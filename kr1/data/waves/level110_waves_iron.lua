-- chunkname: @./kr3/data/waves/level18_waves_campaign.lua
return {
    cash = 2500,
    groups = {{
        interval = 0,
        waves = {{
            delay = 0,
            path_index = 1,
            spawns = {{
                interval = 25,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_gnoll_gnawer",
                path = 1,
                interval_next = 100,
                max = 20
            }, {
                interval = 35,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_gnoll_burner",
                path = 1,
                interval_next = 600,
                max = 15
            }, {
                interval = 60,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_ettin",
                path = 1,
                interval_next = 300,
                max = 3
            }}
        }, {
            delay = 30,
            path_index = 2,
            spawns = {{
                interval = 30,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_hyena",
                path = 2,
                interval_next = 120,
                max = 18
            }, {
                interval = 20,
                max_same = 2,
                fixed_sub_path = 0,
                creep = "enemy_gnoll_reaver",
                path = 2,
                interval_next = 200,
                max = 20
            },{
                interval = 25,
                max_same = 0,
                fixed_sub_path = 0,
                creep = "enemy_perython_rock_thrower",
                path = 2,
                interval_next = 600,
                max = 10
            }, {
                interval = 70,
                max_same = 1,
                fixed_sub_path = 0,
                creep = "enemy_ogre_magi",
                path = 2,
                interval_next = 400,
                max = 2
            }}
        }, {
            delay = 45,
            path_index = 3,
            spawns = {{
                interval = 40,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_twilight_elf_harasser",
                path = 3,
                interval_next = 200,
                max = 12
            }, {
                interval = 45,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_twilight_scourger",
                path = 3,
                interval_next = 300,
                max = 6
            }, {
                interval = 50,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_twilight_evoker",
                path = 3,
                interval_next = 350,
                max = 4
            }}
        }, {
            delay = 300,
            path_index = 4,
            spawns = {{
                interval = 90,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_mounted_avenger",
                path = 3,
                interval_next = 600,
                max = 2
            },  {
                interval = 80,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_bloodsydian_warlock",
                path = 2,
                interval_next = 600,
                max = 3
            }, {
                interval = 40,
                max_same = 1,
                fixed_sub_path = 0,
                creep = "enemy_gnoll_blighter",
                path = 1,
                interval_next = 300,
                max = 5
            },{
                interval = 120,
                max_same = 1,
                fixed_sub_path = 1,
                creep = "enemy_twilight_golem",
                path = 3,
                interval_next = 800,
                max = 1
            }}
        }}
    }}
}
