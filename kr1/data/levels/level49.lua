-- chunkname: @./kr3/data/levels/level01.lua

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

function level:update(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.manual_hero_insertion = true

		-- signal.emit("show-balloon", "TB_START")
		-- signal.emit("show-balloon", "TB_BUILD")
		-- signal.emit("wave-notification", "view", "TUTORIAL_1")

		if store.selected_hero and store.selected_hero ~= "hero_elves_archer" then
			LU.insert_hero(store)
		end

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		-- self.show_next_wave_balloon = true

		while store.wave_group_number < 2 do
			coroutine.yield()
		end

		-- signal.emit("wave-notification", "view", "POWER_REINFORCEMENT")

		while store.wave_group_number < 3 do
			coroutine.yield()
		end

		-- signal.emit("wave-notification", "view", "POWER_FIREBALL")

		while store.wave_group_number < 5 do
			coroutine.yield()
		end

		if store.selected_hero and store.selected_hero == "hero_elves_archer" then
			-- signal.emit("wave-notification", "view", "TIP_HEROES")

			while store.paused do
				coroutine.yield()
			end

			log.debug("-- Move hero to the left of the screen")

			local dp = store.level.locations.exits[1].pos
			local hero = LU.insert_hero(store)

			hero.pos = V.v(-REF_OX - 50, dp.y)
			hero.nav_rally.center = V.v(dp.x, dp.y)
			hero.nav_rally.pos = V.vclone(hero.nav_rally.center)
		end

		while store.wave_group_number < 6 do
			coroutine.yield()
		end

		-- if store.selected_hero and store.selected_hero == "hero_elves_archer" then
		-- 	signal.emit("wave-notification", "view", "POWER_HERO")
		-- else
		-- 	signal.emit("unlock-user-power", 3)
		-- end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		log.debug("-- WON")
	end
end

return level
