-- 用于生成出怪文件的初稿
local data = {
    max_waves = 6 -- 最大波数
    ,
    initial_cash = 960 -- 初始资金
    ,
    initial_inverval = 1500 -- 初始每大波持续时间
    ,
    final_interval = 2500 -- 最终每大波持续时间
    ,
    paths = {1, 2, 9, 10, 11, 12, 13} -- 允许的路径
    ,
    path_active_map = {
        [1] = 1,
        [2] = 1,
        [9] = 9,
        [10] = 10,
        [11] = 11,
        [12] = 12,
        [13] = 13
    }, -- 在这些波次，path 才被激活
    path_weight_map = {
        [1] = 5,
        [2] = 5,
        [9] = 1,
        [10] = 1,
        [11] = 1,
        [12] = 1,
        [13] = 1
    }, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
    path_enemy_map = {
        [1] = {"enemy_necromancer", "enemy_elvira", "enemy_giant_rat", "enemy_wererat"},
        [2] = {"enemy_necromancer", "enemy_giant_rat", "enemy_abomination", "enemy_ghoul", "enemy_lycan",
               "enemy_lycan_werewolf",  "enemy_witch"},
        [9] = {},
        [10] = {},
        [11] = {},
        [12] = {},
        [13] = {}
    } -- 每条路径允许出哪些敌人
    ,
    enemy_weight_map = {
        ["enemy_necromancer"] = 15,
        ["enemy_elvira"] = 10,
        ["enemy_giant_rat"] = 2,
        ["enemy_wererat"] = 8,
        ["enemy_abomination"] = 10,
        ["enemy_ghoul"] = 8,
        ["enemy_lycan"] = 15,
        ["enemy_lycan_werewolf"] = 20,
        ["enemy_witch"] = 14
    } -- 敌人的权重
    ,
    enemy_comeout_wave_map = {
        ["enemy_necromancer"] = 1,
        ["enemy_giant_rat"] = 1,
        ["enemy_ghoul"] = 2,
        ["enemy_wererat"] = 2,
        ["enemy_witch"] = 3,
        ["enemy_elvira"] = 4,
        ["enemy_abomination"] = 5,
        ["enemy_lycan"] = 6,
        ["enemy_lycan_werewolf"] = 6,
    }, -- 敌人首次出现的波次
    enemy_delete_wave_map = {
        [1] = {
            [2] = {"enemy_necromancer", "enemy_giant_rat"},
            [3] = {"enemy_necromancer", "enemy_giant_rat"},
            [4] = {"enemy_necromancer", "enemy_giant_rat", "enemy_ghoul"},
            [5] = {"enemy_necromancer", "enemy_giant_rat", "enemy_elvira"},
            [6] = {"enemy_necromancer", "enemy_giant_rat", "enemy_ghoul", "enemy_wererat", "enemy_witch", "enemy_elvira"}
        },
        [2] = {
            [2] = {"enemy_necromancer", "enemy_giant_rat"},
            [3] = {"enemy_necromancer", "enemy_giant_rat"},
            [4] = {"enemy_necromancer", "enemy_giant_rat", "enemy_ghoul"},
            [5] = {"enemy_necromancer", "enemy_giant_rat", "enemy_elvira"},
            [6] = {"enemy_necromancer", "enemy_giant_rat", "enemy_ghoul", "enemy_wererat", "enemy_witch", "enemy_elvira"}
        }
    }, -- 每一条路径在哪些波次删除哪些敌人
    wave_weight_function = function(wave_number, total_gold)
        return 50 + (total_gold ^ 0.95) / 18
    end,
    min_spawn_weight = 8, -- 每个 spawn 的出怪最少总权重,
    max_spawn_weight = 48, -- 每个 spawn 的出怪最大总权重,
    interval_function = function(weight, e, wave_number)
        return (25 + 100 * math.log(weight)) * 20 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
    end, -- 某权重怪物对应的 spawn 内 interval，允许上下 10% 浮动。interval_next 统一等于 interval * 0.2
    -- fixed_sub_path 始终赋 0
    -- delay 始终赋 0
    -- 如果怪物的 vis.flags 中含有 F_FLYING，就要为 wave 添加 some_flying = true
    wave_max_types = 5 -- 每个 wave 最多不同种类敌人数量
}

return data
