-- chunkname: @./lib/klua/vector.lua
local V = require("hump.vector-light")

function V.v(vx, vy)
	return {
		x = vx or 0,
		y = vy or 0
	}
end

function V.vv(vx)
	return {
		x = vx or 0,
		y = vx or 0
	}
end

function V.vclone(v)
	return {
		x = v.x,
		y = v.y
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

function V.r(x, y, w, h)
	return {
		pos = V.v(x, y),
		size = V.v(w, h)
	}
end

function V.rclone(r)
	return {
		pos = {r.pos.x, r.pos.y},
		size = {r.size.x, r.size.y}
	}
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
