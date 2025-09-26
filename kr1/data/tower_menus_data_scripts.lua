local scripts = {}

function scripts.merge(table1, table2)
    return table.merge(table1, table2, true)
end

return scripts