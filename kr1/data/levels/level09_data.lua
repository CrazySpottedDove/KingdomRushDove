-- chunkname: @./kr1/data/levels/level09_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			["render.sprites[1].sort_y"] = 100,
			["render.sprites[1].z"] = 1000,
			template = "decal_background",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage9_boss_corpse",
			pos = {
				x = 910,
				y = 263
			}
		},
		{
			["render.sprites[1].sort_y"] = 100,
			["render.sprites[1].z"] = 1000,
			template = "decal_background",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage9_boss_corpse",
			pos = {
				x = 910,
				y = 263
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_9",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].name"] = "stage9_cave1",
			["render.sprites[1].anchor.y"] = 0.08,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].sort_y"] = 100,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 864,
				y = 527
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 230,
				y = 398
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 870,
				y = 317
			}
		},
		{
			template = "decal_goat",
			pos = {
				x = 289,
				y = 658
			}
		},
		{
			["editor.r"] = -1.542871058763,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 110,
			pos = {
				x = 560,
				y = 55
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 140,
			pos = {
				x = 780,
				y = 516
			}
		},
		{
			["editor.r"] = 1.4660765716753,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 571,
				y = 732
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
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 454,
				y = 158
			},
			["tower.default_rally_pos"] = {
				x = 424,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 454,
				y = 158
			},
			["tower.default_rally_pos"] = {
				x = 424,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 454,
				y = 158
			},
			["tower.default_rally_pos"] = {
				x = 424,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 560,
				y = 160
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 560,
				y = 160
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 668,
				y = 162
			},
			["tower.default_rally_pos"] = {
				x = 672,
				y = 106
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 668,
				y = 162
			},
			["tower.default_rally_pos"] = {
				x = 672,
				y = 106
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 794,
				y = 291
			},
			["tower.default_rally_pos"] = {
				x = 754,
				y = 224
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 794,
				y = 291
			},
			["tower.default_rally_pos"] = {
				x = 754,
				y = 224
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 794,
				y = 291
			},
			["tower.default_rally_pos"] = {
				x = 754,
				y = 224
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 494,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 485,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 494,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 485,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 593,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 593,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 693,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 700,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 693,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 700,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 780,
				y = 363
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 447
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 780,
				y = 363
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 447
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 780,
				y = 363
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 447
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 601,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 601,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 402,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 398
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 402,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 398
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 402,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 398
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 502,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 505,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 502,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 505,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 313,
				y = 490
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 573
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 313,
				y = 490
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 573
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 313,
				y = 490
			},
			["tower.default_rally_pos"] = {
				x = 386,
				y = 573
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 674,
				y = 600
			},
			["tower.default_rally_pos"] = {
				x = 667,
				y = 546
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 674,
				y = 600
			},
			["tower.default_rally_pos"] = {
				x = 667,
				y = 546
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 674,
				y = 600
			},
			["tower.default_rally_pos"] = {
				x = 667,
				y = 546
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 574,
				y = 604
			},
			["tower.default_rally_pos"] = {
				x = 573,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 574,
				y = 604
			},
			["tower.default_rally_pos"] = {
				x = 573,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 472,
				y = 608
			},
			["tower.default_rally_pos"] = {
				x = 470,
				y = 555
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 472,
				y = 608
			},
			["tower.default_rally_pos"] = {
				x = 470,
				y = 555
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 560,
				y = 160
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 668,
				y = 162
			},
			["tower.default_rally_pos"] = {
				x = 672,
				y = 106
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 494,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 485,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 593,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 625,
				y = 250
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 693,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 700,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 601,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 502,
				y = 461
			},
			["tower.default_rally_pos"] = {
				x = 505,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 574,
				y = 604
			},
			["tower.default_rally_pos"] = {
				x = 573,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_mage_1",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 472,
				y = 608
			},
			["tower.default_rally_pos"] = {
				x = 470,
				y = 555
			}
		}
	},
	invalid_path_ranges = {{
		from = 1,
		to = 15,
		path_id = 2
	}},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 5,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 5,
		locked_towers = {"tower_build_archer", "tower_build_barrack", "tower_build_engineer"}
	}},
	unlock_towers = {"tower_sorcerer", "tower_sunray"},
	nav_mesh = {
		{11, 14, 2, 6},
		{1, 10, 3, 5},
		{2, 9, 15, 4},
		{5, 3, 15, 12},
		{6, 2, 4, 8},
		{13, 1, 5, 7},
		{13, 6, 8},
		{7, 5, 12},
		{10, nil, 15, 3},
		{14, nil, 9, 2},
		{nil, 14, 6, 13},
		{8, 4, 71},
		{nil, 11, 6, 7},
		{nil, nil, 10, 1},
		{3, 9, nil, 71},
		[71] = {12, 15}
	},
	required_sounds = {"music_stage09", "JtEffects", "HeroFrost"},
	required_textures = {"go_enemies_ice", "go_stages_ice", "go_stage09", "go_stage09_bg", "go_hero_elora"}
}
