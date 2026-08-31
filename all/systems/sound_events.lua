local sound_events = {}

local S = require("sound_db")

sound_events.name = "sound_events"

function sound_events:on_insert_unconditional(entity, store)
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
end

function sound_events:on_remove_unconditional(entity, store)
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
end

return sound_events
