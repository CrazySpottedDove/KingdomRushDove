local M = {}

function M.register(sys, deps)
	local S = deps.S

	sys.sound_events = {}
	sys.sound_events.name = "sound_events"

	function sys.sound_events:on_insert(entity, store)
		local se = entity.sound_events

		if se and se.insert then
			local sounds = se.insert

			if type(sounds) ~= "table" then
				sounds = {sounds}
			end

			for _, s in pairs(sounds) do
				S:queue(s, se.insert_args)
			end
		end

		return true
	end

	function sys.sound_events:on_remove(entity, store)
		local se = entity.sound_events

		if se then
			if se.remove then
				local sounds = se.remove

				if type(sounds) ~= "table" then
					sounds = {sounds}
				end

				for _, s in pairs(sounds) do
					S:queue(s, se.remove_args)
				end
			end

			if se.remove_stop then
				local sounds = se.remove_stop

				if type(sounds) ~= "table" then
					sounds = {sounds}
				end

				for _, s in pairs(sounds) do
					S:stop(s, se.remove_stop_args)
				end
			end
		end

		return true
	end
end

return M
