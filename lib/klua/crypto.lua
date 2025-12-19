-- chunkname: @./lib/klua/crypto.lua
local success, ffi = pcall(require, "ffi")

ffi = success and ffi or nil

if ffi then
	local bit = require("bit")
	local two32 = 4294967296
	local oneLong = ffi.new("uint64_t", 1)

	function fnv1a(str)
		local FNV_offset_basis = 2166136261
		local FNV_prime = 16777619
		local hash = FNV_offset_basis

		for i = 1, str:len() do
			local octet = str:byte(i)
			local xored = bit.bxor(hash, octet)
			local timesprime = oneLong * xored * FNV_prime

			hash = tonumber(timesprime % two32)
		end

		return hash
	end
end
