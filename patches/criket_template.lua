-- 这是一个编辑斗蛐蛐出怪的样例文件
-- 不要改本文件，这只是一个示例模板！
-- 想要自己编辑斗蛐蛐出怪，请去存档位置修改 criket.lua!
-- 若你的 criket 缺少一些设置将会使用本文件的设置
return {
    on = false, -- 是否启用斗蛐蛐，需要则置为 true
    cash = 50000, -- 初始金币
    gold_judge = false, -- 是否启用金币评判，启用后敌人生命会依据塔的金币总消耗变化
    gold_base = 50000, -- 金币评判的基准值，默认 50000
    groups = {{ -- 第 1 组出怪
        path_index = 1, -- 设置出怪路径为 1（至少为 1）
        delay = 5, -- 开始出这组怪的延迟，单位为秒
        spawns = {{ -- 出怪 1
            creep = "enemy_goblin", -- 选择出怪：哥布林
            max = 100, -- 总数量
            interval = 0.1, -- 每隔 0.1 秒出一个哥布林
            fixed_sub_path = 0, -- 子路径，0 为随机
            interval_next = 5 -- 出完后，过 5 秒出下一怪
        }, { -- 出怪 2
            creep = "enemy_fat_orc", -- 选择出怪：兽人
            max = 50, -- 总数量
            interval = 0.2, -- 每隔 0.2 秒出一个兽人
            fixed_sub_path = 0, -- 子路径，0 为随机
            interval_next = 0
        }}
    }, { -- 第 2 组出怪
        path_index = 1, -- 设置出怪路径为 1
        delay = 0, -- 开始出怪前的延迟，单位为秒
        spawns = {{ -- 出怪 1
            creep = "enemy_goblin", -- 选择出怪：哥布林
            max = 100, -- 总数量
            interval = 0.1, -- 每隔 0.1 秒出一个哥布林
            fixed_sub_path = 0, -- 子路径，0 为随机
            interval_next = 5 -- 出完后，过 5 秒出下一怪
        }}
    }},
    required_textures = { -- 启用的贴图列表
    "go_enemies_acaroth", "go_enemies_ancient_metropolis", "go_enemies_bandits", "go_enemies_bittering_rancor",
    "go_enemies_blackburn", "go_enemies_desert", "go_enemies_elven_woods", "go_enemies_faerie_grove",
    "go_enemies_forgotten_treasures", "go_enemies_grass", "go_enemies_halloween", "go_enemies_hulking_rage",
    "go_enemies_ice", "go_enemies_jungle", "go_enemies_mactans_malicia", "go_enemies_rising_tides", "go_enemies_rotten",
    "go_enemies_sarelgaz", "go_enemies_storm", "go_enemies_torment", "go_enemies_underground", "go_enemies_wastelands"},
    required_sounds = { -- 启用的音效列表
    "hero_gerald" -- 比如说，有一个特殊的英雄 boss gerald，可能就需要他的音效
    }
}
