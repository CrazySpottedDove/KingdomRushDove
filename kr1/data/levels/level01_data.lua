-- chunkname: @./kr1/data/levels/level01_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	custom_spawn_pos = {
		x = 170,
		y = 371
	},
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_1",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 971,
				y = 320
			}
		},
		{
			template = "decal_mill_big",
			pos = {
				x = 777,
				y = 419
			}
		},
		{
			template = "decal_mill_small",
			pos = {
				x = 736,
				y = 442
			}
		},
		{
			template = "decal_s01_trees",
			pos = {
				x = 578,
				y = 393
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 493,
				y = 82
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 529,
				y = 99
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 663,
				y = 355
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 736,
				y = 358
			}
		},
		{
			template = "decal_sheep_big",
			pos = {
				x = 700,
				y = 373
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 538,
				y = 74
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 688,
				y = 339
			}
		},
		{
			template = "decal_sheep_small",
			pos = {
				x = 675,
				y = 399
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 488,
				y = 719
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 558,
				y = 159
			},
			["tower.default_rally_pos"] = {
				x = 563,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 812,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 765,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 659,
				y = 268
			},
			["tower.default_rally_pos"] = {
				x = 660,
				y = 218
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 380,
				y = 283
			},
			["tower.default_rally_pos"] = {
				x = 382,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 476,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 478,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 385,
				y = 356
			},
			["tower.default_rally_pos"] = {
				x = 277,
				y = 344
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 289,
				y = 483
			},
			["tower.default_rally_pos"] = {
				x = 337,
				y = 443
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 371,
				y = 512
			},
			["tower.default_rally_pos"] = {
				x = 403,
				y = 468
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
		locked_towers = {"tower_barrack_2", "tower_engineer_2", "tower_build_archer", "tower_build_mage"}
	}},
	nav_mesh = {{6, nil, nil, 8}, {nil, 7, 5}, {4, 8, nil, 5}, {7, 8, 3, 5}, {2, 7, 4}, {4, nil, 1, 8}, {2, nil, 4, 5}, {4, 6, nil, 3}},
	required_sounds = {"music_stage01"},
	required_textures = {"go_enemies_grass", "go_stages_grass", "go_stage01", "go_stage01_bg", "gui_tutorial"}
-- "go_hero_alleria"
}
