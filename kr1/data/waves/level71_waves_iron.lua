-- chunkname: @./kr3/data/waves/level01_waves_single_challenge.lua
return {
    cash = 1800,
    groups = {{
        interval = 0,
        waves = { -- 第一阶段：基础压力（0-400 tick）
        {
            delay = 0,
            path_index = 1,
            spawns = {{
                interval = 80,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_brigand",
                path = 1,
                interval_next = 120,
                max = 12
            }}
        }, {
            delay = 300, -- 200 tick后开始路径2
            path_index = 2,
            spawns = {{
                interval = 70,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_troll_skater",
                path = 1,
                interval_next = 140,
                max = 8
            }}
        }, -- 第二阶段：增加难度（400-600 tick）
        {
            delay = 600,
            path_index = 1,
            spawns = {{
                interval = 90,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_bandit",
                path = 1,
                interval_next = 150,
                max = 10
            }}
        }, {
            delay = 675,
            path_index = 2,
            spawns = {{
                interval = 90,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_whitewolf",
                path = 1,
                interval_next = 130,
                max = 10
            }}
        }, -- 第三阶段：重甲单位（600-800 tick）
        {
            delay = 900,
            path_index = 1,
            spawns = {{
                interval = 100,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll",
                path = 1,
                interval_next = 150,
                max = 5
            }}
        }, {
            delay = 975,
            path_index = 2,
            spawns = {{
                interval = 110,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll_axe_thrower",
                path = 1,
                interval_next = 175,
                max = 4
            }}
        }, -- 第四阶段：精英混合（800-1000 tick）
        {
            delay = 1200,
            path_index = 1,
            spawns = {{
                interval = 120,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_marauder",
                path = 1,
                interval_next = 150,
                max = 6
            }}
        }, {
            delay = 1275,
            path_index = 2,
            spawns = {{
                interval = 80,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_wolf",
                path = 1,
                interval_next = 120,
                max = 8
            }}
        }, -- 第五阶段：重型单位（1000-1200 tick）
        {
            delay = 1500,
            path_index = 1,
            spawns = {{
                interval = 150,
                max_same = 1,
                fixed_sub_path = 0,
                creep = "enemy_troll_brute",
                path = 1,
                interval_next = 600,
                max = 2
            }}
        }, -- 第六阶段：快速集群（1200-1400 tick）
        {
            delay = 2400,
            path_index = 2,
            spawns = {{
                interval = 60,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_troll_skater",
                path = 1,
                interval_next = 100,
                max = 12
            }}
        }, -- 最终阶段：双首领（1400+ tick）
        {
            delay = 2700,
            path_index = 1,
            spawns = {{
                interval = 200,
                max_same = 0,
                fixed_sub_path = 0,
                creep = "enemy_troll_chieftain",
                path = 1,
                interval_next = 150,
                max = 1
            }}
        }, {
            delay = 3000, -- 第二个首领晚200 tick出现
            path_index = 2,
            spawns = {{
                interval = 200,
                max_same = 0,
                fixed_sub_path = 0,
                creep = "enemy_troll_chieftain",
                path = 1,
                interval_next = 0,
                max = 1
            }}
        }}
    }}
}
