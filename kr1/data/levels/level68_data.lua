-- chunkname: @./kr3/data/levels/level20_data.lua
return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {"MetropolisAmbienceSound"}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 856,
				y = 166
			}
		},
		{
			template = "decal",
			pos = {
				x = 913,
				y = 198
			}
		},
		{
			["render.sprites[1].sort_y"] = 139,
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 993,
				y = 216
			}
		},
		{
			["render.sprites[1].sort_y"] = 139,
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 985,
				y = 281
			}
		},
		{
			["render.sprites[1].sort_y"] = 439,
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 993,
				y = 508
			}
		},
		{
			["render.sprites[1].sort_y"] = 439,
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 985,
				y = 572
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 206,
				y = 607
			}
		},
		{
			["render.sprites[1].sort_y"] = 699,
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 996,
				y = 776
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s20_flame",
			pos = {
				x = 464,
				y = 788
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage20_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 140,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage20_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 700,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage20_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 440,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage20_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 340,
				y = 74
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 43,
				y = 371
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 260,
				y = 63
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 428,
				y = 63
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 646,
				y = 79
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 955,
				y = 95
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 939,
				y = 219
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = -128,
				y = 563
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 237,
				y = 633
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 786,
				y = 704
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 722,
				y = 756
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 547,
				y = 91
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 735,
				y = 91
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 857,
				y = 91
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 72,
				y = 181
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 144,
				y = 581
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 326,
				y = 704
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 163,
				y = 125
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_5",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 70,
				y = 502
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_5",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 127,
				y = 740
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
				x = 900,
				y = 157
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
				x = 236,
				y = 133
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
				x = -16,
				y = 601
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
				x = 887,
				y = 719
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 975,
				y = 327
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 975,
				y = 372
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 975,
				y = 417
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 975,
				y = 623
			}
		},
		{
			["editor.r"] = 0.87266462599716,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 592,
				y = 727
			}
		},
		{
			load_file = "level68_spawner",
			template = "mega_spawner",
			spawn_nodes = {60, 90, 110},
			spawn_waves = {"Boss_Path_1", "Boss_Path_2", "Boss_Path_3", "Boss_Path_4"}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 513,
				y = 120
			},
			["tower.default_rally_pos"] = {
				x = 412,
				y = 175
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 308,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 378,
				y = 132
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 639,
				y = 244
			},
			["tower.default_rally_pos"] = {
				x = 639,
				y = 183
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 192,
				y = 269
			},
			["tower.default_rally_pos"] = {
				x = 192,
				y = 374
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 743,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 743,
				y = 203
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 452,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 452,
				y = 209
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 348,
				y = 447
			},
			["tower.default_rally_pos"] = {
				x = 348,
				y = 373
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 832,
				y = 450
			},
			["tower.default_rally_pos"] = {
				x = 831,
				y = 376
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 117,
				y = 452
			},
			["tower.default_rally_pos"] = {
				x = 115,
				y = 378
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 627,
				y = 457
			},
			["tower.default_rally_pos"] = {
				x = 627,
				y = 376
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 499,
				y = 472
			},
			["tower.default_rally_pos"] = {
				x = 499,
				y = 379
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 731,
				y = 510
			},
			["tower.default_rally_pos"] = {
				x = 731,
				y = 616
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 318,
				y = 616
			},
			["tower.default_rally_pos"] = {
				x = 318,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 574,
				y = 625
			},
			["tower.default_rally_pos"] = {
				x = 572,
				y = 556
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		locked_towers = {"tower_build_barrack", "tower_build_engineer"}
	}},
	nav_mesh = {
		{4, 7, 8, 11},
		{6, nil, 7, 3},
		{6, 2, 4, 14},
		{3, 2, 1, 11},
		{nil, nil, 6, 13},
		{5, 2, 3, 13},
		{2, nil, 8, 1},
		{1, nil, nil, 10},
		{12, 10, 10},
		{9, 8},
		{14, 1, 10, 12},
		{14, 11, 9},
		{5, 6, 14},
		{13, 3, 11, 12}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {"music_stage68", "ElvesCreepServant", "MetropolisAmbienceSounds", "ElvesCreepEvoker", "ElvesCreepGolem", "ElvesScourger", "ElvesCreepAvenger", "ElvesCreepMountedAvenger", "ElvesCreepScreecher", "ElvesBajNimenBossSounds"},
	required_textures = {"go_enemies_ancient_metropolis", "go_enemies_bittering_rancor", "go_stage68", "go_stage68_bg", "go_stages_faerie_grove", "go_stages_bittering_rancor"}
}
