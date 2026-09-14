require("all.constants")

local E = require("entity_db")
local damage_type_map = {
	[DAMAGE_TRUE] = _("HERO_ROOM_DMG_TRUE"),
	[DAMAGE_PHYSICAL] = _("HERO_ROOM_DMG_PHYSICAL"),
	[DAMAGE_MAGICAL] = _("HERO_ROOM_DMG_MAGICAL"),
	[DAMAGE_EXPLOSION] = _("HERO_ROOM_DMG_EXPLOSION"),
	[DAMAGE_RUDE] = _("HERO_ROOM_DMG_RUDE"),
	[DAMAGE_STAB] = _("HERO_ROOM_DMG_STAB"),
	[DAMAGE_MAGICAL_EXPLOSION] = _("HERO_ROOM_DMG_MAGICAL_EXPLOSION"),
	[DAMAGE_ELECTRICAL] = _("HERO_ROOM_DMG_ELECTRICAL"),
	[DAMAGE_MIXED] = _("HERO_ROOM_DMG_MIXED"),
	[DAMAGE_SHOT] = _("HERO_ROOM_DMG_SHOT"),
	[DAMAGE_POISON] = _("HERO_ROOM_DMG_POISON"),
	[DAMAGE_AGAINST_ARMOR] = _("HERO_ROOM_DMG_AGAINST_ARMOR"),
	[DAMAGE_AGAINST_MAGIC_ARMOR] = _("HERO_ROOM_DMG_AGAINST_MAGIC_ARMOR")
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
	return string.format(_("HERO_ROOM_FMT_CHANCE"), str(rate * 100))
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
	[_("HERO_ROOM_PROCESSING")] = _("HERO_ROOM_PROCESSING")
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
		return string.format(_("HERO_ROOM_FMT_DAMAGE"), str(d[i].damage_min), damage_type_str(d[i].damage_type))
	end

	return string.format(_("HERO_ROOM_FMT_DAMAGE_RANGE"), str(d[i].damage_min), str(d[i].damage_max), damage_type_str(d[i].damage_type))
end

local function hp_str(i)
	if not i then
		i = 1
	end

	return string.format(_("HERO_ROOM_FMT_HP"), str(health[i].hp_max))
end

local function armor_str(i)
	if not i then
		i = 1
	end

	return string.format(_("HERO_ROOM_FMT_ARMOR"), str(health[i].armor * 100))
end

local function magic_armor_str(i)
	if not i then
		i = 1
	end

	return string.format(_("HERO_ROOM_FMT_MAGIC_ARMOR"), str(health[i].magic_armor * 100))
end
--- t: table, with component health
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
		h_str = str(h_str, _("HERO_ROOM_FMT_SEP"), armor_str(i))
	end

	if health[i].magic_armor and health[i].magic_armor > 0 then
		h_str = str(h_str, _("HERO_ROOM_FMT_SEP"), magic_armor_str(i))
	end

	return h_str
end

local function cooldown_str()
	return string.format(_("HERO_ROOM_FMT_COOLDOWN"), str(cooldown))
end

local function T(template_name)
	return E:get_template(template_name)
end

set_hero("hero_alleria")
set_skill(h.hero.skills.multishot)
get_cooldown()

local count = s.count_base + s.count_inc * max_lvl

set_bullet("arrow_multishot_hero_alleria")
get_damage(b.bullet)
get_damage(d[1], 2)

d[2].damage_max = d[2].damage_max - 20
map[_("HERO_ROOM_ALLERIA_MULTISHOT_NAME")] = string.format(_("HERO_ROOM_ALLERIA_MULTISHOT_DESC"), str(cooldown), str(count), str(damage_str()), str(damage_str(2)))

set_skill(h.hero.skills.callofwild)

cooldown = h.timed_attacks.list[1].cooldown
health[1].hp_max = s.hp_base + s.hp_inc * max_lvl
e = E:get_template("soldier_alleria_wildcat")

get_damage(e.melee.attacks[1])

d[1].damage_min = s.damage_min_base + s.damage_inc * max_lvl
d[1].damage_max = s.damage_max_base + s.damage_inc * max_lvl
map[_("HERO_ROOM_ALLERIA_CALLOFWILD_NAME")] = string.format(_("HERO_ROOM_ALLERIA_CALLOFWILD_DESC"), str(cooldown), str(health[1].hp_max), str(damage_str()))

set_skill(h.hero.skills.missileshot)

cooldown = h.ranged.attacks[3].cooldown
count = s.count_base + s.count_inc * max_lvl

set_bullet("arrow_hero_alleria_missile")
get_damage(b.bullet)

map[_("HERO_ROOM_ALLERIA_MISSILESHOT_NAME")] = string.format(_("HERO_ROOM_ALLERIA_MISSILESHOT_DESC"), str(cooldown), str(count), str(damage_str()))

set_hero("hero_gerald")
set_skill(h.hero.skills.block_counter)
get_damage(h.dodge.counter_attack)

local factor = h.dodge.counter_attack.reflected_damage_factor + h.dodge.counter_attack.reflected_damage_factor_inc * max_lvl
local chance = h.dodge.chance_base + h.dodge.chance_inc * max_lvl
local low_change_factor = h.dodge.low_chance_factor

map[_("HERO_ROOM_GERALD_BLOCK_COUNTER_NAME")] = string.format(_("HERO_ROOM_GERALD_BLOCK_COUNTER_DESC"), str(chance * 100), str(factor * 100), str(damage_type_map[d[1].damage_type]), str(low_change_factor * 100))

set_skill(h.hero.skills.holy_strike)
get_damage(h.melee.attacks[3])
cooldown = h.melee.attacks[3].cooldown
local radius = h.melee.attacks[3].damage_radius
e = T("mod_paladin_silence")
local duration = e.modifier.duration
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
map[_("HERO_ROOM_GERALD_HOLY_STRIKE_NAME")] = string.format(_("HERO_ROOM_GERALD_HOLY_STRIKE_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(duration))

set_skill(h.hero.skills.courage)

cooldown = h.timed_attacks.list[1].cooldown

local min_count = h.timed_attacks.list[1].min_count

e = E:get_template("mod_gerald_courage")

local heal_factor = e.courage.heal_once_factor + e.courage.heal_inc * max_lvl
local damage_buff = e.courage.damage_inc * max_lvl + e.courage.damage_inc_base
local armor_buff = e.courage.armor_inc * max_lvl
local magic_armor_buff = e.courage.magic_armor_inc * max_lvl
local duration = e.modifier.duration

map[_("HERO_ROOM_GERALD_COURAGE_NAME")] = string.format(_("HERO_ROOM_GERALD_COURAGE_DESC"), str(cooldown), str(min_count), str(heal_factor * 100), str(duration), str(damage_buff), str(armor_buff * 100), str(magic_armor_buff * 100))

set_skill(h.hero.skills.paladin)

e = E:get_template("soldier_gerald_paladin")

get_damage(e.melee.attacks[1])

d[1].damage_min = s.melee_damage_min[max_lvl]
d[1].damage_max = s.melee_damage_max[max_lvl]

get_health(e)

health[1].hp_max = s.hp_max[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown

local duration = e.reinforcement.duration

map[_("HERO_ROOM_GERALD_PALADIN_NAME")] = string.format(_("HERO_ROOM_GERALD_PALADIN_DESC"), str(cooldown), str(hp_str()), str(armor_str()), str(damage_str()), str(duration))

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
map[_("HERO_ROOM_BOLIN_MINES_NAME")] = string.format(_("HERO_ROOM_BOLIN_MINES_DESC"), str(cooldown), str(radius), str(duration), str(count), str(radius * 2), str(damage_str()))

set_skill(h.hero.skills.tar)

duration = s.duration[max_lvl]

set_bullet("aura_bolin_tar")

radius = b.aura.radius

set_bullet("mod_bolin_slow")

factor = 1 - b.slow.factor
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_BOLIN_TAR_NAME")] = string.format(_("HERO_ROOM_BOLIN_TAR_DESC"), str(cooldown), str(radius), str(factor * 100), str(duration))
chance = h.timed_attacks.list[4].chance
count = #h.timed_attacks.list[4].shoot_times
map[_("HERO_ROOM_BOLIN_TAR_2_NAME")] = string.format(_("HERO_ROOM_BOLIN_TAR_2_DESC"), str(chance * 100), str(count))
cooldown = h.timed_attacks.list[5].cooldown
count = h.timed_attacks.list[5].count

set_bullet("bomb_shrapnel_bolin")
get_damage(b.bullet)

radius = b.bullet.damage_radius
map[_("HERO_ROOM_BOLIN_TAR_3_NAME")] = string.format(_("HERO_ROOM_BOLIN_TAR_3_DESC"), str(cooldown), str(count), str(radius), str(damage_str()))

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
map[_("HERO_ROOM_MAGNUS_MIRAGE_NAME")] = string.format(_("HERO_ROOM_MAGNUS_MIRAGE_DESC"), str(cooldown_str()), str(count), str(health_factor * 100), str(damage_factor * 100), str(duration))
map[_("HERO_ROOM_MAGNUS_MIRAGE_2_NAME")] = string.format(_("HERO_ROOM_MAGNUS_MIRAGE_2_DESC"), str(rain_radius_factor * 100), str(rain_damage_factor * 100))

set_skill(h.hero.skills.arcane_rain)

cooldown = h.timed_attacks.list[2].cooldown

set_bullet("magnus_arcane_rain")
get_damage(b)

radius = b.damage_radius
count = s.count[max_lvl]
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map[_("HERO_ROOM_MAGNUS_ARCANE_RAIN_NAME")] = string.format(_("HERO_ROOM_MAGNUS_ARCANE_RAIN_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))

set_hero("hero_ignus")
set_skill(h.hero.skills.flaming_frenzy)

d[1].damage_type = h.timed_attacks.list[1].damage_type
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]

local heal_factor = h.timed_attacks.list[1].heal_factor

radius = h.timed_attacks.list[1].max_range
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_IGNUS_FLAMING_FRENZY_NAME")] = string.format(_("HERO_ROOM_IGNUS_FLAMING_FRENZY_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(heal_factor * 100))

set_skill(h.hero.skills.surge_of_flame)
set_bullet("aura_ignus_surge_of_flame")
get_damage(b.aura)

radius = b.aura.damage_radius

local cycle_time = b.aura.cycle_time

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_IGNUS_SURGE_OF_FLAME_NAME")] = string.format(_("HERO_ROOM_IGNUS_SURGE_OF_FLAME_DESC"), str(cooldown_str()), str(radius), str(cycle_time), str(damage_str()))

set_bullet("mod_ignus_burn_3")
get_damage(b.dps)

cycle_time = b.dps.damage_every
duration = b.modifier.duration
map[_("HERO_ROOM_IGNUS_SURGE_OF_FLAME_2_NAME")] = string.format(_("HERO_ROOM_IGNUS_SURGE_OF_FLAME_2_DESC"), str(duration), str(cycle_time), str(damage_str()))

set_hero("hero_malik")
set_bullet("mod_malik_stun")

duration = b.modifier.duration
chance = h.melee.attacks[2].chance
map[_("HERO_ROOM_MALIK_SURGE_OF_FLAME_NAME")] = string.format(_("HERO_ROOM_MALIK_SURGE_OF_FLAME_DESC"), str(rate_str(chance)), str(duration))

set_skill(h.hero.skills.smash)

cooldown = h.melee.attacks[3].cooldown

get_damage(h.melee.attacks[3])

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
chance = s.stun_chance[max_lvl]
radius = h.melee.attacks[3].damage_radius
map[_("HERO_ROOM_MALIK_SMASH_NAME")] = string.format(_("HERO_ROOM_MALIK_SMASH_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(rate_str(chance)), str(duration))

set_skill(h.hero.skills.fissure)
set_bullet("aura_malik_fissure")
get_damage(b.aura)

radius = b.aura.damage_radius
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.melee.attacks[4].cooldown
map[_("HERO_ROOM_MALIK_FISSURE_NAME")] = string.format(_("HERO_ROOM_MALIK_FISSURE_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(duration))

set_hero("hero_denas")
set_skill(h.hero.skills.tower_buff)

duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown

set_bullet("mod_denas_tower")

local s_range_factor = b.range_factor - 1
local s_cooldown_factor = 1 - b.cooldown_factor
local range = h.timed_attacks.list[2].max_range

map[_("HERO_ROOM_DENAS_TOWER_BUFF_NAME")] = string.format(_("HERO_ROOM_DENAS_TOWER_BUFF_DESC"), str(cooldown_str()), str(range), str(s_range_factor * 100), str(s_cooldown_factor * 100), str(duration))

set_skill(h.hero.skills.catapult)

cooldown = h.timed_attacks.list[3].cooldown

set_bullet("denas_catapult_rock")
get_damage(b.bullet)

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
count = s.count[max_lvl]
radius = b.bullet.damage_radius
map[_("HERO_ROOM_DENAS_CATAPULT_NAME")] = string.format(_("HERO_ROOM_DENAS_CATAPULT_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))

local s_price_factor = 1 - h.tower_price_factor

map[_("HERO_ROOM_DENAS_CATAPULT_2_NAME")] = string.format(_("HERO_ROOM_DENAS_CATAPULT_2_DESC"), str(s_price_factor * 100))

set_hero("hero_elora")
set_skill(h.hero.skills.chill)

factor = 1 - s.slow_factor[max_lvl]
count = s.count[max_lvl]
e = E:get_template("aura_chill_elora")
radius = e.aura.radius
cooldown = h.timed_attacks.list[2].cooldown
duration = e.aura.duration
map[_("HERO_ROOM_ELORA_CHILL_NAME")] = string.format(_("HERO_ROOM_ELORA_CHILL_DESC"), str(cooldown_str()), str(count), str(duration), str(radius), str(factor * 100))

set_skill(h.hero.skills.ice_storm)

count = s.count[max_lvl]

set_bullet("elora_ice_spike")
get_damage(b.bullet)

d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
radius = b.bullet.damage_radius
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_ELORA_ICE_STORM_NAME")] = string.format(_("HERO_ROOM_ELORA_ICE_STORM_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
e = E:get_template("mod_elora_bolt_slow")
duration = e.modifier.duration
factor = 1 - e.slow.factor
chance = h.ranged.attacks[1].chance
e = E:get_template("mod_elora_bolt_freeze")

local duration_2 = e.modifier.duration

map[_("HERO_ROOM_ELORA_ICE_STORM_2_NAME")] = string.format(_("HERO_ROOM_ELORA_ICE_STORM_2_DESC"), str(factor * 100), str(duration), str(rate_str(chance)), str(duration_2))

set_hero("hero_ingvar")

chance = h.melee.attacks[2].chance

get_damage(h.melee.attacks[2])

radius = h.melee.attacks[2].damage_radius
factor = h.melee.attacks[2].damage_factor
map[_("HERO_ROOM_INGVAR_ICE_STORM_NAME")] = string.format(_("HERO_ROOM_INGVAR_ICE_STORM_DESC"), str(rate_str(chance)), str(radius), str(factor * 100), str(damage_type_map[d[1].damage_type]))

set_skill(h.hero.skills.ancestors_call)

count = s.count[max_lvl]
health[1].hp_max = s.hp_max[max_lvl]
e = E:get_template("soldier_ingvar_ancestor")

get_damage(e.melee.attacks[1])

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
duration = e.reinforcement.duration
map[_("HERO_ROOM_INGVAR_ANCESTORS_CALL_NAME")] = string.format(_("HERO_ROOM_INGVAR_ANCESTORS_CALL_DESC"), str(cooldown_str()), str(count), str(hp_str(1)), str(damage_str()), str(duration))

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

map[_("HERO_ROOM_INGVAR_BEAR_NAME")] = string.format(_("HERO_ROOM_INGVAR_BEAR_DESC"), str(cooldown_str()), str(factor * 100), str(duration), str(damage_str()), str(cycle_time), str(heal))

set_hero("hero_hacksaw")

map[_("HERO_ROOM_HACKSAW_BEAR_NAME")] = _("HERO_ROOM_HACKSAW_BEAR_DESC")

set_skill(h.hero.skills.sawblade)

count = s.bounces[max_lvl]

set_bullet("hacksaw_sawblade")
get_damage(b.bullet)

range = b.bounce_range
cooldown = h.ranged.attacks[1].cooldown
map[_("HERO_ROOM_HACKSAW_SAWBLADE_NAME")] = string.format(_("HERO_ROOM_HACKSAW_SAWBLADE_DESC"), str(cooldown_str()), str(damage_str()), str(count), str(range))

set_skill(h.hero.skills.timber)
get_cooldown()

map[_("HERO_ROOM_HACKSAW_TIMBER_NAME")] = string.format(_("HERO_ROOM_HACKSAW_TIMBER_DESC"), str(cooldown_str()))

set_hero("hero_oni")
set_skill(h.hero.skills.death_strike)
get_damage(h.melee.attacks[3])

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
chance = s.chance[max_lvl]
cooldown = h.melee.attacks[3].cooldown
map[_("HERO_ROOM_ONI_DEATH_STRIKE_NAME")] = string.format(_("HERO_ROOM_ONI_DEATH_STRIKE_DESC"), str(cooldown_str()), str(damage_str()), str(rate_str(chance)))

set_skill(h.hero.skills.torment)
get_damage(h.timed_attacks.list[1])

d[1].damage_min = s.min_damage[max_lvl]
d[1].damage_max = s.max_damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
min_count = h.timed_attacks.list[1].min_count
radius = h.timed_attacks.list[1].damage_radius
map[_("HERO_ROOM_ONI_TORMENT_NAME")] = string.format(_("HERO_ROOM_ONI_TORMENT_DESC"), str(cooldown_str()), str(min_count), str(radius), str(damage_str()))

set_skill(h.hero.skills.rage)

damage_buff = s.rage_max[max_lvl]
factor = s.unyield_max[max_lvl]
map[_("HERO_ROOM_ONI_RAGE_NAME")] = string.format(_("HERO_ROOM_ONI_RAGE_DESC"), str(damage_buff), str(factor * 100))

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
map[_("HERO_ROOM_THOR_THUNDERCLAP_NAME")] = string.format(_("HERO_ROOM_THOR_THUNDERCLAP_DESC"), str(cooldown_str()), str(damage_str(1)), str(radius), str(damage_str(2)), str(duration_min), str(duration))

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
map[_("HERO_ROOM_THOR_CHAINLIGHTNING_NAME")] = string.format(_("HERO_ROOM_THOR_CHAINLIGHTNING_DESC"), str(rate_str(chance)), str(count), str(damage_str(2)), str(cycle_time), str(damage_str()), str(duration), str(factor * 100))
heal = h.hero.level_stats.lightning_heal[10]
map[_("HERO_ROOM_THOR_CHAINLIGHTNING_2_NAME")] = string.format(_("HERO_ROOM_THOR_CHAINLIGHTNING_2_DESC"), str(heal))

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
map[_("HERO_ROOM_10YR_BUFFED_NAME")] = string.format(_("HERO_ROOM_10YR_BUFFED_DESC"), str(cooldown), str(count_2), str(speed), str(duration), str(cooldown_3), str(radius), str(loop), str(damage_str(3)))
map[_("HERO_ROOM_10YR_BUFFED_2_NAME")] = string.format(_("HERO_ROOM_10YR_BUFFED_2_DESC"), str(cooldown_2), str(radius_3), str(damage_str(1)), str(count), str(radius_2), str(damage_str(2)), str(rate_str(chance)), str(duration_2))

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

map[_("HERO_ROOM_10YR_RAIN_NAME")] = string.format(_("HERO_ROOM_10YR_RAIN_DESC"), str(cooldown_str()), str(loop), str(radius), str(damage_str(1)), str(cycle_time), str(radius_2), str(damage_str(2)), str(duration))

set_hero("hero_alric")
set_skill(h.hero.skills.flurry)

loop = s.loops[max_lvl]

get_cooldown()
get_damage(h.melee.attacks[3])

map[_("HERO_ROOM_ALRIC_FLURRY_NAME")] = string.format(_("HERO_ROOM_ALRIC_FLURRY_DESC"), str(cooldown_str()), str(loop), str(damage_type_str(d[1].damage_type)))

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
map[_("HERO_ROOM_ALRIC_SANDWARRIORS_NAME")] = string.format(_("HERO_ROOM_ALRIC_SANDWARRIORS_DESC"), str(cooldown_str()), str(count), str(health[1].hp_max), str(damage_str()), str(duration))
map[_("HERO_ROOM_ALRIC_SANDWARRIORS_2_NAME")] = string.format(_("HERO_ROOM_ALRIC_SANDWARRIORS_2_DESC"), str(speed), str(factor * 100))

set_skill(h.hero.skills.spikedarmor)

local spiked_armor = 0

for _, value in pairs(s.values) do
	spiked_armor = spiked_armor + value
end

map[_("HERO_ROOM_ALRIC_SPIKEDARMOR_NAME")] = string.format(_("HERO_ROOM_ALRIC_SPIKEDARMOR_DESC"), str(spiked_armor * 100))

set_hero("hero_mirage")
set_skill(h.hero.skills.shadowdodge)

chance = s.dodge_chance[max_lvl]

local reward_shadowdance = s.reward_shadowdance[max_lvl]
local reward_lethalstrike = s.reward_lethalstrike[max_lvl]

duration = s.lifespan[max_lvl]
e = E:get_template("soldier_mirage_illusion")

get_damage(e.melee.attacks[1])

radius = e.melee.attacks[1].damage_radius
map[_("HERO_ROOM_MIRAGE_SHADOWDODGE_NAME")] = string.format(_("HERO_ROOM_MIRAGE_SHADOWDODGE_DESC"), str(rate_str(chance)), str(duration), str(radius), str(damage_str()), str(reward_shadowdance * 100), str(reward_lethalstrike * 100))

set_skill(h.hero.skills.shadowdance)

count = s.copies[max_lvl]

set_bullet("mirage_shadow")
get_damage(b.bullet)

d[1].damage_min = b.bullet.damage_min + b.bullet.damage_inc * max_lvl
d[1].damage_max = b.bullet.damage_max + b.bullet.damage_inc * max_lvl
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_MIRAGE_SHADOWDANCE_NAME")] = string.format(_("HERO_ROOM_MIRAGE_SHADOWDANCE_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.lethalstrike)

chance = s.instakill_chance[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown

get_damage(h.timed_attacks.list[2])

d[1].damage_min = d[1].damage_min * max_lvl
d[1].damage_max = d[1].damage_max * max_lvl
map[_("HERO_ROOM_MIRAGE_LETHALSTRIKE_NAME")] = string.format(_("HERO_ROOM_MIRAGE_LETHALSTRIKE_DESC"), str(cooldown_str()), str(damage_str()), str(rate_str(chance)))

set_hero("hero_pirate")
set_skill(h.hero.skills.scattershot)

count = s.fragments[max_lvl]

get_damage(E:get_template("barrel_fragment").bullet)

d[1].damage_max = s.fragment_damage[max_lvl]
d[1].damage_min = s.fragment_damage[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_PIRATE_SCATTERSHOT_NAME")] = string.format(_("HERO_ROOM_PIRATE_SCATTERSHOT_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.kraken)

factor = 1 - s.slow_factor[max_lvl]
count = s.max_enemies[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_dps_kraken")

get_damage(e.dps)

cycle_time = e.dps.damage_every
duration = e.modifier.duration
map[_("HERO_ROOM_PIRATE_KRAKEN_NAME")] = string.format(_("HERO_ROOM_PIRATE_KRAKEN_DESC"), str(cooldown_str()), str(duration), str(count), str(factor * 100), str(cycle_time), str(damage_str()))

set_skill(h.hero.skills.looting)

factor = s.percent[max_lvl]
map[_("HERO_ROOM_PIRATE_LOOTING_NAME")] = string.format(_("HERO_ROOM_PIRATE_LOOTING_DESC"), str(factor * 100))

set_hero("hero_wizard")
set_skill(h.hero.skills.magicmissile)

count = s.count[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown

set_bullet("missile_wizard")
get_damage(b.bullet)

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map[_("HERO_ROOM_WIZARD_MAGICMISSILE_NAME")] = string.format(_("HERO_ROOM_WIZARD_MAGICMISSILE_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.chainspell)

count = s.bounces[max_lvl]
cooldown = h.ranged.attacks[2].cooldown
map[_("HERO_ROOM_WIZARD_CHAINSPELL_NAME")] = string.format(_("HERO_ROOM_WIZARD_CHAINSPELL_DESC"), str(cooldown_str()), str(count))

set_skill(h.hero.skills.disintegrate)

count = s.count[max_lvl]

local total_damage = s.total_damage[max_lvl]

cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_WIZARD_DISINTEGRATE_NAME")] = string.format(_("HERO_ROOM_WIZARD_DISINTEGRATE_DESC"), str(cooldown_str()), str(count), str(total_damage))

set_skill(h.hero.skills.arcanetorrent)

factor = s.factor[max_lvl]
map[_("HERO_ROOM_WIZARD_ARCANETORRENT_NAME")] = string.format(_("HERO_ROOM_WIZARD_ARCANETORRENT_DESC"), str(factor * 100))

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
map[_("HERO_ROOM_BEASTMASTER_BOARMASTER_NAME")] = string.format(_("HERO_ROOM_BEASTMASTER_BOARMASTER_DESC"), str(cooldown_str()), str(count), str(health_str()), str(damage_str()), str(health_str(2)), str(damage_str(2)), str(rate_str(chance)))

set_skill(h.hero.skills.falconer)

count = s.count[max_lvl]
e = E:get_template("beastmaster_falcon")
cooldown = e.custom_attack.cooldown

get_damage(e.custom_attack)

e = E:get_template("mod_beastmaster_falcon")
duration = e.modifier.duration
factor = 1 - e.slow.factor
map[_("HERO_ROOM_BEASTMASTER_FALCONER_NAME")] = string.format(_("HERO_ROOM_BEASTMASTER_FALCONER_DESC"), str(count), str(cooldown), str(damage_str()), str(factor * 100), str(duration))

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
map[_("HERO_ROOM_BEASTMASTER_STAMPEDE_NAME")] = string.format(_("HERO_ROOM_BEASTMASTER_STAMPEDE_DESC"), str(cooldown_str()), str(count), str(damage_str()), str(rate_str(chance)), str(duration_2), str(duration))

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
map[_("HERO_ROOM_BEASTMASTER_DEEPLASHES_NAME")] = string.format(_("HERO_ROOM_BEASTMASTER_DEEPLASHES_DESC"), str(cooldown_str()), str(damage_str()), str(duration), str(damage_str(2)))
e = E:get_template("aura_beastmaster_regeneration")
cycle_time = e.hps.heal_every

local amount = e.hps.heal_min

map[_("HERO_ROOM_BEASTMASTER_DEEPLASHES_2_NAME")] = string.format(_("HERO_ROOM_BEASTMASTER_DEEPLASHES_2_DESC"), str(cycle_time), str(amount))

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
map[_("HERO_ROOM_VOODOO_WITCH_LAUGHINGSKULLS_NAME")] = string.format(_("HERO_ROOM_VOODOO_WITCH_LAUGHINGSKULLS_DESC"), str(cooldown), str(damage_str()), str(count))

set_skill(h.hero.skills.deathskull)
get_damage(e.sacrifice)

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map[_("HERO_ROOM_VOODOO_WITCH_DEATHSKULL_NAME")] = string.format(_("HERO_ROOM_VOODOO_WITCH_DEATHSKULL_DESC"), str(damage_str()))

set_skill(h.hero.skills.bonedance)

count = s.skull_count[max_lvl]
map[_("HERO_ROOM_VOODOO_WITCH_BONEDANCE_NAME")] = string.format(_("HERO_ROOM_VOODOO_WITCH_BONEDANCE_DESC"), str(count))

set_skill(h.hero.skills.deathaura)

factor = s.slow_factor[max_lvl]
e = E:get_template("voodoo_witch_death_aura")
cycle_time = e.aura.cycle_time
radius = e.aura.radius

get_damage(e.aura)

d[1].damage_min = e.aura.damage
d[1].damage_max = e.aura.damage
map[_("HERO_ROOM_VOODOO_WITCH_DEATHAURA_NAME")] = string.format(_("HERO_ROOM_VOODOO_WITCH_DEATHAURA_DESC"), str(cycle_time), str(radius), str(damage_str()), str(factor * 100))

set_skill(h.hero.skills.voodoomagic)
get_damage(h.timed_attacks.list[1])

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_voodoo_witch_magic_slow")
factor = 1 - e.slow.factor
duration = e.modifier.duration
count = s.count[max_lvl]
map[_("HERO_ROOM_VOODOO_WITCH_VOODOOMAGIC_NAME")] = string.format(_("HERO_ROOM_VOODOO_WITCH_VOODOOMAGIC_DESC"), str(cooldown_str()), str(count), str(factor * 100), str(duration), str(damage_str()))

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
map[_("HERO_ROOM_ALIEN_ENERGYGLAIVE_NAME")] = string.format(_("HERO_ROOM_ALIEN_ENERGYGLAIVE_DESC"), str(cooldown_str()), str(damage_str()), str(duration), str(factor * 100), str(rate_str(chance)))

set_skill(h.hero.skills.purificationprotocol)

duration = s.duration[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
e = E:get_template("alien_purification_drone")

get_damage(e.dps)

cycle_time = e.dps.damage_every
map[_("HERO_ROOM_ALIEN_PURIFICATIONPROTOCOL_NAME")] = string.format(_("HERO_ROOM_ALIEN_PURIFICATIONPROTOCOL_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(damage_str()))

set_skill(h.hero.skills.abduction)

count = s.total_targets[max_lvl]
amount = s.total_hp[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_ALIEN_ABDUCTION_NAME")] = string.format(_("HERO_ROOM_ALIEN_ABDUCTION_DESC"), str(cooldown_str()), str(count), str(amount))

set_skill(h.hero.skills.vibroblades)

d[1].damage_type = s.damage_type
d[1].damage_min = s.extra_damage[max_lvl]
d[1].damage_max = s.extra_damage[max_lvl]
map[_("HERO_ROOM_ALIEN_VIBROBLADES_NAME")] = string.format(_("HERO_ROOM_ALIEN_VIBROBLADES_DESC"), str(damage_str()))

set_skill(h.hero.skills.finalcountdown)
get_damage(h.selfdestruct)

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
e = E:get_template("mod_alien_selfdestruct")
duration = e.modifier.duration
map[_("HERO_ROOM_ALIEN_FINALCOUNTDOWN_NAME")] = string.format(_("HERO_ROOM_ALIEN_FINALCOUNTDOWN_DESC"), str(damage_str()), str(duration))

set_hero("hero_monk")
set_skill(h.hero.skills.tigerstyle)
get_damage(h.melee.attacks[5])

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.melee.attacks[5].cooldown
map[_("HERO_ROOM_MONK_TIGERSTYLE_NAME")] = string.format(_("HERO_ROOM_MONK_TIGERSTYLE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.snakestyle)
get_damage(h.melee.attacks[4])

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
cooldown = h.melee.attacks[4].cooldown
factor = s.damage_reduction_factor[max_lvl]
map[_("HERO_ROOM_MONK_SNAKESTYLE_NAME")] = string.format(_("HERO_ROOM_MONK_SNAKESTYLE_DESC"), str(cooldown_str()), str(damage_str()), str(factor * 100))

set_skill(h.hero.skills.leopardstyle)

count = s.loops[max_lvl]

get_damage(h.timed_attacks.list[2])

d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_MONK_LEOPARDSTYLE_NAME")] = string.format(_("HERO_ROOM_MONK_LEOPARDSTYLE_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.dragonstyle)
get_damage(h.timed_attacks.list[1])

d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_MONK_DRAGONSTYLE_NAME")] = string.format(_("HERO_ROOM_MONK_DRAGONSTYLE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.cranestyle)

chance = s.chance[max_lvl]
cooldown = s.cooldown[max_lvl]

get_damage(h.dodge)

d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
map[_("HERO_ROOM_MONK_CRANESTYLE_NAME")] = string.format(_("HERO_ROOM_MONK_CRANESTYLE_DESC"), str(rate_str(chance)), str(damage_str()), str(cooldown))
map[_("HERO_ROOM_MONK_CRANESTYLE_2_NAME")] = _("HERO_ROOM_MONK_CRANESTYLE_2_DESC")

set_hero("hero_monkey_god")
set_skill(h.hero.skills.spinningpole)

count = s.loops[max_lvl]

get_damage(h.melee.attacks[3])

radius = h.melee.attacks[3].damage_radius
cooldown = h.melee.attacks[3].cooldown

set_damage_value(s.damage[max_lvl])

map[_("HERO_ROOM_MONKEY_GOD_SPINNINGPOLE_NAME")] = string.format(_("HERO_ROOM_MONKEY_GOD_SPINNINGPOLE_DESC"), str(cooldown_str()), str(radius), str(count), str(damage_str()))

set_skill(h.hero.skills.tetsubostorm)
get_damage(h.melee.attacks[4])
set_damage_value(s.damage[max_lvl])

cooldown = h.melee.attacks[4].cooldown
count = h.melee.attacks[4].loops * #h.melee.attacks[4].hit_times
map[_("HERO_ROOM_MONKEY_GOD_TETSUBOSTORM_NAME")] = string.format(_("HERO_ROOM_MONKEY_GOD_TETSUBOSTORM_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.monkeypalm)
get_damage(h.melee.attacks[5])

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
duration = s.stun_duration[max_lvl]
duration_2 = s.silence_duration[max_lvl]
cooldown = h.melee.attacks[5].cooldown
map[_("HERO_ROOM_MONKEY_GOD_MONKEYPALM_NAME")] = string.format(_("HERO_ROOM_MONKEY_GOD_MONKEYPALM_DESC"), str(cooldown_str()), str(damage_str()), str(duration), str(duration_2))

set_skill(h.hero.skills.angrygod)

factor = s.received_damage_factor[max_lvl]
duration = h.timed_attacks.list[1].loops * 17 / 30
cooldown = h.timed_attacks.list[1].cooldown
e = E:get_template("mod_monkey_god_fire")

get_damage(e.dps)
set_damage_value(e.dps.damage_min + max_lvl * e.dps.damage_inc)

cycle_time = e.dps.damage_every
map[_("HERO_ROOM_MONKEY_GOD_ANGRYGOD_NAME")] = string.format(_("HERO_ROOM_MONKEY_GOD_ANGRYGOD_DESC"), str(cooldown_str()), str(duration), str(factor), str(cycle_time), str(damage_str()))
speed = h.cloudwalk.extra_speed
e = E:get_template("aura_monkey_god_divinenature")
cycle_time = e.hps.heal_every
amount = e.hps.heal_min
map[_("HERO_ROOM_MONKEY_GOD_ANGRYGOD_2_NAME")] = string.format(_("HERO_ROOM_MONKEY_GOD_ANGRYGOD_2_DESC"), str(speed), str(cycle_time), str(amount))

set_hero("hero_giant")
set_skill(h.hero.skills.boulderthrow)

cooldown = h.ranged.attacks[1].cooldown

set_bullet("giant_boulder")

radius = b.bullet.damage_radius

get_damage(b.bullet)

d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
map[_("HERO_ROOM_GIANT_BOULDERTHROW_NAME")] = string.format(_("HERO_ROOM_GIANT_BOULDERTHROW_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.massivedamage)

factor = s.health_factor
e = E:get_template("mod_giant_massivedamage")

get_damage(e)
set_damage_value(s.extra_damage[max_lvl])

chance = s.chance[max_lvl]
cooldown = h.melee.attacks[2].cooldown
map[_("HERO_ROOM_GIANT_MASSIVEDAMAGE_NAME")] = string.format(_("HERO_ROOM_GIANT_MASSIVEDAMAGE_DESC"), str(cooldown_str()), str(damage_str()), str(rate_str(chance)), str(100 / factor))

set_skill(h.hero.skills.stomp)

count = s.loops[max_lvl]
duration = s.stun_duration[max_lvl]

get_damage(h.timed_attacks.list[1])
set_damage_value(s.damage[max_lvl])

cooldown = h.timed_attacks.list[1].cooldown
radius = h.timed_attacks.list[1].damage_radius
chance = h.timed_attacks.list[1].stun_chance
map[_("HERO_ROOM_GIANT_STOMP_NAME")] = string.format(_("HERO_ROOM_GIANT_STOMP_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()), str(rate_str(chance)), str(duration))

set_skill(h.hero.skills.bastion)

amount = s.damage_per_tick[max_lvl]

local amount_2 = s.max_damage[max_lvl]

e = E:get_template("aura_giant_bastion")
cycle_time = e.tick_time

set_skill(h.hero.skills.hardrock)

local amount_3 = s.damage_block[max_lvl]

map[_("HERO_ROOM_GIANT_HARDROCK_NAME")] = string.format(_("HERO_ROOM_GIANT_HARDROCK_DESC"), str(cycle_time), str(amount), str(amount_2), str(amount_3))

set_hero("hero_dragon")
set_skill(h.hero.skills.blazingbreath)

e = E:get_template("breath_dragon")

get_damage(e.bullet)
set_damage_value(s.damage[max_lvl])

radius = e.bullet.damage_radius
cooldown = h.ranged.attacks[2].cooldown
map[_("HERO_ROOM_DRAGON_BLAZINGBREATH_NAME")] = string.format(_("HERO_ROOM_DRAGON_BLAZINGBREATH_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.feast)

chance = s.devour_chance[max_lvl]

get_damage(h.timed_attacks.list[1])
set_damage_value(s.damage[max_lvl])

cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_DRAGON_FEAST_NAME")] = string.format(_("HERO_ROOM_DRAGON_FEAST_DESC"), str(cooldown_str()), str(damage_str()), str(rate_str(chance)))

set_skill(h.hero.skills.fierymist)

e = E:get_template("aura_fierymist_dragon")
factor = 1 - s.slow_factor[max_lvl]
duration = s.duration[max_lvl]
radius = e.aura.radius
cycle_time = e.aura.cycle_time

get_damage(e.aura)

cooldown = h.ranged.attacks[3].cooldown
map[_("HERO_ROOM_DRAGON_FIERYMIST_NAME")] = string.format(_("HERO_ROOM_DRAGON_FIERYMIST_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(radius), str(damage_str()), str(factor * 100))

set_skill(h.hero.skills.wildfirebarrage)

cooldown = h.ranged.attacks[4].cooldown
count = s.explosions[max_lvl]
e = E:get_template("wildfirebarrage_dragon")

get_damage(e.bullet)

radius = e.bullet.damage_radius
map[_("HERO_ROOM_DRAGON_WILDFIREBARRAGE_NAME")] = string.format(_("HERO_ROOM_DRAGON_WILDFIREBARRAGE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))

set_skill(h.hero.skills.reignoffire)

e = E:get_template("mod_dragon_reign")
duration = e.modifier.duration
cycle_time = e.dps.damage_every

get_damage(e.dps)
set_damage_value(s.dps[max_lvl])

count = e.modifier.max_duplicates
map[_("HERO_ROOM_DRAGON_REIGNOFFIRE_NAME")] = string.format(_("HERO_ROOM_DRAGON_REIGNOFFIRE_DESC"), str(duration), str(cycle_time), str(damage_str()), str(count))

set_hero("hero_priest")
set_skill(h.hero.skills.holylight)

count = s.heal_count[max_lvl]
chance = s.revive_chance[max_lvl]
heal = s.heal_hp[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_PRIEST_HOLYLIGHT_NAME")] = string.format(_("HERO_ROOM_PRIEST_HOLYLIGHT_DESC"), str(cooldown_str()), str(count), str(heal), str(rate_str(chance)))

set_skill(h.hero.skills.consecrate)

duration = s.duration[max_lvl]
factor = s.extra_damage[max_lvl]
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_PRIEST_CONSECRATE_NAME")] = string.format(_("HERO_ROOM_PRIEST_CONSECRATE_DESC"), str(cooldown_str()), str(factor * 100), str(duration))

set_skill(h.hero.skills.wingsoflight)

duration = s.duration[max_lvl]
factor = s.armor_rate[max_lvl]

local factor_2 = s.damage_rate[max_lvl]

e = E:get_template("mod_priest_armor")

local factor_3 = 1 - e.cooldown_rate

count = s.count[max_lvl]
map[_("HERO_ROOM_PRIEST_WINGSOFLIGHT_NAME")] = string.format(_("HERO_ROOM_PRIEST_WINGSOFLIGHT_DESC"), str(count), str(factor * 100), str(factor_2 * 100), str(factor_3 * 100))

set_hero("hero_dwarf")
set_skill(h.hero.skills.ring)
get_damage(h.melee.attacks[2])

cooldown = h.melee.attacks[2].cooldown
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
radius = h.melee.attacks[2].damage_radius
map[_("HERO_ROOM_DWARF_RING_NAME")] = string.format(_("HERO_ROOM_DWARF_RING_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.giant)

factor = s.scale[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
heal_factor = factor * 0.1
e = E:get_template("mod_dwarf_champion_stun")
duration = e.modifier.duration
map[_("HERO_ROOM_DWARF_GIANT_NAME")] = string.format(_("HERO_ROOM_DWARF_GIANT_DESC"), str(cooldown_str()), str(factor), str(heal_factor * 100), str(duration), str(factor))
cooldown = h.timed_attacks.list[2].cooldown
duration = E:get_template("soldier_dwarf_reinforcement").reinforcement.duration
map[_("HERO_ROOM_DWARF_GIANT_2_NAME")] = string.format(_("HERO_ROOM_DWARF_GIANT_2_DESC"), str(cooldown_str()), str(duration))

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
map[_("HERO_ROOM_MINOTAUR_BULLRUSH_NAME")] = string.format(_("HERO_ROOM_MINOTAUR_BULLRUSH_DESC"), str(cooldown_str()), str(damage_str(2)), str(damage_str()), str(duration))

set_skill(h.hero.skills.bloodaxe)

factor = s.damage_factor[max_lvl]
chance = h.melee.attacks[2].chance
map[_("HERO_ROOM_MINOTAUR_BLOODAXE_NAME")] = string.format(_("HERO_ROOM_MINOTAUR_BLOODAXE_DESC"), str(rate_str(chance)), str(factor))

set_skill(h.hero.skills.daedalusmaze)

cooldown = h.timed_attacks.list[4].cooldown
duration = s.duration[max_lvl]
range = h.timed_attacks.list[4].min_range
map[_("HERO_ROOM_MINOTAUR_DAEDALUSMAZE_NAME")] = string.format(_("HERO_ROOM_MINOTAUR_DAEDALUSMAZE_DESC"), str(cooldown_str()), str(range), str(duration))

set_skill(h.hero.skills.roaroffury)

cooldown = h.timed_attacks.list[2].cooldown
factor = s.extra_damage[max_lvl]
map[_("HERO_ROOM_MINOTAUR_ROAROFFURY_NAME")] = string.format(_("HERO_ROOM_MINOTAUR_ROAROFFURY_DESC"), str(cooldown_str()), str(factor * 100))

set_skill(h.hero.skills.doomspin)
get_damage(h.timed_attacks.list[1])

cooldown = h.timed_attacks.list[1].cooldown
radius = h.timed_attacks.list[1].damage_radius
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
map[_("HERO_ROOM_MINOTAUR_DOOMSPIN_NAME")] = string.format(_("HERO_ROOM_MINOTAUR_DOOMSPIN_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_hero("hero_crab")
set_skill(h.hero.skills.battlehardened)

chance = s.chance[max_lvl]
duration = h.invuln.duration
map[_("HERO_ROOM_CRAB_BATTLEHARDENED_NAME")] = string.format(_("HERO_ROOM_CRAB_BATTLEHARDENED_DESC"), str(rate_str(chance)), str(duration))

set_skill(h.hero.skills.pincerattack)

cooldown = h.timed_attacks.list[1].cooldown

get_damage(h.timed_attacks.list[1])

d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]

local x = h.timed_attacks.list[1].damage_size.x
local y = h.timed_attacks.list[1].damage_size.y

map[_("HERO_ROOM_CRAB_PINCERATTACK_NAME")] = string.format(_("HERO_ROOM_CRAB_PINCERATTACK_DESC"), str(cooldown_str()), str(x), str(y), str(damage_str()))

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
map[_("HERO_ROOM_CRAB_SHOULDERCANNON_NAME")] = string.format(_("HERO_ROOM_CRAB_SHOULDERCANNON_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(duration), str(factor * 100))

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
map[_("HERO_ROOM_CRAB_BURROW_NAME")] = string.format(_("HERO_ROOM_CRAB_BURROW_DESC"), str(amount_3), str(amount), str(amount_2), str(amount_4), str(radius), str(damage_str()), str(duration), str(cooldown))

set_hero("hero_van_helsing")
set_skill(h.hero.skills.silverbullet)

cooldown = h.timed_attacks.list[2].cooldown

get_damage(E:get_template("van_helsing_silverbullet").bullet)
set_damage_value(s.damage[max_lvl])

map[_("HERO_ROOM_VAN_HELSING_SILVERBULLET_NAME")] = string.format(_("HERO_ROOM_VAN_HELSING_SILVERBULLET_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.multishoot)

count = s.loops[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown

get_damage(E:get_template("van_helsing_shotgun").bullet)

map[_("HERO_ROOM_VAN_HELSING_MULTISHOOT_NAME")] = string.format(_("HERO_ROOM_VAN_HELSING_MULTISHOOT_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.relicofpower)

factor = ss("armor_reduce_factor")
cooldown = h.melee.attacks[2].cooldown
map[_("HERO_ROOM_VAN_HELSING_RELICOFPOWER_NAME")] = string.format(_("HERO_ROOM_VAN_HELSING_RELICOFPOWER_DESC"), str(cooldown_str()), str(factor * 100))

set_skill(h.hero.skills.holygrenade)

duration = ss("silence_duration")
radius = E:get_template("van_helsing_grenade").bullet.damage_radius
cooldown = h.timed_attacks.list[3].cooldown
map[_("HERO_ROOM_VAN_HELSING_HOLYGRENADE_NAME")] = string.format(_("HERO_ROOM_VAN_HELSING_HOLYGRENADE_DESC"), str(cooldown_str()), str(radius), str(duration))

set_skill(h.hero.skills.beaconoflight)

factor = ss("inflicted_damage_factor")
map[_("HERO_ROOM_VAN_HELSING_BEACONOFLIGHT_NAME")] = string.format(_("HERO_ROOM_VAN_HELSING_BEACONOFLIGHT_DESC"), str(factor))

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
map[_("HERO_ROOM_DRACOLICH_SPINERAIN_NAME")] = string.format(_("HERO_ROOM_DRACOLICH_SPINERAIN_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))

set_skill(h.hero.skills.diseasenova)

a = h.timed_attacks.list[3]
cooldown = a.cooldown

get_damage(a)

radius = a.max_range
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
map[_("HERO_ROOM_DRACOLICH_DISEASENOVA_NAME")] = string.format(_("HERO_ROOM_DRACOLICH_DISEASENOVA_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.plaguecarrier)

count = ss("count")
duration = ss("duration")
a = h.timed_attacks.list[1]
cooldown = a.cooldown
e = E:get_template("dracolich_plague_carrier")

get_damage(e.aura)

map[_("HERO_ROOM_DRACOLICH_PLAGUECARRIER_NAME")] = string.format(_("HERO_ROOM_DRACOLICH_PLAGUECARRIER_DESC"), str(cooldown_str()), str(count), str(duration), str(damage_str()))

set_skill(h.hero.skills.bonegolem)

e = E:get_template("soldier_dracolich_golem")

get_health(e)
get_damage(e.melee.attacks[1])

health[1].hp_max = ss("hp_max")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
duration = ss("duration")
map[_("HERO_ROOM_DRACOLICH_BONEGOLEM_NAME")] = string.format(_("HERO_ROOM_DRACOLICH_BONEGOLEM_DESC"), str(cooldown_str()), str(duration), str(health_str()), str(damage_str()))

set_skill(h.hero.skills.unstabledisease)

e = E:get_template("mod_dracolich_disease")

set_damage_value(ss("spread_damage"))

d[1].damage_type = e.dps.damage_type
duration = e.modifier.duration

get_damage(e.dps, 2)
set_damage_value(h.hero.level_stats.disease_damage[#h.hero.level_stats.disease_damage], 2)

cycle_time = e.dps.damage_every
radius = e.spread_radius
map[_("HERO_ROOM_DRACOLICH_UNSTABLEDISEASE_NAME")] = string.format(_("HERO_ROOM_DRACOLICH_UNSTABLEDISEASE_DESC"), str(duration), str(cycle_time), str(damage_str(2)), str(radius), str(damage_str(1)))

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

map[_("HERO_ROOM_VAMPIRESS_VAMPIRISM_NAME")] = string.format(_("HERO_ROOM_VAMPIRESS_VAMPIRISM_DESC"), str(cooldown_str()), str(damage_str()), str(duration), str(cycle_time), str(damage_str(2)))

set_skill(h.hero.skills.slayer)

a = h.timed_attacks.list[1]

get_damage(a)

d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
radius = a.damage_radius
factor = a.extra_damage_factor
cooldown = a.cooldown
map[_("HERO_ROOM_VAMPIRESS_SLAYER_NAME")] = string.format(_("HERO_ROOM_VAMPIRESS_SLAYER_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(factor))
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

map[_("HERO_ROOM_VAMPIRESS_SLAYER_2_NAME")] = string.format(_("HERO_ROOM_VAMPIRESS_SLAYER_2_DESC"), str(heal), str(amount_2), str(amount), str(amount_7 * 100), str(amount_3 * 100), str(amount_6), str(amount_5), str(amount_4), str(count))
map[_("HERO_ROOM_VAMPIRESS_SLAYER_3_NAME")] = string.format(_("HERO_ROOM_VAMPIRESS_SLAYER_3_DESC"), str(h.motion.max_speed_bat - h.motion.max_speed))

set_hero("hero_elves_archer")
set_skill(h.hero.skills.nimble_fencer)

chance = ss("chance")

get_damage(h.dodge.counter_attack)

map[_("HERO_ROOM_ELVES_ARCHER_NIMBLE_FENCER_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_NIMBLE_FENCER_DESC"), str(rate_str(chance)), str(damage_str()))

set_skill(h.hero.skills.double_strike)
get_damage(h.melee.attacks[2])

cooldown = h.melee.attacks[2].cooldown
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_ELVES_ARCHER_DOUBLE_STRIKE_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_DOUBLE_STRIKE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.porcupine)

amount = ss("damage_inc")
map[_("HERO_ROOM_ELVES_ARCHER_PORCUPINE_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_PORCUPINE_DESC"), str(amount))

set_skill(h.hero.skills.multishot)

count = ss("loops")
cooldown = h.ranged.attacks[2].cooldown
map[_("HERO_ROOM_ELVES_ARCHER_MULTISHOT_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_MULTISHOT_DESC"), str(cooldown_str()), str(count))

set_skill(h.hero.skills.ultimate)

cooldown = h.ultimate.cooldown
e = E:get_template("hero_elves_archer_ultimate")

set_damage_value(e.damage[#e.damage])

count = e.spread[#e.spread] * 4
e = E:get_template("arrow_hero_elves_archer_ultimate")
radius = e.bullet.damage_radius
e = E:get_template("mod_hero_elves_archer_slow")
factor = 1 - e.slow.factor
duration = e.modifier.duration
map[_("HERO_ROOM_ELVES_ARCHER_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()), str(factor * 100), str(duration))

set_skill(h.hero.skills.guards)
e = E:get_template(h.timed_attacks.list[1].entity)
get_damage(e.melee.attacks[1])

get_health(e)
health[1].hp_max = s.hp_max[max_lvl]
health[1].armor = s.armor[max_lvl]
cooldown = h.timed_attacks.list[1].cooldown
local duration = e.reinforcement.duration

map[_("HERO_ROOM_ELVES_ARCHER_GUARDS_NAME")] = string.format(_("HERO_ROOM_ELVES_ARCHER_GUARDS_DESC"), str(cooldown), str(hp_str()), str(armor_str()), str(damage_str()), str(duration))

set_hero("hero_regson")
set_skill(h.hero.skills.slash)

a = h.melee.attacks[5]
cooldown = a.cooldown
radius = a.damage_radius
e = E:get_template("mod_regson_slash")

get_damage(e)

d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_REGSON_SLASH_NAME")] = string.format(_("HERO_ROOM_REGSON_SLASH_DESC"), str(cooldown_str()), str(radius), str(damage_str()))
count = ss("loops")
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_REGSON_SLASH_2_NAME")] = string.format(_("HERO_ROOM_REGSON_SLASH_2_DESC"), str(cooldown_str()), str(count))

set_skill(h.hero.skills.heal)

factor = ss("heal_factor")
map[_("HERO_ROOM_REGSON_HEAL_NAME")] = string.format(_("HERO_ROOM_REGSON_HEAL_DESC"), str(factor * 100))

set_skill(h.hero.skills.blade)
get_damage(h.melee.attacks[3])
set_damage_value(ss("damage"))

e = E:get_template("aura_regson_blade")
duration = e.blade_duration
cooldown = e.blade_cooldown
chance = ss("instakill_chance")
map[_("HERO_ROOM_REGSON_BLADE_NAME")] = string.format(_("HERO_ROOM_REGSON_BLADE_DESC"), str(cooldown_str()), str(duration), str(damage_str()), str(rate_str(chance)))

set_skill(h.hero.skills.ultimate)

cooldown = ss("cooldown")

set_damage_value(ss("damage_boss"))

d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_REGSON_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_REGSON_ULTIMATE_DESC"), str(cooldown_str()), str(damage_str()))

set_hero("hero_lynn")
set_skill(h.hero.skills.hexfury)

count = ss("loops")
amount = s.extra_damage

get_damage(h.melee.attacks[3])

cooldown = h.melee.attacks[3].cooldown
count = count * #h.melee.attacks[3].hit_times
map[_("HERO_ROOM_LYNN_HEXFURY_NAME")] = string.format(_("HERO_ROOM_LYNN_HEXFURY_DESC"), str(cooldown_str()), str(count), str(damage_str()), str(amount))

set_skill(h.hero.skills.despair)

duration = ss("duration")
factor = ss("damage_factor")
factor_2 = 1 - ss("speed_factor")
count = ss("max_count")
a = h.timed_attacks.list[1]
cooldown = a.cooldown
map[_("HERO_ROOM_LYNN_DESPAIR_NAME")] = string.format(_("HERO_ROOM_LYNN_DESPAIR_DESC"), str(cooldown_str()), str(count), str(factor_2 * 100), str(factor * 100), str(duration))

set_skill(h.hero.skills.weakening)

duration = ss("duration")
factor = ss("armor_reduction")
factor_2 = ss("magic_armor_reduction")
count = ss("max_count")
a = h.timed_attacks.list[2]
cooldown = a.cooldown
map[_("HERO_ROOM_LYNN_WEAKENING_NAME")] = string.format(_("HERO_ROOM_LYNN_WEAKENING_DESC"), str(cooldown_str()), str(count), str(factor * 100), str(factor_2 * 100), str(duration))

set_skill(h.hero.skills.charm_of_unluck)

chance = ss("chance")
e = E:get_template("mod_lynn_curse")

local chance_2 = e.modifier.chance

duration = e.modifier.duration
map[_("HERO_ROOM_LYNN_CHARM_OF_UNLUCK_NAME")] = string.format(_("HERO_ROOM_LYNN_CHARM_OF_UNLUCK_DESC"), str(rate_str(chance)), str(rate_str(chance_2)), str(duration))

set_skill(h.hero.skills.ultimate)

cooldown = h.ultimate.cooldown
e = E:get_template("mod_lynn_ultimate")

get_damage(e.dps)
set_damage_value(ss("damage"))

d[2].damage_type = e.explode_damage_type

set_damage_value(ss("explode_damage"), 2)

cycle_time = e.dps.damage_every
duration = e.modifier.duration
map[_("HERO_ROOM_LYNN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_LYNN_ULTIMATE_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(damage_str()), str(damage_str(2)))

set_hero("hero_wilbur")
set_skill(h.hero.skills.smoke)
duration = ss("duration")
factor = ss("slow_factor")
a = h.timed_attacks.list[1]
cooldown = a.cooldown
e = T("aura_smoke_wilbur")
radius = e.aura.radius
map[_("HERO_ROOM_WILBUR_SMOKE_NAME")] = string.format(_("HERO_ROOM_WILBUR_SMOKE_DESC"), str(cooldown_str()), str(duration), str(radius), str(factor * 100))
set_skill(h.hero.skills.missile)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
e = T("missile_wilbur")
d[1].damage_type = e.bullet.damage_type
a = h.ranged.attacks[2]
cooldown = a.cooldown
count = #a.shoot_times
radius = e.bullet.damage_radius
map[_("HERO_ROOM_WILBUR_MISSILE_NAME")] = string.format(_("HERO_ROOM_WILBUR_MISSILE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
set_skill(h.hero.skills.box)
count = ss("count")
e = T("aura_bomb_wilbur")
get_damage(e.aura)
radius = e.aura.radius
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_WILBUR_BOX_NAME")] = string.format(_("HERO_ROOM_WILBUR_BOX_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
set_skill(h.hero.skills.ultimate)
set_damage_value(ss("damage"))
cooldown = h.ultimate.cooldown
e = T("hero_wilbur_ultimate")
count = #e.spawn_offsets
e = T("drone_wilbur")
duration = e.duration
count_2 = e.custom_attack.max_shots
cycle_time = e.custom_attack.cooldown
d[1].damage_type = e.custom_attack.damage_type
map[_("HERO_ROOM_WILBUR_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_WILBUR_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(duration), str(cycle_time), str(count_2), str(damage_str()))

set_hero("hero_veznan")
set_skill(h.hero.skills.soulburn)
amount = ss("total_hp")
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_VEZNAN_SOULBURN_NAME")] = string.format(_("HERO_ROOM_VEZNAN_SOULBURN_DESC"), str(cooldown_str()), str(amount))
set_skill(h.hero.skills.shackles)
count = ss("max_count")
cooldown = h.timed_attacks.list[2].cooldown
e = T("mod_veznan_shackles_dps")
get_damage(e.dps)
cycle_time = e.dps.damage_every
duration = e.modifier.duration
map[_("HERO_ROOM_VEZNAN_SHACKLES_NAME")] = string.format(_("HERO_ROOM_VEZNAN_SHACKLES_DESC"), str(cooldown_str()), str(count), str(duration), str(cycle_time), str(damage_str()))
set_skill(h.hero.skills.arcanenova)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
cooldown = h.timed_attacks.list[3].cooldown
radius = h.timed_attacks.list[3].damage_radius
d[1].damage_type = h.timed_attacks.list[3].damage_type
e = T("mod_veznan_arcanenova")
factor = e.slow.factor
duration = e.modifier.duration
map[_("HERO_ROOM_VEZNAN_ARCANENOVA_NAME")] = string.format(_("HERO_ROOM_VEZNAN_ARCANENOVA_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(factor * 100), str(duration))
set_skill(h.hero.skills.ultimate)
duration = ss("stun_duration")
health[1].hp_max = ss("soldier_hp_max")
d[1].damage_max = ss("soldier_damage_max")
d[1].damage_min = ss("soldier_damage_min")
e = T("hero_veznan_ultimate")
radius = e.range
e = T("soldier_veznan_demon")
health[1].armor = e.health.armor
health[1].magic_armor = e.health.magic_armor
d[1].damage_type = e.melee.attacks[1].damage_type
cooldown = h.ultimate.cooldown
duration_2 = e.reinforcement.duration
map[_("HERO_ROOM_VEZNAN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_VEZNAN_ULTIMATE_DESC"), str(cooldown_str()), str(radius), str(duration), str(duration_2), str(health_str()), str(damage_str()))

set_hero("hero_durax")
set_skill(h.hero.skills.shardseed)
e = T("spear_durax")
get_damage(e.bullet)
set_damage_value(ss("damage"))
a = h.ranged.attacks[1]
cooldown = a.cooldown
map[_("HERO_ROOM_DURAX_SHARDSEED_NAME")] = string.format(_("HERO_ROOM_DURAX_SHARDSEED_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.lethal_prism)
a = h.timed_attacks.list[1]
cooldown = a.cooldown
get_damage(T("ray_durax").bullet)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
count = ss("ray_count")
map[_("HERO_ROOM_DURAX_LETHAL_PRISM_NAME")] = string.format(_("HERO_ROOM_DURAX_LETHAL_PRISM_DESC"), str(cooldown_str()), str(count), str(damage_str()))
set_skill(h.hero.skills.armsword)
a = h.melee.attacks[3]
cooldown = a.cooldown
get_damage(a)
set_damage_value(ss("damage"))
map[_("HERO_ROOM_DURAX_ARMSWORD_NAME")] = string.format(_("HERO_ROOM_DURAX_ARMSWORD_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.crystallites)
factor = s.damage_factor
duration = ss("duration")
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_DURAX_CRYSTALLITES_NAME")] = string.format(_("HERO_ROOM_DURAX_CRYSTALLITES_DESC"), str(cooldown_str()), str(duration), str(factor * 100))

set_skill(h.hero.skills.ultimate)
e = T("hero_durax_ultimate")
get_damage(e)
set_damage_value(ss("damage"))
radius = e.range
cooldown = h.ultimate.cooldown
e = T("mod_durax_slow")
factor = 1 - e.slow.factor
duration_2 = e.modifier.duration
e = T("mod_durax_stun")
duration = e.modifier.duration
map[_("HERO_ROOM_DURAX_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_DURAX_ULTIMATE_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(duration), str(factor * 100), str(duration_2))

set_hero("hero_elves_denas")
set_skill(h.hero.skills.shield_strike)
a = h.ranged.attacks[1]
cooldown = a.cooldown
e = E:get_template("shield_elves_denas")
get_damage(e.bullet)
range = e.rebound_range
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
count = ss("rebounds")
map[_("HERO_ROOM_ELVES_DENAS_SHIELD_STRIKE_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_SHIELD_STRIKE_DESC"), str(cooldown_str()), str(range), str(count), str(damage_str()))
set_skill(h.hero.skills.celebrity)
count = ss("max_targets")
duration = ss("stun_duration")
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_ELVES_DENAS_CELEBRITY_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_CELEBRITY_DESC"), str(cooldown_str()), str(count), str(duration))
set_skill(h.hero.skills.mighty)
a = h.melee.attacks[3]
cooldown = a.cooldown
get_damage(a)
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
map[_("HERO_ROOM_ELVES_DENAS_MIGHTY_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_MIGHTY_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
e = T("soldier_elves_denas_guard")
get_health(e)
get_damage(e.melee.attacks[1])
duration = e.reinforcement.duration
e = T("hero_elves_denas_ultimate")
count = e.guards_count[max_lvl]
map[_("HERO_ROOM_ELVES_DENAS_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(duration), str(health_str()), str(damage_str()))
count = h.wealthy.gold
map[_("HERO_ROOM_ELVES_DENAS_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_ULTIMATE_2_DESC"), str(count))
set_skill(h.hero.skills.sybarite)
heal = ss("heal_hp")
e = T("mod_elves_denas_sybarite")
factor = e.inflicted_damage_factor
duration = e.modifier.duration
cooldown = h.timed_attacks.list[2].cooldown
amount = h.timed_attacks.list[2].lost_health
map[_("HERO_ROOM_ELVES_DENAS_SYBARITE_NAME")] = string.format(_("HERO_ROOM_ELVES_DENAS_SYBARITE_DESC"), str(cooldown_str()), str(amount), str(heal), str(factor), str(duration))

set_hero("hero_arivan")
set_skill(h.hero.skills.lightning_rod)

a = h.ranged.attacks[2]
cooldown = a.cooldown
e = E:get_template("lightning_arivan")

get_damage(e.bullet)

d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_ARIVAN_LIGHTNING_ROD_NAME")] = string.format(_("HERO_ROOM_ARIVAN_LIGHTNING_ROD_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.stone_dance)

a = h.timed_attacks.list[2]
cooldown = a.cooldown
count = ss("count")
amount = ss("stone_extra")

local hp = E:get_template("arivan_stone").hp

map[_("HERO_ROOM_ARIVAN_STONE_DANCE_NAME")] = string.format(_("HERO_ROOM_ARIVAN_STONE_DANCE_DESC"), str(cooldown_str()), str(count), str(hp), str(amount))

set_skill(h.hero.skills.seal_of_fire)

a = h.timed_attacks.list[1]
count = ss("count") * #a.shoot_times
e = E:get_template("fireball_arivan")
radius = e.bullet.damage_radius
cooldown = a.cooldown

get_damage(e.bullet)

map[_("HERO_ROOM_ARIVAN_SEAL_OF_FIRE_NAME")] = string.format(_("HERO_ROOM_ARIVAN_SEAL_OF_FIRE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))

set_skill(h.hero.skills.icy_prison)

a = h.ranged.attacks[3]
cooldown = a.cooldown
e = E:get_template("bolt_freeze_arivan")

get_damage(e.bullet)
set_damage_value(ss("damage"))

duration = ss("duration")
map[_("HERO_ROOM_ARIVAN_ICY_PRISON_NAME")] = string.format(_("HERO_ROOM_ARIVAN_ICY_PRISON_DESC"), str(cooldown_str()), str(damage_str()), str(duration))

set_skill(h.hero.skills.ultimate)

cooldown = h.ultimate.cooldown
duration = ss("duration")
chance = ss("freeze_chance")
duration_2 = ss("freeze_duration")
chance_2 = ss("lightning_chance")
cycle_time = ss("lightning_cooldown")
e = E:get_template("hero_arivan_ultimate")

local cycle_time_2 = e.timed_attacks.list[2].cooldown
local cycle_time_3 = e.timed_attacks.list[3].cooldown

radius = e.timed_attacks.list[1].max_range
radius_2 = e.timed_attacks.list[2].max_range

get_damage(e.timed_attacks.list[2])
set_damage_value(ss("damage"))

radius_3 = e.timed_attacks.list[3].max_range

local radius_4 = e.timed_attacks.list[4].max_range

e = E:get_template("mod_slow")
factor = 1 - e.slow.factor
e = E:get_template("lightning_arivan_ultimate")

get_damage(e.bullet, 2)
set_damage_value(ss("damage"), 2)

map[_("HERO_ROOM_ARIVAN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_ARIVAN_ULTIMATE_DESC"), str(cooldown_str()), str(duration), str(radius), str(factor * 100), str(cycle_time_2), str(radius_2), str(damage_str()), str(radius_3), str(cycle_time_3), str(rate_str(chance)), str(duration_2), str(radius_4), str(cycle_time), str(rate_str(chance_2)), str(damage_str(2)))

set_hero("hero_phoenix")
set_skill(h.hero.skills.purification)
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = DAMAGE_TRUE
e = T("aura_phoenix_purification")
radius = e.aura.radius
map[_("HERO_ROOM_PHOENIX_PURIFICATION_NAME")] = string.format(_("HERO_ROOM_PHOENIX_PURIFICATION_DESC"), str(radius), str(damage_str()))
set_skill(h.hero.skills.inmolate)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
d[1].damage_type = h.selfdestruct.damage_type
radius = h.selfdestruct.damage_radius
cooldown = h.timed_attacks.list[1].cooldown
set_damage_value(h.hero.level_stats.egg_damage[#h.hero.level_stats.egg_damage], 2)
e = T("mod_phoenix_egg")
d[2].damage_type = e.dps.damage_type
cycle_time = e.dps.damage_every
e = T("aura_phoenix_egg")
d[3].damage_min = h.hero.level_stats.egg_explosion_damage_min[#h.hero.level_stats.egg_explosion_damage_min]
d[3].damage_max = h.hero.level_stats.egg_explosion_damage_max[#h.hero.level_stats.egg_explosion_damage_max]
d[3].damage_type = e.custom_attack.damage_type
radius_2 = e.aura.radius
radius_3 = e.custom_attack.radius
map[_("HERO_ROOM_PHOENIX_INMOLATE_NAME")] = string.format(_("HERO_ROOM_PHOENIX_INMOLATE_DESC"), str(radius), str(damage_str()), str(cycle_time), str(radius_2), str(damage_str(2)), str(radius_3), str(damage_str(3)), str(cooldown_str()))
set_skill(h.hero.skills.blazing_offspring)
e = T("missile_phoenix")
get_damage(e.bullet)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
count = ss("count")
cooldown = h.ranged.attacks[2].cooldown
map[_("HERO_ROOM_PHOENIX_BLAZING_OFFSPRING_NAME")] = string.format(_("HERO_ROOM_PHOENIX_BLAZING_OFFSPRING_DESC"), str(cooldown_str()), str(count), str(damage_str()))
set_skill(h.hero.skills.flaming_path)
set_damage_value(ss("damage"))
cooldown = h.timed_attacks.list[2].cooldown
e = T("mod_phoenix_flaming_path")
duration = e.modifier.duration
cycle_time = e.custom_attack.cooldown
radius = e.custom_attack.radius
d[1].damage_type = e.custom_attack.damage_type
map[_("HERO_ROOM_PHOENIX_FLAMING_PATH_NAME")] = string.format(_("HERO_ROOM_PHOENIX_FLAMING_PATH_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(radius), str(damage_str()))
set_skill(h.hero.skills.ultimate)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
cooldown = h.ultimate.cooldown
e = T("hero_phoenix_ultimate")
radius = e.aura.radius
duration = e.aura.duration
d[1].damage_type = e.aura.damage_type
map[_("HERO_ROOM_PHOENIX_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_PHOENIX_ULTIMATE_DESC"), str(cooldown_str()), str(duration), str(radius), str(damage_str()))

set_hero("hero_bravebark")
set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
e = E:get_template("hero_bravebark_ultimate")
get_damage(e)
radius = e.damage_radius
e = E:get_template("mod_bravebark_ultimate")
duration = e.modifier.duration
count = ss("count")
set_damage_value(ss("damage"))
map[_("HERO_ROOM_BRAVEBARK_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_BRAVEBARK_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()), str(duration))
set_skill(h.hero.skills.springsap)
duration = ss("duration")
amount = ss("hp_per_cycle")
cooldown = h.springsap.cooldown
factor = h.springsap.trigger_hp_factor
radius = h.springsap.radius
e = E:get_template("mod_bravebark_springsap")
cycle_time = e.hps.heal_every
map[_("HERO_ROOM_BRAVEBARK_SPRINGSAP_NAME")] = string.format(_("HERO_ROOM_BRAVEBARK_SPRINGSAP_DESC"), str(cooldown_str()), str(factor * 100), str(duration), str(radius), str(cycle_time), str(amount))
set_skill(h.hero.skills.oakseeds)
e = E:get_template("soldier_bravebark")
get_health(e)
health[1].hp_max = ss("soldier_hp_max")
get_damage(e.melee.attacks[1])
d[1].damage_max = ss("soldier_damage_max")
d[1].damage_min = ss("soldier_damage_min")
cooldown = h.timed_attacks.list[2].cooldown
count = h.timed_attacks.list[2].count
duration = e.reinforcement.duration
map[_("HERO_ROOM_BRAVEBARK_OAKSEEDS_NAME")] = string.format(_("HERO_ROOM_BRAVEBARK_OAKSEEDS_DESC"), str(cooldown_str()), str(count), str(health_str()), str(damage_str()), str(duration))
set_skill(h.hero.skills.rootspikes)
a = h.timed_attacks.list[1]
cooldown = a.cooldown
get_damage(a)
radius = a.damage_radius
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
count = a.trigger_count
map[_("HERO_ROOM_BRAVEBARK_ROOTSPIKES_NAME")] = string.format(_("HERO_ROOM_BRAVEBARK_ROOTSPIKES_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(count))
set_skill(h.hero.skills.branchball)
cooldown = h.melee.attacks[2].cooldown
map[_("HERO_ROOM_BRAVEBARK_BRANCHBALL_NAME")] = string.format(_("HERO_ROOM_BRAVEBARK_BRANCHBALL_DESC"), str(cooldown_str()))

set_hero("hero_catha")
set_skill(h.hero.skills.ultimate)
duration = ss("duration")
duration_2 = ss("duration_boss")
radius = ss("range")
cooldown = h.ultimate.cooldown
map[_("HERO_ROOM_CATHA_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_CATHA_ULTIMATE_DESC"), str(cooldown_str()), str(radius), str(duration), str(duration_2))
set_skill(h.hero.skills.curse)
chance = ss("chance")
duration = ss("duration")
factor = s.chance_factor_tale
map[_("HERO_ROOM_CATHA_CURSE_NAME")] = string.format(_("HERO_ROOM_CATHA_CURSE_DESC"), str(rate_str(chance)), str(duration), str(factor * 100))
set_skill(h.hero.skills.soul)
heal = ss("heal_hp")
cooldown = h.timed_attacks.list[2].cooldown
radius = h.timed_attacks.list[2].max_range
count = h.timed_attacks.list[2].max_count
map[_("HERO_ROOM_CATHA_SOUL_NAME")] = string.format(_("HERO_ROOM_CATHA_SOUL_DESC"), str(cooldown_str()), str(radius), str(count), str(heal))
set_skill(h.hero.skills.tale)
count = ss("max_count")
e = T("soldier_catha")
get_health(e)
health[1].hp_max = ss("hp_max")
cooldown = h.timed_attacks.list[3].cooldown
duration = e.reinforcement.duration
map[_("HERO_ROOM_CATHA_TALE_NAME")] = string.format(_("HERO_ROOM_CATHA_TALE_DESC"), str(cooldown_str()), str(count), str(health_str()), str(duration))
set_skill(h.hero.skills.fury)
e = T("catha_fury")
get_damage(e.bullet)
count = ss("count")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
cooldown = h.timed_attacks.list[1].cooldown
map[_("HERO_ROOM_CATHA_FURY_NAME")] = string.format(_("HERO_ROOM_CATHA_FURY_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_hero("hero_lilith")
set_skill(h.hero.skills.infernal_wheel)
a = h.timed_attacks.list[1]
cooldown = a.cooldown
get_damage(T("mod_lilith_infernal_wheel").dps)
cycle_time = T("mod_lilith_infernal_wheel").dps.damage_every
e = T("aura_lilith_infernal_wheel")
duration = e.aura.duration
radius = e.aura.radius
set_damage_value(ss("damage"))
map[_("HERO_ROOM_LILITH_INFERNAL_WHEEL_NAME")] = string.format(_("HERO_ROOM_LILITH_INFERNAL_WHEEL_DESC"), str(cooldown_str()), str(duration), str(radius), str(cycle_time), str(damage_str()))
set_skill(h.hero.skills.reapers_harvest)
chance = ss("instakill_chance")
a = h.melee.attacks[3]
cooldown = a.cooldown
get_damage(a)
set_damage_value(ss("damage"))
map[_("HERO_ROOM_LILITH_REAPERS_HARVEST_NAME")] = string.format(_("HERO_ROOM_LILITH_REAPERS_HARVEST_DESC"), str(cooldown_str()), str(damage_str()), str(rate_str(chance)))
set_skill(h.hero.skills.ultimate)
count = ss("angel_count")
e = T("soldier_lilith_angel")
count_2 = e.max_attack_count
get_damage(e.melee.attacks[1])
set_damage_value(ss("angel_damage"))
e = T("meteor_lilith")
get_damage(e.bullet, 2)
radius = e.bullet.damage_radius
e = T("mod_hero_elves_archer_slow")
factor = 1 - e.slow.factor
duration = e.modifier.duration
set_damage_value(ss("meteor_damage"), 2)
cooldown = h.ultimate.cooldown
e = T("hero_lilith_ultimate")
min_count = 1
local max_count = 1 + e.meteor_node_spread * 4
map[_("HERO_ROOM_LILITH_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_LILITH_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(count_2), str(damage_str()), str(min_count), str(max_count), str(radius), str(damage_str(2)), str(factor * 100), str(duration))
set_skill(h.hero.skills.soul_eater)
e = T("aura_lilith_soul_eater")
factor = ss("damage_factor")
cooldown = e.aura.cooldown
e = T("mod_lilith_soul_eater_damage_factor")
duration = e.modifier.duration
map[_("HERO_ROOM_LILITH_SOUL_EATER_NAME")] = string.format(_("HERO_ROOM_LILITH_SOUL_EATER_DESC"), str(cooldown_str()), str(factor * 100), str(duration))
set_skill(h.hero.skills.resurrection)
chance = ss(("chance"))
local cost = h.revive.resist.cost
duration = h.revive.resist.duration
map[_("HERO_ROOM_LILITH_RESURRECTION_NAME")] = string.format(_("HERO_ROOM_LILITH_RESURRECTION_DESC"), str(rate_str(chance)), str(cost * 100), str(duration))
map[_("HERO_ROOM_LILITH_RESURRECTION_2_NAME")] = _("HERO_ROOM_LILITH_RESURRECTION_2_DESC")
set_hero("hero_xin")
set_skill(h.hero.skills.inspire)

duration = ss("duration")
a = h.timed_attacks.list[2]
cooldown = a.cooldown
e = E:get_template("mod_xin_inspire")
factor = e.inflicted_damage_factor
map[_("HERO_ROOM_XIN_INSPIRE_NAME")] = string.format(_("HERO_ROOM_XIN_INSPIRE_DESC"), str(cooldown_str()), str(factor), str(duration))
a = h.timed_attacks.list[1]
cooldown = a.cooldown

get_damage(a)
set_skill(h.hero.skills.daring_strike)

d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_XIN_DARING_STRIKE_NAME")] = string.format(_("HERO_ROOM_XIN_DARING_STRIKE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.ultimate)

count = ss("count")
cooldown = h.ultimate.cooldown
e = E:get_template("soldier_xin_ultimate")

get_damage(e.melee.attacks[1])
set_damage_value(ss("damage"))

count_2 = e.max_attack_count
map[_("HERO_ROOM_XIN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_XIN_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(count_2), str(damage_str()))

set_skill(h.hero.skills.mind_over_body)

duration = ss("duration")
cycle_time = ss("heal_every")
heal = ss("heal_hp")
amount = ss("damage_buff")
a = h.timed_attacks.list[3]
cooldown = a.cooldown
factor = a.min_health_factor
map[_("HERO_ROOM_XIN_MIND_OVER_BODY_NAME")] = string.format(_("HERO_ROOM_XIN_MIND_OVER_BODY_DESC"), str(cooldown_str()), str(factor * 100), str(duration), str(amount), str(cycle_time), str(heal))

set_skill(h.hero.skills.panda_style)

a = h.melee.attacks[3]
cooldown = a.cooldown
radius = a.damage_radius

get_damage(a)

d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_XIN_PANDA_STYLE_NAME")] = string.format(_("HERO_ROOM_XIN_PANDA_STYLE_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_hero("hero_faustus")
set_skill(h.hero.skills.teleport_rune)
count = ss("max_targets")
a = h.ranged.attacks[3]
cooldown = a.cooldown
e = T("aura_teleport_faustus")
radius = e.aura.radius
e = T("mod_teleport_faustus")
set_damage_value(e.damage_base + e.damage_inc * max_lvl)
d[1].damage_type = e.damage_type
duration = e.delay_start
local nodes_offset = -e.nodes_offset
map[_("HERO_ROOM_FAUSTUS_TELEPORT_RUNE_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_TELEPORT_RUNE_DESC"), str(cooldown_str()), str(radius), str(count), str(duration), str(nodes_offset), str(damage_str()))
set_skill(h.hero.skills.ultimate)
e = T("mod_minidragon_faustus")
set_damage_value(ss("mod_damage"))
cycle_time = e.dps.damage_every
d[1].damage_type = e.dps.damage_type
cooldown = h.ultimate.cooldown
e = T("aura_minidragon_faustus")
duration = e.aura.duration
map[_("HERO_ROOM_FAUSTUS_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_ULTIMATE_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(damage_str()))
set_skill(h.hero.skills.dragon_lance)
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
a = h.ranged.attacks[2]
cooldown = a.cooldown
e = T("bolt_lance_faustus")
d[1].damage_type = e.bullet.damage_type
map[_("HERO_ROOM_FAUSTUS_DRAGON_LANCE_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_DRAGON_LANCE_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.liquid_fire)
count = ss("flames_count")
e = T("aura_liquid_fire_flame_faustus")
duration = e.aura.duration
e = T("mod_liquid_fire_faustus")
set_damage_value(ss("mod_damage"))
d[1].damage_type = e.dps.damage_type
cycle_time = e.dps.damage_every
a = h.ranged.attacks[5]
cooldown = a.cooldown
min_count = a.min_count
map[_("HERO_ROOM_FAUSTUS_LIQUID_FIRE_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_LIQUID_FIRE_DESC"), str(cooldown_str()), str(min_count), str(count), str(duration), str(cycle_time), str(damage_str()))
set_skill(h.hero.skills.enervation)
duration = ss("duration")
count = ss("max_targets")
a = h.ranged.attacks[4]
cooldown = a.cooldown
map[_("HERO_ROOM_FAUSTUS_ENERVATION_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_ENERVATION_DESC"), str(cooldown_str()), str(count), str(duration))
set_skill(h.hero.skills.urination)
count = ss("count")
map[_("HERO_ROOM_FAUSTUS_URINATION_NAME")] = string.format(_("HERO_ROOM_FAUSTUS_URINATION_DESC"), str(count))

set_hero("hero_rag")
-- 兔子
set_skill(h.hero.skills.kamihare)
a = h.timed_attacks.list[2]
cooldown = a.cooldown
e = T("aura_rabbit_kamihare")
get_damage(e.aura)
radius = e.aura.radius
count = ss("count")
map[_("HERO_ROOM_RAG_KAMIHARE_NAME")] = string.format(_("HERO_ROOM_RAG_KAMIHARE_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
-- 锤子
set_skill(h.hero.skills.hammer_time)
a = h.timed_attacks.list[3]
cooldown = a.cooldown
get_damage(a)
radius = a.damage_radius
duration = ss("duration")
cycle_time = a.damage_every
map[_("HERO_ROOM_RAG_HAMMER_TIME_NAME")] = string.format(_("HERO_ROOM_RAG_HAMMER_TIME_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(radius), str(damage_str()))
-- 扔东西
set_skill(h.hero.skills.angry_gnome)
a = h.timed_attacks.list[1]
cooldown = a.cooldown
get_damage(T("bullet_rag_throw").bullet)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
map[_("HERO_ROOM_RAG_ANGRY_GNOME_NAME")] = string.format(_("HERO_ROOM_RAG_ANGRY_GNOME_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.raggified)
a = h.timed_attacks.list[4]
cooldown = a.cooldown
amount = ss("max_target_hp")
duration = ss("doll_duration")
factor = ss("break_factor")
factor_2 = T("soldier_rag").health.damage_factor
map[_("HERO_ROOM_RAG_RAGGIFIED_NAME")] = string.format(_("HERO_ROOM_RAG_RAGGIFIED_DESC"), str(cooldown_str()), str(amount), str(factor_2), str(duration), str(factor * 100))
set_skill(h.hero.skills.ultimate)
count = ss("max_count")
map[_("HERO_ROOM_RAG_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_RAG_ULTIMATE_DESC"), str(cooldown_str()), str(count))

set_hero("hero_bruce")
set_skill(h.hero.skills.sharp_claws)
set_damage_value(ss("damage"), 1)
e = T("mod_bruce_sharp_claws")
cycle_time = e.dps.damage_every
d[1].damage_type = e.dps.damage_type
set_damage_value(ss("extra_damage"), 2)
d[2].damage_type = e.extra_bleeding_damage_type
a = h.melee.attacks[3]
chance = a.chance
duration = e.modifier.duration
map[_("HERO_ROOM_BRUCE_SHARP_CLAWS_NAME")] = string.format(_("HERO_ROOM_BRUCE_SHARP_CLAWS_DESC"), str(chance), str(duration), str(cycle_time), str(damage_str(1)), str(damage_str(2)))
set_skill(h.hero.skills.kings_roar)
duration = ss("stun_duration")
a = h.timed_attacks.list[1]
cooldown = a.cooldown
radius = a.range
min_count = a.min_count
map[_("HERO_ROOM_BRUCE_KINGS_ROAR_NAME")] = string.format(_("HERO_ROOM_BRUCE_KINGS_ROAR_DESC"), str(cooldown_str()), str(min_count), str(radius), str(duration))
set_skill(h.hero.skills.grievous_bites)
set_damage_value(ss("damage"))
a = h.melee.attacks[4]
cooldown = a.cooldown
d[1].damage_type = a.damage_type
count = #a.hit_times
map[_("HERO_ROOM_BRUCE_GRIEVOUS_BITES_NAME")] = string.format(_("HERO_ROOM_BRUCE_GRIEVOUS_BITES_DESC"), str(cooldown_str()), str(count), str(damage_str()))
set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
set_damage_value(ss("damage_per_tick"))
set_damage_value(ss("damage_boss"), 2)
e = T("lion_bruce")
d[2].damage_type = e.custom_attack.damage_type
e = T("mod_lion_bruce_damage")
duration = e.modifier.duration
d[1].damage_type = e.dps.damage_type
cycle_time = e.dps.damage_every
count = ss("count")
map[_("HERO_ROOM_BRUCE_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_BRUCE_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(duration), str(cycle_time), str(damage_str(1)), str(damage_str(2)))

set_hero("hero_bolverk")
set_skill(h.hero.skills.slash)
d[1].damage_max = ss("damage_max")
d[1].damage_min = ss("damage_min")
a = h.melee.attacks[2]
cooldown = a.cooldown
d[1].damage_type = a.damage_type
map[_("HERO_ROOM_BOLVERK_SLASH_NAME")] = string.format(_("HERO_ROOM_BOLVERK_SLASH_DESC"), str(cooldown_str()), str(damage_str()))
set_skill(h.hero.skills.scream)
a = h.timed_attacks.list[1]
set_damage_value(ss("fire_damage"))
cooldown = a.cooldown
e = T("mod_bolverk_scream")
duration = e.modifier.duration
factor = e.received_damage_factor
factor_2 = e.inflicted_damage_factor
e = T("mod_bolverk_fire")
duration_2 = e.modifier.duration
cycle_time = e.dps.damage_every
d[1].damage_type = e.dps.damage_type
radius = a.max_range
map[_("HERO_ROOM_BOLVERK_SCREAM_NAME")] = string.format(_("HERO_ROOM_BOLVERK_SCREAM_DESC"), str(cooldown_str()), str(radius), str(duration_2), str(cycle_time), str(damage_str()), str(factor), str(factor_2), str(duration))
set_skill(h.hero.skills.berserker)
factor = ss("factor")
map[_("HERO_ROOM_BOLVERK_BERSERKER_NAME")] = string.format(_("HERO_ROOM_BOLVERK_BERSERKER_DESC"), str(factor * 100))

set_hero("hero_vesper")
cooldown = table.tail({15, 13, 11})
d[1].damage_max = table.tail({72, 144, 216})
d[1].damage_min = table.tail({54, 108, 162})
d[1].damage_type = DAMAGE_TRUE
duration = table.tail({1, 1.5, 2})
local distance = T("hero_vesper_arrow_to_the_knee_arrow").bullet.straight_forward_distance
map[_("HERO_ROOM_VESPER_BERSERKER_NAME")] = string.format(_("HERO_ROOM_VESPER_BERSERKER_DESC"), str(cooldown_str()), str(distance), str(damage_str()), str(duration))
count = table.tail({3, 5, 7})
d[1].damage_max = table.tail({45, 50, 55})
d[1].damage_min = table.tail({45, 50, 55})
d[1].damage_type = DAMAGE_PHYSICAL
cooldown = table.tail({15, 13, 11})
factor = 0.7
duration = 2
map[_("HERO_ROOM_VESPER_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_VESPER_BERSERKER_2_DESC"), str(cooldown_str()), str(damage_str()), str(count), str(duration), str(factor * 100))
count = 3
cooldown = table.tail({16, 14, 12})
d[1].damage_max = table.tail({60, 110, 160})
d[1].damage_min = table.tail({60, 110, 160})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_VESPER_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_VESPER_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(damage_str()))
cooldown = table.tail({16, 14, 12})
d[1].damage_max = table.tail({50, 80, 120})
d[1].damage_min = table.tail({50, 80, 120})
d[1].damage_type = DAMAGE_PHYSICAL
count = #h.melee.attacks[3].hit_times
map[_("HERO_ROOM_VESPER_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_VESPER_BERSERKER_4_DESC"), str(cooldown_str()), str(count), str(damage_str()))
radius = 100
count = table.tail({8, 10, 12, 14}) * 2
duration = 1
radius_2 = 40
d[1].damage_type = DAMAGE_TRUE
factor = 0.5
set_damage_value(table.tail({26, 32, 39, 45}))
cooldown = table.tail({40, 40, 40, 40})
map[_("HERO_ROOM_VESPER_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_VESPER_BERSERKER_5_DESC"), str(cooldown_str()), str(radius), str(count), str(radius_2), str(damage_str()), str(factor * 100), str(duration))

set_hero("hero_hunter")
radius = 80
cooldown = table.tail({20, 20, 20})
d[1].damage_type = DAMAGE_TRUE
d[1].damage_max = table.tail({6, 7, 8})
d[1].damage_min = table.tail({3, 4, 5})
factor = 0.7
duration = table.tail({3, 3.5, 4})
cycle_time = fts(3)
map[_("HERO_ROOM_HUNTER_BERSERKER_NAME")] = string.format(_("HERO_ROOM_HUNTER_BERSERKER_DESC"), str(cooldown_str()), str(radius), str(duration), str(factor * 100), str(cycle_time), str(damage_str()))
d[1].damage_type = DAMAGE_TRUE
d[1].damage_max = table.tail({40, 52, 64})
d[1].damage_min = table.tail({28, 40, 52})
factor = table.tail({0.08, 0.12, 0.16})
map[_("HERO_ROOM_HUNTER_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_HUNTER_BERSERKER_2_DESC"), str(damage_str()), str(factor * 100))
cooldown = table.tail({18, 18, 18})
cooldown_2 = 0.5
d[1].damage_max = table.tail({10, 20, 30})
d[1].damage_min = table.tail({6, 12, 18})
duration = table.tail({8, 10, 12})
amount = table.tail({1, 2, 3})
d[1].damage_type = DAMAGE_RUDE
chance = 0.25
map[_("HERO_ROOM_HUNTER_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_HUNTER_BERSERKER_3_DESC"), str(cooldown_str()), str(duration), str(damage_str()), str(chance * 100), str(amount))
cooldown = table.tail({15, 15, 15})
d[1].damage_type = DAMAGE_RUDE
d[1].damage_max = table.tail({43, 77, 105})
d[1].damage_min = table.tail({27, 52, 72})
count = table.tail({2, 3, 4}) + 1
map[_("HERO_ROOM_HUNTER_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_HUNTER_BERSERKER_4_DESC"), str(cooldown_str()), str(count), str(damage_str()))
cooldown = table.tail({50, 50, 50, 50})
duration = 12
factor = 0.5
radius = 80
factor_2 = table.tail({2, 2.5, 3, 3.5})
d[1].damage_max = table.tail({11, 19, 30, 42})
d[1].damage_min = table.tail({7, 14, 19, 28})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_HUNTER_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_HUNTER_BERSERKER_5_DESC"), str(cooldown_str()), str(duration), str(damage_str()), str(radius), str(factor * 100), str(factor_2), str(duration))

set_hero("hero_raelyn")
cooldown = table.tail({48, 48, 48, 48})
duration = 20
d[1].damage_type = DAMAGE_TRUE
d[1].damage_max = table.tail({15, 23, 31, 44})
d[1].damage_min = table.tail({10, 15, 20, 28})
health[1].hp_max = table.tail({156, 260, 364, 468})
health[1].armor = table.tail({0.3, 0.4, 0.55, 0.7})
health[1].magic_armor = 0
map[_("HERO_ROOM_RAELYN_BERSERKER_NAME")] = string.format(_("HERO_ROOM_RAELYN_BERSERKER_DESC"), str(cooldown_str()), str(duration), str(health_str()), str(damage_str()))
cooldown = table.tail({20, 19, 18})
d[1].damage_min = table.tail({180, 360, 540})
d[1].damage_max = table.tail({180, 360, 540})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_RAELYN_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_RAELYN_BERSERKER_2_DESC"), str(cooldown_str()), str(damage_str()))
min_count = 2
duration = table.tail({6, 8, 10})
cooldown = table.tail({24, 20, 18})
factor = 0.4
factor_2 = 0.8
map[_("HERO_ROOM_RAELYN_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_RAELYN_BERSERKER_3_DESC"), str(cooldown_str()), str(min_count), str(duration), str(factor * 100), str((1 - factor_2) * 100))
cooldown = table.tail({21, 21, 21})
factor = table.tail({0.6, 0.4, 0.2})
duration = table.tail({2, 2.5, 3})
duration_2 = table.tail({6, 6, 6})
radius = 120
set_damage_value(table.tail({45, 60, 75}))
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_RAELYN_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_RAELYN_BERSERKER_4_DESC"), str(cooldown_str()), str(radius), str(duration), str(damage_str()), str(factor * 100), str(duration_2))
cooldown = table.tail({25, 25, 25})
count = 4
amount = table.tail({0.2, 0.2, 0.2})
amount_2 = table.tail({0.1, 0.15, 0.2})
radius = 140
duration = table.tail({6, 6, 6})
factor = 0.6
map[_("HERO_ROOM_RAELYN_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_RAELYN_BERSERKER_5_DESC"), str(cooldown_str()), str(count), str(duration), str(amount), str(amount_2), str(count), str(factor * 100))

set_hero("hero_muyrn")
radius = 50
cycle_time = 0.25
cycle_time_2 = 0.25
cooldown = table.tail({25, 23.5, 21})
duration = table.tail({8, 8, 8})
d[1].damage_type = DAMAGE_STAB
d[1].damage_max = table.tail({4, 8, 12})
d[1].damage_min = table.tail({2, 4, 6})
amount = table.tail({3, 4, 5})
amount_2 = table.tail({2, 3, 4})
map[_("HERO_ROOM_MUYRN_BERSERKER_NAME")] = string.format(_("HERO_ROOM_MUYRN_BERSERKER_DESC"), str(cooldown_str()), str(duration), str(cycle_time), str(amount_2), str(amount), str(cycle_time_2), str(radius), str(damage_str()))
radius = 80
cooldown = table.tail({14, 14, 14})
duration = table.tail({5, 6, 8})
factor = table.tail({0.4, 0.25, 0.1})
map[_("HERO_ROOM_MUYRN_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_MUYRN_BERSERKER_2_DESC"), str(cooldown_str()), str(radius), str(factor), str(duration))
cooldown = table.tail({17.5, 17.5, 17.5})
count = table.tail({1, 2, 3})
duration = table.tail({6, 6, 6})
d[1].damage_max = table.tail({6, 12, 18})
d[1].damage_min = table.tail({3, 6, 9})
d[1].damage_type = DAMAGE_MAGICAL
map[_("HERO_ROOM_MUYRN_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_MUYRN_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(duration), str(damage_str()))
cooldown = table.tail({22.5, 22.5, 22.5})
d[1].damage_max = table.tail({150, 300, 450})
d[1].damage_min = table.tail({150, 300, 450})
d[1].damage_type = DAMAGE_MAGICAL_EXPLOSION
map[_("HERO_ROOM_MUYRN_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_MUYRN_BERSERKER_4_DESC"), str(cooldown_str()), str(damage_str()))
radius = 60
cycle_time = 0.25
cooldown = table.tail({32, 32, 32, 32})
factor = table.tail({0.6, 0.6, 0.6, 0.6})
duration = table.tail({4, 5, 6, 7})
d[1].damage_max = table.tail({6, 7, 9, 11})
d[1].damage_min = table.tail({4, 5, 6, 7})
d[1].damage_type = DAMAGE_TRUE
count = table.tail({10, 15, 20, 25})
map[_("HERO_ROOM_MUYRN_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_MUYRN_BERSERKER_5_DESC"), str(cooldown_str()), str(count), str(radius), str(factor * 100), str(cycle_time), str(damage_str()), str(duration))

set_hero("hero_space_elf")
cooldown = table.tail({25, 25, 25})
health[1].hp_max = table.tail({247, 286, 325})
health[1].armor = 0
health[1].magic_armor = 0
d[1].damage_max = table.tail({36, 47, 62})
d[1].damage_min = table.tail({19, 26, 33})
d[1].damage_type = DAMAGE_MAGICAL
duration = 12
map[_("HERO_ROOM_SPACE_ELF_BERSERKER_NAME")] = string.format(_("HERO_ROOM_SPACE_ELF_BERSERKER_DESC"), str(cooldown_str()), str(duration), str(health_str()), str(damage_str()))
radius = 120
cycle_time = 0.25
cooldown = table.tail({30, 25, 20})
duration = table.tail({6, 8, 10})
count = table.tail({1, 2, 3})
d[1].damage_max = table.tail({6, 6, 6})
d[1].damage_min = table.tail({3, 3, 3})
d[1].damage_type = DAMAGE_MAGICAL_EXPLOSION
factor = 0.8
map[_("HERO_ROOM_SPACE_ELF_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_SPACE_ELF_BERSERKER_2_DESC"), str(cooldown_str()), str(count), str(duration), str(radius), str(factor * 100), str(cycle_time), str(damage_str()))
radius = 80
cooldown = table.tail({18, 16, 14})
duration = table.tail({6, 8, 10})
amount = table.tail({50, 85, 120})
set_damage_value(table.tail({25, 50, 75}))
d[1].damage_type = DAMAGE_MAGICAL_EXPLOSION
map[_("HERO_ROOM_SPACE_ELF_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_SPACE_ELF_BERSERKER_3_DESC"), str(cooldown_str()), str(amount), str(duration), str(radius), str(damage_str()))
cooldown = table.tail({25, 23, 20})
duration = table.tail({6, 7, 8})
factor = table.tail({1.04, 1.06, 1.08})
factor_2 = table.tail({1.04, 1.06, 1.08})
factor_3 = table.tail({0.96, 0.94, 0.92})
map[_("HERO_ROOM_SPACE_ELF_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_SPACE_ELF_BERSERKER_4_DESC"), str(cooldown_str()), str(factor * 100), str(factor_2 * 100 - 100), str(factor_3 * 100), str(duration))
cooldown = table.tail({45, 45, 45, 45})
duration = table.tail({5, 6, 7, 8})
set_damage_value(table.tail({39, 117, 234, 351}))
d[1].damage_type = DAMAGE_TRUE
radius = 90
map[_("HERO_ROOM_SPACE_ELF_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_SPACE_ELF_BERSERKER_5_DESC"), str(cooldown_str()), str(radius), str(duration), str(damage_str()))

set_hero("hero_venom")
cooldown = table.tail({10, 9, 8})
d[1].damage_min = table.tail({30, 60, 90})
d[1].damage_max = table.tail({30, 60, 90})
d[1].damage_type = DAMAGE_RUDE
local bleed_every_val = table.tail({0.25, 0.25, 0.25})
local bleed_dmg_val = table.tail({3, 4, 5})
local bleed_dur_val = table.tail({4, 4, 4})
map[_("HERO_ROOM_VENOM_BERSERKER_NAME")] = string.format(_("HERO_ROOM_VENOM_BERSERKER_DESC"), str(cooldown_str()), str(damage_str()), str(bleed_every_val), str(bleed_dmg_val), str(bleed_dur_val))
cooldown = table.tail({35, 35, 35})
duration = 10
local trigger_hp_val = 0.5 * 100
local s_dmg_factor_val = table.tail({1.25, 1.5, 1.75}) * 100 - 100
local regen_health_val = 0.1 * 100
map[_("HERO_ROOM_VENOM_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_VENOM_BERSERKER_2_DESC"), str(cooldown_str()), str(trigger_hp_val), str(duration), str(s_dmg_factor_val), str(regen_health_val))
cooldown = table.tail({30, 30, 30})
count = table.tail({15, 15, 15})
d[1].damage_min = table.tail({20, 40, 60})
d[1].damage_max = table.tail({20, 40, 60})
d[1].damage_type = DAMAGE_TRUE
radius = 35
map[_("HERO_ROOM_VENOM_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_VENOM_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
cooldown = table.tail({55, 50, 45})
local eat_hp_trigger_val = 0.3 * 100
local eat_regen_val = table.tail({0.1, 0.15, 0.2}) * 100
set_damage_value(table.tail({40, 50, 60}))
d[1].damage_type = DAMAGE_RUDE
map[_("HERO_ROOM_VENOM_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_VENOM_BERSERKER_4_DESC"), str(eat_hp_trigger_val), str(damage_str()), str(eat_regen_val), str(cooldown))
cooldown = table.tail({50, 50, 50, 50})
radius = 70
factor = 0.5 * 100
duration = table.tail({3, 3, 3, 3})
d[1].damage_min = table.tail({190, 250, 315, 370})
d[1].damage_max = table.tail({190, 250, 315, 370})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_VENOM_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_VENOM_BERSERKER_5_DESC"), str(cooldown_str()), str(radius), str(factor), str(duration), str(damage_str()))

set_hero("hero_dragon_gem")
cooldown = table.tail({16, 16, 16})
radius = 80
duration = table.tail({2, 3, 4})
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_DESC"), str(cooldown_str()), str(radius), str(duration))
cooldown = table.tail({25, 25, 25})
radius = 50
d[1].damage_min = table.tail({31, 62, 93})
d[1].damage_max = table.tail({46, 93, 140})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_2_DESC"), str(cooldown_str()), str(radius), str(damage_str()))
cooldown = table.tail({35, 35, 35})
local instakill_hp_val = table.tail({260, 520, 1040})
d[1].damage_min = table.tail({41, 98, 124})
d[1].damage_max = table.tail({41, 98, 124})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_3_DESC"), str(cooldown_str()), str(instakill_hp_val), str(damage_str()))
cooldown = table.tail({20, 20, 20})
radius = 80
factor = 0.75 * 100
cycle_time = fts(30)
duration = table.tail({6, 8, 10})
d[1].damage_max = table.tail({10, 20, 32})
d[1].damage_min = table.tail({10, 20, 32})
d[1].damage_type = DAMAGE_MAGICAL
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_4_DESC"), str(cooldown_str()), str(duration), str(radius), str(factor), str(cycle_time), str(damage_str()))
cooldown = table.tail({45, 45, 45, 45})
count = table.tail({3, 4, 6, 8})
radius = 30
d[1].damage_min = table.tail({62, 93, 114, 135})
d[1].damage_max = table.tail({93, 140, 171, 202})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_5_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()))
amount = 250
factor = 3
map[_("HERO_ROOM_DRAGON_GEM_BERSERKER_6_NAME")] = string.format(_("HERO_ROOM_DRAGON_GEM_BERSERKER_6_DESC"), str(amount), str(factor))

set_hero("hero_witch")
cooldown = table.tail({20, 20, 20})
duration = table.tail({8, 8, 8})
local poly_hp_val = table.tail({1000, 2000, 3000})
factor = table.tail({0.7, 0.55, 0.4})
speed = 20
map[_("HERO_ROOM_WITCH_BERSERKER_NAME")] = string.format(_("HERO_ROOM_WITCH_BERSERKER_DESC"), str(cooldown_str()), str(poly_hp_val), str(duration), str(factor * 100), str(speed))
cooldown = table.tail({12, 12, 12})
local decoy_hp_val = table.tail({65, 97, 130})
local stun_dur_val = table.tail({2, 2.5, 3})
map[_("HERO_ROOM_WITCH_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_WITCH_BERSERKER_2_DESC"), str(cooldown_str()), str(decoy_hp_val), str(stun_dur_val))
cooldown = table.tail({17.5, 17.5, 17.5})
count = table.tail({2, 3, 4})
duration = 8
health[1].hp_max = table.tail({60, 85, 110})
health[1].armor = 0
health[1].magic_armor = 0
d[1].damage_min = table.tail({2, 5, 7})
d[1].damage_max = table.tail({3, 7, 11})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_WITCH_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_WITCH_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(duration), str(hp_str()), str(damage_str()))
cooldown = table.tail({16, 16, 16})
duration = table.tail({5, 6, 8})
factor = 0.5 * 100
d[1].damage_max = table.tail({65, 104, 156})
d[1].damage_min = table.tail({65, 104, 156})
d[1].damage_type = DAMAGE_MAGICAL_EXPLOSION
map[_("HERO_ROOM_WITCH_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_WITCH_BERSERKER_4_DESC"), str(cooldown_str()), str(damage_str()), str(factor), str(duration))
radius = 100
cooldown = table.tail({27, 27, 27, 27})
count = table.tail({4, 6, 8, 10})
duration = table.tail({3, 4, 5, 6})
amount = 20
map[_("HERO_ROOM_WITCH_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_WITCH_BERSERKER_5_DESC"), str(cooldown_str()), str(radius), str(count), str(amount), str(duration))

set_hero("hero_dragon_bone")
cooldown = table.tail({20, 20, 20})
count = table.tail({4, 6, 8})
stun_dur_val = 0.25
d[1].damage_min = table.tail({15, 31, 46})
d[1].damage_max = table.tail({23, 46, 70})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_DESC"), str(cooldown_str()), str(count), str(damage_str()), str(stun_dur_val))
cooldown = table.tail({15, 15, 15})
radius = 100
factor = 0.5 * 100
duration = table.tail({4, 6, 10})
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_2_DESC"), str(cooldown_str()), str(duration), str(radius), str(factor))
cooldown = table.tail({32, 32, 32})
count = table.tail({6, 8, 10})
d[1].damage_min = table.tail({31, 75, 112})
d[1].damage_max = table.tail({46, 112, 169})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(damage_str()))
cooldown = table.tail({24, 24, 24})
radius = 75
d[1].damage_min = table.tail({26, 80, 109})
d[1].damage_max = table.tail({52, 153, 202})
d[1].damage_type = DAMAGE_EXPLOSION
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_4_DESC"), str(cooldown_str()), str(radius), str(damage_str()))
cooldown = table.tail({36, 36, 36, 36})
health[1].hp_max = table.tail({130, 156, 195, 234})
health[1].armor = 0
health[1].magic_armor = 0
duration = table.tail({10, 15, 20, 25})
d[1].damage_min = table.tail({13, 14, 18, 27})
d[1].damage_max = table.tail({18, 22, 28, 40})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_5_DESC"), str(cooldown_str()), str(hp_str()), str(duration), str(damage_str()))
cycle_time = 0.25
d[1].damage_min = 1
d[1].damage_max = 1
duration = 4
d[2].damage_min = 15
d[2].damage_max = 30
d[2].damage_type = DAMAGE_EXPLOSION
radius = 60
map[_("HERO_ROOM_DRAGON_BONE_BERSERKER_6_NAME")] = string.format(_("HERO_ROOM_DRAGON_BONE_BERSERKER_6_DESC"), str(duration), str(cycle_time), str(damage_str()), str(duration), str(radius), str(damage_str(2)))

set_hero("hero_lumenir")
cooldown = table.tail({20, 20, 20})
count = table.tail({5, 6, 7})
duration = 8
d[1].damage_min = table.tail({1, 2, 4})
d[1].damage_max = table.tail({3, 6, 8})
d[1].damage_type = DAMAGE_TRUE
cycle_time = 0.25
radius = 55
map[_("HERO_ROOM_LUMENIR_BERSERKER_NAME")] = string.format(_("HERO_ROOM_LUMENIR_BERSERKER_DESC"), str(cooldown_str()), str(count), str(duration), str(cycle_time), str(radius), str(damage_str()))
cooldown = table.tail({30, 30, 30})
duration = table.tail({10, 12, 15})
d[1].damage_min = table.tail({13, 20, 24})
d[1].damage_max = table.tail({18, 31, 37})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_LUMENIR_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_LUMENIR_BERSERKER_2_DESC"), str(cooldown_str()), str(duration), str(damage_str()))
cooldown = table.tail({20, 20, 20})
radius = 300
local shield_armor_val = table.tail({0.1, 0.2, 0.3}) * 100
local spiked_armor_val = table.tail({0.2, 0.4, 0.6}) * 100
duration = table.tail({8, 8, 8})
map[_("HERO_ROOM_LUMENIR_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_LUMENIR_BERSERKER_3_DESC"), str(cooldown_str()), str(radius), str(duration), str(shield_armor_val), str(spiked_armor_val))
cooldown = table.tail({32, 32, 32})
radius = 40
set_damage_value(table.tail({240, 480, 720}))
d[1].damage_type = DAMAGE_TRUE
duration = table.tail({2, 2, 2})
map[_("HERO_ROOM_LUMENIR_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_LUMENIR_BERSERKER_4_DESC"), str(cooldown_str()), str(damage_str()), str(radius), str(duration))
cooldown = table.tail({30, 30, 30, 30})
count = table.tail({3, 3, 3, 3})
d[1].damage_min = table.tail({13, 19, 32, 51})
d[1].damage_max = table.tail({19, 29, 48, 77})
d[1].damage_type = DAMAGE_TRUE
count = 2
local lumenir_stun_val = 5
map[_("HERO_ROOM_LUMENIR_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_LUMENIR_BERSERKER_5_DESC"), str(cooldown_str()), str(count), str(count), str(damage_str()), str(lumenir_stun_val))

set_hero("hero_wukong")
health[1].hp_max = table.tail({78, 117, 182})
health[1].armor = 0
health[1].magic_armor = 0
d[1].damage_min = table.tail({3, 5, 10})
d[1].damage_max = table.tail({4, 7, 15})
d[1].damage_type = DAMAGE_PHYSICAL
local smash_min_val = table.tail({39, 71, 97})
local smash_max_val = table.tail({45, 91, 117})
local smash_chance_val = table.tail({0.3, 0.4, 0.5}) * 100
local smash_radius_val = 72
map[_("HERO_ROOM_WUKONG_BERSERKER_NAME")] = string.format(_("HERO_ROOM_WUKONG_BERSERKER_DESC"), str(hp_str()), str(damage_str()), str(smash_chance_val), str(smash_radius_val), str(smash_min_val), str(smash_max_val))
cooldown = table.tail({24, 22, 20})
duration = table.tail({9, 9, 9})
health[1].hp_max = table.tail({104, 130, 156})
health[1].armor = 0
health[1].magic_armor = 0
d[1].damage_min = table.tail({4, 8, 12})
d[1].damage_max = table.tail({5, 10, 15})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_WUKONG_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_WUKONG_BERSERKER_2_DESC"), str(cooldown_str()), str(hp_str()), str(duration), str(damage_str()))
cooldown = table.tail({17, 17, 17})
count = table.tail({3, 5, 7})
radius = 50
d[1].damage_min = table.tail({13, 18, 23})
d[1].damage_max = table.tail({19, 32, 39})
d[1].damage_type = DAMAGE_PHYSICAL
local pole_stun_val = 3
map[_("HERO_ROOM_WUKONG_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_WUKONG_BERSERKER_3_DESC"), str(cooldown_str()), str(count), str(radius), str(damage_str()), str(pole_stun_val))
cooldown = table.tail({50.5, 47.5, 44})
radius = 90
d[1].damage_min = table.tail({120, 160, 200})
d[1].damage_max = table.tail({140, 200, 260})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_WUKONG_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_WUKONG_BERSERKER_4_DESC"), str(cooldown_str()), str(radius), str(damage_str()))
cooldown = table.tail({42, 42, 42, 42})
set_damage_value(table.tail({260, 390, 520, 650}))
d[1].damage_type = DAMAGE_TRUE
factor = table.tail({0.5, 0.5, 0.5, 0.5}) * 100
duration = table.tail({3, 3.5, 4, 4.5})
map[_("HERO_ROOM_WUKONG_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_WUKONG_BERSERKER_5_DESC"), str(cooldown_str()), str(damage_str()), str(factor), str(duration))

set_hero("hero_dragon_arb")
local spawn_cooldown = table.tail({35, 35, 35})
local spawn_count_max = 3
local arb_hp = table.tail({104, 143, 182})
local arb_duration = table.tail({10, 12, 14})
health[1].hp_max = arb_hp
health[1].armor = 0
health[1].magic_armor = 0
d[1].damage_min = table.tail({2, 3, 5})
d[1].damage_max = table.tail({4, 6, 8})
d[1].damage_type = DAMAGE_PHYSICAL
local paragon_hp = table.tail({156, 208, 260})
local paragon_duration = table.tail({10, 12, 14})
health[2].hp_max = paragon_hp
health[2].armor = 0
health[2].magic_armor = 0
d[2].damage_min = table.tail({8, 12, 16})
d[2].damage_max = table.tail({12, 16, 20})
d[2].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_DRAGON_ARB_BERSERKER_NAME")] = string.format(_("HERO_ROOM_DRAGON_ARB_BERSERKER_DESC"), str(spawn_cooldown), str(spawn_count_max), str(hp_str()), str(arb_duration), str(damage_str()), str(hp_str(2)), str(paragon_duration), str(damage_str(2)))

cooldown = table.tail({35, 35, 35})
local runes_count = table.tail({3, 3, 3})
local runes_duration = table.tail({6, 7, 8})
local runes_factor = table.tail({0.3, 0.45, 0.6}) * 100
map[_("HERO_ROOM_DRAGON_ARB_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_DRAGON_ARB_BERSERKER_2_DESC"), str(cooldown_str()), str(runes_count), str(runes_factor), str(runes_duration))

cooldown = table.tail({12, 10, 8})
local bleed_ratio = table.tail({0.375, 0.564, 0.825})
local bleed_every = 0.75
local bleed_duration = table.tail({5, 5, 5})
local instakill_chance = table.tail({0.3, 0.3, 0.3}) * 100
map[_("HERO_ROOM_DRAGON_ARB_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_DRAGON_ARB_BERSERKER_3_DESC"), str(cooldown_str()), str(bleed_duration), str(bleed_every), str(bleed_ratio), str(instakill_chance))

cooldown = table.tail({20, 20, 20})
local plants_count = table.tail({1, 2, 3})
local plants_duration = table.tail({8, 10, 12})
local dark_slow = table.tail({0.5, 0.4, 0.3}) * 100
d[1].damage_min = table.tail({5, 7, 9})
d[1].damage_max = table.tail({5, 7, 9})
d[1].damage_type = DAMAGE_MAGICAL
local linirea_heal = table.tail({15, 15, 15})
map[_("HERO_ROOM_DRAGON_ARB_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_DRAGON_ARB_BERSERKER_4_DESC"), str(cooldown_str()), str(plants_count), str(plants_duration), str(linirea_heal), str(damage_str()), str(dark_slow))

cooldown = table.tail({36, 36, 36, 36})
local ult_duration = table.tail({8, 10, 13, 15})
local ult_bonus = table.tail({0.3, 0.4, 0.5, 0.6}) * 100
map[_("HERO_ROOM_DRAGON_ARB_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_DRAGON_ARB_BERSERKER_5_DESC"), str(cooldown_str()), str(ult_duration), str(ult_bonus))

set_hero("hero_builder")
health[1].hp_max = table.tail({50, 75, 100})
health[1].armor = 0.15
health[1].magic_armor = 0
d[1].damage_min = table.tail({2, 4, 6})
d[1].damage_max = table.tail({4, 8, 12})
d[1].damage_type = DAMAGE_PHYSICAL
local ow_duration = 12
cooldown = table.tail({11, 11, 11})
map[_("HERO_ROOM_BUILDER_BERSERKER_NAME")] = string.format(_("HERO_ROOM_BUILDER_BERSERKER_DESC"), str(cooldown_str()), str(hp_str()), str(ow_duration), str(damage_str()))

cooldown = table.tail({30, 28, 26})
local heal_val = table.tail({125, 250, 375})
local lost_health_val = 0.4 * 100
map[_("HERO_ROOM_BUILDER_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_BUILDER_BERSERKER_2_DESC"), str(cooldown_str()), str(lost_health_val), str(heal_val))

cooldown = table.tail({16, 16, 16})
local demo_duration = table.tail({1.25, 1.25, 1.25})
d[1].damage_min = table.tail({5, 10, 15})
d[1].damage_max = table.tail({8, 16, 24})
d[1].damage_type = DAMAGE_PHYSICAL
cycle_time = 0.25
radius = 100
map[_("HERO_ROOM_BUILDER_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_BUILDER_BERSERKER_3_DESC"), str(cooldown_str()), str(demo_duration), str(cycle_time), str(radius), str(damage_str()))

cooldown = table.tail({30, 30, 30})
local turret_duration = table.tail({12, 13.5, 15})
d[1].damage_min = table.tail({8, 16, 24})
d[1].damage_max = table.tail({12, 24, 36})
d[1].damage_type = DAMAGE_PHYSICAL
duration = 0.25
map[_("HERO_ROOM_BUILDER_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_BUILDER_BERSERKER_4_DESC"), str(cooldown_str()), str(turret_duration), str(damage_str()), str(duration))

cooldown = table.tail({35, 35, 35, 35})
set_damage_value(table.tail({120, 180, 240, 300}))
d[1].damage_type = DAMAGE_AGAINST_ARMOR
local stun_val = table.tail({2, 2, 2, 2})
map[_("HERO_ROOM_BUILDER_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_BUILDER_BERSERKER_5_DESC"), str(cooldown_str()), str(damage_str()), str(stun_val))

set_hero("hero_robot")
cooldown = table.tail({15, 14, 13, 12})
d[1].damage_min = table.tail({30, 60, 90, 120})
d[1].damage_max = table.tail({30, 60, 90, 120})
d[1].damage_type = DAMAGE_PHYSICAL
local stun_dur = table.tail({2, 2, 2, 2})
local jump_radius = 100
loop = table.tail({1, 2, 3, 4})
map[_("HERO_ROOM_ROBOT_BERSERKER_NAME")] = string.format(_("HERO_ROOM_ROBOT_BERSERKER_DESC"), str(cooldown_str()), str(loop), str(jump_radius), str(damage_str()), str(stun_dur))

cooldown = table.tail({20, 20, 20})
d[1].damage_min = table.tail({20, 40, 60})
d[1].damage_max = table.tail({40, 80, 120})
d[1].damage_type = DAMAGE_TRUE
factor = 0.5
duration = table.tail({5, 5, 5})
map[_("HERO_ROOM_ROBOT_BERSERKER_2_NAME")] = string.format(_("HERO_ROOM_ROBOT_BERSERKER_2_DESC"), str(cooldown_str()), str(duration), str(damage_str()), str(factor))

cooldown = table.tail({20, 19, 18})
d[1].damage_min = table.tail({30, 60, 90})
d[1].damage_max = table.tail({40, 80, 120})
d[1].damage_type = DAMAGE_EXPLOSION
local burn_dur = 4
d[2].damage_min = table.tail({1, 2, 3})
d[2].damage_max = table.tail({1, 2, 3})
d[2].damage_type = DAMAGE_TRUE
cycle_time = 0.25
map[_("HERO_ROOM_ROBOT_BERSERKER_3_NAME")] = string.format(_("HERO_ROOM_ROBOT_BERSERKER_3_DESC"), str(cooldown_str()), str(damage_str()), str(burn_dur), str(cycle_time), str(damage_str(2)))

cooldown = table.tail({32, 28, 24})
local life_pct = table.tail({25, 30, 40})
map[_("HERO_ROOM_ROBOT_BERSERKER_4_NAME")] = string.format(_("HERO_ROOM_ROBOT_BERSERKER_4_DESC"), str(cooldown_str()), str(life_pct))

cooldown = table.tail({40, 40, 40, 40})
local ult_dur = 5
d[1].damage_min = table.tail({60, 130, 200, 270})
d[1].damage_max = table.tail({60, 130, 200, 270})
d[1].damage_type = DAMAGE_PHYSICAL
d[2].damage_min = table.tail({1, 2, 3, 4})
d[2].damage_max = table.tail({1, 2, 3, 4})
d[2].damage_type = DAMAGE_TRUE
cycle_time = 0.25
local ult_burn_dur = 4
map[_("HERO_ROOM_ROBOT_BERSERKER_5_NAME")] = string.format(_("HERO_ROOM_ROBOT_BERSERKER_5_DESC"), str(cooldown_str()), str(ult_dur), str(damage_str()), str(ult_burn_dur), str(cycle_time), str(damage_str(2)))

set_hero("hero_bird")
set_skill(h.hero.skills.cluster_bomb)
get_cooldown()
d[1].damage_min = table.tail({16, 24, 36})
d[1].damage_max = table.tail({16, 24, 36})
d[1].damage_type = DAMAGE_EXPLOSION
local fire_dur = table.tail({3, 6, 9})
local burn_dmg = table.tail({1, 1, 1})
map[_("HERO_ROOM_BIRD_CLUSTER_BOMB_NAME")] = string.format(_("HERO_ROOM_BIRD_CLUSTER_BOMB_DESC"), str(cooldown_str()), str(damage_str()), str(fire_dur), str(0.25), str(burn_dmg))

set_skill(h.hero.skills.shout_stun)
get_cooldown()
local stun_dur = table.tail({1, 1.5, 2})
local slow_dur = table.tail({3, 4, 6})
local slow_factor = (1 - 0.5) * 100
map[_("HERO_ROOM_BIRD_SHOUT_STUN_NAME")] = string.format(_("HERO_ROOM_BIRD_SHOUT_STUN_DESC"), str(cooldown_str()), str(100), str(stun_dur), str(slow_factor), str(slow_dur))

set_skill(h.hero.skills.gattling)
get_cooldown()
d[1].damage_min = table.tail({1, 3, 4})
d[1].damage_max = table.tail({3, 5, 6})
d[1].damage_type = DAMAGE_SHOT
local gat_dur = table.tail({3, 3, 3})
cycle_time = fts(4)
map[_("HERO_ROOM_BIRD_GATTLING_NAME")] = string.format(_("HERO_ROOM_BIRD_GATTLING_DESC"), str(cooldown_str()), str(gat_dur), str(cycle_time), str(damage_str()))

set_skill(h.hero.skills.eat_instakill)
get_cooldown()
local eat_hp = table.tail({520, 1040, 1560})
map[_("HERO_ROOM_BIRD_EAT_INSTAKILL_NAME")] = string.format(_("HERO_ROOM_BIRD_EAT_INSTAKILL_DESC"), str(cooldown_str()), str(eat_hp))

set_skill(h.hero.skills.ultimate)
get_cooldown()
local ult_dur = table.tail({8, 10, 12, 15})
d[1].damage_min = table.tail({16, 25, 36, 50})
d[1].damage_max = table.tail({16, 25, 36, 50})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_BIRD_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_BIRD_ULTIMATE_DESC"), str(cooldown_str()), str(ult_dur), str(damage_str()))

set_hero("hero_lava")
set_skill(h.hero.skills.temper_tantrum)
get_cooldown()
d[1].damage_min = table.tail({19, 35, 54})
d[1].damage_max = table.tail({28, 52, 80})
d[1].damage_type = DAMAGE_PHYSICAL
local stun_dur = 2
map[_("HERO_ROOM_LAVA_TEMPER_TANTRUM_NAME")] = string.format(_("HERO_ROOM_LAVA_TEMPER_TANTRUM_DESC"), str(cooldown_str()), str(damage_str()), str(stun_dur))

set_skill(h.hero.skills.hotheaded)
local hothead_factor = (table.tail({1.2, 1.3, 1.4}) - 1) * 100
local hothead_dur = table.tail({6, 6, 6})
cycle_time = 0.25
d[1].damage_min = 5
d[1].damage_max = 7
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_LAVA_HEART_NAME")] = string.format(_("HERO_ROOM_LAVA_HEART_DESC"), str(cycle_time), damage_str(), str(hothead_factor), str(hothead_dur))

set_skill(h.hero.skills.double_trouble)
get_cooldown()
d[1].damage_min = table.tail({30, 50, 75})
d[1].damage_max = table.tail({30, 50, 75})
d[1].damage_type = DAMAGE_EXPLOSION
local sol_dur = 10
map[_("HERO_ROOM_LAVA_DOUBLE_TROUBLE_NAME")] = string.format(_("HERO_ROOM_LAVA_DOUBLE_TROUBLE_DESC"), str(cooldown_str()), str(damage_str()), str(sol_dur))

set_skill(h.hero.skills.wild_eruption)
get_cooldown()
d[1].damage_min = table.tail({10, 12, 15})
d[1].damage_max = table.tail({10, 12, 15})
d[1].damage_type = DAMAGE_TRUE
local erupt_dur = table.tail({4, 4, 4})
cycle_time = 0.25
map[_("HERO_ROOM_LAVA_WILD_ERUPTION_NAME")] = string.format(_("HERO_ROOM_LAVA_WILD_ERUPTION_DESC"), str(cooldown_str()), str(cycle_time), str(damage_str()), str(erupt_dur))

set_skill(h.hero.skills.ultimate)
get_cooldown()
local ult_count = table.tail({3, 4, 5, 6})
d[1].damage_min = table.tail({40, 80, 130, 200})
d[1].damage_max = table.tail({40, 80, 130, 200})
d[1].damage_type = DAMAGE_TRUE
local scorch_dur = 4
map[_("HERO_ROOM_LAVA_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_LAVA_ULTIMATE_DESC"), str(cooldown_str()), str(ult_count), str(damage_str()), str(scorch_dur))

set_hero("hero_spider")
set_skill(h.hero.skills.instakill_melee)
get_cooldown()
local instakill_threshold = table.tail({1000, 1500, 2000})
factor = 0.4
map[_("HERO_ROOM_SPIDER_INSTAKILL_MELEE_NAME")] = string.format(_("HERO_ROOM_SPIDER_INSTAKILL_MELEE_DESC"), str(cooldown_str()), str(instakill_threshold), str(factor * 100))

set_skill(h.hero.skills.area_attack)
get_cooldown()
local stun_dur = table.tail({3, 4, 5})
d[1].damage_min = table.tail({25, 50, 75})
d[1].damage_max = table.tail({50, 75, 100})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_SPIDER_AREA_ATTACK_NAME")] = string.format(_("HERO_ROOM_SPIDER_AREA_ATTACK_DESC"), str(cooldown_str()), str(stun_dur), str(damage_str()))

set_skill(h.hero.skills.tunneling)
d[1].damage_min = table.tail({30, 45, 60})
d[1].damage_max = table.tail({40, 70, 100})
d[1].damage_type = DAMAGE_PHYSICAL
duration = 0.35
map[_("HERO_ROOM_SPIDER_TUNNELING_NAME")] = string.format(_("HERO_ROOM_SPIDER_TUNNELING_DESC"), str(damage_str()), str(duration))

set_skill(h.hero.skills.supreme_hunter)
get_cooldown()
d[1].damage_min = table.tail({112, 224, 336})
d[1].damage_max = table.tail({168, 336, 504})
d[1].damage_type = DAMAGE_RUDE
d[2].damage_min = table.tail({8, 12, 16})
d[2].damage_max = table.tail({8, 12, 16})
d[2].damage_type = DAMAGE_POISON
cycle_time = 0.25
map[_("HERO_ROOM_SPIDER_SUPREME_HUNTER_NAME")] = string.format(_("HERO_ROOM_SPIDER_SUPREME_HUNTER_DESC"), str(cooldown_str()), str(damage_str()), str(cycle_time), str(damage_str(2)))

set_skill(h.hero.skills.ultimate)
get_cooldown()
local spawn_count = table.tail({2, 3, 4, 5})
local spider_dur = table.tail({5, 7, 8, 10})
map[_("HERO_ROOM_SPIDER_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_SPIDER_ULTIMATE_DESC"), str(cooldown_str()), str(spawn_count), str(spider_dur))

set_hero("hero_mecha")
set_skill(h.hero.skills.goblidrones)
get_cooldown()
local drone_dur = table.tail({8, 10, 12})
d[1].damage_min = table.tail({4, 7, 10})
d[1].damage_max = table.tail({5, 10, 15})
d[1].damage_type = DAMAGE_SHOT
map[_("HERO_ROOM_MECHA_GOBLIDRONES_NAME")] = string.format(_("HERO_ROOM_MECHA_GOBLIDRONES_DESC"), str(cooldown_str()), str(2), str(drone_dur), str(damage_str()))

set_skill(h.hero.skills.tar_bomb)
get_cooldown()
local tar_dur = table.tail({5, 6, 7})
local tar_slow = (1 - 0.5) * 100
map[_("HERO_ROOM_MECHA_TAR_BOMB_NAME")] = string.format(_("HERO_ROOM_MECHA_TAR_BOMB_DESC"), str(cooldown_str()), str(tar_slow), str(tar_dur))

set_skill(h.hero.skills.power_slam)
get_cooldown()
local slam_stun = table.tail({30, 45, 60}) / 30
d[1].damage_min = table.tail({30, 60, 90})
d[1].damage_max = table.tail({30, 60, 90})
d[1].damage_type = DAMAGE_PHYSICAL
map[_("HERO_ROOM_MECHA_POWER_SLAM_NAME")] = string.format(_("HERO_ROOM_MECHA_POWER_SLAM_DESC"), str(cooldown_str()), str(slam_stun), str(damage_str()))

set_skill(h.hero.skills.mine_drop)
get_cooldown()
local max_mines = table.tail({2, 3, 4})
d[1].damage_min = table.tail({16, 24, 32})
d[1].damage_max = table.tail({26, 38, 50})
d[1].damage_type = DAMAGE_EXPLOSION
map[_("HERO_ROOM_MECHA_MINE_DROP_NAME")] = string.format(_("HERO_ROOM_MECHA_MINE_DROP_DESC"), str(cooldown_str()), str(max_mines), str(damage_str()))

set_skill(h.hero.skills.ultimate)
get_cooldown()
d[1].damage_min = table.tail({40, 48, 56, 64})
d[1].damage_max = table.tail({60, 72, 84, 96})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_MECHA_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_MECHA_ULTIMATE_DESC"), str(cooldown_str()), str(damage_str()))

set_hero("hero_dragon_sun")
set_skill(h.hero.skills.worthy_foe)
get_cooldown()
d[1].damage_min = table.tail({200, 360, 400})
d[1].damage_max = table.tail({300, 540, 720})
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_DRAGON_SUN_WORTHY_FOE_NAME")] = string.format(_("HERO_ROOM_DRAGON_SUN_WORTHY_FOE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.solar_cleansing)
get_cooldown()
local cleansing_dur = table.tail({6, 6, 6})
cycle_time = 0.25
amount = table.tail({5, 10, 15})
map[_("HERO_ROOM_DRAGON_SUN_SOLAR_CLEANSING_NAME")] = string.format(_("HERO_ROOM_DRAGON_SUN_SOLAR_CLEANSING_DESC"), str(cooldown_str()), str(cleansing_dur), str(cycle_time), str(amount))

set_skill(h.hero.skills.overcharge)
d[1].damage_min = table.tail({75, 150, 225})
d[1].damage_max = table.tail({100, 200, 300})
d[1].damage_type = DAMAGE_TRUE
cooldown = table.tail({6, 6, 6})
map[_("HERO_ROOM_DRAGON_SUN_OVERCHARGE_NAME")] = string.format(_("HERO_ROOM_DRAGON_SUN_OVERCHARGE_DESC"), str(cooldown), str(damage_str()))

set_skill(h.hero.skills.solar_stones)
get_cooldown()
local max_mines = table.tail({3, 4, 5})
d[1].damage_min = table.tail({50, 90, 130})
d[1].damage_max = table.tail({70, 120, 190})
d[1].damage_type = DAMAGE_TRUE
radius = 50
map[_("HERO_ROOM_DRAGON_SUN_SOLAR_STONES_NAME")] = string.format(_("HERO_ROOM_DRAGON_SUN_SOLAR_STONES_DESC"), str(cooldown_str()), str(radius), str(damage_str()), str(max_mines))

set_skill(h.hero.skills.ultimate)
get_cooldown()
d[1].damage_min = table.tail({6, 12, 18, 24})
d[1].damage_max = table.tail({10, 20, 30, 40})
d[1].damage_type = DAMAGE_TRUE
cycle_time = 0.1
radius = 80
map[_("HERO_ROOM_DRAGON_SUN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_DRAGON_SUN_ULTIMATE_DESC"), str(cooldown_str()), str(cycle_time), str(radius), str(damage_str()))

-- hero_eiskalt
set_hero("hero_eiskalt")

map[_("HERO_ROOM_EISKALT_ULTIMATE_NAME")] = _("HERO_ROOM_EISKALT_ULTIMATE_DESC")

set_skill(h.hero.skills.explosion)
local radius = s.damage_radius[max_lvl]
map[_("HERO_ROOM_EISKALT_EXPLOSION_NAME")] = string.format(_("HERO_ROOM_EISKALT_EXPLOSION_DESC"), str(radius))

set_skill(h.hero.skills.coldfury)
cooldown = s.cooldown_time[max_lvl]
duration = T("aura_chill_eiskalt").aura.duration
slow_factor = 1 - T("mod_eiskalt_chill").slow.factor
map[_("HERO_ROOM_EISKALT_COLDFURY_NAME")] = string.format(_("HERO_ROOM_EISKALT_COLDFURY_DESC"), str(cooldown_str()), str(duration), str(slow_factor * 100))

set_skill(h.hero.skills.frosty)
cooldown = h.timed_attacks.list[1].cooldown
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_type = T("aura_eiskalt_rider").damage_type
cycle_time = T("aura_eiskalt_rider").aura.cycle_time
map[_("HERO_ROOM_EISKALT_FROSTY_NAME")] = string.format(_("HERO_ROOM_EISKALT_FROSTY_DESC"), str(cooldown_str()), str(cycle_time), str(damage_str()))

set_skill(h.hero.skills.icepeak)
cooldown = h.timed_attacks.list[2].cooldown
local count = s.count[max_lvl]
map[_("HERO_ROOM_EISKALT_ICEPEAK_NAME")] = string.format(_("HERO_ROOM_EISKALT_ICEPEAK_DESC"), str(cooldown_str()), str(count))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
duration = s.duration[max_lvl]
map[_("HERO_ROOM_EISKALT_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_EISKALT_ULTIMATE_2_DESC"), str(cooldown_str()), str(duration))

-- hero_asra
set_hero("hero_asra")

map[_("HERO_ROOM_ASRA_ULTIMATE_NAME")] = _("HERO_ROOM_ASRA_ULTIMATE_DESC")

set_skill(h.hero.skills.spider_bite)
cooldown = h.melee.attacks[2].cooldown
local poison_damage = s.damage_config[max_lvl]
e = T("mod_asra_poison")
local poison_every = e.dps.damage_every
map[_("HERO_ROOM_ASRA_SPIDER_BITE_NAME")] = string.format(_("HERO_ROOM_ASRA_SPIDER_BITE_DESC"), str(cooldown_str()), str(poison_every), str(poison_damage))

set_skill(h.hero.skills.onix_arrows)
cooldown = h.ranged.attacks[2].cooldown
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_type = T("bullet_onix_asra").bullet.damage_type
map[_("HERO_ROOM_ASRA_ONIX_ARROWS_NAME")] = string.format(_("HERO_ROOM_ASRA_ONIX_ARROWS_DESC"), str(cooldown_str()), str(s.loops[max_lvl]), str(damage_str()))

set_skill(h.hero.skills.quiver_of_sorrow)
map[_("HERO_ROOM_ASRA_QUIVER_OF_SORROW_NAME")] = string.format(_("HERO_ROOM_ASRA_QUIVER_OF_SORROW_DESC"), str(s.damage_armor[max_lvl] * 100))

set_skill(h.hero.skills.shield_of_shadows)
cooldown = h.unbreakable.cooldown
e = T("hero_asra_unbreakable_mod")
local shield_duration = e.modifier.duration
factor = T("mod_hero_asra_unbreakable_broken").inflicted_damage_factor - 1
duration = T("mod_hero_asra_unbreakable_broken").modifier.duration
map[_("HERO_ROOM_ASRA_SHIELD_OF_SHADOWS_NAME")] = string.format(_("HERO_ROOM_ASRA_SHIELD_OF_SHADOWS_DESC"), str(cooldown_str()), str(s.shield_max_damage[max_lvl]), str(shield_duration), str(factor * 100), str(duration))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
d[1].damage_min = s.damage_config[max_lvl]
d[1].damage_max = s.damage_config[max_lvl]
d[1].damage_type = T("arrow_hero_asra_ultimate").bullet.damage_type
e = T("mod_hero_asra_ultimate_poison")
local ult_poison_every = e.dps.damage_every
local ult_poison_duration = e.modifier.duration
d[2].damage_min = s.damage_poison_config[max_lvl]
d[2].damage_max = s.damage_poison_config[max_lvl]
d[2].damage_type = e.dps.damage_type
map[_("HERO_ROOM_ASRA_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_ASRA_ULTIMATE_2_DESC"), str(cooldown_str()), str(damage_str()), str(ult_poison_every), str(damage_str(2)), str(ult_poison_duration))

-- hero_beresad
set_hero("hero_beresad")

map[_("HERO_ROOM_BERESAD_ULTIMATE_NAME")] = _("HERO_ROOM_BERESAD_ULTIMATE_DESC")

set_skill(h.hero.skills.conflagration)
cooldown = s.cooldown[max_lvl]
e = T("aura_beresad_firestorm")
local conflagration_duration = e.aura.duration
e = T("mod_beresad_firestorm")
local conflagration_burn_every = e.dps.damage_every
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
d[1].damage_type = e.dps.damage_type
map[_("HERO_ROOM_BERESAD_CONFLAGRATION_NAME")] = string.format(_("HERO_ROOM_BERESAD_CONFLAGRATION_DESC"), str(cooldown_str()), str(conflagration_duration), str(conflagration_burn_every), str(damage_str()))

set_skill(h.hero.skills.fear_dragon)
cooldown = h.timed_attacks.list[1].cooldown
duration = s.duration[max_lvl]
local max_targets = h.timed_attacks.list[1].max_targets
local speed_factor = (T("mod_beresad_fear_indicator").slow.factor - 1) * 100
map[_("HERO_ROOM_BERESAD_FEAR_DRAGON_NAME")] = string.format(_("HERO_ROOM_BERESAD_FEAR_DRAGON_DESC"), str(cooldown_str()), str(max_targets), str(speed_factor), str(duration))

set_skill(h.hero.skills.dragon_spawn)
get_cooldown()

local golem_hp = s.hp[max_lvl]
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_type = T("hero_beresad_golem").melee.attacks[1].damage_type
d[2].damage_min = s.explode_damage_min[max_lvl]
d[2].damage_max = s.explode_damage_max[max_lvl]
d[2].damage_type = T("bomb_beresad_golem").bullet.damage_type
duration = T("hero_beresad_golem").reinforcement.duration
map[_("HERO_ROOM_BERESAD_DRAGON_SPAWN_NAME")] = string.format(_("HERO_ROOM_BERESAD_DRAGON_SPAWN_DESC"), str(cooldown_str()), str(damage_str(2)), str(golem_hp), str(damage_str()), str(duration))

set_skill(h.hero.skills.remove_existence)
get_cooldown()
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_type = T("mod_ray_beresad_disintegrate").explode_damage_type
map[_("HERO_ROOM_BERESAD_REMOVE_EXISTENCE_NAME")] = string.format(_("HERO_ROOM_BERESAD_REMOVE_EXISTENCE_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
d[1].damage_min = s.damage[max_lvl]
d[1].damage_max = s.damage[max_lvl]
d[1].damage_type = T("mod_beresad_ultimate").dps.damage_type
cycle_time = T("mod_beresad_ultimate").dps.damage_every
duration = T("controller_beresad_ultimate").duration
map[_("HERO_ROOM_BERESAD_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_BERESAD_ULTIMATE_2_DESC"), str(cooldown_str()), str(cycle_time), str(damage_str()), str(duration))

-- hero_dianyun
set_hero("hero_dianyun")

set_skill(h.hero.skills.ricochet)
cooldown = h.ranged.attacks[2].cooldown
d[1].damage_min = s.damage_min[max_lvl]
d[1].damage_max = s.damage_max[max_lvl]
d[1].damage_type = T("hero_dianyun_lightning_ricochet").bullet.damage_type
map[_("HERO_ROOM_DIANYUN_RICOCHET_NAME")] = string.format(_("HERO_ROOM_DIANYUN_RICOCHET_DESC"), str(cooldown_str()), str(s.bounce[max_lvl]), str(damage_str()))

set_skill(h.hero.skills.lord_storm)
map[_("HERO_ROOM_DIANYUN_LORD_STORM_NAME")] = string.format(_("HERO_ROOM_DIANYUN_LORD_STORM_DESC"), str(s.max_targets[max_lvl]))

set_skill(h.hero.skills.divine_rain)
cooldown = h.timed_attacks.list[1].cooldown
duration = s.duration
cycle_time = T("aura_hero_dianyun_divine_rain").aura.cycle_time
map[_("HERO_ROOM_DIANYUN_DIVINE_RAIN_NAME")] = string.format(_("HERO_ROOM_DIANYUN_DIVINE_RAIN_DESC"), str(cooldown_str()), str(cycle_time), str(s.healing_points_tick[max_lvl]), str(duration))

set_skill(h.hero.skills.supreme_wave)
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_DIANYUN_SUPREME_WAVE_NAME")] = string.format(_("HERO_ROOM_DIANYUN_SUPREME_WAVE_DESC"), str(cooldown_str()), str(s.stun[max_lvl]))

set_skill(h.hero.skills.ultimate)
get_cooldown()
e = T("bolt_hero_dianyun_electric_son")
d[1].damage_max = e.bullet.damage_max
d[1].damage_min = e.bullet.damage_min
d[1].damage_type = e.bullet.damage_type
count = s.bullets_to_death[max_lvl]
map[_("HERO_ROOM_DIANYUN_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_DIANYUN_ULTIMATE_DESC"), str(cooldown_str()), str(damage_str()), str(count))

map[_("HERO_ROOM_DIANYUN_ULTIMATE_2_NAME")] = _("HERO_ROOM_DIANYUN_ULTIMATE_2_DESC")

set_hero("hero_isfet")

set_skill(h.hero.skills.black_cloud)
cooldown = h.timed_attacks.list[1].cooldown
d[1].damage_min = ss("damage")
d[1].damage_max = ss("damage")
d[1].damage_type = DAMAGE_EXPLOSION
map[_("HERO_ROOM_ISFET_BLACK_CLOUD_NAME")] = string.format(_("HERO_ROOM_ISFET_BLACK_CLOUD_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.frog_curse)
cooldown = h.timed_attacks.list[2].cooldown
map[_("HERO_ROOM_ISFET_FROG_CURSE_NAME")] = string.format(_("HERO_ROOM_ISFET_FROG_CURSE_DESC"), str(cooldown_str()), str(s.health_threshold[max_lvl]))

set_skill(h.hero.skills.rain)
cooldown = h.timed_attacks.list[3].cooldown
count = ss("count")
map[_("HERO_ROOM_ISFET_RAIN_NAME")] = string.format(_("HERO_ROOM_ISFET_RAIN_DESC"), str(cooldown_str()), str(count))

set_skill(h.hero.skills.blood_pool)
cooldown = h.timed_attacks.list[4].cooldown
d[1].damage_min = ss("damage_factor")
factor = ss("damage_factor")
map[_("HERO_ROOM_ISFET_BLOOD_POOL_NAME")] = string.format(_("HERO_ROOM_ISFET_BLOOD_POOL_DESC"), str(cooldown_str()), str((factor - 1) * 100))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
d[1].damage_min = ss("damage")
d[1].damage_max = ss("damage")
d[1].damage_type = DAMAGE_TRUE
map[_("HERO_ROOM_ISFET_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_ISFET_ULTIMATE_DESC"), str(cooldown_str()), str(damage_str()))

map[_("HERO_ROOM_ISFET_ULTIMATE_2_NAME")] = _("HERO_ROOM_ISFET_ULTIMATE_2_DESC")

set_hero("hero_orc")

set_skill(h.hero.skills.duelist)
cooldown = h.melee.attacks[3].cooldown
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = h.melee.attacks[3].damage_type
map[_("HERO_ROOM_ORC_DUELIST_NAME")] = string.format(_("HERO_ROOM_ORC_DUELIST_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.brute_force)
cooldown = ss("cooldown")
duration = ss("duration")
map[_("HERO_ROOM_ORC_BRUTE_FORCE_NAME")] = string.format(_("HERO_ROOM_ORC_BRUTE_FORCE_DESC"), str(cooldown_str()), str(duration))

set_skill(h.hero.skills.inspiring_leader)
cooldown = ss("cooldown")
e = T("soldier_hero_orc_goblin")
get_health(e)
health[1].hp_max = ss("hp_max")
get_damage(e.melee.attacks[1])
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
count = h.timed_attacks.list[1].count
map[_("HERO_ROOM_ORC_INSPIRING_LEADER_NAME")] = string.format(_("HERO_ROOM_ORC_INSPIRING_LEADER_DESC"), str(cooldown_str()), str(count), str(health_str()), str(damage_str()), str(e.reinforcement.duration))

set_skill(h.hero.skills.ultimate)
e = T("soldier_hero_orc_spear_goblin")
get_health(e)
get_damage(e.melee.attacks[1])
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
duration = e.reinforcement.duration
e = T(e.ranged.attacks[1].bullet)
get_damage(e.bullet, 2)
d[2].damage_min = ss("ranged_damage_min")
d[2].damage_max = ss("ranged_damage_max")

map[_("HERO_ROOM_ORC_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_ORC_ULTIMATE_DESC"), str(damage_str()), str(damage_str(2)), str(duration))

e = T("aura_hero_orc_regen")
amount = e.regen.health
cooldown = e.regen.cooldown
map[_("HERO_ROOM_ORC_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_ORC_ULTIMATE_2_DESC"), str(cooldown_str()), str(amount))

set_skill(h.hero.skills.aimed_slash)
amount = ss("max_buff_level")
e = T("aura_hero_orc_aimed_slash")
amount_2 = e.damage_factor_inc
cycle_time = e.upgrade_cycle_time
map[_("HERO_ROOM_ORC_AIMED_SLASH_NAME")] = string.format(_("HERO_ROOM_ORC_AIMED_SLASH_DESC"), str(amount_2 * 100), str(cycle_time), str(amount))

-- function H.dump()
-- 	for hero_name, skills in pairs(H) do
-- 		print("Hero:", hero_name)
-- 		if type(skills) == "table" then
-- 			for skill_name, skill_description in pairs(skills) do
-- 				print(skill_name)
-- 				print(skill_description)
-- 			end
-- 		end
-- 	end
-- end
-- H.dump()

-- 奥洛克
set_hero("hero_oloch")

set_skill(h.hero.skills.duplication)
cooldown = h.timed_attacks.list[1].cooldown
e = T("soldier_oloch_illusion")
get_health(e)
duration = e.reinforcement.duration
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = DAMAGE_MAGICAL
map[_("HERO_ROOM_OLOCH_DUPLICATION_NAME")] = string.format(_("HERO_ROOM_OLOCH_DUPLICATION_DESC"), str(cooldown_str()), str(hp_str()), str(damage_str()), str(duration))

set_skill(h.hero.skills.magma_eruption)
cooldown = h.timed_attacks.list[2].cooldown
count = ss("count")
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
e = T("oloch_magma")
d[1].damage_type = e.bullet.damage_type
e = T("mod_oloch_magma")
d[2].damage_min = ss("damage_aura_config")
d[2].damage_max = ss("damage_aura_config")
d[2].damage_type = e.dps.damage_type
cycle_time = e.dps.damage_every
map[_("HERO_ROOM_OLOCH_MAGMA_ERUPTION_NAME")] = string.format(_("HERO_ROOM_OLOCH_MAGMA_ERUPTION_DESC"), str(cooldown_str()), str(count), str(damage_str()), str(cycle_time), str(damage_str(2)))

set_skill(h.hero.skills.hellish_infusion)
cooldown = h.timed_attacks.list[1].cooldown
duration = T("mod_oloch_heat").modifier.duration
local factor = ss("damage_factor_config")
map[_("HERO_ROOM_OLOCH_HELLISH_INFUSION_NAME")] = string.format(_("HERO_ROOM_OLOCH_HELLISH_INFUSION_DESC"), str(cooldown_str()), str((factor - 1) * 100), str(duration))

set_skill(h.hero.skills.demonic_blast)
cooldown = h.ranged.attacks[2].cooldown
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = T("bolt_oloch_big").bullet.damage_type
map[_("HERO_ROOM_OLOCH_DEMONIC_BLAST_NAME")] = string.format(_("HERO_ROOM_OLOCH_DEMONIC_BLAST_DESC"), str(cooldown_str()), str(damage_str()))

set_skill(h.hero.skills.ultimate)
cooldown = ss("cooldown")
count = T("controller_hero_oloch_ultimate").max_targets
d[1].damage_min = T("mod_hero_oloch_ultimate_teleport").damage_base + T("mod_hero_oloch_ultimate_teleport").damage_inc * max_lvl
d[1].damage_max = d[1].damage_min
d[1].damage_type = T("mod_hero_oloch_ultimate_teleport").damage_type
map[_("HERO_ROOM_OLOCH_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_OLOCH_ULTIMATE_DESC"), str(cooldown_str()), str(count), str(damage_str()))

d[1].damage_min = table.tail(h.hero.level_stats.selfdestruct_damage_config)
d[1].damage_max = table.tail(h.hero.level_stats.selfdestruct_damage_config)
d[1].damage_type = h.selfdestruct.damage_type
radius = h.selfdestruct.damage_radius
map[_("HERO_ROOM_OLOCH_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_OLOCH_ULTIMATE_2_DESC"), str(radius), str(damage_str()))

-- 苦楝夫人
set_hero("hero_margosa")

map[_("HERO_ROOM_MARGOSA_ULTIMATE_NAME")] = _("HERO_ROOM_MARGOSA_ULTIMATE_DESC")

set_skill(h.hero.skills.bat_familiar)
d[1].damage_min = ss("damage_min_config")
d[1].damage_max = ss("damage_max_config")
d[1].damage_type = T("bat_reinforcement_special_dark_army").custom_attack.damage_type
cooldown = T("bat_reinforcement_special_dark_army").custom_attack.cooldown
map[_("HERO_ROOM_MARGOSA_BAT_FAMILIAR_NAME")] = string.format(_("HERO_ROOM_MARGOSA_BAT_FAMILIAR_DESC"), str(cooldown), str(damage_str()))

set_skill(h.hero.skills.myst_form)
cooldown = h.timed_attacks.list[1].cooldown
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = T("mod_dmg_fog_hero_margosa").dps.damage_type
cycle_time = T("mod_dmg_fog_hero_margosa").dps.damage_every
duration = T("aura_fog_hero_margosa").aura.duration
factor = 1 - ss("damage_factor")
local slow_factor = 1 - T("mod_slow_fog_hero_margosa").slow.factor
map[_("HERO_ROOM_MARGOSA_MYST_FORM_NAME")] = string.format(_("HERO_ROOM_MARGOSA_MYST_FORM_DESC"), str(cooldown_str()), str(cycle_time), str(damage_str()), str(slow_factor * 100), str(factor * 100), str(duration))

set_skill(h.hero.skills.dark_call)
cooldown = h.timed_attacks.list[2].cooldown
duration = ss("duration")
count = h.timed_attacks.list[2].max_count
map[_("HERO_ROOM_MARGOSA_DARK_CALL_NAME")] = string.format(_("HERO_ROOM_MARGOSA_DARK_CALL_DESC"), str(cooldown_str()), str(count), str(duration))

set_skill(h.hero.skills.vampiric_touch)
factor = ss("track_rate")
map[_("HERO_ROOM_MARGOSA_VAMPIRIC_TOUCH_NAME")] = string.format(_("HERO_ROOM_MARGOSA_VAMPIRIC_TOUCH_DESC"), str(factor * 100))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
duration = ss("duration")
local dmg_factor = h.ultimate.damage_factor
map[_("HERO_ROOM_MARGOSA_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_MARGOSA_ULTIMATE_2_DESC"), str(cooldown_str()), str((dmg_factor - 1) * 100), str(duration))

-- 墨忒弥斯
set_hero("hero_mortemis")

map[_("HERO_ROOM_MORTEMIS_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_ULTIMATE_DESC"), str(T("bolt_mortemis").bullet.heal_factor * 100))

set_skill(h.hero.skills.call_haunted)
cooldown = h.timed_attacks.list[1].cooldown
count = h.timed_attacks.list[1].max_target
duration = ss("duration")
map[_("HERO_ROOM_MORTEMIS_CALL_HAUNTED_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_CALL_HAUNTED_DESC"), str(cooldown_str()), str(count), str(duration))

set_skill(h.hero.skills.deadly_fumes)
cooldown = h.timed_attacks.list[2].cooldown
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = T("mod_mortemis_magma").dps.damage_type
cycle_time = T("mod_mortemis_magma").dps.damage_every
duration = T("mortemis_poisonpool").aura.duration
map[_("HERO_ROOM_MORTEMIS_DEADLY_FUMES_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_DEADLY_FUMES_DESC"), str(cooldown_str()), str(cycle_time), str(damage_str()), str(duration))

set_skill(h.hero.skills.grim_presence)
local reduction = -1 * ss("armor_reduction")
radius = T("aura_mortemis_curse_armor").aura.radius
map[_("HERO_ROOM_MORTEMIS_GRIM_PRESENCE_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_GRIM_PRESENCE_DESC"), str(radius), str(reduction * 100))

set_skill(h.hero.skills.undead_servitude)
count = T("aura_mortemis_zombie").max_count
radius = T("aura_mortemis_zombie").aura.radius
health[1].hp_max = ss("hp_max")
health[1].armor = T("hero_mortemis_zombie").health.armor
health[1].magic_armor = T("hero_mortemis_zombie").health.magic_armor
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = T("hero_mortemis_zombie").melee.attacks[1].damage_type
duration = T("hero_mortemis_zombie").reinforcement.duration
map[_("HERO_ROOM_MORTEMIS_UNDEAD_SERVITUDE_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_UNDEAD_SERVITUDE_DESC"), str(radius), str(health_str()), str(damage_str()), str(duration), str(count))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
e = T("hero_mortemis_golem")
get_health(e)
health[1].hp_max = ss("hp_max")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = e.melee.attacks[1].damage_type
duration = e.reinforcement.duration
duration_2 = T("hero_mortemis_golem_stun").modifier.duration
map[_("HERO_ROOM_MORTEMIS_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_ULTIMATE_2_DESC"), str(cooldown_str()), str(hp_str()), str(damage_str()), str(duration_2), str(duration))

set_skill(h.hero.skills.undead_servitude)
e = T("hero_mortemis_zombie")
health[1].hp_max = ss("hp_max")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = e.melee.attacks[1].damage_type
map[_("HERO_ROOM_MORTEMIS_UNDEAD_SERVITUDE_2_NAME")] = string.format(_("HERO_ROOM_MORTEMIS_UNDEAD_SERVITUDE_2_DESC"), str(h.death_spawns.quantity), str(hp_str()), str(damage_str()))

-- 极狗
set_hero("hero_jigou")

e = E:get_template("aura_jigou_regen")
local regen_every = e.hps.heal_every
local regen_amount = e.hps.heal_min
map[_("HERO_ROOM_JIGOU_UNDEAD_SERVITUDE_NAME")] = string.format(_("HERO_ROOM_JIGOU_UNDEAD_SERVITUDE_DESC"), str(regen_every), str(regen_amount))

set_skill(h.hero.skills.ice_shard)
cooldown = h.ranged.attacks[1].cooldown
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = T("bullet_jigou").bullet.damage_type
radius = T("bullet_jigou").bullet.damage_radius
map[_("HERO_ROOM_JIGOU_ICE_SHARD_NAME")] = string.format(_("HERO_ROOM_JIGOU_ICE_SHARD_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.frozen_breath)
cooldown = h.timed_attacks.list[2].cooldown
duration = T("mod_jigou_freeze").modifier.duration
map[_("HERO_ROOM_JIGOU_FROZEN_BREATH_NAME")] = string.format(_("HERO_ROOM_JIGOU_FROZEN_BREATH_DESC"), str(cooldown_str()), str(duration))

set_skill(h.hero.skills.earthshake)
cooldown = h.melee.attacks[2].cooldown
local loops = ss("loops")
get_damage(h.melee.attacks[2])
local stun_dur = T("mod_jigou_stun").modifier.duration
map[_("HERO_ROOM_JIGOU_EARTHSHAKE_NAME")] = string.format(_("HERO_ROOM_JIGOU_EARTHSHAKE_DESC"), str(cooldown_str()), str(loops), str(damage_str()), str(stun_dur))

set_skill(h.hero.skills.glacial_form)
cooldown = h.timed_attacks.list[1].cooldown
duration = ss("duration")
heal = ss("hps")
local damage_reduction = 1 - h.timed_attacks.list[1].damage_factor
e = E:get_template("mod_jigou_slow")
local slow_factor = 1 - e.slow.factor
map[_("HERO_ROOM_JIGOU_GLACIAL_FORM_NAME")] = string.format(_("HERO_ROOM_JIGOU_GLACIAL_FORM_DESC"), str(cooldown_str()), str(duration), str(damage_reduction * 100), str(h.melee.range), str(slow_factor * 100), str(heal))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = T("aura_jigou_ultimate").aura.damage_type
duration = T("mod_jigou_ultimate_slow").modifier.duration
local slow = 1 - ss("slow_factor")
map[_("HERO_ROOM_JIGOU_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_JIGOU_ULTIMATE_DESC"), str(cooldown_str()), str(damage_str()), str(slow * 100), str(duration))

-- 特拉敏大师
set_hero("hero_tramin")

map[_("HERO_ROOM_TRAMIN_ULTIMATE_NAME")] = _("HERO_ROOM_TRAMIN_ULTIMATE_DESC")

set_skill(h.hero.skills.bombots)
cooldown = h.ranged.attacks[2].cooldown
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = T("aura_bomb_tramin_skill1").aura.damage_type
radius = T("aura_bomb_tramin_skill1").aura.radius
map[_("HERO_ROOM_TRAMIN_BOMBOTS_NAME")] = string.format(_("HERO_ROOM_TRAMIN_BOMBOTS_DESC"), str(cooldown_str()), str(radius), str(damage_str()))

set_skill(h.hero.skills.nitro_rush)
cooldown = h.timed_attacks.list[2].cooldown
duration = ss("duration")
factor = 1 - h.timed_attacks.list[2].cooldown_factor
map[_("HERO_ROOM_TRAMIN_NITRO_RUSH_NAME")] = string.format(_("HERO_ROOM_TRAMIN_NITRO_RUSH_DESC"), str(cooldown_str()), str(factor * 100), str(duration))

set_skill(h.hero.skills.flashbang)
cooldown = h.ranged.attacks[3].cooldown
duration = ss("duration")
map[_("HERO_ROOM_TRAMIN_FLASHBANG_NAME")] = string.format(_("HERO_ROOM_TRAMIN_FLASHBANG_DESC"), str(cooldown_str()), str(duration))

set_skill(h.hero.skills.rocket_barrage)
cooldown = h.timed_attacks.list[1].cooldown
count = ss("count")
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
d[1].damage_type = T("missle_tramin").bullet.damage_type
map[_("HERO_ROOM_TRAMIN_ROCKET_BARRAGE_NAME")] = string.format(_("HERO_ROOM_TRAMIN_ROCKET_BARRAGE_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
count = ss("entity_count")
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = T("aura_bomb_tramin_ultimate").aura.damage_type
map[_("HERO_ROOM_TRAMIN_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_TRAMIN_ULTIMATE_2_DESC"), str(cooldown_str()), str(count), str(damage_str()))

-- 毁灭坦克 SG-11
set_hero("hero_tank")
e = T("controller_overwhelm_tank")
d[1].damage_min = table.tail(e.damage)
d[1].damage_max = table.tail(e.damage)
d[1].damage_type = e.damage_type
map[_("HERO_ROOM_TANK_ULTIMATE_NAME")] = string.format(_("HERO_ROOM_TANK_ULTIMATE_DESC"), str(e.cooldown), str(damage_str()))

set_skill(h.hero.skills.heat_missiles)
cooldown = h.timed_attacks.list[1].cooldown
count = ss("count")
d[1].damage_min = ss("damage_min_config")
d[1].damage_max = ss("damage_max_config")
d[1].damage_type = T("missle_tank").bullet.damage_type
map[_("HERO_ROOM_TANK_HEAT_MISSILES_NAME")] = string.format(_("HERO_ROOM_TANK_HEAT_MISSILES_DESC"), str(cooldown_str()), str(count), str(damage_str()))

set_skill(h.hero.skills.ground_slam)
cooldown = h.timed_attacks.list[2].cooldown
e = T("aura_tank_skill2_bomb")
d[1].damage_min = ss("damage_min_config")
d[1].damage_max = ss("damage_max_config")
d[1].damage_type = e.aura.damage_type
local stun_dur = T("mod_tank_skill2_stun").modifier.duration
map[_("HERO_ROOM_TANK_GROUND_SLAM_NAME")] = string.format(_("HERO_ROOM_TANK_GROUND_SLAM_DESC"), str(cooldown_str()), str(damage_str()), str(stun_dur))

set_skill(h.hero.skills.expendables)
e = T("hero_tank_expendables")
get_health(e)
health[1].hp_max = ss("hp_max")
get_damage(e.melee.attacks[1])
d[1].damage_min = ss("damage_min")
d[1].damage_max = ss("damage_max")
count = ss("count")
map[_("HERO_ROOM_TANK_EXPENDABLES_NAME")] = string.format(_("HERO_ROOM_TANK_EXPENDABLES_DESC"), str(count), str(hp_str()), str(damage_str()))

set_skill(h.hero.skills.scorching_cannon)
cooldown = ss("cooldown")
e = T("mod_roundfire_hero_tank")
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = e.dps.damage_type
local fire_every = e.dps.damage_every
map[_("HERO_ROOM_TANK_SCORCHING_CANNON_NAME")] = string.format(_("HERO_ROOM_TANK_SCORCHING_CANNON_DESC"), str(cooldown_str()), str(fire_every), str(damage_str()), str(T("aura_roundfire_hero_tank").aura.duration))

set_skill(h.hero.skills.ultimate)
cooldown = h.ultimate.cooldown
e = T("mod_bullet_zeppelin_hero_tank")
d[1].damage_min = ss("damage_config")
d[1].damage_max = ss("damage_config")
d[1].damage_type = e.dps.damage_type
local ult_every = e.dps.damage_every
map[_("HERO_ROOM_TANK_ULTIMATE_2_NAME")] = string.format(_("HERO_ROOM_TANK_ULTIMATE_2_DESC"), str(cooldown_str()), str(ult_every), str(damage_str()), str(T("aura_bullet_zeppelin_hero_tank").aura.duration))

return H
