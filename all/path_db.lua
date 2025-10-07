-- chunkname: @./all/path_db.lua

local bit = require("bit")
local log = require("klua.log"):new("path_db")
local km = require("klua.macros")
local FS = love.filesystem

require("klua.table")

local V = require("klua.vector")
local GR = require("grid_db")
local serpent = require("serpent")
local path_db = {}

path_db.path_end_margin = 10
path_db.path_valid_margin = 1
path_db.path_valid_margin_top = 2
path_db.average_node_dist = 6

function path_db:load(name, visible_coords)
	self.paths = {}
	self.path_connections = {}
	self.path_start_node = {}
	self.path_end_node = {}
	self.visible_path_start_node = {}
	self.visible_path_end_node = {}
	self.terrains = {}
	self.terrain_props = {}
	self.active_paths = {}
	self.invalid_ranges = {}
	self.path_widths = {}
	self.defend_point_node = {}
	self.path_curves = {}

	local path_list
	local fn = KR_PATH_GAME .. "/data/levels/" .. name .. "_paths.lua"

	if not love.filesystem.isFile(fn) then
		log.debug("Level paths file does not exist for %s", fn)

		path_list = {
			connections = {},
			paths = {},
			active = {},
			curves = {}
		}
	else
		local f, err = love.filesystem.load(fn)

		if err then
			log.error("Error loading paths for %s: %s", fn, err)

			return nil
		end

		path_list = f()
	end

	for i, p in ipairs(path_list.paths) do
		if path_list.active and path_list.active[i] == false then
			self.active_paths[i] = false
		else
			self.active_paths[i] = true
		end

		self.invalid_ranges[i] = {}
	end

	self.paths = table.merge(self.paths, path_list.paths)
	self.path_connections = table.merge(self.path_connections, path_list.connections)

	if path_list.curves then
		self.path_curves = table.merge(self.path_curves, path_list.curves)
	end

	for i, p in ipairs(self.paths) do
		local terrain_types = TERRAIN_NONE
		local sp = p[1]

		for _, o in pairs(sp) do
			local cell_type = GR:cell_type(o.x, o.y)

			terrain_types = bit.bor(terrain_types, cell_type)
		end

		self.terrains[i] = bit.band(terrain_types, TERRAIN_TYPES_MASK)
		self.terrain_props[i] = bit.band(terrain_types, TERRAIN_PROPS_MASK)
	end

	if visible_coords then
		local vc = visible_coords

		for j, p in ipairs(self.paths) do
			local ni_in = 1
			local ni_out = #p[1]

			for i = 1, #p[1] do
				local n = p[1][i]

				if n.x >= vc.left and n.x <= vc.right and n.y >= vc.bottom and n.y <= vc.top then
					ni_in = i

					break
				end
			end

			for i = ni_in, #p[1] do
				local n = p[1][i]

				if n.x < vc.left or n.x > vc.right or n.y < vc.bottom or n.y > vc.top then
					ni_out = i

					break
				end
			end

			local offset = self.path_end_margin

			self:set_start_node(j, km.clamp(1, #p[1], ni_in - offset))
			self:set_end_node(j, km.clamp(1, #p[1], ni_out + offset))

			local visible_start = ni_in == 1
			local visible_end = ni_out == #p[1]
			local margin_start = p[1][1].y > REF_H and self.path_valid_margin_top or self.path_valid_margin
			local margin_end = p[1][#p[1]].y > REF_H and self.path_valid_margin_top or self.path_valid_margin

			self:set_visible_start_node(j, km.clamp(1, #p[1], ni_in + (visible_start and 0 or margin_start)))
			self:set_visible_end_node(j, km.clamp(1, #p[1], ni_out - (visible_end and 0 or margin_end)))
		end
	end
end

function path_db:reverse_all_paths()
    if not self.paths then
        return
    end
    for i, path_group in ipairs(self.paths) do
        for j, subpath in ipairs(path_group) do
            if type(subpath) == "table" then
                local n = #subpath
                for k = 1, math.floor(n * 0.5) do
                    subpath[k], subpath[n - k + 1] = subpath[n - k + 1], subpath[k]
                end
            end
        end
    end
end

function path_db:path(index, subindex)
	subindex = subindex or 1

	return self.paths[index][subindex]
end

function path_db:path_width(index, subindex, nodeindex)
	return self.path_widths[index] or 42
end

function path_db:set_path_width(pi, value)
	self.path_widths[pi] = value
end

function path_db:node_pos(p1, p2, p3, return_ref)
	local pi, spi, ni

	if type(p1) == "table" then
		pi, spi, ni = p1.pi, p1.spi, p1.ni
	else
		pi, spi, ni = p1, p2, p3
	end

	local path = self.paths[pi][spi]

	ni = km.clamp(1, #path, ni)

	if return_ref then
		return path[ni]
	else
		return V.vclone(path[ni])
	end
end

function path_db:node_offset_pos(offset, p1, p2, p3)
	local pi, spi, ni

	if type(p1) == "table" then
		pi, spi, ni = p1.pi, p1.spi, p1.ni
	else
		pi, spi, ni = p1, p2, p3
	end

	ni = km.clamp(1, #self.paths[pi][spi], ni)

	local o = self.paths[pi][spi][ni]
	local v1 = self.paths[pi][3][ni]
	local v2 = self.paths[pi][2][ni]

	return V.v(V.add(o.x, o.y, V.mul(offset, V.normalize(v2.x - v1.x, v2.y - v1.y))))
end

function path_db:set_visible_start_node(pi, ni)
	self.visible_path_start_node[pi] = ni
end

function path_db:set_visible_end_node(pi, node)
	self.visible_path_end_node[pi] = node
end

function path_db:get_visible_start_node(pi)
	local ni = self.visible_path_start_node[pi]

	ni = ni or 1

	return ni
end

function path_db:get_visible_end_node(pi)
	local ni = self.visible_path_end_node[pi]

	ni = ni or #self.paths[pi]

	return ni
end

function path_db:set_start_node(pi, ni)
	self.path_start_node[pi] = ni
end

function path_db:set_end_node(pi, node)
	self.path_end_node[pi] = node
end

function path_db:get_start_node(pi)
	local ni = self.path_start_node[pi]

	ni = ni or 1

	return ni
end

function path_db:get_end_node(pi)
	local ni = self.path_end_node[pi]

	ni = ni or #self.paths[pi]

	return ni
end

function path_db:nodes_from_start(p1, p2, p3)
	local pi, spi, ni

	if type(p1) == "table" then
		pi, spi, ni = p1.pi, p1.spi, p1.ni
	else
		pi, spi, ni = p1, p2, p3
	end

	return ni - self:get_start_node(pi)
end

function path_db:nodes_to_goal(p1, p2, p3)
	local pi, spi, ni

	if type(p1) == "table" then
		pi, spi, ni = p1.pi, p1.spi, p1.ni
	else
		pi, spi, ni = p1, p2, p3
	end

	local cpi = pi
	local count = -ni

	::label_16_0::

	count = count + self.path_end_node[cpi]

	if self.path_connections[cpi] then
		cpi = self.path_connections[cpi]

		goto label_16_0
	end

	return count, cpi
end

function path_db:get_defend_point_node(pi)
	return self.defend_point_node[pi]
end

function path_db:set_defend_point_node(pi, ni)
	self.defend_point_node[pi] = ni
end

function path_db:nodes_to_defend_point(p1, p2, p3)
	local pi, spi, ni

	if type(p1) == "table" then
		pi, spi, ni = p1.pi, p1.spi, p1.ni
	else
		pi, spi, ni = p1, p2, p3
	end

	local ntg, lpi = self:nodes_to_goal(pi, spi, ni)
	local dn = self:get_defend_point_node(lpi)

	if not dn then
		return ntg
	else
		local dntg = self:nodes_to_goal(lpi, spi, dn)

		return ntg - dntg
	end
end

function path_db:point_within_distance(x, y, dist)
	for _, p in pairs(self.paths) do
		local sp = p[1]

		for _, o in pairs(sp) do
			if dist > V.dist(o.x, o.y, x, y) then
				return true
			end
		end
	end

	return false
end

--- 查找距离指定点 (x, y) 最近的路径节点列表（可筛选路径、子路径、有效性等）。
---@param x number 目标点的x坐标
---@param y number 目标点的y坐标
---@param path_indexes table|nil 可选，只在这些路径索引中查找（如 {1,2,3}），nil表示全部路径
---@param subpath_indexes table|nil 可选，只在这些子路径索引中查找（如 {1,2,3}），nil表示只查找第1条子路径
---@param valid_only boolean|nil 可选，true时只查找激活且有效的路径节点
---@param flags number|nil 可选，节点有效性判定时用到的标志位
---@return table nodes 按距离升序排列的最近节点列表，每个元素为 {pi, spi, ni, dist}
function path_db:nearest_nodes(x, y, path_indexes, subpath_indexes, valid_only, flags)
	local nodes = {}

	for pi = 1, #self.paths do
		if path_indexes and not table.contains(path_indexes, pi) then
			-- block empty
		else
			subpath_indexes = subpath_indexes or {
				1
			}

			if valid_only and not self:is_path_active(pi) then
				-- block empty
			else
				local n_dist = 9e+99
				local n_ni, n_spi

				for _, spi in pairs(subpath_indexes) do
					local nodes = self.paths[pi][spi]

					for ni = 1, #nodes do
						local o = nodes[ni]
						local dist = V.dist(o.x, o.y, x, y)

						if dist < n_dist and (not valid_only or self:is_node_valid(pi, ni, flags)) then
							n_dist = dist
							n_ni = ni
							n_spi = spi
						end
					end
				end

				if not n_ni then
					log.debug("nearest node is nil for path %s", pi)
				else
					table.insert(nodes, {
						pi,
						n_spi,
						n_ni,
						n_dist
					})
				end
			end
		end
	end

	table.sort(nodes, function(n1, n2)
		return n1[4] < n2[4]
	end)

	return nodes
end

function path_db:path_terrain_types(index)
	return self.terrains[index]
end

function path_db:path_terrain_props(index)
	return self.terrain_props[index]
end

function path_db:activate_path(index)
	self.active_paths[index] = true
end

function path_db:deactivate_path(index)
	self.active_paths[index] = false
end

function path_db:is_path_active(index)
	return self.active_paths[index]
end

function path_db:add_invalid_range(index, from, to, flags)
	from = from or 1
	to = to or self:get_end_node(index)
	flags = flags or NF_ALL

	table.insert(self.invalid_ranges[index], {
		from,
		to,
		flags
	})
end

function path_db:remove_invalid_range(index, from, to)
	from = from or 1
	to = to or self:get_end_node(index)

	local ranges = self.invalid_ranges[index]

	for i = #ranges, 1, -1 do
		local range = ranges[i]

		if range[1] == from and range[2] == to then
			table.remove(ranges, i)

			break
		end
	end
end

function path_db:is_node_valid(pi, ni, flags)
	local path = self:path(pi, 1)

	if ni <= 0 or ni >= #path + 1 then
		return false
	end

	if not self:is_path_active(pi) then
		return false
	end

	if ni < self:get_visible_start_node(pi) or ni > self:get_visible_end_node(pi) then
		return false
	end

	flags = flags or NF_ALL

	for _, range in pairs(self.invalid_ranges[pi]) do
		if ni >= range[1] and ni <= range[2] and bit.band(flags, bit.bnot(range[3])) == 0 then
			return false
		end
	end

	return true
end

function path_db:get_valid_nodes(pi, flags)
	local node_idxs = {}
	local path = self:path(pi)

	for i = 1, #path do
		if self:is_node_valid(pi, i, flags) then
			table.insert(node_idxs, i)
		end
	end

	return node_idxs
end

function path_db:valid_node_nearby(x, y, path_width_factor, flags)
	path_width_factor = path_width_factor or 1

	local nodes = self:nearest_nodes(x, y)

	for _, n in pairs(nodes) do
		local pi, spi, ni, dist = unpack(n)

		if dist < path_width_factor * self:path_width(pi, spi, ni) and self:is_node_valid(pi, ni, flags) then
			return true
		end
	end

	return false
end

function path_db:next_entity_node(e, dt)
	local n = e.nav_path
	local path = self.paths[n.pi][n.spi]
	local next_node = path[n.ni + n.dir]
	local new = false

	if not next_node or V.dist(next_node.x, next_node.y, e.pos.x, e.pos.y) < 2 * e.motion.real_speed * dt then
		n.ni = n.ni + n.dir

		if n.ni < 1 or n.ni > #path then
			if self.path_connections[n.pi] and n.dir > 0 then
				n.prev_pis = n.prev_pis or {}

				table.insert(n.prev_pis, n.pi)

				local newpi, newspi, newni, dist

				newpi = self.path_connections[n.pi]
				newpi, newspi, newni, dist = unpack(self:nearest_nodes(e.pos.x, e.pos.y, {
					newpi
				})[1])

				log.debug("Entity %s switching from path:%i,%i,%i -> path:%i,%i,%i", e.id, n.pi, n.spi, n.ni, newpi, newspi, newni)

				n.pi = newpi
				n.ni = newni + n.dir
				path = self.paths[n.pi][n.spi]
			else
				return nil
			end
		end

		new = true
		next_node = path[n.ni + n.dir]
	end

	next_node = next_node and V.vclone(next_node)

	return next_node, new
end

function path_db:predict_enemy_node_advance(e, flight_time)
	local average_node_dist = self.average_node_dist

	if not flight_time then
		return 0
	elseif flight_time == true then
		flight_time = 1
	end

	local speed = V.len(e.motion.speed.x, e.motion.speed.y)
	local node_offset = math.ceil(flight_time * speed / average_node_dist)
	local path = self:path(e.nav_path.pi)

	return km.clamp(0, #path - e.nav_path.ni, node_offset)
end

function path_db:predict_enemy_time(e, nodes_count)
	return nodes_count * self.average_node_dist / e.motion.real_speed
end
function path_db:predict_enemy_pos(e, flight_time)
	local node_offset = self:predict_enemy_node_advance(e, flight_time)

	return self:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
end

-- margin = {
--   离出怪口最小节点数
--   离家最小节点数
-- }
function path_db:get_random_position(margin, valid_terrains, node_flags, margin_from_defend)
	if margin and type(margin) == "number" then
		margin = {
			margin,
			margin
		}
	end

	local available_paths = {}

	for i = 1, #self.paths do
		if self:is_path_active(i) then
			table.insert(available_paths, i)
		end
	end

	local pi = available_paths[math.random(1, #available_paths)]
	local spi = math.random(1, 3)
	local valid_nodes = self:get_valid_nodes(pi, node_flags)

	if #valid_nodes < 1 then
		return nil
	end

	local ni, found, tries = nil, false, 0

	while not found and tries < 5 do
		tries = tries + 1
		found = true
		ni = valid_nodes[math.random(1, #valid_nodes)]

		if margin and #margin > 0 then
			if not self:is_node_valid(pi, ni - margin[1], node_flags) then
				found = false
			end

			if self:is_node_valid(pi, ni + margin[2], node_flags) then
				if margin_from_defend and (not self:get_defend_point_node(pi) or ni + margin[2] > self:get_defend_point_node(pi)) then
					found = false
				end
			else
				found = false
			end
		end

		if valid_terrains then
			local npos = self.paths[pi][spi][ni]
			local rt = GR:cell_type(npos.x, npos.y)
			local t = bit.band(TERRAIN_TYPES_MASK, rt)

			if bit.band(t, bit.bnot(valid_terrains)) ~= 0 then
				found = false
			end
		end
	end

	if not found then
		log.debug("could not find random node")

		return nil
	else
		return self:node_pos(pi, spi, ni), pi, spi, ni
	end
end

function path_db:get_next_pi(pi)
	return self.path_connections and self.path_connections[pi]
end

function path_db:get_connected_paths(pi)
	local out = {
		pi
	}
	local next_pi = pi

	repeat
		next_pi = self.path_connections and self.path_connections[next_pi]

		if next_pi then
			table.insert(out, next_pi)
		end
	until next_pi == nil

	return out
end

function path_db:get_all_valid_pos(x, y, min_distance, max_distance, valid_terrains, filter_func, flags)
	valid_terrains = valid_terrains or TERRAIN_ALL_MASK

	local nodes = {}

	for pi = 1, #self.paths do
		for spi = 1, 3 do
			local sp = self.paths[pi][1]

			for ni = 1, #sp do
				local o = sp[ni]
				local d = V.dist(o.x, o.y, x, y)
				local t = GR:cell_type(o.x, o.y)

				if bit.band(bit.bnot(valid_terrains), t) == 0 and d < max_distance and min_distance < d and self:is_node_valid(pi, ni, flags) and (not filter_func or filter_func(o.x, o.y)) then
					table.insert(nodes, o)
				end
			end
		end
	end

	return nodes
end

function path_db:nodes_as_list(id)
	local curve = self.path_curves[id]
	local out = {}

	if curve and curve.nodes then
		for _, n in pairs(curve.nodes) do
			table.insert(out, n.x)
			table.insert(out, n.y)
		end
	end

	return out
end

function path_db:load_curves(name)
	local data
	local fn = KR_PATH_GAME .. "/data/levels/" .. name .. "_paths.lua"

	if not love.filesystem.isFile(fn) then
		log.debug("Level paths file does not exist for %s", fn)

		data = {
			connections = {},
			curves = {},
			paths = {},
			active = {}
		}
	else
		local f, err = love.filesystem.load(fn)

		if err then
			log.error("Error loading path curves for %s: %s", fn, err)

			return nil
		end

		data = f()
	end

	self.path_connections = data.connections or {}
	self.path_curves = data.curves or {}
	self.active_paths = data.active or {}

	for i, p in ipairs(self.path_curves) do
		if self.active_paths[i] == nil then
			self.active_paths[i] = true
		end
	end
end

if DEBUG then
	function path_db:save_curves(name)
		local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. name .. "_paths.lua"
		local t = {
			connections = self.path_connections,
			curves = self.path_curves,
			paths = self:generate_paths(),
			active = self.active_paths
		}
		local str = serpent.line(t, {
			comment = false,
			keyignore = {
				beziers = true
			}
		})
		local out = "return " .. str .. "\n"
        local dir = fn:match("(.+)/[^/]+$")
        if dir then
            os.execute("mkdir \"" .. dir .. "\"")
        end

		local f = io.open(fn, "w")

		f:write(out)
		f:flush()
		f:close()
	end
end

function path_db:generate_paths(pi)
	local STEP_SAMPLING = 10
	local PATH_POINTS_DISTANCE = 7
	local paths = {}

	for ci, curve in pairs(self.path_curves) do
		if pi and pi ~= ci then
			-- block empty
		else
			if not curve.beziers then
				return
			end

			local path_points = {
				{},
				{},
				{}
			}
			local lpx, lpy

			for bi, bezier in ipairs(curve.beziers) do
				local c1x, c1y = bezier:evaluate(0)
				local c4x, c4y = bezier:evaluate(1)
				local w1 = curve.widths[bi]
				local w4 = curve.widths[bi + 1]
				local tstep = PATH_POINTS_DISTANCE / V.len(c4x - c1x, c4y - c1y) / STEP_SAMPLING

				if not lpx and not lpy then
					lpx, lpy = c1x, c1y
				end

				local bezier_d = bezier:getDerivative()
				local t = 0

				while t + tstep < 1 do
					t = t + tstep

					local px, py = bezier:evaluate(t)

					if PATH_POINTS_DISTANCE <= V.len(px - lpx, py - lpy) then
						table.insert(path_points[1], V.v(km.round(px), km.round(py)))

						local w = w1 + (w4 - w1) * t
						local wx, wy = V.perpendicular(V.normalize(bezier_d:evaluate(t)))
						local s1x, s1y = V.mul(w * 0.5, wx, wy)
						local s2x, s2y = V.mul(-w * 0.5, wx, wy)

						table.insert(path_points[2], V.v(km.round(s1x + px), km.round(s1y + py)))
						table.insert(path_points[3], V.v(km.round(s2x + px), km.round(s2y + py)))

						lpx, lpy = px, py
					end
				end
			end

			table.insert(paths, path_points)
		end
	end

	return paths
end

return path_db
