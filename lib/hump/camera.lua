-- chunkname: @./lib/hump/camera.lua
local _PATH = (...):match("^(.*[%./])[^%.%/]+$") or ""
local cos, sin = math.cos, math.sin
local camera = {}
camera.__index = camera
camera.smooth = {}

function camera.smooth.none()
	return function(dx, dy)
		return dx, dy
	end
end

function camera.smooth.linear(speed)
	assert(type(speed) == "number", "Invalid parameter: speed = " .. tostring(speed))
	return function(dx, dy, s)
		local d = math.sqrt(dx * dx + dy * dy)
		local dts = math.min((s or speed) * love.timer.getDelta(), d)

		if d > 0 then
			dx, dy = dx / d, dy / d
		end

		return dx * dts, dy * dts
	end
end

function camera.smooth.damped(stiffness)
	assert(type(stiffness) == "number", "Invalid parameter: stiffness = " .. tostring(stiffness))
	return function(dx, dy, s)
		local dts = love.timer.getDelta() * (s or stiffness)
		return dx * dts, dy * dts
	end
end

local function new(x, y, zoom, rot, smoother)
	x, y = x or love.graphics.getWidth() * 0.5, y or love.graphics.getHeight() * 0.5
	zoom = zoom or 1
	rot = rot or 0
	smoother = smoother or camera.smooth.none()
	return setmetatable({
		x = x,
		y = y,
		scale = zoom,
		rot = rot,
		smoother = smoother
	}, camera)
end

function camera:lookAt(x, y)
	self.x, self.y = x, y
	return self
end

function camera:move(dx, dy)
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function camera:position()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi)
	self.rot = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach(x, y, w, h, noclip)
	x, y = x or 0, y or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
	self._sx, self._sy, self._sw, self._sh = love.graphics.getScissor()

	if not noclip then
		love.graphics.setScissor(x, y, w, h)
	end

	local cx, cy = x + w * 0.5, y + h * 0.5
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.scale(self.scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
	love.graphics.setScissor(self._sx, self._sy, self._sw, self._sh)
end

function camera:draw(...)
	local x, y, w, h, noclip, func
	local nargs = select("#", ...)

	if nargs == 1 then
		func = ...
	elseif nargs == 5 then
		x, y, w, h, func = ...
	elseif nargs == 6 then
		x, y, w, h, noclip, func = ...
	else
		error("Invalid arguments to camera:draw()")
	end

	self:attach(x, y, w, h, noclip)
	func()
	self:detach()
end

function camera:cameraCoords(x, y, ox, oy, w, h)
	ox, oy = ox or 0, oy or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
	local c, s = cos(self.rot), sin(self.rot)
	x, y = x - self.x, y - self.y
	x, y = c * x - s * y, s * x + c * y
	return x * self.scale + w * 0.5 + ox, y * self.scale + h * 0.5 + oy
end

function camera:worldCoords(x, y, ox, oy, w, h)
	ox, oy = ox or 0, oy or 0
	w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
	local c, s = cos(-self.rot), sin(-self.rot)
	x, y = (x - w * 0.5 - ox) / self.scale, (y - h * 0.5 - oy) / self.scale
	x, y = c * x - s * y, s * x + c * y
	return x + self.x, y + self.y
end

function camera:mousePosition(ox, oy, w, h)
	local mx, my = love.mouse.getPosition()
	return self:worldCoords(mx, my, ox, oy, w, h)
end

function camera:lockX(x, smoother, ...)
	local dx, dy = (smoother or self.smoother)(x - self.x, self.y, ...)
	self.x = self.x + dx
	return self
end

function camera:lockY(y, smoother, ...)
	local dx, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
	self.y = self.y + dy
	return self
end

function camera:lockPosition(x, y, smoother, ...)
	return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

function camera:lockWindow(x, y, x_min, x_max, y_min, y_max, smoother, ...)
	x, y = self:cameraCoords(x, y)
	local dx, dy = 0, 0

	if x < x_min then
		dx = x - x_min
	elseif x_max < x then
		dx = x - x_max
	end

	if y < y_min then
		dy = y - y_min
	elseif y_max < y then
		dy = y - y_max
	end

	local c, s = cos(-self.rot), sin(-self.rot)
	dx, dy = (c * dx - s * dy) / self.scale, (s * dx + c * dy) / self.scale
	self:move((smoother or self.smoother)(dx, dy, ...))
end

return setmetatable({
	new = new,
	smooth = camera.smooth
}, {
	__call = function(_, ...)
		return new(...)
	end
})
