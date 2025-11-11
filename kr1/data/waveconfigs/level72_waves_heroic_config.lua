-- 用于生成出怪文件的初稿
local data = {
    max_waves = 6 -- 最大波数
    ,
    initial_cash = 900 -- 初始资金
    ,
    initial_inverval = 1000 -- 初始每大波持续时间
    ,
    final_interval = 2000 -- 最终每大波持续时间
    ,
    paths = {1, 2, 9, 10, 11, 12 ,13} -- 允许的路径
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
        [13] = 1,
    }, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
    path_enemy_map = {
        [1] = {"enemy_skeleton", "enemy_skeleton_big", "enemy_necromancer", "enemy_gargoyle",
               "enemy_fallen_knight", "enemy_spectral_knight", "enemy_ghost", "enemy_elvira", "enemy_giant_rat",
               "enemy_wererat", "enemy_phantom_death_rider"},
        [2] = {"enemy_gargoyle", "enemy_abomination", "enemy_zombiemancer", "enemy_halloween_zombie", "enemy_ghoul",
               "enemy_werewolf", "enemy_lycan", "enemy_lycan_werewolf", "enemy_zombie", "enemy_rotten_tree",
               "enemy_lycan_werewolf_phantom", "enemy_witch"},
        [9] = {"enemy_skeleton", "enemy_skeleton_big"},
        [10] = {"enemy_halloween_zombie"},
        [11] = {"enemy_zombie"},
        [12] = {"enemy_skeleton"},
        [13] = {"enemy_halloween_zombie"}
    } -- 每条路径允许出哪些敌人
    ,
    enemy_weight_map = {
        ["enemy_halloween_zombie"] = 1.5,
        ["enemy_skeleton"] = 1.2,
        ["enemy_skeleton_big"] = 2,
        ["enemy_necromancer"] = 15,
        ["enemy_gargoyle"] = 2,
        ["enemy_fallen_knight"] = 9,
        ["enemy_spectral_knight"] = 7,
        ["enemy_ghost"] = 2.5,
        ["enemy_elvira"] = 10,
        ["enemy_giant_rat"] = 1.6,
        ["enemy_wererat"] = 3,
        ["enemy_abomination"] = 9,
        ["enemy_zombiemancer"] = 20,
        ["enemy_ghoul"] = 3,
        ["enemy_werewolf"] = 6,
        ["enemy_lycan"] = 9,
        ["enemy_lycan_werewolf"] = 9,
        ["enemy_zombie"] = 1.5,
        ["enemy_rotten_tree"] = 7.5,
        ["enemy_lycan_werewolf_phantom"] = 16,
        ["enemy_phantom_death_rider"] = 8,
        ["enemy_witch"] = 10,
    } -- 敌人的权重
    ,
    enemy_comeout_wave_map = {
        ["enemy_halloween_zombie"] = 1,
        ["enemy_skeleton"] = 1,
        ["enemy_skeleton_big"] = 1,
        ["enemy_necromancer"] = 1,
        ["enemy_gargoyle"] = 7,
        ["enemy_fallen_knight"] = 7,
        ["enemy_spectral_knight"] = 6,
        ["enemy_ghost"] = 7,
        ["enemy_elvira"] = 7,
        ["enemy_phantom_death_rider"] = 7,
        ["enemy_giant_rat"] = 2,
        ["enemy_wererat"] = 2,
        ["enemy_abomination"] = 3,
        ["enemy_zombiemancer"] = 7,
        ["enemy_ghoul"] = 2,
        ["enemy_werewolf"] = 5,
        ["enemy_lycan"] = 7,
        ["enemy_lycan_werewolf"] = 6,
        ["enemy_zombie"] = 1,
        ["enemy_rotten_tree"] = 4,
        ["enemy_lycan_werewolf_phantom"] = 6,
        ["enemy_witch"] = 3,
    }, -- 敌人首次出现的波次
    enemy_delete_wave_map = {
        [1] = {
            [3] = {"enemy_necromancer","enemy_skeleton","enemy_halloween_zombie","enemy_skeleton_big","enemy_zombie","enemy_giant_rat","enemy_wererat"},
            [4] = {"enemy_skeleton"},
            [5] = {"enemy_skeleton","enemy_giant_rat", "enemy_gargoyle"},
            [6] = {"enemy_skeleton_big", "enemy_ghost"}
        },
        [2] = {
            [3] = {"enemy_necromancer","enemy_skeleton","enemy_halloween_zombie","enemy_skeleton_big","enemy_zombie","enemy_giant_rat","enemy_wererat"},
            [6] = {"enemy_gargoyle"},
            [10] = {"enemy_halloween_zombie"},
            [12] = {"enemy_zombie"}
        }
    }, -- 每一条路径在哪些波次删除哪些敌人
    wave_weight_function = function(wave_number, total_gold)
        return 50 + (total_gold ^ 0.95) / 18
    end,
    min_spawn_weight = 8, --每个 spawn 的出怪最少总权重,
    max_spawn_weight = 48, --每个 spawn 的出怪最大总权重,
    interval_function = function(weight, e, wave_number)
        return (25 + 100 * math.log(weight)) * 20 / e.motion.max_speed * (1 - wave_number / 15 * 0.6)
    end, -- 某权重怪物对应的 spawn 内 interval，允许上下 10% 浮动。interval_next 统一等于 interval * 0.2
    -- fixed_sub_path 始终赋 0
    -- delay 始终赋 0
    -- 如果怪物的 vis.flags 中含有 F_FLYING，就要为 wave 添加 some_flying = true
    wave_max_types = 5 -- 每个 wave 最多不同种类敌人数量
}

return data