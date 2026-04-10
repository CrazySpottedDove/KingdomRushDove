-- chunkname: @./dove_modules/gui/numeric_keyboard_view.lua
-- 内置数字键盘输入界面
-- 支持带小数点的数字输入、删除、光标位置移动
-- 可在安卓和电脑端使用
--
-- 用法:
--   require("dove_modules.gui.numeric_keyboard_view")
--   local kb = NumericKeyboardView:new(sw, sh)
--   parent:add_child(kb)
--   kb.responder_setter = function(v) screen_map.window:set_responder(v) end
--   kb:open(initial_value, function(value) ... end, { allow_negative=true, allow_decimal=true })
--   -- callback 收到数字（确认）或 nil（取消）

local class = require("middleclass")
local V = require("lib.klua.vector")
local S = require("sound_db")

require("gg_views_custom") -- PopUpView, GGPanelHeader, GGLabel, KView, KButton …

-- ─────────────────────────────────────────────────────────────
-- 布局常量
-- ─────────────────────────────────────────────────────────────
local PANEL_W = 360
local PAD = 18 -- 面板内边距
local GAP = 7 -- 按钮间距
local BTN_H = 56 -- 按钮高度
local HEADER_H = 34 -- 标题栏高度
local DISP_H = 54 -- 显示框高度
local RADIUS = 14 -- 面板圆角

-- 3 列按钮宽度（数字区）
local BTN_W3 = math.floor((PANEL_W - PAD * 2 - GAP * 2) / 3) -- ≈ 103
-- 2 列按钮宽度（操作区）
local BTN_W2 = math.floor((PANEL_W - PAD * 2 - GAP) / 2) -- ≈ 158

-- 数字键盘起始 Y（标题 + 显示框下方）
local ROWS_Y = PAD + HEADER_H + 8 + DISP_H + 12
local ROW_DY = BTN_H + GAP -- 每行步进

-- 面板总高度：4 数字行 + 1 导航行 + 1 操作行
local PANEL_H = ROWS_Y + 6 * ROW_DY + PAD

-- ─────────────────────────────────────────────────────────────
-- 颜色方案（与王国保卫战 UI 风格匹配）
-- ─────────────────────────────────────────────────────────────
local C = {
	panel = {47, 34, 6, 232},
	sep = {95, 75, 40, 200},

	disp_bg = {16, 10, 2, 248},
	disp_bor = {130, 100, 38, 255}, -- 金色边框
	disp_err = {200, 60, 40, 220}, -- 非法数字时的底色提示

	text = {238, 218, 162, 255},
	text_hint = {150, 135, 90, 180},
	text_err = {255, 120, 80, 255},

	btn = {62, 46, 18, 215},
	btn_h = {95, 70, 26, 255},

	btn_del = {118, 52, 16, 230},
	btn_del_h = {158, 70, 22, 255},

	btn_nav = {48, 52, 78, 215}, -- 蓝紫色，区分导航键
	btn_nav_h = {68, 76, 112, 255},

	btn_ok = {35, 148, 68, 215},
	btn_ok_h = {55, 180, 85, 250},

	btn_no = {148, 38, 38, 215},
	btn_no_h = {178, 55, 55, 250},

	btn_dis = {40, 35, 25, 130}, -- 禁用状态
	text_dis = {110, 100, 75, 130},

	cursor = {255, 210, 100, 200}
}

-- ─────────────────────────────────────────────────────────────
-- NumKeyButton：键盘单个按键
-- ─────────────────────────────────────────────────────────────
NumKeyButton = class("NumKeyButton", KButton)

function NumKeyButton:initialize(label, w, h, bg_n, bg_h)
	KButton.initialize(self, V.v(w, h))

	self._bg_n = bg_n or C.btn
	self._bg_h = bg_h or C.btn_h
	self._disabled_vis = false

	self.colors.background = {unpack(self._bg_n)}
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, w, h, 7, 7}
	}

	local rs = GGLabel.static.ref_h / REF_H

	local lbl = GGLabel:new(V.v(w, h))
	lbl.font_name = "h"
	lbl.font_size = 22 * rs
	lbl.text = label
	lbl.text_align = "center"
	lbl.vertical_align = "middle"
	lbl.colors.text = {unpack(C.text)}
	lbl.propagate_on_up = true
	lbl.propagate_on_down = true
	lbl.propagate_on_click = true
	self:add_child(lbl)
	self._lbl = lbl

	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false
end

function NumKeyButton:on_enter()
	if not self._disabled_vis then
		self.colors.background = {unpack(self._bg_h)}
	end
end

function NumKeyButton:on_exit()
	if not self._disabled_vis then
		self.colors.background = {unpack(self._bg_n)}
	end
end

function NumKeyButton:set_disabled_visual(dis)
	self._disabled_vis = dis
	if dis then
		self.colors.background = {unpack(C.btn_dis)}
		self._lbl.colors.text = {unpack(C.text_dis)}
	else
		self.colors.background = {unpack(self._bg_n)}
		self._lbl.colors.text = {unpack(C.text)}
	end
end

-- ─────────────────────────────────────────────────────────────
-- NumericKeyboardView：主弹出面板
-- ─────────────────────────────────────────────────────────────
NumericKeyboardView = class("NumericKeyboardView", PopUpView)

function NumericKeyboardView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	local rs = GGLabel.static.ref_h / REF_H
	local safe_margin = 24

	-- ── 面板背景 ──────────────────────────────────────────────
	local back = KView:new(V.v(PANEL_W, PANEL_H))
	back.colors.background = C.panel
	back.anchor = V.v(PANEL_W / 2, PANEL_H / 2)
	back.pos = V.v(sw / 2, sh / 2)
	-- 兜底缩放：保证安卓/小屏设备上不会超出屏幕
	local sx = math.max(0.1, (sw - safe_margin * 2) / PANEL_W)
	local sy = math.max(0.1, (sh - safe_margin * 2) / PANEL_H)
	local panel_scale = math.min(1, sx, sy)
	back.scale = V.v(panel_scale, panel_scale)
	back.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, PANEL_W, PANEL_H, RADIUS, RADIUS}
	}
	self:add_child(back)
	self.back = back

	-- ── 标题 ──────────────────────────────────────────────────
	local title_lbl = GGPanelHeader:new("数字输入", PANEL_W - 40)
	title_lbl.pos = V.v(20, 6)
	back:add_child(title_lbl)
	self._title_lbl = title_lbl

	-- ── 关闭按钮 ──────────────────────────────────────────────
	local close_btn = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	close_btn.pos = V.v(PANEL_W - 18, 18)
	close_btn:set_anchor_to_center()
	back:add_child(close_btn)

	local this = self
	function close_btn.on_click()
		S:queue("GUIButtonCommon")
		this:_cancel()
	end

	-- ── 显示框边框（金色，略大于内框） ─────────────────────────
	local field_x = PAD
	local field_y = PAD + HEADER_H + 8
	local field_w = PANEL_W - PAD * 2

	local disp_bor = KView:new(V.v(field_w + 4, DISP_H + 4))
	disp_bor.pos = V.v(field_x - 2, field_y - 2)
	disp_bor.colors.background = C.disp_bor
	disp_bor.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, field_w + 4, DISP_H + 4, 8, 8}
	}
	back:add_child(disp_bor)

	-- ── 显示框背景 ──────────────────────────────────────────────
	local disp_bg = KView:new(V.v(field_w, DISP_H))
	disp_bg.pos = V.v(field_x, field_y)
	disp_bg.colors.background = C.disp_bg
	disp_bg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, field_w, DISP_H, 7, 7}
	}
	back:add_child(disp_bg)
	self._disp_bg = disp_bg

	-- ── 显示框文字 ──────────────────────────────────────────────
	local disp_lbl = GGLabel:new(V.v(field_w - 16, DISP_H))
	disp_lbl.pos = V.v(8, 0)
	disp_lbl.font_name = "h"
	disp_lbl.font_size = 26 * rs
	disp_lbl.text = "0"
	disp_lbl.text_align = "right"
	disp_lbl.vertical_align = "middle"
	disp_lbl.colors.text = {unpack(C.text)}
	disp_bg:add_child(disp_lbl)
	self._disp_lbl = disp_lbl

	-- 独立光标条：不把光标字符插入文本，避免闪烁时文本宽度变化导致抖动
	local cursor_bar = KView:new(V.v(2, DISP_H - 18))
	cursor_bar.pos = V.v(field_w - 10, 9)
	cursor_bar.colors.background = C.cursor
	cursor_bar.hidden = true
	cursor_bar.propagate_on_up = true
	cursor_bar.propagate_on_down = true
	cursor_bar.propagate_on_click = true
	disp_bg:add_child(cursor_bar)
	self._cursor_bar = cursor_bar
	self._disp_text_right_x = disp_lbl.pos.x + disp_lbl.size.x

	-- ── 分隔线 ──────────────────────────────────────────────────
	local sep = KView:new(V.v(field_w, 1))
	sep.colors.background = C.sep
	sep.pos = V.v(PAD, field_y + DISP_H + 5)
	back:add_child(sep)

	-- ── 数字键盘（4行 × 3列） ───────────────────────────────────
	local num_layout = {{"7", "8", "9"}, {"4", "5", "6"}, {"1", "2", "3"}, {".", "0", "Del"}}

	for ri, row in ipairs(num_layout) do
		local ry = ROWS_Y + (ri - 1) * ROW_DY
		for ci, label in ipairs(row) do
			local rx = PAD + (ci - 1) * (BTN_W3 + GAP)
			local bgn = C.btn
			local bgh = C.btn_h
			if label == "Del" then
				bgn, bgh = C.btn_del, C.btn_del_h
			end
			local btn = NumKeyButton:new(label, BTN_W3, BTN_H, bgn, bgh)
			btn.pos = V.v(rx, ry)
			local cap = label
			function btn.on_click()
				S:queue("GUIButtonCommon")
				this:_on_key(cap)
			end
			back:add_child(btn)

			-- 保存 . 按钮引用，以便按需禁用
			if label == "." then
				self._dot_btn = btn
			end
		end
	end

	-- ── 导航行：±  ←  → ────────────────────────────────────────
	local nav_y = ROWS_Y + 4 * ROW_DY
	local nav_items = {{"±", C.btn, C.btn_h, function()
		this:_toggle_sign()
	end}, {"←", C.btn_nav, C.btn_nav_h, function()
		this:_move_cursor(-1)
	end}, {"→", C.btn_nav, C.btn_nav_h, function()
		this:_move_cursor(1)
	end}}
	for i, ni in ipairs(nav_items) do
		local label, bgn, bgh, action = ni[1], ni[2], ni[3], ni[4]
		local rx = PAD + (i - 1) * (BTN_W3 + GAP)
		local btn = NumKeyButton:new(label, BTN_W3, BTN_H, bgn, bgh)
		btn.pos = V.v(rx, nav_y)
		function btn.on_click()
			S:queue("GUIButtonCommon")
			action()
		end
		back:add_child(btn)
		if label == "±" then
			self._sign_btn = btn
		end
	end

	-- ── 操作行：取消 | 确认 ─────────────────────────────────────
	local act_y = ROWS_Y + 5 * ROW_DY

	local btn_cancel = NumKeyButton:new("取消", BTN_W2, BTN_H, C.btn_no, C.btn_no_h)
	btn_cancel.pos = V.v(PAD, act_y)
	function btn_cancel.on_click()
		S:queue("GUIButtonCommon")
		this:_cancel()
	end
	back:add_child(btn_cancel)

	local btn_ok = NumKeyButton:new("确认", BTN_W2, BTN_H, C.btn_ok, C.btn_ok_h)
	btn_ok.pos = V.v(PAD + BTN_W2 + GAP, act_y)
	function btn_ok.on_click()
		S:queue("GUIButtonCommon")
		this:_confirm()
	end
	back:add_child(btn_ok)
	self._btn_ok = btn_ok

	-- ── 内部状态 ──────────────────────────────────────────────
	self._text = "0"
	self._cursor_pos = 1 -- 光标位置（0=最前，#text=最后）
	self._callback = nil
	self._allow_neg = true
	self._allow_dec = true
	self._max_len = 20

	self._blink_t = 0
	self._cur_vis = true -- 光标是否可见

-- 可选：由外部设置以支持电脑键盘输入
-- self.responder_setter = function(view_or_nil) ... end
end

-- ─────────────────────────────────────────────────────────────
-- 公开 API
-- ─────────────────────────────────────────────────────────────

--- 打开键盘
-- @param initial_value  初始数值（number 或 string）
-- @param callback       回调 function(value)，确认时传 number，取消传 nil
-- @param opts           可选表：allow_negative, allow_decimal, title, max_len
function NumericKeyboardView:open(initial_value, callback, opts)
	opts = opts or {}
	self._callback = callback
	self._allow_neg = opts.allow_negative ~= false
	self._allow_dec = opts.allow_decimal ~= false
	self._max_len = opts.max_len or 20

	-- 设置标题
	if opts.title then
		self._title_lbl.text = opts.title
	else
		self._title_lbl.text = "数字输入"
	end

	-- 更新 ± 按钮状态
	self._sign_btn:set_disabled_visual(not self._allow_neg)

	-- 更新 . 按钮状态（初始时）
	self._dot_btn:set_disabled_visual(not self._allow_dec)

	-- 初始化文本
	local v_str = tostring(initial_value or 0)
	-- 如果不允许负数，去掉负号
	if not self._allow_neg and v_str:sub(1, 1) == "-" then
		v_str = v_str:sub(2)
	end
	-- 如果不允许小数，去掉小数部分
	if not self._allow_dec then
		v_str = tostring(math.floor(tonumber(v_str) or 0))
	end

	self._text = v_str
	self._cursor_pos = #v_str -- 光标初始在末尾
	self._blink_t = 0
	self._cur_vis = true

	self:_refresh_display()

	-- 注册为事件响应者（支持电脑键盘）
	if self.responder_setter then
		self.responder_setter(self)
	end

	self:show()
end

-- ─────────────────────────────────────────────────────────────
-- 键盘事件（供电脑端调用）
-- ─────────────────────────────────────────────────────────────

function NumericKeyboardView:on_textinput(t)
	if t:match("^%d$") then
		self:_insert(t)
	elseif t == "." and self._allow_dec then
		self:_insert(".")
	elseif t == "-" and self._allow_neg then
		self:_toggle_sign()
	end
	return true
end

function NumericKeyboardView:on_keypressed(key, isrepeat)
	if key == "escape" then
		S:queue("GUIButtonCommon")
		self:_cancel()
	elseif key == "return" or key == "kpenter" then
		S:queue("GUIButtonCommon")
		self:_confirm()
	elseif key == "backspace" then
		self:_backspace()
	elseif key == "delete" then
		self:_delete_forward()
	elseif key == "left" then
		self:_move_cursor(-1)
	elseif key == "right" then
		self:_move_cursor(1)
	elseif key == "home" then
		self._cursor_pos = 0
		self:_refresh_display()
	elseif key == "end" then
		self._cursor_pos = #self._text
		self:_refresh_display()
	end
	return true
end

-- ─────────────────────────────────────────────────────────────
-- 内部：输入逻辑
-- ─────────────────────────────────────────────────────────────

function NumericKeyboardView:_on_key(key)
	if key == "Del" then
		self:_backspace()
	elseif key == "." then
		if self._allow_dec then
			self:_insert(".")
		end
	else
		self:_insert(key)
	end
end

function NumericKeyboardView:_insert(ch)
	-- 长度限制
	if #self._text >= self._max_len then
		return
	end

	local t = self._text
	local p = self._cursor_pos

	-- 小数点唯一性
	if ch == "." and t:find("%.") then
		return
	end

	-- 不允许小数时拒绝小数点
	if ch == "." and not self._allow_dec then
		return
	end

	-- 插入字符
	self._text = t:sub(1, p) .. ch .. t:sub(p + 1)
	self._cursor_pos = p + 1

	-- 刷新 . 按钮禁用状态
	if self._dot_btn then
		self._dot_btn:set_disabled_visual(not self._allow_dec or self._text:find("%.") ~= nil)
	end

	self:_refresh_display()
end

function NumericKeyboardView:_backspace()
	local p = self._cursor_pos
	if p > 0 then
		local t = self._text
		self._text = t:sub(1, p - 1) .. t:sub(p + 1)
		self._cursor_pos = p - 1
		self:_dot_after_edit()
		self:_refresh_display()
	end
end

function NumericKeyboardView:_delete_forward()
	local p = self._cursor_pos
	local t = self._text
	if p < #t then
		self._text = t:sub(1, p) .. t:sub(p + 2)
		self:_dot_after_edit()
		self:_refresh_display()
	end
end

function NumericKeyboardView:_dot_after_edit()
	-- 删除操作后重新评估 . 按钮是否可用
	if self._dot_btn then
		self._dot_btn:set_disabled_visual(not self._allow_dec or self._text:find("%.") ~= nil)
	end
end

function NumericKeyboardView:_move_cursor(dir)
	self._cursor_pos = math.max(0, math.min(#self._text, self._cursor_pos + dir))
	self._blink_t = 0
	self._cur_vis = true
	self:_refresh_display()
end

function NumericKeyboardView:_toggle_sign()
	if not self._allow_neg then
		return
	end

	if self._text:sub(1, 1) == "-" then
		self._text = self._text:sub(2)
		self._cursor_pos = math.max(0, self._cursor_pos - 1)
	else
		self._text = "-" .. self._text
		self._cursor_pos = self._cursor_pos + 1
	end
	self:_refresh_display()
end

-- ─────────────────────────────────────────────────────────────
-- 内部：显示刷新
-- ─────────────────────────────────────────────────────────────

function NumericKeyboardView:_refresh_display()
	local t = self._text
	local p = self._cursor_pos

	-- 仅渲染纯文本，光标由独立 view 渲染
	self._disp_lbl.text = t ~= "" and t or "0"

	-- 计算光标位置（右对齐文本坐标系）
	if self._cursor_bar then
		local full_w = self._disp_lbl:get_text_width(t)
		local left_w = self._disp_lbl:get_text_width(t:sub(1, p))
		local text_left_x = self._disp_text_right_x - full_w
		local cx = text_left_x + left_w

		-- 限制在显示框内
		local min_x = self._disp_lbl.pos.x
		local max_x = self._disp_text_right_x
		cx = math.max(min_x, math.min(max_x, cx))

		self._cursor_bar.pos.x = math.floor(cx + 0.5)
		self._cursor_bar.hidden = not self._cur_vis
	end

	-- 根据有效性调整显示颜色
	local is_valid = (tonumber(t) ~= nil) or (t == "") or (t == "-")
	if is_valid then
		self._disp_lbl.colors.text = C.text
		self._disp_bg.colors.background = C.disp_bg
	else
		self._disp_lbl.colors.text = C.text_err
		self._disp_bg.colors.background = C.disp_err
	end

	-- 确认按钮可用性
	if self._btn_ok then
		self._btn_ok:set_disabled_visual(tonumber(t) == nil)
	end
end

-- ─────────────────────────────────────────────────────────────
-- 内部：确认 / 取消
-- ─────────────────────────────────────────────────────────────

function NumericKeyboardView:_confirm()
	local num = tonumber(self._text)
	if num == nil then -- 非法输入时不响应
		return
	end

	self:_release_responder()
	self:hide()

	if self._callback then
		local cb = self._callback
		self._callback = nil
		cb(num)
	end
end

function NumericKeyboardView:_cancel()
	self:_release_responder()
	self:hide()

	if self._callback then
		local cb = self._callback
		self._callback = nil
		cb(nil)
	end
end

function NumericKeyboardView:_release_responder()
	if self.responder_setter then
		self.responder_setter(nil)
	end
end

-- ─────────────────────────────────────────────────────────────
-- update：光标闪烁
-- ─────────────────────────────────────────────────────────────

function NumericKeyboardView:update(dt)
	NumericKeyboardView.super.update(self, dt)

	if not self.hidden then
		self._blink_t = self._blink_t + dt
		local new_vis = math.floor(self._blink_t * 1.6) % 2 == 0
		if new_vis ~= self._cur_vis then
			self._cur_vis = new_vis
			self:_refresh_display()
		end
	end
end
