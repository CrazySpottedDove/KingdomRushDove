-- ...existing code...
debug_macros = debug_macros or {}

local function is_identifier(str)
    return type(str) == "string" and str:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function escape_string(s)
    s = s:gsub("\r\n", "\\n"):gsub("\n", "\\n"):gsub("\r", "\\r")
    local q = string.format("%q", s)
    q = q:gsub("\\\\n", "\\n"):gsub("\\\\r", "\\r")
    return q
end

local function format_key(k)
    if type(k) == "string" then
        if is_identifier(k) then
            return k
        else
            return "[" .. escape_string(k) .. "]"
        end
    else
        return "[" .. tostring(k) .. "]"
    end
end

local function sort_keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    return keys
end

local function is_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end
    local n = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
        if k > n then
            n = k
        end
    end
    for i = 1, n do
        if tbl[i] == nil then
            return false
        end
    end
    return true
end

local function value_marker(v)
    local tp = type(v)
    if tp == "function" then
        return "<function>"
    elseif tp == "userdata" then
        return "<userdata>"
    elseif tp == "thread" then
        return "<thread>"
    else
        return tostring(v)
    end
end

local function serialize_impl(t, indent, printed, out)
    printed = printed or {}
    indent = indent or ""
    local tp = type(t)

    if tp == "table" then
        if printed[t] then
            out:write("nil --[[circular reference]]")
            return
        end
        printed[t] = true

        if next(t) == nil then
            out:write("{}")
            return
        end

        if is_array(t) then
            out:write("{\n")
            local n = #t
            for i = 1, n do
                out:write(indent .. "  ")
                serialize_impl(t[i], indent .. "  ", printed, out)
                if i < n then
                    out:write(",")
                end
                out:write("\n")
            end
            out:write(indent .. "}")
            return
        else
            out:write("{\n")
            local keys = sort_keys(t)
            for i, k in ipairs(keys) do
                local v = t[k]
                local key_str
                if type(k) == "string" and is_identifier(k) then
                    key_str = k
                    out:write(indent .. "  " .. key_str .. " = ")
                else
                    out:write(indent .. "  [" .. (type(k) == "string" and escape_string(k) or tostring(k)) .. "] = ")
                end
                serialize_impl(v, indent .. "  ", printed, out)
                out:write(",\n")
            end
            out:write(indent .. "}")
            return
        end
    elseif tp == "string" then
        out:write(escape_string(t))
        return
    elseif tp == "number" or tp == "boolean" then
        out:write(tostring(t))
        return
    else
        -- function / userdata / thread / other -> serialize to a quoted marker so result is valid lua
        local mark = value_marker(t)
        out:write(escape_string(mark))
        return
    end
end

local std_out = {
    write = function(_, s)
        io.write(s)
    end
}

-- 兼容旧用法：debug_macros.print(t) 或 debug_macros.print(t, indent_level...)
-- 新增用法：debug_macros.print(t, filename) 当 filename 为字符串时写入文件，写入格式为 return <lua_table>
function debug_macros.print(t, maybe_filename_or_indent, ...)
    if type(maybe_filename_or_indent) == "string" then
        local fname = "tmp/" .. maybe_filename_or_indent .. ".lua"
        local fh, err = io.open(fname, "w")
        if not fh then
            error("无法打开文件: " .. tostring(err))
        end
        local ok, perr = pcall(function()
            fh:write("return ")
            serialize_impl(t, "", {}, fh)
            fh:write("\n")
        end)
        fh:close()
        if not ok then
            error(perr)
        end
        return
    end

    -- 控制台输出：直接打印序列化的 lua 表（不带 return）
    serialize_impl(t, "", {}, std_out)
    io.write("\n")
end

function debug_macros.trace(t, key)
    local last_key = "_trace_last_" .. key
    if not t[last_key] then
        if type(t[key]) == "table" then
            -- 循环引用会导致错误，慎用
            t[last_key] = table.deepclone(t[key])
        else
            t[last_key] = t[key]
        end
    end
    local last = t[last_key]
    local current = t[key]
    if type(current) == "table" then
        for k, v in pairs(current) do
            if last[k] ~= v then
                serialize_impl(t, "", {}, std_out)
                io.write("\n")
                break
            end
        end
    else
        if last ~= current then
            serialize_impl(t, "", {}, std_out)
            io.write("\n")
        end
    end
end