-- chunkname: @./lib/hump/vector-light.lua
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

return {
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
