local FS = love.filesystem
local log = require("lib.klua.log"):new("plugin_paths")
local persistence = require("lib.klua.persistence")
local plugin_paths = {}

plugin_paths.LOCAL_PLUGINS_DIR = "plugins"
plugin_paths.MAIN_CONFIG_PATH = plugin_paths.LOCAL_PLUGINS_DIR .. "/plugin_main_config.lua"
plugin_paths.DEFAULT_MAIN_CONFIG_MODULE = "plugin_main_config"

local function ensure_directory(path)
	if FS.getInfo(path, "directory") then
		return true
	end
	return FS.createDirectory(path)
end

local function load_lua_table(path)
	local chunk, err = FS.load(path)
	if not chunk then
		return nil, err
	end
	local ok, result = pcall(chunk)
	if not ok or type(result) ~= "table" then
		return nil, result
	end
	return result, nil
end

local function write_lua_table(path, tbl)
	local content = persistence.serialize_to_string(tbl)
	return FS.write(path, content)
end

-- ─────────────────────────────────────────────
-- 插件的位置与记录
--
-- 插件只由 entry（config.lua 的 entry）标识，位置全部由 entry 推导：
--   目录       plugins/<entry>
--   元数据     plugins/<entry>/config.lua
--   入口文件   plugins/<entry>/<entry>.lua
--   配置文件   plugins/<entry>/<entry>_config.lua
-- 因此目录名必须等于 entry（插件自身的 require("${entry}.x") 也依赖这一点）。
--
-- 插件记录（管理器与运行时共用同一种结构，只有两个字段）：
--   config             config.lua 返回的表（entry/name/version/enabled/priority/... 都在这里）
--   has_plugin_config  是否存在 <entry>_config.lua（插件是否带玩家可调配置）
-- 位置、路径、优先级等一律不落库，用上面的函数或 config.priority 现算。
-- ─────────────────────────────────────────────

--- 插件目录：plugins/<entry>
function plugin_paths.plugin_dir(entry)
	return plugin_paths.LOCAL_PLUGINS_DIR .. "/" .. entry
end

--- 插件元数据文件：plugins/<entry>/config.lua
function plugin_paths.metadata_path(entry)
	return plugin_paths.plugin_dir(entry) .. "/config.lua"
end

--- 插件入口文件：plugins/<entry>/<entry>.lua
function plugin_paths.entry_path(entry)
	return plugin_paths.plugin_dir(entry) .. "/" .. entry .. ".lua"
end

--- 插件配置文件（玩家可调参数）：plugins/<entry>/<entry>_config.lua
function plugin_paths.plugin_config_path(entry)
	return plugin_paths.plugin_dir(entry) .. "/" .. entry .. "_config.lua"
end

--- 插件是否存在玩家可调配置文件
---@param entry string
---@return boolean
function plugin_paths.has_plugin_config(entry)
	return FS.getInfo(plugin_paths.plugin_config_path(entry), "file") ~= nil
end

--- 读取单个插件，返回插件记录。
---@param entry string 插件 entry
---@return table|nil { config = table, has_plugin_config = boolean }
function plugin_paths.load_plugin(entry)
	local config = load_lua_table(plugin_paths.metadata_path(entry))
	if not config then
		return nil
	end
	return {
		config = config,
		has_plugin_config = plugin_paths.has_plugin_config(entry)
	}
end

--- 扫描 plugins/ 下的插件目录，返回 entry 列表。
--- 没有 config.lua 的目录按「不是插件」跳过；缺 entry、或目录名与 entry 不一致时直接报错
--- （位置由 entry 推导，两边不一致就无法定位）。
---@return table<string>
function plugin_paths.list_plugin_entries()
	local entries = {}
	local items = FS.getDirectoryItems(plugin_paths.LOCAL_PLUGINS_DIR) or {}
	for _, dir_name in ipairs(items) do
		local dir_path = plugin_paths.LOCAL_PLUGINS_DIR .. "/" .. dir_name
		if FS.getInfo(dir_path, "directory") then
			local config = load_lua_table(dir_path .. "/config.lua")
			if config then
				local entry = config.entry
				if type(entry) ~= "string" or entry == "" then
					error(string.format("插件目录 %s 的 config.lua 缺少 entry；entry 是插件的唯一标识", dir_name))
				end
				if entry ~= dir_name then
					error(string.format("插件目录名（%s）与 config.lua 的 entry（%s）不一致：目录名必须等于 entry", dir_name, entry))
				end
				entries[#entries + 1] = entry
			else
				log.error("跳过不是插件的目录（缺少可读取的 config.lua）：%s", dir_name)
			end
		end
	end
	return entries
end

function plugin_paths.ensure_storage_ready()
	ensure_directory("plugins")
	ensure_directory(plugin_paths.LOCAL_PLUGINS_DIR)

	if not FS.getInfo(plugin_paths.MAIN_CONFIG_PATH, "file") then
		local ok, template = pcall(require, plugin_paths.DEFAULT_MAIN_CONFIG_MODULE)
		if ok and type(template) == "table" then
			write_lua_table(plugin_paths.MAIN_CONFIG_PATH, template)
		end
	end
end

function plugin_paths.load_lua_table(path)
	return load_lua_table(path)
end

function plugin_paths.write_lua_table(path, tbl)
	return write_lua_table(path, tbl)
end

function plugin_paths.load_main_config()
	local cfg = load_lua_table(plugin_paths.MAIN_CONFIG_PATH)
	if cfg then
		return cfg
	end
	local ok, template = pcall(require, plugin_paths.DEFAULT_MAIN_CONFIG_MODULE)
	if ok and type(template) == "table" then
		return template
	end
	return {
		enabled = false
	}
end

return plugin_paths
