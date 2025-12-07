-- chunkname: @./kr1/data/levels/level16_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_16",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 51,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_16_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 602,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_16_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 45,
				y = 415
			}
		},
		{
			["editor.r"] = -2.9420910152567e-15,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 978,
				y = 166
			}
		},
		{
			["editor.r"] = 0.17453292519943,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 978,
				y = 351
			}
		},
		{
			["editor.r"] = 0.17453292519943,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 979,
				y = 395
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 182,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 194,
				y = 301
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 558,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 602,
				y = 194
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 654,
				y = 255
			},
			["tower.default_rally_pos"] = {
				x = 660,
				y = 202
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 288,
				y = 299
			},
			["tower.default_rally_pos"] = {
				x = 262,
				y = 243
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 427,
				y = 339
			},
			["tower.default_rally_pos"] = {
				x = 518,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 590,
				y = 383
			},
			["tower.default_rally_pos"] = {
				x = 588,
				y = 343
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 687,
				y = 397
			},
			["tower.default_rally_pos"] = {
				x = 749,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 299,
				y = 431
			},
			["tower.default_rally_pos"] = {
				x = 349,
				y = 390
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 547,
				y = 437
			},
			["tower.default_rally_pos"] = {
				x = 476,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 232,
				y = 467
			},
			["tower.default_rally_pos"] = {
				x = 194,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 470,
				y = 481
			},
			["tower.default_rally_pos"] = {
				x = 397,
				y = 451
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 700,
				y = 481
			},
			["tower.default_rally_pos"] = {
				x = 789,
				y = 485
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 206,
				y = 534
			},
			["tower.default_rally_pos"] = {
				x = 296,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 754,
				y = 558
			},
			["tower.default_rally_pos"] = {
				x = 827,
				y = 539
			}
		}
	},
	invalid_path_ranges = {{
		from = 120,
		to = 162,
		path_id = 1
	}, {
		from = 96,
		to = 127,
		path_id = 3
	}},
	level_mode_overrides = {
		[3] = {
			max_upgrade_level = 6,
			locked_towers = {"tower_build_archer", "tower_build_mage"}
		}
	},
	nav_mesh = {
		{4, 4},
		{3, 6, 5},
		{nil, 7, 2},
		{5, 8, 1, 1},
		{6, 11, 4, 2},
		{7, 9, 5, 2},
		{nil, 12, 6, 3},
		{11, 10, 10, 4},
		{12, 11, 11, 6},
		{11, 13, 13, 8},
		{9, nil, 8, 5},
		{14, 14, 9, 7},
		{11, nil, nil, 10},
		{
			[3] = 11,
			[4] = 12
		}
	},
	required_sounds = {"music_stage16"},
	required_textures = {"go_enemies_grass", "go_enemies_bandits", "go_stages_grass", "go_stage16", "go_stage16_bg"}
}
