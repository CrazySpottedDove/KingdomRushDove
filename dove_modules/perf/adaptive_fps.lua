local M = {
	max_fps = 144,
	min_fps = 30,
	counter = 0,
	scene = nil
}

-- Called once on game init to bind to the game scene
function M:set_scene(scene)
	self.scene = scene
	self.counter = 0
	-- scene 的初始 max_fps 意味着渲染的最高帧率，max_fps 大于这个值是没有意义的
	self.max_fps = scene.max_fps
	self.fps = scene.max_fps
	self.tick_length = 1 / self.fps
end

function M:destroy()
	self.scene = nil
end

function M:update(dt)
	if dt > self.tick_length * 1.1 then
		self.counter = self.counter + 1
		if self.counter > 5 then
			self.counter = 0
			if self.fps > self.min_fps then
				self.fps = math.max(self.min_fps, 1 / dt)
				self.tick_length = 1 / self.fps
				self.scene.simulation.store.tick_length = self.tick_length
				self.scene.limit_fps = self.fps
			end
		end
		return self.tick_length
	elseif self.max_fps > self.fps then
		self.counter = self.counter - 1
		if self.counter < -5 then
			self.counter = 0

			if self.max_fps > self.fps then
				self.fps = self.fps + 1
				self.tick_length = 1 / self.fps
				self.scene.simulation.store.tick_length = self.tick_length
				self.scene.limit_fps = self.fps
			end
		end
		return dt
	end
	return dt
end

return M
