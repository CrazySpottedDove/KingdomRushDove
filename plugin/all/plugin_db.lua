-- chunkname: @./plugin/all/plugin_db.lua
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
	f("%-9s: %-20s", "name", config.name) -- 插件名称
	f(" | %-13s: %s\n", "version", config.version) -- 插件版本
	f("%-9s: %-20s", "by", config.by) -- 作者信息
	f(" | %-13s: %s\n", "priority", config.priority) -- 优先级
	f("%-9s: %s\n", "desc", config.desc) -- 插件描述
	f("%-9s: %s", "entry", config.entry) -- 插件发布地址

	return o
end

---检查并返回包含可用插件的表
---@return table 记录结构见 plugin_paths.load_plugin（{config, has_plugin_config}），按 config.priority 升序
function plugin_db.check_get_available_plugins()
	local plugins_datas = {}

	for _, entry in ipairs(plugin_paths.list_plugin_entries()) do
		local plugin_data = plugin_paths.load_plugin(entry)
		-- 只有启用的插件会进入运行时列表
		if plugin_data and plugin_data.config.enabled then
			table.insert(plugins_datas, plugin_data)
		end
	end

	if #plugins_datas > 1 then
		-- 根据优先级对插件进行升序排序
		table.sort(plugins_datas, function(a, b)
			return a.config.priority < b.config.priority
		end)
	end

	return plugins_datas
end

return plugin_db
