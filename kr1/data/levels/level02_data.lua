-- chunkname: @./kr1/data/levels/level02_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_2",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 460,
				y = 80
			}
		},
		{
			template = "decal_mill_big",
			pos = {
				x = 801,
				y = 232
			}
		},
		{
			template = "decal_mill_big",
			pos = {
				x = 760,
				y = 259
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 582,
				y = 79
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 619,
				y = 96
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 730,
				y = 187
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = -37,
				y = 322
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 170,
				y = 486
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 627,
				y = 71
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 696,
				y = 181
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = -56,
				y = 298
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 137,
				y = 472
			}
		},
		{
			["editor.r"] = 0.26179938779915,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 980,
				y = 499
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 564,
				y = 138
			},
			["tower.default_rally_pos"] = {
				x = 559,
				y = 229
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 455,
				y = 261
			},
			["tower.default_rally_pos"] = {
				x = 433,
				y = 354
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 553,
				y = 281
			},
			["tower.default_rally_pos"] = {
				x = 539,
				y = 373
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 378,
				y = 407
			},
			["tower.default_rally_pos"] = {
				x = 378,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 623,
				y = 490
			},
			["tower.default_rally_pos"] = {
				x = 717,
				y = 535
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 448,
				y = 553
			},
			["tower.default_rally_pos"] = {
				x = 539,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 624,
				y = 569
			},
			["tower.default_rally_pos"] = {
				x = 701,
				y = 605
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {"tower_archer_3", "tower_barrack_3", "tower_mage_3", "tower_engineer_3"}
	}, {
		locked_hero = true,
		max_upgrade_level = 3,
		locked_towers = {"tower_archer_3", "tower_barrack_3", "tower_mage_3", "tower_engineer_3"}
	}, {
		locked_hero = true,
		max_upgrade_level = 3,
		locked_towers = {"tower_archer_3", "tower_build_barrack", "tower_mage_3", "tower_engineer_3"}
	}},
	nav_mesh = {{nil, nil, 2, 6}, {1, nil, nil, 3}, {6, 2, nil, 7}, {nil, 6, 7, 5}, {nil, 4, 7}, {nil, 1, 3, 4}, {4, 3, nil, 5}},
	required_sounds = {"music_stage02"},
	required_textures = {"go_enemies_grass", "go_stages_grass", "go_stage02", "go_stage02_bg"}
}
