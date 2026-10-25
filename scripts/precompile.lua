--[[
预编译 CLI
用法：
  luajit scripts/precompile.lua check
  luajit scripts/precompile.lua build [--force]
  luajit scripts/precompile.lua dump [entity]
]]

package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

local bit = require("bit")

local command = arg[1] or "check"
local GENERATED_DIR = "precompile/generated"
local CACHE_FILE = GENERATED_DIR .. "/.build_cache"
local GROUPS = {"enemies", "bullets", "soldiers", "modifiers", "auras"}

local function fail(message)
	io.stderr:write(message, "\n")
	os.exit(1)
end

local function load_entities()
	local stub = require("scripts.ci.love_stub")
	local E = require("entity_db")
	local ok, err = pcall(E.load_for_build, E)
	if not ok then
		fail("加载实体数据库失败: " .. tostring(err))
	end
	return E
end

local function collect(E, specs, source)
	local records = {}
	local errors = {}
	local entities = {}

	for _, e in pairs(E.entities) do
		for _, item in ipairs(specs.for_entity(e)) do
			local record = records[item.source]
			if not record then
				local func, file, err = source.find_function(item.source)
				record = {
					source = item.source,
					spec = item.spec,
					func = func,
					file = file,
					err = err,
					count = 0,
					entities = {}
				}
				records[item.source] = record
				if err then
					errors[#errors + 1] = {
						message = err,
						group = item.spec.group,
						key = item.spec.key
					}
				end
			end
			record.count = record.count + 1
			record.entities[#record.entities + 1] = e.template_name or "?"
			entities[e.template_name or "?"] = true
		end
	end

	return records, errors, entities
end

local function sorted_records(records)
	local list = {}
	for _, record in pairs(records) do
		list[#list + 1] = record
	end
	table.sort(list, function(a, b)
		if a.spec.group ~= b.spec.group then
			return a.spec.group < b.spec.group
		end
		if a.spec.key ~= b.spec.key then
			return a.spec.key < b.spec.key
		end
		return (a.file and a.file.path or "") < (b.file and b.file.path or "")
	end)
	return list
end

local function count_keys(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

local function has_entity(record, name)
	for _, entity_name in ipairs(record.entities) do
		if entity_name == name then
			return true
		end
	end
	return false
end

local function sanitize(name)
	return (name:gsub("[^%w_]", "_"))
end

local function generate(E, specs, source, specialize, whitelists, globals)
	local groups = {}
	for _, group in ipairs(GROUPS) do
		groups[group] = {}
	end

	local errors = {}
	local stats = {
		functions = 0,
		folded = 0,
		unrolled = 0
	}

	for _, e in pairs(E.entities) do
		local name = e.template_name
		for _, item in ipairs(specs.for_entity(e)) do
			local compile_source = item.spec.compile_source or item.source
			local func, file, err = source.find_function(compile_source)
			if not func then
				errors[#errors + 1] = string.format("%s %s.%s: %s", name, item.spec.group, item.spec.key, err)
			else
				local whitelist = item.spec.family and whitelists[item.spec.family] or nil
				local nullable = item.spec.family and whitelists.nullable and whitelists.nullable[item.spec.family] or nil
				local ok, result = pcall(specialize.specialize, func, e, {
					file = file.path,
					whitelist = whitelist,
					nullable = nullable,
					globals = globals,
					helper_prefix = "__pc_" .. sanitize(name) .. "_" .. sanitize(item.spec.key) .. "_"
				})
				if not ok then
					errors[#errors + 1] = string.format("%s %s.%s: %s", name, item.spec.group, item.spec.key, result)
				else
					local expr = result.code:sub(8)
					local chunk, load_err = load("return " .. expr, "generated", "t", _G)
					if not chunk then
						errors[#errors + 1] = string.format("%s %s.%s: %s", name, item.spec.group, item.spec.key, load_err)
					else
						local group = groups[item.spec.group]
						local entry = group[name]
						if not entry then
							entry = {
								keys = {},
								origins = {},
								helpers = {}
							}
							group[name] = entry
						end
						if entry.keys[item.spec.key] then
							errors[#errors + 1] = string.format("%s %s.%s: duplicate spec", name, item.spec.group, item.spec.key)
						else
							entry.keys[item.spec.key] = expr
							for _, helper in ipairs(result.helpers or {}) do
								entry.helpers[#entry.helpers + 1] = helper
							end
							entry.origins[item.spec.key] = {
								file = result.file,
								line = result.line
							}
							if item.spec.state_machine then
								entry.type = 1
							end
							stats.functions = stats.functions + 1
							stats.folded = stats.folded + result.folded
							stats.unrolled = stats.unrolled + result.unrolled
						end
					end
				end
			end
		end
	end

	local helper_by_name = {}
	for _, group_name in ipairs(GROUPS) do
		for _, entry in pairs(groups[group_name]) do
			for _, helper in ipairs(entry.helpers or {}) do
				helper_by_name[helper.name] = helper
			end
		end
	end

	local function helper_ref(name)
		return "__pc_helpers[" .. string.format("%q", name) .. "]"
	end

	local function replace_ref(text, old, new)
		local needle = helper_ref(old)
		local replacement = helper_ref(new)
		local out = {}
		local pos = 1
		while true do
			local from, to = text:find(needle, pos, true)
			if not from then
				out[#out + 1] = text:sub(pos)
				break
			end
			out[#out + 1] = text:sub(pos, from - 1)
			out[#out + 1] = replacement
			pos = to + 1
		end
		return table.concat(out)
	end

	local canonical = {}
	local visiting = {}
	local seen = {}
	local helper_defs = {}
	local function normalize(name)
		if canonical[name] then
			return canonical[name]
		end
		if visiting[name] then
			return name
		end
		local helper = helper_by_name[name]
		if not helper then
			return name
		end
		visiting[name] = true
		local body = helper.body
		local deps = {}
		local seen_dep = {}
		for dep in body:gmatch('__pc_helpers%["([^"]+)"%]') do
			if not seen_dep[dep] then
				seen_dep[dep] = true
				deps[#deps + 1] = dep
			end
		end
		for _, dep in ipairs(deps) do
			local target = normalize(dep)
			if target ~= dep then
				body = replace_ref(body, dep, target)
			end
		end
		local key = table.concat(helper.params, ",") .. "\0" .. body
		local target = seen[key]
		if not target then
			target = name
			seen[key] = target
			helper_defs[#helper_defs + 1] = {
				name = target,
				params = helper.params,
				body = body
			}
		end
		canonical[name] = target
		visiting[name] = nil
		return target
	end
	local helper_names = {}
	for name in pairs(helper_by_name) do
		helper_names[#helper_names + 1] = name
	end
	table.sort(helper_names)
	for _, name in ipairs(helper_names) do
		normalize(name)
	end
	for _, group_name in ipairs(GROUPS) do
		for _, entry in pairs(groups[group_name]) do
			for key, expr in pairs(entry.keys) do
				for name, target in pairs(canonical) do
					if name ~= target and expr:find(helper_ref(name), 1, true) then
						expr = replace_ref(expr, name, target)
					end
				end
				entry.keys[key] = expr
			end
		end
	end
	table.sort(helper_defs, function(a, b)
		return a.name < b.name
	end)

	local unique_by_key = {}
	for _, group_name in ipairs(GROUPS) do
		for _, entry in pairs(groups[group_name]) do
			local script_type = entry.type == 1 and 1 or 0
			for _, expr in pairs(entry.keys) do
				local key = script_type .. "\0" .. expr
				if not unique_by_key[key] then
					unique_by_key[key] = {
						expr = expr,
						type = script_type
					}
				end
			end
		end
	end

	local unique_list = {}
	for _, item in pairs(unique_by_key) do
		unique_list[#unique_list + 1] = item
	end
	table.sort(unique_list, function(a, b)
		if a.type ~= b.type then
			return a.type < b.type
		end
		return a.expr < b.expr
	end)

	local expr_to_id = {}
	for i, item in ipairs(unique_list) do
		expr_to_id[item.type .. "\0" .. item.expr] = i
	end

	local files = {}
	local modules = {}
	local usage = {}

	do
		local lines = {}
		if #helper_defs > 0 then
			lines[#lines + 1] = "local __pc_helpers = {}"
			for _, helper in ipairs(helper_defs) do
				local code = "__pc_helpers[" .. string.format("%q", helper.name) .. "] = function(" .. table.concat(helper.params, ", ") .. ")\n"
				if helper.body ~= "" then
					code = code .. helper.body .. "\n"
				end
				code = code .. "end"
				lines[#lines + 1] = code
			end
		end
		lines[#lines + 1] = "return {"
		for id, item in ipairs(unique_list) do
			lines[#lines + 1] = string.format("\t[%d] = %s,", id, item.expr)
		end
		lines[#lines + 1] = "}"
		files.shared = table.concat(lines, "\n") .. "\n"
	end

	for _, group_name in ipairs(GROUPS) do
		local group = groups[group_name]
		local names = {}
		for name in pairs(group) do
			names[#names + 1] = name
		end
		table.sort(names)
		if #names > 0 then
			modules[#modules + 1] = group_name
			local lines = {"local shared = __pc_functions", "return {"}
			for _, name in ipairs(names) do
				local entry = group[name]
				local keys = {}
				for key in pairs(entry.keys) do
					keys[#keys + 1] = key
				end
				table.sort(keys)
				lines[#lines + 1] = string.format("\t[%q] = {", name)
				local script_type = entry.type == 1 and 1 or 0
				for _, key in ipairs(keys) do
					local id = assert(expr_to_id[script_type .. "\0" .. entry.keys[key]], "missing shared function")
					local origin = entry.origins[key] or {}
					local item = usage[id]
					if not item then
						item = {
							file = origin.file,
							line = origin.line,
							group = group_name,
							key = key,
							entities = {}
						}
						usage[id] = item
					end
					item.entities[#item.entities + 1] = name
					lines[#lines + 1] = string.format("\t\t%s = shared[%d],", key, id)
				end
				if entry.type then
					lines[#lines + 1] = string.format("\t\ttype = %d,", entry.type)
				end
				lines[#lines + 1] = "\t},"
			end
			lines[#lines + 1] = "}"
			files[group_name] = table.concat(lines, "\n") .. "\n"
		end
	end

	local ids = {}
	for id in pairs(usage) do
		ids[#ids + 1] = id
	end
	table.sort(ids)
	local map_lines = {"return {"}
	for _, id in ipairs(ids) do
		local item = usage[id]
		local entities = {}
		for i = 1, #item.entities do
			entities[i] = string.format("%q", item.entities[i])
		end
		map_lines[#map_lines + 1] = string.format("\t[%d] = { file = %q, line = %d, group = %q, key = %q, entities = {%s} },", id, item.file or "", item.line or 0, item.group or "", item.key or "", table.concat(entities, ", "))
	end
	map_lines[#map_lines + 1] = "}"
	files.source_map = table.concat(map_lines, "\n") .. "\n"

	local index = {"return {", '\t"shared",'}
	for _, group_name in ipairs(modules) do
		index[#index + 1] = string.format("\t%q,", group_name)
	end
	index[#index + 1] = "}"
	files.index = table.concat(index, "\n") .. "\n"

	stats.unique_functions = #unique_list
	stats.helpers = #helper_defs
	return files, errors, stats
end

local function read_file(path)
	local file = io.open(path, "rb")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function write_file(path, content)
	local file = assert(io.open(path, "wb"))
	file:write(content)
	file:close()
end

-- 影响生成结果的所有 Lua 输入。生成物也纳入指纹，避免被手删/手改后仍跳过。
local FINGERPRINT_DIRS = "all kr1 kr1-desktop all-desktop precompile scripts lib dove_modules _assets plugin patches"

local function capture(command)
	local pipe = io.popen(command, "r")
	if not pipe then
		return nil
	end
	local output = pipe:read("*a")
	pipe:close()
	if not output or output == "" then
		return nil
	end
	return output
end

local function build_fingerprint()
	local command = "{ find " .. FINGERPRINT_DIRS .. " -type f -name '*.lua' ! -path 'precompile/generated/*' -printf '%p\\t%s\\t%T@\\n' 2>/dev/null; " .. "find . -maxdepth 1 -type f -name '*.lua' -printf '%p\\t%s\\t%T@\\n' 2>/dev/null; " .. "find " .. GENERATED_DIR .. " -maxdepth 1 -type f -name '*.lua' -printf '%p\\t%s\\t%T@\\n' 2>/dev/null; " .. "} | LC_ALL=C sort"

	local text = capture(command)
	if not text then
		return nil
	end

	-- FNV-1a，避免把整份 stat 列表写进缓存文件。
	local hash = 2166136261
	for i = 1, #text do
		hash = bit.bxor(hash, text:byte(i)) % 4294967296
		hash = (hash * 16777619) % 4294967296
	end
	return string.format("%08x-%d", hash, #text)
end

local run_generate

local function run_build(force)
	local before = build_fingerprint()
	if not force and before then
		local cached = read_file(CACHE_FILE)
		if cached and cached:gsub("%s+$", "") == before then
			print("输入未变化，跳过预编译")
			return 0
		end
	end

	local code = run_generate(true)
	if code == 0 then
		local after = build_fingerprint()
		if after then
			os.execute("mkdir -p " .. GENERATED_DIR)
			write_file(CACHE_FILE, after .. "\n")
		end
	else
		os.remove(CACHE_FILE)
	end
	return code
end

function run_generate(write)
	local E = load_entities()
	local specs = require("precompile.specs")
	local source = require("precompile.frontend.source")
	local specialize = require("precompile.stage.specialize")
	local whitelists = require("precompile.whitelists")
	local globals = require("precompile.interface").env
	local files, errors, stats = generate(E, specs, source, specialize, whitelists, globals)

	if #errors > 0 then
		print("生成失败:")
		for _, message in ipairs(errors) do
			print("  " .. message)
		end
		return 1
	end

	local stale = {}
	for name, content in pairs(files) do
		local path = GENERATED_DIR .. "/" .. name .. ".lua"
		if read_file(path) ~= content then
			stale[#stale + 1] = path
		end
	end
	table.sort(stale)

	if write then
		os.execute("mkdir -p " .. GENERATED_DIR)
		local stale_set = {}
		for _, path in ipairs(stale) do
			stale_set[path] = true
		end
		for name, content in pairs(files) do
			local path = GENERATED_DIR .. "/" .. name .. ".lua"
			if stale_set[path] then
				write_file(path, content)
			end
		end
	end

	local bytes = 0
	for _, content in pairs(files) do
		bytes = bytes + #content
	end
	print(string.format("生成函数: %d（共享后 %d），helper: %d，折叠分支: %d，展开循环: %d", stats.functions, stats.unique_functions, stats.helpers, stats.folded, stats.unrolled))
	print(string.format("生成文件: %d，总计 %.2f MB", count_keys(files), bytes / 1024 / 1024))

	if #stale > 0 then
		if write then
			print("已更新:")
		else
			print("生成物不是最新:")
		end
		for _, path in ipairs(stale) do
			print("  " .. path)
		end
		return write and 0 or 1
	end

	print(write and "生成物已是最新" or "check 通过")
	return 0
end

local function run_source_check()
	local E = load_entities()
	local specs = require("precompile.specs")
	local source = require("precompile.frontend.source")
	local records, errors, entities = collect(E, specs, source)
	local list = sorted_records(records)

	print(string.format("实体模板: %d", count_keys(E.entities)))
	print(string.format("命中实体: %d", count_keys(entities)))
	print(string.format("唯一脚本函数: %d", #list))
	print("")

	for _, record in ipairs(list) do
		local location = "?"
		if record.func and record.file then
			location = string.format("%s:%d", record.file.path, record.func.line)
		end
		print(string.format("%-12s %-7s %5d 个实体  %s", record.spec.group, record.spec.key, record.count, location))
	end

	if #errors > 0 then
		print("")
		print("错误:")
		for _, item in ipairs(errors) do
			print(string.format("  %s.%s: %s", item.group, item.key, item.message))
		end
		return 1
	end

	print("")
	print("check 通过")
	return 0
end

local function run_dump(entity_name)
	local E = load_entities()
	local specs = require("precompile.specs")
	local source = require("precompile.frontend.source")
	local records, errors = collect(E, specs, source)
	local list = sorted_records(records)

	for _, record in ipairs(list) do
		if not entity_name or has_entity(record, entity_name) then
			local location = "?"
			if record.func and record.file then
				location = string.format("%s:%d", record.file.path, record.func.line)
			end
			print(string.format("%s.%s -> %s (%d 个实体)", record.spec.group, record.spec.key, location, record.count))
		end
	end

	if #errors > 0 then
		for _, item in ipairs(errors) do
			print(string.format("ERROR %s.%s: %s", item.group, item.key, item.message))
		end
		return 1
	end
	return 0
end

local function run_which(spec)
	local line = tonumber(tostring(spec):match("(%d+)$") or "")
	if not line then
		fail("which 需要一个行号或 shared.lua:行号")
	end
	local shared = assert(loadfile(GENERATED_DIR .. "/shared.lua"))()
	local id
	for index, fn in pairs(shared) do
		local info = debug.getinfo(fn, "S")
		if info.linedefined <= line and line <= info.lastlinedefined then
			id = index
			break
		end
	end
	if not id then
		fail("没有找到包含第 " .. line .. " 行的生成函数")
	end
	local map = assert(loadfile(GENERATED_DIR .. "/source_map.lua"))()
	local item = map[id]
	print(string.format("shared[%d]  shared.lua:%d", id, line))
	if item then
		print(string.format("源码: %s:%d", item.file or "?", item.line or 0))
		print(string.format("spec: %s.%s", item.group or "?", item.key or "?"))
		print("实体: " .. table.concat(item.entities or {}, ", "))
	end
	return 0
end

if command == "check" then
	if arg[2] == "--source" then
		os.exit(run_source_check())
	end
	os.exit(run_generate(false))
elseif command == "build" then
	local force = arg[2] == "--force" or arg[2] == "-f"
	os.exit(run_build(force))
elseif command == "dump" then
	os.exit(run_dump(arg[2]))
elseif command == "which" then
	os.exit(run_which(arg[2]))
else
	fail("未知命令: " .. command .. "（可用: check, build, dump, which）")
end
