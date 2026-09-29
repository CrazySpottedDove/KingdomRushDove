local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local A = require("achievements")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function decal_s25_nessie_update(this, store)
	local pause_min, pause_max = unpack(this.pause_duration)
	local animation_min, animation_max = unpack(this.animation_duration)
	local pause_ts = 0
	local animation_ts = 0
	local current_pause
	while true do
		::label_273_0::
		U.sprites_hide(this)
		this.ui.can_click = false
		pause_ts = store.tick_ts
		current_pause = U.frandom(pause_min, pause_max)
		while current_pause > store.tick_ts - pause_ts do
			coroutine.yield()
		end
		this.pos = this.out_pos[math.random(1, #this.out_pos)]
		U.sprites_show(this)
		this.ui.can_click = true
		U.animation_start_default(this, "bubble_in", nil, store.tick_ts, false)
		U.y_animation_wait_default(this)
		while this.render.sprites[1].runs < 1 do
			if this.ui.clicked then
				goto label_273_1
			end
			coroutine.yield()
		end
		animation_ts = U.frandom(animation_min, animation_max)
		U.animation_start_default(this, "bubble_play", nil, store.tick_ts, true)
		while animation_ts > this.render.sprites[1].runs * fts(22) do
			if this.ui.clicked then
				goto label_273_1
			end
			coroutine.yield()
		end
		U.sprites_hide(this)
		this.ui.can_click = false
		U.animation_start_default(this, "bubble_out", nil, store.tick_ts, false)
		U.y_animation_wait_default(this)
		goto label_273_0
		::label_273_1::
		this.ui.clicked = nil
		S:queue(this.sound)
		U.animation_start_default(this, "clicked", nil, store.tick_ts, false)
		U.y_wait_unconditional(store, fts(90))
		S:queue(this.sound)
		U.y_animation_wait_default(this)
		A:got("NESSIE")
		U.sprites_hide(this)
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s25_nessie", "decal_click_play", true)
tt.render.sprites[1].anchor = vec_2(0.5, 0.43478260869565216)
tt.render.sprites[1].prefix = "decal_s25_nessie"
tt.main_script.update = decal_s25_nessie_update
tt.out_pos = {vec_2(555, 600), vec_2(131, 530), vec_2(415, 450)}
tt.animation_duration = {3, 4}
tt.pause_duration = {7, 10}
tt.sound = "ExtraBlackburnNessie"
tt.ui.can_select = false
tt.ui.click_rect.pos = vec_2(-22, 2)
tt.ui.click_rect.size = vec_2(30, 20)
