-- chunkname: @./kr1/data/levels/level03_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_boat_big",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_boat_big_idle",
			pos = {
				x = 345,
				y = 77
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_boat_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_boat_small_idle",
			pos = {
				x = 327,
				y = 65
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 53,
				y = 301
			}
		},
		{
			template = "decal_fish",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 76,
				y = 105
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_fish",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 207,
				y = 106
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_mill_big",
			pos = {
				x = 814,
				y = 683
			}
		},
		{
			template = "decal_mill_small",
			pos = {
				x = 865,
				y = 698
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 648,
				y = 60
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 664,
				y = 93
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 620,
				y = 103
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 659,
				y = 668
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 689,
				y = 67
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 599,
				y = 76
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 682,
				y = 655
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = -115,
				y = 23
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 11,
				y = 35
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 2.0816681711722e-17,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 377,
				y = 43
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 181,
				y = 45
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 82,
				y = 57
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = -29,
				y = 59
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 33,
				y = 90
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 226,
				y = 93
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 91,
				y = 99
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_spark",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_spark_play",
			pos = {
				x = 163,
				y = 102
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0.17453292519941,
			template = "decal_water_wave",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = -157,
				y = 34
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0.71383966406566,
			template = "decal_water_wave",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = -47,
				y = 88
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_water_wave",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 118,
				y = 129
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0,
			template = "decal_water_wave",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 213,
				y = 129
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 267,
			pos = {
				x = 991,
				y = 404
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 261,
			pos = {
				x = 994,
				y = 575
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 423,
				y = 153
			},
			["tower.default_rally_pos"] = {
				x = 458,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 798,
				y = 164
			},
			["tower.default_rally_pos"] = {
				x = 728,
				y = 244
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 325,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 329,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 619,
				y = 258
			},
			["tower.default_rally_pos"] = {
				x = 618,
				y = 207
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 517,
				y = 288
			},
			["tower.default_rally_pos"] = {
				x = 521,
				y = 229
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 410,
				y = 331
			},
			["tower.default_rally_pos"] = {
				x = 329,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 655,
				y = 395
			},
			["tower.default_rally_pos"] = {
				x = 655,
				y = 348
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 487,
				y = 496
			},
			["tower.default_rally_pos"] = {
				x = 532,
				y = 439
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 595,
				y = 521
			},
			["tower.default_rally_pos"] = {
				x = 596,
				y = 471
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 710,
				y = 523
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 469
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 404,
				y = 615
			},
			["tower.default_rally_pos"] = {
				x = 408,
				y = 557
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 500,
				y = 638
			},
			["tower.default_rally_pos"] = {
				x = 502,
				y = 593
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {"tower_archer_3", "tower_barrack_3", "tower_mage_3", "tower_engineer_3"}
	}, {
		locked_hero = true,
		max_upgrade_level = 3,
		locked_towers = {"tower_archer_3", "tower_barrack_3", "tower_mage_3", "tower_engineer_3"}
	}, {
		locked_hero = true,
		max_upgrade_level = 3,
		locked_towers = {"tower_archer_3", "tower_barrack_3", "tower_mage_3", "tower_build_engineer"}
	}},
	nav_mesh = {
		{nil, 8, 3, 4},
		{3, 8, 9, 6},
		{1, 8, 2, 4},
		{nil, 3, 6, 5},
		{7, 4, 6, 11},
		{5, 2, 12, 11},
		{nil, 4, 5},
		{3, nil, 9, 2},
		{8, nil, nil, 2},
		{11, 12, nil, 11},
		{5, 6, 10},
		{6, 2, nil, 10}
	},
	required_sounds = {"music_stage03"},
	required_textures = {"go_enemies_grass", "go_stages_grass", "go_stage03", "go_stage03_bg"}
}
