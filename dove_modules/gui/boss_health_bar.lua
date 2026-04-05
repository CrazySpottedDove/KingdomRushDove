require("klove.kui")
local class = require("middleclass")
local timer = require("hump.timer"):new()
local BossHealthBar = class("BossHealthBar", KView)
local G = love.graphics
local F = require("lib.klove.font_db")
local I = require("lib.klove.image_db")
local background_width = 440
local background_height = 42
local healthbar_left_padding = 40
local healthbar_right_padding = 8
local healthbar_up_padding = 26
local healthbar_bottom_padding = 8
local text_up_padding = 6
local healthbar_height = background_height - healthbar_up_padding - healthbar_bottom_padding
local healthbar_width = background_width - healthbar_left_padding - healthbar_right_padding
local fade_in_time = 0.5
local fade_out_time = 0.5

function BossHealthBar:initialize(sw)
	KView.initialize(self, nil)
	self.pos.x = (sw - background_width) / 2
	self.pos.y = 20
	self.health_percent = 1
	self.boss_name = "BOSS_NAME"
	self.portrait = nil
	self.portrait_ss = nil
	self.hidden = true
	self.entities = {}
	self.prime_entity = nil
	self.font = F:f("button", 12)
	self.hp_lag = 1
	self.time = 0
	self.store = nil
	-- 渐变效果相关属性
	self.alpha = 0 -- 整体透明度（用于显示/隐藏渐变）
	self.show_alpha = 0 -- 显示状态透明度
	self.pulse_alpha = 0 -- 脉冲效果透明度
	self.color_shift = 0 -- 颜色偏移（用于血量变化时的颜色渐变）
	self.shake_offset = { -- 震动偏移
		x = 0,
		y = 0
	}
	self.is_animating = false
	-- Timer句柄管理，避免冲突
	self.active_timers = {
		flash = nil, -- 闪烁效果timer
		show = {}, -- 显示动画timer组
		hide = {}, -- 隐藏动画timer组
		shake = {} -- 震动效果timer组
	}
	return self
end

function BossHealthBar:set_entity_info(entity)
	self.time = 0
	self.health_percent = entity.health.hp / entity.health.hp_max
	self.hp_lag = self.health_percent
	self.portrait_ss = I:s(entity.info.portrait)
	self.portrait = I:i(self.portrait_ss.atlas)
	self.boss_name = _(entity.info.i18n_key and entity.info.i18n_key .. "_NAME" or string.upper(entity.template_name) .. "_NAME")
end

--- 将一个 boss 实体加入 boss_health_bar 的显示队列中。该实体必须已经在 store 中。
---@param entity table
---@param store table
function BossHealthBar:enable_with(entity, store)
	self.entities[#self.entities + 1] = entity
	if not self.prime_entity then
		self.prime_entity = entity
		self:set_entity_info(entity)
		-- 启动显示渐变动画
		self:show()
	end

	self.store = store
end

function BossHealthBar:_draw_self()
	if self.hidden then
		return
	end

	local hp = math.min(1, self.health_percent)
	local lag = math.max(0, math.min(self.hp_lag, 1))
	local t = self.time
	local alpha = self.alpha * self.show_alpha

	-- 应用震动偏移
	G.push()
	G.translate(self.shake_offset.x, self.shake_offset.y)

	-- 背景（带透明度）
	G.setColor(0, 0, 0, 0.55 * alpha)
	G.rectangle("fill", 0, 0, background_width, background_height, 5)

	-- 边框
	G.setColor(1, 1, 1, 0.12 * alpha)
	G.setLineWidth(2)
	G.rectangle("line", 1, 1, background_width - 2, background_height - 2, 5)

	-- 低血量警告边框（增强脉冲效果）
	if self.health_percent < 0.3 then
		local warning_alpha = (0.45 + 0.35 * math.abs(math.sin(t * 8))) * alpha
		-- 添加脉冲效果
		warning_alpha = warning_alpha + self.pulse_alpha * 0.3
		G.setColor(1, 0.2, 0.2, warning_alpha)
		G.setLineWidth(2)
		G.rectangle("line", 2, 2, background_width - 4, background_height - 4, 5)

		-- 危险时的额外发光效果
		G.setColor(1, 0.4, 0.4, self.pulse_alpha * 0.2 * alpha)
		G.setLineWidth(4)
		G.rectangle("line", 0, 0, background_width, background_height, 5)
	end

	-- 底层红色血条背景
	G.setColor(0.5, 0.08, 0.08, 0.9 * alpha)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, healthbar_height, 0)

	-- 绿色血条（带颜色渐变效果）
	local hp_width = healthbar_width * hp
	if hp > 0 then
		local r, g, b = 0.2, 0.85, 0.2
		-- 根据血量调整颜色
		if hp < 0.3 then
			-- 低血量时偏红
			r = 0.85
			g = math.max(0.1, 0.3 + hp * 0.55) -- 确保绿色分量不会太低
		elseif hp < 0.6 then
			-- 中血量时偏黄
			r = math.min(0.85, 0.4 + (0.6 - hp) * 0.45) -- 确保红色分量不超过0.85
			g = 0.85
		end
		-- 应用颜色偏移效果（受伤时闪白）
		local shift_multiplier = 1.5 -- 增强闪烁效果
		r = math.min(1, r + self.color_shift * shift_multiplier)
		g = math.min(1, g + self.color_shift * shift_multiplier)
		b = math.min(1, b + self.color_shift * shift_multiplier)
		-- 确保颜色值在有效范围内
		r = math.max(0, math.min(1, r))
		g = math.max(0, math.min(1, g))
		b = math.max(0, math.min(1, b))

		G.setColor(r, g, b, 0.95 * alpha)
		G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, hp_width, healthbar_height, 0)
	end

	-- 黄色滞后血条
	if lag > hp then
		G.setColor(1.0, 0.95, 0.3, 0.9 * alpha)
		G.rectangle("fill", healthbar_left_padding + (hp_width > 0 and hp_width or 0), healthbar_up_padding, healthbar_width * (lag - hp), healthbar_height, 0)
	end

	-- 血条覆盖层（光泽效果）
	G.setColor(1, 1, 1, 0.13 * alpha)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, healthbar_height * 0.32, 0)
	G.setColor(1, 1, 1, 0.22 * alpha)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, 1)

	-- 刻度
	for i = 1, 9 do
		local x = healthbar_left_padding + math.floor(healthbar_width * (i / 10) + 0.5)
		if i % 2 == 0 then
			G.setLineWidth(1.5)
			G.setColor(1, 1, 1, 0.35 * alpha)
			local len = healthbar_height * 0.8
			local y0 = healthbar_up_padding + (healthbar_height - len) / 2
			G.line(x, y0, x, healthbar_up_padding + (healthbar_height + len) / 2)
		else
			G.setLineWidth(1)
			G.setColor(1, 1, 1, 0.25 * alpha)
			local len = healthbar_height * 0.65
			local y0 = healthbar_up_padding + (healthbar_height - len) / 2
			G.line(x, y0, x, y0 + len)
		end
	end

	-- BOSS头像
	local ss = self.portrait_ss
	local ref_scale = (ss.ref_scale or 1) * 0.6
	G.setColor(1, 1, 1, 0.9 * alpha)
	G.draw(self.portrait, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)

	-- BOSS名称文字
	G.setFont(self.font)
	local nx, ny = healthbar_left_padding, text_up_padding
	-- 阴影
	G.setColor(0, 0, 0, 0.85 * alpha)
	G.printf(self.boss_name, nx + 1, ny, healthbar_width, "left")
	G.printf(self.boss_name, nx - 1, ny, healthbar_width, "left")
	G.printf(self.boss_name, nx, ny + 1, healthbar_width, "left")
	G.printf(self.boss_name, nx, ny - 1, healthbar_width, "left")
	-- 主文字
	G.setColor(1, 1, 1, alpha)
	G.printf(self.boss_name, nx, ny, healthbar_width, "left")

	G.pop()
end

--- 清理已经不存在的实体，并更新当前展示的实体
function BossHealthBar:update_entity()
	if self.store then
		for i = #self.entities, 1, -1 do
			local e = self.entities[i]
			if not self.store.entities[e.id] then
				table.remove(self.entities, i)
			end
		end
		if #self.entities > 0 then
			-- 优先选择第一个存活的实体作为展示对象
			local found = false
			for i = 1, #self.entities do
				if not self.entities[i].health.dead then
					found = true
					local entity = self.entities[i]

					if self.prime_entity ~= entity then
						self:set_entity_info(entity)
						-- 启动显示渐变动画
						if not self.prime_entity then
							self:show()
							self.prime_entity = entity
						else
							self.prime_entity = entity
						end
					end
					break
				end
			end
			-- 如果没有找到存活的实体，则不展示
			if not found and self.prime_entity then
				self:hide()
				self.prime_entity = nil
			end
		else
			-- 如果没有实体了，不展示
			if self.prime_entity then
				self:hide()
				self.prime_entity = nil
			end
		end
	end

end

function BossHealthBar:update(dt)
	-- 更新timer
	timer:update(dt)
	-- 更新显示的实体
	self:update_entity()

	if self.prime_entity then
		local health = self.prime_entity.health

		local old_health_percent = self.health_percent
		self.health_percent = health.hp / health.hp_max
		self.time = self.time + dt

		-- 检测血量变化，触发受伤效果
		if old_health_percent > self.health_percent and not self.is_animating then
			local damage_ratio = old_health_percent - self.health_percent
			self:trigger_damage_effect(damage_ratio)
		end

		-- 更新脉冲效果
		self:update_pulse_effect()

		local hp = math.max(0, math.min(self.health_percent, 1))
		if (self.hp_lag or 1) < hp then
			self.hp_lag = hp
		else
			local speed = 0.8
			self.hp_lag = self.hp_lag + (hp - self.hp_lag) * math.min(speed * dt, 1)
		end
	end
end

-- 取消指定类型的timer，避免冲突
function BossHealthBar:cancel_timers(timer_type)
	if timer_type == "all" then
		-- 取消所有timer
		for category, timers in pairs(self.active_timers) do
			if category ~= "flash" then
				for i, handle in pairs(timers) do
					if handle then
						timer:cancel(handle)
					end
				end
				self.active_timers[category] = {}
			else
				if timers then
					timer:cancel(timers)
					self.active_timers.flash = nil
				end
			end
		end
	else
		-- 取消指定类型的timer
		if timer_type == "flash" then
			if self.active_timers.flash then
				timer:cancel(self.active_timers.flash)
				self.active_timers.flash = nil
			end
		else
			local timers = self.active_timers[timer_type]
			if timers then
				for i, handle in pairs(timers) do
					if handle then
						timer:cancel(handle)
					end
				end
				self.active_timers[timer_type] = {}
			end
		end
	end
end

-- 显示动画
function BossHealthBar:show()
	-- 如果正在执行显示动画，则不重复执行动画
	if self.active_timers.show[1] then
		return
	end

	-- 中断任何正在进行的隐藏动画
	self:cancel_timers("hide")

	self.hidden = false
	self.is_animating = true
	self.pos.y = 20 - 15 -- 从稍高的位置开始

	-- 主体渐入动画
	self.active_timers.show[1] = timer:tween(fade_in_time, self, {
		alpha = 1,
		show_alpha = 1
	}, "out-cubic")

	-- 位置动画
	self.active_timers.show[2] = timer:tween(fade_in_time, self.pos, {
		y = 20
	}, "out-back")

	-- 延迟后结束动画状态
	self.active_timers.show[3] = timer:after(fade_in_time, function()
		self.is_animating = false
		self.active_timers.show = {}
	end)
end

-- 隐藏动画
function BossHealthBar:hide()
	-- 如果正在执行隐藏动火，则不重复执行动画
	if self.active_timers.hide[1] then
		return
	end

	-- 中断任何正在进行的显示动画
	self:cancel_timers("show")

	self.is_animating = true

	-- 主体渐出动画
	self.active_timers.hide[1] = timer:tween(fade_out_time, self, {
		alpha = 0,
		show_alpha = 0
	}, "linear", function()
		self.hidden = true
		self.is_animating = false
		-- 清理hide timer组
		self.active_timers.hide = {}
	end)
end

-- 血量变化时的颜色渐变动画
function BossHealthBar:trigger_damage_effect(damage_ratio)
	-- 根据伤害比例调整闪烁强度
	-- damage_ratio = damage_ratio or 0.1 -- 默认伤害比例
	-- local flash_intensity = math.min(1, damage_ratio * 10) -- 伤害比例*10，最大为1
	local flash_intensity = damage_ratio
	-- 只有当伤害足够大时才触发闪烁（避免DOT频繁闪烁）
	if flash_intensity > 0.01 then
		if self.color_shift == 0 then
			-- 颜色闪烁效果
			self.color_shift = flash_intensity * 10
			local flash_time = 0.2 + flash_intensity * 2 -- 根据强度调整持续时间
			timer:tween(flash_time, self, {
				color_shift = 0
			}, "out-quart", function()
				self.color_shift = 0
			end)
		end

		-- 高伤害时添加震动效果
		if flash_intensity > 0.03 then -- 只有伤害比例超过3%才震动
			if self.shake_offset.x == 0 and self.shake_offset.y == 0 then
				local shake_intensity = 10 * math.min(4, flash_intensity * 10) -- 震动强度
				-- 重置震动偏移
				self.shake_offset.x = 0
				self.shake_offset.y = 0
				-- 第一次震动
				timer:tween(0.08, self.shake_offset, {
					x = shake_intensity * (math.random() - 0.5) * 2,
					y = shake_intensity * (math.random() - 0.5) * 2
				}, "out-elastic", function()
					-- 震动回弹
					timer:tween(0.12, self.shake_offset, {
						x = 0,
						y = 0
					}, "out-elastic", function()
						-- 确保最终回到原位
						self.shake_offset.x = 0
						self.shake_offset.y = 0
					end)
				end)
			end
		end
	end
end

-- 低血量脉冲效果
function BossHealthBar:update_pulse_effect()
	if self.health_percent < 0.3 then
		-- 危险状态下的脉冲效果
		local pulse_speed = 4 + (0.3 - self.health_percent) * 10 -- 血量越低脉冲越快
		self.pulse_alpha = 0.3 + 0.4 * math.abs(math.sin(self.time * pulse_speed))
	else
		self.pulse_alpha = 0
	end
end

-- 清理timer（在组件销毁时调用）
function BossHealthBar:destroy()
	timer:clear()
end

return BossHealthBar
