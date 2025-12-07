-- chunkname: @./kr1/data/waves/level09_waves_campaign.lua
return {
	lives = 20,
	cash = 800,
	groups = {
		{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 1,
				notification = "TOWER_SORCERER",
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_bandit",
					path = 1,
					interval_next = 150,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}}
		},
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 2
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}}
		},
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 2
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}}
		},
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 1,
				some_flying = true,
				spawns = {{
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_gargoyle",
					path = 1,
					interval_next = 150,
					max = 2
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_gargoyle",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}, {
				delay = 0,
				path_index = 3,
				some_flying = true,
				spawns = {{
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_gargoyle",
					path = 1,
					interval_next = 150,
					max = 2
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_gargoyle",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}}
		},
		{
			interval = 700,
			waves = {{
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 4
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_shadow_archer",
					path = 1,
					interval_next = 150,
					max = 4
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 200,
					max = 4
				}}
			}}
		},
		{
			interval = 1000,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 60,
					max = 10
				}, {
					interval = 26,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 19,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 60,
					max = 8
				}}
			}}
		},
		{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}}
		},
		{
			interval = 1000,
			waves = {{
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_shadow_archer",
					path = 1,
					interval_next = 150,
					max = 6
				}}
			}}
		},
		{
			interval = 1100,
			waves = {{
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_dark_knight",
					path = 2,
					interval_next = 0,
					max = 1
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_dark_knight",
					path = 3,
					interval_next = 30,
					max = 1
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_slayer",
					path = 1,
					interval_next = 30,
					max = 1
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_dark_knight",
					path = 2,
					interval_next = 0,
					max = 1
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_dark_knight",
					path = 3,
					interval_next = 30,
					max = 1
				}}
			}}
		},
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 3
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 13,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 100,
					max = 4
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 3
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_dark_knight",
					path = 3,
					interval_next = 30,
					max = 1
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}}
		},
		{
			interval = 1500,
			waves = {{
				delay = 0,
				path_index = 1,
				some_flying = true,
				spawns = {{
					interval = 115,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_rocketeer",
					path = 1,
					interval_next = 300,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 3,
				some_flying = true,
				spawns = {{
					interval = 115,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_rocketeer",
					path = 1,
					interval_next = 300,
					max = 3
				}}
			}}
		},
		{
			interval = 1100,
			waves = {{
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_slayer",
					path = 2,
					interval_next = 200,
					max = 1
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_shadow_archer",
					path = 1,
					interval_next = 200,
					max = 6
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 200,
					max = 4
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_slayer",
					path = 3,
					interval_next = 200,
					max = 1
				}}
			}}
		},
		{
			interval = 1500,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 64,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_chieftain",
					path = 1,
					interval_next = 200,
					max = 1
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 4
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 4
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 4
				}}
			}}
		},
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 150,
					max = 15
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 26,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 26,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 100,
					max = 1
				}, {
					interval = 26,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 100,
					max = 3
				}, {
					interval = 26,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 100,
					max = 1
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf_small",
					path = 1,
					interval_next = 150,
					max = 15
				}}
			}}
		},
		{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 1
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 1
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 19,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 1
				}}
			}}
		},
		{
			interval = 1600,
			waves = {{
				delay = 0,
				path_index = 1,
				some_flying = true,
				spawns = {{
					interval = 77,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_rocketeer",
					path = 1,
					interval_next = 150,
					max = 5
				}}
			}, {
				delay = 0,
				path_index = 3,
				some_flying = true,
				spawns = {{
					interval = 77,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_rocketeer",
					path = 1,
					interval_next = 150,
					max = 5
				}}
			}}
		},
		{
			interval = 1500,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 64,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_chieftain",
					path = 1,
					interval_next = 150,
					max = 2
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 300,
					max = 4
				}, {
					interval = 77,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 300,
					max = 2
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 300,
					max = 4
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 300,
					max = 2
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_slayer",
					path = 2,
					interval_next = 200,
					max = 1
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_shadow_archer",
					path = 1,
					interval_next = 200,
					max = 4
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 300,
					max = 4
				}, {
					interval = 1,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_slayer",
					path = 3,
					interval_next = 200,
					max = 1
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_shadow_archer",
					path = 1,
					interval_next = 200,
					max = 4
				}, {
					interval = 38,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 200,
					max = 4
				}}
			}}
		},
		{
			interval = 3000,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 512,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 512,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 3,
				spawns = {{
					interval = 512,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 3
				}}
			}}
		},
		{
			interval = 3000,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 51,
					max_same = 0,
					fixed_sub_path = 1,
					creep = "eb_jt",
					path = 1,
					interval_next = 150,
					max = 1
				}}
			}}
		}
	}
}
