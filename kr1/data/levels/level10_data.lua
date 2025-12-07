-- chunkname: @./kr1/data/levels/level10_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_10",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 562,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0008",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 548,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0006",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 524,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0005",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 544,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0007",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 515,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0004",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 470,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0002",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["render.sprites[1].sort_y"] = 502,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0003",
			pos = {
				x = 551,
				y = 570
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 350,
				y = 721
			}
		},
		{
			["editor.r"] = -0.1221730476396,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 236,
			pos = {
				x = 999,
				y = 164
			}
		},
		{
			["editor.r"] = -3.1241393610698,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 335,
			pos = {
				x = 37,
				y = 226
			}
		},
		{
			template = "graveyard_controller",
			["graveyard.spawn_pos"] = {{
				x = 148,
				y = 556
			}, {
				x = 179,
				y = 541
			}, {
				x = 146,
				y = 519
			}, {
				x = 239,
				y = 540
			}, {
				x = 189,
				y = 502
			}, {
				x = 200,
				y = 526
			}},
			pos = {
				x = 205,
				y = 510
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 211,
				y = 224
			},
			["tower.default_rally_pos"] = {
				x = 204,
				y = 161
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 309,
				y = 224
			},
			["tower.default_rally_pos"] = {
				x = 304,
				y = 161
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 809,
				y = 226
			},
			["tower.default_rally_pos"] = {
				x = 805,
				y = 165
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 582,
				y = 243
			},
			["tower.default_rally_pos"] = {
				x = 686,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 500,
				y = 295
			},
			["tower.default_rally_pos"] = {
				x = 418,
				y = 253
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 584,
				y = 331
			},
			["tower.default_rally_pos"] = {
				x = 693,
				y = 366
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 800,
				y = 349
			},
			["tower.default_rally_pos"] = {
				x = 689,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 351,
				y = 365
			},
			["tower.default_rally_pos"] = {
				x = 336,
				y = 312
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 446,
				y = 365
			},
			["tower.default_rally_pos"] = {
				x = 396,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 597,
				y = 407
			},
			["tower.default_rally_pos"] = {
				x = 503,
				y = 461
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 654,
				y = 462
			},
			["tower.default_rally_pos"] = {
				x = 733,
				y = 414
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 406,
				y = 518
			},
			["tower.default_rally_pos"] = {
				x = 407,
				y = 466
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 607,
				y = 532
			},
			["tower.default_rally_pos"] = {
				x = 503,
				y = 524
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 704,
				y = 532
			},
			["tower.default_rally_pos"] = {
				x = 805,
				y = 524
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
		locked_towers = {"tower_build_engineer"}
	}},
	unlock_towers = {"tower_tesla"},
	nav_mesh = {
		{2, 8},
		{5, 8, 1},
		{nil, 7, 4},
		{3, 6, 5},
		{6, 9, 2, 4},
		{7, 10, 9, 4},
		{nil, 14, 6, 3},
		{9, 12, nil, 2},
		{6, 12, 8, 5},
		{7, 11, 9, 6},
		{7, 13, 12, 10},
		{13, nil, nil, 8},
		{14, nil, 12, 11},
		{7, nil, 13, 11}
	},
	required_sounds = {"music_stage10"},
	required_textures = {"go_enemies_wastelands", "go_stage10", "go_stage10_bg"}
}
