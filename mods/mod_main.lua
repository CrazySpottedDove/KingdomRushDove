-- chunkname: @./mods/mod_main.lua
local log = require("klua.log"):new("mod_main")
local FS = love.filesystem
local additional_paths = {"mods/?.lua", "mods/all/?.lua"}

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())

package.path = FS.getRequirePath()

local mod_main_config_path = "mods/local/mod_main_config.lua"
local FU = require("all.file_utlis")
local f = io.open(mod_main_config_path, "r")
if not f then
	FU.ensure_parent_dir(mod_main_config_path)
	FU.write_lua(mod_main_config_path, dofile("mods/mod_main_config.lua"))
end

require("mod_globals")

local mod_hook = require("mod_hook")
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local mod_db = require("mod_db")
local mod_main_config = require("mods.local.mod_main_config")
local mod_main = {
	loaded_mods = {}
}

function mod_main:init(director)
	mod_db:init()

	if not mod_main_config.enabled then
		director:init(main.params)
		log.info("Mod module is disabled in config.lua")

		return false
	end

	self:front_init()
	director:init(main.params)
	self:after_init()

	return true
end

function mod_main:front_init()
	mod_hook:front_init()
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init()
	-- 正序增加模组路径
	for i = 1, mod_db.mods_count do
		local mod_data = mod_db.mods_datas[i]

		-- 添加模组路径到package.path
		mod_utils.add_path(mod_data)
		log.debug("Current package.path: %s", package.path)
	end

	-- 倒序加载模组，确保加载模块顺序正确
	for i = mod_db.mods_count, 1, -1 do
		local mod_data = mod_db.mods_datas[i]
		-- 加载模组
		local mod = require(mod_data.name)

		if type(mod) ~= "table" then
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
		log.error(mod_db.get_debug_info(mod_data.config))
	end

	mod_hook:after_init()
end

function mod_main:unload_mod(mod_name)
	for i, entry in ipairs(self.loaded_mods) do
		local mod, mod_data = unpack(entry)
		if mod_data.name == mod_name then
			-- 1. 调用模组自身的 unload（如果有）
			if mod.unload then
				mod:unload(mod_data)
			end
			-- 2. 从已加载列表移除
			table.remove(self.loaded_mods, i)
			-- 3. 从 mod_db 移除（自动停止资产 hooks 遍历）
			mod_db:remove_mod(mod_name)
			-- 4. 清除 package.loaded 缓存，允许重新加载
			package.loaded[mod_name] = nil
			log.info("Mod unloaded: %s", mod_name)
			return true
		end
	end
	log.error("Mod not found for unload: %s", mod_name)
	return false
end

return mod_main
