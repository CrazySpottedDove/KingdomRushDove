-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/data/levels/level18.lua

local log = require("lib.klua.log"):new("level18")
local E = require("entity_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local S = require("sound_db")
local P = require("path_db")
local signal = require("hump.signal")

require("constants")

local level = {}

level.required_sounds = {
	"music_stage44",
	"RisingTidesSounds",
	"SpecialMermaid"
}
level.required_textures = {
	"go_enemies_desert",
	"go_enemies_rising_tides",
	"go_stages_rising_tides",
	"go_stage44",
	"go_stage44_bg"
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
			"tower_build_barrack",
		}
	end
end

function level:load(store)
	LU.insert_background(store, "Stage18_0001", Z_BACKGROUND)
	LU.insert_background(store, "Stage18_0002", Z_OBJECT, 370)
	LU.insert_defend_points(store, self.locations.exits, store.level_terrain_type)

	local flags = {
		{
			"decal_defense_flag_water",
			717,
			55
		},
		{
			"decal_defense_flag_water",
			863,
			55
		},
		{
			"decal_defense_flag",
			400,
			55
		},
		{
			"decal_defense_flag",
			549,
			55
		}
	}

	for _, f in pairs(flags) do
		local e = E:create_entity(f[1])

		e.pos.x, e.pos.y = f[2], f[3]
		e.render.sprites[1].ts = U.frandom(0, 0.5)

		LU.queue_insert(store, e)
	end

	for _, h in pairs(self.locations.holders) do
		if store.level_mode == GAME_MODE_CAMPAIGN and h.id == "3" then
			LU.insert_tower(store, "tower_neptune_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		elseif store.level_mode == GAME_MODE_HEROIC and h.id == "3" then
			local t = LU.insert_tower(store, "tower_archmage", h.style, h.pos, h.rally_pos, nil, h.id)

			t.tower.can_be_sold = false
		elseif store.level_mode == GAME_MODE_IRON and table.contains({
			"3",
			"4",
			"8"
		}, h.id) then
			LU.insert_tower(store, "tower_neptune", h.style, h.pos, h.rally_pos, nil, h.id)
		else
			LU.insert_tower(store, "tower_holder", h.style, h.pos, h.rally_pos, nil, h.id)
		end
	end

	local x

	self.nav_mesh = {
		{
			2,
			x,
			x,
			3
		},
		{
			8,
			x,
			1,
			3
		},
		{
			8,
			1,
			4,
			12
		},
		{
			3,
			1,
			x,
			10
		},
		{
			9,
			6,
			12,
			13
		},
		{
			9,
			7,
			3,
			5
		},
		{
			9,
			8,
			3,
			6
		},
		{
			x,
			2,
			3,
			7
		},
		{
			x,
			7,
			5,
			13
		},
		{
			12,
			4,
			4,
			11
		},
		{
			73,
			10,
			x,
			x
		},
		{
			13,
			3,
			10,
			73
		},
		{
			9,
			5,
			12,
			x
		},
		[73] = {
			13,
			12,
			11,
			x
		}
	}

	local e
	local grx = game.game_ref_origin.x
	local water_sparks = {
		V.v(25, 405),
		V.v(25, 312),
		V.v(89, 512),
		V.v(232, 540),
		V.v(290, 448),
		V.v(329, 367),
		V.v(350, 535),
		V.v(409, 698),
		V.v(477, 531),
		V.v(446, 317),
		V.v(530, 711),
		V.v(563, 332),
		V.v(576, 238),
		V.v(647, 538),
		V.v(739, 590),
		V.v(731, 188),
		V.v(771, 65),
		V.v(840, 585),
		V.v(816, 134),
		V.v(200, -2),
		V.v(151, 777),
		V.v(-46, 360),
		V.v(-121, 315)
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
	-- 	V.v(351, 343),
	-- 	V.v(245, 532),
	-- 	V.v(490, 715),
	-- 	V.v(689, 563),
	-- 	V.v(790, 183),
	-- 	V.v(572, 262),
	-- 	V.v(235, 53),
	-- 	V.v(747, 56)
	-- }

	-- for _, p in pairs(fish) do
	-- 	e = E:create_entity("decal_jumping_fish2")
	-- 	e.pos = p

	-- 	LU.queue_insert(store, e)
	-- end

	-- local waves = {
	-- 	{
	-- 		75,
	-- 		39,
	-- 		-40
	-- 	},
	-- 	{
	-- 		951,
	-- 		39,
	-- 		28
	-- 	},
	-- 	{
	-- 		866,
	-- 		132,
	-- 		84
	-- 	},
	-- 	{
	-- 		678,
	-- 		128,
	-- 		-88
	-- 	},
	-- 	{
	-- 		550,
	-- 		180,
	-- 		-168
	-- 	},
	-- 	{
	-- 		280,
	-- 		329,
	-- 		-138
	-- 	},
	-- 	{
	-- 		200,
	-- 		459,
	-- 		-125
	-- 	},
	-- 	{
	-- 		88,
	-- 		469,
	-- 		140
	-- 	},
	-- 	{
	-- 		336,
	-- 		590,
	-- 		15
	-- 	},
	-- 	{
	-- 		593,
	-- 		571,
	-- 		-2
	-- 	},
	-- 	{
	-- 		-88,
	-- 		462,
	-- 		-45
	-- 	}
	-- }

	-- for _, v in pairs(waves) do
	-- 	local x, y, r = unpack(v)

	-- 	e = E:create_entity("decal_water_wave_16")
	-- 	e.pos = V.v(x, y)
	-- 	e.render.sprites[1].r = math.pi * -1 * r / 180

	-- 	LU.queue_insert(store, e)
	-- end

	e = E:create_entity("decal_water_barricade")
	e.pos = V.v(668, 223)

	LU.queue_insert(store, e)

	self.barricade = e
	self.tentacle_pos = {
		{
			317,
			295,
			true
		},
		{
			522,
			207,
			true
		},
		{
			695,
			130,
			true
		},
		{
			60,
			437,
			false
		},
		{
			666,
			595,
			true
		},
		{
			626,
			277,
			false
		},
		{
			294,
			612,
			false
		}
	}
	self.tentacle_waves = {
		[3] = {
			{
				3,
				3
			}
		},
		[6] = {
			{
				2,
				5
			},
			{
				9,
				4
			}
		},
		[9] = {
			{
				0,
				2
			},
			{
				8,
				7
			},
			{
				20,
				6
			}
		},
		[12] = {
			{
				1,
				5
			},
			{
				5,
				1
			},
			{
				9,
				6
			}
		},
		[15] = {
			{
				1,
				2
			},
			{
				1,
				6
			},
			{
				6,
				5
			},
			{
				11,
				4
			}
		}
	}
	self.boss_head_waves = {
		[9] = {
			236,
			530,
			true
		},
		[12] = {
			236,
			530,
			true
		},
		[15] = {
			786,
			590,
			false
		}
	}
	self.boss_tentacle_seq = {
		{
			1,
			2,
			3
		},
		{
			5,
			6,
			4
		},
		{
			1,
			2,
			3
		},
		{
			6,
			2,
			5,
			7
		},
		{
			4,
			3,
			6
		},
		{
			1,
			2,
			5,
			7
		},
		{
			1,
			4,
			5,
			7
		},
		{
			1,
			2,
			4,
			5,
			7
		},
		{
			1,
			4,
			5,
			7
		},
		{
			1,
			2,
			4,
			5,
			7
		},
		{
			1,
			4,
			5,
			7
		}
	}
	self.boss_spawn_seq = {
		{
			0,
			5,
			1,
			{
				enemy_redspine = 2
			}
		},
		{
			8,
			5,
			2,
			{
				enemy_deviltide = 4
			}
		},
		{
			10,
			3,
			2,
			{
				enemy_greenfin = 10
			}
		},
		{
			30,
			5,
			3,
			{
				enemy_redspine = 2
			}
		},
		{
			40,
			3,
			3,
			{
				enemy_redspine = 2
			}
		},
		{
			46,
			5,
			1,
			{
				enemy_deviltide = 4
			}
		},
		{
			48,
			3,
			2,
			{
				enemy_redspine = 2
			}
		},
		{
			60,
			3,
			2,
			{
				enemy_deviltide = 4
			}
		},
		{
			60,
			5,
			2,
			{
				enemy_deviltide = 4
			}
		},
		{
			65,
			5,
			3,
			{
				enemy_redspine = 2
			}
		},
		{
			75,
			3,
			2,
			{
				enemy_bloodshell = 1
			}
		},
		{
			76,
			2,
			1,
			{
				enemy_greenfin = 10
			}
		},
		{
			85,
			3,
			2,
			{
				enemy_greenfin = 10
			}
		},
		{
			100,
			2,
			1,
			{
				enemy_deviltide = 4
			}
		},
		{
			100,
			5,
			2,
			{
				enemy_bloodshell = 1
			}
		},
		{
			115,
			5,
			2,
			{
				enemy_deviltide = 4
			}
		},
		{
			120,
			3,
			2,
			{
				enemy_deviltide = 4
			}
		},
		{
			140,
			3,
			1,
			{
				enemy_bluegale = 1,
				enemy_deviltide = 5
			}
		},
		{
			150,
			5,
			1,
			{
				enemy_bluegale = 1,
				enemy_deviltide = 5
			}
		},
		{
			157,
			5,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			157,
			3,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			160,
			5,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			160,
			3,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			163,
			5,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			163,
			3,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			166,
			5,
			1,
			{
				enemy_bloodshell = 1
			}
		},
		{
			166,
			3,
			1,
			{
				enemy_bloodshell = 1
			}
		}
	}
end

function level:update(store)
	LU.insert_hero(store)

	while store.wave_group_number < 1 do
		coroutine.yield()
	end

	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	else
		while not store.waves_finished do
			local wave_number = store.wave_group_number

			self:y_update_tentacles(store)

			while wave_number == store.wave_group_number and not store.waves_finished do
				coroutine.yield()
			end
		end

		while LU.has_alive_enemies(store) do
			coroutine.yield()
		end

		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 2.5, {
			x = 738,
			y = 576
		}, 2)
		signal.emit("hide-gui")
		S:queue("MusicBossPreFightEnd")
		U.y_wait(store, 1)

		local boss = E:create_entity("eb_leviathan")

		boss.nav_path.pi = 6
		boss.nav_path.spi = 1
		boss.nav_path.ni = 1
		boss.tentacle_pos = self.tentacle_pos
		boss.tentacle_seq = self.boss_tentacle_seq
		boss.spawn_seq = self.boss_spawn_seq

		LU.queue_insert(store, boss)

		self.boss = boss

		while self.boss.phase ~= "loop" do
			coroutine.yield()
		end

		S:queue("MusicBossFight2")
		U.y_wait(store, 1)
		signal.emit("hide-curtains")
		signal.emit("pan-zoom-camera", 2, {
			x = 512,
			y = 384
		}, 1)
		signal.emit("show-gui")

		local spawn_start_ts = store.tick_ts + 6
		local spawn_queue = {}

		for _, sg in pairs(self.boss_spawn_seq) do
			local delay, pi, every, enemies = unpack(sg)
			local enemy_options = {}

			for k, v in pairs(enemies) do
				for i = 1, v do
					table.insert(enemy_options, k)
				end
			end

			local total_enemies = #enemy_options

			for i = 1, total_enemies do
				local idx = math.random(1, #enemy_options)
				local e = enemy_options[idx]

				table.remove(enemy_options, idx)

				local time = delay + every * (i - 1)

				if not spawn_queue[time] then
					spawn_queue[time] = {}
				end

				table.insert(spawn_queue[time], {
					e,
					pi
				})
			end
		end

		while self.boss.phase ~= "dead" do
			local off_sec = math.floor(store.tick_ts - spawn_start_ts)

			if spawn_queue[off_sec] then
				for _, item in pairs(spawn_queue[off_sec]) do
					local name, pi = unpack(item)
					local e = E:create_entity(name)

					e.nav_path.pi = pi
					e.nav_path.spi = math.random(1, 3)
					e.nav_path.ni = P:get_start_node(pi)

					LU.queue_insert(store, e)
					log.paranoid(" SPAWN: (%04d) - %s path:%s", off_sec, name, pi)
				end

				spawn_queue[off_sec] = nil
			end

			if self.barricade and V.dist(boss.pos.x, boss.pos.y, self.barricade.pos.x, self.barricade.pos.y) < 80 then
				S:queue("RTBoatBreak")
				U.y_animation_play(self.barricade, "destroy", nil, store.tick_ts)
				LU.queue_remove(store, self.barricade)

				self.barricade = nil
			end

			if not store.entities[self.boss.id] then
				break
			end

			coroutine.yield()
		end

		U.y_wait(store, 3)
	end
end

function level:y_update_tentacles(store)
	local wave_number = store.wave_group_number
	local boss_head

	if self.boss_head_waves and self.boss_head_waves[wave_number] then
		local hw = self.boss_head_waves[wave_number]
		local e = E:create_entity("leviathan_head")

		e.pos.x, e.pos.y = hw[1], hw[2]
		e.render.sprites[1].flip_x = hw[3]

		LU.queue_insert(store, e)

		boss_head = e

		U.y_animation_play(e, "show", nil, store.tick_ts, 1)
		U.animation_start(e, "idle", nil, store.tick_ts, true)
	end

	local start_ts = store.tick_ts
	local tentacles = {}

	if self.tentacle_waves and self.tentacle_waves[wave_number] then
		for _, tw in pairs(self.tentacle_waves[wave_number]) do
			local delay = tw[1] - (store.tick_ts - start_ts)

			U.y_wait(store, delay)

			if store.waves_finished or store.wave_group_number ~= wave_number then
				for _, t in pairs(tentacles) do
					t.interrupt = true
				end

				goto label_4_1
			end

			local e = E:create_entity("leviathan_tentacle")
			local pos = self.tentacle_pos[tw[2]]

			e.pos.x, e.pos.y = pos[1], pos[2]
			e.flip = pos[3]

			LU.queue_insert(store, e)
			table.insert(tentacles, e)
		end
	end

	::label_4_0::

	coroutine.yield()

	for _, t in pairs(tentacles) do
		if store.waves_finished or store.wave_group_number ~= wave_number then
			t.interrupt = true
		elseif store.entities[t.id] then
			goto label_4_0
		end
	end

	::label_4_1::

	if boss_head then
		U.y_animation_play(boss_head, "hide", nil, store.tick_ts, 1)
		LU.queue_remove(store, boss_head)

		boss_head = nil
	end
end

return level
