-- chunkname: @./plugin/all/plugin_db.lua
local log = require("lib.klua.log"):new("plugin_db")
local plugin_utils = require("plugin_utils")
-- local FS = love.filesystem
local plugin_paths = require("plugin_paths")
local plugin_db = {}

function plugin_db:init()
	-- 初始化插件数据库
	self.plugins_datas = self.check_get_available_plugins()
	self.plugins_count = #self.plugins_datas
end

--- 获取插件调试信息
---@param config table 插件配置表
---@return string 格式化的插件信息字符串
function plugin_db.get_debug_info(config)
	local o = "\n"

	local function f(...)
		o = o .. string.format(...)
	end

	-- 构建插件信息标题
	f("------------------- LOADED_MOD: %s -----------------------\n", config.name)
	f("%-9s: %-20s", "name", config.name or "unknown") -- 插件名称
	f(" | %-13s: %s\n", "version", config.version or "unknown") -- 插件版本
	f("%-9s: %-20s", "by", config.by or "unknown") -- 作者信息
	f(" | %-13s: %s\n", "priority", config.priority or 0) -- 优先级
	f("%-9s: %s\n", "desc", config.desc or "unknown") -- 插件描述
	f("%-9s: %s", "entry", config.entry or "unknown") -- 插件发布地址

	return o
end

---检查并返回包含可用插件的表
---@return table 升序排序的表
function plugin_db.check_get_available_plugins()
	local plugins_datas = {}
	local plugin_subdirs = plugin_utils.get_subdirs(plugin_paths.LOCAL_PLUGINS_DIR)

	for i = 1, #plugin_subdirs do
		local plugin_data = plugin_subdirs[i]
		-- 加载插件配置文件
		local config, load_err = plugin_paths.load_lua_table(plugin_data.path .. "/config.lua")
		if not config then
			log.error("Failed to load config.lua for plugin: %s", plugin_data.name)
			log.error("Reason: %s", tostring(load_err))

			goto continue
		end

		if not config.enabled then
			goto continue
		end

		plugin_data.priority = config.priority or 0
		plugin_data.entry = config.entry
		plugin_data.config = config

		table.insert(plugins_datas, plugin_data)

		::continue::
	end

	if #plugins_datas > 0 then
		-- 根据优先级对插件进行升序排序
		table.sort(plugins_datas, function(a, b)
			return a.priority < b.priority
		end)
	end

	return plugins_datas
end

return plugin_db
