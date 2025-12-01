-- chunkname: @./kr1/data/levels/level20.lua

local log = require("lib.klua.log"):new("level21")
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
		local boss = E:create_entity("enemy_demon_cerberus")

		boss.pos = V.v(817, 297)
		boss.sleeping = true
		boss.render.sprites[1].flip_x = true
		boss.nav_path.pi = 2
		boss.nav_path.spi = 1
		boss.nav_path.ni = 35
		boss.ignore_seen_tracker = true

		local npos = P:node_pos(boss.nav_path)

		boss.motion.forced_waypoint = npos

		LU.queue_insert(store, boss)
		coroutine.yield()
		U.y_wait(store, 1)

		while store.wave_group_number ~= store.wave_group_total do
			coroutine.yield()
		end

		signal.emit("wave-notification", "icon", boss.template_name)

		boss.sleeping = nil

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		U.y_wait(store, 1)
	end
end

return level
