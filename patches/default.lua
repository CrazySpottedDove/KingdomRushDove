return {
    -- 如果需要英雄满级，请将此条改为 true，默认为 false
    hero_full_level_at_start = false,

    -- 出怪倍数，默认为 1(必须为整数，过大容易卡顿！)
    enemy_count_multiplier = 1,

    -- 怪物掉落金币倍率，默认为 1，向上取整
    enemy_gold_multiplier = 1,

    -- 怪物生命倍率，在已有的难度生命基础上相乘，默认为 1
    enemy_health_multiplier = 1,

    -- 开局金币数倍率，默认为 1
    gold_multiplier = 1,

    -- 英雄伤害倍率，默认为 1
    hero_damage_multiplier = 1,

    -- 英雄升级速度倍率，默认为 1
    hero_xp_gain_multiplier = 1,

    -- 路线是否倒转，默认为 false
    reverse_path = false,

    -- 血条是否显示，默认为 true
    show_health_bar = true,

    -- 启动自定义配置开关，默认为 true。如果需要恢复默认配置，可以将它变为 false
    custom_config_enabled = true,

    -- 启动无尽模式开关，默认为 false
    endless = false,

    -- 允许局内召唤英雄开关，默认为 false
    enable_hero_menu = false,
}
