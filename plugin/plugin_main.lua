-- chunkname: @./plugin/plugin_main.lua
local log = require("lib.klua.log"):new("plugin_main")
local FS = love.filesystem
local additional_paths = {"plugin/?.lua", "plugin/all/?.lua", "plugins/?.lua", "plugins/all/?.lua"}
local plugin_paths = require("plugin_paths")

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())

package.path = FS.getRequirePath()

plugin_paths.ensure_storage_ready()

require("plugin_globals")

local plugin_utils = require("plugin_utils")
local hook_utils = require("hook_utils")
local plugin_db = require("plugin_db")
local plugin_main = {
	loaded_plugins = {}
}

local function load_plugin_module(plugin_data)
	local entry_path = plugin_data.path .. "/" .. plugin_data.entry .. ".lua"
	if FS.getInfo(entry_path, "file") then
		local chunk, err = FS.load(entry_path)
		if not chunk then
			return nil, err
		end
		local ok, ret = pcall(chunk)
		if not ok then
			return nil, ret
		end
		return ret, nil
	end
	return nil, string.format("Entry file '%s' not found for plugin '%s'", entry_path, plugin_data.name)
end

function plugin_main:init(director)
	plugin_db:init()
	local plugin_main_config = plugin_paths.load_main_config()
	director:init(main.params)

	if plugin_main_config.enabled then
		self:after_init()
	end
end

--- 初始化所有已启用的插件
---@return nil
function plugin_main:after_init()
	-- 提前初始化，确保 errorhandler 归因时 PLUGIN_REGISTRY 不为 nil
	PLUGIN_REGISTRY = {}

	-- 正序增加插件路径
	-- for i = 1, plugin_db.plugins_count do
	-- local plugin_data = plugin_db.plugins_datas[i]

	-- 添加插件路径到package.path
	-- plugin_utils.add_path(plugin_data)
	-- end

	-- 倒序加载插件，确保加载模块顺序正确
	for i = plugin_db.plugins_count, 1, -1 do
		local plugin_data = plugin_db.plugins_datas[i]
		local plugin, load_err = load_plugin_module(plugin_data)

		if not plugin then
			log.error("Failed to load plugin '%s': %s", plugin_data.name, tostring(load_err))
		elseif type(plugin) ~= "table" then
			log.error(string.format("Must return table, plugin: %s", plugin_data.name))
		else
			table.insert(self.loaded_plugins, {plugin, plugin_data})
		end
	end

	local loaded_plugins_count = #self.loaded_plugins

	-- 正序初始化插件，确保高优先级覆盖低优先级
	for i = loaded_plugins_count, 1, -1 do
		local loaded_plugin, plugin_data = unpack(self.loaded_plugins[i])

		-- 初始化插件
		loaded_plugin:init(plugin_data)
		-- 打印插件加载信息
		print(plugin_db.get_debug_info(plugin_data.config))
	end

	-- 注册全局 plugin 表，供 errorhandler 归因使用（目录名 → config）
	PLUGIN_REGISTRY = {}
	for i = 1, plugin_db.plugins_count do
		local plugin_data = plugin_db.plugins_datas[i]
		PLUGIN_REGISTRY[plugin_data.name] = plugin_data.config
	end
end

return plugin_main
