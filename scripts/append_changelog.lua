-- Fast incremental append: adds the just-made commit to the per-version
-- changelog file without scanning all git history.
-- Called by git-commit.sh after a successful commit.
--
-- Reads commit info from the most recent git commit.

local function run(cmd)
	local h = io.popen(cmd)
	if not h then
		return nil
	end
	local r = h:read("*a")
	h:close()
	return r
end

-- 获取刚刚提交的信息
local hash = run("git rev-parse HEAD")
if not hash or hash == "" then
	io.stderr:write("Failed to get HEAD hash\n")
	os.exit(1)
end
hash = hash:gsub("%s+", "")

local author = run("git log --format=%an -n 1 " .. hash)
local date = run("git log --format=%ad --date=short -n 1 " .. hash)
local message = run("git log --format=%s -n 1 " .. hash)
if not message or message == "" then
	io.stderr:write("Failed to get commit message\n")
	os.exit(1)
end
author = (author or "Unknown"):gsub("%s+", "")
date = (date or os.date("%Y-%m-%d")):gsub("%s+", "")
message = message:gsub("^%s+", ""):gsub("%s+$", "")

-- 读取当前版本号
local version_chunk = loadfile("version.lua")
if not version_chunk then
	io.stderr:write("Failed to load version.lua\n")
	os.exit(1)
end
local ok, ver = pcall(version_chunk)
if not ok or type(ver) ~= "table" or not ver.id then
	io.stderr:write("version.lua has no id field\n")
	os.exit(1)
end

local vid = ver.id
local filename = "v" .. (vid:gsub("%.", "_"))
local filepath = "dove_modules/data/changelog/" .. filename .. ".lua"

local function is_version_only_commit(hash)
	local parent = run("git rev-list --parents -n 1 " .. hash .. " 2>/dev/null")
	if not parent then
		return false
	end
	local count = 0
	for _ in parent:gmatch("%x+") do
		count = count + 1
	end
	if count <= 1 then
		return false
	end
	local diff = run("git diff-tree --no-commit-id --name-only -r " .. hash)
	if not diff then
		return false
	end
	local non_version = 0
	for f in diff:gmatch("[^\n]+") do
		if f ~= "version.lua" then
			non_version = non_version + 1
		end
	end
	return non_version == 0
end

local function is_version_marker(msg)
	local patterns = {"LAST%s+VERSION%s*[:%s]+v?[%d%.]+", "MAIN%s+VERSION%s+JUMP%s*[:%s]+v?[%d%.]+", "version%s+jump%s+to%s+v?[%d%.]+", "VERSION%s+JUMP%s+TO%s+v?[%d%.]+"}
	for _, pat in ipairs(patterns) do
		if msg:match(pat) then
			return true
		end
	end
	return false
end

-- 与 gen_changelog.lua 保持一致的过滤规则
if is_version_only_commit(hash) or is_version_marker(message) then
	os.exit(0)
end

local function escape(s)
	return s:gsub("[\"'\\]", {
		['"'] = '\\"',
		["\\"] = "\\\\"
	})
end

-- 读取已有的版本文件（如果有）
local entries = {}
local existing = loadfile(filepath)
if existing then
	local ok2, data = pcall(existing)
	if ok2 and type(data) == "table" then
		entries = data
	end
end

-- 追加到末尾，与 gen_changelog.lua 一致（最旧在前，最新在后）
table.insert(entries, {
	date = date,
	author = author,
	message = message
})

-- 写回版本文件
local f = io.open(filepath, "w")
if not f then
	io.stderr:write("Failed to open " .. filepath .. "\n")
	os.exit(1)
end
f:write("-- auto-generated\nreturn {\n")
for _, e in ipairs(entries) do
	f:write(string.format('  { date = %q, author = %q, message = %q },\n', e.date or "", escape(e.author or ""), escape(e.message or "")))
end
f:write("}\n")
f:close()

-- 更新索引文件
local idx_path = "dove_modules/data/changelog_data.lua"
local idx_entries = {}
local idx_existing = loadfile(idx_path)
if idx_existing then
	local ok3, data = pcall(idx_existing)
	if ok3 and type(data) == "table" then
		local found = false
		for _, entry in ipairs(data) do
			if entry.id == vid then
				table.insert(idx_entries, {
					id = vid,
					file = filename,
					count = #entries
				})
				found = true
			else
				table.insert(idx_entries, entry)
			end
		end
		if not found then
			-- 新版本，插入到最前面
			table.insert(idx_entries, 1, {
				id = vid,
				file = filename,
				count = #entries
			})
		end
	end
end
if #idx_entries == 0 then
	idx_entries = {{
		id = vid,
		file = filename,
		count = #entries
	}}
end

local idx_f = io.open(idx_path, "w")
if not idx_f then
	io.stderr:write("Failed to open " .. idx_path .. "\n")
	os.exit(1)
end
idx_f:write("-- auto-generated\nreturn {\n")
for _, e in ipairs(idx_entries) do
	idx_f:write(string.format('  { id = %q, file = %q, count = %d },\n', e.id, e.file, e.count))
end
idx_f:write("}\n")
idx_f:close()

print("Appended commit to " .. filepath)
