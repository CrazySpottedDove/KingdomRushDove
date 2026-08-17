-- chunkname: @./conf.lua
function love.conf(t)
	t.modules.physics = false
	t.modules.joystick = false
	t.modules.video = false
	t.accelerometerjoystick = false
	t.console = true
end
