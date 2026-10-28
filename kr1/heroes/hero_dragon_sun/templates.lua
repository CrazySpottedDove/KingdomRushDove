local scripts = require("scripts")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local HU = require("hero_utils")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function mod_hero_dragon_sun_heal_insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	if target.health.hp == target.health.hp_max then
		return false
	end

	if target and target.unit and this.render then
		for i = 1, #this.render.sprites do
			local s = this.render.sprites[i]

			s.ts = store.tick_ts
			s.z = target.render.sprites[1].z

			if s.size_names then
				s.name = s.size_names[target.unit.size]
			end
		end
	end

	this.hps.ts = store.tick_ts - this.hps.heal_every
	this.modifier.ts = store.tick_ts

	return true
end

local function aura_bullet_hero_dragon_sun_solar_stones_mine_insert(this, store)
	this.aura.ts = store.tick_ts

	if this.render then
		for _, s in ipairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	U.animation_start(this, "loop", nil, store.tick_ts, true, 1, true)

	this.actual_duration = this.aura.duration

	return true
end

local function aura_bullet_hero_dragon_sun_solar_stones_mine_update(this, store)
	local next_check_ts = store.tick_ts
	local check_every = fts(3)
	local start_ts = store.tick_ts
	local spawn_fx = E:create_entity(this.spawn_fx)

	spawn_fx.pos:copy(this.pos)

	spawn_fx.render.sprites[1].ts = store.tick_ts
	spawn_fx.render.sprites[1].runs = 0

	simulation:queue_insert_entity(spawn_fx)
	U.y_animation_play(this, "in", nil, store.tick_ts, false, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1, true)
	U.y_wait_unconditional(store, this.time_to_activate)
	S:queue(this.sound_armed)
	U.animation_start(this, "out", nil, store.tick_ts, false, 1, true)
	U.y_wait_unconditional(store, fts(11))

	spawn_fx = E:create_entity(this.spawn_fx)

	spawn_fx.pos:copy(this.pos)

	spawn_fx.render.sprites[1].ts = store.tick_ts
	spawn_fx.render.sprites[1].runs = 0

	simulation:queue_insert_entity(spawn_fx)
	U.y_animation_wait_default(this)

	this.render.sprites[1].hidden = true
	this.render.sprites[2].hidden = false

	while true do
		if store.tick_ts - start_ts >= this.aura.duration then
			break
		end

		if next_check_ts <= store.tick_ts then
			next_check_ts = next_check_ts + check_every

			local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius * 0.75, this.aura.vis_flags, this.aura.vis_bans_trigger)

			if this.trigger or targets and #targets > 0 then
				S:queue(this.sound_explode)

				local dmg_targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans_damage)

				if dmg_targets and #dmg_targets > 0 then
					for _, enemy in ipairs(dmg_targets) do
						if enemy and not enemy.dead then
							local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.aura.radius)
							local d = E.assign_damage(this.damage_type, math.floor(this.damage_max - (this.damage_max - this.damage_min) * dist_factor), this.id, enemy.id)

							queue_damage(store, d)
						end
					end
				end

				S:queue(this.sound_explotion)

				local fx = E:create_entity(this.explosion_fx)

				fx.pos:copy(this.pos)

				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				simulation:queue_insert_entity(fx)

				local decal = E:create_entity(this.explosion_decal)

				decal.pos:copy(this.pos)

				decal.render.sprites[1].ts = store.tick_ts
				decal.render.sprites[1].runs = 0

				simulation:queue_insert_entity(decal)

				this.render.sprites[1].hidden = true
				this.render.sprites[2].hidden = true

				simulation:queue_remove_entity(this)

				return
			end
		end

		coroutine.yield()
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts
end

local function bullet_hero_dragon_sun_ultimate_update(this, store)
	local b = this.bullet
	local start_loop_sound_ts = store.tick_ts + 1.8
	local s = this.render.sprites[1]

	b.to = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	local dest = V.vclone(b.to)
	local last_damage_ts = 0
	local fx = E:create_entity(this.fx_in)

	fx.pos:copy(dest)
	simulation:queue_insert_entity(fx)

	local decal_in = E:create_entity(this.decal_in)

	decal_in.pos = V.vclone(dest)
	decal_in.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(decal_in)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1, true)

	this.render.sprites[2].hidden = false

	local shake = E:create_entity("aura_screen_shake")

	shake.aura.amplitude = 0.5
	shake.aura.duration = this.ray_duration + 0.5
	shake.aura.freq_factor = 4

	simulation:queue_insert_entity(shake)

	local shake_id = shake.id
	local time_between_decals = fts(10) * (100 / this.motion.max_speed)
	local next_decal_ts = store.tick_ts
	local time_between_fire_fxs = fts(6) * (100 / this.motion.max_speed)
	local next_fire_fxs_ts = store.tick_ts

	local function update_targetting()
		this.pos.x, this.pos.y = dest.x, dest.y

		local next = P:next_entity_node(this, store.tick_length)

		if next then
			U.set_destination(this, next)
		end

		U.walk_off__accel__unsnapped(this, store.tick_length)

		if store.tick_ts > next_decal_ts then
			next_decal_ts = store.tick_ts + time_between_decals

			local pos = V.v(dest.x + math.random(-5, 5), dest.y + math.random(-5, 5))
			local fx = E:create_entity(this.decal)

			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})

			simulation:queue_insert_entity(fx)

			fx = E:create_entity(this.decal_2)
			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})

			simulation:queue_insert_entity(fx)
		end

		if store.tick_ts > next_fire_fxs_ts then
			next_fire_fxs_ts = store.tick_ts + time_between_fire_fxs

			local fx = E:create_entity(this.fire_fx)

			fx.pos = V.v(dest.x, dest.y)
			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		dest.x, dest.y = this.pos.x, this.pos.y
	end

	local function hit_targets(targets_table, factor)
		if targets_table and #targets_table > 0 then
			local original_damage_min = b.damage_min
			local original_damage_max = b.damage_max

			b.damage_min = b.damage_min * factor
			b.damage_max = b.damage_max * factor

			for _, e in pairs(targets_table) do
				local d = SU.create_bullet_damage(b, e.id, this.id)

				queue_damage(store, d)
			end

			b.damage_min = original_damage_min
			b.damage_max = original_damage_max
		end
	end

	local function handle_hits(factor)
		hit_targets(U.find_enemies_in_range_filter_off(dest, b.damage_radius, b.damage_flags, b.damage_bans), factor)
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	local start_ts = store.tick_ts
	local reached_invalid = false

	update_targetting()

	while store.tick_ts - start_ts < this.ray_duration do
		update_targetting()

		if store.tick_ts - start_ts > this.hit_delay and store.tick_ts - last_damage_ts >= this.damage_every then
			last_damage_ts = store.tick_ts

			local progress = (store.tick_ts - start_ts) / this.ray_duration
			local factor = this.initial_damage_factor + (this.final_damage_factor - this.initial_damage_factor) * progress

			handle_hits(factor)
		end

		if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
			reached_invalid = true

			break
		end

		if start_loop_sound_ts and start_loop_sound_ts < store.tick_ts then
			start_loop_sound_ts = nil

			S:queue(this.sound_loop)
		end

		coroutine.yield()
	end

	S:stop(this.sound_loop)
	S:queue(this.sound_end)

	if reached_invalid then
		shake = store.entities[shake_id]

		if shake then
			shake.aura.duration = store.tick_ts - start_ts + 1
		end
	end

	this.tween.ts = store.tick_ts
	this.tween.disabled = false
	this.render.sprites[1].runs = 0

	while not U.animation_finished_default(this) do
		update_targetting()
		coroutine.yield()
	end

	local fx = E:create_entity(this.fire_fx)

	fx.pos = V.v(dest.x + math.random(-20, 20), dest.y + math.random(-20, 20))
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].delay_start = fts(6)

	simulation:queue_insert_entity(fx)
	U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
	simulation:queue_remove_entity(this)
end

local function hero_dragon_sun_ultimate_update(this, store)
	local function is_valid_path(pi)
		return (not store.level.ignore_walk_backwards_paths or not table.contains(store.level.ignore_walk_backwards_paths, pi)) and P:is_path_active(pi)
	end

	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, is_valid_path)
	end

	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("hero_dragon_sun_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, 0, 70, nil, F_ENEMY, nil, true, nil)
	local best_node_entry

	if targets_info and #targets_info > 0 then
		local enemy_counts = {}

		for _, target_info in ipairs(targets_info) do
			local target = target_info.enemy

			if target and target.nav_path then
				local pi = target.nav_path.pi

				enemy_counts[pi] = (enemy_counts[pi] or 0) + 1
			end
		end

		local max_enemies = -1

		for _, node_entry in ipairs(nodes) do
			local pi = node_entry[1]
			local count = enemy_counts[pi] or 0

			if max_enemies < count then
				max_enemies = count
				best_node_entry = node_entry
			end
		end
	end

	local n = best_node_entry or nodes[1]
	local b = E:create_entity(this.spawn_bullet)

	b.bullet.target_id = nil
	b.bullet.source_id = nil
	b.bullet.xp_dest_id = nil
	b.pos = V.v(REF_W / 4 * 3, REF_H + 200)

	b.bullet.from:copy(b.pos)
	b.bullet.to:copy(this.pos)

	b.nav_path.pi = n[1]
	b.nav_path.spi = 1
	b.nav_path.ni = n[3]

	simulation:queue_insert_entity(b)
	simulation:queue_remove_entity(this)
end

local function bullet_hero_dragon_sun_breath_ray_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)

	this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(P:nearest_nodes(dest.x, dest.y, target and {target.nav_path.pi} or nil, {1}, true)[1])

	local last_damage_ts = 0
	local bullet_end_pos = V.vv(0)
	local DOWNSTREAM = 1
	local nodes_to_move = math.ceil(this.motion.max_speed * this.ray_duration / P.average_node_dist * 0.8)
	local ray_is_right_to_left = store.entities[b.source_id].render.sprites[1].flip_x

	this.nav_path.dir = DOWNSTREAM

	local end_pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni + this.nav_path.dir * nodes_to_move)

	if ray_is_right_to_left and end_pos.x > b.from.x + 10 or not ray_is_right_to_left and end_pos.x < b.from.x - 10 then
		this.nav_path.dir = this.nav_path.dir * -1
	end

	local next_decal_ts = store.tick_ts
	local next_back_fire_ts = store.tick_ts
	local next_back_fire_small_ts = store.tick_ts

	local function update_targetting()
		local o_pos = V.vclone(this.pos)

		this.pos.x, this.pos.y = dest.x, dest.y

		local next = P:next_entity_node(this, store.tick_length)

		if next then
			U.set_destination(this, next)
		end

		U.walk_off__accel__unsnapped(this, store.tick_length)

		if store.tick_ts >= next_decal_ts then
			next_decal_ts = store.tick_ts + fts(6)

			local fx = E:create_entity(this.decal)

			fx.pos:copy(dest)

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})

			simulation:queue_insert_entity(fx)
		end

		if store.tick_ts >= next_back_fire_ts then
			next_back_fire_ts = store.tick_ts + fts(5)

			local fx = E:create_entity(this.fire_fx)

			fx.pos:copy(dest)

			fx.render.sprites[1].ts = store.tick_ts

			simulation:queue_insert_entity(fx)
		end

		if store.tick_ts >= next_back_fire_small_ts then
			next_back_fire_small_ts = store.tick_ts + fts(3)

			local fx = E:create_entity(this.fire_fx)

			fx.pos = V.v(dest.x + math.random(-10, 10), dest.y + math.random(-10, 10))
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].z = Z_OBJECTS
			fx.render.sprites[1].scale = V.vv(0.2 + math.random() * 0.3)

			simulation:queue_insert_entity(fx)
		end

		dest.x, dest.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = o_pos.x, o_pos.y
		bullet_end_pos.x, bullet_end_pos.y = dest.x, dest.y

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	local function hit_targets(targets_table)
		if targets_table and #targets_table > 0 then
			for _, e in ipairs(targets_table) do
				local d = SU.create_bullet_damage(b, e.id, this.id)

				queue_damage(store, d)

				for _, v in ipairs(b.mods) do
					do
						local mod = E:create_entity(v)

						mod.modifier.target_id = e.id
						mod.modifier.source_id = this.id

						simulation:queue_insert_entity(mod)
					end

					::label_sun_ray_mod_limit::
				end

				if b.hit_fx then
					local fx = E:create_entity(b.hit_fx)

					fx.pos.x, fx.pos.y = dest.x, dest.y
					fx.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(fx)
				end
			end
		end
	end

	local function handle_hits()
		local targets_ground = U.find_enemies_in_range_filter_off(dest, b.damage_radius, b.damage_flags, bor(b.damage_bans, F_FLYING))
		local diff = V.v(dest.x - this.pos.x, dest.y - this.pos.y)
		local fliers_bullet_damage_positions_center = V.v(dest.x - diff.x / 2, dest.y - diff.y / 2)
		local fliers_bullet_damage_positions = {}

		for i = 1, 3 do
			table.insert(fliers_bullet_damage_positions, V.v(dest.x - diff.x / 5 * i, dest.y - diff.y / 5 * i))
		end

		local wide_fliers_filter_search_radius = 400
		local targets_flying_filtered_search = U.find_enemies_in_range_filter_off(fliers_bullet_damage_positions_center, wide_fliers_filter_search_radius, b.damage_flags, b.damage_bans)
		local targets_flying

		if targets_flying_filtered_search and #targets_flying_filtered_search > 0 then
			targets_flying = table.filter(targets_flying_filtered_search, function(k, v)
				if not U.flag_has(v.vis.flags, F_FLYING) then
					return false
				end

				local unit_pos = V.vclone(v.pos)

				if v.unit.hit_offset then
					unit_pos.y = unit_pos.y + v.unit.hit_offset.y
				end

				for _, p in ipairs(fliers_bullet_damage_positions) do
					if U.is_inside_ellipse(unit_pos, p, b.damage_radius) then
						return true
					end
				end

				return false
			end)
		end

		hit_targets(targets_ground)
		hit_targets(targets_flying)
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	local start_ts = store.tick_ts

	update_targetting()

	while store.tick_ts - start_ts < this.ray_duration do
		update_targetting()

		if store.tick_ts - start_ts > this.hit_delay and store.tick_ts - last_damage_ts >= this.damage_every then
			last_damage_ts = store.tick_ts

			handle_hits()
		end

		coroutine.yield()
	end

	U.y_animation_wait_default(this)

	s.hidden = true

	simulation:queue_remove_entity(this)
end

local function hero_dragon_sun_level_up(this, store)
	local hl, ls = level_up_basic(this)
	local b = E:get_template(this.ranged.attacks[1].bullet)

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	local bst = E:get_template(this.ranged.attacks[1].bullet_flier)

	bst.bullet.damage_max = ls.ranged_damage_max_flier[hl]
	bst.bullet.damage_min = ls.ranged_damage_min_flier[hl]

	local basic_burn_dot = E:get_template("mod_hero_dragon_sun_bassic_attack_burn_dps")

	basic_burn_dot.dps.damage_max = ls.basic_burn_dot_damage_max[hl]
	basic_burn_dot.dps.damage_min = ls.basic_burn_dot_damage_min[hl]

	upgrade_skill(this, "worthy_foe", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[this.timed_attacks.sid_worthy_foe]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.target_damage_min = s.target_damage_min[sl]
		a.target_damage_max = s.target_damage_max[sl]
		a.area_damage_min = s.area_damage_min[sl]
		a.area_damage_max = s.area_damage_max[sl]
	end)
	upgrade_skill(this, "solar_cleansing", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[this.timed_attacks.sid_healing_aura]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]

		local aura = E:get_template(a.aura)

		aura.aura.duration = s.duration[sl]

		local mod = E:get_template(aura.aura.mods[1])

		mod.hps.heal_min = s.heal[sl]
		mod.hps.heal_max = s.heal[sl]
	end)
	upgrade_skill(this, "overcharge", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[this.timed_attacks.sid_overcharge]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]

		local bullet = E:get_template(a.bullet)

		bullet.bullet.damage_max = s.damage_max[sl]
		bullet.bullet.damage_min = s.damage_min[sl]

		local bullet_st = E:get_template(a.bullet_flier)

		bullet_st.bullet.damage_max = s.damage_max_flier[sl]
		bullet_st.bullet.damage_min = s.damage_min_flier[sl]
	end)
	upgrade_skill(this, "solar_stones", function(this, s)
		local sl = s.level
		local a = this.timed_attacks.list[this.timed_attacks.sid_solar_stones]

		a.disabled = nil
		a.cooldown = s.cooldown[sl]
		a.max_mines = s.max_mines[sl]

		local bullet = E:get_template(a.bullet)
		local mine = E:get_template(bullet.bullet.hit_payload)

		mine.damage_min = s.damage_min[sl]
		mine.damage_max = s.damage_max[sl]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		local sl = s.level

		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[sl]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[sl]

		local bullet = E:get_template(uc.spawn_bullet)

		bullet.bullet.damage_max = s.damage_max[sl]
		bullet.bullet.damage_min = s.damage_min[sl]
	end)
	update_hp(this)
end

local function hero_dragon_sun_update(this, store)
	local h = this.health
	local a
	local is_overcharged = false
	local a_healing_aura = this.timed_attacks.list[this.timed_attacks.sid_healing_aura]
	local a_overcharge = this.timed_attacks.list[this.timed_attacks.sid_overcharge]
	local a_worthy_foe = this.timed_attacks.list[this.timed_attacks.sid_worthy_foe]
	local a_solar_stones = this.timed_attacks.list[this.timed_attacks.sid_solar_stones]

	this.tween.props[1].disabled = false
	this.tween.props[1].ts = store.tick_ts
	this.health_bar.hidden = false

	U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

	local function can_overcharge()
		if a_overcharge.disabled then
			return false
		end

		if store.tick_ts - a_overcharge.ts < a_overcharge.cooldown then
			return false
		end

		if is_overcharged then
			return false
		end

		return true
	end

	local function do_overcharge()
		S:queue(a_overcharge.cast_sound)

		is_overcharged = true
		this.tween.props[2].disabled = false
		this.tween.props[2].ts = store.tick_ts
		this.tween.reverse = false

		if store.wave_group_number > 0 and a_overcharge.fx_mask then
			local fx = E:create_entity(a_overcharge.fx_mask)

			fx.pos:copy(this.pos)

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
			fx.render.sprites[1].offset.y = this.render.sprites[1].offset.y

			simulation:queue_insert_entity(fx)
		end

		return true
	end

	local function end_overcharge()
		is_overcharged = false
		this.tween.props[2].disabled = false
		this.tween.props[2].ts = store.tick_ts
		this.tween.reverse = true
	end

	local function can_ranged_attack()
		local a = this.ranged.attacks[1]

		if a.disabled then
			return false
		end

		if a.sync_animation and not this.render.sprites[1].sync_flag then
			return false
		end

		if store.tick_ts - a.ts < a.cooldown then
			return false
		end

		return true
	end

	local function do_ranged_attack()
		local a = this.ranged.attacks[1]
		local target = U.find_foremost_enemy_with_max_coverage_in_range_filter_off(this.pos, a.max_range, a.shoot_time, a.vis_flags, a.vis_bans, a.damage_radius * 2)

		if not target then
			return true
		end

		local start_ts = store.tick_ts
		local b
		local bullet_start_offset = V.vv(0)
		local flight_time = 0
		local node_offset = P:predict_enemy_node_advance(target, a.shoot_time + flight_time)
		local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
		local an, af = U.animation_name_facing_point(this, a.animation, t_pos)

		bullet_start_offset = a.bullet_start_offset[af and 2 or 1]

		local bullet_from_pos = V.v(this.pos.x + (af and -1 or 1) * bullet_start_offset.x, this.pos.y + bullet_start_offset.y)

		U.animation_start_default(this, an, af, store.tick_ts)

		while store.tick_ts - start_ts < a.shoot_time do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				return false
			end

			coroutine.yield()
		end

		local bullet_t = a.bullet
		local bullet_dest_pos = V.vclone(t_pos)

		if U.flag_has(target.vis.flags, F_FLYING) then
			if target.unit.hit_offset then
				bullet_dest_pos.x = bullet_dest_pos.x + target.unit.hit_offset.x
				bullet_dest_pos.y = bullet_dest_pos.y + target.unit.hit_offset.y
			end

			if is_overcharged then
				bullet_t = a_overcharge.bullet_flier
			else
				bullet_t = a.bullet_flier
			end
		elseif is_overcharged then
			bullet_t = a_overcharge.bullet
		end

		b = E:create_entity(bullet_t)
		b.bullet.target_id = target.id
		b.bullet.source_id = this.id
		b.bullet.xp_dest_id = this.id

		b.pos:copy(bullet_from_pos)
		b.bullet.from:copy(b.pos)
		b.bullet.to:copy(bullet_dest_pos)

		b.bullet.damage_factor = this.unit.damage_factor

		simulation:queue_insert_entity(b)

		if a.xp_from_skill then
			SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
		end

		a.ts = start_ts
		a_overcharge.ts = a_overcharge.ts + store.tick_ts - start_ts

		if is_overcharged then
			a_overcharge.ts = start_ts

			end_overcharge()
		end

		while not U.animation_finished_default(this) do
			if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
				return false
			end

			coroutine.yield()
		end

		a.ts = start_ts

		U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

		return true
	end

	local function can_heal_aura()
		if a_healing_aura.disabled then
			return false
		end

		if store.tick_ts - a_healing_aura.ts < a_healing_aura.cooldown then
			return false
		end

		local hero_hp_percentage = this.health.hp / this.health.hp_max

		if hero_hp_percentage <= a_healing_aura.hero_health_threshold then
			return true
		end

		for _, e in pairs(store.soldiers) do
			if e.hero and e.id ~= this.id then
				if not e.health.dead and U.is_inside_ellipse(e.pos, this.pos, a_healing_aura.cached_radius) and e.health.hp / e.health.hp_max <= a_healing_aura.allies_health_threshold then
					return true
				else
					break
				end
			end
		end

		if a_healing_aura.ally_count_needed > 0 then
			local allies_below_threshold = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a_healing_aura.cached_radius, 0, 0, function(e)
				return e.health.hp / e.health.hp_max <= a_healing_aura.allies_health_threshold
			end)

			if allies_below_threshold and #allies_below_threshold >= a_healing_aura.ally_count_needed then
				return true
			end
		end

		return false
	end

	local function do_heal_aura()
		S:queue(a_healing_aura.cast_sound)
		U.animation_start(this, a_healing_aura.animation, nil, store.tick_ts, false, nil)

		if SU.y_hero_wait(store, this, a_healing_aura.cast_time) then
			return false
		end

		local aura = E:create_entity(a_healing_aura.aura)

		aura.aura.source_id = this.id

		aura.pos:copy(this.pos)

		aura.aura.ts = store.tick_ts

		simulation:queue_insert_entity(aura)

		a_healing_aura.ts = store.tick_ts

		if SU.y_hero_animation_wait(this) then
			return false
		end

		return true
	end

	local function calculate_solar_stone_pos(near_mines)
		local a = a_solar_stones
		local valid_positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, TERRAIN_LAND, function(x, y)
			if x < this.pos.x + a.min_range and x > this.pos.x - a.min_range then
				return false
			end

			for _, mine in ipairs(near_mines) do
				if V.dist(mine.pos.x, mine.pos.y, x, y) <= a.min_dist_between_mines then
					return false
				end
			end

			return true
		end, nil, {1, 2, 3})

		return valid_positions[math.random(1, #valid_positions)]
	end

	local function can_solar_stones()
		if a_solar_stones.disabled then
			return false
		end

		if store.tick_ts - a_solar_stones.ts < a_solar_stones.cooldown then
			return false
		end

		if store.wave_group_number <= 0 then
			return false
		end

		local time_since_last_basic_attack = store.tick_ts - this.ranged.attacks[1].ts

		if time_since_last_basic_attack < a_solar_stones.no_targets_cooldown then
			return false
		end

		return true
	end

	local function do_solar_stones()
		a = a_solar_stones

		local bullet_template = E:get_template(a_solar_stones.bullet)
		local mine_template_name = bullet_template.bullet.hit_payload
		local near_mines = table.filter(store.entities, function(k, v)
			return v.template_name == mine_template_name and V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) <= a.max_range * a.max_range
		end)

		if #near_mines >= a_solar_stones.max_mines then
			a.ts = a.ts + fts(10)

			return true
		end

		local mine_pos = calculate_solar_stone_pos(near_mines)

		if not mine_pos then
			a.ts = a.ts + fts(10)

			return true
		end

		local all_mines = table.filter(store.entities, function(k, v)
			return v.template_name == mine_template_name
		end)

		if #all_mines >= a_solar_stones.max_mines then
			local far_mines = table.filter(all_mines, function(k, v)
				return V.dist2(v.pos.x, v.pos.y, this.pos.x, this.pos.y) > a.max_range * a.max_range
			end)

			table.sort(far_mines, function(e1, e2)
				return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) > V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
			end)

			far_mines[1].trigger = true
		end

		local start_ts = store.tick_ts
		local an, af = U.animation_name_facing_point(this, a.animation, mine_pos)

		U.animation_start(this, an, af, store.tick_ts, false, nil)

		if SU.y_hero_wait(store, this, a.cast_time) then
			return false
		end

		local b = E:create_entity(a.bullet)

		b.bullet.from = V.v(this.pos.x + a.bullet_start_offset[1].x * (af and -1 or 1), this.pos.y + a.bullet_start_offset[1].y)
		b.bullet.to = V.v(mine_pos.x, mine_pos.y)
		b.bullet.source_id = this.id

		b.pos:copy(b.bullet.from)
		simulation:queue_insert_entity(b)
		SU.y_hero_animation_wait(this)

		a.ts = start_ts

		SU.hero_gain_xp_from_skill(this, this.hero.skills.solar_stones)

		return true
	end

	local function can_worthy_foe()
		if a_worthy_foe.disabled then
			return false
		end

		if store.tick_ts - a_worthy_foe.ts < a_worthy_foe.cooldown then
			return false
		end

		-- 视野中无敌人时才释放该技能
		if U.find_first_enemy_in_range_filter_off(this.pos, this.ranged.attacks[1].max_range, this.ranged.attacks[1].vis_flags, this.ranged.attacks[1].vis_bans) then
			return false
		end

		return true
	end

	local function do_worthy_foe()
		a = a_worthy_foe

		local targets = U.find_enemies_in_range_filter_on(this.pos, a.max_range, a.vis_flags, a.vis_bans, function(e)
			if e.health.hp < a.enemy_minimum_hp then
				return false
			end

			local ni_s = P:get_visible_start_node(e.nav_path.pi)
			local ni_e = P:get_visible_end_node(e.nav_path.pi)

			return e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e - a.node_margin
		end)

		if not targets then
			a.ts = a.ts + 0.3333333333333333

			return true
		end

		table.sort(targets, function(e1, e2)
			return e1.health.hp > e2.health.hp
		end)

		local target = targets[1]

		S:queue(a_worthy_foe.cast_sound)

		local initial_pos = V.vclone(this.pos)

		this.health.ignore_damage = true
		this.health_bar.hidden = true

		local target_center_node = P:nearest_nodes(target.pos.x, target.pos.y, {target.nav_path.pi}, {1}, true)[1]
		local skill_pos = P:node_pos(target_center_node[1], target_center_node[2], target_center_node[3])
		local af = skill_pos.x < this.pos.x
		local decal_target = E:create_entity(a.decal_target)

		decal_target.pos = V.vclone(skill_pos)
		decal_target.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal_target)

		local stun_mod = E:create_entity(a.stun_mod)

		stun_mod.modifier.target_id = target.id

		simulation:queue_insert_entity(stun_mod)
		U.animation_start(this, "idle", af, store.tick_ts, true, false)
		U.y_wait_unconditional(store, 0.5)
		U.animation_start_default(this, a.animations[1], nil, store.tick_ts)
		U.y_animation_wait_default(this)

		local __offset = V.vclone(this.render.sprites[1].offset)

		this.render.sprites[1].offset.y = this.render.sprites[1].offset.y + 35
		this.render.sprites[3].offset.y = this.render.sprites[1].offset.y
		this.pos.x, this.pos.y = skill_pos.x, skill_pos.y

		U.animation_start_default(this, a.animations[2], nil, store.tick_ts)
		U.y_wait_unconditional(store, fts(4))

		this.health_bar.hidden = nil

		local d = E.assign_damage(a.target_damage_type, math.ceil(U.frandom(a.target_damage_min, a.target_damage_max)), this.id, target.id)

		queue_damage(store, d)

		local area_targets = U.find_enemies_in_range_filter_on(this.pos, a.area_damage_radius, a.vis_flags, a.vis_bans, function(e)
			return e.id ~= target.id
		end)

		if area_targets then
			for _, t in ipairs(area_targets) do
				d = E.assign_damage(a.area_damage_type, math.ceil(U.frandom(a.area_damage_min, a.area_damage_max)), this.id, t.id)

				queue_damage(store, d)
			end
		end

		local explotion_fx = E:create_entity(a.explotion_fx)

		explotion_fx.pos = V.vclone(this.pos)
		explotion_fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(explotion_fx)

		local explotion_fire = E:create_entity(a.explotion_fire)

		explotion_fire.pos = V.vclone(this.pos)
		explotion_fire.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(explotion_fire)

		local explotion_decal = E:create_entity(a.explotion_decal)

		explotion_decal.pos = V.vclone(this.pos)
		explotion_decal.render.sprites[1].ts = store.tick_ts
		explotion_decal.tween.ts = store.tick_ts

		simulation:queue_insert_entity(explotion_decal)
		U.y_animation_wait_default(this)
		-- U.y_animation_play(this, "idle", nil, store.tick_ts, 1)
		U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

		if this.nav_rally.new then
			this.nav_rally.new = false
			this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
		else
			this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
		end

		U.animation_start_default(this, a.animations[4], nil, store.tick_ts)

		this.render.sprites[1].offset.y = __offset.y
		this.render.sprites[3].offset.y = this.render.sprites[1].offset.y

		U.y_wait_unconditional(store, fts(5))

		this.health_bar.hidden = nil
		this.health.ignore_damage = nil

		U.y_animation_wait_default(this)
		SU.hero_gain_xp_from_skill(this, this.hero.skills.worthy_foe)

		a.ts = store.tick_ts

		return true
	end

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)
			U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				SU.y_hero_new_rally(store, this)
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1, this.render.sprites[1].group)
			end

			if ready_to_use_skill(this.ultimate, store, this.unit.cooldown_factor) then
				local target = U.find_foremost_enemy_in_range_filter_off(this.pos, 200, 0, F_AREA, 0)

				if target and target.pos then
					local e = E:create_entity(this.hero.skills.ultimate.controller_name)

					e.level = this.hero.skills.ultimate.level
					e.pos = V.vclone(target.pos)

					simulation:queue_insert_entity(e)

					this.ultimate.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
				else
					this.ultimate.ts = this.ultimate.ts + 1
				end
			end

			if can_ranged_attack() and not do_ranged_attack() then
			-- block empty
			elseif can_worthy_foe() and not do_worthy_foe() then
			-- block empty
			elseif can_solar_stones() and not do_solar_stones() then
			-- block empty
			elseif can_heal_aura() and not do_heal_aura() then
			-- block empty
			elseif can_overcharge() and not do_overcharge() then
			-- block empty
			else
				SU.soldier_idle(store, this)

				this.render.sprites[3].flip_x = this.render.sprites[1].flip_x

				SU.soldier_regen(store, this)
			end
		end

		coroutine.yield()
	end
end

local function mod_hero_dragon_sun_bassic_attack_burn_dps_update(this, store, script)
	local cycles = 0
	local m = this.modifier
	local dps = this.dps
	local dmin = dps.damage_min + (m.level or 0) * (dps.damage_inc or 0)
	local dmax = dps.damage_max + (m.level or 0) * (dps.damage_inc or 0)
	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	if this.render.sprites[1].size_names then
		local size_name = this.render.sprites[1].size_names[target.unit.size] or this.render.sprites[1].size_names[1]

		U.animation_start_default(this, size_name, nil, store.tick_ts, true)
	end

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
			cycles = cycles + 1
			dps.ts = dps.ts + dps.damage_every

			local damage_value = math.random(dmin, dmax)
			local d = E.assign_damage(dps.damage_type, damage_value, this.id, target.id)

			queue_damage(store, d)
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_dragon_sun_breath_flier_update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)

	local function update_sprite()
		if this.track_target and target and target.motion then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > (b.max_track_distance or 1e9) then
				target = nil
			else
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle

		local dist_offset = this.dist_offset or 0

		s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width
	end

	if not b.ignore_hit_offset and this.track_target and target and target.motion then
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	update_sprite()

	if b.hit_time and b.hit_time > fts(1) then
		while store.tick_ts - s.ts < b.hit_time do
			coroutine.yield()

			if target and U.flag_has(target.vis.bans, F_RANGED) then
				target = nil
			end

			if this.track_target then
				update_sprite()
			end
		end
	end

	if target and b.damage_type ~= DAMAGE_NONE then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if target then
		for _, mod_name in ipairs(b.mods) do
			local m = E:create_entity(mod_name)

			m.modifier.target_id = b.target_id
			m.modifier.level = this.bullet.level

			simulation:queue_insert_entity(m)
		end
	end

	if this.ray_duration then
		while store.tick_ts - s.ts < this.ray_duration do
			if this.track_target then
				update_sprite()
			end

			coroutine.yield()
		end
	else
		while not U.animation_finished_default(this) do
			coroutine.yield()
		end
	end

	simulation:queue_remove_entity(this)
end

local function bullet_hero_dragon_sun_solar_stone_insert(this, store)
	local b = this.bullet

	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)

	if b.rotation_speed then
		this.render.sprites[1].r = 0
		b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)
	end

	this.render.sprites[1].hidden = false

	return true
end

local function bullet_hero_dragon_sun_solar_stone_update(this, store)
	local b = this.bullet

	this.render.sprites[1].hidden = false

	local ps

	if this.particles_name then
		ps = E:create_entity(this.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		end
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y
		hp.source_id = b.source_id

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		simulation:queue_insert_entity(hp)
	end

	simulation:queue_remove_entity(this)
end

local function aura_hero_dragon_sun_healing_update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	local next_fx_ts = store.tick_ts

	while true do
		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				break
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and v.health.hp < v.health.hp_max and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
			end)
			local mods = this.aura.mods

			for _, target in ipairs(targets) do
				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end

			if next_fx_ts < store.tick_ts then
				next_fx_ts = store.tick_ts + 0.5

				local fx = E:create_entity(this.heal_fx)

				fx.pos.x, fx.pos.y = this.pos.x + math.random(-30, 30), this.pos.y + 50 + math.random(0, 30)
				fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = RT("ps_bullet_hero_dragon_sun_solar_stone")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_aurion_projectile_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt = RT("fx_hero_dragon_sun_solar_stones_mine_spawn", "fx")
tt.render.sprites[1].name = "hero_aurion_projectile_smoke_run"
tt.render.sprites[1].anchor = v(0.4453125, 0.5964912280701754)
tt.render.sprites[1].alpha = 128
tt = RT("fx_hero_dragon_sun_solar_stones_mine_explosion", "fx")
tt.render.sprites[1].name = "hero_aurion_explosion_skil_solar_stone__in"
tt = RT("fx_hero_dragon_sun_overcharge_mask", "fx")
tt.render.sprites[1].name = "hero_aurion_mask_overcharge_in"
tt = RT("fx_hero_dragon_sun_ultimate_in", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "hero_aurion_ulti_in_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS + 1
tt.render.sprites[1].delay_start = fts(13)
tt.render.sprites[1].hidden = true
tt = RT("fx_hero_dragon_sun_basic_ray_back_fire", "fx")
tt.render.sprites[1].name = "hero_aurion_fire_breath_hit_run"
tt.render.sprites[1].scale = vv(1)
tt = RT("fx_hero_dragon_sun_ultimate_back_fire", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "hero_aurion_fire_breath_hit_run"
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].loop = false
tt.render.sprites[1].delay_start = fts(0)
tt.render.sprites[1].hidden = true
tt = RT("fx_hero_dragon_sun_teleport_decal_target", "fx")
tt.render.sprites[1].name = "hero_aurion_decal_target_teleport_full"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_hero_dragon_sun_teleport_explotion", "fx")
tt.render.sprites[1].name = "hero_aurion_explosion_run"
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_EFFECTS + 1
tt = RT("fx_hero_dragon_sun_teleport_explotion_decal", "decal_tween")
tt.render.sprites[1].name = "hero_aurion_decal_teleport_in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vv(2)
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {3, 0}}
tt.tween.disabled = false
tt = RT("fx_hero_dragon_sun_teleport_explotion_fire", "fx")
tt.render.sprites[1].name = "hero_aurion_fire_breath_hit_run"
tt.render.sprites[1].scale = vv(2)
tt = RT("fx_hero_dragon_sun_heal_particle", "fx")
tt.render.sprites[1].name = "hero_aurion_helth_run"
tt = RT("decal_bullet_hero_dragon_sun_breath_ray", "decal_tween")
tt.tween.props[1].keys = {{0, 255}, {0.3, 255}, {1.3, 0}}
tt.render.sprites[1].name = "hero_aurion_fire_breath_decal_run"
tt = RT("decal_bullet_hero_dragon_sun_ultimate_base", "fx")
tt.render.sprites[1].name = "hero_aurion_decal_ulti_base_in"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_bullet_hero_dragon_sun_ultimate", "decal_tween")
tt.tween.props[1].keys = {{0, 155}, {2, 155}, {3.5, 0}}
tt.render.sprites[1].name = "hero_aurion_decal_ulti_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_bullet_hero_dragon_sun_ultimate_2", "decal_tween")
tt.tween.props[1].keys = {{0, 255}, {1.25, 255}, {2.25, 0}}
tt.render.sprites[1].name = "hero_aurion_decal_teleport_in"
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_DECALS + 1
tt = RT("bullet_hero_dragon_sun_breath_ray", "bullet")

AC(tt, "nav_path", "motion")

tt.render.sprites[1].z = Z_FLYING_HEROES - 1
tt.render.sprites[1].prefix = "hero_aurion_ray"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.end_fire_offset_per_angle = -0.25
tt.image_width = 137.5
tt.hit_delay = fts(4)
tt.ray_duration = fts(19)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = 8
tt.bullet.damage_min = 6
tt.bullet.damage_radius = 45
tt.bullet.xp_gain_factor = 1.4
tt.damage_every = 0.25
tt.bullet.mods = {"mod_hero_dragon_sun_bassic_attack_burn_dps"}
tt.motion.max_speed = 100
tt.bullet.damage_flags = F_AREA
tt.main_script.update = bullet_hero_dragon_sun_breath_ray_update
tt.decal = "decal_bullet_hero_dragon_sun_breath_ray"
tt.fire_fx = "fx_hero_dragon_sun_basic_ray_back_fire"
tt.sound_events.insert = "HeroDragonSunBreathAttack"
tt = RT("bullet_hero_dragon_sun_breath_ray_overcharged", "bullet_hero_dragon_sun_breath_ray")
tt.render.sprites[1].prefix = "hero_aurion_ray_2"
tt = RT("bullet_hero_dragon_sun_breath_flier", "bullet")
tt.render.sprites[1].z = Z_FLYING_HEROES - 1
tt.render.sprites[1].prefix = "hero_aurion_ray"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.image_width = 125
tt.hit_delay = fts(4)
tt.bullet.hit_time = fts(5)
tt.ray_duration = fts(19)
tt.track_target = true
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = 20
tt.bullet.damage_min = 13
tt.bullet.level = 1
tt.bullet.damage_radius = nil
tt.bullet.xp_gain_factor = 1.4
tt.bullet.mods = {"mod_hero_dragon_sun_bassic_attack_burn_only_render"}
tt.main_script.update = bullet_hero_dragon_sun_breath_flier_update
tt.sound_events.insert = "HeroDragonSunBreathAttack"
tt = RT("bullet_hero_dragon_sun_breath_flier_overcharged", "bullet_hero_dragon_sun_breath_flier")
tt.render.sprites[1].color = {255, 200, 200, 255}
tt.render.sprites[1].scale = v(1, 1.5)
tt.bullet.mod = "mod_hero_dragon_sun_bassic_attack_burn_only_render_overcharged"
tt = RT("bullet_hero_dragon_sun_ultimate", "bullet")

AC(tt, "nav_path", "motion", "tween")

tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[1].prefix = "hero_aurion_ulti"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = v(2, 3)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "hero_aurion_fire_base_ulti_run"
tt.render.sprites[2].ignore_start = true
tt.render.sprites[2].hidden = true
tt.render.sprites[2].scale = vv(2)
tt.render.sprites[2].offset = v(0, -30)
tt.render.sprites[2].sort_y_offset = -30
tt.image_width = 146.25
tt.hit_delay = fts(1)
tt.ray_duration = 3
tt.initial_damage_factor = 1.2
tt.final_damage_factor = 0.8
tt.nav_path.dir = -1
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 80
tt.damage_every = 0.1
tt.motion.max_speed = 70
tt.bullet.damage_flags = F_AREA
tt.main_script.update = bullet_hero_dragon_sun_ultimate_update
tt.fx_in = "fx_hero_dragon_sun_ultimate_in"
tt.decal_in = "decal_bullet_hero_dragon_sun_ultimate_base"
tt.decal = "decal_bullet_hero_dragon_sun_ultimate"
tt.decal_2 = "decal_bullet_hero_dragon_sun_ultimate_2"
tt.fire_fx = "fx_hero_dragon_sun_ultimate_back_fire"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {0.25, 0}}
tt.tween.props[1].sprite_id = 2
tt.sound_events.insert = "HeroDragonSunUltimateBegin"
tt.sound_loop = "HeroDragonSunUltimateLoop"
tt.sound_end = "HeroDragonSunUltimateEnd"
tt = RT("bullet_hero_dragon_sun_solar_stone", "bomb")
tt.bullet.damage_decay_random = false
tt.bullet.flight_time = fts(25)
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "aura_bullet_hero_dragon_sun_solar_stones_mine"
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.pop_chance = 0
tt.main_script.insert = bullet_hero_dragon_sun_solar_stone_insert
tt.main_script.update = bullet_hero_dragon_sun_solar_stone_update
tt.sound_events.insert = "HeroDragonSunStonesShot"
tt.sound_events.hit = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "hero_aurion_projectil_skil_solar_stone_in"
tt.particles_name = "ps_bullet_hero_dragon_sun_solar_stone"
tt = RT("aura_hero_dragon_sun_healing", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_dragon_sun_healing_update
tt.aura.duration = nil
tt.aura.vis_flags = bor(tt.aura.vis_flags, F_MOD, F_AREA)
tt.aura.vis_bans = bor(tt.aura.vis_bans, F_ENEMY)
tt.aura.mods = {"mod_hero_dragon_sun_heal", "mod_hero_dragon_sun_ban"}
tt.aura.radius = 100
tt.aura.cycle_time = 0.25 / 4
tt.aura.track_source = true
tt.heal_fx = "fx_hero_dragon_sun_heal_particle"
tt = RT("aura_bullet_hero_dragon_sun_solar_stones_mine", "aura")

AC(tt, "render", "tween")

tt.aura.radius = 50
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans_trigger = 0
tt.aura.vis_bans_damage = 0
tt.aura.cycle_time = fts(5)
tt.aura.duration = 90
tt.render.sprites[1].prefix = "hero_aurion_decal_skil_solar_stone"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].loop = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "hero_aurion_object_skil_solar_stone_activate_loop"
tt.render.sprites[2].hidden = true
tt.main_script.insert = aura_bullet_hero_dragon_sun_solar_stones_mine_insert
tt.main_script.update = aura_bullet_hero_dragon_sun_solar_stones_mine_update
tt.spawn_fx = "fx_hero_dragon_sun_solar_stones_mine_spawn"
tt.explosion_fx = "fx_hero_dragon_sun_solar_stones_mine_explosion"
tt.explosion_decal = "decal_bullet_hero_dragon_sun_breath_ray"
tt.sound_explode = "HeroMechaMineDropExplosion"
tt.damage_type = DAMAGE_TRUE
tt.time_to_activate = 3
tt.tween.props[1] = E:clone_c("tween_prop")
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.disabled = true
tt.sound_events.insert = "HeroDragonSunStonesDrop"
tt.sound_armed = "HeroDragonSunStonesArmed"
tt.sound_explotion = "HeroDragonSunStonesExplosion"
tt = RT("mod_hero_dragon_sun_bassic_attack_burn_dps", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 2
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.3
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = mod_hero_dragon_sun_bassic_attack_burn_dps_update
tt = RT("mod_hero_dragon_sun_bassic_attack_burn_only_render", "mod_hero_dragon_sun_bassic_attack_burn_dps")
tt.modifier.duration = 0.8
tt.dps.damage_min = 0
tt.dps.damage_max = 0
tt.dps.damage_type = DAMAGE_NONE
tt.dps.damage_every = 1e+99
tt.render.sprites[1].offset = v(0, -5)
tt = RT("mod_hero_dragon_sun_bassic_attack_burn_only_render_overcharged", "mod_hero_dragon_sun_bassic_attack_burn_only_render")
tt.render.sprites[1].prefix = "hero_aurion_fire_modifier_2"
tt = RT("mod_hero_dragon_sun_heal", "modifier")

AC(tt, "hps", "render")

tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = 0.25
tt.modifier.duration = 1
tt.main_script.insert = mod_hero_dragon_sun_heal_insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].name = "hero_aurion_healing_run"
tt.render.sprites[1].sort_y_offset = -3
tt = RT("mod_hero_dragon_sun_ban", "mod_ban")
tt.modifier.duration = 1
tt.modifier.ban_vis = bor(F_BLOOD, F_STUN, F_BURN, F_POISON)
tt = RT("mod_hero_dragon_stun_worthy_foe_stun", "mod_stun")
tt.modifier.duration = 1.5
tt.render.sprites[1].hidden = true
tt = RT("hero_dragon_sun_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.cooldown = {62, 62, 62, 62}
tt.main_script.update = hero_dragon_sun_ultimate_update
tt.spawn_bullet = "bullet_hero_dragon_sun_ultimate"
tt = RT("hero_dragon_sun", "hero")

AC(tt, "ranged", "timed_attacks", "tween")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {273, 292, 312, 331, 351, 370, 390, 409, 435, 461}
tt.hero.level_stats.ranged_damage_min = {6, 8, 10, 11, 13, 15, 17, 18, 20, 23}
tt.hero.level_stats.ranged_damage_max = {8, 10, 12, 14, 16, 18, 20, 22, 24, 26}
tt.hero.level_stats.ranged_damage_min_flier = {13, 18, 23, 25, 30, 35, 40, 43, 48, 55}
tt.hero.level_stats.ranged_damage_max_flier = {20, 25, 33, 40, 45, 53, 58, 65, 75, 85}
tt.hero.level_stats.basic_burn_dot_damage_max = {1, 2, 2, 3, 3, 4, 4, 5, 5, 5}
tt.hero.level_stats.basic_burn_dot_damage_min = {2, 2, 3, 3, 4, 4, 5, 5, 6, 7}
tt.hero.skills.worthy_foe = E:clone_c("hero_skill")
tt.hero.skills.worthy_foe.cooldown = {40, 36, 32}
tt.hero.skills.worthy_foe.target_damage_min = {200, 360, 400}
tt.hero.skills.worthy_foe.target_damage_max = {300, 540, 720}
tt.hero.skills.worthy_foe.area_damage_min = {20, 30, 40}
tt.hero.skills.worthy_foe.area_damage_max = {30, 40, 50}
tt.hero.skills.worthy_foe.xp_gain = {200, 400, 600}
tt.hero.skills.worthy_foe.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.solar_cleansing = E:clone_c("hero_skill")
tt.hero.skills.solar_cleansing.cooldown = {35, 35, 35}
tt.hero.skills.solar_cleansing.duration = {6, 6, 6}
tt.hero.skills.solar_cleansing.heal = {5, 10, 15}
tt.hero.skills.solar_cleansing.xp_gain = {200, 400, 600}
tt.hero.skills.solar_cleansing.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.overcharge = E:clone_c("hero_skill")
tt.hero.skills.overcharge.cooldown = {6, 6, 6}
tt.hero.skills.overcharge.damage_min = {75, 150, 225}
tt.hero.skills.overcharge.damage_max = {100, 200, 300}
tt.hero.skills.overcharge.damage_min_flier = {150, 200, 400}
tt.hero.skills.overcharge.damage_max_flier = {200, 350, 500}
tt.hero.skills.overcharge.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.solar_stones = E:clone_c("hero_skill")
tt.hero.skills.solar_stones.cooldown = {10, 10, 10}
tt.hero.skills.solar_stones.damage_min = {50, 90, 130}
tt.hero.skills.solar_stones.damage_max = {70, 120, 190}
tt.hero.skills.solar_stones.max_mines = {3, 4, 5}
tt.hero.skills.solar_stones.max_range = 105
tt.hero.skills.solar_stones.xp_gain = {200, 400, 600}
tt.hero.skills.solar_stones.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.cooldown = {62, 62, 62, 62}
tt.hero.skills.ultimate.duration = 3
tt.hero.skills.ultimate.damage_min = {6, 12, 18, 24}
tt.hero.skills.ultimate.damage_max = {10, 20, 30, 40}
tt.hero.skills.ultimate.controller_name = "hero_dragon_sun_ultimate"
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.flight_height = 80
tt.health.dead_lifetime = 15
tt.health_bar.draw_order = -1
tt.health_bar.offset = v(0, 120)
tt.health_bar.sort_y_offset = -121
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.z = Z_FLYING_HEROES
tt.hero.fn_level_up = hero_dragon_sun_level_up
tt.idle_flip.cooldown = 10
tt.info.hero_portrait = "kr5_hero_portraits_0019"
tt.info.portrait = "kr5_info_portraits_heroes_0019"
tt.main_script.update = hero_dragon_sun_update
tt.motion.max_speed = 190
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
tt.drag_line_origin_offset = v(0, tt.flight_height)
tt.regen.cooldown = 1
tt.render.sprites[1].offset.y = tt.flight_height
tt.render.sprites[1].prefix = "hero_aurion_dragon"
tt.render.sprites[1].name = "respawn"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "hero_aurion_sun_skill_overcharge"
tt.render.sprites[3].name = "respawn"
tt.render.sprites[3].offset = tt.render.sprites[1].offset
tt.render.sprites[3].z = Z_FLYING_HEROES
tt.render.sprites[3].draw_order = 2
tt.render.sprites[3].alpha = 0
tt.render.sid_shadow = 2
tt.sound_events.change_rally_point = "HeroDragonSunTaunt"
tt.sound_events.death = "HeroDragonSunDeath"
tt.sound_events.respawn = "HeroDragonSunTaunt"
tt.sound_events.hero_room_select = "HeroDragonSunTauntSelect"
tt.ui.click_rect = r(-37, tt.flight_height - 40, 90, 85)
tt.unit.hit_offset = v(0, tt.flight_height)
tt.unit.mod_offset = v(0, tt.flight_height)
tt.unit.death_animation = "death"
tt.unit.hide_after_death = true
tt.hero.tombstone_decal = nil
tt.hero.respawn_animation = "respawn"
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].animation = "radiant_wave"
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].damage_radius = 45
tt.ranged.attacks[1].shoot_time = fts(26)
tt.ranged.attacks[1].bullet = "bullet_hero_dragon_sun_breath_ray"
tt.ranged.attacks[1].bullet_start_offset = {v(33, tt.flight_height - 14), v(33, tt.flight_height - 14)}
tt.ranged.attacks[1].bullet_flier = "bullet_hero_dragon_sun_breath_flier"
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[1].basic_attack = true
tt.ranged.attacks[1].max_angle = 140
tt.ranged.attacks[1].max_angle_fliers = 140
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].disabled = true
tt.tween.props[1].ignore_reverse = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 3
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2].disabled = true
tt.timed_attacks.sid_healing_aura = 1
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura] = E:clone_c("custom_attack")
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].disabled = true
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].animation = "solar_cleansing"
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].cast_time = fts(20)
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].aura = "aura_hero_dragon_sun_healing"
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].hero_health_threshold = 0.5
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].allies_health_threshold = 0.4
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].ally_count_needed = 3
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].cached_radius = 100
tt.timed_attacks.list[tt.timed_attacks.sid_healing_aura].cast_sound = "HeroDragonSunCleansing"
tt.timed_attacks.sid_overcharge = 2
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge] = E:clone_c("custom_attack")
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge].disabled = true
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge].bullet = "bullet_hero_dragon_sun_breath_ray_overcharged"
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge].bullet_flier = "bullet_hero_dragon_sun_breath_flier_overcharged"
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge].fx_mask = "fx_hero_dragon_sun_overcharge_mask"
tt.timed_attacks.list[tt.timed_attacks.sid_overcharge].cast_sound = "HeroDragonSunOvercharge"
tt.timed_attacks.sid_worthy_foe = 3
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe] = E:clone_c("custom_attack")
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].disabled = true
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].enemy_minimum_hp = 500
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].target_damage_type = DAMAGE_TRUE
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].area_damage_type = DAMAGE_TRUE
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].area_damage_radius = 70
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].animations = {"worthy_foe_in", "worthy_foe_out", "worthy_foe_in", "worthy_foe_out_2"}
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].vis_bans = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].node_margin = 10
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].max_range = 9999
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].min_range = 0
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].decal_target = "fx_hero_dragon_sun_teleport_decal_target"
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].explotion_fx = "fx_hero_dragon_sun_teleport_explotion"
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].explotion_fire = "fx_hero_dragon_sun_teleport_explotion_fire"
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].explotion_decal = "fx_hero_dragon_sun_teleport_explotion_decal"
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].stun_mod = "mod_hero_dragon_stun_worthy_foe_stun"
tt.timed_attacks.list[tt.timed_attacks.sid_worthy_foe].cast_sound = "HeroDragonSunWorthyFoe"
tt.timed_attacks.sid_solar_stones = 4
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones] = E:clone_c("custom_attack")
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].animation = "skill_solar_stone"
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].cast_time = fts(26)
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].disabled = true
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].bullet = "bullet_hero_dragon_sun_solar_stone"
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].bullet_start_offset = {v(40, tt.flight_height + 50)}
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].min_range = 60
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].max_range = 105
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].min_dist_between_mines = 30
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].min_distance_from_border = 100
tt.timed_attacks.list[tt.timed_attacks.sid_solar_stones].no_targets_cooldown = 6
-- ultimate controller reference stored in hero skills
tt.ultimate = {
	ts = 0,
	cooldown = 62
}
