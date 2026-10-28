local scripts = require("scripts")
local E = require("entity_db")
local GR = require("grid_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local V = require("lib.klua.vector")
local bit = require("bit")
local km = require("lib.klua.macros")
local HU = require("hero_utils")
local signal = require("lib.hump.signal")
local log = require("lib.klua.log"):new("hero_scripts")
local band = bit.band
local bor = bit.bor
local fts = U.fts
local level_up_basic = HU.level_up_basic
local queue_damage = U.queue_damage
local ready_to_use_skill = HU.ready_to_use_skill
local tpos = U.tpos
local update_hp = HU.update_hp
local upgrade_skill = HU.upgrade_skill
local v = V.v
local tt

local function mod_hero_robot_skill_uppercut_insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target then
		return false
	end

	if band(target.vis.flags, this.modifier.vis_bans) ~= 0 then
		return false
	end

	if band(target.vis.bans, this.modifier.vis_flags) ~= 0 then
		return false
	end

	SU.stun_inc(target)
	U.bans_add(target.vis, F_ALL)

	target.ui.can_click = false
	target.ui.can_select = false
	target.health_bar.hidden = true
	target.unit.show_blood_pool = false

	return true
end

local function mod_hero_robot_skill_uppercut_update(this, store, script)
	local start_ts = store.tick_ts
	local m = this.modifier
	local target = store.entities[this.modifier.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	local is_on_right = store.entities[this.modifier.source_id].pos.x < this.pos.x

	while store.tick_ts - start_ts < this.modifier.duration do
		target = store.entities[m.target_id]

		if not target or target.health.dead then
			break
		end

		local speed = this.fly_speed
		local rot = this.rotation_speed

		if is_on_right then
			target.pos.x = target.pos.x + speed.x
		else
			target.pos.x = target.pos.x - speed.x
		end

		target.pos.y = target.pos.y - speed.y

		for _, sprite in ipairs(target.render.sprites) do
			sprite.r = sprite.r + rot
		end

		coroutine.yield()
	end

	target = store.entities[m.target_id]

	if target then
		SU.stun_dec(target)
		U.bans_remove(target.vis, F_ALL)

		target.ui.can_click = true
		target.ui.can_select = true
		target.health_bar.hidden = false
		target.health.hp = 0
		target.unit.show_blood_pool = true

		for i, es in ipairs(target.render.sprites) do
			es.r = 0
		end
	end

	simulation:queue_remove_entity(this)
end

local function aura_hero_robot_skill_fire_slow_update(this, store, script)
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
	this.render.sprites[1].flip_x = math.random(1, 2) == 1
	this.aura.duration = this.aura.duration - fts(math.random(1, 10))
	this.tween.props[1].keys[1] = {0, 255}
	this.tween.props[1].keys[2] = {this.aura.duration - fts(12), 255}
	this.tween.props[1].keys[3] = {this.aura.duration, 0}
	this.tween.ts = store.tick_ts

	U.y_animation_play(this, "start", nil, store.tick_ts, 1)
	U.animation_start_default(this, "loop", nil, store.tick_ts, false)

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				break
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_441_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_441_0
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

		::label_441_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end

local function hero_robot_level_up(this, store)
	local hl, ls = level_up_basic(this)

	this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
	this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

	upgrade_skill(this, "jump", function(this, s)
		local a = this.timed_attacks.list[1]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
		a.loops = s.loops[s.level]

		local aura = E:get_template(a.aura)
		local mod = E:get_template(aura.aura.mod)

		mod.modifier.duration = s.stun_duration[s.level]
	end)
	upgrade_skill(this, "fire", function(this, s)
		local a = this.timed_attacks.list[2]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]

		local b = E:get_template(a.bullet)

		b.bullet.damage_min = s.damage_min[s.level]
		b.bullet.damage_max = s.damage_max[s.level]

		local aura = E:get_template(b.aura_on_hit)

		aura.aura.duration = s.smoke_duration[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.modifier.duration = s.slow_duration[s.level]
	end)
	upgrade_skill(this, "explode", function(this, s)
		local a = this.timed_attacks.list[3]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]

		local mod = E:get_template(a.mod)

		mod.dps.damage_min = s.burning_damage_min[s.level]
		mod.dps.damage_max = s.burning_damage_max[s.level]
	end)
	upgrade_skill(this, "uppercut", function(this, s)
		local a = this.timed_attacks.list[4]

		a.disabled = nil
		a.cooldown = s.cooldown[s.level]
		a.life_threshold = s.life_threshold[s.level]
	end)
	upgrade_skill(this, "ultimate", function(this, s)
		this.ultimate.disabled = nil
		this.ultimate.cooldown = s.cooldown[s.level]

		local uc = E:get_template(s.controller_name)

		uc.cooldown = s.cooldown[s.level]

		local aura = E:get_template(uc.entity)

		aura.damage_min = s.damage_min[s.level]
		aura.damage_max = s.damage_max[s.level]

		local mod = E:get_template(aura.aura.mod)

		mod.dps.damage_min = s.burning_damage_min[s.level]
		mod.dps.damage_max = s.burning_damage_max[s.level]
	end)
	update_hp(this)

	this.hero.melee_active_status = {}

	for index, attack in ipairs(this.melee.attacks) do
		this.hero.melee_active_status[index] = attack.disabled
	end
end

local function hero_robot_update(this, store)
	local h = this.health
	local a, skill, brk, sta
	local last_ts = store.tick_ts
	local base_speed = this.motion.max_speed
	local jump_attack = this.timed_attacks.list[1]
	local fire_attack = this.timed_attacks.list[2]
	local explode_attack = this.timed_attacks.list[3]
	local uppercut_attack = this.timed_attacks.list[4]
	local ps1, ps2

	if not jump_attack.disabled then
		jump_attack.ts = store.tick_ts - jump_attack.cooldown
	end

	if not fire_attack.disabled then
		fire_attack.ts = store.tick_ts - fire_attack.cooldown
	end

	if not explode_attack.disabled then
		explode_attack.ts = store.tick_ts - explode_attack.cooldown
	end

	if not uppercut_attack.disabled then
		uppercut_attack.ts = store.tick_ts - uppercut_attack.cooldown
	end

	local function explosion_damage(point, radius, damage_min, damage_max, damage_type, damage_bans, damage_flags, mod_to_apply)
		local enemies = U.find_enemies_in_range_filter_off(point, radius, damage_flags, damage_bans)

		if enemies then
			for _, enemy in ipairs(enemies) do
				local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, point, radius)
				local d = E.assign_damage(damage_type, math.floor(damage_max - (damage_max - damage_min) * dist_factor), this.id, enemy.id)

				queue_damage(store, d)

				if mod_to_apply then
					local mod = E:create_entity(mod_to_apply)

					mod.modifier.target_id = enemy.id
					mod.modifier.source_id = this.id

					simulation:queue_insert_entity(mod)
				end
			end
		end
	end

	ps1 = E:create_entity(this.particles_name_1)
	ps1.particle_system.emit = true
	ps1.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps1)

	ps2 = E:create_entity(this.particles_name_2)
	ps2.particle_system.emit = true
	ps2.particle_system.track_id = this.id

	simulation:queue_insert_entity(ps2)

	this.health_bar.hidden = false

	while true do
		if h.dead then
			ps1.particle_system.emit = false
			ps2.particle_system.emit = false

			SU.y_hero_death_and_respawn(store, this)

			ps1.particle_system.emit = true
			ps2.particle_system.emit = true

			U.update_max_speed(this, base_speed)
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
					ps1.particle_system.emit = false
					ps2.particle_system.emit = false
					r.new = false

					U.unblock_target(store, this)
					U.bans_add(this.vis, F_ALL)

					this.health.immune_to = F_ALL

					U.speed_inc_self(this, tw.extra_speed)

					this.unit.marker_hidden = true
					this.health_bar.hidden = true
					this.ui.click_rect = this.ui.click_rect_fly

					S:queue(this.sound_events.change_rally_point)
					S:queue(this.flywalk.sound)

					local an, af = U.animation_name_facing_point(this, tw.animations[1], r.pos)

					U.animation_start_default(this, an, af, store.tick_ts)

					::label_432_0::

					local dest = r.pos
					local n = this.nav_grid

					while not V.veq(this.pos, dest) do
						local w = table.remove(n.waypoints, 1) or dest

						U.set_destination(this, w)

						local runs = this.render.sprites[1].runs

						while not this.motion.arrived do
							if r.new then
								r.new = false

								goto label_432_0
							end

							U.walk_off__accel__unsnapped(this, store.tick_length)
							coroutine.yield()

							this.motion.speed.x, this.motion.speed.y = 0, 0

							if this.render.sprites[1].runs ~= runs then
								local an, af = U.animation_name_facing_point(this, tw.animations[2], this.motion.dest)

								U.animation_start(this, an, af, store.tick_ts, true, 1, true)

								runs = this.render.sprites[1].runs
							end
						end
					end

					SU.hide_modifiers(store, this, true)
					U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
					SU.show_modifiers(store, this, true)

					this.ui.click_rect = this.ui.click_rect_nofly

					U.speed_dec_self(this, tw.extra_speed)
					U.bans_remove(this.vis, F_ALL)

					this.health.immune_to = 0
					this.unit.marker_hidden = nil
					this.health_bar.hidden = nil
					ps1.particle_system.emit = true
					ps2.particle_system.emit = true
				elseif SU.y_hero_new_rally(store, this) then
					goto label_432_1
				end
			end

			if SU.hero_level_up(store, this) then
				U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
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

			skill = this.hero.skills.jump
			a = jump_attack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				if this.soldier.target_id ~= nil then
					a.ts = a.ts + fts(5)
				else
					for i = 1, a.loops do
						local target = U.find_random_enemy_with_pos(store, this.pos, 0, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, origin)
							return P:is_node_valid(e.nav_path.pi, e.nav_path.ni)
						end)

						if not target then
							a.ts = a.ts + fts(5)

							break
						else
							local n_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni)

							if V.dist2(n_pos.x, n_pos.y, target.pos.x, target.pos.y) > 25 then
								a.ts = a.ts + fts(5)
							else
								local new_ni = target.nav_path.ni + a.fall_ahead
								local target_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, new_ni)

								last_ts = store.tick_ts

								S:queue(a.sound_cast)
								U.unblock_target(store, this)
								U.bans_add(this.vis, F_ALL)
								SU.hide_modifiers(store, this, true)
								SU.hide_auras(store, this, true)

								ps1.particle_system.emit = false
								ps2.particle_system.emit = false

								local an, af = U.animation_name_facing_point(this, a.animation_prepare, target_pos)

								U.y_animation_play(this, an, af, store.tick_ts, 1)

								local an, af = U.animation_name_facing_point(this, a.animation, target_pos)

								U.animation_start_default(this, an, af, store.tick_ts, false)

								local target = U.find_random_enemy_with_pos(store, this.pos, 0, a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, function(e, origin)
									return P:is_node_valid(e.nav_path.pi, e.nav_path.ni)
								end)

								if target then
									new_ni = target.nav_path.ni + a.fall_ahead
									target_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, new_ni)
								end

								local dest = V.vclone(target_pos)

								U.set_destination(this, dest)

								local animation_length = fts(20)
								local remaining_time = animation_length
								local start_jump_ts = store.tick_ts

								S:queue(a.sound_impact, a.sound_impact_args)

								while animation_length > store.tick_ts - start_jump_ts do
									local distance_x = math.abs(this.pos.x - this.motion.dest.x)
									local distance_y = math.abs(this.pos.y - this.motion.dest.y)

									if this.pos.x - this.motion.dest.x < 0 then
										this.pos.x = this.pos.x + distance_x / (remaining_time / store.tick_length)
									else
										this.pos.x = this.pos.x - distance_x / (remaining_time / store.tick_length)
									end

									if this.pos.y - this.motion.dest.y < 0 then
										this.pos.y = this.pos.y + distance_y / (remaining_time / store.tick_length)
									else
										this.pos.y = this.pos.y - distance_y / (remaining_time / store.tick_length)
									end

									remaining_time = remaining_time - store.tick_length

									coroutine.yield()
								end

								this.motion.arrived = true
								this.nav_rally.pos = V.vclone(this.pos)
								this.nav_rally.center = V.vclone(this.pos)
								a.ts = last_ts

								local aura = E:create_entity(a.aura)

								aura.pos = V.v(dest.x, dest.y - 10)
								aura.owner = this
								aura.aura.source_id = this.id

								simulation:queue_insert_entity(aura)
								explosion_damage(dest, a.damage_radius, a.damage_min, a.damage_max, a.damage_type, a.damage_bans, a.damage_flags)
								U.bans_remove(this.vis, F_ALL)
								SU.show_modifiers(store, this, true)
								SU.show_auras(store, this, true)
								SU.hero_gain_xp_from_skill(this, skill)
								U.y_animation_wait_default(this)

								ps1.particle_system.emit = true
								ps2.particle_system.emit = true
							end
						end
					end

					goto label_432_1
				end
			end

			skill = this.hero.skills.fire
			a = fire_attack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				if this.soldier.target_id ~= nil then
					a.ts = a.ts + fts(10)
				else
					local target, enemies = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

					if not target then
						a.ts = a.ts + fts(10)
					elseif #enemies < a.min_targets then
						a.ts = a.ts + fts(10)
					else
						last_ts = store.tick_ts

						local final_target = target

						S:queue(a.sound, a.sound_args)

						ps1.particle_system.emit = false
						ps2.particle_system.emit = false

						local an, af = U.animation_name_facing_point(this, a.animation, final_target.pos)

						U.animation_start_default(this, an, af, store.tick_ts, false)
						U.y_wait_unconditional(store, a.shoot_time)

						local target = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

						if target then
							final_target = target
						end

						local path = final_target.nav_path.pi
						local nodes_between_shoots = 6

						local function fire_bullet(pi, spi, ni)
							local pos = P:node_pos(pi, spi, ni)

							pos.x = pos.x + math.random(-4, 4)
							pos.y = pos.y + math.random(-5, 5)

							local b = E:create_entity(a.bullet)

							b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y

							b.bullet.from:copy(b.pos)

							b.bullet.to = pos
							b.bullet.source_id = this.id

							simulation:queue_insert_entity(b)
						end

						local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path})

						if #nearest > 0 then
							local pi, _, ni = unpack(nearest[1])
							local initial_offset = 1
							local direction = ni < final_target.nav_path.ni and -1 or 1

							ni = (ni - initial_offset) * direction

							local count = a.shoots / 3
							local ni_aux

							for i = 1, count do
								ni_aux = (ni - i * nodes_between_shoots) * direction

								if P:is_node_valid(pi, ni_aux) then
									fire_bullet(pi, 1, ni_aux)
								end

								ni_aux = (ni - i * (nodes_between_shoots + 1)) * direction

								if P:is_node_valid(pi, ni_aux) then
									fire_bullet(pi, 2, ni_aux)
									fire_bullet(pi, 3, ni_aux)
								end
							end
						end

						a.ts = last_ts

						SU.hero_gain_xp_from_skill(this, skill)
						U.y_animation_wait_default(this)

						ps1.particle_system.emit = true
						ps2.particle_system.emit = true

						goto label_432_1
					end
				end
			end

			skill = this.hero.skills.explode
			a = explode_attack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				local target, enemies, pred_pos = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.max_range, a.node_prediction, a.vis_flags, a.vis_bans)

				if not target then
					a.ts = a.ts + fts(10)
				elseif #enemies < a.min_targets then
					a.ts = a.ts + fts(10)
				else
					last_ts = store.tick_ts

					S:queue(a.sound)

					ps1.particle_system.emit = false
					ps2.particle_system.emit = false

					local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

					U.animation_start_default(this, an, af, store.tick_ts, false)
					U.y_wait_unconditional(store, a.load_time)

					a.ts = last_ts

					local decal = E:create_entity(a.decal)

					decal.pos = V.v(this.pos.x, this.pos.y)
					decal.render.sprites[1].ts = store.tick_ts

					simulation:queue_insert_entity(decal)
					explosion_damage(this.pos, a.damage_radius, a.damage_min, a.damage_max, a.damage_type, a.damage_bans, a.damage_flags, a.mod)
					SU.hero_gain_xp_from_skill(this, skill)
					U.y_animation_wait_default(this)

					ps1.particle_system.emit = true
					ps2.particle_system.emit = true

					goto label_432_1
				end
			end

			skill = this.hero.skills.uppercut
			a = uppercut_attack

			if not a.disabled and store.tick_ts - a.ts > a.cooldown and store.tick_ts - last_ts > a.min_cooldown then
				if this.soldier.target_id == nil then
					a.ts = a.ts + fts(5)
				elseif not this.motion.arrived then
					a.ts = a.ts + fts(5)
				else
					local target = store.entities[this.soldier.target_id]

					if not target then
						a.ts = a.ts + fts(5)
					elseif not table.contains({UNIT_SIZE_SMALL}, target.unit.size) then
						a.ts = a.ts + fts(5)
					elseif target.health.dead then
						a.ts = a.ts + fts(5)
					else
						local current_life_percentage = target.health.hp * 100 / target.health.hp_max

						if current_life_percentage > a.life_threshold then
							a.ts = a.ts + fts(5)
						else
							last_ts = store.tick_ts

							S:queue(a.sound)

							ps1.particle_system.emit = false
							ps2.particle_system.emit = false

							local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

							U.animation_start_default(this, an, af, store.tick_ts, false)
							U.y_wait_unconditional(store, a.shoot_time)

							local m = E:create_entity(a.mod)

							m.modifier.target_id = target.id
							m.modifier.source_id = this.id
							m.enemy_move_offset = a.enemy_move_offset

							simulation:queue_insert_entity(m)

							a.ts = last_ts

							SU.hero_gain_xp_from_skill(this, skill)
							U.y_animation_wait_default(this)

							ps1.particle_system.emit = true
							ps2.particle_system.emit = true

							goto label_432_1
						end
					end
				end
			end

			if this.soldier.target_id ~= nil and this.motion.arrived then
				ps1.particle_system.emit = false
				ps2.particle_system.emit = false
			else
				ps1.particle_system.emit = true
				ps2.particle_system.emit = true
			end

			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
			-- block empty
			elseif SU.soldier_go_back_step(store, this) then
			-- block empty
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_432_1::

		coroutine.yield()
	end
end

local function aura_hero_robot_ultimate_train_update(this, store)
	local first_hit_ts
	local last_hit_ts = 0
	local target_pos = this.pos
	local fading = false
	local last_ni_decal = 0
	local last_ni_smoke = 0
	local path_ni = 1
	local path_spi = 1
	local path_pi = 1
	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v) and P:is_path_active(v)
		end)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])

		for _, n in pairs(nearest) do
			local _path_pi, _path_spi, _path_ni = unpack(n)

			if _path_pi == this.path_id then
				path_pi, path_spi, path_ni = _path_pi, _path_spi, _path_ni

				break
			end
		end
	end

	path_spi = 1
	path_ni = path_ni - 3
	last_ni_decal = path_ni
	last_ni_smoke = path_ni

	local distance = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	local function animation_name_facing_angle_hero_robot(group, angle_deg)
		local a = this.render.sprites[1]
		local o_name, o_flip, o_idx
		local a1, a2, a3, a4, a5, a6, a7, a8 = 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5
		local angles = a.angles[group]

		if a1 <= angle_deg and angle_deg < a2 then
			o_name, o_flip, o_idx = angles[3], false, 3
		elseif a2 <= angle_deg and angle_deg < a3 then
			o_name, o_flip, o_idx = angles[4], false, 4
		elseif a3 <= angle_deg and angle_deg < a4 then
			o_name, o_flip, o_idx = angles[3], true, 3
		elseif a4 <= angle_deg and angle_deg < a5 then
			o_name, o_flip, o_idx = angles[2], true, 2
		elseif a5 <= angle_deg and angle_deg < a6 then
			o_name, o_flip, o_idx = angles[1], true, 1
		elseif a6 <= angle_deg and angle_deg < a7 then
			o_name, o_flip, o_idx = angles[5], false, 5
		elseif a7 <= angle_deg and angle_deg < a8 then
			o_name, o_flip, o_idx = angles[1], false, 1
		else
			o_name, o_flip, o_idx = angles[2], false, 2
		end

		return o_name, o_flip, o_idx
	end

	local function animation_name_facing_point_hero_robot(group, point, offset)
		local fx, fy = this.pos.x, this.pos.y

		if offset then
			fx, fy = fx + offset.x, fy + offset.y
		end

		local vx, vy = V.sub(point.x, point.y, fx, fy)
		local v_angle = V.angleTo(vx, vy)
		local angle = km.unroll(v_angle)
		local angle_deg = km.rad2deg(angle)

		return animation_name_facing_angle_hero_robot(group, angle_deg)
	end

	local function hit_enemies()
		local targets = table.filter(store.entities, function(k, v)
			return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
		end)

		for i, target in ipairs(targets) do
			local already_hit_target = false
			local has_mod, mods = U.has_modifiers(store, target, this.aura.mod)

			if has_mod then
				for _, mod in ipairs(mods) do
					if mod.modifier.source_id == this.id then
						already_hit_target = true

						break
					end
				end
			end

			if already_hit_target then
			-- block empty
			elseif target and not target.health.dead and target.enemy then
				queue_damage(store, SU.create_attack_damage(this, target.id, this))

				local hit_fx = E:create_entity(this.hit_fx)

				hit_fx.pos:copy(target.pos)

				hit_fx.render.sprites[1].ts = store.tick_ts

				simulation:queue_insert_entity(hit_fx)

				local new_mod = E:create_entity(this.aura.mod)

				new_mod.modifier.target_id = target.id
				new_mod.modifier.source_id = this.id

				if this.aura.hide_source_fx and target.id == this.aura.source_id then
					new_mod.render = nil
				end

				simulation:queue_insert_entity(new_mod)
			end
		end
	end

	local function rider_go_back_step()
		if V.veq(this.pos, target_pos) then
			this.motion.arrived = true

			return false
		else
			U.set_destination(this, target_pos)

			if U.walk_off__accel__unsnapped(this, store.tick_length) then
				return false
			else
				local an, af = animation_name_facing_point_hero_robot("run", this.motion.dest)

				U.animation_start_default(this, an, af, store.tick_ts, true)

				return true
			end
		end
	end

	local function run_backwards()
		distance = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		if distance < 25 then
			path_ni = path_ni - 3
			target_pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		rider_go_back_step()

		if last_ni_decal - path_ni >= this.nodes_to_floor_decal then
			last_ni_decal = path_ni

			local decal = E:create_entity(this.floor_decal)

			decal.pos:copy(this.pos)

			decal.render.sprites[1].ts = store.tick_ts
			decal.render.sprites[1].flip_x = math.random(1, 2) == 1

			simulation:queue_insert_entity(decal)
		end

		if last_ni_smoke - path_ni >= this.nodes_to_smoke then
			last_ni_smoke = path_ni

			local fx = E:create_entity(this.smoke_fx)

			fx.pos:copy(this.pos)

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = math.random(1, 2) == 1

			local random_size = 1 + math.random(0, 3) / 10

			fx.render.sprites[1].scale = v(random_size, random_size)
			fx.tween.props[1].keys[4][1] = 1 + math.random(0, 5) / 10
			fx.tween.props[1].keys[3][1] = fx.tween.props[1].keys[4][1] - 0.2

			simulation:queue_insert_entity(fx)

			local side_smoke = P:node_pos(path_pi, 2, path_ni + math.random(3, 5))
			local fx = E:create_entity(this.smoke_fx)

			fx.pos = side_smoke
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = math.random(1, 2) == 1
			random_size = 1 + math.random(0, 3) / 10
			fx.render.sprites[1].scale = v(random_size, random_size)
			fx.tween.props[1].keys[4][1] = 1 + math.random(0, 5) / 10
			fx.tween.props[1].keys[3][1] = fx.tween.props[1].keys[4][1] - 0.2

			simulation:queue_insert_entity(fx)

			side_smoke = P:node_pos(path_pi, 3, path_ni + math.random(3, 5))

			local fx = E:create_entity(this.smoke_fx)

			fx.pos = side_smoke
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = math.random(1, 2) == 1
			random_size = 1 + math.random(0, 3) / 10
			fx.render.sprites[1].scale = v(random_size, random_size)
			fx.tween.props[1].keys[4][1] = 1 + math.random(0, 5) / 10
			fx.tween.props[1].keys[3][1] = fx.tween.props[1].keys[4][1] - 0.2

			simulation:queue_insert_entity(fx)
		end
	end

	local function check_start_fade()
		if fading then
			return false
		end

		local fade_duration = this.tween.props[1].keys[2][1]
		local n_pos = P:node_pos(path_pi, path_spi, path_ni - 5)

		if band(GR:cell_type(n_pos.x, n_pos.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) ~= 0 then
			this.tween.props[1].keys[2][1] = 0.25

			return true
		end

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts + fade_duration > this.aura.duration then
			return true
		end

		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path_pi})

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])

			return path_ni < 10
		end

		return false
	end

	S:queue(this.sound)

	path_ni = path_ni - 3
	target_pos = P:node_pos(path_pi, path_spi, path_ni)

	local spawn_fx = E:create_entity(this.spawn_fx)

	spawn_fx.pos:copy(this.pos)

	spawn_fx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(spawn_fx)

	this.render.sprites[1].hidden = true

	U.y_wait_unconditional(store, fts(4))

	local decal = E:create_entity(this.floor_decal)

	decal.pos:copy(this.pos)

	decal.render.sprites[1].ts = store.tick_ts
	decal.render.sprites[1].flip_x = math.random(1, 2) == 1
	decal.render.sprites[1].scale = v(1.3, 1.3)

	simulation:queue_insert_entity(decal)
	U.y_wait_unconditional(store, fts(10))

	this.render.sprites[1].hidden = false
	this.tween.props[1].disabled = true
	this.tween.props[1].ts = store.tick_ts
	this.aura.ts = store.tick_ts

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.aura.duration or fading and this.render.sprites[1].alpha <= 0 then
			break
		end

		if check_start_fade() then
			fading = true
			this.tween.props[1].disabled = false
			this.tween.reverse = true
			this.tween.props[1].ts = store.tick_ts
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_448_0
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			if this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
				goto label_448_0
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts

			hit_enemies()
		end

		run_backwards()

		::label_448_0::

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

local function mod_hero_robot_skill_fire_slow_update(this, store, script)
	local m = this.modifier

	this.modifier.ts = store.tick_ts

	local target = store.entities[m.target_id]

	if not target or not target.pos then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos

	if target.unit.size == UNIT_SIZE_MEDIUM then
		this.render.sprites[1].scale = v(1.5, 1.5)
	elseif target.unit.size == UNIT_SIZE_LARGE then
		this.render.sprites[1].scale = v(2, 2)
	end

	this.tween.ts = store.tick_ts

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
			break
		end

		if this.render and target.unit then
			local s = this.render.sprites[1]
			local flip_sign = 1

			if target.render then
				flip_sign = target.render.sprites[1].flip_x and -1 or 1
			end

			if m.health_bar_offset and target.health_bar then
				local hb = target.health_bar.offset
				local hbo = m.health_bar_offset

				s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
			elseif m.use_mod_offset and target.unit.mod_offset then
				s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
			end
		end

		coroutine.yield()
	end

	this.tween.ts = store.tick_ts
	this.tween.reverse = true
	this.tween.remove = true
end

local function ps_hero_robot_smoke_update(this, store)
	local source_sprite = store.entities[this.particle_system.track_id].render.sprites[1]

	while true do
		if source_sprite.flip_x then
			this.particle_system.emit_offset = this.particle_system.emit_offsets[2]
			this.particle_system.emit_direction = this.emit_direction_sides[2]
		else
			this.particle_system.emit_offset = this.particle_system.emit_offsets[1]
			this.particle_system.emit_direction = this.emit_direction_sides[1]
		end

		coroutine.yield()
	end

	return true
end

local function bullet_hero_robot_skill_fire_update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local target

	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead then
			b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
		end

		mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
		mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.damage_bans) == 0 and band(v.vis.bans, this.damage_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.damage_radius)
	end)

	for _, enemy in ipairs(enemies) do
		local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, this.pos, this.damage_radius)
		local d = E.assign_damage(this.bullet.damage_type, math.floor(this.bullet.damage_max - (this.bullet.damage_max - this.bullet.damage_min) * dist_factor), this.id, enemy.id)

		queue_damage(store, d)
	end

	if this.aura_on_hit then
		local aura = E:create_entity(this.aura_on_hit)

		aura.pos.x, aura.pos.y = b.to.x, b.to.y
		aura.render.sprites[1].ts = store.tick_ts
		aura.render.sprites[1].runs = 0

		simulation:queue_insert_entity(aura)
	end

	if b.hit_fx then
		local sfx = E:create_entity(b.hit_fx)

		sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(sfx)
	end

	S:queue(this.sound)
	simulation:queue_remove_entity(this)
end

local function hero_robot_ultimate_update(this, store)
	local targets = U.find_enemies_in_paths(store.enemies, this.pos, 0, 50, nil, F_AREA, F_FLYING, true)
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

	if #nearest < 1 then
		log.debug("cannot insert robot ulti, no valid nodes nearby %s,%s", this.pos.x, this.pos.y)

		return nil
	end

	local pi, ni, dist

	if not targets or #targets == 0 then
		pi, ni, dist = nearest[1][1], nearest[1][3], nearest[1][4]
	else
		for _, t in ipairs(targets) do
			for _, n in pairs(nearest) do
				pi, _, ni, dist = unpack(n)

				if dist > 20 then
					break
				end

				if t.enemy.nav_path and t.enemy.nav_path.pi == pi then
					goto label_447_0
				end
			end
		end
	end

	::label_447_0::

	S:queue(this.sound)

	local decal = E:create_entity(this.entity)
	local npos = P:node_pos(pi, 1, ni)

	decal.pos = npos
	decal.path_id = pi

	simulation:queue_insert_entity(decal)
	simulation:queue_remove_entity(this)
end

tt = RT("ps_hero_robot_smoke_1")

AC(tt, "pos", "particle_system", "main_script")

tt.particle_system.name = "Blaze_humitodeatras_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 6
tt.particle_system.emit_rotation_spread = d2r(45)
tt.particle_system.emit_area_spread = v(2, 2)
tt.particle_system.emit_speed = {20, 25}
tt.particle_system.emit_offsets = {v(10, 46), v(20, 43)}
tt.particle_system.z = Z_OBJECTS
tt.particle_system.sort_y_offset = -40
tt.particle_system.scale_var = {0.7, 0.7}
tt.main_script.update = ps_hero_robot_smoke_update
tt.emit_direction_sides = {d2r(95), d2r(40)}
tt = RT("ps_hero_robot_smoke_2", "ps_hero_robot_smoke_1")
tt.particle_system.emit_offsets = {v(-10, 44), v(0, 41)}
tt = RT("fx_hero_robot_skill_fire", "fx")
tt.render.sprites[1].name = "Blaze_skill2explosion_run"
tt = RT("fx_hero_robot_ultimate_train_spawn", "fx")
tt.render.sprites[1].name = "Blaze_tren_box"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = RT("fx_hero_robot_ultimate_smoke", "decal_tween")
tt.render.sprites[1].name = "Blaze_skill2humo_loop"
tt.tween.props[1].keys = {{fts(0), 0}, {fts(10), 255}, {0.8, 255}, {1, 0}}
tt = RT("decal_hero_robot_skill_explode", "decal")

AC(tt, "tween")

tt.render.sprites[1].name = "Blaze_skill3decal"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "Blaze_skill1y3decal"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].loop = false
tt.render.sprites[2].scale = v(1.1, 1.1)
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(9), 255}, {fts(16), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(1, 1)}, {fts(6), v(1.7, 1.7)}, {fts(16), v(2, 2)}}
tt = RT("decal_hero_robot_ultimate_floor", "decal_tween")
tt.render.sprites[1].name = "Blaze_trendecal_run"
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = RT("hero_robot", "hero")

AC(tt, "melee", "ranged", "timed_attacks")

tt.hero.level_stats.armor = {0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7}
tt.hero.level_stats.hp_max = {260, 279, 299, 318, 338, 357, 377, 396, 416, 435}
tt.hero.level_stats.melee_damage_min = {7, 9, 10, 11, 13, 13, 14, 15, 16, 19}
tt.hero.level_stats.melee_damage_max = {14, 15, 16, 17, 19, 22, 24, 25, 28, 31}
tt.hero.skills.jump = CC("hero_skill")
tt.hero.skills.jump.cooldown = {15, 14, 13, 12}
tt.hero.skills.jump.damage_min = {30, 60, 90, 120}
tt.hero.skills.jump.damage_max = {30, 60, 90, 120}
tt.hero.skills.jump.stun_duration = {2, 2, 2, 2}
tt.hero.skills.jump.loops = {1, 2, 3, 4}
tt.hero.skills.jump.xp_gain = {100, 200, 300, 400}
tt.hero.skills.jump.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.hero.skills.fire = CC("hero_skill")
tt.hero.skills.fire.cooldown = {20, 20, 20}
tt.hero.skills.fire.damage_min = {20, 40, 60}
tt.hero.skills.fire.damage_max = {40, 80, 120}
tt.hero.skills.fire.smoke_duration = {5, 5, 5}
tt.hero.skills.fire.slow_duration = {1, 1, 1}
tt.hero.skills.fire.xp_gain = {200, 400, 600}
tt.hero.skills.fire.xp_level_steps = {
	[3] = 1,
	[6] = 2,
	[9] = 3
}
tt.hero.skills.explode = CC("hero_skill")
tt.hero.skills.explode.cooldown = {20, 19, 18}
tt.hero.skills.explode.damage_min = {30, 60, 90}
tt.hero.skills.explode.damage_max = {40, 80, 120}
tt.hero.skills.explode.burning_damage_min = {1, 2, 3}
tt.hero.skills.explode.burning_damage_max = {1, 2, 3}
tt.hero.skills.explode.xp_gain = {160, 320, 480}
tt.hero.skills.explode.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3
}
tt.hero.skills.uppercut = CC("hero_skill")
tt.hero.skills.uppercut.cooldown = {32, 28, 24}
tt.hero.skills.uppercut.life_threshold = {25, 30, 40}
tt.hero.skills.uppercut.xp_level_steps = {
	[2] = 1,
	[5] = 2,
	[8] = 3
}
tt.hero.skills.ultimate = CC("hero_skill")
tt.hero.skills.ultimate.controller_name = "controller_hero_robot_ultimate"
tt.hero.skills.ultimate.cooldown = {40, 40, 40, 40}
tt.hero.skills.ultimate.damage_min = {60, 130, 200, 270}
tt.hero.skills.ultimate.damage_max = {60, 130, 200, 270}
tt.hero.skills.ultimate.burning_damage_min = {1, 2, 3, 4}
tt.hero.skills.ultimate.burning_damage_max = {1, 2, 3, 4}
tt.hero.skills.ultimate.xp_level_steps = {
	[1] = 1,
	[4] = 2,
	[7] = 3,
	[10] = 4
}
tt.particles_name_1 = "ps_hero_robot_smoke_1"
tt.particles_name_2 = "ps_hero_robot_smoke_2"
tt.hero.fn_level_up = hero_robot_level_up
tt.health.dead_lifetime = 15
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.hero_portrait = "kr5_hero_portraits_0010"
tt.info.portrait = "kr5_info_portraits_heroes_0010"
tt.main_script.update = hero_robot_update
tt.motion.max_speed = 45
tt.regen.cooldown = 1
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "Blaze_pibe"
tt.render.sprites[1].draw_order = DO_HEROES
tt.soldier.melee_slot_offset = v(20, 0)
tt.sound_events.change_rally_point = "HeroRobotTaunt"
tt.sound_events.death = "HeroRobotDeath"
tt.sound_events.respawn = "HeroRobotTauntIntro"
tt.sound_events.hero_room_select = "HeroRobotTauntSelect"
tt.unit.hit_offset = v(0, 14)
tt.unit.mod_offset = v(0, 14)
tt.melee.range = 72
tt.melee.attacks[1] = CC("melee_attack")
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].shared_cooldown = 1
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_offset = v(45, 15)
tt.melee.attacks[1].xp_gain_factor = 2.2
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].sound = "CommonNoSwordAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(8)
}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation_prepare = "skill1start"
tt.timed_attacks.list[1].animation = "skill1"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.timed_attacks.list[1].vis_flags = bor(F_STUN)
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].sound_cast = "HeroRobotDeepImpactCast"
tt.timed_attacks.list[1].sound_impact = "HeroRobotDeepImpactImpact"
tt.timed_attacks.list[1].sound_impact_args = {
	delay = fts(14)
}
tt.timed_attacks.list[1].min_cooldown = 3
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].node_prediction = fts(36)
tt.timed_attacks.list[1].aura = "aura_hero_robot_skill_jump"
tt.timed_attacks.list[1].fall_ahead = 8
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].damage_bans = bor(F_FLYING)
tt.timed_attacks.list[1].damage_flags = bor(F_AREA)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].min_cooldown = 3
tt.timed_attacks.list[2].animation = "skill2"
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 180
tt.timed_attacks.list[2].node_prediction = fts(36)
tt.timed_attacks.list[2].shoot_time = fts(25)
tt.timed_attacks.list[2].bullet = "bullet_hero_robot_skill_fire"
tt.timed_attacks.list[2].bullet_start_offset = v(7, 26)
tt.timed_attacks.list[2].shoots = 16
tt.timed_attacks.list[2].min_targets = 3
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].damage_bans = bor(F_FLYING)
tt.timed_attacks.list[2].damage_flags = bor(F_AREA)
tt.timed_attacks.list[2].sound = "HeroRobotSmokescreenCast"
tt.timed_attacks.list[2].sound_args = {
	delay = fts(0)
}
tt.timed_attacks.list[3] = CC("custom_attack")
tt.timed_attacks.list[3].animation = "skill4"
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].min_cooldown = 3
tt.timed_attacks.list[3].min_range = 0
tt.timed_attacks.list[3].max_range = 90
tt.timed_attacks.list[3].node_prediction = fts(36)
tt.timed_attacks.list[3].decal = "decal_hero_robot_skill_explode"
tt.timed_attacks.list[3].load_time = fts(25)
tt.timed_attacks.list[3].damage_bans = bor(F_FLYING)
tt.timed_attacks.list[3].damage_flags = bor(F_AREA)
tt.timed_attacks.list[3].damage_radius = 80
tt.timed_attacks.list[3].damage_type = DAMAGE_EXPLOSION
tt.timed_attacks.list[3].mod = "mod_hero_robot_skill_explode"
tt.timed_attacks.list[3].min_targets = 2
tt.timed_attacks.list[3].sound = "HeroRobotImmolationCast"
tt.timed_attacks.list[4] = CC("custom_attack")
tt.timed_attacks.list[4].disabled = true
tt.timed_attacks.list[4].min_cooldown = 3
tt.timed_attacks.list[4].animation = "skill3"
tt.timed_attacks.list[4].shoot_time = fts(25)
tt.timed_attacks.list[4].enemy_move_offset = v(10, 40)
tt.timed_attacks.list[4].mod = "mod_hero_robot_skill_uppercut"
tt.timed_attacks.list[4].sound = "HeroRobotUppercutCast"
tt.ui.click_rect = r(-27, -5, 54, 50)
tt.ui.click_rect_fly = r(-27, 20, 54, 50)
tt.ui.click_rect_nofly = r(-27, -5, 54, 50)
tt.vis.bans = bor(F_POLYMORPH, F_DISINTEGRATED, F_CANNIBALIZE, F_SKELETON, F_BLOOD, F_POISON)
tt.flywalk = {}
tt.flywalk.min_distance = 80
tt.flywalk.extra_speed = 110
tt.flywalk.animations = {"flystart", "passiveloop", "passiveout"}
tt.flywalk.sound = "HeroRobotJetpackCast"
tt.ultimate = {
	ts = 0,
	cooldown = 40
}
tt.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK, TERRAIN_ICE)
tt = RT("bullet_hero_robot_skill_fire", "bullet")
tt.main_script.update = bullet_hero_robot_skill_fire_update
tt.render.sprites[1].name = "Blaze_skill2proyectil"
tt.render.sprites[1].animated = false
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.hit_fx = "fx_hero_robot_skill_fire"
tt.bullet.acceleration_factor = 0.2
tt.bullet.min_speed = 600
tt.bullet.max_speed = 600
tt.bullet.g = -1.8 / (fts(1) * fts(1))
tt.damage_radius = 30
tt.damage_bans = bor(F_FLYING)
tt.damage_flags = bor(F_RANGED)
tt.aura_on_hit = "aura_hero_robot_skill_fire_slow"
tt = RT("aura_hero_robot_skill_jump", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_robot_skill_jump"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.duration = fts(22)
tt.render.sprites[1].prefix = "Blaze_skill1y3decal"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = v(1.1, 1.1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "Blaze_skill1humito"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].loop = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {fts(18), 255}, {fts(22), 0}}
tt = RT("aura_hero_robot_skill_fire_slow", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_hero_robot_skill_fire_slow"
tt.aura.radius = 20
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.duration = nil
tt.aura.cycle_time = fts(1)
tt.aura.track_source = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = aura_hero_robot_skill_fire_slow_update
tt.render.sprites[1].prefix = "Blaze_skill2humo"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = v(1.3, 1.3)
tt.tween.remove = false
tt = RT("aura_hero_robot_ultimate_train", "aura")

AC(tt, "render", "tween", "nav_rally", "motion")

tt.render.sprites[1].prefix = "Blaze_tren"
tt.render.sprites[1].name = "box"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.run = {"downright", "right", "upright", "up", "down"}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.remove = false
tt.main_script.update = aura_hero_robot_ultimate_train_update
tt.motion.max_speed = 200
tt.aura.duration = 5
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.radius = 70
tt.aura.mod = "mod_hero_robot_skill_ultimate_burning"
tt.spawn_fx = "fx_hero_robot_ultimate_train_spawn"
tt.damage_type = DAMAGE_PHYSICAL
tt.floor_decal = "decal_hero_robot_ultimate_floor"
tt.smoke_fx = "fx_hero_robot_ultimate_smoke"
tt.hit_fx = "fx_hero_robot_skill_fire"
tt.nodes_to_floor_decal = 5
tt.nodes_to_smoke = 3
tt.sound = "HeroRobotMotorheadCast"
tt.offset_back = 5
tt = RT("mod_hero_robot_skill_jump", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt = RT("mod_hero_robot_skill_explode", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 4
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_hero_robot_skill_fire_slow", "mod_slow")

AC(tt, "render", "tween")

tt.slow.factor = 0.5
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "Blaze_skill2humostatus"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.modifier.use_mod_offset = false
tt.main_script.update = mod_hero_robot_skill_fire_slow_update
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.remove = false
tt = RT("mod_hero_robot_skill_uppercut", "modifier")
tt.modifier.duration = fts(10)
tt.main_script.insert = mod_hero_robot_skill_uppercut_insert
tt.main_script.update = mod_hero_robot_skill_uppercut_update
tt.fly_speed = v(7, 8)
tt.rotation_speed = 0.17
tt = RT("mod_hero_robot_skill_ultimate_burning", "modifier")

AC(tt, "dps", "render")

tt.modifier.duration = 4
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.25
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("controller_hero_robot_ultimate")

AC(tt, "pos", "main_script", "sound_events")

tt.offset_back = -5
tt.entity = "aura_hero_robot_ultimate_train"
tt.main_script.update = hero_robot_ultimate_update
