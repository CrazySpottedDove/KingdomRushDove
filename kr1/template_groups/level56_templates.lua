local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local v = V.v
local function fts(t)
	return t / FPS
end
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_s08_magic_bean_update(this, store)
	local delay = U.frandom(5, 10)
	local step = 1
	local start_ts
	::label_530_0::
	start_ts = store.tick_ts
	if step == 4 then
		S:queue("ElvesBeanGrowLoop")
	elseif step > 1 then
		S:queue("ElvesBeanGrow")
	end
	U.animation_start_default(this, "step" .. step, nil, store.tick_ts, false)
	while not U.animation_finished_default(this) do
		if step == 4 and store.tick_ts - start_ts >= fts(60) then
			S:stop("ElvesBeanGrowLoop")
			goto label_530_1
		end
		coroutine.yield()
	end
	this.ui.clicked = nil
	while not this.ui.clicked do
		if step == 1 and delay < store.tick_ts - start_ts then
			start_ts = store.tick_ts
			delay = U.frandom(5, 10)
			U.animation_start_default(this, "step" .. step, nil, store.tick_ts, false)
		end
		coroutine.yield()
	end
	step = step + 1
	goto label_530_0
	::label_530_1::
	U.y_wait_unconditional(store, 4)
	store.player_gold = store.player_gold + this.reward_gold
	local fx = E:create_entity(this.reward_fx)
	fx.render.sprites[1].ts = store.tick_ts
	fx.pos.x, fx.pos.y = this.pos.x + 38, this.pos.y
	simulation:queue_insert_entity(fx)
	while true do
		coroutine.yield()
	end
end
local function decal_s08_hansel_gretel_update(this, store)
	local witch_clicks = 0
	local door_sid = 2
	local start_ts
	local witch = E:create_entity("decal_s08_witch")
	witch.inside_pos = v(this.pos.x + 37, this.pos.y - 45)
	witch.outside_pos = v(this.pos.x + 70, this.pos.y - 76)
	witch.pos.x, witch.pos.y = witch.inside_pos.x, witch.inside_pos.y
	witch.render.sprites[1].hidden = true
	witch.ui.can_click = false
	simulation:queue_insert_entity(witch)
	::label_533_0::
	this.ui.clicked = nil
	while not this.ui.clicked do
		coroutine.yield()
	end
	S:queue("GUITowerOpenDoor")
	U.animation_start(this, "open", nil, store.tick_ts, false, door_sid)
	U.y_wait_unconditional(store, 0.8)
	witch.render.sprites[1].hidden = nil
	witch.ui.can_click = true
	U.animation_start_default(witch, "walk", false, store.tick_ts, true)
	U.set_destination(witch, witch.outside_pos)
	while not witch.motion.arrived do
		U.walk(witch, store.tick_length)
		coroutine.yield()
	end
	S:queue("ElvesWitchOutside")
	U.y_animation_play(witch, "angry", nil, store.tick_ts)
	start_ts = store.tick_ts
	witch.ui.clicked = nil
	while store.tick_ts - start_ts < 3 do
		if witch.ui.clicked then
			S:queue("ElvesWitchTouch")
			witch.ui.clicked = nil
			witch_clicks = witch_clicks + 1
			if witch_clicks >= 10 then
				goto label_533_1
			else
				U.y_animation_play(witch, "click", nil, store.tick_ts)
			end
		end
		coroutine.yield()
	end
	U.animation_start_default(witch, "walk", true, store.tick_ts, true)
	U.set_destination(witch, witch.inside_pos)
	while not witch.motion.arrived do
		U.walk(witch, store.tick_length)
		coroutine.yield()
	end
	witch.render.sprites[1].hidden = true
	witch.ui.can_click = false
	S:queue("GUITowerOpenDoor")
	U.animation_start(this, "close", nil, store.tick_ts, false, door_sid)
	U.y_wait_unconditional(store, 0.8)
	goto label_533_0
	::label_533_1::
	S:queue("ElvesWitchDeath")
	U.y_animation_play(witch, "die", nil, store.tick_ts)
	S:queue("ElvesHanselAndGretelEscape")
	for _, n in pairs({"hansel", "gretel"}) do
		local e = E:create_entity("decal_s08_" .. n)
		e.pos.x, e.pos.y = this.pos.x, this.pos.y
		e.tween.ts = store.tick_ts
		simulation:queue_insert_entity(e)
	end
end
local tt
tt = E:register_t_hot("decal_s08_magic_bean", "decal_scripted", true)
AC(tt, "ui")
tt.achievement_id = "BEANS"
tt.main_script.update = decal_s08_magic_bean_update
tt.ui.click_rect = r(-25, -25, 50, 50)
tt.ui.can_select = false
tt.reward_gold = 150
tt.reward_fx = "fx_coin_jump"
for i = 1, 5 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s08_magic_bean_l" .. i
	tt.render.sprites[i].name = "step1"
	tt.render.sprites[i].loop = false
	tt.render.sprites[i].anchor.y = 0.1076923076923077
end
local km = require("lib.klua.macros")
local function decal_s08_peakaboo_update(this, store)
	local s = this.render.sprites[1]
	::label_531_0::
	s.hidden = true
	U.y_wait_unconditional(store, U.frandom(30, 40))
	s.hidden = false
	if this.pos_list then
		this.pos = table.random(this.pos_list)
	end
	U.y_animation_play(this, "in", nil, store.tick_ts)
	this.ui.clicked = nil
	if U.y_wait_conditional(store, U.frandom(2, 4), function(store, time)
		return this.ui.clicked
	end) then
	else
		U.y_animation_play(this, "out", nil, store.tick_ts)
		goto label_531_0
	end
	S:queue(this.sound)
	U.y_animation_play(this, "action", nil, store.tick_ts)
	simulation:queue_remove_entity(this)
end
tt = E:register_t_hot("decal_s08_peekaboo", "decal_scripted", true)
AC(tt, "ui")
tt.main_script.update = decal_s08_peakaboo_update
tt.render.sprites[1].name = "out"
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.sound = "ElvesPeekaboo"
tt = E:register_t_hot("decal_s08_peekaboo_wolf", "decal_s08_peekaboo", true)
tt.render.sprites[1].prefix = "decal_s08_peekaboo_wolf"
tt.achievement_flag = {"PEEKABOO", 1}
tt = E:register_t_hot("decal_s08_peekaboo_rrh", "decal_s08_peekaboo", true)
tt.render.sprites[1].prefix = "decal_s08_peekaboo_rrh"
tt.achievement_flag = {"PEEKABOO", 2}
tt = E:register_t_hot("decal_s08_peekaboo_pork", "decal_s08_peekaboo", true)
tt.render.sprites[1].prefix = "decal_s08_peekaboo_pork"
tt.achievement_flag = {"PEEKABOO", 4}
tt = E:register_t_hot("decal_s08_hansel_gretel", "decal_scripted", true)
AC(tt, "ui")
tt.main_script.update = decal_s08_hansel_gretel_update
tt.ui.click_rect = r(-70, -60, 140, 120)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage10_witchHouse_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_s08_hansel_gretel_door"
tt.render.sprites[2].name = "close"
tt.render.sprites[2].loop = false
