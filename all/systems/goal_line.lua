local M = {}

local perf = require("dove_modules.perf.perf")
local signal = require("lib.hump.signal")
local km = require("lib.klua.macros")
local P = require("path_db")

function M.register(sys)

	local function queue_insert(store, e)
		simulation:queue_insert_entity(e)
	end

	local function queue_remove(store, e)
		simulation:queue_remove_entity(e)
	end

	sys.goal_line = {}
	sys.goal_line.name = "goal_line"

	function sys.goal_line:on_update(dt, ts, store)
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
	end
end

return M
