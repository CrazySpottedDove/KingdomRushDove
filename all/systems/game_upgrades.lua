local M = {}

local math = require("math")
local ceil = math.ceil
local bit = require("bit")
local E = require("entity_db")
local UP = require("kr1.upgrades")
local km = require("lib.klua.macros")

function M.register(sys)

	sys.game_upgrades = {}
	sys.game_upgrades.name = "game_upgrades"

	function sys.game_upgrades:init(store)
		self.mage_tower_map = table.to_map(UP.mage_towers)
	end

	function sys.game_upgrades:on_insert_unconditional(entity, store)
		local mage_bullet_names = UP.mage_tower_bolts
		local mage_tower_map = self.mage_tower_map
		local u = UP:get_upgrade("mage_brilliance")

		if entity.tower and u and mage_tower_map[entity.template_name] then
			local existing_towers = table.filter(store.towers, function(_, e)
				return mage_tower_map[e.template_name]
			end)
			local dps = E:get_template("mod_ray_arcane").dps
			local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
			local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
			local dps_infernal_mage = E:get_template("mod_lava_infernal_mage").dps

			local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

			for _, bn in ipairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				if not b._orig_damage_min then
					b._orig_damage_min = b.damage_min
					b._orig_damage_max = b.damage_max
				end

				b.damage_min = ceil(b._orig_damage_min * f)
				b.damage_max = ceil(b._orig_damage_max * f)
			end

			if not dps._orig_damage_min then
				dps._orig_damage_min = dps.damage_min
				dps._orig_damage_max = dps.damage_max
			end

			dps.damage_min = ceil(dps._orig_damage_min * f)
			dps.damage_max = ceil(dps._orig_damage_max * f)

			if not bullet_ray_high_elven._orig_damage_min then
				bullet_ray_high_elven._orig_damage_min = bullet_ray_high_elven.damage_min
				bullet_ray_high_elven._orig_damage_max = bullet_ray_high_elven.damage_max
			end

			bullet_ray_high_elven.damage_min = ceil(bullet_ray_high_elven._orig_damage_min * f)
			bullet_ray_high_elven.damage_max = ceil(bullet_ray_high_elven._orig_damage_max * f)

			if not modifier_pixie._orig_damage_min then
				modifier_pixie._orig_damage_min = modifier_pixie.damage_min
				modifier_pixie._orig_damage_max = modifier_pixie.damage_max
			end

			modifier_pixie.damage_min = ceil(modifier_pixie._orig_damage_min * f)
			modifier_pixie.damage_max = ceil(modifier_pixie._orig_damage_max * f)

			local arcane5_disintegrate = E:get_template("tower_arcane_wizard_ray_disintegrate_mod")

			if not arcane5_disintegrate._origin_damage_config then
				arcane5_disintegrate._origin_damage_config = {}
				arcane5_disintegrate._origin_damage_config[1] = arcane5_disintegrate.boss_damage_config[1]
				arcane5_disintegrate._origin_damage_config[2] = arcane5_disintegrate.boss_damage_config[2]
				arcane5_disintegrate._origin_damage_config[3] = arcane5_disintegrate.boss_damage_config[3]
			end

			for i = 1, 3 do
				arcane5_disintegrate.boss_damage_config[i] = ceil(arcane5_disintegrate._origin_damage_config[i] * f)
			end

			if not dps_infernal_mage._orig_damage_min then
				dps_infernal_mage._orig_damage_min = dps_infernal_mage.damage_min
				dps_infernal_mage._orig_damage_max = dps_infernal_mage.damage_max
			end

			dps_infernal_mage.damage_min = ceil(dps_infernal_mage._orig_damage_min * f)
			dps_infernal_mage.damage_max = ceil(dps_infernal_mage._orig_damage_max * f)
		end

	-- return true
	end

	function sys.game_upgrades:on_remove_unconditional(entity, store)
		local mage_bullet_names = UP.mage_tower_bolts
		local mage_tower_map = self.mage_tower_map
		local u = UP:get_upgrade("mage_brilliance")

		if entity.tower and u and mage_tower_map[entity.template_name] then
			local existing_towers = table.filter(store.towers, function(_, e)
				return mage_tower_map[e.template_name]
			end)
			local dps = E:get_template("mod_ray_arcane").dps
			local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
			local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
			local dps_infernal_mage = E:get_template("mod_lava_infernal_mage").dps
			local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

			for _, bn in ipairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				b.damage_min = ceil(b._orig_damage_min * f)
				b.damage_max = ceil(b._orig_damage_max * f)
			end

			dps.damage_min = ceil(dps._orig_damage_min * f)
			dps.damage_max = ceil(dps._orig_damage_max * f)
			bullet_ray_high_elven.damage_min = ceil(bullet_ray_high_elven._orig_damage_min * f)
			bullet_ray_high_elven.damage_max = ceil(bullet_ray_high_elven._orig_damage_max * f)
			modifier_pixie.damage_min = ceil(modifier_pixie._orig_damage_min * f)
			modifier_pixie.damage_max = ceil(modifier_pixie._orig_damage_max * f)

			local arcane5_disintegrate = E:get_template("tower_arcane_wizard_ray_disintegrate_mod")

			for i = 1, 3 do
				arcane5_disintegrate.boss_damage_config[i] = ceil(arcane5_disintegrate._origin_damage_config[i] * f)
			end

			dps_infernal_mage.damage_min = ceil(dps_infernal_mage._orig_damage_min * f)
			dps_infernal_mage.damage_max = ceil(dps_infernal_mage._orig_damage_max * f)
		end

		return true
	end
end

return M
