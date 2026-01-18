return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {{
		pos = {
			x = -68,
			y = 317
		}
	}, {
		pos = {
			x = 267,
			y = 668
		}
	}},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 400,
			y = 450
		}
	},
	entities_list = {
		{
			template = "controller_terrain_3_floating_elements",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "controller_terrain_3_local_glare",
			["editor.game_mode"] = 1,
			decal_ground = "decal_stage_13_glare",
			pos = {
				x = 386,
				y = 362
			},
			waves = {{3, 20, 25}, {6, 30, 25}, {8, 16, 25}, {11, 22, 25}, {14, 22, 25}, {15, 24, 35}}
		},
		{
			template = "controller_terrain_3_local_glare",
			["editor.game_mode"] = 2,
			decal_ground = "decal_stage_13_glare",
			pos = {
				x = 386,
				y = 362
			},
			waves = {{2, 15, 25}, {3, 20, 25}, {5, 30, 25}, {6, 20, 40}}
		},
		{
			template = "controller_terrain_3_local_glare",
			["editor.game_mode"] = 3,
			decal_ground = "decal_stage_13_glare",
			pos = {
				x = 386,
				y = 362
			},
			waves = {{1, 55, 25}, {1, 160, 25}, {1, 230, 40}}
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
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage13_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.flip"] = 0,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = -68,
				y = 317
			}
		},
		{
			["editor.flip"] = 1,
			["editor.orientation"] = 1,
			template = "decal_defend_point",
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			pos = {
				x = 267,
				y = 668
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 248
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -68,
				y = 378
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 346,
				y = 658
			}
		},
		{
			["editor.flip"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 188,
				y = 664
			}
		},
		{
			template = "decal_stage_13_mask_1",
			pos = {
				x = 1041,
				y = 264
			}
		},
		{
			template = "decal_stage_13_mask_2",
			pos = {
				x = 657,
				y = 612
			}
		},
		{
			template = "decal_stage_13_mask_3",
			pos = {
				x = -126,
				y = 705
			}
		},
		{
			template = "decal_stage_13_mask_4",
			pos = {
				x = -96,
				y = 32
			}
		},
		{
			template = "decal_stage_13_tentacles",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			min_delay = 7,
			template = "background_sounds",
			max_delay = 13,
			only_on_preparation = true,
			sounds = {"Terrain3AmbienceSoundGutural"}
		},
		{
			["render.sprites[1].sort_y_offset"] = 16,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = 269.32,
				y = 17.15
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 17,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_01",
			pos = {
				x = 226.38,
				y = 17.75
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 26,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_05",
			pos = {
				x = 252.88,
				y = 29.3
			},
			["render.sprites[1].scale"] = {
				x = 0.62,
				y = 0.75
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 10,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 803.8,
				y = 31.4
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 20,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 94.2,
				y = 50.75
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 21,
			["render.sprites[1].flip_x"] = true,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_05",
			pos = {
				x = 79.1,
				y = 61.18
			},
			["render.sprites[1].scale"] = {
				x = 0.69,
				y = 0.69
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 13,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = 434.52,
				y = 65.05
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 7,
			["render.sprites[1].flip_x"] = true,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_05",
			pos = {
				x = 1208.8,
				y = 70.08
			},
			["render.sprites[1].scale"] = {
				x = 0.93,
				y = 0.93
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 19,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = 113.47,
				y = 70.6
			},
			["render.sprites[1].scale"] = {
				x = 0.88,
				y = 0.88
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 12,
			["render.sprites[1].flip_x"] = true,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_01",
			pos = {
				x = 453.77,
				y = 81
			},
			["render.sprites[1].scale"] = {
				x = 0.57,
				y = 0.57
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 14,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 421.5,
				y = 87.45
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 18,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = 223.97,
				y = 92.6
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 15,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 370.5,
				y = 110.9
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 24,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = -68.27,
				y = 119.1
			},
			["render.sprites[1].scale"] = {
				x = 0.91,
				y = 0.91
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 9,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 847.17,
				y = 123.3
			},
			["render.sprites[1].scale"] = {
				x = 0.93,
				y = 0.93
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 11,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 804.8,
				y = 131.3
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 8,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 1037.17,
				y = 135.43
			},
			["render.sprites[1].scale"] = {
				x = 0.73,
				y = 0.73
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 22,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = -131.92,
				y = 144.55
			},
			["render.sprites[1].scale"] = {
				x = 0.88,
				y = 0.88
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 23,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = -11.2,
				y = 152.75
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 25,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0.11,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = -164.38,
				y = 213.7
			},
			["render.sprites[1].scale"] = {
				x = 1.19,
				y = 1.02
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 1,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_10",
			pos = {
				x = -53.42,
				y = 472.85
			},
			["render.sprites[1].scale"] = {
				x = 0.88,
				y = 0.88
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 6,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_01",
			pos = {
				x = 970.63,
				y = 492.85
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 27,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 987.35,
				y = 493.2
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 0,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "terrain_3_floating_statue_1",
			pos = {
				x = 1022,
				y = 538
			},
			["render.sprites[1].scale"] = {
				x = 0.84,
				y = 0.84
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 2,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = -38.35,
				y = 621.65
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 3,
			["render.sprites[1].flip_x"] = true,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_01",
			pos = {
				x = -7.98,
				y = 628.5
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 4,
			["render.sprites[1].flip_x"] = false,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_02",
			pos = {
				x = 416.4,
				y = 643.05
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["render.sprites[1].sort_y_offset"] = 5,
			["render.sprites[1].flip_x"] = true,
			["render.sprites[1].r"] = 0,
			["render.sprites[1].z"] = 3000,
			template = "decal_terrain_3_floating_rock",
			["render.sprites[1].draw_order"] = 2,
			["render.sprites[1].name"] = "T3_Stage_12_floating_01",
			pos = {
				x = 396.82,
				y = 666.2
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 150,
			pos = {
				x = 959,
				y = 263
			}
		},
		{
			["editor.r"] = 0.90757121103707,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 120,
			pos = {
				x = 591,
				y = 607
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1013,
				y = 626
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 659
			}
		},
		{
			["editor.r"] = 0.69813170079773,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 1026,
				y = 671
			}
		},
		{
			template = "ps_terrain_3_spores_1",
			pos = {
				x = 512,
				y = 0
			}
		},
		{
			template = "ps_terrain_3_spores_2",
			pos = {
				x = 512,
				y = 0
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 410,
				y = 279
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 410,
				y = 279
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 430,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 410,
				y = 279
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 800,
				y = 419
			},
			["tower.default_rally_pos"] = {
				x = 653,
				y = 392
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 800,
				y = 419
			},
			["tower.default_rally_pos"] = {
				x = 653,
				y = 392
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 800,
				y = 419
			},
			["tower.default_rally_pos"] = {
				x = 653,
				y = 392
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 330,
				y = 550
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 491
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 330,
				y = 550
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 491
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 20,
			template = "tower_holder_blocked_terrain_3",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 330,
				y = 550
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 491
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 313,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 296,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 313,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 296,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 313,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 296,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 550,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 578,
				y = 280
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 550,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 578,
				y = 280
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 550,
				y = 189
			},
			["tower.default_rally_pos"] = {
				x = 578,
				y = 280
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 822,
				y = 288
			},
			["tower.default_rally_pos"] = {
				x = 795,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 822,
				y = 288
			},
			["tower.default_rally_pos"] = {
				x = 795,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 822,
				y = 288
			},
			["tower.default_rally_pos"] = {
				x = 795,
				y = 228
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 708,
				y = 293
			},
			["tower.default_rally_pos"] = {
				x = 674,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 708,
				y = 293
			},
			["tower.default_rally_pos"] = {
				x = 674,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 708,
				y = 293
			},
			["tower.default_rally_pos"] = {
				x = 674,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 205,
				y = 327
			},
			["tower.default_rally_pos"] = {
				x = 250,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 205,
				y = 327
			},
			["tower.default_rally_pos"] = {
				x = 250,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 205,
				y = 327
			},
			["tower.default_rally_pos"] = {
				x = 250,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 494,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 494,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 494,
				y = 341
			},
			["tower.default_rally_pos"] = {
				x = 507,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 486,
				y = 451
			},
			["tower.default_rally_pos"] = {
				x = 463,
				y = 539
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 486,
				y = 451
			},
			["tower.default_rally_pos"] = {
				x = 463,
				y = 539
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 589,
				y = 451
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 532
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 589,
				y = 451
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 532
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 271,
				y = 480
			},
			["tower.default_rally_pos"] = {
				x = 187,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 271,
				y = 480
			},
			["tower.default_rally_pos"] = {
				x = 187,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 271,
				y = 480
			},
			["tower.default_rally_pos"] = {
				x = 187,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 752,
				y = 576
			},
			["tower.default_rally_pos"] = {
				x = 721,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 752,
				y = 576
			},
			["tower.default_rally_pos"] = {
				x = 721,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 20,
			template = "tower_holder_sea_of_trees_5",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 752,
				y = 576
			},
			["tower.default_rally_pos"] = {
				x = 721,
				y = 504
			}
		},
		{
			["tower.holder_id"] = "72",
			["ui.nav_mesh_id"] = "72",
			template = "tower_stage_13_sunray",
			["editor.game_mode"] = 0,
			pos = {
				x = 97,
				y = 396
			},
			["tower.default_rally_pos"] = {
				x = 55,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "78",
			["ui.nav_mesh_id"] = "78",
			template = "tower_stage_13_sunray",
			["editor.game_mode"] = 3,
			pos = {
				x = 528,
				y = 446
			},
			["tower.default_rally_pos"] = {
				x = 511,
				y = 549
			}
		}
	},
	ignore_walk_backwards_paths = {5, 6},
	invalid_path_ranges = {},
	level_mode_overrides = {{
		max_upgrade_level = 5,
		locked_powers = {},
		locked_towers = {}
	}, {}, {
		available_towers = {"tower_build_ballista", "tower_build_demon_pit"},
		locked_towers = {"tower_build_royal_archers", "tower_build_arcane_wizard", "tower_build_paladin_covenant", "tower_build_tricannon", "tower_build_arborean_emissary", "tower_build_elven_stargazers", "tower_build_rocket_gunners", "tower_build_necromancer", "tower_build_sand"},
		nav_mesh = {
			{7, 2, 72, 3},
			{78, 4, 72, 1},
			{5, nil, 1},
			{78, nil, 2},
			{8, 7, 3},
			[7] = {10, 78, 1, 5},
			[8] = {10, 7, 5},
			[10] = {13, 12, 8},
			[11] = {
				[3] = 78,
				[4] = 12
			},
			[12] = {nil, 11, 78, 13},
			[13] = {nil, 12, 10},
			[72] = {1},
			[78] = {12, nil, 2, 7}
		}
	}},
	nav_mesh = {
		{7, 2, 72, 3},
		{6, 4, 72, 1},
		{5, 1, 1},
		{6, nil, 2, 2},
		{8, 7, 3},
		{9, nil, 2, 7},
		{10, 6, 1, 5},
		{10, 7, 5},
		{12, nil, 6, 7},
		{13, 12, 8},
		{
			[3] = 9,
			[4] = 12
		},
		{nil, 11, 9, 13},
		{nil, 12, 10},
		[72] = {1}
	},
	required_exoskeletons = {"BKtentacle13Def", "sunraytowerDef", "sunraytower_decal1Def", "sunraytower_decal2Def", "sunraytower_hitDef", "stage_13_glareDef"},
	required_sounds = {"stage_13", "music_stage113", "terrain_3_common", "enemies_terrain_3", "tower_barrel"},
	required_textures = {"go_enemies_terrain_3", "go_stage113_bg", "go_stage113", "go_stages_terrain3"},
	scale_required_textures = {"go_towers_barrel"}
}
