-- chunkname: @./mods/all/mod_utils.lua
local log = require("klua.log"):new("mod_utils")
local IS_KR5 = KR_GAME == "kr5"
local FS = love.filesystem
local hook_utils = require("hook_utils")

local A
if IS_KR5 then
    A = require("klove.animation_db")
else
    A = require("animation_db")
end

local mod_utils = {}

mod_utils.ignored_path = {
    "_assets"
}

mod_utils.not_mod_path = {
    "all"
}

mod_utils.ppref = ""

if not love.filesystem.isFused() then
    mod_utils.ppref = base_dir ~= work_dir and "" or "src/"
end

-- 元表：自动创建不存在表
mod_utils.auto_table_mt = {
    __index = function(table, key)
        local new = {}
        setmetatable(new, auto_table_mt)

        rawset(table, key, new)
        return new
    end
}

--- 获取指定路径下的所有子目录名
---
--- 返回一个包含子目录信息的表，每个元素包含name(子目录名)和path(完整路径)
---@param path string 要扫描的目录路径
---@param filter_fn function 过滤函数
---@return table 包含子目录信息的表
function mod_utils:get_subdirs(path, filter_fn)
    -- 获取目录下所有文件和子目录
    local files = FS.getDirectoryItems(path)

    local folders = {}

    -- 检查路径是否存在
    if not files then
        log.error("Path does not exist: %s", path)
        return {}

        -- 检查目录是否为空
    elseif #files == 0 then
        log.debug("No files found in path: %s", path)
    end

    -- 遍历目录下的所有项目
    for _, file in ipairs(files) do
        -- 构建完整文件路径
        local filepath = path .. "/" .. file

        -- 检查是否为目录
        if not filter_fn or filter_fn(file, filepath) and not table.contains(self.ignored_path, file) and FS.isDirectory(filepath) then
            -- 将目录信息添加到结果表中
            table.insert(folders, {
                name = file,    -- 目录名称
                path = filepath -- 目录完整路径
            })
        end
    end

    return folders
end

---将模组所有目录添加到 package.path 中，以便 require 能够找到模组文件
---@param mod_data table 模组数据，包含模组路径等信息
---@return nil
function mod_utils:add_path(mod_data)
    self.kui_insert = self.kui_insert or {}

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
    for _, dir in ipairs(self:get_subdirs(mod_data.path)) do
        if dir.name == "data" then
            for _, data_dir in ipairs(self:get_subdirs(dir.path)) do
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
    log.debug("Current package.path: %s", package.path)
end

--- 将表转化为字符串，返回的字符串无键值与大括号
---@param t table 表
---@return string 字符串
function mod_utils:table_tostring(t)
    if type(t) ~= "table" then
        return tostring(t)
    end

    local items = {}

    for k, v in pairs(t) do
        local value_str
        if type(v) == "string" then
            value_str = v
        elseif type(v) == "table" then
            value_str = "{" .. self:table_tostring(t) .. "}"
        else
            value_str = tostring(v)
        end

        table.insert(items, value_str)
    end

    return table.concat(items, ", ")
end

--- 获取模组调试信息
---@param config table 模组配置表
---@return string 格式化的模组信息字符串
function mod_utils:get_debug_info(config)
    local game_version = self:table_tostring(config.game_version)
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
---@return table 降序排序的表, table 升序排序的表
function mod_utils:check_get_available_mods(main_config)
    local mods_data = {}

    local mod_subdirs = self:get_subdirs("mods", function(name, path)
        return not table.contains(self.not_mod_path, name)
    end)

    for _, mod_data in ipairs(mod_subdirs) do
        -- 加载模组配置文件
        local config = require(self.ppref .. mod_data.path .. ".config")

        -- 检查是否是兼容游戏版本
        if type(config.game_version) == "string" and config.game_version == KR_GAME or type(config.game_version) == "table" and table.contains(config.game_version, KR_GAME) then
            -- 检查模组是否启用且路径存在
            if config.enabled and love.filesystem.exists(mod_data.path) then
                -- 添加优先级信息到模组数据中
                mod_data["priority"] = config.priority or 0
                table.insert(mods_data, mod_data)
            else
                log.error("%s is disabled!", mod_data.name)
            end
        else
            -- 不是兼容的游戏版本
            log.error("Mod '%s' is not compatible. Required game version: %s", config.name,
                self:table_tostring(config.game_version) or "unknown", config.name)
        end
    end

    local ascending = {}

    if #mods_data > 0 then
        -- 根据优先级对模组进行降序排序
        table.sort(mods_data, function(a, b)
            return a.priority > b.priority
        end)

        -- 根据优先级对模组进行升序排序
        for i = #mods_data, 1, -1 do
            table.insert(ascending, mods_data[i])
        end
    end

    return mods_data, ascending
end

---根据表修改指定动画
---
---若动画表中removed为真将会移除动画
---@param t table 表
---@return table 增加的动画, table 删除的动画
function mod_utils:a_db_reset(t)
    local added_a = {}
    local deleted_k = {}

    for k, v in pairs(t) do
        if v.removed then
            table.insert(deleted_k, k)

            goto skip_add
        end

        if v.layer_from and v.layer_to and v.layer_prefix then
            for i = v.layer_from, v.layer_to do
                local nk = string.gsub(k, "layerX", "layer" .. i)
                local nv = {
                    fps = v.fps,
                    group = v.group,
                    pre = v.pre,
                    post = v.post,
                    from = v.from,
                    to = v.to,
                    ranges = v.ranges,
                    frames = v.frames,
                    prefix = string.format(v.layer_prefix, i)
                }

                added_a[nk] = nv

                table.insert(deleted_k, k)
            end
        else
            added_a[k] = v
        end

        ::skip_add::
    end

    for k, v in pairs(added_a) do
        if IS_KR5 and not v.frames then
            A:expand_frames(v)
        end

        if not A.db[k] then
            A.db[k] = v
        else
            table.merge(A.db[k], v)
        end
    end

    for _, v in ipairs(deleted_k) do
        A.db[v] = nil
    end

    return added_a, deleted_k
end

--[[
以下是将一些模块与函数设为全局便于使用
--]]

require("klove.kui")
require("klua.table")
signal = require("hump.signal")
km = require("klua.macros")
SH = require("klove.shader_db")
V = require("klua.vector")
class = require("middleclass")
bit = require("bit")
band = bit.band
bor = bit.bor
bnot = bit.bnot
copy = table.deepclone
clone = table.clone

E = require("entity_db")
UPGR = require("upgrades")
storage = require("storage")
SU = require("script_utils")
U = require("utils")

if IS_KR5 then
    balance = require("data.balance.balance")
else
    require("gg_views_custom")
end

--- 帧转秒
--- @param v number 帧
--- @return number 秒
function fts(v)
    return v / FPS
end

--- 角度转弧度
--- @param d number 角度
--- @return number 弧度
function d2r(d)
    return d * math.pi / 180
end

--- 创建模板
--- @param name string 模板名
--- @param ref string 派生的模板
--- @return table 模板引用
function RT(name, ref)
    return E:register_t(name, ref)
end

--- 增加组件
--- @param name string 模板名
--- @param ... string 组件名
--- @return nil
function AC(name, ...)
    return E:add_comps(name, ...)
end

--- 深拷贝组件
--- @param c_name string 组件名
--- @return table
function CC(c_name)
    return E:clone_c(c_name)
end

--- 索引模板
--- @param name string 模板名
--- @return table
function T(name)
    return E:get_template(name)
end

--- 创建实体
--- @param t string 模板名
--- @return table 实体引用
function create_entity(t)
    return E:create_entity(t)
end

--- 将实体增加到插入队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
function queue_insert(store, e)
    return simulation:queue_insert_entity(e)
end

--- 将实体加入移除队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
function queue_remove(store, e)
    return simulation:queue_remove_entity(e)
end

--- 将伤害实体加入伤害队列
--- @param store table game.store
--- @param damage table 实体表
--- @return nil
function queue_damage(store, damage)
    return table.insert(store.damage_queue, damage)
end

return mod_utils
