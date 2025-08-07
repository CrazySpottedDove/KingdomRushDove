﻿-- chunkname: @./kr3/data/levels/level12_data.lua

return {
	locked_hero = false,
	show_comic_idx = 3,
	level_terrain_type = 3,
	max_upgrade_level = 6,
	custom_spawn_pos = {
		x = 46,
		y = 251
	},
	entities_list = {
		{
			template = "aura_metropolis_portal",
			pos = {
				x = 674,
				y = 283
			}
		},
		{
			template = "background_sounds",
			sounds = {
				"MetropolisAmbienceSound"
			}
		},
		{
			template = "birds_formation_controller",
			time = 4,
			from = {
				x = 1300,
				y = 500
			},
			names = {
				"decal_bird_red",
				"decal_bird_red",
				"decal_bird_red"
			},
			offsets = {
				{
					x = 0,
					y = 0
				},
				{
					x = -104,
					y = 0
				},
				{
					x = 15,
					y = -77
				}
			},
			to = {
				x = 606,
				y = 903
			}
		},
		{
			template = "birds_formation_controller",
			time = 3,
			from = {
				x = -150,
				y = 450
			},
			names = {
				"decal_bird_duck",
				"decal_bird_duck",
				"decal_bird_duck"
			},
			offsets = {
				{
					x = 0,
					y = 0
				},
				{
					x = 30,
					y = 6
				},
				{
					x = 18,
					y = 18
				}
			},
			to = {
				x = 420,
				y = 838
			}
		},
		{
			time = 5,
			template = "birds_formation_controller",
			from = {
				x = 974,
				y = -70
			},
			names = {
				"decal_bird_red"
			},
			to = {
				x = 168,
				y = 834
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 261,
				y = 380
			}
		},
		{
			template = "crystal_arcane",
			pos = {
				x = 605,
				y = 601
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage12_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 474,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage12_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 215
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 46,
				y = 496
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 31,
				y = 146
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 31,
				y = 275
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 31,
				y = 437
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 31,
				y = 554
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0021",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0008",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0020",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0009",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0015",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0010",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0011",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0007",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0018",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0012",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0017",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0019",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0013",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0014",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0016",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0005",
			pos = {
				x = 512,
				y = 385
			}
		},
		{
			template = "decal_metropolis_floating_rock",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "Stage12_0006",
			pos = {
				x = 512,
				y = 385
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 2,
			detection_paths = {
				2,
				4,
				5,
				6
			},
			detection_tags = {
				2
			},
			pos = {
				x = 674,
				y = 283
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 1,
			detection_paths = {
				2,
				4,
				5,
				7,
				8
			},
			detection_tags = {
				2,
				1
			},
			pos = {
				x = 434,
				y = 287
			}
		},
		{
			template = "decal_metropolis_portal",
			["editor.tag"] = 3,
			detection_paths = {
				6,
				9
			},
			detection_tags = {
				2,
				3
			},
			pos = {
				x = 399,
				y = 672
			}
		},
		{
			template = "decal_s12_lemur",
			["nav_path.pi"] = 10,
			pos = {
				x = 0,
				y = 0
			}
		},
		{
			["editor.r"] = -0.10471975511966,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 136
			}
		},
		{
			["editor.r"] = -0.10471975511966,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 174
			}
		},
		{
			["editor.r"] = -0.10471975511966,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 211
			}
		},
		{
			["editor.r"] = -0.10471975511966,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 249
			}
		},
		{
			["editor.r"] = 0.41887902047864,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 10,
			pos = {
				x = 921,
				y = 613
			}
		},
		{
			["editor.r"] = 0.41887902047864,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 10,
			pos = {
				x = 883,
				y = 642
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 803,
				y = 163
			},
			["tower.default_rally_pos"] = {
				x = 871,
				y = 230
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 402,
				y = 164
			},
			["tower.default_rally_pos"] = {
				x = 309,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 237,
				y = 257
			},
			["tower.default_rally_pos"] = {
				x = 239,
				y = 196
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 125,
				y = 282
			},
			["tower.default_rally_pos"] = {
				x = 125,
				y = 219
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 879,
				y = 304
			},
			["tower.default_rally_pos"] = {
				x = 822,
				y = 261
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 801,
				y = 358
			},
			["tower.default_rally_pos"] = {
				x = 745,
				y = 320
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 607,
				y = 397
			},
			["tower.default_rally_pos"] = {
				x = 702,
				y = 405
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 427,
				y = 440
			},
			["tower.default_rally_pos"] = {
				x = 380,
				y = 525
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 519,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 565,
				y = 537
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 245,
				y = 519
			},
			["tower.default_rally_pos"] = {
				x = 246,
				y = 456
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 679,
				y = 536
			},
			["tower.default_rally_pos"] = {
				x = 682,
				y = 479
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 3,
			template = "tower_holder_ancient_metropolis",
			["editor.game_mode"] = 0,
			pos = {
				x = 497,
				y = 606
			},
			["tower.default_rally_pos"] = {
				x = 498,
				y = 552
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{
			locked_towers = {
				"tower_build_engineer",
				"tower_build_mage"
			}
		}
	},
	nav_mesh = {
		{
			4,
			2,
			11,
			3
		},
		{
			1,
			7,
			12,
			11
		},
		{
			nil,
			4,
			6
		},
		{
			nil,
			1,
			1,
			3
		},
		{
			6,
			8,
			10
		},
		{
			3,
			9,
			5
		},
		{
			2,
			nil,
			8,
			12
		},
		{
			9,
			7,
			10,
			5
		},
		{
			12,
			7,
			8,
			6
		},
		{
			5,
			8
		},
		{
			1,
			2,
			12,
			3
		},
		{
			11,
			7,
			9,
			11
		}
	},
	pan_extension = {
		bottom = -40,
		top = 40
	},
	required_sounds = {
		"music_stage60",
		"MetropolisAmbienceSounds",
		"ElvesCrystalPlant",
		"ElvesCreepArachnomancerSpiderSpawn",
		"ElvesCreepAvenger",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesCreepRazorboar",
		"ElvesCreepSonOfMactans",
		"ElvesScourger"
	},
	required_textures = {
		"go_enemies_ancient_metropolis",
		"go_stage60",
		"go_stage60_bg",
		"go_stages_ancient_metropolis"
	}
}
