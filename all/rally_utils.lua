local rally_utils = {}
local signal = require("lib.hump.signal")
local U = require("utils")
local S = require("sound_db")

--- 默认的调集方法
---@param this table 拥有 barrack 的实体
---@param store table
---@param force_silent boolean 无声调集
function rally_utils.rally_fn_default(this, store, force_silent)
	signal.emit("rally-point-changed", this)
	local b = this.barrack
	local all_dead = true
	local sounds = {}
	for i = 1, #b.soldiers do
		local s = b.soldiers[i]
		if b.scattered then
			s.nav_rally.pos = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			s.nav_rally.center:copy(s.nav_rally.pos)
		else
			s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
		end
		s.nav_rally.new = true
		all_dead = all_dead and (s.health and s.health.dead)
		if s.sound_events and s.sound_events.change_rally_point then
			sounds[#sounds + 1] = s.sound_events.change_rally_point
		end
	end
	if not (all_dead or force_silent) then
		if #sounds > 0 then
			S:queue(sounds[math.random(1, #sounds)])
		else
			S:queue(this.sound_events.change_rally_point)
		end
	end
end

--- 发起调集指令
---@param entity table 拥有 barrack 的实体
---@param store table
---@param x number 调集目标 x 坐标
---@param y number 调集目标 y 坐标
---@param force_silent boolean 无声调集
function rally_utils.fire_rally_fn(entity, store, x, y, force_silent)
	local b = entity.barrack
	b.rally_pos:set(x, y)

	-- 如果实体存在 rally_fn，则调用实体的 rally_fn
	if b.rally_fn then
		b.rally_fn(entity, store, force_silent)
	-- 兼容老写法，设置 rally_new 标志来通知实体
	else
		b.rally_new = true
	end
end

return rally_utils
