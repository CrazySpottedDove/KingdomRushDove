local data = {
	max_waves = 6,
	initial_cash = 2500,
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
		[6] = {1, 2, 3, 4, 5, 6, 11}
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
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[2] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[3] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[4] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[5] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[6] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[7] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
		},
		[8] = {
			"enemy_cannibal",
			"enemy_cannibal_volcano_normal",
			"enemy_hunter",
			"enemy_shaman_priest",
			"enemy_shaman_magic",
			"enemy_shaman_necro",
			"enemy_gorilla",
			"enemy_shaman_gravity",
			"enemy_shaman_rage",
			"enemy_shaman_shield",
			"enemy_cannibal_zombie"
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
		["enemy_gorilla"] = 12,
		["enemy_shaman_gravity"] = 9
	},
	enemy_comeout_wave_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 3,
		["enemy_hunter"] = 1,
		["enemy_shaman_priest"] = 2,
		["enemy_shaman_magic"] = 3,
		["enemy_shaman_rage"] = 1,
		["enemy_shaman_shield"] = 3,
		["enemy_shaman_necro"] = 5,
		["enemy_cannibal_zombie"] = 1,
		["enemy_gorilla"] = 5,
		["enemy_shaman_gravity"] = 5
	},
	enemy_delete_wave_map = {
		[1] = {
			[4] = {"enemy_cannibal"}
		},
		[2] = {
			[4] = {"enemy_cannibal"}
		},
		[3] = {
			[4] = {"enemy_cannibal"}
		},
		[4] = {
			[4] = {"enemy_cannibal"}
		},
		[5] = {
			[4] = {"enemy_cannibal"}
		},
		[6] = {
			[4] = {"enemy_cannibal"}
		},
		[7] = {
			[4] = {"enemy_cannibal"}
		},
		[8] = {
			[4] = {"enemy_cannibal"}
		},
		[9] = {},
		[10] = {},
		[11] = {}
	},
	wave_weight_function = function(wave_number, total_gold)
		return (70 + (total_gold ^ 0.75) / 18 + 4 * wave_number ^ 2.25) * 0.4
	end,
	interval_next_factor = 0.1,
	min_spawn_weight = 1,
	max_spawn_weight = 20,
	interval_function = function(weight, e, wave_number)
		return (25 + 160 * math.log(weight)) * 30 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
	end,
	gap_count_range = {1, 2, 3},
	wave_max_types = 6
}
return data
