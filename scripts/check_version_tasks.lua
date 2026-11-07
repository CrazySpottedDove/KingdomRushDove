-- 构建前检查 scripts/version_tasks.lua 中是否有已经到期的版本任务。
--
-- 默认：有到期任务时退出码为 1，阻止继续打包。
-- 仅提醒：VERSION_TASKS_WARN_ONLY=1
-- 自定义路径：VERSION_FILE=... VERSION_TASKS_FILE=...
local version_file = os.getenv("VERSION_FILE") or "version.lua"
local explicit_tasks_file = os.getenv("VERSION_TASKS_FILE")
local tasks_file = explicit_tasks_file or "scripts/version_tasks.lua"
local warn_only = os.getenv("VERSION_TASKS_WARN_ONLY") == "1"

local function file_exists(path)
	local f = io.open(path, "r")

	if f then
		f:close()

		return true
	end

	return false
end

local function load_lua_file(path, description)
	local chunk, err = loadfile(path)
	if not chunk then
		error(string.format("cannot load %s (%s): %s", description, path, tostring(err)))
	end

	local ok, result = pcall(chunk)
	if not ok then
		error(string.format("cannot evaluate %s (%s): %s", description, path, tostring(result)))
	end

	return result
end

local version = load_lua_file(version_file, "version file")
local current = tostring(version.id or "")
if current == "" then
	error("version.lua has no id")
end

if not file_exists(tasks_file) then
	if explicit_tasks_file then
		error("version tasks file not found: " .. tasks_file)
	end

	print(string.format("[version-tasks] no local task file (%s), skipped", tasks_file))

	return
end

local tasks = load_lua_file(tasks_file, "version tasks")
if type(tasks) ~= "table" then
	error("version tasks must return a table")
end

local function parse_version(value)
	local parts = {}

	for n in tostring(value):gmatch("%d+") do
		parts[#parts + 1] = tonumber(n)
	end

	if #parts == 0 then
		error("invalid version: " .. tostring(value))
	end

	return parts
end

local function compare_version(a, b)
	local pa, pb = parse_version(a), parse_version(b)
	local n = math.max(#pa, #pb)

	for i = 1, n do
		local va, vb = pa[i] or 0, pb[i] or 0

		if va < vb then
			return -1
		elseif va > vb then
			return 1
		end
	end

	return 0
end

local due = {}
local pending = 0

for _, task in ipairs(tasks) do
	if type(task) == "table" and task.id and task.due and not task.done then
		if compare_version(task.due, current) <= 0 then
			due[#due + 1] = task
		else
			pending = pending + 1
		end
	end
end

print(string.format("[version-tasks] current=%s due=%d pending=%d", current, #due, pending))

if #due == 0 then
	return
end

for _, task in ipairs(due) do
	print("")
	print(string.format("[version-tasks] DUE: %s (%s)", task.id, task.due))
	print("  " .. tostring(task.message or ""))
	for _, file in ipairs(task.files or {}) do
		print("  - " .. tostring(file))
	end
end

print("")
print("[version-tasks] 请先处理到期任务，或在 scripts/version_tasks.lua 中标记 done = true。")

if not warn_only then
	os.exit(1)
end
