local M = {}

function M.register(sys, deps)
	local perf = deps.perf

	sys.hero_xp_tracking = {}
	sys.hero_xp_tracking.name = "hero_xp_tracking"

	function sys.hero_xp_tracking:on_update(dt, ts, store)
		perf.start("hero_xp_tracking")
		for i = 1, #store.damages_applied do
			local d = store.damages_applied[i]

			if d.xp_gain_factor and d.xp_gain_factor > 0 and d.damage_applied > 0 then
				local id = d.xp_dest_id or d.source_id
				local e = store.entities[id]

				if e and e.hero then
					local amount = d.damage_applied * d.xp_gain_factor
					e.hero.xp_queued = e.hero.xp_queued + amount
				end
			end
		end
		perf.stop("hero_xp_tracking")
	end
end

return M
