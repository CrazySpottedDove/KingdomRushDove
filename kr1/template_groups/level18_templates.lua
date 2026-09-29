local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local A = require("achievements")
require("all.constants")
require("lib.klua.table")
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_scrat_update(this, store)
	local clicks = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			local fx = E:create_entity(this.touch_fx)
			fx.pos = V.vclone(this.pos)
			fx.render.sprites[1].ts = store.tick_ts
			simulation:queue_insert_entity(fx)
			clicks = clicks + 1
			if clicks >= 10 then
				break
			end
		end
		coroutine.yield()
	end
	this.ui.can_click = false
	U.animation_start_default(this, "play", nil, store.tick_ts, false)
	U.y_animation_wait_default(this)
	this.render.sprites[1].hidden = true
	U.animation_start(this, "end", nil, store.tick_ts, false, 2)
	A:got("DEFEAT_ACORN")
end
local tt
tt = E:register_t_hot("decal_scrat", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "decal_scrat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_scrat_ice"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].loop = false
tt.touch_fx = "fx_decal_scrat_touch"
tt.main_script.update = decal_scrat_update
tt.ui.click_rect = r(-45, 5, 40, 40)
