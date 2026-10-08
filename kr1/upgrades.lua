-- chunkname: @./kr1/upgrades.lua
local km = require("lib.klua.macros")
local E = require("entity_db")
local bit = require("bit")
local U = require("utils")
local V = require("lib.klua.vector")
require("all.constants")

local function T(name)
	return E:get_template(name)
end

-- 数值缩放小工具 ----------------------------------------------------------
-- 把 obj[key] 乘以 factor
local function mul_field(obj, key, factor)
	obj[key] = obj[key] * factor
end

-- 把 obj 上列出的若干字段同乘 factor
local function mul_keys(obj, factor, ...)
	for _, k in ipairs({...}) do
		obj[k] = obj[k] * factor
	end
end

-- 把 owner[min_key]/owner[max_key] 同乘 factor（默认 damage_min / damage_max）
local function mul_dmg(owner, factor, min_key, max_key)
	local mn = min_key or "damage_min"
	local mx = max_key or "damage_max"
	owner[mn] = owner[mn] * factor
	owner[mx] = owner[mx] * factor
end

-- 把数组里的每个元素同乘 factor
local function mul_arr(arr, factor)
	for i = 1, #arr do
		arr[i] = arr[i] * factor
	end
end

-- 把 damage_min / damage_max 统一为“平均值 * factor”
local function avg_dmg_mul(owner, factor)
	local damage = (owner.damage_min + owner.damage_max) * 0.5 * factor
	owner.damage_min = damage
	owner.damage_max = damage
end

-- 给一组模板的 bullet.damage_hooks 追加同一个 hook
local function add_damage_hooks(template_names, hook)
	for _, n in ipairs(template_names) do
		local b = T(n).bullet
		b.damage_hooks[#b.damage_hooks + 1] = hook
	end
end

-- 缩放一组塔的建造价格
local function scale_tower_price(towers, factor, round_fn)
	for _, n in pairs(towers) do
		local t = T(n)
		if t.tower and t.tower.price then
			t.tower.price = round_fn(t.tower.price * factor)
		end
	end
end

-- 缩放一组塔的技能价格（price_base / price_inc）
local function scale_power_prices(towers, factor, round_fn)
	for _, n in pairs(towers) do
		local t = T(n)
		if t.powers then
			for _, p in pairs(t.powers) do
				if p.price_base then
					p.price_base = round_fn(p.price_base * factor)
				end
				if p.price_inc then
					p.price_inc = round_fn(p.price_inc * factor)
				end
			end
		end
	end
end

-- 缩放一组塔的伤害倍率
local function scale_tower_damage(towers, factor)
	for _, n in pairs(towers) do
		T(n).tower.damage_factor = T(n).tower.damage_factor * factor
	end
end

-- 缩放一组塔的攻击射程（可用 skip 表跳过指定塔）
local function scale_tower_attack_range(towers, factor, skip)
	for _, n in pairs(towers) do
		if not (skip and skip[n]) then
			T(n).attacks.range = T(n).attacks.range * factor
		end
	end
end

-- 等比缩放 sprite 的 scale（无 scale 时以 factor 初始化）
local function scale_sprite(s, factor)
	if s.scale then
		s.scale.x = s.scale.x * factor
		s.scale.y = s.scale.y * factor
	else
		s.scale = V.v(factor, factor)
	end
end

local upgrades = {}

upgrades.max_level = nil
upgrades.levels = {}
upgrades.levels.archers = 0
upgrades.levels.barracks = 0
upgrades.levels.mages = 0
upgrades.levels.engineers = 0
upgrades.levels.rain = 0
upgrades.levels.reinforcements = 0
upgrades.display_order = {"archers", "barracks", "mages", "engineers", "rain", "reinforcements"}
upgrades.list_id = 1
upgrades.list = {{
	archer_salvage = {
		cost_factor = 0.95,
		class = "archers",
		price = 1,
		level = 1,
		icon = 13
	},
	archer_eagle_eye = {
		range_factor = 1.25,
		class = "archers",
		price = 1,
		level = 2,
		icon = 14
	},
	archer_piercing = {
		class = "archers",
		reduce_armor_factor = 0.1,
		price = 2,
		level = 3,
		icon = 15
	},
	archer_far_shots = {
		range_factor = 1.05,
		class = "archers",
		price = 2,
		level = 4,
		icon = 16
	},
	archer_precision = {
		damage_factor = 2,
		class = "archers",
		chance = 0.1,
		price = 3,
		level = 5,
		icon = 17
	},
	archer_el_bloodletting_shoot = {
		from_kr = 3,
		price = 4,
		icon = 5,
		class = "archers",
		level = 6
	},
	barrack_survival = {
		health_factor = 1.1,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 8
	},
	barrack_better_armor = {
		class = "barracks",
		armor_increase = 0.1,
		price = 1,
		level = 2,
		icon = 9
	},
	barrack_improved_deployment = {
		cooldown_factor = 0.8,
		rally_range_factor = 1.2,
		class = "barracks",
		price = 2,
		level = 3,
		icon = 10
	},
	barrack_survival_2 = {
		health_factor = 1.09,
		class = "barracks",
		price = 2,
		level = 4,
		icon = 11
	},
	barrack_barbed_armor = {
		spiked_armor_factor = 0.1,
		class = "barracks",
		price = 3,
		level = 5,
		icon = 12
	},
	barrack_el_enchanted_armor = {
		from_kr = 3,
		class = "barracks",
		factor = 0.9,
		magic_armor_inc = 0.1,
		icon = 8,
		price = 4,
		level = 6
	},
	mage_spell_reach = {
		range_factor = 1.15,
		class = "mages",
		price = 1,
		level = 1,
		icon = 18
	},
	mage_arcane_shatter = {
		mod_normal = "mod_arcane_shatter",
		mod_little = "mod_arcane_shatter_little",
		class = "mages",
		price = 1,
		level = 2,
		icon = 19
	},
	mage_hermetic_study = {
		class = "mages",
		cost_factor = 0.91,
		price = 2,
		level = 3,
		icon = 20
	},
	mage_empowered_magic = {
		damage_factor = 1.15,
		class = "mages",
		price = 2,
		level = 4,
		icon = 21
	},
	mage_slow_curse = {
		mod = "mod_slow_curse",
		class = "mages",
		price = 3,
		level = 5,
		icon = 22
	},
	mage_brilliance = {
		from_kr = 2,
		class = "mages",
		icon = 15,
		price = 4,
		level = 6,
		damage_factors = {1.18, 1.21, 1.24, 1.27, 1.29, 1.31, 1.33, 1.35, 1.36}
	},
	engineer_concentrated_fire = {
		damage_factor = 1.25,
		class = "engineers",
		price = 1,
		level = 1,
		icon = 23
	},
	engineer_range_finder = {
		range_factor = 1.1,
		class = "engineers",
		price = 1,
		level = 2,
		icon = 24
	},
	engineer_field_logistics = {
		class = "engineers",
		cost_factor = 0.9,
		price = 2,
		level = 3,
		icon = 25
	},
	engineer_industrialization = {
		class = "engineers",
		cost_factor = 0.8,
		price = 3,
		level = 4,
		icon = 26
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = 27
	},
	engineer_gnomish_tinkering = {
		from_kr = 2,
		cooldown_factor_electric = 0.9,
		cooldown_factor = 0.88,
		class = "engineers",
		icon = 19,
		price = 4,
		level = 6
	},
	rain_blazing_skies = {
		fireball_count_increase = 2,
		class = "rain",
		damage_increase = 30,
		price = 2,
		level = 1,
		icon = 3
	},
	rain_scorched_earth = {
		price = 2,
		class = "rain",
		level = 2,
		icon = 4
	},
	rain_bigger_and_meaner = {
		range_factor = 1.25,
		cooldown_reduction = 10,
		class = "rain",
		damage_increase = 30,
		price = 3,
		level = 3,
		icon = 5
	},
	rain_blazing_earth = {
		cooldown_reduction = 10,
		class = "rain",
		price = 3,
		level = 4,
		icon = 6
	},
	rain_cataclysm = {
		class = "rain",
		damage_increase = 60,
		price = 3,
		level = 5,
		icon = 7
	},
	rain_armaggedon = {
		from_kr = 2,
		class = "rain",
		fireball_count_increase = 1,
		icon = 25,
		price = 4,
		level = 6
	},
	reinforcement_level_1 = {
		class = "reinforcements",
		template_name = "re_farmer_well_fed",
		price = 2,
		level = 1,
		icon = 28
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = 29
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = 30
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = 1
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = 2
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 2,
		cooldown_dec = 2,
		icon = 29,
		price = 4,
		level = 6
	}
}, {
	archer_far_shots = {
		from_kr = 2,
		range_factor = 1.25,
		class = "archers",
		price = 1,
		level = 1,
		icon = 1
	},
	archer_logger = {
		from_kr = 2,
		cost_factor = 0.9,
		class = "archers",
		price = 1,
		level = 2,
		icon = 2
	},
	archer_critical = {
		from_kr = 2,
		class = "archers",
		damage_factor = 1.1,
		price = 2,
		level = 3,
		icon = 3
	},
	archer_tear = {
		from_kr = 2,
		class = "archers",
		price = 2,
		level = 4,
		icon = 4
	},
	archer_fast_shots = {
		from_kr = 2,
		cooldown_factor = 0.9,
		class = "archers",
		price = 3,
		level = 5,
		icon = 5
	},
	archer_el_bloodletting_shoot = {
		from_kr = 3,
		price = 4,
		icon = 5,
		class = "archers",
		level = 6
	},
	barrack_bodies = {
		from_kr = 2,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 6
	},
	barrack_march = {
		from_kr = 2,
		class = "barracks",
		speed_inc = 12,
		rally_range_factor = 1.1,
		price = 1,
		level = 2,
		icon = 7
	},
	barrack_rally = {
		from_kr = 2,
		class = "barracks",
		rally_range_factor = 1.2,
		price = 2,
		level = 3,
		icon = 8
	},
	barrack_weapon = {
		from_kr = 2,
		damage_factor = 1.1,
		class = "barracks",
		price = 2,
		level = 4,
		icon = 9
	},
	barrack_go_on = {
		from_kr = 2,
		cooldown_factor = 0.8,
		class = "barracks",
		price = 3,
		level = 5,
		icon = 10
	},
	barrack_el_enchanted_armor = {
		from_kr = 3,
		class = "barracks",
		factor = 0.9,
		magic_armor_inc = 0.1,
		icon = 8,
		price = 4,
		level = 6
	},
	mage_arcane_spell = {
		from_kr = 2,
		damage_factor = 1.15,
		class = "mages",
		price = 1,
		level = 1,
		icon = 11
	},
	mage_strike = {
		from_kr = 2,
		class = "mages",
		price = 1,
		-- 出于减少向上查表的考虑，这里的概率直接放在匿名函数中
		level = 2,
		icon = 12
	},
	mage_spell_reach = {
		from_kr = 2,
		range_factor = 1.1,
		class = "mages",
		price = 2,
		level = 3,
		icon = 13
	},
	-- mage_power = {
	-- 	from_kr = 2,
	-- 	class = "mages",
	-- 	damage_factor = 1.1,
	-- 	price = 2,
	-- 	level = 3,
	-- 	icon = 13
	-- },
	mage_old_folk = {
		from_kr = 2,
		cost_factor = 0.85,
		class = "mages",
		price = 2,
		level = 4,
		icon = 14
	},
	mage_unsteady = {
		class = "mages",
		-- 这里同样直接放在匿名函数
		price = 3,
		level = 5,
		icon = 21
	},
	mage_brilliance = {
		from_kr = 2,
		class = "mages",
		icon = 15,
		price = 4,
		level = 6,
		damage_factors = {1.18, 1.21, 1.24, 1.27, 1.29, 1.31, 1.33, 1.35, 1.36}
	},
	engineer_range_finder = {
		from_kr = 2,
		range_factor = 1.15,
		class = "engineers",
		price = 1,
		level = 1,
		icon = 16
	},
	engineer_magic_dust = {
		from_kr = 2,
		class = "engineers",
		price = 1,
		level = 2,
		damage_factor = 1.2,
		icon = 17
	},
	engineer_concentrated_fire = {
		from_kr = 2,
		class = "engineers",
		damage_factor = 1.1,
		price = 2,
		level = 3,
		icon = 18
	},
	-- engineer_diffusion = {
	-- 	class = "engineers",
	-- 	radius_factor = 1.2,
	-- 	price = 3,
	-- 	level = 4,
	-- 	icon = 23
	-- },
	engineer_industrialization = {
		class = "engineers",
		cost_factor = 0.8,
		price = 3,
		level = 4,
		icon = 26
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = 27
	},
	engineer_gnomish_tinkering = {
		from_kr = 2,
		cooldown_factor_electric = 0.9,
		cooldown_factor = 0.88,
		class = "engineers",
		icon = 19,
		price = 4,
		level = 6
	},
	rain_blazing_skies = {
		fireball_count_increase = 3,
		class = "rain",
		damage_increase = 20,
		price = 2,
		level = 1,
		icon = 3
	},
	rain_scorched_earth = {
		price = 2,
		class = "rain",
		level = 2,
		icon = 4
	},
	rain_bigger_and_meaner = {
		range_factor = 1.25,
		cooldown_reduction = 12,
		class = "rain",
		damage_increase = 25,
		price = 3,
		level = 3,
		icon = 5
	},
	rain_blazing_earth = {
		cooldown_reduction = 12,
		class = "rain",
		price = 3,
		level = 4,
		icon = 6
	},
	rain_cataclysm = {
		class = "rain",
		damage_increase = 45,
		price = 3,
		level = 5,
		icon = 7
	},
	rain_armaggedon = {
		from_kr = 2,
		class = "rain",
		fireball_count_increase = 2,
		icon = 25,
		price = 4,
		level = 6
	},
	reinforcement_level_1 = {
		class = "reinforcements",
		template_name = "re_farmer_well_fed",
		price = 2,
		level = 1,
		icon = 28
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = 29
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = 30
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = 1
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = 2
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 1,
		cooldown_dec = 2.5,
		icon = 29,
		price = 4,
		level = 6
	}
}, {
	archer_salvage = {
		cost_factor = 0.95,
		class = "archers",
		price = 1,
		level = 1,
		icon = 13
	},
	archer_eagle_eye = {
		from_kr = 3,
		range_factor = 1.25,
		class = "archers",
		price = 1,
		level = 2,
		icon = 4
	},
	-- 黑曜石箭头：对护甲低于 10 的敌人造成额外伤害
	archer_obsidian = {
		from_kr = 3,
		class = "archers",
		price = 2,
		level = 3,
		icon = 2,
		damage_factor = 1.27
	},
	archer_far_shots = {
		range_factor = 1.05,
		class = "archers",
		price = 2,
		level = 4,
		icon = 16
	},
	-- 附魔箭矢：攻击附带法术伤害
	archer_magic = {
		from_kr = 3,
		class = "archers",
		price = 3,
		level = 5,
		factor = 0.12,
		icon = 3
	},
	archer_el_bloodletting_shoot = {
		from_kr = 3,
		price = 4,
		icon = 5,
		class = "archers",
		level = 6
	},
	barrack_survival = {
		health_factor = 1.1,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 8
	},
	barrack_better_armor = {
		class = "barracks",
		armor_increase = 0.1,
		price = 1,
		level = 2,
		icon = 9
	},
	barrack_go_on = {
		from_kr = 2,
		cooldown_factor = 0.75,
		class = "barracks",
		price = 2,
		level = 3,
		icon = 10
	},
	barrack_survival_2 = {
		health_factor = 1.05,
		class = "barracks",
		price = 2,
		level = 4,
		icon = 11
	},
	barrack_mobilize = {
		from_kr = 2,
		class = "barracks",
		icon = 7,
		level = 5,
		price = 3,
		price_factor = 0.8
	},
	barrack_dominant = {
		from_kr = 3,
		icon = 7,
		level = 6,
		class = "barracks",
		price = 4,
		rally_range_factor = 2,
		speed_factor = 1.2
	},
	mage_spell_reach = {
		range_factor = 1.15,
		class = "mages",
		price = 1,
		level = 1,
		from_kr = 3,
		icon = 11
	},
	mage_empowered_magic = {
		damage_factor = 1.15,
		class = "mages",
		price = 1,
		level = 2,
		from_kr = 3,
		icon = 12
	},
	mage_spell_reach_2 = {
		range_factor = 1.05,
		class = "mages",
		price = 2,
		level = 3,
		from_kr = 3,
		icon = 15
	},
	mage_old_folk = {
		from_kr = 2,
		cost_factor = 0.9,
		class = "mages",
		price = 2,
		level = 4,
		icon = 14
	},
	mage_treasure = {
		from_kr = 3,
		extra_gold_factor = 0.01,
		max_extra_gold_factor = 0.1,
		price = 3,
		level = 5,
		icon = 13,
		class = "mages"
	},
	mage_brilliance = {
		from_kr = 2,
		class = "mages",
		icon = 15,
		price = 4,
		level = 6,
		damage_factors = {1.18, 1.21, 1.24, 1.27, 1.29, 1.31, 1.33, 1.35, 1.36}
	},
	engineer_concentrated_fire = {
		damage_factor = 1.25,
		class = "engineers",
		price = 1,
		level = 1,
		icon = 16,
		from_kr = 3
	},
	engineer_diffusion = {
		class = "engineers",
		radius_factor = 1.15,
		price = 1,
		level = 2,
		icon = 17,
		from_kr = 3
	},
	engineer_range_finder = {
		from_kr = 3,
		range_factor = 1.15,
		class = "engineers",
		price = 2,
		level = 3,
		icon = 18
	},
	engineer_field_logistics = {
		class = "engineers",
		cost_factor = 0.88,
		price = 3,
		level = 4,
		icon = 25
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = 20,
		from_kr = 3
	},
	engineer_gnomish_tinkering = {
		from_kr = 2,
		cooldown_factor_electric = 0.9,
		cooldown_factor = 0.88,
		class = "engineers",
		icon = 19,
		price = 4,
		level = 6
	},
	reinforcement_level_1 = {
		class = "reinforcements",
		template_name = "re_farmer_well_fed",
		price = 2,
		level = 1,
		icon = 28
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = 29
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = 30
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = 1
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = 2
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 2,
		cooldown_dec = 2,
		icon = 29,
		price = 4,
		level = 6
	},
	thunder_level_1 = {
		hits = 6,
		class = "rain",
		icon = 21,
		price = 2,
		level = 1,
		from_kr = 3
	},
	thunder_level_2 = {
		price = 2,
		icon = 22,
		class = "rain",
		level = 2,
		from_kr = 3
	},
	thunder_level_3 = {
		price = 3,
		icon = 23,
		class = "rain",
		level = 3,
		from_kr = 3
	},
	thunder_level_4 = {
		price = 3,
		icon = 24,
		class = "rain",
		level = 4,
		from_kr = 3
	},
	thunder_level_5 = {
		price = 3,
		icon = 25,
		class = "rain",
		level = 5,
		from_kr = 3
	},
	thunder_level_6 = {
		from_kr = 3,
		price = 4,
		icon = 10,
		class = "rain",
		level = 6
	}
}, {
	archer_salvage = {
		cost_factor = 0.95,
		class = "archers",
		price = 1,
		level = 1,
		icon = 13
	},
	archer_eagle_eye = {
		range_factor = 1.25,
		class = "archers",
		price = 1,
		level = 2,
		icon = 14
	},
	archer_logger = {
		cost_factor = 0.9,
		class = "archers",
		price = 2,
		level = 3,
		icon = 2,
		from_kr = 2
	},
	archer_far_shots = {
		range_factor = 1.05,
		class = "archers",
		price = 2,
		level = 4,
		icon = 16
	},
	archer_fly_killer = {
		damage_factor = 1.08,
		damage_factor_fly = 1.25,
		class = "archers",
		price = 3,
		level = 5,
		icon = 4,
		from_kr = 2
	},
	archer_el_bloodletting_shoot = {
		price = 4,
		icon = 5,
		class = "archers",
		level = 6,
		from_kr = 3
	},
	barrack_survival = {
		health_factor = 1.1,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 8
	},
	barrack_better_armor = {
		class = "barracks",
		armor_increase = 0.1,
		price = 1,
		level = 2,
		icon = 9
	},
	barrack_improved_deployment = {
		cooldown_factor = 0.8,
		rally_range_factor = 1.25,
		class = "barracks",
		price = 2,
		level = 3,
		icon = 10
	},
	barrack_survival_2 = {
		health_factor = 1.05,
		class = "barracks",
		price = 2,
		level = 4,
		icon = 11
	},
	barrack_skill_master = {
		class = "barracks",
		price_factor = 0.9,
		price = 3,
		level = 5,
		icon = 7,
		from_kr = 2
	},
	barrack_el_enchanted_armor = {
		class = "barracks",
		factor = 0.9,
		magic_armor_inc = 0.1,
		icon = 8,
		price = 4,
		level = 6,
		from_kr = 3
	},
	mage_spell_reach = {
		range_factor = 1.15,
		class = "mages",
		price = 1,
		level = 1,
		icon = 18
	},
	mage_empowered_magic = {
		damage_factor = 1.15,
		class = "mages",
		price = 1,
		level = 2,
		icon = 19
	},
	mage_rune_analysis = {
		cost_factor = 0.94,
		class = "mages",
		price = 2,
		level = 3,
		icon = 20
	},
	mage_slow_curse = {
		mod = "mod_slow_curse",
		class = "mages",
		price = 2,
		level = 4,
		icon = 22
	},
	mage_harmony = {
		from_kr = 2,
		range_factor = 1.07,
		damage_factor = 1.07,
		class = "mages",
		price = 3,
		level = 5,
		icon = 11
	},
	mage_purge_field = {
		class = "mages",
		price = 4,
		level = 6,
		icon = 21
	},
	engineer_concentrated_fire = {
		damage_factor = 1.25,
		class = "engineers",
		price = 1,
		level = 1,
		icon = 23
	},
	engineer_range_finder = {
		range_factor = 1.1,
		class = "engineers",
		price = 1,
		level = 2,
		icon = 24
	},
	engineer_emergency_expansion = {
		class = "engineers",
		cost_factor = 0.75,
		damage_factor = 0.88,
		price = 2,
		level = 3,
		icon = 25
	},
	engineer_industrialization = {
		class = "engineers",
		cost_factor = 0.8,
		price = 3,
		level = 4,
		icon = 26
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = 27
	},
	engineer_gnomish_tinkering = {
		from_kr = 2,
		cooldown_factor_electric = 0.9,
		cooldown_factor = 0.88,
		class = "engineers",
		icon = 19,
		price = 4,
		level = 6
	},
	thunder_level_1 = {
		hits = 6,
		class = "rain",
		icon = 21,
		price = 2,
		level = 1,
		from_kr = 3
	},
	thunder_level_2 = {
		price = 2,
		icon = 22,
		class = "rain",
		level = 2,
		from_kr = 3
	},
	thunder_level_3 = {
		price = 3,
		icon = 23,
		class = "rain",
		level = 3,
		from_kr = 3
	},
	thunder_level_4 = {
		price = 3,
		icon = 24,
		class = "rain",
		level = 4,
		from_kr = 3
	},
	thunder_level_5 = {
		price = 3,
		icon = 25,
		class = "rain",
		level = 5,
		from_kr = 3
	},
	thunder_typhoon = {
		from_kr = 3,
		price = 4,
		icon = 21,
		class = "rain",
		level = 6
	},
	reinforcement_level_1 = {
		class = "reinforcements",
		template_name = "re_farmer_well_fed",
		price = 2,
		level = 1,
		icon = 28
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = 29
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = 30
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = 1
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = 2
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 1,
		cooldown_dec = 2.5,
		icon = 29,
		price = 4,
		level = 6
	}
}}
upgrades.list_count = #upgrades.list

function upgrades:toggle_list_id()
	self.list_id = self.list_id % self.list_count + 1
end

function upgrades:set_list_id(id)
	self.list_id = id or 1
end

function upgrades:set_levels(levels)
	for k, v in pairs(levels) do
		self.levels[k] = v
	end
end

function upgrades:has_upgrade(name)
	local u = self.list[self.list_id][name]

	return u and u.level <= self.levels[u.class] and (not self.max_level or u.level <= self.max_level)
end

function upgrades:get_upgrade(name)
	local u = self.list[self.list_id][name]

	if not u or u.level > self.levels[u.class] or not self.max_level or u.level > self.max_level then
		return nil
	else
		return u
	end
end

function upgrades:get_total_stars()
	local total = 0

	for k, v in pairs(self.list[self.list_id]) do
		total = total + v.price
	end

	return total
end

local GS = require("kr1.game_settings")

upgrades.archer_towers = GS.archer_towers

upgrades.arrows = {
	"arrow_1",
	"arrow_2",
	"arrow_3",
	"arrow_ranger",
	"shotgun_musketeer",
	"shotgun_musketeer_sniper",
	"shotgun_musketeer_sniper_instakill",
	"arrow_crossbow",
	"axe_totem",
	"dwarf_shotgun",
	"pirate_watchtower_shotgun",
	"arrow_arcane",
	"arrow_arcane_slumber",
	"arrow_silver",
	"arrow_silver_long",
	"arrow_silver_sentence",
	"arrow_silver_mark",
	"arrow_silver_mark_long",
	"arrow_hero_elves_archer",
	"arrow_hero_alleria",
	"bullet_asra",
	"bullet_onix_asra",
	"multishot_crossbow",
	"knife_catha",
	"bullet_tower_dark_elf_lvl4",
	"bullet_tower_sand_lvl4",
	"bullet_tower_sand_skill_gold",
	"arrow_armor_piercer_royal_archers",
	"tower_royal_archers_arrow_lvl4",
	"bullet_tower_ballista_lvl4",
	"bullet_tower_ballista_skill_final_shot",
	"arrow_hero_vesper_long_arrow",
	"arrow_hero_vesper_short_arrow",
	"arrow_tower_shadow_archer",
	"arrow_tower_shadow_archer_mark",
	"bone_flingers_bone",
	"bone_flingers_bone_golem",
	"bullet_ogre_shipwreck_musket",
	"bullet_ogre_shipwreck_musket_volley_lvl1",
	"bullet_ogre_shipwreck_musket_volley_lvl2",
	"goblirang",
	"goblirang_big",
	"bullet_shaolin",
	"bullet_swamp_monster",
	"bullet_swamp_monster_bomb",
	"bullet_swamp_monster_bomb_tosky",
	"bullet_archers",
	"bullet_archers_skill_a"
}

upgrades.soldiers = {
	"soldier_militia",
	"soldier_footmen",
	"soldier_knight",
	"soldier_paladin",
	"soldier_barbarian",
	"soldier_elf",
	"soldier_elemental",
	"soldier_skeleton",
	"soldier_skeleton_knight",
	"soldier_death_rider",
	"soldier_templar",
	"soldier_assassin",
	"soldier_dwarf",
	"soldier_amazona",
	"soldier_djinn",
	"soldier_pirate_flamer",
	"soldier_frankenstein",
	"soldier_blade",
	"soldier_forest",
	"soldier_druid_bear",
	"soldier_drow",
	"soldier_ewok",
	"soldier_baby_ashbite",
	"soldier_tower_dark_elf",
	"soldier_tower_barrel_skill_warrior",
	"soldier_tower_demon_pit_basic_attack_lvl4",
	"big_guy_tower_demon_pit_lvl4",
	"soldier_tower_necromancer_skeleton_lvl4",
	"soldier_tower_necromancer_skeleton_golem_lvl4",
	"soldier_tower_pandas_green_lvl4",
	"soldier_tower_pandas_red_lvl4",
	"soldier_tower_pandas_blue_lvl4",
	"soldier_tower_rocket_gunners_lvl4",
	"soldier_tower_ghost_lvl4",
	"soldier_tower_dwarf_lvl4",
	"tower_paladin_covenant_soldier_lvl4",
	"soldier_bone_golem",
	"soldier_flingers_skeleton",
	"soldier_flingers_skeleton_warrior",
	"soldier_ogre_shipwreck_cook",
	"soldier_ogre_shipwreck_deckhand",
	"soldier_ogre_shipwreck_red_goblin",
	"soldier_ogre_shipwreck_red_goblin_elite",
	"soldier_orc_warrior",
	"soldier_orc_warrior_captain",
	"soldier_dark_knight",
	"soldier_zombie",
	"soldier_zombie_medium",
	"soldier_zombie_big",
	"soldier_gargoyle",
	"soldier_elves_harasser",
	"soldier_elves_espectral_harasser",
	"soldier_deep_devils",
	"soldier_deep_devils_chosen",
	"soldier_ignis_altar_elemental",
	"soldier_dragon",
	"soldier_swamp_monster",
	"soldier_tower_sandworm_1",
	"soldier_tower_sandworm_2",
	"soldier_priests_barrack",
	"soldier_abomination_priests_barrack",
	"soldier_knights"
}

upgrades.barrack_soldiers = {
	"soldier_militia",
	"soldier_footmen",
	"soldier_knight",
	"soldier_paladin",
	"soldier_barbarian",
	"soldier_elf",
	"soldier_templar",
	"soldier_assassin",
	"soldier_dwarf",
	"soldier_amazona",
	"soldier_djinn",
	"soldier_pirate_flamer",
	"soldier_blade",
	"soldier_forest",
	"soldier_drow",
	"soldier_ewok",
	"soldier_baby_ashbite",
	"soldier_tower_pandas_green_lvl4",
	"soldier_tower_pandas_red_lvl4",
	"soldier_tower_pandas_blue_lvl4",
	"soldier_tower_rocket_gunners_lvl4",
	"soldier_tower_ghost_lvl4",
	"soldier_tower_dwarf_lvl4",
	"tower_paladin_covenant_soldier_lvl4",
	"soldier_ogre_shipwreck_cook",
	"soldier_ogre_shipwreck_deckhand",
	"soldier_ogre_shipwreck_red_goblin",
	"soldier_ogre_shipwreck_red_goblin_elite",
	"soldier_orc_warrior",
	"soldier_orc_warrior_captain",
	"soldier_dark_knight",
	"soldier_zombie",
	"soldier_zombie_medium",
	"soldier_zombie_big",
	"soldier_elves_harasser",
	"soldier_elves_espectral_harasser",
	"soldier_swamp_monster",
	"soldier_priests_barrack",
	"soldier_abomination_priests_barrack",
	"soldier_knights"
}

upgrades.towers_with_barrack = {
	"tower_barrack_1",
	"tower_barrack_2",
	"tower_barrack_3",
	"tower_paladin",
	"tower_barbarian",
	"tower_sorcerer",
	"tower_elf",
	"tower_templar",
	"tower_assassin",
	"tower_mech",
	"tower_necromancer",
	"tower_barrack_dwarf",
	"tower_barrack_amazonas",
	"tower_barrack_mercenaries",
	"tower_barrack_pirates",
	"tower_frankenstein",
	"tower_blade",
	"tower_forest",
	"tower_druid",
	"tower_drow",
	"tower_ewok",
	"tower_baby_ashbite",
	"tower_dark_elf_lvl4",
	"tower_pandas_lvl4",
	"tower_rocket_gunners_lvl4",
	"tower_ghost_lvl4",
	"tower_dwarf_lvl4",
	"tower_barrel_lvl4",
	"tower_paladin_covenant_lvl4",
	"tower_bone_flingers",
	"tower_ogre_shipwreck",
	"tower_orc_warriors",
	"tower_dark_knights",
	"tower_grim_cemetery",
	"tower_twilight_elves_barrack",
	"tower_swamp_monster",
	"tower_wicked_sisters",
	"tower_balloon",
	"tower_spirit_mausoleum",
	"tower_deep_devils",
	"tower_ignis_altar",
	"tower_shaolin",
	"tower_stage_28_priests_barrack",
	"tower_knights"
}

upgrades.non_barrack_towers_with_barrack_attribute = {
	"tower_sorcerer",
	"tower_mech",
	"tower_necromancer",
	"tower_frankenstein",
	"tower_druid",
	"tower_dark_elf_lvl4",
	"tower_bone_flingers",
	"tower_balloon",
	"tower_spirit_mausoleum",
	"tower_deep_devils",
	"tower_ignis_altar",
	"tower_shaolin",
	"tower_swamp_monster",
	"tower_wicked_sisters"
}

upgrades.mage_towers = GS.mage_towers

upgrades.mage_tower_bolts = {
	"bolt_1",
	"bolt_2",
	"bolt_3",
	"ray_arcane",
	"bolt_sorcerer",
	"bolt_archmage",
	"ray_sunray",
	"bolt_necromancer_tower",
	"bolt_high_elven_strong",
	"bolt_high_elven_weak",
	"bolt_wild_magus",
	"bolt_faerie_dragon",
	"bullet_tower_necromancer_lvl4",
	"bullet_tower_necromancer_deathspawn",
	"bullet_tower_ray_lvl4",
	"bullet_tower_ray_chain",
	"tower_elven_stargazers_ray",
	"tower_arcane_wizard5_ray",
	"bullet_tower_hermit_toad_mage_basic_lvl4",
	"tower_arborean_emissary_bolt_lvl4",
	"bolt_faerie_dragon_lvl4",
	"bolt_infernal_mage",
	"bolt_orc_shaman",
	"bolt_tower_spirit_mausoleum",
	"bolt_tower_deep_devils",
	"ray_deep_devils",
	"bullet_tower_blazing_watcher",
	"wicked_sisters_proy_green",
	"wicked_sisters_proy_pink",
	"bolt_tower_wizard"
}

local other_bolts = {
	"bolt_elora_freeze",
	"bolt_elora_slow",
	"bolt_magnus",
	"bolt_magnus_illusion",
	"bolt_priest",
	"bolt_voodoo_witch",
	"bolt_veznan",
	"ray_arivan_simple",
	"bullet_rag",
	"ray_wizard",
	"ray_wizard_chain",
	"bolt_hero_space_elf_basic_attack",
	"bullet_hero_witch_basic_1",
	"bullet_hero_witch_basic_2",
	"bolt_lumenir",
	"bullet_tower_pandas_ray_lvl4",
	"bullet_tower_pandas_fire_lvl4",
	"bullet_tower_pandas_air_lvl4",
	"tower_arcane_wizard5_ray_disintegrate",
	"hero_muyrn_bullet",
	"bolt_hero_spider_basic_attack",
	"bolt_oloch",
	"bolt_oloch_big",
	"bolt_oloch_duplication",
	"bolt_mortemis"
}

upgrades.bolts = table.append(other_bolts, upgrades.mage_tower_bolts)

upgrades.engineer_towers = GS.engineer_towers

upgrades.engineer_bombs = {
	"bomb",
	"bomb_dynamite",
	"bomb_black",
	"bomb_bfg",
	"bomb_mecha",
	"rock_druid",
	"rock_entwood",
	"rock_firey_nut",
	"tower_tricannon_bomb",
	"bullet_tower_demon_pit_basic_attack_lvl4",
	"bullet_tower_demon_pit_big_guy_lvl4",
	"bullet_tower_barrel_lvl4",
	"bullet_tower_hermit_toad_engineer_basic_lvl4",
	"tower_sparking_geode_ray_lvl4",
	"bomb_ogre_shipwreck_goblin",
	"bomb_ogre_shipwreck_goblin_skill1",
	"bomb_ogre_shipwreck_goblin_skill2",
	"missile_rr",
	"missile_rr_nitro",
	"bomb_balloon",
	"bullet_balloon_oil",
	"bullet_catapult",
	"bullet_catapult_skill_a",
	"bullet_catapult_ultimate",
	"bullet_skill_c_wizard_2"
}

upgrades.engineer_advanced_tower = {
	"tower_bfg",
	"tower_tesla",
	"tower_dwaarp",
	"tower_mech",
	"tower_frankenstein",
	"tower_druid",
	"tower_entwood",
	"tower_tricannon_lvl4",
	"tower_demon_pit_lvl4",
	"tower_flamespitter_lvl4",
	"tower_barrel_lvl4",
	"tower_sparking_geode_lvl4",
	"tower_rotten_forest",
	"tower_rocket_riders",
	"tower_balloon",
	"tower_ignis_altar",
	"tower_melting_furnace",
	"tower_sandworm",
	"tower_catapult",
	"tower_culverine"
}

local fps_based_keys = table.to_map({"hit_time", "cast_time", "shoot_time", "dodge_time", "cycle_time", "shoot_times", "hit_times"})

local function scale_fps_based_keys(tbl, factor, visited)
	visited = visited or {}

	if visited[tbl] then
		return
	end

	visited[tbl] = true

	for k, v in pairs(tbl) do
		-- 跳过 _origin_xxx 字段，避免递归
		if fps_based_keys[k] then
			local _origin_key = "_origin_" .. k

			if not tbl[_origin_key] then
				tbl[_origin_key] = table.deepclone(v)
			end
			if type(v) == "number" then
				tbl[k] = tbl[_origin_key] * factor
			else
				for i = 1, #v do
					v[i] = tbl[_origin_key][i] * factor
				end
			end
		elseif type(v) == "table" then
			scale_fps_based_keys(v, factor, visited)
		end
	end
end

function upgrades:bomb_damage_mul(damage_factor)
	for _, n in ipairs(self.engineer_bombs) do
		mul_dmg(T(n).bullet, damage_factor)
	end

	mul_dmg(T("tower_dwaarp").attacks.list[1], damage_factor)
	mul_dmg(T("tower_melting_furnace").attacks.list[1], damage_factor)
	mul_dmg(T("ray_tesla"), damage_factor, "bounce_damage_min", "bounce_damage_max")
	mul_dmg(T("mod_ray_frankenstein").dps, damage_factor)
	mul_dmg(T("tower_flamespitter_lvl4").attacks.list[1], damage_factor)
	mul_dmg(T("mod_tower_rotten_forest_burst_damage").dps, damage_factor)
	mul_dmg(T("mod_ignis_altar_damage"), damage_factor)
	mul_dmg(T("aura_tower_sandworm").aura, damage_factor)
	mul_dmg(T("soldier_tower_demon_pit_basic_attack_lvl4"), damage_factor, "explosion_damage_min", "explosion_damage_max")
	mul_dmg(T("aura_bullet_culverine").aura, damage_factor)
	mul_dmg(T("aura_bullet_culverine_skill_b").aura, damage_factor)
	mul_dmg(T("aura_culverine_ultimate").aura, damage_factor)
end

function upgrades:mage_bolt_damage_mul(damage_factor)
	for _, n in ipairs(self.mage_tower_bolts) do
		mul_dmg(T(n).bullet, damage_factor)
	end

	mul_dmg(T("mod_ray_arcane").dps, damage_factor)
	mul_dmg(T("mod_pixie_pickpocket").modifier, damage_factor)
	mul_field(T("mod_ultimate_wizard"), "damage", damage_factor)

	local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

	for k, v in ipairs(d) do
		d[k] = v * damage_factor
	end

	mul_dmg(T("mod_lava_infernal_mage").dps, damage_factor)
	mul_dmg(T("mod_wicked_sister_poison").dps, damage_factor)
end

function upgrades:patch_templates(max_level)
	if max_level then
		self.max_level = max_level
	end

	local u
	local archer_towers = self.archer_towers

	u = self:get_upgrade("archer_salvage")

	if u then
		scale_tower_price(archer_towers, u.cost_factor, math.ceil)
	end

	u = self:get_upgrade("archer_eagle_eye")

	if u then
		scale_tower_attack_range(archer_towers, u.range_factor)
	end

	u = self:get_upgrade("archer_piercing")

	if u then
		for _, n in pairs(self.arrows) do
			local reduce_armor = T(n).bullet.reduce_armor

			if type(reduce_armor) == "table" then
				for k, v in pairs(reduce_armor) do
					reduce_armor[k] = v + u.reduce_armor_factor
				end
			else
				T(n).bullet.reduce_armor = u.reduce_armor_factor + reduce_armor
			end
		end
	end

	u = self:get_upgrade("archer_far_shots")

	if u then
		scale_tower_attack_range(archer_towers, u.range_factor)
	end

	u = self:get_upgrade("archer_logger")
	if u then
		scale_power_prices(archer_towers, u.cost_factor, math.ceil)
	end

	u = self:get_upgrade("archer_critical")
	if u then
		scale_tower_damage(GS.archer_towers, u.damage_factor)
	end

	local function apply_mod(bullet, mod_name)
		if bullet.mods then
			bullet.mods[#bullet.mods + 1] = mod_name
		elseif bullet.mod then
			bullet.mods = {bullet.mod, mod_name}
			bullet.mod = nil
		else
			bullet.mods = {mod_name}
		end
	end

	u = self:get_upgrade("archer_obsidian")
	if u then
		local archer_obsidian_factor = u.damage_factor
		add_damage_hooks(self.arrows, function(entity, damage, protection)
			if protection <= 0.1 then
				damage.value = damage.value * archer_obsidian_factor
			end
		end)
	end

	u = self:get_upgrade("archer_tear")
	if u then
		for _, n in ipairs(self.arrows) do
			local b = T(n).bullet
			if b.damage_min and b.damage_max then
				local damage_avg = (b.damage_min + b.damage_max) / 2
				if damage_avg > 40 then
					apply_mod(b, "mod_archer_tear_big")
				elseif damage_avg > 20 then
					apply_mod(b, "mod_archer_tear")
				elseif damage_avg > 10 then
					apply_mod(b, "mod_archer_tear_small")
				else
					apply_mod(b, "mod_archer_tear_tiny")
				end
			end
		end
	end

	u = self:get_upgrade("archer_magic")
	if u then
		T("mod_archer_magic")._mod_archer_magic_factor = u.factor
		for _, n in ipairs(self.arrows) do
			local b = T(n).bullet
			apply_mod(b, "mod_archer_magic")
		end
	end

	u = self:get_upgrade("archer_fast_shots")
	if u then
		for _, n in pairs(archer_towers) do
			local t = T(n)
			t.tower.cooldown_factor_divider = t.tower.cooldown_factor_divider + (1 - u.cooldown_factor)
			t.tower.cooldown_factor = 1.0 / t.tower.cooldown_factor_divider
			if t.render then
				for _, s in pairs(t.render.sprites) do
					if not s._origin_fps then
						if not s.fps then
							s._origin_fps = FPS
						else
							s._origin_fps = s.fps
						end
					end
					s.fps = s._origin_fps * t.tower.cooldown_factor
				end
				scale_fps_based_keys(t, t.tower.cooldown_factor)
			end
		end
	end

	u = self:get_upgrade("archer_fly_killer")
	if u then
		scale_tower_damage(archer_towers, u.damage_factor)
		local damage_factor_fly = u.damage_factor_fly
		for _, n in ipairs(self.arrows) do
			local tpl = T(n)

			if tpl.main_script.insert then
				local original_insert = tpl.main_script.insert
				tpl.main_script.insert = function(this, store)
					if not original_insert(this, store) then
						return false
					end
					local target = store.entities[this.bullet.target_id]
					if target and bit.band(target.vis.flags, F_FLYING) ~= 0 then
						this.bullet.damage_factor = this.bullet.damage_factor * damage_factor_fly
					end
					return true
				end
			else
				tpl.main_script.insert = function(this, store)
					local target = store.entities[this.bullet.target_id]
					if target and bit.band(target.vis.flags, F_FLYING) ~= 0 then
						this.bullet.damage_factor = this.bullet.damage_factor * damage_factor_fly
					end
					return true
				end
			end
		end
	end

	u = self:get_upgrade("archer_el_bloodletting_shoot")

	if u then
		for _, n in pairs(self.arrows) do
			local b = T(n).bullet
			apply_mod(b, "mod_blood_elves")
		end
	end

	local soldiers = self.soldiers
	local barrack_soldiers = self.barrack_soldiers
	local towers_with_barrack = self.towers_with_barrack
	local barrack_towers = GS.barrack_towers

	local function apply_soldier_health_factor(health_factor)
		for _, n in ipairs(soldiers) do
			T(n).health.hp_max = T(n).health.hp_max * health_factor
		end
		-- 特殊处理
		local tt = E:get_template("big_guy_tower_demon_pit_lvl4")
		for i = 1, #tt.health_level do
			tt.health_level[i] = tt.health_level[i] * health_factor
		end
	end

	u = self:get_upgrade("barrack_survival")

	if u then
		apply_soldier_health_factor(u.health_factor)
	end

	u = self:get_upgrade("barrack_bodies")

	if u then
		for _, n in pairs(GS.barrack_towers) do
			if n ~= "tower_baby_ashbite" and n ~= "tower_pandas_lvl4" then
				local t = T(n)
				t.barrack.max_soldiers = t.barrack.max_soldiers + 1
			end
		end
		local special_soldiers = {"soldier_baby_ashbite", "soldier_tower_pandas_green_lvl4", "soldier_tower_pandas_red_lvl4", "soldier_tower_pandas_blue_lvl4", "soldier_ogre_shipwreck_cook", "soldier_ogre_shipwreck_deckhand", "soldier_ogre_shipwreck_red_goblin", "soldier_ogre_shipwreck_red_goblin_elite", "soldier_swamp_monster"}

		for _, n in ipairs(special_soldiers) do
			local t = T(n)
			t.unit.damage_factor = t.unit.damage_factor * 1.3
		end

		for _, n in pairs(barrack_soldiers) do
			local t = T(n)
			if t.health.hp_max and not table.contains(special_soldiers, n) then
				t.health.hp_max = t.health.hp_max * 0.8
			end
		end
	end

	u = self:get_upgrade("barrack_march")
	if u then
		for _, n in pairs(towers_with_barrack) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
		for _, n in ipairs(soldiers) do
			T(n).motion.max_speed = T(n).motion.max_speed + u.speed_inc
		end
		T("soldier_tower_rocket_gunners_lvl4").speed_flight = T("soldier_tower_rocket_gunners_lvl4").speed_flight + u.speed_inc
		T("soldier_tower_rocket_gunners_lvl4").speed_ground = T("soldier_tower_rocket_gunners_lvl4").speed_ground + u.speed_inc
	end

	u = self:get_upgrade("barrack_rally")
	if u then
		for _, n in pairs(towers_with_barrack) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
	end

	u = self:get_upgrade("barrack_weapon")
	if u then
		for _, n in ipairs(soldiers) do
			T(n).unit.damage_factor = T(n).unit.damage_factor * u.damage_factor
		end
	end

	u = self:get_upgrade("barrack_go_on")
	if u then
		for _, n in ipairs(soldiers) do
			T(n).health.dead_lifetime = T(n).health.dead_lifetime * u.cooldown_factor
		end
	end

	u = self:get_upgrade("barrack_better_armor")

	if u then
		for _, n in ipairs(soldiers) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
		local tt = T("soldier_frankenstein")
		for i = 1, #tt.health.armor_lvls do
			tt.health.armor_lvls[i] = tt.health.armor_lvls[i] + u.armor_increase
		end
	end

	u = self:get_upgrade("barrack_improved_deployment")

	if u then
		for _, n in ipairs(soldiers) do
			T(n).health.dead_lifetime = T(n).health.dead_lifetime * u.cooldown_factor
		end

		for _, n in pairs(towers_with_barrack) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
	end

	u = self:get_upgrade("barrack_survival_2")

	if u then
		apply_soldier_health_factor(u.health_factor)
	end

	u = self:get_upgrade("barrack_barbed_armor")

	if u then
		for _, t in pairs(E:filter_templates("soldier")) do
			if t.health then
				t.health.spiked_armor = t.health.spiked_armor + u.spiked_armor_factor
			end
		end
	end

	u = self:get_upgrade("barrack_el_enchanted_armor")

	if u then
		for _, t in pairs(E:filter_templates("soldier")) do
			if t.health and not t.hero then
				t.health.damage_factor = u.factor
				t.health.magic_armor = t.health.magic_armor + u.magic_armor_inc
			end
		end
	end

	u = self:get_upgrade("barrack_mobilize")
	if u then
		scale_tower_price(barrack_towers, u.price_factor, math.floor)
	end

	u = self:get_upgrade("barrack_skill_master")
	if u then
		scale_tower_price(barrack_towers, u.price_factor, math.floor)
		scale_power_prices(barrack_towers, u.price_factor, math.ceil)
	end

	u = self:get_upgrade("barrack_dominant")
	if u then
		for _, n in ipairs(towers_with_barrack) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
		for _, n in ipairs(soldiers) do
			T(n).motion.max_speed = T(n).motion.max_speed * u.speed_factor
		end
		T("soldier_tower_rocket_gunners_lvl4").speed_flight = T("soldier_tower_rocket_gunners_lvl4").speed_flight * u.speed_factor
		T("soldier_tower_rocket_gunners_lvl4").speed_ground = T("soldier_tower_rocket_gunners_lvl4").speed_ground * u.speed_factor
	end

	local mage_towers = self.mage_towers

	u = self:get_upgrade("mage_spell_reach")

	if u then
		scale_tower_attack_range(mage_towers, u.range_factor)
	end

	u = self:get_upgrade("mage_spell_reach_2")
	if u then
		scale_tower_attack_range(mage_towers, u.range_factor)
	end

	u = self:get_upgrade("mage_arcane_shatter")

	local function add_mods(b, mods)
		if b.mod then
			table.insert(mods, b.mod)
		end

		if b.mods then
			table.append(mods, b.mods)
		end

		b.mod = nil
		b.mods = mods
	end

	if u then
		for _, n in ipairs(self.bolts) do
			local b = T(n).bullet
			local mods

			if (b.damage_max and b.damage_max >= 50) or b.template_name == "ray_arcane" then
				mods = {u.mod_normal}
			else
				mods = {u.mod_little}
			end

			add_mods(b, mods)
		end

		add_mods(T("tower_pixie").attacks.list[4], {u.mod_normal})
	end

	u = self:get_upgrade("mage_treasure")
	if u then
		T("mod_mage_treasure").extra_gold_factor = u.extra_gold_factor
		T("mod_mage_treasure").max_extra_gold_factor = u.max_extra_gold_factor
		for _, n in ipairs(self.mage_tower_bolts) do
			local b = T(n).bullet
			add_mods(b, {"mod_mage_treasure"})
		end
		add_mods(T("tower_pixie").attacks.list[4], {"mod_mage_treasure"})
	end

	u = self:get_upgrade("mage_hermetic_study")

	if u then
		scale_tower_price(mage_towers, u.cost_factor, math.ceil)
	end

	u = self:get_upgrade("mage_rune_analysis")

	if u then
		scale_tower_price(mage_towers, u.cost_factor, math.ceil)
		scale_power_prices(mage_towers, u.cost_factor, math.ceil)
	end

	u = self:get_upgrade("mage_purge_field")

	if u then
		for _, n in ipairs(mage_towers) do
			local t = T(n)
			if t.main_script.insert then
				local insert = t.main_script.insert
				t.main_script.insert = function(this, store)
					if not insert(this, store) then
						return false
					end
					local e = E:create_entity("controller_mage_purge_field")
					e.target_id = this.id
					simulation:queue_insert_entity(e)

					return true
				end
			else
				t.main_script.insert = function(this, store)
					local e = E:create_entity("controller_mage_purge_field")
					e.target_id = this.id
					simulation:queue_insert_entity(e)

					return true
				end
			end
		end
	end

	u = self:get_upgrade("mage_old_folk")
	if u then
		scale_power_prices(mage_towers, u.cost_factor, math.ceil)
	end

	u = self:get_upgrade("mage_strike")
	if u then
		local function mage_strike(entity, damage, protection)
			if protection <= 0 then
				damage.value = damage.value * 1.2
			end
		end
		add_damage_hooks(self.mage_tower_bolts, mage_strike)

		-- 女巫的毒伤吃不到这个科技，进行伤害补偿
		mul_dmg(T("mod_wicked_sister_poison").dps, 1.15)
	end

	u = self:get_upgrade("mage_unsteady")
	if u then
		local function mage_unsteady(entity, damage, protection)
			if math.random() < 0.1 and protection < 1 then
				damage.value = damage.value * 2 / (1 - protection)
			end
		end
		add_damage_hooks(self.mage_tower_bolts, mage_unsteady)
		-- 女巫的毒伤吃不到这个科技，进行伤害补偿
		mul_dmg(T("mod_wicked_sister_poison").dps, 1.1)
	end

	u = self:get_upgrade("mage_empowered_magic")

	if u then
		self:mage_bolt_damage_mul(u.damage_factor)
	end

	u = self:get_upgrade("mage_arcane_spell")

	if u then
		self:mage_bolt_damage_mul(u.damage_factor)
	end

	u = self:get_upgrade("mage_power")

	if u then
		self:mage_bolt_damage_mul(u.damage_factor)
	end

	u = self:get_upgrade("mage_harmony")

	if u then
		scale_tower_attack_range(mage_towers, u.range_factor)

		for _, n in ipairs(self.mage_tower_bolts) do
			avg_dmg_mul(T(n).bullet, u.damage_factor)
		end

		avg_dmg_mul(T("mod_ray_arcane").dps, u.damage_factor)
		avg_dmg_mul(T("mod_pixie_pickpocket").modifier, u.damage_factor)

		local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

		for k, v in pairs(d) do
			d[k] = v * u.damage_factor
		end

		avg_dmg_mul(T("mod_lava_infernal_mage").dps, u.damage_factor)
		avg_dmg_mul(T("mod_wicked_sister_poison").dps, u.damage_factor)

		mul_field(T("mod_ultimate_wizard"), "damage", u.damage_factor)
	end

	u = self:get_upgrade("mage_slow_curse")

	if u then
		for _, n in pairs(self.bolts) do
			local mods = {u.mod}
			local b = T(n).bullet

			add_mods(b, mods)
		end

		add_mods(T("tower_pixie").attacks.list[4], {u.mod})
	end

	local engineer_towers = self.engineer_towers
	local engineer_bombs = self.engineer_bombs

	u = self:get_upgrade("engineer_concentrated_fire")

	if u then
		self:bomb_damage_mul(u.damage_factor)
	end

	u = self:get_upgrade("engineer_range_finder")

	if u then
		scale_tower_attack_range(engineer_towers, u.range_factor, {
			tower_mech = true,
			tower_balloon = true
		})

		mul_field(T("tower_bfg").attacks.list[2], "range_base", u.range_factor)
		mul_field(T("druid_shooter_sylvan").attacks.list[1], "range", u.range_factor)
		mul_field(T("tower_flamespitter_lvl4").attacks.list[2], "max_range", u.range_factor)
		mul_field(T("tower_flamespitter_lvl4").attacks.list[3], "max_range", u.range_factor)
		mul_field(T("soldier_balloon").attacks.list[1], "max_range", u.range_factor)
		mul_field(T("soldier_mecha").attacks.list[1], "max_range", u.range_factor)
	end

	u = self:get_upgrade("engineer_magic_dust")
	if u then
		u.hook = function(entity, damage, protection)
			if math.random() < 0.1 then
				damage.value = damage.value + entity.health.hp_max * 0.05 * math.sqrt(damage.value + 1) / 12.5
			end
		end
		add_damage_hooks(engineer_bombs, u.hook)

		-- 地震、喷火在他们的逻辑里处理这个科技。
		-- 作为吃不到这个科技的补偿，腐森，特斯拉和弗兰肯斯坦的攻击得到伤害提升
		mul_dmg(T("ray_tesla"), u.damage_factor, "bounce_damage_min", "bounce_damage_max")
		mul_dmg(T("mod_ray_frankenstein").dps, u.damage_factor)
		mul_dmg(T("mod_tower_rotten_forest_burst_damage").dps, u.damage_factor)
		mul_dmg(T("mod_ignis_altar_damage"), u.damage_factor)
		mul_dmg(T("aura_tower_sandworm").aura, u.damage_factor)
		mul_dmg(T("aura_bullet_culverine").aura, u.damage_factor)
		mul_dmg(T("aura_bullet_culverine_skill_b").aura, u.damage_factor)
		mul_dmg(T("aura_culverine_ultimate").aura, u.damage_factor)
	end

	u = self:get_upgrade("engineer_diffusion")
	if u then
		for _, n in ipairs(engineer_bombs) do
			local n = T(n)
			local b = n.bullet
			if b.damage_radius then
				mul_field(b, "damage_radius", u.radius_factor)
				if n.hit_fx then
					local fx = T(n.hit_fx)
					if fx.render then
						scale_sprite(fx.render.sprites[1], u.radius_factor)
					end
				end
			end
		end

		mul_field(T("tower_rotten_forest").attacks, "range", u.radius_factor)
		mul_field(T("tower_dwaarp").attacks, "range", u.radius_factor)

		for _, name in ipairs({"aura_bullet_ignis_altar", "aura_bullet_tower_hermit_toad_engineer_basic", "aura_tower_sandworm"}) do
			local t = T(name)
			scale_sprite(t.render.sprites[1], u.radius_factor)
			mul_field(t.aura, "radius", u.radius_factor)
		end

		mul_field(T("tower_melting_furnace").attacks, "range", u.radius_factor)

		-- 补偿喷火
		mul_field(T("tower_flamespitter_lvl4").attacks, "range", 1 + (u.radius_factor - 1) * 0.5)

		mul_field(T("aura_bullet_culverine").aura, "radius", u.radius_factor)
		mul_field(T("aura_bullet_culverine_skill_b").aura, "radius", u.radius_factor)
		scale_sprite(T("fx_bullet_culverine_hit").render.sprites[1], u.radius_factor)
		scale_sprite(T("fx_bullet_culverine_skill_b_hit").render.sprites[1], u.radius_factor)
	end

	u = self:get_upgrade("engineer_field_logistics")

	if u then
		scale_tower_price(engineer_towers, u.cost_factor, math.floor)
	end

	u = self:get_upgrade("engineer_emergency_expansion")

	if u then
		scale_tower_price(engineer_towers, u.cost_factor, math.floor)
		self:bomb_damage_mul(u.damage_factor)
	end

	u = self:get_upgrade("engineer_industrialization")

	if u then
		scale_power_prices(self.engineer_advanced_tower, u.cost_factor, math.floor)
	end

	u = self:get_upgrade("engineer_gnomish_tinkering")

	if u then
		local cd = u.cooldown_factor
		local cd_e = u.cooldown_factor_electric

		for _, a in ipairs({
			T("tower_dwaarp").attacks.list[2],
			T("tower_dwaarp").attacks.list[3],
			T("soldier_mecha").attacks.list[2],
			T("soldier_mecha").attacks.list[3],
			T("druid_shooter_sylvan").attacks.list[1],
			T("tower_entwood").attacks.list[3],
			T("tower_entwood").attacks.list[2],
			T("tower_dwaarp").attacks.list[3],
			T("soldier_balloon").attacks.list[2],
			T("soldier_balloon").attacks.list[3],
			T("tower_melting_furnace").attacks.list[2],
			T("tower_melting_furnace").attacks.list[4],
			T("tower_catapult").attacks.list[2],
			T("tower_catapult").attacks.list[3],
			T("tower_catapult").attacks.list[4],
			T("tower_culverine").attacks.list[2],
			T("tower_culverine").attacks.list[3]
		}) do
			mul_field(a, "cooldown", cd)
		end

		mul_keys(T("tower_entwood").attacks.list[2], cd, "cooldown_factor", "cooldown")
		mul_keys(T("tower_bfg").attacks.list[2], cd, "cooldown_base", "cooldown_mixed_base", "cooldown_flying")
		mul_field(T("tower_bfg").attacks.list[3], "cooldown_base", cd)
		mul_keys(T("tower_bfg").powers.missile, cd, "cooldown_dec", "cooldown_mixed_dec")
		mul_field(T("tower_bfg").powers.cluster, "cooldown_dec", cd)
		mul_field(T("tower_bfg").attacks, "min_cooldown", cd)
		mul_keys(T("tower_dwaarp").attacks.list[3], cd, "cooldown_inc", "cooldown_base")
		mul_field(T("tower_frankenstein").attacks.list[1], "cooldown", cd_e)
		mul_field(T("tower_tesla").attacks.list[1], "cooldown", cd_e)
		mul_field(T("tower_tesla").attacks, "min_cooldown", cd_e)
		mul_arr(T("tower_tricannon_lvl4").powers.bombardment.cooldown, cd)
		mul_arr(T("tower_tricannon_lvl4").powers.overheat.cooldown, cd)
		mul_arr(T("tower_demon_pit_lvl4").powers.big_guy.cooldown, cd)
		mul_arr(T("tower_flamespitter_lvl4").powers.skill_bomb.cooldown, cd)
		mul_arr(T("tower_flamespitter_lvl4").powers.skill_columns.cooldown, cd)
		mul_arr(T("tower_sparking_geode_lvl4").powers.crystalize.cooldown, cd)
		mul_arr(T("tower_sparking_geode_lvl4").powers.spike_burst.cooldown, cd)
		mul_keys(T("tower_rotten_forest").powers.tree, cd, "cooldown", "cooldown_inc")
		mul_arr(T("tower_ogre_shipwreck").powers.goblin_launcher.cooldown, cd)
		mul_field(T("tower_rocket_riders").attacks.list[2], "cooldown", cd)
		mul_field(T("rr_mine_box").attacks.list[1], "cooldown", cd)
		mul_field(T("ignis_altar_subunit").attacks.list[1], "cooldown", cd)
		mul_arr(T("tower_sandworm").powers.worm.cooldown, cd)
		mul_arr(T("tower_sandworm").powers.slime.cooldown, cd)
		mul_arr(T("tower_sandworm").powers.eat.cooldown, cd)
	end

	u = self:get_upgrade("engineer_efficiency")
	if u then
		mul_dmg(T("mod_tower_rotten_forest_burst_damage").dps, 1.25)
		mul_dmg(T("mod_ignis_altar_damage"), 1.25)
		mul_dmg(T("aura_tower_sandworm").aura, 1.25)
		mul_dmg(T("aura_bullet_culverine").aura, 1.25)
		mul_dmg(T("aura_bullet_culverine_skill_b").aura, 1.25)
		mul_dmg(T("aura_culverine_ultimate").aura, 1.25)
	end

	if self.list_id == 1 or self.list_id == 2 then
		E:set_template("user_power_1", T("power_fireball_control"))
	elseif self.list_id == 3 or self.list_id == 4 then
		E:set_template("user_power_1", T("power_thunder_control"))
	end

	T("power_fireball_control").user_power.level = self.levels.rain

	u = self:get_upgrade("rain_blazing_skies")

	if u then
		T("power_fireball_control").fireball_count = T("power_fireball_control").fireball_count + u.fireball_count_increase
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	u = self:get_upgrade("rain_scorched_earth")

	if u then
		T("power_fireball").scorch_earth = true
	end

	u = self:get_upgrade("rain_bigger_and_meaner")

	if u then
		T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction
		T("power_fireball").bullet.damage_radius = T("power_fireball").bullet.damage_radius * u.range_factor
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	u = self:get_upgrade("rain_blazing_earth")

	if u then
		T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction
		T("power_scorched_earth").aura.damage_min = 20
		T("power_scorched_earth").aura.damage_max = 30
		T("power_scorched_earth").aura.duration = 10
		T("power_scorched_water").aura.damage_min = 20
		T("power_scorched_water").aura.damage_max = 30
		T("power_scorched_water").aura.duration = 10
	end

	u = self:get_upgrade("rain_cataclysm")

	if u then
		T("power_fireball_control").cataclysm_count = 5
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	u = self:get_upgrade("rain_armaggedon")

	if u then
		T("power_fireball_control").cataclysm_count = T("power_fireball_control").cataclysm_count + u.fireball_count_increase
		T("power_fireball_control").fireball_count = T("power_fireball_control").fireball_count + u.fireball_count_increase
	end

	T("power_thunder_control").user_power.level = self.levels.thunder
	u = self:get_upgrade("thunder_level_1")

	if u then
		T("power_thunder_control").thunders[1].count = 6
	end

	u = self:get_upgrade("thunder_level_2")

	if u then
		T("power_thunder_control").cooldown = 60
		T("power_thunder_control").thunders[1].damage_max = 100
		T("power_thunder_control").thunders[1].damage_min = 80
	end

	u = self:get_upgrade("thunder_level_3")

	if u then
		T("power_thunder_control").thunders[1].count = 8
		T("power_thunder_control").rain.disabled = nil
		T("power_thunder_control").slow.disabled = nil
		T("mod_power_thunder_slow").slow.factor = 0.6
	end

	u = self:get_upgrade("thunder_level_4")

	if u then
		T("mod_power_thunder_slow").slow.factor = 0.4
		T("power_thunder_control").thunders[1].damage_max = 130
		T("power_thunder_control").thunders[1].damage_min = 110
	end

	u = self:get_upgrade("thunder_level_5")

	if u then
		T("power_thunder_control").thunders[1].damage_max = 200
		T("power_thunder_control").thunders[1].damage_min = 150
		T("power_thunder_control").thunders[2].count = 6
	end

	u = self:get_upgrade("thunder_level_6")

	if u then
		T("power_thunder_control").main_script.insert = function(this, store)
			for _, e in pairs(store.soldiers) do
				if e.health.dead and not e.reinforcement then
					U.soldier_revive(e)
				elseif not e.health.dead and e.health.hp < e.health.hp_max then
					e.health.hp = e.health.hp_max
				end
			end
			return true
		end
	end

	u = self:get_upgrade("thunder_typhoon")

	if u then
		T("power_thunder_control").thunders[1].count = 10
		T("power_thunder_control").thunders[2].count = 10
		T("power_thunder_control").slow.factor = 0.25
		T("power_thunder_control").extra_duration = 4
	end

	E:set_template("user_power_2", T("power_reinforcements_control"))
	if self.levels.reinforcements > 0 then
		local rl = math.min(self.levels.reinforcements, self.max_level)

		if rl > 5 then
			rl = 5
		end

		u = self:get_upgrade("reinforcement_level_" .. rl)

		local v = self:get_upgrade("reinforcement_level_6")

		if u then
			E:set_template("re_current", T(u.template_name))
		end

		if v then
			T("user_power_2").cooldown = T("user_power_2").cooldown - v.cooldown_dec
			T("user_power_2").duration = T("user_power_2").duration + v.duration_inc
		end
	else
		E:set_template("re_current", T("re_farmer"))
	end
end

return upgrades
