-- chunkname: @./mods/mod_main.lua

local log = require("klua.log"):new("mod_main")
local IS_KR5 = KR_GAME == "kr5"
local FS = love.filesystem

local additional_paths = {
    "mods/?.lua",
    "mods/all/?.lua"
}

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())
package.path = FS.getRequirePath()

local mod_hook = require("mod_hook")
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")

local mod_main = {}

function mod_main:init(director)
    local config = require("config")

    local descending_mods_data, ascending_mods_data = mod_utils:check_get_available_mods(config)
    self.desc_mods_data = descending_mods_data
    self.asc_mods_data = ascending_mods_data
    mod_hook.desc_mods_data = descending_mods_data
    mod_hook.asc_mods_data = ascending_mods_data

    if config.enabled then
        self:front_init()

        director:init(main.params)

        self:after_init()
    else
        director:init(main.params)
    end
end

function mod_main:front_init(mods_data)
    mod_hook:front_init()
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init()
    -- 正序加载所有模组，确保加载模块顺序正确
    for _, mod_data in ipairs(self.desc_mods_data) do
        -- 添加模组路径到package.path
        mod_utils:add_path(mod_data)

        -- 加载模组
        mod_data.module = require(mod_data.name)

        if type(mod_data.module) ~= "table" then
            error(string.format("Must return table, mod: %s", mod_data.name))
        end

        mod_data.module.config = require(mod_utils.ppref .. mod_data.path .. ".config")
    end

    -- 倒序初始化模组，确保高优先级覆盖低优先级
    for _, mod_data in ipairs(self.asc_mods_data) do
        -- 初始化模组
        mod_data.module:init()

        -- 打印模组加载信息
        log.error(mod_utils:get_debug_info(mod_data.module.config))
    end

    mod_hook:after_init()
end

return mod_main
