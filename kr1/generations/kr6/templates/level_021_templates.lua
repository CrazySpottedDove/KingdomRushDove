local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local S = require("sound_db")
local P = require("path_db")
local GR = require("grid_db")
local LU = require("level_utils")
local SU = require("script_utils")
local scripts = require("scripts")
local signal = require("lib.hump.signal")
local km = require("lib.klua.macros")

require("all.constants")
require("lib.klua.table")

local v, vv = V.v, V.vv
local fts = U.fts

local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, d)
	store.damage_queue[#store.damage_queue + 1] = d
end

local function shuffle_table(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

local tt

-- =====================================================================
-- 静态装饰
-- =====================================================================
local STATIC_DECALS = {
	{"decal_stage_221_medio_camp", "stage221_1_medio_camp", Z_BACKGROUND_BETWEEN, 1},
	{"decal_stage_221_1_medio_camp_2", "stage221_1_medio_camp_2", Z_BACKGROUND_BETWEEN, 2},
	{"decal_stage_221_2_puerta", "stage221_2_puerta", Z_BACKGROUND_BETWEEN, 3},
	{"decal_stage_221_3_campamento", "stage221_3_campamento_2", Z_BACKGROUND_BETWEEN, 4},
	{"decal_stage_221_4_campamento", "stage221_4_campamento_3", Z_BACKGROUND_BETWEEN, 5},
	{"decal_stage221_7_camino_boss", "stage221_7_camino_boss", Z_BACKGROUND_BETWEEN, nil},
	{"decal_stage_221_spawner", "stage221_1_spawner", Z_OBJECTS, -10},
	{"decal_stage_221_fortaleza", "stage221_2_fortaleza", Z_OBJECTS, 50},
	{"decal_stage_221_3", "stage221_3", Z_OBJECTS, -17},
	{"decal_stage_221_4", "stage221_4", Z_OBJECTS, -157},
	{"decal_stage_221_5", "stage221_5", Z_OBJECTS, -180},
	{"decal_stage_221_6", "stage221_6", Z_OBJECTS, -168},
	{"decal_stage_221_8_spawner_2", "stage221_8_spawner_2", Z_OBJECTS, -185},
	{"decal_stage_221_9", "stage221_9", Z_OBJECTS, -102},
	{"decal_stage_221_10", "stage221_10", Z_OBJECTS, -147},
	{"decal_stage_221_11_spawner_3", "stage221_11_spawner_3", Z_OBJECTS, -165},
	{"decal_stage_221_12_spawner_4", "stage221_12_spawner_4", Z_OBJECTS, 165},
	{"decal_stage_221_13_spawner_5", "stage221_13_spawner_5", Z_OBJECTS, -44},
	{"decal_stage_221_14_spawner_6", "stage221_14_spawner_6", Z_OBJECTS, 142},
	{"decal_stage_221_15", "stage221_15", Z_OBJECTS, -78},
	{"decal_stage_221_16_spawner_7", "stage221_16_spawner_7", Z_OBJECTS, -112},
	{"decal_stage_221_kingpin_throne_mask", "stage221_kingpin_throne", Z_OBJECTS, nil}
}

for _, def in ipairs(STATIC_DECALS) do
	tt = E:register_t(def[1], "decal", true)
	tt.render.sprites[1].name = def[2]
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].z = def[3]

	if def[4] then
		tt.render.sprites[1].sort_y_offset = def[4]
	end

	if def[1] == "decal_stage221_7_camino_boss" then
		tt.render.sprites[1].hidden = true
	end
end

-- =====================================================================
-- 受惊/奴隶等动画装饰
-- =====================================================================
local function decal_stage_221_scared_update(this, store)
	local s = this.render.sprites[1]

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while not this.scared do
		coroutine.yield()
	end

	U.y_animation_play(this, "scared", nil, store.tick_ts, 1)

	if this.scared_hold then
		return
	end

	U.y_ease_key(store, s, "alpha", s.alpha, 0, this.scared_fade_out or fts(3))
	U.sprites_hide(this)
end

local EXO_DECALS = {
	{"decal_stage_221_bandit_fire_1", "stage_3_bandit_fire_1Def", nil},
	{"decal_stage_221_bandit_fire_2", "stage_3_bandit_fire_2Def", nil},
	{"decal_stage_221_bandit_horse", "stage_3_bandit_horseDef", nil},
	{"decal_stage_221_bandit_recostado", "stage_3_bandit_recostadoDef", -24},
	{"decal_stage_221_cuerdaropa_bandit", "stage_3_cuerdaropa_banditDef", nil},
	{"decal_stage_221_horse_1", "stage_3_horse_1Def", nil},
	{"decal_stage_221_horse_2", "stage_3_horse_2Def", nil},
	{"decal_stage_221_jarron_boss_1", "stage_3_jarron_boss_1Def", nil},
	{"decal_stage_221_jarron_boss_2", "stage_3_jarron_boss_2Def", nil},
	{"decal_stage_221_shadowblade_blackguard", "stage_3_shadowblade_blackguardDef", nil},
	{"decal_stage_221_shadowblade_sitting", "stage_3_shadowblade_sittingDef", nil}
}

for _, def in ipairs(EXO_DECALS) do
	tt = E:register_t(def[1], "decal", true)

	AC(tt, "main_script")

	tt.main_script.update = decal_stage_221_scared_update
	tt.render.sprites[1].prefix = def[2]
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS

	if def[3] then
		tt.render.sprites[1].sort_y_offset = def[3]
	end

	if def[1] == "decal_stage_221_horse_1" or def[1] == "decal_stage_221_horse_2" then
		tt.scared_hold = true
	end
end

-- esclavos
local function decal_stage_221_esclavos_update(this, store, script)
	local d = this.delayed_play

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	while not d.no_boss do
		coroutine.yield()
	end

	if not this._no_boss_start then
		U.y_animation_play(this, d.play_animation, nil, store.tick_ts, 1)
	end

	U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)
end

tt = E:register_t("decal_stage_221_esclavos", "decal", true)
AC(tt, "main_script", "delayed_play")
tt.main_script.update = decal_stage_221_esclavos_update
tt.render.sprites[1].prefix = "stage_3_esclavosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt.delayed_play.idle_animation = "idle_no_boss"
tt.delayed_play.play_animation = "in_no_boss"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 25

-- =====================================================================
-- 王座（桶/陷阱门/buff 奴隶）
-- =====================================================================
local function stage_221_pick_barrel_dest(this, store, req)
	local bb = this.barrel
	local zone = bb.zones[req.zone]

	if not zone then
		return nil
	end

	local friends = U.find_soldiers_in_range(store.soldiers, zone.pos, 0, zone.range, bor(F_BLOCK, F_AREA), bor(F_FLYING))
	local tx, ty

	if friends then
		local f = friends[math.random(#friends)]
		tx, ty = f.pos.x, f.pos.y
	else
		local ok, tries = false, 0

		while not ok and tries < 8 do
			tries = tries + 1

			local ang = math.random() * 2 * math.pi
			local rr = zone.range * math.sqrt(math.random())

			tx, ty = zone.pos.x + math.cos(ang) * rr, zone.pos.y + math.sin(ang) * rr

			local near = GR:cell_is(tx, ty, bor(TERRAIN_LAND)) and P:nearest_nodes(tx, ty, bb.paths, {1}, true, NF_RALLY)[1]
			ok = near and near[4] < P:path_width(near[1], 1, near[3])
		end

		if not ok then
			return nil
		end
	end

	local nodes = P:nearest_nodes(tx, ty, bb.paths, {1}, true)

	if not nodes or #nodes == 0 then
		nodes = P:nearest_nodes(tx, ty, bb.paths, {1}, false)
	end

	if not nodes or #nodes == 0 then
		return nil
	end

	local pi, _, ni = nodes[1][1], nodes[1][2], nodes[1][3]

	return {
		pi = pi,
		ni = ni,
		pos = P:node_pos(pi, 1, ni)
	}
end

local function stage_221_spawn_barrel_sign(this, store, dest)
	local sign = E:create_entity("decal_stage_221_barrel_sign")
	sign.pos = V.v(dest.pos.x, dest.pos.y)
	queue_insert(store, sign)
	return sign
end

local function stage_221_throw_barrel(this, store, req, dest)
	local bb = this.barrel
	local bullet = E:create_entity("bullet_stage_221_barrel")

	bullet.pos = V.vclone(bb.from)
	bullet.bullet.from = V.vclone(bb.from)
	bullet.bullet.to = V.v(dest.pos.x, dest.pos.y)
	bullet.bullet.source_id = this.id
	bullet.barrel_spawn = {
		enemy_t = req.enemy_t,
		pi = dest.pi,
		ni = dest.ni
	}

	queue_insert(store, bullet)

	return bullet
end

local function stage_221_buff_slaves(this, store)
	local bs = this.buff_slaves
	local targets = U.find_enemies_in_range(store, this.pos, 0, bs.range, 0, 0, function(e)
		return P:get_end_node(e.nav_path.pi) - e.nav_path.ni >= bs.safe_nodes_to_exit
	end)

	if not targets then
		return
	end

	shuffle_table(targets)

	for i = 1, math.min(bs.max_enemies, #targets) do
		for _, mod_name in ipairs(this.buff_slaves_mods) do
			local mod = E:create_entity(mod_name)
			mod.modifier.target_id = targets[i].id
			mod.modifier.source_id = this.id
			queue_insert(store, mod)
		end
	end
end

local function stage_221_y_animation_play_sounds(this, store, name, sounds)
	local start_ts = store.tick_ts

	U.animation_start(this, name, nil, start_ts, false, nil, true)

	local i = 1

	repeat
		while sounds[i] and store.tick_ts - start_ts >= sounds[i][1] do
			S:queue(sounds[i][2])
			i = i + 1
		end
		coroutine.yield()
	until U.animation_finished(this)
end

local function decal_stage_221_boss_throne_on_throw_barrel(this, store, action, enemy_t, zone_id)
	this.barrel_queue = this.barrel_queue or {}
	table.insert(this.barrel_queue, {
		enemy_t = enemy_t,
		zone = tonumber(zone_id)
	})
end

local function decal_stage_221_boss_throne_on_call_trapdoors(this, store, action)
	this.trapdoors_queued = (this.trapdoors_queued or 0) + 1
end

local function decal_stage_221_boss_throne_on_buff_slaves(this, store, action)
	this.buffs_queued = (this.buffs_queued or 0) + 1
end

local function decal_stage_221_boss_throne_update(this, store, script)
	local d = this.delayed_play

	this.barrel_queue = this.barrel_queue or {}
	this.trapdoors_queued = this.trapdoors_queued or 0
	this.buffs_queued = this.buffs_queued or 0

	U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

	local play_ts = store.tick_ts
	local delay = U.frandom(d.min_delay, d.max_delay)

	while not d.disabled do
		if this._angry_queued then
			this._angry_queued = nil

			U.y_animation_play(this, "emote_angry_in", nil, store.tick_ts, 1)
			U.animation_start(this, "emote_angry_loop", nil, store.tick_ts, true)

			while not this._angry_release do
				coroutine.yield()
			end

			this._angry_release = nil

			U.y_animation_play(this, "emote_angry_out", nil, store.tick_ts, 1)

			this._angry_done = true

			U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

			play_ts = store.tick_ts
			delay = U.frandom(d.min_delay, d.max_delay)
		elseif #this.barrel_queue > 0 then
			local req = table.remove(this.barrel_queue, 1)
			local dest = stage_221_pick_barrel_dest(this, store, req)

			if dest then
				U.y_animation_play(this, "event_barrel_in", nil, store.tick_ts, 1)
				U.animation_start(this, "event_barrel_loop", nil, store.tick_ts, true)

				local sign = stage_221_spawn_barrel_sign(this, store, dest)

				U.y_wait(store, this.barrel.sign_lead)

				local bullet = stage_221_throw_barrel(this, store, req, dest)

				U.y_wait(store, fts(1))
				U.animation_start(this, "event_barrel_end", nil, store.tick_ts, false)
				S:queue(this.barrel_throw_sound)

				bullet.barrel_sign_id = sign.id

				U.y_animation_wait(this)
			end

			U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

			play_ts = store.tick_ts
			delay = U.frandom(d.min_delay, d.max_delay)
		elseif this.trapdoors_queued > 0 then
			this.trapdoors_queued = this.trapdoors_queued - 1
			this.trapdoors_playing = true

			stage_221_y_animation_play_sounds(this, store, "event_trapdoors", this.trapdoors_sounds)

			this.trapdoors_playing = nil

			U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

			play_ts = store.tick_ts
			delay = U.frandom(d.min_delay, d.max_delay)
		elseif this.buffs_queued > 0 then
			this.buffs_queued = this.buffs_queued - 1

			U.animation_start(this, "event_buff_creeps", nil, store.tick_ts, false)
			U.y_wait(store, this.buff_slaves_cast_sound_time)
			S:queue(this.buff_slaves_cast_sound)
			U.y_wait(store, this.buff_slaves_cast_time - this.buff_slaves_cast_sound_time)
			stage_221_buff_slaves(this, store)
			U.y_wait(store, this.buff_slaves_sound_time - this.buff_slaves_cast_time)
			S:queue(this.buff_slaves_sound)
			U.y_animation_wait(this)
			U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

			play_ts = store.tick_ts
			delay = U.frandom(d.min_delay, d.max_delay)
		elseif not this._hold_idle and delay < store.tick_ts - play_ts then
			U.y_animation_play(this, d.play_animation .. "in", nil, store.tick_ts, 1)
			U.animation_start(this, d.play_animation .. "loop", nil, store.tick_ts, true)
			U.y_wait(store, math.random(3, 5))
			U.y_animation_play(this, d.play_animation .. "out", nil, store.tick_ts, 1)
			U.animation_start(this, d.idle_animation, nil, store.tick_ts, true)

			play_ts = store.tick_ts
			delay = U.frandom(d.min_delay, d.max_delay)
		end

		coroutine.yield()
	end

	while #this.barrel_queue > 0 do
		local req = table.remove(this.barrel_queue, 1)
		local dest = stage_221_pick_barrel_dest(this, store, req)

		if dest then
			stage_221_throw_barrel(this, store, req, dest)
		end
	end

	d.ready = true

	while not d.go do
		coroutine.yield()
	end

	d.jump_started = true

	stage_221_y_animation_play_sounds(this, store, "throne_out", this.throne_out_sounds)

	d.finished = true

	queue_remove(store, this)
end

local BARREL = {
	damage_max = 80,
	damage_radius = 70,
	damage_min = 40,
	spawn_stun = 1,
	sign_lead = 3,
	from = v(885, 705),
	damage_type = DAMAGE_EXPLOSION,
	paths = {
		1,
		2,
		3,
		4,
		5,
		6,
		12,
		13,
		14,
		15,
		16,
		17,
		18,
		19,
		20,
		21,
		22,
		23
	},
	zones = {{
		range = 75,
		pos = v(484, 570)
	}, {
		range = 180,
		pos = v(190, 387)
	}, {
		range = 75,
		pos = v(710, 297)
	}}
}

tt = E:register_t("decal_stage_221_boss_throne", "decal", true)
AC(tt, "main_script", "delayed_play", "events")
tt.main_script.update = decal_stage_221_boss_throne_update
tt.events.list[1].name = "throw_barrel"
tt.events.list[1].on_event = decal_stage_221_boss_throne_on_throw_barrel
tt.events.list[2] = {}
tt.events.list[2].name = "call_trapdoors"
tt.events.list[2].on_event = decal_stage_221_boss_throne_on_call_trapdoors
tt.events.list[3] = {}
tt.events.list[3].name = "buff_slaves"
tt.events.list[3].on_event = decal_stage_221_boss_throne_on_buff_slaves
tt.barrel = BARREL
tt.buff_slaves = {
	dmg_factor = 1.5,
	speed_factor = 1.5,
	duration = 5,
	range = 1200,
	max_enemies = 10,
	safe_nodes_to_exit = 15
}
tt.buff_slaves_cast_time = fts(45)
tt.buff_slaves_cast_sound_time = fts(36)
tt.buff_slaves_cast_sound = "Stage21BossKingpinBuffCast"
tt.buff_slaves_sound_time = fts(159)
tt.buff_slaves_sound = "Stage21BossKingpinBuffMuscleKiss"
tt.barrel_throw_sound = "Stage21BossKingpinBarrelCast"
tt.trapdoors_sounds = {{fts(78), "Stage21BossKingpinSpawnGong"}}
tt.buff_slaves_mods = {"mod_stage_21_buff_slaves_damage", "mod_stage_21_buff_slaves_speed"}
tt.render.sprites[1].prefix = "kingpin_boss_throneDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "taunt_laugh_"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 25
tt.throne_out_duration = fts(247)
tt.throne_out_sounds = {{fts(157), "Stage21PreBossKingpinClap"}, {fts(169), "Stage21PreBossKingpinClap"}, {fts(194), "Stage21PreBossKingpinBoneCrack"}, {fts(228), "Stage21PreBossKingpinGoldDiveJump"}}

-- =====================================================================
-- kingpin 炸弹 / 效果
-- =====================================================================
local function decal_stage_221_kingpin_bomb_update(this, store)
	local s = this.render.sprites[1]
	local start_ts = store.tick_ts
	local from, to, t = this.from, this.to, this.flight_time

	while true do
		local phase = km.clamp(0, 1, (store.tick_ts - start_ts) / t)

		this.pos.x = from.x + (to.x - from.x) * phase
		this.pos.y = from.y + (to.y - from.y) * phase + this.arc_height * 4 * phase * (1 - phase)
		s.r = s.r + this.rotation_speed * store.tick_length

		if phase >= 1 then
			break
		end

		coroutine.yield()
	end

	S:queue(this.hit_sound)

	local fx = E:create_entity(this.hit_fx)
	fx.pos = V.vclone(to)
	fx.on_cover = this.on_hit
	queue_insert(store, fx)

	this.hit = true

	queue_remove(store, this)
end

tt = E:register_t("decal_stage_221_kingpin_bomb", "decal_scripted", true)
tt.main_script.update = decal_stage_221_kingpin_bomb_update
tt.flight_time = 0.8
tt.arc_height = 150
tt.rotation_speed = -12
tt.hit_fx = "fx_stage_221_destroy_camp"
tt.hit_sound = "Stage21IntroHuntersBombsExplosion"
tt.render.sprites[1].prefix = "kingpin_bombDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS

local function fx_stage_221_destroy_camp_update(this, store)
	local s = this.render.sprites[1]

	U.animation_start(this, "run", nil, store.tick_ts, false)

	if this.on_cover then
		U.y_wait(store, this.cover_time)
		this.on_cover(store)
	end

	U.y_animation_wait(this)
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	U.y_wait(store, this.hold)
	U.y_ease_key(store, s, "alpha", 255, 0, this.fade_out, "quad-in")
	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_destroy_camp", "decal_scripted", true)
tt.main_script.update = fx_stage_221_destroy_camp_update
tt.hold = 1.5
tt.fade_out = 1
tt.cover_time = fts(2)
tt.render.sprites[1].prefix = "kingpin_destroy_campDef"
tt.render.sprites[1].offset = v(-15, 40)
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS

local function fx_stage_221_cine_explosion_update(this, store)
	local s = this.render.sprites[1]
	local start_ts = store.tick_ts

	U.animation_start(this, s.name, nil, start_ts, false)

	local events = {}

	for _, c in ipairs(this.calls or {}) do
		table.insert(events, c)
	end

	for _, sh in ipairs(this.shakes or {}) do
		table.insert(events, sh)
	end

	table.sort(events, function(a, b)
		return a.t < b.t
	end)

	for _, ev in ipairs(events) do
		U.y_wait(store, ev.t - (store.tick_ts - start_ts))

		if ev.fn then
			ev.fn(store)
		else
			S:queue(this.explosion_sound, {
				delay = this.explosion_sound_delay
			})

			local shake = E:create_entity("aura_screen_shake")
			shake.aura.amplitude = ev.amplitude
			shake.aura.duration = ev.duration
			shake.aura.freq_factor = ev.freq_factor or 3
			queue_insert(store, shake)
		end
	end

	U.y_animation_wait(this)
	U.y_ease_key(store, s, "alpha", 255, 0, this.fade_out, "quad-in")
	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_cine_explosion", "decal_scripted", true)
tt.main_script.update = fx_stage_221_cine_explosion_update
tt.pos = v(512, 384)
tt.fade_out = 0.5
tt.explosion_sound = "Stage21IntroHuntersBombsExplosion"
tt.explosion_sound_delay = 0.15
tt.render.sprites[1].prefix = "stage_221_cine_explosion_introDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS

local function fx_stage_221_mask_fade_update(this, store)
	local start_ts = store.tick_ts

	while true do
		local phase = km.clamp(0, 1, (store.tick_ts - start_ts) / this.fade_time)

		for _, e in ipairs(this.targets) do
			for _, s in ipairs(e.render.sprites) do
				s.alpha = 255 * (1 - phase)
			end
		end

		if phase >= 1 then
			break
		end

		coroutine.yield()
	end

	for _, e in ipairs(this.targets) do
		U.sprites_hide(e)
	end

	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_mask_fade")
AC(tt, "main_script")
tt.main_script.update = fx_stage_221_mask_fade_update
tt.fade_time = 0.15

local function fx_stage_221_cine_pip_update(this, store)
	local s = this.render.sprites[1]
	local ox, oy = this.screen_offset.x, this.screen_offset.y

	if store.safe_frame then
		ox = math.max(ox, store.safe_frame.lb)
	end

	local left, bottom = 0, 0

	if this.over_curtains then
		local cvl = store.curtain_visible_limits
		left, bottom = cvl and cvl.left or 0, cvl and cvl.bottom or 0
	elseif game and game.game_gui then
		local gg = game.game_gui
		left = -game.game_ref_origin.x / gg.gui_scale
		bottom = REF_H - gg.sh
	end

	s.pos.x = left + ox
	s.pos.y = bottom + oy

	stage_221_y_animation_play_sounds(this, store, s.name, this.run_sounds)
	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_cine_pip", "decal_scripted", true)
tt.main_script.update = fx_stage_221_cine_pip_update
tt.screen_offset = v(90, 30)
tt.over_curtains = true
tt.run_sounds = {{fts(76), "Stage21IntroHuntersBombsThrow"}}
tt.render.sprites[1].prefix = "stage_221_cine_pipDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].pos = v(0, 0)

tt = E:register_t("fx_stage_221_sentinels", "fx", true)
tt.render.sprites[1].name = "fx_sentinels_run"
tt.render.sprites[1].sort_y_offset = -105

tt = E:register_t("fx_stage_221_kingpin_cart_explosion", "fx", true)
tt.render.sprites[1].prefix = "kingpin_explosion_polvoDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(-6, -12)
tt.render.sprites[1].scale = vv(1.1)
tt.render.sprites[1].sort_y_offset = -2

tt = E:register_t("fx_stage_221_barrel_explosion", "fx", true)
tt.render.sprites[1].prefix = "kingpin_barril_bossDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = E:register_t("decal_stage_221_barrel_area_crack", "fx", true)
tt.render.sprites[1].prefix = "kingpin_decal_rotura_piso_barrilDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

-- barrel sign
local function decal_stage_221_barrel_sign_update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
end

tt = E:register_t("decal_stage_221_barrel_sign", "decal", true)
AC(tt, "main_script")
tt.main_script.update = decal_stage_221_barrel_sign_update
tt.render.sprites[1].prefix = "kingpin_barril_markerDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

-- dust traps
local function fx_stage_221_dust_traps_update(this, store)
	local s = this.render.sprites[1]

	s.alpha = 0

	U.animation_start(this, "run", nil, store.tick_ts, true)

	local d = this.trapdoor_spawn

	if d and this.trapdoor_offset then
		local flip = P:node_pos(d.pi, d.spi, d.ni + 1).x < P:node_pos(d.pi, d.spi, d.ni).x
		s.offset.x = flip and -this.trapdoor_offset.x or this.trapdoor_offset.x
		s.offset.y = this.trapdoor_offset.y
	end

	local function spawn_trapdoor()
		if d then
			local fx = E:create_entity("fx_stage_221_trapdoor")
			fx.pos = V.vclone(this.pos)
			fx.trapdoor_spawn = d
			queue_insert(store, fx)
			d = nil
		end
	end

	local lead = this.trapdoor_lead or 0

	U.y_ease_key(store, s, "alpha", 0, 255, this.fade_in, "quad-in")

	local hold = this.hold or 0

	if lead > this.fade_out then
		local pre = math.max(0, hold - (lead - this.fade_out))

		if pre > 0 then
			U.y_wait(store, pre)
		end

		spawn_trapdoor()

		hold = hold - pre
	end

	if hold > 0 then
		U.y_wait(store, hold)
	end

	U.y_ease_key(store, s, "alpha", 255, 0, this.fade_out, "quad-in", function(dt)
		if this.fade_out - dt <= lead then
			spawn_trapdoor()
		end
	end)
	spawn_trapdoor()
	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_dust_traps", "decal_scripted", true)
tt.main_script.update = fx_stage_221_dust_traps_update
tt.fade_in = 0.3
tt.hold = 1.8
tt.fade_out = 0.3
tt.trapdoor_lead = 0.6
tt.trapdoor_offset = v(-18, 5)
tt.render.sprites[1].prefix = "kingpin_tierra_trickster_2Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

local function fx_stage_221_trapdoor_update(this, store)
	local d = this.trapdoor_spawn
	local door, creep = this.render.sprites[2], this.render.sprites[3]
	local flip = false

	if d then
		local vx = P:node_pos(d.pi, d.spi, d.ni + 1).x - P:node_pos(d.pi, d.spi, d.ni).x
		flip = vx < 0
	end

	local c = d and d.controller

	U.y_animation_play(this, "in", flip, store.tick_ts, 1, 1)

	if not c or store.tick_ts - (c._trapdoor_rumble_ts or -1000000000) > 0.5 then
		if c then
			c._trapdoor_rumble_ts = store.tick_ts
		end
		S:queue(this.rumble_sound)
	end

	U.y_animation_play(this, "loop", flip, store.tick_ts, this.anticipation_loops, 1)
	U.animation_start(this, "idle", flip, store.tick_ts, true, 1)

	if not c or store.tick_ts - (c._trapdoor_open_ts or -1000000000) > 0.5 then
		if c then
			c._trapdoor_open_ts = store.tick_ts
		end
		S:queue(this.open_sound)
	end

	door.hidden = false
	creep.hidden = false

	U.animation_start(this, "in", flip, store.tick_ts, false, 2)
	U.y_animation_play(this, "in", flip, store.tick_ts, 1, 3)

	if d and not d.controller._spawns_stopped then
		local enemy = E:create_entity(d.enemy_t)

		if enemy then
			enemy.nav_path.pi = d.pi
			enemy.nav_path.spi = d.spi
			enemy.nav_path.ni = d.ni
			enemy.pos = P:node_pos(d.pi, d.spi, d.ni)

			queue_insert(store, enemy)
		end
	end

	U.y_wait(store, 0.015)

	creep.hidden = true

	U.y_animation_wait(this, 2)
	U.animation_start(this, "idle", nil, store.tick_ts, true, 2)
	U.y_wait(store, this.idle_time)
	U.animation_start(this, "out", nil, store.tick_ts, false, 2, true)
	U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
	queue_remove(store, this)
end

tt = E:register_t("fx_stage_221_trapdoor", "fx", true)
AC(tt, "main_script")
tt.main_script.update = fx_stage_221_trapdoor_update
tt.timed = nil
tt.anticipation_loops = 2
tt.idle_time = fts(4)
tt.rumble_sound = "Stage21TrapdoorsRumble"
tt.open_sound = "Stage21TrapdoorsOpen"
tt.render.sprites[1].prefix = "creep_trickster_trapdoor"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "creep_trickster_trapdoor_door"
tt.render.sprites[2].name = "in"
tt.render.sprites[2].animated = true
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].draw_order = 1
tt.render.sprites[2].sort_y_offset = 10
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "creep_trickster_trapdoor_creep"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].animated = true
tt.render.sprites[3].loop = false
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = 2
tt.render.sprites[3].sort_y_offset = 10
tt.render.sprites[3].hidden = true

-- =====================================================================
-- 公主俘虏
-- =====================================================================
local function decal_stage_221_princess_captives_update(this, store)
	local sp = this.render.sprites
	local P = "stage_221_princess_captives_"

	if this.play_in then
		sp[2].hidden, sp[3].hidden = true, true

		stage_221_y_animation_play_sounds(this, store, P .. "in", this.in_sounds)

		sp[2].hidden, sp[3].hidden = false, false
	end

	local loop_time = fts(66)
	local state, loops, last_angry = {}, {}, {}

	local function start(i, anim, loop, ts)
		state[i] = anim

		U.animation_start(this, P .. i .. "_" .. anim, nil, ts or store.tick_ts, loop, i, true)

		if anim == "loop_tired" then
			loops[i] = math.max(1, math.floor(U.frandom(this.angry_pause[1], this.angry_pause[2]) / loop_time + 0.5))
		elseif anim == "angry_1" or anim == "angry_2" then
			last_angry[i] = anim
		end
	end

	local first = {}

	for i = 1, 3 do
		first[i] = math.random() < 0.5 and "angry_1" or "angry_2"
	end

	if first[1] ~= "angry_1" and first[2] ~= "angry_1" and first[3] ~= "angry_1" then
		first[math.random(1, 3)] = "angry_1"
	end

	for i = 1, 3 do
		if this.play_in then
			start(i, first[i], false)
		else
			last_angry[i] = first[i]
			start(i, "loop_tired", true, store.tick_ts - U.frandom(0, loop_time))
		end
	end

	while true do
		for i = 1, 3 do
			local s = state[i]

			if s == "loop_tired" then
				if U.animation_finished(this, i, loops[i]) then
					start(i, last_angry[i] == "angry_1" and "angry_2" or "angry_1", false)
				end
			elseif U.animation_finished(this, i) then
				if s == "in_tired" then
					start(i, "loop_tired", true)
				else
					start(i, "in_tired", false)
				end
			end
		end

		coroutine.yield()
	end
end

tt = E:register_t("decal_stage_221_princess_captives", "decal", true)
AC(tt, "main_script")
tt.main_script.update = decal_stage_221_princess_captives_update

for i = 1, 3 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].name = "stage_221_princess_captives_" .. i .. "_loop_tired"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].z = Z_OBJECTS
end

tt.in_sounds = {{fts(50), "Stage21IntroPrincessKidnappingPostsUp"}}
tt.angry_pause = {4, 8}

-- =====================================================================
-- 木桶 bullet
-- =====================================================================
local function bullet_stage_221_barrel_update(this, store, script)
	local b = this.bullet
	local dmin, dmax, dradius = b.damage_min, b.damage_max, b.damage_radius

	if b.particles_name then
		local ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		queue_insert(store, ps)
	end

	local shadow, shadow_start_pos

	if this.decal_shadow then
		shadow = E:create_entity(this.decal_shadow)
		shadow.pos = V.vclone(b.from)
		shadow.pos.y = b.from.y - 70
		queue_insert(store, shadow)
		shadow_start_pos = V.vclone(shadow.pos)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end

		if shadow then
			local t = (store.tick_ts - b.ts) / b.flight_time
			shadow.pos.x = shadow_start_pos.x + (b.to.x - shadow_start_pos.x) * t
			shadow.pos.y = shadow_start_pos.y + (b.to.y - shadow_start_pos.y) * t
			shadow.render.sprites[1].scale = V.vv(km.clamp(0.6, 1, 40 / (this.pos.y - shadow.pos.y)))
		end
	end

	local friends = U.find_soldiers_in_range(store.soldiers, b.to, 0, dradius, b.damage_flags, b.damage_bans)

	if friends and dmax and dmax > 0 then
		for _, e in pairs(friends) do
			local d = E:create_entity("damage")
			d.damage_type = b.damage_type

			local f = U.dist_factor_inside_ellipse(e.pos, b.to, dradius)

			d.value = math.ceil((b.damage_factor or 1) * math.floor(dmax - (dmax - dmin) * f))
			d.source_id = this.id
			d.target_id = e.id

			queue_damage(store, d)
		end
	end

	if b.hit_fx then
		if this.sound_events and this.sound_events.hit then
			S:queue(this.sound_events.hit)
		end

		local sfx = E:create_entity(b.hit_fx)
		sfx.pos = V.vclone(b.to)

		for i = 1, #sfx.render.sprites do
			sfx.render.sprites[i].ts = store.tick_ts
		end

		queue_insert(store, sfx)
	end

	if b.hit_decal then
		local crack = E:create_entity(b.hit_decal)
		crack.pos = V.vclone(b.to)
		crack.render.sprites[1].ts = store.tick_ts
		queue_insert(store, crack)
	end

	local s = this.barrel_spawn

	if s then
		local enemy = E:create_entity(s.enemy_t)

		if enemy then
			enemy.nav_path.pi = s.pi
			enemy.nav_path.spi = 1
			enemy.nav_path.ni = s.ni
			enemy.pos = P:node_pos(s.pi, 1, s.ni)

			queue_insert(store, enemy)

			if b.spawn_stun and b.spawn_stun > 0 then
				local stun = E:create_entity("mod_stun")
				stun.modifier.target_id = enemy.id
				stun.modifier.source_id = this.id
				stun.modifier.duration = b.spawn_stun
				queue_insert(store, stun)
			end
		end
	end

	if shadow then
		queue_remove(store, shadow)
	end

	if this.barrel_sign_id then
		local sign = store.entities[this.barrel_sign_id]

		if sign then
			queue_remove(store, sign)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	if p then
		queue_insert(store, p)
	end

	queue_remove(store, this)
end

tt = E:register_t("bullet_stage_221_barrel", "bomb", true)
tt.bullet.from = BARREL.from
tt.render.sprites[1].name = "kingpin_boss_throne_asst_barril"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vv(1.2)
tt.main_script.insert = scripts.bomb.insert
tt.main_script.update = bullet_stage_221_barrel_update
tt.bullet.flight_time = fts(45)
tt.bullet.rotation_speed = 15
tt.bullet.damage_min = BARREL.damage_min
tt.bullet.damage_max = BARREL.damage_max
tt.bullet.damage_type = BARREL.damage_type
tt.bullet.damage_radius = BARREL.damage_radius
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_NONE
tt.bullet.damage_factor = 1
tt.bullet.spawn_stun = BARREL.spawn_stun
tt.bullet.hit_fx = "fx_stage_221_barrel_explosion"
tt.bullet.hit_decal = "decal_stage_221_barrel_area_crack"
tt.sound_events.hit = "Stage21BossKingpinBarrelImpact"

-- =====================================================================
-- 控制器
-- =====================================================================
local function controller_stage_221_update(this, store)
	this.spawn_queue = this.spawn_queue or {}

	local pending_show, pending_hide
	local WAVE6_ON_PATHS = {4, 5, 17, 18}
	local WAVE6_OFF_PATHS = {12, 13}

	for _, pi in ipairs(WAVE6_ON_PATHS) do
		P:deactivate_path(pi)
	end

	local wave6_paths_toggled = false

	while true do
		if pending_show == nil then
			pending_show, pending_hide = {}, {}

			for _, e in pairs(store.entities) do
				if e.show_at_wave then
					if e.tower and e.tower.type == "holder" then
						U.sprites_hide(e, 1, 2)
						e.ui.can_click = false
						e.tower.can_hover = false
					else
						U.sprites_hide(e)
					end

					table.insert(pending_show, e)
				end

				if e.hide_at_wave then
					table.insert(pending_hide, e)
				end
			end
		end

		local wg = this.visibility_wave or store.wave_group_number

		if not wave6_paths_toggled and wg >= 6 then
			wave6_paths_toggled = true
			this._wave6_open = true

			for _, pi in ipairs(WAVE6_ON_PATHS) do
				P:activate_path(pi)
			end

			for _, pi in ipairs(WAVE6_OFF_PATHS) do
				P:deactivate_path(pi)
			end

			if GR:load_file(LU.resolve_level_file(store, "level_021_fase_2", "_grid.lua")) then
				GR.waypoints_cache = {}
			end
		end

		for i = #pending_show, 1, -1 do
			local e = pending_show[i]

			if wg >= e.show_at_wave then
				if e._cine_show then
				-- block empty
				elseif e.tower and e.tower.type == "holder" then
					U.sprites_show(e, 1, 1)
					e.ui.can_click = true
					e.tower.can_hover = true
				else
					U.sprites_show(e)
				end

				table.remove(pending_show, i)
			end
		end

		for i = #pending_hide, 1, -1 do
			local e = pending_hide[i]

			if wg >= e.hide_at_wave then
				U.sprites_hide(e)
				queue_remove(store, e)
				table.remove(pending_hide, i)
			end
		end

		while #this.spawn_queue > 0 and not this._spawns_stopped do
			local req = table.remove(this.spawn_queue, 1)
			local is_watchtower = type(req.enemy_t) == "string" and req.enemy_t:sub(-10) == "watchtower"
			local spi = math.random(1, 3)

			if is_watchtower then
				local killed_any = false
				spi = 1

				for _, e in pairs(store.entities) do
					if e.enemy and e.nav_path and e.nav_path.pi == req.path_id and e.health and not e.health.dead and not e.pending_removal then
						e.health.hp = 0
						killed_any = true
					end
				end

				if killed_any then
					U.y_wait(store, this.kill_wait)
				end

				if this._spawns_stopped then
					break
				end
			end

			if req.enemy_t == "enemy_trickster" then
				local throne = LU.list_entities(store.entities, "decal_stage_221_boss_throne")[1]

				if throne and not throne.delayed_play.disabled and (throne.trapdoors_queued or 0) == 0 and not throne.trapdoors_playing then
					throne.trapdoors_queued = 1
				end

				local dust = E:create_entity("fx_stage_221_dust_traps")
				dust.pos = P:node_pos(req.path_id, spi, req.ni)

				if dust.pos.x < 280 then
					dust.render.sprites[1].prefix = "kingpin_tierra_trickster_1Def"
				end

				dust.trapdoor_spawn = {
					enemy_t = req.enemy_t,
					pi = req.path_id,
					spi = spi,
					ni = req.ni,
					controller = this
				}

				queue_insert(store, dust)
			else
				if is_watchtower and store.tick_ts - (this.watchtower_sound_ts or -1000000000) > 1 then
					this.watchtower_sound_ts = store.tick_ts
					S:queue(this.watchtower_spawn_sound)
				end

				local sentinels = E:create_entity("fx_stage_221_sentinels")
				sentinels.pos = P:node_pos(req.path_id, spi, req.ni)
				sentinels.render.sprites[1].ts = store.tick_ts
				queue_insert(store, sentinels)

				U.y_wait(store, fts(1))

				local enemy = not this._spawns_stopped and E:create_entity(req.enemy_t)

				if enemy then
					enemy.nav_path.pi = req.path_id
					enemy.nav_path.spi = spi
					enemy.nav_path.ni = req.ni
					enemy.pos = P:node_pos(req.path_id, spi, req.ni)
					queue_insert(store, enemy)
				end
			end
		end

		coroutine.yield()
	end
end

local function controller_stage_221_on_spawn_on_path(this, store, action, enemy_t, path_id, min_ni, max_ni, clear_range, max_tries)
	local pi = tonumber(path_id)
	local tries = tonumber(max_tries) or this.max_tries
	local range = tonumber(clear_range) or this.clear_range
	local ni

	for i = 1, tries do
		ni = math.random(tonumber(min_ni), tonumber(max_ni))

		local pos = P:node_pos(pi, 1, ni)
		local nearby = U.find_enemies_in_range(store, pos, 0, range, 0, 0)

		if not nearby then
			break
		end
	end

	this.spawn_queue = this.spawn_queue or {}

	table.insert(this.spawn_queue, {
		enemy_t = enemy_t,
		path_id = pi,
		ni = ni
	})
end

tt = E:register_t("controller_stage_221")
AC(tt, "main_script", "events")
tt.main_script.update = controller_stage_221_update
tt.max_tries = 2
tt.clear_range = 50
tt.kill_wait = 2
tt.watchtower_spawn_sound = "Stage21WatchtowerSpawn"
tt.events.list[1].name = "spawn_on_path"
tt.events.list[1].on_event = controller_stage_221_on_spawn_on_path

-- =====================================================================
-- 剧情兵 / 士兵 / buff mod
-- =====================================================================
tt = E:register_t("bandit_princess_blackguard_stage_221", "bandit_princess_bandit", true)
tt.render.sprites[1].name = "bandit_princess_blackguard_run"

tt = E:register_t("soldier_stage_21_hunter_reinforcement", "soldier_tower_update1_hunter_outpost", true)
AC(tt, "reinforcement")
tt.health.armor = 0
tt.health.hp_max = 150
tt.health.dead_lifetime = 12
tt.regen.health = 5
tt.motion.max_speed = 65
tt.melee.range = 60
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 20
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].max_range = 200
tt.ranged.attacks[1].disabled = false
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.main_script.remove = nil
tt.render.sprites[1].prefix = "celtic_tower_hunter_lvl2"
tt.reinforcement.duration = nil
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.powers = nil
tt.timed_attacks = nil
tt.unit.price = nil
tt.health.delete_after = nil
tt.unit.fade_time_after_death = nil
tt.sound_events.insert = nil
tt.sound_events.change_rally_point = "Stage20HuntersOutpostMove"

tt = E:register_t("mod_stage_21_buff_slaves_damage", "mod_boss_bandit_ally_buff_damage", true)
tt.inflicted_damage_factor = 1.5
tt.modifier.duration = 5

tt = E:register_t("mod_stage_21_buff_slaves_speed", "mod_boss_bandit_ally_buff_speed", true)
tt.slow.factor = 1.5
tt.modifier.duration = 5

return true
