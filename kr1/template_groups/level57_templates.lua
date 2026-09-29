local log = require("lib.klua.log"):new("level04")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function aura_waterfall_entrance_update(this, store)
	local show_queue = {}
	while true do
		for _, e in pairs(store.enemies) do
			if e.nav_path and e._waterfall_entrance_done ~= true then
				for _, item in pairs(this.waterfall_nodes) do
					local pi, nin, nout = item.path_id, item.from, item.to
					if pi ~= e.nav_path.pi then
					elseif e.nav_path.ni == nin and e._waterfall_entrance_done == nil then
						e._waterfall_entrance_done = false
						U.sprites_hide(e)
						if e.health_bar then
							e.health_bar.hidden = true
						end
					elseif e.nav_path.ni == nout and e._waterfall_entrance_done == false then
						e._waterfall_entrance_done = true
						local fx = E:create_entity(this.show_fx)
						fx.pos.x, fx.pos.y = e.pos.x, e.pos.y - 3
						fx.render.sprites[1].ts = store.tick_ts
						simulation:queue_insert_entity(fx)
						table.insert(show_queue, e)
					end
				end
			end
		end
		coroutine.yield()
		for i = #show_queue, 1, -1 do
			local e = show_queue[i]
			U.sprites_show(e)
			if e.health_bar then
				e.health_bar.hidden = nil
			end
			table.remove(show_queue, i)
		end
	end
end
local function decal_s09_crystal_serpent_attack_update(this, store)
	local hids = this.holder_ids
	local towers_by_idx = {}
	for _, e in E:filter_iter(store.entities, "tower") do
		for i, hid in ipairs(hids) do
			if e.tower.holder_id == hid then
				towers_by_idx[i] = e
				log.debug(" tower %s holder:%s pos_y:%s", i, e.tower.holder_id, e.pos.y)
			end
		end
	end
	S:queue("ElvesCrystalSerpentEmerge")
	U.animation_start_default(this, "spawn", this.flip_x, store.tick_ts, false)
	U.y_animation_wait_default(this)
	S:queue("ElvesCrystalSerpentAttack", {
		delay = fts(5)
	})
	U.animation_start_default(this, "shootSmoke", this.flip_x, store.tick_ts, false)
	U.y_wait_unconditional(store, fts(13))
	local first_dest = towers_by_idx[1].pos
	for i = 1, 3 do
		local target = towers_by_idx[i]
		local b = E:create_entity("bullet_crystal_serpent")
		b.bullet.target_id = target.id
		b.pos = this.flip_x and v(this.pos.x - 30, this.pos.y - 17) or v(this.pos.x + 33, this.pos.y - 13)
		b.bullet.from = V.vclone(b.pos)
		if i == 1 then
			b.bullet.to = v(first_dest.x, first_dest.y)
		else
			b.bullet.to = v((first_dest.x + target.pos.x) * 0.5, (first_dest.y + target.pos.y) * 0.5)
		end
		simulation:queue_insert_entity(b)
		if i == 1 then
			U.y_wait_unconditional(store, fts(3))
		end
	end
	U.y_animation_wait_default(this)
	S:queue("ElvesCrystalSerpentSubmerge", {
		delay = fts(8)
	})
	U.y_animation_play(this, "dive", this.flip_x, store.tick_ts)
	simulation:queue_remove_entity(this)
end
local function decal_s09_crystal_serpent_scream_update(this, store)
	S:queue("ElvesCrystalSerpentEmerge")
	U.animation_start(this, "spawn", this.flip_x, store.tick_ts, false, 1)
	this.render.sprites[3].hidden = false
	U.animation_start(this, "waterWaves", this.flip_x, store.tick_ts, true, 3)
	U.y_animation_wait_default(this)
	S:queue("ElvesCrystalSerpentScream")
	this.render.sprites[2].hidden = false
	U.animation_start(this, "superScream", this.flip_x, store.tick_ts, false, 1)
	U.animation_start(this, "superScreamRays", this.flip_x, store.tick_ts, false, 2)
	U.y_animation_wait_default(this)
	this.render.sprites[2].hidden = true
	S:queue("ElvesCrystalSerpentSubmerge", {
		delay = fts(8)
	})
	U.animation_start(this, "dive", this.flip_x, store.tick_ts, false, 1)
	U.y_wait_unconditional(store, fts(19))
	this.render.sprites[3].hidden = true
	U.y_animation_wait_default(this)
	simulation:queue_remove_entity(this)
end
local tt
tt = E:register_t_hot("aura_waterfall_entrance", "aura", true)
tt.main_script.update = aura_waterfall_entrance_update
tt.show_fx = "fx_waterfall_splash"

tt = E:register_t_hot("decal_s09_land_3", "decal_background", true)
AC(tt, "tween")
tt.render.sprites[1].name = "Stage09_0002"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.editor.game_mode = 1
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(9), 255}, {fts(18), 0}}

tt = E:register_t_hot("decal_s09_land_2", "decal_s09_land_3", true)
tt.render.sprites[1].name = "Stage09_0003"

tt = E:register_t_hot("decal_s09_land_1", "decal_s09_land_3", true)
tt.render.sprites[1].name = "Stage09_0004"

tt = E:register_t_hot("decal_s09_crystal_1", "decal_timed", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "decal_s09_crystal_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3941176470588235
tt.render.sprites[1].scale = vec_2(1, 1)
tt.timed.runs = INT_32_MAX
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.debris_pos = vec_2(-5, 1)

tt = E:register_t_hot("decal_s09_crystal_2", "decal_s09_crystal_1", true)
tt.render.sprites[1].prefix = "decal_s09_crystal_2"
tt.debris_pos = vec_2(9, 4)

tt = E:register_t_hot("decal_s09_crystal_3", "decal_s09_crystal_1", true)
tt.render.sprites[1].prefix = "decal_s09_crystal_3"
tt.debris_pos = vec_2(9, -5)

tt = E:register_t_hot("decal_s09_crystal_4", "decal_s09_crystal_1", true)
tt.render.sprites[1].prefix = "decal_s09_crystal_4"
tt.debris_pos = vec_2(-6, 6)

tt = E:register_t_hot("decal_s09_crystal_serpent_back", "decal_tween", true)
AC(tt, "sound_events")
tt.render.sprites[1].name = "crystal_serpent_appear"
tt.render.sprites[1].loop = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(80), vec_2(0, 0)}, {fts(114), vec_2(0, 0)}}
tt.sound_events.insert = "ElvesCrystalSerpentPassby"

tt = E:register_t_hot("decal_s09_crystal_serpent_attack", "decal_scripted", true)
tt.render.sprites[1].prefix = "crystal_serpent"
tt.main_script.update = decal_s09_crystal_serpent_attack_update

tt = E:register_t_hot("decal_s09_crystal_serpent_scream", "decal_s09_crystal_serpent_attack", true)
tt.main_script.update = decal_s09_crystal_serpent_scream_update
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].hidden = true

tt = E:register_t_hot("decal_s09_waterfall", "decal_scripted", true)
tt.render.sprites[1].name = "decal_s09_waterfall_lines1"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_s09_waterfall_lines2"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "decal_s09_waterfall_top"
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "decal_s09_waterfall_bottom"

tt = E:register_t_hot("decal_crystal_water_waves2", "decal_delayed_play", true)
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"

tt = E:register_t_hot("bullet_crystal_serpent", "bullet", true)
tt.render.sprites[1].hidden = true
tt.bullet.mod = "mod_crystal_serpent"
tt.bullet.flight_time = fts(17)
tt.bullet.particles_name = "ps_bullet_crystal_serpent_fly"
tt.main_script.update = bullet_crystal_serpent_update

tt = E:register_t_hot("decal_s09_crystal_debris", "decal_tween", true)
tt.render.sprites[1].name = "decal_s09_crystal_debris_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = vec_2(16, 12)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_s09_crystal_debris_1"
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = vec_2(-14, 9)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "decal_s09_crystal_debris_2"
tt.render.sprites[3].offset = vec_2(2, 42)
tt.render.sprites[3].time_offset = fts(-2)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "decal_s09_crystal_debris_2"
tt.render.sprites[4].flip_x = true
tt.render.sprites[4].offset = vec_2(-32, 46)
tt.render.sprites[4].time_offset = fts(-2)
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].name = "stage9_crystals_smoke"
tt.render.sprites[5].animated = false
tt.render.sprites[5].offset = vec_2(0, 30)
tt.tween.props[1].keys = {{fts(27), 255}, {fts(35), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 5
tt.tween.props[2].keys = {{0, 0}, {fts(1), 255}, {fts(8), 255}, {fts(16), 0}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 5
tt.tween.props[3].keys = {{0, vec_2(0.3, 0.3)}, {fts(16), vec_2(1.03, 1.03)}}
tt.tween.props[4] = table.clone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.clone(tt.tween.props[1])
tt.tween.props[5].sprite_id = 3
tt.tween.props[6] = table.clone(tt.tween.props[1])
tt.tween.props[6].sprite_id = 4

tt = E:register_t_hot("decal_s09_crystal_debris_mod", "decal_s09_crystal_debris", true)
tt.render.sprites[3].sort_y_offset = 1
tt.render.sprites[4].sort_y_offset = 1

