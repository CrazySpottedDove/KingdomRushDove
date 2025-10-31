require("constants")
local hash_array = require("hash_array")
local log = require("klua.log"):new("spatial_hash")

local spatial_hash = {}
spatial_hash.__index = spatial_hash

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
local _max_index = SPATIAL_HASH_MAX_INDEX
function spatial_hash:new()
    local hash = {}

    for i = 1, _max_index do
        hash[i] = hash_array:new()
    end
    setmetatable(hash, spatial_hash)
    return hash
end

local function _x_to_col(x)
    return floor((x - _x_min) * _cell_size_factor) + 1
end

local function _y_to_row(y)
    return floor((y - _y_min) * _cell_size_factor) + 1
end

local function _get_cell_index(x, y)
    return floor((y - _y_min) * _cell_size_factor) * _cols + floor((x - _x_min) * _cell_size_factor) + 1
end

function spatial_hash:_get_cells_in_ellipse_range(x, y, radius)
    local min_col = max(1, _x_to_col(x - radius))
    local max_col = min(_cols, _x_to_col(x + radius))
    local b = radius * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local cells = {}
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    for _ = min_row, max_row do
        for col = min_col, max_col do
            count = count + 1
            cells[count] = self[row_mul_col + col]
        end
        row_mul_col = row_mul_col + _cols
    end
    return cells
end

function spatial_hash:insert_entity(entity)
    local cell_index = _get_cell_index(entity.pos.x, entity.pos.y)
    self[cell_index]:insert(entity)
    entity._spatial_hash_index = cell_index
end

function spatial_hash:update_entity(entity)
    local new_cell_index = _get_cell_index(entity.pos.x, entity.pos.y)
    if new_cell_index > _max_index then
        log.error(entity.template_name .. " pos out of bounds:" .. entity.pos.x .. "," .. entity.pos.y)
        return
    end
    local old_cell_index = entity._spatial_hash_index
    if old_cell_index == new_cell_index then
        return
    end
    self[old_cell_index]:remove(entity)
    self[new_cell_index]:insert(entity)
    entity._spatial_hash_index = new_cell_index
end

function spatial_hash:remove_entity(entity)
    self[entity._spatial_hash_index]:remove(entity)
end

-- 查询范围内所有符合条件目标的底层函数
function spatial_hash:query_entities_in_ellipse(x, y, radius_outer, radius_inner, filter_fn)
    local min_col = max(1, _x_to_col(x - radius_outer))
    local max_col = min(_cols, _x_to_col(x + radius_outer))
    local b = radius_outer * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = radius_outer * radius_outer
    local r_inner_sq = radius_inner * radius_inner
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = self[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and filter_fn(entity) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return result
end

-- 查询范围内第一个符合条件目标的底层函数
function spatial_hash:query_first_entity_in_ellipse(x, y, radius_outer, radius_inner, filter_fn)
    local min_col = max(1, _x_to_col(x - radius_outer))
    local max_col = min(_cols, _x_to_col(x + radius_outer))
    local b = radius_outer * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = radius_outer * radius_outer
    local r_inner_sq = radius_inner * radius_inner
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = self[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and filter_fn(entity) then
                    return entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return nil
end

-- 查询范围内是否有足够数量目标的底层函数
function spatial_hash:query_enough_entities_in_ellipse(x, y, radius_outer, radius_inner, filter_fn, count)
    local min_col = max(1, _x_to_col(x - radius_outer))
    local max_col = min(_cols, _x_to_col(x + radius_outer))
    local b = radius_outer * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local found_count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = radius_outer * radius_outer
    local r_inner_sq = radius_inner * radius_inner
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = self[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and filter_fn(entity) then
                    found_count = found_count + 1
                    if found_count >= count then
                        return true
                    end
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return false
end

--- 查询随机目标的底层函数
--- @param x number
--- @param y number
--- @param radius_outer number
--- @param radius_inner number
--- @param filter_fn function
--- @return table | nil
function spatial_hash:query_random_entity_in_ellipse(x, y, radius_outer, radius_inner, filter_fn)
    local cells = self:_get_cells_in_ellipse_range(x, y, radius_outer)
    -- shuffle
    for i = #cells, 2, -1 do
        local j = math.random(1, i)
        cells[i], cells[j] = cells[j], cells[i]
    end
    local r_outer_sq = radius_outer * radius_outer
    local r_inner_sq = radius_inner * radius_inner
    for i = 1, #cells do
        local cell = cells[i]
        local size = cell.size
        local array = cell.array
        for j = 1, size do
            local entity = array[j]
            local dx = entity.pos.x - x
            local dy = (entity.pos.y - y) * _aspect_inv
            local dist2 = dx * dx + dy * dy
            if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and filter_fn(entity) then
                return entity
            end
        end
    end
    return nil
end

--- 查询范围内符合条件且排序后的第一个目标（不返回数组） 的底层函数
--- @param x number
--- @param y number
--- @param radius_outer number
--- @param radius_inner number
--- @param filter_fn function
--- @param sort_fn function(a, b) 返回 true 表示 a 优于 b
--- @return table | nil
function spatial_hash:query_best_entity_in_ellipse(x, y, radius_outer, radius_inner, filter_fn, sort_fn)
    local min_col = max(1, _x_to_col(x - radius_outer))
    local max_col = min(_cols, _x_to_col(x + radius_outer))
    local b = radius_outer * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = radius_outer * radius_outer
    local r_inner_sq = radius_inner * radius_inner
    local best = nil
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = self[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and filter_fn(entity) then
                    if not best or sort_fn(entity, best) then
                        best = entity
                    end
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return best
end


-- local spatial_hash_manager = {}
-- spatial_hash_manager.__index = spatial_hash_manager
-- SPATIAL_HASH_TYPE_ENEMY = 1
-- SPATIAL_HASH_TYPE_SOLDIER = 2
-- SPATIAL_HASH_TYPE_TOWER = 3

-- function spatial_hash_manager:new()
--     local hashes = {}
--     hashes[SPATIAL_HASH_TYPE_ENEMY] = spatial_hash:new()
--     hashes[SPATIAL_HASH_TYPE_SOLDIER] = spatial_hash:new()
--     hashes[SPATIAL_HASH_TYPE_TOWER] = spatial_hash:new()
--     setmetatable(hashes, spatial_hash_manager)
--     return hashes
-- end
return spatial_hash
