﻿-- chunkname: @./kr3/data/levels/level10_data.lua

return {
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		x = 210,
		y = 360
	},
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"FaerieGroveAmbienceTenElevenSound"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage10_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 437,
				y = 76
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 42,
				y = 368
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 367,
				y = 54
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 517,
				y = 54
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 30,
				y = 293
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 30,
				y = 427
			}
		},
		{
			delay = 0,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 701,
				y = 202
			}
		},
		{
			delay = 0.12,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 613,
				y = 212
			}
		},
		{
			delay = 0.24,
			path_id = 7,
			template = "decal_faerie_crystal",
			pos = {
				x = 533,
				y = 257
			}
		},
		{
			delay = 0.84,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 219,
				y = 476
			}
		},
		{
			delay = 0.72,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 228,
				y = 571
			}
		},
		{
			delay = 0.36,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 499,
				y = 598
			}
		},
		{
			delay = 0.48,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 414,
				y = 621
			}
		},
		{
			delay = 0.6,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 310,
				y = 631
			}
		},
		{
			delay = 0.24,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 731,
				y = 644
			}
		},
		{
			delay = 0.12,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 785,
				y = 696
			}
		},
		{
			delay = 0,
			path_id = 3,
			template = "decal_faerie_crystal",
			pos = {
				x = 809,
				y = 751
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 872,
				y = 57
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 740,
				y = 95
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 562,
				y = 120
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = -94,
				y = 272
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 1094,
				y = 297
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 985,
				y = 375
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = -110,
				y = 558
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 192,
				y = 619
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 472,
				y = 672
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 390,
				y = 680
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 321,
				y = 705
			}
		},
		{
			template = "decal_s10_gnome",
			pos = {
				x = 728,
				y = 718
			}
		},
		{
			template = "decal_s10_gnome_walking",
			pos = {
				x = -15,
				y = 470
			},
			walk_points = {
				{
					x = -15,
					y = 470
				},
				{
					x = 70,
					y = 514
				}
			}
		},
		{
			template = "decal_s10_gnome_walking",
			pos = {
				x = 1045,
				y = 688
			},
			walk_points = {
				{
					x = 1047,
					y = 681
				},
				{
					x = 967,
					y = 675
				}
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 547,
				y = 74
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 47,
				y = 250
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 47,
				y = 514
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 288,
				y = 708
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 967,
				y = 367
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 264,
				y = 186
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 929,
				y = 670
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 880,
				y = 70
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 300,
				y = 81
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 979,
				y = 426
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 413,
				y = 729
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 706,
				y = 748
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_7",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 560,
				y = 142
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
				x = 868,
				y = 666
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -0.3490658503988,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 206
			}
		},
		{
			["editor.r"] = -0.3490658503988,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 253
			}
		},
		{
			["editor.r"] = 6.9333427887841e-14,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 549
			}
		},
		{
			["editor.r"] = 6.9333427887841e-14,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 598
			}
		},
		{
			["editor.r"] = 1.9198621771938,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 558,
				y = 723
			}
		},
		{
			["editor.r"] = 1.9198621771938,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 608,
				y = 723
			}
		},
		{
			["editor.r"] = 1.2217304763961,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 798,
				y = 723
			}
		},
		{
			template = "faerie_trails",
			path_speed_per_wave = {
				[3] = {
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					1,
					0,
					1,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0
				},
				[7] = {
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					1,
					0,
					0,
					1,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0
				}
			}
		},
		{
			template = "mega_spawner",
			load_file = "level58_spawner"
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 838,
				y = 336
			}
		},
		{
			template = "plant_poison_pumpkin",
			pos = {
				x = 528,
				y = 640
			}
		},
		{
			template = "simon_controller",
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			template = "simon_gnome",
			pos = {
				x = 90,
				y = 212
			}
		},
		{
			template = "simon_gnome_mushrooom_glow",
			pos = {
				x = 83,
				y = 175
			}
		},
		{
			template = "simon_mushroom_1",
			pos = {
				x = 151,
				y = 122
			}
		},
		{
			template = "simon_mushroom_2",
			pos = {
				x = 152,
				y = 164
			}
		},
		{
			template = "simon_mushroom_3",
			pos = {
				x = 207,
				y = 163
			}
		},
		{
			template = "simon_mushroom_4",
			pos = {
				x = 206,
				y = 122
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 517,
				y = 184
			},
			["tower.default_rally_pos"] = {
				x = 411,
				y = 179
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 845,
				y = 188
			},
			["tower.default_rally_pos"] = {
				x = 860,
				y = 282
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 296,
				y = 232
			},
			["tower.default_rally_pos"] = {
				x = 287,
				y = 322
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 661,
				y = 247
			},
			["tower.default_rally_pos"] = {
				x = 751,
				y = 296
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 156,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 158,
				y = 368
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 492,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 483,
				y = 431
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 637,
				y = 381
			},
			["tower.default_rally_pos"] = {
				x = 634,
				y = 475
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 308,
				y = 389
			},
			["tower.default_rally_pos"] = {
				x = 366,
				y = 332
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 135,
				y = 429
			},
			["tower.default_rally_pos"] = {
				x = 207,
				y = 354
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 904,
				y = 478
			},
			["tower.default_rally_pos"] = {
				x = 793,
				y = 501
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 518,
				y = 513
			},
			["tower.default_rally_pos"] = {
				x = 531,
				y = 450
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 712,
				y = 522
			},
			["tower.default_rally_pos"] = {
				x = 697,
				y = 463
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 792,
				y = 609
			},
			["tower.default_rally_pos"] = {
				x = 829,
				y = 547
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5
		},
		{
			max_upgrade_level = 4
		},
		{
			max_upgrade_level = 4,
			locked_towers = {
				"tower_build_archer",
				"tower_build_barrack"
			}
		}
	},
    unlock_towers = {"tower_entwood"},
	nav_mesh = {
		{
			3,
			2,
			6,
			10
		},
		{
			3,
			nil,
			6,
			1
		},
		{
			nil,
			2,
			1,
			5
		},
		{
			5,
			10,
			9
		},
		{
			nil,
			3,
			4
		},
		{
			1,
			nil,
			13,
			12
		},
		{
			13,
			nil,
			nil,
			11
		},
		{
			9,
			13,
			11
		},
		{
			4,
			12,
			8
		},
		{
			3,
			1,
			12,
			4
		},
		{
			8,
			7
		},
		{
			10,
			6,
			13,
			9
		},
		{
			12,
			6,
			7,
			8
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage58",
		"ElvesVenomPlants",
		"ElvesLevelTenSounds",
		"ElvesCreepHoplite",
		"ElvesScourger",
		"ElvesCreepAvenger",
		"FaerieGroveAmbienceSounds",
		"FaerieGroveAmbienceSoundsTenEleven"
	},
	required_textures = {
		"go_enemies_faerie_grove",
		"go_stage58",
		"go_stage58_bg",
		"go_stages_faerie_grove"
	}
}
