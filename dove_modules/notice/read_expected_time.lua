local read_expected_time = {
	reads = {}
}

local AVERAGE_CHARS_PER_MIN = 3000

function read_expected_time.read_start(name, string)
	read_expected_time.reads[name] = {
		start_time = love.timer.getTime(),
		expected_stop_time = love.timer.getTime() + (#string / AVERAGE_CHARS_PER_MIN) * 60
	}
end

function read_expected_time.read_can_stop(name)
	return love.timer.getTime() >= read_expected_time.reads[name].expected_stop_time
end

return read_expected_time
