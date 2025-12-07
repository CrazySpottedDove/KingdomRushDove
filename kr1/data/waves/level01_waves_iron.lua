-- chunkname: @./kr1/data/waves/level01_waves_iron.lua
return {
	lives = 1,
	cash = 360,
	-- cash = 10000,
	groups = {{
		interval = 800,
		waves = {{
			delay = 0,
			path_index = 1,
			spawns = {{
				interval = 38,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 250,
				max = 3
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 150,
				max = 5
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 200,
				max = 5
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 150,
				max = 3
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 100,
				max = 7
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 120,
				max = 7
			}, {
				interval = 51,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 150,
				max = 4
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 100,
				max = 16
			}, {
				interval = 26,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_fat_orc",
				path = 1,
				interval_next = 150,
				max = 6
			}, {
				interval = 13,
				max_same = 0,
				fixed_sub_path = 0,
				creep = "enemy_goblin",
				path = 1,
				interval_next = 100,
				max = 30
			}}
		-- {
		--     interval = 13,
		--     max_same = 0,
		--     fixed_sub_path = 0,
		--     creep = "eb_alleria",
		--     path = 1,
		--     interval_next = 100,
		--     max = 1,
		-- }
		}}
	}}
}
