local count_groups = {}

local signal = require("lib.hump.signal")
local km = require("lib.klua.macros")

count_groups.name = "count_groups"

function count_groups:init(store)
	store.count_groups = {}
	store.count_groups[COUNT_GROUP_CONCURRENT] = {}
	store.count_groups[COUNT_GROUP_CUMULATIVE] = {}
end

function count_groups:on_insert_unconditional(entity, store)
	if entity.count_group then
		local c = entity.count_group

		if c.in_limbo then
			c.in_limbo = nil
			return true
		end

		local g = store.count_groups

		if not g[c.type][c.name] then
			g[c.type][c.name] = 0
		end

		g[c.type][c.name] = g[c.type][c.name] + 1
	end
end

function count_groups:on_remove_unconditional(entity, store)
	if entity.count_group and not entity.count_group.in_limbo and entity.count_group.type == COUNT_GROUP_CONCURRENT then
		local c = entity.count_group
		local g = store.count_groups

		g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)
	end
end

return count_groups
