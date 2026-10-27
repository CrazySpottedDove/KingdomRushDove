local H = require("kr1.upgrades.upgrade_utils")

local T = H.T
local E = require("entity_db")
local U = require("utils")
local mul_field = H.mul_field
local mul_dmg = H.mul_dmg
local add_damage_hooks = H.add_damage_hooks
local scale_tower_price = H.scale_tower_price
local scale_power_prices = H.scale_power_prices
local scale_tower_attack_range = H.scale_tower_attack_range
local scale_sprite = H.scale_sprite
local patch_soldier_armor_inc = H.patch_soldier_armor_inc
local patch_soldier_dead_lifetime = H.patch_soldier_dead_lifetime
local patch_engineer_power_cooldown = H.patch_engineer_power_cooldown
local patch_engineer_range = H.patch_engineer_range

local apply_mod = H.apply_mod

local add_mods = H.add_mods

local techs = {
	archer_eagle_eye = {
		class = "archers",
		from_kr = 3,
		icon = 4,
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
	archer_magic = {
		class = "archers",
		factor = 0.12,
		from_kr = 3,
		icon = 3,
		level = 5,
		price = 3,
		patch = function(UP, u)
			T("mod_archer_magic")._mod_archer_magic_factor = u.factor
			for _, n in ipairs(UP.arrows) do
				local b = T(n).bullet
				apply_mod(b, "mod_archer_magic")
			end
		end
	},
	archer_obsidian = {
		class = "archers",
		damage_factor = 1.27,
		from_kr = 3,
		icon = 2,
		level = 3,
		price = 2,
		patch = function(UP, u)
			local archer_obsidian_factor = u.damage_factor
			add_damage_hooks(UP.arrows, function(entity, damage, protection)
				if protection <= 0.1 then
					damage.value = damage.value * archer_obsidian_factor
				end
			end)
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
	barrack_dominant = {
		class = "barracks",
		from_kr = 3,
		icon = 7,
		level = 6,
		price = 4,
		rally_range_factor = 2,
		speed_factor = 1.2,
		patch = function(UP, u)
			local soldiers = UP.soldiers
			local towers_with_barrack = UP.towers_with_barrack
			for _, n in ipairs(towers_with_barrack) do
				T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
			end
			for _, n in ipairs(soldiers) do
				T(n).motion.max_speed = T(n).motion.max_speed * u.speed_factor
			end
			T("soldier_tower_rocket_gunners_lvl4").speed_flight = T("soldier_tower_rocket_gunners_lvl4").speed_flight * u.speed_factor
			T("soldier_tower_rocket_gunners_lvl4").speed_ground = T("soldier_tower_rocket_gunners_lvl4").speed_ground * u.speed_factor
		end
	},
	barrack_go_on = {
		class = "barracks",
		cooldown_factor = 0.75,
		from_kr = 2,
		icon = 10,
		level = 3,
		price = 2,
		patch = function(UP, u)
			patch_soldier_dead_lifetime(UP.soldiers, u.cooldown_factor)
		end
	},
	barrack_mobilize = {
		class = "barracks",
		from_kr = 2,
		icon = 7,
		level = 5,
		price = 3,
		price_factor = 0.8,
		patch = function(UP, u)
			local barrack_towers = UP.barrack_towers
			scale_tower_price(barrack_towers, u.price_factor, math.floor)
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
		from_kr = 3,
		icon = 16,
		level = 1,
		price = 1,
		patch = function(UP, u)
			H.bomb_damage_mul(UP.engineer_bombs, u.damage_factor)
		end
	},
	engineer_diffusion = {
		class = "engineers",
		from_kr = 3,
		icon = 17,
		level = 2,
		price = 1,
		radius_factor = 1.15,
		patch = function(UP, u)
			local engineer_bombs = UP.engineer_bombs
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
			mul_field(T("tower_tree").attacks, "range", u.radius_factor)

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
			mul_field(T("bullet_culverine_air").bullet, "damage_radius", u.radius_factor)
			mul_field(T("bullet_culverine_skill_b_air").bullet, "damage_radius", u.radius_factor)
			scale_sprite(T("fx_bullet_culverine_hit").render.sprites[1], u.radius_factor)
			scale_sprite(T("fx_bullet_culverine_skill_b_hit").render.sprites[1], u.radius_factor)

			for _, name in ipairs({"aura_alchemist_hit_green", "aura_alchemist_skill_a", "aura_alchemist_skill_c"}) do
				local t = T(name)
				mul_field(t.aura, "radius", u.radius_factor)
				scale_sprite(t.render.sprites[1], u.radius_factor)
			end
		end
	},
	engineer_efficiency = {
		class = "engineers",
		from_kr = 3,
		icon = 20,
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
		cost_factor = 0.88,
		icon = 25,
		level = 4,
		price = 3,
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
	engineer_range_finder = {
		class = "engineers",
		from_kr = 3,
		icon = 18,
		level = 3,
		price = 2,
		range_factor = 1.15,
		patch = function(UP, u)
			patch_engineer_range(UP.engineer_towers, u.range_factor)
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
		from_kr = 3,
		icon = 12,
		level = 2,
		price = 1,
		patch = function(UP, u)
			H.mage_bolt_damage_mul(UP.mage_tower_bolts, u.damage_factor)
		end
	},
	mage_old_folk = {
		class = "mages",
		cost_factor = 0.9,
		from_kr = 2,
		icon = 14,
		level = 4,
		price = 2,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_power_prices(mage_towers, u.cost_factor, math.ceil)
		end
	},
	mage_spell_reach = {
		class = "mages",
		from_kr = 3,
		icon = 11,
		level = 1,
		price = 1,
		range_factor = 1.15,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_attack_range(mage_towers, u.range_factor)
		end
	},
	mage_spell_reach_2 = {
		class = "mages",
		from_kr = 3,
		icon = 15,
		level = 3,
		price = 2,
		range_factor = 1.05,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_attack_range(mage_towers, u.range_factor)
		end
	},
	mage_treasure = {
		class = "mages",
		extra_gold_factor = 0.01,
		from_kr = 3,
		icon = 13,
		level = 5,
		max_extra_gold_factor = 0.1,
		price = 3,
		patch = function(UP, u)
			T("mod_mage_treasure").extra_gold_factor = u.extra_gold_factor
			T("mod_mage_treasure").max_extra_gold_factor = u.max_extra_gold_factor
			for _, n in ipairs(UP.mage_tower_bolts) do
				local b = T(n).bullet
				add_mods(b, {"mod_mage_treasure"})
			end
			add_mods(T("tower_pixie").attacks.list[4], {"mod_mage_treasure"})
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
	thunder_level_6 = {
		class = "rain",
		from_kr = 3,
		icon = 10,
		level = 6,
		price = 4,
		patch = function(UP, u)
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
