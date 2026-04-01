local ffi = require("ffi")
ffi.cdef[[
typedef struct {
    float x;
    float y;
} vec2;
]]

local vec2_ct = ffi.typeof("vec2")

--- @class vec2
--- @field x number
--- @field y number
local vec2_constructor = ffi.metatype("vec2", {
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
			return vec2_ct(self.x / length, self.y / length)
		end,
		clone = function(self)
			return vec2_ct(self.x, self.y)
		end,
		set = function(self, x, y)
			self.x = x
			self.y = y
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

local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local function str(x, y)
	return "(" .. tonumber(x) .. "," .. tonumber(y) .. ")"
end

local function mul(s, x, y)
	return s * x, s * y
end

local function div(s, x, y)
	return x / s, y / s
end

local function add(x1, y1, x2, y2)
	return x1 + x2, y1 + y2
end

local function sub(x1, y1, x2, y2)
	return x1 - x2, y1 - y2
end

local function permul(x1, y1, x2, y2)
	return x1 * x2, y1 * y2
end

local function dot(x1, y1, x2, y2)
	return x1 * x2 + y1 * y2
end

local function det(x1, y1, x2, y2)
	return x1 * y2 - y1 * x2
end

local function eq(x1, y1, x2, y2)
	return x1 == x2 and y1 == y2
end

local function lt(x1, y1, x2, y2)
	return x1 < x2 or x1 == x2 and y1 < y2
end

local function le(x1, y1, x2, y2)
	return x1 <= x2 and y1 <= y2
end

local function len2(x, y)
	return x * x + y * y
end

local function len(x, y)
	return sqrt(x * x + y * y)
end

local function fromPolar(angle, radius)
	return cos(angle) * radius, sin(angle) * radius
end

local function toPolar(x, y)
	return atan2(y, x), len(x, y)
end

local function dist2(x1, y1, x2, y2)
	return len2(x1 - x2, y1 - y2)
end

local function dist(x1, y1, x2, y2)
	return len(x1 - x2, y1 - y2)
end

local function normalize(x, y)
	local l = len(x, y)

	if l > 0 then
		return x / l, y / l
	end

	return x, y
end

local function rotate(phi, x, y)
	local c, s = cos(phi), sin(phi)

	return c * x - s * y, s * x + c * y
end

local function perpendicular(x, y)
	return -y, x
end

local function project(x, y, u, v)
	local s = (x * u + y * v) / (u * u + v * v)

	return s * u, s * v
end

local function mirror(x, y, u, v)
	local s = 2 * (x * u + y * v) / (u * u + v * v)

	return s * u - x, s * v - y
end

local function trim(maxLen, x, y)
	local s = maxLen * maxLen / len2(x, y)

	s = s > 1 and 1 or math.sqrt(s)

	return x * s, y * s
end

local function angleTo(x, y, u, v)
	if u and v then
		return atan2(y, x) - atan2(v, u)
	end

	return atan2(y, x)
end

local V = {
	str = str,
	fromPolar = fromPolar,
	toPolar = toPolar,
	mul = mul,
	div = div,
	add = add,
	sub = sub,
	permul = permul,
	dot = dot,
	det = det,
	cross = det,
	eq = eq,
	lt = lt,
	le = le,
	len2 = len2,
	len = len,
	dist2 = dist2,
	dist = dist,
	normalize = normalize,
	rotate = rotate,
	perpendicular = perpendicular,
	project = project,
	mirror = mirror,
	trim = trim,
	angleTo = angleTo
}

function V.v(x, y)
	return vec2_constructor(x, y)
end

function V.vv(x)
	return vec2_constructor(x, x)
end

function V.vclone(vec)
	return vec2_constructor(vec.x, vec.y)
end

function V.r(x, y, w, h)
	return {
		pos = vec2_constructor(x, y),
		size = vec2_constructor(w, h)
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

return V
