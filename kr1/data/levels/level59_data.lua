-- chunkname: @./kr3/data/levels/level11_data.lua
return {
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 6,
	custom_spawn_pos = {
		x = 46,
		y = 251
	},
	entities_list = {
		{
			template = "background_sounds",
			sounds = {"FaerieGroveAmbienceTenElevenSound"}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 777,
				y = 183
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 757,
				y = 352
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 814,
				y = 352
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 873,
				y = 352
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 756,
				y = 447
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 812,
				y = 447
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 866,
				y = 447
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s11_fire",
			pos = {
				x = 776,
				y = 597
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage11_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 415,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 450,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 175,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 110,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 420,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 620,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage11_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 251
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 49,
				y = 526
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 26,
				y = 179
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 26,
				y = 301
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 26,
				y = 448
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 30,
				y = 571
			}
		},
		{
			template = "decal_delayed_play",
			["editor.game_mode"] = 2,
			["render.sprites[1].prefix"] = "decal_s11_gnome_wheelbarrow",
			["render.sprites[1].sort_y"] = 16,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_delayed_play",
			["editor.game_mode"] = 2,
			["render.sprites[1].prefix"] = "decal_s11_gnome_painting",
			["render.sprites[1].sort_y"] = -44,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_delayed_play",
			["editor.game_mode"] = 3,
			["render.sprites[1].prefix"] = "decal_s11_gnome_painting",
			["render.sprites[1].sort_y"] = -44,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_delayed_play",
			["editor.game_mode"] = 3,
			["render.sprites[1].prefix"] = "decal_s11_gnome_wheelbarrow",
			["render.sprites[1].sort_y"] = 16,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_drow_queen_portal",
			path_ids = {4, 5},
			pos = {
				x = 571,
				y = 206
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_drow_queen_portal",
			path_ids = {2, 3, 4, 5},
			pos = {
				x = 413,
				y = 389
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_drow_queen_portal",
			path_ids = {2, 3},
			pos = {
				x = 571,
				y = 535
			}
		},
		{
			delay = 0.12,
			path_id = 6,
			template = "decal_faerie_crystal",
			pos = {
				x = 440,
				y = -7
			}
		},
		{
			delay = 0,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 329,
				y = 1
			}
		},
		{
			delay = 0.24,
			path_id = 6,
			template = "decal_faerie_crystal",
			pos = {
				x = 404,
				y = 60
			}
		},
		{
			delay = 0.12,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 310,
				y = 67
			}
		},
		{
			delay = 0.24,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 287,
				y = 123
			}
		},
		{
			delay = 0.36,
			path_id = 6,
			template = "decal_faerie_crystal",
			pos = {
				x = 395,
				y = 125
			}
		},
		{
			delay = 0.48,
			path_id = 6,
			template = "decal_faerie_crystal",
			pos = {
				x = 428,
				y = 178
			}
		},
		{
			delay = 0.36,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 309,
				y = 185
			}
		},
		{
			delay = 0.48,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 331,
				y = 251
			}
		},
		{
			delay = 0.6,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 322,
				y = 304
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s11_door_glow",
			pos = {
				x = 979,
				y = 150
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s11_door_glow",
			pos = {
				x = 979,
				y = 666
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s11_zealot_rune",
			pos = {
				x = 821,
				y = 132
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s11_zealot_rune",
			pos = {
				x = 822,
				y = 646
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage11_bossDecal_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage11_bossDecal_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage11_bossDecal_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage11_bossDecal_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage11_bossDecal_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage11_bossDecal_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage11_bossDecal_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage11_bossDecal_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage11_bossDecal_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 0,
			template = "decal_static",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage11_bossDecal_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].anchor.y"] = 0,
			template = "decal_static",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage11_fungus",
			pos = {
				x = 591,
				y = 657
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 222,
				y = 72
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 98,
				y = 178
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = -149,
				y = 299
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 25,
				y = 403
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 441,
				y = 567
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 674,
				y = 629
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = -112,
				y = 740
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 342,
				y = 110
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 517,
				y = 83
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 671,
				y = 83
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = -139,
				y = 112
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 45,
				y = 115
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 147,
				y = 143
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 589,
				y = 354
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 686,
				y = 713
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 354,
				y = 742
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 786,
				y = 60
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 192,
				y = 631
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
				x = -95,
				y = 662
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -1.2217304763961,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 300,
				y = 77
			}
		},
		{
			["editor.r"] = -1.2217304763961,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 400,
				y = 77
			}
		},
		{
			["editor.r"] = -2.9698465908723e-14,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 985,
				y = 242
			}
		},
		{
			["editor.r"] = -2.9698465908723e-14,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 985,
				y = 288
			}
		},
		{
			["editor.r"] = -2.9698465908723e-14,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 985,
				y = 518
			}
		},
		{
			["editor.r"] = -2.9698465908723e-14,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 985,
				y = 564
			}
		},
		{
			["editor.r"] = 1.7453292519943,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 506,
				y = 727
			}
		},
		{
			template = "faerie_trails",
			path_speed_per_wave = {
				[6] = {
					1,
					0,
					1,
					0,
					1,
					0,
					1,
					1,
					0,
					1,
					0,
					1,
					1,
					1,
					0,
					1,
					1,
					1,
					1
				},
				[7] = {
					0,
					1,
					0,
					1,
					0,
					1,
					0,
					0,
					1,
					0,
					0,
					1,
					1,
					1,
					0,
					1,
					1,
					1,
					1
				}
			}
		},
		{
			template = "mega_spawner",
			load_file = "level59_spawner"
		},
		{
			template = "plant_poison_pumpkin",
			["editor.game_mode"] = 1,
			pos = {
				x = 600,
				y = 130
			}
		},
		{
			template = "plant_poison_pumpkin",
			["editor.game_mode"] = 2,
			pos = {
				x = 600,
				y = 130
			}
		},
		{
			template = "plant_poison_pumpkin",
			["editor.game_mode"] = 3,
			pos = {
				x = 243,
				y = 261
			}
		},
		{
			template = "plant_poison_pumpkin",
			["editor.game_mode"] = 3,
			pos = {
				x = 257,
				y = 555
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 3,
			pos = {
				x = 600,
				y = 118
			},
			["tower.default_rally_pos"] = {
				x = 568,
				y = 207
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 503,
				y = 128
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 168,
				y = 202
			},
			["tower.default_rally_pos"] = {
				x = 120,
				y = 287
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 3,
			pos = {
				x = 403,
				y = 240
			},
			["tower.default_rally_pos"] = {
				x = 480,
				y = 281
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 253,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 187,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 253,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 187,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 577,
				y = 260
			},
			["tower.default_rally_pos"] = {
				x = 568,
				y = 207
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 120,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 145,
				y = 299
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 526,
				y = 359
			},
			["tower.default_rally_pos"] = {
				x = 417,
				y = 364
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 186,
				y = 418
			},
			["tower.default_rally_pos"] = {
				x = 233,
				y = 373
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 574,
				y = 442
			},
			["tower.default_rally_pos"] = {
				x = 575,
				y = 534
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 368,
				y = 449
			},
			["tower.default_rally_pos"] = {
				x = 348,
				y = 394
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 417,
				y = 506
			},
			["tower.default_rally_pos"] = {
				x = 318,
				y = 534
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 248,
				y = 555
			},
			["tower.default_rally_pos"] = {
				x = 245,
				y = 505
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 248,
				y = 555
			},
			["tower.default_rally_pos"] = {
				x = 245,
				y = 505
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 506,
				y = 577
			},
			["tower.default_rally_pos"] = {
				x = 526,
				y = 527
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 414,
				y = 591
			},
			["tower.default_rally_pos"] = {
				x = 411,
				y = 668
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_pixie",
			["editor.game_mode"] = 1,
			pos = {
				x = 403,
				y = 240
			},
			["tower.default_rally_pos"] = {
				x = 480,
				y = 281
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_pixie",
			["editor.game_mode"] = 2,
			pos = {
				x = 403,
				y = 240
			},
			["tower.default_rally_pos"] = {
				x = 480,
				y = 281
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6
	}, {
		max_upgrade_level = 5
	}, {
		max_upgrade_level = 5,
		locked_towers = {"tower_build_barrack", "tower_build_mage"}
	}},
	unlock_towers = {"tower_pixie"},
	nav_mesh = {
		{3, 3, nil, 2},
		{5, 1},
		{6, 4, 1, 5},
		{8, nil, nil, 3},
		{7, 3, 2},
		{13, 9, 3, 7},
		{14, 6, 5, 10},
		{11, nil, 4, 9},
		{13, 8, 4, 6},
		{14, 14, 7},
		{nil, nil, 8, 13},
		{nil, 13, 6, 14},
		{nil, 11, 6, 12},
		{nil, 12, 7, 10}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage59",
		"ElvesVenomPlants",
		"ElvesScourger",
		"FaerieGroveAmbienceSounds",
		"FaerieGroveAmbienceSoundsTenEleven",
		"ElvesCreepHoplite",
		"ElvesCreepAvenger",
		"ElvesMalicia",
		"FaerieGroveAmbienceSounds",
		"ElvesGnome",
		"ElvesSpecialGnome"
	},
	required_textures = {"go_enemies_faerie_grove", "go_enemies_mactans_malicia", "go_stage59", "go_stage59_bg", "go_stages_faerie_grove"}
}
