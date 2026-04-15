local data = {
	max_waves = 15,
	initial_cash = 1500,
	initial_interval = 800,
	final_interval = 1600,
	paths = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11
	},
	path_active_map = {
		[1] = {1, 2},
		[2] = {1, 2},
		[3] = {7, 8},
		[4] = {1, 2, 7, 8, 9, 10},
		[5] = {3, 4, 9, 10},
		[6] = {3, 4, 5, 6, 11},
		[7] = {3, 4, 7, 8, 5, 6, 9, 10},
		[8] = {1, 2, 7, 8, 9, 10},
		[9] = {1, 2, 5, 6, 11},
		[10] = {3, 4, 7, 8, 9, 10},
		[11] = {1, 2, 3, 4, 9, 10},
		[12] = {5, 6, 7, 8, 11},
		[13] = {1, 2, 3, 4, 5, 6, 9, 10},
		[14] = {3, 4, 5, 6, 7, 8, 9, 10},
		[15] = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11
		}
	},
	path_weight_map = {
		[1] = 3,
		[2] = 3,
		[3] = 3,
		[4] = 3,
		[5] = 3,
		[6] = 3,
		[7] = 3,
		[8] = 3,
		[9] = 1.5,
		[10] = 1.5,
		[11] = 3
	},
	path_enemy_map = {
		[1] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_jungle_spider_tiny",
			"enemy_jungle_spider_small",
			"enemy_jungle_spider_big",
			"enemy_gorilla",
			"enemy_savage_bird_rider",
			"enemy_shaman_gravity"
		},
		[2] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_rage",
			"enemy_jungle_spider_tiny",
			"enemy_jungle_spider_small",
			"enemy_jungle_spider_big",
			"enemy_gorilla",
			"enemy_savage_bird_rider",
			"enemy_shaman_gravity"
		},
		[3] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_magic", "enemy_cannibal_zombie", "enemy_alien_breeder", "enemy_alien_reaper", "enemy_savage_bird", "enemy_savage_bird_rider"},
		[4] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_rage",
			"enemy_shaman_necro",
			"enemy_cannibal_zombie",
			"enemy_alien_breeder",
			"enemy_alien_reaper",
			"enemy_savage_bird",
			"enemy_savage_bird_rider"
		},
		[5] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_shield",
			"enemy_shaman_necro",
			"enemy_jungle_spider_tiny",
			"enemy_jungle_spider_small",
			"enemy_jungle_spider_big",
			"enemy_gorilla",
			"enemy_savage_bird_rider"
		},
		[6] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_gravity", "enemy_jungle_spider_tiny", "enemy_jungle_spider_small", "enemy_jungle_spider_big", "enemy_gorilla", "enemy_savage_bird_rider"},
		[7] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_shaman_priest", "enemy_shaman_shield", "enemy_cannibal_zombie", "enemy_alien_breeder", "enemy_alien_reaper", "enemy_savage_bird", "enemy_savage_bird_rider"},
		[8] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_gravity",
			"enemy_shaman_necro",
			"enemy_cannibal_zombie",
			"enemy_alien_breeder",
			"enemy_alien_reaper",
			"enemy_savage_bird",
			"enemy_savage_bird_rider"
		},
		[9] = {"enemy_cannibal", "enemy_hunter"},
		[10] = {"enemy_cannibal", "enemy_hunter"},
		[11] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_rage", "enemy_shaman_shield", "enemy_shaman_necro", "enemy_shaman_gravity"}
	},
	enemy_weight_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 3,
		["enemy_hunter"] = 1.5,
		["enemy_shaman_priest"] = 6,
		["enemy_shaman_magic"] = 6,
		["enemy_shaman_rage"] = 9,
		["enemy_shaman_shield"] = 8,
		["enemy_shaman_necro"] = 9,
		["enemy_cannibal_zombie"] = 1.2,
		["enemy_jungle_spider_tiny"] = 0.35,
		["enemy_jungle_spider_small"] = 1,
		["enemy_jungle_spider_big"] = 7,
		["enemy_gorilla"] = 12,
		["enemy_alien_breeder"] = 3,
		["enemy_alien_reaper"] = 3,
		["enemy_savage_bird"] = 3,
		["enemy_savage_bird_rider"] = 8,
		["enemy_shaman_gravity"] = 9
	},
	enemy_comeout_wave_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 4,
		["enemy_hunter"] = 1,
		["enemy_shaman_priest"] = 3,
		["enemy_shaman_magic"] = 5,
		["enemy_shaman_rage"] = 7,
		["enemy_shaman_shield"] = 6,
		["enemy_shaman_necro"] = 8,
		["enemy_cannibal_zombie"] = 2,
		["enemy_jungle_spider_tiny"] = 2,
		["enemy_jungle_spider_small"] = 1,
		["enemy_jungle_spider_big"] = 4,
		["enemy_gorilla"] = 10,
		["enemy_alien_breeder"] = 10,
		["enemy_alien_reaper"] = 9,
		["enemy_savage_bird"] = 5,
		["enemy_savage_bird_rider"] = 10,
		["enemy_shaman_gravity"] = 9
	},
	enemy_delete_wave_map = {
		[1] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[2] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[3] = {
			[10] = {"enemy_savage_bird"}
		},
		[4] = {
			[10] = {"enemy_savage_bird"}
		},
		[5] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[6] = {
			[6] = {"enemy_jungle_spider_tiny"}
		},
		[7] = {
			[10] = {"enemy_savage_bird"}
		},
		[8] = {
			[10] = {"enemy_savage_bird"}
		},
		[9] = {},
		[10] = {},
		[11] = {}
	},
	wave_weight_function = function(wave_number, total_gold)
		return (50 + (total_gold ^ 0.7) / 18 + wave_number ^ 2.25) * 0.4
	end,
	interval_next_factor = 0.1,
	min_spawn_weight = 1,
	max_spawn_weight = 20,
	interval_function = function(weight, e, wave_number)
		return (25 + 160 * math.log(weight)) * 20 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
	end,
	gap_count_range = {0, 1, 2},
	wave_max_types = 8
}
return data
