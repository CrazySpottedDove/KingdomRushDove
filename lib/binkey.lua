local binary_key = {}

function binary_key.define_keys(self, keys)
    for _, key in ipairs(keys) do
        self:define_key(key)
    end
end

function binary_key.define_key(self, key)
    self.keys[key] = self.base
    self.base = self.base * 2
end

function binary_key.calculate_key(self, e)
    local result = 0
    for key, value in pairs(self.keys) do
        if e[key] then
            result = result + value
        end
    end
    return result
end

function binary_key.new()
    local group = {
        base = 1,
        keys = {},
    }
    return setmetatable(group, { __index = binary_key })
end

return binary_key