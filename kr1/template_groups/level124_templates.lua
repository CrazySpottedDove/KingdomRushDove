local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local r = V.r
local decal_stage_24_gears_update
local decal_stage_24_bubble_update
local decal_stage_24_upgrade_station_update
local decal_stage_24_modes_decos_update
decal_stage_24_gears_update = function(this, store)
	local start_ts = store.tick_ts
	local pause_ts
	local s = this.render.sprites[1]
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			if pause_ts then
				start_ts = store.tick_ts - (pause_ts - start_ts)
				pause_ts = nil
			else
				pause_ts = store.tick_ts
			end
		end
		if pause_ts then
			s.ts = store.tick_ts - (pause_ts - start_ts)
		end
		coroutine.yield()
	end
end
decal_stage_24_bubble_update = function(this, store)
	local cd = math.random(3, 7)
	while true do
		U.y_wait_unconditional(store, cd)
		this.render.sprites[1].hidden = false
		U.y_animation_play(this, "run", nil, store.tick_ts)
		this.render.sprites[1].hidden = true
		cd = math.random(3, 7)
	end
end
decal_stage_24_upgrade_station_update = function(this, store)
	while store.wave_group_number == 0 do
		coroutine.yield()
	end
	local last_wave = 0
	local start_wave_ts = store.tick_ts
	local last_index_processed = 0
	local function get_wave_data_index(current_wave_data)
		for index, wave_data in ipairs(current_wave_data) do
			if index > last_index_processed and wave_data.time_start + wave_data.duration > store.tick_ts - start_wave_ts then
				return index
			end
		end
		return nil
	end
	local function check_close()
		if this.render.sprites[1].name == "idleopen" then
			S:queue(this.sound_close)
			U.y_animation_play(this, "close", nil, store.tick_ts, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end
	end
	while true do
		local current_wave = store.wave_group_number
		local current_wave_data = this.wave_config[store.level_mode][current_wave]
		if current_wave ~= last_wave then
			last_wave = current_wave
			start_wave_ts = store.tick_ts
			last_index_processed = 0
		end
		if current_wave_data and #current_wave_data > 0 then
			local next_index_to_check = get_wave_data_index(current_wave_data)
			if next_index_to_check and next_index_to_check ~= last_index_processed then
				local wave_data = current_wave_data[next_index_to_check]
				if store.tick_ts - start_wave_ts >= wave_data.time_start then
					if this.render.sprites[1].name == "idle" then
						S:queue(this.sound_open)
						U.y_animation_play(this, "open", nil, store.tick_ts, 1)
					end
					U.animation_start_default(this, "idleopen", nil, store.tick_ts, true)
					while store.tick_ts - start_wave_ts < wave_data.time_start + wave_data.duration do
						local hammerer, enemies = U.find_nearest_enemy(store.entities, this.pos, 0, 200, 0, 0, function(e)
							return e.template_name == this.hammerer_t and e.nav_path.pi == 2 and e.nav_path.ni > 50 and e.nav_path.ni < 56
						end)
						if not hammerer or #enemies == 0 then
							U.y_wait_unconditional(store, 0.3)
						else
							local original_path = hammerer.nav_path.pi
							hammerer.nav_path.pi = this.path_in
							U.bans_add(hammerer.vis, F_POLYMORPH)
							if not hammerer.enemy.counts.mod_teleport then
								hammerer.enemy.counts.mod_teleport = 0
							end
							local start_tel_count = hammerer.enemy.counts.mod_teleport
							while hammerer and P:nodes_to_goal(hammerer.nav_path.pi, hammerer.nav_path.spi, hammerer.nav_path.ni) > 1 do
								if not hammerer or hammerer.health.dead then
									goto label_1580_0
								end
								if start_tel_count < hammerer.enemy.counts.mod_teleport then
									hammerer.nav_path.pi = original_path
									U.bans_remove(hammerer.vis, F_POLYMORPH)
									goto label_1580_0
								end
								coroutine.yield()
							end
							if not hammerer or hammerer.health.dead then
							else
								simulation:queue_remove_entity(hammerer)
								S:queue(this.sound_transform)
								U.y_animation_play(this, "convertstart", nil, store.tick_ts, 1)
								U.y_animation_play(this, "convertloop", nil, store.tick_ts, 3)
								U.animation_start_default(this, "convertend", nil, store.tick_ts, false)
								U.y_wait_unconditional(store, fts(10))
								local fist = E:create_entity(this.fist_t)
								fist.pos = P:node_pos(this.path_out, 1, 1)
								fist.nav_path.pi = this.path_out
								fist.source_id = this.id
								simulation:queue_insert_entity(fist)
								U.y_animation_wait_default(this)
								U.animation_start_default(this, "idleopen", nil, store.tick_ts, true)
							end
						end
						::label_1580_0::
						coroutine.yield()
					end
					last_index_processed = next_index_to_check
				else
					check_close()
				end
			end
		else
			check_close()
		end
		coroutine.yield()
	end
end
decal_stage_24_modes_decos_update = function(this, store)
	local cd = math.random(3, 7)
	while true do
		U.y_wait_unconditional(store, cd)
		if math.random(1, 2) == 1 then
			U.y_animation_play(this, "chispas1", nil, store.tick_ts)
		else
			U.y_animation_play(this, "chispas2", nil, store.tick_ts)
		end
		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		cd = math.random(3, 7)
	end
end
local tt
local decal_stage_24_elevator
local decal_stage_24_factory
local decal_stage_24_factory_sparks
local km = require("lib.klua.macros")
local LU = require("level_utils")
decal_stage_24_elevator = {}

function decal_stage_24_elevator.update(this, store)
	local mask_door

	for i, v in pairs(store.entities) do
		if v.template_name == "decal_stage_24_mask_4" then
			mask_door = v
		end
	end

	while true do
		if this.go_up then
			this.go_up = false

			S:queue(this.sound_machinist_in)
			U.y_animation_play(this, "open", nil, store.tick_ts, 1)
			U.animation_start_default(this, "idleopen", nil, store.tick_ts, true)

			mask_door.render.sprites[1].hidden = false
		end

		if this.go_down then
			this.go_down = false
			mask_door.render.sprites[1].hidden = true

			S:queue(this.sound_machinist_out)
			U.y_animation_play(this, "close", nil, store.tick_ts, 1)
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

decal_stage_24_factory = {}

function decal_stage_24_factory.update(this, store)
	local spawners = LU.list_entities(store.entities, "mega_spawner")
	local megaspawner_door

	this.wave_counter = 0

	local conveyor_belt, factory_gate_mask
	local sp = this.spawner

	for key, value in pairs(spawners) do
		if value.load_file == "level124_factory" then
			megaspawner_door = value
		end
	end

	for i, v in pairs(store.entities) do
		if v.template_name == "decal_stage_24_factory_conveyor_belt" then
			conveyor_belt = v
		end

		if v.template_name == "decal_stage_24_mask_6" then
			factory_gate_mask = v
		end
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while true do
			if this.open then
				this.open = false

				U.y_animation_play(this, "loop", nil, store.tick_ts, 5)

				conveyor_belt.render.sprites[1].hidden = false

				S:queue(this.sound_factory_turn_on_end)
				U.animation_start_default(this, "in", nil, store.tick_ts, false)
				U.y_animation_play(conveyor_belt, "in", nil, store.tick_ts, 1)
				S:queue(this.sound_conveyor_belt_loop)
				U.animation_start_default(this, "activeloop", nil, store.tick_ts, true)
				U.animation_start(conveyor_belt, "activeloop", nil, store.tickts, true)

				factory_gate_mask.render.sprites[1].hidden = false
				megaspawner_door.manual_wave = "DOOR" .. this.wave_counter

				while not sp.spawn_data or not sp.spawn_data.close or this.bossfight do
					coroutine.yield()
				end

				sp.spawn_data.close = nil
				factory_gate_mask.render.sprites[1].hidden = true

				S:stop(this.sound_conveyor_belt_loop)
				S:queue(this.sound_factory_turn_off)
				U.y_animation_play(conveyor_belt, "out", nil, store.tick_ts, 1)

				conveyor_belt.render.sprites[1].hidden = true

				U.y_animation_play(this, "out", nil, store.tick_ts, 1)
				U.y_animation_play(this, "loop", nil, store.tick_ts, 2)
				U.y_animation_play(this, "startup", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", nil, store.tick_ts, true)
			end

			coroutine.yield()
		end
	else
		U.animation_start_default(this, "activeloop", nil, store.tick_ts, true)
		U.animation_start(conveyor_belt, "activeloop", nil, store.tickts, true)

		conveyor_belt.render.sprites[1].hidden = false
		factory_gate_mask.render.sprites[1].hidden = false
	end
end

decal_stage_24_factory_sparks = {}

function decal_stage_24_factory_sparks.update(this, store)
	while true do
		if this.play then
			this.play = false
			this.render.sprites[1].hidden = false
			this.render.sprites[1].r = km.deg2rad(math.random(-30, 30))

			U.y_animation_play(this, "run", math.random(0, 1) == 1, store.tick_ts, 1)

			this.render.sprites[1].hidden = true
		end

		coroutine.yield()
	end
end

local signal = require("lib.hump.signal")
local function fts(v)
	return v / FPS
end

local controller_stage_24_machinist = {}

function controller_stage_24_machinist.update(this, store)
	local factory, elevator

	for i, v in pairs(store.entities) do
		if v.template_name == "decal_stage_24_factory" then
			factory = v
		end

		if v.template_name == "decal_stage_24_elevator" then
			elevator = v
		end
	end

	local kept_factory_closed = true

	while store.wave_group_number == 0 do
		coroutine.yield()
	end

	local last_wave = 0
	local start_wave_ts = store.tick_ts
	local last_index_processed = 0

	local function get_wave_data_index(current_wave_data)
		for index, wave_data in ipairs(current_wave_data) do
			if index > last_index_processed and wave_data.time_start + wave_data.duration > store.tick_ts - start_wave_ts then
				return index
			end
		end

		return nil
	end

	while not this.bossfight do
		local current_wave = store.wave_group_number
		local current_wave_data = this.wave_config[store.level_mode][current_wave]

		if current_wave ~= last_wave then
			last_wave = current_wave
			start_wave_ts = store.tick_ts
			last_index_processed = 0
		end

		if current_wave_data and #current_wave_data > 0 then
			local next_index_to_check = get_wave_data_index(current_wave_data)

			if next_index_to_check and next_index_to_check ~= last_index_processed then
				local wave_data = current_wave_data[next_index_to_check]

				if store.tick_ts - start_wave_ts >= wave_data.time_start then
					elevator.go_up = true

					U.y_wait_unconditional(store, fts(30))

					factory.wave_counter = factory.wave_counter + 1

					local machinist = E:create_entity(this.machinist_t)

					machinist.pos = V.v(-17, 453)
					machinist.nav_path.pi = 7
					machinist.source_id = this.id

					simulation:queue_insert_entity(machinist)
					U.y_wait_unconditional(store, 2)

					if store.level_mode == GAME_MODE_CAMPAIGN then
						local taunt_idx = math.random(1, 3)

						signal.emit("show-balloon_tutorial", string.format("LV24_MACHINIST_BEFORE_BOSSFIGHT_%02i", taunt_idx), false)
					end

					elevator.go_down = true

					local activated_factory = false

					while machinist and not machinist.escape do
						if machinist.operation_done then
							machinist.operation_done = false

							if machinist.current_op > machinist.op_needed then
								factory.open = true

								U.y_wait_unconditional(store, fts(15))

								elevator.go_up = true

								U.y_wait_unconditional(store, fts(100))

								elevator.go_down = true
								activated_factory = true
								kept_factory_closed = false

								break
							else
								U.y_animation_play(factory, "startup", nil, store.tick_ts, 1)
							end
						end

						coroutine.yield()
					end

					if not activated_factory then
						elevator.go_up = true

						U.y_wait_unconditional(store, fts(90))

						elevator.go_down = true
					end

					last_index_processed = next_index_to_check
				end
			end
		end

		coroutine.yield()
	end

	if kept_factory_closed then
		signal.emit("factory-stage24", this)
	end

	elevator.go_up = true

	U.y_wait_unconditional(store, fts(30))

	local machinist = E:create_entity(this.machinist_t)

	machinist.pos = V.v(-17, 453)
	machinist.nav_path.pi = 7
	machinist.source_id = this.id
	machinist.bossfight = true

	simulation:queue_insert_entity(machinist)
	U.y_wait_unconditional(store, 2)

	elevator.go_down = true

	while not machinist.ended_cinematic do
		if machinist.operation_done then
			machinist.operation_done = false

			if machinist.current_op > machinist.op_needed then
				factory.open = true
				factory.bossfight = true
			else
				U.y_animation_play(factory, "startup", nil, store.tick_ts, 1)
			end
		end

		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end

tt = E:register_t_hot("decal_stage_24_mask_1", "decal", true)
tt.render.sprites[1].name = "stage24_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 1
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("decal_stage_24_gear_tower", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "towerDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.main_script.update = decal_stage_24_gears_update
tt.ui.click_rect = r(15, -35, 40, 65)

tt = E:register_t_hot("decal_stage_24_bubble", "decal_scripted", true)
tt.render.sprites[1].prefix = "lavabubbleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].hidden = true
tt.main_script.update = decal_stage_24_bubble_update

tt = E:register_t_hot("decal_stage_24_fans", "decal", true)
tt.render.sprites[1].prefix = "stage2dlcanimsfansDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = E:register_t_hot("decal_stage_24_dust", "decal", true)
tt.render.sprites[1].prefix = "t5_dustDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1

tt = E:register_t_hot("decal_stage_24_smoke", "decal", true)
tt.render.sprites[1].prefix = "t5_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1

tt = E:register_t_hot("decal_stage_24_upgrade_station", "decal_scripted", true)
tt.render.sprites[1].prefix = "converterDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.main_script.update = decal_stage_24_upgrade_station_update
tt.hammerer_t = "enemy_darksteel_hammerer"
tt.fist_t = "enemy_darksteel_fist"
tt.wave_config = {{
	{},
	{},
	{},
	{},
	{{
		duration = 60,
		time_start = 1
	}},
	{},
	{},
	{{
		duration = 60,
		time_start = 10
	}},
	{},
	{},
	{},
	{{
		duration = 50,
		time_start = 1
	}},
	{},
	{{
		duration = 45,
		time_start = 1
	}},
	{}
}, {{}, {{
	duration = 55,
	time_start = 2
}}, {}, {}, {{
	duration = 56,
	time_start = 2
}}, {}}, {{{
	duration = 560,
	time_start = 2
}}}}
tt.path_in = 8
tt.path_out = 9
tt.sound_open = "Stage24UpgradeStationIn"
tt.sound_close = "Stage24UpgradeStationOut"
tt.sound_transform = "Stage24UpgradeStationTransform"

tt = E:register_t_hot("decal_stage_24_gear_factory", "decal", true)
tt.render.sprites[1].prefix = "factory2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_24_gear_floor", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "dlc_enanos_stage_02_LAYERS_gear"
tt.render.sprites[1].name = "loop"
tt.main_script.update = decal_stage_24_gears_update
tt.ui.click_rect = r(-25, -5, 50, 35)

tt = E:register_t_hot("decal_stage_24_modes_decos", "decal_scripted", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "stage2DLC_ascensor_modosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_stage_24_modes_decos_update

tt = E:register_t_hot("decal_stage_24_gears", "decal", true)
tt.render.sprites[1].prefix = "stage2dlcanimstuercasDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_24_mask_3", "decal", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage24_mask3"
tt.render.sprites[1].animated = false

tt = E:register_t_hot("decal_stage_24_mask_2", "decal", true)
tt.render.sprites[1].name = "stage24_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_24_mask_5", "decal", true)
tt.render.sprites[1].name = "stage24_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_24_factory", "decal_scripted", true)
E:add_comps(tt, "spawner", "editor")
tt.render.sprites[1].prefix = "factoryDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 2
tt.main_script.update = decal_stage_24_factory.update
tt.spawner.eternal = true
tt.sound_factory_turn_on_end = "Stage24FactoryTurnOnEnd"
tt.sound_factory_turn_off = "Stage24FactoryTurnOff"

tt = E:register_t_hot("decal_stage_24_factory_conveyor_belt", "decal", true)
tt.render.sprites[1].prefix = "dlc_enanos_stage_02_LAYERS_factorygate"
tt.render.sprites[1].name = "activeloop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 1
tt.render.sprites[1].hidden = true

tt = E:register_t_hot("decal_stage_24_factory_sparks", "decal_scripted", true)
tt.render.sprites[1].prefix = "dlc_dwarf_boss_operator_sparks"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].hidden = true
tt.main_script.update = decal_stage_24_factory_sparks.update

tt = E:register_t_hot("decal_stage_24_elevator", "decal_scripted", true)
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "ascensorDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.main_script.update = decal_stage_24_elevator.update
tt.sound_machinist_in = "Stage24MachinistEnter"
tt.sound_machinist_out = "Stage24MachinistExit"

tt = E:register_t_hot("decal_stage_24_mask_4", "decal", true)
tt.render.sprites[1].name = "stage24_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = 44

tt = E:register_t_hot("decal_stage_24_mask_6", "decal", true)
tt.render.sprites[1].name = "stage24_mask6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = 95

tt = E:register_t_hot("controller_stage_24_machinist", nil, true)
E:add_comps(tt, "main_script")
tt.main_script.update = controller_stage_24_machinist.update
tt.wave_config = {{
	{},
	{},
	{},
	{},
	{},
	{},
	{{
		duration = 40,
		time_start = 10
	}},
	{},
	{{
		duration = 40,
		time_start = 10
	}},
	{},
	{{
		duration = 40,
		time_start = 8
	}},
	{},
	{{
		duration = 40,
		time_start = 12
	}},
	{},
	{{
		duration = 40,
		time_start = 15
	}}
}, {{}, {}, {}, {}, {}, {}}, {{}}}
tt.machinist_t = "enemy_machinist"

