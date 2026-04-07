local ffi = require("ffi")
local V = require("lib.klua.vector")
local FFIPool = require("lib.ffi_pool")

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
local nav_rally_pool = FFIPool:new("nav_rally", 4096)

local function nav_rally_constructor(pos, center, immune_to, requires_node_nearby, is_new)
	local r = nav_rally_pool:alloc()
	r.pos = pos
	r.center = center
	r.immune_to = immune_to
	r.requires_node_nearby = requires_node_nearby
	r.new = is_new

	return r
end

--- @class nav_rally
--- @field pos vec2
--- @field center vec2
--- @field immune_to integer = band(DAMAGE_ALL_TYPES, bnot(DAMAGE_POISON))
--- @field requires_node_nearby boolean = true
--- @field new boolean = false
ffi.metatype("nav_rally", {
	__index = {
		clone = function(self)
			return nav_rally_constructor(self.pos, self.center, self.immune_to, self.requires_node_nearby, self.new)
		end
	}
})

local nav_rally = {
	new = nav_rally_constructor,
	pool = nav_rally_pool,
	ctype = nav_rally_ct
}

return nav_rally
