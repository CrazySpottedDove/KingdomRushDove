return {
    cash = 700,
    live = 20,
    groups = {
        {    -- 第1波
            interval = 0.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_small",
                            max_same = 1,
                            max = 15,
                            interval = 20.0,
                            fixed_sub_path = 0,
                            interval_next = 0.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sword_spider",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 50.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_small",
                            max_same = 1,
                            max = 15,
                            interval = 20.0,
                            fixed_sub_path = 0,
                            interval_next = 0.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sword_spider",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第2波
            interval = 600.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 300.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 30,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 0.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 300.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 30,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 0.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 400.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 500.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第3波
            interval = 800.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sword_spider",
                            max_same = 1,
                            max = 6,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sword_spider",
                            max_same = 1,
                            max = 5,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 150.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 150.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 2,
                            interval = 100.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第4波
            interval = 1000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_small",
                            max_same = 1,
                            max = 16,
                            interval = 35.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_rotten",
                            max_same = 1,
                            max = 2,
                            interval = 100.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_small",
                            max_same = 1,
                            max = 16,
                            interval = 35.0,
                            fixed_sub_path = 0,
                            interval_next = 150.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_rotten",
                            max_same = 1,
                            max = 2,
                            interval = 100.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第5波
            interval = 1200.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 75.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 50.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_big",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 3,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = true,
                    delay = 75.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_razorwing",
                            max_same = 1,
                            max = 8,
                            interval = 30.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = true,
                    delay = 75.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_razorwing",
                            max_same = 1,
                            max = 8,
                            interval = 30.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第6波
            interval = 1000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_son_of_mactans",
                            max_same = 1,
                            max = 10,
                            interval = 40.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 30.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_son_of_mactans",
                            max_same = 1,
                            max = 10,
                            interval = 40.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第7波
            interval = 800.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_rotten",
                            max_same = 1,
                            max = 5,
                            interval = 100.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_rotten_tiny",
                            max_same = 1,
                            max = 24,
                            interval = 20.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 100.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_rotten",
                            max_same = 1,
                            max = 5,
                            interval = 100.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_spider_rotten_tiny",
                            max_same = 1,
                            max = 24,
                            interval = 20.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第8波
            interval = 1000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 100.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 12.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 100.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 12.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 5,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 2,
                            interval = 150.0,
                            fixed_sub_path = 0,
                            interval_next = 150.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 75.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_webspitting_spider",
                            max_same = 1,
                            max = 5,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 250.0
                        }
                    }
                },
                {    -- 第5组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_quetzal",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第9波
            interval = 800.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 4,
                            interval = 90.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 4,
                            interval = 90.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 600.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 150,
                            interval = 7.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 600.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 150,
                            interval = 7.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第10波
            interval = 1000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 5,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_quetzal",
                            max_same = 1,
                            max = 4,
                            interval = 275.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 250.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_jungle_spider_tiny",
                            max_same = 1,
                            max = 150,
                            interval = 5.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第11波
            interval = 1100.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 1,
                            interval = 800.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 300.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 2,
                            interval = 900.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 600.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 4,
                            interval = 75.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 600.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 4,
                            interval = 75.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第12波
            interval = 2000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 15,
                            interval = 60.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 150.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 15,
                            interval = 60.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 500.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_quetzal",
                            max_same = 1,
                            max = 5,
                            interval = 135.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 350.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_quetzal",
                            max_same = 1,
                            max = 5,
                            interval = 135.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第5组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_rotten_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第6组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_rotten_tiny",
                            max_same = 1,
                            max = 100,
                            interval = 10.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第13波
            interval = 1300.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 200.0,
                    path_index = 3,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_son_of_mactans",
                            max_same = 1,
                            max = 75,
                            interval = 22.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 4,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_spider_son_of_mactans",
                            max_same = 1,
                            max = 75,
                            interval = 22.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 300.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 5,
                            interval = 300.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 200.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 5,
                            interval = 350.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第14波
            interval = 2000.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 15,
                            interval = 320.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 400.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 15,
                            interval = 320.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        },
        {    -- 第15波
            interval = 2500.0,
            waves = {
                {    -- 第1组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "eb_sarelgaz",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第2组出怪
                    some_flying = false,
                    delay = 0.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "eb_sarelgaz",
                            max_same = 1,
                            max = 1,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第3组出怪
                    some_flying = false,
                    delay = 1200.0,
                    path_index = 1,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 35,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 100.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 15,
                            interval = 150.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                },
                {    -- 第4组出怪
                    some_flying = false,
                    delay = 1200.0,
                    path_index = 2,
                    spawns = {
                        {    -- 出怪 1
                            creep = "enemy_sarelgaz_small",
                            max_same = 1,
                            max = 35,
                            interval = 50.0,
                            fixed_sub_path = 0,
                            interval_next = 100.0
                        },
                        {    -- 出怪 2
                            creep = "enemy_sarelgaz_big",
                            max_same = 1,
                            max = 15,
                            interval = 150.0,
                            fixed_sub_path = 0,
                            interval_next = 50.0
                        }
                    }
                }
            }
        }
    }
}
