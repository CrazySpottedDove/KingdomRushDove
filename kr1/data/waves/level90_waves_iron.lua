return {
    cash = 800, -- 钢铁挑战通常初始金钱为0
    live = 1, -- 钢铁挑战只有1条命
    groups = {{ -- 钢铁挑战单波
        interval = 0.0,
        waves = {{ -- 第1组：开局小型蜘蛛
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_spider_small",
                max_same = 1,
                max = 8,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 60.0
            }}
        }, { -- 第2组：另一路径小型蜘蛛
            some_flying = false,
            delay = 30.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_spider_small",
                max_same = 1,
                max = 8,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 80.0
            }}
        }, { -- 第3组：剑蜘蛛登场
            some_flying = false,
            delay = 180.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_sword_spider",
                max_same = 1,
                max = 4,
                interval = 60.0,
                fixed_sub_path = 0,
                interval_next = 90.0
            }}
        }, { -- 第4组：另一路径剑蜘蛛
            some_flying = false,
            delay = 225.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_sword_spider",
                max_same = 1,
                max = 4,
                interval = 60.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        }, { -- 第5组：大型蜘蛛
            some_flying = false,
            delay = 450.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_spider_big",
                max_same = 1,
                max = 2,
                interval = 90.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        }, { -- 第6组：吐网蜘蛛（魔法抗性较高）
            some_flying = false,
            delay = 600.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_webspitting_spider",
                max_same = 1,
                max = 3,
                interval = 80.0,
                fixed_sub_path = 0,
                interval_next = 150.0
            }}
        }, { -- 第7组：腐化小蜘蛛群
            some_flying = false,
            delay = 800.0,
            path_index = 3,
            spawns = {{
                creep = "enemy_spider_rotten_tiny_with_gold",
                max_same = 1,
                max = 12,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 100.0
            }}
        }, { -- 第8组：另一路径腐化小蜘蛛
            some_flying = false,
            delay = 900.0,
            path_index = 4,
            spawns = {{
                creep = "enemy_spider_rotten_tiny_with_gold",
                max_same = 1,
                max = 12,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        }, { -- 第9组：Sarelgaz小型单位
            some_flying = false,
            delay = 1200.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 4,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 150.0
            }}
        },{ -- 第7组：腐化小蜘蛛群
            some_flying = false,
            delay = 1300.0,
            path_index = 3,
            spawns = {{
                creep = "enemy_spider_rotten_tiny_with_gold",
                max_same = 1,
                max = 15,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 100.0
            }}
        }, { -- 第8组：另一路径腐化小蜘蛛
            some_flying = false,
            delay = 1200.0,
            path_index = 4,
            spawns = {{
                creep = "enemy_spider_rotten_tiny_with_gold",
                max_same = 1,
                max = 15,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        },  { -- 第10组：蜘蛛法师（压力测试）
            some_flying = false,
            delay = 1350.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_arachnomancer",
                max_same = 1,
                max = 2,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 180.0
            }}
        }, { -- 第9组：Sarelgaz小型单位
            some_flying = false,
            delay = 2000.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_spider_rotten",
                creep_aux = "enemy_arachnomancer",
                max_same = 1,
                max = 4,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 180.0
            }}
        }, { -- 第10组：蜘蛛法师（压力测试）
            some_flying = false,
            delay = 2000.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_spider_rotten",
                creep_aux = "enemy_arachnomancer",
                max_same = 1,
                max = 4,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 180.0
            }}
        }, { -- 第11组：最终混合部队
            some_flying = false,
            delay = 3200.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_spider_son_of_mactans",
                max_same = 1,
                max = 24,
                interval = 50.0,
                fixed_sub_path = 0,
                interval_next = 100.0
            }}
        }, {
            some_flying = false,
            delay = 3000.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_spider_small_big",
                max_same = 1,
                max = 8,
                interval = 40.0,
                fixed_sub_path = 0,
                interval_next = 80.0
            }}
        },{ -- 第12组：另一路径最终部队
            some_flying = false,
            delay = 3200.0,
            path_index = 2,
            spawns = {{
                creep = "enemy_sarelgaz_big",
                max_same = 1,
                max = 2,
                interval = 200.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        },{ -- 第12组：另一路径最终部队
            some_flying = false,
            delay = 3600.0,
            path_index = 1,
            spawns = {{
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 4,
                interval = 200.0,
                fixed_sub_path = 0,
                interval_next = 120.0
            }}
        }}
    }}
}
