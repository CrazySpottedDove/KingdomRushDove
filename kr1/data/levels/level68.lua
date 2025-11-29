-- chunkname: @./kr3/data/levels/level20.lua

local log = require("lib.klua.log"):new("level20")
local km = require("lib.klua.macros")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local P = require("path_db")

require("constants")

local function fts(v)
	return v / FPS
end

local level = {}

function level:load(store)
	return
end

function level:update(store)
	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		local boss = E:create_entity("eb_bajnimen")

		boss.nav_path.pi = 3
		boss.nav_path.ni = P:get_start_node(boss.nav_path.pi)

		LU.queue_insert(store, boss)
		coroutine.yield()

		local megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]
		local spawn_nodes = table.deepclone(megaspawner.spawn_nodes)
		local spawn_idx = 1

		while not boss.health.dead do
			if spawn_nodes[1] and boss.nav_path.ni >= spawn_nodes[1] then
				table.remove(spawn_nodes, 1)

				megaspawner.manual_wave = megaspawner.spawn_waves[spawn_idx]
				spawn_idx = km.zmod(spawn_idx + 1, #megaspawner.spawn_waves)
			end

			coroutine.yield()
		end

		megaspawner.interrupt = true

		while boss.phase ~= "death-complete" do
			coroutine.yield()
		end
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	U.y_wait(store, 1)
end

return level
