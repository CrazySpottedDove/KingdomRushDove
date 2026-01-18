return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 711,
			y = 128
		}
	}, {
		pos = {
			x = 1100,
			y = 458
		}
	}},
	custom_start_pos = {
		zoom = 1.2,
		pos = {
			x = 600,
			y = 400
		}
	},
	entities_list = {
		{
			template = "controller_stage_26_clone_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_clone_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_fist_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_fist_spawner_hand",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_hulk_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_spawners",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_26_taunts",
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
			["render.sprites[1].name"] = "Stage26_0001",
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
				x = 711,
				y = 128
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 1100,
				y = 458
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 639,
				y = 128
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 786,
				y = 128
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1100,
				y = 413
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1100,
				y = 507
			}
		},
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain6AmbienceSoundForge"}
		},
		{
			template = "decal_stage_26_modes_decos",
			["editor.game_mode"] = 2,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_modes_decos",
			["editor.game_mode"] = 3,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_boss",
			["editor.game_mode"] = 1,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_bubbles",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_clone_spawner",
			pos = {
				x = 438,
				y = 386
			}
		},
		{
			template = "decal_stage_26_clone_spawner",
			pos = {
				x = 742,
				y = 546
			}
		},
		{
			template = "decal_stage_26_fist_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_fist_spawner_light",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_foreground_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_foreground_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_gears_back",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_gears_front",
			pos = {
				x = 214,
				y = 487
			}
		},
		{
			template = "decal_stage_26_hulk_spawner",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_mask_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_mask_5",
			pos = {
				x = 209,
				y = 501
			}
		},
		{
			template = "decal_stage_26_mewtwo_capsules",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_tube_left",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_26_tube_right",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_terrain_6_exodia_arm_2",
			pos = {
				x = 820,
				y = 263
			}
		},
		{
			["editor.r"] = -3.1415926535898,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = -68,
				y = 354
			}
		},
		{
			["editor.r"] = -3.1415926535898,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = -68,
				y = 399
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 160,
			pos = {
				x = 474,
				y = 629
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 160,
			pos = {
				x = 522,
				y = 629
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 555,
				y = 182
			},
			["tower.default_rally_pos"] = {
				x = 556,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 759,
				y = 343
			},
			["tower.default_rally_pos"] = {
				x = 662,
				y = 406
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 434,
				y = 182
			},
			["tower.default_rally_pos"] = {
				x = 443,
				y = 268
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 777,
				y = 193
			},
			["tower.default_rally_pos"] = {
				x = 668,
				y = 197
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 742,
				y = 259
			},
			["tower.default_rally_pos"] = {
				x = 637,
				y = 265
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 553,
				y = 332
			},
			["tower.default_rally_pos"] = {
				x = 641,
				y = 339
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 867,
				y = 343
			},
			["tower.default_rally_pos"] = {
				x = 795,
				y = 425
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 332,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 213,
				y = 369
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 509,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 497,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 509,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 497,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 509,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 497,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 397,
				y = 417
			},
			["tower.default_rally_pos"] = {
				x = 380,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 848,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 863,
				y = 427
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 962,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 961,
				y = 427
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 637,
				y = 527
			},
			["tower.default_rally_pos"] = {
				x = 591,
				y = 474
			}
		}
	},
	ignore_walk_backwards_paths = {5, 8},
	invalid_path_ranges = {{
		from = 1,
		path_id = 6
	}, {
		from = 1,
		path_id = 5
	}, {
		from = 1,
		path_id = 7
	}, {
		from = 1,
		path_id = 8
	}, {
		from = 1,
		path_id = 9
	}},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_flamespitter", "tower_build_dwarf"},
		locked_towers = {
			"tower_build_royal_archers",
			"tower_build_arcane_wizard",
			"tower_build_paladin_covenant",
			"tower_build_tricannon",
			"tower_build_arborean_emissary",
			"tower_build_demon_pit",
			"tower_build_elven_stargazers",
			"tower_build_rocket_gunners",
			"tower_build_necromancer",
			"tower_build_barrel",
			"tower_build_ghost",
			"tower_build_ray"
		}
	}},
	nav_mesh = {
		{2, 2, nil, 3},
		{4, nil, 1, 1},
		{6, 1, 1},
		{7, nil, 2, 5},
		{8, 4, 1, 6},
		{10, 5, 3},
		{11, nil, 4, 4},
		{12, nil, 5, 9},
		{nil, 8, nil, 10},
		{nil, 9, 6},
		{13, nil, 7, 12},
		{nil, 11, 8},
		{
			[3] = 11
		}
	},
	required_exoskeletons = {
		"DLC_Enanos_S4_ActivatorLightDef",
		"DLC_Enanos_S4_BubblesDef",
		"DLC_Enanos_S4_Boss01Def",
		"DLC_Enanos_S4_Boss02Def",
		"DLC_Enanos_S4_CloneActivatorDef",
		"DLC_Enanos_S4_ElevatorDef",
		"DLC_Enanos_S4_ElevatorTubeADef",
		"DLC_Enanos_S4_ElevatorTubeBDef",
		"DLC_Enanos_S4_GearsBackDef",
		"DLC_Enanos_S4_GearsDef",
		"DLC_Enanos_S4_HulkSpawnerDef",
		"DLC_Enanos_S4_HulkSpawnerSyringeDef",
		"DLC_Enanos_S4_EasterEgg_Mewtwo_CanistersDef",
		"DLC_Enanos_S4_EasterEgg_MewtwoDef",
		"DLCstage4_deco_modosDef"
	},
	required_sounds = {"music_stage126", "terrain_6_common", "enemies_terrain_6", "stage_26"},
	required_textures = {"go_enemies_terrain_6", "go_enemies_terrain_4", "go_stage126_bg", "go_stage126", "go_stages_terrain6"}
}
