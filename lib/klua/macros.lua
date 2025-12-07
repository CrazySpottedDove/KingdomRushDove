-- chunkname: @./lib/klua/macros.lua
local fmod = math.fmod
local pi = math.pi
local twopi = 2 * pi
local pi_2 = pi * 0.5
local pi_4 = pi / 4

local function UNROLL(a)
	return a % twopi
end

local function UNROLL_DEG(a)
	return a % 360
end

local function SIGNED_UNROLL(a)
	return fmod(a, twopi)
end

local function SIGNED_UNROLL_DEG(a)
	return fmod(a, 360)
end

local function SHORT_ANGLE(from, to)
	local diff = UNROLL(to - from)

	if diff == twopi then
		return 0
	elseif diff <= pi then
		return diff
	else
		return fmod(diff, pi) - pi
	end
end

local function SHORT_ANGLE_DEG(from, to)
	local diff = UNROLL_DEG(to - from)

	if diff == 360 then
		return 0
	elseif diff <= 180 then
		return diff
	else
		return fmod(diff, 180) - 180
	end
end

local function CLAMP_SIGNED(min, max, v)
	return v < min and min or max < v and max or v
end

local function CLAMP(a, b, v)
	if a < b then
		return CLAMP_SIGNED(a, b, v)
	else
		return CLAMP_SIGNED(b, a, v)
	end
end

local function ZMOD(value, module)
	return (value - 1) % module + 1
end

local function ROUND(value)
	return math.floor(value + 0.5)
end

local function SIGN(value)
	if value < 0 then
		return -1
	else
		return 1
	end
end

local function RAND_SIGN(prob_positive)
	prob_positive = prob_positive or 0.5
	return prob_positive <= math.random() and 1 or -1
end

local function DEG2RAD(deg)
	return deg * pi / 180
end

local function RAD2DEG(rad)
	return rad * 180 / pi
end

return {
	twopi = twopi,
	pi = pi,
	pi_2 = pi_2,
	pi_4 = pi_4,
	unroll = UNROLL,
	unroll_deg = UNROLL_DEG,
	signed_unroll = SIGNED_UNROLL,
	signed_unroll_deg = SIGNED_UNROLL_DEG,
	short_angle = SHORT_ANGLE,
	short_angle_deg = SHORT_ANGLE_DEG,
	clamp_signed = CLAMP_SIGNED,
	clamp = CLAMP,
	zmod = ZMOD,
	round = ROUND,
	sign = SIGN,
	rand_sign = RAND_SIGN,
	deg2rad = DEG2RAD,
	rad2deg = RAD2DEG
}
