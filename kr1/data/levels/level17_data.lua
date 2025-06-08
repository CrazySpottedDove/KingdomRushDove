﻿-- chunkname: @./kr1/data/levels/level17_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage17_wall_bottom_",
			pos = {
				x = 1180,
				y = 182
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.5
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_17",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 350,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage17_wall_top",
			pos = {
				x = 1149,
				y = 415
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.5
			}
		},
		{
			template = "decal_bandits_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_bandits_flag_idle",
			pos = {
				x = 983,
				y = 134
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_bandits_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_bandits_flag_idle",
			pos = {
				x = 983,
				y = 520
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 190
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 414
			}
		},
		{
			destroy_node = 104,
			template = "decal_s17_barricade",
			["editor.game_mode"] = 1,
			pos = {
				x = 403,
				y = 421
			}
		},
		{
			destroy_node = 95,
			template = "decal_s17_barricade",
			["editor.game_mode"] = 1,
			pos = {
				x = 466,
				y = 439
			}
		},
		{
			destroy_node = 111,
			template = "decal_s17_barricade",
			["editor.game_mode"] = 1,
			pos = {
				x = 357,
				y = 445
			}
		},
		{
			["editor.r"] = 0.017453292519903,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 974,
				y = 214
			}
		},
		{
			["editor.r"] = 0.017453292519903,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 974,
				y = 384
			}
		},
		{
			["editor.r"] = 0.017453292519903,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 974,
				y = 426
			}
		},
		{
			["editor.r"] = 0.017453292519903,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 974,
				y = 470
			}
		},
		{
			["editor.r"] = 1.5882496193148,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 90,
			pos = {
				x = 591,
				y = 723
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 714,
				y = 140
			},
			["tower.default_rally_pos"] = {
				x = 711,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 231,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 293,
				y = 249
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 577,
				y = 228
			},
			["tower.default_rally_pos"] = {
				x = 576,
				y = 174
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 755,
				y = 268
			},
			["tower.default_rally_pos"] = {
				x = 770,
				y = 206
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 648,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 654,
				y = 199
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 376,
				y = 285
			},
			["tower.default_rally_pos"] = {
				x = 373,
				y = 232
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 227,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 223,
				y = 266
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 444,
				y = 345
			},
			["tower.default_rally_pos"] = {
				x = 547,
				y = 364
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 650,
				y = 351
			},
			["tower.default_rally_pos"] = {
				x = 661,
				y = 432
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 201,
				y = 476
			},
			["tower.default_rally_pos"] = {
				x = 261,
				y = 435
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 408,
				y = 489
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 569
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 507,
				y = 489
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 587
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 607,
				y = 489
			},
			["tower.default_rally_pos"] = {
				x = 599,
				y = 425
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 427,
				y = 625
			},
			["tower.default_rally_pos"] = {
				x = 450,
				y = 576
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 639,
				y = 631
			},
			["tower.default_rally_pos"] = {
				x = 630,
				y = 578
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 5,
			locked_towers = {
				"tower_build_mage",
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			4,
			5,
			3
		},
		{
			6,
			7
		},
		{
			5,
			9,
			6,
			1
		},
		{
			nil,
			9,
			5,
			1
		},
		{
			4,
			9,
			3,
			1
		},
		{
			3,
			8,
			7,
			2
		},
		{
			6,
			10,
			nil,
			2
		},
		{
			9,
			11,
			6,
			6
		},
		{
			4,
			13,
			8,
			5
		},
		{
			11,
			14,
			nil,
			7
		},
		{
			12,
			14,
			10,
			8
		},
		{
			13,
			14,
			11,
			8
		},
		{
			nil,
			15,
			12,
			9
		},
		{
			15,
			nil,
			10,
			11
		},
		{
			nil,
			nil,
			14,
			13
		}
	},
	required_sounds = {
		"music_stage17"
	},
	required_textures = {
		"go_enemies_grass",
		"go_enemies_bandits",
		"go_stages_grass",
		"go_stage17",
		"go_stage17_bg"
	}
}
