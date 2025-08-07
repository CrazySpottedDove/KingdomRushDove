﻿-- chunkname: @./kr1/data/levels/level12_data.lua

return {
	locked_hero = false,
	level_terrain_type = 3,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_12_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 590,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 358,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 316,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 284,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 338,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 329,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 362,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0006",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 376,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_12_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_background",
			["editor.game_mode"] = 2,
			["render.sprites[1].name"] = "stage12_forsale",
			pos = {
				x = 516,
				y = 697
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_background",
			["editor.game_mode"] = 3,
			["render.sprites[1].name"] = "stage12_forsale",
			pos = {
				x = 516,
				y = 697
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_burner_big",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_burner_big_idle",
			pos = {
				x = 329,
				y = 555
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_burner_big",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_burner_big_idle",
			pos = {
				x = 680,
				y = 555
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_burner_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_burner_small_idle",
			pos = {
				x = 280,
				y = 653
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_burner_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_burner_small_idle",
			pos = {
				x = 735,
				y = 653
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
				x = 726,
				y = 54
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 270,
				y = 618
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 30,
			pos = {
				x = 760,
				y = 618
			}
		},
		{
			template = "graveyard_controller",
			["graveyard.spawn_pos"] = {
				{
					x = 109,
					y = 370
				},
				{
					x = 140,
					y = 355
				},
				{
					x = 107,
					y = 333
				},
				{
					x = 200,
					y = 354
				},
				{
					x = 150,
					y = 316
				},
				{
					x = 161,
					y = 340
				}
			},
			pos = {
				x = 201,
				y = 315
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 822,
				y = 143
			},
			["tower.default_rally_pos"] = {
				x = 726,
				y = 95
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 777,
				y = 208
			},
			["tower.default_rally_pos"] = {
				x = 717,
				y = 130
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 393,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 392,
				y = 145
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 492,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 492,
				y = 148
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 588,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 585,
				y = 148
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 685,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 680,
				y = 148
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 332,
				y = 371
			},
			["tower.default_rally_pos"] = {
				x = 339,
				y = 308
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 436,
				y = 371
			},
			["tower.default_rally_pos"] = {
				x = 434,
				y = 310
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 535,
				y = 371
			},
			["tower.default_rally_pos"] = {
				x = 535,
				y = 309
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 747,
				y = 383
			},
			["tower.default_rally_pos"] = {
				x = 743,
				y = 326
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 761,
				y = 450
			},
			["tower.default_rally_pos"] = {
				x = 638,
				y = 410
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 750,
				y = 519
			},
			["tower.default_rally_pos"] = {
				x = 857,
				y = 521
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 3,
			template = "tower_holder_wasteland",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 282,
				y = 528
			},
			["tower.default_rally_pos"] = {
				x = 280,
				y = 467
			}
		},
		{
			template = "veznan_portal",
			["editor.game_mode"] = 0,
			portal_idx = 3,
			out_nodes = {
				221
			},
			pos = {
				x = 520,
				y = 137
			}
		},
		{
			template = "veznan_portal",
			["editor.game_mode"] = 0,
			portal_idx = 2,
			out_nodes = {
				146
			},
			pos = {
				x = 520,
				y = 300
			}
		},
		{
			template = "veznan_portal",
			["editor.game_mode"] = 0,
			portal_idx = 1,
			out_nodes = {
				101
			},
			pos = {
				x = 520,
				y = 453
			}
		}
	},
	invalid_path_ranges = {
		{
			from = 1,
			to = 10,
			path_id = 1
		},
		{
			from = 1,
			to = 10,
			path_id = 2
		}
	},
	level_mode_overrides = {
		{
			max_upgrade_level = 6
		},
		{
			max_upgrade_level = 6
		},
		{
			max_upgrade_level = 6,
			locked_towers = {
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		{
			nil,
			2,
			6
		},
		{
			nil,
			10,
			6,
			1
		},
		{
			4,
			7
		},
		{
			5,
			8,
			3
		},
		{
			6,
			9,
			4
		},
		{
			2,
			10,
			5
		},
		{
			8,
			13,
			nil,
			3
		},
		{
			9,
			13,
			7,
			4
		},
		{
			10,
			nil,
			8,
			5
		},
		{
			nil,
			11,
			9,
			2
		},
		{
			nil,
			12,
			9,
			10
		},
		{
			[3] = 13,
			[4] = 11
		},
		{
			12,
			nil,
			nil,
			7
		}
	},
	required_sounds = {
		"music_stage12",
		"VeznanEffects"
	},
	required_textures = {
		"go_enemies_wastelands",
		"go_stage12",
		"go_stage12_bg"
	}
}
