--[[
预编译 CLI
用法：
  luajit scripts/precompile.lua check
  luajit scripts/precompile.lua build
  luajit scripts/precompile.lua dump [entity]
]]

package.path = "./?.lua;./kr1/?.lua;./all/?.lua;./all/systems/?.lua;./lib/?.lua;./kr1-desktop/?.lua;" .. "./all-desktop/?.lua;./_assets/?.lua;./_assets/kr1-desktop/?.lua;./_assets/all-desktop/?.lua;" .. "./lib/klua/?.lua;./lib/hump/?.lua;./precompile/?.lua;" .. package.path

local command = arg[1] or "check"
local GENERATED_DIR = "precompile/generated"
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

local function generate(E, specs, source, specialize)
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
				local ok, result = pcall(specialize.specialize, func, e, {
					file = file.path
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
								comments = {}
							}
							group[name] = entry
						end
						if entry.keys[item.spec.key] then
							errors[#errors + 1] = string.format("%s %s.%s: duplicate spec", name, item.spec.group, item.spec.key)
						else
							entry.keys[item.spec.key] = expr
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

	do
		local lines = {"return {"}
		for _, item in ipairs(unique_list) do
			lines[#lines + 1] = "\t" .. item.expr .. ","
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

	local index = {"return {", '\t"shared",'}
	for _, group_name in ipairs(modules) do
		index[#index + 1] = string.format("\t%q,", group_name)
	end
	index[#index + 1] = "}"
	files.index = table.concat(index, "\n") .. "\n"

	stats.unique_functions = #unique_list
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

local function run_generate(write)
	local E = load_entities()
	local specs = require("precompile.specs")
	local source = require("precompile.frontend.source")
	local specialize = require("precompile.stage.specialize")
	local files, errors, stats = generate(E, specs, source, specialize)

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
		for name, content in pairs(files) do
			write_file(GENERATED_DIR .. "/" .. name .. ".lua", content)
		end
	end

	local bytes = 0
	for _, content in pairs(files) do
		bytes = bytes + #content
	end
	print(string.format("生成函数: %d（共享后 %d），折叠分支: %d，展开循环: %d", stats.functions, stats.unique_functions, stats.folded, stats.unrolled))
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

if command == "check" then
	if arg[2] == "--source" then
		os.exit(run_source_check())
	end
	os.exit(run_generate(false))
elseif command == "build" then
	os.exit(run_generate(true))
elseif command == "dump" then
	os.exit(run_dump(arg[2]))
else
	fail("未知命令: " .. command .. "（可用: check, check --source, build, dump）")
end
