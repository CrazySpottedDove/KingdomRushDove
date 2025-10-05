-- chunkname: @./kr3/data/waves/level01_waves_challenge.lua

return {
	cash = 1300,
	groups = {
		-- 第一波：双路混合进攻
		{
			interval = 600,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 40,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_brigand",
							path = 1,
							interval_next = 80,
							max = 8
						},
						{
							interval = 20,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_bandit",
							path = 1,
							interval_next = 40,
							max = 10
						}
					}
				},
				{
					delay = 100,  -- 错开出怪时间
					path_index = 2,
					spawns = {
						{
							interval = 60,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 80,
							max = 6
						},
						{
							interval = 80,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll_skater",
							path = 1,
							interval_next = 0,
							max = 3
						}
					}
				}
			}
		},
		-- 第二波：巨魔主力双路夹击
		{
			interval = 700,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 45,
							max_same = 4,
							fixed_sub_path = 0,
							creep = "enemy_troll",
							path = 1,
							interval_next = 100,
							max = 9
						},
						{
							interval = 70,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_troll_axe_thrower",
							path = 1,
							interval_next = 0,
							max = 2
						}
					}
				},
				{
					delay = 50,
					path_index = 2,
					spawns = {
						{
							interval = 40,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_troll_skater",
							path = 1,
							interval_next = 90,
							max = 6
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 0,
							max = 3
						}
					}
				}
			}
		},
		-- 第三波：精英部队双路强攻
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 60,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_marauder",
							path = 1,
							interval_next = 120,
							max = 6
						},
						{
							interval = 100,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll_chieftain",
							path = 1,
							interval_next = 0,
							max = 1
						},
						{
							interval = 80,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_dark_knight",
							path = 1,
							interval_next = 0,
							max = 3
						}
					}
				},
				{
					delay = 80,
					path_index = 2,
					spawns = {
						{
							interval = 50,
							max_same = 4,
							fixed_sub_path = 0,
							creep = "enemy_troll_skater",
							path = 1,
							interval_next = 100,
							max = 10
						},
						{
							interval = 120,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll_chieftain",
							path = 1,
							interval_next = 0,
							max = 1
						}
					}
				}
			}
		},
		-- 第四波：野兽双路突击
		{
			interval = 900,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 30,
							max_same = 6,
							fixed_sub_path = 0,
							creep = "enemy_whitewolf",
							path = 1,
							interval_next = 150,
							max = 18
						},
						{
							interval = 80,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_yeti",
							path = 1,
							interval_next = 0,
							max = 3
						}
					}
				},
				{
					delay = 60,
					path_index = 2,
					spawns = {
						{
							interval = 20,
							max_same = 8,
							fixed_sub_path = 0,
							creep = "enemy_wolf",
							path = 1,
							interval_next = 120,
							max = 25
						},
						{
							interval = 70,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_yeti",
							path = 1,
							interval_next = 0,
							max = 2
						}
					}
				}
			}
		},
		-- 第五波：混合兵种双路压制
		{
			interval = 1000,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 10,
							max_same = 12,
							fixed_sub_path = 0,
							creep = "enemy_spider_tiny",
							path = 1,
							interval_next = 200,
							max = 50
						},
						{
							interval = 70,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_spider_big",
							path = 1,
							interval_next = 150,
							max = 6
						},
						{
							interval = 90,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_raider",
							path = 1,
							interval_next = 0,
							max = 3
						}
					}
				},
				{
					delay = 100,
					path_index = 2,
					spawns = {
						{
							interval = 80,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_sarelgaz_small",
							path = 1,
							interval_next = 120,
							max = 10
						},
						{
							interval = 60,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_pillager",
							path = 1,
							interval_next = 100,
							max = 4
						},
						{
							interval = 120,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_slayer",
							path = 1,
							interval_next = 0,
							max = 2
						}
					}
				}
			}
		},
		-- 第六波：最终双路决战
		{
			interval = 1200,
			waves = {
				{
					delay = 0,
					path_index = 1,
					spawns = {
						{
							interval = 35,
							max_same = 8,
							fixed_sub_path = 0,
							creep = "enemy_troll_skater",
							path = 1,
							interval_next = 200,
							max = 20
						},
						{
							interval = 90,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_troll_brute",
							path = 1,
							interval_next = 150,
							max = 5
						},
						{
							interval = 120,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll_chieftain",
							path = 1,
							interval_next = 0,
							max = 2
						}
					}
				},
				{
					delay = 80,
					path_index = 2,
					spawns = {
						{
							interval = 50,
							max_same = 5,
							fixed_sub_path = 0,
							creep = "enemy_troll_axe_thrower",
							path = 1,
							interval_next = 120,
							max = 10
						},
						{
							interval = 80,
							max_same = 3,
							fixed_sub_path = 0,
							creep = "enemy_yeti",
							path = 1,
							interval_next = 100,
							max = 5
						},
						{
							interval = 150,
							max_same = 0,
							fixed_sub_path = 0,
							creep = "enemy_troll_chieftain",
							path = 1,
							interval_next = 0,
							max = 2
						},
						{
							interval = 100,
							max_same = 2,
							fixed_sub_path = 0,
							creep = "enemy_rocketeer",
							path = 1,
							interval_next = 0,
							max = 5
						}
					}
				}
			}
		}
	}
}