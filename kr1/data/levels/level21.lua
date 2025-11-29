-- chunkname: @./kr1/data/levels/level21.lua

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
		local boss = E:create_entity("eb_moloch")

		boss.pos = V.vclone(boss.pos_sitting)

		LU.queue_insert(store, boss)

		self.boss = boss

		U.mark_seen(store, boss.template_name)
		coroutine.yield()
		U.y_wait(store, 1)

		while store.wave_group_number < boss.wave_active do
			coroutine.yield()
		end

		boss.phase_signal = "battle"

		while self.boss.phase ~= "death-complete" do
			coroutine.yield()
		end

		U.y_wait(store, 1)
	end
end

return level
