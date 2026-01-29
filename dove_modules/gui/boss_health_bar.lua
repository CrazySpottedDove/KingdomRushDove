local BossHealthBar = {}
BossHealthBar.__index = BossHealthBar
require("klove.kui")
local class = require("middleclass")
local BossHealthBar = class("BossHealthBar", KView)
local G = love.graphics
local F = require("lib.klove.font_db")

function BossHealthBar:initialize(size)
	KView.initialize(self, size)
	self.pos.x = 478
	self.pos.y = 20
	self.health_percent = 1
	self.boss_name = "BOSS_NAME"
	self.portrait = nil -- love.graphics.Image
	self.portrait_ss = nil
	self.hidden = true
	self.entity = nil
	self.font = F:f("button", 12)
	return self
end

function BossHealthBar:set_entity(entity)
	self.entity = entity
end

function BossHealthBar:set_portrait(portrait_ss, portrait)
	self.portrait_ss = portrait_ss
	self.portrait = portrait
end

function BossHealthBar:set_name(name)
	self.boss_name = name
end

function BossHealthBar:enable()
	self.hidden = false
end

function BossHealthBar:enabled()
	return not self.hidden and self.entity ~= nil
end

local background_width = 440
local background_height = 42
local healthbar_left_padding = 40
local healthbar_right_padding = 8
local healthbar_up_padding = 26
local healthbar_bottom_padding = 8
local text_up_padding = 6
local healthbar_height = background_height - healthbar_up_padding - healthbar_bottom_padding
local healthbar_width = background_width - healthbar_left_padding - healthbar_right_padding

function BossHealthBar:_draw_self()
	if self.hidden or not self.entity then
		return
	end

	local w, h = 440, 20
	-- 背景
	G.setColor(0, 0, 0, 0.5)
	G.rectangle("fill", 0, 0, background_width, background_height, 5)

	-- 血条底
	G.setColor(0.6, 0.1, 0.1, 0.7)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width, healthbar_height, 4)

	local health_percent_1 = math.min(self.health_percent / 0.5, 1)
	local health_percent_2 = math.max((self.health_percent - 0.5) / 0.5, 0)

	-- 血条1
	G.setColor(1.0, 0.6, 0.0, 0.7)
	G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width * health_percent_1, healthbar_height, 4)

	if health_percent_2 > 0 then
		-- 血条2
		G.setColor(0.2, 0.8, 0.2, 0.7)
		G.rectangle("fill", healthbar_left_padding, healthbar_up_padding, healthbar_width * health_percent_2, healthbar_height, 4)
	end

	-- BOSS 头像
	local ss = self.portrait_ss
	local ref_scale = (ss.ref_scale or 1) * 0.6
	G.setColor(1, 1, 1, 0.8)
	G.draw(self.portrait, ss.quad, ss.trim[1] * ref_scale, ss.trim[2] * ref_scale, 0, ref_scale)

	-- BOSS 名称
	G.setFont(self.font)
	G.printf(self.boss_name, healthbar_left_padding, text_up_padding, healthbar_width, "left")
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
