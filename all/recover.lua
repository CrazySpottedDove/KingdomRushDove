local recover = {}

local function serialize(t, printed, out)
    printed = printed or {}
    local tp = type(t)
    if tp == "table" then
        if printed[t] then
            return
        end
        printed[t] = true
        if next(t) == nil then
            out:write("{}")
        end
        out:write("{")
        for k, v in pairs(t) do
            out:write("[\"")
            out:write(k)
            out:write("\"]=")
            serialize(v, printed, out)
            out:write(",")
        end
        out:write("}")
    elseif tp == "string" then
        out:write(t)
    elseif tp == "number" or tp == "boolean" then
        out:write(tostring(t))
    end
end

function recover.save(store)
    
end
