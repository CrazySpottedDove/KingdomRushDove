local E = require("entity_db")
local U = require("utils")
require("all.constants")
require("lib.klua.table")
local function AC(tpl, ...)
	return E:add_comps(tpl, ...)
end
local function decal_crane_update(this, store)
	local clicks = 0
	local max_clicks = math.random(this.final_clicks[1], this.final_clicks[2])
	local play_ts = store.tick_ts
	local play_time = U.frandom(this.play_time[1], this.play_time[2])
	while true do
		if this.ui.clicked then
			clicks = clicks + 1
			if max_clicks <= clicks then
				this.render.sprites[2].hidden = true
				U.y_animation_play(this, this.final_click_animation, nil, store.tick_ts, 1, 1)
				simulation:queue_remove_entity(this)
				return
			else
				U.y_animation_play(this, this.click_animation, nil, store.tick_ts, 1, 1)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
			end
			this.ui.clicked = nil
			play_ts = store.tick_ts
		end
		if play_time < store.tick_ts - play_ts then
			play_ts = store.tick_ts
			play_time = U.frandom(this.play_time[1], this.play_time[2])
			U.y_animation_play(this, this.play_animation, nil, store.tick_ts, 1, 1)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
			this.ui.clicked = nil
		end
		coroutine.yield()
	end
end
local function river_object_controller_update(this, store)
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	local spawn_ts = store.tick_ts
	local spawn_time = U.frandom(this.min_time, this.max_time)
	local chests = 0
	local name = "hobbit"
	while true do
		if spawn_time < store.tick_ts - spawn_ts then
			spawn_time = U.frandom(this.min_time, this.max_time)
			spawn_ts = store.tick_ts
			if name ~= "hobbit" then
				name = "hobbit"
			else
				name = table.random(this.river_objects)
				if name == "chest" then
					chests = chests + 1
					if chests >= this.max_chests then
						table.removeobject(this.river_objects, "chest")
					end
				end
			end
			local e = E:create_entity("decal_river_object_" .. name)
			simulation:queue_insert_entity(e)
		end
		coroutine.yield()
	end
end
local tt
tt = E:register_t_hot("decal_s03_bridge", "decal_static", true)
AC(tt, "ui")
tt.ui.click_rect = r(-83, -48, 166, 96)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage3_bridge"
tt.render.sprites[1].z = Z_DECALS + 2
tt.render.sprites[1].sort_y_offset = 48
tt = E:register_t_hot("decal_crane", "decal_scripted", true)
AC(tt, "ui")
tt.render.sprites[1].prefix = "decal_crane"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_crane_fx"
tt.render.sprites[2].draw_order = -1
tt.ui.click_rect = r(-20, -40, 40, 40)
tt.ui.can_select = false
tt.main_script.update = decal_crane_update
tt.play_animation = "play"
tt.click_animation = "click"
tt.final_click_animation = "final_click"
tt.play_time = {10, 45}
tt.final_clicks = {3, 6}
tt = E:register_t_hot("river_object_controller", nil, true)
AC(tt, "main_script")
tt.main_script.update = river_object_controller_update
tt.river_objects = {"barrel", "barrel", "chest", "wilson", "submarine"}
tt.min_time = 12
tt.max_time = 24
tt.max_chests = 3
tt.max_hobbits = 13

local S = require("sound_db")
local P = require("path_db")
local V = require("lib.klua.vector")

tt = E:register_t_hot("decal_river_object", "decal_scripted", true)
AC(tt, "nav_path", "motion", "ui", "tween", "sound_events")
tt.main_script.update = function(this, store)
	local next
	local fall_count = 0

	local function check_clicked()
		if this.ui.clicked then
			if this.gold then
				store.player_gold = store.player_gold + this.gold
			end

			S:queue(this.sound_events.save)
			U.y_animation_play(this, "save", nil, store.tick_ts)
			simulation:queue_remove_entity(this)

			if this.achievement then
			-- AC:got(this.achievement)
			end

			if this.achievement_inc then
			-- AC:inc_check(this.achievement_inc)
			end

			return
		end
	end

	::label_514_0::

	this.ui.clicked = nil
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	U.animation_start_default(this, "travel", nil, store.tick_ts, true)

	while true do
		check_clicked()

		next = P:next_entity_node(this, store.tick_length)

		if next == nil then
			break
		end

		local remaining_nodes = P:get_end_node(this.nav_path.pi) - this.nav_path.ni

		if fall_count == 1 and this.sink_nodes and remaining_nodes <= this.sink_nodes then
			break
		end

		U.set_destination(this, next)
		U.walk_off__accel__unsnapped(this, store.tick_length)
		coroutine.yield()
	end

	if fall_count < this.falls then
		fall_count = fall_count + 1

		U.animation_start_default(this, "fall", nil, store.tick_ts, true)

		if fall_count == 1 then
			this.tween.ts = store.tick_ts
			this.tween.disabled = nil
			this.tween.props[1].keys = this.fall_1_tween
		end

		this.nav_path.pi = this.nav_path.pi + 1
		this.nav_path.ni = 1

		local normal_speed = this.motion.max_speed
		local fall_dest = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

		U.update_max_speed(this, V.dist(fall_dest.x, fall_dest.y, this.pos.x, this.pos.y) / this.fall_time)
		U.set_destination(this, fall_dest)

		while not U.walk_off__accel__unsnapped(this, store.tick_length) do
			coroutine.yield()
		end

		U.update_max_speed(this, normal_speed)

		if fall_count == 1 then
			S:queue(this.sound_events.fall)
			U.y_wait_unconditional(store, this.fall_wait)

			this.tween.ts = store.tick_ts
			this.tween.disabled = nil
			this.tween.props[1].keys = this.travel_2_tween

			goto label_514_0
		else
			S:queue(this.sound_events.crash)
			U.y_animation_play(this, "crash", nil, store.tick_ts)
			simulation:queue_remove_entity(this)
		end
	else
		S:queue(this.sound_events.sink)
		U.y_animation_play(this, "sink", nil, store.tick_ts)
		simulation:queue_remove_entity(this)
	end
end
tt.motion.max_speed = 1.5 * FPS
tt.ui.click_rect = r(-18, -5, 36, 36)
tt.ui.can_select = false
tt.ui.z = -1
tt.render.sprites[1].z = Z_DECALS + 1
tt.nav_path.pi = 5
tt.sink_nodes = 5
tt.falls = 1
tt.fall_time = 0.5
tt.fall_wait = 0.6
tt.fall_1_tween = {{0, 255}, {0.4, 255}, {0.5, 0}}
tt.travel_2_tween = {{0, 0}, {1, 255}}
tt.tween.disabled = true
tt.tween.remove = false
tt.sound_events.fall = "ElvesWaterfallStrong"

tt = E:register_t_hot("decal_river_object_hobbit", "decal_river_object", true)
tt.render.sprites[1].prefix = "decal_river_object_hobbit"
tt.render.sprites[1].anchor.y = 0.2818181818181818
tt.falls = 2
tt.sink_nodes = nil
tt.achievement_inc = "DWARF_FALL"
tt.sound_events.save = "ElvesAchievementHobbit"
tt.sound_events.crash = "ElvesAchievementDwarfFall"

tt = E:register_t_hot("decal_river_object_barrel", "decal_river_object", true)
tt.render.sprites[1].prefix = "decal_river_object_barrel"
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.sound_events.save = "ElvesWaterfallMid"

tt = E:register_t_hot("decal_river_object_chest", "decal_river_object", true)
tt.render.sprites[1].prefix = "decal_river_object_chest"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.gold = 20
tt.sound_events.save = "ElvesGoldCoin"

tt = E:register_t_hot("decal_river_object_wilson", "decal_river_object", true)
tt.render.sprites[1].prefix = "decal_river_object_wilson"
tt.render.sprites[1].anchor.y = 0.1527777777777778
tt.sound_events.save = "ElvesAchievementWilson"

tt = E:register_t_hot("decal_river_object_submarine", "decal_river_object", true)
tt.render.sprites[1].prefix = "decal_river_object_submarine"
tt.render.sprites[1].anchor.y = 0.20454545454545456
tt.sound_events.save = "ElvesAchievementYellowSubmarine"
