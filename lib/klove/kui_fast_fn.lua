local G = love.graphics
local I = require("lib.klove.image_db")
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
	end,
	_draw_children_with_clip_view = function(self)
		local cv = self.clip_view
		local clip_x, clip_y = cv:view_to_view(0, 0, self)
		local clip_xw, clip_yh = cv:view_to_view(cv.size.x, cv.size.y, self)
		local px, py = 0, 0

		for i = 1, #self.children do
			local c = self.children[i]
			if not (c.hidden or (clip_xw < c.pos.x or clip_x > c.pos.x + c.size.x or clip_yh < c.pos.y or clip_y > c.pos.y + c.size.y)) then
				G.translate(c.pos.x - px, c.pos.y - py)
				c:draw()
				px, py = c.pos.x, c.pos.y
			end
		end

		G.translate(-px, -py)
	end,
	_draw_children_with_padding = function(self)
		G.translate(self.padding.x, self.padding.y)
		local px, py = 0, 0

		for i = 1, #self.children do
			local c = self.children[i]
			if not c.hidden then
				G.translate(c.pos.x - px, c.pos.y - py)
				c:draw()
				px, py = c.pos.x, c.pos.y
			end
		end

		G.translate(-px - self.padding.x, -py - self.padding.y)
	end,
	draw_without_clip_and_scroll = function(self)
		local pr, pg, pb, pa = G.getColor()
		local current_alpha = pa * self.alpha

		G.setColor(1, 1, 1, current_alpha)
		G.push()
		-- 转移坐标系
		G.scale(self.scale.x, self.scale.y)
		G.rotate(-self.r)
		G.translate(-self.anchor.x, -self.anchor.y)

		self:_draw_self()
		self:_draw_children()

		if self._focused then
			if self.draw_focus then
				self:draw_focus()
			end

			if self.colors.focused_outline then
				G.setColor_old(self.colors.focused_outline)
				G.rectangle("line", -1, -1, self.size.x + 1, self.size.y + 1)
			end
		end

		G.pop()
		G.setColor(pr, pg, pb, pa)
	end,
	-- 叶子节点
	draw_without_children = function(self)
		local pr, pg, pb, pa = G.getColor()
		local current_alpha = pa * self.alpha

		G.setColor(1, 1, 1, current_alpha)
		G.push()
		-- 转移坐标系
		G.scale(self.scale.x, self.scale.y)
		G.rotate(-self.r)
		G.translate(-self.anchor.x, -self.anchor.y)

		if self.clip then
			if not self.clip_fn then
				self.clip_fn = function()
					G.rectangle("fill", 0, 0, self.size.x, self.size.y)
				end
			end

			G.stencil(self.clip_fn)
			G.setStencilTest("greater", 0)
		end

		self:_draw_self()

		if self.clip then
			G.setStencilTest()
		end

		if self._focused then
			if self.draw_focus then
				self:draw_focus()
			end

			if self.colors.focused_outline then
				G.setColor_old(self.colors.focused_outline)
				G.rectangle("line", -1, -1, self.size.x + 1, self.size.y + 1)
			end
		end

		G.pop()
		G.setColor(pr, pg, pb, pa)
	end,
	-- 无 clip 的叶子节点
	draw_without_children_and_clip = function(self)
		local pr, pg, pb, pa = G.getColor()
		local current_alpha = pa * self.alpha

		G.setColor(1, 1, 1, current_alpha)
		G.push()
		-- 转移坐标系
		G.scale(self.scale.x, self.scale.y)
		G.rotate(-self.r)
		G.translate(-self.anchor.x, -self.anchor.y)

		self:_draw_self()

		if self._focused then
			if self.draw_focus then
				self:draw_focus()
			end

			if self.colors.focused_outline then
				G.setColor_old(self.colors.focused_outline)
				G.rectangle("line", -1, -1, self.size.x + 1, self.size.y + 1)
			end
		end

		G.pop()
		G.setColor(pr, pg, pb, pa)
	end,
	-- 没有孩子，自己也没有回绘制逻辑
	draw_empty = function(self)
	end,
	-- 自己没有绘制逻辑，没有 focuse 逻辑，只是一个逻辑节点，用于管理孩子
	draw_virtual = function(self)
		local pr, pg, pb, pa = G.getColor()
		local current_alpha = pa * self.alpha

		G.setColor(1, 1, 1, current_alpha)
		G.push()
		-- 转移坐标系
		G.scale(self.scale.x, self.scale.y)
		G.rotate(-self.r)
		G.translate(-self.anchor.x, -self.anchor.y)

		self:_draw_children()
		G.pop()
		G.setColor(pr, pg, pb, pa)
	end,
	-- 确认该节点 scale, r, anchor, alpha 都是默认值，且没有 clip, 没有 children, 没有 focus 绘制逻辑，只进行透明的 draw 转发
	draw_transparent = function(self)
		self:_draw_children()
	end,
	_draw_self_KView_no_color = function(self)
		local ss = self.image_ss
		local ref_scale = ss.ref_scale * self.image_scale

		G.draw(self.image, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)
	end,
	_draw_self_KView_no_color_animated = function(self)
		local fn = self:animation_frame(self.animation, self.ts, self.loop, self.fps)
		local ss = I:s(fn)
		self.image_ss = ss
		self.image = I:i(ss.atlas)
		local ref_scale = ss.ref_scale * self.image_scale
		G.draw(self.image, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)
	end,
	_draw_self_KView_colored = function(self)
		local pr, pg, pb, pa = G.getColor()

		if self.colors.background then
			G.setColor(self.colors.background[1] / 255, self.colors.background[2] / 255, self.colors.background[3] / 255, self.colors.background[4] * pa / 255)

			if self.shape then
				local fn = G[self.shape.name]

				if fn then
					fn(unpack(self.shape.args))
				end
			else
				G.rectangle("fill", 0, 0, self.size.x, self.size.y)
			end
		end

		if self.colors.tint then
			local tint = self.colors.tint

			G.setColor(tint[1], tint[2], tint[3], tint[4] * pa)
		end

		local ss = self.image_ss
		local ref_scale = ss.ref_scale * self.image_scale

		G.draw(self.image, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)

		G.setColor(pr, pg, pb, pa)
	end,
	_draw_self_KView_colored_animated = function(self)
		local pr, pg, pb, pa = G.getColor()

		if self.colors.background then
			G.setColor(self.colors.background[1] / 255, self.colors.background[2] / 255, self.colors.background[3] / 255, self.colors.background[4] * pa / 255)

			if self.shape then
				local fn = G[self.shape.name]

				if fn then
					fn(unpack(self.shape.args))
				end
			else
				G.rectangle("fill", 0, 0, self.size.x, self.size.y)
			end
		end

		if self.colors.tint then
			local tint = self.colors.tint

			G.setColor(tint[1], tint[2], tint[3], tint[4] * pa)
		end

		local fn = self:animation_frame(self.animation, self.ts, self.loop, self.fps)
		local ss = I:s(fn)
		self.image_ss = ss
		self.image = I:i(ss.atlas)
		local ref_scale = ss.ref_scale * self.image_scale
		G.draw(self.image, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)
		G.setColor(pr, pg, pb, pa)
	end
}

return M
