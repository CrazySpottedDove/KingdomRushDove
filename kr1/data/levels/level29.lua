-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level03.lua

local log = require("lib.klua.log"):new("level03")
local signal = require("hump.signal")
local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")

require("constants")

local level = {}

level.required_sounds = {
	"music_stage29",
	"SpecialBanthaSounds",
	"SpecialFrog",
	"SpecialTusken"
}
level.required_textures = {
	"go_enemies_desert",
	"go_stages_desert",
	"go_stage29",
	"go_stage29_bg"
}

function level:init(store)
	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.max_upgrade_level = 6
		self.locked_towers = {
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.locked_hero = true
		self.max_upgrade_level = 3
		self.locked_towers = {
		}
	elseif store.level_mode == GAME_MODE_IRON then
		self.locked_hero = true
		self.max_upgrade_level = 3
		self.locked_towers = {
			"tower_build_engineer",
		}
	end

	store.level_terrain_type = TERRAIN_STYLE_DESERT
	self.locations = LU.load_locations(store, self)
end

function level:load(store)
	LU.insert_background(store, "Stage03_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage03_0002", Z_OBJECTS_COVERS)
	LU.insert_background(store, "Stage03_0003", Z_OBJECTS_COVERS)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	for _, h in pairs(self.locations.holders) do
		if store.level_mode == GAME_MODE_IRON then
			if h.id == "07" or h.id == "09" then
				LU.insert_tower(store, "tower_barrack_1", h.style, h.pos, h.rally_pos, nil, h.id)
			elseif h.id == "14" then
				LU.insert_tower(store, "tower_barrack_2", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			14,
			x,
			x,
			6
		},
		{
			3,
			x,
			14,
			7
		},
		{
			4,
			x,
			2,
			8
		},
		{
			x,
			5,
			3,
			9
		},
		{
			x,
			x,
			3,
			4
		},
		{
			7,
			14,
			14,
			12
		},
		{
			8,
			2,
			6,
			13
		},
		{
			9,
			3,
			7,
			13
		},
		{
			10,
			4,
			8,
			13
		},
		{
			11,
			9,
			13,
			13
		},
		{
			x,
			x,
			10,
			x
		},
		{
			13,
			6,
			x,
			x
		},
		{
			10,
			8,
			12,
			12
		},
		{
			2,
			x,
			1,
			6
		}
	}

	local e

	e = E:create_entity("decal_tusken")
	e.pos.x, e.pos.y = 193, 570
	e.target_center = V.v(565, 280)

	LU.queue_insert(store, e)

	-- e = E:create_entity("decal_frog")
	-- e.pos.x, e.pos.y = 872, 558

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal")
	-- e.render.sprites[1].draw_order = 2
	-- e.render.sprites[1].animated = false
	-- e.render.sprites[1].name = "Stage2_FrogStone"
	-- e.pos.x, e.pos.y = 872, 558

	-- LU.queue_insert(store, e)

	-- e = E:create_entity("decal_snake")
	-- e.pos.x, e.pos.y = 846, 392

	-- LU.queue_insert(store, e)

	-- for _, p in pairs({
	-- 	V.v(475, 671),
	-- 	V.v(274, 130)
	-- }) do
	-- 	e = E:create_entity("decal_bantha")
	-- 	e.pos = p

	-- 	LU.queue_insert(store, e)
	-- end

	-- local sparkle = E:create_entity("decal")

	-- sparkle.render.sprites[1].prefix = "decal_water_sparks"
	-- sparkle.render.sprites[1].name = "idle"
	-- sparkle.render.sprites[1].z = Z_DECALS

	-- for _, p in pairs({
	-- 	{
	-- 		920,
	-- 		512
	-- 	},
	-- 	{
	-- 		988,
	-- 		494
	-- 	},
	-- 	{
	-- 		1057,
	-- 		485
	-- 	}
	-- }) do
	-- 	e = E:clone_entity(sparkle)
	-- 	e.pos.x, e.pos.y = p[1], p[2]
	-- 	e.render.sprites[1].ts = U.frandom(0, 1)

	-- 	LU.queue_insert(store, e)
	-- end
end

function level:update(store)
	LU.insert_hero(store)

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end

return level
