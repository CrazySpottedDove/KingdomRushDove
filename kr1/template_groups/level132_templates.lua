local E = require("entity_db")
require("lib.klua.table")
local tt
tt = E:register_t_hot("stage_32_mask_waterfall_1", "decal", true)
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t_hot("stage_32_mask_waterfall_2", "stage_32_mask_waterfall_1", true)
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_2Def"
tt.render.sprites[1].sort_y_offset = 175
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t_hot("stage_32_mask_lava_rocks", "decal", true)
tt.render.sprites[1].prefix = "stage_32_rockDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("stage_32_mask_fire_decals", "decal", true)
tt.render.sprites[1].prefix = "stage_32_lava_buffDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t_hot("stage_32_mask_front", "decal", true)
tt.render.sprites[1].prefix = "stage_32_lava_shadow_dragonDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = E:register_t_hot("controller_stage_32_lava_splash_2", "controller_stage_32_lava_splash", true)
tt.mod = "mod_stage_32_lava_splash_2"
tt.paths_y = {
	[3] = 560
}

tt = E:register_t_hot("stage_32_mask_waterfall_3", "stage_32_mask_waterfall_2", true)
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_3Def"

tt = E:register_t_hot("stage_32_mask_lava_bubbles", "decal", true)
tt.render.sprites[1].prefix = "stage_32_lava_bubbleDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 176
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t_hot("stage_32_mask_heads", "decal", true)
tt.render.sprites[1].name = "stage_32_masks_layer_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 160
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t_hot("stage_32_mask_heads_2", "stage_32_mask_heads", true)
tt.render.sprites[1].flip_x = true

local decal_stage_32_easter_egg_sheepy
local U = require("utils")
local V = require("lib.klua.vector")
local v = V.v
decal_stage_32_easter_egg_sheepy = {}

function decal_stage_32_easter_egg_sheepy.update(this, store)
	U.animation_start_default(this, "idle_1", nil, store.tick_ts, true)

	local clicks = 0
	local ts_idle_anim = store.tick_ts
	local delay_anim = math.random(4, 5)

	while true do
		if this.ui.clicked then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false

			if clicks == 1 then
				U.y_animation_play(this, "click_1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_2", nil, store.tick_ts, true, 1, true)

				this.ui.can_click = true
				ts_idle_anim = store.tick_ts
				delay_anim = math.random(4, 5)
			elseif clicks == 2 then
				U.y_animation_play(this, "click_2", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_3", nil, store.tick_ts, true, 1, true)

				this.ui.can_click = true
			elseif clicks == 3 then
				U.y_animation_play(this, "click_3", nil, store.tick_ts, 1, 1)

				return
			end
		elseif delay_anim < store.tick_ts - ts_idle_anim then
			if clicks == 0 then
				U.animation_start(this, "idle_1_anim", nil, store.tick_ts, false, 1, true)
			elseif clicks == 1 then
				U.animation_start(this, "idle_2_anim", nil, store.tick_ts, false, 1, true)
			end

			ts_idle_anim = store.tick_ts
			delay_anim = math.random(4, 5)
		end

		coroutine.yield()
	end
end

tt = E:register_t_hot("decal_stage_32_easter_egg_sheepy", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_32_easter_egg_sheepy.update
tt.render.sprites[1].prefix = "sheepylava_sheepy"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "sheepylava_crater_1"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-45, -30)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "sheepylava_crater_2"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(-20, 0)
tt.render.sprites[3].sort_y_offset = 2
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "sheepylava_crater_3"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].offset = v(25, -20)
tt.render.sprites[4].ignore_start = true
tt.render.sprites[4].ignore_start = true
tt.ui.click_rect = r(-30, -20, 60, 60)

