local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local HU = require("hero_utils")
local bit = require("bit")
local i18n = require("i18n")
local signal = require("lib.hump.signal")
local log = require("lib.klua.log"):new("hero_scripts")
local apply_ultimate = HU.apply_ultimate
local band = bit.band
local bor = bit.bor
local find_target_at_critical_moment = HU.find_target_at_critical_moment
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local vv = V.vv
local tt

local function controller_hero_wukong_ultimate_update(this, store)
	local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

	if #nodes < 1 then
		log.error("controller_hero_wukong_ultimate: could not find valid node")
		simulation:queue_remove_entity(this)

		return
	end

	local pi, _, ni = unpack(nodes[1])

	this.pos = P:node_pos(pi, 1, ni)

	local fx = E:create_entity(this.dragon_fx)

	fx.pos:copy(this.pos)
	simulation:queue_insert_entity(fx)

	local fx_cracks = E:create_entity(this.dragon_fx_cracks)

	fx_cracks.pos = V.vclone(this.pos)
	fx_cracks.tween.ts = store.tick_ts

	simulation:queue_insert_entity(fx_cracks)

	local aura_slow = E:create_entity(this.aura_slow)

	aura_slow.aura.source_id = this.id
	aura_slow.pos = V.vclone(this.pos)

	simulation:queue_insert_entity(aura_slow)

	for i = 1, 30 do
		local explosion = E:create_entity(this.explosion_fx)

		explosion.render.sprites[1].delay_start = fts(31 + math.random(0, 25))
		explosion.pos = v(this.pos.x + math.random(-40, 40), this.pos.y + math.random(-40, 40))

		simulation:queue_insert_entity(explosion)
	end

	local start_ts = store.tick_ts

	for _, t in pairs(this.damage_times) do
		while store.tick_ts < start_ts + t do
			coroutine.yield()
		end

		local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, this.damage_flags, this.damage_bans)

		if targets then
			for _, e in ipairs(targets) do
				local d = E.assign_damage(this.damage_type, this.damage * this.damage_factor, this.id, e.id)

				queue_damage(store, d)
			end
		end
	end

	simulation:queue_remove_entity(this)
end

local function fx_hero_wukong_giant_staff_update(this, store)
	U.animation_start(this, "in", nil, store.tick_ts, false, 1, true)
	-- this.render.sprites[2].hidden = true
	U.y_wait_unconditional(store, fts(21))

	-- this.render.sprites[2].hidden = false
	-- this.tween.ts = store.tick_ts
	-- this.tween.disabled = false
	local staff_finished

	while not staff_finished do
		if U.animation_finished_default(this) then
			staff_finished = true
		-- this.render.sprites[2].hidden = true
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function aura_apply_mod_hero_wukong_ultimate_update(this, store)
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

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	U.animation_start_default(this, "in", nil, store.tick_ts)

	while true do
		if U.animation_finished_default(this) then
			U.animation_start_default(this, "loop", nil, store.tick_ts, true)
		end

		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			goto label_900_1
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			goto label_900_1
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				goto label_900_1
			end
		end

		if this.aura.requires_magic ~= false then
			local te = store.entities[this.aura.source_id]

			if not te or not te.enemy then
				goto label_900_0
			end

			if this.render then
				this.render.sprites[1].hidden = not te.enemy.can_do_magic
			end

			if not te.enemy.can_do_magic then
				goto label_900_0
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_900_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_900_0
			end
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
		-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {this.aura.mod}

				for _, mod_name in ipairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					simulation:queue_insert_entity(new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_900_0::

		coroutine.yield()
	end

	U.y_animation_play(this, "out", nil, store.tick_ts)

	::label_900_1::

	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

local function hero_wukong_choose_next_random_attack(this)
	for k, v in ipairs(this.melee.attacks) do
		v.disabled = true
	end

	local next_attack = math.random(1, #this.melee.attacks)

	if not this.melee.can_repeat_attack and this.melee.last_attack then
		while this.melee.attacks[next_attack] == this.melee.last_attack.attack do
			next_attack = math.random(1, #this.melee.attacks)
		end
	end

	this.melee.attacks[next_attack].disabled = false
end

local function hero_wukong_level_up(this, store, initial)
	local hl, ls = level_up_basic(this)

	for i = 1, 4 do
		this.melee.attacks[i].damage_min = ls.melee_damage_min[i][hl]
		this.melee.attacks[i].damage_max = ls.melee_damage_max[i][hl]
	end

	upgrade_skill(this, "hair_clones", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		for k, v in pairs(a.entity) do
			local e = E:get_template(v)

			e.health.hp_max = s.hp_max[s.level]
			e.melee.attacks[1].damage_max = s.damage_max[s.level]
			e.melee.attacks[1].damage_min = s.damage_min[s.level]
			e.reinforcement.duration = s.duration[s.level]
		end
	end)
	upgrade_skill(this, "zhu_apprentice", function(this, s)
		local e = E:get_template(s.entity)

		e.health.hp_max = s.hp_max[s.level]
		e.melee.attacks[1].damage_max = s.damage_max[s.level]
		e.melee.attacks[1].damage_min = s.damage_min[s.level]
		e.melee.attacks[2].damage_max = s.smash_damage_max[s.level]
		e.melee.attacks[2].damage_min = s.smash_damage_min[s.level]
		e.melee.attacks[2].chance = s.smash_chance[s.level]

		if this.zhu_apprentice_soldier then
			local e = this.zhu_apprentice_soldier

			e.health.hp_max = s.hp_max[s.level]
			e.health.hp = e.health.hp_max
			e.melee.attacks[1].damage_max = s.damage_max[s.level]
			e.melee.attacks[1].damage_min = s.damage_min[s.level]
			e.melee.attacks[2].damage_max = s.smash_damage_max[s.level]
			e.melee.attacks[2].damage_min = s.smash_damage_min[s.level]
			e.melee.attacks[2].chance = s.smash_chance[s.level]
		end
	end)
	upgrade_skill(this, "giant_staff", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.area_damage_max = s.area_damage_max[s.level]
		a.area_damage_min = s.area_damage_max[s.level]
	end)
	upgrade_skill(this, "pole_ranged", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.pole_amounts = s.pole_amounts[s.level]

		local pole_template = E:get_template(a.staff_template)

		pole_template.damage_min = s.damage_min[s.level]
		pole_template.damage_max = s.damage_max[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.damage = s.damage_total[s.level] / #uc.damage_times

		local u_aura = E:get_template(uc.aura_slow)

		u_aura.tween.props[1].keys = {{0, 255}, {s.slow_duration[s.level] - 0.5, 255}, {s.slow_duration[s.level], 0}}
		u_aura.aura.duration = s.slow_duration[s.level]

		local u_slow_mod = E:get_template(u_aura.aura.mod)

		u_slow_mod.slow.factor = s.slow_factor[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_wukong_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local zhu_apprentice_soldier, first_ranged_target, ranged_targets, first_ranged_target_pred_pos
	local second_idle_cd_min = 15
	local second_idle_cd_max = 30
	local next_second_idle_ts = store.tick_ts + math.random(second_idle_cd_min, second_idle_cd_max)

	hero_wukong_choose_next_random_attack(this)

	local hair_clones_attack = this.timed_attacks.list[1]
	local giant_staff_attack = this.timed_attacks.list[2]
	local pole_ranged_attack = this.timed_attacks.list[3]
	local ps_nube_trail = E:create_entity("ps_wukong_nube_trail")

	ps_nube_trail.particle_system.track_id = this.id
	ps_nube_trail.particle_system.emit = false

	simulation:queue_insert_entity(ps_nube_trail)

	this.health_bar.hidden = false

	local function rally_zhu_apprentice()
		if not zhu_apprentice_soldier then
			return
		end

		zhu_apprentice_soldier.nav_rally.new = true

		local angle = math.random() * -180
		local angle_dist_to_bottom = math.abs(90 - math.abs(angle))
		local dist_at_sides = 45
		local dist_at_bottom = 20
		local dist = dist_at_bottom + (dist_at_sides - dist_at_bottom) * (angle_dist_to_bottom / 90)
		local zhuOffsetX, zhuOffsetY = V.rotate(math.rad(angle), dist, 0)

		zhu_apprentice_soldier.nav_rally.center = V.v(this.nav_rally.pos.x + zhuOffsetX, this.nav_rally.pos.y + zhuOffsetY)
		zhu_apprentice_soldier.nav_rally.pos = V.vclone(zhu_apprentice_soldier.nav_rally.center)
		zhu_apprentice_soldier.nav_grid.waypoints = table.deepclone(this.nav_grid.waypoints)

		table.remove(zhu_apprentice_soldier.nav_grid.waypoints, #zhu_apprentice_soldier.nav_grid.waypoints)
	end

	local function create_soldier(e_template, pos)
		local e = E:create_entity(e_template)

		e.pos = V.vclone(pos)
		e.nav_rally.center = V.vclone(e.pos)
		e.nav_rally.pos = V.vclone(e.pos)

		SU.insert_unit_damage_factor_buff(e, this.unit.damage_factor - e.unit.damage_factor)
		simulation:queue_insert_entity(e)

		return e
	end

	local function camera_shake(pos)
		local MIN, MAX = 1, 2
		local values_amplitude = {0.2, 1.5}
		local values_duration = {0.7, 1.3}
		local values_freq = {2.5, 4}
		-- local shake_falloff_dist = 450
		-- local camera_posX = game.camera.x / game.game_scale
		-- local camera_posY = game.ref_h - game.camera.y / game.game_scale
		-- local camera_dist = V.dist(camera_posX, camera_posY, pos.x, pos.y)
		-- local zoom_value = game.camera.zoom - game.camera.min_zoom_clamp
		-- local falloff_value = 1 - camera_dist / shake_falloff_dist
		-- if falloff_value < 0 then
		--     falloff_value = 0
		-- end
		local shake_value = 0.2
		local amplitude = values_amplitude[MIN] + (values_amplitude[MAX] - values_amplitude[MIN]) * shake_value
		local duration = values_duration[MIN] + (values_duration[MAX] - values_duration[MIN]) * shake_value
		local freq = values_freq[MIN] + (values_freq[MAX] - values_freq[MIN]) * shake_value
		local shake = E:create_entity("aura_screen_shake")

		shake.aura.amplitude = amplitude
		shake.aura.duration = duration
		shake.aura.freq_factor = freq

		simulation:queue_insert_entity(shake)
	end

	if this.hero.skills.zhu_apprentice.level > 0 then
		zhu_apprentice_soldier = create_soldier(this.hero.skills.zhu_apprentice.entity, V.v(this.pos.x - 25, this.pos.y - 10))
		this.zhu_apprentice_soldier = zhu_apprentice_soldier
	end

	local function y_wukong_wait_for_second_idle(store, this, time)
		return U.y_wait_conditional(store, time, function(store, time)
			if SU.soldier_pick_melee_target(store, this) then
				return true
			end

			SU.soldier_regen(store, this)

			return SU.soldier_interrupted(this)
		end)
	end

	local function y_wukong_wait_animation_for_second_idle(this)
		while not U.animation_finished_default(this) do
			if SU.soldier_pick_melee_target(store, this) then
				return true
			end

			SU.soldier_regen(store, this)

			if SU.soldier_interrupted(this) then
				return true
			end

			coroutine.yield()
		end

		return false
	end

	while true do
		if h.dead then
			if (not this.selfdestruct or this.selfdestruct.disabled or band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE_BOSS)) ~= 0) and band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE_BOSS)) == 0 and band(h.last_damage_types, bor(DAMAGE_EAT)) == 0 and band(h.last_damage_types, bor(DAMAGE_HOST)) == 0 then
				S:queue(this.sound_death_sfx)
			end

			SU.y_hero_death_and_respawn(store, this)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				local r = this.nav_rally
				local tw = this.flywalk
				local force_flywalk = false

				for _, p in pairs(this.nav_grid.waypoints) do
					if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
						force_flywalk = true

						break
					end
				end

				if force_flywalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance then
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					U.speed_mul_self(this, tw.extra_speed_mult)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true
					this.on_flywalk = true
					ps_nube_trail.particle_system.emit = true
					this.ui.click_rect = this.ui.click_rect_fly

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.flywalk.sound)

					local an, af = U.animation_name_facing_point(this, tw.animations[1], r.pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					::label_882_0::

					local dest = r.pos
					local n = this.nav_grid

					rally_zhu_apprentice()

					local on_landing_anim = false

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local runs = this.render.sprites[1].runs

						while not this.motion.arrived do
							if r.new then
								if on_landing_anim then
									on_landing_anim = false
									ps_nube_trail.particle_system.emit = true
								end

								r.new = false

								goto label_882_0
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)

							local vx, vy = V.sub(this.motion.dest.x, this.motion.dest.y, this.pos.x, this.pos.y)
							local path_len = V.len(vx, vy)
							local prev_point = V.vclone(this.motion.dest)

							for i = 1, #this.nav_grid.waypoints do
								local w_pos = this.nav_grid.waypoints[i]

								vx, vy = V.sub(w_pos.x, w_pos.y, prev_point.x, prev_point.y)
								path_len = path_len + V.len(vx, vy)
								prev_point = V.vclone(w_pos)
							end

							local time_to_leave_cloud = fts(10)

							if path_len < this.motion.real_speed * time_to_leave_cloud and not on_landing_anim then
								on_landing_anim = true
								ps_nube_trail.particle_system.emit = false

								local an, af = U.animation_name_facing_point(this, tw.animations[3], this.motion.dest)

								U.animation_start(this, an, af, store.tick_ts, false, 1, true)
							end

							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							if this.render.sprites[1].runs ~= runs and not on_landing_anim then
								local an, af = U.animation_name_facing_point(this, tw.animations[2], this.motion.dest)

								U.animation_start(this, an, af, store.tick_ts, true, 1, true)

								runs = this.render.sprites[1].runs
							end
						end
					end

					U.y_animation_wait_default(this)

					this.ui.click_rect = this.ui.click_rect_nofly

					U.speed_div_self(this, tw.extra_speed_mult)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
					this.on_flywalk = false
				else
					rally_zhu_apprentice()

					if SU.y_hero_new_rally(store, this) then
						goto label_882_1
					end
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
			end

			a = this.ultimate

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local target = find_target_at_critical_moment(this, hair_clones_attack.max_range, F_RANGED, F_NONE, nil, false, false)

				if target and U.has_valid_rally_node_nearby(target.pos) then
					apply_ultimate(this, store, target.pos, "levelup")
					U.heal(this, h.hp_max)

					if this.health.dead then
						this.health.dead = false
					end
				else
					a.ts = a.ts + 1
				end
			end

			skill = this.hero.skills.hair_clones
			a = hair_clones_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				local _, enemies, pred_pos = U.find_foremost_enemy_in_range_filter_on(this.pos, a.max_range, a.cast_time, a.vis_flags, a.vis_bans, function(e, origin)
					local node_offset = P:predict_enemy_node_advance(e, a.cast_time)
					local e_ni = e.nav_path.ni + node_offset + 8
					local n_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)

					return band(GR:cell_type(n_pos.x, n_pos.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) == 0
				end)

				if not enemies or #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					this.health.immune_to = F_ALL

					local target_nodes = {}

					for i = 1, math.min(#enemies, 2) do
						local e = enemies[i]
						local node_offset = P:predict_enemy_node_advance(e, a.cast_time)
						local e_ni = e.nav_path.ni + node_offset + 8

						table.insert(target_nodes, {
							pi = e.nav_path.pi,
							spi = e.nav_path.spi,
							ni = e_ni
						})
					end

					local start_ts = store.tick_ts

					S:queue(a.sound, a.sound_args)

					local an, af, _ = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)

					if SU.y_soldier_wait(store, this, a.cast_time) then
						this.health.immune_to = 0

						goto label_882_1
					end

					enemies, pred_pos = U.find_foremost_enemy_in_range_filter_on(this.pos, a.max_range, a.cast_time, a.vis_flags, a.vis_bans, function(e, origin)
						local e_ni = e.nav_path.ni + 8
						local n_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)

						return band(GR:cell_type(n_pos.x, n_pos.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) == 0
					end)

					if enemies and #enemies > 0 then
						target_nodes = {}

						for i = 1, math.min(#enemies, 2) do
							local e = enemies[i]
							local e_ni = e.nav_path.ni + 8

							table.insert(target_nodes, {
								pi = e.nav_path.pi,
								spi = e.nav_path.spi,
								ni = e_ni
							})
						end
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local positions = {}

					if #target_nodes == 1 then
						local npos = P:node_pos(target_nodes[1].pi, target_nodes[1].spi, target_nodes[1].ni)

						positions = {{
							x = npos.x + 27,
							y = npos.y
						}, {
							x = npos.x + 27,
							y = npos.y
						}}
					else
						for _, n in ipairs(target_nodes) do
							table.insert(positions, P:node_pos(n.pi, n.spi, n.ni))
						end
					end

					for i = 1, 2 do
						local fx = E:create_entity(a.fx)

						fx.pos.x, fx.pos.y = positions[i].x, positions[i].y
						fx.render.sprites[1].ts = store.tick_ts

						simulation:queue_insert_entity(fx)
					end

					U.y_wait_unconditional(store, fts(4))

					for i = 1, 2 do
						create_soldier(a.entity[i], positions[i])
					end

					SU.y_hero_animation_wait(this)
					U.animation_start_default(this, "idle", nil, store.tick_ts, true)

					this.health.immune_to = 0

					goto label_882_1
				end
			end

			skill = this.hero.skills.giant_staff
			a = giant_staff_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				if this.soldier.target_id == nil then
					a.ts = a.ts + fts(5)
				elseif not this.motion.arrived then
					a.ts = a.ts + fts(5)
				else
					local target = store.entities[this.soldier.target_id]

					if not target then
						a.ts = a.ts + fts(5)
					else
						local is_boss = U.flag_has(target.vis.flags, F_BOSS)

						if is_boss then
							a.ts = a.ts + fts(5)
						else
							local not_instakill = U.flag_has(target.vis.bans, bor(F_INSTAKILL))

							if not_instakill then
								a.ts = a.ts + fts(5)
							elseif target.health.dead then
								a.ts = a.ts + fts(5)
							else
								local start_ts = store.tick_ts

								S:queue(a.sound, a.sound_args)

								local pos_target

								if this.soldier.target_id then
									target = store.entities[this.soldier.target_id]

									if target then
										pos_target = target.pos

										local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

										if #nodes >= 1 then
											local pi, _, ni = unpack(nodes[1])

											pos_target = P:node_pos(pi, 1, ni)
										end
									end
								end

								this.health.immune_to = F_ALL

								local an, af, _ = U.animation_name_facing_point(this, a.animation, target.pos)

								U.animation_start_default(this, an, af, store.tick_ts, false)
								U.y_wait_unconditional(store, a.staff_appear_time)

								this.health_bar.hidden = true

								local staff_offset_x = a.staff_offset.x * (this.render.sprites[1].flip_x and -1 or 1)
								local staff_fx = E:create_entity(a.staff_template)

								staff_fx.pos.x, staff_fx.pos.y = pos_target.x, pos_target.y - 1
								staff_fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(staff_fx)
								U.y_wait_unconditional(store, fts(6))

								this.pos.x = pos_target.x - staff_offset_x
								this.pos.y = pos_target.y - 1

								U.y_wait_unconditional(store, a.hit_time - a.staff_appear_time)

								if this.soldier.target_id then
									target = store.entities[this.soldier.target_id]

									if target then
										local d = E.assign_damage(a.damage_type, 1, this.id, target.id)

										queue_damage(store, d)
									end
								end

								local enemies = U.find_enemies_in_range_filter_off(this.pos, a.area_damage_radius, a.area_vis_flags, a.area_vis_bans)

								if enemies and #enemies > 0 then
									for _, e in ipairs(enemies) do
										local d = E.assign_damage(a.area_damage_type, math.random(a.area_damage_min, a.area_damage_max) * this.unit.damage_factor, this.id, e.id)

										d.track_kills = this.track_kills ~= nil
										d.track_damage = a.track_damage
										d.pop = a.pop
										d.pop_chance = a.pop_chance
										d.pop_conds = a.pop_conds

										queue_damage(store, d)
									end
								end

								local back_dust_fx = E:create_entity(a.staff_dust_template_back)

								back_dust_fx.pos.x, back_dust_fx.pos.y = this.pos.x + staff_offset_x, this.pos.y
								back_dust_fx.render.sprites[1].ts = store.tick_ts

								simulation:queue_insert_entity(back_dust_fx)

								local front_dust_fx = E:create_entity(a.staff_dust_template_front)

								front_dust_fx.pos.x, front_dust_fx.pos.y = this.pos.x + staff_offset_x, this.pos.y
								front_dust_fx.render.sprites[1].ts = store.tick_ts
								front_dust_fx.render.sprites[2].ts = store.tick_ts

								simulation:queue_insert_entity(front_dust_fx)
								camera_shake(staff_fx.pos)

								a.ts = start_ts

								SU.hero_gain_xp_from_skill(this, skill)
								SU.y_hero_animation_wait(this)
								U.animation_start_default(this, "idle", nil, store.tick_ts, true)

								this.health_bar.hidden = false
								this.health.immune_to = 0

								goto label_882_1
							end
						end
					end
				end
			end

			skill = this.hero.skills.pole_ranged
			a = pole_ranged_attack

			if ready_to_use_skill(a, store, this.unit.cooldown_factor) then
				first_ranged_target, ranged_targets, first_ranged_target_pred_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.shoot_time + fts(4), a.vis_flags, a.vis_bans)

				if ranged_targets and #ranged_targets >= a.min_targets then
					local an, af, _ = U.animation_name_facing_point(this, a.animation, first_ranged_target.pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)
					S:queue(a.sound, a.sound_args)

					this.health.immune_to = F_ALL

					if SU.y_soldier_wait(store, this, a.shoot_time) then
						this.health.immune_to = 0

						goto label_882_1
					end

					local old_first_ranged_target_pred_pos = first_ranged_target_pred_pos

					first_ranged_target, ranged_targets, first_ranged_target_pred_pos = U.find_foremost_enemy_between_range_filter_off(this.pos, a.min_range, a.max_range, a.shoot_time + fts(4), a.vis_flags, a.vis_bans)

					local function create_bullet_decal(pos, delay)
						local b = E:create_entity(a.staff_template)

						b.damage_factor = this.unit.damage_factor
						b.pos = V.v(pos.x + math.random(-20, 20), pos.y + math.random(-20, 20))
						b.delay_start = delay

						simulation:queue_insert_entity(b)
					end

					local curr_delay = 0

					if ranged_targets and #ranged_targets > 0 then
						local targets_with_amount = {}

						for i, t in ipairs(ranged_targets) do
							targets_with_amount[i] = {
								amount = 0,
								target = t
							}
						end

						local pole_n = 1

						while pole_n < a.pole_amounts do
							for i, t in ipairs(targets_with_amount) do
								t.amount = t.amount + 1
								pole_n = pole_n + 1

								if pole_n > a.pole_amounts then
									break
								end
							end

							pole_n = pole_n + 1
						end

						for i, t in ipairs(targets_with_amount) do
							if t.amount == 0 then
								break
							end

							for j = 1, t.amount do
								create_bullet_decal(t.target.pos, curr_delay)

								curr_delay = curr_delay + 0.1
							end
						end
					else
						for i = 1, a.pole_amounts do
							create_bullet_decal(old_first_ranged_target_pred_pos, curr_delay)

							curr_delay = curr_delay + 0.1
						end
					end

					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)
					SU.y_hero_animation_wait(this)

					this.health.immune_to = 0

					U.animation_start_default(this, "idle", nil, store.tick_ts, true)

					goto label_882_1
				end
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				hero_wukong_choose_next_random_attack(this)
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)

				if next_second_idle_ts < store.tick_ts then
					next_second_idle_ts = store.tick_ts + math.random(second_idle_cd_min, second_idle_cd_max) + 4

					U.animation_start_default(this, "in_idle_2", nil, store.tick_ts, false)

					if y_wukong_wait_animation_for_second_idle(this) then
					-- block empty
					else
						U.animation_start_default(this, "idle_2", nil, store.tick_ts, true)

						if y_wukong_wait_for_second_idle(store, this, 4) then
						-- block empty
						else
							U.animation_start_default(this, "out_idle_2", nil, store.tick_ts, false)

							if y_wukong_wait_animation_for_second_idle(this) then
							-- block empty
							else
								U.animation_start_default(this, "idle", nil, store.tick_ts, true)
							end
						end
					end
				end
			end
		end

		::label_882_1::

		coroutine.yield()
	end
end

local function decal_zhu_apprentice_area_attack_update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1)

	this.render.sprites[1].hidden = true
end

local function decal_hero_wukong_ranged_attack_staff_update(this, store)
	U.y_wait_unconditional(store, this.delay_start)

	this.render.sprites[1].hidden = false
	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	U.animation_start(this, "projectile", nil, store.tick_ts, false, 1)
	U.y_wait_unconditional(store, fts(5))

	local targets = U.find_enemies_in_range_filter_off(this.pos, this.damage_radius, this.damage_flags, this.damage_bans)

	if targets then
		for _, e in ipairs(targets) do
			local d = E.assign_damage(this.damage_type, math.random(this.damage_min, this.damage_max) * this.damage_factor, this.id, e.id)

			queue_damage(store, d)

			local m = E:create_entity(this.mod_stun)

			m.modifier.source_id = this.id
			m.modifier.target_id = e.id

			simulation:queue_insert_entity(m)
		end
	end

	local decal = E:create_entity(this.decal)

	decal.pos:copy(this.pos)

	decal.render.sprites[1].ts = store.tick_ts
	decal.tween.ts = store.tick_ts

	simulation:queue_insert_entity(decal)
end

local function mod_hero_wukong_attacks_combos_insert(this, store)
	local source = store.entities[this.modifier.source_id]

	if not source then
		return false
	end

	hero_wukong_choose_next_random_attack(source)

	return false
end

tt = RT("ps_wukong_nube_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_wukong_trail_nube_run"
tt.particle_system.animated = true
tt.particle_system.emit_offset = v(0, 10)
tt.particle_system.emission_rate = 12
tt.particle_system.animation_fps = 15
tt.particle_system.track_rotation = false
tt.particle_system.particle_lifetime = {fts(19), fts(19)}
tt.particle_system.z = Z_OBJECTS
tt = RT("fx_hero_wukong_clones_spawn", "fx")
tt.render.sprites[1].name = "hero_wukong_smoke_in"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_hero_wukong_giant_staff", "decal_scripted")
-- AC(tt, "tween")
tt.main_script.update = fx_hero_wukong_giant_staff_update
tt.render.sprites[1].prefix = "hero_wukong_weapon"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].scale = vv(2)
tt = RT("fx_zhu_apprentice_respawn", "fx")
tt.render.sprites[1].name = "hero_wukong_woolong_spawn_FX_spawn"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt = RT("fx_hero_wukong_giant_staff_dust_cloud_back", "fx")
tt.render.sprites[1].name = "hero_wukong_back_dust_in"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 10
tt.render.sprites[1].scale = vv(3)
tt = RT("fx_hero_wukong_giant_staff_dust_cloud_front", "fx")
tt.render.sprites[1].name = "hero_wukong_smoke_in"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[1].scale = vv(3)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "hero_wukong_dust_up_in"
tt.render.sprites[2].sort_y_offset = -35
tt = RT("fx_hero_wukong_hit_2", "fx")
tt.render.sprites[1].name = "hero_wukong_hit_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -35
tt = RT("fx_hero_wukong_hit", "fx")
tt.render.sprites[1].name = "hero_wukong_hit_wukong_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -35
tt = RT("decal_zhu_apprentice_area_attack", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = decal_zhu_apprentice_area_attack_update
tt.render.sprites[1].prefix = "hero_wukong_dust_up"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].loop = false
tt.render.sprites[1].sort_y_offset = -35
tt.render.sprites[1].scale = vv(1.5)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = nil
tt.render.sprites[2].name = "hero_wukong_woolong_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].scale = vv(0.7)
tt.render.sprites[2].sort_y_offset = 0
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {1.5, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.disabled = false
tt = RT("decal_hero_wukong_ranged_attack_staff", "decal_scripted")

AC(tt, "tween")

tt.damage_factor = 1
tt.main_script.update = decal_hero_wukong_ranged_attack_staff_update
tt.render.sprites[1].prefix = "hero_wukong_attack_range"
tt.render.sprites[1].name = "projectile"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.decal = "decal_hero_wukong_ranged_attack_staff_decal"
tt.mod_stun = "mod_hero_wukong_ranged_pole_stun"
tt.damage_radius = 50
tt.damage_flags = bor(F_AREA)
tt.damage_bans = F_NONE
tt.damage_type = DAMAGE_PHYSICAL
tt.tween.props[1].keys = {{fts(0), 255}, {fts(56), 255}, {fts(62), 0}}
tt.tween.disabled = true
tt = RT("decal_hero_wukong_ranged_attack_staff_decal", "decal_tween")
tt.render.sprites[1].name = "hero_wukong_weapon_decal_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{fts(0), 255}, {fts(45), 255}, {fts(52), 0}}
tt.tween.disabled = false
tt = RT("soldier_hero_wukong_clone", "soldier_militia")

AC(tt, "reinforcement")

tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 45)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0033"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].hit_fx = "fx_hero_wukong_hit_2"
tt.melee.attacks[1].hit_offset = v(25, 20)
tt.melee.range = 72
tt.motion.max_speed = 60
tt.regen.health = 0
tt.reinforcement.duration = nil
tt.render.sprites[1].prefix = "hero_wukong_clone_1"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.soldier.melee_slot_offset = v(10, 0)
tt.reinforcement.fade = nil
tt.unit.head_offset = v(0, 14)
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 14)
tt = RT("soldier_hero_wukong_clone_b", "soldier_hero_wukong_clone")
tt.info.portrait = "kr5_info_portraits_soldiers_0034"
tt.render.sprites[1].prefix = "hero_wukong_clone_2"
tt = RT("soldier_hero_wukong_zhu_apprentice", "soldier_militia")

AC(tt, "nav_grid")

tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0032"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_wukong_woolong"
tt.unit.hit_offset = v(0, 16)
tt.health_bar.offset = v(0, 28)
tt.main_script.insert = scripts.soldier_hero_wukong_zhu_apprentice.insert
tt.main_script.update = scripts.soldier_hero_wukong_zhu_apprentice.update
tt.idle_flip.last_animation = "idle"
tt.melee.range = 150
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {4, 7, 15}
tt.melee.attacks[1].damage_min = {3, 5, 10}
tt.melee.attacks[1].hit_time = fts(2)
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = 5
tt.melee.attacks[2].damage_radius = 72
tt.melee.attacks[2].damage_max = {45, 91, 117}
tt.melee.attacks[2].damage_min = {39, 71, 97}
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].hit_decal = "decal_zhu_apprentice_area_attack"
tt.melee.attacks[2].hit_offset = v(15, 0)
tt.melee.attacks[2].hit_time = fts(59)
tt.melee.attacks[2].animation = "attack_area"
tt.melee.attacks[2].sound = "HeroWukongZhuSmash"
tt.melee.attacks[2].sound_args = {
	delay = fts(33)
}
tt.respawn_fx = "fx_zhu_apprentice_respawn"
tt.respawn_fx_timing = fts(9)
tt.ui.click_rect = r(-12, -5, 24, 30)
tt.health.dead_lifetime = 9
tt.health.ignore_delete_after = true
tt.motion.max_speed = 100
tt.soldier.melee_slot_offset = v(12, 0)
tt = RT("fx_hero_wukong_ultimate", "decal_scripted")

AC(tt, "sound_events")

tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "hero_wukong_dragon_ultimate_dragon"
tt.render.sprites[1].scale = vv(1)
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "HeroWukongUltimate"
tt = RT("fx_hero_wukong_ultimate_cracks", "decal_tween")
tt.render.sprites[1].name = "hero_wukong_dragon_ultimate_cracks_floor"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = 20
tt.render.sprites[1].scale = vv(1)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset = v(0, 10)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].offset = v(-10, -10)
tt.tween.props[1].keys = {{fts(31), 0}, {fts(35), 255}, {2.5, 255}, {3, 0}, {4, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{fts(31) + fts(7), 0}, {fts(35) + fts(7), 255}, {2.5 + fts(7), 255}, {3 + fts(7), 0}, {4, 0}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[3].keys = {{fts(31) + fts(14), 0}, {fts(35) + fts(14), 255}, {2.5 + fts(14), 255}, {3 + fts(14), 0}, {4, 0}}
tt = RT("fx_hero_wukong_ultimate_explosion", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "hero_wukong_dragon_ultimate_fire_explosion"
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].hidden = true
tt = RT("hero_wukong", "hero")

AC(tt, "melee", "timed_attacks")

tt.hero.level_stats.armor = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1}
tt.hero.level_stats.hp_max = {260, 286, 312, 338, 354, 390, 416, 442, 468, 494}
tt.hero.level_stats.melee_damage_max = {}
tt.hero.level_stats.melee_damage_min = {}
tt.hero.level_stats.melee_damage_max[1] = {11, 14, 16, 18, 20, 24, 26, 29, 31, 36}
tt.hero.level_stats.melee_damage_min[1] = {8, 9, 10, 11, 13, 15, 17, 20, 23, 26}
tt.hero.level_stats.melee_damage_max[2] = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38}
tt.hero.level_stats.melee_damage_min[2] = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
tt.hero.level_stats.melee_damage_max[3] = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38}
tt.hero.level_stats.melee_damage_min[3] = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
tt.hero.level_stats.melee_damage_max[4] = {11, 13, 15, 16, 18, 20, 24, 27, 29, 31}
tt.hero.level_stats.melee_damage_min[4] = {8, 9, 10, 11, 12, 14, 16, 18, 20, 24}
tt.hero.skills.hair_clones = E:clone_c("hero_skill")
tt.hero.skills.hair_clones.cooldown = {24, 22, 20}
tt.hero.skills.hair_clones.duration = {9, 9, 9}
tt.hero.skills.hair_clones.hp_max = {104, 130, 156}
tt.hero.skills.hair_clones.damage_min = {4, 8, 12}
tt.hero.skills.hair_clones.damage_max = {5, 10, 15}
tt.hero.skills.hair_clones.xp_gain = {160, 320, 480}
tt.hero.skills.hair_clones.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.zhu_apprentice = E:clone_c("hero_skill")
tt.hero.skills.zhu_apprentice.smash_chance = {0.3, 0.4, 0.5}
tt.hero.skills.zhu_apprentice.hp_max = {78, 117, 182}
tt.hero.skills.zhu_apprentice.damage_min = {3, 5, 10}
tt.hero.skills.zhu_apprentice.damage_max = {4, 7, 15}
tt.hero.skills.zhu_apprentice.smash_damage_min = {39, 71, 97}
tt.hero.skills.zhu_apprentice.smash_damage_max = {45, 91, 117}
tt.hero.skills.zhu_apprentice.entity = "soldier_hero_wukong_zhu_apprentice"
tt.hero.skills.zhu_apprentice.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.pole_ranged = E:clone_c("hero_skill")
tt.hero.skills.pole_ranged.cooldown = {17, 17, 17}
tt.hero.skills.pole_ranged.damage_max = {19, 32, 39}
tt.hero.skills.pole_ranged.damage_min = {13, 18, 23}
tt.hero.skills.pole_ranged.pole_amounts = {3, 5, 7}
tt.hero.skills.pole_ranged.xp_gain = {160, 320, 480}
tt.hero.skills.pole_ranged.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.giant_staff = E:clone_c("hero_skill")
tt.hero.skills.giant_staff.cooldown = {50.5, 47.5, 44}
tt.hero.skills.giant_staff.area_damage_min = {120, 160, 200}
tt.hero.skills.giant_staff.area_damage_max = {140, 200, 260}
tt.hero.skills.giant_staff.xp_gain = {160, 320, 480}
tt.hero.skills.giant_staff.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.cooldown = {42, 42, 42, 42}
tt.hero.skills.ultimate.damage_total = {260, 390, 520, 650}
tt.hero.skills.ultimate.controller_name = "controller_hero_wukong_ultimate"
tt.hero.skills.ultimate.slow_factor = {0.5, 0.5, 0.5, 0.5}
tt.hero.skills.ultimate.slow_duration = {3, 3.5, 4, 4.5}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.ultimate.xp_gain_factor = 43
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.hero_portrait = "kr5_hero_portraits_0018"
tt.info.portrait = "kr5_info_portraits_heroes_0018"
tt.hero.fn_level_up = hero_wukong_level_up
tt.main_script.update = hero_wukong_update
tt.motion.max_speed = 80
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "hero_wukong_wukong"
tt.render.sprites[1].draw_order = DO_HEROES
tt.sound_events.change_rally_point = i18n:cjk("HeroWukongTaunt", "HeroWukongTauntZH", nil, nil)
tt.sound_events.death = i18n:cjk("HeroWukongDeath", "HeroWukongDeathZH", nil, nil)
tt.sound_events.respawn = i18n:cjk("HeroWukongTauntIntro", "HeroWukongTauntZHIntro", nil, nil)
tt.sound_events.hero_room_select = i18n:cjk("HeroWukongTauntSelect", "HeroWukongTauntZHSelect", nil, nil)
tt.sound_death_sfx = "HeroWukongDeathSFX"
tt.soldier.melee_slot_offset = v(20, 0)
tt.unit.hit_offset = v(0, 23)
tt.unit.mod_offset = v(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.ui.click_rect = r(-25, -13, 50, 66)
tt.ui.click_rect_fly = r(-25, -13, 50, 66)
tt.ui.click_rect_nofly = table.deepclone(tt.ui.click_rect)
tt.melee.range = 100
tt.melee.cooldown = 1
tt.melee.can_repeat_attack = false
tt.melee.hit_animation = "fx_hero_wukong_hit"
tt.melee.hit_offset = v(25, 20)
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].xp_gain_factor = 1.55
tt.melee.attacks[1].mod = "mod_hero_wukong_attacks_combos"
tt.melee.attacks[1].damage_max = {11, 14, 16, 18, 20, 24, 26, 29, 31, 36}
tt.melee.attacks[1].damage_min = {8, 9, 10, 11, 13, 15, 17, 20, 23, 26}
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_times = {fts(11), fts(16)}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].animations = {nil, "attack_1"}
tt.melee.attacks[1].hit_fx = tt.melee.hit_animation
tt.melee.attacks[1].hit_offset = tt.melee.hit_offset
tt.melee.attacks[1].sound = "HeroWukongMeleeSpin"
tt.melee.attacks[1].sound_args = {
	delay = fts(10)
}
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].basic_attack = true
tt.melee.attacks[2].xp_gain_factor = 1.55
tt.melee.attacks[2].mod = "mod_hero_wukong_attacks_combos"
tt.melee.attacks[2].damage_max = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38}
tt.melee.attacks[2].damage_min = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].hit_time = fts(10)
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].hit_fx = tt.melee.hit_animation
tt.melee.attacks[2].hit_offset = tt.melee.hit_offset
tt.melee.attacks[2].sound = "HeroWukongMeleeJump"
tt.melee.attacks[3] = E:clone_c("melee_attack")
tt.melee.attacks[3].shared_cooldown = true
tt.melee.attacks[3].basic_attack = true
tt.melee.attacks[3].xp_gain_factor = 1.55
tt.melee.attacks[3].mod = "mod_hero_wukong_attacks_combos"
tt.melee.attacks[3].damage_max = {12, 15, 17, 18, 22, 26, 28, 31, 34, 38}
tt.melee.attacks[3].damage_min = {8, 10, 11, 12, 14, 16, 19, 22, 25, 28}
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].hit_time = fts(8)
tt.melee.attacks[3].animation = "attack_3"
tt.melee.attacks[3].hit_fx = tt.melee.hit_animation
tt.melee.attacks[3].hit_offset = tt.melee.hit_offset
tt.melee.attacks[3].sound = "HeroWukongMeleeSimple"
tt.melee.attacks[3].sound_args = {
	delay = fts(10)
}
tt.melee.attacks[4] = E:clone_c("melee_attack")
tt.melee.attacks[4].shared_cooldown = true
tt.melee.attacks[4].basic_attack = true
tt.melee.attacks[4].xp_gain_factor = 1.55
tt.melee.attacks[4].mod = "mod_hero_wukong_attacks_combos"
tt.melee.attacks[4].damage_max = {11, 13, 15, 16, 18, 20, 24, 27, 29, 31}
tt.melee.attacks[4].damage_min = {8, 9, 10, 11, 12, 14, 16, 18, 20, 24}
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].hit_times = {fts(12), fts(16), fts(21)}
tt.melee.attacks[4].loops = 1
tt.melee.attacks[4].animations = {nil, "attack_4"}
tt.melee.attacks[4].hit_fx = tt.melee.hit_animation
tt.melee.attacks[4].hit_offset = tt.melee.hit_offset
tt.melee.attacks[4].sound = "HeroWukongMeleeFast"
tt.melee.attacks[4].sound_args = {
	delay = fts(10)
}
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "clones"
tt.timed_attacks.list[1].cast_time = fts(26)
tt.timed_attacks.list[1].entity = {"soldier_hero_wukong_clone", "soldier_hero_wukong_clone_b"}
tt.timed_attacks.list[1].max_range = 160
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[1].fx = "fx_hero_wukong_clones_spawn"
tt.timed_attacks.list[1].sound = "HeroWukongClones"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(15)
}
tt.timed_attacks.list[2] = E:clone_c("melee_attack")
tt.timed_attacks.list[2].animation = "area_attack"
tt.timed_attacks.list[2].staff_appear_time = fts(24)
tt.timed_attacks.list[2].hit_time = fts(38)
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].min_cooldown = 5
tt.timed_attacks.list[2].staff_template = "fx_hero_wukong_giant_staff"
tt.timed_attacks.list[2].staff_dust_template_back = "fx_hero_wukong_giant_staff_dust_cloud_back"
tt.timed_attacks.list[2].staff_dust_template_front = "fx_hero_wukong_giant_staff_dust_cloud_front"
tt.timed_attacks.list[2].staff_offset = v(17, 0)
tt.timed_attacks.list[2].vis_flags = F_INSTAKILL
tt.timed_attacks.list[2].vis_bans = F_BOSS
tt.timed_attacks.list[2].damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_DODGE)
tt.timed_attacks.list[2].area_vis_flags = F_AREA
tt.timed_attacks.list[2].area_vis_bans = F_NONE
tt.timed_attacks.list[2].area_damage_max = {140, 200, 260}
tt.timed_attacks.list[2].area_damage_min = {120, 160, 200}
tt.timed_attacks.list[2].area_damage_radius = 90
tt.timed_attacks.list[2].area_damage_type = DAMAGE_TRUE
tt.timed_attacks.list[2].sound = "HeroWukongInstakill"
tt.timed_attacks.list[2].sound_args = {
	delay = fts(15)
}
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].animation = "attack_ranged"
tt.timed_attacks.list[3].shoot_time = fts(36)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].min_cooldown = 5
tt.timed_attacks.list[3].staff_template = "decal_hero_wukong_ranged_attack_staff"
tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[3].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[3].max_range = 200
tt.timed_attacks.list[3].min_range = 0
tt.timed_attacks.list[3].min_targets = 3
tt.timed_attacks.list[3].sound = "HeroWukongMultiStaff"
tt.timed_attacks.list[3].sound_args = {
	delay = fts(30)
}
tt.ultimate = {
	ts = 0,
	cooldown = 43,
	vis_ban = 0,
	disabled = true
}
tt.flywalk = {}
tt.flywalk.min_distance = 150
tt.flywalk.extra_speed_mult = 2.2
tt.flywalk.animations = {"cloud_in", "cloud_loop", "cloud_out"}
tt.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK, TERRAIN_ICE)
tt = RT("aura_hero_wukong_ultimate_slow", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_wukong_ultimate_slow"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.aura.duration = nil
tt.render.sprites[1].prefix = "hero_wukong_dragon_ultimate_vfx_decal"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_apply_mod_hero_wukong_ultimate_update
tt = RT("mod_hero_wukong_attacks_combos", "modifier")
tt.main_script.insert = mod_hero_wukong_attacks_combos_insert
tt = RT("mod_hero_wukong_ranged_pole_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.duration = 3
tt = RT("mod_hero_wukong_ultimate_slow", "mod_slow")
tt.slow.factor = nil
tt = RT("controller_hero_wukong_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.main_script.update = controller_hero_wukong_ultimate_update
tt.damage_radius = 80
tt.damage_times = {}

for i = 1, 10 do
	local damage_start_ts = fts(31)
	local damage_end_ts = damage_start_ts + fts(44)

	tt.damage_times[i] = damage_start_ts + (damage_end_ts - damage_start_ts) / 10 * (i - 1)
end

tt.damage_type = DAMAGE_TRUE
tt.damage_flags = bor(F_AREA)
tt.damage_bans = 0
tt.dragon_fx = "fx_hero_wukong_ultimate"
tt.dragon_fx_cracks = "fx_hero_wukong_ultimate_cracks"
tt.explosion_fx = "fx_hero_wukong_ultimate_explosion"
tt.sound_events.insert = "HeroSpiderGlobalCocoons"
tt.aura_slow = "aura_hero_wukong_ultimate_slow"
