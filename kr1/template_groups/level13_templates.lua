local E = require("entity_db")
local U = require("utils")
local A = require("achievements")
require("all.constants")
require("lib.klua.table")
local r = V.r
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_fredo_update(this, store)
	local clicks = 0
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
			U.animation_start_default(this, "clicked", nil, store.tick_ts, false)
		end
		if clicks >= 8 then
			this.ui.can_click = false
			U.animation_start_default(this, "release", nil, store.tick_ts, false)
			U.y_animation_wait_default(this)
			A:got("FREE_FREDO")
			simulation:queue_remove_entity(this)
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_fredo", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "decal_fredo"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.1)
tt.render.sprites[1].loop = false
tt.main_script.update = decal_fredo_update
tt.ui.click_rect = r(-33, 104, 30, 30)
