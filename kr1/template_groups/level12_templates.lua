local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function veznan_portal_update(this, store)
	local spawns = this.spawn_groups[this.portal_idx]
	local ni = this.out_nodes[this.pi]
	while true do
		while not this.spawn_signal do
			coroutine.yield()
		end
		U.y_animation_play(this, "start", nil, store.tick_ts)
		local roll = math.random()
		local entity_data
		for _, s in pairs(spawns) do
			if roll <= s[1] then
				entity_data = s[2]
				break
			end
		end
		U.animation_start_default(this, "active", nil, store.tick_ts, true)
		for _, d in pairs(entity_data) do
			local min, max, template = unpack(d)
			local count = min ~= max and math.random(min, max) or min
			for i = 1, count do
				local e = E:create_entity(template)
				e.nav_path.pi = this.pi
				e.nav_path.spi = math.random(1, 3)
				e.nav_path.ni = ni
				e.pos = V.vclone(this.pos)
				simulation:queue_insert_entity(e)
				U.y_wait_unconditional(store, this.spawn_interval)
			end
		end
		U.y_animation_wait_default(this)
		U.y_animation_play(this, "end", nil, store.tick_ts)
		this.spawn_signal = nil
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_burner_big", "decal_loop", true)
tt.render.sprites[1].anchor = vec_2(0.5, 0.13)
tt.render.sprites[1].name = "decal_burner_big_idle"
tt = E:register_t_hot("decal_burner_small", "decal_loop", true)
tt.render.sprites[1].anchor = vec_2(0.5, 0.11)
tt.render.sprites[1].name = "decal_burner_small_idle"
tt = E:register_t_hot("veznan_portal", "decal_scripted", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "veznan_portal"
tt.render.sprites[1].z = Z_DECALS
tt.fx_out = "fx_demon_portal_out"
tt.main_script.update = veznan_portal_update
tt.spawn_groups = {{{0.5, {{4, 7, "enemy_demon"}}}, {0.8, {{3, 3, "enemy_demon_wolf"}}}, {1, {{5, 5, "enemy_demon"}, {1, 1, "enemy_demon_mage"}}}}, {{0.5, {{2, 5, "enemy_demon"}}}, {0.8, {{2, 2, "enemy_demon_wolf"}}}, {1, {{3, 3, "enemy_demon"}}}}, {{1, {{3, 3, "enemy_demon"}}}}}
tt.portal_idx = 1
tt.spawn_interval = fts(30)
tt.pi = 1
