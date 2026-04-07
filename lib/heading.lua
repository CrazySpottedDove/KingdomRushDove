local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    double angle;
} heading;
]]

local heading_ct = ffi.typeof("heading")

--- @class heading
--- @field angle number = 0
local heading_constructor = ffi.metatype(heading_ct, {
	__index = {
		clone = function(self)
			return heading_ct(self.angle)
		end
	}
})

return heading_constructor
