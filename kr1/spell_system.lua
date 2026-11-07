-- power3 法术系统（注册表 + 生命周期），不再是声明式 patch 引擎。
-- 每个法术是一个独立模块（kr1/spells/<id>.lua），聚焦暴露 register_templates(E) / apply(level)。
-- 集成点：
--   1. all/director.lua        -- SPELLS:set_selected(...) + 按选择 queue 资源
--   2. all/systems/level.lua   -- 热注册模板 + 预编译 + apply
--   3. all-desktop/game_gui.lua -- Power3Button / 开火分支 / 解锁
local E = require("entity_db")
local UP = require("kr1.upgrades")
local GS = require("kr1.game_settings")
local km = require("lib.klua.macros")
local log = require("lib.klua.log"):new("spell_system")
local Registry = require("registry")

require("lib.klua.table")

local SPELLS = Registry.new({
	module_names = {"kr1.spells.royal_edict", "kr1.spells.aspect_of_sol", "kr1.spells.musketeers", "kr1.spells.wintersongs_wrath", "kr1.spells.rain_of_fire", "kr1.spells.teleportation_sigil", "kr1.spells.thunder_zapper", "kr1.spells.reinforcements_kr6", "kr1.spells.soaring_shop"},
	lazy = true
})

SPELLS.max_level = 6
-- 当前选择由 SPELLS 自己管理，不挂到 store 上。
SPELLS.selected_id = nil
-- 选中法术时全体敌人生命倍率
SPELLS.spell_hp_factor = 1.1

--- 按法术 name 懒加载模块（name 必须等于 module_names 路径最后一段）。
---@param name string
---@return table?
function SPELLS:get(name)
	local spell, err = Registry.get(self, name)

	if err then
		log.error("failed to load spell module %s: %s", name, tostring(err))
		return nil
	end

	if spell and (type(spell) ~= "table" or not spell.name) then
		log.error("invalid spell module %s: expected table with name", name)
		return nil
	end

	return spell
end

--- 设置当前选择。selected_id 只保存当前有效的法术。
--- 存档里的 spell_power_id 由调用方保留，插件重新加载后还能恢复。
---@param id string|nil
function SPELLS:set_selected(id)
	local spell = self:get(id)

	self.selected_id = spell and id or nil

	return spell
end

--- 当前实际可用的法术模块；id 无效/插件未加载时返回 nil。
---@return table?
function SPELLS:get_selected()
	if not self.selected_id then
		return nil
	end

	return self:get(self.selected_id)
end

--- 当前选择对应的敌人生命倍率；未选择/无效时返回 1。
---@return number
function SPELLS:hp_factor()
	return self:get_selected() and self.spell_hp_factor or 1
end

--- 枚举所有法术模块（仅供选择 GUI 使用，首次打开时才 require）
---@return table[]
function SPELLS:modules()
	for _, path in ipairs(self.module_names) do
		self:get(path:match("([^%.]+)$"))
	end

	return self:all()
end

--- 按照火雨援军的等级计算自定义法术的等级
---@return integer
function SPELLS:compute_level(store)
	local max_lvl = store.level.max_upgrade_level or UP.max_level or GS.max_upgrade_level or self.max_level
	max_lvl = math.min(max_lvl, self.max_level)

	return km.clamp(1, max_lvl, math.ceil(UP.levels.rain + UP.levels.reinforcements) / 2)
end

function SPELLS:register_common_templates(E)
	local tt = E:register_t("power_control_custom")
	E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

	E:register_t("user_power_3")
end

--- 仅选中时注册本局法术模板
function SPELLS:register_templates(E)
	local spell = self:get_selected()

	if not spell then
		return
	end

	self:register_common_templates(E)
	spell.register_templates(E)
end

--- 法术模板注册完成后的处理
function SPELLS:apply(store)
	local spell = self:get_selected()

	if not spell then
		return
	end

	spell.apply(self:compute_level(store))

	local up = E:get_template("user_power_3")
	up.power_id = spell.name
end

return SPELLS
