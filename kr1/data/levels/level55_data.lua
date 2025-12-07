-- chunkname: @./kr3/data/levels/level07_data.lua
return {
	show_comic_idx = 2,
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {"FaerieGroveAmbienceSound"}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage07_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 37,
				y = 223
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 30,
				y = 153
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 30,
				y = 271
			}
		},
		{
			template = "decal_obelix",
			pos = {
				x = 149,
				y = 570
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 804,
				y = 67
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 261,
				y = 76
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 81,
				y = 147
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 979,
				y = 377
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 955,
				y = 518
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 281,
				y = 537
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 148,
				y = 596
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 967,
				y = 625
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 49,
				y = 665
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 659,
				y = 724
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 798,
				y = 737
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 523,
				y = 728
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 711,
				y = 62
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 165,
				y = 96
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 169,
				y = 139
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 30,
				y = 365
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 188,
				y = 625
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 740,
				y = 669
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 641,
				y = 681
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 223,
				y = 707
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 576,
				y = 63
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 875,
				y = 94
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 35,
				y = 102
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 160,
				y = 492
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 43,
				y = 557
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 285,
				y = 636
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 862,
				y = 661
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 139,
				y = 673
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 531,
				y = 725
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 39,
				y = 738
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 916,
				y = 738
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 1004,
				y = 92
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 88,
				y = 106
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 935,
				y = 488
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 219,
				y = 505
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 786,
				y = 665
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 1004,
				y = 686
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_5",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 78,
				y = 459
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 827,
				y = 118
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_7",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 202,
				y = 152
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_8",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 195,
				y = 628
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_9",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 657,
				y = 130
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 366,
				y = 75
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 203
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 249
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 355,
				y = 730
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 405,
				y = 730
			}
		},
		{
			template = "faerie_trails"
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 335,
				y = 243
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 859,
				y = 536
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 471,
				y = 685
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 827,
				y = 146
			},
			["tower.default_rally_pos"] = {
				x = 833,
				y = 234
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 345,
				y = 152
			},
			["tower.default_rally_pos"] = {
				x = 433,
				y = 150
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 533,
				y = 196
			},
			["tower.default_rally_pos"] = {
				x = 433,
				y = 209
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 707,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 788,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 211,
				y = 230
			},
			["tower.default_rally_pos"] = {
				x = 176,
				y = 317
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 871,
				y = 285
			},
			["tower.default_rally_pos"] = {
				x = 875,
				y = 234
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 347,
				y = 377
			},
			["tower.default_rally_pos"] = {
				x = 353,
				y = 322
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 557,
				y = 410
			},
			["tower.default_rally_pos"] = {
				x = 560,
				y = 505
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 747,
				y = 412
			},
			["tower.default_rally_pos"] = {
				x = 749,
				y = 506
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 647,
				y = 428
			},
			["tower.default_rally_pos"] = {
				x = 639,
				y = 513
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 462,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 479,
				y = 476
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 653,
				y = 566
			},
			["tower.default_rally_pos"] = {
				x = 667,
				y = 513
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {}
	}, {
		max_upgrade_level = 4,
		locked_towers = {}
	}, {
		max_upgrade_level = 4,
		locked_towers = {"tower_build_barrack", "tower_build_mage"}
	}},
	unlock_towers = {"tower_druid"},
	nav_mesh = {
		{13, nil, 2, 11},
		{1, nil, 7, 12},
		{4, 13, 6, 10},
		{nil, 13, 3, 10},
		{6, 7, 8},
		{3, 12, 5},
		{12, 2, 8, 5},
		{5, 7, nil, 5},
		[10] = {nil, 4, 3},
		[11] = {13, 1, 12, 3},
		[12] = {11, 2, 7, 6},
		[13] = {4, 1, 11, 3}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {"music_stage55", "ElvesVenomPlants", "ElvesLevelSevenSounds", "ElvesCreepHoplite", "FaerieGroveAmbienceSounds"},
	required_textures = {"go_enemies_faerie_grove", "go_stage55", "go_stage55_bg", "go_stages_faerie_grove"}
}
