-- chunkname: @./kr1/data/levels/level13_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_13",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].name"] = "stage13_cave1",
			["render.sprites[1].anchor.y"] = 0.18,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].anchor.x"] = 0.5,
			pos = {
				x = 384,
				y = 577
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 594,
				y = 48
			}
		},
		{
			template = "decal_fredo",
			pos = {
				x = 584,
				y = 577
			}
		},
		{
			["editor.r"] = 2.6179938779915,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 276,
			pos = {
				x = 40,
				y = 532
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 16,
			pos = {
				x = 516,
				y = 544
			}
		},
		{
			["editor.r"] = 2.4434609527921,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 16,
			pos = {
				x = 569,
				y = 549
			}
		},
		{
			["editor.r"] = -0.31415926535897,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 236,
			pos = {
				x = 985,
				y = 644
			}
		},
		{
			template = "ps_stage_snow",
			pos = {
				x = 512,
				y = 768
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 826,
				y = 208
			},
			["tower.default_rally_pos"] = {
				x = 821,
				y = 298
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 727,
				y = 213
			},
			["tower.default_rally_pos"] = {
				x = 752,
				y = 298
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 629,
				y = 220
			},
			["tower.default_rally_pos"] = {
				x = 570,
				y = 164
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 361,
				y = 242
			},
			["tower.default_rally_pos"] = {
				x = 371,
				y = 188
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 264,
				y = 245
			},
			["tower.default_rally_pos"] = {
				x = 256,
				y = 188
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 445,
				y = 286
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 247
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 498,
				y = 351
			},
			["tower.default_rally_pos"] = {
				x = 543,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 794,
				y = 351
			},
			["tower.default_rally_pos"] = {
				x = 877,
				y = 322
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 698,
				y = 352
			},
			["tower.default_rally_pos"] = {
				x = 690,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 601,
				y = 364
			},
			["tower.default_rally_pos"] = {
				x = 603,
				y = 311
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 196,
				y = 374
			},
			["tower.default_rally_pos"] = {
				x = 194,
				y = 316
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 291,
				y = 375
			},
			["tower.default_rally_pos"] = {
				x = 295,
				y = 329
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 752,
				y = 488
			},
			["tower.default_rally_pos"] = {
				x = 748,
				y = 433
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_snow",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 272,
				y = 515
			},
			["tower.default_rally_pos"] = {
				x = 271,
				y = 458
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 6,
			locked_towers = {"tower_build_mage", "tower_build_engineer"}
		}
	},
	nav_mesh = {
		{nil, 8, 2},
		{1, 9, 3},
		{2, 10, 6},
		{6, 12, 5},
		{4, 11},
		{3, 7, 4, 4},
		{10, 14, 12, 6},
		{nil, 13, 9, 1},
		{8, 13, 10, 2},
		{9, 13, 7, 3},
		{12, 14, nil, 5},
		{6, 14, 11, 4},
		{8, nil, 14, 9},
		{13, nil, 11, 12}
	},
	required_sounds = {"music_stage13"},
	required_textures = {"go_enemies_ice", "go_enemies_sarelgaz", "go_stages_ice", "go_stage13", "go_stage13_bg"}
}
