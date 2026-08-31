local events = {}

events.name = "events"

function events:init(store)
	store.event_handlers = {}
end

function events:on_insert_unconditional(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if not store.event_handlers[ev.name] then
				store.event_handlers[ev.name] = {}
			end

			ev.entity_id = entity.id
			table.insert(store.event_handlers[ev.name], ev)
		end
	end
end

function events:on_remove_unconditional(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if store.event_handlers[ev.name] then
				table.removeobject(store.event_handlers[ev.name], ev)
			end
		end
	end
end

return events
