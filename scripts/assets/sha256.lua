local ffi = require("ffi")

ffi.cdef[[
	unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md);
]]

local lib = ffi.load("crypto")
local M = {}

local function to_hex(raw)
	return (raw:gsub(".", function(c)
		return string.format("%02x", string.byte(c))
	end))
end

function M.hex(raw)
	return to_hex(raw)
end

function M.hash_string(s)
	local out = ffi.new("unsigned char[32]")
	lib.SHA256(ffi.cast("const unsigned char *", s), #s, out)
	return ffi.string(out, 32)
end

function M.hash_file(path)
	local f = assert(io.open(path, "rb"))
	local s = f:read("*a")
	f:close()
	return M.hash_string(s)
end

return M
