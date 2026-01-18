return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 526,
			y = 71
		}
	}, {
		pos = {
			x = 710,
			y = 76
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 600,
			y = 350
		}
	},
	entities_list = {
		{
			template = "controller_stage_27_cannon_L",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_27_cannon_R",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_27_head",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_27_platform",
			["editor.game_mode"] = 1,
			pos = {
				x = 512,
				y = 384
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
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage27_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 528,
				y = 71
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 711,
				y = 72
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 465,
				y = 71
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 590,
				y = 71
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 653,
				y = 71
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 767,
				y = 71
			}
		},
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain6AmbienceSoundWindRocks"}
		},
		{
			template = "decal_stage_27_cannon_left",
			pos = {
				x = 143,
				y = 437
			}
		},
		{
			template = "decal_stage_27_cannon_right",
			pos = {
				x = 1020,
				y = 417
			}
		},
		{
			template = "decal_stage_27_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_mask_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_mask_5",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_beam",
			["editor.game_mode"] = 2,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_beam",
			["editor.game_mode"] = 3,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_platform",
			["editor.game_mode"] = 1,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_platform_bars",
			["editor.game_mode"] = 1,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_head",
			["editor.game_mode"] = 2,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_head",
			["editor.game_mode"] = 3,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_smoke_back",
			["editor.game_mode"] = 2,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_smoke_back",
			["editor.game_mode"] = 3,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_smoke_front",
			["editor.game_mode"] = 2,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_smoke_front",
			["editor.game_mode"] = 3,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_sparks",
			["editor.game_mode"] = 2,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_sparks",
			["editor.game_mode"] = 3,
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_27_snow",
			pos = {
				x = 324,
				y = 384
			}
		},
		{
			template = "decal_stage_27_snow",
			pos = {
				x = 1024,
				y = 384
			}
		},
		{
			template = "decal_stage_27_modes_decos",
			["editor.game_mode"] = 2,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_27_modes_decos",
			["editor.game_mode"] = 3,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_terrain_6_exodia_head",
			pos = {
				x = 1060,
				y = 368
			}
		},
		{
			["editor.r"] = -4.1078251911131e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 160,
			pos = {
				x = 1088,
				y = 279
			}
		},
		{
			["editor.r"] = -3.4557519189488,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = -61,
				y = 391
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 615,
				y = 123
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 155
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 615,
				y = 123
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 155
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 615,
				y = 123
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 155
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 149
			},
			["tower.default_rally_pos"] = {
				x = 469,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 149
			},
			["tower.default_rally_pos"] = {
				x = 469,
				y = 229
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 149
			},
			["tower.default_rally_pos"] = {
				x = 469,
				y = 229
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 812,
				y = 177
			},
			["tower.default_rally_pos"] = {
				x = 736,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 812,
				y = 177
			},
			["tower.default_rally_pos"] = {
				x = 736,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 812,
				y = 177
			},
			["tower.default_rally_pos"] = {
				x = 736,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 614,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 521,
				y = 185
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 614,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 521,
				y = 185
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 614,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 521,
				y = 185
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 315,
				y = 236
			},
			["tower.default_rally_pos"] = {
				x = 316,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 315,
				y = 236
			},
			["tower.default_rally_pos"] = {
				x = 316,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 315,
				y = 236
			},
			["tower.default_rally_pos"] = {
				x = 316,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 203,
				y = 237
			},
			["tower.default_rally_pos"] = {
				x = 213,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 203,
				y = 237
			},
			["tower.default_rally_pos"] = {
				x = 213,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 203,
				y = 237
			},
			["tower.default_rally_pos"] = {
				x = 213,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 863,
				y = 248
			},
			["tower.default_rally_pos"] = {
				x = 890,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 863,
				y = 248
			},
			["tower.default_rally_pos"] = {
				x = 890,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 863,
				y = 248
			},
			["tower.default_rally_pos"] = {
				x = 890,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 968,
				y = 251
			},
			["tower.default_rally_pos"] = {
				x = 980,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 968,
				y = 251
			},
			["tower.default_rally_pos"] = {
				x = 980,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 968,
				y = 251
			},
			["tower.default_rally_pos"] = {
				x = 980,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 89,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 345
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 89,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 345
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 89,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 345
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 495,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 472,
				y = 391
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 495,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 472,
				y = 391
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 495,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 472,
				y = 391
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 689,
				y = 311
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 689,
				y = 311
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 689,
				y = 311
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 387
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 311,
				y = 375
			},
			["tower.default_rally_pos"] = {
				x = 393,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 311,
				y = 375
			},
			["tower.default_rally_pos"] = {
				x = 393,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 311,
				y = 375
			},
			["tower.default_rally_pos"] = {
				x = 393,
				y = 347
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 851,
				y = 391
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 331
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 851,
				y = 391
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 331
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 851,
				y = 391
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 331
			}
		}
	},
	ignore_walk_backwards_paths = {3, 4, 5, 6, 7, 8, 9},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_tricannon", "tower_build_sand"},
		locked_towers = {
			"tower_build_royal_archers",
			"tower_build_arcane_wizard",
			"tower_build_paladin_covenant",
			"tower_build_arborean_emissary",
			"tower_build_demon_pit",
			"tower_build_elven_stargazers",
			"tower_build_rocket_gunners",
			"tower_build_barrel",
			"tower_build_ghost",
			"tower_build_ray",
			"tower_build_hermit_toad"
		}
	}},
	nav_mesh = {
		{2},
		{3, nil, 1},
		{5, 4, 2},
		{6, nil, nil, 3},
		{8, 6, 3},
		{7, nil, 4, 5},
		{9, nil, 6},
		{10, 7, 5},
		{11, nil, 7},
		{12, 12, 8},
		{
			[3] = 9,
			[4] = 12
		},
		{13, 11, 10, 10},
		{
			[3] = 12
		}
	},
	required_exoskeletons = {
		"dclenanos_stage05_platform_barsDef",
		"dclenanos_stage05_platformDef",
		"dclenanos_stage05_platform_introDef",
		"dclenanos_stage05_snowfallDef",
		"dlcenanos_stage05_cannonDef",
		"dlcenanos_stage05_cannon_explosionDef",
		"dclenanos_head_goblinsDef",
		"dclenanos_stage05_headrayDef",
		"dclenanos_stage05_headplasmaDef",
		"dclenanos_stage05_headplasmabgDef",
		"dclenanos_stage05_headDef",
		"dclenanos_stage05_grymmissileDef",
		"dclenanos_stage05_grymmissiledecalDef",
		"dclenanos_stage05_grymdebree2Def",
		"dclenanos_stage05_grymdebree1Def",
		"dclenanos_stage05_grymbossflytrailDef",
		"dclenanos_stage05_grymbossflyDef",
		"dclenanos_stage05_grymbossDef",
		"dclenanos_stage05_grymbossdecalDef",
		"dclenanos_stage05_HeadSmokeBackDef",
		"dclenanos_stage05_HeadSmokeFrontDef",
		"dclenanos_stage05_HeadSparksDef",
		"dclenanos_stage05_ScrapDef",
		"dclenanos_stage05_ScrapProjectileDef",
		"dclenanos_stage05_ScrapProjectileFXDef",
		"dclenanos_stage05_ScrapProjectileHitFXDef",
		"dclenanos_stage05_ScrapProjectileTrailDef",
		"DLCstage5_deco_modosDef",
		"DLCstage5_enanos_vigaDef"
	},
	required_sounds = {"music_stage127", "terrain_6_common", "enemies_terrain_6", "stage_27", "tower_necromancer"},
	required_textures = {"go_enemies_terrain_6", "go_enemies_terrain_4", "go_stage127_bg", "go_stage127", "go_stages_terrain6"},
	scale_required_textures = {"go_towers_necromancer"}
}
