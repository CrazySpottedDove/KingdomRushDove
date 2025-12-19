-- chunkname: @./lib/klua/dump.lua
function rawtostring(v)
	local mt = getmetatable(v)
	local ret

	if mt and mt ~= nil then
		setmetatable(v, nil)

		ret = tostring(v)

		setmetatable(v, mt)
	else
		ret = tostring(v)
	end

	return ret
end

local function keycomp(k1, k2)
	k1 = tostring(k1)
	k2 = tostring(k2)

	return k1 < k2
end

function getdump(t)
	return getfulldump(t, 1)
end

function dump(t)
	io.write(getdump(t))
end

function getfulldump(t, level, i)
	i = i or ""
	level = level or 99999999
	currLevel = 1

	local seen = {}
	local retstr

	local function _dump(t, i)
		seen[t] = true

		local keys = {}
		local keyStrs = {}
		local maxKeyLen = 0

		for k, _ in pairs(t) do
			keys[#keys + 1] = k
			keyStrs[k] = {type(k) == "string" and "'" .. tostring(k) .. "'" or tostring(k)}

			local klen = #keyStrs[k][1]

			keyStrs[k][2] = klen
			maxKeyLen = maxKeyLen <= klen and klen or maxKeyLen
		end

		table.sort(keys, keycomp)

		for _, k in ipairs(keys) do
			local arrowIndent = string.rep(" ", maxKeyLen - keyStrs[k][2]) .. "  "

			retstr = retstr .. string.format("%s    [%s]", i, keyStrs[k][1])
			retstr = retstr .. arrowIndent
			retstr = retstr .. string.format("->  %s\t%s\n", tostring(t[k]), seen[t[k]] and "(seen)" or "")
			k = t[k]

			if type(k) == "table" and k ~= nil and not seen[k] and currLevel < level then
				currLevel = currLevel + 1

				_dump(k, i .. arrowIndent .. "    ")

				currLevel = currLevel - 1
			end
		end
	end

	retstr = "self: \t" .. tostring(t) .. "\n"

	if t ~= nil then
		_dump(t, i)
	end

	return retstr
end

function fulldump(t, level, i)
	io.write(getfulldump(t, level, i))
end

function getdumplocals(dumplevel)
	dumplevel = dumplevel or 1

	local locals = {}

	for i = 1, 256 do
		local k, v = debug.getlocal(2, i)

		if k == nil then
			break
		end

		locals[k] = v
	end

	return getfulldump(locals, dumplevel)
end

function proxywatch(t, keys, mode, use_print)
	local function write_out(msg)
		if use_print then
			print(msg)
		else
			io.write(msg)

			if io.output() == io.stdout then
				io.flush()
			end
		end
	end

	local anyKey = keys == nil

	keys = type(keys) == "table" and keys or {}
	mode = type(mode) == "string" and mode or "rw"

	local keyDict = table.map(keys, function(k, v)
		return v, true
	end)
	local rLog = string.find(mode, "r", 1, true)
	local wLog = string.find(mode, "w", 1, true)
	local tLog = string.find(mode, "t", 1, true)
	local cLog = string.find(mode, "c", 1, true)

	if not rLog and not wLog and not cLog then
		rLog = true
		wLog = true
	end

	local proxy = table.clone(t)

	for k, v in pairs(t) do
		t[k] = nil
	end

	local tmt = getmetatable(t)

	setmetatable(t, proxy)
	setmetatable(proxy, tmt)

	function proxy.__index(t, k)
		local v = proxy[k]

		if rLog and (anyKey or keyDict[k]) then
			local msg = string.format("====== Reading from %s | %s ==> %s", tostring(t), tostring(k), tostring(v))

			if tLog then
				msg = debug.traceback(msg, 2) .. "\n\n"
			end

			write_out(msg)
		end

		return v
	end

	function proxy.__newindex(t, k, v)
		if wLog and (anyKey or keyDict[k]) then
			local msg = string.format("====== Writing to %s | %s <== %s", tostring(t), tostring(k), tostring(v))

			if tLog then
				msg = debug.traceback(msg, 2) .. "\n\n"
			end

			write_out(msg)
		elseif cLog and (anyKey or keyDict[k]) and proxy[k] ~= v then
			local msg = string.format("====== Changing %s | %s <== %s", tostring(t), tostring(k), tostring(v))

			if tLog then
				msg = debug.traceback(msg, 2) .. "\n\n"
			end

			write_out(msg)
		end

		proxy[k] = v
	end

	return proxy
end
