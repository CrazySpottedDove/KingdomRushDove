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

local v = V.v
local vv = V.vv

-- 这里可以覆盖模板，示例：
-- 修改小公主移动速度
-- T("hero_alleria").motion.max_speed = 3.5 * FPS
-- 拦截范围
-- T("hero_alleria").melee.range = 25
