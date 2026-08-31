local V = require("lib.klua.vector")
local perf = require("dove_modules.perf.perf")

local lights = {}
lights.name = "lights"

function lights:init(store)
	store.lights = {}
	store.entities_with_lights = {}
end

function lights:on_insert_unconditional(entity, store)
	if entity.lights then
		store.entities_with_lights[entity.id] = entity
		for i = 1, #entity.lights do
			local l = entity.lights[i]

			l.pos = V.v(entity.pos.x, entity.pos.y)
			store.lights[#store.lights + 1] = l
		end
	end
end

function lights:on_remove_unconditional(entity, store)
	if entity.lights then
		store.entities_with_lights[entity.id] = nil
		for i = #entity.lights, 1, -1 do
			entity.lights[i].marked_to_remove = true
		end
	end
end

function lights:on_update(dt, ts, store)
	perf.start("lights")
	local d = store
	local entities = d.entities_with_lights
	local new_lights = {}

	for _, e in pairs(entities) do
		for i = 1, #e.lights do
			local l = e.lights[i]

			if not l.marked_to_remove then
				l.pos.x, l.pos.y = e.pos.x, e.pos.y
				new_lights[#new_lights + 1] = l
			end
		end
	end

	if #new_lights > 0 then
		d.lights = new_lights
	end
	perf.stop("lights")
end

return lights
