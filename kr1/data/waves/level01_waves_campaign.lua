return {
	lives = 20,
	cash = 270,
	groups = {{
		interval = 800,
		waves = {{
			delay = 0,
			path_index = 1,
			spawns = {{
				interval = 51,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}}
		}}
	}, {
		interval = 800,
		waves = {{
			delay = 0,
			path_index = 1,
			spawns = {{
				interval = 51,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}, {
				interval = 51,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}}
		}}
	}, {
		interval = 800,
		waves = {{
			delay = 0,
			path_index = 1,
			notification = "POWER_REINFORCEMENT",
			spawns = {{
				interval = 38,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}, {
				interval = 38,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}, {
				interval = 38,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 50,
				max = 3
			}}
		}}
	}, {
		interval = 800,
		waves = {{
			delay = 0,
			path_index = 1,
			spawns = {{
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 150,
				max = 4
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 100,
				max = 1
			}}
		}}
	}, {
		interval = 1000,
		waves = {{
			delay = 0,
			path_index = 1,
			notification_second_level = "TIP_ARMOR",
			spawns = {{
				interval = 51,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 100,
				max = 3
			}}
		}}
	}, {
		interval = 1000,
		waves = {{
			delay = 0,
			path_index = 1,
			notification_second_level = "TIP_RALLY",
			spawns = {{
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 150,
				max = 5
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 100,
				max = 2
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 150,
				max = 5
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 100,
				max = 2
			}}
		}}
	}, {
		interval = 1000,
		waves = {{
			delay = 0,
			path_index = 1,
			notification = "POWER_FIREBALL",
			spawns = {{
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 100,
				max = 16
			}}
		}}
	}}
}
