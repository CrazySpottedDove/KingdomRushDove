local class = require("middleclass")
local V = require("lib.klua.vector")
local S = require("sound_db")
local i18n = require("i18n")

require("klove.kui")
require("gg_views_custom")

local changelog_data = require("dove_modules.data.changelog_data")

local PANEL_MARGIN = 150
local PANEL_MIN_W = 700
local PANEL_MAX_W = 10000
local PANEL_MIN_H = 500
local PANEL_MAX_H = 10000
local ROW_PAD = 16
local ENTRY_H = 24
local BTN_W = 80
local BTN_H = 26

local function safe_tostring(s)
	if s == nil then
		return ""
	end
	return tostring(s)
end

ChangelogView = class("ChangelogView", PopUpView)

function ChangelogView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	local rs = GGLabel.static.ref_h / REF_H
	local panel_w = math.min(PANEL_MAX_W, sw - PANEL_MARGIN)
	panel_w = math.max(PANEL_MIN_W, panel_w)
	panel_w = math.min(panel_w, sw - 12)
	local panel_h = math.min(PANEL_MAX_H, sh - PANEL_MARGIN)
	panel_h = math.max(PANEL_MIN_H, panel_h)
	panel_h = math.min(panel_h, sh - 12)

	self.back = KView:new(V.v(panel_w, panel_h))
	self.back.colors.background = {47, 34, 6, 226}
	self.back.anchor = V.v(panel_w / 2, panel_h / 2)
	self.back.pos = V.v(sw / 2, sh / 2)
	self.back.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, panel_w, panel_h, 20, 20}
	}
	self:add_child(self.back)

	self._panel_w = panel_w
	self._panel_h = panel_h
	self._ver_idx = 1

	local header = GGPanelHeader:new("更新日志", panel_w - 40)
	header.pos = V.v(20, 14)
	self.back:add_child(header)

	local close_btn = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	close_btn.pos = V.v(panel_w - 23, 23)
	close_btn.scale:set(1.5, 1.5)
	close_btn:set_anchor_to_center()
	self.back:add_child(close_btn)
	close_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	if #changelog_data == 0 then
		local empty_lbl = GGLabel:new(V.v(panel_w - 40, 60))
		empty_lbl.font_size = 14 * rs
		empty_lbl.text_align = "center"
		empty_lbl.vertical_align = "middle"
		empty_lbl.colors.text = {160, 150, 120, 255}
		empty_lbl.text = "暂无更新日志记录"
		empty_lbl.pos = V.v(20, 120)
		self.back:add_child(empty_lbl)
		return
	end

	self:_build_ui(rs, panel_w, panel_h)
	self:_render_version()
end

function ChangelogView:_build_ui(rs, panel_w, panel_h)
	local nav_y = 58
	local lbl_w = 200

	local prev_btn = ModActionButton:new("上版本", V.v(BTN_W, BTN_H))
	prev_btn.pos = V.v(20, nav_y)
	self.back:add_child(prev_btn)
	prev_btn.on_press = function()
		S:queue("GUIButtonCommon")
		if self._ver_idx < #changelog_data then
			self._ver_idx = self._ver_idx + 1
			self:_render_version()
		end
	end
	self._prev_btn = prev_btn

	local ver_lbl = GGLabel:new(V.v(lbl_w, BTN_H))
	ver_lbl.font_name = "h"
	ver_lbl.font_size = 14 * rs
	ver_lbl.text_align = "center"
	ver_lbl.vertical_align = "middle"
	ver_lbl.colors.text = {255, 215, 100, 255}
	ver_lbl.fit_lines = 1
	ver_lbl.fit_size = true
	ver_lbl.pos = V.v((panel_w - lbl_w) / 2, nav_y)
	self.back:add_child(ver_lbl)
	self._ver_lbl = ver_lbl

	local pick_btn = ModActionButton:new("选择", V.v(54, BTN_H))
	pick_btn.pos = V.v((panel_w - lbl_w) / 2 + lbl_w + 4, nav_y)
	self.back:add_child(pick_btn)
	pick_btn.on_press = function()
		S:queue("GUIButtonCommon")
		self:_show_version_picker()
	end

	local next_btn = ModActionButton:new("下版本", V.v(BTN_W, BTN_H))
	next_btn.pos = V.v(panel_w - 20 - BTN_W, nav_y)
	self.back:add_child(next_btn)
	next_btn.on_press = function()
		S:queue("GUIButtonCommon")
		if self._ver_idx > 1 then
			self._ver_idx = self._ver_idx - 1
			self:_render_version()
		end
	end
	self._next_btn = next_btn

	local list_top_y = 94
	local scroll_h = math.max(200, panel_h - list_top_y - 10)

	self.scroll_list = KScrollList:new(V.v(panel_w - 40, scroll_h))
	self.scroll_list.pos = V.v(20, list_top_y)
	self.scroll_list.drag_scroll_threshold = IS_ANDROID and 20 or 6
	self.scroll_list.scroll_amount = 60
	self.scroll_list.colors.scroller_background = {45, 36, 22, 200}
	self.scroll_list.colors.scroller_foreground = {110, 90, 50, 255}
	self.scroll_list.scroller_width = 12
	self.back:add_child(self.scroll_list)
end

function ChangelogView:_render_version()
	local rs = GGLabel.static.ref_h / REF_H
	local panel_w = self._panel_w
	local ver = changelog_data[self._ver_idx]
	if not ver then
		return
	end

	if self._ver_idx == 1 then
		self._ver_lbl.text = "v" .. safe_tostring(ver.id)
	else
		local newer_id = changelog_data[self._ver_idx - 1].id
		self._ver_lbl.text = "v" .. safe_tostring(ver.id) .. " → v" .. safe_tostring(newer_id)
	end

	self._prev_btn:set_enabled(self._ver_idx < #changelog_data)
	self._next_btn:set_enabled(self._ver_idx > 1)

	self.scroll_list:clear_rows()

	local total = #(ver.entries or {})

	-- local info = GGLabel:new(V.v(panel_w - 40, 22))
	-- info.font_name = "body"
	-- info.font_size = 11 * rs
	-- info.text_align = "right"
	-- info.vertical_align = "middle"
	-- info.colors.text = {160, 150, 120, 255}
	-- info.fit_lines = 1
	-- info.text = "共" .. total .. "条"
	-- self.scroll_list:add_row(info)

	local head_sep = KView:new(V.v(panel_w - 40, 1))
	head_sep.colors.background = {80, 65, 35, 200}
	self.scroll_list:add_row(head_sep)

	for i = 1, total do
		local entry = ver.entries[i]
		if entry then
			local row = KView:new(V.v(panel_w - 40, ENTRY_H))
			row.propagate_on_down = true
			row.propagate_on_up = true
			row.propagate_on_touch_down = true
			row.propagate_on_touch_up = true
			row.propagate_on_touch_move = true

			local date_lbl = GGLabel:new(V.v(90, ENTRY_H))
			date_lbl.font_name = "body"
			date_lbl.font_size = 11 * rs
			date_lbl.text_align = "left"
			date_lbl.vertical_align = "middle"
			date_lbl.colors.text = {160, 150, 120, 255}
			date_lbl.text = safe_tostring(entry.date or "")
			date_lbl.fit_lines = 1
			date_lbl.pos = V.v(ROW_PAD, 0)
			row:add_child(date_lbl)

			local author_w = 100
			local scroll_pad = 30
			local msg_w = panel_w - 40 - ROW_PAD * 2 - 96 - author_w - scroll_pad

			local msg_lbl = GGLabel:new(V.v(msg_w, ENTRY_H))
			msg_lbl.font_name = "body"
			msg_lbl.font_size = 12 * rs
			msg_lbl.text_align = "left"
			msg_lbl.vertical_align = "middle"
			msg_lbl.colors.text = {200, 195, 180, 255}
			msg_lbl.text = safe_tostring(entry.message or "")
			msg_lbl.fit_lines = 1
			msg_lbl.pos = V.v(ROW_PAD + 96, 0)
			row:add_child(msg_lbl)

			local author_lbl = GGLabel:new(V.v(author_w, ENTRY_H))
			author_lbl.font_name = "body"
			author_lbl.font_size = 11 * rs
			author_lbl.text_align = "right"
			author_lbl.vertical_align = "middle"
			author_lbl.colors.text = {180, 175, 155, 255}
			author_lbl.text = safe_tostring(entry.author or "")
			author_lbl.fit_lines = 1
			author_lbl.pos = V.v(panel_w - 40 - scroll_pad - author_w, 0)
			row:add_child(author_lbl)

			self.scroll_list:add_row(row)
		end
	end
end

function ChangelogView:_show_version_picker()
	local rs = GGLabel.static.ref_h / REF_H
	local panel_w = self._panel_w
	local panel_h = self._panel_h

	local picker = KView:new(V.v(panel_w - 80, panel_h - 120))
	picker.colors.background = {35, 25, 8, 240}
	picker.anchor = V.v((panel_w - 80) / 2, (panel_h - 120) / 2)
	picker.pos = V.v(panel_w / 2, panel_h / 2 + 10)
	picker.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, picker.size.x, picker.size.y, 12, 12}
	}
	self.back:add_child(picker)

	local title = GGLabel:new(V.v(picker.size.x - 24, 28))
	title.font_name = "h"
	title.font_size = 14 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = {244, 221, 165, 255}
	title.text = "选择版本"
	title.pos = V.v(12, 8)
	picker:add_child(title)

	local list = KScrollList:new(V.v(picker.size.x - 24, picker.size.y - 56))
	list.pos = V.v(12, 38)
	list.drag_scroll_threshold = IS_ANDROID and 20 or 6
	list.scroll_amount = 120
	list.colors.scroller_background = {45, 36, 22, 200}
	list.colors.scroller_foreground = {110, 90, 50, 255}
	list.scroller_width = 10
	picker:add_child(list)

	local row_h = 28
	for idx, ver in ipairs(changelog_data) do
		local row = KView:new(V.v(list.size.x, row_h))
		row._base_bg = idx == self._ver_idx and {80, 60, 25, 200} or nil
		row._hover_bg = idx == self._ver_idx and {100, 75, 35, 220} or {55, 42, 15, 230}
		if row._base_bg then
			row.colors.background = {row._base_bg[1], row._base_bg[2], row._base_bg[3], row._base_bg[4]}
		end
		row.propagate_on_down = true
		row.propagate_on_up = true
		row.propagate_on_touch_down = true
		row.propagate_on_touch_up = true
		row.propagate_on_touch_move = true
		row.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, list.size.x, row_h, 6, 6}
		}

		local lbl = GGLabel:new(V.v(list.size.x - 12, row_h))
		lbl.font_name = "body"
		lbl.font_size = 12 * rs
		lbl.text_align = "left"
		lbl.vertical_align = "middle"
		lbl.colors.text = idx == self._ver_idx and {255, 215, 100, 255} or {200, 190, 160, 255}
		if idx == 1 then
			lbl.text = string.format("v%-12s  (%d条)", safe_tostring(ver.id), #(ver.entries or {}))
		else
			local newer_id = changelog_data[idx - 1].id
			lbl.text = string.format("v%s → v%s  (%d条)", safe_tostring(ver.id), safe_tostring(newer_id), #(ver.entries or {}))
		end
		lbl.fit_lines = 1
		lbl.pos = V.v(6, 0)
		row:add_child(lbl)

		function row:on_enter()
			if not self._base_bg then
				self.colors.background = {self._hover_bg[1], self._hover_bg[2], self._hover_bg[3], self._hover_bg[4]}
			end
		end
		function row:on_exit()
			if self._base_bg then
				self.colors.background = {self._base_bg[1], self._base_bg[2], self._base_bg[3], self._base_bg[4]}
			else
				self.colors.background = nil
			end
		end
		row.on_click = function()
			S:queue("GUIButtonCommon")
			self._ver_idx = idx
			if picker.parent then
				picker.parent:remove_child(picker)
			end
			self:_render_version()
		end
		list:add_row(row)
	end

	local pclose = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	pclose.pos = V.v(picker.size.x - 16, 16)
	pclose.scale:set(1.0, 1.0)
	pclose:set_anchor_to_center()
	picker:add_child(pclose)
	pclose.on_click = function()
		S:queue("GUIButtonCommon")
		if picker.parent then
			picker.parent:remove_child(picker)
		end
	end

	picker:order_to_front()
end
