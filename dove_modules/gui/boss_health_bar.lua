local BossHealthBar = {}
BossHealthBar.__index = BossHealthBar
require("klove.kui")
local class = require("middleclass")
local BossHealthBar = class("BossHealthBar", KView)

function BossHealthBar:initialize(size)
	KView.initialize(self, size)
	self.pos.x = 478
	self.pos.y = 20
	self.health_percent = 1
	self.boss_name = "BOSS_NAME"
	self.portrait = nil -- love.graphics.Image
	self.portrait_size = 32
	self.hidden = true
	self.entity = nil
	return self
end

function BossHealthBar:set_entity(entity)
	self.entity = entity
end

function BossHealthBar:enable()
	self.hidden = false
end

function BossHealthBar:enabled()
	return not self.hidden and self.entity ~= nil
end

function BossHealthBar:_draw_self()
	if self.hidden or not self.entity then
		return
	end
	local w, h = 440, 20
	-- 背景
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, w, h + 12, 5)

	-- 血条底
	love.graphics.setColor(0.6, 0.1, 0.1, 0.7)
	love.graphics.rectangle("fill", 8, 8, w - 16, h - 4, 4)

	local health_percent_1 = math.min(self.health_percent / 0.5, 1)

	local health_percent_2 = math.max((self.health_percent - 0.5) / 0.5, 0)

	-- 血条1
	love.graphics.setColor(1.0, 0.6, 0.0, 0.7)
	love.graphics.rectangle("fill", 8, 8, (w - 16) * health_percent_1, h - 4, 4)

	if health_percent_2 > 0 then
		-- 血条2
		love.graphics.setColor(0.2, 0.8, 0.2, 0.7)
		love.graphics.rectangle("fill", 8, 8, (w - 16) * health_percent_2, h - 4, 4)
	end
end

function BossHealthBar:update(dt)
	if self.entity then
		local health = self.entity.health
		if not health then
			self.hidden = true
			self.entity = nil
			return
		end
		if health.dead then
			self.hidden = true
			self.entity = nil
			return
		end
		self.health_percent = health.hp / health.hp_max
	end
end

return BossHealthBar
