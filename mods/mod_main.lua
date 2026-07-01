-- chunkname: @./mods/mod_main.lua
local log = require("lib.klua.log"):new("mod_main")
local FS = love.filesystem
local additional_paths = {"mods/?.lua", "mods/all/?.lua", "plugins/?.lua", "plugins/all/?.lua"}
local mod_paths = require("mod_paths")

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())

package.path = FS.getRequirePath()

mod_paths.ensure_storage_ready()

require("mod_globals")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local mod_db = require("mod_db")
local mod_main = {
	loaded_mods = {}
}

local function load_mod_module(mod_data)
	local candidates = {}
	local entry = mod_data.entry or mod_data.name
	candidates[#candidates + 1] = mod_data.path .. "/" .. entry .. ".lua"
	candidates[#candidates + 1] = mod_data.path .. "/init.lua"

	for _, file_path in ipairs(candidates) do
		if FS.getInfo(file_path, "file") then
			local chunk, err = FS.load(file_path)
			if not chunk then
				return nil, err
			end
			local ok, ret = pcall(chunk)
			if not ok then
				return nil, ret
			end
			return ret, nil
		end
	end

	local ok, ret = pcall(require, mod_data.name)
	if ok then
		return ret, nil
	end
	return nil, ret
end

function mod_main:init(director)
	mod_db:init()
	local mod_main_config = mod_paths.load_main_config()

	if not mod_main_config.enabled then
		director:init(main.params)
		log.info("Mod module is disabled in config.lua")

		return false
	end

	-- self:front_init()
	director:init(main.params)
	self:after_init()

	return true
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init()
	-- 提前初始化，确保 errorhandler 归因时 MOD_REGISTRY 不为 nil
	MOD_REGISTRY = {}

	-- 正序增加模组路径
	-- for i = 1, mod_db.mods_count do
	-- local mod_data = mod_db.mods_datas[i]

	-- 添加模组路径到package.path
	-- mod_utils.add_path(mod_data)
	-- end

	-- 倒序加载模组，确保加载模块顺序正确
	for i = mod_db.mods_count, 1, -1 do
		local mod_data = mod_db.mods_datas[i]
		local mod, load_err = load_mod_module(mod_data)

		if not mod then
			log.error("Failed to load mod '%s': %s", mod_data.name, tostring(load_err))
		elseif type(mod) ~= "table" then
			log.error(string.format("Must return table, mod: %s", mod_data.name))
		else
			table.insert(self.loaded_mods, {mod, mod_data})
		end
	end

	local loaded_mods_count = #self.loaded_mods

	-- 正序初始化模组，确保高优先级覆盖低优先级
	for i = loaded_mods_count, 1, -1 do
		local loaded_mod, mod_data = unpack(self.loaded_mods[i])

		-- 初始化模组
		loaded_mod:init(mod_data)
		-- 打印模组加载信息
		print(mod_db.get_debug_info(mod_data.config))
	end

	-- 注册全局 mod 表，供 errorhandler 归因使用（目录名 → config）
	MOD_REGISTRY = {}
	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]
		MOD_REGISTRY[mod_data.name] = mod_data.config
	end
end

return mod_main
