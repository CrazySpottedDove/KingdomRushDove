﻿-- chunkname: @./all/screen_utils.lua

local V = require("klua.vector")
local SU = {}

function SU.clamp_window_aspect(w, h, ref_w, ref_h, min_aspect, max_aspect)
	min_aspect = min_aspect or MIN_SCREEN_ASPECT
	max_aspect = max_aspect or MAX_SCREEN_ASPECT

	local sw, sh, scale
	local origin = V.v(0, 0)

	if min_aspect > w / h and ref_w then
		sw = ref_w
		sh = ref_w / min_aspect
		scale = w / ref_w
		origin.y = (h - sh * scale) / 2
	else
		sw = ref_h * (w / h)
		sh = ref_h
		scale = h / ref_h

		if max_aspect < sw / sh then
			sw = sh * max_aspect
			origin.x = (w - sw * scale) / 2
		end
	end

	return sw, sh, scale, origin
end

function SU.remove_references(screen, klass)
	for k, v in pairs(screen) do
		if v and type(v) == "table" and v.isInstanceOf and v:isInstanceOf(klass) then
			screen[k] = nil
		end
	end
end

function SU.get_safe_frame(w, h, ref_w, ref_h)
	if KR_TARGET == "phone" and KR_PLATFORM == "android" then
		local jnia = require("jni_android")
		local sa = jnia.get_system_property("SAFE_AREA")

		if sa and sa ~= "" then
			local r, t, l, b = unpack(string.split(sa, ","))

			f = ref_h / h

			local lr = math.max(l, r) * f
			local tb = math.max(t, b) * f

			return {
				t = tb,
				b = tb,
				l = lr,
				r = lr
			}
		end
	end

	local a = w / h

	for _, v in pairs(SAFE_FRAME_STEPS) do
		if a >= v[1] then
			return v[2]
		end
	end

	return SAFE_FRAME_STEPS[#SAFE_FRAME_STEPS][2]
end

function SU.get_hud_scale(w, h, ref_w, ref_h)
	local a = w / h

	for _, v in pairs(HUD_SCALE_STEPS) do
		if a >= v[1] then
			return v[2]
		end
	end

	return HUD_SCALE_STEPS[#HUD_SCALE_STEPS][2]
end

return SU
