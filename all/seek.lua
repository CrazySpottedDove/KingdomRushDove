-- 从 utils.lua 中独立开来，专门用于管理各类索敌函数，旨在尽可能减少性能损耗。本模块不需要遵循任何设计原则（接口暴露除外），只希望性能达到最优。
local seek = {}
local P = require("path_db")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
require("constants")

local _aspect = ASPECT
local _aspect_inv = 1.0 / _aspect
local _cell_size = SPATIAL_HASH_CELL_SIZE
local _cell_size_factor = SPATIAL_HASH_CELL_SIZE_FACTOR
local _x_min = IN_GAME_X_MIN
local _y_min = IN_GAME_Y_MIN
local _cols = SPATIAL_HASH_COLS
local _rows = SPATIAL_HASH_ROWS
local _max_index = SPATIAL_HASH_MAX_INDEX
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local V = require("klua.vector")
local v = V.v
local vclone = V.vclone
local function _x_to_col(x)
    return floor((x - _x_min) * _cell_size_factor) + 1
end

local function _y_to_row(y)
    return floor((y - _y_min) * _cell_size_factor) + 1
end

local function enemy_filter_simple(e, flags, bans)
    return not e.health.dead and band(e.vis.bans, flags) == 0 and band(e.vis.flags, bans) == 0 and
               P:is_node_valid(e.nav_path.pi, e.nav_path.ni)
end

--- 返回敌人的 __ffe_pos
---@param e table
---@param prediction_time number?
---@return table
local function calculate_enemy_ffe_pos(e, prediction_time)
    if prediction_time then
        if e.motion.forced_waypoint then
            local dt = prediction_time == true and 1 or prediction_time

            return v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
        else
            local node_offset = P:predict_enemy_node_advance(e, prediction_time)

            local e_ni = e.nav_path.ni + node_offset
            return P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
        end
    else
        return vclone(e.pos)
    end
end

seek.calculate_enemy_ffe_pos = calculate_enemy_ffe_pos

local function foremost_enemy_cmp(e1, e2)
    local e1_mocking = band(e1.vis.flags, F_MOCKING) ~= 0
    local e2_mocking = band(e2.vis.flags, F_MOCKING) ~= 0
    -- 优先处理嘲讽标志，且嘲讽对空中单位无保护效果
    if e1_mocking and not (e2_mocking or band(e2.vis.flags, F_FLYING) ~= 0) then
        return true
    elseif not (e1_mocking or band(e1.vis.flags, F_FLYING) ~= 0) and e2_mocking then
        return false
    end

    local p1 = e1.nav_path
    local p2 = e2.nav_path

    return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
end

function seek.find_enemies_in_range_filter_off(store, origin, range, flags, bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return count == 0 and nil or result
end

function seek.find_enemies_in_range_filter_on(store, origin, range, flags, bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) and
                    filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return count == 0 and nil or result
end

function seek.find_enemies_between_range_filter_off(store, origin, min_range, max_range, flags, bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return count == 0 and nil or result
end

function seek.find_enemies_between_range_filter_on(store, origin, min_range, max_range, flags, bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and dist2 >= r_inner_sq and enemy_filter_simple(entity, flags, bans) and
                    filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return count == 0 and nil or result
end

function seek.find_foremost_enemy_in_range_filter_off(store, origin, range, prediction_time, flags, bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    return result[1], result, calculate_enemy_ffe_pos(result[1], prediction_time)
end

function seek.find_foremost_enemy_in_range_filter_on(store, origin, range, prediction_time, flags, bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) and
                    filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    return result[1], result, calculate_enemy_ffe_pos(result[1], prediction_time)
end

function seek.find_foremost_enemy_between_range_filter_off(store, origin, min_range, max_range, prediction_time, flags,
    bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and (band(entity.vis.flags, F_FLYING) ~= 0 or dist2 >= r_inner_sq) and
                    enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    return result[1], result, calculate_enemy_ffe_pos(result[1], prediction_time)
end

function seek.find_foremost_enemy_between_range_filter_on(store, origin, min_range, max_range, prediction_time, flags,
    bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and (band(entity.vis.flags, F_FLYING) ~= 0 or dist2 >= r_inner_sq) and
                    enemy_filter_simple(entity, flags, bans) and filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    return result[1], result, calculate_enemy_ffe_pos(result[1], prediction_time)
end

--- 返回范围内符合条件、离家最近的敌人与其 _ffe_pos
---@param store any
---@param origin any
---@param range any
---@param flags any
---@param bans any
---@param filter_fn function(e, origin)
function seek.detect_foremost_enemy_in_range_filter_on(store, origin, range, flags, bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))

    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range

    local e_mocking = false
    local e_flying = false
    local e_nodes_to_goal = math.maxinteger
    local e = nil

    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) and filter_fn(entity, origin) then
                    local e_next_mocking = band(entity.vis.flags, F_MOCKING) ~= 0
                    local e_next_flying = band(entity.vis.flags, F_FLYING) ~= 0
                    local p = entity.nav_path
                    local e_next_nodes_to_goal = P:nodes_to_goal(p.pi, p.spi, p.ni)
                    if (not (e_mocking or e_flying) and e_next_mocking) or e_nodes_to_goal > e_next_nodes_to_goal then
                        e_mocking = e_next_mocking
                        e_flying = e_next_flying
                        e_nodes_to_goal = e_next_nodes_to_goal
                        e = entity
                    end
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end

    return e
end

--- 返回范围内符合条件、离家最近的敌人与其 _ffe_pos，在不需要 enemies 时调用，性能更优
---@param store any
---@param origin any
---@param range any
---@param flags any
---@param bans any
---@param filter_fn function(e, origin)
function seek.detect_foremost_enemy_in_range_filter_off(store, origin, range, flags, bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))

    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range

    local e_mocking = false
    local e_flying = false
    local e_nodes_to_goal = math.maxinteger
    local e = nil

    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) then
                    local e_next_mocking = band(entity.vis.flags, F_MOCKING) ~= 0
                    local e_next_flying = band(entity.vis.flags, F_FLYING) ~= 0
                    local p = entity.nav_path
                    local e_next_nodes_to_goal = P:nodes_to_goal(p.pi, p.spi, p.ni)
                    if (not (e_mocking or e_flying) and e_next_mocking) or e_nodes_to_goal > e_next_nodes_to_goal then
                        e_mocking = e_next_mocking
                        e_flying = e_next_flying
                        e_nodes_to_goal = e_next_nodes_to_goal
                        e = entity
                    end
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end

    return e
end

--- 在不需要区别敌人时使用，以最快的速度找到范围内的一个敌人，性能最佳
---@param store any
---@param origin any
---@param range any
---@param flags any
---@param bans any
---@param filter_fn any
function seek.find_first_enemy_in_range_filter_on(store, origin, range, flags, bans, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))

    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range

    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) and filter_fn(entity, origin) then
                    return entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return nil
end

--- 在不需要区别敌人时使用，以最快的速度找到范围内的一个敌人，性能最佳
---@param store any
---@param origin any
---@param range any
---@param flags any
---@param bans any
function seek.find_first_enemy_in_range_filter_off(store, origin, range, flags, bans)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))

    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range

    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) then
                    return entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    return nil
end

--- 找到范围内符合条件的、离家最近的、同时使得能够覆盖更多敌人的敌人及其预测位置
---@param store any
---@param origin any
---@param range any
---@param prediction_time number?
---@param flags any
---@param bans any
---@param cover_range number
---@return table?, table?, table?
function seek.find_foremost_enemy_with_max_coverage_in_range_filter_off(store, origin, range, prediction_time, flags,
    bans, cover_range)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    local foremost_enemy = result[1]
    local cover_range_sq = cover_range * cover_range
    local ffe_pos = calculate_enemy_ffe_pos(foremost_enemy, prediction_time)
    local best_ffe_pos = ffe_pos
    for i = 2, count do
        local enemy = result[i]
        local enemy_ffe_pos = calculate_enemy_ffe_pos(enemy, prediction_time)
        local dx = enemy_ffe_pos.x - ffe_pos.x
        local dy = enemy_ffe_pos.y - ffe_pos.y
        if (dx * dx + dy * dy) <= cover_range_sq then
            foremost_enemy = enemy
            best_ffe_pos = enemy_ffe_pos
        else
            break
        end
    end
    return foremost_enemy, result, best_ffe_pos
end

function seek.find_foremost_enemy_with_max_coverage_in_range_filter_on(store, origin, range, prediction_time, flags,
    bans, cover_range, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - range))
    local max_col = min(_cols, _x_to_col(x + range))
    local b = range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = range * range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                if (dx * dx + dy * dy <= r_outer_sq) and enemy_filter_simple(entity, flags, bans) and
                    filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    local foremost_enemy = result[1]
    local cover_range_sq = cover_range * cover_range
    local ffe_pos = calculate_enemy_ffe_pos(foremost_enemy, prediction_time)
    local best_ffe_pos = ffe_pos
    for i = 2, count do
        local enemy = result[i]
        local enemy_ffe_pos = calculate_enemy_ffe_pos(enemy, prediction_time)
        local dx = enemy_ffe_pos.x - ffe_pos.x
        local dy = enemy_ffe_pos.y - ffe_pos.y
        if (dx * dx + dy * dy) <= cover_range_sq then
            foremost_enemy = enemy
            best_ffe_pos = enemy_ffe_pos
        else
            break
        end
    end

    return foremost_enemy, result, best_ffe_pos

end

function seek.find_foremost_enemy_with_max_coverage_between_range_filter_off(store, origin, min_range, max_range,
    prediction_time, flags, bans, cover_range)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and (band(entity.vis.flags, F_FLYING) ~= 0 or dist2 >= r_inner_sq) and
                    enemy_filter_simple(entity, flags, bans) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    local foremost_enemy = result[1]
    local cover_range_sq = cover_range * cover_range
    local ffe_pos = calculate_enemy_ffe_pos(foremost_enemy, prediction_time)
    local best_ffe_pos = ffe_pos
    for i = 2, count do
        local enemy = result[i]
        local enemy_ffe_pos = calculate_enemy_ffe_pos(enemy, prediction_time)
        local dx = enemy_ffe_pos.x - ffe_pos.x
        local dy = enemy_ffe_pos.y - ffe_pos.y
        if (dx * dx + dy * dy) <= cover_range_sq then
            foremost_enemy = enemy
            best_ffe_pos = enemy_ffe_pos
        else
            break
        end
    end

    return foremost_enemy, result, best_ffe_pos

end

function seek.find_foremost_enemy_with_max_coverage_between_range_filter_on(store, origin, min_range, max_range,
    prediction_time, flags, bans, cover_range, filter_fn)
    local spatial_hash = store.enemy_spatial_index
    local x = origin.x
    local y = origin.y
    local min_col = max(1, _x_to_col(x - max_range))
    local max_col = min(_cols, _x_to_col(x + max_range))
    local b = max_range * _aspect
    local min_row = max(1, _y_to_row(y - b))
    local max_row = min(_rows, _y_to_row(y + b))
    local count = 0
    local row_mul_col = (min_row - 1) * _cols
    local r_outer_sq = max_range * max_range
    local r_inner_sq = min_range * min_range
    local result = {}
    for _ = min_row, max_row do
        for col = min_col, max_col do
            local cell = spatial_hash[row_mul_col + col]
            local size = cell.size
            local array = cell.array
            for i = 1, size do
                local entity = array[i]
                local dx = entity.pos.x - x
                local dy = (entity.pos.y - y) * _aspect_inv
                local dist2 = dx * dx + dy * dy
                if (dist2 <= r_outer_sq) and (band(entity.vis.flags, F_FLYING) ~= 0 or dist2 >= r_inner_sq) and
                    enemy_filter_simple(entity, flags, bans) and filter_fn(entity, origin) then
                    count = count + 1
                    result[count] = entity
                end
            end
        end
        row_mul_col = row_mul_col + _cols
    end
    if count == 0 then
        return nil, nil, nil
    end
    table.sort(result, foremost_enemy_cmp)
    local foremost_enemy = result[1]
    local cover_range_sq = cover_range * cover_range
    local ffe_pos = calculate_enemy_ffe_pos(foremost_enemy, prediction_time)
    local best_ffe_pos = ffe_pos
    for i = 2, count do
        local enemy = result[i]
        local enemy_ffe_pos = calculate_enemy_ffe_pos(enemy, prediction_time)
        local dx = enemy_ffe_pos.x - ffe_pos.x
        local dy = enemy_ffe_pos.y - ffe_pos.y
        if (dx * dx + dy * dy) <= cover_range_sq then
            foremost_enemy = enemy
            best_ffe_pos = enemy_ffe_pos
        else
            break
        end
    end

    return foremost_enemy, result, best_ffe_pos
end

return seek
