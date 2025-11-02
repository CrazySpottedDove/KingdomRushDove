require("constants")
local E = require("entity_db")
local damage_type_map = {
    [DAMAGE_TRUE] = "真实伤害",
    [DAMAGE_PHYSICAL] = "物理伤害",
    [DAMAGE_MAGICAL] = "法术伤害",
    [DAMAGE_EXPLOSION] = "爆炸伤害",
    [DAMAGE_RUDE] = "残暴伤害",
    [DAMAGE_STAB] = "穿刺伤害",
    [DAMAGE_MAGICAL_EXPLOSION] = "法术爆炸伤害"
}

local function str(...)
    local t = {}
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "number" then
            -- 判断是否为整数或小数部分为0
            if math.type and math.type(v) == "integer" or v == math.floor(v) then
                t[#t + 1] = tostring(v)
            else
                local s = string.format("%.2f", v)
                -- 去掉末尾的.00或.0
                s = s:gsub("%.0+$", ""):gsub("(%.%d-)0+$", "%1")
                t[#t + 1] = s
            end
        else
            t[#t + 1] = tostring(v)
        end
    end
    return table.concat(t)
end

local function _max_level(skill)
    local i = 0
    for _, _ in pairs(skill.xp_level_steps) do
        i = i + 1
    end
    return i
end
local h -- 英雄
local s -- 技能
local max_lvl -- 技能最大等级
local cooldown -- 技能冷却时间
local b -- 子弹
local d = {} -- 伤害列表
local e -- 其它实体
local map
-- 写生命信息时，无甲默认不写。
local health = {{}, {}, {}} -- health 列表
local H = {}
H.default = {
    ["加工中"] = "加工中"
}

local function set_hero(hero_name)
    h = E:get_template(hero_name)
    H[hero_name] = {}
    map = H[hero_name]
end
local function set_skill(skill)
    s = skill
    max_lvl = _max_level(s)
end
local function set_bullet(bullet_name)
    b = E:get_template(bullet_name)
end

--- 当前技能拥有 .cooldown(table) 字段时，获取该字段的最大等级冷却时间，存入 cooldown 变量
local function get_cooldown()
    cooldown = s.cooldown[max_lvl]
end

-- 从拥有 damage_min, damage_max, damage_type 字段的表中获取伤害信息，存入 d 列表
local function get_damage(t, i)
    if not i then
        i = 1
    end
    if not d[i] then
        d[i] = {}
    end
    d[i].damage_min = t.damage_min
    d[i].damage_max = t.damage_max
    d[i].damage_type = damage_type_map[t.damage_type]
end

local function damage_str(i)
    if not i then
        i = 1
    end
    return str(d[i].damage_min, "-", d[i].damage_max, "点", d[i].damage_type)
end

local function hp_str(i)
    if not i then
        i = 1
    end
    return str(health[i].hp_max, "点生命值")
end

local function armor_str(i)
    if not i then
        i = 1
    end
    return str(health[i].armor * 100, "点护甲")
end

local function magic_armor_str(i)
    if not i then
        i = 1
    end
    return str(health[i].magic_armor * 100, "点魔法抗性")
end

local function get_health(t, i)
    if not i then
        i = 1
    end
    if not health[i] then
        health[i] = {}
    end
    health[i].hp_max = t.health.hp_max
    health[i].armor = t.health.armor
    health[i].magic_armor = t.health.magic_armor
end

set_hero("hero_alleria")
set_skill(h.hero.skills.multishot)
get_cooldown()
local count = s.count_base + s.count_inc * max_lvl
set_bullet("arrow_multishot_hero_alleria")
get_damage(b.bullet)

map["多重射击"] = str("每隔", cooldown,
    "秒，小公主瞄准一小片敌人，合理分配箭矢目标，射出共", count, "发精灵箭矢，造成",
    d[1].damage_min, "-", d[1].damage_max, "点", d[1].damage_type,
    "。当额外的箭矢命中同一敌人时，改为造成", d[1].damage_min, "-", d[1].damage_max - 20, "点",
    d[1].damage_type, "。")

set_skill(h.hero.skills.callofwild)
cooldown = h.timed_attacks.list[1].cooldown
health[1].hp_max = s.hp_base + s.hp_inc * max_lvl
e = E:get_template("soldier_alleria_wildcat")
get_damage(e.melee.attacks[1])
d[1].damage_min = s.damage_min_base + s.damage_inc * max_lvl
d[1].damage_max = s.damage_max_base + s.damage_inc * max_lvl

map["野性呼唤"] = str("每隔", cooldown,
    "秒，小公主召唤一只野猫，跟随小公主战斗，召唤期间保持无敌。野猫拥有",
    health[1].hp_max, "点生命值，每次攻击造成", d[1].damage_min, "-", d[1].damage_max, "点",
    d[1].damage_type, "。")

set_skill(h.hero.skills.missileshot)
cooldown = h.ranged.attacks[3].cooldown
count = s.count_base + s.count_inc * max_lvl
set_bullet("arrow_hero_alleria_missile")
get_damage(b.bullet)

map["追猎箭矢"] = str("每隔", cooldown, "秒，小公主射出一发追猎箭矢，追踪并穿刺最多", count,
    "个目标，对每个目标造成", d[1].damage_min, "-", d[1].damage_max, "点", d[1].damage_type, "。")

set_hero("hero_gerald")
set_skill(h.hero.skills.block_counter)
get_damage(h.dodge.counter_attack)
local factor = h.dodge.counter_attack.reflected_damage_factor + h.dodge.counter_attack.reflected_damage_factor_inc *
                   max_lvl
local chance = h.dodge.chance_base + h.dodge.chance_inc * max_lvl
local low_change_factor = h.dodge.low_chance_factor

map["惩戒之盾"] = str("杰拉尔德每次受到近战攻击时，有", chance * 100,
    "%的概率举盾反击，免疫并造成本次攻击伤害", factor * 100, "%的范围", d[1].damage_type,
    "。面对BOSS单位时，盾反概率×", low_change_factor * 100,
    "%；受到范围攻击时，盾反概率×60%。")

set_skill(h.hero.skills.courage)
cooldown = h.timed_attacks.list[1].cooldown
local min_count = h.timed_attacks.list[1].min_count

e = E:get_template("mod_gerald_courage")
local heal_factor = e.courage.heal_once_factor + e.courage.heal_inc * max_lvl
local damage_buff = e.courage.damage_inc * max_lvl + e.courage.damage_inc_base
local armor_buff = e.courage.armor_inc * max_lvl
local magic_armor_buff = e.courage.magic_armor_inc * max_lvl
local duration = e.modifier.duration
map["鼓舞"] = str("每隔", cooldown, "秒，在身边至少有", min_count,
    "名友军时，杰拉尔德会敲盾鼓舞他们，立刻恢复友军", heal_factor * 100,
    "%最大生命值，并在接下来的", duration, "秒内提升友军", damage_buff, "点伤害，",
    armor_buff * 100, "点护甲和", magic_armor_buff * 100,
    "点魔法抗性。抗性提升与恢复效果对英雄减半。")

set_skill(h.hero.skills.paladin)
e = E:get_template("soldier_gerald_paladin")
get_damage(e.melee.attacks[1])
d[1].damage_min = s.melee_damage_min[max_lvl]
d[1].damage_max = s.melee_damage_max[max_lvl]
get_health(e)
health[1].hp_max = s.hp_max[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
local duration = e.reinforcement.duration
map["神圣支援"] = str("每隔", cooldown,
    "秒，爵士召唤一名可调集的皇家近卫协助战斗。皇家近卫拥有", hp_str(), "，", armor_str(),
    "，", "每次攻击造成", damage_str(), "，驻场", duration, "秒。")
return H
