-- 空间索引模块，用于加速索敌。
-- 本模块仅实现空间索引本身的更新功能，不实现具体的索敌逻辑。
-- friend module: seek.lua
-- 其它模块只允许访问 spatial_index 暴露的接口，不允许通过 getter 来访问其内部数据结构。
local ffi = require("ffi")

require("all.constants")

local ceil = math.ceil
local floor = math.floor
local _cell_size = SPATIAL_HASH_CELL_SIZE
local _cell_size_factor = 1 / _cell_size
local _x_min = 0
local _y_min = 0
local _cols = 0
local _rows = 0
local _max_size = 0
local _check_interval = SPATIAL_INDEX_CHECK_INTERVAL

-- array: 存储实体 id 的数组
-- size: 当前 array 中有的 id 个数
-- capacity: array 的最大容量
-- 用于提供快速的查找和删除
ffi.cdef[[
typedef struct{
    uint32_t size;
    uint32_t array[1024];
} id_array;
]]

--- 模块数据区 BEGIN
local id_arrays = nil

--- 按当前世界边界重新分配空间索引。
---@param cols number
---@param rows number
local function allocate(cols, rows)
	_cols = cols
	_rows = rows
	_max_size = _cols * _rows
	id_arrays = ffi.new("id_array[?]", _max_size)

	for i = 0, _max_size - 1 do
		id_arrays[i].size = 0
	end
end

local entities = nil
-- 用于定时 update id_arrays
local t = 0
--- 模块数据区 END
-- 对外暴露方法集
local spatial_index = {}

--- 根据世界边界重建空间索引。
--- 每局开始、关卡尺寸不同或切换地图后调用；重建后原有实体索引失效，必须在实体插入前调用。
---@param bounds table {left, bottom, right, top}
---@param cell_size number|nil
function spatial_index.rebuild(bounds, cell_size)
	_cell_size = cell_size or SPATIAL_HASH_CELL_SIZE
	_cell_size_factor = 1 / _cell_size
	_x_min = bounds.left
	_y_min = bounds.bottom

	allocate(ceil((bounds.right - bounds.left) / _cell_size), ceil((bounds.top - bounds.bottom) / _cell_size))
	t = 0
end

--- 当前空间索引实际覆盖的世界范围。
function spatial_index.get_bounds()
	return {
		left = _x_min,
		bottom = _y_min,
		right = _x_min + _cols * _cell_size,
		top = _y_min + _rows * _cell_size
	}
end

--- 当前网格参数。seek 等 friend module 必须用这些值同步自己的缓存。
function spatial_index.get_grid_params()
	return {
		x_min = _x_min,
		y_min = _y_min,
		cols = _cols,
		rows = _rows,
		cell_size = _cell_size,
		cell_size_factor = _cell_size_factor
	}
end

-- 用 set 方法设置 entities 引用
function spatial_index.set_entities(entities_given)
	entities = entities_given
end

function spatial_index.gc_locked(locker)
	locker._id_arrays_ref = id_arrays
end

function spatial_index.insert_entity(entity)
	local id_array_index = floor((entity.pos.y - _y_min) * _cell_size_factor) * _cols + floor((entity.pos.x - _x_min) * _cell_size_factor)
	local id_array = id_arrays[id_array_index]

	-- 让 entity 知道自己在 spatial_index 中的位置
	entity._id_array_index = id_array_index
	entity._id_array_subindex = id_array.size
	-- 在 id_array 中插入 entity.id
	id_array.array[id_array.size] = entity.id
	-- 更新 size
	id_array.size = id_array.size + 1
end

function spatial_index.remove_entity(entity)
	local id_array_index = entity._id_array_index
	local subindex = entity._id_array_subindex
	local id_array = id_arrays[id_array_index]

	-- 更新 size
	id_array.size = id_array.size - 1

	-- 移动原来最后一个 id 到被删除位置，代替被删除的 id
	local last_id = id_array.array[id_array.size]

	id_array.array[subindex] = last_id
	-- 更新被移动实体的 subindex
	entities[last_id]._id_array_subindex = subindex
-- 老的 id 就留在那里，反正 size 已经减少了，不会访问到的
end

function spatial_index.on_update(dt)
	t = t + dt

	if t < _check_interval then
		return
	end

	t = t - _check_interval

	for _, e in pairs(entities) do
		local new_id_array_index = floor((e.pos.y - _y_min) * _cell_size_factor) * _cols + floor((e.pos.x - _x_min) * _cell_size_factor)

		if new_id_array_index >= _max_size then
			error("spatial_index.on_update: entity " .. e.template_name .. " out of bounds, position (" .. e.pos.x .. ", " .. e.pos.y .. ")")

			goto continue
		end

		local old_id_array_index = e._id_array_index

		if new_id_array_index ~= old_id_array_index then
			local old_id_array = id_arrays[old_id_array_index]
			local new_id_array = id_arrays[new_id_array_index]
			-- 从旧的 id_array 中移除
			local subindex = e._id_array_subindex
			local last_id = old_id_array.array[old_id_array.size - 1]

			old_id_array.array[subindex] = last_id
			entities[last_id]._id_array_subindex = subindex
			old_id_array.size = old_id_array.size - 1
			-- 插入到新的 id_array 中
			e._id_array_index = new_id_array_index
			e._id_array_subindex = new_id_array.size
			new_id_array.array[new_id_array.size] = e.id
			new_id_array.size = new_id_array.size + 1
		end

		::continue::
	end
end

function spatial_index.get_id_arrays()
	return id_arrays
end

return spatial_index
