-- chunkname: @./dove_modules/gui/plugin_manager_packs.lua
-- 本地分组（Group）数据模块：packs/ 目录读写 / 枚举 / 成员序 / 聚合推导。
-- 纯数据与逻辑，不 require plugin_main/plugin_db，不触碰插件运行时；
-- 只依赖 love.filesystem 与插件路径小工具（plugin_paths）。
--
-- v3 简化（设计稿 PACK_DESIGN.md v3）：
--   * packs/<entry>/pack.lua 一律视为「本地分组」（玩家自建的命名插件集合），
--     商店整合包安装/同步不再写任何本地包记录，因此 packs/ 下不再有“已装商店包”。
--   * 历史遗留的 pack.lua（含 by~=""、installed、readme 等 v2 字段）同样按本地分组
--     对待：可编辑成员、删除清理；多余旧字段被忽略（编辑器保存时按新 schema 重建）。
--
-- pack.lua schema（本地分组，v4 精简）：
--   return {
--     entry   = "group_xxx",
--     name    = "分组名",
--     members = { "plugin_a", "plugin_b", ... }, -- 有序数组：成员唯一事实源
--   }
-- 读取兼容旧格式：members 字典 + members_order、by/desc/version/state 等 v2/v3 多余字段会被
-- 忽略；编辑器保存时一律按上述精简 schema 重写（旧文件若有非空 desc，编辑后仍保留展示）。
local FS = love.filesystem
local plugin_paths = require("plugin_paths")

local packs = {}

packs.PACKS_DIR = "packs"

--- 确保 packs 目录存在（与 plugins 平级，均在 love.filesystem 存档根下）
function packs.ensure_dir()
	if FS.getInfo(packs.PACKS_DIR, "directory") then
		return true
	end
	return FS.createDirectory(packs.PACKS_DIR)
end

--- 由 entry 推导分组目录路径；非法 entry 返回 nil（防路径穿越）
function packs.path_of(entry)
	local e = tostring(entry or "")
	if e == "" then
		return nil
	end
	if e:find("/", 1, true) or e:find("\\", 1, true) then
		return nil
	end
	if e == "." or e == ".." then
		return nil
	end
	return packs.PACKS_DIR .. "/" .. e
end

local function pack_file_of(entry)
	local dir = packs.path_of(entry)
	if not dir then
		return nil
	end
	return dir .. "/pack.lua"
end

local function read_pack_table(path)
	local cfg = plugin_paths.load_lua_table(path)
	if type(cfg) ~= "table" then
		return nil
	end
	return cfg
end

--- 递归删除目录（love.filesystem 无内置 rmtree）
local function remove_dir_recursive(path)
	local info = FS.getInfo(path)
	if not info then
		return true
	end
	if info.type == "file" then
		return FS.remove(path)
	end
	local items = FS.getDirectoryItems(path) or {}
	for _, name in ipairs(items) do
		remove_dir_recursive(path .. "/" .. name)
	end
	return FS.remove(path)
end

--- 枚举本地全部分组（目录形式 packs/<entry>/pack.lua）。
--- 返回 { {entry=, path=目录, cfg=}, ... }，cfg=nil 表示 pack.lua 损坏/缺失（仍保留以便删除清理）。
function packs.list()
	packs.ensure_dir()
	local items = FS.getDirectoryItems(packs.PACKS_DIR) or {}
	table.sort(items)
	local out = {}
	for _, name in ipairs(items) do
		if FS.getInfo(packs.PACKS_DIR .. "/" .. name, "directory") then
			local dir_path = packs.PACKS_DIR .. "/" .. name
			local cfg = read_pack_table(dir_path .. "/pack.lua")
			out[#out + 1] = {
				entry = name,
				path = dir_path,
				cfg = cfg
			}
		end
	end
	return out
end

--- 读取单个分组配置（损坏返回 nil）
function packs.load(entry)
	local path = pack_file_of(entry)
	if not path then
		return nil
	end
	return read_pack_table(path)
end

--- 写回单个分组文件（自动建 packs/<entry>/ 目录）
function packs.save(entry, cfg)
	local dir = packs.path_of(entry)
	if not dir or type(cfg) ~= "table" then
		return false
	end
	packs.ensure_dir()
	if not FS.getInfo(dir, "directory") then
		FS.createDirectory(dir)
	end
	return plugin_paths.write_lua_table(dir .. "/pack.lua", cfg)
end

--- 删除整个分组目录（不触碰任何插件目录）
function packs.remove(entry)
	local dir = packs.path_of(entry)
	if not dir then
		return false
	end
	return remove_dir_recursive(dir)
end

--- 返回成员的有序 entry 数组。
--- 新格式：members 为有序数组（单一事实源）；兼容旧格式：members 字典（值占位）+
--- 可选 members_order，缺失部分按 entry 字典序兜底。
function packs.entries_of(cfg)
	local members = (type(cfg) == "table") and cfg.members or nil
	if type(members) ~= "table" then
		return {}
	end
	if members[1] ~= nil then
		-- 新格式：有序数组
		local out = {}
		for i = 1, #members do
			local e = tostring(members[i])
			if e ~= "" then
				out[#out + 1] = e
			end
		end
		return out
	end
	-- 旧格式：字典 + members_order
	local seen = {}
	local out = {}
	if type(cfg.members_order) == "table" then
		for _, m in ipairs(cfg.members_order) do
			local e = tostring(m)
			if not seen[e] and members[e] ~= nil then
				seen[e] = true
				out[#out + 1] = e
			end
		end
	end
	local rest = {}
	for e in pairs(members) do
		if not seen[e] then
			rest[#rest + 1] = tostring(e)
		end
	end
	table.sort(rest)
	for _, e in ipairs(rest) do
		out[#out + 1] = e
	end
	return out
end

--- 聚合推导（成员 enabled 聚合，纯展示）：
--- @param cfg table 分组配置
--- @param plugin_enabled_fn function(entry) -> boolean|nil  成员插件的 enabled 状态；
---        返回 nil 表示该成员目录/插件不存在（缺失成员），true/false 为存在且启用/停用
--- @return table {state="on"|"off"|"partial", total, exist_count, on_count, missing_entries={...}}
function packs.aggregate(cfg, plugin_enabled_fn)
	local members = packs.entries_of(cfg)
	local total = #members
	local exist_count = 0
	local on_count = 0
	local missing = {}
	for _, entry in ipairs(members) do
		local eff = plugin_enabled_fn and plugin_enabled_fn(entry)
		if eff == nil then
			missing[#missing + 1] = entry
		else
			exist_count = exist_count + 1
			if eff then
				on_count = on_count + 1
			end
		end
	end
	local state
	if total == 0 then
		state = "off"
	elseif #missing > 0 or (on_count > 0 and on_count < exist_count) then
		state = "partial"
	elseif on_count == 0 then
		state = "off"
	else
		state = "on"
	end
	return {
		state = state,
		total = total,
		exist_count = exist_count,
		on_count = on_count,
		missing_entries = missing
	}
end

return packs
