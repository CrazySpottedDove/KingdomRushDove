require("klove.kui")
local class = require("middleclass")
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

function BossHealthBar:initialize(sw)
	KView.initialize(self, nil)
	self.pos.x = (sw - background_width) / 2
	self.pos.y = 20
	self.health_percent = 1
	self.boss_name = "BOSS_NAME"
	self.portrait = nil
	self.portrait_ss = nil
	self.hidden = true
	self.entity = nil
	self.font = F:f("button", 12)
	self.hp_lag = 1
	self.time = 0
	self.store = nil
	return self
end

function BossHealthBar:enable_with(entity, store)
	if not self.entity then
		self.entity = entity
		self.hp_lag = 1
		self.time = 0
		self.health_percent = 1
		self.portrait_ss = I:s(entity.info.portrait)
		self.portrait = I:i(self.portrait_ss.atlas)
		self.boss_name = _(entity.info.i18n_key and entity.info.i18n_key .. "_NAME" or string.upper(entity.template_name) .. "_NAME")
		self.hidden = false
	end
	self.store = store
end

-- function BossHealthBar:set_entity(entity)
-- 	self.entity = entity
-- end

-- function BossHealthBar:set_portrait(portrait_ss, portrait)
-- 	self.portrait_ss = portrait_ss
-- 	self.portrait = portrait
-- end

-- function BossHealthBar:set_name(name)
-- 	self.boss_name = name
-- end

-- function BossHealthBar:enable()
-- 	self.hidden = false
-- end

-- function BossHealthBar:enabled()
-- 	return not self.hidden and self.entity ~= nil
-- end

function BossHealthBar:_draw_self()
	if self.hidden or not self.entity then
		return
	end

	local hp = math.min(1, self.health_percent)
	local lag = math.max(0, math.min(self.hp_lag, 1))
	local t = self.time

	-- 背景
	G.setColor(0, 0, 0, 0.55)
	G.rectangle("fill", 0, 0, background_width, background_height, 5)

	-- 边框
	G.setColor(1, 1, 1, 0.12)
	G.setLineWidth(2)
	G.rectangle("line", 1, 1, background_width - 2, background_height - 2, 5)

	-- 低血量警告边框
	if self.health_percent < 0.3 then
		G.setColor(1, 0.2, 0.2, 0.45 + 0.35 * math.abs(math.sin(t * 8)))
		G.setLineWidth(2)
		G.rectangle("line", 2, 2, background_width - 4, background_height - 4, 5)
	end

	-- 底层红色血条背景
	G.setColor(0.5, 0.08, 0.08, 0.9)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, healthbar_height, 0)

	-- 绿色血条
	local hp_width = healthbar_width * hp
	if hp > 0 then
		G.setColor(0.2, 0.85, 0.2, 0.95)
		G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width * hp, healthbar_height, 0)
	end

	-- 黄色滞后血条
	if lag > hp then
		G.setColor(1.0, 0.95, 0.3, 0.9)
		G.rectangle("fill", healthbar_left_padding + (hp_width > 0 and hp_width or 0), healthbar_up_padding, healthbar_width * (lag - hp), healthbar_height, 0)
	end

	-- 血条覆盖层
	G.setColor(1, 1, 1, 0.13)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, healthbar_height * 0.32, 0)
	G.setColor(1, 1, 1, 0.22)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, 0)

	-- 刻度
	for i = 1, 9 do
		local x = healthbar_left_padding + math.floor(healthbar_width * (i / 10) + 0.5)
		if i % 2 == 0 then
			G.setLineWidth(1.5)
			G.setColor(1, 1, 1, 0.35)
			local len = healthbar_height * 0.8
			local y0 = healthbar_up_padding + (healthbar_height - len) / 2
			G.line(x, y0, x, healthbar_up_padding + (healthbar_height + len) / 2)
		else
			G.setLineWidth(1)
			G.setColor(1, 1, 1, 0.25)
			local len = healthbar_height * 0.65
			local y0 = healthbar_up_padding + (healthbar_height - len) / 2
			G.line(x, y0, x, y0 + len)
		end
	end

	local ss = self.portrait_ss
	local ref_scale = (ss.ref_scale or 1) * 0.6
	G.setColor(1, 1, 1, 0.9)
	G.draw(self.portrait, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)

	G.setFont(self.font)
	local nx, ny = healthbar_left_padding, text_up_padding
	G.setColor(0, 0, 0, 0.85)
	G.printf(self.boss_name, nx + 1, ny, healthbar_width, "left")
	G.printf(self.boss_name, nx - 1, ny, healthbar_width, "left")
	G.printf(self.boss_name, nx, ny + 1, healthbar_width, "left")
	G.printf(self.boss_name, nx, ny - 1, healthbar_width, "left")
	G.setColor(1, 1, 1, 1)
	G.printf(self.boss_name, nx, ny, healthbar_width, "left")
end

function BossHealthBar:update(dt)
	if self.entity then
		local health = self.entity.health
		if not health or health.dead then
			self.entity = nil
			local new_entity
			for _, e in pairs(self.store.enemies) do
				if not e.health.dead and e.enemy.lives_cost == 20 then
					new_entity = e
					break
				end
			end
			if new_entity then
				self:enable_with(new_entity, self.store)
			else
				self.hidden = true
				self.store = nil
				return
			end
		end
		self.health_percent = health.hp / health.hp_max
		self.time = self.time + dt

		local hp = math.max(0, math.min(self.health_percent, 1))
		if (self.hp_lag or 1) < hp then
			self.hp_lag = hp
		else
			local speed = 0.8
			self.hp_lag = self.hp_lag + (hp - self.hp_lag) * math.min(speed * dt, 1)
		end
	end
end

return BossHealthBar
