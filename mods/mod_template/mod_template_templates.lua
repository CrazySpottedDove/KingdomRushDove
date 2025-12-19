local scripts = require("scripts")
local i18n = require("i18n")
local tt, balance
local anchor_x, anchor_y = 0, 0
local image_x, image_y = 0, 0

local function adx(v)
	return v - anchor_x * image_x
end

local function ady(v)
	return v - anchor_y * image_y
end

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

local function vv(v1)
	return {
		x = v1,
		y = v1
	}
end
