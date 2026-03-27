local M = {}

function M.register(sys, deps)
	local km = deps.km
	local signal = deps.signal

	sys.count_groups = {}
	sys.count_groups.name = "count_groups"

	function sys.count_groups:init(store)
		store.count_groups = {}
		store.count_groups[COUNT_GROUP_CONCURRENT] = {}
		store.count_groups[COUNT_GROUP_CUMULATIVE] = {}
	end

	function sys.count_groups:on_queue(entity, store, insertion)
		if insertion and entity.count_group then
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
			signal.emit("count-group-changed", entity, g[c.type][c.name], 1)
		end
	end

	function sys.count_groups:on_dequeue(entity, store, insertion)
		if insertion then
			self:on_remove(entity, store)
		end
	end

	function sys.count_groups:on_remove(entity, store)
		if entity.count_group and not entity.count_group.in_limbo and entity.count_group.type == COUNT_GROUP_CONCURRENT then
			local c = entity.count_group
			local g = store.count_groups

			g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)
			signal.emit("count-group-changed", entity, g[c.type][c.name], -1)
		end

		return true
	end
end

return M
