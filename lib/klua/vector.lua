-- chunkname: @./lib/klua/vector.lua
local V = require("lib.hump.vector-light")

local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    double x;
    double y;
} vec2;
]]

local vec2_ct = ffi.typeof("vec2")

--- @class vec2
--- @field x number
--- @field y number
ffi.metatype("vec2", {
	__index = {
		len2 = function(self)
			return self.x * self.x + self.y * self.y
		end,
		len = function(self)
			return math.sqrt(self.x * self.x + self.y * self.y)
		end,
		-- 不检查零向量，请调用者保证。
		normalize = function(self)
			local length = math.sqrt(self.x * self.x + self.y * self.y)
			self.x = self.x / length
			self.y = self.y / length
		end,
		clone = function(self)
			return vec2_ct(self.x, self.y)
		end,
		set = function(self, x, y)
			self.x = x
			self.y = y
		end,
		copy = function(self, other)
			self.x = other.x
			self.y = other.y
		end,
		dist = function(self, other)
			local dx = self.x - other.x
			local dy = self.y - other.y
			return math.sqrt(dx * dx + dy * dy)
		end,
		dist2 = function(self, other)
			local dx = self.x - other.x
			local dy = self.y - other.y
			return dx * dx + dy * dy
		end,
		-- 就地使用向量加法
		add = function(self, other)
			self.x = self.x + other.x
			self.y = self.y + other.y
		end,
		-- 就地使用向量减法
		sub = function(self, other)
			self.x = self.x - other.x
			self.y = self.y - other.y
		end,
		-- 就地使用标量乘法
		scalar_mul = function(self, scalar)
			self.x = self.x * scalar
			self.y = self.y * scalar
		end,
		-- 就地使用标量除法
		scalar_div = function(self, scalar)
			self.x = self.x / scalar
			self.y = self.y / scalar
		end,
		-- 就地使用标量加法
		scalar_add = function(self, x, y)
			self.x = self.x + x
			self.y = self.y + y
		end,
		-- 就地使用标量减法
		scalar_sub = function(self, x, y)
			self.x = self.x - x
			self.y = self.y - y
		end
	},
	-- 返回新的向量
	__add = function(a, b)
		return vec2_ct(a.x + b.x, a.y + b.y)
	end,
	__sub = function(a, b)
		return vec2_ct(a.x - b.x, a.y - b.y)
	end
})

V.v = vec2_ct

function V.vv(x)
	return vec2_ct(x, x)
end

function V.vclone(vec)
	return vec2_ct(vec.x, vec.y)
end

function V.r(x, y, w, h)
	return {
		pos = vec2_ct(x, y),
		size = vec2_ct(w, h)
	}
end

function V.veq(v1, v2)
	return v1.x == v2.x and v1.y == v2.y
end

function V.v2c(v)
	return math.ceil(v.x - 0.5), math.ceil(v.y - 0.5)
end

function V.vsnap(v)
	return V.v(math.ceil(v.x - 0.5), math.ceil(v.y - 0.5))
end

function V.csnap(x, y)
	return math.ceil(x - 0.5), math.ceil(y - 0.5)
end

function V.is_inside(p, r)
	return p.x >= r.pos.x and p.x <= r.pos.x + r.size.x and p.y >= r.pos.y and p.y <= r.pos.y + r.size.y
end

function V.overlap(r1, r2)
	if r1.pos.x > r2.pos.x + r2.size.x or r2.pos.x > r1.pos.x + r1.size.x or r1.pos.y > r2.pos.y + r2.size.y or r2.pos.y > r1.pos.y + r1.size.y then
		return false
	end

	return true
end

V.metatype = vec2_ct

return V
