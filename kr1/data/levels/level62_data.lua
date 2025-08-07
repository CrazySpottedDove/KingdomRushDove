﻿-- chunkname: @./kr3/data/levels/level14_data.lua

return {
	locked_hero = false,
	level_terrain_type = 3,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "aura_metropolis_portal",
			pos = {
				x = 839,
				y = 619
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 23,
			pos = {
				x = 861,
				y = 179
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 23,
			pos = {
				x = 861,
				y = 205
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 23,
			pos = {
				x = 877,
				y = 219
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 65,
			pos = {
				x = 506,
				y = 369
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 62,
			pos = {
				x = 501,
				y = 433
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 42,
			pos = {
				x = 741,
				y = 458
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 42,
			pos = {
				x = 718,
				y = 466
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 50,
			pos = {
				x = 208,
				y = 576
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 29,
			pos = {
				x = 765,
				y = 596
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 54,
			pos = {
				x = 258,
				y = 609
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 29,
			pos = {
				x = 765,
				y = 627
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 52,
			pos = {
				x = 566,
				y = 635
			}
		},
		{
			template = "background_sounds",
			sounds = {
				"MetropolisAmbienceSoundFourteenFifteen"
			}
		},
		{
			template = "birds_formation_controller",
			time = 4,
			from = {
				x = 1230,
				y = 244
			},
			names = {
				"decal_bird_red"
			},
			offsets = {
				{
					x = 0,
					y = 0
				}
			},
			to = {
				x = 547,
				y = 831
			}
		},
		{
			template = "birds_formation_controller",
			time = 4.5,
			from = {
				x = 679,
				y = -70
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
					x = -19,
					y = 1
				},
				{
					x = -38,
					y = 4
				},
				{
					x = -9,
					y = -17
				},
				{
					x = -19,
					y = -34
				}
			},
			to = {
				x = 1257,
				y = 532
			}
		},
		{
			template = "birds_formation_controller",
			time = 4.5,
			from = {
				x = -211,
				y = 315
			},
			names = {
				"decal_bird_red"
			},
			offsets = {
				{
					x = 0,
					y = 0
				}
			},
			to = {
				x = 339,
				y = 831
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 311,
				y = 144
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 709,
				y = 323
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 332,
				y = 413
			}
		},
		{
			["render.sprites[1].sort_y"] = 650,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage14_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage14_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 373,
				y = 76
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 607,
				y = 76
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 299,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 444,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 551,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 656,
				y = 53
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0014",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0013",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0015",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage14_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_floatingStones_0012",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.tag"] = 81,
			template = "decal_metropolis_portal",
			detection_tags = {
				81,
				42
			},
			pos = {
				x = 105,
				y = 232
			}
		},
		{
			["editor.tag"] = 42,
			template = "decal_metropolis_portal",
			detection_tags = {
				42
			},
			pos = {
				x = 839,
				y = 617
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 863,
				y = 80
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 863,
				y = 80
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 877,
				y = 85
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 264,
				y = 122
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 248,
				y = 127
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 582,
				y = 162
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 585,
				y = 180
			}
		},
		{
			template = "decal_s14_break_egg",
			pos = {
				x = 528,
				y = 202
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			pi = 7,
			template = "decal_s14_break_egg",
			pos = {
				x = 1000,
				y = 622
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			pi = 7,
			template = "decal_s14_break_egg",
			pos = {
				x = 971,
				y = 625
			}
		},
		{
			["editor.r"] = 0.52359877559837,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 290,
			pos = {
				x = 978,
				y = 486
			}
		},
		{
			["editor.r"] = 0.52359877559837,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 290,
			pos = {
				x = 978,
				y = 533
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 1,
			pos = {
				x = 566,
				y = 636
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 1,
			pos = {
				x = 309,
				y = 645
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 1,
			pos = {
				x = 526,
				y = 658
			}
		},
		{
			["editor.r"] = 2.792526803191,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 1,
			pos = {
				x = 603,
				y = 664
			}
		},
		{
			["editor.r"] = 2.792526803191,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 1,
			pos = {
				x = 563,
				y = 687
			}
		},
		{
			template = "enemy_mactans",
			idle_pos = {
				x = 0,
				y = 780
			},
			pos = {
				x = 0,
				y = 780
			}
		},
		{
			template = "mactans_controller",
			load_file = "level62_mactans"
		},
		{
			template = "mega_spawner",
			load_file = "level62_spawner"
		},
		{
			["spawner.name"] = "egg5",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 4,
			pos = {
				x = 139,
				y = 279
			},
			["spawner.forced_waypoint"] = {
				x = 197,
				y = 258
			}
		},
		{
			["spawner.name"] = "egg4",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 4,
			pos = {
				x = 113,
				y = 284
			},
			["spawner.forced_waypoint"] = {
				x = 173,
				y = 265
			}
		},
		{
			["spawner.name"] = "egg6",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 4,
			pos = {
				x = 136,
				y = 294
			},
			["spawner.forced_waypoint"] = {
				x = 203,
				y = 273
			}
		},
		{
			["spawner.name"] = "egg8",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 5,
			pos = {
				x = 675,
				y = 399
			},
			["spawner.forced_waypoint"] = {
				x = 714,
				y = 448
			}
		},
		{
			["spawner.name"] = "egg7",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 3,
			pos = {
				x = 675,
				y = 415
			},
			["spawner.forced_waypoint"] = {
				x = 624,
				y = 473
			}
		},
		{
			["spawner.name"] = "egg0",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 2,
			pos = {
				x = 421,
				y = 454
			},
			["spawner.forced_waypoint"] = {
				x = 450,
				y = 419
			}
		},
		{
			["spawner.name"] = "egg2",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 3,
			pos = {
				x = 443,
				y = 459
			},
			["spawner.forced_waypoint"] = {
				x = 470,
				y = 413
			}
		},
		{
			["spawner.name"] = "egg1",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 2,
			pos = {
				x = 427,
				y = 470
			},
			["spawner.forced_waypoint"] = {
				x = 451,
				y = 419
			}
		},
		{
			["spawner.name"] = "egg3",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 3,
			pos = {
				x = 454,
				y = 470
			},
			["spawner.forced_waypoint"] = {
				x = 470,
				y = 432
			}
		},
		{
			["spawner.name"] = "egg9",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 1,
			pos = {
				x = 80,
				y = 560
			},
			["spawner.forced_waypoint"] = {
				x = 97,
				y = 522
			}
		},
		{
			["spawner.name"] = "egg10",
			template = "spider_arachnomancer_egg_spawner",
			["spawner.pi"] = 1,
			pos = {
				x = 96,
				y = 569
			},
			["spawner.forced_waypoint"] = {
				x = 116,
				y = 541
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 645,
				y = 171
			},
			["tower.default_rally_pos"] = {
				x = 648,
				y = 116
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 741,
				y = 174
			},
			["tower.default_rally_pos"] = {
				x = 745,
				y = 130
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 465,
				y = 208
			},
			["tower.default_rally_pos"] = {
				x = 383,
				y = 168
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 275,
				y = 209
			},
			["tower.default_rally_pos"] = {
				x = 368,
				y = 219
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 547,
				y = 258
			},
			["tower.default_rally_pos"] = {
				x = 525,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 877,
				y = 272
			},
			["tower.default_rally_pos"] = {
				x = 776,
				y = 264
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 191,
				y = 323
			},
			["tower.default_rally_pos"] = {
				x = 282,
				y = 304
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 381,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 354,
				y = 277
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 741,
				y = 374
			},
			["tower.default_rally_pos"] = {
				x = 798,
				y = 325
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 909,
				y = 387
			},
			["tower.default_rally_pos"] = {
				x = 824,
				y = 397
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 597,
				y = 394
			},
			["tower.default_rally_pos"] = {
				x = 588,
				y = 330
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 196,
				y = 459
			},
			["tower.default_rally_pos"] = {
				x = 190,
				y = 417
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 761,
				y = 511
			},
			["tower.default_rally_pos"] = {
				x = 757,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 582,
				y = 526
			},
			["tower.default_rally_pos"] = {
				x = 616,
				y = 485
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{
			locked_towers = {
				"tower_build_barrack",
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			nil,
			2,
			14,
			15
		},
		{
			1,
			nil,
			7,
			14
		},
		{
			4,
			14,
			6
		},
		{
			15,
			14,
			3
		},
		{
			6,
			13,
			10
		},
		{
			3,
			12,
			5
		},
		{
			2,
			nil,
			8,
			12
		},
		{
			7,
			nil,
			nil,
			9
		},
		{
			13,
			8,
			nil,
			10
		},
		{
			5,
			9
		},
		[12] = {
			14,
			7,
			13,
			6
		},
		[13] = {
			12,
			8,
			9,
			5
		},
		[14] = {
			1,
			2,
			12,
			4
		},
		[15] = {
			nil,
			1,
			4,
			4
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage62",
		"MetropolisAmbienceSounds",
		"ElvesCrystalPlant",
		"ElvesCreepArachnomancerSpiderSpawn",
		"ElvesCreepAvenger",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesCreepRazorboar",
		"ElvesCreepSonOfMactans",
		"ElvesScourger",
		"ElvesMalicia",
		"ElvesLevelFourteen"
	},
	required_textures = {
		"go_enemies_ancient_metropolis",
		"go_enemies_mactans_malicia",
		"go_stage62",
		"go_stage62_bg",
		"go_stages_ancient_metropolis"
	}
}
