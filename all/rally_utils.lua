local rally_utils = {}
local signal = require("lib.hump.signal")
local U = require("utils")
local S = require("sound_db")
local V = require("lib.klua.vector")
local P = require("path_db")
local GR = require("grid_db")

--- 默认的调集方法
---@param this table 拥有 barrack 的实体
---@param store table
---@param force_silent boolean 无声调集
function rally_utils.rally_fn_default(this, store, force_silent)
	signal.emit("rally-point-changed", this)
	local b = this.barrack
	local all_dead = true
	local sounds = {}
	local soldier_count = this.mercenary and #b.soldiers or b.max_soldiers
	for i = 1, soldier_count do
		local s = b.soldiers[i]
		if s then
			if b.scattered then
				s.nav_rally.pos = U.rally_formation_position(i, b, soldier_count, b.rally_angle_offset)
				s.nav_rally.center:copy(s.nav_rally.pos)
			else
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, soldier_count, b.rally_angle_offset)
			end
			s.nav_rally.new = true
			all_dead = all_dead and (s.health and s.health.dead)
			if s.sound_events and s.sound_events.change_rally_point then
				sounds[#sounds + 1] = s.sound_events.change_rally_point
			end
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

--- 计算一组可调集单位的集结点。
--- 先找离落点最近的路径并用其前后节点确定走向，再在落点周围摆成圆形：
--- 最靠近 ni 小方向的位置优先站没有 ranged 组件的单位，其次站生命值更高的单位。
---@param units table 可调集单位列表（顺序不限）
---@param x number 落点 x 坐标
---@param y number 落点 y 坐标
---@return table 列表，元素为 {实体, 集结点, 寻路结果}
function rally_utils.group_rally_formation(units, x, y)
	local count = #units
	local result = {}

	if count == 0 then
		return result
	end

	-- 最近路径的走向：dir 指向 ni 增大的方向
	local dir_x, dir_y = 0, 1
	local nearest = P:nearest_nodes(x, y, nil, nil, true)

	if nearest and nearest[1] then
		local pi, spi, ni = nearest[1][1], nearest[1][2], nearest[1][3]
		local prev = P:node_pos_ref(pi, spi, ni - 1)
		local next_ = P:node_pos_ref(pi, spi, ni + 1)
		local dx, dy = next_.x - prev.x, next_.y - prev.y
		local len = math.sqrt(dx * dx + dy * dy)

		if len > 0.0001 then
			dir_x, dir_y = dx / len, dy / len
		end
	end

	local ordered = {}

	for i = 1, count do
		ordered[i] = units[i]
	end

	table.sort(ordered, function(a, b)
		local a_ranged = a.ranged and true or false
		local b_ranged = b.ranged and true or false

		if a_ranged ~= b_ranged then
			return not a_ranged
		end

		local a_hp = a.health and a.health.hp or 0
		local b_hp = b.health and b.health.hp or 0

		if a_hp ~= b_hp then
			return a_hp > b_hp
		end

		-- 位置与模板名可跨重演稳定复现（不要用 entity.id）
		local a_name, b_name = a.template_name or "", b.template_name or ""

		if a_name ~= b_name then
			return a_name < b_name
		end

		if a.pos and b.pos then
			if a.pos.x ~= b.pos.x then
				return a.pos.x < b.pos.x
			end

			if a.pos.y ~= b.pos.y then
				return a.pos.y < b.pos.y
			end
		end

		return false
	end)

	-- 圆形站位：最靠近 ni 小方向的位置（front）由优先级最高的单位站，
	-- 其余单位左右交替展开，离 front 越近的排位越靠前，整体仍是一个圆。
	local front_angle = math.atan2(-dir_y, -dir_x)
	local step = 2 * math.pi / count
	local b = 15
	local a = b * math.sqrt(math.log(1 + count) + 1)

	for i, e in ipairs(ordered) do
		local angle_offset = 0

		if i > 1 then
			local k = math.floor(i * 0.5)

			angle_offset = (i % 2 == 0 and k or -k) * step
		end

		-- local angle = front_angle + angle_offset
		local ring_pos = V.v(x + a * math.cos(angle_offset) * math.cos(front_angle) - b * math.sin(angle_offset) * math.sin(front_angle), y + a * math.cos(angle_offset) * math.sin(front_angle) + b * math.sin(angle_offset) * math.cos(front_angle))

		-- 圆形站位若不可站立，退回到落点中心再试一次
		for _, pos in ipairs({ring_pos, V.v(x, y)}) do

			if GR:cell_is_only(pos.x, pos.y, e.nav_grid.valid_terrains_dest) then
				local waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, pos, e.nav_grid.valid_terrains)

				if waypoints then
					result[#result + 1] = {e, pos, waypoints}
					break
				end
			end
		end
	end

	return result
end

--- 把 group_rally_formation 算出的集结点应用到单位上
---@param units table 可调集单位列表
---@param x number 落点 x 坐标
---@param y number 落点 y 坐标
function rally_utils.apply_group_rally(units, x, y)
	for _, item in ipairs(rally_utils.group_rally_formation(units, x, y)) do
		local e = item[1]

		e.nav_grid.waypoints = item[3]
		e.nav_rally.new = true
		e.nav_rally.pos = item[2]
		e.nav_rally.center = item[2]
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
