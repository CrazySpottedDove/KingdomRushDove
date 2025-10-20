return {
    lives = 1,
    cash = 1400,
    groups = {{
        interval = 0,
        waves = {{ -- 路径1：沙漠单位 - 开局（0-1800帧，0-60秒）
            delay = 0,
            path_index = 1,
            spawns = {{
                interval = 24, -- 6秒
                max = 48,
                fixed_sub_path = 0,
                creep = "enemy_desert_raider",
                creep_aux = "enemy_bouncer",
                max_same = 1,
                interval_next = 450, -- 15秒
                path = 1
            }}
        }, { -- 路径2：海洋单位 - 第20秒开始（600-2400帧，20-80秒）
            delay = 600, -- 20秒
            path_index = 2,
            spawns = {{
                interval = 135, -- 5秒
                max = 12,
                fixed_sub_path = 0,
                creep = "enemy_greenfin",
                max_same = 0,
                interval_next = 135, -- 20秒
                path = 1
            },{
                interval = 65, -- 5秒
                max = 3,
                fixed_sub_path = 0,
                creep = "enemy_redspine",
                max_same = 0,
                interval_next = 135, -- 20秒
                path = 1
            },{
                interval = 135, -- 5秒
                max = 12,
                fixed_sub_path = 0,
                creep = "enemy_greenfin",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }}
        }, { -- 路径1：沙漠精英 - 第40秒开始（1200-3000帧，40-100秒）
            delay = 1200, -- 40秒
            path_index = 1,
            spawns = {{
                interval = 50, -- 10秒
                max = 32,
                fixed_sub_path = 0,
                creep = "enemy_desert_wolf",
                max_same = 0,
                interval_next = 450, -- 15秒
                path = 1
            }, {
                interval = 450, -- 15秒
                max = 6,
                fixed_sub_path = 0,
                creep = "enemy_desert_archer",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }}
        }, { -- 路径3：海洋精英 - 第60秒开始（1800-4200帧，60-140秒）
            delay = 1800, -- 60秒
            path_index = 3,
            spawns = {{
                interval = 450, -- 15秒
                max = 3,
                fixed_sub_path = 0,
                creep = "enemy_blacksurge",
                max_same = 0,
                interval_next = 450, -- 25秒
                path = 1
            },{
                interval = 450, -- 15秒
                max = 1,
                fixed_sub_path = 0,
                creep = "enemy_redgale",
                max_same = 0,
                interval_next = 750, -- 25秒
                path = 1
            }, {
                interval = 750, -- 25秒
                max = 1,
                fixed_sub_path = 0,
                creep = "enemy_bloodshell",
                max_same = 0,
                interval_next = 900, -- 30秒
                path = 1
            }}
        }, { -- 路径4：海洋群 - 第80秒开始（2400-4800帧，80-160秒）
            delay = 2400, -- 80秒
            path_index = 4,
            spawns = {{
                interval = 120, -- 4秒
                max = 25,
                fixed_sub_path = 0,
                creep = "enemy_greenfin",
                max_same = 0,
                interval_next = 450, -- 15秒
                path = 1
            }, {
                interval = 300, -- 10秒
                max = 8,
                fixed_sub_path = 0,
                creep = "enemy_deviltide",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }}
        }, { -- 路径10：飞行单位 - 第100秒开始（3000-5400帧，100-180秒）
            some_flying = true,
            delay = 3000, -- 100秒
            path_index = 10,
            spawns = {{
                interval = 120, -- 7秒
                max = 14,
                fixed_sub_path = 0,
                creep = "enemy_bat",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }, {
                interval = 750, -- 25秒
                max = 1,
                fixed_sub_path = 1,
                creep = "enemy_phantom_warrior",
                max_same = 0,
                interval_next = 900, -- 30秒
                path = 1
            }}
        }, { -- 路径2：海洋混合 - 第120秒开始（3600-6000帧，120-200秒）
            delay = 3600, -- 120秒
            path_index = 2,
            spawns = {{
                interval = 180, -- 6秒
                max = 15,
                fixed_sub_path = 0,
                creep = "enemy_greenfin",
                max_same = 0,
                interval_next = 300, -- 10秒
                path = 1
            }, {
                interval = 450, -- 15秒
                max = 5,
                fixed_sub_path = 0,
                creep = "enemy_redspine",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }, {
                interval = 750, -- 25秒
                max = 2,
                fixed_sub_path = 0,
                creep = "enemy_greenshell",
                max_same = 0,
                interval_next = 900, -- 30秒
                path = 1
            }}
        }, { -- 路径11：幽灵精英 - 第140秒开始（4200-6600帧，140-220秒）
            some_flying = true,
            delay = 4200, -- 140秒
            path_index = 11,
            spawns = {{
                interval = 900, -- 30秒
                max = 1,
                fixed_sub_path = 1,
                creep = "enemy_witch",
                max_same = 2,
                interval_next = 1200, -- 40秒
                path = 1
            }, {
                interval = 600, -- 20秒
                max = 1,
                fixed_sub_path = 1,
                creep = "enemy_phantom_warrior",
                max_same = 0,
                interval_next = 900, -- 30秒
                path = 1
            }}
        }, { -- 路径1+3：最终混合 - 第160秒开始（4800-7200帧，160-240秒）
            delay = 4800, -- 160秒
            path_index = 1,
            spawns = {{
                interval = 60, -- 7秒
                max = 24,
                fixed_sub_path = 0,
                creep = "enemy_desert_wolf",
                max_same = 0,
                interval_next = 150, -- 12秒
                path = 1
            }, {
                interval = 60, -- 12秒
                max = 8,
                fixed_sub_path = 0,
                creep = "enemy_desert_archer",
                max_same = 0,
                interval_next = 480, -- 16秒
                path = 1
            }}
        }, { -- 路径3：海洋精英混合 - 第165秒开始
            delay = 4950, -- 165秒
            path_index = 3,
            spawns = {{
                interval = 450, -- 15秒
                max = 3,
                fixed_sub_path = 0,
                creep = "enemy_blacksurge",
                max_same = 0,
                interval_next = 600, -- 20秒
                path = 1
            }, {
                interval = 750, -- 25秒
                max = 1,
                fixed_sub_path = 0,
                creep = "enemy_bloodshell",
                max_same = 0,
                interval_next = 900, -- 30秒
                path = 1
            }}
        }, { -- 路径12：最终幽灵波 - 第180秒开始（5400-9000帧，180-300秒）
            some_flying = true,
            delay = 5400, -- 180秒
            path_index = 12,
            spawns = {{
                interval = 90, -- 6秒
                max = 12,
                fixed_sub_path = 0,
                creep = "enemy_bat",
                max_same = 0,
                interval_next = 250, -- 15秒
                path = 1
            }, {
                interval = 225, -- 15秒
                max = 4,
                fixed_sub_path = 1,
                creep = "enemy_ghost",
                max_same = 0,
                interval_next = 300, -- 20秒
                path = 1
            }, {
                interval = 250, -- 25秒
                max = 1,
                fixed_sub_path = 1,
                creep = "enemy_phantom_warrior",
                max_same = 0,
                interval_next = 600, -- 30秒
                path = 1
            }, {
                interval = 525, -- 35秒
                max = 1,
                fixed_sub_path = 1,
                creep = "enemy_witch",
                max_same = 2,
                interval_next = 0,
                path = 1
            }}
        }, { -- 路径4：最终海洋群 - 第200秒开始（6000-9000帧，200-300秒）
            delay = 6000, -- 200秒
            path_index = 4,
            spawns = {{
                interval = 50, -- 3秒
                max = 30,
                fixed_sub_path = 0,
                creep = "enemy_greenfin",
                max_same = 0,
                interval_next = 100, -- 10秒
                path = 1
            }, {
                interval = 100, -- 8秒
                max = 10,
                fixed_sub_path = 0,
                creep = "enemy_deviltide",
                max_same = 0,
                interval_next = 200, -- 15秒
                path = 1
            }, {
                interval = 100, -- 15秒
                max = 5,
                fixed_sub_path = 0,
                creep = "enemy_redspine",
                max_same = 0,
                interval_next = 200, -- 20秒
                path = 1
            }, {
                interval = 180, -- 25秒
                max = 2,
                fixed_sub_path = 0,
                creep = "enemy_greenshell",
                creep_aux = "enemy_bluegale",
                max_same = 1,
                interval_next = 0,
                path = 1
            }}
        }}
    }}
}
