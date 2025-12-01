-- chunkname: @./kr3/data/levels/level05.lua

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

function level:load(store)
	self.catapult_stop_ni = {
		[6] = 41,
		[5] = 40
	}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.catapult_waves = {
			{
				wave = 2,
				leave = 20,
				enter = 1,
				path_id = 5
			},
			{
				wave = 5,
				leave = 30,
				enter = 7,
				path_id = 6
			},
			{
				wave = 8,
				leave = 25,
				enter = 1,
				path_id = 5
			},
			{
				wave = 8,
				leave = 35,
				enter = 15,
				path_id = 6
			},
			{
				wave = 11,
				leave = 30,
				enter = 15,
				path_id = 5
			},
			{
				wave = 11,
				leave = 30,
				enter = 15,
				path_id = 6
			},
			{
				wave = 14,
				leave = 30,
				enter = 10,
				path_id = 5
			},
			{
				wave = 14,
				leave = 30,
				enter = 10,
				path_id = 6
			},
			{
				wave = 15,
				leave = 45,
				enter = 15,
				path_id = 5
			},
			{
				wave = 15,
				leave = 45,
				enter = 15,
				path_id = 6
			}
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.catapult_waves = {
			{
				wave = 1,
				leave = 30,
				enter = 10,
				path_id = 5
			},
			{
				wave = 2,
				leave = 30,
				enter = 10,
				path_id = 6
			},
			{
				wave = 5,
				leave = 30,
				enter = 10,
				path_id = 5
			}
		}
	end
end

function level:update(store)
	coroutine.yield()

	local h = LU.insert_hero(store, "hero_alleria", V.v(40, 190))

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if self.catapult_waves then
		local cwi, cw = 0
		local wts = store.tick_ts

		::label_3_0::

		while not store.waves_finished do
			cwi, cw = next(self.catapult_waves, cwi)

			if not cw then
				break
			end

			while store.wave_group_number < cw.wave do
				coroutine.yield()

				wts = store.tick_ts
			end

			while store.tick_ts - wts < cw.enter do
				if store.wave_group_number ~= cw.wave then
					goto label_3_0
				end

				coroutine.yield()
			end

			local e = E:create_entity("enemy_catapult")

			e.nav_path.pi = cw.path_id
			e.nav_path.spi = 2
			e.duration = cw.leave - cw.enter
			e.stop_ni = self.catapult_stop_ni[cw.path_id]

			LU.queue_insert(store, e)
		end
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

return level
