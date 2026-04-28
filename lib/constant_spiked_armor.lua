local ffi = require("ffi")

ffi.cdef[[
typedef struct {
    float value;
    int32_t damage_type;
} constant_spiked_armor;
]]

local constant_spiked_armor_ct = ffi.typeof("constant_spiked_armor")

ffi.metatype(constant_spiked_armor_ct, {
	__index = {
		clone = function(self)
			return constant_spiked_armor_ct(self.value, self.damage_type)
		end
	}
})

---@class constant_spiked_armor
---@field value number = 0
---@field damage_type integer = DAMAGE_PHYSICAL
local constant_spiked_armor = {
	new = constant_spiked_armor_ct,
	ctype = constant_spiked_armor_ct
}

return constant_spiked_armor
