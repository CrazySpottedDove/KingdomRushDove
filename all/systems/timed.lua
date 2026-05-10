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

	function sys.timed:on_render_update(dt, ts, store)
		perf.start("timed")
		local entities = store.entities_with_timed

		for _, e in pairs(entities) do
			local s = e.render.sprites[e.timed.sprite_id]

			-- if e.timed.disabled then
			-- -- block empty
			-- elseif s.ts == store.tick_ts then
			-- -- block empty
			-- elseif e.timed.runs and s.runs >= e.timed.runs or e.timed.duration and store.tick_ts - s.ts > e.timed.duration then
			-- 	queue_remove(store, e)
			-- end
			-- 如果 timed 系统排在 render 系统之前更新，那么某些地方启动 timed 的时候，可能将 timed.runs 置为 1，但是此时，render 系统没有更新，s.runs 可能远大于 e.timed.runs，导致实体直接被删除。所以，应该把 timed 系统放在 render 系统之后更新。
			if s.runs >= e.timed.runs or store.tick_ts - s.ts > e.timed.duration then
				queue_remove(store, e)
			end
		end

		perf.stop("timed")
	end
end

return M
