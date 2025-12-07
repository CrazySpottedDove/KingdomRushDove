-- chunkname: @./kr1/data/levels/level05_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			["render.sprites[1].sort_y"] = 100,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_5_trees",
			pos = {
				x = 1177,
				y = 162
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_5",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 710,
				y = 713
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 7,
			pos = {
				x = 539,
				y = 89
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 7,
			pos = {
				x = 585,
				y = 89
			}
		},
		{
			["editor.r"] = -1.7416623698807e-15,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 51,
			pos = {
				x = 987,
				y = 171
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_archer_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 304,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 307,
				y = 255
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_archer_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 377,
				y = 443
			},
			["tower.default_rally_pos"] = {
				x = 451,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_archer_3",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 550,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 643,
				y = 527
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_archer_3",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 550,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 643,
				y = 527
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_archer_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 550,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 643,
				y = 527
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_elf_holder",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 515,
				y = 335
			},
			["tower.default_rally_pos"] = {
				x = 414,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_elf_holder",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 282,
				y = 579
			},
			["tower.default_rally_pos"] = {
				x = 346,
				y = 541
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_elf_holder",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 282,
				y = 579
			},
			["tower.default_rally_pos"] = {
				x = 346,
				y = 541
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_elf_holder",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 282,
				y = 579
			},
			["tower.default_rally_pos"] = {
				x = 346,
				y = 541
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 363,
				y = 156
			},
			["tower.default_rally_pos"] = {
				x = 380,
				y = 255
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 637,
				y = 188
			},
			["tower.default_rally_pos"] = {
				x = 546,
				y = 163
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 660,
				y = 263
			},
			["tower.default_rally_pos"] = {
				x = 768,
				y = 289
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 506,
				y = 272
			},
			["tower.default_rally_pos"] = {
				x = 436,
				y = 235
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 304,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 307,
				y = 255
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 304,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 307,
				y = 255
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 673,
				y = 329
			},
			["tower.default_rally_pos"] = {
				x = 772,
				y = 359
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 515,
				y = 335
			},
			["tower.default_rally_pos"] = {
				x = 414,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 515,
				y = 335
			},
			["tower.default_rally_pos"] = {
				x = 414,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 377,
				y = 443
			},
			["tower.default_rally_pos"] = {
				x = 451,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 377,
				y = 443
			},
			["tower.default_rally_pos"] = {
				x = 451,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 788,
				y = 458
			},
			["tower.default_rally_pos"] = {
				x = 705,
				y = 433
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 744,
				y = 506
			},
			["tower.default_rally_pos"] = {
				x = 651,
				y = 469
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 195,
				y = 522
			},
			["tower.default_rally_pos"] = {
				x = 266,
				y = 483
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 556,
				y = 627
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 591
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 556,
				y = 627
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 591
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 556,
				y = 627
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 591
			}
		}
	},
	invalid_path_ranges = {{
		flags = 4294967295,
		to = 21,
		from = 1,
		path_id = 3
	}},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 4,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 4,
		locked_towers = {"tower_build_barrack"}
	}},
	unlock_towers = {"tower_ranger", "tower_elf"},
	nav_mesh = {
		{8, 3, nil, 14},
		{5, 5, nil, 1},
		{4, 5, 2, 1},
		{12, 6, 3, 7},
		{6, nil, 2, 3},
		{12, nil, 5, 4},
		{9, 4, 3, 8},
		{10, 7, 1, 14},
		{13, 13, 7, 10},
		{13, 9, 8, 11},
		{nil, 10, 14},
		{nil, 6, 4, 13},
		{nil, 12, 4, 9},
		{11, 8, 1}
	},
	required_sounds = {"music_stage05", "HeroArcher"},
	required_textures = {"go_enemies_grass", "go_stages_grass", "go_stage05", "go_stage05_bg", "go_hero_alleria"}
}
