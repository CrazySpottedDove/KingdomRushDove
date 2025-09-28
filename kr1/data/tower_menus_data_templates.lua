local scripts = require("kr1.data.tower_menus_data_scripts")
local merge = scripts.merge

local templates = {}

-- 常见升级按钮（上箭头）
templates.common_upgrade = {
    check = "main_icons_0019",
    action_arg = nil,
    action = "tw_upgrade",
    halo = "glow_ico_main",
    image = "main_icons_0005",
    place = 5,
    tt_title = nil,
    tt_desc = nil
}

-- 升级按钮
templates.upgrade = {
    check = "main_icons_0019",
    action_arg = nil,
    action = "tw_upgrade",
    halo = "glow_ico_main",
    image = nil,
    place = nil,
    preview = nil,
    tt_title = nil,
    tt_desc = nil
}

-- 技能升级按钮
templates.upgrade_power = {
    check = "special_icons_0020",
    action_arg = nil,
    action = "upgrade_power",
    image = nil,
    place = nil,
    halo = "glow_ico_special",
    sounds = {},
    tt_phrase = nil,
    tt_list =
    {
        {
            tt_title = nil,
            tt_desc = nil
        },
        {
            tt_title = nil,
            tt_desc = nil
        },
        {
            tt_title = nil,
            tt_desc = nil
        }
    }
}

-- 购买雇佣兵按钮
templates.buy_soldier = {
    action = "tw_buy_soldier",
    action_arg = nil,
    halo = "glow_ico_main",
    image = nil,
    place = 5,
    tt_title = nil,
    tt_desc = nil
}

-- 购买攻击按钮
templates.buy_attack = {
    check = "main_icons_0019",
    action = "tw_buy_attack",
    action_arg = nil,
    halo = "glow_ico_main",
    image = nil,
    place = 5,
    tt_title = nil,
    tt_desc = nil
}

-- 出售按钮
templates.sell = {
    check = "ico_sell_0002",
    action = "tw_sell",
    halo = "glow_ico_sell",
    image = "ico_sell_0001",
    place = 9
}

-- 集结按钮
templates.rally = {
    action = "tw_rally",
    halo = "glow_ico_sub",
    image = "sub_icons_0001",
    place = 8
}

-- 瞄准按钮
templates.point = {
    check = "sub_icons_0002",
    action = "tw_point",
    halo = "glow_ico_sub",
    image = "sub_icons_0002",
    place = 8
}

return templates