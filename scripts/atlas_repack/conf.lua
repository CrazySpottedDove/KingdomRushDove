function love.conf(t)
	-- 隐藏窗口：PNG 重排不需要 GPU，但 --repack-dds 需要 GPU 解码 DDS
	t.window = {
		width = 64,
		height = 64,
		visible = false
	}
	t.modules.audio = false
	t.modules.sound = false
	t.modules.font = false
	t.modules.joystick = false
	t.modules.mouse = false
	t.modules.keyboard = false
	t.modules.touch = false
	t.modules.physics = false
	t.modules.thread = false
	t.modules.video = false
	t.modules.timer = false
	t.modules.image = true
	t.modules.data = true
	t.modules.filesystem = true
	t.modules.event = true
end
