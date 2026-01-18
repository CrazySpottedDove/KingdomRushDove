return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 30,
			y = 424
		}
	}, {
		pos = {
			x = -5,
			y = 277
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 430,
			y = 384
		}
	},
	entities_list = {
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain6AmbienceSoundWindRocks"}
		},
		{
			template = "controller_stage_25_torso",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_25_tunnel_glow",
			pos = {
				x = 712,
				y = 470
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
			["render.sprites[1].name"] = "Stage25_0001",
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
				x = -5,
				y = 277
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 30,
				y = 424
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -15,
				y = 217
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 5,
				y = 330
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 20,
				y = 366
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 40,
				y = 477
			}
		},
		{
			template = "decal_stage_25_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_mask_2_glow",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_mask_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_solid_snake",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_torso",
			["editor.game_mode"] = 1,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_torso_modes",
			["editor.game_mode"] = 2,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_25_torso_modes",
			["editor.game_mode"] = 3,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_terrain_6_exodia_leg_2",
			pos = {
				x = 1032,
				y = 518
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 770,
				y = 173
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 819,
				y = 173
			}
		},
		{
			["editor.r"] = 3.3861802251067e-15,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 180,
			pos = {
				x = 1066,
				y = 254
			}
		},
		{
			["editor.r"] = 0.017453292519947,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 180,
			pos = {
				x = 1066,
				y = 299
			}
		},
		{
			["editor.r"] = 3.4069969068184e-15,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 180,
			pos = {
				x = 1066,
				y = 434
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 23,
			template = "tower_holder_blocked_terrain_6",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 673,
				y = 184
			},
			["tower.default_rally_pos"] = {
				x = 673,
				y = 268
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 23,
			template = "tower_holder_blocked_terrain_6",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 947,
				y = 342
			},
			["tower.default_rally_pos"] = {
				x = 935,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_blocked_terrain_6_2",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 103,
				y = 192
			},
			["tower.default_rally_pos"] = {
				x = 120,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 965,
				y = 183
			},
			["tower.default_rally_pos"] = {
				x = 875,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 965,
				y = 183
			},
			["tower.default_rally_pos"] = {
				x = 875,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 965,
				y = 183
			},
			["tower.default_rally_pos"] = {
				x = 875,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 673,
				y = 184
			},
			["tower.default_rally_pos"] = {
				x = 673,
				y = 268
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 673,
				y = 184
			},
			["tower.default_rally_pos"] = {
				x = 673,
				y = 268
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 817,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 778,
				y = 217
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 947,
				y = 342
			},
			["tower.default_rally_pos"] = {
				x = 935,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 947,
				y = 342
			},
			["tower.default_rally_pos"] = {
				x = 935,
				y = 269
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 825,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 836,
				y = 450
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 935,
				y = 500
			},
			["tower.default_rally_pos"] = {
				x = 920,
				y = 435
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 935,
				y = 500
			},
			["tower.default_rally_pos"] = {
				x = 920,
				y = 435
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 935,
				y = 500
			},
			["tower.default_rally_pos"] = {
				x = 920,
				y = 435
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 406,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 322,
				y = 230
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 103,
				y = 192
			},
			["tower.default_rally_pos"] = {
				x = 120,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 103,
				y = 192
			},
			["tower.default_rally_pos"] = {
				x = 120,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 260,
				y = 275
			},
			["tower.default_rally_pos"] = {
				x = 358,
				y = 308
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 260,
				y = 275
			},
			["tower.default_rally_pos"] = {
				x = 358,
				y = 308
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 260,
				y = 275
			},
			["tower.default_rally_pos"] = {
				x = 358,
				y = 308
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 195,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 285,
				y = 375
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 97,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 201,
				y = 419
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 141,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 427
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 141,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 427
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 24,
			template = "tower_holder_sea_of_trees_9",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 141,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 121,
				y = 427
			}
		},
		{
			["tunnel.name"] = "1",
			["tunnel.place_pi"] = 6,
			template = "tunnel_KR5",
			["tunnel.pick_pi"] = 1,
			pos = {
				x = 707,
				y = 469
			}
		}
	},
	ignore_walk_backwards_paths = {4, 5},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_arborean_emissary", "tower_build_elven_stargazers"},
		locked_towers = {
			"tower_build_royal_archers",
			"tower_build_arcane_wizard",
			"tower_build_paladin_covenant",
			"tower_build_tricannon",
			"tower_build_demon_pit",
			"tower_build_necromancer",
			"tower_build_barrel",
			"tower_build_ghost",
			"tower_build_flamespitter",
			"tower_build_ray",
			"tower_build_rocket_gunners"
		}
	}},
	nav_mesh = {
		{4, 3, nil, 2},
		{6, 1},
		{4, nil, nil, 1},
		{5, 3, 1, 5},
		{6, 4, 4},
		{7, 5, 2},
		{8, nil, 6},
		{12, 9, 7, 7},
		{11, 10, nil, 8},
		{
			[3] = 9,
			[4] = 11
		},
		{nil, 10, 9, 12},
		{nil, 11, 8}
	},
	required_exoskeletons = {"DLC_stage3_dwarf_inDef", "DLC_stage3_dwarf_machinistDef", "DLC_stage3_robot_arm_decalsDef", "DLC_stage3_robot_armDef", "DLC_Enanos_S3_EasterEgg_SolidSnakeDef", "DLC_stage3_dwarf_machinist_modesDef"},
	required_sounds = {"music_stage125", "terrain_6_common", "enemies_terrain_6", "stage_25", "tower_rocket_gunners"},
	required_textures = {"go_enemies_terrain_6", "go_stage125_bg", "go_stage125", "go_stages_terrain6"},
	scale_required_textures = {"go_towers_rocket_gunners"}
}
