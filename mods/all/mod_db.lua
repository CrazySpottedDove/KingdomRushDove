-- chunkname: @./mods/all/mod_db.lua
local log = require("klua.log"):new("mod_db")
local mod_utils = require("mod_utils")
local mod_main_config = require("mod_main_config")
local FS = love.filesystem

local mod_db = {}

function mod_db:init()
    -- 初始化模组数据库
    self.mods_datas = self.check_get_available_mods()
    self.mods_count = #self.mods_datas
end

---将模组所有目录添加到 package.path 中，以便 require 能够找到模组文件
---@param mod_data table 模组数据，包含模组路径等信息
---@return nil
function mod_utils.add_path(mod_data)
    -- 自定义格式化函数，将路径与模组名结合
    local function f(str, ...)
        local path = mod_data.path .. "/" .. str
        return path:format(...)
    end

    -- 初始化附加路径表
    local additional_paths = {
        f("?.lua") -- 添加模组根目录的lua文件搜索路径
    }

    -- 遍历模组下的所有目录
    for _, dir in ipairs(mod_utils.get_subdirs(mod_data.path)) do
        if dir.name == "data" then
            for _, data_dir in ipairs(mod_utils.get_subdirs(dir.path)) do
                local kui_db

                -- 根据运行环境选择不同的KUI数据库模块
                if IS_KR5 then
                    kui_db = require("klove.kui_db")
                else
                    kui_db = require("kui_db")
                end

                -- 将KUI模板路径添加到KUI数据库路径表中（优先级最高）
                table.insert(kui_db.paths, 1, f("data/kui_templates"))

                log.debug("Added path in kui_db: %s", f("kui_templates", dir.name))
            end
        else
            -- 其他目录添加到require路径中
            table.insert(additional_paths, f("%s/?.lua", dir.name))
            log.debug("Added path in require: %s", f("%s/?.lua", dir.name))
        end
    end

    -- 更新FS和package的require路径
    FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())
    package.path = FS.getRequirePath()
end

--- 获取模组调试信息
---@param config table 模组配置表
---@return string 格式化的模组信息字符串
function mod_db.get_debug_info(config)
    local game_version = mod_utils.table_tostring(config.game_version)
    local o = "\n"

    local function f(...)
        o = o .. string.format(...)
    end

    -- 构建模组信息标题
    f("------------------- LOADED_MOD: %s -----------------------\n", config.name)
    f("%-9s: %-20s", "name", config.name or "unknown")          -- 模组名称
    f(" | %-13s: %s\n", "version", config.version or "unknown") -- 模组版本
    f("%-9s: %-20s", "by", config.by or "unknown")              -- 作者信息
    f(" | %-13s: %s\n", "game_version", game_version)           -- 兼容游戏版本
    f("%-9s: %-20d\n", "priority", config.priority)             -- 优先级
    f("%-9s: %s\n", "desc", config.desc or "unknown")           -- 模组描述
    f("%-9s: %s", "url", config.url or "unknown")               -- 模组发布地址

    return o
end

---检查并返回包含可用模组的表
---@return table 升序排序的表
function mod_db.check_get_available_mods()
    local mods_datas = {}

    local mod_subdirs = mod_utils.get_subdirs("mods", true, function(name, path)
        return not table.contains(mod_main_config.not_mod_path, name)
    end)

    for i = 1, #mod_subdirs do
        local mod_data = mod_subdirs[i]

        -- 加载模组配置文件
        local success, config = pcall(require, string.format("%s%s.config", mod_main_config.ppref, mod_data.path))
        if not success then
            log.error("Failed to load config.lua for mod: %s", mod_data.name)
            goto continue
        end

        if not config.enabled then
            log.error("%s is disabled", mod_data.name)
            goto continue
        end

        local game_version = config.game_version
        local game_version_type = type(game_version)

        if not (game_version_type == "string" and game_version == KR_GAME or game_version_type == "table" and table.contains(game_version, KR_GAME)) then
            log.error("Mod '%s' is not compatible. Required game version: %s", config.name,
                mod_utils.table_tostring(game_version) or "unknown", config.name)
            goto continue
        end

        mod_data.priority = config.priority or 0
        mod_data.config = config
        table.insert(mods_datas, mod_data)

        ::continue::
    end

    if #mods_datas > 0 then
        -- 根据优先级对模组进行升序排序
        table.sort(mods_datas, function(a, b)
            return a.priority < b.priority
        end)
    end

    return mods_datas
end

return mod_db
