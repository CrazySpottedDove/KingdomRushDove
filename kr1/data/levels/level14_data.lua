-- chunkname: @./kr1/data/levels/level14_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "stage14_wall",
			pos = {
				x = 1043,
				y = 381
			},
			["render.sprites[1].scale"] = {
				x = 0.92,
				y = 0.92
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_14",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].name"] = "orc_ruins_0002",
			["render.sprites[1].anchor.y"] = 0.25,
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 623,
				y = 438
			}
		},
		{
			["render.sprites[1].name"] = "orc_ruins_0001",
			["render.sprites[1].anchor.y"] = 0.25,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 478,
				y = 488
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 81,
				y = 334
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 923,
				y = 403
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 923,
				y = 530
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 608,
				y = 683
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 767,
				y = 683
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_flag_idle",
			pos = {
				x = 936,
				y = 364
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_flag_idle",
			pos = {
				x = 936,
				y = 560
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_flag_idle",
			pos = {
				x = 573,
				y = 680
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_flag_idle",
			pos = {
				x = 795,
				y = 680
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 981,
				y = 453
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 80,
			pos = {
				x = 670,
				y = 715
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 80,
			pos = {
				x = 712,
				y = 715
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 417,
				y = 111
			},
			["tower.default_rally_pos"] = {
				x = 491,
				y = 175
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 666,
				y = 224
			},
			["tower.default_rally_pos"] = {
				x = 663,
				y = 173
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 776,
				y = 225
			},
			["tower.default_rally_pos"] = {
				x = 776,
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
				x = 557,
				y = 228
			},
			["tower.default_rally_pos"] = {
				x = 564,
				y = 175
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 357,
				y = 256
			},
			["tower.default_rally_pos"] = {
				x = 355,
				y = 203
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 461,
				y = 256
			},
			["tower.default_rally_pos"] = {
				x = 447,
				y = 203
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 598,
				y = 305
			},
			["tower.default_rally_pos"] = {
				x = 699,
				y = 325
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 788,
				y = 371
			},
			["tower.default_rally_pos"] = {
				x = 785,
				y = 319
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 215,
				y = 395
			},
			["tower.default_rally_pos"] = {
				x = 215,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 429,
				y = 409
			},
			["tower.default_rally_pos"] = {
				x = 431,
				y = 359
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 380,
				y = 472
			},
			["tower.default_rally_pos"] = {
				x = 317,
				y = 421
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 804,
				y = 515
			},
			["tower.default_rally_pos"] = {
				x = 809,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 701,
				y = 517
			},
			["tower.default_rally_pos"] = {
				x = 732,
				y = 461
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 463,
				y = 532
			},
			["tower.default_rally_pos"] = {
				x = 470,
				y = 621
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 253,
				y = 536
			},
			["tower.default_rally_pos"] = {
				x = 254,
				y = 485
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 362,
				y = 538
			},
			["tower.default_rally_pos"] = {
				x = 361,
				y = 623
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			max_upgrade_level = 6,
			locked_towers = {"tower_build_barrack", "tower_build_archer"}
		}
	},
	nav_mesh = {
		{4, 6, 5},
		{3, 7, 4, 1},
		{nil, 8, 2, 1},
		{2, 7, 6, 1},
		{6, 10, 9, 1},
		{4, 10, 5, 1},
		{8, 13, 10, 4},
		{nil, 12, 7, 3},
		{10, 15, nil, 5},
		{7, 11, 9, 6},
		{14, 16, 15, 10},
		{
			[3] = 13,
			[4] = 8
		},
		{12, nil, 14, 7},
		{13, nil, 16, 11},
		{16, nil, nil, 9},
		{14, nil, 15, 11}
	},
	required_sounds = {"music_stage14"},
	required_textures = {"go_enemies_acaroth", "go_enemies_grass", "go_stage14", "go_stage14_bg"}
}
