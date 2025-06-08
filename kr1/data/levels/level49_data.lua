﻿-- chunkname: @./kr3/data/levels/level01_data.lua

return {
	level_terrain_type = 1,
	locked_hero = false,
	show_comic_idx = 1,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		x = 170,
		y = 371
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
					x = 1038,
					y = 436
				},
				{
					x = 1044,
					y = 413
				},
				{
					x = 649,
					y = 832
				},
				{
					x = 615,
					y = 827
				},
				{
					x = 641,
					y = 832
				},
				{
					x = 608,
					y = 827
				}
			},
			origins = {
				{
					x = 521,
					y = -54
				},
				{
					x = 528,
					y = -77
				},
				{
					x = 1043,
					y = 482
				},
				{
					x = 1044,
					y = 459
				},
				{
					x = -160,
					y = 382
				},
				{
					x = -160,
					y = 359
				}
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage01_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 41,
				y = 369
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_jumping_fish",
			["delayed_play.max_delay"] = 10,
			pos = {
				x = 514,
				y = 617
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_jumping_fish",
			["delayed_play.max_delay"] = 10,
			pos = {
				x = 354,
				y = 717
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_jumping_fish",
			["delayed_play.max_delay"] = 10,
			pos = {
				x = 569,
				y = 731
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_jumping_fish",
			["delayed_play.max_delay"] = 10,
			pos = {
				x = 230,
				y = 741
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_stage01_gandalf",
			["delayed_play.max_delay"] = 15,
			pos = {
				x = 269,
				y = 522
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
				x = 522,
				y = 590
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
				x = 596,
				y = 637
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
				x = 494,
				y = 659
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
				x = 260,
				y = 666
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
				y = 702
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
				x = 569,
				y = 712
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
				x = 261,
				y = 741
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
				x = 342,
				y = 775
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
				x = 178,
				y = 780
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
				x = 593,
				y = 787
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
				x = 715,
				y = 807
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 2.9670597283903604,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 407,
				y = 521
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 3.3161255787892,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 513,
				y = 521
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0.10471975511965977,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 420,
				y = 540
			},
			["render.sprites[1].scale"] = {
				x = 0.54,
				y = 0.54
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = -0.3490658503988659,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 379,
				y = 545
			},
			["render.sprites[1].scale"] = {
				x = 0.54,
				y = 0.54
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = 2.4085543677521746,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 262,
				y = 583
			},
			["render.sprites[1].scale"] = {
				x = 0.54,
				y = 0.54
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -0.7853981633974483,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 298,
				y = 589
			},
			["render.sprites[1].scale"] = {
				x = 0.54,
				y = 0.54
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -2.1467549799530254,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 625,
				y = 589
			},
			["render.sprites[1].scale"] = {
				x = 0.54,
				y = 0.54
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -0.6283185307179586,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 675,
				y = 687
			},
			["render.sprites[1].scale"] = {
				x = 0.4,
				y = 0.4
			}
		},
		{
			["delayed_play.min_delay"] = 1,
			["render.sprites[1].r"] = -2.199114857512855,
			template = "decal_water_wave_delayed_2",
			["delayed_play.max_delay"] = 3,
			pos = {
				x = 750,
				y = 783
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["editor.r"] = -3.0461744238153e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 165
			}
		},
		{
			["editor.r"] = -2.2898349882894e-16,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 987,
				y = 615
			}
		},
		{
			["tower.holder_id"] = "31",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 619,
				y = 190
			},
			["tower.default_rally_pos"] = {
				x = 657,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "45",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 849,
				y = 208
			},
			["tower.default_rally_pos"] = {
				x = 806,
				y = 160
			}
		},
		{
			["tower.holder_id"] = "35",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 281,
				y = 260
			},
			["tower.default_rally_pos"] = {
				x = 347,
				y = 325
			}
		},
		{
			["tower.holder_id"] = "41",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 781,
				y = 276
			},
			["tower.default_rally_pos"] = {
				x = 712,
				y = 240
			}
		},
		{
			["tower.holder_id"] = 29,
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 181,
				y = 329
			},
			["tower.default_rally_pos"] = {
				x = 154,
				y = 406
			}
		},
		{
			["tower.holder_id"] = "39",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 597,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 548,
				y = 274
			}
		},
		{
			["tower.holder_id"] = "37",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 443,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 426,
				y = 260
			}
		},
		{
			["tower.holder_id"] = "33",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 325,
				y = 431
			},
			["tower.default_rally_pos"] = {
				x = 271,
				y = 377
			}
		},
		{
			["tower.holder_id"] = "43",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 857,
				y = 536
			},
			["tower.default_rally_pos"] = {
				x = 858,
				y = 618
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_powers = {
				true,
				true,
				true
			},
			locked_towers = {
				"tower_archer_2",
				"tower_barrack_2",
				"tower_engineer_2",
				"tower_mage_2"
			}
		},
		{
			max_upgrade_level = 1,
			locked_powers = {
				[3] = true
			},
			locked_towers = {
				"tower_archer_2",
				"tower_barrack_2",
				"tower_engineer_2",
				"tower_mage_2"
			}
		},
		{
			max_upgrade_level = 1,
			locked_powers = {
				[3] = true
			},
			locked_towers = {
				"tower_build_archer",
				"tower_barrack_2",
				"tower_build_mage",
				"tower_engineer_2"
			}
		}
	},
	nav_mesh = {
		[29] = {
			37,
			33,
			nil,
			35
		},
		[31] = {
			45,
			39,
			37
		},
		[33] = {
			37,
			nil,
			29,
			35
		},
		[35] = {
			37,
			33,
			29
		},
		[37] = {
			39,
			33,
			29,
			35
		},
		[39] = {
			41,
			43,
			37,
			31
		},
		[41] = {
			45,
			43,
			39,
			45
		},
		[43] = {
			nil,
			nil,
			39,
			41
		},
		[45] = {
			nil,
			41,
			31
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage49",
		"ElvenWoodsAmbienceSounds"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_stage49",
		"go_stage49_bg",
		"go_stages_elven_woods",
		"gui_tutorial"
	}
}
