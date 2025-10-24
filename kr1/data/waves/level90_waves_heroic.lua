return {
    cash = 800,
    live = 20,
    groups = {{ -- 第1波
        interval = 0.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_small",
                creep_aux = "enemy_sword_spider",
                max_same = 1,
                max = 24,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 0.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 30.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_small",
                creep_aux = "enemy_sword_spider",
                max_same = 1,
                max = 24,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 0.0
            }}
        }}
    }, { -- 第2波
        interval = 500.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_jungle_spider_tiny_with_gold",
                max_same = 1,
                max = 20,
                interval = 15.0,
                fixed_sub_path = 0,
                interval_next = 0.0
            }, { -- 出怪 2
                creep = "enemy_spider_big",
                max_same = 1,
                max = 2,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_jungle_spider_tiny_with_gold",
                max_same = 1,
                max = 20,
                interval = 15.0,
                fixed_sub_path = 0,
                interval_next = 0.0
            }, { -- 出怪 2
                creep = "enemy_spider_small_big",
                max_same = 1,
                max = 3,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }}
    }, { -- 第3波
        interval = 600.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_sword_spider",
                max_same = 1,
                max = 4,
                interval = 45.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }, { -- 出怪 2
                creep = "enemy_webspitting_spider",
                max_same = 1,
                max = 3,
                interval = 80.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_sword_spider",
                max_same = 1,
                max = 4,
                interval = 45.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }, { -- 出怪 2
                creep = "enemy_webspitting_spider",
                max_same = 1,
                max = 3,
                interval = 80.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }}
        }, { -- 第3组出怪
            some_flying = false,
            delay = 100.0,
            path_index = 3,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_rotten_tiny",
                max_same = 1,
                max = 8,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }}
        },{ -- 第3组出怪
            some_flying = false,
            delay = 100.0,
            path_index = 4,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_rotten_tiny",
                max_same = 1,
                max = 8,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }}
        }}
    }, { -- 第4波
        interval = 700.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_rotten",
                max_same = 1,
                max = 3,
                interval = 90.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }, { -- 出怪 2
                creep = "enemy_spider_son_of_mactans",
                max_same = 1,
                max = 10,
                interval = 40.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 50.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_rotten",
                max_same = 1,
                max = 3,
                interval = 90.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }, { -- 出怪 2
                creep = "enemy_spider_son_of_mactans",
                max_same = 1,
                max = 10,
                interval = 40.0,
                fixed_sub_path = 0,
                interval_next = 30.0
            }}
        }, { -- 第3组出怪
            some_flying = false,
            delay = 150.0,
            path_index = 3,
            spawns = {{ -- 出怪 1
                creep = "enemy_arachnomancer",
                creep_aux = "enemy_sarelgaz_small",
                max_same = 1,
                max = 2,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 60.0
            }}
        },{ -- 第4组出怪
            some_flying = false,
            delay = 150.0,
            path_index = 4,
            spawns = {{ -- 出怪 1
                creep = "enemy_arachnomancer",
                creep_aux = "enemy_sarelgaz_small",
                max_same = 1,
                max = 2,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 60.0
            }}
        }}
    }, { -- 第5波
        interval = 800.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 8,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }, { -- 出怪 2
                creep = "enemy_sarelgaz_big",
                max_same = 1,
                max = 1,
                interval = 200.0,
                fixed_sub_path = 0,
                interval_next = 80.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 100.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 8,
                interval = 70.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }, { -- 出怪 2
                creep = "enemy_sarelgaz_big",
                max_same = 1,
                max = 1,
                interval = 200.0,
                fixed_sub_path = 0,
                interval_next = 80.0
            }}
        }, { -- 第3组出怪
            some_flying = false,
            delay = 300.0,
            path_index = 3,
            spawns = {{ -- 出怪 1
                creep = "enemy_jungle_spider_tiny_with_gold",
                max_same = 1,
                max = 80,
                interval = 6.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }, { -- 第4组出怪
            some_flying = false,
            delay = 300.0,
            path_index = 4,
            spawns = {{ -- 出怪 1
                creep = "enemy_jungle_spider_tiny_with_gold",
                max_same = 1,
                max = 80,
                interval = 6.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }}
    }, { -- 第6波（最终波）
        interval = 900.0,
        waves = {{ -- 第1组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_big",
                max_same = 1,
                max = 2,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 60.0
            }, { -- 出怪 2
                creep = "enemy_webspitting_spider",
                max_same = 1,
                max = 6,
                interval = 45.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }}
        }, { -- 第2组出怪
            some_flying = false,
            delay = 0.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_big",
                max_same = 1,
                max = 2,
                interval = 120.0,
                fixed_sub_path = 0,
                interval_next = 60.0
            }, { -- 出怪 2
                creep = "enemy_spider_rotten",
                max_same = 1,
                max = 6,
                interval = 80.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }, { -- 第3组出怪
            some_flying = false,
            delay = 200.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 16,
                interval = 35.0,
                fixed_sub_path = 0,
                interval_next = 25.0
            }}
        }, { -- 第4组出怪
            some_flying = false,
            delay = 200.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_sarelgaz_small",
                max_same = 1,
                max = 16,
                interval = 35.0,
                fixed_sub_path = 0,
                interval_next = 25.0
            }}
        }, { -- 第5组出怪
            some_flying = false,
            delay = 400.0,
            path_index = 3,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_son_of_mactans",
                max_same = 1,
                max = 15,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }}
        }, { -- 第6组出怪
            some_flying = false,
            delay = 400.0,
            path_index = 4,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_son_of_mactans",
                max_same = 1,
                max = 15,
                interval = 30.0,
                fixed_sub_path = 0,
                interval_next = 40.0
            }}
        }, { -- 第7组出怪
            some_flying = false,
            delay = 300.0,
            path_index = 1,
            spawns = {{ -- 出怪 1
                creep = "enemy_arachnomancer",
                max_same = 1,
                max = 4,
                interval = 90.0,
                fixed_sub_path = 0,
                interval_next = 70.0
            }}
        }, { -- 第8组出怪
            some_flying = false,
            delay = 350.0,
            path_index = 2,
            spawns = {{ -- 出怪 1
                creep = "enemy_spider_small_big",
                max_same = 1,
                max = 12,
                interval = 25.0,
                fixed_sub_path = 0,
                interval_next = 50.0
            }}
        }}
    }}
}
