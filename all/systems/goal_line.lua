local M = {}

function M.register(sys, deps)
	local perf = deps.perf
	local P = deps.P
	local signal = deps.signal
	local km = deps.km
	local queue_remove = deps.queue_remove

	sys.goal_line = {}
	sys.goal_line.name = "goal_line"

	function sys.goal_line:on_update(dt, ts, store)
		perf.start("goal_line")
		local enemies = store.enemies

		for _, e in pairs(enemies) do
			local node_index = e.nav_path.ni
			local end_node = P:get_end_node(e.nav_path.pi)

			if end_node <= node_index and not P.path_connections[e.nav_path.pi] and e.enemy.remove_at_goal_line then
				signal.emit("enemy-reached-goal", e)
				store.lives = km.clamp(-10000, 10000, store.lives - e.enemy.lives_cost)
				store.player_gold = store.player_gold + e.enemy.gold
				queue_remove(store, e)
			end
		end
		perf.stop("goal_line")
	end
end

return M
