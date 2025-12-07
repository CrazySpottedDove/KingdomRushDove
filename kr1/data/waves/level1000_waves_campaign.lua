-- chunkname: @./kr1/data/waves/level01_waves_campaign.lua
return {
	lives = 20,
	cash = 999999,
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
		}, {
			delay = 0,
			path_index = 2,
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
	}}
}
