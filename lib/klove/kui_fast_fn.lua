local M = {
	-- 空 update 实现
	update_empty = function(self, dt)
	end,
	-- 只有自己拥有动画，不调用孩子 update
	update_only_own_animation = function(self, dt)
		if not self.animation.paused then
			self.ts = self.ts + dt
		end
	end,
	-- 只传播给孩子的 update
	update_only_propagate_to_children = function(self, dt)
		for i = 1, #self.children do
			self.children[i]:update(dt)
		end
	end
}

return M
