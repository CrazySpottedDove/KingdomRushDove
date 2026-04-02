local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    int pi;
    int spi;
    int ni;
    int dir;
} nav_path;
]]

local nav_path_ct = ffi.typeof("nav_path")
--- @class nav_path
--- @field pi integer = 1
--- @field spi integer = 1
--- @field ni integer = 1
--- @field dir integer = 1
local nav_path_constructor = ffi.metatype(nav_path_ct, {
	__index = {
		clone = function(self)
			return nav_path_ct(self.pi, self.spi, self.ni, self.dir)
		end
	}
})

return nav_path_constructor
