﻿-- chunkname: @./kr1/data/levels/level08_data.lua

return {
	level_terrain_type = 1,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		x = 170,
		y = 371
	},
	entities_list = {
		{
			["render.sprites[1].sort_y"] = 340,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage8_cave2",
			pos = {
				x = 877,
				y = 339
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.26
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_8",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 490,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "sasquash_cave",
			pos = {
				x = 246,
				y = 490
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.14
			}
		},
		{
			["render.sprites[1].sort_y"] = 660,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage8_cave1",
			pos = {
				x = 468,
				y = 658
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.18
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 45,
				y = 193
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 310,
				y = 139
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 794,
				y = 631
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 763,
				y = 648
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_tunnel_light",
			pos = {
				x = 820,
				y = 399
			},
			track_names = {
				"1"
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 988,
				y = 138
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 275,
			pos = {
				x = 969,
				y = 595
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 988,
				y = 595
			}
		},
		{
			["editor.r"] = -6.3143934525556e-16,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 988,
				y = 639
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
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 536,
				y = 141
			},
			["tower.default_rally_pos"] = {
				x = 646,
				y = 174
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "07",
			pos = {
				x = 403,
				y = 194
			},
			["tower.default_rally_pos"] = {
				x = 328,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 505,
				y = 195
			},
			["tower.default_rally_pos"] = {
				x = 500,
				y = 287
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "09",
			pos = {
				x = 718,
				y = 221
			},
			["tower.default_rally_pos"] = {
				x = 718,
				y = 174
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 812,
				y = 221
			},
			["tower.default_rally_pos"] = {
				x = 812,
				y = 174
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "06",
			pos = {
				x = 204,
				y = 257
			},
			["tower.default_rally_pos"] = {
				x = 207,
				y = 198
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "03",
			pos = {
				x = 594,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 589,
				y = 426
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "05",
			pos = {
				x = 398,
				y = 339
			},
			["tower.default_rally_pos"] = {
				x = 407,
				y = 286
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "04",
			pos = {
				x = 495,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 496,
				y = 439
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 755,
				y = 483
			},
			["tower.default_rally_pos"] = {
				x = 753,
				y = 579
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "01",
			pos = {
				x = 656,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 649,
				y = 582
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 558,
				y = 487
			},
			["tower.default_rally_pos"] = {
				x = 556,
				y = 586
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 558,
				y = 487
			},
			["tower.default_rally_pos"] = {
				x = 556,
				y = 586
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 2,
			template = "tower_mage_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 558,
				y = 487
			},
			["tower.default_rally_pos"] = {
				x = 556,
				y = 586
			}
		},
		{
			["tower.holder_id"] = "91",
			["ui.nav_mesh_id"] = "91",
			template = "tower_sasquash_holder",
			["editor.game_mode"] = 0,
			pos = {
				x = 329,
				y = 538
			},
			["tower.default_rally_pos"] = {
				x = 429,
				y = 500
			}
		},
		{
			["tunnel.name"] = "1",
			["tunnel.place_pi"] = 5,
			template = "tunnel",
			["tunnel.pick_pi"] = 2,
			pos = {
				x = 0,
				y = 0
			}
		}
	},
	invalid_path_ranges = {
		{
			from = 105,
			path_id = 2
		},
		{
			from = 1,
			to = 9,
			path_id = 4
		}
	},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
				"tower_sorcerer",
				"tower_tesla",
                "tower_sunray"
			}
		},
		{
			locked_hero = true,
			max_upgrade_level = 4,
			locked_towers = {
				"tower_sorcerer",
				"tower_tesla",
                "tower_sunray"
			}
		},
		{
			locked_hero = true,
			max_upgrade_level = 4,
			locked_towers = {
				"tower_build_archer",
				"tower_build_mage",
				"tower_sorcerer",
				"tower_tesla",
                "tower_sunray"
			}
		}
	},
	nav_mesh = {
		{
			2,
			nil,
			20,
			3
		},
		{
			nil,
			nil,
			1,
			10
		},
		{
			9,
			1,
			4,
			9
		},
		{
			3,
			20,
			5,
			8
		},
		{
			4,
			91,
			6,
			7
		},
		{
			5,
			91,
			nil,
			7
		},
		{
			8,
			5,
			6,
			11
		},
		{
			9,
			4,
			7,
			11
		},
		{
			10,
			3,
			8,
			11
		},
		{
			nil,
			2,
			9,
			11
		},
		{
			9,
			8,
			7
		},
		[20] = {
			1,
			nil,
			91,
			4
		},
		[91] = {
			20,
			nil,
			6,
			5
		}
	},
	required_sounds = {
		"music_stage08"
	},
	required_textures = {
		"go_enemies_ice",
		"go_stages_ice",
		"go_stage08",
		"go_stage08_bg"
	}
}
