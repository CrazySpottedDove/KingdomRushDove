﻿-- chunkname: @./kr3/data/levels/level13_data.lua

return {
	locked_hero = false,
	level_terrain_type = 3,
	max_upgrade_level = 5,
	entities_list = {
		{
			portal_tag = 32,
			template = "aura_metropolis_portal",
			pos = {
				x = 736,
				y = 185
			}
		},
		{
			portal_tag = 22,
			template = "aura_metropolis_portal",
			pos = {
				x = 801,
				y = 319
			}
		},
		{
			portal_tag = 12,
			template = "aura_metropolis_portal",
			pos = {
				x = 890,
				y = 516
			}
		},
		{
			portal_tag = 42,
			template = "aura_metropolis_portal",
			pos = {
				x = 725,
				y = 532
			}
		},
		{
			template = "background_sounds",
			sounds = {
				"MetropolisAmbienceSound"
			}
		},
		{
			template = "birds_formation_controller",
			time = 3.5,
			from = {
				x = 1217,
				y = 351
			},
			names = {
				"decal_bird_duck",
				"decal_bird_duck",
				"decal_bird_duck",
				"decal_bird_duck",
				"decal_bird_duck"
			},
			offsets = {
				{
					x = 0,
					y = 0
				},
				{
					x = 19,
					y = 1
				},
				{
					x = 38,
					y = 4
				},
				{
					x = 9,
					y = -17
				},
				{
					x = 19,
					y = -34
				}
			},
			to = {
				x = 573,
				y = 856
			}
		},
		{
			template = "birds_formation_controller",
			time = 4,
			from = {
				x = 797,
				y = -73
			},
			names = {
				"decal_bird_duck"
			},
			offsets = {
				{
					x = 0,
					y = 0
				}
			},
			to = {
				x = -200,
				y = 768
			}
		},
		{
			template = "birds_formation_controller",
			time = 3,
			from = {
				x = 474,
				y = -69
			},
			names = {
				"decal_bird_red",
				"decal_bird_red"
			},
			offsets = {
				{
					x = 0,
					y = 0
				},
				{
					x = 0,
					y = -30
				}
			},
			to = {
				x = 1234,
				y = 589
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 494,
				y = 203
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 499,
				y = 513
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage13_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 660,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage13_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 470,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage13_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 373,
				y = 77
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 370
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 292,
				y = 51
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 439,
				y = 51
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 22,
				y = 307
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 22,
				y = 424
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0013",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0022",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0020",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0019",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0024",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0023",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0027",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0018",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0021",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0028",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0026",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0016",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0025",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0014",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0015",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0017",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0030",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0012",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage13_0029",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.tag"] = 51,
			template = "decal_metropolis_portal",
			detection_tags = {
				51,
				42
			},
			pos = {
				x = 631,
				y = 114
			}
		},
		{
			["editor.tag"] = 71,
			template = "decal_metropolis_portal",
			detection_tags = {
				71,
				32
			},
			pos = {
				x = 120,
				y = 143
			}
		},
		{
			["editor.tag"] = 32,
			template = "decal_metropolis_portal",
			detection_tags = {
				32
			},
			pos = {
				x = 736,
				y = 185
			}
		},
		{
			["editor.tag"] = 22,
			template = "decal_metropolis_portal",
			detection_tags = {
				22
			},
			pos = {
				x = 801,
				y = 319
			}
		},
		{
			["editor.tag"] = 61,
			template = "decal_metropolis_portal",
			detection_tags = {
				61,
				22
			},
			pos = {
				x = 466,
				y = 389
			}
		},
		{
			["editor.tag"] = 12,
			template = "decal_metropolis_portal",
			detection_tags = {
				12
			},
			pos = {
				x = 890,
				y = 516
			}
		},
		{
			["editor.tag"] = 42,
			template = "decal_metropolis_portal",
			detection_tags = {
				42
			},
			pos = {
				x = 725,
				y = 532
			}
		},
		{
			["editor.tag"] = 41,
			template = "decal_metropolis_portal",
			detection_tags = {
				41,
				12
			},
			pos = {
				x = 240,
				y = 573
			}
		},
		{
			template = "decal_s13_relic_book",
			pos = {
				x = 741,
				y = 381
			}
		},
		{
			template = "decal_s13_relic_broom",
			pos = {
				x = 14,
				y = 219
			}
		},
		{
			template = "decal_s13_relic_hat",
			pos = {
				x = 174,
				y = 590
			}
		},
		{
			template = "decal_static",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage13_over2",
			pos = {
				x = 91,
				y = 240
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17142857142857143
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].sort_y"] = 475,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage13_ironHeroicDecals_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 425,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage13_ironHeroicDecals_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.r"] = -0.34906585039887,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 260,
			pos = {
				x = 978,
				y = 231
			}
		},
		{
			["editor.r"] = -0.34906585039887,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 260,
			pos = {
				x = 978,
				y = 277
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 978,
				y = 517
			}
		},
		{
			template = "mega_spawner",
			load_file = "level61_spawner"
		},
		{
			["tower.holder_id"] = "14",
			template = "tower_barrack_1",
			["editor.game_mode"] = 0,
			["tower.terrain_style"] = 3,
			["barrack.rally_pos"] = {
				x = 565,
				y = 570
			},
			pos = {
				x = 565,
				y = 621
			},
			["tower.default_rally_pos"] = {
				x = 565,
				y = 570
			}
		},
		{
			["tower.holder_id"] = "25",
			template = "tower_black_baby_dragon",
			["editor.game_mode"] = 1,
			pos = {
				x = 790,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 840,
				y = 475
			}
		},
		{
			["tower.holder_id"] = "25",
			template = "tower_black_baby_dragon",
			["editor.game_mode"] = 3,
			pos = {
				x = 790,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 840,
				y = 475
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 304,
				y = 116
			},
			["tower.default_rally_pos"] = {
				x = 385,
				y = 86
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 868,
				y = 152
			},
			["tower.default_rally_pos"] = {
				x = 862,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 395,
				y = 175
			},
			["tower.default_rally_pos"] = {
				x = 453,
				y = 131
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 202,
				y = 236
			},
			["tower.default_rally_pos"] = {
				x = 210,
				y = 329
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 732,
				y = 252
			},
			["tower.default_rally_pos"] = {
				x = 811,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 915,
				y = 294
			},
			["tower.default_rally_pos"] = {
				x = 929,
				y = 248
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 400,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 396,
				y = 264
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 286,
				y = 370
			},
			["tower.default_rally_pos"] = {
				x = 272,
				y = 301
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 141,
				y = 398
			},
			["tower.default_rally_pos"] = {
				x = 135,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 331,
				y = 499
			},
			["tower.default_rally_pos"] = {
				x = 346,
				y = 589
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 689,
				y = 589
			},
			["tower.default_rally_pos"] = {
				x = 631,
				y = 556
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 418,
				y = 624
			},
			["tower.default_rally_pos"] = {
				x = 428,
				y = 565
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_baby_ashbite",
			["editor.game_mode"] = 1,
			pos = {
				x = 615,
				y = 382
			},
			["tower.default_rally_pos"] = {
				x = 615,
				y = 382
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_baby_ashbite",
			["editor.game_mode"] = 2,
			pos = {
				x = 615,
				y = 382
			},
			["tower.default_rally_pos"] = {
				x = 615,
				y = 382
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{
			locked_towers = {
				"tower_build_archer",
				"tower_build_engineer"
			}
		}
	},
    unlock_towers = {"tower_baby_ashbite"},
	nav_mesh = {
		{
			5,
			12,
			nil,
			10
		},
		{
			25,
			nil,
			7,
			14
		},
		{
			4,
			14,
			8,
			6
		},
		{
			nil,
			25,
			3,
			6
		},
		{
			9,
			12,
			1,
			10
		},
		{
			4,
			4,
			3
		},
		{
			2,
			nil,
			12,
			12
		},
		{
			3,
			9,
			13,
			13
		},
		{
			14,
			12,
			5,
			8
		},
		{
			9,
			5,
			1,
			13
		},
		[12] = {
			14,
			7,
			1,
			5
		},
		[13] = {
			8,
			10,
			10
		},
		[14] = {
			25,
			2,
			9,
			3
		},
		[25] = {
			nil,
			2,
			14,
			4
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage61",
		"MetropolisAmbienceSounds",
		"ElvesLevelThirteen",
		"ElvesCrystalPlant",
		"ElvesCreepArachnomancerSpiderSpawn",
		"ElvesCreepAvenger",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesCreepRazorboar",
		"ElvesCreepSonOfMactans",
		"ElvesScourger"
	},
	required_textures = {
		"go_enemies_ancient_metropolis",
		"go_stage61",
		"go_stage61_bg",
		"go_stages_ancient_metropolis"
	}
}
