-- chunkname: @./kr1/data/levels/level05.lua

local log = require("lib.klua.log"):new("level05")
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

function level:update(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		-- if not table.contains(store.level.locked_towers, "tower_ranger") then
		-- 	table.insert(store.level.locked_towers, "tower_ranger")
		-- end

		-- while store.wave_group_number < 5 do
		-- 	coroutine.yield()
		-- end

		-- table.removeobject(store.level.locked_towers, "tower_ranger")

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("-- WON")
	end
end

return level
