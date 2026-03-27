local M = {}

function M.register(sys, deps)
	local floor = deps.floor

	function sys.particle_system:init(store)
		self.phase_interp = function(values, phase, default)
			if not values or #values == 0 then
				return default
			end

			if #values == 1 then
				return values[1]
			end

			local intervals = #values - 1
			local interval = floor(phase * intervals)
			local interval_phase = phase * intervals - interval
			local a = values[interval + 1]
			local b = values[interval + 2]
			local ta = type(a)

			if ta == "table" then
				local out = {}

				for i = 1, #a do
					out[i] = a[i] + (b[i] - a[i]) * interval_phase
				end

				return out
			elseif ta == "boolean" then
				return a
			elseif a ~= nil and b ~= nil then
				return a + (b - a) * interval_phase
			end

			return default
		end
	end
end

return M
