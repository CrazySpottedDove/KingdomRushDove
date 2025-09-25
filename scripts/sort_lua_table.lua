-- sort_lua_table.lua

local input_file = arg[1]
local output_file = "tmp/sorted_table.lua"
if not input_file then
    print("Usage: lua sort_lua_table.lua <input_file>")
    os.exit(1)
end
---合并两个表（递归合并，数组去重合并）
---@param t1 table 表1
---@param t2 table 表2
---@return table 合并后的新表
local function merge_tables(t1, t2)
    local merged = {}

    -- 遍历 t1 的所有键值对
    for key, value in pairs(t1) do
        if t2[key] then
            -- 如果 t2 中也有相同的键，并且值是表
            if type(value) == "table" and type(t2[key]) == "table" then
                -- 如果是数组（所有键是连续的数字），合并数组
                if #value > 0 and #t2[key] > 0 then
                    local set = {}
                    for _, v in ipairs(value) do
                        set[v] = true
                    end
                    for _, v in ipairs(t2[key]) do
                        set[v] = true
                    end
                    merged[key] = {}
                    for v, _ in pairs(set) do
                        table.insert(merged[key], v)
                    end
                else
                    -- 否则递归合并
                    merged[key] = merge_tables(value, t2[key])
                end
            else
                -- 如果不是表，优先保留 t1 的值
                merged[key] = value
            end
        else
            -- 如果 t2 中没有这个键，直接保留 t1 的值
            merged[key] = value
        end
    end

    -- 遍历 t2 的所有键值对，添加 t1 中没有的键
    for key, value in pairs(t2) do
        if not t1[key] then
            merged[key] = value
        end
    end

    return merged
end

---合并两个表（仅添加 t2 中 t1 没有的键）
---@param t1 table 表1
---@param t2 table 表2
---@return table 合并后的新表
local function merge_conflict_tables(t1, t2)
    local merged = {}

    -- 遍历 t1 的所有键值对
    for key, value in pairs(t1) do
        merged[key] = value
    end

    -- 遍历 t2 的所有键值对，添加 t1 中没有的键
    for key, value in pairs(t2) do
        if not t1[key] then
            merged[key] = value
        end
    end

    return merged
end

local script_utils = {
    merge_tables = merge_tables,
    merge_conflict_tables = merge_conflict_tables,
}
package.loaded["script_utils"] = script_utils

-- 加载数据表
local function load_table_from_file(filename)
    local f = assert(io.open(filename, "r"))
    local content = f:read("*a")
    f:close()
    -- 加载为函数
    local chunk, err = load(content, "@" .. filename, "t", _ENV)
    if not chunk then
        error("加载文件失败: " .. err)
    end
    return chunk()
end

-- 加载数据表
local tbl = load_table_from_file(input_file)
local function is_identifier(str)
    return type(str) == "string" and str:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function is_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end
    local i = 0
    for _ in pairs(tbl) do
        i = i + 1
        if tbl[i] == nil then
            return false
        end
    end
    return true
end

local function serialize(tbl, indent)
    indent = indent or ""
    local lines = {}
    table.insert(lines, "{")
    if is_array(tbl) then
        for i = 1, #tbl do
            local v = tbl[i]
            local val_str
            if type(v) == "table" then
                val_str = serialize(v, indent .. "    ")
            elseif type(v) == "string" then
                val_str = string.format("%q", v)
            else
                val_str = tostring(v)
            end
            table.insert(lines, string.format("%s    %s,", indent, val_str))
        end
    else
        -- 收集并排序键
        local keys = {}
        for k in pairs(tbl) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        for _, k in ipairs(keys) do
            local v = tbl[k]
            local key_str
            if is_identifier(k) then
                key_str = k
            elseif type(k) == "string" then
                key_str = string.format("[%q]", k)
            else
                key_str = string.format("[%s]", tostring(k))
            end
            local val_str
            if type(v) == "table" then
                val_str = serialize(v, indent .. "    ")
            elseif type(v) == "string" then
                val_str = string.format("%q", v)
            else
                val_str = tostring(v)
            end
            table.insert(lines, string.format("%s    %s = %s,", indent, key_str, val_str))
        end
    end
    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
end

-- 输出到文件
local f = assert(io.open(output_file, "w"))
f:write("return ")
f:write(serialize(tbl, ""))
f:write("\n")
f:close()

