-- chunkname: @./kr1/upgrades.lua
local log = require("lib.klua.log"):new("kr1.upgrades")
local km = require("lib.klua.macros")
local E = require("entity_db")
local bit = require("bit")
require("all.constants")

local function T(name)
	return E:get_template(name)
end

local function DP(desktop, phone)
	return desktop
end

local epsilon = 1e-09
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
		icon = DP(13, 6)
	},
	archer_eagle_eye = {
		range_factor = 1.25,
		class = "archers",
		price = 1,
		level = 2,
		icon = DP(14, 7)
	},
	archer_piercing = {
		class = "archers",
		reduce_armor_factor = 0.1,
		price = 2,
		level = 3,
		icon = DP(15, 8)
	},
	archer_far_shots = {
		range_factor = 1.05,
		class = "archers",
		price = 2,
		level = 4,
		icon = DP(16, 9)
	},
	archer_precision = {
		damage_factor = 1.8,
		class = "archers",
		chance = 0.1,
		price = 3,
		level = 5,
		icon = DP(17, 10)
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
		icon = DP(8, 1)
	},
	barrack_better_armor = {
		class = "barracks",
		armor_increase = 0.1,
		price = 1,
		level = 2,
		icon = DP(9, 2)
	},
	barrack_improved_deployment = {
		cooldown_factor = 0.8,
		rally_range_factor = 1.2,
		class = "barracks",
		price = 2,
		level = 3,
		icon = DP(10, 3)
	},
	barrack_survival_2 = {
		health_factor = 1.09,
		class = "barracks",
		price = 2,
		level = 4,
		icon = DP(11, 4)
	},
	barrack_barbed_armor = {
		spiked_armor_factor = 0.1,
		class = "barracks",
		price = 3,
		level = 5,
		icon = DP(12, 5)
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
		icon = DP(18, 11)
	},
	mage_arcane_shatter = {
		mod_normal = "mod_arcane_shatter",
		mod_little = "mod_arcane_shatter_little",
		class = "mages",
		price = 1,
		level = 2,
		icon = DP(19, 12)
	},
	mage_hermetic_study = {
		class = "mages",
		cost_factor = 0.91,
		price = 2,
		level = 3,
		icon = DP(20, 13)
	},
	mage_empowered_magic = {
		damage_factor = 1.15,
		class = "mages",
		price = 2,
		level = 4,
		icon = DP(21, 14)
	},
	mage_slow_curse = {
		mod = "mod_slow_curse",
		class = "mages",
		price = 3,
		level = 5,
		icon = DP(22, 15)
	},
	mage_brilliance = {
		from_kr = 2,
		class = "mages",
		icon = 15,
		price = 4,
		level = 6,
		damage_factors = {
			1.1,
			1.12,
			1.14,
			1.16,
			1.18,
			1.2,
			1.22,
			1.24,
			1.26,
			1.28,
			1.29,
			1.30,
			1.31,
			1.32,
			1.33,
			1.34,
			1.35
		}
	},
	engineer_concentrated_fire = {
		damage_factor = 1.25,
		class = "engineers",
		price = 1,
		level = 1,
		icon = DP(23, 16)
	},
	engineer_range_finder = {
		range_factor = 1.1,
		class = "engineers",
		price = 1,
		level = 2,
		icon = DP(24, 17)
	},
	engineer_field_logistics = {
		class = "engineers",
		cost_factor = 0.9,
		price = 2,
		level = 3,
		icon = DP(25, 18)
	},
	engineer_industrialization = {
		class = "engineers",
		cost_factor = 0.8,
		price = 3,
		level = 4,
		icon = DP(26, 19)
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = DP(27, 20)
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
		icon = DP(3, 26)
	},
	rain_scorched_earth = {
		price = 2,
		class = "rain",
		level = 2,
		icon = DP(4, 27)
	},
	rain_bigger_and_meaner = {
		range_factor = 1.25,
		cooldown_reduction = 10,
		class = "rain",
		damage_increase = 30,
		price = 3,
		level = 3,
		icon = DP(5, 28)
	},
	rain_blazing_earth = {
		cooldown_reduction = 10,
		class = "rain",
		price = 3,
		level = 4,
		icon = DP(6, 29)
	},
	rain_cataclysm = {
		class = "rain",
		damage_increase = 60,
		price = 3,
		level = 5,
		icon = DP(7, 30)
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
		icon = DP(28, 21)
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = DP(29, 22)
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = DP(30, 23)
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = DP(1, 24)
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = DP(2, 25)
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 2,
		cooldown_dec = 1,
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
		reduce_armor = 0.0075,
		class = "archers",
		price = 2,
		level = 4,
		icon = 4
	},
	archer_fast_shots = {
		from_kr = 2,
		cooldown_factor = 0.925,
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
	mage_power = {
		from_kr = 2,
		class = "mages",
		damage_factor = 1.1,
		price = 2,
		level = 3,
		icon = 13
	},
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
		damage_factors = {
			1.1,
			1.12,
			1.14,
			1.16,
			1.18,
			1.2,
			1.22,
			1.24,
			1.26,
			1.28,
			1.29,
			1.30,
			1.31,
			1.32,
			1.33,
			1.34,
			1.35
		}
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
	engineer_diffusion = {
		class = "engineers",
		radius_factor = 1.2,
		price = 3,
		level = 4,
		icon = DP(23, 16)
	},
	engineer_efficiency = {
		price = 3,
		class = "engineers",
		level = 5,
		icon = DP(27, 20)
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
	-- rain_blazing_skies = {
	-- 	from_kr = 2,
	-- 	fireball_count_increase = 2,
	-- 	class = "rain",
	-- 	damage_increase = 30,
	-- 	price = 2,
	-- 	level = 1,
	-- 	icon = 21
	-- },
	-- rain_scorched_earth = {
	-- 	from_kr = 2,
	-- 	price = 2,
	-- 	class = "rain",
	-- 	level = 2,
	-- 	icon = 22
	-- },
	-- rain_bigger_and_meaner = {
	-- 	from_kr = 2,
	-- 	range_factor = 1.25,
	-- 	cooldown_reduction = 10,
	-- 	class = "rain",
	-- 	damage_increase = 30,
	-- 	price = 3,
	-- 	level = 3,
	-- 	icon = 23
	-- },
	-- rain_blazing_earth = {
	-- 	from_kr = 2,
	-- 	cooldown_reduction = 10,
	-- 	class = "rain",
	-- 	price = 3,
	-- 	level = 4,
	-- 	icon = 24
	-- },
	-- rain_cataclysm = {
	-- 	from_kr = 2,
	-- 	class = "rain",
	-- 	damage_increase = 60,
	-- 	price = 3,
	-- 	level = 5,
	-- 	icon = 25
	-- },
	-- rain_armaggedon = {
	-- 	from_kr = 2,
	-- 	class = "rain",
	-- 	fireball_count_increase = 1,
	-- 	icon = 25,
	-- 	price = 4,
	-- 	level = 6
	-- },
	-- reinforcement_level_1 = {
	-- 	from_kr = 2,
	-- 	class = "reinforcements",
	-- 	template_name = "re_farmer_well_fed",
	-- 	price = 2,
	-- 	level = 1,
	-- 	icon = 26
	-- },
	-- reinforcement_level_2 = {
	-- 	from_kr = 2,
	-- 	class = "reinforcements",
	-- 	template_name = "re_conscript",
	-- 	price = 3,
	-- 	level = 2,
	-- 	icon = 27
	-- },
	-- reinforcement_level_3 = {
	-- 	from_kr = 2,
	-- 	class = "reinforcements",
	-- 	template_name = "re_warrior",
	-- 	price = 3,
	-- 	level = 3,
	-- 	icon = 28
	-- },
	-- reinforcement_level_4 = {
	-- 	from_kr = 2,
	-- 	class = "reinforcements",
	-- 	template_name = "re_legionnaire",
	-- 	price = 3,
	-- 	level = 4,
	-- 	icon = 29
	-- },
	-- reinforcement_level_5 = {
	-- 	from_kr = 2,
	-- 	class = "reinforcements",
	-- 	template_name = "re_legionnaire_ranged",
	-- 	price = 4,
	-- 	level = 5,
	-- 	icon = 30
	-- },
	-- reinforcement_level_6 = {
	-- 	from_kr = 3,
	-- 	class = "reinforcements",
	-- 	duration_inc = 2,
	-- 	cooldown_dec = 1,
	-- 	icon = 29,
	-- 	price = 4,
	-- 	level = 6
	-- }
	rain_blazing_skies = {
		fireball_count_increase = 2,
		class = "rain",
		damage_increase = 30,
		price = 2,
		level = 1,
		icon = DP(3, 26)
	},
	rain_scorched_earth = {
		price = 2,
		class = "rain",
		level = 2,
		icon = DP(4, 27)
	},
	rain_bigger_and_meaner = {
		range_factor = 1.25,
		cooldown_reduction = 10,
		class = "rain",
		damage_increase = 30,
		price = 3,
		level = 3,
		icon = DP(5, 28)
	},
	rain_blazing_earth = {
		cooldown_reduction = 10,
		class = "rain",
		price = 3,
		level = 4,
		icon = DP(6, 29)
	},
	rain_cataclysm = {
		class = "rain",
		damage_increase = 60,
		price = 3,
		level = 5,
		icon = DP(7, 30)
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
		icon = DP(28, 21)
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "re_conscript",
		price = 3,
		level = 2,
		icon = DP(29, 22)
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "re_warrior",
		price = 3,
		level = 3,
		icon = DP(30, 23)
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "re_legionnaire",
		price = 3,
		level = 4,
		icon = DP(1, 24)
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "re_legionnaire_ranged",
		price = 4,
		level = 5,
		icon = DP(2, 25)
	},
	reinforcement_level_6 = {
		from_kr = 3,
		class = "reinforcements",
		duration_inc = 2,
		cooldown_dec = 1,
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

function upgrades:archer_towers()
	return GS.archer_towers
end

function upgrades:arrows()
	return {
		"arrow_1",
		"arrow_2",
		"arrow_3",
		"arrow_ranger",
		"shotgun_musketeer",
		"shotgun_musketeer_sniper",
		"arrow_crossbow",
		"axe_totem",
		"dwarf_shotgun",
		"pirate_watchtower_shotgun",
		"arrow_arcane",
		"arrow_arcane_slumber",
		"arrow_silver",
		"arrow_silver_long",
		"arrow_silver_sentence",
		"arrow_silver_sentence_long",
		"arrow_silver_mark",
		"arrow_silver_mark_long",
		"arrow_hero_elves_archer",
		"arrow_hero_alleria",
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
		"arrow_hero_vesper_short_arrow"
	}
end

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
	"tower_paladin_covenant_soldier_lvl4"
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
	"tower_paladin_covenant_soldier_lvl4"
}

function upgrades:towers_with_barrack()
	return {
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
		"tower_paladin_covenant_lvl4"
	}
end

function upgrades:non_barrack_towers_with_barrack_attribute()
	return {"tower_sorcerer", "tower_mech", "tower_necromancer", "tower_frankenstein", "tower_druid", "tower_dark_elf_lvl4"}
end

function upgrades:mage_towers()
	return GS.mage_towers
end

function upgrades:mage_tower_bolts()
	return {
		"bolt_1",
		"bolt_2",
		"bolt_3",
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
		"bolt_faerie_dragon_lvl4"
	}
end

function upgrades:bolts()
	local other_bolts = {
		"ray_arcane",
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
		"bolt_hero_spider_basic_attack"
	}

	return table.append(other_bolts, self:mage_tower_bolts())
end

function upgrades:engineer_towers()
	return GS.engineer_towers
end

function upgrades:engineer_bombs()
	return {
		"bomb",
		"bomb_dynamite",
		"bomb_black",
		"bomb_bfg",
		"bomb_mecha",
		"rock_druid",
		"rock_entwood",
		"rock_firey_nut",
		"tower_tricannon_bomb",
		"tower_tricannon_bomb_overheated",
		"bullet_tower_demon_pit_basic_attack_lvl4",
		"bullet_tower_demon_pit_big_guy_lvl4",
		"bullet_tower_barrel_lvl4",
		"bullet_tower_hermit_toad_engineer_basic_lvl4",
		"tower_sparking_geode_ray_lvl4"
	}
end

function upgrades:engineer_advanced_towers()
	return {
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
		"tower_sparking_geode_lvl4"
	}
end

local fps_based_keys = {
	["hit_time"] = true,
	["cast_time"] = true,
	["shoot_time"] = true,
	["dodge_time"] = true
}
-- SU 中的副本，为了避免循环引用，不得不在这里复制
local function scale_fps_based_keys(tbl, factor, visited)
	visited = visited or {}

	if visited[tbl] then
		return
	end

	visited[tbl] = true

	for k, v in pairs(tbl) do
		-- 跳过 _origin_xxx 字段，避免递归
		if type(v) == "table" then
			scale_fps_based_keys(v, factor, visited)
		elseif fps_based_keys[k] and type(v) == "number" then
			local _origin_key = "_origin_" .. k

			if not tbl[_origin_key] then
				tbl[_origin_key] = v
			end

			tbl[k] = tbl[_origin_key] * factor
		end
	end
end

function upgrades:patch_templates(max_level)
	if max_level then
		self.max_level = max_level
	end

	local u
	local archer_towers = self:archer_towers()

	u = self:get_upgrade("archer_salvage")

	if u then
		for _, n in pairs(archer_towers) do
			T(n).tower.price = math.ceil(T(n).tower.price * u.cost_factor)
		end
	end

	u = self:get_upgrade("archer_eagle_eye")

	if u then
		for _, n in pairs(archer_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end

		T("aura_ranger_thorn").aura.radius = T("aura_ranger_thorn").aura.radius * u.range_factor
		T("tower_musketeer").attacks.list[2].range = T("tower_musketeer").attacks.list[2].range * u.range_factor
		T("tower_musketeer").attacks.list[3].range = T("tower_musketeer").attacks.list[3].range * u.range_factor
		T("tower_musketeer").attacks.list[4].range = T("tower_musketeer").attacks.list[4].range * u.range_factor
	end

	u = self:get_upgrade("archer_piercing")

	if u then
		for _, n in pairs(self:arrows()) do
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
		for _, n in pairs(archer_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end

		T("aura_ranger_thorn").aura.radius = T("aura_ranger_thorn").aura.radius * u.range_factor
		T("tower_musketeer").attacks.list[2].range = T("tower_musketeer").attacks.list[2].range * u.range_factor
		T("tower_musketeer").attacks.list[3].range = T("tower_musketeer").attacks.list[3].range * u.range_factor
		T("tower_musketeer").attacks.list[4].range = T("tower_musketeer").attacks.list[4].range * u.range_factor
	end

	u = self:get_upgrade("archer_logger")
	if u then
		for _, n in pairs(archer_towers) do
			local t = T(n)
			if t.powers then
				for _, p in pairs(t.powers) do
					if p.price_base then
						p.price_base = math.ceil(p.price_base * u.cost_factor)
					end
					if p.price_inc then
						p.price_inc = math.ceil(p.price_inc * u.cost_factor)
					end
				end
			end
		end
	end

	u = self:get_upgrade("archer_critical")
	if u then
		for _, n in pairs(GS.archer_towers) do
			local t = T(n)
			t.tower.damage_factor = t.tower.damage_factor * u.damage_factor
		end
	end

	local function apply_mod(bullet, mod_name)
		if type(bullet.mod) == "table" then
			table.insert(bullet.mod, mod_name)
		elseif bullet.mod ~= nil then
			bullet.mod = {bullet.mod, mod_name}
		elseif bullet.mods ~= nil then
			table.insert(bullet.mods, mod_name)
		else
			bullet.mod = mod_name
		end
	end

	u = self:get_upgrade("archer_tear")
	if u then
		for _, n in pairs(self:arrows()) do
			local b = T(n).bullet
			if b.damage_min and b.damage_max then
				local damage_avg = (b.damage_min + b.damage_max) / 2
				if damage_avg > 40 then
					apply_mod(b, "mod_archer_tear_strong")
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

	u = self:get_upgrade("archer_fast_shots")
	if u then
		for _, n in pairs(archer_towers) do
			local t = T(n)
			t.tower.cooldown_factor = t.tower.cooldown_factor * u.cooldown_factor
			if t.render then
				for _, s in pairs(t.render.sprites) do
					if not s._origin_fps then
						if not s.fps then
							s._origin_fps = FPS
						else
							s._origin_fps = s.fps
						end
					end
					s.fps = s._origin_fps * u.cooldown_factor
				end
				scale_fps_based_keys(t, 1 / u.cooldown_factor)
			end
		end
	end

	u = self:get_upgrade("archer_el_bloodletting_shoot")

	if u then
		for _, n in pairs(self:arrows()) do
			local b = T(n).bullet
			apply_mod(b, "mod_blood_elves")
		end
	end

	local soldiers = self.soldiers
	local barrack_soldiers = self.barrack_soldiers
	local barrack_towers = self:towers_with_barrack()

	u = self:get_upgrade("barrack_survival")

	if u then
		for _, n in pairs(soldiers) do
			T(n).health.hp_max = km.round(T(n).health.hp_max * u.health_factor)
		end
	end

	u = self:get_upgrade("barrack_bodies")

	if u then
		for _, n in pairs(GS.barrack_towers) do
			if n ~= "tower_baby_ashbite" and n ~= "tower_pandas_lvl4" then
				local t = T(n)
				t.barrack.max_soldiers = t.barrack.max_soldiers + 1
			end
		end
		local special_soldiers = {"soldier_baby_ashbite", "soldier_tower_pandas_green_lvl4", "soldier_tower_pandas_red_lvl4", "soldier_tower_pandas_blue_lvl4"}

		for _, n in pairs(special_soldiers) do
			local t = T(n)
			t.unit.damage_factor = t.unit.damage_factor * 1.3
		end

		for _, n in pairs(barrack_soldiers) do
			local t = T(n)
			if t.health.hp_max and not table.contains(special_soldiers, n) then
				t.health.hp_max = math.ceil(t.health.hp_max * 0.8)
			end
		end
	end

	u = self:get_upgrade("barrack_march")
	if u then
		for _, n in pairs(barrack_towers) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
		for _, n in pairs(soldiers) do
			T(n).motion.max_speed = T(n).motion.max_speed + u.speed_inc
		end
	end

	u = self:get_upgrade("barrack_rally")
	if u then
		for _, n in pairs(barrack_towers) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
	end

	u = self:get_upgrade("barrack_weapon")
	if u then
		for _, n in pairs(soldiers) do
			T(n).unit.damage_factor = T(n).unit.damage_factor * u.damage_factor
		end
	end

	u = self:get_upgrade("barrack_go_on")
	if u then
		for _, n in pairs(soldiers) do
			T(n).health.dead_lifetime = T(n).health.dead_lifetime * u.cooldown_factor
		end
	end

	u = self:get_upgrade("barrack_better_armor")

	if u then
		for _, n in pairs(soldiers) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
	end

	u = self:get_upgrade("barrack_improved_deployment")

	if u then
		for _, n in pairs(soldiers) do
			T(n).health.dead_lifetime = math.floor(T(n).health.dead_lifetime * u.cooldown_factor)
		end

		for _, n in pairs(barrack_towers) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
	end

	u = self:get_upgrade("barrack_survival_2")

	if u then
		for _, n in pairs(soldiers) do
			T(n).health.hp_max = km.round(T(n).health.hp_max * u.health_factor)
		end
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

	local mage_towers = self:mage_towers()

	u = self:get_upgrade("mage_spell_reach")

	if u then
		for _, n in pairs(mage_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end
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
		for _, n in pairs(self:bolts()) do
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

	u = self:get_upgrade("mage_hermetic_study")

	if u then
		for _, n in pairs(mage_towers) do
			T(n).tower.price = math.ceil(T(n).tower.price * u.cost_factor)
		end
	end

	u = self:get_upgrade("mage_old_folk")
	if u then
		for _, n in pairs(mage_towers) do
			local t = T(n)
			if t.powers then
				for _, p in pairs(t.powers) do
					if p.price_base then
						p.price_base = math.ceil(p.price_base * u.cost_factor)
					end
					if p.price_inc then
						p.price_inc = math.ceil(p.price_inc * u.cost_factor)
					end
				end
			end
		end
	end

	u = self:get_upgrade("mage_strike")
	if u then
		for _, n in pairs(self:mage_tower_bolts()) do
			local b = T(n).bullet
			b.damage_hooks[#b.damage_hooks + 1] = function(entity, damage, protection)
				if protection <= 0 then
					damage.value = damage.value * 1.2
				end
			end
		end
	end

	u = self:get_upgrade("mage_unsteady")
	if u then
		for _, n in pairs(self:mage_tower_bolts()) do
			local b = T(n).bullet
			b.damage_hooks[#b.damage_hooks + 1] = function(entity, damage, protection)
				if math.random() < 0.1 and protection < 1 then
					damage.value = damage.value * 1.5 / (1 - protection)
				end
			end
		end
	end

	u = self:get_upgrade("mage_empowered_magic")

	if u then
		for _, n in pairs(self:mage_tower_bolts()) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("mod_ray_arcane").dps.damage_min = math.ceil(T("mod_ray_arcane").dps.damage_min * u.damage_factor)
		T("mod_ray_arcane").dps.damage_max = math.ceil(T("mod_ray_arcane").dps.damage_max * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_min = math.ceil(T("mod_pixie_pickpocket").modifier.damage_min * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_max = math.ceil(T("mod_pixie_pickpocket").modifier.damage_max * u.damage_factor)

		local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

		for k, v in pairs(d) do
			d[k] = math.ceil(v * u.damage_factor)
		end
	end

	u = self:get_upgrade("mage_arcane_spell")

	if u then
		for _, n in pairs(self:mage_tower_bolts()) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("mod_ray_arcane").dps.damage_min = math.ceil(T("mod_ray_arcane").dps.damage_min * u.damage_factor)
		T("mod_ray_arcane").dps.damage_max = math.ceil(T("mod_ray_arcane").dps.damage_max * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_min = math.ceil(T("mod_pixie_pickpocket").modifier.damage_min * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_max = math.ceil(T("mod_pixie_pickpocket").modifier.damage_max * u.damage_factor)

		local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

		for k, v in pairs(d) do
			d[k] = math.ceil(v * u.damage_factor)
		end
	end

	u = self:get_upgrade("mage_power")

	if u then
		for _, n in pairs(self:mage_tower_bolts()) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("mod_ray_arcane").dps.damage_min = math.ceil(T("mod_ray_arcane").dps.damage_min * u.damage_factor)
		T("mod_ray_arcane").dps.damage_max = math.ceil(T("mod_ray_arcane").dps.damage_max * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_min = math.ceil(T("mod_pixie_pickpocket").modifier.damage_min * u.damage_factor)
		T("mod_pixie_pickpocket").modifier.damage_max = math.ceil(T("mod_pixie_pickpocket").modifier.damage_max * u.damage_factor)

		local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

		for k, v in pairs(d) do
			d[k] = math.ceil(v * u.damage_factor)
		end
	end

	u = self:get_upgrade("mage_slow_curse")

	if u then
		for _, n in pairs(self:bolts()) do
			local mods = {u.mod}
			local b = T(n).bullet

			add_mods(b, mods)
		end

		add_mods(T("tower_pixie").attacks.list[4], {u.mod})
	end

	local engineer_towers = self:engineer_towers()
	local engineer_bombs = self:engineer_bombs()

	u = self:get_upgrade("engineer_concentrated_fire")

	if u then
		for _, n in pairs(engineer_bombs) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("ray_tesla").bounce_damage_min = math.floor(T("ray_tesla").bounce_damage_min * u.damage_factor)
		T("ray_tesla").bounce_damage_max = math.floor(T("ray_tesla").bounce_damage_max * u.damage_factor)
		T("mod_ray_frankenstein").dps.damage_min = math.floor(T("mod_ray_frankenstein").dps.damage_min * u.damage_factor)
		T("mod_ray_frankenstein").dps.damage_max = math.floor(T("mod_ray_frankenstein").dps.damage_max * u.damage_factor)
		T("tower_flamespitter_lvl4").attacks.list[1].damage_min = math.floor(T("tower_flamespitter_lvl4").attacks.list[1].damage_min * u.damage_factor)
		T("tower_flamespitter_lvl4").attacks.list[1].damage_max = math.floor(T("tower_flamespitter_lvl4").attacks.list[1].damage_max * u.damage_factor)
	end

	u = self:get_upgrade("engineer_range_finder")

	if u then
		for _, n in pairs(engineer_towers) do
			if n ~= "tower_mech" then
				T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
			end
		end

		T("tower_bfg").attacks.list[2].range_base = math.ceil(T("tower_bfg").attacks.list[2].range_base * u.range_factor)
		T("druid_shooter_sylvan").attacks.list[1].range = math.ceil(T("druid_shooter_sylvan").attacks.list[1].range * u.range_factor)
		T("tower_flamespitter_lvl4").attacks.list[2].max_range = math.ceil(T("tower_flamespitter_lvl4").attacks.list[2].max_range * u.range_factor)
		T("tower_flamespitter_lvl4").attacks.list[3].max_range = math.ceil(T("tower_flamespitter_lvl4").attacks.list[3].max_range * u.range_factor)
	end

	u = self:get_upgrade("engineer_magic_dust")
	if u then
		for _, n in pairs(engineer_bombs) do
			local n = T(n)
			local b = n.bullet
			b.damage_hooks[#b.damage_hooks + 1] = function(entity, damage, protection)
				if math.random() < 0.1 then
					damage.value = damage.value + entity.health.hp_max * 0.05
				end
			end
		end
	end

	u = self:get_upgrade("engineer_diffusion")
	if u then
		for _, n in pairs(engineer_bombs) do
			local n = T(n)
			local b = n.bullet
			if b.damage_radius then
				b.damage_radius = b.damage_radius * u.radius_factor
				if n.hit_fx then
					local fx = T(n.hit_fx)
					if fx.render then
						local s = fx.render.sprites[1]
						if s.scale then
							s.scale.x = s.scale.x * u.radius_factor
							s.scale.y = s.scale.y * u.radius_factor
						else
							s.scale = {
								x = u.radius_factor,
								y = u.radius_factor
							}
						end
					end
				end
			end
		end
	end

	u = self:get_upgrade("engineer_field_logistics")

	if u then
		for _, n in pairs(engineer_towers) do
			T(n).tower.price = math.floor(T(n).tower.price * u.cost_factor)
		end
	end

	u = self:get_upgrade("engineer_industrialization")

	if u then
		for _, n in pairs(self:engineer_advanced_towers()) do
			for pk, pv in pairs(T(n).powers) do
				pv.price_base = math.floor(pv.price_base * u.cost_factor)
				pv.price_inc = math.floor(pv.price_inc * u.cost_factor)
			end
		end
	end

	u = self:get_upgrade("engineer_gnomish_tinkering")

	if u then
		for _, a in pairs({T("tower_dwaarp").attacks.list[2], T("tower_dwaarp").attacks.list[3], T("soldier_mecha").attacks.list[2], T("soldier_mecha").attacks.list[3], T("druid_shooter_sylvan").attacks.list[1], T("tower_entwood").attacks.list[3], T("tower_entwood").attacks.list[2], T("tower_dwaarp").attacks.list[3]}) do
			a.cooldown = a.cooldown * u.cooldown_factor
		end

		local at

		at = T("tower_entwood").attacks.list[2]
		at.cooldown_factor = at.cooldown_factor * u.cooldown_factor
		at.cooldown = at.cooldown * u.cooldown_factor
		at = T("tower_bfg").attacks.list[2]
		at.cooldown_base = at.cooldown_base * u.cooldown_factor
		at.cooldown_mixed_base = at.cooldown_mixed_base * u.cooldown_factor
		at.cooldown_flying = at.cooldown_flying * u.cooldown_factor
		at = T("tower_bfg").attacks.list[3]
		at.cooldown_base = at.cooldown_base * u.cooldown_factor
		at = T("tower_bfg").powers.missile
		at.cooldown_dec = at.cooldown_dec * u.cooldown_factor
		at.cooldown_mixed_dec = at.cooldown_mixed_dec * u.cooldown_factor
		at = T("tower_bfg").powers.cluster
		at.cooldown_dec = at.cooldown_dec * u.cooldown_factor
		at = T("tower_bfg").attacks
		at.min_cooldown = at.min_cooldown * u.cooldown_factor
		at = T("tower_dwaarp").attacks.list[3]
		at.cooldown_inc = at.cooldown_inc * u.cooldown_factor
		at = T("tower_frankenstein").attacks.list[1]
		at.cooldown = at.cooldown * u.cooldown_factor_electric
		at = T("tower_tesla").attacks.list[1]
		at.cooldown = at.cooldown * u.cooldown_factor_electric
		at = T("tower_tesla").attacks
		at.min_cooldown = at.min_cooldown * u.cooldown_factor_electric
		at = T("tower_tricannon_lvl4").powers.bombardment
		at.cooldown[1] = at.cooldown[1] * u.cooldown_factor
		at.cooldown[2] = at.cooldown[2] * u.cooldown_factor
		at.cooldown[3] = at.cooldown[3] * u.cooldown_factor
		at = T("tower_tricannon_lvl4").powers.overheat
		at.cooldown[1] = at.cooldown[1] * u.cooldown_factor
		at.cooldown[2] = at.cooldown[2] * u.cooldown_factor
		at.cooldown[3] = at.cooldown[3] * u.cooldown_factor
		at = T("tower_demon_pit_lvl4").powers.big_guy
		at.cooldown[1] = at.cooldown[1] * u.cooldown_factor
		at.cooldown[2] = at.cooldown[2] * u.cooldown_factor
		at.cooldown[3] = at.cooldown[3] * u.cooldown_factor
		at = T("tower_flamespitter_lvl4").powers.skill_bomb
		at.cooldown[1] = at.cooldown[1] * u.cooldown_factor
		at.cooldown[2] = at.cooldown[2] * u.cooldown_factor
		at.cooldown[3] = at.cooldown[3] * u.cooldown_factor
		at = T("tower_flamespitter_lvl4").powers.skill_columns
		at.cooldown[1] = at.cooldown[1] * u.cooldown_factor
		at.cooldown[2] = at.cooldown[2] * u.cooldown_factor
		at.cooldown[3] = at.cooldown[3] * u.cooldown_factor
	end

	if self.list_id == 1 or self.list_id == 2 then
		E:set_template("user_power_1", T("power_fireball_control"))
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

	if self.levels.reinforcements > 0 then
		local rl = math.min(self.levels.reinforcements, self.max_level)

		if rl > 5 then
			rl = 5
		end

		u = self:get_upgrade("reinforcement_level_" .. rl)

		local v = self:get_upgrade("reinforcement_level_6")

		if v then
		end

		if u then
			for i = 1, 3 do
				if v then
					T(u.template_name .. "_" .. i).reinforcement.duration = T(u.template_name .. "_" .. i).reinforcement.duration + v.duration_inc
					T("re_current_1").cooldown = T("re_current_1").cooldown - 1
				end

				E:set_template("re_current_" .. i, T(u.template_name .. "_" .. i))
			end
		end
	end
end

return upgrades
