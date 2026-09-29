local signal = require("lib.hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local function fts(v)
	return v / FPS
end
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_09_sheepy_easteregg_update
decal_stage_09_sheepy_easteregg_update = function(this, store)
	local bridge_down = false
	local function check_bridge_down()
		if not bridge_down and store.wave_group_number == 10 then
			bridge_down = true
			return true
		end
		return false
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			S:queue("Stage09SheepyCamera")
			U.animation_start_default(this, "action_" .. math.random(1, 3), nil, store.tick_ts)
			signal.emit("sheepy_tap_achievement", 1)
			while not U.animation_finished_default(this) do
				if check_bridge_down() then
					U.y_wait_unconditional(store, fts(13))
					S:queue("Stage09SheepyBridge")
					U.y_animation_play(this, "bridge", true, store.tick_ts)
					goto label_1416_0
				end
				coroutine.yield()
			end
		end
		if check_bridge_down() then
			U.y_wait_unconditional(store, fts(13))
			S:queue("Stage09SheepyBridge")
			U.y_animation_play(this, "bridge", true, store.tick_ts)
			break
		end
		coroutine.yield()
	end
	::label_1416_0::
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_stage_09_fire", "decal", true)
tt.render.sprites[1].prefix = "stage_9_fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t_hot("decal_stage_09_bridge3", "decal_stage_09_bridge", true)
tt.render.sprites[1].prefix = "stage_9_bridge3Def"
tt.mask_entity = "decal_stage_09_bridge3_mask"
tt.mask_before = true
tt.mask_in_animation = "in"
tt.mask_loop_animation = "loop"
tt = E:register_t_hot("decal_stage_09_sheepy_easteregg", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.render.sprites[1].prefix = "stage_9_sheepyDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.main_script.update = decal_stage_09_sheepy_easteregg_update
tt.ui.click_rect = r(-20, -10, 40, 40)
tt = E:register_t_hot("controller_stage_09_spawn_nightmares", nil, true)
E:add_comps(tt, "editor", "pos", "main_script")
tt.main_script.insert = scripts.controller_stage_09_spawn_nightmares.insert
tt.main_script.update = scripts.controller_stage_09_spawn_nightmares.update
tt.wave_config = {{
	{},
	{},
	{{
		duration = 28,
		time_start = 10
	}},
	{{
		duration = 28,
		time_start = 10
	}},
	{},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 30,
		time_start = 10
	}},
	{},
	{{
		duration = 52,
		time_start = 10
	}},
	{{
		duration = 40,
		time_start = 10
	}},
	{},
	{{
		duration = 40,
		time_start = 12
	}},
	{{
		duration = 70,
		time_start = 10
	}}
}, {{}, {}, {}, {{
	duration = 70,
	time_start = 20
}}, {}, {{
	duration = 107,
	time_start = 21
}}}, {{{
	duration = 110,
	time_start = 74
}, {
	duration = 330,
	time_start = 310
}}}}
tt.entity_portal = "decal_stage_09_portal"
tt.entity_aura = "aura_stage_09_spawn_nightmare_convert"
tt.spawn_fx_aura = "aura_stage_09_spawn_nightmare_convert_spawn_fx"
tt.entity_candles = {"decal_stage_09_candle_back1", "decal_stage_09_candle_back2", "decal_stage_09_candle_back3", "decal_stage_09_candle_front1", "decal_stage_09_candle_front2", "decal_stage_09_candle_front3"}
tt.entity_glows = {"decal_stage_09_candle_glow_back", "decal_stage_09_candle_glow_front"}
tt.path_portal = "decal_stage_09_portal_path_spawn"
tt.portal_offset = v(-15, 0)
tt.pos_portal = v(1048 + tt.portal_offset.x, 446 + tt.portal_offset.y)
tt.pos_aura = {v(661 + tt.portal_offset.x, 280 + tt.portal_offset.y), v(659 + tt.portal_offset.x, 300 + tt.portal_offset.y), v(658 + tt.portal_offset.x, 260 + tt.portal_offset.y)}
tt.path_portal_off_delay = 10
tt.sound_candles_in = "Stage09NightmarePortalCandles"
tt.sound_portal_in = "Stage09NightmarePortalEye"
tt = E:register_t_hot("decal_stage_09_mask", "decal", true)
tt.render.sprites[1].name = "T2_Stage_9_chains_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
