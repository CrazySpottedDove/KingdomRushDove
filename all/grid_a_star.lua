-- -- chunkname: @./all/grid_a_star.lua
-- local log = require("lib.klua.log"):new("grid_a_star")
-- require("lib.klua.table")
-- local a = {}
-- function a.heuristic_cost(n1, n2)
-- 	return math.sqrt(math.pow(n2.x - n1.x, 2) + math.pow(n2.y - n1.y, 2))
-- end
-- function a.get_lowest_node(nodes, cost_for_node)
-- 	local best_score = 1 / 0
-- 	local best_node
-- 	for _, n in ipairs(nodes) do
-- 		local score = cost_for_node[n]
-- 		if score < best_score then
-- 			best_score = score
-- 			best_node = n
-- 		end
-- 	end
-- 	return best_node
-- end
-- function a.get_neighbors(nodes, node, grid, valid_cell_fn)
-- 	local result = {}
-- 	for i = -1, 1 do
-- 		for j = -1, 1 do
-- 			if i ~= 0 or j ~= 0 then
-- 				local cx, cy = node.x + i, node.y + j
-- 				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] then
-- 					local cell = grid[cx][cy]
-- 					if valid_cell_fn(cx, cy, cell) then
-- 						table.insert(result, a.get_node(nodes, cx, cy))
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return result
-- end
-- function a.table_contains(table, node)
-- 	for _, n in pairs(table) do
-- 		if n.x == node.x and n.y == node.y then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
-- function a.table_remove(t, node)
-- 	local key
-- 	for k, n in pairs(t) do
-- 		if n.x == node.x and n.y == node.y then
-- 			key = k
-- 			break
-- 		end
-- 	end
-- 	if key ~= nil then
-- 		table.remove(t, key)
-- 	end
-- end
-- function a.get_node(nodes, x, y)
-- 	if nodes[x] == nil then
-- 		nodes[x] = {}
-- 		nodes[x][y] = {
-- 			x = x,
-- 			y = y
-- 		}
-- 	elseif nodes[x][y] == nil then
-- 		nodes[x][y] = {
-- 			x = x,
-- 			y = y
-- 		}
-- 	end
-- 	return nodes[x][y]
-- end
-- function a.find_nearest_valid(coords, grid, valid_cell_fn, max_dist)
-- 	for dist = 0, max_dist do
-- 		for i = -dist, dist do
-- 			for j = -dist, dist do
-- 				local cx, cy = coords.x + i, coords.y + j
-- 				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] and valid_cell_fn(cx, cy, grid[cx][cy]) then
-- 					return {
-- 						x = cx,
-- 						y = cy
-- 					}
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end
-- function a.get_path(start_coords, goal_coords, grid, valid_cell_fn, debug_data)
-- 	log.debug("start")
-- 	local nodes = {}
-- 	local start = a.get_node(nodes, start_coords.x, start_coords.y)
-- 	local goal = a.get_node(nodes, goal_coords.x, goal_coords.y)
-- 	local previous = {}
-- 	local closed = {}
-- 	local open = {
-- 		start
-- 	}
-- 	local cost_back = {}
-- 	local cost_forward = {}
-- 	cost_back[start] = 0
-- 	cost_forward[start] = cost_back[start] + a.heuristic_cost(start, goal)
-- 	local current
-- 	local iterations = 0
-- 	while #open > 0 do
-- 		iterations = iterations + 1
-- 		current = a.get_lowest_node(open, cost_forward)
-- 		if current == goal then
-- 			break
-- 		end
-- 		local neighbors = a.get_neighbors(nodes, current, grid, valid_cell_fn)
-- 		for _, neighbor in pairs(neighbors) do
-- 			do
-- 				local step_cost
-- 				step_cost = (neighbor.x == current.x or neighbor.y == current.y) and 1 or 1.4142
-- 				local n_cost_back = cost_back[current] + step_cost
-- 				if a.table_contains(closed, neighbor) then
-- 					if n_cost_back >= cost_back[neighbor] then
-- 						goto label_8_0
-- 					end
-- 					a.table_remove(closed, neighbor)
-- 				elseif a.table_contains(open, neighbor) and n_cost_back >= cost_back[neighbor] then
-- 					goto label_8_0
-- 				end
-- 				previous[neighbor] = current
-- 				cost_back[neighbor] = n_cost_back
-- 				cost_forward[neighbor] = n_cost_back + a.heuristic_cost(neighbor, goal)
-- 				if not a.table_contains(open, neighbor) then
-- 					table.insert(open, neighbor)
-- 				end
-- 			end
-- 			::label_8_0::
-- 		end
-- 		a.table_remove(open, current)
-- 		table.insert(closed, current)
-- 	end
-- 	if debug_data then
-- 		debug_data.iterations = iterations
-- 		debug_data.grid = grid
-- 		debug_data.start = start
-- 		debug_data.goal = goal
-- 		debug_data.nodes = nodes
-- 		debug_data.cost_back = cost_back
-- 		debug_data.cost_forward = cost_forward
-- 		debug_data.closed = closed
-- 	end
-- 	log.debug("end. iterations %s", iterations)
-- 	if current ~= goal then
-- 		return nil
-- 	else
-- 		local result = {}
-- 		while current ~= start do
-- 			table.insert(result, 1, current)
-- 			current = previous[current]
-- 		end
-- 		if debug_data then
-- 			debug_data.result = result
-- 		end
-- 		return result
-- 	end
-- end
-- function a.dump_costs(debug_data)
-- 	local d = debug_data
-- 	local out = ""
-- 	for i = 1, #d.grid do
-- 		for j = 1, #d.grid[i] do
-- 			local n = a.get_node(d.nodes, i, j)
-- 			local cost = d.cost_back[n]
-- 			out = out .. (cost and string.format("%02i ", cost) or ".  ")
-- 		end
-- 		out = out .. "\n"
-- 	end
-- 	return out
-- end
-- local out = ""
-- function a.dump_path(path)
-- 	for _, n in ipairs(path) do
-- 		out = out .. string.format("-> %s,%s ", n.x, n.y)
-- 	end
-- 	return out
-- end
-- return a
local log = require("lib.klua.log"):new("grid_a_star")

require("lib.klua.table")

local a = {}

-- 优化：使用曼哈顿距离 + 对角线修正，避免开方运算
function a.heuristic_cost(n1, n2)
	local dx = math.abs(n2.x - n1.x)
	local dy = math.abs(n2.y - n1.y)

	-- 曼哈顿距离 + 对角线修正 (√2 - 2 ≈ -0.586)
	return dx + dy + (1.4142 - 2) * math.min(dx, dy)
end

-- 优化：二叉堆实现，用于高效管理open列表
local function create_binary_heap()
	local heap = {
		size = 0
	}

	function heap:push(node, cost)
		self.size = self.size + 1

		local pos = self.size

		self[pos] = {
			node = node,
			cost = cost
		}

		-- 上浮操作
		while pos > 1 do
			local parent = math.floor(pos * 0.5)

			if self[parent].cost <= self[pos].cost then
				break
			end

			self[parent], self[pos] = self[pos], self[parent]
			pos = parent
		end
	end

	function heap:pop()
		if self.size == 0 then
			return nil
		end

		local result = self[1].node

		self[1] = self[self.size]
		self[self.size] = nil
		self.size = self.size - 1

		-- 下沉操作
		local pos = 1

		while pos * 2 <= self.size do
			local child = pos * 2

			if child + 1 <= self.size and self[child + 1].cost < self[child].cost then
				child = child + 1
			end

			if self[pos].cost <= self[child].cost then
				break
			end

			self[pos], self[child] = self[child], self[pos]
			pos = child
		end

		return result
	end

	function heap:update_cost(node, new_cost)
		-- 简化实现：重新插入节点（实际应用中可以优化）
		for i = 1, self.size do
			if self[i].node == node then
				self[i].cost = new_cost

				-- 重新调整堆结构
				local pos = i

				-- 先尝试上浮
				while pos > 1 do
					local parent = math.floor(pos * 0.5)

					if self[parent].cost <= self[pos].cost then
						break
					end

					self[parent], self[pos] = self[pos], self[parent]
					pos = parent
				end

				-- 再尝试下沉
				while pos * 2 <= self.size do
					local child = pos * 2

					if child + 1 <= self.size and self[child + 1].cost < self[child].cost then
						child = child + 1
					end

					if self[pos].cost <= self[child].cost then
						break
					end

					self[pos], self[child] = self[child], self[pos]
					pos = child
				end

				break
			end
		end
	end

	return heap
end

-- 优化：生成节点键的高效函数
local function node_key(node)
	return node.x * 10000 + node.y -- 假设坐标不超过10000
end

function a.get_neighbors(nodes, node, grid, valid_cell_fn)
	local result = {}

	for i = -1, 1 do
		for j = -1, 1 do
			if i ~= 0 or j ~= 0 then
				local cx, cy = node.x + i, node.y + j

				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] then
					local cell = grid[cx][cy]

					if valid_cell_fn(cx, cy, cell) then
						table.insert(result, a.get_node(nodes, cx, cy))
					end
				end
			end
		end
	end

	return result
end

function a.get_node(nodes, x, y)
	if nodes[x] == nil then
		nodes[x] = {}
		nodes[x][y] = {
			x = x,
			y = y
		}
	elseif nodes[x][y] == nil then
		nodes[x][y] = {
			x = x,
			y = y
		}
	end

	return nodes[x][y]
end

function a.find_nearest_valid(coords, grid, valid_cell_fn, max_dist)
	for dist = 0, max_dist do
		for i = -dist, dist do
			for j = -dist, dist do
				local cx, cy = coords.x + i, coords.y + j

				if cx > 1 and cx < #grid and cy > 1 and cy < #grid[cx] and valid_cell_fn(cx, cy, grid[cx][cy]) then
					return {
						x = cx,
						y = cy
					}
				end
			end
		end
	end

	return nil
end

-- 主要优化：完全重写的get_path函数
function a.get_path(start_coords, goal_coords, grid, valid_cell_fn, debug_data, max_iterations)
	log.debug("start")

	max_iterations = max_iterations or 1000 -- 添加迭代限制

	local nodes = {}
	local start = a.get_node(nodes, start_coords.x, start_coords.y)
	local goal = a.get_node(nodes, goal_coords.x, goal_coords.y)
	-- 使用哈希表替代数组，提高查找效率
	local closed = {} -- key: node_key, value: true
	local open_heap = create_binary_heap()
	local open_set = {} -- key: node_key, value: true，用于快速查找
	local cost_back = {} -- g值
	local cost_forward = {} -- f值
	local previous = {} -- 前驱节点

	-- 初始化
	cost_back[start] = 0
	cost_forward[start] = a.heuristic_cost(start, goal)

	open_heap:push(start, cost_forward[start])

	open_set[node_key(start)] = true

	local iterations = 0
	local current

	while open_heap.size > 0 and iterations < max_iterations do
		iterations = iterations + 1
		current = open_heap:pop()

		if not current then
			break
		end

		local current_key = node_key(current)

		open_set[current_key] = nil
		closed[current_key] = true

		if current == goal then
			break
		end

		local neighbors = a.get_neighbors(nodes, current, grid, valid_cell_fn)

		for _, neighbor in pairs(neighbors) do
			local neighbor_key = node_key(neighbor)

			-- 跳过已处理的节点
			if not closed[neighbor_key] then
				local step_cost = (neighbor.x == current.x or neighbor.y == current.y) and 1 or 1.4142
				local n_cost_back = cost_back[current] + step_cost
				local is_in_open = open_set[neighbor_key]

				-- 如果找到更好的路径，或者节点未被探索过
				if not cost_back[neighbor] or n_cost_back < cost_back[neighbor] then
					previous[neighbor] = current
					cost_back[neighbor] = n_cost_back
					cost_forward[neighbor] = n_cost_back + a.heuristic_cost(neighbor, goal)

					if not is_in_open then
						open_heap:push(neighbor, cost_forward[neighbor])

						open_set[neighbor_key] = true
					else
						-- 更新堆中的成本
						open_heap:update_cost(neighbor, cost_forward[neighbor])
					end
				end
			end
		end
	end

	-- 调试信息
	if debug_data then
		debug_data.iterations = iterations
		debug_data.grid = grid
		debug_data.start = start
		debug_data.goal = goal
		debug_data.nodes = nodes
		debug_data.cost_back = cost_back
		debug_data.cost_forward = cost_forward
		debug_data.closed = closed
		debug_data.max_iterations_reached = iterations >= max_iterations
	end

	log.debug("end. iterations %s", iterations)

	-- 检查是否达到迭代限制
	if iterations >= max_iterations then
		log.warning("A* reached iteration limit (%s), pathfinding incomplete", max_iterations)

		return nil
	end

	-- 构建路径
	if current ~= goal then
		return nil
	else
		local result = {}

		while current ~= start do
			table.insert(result, 1, current)

			current = previous[current]
		end

		if debug_data then
			debug_data.result = result
		end

		return result
	end
end

-- 保持原有的调试函数
function a.dump_costs(debug_data)
	local d = debug_data
	local out = ""

	for i = 1, #d.grid do
		for j = 1, #d.grid[i] do
			local n = a.get_node(d.nodes, i, j)
			local cost = d.cost_back[n]

			out = out .. (cost and string.format("%02i ", cost) or ".  ")
		end

		out = out .. "\n"
	end

	return out
end

function a.dump_path(path)
	local out = ""

	for _, n in ipairs(path) do
		out = out .. string.format("-> %s,%s ", n.x, n.y)
	end

	return out
end

return a
