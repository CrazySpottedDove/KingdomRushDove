-- chunkname: @./kr3/data/levels/level15.lua
local log = require("lib.klua.log"):new("level15")
local signal = require("hump.signal")
local km = require("lib.klua.macros")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local SU = require("script_utils")
require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}

function level:load(store)
	self.boss_rounds = {{
		pi = 1,
		qty_per_egg = 2,
		pos = v(259, 469)
	}, {
		pi = 5,
		qty_per_egg = 2,
		pos = v(524, 455)
	}, {
		pi = 6,
		qty_per_egg = 3,
		pos = v(845, 394)
	}, {
		pi = 4,
		qty_per_egg = 3,
		pos = v(567, 328)
	}}
	self.mactans_eggs = {
		{
			path_id = 2,
			pos = v(98, 322),
			spawn_pos = v(82, 266)
		},
		{
			path_id = 3,
			pos = v(185, 454),
			spawn_pos = v(287, 454)
		},
		{
			path_id = 2,
			pos = v(209, 344),
			spawn_pos = v(176, 298)
		},
		{
			path_id = 2,
			pos = v(266, 360),
			spawn_pos = v(240, 314)
		},
		{
			path_id = 3,
			pos = v(282, 501),
			spawn_pos = v(287, 454)
		},
		{
			path_id = 3,
			pos = v(303, 386),
			spawn_pos = v(326, 344)
		},
		{
			path_id = 3,
			pos = v(384, 434),
			spawn_pos = v(352, 395)
		},
		{
			path_id = 7,
			pos = v(458, 445),
			spawn_pos = v(452, 392)
		},
		{
			path_id = 5,
			pos = v(468, 306),
			spawn_pos = v(524, 328)
		},
		{
			path_id = 5,
			pos = v(474, 353),
			spawn_pos = v(524, 328)
		},
		{
			path_id = 7,
			pos = v(497, 402),
			spawn_pos = v(452, 392)
		},
		{
			path_id = 5,
			pos = v(540, 290),
			spawn_pos = v(584, 328)
		},
		{
			path_id = 7,
			pos = v(572, 495),
			spawn_pos = v(531, 450)
		},
		{
			path_id = 5,
			pos = v(600, 360),
			spawn_pos = v(646, 337)
		},
		{
			path_id = 7,
			pos = v(616, 438),
			spawn_pos = v(531, 450)
		},
		{
			path_id = 6,
			pos = v(800, 404),
			spawn_pos = v(852, 360)
		},
		{
			path_id = 6,
			pos = v(875, 392),
			spawn_pos = v(852, 360)
		},
		{
			path_id = 6,
			pos = v(891, 282),
			spawn_pos = v(950, 252)
		},
		{
			path_id = 6,
			pos = v(977, 298),
			spawn_pos = v(950, 252)
		}
	}

	for _, egg in pairs(self.mactans_eggs) do
		local pis = P:get_connected_paths(egg.path_id)
		local nodes = P:nearest_nodes(egg.spawn_pos.x, egg.spawn_pos.y, pis, nil, true)

		if #nodes > 0 then
			egg.node_pi = nodes[1][1]
			egg.node_spi = nodes[1][2]
			egg.node_ni = nodes[1][3]
		else
			log.error("stage15: node not found for egg:%s", getfulldump(egg))
		end
	end
end

function level:update(store)
	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		if table.contains(store.selected_hero, "hero_veznan") then
			local veznan_deco = LU.list_entities(store.entities, "decal_s15_finished_veznan")[1]
			LU.queue_remove(store, veznan_deco)
		end

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	else
		local c_taunt = E:create_entity("taunts_s15_controller")
		local s_malicia = E:create_entity("decal_s15_malicia")
		local s_mactans = E:create_entity("decal_s15_mactans")
		local s_statue = E:create_entity("decal_s15_statue")
		local s_crystal = E:create_entity("decal_s15_crystal")
		LU.queue_insert(store, c_taunt)
		LU.queue_insert(store, s_malicia)
		LU.queue_insert(store, s_mactans)
		LU.queue_insert(store, s_statue)
		LU.queue_insert(store, s_crystal)
		s_malicia.pos = v(579, 643)
		s_mactans.pos = v(482, 647)
		s_mactans.decal_statue = s_statue
		s_statue.pos = v(544, 662)
		s_crystal.pos = v(544, 742)
		local mactans = LU.list_entities(store.entities, "enemy_mactans")[1]
		mactans.mactans_deco = s_mactans
		coroutine.yield()

		if not store.restarted then
			signal.emit("show-curtains")
			signal.emit("pan-zoom-camera", 3, {
				x = 512,
				y = 672
			}, 2)
			signal.emit("hide-gui")
			U.y_wait(store, 8)
			signal.emit("hide-curtains")
			signal.emit("pan-zoom-camera", 2, {
				x = 512,
				y = 384
			}, 1)
			signal.emit("show-gui")
		end

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		c_taunt.interrupt = true
		signal.emit("hide-gui")
		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 3, {
			x = 512,
			y = 672
		}, 2)
		s_mactans.phase_signal = "stop"
		s_malicia.phase_signal = "stop"

		repeat
			coroutine.yield()
		until s_mactans.phase == "idle" and s_malicia.phase == "idle"

		S:queue("MusicBossPreFight15")
		U.y_wait(store, 3)
		SU.y_show_taunt_set(store, c_taunt.taunts, "custom_malicia", "BREAKING", nil, 1.5, true)
		U.y_wait(store, 1.5)
		s_mactans.phase_signal = "single_attack"
		s_malicia.phase_signal = "single_attack"

		repeat
			coroutine.yield()
		until s_mactans.phase == "idle" and s_malicia.phase == "idle"

		U.y_wait(store, 1.5)
		s_statue.phase_signal = "break"
		s_crystal.tween.disabled = true
		local crystal_s = s_crystal.render.sprites[1]
		U.y_ease_keys(store, {s_crystal.pos, s_crystal.render.sprites[1].offset}, {"y", "y"}, {s_crystal.pos.y, s_crystal.render.sprites[1].offset.y}, {s_crystal.pos.y - 27, 0}, fts(20), {"quad-in"})

		while s_statue.phase ~= "broken" do
			coroutine.yield()
		end

		local fx = E:create_entity("fx_s15_crystal_shine")
		fx.pos.x, fx.pos.y = s_crystal.pos.x, s_crystal.pos.y
		fx.render.sprites[1].ts = store.tick_ts
		LU.queue_insert(store, fx)
		s_mactans.phase_signal = "jump"
		s_malicia.phase_signal = "jump"
		U.y_wait(store, fts(34))
		SU.y_show_taunt_set(store, c_taunt.taunts, "custom_malicia", "MINE", nil, 1, false)
		SU.y_show_taunt_set(store, c_taunt.taunts, "custom_mactans", "MINE", nil, 1, false)
		U.y_wait(store, fts(37))
		fx = E:create_entity("fx_s15_crystal_transformation")
		fx.pos.x, fx.pos.y = s_crystal.pos.x, s_crystal.pos.y
		U.animation_start(fx, "explosion", nil, store.tick_ts, false)
		LU.queue_insert(store, fx)
		LU.queue_remove(store, s_crystal)
		U.y_wait(store, fts(100))
		local circle = E:create_entity("fx_s15_white_circle")
		circle.pos.x, circle.pos.y = s_crystal.pos.x, s_crystal.pos.y
		circle.render.sprites[1].ts = store.tick_ts
		LU.queue_insert(store, circle)
		U.y_wait(store, 0.5)
		local boss = E:create_entity("eb_spider")
		boss.pos.x, boss.pos.y = 544, 643
		boss.megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]
		LU.queue_insert(store, boss)
		LU.queue_remove(store, s_statue)

		while boss.phase ~= "fight" do
			coroutine.yield()
		end

		signal.emit("pan-zoom-camera", 2, {
			x = 512,
			y = 384
		}, 1)
		signal.emit("hide-curtains")
		signal.emit("show-gui")
		S:queue("MusicBossFight")

		while boss.phase ~= "death-animation" do
			coroutine.yield()
		end

		signal.emit("hide-gui", true)

		for _, e in pairs(store.entities) do
			if e and e.tower then
				e.tower.blocked = true
			end
		end

		while boss.phase ~= "dead" do
			coroutine.yield()
		end

		store.custom_game_outcome = {
			-- next_item_name = "kr3_end"
			next_item_name = "map"
		}
	end

	log.debug("-- WON")
end

return level
