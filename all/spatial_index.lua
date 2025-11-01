-- 空间索引模块，用于加速索敌。
-- 本模块仅实现空间索引本身的更新功能，不实现具体的索敌逻辑。
-- friend module: seek.lua
-- 其它模块只允许访问 spatial_index 暴露的接口，不允许通过 getter 来访问其内部数据结构。

local ffi = require("ffi")
require("constants")

local _aspect = ASPECT
local _aspect_inv = 1.0 / _aspect
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local _cell_size = SPATIAL_HASH_CELL_SIZE
local _cell_size_factor = SPATIAL_HASH_CELL_SIZE_FACTOR
local _x_min = IN_GAME_X_MIN
local _y_min = IN_GAME_Y_MIN
local _cols = SPATIAL_HASH_COLS
local _rows = SPATIAL_HASH_ROWS
local _max_size = SPATIAL_HASH_MAX_INDEX
local _id_array_capacity = ID_ARRAY_CAPACITY
-- array: 存储实体 id 的数组
-- size: 当前 array 中有的 id 个数
-- capacity: array 的最大容量
-- 用于提供快速的查找和删除
ffi.cdef[[
typedef struct{
    uint32_t size;
    uint32_t capacity;
    uint32_t* array;
} id_array;
]]

-- 初始化一个新的 id_array
local function new_id_array(capacity)
    local arr = ffi.new("id_array")
    arr.size = 0
    arr.capacity = capacity
    arr.array = ffi.new("uint32_t[?]", capacity)
    return arr
end

--- 模块数据区 BEGIN
-- id_array 数组，共 SPATIAL_HASH_MAX_INDEX 个元素
local id_arrays = ffi.new("id_array[?]", _max_size)
for i = 0, _max_size - 1 do
    id_arrays[i] = new_id_array(_id_array_capacity)
end
local entities = nil -- 引用 store.enemies
--- 模块数据区 END

--- 辅助方法
local function _x_to_col(x)
    return floor((x - _x_min) * _cell_size_factor) + 1
end

local function _y_to_row(y)
    return floor((y - _y_min) * _cell_size_factor) + 1
end

-- 以此方法得到的 index 用于访问 id_arrays（注意！该 index 从 0 开始）
local function _get_id_array_index(x, y)
    return floor((y - _y_min) * _cell_size_factor) * _cols + floor((x - _x_min) * _cell_size_factor)
end
---

-- 对外暴露方法集
local spatial_index = {}

-- 用 set 方法设置 entities 引用
function spatial_index.set_entities(entities_given)
    entities = entities_given
end

function spatial_index.insert_entity(entity)
    local id_array_index = _get_id_array_index(entity.pos.x, entity.pos.y)
    local id_array = id_arrays[id_array_index]
    entity._id_array_index = id_array_index
    entity._id_array_subindex = id_array.size
    id_array.array[id_array.size] = entity.id
    id_array.size = id_array.size + 1
end

function spatial_index.remove_entity(entity)
    local id_array_index = entity._id_array_index
    local subindex = entity._id_array_subindex
    local id_array = id_arrays[id_array_index]

    -- 首先，移动最后一个元素到被删除位置
    local last_id = id_array.array[id_array.size - 1]
    id_array.array[subindex] = last_id
    -- 更新被移动实体的 subindex
    entities[last_id]._id_array_subindex = subindex

    -- 然后，减少 size
    id_array.size = id_array.size - 1

    -- 老的 id 就留在那里，反正 size 已经减少了，不会访问到的
end

function spatial_index.on_update()
    for _, e in pairs(entities) do
        local new_id_array_index = _get_id_array_index(e.pos.x, e.pos.y)
        if new_id_array_index >= _max_size then
            print("spatial_index.on_update: entity " .. e.template_name .. " out of bounds, position (" .. e.pos.x .. ", " .. e.pos.y .. ")")
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