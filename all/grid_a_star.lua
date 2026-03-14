local log = require("lib.klua.log"):new("grid_a_star")

require("lib.klua.table")

local a = {}

-- 优化：使用曼哈顿距离 + 对角线修正，避免开方运算
function a.heuristic_cost(n1, n2)
	local dx = math.abs(n2.x - n1.x)
	local dy = math.abs(n2.y - n1.y)

	-- 曼哈顿距离 + 对角线修正 (√2 - 2 ≈ -0.586)
	return dx + dy - 0.586 * math.min(dx, dy)
end

-- 二叉堆。弹入弹出开销 logn
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

--- 找到一个节点的所有有效邻居，考虑八个方向
function a.get_neighbors(nodes, node, grid, valid_cell_fn)
	local result = {}

	local x = node.x
	local y = node.y

	local gx = #grid
	local cx, cy, cell

	local function try(nx, ny)
		if nx > 1 and nx < gx then
			local col = grid[nx]
			if ny > 1 and ny < #col then
				cell = col[ny]
				if valid_cell_fn(nx, ny, cell) then
					result[#result + 1] = a.get_node(nodes, nx, ny)
				end
			end
		end
	end

	try(x - 1, y - 1)
	try(x - 1, y)
	try(x - 1, y + 1)
	try(x, y - 1)
	try(x, y + 1)
	try(x + 1, y - 1)
	try(x + 1, y)
	try(x + 1, y + 1)

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
function a.get_path(start_coords, goal_coords, grid, valid_cell_fn)
	local max_iterations = 1000 -- 添加迭代限制

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

		-- 获取当前节点的所有有效邻居
		local neighbors = a.get_neighbors(nodes, current, grid, valid_cell_fn)

		for i = 1, #neighbors do
			local neighbor = neighbors[i]
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

	-- 检查是否达到迭代限制
	if iterations >= max_iterations then
		return nil
	end

	-- 构建路径
	if current ~= goal then
		return nil
	else
		local rev_result = {}

		while current ~= start do
			rev_result[#rev_result + 1] = current
			current = previous[current]
		end

		local result = {}
		for i = #rev_result, 1, -1 do
			result[#result + 1] = rev_result[i]
		end

		return result
	end
end

return a
