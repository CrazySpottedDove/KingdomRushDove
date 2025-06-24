﻿-- chunkname: @./kr3/data/levels/level09_data.lua
local function faerie_dragon_preset(this)
    this.powers.more_dragons.level = 0
    this.powers.more_dragons.changed = nil
end
return {
	locked_hero = false,
	level_terrain_type = 2,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "aura_waterfall_entrance",
			pos = {
				x = 0,
				y = 0
			},
			waterfall_nodes = {
				{
					flags = 4294967295,
					to = 18,
					from = 1,
					path_id = 1
				},
				{
					flags = 4294967295,
					to = 19,
					from = 1,
					path_id = 2
				},
				{
					flags = 4294967295,
					to = 19,
					from = 1,
					path_id = 8
				}
			}
		},
		{
			template = "background_sounds",
			sounds = {
				"FaerieGroveAmbienceSound"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage09_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].alpha"] = 100,
			template = "decal_crystal_water_waves2",
			["delayed_play.max_delay"] = 3,
			["render.sprites[1].r"] = -0.7504915783575616,
			pos = {
				x = 290,
				y = 421
			},
			["render.sprites[1].scale"] = {
				x = 0.5,
				y = 0.5
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].alpha"] = 100,
			template = "decal_crystal_water_waves2",
			["delayed_play.max_delay"] = 3,
			["render.sprites[1].r"] = -0.7504915783575616,
			pos = {
				x = 315,
				y = 464
			},
			["render.sprites[1].scale"] = {
				x = 0.64,
				y = 0.64
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].alpha"] = 100,
			template = "decal_crystal_water_waves2",
			["delayed_play.max_delay"] = 3,
			["render.sprites[1].r"] = 0.8028514559173915,
			pos = {
				x = 717,
				y = 499
			},
			["render.sprites[1].scale"] = {
				x = 0.76,
				y = 0.76
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].alpha"] = 100,
			template = "decal_crystal_water_waves2",
			["delayed_play.max_delay"] = 3,
			["render.sprites[1].r"] = -0.7504915783575616,
			pos = {
				x = 318,
				y = 541
			},
			["render.sprites[1].scale"] = {
				x = 0.99,
				y = 0.99
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].alpha"] = 100,
			template = "decal_crystal_water_waves2",
			["delayed_play.max_delay"] = 3,
			["render.sprites[1].r"] = 0.715584993317675,
			pos = {
				x = 676,
				y = 566
			},
			["render.sprites[1].scale"] = {
				x = 0.76,
				y = 0.76
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 433,
				y = 75
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 755,
				y = 75
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 362,
				y = 54
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 512,
				y = 54
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_defense_flag",
			pos = {
				x = 697,
				y = 70
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_defense_flag",
			pos = {
				x = 831,
				y = 73
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 745,
				y = 24
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 25,
				y = 141
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 651,
				y = 145
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = -156,
				y = 162
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 189,
				y = 174
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 1072,
				y = 472
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_1",
			["editor.game_mode"] = 1,
			pos = {
				x = 1186,
				y = 512
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_2",
			["editor.game_mode"] = 1,
			pos = {
				x = 749,
				y = -38
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_2",
			["editor.game_mode"] = 1,
			pos = {
				x = -47,
				y = 116
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_2",
			["editor.game_mode"] = 1,
			pos = {
				x = 738,
				y = 132
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_2",
			["editor.game_mode"] = 1,
			pos = {
				x = 133,
				y = 145
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_2",
			["editor.game_mode"] = 1,
			pos = {
				x = 1012,
				y = 514
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_3",
			["editor.game_mode"] = 1,
			pos = {
				x = 773,
				y = 71
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_3",
			["editor.game_mode"] = 1,
			pos = {
				x = -141,
				y = 100
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_3",
			["editor.game_mode"] = 1,
			pos = {
				x = 48,
				y = 177
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_3",
			["editor.game_mode"] = 1,
			pos = {
				x = 1117,
				y = 516
			}
		},
		{
			["editor.tag"] = 2,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = 684,
				y = 90
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = -81,
				y = 147
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = -45,
				y = 181
			}
		},
		{
			["editor.tag"] = 1,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = 119,
				y = 190
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = 1164,
				y = 466
			}
		},
		{
			["editor.tag"] = 3,
			template = "decal_s09_crystal_4",
			["editor.game_mode"] = 1,
			pos = {
				x = 975,
				y = 468
			}
		},
		{
			["render.sprites[1].z"] = 1300,
			template = "decal_s09_land_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			["render.sprites[1].name"] = "Stage09_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].z"] = 1300,
			template = "decal_s09_land_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			["render.sprites[1].name"] = "Stage09_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].z"] = 1300,
			template = "decal_s09_land_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 3,
			["render.sprites[1].name"] = "Stage09_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_s09_waterfall",
			pos = {
				x = 521,
				y = 735
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 566,
				y = 385
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 371,
				y = 411
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 349,
				y = 524
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 661,
				y = 524
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 538,
				y = 541
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = -148,
				y = 28
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 244,
				y = 96
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 75,
				y = 382
			}
		},
		{
			template = "decal_wisp_1",
			pos = {
				x = 366,
				y = 691
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_10",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 510,
				y = 594
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = -161,
				y = 325
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = 934,
				y = 641
			}
		},
		{
			template = "decal_wisp_2",
			pos = {
				x = -44,
				y = 737
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 628,
				y = 68
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 946,
				y = 122
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 1165,
				y = 389
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = -146,
				y = 402
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 255,
				y = 692
			}
		},
		{
			template = "decal_wisp_3",
			pos = {
				x = 628,
				y = 692
			}
		},
		{
			template = "decal_wisp_4",
			pos = {
				x = 949,
				y = 357
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_5",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 308,
				y = 82
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 578,
				y = 103
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_6",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = -115,
				y = 663
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
				x = 865,
				y = 84
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
				x = 1117,
				y = 676
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_9",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 1137,
				y = 93
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 3,
			["render.sprites[1].r"] = 0,
			template = "decal_wisp_9",
			["delayed_play.max_delay"] = 6,
			pos = {
				x = 71,
				y = 325
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = 3.1939525311496,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 46,
				y = 165
			}
		},
		{
			["editor.r"] = 3.5318969970888e-15,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 983,
				y = 209
			}
		},
		{
			["editor.r"] = 3.5318969970888e-15,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 983,
				y = 259
			}
		},
		{
			["editor.r"] = 0.08726646259972,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 988,
				y = 504
			}
		},
		{
			["editor.r"] = 2.8448866807507,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 42,
				y = 511
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 8,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 474,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 568,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 520,
				y = 721
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_barrack_1",
			["editor.game_mode"] = 3,
			pos = {
				x = 134,
				y = 234
			},
			["tower.default_rally_pos"] = {
				x = 189,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_barrack_1",
			["editor.game_mode"] = 3,
			pos = {
				x = 861,
				y = 308
			},
			["tower.default_rally_pos"] = {
				x = 851,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 3,
			pos = {
				x = 343,
				y = 145
			},
			["tower.default_rally_pos"] = {
				x = 434,
				y = 119
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 3,
			pos = {
				x = 716,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 630,
				y = 253
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 1,
			pos = {
				x = 327,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 321,
				y = 232
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 2,
			pos = {
				x = 327,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 321,
				y = 232
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 1,
			pos = {
				x = 706,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 765,
				y = 327
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_faerie_dragon",
			["editor.game_mode"] = 2,
			pos = {
				x = 706,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 765,
				y = 327
			},
            ["preset"] = faerie_dragon_preset
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 534,
				y = 144
			},
			["tower.default_rally_pos"] = {
				x = 505,
				y = 223
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 343,
				y = 145
			},
			["tower.default_rally_pos"] = {
				x = 434,
				y = 119
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 343,
				y = 145
			},
			["tower.default_rally_pos"] = {
				x = 434,
				y = 119
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 806,
				y = 175
			},
			["tower.default_rally_pos"] = {
				x = 808,
				y = 262
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 716,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 630,
				y = 253
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 716,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 630,
				y = 253
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 134,
				y = 234
			},
			["tower.default_rally_pos"] = {
				x = 189,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 134,
				y = 234
			},
			["tower.default_rally_pos"] = {
				x = 189,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 439,
				y = 261
			},
			["tower.default_rally_pos"] = {
				x = 436,
				y = 209
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 3,
			pos = {
				x = 327,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 321,
				y = 232
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 551,
				y = 284
			},
			["tower.default_rally_pos"] = {
				x = 567,
				y = 232
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 1,
			pos = {
				x = 861,
				y = 308
			},
			["tower.default_rally_pos"] = {
				x = 851,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 2,
			pos = {
				x = 861,
				y = 308
			},
			["tower.default_rally_pos"] = {
				x = 851,
				y = 252
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 653,
				y = 329
			},
			["tower.default_rally_pos"] = {
				x = 671,
				y = 277
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 263,
				y = 336
			},
			["tower.default_rally_pos"] = {
				x = 227,
				y = 267
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 3,
			pos = {
				x = 706,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 765,
				y = 327
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 796,
				y = 441
			},
			["tower.default_rally_pos"] = {
				x = 815,
				y = 385
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 221,
				y = 452
			},
			["tower.default_rally_pos"] = {
				x = 165,
				y = 401
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 2,
			template = "tower_holder_faerie_grove",
			["editor.game_mode"] = 0,
			pos = {
				x = 784,
				y = 516
			},
			["tower.default_rally_pos"] = {
				x = 871,
				y = 553
			}
		}
	},
	invalid_path_ranges = {
		{
			flags = 4294967295,
			to = 18,
			from = 1,
			path_id = 1
		},
		{
			flags = 4294967295,
			to = 19,
			from = 1,
			path_id = 2
		},
		{
			flags = 4294967295,
			to = 19,
			from = 1,
			path_id = 8
		}
	},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
			}
		},
		{
			max_upgrade_level = 4,
			locked_towers = {
			}
		},
		{
			max_upgrade_level = 4,
			locked_towers = {
				"tower_build_barrack",
				"tower_build_mage",
			}
		}
	},
    unlock_towers = {"tower_high_elven", "tower_faerie_dragon"},
	nav_mesh = {
		{
			4,
			2,
			8,
			15
		},
		{
			1,
			7,
			8,
			1
		},
		{
			6,
			nil,
			4,
			13
		},
		{
			3,
			nil,
			1,
			15
		},
		{
			10,
			10,
			6,
			6
		},
		{
			12,
			5,
			3,
			14
		},
		{
			9,
			nil,
			8,
			2
		},
		{
			1,
			7
		},
		{
			nil,
			nil,
			7,
			10
		},
		{
			nil,
			9,
			5,
			12
		},
		{
			nil,
			12,
			14
		},
		{
			nil,
			10,
			6,
			11
		},
		{
			14,
			3,
			15
		},
		{
			11,
			6,
			13
		},
		{
			13,
			1,
			8
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage57",
		"ElvesLevelNineSounds",
		"ElvesCreepHoplite",
		"ElvesScourger",
		"ElvesCreepAvenger",
		"FaerieGroveAmbienceSounds"
	},
	required_textures = {
		"go_enemies_faerie_grove",
		"go_stage57",
		"go_stage57_bg",
		"go_stages_faerie_grove"
	}
}
