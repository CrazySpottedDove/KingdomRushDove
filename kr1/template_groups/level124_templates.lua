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
							hammerer.vis.bans = U.flag_set(hammerer.vis.bans, F_POLYMORPH)
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
									hammerer.vis.bans = U.flag_clear(hammerer.vis.bans, F_POLYMORPH)
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
