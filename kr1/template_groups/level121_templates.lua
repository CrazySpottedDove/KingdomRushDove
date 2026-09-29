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
local decal_achievement_stage_21_croc_boat_update
decal_achievement_stage_21_croc_boat_update = function(this, store)
	local touch_times = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1
			if touch_times == this.touches_needed then
				S:queue(this.sound_engine_success)
				U.animation_start(this, "tap2", nil, store.tick_ts, false, this.render.sid_croc)
				U.y_wait_unconditional(store, fts(73))
				signal.emit("boat-croc-stage21")
				U.y_animation_wait(this, this.render.sid_croc, 1)
				U.animation_start(this, "idle2", nil, store.tick_ts, true, this.render.sid_croc)
			else
				S:queue(this.sound_engine_fail)
				U.y_animation_play(this, "tap1", nil, store.tick_ts, 1, this.render.sid_croc)
				U.animation_start(this, "idle1", nil, store.tick_ts, true, this.render.sid_croc)
				this.ui.can_click = true
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_21_mask_2", "decal", true)
tt.render.sprites[1].name = "stage21_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 1
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_21_mask_3", "decal", true)
tt.render.sprites[1].name = "stage21_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 2
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_achievement_stage_21_croc_boat", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.ui.click_rect = r(-55, -20, 90, 60)
tt.main_script.update = decal_achievement_stage_21_croc_boat_update
tt.touches_needed = 2
tt.render.sid_croc = 3
tt.render.sprites[1].name = "Achievement_lagarto_juancho_boat"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(-8, -20)
tt.render.sprites[1].anchor = v(0.5833333333333334, 0.21052631578947367)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "Achievement_lagarto_juancho_water"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor = v(0.7289156626506024, 0.29464285714285715)
tt.render.sprites[2].offset = v(-2, -16)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "Achievement_lagarto_juancho_creep"
tt.render.sprites[3].name = "idle1"
tt.render.sprites[3].anchor = v(0.5, 0.38636363636363635)
tt.sound_engine_fail = "Stage21JuanchoEngineFail"
tt.sound_engine_success = "Stage21JuanchoEngineSuccess"

tt = E:register_t_hot("decal_stage_21_particlesLeft", "decal_delayed_play", true)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.main_script.update = scripts.delayed_play_kr5.update
tt.render.sprites[1].prefix = "stage_21_particlesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35

tt = E:register_t_hot("decal_stage_21_mask_4", "decal", true)
tt.render.sprites[1].name = "stage21_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_21_mask_1", "decal", true)
tt.render.sprites[1].name = "stage21_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t_hot("decal_stage_21_bubbles", "decal", true)
tt.render.sprites[1].prefix = "stage_21_bubbles_02Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("decal_stage_21_mask_lianas", "decal", true)
tt.render.sprites[1].name = "stage21_mask_lianas"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_FLYING_HEROES + 1

tt = E:register_t_hot("decal_stage_21_dragonfly_1", "decal_delayed_play", true)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.main_script.update = scripts.delayed_play_kr5.update
tt.render.sprites[1].prefix = "stage_21_dragonfly_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt.delayed_play.start_min_delay = 1
tt.delayed_play.start_max_delay = 3

tt = E:register_t_hot("decal_stage_21_dragonfly_2", "decal_stage_21_dragonfly_1", true)
tt.render.sprites[1].prefix = "stage_21_dragonfly_02Def"
tt.delayed_play.start_min_delay = 13
tt.delayed_play.start_max_delay = 20
