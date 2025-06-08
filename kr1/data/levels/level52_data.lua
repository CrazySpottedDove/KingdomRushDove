﻿-- chunkname: @./kr3/data/levels/level04_data.lua

return {
	level_terrain_type = 1,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		x = 303,
		y = 570
	},
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"ElvenWoodsAmbienceSound"
			}
		},
		{
			template = "birds_controller",
			destinations = {
				{
					x = 1047,
					y = 298
				},
				{
					x = 1054,
					y = 275
				},
				{
					x = 777,
					y = 828
				},
				{
					x = 743,
					y = 823
				},
				{
					x = 743,
					y = 823
				},
				{
					x = 184,
					y = 825
				}
			},
			origins = {
				{
					x = 507,
					y = -54
				},
				{
					x = 514,
					y = -77
				},
				{
					x = 1053,
					y = 391
				},
				{
					x = 1054,
					y = 368
				},
				{
					x = 1054,
					y = 368
				},
				{
					x = -26,
					y = 309
				}
			}
		},
		{
			["render.sprites[1].sort_y"] = 344,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage04_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage04_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3100,
			["render.sprites[1].name"] = "Stage04_0005",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_bambi",
			["render.sprites[1].flip_x"] = true,
			pos = {
				x = 836,
				y = 608
			}
		},
		{
			template = "decal_bambi",
			["motion.max_speed"] = 30,
			pos = {
				x = 734,
				y = 634
			},
			["render.sprites[1].scale"] = {
				x = 0.7,
				y = 0.7
			},
			run_offset = {
				x = 34,
				y = 0
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 300,
				y = 718
			}
		},
		{
			template = "decal_george_jungle",
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 540,
				y = 114
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 491,
				y = 143
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -66,
				y = 168
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 436,
				y = 191
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 11,
				y = 198
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -154,
				y = 205
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 126,
				y = 205
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -87,
				y = 221
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 63,
				y = 224
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 583,
				y = 95
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 608,
				y = 111
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 422,
				y = 142
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 11,
				y = 166
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 553,
				y = 178
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 73,
				y = 181
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 501,
				y = 190
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 97,
				y = 203
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 18,
				y = 217
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -30,
				y = 231
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -183,
				y = 243
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -143,
				y = 260
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 608,
				y = 111
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 18,
				y = 144
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 591,
				y = 149
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 73,
				y = 154
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -179,
				y = 172
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -112,
				y = 184
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_charcoal_3",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 478,
				y = 222
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_land_1",
			["render.sprites[1].z"] = 1401,
			["render.sprites[1].name"] = "Stage04_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_s04_land_2",
			["render.sprites[1].z"] = 1200,
			["render.sprites[1].name"] = "Stage04_0004",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 6,
				y = 66
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 538,
				y = 72
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 601,
				y = 76
			},
			["render.sprites[1].scale"] = {
				x = 0.78,
				y = 0.78
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -145,
				y = 89
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 76,
				y = 92
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -53,
				y = 106
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 496,
				y = 120
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 422,
				y = 123
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 566,
				y = 126
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 12,
				y = 133
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -84,
				y = 134
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -163,
				y = 142
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 558,
				y = 163
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 129,
				y = 164
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 40,
				y = 167
			},
			["render.sprites[1].scale"] = {
				x = 0.9,
				y = 0.9
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 451,
				y = 167
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -111,
				y = 170
			},
			["render.sprites[1].scale"] = {
				x = 0.9,
				y = 0.9
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -30,
				y = 178
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.9
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 75,
				y = 194
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 17,
				y = 203
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -169,
				y = 214
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -78,
				y = 235
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_s04_tree_burn",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -136,
				y = 237
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_tree_ewok",
			path_id = 5,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			template = "decal_tree_ewok",
			path_id = 6,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			["editor.r"] = -1.3962634015955,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 715,
				y = 53
			}
		},
		{
			["editor.r"] = -1.3962634015955,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 762,
				y = 53
			}
		},
		{
			["editor.r"] = 3.0194196059502,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 43,
				y = 201
			}
		},
		{
			["editor.r"] = -0.17453292519943,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 980,
				y = 465
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 640,
				y = 107
			}
		},
		{
			["render.sprites[1].r"] = -1.5707963267949,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 462,
				y = 142
			}
		},
		{
			["render.sprites[1].r"] = 3.1415926535898,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 620,
				y = 164
			}
		},
		{
			["render.sprites[1].r"] = 1.9198621771938,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 38,
				y = 194
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 165,
				y = 218
			}
		},
		{
			["render.sprites[1].r"] = 1.9198621771938,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -119,
				y = 227
			}
		},
		{
			["render.sprites[1].r"] = 2.6179938779915,
			template = "fx_s04_tree_fire_1",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -162,
				y = 282
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -160,
				y = 171
			}
		},
		{
			["render.sprites[1].r"] = 2.7925268031909,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 394,
				y = 185
			}
		},
		{
			["render.sprites[1].r"] = -0.69813170079773,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -83,
				y = 190
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 432,
				y = 234
			}
		},
		{
			["render.sprites[1].r"] = -0.34906585039887,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 1,
			pos = {
				x = 514,
				y = 236
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 132,
				y = 250
			}
		},
		{
			["render.sprites[1].r"] = 0.34906585039887,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -9,
				y = 261
			}
		},
		{
			["render.sprites[1].r"] = 0,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = 48,
				y = 303
			}
		},
		{
			["render.sprites[1].r"] = -0.69813170079773,
			template = "fx_s04_tree_fire_2",
			["editor.game_mode"] = 1,
			["editor.tag"] = 2,
			pos = {
				x = -115,
				y = 331
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 628,
				y = 198
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 307,
				y = 332
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 894,
				y = 494
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 386,
				y = 572
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_ewok",
			["editor.game_mode"] = 3,
			pos = {
				x = 827,
				y = 222
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 307
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_ewok_holder",
			["editor.game_mode"] = 3,
			pos = {
				x = 276,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 254,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 1,
			template = "tower_ewok_holder",
			["editor.game_mode"] = 1,
			pos = {
				x = 303,
				y = 474
			},
			["tower.default_rally_pos"] = {
				x = 231,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 1,
			template = "tower_ewok_holder",
			["editor.game_mode"] = 2,
			pos = {
				x = 303,
				y = 474
			},
			["tower.default_rally_pos"] = {
				x = 231,
				y = 423
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			["ui.can_click"] = false,
			pos = {
				x = 479,
				y = 127
			},
			["tower.default_rally_pos"] = {
				x = 510,
				y = 199
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 479,
				y = 127
			},
			["tower.default_rally_pos"] = {
				x = 510,
				y = 199
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 3,
			pos = {
				x = 479,
				y = 127
			},
			["tower.default_rally_pos"] = {
				x = 510,
				y = 199
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 798,
				y = 141
			},
			["tower.default_rally_pos"] = {
				x = 705,
				y = 156
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			pos = {
				x = 276,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 254,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 276,
				y = 180
			},
			["tower.default_rally_pos"] = {
				x = 254,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			pos = {
				x = 827,
				y = 222
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 307
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 827,
				y = 222
			},
			["tower.default_rally_pos"] = {
				x = 819,
				y = 307
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 134,
				y = 265
			},
			["tower.default_rally_pos"] = {
				x = 227,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 643,
				y = 265
			},
			["tower.default_rally_pos"] = {
				x = 729,
				y = 236
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 480,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 389,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 775,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 764,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 145,
				y = 383
			},
			["tower.default_rally_pos"] = {
				x = 218,
				y = 338
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 817,
				y = 444
			},
			["tower.default_rally_pos"] = {
				x = 880,
				y = 371
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 3,
			pos = {
				x = 303,
				y = 474
			},
			["tower.default_rally_pos"] = {
				x = 231,
				y = 423
			}
		}
	},
	invalid_path_ranges = {
		{
			flags = 4294967295,
			to = 122,
			from = 95,
			path_id = 1
		},
		{
			flags = 4294967295,
			to = 92,
			from = 65,
			path_id = 2
		}
	},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
				"tower_silver",
				"tower_blade",
				"tower_forest",
				"tower_wild_magus",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_silver",
				"tower_blade",
				"tower_forest",
				"tower_wild_magus",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_silver",
				"tower_build_barrack",
				"tower_build_mage",
				"tower_druid",
				"tower_entwood"
			}
		}
	},
	nav_mesh = {
		[11] = {
			12,
			23,
			22,
			24
		},
		[12] = {
			21,
			16,
			11,
			24
		},
		[13] = {
			23,
			23,
			nil,
			14
		},
		[14] = {
			11,
			13,
			nil,
			22
		},
		[15] = {
			nil,
			nil,
			16,
			16
		},
		[16] = {
			nil,
			15,
			12,
			21
		},
		[17] = {
			nil,
			21,
			24
		},
		[21] = {
			nil,
			16,
			12,
			17
		},
		[22] = {
			11,
			23,
			14
		},
		[23] = {
			11,
			nil,
			13,
			22
		},
		[24] = {
			12,
			11,
			22
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage52",
		"ElvesLevelFourSounds",
		"ElvenWoodsAmbienceSounds",
		"ElvesSpecialEwoks",
		"ElvesPlants",
		"ElvesCreepHyena"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_stage52",
		"go_stage52_bg",
		"go_stages_elven_woods"
	}
}
