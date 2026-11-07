-- 世代注册表：generation 的地图、关卡、旗帜、升级与资源全部由各自模块声明。
-- 插件在初始化时调用 GENS:register(module) 即可加入切换菜单。
local Registry = require("registry")
local LEGACY = require("generations.legacy")

local GENS = Registry.new({
	module_names = {"kr1.generations.kr1.init", "kr1.generations.kr2.init", "kr1.generations.kr3.init", "kr1.generations.kr5.init", "kr1.generations.kr6.init", "kr1.generations.custom.init"},
	sort_fn = function(a, b)
		return a.order < b.order
	end
})

--- 所有世代星数上限总和（读档界面用）。
---@return number
function GENS:total_max_stars()
	local total = 0

	for _, module in ipairs(self.items) do
		if module.kind == "standard" then
			total = total + module.levels.max_stars
		end
	end

	return total
end

--- 按 (name, local_idx) 生成关卡文件名。
---@param name string
---@param local_idx number
---@return string
function GENS:level_name(name, local_idx)
	return string.format("level_%s_%03d", name, local_idx)
end

--- 关卡标题 i18n key。
---@param name string
---@param local_idx number
---@return string
function GENS:level_title_key(name, local_idx)
	return string.format("LEVEL_%s_%03d_TITLE", name:upper(), local_idx)
end

--- 关卡历史 i18n key。
---@param name string
---@param local_idx number
---@return string
function GENS:level_history_key(name, local_idx)
	return string.format("LEVEL_%s_%03d_HISTORY", name:upper(), local_idx)
end

--- 关卡缩略图 sprite 名。
---@param name string
---@param local_idx number
---@return string
function GENS:level_thumb_key(name, local_idx)
	return string.format("stage_thumbs_%s_%04d", name, local_idx)
end

--- 战斗音乐 sound id。
---@param name string
---@param local_idx number
---@return string
function GENS:battle_music(name, local_idx)
	local module = self:get(name)
	local fn = module and module.map and module.map.battle_music

	if fn then
		return fn(local_idx)
	end

	local global_idx = LEGACY.to_global(name, local_idx)

	return global_idx and string.format("MusicBattle_%02d", global_idx) or nil
end

--- 准备音乐 sound id。
---@param name string
---@param local_idx number
---@return string
function GENS:prep_music(name, local_idx)
	local module = self:get(name)
	local fn = module and module.map and module.map.prep_music

	if fn then
		return fn(local_idx)
	end

	local global_idx = LEGACY.to_global(name, local_idx)

	return global_idx and string.format("MusicBattlePrep_%02d", global_idx) or nil
end

--- 判定 local 关卡是否在当前世代有效。
---@param name string
---@param local_idx number
---@return boolean
function GENS:is_level_valid(name, local_idx)
	local module = self:get(name)

	if not module or module.kind ~= "standard" then
		return false
	end

	return local_idx >= 1 and local_idx <= module.levels.count
end

return GENS
