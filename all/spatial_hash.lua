require("constants")
local spatial_hash = {}
local aspect = ASPECT
spatial_hash.__index = spatial_hash
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
function spatial_hash:new(cell_size)
    local hash = {
        cell_size = cell_size,
        _cell_size_factor = 1.0 / cell_size,
        cols = ceil((IN_GAME_X_MAX - IN_GAME_X_MIN) / cell_size),
        rows = ceil((IN_GAME_Y_MAX - IN_GAME_Y_MIN) / cell_size),
        x_min = IN_GAME_X_MIN,
        y_min = IN_GAME_Y_MIN,
        cells = {},
        entity_cells = {} -- entity id -> cell
    }
    for row = 1, hash.rows do
        hash.cells[row] = {}
        for col = 1, hash.cols do
            hash.cells[row][col] = {} -- id -> entity
        end
    end
    setmetatable(hash, spatial_hash)
    return hash
end

function spatial_hash:_x_to_col(x)
    return floor((x - self.x_min) * self._cell_size_factor) + 1
end

function spatial_hash:_y_to_row(y)
    return floor((y - self.y_min) * self._cell_size_factor) + 1
end

function spatial_hash:_get_cell(x, y)
    return self.cells[self:_y_to_row(y)][self:_x_to_col(x)]
end

function spatial_hash:_get_cells_in_ellipse_range(x, y, radius)
    local min_col = max(1, self:_x_to_col(x - radius))
    local max_col = min(self.cols, self:_x_to_col(x + radius))
    local b = radius * aspect
    local min_row = max(1, self:_y_to_row(y - b))
    local max_row = min(self.rows, self:_y_to_row(y + b))

    local cells = {}
    for row = min_row, max_row do
        for col = min_col, max_col do
            -- 性能敏感，避免 table.insert
            cells[#cells + 1] = self.cells[row][col]
        end
    end
    return cells
end

function spatial_hash:insert_entity(entity)
    local cell = self:_get_cell(entity.pos.x, entity.pos.y)
    cell[entity.id] = entity
    self.entity_cells[entity.id] = cell
end

function spatial_hash:update_entity(entity)
    local id = entity.id
    local new_cell = self:_get_cell(entity.pos.x, entity.pos.y)
    local old_cell = self.entity_cells[id]
    if old_cell == new_cell then
        return
    end
    old_cell[id] = nil
    new_cell[id] = entity
    self.entity_cells[id] = new_cell
    return true
end

function spatial_hash:remove_entity(entity)
    self.entity_cells[entity.id][entity.id] = nil
    self.entity_cells[entity.id] = nil
end

-- 必须提供 filter_fn
-- return 符合条件的实体数组
function spatial_hash:query_entities_in_ellipse(x, y, radius_outer, radius_inner, filter_fn)
    local result = {}
    local min_col = max(1, self:_x_to_col(x - radius_outer))
    local max_col = min(self.cols, self:_x_to_col(x + radius_outer))
    local b = radius_outer * aspect
    local min_row = max(1, self:_y_to_row(y - b))
    local max_row = min(self.rows, self:_y_to_row(y + b))

    local b2_outer = radius_outer * aspect * radius_outer * aspect
    local a2_outer = radius_outer * radius_outer
    local r2_outer = a2_outer * b2_outer

    local b2_inner = radius_inner * aspect * radius_inner * aspect
    local a2_inner = radius_inner * radius_inner
    local r2_inner = a2_inner * b2_inner

    for row = min_row, max_row do
        for col = min_col, max_col do
            -- 性能敏感，避免 table.insert
            local cell = self.cells[row][col]
            for _, entity in pairs(cell) do
                local r_x2 = (entity.pos.x - x) * (entity.pos.x - x)
                local r_y2 = (entity.pos.y - y) * (entity.pos.y - y)

                if r_x2 * b2_outer + r_y2 * a2_outer <= r2_outer and
                    ((radius_inner == 0) or (r_x2 * b2_inner + r_y2 * a2_inner > r2_inner)) and filter_fn(entity) then
                    result[#result + 1] = entity
                end
            end
        end
    end

    return result
end

function spatial_hash:query_first_entity_in_ellipse(x, y, radius_outer, radius_inner, filter_fn)
    local min_col = max(1, self:_x_to_col(x - radius_outer))
    local max_col = min(self.cols, self:_x_to_col(x + radius_outer))
    local b = radius_outer * aspect
    local min_row = max(1, self:_y_to_row(y - b))
    local max_row = min(self.rows, self:_y_to_row(y + b))

    local b2_outer = radius_outer * aspect * radius_outer * aspect
    local a2_outer = radius_outer * radius_outer
    local r2_outer = a2_outer * b2_outer

    local b2_inner = radius_inner * aspect * radius_inner * aspect
    local a2_inner = radius_inner * radius_inner
    local r2_inner = a2_inner * b2_inner

    for row = min_row, max_row do
        for col = min_col, max_col do
            -- 性能敏感，避免 table.insert
            local cell = self.cells[row][col]
            for _, entity in pairs(cell) do
                local r_x2 = (entity.pos.x - x) * (entity.pos.x - x)
                local r_y2 = (entity.pos.y - y) * (entity.pos.y - y)

                if r_x2 * b2_outer + r_y2 * a2_outer <= r2_outer and
                    ((radius_inner == 0) or (r_x2 * b2_inner + r_y2 * a2_inner > r2_inner)) and filter_fn(entity) then
                    return entity
                end
            end
        end
    end

    return nil
end

-- -- 在 spatial_hash.lua 文件末尾添加调试方法
-- function spatial_hash:print_debug_info()
--     print("========== Spatial Hash Debug Info ==========")
--     print(string.format("Grid size: %d x %d cells", self.cols, self.rows))
--     print(string.format("Cell size: %d pixels", self.cell_size))
--     print(string.format("World size: %.0f x %.0f pixels", self.cols * self.cell_size, self.rows * self.cell_size))

--     local total_entities = 0
--     local occupied_cells = 0
--     local max_entities_per_cell = 0

--     for key, cell in pairs(self.cells) do
--         local count = 0
--         local entity_ids = {}

--         for entity_id, entity in pairs(cell) do
--             count = count + 1
--             table.insert(entity_ids, entity_id)
--         end

--         if count > 0 then
--             occupied_cells = occupied_cells + 1
--             total_entities = total_entities + count
--             max_entities_per_cell = max(max_entities_per_cell, count)

--             -- 计算网格坐标
--             local row = floor(key / self.cols)
--             local col = key % self.cols

--             print(string.format("Cell[%d,%d] (key=%d): %d entities -> %s", row, col, key, count,
--                 table.concat(entity_ids, ", ")))

--             -- 显示实体的实际位置
--             for _, entity_id in ipairs(entity_ids) do
--                 local entity = cell[entity_id]
--                 if entity and entity.pos then
--                     print(string.format("  Entity %s at (%.1f, %.1f)", entity_id, entity.pos.x, entity.pos.y))
--                 end
--             end
--         end
--     end

--     print(string.format("Summary: %d total entities in %d occupied cells (max %d per cell)", total_entities,
--         occupied_cells, max_entities_per_cell))
--     print("============================================")
-- end

-- -- 添加一个更简洁的版本
-- function spatial_hash:print_summary()
--     local total = 0
--     local cells = 0
--     for _, cell in pairs(self.cells) do
--         local count = 0
--         for _ in pairs(cell) do
--             count = count + 1
--         end
--         if count > 0 then
--             cells = cells + 1
--             total = total + count
--         end
--     end
--     print(string.format("Spatial Hash: %d entities in %d cells", total, cells))
-- end

return spatial_hash
