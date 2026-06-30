-- chunkname: @./all-desktop/mod_manager_view.lua
-- 模组管理器 + 插件商店（游戏内）
local log = require("lib.klua.log"):new("mod_manager_view")
local class = require("middleclass")
local V = require("lib.klua.vector")
local FS = love.filesystem
local S = require("sound_db")
local restart = require("all.restart")
local storage = require("all.storage")
local json = require("lib.json")
local persistence = require("lib.klua.persistence")
local mod_paths = require("mod_paths")
local editable_panel_view = require("dove_modules.gui.editable_panel_view")
local markdown_view = require("dove_modules.gui.markdown_view")
local zip = require("lib.zip")

local km = require("lib.klua.macros")
local utf8_util = require("lib.utf8_utils")
require("lib.klua.string")
require("gg_views_custom")
local PANEL_MIN_W = 900
local PANEL_MAX_W = 10000
-- local PANEL_MAX_W = 1020
local PANEL_MIN_H = 730
-- local PANEL_MAX_H = 800
local PANEL_MAX_H = 10000
-- local PANEL_MARGIN = 36
local PANEL_MARGIN = 150
local ROW_H = 156
local LIST_TOP_Y = 208
local STORE_PAGE_SIZE = 20

local STORE_BACKUP_SITES = {"https://krdovedownload6.crazyspotteddove.top:52000/", "https://krdovedownload4.crazyspotteddove.top/"}

local CATEGORY_OPTIONS = {{
	label = "全部",
	value = "all"
}, {
	label = "玩法",
	value = "gameplay"
}, {
	label = "防御塔",
	value = "tower"
}, {
	label = "英雄",
	value = "hero"
}, {
	label = "显示",
	value = "display"
}, {
	label = "美化",
	value = "cosmetic"
}, {
	label = "敌人",
	value = "enemy"
}, {
	label = "其它",
	value = "other"
}}

local SORT_OPTIONS = {{
	label = "最热门",
	value = "hot"
}, {
	label = "下载最多",
	value = "downloads"
}, {
	label = "最新",
	value = "newest"
}}

local HTTP_WORKER = [[
local https = require("https")
local req_ch = love.thread.getChannel("mod_store_http_req")
local resp_ch = love.thread.getChannel("mod_store_http_resp")
while true do
	local req = req_ch:demand()
	if req == "quit" then
		break
	end
	local ok, code, body, headers = pcall(https.request, req.url, req.options)
	if ok then
		resp_ch:push({
			id = req.id,
			code = code,
			body = body,
			headers = headers or {}
		})
	else
		resp_ch:push({
			id = req.id,
			code = 0,
			body = tostring(code),
			headers = {}
		})
	end
end
]]

local function norm_version(v)
	return string.trim(utf8_util.sanitize(v))
end

local function has_update(local_version, remote_version)
	return norm_version(local_version) ~= "" and norm_version(remote_version) ~= "" and norm_version(local_version) ~= norm_version(remote_version)
end

local function remove_dir_recursive(path)
	local info = FS.getInfo(path)
	if not info then
		return true
	end
	if info.type == "file" then
		return FS.remove(path)
	end
	local items = FS.getDirectoryItems(path) or {}
	for _, name in ipairs(items) do
		remove_dir_recursive(path .. "/" .. name)
	end
	return FS.remove(path)
end

local function copy_dir_recursive(src_dir, dst_dir)
	if not FS.getInfo(dst_dir, "directory") then
		FS.createDirectory(dst_dir)
	end
	local items = FS.getDirectoryItems(src_dir) or {}
	for _, name in ipairs(items) do
		local src_path = src_dir .. "/" .. name
		local dst_path = dst_dir .. "/" .. name
		local info = FS.getInfo(src_path)
		if info then
			if info.type == "directory" then
				copy_dir_recursive(src_path, dst_path)
			else
				FS.write(dst_path, FS.read(src_path) or "")
			end
		end
	end
	return true
end

local function basename(path)
	return (path:match("([^/]+)$") or path)
end

local function merge_missing_or_mismatch_fields(local_cfg, remote_cfg)
	if type(local_cfg) ~= "table" or type(remote_cfg) ~= "table" then
		return
	end
	for k, remote_v in pairs(remote_cfg) do
		local local_v = local_cfg[k]
		if local_v == nil or type(local_v) ~= type(remote_v) then
			local_cfg[k] = table.deepclone(remote_v)
		elseif type(remote_v) == "table" then
			merge_missing_or_mismatch_fields(local_v, remote_v)
		end
	end
end

local function url_encode(str)
	return (str:gsub("([^%w%-%.%_%~%/])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function parse_content_range(h)
	if not h then
		return nil
	end
	local _, _, total = h:match("bytes%s+(%d+)%-(%d+)/(%d+)")
	return tonumber(total)
end

local function normalize_headers(h)
	local out = {}
	for k, v in pairs(h or {}) do
		out[string.lower(k)] = v
	end
	return out
end

local function in_game_version(plugin)
	local gv = plugin.game_version
	if type(gv) ~= "table" then
		return true
	end
	if #gv == 0 then
		return true
	end
	return table.contains(gv, KR_GAME)
end

require("dove_modules.gui.mod_manager_components")

ModManagerView = class("ModManagerView", PopUpView)

function ModManagerView:initialize(sw, sh, keyboard, controller)
	PopUpView.initialize(self, V.v(sw, sh))
	self._keyboard = keyboard
	self._controller = controller
	self._sw = sw
	self._sh = sh
	local rs = GGLabel.static.ref_h / REF_H

	-- 面板尺寸与缩放
	local panel_w = math.min(PANEL_MAX_W, sw - PANEL_MARGIN)
	panel_w = math.max(PANEL_MIN_W, panel_w)
	panel_w = math.min(panel_w, sw - 12)
	local panel_h = math.min(PANEL_MAX_H, sh - PANEL_MARGIN)
	panel_h = math.max(PANEL_MIN_H, panel_h)
	panel_h = math.min(panel_h, sh - 12)
	local ui_scale = math.max(panel_w / PANEL_MIN_W, panel_h / PANEL_MIN_H)
	local touch_scale = km.clamp(ui_scale * (IS_ANDROID and 1.12 or 1.0), 1.0, 1.35)
	local header_btn_w = math.floor(132 * touch_scale + 0.5)
	local header_btn_h = math.floor(30 * touch_scale + 0.5)
	local header_btn_gap = math.floor(10 * touch_scale + 0.5)
	local pager_btn_w = math.floor(90 * touch_scale + 0.5)
	local pager_btn_h = math.floor(24 * touch_scale + 0.5)
	local pager_page_w = math.floor(100 * touch_scale + 0.5)
	local hint_h = math.max(math.floor(20 * touch_scale + 0.5), pager_btn_h + 4)
	local global_label_y = 56
	local global_label_h = 28
	local global_toggle_w = km.clamp(math.floor(92 * touch_scale + 0.5), 84, 120)
	local global_toggle_h = km.clamp(math.floor(40 * touch_scale + 0.5), 36, 42)
	local global_toggle_center_y = global_label_y + math.floor(global_label_h / 2) + 2
	local global_row_bottom = math.max(global_label_y + global_label_h, global_toggle_center_y + math.floor(global_toggle_h / 2))
	local header_top_gap = km.clamp(math.floor(16 * touch_scale + 0.5), 14, 24)
	local header_top_y = global_row_bottom + header_top_gap
	local header_row_gap = math.max(6, math.floor(6 * touch_scale + 0.5))
	local header_row2_y = header_top_y + header_btn_h + header_row_gap
	local sep_y = header_row2_y + header_btn_h + 6
	local hint_y = sep_y + 4
	local pager_y = hint_y + math.max(0, math.floor((hint_h - pager_btn_h) / 2))
	local list_top_y = math.max(LIST_TOP_Y, hint_y + hint_h + 10)
	local footer_y = panel_h - 44
	local scroll_h = math.max(260, footer_y - list_top_y - 14)
	local header_group_x = panel_w - 20 - (header_btn_w * 3 + header_btn_gap * 2)
	self._row_action_button_size = V.v(km.clamp(math.floor(122 * touch_scale + 0.5), 122, 160), km.clamp(math.floor(34 * touch_scale + 0.5), 34, 38))
	self._row_toggle_size = V.v(km.clamp(math.floor(84 * touch_scale + 0.5), 84, 110), km.clamp(math.floor(36 * touch_scale + 0.5), 36, 44))
	self._row_status_width = km.clamp(math.floor(300 * touch_scale + 0.5), 300, 380)
	local row_right_pad = math.floor((IS_ANDROID and 30 or 26) * touch_scale + 0.5)
	self._row_right_pad = km.clamp(row_right_pad, IS_ANDROID and 32 or 28, IS_ANDROID and 44 or 38)
	self._row_action_bottom_margin = km.clamp(math.floor(18 * touch_scale + 0.5), 18, 26)
	self._row_toggle_top_margin = km.clamp(math.floor(18 * touch_scale + 0.5), 18, 26)

	-- 视图状态
	self.mode = "local"
	self.sort_idx = 1
	self.category_idx = 1
	self.store_page = 1
	self.store_total_pages = 1
	self.store_items = {}
	self._store_page_cache = {}
	self._remote_entry_cache = {}
	self._remote_lookup_done = false
	self.remote_by_entry = self._remote_entry_cache
	self.local_mods = {}
	self.local_by_entry = {}
	self.local_by_name = {}
	self._mod_rows = {}
	self._progress_target = 0
	self._progress_value = 0
	self._status_text = "点击“刷新商店”加载插件列表"
	self._cancel_requested = false
	self._request_id = 0
	self._active_task = nil
	self._task_result = nil
	self._selected_site = nil
	self._active_download_name = ""
	self._http_thread = nil
	self._unsaved_changes = false
	self._pending_close = false
	self._saved_state = {}

	-- 开发者模式
	self._developer_config = {
		account = "",
		password = ""
	}
	self._developer_token = nil
	self._developer_mode = false
	self._upload_pending_data = nil
	self._upload_pending_cover = nil
	self._my_plugins_only = false
	do
		local dev_chunk = FS.load("developer.lua")
		if dev_chunk then
			local ok, result = pcall(dev_chunk)
			if ok and type(result) == "table" then
				self._developer_config.account = result.account or ""
				self._developer_config.password = result.password or ""
				self._developer_mode = self._developer_config.account ~= "" and self._developer_config.password ~= ""
			end
		end
	end

	self.back = KView:new(V.v(panel_w, panel_h))
	self.back.colors.background = {47, 34, 6, 226}
	self.back.anchor = V.v(panel_w / 2, panel_h / 2)
	self.back.pos = V.v(sw / 2, sh / 2)
	self.back.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, panel_w, panel_h, 20, 20}
	}
	self:add_child(self.back)

	-- 面板标题
	local header = GGPanelHeader:new("插件管理器", panel_w - 40)
	header.pos = V.v(20, 14)
	self.back:add_child(header)

	-- 插件管理器总开关
	local global_lbl = GGOptionsLabel:new(V.v(300, global_label_h))
	global_lbl.text = "插件管理器总开关"
	global_lbl.text_align = "left"
	global_lbl.vertical_align = "middle"
	global_lbl.pos = V.v(20, global_label_y)
	self.back:add_child(global_lbl)

	self.global_toggle = ModToggleButton:new(false, V.v(global_toggle_w, global_toggle_h))
	self.global_toggle.anchor = V.v(self.global_toggle.size.x / 2, self.global_toggle.size.y / 2)
	self.global_toggle.pos = V.v(panel_w - 24 - self.global_toggle.size.x / 2, global_toggle_center_y)
	self.global_toggle.on_change = function(_, v)
		self._unsaved_changes = self:_check_unsaved()
		self:_render_current_list()
	end
	self.back:add_child(self.global_toggle)

	-- 头部按钮组（模式/排序/分类/刷新/更新/我的插件）
	local function header_btn(text, x, y, w, h)
		w = w or header_btn_w
		h = h or header_btn_h
		local btn = ModActionButton:new(text, V.v(w, h))
		btn.pos = V.v(x, y)
		self.back:add_child(btn)
		return btn
	end

	self.mode_btn = header_btn("前往商店", header_group_x, header_top_y)
	self.mode_btn.on_press = function()
		self._category_panel.hidden = true
		local prev_mode = self.mode
		self.mode = (self.mode == "local") and "store" or "local"
		self:_refresh_header_buttons()
		self:_render_current_list()
		if prev_mode ~= "store" and self.mode == "store" and #self.store_items == 0 and not self._active_task then
			self.store_page = 1
			self:_start_task("刷新商店列表", function()
				return self:_fetch_store_list()
			end)
		end
	end

	self.sort_btn = header_btn("排序：最热", header_group_x + header_btn_w + header_btn_gap, header_top_y)
	self.sort_btn.on_press = function()
		self.sort_idx = self.sort_idx % #SORT_OPTIONS + 1
		self.store_page = 1
		self:_refresh_header_buttons()
		if self.mode == "store" then
			self:_start_task("刷新商店列表", function()
				return self:_fetch_store_list()
			end)
		end
	end

	self.category_btn = header_btn("分类：全部", header_group_x + (header_btn_w + header_btn_gap) * 2, header_top_y)
	self.category_btn.on_press = function()
		self:_toggle_category_panel()
	end

	-- 分类选择下拉面板
	self._category_panel = KView:new(V.v(380, 180))
	self._category_panel.colors.background = {35, 25, 12, 240}
	self._category_panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 380, 180, 10, 10}
	}
	self._category_panel.hidden = true
	self.back:add_child(self._category_panel)
	local cat_panel_x = math.max(20, panel_w - 20 - 380)
	self._category_panel.pos = V.v(cat_panel_x, sep_y + 2)

	local CAT_COLS = 2
	local CAT_GAP = 6
	local CAT_PAD = 12
	local cat_btn_w = math.floor((380 - CAT_PAD * 2 - CAT_GAP * (CAT_COLS - 1)) / CAT_COLS)
	local cat_btn_h = 32
	self._category_buttons = {}
	for i, opt in ipairs(CATEGORY_OPTIONS) do
		local col = (i - 1) % CAT_COLS
		local row = math.floor((i - 1) / CAT_COLS)
		local bx = CAT_PAD + col * (cat_btn_w + CAT_GAP)
		local by = CAT_PAD + row * (cat_btn_h + CAT_GAP)
		local btn = ModActionButton:new(opt.label, V.v(cat_btn_w, cat_btn_h))
		btn.pos = V.v(bx, by)
		btn._category_index = i

		local orig_enter = btn.on_enter
		local orig_exit = btn.on_exit

		function btn:on_enter()
			orig_enter(self)
			if self._is_selected then
				self.colors.background = {58, 183, 90, 245}
				self._label.colors.text = {195, 255, 178, 255}
			end
		end

		function btn:on_exit()
			orig_exit(self)
			if self._is_selected then
				self.colors.background = {35, 148, 68, 215}
				self._label.colors.text = {195, 255, 178, 255}
			end
		end

		btn.on_press = function()
			if self.category_idx == i then
				self._category_panel.hidden = true
				return
			end
			self.category_idx = i
			self.store_page = 1
			self:_refresh_header_buttons()
			if self.mode == "store" then
				self:_start_task("刷新商店列表", function()
					return self:_fetch_store_list()
				end)
			else
				self:_render_current_list()
			end
			self._category_panel.hidden = true
		end

		self._category_panel:add_child(btn)
		self._category_buttons[i] = btn
	end

	self.refresh_btn = header_btn("刷新商店", header_group_x, header_row2_y)
	self.refresh_btn.on_press = function()
		if self.mode == "store" then
			self:_start_task("刷新商店列表", function()
				return self:_fetch_store_list()
			end)
		else
			self:_start_task("查询远端条目", function()
				return self:_fetch_remote_entries_for_local()
			end)
		end
	end

	self.update_all_btn = header_btn("一键更新全部", header_group_x + header_btn_w + header_btn_gap, header_row2_y)
	self.update_all_btn.on_press = function()
		self:_start_task("一键更新插件", function()
			return self:_update_all_plugins()
		end)
	end

	self.my_plugins_btn = header_btn("我的插件", header_group_x + (header_btn_w + header_btn_gap) * 2, header_row2_y)
	self.my_plugins_btn.on_press = function()
		self._my_plugins_only = not self._my_plugins_only
		if self.mode ~= "store" then
			self:_render_current_list()
		end
		self:_refresh_header_buttons()
	end
	self.my_plugins_btn.hidden = not self._developer_mode

	-- 分页控件与状态提示
	local pager_gap = 10
	local pager_next_x = panel_w - 20 - pager_btn_w
	local pager_page_x = pager_next_x - pager_gap - pager_page_w
	local pager_prev_x = pager_page_x - pager_gap - pager_btn_w

	self.prev_page_btn = header_btn("上一页", pager_prev_x, pager_y, pager_btn_w, pager_btn_h)
	self.prev_page_btn.on_press = function()
		if self.mode ~= "store" or self.store_page <= 1 then
			return
		end
		self.store_page = self.store_page - 1
		self:_start_task("翻页刷新", function()
			return self:_fetch_store_list()
		end)
	end

	local sep = KView:new(V.v(panel_w - 40, 1))
	sep.colors.background = {95, 75, 40, 255}
	sep.pos = V.v(20, sep_y)
	self.back:add_child(sep)

	-- 状态提示文本与翻页标签
	self.hint_lbl = GGLabel:new(V.v(panel_w - 40, hint_h))
	self.hint_lbl.font_name = "body"
	self.hint_lbl.font_size = 12 * rs
	self.hint_lbl.text_align = "left"
	self.hint_lbl.colors.text = {214, 193, 144, 255}
	self.hint_lbl.pos = V.v(20, hint_y)
	self.hint_lbl.text = self._status_text
	self.back:add_child(self.hint_lbl)

	self.page_lbl = GGLabel:new(V.v(pager_page_w, pager_btn_h))
	self.page_lbl.font_name = "body"
	self.page_lbl.font_size = 12 * rs
	self.page_lbl.text_align = "center"
	self.page_lbl.vertical_align = "middle"
	self.page_lbl.fit_lines = 1
	self.page_lbl.fit_size = true
	self.page_lbl.colors.text = {232, 214, 166, 255}
	self.page_lbl.pos = V.v(pager_page_x, pager_y)
	self.back:add_child(self.page_lbl)

	self.next_page_btn = header_btn("下一页", pager_next_x, pager_y, pager_btn_w, pager_btn_h)
	self.next_page_btn.on_press = function()
		if self.mode ~= "store" or self.store_page >= self.store_total_pages then
			return
		end
		self.store_page = self.store_page + 1
		self:_start_task("翻页刷新", function()
			return self:_fetch_store_list()
		end)
	end

	-- 任务进度对话框
	self.task_dialog = KView:new(V.v(math.min(560, panel_w - 80), 150))
	self.task_dialog.anchor = V.v(self.task_dialog.size.x / 2, self.task_dialog.size.y / 2)
	self.task_dialog.pos = V.v(panel_w / 2, panel_h / 2)
	self.task_dialog.colors.background = {30, 21, 9, 235}
	self.task_dialog.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, self.task_dialog.size.x, self.task_dialog.size.y, 12, 12}
	}
	self.task_dialog.hidden = true
	self.back:add_child(self.task_dialog)

	self.task_title_lbl = GGLabel:new(V.v(self.task_dialog.size.x - 24, 24))
	self.task_title_lbl.font_name = "h"
	self.task_title_lbl.font_size = 15 * rs
	self.task_title_lbl.text_align = "left"
	self.task_title_lbl.vertical_align = "middle"
	self.task_title_lbl.colors.text = {244, 221, 165, 255}
	self.task_title_lbl.text = "网络任务进行中"
	self.task_title_lbl.pos = V.v(12, 10)
	self.task_dialog:add_child(self.task_title_lbl)

	self.task_status_lbl = GGLabel:new(V.v(self.task_dialog.size.x - 24, 48))
	self.task_status_lbl.font_name = "body"
	self.task_status_lbl.font_size = 12 * rs
	self.task_status_lbl.text_align = "left"
	self.task_status_lbl.vertical_align = "top"
	self.task_status_lbl.fit_lines = 2
	self.task_status_lbl.fit_size = true
	self.task_status_lbl.line_height = 1.2
	self.task_status_lbl.colors.text = {223, 202, 152, 255}
	self.task_status_lbl.text = self._status_text
	self.task_status_lbl.pos = V.v(12, 36)
	self.task_dialog:add_child(self.task_status_lbl)

	self.progress_bg = KView:new(V.v(self.task_dialog.size.x - 24, 10))
	self.progress_bg.colors.background = {75, 62, 34, 210}
	self.progress_bg.pos = V.v(12, 90)
	self.progress_bg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, self.progress_bg.size.x, 10, 6, 6}
	}
	self.task_dialog:add_child(self.progress_bg)

	self.progress_fill = KView:new(V.v(0, 10))
	self.progress_fill.colors.background = {227, 190, 68, 235}
	self.progress_fill.pos = V.v(0, 0)
	self.progress_fill.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 0, 10, 6, 6}
	}
	self.progress_bg:add_child(self.progress_fill)

	local task_btn_w = km.clamp(math.floor(110 * touch_scale + 0.5), 110, 150)
	local task_btn_h = km.clamp(math.floor(28 * touch_scale + 0.5), 28, 34)
	self._confirm_btn_h = task_btn_h
	self.task_cancel_btn = ModActionButton:new("断开请求", V.v(task_btn_w, task_btn_h))
	self.task_cancel_btn.pos = V.v(self.task_dialog.size.x - task_btn_w - 12, self.task_dialog.size.y - task_btn_h - 12)
	self.task_cancel_btn.on_press = function()
		self._cancel_requested = true
		self:_set_status("已请求断连，正在停止当前网络操作…", nil)
	end
	self.task_dialog:add_child(self.task_cancel_btn)

	local cover_btn_gap = 10
	self._confirm_btn_gap = cover_btn_gap
	local cover_btn_w = math.floor(task_btn_w * 0.8)
	self._confirm_btn_w = cover_btn_w
	self._cover_yes_btn = ModActionButton:new("上传封面", V.v(cover_btn_w, task_btn_h))
	self._cover_yes_btn.on_press = function()
		S:queue("GUIButtonCommon")
		local mod_data = self._upload_pending_data
		local has_cover = self._upload_pending_cover ~= nil
		self:_reset_cover_prompt()
		if mod_data then
			self:_start_task("上传插件", function()
				return self:_upload_plugin(mod_data, has_cover)
			end)
		end
	end
	self._cover_yes_btn.hidden = true
	self.task_dialog:add_child(self._cover_yes_btn)

	self._cover_no_btn = ModActionButton:new("跳过封面", V.v(cover_btn_w, task_btn_h))
	self._cover_no_btn.on_press = function()
		S:queue("GUIButtonCommon")
		local mod_data = self._upload_pending_data
		self:_reset_cover_prompt()
		if mod_data then
			self:_start_task("上传插件", function()
				return self:_upload_plugin(mod_data, false)
			end)
		end
	end
	self._cover_no_btn.hidden = true
	self.task_dialog:add_child(self._cover_no_btn)

	self._confirm_cancel_btn = ModActionButton:new("取消", V.v(cover_btn_w, task_btn_h))
	self._confirm_cancel_btn.on_press = function()
		S:queue("GUIButtonCommon")
		self:_reset_cover_prompt()
	end
	self._confirm_cancel_btn.hidden = true
	self.task_dialog:add_child(self._confirm_cancel_btn)
	self.task_dialog:add_child(self._cover_no_btn)

	-- 禁用警告与插件列表
	self._disabled_warning = GGLabel:new(V.v(panel_w - 40, 28))
	self._disabled_warning.font_name = "body"
	self._disabled_warning.font_size = 14 * rs
	self._disabled_warning.text_align = "center"
	self._disabled_warning.vertical_align = "middle"
	self._disabled_warning.colors.text = {255, 180, 100, 255}
	self._disabled_warning.text = "!插件管理器总开关已关闭，所有插件不会生效"
	self._disabled_warning.pos = V.v(20, list_top_y - 32)
	self._disabled_warning.hidden = true
	self.back:add_child(self._disabled_warning)

	self.mod_list = KScrollList:new(V.v(panel_w - 40, scroll_h))
	self.mod_list.pos = V.v(20, list_top_y)
	self.mod_list.drag_scroll_threshold = IS_ANDROID and 20 or 6
	self.mod_list.scroll_amount = ROW_H
	self.mod_list.colors.scroller_background = {45, 36, 22, 200}
	self.mod_list.colors.scroller_foreground = {110, 90, 50, 255}
	-- 加宽滑块
	self.mod_list.scroller_width = 24
	self.back:add_child(self.mod_list)

	-- 底部按钮（保存并重启 / 浏览器商店 / 关闭）
	local y_btn = footer_y
	local save_btn = GGOptionsButton:new("保存并重启")
	save_btn:set_anchor_to_center()
	save_btn.pos = V.v(panel_w / 3, y_btn)
	self.back:add_child(save_btn)
	save_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:save()
		self:_stop_http_thread()
		restart.tmp()
	end

	local shop_btn = GGOptionsButton:new("浏览器商店")
	shop_btn:set_anchor_to_center()
	shop_btn.pos = V.v(panel_w * 2 / 3, y_btn)
	self.back:add_child(shop_btn)
	shop_btn.on_click = function()
		S:queue("GUIButtonCommon")
		love.system.openURL((self._selected_site or (main and main.params and main.params.update_last_site) or STORE_BACKUP_SITES[1]):gsub("/+$", "") .. "/plugins")
	end

	local close_btn = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	close_btn.pos = V.v(panel_w - 23, 23)
	close_btn.scale:set(1.5, 1.5)
	close_btn:set_anchor_to_center()
	self.back:add_child(close_btn)
	close_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	-- 未保存修改确认对话框
	self._confirm_dialog = KView:new(V.v(480, 180))
	self._confirm_dialog.anchor = V.v(self._confirm_dialog.size.x / 2, self._confirm_dialog.size.y / 2)
	self._confirm_dialog.pos = V.v(panel_w / 2, panel_h / 2)
	self._confirm_dialog.colors.background = {30, 21, 9, 235}
	self._confirm_dialog.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, self._confirm_dialog.size.x, self._confirm_dialog.size.y, 12, 12}
	}
	self._confirm_dialog.hidden = true
	self.back:add_child(self._confirm_dialog)

	local confirm_title = GGLabel:new(V.v(self._confirm_dialog.size.x - 24, 28))
	confirm_title.font_name = "h"
	confirm_title.font_size = 15 * rs
	confirm_title.text_align = "left"
	confirm_title.vertical_align = "middle"
	confirm_title.colors.text = {244, 221, 165, 255}
	confirm_title.text = "有未保存的修改"
	confirm_title.pos = V.v(12, 10)
	self._confirm_dialog:add_child(confirm_title)

	local confirm_hint = GGLabel:new(V.v(self._confirm_dialog.size.x - 24, 28))
	confirm_hint.font_name = "body"
	confirm_hint.font_size = 12 * rs
	confirm_hint.text_align = "left"
	confirm_hint.vertical_align = "middle"
	confirm_hint.colors.text = {223, 202, 152, 255}
	confirm_hint.text = "插件管理器配置已修改，请选择操作："
	confirm_hint.pos = V.v(12, 40)
	self._confirm_dialog:add_child(confirm_hint)

	local bw = 120
	local bh = 30
	local gap = 16
	local row_y1 = self._confirm_dialog.size.y - bh * 2 - 16
	local row_y2 = self._confirm_dialog.size.y - bh - 8

	local function center_row(buttons)
		local total_w = #buttons * bw + (#buttons - 1) * gap
		local x = (self._confirm_dialog.size.x - total_w) / 2
		for _, b in ipairs(buttons) do
			local btn = ModActionButton:new(b.text, V.v(bw, bh))
			btn.pos = V.v(x, b.y)
			btn.on_press = function()
				S:queue("GUIButtonCommon")
				b.action()
			end
			self._confirm_dialog:add_child(btn)
			x = x + bw + gap
		end
	end

	center_row({{
		text = "保存调整",
		y = row_y1,
		action = function()
			self:save()
			self._confirm_dialog.hidden = true
			self._unsaved_changes = false
			self._pending_close = true
		end
	}, {
		text = "舍弃调整",
		y = row_y1,
		action = function()
			self._confirm_dialog.hidden = true
			self._unsaved_changes = false
			self._pending_close = true
		end
	}})

	center_row({{
		text = "保存并重启",
		y = row_y2,
		action = function()
			self:save()
			self._confirm_dialog.hidden = true
			self:_stop_http_thread()
			restart.tmp()
		end
	}, {
		text = "取消",
		y = row_y2,
		action = function()
			self._confirm_dialog.hidden = true
		end
	}})

	self.task_dialog:order_to_front()
	self:_refresh_header_buttons()
	self:_start_http_thread()
end

function ModManagerView:_start_http_thread()
	if self._http_thread then
		return
	end
	local req_ch = love.thread.getChannel("mod_store_http_req")
	local resp_ch = love.thread.getChannel("mod_store_http_resp")
	while req_ch:getCount() > 0 do
		req_ch:pop()
	end
	while resp_ch:getCount() > 0 do
		resp_ch:pop()
	end
	self._http_thread = love.thread.newThread(HTTP_WORKER)
	self._http_thread:start()
end

function ModManagerView:_stop_http_thread()
	if not self._http_thread then
		return
	end
	love.thread.getChannel("mod_store_http_req"):push("quit")
	self._http_thread:wait()
	self._http_thread = nil
end

function ModManagerView:_refresh_header_buttons()
	self.mode_btn:set_text(self.mode == "local" and "前往商店" or "回到本地")
	self.sort_btn:set_text("排序：" .. SORT_OPTIONS[self.sort_idx].label)
	self.category_btn:set_text("分类：" .. CATEGORY_OPTIONS[self.category_idx].label)
	local in_store = self.mode == "store"
	local task_running = self._active_task ~= nil
	self.refresh_btn:set_text(in_store and "刷新商店" or "查询远端")
	self.sort_btn:set_enabled(in_store and not self._active_task)
	self.category_btn:set_enabled(true) -- 分类按钮始终可用，本地下直接切分类，商店下刷新商店列表
	self.refresh_btn:set_enabled(not self._active_task)
	self.prev_page_btn.hidden = not in_store
	self.page_lbl.hidden = not in_store
	self.next_page_btn.hidden = not in_store
	self.prev_page_btn:set_enabled(in_store and not task_running and self.store_page > 1)
	self.next_page_btn:set_enabled(in_store and not task_running and self.store_page < self.store_total_pages)
	self.page_lbl.text = string.format("第%d/%d页", self.store_page, self.store_total_pages)
	self.task_cancel_btn:set_enabled(task_running)
	self.update_all_btn:set_enabled(not task_running)
	self.my_plugins_btn.hidden = not self._developer_mode or in_store
	if not self.my_plugins_btn.hidden then
		if self._my_plugins_only then
			self.my_plugins_btn:set_text("切换本地插件")
			self.my_plugins_btn.colors.background = {161, 122, 45, 245}
			self.my_plugins_btn._label.colors.text = {255, 240, 190, 255}
		else
			self.my_plugins_btn:set_text("切换我的插件")
			self.my_plugins_btn:_refresh()
		end
	end
end

function ModManagerView:_toggle_category_panel()
	if not self._category_panel then
		return
	end
	if self._category_panel.hidden then
		self:_refresh_category_buttons_highlight()
		self._category_panel.hidden = false
		self._category_panel:order_to_front()
	else
		self._category_panel.hidden = true
	end
end

function ModManagerView:_refresh_category_buttons_highlight()
	if not self._category_buttons then
		return
	end
	for i, btn in ipairs(self._category_buttons) do
		local selected = i == self.category_idx
		btn._is_selected = selected
		btn:_refresh()
		if selected then
			btn.colors.background = {35, 148, 68, 215}
			btn._label.colors.text = {195, 255, 178, 255}
		end
	end
end

function ModManagerView:_set_status(text, progress)
	self._status_text = utf8_util.sanitize(text or "")
	self.hint_lbl.text = self._status_text
	if self.task_status_lbl then
		self.task_status_lbl.text = self._status_text
	end
	if progress ~= nil then
		self._progress_target = math.max(0, math.min(100, progress))
	end
end

function ModManagerView:_render_progress()
	self._progress_value = self._progress_value + (self._progress_target - self._progress_value) * 0.2
	local w = (self.progress_bg.size.x) * (self._progress_value / 100)
	self.progress_fill.shape.args[4] = w
	self.progress_fill.size = V.v(w, self.progress_fill.size.y)
end

function ModManagerView:_request(url, options, timeout_sec)
	timeout_sec = timeout_sec or 20
	self._request_id = self._request_id + 1
	local req_id = self._request_id
	local req_ch = love.thread.getChannel("mod_store_http_req")
	local resp_ch = love.thread.getChannel("mod_store_http_resp")
	req_ch:push({
		id = req_id,
		url = url,
		options = options
	})

	local start_t = love.timer.getTime()
	while true do
		if self._cancel_requested then
			return nil, "cancelled"
		end
		if love.timer.getTime() - start_t > timeout_sec then
			return nil, "timeout"
		end
		while resp_ch:getCount() > 0 do
			local resp = resp_ch:pop()
			if resp and resp.id == req_id then
				return resp, nil
			end
		end
		coroutine.yield()
	end
end

function ModManagerView:_select_store_base_url()
	if self._selected_site and self._selected_site ~= "" then
		return self._selected_site:gsub("/+$", "") .. "/plugins"
	end
	local params_tmp = main and main.params or {}
	local last_site = params_tmp and params_tmp.update_last_site or STORE_BACKUP_SITES[1]
	local candidates = {last_site}
	for _, site in ipairs(STORE_BACKUP_SITES) do
		if site ~= last_site then
			candidates[#candidates + 1] = site
		end
	end
	for i, site in ipairs(candidates) do
		self:_set_status(string.format("正在选择插件商店地址（%d/%d）：%s", i, #candidates, site), 0)
		local test_url = site:gsub("/+$", "") .. "/plugins/list?page=1&page_size=1&sort=hot&category=all"
		local resp, err = self:_request(test_url, {
			method = "GET"
		}, 10)
		if err then
			self:_set_status("地址不可用：" .. site .. "（" .. err .. "）", 0)
		elseif tonumber(resp.code) == 200 then
			self._selected_site = site
			local params = main and main.params
			if params and params.update_last_site ~= site then
				params.update_last_site = site
				storage:save_settings(params)
			end
			self:_set_status("已选中插件商店地址：" .. site, 0)
			return site:gsub("/+$", "") .. "/plugins"
		else
			self:_set_status("地址不可用：" .. site .. "（HTTP " .. tostring(resp.code) .. "）", 0)
		end
	end
	return nil
end

function ModManagerView:_decode_store_page(body, fallback_page)
	local items = body.items or {}
	local filtered = {}
	local by_entry = {}
	for _, item in ipairs(items) do
		if in_game_version(item) then
			filtered[#filtered + 1] = item
			if item.entry and not by_entry[item.entry] then
				by_entry[item.entry] = item
			end
		end
	end

	local page = math.max(1, tonumber(body.page or body.current_page) or fallback_page or 1)
	local total = tonumber(body.total or body.total_count or body.count)
	local total_pages = tonumber(body.total_pages or body.page_count)
	local page_size = tonumber(body.page_size or body.per_page or body.limit) or STORE_PAGE_SIZE
	local has_more = body.has_more
	if has_more == nil then
		has_more = body.has_next
	end
	if type(has_more) ~= "boolean" then
		has_more = #items >= page_size
	end

	if total_pages and total_pages > 0 then
		total_pages = math.max(1, math.floor(total_pages))
	elseif total and total > 0 then
		total_pages = math.max(1, math.ceil(total / math.max(1, page_size)))
	else
		total_pages = math.max(page, has_more and (page + 1) or page)
	end

	return {
		items = filtered,
		by_entry = by_entry,
		page = math.min(page, total_pages),
		total_pages = total_pages,
		page_size = page_size,
		has_more = has_more
	}
end

function ModManagerView:_get_store_page(base, sort_val, category_val, page, use_cache)
	local key = table.concat({base or "", sort_val or "", category_val or "", tostring(page or 1), tostring(STORE_PAGE_SIZE)}, "::")
	if use_cache ~= false and self._store_page_cache[key] then
		return true, self._store_page_cache[key], true
	end

	local url = string.format("%s/list?page=%d&page_size=%d&sort=%s&category=%s", base, page, STORE_PAGE_SIZE, sort_val, category_val)
	local resp, err = self:_request(url, {
		method = "GET"
	}, 20)
	if err then
		return false, "拉取插件列表失败：" .. err, false
	end
	if tonumber(resp.code) ~= 200 then
		return false, "拉取插件列表失败：HTTP " .. tostring(resp.code), false
	end
	local ok, body = pcall(json.decode, resp.body)
	if not ok or type(body) ~= "table" then
		return false, "插件列表解析失败", false
	end

	local parsed = self:_decode_store_page(body, page)
	self._store_page_cache[key] = parsed
	return true, parsed, false
end

function ModManagerView:_fetch_store_list()
	self._cancel_requested = false
	local base = self:_select_store_base_url()
	if not base then
		return false, "没有可用插件商店地址"
	end
	local sort_val = SORT_OPTIONS[self.sort_idx].value
	local category_val = CATEGORY_OPTIONS[self.category_idx].value
	local page = math.max(1, self.store_page)
	self:_set_status(string.format("正在刷新插件商店（第 %d 页）…", page), 5)
	local ok, page_data_or_err = self:_get_store_page(base, sort_val, category_val, page, true)
	if not ok then
		return false, page_data_or_err
	end
	local page_data = page_data_or_err
	self.store_page = page_data.page
	self.store_total_pages = page_data.total_pages
	self.store_items = page_data.items
	for entry, item in pairs(page_data.by_entry or {}) do
		self._remote_entry_cache[entry] = item
	end
	self.remote_by_entry = self._remote_entry_cache
	self:_set_status(string.format("插件商店第 %d 页已刷新：%d 项", self.store_page, #self.store_items), 100)
	self:_render_current_list()
	return true, nil
end

function ModManagerView:_fetch_remote_entries_for_local()
	self._cancel_requested = false
	if #self.local_mods == 0 then
		self.remote_by_entry = self._remote_entry_cache
		self._remote_lookup_done = true
		self:_set_status("本地没有已安装插件", 0)
		self:_render_current_list()
		return true, nil
	end

	local base = self:_select_store_base_url()
	if not base then
		return false, "没有可用插件商店地址"
	end

	local target_entries = {}
	local total_targets = 0
	for _, mod_data in ipairs(self.local_mods) do
		local entry = utf8_util.sanitize(mod_data.entry)
		if entry ~= "" then
			if not target_entries[entry] then
				total_targets = total_targets + 1
			end
			target_entries[entry] = true
		end
	end
	if total_targets == 0 then
		self._remote_lookup_done = true
		self:_set_status("本地插件缺少可匹配的 entry 字段", 0)
		self:_render_current_list()
		return true, nil
	end

	local found_count = 0
	for entry, _ in pairs(target_entries) do
		if self._remote_entry_cache[entry] then
			found_count = found_count + 1
		end
	end
	local sort_val = SORT_OPTIONS[self.sort_idx].value
	local category_val = "all"
	local page = 1
	while true do
		if self._cancel_requested then
			return false, "cancelled"
		end
		local ok, page_data_or_err = self:_get_store_page(base, sort_val, category_val, page, true)
		if not ok then
			return false, page_data_or_err
		end
		local page_data = page_data_or_err
		for entry, item in pairs(page_data.by_entry) do
			if target_entries[entry] and not self._remote_entry_cache[entry] then
				self._remote_entry_cache[entry] = item
				found_count = found_count + 1
			end
		end
		self:_set_status(string.format("正在查询远端条目… 第 %d 页（已匹配 %d/%d）", page, found_count, total_targets), 5)
		if found_count >= total_targets then
			break
		end
		if page >= page_data.total_pages then
			break
		end
		page = page + 1
		coroutine.yield()
	end

	self.remote_by_entry = self._remote_entry_cache
	self._remote_lookup_done = true
	self:_render_current_list()
	if found_count >= total_targets then
		self:_set_status(string.format("远端条目查询完成：已匹配 %d/%d", found_count, total_targets), 100)
	else
		self:_set_status(string.format("远端条目查询完成：已匹配 %d/%d，仍有缺失", found_count, total_targets), 100)
	end
	return true, nil
end

function ModManagerView:_reload_local_mods()
	mod_paths.ensure_storage_ready()
	local main_cfg = mod_paths.load_main_config()

	self.local_mods = {}
	self.local_by_entry = {}
	self.local_by_name = {}

	local mods_dir = mod_paths.LOCAL_MODS_DIR
	local not_mod_path = main_cfg.not_mod_path or {"mod_template", "all"}
	local items = FS.getDirectoryItems(mods_dir) or {}
	for _, name in ipairs(items) do
		if not table.contains(not_mod_path, name) then
			local dir_path = mods_dir .. "/" .. name
			if FS.getInfo(dir_path, "directory") then
				local config_path = dir_path .. "/config.lua"
				local mc = mod_paths.load_lua_table(config_path)
				if mc then
					local has_config = false
					local config_info = love.filesystem.getInfo(dir_path .. "/" .. name .. "_config.lua")
					if config_info and config_info.type == "file" then
						has_config = true
					end
					local mod_data = {
						name = name,
						path = dir_path,
						config_path = config_path,
						config = mc,
						entry = mc.entry or name,
						has_config = has_config
					}
					self.local_mods[#self.local_mods + 1] = mod_data
					self.local_by_name[name] = mod_data
					self.local_by_entry[mod_data.entry] = mod_data
				end
			end
		end
	end
	table.sort(self.local_mods, function(a, b)
		local t_a = a.config.last_used_at or 0
		local t_b = b.config.last_used_at or 0
		if t_a ~= t_b then
			return t_a > t_b
		end
		return (a.config.priority or 0) < (b.config.priority or 0)
	end)
end

function ModManagerView:_refresh_local_view(status_text)
	if status_text then
		self:_set_status(status_text, 100)
	end
	self:_reload_local_mods()
	self:_render_current_list()
end

function ModManagerView:_delete_local_mod_by_name(mod_name)
	local mod_data = self.local_by_name[mod_name]
	if not mod_data then
		return false, "本地插件不存在"
	end
	local ok = remove_dir_recursive(mod_data.path)
	if not ok then
		return false, "删除失败：" .. mod_data.path
	end
	self:_reload_local_mods()
	self:_render_current_list()
	return true, nil
end

function ModManagerView:_download_zip(item)
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return nil, "无法选择插件商店地址"
	end
	local filename = item.filename
	if not filename or filename == "" then
		return nil, "插件缺少下载文件名"
	end
	local url = base .. "/download/" .. url_encode(filename)
	local chunk_size = 256 * 1024
	local chunks = {}
	local downloaded = 0
	local total = nil
	self._active_download_name = item.name or item.entry or filename

	while not total or downloaded < total do
		if self._cancel_requested then
			return nil, "cancelled"
		end
		local end_pos
		if total then
			end_pos = math.min(downloaded + chunk_size - 1, total - 1)
		else
			end_pos = downloaded + chunk_size - 1
		end
		local resp, err = self:_request(url, {
			method = "GET",
			headers = {
				["Range"] = string.format("bytes=%d-%d", downloaded, end_pos)
			}
		}, 20)
		if err then
			return nil, "下载失败：" .. err
		end
		local code = tonumber(resp.code)
		if code ~= 206 and code ~= 200 then
			return nil, "下载失败：HTTP " .. tostring(resp.code)
		end

		local headers = normalize_headers(resp.headers)
		if not total then
			total = parse_content_range(headers["content-range"]) or tonumber(headers["content-length"])
			if total and code == 200 then
				total = #resp.body
			end
		end
		local body = resp.body or ""
		chunks[#chunks + 1] = body
		downloaded = downloaded + #body

		local percent = total and (downloaded * 100 / math.max(total, 1)) or 0
		self:_set_status(string.format("下载插件中：%s  %.1f%%", self._active_download_name, percent), percent)

		if code == 200 then
			break
		end
		if #body == 0 then
			return nil, "下载返回空数据"
		end
	end

	if total and downloaded ~= total then
		return nil, "下载不完整"
	end
	return table.concat(chunks), nil
end

function ModManagerView:_collect_mod_root_candidates(base_dir)
	local candidates = {}
	local visited = {}

	local function walk(dir, depth)
		if depth > 4 or visited[dir] then
			return
		end
		visited[dir] = true
		if FS.getInfo(dir .. "/config.lua", "file") then
			candidates[#candidates + 1] = dir
		end
		for _, name in ipairs(FS.getDirectoryItems(dir) or {}) do
			local child = dir .. "/" .. name
			if FS.getInfo(child, "directory") then
				walk(child, depth + 1)
			end
		end
	end

	walk(base_dir, 0)
	return candidates
end

function ModManagerView:_install_plugin(item, is_update)
	self._cancel_requested = false
	self:_set_status((is_update and "正在更新插件：" or "正在安装插件：") .. (item.name or item.entry), 0)
	local zip_data, err = self:_download_zip(item)
	if not zip_data then
		return false, err
	end
	if self._cancel_requested then
		return false, "cancelled"
	end

	local entry = utf8_util.sanitize(item.entry or "")
	local stage_root = "tmp/mod_store_stage/" .. (entry ~= "" and entry or ("pkg_" .. tostring(os.time())))
	remove_dir_recursive("tmp/mod_store_stage")
	FS.createDirectory("tmp")
	FS.createDirectory("tmp/mod_store_stage")
	FS.createDirectory(stage_root)

	self:_set_status("正在解压插件：" .. (item.name or item.entry), 92)
	local ok, unzip_err = zip.unzip_to_dir(zip_data, stage_root)
	if not ok then
		return false, unzip_err
	end

	local candidates = self:_collect_mod_root_candidates(stage_root)
	local selected_dir = nil
	for _, c in ipairs(candidates) do
		local cfg = mod_paths.load_lua_table(c .. "/config.lua")
		local c_entry = cfg and utf8_util.sanitize(cfg.entry or "")
		if entry ~= "" and (c_entry == entry or basename(c) == entry) then
			selected_dir = c
			break
		end
	end
	if not selected_dir and #candidates == 1 then
		selected_dir = candidates[1]
	end
	if not selected_dir and entry ~= "" and FS.getInfo(stage_root .. "/" .. entry, "directory") then
		selected_dir = stage_root .. "/" .. entry
	end
	if not selected_dir then
		return false, "安装包结构无法识别（未找到有效插件目录）"
	end

	local target_name = (entry ~= "" and entry) or basename(selected_dir)
	local target_dir = mod_paths.LOCAL_MODS_DIR .. "/" .. target_name
	local local_mod = nil
	local preserved_enabled = nil
	local preserved_local_config = nil
	if is_update then
		local_mod = (entry ~= "" and self.local_by_entry[entry]) or self.local_by_name[target_name]
		if local_mod and local_mod.config then
			preserved_enabled = local_mod.config.enabled ~= false
		else
			local existing_cfg = mod_paths.load_lua_table(target_dir .. "/config.lua")
			if existing_cfg then
				preserved_enabled = existing_cfg.enabled ~= false
			end
		end

		local local_cfg_path = local_mod and (local_mod.path .. "/" .. local_mod.name .. "_config.lua") or (target_dir .. "/" .. target_name .. "_config.lua")
		if FS.getInfo(local_cfg_path, "file") then
			local local_cfg, read_err = mod_paths.load_lua_table(local_cfg_path)
			if not local_cfg then
				return false, "更新前读取本地配置失败：" .. local_cfg_path .. " (" .. tostring(read_err) .. ")"
			end
			preserved_local_config = local_cfg
		end
	end
	remove_dir_recursive(target_dir)
	copy_dir_recursive(selected_dir, target_dir)
	if preserved_enabled ~= nil then
		local installed_cfg = mod_paths.load_lua_table(target_dir .. "/config.lua")
		if not installed_cfg then
			return false, "更新后读取配置失败：" .. target_dir .. "/config.lua"
		end
		installed_cfg.enabled = preserved_enabled
		local wok = storage:write_lua(target_dir .. "/config.lua", installed_cfg)
		if not wok then
			return false, "更新后写入配置失败：" .. target_dir .. "/config.lua"
		end
	end
	if preserved_local_config then
		local installed_local_cfg_path = target_dir .. "/" .. target_name .. "_config.lua"
		local merged_local_cfg = table.deepclone(preserved_local_config)
		if FS.getInfo(installed_local_cfg_path, "file") then
			local remote_local_cfg, read_err = mod_paths.load_lua_table(installed_local_cfg_path)
			if not remote_local_cfg then
				return false, "更新后读取远端本地配置失败：" .. installed_local_cfg_path .. " (" .. tostring(read_err) .. ")"
			end
			merge_missing_or_mismatch_fields(merged_local_cfg, remote_local_cfg)
		end
		local wok = storage:write_lua(installed_local_cfg_path, merged_local_cfg)
		if not wok then
			return false, "更新后写入本地配置失败：" .. installed_local_cfg_path
		end
	end
	remove_dir_recursive("tmp/mod_store_stage")

	local new_cfg = mod_paths.load_lua_table(target_dir .. "/config.lua")
	if new_cfg then
		new_cfg.last_used_at = os.time()
		storage:write_lua(target_dir .. "/config.lua", new_cfg)
	end

	self:_refresh_local_view((is_update and "插件更新完成：" or "插件安装完成：") .. (item.name or item.entry))
	self._active_download_name = ""
	return true, nil
end

function ModManagerView:_install_or_update_item(item)
	local local_mod = self.local_by_entry[item.entry]
	local need_update = local_mod and has_update(local_mod.config.version, item.version)
	local is_update = need_update == true
	return self:_install_plugin(item, is_update)
end

function ModManagerView:_update_all_plugins()
	self._cancel_requested = false
	if #self.local_mods == 0 then
		self:_set_status("本地没有已安装插件", 0)
		return true, nil
	end
	local need_remote_lookup = not next(self._remote_entry_cache)
	if not need_remote_lookup then
		for _, mod_data in ipairs(self.local_mods) do
			local entry = utf8_util.sanitize(mod_data.entry)
			if entry ~= "" and not self._remote_entry_cache[entry] then
				need_remote_lookup = true
				break
			end
		end
	end
	if need_remote_lookup then
		local ok, err = self:_fetch_remote_entries_for_local()
		if not ok then
			return false, err
		end
	end
	self.remote_by_entry = self._remote_entry_cache
	local pending = {}
	for _, mod_data in ipairs(self.local_mods) do
		local remote = self.remote_by_entry[mod_data.entry]
		if remote and has_update(mod_data.config.version, remote.version) then
			pending[#pending + 1] = {
				local_mod = mod_data,
				remote = remote
			}
		end
	end
	if #pending == 0 then
		self:_set_status("没有可更新的插件", 0)
		return true, nil
	end
	for i, row in ipairs(pending) do
		if self._cancel_requested then
			return false, "cancelled"
		end
		self:_set_status(string.format("一键更新（%d/%d）：%s", i, #pending, row.remote.name or row.remote.entry), (i - 1) * 100 / #pending)
		local ok, err = self:_install_plugin(row.remote, true)
		if not ok then
			return false, err
		end
		coroutine.yield()
	end
	self:_set_status(string.format("一键更新完成，共 %d 个插件", #pending), 100)
	return true, nil
end

function ModManagerView:_start_task(name, fn)
	if self._active_task then
		return
	end
	self._cancel_requested = false
	self._task_result = nil
	self:_set_status("正在处理：" .. name, 0)
	self.task_dialog:order_to_front()
	self.task_dialog.hidden = false
	self._active_task = coroutine.create(function()
		local ok, err = fn()
		return {
			ok = ok,
			err = err
		}
	end)
	self:_refresh_header_buttons()
end

function ModManagerView:_render_local_list()
	self.mod_list:clear_rows()
	self._mod_rows = {}
	local list_w = self.mod_list.size.x - self.mod_list.scroller_width - 2 * self.mod_list.scroller_margin - 4
	local global_disabled = not self.global_toggle.value

	local category_option = CATEGORY_OPTIONS[self.category_idx]

	for _, mod_data in ipairs(self.local_mods) do
		local cfg = mod_data.config
		local mod_category = cfg.category or "other"
		-- 过滤分类
		if (category_option.value == "all" or category_option.value == mod_category) and (not self._my_plugins_only or cfg.by == self._developer_config.account) then
			local remote = self.remote_by_entry[mod_data.entry]
			local status = ""

			if remote and has_update(cfg.version, remote.version) then
				status = string.format("可更新：v%s → v%s", utf8_util.sanitize(cfg.version), utf8_util.sanitize(remote.version))
			elseif remote then
				status = "已是最新版本"
			else
				status = self._remote_lookup_done and "未在商店中找到远端条目" or "未查询远端条目（点“查询远端”）"
			end

			local actions = {}
			if self._developer_mode and cfg.by == self._developer_config.account then
				actions[#actions + 1] = {
					text = "上传",
					on_press = function()
						self:_handle_upload_plugin(mod_data)
					end
				}
			end
			actions[#actions + 1] = {
				text = "详情",
				on_press = function()
					self:_show_local_mod_detail(mod_data)
				end
			}
			actions[#actions + 1] = {
				text = "删除",
				on_press = function()
					self:_start_task("删除插件", function()
						local ok, err = self:_delete_local_mod_by_name(mod_data.name)
						if ok then
							self:_set_status("已删除插件：" .. mod_data.name, 0)
							return true, nil
						end
						return false, err
					end)
				end
			}
			if remote and has_update(cfg.version, remote.version) then
				actions[#actions + 1] = {
					text = "更新",
					on_press = function()
						self:_start_task("更新插件", function()
							return self:_install_plugin(remote, true)
						end)
					end
				}
			end

			local row = ModItemRow:new({
				mod_data = mod_data,
				title = cfg.name or mod_data.name,
				meta = string.format("本地版本 v%s  作者: %s", utf8_util.sanitize(cfg.version), utf8_util.sanitize(cfg.by)),
				desc = cfg.desc or "",
				status = status,
				show_toggle = not global_disabled,
				action_button_size = self._row_action_button_size,
				toggle_size = self._row_toggle_size,
				status_width = self._row_status_width,
				right_pad = self._row_right_pad,
				action_bottom_margin = self._row_action_bottom_margin,
				toggle_top_margin = self._row_toggle_top_margin,
				enabled = cfg.enabled ~= false,
				on_toggle = function(v)
					cfg.enabled = v
					if v then
						cfg.last_used_at = os.time()
					end
					self._unsaved_changes = self:_check_unsaved()
				end,
				actions = global_disabled and {} or actions,
				_sw = self._sw,
				_sh = self._sh,
				_keyboard = self._keyboard,
				_controller = self._controller
			}, list_w)
			if global_disabled then
				row:set_dimmed(true)
			end
			self.mod_list:add_row(row)
			self.mod_list:add_row(KView:new(V.v(list_w, 10)))
			self._mod_rows[#self._mod_rows + 1] = row
		end
	end
end

function ModManagerView:_render_store_list()
	self.mod_list:clear_rows()
	local list_w = self.mod_list.size.x - self.mod_list.scroller_width - 2 * self.mod_list.scroller_margin - 4
	for _, item in ipairs(self.store_items) do
		local local_mod = self.local_by_entry[item.entry] or self.local_by_name[item.entry]
		local installed = local_mod ~= nil
		local needs_update = installed and has_update(local_mod.config.version, item.version)
		local status
		if installed then
			if needs_update then
				status = string.format("已安装：v%s（可更新到 v%s）", utf8_util.sanitize(local_mod.config.version), utf8_util.sanitize(item.version))
			else
				status = "已安装且最新"
			end
		else
			status = "未安装"
		end

		local actions = {}
		actions[#actions + 1] = {
			text = "详情",
			on_press = function()
				self:_show_store_mod_detail(item)
			end
		}
		actions[#actions + 1] = {
			text = installed and (needs_update and "更新" or "重装") or "安装",
			on_press = function()
				self:_start_task("安装插件", function()
					return self:_install_or_update_item(item)
				end)
			end
		}
		if installed then
			actions[#actions + 1] = {
				text = "删除",
				on_press = function()
					self:_start_task("删除插件", function()
						local ok, err = self:_delete_local_mod_by_name(local_mod.name)
						if ok then
							self:_set_status("已删除插件：" .. local_mod.name, 0)
							return true, nil
						end
						return false, err
					end)
				end
			}
		end

		local row = ModItemRow:new({
			title = item.name or item.entry,
			meta = string.format("v%s  下载:%s  作者:%s", utf8_util.sanitize(item.version), utf8_util.sanitize(item.downloads), utf8_util.sanitize(item.by)),
			desc = item.desc or "",
			status = status,
			show_toggle = false,
			action_button_size = self._row_action_button_size,
			status_width = self._row_status_width,
			right_pad = self._row_right_pad,
			action_bottom_margin = self._row_action_bottom_margin,
			actions = actions
		}, list_w)
		self.mod_list:add_row(row)
		self.mod_list:add_row(KView:new(V.v(list_w, 10)))
	end
end

function ModManagerView:_render_current_list()
	self._disabled_warning.hidden = self.global_toggle.value
	if self.mode == "store" then
		self:_render_store_list()
	else
		self:_render_local_list()
	end
	self:_sanitize_view_texts(self.back)
	self:_refresh_header_buttons()
end

function ModManagerView:_sanitize_view_texts(view)
	if not view then
		return
	end
	if type(view.text) == "string" then
		view.text = utf8_util.sanitize(view.text)
	end
	if type(view._text) == "string" then
		view._text = utf8_util.sanitize(view._text)
	end
	local children = view.children
	if type(children) == "table" then
		for _, child in pairs(children) do
			self:_sanitize_view_texts(child)
		end
	end
end

function ModManagerView:show()
	mod_paths.ensure_storage_ready()
	self._unsaved_changes = false
	self:_start_http_thread()
	-- 从磁盘读取初始状态，但仅在此处（后续 _reload_local_mods 不会覆盖用户未保存的修改）
	local cfg = mod_paths.load_main_config()
	local saved_cb = self.global_toggle.on_change
	self.global_toggle.on_change = nil
	self.global_toggle:set_value(cfg.enabled ~= false)
	self.global_toggle.on_change = saved_cb
	self:_reload_local_mods()
	self:_capture_state()
	self:_render_current_list()
	self.task_dialog.hidden = true
	self._category_panel.hidden = true
	self:_set_status("前往插件商店后会自动拉取第一页", 0)
	self:_sanitize_view_texts(self.back)
	ModManagerView.super.show(self)
end

function ModManagerView:hide()
	if self._unsaved_changes then
		self._confirm_dialog.hidden = false
		self._confirm_dialog:order_to_front()
		return
	end
	self._cancel_requested = true
	self:_stop_http_thread()
	ModManagerView.super.hide(self)
end

function ModManagerView:update(dt)
	ModManagerView.super.update(self, dt)
	if self._pending_close then
		self._pending_close = false
		self:hide()
		return
	end
	self:_sanitize_view_texts(self.back)
	self:_render_progress()
	if not self._active_task then
		if self._cover_yes_btn.hidden and self._cover_no_btn.hidden then
			self.task_dialog.hidden = true
		end
		return
	end
	local ok, result = coroutine.resume(self._active_task)
	if not ok then
		self._active_task = nil
		self.task_dialog.hidden = true
		self:_set_status("操作失败：" .. tostring(result), 0)
		log.error("mod manager task failed: %s", tostring(result))
		self:_refresh_header_buttons()
		return
	end
	if coroutine.status(self._active_task) == "dead" then
		self._active_task = nil
		self.task_dialog.hidden = true
		self._task_result = result
		if result and result.ok then
			if self._cancel_requested then
				self:_set_status("操作已断开", 0)
			end
		else
			self:_set_status("操作失败：" .. tostring(result and result.err or "unknown"), 0)
		end
		self._cancel_requested = false
		self:_refresh_header_buttons()
	end
end

function ModManagerView:_reset_cover_prompt()
	self._upload_pending_data = nil
	self._upload_pending_cover = nil
	self._cover_yes_btn.hidden = true
	self._cover_no_btn.hidden = true
	self._confirm_cancel_btn.hidden = true
	self.task_cancel_btn.hidden = false
	self._cover_yes_btn:set_text("上传封面")
end

function ModManagerView:_show_local_mod_detail(mod_data)
	-- 读取本地 README.md
	local readme_path = mod_data.path .. "/README.md"
	local content = nil
	local fallback = mod_data.config.desc or "暂无说明文档"
	if FS.getInfo(readme_path, "file") then
		content = FS.read(readme_path) or nil
	end
	if not content or content == "" then
		content = nil
	end

	local detail = markdown_view:new(self._sw, self._sh, mod_data.config.name or mod_data.name, content, fallback)
	self:add_child(detail)
	detail:show()
end

function ModManagerView:_show_store_mod_detail(item)
	-- 网络获取商店插件的 README
	self:_start_task("获取插件详情", function()
		local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
		if not base then
			return false, "无法选择插件商店地址"
		end
		local entry = utf8_util.sanitize(item.entry or "")
		if entry == "" then
			return false, "插件缺少 entry 字段"
		end

		local url = base .. "/" .. url_encode(entry) .. "/readme"
		self:_set_status("正在获取插件详情：" .. (item.name or item.entry), 50)
		local resp, err = self:_request(url, {
			method = "GET"
		}, 20)
		if err then
			return false, "获取详情失败：" .. err
		end
		if tonumber(resp.code) ~= 200 then
			-- 可能没有 README，使用 item.desc 作为备选
			self:_set_status("插件无 README 文档", 100)
			local detail = markdown_view:new(self._sw, self._sh, item.name or item.entry, nil, item.desc or "暂无说明文档")
			self:add_child(detail)
			detail:show()
			return true, nil
		end

		local content = resp.body or ""
		if content == "" then
			content = nil
		end
		self:_set_status("已获取详情", 100)
		local detail = markdown_view:new(self._sw, self._sh, item.name or item.entry, content, item.desc or "暂无说明文档")
		self:add_child(detail)
		detail:show()
		return true, nil
	end)
end

function ModManagerView:_handle_upload_plugin(mod_data)
	local cover_name = nil
	local items = FS.getDirectoryItems(mod_data.path) or {}
	for _, name in ipairs(items) do
		if name:lower():match("^cover%.") then
			cover_name = name
			break
		end
	end

	self._upload_pending_data = mod_data
	self._upload_pending_cover = cover_name
	self.task_dialog.hidden = false
	self.task_cancel_btn.hidden = true
	self._confirm_cancel_btn.hidden = false
	self.progress_fill.shape.args[4] = 0
	self.progress_fill.size = V.v(0, self.progress_fill.size.y)

	if cover_name then
		self.task_title_lbl.text = "上传插件"
		self.task_status_lbl.text = "检测到封面文件 " .. cover_name .. "，是否上传？"
		self._cover_yes_btn:set_text("上传封面")
		self._cover_yes_btn.hidden = false
		self._cover_no_btn.hidden = false
	else
		self.task_title_lbl.text = "上传插件"
		self.task_status_lbl.text = "确认上传 " .. (mod_data.config.name or mod_data.name) .. " 到商店？"
		self._cover_yes_btn:set_text("确认上传")
		self._cover_yes_btn.hidden = false
		self._cover_no_btn.hidden = true
	end

	local visible = {}
	if not self._cover_yes_btn.hidden then
		visible[#visible + 1] = self._cover_yes_btn
	end
	if not self._cover_no_btn.hidden then
		visible[#visible + 1] = self._cover_no_btn
	end
	if not self._confirm_cancel_btn.hidden then
		visible[#visible + 1] = self._confirm_cancel_btn
	end
	local total_w = #visible * self._confirm_btn_w + (#visible - 1) * self._confirm_btn_gap
	local x = self.task_dialog.size.x - total_w - 12
	for _, btn in ipairs(visible) do
		btn.pos = V.v(x, self.task_dialog.size.y - self._confirm_btn_h - 12)
		x = x + self._confirm_btn_w + self._confirm_btn_gap
	end
end

function ModManagerView:_developer_login()
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return false, "无法选择插件商店地址"
	end

	self:_set_status("正在登录开发者账户…", 5)
	local resp, err = self:_request(base .. "/login", {
		method = "POST",
		headers = {
			["Content-Type"] = "application/json"
		},
		data = json.encode({
			username = self._developer_config.account,
			password = self._developer_config.password
		})
	}, 15)

	if err then
		return false, "登录失败：" .. err
	end
	if tonumber(resp.code) ~= 200 then
		return false, "登录失败：HTTP " .. tostring(resp.code) .. " " .. tostring(resp.body)
	end

	local ok, body = pcall(json.decode, resp.body)
	if not ok or not body.token then
		return false, "登录响应解析失败"
	end

	self._developer_token = body.token
	return true, nil
end

function ModManagerView:_upload_plugin(mod_data, upload_cover)
	if not self._developer_token then
		local ok, err = self:_developer_login()
		if not ok then
			return false, err
		end
	end

	local entry = mod_data.config.entry or mod_data.name
	self:_set_status("正在打包插件：" .. entry, 10)

	local cover_data = nil
	local cover_ext = nil
	if upload_cover then
		local items = FS.getDirectoryItems(mod_data.path) or {}
		for _, name in ipairs(items) do
			if name:lower():match("^cover%.") then
				cover_data = FS.read(mod_data.path .. "/" .. name)
				cover_ext = name:match("%.([^%.]+)$")
				break
			end
		end
	end

	self:_set_status("正在压缩插件：" .. entry, 20)
	local zip_data = zip.create_from_dir(mod_data.path, {
		exclude = {"^cover%..+$"},
		skip_dirs = {".git", ".backup", ".tmp"}
	})
	if not zip_data then
		return false, "打包插件失败：目录为空"
	end

	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return false, "无法选择插件商店地址"
	end

	self:_set_status("正在上传插件：" .. entry, 40)
	local resp, err = self:_request(base .. "/upload", {
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. self._developer_token,
			["Content-Type"] = "application/octet-stream"
		},
		data = zip_data
	}, 60)

	if err then
		return false, "上传失败：" .. err
	end
	if tonumber(resp.code) ~= 200 then
		return false, "上传失败：HTTP " .. tostring(resp.code) .. " " .. tostring(resp.body)
	end

	local ok, body = pcall(json.decode, resp.body)
	if not ok or not body.entry then
		return false, "上传响应解析失败"
	end

	self:_set_status("已上传插件，正在处理…", 80)

	if cover_data and cover_ext then
		self:_set_status("正在上传封面…", 90)
		local mime = "application/octet-stream"
		if cover_ext == "png" then
			mime = "image/png"
		elseif cover_ext == "jpg" or cover_ext == "jpeg" then
			mime = "image/jpeg"
		elseif cover_ext == "gif" then
			mime = "image/gif"
		elseif cover_ext == "webp" then
			mime = "image/webp"
		end
		local cover_resp, cover_err = self:_request(base .. "/" .. url_encode(entry) .. "/cover", {
			method = "POST",
			headers = {
				["Authorization"] = "Bearer " .. self._developer_token,
				["Content-Type"] = mime
			},
			data = cover_data
		}, 30)

		if cover_err then
			self:_refresh_local_view("插件上传成功，但封面上传失败：" .. cover_err)
			return true, nil
		end
		if tonumber(cover_resp.code) ~= 200 then
			self:_refresh_local_view("插件上传成功，但封面上传失败：HTTP " .. tostring(cover_resp.code))
			return true, nil
		end
	end

	self:_refresh_local_view("上传成功：" .. entry)
	return true, nil
end

function ModManagerView:_capture_state()
	self._saved_state = {
		global_enabled = self.global_toggle.value,
		mod_enabled = {}
	}
	for _, mod_data in ipairs(self.local_mods) do
		self._saved_state.mod_enabled[mod_data.name] = mod_data.config.enabled ~= false
	end
	self._unsaved_changes = false
end

function ModManagerView:_check_unsaved()
	if self.global_toggle.value ~= self._saved_state.global_enabled then
		return true
	end
	for _, mod_data in ipairs(self.local_mods) do
		local saved = self._saved_state.mod_enabled[mod_data.name]
		if saved ~= nil and (mod_data.config.enabled ~= false) ~= saved then
			return true
		end
	end
	return false
end

function ModManagerView:save()
	local base_cfg = mod_paths.load_main_config()
	base_cfg.enabled = self.global_toggle.value
	local ok = storage:write_lua(mod_paths.MAIN_CONFIG_PATH, base_cfg)
	if not ok then
		log.error("写入 %s 失败", mod_paths.MAIN_CONFIG_PATH)
	end

	for _, mod_data in ipairs(self.local_mods) do
		local cfg = mod_data.config or {}
		local out = {}
		for k, v in pairs(cfg) do
			out[k] = v
		end
		out.enabled = cfg.enabled ~= false
		if out.enabled then
			out.last_used_at = os.time()
		end
		local wok = storage:write_lua(mod_data.config_path, out)
		if not wok then
			log.error("写入 %s 失败", mod_data.config_path)
		end
	end
	self:_capture_state()
end

function ModManagerView:destroy()
	self:_stop_http_thread()
end

return ModManagerView
