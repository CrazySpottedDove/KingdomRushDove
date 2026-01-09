-- chunkname: @./mods/mod_main.lua
local log = require("klua.log"):new("mod_main")
local FS = love.filesystem
local additional_paths = {"mods/?.lua", "mods/all/?.lua"}

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())

package.path = FS.getRequirePath()

require("mod_globals")

local mod_hook = require("mod_hook")
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local mod_db = require("mod_db")
local mod_main_config = require("mod_main_config")
local mod_main = {}

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
	local loaded_mods = {}

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
			table.insert(loaded_mods, {mod, mod_data})
		end
	end

	local loaded_mods_count = #loaded_mods

	-- 正序初始化模组，确保高优先级覆盖低优先级
	for i = loaded_mods_count, 1, -1 do
		local loaded_mod, mod_data = unpack(loaded_mods[i])

		-- 初始化模组
		loaded_mod:init(mod_data)
		-- 打印模组加载信息
		log.error(mod_db.get_debug_info(mod_data.config))
	end

	mod_hook:after_init()
end

return mod_main
