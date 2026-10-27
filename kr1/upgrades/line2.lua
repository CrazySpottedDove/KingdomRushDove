local H = require("kr1.upgrades.upgrade_utils")

local T = H.T
local E = require("entity_db")
local GS = require("kr1.game_settings")
local mul_dmg = H.mul_dmg
local add_damage_hooks = H.add_damage_hooks
local scale_power_prices = H.scale_power_prices
local scale_tower_damage = H.scale_tower_damage
local scale_tower_attack_range = H.scale_tower_attack_range
local patch_soldier_magic_armor_inc = H.patch_soldier_magic_armor_inc
local patch_soldier_dead_lifetime = H.patch_soldier_dead_lifetime
local patch_engineer_power_cooldown = H.patch_engineer_power_cooldown
local patch_engineer_range = H.patch_engineer_range

local apply_mod = H.apply_mod

local techs = {
	archer_critical = {
		class = "archers",
		damage_factor = 1.1,
		from_kr = 2,
		icon = 3,
		level = 3,
		price = 2,
		patch = function(UP, u)
			scale_tower_damage(GS.archer_towers, u.damage_factor)
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
		from_kr = 2,
		icon = 1,
		level = 1,
		price = 1,
		range_factor = 1.25,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_tower_attack_range(archer_towers, u.range_factor)
		end
	},
	archer_fast_shots = {
		class = "archers",
		cooldown_factor = 0.9,
		from_kr = 2,
		icon = 5,
		level = 5,
		price = 3,
		patch = function(UP, u)
			local SU = H.get_SU()
			local archer_towers = UP.archer_towers
			for _, n in ipairs(archer_towers) do
				local t = T(n)
				SU.insert_tower_cooldown_buff(0, t, u.cooldown_factor)
			end
		end
	},
	archer_logger = {
		class = "archers",
		cost_factor = 0.9,
		from_kr = 2,
		icon = 2,
		level = 2,
		price = 1,
		patch = function(UP, u)
			local archer_towers = UP.archer_towers
			scale_power_prices(archer_towers, u.cost_factor, math.ceil)
		end
	},
	archer_tear = {
		class = "archers",
		from_kr = 2,
		icon = 4,
		level = 4,
		price = 2,
		patch = function(UP, u)
			for _, n in ipairs(UP.arrows) do
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
	},
	barrack_bodies = {
		class = "barracks",
		from_kr = 2,
		icon = 6,
		level = 1,
		price = 1,
		patch = function(UP, u)
			local barrack_soldiers = UP.barrack_soldiers
			local special_towers = {"tower_baby_ashbite", "tower_pandas_lvl4", "tower_miners"}
			for _, n in ipairs(GS.barrack_towers) do
				if not table.arraycontains(special_towers, n) then
					local t = T(n)
					local soldier_t = t.barrack.soldier_type
					if soldier_t then
						local soldier_tpl = T(soldier_t)
						if soldier_tpl then
							local x = t.barrack.max_soldiers
							if n == "tower_dwarf_lvl4" then
								x = x + 3
							end
							local factor = (4 * x) / (3 * (x + 1))
							soldier_tpl.unit.damage_factor = soldier_tpl.unit.damage_factor + (factor - 1)
						end
					end
					t.barrack.max_soldiers = t.barrack.max_soldiers + 1
				end
			end
			local special_soldiers = {
				"soldier_baby_ashbite",
				"soldier_tower_pandas_green_lvl4",
				"soldier_tower_pandas_red_lvl4",
				"soldier_tower_pandas_blue_lvl4",
				"soldier_ogre_shipwreck_cook",
				"soldier_ogre_shipwreck_deckhand",
				"soldier_ogre_shipwreck_red_goblin",
				"soldier_ogre_shipwreck_red_goblin_elite",
				"soldier_swamp_monster",
				"soldier_miners",
				"soldier_tree"
			}

			for _, n in ipairs(special_soldiers) do
				local t = T(n)
				t.unit.damage_factor = t.unit.damage_factor + 0.3
			end

			for _, n in ipairs(barrack_soldiers) do
				local t = T(n)
				if t.health.hp_max and not table.arraycontains(special_soldiers, n) then
					t.health.hp_max = t.health.hp_max * 0.8
				end
			end
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
	barrack_go_on = {
		class = "barracks",
		cooldown_factor = 0.8,
		from_kr = 2,
		icon = 10,
		level = 5,
		price = 3,
		patch = function(UP, u)
			patch_soldier_dead_lifetime(UP.soldiers, u.cooldown_factor)
		end
	},
	barrack_march = {
		class = "barracks",
		from_kr = 2,
		icon = 7,
		level = 2,
		price = 1,
		rally_range_factor = 1.1,
		speed_inc = 12,
		patch = function(UP, u)
			local soldiers = UP.soldiers
			local towers_with_barrack = UP.towers_with_barrack
			for _, n in ipairs(towers_with_barrack) do
				T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
			end
			for _, n in ipairs(soldiers) do
				T(n).motion.max_speed = T(n).motion.max_speed + u.speed_inc
			end
			T("soldier_tower_rocket_gunners_lvl4").speed_flight = T("soldier_tower_rocket_gunners_lvl4").speed_flight + u.speed_inc
			T("soldier_tower_rocket_gunners_lvl4").speed_ground = T("soldier_tower_rocket_gunners_lvl4").speed_ground + u.speed_inc
		end
	},
	barrack_rally = {
		class = "barracks",
		from_kr = 2,
		icon = 8,
		level = 3,
		price = 2,
		rally_range_factor = 1.2,
		patch = function(UP, u)
			local towers_with_barrack = UP.towers_with_barrack
			for _, n in ipairs(towers_with_barrack) do
				T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
			end
		end
	},
	barrack_weapon = {
		class = "barracks",
		damage_factor = 1.1,
		from_kr = 2,
		icon = 9,
		level = 4,
		price = 2,
		patch = function(UP, u)
			local soldiers = UP.soldiers
			for _, n in ipairs(soldiers) do
				T(n).unit.damage_factor = T(n).unit.damage_factor + (u.damage_factor - 1)
			end
		end
	},
	engineer_concentrated_fire = {
		class = "engineers",
		damage_factor = 1.1,
		from_kr = 2,
		icon = 18,
		level = 3,
		price = 2,
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
	engineer_magic_dust = {
		class = "engineers",
		damage_factor = 1.2,
		from_kr = 2,
		icon = 17,
		level = 2,
		price = 1,
		patch = function(UP, u)
			local engineer_bombs = UP.engineer_bombs
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
			mul_dmg(T("aura_tree_attack").aura, u.damage_factor)
			mul_dmg(T("aura_tree_ultimate_bomb").aura, u.damage_factor)

			-- 炼金术士主伤害在 aura 上，吃不到 magic dust 的命中 hook，按惯例直接补伤害
			mul_dmg(T("aura_alchemist_hit_green").aura, u.damage_factor)

			local alchemist_dust_aura_c = T("aura_alchemist_skill_c").aura
			mul_dmg(alchemist_dust_aura_c, u.damage_factor)
			alchemist_dust_aura_c.damage_inc = alchemist_dust_aura_c.damage_inc * u.damage_factor
		end
	},
	engineer_range_finder = {
		class = "engineers",
		from_kr = 2,
		icon = 16,
		level = 1,
		price = 1,
		range_factor = 1.15,
		patch = function(UP, u)
			patch_engineer_range(UP.engineer_towers, u.range_factor)
		end
	},
	mage_arcane_spell = {
		class = "mages",
		damage_factor = 1.15,
		from_kr = 2,
		icon = 11,
		level = 1,
		price = 1,
		patch = function(UP, u)
			H.mage_bolt_damage_mul(UP.mage_tower_bolts, u.damage_factor)
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
	mage_old_folk = {
		class = "mages",
		cost_factor = 0.85,
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
		from_kr = 2,
		icon = 13,
		level = 3,
		price = 2,
		range_factor = 1.1,
		patch = function(UP, u)
			local mage_towers = UP.mage_towers
			scale_tower_attack_range(mage_towers, u.range_factor)
		end
	},
	mage_strike = {
		class = "mages",
		from_kr = 2,
		icon = 12,
		level = 2,
		price = 1,
		patch = function(UP, u)
			local function mage_strike(entity, damage, protection)
				if protection <= 0 then
					damage.value = damage.value * 1.2
				end
			end
			add_damage_hooks(UP.mage_tower_bolts, mage_strike)

			-- 女巫的毒伤吃不到这个科技，进行伤害补偿
			mul_dmg(T("mod_wicked_sister_poison").dps, 1.15)
			mul_dmg(T("aura_sunray_master_beam").aura, 1.15)
			mul_dmg(T("aura_sunray_master_ult_beam").aura, 1.15)
		end
	},
	mage_unsteady = {
		class = "mages",
		icon = 21,
		level = 5,
		price = 3,
		patch = function(UP, u)
			local function mage_unsteady(entity, damage, protection)
				if math.random() < 0.1 and protection < 1 then
					damage.value = damage.value * 2 / (1 - protection)
				end
			end
			add_damage_hooks(UP.mage_tower_bolts, mage_unsteady)
			-- 女巫的毒伤吃不到这个科技，进行伤害补偿
			mul_dmg(T("mod_wicked_sister_poison").dps, 1.1)
			mul_dmg(T("aura_sunray_master_beam").aura, 1.1)
			mul_dmg(T("aura_sunray_master_ult_beam").aura, 1.1)
		end
	},
	rain_armaggedon = {
		class = "rain",
		fireball_count_increase = 2,
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
		cooldown_reduction = 12,
		damage_increase = 25,
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
		cooldown_reduction = 12,
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
		damage_increase = 20,
		fireball_count_increase = 3,
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
		damage_increase = 45,
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
		cooldown_dec = 2.5,
		duration_inc = 1,
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
