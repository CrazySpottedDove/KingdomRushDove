-- organize_strings.lua
--
-- 整理 i18n 文本文件（_assets/kr1-desktop/strings/en.lua 与 zh-Hans.lua）：
--
--   1. 按 key 排序。
--   2. 找出「内容完全相同、且含有动态表达式 %$...%$」的字符串（例如同一技能的
--      _1/_2/_3_DESCRIPTION 文案一字不差）。把这段文案在文件开头定义成一个
--      local 变量，变量名取这几个 key 里（排序后）的第一个；所有 key 的取值
--      都改成引用这个 local，于是改文案/公式只需改一处。
--
--        local TOWER_X_DESCRIPTION_1 = "造成 %$T('t').damage[level]%$ 点伤害。"
--        return {
--          TOWER_X_DESCRIPTION_1 = TOWER_X_DESCRIPTION_1,
--          TOWER_X_DESCRIPTION_2 = TOWER_X_DESCRIPTION_1,
--          TOWER_X_DESCRIPTION_3 = TOWER_X_DESCRIPTION_1,
--        }
--
--      只处理含 %$...%$ 的「动态字符串」；不含动态表达式的普通重复文案不去重
--      （数量太多，且没有「改一处公式」的收益）。
--   3. 若 local 数量超过 LuaJIT 单函数 200 个 local 的上限，则退化为一个
--      local 表 DYN：`local DYN = { KEY = "..." }`，取值处引用 DYN.KEY。
--   4. 仅当这两个文件相对 HEAD / 暂存区有改动时才运行，且直接重写文件。
--
-- 用法：
--   luajit scripts/organize_strings.lua           # 按 git 改动决定是否执行
--   luajit scripts/organize_strings.lua --force   # 忽略 git 改动检查，强制执行
--   luajit scripts/organize_strings.lua --force <file> [file...]
--
-- 接入：make add 的 format 阶段之后执行，执行完再 format 一次。

local DEFAULT_FILES = {"_assets/kr1-desktop/strings/en.lua", "_assets/kr1-desktop/strings/zh-Hans.lua"}

-- LuaJIT 单个函数最多 200 个 local，留一点余量
local MAX_LOCALS = 198

local KEYWORDS = {}

for w in ("and break do else elseif end false for function if in local nil not or " .. "repeat return then true until while"):gmatch("%S+") do
	KEYWORDS[w] = true
end

-- ── 参数 ──────────────────────────────────────────────────────
local force = false
local files = {}

for _, a in ipairs(arg or {}) do
	if a == "--force" or a == "-f" then
		force = true
	else
		files[#files + 1] = a
	end
end

if #files == 0 then
	files = DEFAULT_FILES
end

-- ── 基础工具 ──────────────────────────────────────────────────
local function read_file(path)
	local f = assert(io.open(path, "r"))

	local content = f:read("*a")

	f:close()

	return content
end

local function write_file(path, content)
	local f, err = io.open(path, "w")

	if not f then
		error("无法写入 " .. path .. ": " .. tostring(err))
	end

	f:write(content)
	f:close()
end

local function load_table(path)
	local content = read_file(path)
	local chunk, err = load(content, "@" .. path, "t", _ENV)

	if not chunk then
		error("无法加载 " .. path .. ": " .. tostring(err))
	end

	return chunk(), content
end

--- 目标文件相对 HEAD / 暂存区是否有改动。
local function git_changed(paths)
	local quoted = {}

	for i, p in ipairs(paths) do
		quoted[i] = "'" .. p .. "'"
	end

	local cmd = "git status --porcelain -- " .. table.concat(quoted, " ") .. " 2>/dev/null"
	local pipe = io.popen(cmd)

	if not pipe then
		-- 无法执行 git，保守起见照常处理
		return true
	end

	local out = pipe:read("*a") or ""

	pipe:close()

	return out:match("%S") ~= nil
end

local function is_identifier(s)
	return type(s) == "string" and s:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

--- 含有动态表达式 %$...%$ 的字符串才参与去重。
local function is_dynamic(v)
	return type(v) == "string" and v:find("%$", 1, true) ~= nil
end

local function sanitize_name(key)
	local s = tostring(key):gsub("[^%w_]", "_")

	if s:match("^%d") then
		s = "_" .. s
	end

	if s == "" then
		s = "DYN"
	end

	if KEYWORDS[s] then
		s = "_" .. s
	end

	return s
end

--- 把字符串安全地序列化为 Lua 字符串字面量。
local function quote(s)
	local body = s:gsub("[%z\1-\31\\\"]", function(c)
		if c == "\\" then
			return "\\\\"
		elseif c == '"' then
			return '\\"'
		elseif c == "\n" then
			return "\\n"
		elseif c == "\r" then
			return "\\r"
		elseif c == "\t" then
			return "\\t"
		else
			return string.format("\\%d", string.byte(c))
		end
	end)

	return '"' .. body .. '"'
end

local function sorted_keys(tbl)
	local keys = {}

	for k in pairs(tbl) do
		keys[#keys + 1] = k
	end

	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return keys
end

-- ── 共享文案提取 ──────────────────────────────────────────────
--- 找出重复的动态字符串，给每组分配一个 local 名字。
---@param tbl table
---@param keys string[]  已排序的 key
---@return table ref_of  字符串值 -> 取值表达式（local 名或 DYN.field）
---@return table groups  { { name = local名, value = 文案 }, ... }
local function build_share_map(tbl, keys)
	local count = {}

	for _, k in ipairs(keys) do
		local v = tbl[k]

		if is_dynamic(v) then
			count[v] = (count[v] or 0) + 1
		end
	end

	local ref_of = {}
	local groups = {}
	local used = {}

	for _, k in ipairs(keys) do
		local v = tbl[k]

		if is_dynamic(v) and count[v] >= 2 and not ref_of[v] then
			local base = sanitize_name(k)
			local name = base
			local n = 2

			while used[name] do
				name = base .. "_" .. n
				n = n + 1
			end

			used[name] = true
			ref_of[v] = name
			groups[#groups + 1] = {
				name = name,
				value = v
			}
		end
	end

	return ref_of, groups
end

local serialize_body

--- 把表序列化成表字面量（不含 return）。
serialize_body = function(tbl, ref_of, indent)
	local pad = indent or ""
	local child_pad = pad .. "\t"
	local entries = {}

	for _, k in ipairs(sorted_keys(tbl)) do
		local v = tbl[k]
		local key_str = is_identifier(k) and k or ("[" .. quote(k) .. "]")
		local val_str

		if ref_of[v] then
			val_str = ref_of[v]
		elseif type(v) == "string" then
			val_str = quote(v)
		elseif type(v) == "table" then
			val_str = serialize_body(v, ref_of, child_pad)
		else
			val_str = tostring(v)
		end

		entries[#entries + 1] = child_pad .. key_str .. " = " .. val_str
	end

	-- 最后一个元素不带逗号（与 dlfmt 的输出保持一致，保证脚本幂等）
	return "{\n" .. table.concat(entries, ",\n") .. "\n" .. pad .. "}"
end

local function serialize_table(tbl, ref_of)
	return "return " .. serialize_body(tbl, ref_of, "")
end

-- ── 单文件处理 ────────────────────────────────────────────────
local function organize(path)
	local tbl, original = load_table(path)
	local keys = sorted_keys(tbl)
	local ref_of, groups = build_share_map(tbl, keys)

	table.sort(groups, function(a, b)
		return a.name < b.name
	end)

	local header

	if #groups == 0 then
		header = nil
	elseif #groups <= MAX_LOCALS then
		local lines = {}

		for _, g in ipairs(groups) do
			lines[#lines + 1] = "local " .. g.name .. " = " .. quote(g.value)
		end

		header = table.concat(lines, "\n")
	else
		-- 兜底：local 太多会触发 LuaJIT 200 locals 上限，改用一张 local 表
		local lines = {"local DYN = {"}

		for _, g in ipairs(groups) do
			lines[#lines + 1] = "\t" .. g.name .. " = " .. quote(g.value) .. ","

			ref_of[g.value] = "DYN." .. g.name
		end

		lines[#lines + 1] = "}"
		header = table.concat(lines, "\n")
	end

	local body = serialize_table(tbl, ref_of)
	local result

	if header then
		result = header .. "\n\n" .. body .. "\n"
	else
		result = body .. "\n"
	end

	if result == original then
		print(string.format("[organize_strings] %s: 无需修改（共享 %d 段动态文案）", path, #groups))

		return #groups, false
	end

	write_file(path, result)

	print(string.format("[organize_strings] %s: 已整理（共享 %d 段动态文案）", path, #groups))

	return #groups, true
end

-- ── 主流程 ────────────────────────────────────────────────────
if not force and not git_changed(files) then
	print("[organize_strings] 文本文件无改动，跳过。")

	os.exit(0)
end

local total = 0
local changed = 0

for _, path in ipairs(files) do
	local n, did = organize(path)

	total = total + n

	if did then
		changed = changed + 1
	end
end

print(string.format("[organize_strings] 完成：%d 个文件，共共享 %d 段动态文案。", changed, total))
