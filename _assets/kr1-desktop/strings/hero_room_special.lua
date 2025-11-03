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

local function rate_str(rate)
    return str(rate * 100, "%概率")
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
    d[i].damage_type = t.damage_type
end

local function damage_str(i)
    if not i then
        i = 1
    end
    if d[i].damage_min == d[i].damage_max then
        return str(d[i].damage_min, "点", damage_type_map[d[i].damage_type])
    end
    return str(d[i].damage_min, "-", d[i].damage_max, "点", damage_type_map[d[i].damage_type])
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

local function cooldown_str()
    return str("每隔", cooldown, "秒，")
end

set_hero("hero_alleria")
set_skill(h.hero.skills.multishot)
get_cooldown()
local count = s.count_base + s.count_inc * max_lvl
set_bullet("arrow_multishot_hero_alleria")
get_damage(b.bullet)
get_damage(d[1], 2)
d[2].damage_max = d[2].damage_max - 20
map["多重射击"] = str("每隔", cooldown,
    "秒，小公主瞄准一小片敌人，合理分配箭矢目标，射出共", count, "发精灵箭矢，造成",
    damage_str(), "。当额外的箭矢命中同一敌人时，改为造成", damage_str(2), "。")

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
    "个目标，对每个目标造成", damage_str(), "。")

set_hero("hero_gerald")
set_skill(h.hero.skills.block_counter)
get_damage(h.dodge.counter_attack)
local factor = h.dodge.counter_attack.reflected_damage_factor + h.dodge.counter_attack.reflected_damage_factor_inc *
                   max_lvl
local chance = h.dodge.chance_base + h.dodge.chance_inc * max_lvl
local low_change_factor = h.dodge.low_chance_factor

map["惩戒之盾"] = str("杰拉尔德每次受到近战攻击时，有", chance * 100,
    "%的概率举盾反击，免疫并造成本次攻击伤害", factor * 100, "%的范围",
    damage_type_map[d[1].damage_type], "。面对BOSS单位时，盾反概率×", low_change_factor * 100,
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

set_hero("hero_bolin")
set_skill(h.hero.skills.mines)
set_bullet("decal_bolin_mine")
get_damage(b)
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
local radius = b.radius
cooldown = h.timed_attacks.list[3].cooldown
count = h.timed_attacks.list[3].count
duration = b.duration
map["布雷专家"] = str("每隔", cooldown, "秒，博林投掷一枚警戒范围为", radius,
    "的地雷，持续时间", duration, "秒，最多同时存在", count, "枚。地雷爆炸时，对", radius * 2,
    "范围内敌人造成", damage_str(), "。若视野内有敌人，博林将尝试直接向敌人投掷地雷。")
set_skill(h.hero.skills.tar)
duration = s.duration[max_lvl]
set_bullet("aura_bolin_tar")
radius = b.aura.radius
set_bullet("mod_bolin_slow")
factor = 1 - b.slow.factor
cooldown = h.timed_attacks.list[2].cooldown
map["焦油炸弹"] = str("每隔", cooldown,
    "秒，博林投掷一枚焦油炸弹，炸弹在命中地面后形成一片半径为", radius,
    "的焦油区域，使进入焦油区域的敌人移动速度降低", factor * 100, "%，持续", duration, "秒。")
chance = h.timed_attacks.list[4].chance
count = #h.timed_attacks.list[4].shoot_times
map["狂热连射"] = str("博林有", chance * 100, "%的概率连射", count,
    "次，每发子弹造成最大伤害。")
cooldown = h.timed_attacks.list[5].cooldown
count = h.timed_attacks.list[5].count
set_bullet("bomb_shrapnel_bolin")
get_damage(b.bullet)
radius = b.bullet.damage_radius
map["霰弹射击"] = str("每隔", cooldown, "秒，博林发射", count,
    "发霰弹，每发霰弹在命中目标后对半径", radius, "范围内的敌人造成", damage_str(), "。")

set_hero("hero_magnus")
set_skill(h.hero.skills.mirage)
count = s.count[max_lvl]
local health_factor = s.health_factor
local damage_factor = s.damage_factor
e = E:get_template("soldier_magnus_illusion")
local rain_radius_factor = e.skill_radius_factor
local rain_damage_factor = e.skill_damage_factor
duration = e.reinforcement.duration
cooldown = h.timed_attacks.list[1].cooldown
map["幻影"] = str(cooldown_str(), "马格努斯创造", count, "个幻影分身，分身拥有主英雄",
    health_factor * 100, "%的生命值，", damage_factor * 100, "%的普攻伤害，持续", duration, "秒。")
map["幻影·奥术风暴"] = str(
    "马格努斯的幻影分身会释放弱化的奥术风暴，每个幻影分身释放的奥术风暴拥有主英雄奥术风暴",
    rain_radius_factor * 100, "%的作用范围，造成", rain_damage_factor * 100, "%的魔法伤害。")
set_skill(h.hero.skills.arcane_rain)
cooldown = h.timed_attacks.list[2].cooldown
set_bullet("magnus_arcane_rain")
get_damage(b)
radius = b.damage_radius
count = s.count[max_lvl]
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map["奥术风暴"] = str(cooldown_str(), "马格努斯召唤奥术风暴，在目标区域内降下", count,
    "枚奥术雨滴，每枚雨滴对", radius, "范围内敌人造成", damage_str(), "。")

set_hero("hero_ignus")
set_skill(h.hero.skills.flaming_frenzy)
d[1].damage_type = h.timed_attacks.list[1].damage_type
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
local heal_factor = h.timed_attacks.list[1].heal_factor
radius = h.timed_attacks.list[1].max_range
cooldown = h.timed_attacks.list[1].cooldown

map["暴怒狂焰"] = str(cooldown_str(), "伊格努斯释放暴怒狂焰，对周围", radius,
    "范围内的敌人造成", damage_str(), "，并恢复", heal_factor * 100, "%最大生命值。")
set_skill(h.hero.skills.surge_of_flame)
set_bullet("aura_ignus_surge_of_flame")
get_damage(b.aura)
radius = b.aura.damage_radius
local cycle_time = b.aura.cycle_time
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown

map["烈焰喷涌"] = str(cooldown_str(),
    "伊格努斯化为火球，快速穿梭至另一名敌人面前，再穿梭回来，期间保持无敌，并对身边",
    radius, "范围内敌人每", cycle_time, "秒造成", damage_str(),
    "。若穿梭导致了目标死亡，伊格努斯将额外寻找目标穿梭。")
set_bullet("mod_ignus_burn_3")
get_damage(b.dps)
cycle_time = b.dps.damage_every
duration = b.modifier.duration

map["烈火附身"] = str("伊格努斯所有攻击有60%的概率点燃敌人，使其在接下来的", duration,
    "秒内每", cycle_time, "秒受到", damage_str(),
    "。永恒燃烧的身躯使伊格努斯免疫火焰与剧毒。")

set_hero("hero_malik")
set_bullet("mod_malik_stun")
duration = b.modifier.duration
chance = h.melee.attacks[2].chance
map["震慑"] = str("马利克每次普攻有", rate_str(chance), "震慑敌人，使敌人眩晕", duration, "秒。")
set_skill(h.hero.skills.smash)
cooldown = h.melee.attacks[3].cooldown
get_damage(h.melee.attacks[3])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
chance = s.stun_chance[max_lvl]
radius = h.melee.attacks[3].damage_radius
map["粉碎重锤"] = str(cooldown_str(), "马利克调动重锤之力，对面前", radius, "范围内敌人造成",
    damage_str(), "，并有", rate_str(chance), "使其眩晕", duration,
    "秒。该技能获取经验量和造成总伤相关。")
set_skill(h.hero.skills.fissure)
set_bullet("aura_malik_fissure")
get_damage(b.aura)
radius = b.aura.damage_radius
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.melee.attacks[4].cooldown
map["地震"] = str(cooldown_str(), "马利克高高跃起，锤击地面，引起数片地震，每片地震对",
    radius, "范围内敌人造成", damage_str(), "，并使其眩晕", duration,
    "秒。在道路的交汇处，地震将额外向多条道路蔓延。")

set_hero("hero_denas")
set_skill(h.hero.skills.tower_buff)
duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
set_bullet("mod_denas_tower")
local s_range_factor = b.range_factor - 1
local s_cooldown_factor = 1 - b.cooldown_factor
local range = h.timed_attacks.list[2].max_range
map["皇家号令"] = str(cooldown_str(), "迪纳斯发出皇家号令，使", range,
    "范围内友军防御塔攻击范围提升", s_range_factor * 100, "%，冷却下降", s_cooldown_factor * 100,
    "%，持续", duration, "秒。")
set_skill(h.hero.skills.catapult)
cooldown = h.timed_attacks.list[3].cooldown
set_bullet("denas_catapult_rock")
get_damage(b.bullet)
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
count = s.count[max_lvl]
radius = b.bullet.damage_radius
map["投石弹幕"] = str(cooldown_str(), "迪纳斯命令投石机向目标区域发射", count,
    "块巨石，每块巨石对", radius, "范围内敌人造成", damage_str(), "。")
local s_price_factor = 1 - h.tower_price_factor
map["资源调配"] = str("迪纳斯国王优秀的资源调配能力使所有防御塔的造价降低",
    s_price_factor * 100, "%。赞美国王！")

set_hero("hero_elora")
map["永恒冻土"] = str()
map["寒冰风暴"] = str()

set_hero("hero_ingvar")
map["旋风斩"] = str()
map["先祖召唤"] = str()
map["巨熊形态"] = str()

set_hero("hero_hacksaw")
map["摧甲钢锯"] = str()
map["弹射锯片"] = str()
map["伐伐伐木"] = str()

set_hero("hero_oni")
map["灭魂斩"] = str()
map["千本刃"] = str()
map["复仇怒火"] = str()

set_hero("hero_thor")
map["雷神之锤"] = str()
map["雷霆一击"] = str()
map["雷电中继"] = str()

set_hero("hero_10yr")
map["钢铁时间"] = str()
map["火焰冲刺"] = str()

set_hero("hero_alric")
map["血色连斩"] = str()
map["沙漠勇士"] = str()
map["反伤刺甲"] = str()

set_hero("hero_mirage")
map["移形换影"] = str()
map["影舞"] = str()
map["背刺"] = str()

set_hero("hero_pirate")
map["火药子母"] = str()
map["克拉肯之触"] = str()
map["寻宝"] = str()

set_hero("hero_wizard")
map["魔法飞弹"] = str()
map["连锁反应"] = str()
map["分解"] = str()
map["法术洪流"] = str()

set_hero("hero_beastmaster")
map["野猪朋友"] = str()
map["猎鹰朋友"] = str()
map["犀牛朋友"] = str()
map["愤怒鞭笞"] = str()
map["狂野体质"] = str()

set_hero("hero_vodoo_witch")
map["冷笑骷髅"] = str()
map["亡骨献祭"] = str()
map["骨骸舞蹈"] = str()
map["恐惧光环"] = str()
map["巫毒魔法"] = str()

set_hero("hero_alien")
map["能量飞镖"] = str()
map["净化协议"] = str()
map["母舰劫持"] = str()
map["最终手段"] = str()

set_hero("hero_monk")
map["虎型拳"] = str()
map["蛇型拳"] = str()
map["豹形拳"] = str()
map["龙形拳"] = str()
map["鹤形拳"] = str()

set_hero("hero_monkey_god")
map["狼牙风暴"] = str()
map["旋风棍法"] = str()
map["猴掌"] = str()
map["神怒"] = str()
map["神性"] = str()

set_hero("hero_giant")
map["巨石投掷"] = str()
map["岩晶肘击"] = str()
map["大地震颤"] = str()
map["堡垒之势"] = str()

set_hero("hero_dragon")
map["龙息"] = str()
map["猎宴"] = str()
map["浓烟"] = str()
map["火焰弹幕"] = str()

set_hero("hero_priest")
map["圣光术"]=str()
map["神圣祝颂"]=str()
map["光翼庇护"]=str()

set_hero("hero_dwarf")
map["重锤"]=str()
map["大地之力"]=str()

set_hero("hero_minotaur")
map["蛮牛冲撞"]=str()
map["英勇打击"]=str()
map["代达罗斯的迷宫"]=str()
map["野牛怒吼"]=str()
map["巨斧风暴"]=str()

set_hero("hero_crab")
map["战争强硬"]=str()
map["折叠蟹钳"]=str()
map["水炮"]=str()
map["裂地攻势"]=str()

set_hero("hero_van_helsing")
map["纯银子弹"]=str()
map["致命连射"]=str()
map["遗迹之力"]=str()
map["圣水炸弹"]=str()
map["光明信标"]=str()

set_hero("hero_dracolich")
map["脊雨"]=str()
map["疾病新星"]=str()
map["死亡之触"]=str()
map["亡灵眷属"]=str()

return H
