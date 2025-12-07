-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level13.lua
local log = require("lib.klua.log"):new("level13")
local signal = require("hump.signal")
local km = require("lib.klua.macros")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local A = require("achievements")
local E = require("entity_db")
local P = require("path_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}
level.required_sounds = {"music_stage39", "FrontiersUndergroundAmbienceSounds", "SpecialBlackDragon"}
level.required_textures = {"go_enemies_underground", "go_stages_underground", "go_stage39", "go_stage39_bg"}

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_UNDERGROUND
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.locked_powers = {}
	self.max_upgrade_level = 6
	self.locked_towers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {"tower_build_mage", "tower_build_archer"}
	end
end

function level:load(store)
	LU.insert_background(store, "Stage13_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage13_0002", Z_BACKGROUND_COVERS, nil, -1)
	LU.insert_background(store, "Stage13_0003", Z_OBJECTS, 628)
	LU.insert_background(store, "Stage13_0004", Z_OBJECTS, 584)
	LU.insert_background(store, "Stage13_0005", Z_OBJECTS, 35)
	LU.insert_background(store, "Stage13_0006", Z_OBJECTS, 155, -1)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		for _, h in pairs(self.locations.holders) do
			if table.contains({"5", "7", "12", "16"}, h.id) then
				e = LU.insert_tower(store, "tower_holder_blocked_underground", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	elseif store.level_mode == GAME_MODE_HEROIC then
		for _, h in pairs(self.locations.holders) do
			if table.contains({"5", "7", "12", "16"}, h.id) then
				e = LU.insert_tower(store, "tower_holder_blocked_underground", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		end
	else
		for _, h in pairs(self.locations.holders) do
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x
	self.nav_mesh = {
		{2, 11, x, x},
		{4, 16, 1, x},
		{5, 13, 16, 4},
		{6, 3, 2, x},
		{8, 8, 3, 15},
		{7, 15, 4, x},
		{x, 9, 6, x},
		{9, 10, 5, 15},
		{x, x, 8, 7},
		{9, 14, 13, 8},
		{12, 14, x, 1},
		{13, 14, 11, 16},
		{10, 14, 12, 3},
		{9, x, 13, 10},
		{6, 8, 5, 6},
		{3, 12, 2, 2},
		{x, x, x, x},
		{x, x, x, x},
		{x, x, x, x},
		{x, x, x, x},
		{x, x, x, x},
		{x, x, x, x}
	}
	P:add_invalid_range(1, 1, 15)
	P:add_invalid_range(2, 1, 18)
	P:add_invalid_range(5, 1, 10)
	local e
	-- local v_left = store.visible_coords.left
	-- local v_right = store.visible_coords.right
	-- local bats = {
	-- 	v(v_left, 0),
	-- 	v(0, 0),
	-- 	v(v_right - REF_W, 0),
	-- 	v(v_right - REF_W, 0),
	-- 	v(0, 0),
	-- 	v(v_left, 0)
	-- }
	-- for i, b in ipairs(bats) do
	-- 	e = E:create_entity("decal_bat_flying_" .. i)
	-- 	e.pos = b
	-- 	LU.queue_insert(store, e)
	-- end
	e = E:create_entity("decal_black_dragon")
	e.pos.x, e.pos.y = e.sleep_pos.x, e.sleep_pos.y
	LU.queue_insert(store, e)
	self.dragon = e
	e = E:create_entity("button_steal_dragon_gold")
	e.pos.x, e.pos.y = 605, 679
	e.dragon = self.dragon
	LU.queue_insert(store, e)
	self.dragon_cave_button = e
	self.dragon.dragon_paths = {{
		y = 468,
		x_ranges = {165, 530}
	}, {
		y = 305,
		x_ranges = {300, 450}
	}, {
		y = 305,
		x_ranges = {600, 765}
	}, {
		y = 305,
		x_ranges = {300, 450, 600, 765}
	}}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.dragon_waves = {
			{
				min_time = 8,
				delay = 20,
				max_time = 12,
				wave = 4,
				path = 1
			},
			{
				min_time = 8,
				delay = 25,
				max_time = 12,
				wave = 7,
				path = 4
			},
			{
				min_time = 6,
				delay = 10,
				max_time = 8,
				wave = 9,
				path = 1
			},
			{
				min_time = 8,
				delay = 30,
				max_time = 12,
				wave = 9,
				path = 3
			},
			{
				min_time = 8,
				delay = 40,
				max_time = 12,
				wave = 9,
				path = 2
			},
			{
				min_time = 8,
				delay = 30,
				max_time = 12,
				wave = 10,
				path = 2
			},
			{
				min_time = 8,
				delay = 45,
				max_time = 12,
				wave = 10,
				path = 3
			},
			{
				min_time = 8,
				delay = 60,
				max_time = 12,
				wave = 10,
				path = 4
			},
			{
				min_time = 4,
				delay = 15,
				max_time = 6,
				wave = 12,
				path = 1
			},
			{
				min_time = 4,
				delay = 40,
				max_time = 6,
				wave = 12,
				path = 4
			},
			{
				min_time = 8,
				delay = 5,
				max_time = 10,
				wave = 13,
				path = 1
			},
			{
				min_time = 3,
				delay = 20,
				max_time = 5,
				wave = 14,
				path = 2
			},
			{
				min_time = 4,
				delay = 50,
				max_time = 6,
				wave = 14,
				path = 3
			},
			{
				min_time = 3,
				delay = 80,
				max_time = 5,
				wave = 14,
				path = 2
			},
			{
				min_time = 4,
				delay = 110,
				max_time = 6,
				wave = 14,
				path = 1
			},
			{
				min_time = 4,
				delay = 10,
				max_time = 6,
				wave = 15,
				path = 3
			},
			{
				min_time = 3,
				delay = 40,
				max_time = 5,
				wave = 15,
				path = 2
			},
			{
				min_time = 4,
				delay = 70,
				max_time = 6,
				wave = 15,
				path = 1
			},
			{
				min_time = 3,
				delay = 100,
				max_time = 5,
				wave = 15,
				path = 4
			},
			{
				min_time = 4,
				delay = 130,
				max_time = 6,
				wave = 15,
				path = 1
			}
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.dragon_waves = {{
			min_time = 2,
			delay = 10,
			max_time = 5,
			wave = 1,
			path = 1
		}, {
			min_time = 6,
			delay = 8,
			max_time = 10,
			wave = 2,
			path = 1
		}, {
			min_time = 6,
			delay = 4,
			max_time = 10,
			wave = 3,
			path = 4
		}, {
			min_time = 6,
			delay = 1,
			max_time = 10,
			wave = 5,
			path = 1
		}, {
			min_time = 6,
			delay = 15,
			max_time = 10,
			wave = 5,
			path = 2
		}, {
			min_time = 3,
			delay = 35,
			max_time = 8,
			wave = 5,
			path = 3
		}}
	else
		self.dragon_waves = {{
			min_time = 5,
			delay = 10,
			max_time = 6,
			wave = 1,
			path = 3
		}, {
			min_time = 5,
			delay = 110,
			max_time = 6,
			wave = 1,
			path = 2
		}, {
			min_time = 5,
			delay = 230,
			max_time = 6,
			wave = 1,
			path = 1
		}, {
			min_time = 5,
			delay = 320,
			max_time = 6,
			wave = 1,
			path = 4
		}}
	end

	e = E:create_entity("background_sounds_underground")
	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	local dwi, dw = next(self.dragon_waves)
	local wts = store.tick_ts

	while not store.waves_finished and dw do
		while store.wave_group_number < dw.wave do
			coroutine.yield()
			wts = store.tick_ts
		end

		while store.tick_ts - wts < dw.delay do
			if store.wave_group_number ~= dw.wave then
				goto label_4_0
			end

			coroutine.yield()
		end

		self.dragon.attack_requested = dw
		self.dragon_cave_button.already_stolen = false
		::label_4_0::
		dwi, dw = next(self.dragon_waves, dwi)
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

return level
