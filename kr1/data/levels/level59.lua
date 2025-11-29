-- chunkname: @./kr3/data/levels/level11.lua

local log = require("lib.klua.log"):new("level11")
local signal = require("hump.signal")
local km = require("lib.klua.macros")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local GS = require("game_settings")

require("constants")

local function fts(v)
	return v / FPS
end

local v = V.v
local level = {}

function level:load(store)
	P:add_invalid_range(10, nil, nil, bit.bor(NF_RALLY, NF_POWER_1, NF_POWER_2, NF_POWER_3))

	self.portal_packs = {
		[0] = {
			{
				"enemy_satyr_cutthroat",
				20,
				1,
				0
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				1
			},
			{
				"enemy_satyr_cutthroat",
				20,
				1,
				2
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				0
			}
		},
		{
			{
				"enemy_satyr_hoplite",
				20,
				1,
				0
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				2
			},
			{
				"enemy_satyr_cutthroat",
				20,
				1,
				1
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				2
			},
			{
				"enemy_satyr_cutthroat",
				20,
				1,
				1
			}
		},
		{
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				2
			},
			{
				"enemy_twilight_elf_harasser",
				20,
				1,
				1
			},
			{
				"enemy_twilight_scourger",
				0,
				1,
				0
			}
		},
		{
			{
				"enemy_twilight_scourger",
				20,
				1,
				0
			},
			{
				"enemy_twilight_scourger",
				0,
				1,
				1
			},
			{
				"enemy_twilight_scourger",
				0,
				1,
				2
			}
		},
		{
			{
				"enemy_twilight_avenger",
				30,
				1,
				0
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				1
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				2
			}
		},
		{
			{
				"enemy_twilight_scourger",
				20,
				1,
				0
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				1
			},
			{
				"enemy_twilight_elf_harasser",
				20,
				1,
				2
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				1
			},
			{
				"enemy_twilight_elf_harasser",
				20,
				1,
				2
			}
		},
		{
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				1
			},
			{
				"enemy_satyr_cutthroat",
				50,
				1,
				2
			},
			{
				"enemy_twilight_scourger",
				0,
				1,
				1
			},
			{
				"enemy_twilight_scourger",
				50,
				1,
				2
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				0
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				1
			},
			{
				"enemy_satyr_cutthroat",
				50,
				1,
				2
			},
			{
				"enemy_satyr_cutthroat",
				0,
				1,
				1
			},
			{
				"enemy_satyr_cutthroat",
				50,
				1,
				2
			}
		},
		{
			{
				"enemy_twilight_scourger",
				50,
				1,
				0
			},
			{
				"enemy_twilight_avenger",
				50,
				2,
				1
			},
			{
				"enemy_twilight_avenger",
				50,
				0,
				2
			},
			{
				"enemy_twilight_avenger",
				0,
				1,
				1
			}
		},
		{
			{
				"enemy_twilight_avenger",
				0,
				1,
				1
			},
			{
				"enemy_twilight_avenger",
				70,
				1,
				2
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				2,
				1
			},
			{
				"enemy_twilight_elf_harasser",
				70,
				0,
				2
			},
			{
				"enemy_twilight_scourger",
				0,
				1,
				1
			},
			{
				"enemy_twilight_scourger",
				70,
				1,
				2
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				1
			},
			{
				"enemy_twilight_elf_harasser",
				70,
				1,
				2
			},
			{
				"enemy_twilight_elf_harasser",
				0,
				1,
				0
			}
		}
	}
	self.summoner_config = {
		[0] = {
			portal_idx = 1,
			summoner_pi = 8,
			spawn_pi = 5
		},
		{
			portal_idx = 2,
			summoner_pi = 9,
			spawn_pi = 2
		}
	}
	self.boss_waves = {
		[2] = {
			{
				"taunt",
				fts(20)
			}
		},
		[3] = {
			{
				"summoner",
				fts(10),
				0,
				0,
				150
			},
			{
				"summoner",
				fts(500),
				0,
				0,
				150
			},
			{
				"summoner",
				fts(1000),
				0,
				0,
				150
			}
		},
		[5] = {
			{
				"summoner",
				fts(50),
				1,
				1,
				180
			},
			{
				"summoner",
				fts(650),
				1,
				1,
				180
			},
			{
				"summoner",
				fts(1150),
				1,
				1,
				180
			}
		},
		[6] = {
			{
				"powers",
				fts(50),
				1800,
				4,
				5,
				{
					0,
					1
				},
				13
			}
		},
		[8] = {
			{
				"summoner",
				fts(80),
				2,
				0,
				200
			},
			{
				"summoner",
				fts(300),
				2,
				1,
				200
			},
			{
				"summoner",
				fts(700),
				2,
				0,
				200
			},
			{
				"summoner",
				fts(950),
				2,
				1,
				200
			}
		},
		[9] = {
			{
				"powers",
				fts(150),
				3000,
				4,
				5,
				{
					1,
					0
				},
				11
			},
			{
				"powers",
				fts(1250),
				3000,
				3,
				4,
				{
					0.25,
					0.75
				},
				18
			}
		},
		[11] = {
			{
				"summoner",
				fts(20),
				3,
				0,
				250
			},
			{
				"summoner",
				fts(420),
				4,
				1,
				250
			},
			{
				"summoner",
				fts(1000),
				3,
				0,
				250
			},
			{
				"summoner",
				fts(1000),
				4,
				1,
				250
			}
		},
		[12] = {
			{
				"powers",
				fts(10),
				4200,
				4,
				5,
				{
					0.3,
					0.7
				},
				20
			},
			{
				"powers",
				fts(950),
				4200,
				3,
				4,
				{
					0.3,
					0.7
				},
				18
			}
		},

		[15] = {
			{
				"summoner",
				fts(20),
				5,
				0,
				250
			},
			{
				"summoner",
				fts(20),
				5,
				1,
				250
			},
			{
				"powers",
				fts(250),
				5400,
				3,
				4,
				{
					0.3,
					0.7
				},
				18
			},
			{
				"powers",
				fts(850),
				5400,
				3,
				4,
				{
					0.3,
					0.7
				},
				18
			},
			{
				"summoner",
				fts(1050),
				5,
				0,
				250
			},
			{
				"summoner",
				fts(1050),
				5,
				1,
				250
			},
			{
				"fight",
				fts(2300)
                -- 0
			},
			{
				"summoner",
				fts(6000),
				5,
				1,
				300
			},
			{
				"summoner",
				fts(6000),
				5,
				0,
				300
			}
		}
	}
	self.boss_fight_rounds = {
		{
			6000,
			4,
			5,
			{
				0.3,
				0.7
			},
			20,
			{
				6,
				6
			},
			{
				4,
				2,
				4
			},
			2,
			3
		},
		{
			6000,
			3,
			4,
			{
				0,
				1
			},
			20,
			{
				7,
				7
			},
			{
				5,
				3,
				5
			},
			5,
			3
		},
		{
			8400,
			2,
			3,
			{
				0,
				1
			},
			12,
			{
				7,
				7,
				7
			},
			{
				5,
				3,
				2
			},
			2,
			3
		}
	}
end

function level:update(store)
	self.portals = LU.list_entities(store.entities, "decal_drow_queen_portal")

	table.sort(self.portals, function(e1, e2)
		return tonumber(e1.editor.tag) < tonumber(e2.editor.tag)
	end)

	self.door_glows = LU.list_entities(store.entities, "decal_s11_door_glow")

	table.sort(self.door_glows, function(e1, e2)
		return tonumber(e1.editor.tag) < tonumber(e2.editor.tag)
	end)

	self.runes = LU.list_entities(store.entities, "decal_s11_zealot_rune")

	table.sort(self.runes, function(e1, e2)
		return tonumber(e1.editor.tag) < tonumber(e2.editor.tag)
	end)

	self.megaspawner = LU.list_entities(store.entities, "mega_spawner")[1]

	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		while not store.waves_finished or LU.has_alive_enemies(store) do
			coroutine.yield()
		end
	else
		local boss = E:create_entity("eb_drow_queen")

		boss.path_id_throne = 10
		boss.pos = V.vclone(boss.pos_sitting)
		boss.portals = self.portals
		boss.portal_packs = self.portal_packs
		boss.megaspawner = self.megaspawner
		boss.fight_rounds = self.boss_fight_rounds
		boss.phase_signal = nil
		boss.cast_pi = 10
		self.boss = boss

		LU.queue_insert(store, boss)
		coroutine.yield()

		if not store.restarted then
			signal.emit("show-curtains")
			signal.emit("pan-zoom-camera", 2, {
				x = 1000,
				y = 400
			}, 2)
			signal.emit("hide-gui")
		end

		U.y_wait(store, 1)

		boss.phase_signal = "welcome"
		boss.phase_params = 0

		while self.boss.phase ~= "prebattle" do
			coroutine.yield()
		end

		if not store.restarted then
			signal.emit("hide-curtains")
			signal.emit("pan-zoom-camera", 2, {
				x = 512,
				y = 384
			}, 1)
			signal.emit("show-gui")
		end

		while store.wave_group_number < 1 do
			coroutine.yield()
		end

		self.boss.phase_signal = "sitting"

		while self.boss.phase ~= "mactans" do
			self:y_boss_wave(store, store.wave_group_number)
			coroutine.yield()
		end

		signal.emit("show-curtains")
		signal.emit("pan-zoom-camera", 2, {
			x = 680,
			y = 400
		}, 2)
		signal.emit("hide-gui", true)

		while self.boss.phase ~= "dead" do
			coroutine.yield()
		end

		signal.emit("hide-curtains")
		signal.emit("pan-zoom-camera", 2, {
			x = 512,
			y = 384
		}, 1)
		U.y_wait(store, 2.5)
	end
end

function level:y_boss_wave(store, wave_number)
	local groups = self.boss_waves[wave_number]

	if not groups then
		return
	end

	local start_ts, last_ts = store.tick_ts, store.tick_ts

	for _, group in pairs(groups) do
		local t_elapsed = store.tick_ts - start_ts
		local t_total = group[2]
		local t_actual = km.clamp(0, t_total, t_total - t_elapsed)

		log.debug("wave_number:%s waiting:%s type:%s", wave_number, t_actual, group[1])

		if U.y_wait(store, t_actual, function(store, time)
			return store.wave_group_number ~= wave_number or self.boss.health.dead
		end) then
			return
		end

		if group[1] == "summoner" then
			local _, __, pack_idx, conf_idx, hp = unpack(group)
			local cfg = self.summoner_config[conf_idx]

			hp = 10 * math.ceil(hp * GS.difficulty_enemy_hp_max_factor[store.level_difficulty] / 10)

			local zealots = table.filter(store.entities, function(_, e)
				return e.template_name == "enemy_zealot" and e.nav_path.pi == cfg.summoner_pi and not e.is_summoning
			end)

			for _, e in pairs(zealots) do
				log.debug("killing idle zealot: %s", e.id)

				e.health.hp = 0
			end

			local door_glow = self.door_glows[cfg.portal_idx]

			if door_glow then
				door_glow.tween.disabled = false
				door_glow.tween.ts = store.tick_ts
			end

			self.boss.phase_signal = "summoner"

			local e = E:create_entity("enemy_zealot")

			e.nav_path.pi = cfg.summoner_pi
			e.health.hp = hp
			e.health.hp_max = hp
			e.portal_pack = {
				pi = cfg.spawn_pi,
				waves = self.portal_packs[pack_idx]
			}
			e.portal = self.portals[cfg.portal_idx]
			e.rune = self.runes[cfg.portal_idx]

			LU.queue_insert(store, e)
		else
			self.boss.phase_signal = group[1]
			self.boss.phase_params = group
		end

		if store.wave_group_number ~= wave_number or self.boss.health.dead then
			return
		end
	end

	while store.wave_group_number == wave_number and not self.boss.health.dead do
		coroutine.yield()
	end
end

return level
