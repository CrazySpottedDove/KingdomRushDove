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
