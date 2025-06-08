﻿-- chunkname: @./kr3/data/levels/level19_data.lua

return {
	show_comic_idx = 8,
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"MetropolisAmbienceSound"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage19_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 624,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage19_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 65,
				y = 242
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 65,
				y = 467
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 55,
				y = 168
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 44,
				y = 306
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 44,
				y = 397
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 39,
				y = 523
			}
		},
		{
			template = "decal_s19_drizzt",
			pos = {
				x = 107,
				y = 656
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 822,
				y = 91
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 319,
				y = 104
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 121,
				y = 120
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 319,
				y = 746
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 705,
				y = 732
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 383,
				y = 85
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 887,
				y = 91
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 193,
				y = 115
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = -38,
				y = 710
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 382,
				y = 757
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 745,
				y = 95
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 953,
				y = 100
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 244,
				y = 127
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 46,
				y = 142
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 244,
				y = 742
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 771,
				y = 742
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 202,
				y = 587
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 881,
				y = 310
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_7",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 989,
				y = 284
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_8",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 455,
				y = 83
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 20,
			pos = {
				x = 579,
				y = 77
			}
		},
		{
			["editor.r"] = 0.17453292519947,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 162
			}
		},
		{
			["editor.r"] = -0.1745329251994,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 572
			}
		},
		{
			["editor.r"] = -0.1745329251994,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 620
			}
		},
		{
			["editor.r"] = 1.3962634015955,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 557,
				y = 708
			}
		},
		{
			template = "paralyzing_tree",
			pos = {
				x = 605,
				y = 325
			}
		},
		{
			template = "paralyzing_tree",
			pos = {
				x = 646,
				y = 650
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 431,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 400,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 673,
				y = 157
			},
			["tower.default_rally_pos"] = {
				x = 749,
				y = 219
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 867,
				y = 245
			},
			["tower.default_rally_pos"] = {
				x = 870,
				y = 169
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 280,
				y = 314
			},
			["tower.default_rally_pos"] = {
				x = 269,
				y = 251
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 496,
				y = 322
			},
			["tower.default_rally_pos"] = {
				x = 530,
				y = 242
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 717,
				y = 326
			},
			["tower.default_rally_pos"] = {
				x = 644,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 820,
				y = 355
			},
			["tower.default_rally_pos"] = {
				x = 764,
				y = 455
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 164,
				y = 378
			},
			["tower.default_rally_pos"] = {
				x = 153,
				y = 467
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 338,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 400,
				y = 374
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 432,
				y = 494
			},
			["tower.default_rally_pos"] = {
				x = 381,
				y = 560
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 902,
				y = 497
			},
			["tower.default_rally_pos"] = {
				x = 813,
				y = 554
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 685,
				y = 500
			},
			["tower.default_rally_pos"] = {
				x = 663,
				y = 437
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 563,
				y = 502
			},
			["tower.default_rally_pos"] = {
				x = 552,
				y = 592
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 5,
			template = "tower_holder_bittering_rancor",
			["editor.game_mode"] = 0,
			pos = {
				x = 304,
				y = 635
			},
			["tower.default_rally_pos"] = {
				x = 407,
				y = 594
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
				"tower_build_mage"
			}
		}
	},
	nav_mesh = {
		{
			14,
			4,
			2,
			13
		},
		{
			4,
			6,
			nil,
			1
		},
		{
			5,
			6,
			8,
			14
		},
		{
			8,
			6,
			2,
			1
		},
		{
			7,
			nil,
			3,
			11
		},
		{
			3,
			nil,
			nil,
			8
		},
		{
			nil,
			nil,
			5,
			10
		},
		{
			3,
			6,
			4,
			14
		},
		{
			nil,
			10,
			12,
			12
		},
		{
			nil,
			7,
			11,
			9
		},
		{
			10,
			5,
			14,
			12
		},
		{
			9,
			11,
			13
		},
		{
			12,
			14,
			1
		},
		{
			11,
			8,
			1,
			13
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage67",
		"ElvesDrizzt",
		"ElvesCreepServant",
		"ElvesWhiteTree",
		"MetropolisAmbienceSounds",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesScourger",
		"ElvesCreepAvenger",
		"ElvesCreepMountedAvenger",
		"ElvesCreepScreecher"
	},
	required_textures = {
		"go_enemies_ancient_metropolis",
		"go_enemies_bittering_rancor",
		"go_stage67",
		"go_stage67_bg",
		"go_stages_faerie_grove",
		"go_stages_bittering_rancor"
	}
}
