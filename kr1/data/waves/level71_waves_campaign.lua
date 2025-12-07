-- chunkname: @./kr3/data/waves/level01_waves_campaign.lua
return {
	cash = 1200,
	groups = {
		-- 第一波
		{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 80,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 100,
					max = 6
				}, {
					interval = 25,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_bandit",
					path = 1,
					interval_next = 50,
					max = 7
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 100,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 100,
					max = 4
				}, {
					interval = 25,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 50,
					max = 1
				}}
			}}
		},
		-- 第二波
		{
			interval = 800,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 50,
					max = 5
				}, {
					interval = 40,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 50,
					max = 7
				}, {
					interval = 51,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 0,
					max = 6
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 6
				}, {
					interval = 25,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_marauder",
					path = 1,
					interval_next = 50,
					max = 2
				}}
			}}
		},
		-- 第三波
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 50,
					max = 3
				}, {
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_chieftain",
					path = 1,
					interval_next = 0,
					max = 1
				}, {
					interval = 30,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 50,
					max = 10
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 100,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_marauder",
					path = 1,
					interval_next = 0,
					max = 3
				}, {
					interval = 35,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 150,
					max = 8
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_dark_knight",
					path = 1,
					interval_next = 0,
					max = 5
				}}
			}}
		},
		-- 第四波
		{
			interval = 1300,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 200,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_slayer",
					path = 1,
					interval_next = 0,
					max = 3
				}}
			}}
		},
		-- 第五波
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 300,
					max = 5
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 50,
					max = 7
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 50,
					max = 5
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_big",
					path = 1,
					interval_next = 0,
					max = 5
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_small",
					path = 1,
					interval_next = 150,
					max = 10
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_small",
					path = 1,
					interval_next = 150,
					max = 10
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_small",
					path = 1,
					interval_next = 0,
					max = 10
				}, {
					interval = 45,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_sarelgaz_small",
					path = 1,
					interval_next = 150,
					max = 2
				}}
			}}
		},
		-- 第六波
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_chieftain",
					path = 1,
					interval_next = 0,
					max = 2
				}, {
					interval = 40,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll",
					path = 1,
					interval_next = 200,
					max = 15
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 0,
					max = 5
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 50,
					max = 5
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_marauder",
					path = 1,
					interval_next = 200,
					max = 5
				}, {
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_raider",
					path = 1,
					interval_next = 150,
					max = 2
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_sarelgaz_small",
					path = 1,
					interval_next = 150,
					max = 5
				}}
			}}
		},
		-- 第七波
		{
			interval = 1500,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 200,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 0,
					max = 5
				}, {
					interval = 100,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 200,
					max = 12
				}}
			}, {
				delay = 100,
				path_index = 1,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_slayer",
					path = 1,
					interval_next = 0,
					max = 3
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_brigand",
					path = 1,
					interval_next = 0,
					max = 20
				}}
			}}
		},
		-- 第八波
		{
			interval = 1500,
			waves = {{
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_sarelgaz_small",
					path = 1,
					interval_next = 0,
					max = 8
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_big",
					path = 1,
					interval_next = 150,
					max = 5
				}, {
					interval = 5,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_tiny",
					path = 1,
					interval_next = 150,
					max = 20
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_sarelgaz_small",
					path = 1,
					interval_next = 0,
					max = 10
				}}
			}}
		},
		-- 第九波
		{
			interval = 1200,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_brute",
					path = 1,
					interval_next = 150,
					max = 3
				}, {
					interval = 60,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 300,
					max = 25
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_pillager",
					path = 1,
					interval_next = 300,
					max = 3
				}, {
					interval = 100,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_raider",
					path = 1,
					interval_next = 150,
					max = 3
				}}
			}, {
				delay = 300,
				path_index = 1,
				spawns = {{
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_marauder",
					path = 1,
					interval_next = 0,
					max = 8
				}}
			}}
		},
		-- 第十波
		{
			interval = 1800,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 60,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 0,
					max = 30
				}}
			}, {
				delay = 225,
				path_index = 2,
				spawns = {{
					interval = 60,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 0,
					max = 30
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 160,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_pillager",
					path = 1,
					interval_next = 150,
					max = 5
				}}
			}, {
				delay = 575,
				path_index = 1,
				spawns = {{
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_raider",
					path = 1,
					interval_next = 150,
					max = 5
				}}
			}}
		},
		-- 第十一波
		{
			interval = 1800,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 0,
					max = 15
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 300,
					max = 20
				}, {
					interval = 20,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 0,
					max = 10
				}}
			}, {
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 0,
					max = 15
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_wolf",
					path = 1,
					interval_next = 300,
					max = 20
				}, {
					interval = 20,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 0,
					max = 10
				}}
			}, {
				delay = 200,
				path_index = 1,
				spawns = {{
					interval = 5,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_tiny",
					path = 1,
					interval_next = 100,
					max = 50
				}}
			}, {
				delay = 200,
				path_index = 1,
				spawns = {{
					interval = 5,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_spider_tiny",
					path = 1,
					interval_next = 100,
					max = 50
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 60,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_rocketeer",
					path = 1,
					interval_next = 100,
					max = 15
				}}
			}}
		},
		-- 第十二波
		{
			interval = 1800,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_chieftain",
					path = 1,
					interval_next = 0,
					max = 3
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_axe_thrower",
					path = 1,
					interval_next = 300,
					max = 10
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 300,
					max = 15
				}, {
					interval = 10,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 150,
					max = 10
				}, {
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_brute",
					path = 1,
					interval_next = 0,
					max = 5
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 85,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_sarelgaz_small",
					path = 1,
					interval_next = 100,
					max = 25
				}, {
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_raider",
					path = 1,
					interval_next = 100,
					max = 10
				}}
			}}
		},
		-- 第十三波
		{
			interval = 1800,
			waves = {{
				delay = 0,
				path_index = 2,
				spawns = {{
					interval = 300,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "eb_ulgukhai",
					path = 1,
					interval_next = 0,
					max = 1
				}, {
					interval = 200,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_brute",
					path = 1,
					interval_next = 300,
					max = 8
				}, {
					interval = 75,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_troll_skater",
					path = 1,
					interval_next = 300,
					max = 15
				}, {
					interval = 50,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_yeti",
					path = 1,
					interval_next = 150,
					max = 10
				}, {
					interval = 5,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_whitewolf",
					path = 1,
					interval_next = 150,
					max = 60
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 25,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "eb_kingpin",
					path = 1,
					interval_next = 100,
					max = 1
				}, {
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_raider",
					path = 1,
					interval_next = 100,
					max = 10
				}, {
					interval = 150,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_pillager",
					path = 1,
					interval_next = 100,
					max = 10
				}, {
					interval = 100,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_slayer",
					path = 1,
					interval_next = 100,
					max = 10
				}}
			}, {
				delay = 0,
				path_index = 1,
				spawns = {{
					interval = 25,
					max_same = 0,
					fixed_sub_path = 0,
					creep = "enemy_marauder",
					path = 1,
					interval_next = 100,
					max = 40
				}}
			}}
		}
	}
}
