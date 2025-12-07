-- chunkname: @./lib/hump/vector.lua
local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2
local vector = {}
vector.__index = vector

local function new(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0
	}, vector)
end

local zero = new(0, 0)

local function fromPolar(angle, radius)
	return new(cos(angle) * radius, sin(angle) * radius)
end

local function isvector(v)
	return type(v) == "table" and type(v.x) == "number" and type(v.y) == "number"
end

function vector:clone()
	return new(self.x, self.y)
end

function vector:unpack()
	return self.x, self.y
end

function vector:__tostring()
	return "(" .. tonumber(self.x) .. "," .. tonumber(self.y) .. ")"
end

function vector.__unm(a)
	return new(-a.x, -a.y)
end

function vector.__add(a, b)
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return new(a.x + b.x, a.y + b.y)
end

function vector.__sub(a, b)
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
	return new(a.x - b.x, a.y - b.y)
end

function vector.__mul(a, b)
	if type(a) == "number" then
		return new(a * b.x, a * b.y)
	elseif type(b) == "number" then
		return new(b * a.x, b * a.y)
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return a.x * b.x + a.y * b.y
	end
end

function vector.__div(a, b)
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return new(a.x / b, a.y / b)
end

function vector.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

function vector.__lt(a, b)
	return a.x < b.x or a.x == b.x and a.y < b.y
end

function vector.__le(a, b)
	return a.x <= b.x and a.y <= b.y
end

function vector.permul(a, b)
	assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
	return new(a.x * b.x, a.y * b.y)
end

function vector:toPolar()
	return new(atan2(self.x, self.y), self:len())
end

function vector:len2()
	return self.x * self.x + self.y * self.y
end

function vector:len()
	return sqrt(self.x * self.x + self.y * self.y)
end

function vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

function vector.dist2(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	return dx * dx + dy * dy
end

function vector:normalizeInplace()
	local l = self:len()

	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end

	return self
end

function vector:normalized()
	return self:clone():normalizeInplace()
end

function vector:rotateInplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function vector:rotated(phi)
	local c, s = cos(phi), sin(phi)
	return new(c * self.x - s * self.y, s * self.x + c * self.y)
end

function vector:perpendicular()
	return new(-self.y, self.x)
end

function vector:projectOn(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	local s = (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x, s * v.y)
end

function vector:mirrorOn(v)
	assert(isvector(v), "invalid argument: cannot mirror vector on " .. type(v))
	local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x - self.x, s * v.y - self.y)
end

function vector:cross(v)
	assert(isvector(v), "cross: wrong argument types (<vector> expected)")
	return self.x * v.y - self.y * v.x
end

function vector:trimInplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = s > 1 and 1 or math.sqrt(s)
	self.x, self.y = self.x * s, self.y * s
	return self
end

function vector:angleTo(other)
	if other then
		return atan2(self.y, self.x) - atan2(other.y, other.x)
	end

	return atan2(self.y, self.x)
end

function vector:trimmed(maxLen)
	return self:clone():trimInplace(maxLen)
end

return setmetatable({
	new = new,
	fromPolar = fromPolar,
	isvector = isvector,
	zero = zero
}, {
	__call = function(_, ...)
		return new(...)
	end
})
