-- chunkname: @./kr1/data/levels/level23_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "background_sounds_blackburn",
			sounds = {"BlackburnGhosts"}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse1",
			pos = {
				x = 483,
				y = 131
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.22
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse2",
			pos = {
				x = 77,
				y = 265
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_Light",
			pos = {
				x = 910,
				y = 291
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.08
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse2",
			pos = {
				x = 294,
				y = 320
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse1",
			pos = {
				x = 209,
				y = 339
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.22
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_23",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse1",
			pos = {
				x = 956,
				y = 403
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.22
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse1",
			pos = {
				x = 196,
				y = 498
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.22
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg23_brokenHouse1",
			pos = {
				x = 537,
				y = 539
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.22
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_house1",
			pos = {
				x = 969,
				y = 623
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_1",
			["delayed_play.max_delay"] = 20,
			snapping = "top left",
			pos = {
				x = -7.74,
				y = 618.5
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_2",
			["delayed_play.max_delay"] = 20,
			snapping = "top",
			pos = {
				x = 502.46,
				y = 774.14
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_3",
			["delayed_play.max_delay"] = 20,
			snapping = "top right",
			pos = {
				x = 1031.49,
				y = 454.02
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_4",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom right",
			pos = {
				x = 1028.54,
				y = 116.61
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_5",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom",
			pos = {
				x = 687.1,
				y = -12.1
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_6",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom left",
			pos = {
				x = -12.86,
				y = 155.9
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 972,
				y = 223
			}
		},
		{
			template = "decal_s23_splinter",
			pos = {
				x = 269,
				y = 126
			}
		},
		{
			template = "decal_s23_splinter",
			pos = {
				x = 580,
				y = 172
			}
		},
		{
			template = "decal_s23_splinter",
			pos = {
				x = 966,
				y = 366
			}
		},
		{
			template = "decal_s23_splinter",
			pos = {
				x = 770,
				y = 700
			}
		},
		{
			template = "decal_s23_splinter_pizza",
			pos = {
				x = 165,
				y = 640
			}
		},
		{
			["editor.r"] = 4.7298422729046,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 100,
			pos = {
				x = 492,
				y = 66
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 37,
				y = 184
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 37,
				y = 452
			}
		},
		{
			["editor.r"] = 7.8888882190143,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 959,
				y = 567
			}
		},
		{
			["editor.r"] = 7.8888882190143,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 663,
				y = 569
			}
		},
		{
			template = "mega_spawner",
			load_file = "level23_spawner"
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 684,
				y = 132
			},
			["tower.default_rally_pos"] = {
				x = 743,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 303,
				y = 193
			},
			["tower.default_rally_pos"] = {
				x = 304,
				y = 263
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 495,
				y = 193
			},
			["tower.default_rally_pos"] = {
				x = 428,
				y = 254
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 612,
				y = 236
			},
			["tower.default_rally_pos"] = {
				x = 613,
				y = 331
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 183,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 232,
				y = 232
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 390,
				y = 303
			},
			["tower.default_rally_pos"] = {
				x = 367,
				y = 248
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 779,
				y = 338
			},
			["tower.default_rally_pos"] = {
				x = 780,
				y = 440
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 322,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 313,
				y = 471
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 611,
				y = 407
			},
			["tower.default_rally_pos"] = {
				x = 665,
				y = 470
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 476,
				y = 482
			},
			["tower.default_rally_pos"] = {
				x = 406,
				y = 440
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 740,
				y = 500
			},
			["tower.default_rally_pos"] = {
				x = 725,
				y = 432
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 325,
				y = 527
			},
			["tower.default_rally_pos"] = {
				x = 341,
				y = 473
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 856,
				y = 543
			},
			["tower.default_rally_pos"] = {
				x = 878,
				y = 468
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 8,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 759,
				y = 579
			},
			["tower.default_rally_pos"] = {
				x = 653,
				y = 565
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 6,
			locked_towers = {"tower_build_barrack", "tower_build_engineer"}
		}
	},
	nav_mesh = {
		{3, 4, 6, 2},
		{5, 1, 12, 8},
		{nil, 4, 1, 5},
		{3, nil, 6, 1},
		{3, 3, 2, 9},
		{1, 4, 7, 2},
		{6, nil, nil, 12},
		{5, 2, 11, 9},
		{5, 8, 11},
		{11, 13, 14},
		{8, 13, 10},
		{2, 7, 14, 13},
		{8, 12, 14, 10},
		{13, 12, nil, 10}
	},
	required_sounds = {"music_stage23", "BlackburnSounds"},
	required_textures = {"go_enemies_blackburn", "go_stages_blackburn", "go_stage23", "go_stage23_bg"}
}
