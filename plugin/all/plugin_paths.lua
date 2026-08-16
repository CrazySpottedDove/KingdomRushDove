local FS = love.filesystem
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
