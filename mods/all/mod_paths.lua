local FS = love.filesystem
local persistence = require("lib.klua.persistence")
local mod_paths = {}

mod_paths.LOCAL_MODS_DIR = "plugins"
mod_paths.MAIN_CONFIG_PATH = mod_paths.LOCAL_MODS_DIR .. "/mod_main_config.lua"
mod_paths.DEFAULT_MAIN_CONFIG_MODULE = "mod_main_config"

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

function mod_paths.ensure_storage_ready()
	ensure_directory("plugins")
	ensure_directory(mod_paths.LOCAL_MODS_DIR)

	if not FS.getInfo(mod_paths.MAIN_CONFIG_PATH, "file") then
		local ok, template = pcall(require, mod_paths.DEFAULT_MAIN_CONFIG_MODULE)
		if ok and type(template) == "table" then
			write_lua_table(mod_paths.MAIN_CONFIG_PATH, template)
		end
	end
end

function mod_paths.load_lua_table(path)
	return load_lua_table(path)
end

function mod_paths.write_lua_table(path, tbl)
	return write_lua_table(path, tbl)
end

function mod_paths.load_main_config()
	local cfg = load_lua_table(mod_paths.MAIN_CONFIG_PATH)
	if cfg then
		return cfg
	end
	local ok, template = pcall(require, mod_paths.DEFAULT_MAIN_CONFIG_MODULE)
	if ok and type(template) == "table" then
		return template
	end
	return {
		enabled = false
	}
end

return mod_paths
