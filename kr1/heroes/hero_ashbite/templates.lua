local bit = require("bit")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local km = require("lib.klua.macros")
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

local function mod_ashbite_talent_2_armor_red_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		return false
	end

	SU.armor_dec(target, this.modifier.armor_red_factor)

	return false
end

local function mod_ashbite_skill_b_stun_insert(this, store)
	local source = store.entities[this.modifier.source_id]
	local level = source and source.hero and source.hero.skills.skill_b.level or 1

	this.modifier.duration = level + 1

	return scripts.mod_stun.insert(this, store)
end

local function mod_ashbite_burn_update(this, store)
	local m = this.modifier
	local dps = this.dps
	local dmin, dmax = dps.damage_min, dps.damage_max
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local source = store.entities[m.source_id]
	local hero = source
	local armor_sunder = 0

	if source and source.aura then
		local aura_source = store.entities[source.aura.source_id]

		if aura_source and aura_source.bullet then
			hero = store.entities[aura_source.bullet.source_id]
		else
			hero = aura_source
		end

		armor_sunder = source.aura.armor_sunder or 0
	end

	local damage_buff = hero and hero.unit and hero.unit.damage_buff or 0
	local damage_factor = hero and hero.unit and hero.unit.damage_factor or 1
	local source_id = hero and hero.id or this.id

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		if store.tick_ts - m.ts >= m.duration - 1e-09 then
			break
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			local so = this.render.sprites[1].offset

			so.x, so.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
			dps.ts = dps.ts + dps.damage_every

			local value = math.floor((math.random(dmin, dmax) + damage_buff) * damage_factor)

			if not dps.kill then
				value = km.clamp(0, target.health.hp - 1, value)
			end

			value = math.max(1, value)

			local d = E:create_entity("damage")

			d.source_id = source_id
			d.target_id = target.id
			d.value = value
			d.damage_type = dps.damage_type
			d.pop = dps.pop
			d.pop_chance = dps.pop_chance
			d.pop_conds = dps.pop_conds

			queue_damage(store, d)

			if armor_sunder > 0 and band(target.vis.flags, F_BOSS) == 0 then
				SU.armor_dec(target, armor_sunder)
			end

			if dps.fx and (not dps.fx_every or store.tick_ts - (this._fx_ts or 0) >= dps.fx_every) then
				this._fx_ts = store.tick_ts

				local fx = E:create_entity(dps.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function aura_ashbite_skill_a_update(this, store)
	local a = this.aura
	local last_hit_ts = store.tick_ts - a.cycle_time

	a.ts = store.tick_ts

	while true do
		if a.duration >= 0 and store.tick_ts - a.ts >= a.duration then
			break
		end

		local source = store.entities[a.source_id]
		local damage_buff, damage_factor

		if source and source.unit then
			damage_buff = source.unit.damage_buff or 0
			damage_factor = source.unit.damage_factor or 1
		else
			damage_buff = 0
			damage_factor = 1
		end

		if store.tick_ts - last_hit_ts >= a.cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

			if targets then
				for _, target in ipairs(targets) do
					local value = math.floor((math.random(a.damage_min, a.damage_max) + damage_buff) * damage_factor)
					local d = E:create_entity("damage")

					d.source_id = a.source_id
					d.target_id = target.id
					d.damage_type = a.damage_type
					d.value = math.max(1, value)

					queue_damage(store, d)

					if a.mod then
						local mod = E:create_entity(a.mod)

						mod.modifier.level = 1
						mod.modifier.target_id = target.id
						mod.modifier.source_id = a.source_id

						simulation:queue_insert_entity(mod)
					end
				end
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function aura_ashbite_skill_b_insert(this, store)
	local source = store.entities[this.aura.source_id]

	if source and source.bullet and source.bullet.armor_sunder then
		this.aura.armor_sunder = source.bullet.armor_sunder
	end

	this.aura.duration = 2 + 2 * (this.aura.level or 1)

	return scripts.aura_apply_mod.insert(this, store)
end

local function hero_ashbite_level_up(this, store, initial)
	if not initial and this.hero.level > 1 then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)
	local skills = this.hero.skills

	upgrade_skill(this, "skill_a", function(this, s)
		this.timed_attacks.list[1].disabled = nil
	end)
	upgrade_skill(this, "skill_b", function(this, s)
		this.timed_attacks.list[2].disabled = nil
	end)
	upgrade_skill(this, "skill_c", function(this, s)
		this.timed_attacks.list[3].disabled = nil
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.timed_attacks.list[4].disabled = nil
	end)
	upgrade_skill(this, "talent_1", function(this, s)
		s.disabled = nil
	end)
	upgrade_skill(this, "talent_2", function(this, s)
		s.disabled = nil
	end)
	update_hp(this)
end

local function hero_ashbite_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

local function hero_ashbite_remove(this, store)
	return true
end

local function hero_ashbite_update(this, store)
	local h = this.health
	local skills = this.hero.skills
	local sa = skills.skill_a
	local sb = skills.skill_b
	local sc = skills.skill_c
	local su = skills.ultimate
	local st1 = skills.talent_1
	local st2 = skills.talent_2
	local aa = this.ranged.attacks[1]
	local saa = this.timed_attacks.list[1]
	local sba = this.timed_attacks.list[2]
	local sca = this.timed_attacks.list[3]
	local ua = this.timed_attacks.list[4]
	local level_stats = this.hero.level_stats
	local brk, sta
	local feeding_time = false
	local feeding_time_mod
	local feeding_time_start_ts = 0
	local shadow_sprite = this.render.sprites[2]
	local cdf = this.unit.cooldown_factor or 1

	aa.ts = store.tick_ts - aa.cooldown * cdf
	saa.ts = store.tick_ts - saa.cooldown * cdf
	sba.ts = store.tick_ts - sba.cooldown * cdf
	sca.ts = store.tick_ts - sca.cooldown * cdf
	ua.ts = store.tick_ts - ua.cooldown * cdf

	local ult_start_cd = store.wave_group_number == 0

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

	local function flap_fx()
		local f = E:create_entity(sca.flap_fx)

		f.pos.x, f.pos.y = this.pos.x, this.pos.y
		f.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(f)
	end

	this.flap_fx_fn = flap_fx

	local function spawn_ultimate_bullet(attack, target, offset)
		local pred_pos
		local pred_ni

		if attack.node_prediction and target.motion and target.motion.speed then
			if target.motion.forced_waypoint then
				local dt = attack.node_prediction == true and 1 or attack.node_prediction

				pred_pos = V.v(target.pos.x + dt * target.motion.speed.x, target.pos.y + dt * target.motion.speed.y)
				pred_ni = target.nav_path.ni
			else
				local node_offset = P:predict_enemy_node_advance(target, attack.node_prediction)

				pred_ni = target.nav_path.ni + node_offset
				pred_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, pred_ni)
			end
		else
			pred_pos = target.pos
			pred_ni = target.nav_path.ni
		end

		local dir = this.render.sprites[1].flip_x and -1 or 1
		local b = E:create_entity(attack.bullet_t)

		b.bullet.target_id = target.id
		b.bullet.source_id = this.id
		b.bullet.xp_dest_id = this.id
		b.bullet.damage_min = attack.damage_min + (this.unit.damage_buff or 0)
		b.bullet.damage_max = attack.damage_max + (this.unit.damage_buff or 0)
		b.bullet.damage_factor = this.unit.damage_factor
		b.pos = V.v(this.pos.x + offset.x * dir, this.pos.y + this.flight_height + offset.y)
		b.bullet.from = V.vclone(b.pos)

		if b.bullet.ignore_hit_offset then
			b.bullet.to = V.v(pred_pos.x, pred_pos.y)
		else
			b.bullet.to = V.v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
		end

		simulation:queue_insert_entity(b)
	end

	local function find_targets_ultimate(a)
		local function sum_of_values(t)
			local sum = 0

			for i = 1, #t do
				sum = sum + t[i]
			end

			return sum
		end

		local target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

		if not targets or #targets < a.min_targets then
			return nil
		end

		local real_prediction = a.node_prediction + sum_of_values(a.fireball_timings)
		local _, real_targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, real_prediction, a.vis_flags, a.vis_bans)

		if not real_targets then
			return nil
		end

		targets = table.filter(real_targets, function(k, v)
			if not v.nav_path or not v.__ffe_pos then
				return false
			end

			local vni = P:nearest_nodes(v.__ffe_pos.x, v.__ffe_pos.y, {v.nav_path.pi})[1][3]

			return v.nav_path and v.__ffe_pos and (GR:cell_is(v.__ffe_pos.x, v.__ffe_pos.y, TERRAIN_LAND) or GR:cell_is(v.__ffe_pos.x, v.__ffe_pos.y, TERRAIN_ICE)) and P:is_node_valid(v.nav_path.pi, vni)
		end)

		table.sort(targets, function(e1, e2)
			local p1 = e1.nav_path
			local p2 = e2.nav_path

			return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
		end)

		return targets
	end

	local function bow_attack()
		if feeding_time then
			return
		end

		if store.tick_ts - aa.ts < aa.cooldown * (this.unit.cooldown_factor or 1) then
			return
		end

		local pos_offset = V.v(this.pos.x + aa.ignore_offset.x, this.pos.y + aa.ignore_offset.y)
		local _, targets = U.find_foremost_enemy(store, this.pos, aa.min_range, aa.max_range, 0, aa.vis_flags, aa.vis_bans, function(e)
			return V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > aa.radius * aa.radius
		end)

		if not targets or #targets == 0 then
			return
		end

		local target = targets[1]
		local start_ts = store.tick_ts
		local node_offset = P:predict_enemy_node_advance(target, aa.node_prediction)
		local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
		local an, af = U.animation_name_facing_point(this, aa.animation, t_pos)

		U.animation_start(this, an, af, store.tick_ts)

		while store.tick_ts - start_ts < aa.shoot_time do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				return
			end

			coroutine.yield()
		end

		S:queue(aa.sound)

		local b = E:create_entity(aa.bullet)
		local hl = this.hero.level
		local buff = this.unit.damage_buff or 0

		b.bullet.target_id = target.id
		b.bullet.source_id = this.id
		b.bullet.xp_dest_id = this.id
		b.bullet.damage_min = level_stats.ranged_damage_min[hl] + buff
		b.bullet.damage_max = level_stats.ranged_damage_max[hl] + buff
		b.bullet.damage_factor = this.unit.damage_factor

		if st1.level > 0 then
			b.bullet.mod = st1.mod_t
		end

		b.pos = V.vclone(this.pos)

		local bullet_start_offset = V.v(0, 0)

		if aa.bullet_start_offset and #aa.bullet_start_offset == 2 then
			bullet_start_offset = aa.bullet_start_offset[af and 2 or 1]
		end

		b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
		b.pos.y = b.pos.y + bullet_start_offset.y
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)

		simulation:queue_insert_entity(b)

		aa.ts = start_ts

		while not U.animation_finished(this) do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				return
			end

			coroutine.yield()
		end

		aa.ts = start_ts

		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
	end

	while true do
		if ult_start_cd and store.wave_group_number > 0 then
			ult_start_cd = false
			ua.ts = store.tick_ts
		end

		if h.dead then
			if this.__dust_controller then
				simulation:queue_remove_entity(this.__dust_controller)
				this.__dust_controller = nil
			end

			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		while this.nav_rally.new and not feeding_time do
			if SU.y_hero_new_rally(store, this) then
				goto continue
			end
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "lvlup", nil, store.tick_ts, 1)
		end

		if not feeding_time and ready_to_use_skill(ua, store, this.unit.cooldown_factor) then
			local a = ua
			local enemies = find_targets_ultimate(a)

			if not enemies or #enemies < a.min_targets then
				SU.delay_attack(store, a, fts(10))
			else
				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				S:queue(a.sound)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				local fireballs = #a.fireball_timings
				local max_shot = 1

				for i, wait in ipairs(a.fireball_timings) do
					U.y_wait(store, wait)

					local j = max_shot

					for k = j, #enemies do
						if enemies[k].health.dead and fireballs - (i - 1) < #enemies - (k - 1) then
							j = k + 1
						else
							break
						end
					end

					if max_shot < j + 1 then
						max_shot = j + 1
					end

					if enemies[j] then
						spawn_ultimate_bullet(a, enemies[j], a.fireball_offsets[i])
					end
				end

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, su)

				if SU.y_hero_animation_wait(this) then
					goto continue
				end

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				goto continue
			end
		end

		if not feeding_time and ready_to_use_skill(sca, store, this.unit.cooldown_factor) and GR:cell_is(this.pos.x, this.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) then
			local a = sca
			local target = U.find_nearest_enemy(store, this.pos, 0, this.melee.range, bor(a.vis_flags, F_BLOCK), bor(a.vis_bans, F_CLIFF), function(e)
				return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e)) and e.health.hp > a.target_min_hp and e.health.hp < a.target_max_hp
			end)

			if not target then
				SU.delay_attack(store, a, fts(10))
			else
				local c = E:create_entity(a.dust_c)

				c.ashbite_e = this
				this.__dust_controller = c

				simulation:queue_insert_entity(c)

				this.soldier.target_id = target.id

				U.animation_start(this, a.animation_down, nil, store.tick_ts)
				S:queue(a.sound)
				U.y_wait(store, a.wait_to_lower)

				this.render.sprites[1].z = Z_OBJECTS
				this._current_height = this.flight_height

				U.y_ease_key(store, this, "_current_height", this.flight_height, a.floor_height, a.lower_duration, a.ease_down, function(dt, p)
					this.drag_line_origin_offset.y = this._current_height
					this.render.sprites[1].offset.y = this._current_height
					U.change_health_bar_offset_run_time(this.health_bar, this._current_height + 80)
					this.ui.click_rect.pos.y = this._current_height - 20
					this.unit.hit_offset.y = this._current_height + 10
					this.unit.mod_offset.y = this._current_height + 10

					local scale = km.clamp(1, a.shadow_max_scale, a.shadow_max_scale * (this.flight_height - this._current_height) / (this.flight_height - a.floor_height))

					this.render.sprites[2].scale = V.vv(scale)
				end)

				U.flags_remove(this.vis, F_FLYING)
				U.bans_add(this.vis, F_STUN)

				SU.hero_gain_xp_from_skill(this, sc)

				if this.track_kills and this.track_kills.mod then
					feeding_time_mod = E:create_entity(this.track_kills.mod)
					feeding_time_mod.pos = V.vclone(this.pos)
					feeding_time_mod.modifier.target_id = this.id
					feeding_time_mod.modifier.source_id = this.id
					feeding_time_mod.heal_on_kill.hp = sc.heal_ptg[sc.level] * this.health.hp_max

					simulation:queue_insert_entity(feeding_time_mod)
				end

				feeding_time = true
				feeding_time_start_ts = store.tick_ts

				if SU.y_hero_animation_wait(this) then
					goto continue
				end

				goto continue
			end
		end

		if not feeding_time and ready_to_use_skill(sba, store, this.unit.cooldown_factor) then
			local a = sba
			local pos_offset = V.v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
			local target, enemies = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, o)
				return not e.unit.ignore_stun and not e.unit.is_stunned and GR:cell_is(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) and V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > a.radius * a.radius
			end)

			if not enemies or #enemies == 0 then
				SU.delay_attack(store, a, fts(10))
			else
				table.sort(enemies, function(a1, a2)
					return a1.health.hp_max > a2.health.hp_max
				end)

				target = enemies[1]

				local pred_pos

				if a.node_prediction and target.motion and target.motion.speed then
					if target.motion.forced_waypoint then
						local dt = a.node_prediction == true and 1 or a.node_prediction

						pred_pos = V.v(target.pos.x + dt * target.motion.speed.x, target.pos.y + dt * target.motion.speed.y)
					else
						local node_offset = P:predict_enemy_node_advance(target, a.node_prediction)

						pred_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					end
				else
					pred_pos = target.pos
				end

				this.render.sprites[1].flip_x = pred_pos.x < this.pos.x

				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				S:queue(a.sound)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, sb)

				local d = this.render.sprites[1].flip_x and -1 or 1
				local offset = V.v(a.offset.x * d, a.offset.y)
				local b = E:create_entity(a.bullet_t)

				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				b.bullet.xp_dest_id = this.id
				b.bullet.level = sb.level
				b.bullet.armor_sunder = st2.level > 0 and st2.armor_sunder or 0
				b.bullet.damage_min = sb.damage_min + (this.unit.damage_buff or 0)
				b.bullet.damage_max = sb.damage_max + (this.unit.damage_buff or 0)
				b.bullet.damage_factor = this.unit.damage_factor
				b.pos = V.v(this.pos.x + offset.x, this.pos.y + this.flight_height + offset.y)
				b.bullet.from = V.vclone(b.pos)

				if b.bullet.ignore_hit_offset then
					b.bullet.to = V.v(pred_pos.x, pred_pos.y)
				else
					b.bullet.to = V.v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
				end

				simulation:queue_insert_entity(b)
				U.animation_start(this, "idle", nil, store.tick_ts, true)

				goto continue
			end
		end

		if not feeding_time and ready_to_use_skill(saa, store, this.unit.cooldown_factor) then
			local a = saa
			local pos_offset = V.v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
			local target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, nil, a.vis_flags, a.vis_bans, function(e, o)
				return GR:cell_is(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) and V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > a.radius * a.radius
			end)

			if not targets or #targets < a.min_targets then
				SU.delay_attack(store, a, fts(10))
			else
				local target_pos = target.pos

				this.render.sprites[1].flip_x = target_pos.x < this.pos.x

				U.animation_start(this, a.animation, nil, store.tick_ts, false)
				S:queue(a.sound)

				if SU.y_hero_wait(store, this, a.cast_time) then
					goto continue
				end

				a.ts = store.tick_ts

				SU.hero_gain_xp_from_skill(this, sa)

				local d = this.render.sprites[1].flip_x and -1 or 1
				local offset = V.v(a.offset.x * d, a.offset.y)
				local fx = E:create_entity(a.fx_t)

				fx.pos = V.v(this.pos.x + offset.x, this.pos.y + this.flight_height + offset.y)
				fx.render.sprites[1].r = V.angleTo(target_pos.x - fx.pos.x, target_pos.y - fx.pos.y)
				fx.render.sprites[1].scale = V.v(km.clamp(a.min_scale_x, 1.5, V.dist(fx.pos.x, fx.pos.y, target_pos.x, target_pos.y) / a.image_width), 1)

				simulation:queue_insert_entity(fx)
				U.y_wait(store, a.hit_time)

				local hfx = E:create_entity(a.hit_fx_t)

				hfx.render.sprites[1].ts = store.tick_ts
				hfx.pos.x, hfx.pos.y = target_pos.x, target_pos.y

				simulation:queue_insert_entity(hfx)

				local au = E:create_entity(a.aura_t)

				au.render.sprites[1].ts = store.tick_ts
				au.pos = V.vclone(target_pos)
				au.aura.source_id = this.id
				au.aura.level = sa.level
				au.aura.damage_min = sa.aura_damage_min[sa.level]
				au.aura.damage_max = sa.aura_damage_max[sa.level]

				if st2.level > 0 then
					au.aura.mod = st2.mod
				end

				simulation:queue_insert_entity(au)

				a.ts = store.tick_ts

				U.animation_start(this, "idle", nil, store.tick_ts, true)

				goto continue
			end
		end

		if feeding_time then
			local feeding_target = store.entities[this.soldier.target_id]

			if this.nav_rally.new or not feeding_target or feeding_target.health.dead or store.tick_ts - feeding_time_start_ts > sca.duration then
				if this.soldier.target_id then
					U.unblock_target(store, this)
				end

				if this.__dust_controller then
					simulation:queue_remove_entity(this.__dust_controller)
					this.__dust_controller = nil
				end

				U.animation_start(this, sca.animation_up, nil, store.tick_ts)
				flap_fx()

				this.render.sprites[1].z = Z_FLYING_HEROES
				this._current_height = sca.floor_height

				U.y_ease_key(store, this, "_current_height", sca.floor_height, this.flight_height, sca.raise_duration, sca.ease_up, function(dt, p)
					this.drag_line_origin_offset.y = this._current_height
					this.render.sprites[1].offset.y = this._current_height
					U.change_health_bar_offset_run_time(this.health_bar, this._current_height + 80)
					this.ui.click_rect.pos.y = this._current_height - 20
					this.unit.hit_offset.y = this._current_height + 10
					this.unit.mod_offset.y = this._current_height + 10

					local scale = km.clamp(1, sca.shadow_max_scale, sca.shadow_max_scale * (this.flight_height - this._current_height) / (this.flight_height - sca.floor_height))

					this.render.sprites[2].scale = V.vv(scale)
				end)

				U.flags_add(this.vis, F_FLYING)
				U.bans_remove(this.vis, F_STUN)

				if SU.y_hero_animation_wait(this) then
					goto continue
				end

				if feeding_time_mod then
					simulation:queue_remove_entity(feeding_time_mod)
					feeding_time_mod = nil
				end

				feeding_time = false
				sca.ts = store.tick_ts
			else
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if not brk and sta == A_DONE then
					this.render.sprites[1].ts = store.tick_ts

					U.animation_start(this, "idle", nil, store.tick_ts, true)

					goto continue
				end

				if brk or sta ~= A_NO_TARGET then
					goto continue
				end
			end
		end

		bow_attack()

		SU.soldier_idle(store, this)
		SU.soldier_regen(store, this)

		::continue::

		coroutine.yield()
	end
end

local tt

tt = RT("hero_ashbite", "hero")
AC(tt, "melee", "ranged", "timed_attacks", "tween", "track_kills")
tt.hero.level_stats.armor = {0.05, 0.07, 0.09, 0.11, 0.13, 0.15, 0.17, 0.19, 0.21, 0.23}
tt.hero.level_stats.hp_max = {230, 260, 290, 320, 350, 380, 410, 440, 470, 500}
tt.hero.level_stats.ranged_damage_min = {19, 22, 26, 29, 32, 35, 38, 42, 45, 48}
tt.hero.level_stats.ranged_damage_max = {29, 34, 38, 43, 48, 53, 58, 62, 67, 72}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.aura_damage_min = {4, 6, 9}
tt.hero.skills.skill_a.aura_damage_max = {6, 9, 12}
tt.hero.skills.skill_a.xp_gain = {64, 128, 192}
tt.hero.skills.skill_a.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.damage_min = 32
tt.hero.skills.skill_b.damage_max = 32
tt.hero.skills.skill_b.stun_duration = {2, 3, 4}
tt.hero.skills.skill_b.embers_duration = {4, 6, 8}
tt.hero.skills.skill_b.xp_gain = {80, 160, 240}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.heal_ptg = {0.2, 0.3, 0.4}
tt.hero.skills.skill_c.xp_gain = {120, 240, 360}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.damage_min = 64
tt.hero.skills.ultimate.damage_max = 96
tt.hero.skills.ultimate.xp_gain = {140}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.mod_t = "mod_ashbite_talent_1_fire"
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.armor_sunder = 0.01
tt.hero.skills.talent_2.mod = "mod_ashbite_talent_2_skill_a_armor_red"
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.armor = nil
tt.health.dead_lifetime = 15
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 160)
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -161
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.tombstone_show_time = nil
tt.hero.tombstone_respawn_animation = nil
tt.hero.tombstone_force_over_path = nil
tt.hero.tombstone_concurrent_with_death = nil
tt.hero.fn_level_up = hero_ashbite_level_up
tt.hero.use_custom_spawn_point = true
tt.hero.respawn_animation = "respawn"
tt.flight_height = 80
tt.text_balloon_offset = vec_2(48, 55)
tt.idle_flip.chance = 0.4
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr6_hero_portraits_0008"
tt.info.i18n_key = "HERO_ASHBITE"
tt.info.portrait = "kr6_info_portraits_heroes_0006"
tt.main_script.insert = hero_ashbite_insert
tt.main_script.update = hero_ashbite_update
tt.main_script.remove = hero_ashbite_remove
tt.motion.max_speed = 150
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains_dest = tt.nav_grid.valid_terrains
tt.drag_line_origin_offset = vec_2(0, 80)
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_ashbiteDef"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"idle"}
tt.render.sprites[1].offset.y = 80
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].draw_order = DO_HEROES
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.render.sprites[2].scale = vec_2(1, 1)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = vec_2(30, 0)
tt.sound_events.change_rally_point = "HeroAshbiteTaunt"
tt.sound_events.death = "HeroAshbiteDeath"
tt.sound_events.insert = "HeroAshbiteTauntIntro"
tt.sound_events.level_up = "HeroAshbiteTauntLevelUp"
tt.sound_events.respawn = "HeroAshbiteTauntIntro"
tt.sound_events.hero_room_select = "HeroAshbiteTauntSelect"
tt.ui.click_rect = r(-37, 60, 90, 85)
tt.unit.hit_offset = vec_2(0, 90)
tt.unit.mod_offset = vec_2(0, 90)
tt.unit.hide_after_death = true
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bullet_ashbite"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, 57), vec_2(50, 57)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].ignore_offset = vec_2(0, 110)
tt.ranged.attacks[1].radius = 125
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound = "HeroAshbiteBasicAttack"
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].node_prediction = fts(15)
tt.melee.cooldown = 2
tt.melee.range = 120
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "feeding_attack"
tt.melee.attacks[1].damage_min = 80
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_bans = 0
tt.melee.attacks[1].damage_flags = 0
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "HeroAshbiteFeedingTimeAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(15)
}
tt.melee.attacks[1].vis_bans = 0
tt.melee.attacks[1].xp_gain_factor = 1
tt.melee.attacks[1].hit_fx = "fx_ashbite_skill_c_hit"
tt.melee.attacks[1].hit_offset = vec_2(60, 0)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "breath"
tt.timed_attacks.list[1].cooldown = 16
tt.timed_attacks.list[1].ignore_offset = vec_2(0, 110)
tt.timed_attacks.list[1].radius = 125
tt.timed_attacks.list[1].min_range = 50
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].height_tolerance = 20
tt.timed_attacks.list[1].offset = vec_2(37, -6)
tt.timed_attacks.list[1].min_targets = 3
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].hit_time = fts(5)
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[1].image_width = 145
tt.timed_attacks.list[1].min_scale_x = 0.7
tt.timed_attacks.list[1].aura_t = "aura_ashbite_skill_a"
tt.timed_attacks.list[1].fx_t = "fx_ashbite_skill_a"
tt.timed_attacks.list[1].hit_fx_t = "fx_ashbite_skill_a_hit"
tt.timed_attacks.list[1].sound = "HeroAshbiteBlazingBreathCast"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].animation = "sneeze"
tt.timed_attacks.list[2].cooldown = 20
tt.timed_attacks.list[2].ignore_offset = vec_2(0, 110)
tt.timed_attacks.list[2].radius = 125
tt.timed_attacks.list[2].min_range = 50
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].node_prediction = fts(15)
tt.timed_attacks.list[2].offset = vec_2(37, -6)
tt.timed_attacks.list[2].cast_time = fts(18)
tt.timed_attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[2].vis_flags = bor(F_AREA)
tt.timed_attacks.list[2].bullet_t = "bullet_ashbite_skill_b"
tt.timed_attacks.list[2].sound = "HeroAshbiteSearingSneeze"
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].animation_down = "feeding_down"
tt.timed_attacks.list[3].animation_up = "feeding_up"
tt.timed_attacks.list[3].flap_fx = "fx_ashbite_skill_c_flap"
tt.timed_attacks.list[3].dust_c = "controller_ashbite_dust"
tt.timed_attacks.list[3].heal_ptg = 0.2
tt.timed_attacks.list[3].floor_height = 38
tt.timed_attacks.list[3].wait_to_lower = fts(7)
tt.timed_attacks.list[3].lower_duration = fts(11)
tt.timed_attacks.list[3].raise_duration = fts(9)
tt.timed_attacks.list[3].raise_lower_speed = 150
tt.timed_attacks.list[3].target_min_hp = 100
tt.timed_attacks.list[3].target_max_hp = 1000
tt.timed_attacks.list[3].cooldown = 30
tt.timed_attacks.list[3].duration = 8
tt.timed_attacks.list[3].range = 120
tt.timed_attacks.list[3].cast_time = fts(18)
tt.timed_attacks.list[3].ease_down = "quad-in"
tt.timed_attacks.list[3].ease_up = "quad-in"
tt.timed_attacks.list[3].shadow_max_scale = 1.7
tt.timed_attacks.list[3].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
tt.timed_attacks.list[3].sound = "HeroAshbiteFeedingTimeFlyDown"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].animation = "ult"
tt.timed_attacks.list[4].cooldown = 35
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].damage_min = 64
tt.timed_attacks.list[4].damage_max = 96
tt.timed_attacks.list[4].min_targets = 3
tt.timed_attacks.list[4].min_range = 100
tt.timed_attacks.list[4].max_range = 300
tt.timed_attacks.list[4].node_prediction = fts(35)
tt.timed_attacks.list[4].cast_time = fts(15)
tt.timed_attacks.list[4].fireball_timings = {fts(9), fts(22), fts(22)}
tt.timed_attacks.list[4].fireball_offsets = {vec_2(-4, 56), vec_2(19, 34), vec_2(16, 55)}
tt.timed_attacks.list[4].vis_bans = bor(F_FRIEND, F_FLYING)
tt.timed_attacks.list[4].vis_flags = bor(F_AREA)
tt.timed_attacks.list[4].bullet_t = "bullet_ashbite_ultimate"
tt.timed_attacks.list[4].sound = "HeroAshbiteWildfireBarrageCast"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.track_kills.mod = "mod_ashbite_skill_c_heal_on_kill"

tt = RT("bullet_ashbite", "bolt")
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_radius = 40
tt.bullet.damage_min = 19
tt.bullet.damage_max = 29
tt.bullet.hit_fx = "fx_bullet_ashbite"
tt.bullet.particles_name = "ps_bullet_ashbite"
tt.bullet.max_speed = 600
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 600
tt.bullet.xp_gain_factor = 1.2
tt.bullet.ignore_hit_offset = false
tt.bullet.pop_chance = 0
tt.bullet.g = nil
tt.bullet.vis_flags = bor(F_AREA)
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "hero_ashbite_fx_attack_projectile"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.fireball.update
tt.sound_events.insert = nil

tt = RT("bullet_ashbite_skill_b", "bolt")
tt.bullet.damage_min = 32
tt.bullet.damage_max = 32
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_radius = 45
tt.bullet.hit_fx = "fx_ashbite_skill_b_hit"
tt.bullet.max_speed = 600
tt.bullet.ignore_hit_offset = true
tt.bullet.align_with_trajectory = true
tt.bullet.min_speed = 600
tt.bullet.pop_chance = 0
tt.bullet.g = nil
tt.bullet.particles_name = "ps_bullet_ashbite_skill_b"
tt.bullet.mod = "mod_ashbite_skill_b_stun"
tt.bullet.hit_decal = "aura_ashbite_skill_b"
tt.bullet.vis_flags = bor(F_AREA)
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "hero_ashbite_fx_sneeze_projectile"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.fireball.update
tt.sound_events.insert = nil

tt = RT("bullet_ashbite_ultimate", "bomb")
tt.bullet.damage_min = 64
tt.bullet.damage_max = 96
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 70
tt.bullet.damage_flags = bor(F_AREA)
tt.bullet.damage_bans = bor(F_FRIEND, F_FLYING)
tt.bullet.flight_time = fts(35)
tt.bullet.particles_name = "ps_bullet_ashbite_ultimate"
tt.bullet.hit_fx = "fx_ashbite_ultimate_hit"
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.pop_conds = DR_KILL
tt.bullet.pop = {"pop_kboom"}
tt.bullet.rotation_speed = 10
tt.bullet.g = -1 / (fts(1) * fts(1))
tt.bullet.damage_decay_random = false
tt.render.sprites[1].prefix = "hero_ashbite_fx_ult_projectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.bomb_kr6.insert
tt.main_script.update = scripts.bomb_kr6.update
tt.sound_events.hit = "HeroAshbiteWildfireBarrageImpact"
tt.sound_events.insert = "HeroAshbiteWildfireBarrageCast"

tt = RT("ps_bullet_ashbite", "particle_system")
AC(tt, "pos", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.name = "hero_ashbite_fx_attack_projectile_trail_run"
tt.particle_system.particle_lifetime = {fts(9), fts(9)}
tt.particle_system.emission_rate = 25
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.track_rotation = true

tt = RT("ps_bullet_ashbite_skill_b", "particle_system")
AC(tt, "pos", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.name = "hero_ashbite_fx_sneeze_projectile_trail_run"
tt.particle_system.particle_lifetime = {fts(3), fts(3)}
tt.particle_system.emission_rate = 25
tt.particle_system.emit_area_spread = vec_2(3, 3)

tt = RT("ps_bullet_ashbite_ultimate", "particle_system")
AC(tt, "pos", "particle_system")
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.name = "hero_ashbite_fx_ult_projectile_trail_run"
tt.particle_system.particle_lifetime = {fts(9), fts(9)}
tt.particle_system.emission_rate = 45
tt.particle_system.emit_area_spread = vec_2(3, 3)

tt = RT("fx_bullet_ashbite", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_attack_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = RT("fx_ashbite_skill_a", "fx")
AC(tt, "main_script")
tt.render.sprites[1].prefix = "hero_ashbite_fx_breath_fx"
tt.render.sprites[1].name = "in"
tt.animation_in = "in"
tt.animation_loop = "loop"
tt.animation_end = "out"
tt.loop_time = fts(17)
tt.main_script.update = scripts.fx_utils.in_loop_out

tt = RT("fx_ashbite_skill_a_hit", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_breath_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_ashbite_skill_b_hit", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_sneeze_hit_fx"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_ashbite_skill_c_hit", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_bite_hit_fx"
tt.render.sprites[1].name = "run"

tt = RT("fx_ashbite_skill_c_flap", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_dust_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_ashbite_ultimate_hit", "fx")
tt.render.sprites[1].prefix = "hero_ashbite_fx_ult_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("aura_ashbite_skill_a", "aura")
AC(tt, "render", "tween")
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = 0.25
tt.aura.duration = 2
tt.aura.damage_min = 4
tt.aura.damage_max = 6
tt.aura.damage_type = DAMAGE_TRUE
tt.render.sprites[1].prefix = "hero_ashbite_fx_breath_decal"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.main_script.update = aura_ashbite_skill_a_update

tt = RT("aura_ashbite_skill_b", "aura")
AC(tt, "render", "tween")
tt.aura.mod = "mod_ashbite_skill_b_burn"
tt.aura.radius = 45
tt.aura.cycle_time = 0.5
tt.aura.duration = 4
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.render.sprites[1].prefix = "hero_ashbite_fx_sneeze_hit_fx_decal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.main_script.insert = aura_ashbite_skill_b_insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.main_script.remove = scripts.tween_utils.reverse_remove

tt = RT("aura_ashbite_ultimate", "aura")
tt.aura.radius = 70
tt.aura.vis_flags = bor(F_AREA, F_ENEMY)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.damage_min = 64
tt.aura.damage_max = 96
tt.aura.damage_type = DAMAGE_TRUE
tt.main_script.update = scripts.aura_apply_damage.update

tt = RT("mod_ashbite_talent_2_skill_a_armor_red", "modifier")
tt.modifier.armor_red_factor = 0.01
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = bor(F_BOSS)
tt.main_script.insert = mod_ashbite_talent_2_armor_red_insert

tt = RT("mod_ashbite_skill_b_stun", "mod_stun")
tt.modifier.duration = 4
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt.main_script.insert = mod_ashbite_skill_b_stun_insert

tt = RT("mod_ashbite_skill_b_burn", "modifier")
AC(tt, "dps", "render", "tween")
tt.modifier.duration = 0.5
tt.modifier.resets_same = true
tt.modifier.use_mod_offset = true
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.vis_bans = 0
tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_inc = 0
tt.dps.damage_every = 0.25
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.armor_sunder = 0
tt.render.sprites[1].prefix = "hero_ashbite_fx_burn_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = mod_ashbite_burn_update
tt.main_script.remove = scripts.tween_utils.reverse_remove
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 0}, {0.75, 255}}

tt = RT("mod_ashbite_talent_1_fire", "mod_ashbite_skill_b_burn")
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].prefix = "hero_ashbite_fx_burn_fx"
tt.render.sprites[1].name = "run"
tt.modifier.duration = 4
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_inc = 0
tt.dps.damage_every = 0.25
tt.dps.damage_type = DAMAGE_TRUE

tt = RT("mod_ashbite_skill_c_heal_on_kill", "modifier")
AC(tt, "render", "heal_on_kill")
tt.main_script.insert = scripts.mod_heal_on_kill.insert
tt.main_script.update = scripts.mod_heal_on_kill.update
tt.heal_on_kill.hp = 50

tt = RT("controller_ashbite_dust")
AC(tt, "main_script")
tt.main_script.update = function(this, store, script)
	local skip_next = false

	while true do
		local hero = this.ashbite_e

		if not skip_next and hero and not hero.health.dead and (hero.render.sprites[1].frame_name == "hero_ashbiteDef_idle_0001" or hero.render.sprites[1].frame_name == "hero_ashbiteDef_feeding_attack_0001" or hero.render.sprites[1].frame_name == "hero_ashbiteDef_feeding_attack_0019") then
			skip_next = true
			hero.flap_fx_fn()
		else
			skip_next = false
		end

		coroutine.yield()
	end
end
tt.ashbite_e = nil
tt.flap_fx = "fx_ashbite_skill_c_flap"
