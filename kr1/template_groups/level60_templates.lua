local E = require("entity_db")
local U = require("utils")
local P = require("path_db")
local SU = require("script_utils")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s12_lemur_update(this, store)
	local clicked = false
	::label_573_0::
	this.nav_path.ni = 1
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	U.y_wait_unconditional(store, U.frandom(this.wait_time[1], this.wait_time[2]))
	this.tween.ts = store.tick_ts
	this.tween.reverse = false
	while this.nav_path.ni < this.action_ni do
		SU.y_enemy_walk_step(store, this, "running", 1)
	end
	U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	this.ui.clicked = nil
	local show_time = U.frandom(this.show_time[1], this.show_time[2])
	if U.y_wait_conditional(store, show_time, function()
		return this.ui.clicked == true
	end) then
		U.y_animation_play(this, "action", nil, store.tick_ts)
		clicked = true
	end
	while SU.y_enemy_walk_step(store, this, "running", 1) do
		if not this.tween.reverse and this.nav_path.ni > this.fade_ni then
			this.tween.reverse = true
			this.tween.ts = store.tick_ts
		end
	end
	if not clicked then
		goto label_573_0
	end
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("decal_s12_lemur", "decal_scripted", true)
AC(tt, "nav_path", "motion", "tween", "ui")
tt.render.sprites[1].prefix = "decal_s12_lemur"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.133333
tt.render.sprites[1].alpha = 0
tt.motion.max_speed = 60
tt.achievement = "LIKE_TO_MOVE_IT"
tt.action_ni = 12
tt.fade_ni = 18
tt.wait_time = {5, 10}
tt.show_time = {1, 3}
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.main_script.update = decal_s12_lemur_update
tt.ui.click_rect = r(-15, 0, 30, 30)
