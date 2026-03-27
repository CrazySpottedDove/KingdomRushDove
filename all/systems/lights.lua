local M = {}

function M.register(sys, deps)
	local perf = deps.perf

	sys.lights = {}
	sys.lights.name = "lights"

	function sys.lights:init(store)
		store.lights = {}
	end

	function sys.lights:on_insert(entity, store)
		local d = store

		if entity.lights then
			for i = 1, #entity.lights do
				local l = entity.lights[i]

				l.pos = {
					x = entity.pos.x,
					y = entity.pos.y
				}
				d.lights[#d.lights + 1] = l
			end
		end

		return true
	end

	function sys.lights:on_remove(entity, store)
		if entity.lights then
			for i = #entity.lights, 1, -1 do
				entity.lights[i].marked_to_remove = true
			end
		end

		return true
	end

	function sys.lights:on_update(dt, ts, store)
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
end

return M
