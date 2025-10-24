-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level17.lua

local log = require("klua.log"):new("level17")
local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local S = require("sound_db")
local P = require("path_db")

require("constants")

local level = {}

level.required_sounds = {
	"music_stage43",
	"PirateBoatSounds",
	"RisingTidesSounds",
	"SpecialMermaid"
}
level.required_textures = {
	"go_enemies_desert",
	"go_enemies_rising_tides",
	"go_stages_rising_tides",
	"go_stage43",
	"go_stage43_bg",
	"go_hero_pirate"
}
local x = nil
level.nav_mesh = {
    [0] = {7, 1, x, 10},
    {2, x, x, 0},
    {21, x, 1, 7},
    {4, 21, 21, 5},
    {x, 3, 5, 6},
    {4, 3, 7, 66},
    {x, 4, 66, x},
    {5, 2, 0, 8},
    {66, 7, 10, x},
    [10] = {8, 0, x, x},
    [21] = {3, x, 2, 7},
    [66] = {6, 5, 8, x}
}


function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_BEACH
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.max_upgrade_level = 6
	self.locked_towers = {}
	self.locked_powers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {
			"tower_build_archer",
			"tower_build_engineer",
		}
	end
end

function level:load(store)
	LU.insert_background(store, "Stage17_0001", Z_BACKGROUND)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	local flags = {
		{
			"decal_defense_flag_water",
			1000,
			177
		},
		{
			"decal_defense_flag_water",
			1000,
			85
		}
	}

	for _, f in pairs(flags) do
		local e = E:create_entity(f[1])

		e.pos.x, e.pos.y = f[2], f[3]
		e.render.sprites[1].ts = U.frandom(0, 0.5)

		LU.queue_insert(store, e)
	end

	for _, h in pairs(self.locations.holders) do
		if h.id == "00" then
			if store.level_mode == GAME_MODE_IRON then
				LU.insert_tower(store, "tower_neptune", h.style, h.pos, h.rally_pos, nil, h.id)
			else
				LU.insert_tower(store, "tower_neptune_holder", h.style, h.pos, h.rally_pos, nil, h.id)
			end
		elseif h.id == "05" and store.level_mode == GAME_MODE_IRON then
			LU.insert_tower(store, "tower_barrack_1", h.style, h.pos, h.rally_pos, nil, h.id)
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	P:add_invalid_range(5, 1, 17)

	for i = 6, 9 do
		P:add_invalid_range(i, 1, 11)
	end

	local e

	e = E:create_entity("decal")
	e.render.sprites[1].animated = false
	e.render.sprites[1].name = "Stage17_boat_top_0001"
	e.render.sprites[1].anchor = V.v(0.5, 0.1)
	e.render.sprites[1].z = Z_OBJECTS
	e.pos.x, e.pos.y = 84, 129

	LU.queue_insert(store, e)

	if store.level_mode == GAME_MODE_CAMPAIGN then
		e = E:create_entity("decal")
		e.render.sprites[1].animated = false
		e.render.sprites[1].name = "Stage17_boat_top_0002"
		e.render.sprites[1].anchor = V.v(0.5, 0.1)
		e.render.sprites[1].z = Z_OBJECTS
		e.pos.x, e.pos.y = 84, 129

		LU.queue_insert(store, e)

		self.ship_cover = e
		e = E:create_entity("decal")
		e.render.sprites[1].animation = {
			prefix = "Stage17_boat",
			to = 26,
			from = 1
		}
		e.render.sprites[1].hidden = true
		e.render.sprites[1].loop = false
		e.render.sprites[1].z = Z_DECALS
		e.pos.x, e.pos.y = 182, 160

		LU.queue_insert(store, e)

		self.ship_blown = e
	end

	e = E:create_entity("decal")
	e.render.sprites[1].animation = {
		prefix = "Stage17_waterFall",
		to = 9,
		from = 1
	}
	e.render.sprites[1].z = Z_DECALS
	e.pos.x, e.pos.y = 447, 737

	LU.queue_insert(store, e)

	e = E:create_entity("decal")
	e.render.sprites[1].animation = {
		prefix = "Stage17_waterFall_waves",
		to = 27,
		from = 1
	}
	e.render.sprites[1].z = Z_DECALS
	e.pos.x, e.pos.y = 447, 737

	LU.queue_insert(store, e)

	-- local fish_pos = {
	-- 	V.v(37, 400),
	-- 	V.v(93, 557),
	-- 	V.v(313, 309),
	-- 	V.v(373, 683),
	-- 	V.v(429, 530),
	-- 	V.v(613, 395),
	-- 	V.v(805, 619),
	-- 	V.v(704, 688),
	-- 	V.v(1003, 143)
	-- }

	-- for _, p in pairs(fish_pos) do
	-- 	e = E:create_entity("decal_jumping_fish2")
	-- 	e.pos = p

	-- 	LU.queue_insert(store, e)
	-- end

	local water_sparks = {
		V.v(97, 642),
		V.v(110, 570),
		V.v(20, 512),
		V.v(137, 502),
		V.v(358, 446),
		V.v(355, 293),
		V.v(514, 362),
		V.v(404, 583),
		V.v(422, 514),
		V.v(469, 459),
		V.v(539, 426),
		V.v(405, 360),
		V.v(216, 295),
		V.v(90, 316),
		V.v(22, 380),
		V.v(394, 646),
		V.v(7, 620),
		V.v(621, 369),
		V.v(620, 479),
		V.v(652, 306),
		V.v(707, 568),
		V.v(787, 615),
		V.v(721, 672),
		V.v(944, 153),
		V.v(1011, 102),
		V.v(-46, 459),
		V.v(-129, 251),
		V.v(-43, 300)
	}

	for _, p in pairs(water_sparks) do
		e = E:create_entity("decal")
		e.render.sprites[1].name = "decal_water_sparks_16_idle"
		e.render.sprites[1].ts = U.frandom(0, 0.5)
		e.render.sprites[1].z = Z_DECALS
		e.pos = p

		LU.queue_insert(store, e)
	end

	e = E:create_entity("decal")
	e.render.sprites[1].animated = false
	e.render.sprites[1].name = "Stage17_lighthouse"
	e.render.sprites[1].anchor = V.v(0.5, 0)
	e.render.sprites[1].z = Z_OBJECTS
	e.pos.x, e.pos.y = 147, 381

	LU.queue_insert(store, e)

	-- local wave_pos = {
	-- 	{
	-- 		158,
	-- 		634,
	-- 		70
	-- 	},
	-- 	{
	-- 		881,
	-- 		84,
	-- 		-175
	-- 	},
	-- 	{
	-- 		990,
	-- 		190,
	-- 		-5
	-- 	},
	-- 	{
	-- 		306,
	-- 		254,
	-- 		-169
	-- 	},
	-- 	{
	-- 		398,
	-- 		232,
	-- 		180
	-- 	},
	-- 	{
	-- 		535,
	-- 		326,
	-- 		180
	-- 	},
	-- 	{
	-- 		694,
	-- 		390,
	-- 		126
	-- 	},
	-- 	{
	-- 		751,
	-- 		540,
	-- 		180
	-- 	},
	-- 	{
	-- 		635,
	-- 		550,
	-- 		-19
	-- 	},
	-- 	{
	-- 		732,
	-- 		715,
	-- 		0
	-- 	},
	-- 	{
	-- 		653,
	-- 		663,
	-- 		-76
	-- 	},
	-- 	{
	-- 		484,
	-- 		551,
	-- 		26
	-- 	},
	-- 	{
	-- 		456,
	-- 		637,
	-- 		103
	-- 	},
	-- 	{
	-- 		337,
	-- 		628,
	-- 		-88
	-- 	},
	-- 	{
	-- 		341,
	-- 		488,
	-- 		-17
	-- 	},
	-- 	{
	-- 		232,
	-- 		503,
	-- 		27
	-- 	},
	-- 	{
	-- 		259,
	-- 		345,
	-- 		0
	-- 	}
	-- }

	-- for _, v in pairs(wave_pos) do
	-- 	local x, y, r = unpack(v)

	-- 	e = E:create_entity("decal_water_wave_16")
	-- 	e.pos = V.v(x, y)
	-- 	e.render.sprites[1].r = math.pi * -1 * r / 180

	-- 	LU.queue_insert(store, e)
	-- end
end

function level:update(store)
	LU.insert_hero(store)
    LU.insert_hero(store, "hero_steam_frigate", V.v(646, 421))

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number ~= 5 do
			coroutine.yield()
		end

		self.ship_cover.render.sprites[1].hidden = true
		self.ship_blown.render.sprites[1].hidden = false
		self.ship_blown.render.sprites[1].ts = store.tick_ts
		self.ship_blown.render.sprites[1].runs = 0

		S:queue("RTBoatBreak")
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end

return level
