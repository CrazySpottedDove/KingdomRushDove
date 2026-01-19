return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = -68,
			y = 218
		}
	}, {
		pos = {
			x = -68,
			y = 510
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 0,
			y = 360
		}
	},
	entities_list = {
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain1AmbienceSoundBirds"}
		},
		{
			template = "bush_ladder",
			["spawner.name"] = "trail1",
			["spawner.pi"] = 3,
			pos = {
				x = 593,
				y = 230
			}
		},
		{
			template = "bush_ladder",
			["spawner.name"] = "trail2",
			["spawner.pi"] = 1,
			pos = {
				x = 337,
				y = 493
			}
		},
		{
			template = "controller_stage_04_arboreans",
			pos = {
				x = 829,
				y = 120
			}
		},
		{
			template = "controller_stage_04_easteregg_sheepy",
			pos = {
				x = 585,
				y = 660
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage04_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 5,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = -68,
				y = 218
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 3,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = -68,
				y = 510
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 159
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 284
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 448
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 567
			}
		},
		{
			template = "decal_stage_04_arborean_center",
			pos = {
				x = 568,
				y = 410
			}
		},
		{
			template = "decal_stage_04_arborean_left",
			pos = {
				x = -54,
				y = 618
			}
		},
		{
			template = "decal_stage_04_arborean_right",
			pos = {
				x = 1035,
				y = 593
			}
		},
		{
			template = "decal_stage_04_easteregg_sheepy_old_man",
			pos = {
				x = 540,
				y = 660
			}
		},
		{
			template = "decal_stage_04_easteregg_sheepy_sheepy",
			pos = {
				x = 585,
				y = 660
			}
		},
		{
			template = "decal_stage_04_elder_rune",
			["editor.game_mode"] = 1,
			pos = {
				x = 1004,
				y = 228
			}
		},
		{
			template = "decal_stage_04_elder_rune_static",
			["editor.game_mode"] = 2,
			pos = {
				x = 837,
				y = 202
			}
		},
		{
			template = "decal_stage_04_elder_rune_static",
			["editor.game_mode"] = 3,
			pos = {
				x = 837,
				y = 202
			}
		},
		{
			template = "decal_stage_04_mask_tunnel",
			pos = {
				x = 969,
				y = 607
			}
		},
		{
			template = "decal_stage_04_waterfall",
			pos = {
				x = 1114,
				y = 589
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1131,
				y = 46
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 134,
				y = 61
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1009,
				y = 70
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 352,
				y = 71
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1160,
				y = 127
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 232,
				y = 139
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1015,
				y = 159
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1122,
				y = 162
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -151,
				y = 325
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -129,
				y = 370
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 545,
				y = 381
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 690,
				y = 430
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 646,
				y = 464
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1146,
				y = 477
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1168,
				y = 525
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1057,
				y = 591
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1166,
				y = 635
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1084,
				y = 661
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 154,
				y = 667
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -82,
				y = 671
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -60,
				y = 706
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -35,
				y = 727
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 51,
				y = 730
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_501",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 532,
				y = 736
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -5.8841820305133e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1070,
				y = 328
			}
		},
		{
			["editor.r"] = -5.8841820305133e-15,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1070,
				y = 371
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 866,
				y = 649
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 826,
				y = 668
			}
		},
		{
			load_file = "level104heroic_spawner",
			template = "mega_spawner",
			["editor.game_mode"] = 2
		},
		{
			load_file = "level104iron_spawner",
			template = "mega_spawner",
			["editor.game_mode"] = 3
		},
		{
			load_file = "level104_spawner",
			template = "mega_spawner",
			["editor.game_mode"] = 1
		},
		{
			template = "stage_04_mask_bottom",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_bridge_center_back",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_bridge_center_front",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_bridge_left_back",
			pos = {
				x = 512,
				y = 382
			}
		},
		{
			template = "stage_04_mask_bridge_left_front",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_bridge_right_back",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_bridge_right_front",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_04_mask_top",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_4_arborean_vine",
			pos = {
				x = 438,
				y = 737
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 150,
				y = 221
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = -73,
				y = 302
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 750,
				y = 473
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 1147,
				y = 572
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 973,
				y = 603
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 141,
				y = 627
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "stage_4_leaf_anim",
			["render.sprites[1].r"] = 0,
			pos = {
				x = 383,
				y = 738
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 7,
			template = "tower_arborean_sentinels",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 217,
				y = 346
			},
			["tower.default_rally_pos"] = {
				x = 204,
				y = 289
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 7,
			template = "tower_arborean_sentinels",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 790,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 894,
				y = 395
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 294,
				y = 196
			},
			["tower.default_rally_pos"] = {
				x = 372,
				y = 248
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 499,
				y = 265
			},
			["tower.default_rally_pos"] = {
				x = 458,
				y = 210
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 940,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 879,
				y = 317
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 728,
				y = 288
			},
			["tower.default_rally_pos"] = {
				x = 785,
				y = 242
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 119,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 95,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 324,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 307,
				y = 436
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 493,
				y = 456
			},
			["tower.default_rally_pos"] = {
				x = 417,
				y = 509
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 152,
				y = 478
			},
			["tower.default_rally_pos"] = {
				x = 130,
				y = 425
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 270,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 242,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 596,
				y = 508
			},
			["tower.default_rally_pos"] = {
				x = 550,
				y = 584
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 738,
				y = 508
			},
			["tower.default_rally_pos"] = {
				x = 788,
				y = 591
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 7,
			template = "tower_holder_sea_of_trees_2",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 922,
				y = 552
			},
			["tower.default_rally_pos"] = {
				x = 851,
				y = 499
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{}, {}, {
		available_towers = {"tower_build_tricannon", "tower_build_ballista"}
	}},
	nav_mesh = {
		{3, 2},
		{4, nil, nil, 1},
		{6, 4, 1, 5},
		{7, nil, 2, 6},
		{8, 6, 3},
		{8, 4, 3, 5},
		{9, nil, 4, 8},
		{10, 7, 5},
		{11, nil, 7, 8},
		{14, 12, 8},
		{13, nil, 9, 12},
		{nil, 11, nil, 10},
		{
			[3] = 11,
			[4] = 14
		},
		{nil, 13, 10}
	},
	required_exoskeletons = {"elevator_cosoDef", "elevator_explosionDef", "elevatorDef"},
	required_sounds = {"music_stage104", "enemies_sea_of_trees", "stage_04", "terrain_1_common"},
	required_textures = {"go_enemies_sea_of_trees", "go_stage104_bg", "go_stage104", "go_stages_sea_of_trees"}
}
