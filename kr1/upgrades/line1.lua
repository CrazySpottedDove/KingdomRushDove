local H = require("kr1.upgrades.upgrade_utils")

local T = H.T
local E = require("entity_db")
local mul_dmg = H.mul_dmg
local scale_tower_price = H.scale_tower_price
local scale_power_prices = H.scale_power_prices
local scale_tower_attack_range = H.scale_tower_attack_range
local patch_soldier_armor_inc = H.patch_soldier_armor_inc
local patch_soldier_magic_armor_inc = H.patch_soldier_magic_armor_inc
local patch_soldier_dead_lifetime = H.patch_soldier_dead_lifetime
local patch_engineer_power_cooldown = H.patch_engineer_power_cooldown
local patch_engineer_range = H.patch_engineer_range

local apply_mod = H.apply_mod

local add_mods = H.add_mods

local techs = {
	archer_eagle_eye = {
		class = "archers",
		icon = 14,
		level = 2,
		price = 1,
		range_factor = 1.25,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_tower_attack_range(archer_towers, u.range_factor)
		end
	},
	archer_el_bloodletting_shoot = {
		class = "archers",
		from_kr = 3,
		icon = 5,
		level = 6,
		price = 4,
		patch = function(UP, u)
			for _, n in ipairs(UP.arrows) do
				local b = T(n).bullet
				apply_mod(b, "mod_blood_elves")
			end
		end
	},
	archer_far_shots = {
		class = "archers",
		icon = 16,
		level = 4,
		price = 2,
		range_factor = 1.05,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_tower_attack_range(archer_towers, u.range_factor)
		end
	},
	archer_piercing = {
		class = "archers",
		icon = 15,
		level = 3,
		price = 2,
		reduce_armor_factor = 0.1,
		patch = function(UP, u)
			for _, n in ipairs(UP.arrows) do
				local reduce_armor = T(n).bullet.reduce_armor

				if type(reduce_armor) == "table" then
					for k, v in ipairs(reduce_armor) do
						reduce_armor[k] = v + u.reduce_armor_factor
					end
				else
					T(n).bullet.reduce_armor = u.reduce_armor_factor + reduce_armor
				end
			end
		end
	},
	archer_precision = {
		chance = 0.1,
		class = "archers",
		damage_factor = 2,
		icon = 17,
		level = 5,
		price = 3
	},
	archer_salvage = {
		class = "archers",
		cost_factor = 0.95,
		icon = 13,
		level = 1,
		price = 1,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_tower_price(archer_towers, u.cost_factor, math.ceil)
		end
	},
	barrack_barbed_armor = {
		class = "barracks",
		icon = 12,
		level = 5,
		price = 3,
		spiked_armor_factor = 0.1,
		patch = function(UP, u)
			for _, t in ipairs(E:filter_templates("soldier")) do
				if t.health then
					t.health.spiked_armor = t.health.spiked_armor + u.spiked_armor_factor
				end
			end
		end
	},
	barrack_better_armor = {
		armor_increase = 0.1,
		class = "barracks",
		icon = 9,
		level = 2,
		price = 1,
		patch = function(UP, u)
			patch_soldier_armor_inc(UP.soldiers, u.armor_increase)
		end
	},
	barrack_el_enchanted_armor = {
		class = "barracks",
		factor = 0.9,
		from_kr = 3,
		icon = 8,
		level = 6,
		magic_armor_inc = 0.1,
		price = 4,
		patch = function(UP, u)
			patch_soldier_magic_armor_inc(u.factor, u.magic_armor_inc)
		end
	},
	barrack_improved_deployment = {
		class = "barracks",
		cooldown_factor = 0.8,
		icon = 10,
		level = 3,
		price = 2,
		rally_range_factor = 1.2,
		patch = function(UP, u)
			local towers_with_barrack = UP.towers_with_barrack
			patch_soldier_dead_lifetime(UP.soldiers, u.cooldown_factor)

			for _, n in ipairs(towers_with_barrack) do
				T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
			end
		end
	},
	barrack_survival = {
		class = "barracks",
		health_factor = 1.1,
		icon = 8,
		level = 1,
		price = 1,
		patch = function(UP, u)
			local function apply_soldier_health_factor(health_factor)
				H.apply_soldier_health_factor(UP.soldiers, health_factor)
			end
			apply_soldier_health_factor(u.health_factor)
		end
	},
	barrack_survival_2 = {
		class = "barracks",
		health_factor = 1.09,
		icon = 11,
		level = 4,
		price = 2,
		patch = function(UP, u)
			local function apply_soldier_health_factor(health_factor)
				H.apply_soldier_health_factor(UP.soldiers, health_factor)
			end
			apply_soldier_health_factor(u.health_factor)
		end
	},
	engineer_concentrated_fire = {
		class = "engineers",
		damage_factor = 1.25,
		icon = 23,
		level = 1,
		price = 1,
		patch = function(UP, u)
			H.bomb_damage_mul(UP.engineer_bombs, u.damage_factor)
		end
	},
	engineer_efficiency = {
		class = "engineers",
		icon = 27,
		level = 5,
		price = 3,
		patch = function(UP, u)
			mul_dmg(T("mod_tower_rotten_forest_burst_damage").dps, 1.25)
			mul_dmg(T("mod_ignis_altar_damage"), 1.25)
			mul_dmg(T("aura_tower_sandworm").aura, 1.25)
			mul_dmg(T("aura_bullet_culverine").aura, 1.25)
			mul_dmg(T("aura_bullet_culverine_skill_b").aura, 1.25)
			mul_dmg(T("bullet_culverine_air").bullet, 1.25)
			mul_dmg(T("bullet_culverine_skill_b_air").bullet, 1.25)
			mul_dmg(T("aura_culverine_ultimate").aura, 1.25)
			mul_dmg(T("bullet_alchemist_basic").bullet, 1.25)
			mul_dmg(T("bullet_alchemist_skill_c").bullet, 1.25)
			mul_dmg(T("aura_alchemist_hit_green").aura, 1.25)

			local alchemist_efficiency_aura_c = T("aura_alchemist_skill_c").aura
			mul_dmg(alchemist_efficiency_aura_c, 1.25)
			alchemist_efficiency_aura_c.damage_inc = alchemist_efficiency_aura_c.damage_inc * 1.25
		end
	},
	engineer_field_logistics = {
		class = "engineers",
		cost_factor = 0.9,
		icon = 25,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local engineer_towers = UP.engineer_towers
			scale_tower_price(engineer_towers, u.cost_factor, math.floor)
		end
	},
	engineer_gnomish_tinkering = {
		class = "engineers",
		cooldown_factor = 0.88,
		cooldown_factor_electric = 0.9,
		from_kr = 2,
		icon = 19,
		level = 6,
		price = 4,
		patch = function(UP, u)
			patch_engineer_power_cooldown(u.cooldown_factor, u.cooldown_factor_electric)
		end
	},
	engineer_industrialization = {
		class = "engineers",
		cost_factor = 0.8,
		icon = 26,
		level = 4,
		price = 3,
		patch = function(UP, u)
			scale_power_prices(UP.engineer_advanced_tower, u.cost_factor, math.floor)
		end
	},
	engineer_range_finder = {
		class = "engineers",
		icon = 24,
		level = 2,
		price = 1,
		range_factor = 1.1,
		patch = function(UP, u)
			patch_engineer_range(UP.engineer_towers, u.range_factor)
		end
	},
	mage_arcane_shatter = {
		class = "mages",
		icon = 19,
		level = 2,
		mod_little = "mod_arcane_shatter_little",
		mod_normal = "mod_arcane_shatter",
		price = 1,
		patch = function(UP, u)
			for _, n in ipairs(UP.bolts) do
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
	},
	mage_brilliance = {
		class = "mages",
		damage_factors = {1.18, 1.21, 1.24, 1.27, 1.29, 1.31, 1.33, 1.35, 1.36},
		from_kr = 2,
		icon = 15,
		level = 6,
		price = 4
	},
	mage_empowered_magic = {
		class = "mages",
		damage_factor = 1.15,
		icon = 21,
		level = 4,
		price = 2,
		patch = function(UP, u)
			H.mage_bolt_damage_mul(UP.mage_tower_bolts, u.damage_factor)
		end
	},
	mage_hermetic_study = {
		class = "mages",
		cost_factor = 0.91,
		icon = 20,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_price(mage_towers, u.cost_factor, math.ceil)
		end
	},
	mage_slow_curse = {
		class = "mages",
		icon = 22,
		level = 5,
		mod = "mod_slow_curse",
		price = 3,
		patch = function(UP, u)
			for _, n in ipairs(UP.bolts) do
				local mods = {u.mod}
				local b = T(n).bullet

				add_mods(b, mods)
			end

			add_mods(T("tower_pixie").attacks.list[4], {u.mod})
		end
	},
	mage_spell_reach = {
		class = "mages",
		icon = 18,
		level = 1,
		price = 1,
		range_factor = 1.15,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_attack_range(mage_towers, u.range_factor)
		end
	},
	rain_armaggedon = {
		class = "rain",
		fireball_count_increase = 1,
		from_kr = 2,
		icon = 25,
		level = 6,
		price = 4,
		patch = function(UP, u)
			T("power_fireball_control").cataclysm_count = T("power_fireball_control").cataclysm_count + u.fireball_count_increase
			T("power_fireball_control").fireball_count = T("power_fireball_control").fireball_count + u.fireball_count_increase
		end
	},
	rain_bigger_and_meaner = {
		class = "rain",
		cooldown_reduction = 10,
		damage_increase = 30,
		icon = 5,
		level = 3,
		price = 3,
		range_factor = 1.25,
		patch = function(UP, u)
			T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction
			T("power_fireball").bullet.damage_radius = T("power_fireball").bullet.damage_radius * u.range_factor
			T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
			T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
		end
	},
	rain_blazing_earth = {
		class = "rain",
		cooldown_reduction = 10,
		damage_max_increase = 30,
		damage_min_increase = 20,
		duration_increase = 10,
		icon = 6,
		level = 4,
		price = 3,
		patch = function(UP, u)
			T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction

			for _, name in ipairs({"power_scorched_earth", "power_scorched_water"}) do
				local aura = T(name).aura

				aura.damage_min = aura.damage_min + u.damage_min_increase
				aura.damage_max = aura.damage_max + u.damage_max_increase
				aura.duration = aura.duration + u.duration_increase
			end
		end
	},
	rain_blazing_skies = {
		class = "rain",
		damage_increase = 30,
		fireball_count_increase = 2,
		icon = 3,
		level = 1,
		price = 2,
		patch = function(UP, u)
			T("power_fireball_control").fireball_count = T("power_fireball_control").fireball_count + u.fireball_count_increase
			T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
			T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
		end
	},
	rain_cataclysm = {
		class = "rain",
		cataclysm_count_increase = 5,
		damage_increase = 60,
		icon = 7,
		level = 5,
		price = 3,
		patch = function(UP, u)
			T("power_fireball_control").cataclysm_count = T("power_fireball_control").cataclysm_count + u.cataclysm_count_increase
			T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
			T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
		end
	},
	rain_scorched_earth = {
		class = "rain",
		icon = 4,
		level = 2,
		price = 2,
		patch = function(UP, u)
			T("power_fireball").scorch_earth = true
		end
	},
	reinforcement_level_1 = {
		class = "reinforcements",
		icon = 28,
		level = 1,
		price = 2,
		template_name = "re_farmer_well_fed"
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		icon = 29,
		level = 2,
		price = 3,
		template_name = "re_conscript"
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		icon = 30,
		level = 3,
		price = 3,
		template_name = "re_warrior"
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		icon = 1,
		level = 4,
		price = 3,
		template_name = "re_legionnaire"
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		icon = 2,
		level = 5,
		price = 4,
		template_name = "re_legionnaire_ranged"
	},
	reinforcement_level_6 = {
		class = "reinforcements",
		cooldown_dec = 2,
		duration_inc = 2,
		from_kr = 3,
		icon = 29,
		level = 6,
		price = 4
	}

}

return {
	techs = techs,
	patch = function(UP)
		E:set_template("user_power_1", T("power_fireball_control"))

		T("power_fireball_control").user_power.level = UP.levels.rain
		T("power_thunder_control").user_power.level = UP.levels.rain

		E:set_template("user_power_2", T("power_reinforcements_control"))

		if UP.levels.reinforcements > 0 then
			local rl = math.min(UP.levels.reinforcements, UP.max_level)

			if rl > 5 then
				rl = 5
			end

			local u = UP:get_upgrade("reinforcement_level_" .. rl)
			local v = UP:get_upgrade("reinforcement_level_6")

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
}
