-- chunkname: @./kr1/data/levels/level20_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "aura_burning_floor",
			pos = {
				x = 254,
				y = 262
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 583,
				y = 293
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 210,
				y = 301
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 654,
				y = 301
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 167,
				y = 338
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 707,
				y = 338
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 535,
				y = 502
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 604,
				y = 529
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 673,
				y = 557
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 580,
				y = 577
			}
		},
		{
			template = "aura_burning_floor",
			pos = {
				x = 541,
				y = 615
			}
		},
		{
			template = "burning_floor_controller",
			cooldowns = {{
				[4] = {3, 40},
				[5] = {3, 40},
				[8] = {3, 20},
				[9] = {3, 30},
				[10] = {3, 40},
				[13] = {3, 20},
				[15] = {20, 40},
				[16] = {3, 5},
				[17] = {3, 5},
				[18] = {3, 5}
			}, {{1, 10}, {15, 25}, {15, 50}, {5, 40}, {15, 120}, {20, 240}}, {{5, 9999}}},
			pos = {
				x = 254,
				y = 262
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_20",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 570,
				y = 722
			}
		},
		{
			template = "decal_demon_portal_big",
			out_nodes = {
				[2] = 3
			},
			pos = {
				x = 927,
				y = 283
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 320,
				y = 20
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 353,
				y = 44
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1069,
				y = 621
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1101,
				y = 643
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 955,
				y = 647
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 747,
				y = 657
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_inferno_bubble",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 850,
				y = 663
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_lava_fall",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_lava_fall_idle",
			pos = {
				x = 389,
				y = 649
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 303,
				y = 50
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 987,
				y = 640
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 884,
				y = 660
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333,
			pos = {
				x = 1056,
				y = 661
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_lava_splash",
			["delayed_play.max_delay"] = 13.333333333333334,
			pos = {
				x = 797,
				y = 665
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 7.1558499331768,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 858,
				y = 178
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 37,
				y = 216
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 357,
				y = 146
			},
			["tower.default_rally_pos"] = {
				x = 241,
				y = 188
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 558,
				y = 206
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 142
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 680,
				y = 207
			},
			["tower.default_rally_pos"] = {
				x = 684,
				y = 142
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 161,
				y = 223
			},
			["tower.default_rally_pos"] = {
				x = 162,
				y = 180
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 363,
				y = 265
			},
			["tower.default_rally_pos"] = {
				x = 469,
				y = 225
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 300,
				y = 320
			},
			["tower.default_rally_pos"] = {
				x = 235,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 463,
				y = 346
			},
			["tower.default_rally_pos"] = {
				x = 486,
				y = 273
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 240,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 183,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 674,
				y = 437
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 349
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 755,
				y = 476
			},
			["tower.default_rally_pos"] = {
				x = 777,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 852,
				y = 479
			},
			["tower.default_rally_pos"] = {
				x = 853,
				y = 418
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 374,
				y = 489
			},
			["tower.default_rally_pos"] = {
				x = 375,
				y = 430
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 260,
				y = 525
			},
			["tower.default_rally_pos"] = {
				x = 256,
				y = 467
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 648,
				y = 614
			},
			["tower.default_rally_pos"] = {
				x = 650,
				y = 556
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 6,
			locked_towers = {"tower_build_mage"}
		}
	},
	nav_mesh = {
		{2, 5, 4},
		{3, 7, 1},
		{11, 9, 2},
		{1, 8, nil, 1},
		{7, 12, 6, 1},
		{5, 12, 8, 1},
		{9, 12, 5, 2},
		{6, 13, 4, 4},
		{10, 14, 7, 3},
		{11, 14, 9, 9},
		{nil, 14, 10, 3},
		{14, nil, 13, 7},
		{12, nil, nil, 8},
		{10, nil, 12, 9}
	},
	required_sounds = {"music_stage20"},
	required_textures = {"go_enemies_wastelands", "go_enemies_torment", "go_stages_rotten_torment", "go_stage20", "go_stage20_bg"}
}
