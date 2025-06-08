﻿-- chunkname: @./kr3/data/levels/level17_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"HulkingRageAmbienceSound"
			}
		},
		{
			template = "crystal_unstable",
			pos = {
				x = 290,
				y = 455
			}
		},
		{
			template = "crystal_unstable",
			pos = {
				x = 861,
				y = 544
			}
		},
		{
			["render.sprites[1].sort_y"] = 620,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage17_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage17_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 334,
				y = 60
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 535,
				y = 60
			}
		},
		{
			["editor.exit_id"] = 3,
			template = "decal_defend_point",
			pos = {
				x = 810,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 265,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 391,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 470,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 605,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 743,
				y = 60
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 882,
				y = 60
			}
		},
		{
			template = "decal_hr_cart",
			pos = {
				x = 644,
				y = 622
			}
		},
		{
			template = "decal_hr_crystal_skull",
			["delayed_play.achievement_flag"] = {
				"MITCHELL_HEDGES",
				2
			},
			pos = {
				x = 980,
				y = 339
			}
		},
		{
			template = "decal_hr_worker_a",
			pos = {
				x = 186,
				y = 619
			}
		},
		{
			template = "decal_hr_worker_a",
			pos = {
				x = 684,
				y = 659
			}
		},
		{
			template = "decal_hr_worker_b",
			pos = {
				x = 649,
				y = 662
			}
		},
		{
			["editor.r"] = 2.9146998508306,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 32,
				y = 455
			}
		},
		{
			["editor.r"] = -0.2792526803191,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 986,
				y = 537
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 357,
				y = 682
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 328,
				y = 720
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 387,
				y = 720
			}
		},
		{
			["spawner.name"] = "trail0",
			template = "gnoll_bush_spawner",
			["spawner.pi"] = 6,
			spawn_node_offset = 3,
			pos = {
				x = 980,
				y = 246
			}
		},
		{
			template = "malik_slave_controller",
			["editor.game_mode"] = 1,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			template = "mega_spawner",
			load_file = "level65_spawner"
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 463,
				y = 205
			},
			["tower.default_rally_pos"] = {
				x = 540,
				y = 282
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 685,
				y = 223
			},
			["tower.default_rally_pos"] = {
				x = 570,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 348,
				y = 233
			},
			["tower.default_rally_pos"] = {
				x = 310,
				y = 180
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 887,
				y = 233
			},
			["tower.default_rally_pos"] = {
				x = 782,
				y = 238
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 141,
				y = 243
			},
			["tower.default_rally_pos"] = {
				x = 247,
				y = 256
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 395,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 392,
				y = 402
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 629,
				y = 323
			},
			["tower.default_rally_pos"] = {
				x = 695,
				y = 395
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 157,
				y = 349
			},
			["tower.default_rally_pos"] = {
				x = 260,
				y = 366
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 559,
				y = 423
			},
			["tower.default_rally_pos"] = {
				x = 639,
				y = 476
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 1,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			pos = {
				x = 211,
				y = 501
			},
			["tower.default_rally_pos"] = {
				x = 166,
				y = 450
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 4,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			pos = {
				x = 774,
				y = 452
			},
			["tower.default_rally_pos"] = {
				x = 833,
				y = 400
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 4,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			pos = {
				x = 688,
				y = 542
			},
			["tower.default_rally_pos"] = {
				x = 591,
				y = 539
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 4,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			pos = {
				x = 429,
				y = 571
			},
			["tower.default_rally_pos"] = {
				x = 338,
				y = 554
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
			3,
			nil,
			6,
			3
		},
		{
			3,
			6,
			4,
			9
		},
		{
			nil,
			1,
			2,
			8
		},
		{
			9,
			2,
			5,
			13
		},
		{
			4,
			7,
			nil,
			12
		},
		{
			1,
			nil,
			7,
			2
		},
		{
			6,
			6,
			nil,
			5
		},
		{
			nil,
			3,
			11
		},
		{
			3,
			2,
			4,
			11
		},
		{
			11,
			4,
			13
		},
		{
			8,
			9,
			10
		},
		{
			13,
			5
		},
		{
			10,
			4,
			12
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage65",
		"ElvesLevelHRSounds",
		"ElvesHeroBabyMalik",
		"ElvesUnstableCrystalSounds",
		"ElvenWoodsAmbienceSounds",
		"ElvesCreepHyena",
		"ElvesMalikSpecialSounds"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_enemies_hulking_rage",
		"go_stage65",
		"go_stage65_bg",
		"go_hero_baby_malik",
		"go_stages_hulking_rage"
	}
}
