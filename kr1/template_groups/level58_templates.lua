local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local km = require("lib.klua.macros")
require("all.constants")
require("lib.klua.table")
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s10_gnome_update(this, store)
	local s = this.render.sprites[1]
	local action, delay
	local function y_play(name, loops)
		loops = loops or 1
		U.animation_start_default(this, name, nil, store.tick_ts, loops > 1)
		while not U.animation_finished(this, nil, loops) do
			if this.ui.clicked then
				return true
			end
			coroutine.yield()
		end
	end
	local function y_walk(from, to, time)
		local an, af = U.animation_name_facing_point(this, "walk", to)
		U.animation_start_default(this, an, af, store.tick_ts, true)
		local start_ts = store.tick_ts
		local phase = 0
		while phase < 1 do
			if this.ui.clicked then
				return true
			end
			phase = km.clamp(0, 1, (store.tick_ts - start_ts) / time)
			this.pos.x = from.x + phase * (to.x - from.x)
			this.pos.y = from.y + phase * (to.y - from.y)
			coroutine.yield()
		end
		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
	end
	s.flip_x = math.random() < 0.5
	::label_552_0::
	this.ui.clicked = nil
	delay = U.frandom(this.min_delay, this.max_delay)
	if U.y_wait_conditional(store, delay, function()
		return this.ui.clicked
	end) then
	else
		action = table.random(this.gnome_actions)
		if action == "guitar" then
			if y_play("guitarBegin") or y_play("guitarLoop", math.random(5, 10)) or y_play("guitarEnd") then
				goto label_552_1
			end
		elseif action == "diamond" then
			if y_play("diamond") then
				goto label_552_1
			end
		elseif action == "sleep" then
			if y_play("sleepBegin") or y_play("sleepLoop", math.random(5, 10)) or y_play("sleepEnd") then
				goto label_552_1
			end
		elseif action == "teleport" then
			U.y_animation_play(this, "teleportOut", nil, store.tick_ts, false)
			U.y_wait_unconditional(store, U.frandom(5, 10))
			U.y_animation_play(this, "teleportIn", nil, store.tick_ts, false)
		elseif action == "flip" then
			s.flip_x = not s.flip_x
		elseif action == "walk" then
			local from, to = unpack(this.walk_points)
			if y_walk(from, to, this.walk_time) or U.y_wait_conditional(store, U.frandom(10, 15), function()
				return this.ui.clicked
			end) or y_walk(to, from, this.walk_time) then
				goto label_552_1
			end
		end
		U.animation_start_default(this, "idle", nil, store.tick_ts, true)
		goto label_552_0
	end
	::label_552_1::
	S:queue("ElvesGnomeDeathTaunt")
	U.y_animation_play(this, "explode", nil, store.tick_ts)
	U.y_wait_unconditional(store, 25)
	if this.walk_points then
		this.pos.x, this.pos.y = this.walk_points[1].x, this.walk_points[1].y
	end
	U.y_animation_play(this, "teleportIn", nil, store.tick_ts, false)
	goto label_552_0
end
local function simon_controller_update(this, store)
	local sign_cooldown, sign_ts, sign_step, touch_count
	local m1 = LU.list_entities(store.entities, "simon_mushroom_1")[1]
	local m2 = LU.list_entities(store.entities, "simon_mushroom_2")[1]
	local m3 = LU.list_entities(store.entities, "simon_mushroom_3")[1]
	local m4 = LU.list_entities(store.entities, "simon_mushroom_4")[1]
	local m0 = LU.list_entities(store.entities, "simon_gnome_mushrooom_glow")[1]
	local gnome = LU.list_entities(store.entities, "simon_gnome")[1]
	local ms = {
		[0] = m0,
		m1,
		m2,
		m3,
		m4
	}
	local glow_data = {
		gnome = {false, 1, {{0, 0}, {fts(9), 255}, {fts(18), 0}}},
		hint = {false, 1, {{0, 0}, {fts(9), 128}, {fts(18), 0}}},
		start = {false, 1, {{0, 0}, {fts(5), 255}, {fts(15), 255}, {fts(24), 0}}},
		touch = {true, 1, {{0, 0}, {fts(5), 255}, {fts(15), 255}, {fts(24), 0}}},
		seq = {true, 1, {{0, 0}, {fts(5), 255}, {fts(18), 255}, {fts(27), 0}}},
		win = {false, 1, {
			{fts(20), 0},
			{fts(22), 255},
			{fts(24), 170},
			{fts(26), 255},
			{fts(28), 170},
			{fts(30), 255},
			{fts(32), 170},
			{fts(34), 255},
			{fts(36), 170},
			{fts(38), 255},
			{fts(40), 0}
		}},
		fail = {false, 2, {{fts(3), 0}, {fts(8), 255}, {fts(13), 255}, {fts(20), 0}}}
	}
	local function show_fx(name, delay)
		local fx = E:create_entity(name)
		fx.pos.x, fx.pos.y = gnome.pos.x, gnome.pos.y
		fx.render.sprites[1].ts = store.tick_ts + (delay or 0)
		simulation:queue_insert_entity(fx)
	end
	local function glow(mi, id, overlap)
		for _, prop in pairs(ms[mi].tween.props) do
			prop.disabled = true
		end
		local has_sound, tween_id, keys = unpack(glow_data[id])
		local prop = ms[mi].tween.props[tween_id]
		prop.keys = keys
		prop.disabled = nil
		ms[mi].tween.ts = store.tick_ts
		if has_sound then
			S:queue(ms[mi].sound_events.touch)
		end
		if overlap then
			return keys[#keys][1] - fts(6)
		else
			return keys[#keys][1]
		end
	end
	local function glow_all(id)
		local delay
		for i = 1, #ms do
			delay = glow(i, id)
		end
		return delay
	end
	local function clear_touches()
		for i = 0, #ms do
			ms[i].ui.clicked = nil
		end
	end
	local function get_touched()
		for i = 0, #ms do
			if ms[i].ui.clicked then
				clear_touches()
				return i
			end
		end
	end
	local function extend_seq()
		local seq = this.seq
		::label_550_0::
		local r = math.random(1, 4)
		if #seq > 0 and seq[#seq] == r then
			goto label_550_0
		end
		table.insert(seq, r)
	end
	local function reset_seq()
		this.seq = {}
		for i = 1, this.initial_sequence_length do
			extend_seq()
		end
	end
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	::label_544_0::
	reset_seq()
	::label_544_1::
	sign_ts = store.tick_ts
	sign_cooldown = U.frandom(3, 5)
	clear_touches()
	while get_touched() ~= 0 do
		if sign_cooldown < store.tick_ts - sign_ts then
			sign_ts = store.tick_ts
			sign_step = km.zmod((sign_step or 0) + 1, 3)
			if sign_step == 3 then
				show_fx("simon_gnome_sign")
			else
				glow(0, "hint")
			end
		end
		coroutine.yield()
	end
	glow(0, "gnome")
	S:queue("ElvesSimonActivate", {
		delay = fts(10)
	})
	show_fx("simon_gnome_fx", fts(29))
	U.animation_start_default(gnome, "play", nil, store.tick_ts, false)
	U.y_wait_unconditional(store, fts(40))
	U.y_wait_unconditional(store, glow_all("start") + 0.5)
	for _, id in pairs(this.seq) do
		U.y_wait_unconditional(store, glow(id, "seq", true))
	end
	clear_touches()
	touch_count = 0
	while true do
		local id = get_touched()
		if id then
			if id == 0 then
				goto label_544_1
			end
			local delay = glow(id, "touch")
			U.y_wait_unconditional(store, delay * 0.5)
			touch_count = touch_count + 1
			if id == this.seq[touch_count] then
				if touch_count == #this.seq then
					U.y_wait_unconditional(store, delay * 0.5)
					glow_all("win")
					S:queue("ElvesSimonActivate", {
						delay = fts(10)
					})
					U.animation_start_default(gnome, "play", nil, store.tick_ts, false)
					U.y_wait_unconditional(store, fts(27))
					local fx = E:create_entity("fx_coin_shower")
					fx.coin_count = 5
					fx.pos.x, fx.pos.y = gnome.pos.x - 4, gnome.pos.y + 10
					simulation:queue_insert_entity(fx)
					store.player_gold = store.player_gold + this.reward_base + this.reward_inc * (#this.seq - this.initial_sequence_length)
					U.y_animation_wait_default(gnome)
					if #this.seq == this.achievement_count then
					end
					extend_seq()
					goto label_544_1
				end
			else
				U.y_wait_unconditional(store, delay * 0.5)
				S:queue("ElvesSimonWrong")
				U.y_wait_unconditional(store, glow_all("fail"))
				goto label_544_0
			end
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s10_gnome", "decal_scripted", true)
AC(tt, "ui")
tt.ui.click_rect = r(-23, -19, 46, 38)
tt.ui.can_select = false
tt.render.sprites[1].prefix = "decal_s10_gnome"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.main_script.update = decal_s10_gnome_update
tt.min_delay = 5
tt.max_delay = 20
tt.gnome_actions = {"guitar", "diamond", "sleep", "teleport", "flip"}
tt = E:register_t_hot("decal_s10_gnome_walking", "decal_s10_gnome", true)
tt.walk_time = 1.5
table.insert(tt.gnome_actions, "walk")
tt = E:register_t_hot("simon_controller", nil, true)
AC(tt, "main_script")
tt.main_script.update = simon_controller_update
tt.initial_sequence_length = 4
tt.reward_base = 25
tt.reward_inc = 15
tt.achievement_id = "SIMON"
tt.achievement_count = 9
tt = E:register_t_hot("simon_mushroom_1", "decal_tween", true)
AC(tt, "ui", "sound_events")
tt.ui.click_rect = r(-20, 10, 40, 30)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage8_symon_fungus1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage8_symon_fungus1_0002"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "stage8_symon_fungus1_0003"
tt.tween.props[1].keys = {{0, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}}
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.sound_events.touch = "ElvesSimonYellow"
tt = E:register_t_hot("simon_mushroom_2", "simon_mushroom_1", true)
tt.render.sprites[1].name = "stage8_symon_fungus2_0001"
tt.render.sprites[2].name = "stage8_symon_fungus2_0002"
tt.render.sprites[3].name = "stage8_symon_fungus2_0003"
tt.sound_events.touch = "ElvesSimonGreen"
tt = E:register_t_hot("simon_mushroom_3", "simon_mushroom_1", true)
tt.render.sprites[1].name = "stage8_symon_fungus3_0001"
tt.render.sprites[2].name = "stage8_symon_fungus3_0002"
tt.render.sprites[3].name = "stage8_symon_fungus3_0003"
tt.sound_events.touch = "ElvesSimonRed"
tt = E:register_t_hot("simon_mushroom_4", "simon_mushroom_1", true)
tt.render.sprites[1].name = "stage8_symon_fungus4_0001"
tt.render.sprites[2].name = "stage8_symon_fungus4_0002"
tt.render.sprites[3].name = "stage8_symon_fungus4_0003"
tt.sound_events.touch = "ElvesSimonBlue"
tt = E:register_t_hot("simon_gnome_mushrooom_glow", "decal_tween", true)
AC(tt, "ui")
tt.ui.can_select = false
tt.ui.click_rect = r(-20, -20, 40, 50)
tt.render.sprites[1].name = "stage8_symon_bigGlow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}}
tt.tween.remove = false
tt = E:register_t_hot("simon_gnome", "decal", true)
tt.render.sprites[1].prefix = "simon_gnome"
tt.render.sprites[1].sort_y_offset = -38
