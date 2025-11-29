-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level21.lua

local log = require("lib.klua.log"):new("level21")
local bit = require("bit")
local signal = require("hump.signal")
local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local S = require("sound_db")
local P = require("path_db")

require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}

level.required_sounds = {
	"music_stage47",
	"HalloweenSounds",
	"HWVampiress",
	"HWVampireBoss"
}
level.required_textures = {
	"go_enemies_halloween",
    "go_enemies_blackburn",
	"go_stages_halloween",
	"go_hero_vampiress",
	"go_stage47",
	"go_stage47_bg"
}

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_HALLOWEEN
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.max_upgrade_level = 6
	self.locked_towers = {}
	self.locked_powers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {
			"tower_build_archer",
			"tower_build_barrack",
		}
	end
end

function level:load(store)
	LU.insert_background(store, "Stage21_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage21_0002", Z_OBJECTS, 666)
	LU.insert_background(store, "Stage21_0003", Z_OBJECTS, 595)
	LU.insert_background(store, "Stage21_0004", Z_OBJECTS, 540)
	LU.insert_background(store, "Stage21_0005", Z_OBJECTS, 558)
	LU.insert_background(store, "Stage21_0006", Z_OBJECTS, 525)
	LU.insert_background(store, "Stage21_0007", Z_OBJECTS_COVERS)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	for _, h in pairs(self.locations.holders) do
		if store.level_mode == GAME_MODE_IRON and table.contains({
			"2",
			"4",
			"9",
			"11"
		}, h.id) then
			LU.insert_tower(store, "tower_barrack_2", h.style, h.pos, h.rally_pos, 0, h.id)
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			2,
			2,
			x,
			7
		},
		{
			3,
			3,
			1,
			7
		},
		{
			6,
			4,
			2,
			x
		},
		{
			5,
			5,
			3,
			6
		},
		{
			12,
			x,
			4,
			11
		},
		{
			10,
			4,
			3,
			8
		},
		{
			9,
			2,
			1,
			x
		},
		{
			10,
			6,
			7,
			9
		},
		{
			13,
			8,
			7,
			x
		},
		{
			11,
			5,
			6,
			13
		},
		{
			12,
			5,
			10,
			13
		},
		{
			x,
			5,
			11,
			13
		},
		{
			12,
			11,
			9,
			x
		}
	}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		for i = 2, 3 do
			P:add_invalid_range(i, nil, 40, NF_ALL)
		end
	end

	local e

	e = E:create_entity("decal_defense_flag")
	e.pos = v(746, 53)

	LU.queue_insert(store, e)

	e = E:create_entity("decal")
	e.render.sprites[1].prefix = "grating_door"
	e.render.sprites[1].name = store.level_mode == GAME_MODE_CAMPAIGN and "closed" or "opened"
	e.render.sprites[1].anchor.y = 0.09259259259259259
	e.pos = v(571, 559)
	self.grating_door_right = e

	LU.queue_insert(store, e)

	e = E:clone_entity(e)
	e.render.sprites[1].flip_x = true
	e.pos = v(461, 559)
	self.grating_door_left = e

	LU.queue_insert(store, e)

	e = E:create_entity("decal")
	e.render.sprites[1].prefix = "castle_door"
	e.render.sprites[1].name = store.level_mode == GAME_MODE_CAMPAIGN and "closed" or "opened"
	e.render.sprites[1].anchor.y = 0
	e.pos = v(547, 670)
	self.castle_door_right = e

	LU.queue_insert(store, e)

	e = E:clone_entity(e)
	e.render.sprites[1].flip_x = true
	e.pos = v(484, 670)
	self.castle_door_left = e

	LU.queue_insert(store, e)

	local trees = {
		v(-2, 445),
		v(98, 449),
		v(162, 512),
		v(67, 376),
		v(197, 400),
		v(225, 471)
	}

	for _, p in pairs(trees) do
		e = E:create_entity("decal")
		e.render.sprites[1].animated = false
		e.render.sprites[1].name = "Halloween_stg20_tree"
		e.render.sprites[1].anchor = V.v(0.5, 0.10256410256410256)
		e.render.sprites[1].z = Z_OBJECTS
		e.pos = p

		LU.queue_insert(store, e)
	end

	e = E:create_entity("decal")
	e.render.sprites[1].animated = false
	e.render.sprites[1].name = "Halloween_stg21_tree"
	e.render.sprites[1].anchor = V.v(0.5, 0.1276595744680851)
	e.render.sprites[1].z = Z_OBJECTS
	e.pos = v(61, 493)

	LU.queue_insert(store, e)

	local stones = {
		{
			2,
			v(103, 111),
			0.175
		},
		{
			3,
			v(41, 161),
			0.0625
		},
		{
			4,
			v(425, 291),
			0.1625,
			true
		}
	}

	for _, d in pairs(stones) do
		local id, pos, anchor_y, flip = unpack(d)

		e = E:create_entity("decal_moon_activated")
		e.render.sprites[1].name = "Halloween_stg20_stones_000" .. id
		e.render.sprites[1].anchor.y = anchor_y
		e.render.sprites[1].flip_x = flip
		e.render.sprites[2].name = "Halloween_stg20_stone_lights_000" .. id
		e.render.sprites[2].anchor.y = anchor_y
		e.render.sprites[2].flip_x = flip
		e.pos = pos

		LU.queue_insert(store, e)
	end

	local torches = {
		v(85, 643),
		v(130, 630),
		v(283, 564),
		v(329, 552),
		v(372, 564),
		v(663, 564),
		v(708, 552),
		v(751, 564),
		v(1007, 670)
	}

	for _, p in pairs(torches) do
		e = E:create_entity("decal")
		e.render.sprites[1].name = "castle_torch_fire"
		e.render.sprites[1].ts = U.frandom(0, 0.5)
		e.render.sprites[1].anchor.y = 0
		e.pos = p

		LU.queue_insert(store, e)
	end

	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		e = E:create_entity("decal")
		e.render.sprites[1].name = "Halloween_stg21_chateauTour_0001"
		e.render.sprites[1].animated = false
		e.pos = v(414, 534)

		LU.queue_insert(store, e)

		e = E:create_entity("decal")
		e.render.sprites[1].name = "Halloween_stg21_chateauTour_0002"
		e.render.sprites[1].animated = false
		e.pos = v(617, 533)

		LU.queue_insert(store, e)
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		e = E:create_entity("decal_taunting_dracula")

		LU.queue_insert(store, e)

		self.decal_taunting_dracula = e
	end

	self.moon_overlay = E:create_entity("decal_moon_overlay")

	LU.queue_insert(store, self.moon_overlay)

	self.decal_moon_dark = E:create_entity("decal_moon_dark")

	LU.queue_insert(store, self.decal_moon_dark)

	self.decal_moon_light = E:create_entity("decal_moon_light")

	LU.queue_insert(store, self.decal_moon_light)

	e = E:create_entity("moon_controller")
	e.moon_overlay = self.moon_overlay
	e.decal_moon_dark = self.decal_moon_dark
	e.decal_moon_light = self.decal_moon_light
	e.transit_time = fts(550)

	LU.queue_insert(store, e)

	self.moon_controller = e

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.moon_controller.waves = {
			{
				2,
				fts(780),
				15
			},
			{
				6,
				fts(1100),
				8
			},
			{
				7,
				fts(700),
				25
			},
			{
				11,
				fts(800),
				32
			},
			{
				12,
				fts(590),
				35
			},
			{
				13,
				fts(1200),
				10
			},
			{
				15,
				fts(2300),
				400000
			}
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		self.moon_controller.waves = {
			{
				5,
				fts(1400),
				15
			},
			{
				6,
				fts(2100),
				10
			}
		}
	elseif store.level_mode == GAME_MODE_IRON then
		self.moon_controller.waves = {
			{
				1,
				fts(1),
				400000
			}
		}
	end

	e = E:create_entity("points_spawner")

	LU.queue_insert(store, e)

	self.points_spawner = e
	e.spawner_points = {
		{
			path = 2,
			from = v(289, 489),
			to = v(290, 404)
		},
		{
			path = 2,
			from = v(57, 351),
			to = v(102, 291)
		},
		{
			path = 2,
			from = v(76, 163),
			to = v(139, 201)
		},
		{
			path = 2,
			from = v(432, 373),
			to = v(377, 426)
		},
		{
			path = 2,
			from = v(378, 291),
			to = v(401, 221)
		},
		{
			path = 3,
			from = v(531, 351),
			to = v(597, 300)
		},
		{
			path = 3,
			from = v(684, 180),
			to = v(705, 241)
		},
		{
			path = 3,
			from = v(693, 474),
			to = v(651, 408)
		},
		{
			path = 4,
			from = v(915, 349),
			to = v(825, 376)
		},
		{
			path = 2,
			from = v(340, 661),
			to = v(208, 341)
		},
		{
			path = 2,
			from = v(340, 661),
			to = v(198, 196)
		},
		{
			path = 3,
			from = v(722, 661),
			to = v(633, 377)
		},
		{
			path = 3,
			from = v(722, 661),
			to = v(653, 243)
		},
		{
			path = 2,
			from = v(514, 804),
			to = v(514, 804)
		},
		{
			path = 3,
			from = v(515, 804),
			to = v(515, 804)
		}
	}
	e.spawner_groups = {
		[100] = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		},
		[101] = {
			1,
			4,
			6,
			8
		},
		[102] = {
			6,
			8,
			9
		},
		[103] = {
			1,
			2,
			4,
			5
		},
		[104] = {
			4,
			5,
			6
		},
		[1000] = {
			10
		},
		[1001] = {
			11
		},
		[1002] = {
			12
		},
		[1003] = {
			13
		},
		[1100] = {
			10,
			11,
			12,
			13
		},
		[2001] = {
			14
		},
		[2002] = {
			15
		}
	}

	if store.level_mode == GAME_MODE_CAMPAIGN then
		e.spawner_waves = {
			{
				{
					0.6666666666666666,
					0.5,
					7,
					0,
					5,
					true,
					2,
					3,
					"enemy_halloween_zombie"
				},
				{
					6.666666666666667,
					0.5,
					102,
					0,
					4,
					true,
					2,
					3,
					"enemy_halloween_zombie"
				}
			},
			{
				{
					6.666666666666667,
					0.5,
					4,
					0,
					4,
					true,
					2,
					3,
					"enemy_halloween_zombie"
				},
				{
					26.333333333333332,
					0.5,
					103,
					0,
					3,
					true,
					2,
					3,
					"enemy_halloween_zombie"
				}
			},
			{
				{
					2,
					0.5,
					103,
					0,
					4,
					true,
					2,
					3,
					"enemy_halloween_zombie"
				},
				{
					13.333333333333334,
					0.5,
					8,
					0,
					3,
					true,
					2,
					6,
					"enemy_ghost"
				},
				{
					18.333333333333332,
					0.5,
					9,
					0,
					4,
					true,
					2,
					6,
					"enemy_ghost"
				}
			},
			{
				{
					19.666666666666668,
					0.5,
					102,
					0,
					1,
					true,
					2,
					3,
					"enemy_ghoul"
				}
			},
			{
				{
					13.333333333333334,
					0.5,
					102,
					0,
					2,
					true,
					3,
					5,
					"enemy_ghoul"
				},
				{
					0.6666666666666666,
					0.5,
					1000,
					0,
					2,
					true,
					3,
					3,
					"elvira_bat"
				},
				{
					35,
					0.5,
					1000,
					0,
					3,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					60,
					0.5,
					1000,
					0,
					4,
					true,
					1,
					1,
					"elvira_bat"
				}
			},
			[8] = {
				{
					5,
					0.5,
					1002,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					5.666666666666667,
					0.5,
					1003,
					0,
					2,
					true,
					3,
					3,
					"elvira_bat"
				},
				{
					10,
					0.5,
					1000,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					10.066666666666666,
					0.5,
					1001,
					0,
					2,
					true,
					3,
					3,
					"elvira_bat"
				},
				{
					18.333333333333332,
					0.5,
					1002,
					0,
					3,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					28.333333333333332,
					0.5,
					1001,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					43.333333333333336,
					0.5,
					1100,
					0,
					3,
					true,
					3,
					3,
					"elvira_bat"
				}
			},
			[9] = {
				{
					3.3333333333333335,
					0.5,
					1002,
					0,
					3,
					true,
					3,
					5,
					"elvira_bat"
				},
				{
					6.666666666666667,
					0.5,
					1000,
					0,
					3,
					true,
					3,
					3,
					"elvira_bat"
				},
				{
					10,
					0.5,
					100,
					0,
					3,
					true,
					2,
					6,
					"enemy_halloween_zombie"
				},
				{
					50,
					0.5,
					1000,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					46.666666666666664,
					0.5,
					1002,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				}
			},
			[10] = {
				{
					0.6666666666666666,
					0.5,
					102,
					0,
					2,
					true,
					4,
					5,
					"enemy_ghost"
				},
				{
					20,
					0.5,
					8,
					0,
					4,
					true,
					2,
					2,
					"enemy_ghost"
				},
				{
					60,
					0.5,
					102,
					0,
					5,
					true,
					2,
					3,
					"enemy_ghost"
				}
			},
			[11] = {
				{
					0.6666666666666666,
					0.5,
					1100,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					16.666666666666668,
					0.5,
					1000,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					16.666666666666668,
					0.5,
					1002,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					30.333333333333332,
					0.5,
					1100,
					0,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					50,
					0.5,
					1100,
					0,
					2,
					true,
					1,
					1,
					"elvira_bat"
				}
			},
			[12] = {
				{
					20,
					0.5,
					102,
					0,
					2,
					true,
					4,
					5,
					"enemy_ghost"
				},
				{
					36.666666666666664,
					0.5,
					102,
					0,
					3,
					true,
					2,
					2,
					"enemy_ghost"
				},
				{
					60,
					0.5,
					102,
					0,
					5,
					true,
					2,
					3,
					"enemy_ghost"
				}
			},
			[13] = {
				{
					3.3333333333333335,
					0.5,
					1003,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					2.6666666666666665,
					0.5,
					7,
					0,
					5,
					true,
					1,
					3,
					"enemy_halloween_zombie"
				},
				{
					8.333333333333334,
					0.5,
					1001,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					7.666666666666667,
					0.5,
					3,
					0,
					6,
					true,
					1,
					3,
					"enemy_halloween_zombie"
				},
				{
					16.666666666666668,
					0.5,
					1000,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					15.666666666666666,
					0.5,
					103,
					0,
					3,
					true,
					1,
					3,
					"enemy_halloween_zombie"
				},
				{
					40,
					1.5,
					1100,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					266.6666666666667,
					1.5,
					100,
					0,
					2,
					true,
					3,
					5,
					"enemy_halloween_zombie"
				},
				{
					40,
					0.5,
					100,
					0,
					2,
					true,
					5,
					5,
					"enemy_ghoul"
				}
			},
			[15] = {
				{
					60,
					0.5,
					103,
					0,
					2,
					true,
					2,
					2,
					"enemy_ghoul"
				},
				{
					60,
					0.5,
					3,
					0,
					1,
					true,
					2,
					2,
					"enemy_ghoul"
				}
			},
			BOSS = {
				{
					0,
					0,
					2001,
					2,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					0,
					0,
					2001,
					3,
					2,
					true,
					2,
					2,
					"elvira_bat"
				},
				{
					17,
					0,
					1000,
					2,
					3,
					true,
					8,
					8,
					"elvira_bat"
				},
				{
					17,
					0,
					1000,
					3,
					3,
					true,
					8,
					8,
					"elvira_bat"
				},
				{
					15,
					0,
					1000,
					1,
					3,
					true,
					8,
					8,
					"elvira_bat"
				},
				{
					5,
					0,
					2002,
					2,
					6,
					true,
					3,
					6,
					"enemy_ghost"
				},
				{
					5,
					0,
					2002,
					3,
					6,
					true,
					3,
					6,
					"enemy_ghost"
				},
				{
					21.666666666666668,
					0,
					102,
					0,
					3,
					true,
					2,
					2,
					"enemy_halloween_zombie"
				},
				{
					21.666666666666668,
					0,
					1000,
					0,
					9,
					true,
					3,
					6,
					"elvira_bat"
				},
				{
					55,
					0,
					102,
					0,
					4,
					true,
					3,
					4,
					"enemy_halloween_zombie"
				},
				{
					60,
					0,
					102,
					0,
					2,
					true,
					3,
					5,
					"enemy_ghoul"
				},
				{
					65,
					0,
					2001,
					0,
					12,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					71,
					0,
					1000,
					0,
					5,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					73,
					0,
					1001,
					0,
					5,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					71.66666666666667,
					0,
					102,
					0,
					2,
					true,
					1,
					2,
					"enemy_halloween_zombie"
				},
				{
					76.66666666666667,
					0,
					9,
					0,
					5,
					true,
					2,
					4,
					"enemy_ghoul"
				}
			},
			BOSS_ANGRY = {
				{
					6.666666666666667,
					0,
					2001,
					2,
					10,
					false,
					3,
					3,
					"elvira_bat"
				},
				{
					8.666666666666668,
					0,
					2001,
					3,
					10,
					false,
					3,
					3,
					"elvira_bat"
				},
				{
					13.333333333333334,
					0,
					1000,
					0,
					10,
					false,
					3,
					3,
					"elvira_bat"
				},
				{
					15.333333333333334,
					0,
					1001,
					0,
					5,
					false,
					6,
					8,
					"elvira_bat"
				},
				{
					83.33333333333333,
					0,
					1002,
					3,
					10,
					false,
					4,
					4,
					"elvira_bat"
				},
				{
					85.33333333333333,
					0,
					1002,
					2,
					6,
					false,
					4,
					4,
					"elvira_bat"
				},
				{
					85.33333333333333,
					0,
					1002,
					1,
					3,
					false,
					6,
					8,
					"elvira_bat"
				}
			}
		}
	elseif store.level_mode == GAME_MODE_HEROIC then
		e.spawner_waves = {
			[3] = {
				{
					16.666666666666668,
					0.5,
					1002,
					0,
					2,
					true,
					6,
					6,
					"elvira_bat"
				},
				{
					16.666666666666668,
					0.5,
					1003,
					0,
					2,
					true,
					6,
					6,
					"elvira_bat"
				}
			},
			[4] = {
				{
					10,
					0.5,
					1002,
					0,
					4,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					25,
					0.5,
					1002,
					0,
					4,
					true,
					3,
					3,
					"elvira_bat"
				},
				{
					28.333333333333332,
					0.5,
					1003,
					0,
					2,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					43.333333333333336,
					0.5,
					1002,
					0,
					4,
					true,
					2,
					2,
					"elvira_bat"
				}
			}
		}
	elseif store.level_mode == GAME_MODE_IRON then
		e.spawner_waves = {
			{
				{
					0.03333333333333333,
					1.5,
					100,
					0,
					1,
					true,
					5,
					5,
					"enemy_ghoul"
				},
				{
					16.666666666666668,
					2.5,
					102,
					0,
					5,
					true,
					2,
					4,
					"enemy_ghoul"
				},
				{
					26.666666666666668,
					0.5,
					1003,
					0,
					2,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					40,
					0.5,
					1002,
					0,
					3,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					73.33333333333333,
					0.5,
					1000,
					0,
					5,
					true,
					1,
					1,
					"elvira_bat"
				},
				{
					130,
					0.5,
					103,
					0,
					7,
					true,
					3,
					4,
					"enemy_halloween_zombie"
				},
				{
					206.66666666666666,
					0.5,
					1000,
					0,
					3,
					true,
					0.5,
					0.5,
					"elvira_bat"
				},
				{
					216.66666666666666,
					0.5,
					1001,
					0,
					3,
					true,
					0.5,
					0.5,
					"elvira_bat"
				},
				{
					233.33333333333334,
					0.5,
					1000,
					0,
					7,
					true,
					5,
					6,
					"elvira_bat"
				}
			}
		}
	end
end

function level:update(store)
	LU.insert_hero(store)
	LU.insert_hero(store, "hero_vampiress", store.level.locations.exits[2].pos)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		while store.wave_group_number < 2 do
			coroutine.yield()
		end

		U.animation_start(self.grating_door_left, "open", nil, store.tick_ts, false)
		U.animation_start(self.grating_door_right, "open", nil, store.tick_ts, false)
		U.animation_start(self.castle_door_left, "open", nil, store.tick_ts, false)
		U.animation_start(self.castle_door_right, "open", nil, store.tick_ts, false)
		S:queue("HWCastleDoorsOpen")

		for i = 2, 3 do
			P:remove_invalid_range(i, nil, 40)
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		while self.decal_taunting_dracula.showing do
			coroutine.yield()
		end

		LU.queue_remove(store, self.decal_taunting_dracula)
		U.y_wait(store, 2)
		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 2.5, {
			x = 512,
			y = 550
		}, 2)
		signal.emit("hide-gui")

		local boss = E:create_entity("eb_dracula")

		boss.nav_path.pi = 2
		boss.nav_path.spi = 1
		boss.nav_path.ni = 1
		boss.pos = P:node_pos(boss.nav_path)

		LU.queue_insert(store, boss)

		self.boss = boss

		U.y_wait(store, 4)

		self.points_spawner.manual_wave = "BOSS"

		while self.boss.phase ~= "fight" do
			coroutine.yield()
		end

		signal.emit("show-gui")
		signal.emit("hide-curtains")
		signal.emit("pan-zoom-camera", 2, {
			x = 512,
			y = 384
		}, 1)

		while self.boss.phase ~= "angry" do
			if not store.entities[self.boss.id] then
				goto label_4_0
			end

			coroutine.yield()
		end

		self.points_spawner.manual_wave = "BOSS_ANGRY"

		while self.boss.phase ~= "dead" do
			if not store.entities[self.boss.id] then
				break
			end

			coroutine.yield()
		end

		::label_4_0::

		self.points_spawner.interrupt = true
	end

	while not store.waves_finished or LU.has_alive_enemies(store) do
		coroutine.yield()
	end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		U.y_wait(store, 3)
	end

	log.debug("-- WON")
end

return level
