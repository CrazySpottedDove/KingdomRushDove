--- 安卓端启动语言选择界面。
---
--- 加载顺序：settings（安卓跳过） → language_select → must_read（作者的话/答题） → ...
--- 之所以放在流程最前：作者的话与题库文案都是模块加载时用 _() 定型的，
--- 必须在 require 它们之前选好语言；而且外国人看不懂作者的话就做不了首次答题。
---
--- 此时图集/纹理尚未加载，所以和 must_read 一样只用 love.graphics 图元绘制。
--- 界面本身刻意不依赖任何翻译：标题中英双语，语言按钮一律用各语言的母语名
--- （i18n.locale_names），任何语言的用户都能认出并点击自己的语言。
---
--- 出现条件由 main.lua 的 loader 控制：仅安卓端，且
--- launch_options.skip_language_select 为 false。关掉该启动项后本界面不再出现，
--- 提示文案写在「作者的话」页面（must_read.lua）。
local font_db = require("lib.klove.font_db")
local i18n = require("i18n")
local storage = require("all.storage")
local version = require("version")

local font_title = font_db:f("msyh", 30)
local font_sub = font_db:f("msyh", 16)
local font_lang = font_db:f("msyh", 26)

local LS = {
	margin = 40,
	activated = false
}

--- 语言按钮几何：draw 与点击命中共用同一份计算，保证所见即所点。
local function get_language_buttons(w, h)
	local locales = i18n.supported_locales
	local n = #locales
	local btn_w = math.min(620, math.max(260, w - 100))
	local btn_h = math.max(56, math.min(88, math.floor(h * 0.1)))
	local gap = math.max(14, math.floor(h * 0.026))
	local block_h = n * btn_h + math.max(0, n - 1) * gap
	local start_y = math.max(190, (h - block_h) * 0.5 + h * 0.04)
	local x = (w - btn_w) * 0.5
	local buttons = {}

	for i = 1, n do
		buttons[i] = {
			locale = locales[i],
			x = x,
			y = start_y + (i - 1) * (btn_h + gap),
			w = btn_w,
			h = btn_h
		}
	end

	return buttons
end

local function hit_test(x, y)
	local w, h = love.graphics.getDimensions()

	for _, b in ipairs(get_language_buttons(w, h)) do
		if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
			return b.locale
		end
	end

	return nil
end

function LS:init(params, done_callback)
	self.params = params
	self.done_callback = done_callback
	self.activated = false
	self.mouse_x, self.mouse_y = love.mouse.getPosition()
end

--- 选中某个语言：立即生效并落盘，然后交给下一个加载项。
--- 因为本界面在所有内容之前，这里不需要重启游戏（重启反而会再次回到本界面）。
function LS:select_locale(locale)
	if self.activated or not locale then
		return
	end

	self.activated = true

	if locale ~= i18n.current_locale then
		main:set_locale(locale)
	end

	self.params.locale = locale
	storage:save_settings(self.params)
	love.window.setTitle(_("APP_TITLE") .. version.id)

	self.done_callback()
end

function LS:mousepressed(x, y, button)
	if button ~= 1 then
		return
	end

	self.mouse_x, self.mouse_y = x, y
	self:select_locale(hit_test(x, y))
end

function LS:mousereleased(x, y, button)
end

function LS:touchpressed(id, x, y, dx, dy, pressure)
	self.mouse_x, self.mouse_y = x, y
	self:select_locale(hit_test(x, y))
end

function LS:touchmoved(id, x, y, dx, dy, pressure)
end

function LS:touchreleased(id, x, y, dx, dy, pressure)
end

function LS:keypressed(key, isrepeat)
end

function LS:keyreleased(key)
end

function LS:wheelmoved(x, y)
end

function LS:update(dt)
	self.mouse_x, self.mouse_y = love.mouse.getPosition()
end

function LS:draw()
	local w, h = love.graphics.getDimensions()
	local G = love.graphics

	G.setColor(0.09, 0.09, 0.11, 1)
	G.rectangle("fill", 0, 0, w, h)

	-- 地球图标：纯图元绘制，不依赖贴图资源
	local gr = math.max(26, math.min(56, math.floor(h * 0.05)))
	local gx, gy = w * 0.5, math.max(60, h * 0.14)

	G.setLineWidth(math.max(2, gr * 0.07))
	G.setColor(0.45, 0.72, 1, 1)
	G.circle("line", gx, gy, gr)
	G.ellipse("line", gx, gy, gr * 0.45, gr)
	G.ellipse("line", gx, gy, gr, gr * 0.45)

	-- 标题：中英双语，避免用户因为看不懂当前语言而卡在第一步
	local title_y = gy + gr + math.max(16, h * 0.028)

	G.setFont(font_title)
	G.setColor(1, 1, 1, 1)
	G.printf("语言 / Language", 0, title_y, w, "center")

	G.setFont(font_sub)
	G.setColor(0.72, 0.74, 0.78, 1)
	G.printf("请选择语言 / Choose your language", 0, title_y + font_title:getHeight() + 6, w, "center")

	-- 语言按钮：文字用该语言自己的名字，任何人都不用先看懂别的语言
	for _, b in ipairs(get_language_buttons(w, h)) do
		local is_current = b.locale == i18n.current_locale
		local is_hover = self.mouse_x >= b.x and self.mouse_x <= b.x + b.w and self.mouse_y >= b.y and self.mouse_y <= b.y + b.h

		if is_current then
			G.setColor(is_hover and {0.2, 0.33, 0.5, 1} or {0.15, 0.25, 0.38, 1})
		else
			G.setColor(is_hover and {0.24, 0.24, 0.28, 1} or {0.16, 0.16, 0.19, 1})
		end

		G.rectangle("fill", b.x, b.y, b.w, b.h, 10, 10)

		if is_current then
			G.setColor(0.45, 0.72, 1, 1)
			G.setLineWidth(3)
		elseif is_hover then
			G.setColor(0.78, 0.78, 0.84, 1)
			G.setLineWidth(2)
		else
			G.setColor(0.34, 0.34, 0.4, 1)
			G.setLineWidth(1)
		end

		G.rectangle("line", b.x, b.y, b.w, b.h, 10, 10)

		local name = i18n.locale_names[b.locale] or b.locale
		local name_w = font_lang:getWidth(name)
		local dot_r = math.max(5, math.floor(b.h * 0.08))
		local content_w = name_w + (is_current and dot_r * 2 + 14 or 0)
		local cx = b.x + (b.w - content_w) * 0.5
		local ty = b.y + (b.h - font_lang:getHeight()) * 0.5

		-- 当前语言打点标记（不用文字，任何语言都看得懂）
		if is_current then
			G.setColor(0.45, 0.72, 1, 1)
			G.circle("fill", cx + dot_r, ty + font_lang:getHeight() * 0.5, dot_r)
			cx = cx + dot_r * 2 + 14
		end

		G.setFont(font_lang)
		G.setColor(1, 1, 1, 1)
		G.print(name, cx, ty)
	end

	G.setColor(1, 1, 1, 1)
end

return LS
