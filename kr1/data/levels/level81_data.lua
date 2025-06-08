﻿-- chunkname: @./kr1/data/levels/level81_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_81_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 550,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "stage_81_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 398.25,
				y = 34
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 610,
				y = 34
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 312,
				y = 14
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 482,
				y = 14
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 529,
				y = 14
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 706,
				y = 14
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_endless_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = false,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 434,
				y = 710
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_endless_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = true,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 536,
				y = 710
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_endless_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = true,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 522,
				y = 746
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_endless_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = false,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 451,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 1005,
				y = 502
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 881,
				y = 566
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_burner",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_burner_idle",
			pos = {
				x = 444,
				y = 660
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 3000,
			template = "decal_orc_flag",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_orc_flag_idle",
			pos = {
				x = 571,
				y = 683
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s81_percussionist",
			pos = {
				x = 531,
				y = 646
			}
		},
		{
			template = "eb_elder_shaman",
			pos = {
				x = 484,
				y = 709
			}
		},
		{
			["editor.r"] = 0.87266462599717,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 70,
			pos = {
				x = 921,
				y = 510
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 70,
			pos = {
				x = 292,
				y = 723
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 70,
			pos = {
				x = 336,
				y = 723
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 70,
			pos = {
				x = 686,
				y = 723
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 70,
			pos = {
				x = 731,
				y = 723
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 671,
				y = 122
			},
			["tower.default_rally_pos"] = {
				x = 586,
				y = 132
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 488,
				y = 134
			},
			["tower.default_rally_pos"] = {
				x = 391,
				y = 134
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 787,
				y = 136
			},
			["tower.default_rally_pos"] = {
				x = 791,
				y = 225
			}
		},
		{
			["tower.holder_id"] = "19",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "19",
			pos = {
				x = 125,
				y = 186
			},
			["tower.default_rally_pos"] = {
				x = 224,
				y = 184
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 310,
				y = 206
			},
			["tower.default_rally_pos"] = {
				x = 311,
				y = 148
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 527,
				y = 213
			},
			["tower.default_rally_pos"] = {
				x = 607,
				y = 190
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 657,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 661,
				y = 214
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 281,
				y = 268
			},
			["tower.default_rally_pos"] = {
				x = 192,
				y = 242
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 860,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 866,
				y = 218
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 569,
				y = 305
			},
			["tower.default_rally_pos"] = {
				x = 469,
				y = 313
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 209,
				y = 307
			},
			["tower.default_rally_pos"] = {
				x = 133,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 365,
				y = 310
			},
			["tower.default_rally_pos"] = {
				x = 423,
				y = 246
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 822,
				y = 364
			},
			["tower.default_rally_pos"] = {
				x = 749,
				y = 310
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 635,
				y = 369
			},
			["tower.default_rally_pos"] = {
				x = 724,
				y = 382
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 470,
				y = 438
			},
			["tower.default_rally_pos"] = {
				x = 454,
				y = 383
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "17",
			pos = {
				x = 246,
				y = 441
			},
			["tower.default_rally_pos"] = {
				x = 259,
				y = 388
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 151,
				y = 442
			},
			["tower.default_rally_pos"] = {
				x = 173,
				y = 383
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 814,
				y = 465
			},
			["tower.default_rally_pos"] = {
				x = 905,
				y = 425
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 403,
				y = 504
			},
			["tower.default_rally_pos"] = {
				x = 349,
				y = 453
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 621,
				y = 526
			},
			["tower.default_rally_pos"] = {
				x = 628,
				y = 466
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_grass",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 350,
				y = 554
			},
			["tower.default_rally_pos"] = {
				x = 280,
				y = 521
			}
		}
	},
	invalid_path_ranges = {
		{
			flags = 4294967295,
			to = 11,
			from = 1,
			path_id = 5
		}
	},
	level_mode_overrides = {
		{},
		{},
		{}
	},
	nav_mesh = {
		{
			4,
			nil,
			17,
			2
		},
		{
			4,
			1,
			17,
			3
		},
		{
			4,
			2,
			17,
			13
		},
		{
			5,
			nil,
			3,
			8
		},
		{
			[3] = 4,
			[4] = 6
		},
		{
			nil,
			5,
			8,
			7
		},
		{
			nil,
			6,
			10,
			21
		},
		{
			6,
			4,
			9,
			10
		},
		{
			10,
			3,
			13,
			11
		},
		{
			7,
			8,
			9,
			20
		},
		{
			10,
			9,
			13,
			12
		},
		{
			20,
			11,
			16
		},
		{
			9,
			3,
			14,
			16
		},
		{
			13,
			17,
			15,
			16
		},
		{
			14,
			18,
			nil,
			19
		},
		{
			12,
			14,
			19
		},
		{
			3,
			1,
			18,
			15
		},
		{
			17,
			1,
			nil,
			15
		},
		{
			16,
			15
		},
		{
			21,
			10,
			12
		},
		{
			nil,
			7,
			20
		}
	},
	pan_extension = {
		bottom = -10,
		top = 20
	},
	required_sounds = {
		"music_stage81",
		"EndlessOrcsSounds"
	},
	required_textures = {
		"go_enemies_grass",
		"go_enemies_acaroth",
		"go_stages_grass",
		"go_stage14",
		"go_stage81",
		"go_stage81_bg"
	}
}
