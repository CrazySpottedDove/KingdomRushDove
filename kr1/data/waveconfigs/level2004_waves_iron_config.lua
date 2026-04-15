local data = {
	max_waves = 1,
	initial_cash = 2250,
	initial_interval = 7200,
	final_interval = 7200,
	paths = {1, 2, 3, 4, 5, 6, 7, 8, 9},
	path_active_map = {
		[1] = {1, 2, 4, 6, 8, 9}
	},
	path_weight_map = {
		[1] = 2,
		[2] = 4,
		[4] = 3,
		[6] = 4,
		[8] = 2,
		[9] = 3
	},
	path_enemy_map = {
		[1] = {"enemy_bouncer", "enemy_desert_raider", "enemy_immortal"},
		[2] = {"enemy_desert_wolf_small", "enemy_desert_wolf", "enemy_desert_archer"},
		[4] = {"enemy_desert_raider", "enemy_immortal", "enemy_executioner"},
		[6] = {"enemy_fallen", "enemy_munra", "enemy_desert_spider"},
		[8] = {"enemy_wasp", "enemy_wasp_queen", "enemy_tremor"},
		[9] = {"enemy_fallen", "enemy_scorpion", "enemy_desert_spider", "enemy_desert_archer"}
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
		["enemy_wasp_queen"] = 10,
		["enemy_executioner"] = 15,
		["enemy_munra"] = 25,
		["enemy_desert_spider"] = 10
	},
	enemy_comeout_wave_map = {
		["enemy_bouncer"] = 1,
		["enemy_desert_raider"] = 1,
		["enemy_desert_wolf_small"] = 1,
		["enemy_desert_wolf"] = 1,
		["enemy_immortal"] = 1,
		["enemy_fallen"] = 1,
		["enemy_desert_archer"] = 1,
		["enemy_scorpion"] = 1,
		["enemy_tremor"] = 1,
		["enemy_wasp"] = 1,
		["enemy_wasp_queen"] = 1,
		["enemy_executioner"] = 1,
		["enemy_munra"] = 1,
		["enemy_desert_spider"] = 1
	},
	enemy_delete_wave_map = {},
	wave_weight_function = function(wave_number, total_gold)
		return 1000
	end,
	interval_function = function(weight, e, wave_number)
		return (25 + 100 * math.log(weight)) * 21.5 / e.motion.max_speed * (1.3 - math.random())
	end,
	interval_next_factor = 1,
	min_spawn_weight = 15,
	max_spawn_weight = 30,
	gap_count_range = {5, 7, 9},
	wave_max_types = 100
}
return data
