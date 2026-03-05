IS_KR5 = KR_GAME == "kr5"
IS_LOVE_11 = love.getVersion() >= 11

local FS = love.filesystem

if IS_LOVE_11 then
	function FS.isDirectory(path)
		local info = FS.getInfo(path, "directory")

		return info ~= nil and info.type == "directory"
	end

	function FS.isFile(path)
		local info = FS.getInfo(path, "file")

		return info ~= nil and info.type == "file"
	end

	function FS.exists(path)
		return FS.getInfo(path) ~= nil
	end
end

require("klove.kui")
require("klua.table")

signal = require("lib.hump.signal")
km = require("klua.macros")
SH = require("klove.shader_db")
V = require("lib.klua.vector")
class = require("middleclass")
bit = require("bit")
band = bit.band
bor = bit.bor
bnot = bit.bnot
copy = table.deepclone
clone = table.clone
E = require("entity_db")
UPGR = require("upgrades")
storage = require("all.storage")
SU = require("script_utils")
U = require("utils")

if not IS_KR5 then
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
