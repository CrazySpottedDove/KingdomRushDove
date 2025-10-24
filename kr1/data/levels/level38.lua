-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level12.lua

local log = require("klua.log"):new("level12")
local signal = require("hump.signal")
local km = require("klua.macros")
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
local V = require("klua.vector")

require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}

level.required_sounds = {
	"music_stage38",
	"FrontiersUndergroundAmbienceSounds"
}
level.required_textures = {
	"go_enemies_underground",
	"go_stages_underground",
	"go_stage38",
	"go_stage38_bg"
}
level.show_comic_idx = 12

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_UNDERGROUND
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.locked_powers = {}
	self.max_upgrade_level = 6
	self.locked_towers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {
			"tower_build_mage",
			"tower_build_engineer"
		}
	end
end

function level:load(store)
	LU.insert_background(store, "Stage12_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage12_0005", Z_BACKGROUND_COVERS, nil, -4)
	LU.insert_background(store, "Stage12_0002", Z_OBJECTS, 548)
	LU.insert_background(store, "Stage12_0003", Z_OBJECTS, 623)
	LU.insert_background(store, "Stage12_0004", Z_OBJECTS, 354)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		for _, h in pairs(self.locations.holders) do
			if h.id == "2" then
				-- block empty
			elseif table.contains({
				"4",
				"5",
				"7",
				"8",
				"3",
				"14"
			}, h.id) then
				LU.insert_tower(store, "tower_holder_blocked_underground", h.style, h.pos, h.rally_pos, nil, h.id)
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
		{
			10,
			3,
			4,
			5
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			1,
			10
		},
		{
			1,
			x,
			6,
			5
		},
		{
			12,
			4,
			7,
			9
		},
		{
			5,
			4,
			x,
			7
		},
		{
			5,
			6,
			x,
			8
		},
		{
			5,
			7,
			x,
			9
		},
		{
			12,
			5,
			8,
			x
		},
		{
			11,
			3,
			1,
			12
		},
		{
			x,
			3,
			10,
			14
		},
		{
			13,
			10,
			5,
			9
		},
		{
			14,
			10,
			12,
			9
		},
		{
			x,
			11,
			13,
			9
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		},
		{
			x,
			x,
			x,
			x
		}
	}

	P:add_invalid_range(1, 79, nil)
	P:add_invalid_range(3, 104, nil)
	P:add_invalid_range(6, 1, 8)

	local t1 = E:create_entity("tunnel")

	t1.tunnel.pick_pi = 1
	t1.tunnel.place_pi = 6

	LU.queue_insert(store, t1)

	local t2 = E:create_entity("tunnel")

	t2.tunnel.pick_pi = 3
	t2.tunnel.place_pi = 6

	LU.queue_insert(store, t2)

	local tl = E:create_entity("decal_tunnel_light")

	tl.track_ids = {
		t1.id,
		t2.id
	}
	tl.pos.x, tl.pos.y = REF_W * 0.5, REF_H * 0.5
	tl.render.sprites[1].anchor = V.v(0.5, 0.5)
	tl.render.sprites[1].sort_y = 548

	LU.queue_insert(store, tl)

	local e

	-- e = E:create_entity("decal_cave_eyes")
	-- e.pos = v(464, 698)

	-- LU.queue_insert(store, e)

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

	e = E:create_entity("background_sounds_underground")

	LU.queue_insert(store, e)
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	log.debug("-- WON")
end

return level
