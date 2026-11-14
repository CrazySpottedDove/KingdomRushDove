-- 世代注册表：generation 的地图、关卡、旗帜、升级与资源全部由各自模块声明。
-- 插件在初始化时调用 GENS:register(module) 即可加入切换菜单。
local Registry = require("registry")
local LEGACY = require("generations.legacy")
local common = require("kr1.generations.common")

local GENS = Registry.new({
	module_names = {"kr1.generations.kr1.init", "kr1.generations.kr2.init", "kr1.generations.kr3.init", "kr1.generations.kr5.init", "kr1.generations.kr6.init", "kr1.generations.custom.init"},
	sort_fn = function(a, b)
		local ao = a.order or math.huge
		local bo = b.order or math.huge

		if ao == bo then
			return (a.name or "") < (b.name or "")
		end

		return ao < bo
	end
})

GENS.encyclopedia_entries = {}
GENS.encyclopedia_map = {}
GENS.notifications = {}

local function add_encyclopedia_entries(entries)
	for _, entry in ipairs(entries) do
		GENS.encyclopedia_entries[#GENS.encyclopedia_entries + 1] = entry
		GENS.encyclopedia_map[entry.template_name] = entry
	end
end

local function remove_encyclopedia_entries(entries)
	for _, entry in ipairs(entries) do
		GENS.encyclopedia_map[entry.template_name] = nil

		for i = #GENS.encyclopedia_entries, 1, -1 do
			if GENS.encyclopedia_entries[i] == entry then
				table.remove(GENS.encyclopedia_entries, i)

				break
			end
		end
	end
end

local function add_notifications(notifications)
	for id, notification in pairs(notifications) do
		GENS.notifications[id] = notification
	end
end

-- 初始化
add_notifications(require("kr1.data.notifications"))

local ORDER_STEP = 10

--- 注册时补全展示顺序：未声明 order 的模块按注册顺序递增。
--- 插件若要插到本体世代之间，显式传 order 即可。
function GENS:add(module)
	local existing = self.by_id[module.name]

	if module.levels and module.levels.ranges then
		local meta = common.level_meta(module.levels.ranges)

		module.levels.count = meta.count
		module.levels.main_campaign_last = meta.main_campaign_last
		module.levels.max_stars = meta.max_stars
	end

	if module.order == nil then
		if existing and existing.order ~= nil then
			module.order = existing.order
		else
			self._next_order = (self._next_order or 0) + ORDER_STEP
			module.order = self._next_order
		end
	elseif self._next_order == nil or module.order > self._next_order then
		self._next_order = module.order
	end

	add_encyclopedia_entries(module.encyclopedia_entries)
	add_notifications(module.notifications)

	return Registry.add(self, module)
end

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

--- 按 (name, local_idx) 生成全局唯一关卡逻辑 key。
---@param name string
---@param local_idx number
---@return string
function GENS:level_name(name, local_idx)
	return string.format("level_%s_%03d", name, local_idx)
end

--- 按 (name, local_idx) 生成 generation 内的物理文件名。
---@param name string
---@param local_idx number
---@return string
function GENS:level_file(name, local_idx)
	return string.format("level_%03d", local_idx)
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
