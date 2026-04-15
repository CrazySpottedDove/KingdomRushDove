local data = {
	max_waves = 1,
	initial_cash = 1200,
	initial_interval = 7200,
	final_interval = 7200,
	paths = {1, 2},
	path_active_map = {
		[1] = 1,
		[2] = 1
	},
	path_weight_map = {
		[1] = 3,
		[2] = 2
	},
	path_enemy_map = {
		[1] = {"enemy_skeleton", "enemy_skeleton_big", "enemy_necromancer", "enemy_phantom_death_rider", "enemy_wererat"},
		[2] = {"enemy_gargoyle", "enemy_abomination", "enemy_zombiemancer", "enemy_halloween_zombie", "enemy_zombie", "enemy_werewolf"}
	},
	enemy_weight_map = {
		["enemy_halloween_zombie"] = 1.4,
		["enemy_skeleton"] = 1,
		["enemy_skeleton_big"] = 2,
		["enemy_necromancer"] = 12,
		["enemy_gargoyle"] = 2,
		["enemy_wererat"] = 6,
		["enemy_werewolf"] = 7,
		["enemy_zombiemancer"] = 20,
		["enemy_zombie"] = 1.5,
		["enemy_phantom_death_rider"] = 10,
		["enemy_abomination"] = 10
	},
	enemy_comeout_wave_map = {
		["enemy_halloween_zombie"] = 1,
		["enemy_skeleton"] = 1,
		["enemy_skeleton_big"] = 1,
		["enemy_necromancer"] = 1,
		["enemy_gargoyle"] = 1,
		["enemy_wererat"] = 1,
		["enemy_werewolf"] = 1,
		["enemy_phantom_death_rider"] = 1,
		["enemy_abomination"] = 1,
		["enemy_zombiemancer"] = 1,
		["enemy_zombie"] = 1
	},
	enemy_delete_wave_map = {
		[1] = {},
		[2] = {}
	},
	wave_weight_function = function(wave_number, total_gold)
		return 1500
	end,
	min_spawn_weight = 14,
	max_spawn_weight = 40,
	interval_function = function(weight, e, wave_number)
		return (25 + 100 * math.log(weight)) * 20 / e.motion.max_speed * (1.4 - math.random())
	end,
	wave_max_types = 10
}
return data
