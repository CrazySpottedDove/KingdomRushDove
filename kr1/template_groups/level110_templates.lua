local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local vv = V.vv
local P = require("path_db")
local SU = require("script_utils")
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

tt = E:register_t_hot("soldier_stage_10_ymca", "soldier_militia", true)
E:add_comps(tt, "reinforcement", "nav_grid", "tween")
tt.health.armor = 0
tt.health.hp_max = 100
tt.health_bar.offset = v(0, 30)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = function(this, store)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.ui.can_click = false

	U.y_wait_unconditional(store, this.spawn_delay)
	U.set_destination(this, this.position_in_line)

	local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

	U.animation_start_default(this, an, af, store.tick_ts, true)

	while not U.walk_off__accel__unsnapped(this, store.tick_length) do
		coroutine.yield()
	end

	U.set_destination(this, this.path_pos)

	local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

	U.animation_start_default(this, an, af, store.tick_ts, true)

	while not U.walk_off__accel__unsnapped(this, store.tick_length) do
		coroutine.yield()
	end

	this.nav_rally.pos = this.path_pos

	U.animation_start_default(this, "idle", af, store.tick_ts, true)

	if this.reinforcement.fade or this.reinforcement.fade_in then
		SU.y_reinforcement_fade_in(store, this)
	elseif this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise)
		end

		this.health_bar.hidden = true
		U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	this.ui.can_click = true

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			SU.remove_modifiers(store, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_hero_new_rally(store, this) then
					goto label_1168_1
				end
			end

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto label_1168_1
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto label_1168_1
				elseif star == A_IN_COOLDOWN then
					goto label_1168_0
				end
			end

			if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto label_1168_1
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_1168_1
			end

			::label_1168_0::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::label_1168_1::

		coroutine.yield()
	end
end
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.range = 72
tt.motion.max_speed = 90
tt.regen.health = 0
tt.reinforcement.duration = 1e+99
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(1.1)
tt.soldier.melee_slot_offset = v(3, 0)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

tt = E:register_t_hot("soldier_stage_10_ymca_indio", "soldier_stage_10_ymca", true)
tt.render.sprites[1].prefix = "ymca_ymca_indio"
tt.info.portrait = "kr5_info_portraits_soldiers_0020"

tt = E:register_t_hot("soldier_stage_10_ymca_constructor", "soldier_stage_10_ymca", true)
tt.render.sprites[1].prefix = "ymca_ymca_constructor"
tt.render.sprites[1].anchor = v(0.5, 1)
tt.render.sprites[1].offset.y = 35
tt.info.portrait = "kr5_info_portraits_soldiers_0023"

tt = E:register_t_hot("soldier_stage_10_ymca_biker", "soldier_stage_10_ymca", true)
tt.render.sprites[1].prefix = "ymca_ymca_biker"
tt.info.portrait = "kr5_info_portraits_soldiers_0022"

tt = E:register_t_hot("soldier_stage_10_ymca_policia", "soldier_stage_10_ymca", true)
tt.render.sprites[1].prefix = "ymca_ymca_policia"
tt.info.portrait = "kr5_info_portraits_soldiers_0021"

tt = E:register_t_hot("fx_stage_10_statue_click", "fx", true)
tt.render.sprites[1].prefix = "ymca_statue_dust"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].hide_after_runs = 1

tt = E:register_t_hot("fx_stage_10_obelisk_teleport", "fx", true)
tt.render.sprites[1].prefix = "TeleportFxDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("fx_stage_10_obelisk_stun_explosion", "fx", true)
tt.render.sprites[1].prefix = "StunFxDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("fx_stage_10_obelisk_stun_explosion_white", "decal_tween", true)
tt.render.sprites[1].prefix = "StunWhiteDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].z = Z_GUI - 2
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(70)
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{fts(0), vv(70)}}

tt = E:register_t_hot("fx_stage_10_obelisk_stun_circle", "fx", true)
tt.render.sprites[1].prefix = "StunCircleDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("fx_stage_10_obelisk_teleport_crystal", "decal_tween", true)
tt.render.sprites[1].prefix = "stage10_obelisk_teleport_fx_teleport"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].z = Z_DECALS - 1
tt.fx_duration = 1.6
tt.tween.props[1].keys = {{fts(0), 0}, {fts(5), 255}, {tt.fx_duration - fts(7), 255}, {tt.fx_duration, 0}}

tt = E:register_t_hot("decal_stage_10_ymca_statue", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "ymca_statue"
tt.main_script.update = function(this, store)
	local function get_letter(idx)
		if idx == 1 then
			return "y"
		elseif idx == 2 then
			return "m"
		elseif idx == 3 then
			return "c"
		elseif idx == 4 then
			return "a"
		end
	end

	local function create_dust_fx()
		local fx = E:create_entity(this.click_fx)

		fx.pos = this.pos
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	while true do
		if this.dance then
			U.y_animation_play(this, "dance_loop", nil, store.tick_ts, 2)
			create_dust_fx()

			this.dance = nil
		end

		if this.ui.clicked then
			this.ui.clicked = nil
			this.letter_idx = km.zmod(this.letter_idx + 1, 4)

			S:queue("Stage10VillagePeopleStatuePuff")
			create_dust_fx()
		end

		U.animation_start_default(this, get_letter(this.letter_idx), nil, store.tick_ts)
		coroutine.yield()
	end
end
tt.ui.click_rect = r(-30, -10, 60, 80)
tt.click_fx = "fx_stage_10_statue_click"

tt = E:register_t_hot("decal_stage_10_ymca_dots", "decal", true)
tt.render.sprites[1].prefix = "YMCAPuntosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_10_ymca_fireworks", "decal", true)
tt.render.sprites[1].prefix = "ymca_spawn_fx_layer_3"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].hide_after_runs = 1

tt = E:register_t_hot("decal_stage_10_ymca_lights", "decal", true)
tt.render.sprites[1].prefix = "ymca_spawn_fx_layer_4"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("mod_stage_10_obelisk_heal", "modifier", true)
E:add_comps(tt, "hps", "render")
tt.modifier.duration = 10
tt.modifier.use_mod_offset = false
tt.hps.heal_min = 1
tt.hps.heal_max = 3
tt.hps.heal_every = 0.25
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = function(this, store)
	local m = this.modifier
	local hps = this.hps
	local duration = m.duration

	if m.duration_inc then
		duration = duration + m.level * m.duration_inc
	end

	local heal_min = hps.heal_min
	local heal_max = hps.heal_max

	if hps.heal_min_inc and hps.heal_max_inc then
		heal_min = hps.heal_min + m.level * hps.heal_min_inc
		heal_max = hps.heal_max + m.level * hps.heal_max_inc
	end

	if hps.heal_inc then
		heal_min = hps.heal_min + m.level * hps.heal_inc
		heal_max = hps.heal_max + m.level * hps.heal_inc
	end

	local target = store.entities[m.target_id]

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	this.pos = target.pos
	this.render.sprites[1].prefix = this.render.sprites[1].size_prefix[target.unit.size]
	this.render.sprites[2].prefix = this.render.sprites[2].size_prefix[target.unit.size]

	local target_fly = target and band(target.vis.flags, F_FLYING) ~= 0

	if target_fly then
		this.render.sprites[1].hidden = true
		this.render.sprites[2].hidden = true
		m.use_mod_offset = true
	end

	U.y_animation_play(this, "in", nil, store.tick_ts)
	U.animation_start_default(this, "Idle", nil, store.tick_ts, true)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or duration < store.tick_ts - m.ts then
			U.y_animation_play(this, "out", nil, store.tick_ts)
			simulation:queue_remove_entity(this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			for i = 1, #this.render.sprites do
				local s = this.render.sprites[i]

				if not s.exclude_mod_offset then
					s.offset.x, s.offset.y = -target.unit.mod_offset.x, -target.unit.mod_offset.y
				end
			end
		end

		if hps.heal_every and store.tick_ts - hps.ts >= hps.heal_every then
			hps.ts = store.tick_ts

			local heal_amount = U.heal(target, math.random(heal_min, heal_max))

			signal.emit("entity-healed", this, target, heal_amount)

			if hps.fx then
				local fx = E:create_entity(hps.fx)

				fx.pos = V.vclone(this.pos)
				fx.render.sprites[1].ts = store.tick_ts
				fx.render.sprites[1].runs = 0

				simulation:queue_insert_entity(fx)
			end
		end

		coroutine.yield()
	end
end
tt.render.sprites[1].prefix = "HealFx1Def"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].size_prefix = {"HealFx1Def", "HealFx1BigDef", "HealFx1BigDef"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "HealFx2Def"
tt.render.sprites[2].name = "Idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].size_prefix = {"HealFx2Def", "HealFx2BigDef", "HealFx2BigDef"}
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "HealFx3Def"
tt.render.sprites[3].name = "Idle"
tt.render.sprites[3].exo = true

tt = E:register_t_hot("aura_stage_10_obelisk_teleport", "aura", true)
E:add_comps(tt, "track_damage", "render")
tt.aura.duration = fts(1)
tt.aura.radius = 100
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_TELEPORT, F_RANGED)
tt.aura.mod = "mod_stage_10_obelisk_teleport"
tt.aura.max_count = 4
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = function(this, store)
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

		if this.aura.requires_magic ~= false then
			local te = store.entities[this.aura.source_id]

			if not te or not te.enemy then
				goto label_1163_0
			end

			if this.render then
				this.render.sprites[1].hidden = not te.enemy.can_do_magic
			end

			if not te.enemy.can_do_magic then
				goto label_1163_0
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_1163_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_1163_0
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
			this.render.sprites[1].hidden = false
			U.y_animation_play(this, "decal_in", nil, store.tick_ts)
			U.animation_start_default(this, "decal_loop", nil, store.tick_ts, true)
		end

		::label_1163_0::

		coroutine.yield()
	end

	U.y_animation_play(this, "decal_out", nil, store.tick_ts)
	signal.emit("aura-apply-mod-victims", this, victims_count)
	simulation:queue_remove_entity(this)
end
tt.render.sprites[1].prefix = "TeleportDecalDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "decal_in"
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("mod_stage_10_obelisk_teleport", "mod_teleport", true)
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.nodes_offset = 25
tt.nodeslimit = 30
tt.delay_start = fts(2)
tt.hold_time = 0.34
tt.delay_end = fts(4)
tt.fx_start = "fx_stage_10_obelisk_teleport"
tt.fx_end = "fx_stage_10_obelisk_teleport"
tt.max_times_applied = 1e+99

tt = E:register_t_hot("decal_stage_10_obelisk_priests", "decal", true)
tt.render.sprites[1].prefix = "stage10_obelisk_priests"
tt.render.sprites[1].name = "idle_off"
tt.render.sprites[1].z = Z_DECALS + 1

tt = E:register_t_hot("decal_stage_10_obelisk_crystals", "decal", true)
tt.render.sprites[1].prefix = "stage10_obelisk_base_cristalitos"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage10_obelisk_base_cristalitos_back"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_DECALS - 1

tt = E:register_t_hot("decal_stage_10_obelisk_crystal", "decal_tween", true)
tt.render.sprites[1].prefix = "stage10_obelisk_crystal"
tt.render.sprites[1].name = "idle_off"
tt.render.sprites[1].z = Z_DECALS - 1
tt.move_frequency = 25
tt.move_distance = 20
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, tt.move_distance)}, {fts(tt.move_frequency), v(0, 15)}, {fts(tt.move_frequency * 2), v(0, tt.move_distance)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].keys = {{fts(0), v(0, 0)}, {fts(tt.move_frequency), v(0, tt.move_distance)}}
tt.tween.props[2].disabled = true
tt.tween.remove = false
tt.tween.disabled = true

tt = E:register_t_hot("decal_stage_10_obelisk_crystal_fx", "decal_scripted", true)
E:add_comps(tt, "tween")
tt.render.sprites[1].prefix = "stage10_obelisk_changestate_fx_change"
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(12), 0}}
tt.tween.disabled = true
tt.main_script.update = function(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts)

	while true do
		if this.end_fx then
			break
		end

		U.animation_start_default(this, "loop", false, store.tick_ts, true)
		coroutine.yield()
	end

	this.tween.disabled = false
	this.tween.ts = store.tick_ts

	U.y_animation_play(this, "out", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end

tt = E:register_t_hot("fx_stage_10_obelisk_priest_hit", "fx", true)
tt.render.sprites[1].name = "stage10_obelisk_hit"

tt = E:register_t_hot("ps_bullet_stage_10_obelisk_priests", nil, true)
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "stage10_obelisk_particle_Idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = v(8, 8)
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.animation_fps = 15

tt = E:register_t_hot("bullet_stage_10_obelisk_priests", "bolt", true)
E:add_comps(tt, "force_motion")
tt.render.sprites[1].prefix = "stage10_obelisk_projectile"
tt.bullet.acceleration_factor = 0.1
tt.bullet.align_with_trajectory = true
tt.main_script.update = function(this, store)
	local b = this.bullet
	local fm = this.force_motion
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

	local function fly_to_pos(target_pos)
		local last_pos = V.vclone(this.pos)
		local dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		while V.len(dx, dy) > 20 do
			last_pos.x, last_pos.y = this.pos.x, this.pos.y

			move_step(target_pos)

			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
			dx, dy = V.sub(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

			coroutine.yield()
		end
	end

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	b.ts = store.tick_ts
	fm.a.x, fm.a.y = 0, 80

	local target_pos = v(b.from.x - 70 + 30 * this.bullet_idx, b.from.y + 110 - 10 * this.bullet_idx)

	fly_to_pos(target_pos)

	fm.a.x, fm.a.y = 100, 0

	if this.bullet_idx == 3 then
		local target_pos = v(b.from.x + 70, b.from.y + 50)

		fly_to_pos(target_pos)
	else
		local target_pos = v(b.from.x - 70, b.from.y + 50)

		fly_to_pos(target_pos)
	end

	b.initial_impulse = nil
	fm.a_step = 10
	fm.max_a = 6000
	fm.max_v = 510
	ps.particle_system.emission_rate = 60

	fly_to_pos(b.to)

	this.pos.x, this.pos.y = b.to.x, b.to.y
	this.target_golem.wake_up = true
	this.render.sprites[1].hidden = true

	if b.hit_fx and this.bullet_idx == 1 then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		simulation:queue_insert_entity(fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait_unconditional(store, ps.particle_system.particle_lifetime[2])
	end

	simulation:queue_remove_entity(this)
end
tt.bullet.hit_fx = "fx_stage_10_obelisk_priest_hit"
tt.bullet.particles_name = "ps_bullet_stage_10_obelisk_priests"
tt.bullet.max_speed = 30
tt.bullet.min_speed = 3
tt.force_motion.a_step = 5
tt.force_motion.max_a = 900
tt.force_motion.max_v = 300
tt = E:register_t_hot("controller_stage_10_obelisk", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.insert = function(this, store)
	local cultist = E:create_entity(this.entity_cultist)

	cultist.pos = this.obelisk_pos

	simulation:queue_insert_entity(cultist)

	this.cultist = cultist

	local crystal = E:create_entity(this.entity_crystal)

	crystal.pos = V.v(this.crystal_pos.x, this.crystal_pos.y - crystal.move_distance)

	simulation:queue_insert_entity(crystal)

	this.crystal = crystal

	local base_crystal = E:create_entity(this.entity_base_crystals)

	base_crystal.pos = this.obelisk_pos

	simulation:queue_insert_entity(base_crystal)

	this.base_crystal = base_crystal
	this.golems = {}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		for i = 1, 3 do
			local golem = E:create_entity(this.template_golem)

			golem.pos = this.golem_holder_pos[i]
			golem.start_as_rock = true
			golem.walk_pos = this.golem_walk_pos[i]
			golem.activate_holder = this.golem_activate_holder[i]
			golem.selected_path = this.golem_selected_paths[i]
			golem.ignore_seen_tracker = true

			simulation:queue_insert_entity(golem)
			table.insert(this.golems, golem)
		end
	elseif store.level_mode == GAME_MODE_IRON then
		for i = 1, #this.golem_activate_holder do
			local golem = E:create_entity(this.template_golem)

			golem.pos = V.vclone(this.golem_holder_pos[i])
			golem.start_as_rock = true
			golem.walk_pos = V.v(golem.pos.x + this.golem_walk_pos[i].x, golem.pos.y + this.golem_walk_pos[i].y)
			golem.activate_holder = this.golem_activate_holder[i]
			golem.selected_path = this.golem_selected_paths[i]
			golem.ignore_seen_tracker = true

			simulation:queue_insert_entity(golem)
			table.insert(this.golems, golem)
		end
	end

	return true
end
tt.main_script.update = function(this, store)
	local MODE_STUN = 1
	local MODE_HEAL = 2
	local MODE_TELEPORT = 3
	local MODE_SACRIFICE = 4
	local current_mode_idx = 1
	local crystal_mode_list = table.random_order({MODE_STUN, MODE_HEAL, MODE_TELEPORT})
	local comes_from_off = true
	local golems_to_spawn = table.clone(this.config.sacrifice.waves)
	local mode_ability_ts
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
			U.animation_start_default(this.crystal, "to_idle" .. crystal_mode_list[current_mode_idx], nil, store.tick_ts)
			U.y_animation_wait_default(this.crystal)
			U.animation_start_default(this.crystal, "idle" .. crystal_mode_list[current_mode_idx], nil, store.tick_ts, true)

			local set_ts = store.tick_ts

			if crystal_mode_list[current_mode_idx] == MODE_STUN then
				set_ts = set_ts - (this.config.stun.cooldown - this.config.mode_first_delay)
				current_mode = MODE_STUN
			elseif crystal_mode_list[current_mode_idx] == MODE_HEAL then
				set_ts = set_ts - (this.config.heal.cooldown - this.config.mode_first_delay)
				current_mode = MODE_HEAL
			elseif crystal_mode_list[current_mode_idx] == MODE_TELEPORT then
				set_ts = set_ts - (this.config.teleport.cooldown - this.config.mode_first_delay)
				current_mode = MODE_TELEPORT
			end

			mode_ability_ts = set_ts
		end
	end

	local function on_mode_end()
		current_mode = nil
		current_mode_idx = km.zmod(current_mode_idx + 1, #crystal_mode_list)
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

				a.aura.source_id = this.id
				a.pos = V.vclone(sorted_enemies[1].entity.pos)

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

	U.y_wait_unconditional(store, this.config.start_delay[store.level_mode])

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
		elseif current_mode == MODE_SACRIFICE then
			do_sacrifice()
		elseif current_mode == MODE_STUN then
			do_while_stun()
		elseif current_mode == MODE_HEAL then
			do_while_heal()
		elseif current_mode == MODE_TELEPORT then
			do_while_teleport()
		end

		coroutine.yield()
	end
end
tt.entity_cultist = "decal_stage_10_obelisk_priests"
tt.entity_crystal = "decal_stage_10_obelisk_crystal"
tt.entity_light = "decal_stage_10_obelisk_light"
tt.entity_base_crystals = "decal_stage_10_obelisk_crystals"
tt.template_crystal_fx = "decal_stage_10_obelisk_crystal_fx"
tt.fx_stun_explosion = "fx_stage_10_obelisk_stun_explosion"
tt.fx_stun_explosion_white = "fx_stage_10_obelisk_stun_explosion_white"
tt.fx_stun_circle = "fx_stage_10_obelisk_stun_circle"
tt.fx_teleport = "fx_stage_10_obelisk_teleport_crystal"
tt.obelisk_pos = v(531, 545)
tt.crystal_pos = v(531, 539)
tt.fx_heal_pos = v(528, 557)
tt.config = {
	mode_first_delay = 1,
	min_enemies = 2,
	start_delay = {20, 0, 30},
	per_wave_config_campaign = {
		{
			delay = 30,
			mode = "heal",
			duration = 12
		},
		{
			delay = 12,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 30,
			mode = "heal",
			duration = 12
		},
		{
			delay = 8,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 1,
			mode = "sacrifice"
		},
		{
			delay = 20,
			mode = "heal",
			duration = 12
		},
		{
			delay = 12,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 20,
			mode = "heal",
			duration = 12
		},
		{
			delay = 12,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 1,
			mode = "sacrifice"
		},
		{
			delay = 25,
			mode = "heal",
			duration = 12
		},
		{
			delay = 12,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 20,
			mode = "heal",
			duration = 12
		},
		{
			delay = 12,
			mode = "teleport",
			duration = 12
		},
		{
			delay = 10,
			mode = "sacrifice"
		}
	},
	per_wave_config_heroic = {{
		delay = 30,
		mode = "heal",
		duration = 10
	}, {
		delay = 48,
		mode = "heal",
		duration = 10
	}, {
		delay = 20,
		mode = "heal",
		duration = 10
	}, {
		delay = 45,
		mode = "heal",
		duration = 10
	}, {
		delay = 30,
		mode = "heal",
		duration = 10
	}, {
		delay = 120,
		mode = "heal",
		duration = 10
	}},
	iron_config = {
		golem_activate_delay = {50, 190, 270, 350, 370}
	},
	stun = {
		cooldown = 26,
		stun_duration = 3
	},
	heal = {
		heal_duration = 10,
		cooldown = 50,
		heal_min = 1,
		heal_every = 0.25,
		heal_max = 3
	},
	teleport = {
		max_targets = 4,
		nodes_advance = 25,
		aura_radius = 100,
		nodes_limit = 30,
		cooldown = 5,
		nodes_from_selectable = 30,
		nodes_to_goal_selectable = 80
	},
	sacrifice = {
		inactive_time = 20,
		waves = {5, 10, 15}
	}
}
tt.stun_bans = bor(F_ENEMY, F_HERO, F_FLYING)
tt.stun_flags = bor(F_FRIEND, F_MOD)
tt.stun_mod = "mod_stage_10_obelisk_stun"
tt.heal_bans = bor(F_FRIEND)
tt.heal_flags = bor(F_ENEMY, F_MOD)
tt.heal_mod = "mod_stage_10_obelisk_heal"
tt.teleport_bans = bor(F_FRIEND, F_FLYING)
tt.teleport_flags = bor(F_ENEMY, F_MOD)
tt.teleport_aura = "aura_stage_10_obelisk_teleport"
tt.bullet_golem_spawn = "bullet_stage_10_obelisk_priests"
tt.bullet_offset = v(0, 20)
tt.bullet_spawn_pos = {v(-71, 38), v(3, 3), v(71, 35)}
tt.golem_selected_paths = {4, 3, 1}
tt.golem_holder_pos = {v(310, 441), v(482, 345), v(328, 205)}
tt.golem_activate_holder = {"4", "9", "6"}
tt.golem_walk_pos = {v(375, 465), v(572, 392), v(381, 275)}
tt.template_golem = "enemy_crystal_golem"
tt.sacrifice_duration = 4
tt.sound_activation = "Stage10ObeliskActivation"
tt.sound_cast_stun = "Stage10ObeliskEffectStun"
tt.sound_cast_heal = "Stage10ObeliskEffectHealLoopStart"
tt.sound_heal_loop = "Stage10ObeliskEffectHealLoop"
tt.sound_change_mode = "Stage10ObeliskEffectChange"
tt.sound_cast_golem = "Stage10ObeliskEffectGolemSpawnCast"
tt.sound_cast_teleport = "EnemyVoidBlinkerTeleport"
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

tt = E:register_t_hot("decal_stage_10_mask", "decal", true)
tt.render.sprites[1].name = "T2_Stage_10_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

