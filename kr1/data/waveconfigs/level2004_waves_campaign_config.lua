local data = {
	max_waves = 15,
	initial_cash = 1200,
	initial_interval = 800,
	final_interval = 2000,
	paths = {1, 2, 3, 4, 5, 6, 7, 8, 9},
	path_active_map = {
		[1] = {2},
		[2] = {3},
		[3] = {2, 3},
		[4] = {7, 6},
		[5] = {1, 7},
		[6] = {1, 7, 9},
		[7] = {1, 4},
		[8] = {4, 5},
		[9] = {2, 8},
		[10] = {2, 3, 4, 5},
		[11] = {1},
		[12] = {8, 9},
		[13] = {1, 2, 8, 9},
		[14] = {1, 2, 3, 7, 8, 9},
		[15] = {1, 4, 5, 6, 7, 9}
	},
	path_weight_map = {
		[1] = 2,
		[2] = 4,
		[3] = 4,
		[4] = 3,
		[5] = 3,
		[6] = 4,
		[7] = 3,
		[8] = 2,
		[9] = 3
	},
	path_enemy_map = {
		[1] = {"enemy_bouncer", "enemy_desert_raider", "enemy_immortal", "enemy_tremor"},
		[2] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_wasp_queen"},
		[3] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra", "enemy_wasp"},
		[4] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal"},
		[5] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_immortal", "enemy_munra", "enemy_desert_spider"},
		[6] = {"enemy_bouncer", "enemy_desert_raider", "enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_executioner", "enemy_immortal", "enemy_munra", "enemy_tremor", "enemy_desert_archer", "enemy_wasp"},
		[7] = {"enemy_bouncer", "enemy_wasp", "enemy_wasp_queen", "enemy_scorpion", "enemy_executioner", "enemy_desert_spider"},
		[8] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor"},
		[9] = {"enemy_fallen", "enemy_wasp_queen", "enemy_scorpion", "enemy_tremor", "enemy_munra", "enemy_desert_spider"}
	},
	enemy_weight_map = {
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 3,
		["enemy_desert_wolf_small"] = 1.5,
		["enemy_desert_wolf"] = 3,
		["enemy_immortal"] = 7,
		["enemy_fallen"] = 3,
		["enemy_desert_archer"] = 4,
		["enemy_scorpion"] = 8,
		["enemy_tremor"] = 2.5,
		["enemy_wasp"] = 2.5,
		["enemy_wasp_queen"] = 7,
		["enemy_executioner"] = 12,
		["enemy_munra"] = 15,
		["enemy_desert_spider"] = 10
	},
	enemy_comeout_wave_map = {
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 1,
		["enemy_desert_wolf_small"] = 1,
		["enemy_desert_wolf"] = 2,
		["enemy_immortal"] = 3,
		["enemy_fallen"] = 2,
		["enemy_desert_archer"] = 4,
		["enemy_scorpion"] = 8,
		["enemy_tremor"] = 4,
		["enemy_wasp"] = 5,
		["enemy_wasp_queen"] = 7,
		["enemy_executioner"] = 9,
		["enemy_munra"] = 10,
		["enemy_desert_spider"] = 6
	},
	enemy_delete_wave_map = {
		[1] = {
			[6] = {"enemy_bouncer"},
			[9] = {"enemy_tremor"}
		},
		[2] = {
			[7] = {"enemy_bouncer"},
			[10] = {"enemy_desert_raider"}
		},
		[3] = {
			[7] = {"enemy_bouncer"},
			[10] = {"enemy_desert_raider"}
		},
		[4] = {
			[8] = {"enemy_bouncer"},
			[11] = {"enemy_desert_wolf_small"}
		},
		[5] = {
			[8] = {"enemy_bouncer"},
			[11] = {"enemy_desert_wolf_small"}
		},
		[6] = {
			[9] = {"enemy_bouncer", "enemy_desert_raider"},
			[12] = {"enemy_desert_archer"}
		},
		[7] = {
			[8] = {"enemy_bouncer"},
			[11] = {"enemy_wasp"}
		},
		[8] = {
			[9] = {"enemy_fallen"}
		},
		[9] = {
			[10] = {"enemy_fallen"}
		}
	},
	wave_weight_function = function(wave_number, total_gold)
		return (50 + (total_gold ^ 0.72) / 18 + wave_number ^ 2.5) * 0.38
	end,
	interval_function = function(weight, e, wave_number)
		local base = 60 + 180 * math.log(weight)
		local speed_factor = 20 / (e.motion.max_speed or 1)
		local wave_factor = 1 - math.min(wave_number / 16, 0.6)
		return base * speed_factor * wave_factor
	end,
	interval_next_factor = 0.18,
	min_spawn_weight = 1.5,
	max_spawn_weight = 18,
	gap_count_range = {1, 2, 3, 4},
	wave_max_types = 3
}
return data
