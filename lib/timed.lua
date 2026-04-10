local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    float duration;
    int runs;
    int16_t sprite_id;
} timed;
]]

local timed_ct = ffi.typeof("timed")

ffi.metatype(timed_ct, {
	__index = {
		clone = function(self)
			return timed_ct(self.duration, self.runs, self.sprite_id)
		end
	}
})

---@class timed
---@field duration number = FLOAT_MAX
---@field runs integer = 1(请使用 INT_32_MAX 来表示无限次，1e99 将导致数值溢出)
---@field sprite_id integer = 1
local timed = {
	new = timed_ct,
	ctype = timed_ct
}

return timed
