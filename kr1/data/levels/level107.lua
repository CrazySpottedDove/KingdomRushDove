local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")
local storage = require("storage")
require("constants")
local function fts(v)
	return v / FPS
end
local level = {}
function level:update(store)
	P:add_invalid_range(4, 31, 55, NF_NO_SHADOW)
	P:add_invalid_range(5, 31, 55, NF_NO_SHADOW)
	P:add_invalid_range(4, P:get_start_node(4), P:get_start_node(4) + 8)
	P:add_invalid_range(5, P:get_start_node(5), P:get_start_node(5) + 8)
	P:add_invalid_range(6, P:get_start_node(6), P:get_start_node(6) + 14)
	P:add_invalid_range(7, P:get_start_node(7), P:get_start_node(7) + 14)
	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
	log.debug("-- WON")
	if store.level_mode == GAME_MODE_CAMPAIGN then
	end
end
return level
