-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level16.lua

local log = require("lib.klua.log"):new("level16")
local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")

require("constants")

local level = {}

level.required_sounds = {
	"music_stage42",
	"PiratesSounds",
	"PirateBigSounds",
	"PirateTowerSounds",
	"RisingTidesSounds",
	"SpecialMermaid",
	"SpecialVolcanoSounds"
}
level.required_textures = {
	"go_enemies_desert",
	"go_enemies_rising_tides",
	"go_stages_rising_tides",
	"go_stage42",
	"go_stage42_bg",
}
level.show_comic_idx = 16

function level:init(store)
	store.level_terrain_type = TERRAIN_STYLE_BEACH
	self.locations = LU.load_locations(store, self)
	self.locked_hero = false
	self.max_upgrade_level = 6
	self.locked_towers = {}
	self.locked_powers = {}

	if store.level_mode == GAME_MODE_IRON then
		self.locked_towers = {
			"tower_build_mage",
			"tower_build_engineer"
		}
	end
    self.unlock_towers = {"tower_pirate_watchtower"}
end

function level:load(store)
	LU.insert_background(store, "Stage16_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage16_0002", Z_OBJECT, 616)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	for _, h in pairs(self.locations.holders) do
		if store.level_mode == GAME_MODE_CAMPAIGN and (h.id == "8" or h.id == "5") or store.level_mode == GAME_MODE_HEROIC and (h.id == "8" or h.id == "141") or store.level_mode == GAME_MODE_IRON and (h.id == "8" or h.id == "7" or h.id == "11") then
			LU.insert_tower(store, "tower_pirate_watchtower", h.style, h.pos, h.rally_pos, nil, h.id)
		elseif h.id == "13" then
			LU.insert_tower(store, "tower_barrack_pirates", h.style, h.pos, h.rally_pos, nil, h.id)
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			2,
			13,
			141,
			14
		},
		{
			x,
			13,
			1,
			x
		},
		{
			141,
			7,
			4,
			x
		},
		{
			3,
			5,
			6,
			x
		},
		{
			7,
			9,
			6,
			4
		},
		{
			5,
			5,
			x,
			4
		},
		{
			10,
			8,
			5,
			3
		},
		{
			12,
			x,
			9,
			11
		},
		{
			7,
			8,
			x,
			5
		},
		{
			13,
			11,
			7,
			141
		},
		{
			13,
			8,
			7,
			10
		},
		{
			x,
			x,
			8,
			13
		},
		{
			x,
			12,
			10,
			2
		},
		{
			2,
			141,
			3,
			x
		},
		[141] = {
			1,
			10,
			3,
			14
		}
	}

	local e
	local water_sparks = {
		V.v(-110, 430),
		V.v(-20, 431),
		V.v(240, 769),
		V.v(378, 708),
		V.v(411, 602),
		V.v(415, 772),
		V.v(432, 538),
		V.v(453, 675),
		V.v(492, 338),
		V.v(516, 399),
		V.v(516, 483),
		V.v(520, 548),
		V.v(590, 453),
		V.v(617, 526),
		V.v(686, 581),
		V.v(710, 660),
		V.v(764, 731),
		V.v(874, 737),
		V.v(1024, 750),
		V.v(1104, 725)
	}

	for _, p in pairs(water_sparks) do
		e = E:create_entity("decal")
		e.render.sprites[1].name = "decal_water_sparks_16_idle"
		e.render.sprites[1].ts = U.frandom(0, 0.5)
		e.render.sprites[1].z = Z_DECALS
		e.pos = p

		LU.queue_insert(store, e)
	end

	-- local fish = {
	-- 	V.v(461, 504),
	-- 	V.v(438, 722),
	-- 	V.v(471, 379),
	-- 	V.v(672, 580)
	-- }

	-- for _, p in pairs(fish) do
	-- 	e = E:create_entity("decal_jumping_fish2")
	-- 	e.pos = p

	-- 	LU.queue_insert(store, e)
	-- end

	-- local waves = {
	-- 	{
	-- 		544,
	-- 		363,
	-- 		135
	-- 	},
	-- 	{
	-- 		679,
	-- 		521,
	-- 		120
	-- 	},
	-- 	{
	-- 		739,
	-- 		591,
	-- 		120
	-- 	},
	-- 	{
	-- 		448,
	-- 		461,
	-- 		-157
	-- 	},
	-- 	{
	-- 		429,
	-- 		356,
	-- 		-133
	-- 	},
	-- 	{
	-- 		376,
	-- 		526,
	-- 		-145
	-- 	},
	-- 	{
	-- 		298,
	-- 		625,
	-- 		-27
	-- 	}
	-- }

	-- for _, v in pairs(waves) do
	-- 	local x, y, r = unpack(v)

	-- 	e = E:create_entity("decal_water_wave_16")
	-- 	e.pos = V.v(x, y)
	-- 	e.render.sprites[1].r = math.pi * -1 * r / 180

	-- 	LU.queue_insert(store, e)
	-- end

	if store.level_mode == GAME_MODE_CAMPAIGN then
		self.gunboat_waves = {
			[2] = {
				{
					delay = 5,
					shots = {
						0,
						4,
						0
					}
				}
			},
			[4] = {
				{
					delay = 5,
					shots = {
						4,
						0,
						4
					}
				}
			},
			[6] = {
				{
					delay = 3,
					shots = {
						4,
						6,
						6
					}
				}
			},
			[8] = {
				{
					delay = 5,
					shots = {
						5,
						5,
						0
					}
				}
			},
			[11] = {
				{
					delay = 2,
					shots = {
						11,
						0,
						12
					}
				}
			},
			[14] = {
				{
					delay = 18,
					shots = {
						0,
						0,
						20
					}
				}
			}
		}
	elseif store.level_mode == GAME_MODE_IRON then
		self.gunboat_waves = {
			{
				{
					delay = 0,
					shots = {
						2,
						12,
						4
					}
				},
				{
					delay = 25,
					shots = {
						2,
						3,
						4
					}
				},
				{
					delay = 57,
					shots = {
						4,
						4,
						3
					}
				},
				{
					delay = 85,
					shots = {
						3,
						0,
						2
					}
				},
				{
					delay = 123,
					shots = {
						3,
						3,
						3
					}
				},
				{
					delay = 185,
					shots = {
						3,
						3,
						35
					}
				},
				{
					delay = 200,
					shots = {
						3,
						27,
						0
					}
				},
				{
					delay = 210,
					shots = {
						25,
						0,
						0
					}
				},
				{
					delay = 280,
					shots = {
						3,
						3,
						25
					}
				},
				{
					delay = 290,
					shots = {
						3,
						17,
						0
					}
				},
				{
					delay = 300,
					shots = {
						15,
						0,
						0
					}
				}
			}
		}
	end
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	while not store.waves_finished do
		local wave_number = store.wave_group_number

		if self.gunboat_waves and self.gunboat_waves[wave_number] then
			local start_ts = store.tick_ts

			for _, gw in pairs(self.gunboat_waves[wave_number]) do
				local offset_delay = gw.delay - (store.tick_ts - start_ts)

				U.y_wait(store, offset_delay)

				if store.waves_finished then
					goto label_3_0
				end

				local e = E:create_entity("enemy_gunboat")

				e.nav_path.pi = 6
				e.attacks.list[1].stop_at_nodes = {
					32,
					52,
					72
				}
				e.attacks.list[1].shots_at_node = gw.shots

				LU.queue_insert(store, e)
			end

			while wave_number == store.wave_group_number and not store.waves_finished do
				coroutine.yield()
			end
		end

		::label_3_0::

		coroutine.yield()
	end

	while LU.has_alive_enemies(store) do
		coroutine.yield()
	end
end

return level
