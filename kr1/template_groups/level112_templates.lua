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
local decal_stage_12_sheepy_easteregg_update
local decal_stage_12_windmill_update
local decal_stage_12_easter_egg_strangerthings_update
decal_stage_12_sheepy_easteregg_update = function(this, store)
	local already_tapped = false
	while true do
		if not already_tapped and this.ui.clicked then
			this.ui.clicked = nil
			already_tapped = true
			U.animation_start_default(this, "action", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, 2.1)
			S:queue("Stage12SheepyPart1")
			U.y_wait_unconditional(store, 1.9)
			S:queue("Stage12SheepyPart2")
			U.y_wait_unconditional(store, 1)
			S:queue("Stage12SheepyPart3")
			U.y_animation_wait_default(this)
			signal.emit("sheepy_tap_achievement", 2)
		end
		coroutine.yield()
	end
end
decal_stage_12_windmill_update = function(this, store)
	local start_ts = store.tick_ts
	local pause_ts
	local s = this.render.sprites[1]
	local start_tween_ts = store.tick_ts
	this.tween.ts = start_tween_ts
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
decal_stage_12_easter_egg_strangerthings_update = function(this, store)
	local phase = 0
	while store.wave_group_number == 0 do
		this.render.sprites[1].ts = store.tick_ts
		coroutine.yield()
	end
	U.y_animation_play(this, "in", false, store.tick_ts)
	this.ui.clicked = nil
	while true do
		if phase == 0 then
			if this.ui.clicked then
				this.ui.clicked = nil
				S:queue("Stage12WeirderThingsEnterChar")
				S:queue("Stage12WeirderThingsFirstStrum")
				U.y_animation_play(this, "action_1", nil, store.tick_ts, 1)
				U.animation_start_default(this, "idle", false, store.tick_ts, true)
				phase = 1
			end
		elseif phase == 1 and this.ui.clicked then
			this.ui.clicked = nil
			S:queue("Stage12WeirderThingsEnterCharTap2")
			U.y_animation_play(this, "action_2", nil, store.tick_ts, 1)
			signal.emit("stranger_things-stage12", this)
			phase = 2
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_12_easter_egg_strangerthings", "decal", true)
E:add_comps(tt, "ui", "main_script")
tt.main_script.update = decal_stage_12_easter_egg_strangerthings_update
tt.render.sprites[1].prefix = "stranger_thingsDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.ui.click_rect = r(-365, -240, 95, 55)
tt = E:register_t_hot("decal_stage_12_mask_2", "decal_stage_12_mask_1", true)
tt.render.sprites[1].name = "T3_12_mask_02"
tt = E:register_t_hot("decal_stage_12_sheepy_easteregg", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.render.sprites[1].prefix = "stage_12_sheepyDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = decal_stage_12_sheepy_easteregg_update
tt.ui.click_rect = r(410, 230, 40, 40)
tt = E:register_t_hot("decal_stage_12_windmill", "decal_click_pause", true)
E:add_comps(tt, "tween")
tt.render.sprites[1].prefix = "t3_windmillDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.ui.click_rect = r(-25, -5, 50, 70)
tt.tween_amplitude = 15
tt.tween_frecuency = 150
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, 0)}, {fts(tt.tween_frecuency), v(0, tt.tween_amplitude)}, {fts(tt.tween_frecuency * 2), v(0, 0)}}
tt.main_script.update = decal_stage_12_windmill_update
tt = E:register_t_hot("decal_stage_12_mask_3", "decal_stage_12_mask_1", true)
tt.render.sprites[1].name = "T3_12_mask_03"
tt = E:register_t_hot("decal_stage_12_mask_4", "decal_stage_12_mask_1", true)
tt.render.sprites[1].name = "T3_12_mask_04"
