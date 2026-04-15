local data = {
	max_waves = 1,
	initial_cash = 3000,
	initial_interval = 7200,
	final_interval = 7200,
	paths = {3, 4, 7, 8, 9, 10, 11},
	path_active_map = {
		[1] = {
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
		[1] = 1,
		[2] = 3,
		[3] = 1,
		[4] = 3,
		[5] = 1,
		[6] = 3,
		[7] = 1,
		[8] = 3,
		[9] = 1.5,
		[10] = 1.5,
		[11] = 3
	},
	path_enemy_map = {
		[1] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_gorilla", "enemy_cannibal_zombie"},
		[2] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_necro", "enemy_shaman_shield"},
		[3] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_gorilla", "enemy_cannibal_zombie"},
		[4] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_necro", "enemy_shaman_shield"},
		[5] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_gorilla", "enemy_cannibal_zombie"},
		[6] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_necro", "enemy_shaman_shield"},
		[7] = {"enemy_cannibal", "enemy_cannibal_volcano_normal", "enemy_hunter", "enemy_gorilla", "enemy_cannibal_zombie"},
		[8] = {"enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_necro"},
		[9] = {"enemy_cannibal", "enemy_hunter"},
		[10] = {"enemy_cannibal", "enemy_hunter"},
		[11] = {"enemy_shaman_gravity", "enemy_cannibal", "enemy_cannibal_volcano_normal"}
	},
	enemy_weight_map = {
		["enemy_cannibal"] = 2,
		["enemy_cannibal_volcano_normal"] = 4,
		["enemy_hunter"] = 3,
		["enemy_shaman_priest"] = 7,
		["enemy_shaman_magic"] = 6,
		["enemy_shaman_rage"] = 10,
		["enemy_shaman_shield"] = 15,
		["enemy_shaman_necro"] = 25,
		["enemy_cannibal_zombie"] = 4,
		["enemy_gorilla"] = 17,
		["enemy_shaman_gravity"] = 15
	},
	enemy_comeout_wave_map = {
		["enemy_cannibal"] = 1,
		["enemy_cannibal_volcano_normal"] = 1,
		["enemy_hunter"] = 1,
		["enemy_shaman_priest"] = 1,
		["enemy_shaman_magic"] = 1,
		["enemy_shaman_rage"] = 1,
		["enemy_shaman_shield"] = 1,
		["enemy_shaman_necro"] = 1,
		["enemy_cannibal_zombie"] = 1,
		["enemy_gorilla"] = 1,
		["enemy_shaman_gravity"] = 1
	},
	enemy_delete_wave_map = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {},
		[11] = {}
	},
	wave_weight_function = function(wave_number, total_gold)
		return 500
	end,
	interval_next_factor = 0.1,
	min_spawn_weight = 10,
	max_spawn_weight = 20,
	interval_function = function(weight, e, wave_number)
		return (25 + 300 * math.log(weight)) * 30 / e.motion.max_speed
	end,
	gap_count_range = {3, 5, 7},
	wave_max_types = 100
}
return data
