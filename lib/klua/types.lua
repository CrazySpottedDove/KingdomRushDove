-- chunkname: @./lib/klua/types.lua
NULL = setmetatable({}, {
	__index = function(t, k)
		error("Error: trying to access member " .. tostring(k) .. " of NULL value")
		return nil
	end,
	__newindex = function(t, k, v)
		error("Error: trying to set member " .. tostring(k) .. " of NULL value")
	end,
	__tostring = function(s)
		return "NULL"
	end
})
getmetatable(NULL).__metatable = NULL

function enum(enumTable)
	assert(type(enumTable) == "table" and #enumTable > 0, "Error: enum expects an array table with at least one string item")

	for i = 1, #enumTable do
		local it = enumTable[i]
		assert(type(it) == "string", "Error: enum itmes must be strings (" .. type(it) .. " found at position " .. i .. ")")
		assert(not _G[it], "Error: enum redefines symbol '" .. it .. "'")
		enumTable[it] = i
		_G[it] = i
	end

	return enumTable
end
