local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    double duration;
    double runs;
    int sprite_id;
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
---@field duration number = 1e99
---@field runs integer = 1(定义为 double，语义上为 int，因为很多地方使用了 1e+99 给它赋值，如为 int 会导致数值溢出)
---@field sprite_id integer = 1
local timed = {
	new = timed_ct,
	ctype = timed_ct
}

return timed
