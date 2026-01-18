local log = require("klua.log"):new("level01")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")
require("constants")
local function fts(v)
	return v / FPS
end
local level = {}
function level:load(store)
	P:deactivate_path(4)
end
function level:update(store)
	local heart
	for k, v in pairs(store.entities) do
		if v.template_name == "trees_heart_of_the_arborean_decal" then
			heart = v
			break
		end
	end
	while store.wave_group_number < 1 do
		coroutine.yield()
	end
	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number < 3 do
			coroutine.yield()
		end
		P:activate_path(4)
	end
	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end
return level
