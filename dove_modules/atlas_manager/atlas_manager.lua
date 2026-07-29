local class = require("middleclass")
local G = love.graphics
local FS = love.filesystem
local V = require("lib.klua.vector")
local v = V.v
local S = require("sound_db")
local I = require("lib.klove.image_db")
local SU = require("screen_utils")
local atlas_binpack = require("dove_modules.atlas_manager.atlas_binpack")
local atlas_util = require("dove_modules.atlas_manager.atlas_util")

require("lib.klua.table")
require("gg_views_custom")
require("klove.kui")

local ATLAS_DIR = "_assets/kr1-desktop/images/fullhd"
local IMAGES_DIR = ".images"
local BACKUP_DIR = ".images_backup"
local REF_W = 1920
local REF_H = 1080

local atlas_manager = {}

atlas_manager.required_textures = {}
atlas_manager.required_sounds = {}
atlas_manager.plugin_required_textures = {}
atlas_manager.plugin_required_sounds = {}
atlas_manager.ref_w = REF_W
atlas_manager.ref_h = 1080
atlas_manager.ref_res = TEXTURE_SIZE_ALIAS.fullhd

local state = {
	groups = {},
	group_order = {},
	expanded = {},
	selected_frames = {},
	frame_checks = {},
	sort_area_desc = true,
	merge_name = "",
	merge_w = 2048,
	merge_h = 2048,
	preview_canvas = nil,
	preview_valid = false,
	dirty = false,
	preview_frames = nil,
	loaded_textures = {},
}

local ui = {}

PreviewCanvas = class("PreviewCanvas", KView)

function PreviewCanvas:initialize(size, get_state)
	KView.initialize(self, size)
	self._get_state = get_state
end

function PreviewCanvas:_draw_self()
	local st = self._get_state()
	local G2 = love.graphics
	if not st or not st.preview_canvas or not st.preview_valid then
		G2.setColor(150/255, 160/255, 190/255, 1)
		G2.print("未合并 — 选中帧后点击\"预览合并结果\"", 4, 4)
		return
	end
	local canvas = st.preview_canvas
	local cw, ch = canvas:getDimensions()
	local max_w = self.size.x
	local max_h = self.size.y
	local scale = math.min(max_w / cw, max_h / ch, 1)
	local dw, dh = cw * scale, ch * scale
	local ox = (max_w - dw) * 0.5
	local oy = (max_h - dh) * 0.5

	G2.setColor(1, 1, 1, 1)
	G2.draw(canvas, ox, oy, 0, scale, scale)

	G2.setColor(200/255, 210/255, 240/255, 1)
	local info = string.format("预览: %dx%d (%.1f%%)", cw, ch, st._calc_utilization and st:_calc_utilization() or 0)
	G2.print(info, 4, 4)
end

function atlas_manager:init(w, h, done_callback)
	self.done_callback = done_callback
	self.sw, self.sh, self.scale, self.origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	self._rs = self.ref_h / REF_H

	GGLabel.static.font_scale = self.scale
	GGLabel.static.ref_h = self.ref_h

	ui.window = KWindow:new(V.v(self.sw, self.sh))
	ui.window.scale = v(self.scale, self.scale)
	ui.window.origin = self.origin

	local bg = KView:new(V.v(self.ref_w, self.ref_h))
	bg.colors.background = {16, 20, 32, 255}
	ui.window:add_child(bg)

	self:build_header()
	self:build_controls()
	self:build_preview_area()
	self:build_button_bar()

	self:refresh_groups()
	ui.window:add_child(ui.fps_label)
end

function atlas_manager:build_header()
	local rs = self._rs

	local header = GGPanelHeader:new("图集管理器", 300)
	header.pos = V.v(20, 14)
	ui.window:add_child(header)

	local status_text = GGLabel:new(V.v(self.ref_w - 240, 28))
	status_text.font_name = "body"
	status_text.font_size = 13 * rs
	status_text.text_align = "right"
	status_text.vertical_align = "middle"
	status_text.colors.text = {180, 190, 220, 255}
	status_text.pos = V.v(240, 14)
	ui.status_label = status_text
	ui.window:add_child(status_text)

	local close_btn = self:make_button("✕", V.v(36, 36))
	close_btn.pos = V.v(self.ref_w - 46, 8)
	close_btn.on_press = function() self:leave() end
	ui.window:add_child(close_btn)

	local sep = KView:new(V.v(self.ref_w - 40, 1))
	sep.colors.background = {95, 75, 40, 255}
	sep.pos = V.v(20, 52)
	ui.window:add_child(sep)

	local btn_y = 58
	self:add_action_button("全部折叠", 20, btn_y, function()
		for _, g in ipairs(state.group_order) do
			state.expanded[g] = nil
		end
		self:rebuild_tree()
	end)

	self:add_action_button("刷新", 150, btn_y, function()
		self:refresh_groups()
	end)

	ui.fps_label = GGLabel:new(V.v(200, 20))
	ui.fps_label.font_name = "body"
	ui.fps_label.font_size = 11 * rs
	ui.fps_label.text_align = "right"
	ui.fps_label.vertical_align = "middle"
	ui.fps_label.colors.text = {120, 130, 160, 255}
	ui.fps_label.pos = V.v(self.ref_w - 220, 58)
end

function atlas_manager:add_action_button(text, x, y, on_press)
	local btn = self:make_button(text, V.v(120, 28))
	btn.pos = V.v(x, y)
	btn.on_press = on_press
	ui.window:add_child(btn)
	return btn
end

function atlas_manager:make_button(text, size)
	local rs = self._rs
	local w = size and size.x or 110
	local h = size and size.y or 34
	local btn = KButton:new(V.v(w, h))
	btn.shape = {name = "rectangle", args = {"fill", 0, 0, w, h, 6, 6}}
	btn.colors.background = {134, 101, 36, 220}
	btn.enabled = true
	btn._hover = false
	btn._label = GGLabel:new(btn.size)
	btn._label.font_name = "body"
	btn._label.font_size = 13 * rs
	btn._label.text_align = "center"
	btn._label.vertical_align = "middle"
	btn._label.fit_lines = 1
	btn._label.fit_size = true
	btn._label.colors.text = {236, 220, 175, 255}
	btn._label.propagate_on_click = true
	btn._label.text = text
	btn:add_child(btn._label)

	function btn:on_enter(drag_view)
		btn._hover = true
		btn.colors.background = {161, 122, 45, 245}
		btn._label.colors.text = {255, 240, 190, 255}
	end
	function btn:on_exit()
		btn._hover = false
		btn.colors.background = {134, 101, 36, 220}
		btn._label.colors.text = {236, 220, 175, 255}
	end
	function btn:on_click(button, vx, vy)
		if not btn.enabled then return end
		S:queue("GUIButtonCommon")
		if btn.on_press then btn.on_press() end
	end
	return btn
end

function atlas_manager:build_controls()
	local rs = self._rs
	local vw, vh = self.ref_w, self.ref_h

	local list_y = 90
	local list_h = vh - list_y - 300

	ui.tree_list = KScrollList:new(V.v(vw - 40, list_h))
	ui.tree_list.pos = V.v(20, list_y)
	ui.tree_list.scroll_amount = 28
	ui.tree_list.colors.scroller_background = {45, 36, 22, 200}
	ui.tree_list.colors.scroller_foreground = {110, 90, 50, 255}
	ui.tree_list.scroller_width = 12
	ui.window:add_child(ui.tree_list)

	local control_y = list_y + list_h + 6
	ui.control_y = control_y

	local sel_label = GGLabel:new(V.v(250, 22))
	sel_label.font_name = "body"
	sel_label.font_size = 13 * rs
	sel_label.text_align = "left"
	sel_label.vertical_align = "middle"
	sel_label.colors.text = {205, 218, 248, 255}
	sel_label.pos = V.v(20, control_y)
	ui.sel_label = sel_label
	ui.window:add_child(sel_label)

	local name_lbl = GGLabel:new(V.v(50, 22))
	name_lbl.font_name = "body"
	name_lbl.font_size = 13 * rs
	name_lbl.text_align = "left"
	name_lbl.vertical_align = "middle"
	name_lbl.colors.text = {205, 218, 248, 255}
	name_lbl.text = "名称:"
	name_lbl.pos = V.v(280, control_y)
	ui.window:add_child(name_lbl)

	local name_input = KView:new(V.v(180, 22))
	name_input.pos = V.v(330, control_y)
	name_input.colors.background = {22, 28, 42, 255}
	name_input.shape = {name = "rectangle", args = {"fill", 0, 0, 180, 22, 4, 4}}
	ui.window:add_child(name_input)

	local name_text = GGLabel:new(V.v(176, 22))
	name_text.font_name = "body"
	name_text.font_size = 13 * rs
	name_text.text_align = "left"
	name_text.vertical_align = "middle"
	name_text.colors.text = {255, 255, 255, 255}
	name_text.text = "merged_atlas"
	name_text.pos = V.v(2, 0)
	name_text.fit_lines = 1
	name_text.fit_size = true
	ui.merge_name_text = name_text
	name_input:add_child(name_text)

	local w_lbl = GGLabel:new(V.v(40, 22))
	w_lbl.font_name = "body"
	w_lbl.font_size = 13 * rs
	w_lbl.text_align = "right"
	w_lbl.vertical_align = "middle"
	w_lbl.colors.text = {205, 218, 248, 255}
	w_lbl.text = "尺寸:"
	w_lbl.pos = V.v(530, control_y)
	ui.window:add_child(w_lbl)

	local function make_size_input(x, initial)
		local inp = KView:new(V.v(64, 22))
		inp.pos = V.v(x, control_y)
		inp.colors.background = {22, 28, 42, 255}
		inp.shape = {name = "rectangle", args = {"fill", 0, 0, 64, 22, 4, 4}}
		ui.window:add_child(inp)

		local txt = GGLabel:new(V.v(60, 22))
		txt.font_name = "body"
		txt.font_size = 13 * rs
		txt.text_align = "center"
		txt.vertical_align = "middle"
		txt.colors.text = {255, 255, 255, 255}
		txt.text = tostring(initial)
		inp:add_child(txt)
		return inp, txt
	end

	ui.merge_w_input, ui.merge_w_text = make_size_input(572, 2048)
	local x_lbl = GGLabel:new(V.v(12, 22))
	x_lbl.font_name = "body"
	x_lbl.font_size = 13 * rs
	x_lbl.text_align = "center"
	x_lbl.vertical_align = "middle"
	x_lbl.colors.text = {205, 218, 248, 255}
	x_lbl.text = "x"
	x_lbl.pos = V.v(638, control_y)
	ui.window:add_child(x_lbl)

	ui.merge_h_input, ui.merge_h_text = make_size_input(650, 2048)

	local function make_size_btn(x, text)
		local btn = self:make_button(text, V.v(48, 22))
		btn.pos = V.v(x, control_y)
		ui.window:add_child(btn)
		return btn
	end

	local presets = {{720, "1K", 1024}, {770, "2K", 2048}, {820, "4K", 4096}}
	for _, p in ipairs(presets) do
		local btn = make_size_btn(p[1], p[2])
		btn.on_press = function()
			state.merge_w = p[3]
			state.merge_h = p[3]
			ui.merge_w_text.text = tostring(p[3])
			ui.merge_h_text.text = tostring(p[3])
		end
	end

	local action_y = control_y + 26

	local merge_btn = self:make_button("合并", V.v(80, 26))
	merge_btn.pos = V.v(20, action_y)
	merge_btn.on_press = function() self:do_merge() end
	ui.window:add_child(merge_btn)

	local preview_btn = self:make_button("预览合并", V.v(110, 26))
	preview_btn.pos = V.v(110, action_y)
	preview_btn.on_press = function() self:preview_merge() end
	ui.window:add_child(preview_btn)

	local del_btn = self:make_button("删除帧", V.v(100, 26))
	del_btn.pos = V.v(230, action_y)
	del_btn.on_press = function() self:delete_frames() end
	ui.window:add_child(del_btn)

	local rename_btn = self:make_button("重命名", V.v(100, 26))
	rename_btn.pos = V.v(340, action_y)
	rename_btn.on_press = function() self:rename_atlas() end
	ui.window:add_child(rename_btn)

	local export_btn = self:make_button("导出PNG", V.v(100, 26))
	export_btn.pos = V.v(450, action_y)
	export_btn.on_press = function() self:export_png() end
	ui.window:add_child(export_btn)

	local unload_btn = self:make_button("释放纹理", V.v(110, 26))
	unload_btn.pos = V.v(560, action_y)
	unload_btn.on_press = function() self:unload_all_textures() end
	ui.window:add_child(unload_btn)

	ui.select_y = action_y + 30
end

function atlas_manager:build_preview_area()
	local rs = self._rs
	local vw = self.ref_w
	local select_y = ui.select_y

	local preview_h = self.ref_h - select_y - 40
	preview_h = math.max(50, preview_h)

	local preview_title = GGLabel:new(V.v(vw - 40, 18))
	preview_title.font_name = "body"
	preview_title.font_size = 12 * rs
	preview_title.text_align = "left"
	preview_title.vertical_align = "middle"
	preview_title.colors.text = {180, 190, 220, 255}
	preview_title.text = "合并预览"
	preview_title.pos = V.v(20, select_y)
	ui.window:add_child(preview_title)

	local preview_y = select_y + 20

	ui.preview_panel = PreviewCanvas:new(V.v(vw - 40, preview_h), function()
		return self
	end)
	ui.preview_panel.pos = V.v(20, preview_y)
	ui.preview_panel.colors.background = {26, 33, 50, 255}
	ui.preview_panel.shape = {name = "rectangle", args = {"fill", 0, 0, vw - 40, preview_h, 6, 6}}
	ui.window:add_child(ui.preview_panel)

	ui.button_y = preview_y + preview_h + 4
end

function atlas_manager:build_button_bar()
	local vw = self.ref_w
	local by = ui.button_y or (self.ref_h - 40)

	local bw = 150
	local gap = 16
	local total = bw * 4 + gap * 3
	local sx = (vw - total) * 0.5

	do
		local btn = self:make_button("保存并热重载", V.v(bw, 32))
		btn.pos = V.v(sx, by)
		btn.on_press = function() self:save(true) end
		ui.window:add_child(btn)
	end
	do
		local btn = self:make_button("保存(仅文件)", V.v(bw, 32))
		btn.pos = V.v(sx + bw + gap, by)
		btn.on_press = function() self:save(false) end
		ui.window:add_child(btn)
	end
	do
		local btn = self:make_button("放弃修改", V.v(bw, 32))
		btn.pos = V.v(sx + (bw + gap) * 2, by)
		btn.on_press = function() self:leave() end
		ui.window:add_child(btn)
	end
	do
		local btn = self:make_button("DDS命令", V.v(bw, 32))
		btn.pos = V.v(sx + (bw + gap) * 3, by)
		btn.on_press = function() self:print_dds_commands() end
		ui.window:add_child(btn)
	end
end

local _dds_cache = {}

function atlas_manager:_get_dds_dim(dds_key)
	if _dds_cache[dds_key] then
		return _dds_cache[dds_key][1], _dds_cache[dds_key][2]
	end
	local w, h = atlas_util.get_dds_dimensions(ATLAS_DIR .. "/" .. dds_key .. ".dds")
	_dds_cache[dds_key] = {w, h}
	return w, h
end

function atlas_manager:refresh_groups()
	state.groups = {}
	state.group_order = {}
	state.selected_frames = {}
	state.frame_checks = {}
	state.expanded = {}

	local files = atlas_util.scan_atlas_files(ATLAS_DIR)
	for _, f in ipairs(files) do
		local tbl, err = atlas_util.load_atlas_lua(f.path)
		if tbl then
			local frames = {}
			local dds_map = {}
			local has_png = false
			local normalize_count = 0

			for k, v in pairs(tbl) do
				local a_name = v.a_name or ""
				local dds_key = a_name:match("^(.+)%.[^.]+$") or a_name
				local ref = v.ref_scale or 1
				local a_sz = v.a_size or {0, 0}
				local fq = v.f_quad or {0, 0, 0, 0}
				local logical_size = a_sz
				local actual_w, actual_h = self:_get_dds_dim(dds_key)
				if actual_w and actual_h and actual_w > 0 and a_sz[1] > 0 then
					local sx = actual_w / a_sz[1]
					local sy = actual_h / a_sz[2]
					fq = {
						math.floor(fq[1] * sx + 0.5),
						math.floor(fq[2] * sy + 0.5),
						math.floor(fq[3] * sx + 0.5),
						math.floor(fq[4] * sy + 0.5),
					}
					a_sz = {actual_w, actual_h}
					local trim_src = v.trim or {0, 0, 0, 0}
					v.size = {math.floor(v.size[1] * sx + 0.5), math.floor(v.size[2] * sy + 0.5)}
					v.trim = {
						math.floor(trim_src[1] * sx + 0.5),
						math.floor(trim_src[2] * sy + 0.5),
						math.floor(trim_src[3] * sx + 0.5),
						math.floor(trim_src[4] * sy + 0.5),
					}
					ref = ref / sx
					normalize_count = normalize_count + 1
				end
				frames[k] = {
					a_name = a_name,
					size = v.size,
					trim = v.trim or {0, 0, 0, 0},
					a_size = a_sz,
					f_quad = fq,
					alias = v.alias or {},
					ref_scale = ref,
					dds_key = dds_key,
				}
				dds_map[dds_key] = true
			end

			local has_png = false
			for dds_key, _ in pairs(dds_map) do
				if FS.getInfo(IMAGES_DIR .. "/" .. dds_key .. ".png", "file") then
					has_png = true
					break
				end
			end

			state.groups[f.base] = {
				name = f.base,
				path = f.path,
				frames = frames,
				frame_order = table.keys(tbl),
				dds_files = table.keys(dds_map),
				has_png_archive = has_png,
			}
			state.group_order[#state.group_order + 1] = f.base
		end
	end

	self:set_status(string.format("已加载 %d 个图集", #state.group_order))
	self:rebuild_tree()
end

function atlas_manager:rebuild_tree()
	-- save scroll fraction
	local saved_frac = 0
	local sl = ui.tree_list
	if sl._bottom_y and sl._bottom_y > sl.size.y then
		saved_frac = (-sl.scroll_origin_y) / (sl._bottom_y - sl.size.y)
	end

	sl:clear_rows()
	local rs = GGLabel.static.ref_h / REF_H

	local sel_count = 0
	for _, v in pairs(state.selected_frames) do
		if v then sel_count = sel_count + 1 end
	end
	ui.sel_label.text = string.format("选中: %d 帧", sel_count)
	print(string.format("[atlas_manager] rebuild_tree: %d groups, %d selected", #state.group_order, sel_count))

	-- sort: groups with selected frames first, then the rest
	local sorted_groups = {}
	for _, gname in ipairs(state.group_order) do
		sorted_groups[#sorted_groups + 1] = gname
	end
	local has_selected_in_group = {}
	for key, checked in pairs(state.selected_frames) do
		if checked then
			local dot = key:find("%.")
			if dot then
				has_selected_in_group[key:sub(1, dot - 1)] = true
			end
		end
	end
	table.sort(sorted_groups, function(a, b)
		local sa = has_selected_in_group[a] and 1 or 0
		local sb = has_selected_in_group[b] and 1 or 0
		if sa ~= sb then return sa > sb end
		return a < b
	end)

	local row_w = sl.size.x

		for _, gname in ipairs(sorted_groups) do
		local group = state.groups[gname]
		if group then
			local expanded = state.expanded[gname]
			local has_sel = has_selected_in_group[gname]

			-- check if all frames in this group are selected
			local total_frames = #group.frame_order
			local sel_in_group = 0
			for _, fn in ipairs(group.frame_order) do
				if state.selected_frames[gname .. "." .. fn] then
					sel_in_group = sel_in_group + 1
				end
			end
			local all_selected = sel_in_group == total_frames and total_frames > 0

			local group_row = KView:new(V.v(row_w, 28))
			group_row.propagate_on_click = true
			group_row.propagate_on_down = true
			group_row.propagate_on_up = true
			if all_selected then
				group_row.colors.background = {52, 118, 210, 120}
			elseif has_sel then
				group_row.colors.background = {52, 118, 210, 50}
			end

			local expand_btn = KView:new(V.v(14, 14))
			expand_btn.pos = V.v(4, 7)
			expand_btn.propagate_on_click = true
			group_row:add_child(expand_btn)

			local gname_text = GGLabel:new(V.v(260, 28))
			gname_text.font_name = "body"
			gname_text.font_size = 13 * rs
			gname_text.text_align = "left"
			gname_text.vertical_align = "middle"
			gname_text.colors.text = all_selected and {220, 240, 255, 255} or {238, 244, 255, 255}
			gname_text.text = gname
			gname_text.pos = V.v(22, 0)
			gname_text.fit_lines = 1
			gname_text.fit_size = true
			group_row:add_child(gname_text)

			local count_text = GGLabel:new(V.v(50, 28))
			count_text.font_name = "body"
			count_text.font_size = 11 * rs
			count_text.text_align = "left"
			count_text.vertical_align = "middle"
			count_text.colors.text = all_selected and {200, 220, 255, 255} or {150, 170, 200, 255}
			count_text.text = string.format("(%d)", total_frames)
			count_text.pos = V.v(285, 0)
			group_row:add_child(count_text)

			local group_sel_all = self:make_button("全选", V.v(34, 18))
			group_sel_all.pos = V.v(312, 5)
			group_sel_all._label.font_size = 10 * rs
			group_sel_all.on_press = function()
				for _, fname in ipairs(group.frame_order) do
					state.selected_frames[gname .. "." .. fname] = true
				end
				self:rebuild_tree()
			end
			group_row:add_child(group_sel_all)

			local group_unsel_all = self:make_button("取消", V.v(34, 18))
			group_unsel_all.pos = V.v(348, 5)
			group_unsel_all._label.font_size = 10 * rs
			group_unsel_all.on_press = function()
				for _, fname in ipairs(group.frame_order) do
					state.selected_frames[gname .. "." .. fname] = nil
				end
				self:rebuild_tree()
			end
			group_row:add_child(group_unsel_all)

			local png_label = GGLabel:new(V.v(20, 28))
			png_label.font_name = "body"
			png_label.font_size = 10 * rs
			png_label.text_align = "center"
			png_label.vertical_align = "middle"
			png_label.colors.text = group.has_png_archive and {100, 200, 100, 255} or {150, 150, 150, 180}
			png_label.text = group.has_png_archive and "P" or "D"
			png_label.pos = V.v(row_w - 22, 0)
			group_row:add_child(png_label)

			function expand_btn._draw_self()
				local G2 = love.graphics
				local cx, cy = 7, 7
				local r = 5
				if expanded then
					G2.setColor(220/255, 200/255, 150/255, 1)
					G2.polygon("fill", cx - r, cy - r * 0.4, cx + r, cy - r * 0.4, cx, cy + r * 0.6)
				else
					G2.setColor(200/255, 180/255, 130/255, 1)
					G2.polygon("fill", cx - r * 0.4, cy - r, cx + r * 0.6, cy, cx - r * 0.4, cy + r)
				end
			end

			function expand_btn.on_click()
				if state.expanded[gname] then
					state.expanded[gname] = nil
				else
					state.expanded[gname] = true
				end
				self:rebuild_tree()
			end

			ui.tree_list:add_row(group_row)

			if expanded then
				state.loading_group = gname
				local sorted_fnames = {}
				local sel_fnames, unsel_fnames = {}, {}
				for _, fn in ipairs(group.frame_order) do
					if state.selected_frames[gname .. "." .. fn] then
						sel_fnames[#sel_fnames + 1] = fn
					else
						unsel_fnames[#unsel_fnames + 1] = fn
					end
				end
				for _, fn in ipairs(sel_fnames) do sorted_fnames[#sorted_fnames + 1] = fn end
				for _, fn in ipairs(unsel_fnames) do sorted_fnames[#sorted_fnames + 1] = fn end

				for fi, fname in ipairs(sorted_fnames) do
					local frame = group.frames[fname]
					local key = gname .. "." .. fname
					local checked = state.selected_frames[key]

					local frame_row = KView:new(V.v(ui.tree_list.size.x, 24))
					frame_row.propagate_on_click = true
					frame_row.propagate_on_down = true
					frame_row.propagate_on_up = true
					frame_row.colors.background = checked and {52, 118, 210, 180} or nil

					local cb_view = KView:new(V.v(14, 14))
					cb_view.pos = V.v(20, 5)
					cb_view.propagate_on_click = true
					frame_row:add_child(cb_view)
					cb_view._checked = checked

					do
						local cv = cb_view
						function cv._draw_self()
							local G2 = love.graphics
							local s = 14
							if cv._checked then
								G2.setColor(52/255, 118/255, 210/255, 1)
								G2.rectangle("fill", 0, 0, s, s)
								G2.setColor(1, 1, 1, 230/255)
								G2.setLineWidth(2)
								G2.line(3, 8, 6, 11)
								G2.line(6, 11, 11, 3)
								G2.setLineWidth(1)
							else
								G2.setColor(100/255, 130/255, 180/255, 120/255)
								G2.setLineWidth(1.5)
								G2.rectangle("line", 0, 0, s, s)
								G2.setLineWidth(1)
							end
						end
					end

					do
						local cv = cb_view
						local k = key
						function cv.on_click()
							if state.selected_frames[k] then
								state.selected_frames[k] = nil
							else
								state.selected_frames[k] = true
							end
							self:rebuild_tree()
						end
					end

					local frame_label = GGLabel:new(V.v(ui.tree_list.size.x - 60, 24))
					frame_label.font_name = "body"
					frame_label.font_size = 12 * rs
					frame_label.text_align = "left"
					frame_label.vertical_align = "middle"
					frame_label.colors.text = checked and {220, 240, 255, 255} or {180, 190, 210, 255}
					local size_str = string.format("%dx%d", frame.size[1], frame.size[2])
					local alias_count = #(frame.alias or {})
					local alias_str = alias_count > 0 and string.format(" alias:%d", alias_count) or ""
					frame_label.text = string.format("  %s  [%s]%s", fname, size_str, alias_str)
					frame_label.pos = V.v(38, 0)
					frame_label.fit_lines = 1
					frame_label.fit_size = true
					frame_label.propagate_on_click = true
					frame_row:add_child(frame_label)

					do
						local cv = cb_view
						function frame_row.on_click()
							cv.on_click()
						end
					end

					sl:add_row(frame_row)
				end
				state.loading_group = nil
			end
		end
	end

	-- restore scroll position
	if saved_frac > 0 and sl._bottom_y and sl._bottom_y > sl.size.y then
		local max_scroll = -(sl._bottom_y - sl.size.y)
		sl.scroll_origin_y = math.max(max_scroll, -(saved_frac * (sl._bottom_y - sl.size.y)))
		sl._target_y = sl.scroll_origin_y
	end
end

function atlas_manager:update(dt)
	if ui.window then
		ui.window:update(dt)
	end
	self:update_fps()
	return true
end

function atlas_manager:update_fps()
	if ui.fps_label then
		local stats = G.getStats()
		ui.fps_label.text = string.format("纹理: %.0fMB | 帧: %d", stats.texturememory / 1048576, stats.drawcalls)
	end
end

function atlas_manager:draw()
	if ui.window then
		ui.window:draw()
	end
end

function atlas_manager:_calc_utilization()
	if not state.preview_frames then return 0 end
	local total_pixels = state.merge_w * state.merge_h
	local used_pixels = 0
	for _, p in ipairs(state.preview_frames) do
		used_pixels = used_pixels + p.w * p.h
	end
	if total_pixels == 0 then return 0 end
	return (used_pixels / total_pixels) * 100
end

function atlas_manager:get_selected_frame_list()
	local selected = {}
	for key, checked in pairs(state.selected_frames) do
		if checked then
			local dot = key:find("%.")
			if dot then
				local gname = key:sub(1, dot - 1)
				local fname = key:sub(dot + 1)
				local group = state.groups[gname]
				if group and group.frames[fname] then
					selected[#selected + 1] = {
						group = gname,
						frame_name = fname,
						frame = group.frames[fname],
					}
				end
			end
		end
	end
	return selected
end

function atlas_manager:do_merge()
	print("[atlas_manager] merge: start")
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("没有选中任何帧")
		return
	end

	local name = ui.merge_name_text and ui.merge_name_text.text or "merged_atlas"
	if name == "" then name = "merged_atlas" end
	local w = tonumber(ui.merge_w_text and ui.merge_w_text.text) or state.merge_w
	local h = tonumber(ui.merge_h_text and ui.merge_h_text.text) or state.merge_h

	if not self:_is_pow2(w) or not self:_is_pow2(h) then
		self:set_status("图集尺寸必须是2的幂次")
		return
	end

	local pack_frames = {}
	for _, sel in ipairs(selected) do
		local f = sel.frame
		pack_frames[#pack_frames + 1] = {
			w = f.f_quad[3],
			h = f.f_quad[4],
			frame_name = sel.frame_name,
			group = sel.group,
		}
	end

	local placements, err = atlas_binpack.pack(pack_frames, w, h)
	if not placements then
		self:set_status("打包失败: " .. err)
		return
	end

	local all_frames = {}
	for _, sel in ipairs(selected) do
		all_frames[sel.frame_name] = sel.frame
	end

	state.preview_frames = placements
	state.merge_name = name
	state.merge_w = w
	state.merge_h = h

	local sel_info = {}
	for _, p in ipairs(placements) do
		sel_info[p.frame_name] = all_frames[p.frame_name]
	end

	self._merge_placements = placements
	self._merge_src_frames = all_frames
	self._merge_full_frames = sel_info

	local util = self:_calc_utilization()
	print(string.format("[atlas_manager] merge: %d frames into %dx%d, pack=ok, util=%.1f%%", #placements, w, h, util))
	self:set_status(string.format("合并完成: %d帧打包到 %dx%d 图集 (%.1f%%)", #placements, w, h, util))
	self:preview_merge()
end

function atlas_manager:preview_merge()
	print("[atlas_manager] preview_merge: start")
	if not self._merge_placements or not self._merge_src_frames then
		local selected = self:get_selected_frame_list()
		if #selected == 0 then
			self:set_status("没有选中任何帧")
			return
		end
		self:do_merge()
		return
	end

	local placements = self._merge_placements
	local all_frames = self._merge_src_frames
	local w = state.merge_w
	local h = state.merge_h

	if state.preview_canvas then
		state.preview_canvas:release()
		state.preview_canvas = nil
	end

	local need_load = {}
	for _, p in ipairs(placements) do
		local frame = all_frames[p.frame_name]
		if frame and not frame._preview_texture then
			local dds_key = frame.dds_key
			if not need_load[dds_key] then
				need_load[dds_key] = {frames = {}, texture = nil, tex_w = 0, tex_h = 0}
			end
			need_load[dds_key].frames[p.frame_name] = frame
		end
	end

	local total_loads = 0
	for dds_key, info in pairs(need_load) do
		local dds_path = ATLAS_DIR .. "/" .. dds_key .. ".dds"
		local img, err, tw, th = atlas_util.load_dds_preview(dds_path)
		if img then
			info.texture = img
			info.tex_w = tw
			info.tex_h = th
			total_loads = total_loads + 1
			print(string.format("[atlas_manager] dds_load: %s (%dx%d)", dds_key, tw, th))
		else
			local alt_path = ATLAS_DIR .. "/" .. dds_key:gsub("%-1$", "") .. ".dds"
			img, err, tw, th = atlas_util.load_dds_preview(alt_path)
			if img then
				info.texture = img
				info.tex_w = tw
				info.tex_h = th
				total_loads = total_loads + 1
			end
		end
	end

	if total_loads == 0 and next(need_load) then
		self:set_status("无法加载纹理用于预览 (DDS文件不存在?)")
		state.preview_valid = false
		return
	end

	for dds_key, info in pairs(need_load) do
		if info.texture then
			for fname, frame in pairs(info.frames) do
				frame._preview_texture = info.texture
				local idata = atlas_util.extract_frame_pixels(info.texture, frame.f_quad, info.tex_w, info.tex_h)
				frame._preview_idata = idata
			end
		end
	end

	local merged_idata = atlas_util.create_merged_atlas(placements, all_frames, w, h)
	print(string.format("[atlas_manager] preview_canvas: %dx%d created", w, h))
	state.preview_canvas = G.newCanvas(w, h)
	G.setCanvas(state.preview_canvas)
	G.setColor(1, 1, 1, 1)
	local preview_img = G.newImage(merged_idata)
	G.draw(preview_img, 0, 0)
	G.setCanvas()

	preview_img:release()
	state.preview_valid = true
	state.preview_idata = merged_idata

	for dds_key, info in pairs(need_load) do
		for fname, frame in pairs(info.frames) do
			frame._preview_idata = nil
		end
	end

	self:set_status("预览已生成")
end

function atlas_manager:delete_frames()
	print("[atlas_manager] delete: start")
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("没有选中任何帧")
		return
	end

	local delete_map = {}
	for _, sel in ipairs(selected) do
		local gname = sel.group
		local fname = sel.frame_name
		if not delete_map[gname] then delete_map[gname] = {} end
		delete_map[gname][#delete_map[gname] + 1] = fname
		state.selected_frames[gname .. "." .. fname] = nil
	end

	local total_del = 0
	for gname, fnames in pairs(delete_map) do
		local group = state.groups[gname]
		if group then
			for _, fname in ipairs(fnames) do
				print(string.format("[atlas_manager] delete: %s/%s", gname, fname))
				group.frames[fname] = nil
				total_del = total_del + 1
			end
			local new_order = {}
			for _, fn in ipairs(group.frame_order) do
				if group.frames[fn] then
					new_order[#new_order + 1] = fn
				end
			end
			group.frame_order = new_order
		end
	end

	state.dirty = true
	self:rebuild_tree()
	self:set_status(string.format("已标记 %d 帧为删除 (保存后生效)", total_del))
	print(string.format("[atlas_manager] delete_total: %d frames marked", total_del))
end

function atlas_manager:rename_atlas()
	print("[atlas_manager] rename: start")
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("在要重命名的图集中选中任意帧")
		return
	end

	local groups = {}
	for _, sel in ipairs(selected) do
		groups[sel.group] = true
	end
	if #table.keys(groups) ~= 1 then
		self:set_status("只能重命名单个图集 — 选中的帧来自多个图集")
		return
	end

	local old_name = table.keys(groups)[1]
	local new_name = ui.merge_name_text and ui.merge_name_text.text or ""
	if new_name == "" or new_name == old_name then
		self:set_status("请输入新名称 (修改\"名称\"输入框)")
		return
	end

	local group = state.groups[old_name]
	if not group then return end

	state.groups[new_name] = group
	state.groups[new_name].name = new_name
	state.groups[old_name] = nil
	state.expanded[new_name] = state.expanded[old_name]
	state.expanded[old_name] = nil

	for i, gn in ipairs(state.group_order) do
		if gn == old_name then
			state.group_order[i] = new_name
			break
		end
	end

	self._rename_map = self._rename_map or {}
	self._rename_map[old_name] = new_name
	state.dirty = true

	local rename_source = old_name
	local rename_dest = new_name
	self:rebuild_tree()
	print(string.format("[atlas_manager] rename: '%s' -> '%s'", rename_source, rename_dest))
	self:set_status(string.format("图集 \"%s\" 将重命名为 \"%s\" (保存后生效)", rename_source, rename_dest))
end

function atlas_manager:export_png()
	if not state.preview_canvas or not state.preview_valid then
		self:set_status("请先预览合并结果")
		return
	end
	if not state.preview_idata then
		self:set_status("预览数据无效")
		return
	end

	local name = ui.merge_name_text and ui.merge_name_text.text or "merged_atlas"
	FS.createDirectory(IMAGES_DIR)
	local png_path = IMAGES_DIR .. "/" .. name .. ".png"
	local ok = atlas_util.save_png(state.preview_idata, png_path)
	if ok then
		print(string.format("[atlas_manager] export_png: %s (%dx%d)", png_path, state.merge_w, state.merge_h))
		self:set_status(string.format("已导出PNG: %s", png_path))
	else
		self:set_status("PNG导出失败")
	end
end

function atlas_manager:save(hot_reload)
	print(string.format("[atlas_manager] save: start (hot_reload=%s)", tostring(hot_reload)))
	local has_selected = next(state.selected_frames) ~= nil
	local has_deleted = state.dirty

	if not has_selected and not has_deleted then
		self:set_status("没有修改需要保存")
		return
	end

	FS.createDirectory(BACKUP_DIR)

	if has_deleted then
		for _, gname in ipairs(state.group_order) do
			local group = state.groups[gname]
			if group and group.frames then
				local frame_count = 0
				for _, fn in ipairs(group.frame_order) do
					if group.frames[fn] then frame_count = frame_count + 1 end
				end
				if frame_count == 0 then return self:set_status("图集 " .. gname .. " 已无帧, 无法保存") end

				local lua_data = FS.load(group.path)
				if lua_data then
					local ok, src_tbl = pcall(lua_data)
					if ok and type(src_tbl) == "table" then
						for fname, _ in pairs(src_tbl) do
							if not group.frames[fname] then
								src_tbl[fname] = nil
							end
						end

						local merged_name = gname
						local bp = atlas_util.backup_files(ATLAS_DIR, merged_name, BACKUP_DIR)
						print(string.format("[atlas_manager] save_backup: %s -> %s", merged_name, bp))
						local ok_write, err_write = atlas_util.write_atlas_files(ATLAS_DIR, merged_name, src_tbl)
						if not ok_write then
							return self:set_status("写入失败: " .. tostring(err_write))
						end
					end
				end
			end
		end
	end

	if has_selected then
		local name = ui.merge_name_text and ui.merge_name_text.text or "merged_atlas"
		if name == "" then name = "merged_atlas" end
		if not self._merge_placements then
			self:do_merge()
		end
		if not self._merge_placements or not state.preview_idata then
			return
		end

		local placements = self._merge_placements
		local all_frames = self._merge_src_frames
		local w = state.merge_w
		local h = state.merge_h

		local dds_name = name .. "-1"
		FS.createDirectory(IMAGES_DIR)
		atlas_util.save_png(state.preview_idata, IMAGES_DIR .. "/" .. dds_name .. ".png")
		print(string.format("[atlas_manager] save_merge: %s png=%s.png a_size=%dx%d", name, dds_name, w, h))

		local new_frames = {}
		for _, p in ipairs(placements) do
			local src = all_frames[p.frame_name]
			new_frames[p.frame_name] = {
				a_name = dds_name .. ".dds",
				size = {src.size[1], src.size[2]},
				trim = {src.trim[1], src.trim[2]},
				a_size = {w, h},
				f_quad = {p.x, p.y, p.w, p.h},
				alias = type(src.alias) == "table" and src.alias or {},
				ref_scale = src.ref_scale or 1,
			}
		end

		local bp = atlas_util.backup_files(ATLAS_DIR, name, BACKUP_DIR)
		print(string.format("[atlas_manager] save_backup: %s -> %s", name, bp))
		local ok, err = atlas_util.write_atlas_files(ATLAS_DIR, name, new_frames)
		if not ok then
			return self:set_status("写入文件失败: " .. (err or "unknown"))
		end
		print(string.format("[atlas_manager] save_compile: %s .lua/.luac/.aluac written", name))

		self._pending_dds_commands = atlas_util.generate_nvcompress_commands(IMAGES_DIR, ATLAS_DIR, name, 1)
		self:set_status(string.format("已保存 %s.", name))

		if hot_reload then
			self:_hot_reload_group(name, new_frames, w, h)
			state.preview_valid = false
			if state.preview_canvas then
				state.preview_canvas:release()
				state.preview_canvas = nil
			end
			state.preview_frames = nil
			self._merge_placements = nil
			self._merge_src_frames = nil
		end
	end

	state.dirty = false
	self:rebuild_tree()
	self:set_status(string.format("保存完成. %s", hot_reload and "已热重载" or "重启后生效"))
	print(string.format("[atlas_manager] save: done (hot_reload=%s)", tostring(hot_reload)))
end

function atlas_manager:_hot_reload_group(name, frames, w, h)
	print(string.format("[atlas_manager] hot_reload: %s start", name))
	local dds_key = name .. "-1"
	local png_path = IMAGES_DIR .. "/" .. dds_key .. ".png"
	local png_info = FS.getInfo(png_path)
	if not png_info then
		self:set_status("热重载需要PNG文件, 但 .images 中未找到")
		return
	end

	local ok, img = pcall(G.newImage, png_path)
	if not ok then
		self:set_status("热重载: 无法加载PNG纹理")
		return
	end

	local img_w, img_h = img:getDimensions()

	I.db_images[dds_key] = {img, img_w, img_h}
	I.image_uses[dds_key] = (I.image_uses[dds_key] or 0) + 1

	local name_scale = string.format("%s-%.6f", name, 1)
	I.atlas_uses[name_scale] = (I.atlas_uses[name_scale] or 0) + 1

	for fname, fdata in pairs(frames) do
		I.db_atlas[fname] = {
			atlas = dds_key,
			group = name_scale,
			quad = G.newQuad(fdata.f_quad[1], fdata.f_quad[2], fdata.f_quad[3], fdata.f_quad[4], img_w, img_h),
			trim = {fdata.trim[1], fdata.trim[2]},
			ref_scale = fdata.ref_scale or 1,
			size = {fdata.size[1], fdata.size[2]},
		}
		for i = 1, #(fdata.alias or {}) do
			I.db_atlas[fdata.alias[i]] = I.db_atlas[fname]
		end
	end

	print(string.format("[atlas_manager] hot_reload: %s from %s (%dx%d) %d frames -> image_db", name, png_path, img_w, img_h, #frames))
	self:set_status("热重载完成: " .. name)
end

function atlas_manager:print_dds_commands()
	local cmds = self._pending_dds_commands
	if not cmds or #cmds == 0 then
		local name = ui.merge_name_text and ui.merge_name_text.text or "merged_atlas"
		cmds = atlas_util.generate_nvcompress_commands(IMAGES_DIR, ATLAS_DIR, name, 1)
	end

	local output = "-- DDS转换命令 (在项目根目录运行):\n"
	for _, cmd in ipairs(cmds) do
		output = output .. cmd .. "\n"
	end

	local cmd_path = ATLAS_DIR .. "/convert_dds_commands.sh"
	FS.write(cmd_path, output)
	print(string.format("[atlas_manager] dds_cmds: %d cmds -> %s", #cmds, cmd_path))
	self:set_status(string.format("DDS转换命令已写入: %s (%d条)", cmd_path, #cmds))
end

function atlas_manager:set_status(text)
	if ui.status_label then
		ui.status_label.text = text
	end
	print("[atlas_manager] " .. tostring(text))
end

function atlas_manager:unload_all_textures()
	local count = 0
	for key, tex in pairs(state.loaded_textures) do
		if tex and tex.release then
			tex:release()
			count = count + 1
		end
	end
	state.loaded_textures = {}
	print(string.format("[atlas_manager] unload_textures: %d textures released", count))
	self:set_status("已释放所有预览纹理")
end

function atlas_manager:_is_pow2(n)
	if n <= 0 then return false end
	while n % 2 == 0 do n = n / 2 end
	return n == 1
end

function atlas_manager:leave()
	if self._leaving then return end
	self._leaving = true
	print("[atlas_manager] leave: start")
	self:unload_all_textures()
	if state.preview_canvas then
		state.preview_canvas:release()
		state.preview_canvas = nil
	end
	print("[atlas_manager] leave: switching to map")
	self.done_callback({next_item_name = "map"})
end

function atlas_manager:destroy()
	self:unload_all_textures()
	if state.preview_canvas then
		state.preview_canvas:release()
		state.preview_canvas = nil
	end
	for gname, group in pairs(state.groups) do
		for _, frame in pairs(group.frames) do
			frame._preview_texture = nil
			frame._preview_idata = nil
		end
	end
	state.groups = {}
	state.group_order = {}
	state.expanded = {}
	state.selected_frames = {}
	state.preview_frames = nil
	state.preview_idata = nil
	ui.window = nil
	print("[atlas_manager] destroy: freed")
end

function atlas_manager:mousepressed(x, y, button)
	if ui.window then ui.window:mousepressed(x, y, button) end
end

function atlas_manager:mousereleased(x, y, button)
	if ui.window then ui.window:mousereleased(x, y, button) end
end

function atlas_manager:wheelmoved(dx, dy)
	if ui.window then ui.window:wheelmoved(dx, dy) end
end

function atlas_manager:keypressed(key, isrepeat)
	if isrepeat then return end
	if key == "escape" then
		self:leave()
	end
end

return atlas_manager
