-- chunkname: @./mods/all/mod_db.lua
local log = require("lib.klua.log"):new("mod_db")
local mod_utils = require("mod_utils")
-- local FS = love.filesystem
local mod_paths = require("mod_paths")
local mod_db = {}

function mod_db:init()
	-- 初始化模组数据库
	self.mods_datas = self.check_get_available_mods()
	self.mods_count = #self.mods_datas
end

--- 获取模组调试信息
---@param config table 模组配置表
---@return string 格式化的模组信息字符串
function mod_db.get_debug_info(config)
	local o = "\n"

	local function f(...)
		o = o .. string.format(...)
	end

	-- 构建模组信息标题
	f("------------------- LOADED_MOD: %s -----------------------\n", config.name)
	f("%-9s: %-20s", "name", config.name or "unknown") -- 模组名称
	f(" | %-13s: %s\n", "version", config.version or "unknown") -- 模组版本
	f("%-9s: %-20s", "by", config.by or "unknown") -- 作者信息
	f(" | %-13s: %s\n", "priority", config.priority or 0) -- 优先级
	f("%-9s: %s\n", "desc", config.desc or "unknown") -- 模组描述
	f("%-9s: %s", "entry", config.entry or "unknown") -- 模组发布地址

	return o
end

---检查并返回包含可用模组的表
---@return table 升序排序的表
function mod_db.check_get_available_mods()
	local mods_datas = {}
	local mod_subdirs = mod_utils.get_subdirs(mod_paths.LOCAL_MODS_DIR)

	for i = 1, #mod_subdirs do
		local mod_data = mod_subdirs[i]
		-- 加载模组配置文件
		local config, load_err = mod_paths.load_lua_table(mod_data.path .. "/config.lua")
		if not config then
			log.error("Failed to load config.lua for mod: %s", mod_data.name)
			log.error("Reason: %s", tostring(load_err))

			goto continue
		end

		if not config.enabled then
			goto continue
		end

		mod_data.priority = config.priority or 0
		mod_data.entry = config.entry or mod_data.name
		mod_data.config = config

		table.insert(mods_datas, mod_data)

		::continue::
	end

	if #mods_datas > 0 then
		-- 根据优先级对模组进行升序排序
		table.sort(mods_datas, function(a, b)
			return a.priority < b.priority
		end)
	end

	return mods_datas
end

return mod_db
