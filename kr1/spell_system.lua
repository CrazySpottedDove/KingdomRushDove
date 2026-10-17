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

require("lib.klua.table")

local SPELLS = {}

SPELLS.registry = {}
SPELLS.max_level = 6
-- 当前选择由 SPELLS 自己管理，不挂到 store 上。
SPELLS.selected_id = nil
-- 选中法术时全体敌人生命倍率
SPELLS.spell_hp_factor = 1.1

-- spell 模块路径注册表
SPELLS.module_names = {"kr1.spells.royal_edict", "kr1.spells.aspect_of_sol"}

--- 按法术 id 懒加载模块（id 必须等于 module_names 路径最后一段）
--- 先确认 module_names 里仍有这个路径，避免插件卸载后还命中旧缓存。
---@param id string
---@return table?
function SPELLS:get(id)
	if not id then
		return nil
	end

	if self.registry[id] then
		return self.registry[id]
	end

	for _, path in ipairs(self.module_names) do
		if path:match("([^%.]+)$") == id then
			local ok, spell = pcall(require, path)

			if not ok then
				log.error("failed to load spell module %s: %s", path, tostring(spell))
				return nil
			end

			if type(spell) ~= "table" or not spell.id then
				log.error("invalid spell module %s: expected table with id", path)
				return nil
			end

			self.registry[id] = spell

			return spell
		end
	end

	return nil
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
	local list = {}

	for _, path in ipairs(self.module_names) do
		local id = path:match("([^%.]+)$")
		local spell = self.registry[id]

		if not spell then
			local ok, m = pcall(require, path)

			if ok then
				spell = m
				self.registry[id] = spell
			else
				log.error("failed to load spell module %s: %s", path, tostring(m))
			end
		end

		if spell and spell.id then
			list[#list + 1] = spell
		end
	end

	return list
end

--- 按照火雨援军的等级计算自定义法术的等级
---@return integer
function SPELLS:compute_level(store)
	local max_lvl = store.level.max_upgrade_level or UP.max_level or GS.max_upgrade_level or self.max_level
	max_lvl = math.min(max_lvl, self.max_level)

	return km.clamp(1, max_lvl, math.ceil(UP.levels.rain + UP.levels.reinforcements) / 2)
end

function SPELLS:register_common_templates(E)
	local tt = E:register_t_tmp("power_control_custom")
	E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

	E:register_t_tmp("user_power_3")
end

--- 在 E:precompile_hot() 之前调用：仅选中时注册本局法术模板
function SPELLS:register_templates(E)
	local spell = self:get_selected()

	if not spell then
		return
	end

	self:register_common_templates(E)
	spell.register_templates(E)
end

--- 在 E:precompile_hot() 之后调用
function SPELLS:apply(store)
	local spell = self:get_selected()

	if not spell then
		return
	end

	spell.apply(self:compute_level(store))

	local up = E:get_template("user_power_3")
	up.power_id = spell.id
end

return SPELLS
