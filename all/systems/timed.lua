local M = {}

local perf = require("dove_modules.perf.perf")

function M.register(sys)

	local function queue_insert(store, e)
		simulation:queue_insert_entity(e)
	end

	local function queue_remove(store, e)
		simulation:queue_remove_entity(e)
	end

	sys.timed = {}
	sys.timed.name = "timed"

	function sys.timed:on_update(dt, ts, store)
		perf.start("timed")
		local entities = store.entities_with_timed

		for _, e in pairs(entities) do
			local s = e.render.sprites[e.timed.sprite_id]

			if e.timed.disabled then
			-- block empty
			elseif s.ts == store.tick_ts then
			-- block empty
			elseif e.timed.runs and s.runs == e.timed.runs or e.timed.duration and store.tick_ts - s.ts > e.timed.duration then
				queue_remove(store, e)
			end
		end

		perf.stop("timed")
	end
end

return M
