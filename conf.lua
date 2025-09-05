-- chunkname: @./conf.lua
if arg[2] == "debug" or arg[2] == "release" then
	v = false
else
	v = true
end

function love.conf(t)
	t.modules.physics = false
	t.console = v
end
