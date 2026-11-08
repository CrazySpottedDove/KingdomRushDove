-- 会话 / 时间推进 / 断言类命令。
local conditions = require("dove_modules.test.conditions")
local session = {}

function session.ping()
	return {
		pong = true
	}
end

function session.status(harness)
	return harness:snapshot()
end

function session.quit(harness, args)
	harness:quit(args.code or 0)

	return {
		quit = true
	}
end

function session.tick(harness, args)
	return harness:tick(args.n or 1)
end

function session.set_render(harness, args)
	harness.render = args.enabled ~= false

	return {
		render = harness.render
	}
end

function session.run_until(harness, args)
	local condition = conditions.resolve(args.condition)
	local fps = (args.fps and tonumber(args.fps)) or DRAW_FPS
	local max_ticks = tonumber(args.max_ticks) or (tonumber(args.max_sim_seconds) and tonumber(args.max_sim_seconds) * fps) or (60 * 60 * fps)
	local load_timeout_ms = tonumber(args.load_timeout_ms) or 30000
	local wall_timeout_ms = tonumber(args.timeout_ms)
	local started = love.timer.getTime()
	local ticks = 0

	if condition(harness, args) then
		return {
			met = true,
			ticks = 0,
			state = harness:snapshot()
		}
	end

	while ticks < max_ticks do
		harness:step_once()

		ticks = ticks + 1

		if condition(harness, args) then
			return {
				met = true,
				ticks = ticks,
				state = harness:snapshot()
			}
		end

		local now = love.timer.getTime()

		if wall_timeout_ms and wall_timeout_ms > 0 and (now - started) * 1000 >= wall_timeout_ms then
			return {
				met = false,
				reason = "wall_timeout",
				ticks = ticks,
				state = harness:snapshot()
			}
		end

		-- 场景加载依赖后台线程；不要让 director:update 空转把 CPU 吃满。
		if not harness:get_game() and (now - started) * 1000 >= load_timeout_ms then
			return {
				met = false,
				reason = "load_timeout",
				ticks = ticks,
				state = harness:snapshot()
			}
		end

		if ticks % 64 == 0 and not harness:get_game() then
			love.timer.sleep(0.001)
		end
	end

	return {
		met = false,
		reason = "max_ticks",
		ticks = ticks,
		state = harness:snapshot()
	}
end

function session.log_errors(harness)
	return {
		errors = harness.log_errors
	}
end

function session.clear_log_errors(harness)
	harness.log_errors = {}

	return {
		cleared = true
	}
end

session["assert"] = function(harness, args)
	local value = harness

	for part in tostring(args.path or ""):gmatch("[^%.]+") do
		if type(value) ~= "table" then
			error("assert path not found: " .. tostring(args.path))

			return
		end

		value = value[part]
	end

	if args.equals ~= nil and value ~= args.equals then
		error(string.format("assert failed: %s = %s, expected %s", tostring(args.path), tostring(value), tostring(args.equals)))
	end

	if args.truthy and not value then
		error(string.format("assert failed: %s is falsy", tostring(args.path)))
	end

	return {
		value = value
	}
end

function session.assert_no_log_errors(harness)
	if #harness.log_errors > 0 then
		local first = harness.log_errors[1]

		error(string.format("log.error present (%d), first: %s: %s", #harness.log_errors, tostring(first.logger), tostring(first.message)))
	end

	return {
		ok = true
	}
end

function session.wait(harness, args)
	local ms = tonumber(args.ms) or 0
	local started = love.timer.getTime()

	while (love.timer.getTime() - started) * 1000 < ms do
		love.timer.sleep(0.001)

		if args.pump ~= false then
			harness:step_once()
		end
	end

	return {
		ms = ms
	}
end

return session
