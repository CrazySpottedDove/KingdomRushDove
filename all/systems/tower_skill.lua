local TowerSkill = require("kr1.tower_skill_protocol")

local M = {}
local perf = require("dove_modules.perf.perf")

function M.register(sys)

	sys.tower_skill = {}
	sys.tower_skill.name = "tower_skill"

	function sys.tower_skill:init(store)
		if store.level_mode_override ~= GAME_MODE_ENDLESS then
			return false
		end
	end

	function sys.tower_skill:on_update(dt, ts, store)
		-- 这里只做调度，选目标/结算效果在 protocol 中实现。
		perf.start("tower_skill")
		TowerSkill.tick_all(store)
		perf.stop("tower_skill")
	end
end

return M
