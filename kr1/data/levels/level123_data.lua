return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 673,
			y = 107
		}
	}, {
		pos = {
			x = -68,
			y = 272
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 400,
			y = 300
		}
	},
	entities_list = {
		{
			["editor.path"] = 8,
			template = "controller_darksteel_guardian",
			["editor.game_mode"] = 1,
			["editor.flip_x"] = 0,
			pos = {
				x = 167,
				y = 528
			}
		},
		{
			["editor.path"] = 9,
			template = "controller_darksteel_guardian",
			["editor.game_mode"] = 1,
			["editor.flip_x"] = 1,
			pos = {
				x = 373,
				y = 533
			}
		},
		{
			template = "controller_stage_23_roboboots",
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
			["render.sprites[1].name"] = "Stage23_0001",
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
				x = 673,
				y = 107
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = -68,
				y = 272
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 741,
				y = 93
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 600,
				y = 104
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 209
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 331
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
			template = "decal_stage_23_crane",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_mask_5",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_mask_6",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_rock",
			pos = {
				x = 480,
				y = 500
			}
		},
		{
			template = "decal_stage_23_snow",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_23_torches",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_terrain_6_exodia_leg",
			pos = {
				x = 459,
				y = 146
			}
		},
		{
			["editor.r"] = 0.17453292519944,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = 957,
				y = 469
			}
		},
		{
			["editor.r"] = 0.19198621771938,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = 957,
				y = 515
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = 262,
				y = 612
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 75,
				y = 171
			},
			["tower.default_rally_pos"] = {
				x = 103,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 597,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 610,
				y = 268
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 794,
				y = 191
			},
			["tower.default_rally_pos"] = {
				x = 698,
				y = 218
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 308,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 258,
				y = 295
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 426,
				y = 257
			},
			["tower.default_rally_pos"] = {
				x = 405,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 131,
				y = 317
			},
			["tower.default_rally_pos"] = {
				x = 188,
				y = 257
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 707,
				y = 336
			},
			["tower.default_rally_pos"] = {
				x = 685,
				y = 416
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 603,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 586,
				y = 416
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 855,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 802,
				y = 433
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 230,
				y = 365
			},
			["tower.default_rally_pos"] = {
				x = 331,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 424,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 492,
				y = 368
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 424,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 492,
				y = 368
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 424,
				y = 415
			},
			["tower.default_rally_pos"] = {
				x = 492,
				y = 368
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 23,
			template = "tower_holder_sea_of_trees_8",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 379,
				y = 473
			},
			["tower.default_rally_pos"] = {
				x = 291,
				y = 449
			}
		}
	},
	ignore_walk_backwards_paths = {4, 5, 6, 7, 8, 9},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_arcane_wizard", "tower_build_ballista"},
		locked_towers = {
			"tower_build_royal_archers",
			"tower_build_paladin_covenant",
			"tower_build_tricannon",
			"tower_build_arborean_emissary",
			"tower_build_demon_pit",
			"tower_build_elven_stargazers",
			"tower_build_rocket_gunners",
			"tower_build_necromancer",
			"tower_build_barrel",
			"tower_build_ghost",
			"tower_build_flamespitter",
			"tower_build_ray"
		}
	}},
	nav_mesh = {
		{4, 2},
		{3, nil, nil, 1},
		{6, nil, 2, 4},
		{7, 3, 1},
		{
			[4] = 6
		},
		{9, 5, 3, 7},
		{8, 6, 4},
		{11, 9, 7},
		{10, nil, 6, 8},
		{12, nil, 9},
		{nil, 12, 8},
		{
			[3] = 10,
			[4] = 11
		}
	},
	required_exoskeletons = {"dclenanos_stage01_snowfallDef", "dclenanos_stage01_torchesDef", "dclenanos_stage01_robobootDef", "dclenanos_stage01_roboboot2Def", "dclenanos_stage01_roboboot_topDef", "dclenanos_stage01_roboboot2_topDef", "DLCenanos_stage1_deco_gruaDef"},
	required_sounds = {"music_stage123", "terrain_6_common", "enemies_terrain_6", "stage_23", "tower_paladin_covenant"},
	required_textures = {"go_enemies_terrain_6", "go_stage123_bg", "go_stage123", "go_stages_terrain6"},
	scale_required_textures = {"go_towers_paladin_covenant"}
}
