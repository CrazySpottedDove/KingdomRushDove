local M = {}

function M.register(sys, deps)
	sys.events = {}
	sys.events.name = "events"

	function sys.events:init(store)
		store.event_handlers = {}
	end

	function sys.events:on_insert(entity, store)
		if entity.events then
			for _, ev in pairs(entity.events.list) do
				if not store.event_handlers[ev.name] then
					store.event_handlers[ev.name] = {}
				end

				ev.entity_id = entity.id
				table.insert(store.event_handlers[ev.name], ev)
			end
		end

		return true
	end

	function sys.events:on_remove(entity, store)
		if entity.events then
			for _, ev in pairs(entity.events.list) do
				if store.event_handlers[ev.name] then
					table.removeobject(store.event_handlers[ev.name], ev)
				end
			end
		end

		return true
	end
end

return M
