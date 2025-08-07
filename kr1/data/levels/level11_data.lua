﻿-- chunkname: @./kr1/data/levels/level11_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_11",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 505,
				y = 720
			}
		},
		{
			["editor.r"] = -1.5882496193148,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 90,
			pos = {
				x = 351,
				y = 50
			}
		},
		{
			["editor.r"] = -1.5882496193148,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 90,
			pos = {
				x = 665,
				y = 51
			}
		},
		{
			template = "s11_lava_spawner",
			pos = {
				x = 498,
				y = 383
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 771,
				y = 154
			},
			["tower.default_rally_pos"] = {
				x = 685,
				y = 187
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 234,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 327,
				y = 178
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 461,
				y = 176
			},
			["tower.default_rally_pos"] = {
				x = 367,
				y = 156
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 556,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 643,
				y = 160
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 624,
				y = 271
			},
			["tower.default_rally_pos"] = {
				x = 644,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 388,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 371,
				y = 215
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 721,
				y = 296
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 241
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 299,
				y = 302
			},
			["tower.default_rally_pos"] = {
				x = 294,
				y = 241
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 768,
				y = 368
			},
			["tower.default_rally_pos"] = {
				x = 851,
				y = 341
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "17",
			pos = {
				x = 258,
				y = 369
			},
			["tower.default_rally_pos"] = {
				x = 173,
				y = 337
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 278,
				y = 444
			},
			["tower.default_rally_pos"] = {
				x = 210,
				y = 510
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 743,
				y = 445
			},
			["tower.default_rally_pos"] = {
				x = 854,
				y = 472
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 358,
				y = 478
			},
			["tower.default_rally_pos"] = {
				x = 319,
				y = 557
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 660,
				y = 481
			},
			["tower.default_rally_pos"] = {
				x = 695,
				y = 562
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 453,
				y = 488
			},
			["tower.default_rally_pos"] = {
				x = 456,
				y = 577
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 562,
				y = 489
			},
			["tower.default_rally_pos"] = {
				x = 562,
				y = 576
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 390,
				y = 621
			},
			["tower.default_rally_pos"] = {
				x = 393,
				y = 568
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 628,
				y = 621
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 569
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 6
		},
		{
			max_upgrade_level = 6
		},
		{
			max_upgrade_level = 6,
			locked_towers = {
				"tower_build_archer",
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			nil,
			nil,
			4,
			8
		},
		{
			nil,
			16,
			13
		},
		{
			14,
			18
		},
		{
			1,
			nil,
			nil,
			5
		},
		{
			6,
			4,
			9,
			10
		},
		{
			7,
			4,
			5,
			10
		},
		{
			8,
			1,
			6,
			13
		},
		{
			12,
			1,
			7,
			13
		},
		{
			5,
			5,
			nil,
			17
		},
		{
			13,
			5,
			18,
			14
		},
		{
			2,
			13,
			14
		},
		{
			nil,
			8,
			8,
			15
		},
		{
			16,
			8,
			10,
			11
		},
		{
			11,
			10,
			3
		},
		{
			nil,
			12,
			17,
			16
		},
		{
			nil,
			15,
			13,
			2
		},
		{
			15,
			9,
			nil,
			18
		},
		{
			10,
			17,
			nil,
			3
		}
	},
	required_sounds = {
		"music_stage11"
	},
	required_textures = {
		"go_enemies_wastelands",
		"go_stage11",
		"go_stage11_bg"
	}
}
