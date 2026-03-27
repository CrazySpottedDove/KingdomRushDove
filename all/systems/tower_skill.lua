local TowerSkill = require("kr1.tower_skill_protocol")

local M = {}

function M.register(sys, deps)
	local perf = deps.perf

	sys.tower_skill = {}
	sys.tower_skill.name = "tower_skill"

	function sys.tower_skill:on_update(dt, ts, store)
		-- 塔专属技能只在无尽里跑，避免影响主线平衡。
		if store.level_mode_override ~= GAME_MODE_ENDLESS then
			return
		end

		-- 这里只做调度，选目标/结算效果在 protocol 中实现。
		perf.start("tower_skill")
		TowerSkill.tick_all(store)
		perf.stop("tower_skill")
	end
end

return M
