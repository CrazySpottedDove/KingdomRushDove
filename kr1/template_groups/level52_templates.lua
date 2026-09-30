local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local SU = require("script_utils")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_george_jungle_update(this, store)
	local clicks = 0
	local max_clicks = math.random(this.final_clicks[1], this.final_clicks[2])
	local play_ts = store.tick_ts
	local play_time = U.frandom(this.play_time[1], this.play_time[2])
	local sid_liana, sid_fall, sid_bush = 1, 2, 3
	local s_liana, s_fall = this.render.sprites[1], this.render.sprites[2]
	local dx = store.visible_coords.right - REF_W
	local ox, oy = s_liana.offset.x, s_liana.offset.y
	this.tween.props[2].keys[1][2] = v(ox + dx, oy)
	this.tween.props[2].keys[2][2] = v(ox, oy)
	s_liana.offset.x, s_liana.offset.y = ox + dx, oy
	local rect = this.ui.click_rect
	rect.pos.x = ox + dx + 60
	rect.pos.y = REF_H - rect.size.y
	while true do
		if this.ui.clicked then
			clicks = clicks + 1
			if max_clicks <= clicks then
				S:queue("ElvesSpecialGeorgeFall")
				this.tween.ts = store.tick_ts
				this.tween.disabled = nil
				U.y_wait_unconditional(store, this.tween.props[1].keys[2][1])
				U.y_animation_play(this, "start", nil, store.tick_ts, 1, sid_liana)
				U.animation_start(this, "release", nil, store.tick_ts, false, sid_liana)
				s_fall.hidden = nil
				U.animation_start(this, "fall", nil, store.tick_ts, false, sid_fall)
				U.y_animation_wait(this, sid_liana)
				s_liana.hidden = true
				U.y_animation_wait(this, sid_fall)
				s_fall.hidden = true
				U.y_animation_play(this, "play", nil, store.tick_ts, 1, sid_bush)
				U.animation_start(this, "idle", nil, store.tick_ts, true, sid_bush)
				break
			else
				U.y_animation_play(this, "click", nil, store.tick_ts, 1, sid_liana)
				U.animation_start(this, "idle", nil, store.tick_ts, true, sid_liana)
			end
			this.ui.clicked = nil
			play_ts = store.tick_ts
		end
		if play_time < store.tick_ts - play_ts then
			play_ts = store.tick_ts
			play_time = U.frandom(this.play_time[1], this.play_time[2])
			U.y_animation_play(this, "click", nil, store.tick_ts, 1, sid_liana)
			U.animation_start(this, "idle", nil, store.tick_ts, true, sid_liana)
			this.ui.clicked = nil
		end
		coroutine.yield()
	end
end
local function decal_tree_ewok_update(this, store)
	local a = this.ranged.attacks[1]
	a.ts = store.tick_ts
	local wait_ts = -this.wait_time
	this.nav_path.pi = this.path_id
	this.nav_path.spi = 1
	this.nav_path.ni = 1
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
	while true do
		if store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store, this.ranged_center, a.min_range, a.max_range, a.vis_flags, a.vis_bans)
			if target then
				a.ts = store.tick_ts
				local node_offset = P:predict_enemy_node_advance(target, nil)
				local pred_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
				local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)
				U.animation_start_default(this, an, af, store.tick_ts, false)
				S:queue(a.sound)
				U.y_wait_unconditional(store, a.shoot_time)
				local bo = a.bullet_start_offset[ai]
				local b = E:create_entity(a.bullet)
				b.pos = v(this.pos.x + bo.x, this.pos.y + bo.y)
				b.bullet.to = v(pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y)
				b.bullet.from = V.vclone(b.pos)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				simulation:queue_insert_entity(b)
				U.y_animation_wait_default(this)
			end
		end
		if store.tick_ts - wait_ts > this.wait_time then
			U.y_animation_play(this, table.random(this.dance_animations), nil, store.tick_ts, 2)
			while SU.y_enemy_walk_step_default(store, this) do
				coroutine.yield()
			end
			this.nav_path.dir = -1 * this.nav_path.dir
			wait_ts = store.tick_ts
		end
		U.animation_start_default(this, "idle", false, store.tick_ts, true)
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s04_land_1", "decal_background", true)
AC(tt, "tween")
tt.render.sprites[1].name = "Stage04_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.editor.game_mode = 1
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = E:register_t_hot("decal_s04_land_2", "decal_s04_land_1", true)
tt.render.sprites[1].name = "Stage04_0004"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t_hot("decal_s04_tree_burn", "decal_timed", true)
AC(tt, "editor")
tt.render.sprites[1].prefix = "decal_s04_tree_burn"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].scale = vec_2(1, 1)
tt.timed.runs = INT_32_MAX
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].scale", PT_COORDS}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt = E:register_t_hot("decal_s04_charcoal_1", "decal_tween", true)
AC(tt, "editor")
tt.render.sprites[1].name = "stage4_fire_decal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(1, 1)
tt.render.sprites[1].z = Z_BACKGROUND + 1
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.4, 255}, {1.7, 0}}
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].scale", PT_COORDS}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt = E:register_t_hot("decal_s04_charcoal_2", "decal_s04_charcoal_1", true)
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt = E:register_t_hot("decal_s04_charcoal_3", "decal_s04_charcoal_1", true)
tt.render.sprites[1].name = "stage4_fire_decal_0003"
tt = E:register_t_hot("fx_torch_gnoll_burner_explosion_stage04", "fx", true)
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion_stage04"
tt = E:register_t_hot("fx_s04_tree_fire_1", "decal_timed", true)
AC(tt, "editor")
tt.timed.runs = INT_32_MAX
tt.render.sprites[1].name = "fx_s04_tree_fire_1"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
tt = E:register_t_hot("fx_s04_tree_fire_2", "fx_s04_tree_fire_1", true)
tt.render.sprites[1].name = "fx_s04_tree_fire_2"
tt = E:register_t_hot("decal_george_jungle", "decal_scripted", true)
AC(tt, "ui", "tween")
tt.main_script.update = decal_george_jungle_update
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].prefix = "decal_george_jungle_liana"
tt.render.sprites[1].r = 50 * math.pi / 180
tt.render.sprites[1].offset = vec_2(768, 830)
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_george_jungle"
tt.render.sprites[2].name = "fall"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = vec_2(566, 457)
tt.render.sprites[2].sort_y = 343
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "decal_george_jungle_bush"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor.y = 0
tt.render.sprites[3].offset = vec_2(553, 296)
tt.render.sprites[3].sort_y = 296
tt.final_clicks = {3, 5}
tt.play_time = {3, 5}
tt.ui.click_rect = r(0, 0, 200, 120)
tt.ui.can_select = false
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "r"
tt.tween.props[1].keys = {{0, 50 * math.pi / 180}, {0.3, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(0, 0)}, {0.3, v(0, 0)}}
tt.achievement = "GEORGE_FALL"
tt = E:register_t_hot("decal_tree_ewok", "decal_scripted", true)
AC(tt, "motion", "nav_path", "ranged", "unit")
tt.main_script.update = decal_tree_ewok_update
tt.render.sprites[1].anchor.y = 0.083333
tt.render.sprites[1].prefix = "decal_tree_ewok"
tt.ranged.attacks[1].min_range = 150
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].bullet = "spear_tree_ewok"
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 15)}
tt.wait_time = 5
tt.dance_animations = {"dance1", "dance2"}
tt.ranged_center = vec_2(550, 380)
tt.motion.max_speed = 45
local km = require("lib.klua.macros")
tt = E:register_t_hot("spear_tree_ewok", "arrow", true)
tt.bullet.damage_max = 10
tt.bullet.hit_chance = 0.4
tt.bullet.miss_decal = "ewok_2_proy_0002"
tt.bullet.flight_time = fts(33)
tt.render.sprites[1].name = "ewok_2_proy_0001"
tt.sound_events.insert = "AxeSound"
