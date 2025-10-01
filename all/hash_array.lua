local hash_array = {}
hash_array.__index = hash_array

--- Creates a new hash_array instance
--- All the item in hash_array must have a unique 'id' field
function hash_array:new()
    return setmetatable({
        array = {}, -- 数组，提供高效的遍历
        hashmap = {}, -- 哈希表，提供高效的查找和删除
        size = 0 -- 元数据，记录当前元素数量
    }, hash_array)
end

function hash_array:insert(item)
    self.size = self.size + 1
    self.array[self.size] = item
    self.hashmap[item.id] = self.size
end

function hash_array:remove(item)
    local hashkey = item.id
    local index = self.hashmap[hashkey]
    self.hashmap[hashkey] = nil
    if index == self.size then
        self.array[index] = nil
    else
        local last_item = self.array[self.size]
        self.array[index] = last_item
        self.hashmap[last_item.id] = index
        self.array[self.size] = nil
    end
    self.size = self.size - 1
end

function hash_array:iter()
    local i = 0
    local iter_size = self.size
    return function()
        i = i + 1
        if i <= iter_size then
            return self.array[i]
        end
    end
end

return hash_array