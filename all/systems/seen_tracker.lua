local M = {}

function M.register(sys)
	local storage = require("all.storage")
	local U = require("utils")
	local signal = require("lib.hump.signal")
	sys.seen_tracker = {}
	sys.seen_tracker.name = "seen_tracker"

	function sys.seen_tracker:init(store)
		require("lib.klua.table")
		local slot = storage:load_slot()

		store.seen = slot.seen and slot.seen or {}
		store.seen_dirty = nil
		self.encyclopedia_map = table.to_map(require("kr1.game_settings").encyclopedia_enemies)
	end

	function sys.seen_tracker:on_insert_unconditional(entity, store)
		if entity.enemy and not entity.ignore_seen_tracker and self.encyclopedia_map[entity.template_name] then
			signal.emit("wave-notification", "icon", entity.template_name)
			U.mark_seen(store, entity.template_name)
		end
	end
end

return M
