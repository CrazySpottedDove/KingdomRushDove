local V = require("lib.klua.vector")
local E = require("entity_db")
local U = require("utils")
local A = require("achievements")
local scripts = require("scripts")
require("all.constants")
require("lib.klua.table")
local v = V.v
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_stage22_reptile_update(this, store)
	while true do
		if this.ui.clicked then
			U.y_animation_play(this, "clicked", nil, store.tick_ts)
			U.animation_start_default(this, "climb", nil, store.tick_ts, true)
			U.set_destination(this, v(this.pos.x, this.pos.y + this.climb_distance))
			while not U.walk_off__accel__unsnapped(this, store.tick_length) do
				coroutine.yield()
			end
			simulation:queue_remove_entity(this)
			return
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_moria_gate", "decal_scripted", true)
AC(tt, "tween", "ui")
tt.render.sprites[1].name = "moria_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 100
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "moria_0002"
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].anchor.y = 0
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 0}, {0.6, 255}, {0.9, 150}}
tt.main_script.update = scripts.click_run_tween.update
tt.ui.click_rect = r(-25, 0, 50, 80)
tt = E:register_t_hot("decal_stage22_reptile", "decal_scripted", true)
AC(tt, "ui", "motion")
tt.render.sprites[1].prefix = "decal_stage22_reptile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.6935483870967742, 0.05555555555555555)
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.main_script.update = decal_stage22_reptile_update
tt.climb_distance = 140
tt.motion.max_speed = 2 * FPS
