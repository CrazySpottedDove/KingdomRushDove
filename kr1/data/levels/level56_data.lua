-- chunkname: @./kr3/data/levels/level08_data.lua
return {
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
			["render.sprites[1].name"] = "Stage08_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 570,
				y = 73
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 486,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 660,
				y = 53
			}
		},
		{
			template = "decal_s08_hansel_gretel",
			pos = {
				x = 327,
				y = 254
			}
		},
		{
			template = "decal_s08_magic_bean",
			pos = {
				x = 312,
				y = 697
			}
		},
		{
			template = "decal_s08_peekaboo_pork",
			pos = {
				x = 906,
				y = 135
			},
			pos_list = {{
				x = 906,
				y = 135
			}, {
				x = 898,
				y = 250
			}, {
				x = 925,
				y = 343
			}}
		},
		{
			template = "decal_s08_peekaboo_rrh",
			pos = {
				x = 993,
				y = 187
			}
		},
		{
			template = "decal_s08_peekaboo_wolf",
			pos = {
				x = 976,
				y = 420
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 871,
				y = 680
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 993,
				y = 701
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 1177,
				y = 740
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 304,
				y = 170
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 1186,
				y = 97
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = -109,
				y = 131
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 62,
				y = 247
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 735,
				y = 70
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 109,
				y = 133
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 919,
				y = 417
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 521,
				y = 513
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 393,
				y = 720
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 109,
				y = 317
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
				x = 181,
				y = 666
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
				x = -168,
				y = 386
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
				x = 1104,
				y = 471
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
				x = 1121,
				y = 676
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
				x = 781,
				y = 700
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
				x = 840,
				y = 182
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
				x = -120,
				y = 643
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 43,
				y = 450
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 43,
				y = 498
			}
		},
		{
			["editor.r"] = -3.0808688933348e-14,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 989,
				y = 522
			}
		},
		{
			["editor.r"] = -3.0808688933348e-14,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 989,
				y = 573
			}
		},
		{
			["editor.r"] = 1.221730476396,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 638,
				y = 734
			}
		},
		{
			["editor.r"] = 1.221730476396,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 692,
				y = 734
			}
		},
		{
			template = "faerie_trails",
			path_speed_per_wave = {
				{
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1
				},
				[3] = {
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1
				},
				[6] = {
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1,
					1
				}
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 313,
				y = 463
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 534,
				y = 546
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 666,
				y = 640
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 749,
				y = 137
			},
			["tower.default_rally_pos"] = {
				x = 645,
				y = 162
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 545,
				y = 162
			},
			["tower.default_rally_pos"] = {
				x = 622,
				y = 122
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 722,
				y = 262
			},
			["tower.default_rally_pos"] = {
				x = 623,
				y = 264
			}
		},
		{
			["tower.holder_id"] = "19",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 508,
				y = 279
			},
			["tower.default_rally_pos"] = {
				x = 550,
				y = 369
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 399,
				y = 313
			},
			["tower.default_rally_pos"] = {
				x = 429,
				y = 390
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 683,
				y = 349
			},
			["tower.default_rally_pos"] = {
				x = 593,
				y = 358
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 147,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 166,
				y = 471
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 514,
				y = 428
			},
			["tower.default_rally_pos"] = {
				x = 501,
				y = 370
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 414,
				y = 465
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 398
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 721,
				y = 486
			},
			["tower.default_rally_pos"] = {
				x = 629,
				y = 502
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 870,
				y = 503
			},
			["tower.default_rally_pos"] = {
				x = 862,
				y = 589
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 585,
				y = 615
			},
			["tower.default_rally_pos"] = {
				x = 560,
				y = 701
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 376,
				y = 619
			},
			["tower.default_rally_pos"] = {
				x = 377,
				y = 562
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 752,
				y = 626
			},
			["tower.default_rally_pos"] = {
				x = 757,
				y = 577
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
		locked_towers = {"tower_build_mage", "tower_build_engineer"}
	}},
	unlock_towers = {"tower_silver", "tower_forest"},
	nav_mesh = {
		[11] = {nil, 12, 14, 16},
		[12] = {11, nil, 17, 14},
		[13] = {11, 14, 23, 16},
		[14] = {11, 12, 23, 13},
		[15] = {11, 16, 20},
		[16] = {11, 13, 19, 15},
		[17] = {12, nil, 18, 23},
		[18] = {17, nil, 24, 21},
		[19] = {16, 23, 22, 20},
		[20] = {15, 19, 22},
		[21] = {23, 18, 24, 22},
		[22] = {19, 21, 24, 20},
		[23] = {13, 17, 21, 19},
		[24] = {21, 18, nil, 22}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {"music_stage56", "ElvesVenomPlants", "ElvesLevelEightSounds", "ElvesCreepHoplite", "ElvesScourger", "FaerieGroveAmbienceSounds"},
	required_textures = {"go_enemies_faerie_grove", "go_stage56", "go_stage56_bg", "go_stages_faerie_grove"}
}
