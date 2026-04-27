local km = require("lib.klua.macros")
local F = require("lib.klove.font_db")
local I = require("lib.klove.image_db")
local S = require("sound_db")
local GS = require("kr1.game_settings")
local Timer = require("lib.hump.timer")

require("all.constants")

local screen = {}

screen.required_textures = {}
screen.required_sounds = {}
screen.ref_w = 1920
screen.ref_h = 1080
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd

local PIXEL_PALETTE = {
	[1] = {186, 173, 154},
	[2] = {159, 142, 119},
	[3] = {197, 93, 39},
	[4] = {105, 95, 80},
	[5] = {204, 64, 16},
	[6] = {89, 65, 40},
	[7] = {67, 52, 35},
	[8] = {54, 39, 21},
	[9] = {54, 27, 11},
	[10] = {34, 24, 13},
	[11] = {30, 21, 12},
	[12] = {28, 18, 9},
	[13] = {20, 13, 6}
}

local PIXEL_DOVE = {
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000",
	"0000000000000000000000000000000DD000000000D00000",
	"00000000000000000000000000000A7447C00000DA8A0000",
	"0000000000000000000ABCCCCCBC8411126C00DA74480000",
	"0000BACD000000000BCA8766678A41122128C864224A0000",
	"0000A447AD00000BB84211111124111661267222227B0000",
	"0000B4222478CDC841112444444211122263342226AC0000",
	"0000C84211122464444788888941111112766744677B0000",
	"00000B8422111111111248888611111124744444427C0000",
	"0000C846642221111111127A411111112744422224A00000",
	"00000842244422222111112421111111474422246AC00000",
	"00000C8422222211242111112211111246444447AC000000",
	"000000DA744222211221111111111112464444447B000000",
	"0000000A64644422222422211222222244444467A0000000",
	"0000000B744446667446776466666667874467ACC0000000",
	"000000BA777764337A63336A733333333686676AC0000000",
	"000000C727C333338835535963555555336AB826C0000000",
	"000000C417A3355393355559635555555536C822AB000000",
	"00000AA228A335556355559D63555665555398218B000000",
	"00000BA128A33553355559CC635559C6555598417C000000",
	"00000C8148A3355355559CAA63555CC6555598616C000000",
	"00000C8148A635555556CA8A355556335556B8616C000000",
	"00000C8148A635555556C88A355553555559A8616C000000",
	"00000C8148A6355555536A8A35555555559C88616C000000",
	"00000BA228A65555555537CA3555555556C988417C000000",
	"000000B217A655559555538A35555655538888218B000000",
	"000000C416A655559955553835556955553A8712B0000000",
	"000000C814A655559C55555655556C655556A416C0000000",
	"000000BA218655559D95599955559D955556A218B0000000",
	"0000000C71496699AAC99CAC99999AA6569C614B00000000",
	"0000000BA417CCCB9867A889AAAAA8AAACC8128B00000000",
	"00000000B82179888822888888888888988216B000000000",
	"000000000C712788421262264464422688214AA000000000",
	"000000000CC6127412122121212212128214AC0000000000",
	"00000000C87A61641622144141141224714A88BB00000000",
	"0000000BA633A886111241127116211487B6339C00000000",
	"00000000B63338CA7667866886687668CB6336AC00000000",
	"00000000CA63337CCA98888888889ACC933369C000000000",
	"000000000CA7333ACCCBAAAAAAABCCCB33369C0000000000",
	"0000000000CC966BC0BCCCCCCCCCC0CB637AC00000000000",
	"000000000000CBBC000000000000000CBACC000000000000",
	"0000000000000BB00000000000000000CC00000000000000",
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000",
	"000000000000000000000000000000000000000000000000"
}

local function draw_pixel_dove(x, y, scale, phase, alpha)
	for row_idx, row in ipairs(PIXEL_DOVE) do
		for col_idx = 1, #row do
			local pixel = tonumber(row:sub(col_idx, col_idx), 16)
			local color = PIXEL_PALETTE[pixel]

			if color then
				local glow = (col_idx + row_idx + phase) % 11 == 0 and 18 or 0
				local r = math.min(255, color[1] + glow) / 255
				local g = math.min(255, color[2] + glow) / 255
				local b = math.min(255, color[3] + glow) / 255
				love.graphics.setColor(r, g, b, alpha)
				love.graphics.rectangle("fill", x + (col_idx - 1) * scale, y + (row_idx - 1) * scale, scale, scale)
			end
		end
	end
end

function screen:init(w, h)
	self.hold_enabled = true
	self.progress = 0
	self.progress_display = 0
	self.anim_t = 0
	self.fade_alpha = 0
	self.timer = Timer()
	self.font_title = F:f("msyh", 34)
	self.font_percent = F:f("msyh", 28)
	self.font_tip = F:f("msyh", 20)
	self.tip = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
	self.timer:tween(2, self, {
		fade_alpha = 1
	}, "out-quad")
end

function screen:destroy()
	self.progress = nil
	self.progress_display = nil
	self.anim_t = nil
	self.fade_alpha = nil
	self.timer = nil
	self.font_title = nil
	self.font_percent = nil
	self.font_tip = nil
	self.tip = nil
end

function screen:update(dt)
	if self.timer then
		self.timer:update(dt)
	end

	self.anim_t = self.anim_t + dt
	self.progress = km.clamp(0, 1, 0.6 * I.progress + 0.4 * S.progress)
	self.progress_display = self.progress_display + (self.progress - self.progress_display) * math.min(dt * 7, 1)

	if I:queue_load_done() and S:queue_load_done() then
		self.progress = 1
		self.progress_display = 1
		self.hold_enabled = false
	end

	return true
end

function screen:draw()
	local g = love.graphics
	local w, h = g.getDimensions()
	local tween_alpha = self.fade_alpha or 1
	-- 进度兜底：即使淡入补间未结束，加载接近完成时也避免半透明叠到游戏画面。
	local progress_alpha = km.clamp(0, 1, self.progress_display)
	local a = math.max(tween_alpha, progress_alpha)
	local old_font = g.getFont()
	local font_title = self.font_title or old_font
	local font_percent = self.font_percent or old_font
	local font_tip = self.font_tip or old_font

	for y = 0, h do
		local t = y / h
		g.setColor(0.12 - 0.04 * t, 0.14 - 0.04 * t, 0.18 - 0.03 * t, a)
		g.rectangle("fill", 0, y, w, 1)
	end

	local pixel_scale = math.max(3, math.floor(math.min(w, h) / 180))
	local sprite_w = #PIXEL_DOVE[1] * pixel_scale
	local sprite_h = #PIXEL_DOVE * pixel_scale
	local bob_y = math.floor(math.sin(self.anim_t * 2.8) * pixel_scale)
	local sprite_x = math.floor((w - sprite_w) * 0.5)
	local sprite_y = math.floor(h * 0.28 - sprite_h * 0.5 + bob_y)
	local phase = math.floor(self.anim_t * 14)

	draw_pixel_dove(sprite_x, sprite_y, pixel_scale, phase, a)

	local bar_w = math.floor(math.min(740, w * 0.68))
	local bar_h = math.max(14, math.floor(h / 48))
	local bar_x = math.floor((w - bar_w) * 0.5)
	local bar_y = math.floor(h * 0.72)
	local inner_w = bar_w - 4
	local fill_w = math.floor(inner_w * self.progress_display)

	g.setColor(0.08, 0.08, 0.10, a)
	g.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
	g.setColor(0.22, 0.22, 0.26, a)
	g.rectangle("line", bar_x, bar_y, bar_w, bar_h)

	if fill_w > 0 then
		g.setColor(0.92, 0.54, 0.21, a)
		g.rectangle("fill", bar_x + 2, bar_y + 2, fill_w, bar_h - 4)

		local stripe_start = (phase * 2) % 8
		g.setColor(1, 0.76, 0.40, 0.35 * a)
		for x = stripe_start, fill_w, 8 do
			g.rectangle("fill", bar_x + 2 + x, bar_y + 2, 3, bar_h - 4)
		end
	end

	local percent_text = string.format("%d%%", math.floor(self.progress_display * 100 + 0.5))
	local title = "Loading..."
	local title_w = font_title:getWidth(title)
	local percent_w = font_percent:getWidth(percent_text)

	g.setFont(font_title)
	g.setColor(1, 1, 1, a)
	g.print(title, math.floor((w - title_w) * 0.5), bar_y - 90)

	g.setFont(font_percent)
	g.print(percent_text, math.floor((w - percent_w) * 0.5), bar_y - 45)

	g.setFont(font_tip)
	g.setColor(0.82, 0.86, 0.92, a)
	g.printf(self.tip, math.floor(w * 0.1), bar_y + bar_h + 18, math.floor(w * 0.8), "center")
	g.setFont(old_font)
end

function screen:keypressed(key, isrepeat)
	return
end

function screen:mousepressed(x, y, button)
	return
end

function screen:close()
	return
end

return screen
