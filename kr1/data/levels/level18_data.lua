﻿-- chunkname: @./kr1/data/levels/level18_data.lua

return {
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_18",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 624,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_18_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 588,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_18_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 160,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_18_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 52,
				y = 340
			}
		},
		{
			template = "decal_scrat",
			pos = {
				x = 169,
				y = 459
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_tunnel_light",
			pos = {
				x = 954,
				y = 229
			},
			track_names = {
				"1",
				"2"
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 976,
				y = 495
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 362,
				y = 598
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 317,
				y = 608
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 349,
				y = 640
			}
		},
		{
			template = "ps_stage_snow",
			pos = {
				x = 512,
				y = 768
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 759,
				y = 122
			},
			["tower.default_rally_pos"] = {
				x = 725,
				y = 214
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 416,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 256
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 510,
				y = 177
			},
			["tower.default_rally_pos"] = {
				x = 515,
				y = 264
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 782,
				y = 270
			},
			["tower.default_rally_pos"] = {
				x = 786,
				y = 209
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 656,
				y = 282
			},
			["tower.default_rally_pos"] = {
				x = 633,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 309,
				y = 285
			},
			["tower.default_rally_pos"] = {
				x = 298,
				y = 223
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 471,
				y = 352
			},
			["tower.default_rally_pos"] = {
				x = 456,
				y = 281
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 597,
				y = 365
			},
			["tower.default_rally_pos"] = {
				x = 562,
				y = 450
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 723,
				y = 369
			},
			["tower.default_rally_pos"] = {
				x = 733,
				y = 448
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 393,
				y = 511
			},
			["tower.default_rally_pos"] = {
				x = 396,
				y = 445
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 496,
				y = 515
			},
			["tower.default_rally_pos"] = {
				x = 482,
				y = 456
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 595,
				y = 515
			},
			["tower.default_rally_pos"] = {
				x = 629,
				y = 456
			}
		},
		{
			["tunnel.name"] = "1",
			["tunnel.place_pi"] = 5,
			template = "tunnel",
			["tunnel.pick_pi"] = 1,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			["tunnel.name"] = "2",
			["tunnel.place_pi"] = 6,
			template = "tunnel",
			["tunnel.pick_pi"] = 2,
			pos = {
				x = 0,
				y = 0
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 6,
			locked_towers = {
				"tower_build_archer",
				"tower_build_mage"
			}
		}
	},
	nav_mesh = {
		{
			nil,
			4,
			3
		},
		{
			3,
			6
		},
		{
			1,
			7,
			2
		},
		{
			nil,
			9,
			5,
			1
		},
		{
			4,
			8,
			7,
			3
		},
		{
			7,
			10,
			nil,
			2
		},
		{
			8,
			10,
			6,
			3
		},
		{
			9,
			11,
			7,
			5
		},
		{
			nil,
			12,
			8,
			4
		},
		{
			11,
			nil,
			6,
			7
		},
		{
			12,
			nil,
			10,
			8
		},
		{
			[3] = 11,
			[4] = 9
		}
	},
	required_sounds = {
		"music_stage18",
		"JtEffects"
	},
	required_textures = {
		"go_enemies_ice",
		"go_enemies_storm",
		"go_stages_ice",
		"go_stage18",
		"go_stage18_bg"
	}
}
