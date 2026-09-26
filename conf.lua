-- chunkname: @./conf.lua
function love.conf(t)
	t.modules.physics = false
	t.modules.joystick = false
	t.modules.video = false
	t.accelerometerjoystick = false
	t.console = true

	-- 无人值守自动测试（love . -autoplay ...）：窗口不可见，避免打断正在全屏游玩的本体
	local a = rawget(_G, "arg") or {}

	for _, v in pairs(a) do
		if v == "-autoplay" then
			-- LÖVE 11.5 的 conf.lua 不支持 t.window.visible（那是 12 的特性，已被 liblove 忽略），
			-- 所以改用「无边框 + 尺寸很小 + 丢到屏幕外」，尽量不占用户桌面。
			t.window.width = 320
			t.window.height = 240
			t.window.borderless = true
			t.window.x = -32000
			t.window.y = -32000
			t.window.vsync = 0

			break
		end
	end
end
