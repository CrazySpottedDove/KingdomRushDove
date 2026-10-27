local H = require("kr1.upgrades.upgrade_utils")

local T = H.T
local E = require("entity_db")
local bit = require("bit")
local mul_field = H.mul_field
local mul_dmg = H.mul_dmg
local avg_dmg_mul = H.avg_dmg_mul
local scale_tower_price = H.scale_tower_price
local scale_power_prices = H.scale_power_prices
local scale_tower_damage = H.scale_tower_damage
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
	archer_fly_killer = {
		class = "archers",
		damage_factor = 1.08,
		damage_factor_fly = 1.25,
		from_kr = 2,
		icon = 4,
		level = 5,
		price = 3,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_tower_damage(archer_towers, u.damage_factor)
			local damage_factor_fly = u.damage_factor_fly
			for _, n in ipairs(UP.arrows) do
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
	},
	archer_logger = {
		class = "archers",
		cost_factor = 0.9,
		from_kr = 2,
		icon = 2,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_power_prices(archer_towers, u.cost_factor, math.ceil)
		end
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
		rally_range_factor = 1.25,
		patch = function(UP, u)
			local towers_with_barrack = UP.towers_with_barrack
			patch_soldier_dead_lifetime(UP.soldiers, u.cooldown_factor)

			for _, n in ipairs(towers_with_barrack) do
				T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
			end
		end
	},
	barrack_skill_master = {
		class = "barracks",
		from_kr = 2,
		icon = 7,
		level = 5,
		price = 3,
		price_factor = 0.9,
		patch = function(UP, u)
			local barrack_towers = UP.barrack_towers
			scale_tower_price(barrack_towers, u.price_factor, math.floor)
			scale_power_prices(barrack_towers, u.price_factor, math.ceil)
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
		health_factor = 1.05,
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
	engineer_emergency_expansion = {
		class = "engineers",
		cost_factor = 0.75,
		damage_factor = 0.88,
		icon = 25,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local engineer_towers = UP.engineer_towers
			scale_tower_price(engineer_towers, u.cost_factor, math.floor)
			H.bomb_damage_mul(UP.engineer_bombs, u.damage_factor)
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
	mage_empowered_magic = {
		class = "mages",
		damage_factor = 1.15,
		icon = 19,
		level = 2,
		price = 1,
		patch = function(UP, u)
			H.mage_bolt_damage_mul(UP.mage_tower_bolts, u.damage_factor)
		end
	},
	mage_harmony = {
		class = "mages",
		damage_factor = 1.07,
		from_kr = 2,
		icon = 11,
		level = 5,
		price = 3,
		range_factor = 1.07,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_attack_range(mage_towers, u.range_factor)

			for _, n in ipairs(UP.mage_tower_bolts) do
				avg_dmg_mul(T(n).bullet, u.damage_factor)
			end

			avg_dmg_mul(T("mod_ray_arcane").dps, u.damage_factor)
			avg_dmg_mul(T("mod_pixie_pickpocket").modifier, u.damage_factor)

			local d = T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config

			for k, v in ipairs(d) do
				d[k] = v * u.damage_factor
			end

			avg_dmg_mul(T("mod_lava_infernal_mage").dps, u.damage_factor)
			avg_dmg_mul(T("mod_wicked_sister_poison").dps, u.damage_factor)

			mul_field(T("mod_ultimate_wizard"), "damage", u.damage_factor)
			avg_dmg_mul(T("aura_sunray_master_beam").aura, u.damage_factor)
			avg_dmg_mul(T("aura_sunray_master_ult_beam").aura, u.damage_factor)
		end
	},
	mage_purge_field = {
		class = "mages",
		icon = 21,
		level = 6,
		price = 4,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
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
	},
	mage_rune_analysis = {
		class = "mages",
		cost_factor = 0.94,
		icon = 20,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_price(mage_towers, u.cost_factor, math.ceil)
			scale_power_prices(mage_towers, u.cost_factor, math.ceil)
		end
	},
	mage_slow_curse = {
		class = "mages",
		icon = 22,
		level = 4,
		mod = "mod_slow_curse",
		price = 2,
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
		cooldown_dec = 2.5,
		duration_inc = 1,
		from_kr = 3,
		icon = 29,
		level = 6,
		price = 4
	},
	thunder_level_1 = {
		class = "rain",
		from_kr = 3,
		hits_increase = 3,
		icon = 21,
		level = 1,
		price = 2,
		patch = function(UP, u)
			T("power_thunder_control").thunders[1].count = T("power_thunder_control").thunders[1].count + u.hits_increase
		end
	},
	thunder_level_2 = {
		class = "rain",
		cooldown_reduction = 10,
		damage_max_increase = 10,
		damage_min_increase = 30,
		from_kr = 3,
		icon = 22,
		level = 2,
		price = 2,
		patch = function(UP, u)
			T("power_thunder_control").cooldown = T("power_thunder_control").cooldown - u.cooldown_reduction
			T("power_thunder_control").thunders[1].damage_max = T("power_thunder_control").thunders[1].damage_max + u.damage_max_increase
			T("power_thunder_control").thunders[1].damage_min = T("power_thunder_control").thunders[1].damage_min + u.damage_min_increase
		end
	},
	thunder_level_3 = {
		class = "rain",
		from_kr = 3,
		hits_increase = 2,
		icon = 23,
		level = 3,
		price = 3,
		slow_factor_increase = 0.6,
		patch = function(UP, u)
			T("power_thunder_control").thunders[1].count = T("power_thunder_control").thunders[1].count + u.hits_increase
			T("power_thunder_control").rain.disabled = nil
			T("power_thunder_control").slow.disabled = nil
			T("mod_power_thunder_slow").slow.factor = T("mod_power_thunder_slow").slow.factor + u.slow_factor_increase
		end
	},
	thunder_level_4 = {
		class = "rain",
		damage_max_increase = 30,
		damage_min_increase = 30,
		from_kr = 3,
		icon = 24,
		level = 4,
		price = 3,
		slow_factor_increase = -0.2,
		patch = function(UP, u)
			T("mod_power_thunder_slow").slow.factor = T("mod_power_thunder_slow").slow.factor + u.slow_factor_increase
			T("power_thunder_control").thunders[1].damage_max = T("power_thunder_control").thunders[1].damage_max + u.damage_max_increase
			T("power_thunder_control").thunders[1].damage_min = T("power_thunder_control").thunders[1].damage_min + u.damage_min_increase
		end
	},
	thunder_level_5 = {
		class = "rain",
		damage_max_increase = 70,
		damage_min_increase = 40,
		from_kr = 3,
		icon = 25,
		level = 5,
		price = 3,
		second_count_increase = 6,
		patch = function(UP, u)
			T("power_thunder_control").thunders[1].damage_max = T("power_thunder_control").thunders[1].damage_max + u.damage_max_increase
			T("power_thunder_control").thunders[1].damage_min = T("power_thunder_control").thunders[1].damage_min + u.damage_min_increase
			T("power_thunder_control").thunders[2].count = T("power_thunder_control").thunders[2].count + u.second_count_increase
		end
	},
	thunder_typhoon = {
		class = "rain",
		from_kr = 3,
		icon = 21,
		level = 6,
		price = 4,
		patch = function(UP, u)
			T("power_thunder_control").thunders[1].count = 10
			T("power_thunder_control").thunders[2].count = 10
			T("power_thunder_control").slow.factor = 0.25
			T("power_thunder_control").extra_duration = 4
		end
	}

}

return {
	techs = techs,
	patch = function(UP)
		E:set_template("user_power_1", T("power_thunder_control"))

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
