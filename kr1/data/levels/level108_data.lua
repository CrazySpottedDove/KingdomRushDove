return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 519,
			y = 92
		}
	}, {
		pos = {
			x = 702,
			y = 92
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 512,
			y = 275
		}
	},
	entities_list = {
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain2AmbienceSoundWaterDrop", "Terrain2AmbienceSoundWind"}
		},
		{
			template = "controller_stage_08_elf_rescue",
			["editor.game_mode"] = 0,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			template = "controller_stage_08_gem_baskets",
			pos = {
				x = 829,
				y = 120
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
			["render.sprites[1].name"] = "Stage08_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 6,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 15,
			pos = {
				x = 519,
				y = 92
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 6,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 15,
			pos = {
				x = 702,
				y = 92
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 453,
				y = 92
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 588,
				y = 92
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 636,
				y = 92
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 766,
				y = 92
			}
		},
		{
			template = "decal_stage_08_fire",
			pos = {
				x = -189,
				y = 768
			}
		},
		{
			template = "decal_stage_08_gem_basket_big_clickable",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_08_gem_basket_small_clickable",
			pos = {
				x = 890,
				y = 318
			}
		},
		{
			template = "decal_stage_08_gem_basket_third_clickable",
			pos = {
				x = 508,
				y = 369
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 968,
				y = 10
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 85,
				y = 100
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = -62,
				y = 262
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = -153,
				y = 537
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 912,
				y = -28
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 124,
				y = -23
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = -109,
				y = -16
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = -202,
				y = 170
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = -218,
				y = 502
			}
		},
		{
			["editor.r"] = 4.7176249681407,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 282,
				y = 162
			}
		},
		{
			["editor.r"] = 0.35430183815487,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1070,
				y = 419
			}
		},
		{
			["editor.r"] = 0.31939525311498,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1070,
				y = 461.5
			}
		},
		{
			["editor.r"] = 3.1468286413458,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = -60,
				y = 472
			}
		},
		{
			["editor.r"] = 1.5760323145509,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 309,
				y = 716
			}
		},
		{
			["editor.r"] = 1.553343034275,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 814,
				y = 716
			}
		},
		{
			["editor.r"] = 1.553343034275,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 868,
				y = 716
			}
		},
		{
			template = "stage_08_mask_1",
			pos = {
				x = 512,
				y = 618
			}
		},
		{
			template = "stage_08_mask_2",
			pos = {
				x = 512,
				y = 619
			}
		},
		{
			template = "stage_08_mask_3",
			pos = {
				x = 512,
				y = 569
			}
		},
		{
			template = "stage_08_mask_4",
			pos = {
				x = 512,
				y = 634
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 602,
				y = 300
			},
			["tower.default_rally_pos"] = {
				x = 522,
				y = 249
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 325,
				y = 360
			},
			["tower.default_rally_pos"] = {
				x = 235,
				y = 330
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 880,
				y = 436
			},
			["tower.default_rally_pos"] = {
				x = 814,
				y = 388
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 427,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 395,
				y = 297
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 620,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 204.5
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 188,
				y = 236.5
			},
			["tower.default_rally_pos"] = {
				x = 276,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 764,
				y = 300
			},
			["tower.default_rally_pos"] = {
				x = 827,
				y = 260
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 123,
				y = 334.5
			},
			["tower.default_rally_pos"] = {
				x = 230,
				y = 370.5
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 428,
				y = 368
			},
			["tower.default_rally_pos"] = {
				x = 364,
				y = 453
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 532,
				y = 370
			},
			["tower.default_rally_pos"] = {
				x = 482,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 956,
				y = 372
			},
			["tower.default_rally_pos"] = {
				x = 853,
				y = 350
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 126,
				y = 428
			},
			["tower.default_rally_pos"] = {
				x = 228,
				y = 433.5
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 720,
				y = 445
			},
			["tower.default_rally_pos"] = {
				x = 649,
				y = 396
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 804,
				y = 470
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 542
			}
		}
	},
	ignore_walk_backwards_paths = {2, 3, 4, 7, 8},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		available_towers = {"tower_build_tricannon", "tower_build_paladin_covenant"},
		locked_towers = {"tower_build_royal_archers", "tower_build_arcane_wizard", "tower_build_arborean_emissary", "tower_build_demon_pit", "tower_build_elven_stargazers", "tower_build_ballista"}
	}},
	nav_mesh = {
		{4, nil, nil, 2},
		{4, 1, nil, 3},
		{6, 2},
		{5, nil, 2, 6},
		{7, nil, 4, 6},
		{9, 5, 3},
		{10, nil, 5, 8},
		{11, 7, 6, 9},
		{11, 8, 6},
		{12, nil, 7, 11},
		{14, 10, 8, 9},
		{13, nil, 10, 11},
		{14, nil, 12, 11},
		{nil, 13, 11}
	},
	required_exoskeletons = {"ChainDef", "ElfSlaveDef", "Abomination2Def", "fire_stage_8Def", "stage_8_gems_basket_bigDef", "stage_8_gems_basket_smallDef", "stage_8_gems_basket_thirdDef", "t2_dustDef", "t2_smokeDef"},
	required_sounds = {"stage_08", "music_stage108", "enemies_terrain_2", "terrain_2_common"},
	required_textures = {"go_enemies_terrain_2", "go_stage108_bg", "go_stage108", "go_stages_terrain2"}
}
