local MUST_READ = {}
MUST_READ.text = require("dove_modules.notice.author_words")
local utf8 = require("utf8")
local storage = require("all.storage")

local confirm_steps = {{
	btn = "我已阅读，继续游戏"
}, {
	btn = "我真的已阅读全部内容"
}, {
	btn = "我发誓已阅读完毕"
}}

local function wrap_text(text, font, maxw)
	local lines = {}
	for paragraph in string.gmatch(text, "[^\n]+") do
		local line = ""
		for word in string.gmatch(paragraph, "%S+") do
			local try = (line == "") and word or (line .. " " .. word)
			if font:getWidth(try) <= maxw then
				line = try
			else
				if line ~= "" then
					table.insert(lines, line)
				end
				-- word may still be too long; split by character (safe UTF-8 aware)
				if font:getWidth(word) <= maxw then
					line = word
				else
					local cur = ""
					local splitted = false
					-- 优先使用 LÖVE 11+ 的 utf8 库，更安全可靠
					if type(utf8) == "table" and utf8.codes then
						local ok, positions = pcall(function()
							local t = {}
							for p in utf8.codes(word) do
								table.insert(t, p)
							end
							return t
						end)
						if ok and #positions > 0 then
							table.insert(positions, #word + 1) -- 添加末尾边界
							for i = 1, #positions - 1 do
								-- 根据准确的字节位置截取完整字符
								local ch = word:sub(positions[i], positions[i + 1] - 1)
								if font:getWidth(cur .. ch) <= maxw then
									cur = cur .. ch
								else
									if cur ~= "" then
										table.insert(lines, cur)
									end
									cur = ch
								end
							end
							line = cur
							splitted = true
						end
					end

					-- 如果 utf8 库不可用或失败，回退到原来的方法
					if not splitted then
						cur = ""
						for c in word:gmatch(utf8 and "[%z\1-\127\194-\244][\128-\191]*" or ".") do
							if font:getWidth(cur .. c) <= maxw then
								cur = cur .. c
							else
								if cur ~= "" then
									table.insert(lines, cur)
								end
								cur = c
							end
						end
						line = cur
					end
				end
			end
		end
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	return lines
end

-- 返回 true 表示已滚到底
local function is_scrolled_to_bottom(scroll, total_lines, visible_lines)
	return scroll >= math.max(0, total_lines - visible_lines)
end

--- only do affect when must_read_flag is nil
---@param original_love_update_function function(dt: number)
---@param original_love_draw_function function()
function MUST_READ.hack_love_update(original_love_update_function, original_love_draw_function)
	-- 用是否存在 must_read.lua 来确定是否已经提示过用户
	local must_read_flag = storage:load_lua("must_read.lua", true)
	if must_read_flag ~= nil then
		return
	end

	-- 允许外部传入文本，也可在模块中设置 M.text
	local text = MUST_READ.text
	-- 检查并提取隐藏口令
	local hidden_key = text:match("%[KEY:(.-)%]")
	if hidden_key then
		-- 从显示文本中移除口令标记
		text = text:gsub("%[KEY:.-%]", "")
		hidden_key = hidden_key:gsub("^%s+", ""):gsub("%s+$", "")
	end

	-- 状态
	local font = nil
	local margin = 40
	local line_h = 22
	local lines = {}
	local scroll = 0
	local typing = ""
	local input_active = false
	local clicked_continue = false
	local show_hint = true

	pcall(function()
		font = require("lib.klove.font_db"):f("msyh", 20)
	end)
	font = font or love.graphics.newFont(16)
	line_h = font:getHeight() + 6

	local old_w, old_h, old_flags
	if love.window and love.window.getMode then
		old_w, old_h, old_flags = love.window.getMode()
	end

	local dw, dh = nil, nil

	if love.window and love.window.getDesktopDimensions then
		dw, dh = love.window.getDesktopDimensions()
	end

	if not dw or not dh or dw == 0 or dh == 0 then
		dw, dh = G.getDimensions()
	end

	local target_w = math.max(200, math.floor((dw or 800) * 0.95))
	local target_h = math.max(200, math.floor((dh or 600) * 0.95))

	love.window.setMode(target_w, target_h, {
		resizable = false,
		fullscreen = false,
		highdpi = false
	})

	local function layout()
		local w, h = love.graphics.getDimensions()
		local maxw = math.max(200, w - margin * 2)
		lines = wrap_text(text, font, maxw)
	end

	-- 监听窗口尺寸变化（简单处理，在 draw 时检测）
	local last_w, last_h = love.graphics.getDimensions()

	-- 鼠标滚轮 callback（如果引擎发送）
	local orig_wheelmoved = love.wheelmoved

	love.wheelmoved = function(x, y)
		if y ~= 0 then
			scroll = math.max(0, scroll - math.floor(y * 3))
		end
	end

	-- 鼠标点击判断按钮
	local orig_mousepressed = love.mousepressed

	local touch_scrolling = false
	local touch_start_y = 0
	local scroll_start = 0
	local orig_touchpressed = love.touchpressed
	local orig_touchmoved = love.touchmoved
	local orig_touchreleased = love.touchreleased

	love.touchpressed = function(id, x, y, dx, dy, pressure)
		touch_scrolling = true
		touch_start_y = y
		scroll_start = scroll
	end

	love.touchmoved = function(id, x, y, dx, dy, pressure)
		if touch_scrolling then
			local w, h = love.graphics.getDimensions()
			local visible_lines = math.floor((h - 180) / line_h)
			local total_lines = #lines
			local max_scroll = math.max(0, total_lines - visible_lines)
			-- 这里的 30 是经验值，可根据实际手感调整
			local delta = (touch_start_y - y) / 30
			scroll = math.max(0, math.min(max_scroll, scroll_start + delta))
		end
	end

	love.touchreleased = function(id, x, y, dx, dy, pressure)
		touch_scrolling = false
	end

	-- 替换 love.update
	love.update = function(dt)
		-- 如果窗口大小变了，重新布局
		local w, h = love.graphics.getDimensions()
		if w ~= last_w or h ~= last_h then
			last_w, last_h = w, h
			layout()
		end
	end

	-- 还原函数
	local function restore()
		love.update = original_love_update_function
		love.draw = original_love_draw_function
		if old_w and old_h and old_flags and love.window and love.window.setMode then
			pcall(function()
				love.window.setMode(old_w, old_h, old_flags)
			end)
		end
		love.wheelmoved = orig_wheelmoved
		love.mousepressed = orig_mousepressed
		love.touchpressed = orig_touchpressed
		love.touchmoved = orig_touchmoved
		love.touchreleased = orig_touchreleased
		-- 标记为已阅读
		storage:write_lua("must_read.lua", {
			read = true
		})
	end

	local confirm_index = 1
	love.mousepressed = function(x, y, button)
		local w, h = love.graphics.getDimensions()
		local content_w = math.max(200, w - margin * 2)
		local visible_lines = math.floor((h - 180) / line_h)
		local total_lines = #lines
		local can_continue = is_scrolled_to_bottom(scroll, total_lines, visible_lines)

		local btn_w, btn_h = 240, 44
		local bx = (w - btn_w) / 2
		local by = h - 100

		if button == 1 then
			if x >= bx and x <= bx + btn_w and y >= by and y <= by + btn_h and can_continue then
				if confirm_index < #confirm_steps then
					confirm_index = confirm_index + 1
				else
					restore()
				end
				return
			end

			-- 输入框点击区域
			if hidden_key then
				local ix, iy, iw, ih = margin, h - 160, content_w, 36
				if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
					input_active = true
					pcall(function()
						love.keyboard.setTextInput(true, ix, iy, iw, ih)
					end)
					return
				else
					input_active = false
					pcall(function()
						love.keyboard.setTextInput(false)
					end)
				end
			end
		end
	end

	-- 初始化布局
	layout()

	-- draw 覆盖
	love.draw = function()
		local w, h = love.graphics.getDimensions()
		-- 背景
		love.graphics.clear(0, 0, 0)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(font)

		local content_w = math.max(200, w - margin * 2)
		local visible_lines = math.floor((h - 180) / line_h)
		local total_lines = #lines

		-- 限制 scroll 合理范围
		local max_scroll = math.max(0, total_lines - visible_lines)
		if scroll > max_scroll then
			scroll = max_scroll
		end
		if scroll < 0 then
			scroll = 0
		end

		-- 标题
		local title = "作者的话"
		love.graphics.printf(title, margin, 20, content_w, "center")

		-- 文本绘制
		local start_i = scroll + 1
		local end_i = math.min(total_lines, scroll + visible_lines)
		local y = 60
		for i = start_i, end_i do
			love.graphics.print(lines[i], margin, y)
			y = y + line_h
		end

		-- 滚动提示（若未到底部）
		if not is_scrolled_to_bottom(scroll, total_lines, visible_lines) then
			love.graphics.setColor(1, 1, 1, 0.7)
			love.graphics.printf("向下滚动以阅读剩余内容...", margin, h - 120, content_w, "left")
		end

		-- Continue 按钮（仅当滚到底部时启用）
		local btn_w, btn_h = 240, 44
		local bx = (w - btn_w) / 2
		local by = h - 100
		local can_continue = is_scrolled_to_bottom(scroll, total_lines, visible_lines)
		love.graphics.setColor(can_continue and {0.1, 0.6, 0.1} or {0.4, 0.4, 0.4})
		love.graphics.rectangle("fill", bx, by, btn_w, btn_h, 6, 6)
		love.graphics.setColor(1, 1, 1)
		local btn_text = confirm_steps[confirm_index].btn
		love.graphics.printf(btn_text, bx, by + (btn_h - font:getHeight()) / 2, btn_w, "center")
	end

	-- expose some for testing / debug
	MUST_READ._state = {
		get_lines = function()
			return lines
		end,
		get_hidden_key = function()
			return hidden_key
		end
	}
end

return MUST_READ
