local tower = {}
tower.name = "tower"

local E = require("entity_db")
local km = require("lib.klua.macros")
local UP = require("kr1.upgrades")

--- 缩放组件的 damage_min / damage_max，首次调用时记录原始值
---@param component table 组件表
---@param factor number 倍率
local function scale_damage(component, factor)
	local orig_min = component._orig_damage_min

	if not orig_min then
		orig_min = component.damage_min
		component._orig_damage_min = orig_min
		component._orig_damage_max = component.damage_max
	end

	component.damage_min = orig_min * factor
	component.damage_max = component._orig_damage_max * factor
end

--- 缩放组件上的一维数字数组字段，首次调用时记录原始值
---@param component table 组件表
---@param field string 数组字段名
---@param factor number 倍率
local function scale_damage_config(component, field, factor)
	local config = component[field]
	local orig_field = "_orig_" .. field
	local orig = component[orig_field]

	if not orig then
		orig = {}
		component[orig_field] = orig

		for i = 1, #config do
			orig[i] = config[i]
		end
	end

	for i = 1, #config do
		config[i] = orig[i] * factor
	end
end

--- 统一处理 mage_brilliance 涉及的所有伤害模板
---@param factor number 当前层数对应的伤害倍率
local function scale_mage_brilliance_damage(factor)
	for _, name in ipairs(UP.mage_tower_bolts) do
		scale_damage(E:get_template(name).bullet, factor)
	end

	local arcane_dps = E:get_template("mod_ray_arcane").dps
	local high_elven_bullet = E:get_template("ray_high_elven_sentinel").bullet
	local pixie_modifier = E:get_template("mod_pixie_pickpocket").modifier
	local infernal_dps = E:get_template("mod_lava_infernal_mage").dps
	local wicked_sister_dps = E:get_template("mod_wicked_sister_poison").dps
	local arcane_disintegrate = E:get_template("tower_arcane_wizard_ray_disintegrate_mod")

	scale_damage(arcane_dps, factor)
	scale_damage(high_elven_bullet, factor)
	scale_damage(pixie_modifier, factor)
	scale_damage(infernal_dps, factor)
	scale_damage(wicked_sister_dps, factor)
	scale_damage_config(arcane_disintegrate, "boss_damage_config", factor)

	scale_damage(E:get_template("aura_sunray_master_beam").aura, factor)
	scale_damage(E:get_template("aura_sunray_master_ult_beam").aura, factor)
end

function tower:init(store)
	store.towers = {}
	require("lib.klua.table")
	self.mage_tower_map = table.to_map(UP.mage_towers)
end

function tower:on_insert_unconditional(entity, store)
	if entity.tower then
		-- tower index
		store.towers[entity.id] = entity

		-- mage_brilliance
		local mage_tower_map = self.mage_tower_map
		local u = UP:get_upgrade("mage_brilliance")

		if u and mage_tower_map[entity.template_name] then
			local existing_towers = table.filter(store.towers, function(_, e)
				return mage_tower_map[e.template_name]
			end)
			local factor = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

			scale_mage_brilliance_damage(factor)
		end
	end
end

function tower:on_remove_unconditional(entity, store)
	if entity.tower then
		-- mage_brilliance
		local mage_tower_map = self.mage_tower_map
		local u = UP:get_upgrade("mage_brilliance")

		if u and mage_tower_map[entity.template_name] then
			local existing_towers = table.filter(store.towers, function(_, e)
				return mage_tower_map[e.template_name]
			end)
			local factor = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

			scale_mage_brilliance_damage(factor)
		end

		-- tower index
		store.towers[entity.id] = nil
	end
end

return tower
