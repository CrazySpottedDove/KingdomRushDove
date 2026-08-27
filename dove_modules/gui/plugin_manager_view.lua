-- chunkname: @./all-desktop/plugin_manager_view.lua
-- 插件管理器 + 插件商店（游戏内）
local log = require("lib.klua.log"):new("plugin_manager_view")
local class = require("middleclass")
local V = require("lib.klua.vector")
local FS = love.filesystem
local S = require("sound_db")
local restart = require("all.restart")
local storage = require("all.storage")
local json = require("lib.json")
local persistence = require("lib.klua.persistence")
local plugin_paths = require("plugin_paths")
local plugin_main = require("plugin.plugin_main")
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
	label = "关卡",
	value = "level"
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
local req_ch = love.thread.getChannel("plugin_store_http_req")
local resp_ch = love.thread.getChannel("plugin_store_http_resp")
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

local preserved_keys = table.to_map({"__default_config", "key_label_map", "key_order_list"})

-- 提取配置中的默认数值（排除保留字段本身）
local function extract_default_config(cfg)
	local default = {}
	for k, v in pairs(cfg or {}) do
		if not preserved_keys[k] then
			default[k] = table.deepclone(v)
		end
	end
	return default
end

-- 依据 __default_config 合并远端新配置到本地旧配置：
-- 若本地某条配置与旧的默认配置相同（用户未自定义），且新版本默认值已变化，则采用新版本默认值；
-- 用户自定义过的字段则保留本地值；本地新增字段也保留。
-- 旧版本插件没有 __default_config 记录时，沿用 merge_missing_or_mismatch_fields 策略保留用户配置。
local function merge_plugin_config_with_defaults(preserved_local_cfg, remote_cfg)
	local old_default = preserved_local_cfg and preserved_local_cfg.__default_config
	local new_default = extract_default_config(remote_cfg)

	local result
	if type(old_default) ~= "table" then
		-- 本地不存在默认配置数据：无法判断用户是否自定义，保留本地配置并补充新增字段
		result = table.deepclone(preserved_local_cfg or {})
		merge_missing_or_mismatch_fields(result, remote_cfg)
	else
		result = table.deepclone(remote_cfg)
		for k, v in pairs(preserved_local_cfg) do
			if not preserved_keys[k] then
				if old_default[k] == nil then
					-- 用户新增字段，保留
					result[k] = table.deepclone(v)
				elseif not deep_equal(v, old_default[k]) then
					-- 用户自定义过，保留用户值
					result[k] = table.deepclone(v)
				end
			-- 其余：用户未修改，采用新版本默认值
			end
		end
	end

	result.__default_config = new_default
	return result
end

-- 本地配置文件缺少 __default_config 记录时，自动生成并保存
local function ensure_default_config_recorded(config_path)
	local cfg = plugin_paths.load_lua_table(config_path)
	if not cfg or type(cfg) ~= "table" then
		return
	end
	if type(cfg.__default_config) == "table" then
		return
	end
	cfg.__default_config = extract_default_config(cfg)
	storage:write_lua(config_path, cfg)
end

local function url_encode(str)
	return (str:gsub("([^%w%-%.%_%~%/])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function get_platform()
	local os = love.system.getOS()
	if os == "Android" then
		return "android"
	elseif os == "Linux" then
		return "linux"
	elseif os == "OS X" then
		return "macos"
	end
	return "windows"
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

require("dove_modules.gui.plugin_manager_components")

-- ─────────────────────────────────────────────
-- 下拉选择面板公共辅助函数
-- ─────────────────────────────────────────────
local function create_dropdown(self, cfg)
	local panel = KView:new(V.v(cfg.width, cfg.height))
	panel.colors.background = {35, 25, 12, 240}
	panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, cfg.width, cfg.height, 10, 10}
	}
	panel.hidden = true
	self.back:add_child(panel)
	panel.pos = V.v(cfg.x, cfg.y)

	local cols = cfg.columns or 1
	local gap = cfg.gap or 6
	local pad = cfg.pad or 12
	local btn_h = cfg.btn_h or 32
	local btn_w
	if cols > 1 then
		btn_w = math.floor((cfg.width - pad * 2 - gap * (cols - 1)) / cols)
	else
		btn_w = cfg.width - pad * 2
	end

	local buttons = {}
	for i, opt in ipairs(cfg.options) do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local bx = pad + col * (btn_w + gap)
		local by = pad + row * (btn_h + gap)

		local btn = PluginActionButton:new(opt.label, V.v(btn_w, btn_h))
		btn.pos = V.v(bx, by)

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
			if cfg.get_idx() == i then
				panel.hidden = true
				return
			end
			cfg.set_idx(i)
			cfg.on_select()
			panel.hidden = true
		end

		panel:add_child(btn)
		buttons[i] = btn
	end
	return panel, buttons
end

local function refresh_dropdown(buttons, get_idx)
	if not buttons then
		return
	end
	for i, btn in ipairs(buttons) do
		local selected = i == get_idx()
		btn._is_selected = selected
		btn:_refresh()
		if selected then
			btn.colors.background = {35, 148, 68, 215}
			btn._label.colors.text = {195, 255, 178, 255}
		end
	end
end

local function toggle_dropdown(panel, other_panel, buttons, get_idx)
	if not panel then
		return
	end
	if panel.hidden then
		if other_panel then
			other_panel.hidden = true
		end
		refresh_dropdown(buttons, get_idx)
		panel.hidden = false
		panel:order_to_front()
	else
		panel.hidden = true
	end
end

PluginManagerView = class("PluginManagerView", PopUpView)

function PluginManagerView:initialize(sw, sh, keyboard, controller)
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
	-- 供下载任务管理视图复用同一套动态布局（随屏幕缩放，与主面板一致）
	self._panel_w = panel_w
	self._panel_h = panel_h
	self._dl_touch_scale = touch_scale
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
	-- 商店搜索行（store 模式显示）：sep 下方独立一行
	local search_h = math.floor(32 * touch_scale + 0.5)
	local search_y = sep_y + 8
	local hint_y = search_y + search_h + 6
	local pager_y = hint_y + math.max(0, math.floor((hint_h - pager_btn_h) / 2))
	local list_top_y = math.max(LIST_TOP_Y, hint_y + hint_h + 10)
	local footer_y = panel_h - 44
	local scroll_h = math.max(260, footer_y - list_top_y - 14)
	local header_group_x = panel_w - 20 - (header_btn_w * 4 + header_btn_gap * 3)
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
	self._uninstalled_only = true -- 商店默认只看未安装
	self._search_query = ""
	self.store_page = 1
	self.store_total_pages = 1
	self.store_items = {}
	self._store_page_cache = {}
	self._remote_entry_cache = {}
	self._remote_lookup_done = false
	self.remote_by_entry = self._remote_entry_cache
	self.local_plugins = {}
	self.local_by_entry = {}
	self.local_by_name = {}
	self._plugin_rows = {}
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
	-- 下载任务队列（串行）：_dl_queue 是 FIFO 队列，_dl_running 是当前执行中的任务
	self._dl_queue = {}
	self._dl_running = nil
	self._dl_seq = 0
	self._dl_view_open = false
	self._dl_view_dirty = false
	self._dl_row_by_id = {}
	self._unsaved_changes = false
	self._pending_close = false
	self._saved_state = {}
	-- 本次打开期间的修改记忆（点「应用」或关闭管理器后清空，避免下次打开污染）：
	--   plugins[name] = {config_changed = bool, config = table}  待应用的插件配置修改（延迟写盘）
	--   deleted[name] = plugin_data                               本会话已删除的插件（运行中则应用时重启）
	--   updated[name] = true                                      本会话已更新的插件（运行中则应用时重启）
	self._pending = {
		plugins = {},
		deleted = {},
		updated = {}
	}

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

	self.global_toggle = PluginToggleButton:new(false, V.v(global_toggle_w, global_toggle_h))
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
		local btn = PluginActionButton:new(text, V.v(w, h))
		btn.pos = V.v(x, y)
		self.back:add_child(btn)
		return btn
	end

	self.mode_btn = header_btn("前往商店", header_group_x, header_top_y)
	self.mode_btn.on_press = function()
		self._category_panel.hidden = true
		self._sort_panel.hidden = true
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
		self:_toggle_sort_panel()
	end

	self.category_btn = header_btn("分类：全部", header_group_x + (header_btn_w + header_btn_gap) * 2, header_top_y)
	self.category_btn.on_press = function()
		self:_toggle_category_panel()
	end

	self.uninstalled_btn = header_btn("只看未安装", header_group_x + (header_btn_w + header_btn_gap) * 3, header_top_y)
	self.uninstalled_btn.on_press = function()
		self._uninstalled_only = not self._uninstalled_only
		self:_refresh_header_buttons()
		if self.mode == "store" then
			self.store_page = 1
			self:_start_task("刷新商店列表", function()
				return self:_fetch_store_list()
			end)
		end
	end

	-- 排序选择下拉面板
	local sort_btn_x = header_group_x + header_btn_w + header_btn_gap
	local sort_panel_x = math.max(20, sort_btn_x)
	self._sort_panel, self._sort_buttons = create_dropdown(self, {
		options = SORT_OPTIONS,
		width = 220,
		height = 3 * 38 + 18,
		x = sort_panel_x,
		y = sep_y + 2,
		pad = 9,
		btn_h = 32,
		get_idx = function()
			return self.sort_idx
		end,
		set_idx = function(v)
			self.sort_idx = v
		end,
		on_select = function()
			self.store_page = 1
			self:_refresh_header_buttons()
			if self.mode == "store" then
				self:_start_task("刷新商店列表", function()
					return self:_fetch_store_list()
				end)
			end
		end
	})

	-- 分类选择下拉面板
	local cat_panel_x = math.max(20, panel_w - 20 - 380)
	self._category_panel, self._category_buttons = create_dropdown(self, {
		options = CATEGORY_OPTIONS,
		width = 380,
		height = 180,
		x = cat_panel_x,
		y = sep_y + 2,
		columns = 2,
		pad = 12,
		btn_h = 32,
		get_idx = function()
			return self.category_idx
		end,
		set_idx = function(v)
			self.category_idx = v
		end,
		on_select = function()
			self.store_page = 1
			self:_refresh_header_buttons()
			if self.mode == "store" then
				self:_start_task("刷新商店列表", function()
					return self:_fetch_store_list()
				end)
			else
				self:_render_current_list()
			end
		end
	})

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
		self:_update_all_plugins()
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

	self.dl_manager_btn = header_btn("下载管理", header_group_x + (header_btn_w + header_btn_gap) * 3, header_row2_y)
	self.dl_manager_btn.on_press = function()
		self:_toggle_dl_view()
	end

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

	-- 商店搜索框（store 模式显示；本地模式隐藏）
	local search_box_w = math.floor(340 * touch_scale + 0.5)
	self.search_box = PluginSearchBox:new({
		width = search_box_w,
		height = search_h,
		controller = self._controller,
		placeholder = "搜索插件（支持中文）",
		on_change = function(text)
			self._search_query = text
			-- 本地模式过滤无网络成本，输入即生效；商店模式等待回车提交
			if self.mode == "local" then
				self:_render_current_list()
			end
		end,
		on_submit = function(text)
			self:_on_search_submit(text)
		end
	})
	self.search_box.pos = V.v(20, search_y)
	self.back:add_child(self.search_box)

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
	self.task_cancel_btn = PluginActionButton:new("断开请求", V.v(task_btn_w, task_btn_h))
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
	self._cover_yes_btn = PluginActionButton:new("上传封面", V.v(cover_btn_w, task_btn_h))
	self._cover_yes_btn.on_press = function()
		S:queue("GUIButtonCommon")
		local plugin_data = self._upload_pending_data
		local has_cover = self._upload_pending_cover ~= nil
		self:_reset_cover_prompt()
		if plugin_data then
			self:_start_task("上传插件", function()
				return self:_upload_plugin(plugin_data, has_cover)
			end)
		end
	end
	self._cover_yes_btn.hidden = true
	self.task_dialog:add_child(self._cover_yes_btn)

	self._cover_no_btn = PluginActionButton:new("跳过封面", V.v(cover_btn_w, task_btn_h))
	self._cover_no_btn.on_press = function()
		S:queue("GUIButtonCommon")
		local plugin_data = self._upload_pending_data
		self:_reset_cover_prompt()
		if plugin_data then
			self:_start_task("上传插件", function()
				return self:_upload_plugin(plugin_data, false)
			end)
		end
	end
	self._cover_no_btn.hidden = true
	self.task_dialog:add_child(self._cover_no_btn)

	self._confirm_cancel_btn = PluginActionButton:new("取消", V.v(cover_btn_w, task_btn_h))
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

	self.plugin_list = KScrollList:new(V.v(panel_w - 40, scroll_h))
	self.plugin_list.pos = V.v(20, list_top_y)
	self.plugin_list.drag_scroll_threshold = IS_ANDROID and 20 or 6
	self.plugin_list.scroll_amount = ROW_H
	self.plugin_list.colors.scroller_background = {45, 36, 22, 200}
	self.plugin_list.colors.scroller_foreground = {110, 90, 50, 255}
	-- 加宽滑块
	self.plugin_list.scroller_width = 24
	self.back:add_child(self.plugin_list)

	-- 底部按钮（应用 / 浏览器商店 / 关闭）
	local y_btn = footer_y
	local save_btn = GGOptionsButton:new("应用")
	save_btn:set_anchor_to_center()
	save_btn.pos = V.v(panel_w / 3, y_btn)
	self.back:add_child(save_btn)
	save_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:apply()
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
			local btn = PluginActionButton:new(b.text, V.v(bw, bh))
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
		text = "应用",
		y = row_y1,
		action = function()
			self._confirm_dialog.hidden = true
			-- 应用成功会通过 _pending_close 自动关闭；不可热重载时走重启逻辑
			self:apply()
		end
	}, {
		text = "直接退出",
		y = row_y1,
		action = function()
			self._confirm_dialog.hidden = true
			-- 舍弃本次全部修改（含未应用的插件配置，配置不写盘）
			self:_clear_pending_changes()
			self._unsaved_changes = false
			self._pending_close = true
		end
	}})

	center_row({{
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

function PluginManagerView:_start_http_thread()
	if self._http_thread then
		return
	end
	local req_ch = love.thread.getChannel("plugin_store_http_req")
	local resp_ch = love.thread.getChannel("plugin_store_http_resp")
	while req_ch:getCount() > 0 do
		req_ch:pop()
	end
	while resp_ch:getCount() > 0 do
		resp_ch:pop()
	end
	self._http_thread = love.thread.newThread(HTTP_WORKER)
	self._http_thread:start()
end

function PluginManagerView:_stop_http_thread()
	if not self._http_thread then
		return
	end
	love.thread.getChannel("plugin_store_http_req"):push("quit")
	self._http_thread:wait()
	self._http_thread = nil
end

function PluginManagerView:_refresh_header_buttons()
	self.mode_btn:set_text(self.mode == "local" and "前往商店" or "回到本地")
	self.sort_btn:set_text("排序：" .. SORT_OPTIONS[self.sort_idx].label)
	self.category_btn:set_text("分类：" .. CATEGORY_OPTIONS[self.category_idx].label)
	if self._uninstalled_only then
		self.uninstalled_btn:set_text("只看未安装")
		self.uninstalled_btn.colors.background = {161, 122, 45, 245}
		self.uninstalled_btn._label.colors.text = {255, 240, 190, 255}
	else
		self.uninstalled_btn:set_text("显示全部")
		self.uninstalled_btn:_refresh()
	end
	local in_store = self.mode == "store"
	self.uninstalled_btn.hidden = not in_store
	-- 搜索框常驻：商店模式搜索远端，本地模式过滤本地
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

function PluginManagerView:_toggle_sort_panel()
	toggle_dropdown(self._sort_panel, self._category_panel, self._sort_buttons, function()
		return self.sort_idx
	end)
end

function PluginManagerView:_refresh_sort_buttons_highlight()
	refresh_dropdown(self._sort_buttons, function()
		return self.sort_idx
	end)
end

function PluginManagerView:_toggle_category_panel()
	toggle_dropdown(self._category_panel, self._sort_panel, self._category_buttons, function()
		return self.category_idx
	end)
end

function PluginManagerView:_refresh_category_buttons_highlight()
	refresh_dropdown(self._category_buttons, function()
		return self.category_idx
	end)
end

function PluginManagerView:_set_status(text, progress)
	self._status_text = utf8_util.sanitize(text or "")
	self.hint_lbl.text = self._status_text
	if self.task_status_lbl then
		self.task_status_lbl.text = self._status_text
	end
	if progress ~= nil then
		self._progress_target = math.max(0, math.min(100, progress))
	end
end

function PluginManagerView:_render_progress()
	self._progress_value = self._progress_value + (self._progress_target - self._progress_value) * 0.2
	local w = (self.progress_bg.size.x) * (self._progress_value / 100)
	self.progress_fill.shape.args[4] = w
	self.progress_fill.size = V.v(w, self.progress_fill.size.y)
end

function PluginManagerView:_request(url, options, timeout_sec, cancel_fn)
	timeout_sec = timeout_sec or 20
	self._request_id = self._request_id + 1
	local req_id = self._request_id
	local req_ch = love.thread.getChannel("plugin_store_http_req")
	local resp_ch = love.thread.getChannel("plugin_store_http_resp")
	req_ch:push({
		id = req_id,
		url = url,
		options = options
	})

	local start_t = love.timer.getTime()
	while true do
		if self._cancel_requested or (cancel_fn and cancel_fn()) then
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

function PluginManagerView:_select_store_base_url()
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

function PluginManagerView:_decode_store_page(body, fallback_page)
	local items = body.items or {}
	local filtered = {}
	local by_entry = {}
	for _, item in ipairs(items) do
		filtered[#filtered + 1] = item
		if item.entry and not by_entry[item.entry] then
			by_entry[item.entry] = item
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

--- 构造「只看未安装」的 exclude 查询参数（本地已安装 entry 逗号连接）
---@return string 空串或 "&exclude=..."
function PluginManagerView:_build_exclude_param()
	if not self._uninstalled_only then
		return ""
	end
	local entries = {}
	for entry, _ in pairs(self.local_by_entry) do
		entries[#entries + 1] = entry
	end
	if #entries == 0 then
		return ""
	end
	return "&exclude=" .. url_encode(table.concat(entries, ","))
end

function PluginManagerView:_get_store_page(base, sort_val, category_val, page, use_cache)
	local exclude_param = self:_build_exclude_param()
	local q_param = ""
	if self._search_query and self._search_query ~= "" then
		q_param = "&q=" .. url_encode(self._search_query)
	end
	local key = table.concat({base or "", sort_val or "", category_val or "", tostring(page or 1), tostring(STORE_PAGE_SIZE), exclude_param, q_param}, "::")
	if use_cache ~= false and self._store_page_cache[key] then
		return true, self._store_page_cache[key], true
	end

	local url = string.format("%s/list?page=%d&page_size=%d&sort=%s&category=%s%s%s", base, page, STORE_PAGE_SIZE, sort_val, category_val, exclude_param, q_param)
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

--- 搜索提交（回车）：商店模式请求远端，本地模式重绘本地过滤
function PluginManagerView:_on_search_submit(text)
	self._search_query = text
	if self.mode == "store" then
		self.store_page = 1
		self:_start_task("搜索插件", function()
			return self:_fetch_store_list()
		end)
	else
		self:_render_current_list()
	end
end

function PluginManagerView:_fetch_store_list()
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

function PluginManagerView:_fetch_remote_entries_for_local()
	self._cancel_requested = false
	if #self.local_plugins == 0 then
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

	-- 收集需要查询的 entry（去重），已命中缓存的直接计入
	local target_entries = {}
	local pending = {}
	for _, plugin_data in ipairs(self.local_plugins) do
		local entry = utf8_util.sanitize(plugin_data.entry)
		if entry ~= "" and not target_entries[entry] then
			target_entries[entry] = true
			if not self._remote_entry_cache[entry] then
				pending[#pending + 1] = entry
			end
		end
	end
	local total_targets = 0
	for _ in pairs(target_entries) do
		total_targets = total_targets + 1
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

	-- 批量查询：一次请求查询一批 entry，替代逐页翻完整个商店（减轻服务器带宽压力）
	local BATCH_SIZE = 100
	for i = 1, #pending, BATCH_SIZE do
		if self._cancel_requested then
			return false, "cancelled"
		end
		local batch = {}
		local batch_end = math.min(i + BATCH_SIZE - 1, #pending)
		for j = i, batch_end do
			batch[#batch + 1] = pending[j]
		end
		self:_set_status(string.format("正在批量查询远端条目…（%d/%d）", i, #pending), 5)
		local resp, err = self:_request(base .. "/entries", {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			data = json.encode({
				entries = batch
			})
		}, 30)
		if err then
			return false, "批量查询失败：" .. err
		end
		if tonumber(resp.code) ~= 200 then
			return false, "批量查询失败：HTTP " .. tostring(resp.code)
		end
		local ok, body = pcall(json.decode, resp.body)
		if not ok or type(body) ~= "table" or type(body.items) ~= "table" then
			return false, "批量查询响应解析失败"
		end
		for _, item in ipairs(body.items) do
			if item.entry and not self._remote_entry_cache[item.entry] then
				self._remote_entry_cache[item.entry] = item
				found_count = found_count + 1
			end
		end
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

function PluginManagerView:_load_local_plugin(name)
	local dir_path = plugin_paths.LOCAL_PLUGINS_DIR .. "/" .. name
	if not FS.getInfo(dir_path, "directory") then
		return nil
	end
	local config_path = dir_path .. "/config.lua"
	local mc = plugin_paths.load_lua_table(config_path)
	if not mc then
		return nil
	end
	local has_config = false
	local config_info = love.filesystem.getInfo(dir_path .. "/" .. name .. "_config.lua")
	if config_info and config_info.type == "file" then
		has_config = true
	end
	return {
		name = name,
		path = dir_path,
		config_path = config_path,
		config = mc,
		entry = mc.entry or name,
		has_config = has_config
	}
end

function PluginManagerView:_reload_local_plugins()
	plugin_paths.ensure_storage_ready()

	self.local_plugins = {}
	self.local_by_entry = {}
	self.local_by_name = {}

	local plugins_dir = plugin_paths.LOCAL_PLUGINS_DIR
	local items = FS.getDirectoryItems(plugins_dir) or {}
	for _, name in ipairs(items) do
		local plugin_data = self:_load_local_plugin(name)
		if plugin_data then
			self.local_plugins[#self.local_plugins + 1] = plugin_data
			self.local_by_name[name] = plugin_data
			self.local_by_entry[plugin_data.entry] = plugin_data
		end
	end
	self:_sort_local_plugins()
end

function PluginManagerView:_sort_local_plugins()
	table.sort(self.local_plugins, function(a, b)
		local t_a = a.config.last_used_at or 0
		local t_b = b.config.last_used_at or 0
		if t_a ~= t_b then
			return t_a > t_b
		end
		return (a.config.priority or 0) < (b.config.priority or 0)
	end)
end

--- 只刷新指定插件（新增或更新后调用），避免全量 reload 覆盖其他插件未保存的开关状态。
--- 支持传插件目录名或 entry。
function PluginManagerView:_reload_local_plugin(name_or_entry)
	plugin_paths.ensure_storage_ready()
	local old = self.local_by_name[name_or_entry] or self.local_by_entry[name_or_entry]
	local name = old and old.name or name_or_entry

	if old then
		table.removeobject(self.local_plugins, old)
		self.local_by_name[old.name] = nil
		if self.local_by_entry[old.entry] == old then
			self.local_by_entry[old.entry] = nil
		end
	end

	local plugin_data = self:_load_local_plugin(name)
	if plugin_data then
		self.local_plugins[#self.local_plugins + 1] = plugin_data
		self.local_by_name[plugin_data.name] = plugin_data
		self.local_by_entry[plugin_data.entry] = plugin_data
	end

	self:_sort_local_plugins()
end

function PluginManagerView:_refresh_local_view(status_text, target_name)
	if status_text then
		self:_set_status(status_text, 100)
	end
	if target_name then
		self:_reload_local_plugin(target_name)
	else
		self:_reload_local_plugins()
	end
	self:_render_current_list()
	self._unsaved_changes = self:_check_unsaved()
end

function PluginManagerView:_delete_local_plugin_by_name(plugin_name)
	local plugin_data = self.local_by_name[plugin_name]
	if not plugin_data then
		return false, "本地插件不存在"
	end
	-- 记忆删除：点「应用」时若插件仍在运行（文件已移除），无法安全热应用，直接重启
	self._pending.deleted[plugin_name] = plugin_data
	local ok = remove_dir_recursive(plugin_data.path)
	if not ok then
		return false, "删除失败：" .. plugin_data.path
	end
	-- 只从内存中移除该插件，保留其他插件尚未落盘的开关修改；
	-- 不需要重新扫描磁盘导致未保存的开关状态被覆盖。
	self._pending.plugins[plugin_name] = nil
	table.removeobject(self.local_plugins, plugin_data)
	self.local_by_name[plugin_name] = nil
	if self.local_by_entry[plugin_data.entry] == plugin_data then
		self.local_by_entry[plugin_data.entry] = nil
	end
	self:_render_current_list()
	self._unsaved_changes = self:_check_unsaved()
	return true, nil
end

function PluginManagerView:_download_zip(item, task)
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return nil, "无法选择插件商店地址"
	end
	local filename = item.filename
	if not filename or filename == "" then
		return nil, "插件缺少下载文件名"
	end
	local url = base .. "/download/" .. url_encode(filename) .. "?platform=" .. get_platform()
	local chunk_size = 256 * 1024
	local chunks = {}
	local downloaded = 0
	local total = nil
	self._active_download_name = item.name or item.entry or filename

	local function is_cancelled()
		return (task and task.cancelled) or self._cancel_requested
	end

	while not total or downloaded < total do
		if is_cancelled() then
			if task then
				task.progress = 0
			end
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
		}, 120, function()
			return task and task.cancelled
		end)
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
		if task then
			task.progress = percent
		end
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

function PluginManagerView:_collect_plugin_root_candidates(base_dir)
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

function PluginManagerView:_install_plugin(item, is_update, task)
	self:_set_status((is_update and "正在更新插件：" or "正在安装插件：") .. (item.name or item.entry), 0)
	local zip_data, err = self:_download_zip(item, task)
	if not zip_data then
		return false, err
	end
	if (task and task.cancelled) or self._cancel_requested then
		return false, "cancelled"
	end

	local entry = utf8_util.sanitize(item.entry or "")
	local stage_root = "tmp/plugin_store_stage/" .. (entry ~= "" and entry or ("pkg_" .. tostring(os.time())))
	remove_dir_recursive("tmp/plugin_store_stage")
	FS.createDirectory("tmp")
	FS.createDirectory("tmp/plugin_store_stage")
	FS.createDirectory(stage_root)

	self:_set_status("正在解压插件：" .. (item.name or item.entry), 92)
	if task then
		task.progress = 92
	end
	local ok, unzip_err = zip.unzip_to_dir(zip_data, stage_root)
	if not ok then
		return false, unzip_err
	end

	local candidates = self:_collect_plugin_root_candidates(stage_root)
	local selected_dir = nil
	for _, c in ipairs(candidates) do
		local cfg = plugin_paths.load_lua_table(c .. "/config.lua")
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
	local target_dir = plugin_paths.LOCAL_PLUGINS_DIR .. "/" .. target_name
	local local_plugin = nil
	local preserved_enabled = nil
	local preserved_local_config = nil
	if is_update then
		-- 记忆更新：应用时若该插件正在运行（文件已替换），无法安全热应用，直接重启
		self._pending.updated[target_name] = true
		local_plugin = (entry ~= "" and self.local_by_entry[entry]) or self.local_by_name[target_name]
		if local_plugin and local_plugin.config then
			preserved_enabled = local_plugin.config.enabled ~= false
		else
			local existing_cfg = plugin_paths.load_lua_table(target_dir .. "/config.lua")
			if existing_cfg then
				preserved_enabled = existing_cfg.enabled ~= false
			end
		end

		local local_cfg_path = local_plugin and (local_plugin.path .. "/" .. local_plugin.name .. "_config.lua") or (target_dir .. "/" .. target_name .. "_config.lua")
		if FS.getInfo(local_cfg_path, "file") then
			local local_cfg, read_err = plugin_paths.load_lua_table(local_cfg_path)
			if not local_cfg then
				return false, "更新前读取本地配置失败：" .. local_cfg_path .. " (" .. tostring(read_err) .. ")"
			end
			preserved_local_config = local_cfg
		end
	end
	remove_dir_recursive(target_dir)
	copy_dir_recursive(selected_dir, target_dir)
	if preserved_enabled ~= nil then
		local installed_cfg = plugin_paths.load_lua_table(target_dir .. "/config.lua")
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
		if FS.getInfo(installed_local_cfg_path, "file") then
			local remote_local_cfg, read_err = plugin_paths.load_lua_table(installed_local_cfg_path)
			if not remote_local_cfg then
				return false, "更新后读取远端本地配置失败：" .. installed_local_cfg_path .. " (" .. tostring(read_err) .. ")"
			end
			preserved_local_config = merge_plugin_config_with_defaults(preserved_local_config, remote_local_cfg)
		end
		local wok = storage:write_lua(installed_local_cfg_path, preserved_local_config)
		if not wok then
			return false, "更新后写入本地配置失败：" .. installed_local_cfg_path
		end
	else
		-- 本地不存在配置（或旧配置），为新版本配置记录默认配置数据
		ensure_default_config_recorded(target_dir .. "/" .. target_name .. "_config.lua")
	end
	remove_dir_recursive("tmp/plugin_store_stage")

	local new_cfg = plugin_paths.load_lua_table(target_dir .. "/config.lua")
	if new_cfg then
		new_cfg.last_used_at = os.time()
		storage:write_lua(target_dir .. "/config.lua", new_cfg)
	end

	self:_refresh_local_view((is_update and "插件更新完成：" or "插件安装完成：") .. (item.name or item.entry), target_name)
	self._active_download_name = ""
	if task then
		task.progress = 100
	end
	return true, nil
end

function PluginManagerView:_apply_patch_to_dir(target_dir, patch_data)
	local tmp = "tmp/plugin_patch_apply"
	remove_dir_recursive(tmp)
	FS.createDirectory("tmp")
	FS.createDirectory(tmp)

	local ok, err = zip.unzip_to_dir(patch_data, tmp)
	if not ok then
		remove_dir_recursive(tmp)
		return false, err
	end

	-- 读取 patch manifest
	local patch_manifest_data = FS.read(tmp .. "/_patch_manifest.json")
	local deleted_files = {}
	if patch_manifest_data then
		local ok_m, manifest = pcall(json.decode, patch_manifest_data)
		if ok_m and type(manifest) == "table" and type(manifest.deleted) == "table" then
			deleted_files = manifest.deleted
		end
	end

	-- 覆盖变更文件（跳过 manifest 文件本身）
	local items = FS.getDirectoryItems(tmp) or {}
	for _, name in ipairs(items) do
		if name == "_patch_manifest.json" then
			goto continue
		end
		local src = tmp .. "/" .. name
		local info = FS.getInfo(src)
		if info then
			local dst = target_dir .. "/" .. name
			local function cp_dir(s, d)
				if not FS.getInfo(d, "directory") then
					FS.createDirectory(d)
				end
				local subs = FS.getDirectoryItems(s) or {}
				for _, sub in ipairs(subs) do
					local ss = s .. "/" .. sub
					local sd = d .. "/" .. sub
					local si = FS.getInfo(ss)
					if si then
						if si.type == "directory" then
							cp_dir(ss, sd)
						else
							local data = FS.read(ss)
							if data then
								FS.write(sd, data)
							end
						end
					end
				end
			end
			if info.type == "directory" then
				cp_dir(src, dst)
			else
				local data = FS.read(src)
				if data then
					FS.write(dst, data)
				end
			end
		end
		::continue::
	end

	-- 删除已删除的文件
	for _, del_path in ipairs(deleted_files) do
		remove_dir_recursive(target_dir .. "/" .. del_path)
	end

	remove_dir_recursive(tmp)
	return true, nil
end
function PluginManagerView:_download_patch(entry, platform, version, changed, deleted)
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return nil, "无法选择插件商店地址"
	end
	local resp, err = self:_request(base .. "/download_patch", {
		method = "POST",
		headers = {
			["Content-Type"] = "application/json"
		},
		data = json.encode({
			entry = entry,
			version = version,
			platform = platform,
			changed = changed,
			deleted = deleted
		})
	}, 60)
	if err then
		return nil, "增量更新请求失败：" .. err
	end
	if tonumber(resp.code) ~= 200 then
		return nil, "增量更新请求失败：HTTP " .. tostring(resp.code)
	end
	return resp.body, nil
end

function PluginManagerView:_install_or_update_item(item, task)
	if task and task.cancelled then
		return false, "cancelled"
	end
	local local_plugin = self.local_by_entry[item.entry]
	local need_update = local_plugin and has_update(local_plugin.config.version, item.version)
	if not need_update then
		return self:_install_plugin(item, false, task)
	end

	-- 尝试增量更新：现场计算本地文件哈希
	local entry = utf8_util.sanitize(item.entry or "")
	local target_dir = plugin_paths.LOCAL_PLUGINS_DIR .. "/" .. entry
	if FS.getInfo(target_dir, "directory") then
		local local_cfg = plugin_paths.load_lua_table(target_dir .. "/config.lua")
		local dir_info = self:_compute_dir_hashes(target_dir)
		local hash_ok, hash_resp = self:_hash_check(entry, item.version or "", dir_info.hashes, get_platform(), "download")
		if hash_ok and hash_resp and type(hash_resp.changed) == "table" then
			local changed = hash_resp.changed
			local deleted = hash_resp.deleted
			if #changed == 0 and #deleted == 0 then
				self:_set_status("插件已是最新：" .. (item.name or item.entry), 100)
				return true, nil
			end
			local patch_data = self:_download_patch(entry, get_platform(), item.version or "", changed, deleted)
			if task and task.cancelled then
				return false, "cancelled"
			end
			if patch_data then
				local _, local_cfg_saved = self:_preserve_local_config(target_dir, entry, local_plugin)
				self:_set_status("正在应用增量更新：" .. (item.name or item.entry), 90)
				if task then
					task.progress = 90
				end
				local ok_apply = self:_apply_patch_to_dir(target_dir, patch_data)
				if ok_apply then
					-- 记忆更新：应用时若该插件正在运行（文件已替换），直接重启
					self._pending.updated[entry] = true
					if local_cfg_saved then
						self:_restore_local_config(target_dir, entry, local_cfg_saved)
					else
						-- 本地没有旧配置，为新版本配置记录默认配置数据
						ensure_default_config_recorded(target_dir .. "/" .. entry .. "_config.lua")
					end
					local installed_cfg = plugin_paths.load_lua_table(target_dir .. "/config.lua")
					if installed_cfg then
						installed_cfg.enabled = local_plugin and local_plugin.config and (local_plugin.config.enabled ~= false)
						if installed_cfg.enabled == nil then
							installed_cfg.enabled = local_cfg and local_cfg.enabled ~= false
						end
						installed_cfg.last_used_at = os.time()
						storage:write_lua(target_dir .. "/config.lua", installed_cfg)
					end
					self:_refresh_local_view("插件增量更新完成：" .. (item.name or item.entry), local_plugin and local_plugin.name or entry)
					if task then
						task.progress = 100
					end
					return true, nil
				end
			end
		end
	end

	-- 回落全量更新
	return self:_install_plugin(item, true, task)
end

-- ─────────────────────────────────────────────
-- 下载任务队列（串行执行，服务器带宽低）
-- ─────────────────────────────────────────────

--- 查找某插件 entry 是否在下载队列中（未终态：排队/下载/取消中）
---@param entry string 插件 entry
---@return table|nil 任务对象
function PluginManagerView:_find_dl_task_by_entry(entry)
	if self._dl_running and self._dl_running.item.entry == entry then
		return self._dl_running
	end
	for _, t in ipairs(self._dl_queue) do
		if t.item.entry == entry and (t.state == "queued" or t.state == "running" or t.state == "cancelling") then
			return t
		end
	end
	return nil
end

--- 加入下载队列；同一 entry 已在队列/运行中时忽略
---@param item table 商店条目
---@param is_update boolean 是否更新（用于完成文案）
---@return table|nil 任务对象（重复入队返回 nil）
function PluginManagerView:_enqueue_download(item, is_update)
	if not item or not item.entry then
		return nil
	end
	local entry = item.entry
	if self._dl_running and self._dl_running.item.entry == entry then
		self:_set_status("该插件正在下载中：" .. (item.name or entry), 0)
		return nil
	end
	for _, t in ipairs(self._dl_queue) do
		if t.item.entry == entry and (t.state == "queued" or t.state == "running") then
			self:_set_status("该插件已在下载队列中：" .. (item.name or entry), 0)
			return nil
		end
	end
	self._dl_seq = self._dl_seq + 1
	local task = {
		id = self._dl_seq,
		item = item,
		is_update = is_update == true,
		state = "queued",
		progress = 0,
		error = nil,
		cancelled = false,
		coro = nil
	}
	table.insert(self._dl_queue, task)
	self:_set_status(string.format("已加入下载队列：%s（队列共 %d 项）", item.name or entry, #self._dl_queue), 0)
	self:_refresh_header_buttons()
	self:_render_current_list()
	if self._dl_view_open then
		self._dl_view_dirty = true
	end
	return task
end

--- 启动一个任务（下载+安装协程）
function PluginManagerView:_start_dl_task(task)
	task.state = "running"
	task.coro = coroutine.create(function()
		local ok, err = self:_install_or_update_item(task.item, task)
		return {
			ok = ok,
			err = err,
			cancelled = task.cancelled
		}
	end)
	self._dl_running = task
end

--- 每帧驱动队列：推进运行中任务、启动下一个排队任务
function PluginManagerView:_update_dl_queue()
	if self._dl_running then
		local task = self._dl_running
		local ok, result = coroutine.resume(task.coro)
		if not ok then
			task.state = "failed"
			task.error = tostring(result)
			self._dl_running = nil
			self._dl_view_dirty = true
			log.error("download task failed: %s", tostring(result))
			self:_render_current_list()
		elseif coroutine.status(task.coro) == "dead" then
			if result and result.cancelled then
				task.state = "cancelled"
			elseif result and result.ok then
				task.state = "done"
			else
				task.state = "failed"
				task.error = result and result.err or "unknown"
			end
			self._dl_running = nil
			self._dl_view_dirty = true
			-- 任务终态：刷新主列表，恢复「安装/更新」按钮与状态
			self:_render_current_list()
		end
	end
	if not self._dl_running then
		for _, task in ipairs(self._dl_queue) do
			if task.state == "queued" then
				self:_start_dl_task(task)
				self._dl_view_dirty = true
				break
			end
		end
	end
	if self._dl_view_open then
		if self._dl_view_dirty then
			-- 结构变化（入队/终态/删除）：重建列表，并保持滚动位置
			self._dl_view_dirty = false
			self:_render_dl_task_view()
		elseif self._dl_running then
			-- 下载中：只刷新进度与状态文本，避免重建导致滚动位置丢失
			self:_update_dl_view_progress()
		end
	end
end

--- 取消任务（排队中直接取消；运行中标记取消，协程在下一个网络边界退出）
function PluginManagerView:_cancel_dl_task(task)
	if task.state == "queued" then
		task.state = "cancelled"
		self:_render_current_list()
	elseif task.state == "running" then
		task.cancelled = true
		task.state = "cancelling"
	end
	self:_refresh_header_buttons()
	if self._dl_view_open then
		self._dl_view_dirty = true
	end
end

--- 从队列移除终态任务
function PluginManagerView:_remove_dl_task(task)
	if task.state == "running" or task.state == "queued" or task.state == "cancelling" then
		return false
	end
	for i, t in ipairs(self._dl_queue) do
		if t == task then
			table.remove(self._dl_queue, i)
			break
		end
	end
	self:_refresh_header_buttons()
	if self._dl_view_open then
		self._dl_view_dirty = true
	end
	return true
end

function PluginManagerView:_preserve_local_config(target_dir, entry, local_plugin)
	local local_cfg = nil
	local local_cfg_path = local_plugin and (local_plugin.path .. "/" .. local_plugin.name .. "_config.lua") or (target_dir .. "/" .. entry .. "_config.lua")
	if FS.getInfo(local_cfg_path, "file") then
		local ok, cfg = pcall(FS.load, local_cfg_path)
		if ok and type(cfg()) == "table" then
			local_cfg = cfg()
		end
	end
	return local_cfg_path, local_cfg
end

function PluginManagerView:_restore_local_config(target_dir, entry, local_cfg)
	local path = target_dir .. "/" .. entry .. "_config.lua"
	if not local_cfg then
		return
	end
	-- 读取新安装的配置，将新增字段合并到用户保留的旧配置中
	local new_cfg = nil
	if FS.getInfo(path, "file") then
		local ok, chunk = pcall(FS.load, path)
		if ok and type(chunk) == "function" then
			local ok2, result = pcall(chunk)
			if ok2 and type(result) == "table" then
				new_cfg = result
			end
		end
	end
	if new_cfg then
		local_cfg = merge_plugin_config_with_defaults(local_cfg, new_cfg)
	end
	storage:write_lua(path, local_cfg)
end

function PluginManagerView:_update_all_plugins()
	self._cancel_requested = false
	if #self.local_plugins == 0 then
		self:_set_status("本地没有已安装插件", 0)
		return true, nil
	end
	local need_remote_lookup = not next(self._remote_entry_cache)
	if not need_remote_lookup then
		for _, plugin_data in ipairs(self.local_plugins) do
			local entry = utf8_util.sanitize(plugin_data.entry)
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
	for _, plugin_data in ipairs(self.local_plugins) do
		local remote = self.remote_by_entry[plugin_data.entry]
		if remote and has_update(plugin_data.config.version, remote.version) then
			pending[#pending + 1] = {
				local_plugin = plugin_data,
				remote = remote
			}
		end
	end
	if #pending == 0 then
		self:_set_status("没有可更新的插件", 0)
		return true, nil
	end
	-- 全部加入下载队列（串行执行，不阻塞 UI）
	local enqueued = 0
	for _, row in ipairs(pending) do
		if self:_enqueue_download(row.remote, true) then
			enqueued = enqueued + 1
		end
	end
	self:_set_status(string.format("已加入更新队列，共 %d 个插件", enqueued), 0)
	return true, nil
end

function PluginManagerView:_start_task(name, fn)
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

function PluginManagerView:_render_local_list()
	self.plugin_list:clear_rows()
	self._plugin_rows = {}
	local list_w = self.plugin_list.size.x - self.plugin_list.scroller_width - 2 * self.plugin_list.scroller_margin - 4
	local global_disabled = not self.global_toggle.value

	local category_option = CATEGORY_OPTIONS[self.category_idx]

	for _, plugin_data in ipairs(self.local_plugins) do
		local cfg = plugin_data.config
		local plugin_category = cfg.category or "other"
		-- 搜索过滤（本地即时）
		if self._search_query and self._search_query ~= "" then
			local q = self._search_query:lower()
			local hit = (cfg.name and cfg.name:lower():find(q, 1, true)) or (cfg.desc and cfg.desc:lower():find(q, 1, true)) or (cfg.by and cfg.by:lower():find(q, 1, true)) or (plugin_data.entry and plugin_data.entry:lower():find(q, 1, true))

			if not hit then
				goto continue
			end
		end
		-- 过滤分类
		if (category_option.value == "all" or category_option.value == plugin_category) and (not self._my_plugins_only or cfg.by == self._developer_config.account) then
			local remote = self.remote_by_entry[plugin_data.entry]
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
						self:_handle_upload_plugin(plugin_data)
					end
				}
			end
			actions[#actions + 1] = {
				text = "详情",
				on_press = function()
					self:_show_local_plugin_detail(plugin_data)
				end
			}
			-- 作者自己的插件：本地视图同样禁止删除，防止误删
			local is_own = self._developer_mode and cfg and cfg.by == self._developer_config.account
			actions[#actions + 1] = {
				text = is_own and "我的插件" or "删除",
				enabled = not is_own,
				on_press = function()
					self:_start_task("删除插件", function()
						local ok, err = self:_delete_local_plugin_by_name(plugin_data.name)
						if ok then
							self:_set_status("已删除插件：" .. plugin_data.name, 0)
							return true, nil
						end
						return false, err
					end)
				end
			}
			if remote and has_update(cfg.version, remote.version) then
				local dl_task = self:_find_dl_task_by_entry(remote.entry)
				actions[#actions + 1] = {
					text = dl_task and "更新中" or "更新",
					on_press = function()
						self:_enqueue_download(remote, true)
					end
				}
			end

			local row = PluginItemRow:new({
				plugin_data = plugin_data,
				title = cfg.name or plugin_data.name,
				meta = string.format("%s v%s  作者: %s", plugin_data.entry, utf8_util.sanitize(cfg.version), utf8_util.sanitize(cfg.by)),
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
				manager = self, -- 供配置编辑器延迟写盘与记忆待应用修改
				actions = global_disabled and {} or actions,
				_sw = self._sw,
				_sh = self._sh,
				_keyboard = self._keyboard,
				_controller = self._controller
			}, list_w)
			if global_disabled then
				row:set_dimmed(true)
			end
			self.plugin_list:add_row(row)
			self.plugin_list:add_row(KVirtualView:new(V.v(list_w, 10)))
			self._plugin_rows[#self._plugin_rows + 1] = row
		end
		::continue::
	end
end

function PluginManagerView:_render_store_list()
	self.plugin_list:clear_rows()
	local list_w = self.plugin_list.size.x - self.plugin_list.scroller_width - 2 * self.plugin_list.scroller_margin - 4
	for _, item in ipairs(self.store_items) do
		local local_plugin = self.local_by_entry[item.entry] or self.local_by_name[item.entry]
		-- 只看未安装：本地再过滤一次（防本页请求后刚安装的条目残留）
		if self._uninstalled_only and local_plugin then
			goto continue
		end
		local installed = local_plugin ~= nil
		local needs_update = installed and has_update(local_plugin.config.version, item.version)
		local dl_task = self:_find_dl_task_by_entry(item.entry)
		local status
		if dl_task then
			if dl_task.state == "running" or dl_task.state == "cancelling" then
				status = "正在下载…"
			else
				status = "已加入下载队列"
			end
		elseif installed then
			if needs_update then
				status = string.format("已安装：v%s（可更新到 v%s）", utf8_util.sanitize(local_plugin.config.version), utf8_util.sanitize(item.version))
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
				self:_show_store_plugin_detail(item)
			end
		}
		if dl_task then
			-- 已在下载队列：按钮改为排队提示（点击不再重复入队，_enqueue_download 会提示）
			actions[#actions + 1] = {
				text = dl_task.state == "running" and "下载中" or "排队中",
				on_press = function()
					self:_enqueue_download(item, installed and needs_update)
				end
			}
		else
			actions[#actions + 1] = {
				text = installed and (needs_update and "更新" or "重装") or "安装",
				on_press = function()
					self:_enqueue_download(item, installed and needs_update)
				end
			}
		end
		if installed then
			-- 作者自己的插件：商店视图中禁用删除按钮，防止误删本地插件
			local is_own = self._developer_mode and local_plugin.config and local_plugin.config.by == self._developer_config.account
			actions[#actions + 1] = {
				text = is_own and "我的插件" or "删除",
				enabled = not is_own,
				on_press = function()
					self:_start_task("删除插件", function()
						local ok, err = self:_delete_local_plugin_by_name(local_plugin.name)
						if ok then
							self:_set_status("已删除插件：" .. local_plugin.name, 0)
							return true, nil
						end
						return false, err
					end)
				end
			}
		end

		local row = PluginItemRow:new({
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
		self.plugin_list:add_row(row)
		self.plugin_list:add_row(KVirtualView:new(V.v(list_w, 10)))
		::continue::
	end
end

function PluginManagerView:_render_current_list()
	self._disabled_warning.hidden = self.global_toggle.value
	-- 渲染前后保存/恢复滚动位置，避免重绘列表（如安装/更新完成后）把视野弹回顶部
	local plugin_list = self.plugin_list
	local saved_scroll = plugin_list and plugin_list.scroll_origin_y or 0
	if self.mode == "store" then
		self:_render_store_list()
	else
		self:_render_local_list()
	end
	if plugin_list then
		local max_scroll = -(plugin_list._bottom_y - plugin_list.size.y)
		plugin_list.scroll_origin_y = km.clamp(max_scroll, 0, saved_scroll)
	end
	self:_sanitize_view_texts(self.back)
	self:_refresh_header_buttons()
end

function PluginManagerView:_sanitize_view_texts(view)
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

function PluginManagerView:show()
	plugin_paths.ensure_storage_ready()
	self._unsaved_changes = false
	-- 每次打开都清空修改记忆，避免上次会话残留污染
	self._pending = {
		plugins = {},
		deleted = {},
		updated = {}
	}
	self:_start_http_thread()
	-- 从磁盘读取初始状态，但仅在此处（后续 _reload_local_plugins 不会覆盖用户未保存的修改）
	local cfg = plugin_paths.load_main_config()
	local saved_cb = self.global_toggle.on_change
	self.global_toggle.on_change = nil
	self.global_toggle:set_value(cfg.enabled ~= false)
	self.global_toggle.on_change = saved_cb
	self:_reload_local_plugins()
	self:_capture_state()
	self:_render_current_list()
	self.task_dialog.hidden = true
	self._category_panel.hidden = true
	self._sort_panel.hidden = true
	self:_set_status("前往插件商店后会自动拉取第一页", 0)
	self:_sanitize_view_texts(self.back)
	PluginManagerView.super.show(self)
end

function PluginManagerView:hide()
	if self._unsaved_changes then
		self._confirm_dialog.hidden = false
		self._confirm_dialog:order_to_front()
		return
	end
	-- 关闭管理器：清理本次修改记忆，避免下次打开污染
	self:_clear_pending_changes()
	self._cancel_requested = true
	self:_stop_http_thread()
	PluginManagerView.super.hide(self)
end

function PluginManagerView:update(dt)
	PluginManagerView.super.update(self, dt)
	if self._pending_close then
		self._pending_close = false
		self:hide()
		return
	end
	self:_sanitize_view_texts(self.back)
	self:_render_progress()
	self:_update_dl_queue()
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
		log.error("plugin manager task failed: %s", tostring(result))
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

function PluginManagerView:_reset_cover_prompt()
	self._upload_pending_data = nil
	self._upload_pending_cover = nil
	self._cover_yes_btn.hidden = true
	self._cover_no_btn.hidden = true
	self._confirm_cancel_btn.hidden = true
	self.task_cancel_btn.hidden = false
	self._cover_yes_btn:set_text("上传封面")
end

function PluginManagerView:_show_local_plugin_detail(plugin_data)
	-- 读取本地 README.md
	local readme_path = plugin_data.path .. "/README.md"
	local content = nil
	local fallback = plugin_data.config.desc or "暂无说明文档"
	if FS.getInfo(readme_path, "file") then
		content = FS.read(readme_path) or nil
	end
	if not content or content == "" then
		content = nil
	end

	local detail = markdown_view:new(self._sw, self._sh, plugin_data.config.name or plugin_data.name, content, fallback)
	self:add_child(detail)
	detail:show()
end

function PluginManagerView:_show_store_plugin_detail(item)
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

function PluginManagerView:_handle_upload_plugin(plugin_data)
	local cover_name = nil
	local items = FS.getDirectoryItems(plugin_data.path) or {}
	for _, name in ipairs(items) do
		if name:lower():match("^cover%.") then
			cover_name = name
			break
		end
	end

	self._upload_pending_data = plugin_data
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
		self.task_status_lbl.text = "确认上传 " .. (plugin_data.config.name or plugin_data.name) .. " 到商店？"
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

function PluginManagerView:_developer_login()
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

function PluginManagerView:_compute_dir_hashes(dir)
	local hashes = {}
	local sizes = {}
	local total_bytes = 0

	local skip_dirs = {".git", ".backup", ".tmp"}

	local function walk(path, prefix)
		local items = FS.getDirectoryItems(path) or {}
		for _, name in ipairs(items) do
			if prefix == "" then
				local is_skip = false
				for _, sd in ipairs(skip_dirs) do
					if name == sd then
						is_skip = true
						break
					end
				end
				if is_skip then
					goto continue
				end
				if name:lower():match("^cover%.") then
					goto continue
				end
			end

			local full_path = path .. "/" .. name
			local rel_path = (prefix ~= "" and prefix .. "/" .. name) or name
			local info = FS.getInfo(full_path)
			if info then
				if info.type == "directory" then
					walk(full_path, rel_path)
				elseif info.type == "file" then
					local data = FS.read(full_path)
					if data then
						local hash_data = love.data.hash("sha256", data)
						hashes[rel_path] = love.data.encode("string", "hex", hash_data)
						sizes[rel_path] = #data
						total_bytes = total_bytes + #data
					end
				end
			end
			::continue::
		end
	end

	walk(dir, "")
	local file_count = 0
	for _ in pairs(hashes) do
		file_count = file_count + 1
	end
	return {
		hashes = hashes,
		sizes = sizes,
		total_bytes = total_bytes
	}
end

function PluginManagerView:_hash_check(entry, version, hashes, platform, mode)
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return false, "无法选择插件商店地址"
	end
	local body_data = {
		entry = entry,
		version = version,
		platform = platform,
		hashes = hashes
	}
	if mode then
		body_data.mode = mode
	end
	local resp, err = self:_request(base .. "/hash_check", {
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. (self._developer_token or ""),
			["Content-Type"] = "application/json"
		},
		data = json.encode(body_data)
	}, 30)
	if err then
		return false, "哈希比对失败：" .. err
	end
	if tonumber(resp.code) ~= 200 then
		return false, nil
	end
	local ok, body = pcall(json.decode, resp.body)
	if not ok or type(body) ~= "table" then
		return false, "哈希比对响应解析失败"
	end
	return true, body
end

function PluginManagerView:_upload_patch(plugin_data, entry, version, changed, deleted, upload_cover)
	local tmp = "tmp/plugin_patch/" .. entry
	remove_dir_recursive("tmp/plugin_patch")
	FS.createDirectory("tmp")
	FS.createDirectory("tmp/plugin_patch")
	FS.createDirectory(tmp)

	for _, rel_path in ipairs(changed) do
		local src = plugin_data.path .. "/" .. rel_path
		local dst = tmp .. "/" .. rel_path
		local parent = dst:match("^(.*/)")
		if parent and not FS.getInfo(parent, "directory") then
			local parts = {}
			for seg in parent:gmatch("[^/]+") do
				parts[#parts + 1] = seg
				local p = table.concat(parts, "/")
				if not FS.getInfo(p, "directory") then
					FS.createDirectory(p)
				end
			end
		end
		local data = FS.read(src)
		if data then
			FS.write(dst, data)
		end
	end

	FS.write(tmp .. "/_patch_manifest.json", json.encode({
		deleted = deleted
	}))
	local patch_data = zip.create_from_dir(tmp, {})
	remove_dir_recursive("tmp/plugin_patch")
	if not patch_data then
		return false, "打包增量失败"
	end

	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return false, "无法选择插件商店地址"
	end

	self:_set_status("正在增量上传插件：" .. entry, 40)
	local resp, err = self:_request(base .. "/upload", {
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. self._developer_token,
			["Content-Type"] = "application/octet-stream",
			["X-Upload-Mode"] = "patch",
			["X-Plugin-Entry"] = entry,
			["X-Plugin-Version"] = version
		},
		data = patch_data
	}, 120)

	if err then
		return false, "增量上传失败：" .. err
	end
	if tonumber(resp.code) ~= 200 then
		return false, "增量上传失败：HTTP " .. tostring(resp.code) .. " " .. tostring(resp.body)
	end

	return true, nil
end

function PluginManagerView:_upload_plugin(plugin_data, upload_cover)
	if not self._developer_token then
		local ok, err = self:_developer_login()
		if not ok then
			return false, err
		end
	end

	local entry = plugin_data.config.entry or plugin_data.name
	local version = plugin_data.config.version or ""

	local cover_data = nil
	local cover_ext = nil
	if upload_cover then
		local items = FS.getDirectoryItems(plugin_data.path) or {}
		for _, name in ipairs(items) do
			if name:lower():match("^cover%.") then
				cover_data = FS.read(plugin_data.path .. "/" .. name)
				cover_ext = name:match("%.([^%.]+)$")
				break
			end
		end
	end

	-- 计算本地文件哈希
	self:_set_status("正在计算文件哈希：" .. entry, 5)
	local dir_info = self:_compute_dir_hashes(plugin_data.path)
	if dir_info.total_bytes == 0 then
		return false, "插件目录为空"
	end

	-- 与服务端比对哈希，决定全量还是增量
	local use_full = true
	local hash_ok, hash_resp = self:_hash_check(entry, version, dir_info.hashes)
	if hash_ok and hash_resp and type(hash_resp.changed) == "table" and type(hash_resp.deleted) == "table" then
		local changed = hash_resp.changed
		local deleted = hash_resp.deleted
		local changed_bytes = 0
		for _, p in ipairs(changed) do
			changed_bytes = changed_bytes + (dir_info.sizes[p] or 0)
		end
		use_full = changed_bytes > dir_info.total_bytes * 0.6

		if #changed == 0 and #deleted == 0 then
			print("插件无变更，无需上传！")
			self:_refresh_local_view("插件无变更，无需上传：" .. entry, plugin_data.name)
			return true, nil
		end
		if not use_full and #changed > 0 then
			local ok_patch, err_patch = self:_upload_patch(plugin_data, entry, version, changed, deleted, upload_cover)
			if ok_patch then
				if cover_data and cover_ext then
					self:_upload_cover(entry, cover_data, cover_ext)
				end
				self:_refresh_local_view("增量上传成功：" .. entry, plugin_data.name)
				return true, nil
			end
			log.error("[plugin_manager] 补丁上传失败，回退到全量上传：%s", tostring(err_patch))
			use_full = true
		end
	end
	if not hash_ok then
		log.error("[plugin_manager] 哈希检查失败，回退到全量上传：%s", tostring(hash_resp))
	end

	-- 全量上传（增量不可用或变更量过大时回落）
	self:_set_status("正在压缩插件：" .. entry, 20)
	local zip_data = zip.create_from_dir(plugin_data.path, {
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
		self:_upload_cover(entry, cover_data, cover_ext)
	end

	self:_refresh_local_view("上传成功：" .. entry, plugin_data.name)
	return true, nil
end

function PluginManagerView:_upload_cover(entry, cover_data, cover_ext)
	self:_set_status("正在上传封面…", 90)
	local base = self._selected_site and (self._selected_site:gsub("/+$", "") .. "/plugins") or self:_select_store_base_url()
	if not base then
		return
	end

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

	local resp, err = self:_request(base .. "/" .. url_encode(entry) .. "/cover", {
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. self._developer_token,
			["Content-Type"] = mime
		},
		data = cover_data
	}, 30)

	if err then
		self:_refresh_local_view("插件上传成功，但封面上传失败：" .. err, entry)
	elseif tonumber(resp.code) ~= 200 then
		self:_refresh_local_view("插件上传成功，但封面上传失败：HTTP " .. tostring(resp.code), entry)
	end
end

function PluginManagerView:_capture_state()
	self._saved_state = {
		global_enabled = self.global_toggle.value,
		plugin_enabled = {}
	}
	for _, plugin_data in ipairs(self.local_plugins) do
		self._saved_state.plugin_enabled[plugin_data.name] = plugin_data.config.enabled ~= false
	end
	self._unsaved_changes = false
end

function PluginManagerView:_check_unsaved()
	if self.global_toggle.value ~= self._saved_state.global_enabled then
		return true
	end
	for _, plugin_data in ipairs(self.local_plugins) do
		local saved = self._saved_state.plugin_enabled[plugin_data.name]
		if saved ~= nil and (plugin_data.config.enabled ~= false) ~= saved then
			return true
		end
	end
	-- 本会话存在待应用的插件配置修改
	for _, info in pairs(self._pending.plugins) do
		if info.config_changed then
			return true
		end
	end
	return false
end

--- 配置编辑器保存时调用：记忆待应用配置（延迟写盘，点「应用」才落盘并触发 on_config_change）
---@param plugin_name string 插件目录名
---@param config table 编辑后的完整用户配置（<name>_config.lua 内容）
function PluginManagerView:_set_pending_config(plugin_name, config)
	local info = self._pending.plugins[plugin_name] or {}
	info.config_changed = true
	info.config = table.deepclone(config or {})
	self._pending.plugins[plugin_name] = info
	self._unsaved_changes = self:_check_unsaved()
end

--- 清除某插件的待应用配置（编辑结果与磁盘原配置一致时调用，
--- 避免仅打开过配置界面未做修改也提示「有未保存的修改」）
---@param plugin_name string 插件目录名
function PluginManagerView:_clear_pending_config(plugin_name)
	if self._pending.plugins[plugin_name] then
		self._pending.plugins[plugin_name] = nil
		self._unsaved_changes = self:_check_unsaved()
	end
end

--- 读取待应用配置（配置编辑器加载时优先显示待定值，未修改则显示磁盘值）
---@param plugin_name string 插件目录名
---@return table|nil
function PluginManagerView:_get_pending_config(plugin_name)
	local info = self._pending.plugins[plugin_name]
	if info and info.config then
		return info.config
	end
	return nil
end

--- 清空本次修改记忆（应用完成或关闭管理器时调用）
function PluginManagerView:_clear_pending_changes()
	self._pending = {
		plugins = {},
		deleted = {},
		updated = {}
	}
end

--- 汇总本次打开期间的最终修改（按最终状态与运行时加载状态比较，
--- 同一插件多次切换开闭只产生一次有效变更，避免先 reload 后 unload 的无效操作）。
--- 基准使用 plugin_main 的运行时加载状态而非磁盘快照：
--- 新下载/新安装的插件（未应用过）不在运行时加载集合中，点「应用」时会被正确热加载。
--- 注：更新/删除正在运行的插件不在此列——文件已替换/移除，无法安全热应用，统一走重启。
---@return table {unloads=..., reloads=..., configs=...}
function PluginManagerView:_collect_changes()
	local new_global = self.global_toggle.value
	local changes = {
		unloads = {},
		reloads = {},
		configs = {}
	}
	for _, plugin_data in ipairs(self.local_plugins) do
		-- 应用前该插件是否正在运行（运行时真实状态）
		local old_eff = plugin_main:is_loaded(plugin_data)
		local new_eff = new_global and plugin_data.config.enabled ~= false
		if old_eff and not new_eff then
			-- 启用 → 未启用：热卸载
			changes.unloads[#changes.unloads + 1] = plugin_data
		elseif not old_eff and new_eff then
			-- 未启用 → 启用：热加载（配置由 reload 自行读取）
			changes.reloads[#changes.reloads + 1] = plugin_data
		elseif new_eff then
			local info = self._pending.plugins[plugin_data.name]
			if info and info.config_changed and info.config then
				-- 保持启用且配置有修改：配置热加载（携带新配置数据）
				changes.configs[#changes.configs + 1] = {
					plugin_data = plugin_data,
					config = info.config
				}
			end
		end
	end
	return changes
end

--- 更新/删除正在运行的插件时无法安全热应用（文件已替换/移除，
--- 热卸载也无法撤销模板注册等全部副作用），应用时直接重启
function PluginManagerView:_needs_restart()
	for _, plugin_data in pairs(self._pending.deleted) do
		if plugin_main:is_loaded(plugin_data) then
			return true
		end
	end
	for name in pairs(self._pending.updated) do
		local plugin_data = self.local_by_name[name]
		if plugin_data and plugin_main:is_loaded(plugin_data) then
			return true
		end
	end
	return false
end

--- 是否存在需要落盘的开关状态修改。
--- 运行时动作（reload/unload/on_config_change）之外，仍需把最终开关状态写入磁盘；
--- 典型场景：新下载的插件被关闭——插件从未加载，没有运行时动作，
--- 但 config.lua 必须写入禁用状态，否则下次打开管理器会显示仍为启用。
function PluginManagerView:_has_disk_changes()
	if self.global_toggle.value ~= self._saved_state.global_enabled then
		return true
	end
	for _, plugin_data in ipairs(self.local_plugins) do
		local saved = self._saved_state.plugin_enabled[plugin_data.name]
		-- saved == nil：本会话新安装的插件（打开管理器时尚不存在），最终状态必须落盘
		if saved == nil or (plugin_data.config.enabled ~= false) ~= saved then
			return true
		end
	end
	return false
end

--- 应用按钮：先检查本次所有修改能否热重载；任一修改无法热重载则沿用原「保存并重启」逻辑。
--- 热应用成功后自动关闭管理器；部分失败时保持打开并在状态栏提示。
--- 没有任何需要应用的修改时直接关闭，不提示。
function PluginManagerView:apply()
	local changes = self:_collect_changes()
	local has_runtime_actions = changes.unloads[1] or changes.reloads[1] or changes.configs[1]
	local has_pending_config = next(self._pending.plugins) ~= nil
	local has_pending_deleted = next(self._pending.deleted) ~= nil
	local needs_restart = self:_needs_restart()

	if not has_runtime_actions and not has_pending_config and not has_pending_deleted and not needs_restart and not self:_has_disk_changes() then
		-- 没有任何需要应用的修改：直接关闭
		self._pending_close = true
		return
	end

	-- 先落盘（含延迟的插件配置修改与开闭状态），确保热加载/重启读取的都是新配置
	self:save()

	if needs_restart then
		-- 更新/删除了正在运行的插件：文件已替换/移除，无法安全热应用，直接重启
		self:_stop_http_thread()
		restart.tmp()
		return
	end

	if not has_runtime_actions then
		-- 只有磁盘层面的修改（如新下载的插件被关闭）：无需热重载或重启
		self:_clear_pending_changes()
		self._pending_close = true
		return
	end

	local hot_ok, _ = plugin_main:can_hot_apply(changes)
	if not hot_ok then
		-- 存在无法热重载的修改：沿用原重启逻辑
		self:_stop_http_thread()
		restart.tmp()
		return
	end

	-- 热重载路径：执行 reload/unload/on_config_change
	local ok, errors = plugin_main:apply_hot(changes)
	self:_clear_pending_changes()
	-- 通知宿主（如 screen_map）刷新自制关卡列表等依赖插件运行状态的界面
	if self.on_applied then
		self.on_applied()
	end
	if ok then
		self:_set_status("已热应用插件修改，无需重启", 0)
		-- 应用成功自动关闭管理器
		self._pending_close = true
	else
		self:_set_status("热应用部分失败：" .. table.concat(errors, "；"), 0)
	end
end

function PluginManagerView:save()
	local base_cfg = plugin_paths.load_main_config()
	base_cfg.enabled = self.global_toggle.value
	local ok = storage:write_lua(plugin_paths.MAIN_CONFIG_PATH, base_cfg)
	if not ok then
		log.error("写入 %s 失败", plugin_paths.MAIN_CONFIG_PATH)
	end

	for _, plugin_data in ipairs(self.local_plugins) do
		local cfg = plugin_data.config or {}
		local out = {}
		for k, v in pairs(cfg) do
			out[k] = v
		end
		out.enabled = cfg.enabled ~= false
		if out.enabled then
			out.last_used_at = os.time()
		end
		local wok = storage:write_lua(plugin_data.config_path, out)
		if not wok then
			log.error("写入 %s 失败", plugin_data.config_path)
		end
	end

	-- 写入本会话待应用的插件用户配置（<name>_config.lua）：延迟到应用时才落盘
	for name, info in pairs(self._pending.plugins) do
		if info.config then
			local plugin_data = self.local_by_name[name]
			if plugin_data then
				local cfg_path = plugin_data.path .. "/" .. plugin_data.name .. "_config.lua"
				local wok = storage:write_lua(cfg_path, info.config)
				if not wok then
					log.error("写入 %s 失败", cfg_path)
				end
			end
		end
	end
	self:_capture_state()
end

function PluginManagerView:destroy()
	self:_stop_http_thread()
end

-- ─────────────────────────────────────────────
-- 下载任务管理视图
-- ─────────────────────────────────────────────

local DL_STATE_TEXT = {
	queued = "排队中",
	running = "下载中",
	cancelling = "取消中",
	done = "完成",
	failed = "失败",
	cancelled = "已取消"
}

function PluginManagerView:_build_dl_view()
	if self._dl_view then
		return
	end
	local rs = GGLabel.static.ref_h / REF_H
	local vw, vh = self._sw, self._sh
	self._dl_view = KView:new(V.v(vw, vh))
	self._dl_view.colors.background = {0, 0, 0, 150}
	self._dl_view.hidden = true
	self:add_child(self._dl_view)

	local pw, ph = self._panel_w or math.min(880, vw - 60), self._panel_h or math.min(700, vh - 80)
	local us = self._dl_touch_scale or 1
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = {40, 29, 10, 245}
	panel.anchor = V.v(pw / 2, ph / 2)
	panel.pos = V.v(vw / 2, vh / 2)
	panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, pw, ph, 14, 14}
	}
	self._dl_view:add_child(panel)

	local title = GGLabel:new(V.v(pw - 80, 30))
	title.font_name = "h"
	title.font_size = 16 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = {244, 221, 165, 255}
	title.text = "下载任务管理"
	title.pos = V.v(20, 12)
	panel:add_child(title)

	local hint = GGLabel:new(V.v(pw - 40, 20))
	hint.font_size = 12 * rs
	hint.font_name = "body"
	hint.text_align = "left"
	hint.vertical_align = "middle"
	hint.colors.text = {200, 185, 150, 255}
	hint.text = "任务完成后点「清除记录」仅移除列表项，不会删除已安装的插件；卸载插件请在本地列表操作。"
	hint.pos = V.v(20, 44)
	panel:add_child(hint)

	local close_btn = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")
	close_btn.pos = V.v(pw - 23, 23)
	close_btn.scale:set(1.2, 1.2)
	close_btn:set_anchor_to_center()
	close_btn.on_click = function()
		S:queue("GUIButtonCommon")
		self:_toggle_dl_view()
	end
	panel:add_child(close_btn)

	self._dl_list = KScrollList:new(V.v(pw - 40, ph - 118))
	self._dl_list.pos = V.v(20, 74)
	self._dl_list.colors.scroller_background = {45, 36, 22, 200}
	self._dl_list.colors.scroller_foreground = {110, 90, 50, 255}
	self._dl_list.scroller_width = math.max(10, math.floor(14 * us + 0.5))
	self._dl_list.scroll_amount = math.floor(66 * us + 0.5)
	panel:add_child(self._dl_list)
end

function PluginManagerView:_toggle_dl_view()
	self:_build_dl_view()
	self._dl_view_open = not self._dl_view_open
	self._dl_view.hidden = not self._dl_view_open
	if self._dl_view_open then
		self._dl_view_dirty = false
		self:_render_dl_task_view()
		self._dl_view:order_to_front()
	end
end

function PluginManagerView:_render_dl_task_view()
	if not self._dl_view or not self._dl_list then
		return
	end
	local rs = GGLabel.static.ref_h / REF_H
	local us = self._dl_touch_scale or 1
	-- 重建前保存滚动位置（clear_rows 会重置 scroll_origin_y），避免重建弹回顶部
	local saved_scroll = self._dl_list.scroll_origin_y
	self._dl_list:clear_rows()
	self._dl_row_by_id = {}
	local list_w = self._dl_list.size.x - self._dl_list.scroller_width - 2 * self._dl_list.scroller_margin

	if #self._dl_queue == 0 then
		local lbl = GGLabel:new(V.v(list_w, 40))
		lbl.font_size = 13 * rs
		lbl.text_align = "center"
		lbl.colors.text = {200, 185, 150, 255}
		lbl.font_name = "body"
		lbl.text = "暂无下载任务"
		self._dl_list:add_row(lbl)
		return
	end

	local row_h = math.floor(66 * us + 0.5)
	local row_gap = math.max(4, math.floor(8 * us + 0.5))
	for _, task in ipairs(self._dl_queue) do
		local row = KView:new(V.v(list_w, row_h))
		row.colors.background = {62, 48, 22, 220}
		row.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, list_w, row_h, 8, 8}
		}

		-- 名称：固定字号，超长按字符截断，避免 GGLabel fit_lines 自动缩放字体导致各任务字号不一致
		local name_lbl = GGLabel:new(V.v(list_w - 300 * us, math.floor(22 * us + 0.5)))
		name_lbl.font_size = 13 * rs
		name_lbl.text_align = "left"
		name_lbl.vertical_align = "middle"
		name_lbl.font_name = "body"
		name_lbl.colors.text = {240, 228, 200, 255}
		name_lbl.text = utf8_util.sub(task.item.name or task.item.entry or ("#" .. tostring(task.id)), 22)
		name_lbl.pos = V.v(12, math.floor(6 * us + 0.5))
		row:add_child(name_lbl)

		local state_lbl = GGLabel:new(V.v(math.floor(140 * us + 0.5), math.floor(22 * us + 0.5)))
		state_lbl.font_size = 13 * rs
		state_lbl.text_align = "right"
		state_lbl.vertical_align = "middle"
		state_lbl.colors.text = {214, 193, 144, 255}
		state_lbl.text = DL_STATE_TEXT[task.state] or task.state
		state_lbl.pos = V.v(list_w - math.floor(152 * us + 0.5), math.floor(6 * us + 0.5))
		state_lbl.font_name = "body"
		row:add_child(state_lbl)
		task._state_lbl = state_lbl
		task._error_lbl = nil

		-- 进度条 + 百分比
		local bar_w = list_w - 230 * us
		local bar_h = math.max(4, math.floor(8 * us + 0.5))
		local bar_bg = KView:new(V.v(bar_w, bar_h))
		bar_bg.colors.background = {30, 22, 10, 220}
		bar_bg.pos = V.v(12, math.floor(34 * us + 0.5))
		bar_bg.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, bar_w, bar_h, 4, 4}
		}
		row:add_child(bar_bg)
		local bar_fill = KView:new(V.v(0, bar_h))
		bar_fill.colors.background = {227, 190, 68, 235}
		bar_fill.pos = V.v(0, 0)
		bar_fill.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, 0, bar_h, 4, 4}
		}
		bar_bg:add_child(bar_fill)
		task._bar_fill = bar_fill
		task._bar_w = bar_w
		task._bar_h = bar_h
		local fill_w = bar_w * task.progress / 100
		bar_fill.shape.args[4] = fill_w
		bar_fill.size = V.v(fill_w, bar_h)

		local progress_lbl = GGLabel:new(V.v(math.floor(60 * us + 0.5), math.floor(20 * us + 0.5)))
		progress_lbl.font_size = 12 * rs
		progress_lbl.text_align = "left"
		progress_lbl.vertical_align = "middle"
		progress_lbl.colors.text = {227, 190, 68, 255}
		progress_lbl.text = (task.state == "done" and "100%" or tostring(math.floor(task.progress + 0.5)) .. "%")
		progress_lbl.pos = V.v(12 + bar_w + math.floor(10 * us + 0.5), math.floor(28 * us + 0.5))
		progress_lbl.font_name = "body"
		row:add_child(progress_lbl)
		task._progress_lbl = progress_lbl

		if task.error and task.error ~= "" then
			local err_lbl = GGLabel:new(V.v(list_w - 200 * us, math.floor(18 * us + 0.5)))
			err_lbl.font_size = 11 * rs
			err_lbl.text_align = "left"
			err_lbl.colors.text = {255, 150, 130, 255}
			err_lbl.text = utf8_util.sub(utf8_util.sanitize(task.error), 30)
			err_lbl.pos = V.v(12, math.floor(44 * us + 0.5))
			err_lbl.font_name = "body"
			row:add_child(err_lbl)
			task._error_lbl = err_lbl
		end

		local btn
		if task.state == "queued" or task.state == "running" or task.state == "cancelling" then
			btn = PluginActionButton:new("取消", V.v(math.floor(64 * us + 0.5), math.floor(28 * us + 0.5)))
			btn.on_press = function()
				self:_cancel_dl_task(task)
			end
		else
			btn = PluginActionButton:new("清除记录", V.v(math.floor(76 * us + 0.5), math.floor(28 * us + 0.5)))
			btn.on_press = function()
				self:_remove_dl_task(task)
			end
		end
		btn.pos = V.v(list_w - math.floor(84 * us + 0.5), math.floor(30 * us + 0.5))
		row:add_child(btn)

		self._dl_list:add_row(row)
		self._dl_list:add_row(KView:new(V.v(list_w, row_gap)))
		self._dl_row_by_id[task.id] = task
	end

	-- 恢复滚动位置（clamp 到有效范围）
	local max_scroll = -(self._dl_list._bottom_y - self._dl_list.size.y)
	self._dl_list.scroll_origin_y = km.clamp(max_scroll, 0, saved_scroll)
end

--- 每帧刷新管理视图中的进度条与状态文本（不重建行）
function PluginManagerView:_update_dl_view_progress()
	for _, task in ipairs(self._dl_queue) do
		if task._bar_fill then
			local w = task._bar_w * task.progress / 100
			task._bar_fill.shape.args[4] = w
			task._bar_fill.size = V.v(w, task._bar_h or 8)
		end
		if task._progress_lbl then
			local pct = task.state == "done" and 100 or math.floor(task.progress + 0.5)
			task._progress_lbl.text = pct .. "%"
		end
		if task._state_lbl then
			task._state_lbl.text = DL_STATE_TEXT[task.state] or task.state
		end
	end
end

return PluginManagerView
