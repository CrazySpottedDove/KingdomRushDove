﻿-- chunkname: @./kr1/data/levels/level21_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "aura_burning_floor",
			pos = {
				x = 826,
				y = 208
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 294,
				y = 224
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 784,
				y = 245
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 341,
				y = 261
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 724,
				y = 277
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 837,
				y = 277
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 403,
				y = 284
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 311,
				y = 300
			}
		},
		{
			template = "burning_floor_controller",
			cooldowns = {
				{
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					},
					{
						3,
						5
					}
				},
				{
					{
						1,
						40
					},
					{
						13,
						10
					},
					{
						2,
						10
					},
					{
						2,
						10
					},
					{
						3,
						10
					}
				},
				{
					{
						5,
						9999
					}
				}
			},
			pos = {
				x = 254,
				y = 262
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_21",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 528,
				y = 76
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1082,
				y = 76
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -34,
				y = 113
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1048,
				y = 121
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 19,
				y = 125
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 386,
				y = 489
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1075,
				y = 563
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 48,
				y = 566
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -107,
				y = 575
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 925,
				y = 588
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1134,
				y = 599
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -35,
				y = 624
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -122,
				y = 654
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 884,
				y = 668
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -23,
				y = 671
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 59,
				y = 672
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 943,
				y = 689
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 174,
				y = 714
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1094,
				y = 721
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 665,
				y = 741
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 835,
				y = 741
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 598,
				y = 744
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 393,
				y = 753
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 922,
				y = 753
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_inferno_ground_portal",
			["render.sprites[1].sort_y_offset"] = 20,
			out_nodes = {
				[2] = 3,
				[3] = 3
			},
			pos = {
				x = 528,
				y = 571
			}
		},
		{
			template = "decal_inferno_portal",
			out_nodes = {
				3
			},
			pos = {
				x = 316,
				y = 697
			}
		},
		{
			template = "decal_inferno_portal",
			out_nodes = {
				[4] = 3
			},
			pos = {
				x = 750,
				y = 697
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1139,
				y = 72
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 1026,
				y = 76
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 47,
				y = 91
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -80,
				y = 139
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1137,
				y = 531
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -54,
				y = 567
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1092,
				y = 649
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 122,
				y = 690
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 881,
				y = 702
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = -116,
				y = 710
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 963,
				y = 726
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 435,
				y = 737
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 219,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 675,
				y = 772
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s21_hellboy",
			pos = {
				x = 955,
				y = 660
			}
		},
		{
			template = "decal_s21_veznan",
			editor = {
				game_mode = 1
			},
			pos = {
				x = 631,
				y = 729
			}
		},
		{
			template = "decal_s21_veznan_free",
			editor = {
				game_mode = 2
			},
			pos = {
				x = 631,
				y = 729
			}
		},
		{
			template = "decal_s21_veznan_free",
			editor = {
				game_mode = 3
			},
			pos = {
				x = 631,
				y = 729
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 501,
				y = 511
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 545,
				y = 511
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 316,
				y = 594
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 754,
				y = 595
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 547,
				y = 162
			},
			["tower.default_rally_pos"] = {
				x = 544,
				y = 107
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 738,
				y = 172
			},
			["tower.default_rally_pos"] = {
				x = 737,
				y = 118
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 359,
				y = 176
			},
			["tower.default_rally_pos"] = {
				x = 355,
				y = 121
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 901,
				y = 218
			},
			["tower.default_rally_pos"] = {
				x = 827,
				y = 179
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 649,
				y = 226
			},
			["tower.default_rally_pos"] = {
				x = 649,
				y = 308
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 481,
				y = 230
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 310
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 222,
				y = 259
			},
			["tower.default_rally_pos"] = {
				x = 274,
				y = 211
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 766,
				y = 322
			},
			["tower.default_rally_pos"] = {
				x = 758,
				y = 263
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 371,
				y = 343
			},
			["tower.default_rally_pos"] = {
				x = 371,
				y = 277
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 592,
				y = 345
			},
			["tower.default_rally_pos"] = {
				x = 589,
				y = 295
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 856,
				y = 361
			},
			["tower.default_rally_pos"] = {
				x = 860,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 144,
				y = 365
			},
			["tower.default_rally_pos"] = {
				x = 142,
				y = 312
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 252,
				y = 400
			},
			["tower.default_rally_pos"] = {
				x = 247,
				y = 339
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 547,
				y = 401
			},
			["tower.default_rally_pos"] = {
				x = 459,
				y = 371
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 682,
				y = 406
			},
			["tower.default_rally_pos"] = {
				x = 773,
				y = 452
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 5,
			locked_towers = {
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			4,
			7,
			8
		},
		{
			3,
			nil,
			7,
			4
		},
		{
			6,
			nil,
			2,
			6
		},
		{
			5,
			2,
			1
		},
		{
			9,
			6,
			4,
			10
		},
		{
			11,
			3,
			3,
			9
		},
		{
			2,
			nil,
			8,
			1
		},
		{
			7,
			nil,
			nil,
			1
		},
		{
			12,
			6,
			10,
			10
		},
		{
			9,
			5,
			4
		},
		{
			14,
			nil,
			6,
			6
		},
		{
			15,
			14,
			9
		},
		{
			[3] = 14,
			[4] = 15
		},
		{
			13,
			11,
			11,
			12
		},
		{
			nil,
			13,
			12
		}
	},
	required_sounds = {
		"music_stage21",
		"InfernoSounds"
	},
	required_textures = {
		"go_enemies_wastelands",
		"go_enemies_torment",
		"go_stages_rotten_torment",
		"go_stage21",
		"go_stage21_bg"
	}
}
