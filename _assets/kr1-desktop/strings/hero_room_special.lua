require("constants")
local E = require("entity_db")
local damage_type_map = {
    [DAMAGE_TRUE] = "真实伤害",
    [DAMAGE_PHYSICAL] = "物理伤害",
    [DAMAGE_MAGICAL] = "法术伤害",
    [DAMAGE_EXPLOSION] = "爆炸伤害",
    [DAMAGE_RUDE] = "残暴伤害",
    [DAMAGE_STAB] = "穿刺伤害",
    [DAMAGE_MAGICAL_EXPLOSION] = "法术爆炸伤害",
    [DAMAGE_ELECTRICAL] = "雷电伤害",
    [DAMAGE_MIXED] = "物法混合伤害",
    [DAMAGE_SHOT] = "枪击伤害"
}
local bit = require("bit")
local band = bit.band
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
local d = {{}, {}, {}} -- 伤害列表
local e -- 其它实体
local map
-- 写生命信息时，无甲默认不写。
local health = {{}, {}, {}} -- health 列表
local H = {}
H.default = {
    ["加工中"] = "加工中"
}

local function ss(key)
    return s[key][max_lvl]
end

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

local function set_damage_value(value, i)
    if not i then
        i = 1
    end
    d[i].damage_max = value
    d[i].damage_min = value
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

local function damage_type_str(type)
    if damage_type_map[type] then
        return damage_type_map[type]
    end
    for t, str in pairs(damage_type_map) do
        if band(type, t) ~= 0 then
            return str
        end
    end
end

local function damage_str(i)
    if not i then
        i = 1
    end
    if d[i].damage_min == d[i].damage_max then
        return str(d[i].damage_min, "点", damage_type_str(d[i].damage_type))
    end
    return str(d[i].damage_min, "-", d[i].damage_max, "点", damage_type_str(d[i].damage_type))
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
local function health_str(i)
    if not i then
        i = 1
    end
    local h_str = hp_str(i)
    if health[i].armor and health[i].armor > 0 then
        h_str = str(h_str, "，", armor_str(i))
    end
    if health[i].magic_armor and health[i].magic_armor > 0 then
        h_str = str(h_str, "，", magic_armor_str(i))
    end
    return h_str
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
    health[1].hp_max, "点生命值，每次攻击造成", damage_str(), "。")

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
set_skill(h.hero.skills.chill)
factor = 1 - s.slow_factor[max_lvl]
count = s.count[max_lvl]
e = E:get_template("aura_chill_elora")
radius = e.aura.radius
cooldown = h.timed_attacks.list[2].cooldown
duration = e.aura.duration
map["永恒冻土"] = str(cooldown_str(), "伊洛拉制造", count, "片冻土覆盖地面，持续", duration,
    "秒，每一片冻土使", radius, "范围内敌人受到", factor * 100, "%减速效果。")
set_skill(h.hero.skills.ice_storm)
count = s.count[max_lvl]
set_bullet("elora_ice_spike")
get_damage(b.bullet)
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
radius = b.bullet.damage_radius
cooldown = h.timed_attacks.list[1].cooldown
map["寒冰风暴"] = str(cooldown_str(), "伊洛拉召唤", count, "枚冰锥打击敌人，每一枚冰锥对",
    radius, "范围内敌人造成", damage_str(), "。")
e = E:get_template("mod_elora_bolt_slow")
duration = e.modifier.duration
factor = 1 - e.slow.factor
chance = h.ranged.attacks[1].chance
e = E:get_template("mod_elora_bolt_freeze")
local duration_2 = e.modifier.duration
map["冰霜气息"] = str("伊洛拉的法球可对敌人造成", factor * 100, "%的减速效果，持续", duration,
    "秒。法球有", rate_str(chance), "冰冻敌人，持续", duration_2, "秒。")

set_hero("hero_ingvar")
chance = h.melee.attacks[2].chance
get_damage(h.melee.attacks[2])
radius = h.melee.attacks[2].damage_radius
factor = h.melee.attacks[2].damage_factor
map["旋风斩"] = str("英格瓦每次攻击有", rate_str(chance), "的概率发动旋风斩，对周围", radius,
    "范围内敌人造成普攻", factor * 100, "%的", damage_type_map[d[1].damage_type],
    "。该技能获取经验数与造成总伤相关。")
set_skill(h.hero.skills.ancestors_call)
count = s.count[max_lvl]
health[1].hp_max = s.hp_max[max_lvl]
e = E:get_template("soldier_ingvar_ancestor")
get_damage(e.melee.attacks[1])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
duration = e.reinforcement.duration
map["先祖召唤"] = str(cooldown_str(), "英格瓦召唤", count, "名可调集的先祖加入战斗。先祖拥有",
    hp_str(1), "，每次攻击造成", damage_str(), "，驻场", duration,
    "秒，且不会被转化为狼人或骷髅。若该技能已冷却好，且英格瓦仍处于巨熊形态，英格瓦将自行退出巨熊形态并释放本技能，并返还对应冷却时间。")
set_skill(h.hero.skills.bear)
get_damage(h.melee.attacks[3])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
factor = h.timed_attacks.list[2].transform_health_factor
e = E:get_template("aura_ingvar_bear_regenerate")
cycle_time = e.regen.cooldown
local heal = e.regen.health
map["巨熊形态"] = str(cooldown_str(), "若英格瓦生命值低于", factor * 100,
    "%，英格瓦将变身巨熊，持续", duration,
    "秒。变身后，英格瓦免疫基础伤害类型，攻击替换为三连击，每次攻击造成", damage_str(),
    "。变身期间，英格瓦还会获得每", cycle_time, "秒恢复", heal,
    "点生命值的再生效果。该技能在巨熊状态下不进入冷却。")

set_hero("hero_hacksaw")
map["摧甲钢锯"] = str(
    "钢锯每次攻击敌人，都能削减敌人5点护甲，并加快弹射锯片等同于敌人护甲一半的冷却。")
set_skill(h.hero.skills.sawblade)
count = s.bounces[max_lvl]
set_bullet("hacksaw_sawblade")
get_damage(b.bullet)
range = b.bounce_range
cooldown = h.ranged.attacks[1].cooldown
map["弹射锯片"] = str(cooldown_str(), "钢锯发射一枚高速飞行的锯片，造成", damage_str(),
    "，并在击中目标后弹射至最多", count, "个附近敌人，弹射范围为", range, "。")
set_skill(h.hero.skills.timber)
get_cooldown()
map["伐伐伐木"] = str(cooldown_str(),
    "钢锯祭出巨型电钻，强行秒杀面前的敌人，并获得双倍的金币。")

set_hero("hero_oni")
set_skill(h.hero.skills.death_strike)
get_damage(h.melee.attacks[3])
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
chance = s.chance[max_lvl]
cooldown = h.melee.attacks[3].cooldown
map["灭魂斩"] = str(cooldown_str(), "鬼侍聚力怒击，对敌人造成无法闪避的", damage_str(), "并有",
    rate_str(chance), "斩杀敌人。")
set_skill(h.hero.skills.torment)
get_damage(h.timed_attacks.list[1])
d[1].damage_min = s.min_damage[max_lvl]
d[1].damage_max = s.max_damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
min_count = h.timed_attacks.list[1].min_count
radius = h.timed_attacks.list[1].damage_radius
map["千本刃"] = str(cooldown_str(), "若身边有不少于", min_count,
    "名敌人，鬼侍插刀入地，生出千刃莲台，对", radius, "范围内敌人造成无法闪避的",
    damage_str(), "。若目标为恶魔，则额外造成60%伤害。")
set_skill(h.hero.skills.rage)
damage_buff = s.rage_max[max_lvl]
factor = s.unyield_max[max_lvl]
map["复仇怒火"] = str(
    "鬼侍的复仇之火永恒燃烧，无视恶魔的爆炸，并在受伤时提升伤害与免伤，最多提高",
    damage_buff, "点伤害与", factor * 100, "%伤害减免。")

set_hero("hero_thor")
set_skill(h.hero.skills.thunderclap)
duration = s.stun_duration[max_lvl]
radius = s.max_range[max_lvl]
d[1].damage_min = s.damage_max[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[2].damage_min = s.secondary_damage_max[max_lvl]
d[2].damage_max = s.secondary_damage_max[max_lvl]
set_bullet("mod_hero_thor_thunderclap")
d[1].damage_type = b.thunderclap.damage_type
d[2].damage_type = b.thunderclap.secondary_damage_type
local duration_min = b.thunderclap.stun_duration_min
cooldown = h.ranged.attacks[1].cooldown
map["雷神之锤"] = str(cooldown_str(), "索尔掷出雷神之锤，对目标造成", damage_str(1), "，并对",
    radius, "范围内敌人造成", damage_str(2), "与", duration_min, "-", duration, "秒眩晕效果。")
set_skill(h.hero.skills.chainlightning)
factor = 1 - h.hero.level_stats.melee_cooldown[10] / h.hero.level_stats.melee_cooldown[1]
chance = s.chance[max_lvl]
count = s.count[max_lvl]
set_bullet("mod_ray_hero_thor")
get_damage(b.dps)
cycle_time = b.dps.damage_every
duration = b.modifier.duration

set_bullet("mod_hero_thor_chainlightning")
d[2].damage_type = b.chainlightning.damage_type
d[2].damage_min = b.chainlightning.damage
d[2].damage_max = b.chainlightning.damage

map["雷霆一击"] = str("索尔每次攻击，有", rate_str(chance), "触发", count,
    "条电流分配给随机敌人，造成", damage_str(2), "并施加可叠加的电击效果，每", cycle_time,
    "秒造成", damage_str(), "，持续", duration,
    "秒。触发雷霆一击时，雷神之锤的冷却加快1秒。雷神的普攻攻速提升", factor * 100, "%。")
heal = h.hero.level_stats.lightning_heal[10]
map["雷电中继"] = str(
    "索尔的身躯可以充当电流的中继站，使电流传导上限刷新至5倍，并使电流的传导范围翻倍。每当雷电中继触发，索尔都会恢复",
    heal, "点生命值。")

set_hero("hero_10yr")
set_skill(h.hero.skills.buffed)
count = s.bomb_steps[max_lvl]
d[1].damage_min = s.bomb_damage_min[max_lvl]
d[1].damage_max = s.bomb_damage_max[max_lvl]
d[2].damage_min = s.bomb_step_damage_min[max_lvl]
d[2].damage_max = s.bomb_step_damage_max[max_lvl]
d[3].damage_min = s.spin_damage_min[max_lvl]
d[3].damage_max = s.spin_damage_max[max_lvl]
duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
local cooldown_2 = h.timed_attacks.list[3].cooldown
local cooldown_3 = h.melee.attacks[3].cooldown
local loop = h.melee.attacks[3].loops
d[3].damage_type = h.melee.attacks[3].damage_type
radius = h.melee.attacks[3].damage_radius
local count_2 = h.timed_attacks.list[2].min_count
local speed = h.motion.max_speed_buffed
set_bullet("aura_10yr_bomb")
local radius_2 = b.aura.damage_radius
local radius_3 = h.timed_attacks.list[3].damage_radius
d[1].damage_type = h.timed_attacks.list[3].damage_type
d[2].damage_type = b.aura.damage_type
chance = b.aura.stun_chance
e = E:get_template("mod_10yr_stun")
duration_2 = e.modifier.duration
map["钢铁时间"] = str("每隔", cooldown, "秒，若周围敌人数量不少于", count_2,
    "，天十进入钢铁状态，移速提升至", speed, "。并免疫基础伤害类型，持续", duration,
    "秒。在钢铁状态下，天十每隔", cooldown_3, "秒高速旋转，对", radius, "范围内敌人进行",
    loop, "连击，每次攻击造成", damage_str(3),
    "。在调集距离较远时，天十将主动退出钢铁状态，返还对应冷却，并传送至调集位置。该技能在钢铁状态下不进入冷却。")
map["巨叟撼地"] = str("在钢铁状态下，天十每隔", cooldown_2, "秒高高跃起，对", radius_3,
    "范围内敌人造成", damage_str(1), "，同时震碎地面，激起", count, "片裂片，每片裂片对",
    radius_2, "范围内敌人造成", damage_str(2), "，并有", rate_str(chance), "使其眩晕", duration_2,
    "秒。")
set_skill(h.hero.skills.rain)
set_bullet("fireball_10yr")
get_damage(b.bullet)
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
loop = s.loops[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
radius = b.bullet.damage_radius
set_bullet("power_scorched_water")
radius_2 = b.aura.radius
duration = b.aura.duration
cycle_time = b.aura.cycle_time
get_damage(b.aura, 2)
map["火焰冲刺"] = str(cooldown_str(), "天十感召天地，召唤", loop, "枚火球，每枚火球对", radius,
    "范围内敌人造成", damage_str(1), "。火球落地后产生焦土，每隔", cycle_time, "秒对", radius_2,
    "范围内敌人造成", damage_str(2), "，持续", duration, "秒。")

set_hero("hero_alric")
set_skill(h.hero.skills.flurry)
loop = s.loops[max_lvl]
get_cooldown()
get_damage(h.melee.attacks[3])
map["血色连斩"] = str(cooldown_str(), "沙王对面前敌人发动", loop,
    "连斩，每次斩击造成普攻等额的", damage_type_str(d[1].damage_type),
    "。该技能获取经验量与总伤相关。")
set_skill(h.hero.skills.sandwarriors)
count = s.count[max_lvl]
duration = s.lifespan[max_lvl]
speed = h.transfer.extra_speed
e = E:get_template("soldier_sand_warrior")
get_health(e)
get_damage(e.melee.attacks[1])
health[1].hp_max = e.health.hp_max + max_lvl * e.health.hp_inc
set_bullet("decal_alric_soul_ball")
factor = b.hp_factor
cooldown = h.timed_attacks.list[1].cooldown
map["沙漠勇士"] = str(cooldown_str(), "沙王唤醒", count, "名沙漠勇士，一同作战。沙漠勇士拥有",
    health[1].hp_max, "点生命值，每次攻击造成", damage_str(), "，驻场", duration,
    "秒，且无惧剧毒，不会狼人化、尸骸化。")
map["沙漠之心"] = str(
    "阿尔里奇的心与沙漠和族人们紧密连结。远距离调遣时，阿尔里奇会化身沙卷风，提升自身",
    speed,
    "点移速。在沙漠勇士的躯体消散时，他们的灵魂会飘向阿尔里奇，使阿尔里奇恢复沙漠勇士最大生命值",
    factor * 100, "%的生命，并减少血色连斩10%的剩余冷却时间。")
set_skill(h.hero.skills.spikedarmor)
local spiked_armor = 0
for _, value in pairs(s.values) do
    spiked_armor = spiked_armor + value
end
map["反伤刺甲"] = str("沙王额外获得", spiked_armor * 100, "点反甲。")
set_hero("hero_mirage")
set_skill(h.hero.skills.shadowdodge)
chance = s.dodge_chance[max_lvl]
local reward_shadowdance = s.reward_shadowdance[max_lvl]
local reward_lethalstrike = s.reward_lethalstrike[max_lvl]
duration = s.lifespan[max_lvl]
e = E:get_template("soldier_mirage_illusion")
get_damage(e.melee.attacks[1])
radius = e.melee.attacks[1].damage_radius
map["移形换影"] = str("幻影每次遭遇近战攻击时，有", rate_str(chance),
    "恢复10%最大生命值，进入无敌状态并闪离，在原地留下一个存在", duration,
    "秒的影子。影子消失时，对", radius, "范围内敌人造成", damage_str(),
    "。若幻影成功闪避近战攻击，将立刻缩减影舞", reward_shadowdance * 100, "%冷却与背刺",
    reward_lethalstrike * 100, "%冷却。面对范围攻击或远程攻击时，移形换影触发概率×60%。")
set_skill(h.hero.skills.shadowdance)
count = s.copies[max_lvl]
set_bullet("mirage_shadow")
get_damage(b.bullet)
d[1].damage_min = b.bullet.damage_min + b.bullet.damage_inc * max_lvl
d[1].damage_max = b.bullet.damage_max + b.bullet.damage_inc * max_lvl
cooldown = h.timed_attacks.list[1].cooldown
map["影舞"] = str(cooldown_str(), "幻影进入无敌状态，幻化", count,
    "个分身，每个分身对敌人造成", damage_str(), "。")
set_skill(h.hero.skills.lethalstrike)
chance = s.instakill_chance[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
get_damage(h.timed_attacks.list[2])
d[1].damage_min = d[1].damage_min * max_lvl
d[1].damage_max = d[1].damage_max * max_lvl
map["背刺"] = str(cooldown_str(), "幻影进入无敌状态，潜行到敌人背后，发动致命一击，造成",
    damage_str(), "，并有", rate_str(chance),
    "概率斩杀敌人。对于BOSS单位，斩杀效果替换为双倍伤害。")

set_hero("hero_pirate")
set_skill(h.hero.skills.scattershot)
count = s.fragments[max_lvl]
get_damage(E:get_template("barrel_fragment").bullet)
d[1].damage_max = s.fragment_damage[max_lvl]
d[1].damage_min = s.fragment_damage[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map["火药子母"] = str(cooldown_str(), "黑棘船长投出一桶炸药，在空中爆炸产生", count,
    "枚破片，每枚破片造成", damage_str(), "。")
set_skill(h.hero.skills.kraken)
factor = 1 - s.slow_factor[max_lvl]
count = s.max_enemies[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_dps_kraken")
get_damage(e.dps)
cycle_time = e.dps.damage_every
duration = e.modifier.duration
map["克拉肯之触"] = str(cooldown_str(), "黑棘船长召唤克拉肯的触手攻击敌人，持续", duration,
    "秒。在持续区间，触手可困住最多", count, "名敌人，并使范围内敌人受到", factor * 100,
    "%的减速效果，且每", cycle_time, "秒受到", damage_str(), "。")
set_skill(h.hero.skills.looting)
factor = s.percent[max_lvl]
map["寻宝"] = str("黑棘船长高超的职业素养让他能在摸尸体的时候找到额外", factor * 100,
    "%的金币。")

set_hero("hero_wizard")
set_skill(h.hero.skills.magicmissile)
count = s.count[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
set_bullet("missile_wizard")
get_damage(b.bullet)
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map["魔法飞弹"] = str(cooldown_str(), "纽维斯发射", count,
    "枚魔法飞弹，全图范围内追踪敌人，每枚飞弹造成", damage_str(), "。")
set_skill(h.hero.skills.chainspell)
count = s.bounces[max_lvl]
cooldown = h.ranged.attacks[2].cooldown
map["连锁反应"] = str(cooldown_str(), "纽维斯的普攻额外进行", count, "次弹射。")
set_skill(h.hero.skills.disintegrate)
count = s.count[max_lvl]
local total_damage = s.total_damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map["分解"] = str(cooldown_str(), "纽维斯用知识的力量分解最多", count, "名血量总和不超过",
    total_damage, "的敌人。")
set_skill(h.hero.skills.arcanetorrent)
factor = s.factor[max_lvl]
map["法术洪流"] = str(
    "年迈的法师热衷于在后辈前展示力量。场上每多一座法师塔，纽维斯的伤害就提升",
    factor * 100, "%。该伤害提升对魔法飞弹、分解同样生效。")
set_hero("hero_beastmaster")
set_skill(h.hero.skills.boarmaster)
count = s.boars[max_lvl]
e = E:get_template("beastmaster_boar")
get_health(e)
health[1].hp_max = s.boar_hp_max[max_lvl]
get_damage(e.melee.attacks[1])
e = E:get_template("beastmaster_wolf")
get_health(e, 2)
health[2].hp_max = s.wolf_hp_max[max_lvl]
get_damage(e.melee.attacks[1], 2)
chance = e.dodge.chance
cooldown = h.timed_attacks.list[2].cooldown
map["野猪朋友"] = str(cooldown_str(), "兽王随机召唤", count,
    "只野猪、野狼，跟随兽王战斗。野猪拥有", health_str(), "，每次攻击造成", damage_str(),
    "；野狼拥有", health_str(2), "，每次攻击造成", damage_str(2), "，且拥有", rate_str(chance),
    "闪避攻击。")
set_skill(h.hero.skills.falconer)
count = s.count[max_lvl]
e = E:get_template("beastmaster_falcon")
cooldown = e.custom_attack.cooldown
get_damage(e.custom_attack)
e = E:get_template("mod_beastmaster_falcon")
duration = e.modifier.duration
factor = 1 - e.slow.factor
map["猎鹰朋友"] = str("兽王身边伴有", count, "只猎鹰。猎鹰每隔", cooldown,
    "秒发动一次攻击，造成", damage_str(), "，并使目标受到", factor * 100, "%的减速效果，持续",
    duration, "秒。")
set_skill(h.hero.skills.stampede)
count = s.rhinos[max_lvl]
duration = s.duration[max_lvl]
chance = s.stun_chance[max_lvl]
duration_2 = s.stun_duration[max_lvl]
e = E:get_template("beastmaster_rhino")
get_damage(e.attack)
d[1].damage_max = s.damage[max_lvl]
d[1].damage_min = s.damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map["犀牛朋友"] = str(cooldown_str(), "兽王召唤", count, "只犀牛，犀牛冲锋对路径上的敌人造成",
    damage_str(), "，并有", rate_str(chance), "使其眩晕", duration_2, "秒。犀牛驻场", duration, "秒。")
set_skill(h.hero.skills.deeplashes)
cooldown = s.cooldown[max_lvl]
d[1].damage_max = s.damage[max_lvl]
d[1].damage_min = s.damage[max_lvl]
cooldown = s.cooldown[max_lvl]
e = E:get_template("mod_beastmaster_lash")
get_damage(e.dps, 2)
d[2].damage_max = s.blood_damage[max_lvl]
d[2].damage_min = s.blood_damage[max_lvl]
duration = e.modifier.duration
map["愤怒鞭笞"] = str(cooldown_str(), "兽王挥舞长鞭，对敌人造成", damage_str(),
    "，并使其流血，在", duration, "秒内受到共", damage_str(2), "。")
e = E:get_template("aura_beastmaster_regeneration")
cycle_time = e.hps.heal_every
local amount = e.hps.heal_min
map["狂野体质"] = str("兽王免疫剧毒，且每隔", cycle_time, "秒恢复", amount, "点生命值。")

set_hero("hero_voodoo_witch")
set_skill(h.hero.skills.laughingskulls)
set_bullet("bolt_voodoo_witch_skull")
get_damage(b.bullet)
for _, value in pairs(s.extra_damage) do
    d[1].damage_min = d[1].damage_min + value
    d[1].damage_max = d[1].damage_max + value
end
e = E:get_template("voodoo_witch_skull")
cooldown = e.ranged.attacks[1].cooldown
count = e.max_shots
map["冷笑骷髅"] = str("冷笑骷髅每隔", cooldown, "秒攻击一名敌人，造成", damage_str(),
    "，最多攻击", count, "次。")
set_skill(h.hero.skills.deathskull)
get_damage(e.sacrifice)
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map["亡骨献祭"] = str("冷笑骷髅完成使命时，砸向敌人，造成", damage_str(), "。")
set_skill(h.hero.skills.bonedance)
count = s.skull_count[max_lvl]
map["骨骸舞蹈"] = str(
    "每当敌军或友军在女巫身边死亡时，女巫将提取亡灵之力，召唤冷笑骷髅，跟随女巫战斗。冷笑骷髅最多存在",
    count, "个。")
set_skill(h.hero.skills.deathaura)
factor = s.slow_factor[max_lvl]
e = E:get_template("voodoo_witch_death_aura")
cycle_time = e.aura.cycle_time
radius = e.aura.radius
get_damage(e.aura)
d[1].damage_min = e.aura.damage
d[1].damage_max = e.aura.damage
map["恐惧光环"] = str("女巫散发出恐惧光环，每隔", cycle_time, "秒对", radius, "范围内敌人造成",
    damage_str(), "，并使其受到", factor * 100, "%的减速效果。")
set_skill(h.hero.skills.voodoomagic)
get_damage(h.timed_attacks.list[1])
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_voodoo_witch_magic_slow")
factor = 1 - e.slow.factor
duration = e.modifier.duration
count = s.count[max_lvl]
map["巫毒魔法"] = str(cooldown_str(), "女巫施展巫毒魔法，使最多", count, "名敌人减速",
    factor * 100, "%，持续", duration, "秒，并对其造成", damage_str(), "。")

set_hero("hero_alien")
set_skill(h.hero.skills.energyglaive)
chance = s.bounce_chance[max_lvl]
set_bullet("alien_glaive")
get_damage(b.bullet)
d[1].damage_max = s.damage[max_lvl]
d[1].damage_min = s.damage[max_lvl]
cooldown = h.ranged.attacks[1].cooldown
e = E:get_template("mod_slow_alien_glaive")
factor = 1 - e.slow.factor
duration = e.modifier.duration
map["能量飞镖"] = str(cooldown_str(), "沙塔投掷能量飞镖，造成", damage_str(), "与持续", duration,
    "秒的", factor * 100, "%减速效果。飞镖每次命中敌人都有", rate_str(chance),
    "弹射至附近敌人。")
set_skill(h.hero.skills.purificationprotocol)
duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
e = E:get_template("alien_purification_drone")
get_damage(e.dps)
cycle_time = e.dps.damage_every
map["净化协议"] = str(cooldown_str(), "沙塔召唤驻场", duration,
    "秒的净化无人机，自动锁定敌人，造成持续眩晕，并每", cycle_time, "秒对敌人造成",
    damage_str(), "。")
set_skill(h.hero.skills.abduction)
count = s.total_targets[max_lvl]
amount = s.total_hp[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map["母舰劫持"] = str(cooldown_str(), "沙塔呼叫母舰，随机劫持最多", count, "名血量总和不超过",
    amount, "的敌人，或一名血量不限的敌人，直接将他们移出战场。")
set_skill(h.hero.skills.vibroblades)
d[1].damage_type = s.damage_type
d[1].damage_min = s.extra_damage[max_lvl]
d[1].damage_max = s.extra_damage[max_lvl]
map["鸣颤战刃"] = str("沙塔每次普攻额外附带", damage_str(), "。")
set_skill(h.hero.skills.finalcountdown)
get_damage(h.selfdestruct)
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
e = E:get_template("mod_alien_selfdestruct")
duration = e.modifier.duration
map["最终手段"] = str(
    "沙塔复活时间为6秒，并在升级时刷新所有技能冷却。当生命值耗尽时，沙塔自爆，对周围敌人造成",
    damage_str(), "，并使其受到", duration, "秒的眩晕效果。")

set_hero("hero_monk")
set_skill(h.hero.skills.tigerstyle)
get_damage(h.melee.attacks[5])
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.melee.attacks[5].cooldown
map["虎型拳"] = str(cooldown_str(), "库绍施展虎型拳，造成", damage_str(),
    "，并恢复自身30点生命值。")
set_skill(h.hero.skills.snakestyle)
get_damage(h.melee.attacks[4])
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.melee.attacks[4].cooldown
factor = s.damage_reduction_factor[max_lvl]
map["蛇型拳"] = str(cooldown_str(), "库绍对非boss敌人施展蛇形拳，造成", damage_str(),
    "并使敌人的伤害降低", factor * 100, "%", "。")
set_skill(h.hero.skills.leopardstyle)
count = s.loops[max_lvl]
get_damage(h.timed_attacks.list[2])
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map["豹形拳"] = str(cooldown_str(), "库绍对非boss敌人施展豹形拳，连续攻击", count,
    "次并短暂阻拦敌人，每次攻击造成", damage_str(), "。")
set_skill(h.hero.skills.dragonstyle)
get_damage(h.timed_attacks.list[1])
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map["龙形拳"] = str(cooldown_str(), "库绍施展龙形拳，对周围敌人造成", damage_str(), "。")
set_skill(h.hero.skills.cranestyle)
chance = s.chance[max_lvl]
cooldown = s.cooldown[max_lvl]
get_damage(h.dodge)
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map["鹤形拳"] = str("库绍有", rate_str(chance), "闪避敌人的攻击并以鹤形拳反击，造成",
    damage_str(), "。该技能有", cooldown, "秒冷却时间。")
map["诸武精通"] = str(
    "库绍的普攻可触发三种随机效果：降低敌人10%护甲；减少蛇形拳和虎型拳1秒冷却；减少豹形拳和龙形拳一秒冷却。持续战斗时，库绍的普攻、虎型拳、蛇形拳的冷却逐渐减少，最多减少40%。")
set_hero("hero_monkey_god")
set_skill(h.hero.skills.spinningpole)
count = s.loops[max_lvl]
get_damage(h.melee.attacks[3])
radius = h.melee.attacks[3].damage_radius
cooldown = h.melee.attacks[3].cooldown
set_damage_value(s.damage[max_lvl])
map["狼牙风暴"] = str(cooldown_str(), "赛塔姆挥舞狼牙棒，对", radius, "范围内敌人造成", count,
    "段伤害，每段造成", damage_str(), "。")
set_skill(h.hero.skills.tetsubostorm)
get_damage(h.melee.attacks[4])
set_damage_value(s.damage[max_lvl])
cooldown = h.melee.attacks[4].cooldown
count = h.melee.attacks[4].loops * #h.melee.attacks[4].hit_times
map["旋风棍法"] = str(cooldown_str(), "赛塔姆挥棒如旋风，对敌人进行", count,
    "段攻击，每段造成", damage_str(), "。")
set_skill(h.hero.skills.monkeypalm)
get_damage(h.melee.attacks[5])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
duration = s.stun_duration[max_lvl]
duration_2 = s.silence_duration[max_lvl]
cooldown = h.melee.attacks[5].cooldown
map["猴掌"] = str(cooldown_str(), "赛塔姆凝聚精神拍出一掌，对非BOSS敌人造成", damage_str(),
    "，并使敌人眩晕", duration, "秒，沉默", duration_2, "秒，且使神怒的冷却减少4秒。")
set_skill(h.hero.skills.angrygod)
factor = s.received_damage_factor[max_lvl]
duration = h.timed_attacks.list[1].loops * 17 / 30
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_monkey_god_fire")
get_damage(e.dps)
set_damage_value(e.dps.damage_min + max_lvl * e.dps.damage_inc)
cycle_time = e.dps.damage_every
map["神怒"] = str(cooldown_str(),
    "赛塔姆进入无敌状态，刷新狼牙风暴、旋风棍法和猴掌的冷却，并释放心中的怒火，持续",
    duration, "秒，期间所有敌人受到的伤害乘以", factor, "，并每隔", cycle_time, "秒受到",
    damage_str(), "。该技能被手动打断时，恢复等比例冷却时间。")
speed = h.cloudwalk.extra_speed
e = E:get_template("aura_monkey_god_divinenature")
cycle_time = e.hps.heal_every
amount = e.hps.heal_min
map["神性"] = str("远距离移动时，赛塔姆乘坐祥云，移速提升", speed, "点。每隔", cycle_time,
    "秒，赛塔姆恢复", amount, "点生命值。赛塔姆免疫剧毒。")

set_hero("hero_giant")
set_skill(h.hero.skills.boulderthrow)
cooldown = h.ranged.attacks[1].cooldown
set_bullet("giant_boulder")
radius = b.bullet.damage_radius
get_damage(b.bullet)
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
map["巨石投掷"] = str(cooldown_str(), "格劳尔投掷巨石，对", radius, "范围内敌人造成", damage_str(),
    "。")
set_skill(h.hero.skills.massivedamage)
factor = s.health_factor
e = E:get_template("mod_giant_massivedamage")
get_damage(e)
set_damage_value(s.extra_damage[max_lvl])
chance = s.chance[max_lvl]
cooldown = h.melee.attacks[2].cooldown
map["岩晶肘击"] = str(cooldown_str(), "格劳尔奋力肘击敌人，额外造成", damage_str(), "。肘击有",
    rate_str(chance), "概率暴击：若结算伤害后，敌人生命值少于格劳尔", 100 / factor,
    "%最大生命值，且不为BOSS，则秒杀敌人；否则，额外伤害翻倍。")
set_skill(h.hero.skills.stomp)
count = s.loops[max_lvl]
duration = s.stun_duration[max_lvl]
get_damage(h.timed_attacks.list[1])
set_damage_value(s.damage[max_lvl])
cooldown = h.timed_attacks.list[1].cooldown
radius = h.timed_attacks.list[1].damage_radius
chance = h.timed_attacks.list[1].stun_chance
map["大地震颤"] = str(cooldown_str(), "格劳尔持续锤击地面", count, "次，每次对", radius,
    "范围内敌人造成", damage_str(), "，并有", rate_str(chance), "概率使其眩晕", duration, "秒。")
set_skill(h.hero.skills.bastion)
amount = s.damage_per_tick[max_lvl]
local amount_2 = s.max_damage[max_lvl]
e = E:get_template("aura_giant_bastion")
cycle_time = e.tick_time
set_skill(h.hero.skills.hardrock)
local amount_3 = s.damage_block[max_lvl]
map["堡垒之势"] = str("格劳尔免疫毒伤，且拥有嘲讽效果。当原地不动时，格劳尔每",
    cycle_time, "秒提升", amount, "点伤害，最多提升", amount_2, "点。格劳尔受到的所有伤害减少",
    amount_3, "点。")

set_hero("hero_dragon")
set_skill(h.hero.skills.blazingbreath)
e = E:get_template("breath_dragon")
get_damage(e.bullet)
set_damage_value(s.damage[max_lvl])
radius = e.bullet.damage_radius
cooldown = h.ranged.attacks[2].cooldown
map["龙息"] = str(cooldown_str(), "阿什比特向随机敌人持续喷吐火焰，对", radius,
    "范围内敌人总共造成", damage_str(), "。")
set_skill(h.hero.skills.feast)
chance = s.devour_chance[max_lvl]
get_damage(h.timed_attacks.list[1])
set_damage_value(s.damage[max_lvl])
cooldown = h.timed_attacks.list[1].cooldown
map["猎宴"] = str(cooldown_str(), "阿什比特扑击最近的敌人，造成", damage_str(), "，并有",
    rate_str(chance), "概率吞噬敌人。如果敌人免疫秒杀或吞噬，则改为造成2倍伤害。")
set_skill(h.hero.skills.fierymist)
e = E:get_template("aura_fierymist_dragon")
factor = 1 - s.slow_factor[max_lvl]
duration = s.duration[max_lvl]
radius = e.aura.radius
cycle_time = e.aura.cycle_time
get_damage(e.aura)
cooldown = h.ranged.attacks[3].cooldown
map["浓烟"] = str(cooldown_str(), "阿什比特向随机敌人喷吐浓烟，持续", duration, "秒。浓烟每隔",
    cycle_time, "秒对", radius, "范围内敌人造成", damage_str(), "，并使其受到", factor * 100,
    "%的减速效果。")
set_skill(h.hero.skills.wildfirebarrage)
cooldown = h.ranged.attacks[4].cooldown
count = s.explosions[max_lvl]
e = E:get_template("wildfirebarrage_dragon")
get_damage(e.bullet)
radius = e.bullet.damage_radius
map["火焰弹幕"] = str(cooldown_str(), "阿什比特向随机敌人发射火球，落地后爆炸产生", count,
    "次范围", radius, "的爆炸，每次爆炸造成", damage_str(), "。")
set_skill(h.hero.skills.reignoffire)
e = E:get_template("mod_dragon_reign")
duration = e.modifier.duration
cycle_time = e.dps.damage_every
get_damage(e.dps)
set_damage_value(s.dps[max_lvl])
count = e.modifier.max_duplicates
map["烈焰君临"] = str("阿什比特的攻击将会点燃敌人，持续", duration,
    "秒。点燃状态下的敌人每隔", cycle_time, "秒受到", damage_str(), "，最多叠加", count,
    "层。当火焰持续时间结束时，火焰将尝试向周围敌人传播。")

set_hero("hero_priest")
set_skill(h.hero.skills.holylight)
count = s.heal_count[max_lvl]
chance = s.revive_chance[max_lvl]
heal = s.heal_hp[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map["圣光术"] = str(cooldown_str(), "德得尔使用圣光术治疗自己与周围友军，最多恢复", count,
    "名士兵", heal, "点生命值，驱散他们的异常状态，并有", rate_str(chance),
    "复活死去的战友。")
set_skill(h.hero.skills.consecrate)
duration = s.duration[max_lvl]
factor = s.extra_damage[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map["神圣祝颂"] = str(cooldown_str(), "德得尔祝福最近的一座防御塔，使其伤害提升", factor * 100,
    "%，持续", duration, "秒。")
set_skill(h.hero.skills.wingsoflight)
duration = s.duration[max_lvl]
factor = s.armor_rate[max_lvl]
local factor_2 = s.damage_rate[max_lvl]
e = E:get_template("mod_priest_armor")
local factor_3 = 1 - e.cooldown_rate
count = s.count[max_lvl]
map["光翼庇护"] = str("德得尔传送时，用光翼庇护周围最多", count,
    "名友军，使他们物抗与法抗距离免疫的差距减小", factor * 100, "%，并使他们伤害提升",
    factor_2 * 100, "%，攻速提升", factor_3 * 100, "%。")

set_hero("hero_dwarf")
set_skill(h.hero.skills.ring)
get_damage(h.melee.attacks[2])
cooldown = h.melee.attacks[2].cooldown
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
radius = h.melee.attacks[2].damage_radius
map["重锤"] = str(cooldown_str(), "鲁林挥动重锤，对", radius, "范围内敌人造成", damage_str(), "。")
set_skill(h.hero.skills.giant)
factor = s.scale[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
heal_factor = factor * 0.1
e = E:get_template("mod_dwarf_champion_stun")
duration = e.modifier.duration
map["大地之力"] = str(cooldown_str(), "鲁林使用大地之力，身形变为", factor, "倍，恢复",
    heal_factor * 100, "%最大生命值的生命，并挥动重锤，造成范围伤害与", duration,
    "秒眩晕，范围与伤害均为重锤技能的", factor, "倍。")
cooldown = h.timed_attacks.list[2].cooldown
duration = E:get_template("soldier_dwarf_reinforcement").reinforcement.duration
map["矮人亲卫"] = str(cooldown_str(), "鲁林召唤可调集的矮人亲卫协助战斗，驻场", duration,
    "秒。矮人亲卫数值与矮人大厅的士兵相同，技能等级同本技能等级。")

set_hero("hero_minotaur")
set_skill(h.hero.skills.bullrush)
get_damage(h.timed_attacks.list[3])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[2].damage_type = d[1].damage_type
d[2].damage_min = s.run_damage_min[max_lvl]
d[2].damage_max = s.run_damage_max[max_lvl]
duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[3].cooldown
map["蛮牛冲撞"] = str(cooldown_str(),
    "卡兹刷新巨斧风暴的冷却，对首个离自己一定距离的敌人发动冲撞，使路径上所有敌人受到",
    damage_str(2), "，冲撞终点的敌人受到", damage_str(), "。上述所有敌人眩晕", duration, "秒。")
set_skill(h.hero.skills.bloodaxe)
factor = s.damage_factor[max_lvl]
chance = h.melee.attacks[2].chance
map["英勇打击"] = str("卡兹每次攻击有", rate_str(chance),
    "概率发动英勇打击，该攻击无法闪避且能够破除护盾，造成", factor,
    "倍于普攻的真实伤害。")
set_skill(h.hero.skills.daedalusmaze)
cooldown = h.timed_attacks.list[4].cooldown
duration = s.duration[max_lvl]
range = h.timed_attacks.list[4].min_range
map["代达罗斯的迷宫"] = str(cooldown_str(), "卡兹刷新巨斧风暴和野牛怒吼的冷却，并将", range,
    "距离外最近的一名生命值大于卡兹当前生命值2倍的敌人传送至身前，使其眩晕", duration,
    "秒。")
set_skill(h.hero.skills.roaroffury)
cooldown = h.timed_attacks.list[2].cooldown
factor = s.extra_damage[max_lvl]
map["野牛怒吼"] = str(cooldown_str(), "卡兹一声怒吼鼓舞士气，使所有的防御塔伤害提升",
    factor * 100, "%。")
set_skill(h.hero.skills.doomspin)
get_damage(h.timed_attacks.list[1])
cooldown = h.timed_attacks.list[1].cooldown
radius = h.timed_attacks.list[1].damage_radius
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
map["巨斧风暴"] = str(cooldown_str(), "卡兹对", radius, "范围内敌人造成", damage_str(),
    "并恢复造成伤害总量25%的生命值。")

set_hero("hero_crab")
set_skill(h.hero.skills.battlehardened)
chance = s.chance[max_lvl]
duration = h.invuln.duration
map["战争强硬"] = str("每当卡基诺斯受到攻击，有", rate_str(chance),
    "触发战争强硬，使得接下来", duration,
    "秒内受到的攻击改为使卡基诺斯恢复一半伤害量的生命值。该效果持续期间无法重复触发。")
set_skill(h.hero.skills.pincerattack)
cooldown = h.timed_attacks.list[1].cooldown
get_damage(h.timed_attacks.list[1])
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
local x = h.timed_attacks.list[1].damage_size.x
local y = h.timed_attacks.list[1].damage_size.y
map["折叠蟹钳"] = str(cooldown_str(), "卡基诺斯使用折叠蟹钳，对面前", x, "x", y,
    "区域内的敌人造成", damage_str(), "。")
set_skill(h.hero.skills.shouldercannon)
get_damage(E:get_template("crab_water_bomb").bullet)
set_damage_value(s.damage[max_lvl])
factor = s.slow_factor[max_lvl]
duration = s.slow_duration[max_lvl]
radius = E:get_template("aura_slow_water_bomb").aura.radius
for _, inc in pairs(s.radius_inc) do
    radius = radius + inc
end
cooldown = h.ranged.attacks[1].cooldown
map["水炮"] = str(cooldown_str(), "卡基诺斯发射水炮，对", radius, "范围内敌人造成", damage_str(),
    "与持续", duration, "秒的", factor * 100, "%减速效果。")
set_skill(h.hero.skills.burrow)
amount = s.extra_speed[max_lvl]
d[1].damage_type = DAMAGE_EXPLOSION
set_damage_value(s.damage[max_lvl])
amount_2 = h.motion.speed_limit - h.motion.max_speed
amount_3 = h.burrow.init_accel
cooldown = h.burrow.cooldown
radius = h.burrow.radius
local amount_4 = h.burrow.stun_speed - h.motion.max_speed
duration = E:get_template("mod_stun_burrow").modifier.duration
map["裂地攻势"] = str(
    "卡基诺斯可在海洋中自由穿梭。长距离移动时，卡基诺斯遁地，立刻提升", amount_3,
    "点移速，并每秒提高", amount, "点移速，最高提升", amount_2,
    "点。当卡基诺斯出土时，若提升的速度超过", amount_4, "，则在", radius,
    "范围内造成基于加速效果（最多两倍）倍数的", damage_str(), "与", duration,
    "秒眩晕效果。伤害与眩晕效果每", cooldown, "秒仅触发一次。")

set_hero("hero_van_helsing")
set_skill(h.hero.skills.silverbullet)
cooldown = h.timed_attacks.list[2].cooldown
get_damage(E:get_template("van_helsing_silverbullet").bullet)
set_damage_value(s.damage[max_lvl])
map["纯银子弹"] = str(cooldown_str(), "但丁射出一发纯银子弹，造成", damage_str(),
    "。该攻击优先攻击极接近驻守点的敌人，其次是折算物抗后生命值最高的敌人。对于狼人，该折算生命值翻倍，造成的伤害也翻倍。")
set_skill(h.hero.skills.multishoot)
count = s.loops[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
get_damage(E:get_template("van_helsing_shotgun").bullet)
map["致命连射"] = str(cooldown_str(), "但丁使用手枪连射", count, "发，每发造成", damage_str(),
    "。射击目标死亡后，就近转火。")
set_skill(h.hero.skills.relicofpower)
factor = ss("armor_reduce_factor")
cooldown = h.melee.attacks[2].cooldown
map["遗迹之力"] = str(cooldown_str(), "但丁对面前敌人使用遗迹之力，削减他", factor * 100,
    "%的双抗。该技能只会对生命高于500，且护甲/法抗高于0的敌人使用。")
set_skill(h.hero.skills.holygrenade)
duration = ss("silence_duration")
radius = E:get_template("van_helsing_grenade").bullet.damage_radius
cooldown = h.timed_attacks.list[3].cooldown
map["圣水炸弹"] = str(cooldown_str(), "但丁对可沉默单位投掷一枚圣水炸弹，在", radius,
    "范围内造成沉默效果，持续", duration, "秒。")
set_skill(h.hero.skills.beaconoflight)
factor = ss("inflicted_damage_factor")
map["光明信标"] = str("但丁的光明信标鼓舞着友军，使身边友军的伤害乘以", factor,
    "。但丁死亡后，魂灵依旧留在战场。")

set_hero("hero_dracolich")
set_skill(h.hero.skills.spinerain)
count = ss("count")
local a = h.timed_attacks.list[2]
cooldown = a.cooldown
e = E:get_template("dracolich_spine")
radius = e.bullet.damage_radius
get_damage(e.bullet)
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
map["脊雨"] = str(cooldown_str(), "波恩哈特向随机敌人发射", count, "根脊柱，每根对", radius,
    "范围内敌人造成", damage_str(), "。该技能不会主动对空军释放。")
set_skill(h.hero.skills.diseasenova)
a = h.timed_attacks.list[3]
cooldown = a.cooldown
get_damage(a)
radius = a.max_range
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
map["疾病新星"] = str(cooldown_str(), "波恩哈特撞击敌人，在", radius, "范围内造成", damage_str(),
    "，并使敌人感染瘟疫。")
set_skill(h.hero.skills.plaguecarrier)
count = ss("count")
duration = ss("duration")
a = h.timed_attacks.list[1]
cooldown = a.cooldown
e = E:get_template("dracolich_plague_carrier")
get_damage(e.aura)
map["死亡之触"] = str(cooldown_str(), "波恩哈特向前吐出", count,
    "枚瘟疫球，每枚瘟疫球持续前进", duration, "秒，并对路径上的敌人造成", damage_str(),
    "，让他们感染瘟疫。")
set_skill(h.hero.skills.bonegolem)
e = E:get_template("soldier_dracolich_golem")
get_health(e)
get_damage(e.melee.attacks[1])
health[1].hp_max = ss("hp_max")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
duration = ss("duration")
map["亡灵眷属"] = str(cooldown_str(), "波恩哈特召唤亡灵眷属协助战斗，驻场", duration,
    "秒。亡灵眷属拥有", health_str(), "，每次攻击造成", damage_str(), "。")
set_skill(h.hero.skills.unstabledisease)
e = E:get_template("mod_dracolich_disease")
set_damage_value(ss("spread_damage"))
d[1].damage_type = e.dps.damage_type
duration = e.modifier.duration
get_damage(e.dps, 2)
set_damage_value(h.hero.level_stats.disease_damage[#h.hero.level_stats.disease_damage], 2)
cycle_time = e.dps.damage_every
radius = e.spread_radius
map["凋零"] = str("波恩哈特的攻击会使敌人感染瘟疫，持续", duration, "秒，每", cycle_time,
    "秒造成", damage_str(2), "。当感染瘟疫的敌人死亡时，会触发尸爆，对", radius,
    "范围内敌人造成", damage_str(1), "。")

set_hero("hero_vampiress")
set_skill(h.hero.skills.vampirism)
a = h.melee.attacks[2]
get_damage(a)
set_damage_value(ss("damage"))
cooldown = a.cooldown
e = E:get_template("mod_vampiress_blood")
duration = e.modifier.duration
cycle_time = e.dps.damage_every
get_damage(e.dps, 2)
set_damage_value(e.dps.damage_min + max_lvl * e.dps.damage_inc, 2)
map["生命汲取"] = str(cooldown_str(), "卢克蕾齐娅汲取敌人的生命，造成", damage_str(),
    "并恢复等量生命值。被汲取的敌人流血", duration, "秒，每", cycle_time, "秒受到",
    damage_str(2), "。")
set_skill(h.hero.skills.slayer)
a = h.timed_attacks.list[1]
get_damage(a)
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
radius = a.damage_radius
factor = a.extra_damage_factor
cooldown = a.cooldown
map["绛红之舞"] = str(cooldown_str(), "卢克蕾齐娅对周围", radius, "范围内敌人造成", damage_str(),
    "。该伤害对吸血鬼夫人x", factor, "。")
e = E:get_template("mod_vampiress_gain")
count = e.max_gain_count
amount = e.gain.damage
amount_2 = e.gain.hp
amount_3 = e.gain.magic_armor
heal = e.gain.heal
amount_4 = e.gain.cooldown
local amount_5 = e.gain.radius
local amount_6 = e.gain.speed
local amount_7 = e.gain.armor
map["杀戮生长"] = str("卢克蕾齐娅在杀戮中成长，每杀死一名敌人，就恢复", heal,
    "点生命值，并提升：", amount_2, "点最大生命值，", amount, "点普攻伤害，", amount_7 * 100,
    "点物抗，", amount_3 * 100, "点法抗，", amount_6, "点移速，", amount_5,
    "点绛红之舞的伤害范围，并永久减少", amount_4,
    "秒生命汲取和绛红之舞的冷却时间。上述属性提升最多", count, "次。")
map["鲜血后裔"] = str(
    "卢克蕾齐娅免疫毒素，每次普攻恢复3点生命值，且被视为亡灵单位。远距离移动时，卢克蕾齐娅变身蝙蝠飞行，提升自身",
    h.motion.max_speed_bat - h.motion.max_speed, "点移速。")

set_hero("hero_elves_archer")
map["迅闪"] = str()
map["双刃"] = str()
map["箭猪"] = str()
map["箭雨"] = str()

set_hero("hero_regson")
map["刃舞"] = str()
map["死战之志"] = str()
map["异能魔刃"] = str()
map["影袭"] = str()
map["死吻"] = str()

set_hero("hero_lynn")
map["妖咒连斩"] = str()
map["绝望诅咒"] = str()
map["虚弱诅咒"] = str()
map["厄运符印"] = str()
map["命运封印"] = str()

set_hero("hero_wilbur")
map["迷雾"] = str()
map["导弹"] = str()
map["自走炸弹"] = str()
map["无人机蜂群"] = str()

set_hero("hero_veznan")
map["灵魂裂解"] = str()
map["苦痛牢笼"] = str()
map["奥术新星"] = str()
map["恶魔契约"] = str()

set_hero("hero_durax")
map["水晶长矛"] = str()
map["折射效应"] = str()
map["致命晶刃"] = str()
map["水晶分身"] = str()
map["蓝水晶之牙"] = str()

set_hero("hero_elves_denas")
map["弹射盾牌"] = str()
map["英姿"] = str()
map["巨势锤击"] = str()
map["近卫骑士"] = str()
map["零花钱"] = str()
map["大鸡腿"] = str()

set_hero("hero_arivan")
map["闪电箭"] = str()
map["石盾"] = str()
map["火球术"] = str()
map["寒冰箭"] = str()
map["元素之怒"] = str()

set_hero("hero_phoenix")
map["净化"] = str()
map["焚祭"] = str()
map["余烬之地"] = str()
map["火焰之环"] = str()
map["炽焰后裔"] = str()

set_hero("hero_bravebark")
map["自然之怒"] = str()
map["春生树液"] = str()
map["橡树之种"] = str()
map["尖刺树根"] = str()
map["本垒打"] = str()

set_hero("hero_catha")
map["仙境魔尘"] = str()
map["仙子诅咒"] = str()
map["仙女之魂"] = str()
map["仙境传说"] = str()
map["仙子之怒"] = str()

set_hero("hero_lilith")
map["地狱之轮"] = str()
map["收割"] = str()
map["神圣混沌"] = str()
map["噬魂"] = str()
map["复生"] = str()

set_hero("hero_xin")
map["激励怒吼"] = str()
map["英勇打击"] = str()
map["熊猫乱舞"] = str()
map["驭体于灵"] = str()
map["熊猫流氓"] = str()

set_hero("hero_faustus")
map["传送符文"] = str()
map["龙怒"] = str()
map["龙枪"] = str()
map["液烟"] = str()
map["弱能"] = str()

set_hero("hero_rag")
map["爆炸兔兔"] = str()
map["敲敲敲"] = str()
map["侏儒之怒"] = str()
map["布偶变"] = str()
map["超级变变变"] = str()

set_hero("hero_bruce")
map["流血利刃"] = str()
map["王者咆哮"] = str()
map["野蛮撕咬"] = str()
map["雄狮守卫"] = str()

set_hero("hero_bolverk")
map["怒击"] = str()
map["炎吼"] = str()
map["狂战血脉"] = str()

set_hero("hero_hunter")
map["银白风暴"] = str()
map["吸血爪击"] = str()
map["黄昏血妖"] = str()
map["迷雾步伐"] = str()
map["父魂"] = str()

set_hero("hero_space_elf")
map["星界镜像"] = str()
map["虚空裂隙"] = str()
map["黑曜庇护"] = str()
map["空间扭曲"] = str()
map["异域囚笼"] = str()

set_hero("hero_raelyn")
map["指挥号令"] = str()
map["残酷打击"] = str()
map["全力猛攻"] = str()
map["闻风丧胆"] = str()
map["坚不可摧"] = str()

set_hero("hero_venom")
map["贯心追猎"] = str()
map["原始野性"] = str()
map["致命尖刺"] = str()
map["重塑血肉"] = str()
map["死亡蔓延"] = str()

set_hero("hero_dragon_gem")
map["结晶吐息"] = str()
map["棱晶碎片"] = str()
map["红晶石冢"] = str()
map["能量输导"] = str()
map["水晶崩落"] = str()

set_hero("hero_witch")
map["南瓜魔术"] = str()
map["闪光诱饵"] = str()
map["黑夜煞星"] = str()
map["粘稠魔药"] = str()
map["昏昏欲退"] = str()

set_hero("hero_dragon_bone")
map["脊骨骤雨"] = str()
map["瘟神毒雾"] = str()
map["爆发感染"] = str()
map["疫病灾星"] = str()
map["化骨为龙"] = str()

set_hero("hero_lumenir")
map["光辉波动"] = str()
map["光明伙伴"] = str()
map["反伤赐福"] = str()
map["天国裁决"] = str()
map["光耀凯歌"] = str()

set_hero("hero_wukong")
map["八戒师弟"] = str()
map["身外身法"] = str()
map["雨落千钧"] = str()
map["神珍定海"] = str()
map["白龙腾渊"] = str()

return H
