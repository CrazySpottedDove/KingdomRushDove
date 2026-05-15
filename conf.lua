-- chunkname: @./conf.lua
local enabled_console

if arg[2] == "debug" or arg[2] == "release" then
	enabled_console = false
else
	enabled_console = true
end

function love.conf(t)
	t.modules.physics = false
	t.modules.joystick = false
	t.modules.viedo = false
	t.accelerometerjoystick = false
	t.console = enabled_console
end
