﻿-- chunkname: @./kr3/data/levels/level16_data.lua

return {
	show_comic_idx = 7,
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"ElvenWoodsAmbienceSound"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage16_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 50,
				y = 254
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 51,
				y = 481
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 28,
				y = 167
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 28,
				y = 316
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 28,
				y = 412
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 28,
				y = 540
			}
		},
		{
			template = "decal_hr_crystal_skull",
			["delayed_play.achievement_flag"] = {
				"MITCHELL_HEDGES",
				1
			},
			pos = {
				x = 192,
				y = 134
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s16_bush_burner",
			["editor.game_mode"] = 1,
			pos = {
				x = 889,
				y = 300
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s16_bush_burner",
			["editor.game_mode"] = 1,
			pos = {
				x = 485,
				y = 365
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s16_bush_holder",
			["editor.game_mode"] = 1,
			pos = {
				x = 552,
				y = 294
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s16_bush_holder",
			["editor.game_mode"] = 1,
			pos = {
				x = 605,
				y = 354
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s16_ground_archers_land",
			["editor.game_mode"] = 1,
			pos = {
				x = 391,
				y = 365
			}
		},
		{
			template = "decal_s16_land_1",
			["editor.game_mode"] = 1,
			["render.sprites[1].name"] = "Stage16_0003",
			pos = {
				x = 512,
				y = 384
			},
			["render.sprites[1].z"] = Z_BACKGROUND_COVERS
		},
		{
			template = "decal_s16_land_2",
			["editor.game_mode"] = 1,
			["render.sprites[1].name"] = "Stage16_0002",
			pos = {
				x = 512,
				y = 384
			},
			["render.sprites[1].z"] = Z_BACKGROUND_COVERS
		},
		{
			["editor.r"] = -4.0523140398818e-15,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 974,
				y = 179
			}
		},
		{
			["editor.r"] = -4.0523140398818e-15,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 974,
				y = 225
			}
		},
		{
			["editor.r"] = -0.34906585039887,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 979,
				y = 575
			}
		},
		{
			["editor.r"] = -0.34906585039887,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 979,
				y = 621
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 669,
				y = 718
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 12,
			pos = {
				x = 647,
				y = 239
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 11,
			pos = {
				x = 705,
				y = 287
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 13,
			pos = {
				x = 557,
				y = 288
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 12,
			pos = {
				x = 753,
				y = 302
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 12,
			pos = {
				x = 672,
				y = 328
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 13,
			pos = {
				x = 611,
				y = 343
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 21,
			pos = {
				x = 402,
				y = 359
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s16_burner_explosion",
			["editor.game_mode"] = 1,
			["editor.tag"] = 22,
			pos = {
				x = 377,
				y = 362
			}
		},
		{
			template = "gnoll_bush_spawner",
			["spawner.name"] = "trail1",
			["spawner.pi"] = 7,
			pos = {
				x = 476,
				y = 61
			}
		},
		{
			template = "gnoll_bush_spawner",
			["spawner.name"] = "trail0",
			["spawner.pi"] = 6,
			pos = {
				x = 826,
				y = 580
			}
		},
		{
			template = "mega_spawner",
			load_file = "level64_spawner"
		},
		{
			template = "soldier_s16_ground_archer",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			["nav_rally.center"] = {
				x = 382,
				y = 369
			},
			["nav_rally.pos"] = {
				x = 382,
				y = 369
			},
			pos = {
				x = 382,
				y = 369
			}
		},
		{
			template = "soldier_s16_ground_archer",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			["nav_rally.center"] = {
				x = 406,
				y = 382
			},
			["nav_rally.pos"] = {
				x = 406,
				y = 382
			},
			pos = {
				x = 406,
				y = 382
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 1,
			["render.sprites[1].z"] = 1402,
			["editor.tag"] = 1,
			["tower.flip_x"] = true,
			["powers.razor_edge.level"] = 2,
			template = "tower_bastion",
			["editor.game_mode"] = 1,
			pos = {
				x = 708,
				y = 300
			},
			["tower.default_rally_pos"] = {
				x = 572,
				y = 220
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_bastion_holder",
			["editor.game_mode"] = 0,
			pos = {
				x = 360,
				y = 626
			},
			["tower.default_rally_pos"] = {
				x = 457,
				y = 577
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 513,
				y = 148
			},
			["tower.default_rally_pos"] = {
				x = 518,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 697,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 694,
				y = 131
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 231,
				y = 200
			},
			["tower.default_rally_pos"] = {
				x = 228,
				y = 299
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 381,
				y = 209
			},
			["tower.default_rally_pos"] = {
				x = 424,
				y = 288
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 820,
				y = 210
			},
			["tower.default_rally_pos"] = {
				x = 825,
				y = 154
			}
		},
		{
			["tower.terrain_style"] = 1,
			["ui.can_click"] = false,
			["tower.holder_id"] = "15",
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["tower.can_hover"] = false,
			pos = {
				x = 546,
				y = 297
			},
			["tower.default_rally_pos"] = {
				x = 565,
				y = 238
			},
			["render.sprites[1].z"] = Z_BACKGROUND_BETWEEN
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 816,
				y = 357
			},
			["tower.default_rally_pos"] = {
				x = 800,
				y = 443
			}
		},
		{
			["tower.terrain_style"] = 1,
			["ui.can_click"] = false,
			["tower.holder_id"] = "14",
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["tower.can_hover"] = false,
			pos = {
				x = 613,
				y = 361
			},
			["tower.default_rally_pos"] = {
				x = 612,
				y = 446
			},
			["render.sprites[1].z"] = Z_BACKGROUND_BETWEEN
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 291,
				y = 362
			},
			["tower.default_rally_pos"] = {
				x = 292,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 716,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 717,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 511,
				y = 504
			},
			["tower.default_rally_pos"] = {
				x = 487,
				y = 446
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 846,
				y = 504
			},
			["tower.default_rally_pos"] = {
				x = 872,
				y = 447
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 323,
				y = 516
			},
			["tower.default_rally_pos"] = {
				x = 324,
				y = 456
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 575,
				y = 576
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 633
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 721,
				y = 609
			},
			["tower.default_rally_pos"] = {
				x = 641,
				y = 666
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{
			locked_towers = {
				"tower_build_archer",
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			4,
			nil,
			2,
			13
		},
		{
			1,
			1,
			16,
			7
		},
		{
			nil,
			4,
			17,
			6
		},
		{
			nil,
			1,
			13,
			3
		},
		{
			6,
			17,
			10
		},
		{
			nil,
			3,
			5
		},
		{
			13,
			2,
			8,
			14
		},
		{
			7,
			16,
			nil,
			11
		},
		{
			10,
			11,
			12,
			10
		},
		{
			5,
			15,
			9
		},
		{
			15,
			8,
			nil,
			12
		},
		{
			9,
			11
		},
		{
			4,
			1,
			7,
			17
		},
		{
			17,
			13,
			15,
			15
		},
		{
			17,
			14,
			11,
			10
		},
		{
			2,
			nil,
			nil,
			8
		},
		{
			3,
			13,
			14,
			5
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage64",
		"ElvesTowerBastionSounds",
		"ElvesLevelHRSounds",
		"ElvenWoodsAmbienceSounds",
		"ElvesCreepHyena"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_enemies_hulking_rage",
		"go_stage64",
		"go_stage64_bg",
		"go_stages_hulking_rage"
	}
}
