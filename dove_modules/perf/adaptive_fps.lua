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
				-- fps: 标准 fps，即绘制层的更新 fps。
				self.fps = math.max(self.min_fps, 1 / dt)
				-- tick_length: 绘制层的更新周期
				self.tick_length = 1 / self.fps
				-- 当玩家选择了倍速的时候，如果发现帧率不稳定了，则在合理的区间内，适当提高 store.tick_length，从而减少需要执行 update 的次数，来降低 CPU 的更新压力
				self.scene.simulation.store.tick_length = math.min(self.tick_length * math.max(self.scene.simulation.store.speed_factor, 1), 1 / self.min_fps)
				self.scene.limit_fps = self.fps
			end
		end
		return self.tick_length
	elseif self.max_fps > self.fps then
		self.counter = self.counter - 1
		if self.counter < -5 then
			self.counter = 0

			if self.max_fps > self.fps then
				-- 慢慢回升 fps，避免突然提升 fps 导致的性能问题
				self.fps = math.floor(self.fps + 1)
				self.tick_length = 1 / self.fps
				self.scene.simulation.store.tick_length = math.min(self.tick_length * math.max(self.scene.simulation.store.speed_factor, 1), 1 / self.min_fps)
				self.scene.limit_fps = self.fps
			end
		end
		return dt
	end
	self.counter = 0
	return dt
end

return M
