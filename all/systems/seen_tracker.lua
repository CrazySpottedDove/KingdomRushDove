local M = {}

local storage = require("all.storage")
local perf = require("dove_modules.perf.perf")
local U = require("utils")

function M.register(sys)

	sys.seen_tracker = {}
	sys.seen_tracker.name = "seen_tracker"

	function sys.seen_tracker:init(store)
		local slot = storage:load_slot()

		store.seen = slot.seen and slot.seen or {}
		store.seen_dirty = nil
	end

	function sys.seen_tracker:on_insert_unconditional(entity, store)
		if (entity.tower or entity.enemy) and not entity.ignore_seen_tracker then
			U.mark_seen(store, entity.template_name)
		end

	-- return true
	end

	function sys.seen_tracker:on_update(dt, ts, store)
		perf.start("seen_tracker")
		if store.seen_dirty then
			local slot = storage:load_slot()

			slot.seen = store.seen

			storage:save_slot(slot)

			store.seen_dirty = false
		end
		perf.stop("seen_tracker")
	end
end

return M
