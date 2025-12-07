-- chunkname: @./kr1/data/levels/level06_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_6",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 100,
			["render.sprites[1].z"] = 1000,
			template = "decal_background",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage6_boss_corpse",
			pos = {
				x = 810,
				y = 675
			}
		},
		{
			["render.sprites[1].sort_y"] = 100,
			["render.sprites[1].z"] = 1000,
			template = "decal_background",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage6_boss_corpse",
			pos = {
				x = 810,
				y = 675
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 510,
				y = 673
			}
		},
		{
			["editor.r"] = -1.5777776438029,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 489,
				y = 59
			}
		},
		{
			["editor.r"] = -1.5777776438029,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 534,
				y = 59
			}
		},
		{
			["editor.r"] = -0.21642082724732,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 996,
				y = 221
			}
		},
		{
			["editor.r"] = -2.9216811678386,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 56,
				y = 255
			}
		},
		{
			["editor.r"] = -0.35604716740687,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 996,
				y = 268
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 290,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 290,
				y = 390
			},
			pos = {
				x = 290,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 290,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 290,
				y = 390
			},
			pos = {
				x = 290,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 340,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 340,
				y = 390
			},
			pos = {
				x = 340,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 340,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 340,
				y = 390
			},
			pos = {
				x = 340,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 690,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 690,
				y = 390
			},
			pos = {
				x = 690,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 690,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 690,
				y = 390
			},
			pos = {
				x = 690,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 740,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 740,
				y = 390
			},
			pos = {
				x = 740,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 740,
				y = 390
			},
			["nav_rally.pos"] = {
				x = 740,
				y = 390
			},
			pos = {
				x = 740,
				y = 390
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 472,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 472,
				y = 580
			},
			pos = {
				x = 472,
				y = 580
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 472,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 472,
				y = 580
			},
			pos = {
				x = 472,
				y = 580
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 512,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 512,
				y = 580
			},
			pos = {
				x = 512,
				y = 580
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 512,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 512,
				y = 580
			},
			pos = {
				x = 512,
				y = 580
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 1,
			["nav_rally.center"] = {
				x = 552,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 552,
				y = 580
			},
			pos = {
				x = 552,
				y = 580
			}
		},
		{
			template = "soldier_s6_imperial_guard",
			["editor.game_mode"] = 2,
			["nav_rally.center"] = {
				x = 552,
				y = 580
			},
			["nav_rally.pos"] = {
				x = 552,
				y = 580
			},
			pos = {
				x = 552,
				y = 580
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 391,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 210
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 391,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 210
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 391,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 210
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 629,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 544,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 629,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 544,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 629,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 544,
				y = 213
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 209,
				y = 310
			},
			["tower.default_rally_pos"] = {
				x = 212,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 209,
				y = 310
			},
			["tower.default_rally_pos"] = {
				x = 212,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 209,
				y = 310
			},
			["tower.default_rally_pos"] = {
				x = 212,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 408,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 406,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 408,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 406,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 408,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 406,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 609,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 609,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 609,
				y = 316
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 510,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 508,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 510,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 508,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 510,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 508,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 806,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 806,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 806,
				y = 318
			},
			["tower.default_rally_pos"] = {
				x = 803,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 302,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 298,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 302,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 298,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 403,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 400,
				y = 402
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 403,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 400,
				y = 402
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 403,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 400,
				y = 402
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 619,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 611,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 619,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 611,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 619,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 611,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 719,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 411
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 719,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 411
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 623,
				y = 593
			},
			["tower.default_rally_pos"] = {
				x = 615,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 623,
				y = 593
			},
			["tower.default_rally_pos"] = {
				x = 615,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 623,
				y = 593
			},
			["tower.default_rally_pos"] = {
				x = 615,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 289,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 289,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 289,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 289,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 289,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 289,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 391,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 384,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 391,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 384,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 391,
				y = 595
			},
			["tower.default_rally_pos"] = {
				x = 384,
				y = 543
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 720,
				y = 596
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 720,
				y = 596
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 720,
				y = 596
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 548
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_mage_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 302,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 298,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_mage_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 719,
				y = 454
			},
			["tower.default_rally_pos"] = {
				x = 707,
				y = 411
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 4,
		locked_towers = {}
	}, {
		locked_hero = true,
		max_upgrade_level = 4,
		locked_towers = {"tower_build_archer", "tower_build_mage", "tower_build_engineer"}
	}},
	unlock_towers = {"tower_arcane_wizard", "tower_paladin"},
	nav_mesh = {
		{2, 4, 3},
		{7, 6, 1},
		{4, 8, nil, 1},
		{5, 9, 3, 1},
		{6, 9, 4, 2},
		{7, 10, 5, 2},
		{nil, 11, 6, 2},
		{9, 15, 3, 3},
		{10, 14, 8, 4},
		{11, 12, 9, 6},
		{7, 13, 10, 7},
		{13, nil, 14, 10},
		{nil, nil, 12, 11},
		{12, nil, 15, 9},
		{14, nil, nil, 8}
	},
	required_sounds = {"music_stage06"},
	required_textures = {"go_enemies_grass", "go_stages_grass", "go_stage06", "go_stage06_bg"}
}
