local signal = require("lib.hump.signal")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_achievement_into_the_ogreverse_update
decal_achievement_into_the_ogreverse_update = function(this, store)
	local touch_times = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			touch_times = touch_times + 1
			if touch_times == 1 then
				U.y_animation_play(this, "cultist_transform", nil, store.tick_ts, 1, 2)
				U.animation_start(this, "spider_idle", nil, store.tick_ts, true, 2)
				this.ui.can_click = true
			elseif touch_times == 2 then
				U.y_animation_play(this, "spider_transform", nil, store.tick_ts, 1, 2)
				U.animation_start(this, "pig_idle", nil, store.tick_ts, true, 2)
				this.ui.can_click = true
			elseif touch_times == 3 then
				U.y_animation_play(this, "pig_transform", nil, store.tick_ts, 1, 2)
				U.animation_start(this, "ogre_idle", nil, store.tick_ts, true, 2)
				this.ui.can_click = true
			elseif touch_times == 4 then
				U.y_animation_play(this, "ogre_transform", nil, store.tick_ts, 1, 2)
				this.render.sprites[2].z = Z_TOWER_BASES - 1
				this.render.sprites[1].z = Z_TOWER_BASES - 2
				U.y_animation_play(this, "ogre_fall", nil, store.tick_ts, 1, 2)
				this.render.sprites[1].z = Z_OBJECTS
				this.render.sprites[2].hidden = true
				U.y_wait_unconditional(store, 1)
				signal.emit("spiders-into-the-ogreverse")
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_28_mask_3", "decal", true)
tt.render.sprites[1].name = "stage_28_mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_TOWER_BASES
tt = E:register_t_hot("decal_stage_28_torches", "decal", true)
tt.render.sprites[1].prefix = "stage_28_antorchasDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 200
tt = E:register_t_hot("decal_achievement_into_the_ogreverse", "decal_scripted", true)
E:add_comps(tt, "ui")
tt.ui.click_rect = r(-20, -40, 40, 50)
tt.main_script.update = decal_achievement_into_the_ogreverse_update
tt.render.sprites[1].name = "ogreverse_web"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "ogreverse_character"
tt.render.sprites[2].name = "cultist_idle"
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[2].sort_y_offset = -30
tt = E:register_t_hot("decal_stage_28_mask_1", "decal", true)
tt.render.sprites[1].name = "stage_28_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 106
tt = E:register_t_hot("decal_stage_28_mask_2", "decal", true)
tt.render.sprites[1].name = "stage_28_mask_02"
tt.render.sprites[1].animated = false
