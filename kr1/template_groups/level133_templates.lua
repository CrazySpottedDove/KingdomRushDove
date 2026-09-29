local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
require("lib.klua.table")
local AC = require("achievements")
local scripts = require("scripts")
local v = V.v
local controller_stage_33_lightning_strike_update
local controller_stage_33_lightning_strike_editor_update
local controller_stage_33_house_doors_citizen_spawned
local controller_stage_33_house_doors_insert
local controller_stage_33_boat_update
local controller_stage_33_boat_on_event
local controller_stage33_envelops_update
local stage_33_spawner_update
controller_stage_33_lightning_strike_update = function(this, store)
	local level_mode_string = "CAMPAIGN"
	if store.level_mode == GAME_MODE_HEROIC then
		level_mode_string = "HEROIC"
	elseif store.level_mode == GAME_MODE_IRON then
		level_mode_string = "IRON"
	end
	if not this.areas_configs[level_mode_string] then
		simulation:queue_remove_entity(this)
		return
	end
	local waves_config_list = this.areas_configs[level_mode_string][tostring(this.area_id)]
	if not waves_config_list then
		simulation:queue_remove_entity(this)
		return
	end
	local strike_template = E:get_template("stage_33_lightning_strike")
	local vis_flags = strike_template.vis_flags
	local vis_bans = strike_template.vis_bans
	local strikes_spawn_radius = this.strikes_spawn_radius
	local previous_wave_index = store.wave_group_number
	local run_this_wave = false
	local casts = 0
	local next_ts = store.tick_ts
	local wave_config
	local wave_start_ts = store.tick_ts
	local wave_cfg_index = 1
	local delay_between_overlays = 10
	local overlay_ts = store.tick_ts
	while true do
		local current_wave_group_number_cache = store.wave_group_number
		if previous_wave_index ~= current_wave_group_number_cache then
			previous_wave_index = current_wave_group_number_cache
			wave_start_ts = store.tick_ts
			run_this_wave = false
			for wave_index, v in pairs(waves_config_list) do
				if current_wave_group_number_cache == wave_index then
					run_this_wave = true
					casts = 0
					wave_cfg_index = 1
					wave_config = v
					next_ts = wave_start_ts + wave_config[wave_cfg_index].first_cd
					break
				end
			end
		end
		if run_this_wave then
			local cfg = wave_config[wave_cfg_index]
			if casts >= cfg.max_casts then
				wave_cfg_index = wave_cfg_index + 1
				if wave_cfg_index > #wave_config then
					run_this_wave = false
				else
					casts = 0
					next_ts = wave_start_ts + wave_config[wave_cfg_index].first_cd
				end
			elseif next_ts <= store.tick_ts then
				casts = casts + 1
				next_ts = store.tick_ts + cfg.min_cd + (cfg.max_cd - cfg.min_cd) * math.random()
				local soldier_pos
				if math.random() < this.force_target_soldier_chance then
					local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, strikes_spawn_radius, vis_flags, vis_bans)
					if soldiers and #soldiers > 0 then
						soldier_pos = V.vclone(table.random(soldiers).pos)
					end
				end
				local first_strike_pos
				local current_chain = -1
				while current_chain < this.max_chains do
					current_chain = current_chain + 1
					local spawn_unit = wave_config[wave_cfg_index].spawn_unit
					local e = E:create_entity("stage_33_lightning_strike")
					if overlay_ts <= store.tick_ts then
						overlay_ts = store.tick_ts + delay_between_overlays * math.random()
						e.create_overlay = true
					end
					if current_chain == 0 then
						if soldier_pos then
							e.pos = V.vclone(soldier_pos)
						else
							e.pos.x = this.pos.x + math.random(-strikes_spawn_radius, strikes_spawn_radius)
							e.pos.y = this.pos.y + math.random(-strikes_spawn_radius, strikes_spawn_radius)
						end
						local nodes = P:nearest_nodes(e.pos.x, e.pos.y, nil, {1, 2, 3})
						if nodes and #nodes > 0 then
							local pi, spi, ni = unpack(nodes[1])
							if spawn_unit and spawn_unit == "enemy_storm_elemental" then
								spi = 1
							end
							local npos = P:node_pos(pi, spi, ni)
							e.pos = npos
						end
						first_strike_pos = V.vclone(e.pos)
					else
						e.pos.x = first_strike_pos.x + math.random(-40, 40)
						e.pos.y = first_strike_pos.y + math.random(-40, 40)
						e.start_delay = 0.2 * current_chain
					end
					if spawn_unit then
						e.spawn_unit = spawn_unit
					end
					simulation:queue_insert_entity(e)
					if math.random() >= this.chain_strikes_chance then
						break
					end
				end
			end
		end
		coroutine.yield()
	end
end
controller_stage_33_lightning_strike_editor_update = function(this, store)
	while true do
		this.render.sprites[1].scale = V.vv(this.strikes_spawn_radius / 50)
		coroutine.yield()
	end
end
controller_stage_33_house_doors_citizen_spawned = function(this, citizen, store)
	local nearest_door
	for _, v in pairs(this.doors_map) do
		local d = V.dist2(citizen.pos.x, citizen.pos.y, v.pos.x, v.pos.y)
		if not nearest_door or d < nearest_door.dist2 then
			nearest_door = {
				door = v,
				dist2 = d
			}
		end
	end
	if math.sqrt(nearest_door.dist2) < 50 then
		nearest_door.door:open_door(store)
		return true
	end
	return false
end
controller_stage_33_house_doors_insert = function(this, store)
	store.level.stage33_house_door_controller = this
	this.doors_map = {}
	for _, v in pairs(this.door_positions) do
		local e = E:create_entity(v.template)
		e.pos = V.vclone(v.pos)
		simulation:queue_insert_entity(e)
		table.insert(this.doors_map, e)
	end
	return true
end
controller_stage_33_boat_update = function(this, store)
	local boat_inside = false
	U.sprites_hide(this, nil, nil, false)
	while true do
		if this.activate then
			this.activate = nil
			U.y_wait_unconditional(store, 5)
			if not boat_inside then
				U.sprites_show(this, nil, nil, false)
				local boat_ended, vela_ended
				U.animation_start(this, "in", nil, store.tick_ts, false, this.render.sid_boat, true)
				U.animation_start(this, "in", nil, store.tick_ts, false, this.render.sid_sail, true)
				while true do
					if not boat_ended and U.animation_finished(this, this.render.sid_boat) then
						U.animation_start(this, "idle", nil, store.tick_ts, true, this.render.sid_boat, true)
						boat_ended = true
					end
					if not vela_ended and U.animation_finished(this, this.render.sid_sail) then
						U.animation_start(this, "idle", nil, store.tick_ts, true, this.render.sid_sail, true)
						vela_ended = true
					end
					if boat_ended and vela_ended then
						break
					end
					coroutine.yield()
				end
				boat_inside = true
			else
				this.render.sprites[this.render.sid_sail].hidden = true
				U.y_animation_play(this, "out", nil, store.tick_ts, 1, this.render.sid_boat)
				U.sprites_hide(this, nil, nil, false)
				boat_inside = false
			end
		end
		coroutine.yield()
	end
end
controller_stage_33_boat_on_event = function(this, store, action)
	this.activate = true
	for _, v in pairs(store.entities) do
		if v.template_name == "controller_stage_33_tambor" then
			v:do_tambor()
			break
		end
	end
end
controller_stage33_envelops_update = function(this, store)
	store.level.envelops_opened = 0
	local spawn_points = {}
	for _, e in pairs(store.entities) do
		if e.template_name == this.envelop_spawn_pos_t then
			table.insert(spawn_points, V.vclone(e.pos))
			simulation:queue_remove_entity(e)
		end
	end
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	while true do
		local wait_time = this.cooldown_min + (this.cooldown_max - this.cooldown_min) * math.random()
		U.y_wait_unconditional(store, wait_time)
		local envelop
		if math.random() < this.decoy_chance then
			envelop = E:create_entity(this.decoy_t)
		else
			envelop = E:create_entity(this.envelop_t)
		end
		envelop.pos = V.vclone(table.random(spawn_points))
		simulation:queue_insert_entity(envelop)
	end
end
stage_33_spawner_update = function(this, store)
	local sp = this.spawner
	while true do
		if sp.interrupt then
		elseif sp.spawn_data then
			local enable = sp.spawn_data.enable
			if enable then
				sp.spawn_data.enable = false
			end
		end
		sp.interrupt = nil
		coroutine.yield()
	end
	simulation:queue_remove_entity(this)
end
local tt
local S = require("sound_db")
local signal = require("lib.hump.signal")
local function fts(v)
	return v / FPS
end

local controller_stage_33_ciclone = {}

function controller_stage_33_ciclone.update(this, store)
	local this_render = this.render
	local this_sprites = this_render.sprites
	local sid_clouds_der = this_render.sid_clouds_der
	local sid_clouds_izq = this_render.sid_clouds_izq
	local sid_clouds_fly = this_render.sid_clouds_fly
	local sid_shadows_fly = this_render.sid_shadows_fly
	local sid_shadow = this_render.sid_shadow
	local sid_shadow_2 = this_render.sid_shadow_2
	local sid_tejas_puerta = this_render.sid_tejas_puerta
	local sid_storm_rayos = this_render.sid_storm_rayos
	local sid_escombros = this_render.sid_escombros
	local new_path_thunders_list = {{
		delay = 0.7,
		pos = v(647, 362)
	}, {
		delay = 1.3,
		pos = v(589, 442)
	}, {
		delay = 1.8,
		pos = v(638, 505)
	}, {
		delay = 5,
		spawn_unit = "enemy_storm_elemental",
		spawn_unit_animation = "raise",
		pos = v(605, 600)
	}}

	local function create_pre_destroy_thunders(store)
		for _, t in pairs(new_path_thunders_list) do
			local e = E:create_entity("stage_33_lightning_strike")

			e.pos = V.vclone(t.pos)
			e.start_delay = t.delay

			if t.spawn_unit then
				e.spawn_unit = t.spawn_unit
			end

			if t.spawn_unit_animation then
				e.spawn_unit_animation = t.spawn_unit_animation
			end

			simulation:queue_insert_entity(e)
		end
	end

	local function fade_sprite(store, sprite_id, duration, fade_init, fade_end, id, clear_props)
		duration = duration or 2

		if not this.tween then
			this.tween = E:clone_c("tween")
			this.tween.remove = false
		end

		if clear_props then
			this.tween.props = {}
		end

		-- TODO: 修复 tween
		local p = E:clone_c("tween_prop")

		p.keys = {{0, fade_init}, {duration, fade_end}}
		p.sprite_id = sprite_id
		p.ts = store.tick_ts
		this.tween.props[id] = p
	end

	U.sprites_hide(this, nil, nil, false)

	local ciclone_in = false
	local hidden_tejas = 10
	local distant_thunders_ts = 0

	while true do
		if this.activate then
			local houses_templates = {}
			local new_path = this.activate_new_path
			local cinematic = this.activate_cinematic
			local action = this.activate_action

			if this.activate_houses then
				for _, house_id in ipairs(this.activate_houses) do
					table.insert(houses_templates, "tower_holder_blocked_stage_33_house_" .. house_id)
				end
			end

			local houses = {}

			for _, e in pairs(store.entities) do
				if table.contains(houses_templates, e.template_name) then
					table.insert(houses, e)
				end
			end

			this.activate = nil

			if action == "in" then
				this_sprites[sid_clouds_der].hidden = false
				this_sprites[sid_clouds_izq].hidden = false
				this_sprites[sid_shadow].hidden = false
				this_sprites[sid_shadow_2].hidden = false
				this_sprites[sid_clouds_fly].hidden = false
				this_sprites[sid_shadows_fly].hidden = false
				this_sprites[sid_storm_rayos].hidden = false

				fade_sprite(store, sid_shadow, fts(21), 0, 255, 1, true)
				fade_sprite(store, sid_shadow_2, fts(21), 0, 255, 2, false)
				fade_sprite(store, sid_clouds_fly, fts(21), 0, 255, 3, false)
				fade_sprite(store, sid_shadows_fly, fts(21), 0, 255, 4, false)
				S:queue("Stage33StormStart")
				U.animation_start(this, "in", nil, store.tick_ts, false, sid_clouds_der)
				U.y_animation_play(this, "in", nil, store.tick_ts, false, sid_clouds_izq)
				U.animation_start(this, "in", nil, store.tick_ts, false, sid_storm_rayos)
				S:queue("Stage33StormLoop")
				U.sprites_show(this, nil, hidden_tejas, false)
				U.animation_start_group(this, "idle", nil, store.tick_ts, true, "layers")
				U.animation_start(this, "loop", nil, store.tick_ts, true, sid_shadow_2)

				ciclone_in = true
				distant_thunders_ts = store.tick_ts + math.random(3, 5)
			elseif action == "destroy_houses" then
				U.y_wait_unconditional(store, 1)

				local camera_posX, camera_posY, zoom_value

				if cinematic then
					signal.emit("show-curtains")
					signal.emit("hide-gui")
					signal.emit("start-cinematic")

				--camera_posX = game.camera.x / game.game_scale
				--camera_posY = game.ref_h - game.camera.y / game.game_scale
				--zoom_value = game.camera.zoom
				end

				for h_index, house in ipairs(houses) do
					if cinematic then
						signal.emit("pan-zoom-camera", h_index == 1 and 1 or 2, {
							x = house.pos.x,
							y = house.pos.y + 50
						}, 1.5)
						house:pre_destroy_thunders(store)
					end

					U.y_wait_unconditional(store, 3)
					house:destroy_house(store)
				end

				if new_path then
					if cinematic then
						signal.emit("pan-zoom-camera", 2, {
							x = 613,
							y = 800
						}, 1.5)
						create_pre_destroy_thunders(store)
					end

					U.y_wait_unconditional(store, 3)

					this_sprites[sid_tejas_puerta].hidden = true
					hidden_tejas = hidden_tejas - 1
					this_sprites[sid_escombros].hidden = false

					U.animation_start(this, "in", nil, store.tick_ts, false, sid_escombros)
					store.level.open_middle_path(store)
					U.animation_start(this, "idle", nil, store.tick_ts, true, sid_escombros)
					U.y_wait_unconditional(store, 1)
				end

				U.y_wait_unconditional(store, 1.5)

				if cinematic then
					signal.emit("pan-zoom-camera", 1, {
						x = camera_posX,
						y = camera_posY
					}, zoom_value)
				end

				U.y_wait_unconditional(store, 2)

				if cinematic then
					signal.emit("hide-curtains")
					signal.emit("show-gui")
					signal.emit("end-cinematic")
					U.y_wait_unconditional(store, 1)
					signal.emit("ciclone_end")
				end
			else
				ciclone_in = false

				U.y_wait_unconditional(store, 1)
				S:stop("Stage33StormLoop")
				U.sprites_hide(this, nil, hidden_tejas, false)

				this_sprites[sid_clouds_der].hidden = false
				this_sprites[sid_clouds_izq].hidden = false
				this_sprites[sid_shadow].hidden = false
				this_sprites[sid_shadow_2].hidden = false
				this_sprites[sid_clouds_fly].hidden = false
				this_sprites[sid_shadows_fly].hidden = false
				this_sprites[sid_storm_rayos].hidden = false

				fade_sprite(store, sid_shadow, fts(21), 255, 0, 1, true)
				fade_sprite(store, sid_shadow_2, fts(21), 255, 0, 2, false)
				fade_sprite(store, sid_clouds_fly, fts(21), 255, 0, 3, false)
				fade_sprite(store, sid_shadows_fly, fts(21), 255, 0, 4, false)
				U.animation_start(this, "out", nil, store.tick_ts, false, sid_clouds_der)
				U.y_animation_play(this, "out", nil, store.tick_ts, false, sid_clouds_izq)
				U.animation_start(this, "out", nil, store.tick_ts, false, sid_storm_rayos)

				this_sprites[sid_clouds_der].hidden = true
				this_sprites[sid_clouds_izq].hidden = true
				this_sprites[sid_shadow].hidden = true
				this_sprites[sid_shadow_2].hidden = true
				this_sprites[sid_clouds_fly].hidden = true
				this_sprites[sid_shadows_fly].hidden = true
				this_sprites[sid_storm_rayos].hidden = true
			end
		elseif ciclone_in and distant_thunders_ts < store.tick_ts then
			distant_thunders_ts = store.tick_ts + math.random(3, 5)

			S:queue("Stage33StormDistantThunder")
		end

		coroutine.yield()
	end
end

function controller_stage_33_ciclone.on_event(this, store, action, houses, cinematic, mode, new_path)
	this.activate = true
	this.activate_action = tostring(mode)
	this.activate_new_path = false

	if new_path and new_path ~= "" then
		this.activate_new_path = new_path
	end

	this.activate_cinematic = false

	if cinematic and cinematic ~= "" then
		this.activate_cinematic = tonumber(cinematic) > 0
	end

	this.activate_houses = {}

	if houses and houses ~= "" then
		local houses_var = houses and tostring(houses) or ""

		for i = 1, #houses_var do
			table.insert(this.activate_houses, tonumber(houses_var:sub(i, i)))
		end
	end
end

local controller_stage_33_tambor = {}

function controller_stage_33_tambor.do_tambor(this)
	this.activate = true
end

function controller_stage_33_tambor.update(this, store)
	U.animation_start_group(this, "idle_tambor", nil, store.tick_ts, true, "group")

	local is_in = false

	while true do
		if this.activate then
			this.activate = nil

			if is_in then
				is_in = false

				S:stop("Stage33BoatDrumLoop")
				U.y_animation_play_group(this, "out", nil, store.tick_ts, 1, "group")
				U.animation_start_group(this, "idle_tambor", nil, store.tick_ts, true, "group")
			else
				is_in = true

				U.y_animation_play_group(this, "in", nil, store.tick_ts, 1, "group")
				S:queue("Stage33BoatDrumLoop")
				U.animation_start_group(this, "loop", nil, store.tick_ts, true, "group")
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("stage_33_mask_1", "decal", true)
tt.render.sprites[1].name = "stage33_mask_1_casa_grande"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.pos = v(512, 384)
tt.render.sprites[1].sort_y_offset = 550 - tt.pos.y

tt = E:register_t_hot("stage_33_mask_1_destroyed", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage 33_mask_intersection"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("stage_33_mask_4", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_4_plataforma"
tt.render.sprites[1].sort_y_offset = 371 - tt.pos.y

tt = E:register_t_hot("controller_stage_33_lightning_strike", nil, true)
E:add_comps(tt, "pos", "main_script", "editor", "editor_script")
tt.main_script.update = controller_stage_33_lightning_strike_update
tt.force_target_soldier_chance = 0.2
tt.chain_strikes_chance = 0
tt.max_chains = 2
tt.areas_configs = {
	CAMPAIGN = {
		["1"] = {
			[5] = {{
				max_casts = 10,
				first_cd = 1,
				max_cd = 6,
				min_cd = 4.5
			}},
			[6] = {{
				max_casts = 15,
				first_cd = 3,
				max_cd = 5.5,
				min_cd = 4
			}},
			[8] = {{
				max_casts = 4,
				first_cd = 3,
				max_cd = 5,
				min_cd = 4
			}},
			[10] = {{
				max_casts = 15,
				first_cd = 5,
				max_cd = 5,
				min_cd = 4
			}},
			[11] = {{
				max_casts = 10,
				first_cd = 15,
				max_cd = 7,
				min_cd = 5
			}},
			[13] = {{
				max_casts = 40,
				first_cd = 5,
				max_cd = 3.5,
				min_cd = 3
			}},
			[15] = {{
				max_casts = 75,
				first_cd = 1,
				max_cd = 4,
				min_cd = 3.75
			}}
		},
		["10"] = {},
		["2"] = {
			[6] = {{
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 10,
				max_casts = 6,
				max_cd = 3,
				min_cd = 2
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 42,
				max_casts = 6,
				max_cd = 3,
				min_cd = 2
			}},
			[8] = {{
				max_casts = 8,
				first_cd = 1,
				max_cd = 4,
				min_cd = 2
			}},
			[9] = {{
				max_casts = 11,
				first_cd = 2,
				max_cd = 6,
				min_cd = 5
			}},
			[11] = {{
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 48.5,
				max_casts = 6,
				max_cd = 3,
				min_cd = 2.5
			}},
			[13] = {{
				max_casts = 10,
				first_cd = 2,
				max_cd = 1.5,
				min_cd = 1
			}, {
				max_casts = 20,
				first_cd = 70,
				max_cd = 1.25,
				min_cd = 0.75
			}},
			[15] = {{
				spawn_unit = "enemy_storm_elemental",
				first_cd = 6.5,
				max_casts = 1,
				max_cd = 1,
				min_cd = 1
			}, {
				spawn_unit = "enemy_storm_elemental",
				first_cd = 52,
				max_casts = 1,
				max_cd = 12,
				min_cd = 10
			}}
		},
		["3"] = {
			[9] = {{
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 6,
				max_casts = 7,
				max_cd = 1.5,
				min_cd = 1
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 70,
				max_casts = 7,
				max_cd = 1.5,
				min_cd = 1
			}},
			[11] = {{
				max_casts = 6,
				first_cd = 3,
				max_cd = 8,
				min_cd = 6
			}},
			[13] = {{
				max_casts = 10,
				first_cd = 10,
				max_cd = 1.25,
				min_cd = 0.75
			}, {
				spawn_unit = "enemy_storm_elemental",
				first_cd = 25,
				max_casts = 2,
				max_cd = 23,
				min_cd = 23
			}},
			[15] = {{
				max_casts = 1e+99,
				first_cd = 1,
				max_cd = 4,
				min_cd = 3
			}}
		},
		["4"] = {
			[9] = {{
				max_casts = 11,
				first_cd = 5,
				max_cd = 6,
				min_cd = 5
			}},
			[11] = {{
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 4,
				max_casts = 8,
				max_cd = 3,
				min_cd = 2
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 50,
				max_casts = 6,
				max_cd = 3,
				min_cd = 2.5
			}},
			[15] = {{
				spawn_unit = "enemy_storm_elemental",
				first_cd = 8,
				max_casts = 1,
				max_cd = 12,
				min_cd = 10
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 22,
				max_casts = 6,
				max_cd = 1.25,
				min_cd = 1
			}, {
				spawn_unit = "enemy_storm_elemental",
				first_cd = 50,
				max_casts = 1,
				max_cd = 12,
				min_cd = 10
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 63,
				max_casts = 8,
				max_cd = 0.75,
				min_cd = 0.5
			}}
		},
		["5"] = {
			[13] = {{
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 5,
				max_casts = 8,
				max_cd = 1.5,
				min_cd = 1
			}, {
				spawn_unit = "enemy_water_spirit_spawnless",
				first_cd = 34,
				max_casts = 8,
				max_cd = 1.5,
				min_cd = 1
			}}
		},
		["6"] = {
			[10] = {{
				max_casts = 3,
				first_cd = 3,
				max_cd = 1,
				min_cd = 0.75
			}, {
				spawn_unit = "enemy_storm_elemental",
				first_cd = 39,
				max_casts = 1,
				max_cd = 1,
				min_cd = 0.75
			}},
			[13] = {{
				max_casts = 10,
				first_cd = 13,
				max_cd = 1.25,
				min_cd = 0.75
			}},
			[15] = {{
				spawn_unit = "enemy_storm_elemental",
				first_cd = 5,
				max_casts = 1,
				max_cd = 12,
				min_cd = 10
			}, {
				spawn_unit = "enemy_storm_elemental",
				first_cd = 54,
				max_casts = 1,
				max_cd = 12,
				min_cd = 10
			}, {
				max_casts = 11,
				first_cd = 60,
				max_cd = 6,
				min_cd = 5
			}}
		},
		["7"] = {
			[15] = {{
				max_casts = 10,
				first_cd = 6,
				max_cd = 5,
				min_cd = 4
			}}
		},
		["8"] = {}
	},
	HEROIC = {},
	IRON = {
		["1"] = {{{
			max_casts = 1e+99,
			first_cd = 169,
			max_cd = 7,
			min_cd = 4
		}}},
		["2"] = {{{
			max_casts = 10,
			first_cd = 171,
			max_cd = 5,
			min_cd = 4
		}, {
			spawn_unit = "enemy_water_spirit_spawnless",
			first_cd = 225,
			max_casts = 10,
			max_cd = 2,
			min_cd = 1.5
		}}},
		["3"] = {{{
			spawn_unit = "enemy_storm_elemental",
			first_cd = 174,
			max_casts = 1,
			max_cd = 1,
			min_cd = 1
		}, {
			max_casts = 1e+99,
			first_cd = 176,
			max_cd = 8,
			min_cd = 5
		}}},
		["4"] = {{{
			max_casts = 6,
			first_cd = 172.5,
			max_cd = 7,
			min_cd = 4
		}, {
			spawn_unit = "enemy_water_spirit_spawnless",
			first_cd = 212,
			max_casts = 7,
			max_cd = 2.5,
			min_cd = 2
		}}}
	}
}
tt.strikes_spawn_radius = 100
tt.area_id = 1
tt.editor.components = {"render", "texts"}
tt.editor.overrides = {
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_cyan_circle"
}
tt.editor.props = {{"strikes_spawn_radius", PT_NUMBER}, {"area_id", PT_NUMBER}}
tt.editor_script.update = controller_stage_33_lightning_strike_editor_update

tt = E:register_t_hot("stage_33_mask_water_big", "decal", true)
tt.render.sprites[1].prefix = "stage_33_olas_grandesDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND - 2

tt = E:register_t_hot("stage_33_mask_6", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_6_casita"
tt.render.sprites[1].sort_y_offset = 374 - tt.pos.y

tt = E:register_t_hot("stage_33_mask_8", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_8_casitas"
tt.render.sprites[1].sort_y_offset = 530 - tt.pos.y

tt = E:register_t_hot("controller_stage33_envelops", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage33_envelops_update
tt.envelop_t = "decal_stage33_envelop"
tt.decoy_t = "decal_stage33_envelop_decoy"
tt.envelop_spawn_pos_t = "decal_stage33_envelop_spawn_pos"
tt.decoy_chance = 0.5
tt.cooldown_min = 20
tt.cooldown_max = 40

tt = E:register_t_hot("stage_33_mask_2", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_2_casita"
tt.render.sprites[1].sort_y_offset = 581 - tt.pos.y

tt = E:register_t_hot("stage_33_mask_3", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_3_casita"
tt.render.sprites[1].sort_y_offset = 544 - tt.pos.y

tt = E:register_t_hot("controller_stage_33_boat", "decal_scripted", true)
tt.main_script.update = controller_stage_33_boat_update
E:add_comps(tt, "events")
tt.render.sid_boat = 1
tt.render.sid_sail = 2
tt.render.sprites[tt.render.sid_boat].prefix = "stage_3_barcoDef"
tt.render.sprites[tt.render.sid_boat].exo = true
tt.render.sprites[tt.render.sid_boat].name = "idle"
tt.render.sprites[tt.render.sid_boat].z = Z_DECALS
tt.render.sprites[tt.render.sid_boat].hidden = true
tt.render.sprites[tt.render.sid_sail] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_sail].prefix = "stage_3_barco_velaDef"
tt.render.sprites[tt.render.sid_sail].exo = true
tt.render.sprites[tt.render.sid_sail].name = "idle"
tt.render.sprites[tt.render.sid_sail].z = Z_DECALS
tt.events.list[1].name = "boat"
tt.events.list[1].on_event = controller_stage_33_boat_on_event

tt = E:register_t_hot("controller_stage_33_house_doors", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.insert = controller_stage_33_house_doors_insert
tt.citizen_spawned = controller_stage_33_house_doors_citizen_spawned
tt.door_positions = {{
	template = "stage_33_citizen_house_1",
	pos = v(72, 348)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(197, 348)
}, {
	template = "stage_33_citizen_house_1",
	pos = v(235, 693)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(387, 693)
}, {
	template = "stage_33_citizen_house_1",
	pos = v(799, 692)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(925, 696)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(1030, 348)
}}

tt = E:register_t_hot("stage_33_mask_9", "stage_33_mask_1", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage33_mask_9_modos_relleno_holders"
tt.render.sprites[1].sort_y_offset = 450 - tt.pos.y

tt = E:register_t_hot("stage_33_spawner", nil, true)
E:add_comps(tt, "main_script", "spawner")
tt.main_script.update = stage_33_spawner_update
tt.spawner.eternal = true

tt = E:register_t_hot("stage_33_mask_7", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_7_casita"
tt.render.sprites[1].sort_y_offset = 374 - tt.pos.y

tt = E:register_t_hot("stage_33_mask_5", "stage_33_mask_1", true)
tt.render.sprites[1].name = "stage33_mask_5_carpa"
tt.render.sprites[1].sort_y_offset = 365 - tt.pos.y

tt = E:register_t_hot("stage_33_mask_water_small", "decal", true)
tt.render.sprites[1].prefix = "stage_33_olas_chicasDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND - 1

tt = E:register_t_hot("decal_stage33_envelop_spawn_pos", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "envelops_envelop_water_idle"
tt.render.sprites[1].hidden = true
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false
}

tt = E:register_t_hot("controller_stage_33_ciclone", "decal_scripted", true)
E:add_comps(tt, "editor", "ui", "events")
tt.main_script.update = controller_stage_33_ciclone.update
tt.render.sid_tejas = 1
tt.render.sid_dirty = 2
tt.render.sid_shadow = 3
tt.render.sid_clouds_der = 4
tt.render.sid_clouds_izq = 5
tt.render.sid_shadow_2 = 6
tt.render.sid_clouds_fly = 7
tt.render.sid_shadows_fly = 8
tt.render.sid_storm_rayos = 9
tt.render.sid_tejas_puerta = 10
tt.render.sid_escombros = 11
tt.render.sprites[tt.render.sid_tejas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_tejas].prefix = "stage_33_tejasDef"
tt.render.sprites[tt.render.sid_tejas].exo = true
tt.render.sprites[tt.render.sid_tejas].name = "idle"
tt.render.sprites[tt.render.sid_tejas].z = Z_OBJECTS_COVERS
tt.render.sprites[tt.render.sid_tejas].group = "layers"
tt.render.sprites[tt.render.sid_tejas_puerta] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_tejas_puerta].prefix = "stage_33_tejas_puertaDef"
tt.render.sprites[tt.render.sid_tejas_puerta].exo = true
tt.render.sprites[tt.render.sid_tejas_puerta].name = "idle"
tt.render.sprites[tt.render.sid_tejas_puerta].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_dirty] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dirty].prefix = "stage_33_dirtyDef"
tt.render.sprites[tt.render.sid_dirty].exo = true
tt.render.sprites[tt.render.sid_dirty].name = "idle"
tt.render.sprites[tt.render.sid_dirty].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_dirty].group = "layers"
tt.render.sprites[tt.render.sid_shadow] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow].prefix = "stage_33_shadow_screenDef"
tt.render.sprites[tt.render.sid_shadow].exo = true
tt.render.sprites[tt.render.sid_shadow].name = "idle"
tt.render.sprites[tt.render.sid_shadow].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_shadow].group = "layers"
tt.render.sprites[tt.render.sid_shadows_fly] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadows_fly].prefix = "stage_33_shadows_flyDef"
tt.render.sprites[tt.render.sid_shadows_fly].exo = true
tt.render.sprites[tt.render.sid_shadows_fly].name = "idle"
tt.render.sprites[tt.render.sid_shadows_fly].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_der] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_der].prefix = "stage_33_storm_clouds_derDef"
tt.render.sprites[tt.render.sid_clouds_der].exo = true
tt.render.sprites[tt.render.sid_clouds_der].name = "in"
tt.render.sprites[tt.render.sid_clouds_der].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_der].group = "layers"
tt.render.sprites[tt.render.sid_clouds_izq] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_izq].prefix = "stage_33_storm_clouds_izqDef"
tt.render.sprites[tt.render.sid_clouds_izq].exo = true
tt.render.sprites[tt.render.sid_clouds_izq].name = "in"
tt.render.sprites[tt.render.sid_clouds_izq].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_izq].group = "layers"
tt.render.sprites[tt.render.sid_storm_rayos] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_storm_rayos].prefix = "stage_33_storm_rayosDef"
tt.render.sprites[tt.render.sid_storm_rayos].exo = true
tt.render.sprites[tt.render.sid_storm_rayos].name = "in"
tt.render.sprites[tt.render.sid_storm_rayos].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_storm_rayos].group = "layers"
tt.render.sprites[tt.render.sid_clouds_fly] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_fly].prefix = "stage_33_clouds_flyDef"
tt.render.sprites[tt.render.sid_clouds_fly].exo = true
tt.render.sprites[tt.render.sid_clouds_fly].name = "idle"
tt.render.sprites[tt.render.sid_clouds_fly].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_fly].group = "layers"
tt.render.sprites[tt.render.sid_shadow_2] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow_2].prefix = "stage_33_storm_shadowDef"
tt.render.sprites[tt.render.sid_shadow_2].exo = true
tt.render.sprites[tt.render.sid_shadow_2].name = "loop"
tt.render.sprites[tt.render.sid_shadow_2].z = Z_OBJECTS_SKY + 1
tt.render.sprites[tt.render.sid_escombros] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_escombros].prefix = "stage33_explosion_escombrosDef"
tt.render.sprites[tt.render.sid_escombros].exo = true
tt.render.sprites[tt.render.sid_escombros].name = "idle"
tt.render.sprites[tt.render.sid_escombros].z = Z_DECALS
tt.render.sprites[tt.render.sid_escombros].hidden = true
tt.events.list[1].name = "ciclone"
tt.events.list[1].on_event = controller_stage_33_ciclone.on_event

tt = E:register_t_hot("controller_stage_33_tambor", "decal_scripted", true)
tt.do_tambor = controller_stage_33_tambor.do_tambor
tt.main_script.update = controller_stage_33_tambor.update
tt.render.sprites[1].prefix = "stage_33_barco_call_tambor"
tt.render.sprites[1].name = "idle_tambor"
tt.render.sprites[1].anchor = v(0.05777310924369748, 0.55625)
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].group = "group"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_33_barco_call_body"
tt.render.sprites[2].anchor = v(0.11346863468634687, 0.5290697674418605)
tt.render.sprites[2].sort_y_offset = -49

tt = E:register_t_hot("stage_33_mask_props", "decal", true)
tt.render.sprites[1].prefix = "stage_33_anim_propsDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

