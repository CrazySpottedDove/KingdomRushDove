local E = require("entity_db")
local U = require("utils")
local A = require("achievements")
local scripts = require("scripts")
require("all.constants")
require("lib.klua.table")
local function decal_s23_splinter_pizza_update(this, store)
	while not this.ui.clicked do
		coroutine.yield()
	end
	this.ui.clicked = nil
	U.animation_start_default(this, "clicked", nil, store.tick_ts, false)
	U.y_animation_wait_default(this)
	A:got("SPLINTER")
	this.render.sprites[1].prefix = "decal_s23_splinter"
	return scripts.click_play.update(this, store)
end
local tt
tt = E:register_t_hot("decal_s23_splinter", "decal_click_play", true)
tt.render.sprites[1].prefix = "decal_s23_splinter"
tt.ui.can_select = false
tt.ui.click_rect.pos.x = -6
tt.ui.click_rect.size.x = 25
tt = E:register_t_hot("decal_s23_splinter_pizza", "decal_s23_splinter", true)
tt.main_script.update = decal_s23_splinter_pizza_update
tt.render.sprites[1].prefix = "decal_s23_splinter_pizza"
