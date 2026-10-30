local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")

require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

---查找场上当前英雄实例（分身与召唤物据此继承英雄实时属性）
---@param store table
---@return table
local function find_hero(store)
	for _, e in pairs(store.entities) do
		if e.template_name == "hero_myriath" then
			return e
		end
	end
end

local function hero_myriath_can_dodge(store, this, ranged_attack, attack, enemy)
	local skb = this.timed_attacks.list[2]

	if skb and not skb.disabled and store.tick_ts - skb.ts > skb.cooldown * (this.unit.cooldown_factor or 1) then
		if enemy and enemy.health and not enemy.health.dead then
			local enp = enemy.nav_path
			local new_ni = enp.ni
			local node_limit = math.floor(skb.min_distance_from_end / P.average_node_dist)
			local node_jump = math.floor(skb.distance / P.average_node_dist)
			local nodes_to_goal = P:nodes_to_goal(enp.pi, enp.spi, enp.ni)

			if node_limit < nodes_to_goal then
				new_ni = new_ni + math.min(nodes_to_goal - 1, node_jump)

				local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

				if band(GR:cell_type(new_pos.x, new_pos.y), TERRAIN_NOWALK) == 0 then
					this.dodge.new_pos = new_pos

					return true
				end
			end
		end
	end

	return false
end

local function hero_myriath_level_up(this, store)
	if this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
	this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
	this.ranged.attacks[1].damage_min = ls.ranged_damage_min[hl]
	this.ranged.attacks[1].damage_max = ls.ranged_damage_max[hl]

	upgrade_skill(this, "skill_a", function(this, s)
		this.timed_attacks.list[1].disabled = nil
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		this.timed_attacks.list[2].disabled = nil
		this.timed_attacks.list[2].cooldown = s.cooldown[s.level]
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.cooldown = s.cooldown
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		this.hero.skills.talent_1.ts = store.tick_ts
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		this.hero.skills.talent_2.ts = store.tick_ts
	end)
	update_hp(this)
end

local function hero_myriath_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

local function hero_myriath_update(this, store)
	local h = this.health
	local brk, sta
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	local clone_ids = {}
	local t1 = this.hero.skills.talent_1
	local t2 = this.hero.skills.talent_2
	local ska = this.timed_attacks.list[1]
	local pow_a = this.hero.skills.skill_a
	local skb = this.timed_attacks.list[2]
	local pow_b = this.hero.skills.skill_b
	local skc = this.timed_attacks.list[3]
	local pow_c = this.hero.skills.skill_c
	local ult = this.timed_attacks.list[4]
	local ultimate = this.hero.skills.ultimate
	local cdf = this.unit.cooldown_factor or 1

	ska.ts = store.tick_ts - ska.cooldown * cdf
	skb.ts = store.tick_ts - skb.cooldown * cdf
	skc.ts = store.tick_ts - skc.cooldown * cdf
	ult.ts = store.tick_ts - ult.cooldown * cdf

	local function add_clone_id(id)
		table.insert(clone_ids, id)
	end

	local function remove_clone_id(id)
		table.remove(clone_ids, table.indexforobject(clone_ids, id))
	end

	local function cant_do_action()
		return SU.soldier_interrupted(this)
	end

	local function find_most_populated_path(enemies)
		local paths = {}
		local counts = {}

		for _, e in pairs(enemies) do
			local pi = e.nav_path.pi

			if not counts[pi] then
				counts[pi] = 0

				paths[#paths + 1] = pi
			end

			counts[pi] = counts[pi] + 1
		end

		local out = {}

		for _, pi in ipairs(paths) do
			out[#out + 1] = {pi, counts[pi]}
		end

		table.sort(out, function(v1, v2)
			return v1[2] > v2[2]
		end)

		return out
	end

	local function sort_paths_by_distance(paths, min_distance)
		local available = {}

		for _, v in ipairs(paths) do
			local pi = v[1]
			local n = P:nearest_nodes(this.pos.x, this.pos.y, {pi})[1][3]
			local first_node = P:get_visible_start_node(pi)
			local count = 0
			local found = false

			for i = 0, min_distance do
				if first_node <= n - i then
					found = true

					break
				end

				if P:is_node_valid(pi, first_node < n - i and n - i or first_node, 0) and not (store.level.ignore_walk_backwards_paths and table.contains(store.level.ignore_walk_backwards_paths, pi)) then
					count = count + 1

					if count >= min_distance then
						found = true

						break
					end
				else
					break
				end
			end

			if found then
				available[#available + 1] = v
			end
		end

		return available
	end

	this.add_clone_id = add_clone_id
	this.remove_clone_id = remove_clone_id

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
				this.hero.tombstone_show_time = nil
				this.hero.tombstone_respawn_animation = nil
			end

			SU.y_hero_death_and_respawn(store, this)

			this.hero.tombstone_show_time = old_tombstone_time
			this.hero.tombstone_respawn_animation = old_tombstone_respawn_animation
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto continue
				end
			end

			if not ult.disabled and ready_to_use_skill(ult, store, this.unit.cooldown_factor) then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y)
				local target, targets = U.find_foremost_enemy(store, this.pos, ult.min_detection_range, ult.max_detection_range, ult.prediction, 0, ult.bans, function(v)
					for _, p in pairs(nearest) do
						if p[1] == v.nav_path.pi and v.nav_path.ni < p[3] then
							return true
						end
					end

					return false
				end)

				if not targets or #targets < ult.min_targets then
					SU.delay_attack(store, ult, fts(10))
				else
					local paths = sort_paths_by_distance(find_most_populated_path(targets), ult.distance)

					if #paths == 0 then
						SU.delay_attack(store, ult, fts(10))
					else
						local n = P:nearest_nodes(this.pos.x, this.pos.y, {paths[1][1]})
						local pos = P:node_pos(n[1][1], n[1][2], n[1][3])

						U.animation_start(this, ult.animation, this.render.sprites[1].flip_x, store.tick_ts, false)
						S:queue(ult.sound_taunt)

						if SU.y_hero_wait(store, this, ult.cast_time) then
							goto continue
						end

						S:queue(ult.sound_cast)

						for i = 1, 3 do
							local s = E:create_entity(ult.soldier)

							s.pos = V.vclone(this.pos)
							s.pi = n[1][1]
							s.spi = i
							s.ni = n[1][3] + math.random(-4, 4)
							s.source_id = this.id

							simulation:queue_insert_entity(s)
							U.y_wait(store, fts(3))
						end

						SU.hero_gain_xp_from_skill(this, ultimate)
						U.y_animation_wait(this)

						ult.ts = store.tick_ts

						goto continue
					end
				end
			end

			if skb and not skb.disabled and this.vis.bans ~= F_ALL and this.dodge.new_pos and ready_to_use_skill(skb, store, this.unit.cooldown_factor) then
				local enemy = store.entities[this.soldier.target_id]

				if not enemy then
					this.dodge.new_pos = nil
				else
					local new_pos = this.dodge.new_pos

					this.dodge.new_pos = nil

					U.animation_start(this, skb.animation_out, nil, store.tick_ts, false)

					if SU.y_hero_wait(store, this, fts(6)) then
						goto continue
					end

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)
					SU.hide_modifiers(store, this, true)
					SU.hide_auras(store, this, true)
					S:queue(skb.sound)

					local clone = E:create_entity(ska.clone)

					clone.pos.x, clone.pos.y = this.pos.x, this.pos.y
					clone.target_block = enemy
					clone.animation_spawn = "in"
					clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x

					simulation:queue_insert_entity(clone)
					U.y_animation_wait(this)

					this.pos.x, this.pos.y = new_pos.x, new_pos.y

					if not this.nav_rally.new then
						this.nav_rally.center = V.vclone(this.pos)
						this.nav_rally.pos = V.vclone(this.pos)
					end

					SU.hero_gain_xp_from_skill(this, pow_b)

					U.animation_start(this, skb.animation_in, nil, store.tick_ts, false)
					U.y_wait(store, fts(3))
					SU.y_hero_animation_wait(this)

					U.bans_remove(this.vis, F_ALL)
					SU.show_modifiers(store, this, true)
					SU.show_auras(store, this, true)
					U.y_animation_wait(this)

					skb.ts = store.tick_ts

					goto continue
				end
			end

			if skc and not skc.disabled and ready_to_use_skill(skc, store, this.unit.cooldown_factor) then
				local target = store.entities[this.soldier.target_id]

				if not target or not this.motion.arrived or target.health.dead then
					SU.delay_attack(store, skc, fts(10))
				else
					h.ignore_damage = true
					this.health_bar.hidden = true

					S:queue(skc.sound_cast)
					U.animation_start(this, skc.animation_in, this.render.sprites[1].flip_x, store.tick_ts, false)

					for _, id in ipairs(clone_ids) do
						if store.entities[id] then
							store.entities[id].cast_mirror_slash = true
						end
					end

					SU.y_hero_animation_wait(this)

					if cant_do_action() then
						skc.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, pow_c)

						h.ignore_damage = false
						this.health_bar.hidden = false

						goto continue
					end

					local original_pos = V.vclone(this.pos)

					this.pos = V.vclone(target.pos)

					U.animation_start(this, skc.animation, this.render.sprites[1].flip_x, store.tick_ts, false)
					S:queue(skc.sound_hit)

					for _, hit_time in pairs(skc.hit_times) do
						U.y_wait(store, hit_time)

						local d = E.assign_damage(skc.damage_type, math.ceil((math.random(skc.damage_min, skc.damage_max) + this.unit.damage_buff) * this.unit.damage_factor), this.id, this.soldier.target_id)

						d.track_kills = this.track_kills ~= nil
						d.track_damage = skc.track_damage
						d.pop = skc.pop
						d.pop_chance = skc.pop_chance
						d.pop_conds = skc.pop_conds

						queue_damage(store, d)

						local fx = E:create_entity(skc.hit_fx)

						fx.pos.x, fx.pos.y = this.pos.x + skc.hit_offset.x, this.pos.y + skc.hit_offset.y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
					end

					U.y_wait(store, fts(3))

					this.pos = original_pos

					U.animation_start(this, skc.animation_out, this.render.sprites[1].flip_x, store.tick_ts, false)
					U.y_wait(store, fts(3))
					SU.y_hero_animation_wait(this)

					h.ignore_damage = false
					this.health_bar.hidden = false

					SU.hero_gain_xp_from_skill(this, pow_c)

					skc.ts = store.tick_ts

					goto continue
				end
			end

			if ska and not ska.disabled and ready_to_use_skill(ska, store, this.unit.cooldown_factor) then
				local target, targets = U.find_foremost_enemy(store, this.pos, ska.min_range, ska.max_range, ska.node_prediction, ska.vis_flags, ska.vis_bans, function(e)
					return band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0
				end)

				if not target or #targets == 0 then
					SU.delay_attack(store, ska, fts(10))
				else
					this.render.sprites[1].flip_x = target.pos.x < this.pos.x

					U.animation_start(this, ska.animation, nil, store.tick_ts, false)
					U.y_wait(store, fts(19), cant_do_action)

					if cant_do_action() then
						goto continue
					end

					local flip = target.render.sprites[1].flip_x and -1 or 1
					local bullet = E:create_entity(ska.bullet)

					bullet.pos = V.v(this.pos.x, this.pos.y)
					bullet.bullet.from = V.vclone(bullet.pos)
					bullet.bullet.to = P:predict_enemy_pos(target, ska.flight_time)
					bullet.bullet.to.x = bullet.bullet.to.x + (target.enemy.melee_slot.x + this.soldier.melee_slot_offset.x) * flip
					bullet.bullet.target_id = target.id
					bullet.bullet.source_id = this.id

					simulation:queue_insert_entity(bullet)
					S:queue(ska.sound)
					SU.y_hero_animation_wait(this)
					SU.hero_gain_xp_from_skill(this, pow_a)

					ska.ts = store.tick_ts

					goto continue
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if sta == A_DONE then
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			elseif brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::continue::

		this.dodge.active = false

		coroutine.yield()
	end
end

local function soldier_myriath_clone_insert(this, store)
	local hero = find_hero(store)

	this.hero_myriath = hero
	this.melee.attacks[1].damage_min = hero.melee.attacks[1].damage_min * this.basic_melee_attack_ptg
	this.melee.attacks[1].damage_max = hero.melee.attacks[1].damage_max * this.basic_melee_attack_ptg
	this.ranged.attacks[1].damage_min = hero.ranged.attacks[1].damage_min * this.basic_ranged_attack_ptg
	this.ranged.attacks[1].damage_max = hero.ranged.attacks[1].damage_max * this.basic_ranged_attack_ptg
	this.timed_attacks.list[1].damage_min = hero.timed_attacks.list[3].damage_min * this.skill_c_attack_ptg
	this.timed_attacks.list[1].damage_max = hero.timed_attacks.list[3].damage_max * this.skill_c_attack_ptg
	this.nav_rally.pos = V.vclone(this.pos)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	local t1 = hero.hero.skills.talent_1

	if t1.level > 0 then
		this.health.hp_max = this.health.hp_max + t1.health_inc
		this.health.hp = this.health.hp_max
		this.duration = this.duration + t1.duration_inc
	end

	if hero.hero.skills.talent_2.level > 0 then
		this.aura_explosion = hero.hero.skills.talent_2.aura
	end

	if this.target_block then
		U.block_enemy(store, this, this.target_block)

		this.render.sprites[1].flip_x = not this.target_block.render.sprites[1].flip_x
	else
		this.render.sprites[1].flip_x = hero.render.sprites[1].flip_x
	end

	return true
end

local function soldier_myriath_clone_update(this, store)
	local spawn_ts = store.tick_ts
	local h = this.health
	local brk, sta

	this.health_bar.hidden = false

	local skc = this.timed_attacks.list[1]

	U.animation_start(this, this.animation_spawn, nil, store.tick_ts, false)

	if string.find(this.animation_spawn, "ultimate") then
		U.y_wait(store, this.animation_spawn_hit_time)

		if this.animation_spawn_hit_fx then
			local sfx = E:create_entity(this.animation_spawn_hit_fx)

			sfx.pos.x, sfx.pos.y = this.pos.x + this.melee.attacks[1].hit_offset.x * (this.render.sprites[1].flip_x and -1 or 1), this.pos.y + this.melee.attacks[1].hit_offset.y
			sfx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(sfx)
		end
	end

	U.y_animation_wait(this, 1, 1)
	this.hero_myriath.add_clone_id(this.id)

	while true do
		if h.dead or store.tick_ts - spawn_ts > this.duration then
			local sfx = this.death_sfx
			local death = this.death_anim

			if this.aura_explosion then
				local hero = this.hero_myriath
				local aura = E:create_entity(this.aura_explosion)

				aura.aura.source_id = this.id
				aura.aura.damage_min = aura.aura.damage_min + hero.unit.damage_buff
				aura.aura.damage_max = aura.aura.damage_max + hero.unit.damage_buff
				aura.aura.damage_factor = hero.unit.damage_factor
				aura.pos = V.vclone(this.pos)

				simulation:queue_insert_entity(aura)

				sfx = this.death_explosion_sfx
				death = this.death_anim_explosion
			end

			this.hero_myriath.remove_clone_id(this.id)

			this.ui.can_click = false

			S:queue(sfx)
			SU.remove_modifiers(store, this)
			U.unblock_target(store, this)
			U.y_animation_play(this, death, this.render.sprites[1].flip_x, store.tick_ts, 1, 1)
			simulation:queue_remove_entity(this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			local target = this.soldier.target_id and store.entities[this.soldier.target_id]

			if this.cast_mirror_slash and target and not target.health.dead then
				this.cast_mirror_slash = false
				this.health.ignore_damage = true
				this.health_bar.hidden = true

				U.y_wait(store, fts(0.1))
				S:queue(skc.sound_cast)
				U.animation_start(this, skc.animation_in, this.render.sprites[1].flip_x, store.tick_ts, false)
				U.y_animation_wait(this)

				local original_pos = V.vclone(this.pos)

				this.pos = V.vclone(target.pos)

				U.animation_start(this, skc.animation, this.render.sprites[1].flip_x, store.tick_ts, false)
				S:queue(skc.sound_hit)

				for _, hit_time in pairs(skc.hit_times) do
					U.y_wait(store, hit_time)

					local d = E.assign_damage(skc.damage_type, math.ceil((math.random(skc.damage_min, skc.damage_max) + this.unit.damage_buff) * this.unit.damage_factor), this.id, this.soldier.target_id)

					queue_damage(store, d)

					local fx = E:create_entity(skc.hit_fx)

					fx.pos.x, fx.pos.y = this.pos.x + skc.hit_offset.x, this.pos.y + skc.hit_offset.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end

				U.y_wait(store, fts(6))

				this.pos = original_pos

				U.y_animation_play(this, skc.animation_out, this.render.sprites[1].flip_x, store.tick_ts, 1, 1)

				this.health.ignore_damage = false
				this.health_bar.hidden = false
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if sta == A_DONE then
				U.animation_start(this, "idle", nil, store.tick_ts, true)
			elseif brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
				-- block empty
				else
					SU.soldier_idle(store, this)
				end
			end
		end

		coroutine.yield()
	end
end

local function bullet_myriath_basic_ranged_update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

	local function move_step(dest)
		local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
		local dist = V.len(dx, dy)
		local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
		local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

		if dist <= 4 * fm.max_v * store.tick_length then
			stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
		end

		fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
		fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
		fm.a.x, fm.a.y = 0, 0

		return dist <= fm.max_v * store.tick_length
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)

		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x), math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle, iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local source = store.entities[b.source_id]
		local ra = source.ranged.attacks[1]
		local value = (math.random(ra.damage_min, ra.damage_max) + source.unit.damage_buff) * source.unit.damage_factor
		local d = E.assign_damage(b.damage_type, math.max(1, value), this.id, target.id)

		d.reduce_magic_armor = b.reduce_magic_armor
		d.xp_dest_id = b.xp_dest_id
		d.xp_gain_factor = b.xp_gain_factor
		d.pop = b.pop
		d.pop_chance = b.pop_chance
		d.pop_conds = b.pop_conds

		queue_damage(store, d)

	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	S:queue(this.hit_sfx)

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end

local function bullet_myriath_skill_a_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if this.tween then
		for i = 1, #this.tween.props do
			this.tween.props[i].ts = store.tick_ts
		end
	end

	return true
end

local function bullet_myriath_skill_a_update(this, store)
	local b = this.bullet
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)

		local target = store.entities[b.target_id]

		if target and store.entities[b.source_id] and target.pos.x < store.entities[b.source_id].pos.x then
			ps.particle_system.scales_x = {-1}
		else
			ps.particle_system.scales_x = {1}
		end
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
	end

	local source = store.entities[b.source_id]

	if b.target_id then
		local power = source.hero.skills.skill_a
		local value = (math.random(power.damage_min[power.level], power.damage_max[power.level]) + source.unit.damage_buff) * source.unit.damage_factor
		local d = E.assign_damage(b.damage_type, math.ceil(value), b.source_id, b.target_id)

		queue_damage(store, d)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
	end

	if b.hit_payload then
		local target = store.entities[b.target_id]
		local hp = E:create_entity(b.hit_payload)
		local flip = target and target.render.sprites[1].flip_x and -1 or 1
		local pos_x = target and target.pos.x + (target.enemy.melee_slot.x + source.soldier.melee_slot_offset.x) * flip or b.to.x
		local pos_y = target and target.pos.y + target.enemy.melee_slot.y or b.to.y

		hp.pos.x, hp.pos.y = pos_x, pos_y
		hp.source_id = b.source_id
		hp.target_block = target
		hp.animation_spawn = "ultimate_attack_" .. math.random(1, 3)

		simulation:queue_insert_entity(hp)
	end

	simulation:queue_remove_entity(this)
end

local function soldier_myriath_ult_update(this, store)
	local node_pos, distance
	local path_pi = this.pi
	local path_spi = this.spi
	local path_ni = this.ni
	local traversed = 0

	path_ni = path_ni - 3
	this.nav_rally.pos = P:node_pos(path_pi, path_spi, path_ni)

	if path_spi == 1 then
		local aura = E:create_entity(this.damage_aura)

		aura.pos = this.pos
		aura.aura.source_id = this.source_id

		this.aura = aura

		simulation:queue_insert_entity(aura)
	end

	local ps = E:create_entity(this.particles)

	ps.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps)

	while true do
		if this.duration and store.tick_ts - this.ts > this.duration or not GR:cell_is(this.pos.x, this.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) or GR:cell_is(this.pos.x, this.pos.y, bor(TERRAIN_NOWALK)) or not P:is_node_valid(path_pi, path_ni) or traversed >= this.distance then
			simulation:queue_remove_entity(this)

			return
		end

		node_pos = this.nav_rally.pos
		distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

		if distance < 25 then
			path_ni = path_ni - 3
			traversed = traversed + 3
			this.nav_rally.pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		SU.soldier_go_back_step(store, this)

		coroutine.yield()
	end
end

local function soldier_myriath_ult_remove(this, store, script)
	if this.aura then
		simulation:queue_remove_entity(this.aura)
	end

	return scripts.tween_utils.reverse_remove(this, store, script)
end

local function aura_myriath_ult_update(this, store)
	this.aura.ts = store.tick_ts

	local last_hit_ts = 0
	local cycles_count = 0

	this.aura.excluded_entities = {}

	local clones = 0

	while true do
		if this.aura.cycles then
			if cycles_count >= this.aura.cycles then
				break
			end
		elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level * this.aura.duration_inc then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead then
				simulation:queue_remove_entity(this)

				return
			end

			if te and te.pos then
				this.pos.x, this.pos.y = te.pos.x, te.pos.y
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			cycles_count = cycles_count + 1
			last_hit_ts = store.tick_ts

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.excluded_entities or not table.contains(this.aura.excluded_entities, v.id))
			end)

			local source = store.entities[this.aura.source_id]

			for _, target in pairs(targets) do
				local dmin, dmax = this.aura.damage_min, this.aura.damage_max

				if this.aura.damage_inc then
					dmin = dmin + this.aura.damage_inc * this.aura.level
					dmax = dmax + this.aura.damage_inc * this.aura.level
				end

				local buff = source and source.unit.damage_buff or 0
				local factor = source and source.unit.damage_factor or 1
				local d = E.assign_damage(this.aura.damage_type, math.ceil((math.random(dmin, dmax) + buff) * factor), this.id, target.id)

				d.track_damage = this.aura.track_damage
				d.xp_dest_id = this.aura.xp_dest_id
				d.xp_gain_factor = this.aura.xp_gain_factor

				queue_damage(store, d)
				table.insert(this.aura.excluded_entities, #this.aura.excluded_entities + 1, target.id)

				if clones < this.clone_count then
					clones = clones + 1

					local clone = E:create_entity(this.clone_t)
					local clone_melee_slot = E:get_template(this.clone_t).soldier.melee_slot_offset
					local pos_x = target.pos.x + (target.enemy.melee_slot.x + clone_melee_slot.x) * (target.render.sprites[1].flip_x and -1 or 1)
					local pos_y = target.pos.y + (target.enemy.melee_slot.y + clone_melee_slot.y)

					clone.pos = V.v(pos_x, pos_y)
					clone.target_block = target
					clone.animation_spawn = "in"

					simulation:queue_insert_entity(clone)
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in pairs(mods) do
					local m = E:create_entity(mod_name)

					m.modifier.level = this.aura.level
					m.modifier.target_id = target.id
					m.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						m.render = nil
					end

					simulation:queue_insert_entity(m)
				end

				if this.aura.hit_fx then
					local fx = E:create_entity(this.aura.hit_fx)

					fx.pos.x, fx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_myriath", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "dodge")
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {170, 180, 190, 200, 210, 220, 230, 240, 250, 260}
tt.hero.level_stats.melee_damage_min = {12, 14, 16, 17, 19, 21, 23, 25, 26, 28}
tt.hero.level_stats.melee_damage_max = {18, 21, 23, 26, 29, 32, 34, 37, 40, 42}
tt.hero.level_stats.ranged_damage_min = {12, 14, 16, 17, 19, 21, 23, 25, 26, 28}
tt.hero.level_stats.ranged_damage_max = {18, 21, 23, 26, 29, 32, 34, 37, 40, 42}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.key = "FORWARD_ILLUSION"
tt.hero.skills.skill_a.cooldown = 6
tt.hero.skills.skill_a.damage_min = {12, 24, 36}
tt.hero.skills.skill_a.damage_max = {18, 36, 54}
tt.hero.skills.skill_a.damage_type = DAMAGE_MAGICAL
tt.hero.skills.skill_a.xp_gain = {24, 48, 72}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.key = "GUARDING_DECOY"
tt.hero.skills.skill_b.cooldown = {16, 13, 10}
tt.hero.skills.skill_b.xp_gain = {64, 128, 192}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.key = "MIRROR_MISSILES"
tt.hero.skills.skill_c.cooldown = 12
tt.hero.skills.skill_c.damage_min = {6, 7, 8}
tt.hero.skills.skill_c.damage_max = {8, 10, 12}
tt.hero.skills.skill_c.damage_type = DAMAGE_MAGICAL
tt.hero.skills.skill_c.xp_gain = {48, 96, 192}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.key = "I_AM_LEGION"
tt.hero.skills.ultimate.cooldown = 40
tt.hero.skills.ultimate.damage_type = DAMAGE_MAGICAL
tt.hero.skills.ultimate.damage_min = 60
tt.hero.skills.ultimate.damage_max = 90
tt.hero.skills.ultimate.clone_count = 3
tt.hero.skills.ultimate.xp_gain = {160}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.key = "SOLID_LIGHT"
tt.hero.skills.talent_1.health_inc = 25
tt.hero.skills.talent_1.duration_inc = 2
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.key = "LAST_EFFORT"
tt.hero.skills.talent_2.aura = "aura_myriath_talent_2_area_damage"
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = hero_myriath_level_up
tt.hero.respawn_animation = "respawn"
tt.hero.tombstone_show_time = fts(25)
tt.hero.tombstone_decal = "decal_myriath_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.info.i18n_key = "HERO_MYRIATH"
tt.info.hero_portrait = "kr6_hero_portraits_0005"
tt.info.portrait = "kr6_info_portraits_heroes_0009"
tt.main_script.insert = hero_myriath_insert
tt.main_script.update = hero_myriath_update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "hero_myriathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroGeminaTaunt"
tt.sound_events.death = "HeroGeminaDeath"
tt.sound_events.respawn = "HeroGeminaTauntIntro"
tt.sound_events.hero_room_select = "HeroGeminaTauntSelect"
tt.sound_events.level_up = "HeroGeminaTauntLevelUp"
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.dodge.can_dodge = hero_myriath_can_dodge
tt.dodge.chance = 1
tt.dodge.cooldown = 0
tt.dodge.ranged = false
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].hit_fx = "fx_myriath_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 20)
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 1.6
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.cooldown = 1.5
tt.melee.range = 60
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "basic_ranged"
tt.ranged.attacks[1].bullet = "bullet_myriath_basic_ranged"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(10, 40)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 70
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].node_prediction = fts(1)
tt.ranged.attacks[1].shoot_time = fts(14)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "skill_1"
tt.timed_attacks.list[1].bullet = "bullet_myriath_skill_a"
tt.timed_attacks.list[1].cast_time = fts(17)
tt.timed_attacks.list[1].clone = "soldier_myriath_clone"
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].flight_time = fts(5)
tt.timed_attacks.list[1].max_range = 130
tt.timed_attacks.list[1].min_range = 75
tt.timed_attacks.list[1].min_targets = 1
tt.timed_attacks.list[1].node_prediction = fts(14)
tt.timed_attacks.list[1].sound = "HeroGeminaForwardIllusionCast"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_BLOCK)
tt.timed_attacks.list[1].vis_flags = bor(F_BLOCK)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation_in = "skill_2_in"
tt.timed_attacks.list[2].animation_out = "skill_2_out"
tt.timed_attacks.list[2].cast_time = fts(17)
tt.timed_attacks.list[2].cooldown = 16
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].distance = 50
tt.timed_attacks.list[2].min_distance_from_end = 200
tt.timed_attacks.list[2].sound = "HeroGeminaGuardingDecoyCast"
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "skill_3"
tt.timed_attacks.list[3].animation_in = "skill_3_cast"
tt.timed_attacks.list[3].animation_out = "skill_2_in"
tt.timed_attacks.list[3].cooldown = 12
tt.timed_attacks.list[3].damage_min = 6
tt.timed_attacks.list[3].damage_max = 8
tt.timed_attacks.list[3].damage_type = DAMAGE_MAGICAL
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].hit_fx = "fx_myriath_hit"
tt.timed_attacks.list[3].hit_offset = vec_2(0, 20)
tt.timed_attacks.list[3].hit_times = {fts(1), fts(8), fts(4), fts(5), fts(2), fts(9)}
tt.timed_attacks.list[3].sound_cast = "HeroGeminaMirrorSlashesCast"
tt.timed_attacks.list[3].sound_hit = "HeroGeminaMirrorBarrage"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "ultimate"
tt.timed_attacks.list[4].bans = bor(F_FLYING)
tt.timed_attacks.list[4].cast_time = fts(21)
tt.timed_attacks.list[4].cooldown = 40
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].distance = 40
tt.timed_attacks.list[4].max_detection_range = 80
tt.timed_attacks.list[4].min_detection_range = 20
tt.timed_attacks.list[4].min_targets = 3
tt.timed_attacks.list[4].prediction = 1
tt.timed_attacks.list[4].soldier = "soldier_myriath_ult"
tt.timed_attacks.list[4].sound_cast = "HeroGeminaIAmLegionCast"
tt.timed_attacks.list[4].sound_taunt = "HeroGeminaTauntUltimate"

tt = RT("soldier_myriath_clone", "soldier_militia")
AC(tt, "melee", "ranged", "timed_attacks")
tt.nav_grid = nil
tt.health.armor = 0
tt.health.hp_max = 85
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -161
tt.idle_flip.cooldown = 10
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.hero_portrait = "kr6_hero_portraits_0005"
tt.info.i18n_key = "HERO_MYRIATH_CLONE"
tt.info.portrait = "kr6_info_portraits_heroes_0009"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = soldier_myriath_clone_insert
tt.main_script.update = soldier_myriath_clone_update
tt.motion.max_speed = 100
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_myriath_illusionDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].draw_order = DO_HEROES
tt.melee.attacks[1] = table.deepclone(E:get_template("hero_myriath").melee.attacks[1])
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].xp_gain_factor = 0
tt.ranged.attacks[1] = table.deepclone(E:get_template("hero_myriath").ranged.attacks[1])
tt.ranged.attacks[1].bullet = "bullet_myriath_clone_basic_ranged"
tt.melee.range = 60
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(0, 19.9)
tt.unit.fade_time_after_death = nil
tt.animation_spawn_hit_time = fts(1)
tt.animation_spawn_hit_fx = "fx_myriath_ultimate_decal_hit"
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.timed_attacks.list[1] = table.deepclone(E:get_template("hero_myriath").timed_attacks.list[3])
tt.timed_attacks.list[1].animation_in = "skill_3_in"
tt.timed_attacks.list[1].animation_out = "in"
tt.death_sfx = "HeroGeminaIllusionDeath"
tt.death_explosion_sfx = "HeroGeminaDeathExplosion"
tt.basic_melee_attack_ptg = 0.68
tt.basic_ranged_attack_ptg = 0.68
tt.skill_c_attack_ptg = 1
tt.duration = 6
tt.death_anim = "out"
tt.death_anim_explosion = "death"

tt = RT("soldier_myriath_ult", "soldier_militia")
AC(tt, "tween")
tt.nav_grid = nil
tt.ui.click_rect = r(0, 0, 0, 0)
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = soldier_myriath_ult_update
tt.main_script.remove = soldier_myriath_ult_remove
tt.motion.max_speed = 80
tt.render.sprites[1].prefix = "hero_myriath_FX_stampede"
tt.render.sprites[1].name = "side"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"side", "back", "front"}
tt.render.sprites[1].offset = vec_2(0, -20)
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.vis.bans = bor(F_ALL)
tt.damage_aura = "aura_myriath_ultimate_damage"
tt.particles = "ps_myriath_ult_trail"
tt.distance = 40

tt = RT("bullet_myriath_skill_a", "bomb")
tt.render.sprites[1].hidden = true
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 0
tt.bullet.flight_time = fts(5)
tt.bullet.g = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = "fx_myriath_skill_c_hit"
tt.bullet.hit_payload = "soldier_myriath_clone"
tt.bullet.ignore_rotation = true
tt.bullet.level = nil
tt.bullet.particles_name = "ps_myriath_skill_a_trail"
tt.main_script.insert = bullet_myriath_skill_a_insert
tt.main_script.update = bullet_myriath_skill_a_update
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
tt.sound_events.insert = nil

tt = RT("bullet_myriath_basic_ranged", "bolt")
AC(tt, "force_motion")
tt.render.sprites[1].prefix = "hero_myriath_FX_skill3_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.bullet.align_with_trajectory = true
tt.bullet.chance_to_ignore_mr = 1
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.flight_time = fts(5)
tt.bullet.g = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_myriath_skill_c_hit"
tt.bullet.particles_name = "ps_myriath_skill_c_trail"
tt.bullet.pop = {"pop_zap"}
tt.bullet.predict_target_pos = true
tt.bullet.prediction_error = true
tt.bullet.reduce_magic_armor = 1
tt.bullet.xp_gain_factor = 1.6
tt.force_motion.a_step = 4
tt.force_motion.max_a = 850 * FPS
tt.force_motion.max_v = 35 * FPS
tt.force_motion.v = vec_2(0, 175)
tt.hit_sfx = "HeroGeminaMagicMissileImpact"
tt.initial_impulse = 2500
tt.initial_impulse_angle_abs = math.pi / 2
tt.initial_impulse_duration = 0.05
tt.main_script.insert = nil
tt.main_script.update = bullet_myriath_basic_ranged_update
tt.sound_events.insert = nil
tt.sound_events.remove = nil

tt = RT("bullet_myriath_clone_basic_ranged", "bullet_myriath_basic_ranged")
tt.bullet.xp_gain_factor = 0

tt = RT("aura_myriath_talent_2_area_damage", "aura")
tt.aura.cycles = 1
tt.aura.damage_max = 72
tt.aura.damage_min = 48
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.radius = 75
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("aura_myriath_ultimate_damage", "aura")
tt.aura.damage_max = 90
tt.aura.damage_min = 60
tt.aura.damage_type = DAMAGE_MAGICAL
tt.aura.duration = 1e+99
tt.aura.radius = 55
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_AREA)
tt.clone_count = 3
tt.clone_t = "soldier_myriath_clone"
tt.main_script.update = aura_myriath_ult_update

tt = RT("ps_myriath_skill_a_trail", "particle_system")
tt.particle_system.emission_rate = 30
tt.particle_system.name = "hero_myriath_FX_walk_trail_action"
tt.particle_system.particle_lifetime = {fts(9), fts(9)}

tt = RT("ps_myriath_skill_c_trail", "particle_system")
tt.particle_system.emit_area_spread = vec_2(10, 0)
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.emission_rate = 40
tt.particle_system.name = "hero_myriath_FX_skill3_particle_action"

tt = RT("ps_myriath_ult_trail", "particle_system")
tt.particle_system.emit_area_spread = vec_2(5, 5)
tt.particle_system.emission_rate = 1.5
tt.particle_system.name = "hero_myriath_FX_ult_trail_run"
tt.particle_system.particle_lifetime = {fts(56), fts(56)}
tt.particle_system.z = Z_DECALS

tt = RT("fx_myriath_hit", "fx")
tt.render.sprites[1].prefix = "hero_myriath_FX_attack_hit"
tt.render.sprites[1].name = "action"

tt = RT("fx_myriath_skill_c_hit", "fx")
tt.render.sprites[1].offset = vec_2(0, -15)
tt.render.sprites[1].prefix = "hero_myriath_FX_skill3_hit"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_myriath_ultimate_ray", "fx")
tt.render.sprites[1].prefix = "hero_myriath_FX_ulti"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("fx_myriath_ultimate_decal_hit", "fx")
tt.render.sprites[1].prefix = "hero_myriath_FX_ulti_hit"
tt.render.sprites[1].name = "action"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("decal_myriath_tombstone", "decal_tween")
tt.render.sprites[1].prefix = "hero_myriathDef"
tt.render.sprites[1].name = "grave"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(1), 0}}
