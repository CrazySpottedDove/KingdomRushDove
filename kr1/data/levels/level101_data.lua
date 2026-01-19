return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 6,
	custom_spawn_pos = {{
		pos = {
			x = -68,
			y = 402
		}
	}, {
		pos = {
			x = -68,
			y = 352
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 480,
			y = 412
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
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage01_0001",
			pos = {
				x = 512,
				y = 384
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
				y = 382
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 314
			}
		},
		{
			["editor.flip"] = 0,
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 430
			}
		},
		{
			template = "decal_stage1_decos_waterfalltop",
			pos = {
				x = 1075,
				y = 163
			}
		},
		{
			template = "decal_stage1_waterfall1",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage1_waterfall_1",
			pos = {
				x = 1075,
				y = 164
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_stage1_waterfall2",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage1_waterfall_2",
			pos = {
				x = 418,
				y = 565
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_stage1_waterfall_ripples",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage1_waterfall_ripples",
			pos = {
				x = 906,
				y = 53
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 10,
			["render.sprites[1].r"] = 0,
			template = "decal_stage_01_butterfly_1",
			["delayed_play.max_delay"] = 30,
			pos = {
				x = 512,
				y = 384
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 15,
			["render.sprites[1].r"] = 0,
			template = "decal_stage_01_butterfly_2",
			["delayed_play.max_delay"] = 35,
			pos = {
				x = 512,
				y = 384
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_stage_01_campfire_guy_campfire",
			pos = {
				x = 242,
				y = 219
			}
		},
		{
			template = "decal_stage_01_decos_waterfall",
			pos = {
				x = 1076,
				y = 163
			}
		},
		{
			template = "decal_stage_01_elder_rune",
			["editor.game_mode"] = 1,
			pos = {
				x = 570,
				y = 190
			}
		},
		{
			template = "decal_stage_01_robin_hood",
			["editor.game_mode"] = 1,
			pos = {
				x = 271,
				y = 639
			}
		},
		{
			template = "decal_stage_01_robin_hood",
			["editor.game_mode"] = 2,
			pos = {
				x = 271,
				y = 639
			}
		},
		{
			template = "decal_stage_01_robin_hood",
			["editor.game_mode"] = 3,
			pos = {
				x = 271,
				y = 639
			}
		},
		{
			template = "decal_stage_01_wisps",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 792,
				y = 16
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 763,
				y = 60
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 719,
				y = 63
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 812,
				y = 74
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 863,
				y = 76
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 758,
				y = 102
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 821,
				y = 123
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 752,
				y = 148
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 714,
				y = 177
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 686,
				y = 230
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 610,
				y = 279
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_shine",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "props_water_shine",
			pos = {
				x = 534,
				y = 316
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 0.76794487087751,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 727,
				y = 17
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 3.5081117965086,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 862,
				y = 20
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 0.19198621771938,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 706,
				y = 104
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 3.7175513067479,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 882,
				y = 138
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 4.3633231299858,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 789,
				y = 174
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 3.7175513067479,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 718,
				y = 231
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3101,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -2.3212879051525,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 1128,
				y = 239
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 4.3633231299858,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 658,
				y = 275
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = 0.76794487087751,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 560,
				y = 291
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -0.13962634015955,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 510,
				y = 337
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -0.57595865315813,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 327,
				y = 591
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -1.7627825445143,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 463,
				y = 602
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -1.7627825445143,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 535,
				y = 655
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -2.0769418098733,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 626,
				y = 660
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -1.535889741755,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 629,
				y = 704
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1401,
			template = "decal_waterfall_waves",
			["render.sprites[1].r"] = -1.0471975511966,
			["render.sprites[1].name"] = "props_waterfall_waves",
			pos = {
				x = 564,
				y = 718
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 0.069813170079774,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 220,
			pos = {
				x = 1070,
				y = 435
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 83,
				y = 250
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 361,
				y = 286
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 217,
				y = 385
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 100,
				y = 400
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 920,
				y = 443
			}
		},
		{
			template = "stage_01_bush",
			bush_id = "1",
			["editor.game_mode"] = 1,
			pos = {
				x = 859,
				y = 537
			}
		},
		{
			template = "stage_01_bush",
			["editor.game_mode"] = 1,
			pos = {
				x = 655,
				y = 597
			}
		},
		{
			template = "stage_01_shaman",
			pos = {
				x = 982,
				y = 500
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 84,
				y = 238
			},
			["tower.default_rally_pos"] = {
				x = 142,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 361,
				y = 274
			},
			["tower.default_rally_pos"] = {
				x = 300,
				y = 340
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 218,
				y = 372
			},
			["tower.default_rally_pos"] = {
				x = 224,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 101,
				y = 388
			},
			["tower.default_rally_pos"] = {
				x = 73,
				y = 329
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 922,
				y = 431
			},
			["tower.default_rally_pos"] = {
				x = 820,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 694,
				y = 436
			},
			["tower.default_rally_pos"] = {
				x = 734,
				y = 517
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 860,
				y = 522
			},
			["tower.default_rally_pos"] = {
				x = 770,
				y = 490
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 657,
				y = 583
			},
			["tower.default_rally_pos"] = {
				x = 675,
				y = 523
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_powers = {true, true},
		locked_towers = {"tower_archer_2", "tower_barrack_2", "tower_engineer_2", "tower_mage_2"}
	}, {
		locked_hero = true,
		max_upgrade_level = 2,
		locked_towers = {"tower_archer_2", "tower_barrack_2", "tower_engineer_2", "tower_mage_2"}
	}, {
		locked_hero = true,
		max_upgrade_level = 2,
		locked_towers = {"tower_barrack_2", "tower_engineer_2", "tower_archer_2", "tower_mage_2"}
	}},
	nav_mesh = {{4, 2}, {3, nil, nil, 1}, {5, nil, 2, 4}, {6, 3, 1}, {7, nil, 3, 6}, {8, 5, 4}, {
		[3] = 5,
		[4] = 8
	}, {nil, 7, 6}},
	required_exoskeletons = {"stage_1_butterfly_1Def", "stage_1_butterfly_2Def", "stage_1_wisps_1Def", "stage_1_wisps_2Def", "drag_tutorialDef"},
	required_sounds = {"music_stage101", "enemies_sea_of_trees", "stage_01", "terrain_1_common"},
	required_textures = {"go_stages_sea_of_trees", "go_stage101_bg", "go_stage101", "go_enemies_sea_of_trees"}
}
