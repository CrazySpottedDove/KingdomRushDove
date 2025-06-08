﻿-- chunkname: @./kr3/data/levels/level02_data.lua

return {
	level_terrain_type = 1,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		x = 180,
		y = 356
	},
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"ElvenWoodsAmbienceSound"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage02_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_bambi",
			pos = {
				x = 136,
				y = 562
			},
			run_offset = {
				x = 66,
				y = 20
			}
		},
		{
			template = "decal_bambi",
			["render.sprites[1].flip_x"] = true,
			pos = {
				x = 663,
				y = 680
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 56,
				y = 357
			}
		},
		-- {
		-- 	["delayed_play.min_delay"] = 5,
		-- 	["render.sprites[1].r"] = 0,
		-- 	template = "decal_jumping_fish",
		-- 	["delayed_play.max_delay"] = 10,
		-- 	pos = {
		-- 		x = 580,
		-- 		y = 67
		-- 	},
		-- 	["render.sprites[1].scale"] = {
		-- 		x = 1,
		-- 		y = 1
		-- 	}
		-- },
		-- {
		-- 	["delayed_play.min_delay"] = 5,
		-- 	["render.sprites[1].r"] = 0,
		-- 	template = "decal_jumping_fish",
		-- 	["delayed_play.max_delay"] = 10,
		-- 	pos = {
		-- 		x = 426,
		-- 		y = 124
		-- 	},
		-- 	["render.sprites[1].scale"] = {
		-- 		x = 1,
		-- 		y = 1
		-- 	}
		-- },
		-- {
		-- 	["delayed_play.min_delay"] = 5,
		-- 	["render.sprites[1].r"] = 0,
		-- 	template = "decal_jumping_fish",
		-- 	["delayed_play.max_delay"] = 10,
		-- 	pos = {
		-- 		x = 519,
		-- 		y = 628
		-- 	},
		-- 	["render.sprites[1].scale"] = {
		-- 		x = 1,
		-- 		y = 1
		-- 	}
		-- },
		-- {
		-- 	["delayed_play.min_delay"] = 5,
		-- 	["render.sprites[1].r"] = 0,
		-- 	template = "decal_jumping_fish",
		-- 	["delayed_play.max_delay"] = 10,
		-- 	pos = {
		-- 		x = 463,
		-- 		y = 743
		-- 	},
		-- 	["render.sprites[1].scale"] = {
		-- 		x = 1,
		-- 		y = 1
		-- 	}
		-- },
		{
			template = "decal_rabbit",
			pos = {
				x = 815,
				y = 130
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 136,
				y = 489
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 185,
				y = 518
			}
		},
		{
			template = "decal_stage_02_bigwaves",
			pos = {
				x = 459,
				y = 634
			}
		},
		{
			template = "decal_stage_02_bridge_mask",
			["render.sprites[1].sort_y_offset"] = -5,
			pos = {
				x = 489,
				y = 541
			}
		},
		{
			template = "decal_stage_02_bridge_shadows",
			pos = {
				x = 503,
				y = 125
			}
		},
		{
			template = "decal_stage_02_stone_1",
			pos = {
				x = 337,
				y = 721
			}
		},
		{
			template = "decal_stage_02_stone_2",
			pos = {
				x = 415,
				y = 44
			}
		},
		{
			template = "decal_stage_02_stone_2",
			pos = {
				x = 505,
				y = 711
			}
		},
		{
			template = "decal_stage_02_stone_3",
			pos = {
				x = 397,
				y = 38
			}
		},
		{
			template = "decal_stage_02_stone_3",
			pos = {
				x = 376,
				y = 101
			}
		},
		{
			template = "decal_stage_02_stone_3",
			pos = {
				x = 478,
				y = 682
			}
		},
		{
			template = "decal_stage_02_stone_4",
			pos = {
				x = 315,
				y = 660
			}
		},
		{
			template = "decal_stage_02_stone_5",
			pos = {
				x = 386,
				y = 608
			}
		},
		{
			template = "decal_stage_02_stone_6",
			pos = {
				x = 633,
				y = 73
			}
		},
		{
			template = "decal_stage_02_stone_6",
			pos = {
				x = 535,
				y = 570
			}
		},
		{
			template = "decal_stage_02_stone_6",
			pos = {
				x = 337,
				y = 720
			}
		},
		{
			template = "decal_stage_02_waterfall_1",
			pos = {
				x = 347,
				y = 679
			}
		},
		{
			template = "decal_stage_02_waterfall_2",
			pos = {
				x = 469,
				y = 577
			}
		},
		{
			template = "decal_stage_02_waterfall_3",
			pos = {
				x = 455,
				y = 690
			}
		},
		{
			template = "decal_stage_02_waterfall_4",
			pos = {
				x = 502,
				y = 689
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 370,
				y = -11
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 468,
				y = 7
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 566,
				y = 19
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 420,
				y = 136
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 583,
				y = 136
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 410,
				y = 555
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 528,
				y = 608
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 477,
				y = 643
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 389,
				y = 654
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 460,
				y = 758
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 318,
				y = 767
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_sparks_small",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 398,
				y = 796
			},
			["render.sprites[1].scale"] = {
				x = 0.6,
				y = 0.6
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 388,
				y = 47
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 426,
				y = 48
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 615,
				y = 79
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 636,
				y = 83
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 385,
				y = 106
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 369,
				y = 107
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 510,
				y = 565
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 522,
				y = 583
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 540,
				y = 585
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 417,
				y = 594
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 417,
				y = 609
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 400,
				y = 621
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 383,
				y = 629
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 365,
				y = 633
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 334,
				y = 653
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 554,
				y = 661
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 559,
				y = 677
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 462,
				y = 681
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 383,
				y = 689
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 546,
				y = 689
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 470,
				y = 692
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 533,
				y = 694
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].flip_x"] = true,
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 433,
				y = 695
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 489,
				y = 714
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_splash",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_water_splash_play",
			pos = {
				x = 316,
				y = 718
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 1.8325957145940461,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 320,
				y = -12
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -1.239183768915974,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 617,
				y = 32
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 0.7504915783575616,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 329,
				y = 46
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 0.7504915783575616,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 552,
				y = 58
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -1.0297442586766543,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 442,
				y = 66
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 0.4363323129985824,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 379,
				y = 122
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.5585053606381855,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 610,
				y = 159
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.15707963267948966,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 469,
				y = 536
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 0.9250245035569946,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 385,
				y = 547
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.05235987755982988,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 489,
				y = 547
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.4363323129985824,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 439,
				y = 552
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 0.06981317007977318,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 570,
				y = 552
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = 1.0821041362364843,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 379,
				y = 561
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.3839724354387525,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 454,
				y = 561
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -0.4886921905584123,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 418,
				y = 570
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_3",
			["render.sprites[1].r"] = -1.1519173063162575,
			["render.sprites[1].name"] = "decal_water_wave_3_play",
			pos = {
				x = 563,
				y = 607
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.10471975511965977,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 469,
				y = 15
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.10471975511965977,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 342,
				y = 23
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.10471975511965977,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 578,
				y = 46
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.10471975511965977,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 581,
				y = 159
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.10471975511965977,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 420,
				y = 160
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = 0.6981317007977318,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 360,
				y = 671
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.19198621771937624,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 458,
				y = 733
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = -0.2617993877991494,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 381,
				y = 749
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = 0.5235987755982988,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 319,
				y = 767
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_wave_4",
			["render.sprites[1].r"] = 0.03490658503988659,
			["render.sprites[1].name"] = "decal_water_wave_4_play",
			pos = {
				x = 411,
				y = 788
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -0.2443460952792,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 208
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 362
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 981,
				y = 386
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 988,
				y = 386
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 409
			}
		},
		{
			["editor.r"] = 0.20943951023932,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 622
			}
		},
		{
			["tower.holder_id"] = "27",
			template = "tower_barrack_1",
			["editor.game_mode"] = 1,
			["tower.terrain_style"] = 1,
			["barrack.rally_pos"] = {
				x = 308,
				y = 249
			},
			pos = {
				x = 258,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 308,
				y = 249
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_barrack_1",
			["editor.game_mode"] = 3,
			pos = {
				x = 397,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "29",
			["tower.terrain_style"] = 1,
			template = "tower_barrack_1",
			["editor.game_mode"] = 3,
			pos = {
				x = 592,
				y = 384
			},
			["tower.default_rally_pos"] = {
				x = 576,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 732,
				y = 192
			},
			["tower.default_rally_pos"] = {
				x = 718,
				y = 291
			}
		},
		{
			["tower.holder_id"] = "27",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 258,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 320,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "27",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 3,
			pos = {
				x = 258,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 320,
				y = 278
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			pos = {
				x = 397,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 397,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 387,
				y = 283
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 655,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 650,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 274,
				y = 335
			},
			["tower.default_rally_pos"] = {
				x = 262,
				y = 279
			}
		},
		{
			["tower.holder_id"] = "29",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			pos = {
				x = 592,
				y = 384
			},
			["tower.default_rally_pos"] = {
				x = 576,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "29",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 592,
				y = 384
			},
			["tower.default_rally_pos"] = {
				x = 576,
				y = 465
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 717,
				y = 384
			},
			["tower.default_rally_pos"] = {
				x = 745,
				y = 316
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 339,
				y = 388
			},
			["tower.default_rally_pos"] = {
				x = 326,
				y = 469
			}
		},
		{
			["tower.holder_id"] = "25",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 264,
				y = 508
			},
			["tower.default_rally_pos"] = {
				x = 247,
				y = 433
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 729,
				y = 509
			},
			["tower.default_rally_pos"] = {
				x = 703,
				y = 462
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
				"tower_archer_3",
				"tower_barrack_3",
				"tower_mage_3",
				"tower_engineer_3"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_archer_3",
				"tower_barrack_3",
				"tower_mage_3",
				"tower_engineer_3"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_archer_3",
				"tower_barrack_3",
				"tower_build_mage",
				"tower_build_engineer"
			}
		}
	},
	nav_mesh = {
		[20] = {
			28,
			25,
			24,
			27
		},
		[21] = {
			nil,
			26,
			27
		},
		[22] = {
			nil,
			nil,
			25,
			23
		},
		[23] = {
			nil,
			22,
			26,
			21
		},
		[24] = {
			20,
			25,
			nil,
			27
		},
		[25] = {
			22,
			nil,
			nil,
			20
		},
		[26] = {
			23,
			22,
			29,
			21
		},
		[27] = {
			21,
			24
		},
		[28] = {
			29,
			20,
			20,
			27
		},
		[29] = {
			26,
			22,
			28,
			26
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage50",
		"ElvenWoodsAmbienceSounds"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_stage50",
		"go_stage50_bg",
		"go_stages_elven_woods"
	}
}
