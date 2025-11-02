require("constants")
require("entity_db")
local damage_type_map = {
    [DAMAGE_TRUE] = "真实伤害"
}

local function str(...)
    local t = {}
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "number" then
            -- 判断是否为整数，若不是则保留两位小数
            if math.type and math.type(v) == "integer" or v == math.floor(v) then
                t[#t + 1] = tostring(v)
            else
                t[#t + 1] = string.format("%.2f", v)
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

local function set_hero(hero_name)
    h = E:get_template(hero_name)
end
local function set_skill(skill)
    s = skill
    max_lvl = _max_level(s)
end
local function set_bullet(bullet_name)
    b = E:get_template(bullet_name)
end
local function get_cooldown()
    cooldown = s.cooldown[max_lvl]
end

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

local H = {}
H.default = {
    ["加工中"] = "加工中"
}

H.hero_alleria = {}
local map = H.hero_alleria

set_hero("hero_alleria")
set_skill(h.hero.skills.multishot)
get_cooldown()
local count = s.count_base + s.count_inc * max_lvl
set_bullet("arrow_multishot_hero_alleria")
get_damage(b.bullet)

map["多重射击"] = str("每隔", cooldown,
    "秒，小公主瞄准一小片敌人，合理分配箭矢目标，射出共", count, "发精灵箭矢，造成",
    d[1].damage_min, "-", d[1].damage_max, "点", d[1].damage_type, "。当命中同一敌人时，伤害衰减20点。")

set_skill(h.hero.skills.callofwild)
cooldown = h.timed_attacks.list[1].cooldown

map["野性呼唤"] = str()
map["追猎箭矢"] = str()

return H
