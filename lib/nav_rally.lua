local ffi = require("ffi")
local V = require("lib.klua.vector")

ffi.cdef[[
typedef struct {
    vec2 pos;
    vec2 center;
    int immune_to;
    bool requires_node_nearby;
    bool new;
} nav_rally;
]]

local nav_rally_ct = ffi.typeof("nav_rally")

--- @class nav_rally
--- @field pos vec2
--- @field center vec2
--- @field immune_to integer = band(DAMAGE_ALL_TYPES, bnot(DAMAGE_POISON))
--- @field requires_node_nearby boolean = true
--- @field new boolean = false
local nav_rally_constructor = ffi.metatype("nav_rally", {
	__index = {
		clone = function(self)
			return nav_rally_ct(self.pos, self.center, self.immune_to, self.requires_node_nearby, self.new)
		end
	}
})

return nav_rally_constructor
