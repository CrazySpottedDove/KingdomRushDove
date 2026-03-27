local M = {}

function M.register(sys, deps)
	local perf = deps.perf
	local queue_remove = deps.queue_remove

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
