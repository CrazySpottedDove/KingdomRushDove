local debug_macros = {}
function debug_macros.print(t, indent_level, printed_tables)
    printed_tables = printed_tables or {}
    indent_level = indent_level or 0
    if type(t) == "table" then
        if printed_tables[t] then
            return
        else
            printed_tables[t] = true
        end
        local indent = string.rep("  ", indent_level)
        print(indent .. "{")
        for k, v in pairs(t) do
            io.write(indent .. "  " .. tostring(k) .. " = ")
            debug_macros.print(v, indent_level + 1, printed_tables)
        end
        print(indent .. "}")
    else
        print(t)
    end
end
return debug_macros