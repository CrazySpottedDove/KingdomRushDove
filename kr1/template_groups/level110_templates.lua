local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local controller_stage_10_obelisk_iron_update
local controller_stage_10_obelisk_wave_fixed_update
local controller_stage_10_ymca_insert
local controller_stage_10_ymca_update
controller_stage_10_obelisk_iron_update = function(this, store)
	local comes_from_off = true
	local next_sacrifice_id = 1
	local next_sacrifice_ts = this.config.iron_config.golem_activate_delay[next_sacrifice_id]
	local max_sacrifices = #this.config.iron_config.golem_activate_delay
	local function crystal_up()
		this.crystal.tween.props[2].keys[1][2] = V.v(0, this.crystal.render.sprites[1].offset.y)
		this.crystal.tween.props[2].keys[2][2] = V.v(0, this.crystal.move_distance)
		this.crystal.tween.disabled = false
		this.crystal.tween.reverse = false
		this.crystal.tween.ts = store.tick_ts
		this.crystal.tween.props[1].disabled = true
		this.crystal.tween.props[2].disabled = false
		this.crystal.tween.props[2].ts = store.tick_ts
	end
	local function crystal_down()
		this.crystal.tween.props[2].keys[1][2] = V.v(0, 0)
		this.crystal.tween.props[2].keys[2][2] = V.v(0, this.crystal.render.sprites[1].offset.y)
		this.crystal.tween.disabled = false
		this.crystal.tween.reverse = true
		this.crystal.tween.ts = store.tick_ts
		this.crystal.tween.props[1].disabled = true
		this.crystal.tween.props[2].disabled = false
		this.crystal.tween.props[2].ts = store.tick_ts
	end
	local function crystal_levitate()
		if this.crystal.tween.props[1].disabled then
			this.crystal.tween.disabled = false
			this.crystal.tween.reverse = false
			this.crystal.tween.ts = store.tick_ts
			this.crystal.tween.props[1].disabled = false
			this.crystal.tween.props[1].loop = true
			this.crystal.tween.props[1].ts = store.tick_ts
			this.crystal.tween.props[2].disabled = true
			this.crystal.tween.props[2].ts = store.tick_ts
		end
	end
	local function prepare_crystal()
		if comes_from_off then
			this.cultist.render.sprites[1].hidden = false
			U.animation_start_default(this.cultist, "back_online", nil, store.tick_ts)
			U.animation_start_default(this.crystal, "back_online", nil, store.tick_ts)
			S:queue(this.sound_activation)
			U.y_animation_wait_default(this.cultist)
			this.crystal.tween.props[1].ts = store.tick_ts
		else
			S:queue(this.sound_change_mode)
		end
		crystal_up()
		U.animation_start_default(this.cultist, "change_in", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.crystal, "change_in", nil, store.tick_ts)
		U.y_animation_wait_default(this.crystal)
		U.animation_start_default(this.cultist, "change_loop", nil, store.tick_ts, true)
		U.animation_start_default(this.crystal, "change_loop", nil, store.tick_ts, true)
		local fx = E:create_entity(this.template_crystal_fx)
		fx.pos = this.cultist.pos
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		this.crystal_fx = fx
		U.y_wait_unconditional(store, this.prepare_delay)
	end
	local function change_mode()
		prepare_crystal()
		if this.crystal_fx then
			this.crystal_fx.end_fx = true
		end
		U.animation_start_default(this.cultist, "change_out", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.cultist, "idle", nil, store.tick_ts, true)
	end
	local function do_sacrifice()
		U.animation_start_default(this.crystal, "to_idle4", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		S:queue(this.sound_cast_golem)
		U.animation_start_default(this.cultist, "sacrifice_in", nil, store.tick_ts)
		U.animation_start_default(this.crystal, "sacrifice_in", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.cultist, "sacrifice_loop", nil, store.tick_ts, true)
		U.animation_start_default(this.crystal, "sacrifice_loop", nil, store.tick_ts, true)
		U.y_wait_unconditional(store, this.sacrifice_duration)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.cultist, "sacrifice_out", nil, store.tick_ts)
		U.animation_start_default(this.crystal, "sacrifice_out", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		crystal_down()
		local golem_idx = next_sacrifice_id - 1
		for i = 1, 3 do
			local b = E:create_entity(this.bullet_golem_spawn)
			local pos = V.v(this.bullet_spawn_pos[i].x + this.cultist.pos.x, this.bullet_spawn_pos[i].y + this.cultist.pos.y)
			b.pos = pos
			b.bullet.from = V.vclone(b.pos)
			local golem_pos = this.golem_holder_pos[golem_idx]
			b.bullet.to = V.v(golem_pos.x + this.bullet_offset.x, golem_pos.y + this.bullet_offset.y)
			b.target_golem = this.golems[golem_idx]
			b.bullet_idx = i
			simulation:queue_insert_entity(b)
		end
		coroutine.yield()
		this.cultist.render.sprites[1].hidden = true
	end
	while store.wave_group_number == 0 do
		coroutine.yield()
	end
	local start_ts = store.tick_ts
	while true do
		if store.waves_finished and not LU.has_alive_enemies(store) then
			crystal_down()
			U.y_animation_play(this.cultist, "death", nil, store.tick_ts)
			break
		end
		if max_sacrifices < next_sacrifice_id then
			break
		end
		if next_sacrifice_ts <= store.tick_ts - start_ts then
			next_sacrifice_id = next_sacrifice_id + 1
			if next_sacrifice_id <= max_sacrifices then
				next_sacrifice_ts = this.config.iron_config.golem_activate_delay[next_sacrifice_id]
			end
			change_mode()
			do_sacrifice()
		end
		coroutine.yield()
	end
end
controller_stage_10_obelisk_wave_fixed_update = function(this, store)
	local MODE_STUN = 1
	local MODE_HEAL = 2
	local MODE_TELEPORT = 3
	local MODE_SACRIFICE = 4
	local comes_from_off = true
	local golems_to_spawn = table.clone(this.config.sacrifice.waves)
	local mode_ability_ts
	local current_mode_duration = 0
	local current_mode_start_ts = 0
	local last_wave_processed = 0
	local current_mode
	local function crystal_up()
		this.crystal.tween.props[2].keys[1][2] = V.v(0, this.crystal.render.sprites[1].offset.y)
		this.crystal.tween.props[2].keys[2][2] = V.v(0, this.crystal.move_distance)
		this.crystal.tween.disabled = false
		this.crystal.tween.reverse = false
		this.crystal.tween.ts = store.tick_ts
		this.crystal.tween.props[1].disabled = true
		this.crystal.tween.props[2].disabled = false
		this.crystal.tween.props[2].ts = store.tick_ts
	end
	local function crystal_down()
		this.crystal.tween.props[2].keys[1][2] = V.v(0, 0)
		this.crystal.tween.props[2].keys[2][2] = V.v(0, this.crystal.render.sprites[1].offset.y)
		this.crystal.tween.disabled = false
		this.crystal.tween.reverse = true
		this.crystal.tween.ts = store.tick_ts
		this.crystal.tween.props[1].disabled = true
		this.crystal.tween.props[2].disabled = false
		this.crystal.tween.props[2].ts = store.tick_ts
	end
	local function crystal_levitate()
		if this.crystal.tween.props[1].disabled then
			this.crystal.tween.disabled = false
			this.crystal.tween.reverse = false
			this.crystal.tween.ts = store.tick_ts
			this.crystal.tween.props[1].disabled = false
			this.crystal.tween.props[1].loop = true
			this.crystal.tween.props[1].ts = store.tick_ts
			this.crystal.tween.props[2].disabled = true
			this.crystal.tween.props[2].ts = store.tick_ts
		end
	end
	local function prepare_crystal()
		if comes_from_off then
			this.cultist.render.sprites[1].hidden = false
			U.animation_start_default(this.cultist, "back_online", nil, store.tick_ts)
			U.animation_start_default(this.crystal, "back_online", nil, store.tick_ts)
			S:queue(this.sound_activation)
			U.y_animation_wait_default(this.cultist)
			this.crystal.tween.props[1].ts = store.tick_ts
		else
			S:queue(this.sound_change_mode)
		end
		crystal_up()
		U.animation_start_default(this.cultist, "change_in", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.crystal, "change_in", nil, store.tick_ts)
		U.y_animation_wait_default(this.crystal)
		U.animation_start_default(this.cultist, "change_loop", nil, store.tick_ts, true)
		U.animation_start_default(this.crystal, "change_loop", nil, store.tick_ts, true)
		local fx = E:create_entity(this.template_crystal_fx)
		fx.pos = this.cultist.pos
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
		this.crystal_fx = fx
		U.y_wait_unconditional(store, this.config.mode_first_delay)
	end
	local function change_mode()
		local per_wave_config = store.level_mode == GAME_MODE_CAMPAIGN and this.config.per_wave_config_campaign or this.config.per_wave_config_heroic
		U.y_wait_unconditional(store, per_wave_config[store.wave_group_number].delay)
		last_wave_processed = store.wave_group_number
		prepare_crystal()
		if this.crystal_fx then
			this.crystal_fx.end_fx = true
		end
		U.animation_start_default(this.cultist, "change_out", nil, store.tick_ts)
		U.y_animation_wait_default(this.cultist)
		U.animation_start_default(this.cultist, "idle", nil, store.tick_ts, true)
		if store.level_mode == GAME_MODE_CAMPAIGN and table.contains(golems_to_spawn, store.wave_group_number) then
			current_mode = MODE_SACRIFICE
		else
			local current_mode_name = per_wave_config[store.wave_group_number].mode
			if current_mode_name == "teleport" then
				current_mode = MODE_TELEPORT
			elseif current_mode_name == "heal" then
				current_mode = MODE_HEAL
			end
			U.animation_start_default(this.crystal, "to_idle" .. current_mode, nil, store.tick_ts)
			U.y_animation_wait_default(this.crystal)
			U.animation_start_default(this.crystal, "idle" .. current_mode, nil, store.tick_ts, true)
			local set_ts = store.tick_ts
			if current_mode == MODE_STUN then
				set_ts = set_ts - (this.config.stun.cooldown - this.config.mode_first_delay)
			elseif current_mode == MODE_HEAL then
				set_ts = set_ts - (this.config.heal.cooldown - this.config.mode_first_delay)
			elseif current_mode == MODE_TELEPORT then
				set_ts = set_ts - (this.config.teleport.cooldown - this.config.mode_first_delay)
			end
			mode_ability_ts = set_ts
			current_mode_duration = per_wave_config[store.wave_group_number].duration
			current_mode_start_ts = store.tick_ts
		end
	end
	local function on_mode_end()
		current_mode = nil
	end
	local function do_while_stun()
		crystal_levitate()
		if store.tick_ts - mode_ability_ts >= this.config.stun.cooldown then
			local enemies = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, bor(F_ENEMY)) == 0 and v.vis and v.vis.bans and band(v.vis.bans, 0) == 0
			end)
			if not enemies or #enemies < this.config.min_enemies then
				mode_ability_ts = store.tick_ts - this.config.stun.cooldown + 1 - 1e-06
				return
			end
			S:queue(this.sound_cast_stun)
			U.y_animation_play(this.cultist, "telegraph_in", nil, store.tick_ts)
			U.animation_start_default(this.cultist, "telegraph_loop", nil, store.tick_ts, true)
			local fx_explosion = E:create_entity(this.fx_stun_explosion)
			fx_explosion.pos = this.cultist.pos
			fx_explosion.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx_explosion)
			U.y_wait_unconditional(store, fts(18))
			local fx_white = E:create_entity(this.fx_stun_explosion_white)
			fx_white.pos = V.v(512, 384)
			fx_white.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx_white)
			local fx = E:create_entity(this.fx_stun_circle)
			fx.pos = this.cultist.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = 0.4
			shake.aura.duration = 0.5
			shake.aura.freq_factor = 1
			simulation:queue_insert_entity(shake)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "telegraph_out", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "idle", nil, store.tick_ts, true)
			local soldiers = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, this.stun_bans) == 0 and v.vis and v.vis.bans and band(v.vis.bans, this.stun_flags) == 0 and (not this.stun_excluded_teplates or not table.contains(this.stun_excluded_teplates, v.template_name))
			end)
			if soldiers and #soldiers > 0 then
				for _, s in ipairs(soldiers) do
					local m = E:create_entity(this.stun_mod)
					m.modifier.source_id = this.id
					m.modifier.target_id = s.id
					m.modifier.duration = this.config.stun.stun_duration
					simulation:queue_insert_entity(m)
				end
			end
			mode_ability_ts = store.tick_ts
		end
	end
	local function do_while_heal()
		crystal_levitate()
		if store.tick_ts - mode_ability_ts >= this.config.heal.cooldown then
			local enemies = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, this.heal_bans) == 0 and v.vis and v.vis.bans and band(v.vis.bans, this.heal_flags) == 0 and (not this.heal_excluded_teplates or not table.contains(this.heal_excluded_teplates, v.template_name))
			end)
			if not enemies or #enemies < this.config.min_enemies then
				mode_ability_ts = store.tick_ts - this.config.heal.cooldown + 1 - 1e-06
				return
			end
			S:queue(this.sound_cast_heal)
			U.y_animation_play(this.cultist, "telegraph_in", nil, store.tick_ts)
			U.y_animation_play(this.base_crystal, "heal_in", nil, store.tick_ts)
			S:queue(this.sound_heal_loop)
			U.animation_start_default(this.base_crystal, "heal_loop", nil, store.tick_ts, true)
			U.animation_start_default(this.cultist, "telegraph_loop", nil, store.tick_ts, true)
			local enemies = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, this.heal_bans) == 0 and v.vis and v.vis.bans and band(v.vis.bans, this.heal_flags) == 0 and (not this.heal_excluded_teplates or not table.contains(this.heal_excluded_teplates, v.template_name))
			end)
			local mod_duration = fts(30)
			if enemies and #enemies > 0 then
				for _, enemy in ipairs(enemies) do
					local m = E:create_entity(this.heal_mod)
					m.modifier.source_id = this.id
					m.modifier.target_id = enemy.id
					m.heal_hp = math.random(this.config.heal.heal_min, this.config.heal.heal_max)
					simulation:queue_insert_entity(m)
					mod_duration = m.modifier.duration
				end
			end
			U.y_wait_unconditional(store, mod_duration)
			S:stop(this.sound_heal_loop)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "telegraph_out", nil, store.tick_ts)
			U.animation_start_default(this.base_crystal, "heal_out", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "idle", nil, store.tick_ts, true)
			mode_ability_ts = store.tick_ts
		end
	end
	local function do_while_teleport()
		crystal_levitate()
		if store.tick_ts - mode_ability_ts >= this.config.teleport.cooldown then
			local enemies = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, this.teleport_bans) == 0 and v.vis and v.vis.bans and band(v.vis.bans, this.teleport_flags) == 0 and (not this.teleport_excluded_teplates or not table.contains(this.teleport_excluded_teplates, v.template_name)) and v.nav_path and P:nodes_to_goal(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni) >= this.config.teleport.nodes_to_goal_selectable and v.nav_path.ni >= this.config.teleport.nodes_from_selectable
			end)
			if not enemies or #enemies < this.config.min_enemies then
				mode_ability_ts = store.tick_ts - this.config.teleport.cooldown + 1 - 1e-06
				return
			end
			U.y_animation_play(this.cultist, "telegraph_in", nil, store.tick_ts)
			U.animation_start_default(this.cultist, "telegraph_loop", nil, store.tick_ts, true)
			U.animation_start_default(this.crystal, "telegraph_3", nil, store.tick_ts)
			local fx = E:create_entity(this.fx_teleport)
			fx.pos = this.cultist.pos
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
			U.y_wait_unconditional(store, fts(20))
			S:queue(this.sound_cast_teleport)
			local enemies = table.filter(store.entities, function(k, v)
				return not v.pending_removal and v.health and not v.health.dead and v.vis and v.vis.flags and band(v.vis.flags, this.teleport_bans) == 0 and v.vis and v.vis.bans and band(v.vis.bans, this.teleport_flags) == 0 and (not this.teleport_excluded_teplates or not table.contains(this.teleport_excluded_teplates, v.template_name)) and v.nav_path and P:nodes_to_goal(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni) >= this.config.teleport.nodes_to_goal_selectable and v.nav_path.ni >= this.config.teleport.nodes_from_selectable
			end)
			if enemies and #enemies > 0 then
				local sorted_enemies = {}
				for _, e1 in ipairs(enemies) do
					local enemies_in_range = 0
					for _, e2 in ipairs(enemies) do
						if e1.id ~= e2.id and e1.pos and e2.pos then
							local distance = V.dist(e1.pos.x, e1.pos.y, e2.pos.x, e2.pos.y)
							if distance < this.config.teleport.aura_radius then
								enemies_in_range = enemies_in_range + 1
							end
						end
					end
					table.insert(sorted_enemies, {
						entity = e1,
						enemies_in_range = enemies_in_range
					})
				end
				table.sort(sorted_enemies, function(e1, e2)
					return e1.enemies_in_range > e2.enemies_in_range
				end)
				local a = E:create_entity(this.teleport_aura)
				local target = enemies[1]
				if #sorted_enemies > 0 then
					target = sorted_enemies[1].entity
				end
				a.aura.source_id = this.id
				local pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni)
				a.pos = V.vclone(pos)
				simulation:queue_insert_entity(a)
			end
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "telegraph_out", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "idle", nil, store.tick_ts, true)
			mode_ability_ts = store.tick_ts
		end
	end
	local function do_sacrifice()
		if table.contains(golems_to_spawn, store.wave_group_number) then
			U.animation_start_default(this.crystal, "to_idle4", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			S:queue(this.sound_cast_golem)
			U.animation_start_default(this.cultist, "sacrifice_in", nil, store.tick_ts)
			U.animation_start_default(this.crystal, "sacrifice_in", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "sacrifice_loop", nil, store.tick_ts, true)
			U.animation_start_default(this.crystal, "sacrifice_loop", nil, store.tick_ts, true)
			U.y_wait_unconditional(store, this.sacrifice_duration)
			U.y_animation_wait_default(this.cultist)
			U.animation_start_default(this.cultist, "sacrifice_out", nil, store.tick_ts)
			U.animation_start_default(this.crystal, "sacrifice_out", nil, store.tick_ts)
			U.y_animation_wait_default(this.cultist)
			crystal_down()
			local golem_idx = #this.config.sacrifice.waves - #golems_to_spawn + 1
			for i = 1, 3 do
				local b = E:create_entity(this.bullet_golem_spawn)
				local pos = V.v(this.bullet_spawn_pos[i].x + this.cultist.pos.x, this.bullet_spawn_pos[i].y + this.cultist.pos.y)
				b.pos = pos
				b.bullet.from = V.vclone(b.pos)
				local golem_pos = this.golem_holder_pos[golem_idx]
				b.bullet.to = V.v(golem_pos.x + this.bullet_offset.x, golem_pos.y + this.bullet_offset.y)
				b.target_golem = this.golems[golem_idx]
				b.bullet_idx = i
				simulation:queue_insert_entity(b)
			end
			coroutine.yield()
			this.cultist.render.sprites[1].hidden = true
			table.remove(golems_to_spawn, 1)
		end
	end
	while store.wave_group_number == 0 do
		coroutine.yield()
	end
	while true do
		if store.waves_finished and not LU.has_alive_enemies(store) then
			crystal_down()
			U.y_animation_play(this.cultist, "death", nil, store.tick_ts)
			break
		end
		if store.wave_group_number ~= last_wave_processed then
			if current_mode == MODE_SACRIFICE then
				comes_from_off = true
			else
				comes_from_off = false
				if current_mode == nil then
					comes_from_off = true
				end
			end
			on_mode_end()
			change_mode()
		else
			if current_mode == MODE_SACRIFICE then
				do_sacrifice()
			elseif current_mode == MODE_STUN then
				do_while_stun()
			elseif current_mode == MODE_HEAL then
				do_while_heal()
			elseif current_mode == MODE_TELEPORT then
				do_while_teleport()
			end
			if current_mode ~= nil and current_mode_duration <= store.tick_ts - current_mode_start_ts then
				on_mode_end()
				U.y_animation_play(this.cultist, "death", nil, store.tick_ts)
				U.y_wait_unconditional(store, 0.8)
				crystal_down()
				U.animation_start_default(this.crystal, "turn_off", nil, store.tick_ts)
			end
		end
		coroutine.yield()
	end
end
controller_stage_10_ymca_insert = function(this, store)
	this.statues = {}
	for i = 1, 4 do
		local statue = E:create_entity(this.entity_statue)
		statue.pos = this.statue_position[i]
		statue.letter_idx = this.start_formation[i]
		simulation:queue_insert_entity(statue)
		table.insert(this.statues, statue)
	end
	local dots = E:create_entity(this.entity_dots)
	dots.pos = this.dots_pos
	dots.render.sprites[1].hidden = true
	simulation:queue_insert_entity(dots)
	this.dots = dots
	return true
end
controller_stage_10_ymca_update = function(this, store)
	local function create_fireworks()
		local fireworks = E:create_entity(this.entity_fireworks)
		fireworks.pos = this.dots_pos
		fireworks.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fireworks)
		S:queue("Stage10VillagePeopleFireworks")
	end
	local function create_lights()
		local lights = E:create_entity(this.entity_lights)
		lights.pos = this.dots_pos
		lights.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(lights)
		this.lights = lights
	end
	local puzzle_solved = false
	local function is_puzzle_solved()
		for statue_idx, s in ipairs(this.statues) do
			if s.letter_idx ~= statue_idx then
				return false
			end
		end
		return true
	end
	while true do
		if not puzzle_solved and is_puzzle_solved() then
			puzzle_solved = true
			for statue_idx, s in ipairs(this.statues) do
				s.ui.can_click = false
			end
			U.y_wait_unconditional(store, 1)
			for statue_idx, s in ipairs(this.statues) do
				s.dance = true
			end
			create_fireworks()
			create_lights()
			this.dots.render.sprites[1].hidden = false
			U.y_animation_play(this.dots, "start", nil, store.tick_ts)
			S:queue("Stage10VillagePeopleSong", {
				delay = fts(12)
			})
			U.animation_start_default(this.dots, "idle", nil, store.tick_ts, true)
			local center = V.v(0, 0)
			for i, s in ipairs(this.entities_soldiers) do
				center.x = center.x + this.soldier_path_pos[i].x
				center.y = center.y + this.soldier_path_pos[i].y
			end
			center.x = center.x / #this.entities_soldiers
			center.y = center.y / #this.entities_soldiers
			for i, s in ipairs(this.entities_soldiers) do
				local soldier = E:create_entity(s)
				soldier.pos = this.soldier_spawn_pos[i]
				local line_pos = V.v(this.soldier_line_pos_offset[i].x + soldier.pos.x, this.soldier_line_pos_offset[i].y + soldier.pos.y)
				soldier.spawn_delay = this.soldier_spawn_delay[i]
				soldier.position_in_line = line_pos
				soldier.path_pos = this.soldier_path_pos[i]
				soldier.nav_rally.center = V.vclone(center)
				soldier.reinforcement.squad_id = this.id
				simulation:queue_insert_entity(soldier)
			end
			while this.statues[1].dance do
				coroutine.yield()
			end
			simulation:queue_remove_entity(this.dots)
			simulation:queue_remove_entity(this.lights)
			signal.emit("ymca-stage10", this)
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("controller_stage_10_obelisk_wave_fixed", "controller_stage_10_obelisk", true)
tt.main_script.update = controller_stage_10_obelisk_wave_fixed_update
tt = E:register_t_hot("decal_stage_10_ymca_ground_decos", "decal", true)
tt.render.sprites[1].name = "ymca_spawn_fx_layer_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t_hot("decal_stage_10_obelisk_back", "decal", true)
tt.render.sprites[1].name = "stage10_obelisk_base_back"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].animated = false
tt = E:register_t_hot("controller_stage_10_obelisk_iron", "controller_stage_10_obelisk", true)
tt.main_script.update = controller_stage_10_obelisk_iron_update
tt.golem_holder_pos = {v(74, 524), v(310, 440), v(60, 308), v(700, 400), v(328, 204)}
tt.golem_walk_pos = {v(26, -34), v(50, 50), v(30, 0), v(0, -70), v(54, 60)}
tt.golem_activate_holder = {"2", "4", "1", "11", "6"}
tt.golem_selected_paths = {4, 3, 2, 3, 1}
tt.prepare_delay = 3
tt = E:register_t_hot("decal_stage_10_obelisk", "decal", true)
tt.render.sprites[1].name = "stage10_obelisk_base"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt = E:register_t_hot("controller_stage_10_ymca", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.insert = controller_stage_10_ymca_insert
tt.main_script.update = controller_stage_10_ymca_update
tt.entities_soldiers = {"soldier_stage_10_ymca_indio", "soldier_stage_10_ymca_constructor", "soldier_stage_10_ymca_biker", "soldier_stage_10_ymca_policia"}
tt.entity_statue = "decal_stage_10_ymca_statue"
tt.entity_dots = "decal_stage_10_ymca_dots"
tt.entity_fireworks = "decal_stage_10_ymca_fireworks"
tt.entity_lights = "decal_stage_10_ymca_lights"
tt.dots_pos = v(1025, 590)
tt.start_formation = {3, 4, 2, 1}
local sb = v(-30, -30)
tt.statue_position = {v(sb.x + 975, sb.y + 620), v(sb.x + 1030, sb.y + 650), v(sb.x + 1090, sb.y + 645), v(sb.x + 1133, sb.y + 590)}
tt.soldier_spawn_pos = {v(985, 585), v(1015, 600), v(1045, 580), v(1015, 560)}
tt.soldier_line_pos_offset = {v(25, -20), v(20, -10), v(-15, 5), v(-25, -10)}
local base = v(925, 445)
tt.soldier_path_pos = {v(base.x - 20, base.y + 20), v(base.x + 13, base.y + 33), v(base.x + 25, base.y), v(base.x - 10, base.y - 10)}
tt.soldier_spawn_delay = {1.5, 1.8, 1.7, 1.5}
tt = E:register_t_hot("decal_stage_10_fire", "decal", true)
tt.render.sprites[1].prefix = "stage_10_fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
