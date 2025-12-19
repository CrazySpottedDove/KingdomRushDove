-- chunkname: @./lib/klove/utf8_string.lua
local mappings = require("klove.utf8_tables")
local utf8 = require("utf8")

function upper(s)
	if not s or utf8.len(s) == 0 then
		return s
	end

	local out = ""

	for p, c in utf8.codes(s) do
		local mc = mappings.upper[c]

		out = out .. utf8.char(mc or c)
	end

	return out
end

return {
	upper = upper
}
