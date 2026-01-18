return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 549,
			y = 119
		}
	}, {
		pos = {
			x = 757,
			y = 122
		}
	}},
	custom_start_pos = {
		zoom = 2,
		pos = {
			x = 512,
			y = 800
		}
	},
	entities_list = {
		{
			template = "aura_spider_webs_slowness",
			["aura.radius"] = 103,
			pos = {
				x = 804,
				y = 366
			}
		},
		{
			template = "aura_spider_webs_slowness",
			["aura.radius"] = 92,
			pos = {
				x = 388,
				y = 376
			}
		},
		{
			template = "aura_spider_webs_sprint",
			["aura.radius"] = 104,
			pos = {
				x = 804,
				y = 366
			}
		},
		{
			template = "aura_spider_webs_sprint",
			["aura.radius"] = 92,
			pos = {
				x = 388,
				y = 376
			}
		},
		{
			template = "debug_path_renderer",
			["path_debug.background_color"] = {46, 193, 142, 0},
			["path_debug.path_color"] = {168, 199, 169, 0},
			pos = {
				x = -300,
				y = 868
			}
		},
		{
			template = "decal_achievement_lucas_spider",
			pos = {
				x = 2,
				y = 293
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage30_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 550,
				y = 118
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 761,
				y = 118
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 460,
				y = 118
			},
			target_only_paths = {1, 3, 4, 7}
		},
		{
			["editor.flip"] = -1,
			template = "decal_defense_flag",
			pos = {
				x = 630,
				y = 118
			},
			target_only_paths = {1, 3, 4, 7}
		},
		{
			["editor.flip"] = -1,
			template = "decal_defense_flag",
			pos = {
				x = 682,
				y = 118
			},
			target_only_paths = {2, 5, 6, 8}
		},
		{
			["editor.flip"] = -1,
			template = "decal_defense_flag",
			pos = {
				x = 855,
				y = 118
			},
			target_only_paths = {2, 5, 6, 8}
		},
		{
			template = "decal_stage_30_door",
			pos = {
				x = 512,
				y = 410
			}
		},
		{
			["editor.r"] = 0.17453292519944,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 1016,
				y = 329
			}
		},
		{
			["editor.r"] = -3.2986722862693,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = -6,
				y = 383
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 77,
				y = 525
			}
		},
		{
			["editor.r"] = 1.6057029118348,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 128,
				y = 525
			}
		},
		{
			["editor.r"] = 1.221730476396,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 1002,
				y = 535
			}
		},
		{
			["editor.r"] = 0.97738438111679,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 956,
				y = 560
			}
		},
		{
			template = "mask_stage_30_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "mask_stage_30_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "mask_stage_30_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "mask_stage_30_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "mask_stage_30_5",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 373,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 442,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 373,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 442,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "41",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "41",
			pos = {
				x = 373,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 442,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "50",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "50",
			pos = {
				x = 657,
				y = 186
			},
			["tower.default_rally_pos"] = {
				x = 523,
				y = 184
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 630,
				y = 202
			},
			["tower.default_rally_pos"] = {
				x = 523,
				y = 184
			}
		},
		{
			["tower.holder_id"] = "29",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "29",
			pos = {
				x = 710,
				y = 223
			},
			["tower.default_rally_pos"] = {
				x = 823,
				y = 175
			}
		},
		{
			["tower.holder_id"] = "49",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "49",
			pos = {
				x = 972,
				y = 235
			},
			["tower.default_rally_pos"] = {
				x = 863,
				y = 235
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 770,
				y = 238
			},
			["tower.default_rally_pos"] = {
				x = 820,
				y = 183
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 972,
				y = 250
			},
			["tower.default_rally_pos"] = {
				x = 863,
				y = 235
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "28",
			pos = {
				x = 972,
				y = 250
			},
			["tower.default_rally_pos"] = {
				x = 863,
				y = 235
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 560,
				y = 259
			},
			["tower.default_rally_pos"] = {
				x = 479,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 560,
				y = 259
			},
			["tower.default_rally_pos"] = {
				x = 479,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "31",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "31",
			pos = {
				x = 715,
				y = 289
			},
			["tower.default_rally_pos"] = {
				x = 804,
				y = 365
			}
		},
		{
			["tower.holder_id"] = "48",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "48",
			pos = {
				x = 714,
				y = 293
			},
			["tower.default_rally_pos"] = {
				x = 800,
				y = 370
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 311,
				y = 314
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 311,
				y = 314
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "42",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "42",
			pos = {
				x = 311,
				y = 314
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 625,
				y = 336
			},
			["tower.default_rally_pos"] = {
				x = 673,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "30",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "30",
			pos = {
				x = 625,
				y = 336
			},
			["tower.default_rally_pos"] = {
				x = 673,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 188,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 223,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "23",
			pos = {
				x = 188,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 223,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "43",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "43",
			pos = {
				x = 560,
				y = 343
			},
			["tower.default_rally_pos"] = {
				x = 537,
				y = 440
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 520,
				y = 355
			},
			["tower.default_rally_pos"] = {
				x = 466,
				y = 422
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 520,
				y = 355
			},
			["tower.default_rally_pos"] = {
				x = 466,
				y = 422
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 918,
				y = 356
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "27",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "27",
			pos = {
				x = 918,
				y = 356
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "47",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "47",
			pos = {
				x = 918,
				y = 356
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 42,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 139,
				y = 460
			}
		},
		{
			["tower.holder_id"] = "44",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "44",
			pos = {
				x = 42,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 139,
				y = 460
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 742,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 786,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 742,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 786,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "46",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "46",
			pos = {
				x = 742,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 786,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 377,
				y = 470
			},
			["tower.default_rally_pos"] = {
				x = 341,
				y = 409
			}
		},
		{
			["tower.holder_id"] = "25",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "25",
			pos = {
				x = 377,
				y = 470
			},
			["tower.default_rally_pos"] = {
				x = 341,
				y = 409
			}
		},
		{
			["tower.holder_id"] = "45",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "45",
			pos = {
				x = 377,
				y = 470
			},
			["tower.default_rally_pos"] = {
				x = 341,
				y = 409
			}
		}
	},
	ignore_walk_backwards_paths = {},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {
		nav_mesh = {
			[21] = {24, 22},
			[22] = {32, 25, 23, 21},
			[23] = {22, 25, nil, 22},
			[24] = {29, 32, 21},
			[25] = {26, nil, 23, 32},
			[26] = {27, nil, 25, 31},
			[27] = {nil, 26, 31, 28},
			[28] = {nil, 27, 29},
			[29] = {28, 31, 24},
			[30] = {31, 26, 32, 24},
			[31] = {27, 26, 30, 29},
			[32] = {30, 25, 22, 24}
		}
	}, {
		available_towers = {"tower_build_dark_elf", "tower_build_paladin_covenant"},
		locked_towers = {
			"tower_build_sand",
			"tower_build_ballista",
			"tower_build_arborean_emissary",
			"tower_build_tricannon",
			"tower_build_elven_stargazers",
			"tower_build_rocket_gunners",
			"tower_build_arcane_wizard",
			"tower_build_barrel",
			"tower_build_necromancer",
			"tower_build_ray",
			"tower_build_demon_pit",
			"tower_build_ghost"
		},
		nav_mesh = {
			[41] = {50, 42},
			[42] = {43, 45, 44, 41},
			[43] = {48, 45, 42, 50},
			[44] = {45, nil, nil, 42},
			[45] = {46, nil, 44, 42},
			[46] = {47, nil, 45, 48},
			[47] = {nil, 46, 48, 49},
			[48] = {47, 46, 43, 50},
			[49] = {nil, 47, 50},
			[50] = {49, 48, 41}
		}
	}},
	nav_mesh = {
		{13, 2},
		{11, 5, 3, 1},
		{2, 5, 4, 2},
		{5, nil, nil, 3},
		{6, nil, 4, 11},
		{7, nil, 5, 9},
		{nil, 6, 10, 8},
		{nil, 7, 9},
		{8, 10, 13},
		{9, 6, 11, 12},
		{10, 5, 2, 12},
		{9, 11, 1, 13},
		{9, 12, 1}
	},
	required_exoskeletons = {"spider_queen_animationsDef", "spider_queen_animations_stunDef", "spiderqueen_queen_assetDef", "spiderqueen_smokeDef", "spiderqueen_spider_jumpDef", "spiderqueen_spider_queenDef", "stage_30_spider_doorDef"},
	required_sounds = {"music_stage130", "enemies_terrain_spiders", "stage_30", "tower_sparking_geode"},
	required_textures = {"go_stage130_bg", "go_stage130", "go_enemies_terrain_7"},
	scale_required_textures = {"go_towers_sparking_geode"}
}
