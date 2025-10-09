local input_file = arg[1]
local file_name = string.match(input_file, "([^/]+)%.lua$")
local output_file = "tmp/" .. file_name .. ".lua"
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
local path_data = load_table_from_file(input_file)
local paths = path_data.paths

-- paths: 形如 paths = {{{{x=...,y=...},...}, ...}, ...}
-- 返回 curves: {{nodes = {...}, widths = {...}}, ...}
local function generate_curves_from_paths(paths, default_width)
    default_width = default_width or 40
    local curves = {}
    for i, path_group in ipairs(paths) do
        local nodes = {}
        local widths = {}
        local path_branch = path_group[1]

            for k, pt in ipairs(path_branch) do
                table.insert(nodes, {
                    x = pt.x,
                    y = pt.y
                })
                table.insert(widths, default_width)
            end
        
        table.insert(curves, {
            nodes = nodes,
            widths = widths
        })
    end
    return curves
end


-- 用法示例
-- local curves = generate_curves_from_paths(paths, 40)

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
                -- 先把换行替换成 \n
                local s = v:gsub("\n", "\\n")
                -- 再用 %q 转义
                val_str = string.format("%q", s)
                -- 再把 \\n 还原成 \n（去掉多余的转义）
                val_str = val_str:gsub("\\\\n", "\\n")
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
                -- 先把换行替换成 \n
                local s = v:gsub("\n", "\\n")
                -- 再用 %q 转义
                val_str = string.format("%q", s)
                -- 再把 \\n 还原成 \n（去掉多余的转义）
                val_str = val_str:gsub("\\\\n", "\\n")
            else
                val_str = tostring(v)
            end

            table.insert(lines, string.format("%s    %s = %s,", indent, key_str, val_str))
        end
    end

    table.insert(lines, indent .. "}")

    return table.concat(lines, "\n")
end
path_data.curves = generate_curves_from_paths(paths)
local f = assert(io.open(output_file, "w"))
f:write("return ")
f:write(serialize(path_data, ""))
f:write("\n")
f:close()
