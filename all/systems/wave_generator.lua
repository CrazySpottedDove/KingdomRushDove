local M = {}

function M.register(sys, deps)
	local E = deps.E

	if GEN_WAVES_ENABLED then
		sys.wave_generator = {}
		sys.wave_generator.name = "wave_generator"

		function sys.wave_generator:init(store)
			E:gen_wave(store.level_idx, store.level_mode)
		end
	end
end

return M
