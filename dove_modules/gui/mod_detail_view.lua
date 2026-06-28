-- 插件详情弹窗（README 查看器）
-- 支持 markdown 的简单渲染（标题、加粗、代码块等）
local class = require("middleclass")
local V = require("lib.klua.vector")
local S = require("sound_db")
local km = require("lib.klua.macros")
local utf8_util = require("lib.utf8_utils")

require("gg_views_custom")

local PANEL_MARGIN = 150
local PANEL_MIN_W = 900
local PANEL_MAX_W = 10000
local PANEL_MIN_H = 730
local PANEL_MAX_H = 10000
local RS = GGLabel.static.ref_h / REF_H

-- ─────────────────────────────────────────────
-- Markdown 解析：将 markdown 文本解析为块列表
-- ─────────────────────────────────────────────

local BlockType = {
	HEADING = "heading",
	PARAGRAPH = "paragraph",
	CODE = "code",
	LIST_ITEM = "list_item",
	HORIZONTAL_RULE = "hr",
	BLOCKQUOTE = "blockquote",
	TABLE = "table",
	EMPTY = "empty"
}

--- 去除行内 markdown 标记，保留纯文本
local function strip_inline_markdown(text)
	if not text then
		return ""
	end
	-- 行内代码 `text`
	text = text:gsub("`([^`]+)`", "%1")
	-- 加粗 **text** 或 __text__
	text = text:gsub("%*%*(.-)%*%*", "%1")
	text = text:gsub("__(.-)__", "%1")
	-- 斜体 *text*：* 几乎不会出现在普通文本中，直接匹配
	text = text:gsub("%*(.-)%*", "%1")
	-- 斜体 _text_：只在单词边界时才算，防止吞噬 hero_auto_rally 中的下划线
	-- 规则：前面是[非单词字符或行首]，后面是[非单词字符或行尾]
	text = text:gsub("([^%w])_([^_]-)_([^%w])", "%1%2%3")
	text = text:gsub("^_([^_]-)_([^%w])", "%1%2")
	text = text:gsub("([^%w])_([^_]-)_$", "%1%2")
	text = text:gsub("^_([^_]-)_$", "%1")
	-- 删除线 ~~text~~
	text = text:gsub("~~(.-)~~", "%1")
	-- 链接 [text](url) 只保留 text
	text = text:gsub("%[([^%]]*)%]%([^%)]*%)", "%1")
	-- 图片 ![alt](url) 完全去除
	text = text:gsub("!%[[^%]]*%]%([^%)]*%)", "")
	-- HTML 标签
	text = text:gsub("<[^>]+>", "")
	return text
end

-----------------------------------------------------------------------
-- 纯字符串辅助：检查一行是否全部由同一个字符重复组成（如 --- *** ___）
local function is_all_same_char(s)
	if #s < 3 then
		return false
	end
	local c = s:sub(1, 1)
	if c ~= "-" and c ~= "_" and c ~= "*" then
		return false
	end
	for i = 2, #s do
		if s:sub(i, i) ~= c then
			return false
		end
	end
	return true
end

-- 纯字符串辅助：提取前导 fence 字符（``` 或 ~~~）
local function fence_prefix(s)
	if #s == 0 then
		return nil
	end
	local c = s:sub(1, 1)
	if c ~= "`" and c ~= "~" then
		return nil
	end
	local n = 0
	for i = 1, #s do
		if s:sub(i, i) == c then
			n = n + 1
		else
			break
		end
	end
	if n >= 3 then
		return s:sub(1, n)
	end
	return nil
end

-- 纯字符串辅助：检查是否为表格分隔行（|------| 或 |:---:|）
local function is_table_sep(s)
	if s:sub(1, 1) ~= "|" then
		return false
	end
	if s:sub(-1, -1) ~= "|" then
		return false
	end
	if #s < 3 then
		return false
	end
	-- 内层允许 - : 空格以及列分隔符 |
	for i = 2, #s - 1 do
		local c = s:sub(i, i)
		if c ~= "-" and c ~= ":" and c ~= " " and c ~= "|" then
			return false
		end
	end
	return true
end

-- trim 空白
local function trim(s)
	return s:match("^%s*(.-)%s*$") or s
end

--- 简易 markdown 渲染：逐行分类并生成块列表（纯字符串操作，无 goto）
local function parse_markdown(text)
	if not text or text == "" then
		return {}
	end

	text = text:gsub("\r\n?", "\n")
	local raw = {}
	-- 逐行分割，避免 gmatch("([^\n]*)") 在相邻 \n 之间产生幽灵空串 ""
	-- 但仍保留真实的空行（EMPTY block 需要）
	local pos = 1
	local len = #text
	while pos <= len do
		local next_nl = text:find("\n", pos)
		if next_nl then
			raw[#raw + 1] = text:sub(pos, next_nl - 1)
			pos = next_nl + 1
		else
			raw[#raw + 1] = text:sub(pos)
			break
		end
	end
	if #raw == 0 then
		return {{
			block_type = BlockType.PARAGRAPH,
			text = text
		}}
	end
	while #raw > 0 and raw[#raw]:match("^%s*$") do
		raw[#raw] = nil
	end
	if #raw == 0 then
		return {}
	end

	local blocks = {}
	local in_code = false
	local c_marker = nil
	local c_lines = {}
	local idx = 1

	while idx <= #raw do
		local l = raw[idx]

		-- ─── 代码块内部 ────────────────────
		if in_code then
			local trimmed_close = l:match("^%s*(.-)%s*$")
			if trimmed_close and trimmed_close == c_marker then
				local ct = table.concat(c_lines, "\n")
				if ct ~= "" then
					blocks[#blocks + 1] = {
						block_type = BlockType.CODE,
						text = ct
					}
				end
				in_code = false
				c_marker = nil
				c_lines = {}
			else
				c_lines[#c_lines + 1] = l
			end
			idx = idx + 1

		-- ─── 代码块开口 ────────────────────
		else
			local fp = fence_prefix(l)
			if fp then
				c_marker = fp
				in_code = true
				c_lines = {}
				idx = idx + 1

			-- ─── 空行 ──────────────────────
			elseif l:match("^%s*$") then
				blocks[#blocks + 1] = {
					block_type = BlockType.EMPTY
				}
				idx = idx + 1

			-- ─── 水平分割线 ────────────────
			else
				local trimmed = l:match("^%s*(.-)%s*$")
				if trimmed and is_all_same_char(trimmed) then
					blocks[#blocks + 1] = {
						block_type = BlockType.HORIZONTAL_RULE
					}
					idx = idx + 1

				-- ─── 标题 ──────────────────
				else
					local hash = 0
					for i = 1, (#l) do
						if l:sub(i, i) == "#" then
							hash = hash + 1
						else
							break
						end
					end
					if hash >= 1 and hash < #l and l:sub(hash + 1, hash + 1) == " " then
						local h_text = l:sub(hash + 2)
						blocks[#blocks + 1] = {
							block_type = BlockType.HEADING,
							text = strip_inline_markdown(h_text),
							level = math.min(hash, 6)
						}
						idx = idx + 1

					-- ─── 引用 ──────────────
					elseif l:sub(1, 1) == ">" then
						local bq = l:match("^%>%s?(.+)$")
						blocks[#blocks + 1] = {
							block_type = BlockType.BLOCKQUOTE,
							text = strip_inline_markdown(bq or l:sub(2))
						}
						idx = idx + 1

					-- ─── 列表项 ────────────
					else
						local li_ws, li_t = l:match("^(%s*)[%*%+%-]%s+(.+)$")
						if not li_t then
							li_ws, li_t = l:match("^(%s*)%d+[%.%)]%s+(.+)$")
						end
						if li_t then
							blocks[#blocks + 1] = {
								block_type = BlockType.LIST_ITEM,
								text = strip_inline_markdown(li_t),
								indent = math.floor(#li_ws / 2)
							}
							idx = idx + 1

						-- ─── 表格 ──────────
						-- 收集连续的表格行，合并为一个 TABLE block
						-- 跳过表格行之间可能的真实空行（某些 markdown 风格）
						elseif l:sub(1, 1) == "|" then
							local table_rows = {}
							local sep_found = false
							while idx <= #raw do
								local tl = raw[idx]
								local ttrimmed = tl:match("^%s*(.-)%s*$") or tl

								-- 空行（可能是 gmatch 伪影，也可能是真实的空行）
								-- 向前窥探：如果后续还有 | 行则跳过，属于同一表格
								if tl:match("^%s*$") then
									local peek = idx + 1
									local has_more_table = false
									while peek <= #raw do
										local pl = raw[peek]
										if pl:match("^%s*$") then
											peek = peek + 1
										elseif pl:sub(1, 1) == "|" then
											has_more_table = true
											break
										else
											break
										end
									end
									if has_more_table then
										idx = idx + 1
									else
										break
									end

								elseif tl:sub(1, 1) == "|" then
									if is_table_sep(ttrimmed) then
										sep_found = true
									else
										local cells = {}
										local inner = ttrimmed:match("^|%s*(.-)%s*|$") or ttrimmed:match("^|%s*(.+)$") or ttrimmed
										for cell in inner:gmatch("([^|]+)") do
											local c = cell:match("^%s*(.-)%s*$") or cell
											cells[#cells + 1] = utf8_util.sanitize(strip_inline_markdown(c))
										end
										table_rows[#table_rows + 1] = cells
									end
									idx = idx + 1

								else
									break
								end
							end
							if #table_rows > 0 then
								blocks[#blocks + 1] = {
									block_type = BlockType.TABLE,
									rows = table_rows,
									header_count = sep_found and 1 or 0
								}
							end

						-- ─── 默认段落 ──────
						else
							blocks[#blocks + 1] = {
								block_type = BlockType.PARAGRAPH,
								text = strip_inline_markdown(l)
							}
							idx = idx + 1
						end
					end
				end
			end
		end
	end

	if in_code and #c_lines > 0 then
		blocks[#blocks + 1] = {
			block_type = BlockType.CODE,
			text = table.concat(c_lines, "\n")
		}
	end

	return blocks
end

-- ─────────────────────────────────────────────
-- ModDetailView
-- ─────────────────────────────────────────────
ModDetailView = class("ModDetailView", KView)

function ModDetailView:initialize(sw, sh, title, content, fallback_text)
	KView.initialize(self, V.v(sw, sh))
	self._content = content or ""
	self._fallback_text = fallback_text or "暂无说明文档"
	self._title = utf8_util.sanitize(title or "详情")

	-- 面板尺寸
	local panel_w = math.min(PANEL_MAX_W, sw - PANEL_MARGIN)
	panel_w = math.max(PANEL_MIN_W, panel_w)
	panel_w = math.min(panel_w, sw - 12)
	local panel_h = math.min(PANEL_MAX_H, sh - PANEL_MARGIN)
	panel_h = math.max(PANEL_MIN_H, panel_h)
	panel_h = math.min(panel_h, sh - 12)

	-- 背景遮罩
	self.colors.background = {0, 0, 0, 160}

	-- 面板
	self._panel = KView:new(V.v(panel_w, panel_h))
	self._panel.colors.background = {47, 34, 6, 235}
	self._panel.anchor = V.v(panel_w / 2, panel_h / 2)
	self._panel.pos = V.v(sw / 2, sh / 2)
	self._panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, panel_w, panel_h, 16, 16}
	}
	self:add_child(self._panel)

	-- 标题
	local header_bg = KView:new(V.v(panel_w, 44))
	header_bg.colors.background = {38, 28, 8, 220}
	header_bg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, panel_w, 44, 16, 16, 0, 0}
	}
	header_bg.pos = V.v(0, 0)
	self._panel:add_child(header_bg)

	local title_lbl = GGLabel:new(V.v(panel_w - 80, 44))
	title_lbl.font_name = "h"
	title_lbl.font_size = 17 * RS
	title_lbl.text_align = "left"
	title_lbl.vertical_align = "middle"
	title_lbl.colors.text = {244, 221, 165, 255}
	title_lbl.text = utf8_util.sanitize(self._title) .. " - 详情"
	title_lbl.fit_lines = 1
	title_lbl.fit_size = true
	title_lbl.pos = V.v(16, 0)
	self._panel:add_child(title_lbl)

	-- 关闭按钮
	local close_btn = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	close_btn.pos = V.v(panel_w - 23, 23)
	close_btn.scale:set(1.5, 1.5)
	close_btn:set_anchor_to_center()
	close_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:hide()
	end
	self._panel:add_child(close_btn)

	-- 滚动区域
	local scroll_top = 52
	local scroll_bottom = 16
	local scroll_w = panel_w - 40
	local scroll_h = panel_h - scroll_top - scroll_bottom

	self._scroll = KScrollList:new(V.v(scroll_w, scroll_h))
	self._scroll.pos = V.v(20, scroll_top)
	self._scroll.drag_scroll_threshold = 8
	self._scroll.scroll_amount = 24
	self._scroll.colors.scroller_background = {45, 36, 22, 200}
	self._scroll.colors.scroller_foreground = {110, 90, 50, 255}
	self._scroll.scroller_width = 18
	self._panel:add_child(self._scroll)

	-- 渲染内容
	self:_render_content(content)
end

function ModDetailView:show()
-- KView 没有 show 方法，hidden 默认为 false，无需额外操作
end

function ModDetailView:hide()
	self.parent:remove_child(self)
end

function ModDetailView:_render_content(content)
	self._scroll:clear_rows()

	local has_content = content and content ~= ""
	if not has_content then
		self:_add_empty_row(self._fallback_text)
		return
	end

	local scroll_w = self._scroll.size.x - self._scroll.scroller_width - 2 * self._scroll.scroller_margin - 4
	local blocks = parse_markdown(content)

	for _, block in ipairs(blocks) do
		-- print("Rendering block type:", block.block_type, "text:", block.text)
		if block.block_type == BlockType.EMPTY then
			self:_add_spacer_row(12)
		elseif block.block_type == BlockType.HORIZONTAL_RULE then
			self:_add_hr_row(scroll_w)
		elseif block.block_type == BlockType.HEADING then
			self:_add_heading_row(block.text, block.level, scroll_w)
		elseif block.block_type == BlockType.CODE then
			self:_add_code_row(block.text, scroll_w)
		elseif block.block_type == BlockType.BLOCKQUOTE then
			self:_add_quote_row(block.text, scroll_w)
		elseif block.block_type == BlockType.TABLE then
			self:_add_table_block(block, scroll_w)
		elseif block.block_type == BlockType.LIST_ITEM then
			self:_add_list_item_row(block.text, block.indent or 0, scroll_w)
		else
			self:_add_paragraph_row(block.text, scroll_w)
		end
	end
end

function ModDetailView:_add_empty_row(message)
	local scroll_w = self._scroll.size.x - self._scroll.scroller_width - 2 * self._scroll.scroller_margin - 4
	local row = KView:new(V.v(scroll_w, 50))
	local lbl = GGLabel:new(V.v(scroll_w, 50))
	lbl.font_name = "body"
	lbl.font_size = 15 * RS
	lbl.text_align = "center"
	lbl.vertical_align = "middle"
	lbl.colors.text = {200, 180, 130, 255}
	lbl.text = utf8_util.sanitize(message or "暂无内容")
	lbl.fit_lines = 2
	lbl.fit_size = true
	lbl.line_height = 1.4
	lbl.pos = V.v(0, 0)
	row:add_child(lbl)
	self._scroll:add_row(row)
end

function ModDetailView:_add_spacer_row(height)
	local scroll_w = self._scroll.size.x - self._scroll.scroller_width - 2 * self._scroll.scroller_margin - 4
	self._scroll:add_row(KView:new(V.v(scroll_w, height)))
end

function ModDetailView:_add_hr_row(scroll_w)
	self:_add_spacer_row(6)
	local hr = KView:new(V.v(scroll_w, 3))
	hr.colors.background = {95, 75, 40, 200}
	hr.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, scroll_w, 3, 2, 2}
	}
	self._scroll:add_row(hr)
	self:_add_spacer_row(6)
end

function ModDetailView:_add_heading_row(text, level, scroll_w)
	local font_size_map = {22, 19, 17, 15, 14, 13}
	local paddings = {8, 6, 4, 3, 2, 2}
	local fs = font_size_map[level] or 15
	local padding = paddings[level] or 4
	local row = KView:new(V.v(scroll_w, fs * 1.5 + padding * 2))

	local lbl = GGLabel:new(V.v(scroll_w, fs * 1.5 + padding * 2))
	lbl.font_name = "h"
	lbl.font_size = fs * RS
	lbl.text_align = "left"
	lbl.vertical_align = "middle"
	lbl.colors.text = {244, 221, 165, 255}
	lbl.text = utf8_util.sanitize(text)
	lbl.fit_lines = 2
	lbl.fit_size = true
	lbl.line_height = 1.3
	lbl.pos = V.v(0, padding)
	row:add_child(lbl)
	self._scroll:add_row(row)
	self:_add_spacer_row(4)
end

function ModDetailView:_add_paragraph_row(text, scroll_w)
	if not text or text == "" then
		return
	end
	local lbl = GGLabel:new(V.v(scroll_w, 200))
	lbl.font_name = "body"
	lbl.font_size = 14 * RS
	lbl.text_align = "left"
	lbl.vertical_align = "top"
	lbl.colors.text = {148, 140, 116, 255}
	lbl.text = utf8_util.sanitize(text)
	lbl.fit_lines = 9999 -- 不限行数，不缩小字号，文本自由换行
	lbl.line_height = 1.45

	-- 计算文本换行后的实际高度
	local _, wrapped_lines = lbl:get_wrap_lines()
	local font_height = lbl:get_font_height()
	local text_h = math.max(font_height, wrapped_lines * font_height * lbl.line_height)
	local h = math.ceil(text_h) + 4

	local row = KView:new(V.v(scroll_w, h))
	lbl.size = V.v(scroll_w, h)
	lbl.pos = V.v(0, 2)
	row:add_child(lbl)
	self._scroll:add_row(row)
end

function ModDetailView:_add_code_row(text, scroll_w)
	local padding_v = 10
	local padding_h = 16
	local code_lbl = GGLabel:new(V.v(scroll_w - padding_h - 8, 200))
	code_lbl.font_name = "body"
	code_lbl.font_size = 15 * RS
	code_lbl.text_align = "left"
	code_lbl.vertical_align = "top"
	code_lbl.colors.text = {195, 215, 180, 255}
	code_lbl.text = utf8_util.sanitize(text)
	code_lbl.fit_lines = 9999
	code_lbl.line_height = 1.35

	-- 使用 GGLabel API 精确计算文本高度
	local _, wrapped_lines = code_lbl:get_wrap_lines()
	local font_height = code_lbl:get_font_height()
	local text_h = math.max(font_height, wrapped_lines * font_height * code_lbl.line_height)
	local h = math.ceil(text_h) + padding_v * 2 + 2
	code_lbl.size = V.v(scroll_w - padding_h - 8, h)

	local row = KView:new(V.v(scroll_w, h))
	row.colors.background = {22, 18, 12, 210}
	row.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, scroll_w, h, 8, 8}
	}

	-- 左侧彩色竖条，强调代码块
	local accent_bar = KView:new(V.v(5, h))
	accent_bar.colors.background = {60, 140, 90, 220}
	accent_bar.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 5, h, 2, 2, 0, 0}
	}
	row:add_child(accent_bar)

	code_lbl.pos = V.v(padding_h, padding_v)
	row:add_child(code_lbl)
	self._scroll:add_row(row)
	self:_add_spacer_row(8)
end

function ModDetailView:_add_table_block(block, scroll_w)
	local rows = block.rows
	if not rows or #rows == 0 then
		return
	end

	local header_count = block.header_count or 0

	-- 计算最大列数
	local max_cells = 0
	for _, row in ipairs(rows) do
		max_cells = math.max(max_cells, #row)
	end
	if max_cells == 0 then
		return
	end

	local cell_w = math.floor((scroll_w - 2) / max_cells)
	local font_size = 13 * RS
	local line_height_v = font_size * 1.35

	for row_idx, cells in ipairs(rows) do
		local cell_count = math.max(1, #cells)
		-- 估算行高
		local max_cell_lines = 1
		for _, c in ipairs(cells) do
			local approx_lines = math.max(1, math.ceil(#c / math.max(1, math.floor(cell_w / (font_size * 0.65)))))
			max_cell_lines = math.max(max_cell_lines, approx_lines)
		end

		-- 行高 = 文字高度 + 上下留白
		local row_h = math.max(26, max_cell_lines * line_height_v + 12)
		local row = KView:new(V.v(scroll_w, row_h))

		-- 底部细线
		local bottom_line = KView:new(V.v(scroll_w, 1))
		bottom_line.colors.background = {80, 65, 35, 180}
		bottom_line.pos = V.v(0, row_h - 2)
		row:add_child(bottom_line)

		local is_header = row_idx <= header_count

		for idx, cell_text in ipairs(cells) do
			local lbl = GGLabel:new(V.v(cell_w - 4, row_h))
			if is_header then
				-- 表头行：粗体（使用 h 字体族）+ 金色文字
				lbl.font_name = "h"
				lbl.font_size = font_size
				lbl.colors.text = {244, 221, 165, 255}
			else
				-- 数据行：正常体
				lbl.font_name = "body"
				lbl.font_size = font_size
				lbl.colors.text = {160, 152, 120, 255}
			end
			lbl.text_align = "left"
			lbl.vertical_align = "middle"
			lbl.text = cell_text
			lbl.fit_lines = 3
			lbl.fit_size = true
			lbl.pos = V.v((idx - 1) * cell_w + 2, 0)
			row:add_child(lbl)
		end

		self._scroll:add_row(row)
	end
end

function ModDetailView:_add_quote_row(text, scroll_w)
	local lbl = GGLabel:new(V.v(scroll_w - 20, 200))
	lbl.font_name = "body"
	lbl.font_size = 13 * RS
	lbl.text_align = "left"
	lbl.vertical_align = "top"
	lbl.colors.text = {180, 170, 130, 255}
	lbl.text = utf8_util.sanitize(text)
	lbl.fit_lines = 9999 -- 不限行数，不缩小字号
	lbl.line_height = 1.4

	-- 计算文本换行后的实际高度
	local _, wrapped_lines = lbl:get_wrap_lines()
	local font_height = lbl:get_font_height()
	local text_h = math.max(font_height, wrapped_lines * font_height * lbl.line_height)
	local h = math.ceil(text_h) + 4
	local row = KView:new(V.v(scroll_w, h))

	lbl.size = V.v(scroll_w - 20, h)

	-- 引用左侧竖线
	local quote_bar = KView:new(V.v(4, h))
	quote_bar.colors.background = {161, 122, 45, 200}
	quote_bar.pos = V.v(0, 0)
	row:add_child(quote_bar)

	lbl.pos = V.v(14, 2)
	row:add_child(lbl)
	self._scroll:add_row(row)
end

function ModDetailView:_add_list_item_row(text, indent, scroll_w)
	local lbl = GGLabel:new(V.v(scroll_w - indent * 20 - 20, 200))
	lbl.font_name = "body"
	lbl.font_size = 14 * RS
	lbl.text_align = "left"
	lbl.vertical_align = "top"
	lbl.colors.text = {148, 140, 116, 255}
	lbl.text = utf8_util.sanitize("• " .. text)
	lbl.fit_lines = 9999 -- 不限行数，不缩小字号
	lbl.line_height = 1.4

	-- 计算文本换行后的实际高度
	local _, wrapped_lines = lbl:get_wrap_lines()
	local font_height = lbl:get_font_height()
	local text_h = math.max(font_height, wrapped_lines * font_height * lbl.line_height)
	local h = math.ceil(text_h) + 4

	local row = KView:new(V.v(scroll_w, h))
	lbl.size = V.v(scroll_w - indent * 20 - 20, h)
	lbl.pos = V.v(indent * 20, 2)
	row:add_child(lbl)
	self._scroll:add_row(row)
end

return ModDetailView
