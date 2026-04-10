local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    float angle;
} heading;
]]

local heading_ct = ffi.typeof("heading")

--- @class heading
--- @field angle number = 0
ffi.metatype(heading_ct, {
	__index = {
		clone = function(self)
			return heading_ct(self.angle)
		end
	}
})

local heading = {
	new = heading_ct,
	ctype = heading_ct
}

return heading
