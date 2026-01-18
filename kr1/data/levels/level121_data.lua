return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 1100,
			y = 257
		}
	}, {
		pos = {
			x = 1092,
			y = 569
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 671,
			y = 395
		}
	},
	entities_list = {
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain3AmbienceSoundGutural"}
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
			template = "decal_achievement_stage_21_croc_boat",
			pos = {
				x = 970,
				y = 166
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage21_0001",
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
				x = 1099,
				y = 257
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 1094,
				y = 567
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 436,
				y = 683
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1100,
				y = 181
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1095,
				y = 310
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1092,
				y = 489
			}
		},
		{
			["editor.flip"] = 1,
			template = "decal_defense_flag",
			pos = {
				x = 1091,
				y = 628
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 368,
				y = 679
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 506,
				y = 680
			}
		},
		{
			template = "decal_stage_21_bubbles",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["delayed_play.min_delay"] = 15,
			["render.sprites[1].r"] = 0,
			template = "decal_stage_21_dragonfly_1",
			["delayed_play.max_delay"] = 35,
			pos = {
				x = 512,
				y = 390
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 15,
			["render.sprites[1].r"] = 0,
			template = "decal_stage_21_dragonfly_2",
			["delayed_play.max_delay"] = 35,
			pos = {
				x = 512,
				y = 334
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_stage_21_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_21_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_21_mask_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_21_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_21_mask_lianas",
			pos = {
				x = -150,
				y = 739
			}
		},
		{
			template = "decal_stage_21_mask_lianas",
			["render.sprites[1].flip_x"] = true,
			pos = {
				x = 1153,
				y = 739
			}
		},
		{
			["delayed_play.min_delay"] = 15,
			["render.sprites[1].r"] = 0,
			template = "decal_stage_21_particlesLeft",
			["delayed_play.max_delay"] = 35,
			pos = {
				x = 512,
				y = 334
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 105,
			pos = {
				x = 520,
				y = 63
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 105,
			pos = {
				x = 579,
				y = 63
			}
		},
		{
			["editor.r"] = -3.1241393610699,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = -79,
				y = 170
			}
		},
		{
			["editor.r"] = -3.1066860685499,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = -79,
				y = 212
			}
		},
		{
			["editor.r"] = -3.1066860685499,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = -79,
				y = 255
			}
		},
		{
			["editor.r"] = -3.1415926535898,
			["editor.path_id"] = 8,
			template = "editor_wave_flag",
			["editor.len"] = 67,
			pos = {
				x = -10,
				y = 371
			}
		},
		{
			["editor.r"] = -3.1241393610699,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 67,
			pos = {
				x = -10,
				y = 410
			}
		},
		{
			["editor.r"] = -3.1590459461097,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = -13,
				y = 516
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 762,
				y = 203
			},
			["tower.default_rally_pos"] = {
				x = 758,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 895,
				y = 243
			},
			["tower.default_rally_pos"] = {
				x = 893,
				y = 313
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 407,
				y = 244
			},
			["tower.default_rally_pos"] = {
				x = 368,
				y = 341
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 63,
				y = 270
			},
			["tower.default_rally_pos"] = {
				x = 44,
				y = 212
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 768,
				y = 328
			},
			["tower.default_rally_pos"] = {
				x = 822,
				y = 290
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 252,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 325,
				y = 307
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 968,
				y = 371
			},
			["tower.default_rally_pos"] = {
				x = 971,
				y = 299
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 786,
				y = 475
			},
			["tower.default_rally_pos"] = {
				x = 718,
				y = 525
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 596,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 656,
				y = 488
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 301,
				y = 539
			},
			["tower.default_rally_pos"] = {
				x = 248,
				y = 601
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 495,
				y = 564
			},
			["tower.default_rally_pos"] = {
				x = 398,
				y = 599
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 958,
				y = 564
			},
			["tower.default_rally_pos"] = {
				x = 940,
				y = 651
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 22,
			template = "tower_holder_sea_of_trees_7",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 110,
				y = 576
			},
			["tower.default_rally_pos"] = {
				x = 137,
				y = 528
			}
		}
	},
	ignore_walk_backwards_paths = {},
	invalid_path_ranges = {
		{
			from = 43,
			to = 69,
			path_id = 2
		},
		{
			from = 83,
			to = 102,
			path_id = 2
		},
		{
			from = 43,
			to = 69,
			path_id = 3
		},
		{
			from = 83,
			to = 123,
			path_id = 3
		},
		{
			from = 43,
			to = 69,
			path_id = 4
		},
		{
			from = 84,
			to = 131,
			path_id = 4
		},
		{
			path_id = 5,
			to = 78
		},
		{
			path_id = 6,
			to = 56
		},
		{
			path_id = 7,
			to = 60
		},
		{
			from = 74,
			to = 112,
			path_id = 7
		},
		{
			path_id = 8,
			to = 59
		},
		{
			from = 74,
			to = 121,
			path_id = 8
		}
	},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_demon_pit", "tower_build_hermit_toad"},
		locked_towers = {"tower_build_arcane_wizard", "tower_build_paladin_covenant", "tower_build_tricannon", "tower_build_barrel", "tower_build_arborean_emissary", "tower_build_elven_stargazers", "tower_build_rocket_gunners", "tower_build_necromancer", "tower_build_ghost"}
	}},
	nav_mesh = {
		{9, 12, 2},
		{1, 5, 7},
		{nil, 6, 9},
		{5, nil, nil, 7},
		{12, nil, 4, 2},
		{nil, 14, 8, 3},
		{2, 4},
		{6, 13, nil, 9},
		{3, 8, 1},
		[11] = {13, nil, 12, 8},
		[12] = {11, nil, 5, 1},
		[13] = {14, nil, 11, 8},
		[14] = {
			[3] = 13,
			[4] = 6
		}
	},
	required_exoskeletons = {
		"hydra_unitDef",
		"hydra_unit_transformedDef",
		"hydra_deathDef",
		"hydra_trailDef",
		"hydra_poisonDef",
		"hydra_hit_Skill1Def",
		"hydra_projectileDef",
		"hydra_decal_skill2Def",
		"hydra_death1_headsDef",
		"hydra_death_threeheadsDef",
		"stage_21_bubbles_02Def",
		"stage_21_dragonfly_01Def",
		"stage_21_dragonfly_02Def",
		"stage_21_particlesDef",
		"Tank_crocs_animationsDef",
		"Fx_Shaman_BlocktowerDef"
	},
	required_sounds = {"music_stage121", "enemies_terrain_crocs", "stage_21"},
	required_textures = {"go_stage121_bg", "go_stage121", "go_enemies_terrain_5"}
}
