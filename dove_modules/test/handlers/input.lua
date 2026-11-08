-- 原始输入命令：坐标/按键都走 director 的真实分发路径。
local input = {}

function input.click_at(harness, args)
	local x = tonumber(args.x)
	local y = tonumber(args.y)

	if not x or not y then
		error("click_at requires x and y")
	end

	local button = tonumber(args.button) or 1

	harness.director:mousepressed(x, y, button)
	harness.director:mousereleased(x, y, button)

	return {
		x = x,
		y = y,
		button = button
	}
end

function input.mouse_down(harness, args)
	local x = tonumber(args.x)
	local y = tonumber(args.y)

	if not x or not y then
		error("mouse_down requires x and y")
	end

	local button = tonumber(args.button) or 1

	harness.director:mousepressed(x, y, button)

	return {
		x = x,
		y = y,
		button = button
	}
end

function input.mouse_up(harness, args)
	local x = tonumber(args.x)
	local y = tonumber(args.y)

	if not x or not y then
		error("mouse_up requires x and y")
	end

	local button = tonumber(args.button) or 1

	harness.director:mousereleased(x, y, button)

	return {
		x = x,
		y = y,
		button = button
	}
end

function input.mouse_move(_, args)
	local x = tonumber(args.x) or 0
	local y = tonumber(args.y) or 0

	love.mouse.setPosition(x, y)

	return {
		x = x,
		y = y
	}
end

function input.key_down(harness, args)
	if not args.key then
		error("key_down requires key")
	end

	harness.director:keypressed(args.key, args["repeat"] == true)

	return {
		key = args.key
	}
end

function input.key_up(harness, args)
	if not args.key then
		error("key_up requires key")
	end

	harness.director:keyreleased(args.key, args["repeat"] == true)

	return {
		key = args.key
	}
end

function input.key(harness, args)
	input.key_down(harness, args)
	input.key_up(harness, args)

	return {
		key = args.key
	}
end

function input.text(harness, args)
	if args.text == nil then
		error("text requires text")
	end

	harness.director:textinput(tostring(args.text))

	return {
		text = args.text
	}
end

function input.wheel(harness, args)
	local dx = tonumber(args.dx) or 0
	local dy = tonumber(args.dy) or 0

	harness.director:wheelmoved(dx, dy)

	return {
		dx = dx,
		dy = dy
	}
end

return input
