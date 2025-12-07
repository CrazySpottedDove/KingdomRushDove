-- chunkname: @./kr1/data/levels/level19_data.lua
return {
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_19",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 3,
			template = "decal_defend_point",
			pos = {
				x = 512,
				y = 93
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 221
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 51,
				y = 448
			}
		},
		{
			template = "decal_frozen_mushroom",
			["click_play.achievement_flag"] = {"DEFEAT_MUSHROOM", 1},
			pos = {
				x = 874,
				y = 55
			}
		},
		{
			template = "decal_frozen_mushroom",
			["click_play.achievement_flag"] = {"DEFEAT_MUSHROOM", 2},
			pos = {
				x = 689,
				y = 90
			}
		},
		{
			template = "decal_frozen_mushroom",
			["click_play.achievement_flag"] = {"DEFEAT_MUSHROOM", 4},
			pos = {
				x = 190,
				y = 123
			}
		},
		{
			template = "decal_frozen_mushroom",
			["click_play.achievement_flag"] = {"DEFEAT_MUSHROOM", 8},
			pos = {
				x = 921,
				y = 379
			}
		},
		{
			template = "decal_frozen_mushroom",
			["click_play.achievement_flag"] = {"DEFEAT_MUSHROOM", 16},
			pos = {
				x = 162,
				y = 579
			}
		},
		{
			template = "decal_troll_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_troll_burner_idle",
			pos = {
				x = 949,
				y = 512
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_troll_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_troll_flag_idle",
			pos = {
				x = 976,
				y = 236
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_troll_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_troll_flag_idle",
			pos = {
				x = 946,
				y = 686
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
				x = 969,
				y = 174
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 969,
				y = 614
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 366,
				y = 723
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
				x = 726,
				y = 152
			},
			["tower.default_rally_pos"] = {
				x = 753,
				y = 241
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 329,
				y = 173
			},
			["tower.default_rally_pos"] = {
				x = 305,
				y = 282
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 405,
				y = 224
			},
			["tower.default_rally_pos"] = {
				x = 346,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 844,
				y = 276
			},
			["tower.default_rally_pos"] = {
				x = 804,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 466,
				y = 300
			},
			["tower.default_rally_pos"] = {
				x = 377,
				y = 363
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 750,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 701,
				y = 257
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 228,
				y = 322
			},
			["tower.default_rally_pos"] = {
				x = 232,
				y = 254
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 606,
				y = 412
			},
			["tower.default_rally_pos"] = {
				x = 592,
				y = 351
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 381,
				y = 462
			},
			["tower.default_rally_pos"] = {
				x = 362,
				y = 398
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 828,
				y = 473
			},
			["tower.default_rally_pos"] = {
				x = 826,
				y = 562
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 730,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 440
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 244,
				y = 513
			},
			["tower.default_rally_pos"] = {
				x = 198,
				y = 448
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 478,
				y = 559
			},
			["tower.default_rally_pos"] = {
				x = 528,
				y = 496
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 568,
				y = 594
			},
			["tower.default_rally_pos"] = {
				x = 612,
				y = 542
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 662,
				y = 623
			},
			["tower.default_rally_pos"] = {
				x = 702,
				y = 567
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 6,
			locked_towers = {"tower_build_barrack", "tower_build_mage"}
		}
	},
	nav_mesh = {
		{4, 6, 3},
		{3, 7, 7},
		{1, 5, 2, 2},
		{nil, 10, 6, 1},
		{6, 9, 7, 3},
		{4, 11, 5, 1},
		{5, 12, nil, 2},
		{11, 14, 9, 6},
		{8, 13, 12, 5},
		{nil, 15, 11, 4},
		{10, 15, 8, 6},
		{9, nil, nil, 7},
		{14, nil, 9, 8},
		{15, nil, 13, 8},
		{10, nil, 14, 11}
	},
	required_sounds = {"music_stage19", "MushroomSounds"},
	required_textures = {"go_enemies_ice", "go_enemies_storm", "go_stages_ice", "go_stage19", "go_stage19_bg"}
}
