local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("lib.klua.table")
local scripts = require("scripts")
local v = V.v
local r = V.r
local decal_stage_31_easter_egg_oogway_update
local decal_stage_31_easter_egg_littledragon_update
decal_stage_31_easter_egg_oogway_update = function(this, store)
	U.animation_start_default(this, "idle1", nil, store.tick_ts, true)
	local next_idle_ts = store.tick_ts + this.idle_cooldown_min + (this.idle_cooldown_max - this.idle_cooldown_min) * math.random()
	local clicks = 0
	::label_1875_0::
	while true do
		if this.ui.clicked then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false
			if clicks == 1 then
				U.y_animation_play(this, "tap1", nil, store.tick_ts)
				U.animation_start_default(this, "idle3", nil, store.tick_ts, true)
				this.ui.can_click = true
			elseif clicks == 2 then
				U.y_animation_play(this, "tap2", nil, store.tick_ts)
				U.animation_start_default(this, "idle4", nil, store.tick_ts, true)
				this.ui.can_click = true
			elseif clicks == 3 then
				U.y_animation_play(this, "tap3", nil, store.tick_ts)
				this.ui.can_click = true
			elseif clicks == 4 then
				U.y_animation_play(this, "tap4", nil, store.tick_ts)
				simulation:queue_remove_entity(this)
			end
		end
		if clicks == 0 and next_idle_ts < store.tick_ts then
			next_idle_ts = store.tick_ts + this.idle_cooldown_min + (this.idle_cooldown_max - this.idle_cooldown_min) * math.random()
			U.animation_start_default(this, "idle_2", nil, store.tick_ts, false)
			while not U.animation_finished_default(this) do
				if this.ui.clicked then
					goto label_1875_0
				end
				coroutine.yield()
			end
			U.animation_start_default(this, "idle1", nil, store.tick_ts, true)
		end
		coroutine.yield()
	end
end
decal_stage_31_easter_egg_littledragon_update = function(this, store)
	U.animation_start_default(this, "idle_1", nil, store.tick_ts, true)
	local clicks = 0
	while true do
		if this.ui.clicked and not this.render.sprites[1].hidden then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false
			if clicks == 1 then
				U.y_animation_play(this, "tap_1", nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle_2", nil, store.tick_ts, true, 1, true)
				this.ui.can_click = true
			elseif clicks == 2 then
				U.y_animation_play(this, "tap_2", nil, store.tick_ts, 1, 1)
				U.sprites_hide(this, 1, 1, false)
				return
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_stage_31_easter_egg_oogway", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_31_easter_egg_oogway_update
tt.render.sprites[1].prefix = "stage_31_oogwayDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].exo = true
tt.idle_cooldown_max = 20
tt.idle_cooldown_min = 5
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t_hot("fx_stage_31_fireball_b", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_BDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 2
tt = E:register_t_hot("decal_stage_31_easter_egg_littledragon", "decal_scripted", true)
E:add_comps(tt, "ui", "editor")
tt.main_script.update = decal_stage_31_easter_egg_littledragon_update
tt.render.sprites[1].prefix = "littledragon_easteregg_stage1_easteregg"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "littledragon_easteregg_stage1_easter_egg_dead"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(5, -30)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "littledragon_easteregg_stage1_tree"
tt.render.sprites[3].animated = false
tt.render.sprites[3].anchor = v(0, 0)
tt.render.sprites[3].offset = v(-69, -23)
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t_hot("stage_31_mask_shadow_top", "decal", true)
tt.render.sprites[1].prefix = "stage_31_shadowDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t_hot("stage_31_exo_fire_b", "stage_31_exo_fire_a", true)
tt.render.sprites[1].prefix = "stage_31_fire_BDef"
tt = E:register_t_hot("fx_stage_31_fireball_a", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_ADef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 1
tt = E:register_t_hot("fx_stage_31_fireball_c", "fx", true)
tt.render.sprites[1].prefix = "stage_31_fireball_CDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 3
