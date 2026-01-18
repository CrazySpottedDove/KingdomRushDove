return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = 518,
			y = 262
		}
	}, {
		pos = {
			x = 718,
			y = 262
		}
	}},
	custom_start_pos = {
		zoom = 1.2,
		pos = {
			x = 373,
			y = 202
		}
	},
	entities_list = {
		{
			template = "controller_stage33_envelops",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_33_boat",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_33_ciclone",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_stage_33_house_doors"
		},
		{
			area_id = 8,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 85,
			pos = {
				x = 622,
				y = 167
			}
		},
		{
			area_id = 4,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 117,
			pos = {
				x = 925,
				y = 264
			}
		},
		{
			area_id = 2,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 117,
			pos = {
				x = 268,
				y = 276
			}
		},
		{
			area_id = 1,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 181,
			pos = {
				x = 617,
				y = 279
			}
		},
		{
			area_id = 10,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 181,
			pos = {
				x = 617,
				y = 279
			}
		},
		{
			area_id = 3,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 117,
			pos = {
				x = 614,
				y = 467
			}
		},
		{
			area_id = 6,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 117,
			pos = {
				x = 614,
				y = 610
			}
		},
		{
			area_id = 5,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 146,
			pos = {
				x = 296,
				y = 628
			}
		},
		{
			area_id = 7,
			template = "controller_stage_33_lightning_strike",
			strikes_spawn_radius = 146,
			pos = {
				x = 925,
				y = 628
			}
		},
		{
			template = "controller_stage_33_tambor",
			pos = {
				x = 303,
				y = 390
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
			template = "decal_achievement_saitam_stage33",
			pos = {
				x = 478,
				y = 48
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage33_0001",
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
				x = 634,
				y = 63
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 556,
				y = 58
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 711,
				y = 59
			}
		},
		{
			kill_radius = 178,
			template = "decal_generic_kill_area",
			kill_area_id = 1,
			pos = {
				x = 616,
				y = 617
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = 218,
				y = 417
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = -47,
				y = 419
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = 351,
				y = 419
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = 136,
				y = 422
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = 22,
				y = 426
			}
		},
		{
			template = "decal_stage33_envelop_spawn_pos",
			pos = {
				x = 267,
				y = 428
			}
		},
		{
			["editor.r"] = -1.1742690153582e-13,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 1131,
				y = 261
			}
		},
		{
			["editor.r"] = -3.1415926535899,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 46,
				y = 275
			}
		},
		{
			["editor.r"] = -1.7506829319558e-14,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 1131,
				y = 640
			}
		},
		{
			["editor.r"] = 1.5707963267948,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 145,
			pos = {
				x = 50,
				y = 659
			}
		},
		{
			["editor.r"] = -4.7123889803847,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 588,
				y = 693
			}
		},
		{
			["editor.r"] = -4.7123889803847,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 130,
			pos = {
				x = 636,
				y = 693
			}
		},
		{
			template = "mega_spawner",
			load_file = "level133_spawner"
		},
		{
			template = "stage_33_mask_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_1_destroyed",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_3",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_4",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_5",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_6",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_7",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_8",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_9",
			["editor.game_mode"] = 2,
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_props",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_water_big",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_mask_water_small",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "stage_33_spawner",
			["spawner.name"] = "trail3",
			["spawner.pi"] = 1,
			pos = {
				x = -50,
				y = 270
			}
		},
		{
			template = "stage_33_spawner",
			["spawner.name"] = "trail1",
			["spawner.pi"] = 1,
			pos = {
				x = 500,
				y = 465
			}
		},
		{
			template = "stage_33_spawner",
			["spawner.name"] = "trail2",
			["spawner.pi"] = 1,
			pos = {
				x = 740,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "27",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_elemental_water",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "27",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 618,
				y = 264
			},
			["tower.default_rally_pos"] = {
				x = 618,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_elemental_water",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 808,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 808,
				y = 256
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_elemental_water",
			["editor.game_mode"] = 1,
			should_flip = true,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 328,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 328,
				y = 642
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_house_1",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 618,
				y = 264
			},
			["tower.default_rally_pos"] = {
				x = 618,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_house_2",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			unlock_holder_type = "tower_holder_elemental_water",
			pos = {
				x = 268,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 268,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "42",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_house_2",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "42",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 268,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 268,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_house_3",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 921,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 921,
				y = 640
			}
		},
		{
			["tower.holder_id"] = "51",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_house_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "51",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 921,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 921,
				y = 640
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_invisible",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 503,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 620
			}
		},
		{
			["tower.holder_id"] = "52",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_invisible",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "52",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 503,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 620
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_invisible",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 720,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 575
			}
		},
		{
			["tower.holder_id"] = "53",
			["tower.terrain_style"] = 28,
			template = "tower_holder_blocked_stage_33_invisible",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "53",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 720,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 575
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 766,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 694,
				y = 224
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 766,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 689,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "44",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "44",
			pos = {
				x = 766,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 689,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 1030,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 1030,
				y = 263
			}
		},
		{
			["tower.holder_id"] = "25",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "25",
			pos = {
				x = 1030,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 1030,
				y = 263
			}
		},
		{
			["tower.holder_id"] = "45",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "45",
			pos = {
				x = 1030,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 1030,
				y = 263
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 435,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 425,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "23",
			pos = {
				x = 435,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 425,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "43",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "43",
			pos = {
				x = 435,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 425,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			should_flip = true,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 110,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 108,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 110,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 108,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "41",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "41",
			pos = {
				x = 110,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 108,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "22",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 268,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 268,
				y = 271
			}
		},
		{
			["tower.holder_id"] = "47",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "47",
			unlock_holder_type = "tower_holder_sea_of_trees_13",
			pos = {
				x = 618,
				y = 264
			},
			["tower.default_rally_pos"] = {
				x = 618,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "46",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "46",
			pos = {
				x = 808,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 808,
				y = 256
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 435,
				y = 342
			},
			["tower.default_rally_pos"] = {
				x = 435,
				y = 292
			}
		},
		{
			["tower.holder_id"] = "48",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "48",
			pos = {
				x = 435,
				y = 342
			},
			["tower.default_rally_pos"] = {
				x = 435,
				y = 292
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 164,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 164,
				y = 642
			}
		},
		{
			["tower.holder_id"] = "29",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "29",
			pos = {
				x = 164,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 164,
				y = 642
			}
		},
		{
			["tower.holder_id"] = "49",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "49",
			pos = {
				x = 164,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 164,
				y = 642
			}
		},
		{
			["tower.holder_id"] = "30",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "30",
			pos = {
				x = 328,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 328,
				y = 641
			}
		},
		{
			["tower.holder_id"] = "50",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "50",
			pos = {
				x = 328,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 328,
				y = 641
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 503,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 620
			}
		},
		{
			["tower.holder_id"] = "33",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "33",
			pos = {
				x = 720,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 604,
				y = 575
			}
		},
		{
			["tower.holder_id"] = "31",
			["tower.terrain_style"] = 28,
			template = "tower_holder_sea_of_trees_13",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "31",
			unlock_holder_type = "tower_holder_blocked_elemental_water",
			pos = {
				x = 921,
				y = 530
			},
			["tower.default_rally_pos"] = {
				x = 921,
				y = 640
			}
		}
	},
	ignore_walk_backwards_paths = {},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_flamespitter", "tower_build_ballista"},
		locked_towers = {
			"tower_build_arborean_emissary",
			"tower_build_sand",
			"tower_build_paladin_covenant",
			"tower_build_tricannon",
			"tower_build_demon_pit",
			"tower_build_arcane_wizard",
			"tower_build_elven_stargazers",
			"tower_build_rocket_gunners",
			"tower_build_barrel",
			"tower_build_royal_archers",
			"tower_build_ray",
			"tower_build_ghost",
			"tower_build_necromancer",
			"tower_build_hermit_toad"
		}
	}},
	nav_mesh = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{}
	},
	required_exoskeletons = {
		"stage31_wood_holder_rayoDef",
		"stage31_wood_holder_rayo_explosionDef",
		"stage_33_anim_propsDef",
		"stage_33_olas_chicasDef",
		"stage_33_olas_grandesDef",
		"stage_33_dirtyDef",
		"stage_33_shadow_screenDef",
		"stage_33_storm_clouds_derDef",
		"stage_33_storm_clouds_izqDef",
		"stage_33_tejasDef",
		"stage_33_storm_shadowDef",
		"stage_33_clouds_flyDef",
		"stage_33_shadows_flyDef",
		"stage_33_tejas_puertaDef",
		"stage_33_storm_rayosDef",
		"stage_3_barco_velaDef",
		"stage_3_barcoDef",
		"stage33_water_mistDef",
		"stage33_water_holder_animations_parcheDef",
		"stage33_water_holder_cuernosDef",
		"stage33_water_holder_dragonDef",
		"stage33_water_holder_gradienteDef",
		"stage33_water_holder_habilidad_1Def",
		"stage33_water_holder_healDef",
		"stage33_water_holder_jarraDef",
		"stage33_water_holder_jarrahojasDef",
		"stage33_water_holder_rayo_explosionDef",
		"stage33_water_holder_rayoDef",
		"stage33_water_dragonflyDef",
		"stage33_water_dragonrootDef",
		"stage33_water_debuff_midDef",
		"stage33_explosion_escombrosDef"
	},
	required_sounds = {"music_stage133", "enemies_terrain_wukong_2", "stage_33", "terrain_wukong_common", "tower_paladin_covenant"},
	required_textures = {"go_stage133_bg", "go_stage133", "go_enemies_terrain_8_2_a", "go_enemies_terrain_8_2_b", "go_wukong_elemental_holders"},
	scale_required_textures = {"go_towers_paladin_covenant"}
}
