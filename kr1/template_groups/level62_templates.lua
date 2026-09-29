local E = require("entity_db")
local U = require("utils")
local P = require("path_db")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s14_break_spider_update(this, store)
	local c = this.click_play
	local s = this.render.sprites[1]
	local clicks = 0
	if s.scale then
		for _, p in pairs(this.tween.props[1].keys) do
			p[2].x = p[2].x * s.scale.x
			p[2].y = p[2].y * s.scale.y
		end
	end
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
			this.tween.ts = store.tick_ts
		end
		if clicks > c.required_clicks then
			this.ui.can_click = false
			clicks = 0
			U.animation_start_default(this, "open", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, fts(4))
			local pis = this.pi and {this.pi} or nil
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, pis)
			for i = 1, 3 do
				local npos = P:node_pos(nodes[1][1], nodes[1][2], nodes[1][3] + 6 * (i - 2))
				local e = E:create_entity("decal_s14_break_spider")
				e.pos.x, e.pos.y = this.pos.x, this.pos.y
				e.tween.ts = store.tick_ts
				e.tween.props[2].keys[2][2] = v(npos.x - this.pos.x, npos.y - this.pos.y)
				simulation:queue_insert_entity(e)
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s14_break_egg", "decal_scripted", true)
AC(tt, "ui", "click_play", "tween")
tt.render.sprites[1].prefix = "decal_s14_break_egg"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.38235294117647056
tt.main_script.update = decal_s14_break_spider_update
tt.click_play.required_clicks = 5
tt.ui.can_select = false
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(1), vec_1(1.2)}, {fts(6), vec_1(1)}}
