-- chunkname: @./kr3/data/waves/level01_waves_single_challenge.lua
return {
    cash = 1600, -- 增加金币应对兵营建设成本
    groups = { -- 单波持续压力挑战（箭塔+兵营限定）
    {
        interval = 0,
        waves = { -- 路径1：轻甲和中等装甲单位为主
        {
            delay = 0,
            path_index = 1,
            spawns = {{
                interval = 35,
                max_same = 5,
                fixed_sub_path = 0,
                creep = "enemy_brigand", -- 轻甲，箭塔有效
                path = 1,
                interval_next = 180,
                max = 30
            }, {
                interval = 60,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_bandit", -- 轻甲，箭塔有效
                path = 1,
                interval_next = 150,
                max = 25
            }, {
                interval = 100,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_marauder", -- 中等装甲，需要高级箭塔或士兵
                path = 1,
                interval_next = 200,
                max = 15
            }, {
                interval = 150,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll", -- 重甲，考验兵营和高级箭塔
                path = 1,
                interval_next = 180,
                max = 12
            }}
        }, -- 路径2：快速单位和远程单位
        {
            delay = 40,
            path_index = 2,
            spawns = {{
                interval = 45,
                max_same = 6,
                fixed_sub_path = 0,
                creep = "enemy_troll_skater", -- 快速，考验兵营拦截
                path = 1,
                interval_next = 160,
                max = 25
            }, {
                interval = 80,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_troll_axe_thrower", -- 远程，需要箭塔压制
                path = 1,
                interval_next = 200,
                max = 12
            }, {
                interval = 70,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_whitewolf", -- 快速轻甲，箭塔有效但需要数量
                path = 1,
                interval_next = 150,
                max = 20
            }, {
                interval = 90,
                max_same = 5,
                fixed_sub_path = 0,
                creep = "enemy_wolf", -- 快速轻甲，考验兵营阻挡
                path = 1,
                interval_next = 120,
                max = 30
            }}
        }, -- 路径1中期：混合压力测试
        {
            delay = 350,
            path_index = 1,
            spawns = {{
                interval = 50,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_troll_skater", -- 快速单位突破
                path = 1,
                interval_next = 100,
                max = 15
            }, {
                interval = 100,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll_axe_thrower", -- 远程压制
                path = 1,
                interval_next = 120,
                max = 8
            }, {
                interval = 120,
                max_same = 1,
                fixed_sub_path = 0,
                creep = "enemy_troll_brute", -- 重甲坦克，需要高级兵营
                path = 1,
                interval_next = 150,
                max = 4
            }}
        }, -- 路径2后期：精英单位考验
        {
            delay = 450,
            path_index = 2,
            spawns = {{
                interval = 60,
                max_same = 3,
                fixed_sub_path = 0,
                creep = "enemy_marauder", -- 中等装甲集群
                path = 1,
                interval_next = 140,
                max = 12
            }, {
                interval = 100,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll", -- 重甲单位
                path = 1,
                interval_next = 160,
                max = 8
            }, {
                interval = 150,
                max_same = 1,
                fixed_sub_path = 0,
                creep = "enemy_troll_chieftain", -- 首领，考验兵营和高级箭塔配合
                path = 1,
                interval_next = 200,
                max = 2
            }, {
                interval = 80,
                max_same = 4,
                fixed_sub_path = 0,
                creep = "enemy_whitewolf", -- 快速单位伴随首领
                path = 1,
                interval_next = 0,
                max = 15
            }}
        }, -- 最终压力：快速单位海
        {
            delay = 600,
            path_index = 1,
            spawns = {{
                interval = 20,
                max_same = 8,
                fixed_sub_path = 0,
                creep = "enemy_troll_skater", -- 大量快速单位
                path = 1,
                interval_next = 80,
                max = 35
            }, {
                interval = 25,
                max_same = 6,
                fixed_sub_path = 0,
                creep = "enemy_whitewolf", -- 快速轻甲混合
                path = 1,
                interval_next = 60,
                max = 25
            }, {
                interval = 100,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_troll_axe_thrower", -- 远程支援
                path = 1,
                interval_next = 0,
                max = 6
            }}
        }}
    }}
}
