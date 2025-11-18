-- 用于生成出怪文件的初稿
local data = {
    max_waves = 15 -- 最大波数
    ,
    initial_cash = 800 -- 初始资金
    ,
    initial_inverval = 800 -- 初始每大波持续时间
    ,
    final_interval = 1600 -- 最终每大波持续时间
    ,
    paths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} -- 允许的路径
    ,
    path_active_map = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
        [5] = 1,
        [6] = 1,
        [7] = 1,
        [8] = 1,
        [9] = 1,
        [10] = 1,
        [11] = 1
    }, -- 在这些波次，path 才被激活
    path_weight_map = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
        [5] = 1,
        [6] = 1,
        [7] = 1,
        [8] = 1,
        [9] = 1,
        [10] = 1,
        [11] = 1,
        [12] = 1,
        [13] = 1
    }, -- 每一个路径分配出怪权重时的权重。每次出怪时，取活跃路径的权重相加，然后再根据各路径权重分配出怪权重
    path_enemy_map = {
        [1] = {"enemy_cannibal", -- 野蛮人
        "enemy_cannibal_volcano_normal", -- 野蛮人狂战士
        "enemy_hunter", -- 野蛮人猎手
        "enemy_shaman_priest", -- 恢复萨满
        "enemy_shaman_magic", -- 法抗萨满
        "enemy_shaman_rage", -- 加伤加速萨满
        "enemy_shaman_shield", -- 物抗萨满
        "enemy_shaman_necro", -- 拉尸体萨满
        "enemy_cannibal_zombie", -- 野蛮人僵尸
        "enemy_jungle_spider_tiny", -- 丛林小蜘蛛
        "enemy_jungle_spider_small", -- 丛林蜘蛛
        "enemy_jungle_spider_big", -- 大丛林蜘蛛
        "enemy_gorilla", -- 大猩猩
        "enemy_alien_breeder", -- 抱脸虫
        "enemy_alien_reaper", -- 抱脸虫生出来的
        "enemy_savage_bird", -- 巨鸟
        "enemy_savage_bird_rider", -- 巨鸟骑士,
        "enemy_shaman_gravity" -- 反重力萨满
        },
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
        [10] = {},
        [11] = {}
    } -- 每条路径允许出哪些敌人
    ,
    enemy_weight_map = {
        ["enemy_cannibal"] = 1,
        ["enemy_cannibal_volcano_normal"] = 1,
        ["enemy_hunter"] = 1,
        ["enemy_shaman_priest"] = 1,
        ["enemy_shaman_magic"] = 1,
        ["enemy_shaman_rage"] = 1,
        ["enemy_shaman_shield"] = 1,
        ["enemy_shaman_necro"] = 1,
        ["enemy_cannibal_zombie"] = 1,
        ["enemy_jungle_spider_tiny"] = 1,
        ["enemy_jungle_spider_small"] = 1,
        ["enemy_jungle_spider_big"] = 1,
        ["enemy_gorilla"] = 1,
        ["enemy_alien_breeder"] = 1,
        ["enemy_alien_reaper"] = 1,
        ["enemy_savage_bird"] = 1,
        ["enemy_savage_bird_rider"] = 1,
        ["enemy_shaman_gravity"] = 1
    } -- 敌人的权重
    ,
    enemy_comeout_wave_map = {
        ["enemy_cannibal"] = 1,
        ["enemy_cannibal_volcano_normal"] = 1,
        ["enemy_hunter"] = 1,
        ["enemy_shaman_priest"] = 1,
        ["enemy_shaman_magic"] = 1,
        ["enemy_shaman_rage"] = 1,
        ["enemy_shaman_shield"] = 1,
        ["enemy_shaman_necro"] = 1,
        ["enemy_cannibal_zombie"] = 1,
        ["enemy_jungle_spider_tiny"] = 1,
        ["enemy_jungle_spider_small"] = 1,
        ["enemy_jungle_spider_big"] = 1,
        ["enemy_gorilla"] = 1,
        ["enemy_alien_breeder"] = 1,
        ["enemy_alien_reaper"] = 1,
        ["enemy_savage_bird"] = 1,
        ["enemy_savage_bird_rider"] = 1,
        ["enemy_shaman_gravity"] = 1
    }, -- 敌人首次出现的波次
    enemy_delete_wave_map = {
        [1] = {
            [4] = {"enemy_cannibal"},
            [8] = {"enemy_hunter"}
        },
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
        [10] = {},
        [11] = {}
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
