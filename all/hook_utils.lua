local hook_utils = {}

---替换原函数
---@param obj table 目标
---@param fn_name str 函数名
---@param handler function 替换的函数
---@return nil
function hook_utils.HOOK(obj, fn_name, handler)
    if not obj._hook_origin_fn then -- 若没有 hook 给定的函数
        obj._hook_origin_fn = {}
    elseif obj._hook_origin_fn[fn_name] then    -- 若已 hook 给定的函数直接返回
        return
    end

    local hook_fn = obj[fn_name]    -- 存储原函数

    obj._hook_origin_fn[fn_name] = hook_fn  -- 标记已 hook

    obj[fn_name] = function(...)
        return handler(hook_fn, ...)    -- 替换原函数
    end
end

---移除 hook
---@param obj table 目标
---@param fn_name str 函数名
---@return nil
function hook_utils.UNHOOK(obj, fn_name)
    if not obj._hook_origin_fn then -- 若对应函数未 hook 直接返回
        return
    end

    local hook_fn = obj._hook_origin_fn[fn_name]    -- 存储 hook 后的函数

    if not hook_fn then
        return
    end

    obj[fn_name] = hook_fn  -- 还原
    obj._hook_origin_fn[fn_name] = nil  -- 移除标记
end

--[[
以下是将一些模块与函数设为全局便于使用
--]]

require("main_globals")
require("gg_views_custom")
require("constants")
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
epsilon = 1e-09

E = require("entity_db")
UPGR = require("upgrades")
storage = require("storage")
SU = require("script_utils")
U = require("utils")

if KR_GAME == "kr5" then
    balance = require("balance/balance")
end

---帧转秒
---@param v number 帧
---@return number 秒
function fts(v)
    return v / FPS
end

---角度转弧度
---@param d number 角度
---@return number 弧度
function d2r(d)
    return d * math.pi / 180
end

---创建模板
---@param name string 模板名
---@param ref string 派生的模板
---@return table
---@see E:register_t
function RT(name, ref)
    return E:register_t(name, ref)
end

---增加组件
---@param name string 模板名
---@param ... string 组件名
---@return nil
---@see E:add_comps
function AC(name, ...)
    return E:add_comps(name, ...)
end

---深拷贝组件
---@param c_name string 组件名
---@return table
---@see E:clone_c
function CC(c_name)
    return E:clone_c(c_name)
end

---索引模板
---@param name string 模板名
---@return table
---@see E:get_template
function T(name)
    return E:get_template(name)
end

---创建实体
---@param t string 模板名
---@return table
---@see E:create_entity
function create_entity(t)
    return E:create_entity(t)
end

---将实体放到插入队列
---@param store table game.store
---@param e table 实体表
---@return nil
---@see simulation:queue_insert_entity
function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end

---将实体放到移除队列
---@param store table game.store
---@param e table 实体表
---@return nil
---@see simulation:queue_remove_entity
function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

---将伤害实体放到伤害队列
---@param store table game.store
---@param damage table 实体表
---@return nil
function queue_damage(store, damage)
    table.insert(store.damage_queue, damage)
end

return hook_utils