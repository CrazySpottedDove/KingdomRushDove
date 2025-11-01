-- 空间索引模块（严格模式）：任何意料之外的情况都会立即以红色输出致命错误并终止进程。
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

ffi.cdef [[
typedef struct{
    uint32_t size;
    uint32_t* array;
} id_array;
]]

-- 调试开关：运行时可改 false 减少日志
local DEBUG = true
local function dprint(...)
    if DEBUG then
        print(...)
    end
end

-- 致命错误：打印红色到 stderr，包含 traceback，然后退出进程
local function fatal(msg)
    msg = tostring(msg or "fatal error")
    local tb = debug and debug.traceback and debug.traceback() or ""
    local red = "\27[31m"
    local reset = "\27[0m"
    -- 写到 stderr（Windows 控制台若不支持 ANSI 可能不显示颜色，但仍会退出）
    if io and io.stderr and io.stderr.write then
        io.stderr:write(red .. "FATAL: " .. msg .. "\n" .. tb .. reset .. "\n")
        io.stderr:flush()
    else
        print("FATAL: " .. msg)
        print(tb)
    end
    -- 强制终止进程以避免继续运行（确保崩溃）
    if os and os.exit then
        os.exit(1)
    else
        error(msg)
    end
end

-- helpers
local function ptr_of(arr)
    if not arr or not arr.array then
        return "nil"
    end
    return tostring(tonumber(ffi.cast("uintptr_t", arr.array)))
end

local function is_valid_id(id)
    return type(id) == "number" and id >= 0 and id <= 0xFFFFFFFF and id == math.floor(id)
end

local function dump_id_array(id_array, idx)
    if not id_array then
        print("dump_id_array: nil at index", tostring(idx))
        return
    end
    print(("dump_id_array index=%d ptr=%s size=%d cap=%d"):format(idx, ptr_of(id_array), tonumber(id_array.size),
        _id_array_capacity))
    for i = 0, math.max(0, tonumber(id_array.size) - 1) do
        local v = id_array.array[i]
        io.write(("[%d]=%s"):format(i, tostring(v)))
        if v == 0 then
            io.write(" (zero)")
        end
        if not is_valid_id(v) then
            io.write(" (invalid numeric)")
        end
        io.write("\n")
    end
end

local function dump_all_id_arrays(limit)
    limit = limit or _max_size - 1
    for i = 0, math.min(limit, _max_size - 1) do
        local a = id_arrays[i]
        if a and tonumber(a.size) > 0 then
            io.write("Index " .. i .. ": ")
            for j = 0, tonumber(a.size) - 1 do
                io.write(tostring(a.array[j]) .. " ")
            end
            io.write("\n")
        end
    end
end

-- canary / guard
local CANARY_LEFT = 0xDEADBEEF
local CANARY_RIGHT = 0xBAADF00D

local function new_id_array_with_guard(capacity)
    if type(capacity) ~= "number" or capacity <= 0 then
        fatal("invalid capacity for new_id_array_with_guard: " .. tostring(capacity))
    end
    local base = ffi.new("uint32_t[?]", capacity + 2)
    base[0] = CANARY_LEFT
    base[capacity + 1] = CANARY_RIGHT
    for i = 1, capacity do
        base[i] = 0
    end
    local arr = ffi.new("id_array")
    arr.size = 0
    arr.array = base + 1
    return arr, base
end

-- 模块数据区
local id_arrays = ffi.new("id_array[?]", _max_size)
local id_array_roots = {}
for i = 0, _max_size - 1 do
    local arr, base = new_id_array_with_guard(_id_array_capacity)
    id_array_roots[i + 1] = {
        arr = arr,
        base = base
    }
    id_arrays[i] = arr
end
id_array_roots[_max_size + 1] = id_arrays
local entities = nil

local function check_canary(idx)
    local root = id_array_roots[idx + 1]
    if not root then
        return false, "no root"
    end
    local base = root.base
    if not base then
        return false, "no base"
    end
    if base[0] ~= CANARY_LEFT then
        return false, ("left canary corrupted idx=%d left=%s"):format(idx, tostring(base[0]))
    end
    if base[_id_array_capacity + 1] ~= CANARY_RIGHT then
        return false, ("right canary corrupted idx=%d right=%s"):format(idx, tostring(base[_id_array_capacity + 1]))
    end
    return true
end

local function validate_id_write(id)
    if not is_valid_id(id) then
        fatal("invalid id value for write: " .. tostring(id))
    end
end

local function validate_subindex_for_write(arr, subindex)
    if type(subindex) ~= "number" then
        fatal(("validate_subindex_for_write: subindex not number: %s"):format(tostring(subindex)))
    end
    if subindex < 0 or subindex >= _id_array_capacity then
        fatal(("subindex out of absolute bounds: %d (capacity=%d)"):format(subindex, _id_array_capacity))
    end
    if subindex > tonumber(arr.size) then
        fatal(("writing beyond current size: sub=%d size=%d"):format(subindex, tonumber(arr.size)))
    end
end

local function dump_roots_sample()
    print("=== dump roots sample ===")
    if id_array_roots then
        for k = 1, math.min(#id_array_roots, 20) do
            local v = id_array_roots[k]
            if v and v.base then
                print(("root[%d] base_ptr=%s"):format(k, tostring(tonumber(ffi.cast("uintptr_t", v.base)))))
            end
        end
    end
    print("=== end dump roots ===")
end

local function _get_id_array_index(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        fatal("_get_id_array_index: x,y must be numbers")
    end
    local col = floor((x - _x_min) * _cell_size_factor)
    local row = floor((y - _y_min) * _cell_size_factor)
    local idx = row * _cols + col
    return idx
end

local spatial_index = {}

function spatial_index.set_entities(entities_given)
    if type(entities_given) ~= "table" and entities_given ~= nil then
        fatal("set_entities: expected table or nil")
    end
    entities = entities_given
end

function spatial_index.get_id_arrays()
    return id_arrays
end

-- insert
function spatial_index.insert_entity(entity)
    if not entity or not entity.pos then
        fatal("insert_entity: invalid entity")
    end
    if type(entity.id) ~= "number" then
        fatal("insert_entity: entity.id must be number")
    end
    local id_array_index = _get_id_array_index(entity.pos.x, entity.pos.y)
    if id_array_index < 0 or id_array_index >= _max_size then
        fatal(("insert_entity: out of bounds index for entity %s idx=%s"):format(tostring(entity.id),
            tostring(id_array_index)))
    end

    local ok, err = check_canary(id_array_index)
    if not ok then
        dump_roots_sample();
        dump_id_array(id_arrays[id_array_index], id_array_index);
        fatal("CANARY FAIL before insert: " .. tostring(err))
    end

    local id_array = id_arrays[id_array_index]
    if not id_array then
        fatal(("insert_entity: nil id_array at %d"):format(id_array_index))
    end
    if tonumber(id_array.size) >= _id_array_capacity then
        fatal(("insert_entity: id_array full at index %d size=%d"):format(id_array_index, tonumber(id_array.size)))
    end

    validate_id_write(entity.id)
    validate_subindex_for_write(id_array, tonumber(id_array.size))

    if entity._id_array_index ~= nil then
        fatal(("insert_entity: entity %s already has id_array_index=%s"):format(tostring(entity.id),
            tostring(entity._id_array_index)))
    end

    entity._id_array_index = id_array_index
    entity._id_array_subindex = tonumber(id_array.size)
    dprint(("WRITE: arr_ptr=%s idx=%d id=%s size_before=%d"):format(ptr_of(id_array), entity._id_array_subindex,
        tostring(entity.id), tonumber(id_array.size)))
    id_array.array[entity._id_array_subindex] = entity.id
    id_array.size = id_array.size + 1

    if id_array.array[entity._id_array_subindex] ~= entity.id then
        dump_roots_sample();
        dump_id_array(id_array, id_array_index);
        fatal(("insert_entity: post-write verification failed for id=%s at index=%d sub=%d"):format(tostring(entity.id),
            id_array_index, entity._id_array_subindex))
    end

    dprint(entity.id .. " inserted into index " .. id_array_index .. " at subindex " .. entity._id_array_subindex)
end

-- remove
function spatial_index.remove_entity(entity)
    if not entity then
        fatal("remove_entity: nil entity")
    end
    local id_array_index = entity._id_array_index
    local subindex = entity._id_array_subindex
    if id_array_index == nil or subindex == nil then
        fatal(("remove_entity: missing index/subindex for %s"):format(tostring(entity and entity.id)))
    end
    if id_array_index < 0 or id_array_index >= _max_size then
        fatal(("remove_entity: out of bounds id_array_index %s"):format(tostring(id_array_index)))
    end

    local ok, err = check_canary(id_array_index)
    if not ok then
        dump_roots_sample();
        dump_id_array(id_arrays[id_array_index], id_array_index);
        fatal("CANARY FAIL before remove: " .. tostring(err))
    end

    local id_array = id_arrays[id_array_index]
    if not id_array then
        fatal(("remove_entity: nil id_array at %d"):format(id_array_index))
    end
    if tonumber(id_array.size) == 0 then
        fatal(("remove_entity: empty id_array at %d"):format(id_array_index))
    end
    if subindex < 0 or subindex >= tonumber(id_array.size) then
        dump_id_array(id_array, id_array_index);
        fatal(("remove_entity: invalid subindex %d size=%d"):format(subindex, tonumber(id_array.size)))
    end

    local last_pos = tonumber(id_array.size) - 1
    local last_id = id_array.array[last_pos]

    if not is_valid_id(last_id) then
        dump_id_array(id_array, id_array_index);
        fatal(("remove_entity: last_id invalid numeric: %s at index %d last_pos %d"):format(tostring(last_id),
            id_array_index, last_pos))
    end

    dprint(("REMOVE: arr_ptr=%s idx=%d last_pos=%d last_id=%s"):format(ptr_of(id_array), subindex, last_pos,
        tostring(last_id)))
    id_array.array[subindex] = last_id
    id_array.array[last_pos] = 0
    id_array.size = last_pos

    if last_id ~= 0 then
        if not entities then
            fatal("remove_entity: entities table nil while last_id != 0")
        end
        if not entities[last_id] then
            dump_id_array(id_array, id_array_index);
            fatal(("remove_entity: moved last_id %d not found in entities"):format(last_id))
        end
        entities[last_id]._id_array_subindex = subindex
    end

    entity._id_array_index = nil
    entity._id_array_subindex = nil
end

-- on_update
function spatial_index.on_update()
    if not entities then
        fatal("on_update: entities table is nil")
    end
    for _, e in pairs(entities) do
        if not e or not e.pos then
            goto continue
        end
        if type(e.pos.x) ~= "number" or type(e.pos.y) ~= "number" then
            fatal("entity.pos must have numeric x,y")
        end
        local new_id_array_index = _get_id_array_index(e.pos.x, e.pos.y)
        if new_id_array_index < 0 or new_id_array_index >= _max_size then
            fatal(("on_update: entity %s out of bounds at pos (%s,%s) idx=%s"):format(tostring(e.id), tostring(e.pos.x),
                tostring(e.pos.y), tostring(new_id_array_index)))
        end

        local old_id_array_index = e._id_array_index
        if old_id_array_index == nil then
            -- 初次插入
            local ok, err = check_canary(new_id_array_index)
            if not ok then
                dump_roots_sample();
                dump_id_array(id_arrays[new_id_array_index], new_id_array_index);
                fatal("CANARY FAIL at initial insert: " .. tostring(err))
            end
            local new_id_array = id_arrays[new_id_array_index]
            if not new_id_array then
                fatal(("on_update initial insert: nil id_array at %d"):format(new_id_array_index))
            end
            if tonumber(new_id_array.size) >= _id_array_capacity then
                fatal(("on_update initial insert: target id_array full at %d"):format(new_id_array_index))
            end
            validate_id_write(e.id)
            validate_subindex_for_write(new_id_array, tonumber(new_id_array.size))
            e._id_array_index = new_id_array_index
            e._id_array_subindex = tonumber(new_id_array.size)
            new_id_array.array[new_id_array.size] = e.id
            new_id_array.size = new_id_array.size + 1
            if new_id_array.array[e._id_array_subindex] ~= e.id then
                dump_roots_sample();
                dump_id_array(new_id_array, new_id_array_index);
                fatal(("on_update initial insert verification failed for id=%s at index=%d sub=%d"):format(
                    tostring(e.id), new_id_array_index, e._id_array_subindex))
            end
            dprint(e.id .. " initially inserted to index " .. new_id_array_index .. " at subindex " ..
                       e._id_array_subindex)
            goto continue
        end

        if new_id_array_index ~= old_id_array_index then
            local ok_old, err_old = check_canary(old_id_array_index)
            local ok_new, err_new = check_canary(new_id_array_index)
            if not ok_old then
                dump_roots_sample();
                dump_id_array(id_arrays[old_id_array_index], old_id_array_index);
                fatal("CANARY FAIL old: " .. tostring(err_old))
            end
            if not ok_new then
                dump_roots_sample();
                dump_id_array(id_arrays[new_id_array_index], new_id_array_index);
                fatal("CANARY FAIL new: " .. tostring(err_new))
            end

            local old_id_array = id_arrays[old_id_array_index]
            local new_id_array = id_arrays[new_id_array_index]
            if not old_id_array or not new_id_array then
                fatal(("on_update: expected id_arrays at old=%s new=%s"):format(tostring(old_id_array),
                    tostring(new_id_array)))
            end

            local subindex = e._id_array_subindex
            if subindex == nil or subindex < 0 or subindex >= tonumber(old_id_array.size) then
                dump_id_array(old_id_array, old_id_array_index);
                fatal(("on_update: invalid subindex for %s subindex=%s old_size=%s"):format(tostring(e.id),
                    tostring(subindex), tostring(tonumber(old_id_array.size))))
            end

            local last_pos = tonumber(old_id_array.size) - 1
            if last_pos < 0 then
                fatal(("on_update: old array at %d has negative last_pos"):format(old_id_array_index))
            end
            local last_id = old_id_array.array[last_pos]
            if not is_valid_id(last_id) then
                dump_id_array(old_id_array, old_id_array_index);
                fatal(("on_update: last_id invalid numeric: %s at old_index %d last_pos %d"):format(tostring(last_id),
                    old_id_array_index, last_pos))
            end

            dprint(("MOVE-OUT: old_ptr=%s old_idx=%d sub=%d last_pos=%d last_id=%s"):format(ptr_of(old_id_array),
                old_id_array_index, subindex, last_pos, tostring(last_id)))
            old_id_array.array[subindex] = last_id
            old_id_array.array[last_pos] = 0
            old_id_array.size = last_pos
            if last_id ~= 0 then
                if not entities or not entities[last_id] then
                    dump_id_array(old_id_array, old_id_array_index);
                    fatal(("on_update: moved last_id %d not present in entities after removal"):format(last_id))
                end
                entities[last_id]._id_array_subindex = subindex
            end

            if tonumber(new_id_array.size) >= _id_array_capacity then
                fatal(("on_update: target id_array full at %d"):format(new_id_array_index))
            end
            validate_id_write(e.id)
            validate_subindex_for_write(new_id_array, tonumber(new_id_array.size))
            e._id_array_index = new_id_array_index
            e._id_array_subindex = tonumber(new_id_array.size)
            new_id_array.array[new_id_array.size] = e.id
            new_id_array.size = new_id_array.size + 1
            if new_id_array.array[e._id_array_subindex] ~= e.id then
                dump_roots_sample();
                dump_id_array(new_id_array, new_id_array_index);
                fatal(("on_update: post-insert verification failed for id=%s at index=%d sub=%d"):format(tostring(e.id),
                    new_id_array_index, e._id_array_subindex))
            end

            dprint(e.id .. " moved to index " .. new_id_array_index .. " at subindex " .. e._id_array_subindex)
        end
        ::continue::
    end
end

return spatial_index
