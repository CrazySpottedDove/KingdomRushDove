local bit = require("bit")
local E = require("entity_db")
local P = require("path_db")
local scripts = require("scripts")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local km = require("lib.klua.macros")
require("all.constants")
require("lib.klua.table")

local band = bit.band
local bor = bit.bor
local level_up_basic = HU.level_up_basic
local upgrade_skill = HU.upgrade_skill
local update_hp = HU.update_hp
local queue_damage = U.queue_damage
local fts = U.fts

local function osnir_find_enemies_in_paths(store, origin, min_node_range, max_node_range, max_path_dist, flags, bans, only_upstream, filter_func)
	local result = {}

	for _, n in pairs(P:nearest_nodes(origin.x, origin.y)) do
		local opi, _, oni, odist = unpack(n, 1, 4)

		if not (max_path_dist < odist) and P:is_node_valid(opi, oni) then
			for _, e in pairs(store.enemies) do
				local np = e.nav_path

				if np and np.pi == opi and e.health and not e.health.dead and not e.pending_removal and e.vis and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) == 0 and (only_upstream == true and oni > np.ni or only_upstream == false and oni < np.ni or only_upstream == nil) and min_node_range <= math.abs(np.ni - oni) and max_node_range >= math.abs(np.ni - oni) and (not filter_func or filter_func(e, origin)) then
					result[#result + 1] = {
						enemy = e,
						origin = n
					}
				end
			end
		end
	end

	if #result == 0 then
		return nil
	end

	return result
end

local function find_valid_node(pi, ni)
	for i = ni, ni + 10 do
		if P:is_node_valid(pi, i, NF_NO_BACKWARDS) then
			return i
		end
	end
end

local function osnir_skill_used_heal(this)
	local t2 = this.hero.skills.talent_2

	if not t2.disabled and not this.health.dead then
		U.heal(this, this.health.hp_max * t2.heal_ptg)
	end
end

local function osnir_level_up(this, store, initial)
	if not initial then
		S:queue(this.sound_events.level_up)
	end

	local hl, ls = level_up_basic(this)
	local b = this.walk_attack
	local sa = this.hero.skills.skill_a

	b.damage_min = sa.damage_min
	b.damage_max = sa.damage_max

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "talent_1", function(hero, skill)
		skill.disabled = nil
	end)

	upgrade_skill(this, "talent_2", function(hero, skill)
		skill.disabled = nil
	end)

	upgrade_skill(this, "skill_a", function(hero, skill)
	end)

	upgrade_skill(this, "skill_b", function(hero, skill)
		local antler = this.melee.attacks[2]

		antler.disabled = nil
		antler.damage_min = skill.damage_min[skill.level]
		antler.damage_max = skill.damage_max[skill.level]
		local m = E:get_template("mod_hero_osnir_antler_stun")
		m.modifier.duration = skill.stun_duration[skill.level]
	end)

	upgrade_skill(this, "skill_c", function(hero, skill)
	end)

	upgrade_skill(this, "ultimate", function(hero, skill)
		skill.active = true
	end)

	local bt = E:get_template(this.ranged.attacks[1].bullet)

	bt.bullet.damage_min = ls.ranged_damage_min[hl]
	bt.bullet.damage_max = ls.ranged_damage_max[hl]

	update_hp(this)
end

local function osnir_do_walk_attack(store, this)
	local b = this.walk_attack
	local sa = this.hero.skills.skill_a
	local targets = U.find_targets_in_range(store.enemies, this.pos, 0, b.radius, 0, bor(F_FRIEND, F_FLYING))

	if not targets then
		return
	end

	if this.walk_attack_xp_pending then
		this.walk_attack_xp_pending = false

		SU.hero_gain_xp_from_skill(this, sa)
	end

	S:queue(this.walk_attack_sound)

	for _, e in ipairs(targets) do
		local d = E:create_entity("damage")

		d.source_id = this.id
		d.target_id = e.id
		d.damage_type = b.damage_type
		d.value = (math.random(sa.damage_min[sa.level], sa.damage_max[sa.level]) + this.unit.damage_buff) * this.unit.damage_factor

		queue_damage(store, d)

		local fx = E:create_entity("fx_hero_osnir_hit")
		local ho = e.unit and e.unit.hit_offset

		fx.pos.x = e.pos.x + (ho and ho.x or 0)
		fx.pos.y = e.pos.y + (ho and ho.y or 0)

		local flip = math.random() < 0.5

		for i = 1, #fx.render.sprites do
			fx.render.sprites[i].ts = store.tick_ts
			fx.render.sprites[i].flip_x = flip
		end

		simulation:queue_insert_entity(fx)
	end
end

local function osnir_walk_step(store, this, walk_anim)
	local b = this.walk_attack
	local has_targets = false
	local min_flip_dx = this.motion.real_speed * store.tick_length

	if this.hero.skills.skill_a.level > 0 then
		local targets = U.find_targets_in_range(store.enemies, this.pos, 0, b.radius, F_RANGED, bor(F_FRIEND, F_FLYING))

		has_targets = targets and #targets > 0
	end

	if has_targets then
		local an, af = U.animation_name_facing_point(this, "walk_attack", this.motion.dest)

		if math.abs(this.motion.dest.x - this.pos.x) <= min_flip_dx then
			af = this.render.sprites[1].flip_x
		end

		if not this.walk_attack_active then
			this.walk_attack_active = true
			this.walk_attack_ts = store.tick_ts
			this.walk_attack_hit_done = false
			this.walk_attack_xp_pending = true
			this.walk_attack_runs = 0

			U.animation_start(this, an, af, store.tick_ts, true, nil, true)
		else
			U.animation_start(this, an, af, store.tick_ts, true)

			local runs = this.render.sprites[1].runs

			if runs ~= this.walk_attack_runs then
				this.walk_attack_runs = runs
				this.walk_attack_ts = store.tick_ts
				this.walk_attack_hit_done = false
			end
		end

		if not this.walk_attack_hit_done and store.tick_ts - this.walk_attack_ts >= b.hit_time then
			osnir_do_walk_attack(store, this)

			this.walk_attack_hit_done = true
		end
	elseif this.walk_attack_active then
		this.walk_attack_active = false

		local an, af = U.animation_name_facing_point(this, walk_anim, this.motion.dest)

		if math.abs(this.motion.dest.x - this.pos.x) <= min_flip_dx then
			af = this.render.sprites[1].flip_x
		end

		U.animation_start(this, an, af, store.tick_ts, true)
	end
end

local function osnir_new_rally(store, this)
	this.walk_attack_active = false

	local co = coroutine.create(SU.y_hero_new_rally)

	while true do
		local ok, ret = coroutine.resume(co, store, this)

		if not ok then
			error(ret)
		end

		if coroutine.status(co) == "dead" then
			return ret
		end

		osnir_walk_step(store, this, "walk")
		coroutine.yield()
	end
end

local function osnir_stampede(store, this)
	local cfg = this.stampede
	local sc = this.hero.skills.skill_c

	if sc.level == 0 then
		return false
	end

	if store.tick_ts - this.stampede_ts <= cfg.cooldown then
		return false
	end

	local info = osnir_find_enemies_in_paths(store, this.pos, cfg.range_nodes_min, cfg.range_nodes_max, cfg.max_path_dist, F_RANGED, bor(F_FLYING, F_WATER, F_CLIFF), true)

	if not info then
		return false
	end

	local groups, order = {}, {}

	for _, ti in ipairs(info) do
		local g = groups[ti.origin]

		if not g then
			g = {
				count = 0,
				origin = ti.origin,
				enemy = ti.enemy
			}
			groups[ti.origin] = g
			order[#order + 1] = g
		end

		g.count = g.count + 1
	end

	local best = order[1]

	for _, g in ipairs(order) do
		if g.count > best.count then
			best = g
		end
	end

	local origin = best.origin
	local start_ts = store.tick_ts
	local flip = best.enemy.pos.x < this.pos.x

	U.animation_start(this, "stampade", flip, store.tick_ts)
	S:queue(this.stampede_sound)

	while store.tick_ts - start_ts < cfg.spawn_time do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	this.stampede_ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, sc)
	osnir_skill_used_heal(this)

	this.ulti_ts = math.max(this.ulti_ts, store.tick_ts - 0.75 * this.ulti.cooldown)

	local base_ni = origin[3] - cfg.spawn_back_nodes

	for spi = 1, 3 do
		local ni = base_ni

		if spi == 1 then
			ni = base_ni - cfg.subpath1_lead_nodes
		end

		local vni = find_valid_node(origin[1], ni)

		if vni then
			local u = E:create_entity("hero_osnir_stampede_unit")

			u.nav_path.pi = origin[1]
			u.nav_path.spi = spi
			u.nav_path.ni = vni
			u.attack.damage = sc.damage[sc.level]
			u.shared_enemies_hit = {}

			simulation:queue_insert_entity(u)
		end
	end

	while not U.animation_finished(this) do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	this.stampede_ts = store.tick_ts

	return true
end

local function osnir_spawn_ulti_fx(store, pos, crack)
	local ray = E:create_entity("fx_hero_osnir_ulti_ray_0" .. math.random(1, 2))

	ray.pos.x, ray.pos.y = pos.x, pos.y
	ray.render.sprites[1].ts = store.tick_ts
	ray.render.sprites[1].flip_x = math.random(0, 1) == 0 and 1 or -1

	if REF_H - pos.y > ray.image_h then
		ray.render.sprites[1].scale = V.v(1, (REF_H - pos.y) / ray.image_h)
	end

	ray.tween.ts = store.tick_ts

	simulation:queue_insert_entity(ray)
	U.y_wait(store, fts(math.random(3, 5)))

	local ray2 = E:create_entity("fx_hero_osnir_ulti_ray_0" .. math.random(1, 2))

	ray2.pos.x, ray2.pos.y = pos.x, pos.y
	ray2.render.sprites[1].ts = store.tick_ts
	ray2.render.sprites[1].flip_x = math.random(0, 1) == 0 and 1 or -1

	if REF_H - pos.y > ray2.image_h then
		ray2.render.sprites[1].scale = V.v(1, (REF_H - pos.y) / ray2.image_h)
	end

	ray2.tween.ts = store.tick_ts

	simulation:queue_insert_entity(ray2)
	U.y_wait(store, fts(math.random(3, 5)))

	local ray3 = E:create_entity("fx_hero_osnir_ulti_ray_0" .. math.random(1, 2))

	ray3.pos.x, ray3.pos.y = pos.x, pos.y
	ray3.render.sprites[1].ts = store.tick_ts
	ray3.render.sprites[1].flip_x = math.random(0, 1) == 0 and 1 or -1

	if REF_H - pos.y > ray3.image_h then
		ray3.render.sprites[1].scale = V.v(1, (REF_H - pos.y) / ray3.image_h)
	end

	ray3.tween.ts = store.tick_ts

	simulation:queue_insert_entity(ray3)

	local exp = E:create_entity("fx_hero_osnir_ulti_explosion")

	exp.pos.x, exp.pos.y = pos.x, pos.y
	exp.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(exp)

	local deco = E:create_entity("fx_hero_osnir_ulti_deco")

	deco.pos.x, deco.pos.y = pos.x, pos.y
	deco.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(deco)

	if crack then
		local crack_fx = E:create_entity("fx_hero_osnir_ulti_crack")

		crack_fx.pos.x, crack_fx.pos.y = pos.x, pos.y
		crack_fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(crack_fx)
	end
end

local function osnir_ulti_summon(store, this)
	local cfg = this.ulti

	if not this.hero.skills.ultimate.active then
		return false
	end

	if store.tick_ts - this.ulti_ts <= cfg.cooldown then
		return false
	end

	local info = osnir_find_enemies_in_paths(store, this.pos, cfg.range_nodes_min, cfg.range_nodes_max, cfg.max_path_dist, F_RANGED, bor(F_FLYING, F_WATER, F_CLIFF), nil, function(e)
		return P:is_node_valid(e.nav_path.pi, e.nav_path.ni)
	end)

	if not info then
		return false
	end

	local groups, order = {}, {}

	for _, ti in ipairs(info) do
		local g = groups[ti.origin]

		if not g then
			g = {
				count = 0,
				origin = ti.origin,
				enemy = ti.enemy
			}
			groups[ti.origin] = g
			order[#order + 1] = g
		end

		g.count = g.count + 1
	end

	local best = order[1]

	for _, g in ipairs(order) do
		if g.count > best.count then
			best = g
		end
	end

	local origin = best.origin
	local spawn_pos = P:node_pos(origin[1], 1, best.enemy.nav_path.ni)
	local start_ts = store.tick_ts

	U.animation_start(this, "ulti", spawn_pos.x < this.pos.x, store.tick_ts)
	S:queue(this.ulti_sound_taunt)
	S:queue(this.ulti_sound)

	while store.tick_ts - start_ts < cfg.cast_time do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	this.ulti_ts = store.tick_ts

	SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
	osnir_skill_used_heal(this)

	this.stampede_ts = math.max(this.stampede_ts, store.tick_ts - 0.75 * this.stampede.cooldown)

	osnir_spawn_ulti_fx(store, spawn_pos, false)

	local targets = U.find_enemies_in_range(store, spawn_pos, 0, cfg.spawn_damage_radius, F_AREA, bor(F_FLYING, F_CLIFF, F_WATER))

	if targets then
		for _, e in ipairs(targets) do
			local d = E:create_entity("damage")

			d.source_id = this.id
			d.target_id = e.id
			d.value = (cfg.spawn_damage + this.unit.damage_buff) * this.unit.damage_factor
			d.damage_type = cfg.spawn_damage_type

			queue_damage(store, d)
		end
	end

	local u = E:create_entity("hero_osnir_ulti_unit")

	u.pos.x, u.pos.y = spawn_pos.x, spawn_pos.y
	u.nav_rally.center = V.vclone(spawn_pos)
	u.nav_rally.pos = V.vclone(spawn_pos)

	simulation:queue_insert_entity(u)

	while not U.animation_finished(this) do
		if this.nav_rally.new or this.health.dead or this.unit.is_stunned then
			return true
		end

		coroutine.yield()
	end

	this.ulti_ts = store.tick_ts

	return true
end

local function hero_osnir_insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.melee.order = U.attack_order(this.melee.attacks)
	this.ranged.order = U.attack_order(this.ranged.attacks)

	local antler = this.melee.attacks[2]

	antler.cooldown = U.frandom(antler.cooldown_min, antler.cooldown_max)
	this.antler_last_ts = antler.ts
	this.walk_attack_ts = -1000
	this.walk_attack_active = false
	this.walk_attack_hit_done = false
	this.walk_attack_xp_pending = false
	this.stampede_ts = -1000
	this.ulti_ts = -1000
	this.osnir_t1_active = false

	return true
end

local function hero_osnir_update(this, store)
	local h = this.health
	local brk, sta
	local old_tombstone_time = this.hero.tombstone_show_time
	local old_tombstone_respawn_animation = this.hero.tombstone_respawn_animation

	this.health_bar.hidden = false

	while true do
		if h.dead then
			if band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_INSTAKILL)) ~= 0 then
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
				if osnir_new_rally(store, this) then
					goto continue
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "lvl_up", nil, store.tick_ts, 1)
			end

			do
				local t1 = this.hero.skills.talent_1

				if not t1.disabled then
					local tgt = this.soldier.target_id and store.entities[this.soldier.target_id]
					local want = tgt and tgt.health and not tgt.health.dead and tgt.health.hp > this.health.hp

					if want and not this.osnir_t1_active then
						SU.insert_unit_damage_factor_by_factor(this, t1.damage_factor)

						this.osnir_t1_active = true
					elseif not want and this.osnir_t1_active then
						SU.remove_unit_damage_factor_by_factor(this, t1.damage_factor)

						this.osnir_t1_active = false
					end
				end
			end

			if not this.soldier.target_id and osnir_stampede(store, this) then
			elseif osnir_ulti_summon(store, this) then
			else
				local antler = this.melee.attacks[2]

				if antler.ts ~= this.antler_last_ts then
					this.antler_last_ts = antler.ts
					antler.cooldown = U.frandom(antler.cooldown_min, antler.cooldown_max)

					osnir_skill_used_heal(this)
				end

				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
				elseif SU.soldier_go_back_step(store, this) then
				else
					brk, sta = SU.y_soldier_ranged_attacks(store, this)

					if not brk then
						SU.soldier_idle(store, this)
						SU.soldier_regen(store, this)
					end
				end
			end
		end

		::continue::

		coroutine.yield()
	end
end

local function hero_osnir_projectile_insert(this, store)
	local b = this.bullet

	b.fixed_height = b.fixed_height * (1 + (math.random() * 0.8 - 0.4))
	b.rotation_speed = b.rotation_speed * (1 + (math.random() * 0.4 - 0.2))

	return scripts.arrow5_fixed_height.insert(this, store)
end

local function stampede_unit_insert(this, store)
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	if not this.pos then
		return false
	end

	return true
end

local function stampede_unit_update(this, store)
	local attack = this.attack
	local start_ts = store.tick_ts
	local fade_lead = fts(10)
	local despawn_fx

	local function spawn_fx()
		despawn_fx = E:create_entity("fx_hero_osnir_stampede_despawn")
		despawn_fx.pos.x, despawn_fx.pos.y = this.pos.x, this.pos.y + this.despawn_fx_offset_y

		for i = 1, #despawn_fx.render.sprites do
			despawn_fx.render.sprites[i].ts = store.tick_ts
		end

		simulation:queue_insert_entity(despawn_fx)
	end

	local spawning = false
	local first = P:next_entity_node(this, store.tick_length)

	if first then
		local sa, saf = U.animation_name_facing_point(this, "spawn", first)

		U.animation_start(this, sa, saf, store.tick_ts, false)

		spawning = true
	end

	while true do
		local elapsed = store.tick_ts - start_ts

		if elapsed >= this.duration then
			if not despawn_fx then
				spawn_fx()
			end

			simulation:queue_remove_entity(this)

			return
		end

		local nxt = P:next_entity_node(this, store.tick_length)

		if not nxt or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni + this.nav_path.dir, NF_NO_BACKWARDS) then
			if not despawn_fx then
				spawn_fx()
			end

			simulation:queue_remove_entity(this)

			return
		end

		U.set_destination(this, nxt)
		U.walk(this, store.tick_length)

		if elapsed >= this.duration - fade_lead then
			if not despawn_fx then
				spawn_fx()
			end

			despawn_fx.pos.x, despawn_fx.pos.y = this.pos.x, this.pos.y + this.despawn_fx_offset_y

			local k = km.clamp(0, 1, (this.duration - elapsed) / fade_lead)

			for i = 1, #this.render.sprites do
				this.render.sprites[i].alpha = math.floor(255 * k)
			end
		end

		if spawning and U.animation_finished(this) then
			spawning = false
		end

		if not spawning then
			local wa, waf = U.animation_name_facing_point(this, "walk", this.motion.dest)

			U.animation_start(this, wa, waf, store.tick_ts, true)
		end

		if store.tick_ts - attack.ts >= attack.cooldown then
			attack.ts = store.tick_ts

			local targets = U.find_enemies_in_range(store, this.pos, 0, attack.damage_radius, attack.damage_flags, attack.damage_bans, function(v)
				return not table.contains(this.shared_enemies_hit, v)
			end)

			if targets then
				for _, e in ipairs(targets) do
					if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 and math.random() < attack.mod_chance then
						local m = E:create_entity(attack.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id

						simulation:queue_insert_entity(m)
					end

					local d = E:create_entity("damage")

					d.source_id = this.id
					d.target_id = e.id
					d.value = attack.damage
					d.damage_type = attack.damage_type

					queue_damage(store, d)

					if attack.hit_fx then
						local fx = E:create_entity(attack.hit_fx)
						local ho = e.unit and e.unit.hit_offset

						fx.pos.x = e.pos.x + (ho and ho.x or 0)
						fx.pos.y = e.pos.y + (ho and ho.y or 0)

						for i = 1, #fx.render.sprites do
							fx.render.sprites[i].ts = store.tick_ts
						end

						simulation:queue_insert_entity(fx)
					end

					table.insert(this.shared_enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end
end

local function ulti_unit_insert(this, store)
	this.melee.order = U.attack_order(this.melee.attacks)

	return true
end

local function ulti_unit_area_attack(store, this)
	if store.tick_ts - this.area_ts <= this.area_cooldown then
		return false
	end

	local enemies = U.find_enemies_in_range(store, this.pos, 0, this.area_search_radius, bor(F_AREA, F_RANGED), bor(F_FLYING, F_CLIFF, F_WATER))

	if not enemies then
		return false
	end

	local best_count, best_pi, best_ni, center = 0, nil, nil, nil

	for _, e in ipairs(enemies) do
		if e.nav_path then
			local c = P:node_pos(e.nav_path.pi, 1, e.nav_path.ni)
			local count = 0

			for _, e2 in ipairs(enemies) do
				if U.is_inside_ellipse(e2.pos, c, this.area_damage_radius) then
					count = count + 1
				end
			end

			if best_count < count then
				best_count, best_pi, best_ni, center = count, e.nav_path.pi, e.nav_path.ni, c
			end
		end
	end

	if best_count < this.area_min_count then
		return false
	end

	local pi, ni = best_pi, best_ni
	local start_ts = store.tick_ts

	U.animation_start(this, "attack_area", center.x < this.pos.x, store.tick_ts)

	while store.tick_ts - start_ts < this.area_cast_time do
		if this.health.dead or this.unit.is_stunned or this.nav_rally.new then
			return true
		end

		coroutine.yield()
	end

	this.area_ts = store.tick_ts

	if this.area_attack_fx then
		local afx = E:create_entity(this.area_attack_fx)

		afx.pos.x, afx.pos.y = this.pos.x + this.area_attack_offset.x, this.pos.y + this.area_attack_offset.y

		for i = 1, #afx.render.sprites do
			afx.render.sprites[i].ts = store.tick_ts
		end

		simulation:queue_insert_entity(afx)
	end

	local off = this.area_node_offset
	local positions = {center, P:node_pos(pi, 1, ni - off), P:node_pos(pi, 1, ni + off), P:node_pos(pi, 2, ni), P:node_pos(pi, 3, ni)}

	for _, pos in ipairs(positions) do
		osnir_spawn_ulti_fx(store, pos, true)

		local targets = U.find_enemies_in_range(store, pos, 0, this.area_damage_radius, F_AREA, bor(F_CLIFF, F_WATER))

		if targets then
			for _, e in ipairs(targets) do
				if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 then
					local m = E:create_entity("mod_hero_osnir_ulti_stun")

					m.modifier.source_id = this.id
					m.modifier.target_id = e.id

					simulation:queue_insert_entity(m)
				end

				local d = E:create_entity("damage")

				d.source_id = this.id
				d.target_id = e.id
				d.value = (this.area_damage + this.unit.damage_buff) * this.unit.damage_factor
				d.damage_type = this.area_damage_type

				queue_damage(store, d)
			end
		end
	end

	while not U.animation_finished(this) do
		if this.health.dead or this.unit.is_stunned or this.nav_rally.new then
			return true
		end

		coroutine.yield()
	end

	this.area_ts = store.tick_ts

	return true
end

local function ulti_unit_update(this, store)
	local start_ts = store.tick_ts
	local brk, sta

	U.y_animation_play(this, "spawn", nil, store.tick_ts)
	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while true do
		if this.health.dead or store.tick_ts - start_ts >= this.duration then
			U.flags_remove(this.vis, F_BLOCK)

			U.unblock_target(store, this)

			this.health.hp = 0

			U.y_animation_play(this, "death", nil, store.tick_ts)
			simulation:queue_remove_entity(this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto continue
				end
			end

			if ulti_unit_area_attack(store, this) then
			else
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or sta ~= A_NO_TARGET then
				elseif SU.soldier_go_back_step(store, this) then
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
				end
			end
		end

		::continue::

		coroutine.yield()
	end
end

local function cornada_burst_update(this, store)
	local bx, by = this.pos.x, this.pos.y
	local mids = {{0, 8}, {0, -8}}

	if math.random() < 0.5 then
		mids[1], mids[2] = mids[2], mids[1]
	end

	local seq = {{-10, 0}, mids[1], mids[2], {10, 0}}

	for i = 1, #seq do
		local fx = E:create_entity("fx_hero_osnir_ulti_cornada")

		fx.pos.x = bx + seq[i][1]
		fx.pos.y = by + seq[i][2]

		for j = 1, #fx.render.sprites do
			fx.render.sprites[j].ts = store.tick_ts
		end

		simulation:queue_insert_entity(fx)
	end

	simulation:queue_remove_entity(this)
end

local tt

tt = RT("hero_osnir", "hero")
AC(tt, "melee", "ranged")
tt.walk_attack = {}
tt.walk_attack.radius = 75
tt.walk_attack.hit_time = fts(8)
tt.walk_attack.damage_type = DAMAGE_PHYSICAL
tt.stampede = {}
tt.stampede.cooldown = 30
tt.stampede.spawn_time = fts(20)
tt.stampede.range_nodes_min = 5
tt.stampede.range_nodes_max = 40
tt.stampede.max_path_dist = 60
tt.stampede.spawn_back_nodes = 5
tt.stampede.subpath1_lead_nodes = 3
tt.stampede.unit_speed = 90
tt.stampede.unit_duration = 4
tt.stampede.damage_radius = 55
tt.stampede.damage_type = DAMAGE_PHYSICAL
tt.stampede.attack_cooldown = fts(6)
tt.stampede.stun_chance = 0.4
tt.stampede.stun_duration = fts(60)
tt.ulti = {}
tt.ulti.cooldown = 45
tt.ulti.cast_time = fts(7)
tt.ulti.range_nodes_min = 0
tt.ulti.range_nodes_max = 30
tt.ulti.max_path_dist = 60
tt.ulti.spawn_damage = 60
tt.ulti.spawn_damage_radius = 80
tt.ulti.spawn_damage_type = DAMAGE_MAGICAL
tt.ulti.duration = 12
tt.ulti.slam_cooldown = 2
tt.ulti.slam_hit_time = fts(20)
tt.ulti.damage = 45
tt.ulti.damage_radius = 60
tt.ulti.damage_type = DAMAGE_PHYSICAL
tt.ulti.stun_duration = fts(45)
tt.ulti.unit_speed = 70
tt.ulti.area_cooldown = 4
tt.ulti.area_min_count = 3
tt.ulti.area_search_radius = 50
tt.ulti.area_damage = 80
tt.ulti.area_damage_type = DAMAGE_PHYSICAL
tt.ulti.area_damage_radius = 70
tt.ulti.area_node_offset = 5
tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {265, 296, 326, 357, 388, 418, 449, 479, 510, 541}
tt.hero.level_stats.melee_damage_min = {13, 14, 16, 18, 19, 21, 22, 24, 26, 27}
tt.hero.level_stats.melee_damage_max = {19, 22, 24, 26, 29, 31, 34, 36, 39, 41}
tt.hero.level_stats.ranged_damage_min = {21, 24, 27, 30, 33, 36, 39, 42, 45, 48}
tt.hero.level_stats.ranged_damage_max = {31, 34, 37, 40, 43, 46, 49, 52, 55, 58}
tt.hero.skills.skill_a = CC("hero_skill")
tt.hero.skills.skill_a.damage_min = {7, 14, 21, 28}
tt.hero.skills.skill_a.damage_max = {8, 16, 24, 32}
tt.hero.skills.skill_a.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.skill_a.xp_gain = {50, 90, 130, 170}
tt.hero.skills.skill_a.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.skill_b = CC("hero_skill")
tt.hero.skills.skill_b.damage_min = {30, 40, 50}
tt.hero.skills.skill_b.damage_max = {40, 50, 60}
tt.hero.skills.skill_b.damage_type = DAMAGE_PHYSICAL
tt.hero.skills.skill_b.stun_duration = {1, 1.5, 2}
tt.hero.skills.skill_b.xp_gain = {80, 160, 240}
tt.hero.skills.skill_b.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.skill_c = CC("hero_skill")
tt.hero.skills.skill_c.damage = {21, 30, 40}
tt.hero.skills.skill_c.xp_gain = {120, 240, 360}
tt.hero.skills.skill_c.xp_level_steps = {
	[4] = 1,
	[7] = 2,
	[10] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.active = false
tt.hero.skills.ultimate.xp_gain = {300}
tt.hero.skills.ultimate.xp_level_steps = {
	[5] = 1
}
tt.hero.skills.talent_1 = CC("hero_skill")
tt.hero.skills.talent_1.damage_factor = 1.15
tt.hero.skills.talent_1.disabled = true
tt.hero.skills.talent_1.xp_level_steps = {
	[1] = 1
}
tt.hero.skills.talent_2 = CC("hero_skill")
tt.hero.skills.talent_2.heal_ptg = 0.05
tt.hero.skills.talent_2.disabled = true
tt.hero.skills.talent_2.xp_level_steps = {
	[1] = 1
}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 80)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.hero.fn_level_up = osnir_level_up
tt.hero.respawn_animation = "revive"
tt.hero.tombstone_show_time = fts(56)
tt.hero.tombstone_decal = "decal_osnir_tombstone"
tt.hero.tombstone_concurrent_with_death = true
tt.hero.tombstone_remove_before_respawn = true
tt.unit.death_animation = "death"
tt.unit.hide_after_death = true
tt.info.i18n_key = "HERO_OSNIR"
tt.info.hero_portrait = "kr6_hero_portraits_0013"
tt.info.portrait = "kr6_info_portraits_heroes_0012"
tt.main_script.insert = hero_osnir_insert
tt.main_script.update = hero_osnir_update
tt.motion.max_speed = 120
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.walk_attack = {"walk_attack"}
tt.render.sprites[1].prefix = "hero_osnir_unitDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = "HeroOsnirTaunt"
tt.sound_events.death = "HeroOsnirTauntDeath"
tt.sound_events.respawn = "HeroOsnirTauntIntro"
tt.sound_events.hero_room_select = "HeroOsnirTauntSelect"
tt.sound_events.level_up = "HeroOsnirTauntLevelUp"
tt.ulti_sound_taunt = "HeroOsnirTauntUltimate"
tt.ulti_sound = "HeroOsnirStagGuardianCast"
tt.stampede_sound = "HeroOsnirStagpedeCast"
tt.walk_attack_sound = "HeroesOsnirHitAndRunCast"
tt.soldier.melee_slot_offset = vec_2(30, 0)
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.mod_offset = vec_2(0, 22)
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].loops = false
tt.melee.attacks[1].hit_time = fts(32)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].xp_gain_factor = 2
tt.melee.attacks[1].hit_offset = vec_2(60, 20)
tt.melee.attacks[1].hit_fx = "fx_hero_osnir_hit"
tt.melee.attacks[1].sound = "HeroOsnirBasicAttackMeleeCast"
tt.melee.attacks[1].sound_args = {
	delay = fts(29)
}
tt.melee.cooldown = 2
tt.melee.range = 60
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "antler_slam"
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].cooldown = 4
tt.melee.attacks[2].cooldown_min = 4
tt.melee.attacks[2].cooldown_max = 8
tt.melee.attacks[2].damage_radius = 60
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].damage_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2].hit_offset = vec_2(40, 0)
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].vis_bans = bor(F_CLIFF)
tt.melee.attacks[2].mod = "mod_hero_osnir_antler_stun"
tt.melee.attacks[2].xp_gain_factor = 2
tt.melee.attacks[2].xp_from_skill = "skill_b"
tt.melee.attacks[2].hit_fx = "fx_hero_osnir_ulti_cornada_burst"
tt.melee.attacks[2].sound_hit = "HeroOsnirAntlerSlamCast"
tt.melee.attacks[2].disabled = true
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "attack_range"
tt.ranged.attacks[1].bullet = "hero_osnir_projectile"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 70)}
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].min_range = 80
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].shoot_time = fts(14)
tt.ranged.attacks[1].sound_shoot = "HeroesOsnirBasicAttackRangedCast"
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[1].node_prediction = fts(12)

tt = RT("decal_osnir_tombstone", "decal")
tt.render.sprites[1].prefix = "hero_osnir_unitDef"
tt.render.sprites[1].name = "death_idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true

tt = RT("mod_hero_osnir_antler_stun", "mod_stun")
tt.modifier.duration = 1
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("mod_hero_osnir_ulti_stun", "mod_stun")
tt.modifier.duration = fts(45)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("hero_osnir_projectile", "arrow5_fixed_height")
tt.main_script.insert = hero_osnir_projectile_insert
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_osnir_projectileDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.bullet.rotation_speed = 25
tt.bullet.fixed_height = 45
tt.bullet.g = -1000
tt.bullet.xp_gain_factor = 2.4
tt.bullet.hide_radius = 0
tt.bullet.reset_to_target_pos = true
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = true
tt.bullet.hit_fx = "fx_hero_osnir_projectile_hit"
tt.bullet.damage_type = DAMAGE_PHYSICAL

tt = RT("fx_hero_osnir_projectile_hit", "fx")
tt.render.sprites[1].prefix = "hero_osnir_projectile_hitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("fx_hero_osnir_hit", "fx")
tt.render.sprites[1].prefix = "hero_osnir_hitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("fx_hero_osnir_projectile_hit_floor", "decal")
AC(tt, "main_script")
tt.render.sprites[1].prefix = "hero_osnir_projectile_floorDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_utils.animation_in_loop_out.update
tt.duration = 2
tt.animation_start = "run"

tt = RT("hero_osnir_stampede_unit", "decal_scripted")
AC(tt, "nav_path", "motion")
tt.attack = CC("area_attack")
tt.attack.cooldown = fts(6)
tt.attack.damage_radius = 55
tt.attack.damage_type = DAMAGE_PHYSICAL
tt.attack.damage_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.attack.damage_flags = F_AREA
tt.attack.mod = "mod_hero_osnir_stampede_stun"
tt.attack.mod_chance = 0.4
tt.attack.hit_fx = "fx_hero_osnir_projectile_hit"
tt.duration = 4
tt.despawn_fx_offset_y = 20
tt.motion.max_speed = 90
tt.nav_path.dir = -1
tt.main_script.insert = stampede_unit_insert
tt.main_script.update = stampede_unit_update
tt.render.sprites[1].prefix = "hero_osnir_spawn_unitDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk_side", "walk_back", "walk_front"}
tt.render.sprites[1].angles.spawn = {"spawn_side", "spawn_back", "spawn_front"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}

tt = RT("fx_hero_osnir_stampede_despawn", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_area_fireDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = RT("mod_hero_osnir_stampede_stun", "mod_stun")
tt.modifier.duration = fts(60)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("hero_osnir_ulti_unit", "soldier_militia")
AC(tt, "nav_grid", "reinforcement")
tt.idle_flip.chance = 0
tt.controable = true
tt.controable_other = true
tt.reinforcement.fade = false
tt.vis.flags = bor(F_BLOCK, F_FRIEND)
tt.vis.bans = 0
tt.health.hp_max = 999
tt.health.hp = 999
tt.health.armor = 0
tt.health_bar.offset = vec_2(0, 80)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health_bar.sort_y_offset = -90
tt.unit.hide_after_death = true
tt.regen.cooldown = 1
tt.duration = 12
tt.motion.max_speed = 70
tt.soldier.melee_slot_offset = vec_2(20, 0)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.hit_offset = vec_2(0, 25)
tt.info.random_name_format = nil
tt.info.portrait = "kr6_info_portraits_soldiers_0055"
tt.main_script.insert = ulti_unit_insert
tt.main_script.update = ulti_unit_update
tt.main_script.remove = nil
tt.melee.range = 60
tt.melee.cooldown = 2
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].animation = "antler_slam"
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 45
tt.melee.attacks[1].damage_max = 45
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].damage_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].damage_flags = F_AREA
tt.melee.attacks[1].hit_offset = vec_2(45, 0)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].mod = "mod_hero_osnir_ulti_stun"
tt.melee.attacks[1].hit_fx = "fx_hero_osnir_ulti_cornada_burst"
tt.melee.attacks[1].sound_hit = "HeroOsnirAntlerSlamCast"
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "hero_osnir_unit_ultiDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].draw_order = DO_HEROES
tt.area_cooldown = 4
tt.area_cast_time = fts(31)
tt.area_min_count = 3
tt.area_search_radius = 50
tt.area_damage = 80
tt.area_damage_type = DAMAGE_PHYSICAL
tt.area_damage_radius = 70
tt.area_node_offset = 5
tt.area_ts = -1000
tt.area_attack_fx = "fx_hero_osnir_ulti_area_attack"
tt.area_attack_offset = vec_2(15, 0)

tt = RT("fx_hero_osnir_ulti_ray_01", "decal_tween")
tt.image_h = 459
tt.render.sprites[1].prefix = "hero_osnir_ulti_spawn_rayDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.props[1].keys = {{0, 255}, {fts(3), 255}, {fts(8), 0}}

tt = RT("fx_hero_osnir_ulti_ray_02", "fx_hero_osnir_ulti_ray_01")

tt = RT("fx_hero_osnir_ulti_explosion", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_spawn_explosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_hero_osnir_ulti_deco", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_spawn_decoDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_hero_osnir_ulti_crack", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_area_crackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_hero_osnir_ulti_cornada", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_cornada_attackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5

tt = RT("fx_hero_osnir_ulti_cornada_burst", "fx")
AC(tt, "main_script")
tt.render.sprites[1].prefix = "hero_osnir_ulti_cornada_attackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.main_script.update = cornada_burst_update

tt = RT("fx_hero_osnir_ulti_area_attack", "fx")
tt.render.sprites[1].prefix = "hero_osnir_ulti_area_attackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
