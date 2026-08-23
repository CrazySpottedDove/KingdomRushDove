-- 插件管理器的 UI 组件（PluginActionButton / PluginToggleButton / PluginItemRow）
local class = require("middleclass")
local V = require("lib.klua.vector")
local S = require("sound_db")
local storage = require("all.storage")
local editable_panel_view = require("dove_modules.gui.editable_panel_view")
local km = require("lib.klua.macros")
local utf8_util = require("lib.utf8_utils")
local utf8 = require("utf8")

require("gg_views_custom")

local ROW_H = 156
local ROW_PAD = 16
local ACCENT_W = 6

--- 深比较两个值（插件配置为无环的 storage 数据，无需防环）
local function deep_equal(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in pairs(a) do
		if not deep_equal(v, b[k]) then
			return false
		end
	end
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- ─────────────────────────────────────────────
-- PluginActionButton
-- ─────────────────────────────────────────────
PluginActionButton = class("PluginActionButton", KButtonNoText)

function PluginActionButton:initialize(text, size)
	local rs = GGLabel.static.ref_h / REF_H
	local w = size and size.x or 110
	local h = size and size.y or 34
	KButtonNoText.initialize(self, V.v(w, h))
	self.text = ""
	self._text = utf8_util.sanitize(text or "")
	self.enabled = true
	self._hover = false
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, w, h, 8, 8}
	}
	self._label = GGLabel:new(self.size)
	self._label.font_name = "body"
	self._label.font_size = 13 * rs
	self._label.text_align = "center"
	self._label.vertical_align = "middle"
	self._label.fit_lines = 1
	self._label.fit_size = true
	self._label.propagate_on_click = true
	self:add_child(self._label)
	self:_refresh()
end

function PluginActionButton:set_text(text)
	self._text = utf8_util.sanitize(text)
	self:_refresh()
end

function PluginActionButton:set_enabled(v)
	self.enabled = v ~= false
	self:_refresh()
end

function PluginActionButton:_refresh()
	if not self.enabled then
		self.colors.background = {88, 78, 64, 180}
		self._label.colors.text = {160, 150, 130, 220}
	elseif self._hover then
		self.colors.background = {161, 122, 45, 245}
		self._label.colors.text = {255, 240, 190, 255}
	else
		self.colors.background = {134, 101, 36, 220}
		self._label.colors.text = {236, 220, 175, 255}
	end
	self._label.text = self._text
end

function PluginActionButton:on_enter()
	self._hover = true
	self:_refresh()
end

function PluginActionButton:on_exit()
	self._hover = false
	self:_refresh()
end

function PluginActionButton:on_click()
	if not self.enabled then
		return
	end
	S:queue("GUIButtonCommon")
	if self.on_press then
		self:on_press()
	end
end

-- ─────────────────────────────────────────────
-- PluginToggleButton
-- ─────────────────────────────────────────────
PluginToggleButton = class("PluginToggleButton", KButtonNoText)

function PluginToggleButton:initialize(initial_value, size)
	local rs = GGLabel.static.ref_h / REF_H
	local w = size and size.x or 84
	local h = size and size.y or 36
	KButtonNoText.initialize(self, V.v(w, h))
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, w, h, 9, 9}
	}
	self.value = initial_value ~= false
	self._hover = false
	self._label = GGLabel:new(self.size)
	self._label.font_name = "body"
	self._label.font_size = 16 * rs
	self._label.text_align = "center"
	self._label.vertical_align = "middle"
	self._label.propagate_on_click = true
	self._enable_text = "已启用"
	self._disable_text = "已禁用"
	self:add_child(self._label)
	self:_refresh()
end

function PluginToggleButton:set_value(v)
	self.value = v
	self:_refresh()
	if self.on_change then
		self:on_change(v)
	end
end

function PluginToggleButton:_refresh()
	if self.value then
		self.colors.background = self._hover and {58, 183, 90, 245} or {35, 148, 68, 215}
		self._label.colors.text = {195, 255, 178, 255}
		self._label.text = self._enable_text
	else
		self.colors.background = self._hover and {178, 55, 55, 245} or {148, 38, 38, 215}
		self._label.colors.text = {255, 178, 155, 255}
		self._label.text = self._disable_text
	end
end

function PluginToggleButton:on_enter()
	self._hover = true
	self:_refresh()
end

function PluginToggleButton:on_exit()
	self._hover = false
	self:_refresh()
end

function PluginToggleButton:on_click()
	S:queue("GUIButtonCommon")
	self:set_value(not self.value)
end

-- ─────────────────────────────────────────────
-- PluginItemRow
-- ─────────────────────────────────────────────
PluginItemRow = class("PluginItemRow", KView)

function PluginItemRow:initialize(opts, row_w)
	row_w = row_w or 760
	KView.initialize(self, V.v(row_w, ROW_H))
	self.opts = opts or {}
	self._base_bg = {24, 18, 12, 210}
	self._hover_bg = {40, 30, 18, 230}
	self.colors.background = {self._base_bg[1], self._base_bg[2], self._base_bg[3], self._base_bg[4]}
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.propagate_on_touch_down = true
	self.propagate_on_touch_up = true
	self.propagate_on_touch_move = true
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, row_w, ROW_H, 14, 14}
	}

	local rs = GGLabel.static.ref_h / REF_H
	local action_size = self.opts.action_button_size
	local action_w = action_size and action_size.x or 122
	local action_h = action_size and action_size.y or 34
	local action_gap = self.opts.action_button_gap or 10
	local toggle_size = self.opts.toggle_size
	local toggle_w = toggle_size and toggle_size.x or 84
	local toggle_h = toggle_size and toggle_size.y or 36
	local right_pad = self.opts.right_pad or (IS_ANDROID and 30 or 24)
	local actions = self.opts.actions or {}
	local action_btn_count = #actions
	local needed_action_w = action_w * math.max(1, action_btn_count) + action_gap * math.max(0, action_btn_count - 1)
	local action_col_w = math.max(toggle_w, needed_action_w)
	local status_col_w = self.opts.status_width or action_col_w
	if status_col_w < 180 then
		status_col_w = 180
	end
	local action_col_left = row_w - right_pad - status_col_w
	local status_w = status_col_w
	local status_x = row_w - right_pad - status_w
	local text_w = math.max(220, action_col_left - (ACCENT_W + ROW_PAD) - 12)

	local accent = KView:new(V.v(ACCENT_W, ROW_H - 1))
	accent.pos = V.v(0, 0)
	self:add_child(accent)
	self._accent = accent

	local name_lbl = GGLabel:new(V.v(text_w, 26))
	name_lbl.font_name = "h"
	name_lbl.font_size = 16 * rs
	name_lbl.text_align = "left"
	name_lbl.vertical_align = "middle"
	name_lbl.colors.text = {238, 218, 162, 255}
	name_lbl.text = utf8_util.sanitize(self.opts.title or "?")
	name_lbl.fit_lines = 1
	name_lbl.fit_size = true
	name_lbl.pos = V.v(ACCENT_W + ROW_PAD, 10)
	self:add_child(name_lbl)

	local meta_lbl = GGLabel:new(V.v(text_w, 22))
	meta_lbl.font_name = "body"
	meta_lbl.font_size = 13 * rs
	meta_lbl.text_align = "left"
	meta_lbl.vertical_align = "middle"
	meta_lbl.colors.text = {175, 162, 122, 255}
	meta_lbl.text = utf8_util.sanitize(self.opts.meta or "")
	meta_lbl.fit_lines = 1
	meta_lbl.fit_size = true
	meta_lbl.pos = V.v(ACCENT_W + ROW_PAD, 38)
	self:add_child(meta_lbl)

	local desc_lbl = GGLabel:new(V.v(text_w, 62))
	desc_lbl.font_name = "body"
	desc_lbl.font_size = 12 * rs
	desc_lbl.text_align = "left"
	desc_lbl.vertical_align = "top"
	desc_lbl.colors.text = {148, 140, 116, 255}
	desc_lbl.text = utf8_util.safe_label_desc(self.opts.desc or "")
	desc_lbl.fit_lines = 3
	desc_lbl.line_height = 1.25
	desc_lbl.fit_size = true
	desc_lbl.pos = V.v(ACCENT_W + ROW_PAD, 62)
	self:add_child(desc_lbl)

	local status_y = 8
	local status_h = 22
	local status_lbl = GGLabel:new(V.v(status_w, status_h))
	status_lbl.font_name = "body"
	status_lbl.font_size = 12 * rs
	status_lbl.text_align = "right"
	status_lbl.vertical_align = "middle"
	status_lbl.colors.text = {242, 211, 121, 255}
	status_lbl.text = utf8_util.sanitize(self.opts.status or "")
	status_lbl.pos = V.v(status_x, status_y)
	self:add_child(status_lbl)

	local action_bottom_margin = self.opts.action_bottom_margin or 16
	local action_top_min_y = 104
	local toggle_bottom = 0
	local action_right = row_w - right_pad
	if self.opts.show_toggle then
		local toggle = PluginToggleButton:new(self.opts.enabled ~= false, V.v(toggle_w, km.clamp(toggle_h, 36, 44)))
		local toggle_top_margin = self.opts.toggle_top_margin or 16
		local toggle_top = math.max(toggle_top_margin, status_y + status_h + 14)
		toggle_bottom = toggle_top + toggle.size.y
		toggle.pos = V.v(row_w - right_pad - toggle_w / 2, toggle_top + toggle.size.y / 2)
		toggle.anchor = V.v(toggle.size.x / 2, toggle.size.y / 2)
		toggle.on_change = function(_, v)
			if self.opts.on_toggle then
				self.opts.on_toggle(v)
			end
			self:_refresh_accent(v)
		end
		self:add_child(toggle)
		self.toggle = toggle
		if self.opts.plugin_data.has_config then
			local config_button = PluginToggleButton:new(true, V.v(toggle_w, km.clamp(toggle_h, 36, 44)))
			config_button.pos = V.v(row_w - 2 * right_pad - toggle_w * 3 / 2, toggle_top + toggle.size.y / 2)
			config_button.anchor = V.v(toggle.size.x / 2, toggle.size.y / 2)
			config_button._label.text = "配置"
			config_button._enable_text = "配置"
			function config_button:on_click()
				S:queue("GUIButtonCommon")
				local config_path = opts.plugin_data.path .. "/" .. opts.plugin_data.name .. "_config.lua"
				local manager = opts.manager
				-- 读取当前配置：优先管理器中的待应用修改（延迟写盘期间编辑面板显示最新值），其次磁盘
				local function read_current_config()
					if manager then
						local pending = manager:_get_pending_config(opts.plugin_data.name)
						if pending then
							return pending
						end
					end
					return storage:load_lua(config_path, true)
				end
				local config_view = editable_panel_view:new(opts._sw, opts._sh, opts.title, opts._keyboard, opts._controller)
				config_view._config_path = config_path
				function config_view:load()
					self.data_group:set_all_data(read_current_config())
				end
				function config_view:save()
					-- 合并编辑值到当前配置（优先待应用配置，其次磁盘）
					local config = read_current_config() or {}
					for k, v in pairs(self.data_group:get_all_data()) do
						config[k] = v
					end
					if manager then
						-- 延迟写盘：仅记忆修改，点插件管理器「应用」时才落盘并触发 on_config_change。
						-- 与磁盘原配置深比较：什么都没改（或改回原值）时不产生待应用修改，
						-- 避免关闭管理器时误报「有未保存的修改」。
						local disk_config = storage:load_lua(config_path, true)
						if deep_equal(config, disk_config) then
							manager:_clear_pending_config(opts.plugin_data.name)
						else
							manager:_set_pending_config(opts.plugin_data.name, config)
						end
					else
						-- 无管理器上下文（理论上不会发生）：保持原行为直接写盘
						storage:write_lua(config_path, config)
					end
				end
				local config = read_current_config()
				config_view:set_key_label_map(config.key_label_map or {})
				if type(config.key_order_list) == "table" then
					config_view:set_key_order_list(config.key_order_list)
				end
				if type(config.__default_config) == "table" then
					config_view:set_default_data(config.__default_config)
				end
				opts._controller:add_child(config_view)
				config_view:show()
			end
			self:add_child(config_button)
		end
	else
		self:_refresh_accent(true)
	end
	action_top_min_y = math.max(action_top_min_y, toggle_bottom + 4)
	local action_h_min = 28
	local action_h_max = math.max(action_h_min, ROW_H - action_top_min_y - action_bottom_margin)
	action_h = km.clamp(action_h, action_h_min, action_h_max)
	local action_y = ROW_H - action_h - action_bottom_margin

	local total_w = action_btn_count * action_w + math.max(0, action_btn_count - 1) * action_gap
	local x = action_right - total_w

	self._action_buttons = {}
	for _, action in ipairs(actions) do
		local btn = PluginActionButton:new(action.text, V.v(action_w, action_h))
		btn.pos = V.v(x, action_y)
		if action.enabled == false then
			btn:set_enabled(false)
		end
		btn.on_press = function()
			if action.on_press then
				action.on_press()
			end
		end
		self:add_child(btn)
		self._action_buttons[#self._action_buttons + 1] = btn
		x = x + action_w + action_gap
	end

	local sep = KView:new(V.v(row_w, 1))
	sep.colors.background = {65, 50, 30, 200}
	sep.pos = V.v(0, ROW_H - 1)
	self:add_child(sep)

	if self.toggle then
		self:_refresh_accent(self.toggle.value)
	end
end

function PluginItemRow:_refresh_accent(enabled)
	if enabled then
		self._accent.colors.background = {55, 185, 80, 235}
	else
		self._accent.colors.background = {185, 50, 45, 210}
	end
end

function PluginItemRow:set_dimmed(dimmed)
	if dimmed then
		self._accent.colors.background = {80, 72, 58, 200}
		self.colors.background = {18, 14, 10, 180}
		self.colors.foreground = {80, 72, 58, 180}
	else
		self.colors.background = {self._base_bg[1], self._base_bg[2], self._base_bg[3], self._base_bg[4]}
		if self.toggle then
			self:_refresh_accent(self.toggle.value)
		end
	end
	self._hover_bg = dimmed and {18, 14, 10, 200} or {40, 30, 18, 230}
end

function PluginItemRow:on_enter()
	self.colors.background = {self._hover_bg[1], self._hover_bg[2], self._hover_bg[3], self._hover_bg[4]}
end

function PluginItemRow:on_exit()
	self.colors.background = {self._base_bg[1], self._base_bg[2], self._base_bg[3], self._base_bg[4]}
end

-- ─────────────────────────────────────────────
-- PluginSearchBox：商店搜索框（单行文本输入）
-- 走系统 IME（is_virtual_keyboard = false → setTextInput(true)），
-- 桌面端支持中文输入法选字，手机端弹出系统软键盘。
-- ─────────────────────────────────────────────
PluginSearchBox = class("PluginSearchBox", KView)

function PluginSearchBox:initialize(opts)
	local rs = GGLabel.static.ref_h / REF_H
	local w = opts.width or 320
	local h = opts.height or 32
	KView.initialize(self, V.v(w, h))
	self.colors.background = {30, 22, 12, 230}
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, w, h, 6, 6}
	}
	self._controller = opts.controller
	self._placeholder = opts.placeholder or "搜索插件"
	self._text = ""
	self._focused = false
	self._cursor_visible = true
	self._cursor_timer = 0
	self.on_change = opts.on_change
	self.on_submit = opts.on_submit

	self._label = GGLabel:new(V.v(w - 28, h))
	self._label.font_name = "body"
	self._label.font_size = 13 * rs
	self._label.text_align = "left"
	self._label.vertical_align = "middle"
	self._label.fit_lines = 1
	self._label.colors.text = {240, 228, 200, 255}
	self._label.pos = V.v(10, 0)
	self:add_child(self._label)
	self:_refresh()
end

function PluginSearchBox:get_text()
	return self._text
end

function PluginSearchBox:set_text(text)
	self._text = text or ""
	self:_refresh()
	if self.on_change then
		self.on_change(self._text)
	end
end

function PluginSearchBox:_refresh()
	if self._text ~= "" then
		self._label.colors.text = {240, 228, 200, 255}
		self._label.text = utf8_util.sub(self._text, 24)
	elseif self._focused then
		self._label.colors.text = {180, 168, 138, 255}
		self._label.text = "输入后搜索"
	else
		self._label.colors.text = {150, 138, 112, 255}
		self._label.text = self._placeholder
	end
end

function PluginSearchBox:set_focused(focused)
	self._focused = focused
	self:_refresh()
	if focused then
		self.colors.background = {44, 34, 18, 245}
		if self._controller and self._controller.set_responder then
			self._controller:set_responder(self)
		end
	else
		self.colors.background = {30, 22, 12, 230}
		-- 归还 IME 焦点（关闭系统输入法，避免拦截游戏快捷键）
		if self._controller and self._controller.set_responder then
			self._controller:set_responder()
		end
	end
end

function PluginSearchBox:on_click()
	S:queue("GUIButtonCommon")
	self:set_focused(true)
end

function PluginSearchBox:on_textinput(t)
	self._text = utf8_util.sub(self._text .. t, 60)
	self:_refresh()
	if self.on_change then
		self.on_change(self._text)
	end
	return true
end

function PluginSearchBox:on_keypressed(key)
	if key == "backspace" then
		local text = self._text
		local byteoffset = utf8.offset(text, -1)

		if byteoffset then
			if byteoffset > 1 then
				self._text = string.sub(text, 1, byteoffset - 1)
			else
				self._text = ""
			end
		end
		self:_refresh()
		if self.on_change then
			self.on_change(self._text)
		end
		return true
	elseif key == "return" or key == "kpenter" then
		S:queue("GUIButtonCommon")
		if self.on_submit then
			self.on_submit(self._text)
		end
		self:set_focused(false)
		return true
	elseif key == "escape" then
		if self._text ~= "" then
			self:set_text("")
		end
		self:set_focused(false)
		return true
	end
	return false
end

function PluginSearchBox:update(dt)
	PluginSearchBox.super.update(self, dt)
	if self._focused then
		self._cursor_timer = self._cursor_timer + dt

		if self._cursor_timer >= 0.5 then
			self._cursor_timer = 0
			self._cursor_visible = not self._cursor_visible
			local text = self._text ~= "" and self._text or ""
			self._label.text = utf8_util.sub(text, 24) .. (self._cursor_visible and "|" or "")
		end
	end
end
