local function mkdir_p(path)
	os.execute("mkdir -p " .. path)
end

local function run(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

local function get_version_id_at(commit_hash)
	local content = run("git show " .. commit_hash .. ":version.lua 2>/dev/null")
	if not content or content == "" then
		return nil
	end
	return content:match('^id%s*=%s*"([^"]+)"') or content:match('[%s]id%s*=%s*"([^"]+)"')
end

local function extract_version_from_message(msg)
	if not msg then
		return nil
	end
	local patterns = {"LAST%s+VERSION%s*[:%s]+v?([%d%.]+)", "MAIN%s+VERSION%s+JUMP%s*[:%s]+v?([%d%.]+)", "version%s+jump%s+to%s+v?([%d%.]+)", "VERSION%s+JUMP%s+TO%s+v?([%d%.]+)"}
	for _, pat in ipairs(patterns) do
		local vn = msg:match(pat)
		if vn then
			return vn
		end
	end
	return nil
end

local function escape(s)
	return s:gsub("[\"'\\]", {
		['"'] = '\\"',
		["\\"] = "\\\\"
	})
end

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

local function sanitize_filename(vid)
	return vid:gsub("%.", "_")
end

-- 收集所有修改过 version.lua 的 commit（按时间正序）
local version_lua_str = run('git log --all --format="%H" --reverse -- version.lua')
local version_lua_commits = {}
for hash in version_lua_str:gmatch("([%x]+)") do
	table.insert(version_lua_commits, hash)
end

if #version_lua_commits == 0 then
	io.stderr:write("No commits touching version.lua found\n")
	os.exit(1)
end

-- 找出第一个有 id 字段的 commit
local id_start_hash = nil
local id_start_idx = 1
for i, hash in ipairs(version_lua_commits) do
	local vid = get_version_id_at(hash)
	if vid then
		id_start_hash = hash
		id_start_idx = i
		break
	end
end
if not id_start_hash then
	io.stderr:write("No version id found in version.lua history\n")
	os.exit(1)
end

-- post-id 时代 version_at 映射
local version_at = {}
local last_known_id = nil
for i, hash in ipairs(version_lua_commits) do
	local vid = get_version_id_at(hash)
	if vid then
		last_known_id = vid
	end
	if i >= id_start_idx then
		version_at[hash] = last_known_id
	end
end

-- 获取所有 commit（按时间正序）
local git_log = run('git log --all --format="%H|%an|%ad|%s" --date=short --reverse --max-count=5000')
local all_commits = {}
for line in git_log:gmatch("([^\n]+)") do
	local hash, author, date, message = line:match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
	if hash then
		table.insert(all_commits, {
			hash = hash,
			author = author,
			date = date,
			message = message
		})
	end
end

-- 扫描版本变化
local version_entries = {}
local version_order = {}
local current_version = nil
local version_lua_idx = 1
local entered_id_era = false

for _, c in ipairs(all_commits) do
	local in_version_lua = false
	while version_lua_idx <= #version_lua_commits and version_lua_commits[version_lua_idx] == c.hash do
		in_version_lua = true
		if c.hash == id_start_hash then
			entered_id_era = true
		end
		version_lua_idx = version_lua_idx + 1
	end

	local new_version = nil
	if entered_id_era then
		if version_at[c.hash] then
			new_version = version_at[c.hash]
		end
		if in_version_lua and c.hash == id_start_hash and not new_version then
			new_version = get_version_id_at(c.hash)
		end
	else
		new_version = extract_version_from_message(c.message)
	end

	if new_version then
		if not version_entries[new_version] then
			version_entries[new_version] = {}
			table.insert(version_order, new_version)
		end
		current_version = new_version
	end

	if current_version then
		local skip = false
		if entered_id_era then
			skip = new_version and is_version_only_commit(c.hash)
		else
			skip = new_version ~= nil
		end
		if not skip then
			table.insert(version_entries[current_version], {
				date = c.date,
				author = c.author,
				message = c.message
			})
		end
	end
end

-- 确保输出目录存在
mkdir_p("dove_modules/data/changelog")

-- 写入每个版本的独立文件
for _, vid in ipairs(version_order) do
	local entries = version_entries[vid] or {}
	local fname = "v" .. sanitize_filename(vid) .. ".lua"
	local path = "dove_modules/data/changelog/" .. fname
	local f = io.open(path, "w")
	if not f then
		io.stderr:write("Failed to open " .. path .. "\n")
		os.exit(1)
	end
	f:write("-- auto-generated\nreturn {\n")
	for _, e in ipairs(entries) do
		f:write(string.format('  { date = %q, author = %q, message = %q },\n', e.date or "", escape(e.author or ""), escape(e.message or "")))
	end
	f:write("}\n")
	f:close()
end

-- 写入索引文件（最新在前）
local index_path = "dove_modules/data/changelog_data.lua"
local idx_f = io.open(index_path, "w")
if not idx_f then
	io.stderr:write("Failed to open " .. index_path .. "\n")
	os.exit(1)
end
idx_f:write("-- auto-generated\nreturn {\n")
for i = #version_order, 1, -1 do
	local vid = version_order[i]
	idx_f:write(string.format('  { id = %q, file = %q, count = %d },\n', vid, "v" .. sanitize_filename(vid), #(version_entries[vid] or {})))
end
idx_f:write("}\n")
idx_f:close()

print("Generated " .. #version_order .. " version files in dove_modules/data/changelog/")
print("Updated dove_modules/data/changelog_data.lua (index)")
