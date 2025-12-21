-- chunkname: @./lib/klua/persistence.lua
local write, writeIndent, writers, refCount, stringWriter
local persistence = {}

function persistence.store(path, ...)
	local file, e = io.open(path, "w")

	if not file then
		return error(e)
	end

	persistence.serialize(file, ...)
	file:close()
end

function persistence.load(path, fenv)
	local f, e = loadfile(path)

	if f then
		if fenv then
			setfenv(f, fenv)
		end

		return f()
	else
		return nil, e
	end
end

function persistence.serialize(file, ...)
	local n = select("#", ...)
	local objRefCount = {}

	for i = 1, n do
		refCount(objRefCount, (select(i, ...)))
	end

	local objRefNames = {}
	local objRefIdx = 0
	local wrote_def = false

	for obj, count in pairs(objRefCount) do
		if count > 1 then
			if not wrote_def then
				file:write("local multiRefObjects = {\n")

				wrote_def = true
			end

			objRefIdx = objRefIdx + 1
			objRefNames[obj] = objRefIdx

			file:write("{};")
		end
	end

	if wrote_def then
		file:write("\n} -- multiRefObjects\n")
	end

	for obj, idx in pairs(objRefNames) do
		for k, v in pairs(obj) do
			file:write("multiRefObjects[" .. idx .. "][")
			write(file, k, 0, objRefNames)
			file:write("] = ")
			write(file, v, 0, objRefNames)
			file:write(";\n")
		end
	end

	for i = 1, n do
		file:write("local " .. "obj" .. i .. " = ")
		write(file, select(i, ...), 0, objRefNames)
		file:write("\n")
	end

	if n > 0 then
		file:write("return obj1")

		for i = 2, n do
			file:write(" ,obj" .. i)
		end

		file:write("\n")
	else
		file:write("return\n")
	end
end

function persistence.serialize_to_string(...)
	local sw = stringWriter.open()

	persistence.serialize(sw, ...)

	local str = tostring(sw)

	sw:close()

	return str
end

function write(file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames)
end

function writeIndent(file, level)
	for i = 1, level do
		file:write("\t")
	end
end

function refCount(objRefCount, item)
	if type(item) == "table" then
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1
		else
			objRefCount[item] = 1

			for k, v in pairs(item) do
				refCount(objRefCount, k)
				refCount(objRefCount, v)
			end
		end
	end
end

writers = {
	["nil"] = function(file, item)
		file:write("nil")
	end,
	number = function(file, item)
		file:write(tostring(item))
	end,
	string = function(file, item)
		file:write(string.format("%q", item))
	end,
	boolean = function(file, item)
		file:write(item and "true" or "false")
	end,
	table = function(file, item, level, objRefNames)
		local refIdx = objRefNames[item]

		if refIdx then
			file:write("multiRefObjects[" .. refIdx .. "]")
		else
			file:write("{\n")

			local keys = {}

			for k, v in pairs(item) do
				table.insert(keys, k)
			end

			table.sort(keys, function(e1, e2)
				te1, te2 = type(e1), type(e2)

				if te1 == "number" and te2 == "number" then
					return e1 < e2
				elseif te1 == "string" and te2 == "string" then
					return e1 < e2
				elseif te1 == "number" then
					return true
				else
					return false
				end
			end)

			for _, k in pairs(keys) do
				local v = item[k]

				writeIndent(file, level + 1)
				file:write("[")
				write(file, k, level + 1, objRefNames)
				file:write("] = ")
				write(file, v, level + 1, objRefNames)
				file:write(";\n")
			end

			writeIndent(file, level)
			file:write("}")
		end
	end,
	["function"] = function(file, item)
		local dInfo = debug.getinfo(item, "uS")

		if dInfo.nups > 0 then
			file:write("nil --[[functions with upvalue not supported]]")
		elseif dInfo.what ~= "Lua" then
			file:write("nil --[[non-lua function not supported]]")
		else
			local r, s = pcall(string.dump, item)

			if r then
				file:write(string.format("loadstring(%q)", s))
			else
				file:write("nil --[[function could not be dumped]]")
			end
		end
	end,
	thread = function(file, item)
		file:write("nil --[[thread]]\n")
	end,
	userdata = function(file, item)
		file:write("nil --[[userdata]]\n")
	end
}
stringWriter = {}

local metat = {
	__index = {}
}

function stringWriter.open(...)
	local sw = {
		buffer = {}
	}

	setmetatable(sw, metat)

	return sw
end

function metat.__index:write(str)
	self.buffer[#self.buffer + 1] = str
end

function metat:__tostring()
	if self.buffer then
		return table.concat(self.buffer)
	else
		return tostring(nil)
	end
end

function metat.__index:close(...)
	self.buffer = nil
end

local write_compact

local function is_array(t)
	-- 纯数组：键为 1..n 的连续整数，且没有其他键
	if type(t) ~= "table" then
		return false
	end

	local n = #t
	local count = 0

	for k, _ in pairs(t) do
		if type(k) ~= "number" or k < 1 or k > n or k % 1 ~= 0 then
			return false
		end

		count = count + 1
	end

	return count == n
end

function persistence.serialize_compact(file, ...)
	-- 紧凑版本：不生成 multiRefObjects，不排序键，不缩进
	-- 适合 v3 的数组密集结构（如 EXO），体积更小
	local n = select("#", ...)

	if n == 1 then
		file:write("return ")
		write_compact(file, select(1, ...))

		return
	end

	for i = 1, n do
		file:write("local obj" .. i .. "=")
		write_compact(file, select(i, ...))
		file:write("\n")
	end

	if n > 0 then
		file:write("return obj1")

		for i = 2, n do
			file:write(",obj" .. i)
		end

		file:write("\n")
	else
		file:write("return\n")
	end
end

function persistence.serialize_to_string_compact(...)
	local sw = stringWriter.open()

	persistence.serialize_compact(sw, ...)

	local str = tostring(sw)

	sw:close()

	return str
end

local key_words = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true
}

write_compact = function(file, item)
	local t = type(item)

	if t == "nil" then
		file:write("nil")
	elseif t == "number" then
		file:write(tostring(item))
	elseif t == "string" then
		file:write(string.format("%q", item))
	elseif t == "boolean" then
		file:write(item and "true" or "false")
	elseif t == "table" then
		if is_array(item) then
			-- 紧凑数组：{v1,v2,...}
			file:write("{")

			for i = 1, #item do
				if i > 1 then
					file:write(",")
				end

				write_compact(file, item[i])
			end

			file:write("}")
		else
			-- 普通 table：{[k]=v;...}，不缩进不排序，分号做项分隔更紧凑
			file:write("{")

			local first = true

			for k, v in pairs(item) do
				if first then
					first = false
				else
					file:write(";")
				end

				-- 当无异义时，省略键的方括号
				if type(k) == "string" and k:match("^[%a_][%w_]*$") and (not key_words[k]) then
					file:write(k)
					file:write("=")
					write_compact(file, v)
				else
					file:write("[")
					write_compact(file, k)
					file:write("]=")
					write_compact(file, v)
				end
			end

			file:write("}")
		end
	elseif t == "function" then
		-- 保持与原库兼容的限制
		local dInfo = debug.getinfo(item, "uS")

		if dInfo.nups > 0 or dInfo.what ~= "Lua" then
			file:write("nil")
		else
			local ok, s = pcall(string.dump, item)

			if ok then
				file:write(string.format("loadstring(%q)", s))
			else
				file:write("nil")
			end
		end
	else
		-- thread/userdata 等不可序列化类型
		file:write("nil")
	end
end

return persistence
