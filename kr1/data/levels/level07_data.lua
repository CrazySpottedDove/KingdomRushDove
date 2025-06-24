﻿-- chunkname: @./kr1/data/levels/level07_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			["render.sprites[1].name"] = "stage7_cave3",
			["render.sprites[1].anchor.y"] = 0.22,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 173,
				y = 257
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_7",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].name"] = "stage7_cave2",
			["render.sprites[1].anchor.y"] = 0.3,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 824,
				y = 464
			}
		},
		{
			["render.sprites[1].name"] = "stage7_cave1",
			["render.sprites[1].anchor.y"] = 0.3,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 298,
				y = 654
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 684,
				y = 84
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 827,
				y = 188
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 892,
				y = 292
			}
		},
		{
			template = "decal_tunnel_light",
			pos = {
				x = 231,
				y = 282
			},
			track_names = {
				"2"
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_tunnel_light",
			pos = {
				x = 768,
				y = 490
			},
			track_names = {
				"1"
			}
		},
		{
			["editor.r"] = 1.5882496193148,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 83,
			pos = {
				x = 618,
				y = 706
			}
		},
		{
			["editor.r"] = 1.5882496193148,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 83,
			pos = {
				x = 678,
				y = 706
			}
		},
		{
			["editor.r"] = 1.6231562043547,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 83,
			pos = {
				x = 648,
				y = 736
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
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_barrack_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 447,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 449,
				y = 445
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_barrack_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 648,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 724,
				y = 422
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_barrack_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 546,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 537,
				y = 443
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 739,
				y = 160
			},
			["tower.default_rally_pos"] = {
				x = 648,
				y = 128
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 655,
				y = 197
			},
			["tower.default_rally_pos"] = {
				x = 655,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 460,
				y = 201
			},
			["tower.default_rally_pos"] = {
				x = 465,
				y = 284
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 558,
				y = 201
			},
			["tower.default_rally_pos"] = {
				x = 555,
				y = 284
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 347,
				y = 348
			},
			["tower.default_rally_pos"] = {
				x = 350,
				y = 446
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 447,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 449,
				y = 444
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 447,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 448,
				y = 443
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 648,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 724,
				y = 422
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 648,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 724,
				y = 422
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 546,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 542,
				y = 444
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 546,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 538,
				y = 443
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 585,
				y = 508
			},
			["tower.default_rally_pos"] = {
				x = 567,
				y = 596
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 480,
				y = 511
			},
			["tower.default_rally_pos"] = {
				x = 480,
				y = 596
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 375,
				y = 512
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 596
			}
		},
		{
			["tunnel.name"] = "1",
			["tunnel.place_pi"] = 4,
			template = "tunnel",
			["tunnel.pick_pi"] = 2,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			["tunnel.name"] = "2",
			["tunnel.place_pi"] = 5,
			template = "tunnel",
			["tunnel.pick_pi"] = 3,
			pos = {
				x = 0,
				y = 0
			}
		}
	},
	invalid_path_ranges = {
		{
			from = 75,
			path_id = 2
		},
		{
			from = 75,
			path_id = 3
		},
		{
			from = 1,
			to = 5,
			path_id = 4
		},
		{
			from = 1,
			to = 5,
			path_id = 5
		}
	},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {

			}
		},
		{
			locked_hero = true,
			max_upgrade_level = 3,
			locked_towers = {

			}
		},
		{
			locked_hero = true,
			max_upgrade_level = 3,
			locked_towers = {
				"tower_build_barrack",
				"tower_build_engineer",
			}
		}
	},
    unlock_towers = {"tower_musketeer"},
	nav_mesh = {
		{
			2,
			nil,
			nil,
			7
		},
		{
			3,
			nil,
			1,
			6
		},
		{
			[3] = 2,
			[4] = 5
		},
		{
			nil,
			3,
			5,
			10
		},
		{
			4,
			3,
			6,
			9
		},
		{
			5,
			2,
			7,
			8
		},
		{
			6,
			1,
			nil,
			8
		},
		{
			9,
			6
		},
		{
			10,
			5,
			8
		},
		{
			11,
			4,
			9,
			11
		},
		{
			nil,
			4,
			10
		}
	},
	required_sounds = {
		"music_stage07"
	},
	required_textures = {
		"go_enemies_ice",
		"go_stages_ice",
		"go_stage07",
		"go_stage07_bg"
	}
}
