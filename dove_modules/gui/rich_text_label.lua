--[[
    富文本标签类 - GGRichTextLabel

    支持在文本中使用颜色标记，实现多彩文本显示，并支持自动缩放以适配行数/区域（fit_lines / fit_size / fit_step）。
    实现富文本解析和绘制，同时完美复刻GGLabel的文本自适应功能。

    使用方法：
        local label = RichTextLabel:new(V.v(200, 50))
        label.font_name = "body"
        label.font_size = 12
        label:set_text("普通文本 {c:255,0,0}红色{/c} {c:0,255,0}绿色{/c}")
        label.default_color = {240, 230, 185}
        label.fit_lines = 2
        label.fit_step = 0.5
        label.fit_size = true

    颜色标记语法：
        {c:r,g,b}文本{/c}       - RGB颜色
        {c:r,g,b,a}文本{/c}     - RGBA颜色
]]

require("klove.kui")
local class = require("middleclass")
local V = require("lib.klua.vector")
local G = love.graphics
local F = require("lib.klove.font_db")
local utf8 = require("utf8")
local i18n = require("i18n")
local log = require("lib.klua.log"):new("RichTextLabel")

local RichTextLabel = class("RichTextLabel", KLabel)

RichTextLabel:append_serialize_keys("text_key", "text_shadow", "text_shadow_offset", "fit_lines", "fit_step", "fit_size", "vertical_align", "default_color")

--- 初始化富文本标签对象
-- @param size 标签尺寸（V.v类型）
-- @param image_name 可选，背景图片名
-- @param font_scale 字体缩放因子
-- @param ref_h 参考高度
function RichTextLabel:initialize(size, image_name, font_scale, ref_h)
	self.font_name = nil
	self.font_size = nil
	self.text_key = nil
	self.text_shadow = nil
	self.text_shadow_offset = V.v(1, 1)
	self.fit_lines = nil
	self.fit_step = 0.5
	self.fit_size = nil
	self.vertical_align = "top"
	self.default_color = {240, 230, 185, 255} -- 默认文本颜色
	self._font_scale = font_scale
	self._ref_h = ref_h

	-- 富文本相关
	self._segments = {} -- 解析后的文本段落
	self._dirty = true -- 是否需要重新解析

	KLabel.initialize(self, size, image_name)

	if not self.colors.text_shadow then
		self.colors.text_shadow = {0, 0, 0, 255}
	end

	-- 设置默认文本颜色
	if not self.colors.text then
		self.colors.text = self.default_color
	end

	if self.text_key then
		self.text = _(self.text_key)
	end

	self._fitted_font = nil
	self._fitted_lines = nil
	self._fitted_text = nil
end

--- 解析富文本标记，将带颜色的文本拆分为段落
-- 用途：内部调用，生成 self._segments
function RichTextLabel:_parse_rich_text()
	if not self._dirty then
		return
	end

	self._segments = {}

	if not self.text or self.text == "" then
		self._dirty = false
		return
	end

	local pos = 1
	local text = self.text
	local default_color = self.default_color or {240, 230, 185, 255}

	while pos <= #text do
		-- 查找颜色标记开始：{c:r,g,b} 或 {c:r,g,b,a}
		local tag_start, tag_end = string.find(text, "{c:%d+,%d+,%d+[,%d]*}", pos)

		if tag_start then
			-- 添加标记前的普通文本
			if tag_start > pos then
				table.insert(self._segments, {
					text = string.sub(text, pos, tag_start - 1),
					color = default_color
				})
			end

			-- 解析颜色值
			local color_str = string.match(string.sub(text, tag_start, tag_end), "{c:([%d,]+)}")
			local color_parts = {}
			for num in string.gmatch(color_str, "%d+") do
				table.insert(color_parts, tonumber(num))
			end

			-- 确保至少有RGB，如果没有A则默认255
			if #color_parts >= 3 then
				if #color_parts == 3 then
					table.insert(color_parts, 255)
				end

				-- 查找对应的结束标记
				local close_start, close_end = string.find(text, "{/c}", tag_end + 1)

				if close_start then
					-- 添加彩色文本段
					table.insert(self._segments, {
						text = string.sub(text, tag_end + 1, close_start - 1),
						color = color_parts
					})
					pos = close_end + 1
				else
					-- 没有结束标记，将剩余文本视为彩色
					table.insert(self._segments, {
						text = string.sub(text, tag_end + 1),
						color = color_parts
					})
					break
				end
			else
				-- 无效的颜色标记，跳过
				pos = tag_end + 1
			end
		else
			-- 没有更多标记，添加剩余文本
			table.insert(self._segments, {
				text = string.sub(text, pos),
				color = default_color
			})
			break
		end
	end

	self._dirty = false
end

--- 获取纯文本（去除所有富文本标记）
-- @return string 纯文本内容
function RichTextLabel:get_plain_text()
	self:_parse_rich_text()

	local plain = ""
	for _, segment in ipairs(self._segments) do
		if segment.text then
			plain = plain .. segment.text
		end
	end

	return plain
end

--- 设置文本内容（会触发重新解析富文本）
-- @param text 新文本
function RichTextLabel:set_text(text)
	if self.text ~= text then
		self.text = text
		self._dirty = true
	end
end

--- 加载字体资源，根据当前字体名、字号和缩放
-- 用途：内部调用，设置 self.font 和 self.font_adj
function RichTextLabel:_load_font()
	local font_size = self._fitted_font_size or self.font_size

	if not self.font or self._loaded_font_name ~= self.font_name or self._loaded_font_size ~= font_size then
		self._fitted_font = nil
		self._loaded_font_name = self.font_name
		self._loaded_font_size = font_size

		if self.font_name and self.font_size then
			self.font = F:f(self.font_name, font_size * self._font_scale)
			self.font_adj = F:f_adj(self.font_name, font_size * self._font_scale)
		else
			log.debug("Font not specified for %s", self)

			self.font = G:getFont()
			self.font_adj = {
				size = 1
			}
		end
	end
end

--- 自动适配字体大小以满足 fit_lines/fit_size 需求
-- 用途：内部调用，动态调整字号
function RichTextLabel:_fit_text()
	local font_size = self.font_size
	local fit_lines = self.fit_lines
	local fit_size = self.fit_size
	local step = self.fit_step

	if not fit_lines and not fit_size then
		return
	end

	-- 英文等非CJK语言特殊处理
	if fit_lines and fit_lines > 1 and self.text and not table.contains({"ja", "zh-Hans", "zh-Hant"}, i18n.current_locale) then
		local spacers = {" ", ",", "\n", utf8.char(65292), utf8.char(12290)}

		for _, v in pairs(spacers) do
			if string.find(self.text, v) then
				goto label_3_0
			end
		end

		fit_lines = 1
	end

	::label_3_0::

	if self._fitted_font ~= self.font or self._fitted_starting_font_size ~= font_size or self._fitted_lines ~= fit_lines or self._fitted_fit_size ~= fit_size or self._fitted_step ~= self.fit_step or self._fitted_size ~= self.text_size or self._fitted_text ~= self.text then
		self.font = nil
		self._fitted_font_size = nil

		while font_size >= 1 do
			local _, lines = self:get_wrap_lines()
			local h = lines * self:get_font_height() * self.line_height

			if fit_lines and fit_size and lines <= fit_lines and h <= self.text_size.y or not fit_size and fit_lines and lines <= fit_lines or not fit_lines and fit_size and h <= self.text_size.y then
				break
			end

			font_size = font_size - step
			self._fitted_font_size = font_size
			self.font = nil
		end

		if font_size < 1 then
			log.error("Could not fit label %s for text %s, size:%s,%s, lines:%s, fit_size:%s", self.id, self.text, self.text_size.x, self.text_size.y, fit_lines, fit_size)

			self._fitted_font_size = nil
		end

		self._fitted_starting_font_size = self.font_size
		self._fitted_font = self.font
		self._fitted_lines = fit_lines
		self._fitted_fit_size = fit_size
		self._fitted_step = self.fit_step
		self._fitted_size = self.text_size
		self._fitted_text = self.text
	end
end

--- 获取字体上升线高度
-- @return number 上升线像素
function RichTextLabel:get_font_ascent()
	self:_load_font()

	if self.font then
		return self.font:getAscent() / self._font_scale
	end

	return 0
end

--- 获取字体下降线高度
-- @return number 下降线像素
function RichTextLabel:get_font_descent()
	self:_load_font()

	if self.font then
		return self.font:getDescent() / self._font_scale
	end

	return 0
end

--- 获取字体基线高度
-- @return number 基线像素
function RichTextLabel:get_font_baseline()
	self:_load_font()

	if self.font then
		return self.font:getBaseline() / self._font_scale
	end

	return 0
end

--- 获取当前适配后的字体大小
-- @return number 字号
function RichTextLabel:get_fitted_font_size()
	return self._fitted_font_size or self.font_size
end

--- 获取文本宽度（像素）
-- @param text 可选，指定文本，默认当前纯文本
-- @return number 宽度
function RichTextLabel:get_text_width(text)
	self:_load_font()

	if self.font then
		local plain_text = text or self:get_plain_text()
		return self.font:getWidth(plain_text) / self._font_scale
	end

	return 0
end

--- 获取文本换行后的行数和内容
-- @return width, lines, wrapped 换行宽度、行数、行内容
function RichTextLabel:get_wrap_lines()
	self:_load_font()

	if self.font then
		local plain_text = self:get_plain_text()
		local width, wrapped = self.font:getWrap(plain_text, self.text_size.x * self._font_scale)
		return width / self._font_scale, #wrapped, wrapped
	end

	return 0, 1
end

--- 获取字体高度
-- @return number 字体高度
function RichTextLabel:get_font_height()
	self:_load_font()

	if self.font then
		return self.font:getHeight() / self._font_scale
	end

	return 0
end

--- 手动触发行数适配
-- @param lines 目标行数
-- @param min_size 最小字号（未用）
-- @param step 步进
function RichTextLabel:do_fit_lines(lines, min_size, step)
	self.fit_lines = lines or self.fit_lines
	self.fit_step = step or self.fit_step

	self:_fit_text()
end

--- 标签绘制主方法，负责背景和文本绘制
-- 用途：由KView自动调用
function RichTextLabel:_draw_self()
	-- 只调用KLabel的super（也就是KView）的_draw_self来绘制背景，不调用KLabel的文本绘制
	KLabel.super._draw_self(self)
	self:_fit_text() -- 确保在绘制前进行文本适配
	self:_load_font()

	local font_scale = self._font_scale

	if self.font then
		G.setFont(self.font)
		self.font:setLineHeight(self.line_height)
	end

	local pr, pg, pb, pa = G.getColor()

	local voff = (self.font_adj.top or 0) / font_scale

	-- 垂直对齐处理
	if self.vertical_align and self.vertical_align ~= "top" then
		local _, tl = self:get_wrap_lines()
		local th = self:get_font_height()
		local des = -1 * self.font:getDescent() / font_scale
		local base = self.font:getBaseline() / font_scale

		if tl > 1 then
			th = th + (tl - 1) * self:get_font_height() * self.font:getLineHeight()
		end

		if self.vertical_align == "middle" then
			voff = math.floor((self.text_size.y - th) * 0.5)
		elseif self.vertical_align == "middle-caps" then
			voff = math.floor((self.text_size.y - th + des) * 0.5)
		elseif self.vertical_align == "bottom" then
			voff = self.text_size.y - th
		elseif self.vertical_align == "bottom-caps" then
			voff = self.text_size.y - th + des
		elseif self.vertical_align == "base" then
			voff = -base
		end

		local vadj = (self.font_adj[self.vertical_align] or 0) / font_scale

		voff = voff + vadj
	end

	-- 解析富文本
	self:_parse_rich_text()

	if #self._segments == 0 then
		-- 没有文本段落，绘制普通文本
		self:_draw_plain_text(voff, font_scale, pr, pg, pb, pa)
	else
		-- 绘制富文本段落
		self:_draw_rich_text_segments(voff, font_scale, pr, pg, pb, pa)
	end

	G.setColor(pr, pg, pb, pa)
end

--- 绘制普通文本（无富文本标记时使用）
-- @param voff 垂直偏移
-- @param font_scale 字体缩放
-- @param pr,pg,pb,pa 当前颜色
function RichTextLabel:_draw_plain_text(voff, font_scale, pr, pg, pb, pa)
	if self.text_shadow then
		local tsc = self.colors.text_shadow
		local new_c = {tsc[1], tsc[2], tsc[3], tsc[4]}

		if not new_c[4] then
			new_c[4] = 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor_old(new_c)

		local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y

		G.printf(self.text or "", self.text_offset.x + sox, self.text_offset.y + soy + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	end

	if self.colors.text then
		local new_c = {self.colors.text[1], self.colors.text[2], self.colors.text[3], self.colors.text[4]}

		if not new_c[4] then
			new_c[4] = 255
		end

		if self.colors.tint then
			local tint_c = self.colors.tint

			new_c[1] = new_c[1] * tint_c[1]
			new_c[2] = new_c[2] * tint_c[2]
			new_c[3] = new_c[3] * tint_c[3]
			new_c[4] = new_c[4] * tint_c[4]
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor_old(new_c)
	end

	G.printf(self.text or "", self.text_offset.x, self.text_offset.y + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
end

--- 绘制富文本段落，按行分段绘制
-- @param voff 垂直偏移
-- @param font_scale 字体缩放
-- @param pr,pg,pb,pa 当前颜色
function RichTextLabel:_draw_rich_text_segments(voff, font_scale, pr, pg, pb, pa)
	if not self.font or #self._segments == 0 then
		return
	end

	-- 获取完整的纯文本用于换行计算
	local plain_text = self:get_plain_text()

	-- 使用字体的 getWrap 方法获取换行后的文本行
	local _, wrapped_lines = self.font:getWrap(plain_text, self.text_size.x * font_scale)

	if #wrapped_lines == 0 then
		return
	end

	-- 为每个段落找到其在换行文本中的位置
	local line_height = self:get_font_height() * self.line_height

	for line_idx, line_text in ipairs(wrapped_lines) do
		local line_y = self.text_offset.y + voff + (line_idx - 1) * line_height

		-- 在当前行中绘制所有相关的文本段
		self:_draw_line_segments(line_text, line_y, font_scale, pr, pg, pb, pa)
	end
end

--- 在指定行绘制富文本段落，支持多色与阴影
-- @param line_text 当前行文本
-- @param line_y 行Y坐标
-- @param font_scale 字体缩放
-- @param pr,pg,pb,pa 当前颜色
function RichTextLabel:_draw_line_segments(line_text, line_y, font_scale, pr, pg, pb, pa)
	local plain_text = self:get_plain_text()
	local line_start = string.find(plain_text, line_text, 1, true)

	if not line_start then
		return
	end

	local line_end = line_start + #line_text - 1
	local segment_start = 1

	for _, segment in ipairs(self._segments) do
		if segment.text and segment.text ~= "" then
			local segment_end = segment_start + #segment.text - 1

			-- 检查这个段落是否与当前行有重叠
			if segment_start <= line_end and segment_end >= line_start then
				-- 计算在当前行中的部分
				local text_start = math.max(segment_start, line_start)
				local text_end = math.min(segment_end, line_end)

				if text_start <= text_end then
					-- 提取在当前行的文本部分
					local char_start_in_segment = text_start - segment_start + 1
					local char_end_in_segment = text_end - segment_start + 1
					local segment_text = string.sub(segment.text, char_start_in_segment, char_end_in_segment)

					-- 计算前面文本的宽度
					local prefix_text = string.sub(line_text, 1, text_start - line_start)
					local prefix_width = self.font:getWidth(prefix_text) / font_scale

					-- 绘制文本段阴影
					if self.text_shadow then
						local tsc = self.colors.text_shadow
						local shadow_alpha = self.alpha * pa / 255 * (tsc[4] or 255) / 255

						G.setColor_old({tsc[1], tsc[2], tsc[3], shadow_alpha * 255})

						local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y
						G.print(segment_text, self.text_offset.x + prefix_width + sox, line_y + soy, 0, 1 / font_scale)
					end

					-- 绘制彩色文本段
					local color = segment.color
					local alpha_factor = self.alpha * pa / 255

					local final_color = {color[1], color[2], color[3], (color[4] or 255) * alpha_factor}

					-- 应用tint
					if self.colors.tint then
						local tint_c = self.colors.tint
						final_color[1] = final_color[1] * tint_c[1]
						final_color[2] = final_color[2] * tint_c[2]
						final_color[3] = final_color[3] * tint_c[3]
						final_color[4] = final_color[4] * tint_c[4]
					end

					G.setColor_old(final_color)
					G.print(segment_text, self.text_offset.x + prefix_width, line_y, 0, 1 / font_scale)
				end
			end

			segment_start = segment_end + 1
		end
	end
end

return RichTextLabel
