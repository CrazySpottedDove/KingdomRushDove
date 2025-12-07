-- chunkname: @./kr3/data/levels/level15_data.lua
return {
	show_comic_idx = 4,
	locked_hero = false,
	level_terrain_type = 3,
	max_upgrade_level = 6,
	entities_list = {
		{
			portal_tag = 4,
			template = "aura_metropolis_portal",
			pos = {
				x = 915,
				y = 619
			}
		},
		{
			portal_tag = 1,
			template = "aura_metropolis_portal",
			pos = {
				x = 230,
				y = 628
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 42,
			pos = {
				x = 992,
				y = 261
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 52,
			pos = {
				x = 321,
				y = 351
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 62,
			pos = {
				x = 360,
				y = 396
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 62,
			pos = {
				x = 439,
				y = 396
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 42,
			pos = {
				x = 625,
				y = 456
			}
		},
		{
			template = "aura_spider_sprint",
			["aura.radius"] = 42,
			pos = {
				x = 612,
				y = 502
			}
		},
		{
			template = "background_sounds",
			sounds = {"MetropolisAmbienceSoundFourteenFifteen"}
		},
		{
			template = "birds_formation_controller",
			time = 4.5,
			from = {
				x = -222,
				y = 254
			},
			names = {"decal_bird_duck"},
			offsets = {{
				x = 0,
				y = 0
			}},
			to = {
				x = 449,
				y = 825
			}
		},
		{
			template = "birds_formation_controller",
			time = 5,
			from = {
				x = 633,
				y = -61
			},
			names = {"decal_bird_red", "decal_bird_red", "decal_bird_red"},
			offsets = {{
				x = 0,
				y = 0
			}, {
				x = -14,
				y = -22
			}, {
				x = -31,
				y = -44
			}},
			to = {
				x = 1479,
				y = 738
			}
		},
		{
			template = "birds_formation_controller",
			time = 4.5,
			from = {
				x = 357,
				y = -65
			},
			names = {"decal_bird_duck"},
			offsets = {{
				x = 0,
				y = 0
			}},
			to = {
				x = -222,
				y = 520
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 539,
				y = 241
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 765,
				y = 408
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 414,
				y = 472
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0002",
			pos = {
				x = 728,
				y = 16
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0003",
			pos = {
				x = 659,
				y = 27
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0006",
			pos = {
				x = 740,
				y = 43
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0001",
			pos = {
				x = 461,
				y = 160
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0005",
			pos = {
				x = 40,
				y = 313
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage15_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage15_elements_0004",
			pos = {
				x = 76,
				y = 403
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.275
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 398,
				y = 77
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 566,
				y = 77
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 338,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 461,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 513,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 625,
				y = 53
			}
		},
		{
			["render.sprites[1].sort_y"] = 320,
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 3100,
			["render.sprites[1].name"] = "Stage15_0013",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0012",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage15_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0016",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0014",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = -1,
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0017",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0013",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0015",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0012",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage15_floatingStones_0004",
			pos = {
				x = 512,
				y = 385
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 3,
			detection_paths = {2, 9, 4, 11},
			detection_tags = {3, 1, 4},
			pos = {
				x = 428,
				y = 265
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 6,
			detection_paths = {6, 13},
			detection_tags = {6, 4},
			pos = {
				x = 945,
				y = 483
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 2,
			detection_paths = {1, 3, 8, 10},
			detection_tags = {2, 1},
			pos = {
				x = 157,
				y = 503
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 5,
			detection_paths = {5, 7, 12, 14},
			detection_tags = {5, 4},
			pos = {
				x = 734,
				y = 516
			}
		},
		{
			["editor.tag"] = 4,
			template = "decal_metropolis_portal",
			detection_tags = {4},
			pos = {
				x = 915,
				y = 619
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_metropolis_portal",
			detection_tags = {1},
			pos = {
				x = 230,
				y = 628
			}
		},
		{
			template = "decal_s15_finished_gem",
			["editor.game_mode"] = 2,
			pos = {
				x = 546,
				y = 664
			}
		},
		{
			template = "decal_s15_finished_gem",
			["editor.game_mode"] = 3,
			pos = {
				x = 546,
				y = 664
			}
		},
		{
			template = "decal_s15_finished_guard",
			["editor.game_mode"] = 2,
			pos = {
				x = 611,
				y = 642
			}
		},
		{
			template = "decal_s15_finished_guard",
			["editor.game_mode"] = 3,
			pos = {
				x = 611,
				y = 642
			}
		},
		{
			template = "decal_s15_finished_guard_flipped",
			["editor.game_mode"] = 2,
			pos = {
				x = 483,
				y = 642
			}
		},
		{
			template = "decal_s15_finished_guard_flipped",
			["editor.game_mode"] = 3,
			pos = {
				x = 483,
				y = 642
			}
		},
		{
			template = "decal_s15_finished_veznan",
			["editor.game_mode"] = 2,
			pos = {
				x = 581,
				y = 686
			}
		},
		{
			template = "decal_s15_finished_veznan",
			["editor.game_mode"] = 3,
			pos = {
				x = 581,
				y = 686
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 323,
				y = 690
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 726,
				y = 690
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 786,
				y = 690
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 291,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 356,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 696,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 756,
				y = 720
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
			load_file = "level63_mactans"
		},
		{
			template = "mega_spawner",
			load_file = "level63_spawner"
		},
		{
			["tower.holder_id"] = "1",
			template = "tower_drow",
			["editor.game_mode"] = 0,
			["tower.terrain_style"] = 3,
			["barrack.rally_pos"] = {
				x = 268,
				y = 171
			},
			pos = {
				x = 268,
				y = 234
			},
			["tower.default_rally_pos"] = {
				x = 268,
				y = 171
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_drow",
			["editor.game_mode"] = 3,
			pos = {
				x = 646,
				y = 263
			},
			["tower.default_rally_pos"] = {
				x = 640,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 479,
				y = 115
			},
			["tower.default_rally_pos"] = {
				x = 565,
				y = 117
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 661,
				y = 115
			},
			["tower.default_rally_pos"] = {
				x = 697,
				y = 196
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 379,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 374,
				y = 120
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 801,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 784,
				y = 142
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 168,
				y = 220
			},
			["tower.default_rally_pos"] = {
				x = 165,
				y = 168
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 859,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 899,
				y = 184
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 2,
			pos = {
				x = 646,
				y = 263
			},
			["tower.default_rally_pos"] = {
				x = 640,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 1,
			pos = {
				x = 646,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 640,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 416,
				y = 314
			},
			["tower.default_rally_pos"] = {
				x = 502,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 155,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 158,
				y = 307
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 559,
				y = 381
			},
			["tower.default_rally_pos"] = {
				x = 563,
				y = 332
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 242,
				y = 387
			},
			["tower.default_rally_pos"] = {
				x = 242,
				y = 329
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 928,
				y = 387
			},
			["tower.default_rally_pos"] = {
				x = 899,
				y = 318
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 656,
				y = 398
			},
			["tower.default_rally_pos"] = {
				x = 657,
				y = 348
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		locked_towers = {"tower_build_archer", "tower_build_engineer"}
	}},
	unlock_towers = {"tower_drow"},
	nav_mesh = {
		{11, 2, 8},
		{14, nil, 3, 1},
		{2, nil, nil, 8},
		{7, nil, 5, 13},
		{4, nil, 14, 13},
		{7, 7, 13, 10},
		{nil, nil, 4, 6},
		{1, 3},
		{10, 13, 12},
		{6, 6, 13, 9},
		{12, 14, 1, 12},
		{9, 11, 11},
		{10, 4, 12, 9},
		{5, nil, 2, 11}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage63",
		"MetropolisAmbienceSounds",
		"ElvesCrystalPlant",
		"ElvesCreepArachnomancerSpiderSpawn",
		"ElvesCreepAvenger",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesCreepRazorboar",
		"ElvesCreepSonOfMactans",
		"ElvesScourger",
		"ElvesFinalBoss",
		"ElvesMalicia",
		"ElvesLevelFourteen",
		"ElvesLevelFifteenSounds"
	},
	required_textures = {"go_enemies_ancient_metropolis", "go_enemies_mactans_malicia", "go_stage63", "go_stage63_bg", "go_stages_ancient_metropolis"}
}
