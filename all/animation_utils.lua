-- 旨在减少运行时动画函数的分支，为 Utils 中动画相关方法的特化。在性能热点的函数中使用，新代码也建议使用本模块代替原有的 Utils 中动画相关方法。

local AU = {}
local U = require("utils")
local P = require("path_db")
local km = require("lib.klua.macros")

function AU.animation_name_facing_point_use_path_and_offset(e, group, point, idx, offset)
	local npos = P:node_pos_ref(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
	return U.animation_name_for_angle(e, group, km.unroll(math.atan2(point.y - offset.y - npos.y, point.x - offset.x - npos.x)))
end

function AU.animation_name_facing_point_use_path(e, group, point, idx)
	local npos = P:node_pos_ref(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni)
	return U.animation_name_for_angle(e, group, km.unroll(math.atan2(point.y - npos.y, point.x - npos.x)))
end

function AU.animation_name_facing_point_use_offset(e, group, point, idx, offset)
	return U.animation_name_for_angle(e, group, km.unroll(math.atan2(point.y - offset.y - e.y, point.x - offset.x - e.x)))
end

function AU.animation_name_facing_point(e, group, point, idx)
	return U.animation_name_for_angle(e, group, km.unroll(math.atan2(point.y - e.y, point.x - e.x)))
end

return AU
