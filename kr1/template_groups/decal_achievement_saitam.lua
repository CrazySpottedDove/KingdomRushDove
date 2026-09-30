local U = require("utils")
local signal = require("lib.hump.signal")
local E = require("entity_db")
local V = require("lib.klua.vector")
local v = V.v
local tt = E:register_t_hot("decal_achievement_saitam_stage31", "decal_scripted", true)
E:add_comps(tt, "ui", "editor", "tween")
tt.main_script.update = function(this, store)
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)

	local clicks = 0
	local scale_animation_duration = 0.2
	local initial_scale = this.render.sprites[1].scale and this.render.sprites[1].scale.x or 1
	local target_scale = 1.15 * initial_scale
	local scale_animation_active = false
	local scale_start_ts = 0

	while true do
		if scale_animation_active then
			local elapsed = store.tick_ts - scale_start_ts

			if elapsed < scale_animation_duration then
				local progress = elapsed / scale_animation_duration
				local scale_factor = math.sin(progress * math.pi)

				this.render.sprites[1].scale = v(initial_scale + (target_scale - initial_scale) * scale_factor, initial_scale + (target_scale - initial_scale) * scale_factor)
			else
				this.render.sprites[1].scale = v(initial_scale, initial_scale)
				scale_animation_active = false
				this.ui.can_click = true
			end
		end

		if this.render.sprites[1].name == "click_1" and U.animation_finished_default(this) then
			U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		end

		if this.ui.clicked and not this.render.sprites[1].hidden then
			clicks = clicks + 1
			this.ui.clicked = nil
			this.ui.can_click = false

			if clicks == 1 then
				U.animation_start_default(this, "click_1", nil, store.tick_ts, false)

				scale_animation_active = true
				scale_start_ts = store.tick_ts
			elseif clicks == 2 then
				U.y_animation_play(this, "click_2", nil, store.tick_ts, 1, 1)
				signal.emit("saitam-dlc2", store.level_idx - 31)

				this.tween.disabled = false
				this.tween.ts = store.tick_ts

				return
			end
		end

		coroutine.yield()
	end
end
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].offset = v(-30, 5)
tt.render.sprites[1].anchor = v(0.333333, 0.522222)
tt.ui.click_rect = r(-50, -5, 40, 30)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.5, 0}}

tt = E:register_t_hot("decal_achievement_saitam_stage32", "decal_achievement_saitam_stage31", true)
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_2"

tt = E:register_t_hot("decal_achievement_saitam_stage33", "decal_achievement_saitam_stage31", true)
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_3"

tt = E:register_t_hot("decal_achievement_saitam_stage34", "decal_achievement_saitam_stage31", true)
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_4"

tt = E:register_t_hot("decal_achievement_saitam_stage35", "decal_achievement_saitam_stage31", true)
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_5"
