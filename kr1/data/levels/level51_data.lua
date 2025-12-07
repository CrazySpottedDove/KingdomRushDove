-- chunkname: @./kr3/data/levels/level03_data.lua
return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 6,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {"ElvenWoodsAmbienceSound"}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage03_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3100,
			["render.sprites[1].name"] = "Stage03_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_bambi",
			pos = {
				x = 64,
				y = 287
			}
		},
		{
			template = "decal_bambi",
			["render.sprites[1].flip_x"] = true,
			pos = {
				x = 118,
				y = 318
			},
			["render.sprites[1].scale"] = {
				x = 0.7,
				y = 0.7
			}
		},
		{
			template = "decal_crane",
			pos = {
				x = 853,
				y = 143
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 497,
				y = 68
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.767944870877505,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 1031,
				y = -204
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.47123889803846897,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 991,
				y = -25
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.47123889803846897,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 998,
				y = -9
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.47123889803846897,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 974,
				y = -7
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_water_2",
			pos = {
				x = 963,
				y = 14
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.7853981633974483,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 912,
				y = 30
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = -0.5235987755982988,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 721,
				y = 34
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.6283185307179586,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 937,
				y = 37
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.6283185307179586,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 908,
				y = 47
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = -0.5235987755982988,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 733,
				y = 53
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.7853981633974483,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 889,
				y = 81
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = -0.5235987755982988,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 741,
				y = 87
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = -0.767944870877505,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 769,
				y = 96
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.7853981633974483,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 870,
				y = 99
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.7853981633974483,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 834,
				y = 113
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_water_2",
			pos = {
				x = 796,
				y = 124
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.5410520681182421,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 792,
				y = 142
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_stones_water_2",
			pos = {
				x = 658,
				y = 299
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_2_b",
			pos = {
				x = 597,
				y = 380
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 1.4486232791552935,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 111,
				y = 414
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 1.0471975511965976,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 85,
				y = 423
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_2_2",
			pos = {
				x = 593,
				y = 423
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_2_1",
			pos = {
				x = 593,
				y = 425
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_2_4",
			pos = {
				x = 593,
				y = 425
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_2_3",
			pos = {
				x = 593,
				y = 425
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_b",
			pos = {
				x = 55,
				y = 442
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 1.8325957145940461,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 331,
				y = 450
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_water_1",
			pos = {
				x = 553,
				y = 477
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.4537856055185257,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 474,
				y = 482
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_water_2",
			pos = {
				x = 527,
				y = 492
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.6283185307179586,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 509,
				y = 512
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_2",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_3",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_5",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_6",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_1",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_3_4",
			pos = {
				x = 28,
				y = 514
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.5759586531581288,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = 476,
				y = 515
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_water_2",
			pos = {
				x = -8,
				y = 588
			},
			["render.sprites[1].scale"] = {
				x = 0.7,
				y = 0.7
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.45378560551853,
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = -38,
				y = 596
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_stones_water_1",
			pos = {
				x = 440,
				y = 600
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0.43633231299858,
			["render.sprites[1].name"] = "decal_water_wave_1_play",
			pos = {
				x = -56,
				y = 616
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_1_b",
			pos = {
				x = 369,
				y = 702
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_1_3",
			pos = {
				x = 359,
				y = 757
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_1_4",
			pos = {
				x = 359,
				y = 757
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_1_2",
			pos = {
				x = 359,
				y = 757
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s03_cascade_1_1",
			pos = {
				x = 359,
				y = 757
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 303,
				y = 103
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 803,
				y = 583
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 791,
				y = 634
			}
		},
		{
			template = "decal_s03_bridge",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "stage3_bridge",
			pos = {
				x = 175,
				y = 426
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 945,
				y = 25
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 800,
				y = 123
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 1014,
				y = 294
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 294,
				y = 439
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 375,
				y = 462
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 559,
				y = 479
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_water_sparks",
			["render.sprites[1].r"] = 0,
			["editor.device_profile_min"] = "hi",
			["render.sprites[1].name"] = "decal_water_sparks_idle",
			pos = {
				x = 497,
				y = 508
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
				x = -79,
				y = 612
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -0.24434609527920614,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 953,
				y = 42
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -1.0297442586766545,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 900,
				y = 91
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -0.19198621771937624,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 123,
				y = 426
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0.3490658503988659,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 310,
				y = 456
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 413,
				y = 473
			},
			["render.sprites[1].r"] = -0,
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -0.6283185307179586,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			["editor.device_profile_min"] = "hi",
			pos = {
				x = 526,
				y = 517
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 0.069813170079769,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = -76,
				y = 636
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["editor.r"] = -0.069813170079773,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 169
			}
		},
		{
			["editor.r"] = 1.4835298641952,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 696,
				y = 730
			}
		},
		{
			["editor.r"] = 1.6580627893946,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 746,
				y = 730
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 865,
				y = 158
			}
		},
		{
			template = "plant_magic_blossom",
			pos = {
				x = 235,
				y = 495
			}
		},
		{
			template = "river_object_controller"
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_barrack_2",
			["editor.game_mode"] = 3,
			pos = {
				x = 378,
				y = 531
			},
			["tower.default_rally_pos"] = {
				x = 294,
				y = 616
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 575,
				y = 142
			},
			["tower.default_rally_pos"] = {
				x = 480,
				y = 179
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 375,
				y = 151
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 155
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 175,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 220,
				y = 282
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 787,
				y = 229
			},
			["tower.default_rally_pos"] = {
				x = 787,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 486,
				y = 258
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 199
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 311,
				y = 289
			},
			["tower.default_rally_pos"] = {
				x = 289,
				y = 240
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 729,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 719,
				y = 309
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 881,
				y = 357
			},
			["tower.default_rally_pos"] = {
				x = 850,
				y = 296
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			pos = {
				x = 378,
				y = 531
			},
			["tower.default_rally_pos"] = {
				x = 294,
				y = 616
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			pos = {
				x = 378,
				y = 531
			},
			["tower.default_rally_pos"] = {
				x = 294,
				y = 616
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 585,
				y = 532
			},
			["tower.default_rally_pos"] = {
				x = 563,
				y = 608
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 722,
				y = 557
			},
			["tower.default_rally_pos"] = {
				x = 688,
				y = 651
			}
		},
		{
			["tunnel.pick_fx"] = "fx_waterfall_splash",
			["tunnel.place_pi"] = 4,
			template = "tunnel",
			["tunnel.place_fx"] = "fx_waterfall_splash",
			["tunnel.pick_pi"] = 3,
			pos = {
				x = 0,
				y = 0
			}
		}
	},
	invalid_path_ranges = {{
		flags = 4294967295,
		path_id = 3,
		from = 64
	}},
	level_mode_overrides = {{
		max_upgrade_level = 6,
		locked_towers = {}
	}, {
		max_upgrade_level = 3,
		locked_towers = {}
	}, {
		max_upgrade_level = 3,
		locked_towers = {"tower_build_archer", "tower_build_mage"}
	}},
	nav_mesh = {
		{4, 5, 2},
		{1, 6, 3},
		{2, 6, nil, 2},
		{nil, 7, 1},
		{7, 10, 6, 1},
		{5, 9, 3, 2},
		{8, 11, 5, 4},
		{nil, 11, 7, 4},
		{10, nil, nil, 6},
		{11, nil, 9, 5},
		{8, nil, 10, 7}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {"music_stage51", "ElvenWoodsAmbienceSounds", "ElvesLevelThreeSounds", "ElvesPlants", "ElvesCreepHyena"},
	required_textures = {"go_enemies_elven_woods", "go_stage51", "go_stage51_bg", "go_stages_elven_woods"}
}
