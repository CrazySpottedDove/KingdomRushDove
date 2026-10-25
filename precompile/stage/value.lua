--- 特化期抽象值
local M = {}

local function path_key(path)
	return table.concat(path, ".")
end

function M.const(value, safe, path, nullable)
	return {
		known = true,
		value = value,
		safe = safe == true,
		path = path,
		nullable = nullable == true
	}
end

function M.unknown()
	return {
		known = false
	}
end

function M.child(obj, key, allowed, nullable)
	if not obj.known or type(obj.value) ~= "table" then
		return M.unknown()
	end
	if type(key) ~= "string" and type(key) ~= "number" then
		return M.unknown()
	end

	local path
	if obj.path then
		path = {}
		for i = 1, #obj.path do
			path[i] = obj.path[i]
		end
		path[#path + 1] = key
	end

	local safe = allowed ~= nil and allowed[path_key(path)] == true
	local is_nullable = nullable ~= nil and nullable[path_key(path)] == true

	return M.const(obj.value[key], safe, path, is_nullable)
end

return M
