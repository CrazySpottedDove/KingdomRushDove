local M = {
	max_fps = 144,
	min_fps = 30,
	counter = 0,
	scene = nil
}
local perf = require("dove_modules.perf.perf")
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

function M:set_fps(fps)
	self.fps = fps
	self.tick_length = 1 / self.fps
	self.scene.simulation.store.tick_length = math.min(self.tick_length * math.max(self.scene.simulation.store.speed_factor, 1), 1 / self.min_fps)
	self.scene.limit_fps = self.fps
end

function M:update(dt)
	if dt > self.tick_length * 1.1 then
		self.counter = self.counter + 1
		if self.counter > 5 then
			self.counter = 0
			if self.fps > self.min_fps then
				self:set_fps(math.max(self.min_fps, 1 / dt))
			end
		end
		-- 如果 dt 太大了，说明性能不足了，这时候不可以直接返回 dt，否则大的耗时会进一步放大下一次 dt，造成游戏卡死。这里使用 min_fps 来限制 dt 的最大值，来避免这种情况的发生。
		if dt * self.min_fps > 1 then
			return 1 / self.min_fps
		else
			return dt
		end
	elseif self.max_fps > self.fps then
		self.counter = self.counter - 1
		if self.counter < -5 then
			self.counter = 0
			self:set_fps(math.floor(self.fps + 1))
		end
		return dt
	end
	self.counter = 0
	return dt
end

return M
