local M = {}

local signal = require("lib.hump.signal")
local km = require("lib.klua.macros")
local P = require("path_db")

function M.register(sys)
	sys.goal_line = {}
	sys.goal_line.name = "goal_line"

	function sys.goal_line:on_update(dt, ts, store)
		local enemies = store.enemies

		for _, e in pairs(enemies) do
			local node_index = e.nav_path.ni
			local pi = e.nav_path.pi
			local end_node = P.path_end_node[pi] or #P.paths[pi]

			if end_node <= node_index and not P.path_connections[pi] and e.enemy.remove_at_goal_line then
				signal.emit("enemy-reached-goal", e)
				store.lives = km.clamp(-1000000, 1000000, store.lives - e.enemy.lives_cost)
				store.player_gold = store.player_gold + e.enemy.gold
				simulation:queue_remove_entity(e)
			end
		end
	end
end

return M
