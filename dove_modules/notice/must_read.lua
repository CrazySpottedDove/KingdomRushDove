local storage = require("all.storage")

-- 提供一个强制阅读作者的话的界面。使用方法：在main.lua的load.run()的主循环前调用 MUST_READ.run() 即可。
local MUST_READ = {
	touch_scrolling = false,
	touch_start_y = 0,
	scroll_start = 0,
	scroll = 0,
	confirm_index = 1,
	margin = 40,
	text = require("dove_modules.notice.author_words"),
	enabled = true,
	params = nil,
	has_read = storage:load_lua("must_read.lua", true) ~= nil
}
local READ_EXPECTED_TIME = require("dove_modules.notice.read_expected_time")
local utf8 = require("utf8")
local confirm_steps = {"我已阅读，继续游戏", "我真的已阅读全部内容", "我发誓已阅读完毕", "我为因未读完导致的任何事负责", "我承诺不人身攻击作者", "确认过快，请继续阅读"}
local font = require("lib.klove.font_db"):f("msyh", 20)
local line_h = font:getHeight() + 6
local lines = {}

local function wrap_text(text, font, maxw)
	local color_white = {1, 1, 1}
	local color_red = {1, 0, 0}
	local lines = {}
	local current_line = {}
	local current_color = color_white
	local buffer = ""
	local width = 0
	local space_width = font:getWidth(" ")
	local i = 1

	-- RED状态机
	local function check_red_tag(idx)
		if text:sub(idx, idx + 2) == "RED" then
			return "RED", 3
		elseif text:sub(idx, idx + 3) == "/RED" then
			return "/RED", 4
		end
		return nil, 0
	end

	local function flush_buffer()
		if buffer ~= "" then
			table.insert(current_line, {
				text = buffer,
				color = current_color
			})
			buffer = ""
		end
	end

	local function flush_line()
		flush_buffer()
		table.insert(lines, current_line)
		current_line = {}
		width = 0
	end

	local text_len = #text
	while i <= text_len do
		local tag, taglen = check_red_tag(i)
		if tag == "RED" then
			flush_buffer()
			current_color = color_red
			i = i + taglen
		elseif tag == "/RED" then
			flush_buffer()
			current_color = color_white
			i = i + taglen
		else
			local c_start = i
			local c_end = utf8.offset(text, 2, i) and utf8.offset(text, 2, i) - 1 or text_len
			local ch = text:sub(c_start, c_end)
			i = c_end + 1

			if ch == "\n" then
				flush_line()
			else
				local w = font:getWidth(ch)
				if width + w > maxw then
					flush_buffer()
					flush_line()
					buffer = ch
					width = font:getWidth(ch)
				else
					buffer = buffer .. ch
					width = width + w
				end
			end
		end
	end
	flush_buffer()
	if #current_line > 0 then
		table.insert(lines, current_line)
	end
	return lines
end

-- 返回 true 表示已滚到底
local function is_scrolled_to_bottom(scroll, total_lines, visible_lines)
	return scroll >= math.max(0, total_lines - visible_lines)
end

-- window 由外部设置，内部不对其进行调整
function MUST_READ:init(params, done_callback)
	self.done_callback = done_callback
	self.params = params
	self:layout()
end

function MUST_READ:wheelmoved(x, y)
	if y ~= 0 then
		self.scroll = math.max(0, self.scroll - math.floor(y * 3))
	end
end

function MUST_READ:touchpressed(id, x, y, dx, dy, pressure)
	self.touch_scrolling = true
	self.touch_start_y = y
	self.scroll_start = self.scroll
end

function MUST_READ:touchmoved(id, x, y, dx, dy, pressure)
	if self.touch_scrolling then
		local w, h = love.graphics.getDimensions()
		local visible_lines = math.floor((h - 180) / line_h)
		local total_lines = #lines
		local max_scroll = math.max(0, total_lines - visible_lines)
		local delta = math.ceil((self.touch_start_y - y) / 30)
		self.scroll = math.max(0, math.min(max_scroll, self.scroll_start + delta))
	end
end

function MUST_READ:layout()
	local w, h = love.graphics.getDimensions()
	local maxw = math.max(200, w - self.margin * 2)
	lines = wrap_text(self.text, font, maxw)
end

function MUST_READ:touchreleased(id, x, y, dx, dy, pressure)
	self.touch_scrolling = false
end

function MUST_READ:mousepressed(x, y, button)
	local w, h = love.graphics.getDimensions()
	local content_w = math.max(200, w - self.margin * 2)
	local visible_lines = math.floor((h - 180) / line_h)
	local total_lines = #lines
	local can_continue = is_scrolled_to_bottom(self.scroll, total_lines, visible_lines)

	local btn_w, btn_h = 300, 44
	local bx = (w - btn_w) / 2
	local by = h - 100

	if button == 1 then
		if x >= bx and x <= bx + btn_w and y >= by and y <= by + btn_h and can_continue then
			if self.has_read then
				self.done_callback()
			elseif self.confirm_index < #confirm_steps - 1 then
				if READ_EXPECTED_TIME.read_can_stop("author_words") then
					self.confirm_index = self.confirm_index + 1
				else
					self.confirm_index = #confirm_steps
				end
			elseif self.confirm_index == #confirm_steps then
				if READ_EXPECTED_TIME.read_can_stop("author_words") then
					self.confirm_index = 1
				end
			else
				-- TODO: 一些结束效果
				-- local function restore()
				-- 	MUST_READ.enabled = false
				-- 	love.window.setMode(old_w, old_h, old_flags)
				-- 	love.wheelmoved = orig_wheelmoved
				-- 	love.mousepressed = orig_mousepressed
				-- 	love.touchpressed = orig_touchpressed
				-- 	love.touchmoved = orig_touchmoved
				-- 	love.touchreleased = orig_touchreleased
				-- 	-- 标记为已阅读
				-- 	storage:write_lua("must_read.lua", {
				-- 		read = true
				-- 	})
				-- end
				self.done_callback()
			end
			return
		end
	end
end

function MUST_READ:mousereleased(x, y, button, istouch)
end

function MUST_READ:keypressed(key, isrepeat)
end

function MUST_READ:keyreleased(key)
end

function MUST_READ:update(dt)
end

function MUST_READ:draw()
	local w, h = love.graphics.getDimensions()
	-- 背景
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(font)

	local content_w = math.max(200, w - self.margin * 2)
	local visible_lines = math.floor((h - 180) / line_h)
	local total_lines = #lines

	-- 限制 scroll 合理范围
	local max_scroll = math.max(0, total_lines - visible_lines)
	if self.scroll > max_scroll then
		self.scroll = max_scroll
	end
	if self.scroll < 0 then
		self.scroll = 0
	end

	-- 标题
	local title = "作者的话"
	love.graphics.printf(title, self.margin, 20, content_w, "center")

	-- 文本绘制
	local start_i = self.scroll + 1
	local end_i = math.min(total_lines, self.scroll + visible_lines)
	local y = 60
	for i = start_i, end_i do
		local x = self.margin
		local y_line = y
		for _, seg in ipairs(lines[i]) do
			love.graphics.setColor(seg.color)
			love.graphics.print(seg.text, x, y_line)
			x = x + font:getWidth(seg.text)
		end
		y = y + line_h
	end
	love.graphics.setColor(1, 1, 1) -- 恢复白色

	-- 滚动提示（若未到底部）
	if not is_scrolled_to_bottom(self.scroll, total_lines, visible_lines) then
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.printf("向下滚动以阅读剩余内容...", self.margin, h - 120, content_w, "left")
	end

	-- Continue 按钮（仅当滚到底部时启用）
	local btn_w, btn_h = 300, 44
	local bx = (w - btn_w) / 2
	local by = h - 100
	local can_continue = is_scrolled_to_bottom(self.scroll, total_lines, visible_lines)
	love.graphics.setColor(can_continue and {0.1, 0.6, 0.1} or {0.4, 0.4, 0.4})
	love.graphics.rectangle("fill", bx, by, btn_w, btn_h, 6, 6)
	love.graphics.setColor(1, 1, 1)
	local btn_text = confirm_steps[self.confirm_index]
	love.graphics.printf(btn_text, bx, by + (btn_h - font:getHeight()) / 2, btn_w, "center")
end

return MUST_READ
