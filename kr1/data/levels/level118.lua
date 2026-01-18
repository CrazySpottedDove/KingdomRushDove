local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")
local storage = require("storage")
local GR = require("grid_db")
require("constants")
local function fts(v)
	return v / FPS
end
local level = {}
function level:load(store)
	return
end
function level:update(store)
	for i = 1, 4 do
		P:add_invalid_range(i, P:get_end_node(i) - 10, P:get_end_node(i))
	end
	if store.level_mode == GAME_MODE_CAMPAIGN then
		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	else
		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	end
end
return level
