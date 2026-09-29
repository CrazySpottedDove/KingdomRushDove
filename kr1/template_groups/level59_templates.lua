local log = require("lib.klua.log"):new("level11")
local function fts(v)
	return v / FPS
end
local E = require("entity_db")
local U = require("utils")
local P = require("path_db")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_drow_queen_portal_update(this, store)
	local current_pack
	local pi_nodes = {}
	local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, this.path_ids)
	for _, item in pairs(nearest_nodes) do
		pi_nodes[item[1]] = item[3] + 2
	end
	while true do
		while not this.pack do
			coroutine.yield()
		end
		current_pack = this.pack
		this.pack_finished = nil
		this.tween.ts = store.tick_ts
		this.tween.reverse = nil
		this.tween.disabled = nil
		for _, row in pairs(current_pack.waves) do
			local tn, interval, qty, sub0 = unpack(row, 1, 4)
			for i = 1, qty do
				log.debug("(%s)decal_drow_queen_portal spawning:%s", this.id, tn)
				local o = this.spawn_offsets[sub0 + 1]
				local e = E:create_entity(tn)
				e.nav_path.pi = current_pack.pi
				e.nav_path.spi = sub0 + 1
				e.nav_path.ni = pi_nodes[current_pack.pi]
				e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
				e.enemy.gold = 0
				simulation:queue_insert_entity(e)
				local fx = E:create_entity("fx_drow_queen_portal")
				fx.render.sprites[1].ts = store.tick_ts
				fx.pos.x, fx.pos.y = e.pos.x, e.pos.y - 1
				simulation:queue_insert_entity(fx)
				coroutine.yield()
				if interval > 0 and U.y_wait_conditional(store, fts(interval), function()
					return this.pack == nil
				end) then
					log.debug("(%s)decal_drow_queen_portal interrupted", this.id)
					goto label_571_0
				end
			end
		end
		log.debug("(%s)decal_drow_queen_portal finished", this.id)
		::label_571_0::
		this.pack = nil
		this.pack_finished = true
		this.tween.ts = store.tick_ts
		this.tween.reverse = true
		this.tween.disabled = nil
		current_pack = nil
	end
end
local tt
tt = E:register_t_hot("decal_drow_queen_portal", "decal_scripted", true)
AC(tt, "editor", "tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_portal_0001"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage11_portal_0002"
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "stage11_portal_0003"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "stage11_portal_0004"
tt.main_script.update = decal_drow_queen_portal_update
tt.spawn_offsets = {vec_2(0, 0), vec_2(0, -20), vec_2(0, 20)}
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(7), 255}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 4
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].sprite_id = 4
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_1(1)}, {fts(23), vec_1(1.2)}}
tt.tween.props[4].loop = true
tt.tween.props[4].ignore_reverse = true
tt = E:register_t_hot("decal_s11_door_glow", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_doorGlow"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -30
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 100}, {0.3, 200}, {0.6, 130}, {0.9, 255}, {1.2, 100}}
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.5, 1}, {4.8, 1}, {6, 0}}
tt.tween.props[2].multiply = true
tt.editor.tag = 1
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
tt = E:register_t_hot("decal_s11_zealot_rune", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].offset = vec_2(-40, 0)
tt.render.sprites[1].name = "stage11_zealotRune"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}}
tt.editor.tag = 1
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
