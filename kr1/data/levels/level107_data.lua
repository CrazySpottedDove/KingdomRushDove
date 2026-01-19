return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 6,
	custom_spawn_pos = {{
		pos = {
			x = 710,
			y = 76
		}
	}, {
		pos = {
			x = 1070,
			y = 327
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 670,
			y = 275
		}
	},
	entities_list = {
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain2AmbienceSoundBats", "Terrain2AmbienceSoundWind"}
		},
		{
			template = "controller_stage_07_crows",
			pos = {
				x = -12,
				y = 202
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
			["render.sprites[1].name"] = "Stage07_0001",
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
			["editor.alpha"] = 15,
			pos = {
				x = 710,
				y = 76
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 9,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 15,
			pos = {
				x = 1070,
				y = 327
			}
		},
		{
			["editor.flip"] = 1,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 636,
				y = 76
			}
		},
		{
			["editor.flip"] = 1,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 787,
				y = 76
			}
		},
		{
			["editor.flip"] = 1,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 1092,
				y = 256
			}
		},
		{
			["editor.flip"] = 1,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 1048,
				y = 392
			}
		},
		{
			template = "decal_stage_07_cave_mask_smoke",
			["editor.game_mode"] = 1,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_07_crow_clickable_1",
			pos = {
				x = -12,
				y = 202
			}
		},
		{
			template = "decal_stage_07_crow_clickable_2",
			pos = {
				x = 16,
				y = 214
			}
		},
		{
			template = "decal_stage_07_crow_clickable_3",
			pos = {
				x = 98,
				y = 153
			}
		},
		{
			template = "decal_stage_07_crow_clickable_4",
			pos = {
				x = 23,
				y = 577
			}
		},
		{
			template = "decal_stage_07_crow_clickable_5",
			pos = {
				x = 562,
				y = 664
			}
		},
		{
			template = "decal_stage_07_dust",
			pos = {
				x = 170,
				y = 416
			}
		},
		{
			template = "decal_stage_07_dust",
			pos = {
				x = 63,
				y = 437
			}
		},
		{
			template = "decal_stage_07_fire",
			pos = {
				x = -188,
				y = 768
			}
		},
		{
			template = "decal_stage_07_fireMask",
			pos = {
				x = -187,
				y = 775
			}
		},
		{
			template = "decal_stage_07_mask",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_stage_07_temple",
			pos = {
				x = -190,
				y = 768
			}
		},
		{
			template = "decal_stage_07_temple_mask",
			pos = {
				x = -190.4,
				y = 768
			}
		},
		{
			template = "decal_stage_07_witcher_easter_egg",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 108,
				y = 2
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 976,
				y = 11
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 513,
				y = 504
			}
		},
		{
			template = "decal_terrain_2_dust",
			pos = {
				x = 1030,
				y = 509
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 1012,
				y = -72
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 13,
				y = -44
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 174,
				y = 7
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = -210,
				y = 475
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 507,
				y = 510
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 1027,
				y = 519
			}
		},
		{
			template = "decal_terrain_2_smoke",
			pos = {
				x = 1003,
				y = 701
			}
		},
		{
			["editor.r"] = 3.1468286413458,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = -60,
				y = 308
			}
		},
		{
			["editor.r"] = 3.1468286413458,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = -60,
				y = 356
			}
		},
		{
			["editor.r"] = 2.157226955465,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 776,
				y = 696
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 208,
				y = 182
			},
			["tower.default_rally_pos"] = {
				x = 260,
				y = 280
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 732,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 636,
				y = 148
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 19,
			template = "tower_holder_blocked_terrain_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 834,
				y = 352
			},
			["tower.default_rally_pos"] = {
				x = 836,
				y = 288
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 330,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 418,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 864,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 880,
				y = 280
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 98,
				y = 220
			},
			["tower.default_rally_pos"] = {
				x = 170,
				y = 292
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 621,
				y = 241
			},
			["tower.default_rally_pos"] = {
				x = 546,
				y = 168
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 514,
				y = 287
			},
			["tower.default_rally_pos"] = {
				x = 435,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 258,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 300,
				y = 288
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 942,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 942,
				y = 286
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 732,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 708,
				y = 306
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 542,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 574,
				y = 374
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 864,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 774,
				y = 524
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 19,
			template = "tower_holder_sea_of_trees_4",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 732,
				y = 580
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 494
			}
		}
	},
	ignore_walk_backwards_paths = {4, 5, 6, 7},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		available_towers = {"tower_build_ballista", "tower_build_paladin_covenant"},
		locked_towers = {"tower_build_royal_archers", "tower_build_arcane_wizard", "tower_build_tricannon", "tower_build_arborean_emissary", "tower_build_demon_pit", "tower_build_elven_stargazers", "tower_build_rocket_gunners", "tower_build_necromancer"}
	}},
	nav_mesh = {
		{2, 3},
		{4, 3, 1},
		{5, nil, 1, 2},
		{5, 3, 2},
		{7, 6, 3},
		{9, 8, 3, 5},
		{10, 9, 5},
		{12, nil, 6, 9},
		{11, 8, 6, 10},
		{13, 9, 7},
		{14, 12, 9, 13},
		{14, 8, 9, 11},
		{14, 11, 10},
		{nil, 12, 11, 13}
	},
	required_exoskeletons = {
		"fireDef",
		"fire_maskDef",
		"templeDef",
		"temple_maskDef",
		"stage_7_crow1Def",
		"stage_7_crow2Def",
		"stage_7_crow3Def",
		"stage_7_crow4Def",
		"stage_7_crow5Def",
		"the_witcherDef",
		"t2_dustDef",
		"t2_smokeDef"
	},
	required_sounds = {"stage_07", "music_stage107", "enemies_terrain_2", "terrain_2_common"},
	required_textures = {"go_enemies_terrain_2", "go_stage107_bg", "go_stage107", "go_stages_terrain2"}
}
