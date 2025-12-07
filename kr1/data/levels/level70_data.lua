-- chunkname: @./kr3/data/levels/level22_data.lua
return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {"ElvesForgottenTreasureAmbienceSound"}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s21_white_flame",
			pos = {
				x = 952,
				y = 179
			}
		},
		{
			["render.sprites[1].anchor.y"] = 0,
			template = "decal",
			["render.sprites[1].animated"] = false,
			["render.sprites[1].name"] = "gargoyle",
			pos = {
				x = 107,
				y = 301
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s21_white_flame",
			pos = {
				x = 324,
				y = 311
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s21_white_flame",
			pos = {
				x = 992,
				y = 481
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s21_white_flame",
			pos = {
				x = 244,
				y = 705
			}
		},
		{
			template = "decal",
			["render.sprites[1].random_ts"] = 0.5,
			["render.sprites[1].name"] = "decal_s21_white_flame",
			pos = {
				x = 469,
				y = 705
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage22_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 3,
			template = "decal_defend_point",
			pos = {
				x = 769,
				y = 75
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 980,
				y = 300
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 981,
				y = 611
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 686,
				y = 54
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 848,
				y = 54
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 986,
				y = 230
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 986,
				y = 363
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 986,
				y = 534
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 986,
				y = 668
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 161,
				y = 31
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -128,
				y = 63
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -81,
				y = 86
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 20,
				y = 90
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 100,
				y = 94
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 66,
				y = 96
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 40,
				y = 109
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -108,
				y = 119
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 43,
				y = 142
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 37,
				y = 211
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -75,
				y = 243
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 24,
				y = 256
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -15,
				y = 263
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -31,
				y = 270
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -122,
				y = 280
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -21,
				y = 280
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 18,
				y = 480
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -36,
				y = 487
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -115,
				y = 502
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 43,
				y = 518
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 43,
				y = 518
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -51,
				y = 529
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 85,
				y = 545
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -115,
				y = 569
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -131,
				y = 577
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = 100,
				y = 587
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -17,
				y = 635
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -49,
				y = 649
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -75,
				y = 724
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 2,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_bubble",
			["delayed_play.max_delay"] = 5,
			pos = {
				x = -145,
				y = 753
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 344,
				y = 87
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 451,
				y = 97
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 386,
				y = 134
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 252,
				y = 235
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 555,
				y = 592
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 171,
				y = 699
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 186,
				y = 721
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_hole",
			["delayed_play.max_delay"] = 2,
			pos = {
				x = 112,
				y = 758
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = 129,
				y = 111
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = -81,
				y = 123
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = 30,
				y = 170
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = 56,
				y = 268
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = 113,
				y = 546
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = 41,
				y = 555
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = -116,
				y = 618
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_s22_lava_smoke",
			["delayed_play.max_delay"] = 8,
			pos = {
				x = -18,
				y = 676
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 34,
				y = 346
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 34,
				y = 391
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 34,
				y = 436
			}
		},
		{
			["editor.r"] = 1.7453292519943,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 288,
				y = 726
			}
		},
		{
			["editor.r"] = 1.7453292519943,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 338,
				y = 726
			}
		},
		{
			["editor.r"] = 1.7453292519943,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 230,
			pos = {
				x = 387,
				y = 726
			}
		},
		{
			template = "lava_fireball_controller",
			launch_cooldown_boss = 3,
			duration = {30, 30, 1e+99},
			launch_active = {{
				nil,
				nil,
				true,
				nil,
				nil,
				true,
				nil,
				nil,
				true,
				nil,
				nil,
				true,
				nil,
				true,
				true
			}, {}, {true}},
			launch_cooldown = {5, 3, 8},
			launch_points = {{
				x = 37,
				y = 258
			}, {
				x = 45,
				y = 210
			}, {
				x = 37,
				y = 500
			}, {
				x = 63,
				y = 537
			}, {
				x = 45,
				y = 572
			}}
		},
		{
			load_file = "level70_spawner",
			template = "mega_spawner",
			spawn_nodes = {45, 95, 125, 145},
			spawn_waves = {"Boss_Path_1", "Boss_Path_2", "Boss_Path_3", "Boss_Path_4"}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 582,
				y = 141
			},
			["tower.default_rally_pos"] = {
				x = 688,
				y = 169
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 871,
				y = 217
			},
			["tower.default_rally_pos"] = {
				x = 864,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 725,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 606,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 432,
				y = 253
			},
			["tower.default_rally_pos"] = {
				x = 514,
				y = 316
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 613,
				y = 307
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 425
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 278,
				y = 357
			},
			["tower.default_rally_pos"] = {
				x = 222,
				y = 440
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 851,
				y = 367
			},
			["tower.default_rally_pos"] = {
				x = 766,
				y = 337
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 428,
				y = 383
			},
			["tower.default_rally_pos"] = {
				x = 464,
				y = 472
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 610,
				y = 494
			},
			["tower.default_rally_pos"] = {
				x = 616,
				y = 445
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 806,
				y = 516
			},
			["tower.default_rally_pos"] = {
				x = 817,
				y = 618
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 461,
				y = 586
			},
			["tower.default_rally_pos"] = {
				x = 354,
				y = 573
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 6,
			template = "tower_holder_forgotten_treasures",
			["editor.game_mode"] = 0,
			pos = {
				x = 638,
				y = 607
			},
			["tower.default_rally_pos"] = {
				x = 713,
				y = 572
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		locked_towers = {"tower_build_engineer", "tower_build_archer"}
	}},
	nav_mesh = {
		{4, nil, 7, 2},
		{4, 1, 7, 5},
		{nil, 4, 5, 6},
		{nil, 1, 2, 3},
		{8, 2, 10, 11},
		{nil, 3, 8},
		{1, nil, 12, 9},
		{6, 5, 5, 11},
		{5, 7, 12, 10},
		{5, 9, 12, 11},
		{8, 5, 10},
		{9, 7, nil, 10}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {"music_stage70", "ElvesForgottenTreasureAmbienceSounds", "ElvesCreepScreecher", "ElvesForgottenTreasureShadowSpawnSounds", "ElvesForgottenTreasureDarkSpitterSounds", "ElvesForgottenTreasureGrimDevourerSounds", "ElvesForgottenTreasureShadowChampionSounds", "ElvesForgottenTreasureBalrogSounds", "ElvesCreepScreecher", "ElvesHeroBolverk"},
	required_textures = {"go_enemies_ancient_metropolis", "go_enemies_forgotten_treasures", "go_stage70", "go_stage70_bg", "go_stages_forgotten_treasures", "go_hero_bolverk"}
}
