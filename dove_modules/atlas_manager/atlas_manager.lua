local G = love.graphics
local FS = love.filesystem
local utf8 = require("utf8")
local V = require("lib.klua.vector")
local v = V.v
local S = require("sound_db")
local I = require("lib.klove.image_db")
local SU = require("screen_utils")
local file_utlis = require("file_utlis")
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

local function align4(v)
	return math.ceil(v / 4) * 4
end

local project_root = (function()
	local ok, p = pcall(FS.getRealDirectory, "main.lua")
	if ok then
		local idx = p:find("main.lua$")
		if idx then
			return p:sub(1, idx - 2)
		end
		return p
	end
	return "."
end)()

local function real_path(rel)
	return project_root .. "/" .. rel
end

local function read_fs(path)
	local data = FS.read(path)
	if data then
		return data
	end
	local f = io.open(path, "rb")
	if f then
		data = f:read("*all")
		f:close()
		return data
	end
	return nil
end

local function write_real(path, data)
	file_utlis.ensure_parent_dir(path)
	return file_utlis.write_file(path, data)
end

--- 文件内容 md5（十六进制字符串）。love.data.hash 是 C 实现；失败时退回纯 lua 实现。
local function file_md5_hex(data)
	if not data or data == "" then
		return nil
	end
	local ok, h = pcall(love.data.hash, "md5", data)
	if ok and h then
		local ok_hex, hex = pcall(love.data.encode, "string", "hex", h)
		return ok_hex and hex or h
	end
	local ok_lib, md5 = pcall(require, "lib.md5")
	if ok_lib and md5 and md5.sumhexa then
		return md5.sumhexa(data)
	end
	return nil
end

local state = {
	groups = {},
	group_order = {},
	expanded = {},
	selected_frames = {},
	frame_checks = {},
	file_checks = {},
	sort_area_desc = true,
	non_pow2_mode = false,
	dedup_alias = true,
	merge_name = "",
	merge_w = 2048,
	merge_h = 2048,
	preview_canvas = nil,
	preview_valid = false,
	dirty = false,
	preview_frames = nil,
	preview_files = nil,
	merge_pages = nil,
	scale_factor = 1,
	_merged_idata = nil,
	loaded_textures = {}
}

local function align4(v)
	return math.ceil(v / 4) * 4
end

local ui = {}

local CLOSE_BTN_SIZE = 36

local popup = {
	active = false,
	scale = 1,
	ox = 0,
	oy = 0,
	dragging = false,
	lx = 0,
	ly = 0,
	show_list = false,
	sel_idx = 1,
	scroll = 0,
	zoom = 1,
	sb_drag = false,
	sb_y = 0,
	file_idx = 1,
	file_tabs = {}
}

function atlas_manager:show_preview_popup()
	if not state.preview_valid or not state.preview_canvas then
		self:set_status("没有可用的预览")
		return
	end
	popup.active = true
	popup.scale = 1
	popup.ox = 0
	popup.oy = 0
	popup.dragging = false
	popup.sb_drag = false
	popup.sb_scroll = nil
	popup.show_list = false
	popup.sel_idx = 1
	popup.scroll = 0
	popup._last_mx = nil
	popup._last_my = nil
end

function atlas_manager:hide_preview_popup()
	popup.active = false
	popup.file_tabs = {}
end

function atlas_manager:preview_group(gname)
	local group = state.groups[gname]
	if not group then
		return
	end
	-- 松散组（如 .images/append）：把每个 png 作为一页预览，可直接单图查看
	if group._is_loose_group then
		local files = {}
		for _, fname in ipairs(group.frame_order) do
			local frame = group.frames[fname]
			if frame and frame._src_path then
				local ok, data = pcall(love.filesystem.read, frame._src_path)
				if not ok or not data then
					local real = real_path(frame._src_path)
					local fh = io.open(real, "rb")
					if fh then
						data = fh:read("*all")
						fh:close()
					end
				end
				if data then
					local ok2, idata = pcall(love.image.newImageData, love.data.newByteData(data))
					if ok2 then
						local iw, ih = idata:getDimensions()
						local canvas = G.newCanvas(iw, ih)
						G.setCanvas(canvas)
						G.setColor(1, 1, 1, 1)
						G.clear(0, 0, 0, 0)
						G.setBlendMode("alpha", "premultiplied")
						G.draw(G.newImage(idata), 0, 0)
						G.setBlendMode("alpha", "alphamultiply")
						G.setCanvas()
						files[#files + 1] = {
							key = frame.a_name or fname,
							canvas = canvas,
							w = iw,
							h = ih,
							placements = {{
								frame_name = fname,
								x = 0,
								y = 0,
								w = iw,
								h = ih,
								data = {
									group = gname
								}
							}},
							sprite_list = {fname},
							sprite_group = {
								[fname] = gname
							}
						}
					end
				end
			end
		end
		if #files == 0 then
			self:set_status("该图集所有文件都无法加载")
			return
		end
		self:set_preview_files(files)
		self:show_preview_popup()
		return
	end
	if not group.dds_files or #group.dds_files == 0 then
		self:set_status("该图集无可预览的纹理")
		return
	end
	local real_png_dir = project_root .. "/" .. IMAGES_DIR
	local files = {}
	for _, dds_key in ipairs(group.dds_files) do
		local img, err, tw, th = atlas_util.load_source_preview(dds_key, ATLAS_DIR, real_png_dir)
		if img then
			local canvas = G.newCanvas(tw, th)
			G.setCanvas(canvas)
			G.setColor(1, 1, 1, 1)
			G.clear(0, 0, 0, 0)
			G.setBlendMode("alpha", "premultiplied")
			G.draw(img, 0, 0)
			G.setBlendMode("alpha", "alphamultiply")
			G.setCanvas()
			local placements = {}
			local sprite_list = {}
			for _, fn in ipairs(group.frame_order) do
				local frame = group.frames[fn]
				if frame and frame.dds_key == dds_key then
					placements[#placements + 1] = {
						frame_name = fn,
						x = frame.f_quad[1],
						y = frame.f_quad[2],
						w = frame.f_quad[3],
						h = frame.f_quad[4],
						data = {
							group = gname
						}
					}
					sprite_list[#sprite_list + 1] = fn
				end
			end
			files[#files + 1] = {
				key = dds_key,
				canvas = canvas,
				w = tw,
				h = th,
				placements = placements,
				sprite_list = sprite_list,
				sprite_group = {}
			}
			for _, p in ipairs(placements) do
				files[#files].sprite_group[p.frame_name] = gname
			end
		else
			self:set_status(string.format("无法加载纹理 %s: %s", dds_key, tostring(err)))
		end
	end
	if #files == 0 then
		self:set_status("该图集所有文件都无法加载")
		return
	end
	self:set_preview_files(files)
	self:show_preview_popup()
end

function atlas_manager:set_preview_files(files)
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas then
				f.canvas:release()
			end
		end
	end
	state.preview_files = files or {}
	state.preview_canvas = nil
	popup.file_idx = 1
	self:select_preview_file(1)
end

function atlas_manager:select_preview_file(idx)
	local files = state.preview_files
	if not files or #files == 0 then
		return
	end
	idx = math.max(1, math.min(#files, idx))
	popup.file_idx = idx
	local f = files[idx]
	if f.canvas then
		state.preview_canvas = f.canvas
	end
	state.preview_valid = true
	state.merge_w = f.w
	state.merge_h = f.h
	state._placements = f.placements
	state._sprite_list = f.sprite_list
	state._sprite_group = f.sprite_group
	popup.sel_idx = 1
	popup.scroll = 0
	popup.zoom = 1
end

function atlas_manager:preview_group_file(gname, dds_key)
	local group = state.groups[gname]
	if not group then
		return
	end
	local real_png_dir = project_root .. "/" .. IMAGES_DIR
	local img, err, tw, th = atlas_util.load_source_preview(dds_key, ATLAS_DIR, real_png_dir)
	if not img then
		self:set_status("无法加载纹理 " .. tostring(dds_key) .. ": " .. tostring(err))
		return
	end
	local canvas = G.newCanvas(tw, th)
	G.setCanvas(canvas)
	G.setColor(1, 1, 1, 1)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("alpha", "premultiplied")
	G.draw(img, 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	local placements = {}
	local sprite_list = {}
	for _, fn in ipairs(group.frame_order) do
		local frame = group.frames[fn]
		if frame and frame.dds_key == dds_key then
			placements[#placements + 1] = {
				frame_name = fn,
				x = frame.f_quad[1],
				y = frame.f_quad[2],
				w = frame.f_quad[3],
				h = frame.f_quad[4],
				data = {
					group = gname
				}
			}
			sprite_list[#sprite_list + 1] = fn
		end
	end
	local sprite_group = {}
	for _, p in ipairs(placements) do
		sprite_group[p.frame_name] = gname
	end
	self:set_preview_files({{
		key = dds_key,
		canvas = canvas,
		w = tw,
		h = th,
		placements = placements,
		sprite_list = sprite_list,
		sprite_group = sprite_group
	}})
	self:show_preview_popup()
end

local function draw_popup()
	if not popup.active or not state.preview_canvas or not state.preview_valid then
		return
	end
	local G2 = love.graphics
	local sw, sh = love.graphics.getDimensions()
	G2.setColor(0, 0, 0, 200 / 255)
	G2.rectangle("fill", 0, 0, sw, sh)
	local cw, ch = state.preview_canvas:getDimensions()

	-- sprite list sidebar
	if popup.show_list and state._sprite_list then
		local list = state._sprite_list
		local list_w = math.min(480, math.floor(sw * 0.45))
		local area_w = sw - list_w
		local sel = list[popup.sel_idx]
		local pl = nil
		if sel and state._placements then
			for _, p in ipairs(state._placements) do
				if p.frame_name == sel then
					pl = p
					break
				end
			end
		end
		if pl then
			local zoom = popup.zoom
			popup._sprite_pl = pl
			local dw, dh = pl.w * zoom, pl.h * zoom
			local cx = (area_w - dw) * 0.5
			local cy = (sh - dh) * 0.5
			local quad = G2.newQuad(pl.x, pl.y, pl.w, pl.h, cw, ch)
			-- checkerboard background
			local cs = 8
			for gy = 0, math.ceil(dh / cs) do
				for gx = 0, math.ceil(dw / cs) do
					local v = (gx + gy) % 2 == 0 and 0.35 or 0.55
					G2.setColor(v, v, v, 1)
					G2.rectangle("fill", cx + gx * cs, cy + gy * cs, cs, cs)
				end
			end
			G2.setColor(1, 1, 1, 1)
			G2.draw(state.preview_canvas, quad, cx, cy, 0, zoom, zoom)
			G2.setColor(255 / 255, 255 / 255, 255 / 255, 200 / 255)
			G2.print(string.format("%s (%d,%d) %dx%d 缩放:%.0f%% +- X R", sel, pl.x, pl.y, pl.w, pl.h, zoom * 100), 10, 10)
		end
		-- sidebar
		G2.setColor(20 / 255, 25 / 255, 40 / 255, 230 / 255)
		G2.rectangle("fill", area_w, 0, list_w, sh)
		local font = love.graphics.newFont(12)
		G2.setFont(font)
		local lh = font:getHeight() + 2
		local max_visible = math.floor((sh - 20) / lh)
		local view_h = sh - 20
		local scroll_h = #list > max_visible and math.max(20, view_h * max_visible / #list) or 0
		local scroll_y = view_h * popup.scroll / math.max(1, #list)
		for i = 1 + popup.scroll, math.min(#list, popup.scroll + max_visible) do
			local y = (i - 1 - popup.scroll) * lh + 4
			local name = list[i]
			local grp = state._sprite_group and state._sprite_group[name]
			local sel_key = grp and (grp .. "." .. name) or nil
			local is_sel = sel_key and state.selected_frames[sel_key]
			if i == popup.sel_idx then
				G2.setColor(52 / 255, 118 / 255, 210 / 255, 180 / 255)
				G2.rectangle("fill", area_w + 2, y, list_w - 18, lh)
			end
			if not is_sel and sel_key then
				G2.setColor(255 / 255, 100 / 255, 100 / 255, 200 / 255)
				G2.print("✕", area_w + 4, y)
			end
			G2.setColor(200 / 255, 210 / 255, 230 / 255, 255 / 255)
			G2.print(name, area_w + 16, y)
		end
		if scroll_h > 0 then
			local sb_w = 16
			local sb_x = sw - sb_w - 4
			G2.setColor(80 / 255, 80 / 255, 100 / 255, 150 / 255)
			G2.rectangle("fill", sb_x, 4, sb_w, view_h)
			G2.setColor(160 / 255, 170 / 255, 200 / 255, 200 / 255)
			G2.rectangle("fill", sb_x, 4 + scroll_y, sb_w, scroll_h)
			popup._sb_x = sb_x
			popup._sb_w = sb_w
			popup._sb_y0 = 4
			popup._sb_h = view_h
			popup._sb_scroll_h = scroll_h
		end
		local cs = CLOSE_BTN_SIZE
		G2.setColor(200 / 255, 60 / 255, 60 / 255, 200 / 255)
		G2.rectangle("fill", sw - cs, 0, cs, cs)
		G2.setColor(1, 1, 1, 1)
		G2.printf("✕", sw - cs, 6, cs, "center")
		return
	end

	-- full atlas view
	local max_w = sw * 0.9
	local max_h = sh * 0.9
	local fit = math.min(max_w / cw, max_h / ch, 1)
	local s = fit * popup.scale
	local cx = (sw - cw * s) * 0.5 + popup.ox
	local cy = (sh - ch * s) * 0.5 + popup.oy
	G2.setColor(1, 1, 1, 1)
	G2.draw(state.preview_canvas, cx, cy, 0, s, s)
	-- file tabs
	popup.file_tabs = {}
	if state.preview_files and #state.preview_files > 1 then
		local font = love.graphics.newFont(11)
		G2.setFont(font)
		local tab_h = 22
		local tab_y = 34
		local total = 0
		local tabs_w = {}
		for i, f in ipairs(state.preview_files) do
			local label = string.format("%s (%dx%d)", f.key, f.w, f.h)
			local twx = font:getWidth(label) + 16
			tabs_w[i] = twx
			total = total + twx + 6
		end
		local start_x = math.max(10, (sw - total) * 0.5)
		for i, f in ipairs(state.preview_files) do
			local twx = tabs_w[i]
			local is_cur = (i == popup.file_idx)
			if is_cur then
				G2.setColor(52 / 255, 118 / 255, 210 / 255, 230 / 255)
			else
				G2.setColor(35 / 255, 42 / 255, 66 / 255, 230 / 255)
			end
			G2.rectangle("fill", start_x, tab_y, twx, tab_h)
			G2.setColor(230 / 255, 240 / 255, 255 / 255, 255 / 255)
			G2.print(string.format("%s", f.key), start_x + 8, tab_y + 5)
			popup.file_tabs[i] = {
				x = start_x,
				y = tab_y,
				w = twx,
				h = tab_h
			}
			start_x = start_x + twx + 6
		end
	end
	local file_label = ""
	if state.preview_files and #state.preview_files > 1 then
		local f = state.preview_files[popup.file_idx]
		file_label = string.format(" | 文件 %d/%d: %s", popup.file_idx, #state.preview_files, f and f.key or "?")
	end
	G2.setColor(255 / 255, 255 / 255, 255 / 255, 200 / 255)
	G2.print(string.format("图集: %dx%d | 缩放: %.0f%% | S键列表 | ESC关闭%s", cw, ch, s * 100, file_label), 10, 10)
	local cs = CLOSE_BTN_SIZE
	G2.setColor(200 / 255, 60 / 255, 60 / 255, 200 / 255)
	G2.rectangle("fill", sw - cs, 0, cs, cs)
	G2.setColor(1, 1, 1, 1)
	G2.printf("✕", sw - cs, 6, cs, "center")
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
	-- 重新扫描 .images/append：把新增的小图同步进松散组 append
	local refresh_btn = self:make_button("刷新append", V.v(110, 24))
	refresh_btn.pos = V.v(330, 14)
	refresh_btn._label.font_size = 12 * rs
	refresh_btn.on_press = function()
		self:refresh_append_group()
		self:rebuild_tree()
		local g = state.groups["append"]
		self:set_status(g and string.format("append 已同步: %d 张 (其中 %d 张内容重复)", #g.frame_order, self._append_dup_count or 0) or "append 无小图")
	end
	ui.window:add_child(refresh_btn)
	local status_text = GGLabel:new(V.v(self.ref_w - 480, 28))
	status_text.font_name = "body"
	status_text.font_size = 12 * rs
	status_text.text_align = "right"
	status_text.vertical_align = "middle"
	status_text.colors.text = {180, 190, 220, 255}
	status_text.pos = V.v(430, 14)
	status_text.fit_lines = 1
	ui.status_label = status_text
	ui.window:add_child(status_text)
	ui.fps_label = GGLabel:new(V.v(200, 20))
	ui.fps_label.font_name = "body"
	ui.fps_label.font_size = 11 * rs
	ui.fps_label.text_align = "right"
	ui.fps_label.vertical_align = "middle"
	ui.fps_label.colors.text = {120, 130, 160, 255}
	ui.fps_label.pos = V.v(self.ref_w - 220, 58)
end

function atlas_manager:make_button(text, size)
	local rs = self._rs
	local btn = KView:new(V.v(size.x, size.y))
	btn.enabled = true
	btn._bg = {40, 48, 70, 230}
	btn._hover_bg = {50, 60, 85, 230}
	btn._pressed_bg = {60, 72, 100, 230}
	btn.colors.background = btn._bg
	btn.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, size.x, size.y, 4, 4}
	}
	local label = GGLabel:new(V.v(size.x - 8, size.y))
	label.font_name = "body"
	label.font_size = 12 * rs
	label.text_align = "center"
	label.vertical_align = "middle"
	label.colors.text = {210, 218, 240, 255}
	label.pos = V.v(4, 0)
	label.text = text
	btn:add_child(label)
	btn._label = label
	function btn:on_mouse_enter()
		self.colors.background = self._hover_bg
	end
	function btn:on_mouse_leave()
		self.colors.background = self._bg
	end
	function btn:on_down(button, vx, vy)
		self.colors.background = self._pressed_bg
	end
	function btn:on_up(button, vx, vy, drag_view, istouch)
		self.colors.background = self._bg
	end
	function btn:on_click(button, vx, vy)
		if not self.enabled then
			return
		end
		S:queue("GUIButtonCommon")
		if self.on_press then
			self.on_press()
		end
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
	local name_input = KButton:new(V.v(180, 22))
	name_input.pos = V.v(330, control_y)
	name_input.colors.background = {22, 28, 42, 255}
	name_input.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 180, 22, 4, 4}
	}
	name_input._text = "merged_atlas"
	name_input._cursor = 0
	name_input._focused = false
	ui.window:add_child(name_input)
	local _name_input_font = love.graphics.newFont(13)
	function name_input:_draw_self()
		local G2 = love.graphics
		KButton._draw_self(self)
		local old_font = G2.getFont()
		G2.setFont(_name_input_font)
		local text = self._text or ""
		local tw = _name_input_font:getWidth(text)
		G2.setColor(255 / 255, 255 / 255, 255 / 255, 1)
		local box_w = self.size.x - 8
		local display_text = text
		local display_w = tw
		if display_w > box_w then
			local sub = #text
			while sub > 0 and _name_input_font:getWidth("..." .. text:sub(sub)) > box_w do
				sub = sub - 1
			end
			display_text = "..." .. text:sub(math.max(1, sub))
			display_w = _name_input_font:getWidth(display_text)
		end
		G2.print(display_text, 4, 3)
		if self._focused then
			G2.setColor(255 / 255, 255 / 255, 255 / 255, 200 / 255)
			local cursor_x = math.min(box_w, 4 + display_w)
			G2.rectangle("fill", cursor_x, 4, 1, 14)
		end
		G2.setFont(old_font)
	end
	function name_input:on_click()
		S:queue("GUIButtonCommon")
		self._focused = true
		if ui.window.set_responder then
			ui.window:set_responder(self)
		end
	end
	function name_input:on_textinput(t)
		if not self._focused then
			return
		end
		self._text = (self._text or "") .. t
	end
	function name_input:on_keypressed(key)
		if not self._focused then
			return
		end
		if key == "backspace" then
			local text = self._text or ""
			local byteoffset = utf8.offset(text, -1)
			if byteoffset then
				self._text = byteoffset > 1 and text:sub(1, byteoffset - 1) or ""
			else
				self._text = ""
			end
		elseif key == "return" or key == "escape" then
			self._focused = false
			if ui.window.set_responder then
				ui.window:set_responder()
			end
		end
	end
	function name_input:on_exit()
		self._focused = false
	end
	ui.merge_name_input = name_input
	local w_lbl = GGLabel:new(V.v(40, 22))
	w_lbl.font_name = "body"
	w_lbl.font_size = 13 * rs
	w_lbl.text_align = "right"
	w_lbl.vertical_align = "middle"
	w_lbl.colors.text = {205, 218, 248, 255}
	w_lbl.text = "尺寸:"
	w_lbl.pos = V.v(530, control_y)
	ui.window:add_child(w_lbl)
	-- 尺寸下拉选项：宽/高独立选择（256~4096），合并与后续重打包共用同一套选择
	local SIZE_CHOICES = {256, 512, 1024, 2048, 4096}
	local size_target = nil -- "w" | "h"

	local function close_size_menu()
		if ui.size_menu_dlg then
			ui.size_menu_dlg.hidden = true
		end
		size_target = nil
	end
	ui.close_size_menu = close_size_menu

	local function make_size_input(x, initial, kind)
		local inp = KView:new(V.v(64, 22))
		inp.pos = V.v(x, control_y)
		inp.colors.background = {22, 28, 42, 255}
		inp.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, 64, 22, 4, 4}
		}
		ui.window:add_child(inp)
		local txt = GGLabel:new(V.v(46, 22))
		txt.font_name = "body"
		txt.font_size = 13 * rs
		txt.text_align = "center"
		txt.vertical_align = "middle"
		txt.colors.text = {255, 255, 255, 255}
		txt.text = tostring(initial)
		txt.pos = V.v(0, 0)
		inp:add_child(txt)
		local arrow = GGLabel:new(V.v(14, 22))
		arrow.font_name = "body"
		arrow.font_size = 11 * rs
		arrow.text_align = "center"
		arrow.vertical_align = "middle"
		arrow.colors.text = {150, 162, 192, 255}
		arrow.text = "▾"
		arrow.pos = V.v(48, 0)
		inp:add_child(arrow)
		function inp:on_click()
			ui.size_menu_apply = nil -- 合并尺寸路径：不使用外部回调
			if ui.size_menu_dlg and not ui.size_menu_dlg.hidden and size_target == kind then
				close_size_menu()
				return
			end
			size_target = kind
			local mw, mh = ui.size_menu_dlg.size.x, ui.size_menu_dlg.size.y
			ui.size_menu_dlg.anchor = V.v(mw * 0.5, mh * 0.5)
			ui.size_menu_dlg.pos = V.v(x + 32, control_y + 22 + 6 + mh * 0.5)
			ui.size_menu_dlg.hidden = false
			ui.size_menu_dlg:order_to_front()
		end
		return inp, txt
	end

	-- 尺寸下拉弹层
	do
		local rows = #SIZE_CHOICES
		local mw, row_h, gap = 150, 24, 2
		local mh = rows * row_h + (rows - 1) * gap + 8
		ui.size_menu_dlg = KView:new(V.v(mw, mh))
		ui.size_menu_dlg.colors.background = {20, 27, 42, 250}
		ui.size_menu_dlg.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, mw, mh, 6, 6}
		}
		ui.window:add_child(ui.size_menu_dlg)
		for i, sz in ipairs(SIZE_CHOICES) do
			local b = self:make_button(tostring(sz), V.v(mw - 12, row_h))
			b.pos = V.v(6, 4 + (i - 1) * (row_h + gap))
			b.on_press = function()
				if ui.size_menu_apply then
					ui.size_menu_apply(sz)
				elseif size_target == "w" then
					state.merge_w = sz
					ui.merge_w_text.text = tostring(sz)
				elseif size_target == "h" then
					state.merge_h = sz
					ui.merge_h_text.text = tostring(sz)
				end
				close_size_menu()
			end
			ui.size_menu_dlg:add_child(b)
		end
		ui.size_menu_dlg.hidden = true
	end
	ui.size_menu_apply = nil
	ui.merge_w_input, ui.merge_w_text = make_size_input(572, state.merge_w, "w")
	local x_lbl = GGLabel:new(V.v(12, 22))
	x_lbl.font_name = "body"
	x_lbl.font_size = 13 * rs
	x_lbl.text_align = "center"
	x_lbl.vertical_align = "middle"
	x_lbl.colors.text = {205, 218, 248, 255}
	x_lbl.text = "x"
	x_lbl.pos = V.v(638, control_y)
	ui.window:add_child(x_lbl)
	ui.merge_h_input, ui.merge_h_text = make_size_input(650, state.merge_h, "h")
	-- non-power-of-2 mode checkbox
	do
		local cb = KView:new(V.v(130, 20))
		cb.pos = V.v(930, control_y + 1)
		cb.colors.background = {22, 28, 42, 200}
		cb.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, 130, 20, 4, 4}
		}
		ui.window:add_child(cb)
		local cbt = GGLabel:new(V.v(120, 20))
		cbt.font_name = "body"
		cbt.font_size = 12 * rs
		cbt.text_align = "left"
		cbt.vertical_align = "middle"
		cbt.colors.text = {180, 190, 220, 255}
		cbt.text = "  非常规尺寸"
		cbt.pos = V.v(5, 0)
		cb:add_child(cbt)
		local tick = GGLabel:new(V.v(14, 20))
		tick.font_name = "body"
		tick.font_size = 14 * rs
		tick.text_align = "center"
		tick.vertical_align = "middle"
		tick.colors.text = {100, 220, 100, 255}
		tick.pos = V.v(3, 0)
		tick.text = ""
		cb:add_child(tick)
		function cb:on_click()
			state.non_pow2_mode = not state.non_pow2_mode
			tick.text = state.non_pow2_mode and "✓" or ""
		end
		ui.non_pow2_cb = cb
		ui.non_pow2_tick = tick
	end
	-- 重复帧去重：内容完全一致的帧只打包一份，其余名字写成 alias
	do
		local cb = KView:new(V.v(210, 20))
		cb.pos = V.v(1075, control_y + 1)
		cb.colors.background = {22, 28, 42, 200}
		cb.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, 210, 20, 4, 4}
		}
		ui.window:add_child(cb)
		local cbt = GGLabel:new(V.v(200, 20))
		cbt.font_name = "body"
		cbt.font_size = 12 * rs
		cbt.text_align = "left"
		cbt.vertical_align = "middle"
		cbt.colors.text = {180, 190, 220, 255}
		cbt.text = "  重复帧→alias"
		cbt.pos = V.v(5, 0)
		cb:add_child(cbt)
		local tick = GGLabel:new(V.v(14, 20))
		tick.font_name = "body"
		tick.font_size = 14 * rs
		tick.text_align = "center"
		tick.vertical_align = "middle"
		tick.colors.text = {100, 220, 100, 255}
		tick.pos = V.v(3, 0)
		tick.text = state.dedup_alias and "✓" or ""
		cb:add_child(tick)
		function cb:on_click()
			state.dedup_alias = not state.dedup_alias
			tick.text = state.dedup_alias and "✓" or ""
		end
		ui.dedup_cb = cb
		ui.dedup_tick = tick
	end
	local action_y = control_y + 26
	local merge_btn = self:make_button("合并", V.v(80, 26))
	merge_btn.pos = V.v(20, action_y)
	merge_btn.on_press = function()
		self:do_merge()
	end
	ui.window:add_child(merge_btn)
	local del_btn = self:make_button("删除帧", V.v(100, 26))
	del_btn.pos = V.v(110, action_y)
	del_btn.on_press = function()
		self:delete_frames()
	end
	ui.window:add_child(del_btn)
	local export_btn = self:make_button("导出PNG", V.v(100, 26))
	export_btn.pos = V.v(220, action_y)
	export_btn.on_press = function()
		self:export_png()
	end
	ui.window:add_child(export_btn)
	local unload_btn = self:make_button("释放纹理", V.v(110, 26))
	unload_btn.pos = V.v(330, action_y)
	unload_btn.on_press = function()
		self:unload_all_textures()
	end
	ui.window:add_child(unload_btn)
	local scale_btn = self:make_button("缩放", V.v(70, 26))
	scale_btn.pos = V.v(450, action_y)
	scale_btn.on_press = function()
		self:show_scale_dialog()
	end
	ui.window:add_child(scale_btn)
	local split_btn = self:make_button("拆分", V.v(70, 26))
	split_btn.pos = V.v(530, action_y)
	split_btn.on_press = function()
		self:show_split_dialog()
	end
	ui.window:add_child(split_btn)
	ui.select_y = action_y + 30
	self:build_scale_dialog()
	self:build_split_dialog()
	self:build_png_scale_dialog()
end

local function make_dialog_text_input(w, initial)
	local inp = KView:new(V.v(w, 22))
	inp.colors.background = {22, 28, 42, 255}
	inp.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, w, 22, 4, 4}
	}
	inp._text = initial or ""
	inp._focused = false
	local font = love.graphics.newFont(13)
	function inp:_draw_self()
		local G2 = love.graphics
		KView._draw_self(self)
		local old_font = G2.getFont()
		G2.setFont(font)
		local text = self._text or ""
		local tw = font:getWidth(text)
		G2.setColor(255 / 255, 255 / 255, 255 / 255, 1)
		local box_w = self.size.x - 8
		local display_text = text
		local display_w = tw
		if display_w > box_w then
			local sub = #text
			while sub > 0 and font:getWidth("..." .. text:sub(sub)) > box_w do
				sub = sub - 1
			end
			display_text = "..." .. text:sub(math.max(1, sub))
			display_w = font:getWidth(display_text)
		end
		G2.print(display_text, 4, 3)
		if self._focused then
			G2.setColor(255 / 255, 255 / 255, 255 / 255, 200 / 255)
			local cursor_x = math.min(box_w, 4 + display_w)
			G2.rectangle("fill", cursor_x, 4, 1, 14)
		end
		G2.setFont(old_font)
	end
	function inp:on_click()
		S:queue("GUIButtonCommon")
		self._focused = true
		if ui.window.set_responder then
			ui.window:set_responder(self)
		end
	end
	function inp:on_textinput(t)
		if not self._focused then
			return
		end
		self._text = (self._text or "") .. t
		if self._on_change then
			self:_on_change(self._text)
		end
	end
	function inp:on_keypressed(key)
		if not self._focused then
			return
		end
		if key == "backspace" then
			local text = self._text or ""
			local byteoffset = utf8.offset(text, -1)
			if byteoffset then
				self._text = byteoffset > 1 and text:sub(1, byteoffset - 1) or ""
			else
				self._text = ""
			end
			if self._on_change then
				self:_on_change(self._text)
			end
		elseif key == "return" or key == "escape" then
			self._focused = false
			if ui.window.set_responder then
				ui.window:set_responder()
			end
			if self._on_commit then
				self:_on_commit(self._text)
			end
		end
	end
	function inp:on_exit()
		if self._focused then
			self._focused = false
			if self._on_commit then
				self:_on_commit(self._text)
			end
		end
	end
	return inp
end

function atlas_manager:show_scale_dialog()

	if ui.close_size_menu then
		ui.close_size_menu()
	end
	if not state._merged_idata then
		self:set_status("请先选中帧并点击「合并」生成图集")
		return
	end
	if state.merge_pages then
		self:set_status("已拆分图集，缩放请先重新合并")
		return
	end
	ui.scale_dialog.hidden = false
	ui.scale_dialog:order_to_front()
	ui.scale_info.text = string.format("当前尺寸: %dx%d (%.2fMP)", state.merge_w, state.merge_h, state.merge_w * state.merge_h / 1e6)
	ui.scale_input._text = "1"
	ui.scale_input._focused = false
end

function atlas_manager:show_split_dialog()

	if ui.close_size_menu then
		ui.close_size_menu()
	end
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("请先勾选要拆分的帧（无需先合并）")
		return
	end
	if state.merge_pages then
		self:set_status("已经拆分过了，可重新选择帧后再拆分")
		return
	end
	ui.split_dialog.hidden = false
	ui.split_dialog:order_to_front()
	ui.split_max_input._text = "4096"
	ui.split_max_input._focused = false
	local total_area = 0
	for _, sel in ipairs(selected) do
		total_area = total_area + sel.frame.f_quad[3] * sel.frame.f_quad[4]
	end
	ui.split_info.text = string.format("已选 %d 帧，将按上限拆分为多页", #selected)
end

function atlas_manager:build_scale_dialog()
	local rs = self._rs
	local dlg = KView:new(V.v(400, 230))
	dlg.anchor = V.v(200, 115)
	dlg.pos = V.v(self.ref_w / 2, self.ref_h / 2)
	dlg.colors.background = {20, 26, 42, 245}
	dlg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 400, 230, 12, 12}
	}
	dlg.hidden = true
	ui.window:add_child(dlg)
	ui.scale_dialog = dlg
	local title = GGLabel:new(V.v(360, 26))
	title.font_name = "body"
	title.font_size = 15 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = {244, 221, 165, 255}
	title.text = "图集缩放"
	title.pos = V.v(16, 10)
	dlg:add_child(title)
	local info = GGLabel:new(V.v(360, 24))
	info.font_name = "body"
	info.font_size = 12 * rs
	info.text_align = "left"
	info.vertical_align = "middle"
	info.colors.text = {180, 190, 220, 255}
	info.pos = V.v(16, 40)
	ui.scale_info = info
	dlg:add_child(info)
	local fl = GGLabel:new(V.v(80, 22))
	fl.font_name = "body"
	fl.font_size = 12 * rs
	fl.text_align = "left"
	fl.vertical_align = "middle"
	fl.colors.text = {205, 218, 248, 255}
	fl.text = "倍率:"
	fl.pos = V.v(16, 70)
	dlg:add_child(fl)
	local inp = make_dialog_text_input(100, "1")
	inp.pos = V.v(70, 70)
	dlg:add_child(inp)
	ui.scale_input = inp
	local presets = {{0.5, "x0.5"}, {0.75, "x0.75"}, {0.8, "x0.8"}, {1.5, "x1.5"}, {2, "x2"}}
	local px = 16
	for i, p in ipairs(presets) do
		local b = self:make_button(p[2], V.v(56, 26))
		b.pos = V.v(px, 100)
		b._label.font_size = 12 * rs
		local factor = p[1]
		b.on_press = function()
			self:apply_scale(factor)
		end
		dlg:add_child(b)
		px = px + 62
	end
	local fit_btn = self:make_button("适配4096", V.v(90, 26))
	fit_btn.pos = V.v(16, 136)
	fit_btn.on_press = function()
		local mw, mh = state.merge_w, state.merge_h
		local mx = math.max(mw, mh)
		if mx <= 4096 then
			self:set_status("当前尺寸未超过4096")
			return
		end
		self:apply_scale(4096 / mx)
	end
	dlg:add_child(fit_btn)
	local apply_btn = self:make_button("应用", V.v(90, 26))
	apply_btn.pos = V.v(116, 136)
	apply_btn.on_press = function()
		local f = tonumber(ui.scale_input._text or "1")
		if not f or f <= 0 then
			self:set_status("无效的倍率")
			return
		end
		self:apply_scale(f)
	end
	dlg:add_child(apply_btn)
	local close_btn = self:make_button("关闭", V.v(90, 26))
	close_btn.pos = V.v(216, 136)
	close_btn.on_press = function()
		dlg.hidden = true
	end
	dlg:add_child(close_btn)
	local hint = GGLabel:new(V.v(360, 20))
	hint.font_name = "body"
	hint.font_size = 11 * rs
	hint.text_align = "left"
	hint.vertical_align = "middle"
	hint.colors.text = {140, 155, 185, 255}
	hint.text = "缩放后所有帧坐标/尺寸同步换算，配合 DDS转换 使用"
	hint.pos = V.v(16, 172)
	dlg:add_child(hint)
end

function atlas_manager:build_split_dialog()
	local rs = self._rs
	local dlg = KView:new(V.v(400, 210))
	dlg.anchor = V.v(200, 105)
	dlg.pos = V.v(self.ref_w / 2, self.ref_h / 2)
	dlg.colors.background = {20, 26, 42, 245}
	dlg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 400, 210, 12, 12}
	}
	dlg.hidden = true
	ui.window:add_child(dlg)
	ui.split_dialog = dlg
	local title = GGLabel:new(V.v(360, 26))
	title.font_name = "body"
	title.font_size = 15 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = {244, 221, 165, 255}
	title.text = "图集拆分"
	title.pos = V.v(16, 10)
	dlg:add_child(title)
	local info = GGLabel:new(V.v(360, 24))
	info.font_name = "body"
	info.font_size = 12 * rs
	info.text_align = "left"
	info.vertical_align = "middle"
	info.colors.text = {180, 190, 220, 255}
	info.pos = V.v(16, 40)
	ui.split_info = info
	dlg:add_child(info)
	local ml = GGLabel:new(V.v(80, 22))
	ml.font_name = "body"
	ml.font_size = 12 * rs
	ml.text_align = "left"
	ml.vertical_align = "middle"
	ml.colors.text = {205, 218, 248, 255}
	ml.text = "上限:"
	ml.pos = V.v(16, 70)
	dlg:add_child(ml)
	local inp = make_dialog_text_input(100, "4096")
	inp.pos = V.v(70, 70)
	dlg:add_child(inp)
	ui.split_max_input = inp
	local run_btn = self:make_button("执行拆分", V.v(100, 30))
	run_btn.pos = V.v(16, 108)
	run_btn.on_press = function()
		local mx = tonumber(ui.split_max_input._text or "4096")
		if not mx or mx < 16 then
			self:set_status("无效的上限尺寸")
			return
		end
		self:do_split(mx)
	end
	dlg:add_child(run_btn)
	local close_btn = self:make_button("关闭", V.v(100, 30))
	close_btn.pos = V.v(126, 108)
	close_btn.on_press = function()
		dlg.hidden = true
	end
	dlg:add_child(close_btn)
	local hint = GGLabel:new(V.v(360, 20))
	hint.font_name = "body"
	hint.font_size = 11 * rs
	hint.text_align = "left"
	hint.vertical_align = "middle"
	hint.colors.text = {140, 155, 185, 255}
	hint.text = "拆分为 name-1.dds / name-2.dds ... 多页图集"
	hint.pos = V.v(16, 150)
	dlg:add_child(hint)
end

-- ========== 单张PNG 等比缩放 ==========
-- 对 append 松散组中的单个 png 小图预览并等比缩放：
-- 目标宽/目标高填其中一个即按等比(保比例)计算另一边；两个都填且比例不一致时取较小比例(不超界)。
function atlas_manager:build_png_scale_dialog()
	local rs = self._rs
	local dlg = KView:new(V.v(460, 300))
	dlg.anchor = V.v(230, 150)
	dlg.pos = V.v(self.ref_w / 2, self.ref_h / 2)
	dlg.colors.background = {20, 26, 42, 245}
	dlg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 460, 300, 12, 12}
	}
	dlg.hidden = true
	ui.window:add_child(dlg)
	ui.png_scale_dialog = dlg
	local title = GGLabel:new(V.v(420, 26))
	title.font_name = "body"
	title.font_size = 15 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = {244, 221, 165, 255}
	title.text = "PNG等比缩放"
	title.pos = V.v(16, 10)
	dlg:add_child(title)
	local info = GGLabel:new(V.v(420, 44))
	info.font_name = "body"
	info.font_size = 12 * rs
	info.text_align = "left"
	info.vertical_align = "top"
	info.colors.text = {180, 190, 220, 255}
	info.pos = V.v(16, 42)
	info.fit_lines = 2
	info.fit_size = true
	info.line_height = 1.3
	ui.png_scale_info = info
	dlg:add_child(info)
	local wl = GGLabel:new(V.v(90, 22))
	wl.font_name = "body"
	wl.font_size = 12 * rs
	wl.text_align = "left"
	wl.vertical_align = "middle"
	wl.colors.text = {205, 218, 248, 255}
	wl.text = "目标宽(x):"
	wl.pos = V.v(16, 92)
	dlg:add_child(wl)
	local w_input = make_dialog_text_input(100, "")
	w_input.pos = V.v(110, 92)
	dlg:add_child(w_input)
	w_input._on_commit = function()
		self:_update_png_scale_result()
	end
	w_input._on_change = function()
		self:_update_png_scale_result()
	end
	ui.png_scale_w_input = w_input
	local hl = GGLabel:new(V.v(90, 22))
	hl.font_name = "body"
	hl.font_size = 12 * rs
	hl.text_align = "left"
	hl.vertical_align = "middle"
	hl.colors.text = {205, 218, 248, 255}
	hl.text = "目标高(y):"
	hl.pos = V.v(16, 122)
	dlg:add_child(hl)
	local h_input = make_dialog_text_input(100, "")
	h_input.pos = V.v(110, 122)
	dlg:add_child(h_input)
	h_input._on_commit = function()
		self:_update_png_scale_result()
	end
	h_input._on_change = function()
		self:_update_png_scale_result()
	end
	ui.png_scale_h_input = h_input
	local result = GGLabel:new(V.v(420, 22))
	result.font_name = "body"
	result.font_size = 13 * rs
	result.text_align = "left"
	result.vertical_align = "middle"
	result.colors.text = {100, 220, 100, 255}
	result.pos = V.v(16, 152)
	ui.png_scale_result = result
	dlg:add_child(result)
	local preview_btn = self:make_button("预览原图", V.v(110, 32))
	preview_btn.pos = V.v(16, 190)
	preview_btn.on_press = function()
		self:preview_png_file(ui.png_scale_file)
	end
	dlg:add_child(preview_btn)
	local apply_btn = self:make_button("应用缩放", V.v(110, 32))
	apply_btn.pos = V.v(136, 190)
	apply_btn.on_press = function()
		self:apply_png_scale()
	end
	dlg:add_child(apply_btn)
	local close_btn = self:make_button("关闭", V.v(110, 32))
	close_btn.pos = V.v(256, 190)
	close_btn.on_press = function()
		dlg.hidden = true
	end
	dlg:add_child(close_btn)
	local hint = GGLabel:new(V.v(420, 40))
	hint.font_name = "body"
	hint.font_size = 11 * rs
	hint.text_align = "left"
	hint.vertical_align = "top"
	hint.colors.text = {140, 155, 185, 255}
	hint.text = "等比缩放：只填宽或高，另一边自动按比例。两个都填时按较小比例（不超出）。应用将覆盖该PNG文件（原文件备份到 .images_backup）。"
	hint.pos = V.v(16, 234)
	hint.fit_lines = 2
	hint.fit_size = true
	hint.line_height = 1.3
	dlg:add_child(hint)
end

function atlas_manager:show_png_scale_dialog(f)
	if not f then
		self:set_status("请先选中一个PNG")
		return
	end
	ui.png_scale_file = f
	ui.png_scale_info.text = string.format("%s  (%dx%d)", f.name, f.w or 0, f.h or 0)
	ui.png_scale_w_input._text = ""
	ui.png_scale_h_input._text = ""
	ui.png_scale_w_input._focused = false
	ui.png_scale_h_input._focused = false
	ui.png_scale_result.text = ""
	self:_update_png_scale_result()
	ui.png_scale_dialog.hidden = false
	ui.png_scale_dialog:order_to_front()
end

-- 计算等比缩放目标尺寸；无法计算时返回 nil
function atlas_manager:_png_scale_target_dims()
	local f = ui.png_scale_file
	if not f then
		return nil
	end
	local w, h = f.w or 0, f.h or 0
	if w <= 0 or h <= 0 then
		return nil
	end
	local tw = tonumber(ui.png_scale_w_input and ui.png_scale_w_input._text or "")
	local th = tonumber(ui.png_scale_h_input and ui.png_scale_h_input._text or "")
	if (not tw or tw <= 0) and (not th or th <= 0) then
		return nil
	end
	local s = nil
	if tw and tw > 0 then
		s = tw / w
	end
	if th and th > 0 then
		local sh = th / h
		s = s and math.min(s, sh) or sh
	end
	if not s or s <= 0 then
		return nil
	end
	local nw = math.max(1, math.floor(w * s + 0.5))
	local nh = math.max(1, math.floor(h * s + 0.5))
	if nw > 16384 or nh > 16384 then
		return nil
	end
	return nw, nh
end

function atlas_manager:_update_png_scale_result()
	if not ui.png_scale_result then
		return
	end
	local f = ui.png_scale_file
	local nw, nh = self:_png_scale_target_dims()
	if nw then
		ui.png_scale_result.text = string.format("等比结果: %dx%d", nw, nh)
	elseif f then
		ui.png_scale_result.text = string.format("原尺寸: %dx%d (输入目标宽或高)", f.w or 0, f.h or 0)
	end
end

function atlas_manager:apply_png_scale()
	local f = ui.png_scale_file
	if not f then
		self:set_status("没有可缩放的PNG")
		return
	end
	local nw, nh = self:_png_scale_target_dims()
	if not nw then
		self:set_status("请输入有效的目标宽或目标高")
		return
	end
	local ow, oh = f.w or 0, f.h or 0
	if nw == ow and nh == oh then
		ui.png_scale_dialog.hidden = true
		self:set_status("尺寸未变化")
		return
	end
	local ok, data = pcall(love.filesystem.read, f.rel)
	if not ok or not data then
		local real = real_path(f.rel)
		local fh = io.open(real, "rb")
		if fh then
			data = fh:read("*all")
			fh:close()
		end
	end
	if not data then
		self:set_status("无法读取PNG: " .. tostring(f.name))
		return
	end
	local ok2, idata = pcall(love.image.newImageData, love.data.newByteData(data))
	if not ok2 then
		self:set_status("无法解码PNG: " .. tostring(f.name))
		return
	end
	local resized = self:_resample_idata(idata, nw, nh)
	if not resized then
		self:set_status("缩放失败")
		return
	end
	local png_data = resized:encode("png")
	if png_data.getString then
		png_data = png_data:getString()
	end
	-- 备份原文件
	local ts = tostring(os.time())
	local backup_dir = real_path(BACKUP_DIR)
	local backup_path = backup_dir .. "/" .. ts .. "_" .. tostring(f.name) .. ".png"
	local ok_bak = write_real(backup_path, data)
	if not ok_bak then
		self:set_status("备份原图失败，已取消: " .. backup_path)
		return
	end
	-- 覆盖源文件
	local ok_write = write_real(real_path(f.rel), png_data)
	if not ok_write then
		self:set_status("写入PNG失败: " .. real_path(f.rel))
		return
	end
	f.w, f.h = nw, nh
	if f.dds_exists then
		local dw, dh = self:_get_dds_dim(f.name)
		f.dds_match = dw == nw and dh == nh
	end
	ui.png_scale_dialog.hidden = true
	-- 若是 append 松散组中的文件，刷新其帧元数据（尺寸/裁剪）
	self:refresh_append_group()
	self:rebuild_tree()
	self:set_status(string.format("已等比缩放 %s: %dx%d -> %dx%d", f.name, ow, oh, nw, nh))
end

function atlas_manager:build_preview_area()
	ui.button_y = ui.select_y + 8
end

function atlas_manager:build_button_bar()
	local vw = self.ref_w
	local by = ui.button_y or (self.ref_h - 36)
	local bw = 120
	local gap = 12
	local total = bw * 7 + gap * 6
	local sx = (vw - total) * 0.5
	local function bar_btn(text, idx, on_press)
		local btn = self:make_button(text, V.v(bw, 32))
		btn.pos = V.v(sx + (bw + gap) * idx, by)
		btn.on_press = on_press
		ui.window:add_child(btn)
		return btn
	end
	bar_btn("保存", 0, function()
		self:save(false)
	end)
	bar_btn("预览", 1, function()
		if state.preview_valid and state.preview_canvas then
			self:show_preview_popup()
		else
			self:set_status("请先选中帧并点击「合并」生成预览")
		end
	end)
	bar_btn("放弃修改", 2, function()
		self:leave()
	end)
	bar_btn("DDS转换", 3, function()
		self:print_dds_commands()
	end)
	bar_btn("AI放大", 4, function()
		self:ai_upscale()
	end)
	bar_btn("替换图集", 5, function()
		self:replace_with_upscaled()
	end)
	bar_btn("重打包", 6, function()
		self:show_repack_dialog()
	end)
-- 说明：原 PNG 视图已移除，小图处理（预览/缩放/合并）统一在图集视图中完成。
end

local _dds_cache = {}

-- 扫描 .images/append 平铺 png，返回 frames（loose frame 元数据）与有序名称列表
function atlas_manager:_scan_append_dir_frames()
	local frames = {}
	local frame_order = {}
	local append_dir = IMAGES_DIR .. "/append"
	local ok_dir, items = pcall(love.filesystem.getDirectoryItems, append_dir)
	if not ok_dir then
		return frames, frame_order
	end
	table.sort(items)
	local first_by_hash = {}
	local dup_count = 0
	for _, fn in ipairs(items) do
		if fn:sub(-4) == ".png" then
			local base = fn:sub(1, -5)
			local full_rel = append_dir .. "/" .. fn
			local trim_data, img_w, img_h = self:_compute_png_trim(full_rel)
			if trim_data then
				local crop_w = img_w - trim_data[1] - trim_data[3]
				local crop_h = img_h - trim_data[2] - trim_data[4]
				-- 内容指纹：内容完全一致的帧打包时只保留一份，其余名字用 alias 指向它
				local hash = file_md5_hex(read_fs(full_rel))
				local dup_of = hash and first_by_hash[hash] or nil
				if dup_of then
					dup_count = dup_count + 1
				elseif hash then
					first_by_hash[hash] = base
				end
				frames[base] = {
					a_name = fn,
					size = {img_w, img_h},
					trim = trim_data,
					a_size = {crop_w, crop_h},
					f_quad = {0, 0, crop_w, crop_h},
					alias = {},
					ref_scale = 1,
					dds_key = nil,
					_is_loose = true,
					_src_path = full_rel,
					_content_hash = hash,
					_dup_of = dup_of
				}
				frame_order[#frame_order + 1] = base
			end
		end
	end
	self._append_dup_count = dup_count
	return frames, frame_order
end

-- 刷新 .images/append 松散组（组名 append），保留仍存在的帧的选中状态
function atlas_manager:refresh_append_group()
	local gname = "append"
	local frames, frame_order = self:_scan_append_dir_frames()
	local group = state.groups[gname]
	if not group then
		if #frame_order == 0 then
			return
		end
		group = {
			name = gname,
			path = nil,
			frames = {},
			frame_order = {},
			dds_files = {},
			has_png_archive = false,
			tex_size = "",
			_is_loose_group = true
		}
		state.groups[gname] = group
		state.group_order[#state.group_order + 1] = gname
	end
	-- 清理已不存在帧的勾选
	for key in pairs(state.selected_frames) do
		local prefix = gname .. "."
		if key:sub(1, #prefix) == prefix then
			local base = key:sub(#prefix + 1)
			if not frames[base] then
				state.selected_frames[key] = nil
			end
		end
	end
	group.frames = frames
	group.frame_order = frame_order
	if #frame_order == 0 then
		state.groups[gname] = nil
		table.removeobject(state.group_order, gname)
	end
end

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
	state.file_checks = {}
	state.expanded = {}
	state.ref_index_dirty = true -- 图集数据变化后，重打包引用索引需要重建
	local files = atlas_util.scan_atlas_files(ATLAS_DIR)
	for _, f in ipairs(files) do
		local tbl = atlas_util.load_atlas_lua(f.path)
		if tbl then
			local frames = {}
			local dds_map = {}
			local normalize_count = 0
			for k, v in pairs(tbl) do
				local a_name = v.a_name or ""
				local dds_key = a_name:match("^(.+)%.[^.]+$") or a_name
				local ref = v.ref_scale or 1
				local a_sz = v.a_size or {0, 0}
				local fq = v.f_quad or {0, 0, 0, 0}
				local actual_w, actual_h = self:_get_dds_dim(dds_key)
				if actual_w and actual_h and actual_w > 0 and a_sz[1] > 0 then
					local sx = actual_w / a_sz[1]
					local sy = actual_h / a_sz[2]
					fq = {math.floor(fq[1] * sx + 0.5), math.floor(fq[2] * sy + 0.5), math.floor(fq[3] * sx + 0.5), math.floor(fq[4] * sy + 0.5)}
					a_sz = {actual_w, actual_h}
					local raw_trim = v.trim or {}
					local trim_src = {raw_trim[1] or 0, raw_trim[2] or 0, raw_trim[3] or raw_trim[1] or 0, raw_trim[4] or raw_trim[2] or 0}
					v.size = {math.floor(v.size[1] * sx + 0.5), math.floor(v.size[2] * sy + 0.5)}
					v.trim = {math.floor(trim_src[1] * sx + 0.5), math.floor(trim_src[2] * sy + 0.5), math.floor(trim_src[3] * sx + 0.5), math.floor(trim_src[4] * sy + 0.5)}
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
					dds_key = dds_key
				}
				if not dds_map[dds_key] then
					local dw, dh = self:_get_dds_dim(dds_key)
					dds_map[dds_key] = {
						w = dw or a_sz[1],
						h = dh or a_sz[2]
					}
				end
			end
			local group_sizes = {}
			for dds_key, dim in pairs(dds_map) do
				local s = string.format("%dx%d", dim.w, dim.h)
				group_sizes[s] = (group_sizes[s] or 0) + 1
			end
			local size_parts = {}
			for s, count in pairs(group_sizes) do
				size_parts[#size_parts + 1] = count > 1 and (s .. "x" .. count) or s
			end
			local size_label = table.concat(size_parts, " ")
			local has_png = false
			for dds_key, _ in pairs(dds_map) do
				if FS.getInfo(IMAGES_DIR .. "/" .. dds_key .. ".png", "file") then
					has_png = true
					break
				end
			end
			local frame_order = table.keys(tbl)
			table.sort(frame_order)
			state.groups[f.base] = {
				name = f.base,
				path = f.path,
				frames = frames,
				frame_order = frame_order,
				dds_files = table.keys(dds_map),
				has_png_archive = has_png,
				tex_size = size_label
			}
			state.group_order[#state.group_order + 1] = f.base
		end
	end
	-- scan loose PNGs: .images/append 下的平铺小图，注册为一个可勾选的松散组
	-- （组名固定 append，可与其它图集帧一起参与合并）
	self:refresh_append_group()
	self:set_status(string.format("已加载 %d 个图集", #state.group_order))
	self:rebuild_tree()
end

function atlas_manager:preview_png_file(f)
	local ok, data = pcall(love.filesystem.read, f.rel)
	if not ok or not data then
		local real = real_path(f.rel)
		local fh = io.open(real, "rb")
		if fh then
			data = fh:read("*all")
			fh:close()
		end
	end
	if not data then
		self:set_status("无法读取PNG: " .. f.name)
		return
	end
	local ok2, idata = pcall(love.image.newImageData, love.data.newByteData(data))
	if not ok2 then
		self:set_status("无法解码PNG: " .. f.name)
		return
	end
	local w, h = idata:getDimensions()
	local canvas = G.newCanvas(w, h)
	G.setCanvas(canvas)
	G.setColor(1, 1, 1, 1)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("alpha", "premultiplied")
	G.draw(G.newImage(idata), 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	local placements = {{
		frame_name = f.name,
		x = 0,
		y = 0,
		w = w,
		h = h,
		data = {
			group = f.name
		}
	}}
	self:set_preview_files({{
		key = f.name,
		canvas = canvas,
		w = w,
		h = h,
		placements = placements,
		sprite_list = {f.name},
		sprite_group = {
			[f.name] = f.name
		}
	}})
	self:show_preview_popup()
end

function atlas_manager:_compute_png_trim(rel_path)
	local ok, data = pcall(love.filesystem.read, rel_path)
	if not ok then
		local real = real_path(rel_path)
		local f = io.open(real, "rb")
		if f then
			data = f:read("*all")
			f:close()
		end
	end
	if not data then
		return nil
	end
	local ok2, idata = pcall(love.image.newImageData, love.data.newByteData(data))
	if not ok2 then
		return nil
	end
	local w, h = idata:getDimensions()
	local left, top, right, bottom = 0, 0, 0, 0
	for x = 0, w - 1 do
		local found = false
		for y = 0, h - 1 do
			local _, _, _, a = idata:getPixel(x, y)
			if a > 0 then
				found = true
				break
			end
		end
		if found then
			break
		end
		left = left + 1
	end
	for y = 0, h - 1 do
		local found = false
		for x = 0, w - 1 do
			local _, _, _, a = idata:getPixel(x, y)
			if a > 0 then
				found = true
				break
			end
		end
		if found then
			break
		end
		top = top + 1
	end
	for x = w - 1, 0, -1 do
		local found = false
		for y = 0, h - 1 do
			local _, _, _, a = idata:getPixel(x, y)
			if a > 0 then
				found = true
				break
			end
		end
		if found then
			break
		end
		right = right + 1
	end
	for y = h - 1, 0, -1 do
		local found = false
		for x = 0, w - 1 do
			local _, _, _, a = idata:getPixel(x, y)
			if a > 0 then
				found = true
				break
			end
		end
		if found then
			break
		end
		bottom = bottom + 1
	end
	if left >= w or top >= h then
		return {0, 0, 0, 0}, w, h
	end
	return {left, top, right, bottom}, w, h
end

function atlas_manager:rebuild_tree()
	local saved_frac = 0
	local sl = ui.tree_list
	if sl._bottom_y and sl._bottom_y > sl.size.y then
		saved_frac = (-sl.scroll_origin_y) / (sl._bottom_y - sl.size.y)
	end

	sl:clear_rows()
	local rs = self._rs

	local sel_count = 0
	for _, v in pairs(state.selected_frames) do
		if v then
			sel_count = sel_count + 1
		end
	end
	ui.sel_label.text = string.format("选中: %d 帧", sel_count)

	for _, gname in ipairs(state.group_order) do
		local group = state.groups[gname]
		if group then
			local expanded = state.expanded[gname]

			local has_sel = false
			for _, fn in ipairs(group.frame_order) do
				if group.frames[fn] and state.selected_frames[gname .. "." .. fn] then
					has_sel = true
					break
				end
			end

			local group_row = KView:new(V.v(ui.tree_list.size.x, 28))
			group_row.propagate_on_click = true
			group_row.propagate_on_down = true
			group_row.propagate_on_up = true
			if has_sel then
				group_row.colors.background = {52, 118, 210, 60}
			end

			local expand_btn = KView:new(V.v(14, 14))
			expand_btn.pos = V.v(4, 7)
			expand_btn.propagate_on_click = true
			group_row:add_child(expand_btn)

			local gname_text = GGLabel:new(V.v(200, 28))
			gname_text.font_name = "body"
			gname_text.font_size = 13 * rs
			gname_text.text_align = "left"
			gname_text.vertical_align = "middle"
			gname_text.colors.text = has_sel and {255, 220, 100, 255} or {238, 244, 255, 255}
			gname_text.text = gname
			gname_text.pos = V.v(22, 0)
			gname_text.fit_lines = 1
			gname_text.fit_size = true
			gname_text.propagate_on_click = true
			group_row:add_child(gname_text)

			local frame_count = #group.frame_order
			local tex_info = group.tex_size or ""
			local count_str = string.format("(%d帧%s%s)", frame_count, tex_info ~= "" and " " or "", tex_info)
			local count_text = GGLabel:new(V.v(200, 28))
			count_text.font_name = "body"
			count_text.font_size = 11 * rs
			count_text.text_align = "left"
			count_text.vertical_align = "middle"
			count_text.colors.text = {150, 170, 200, 255}
			count_text.text = count_str
			count_text.pos = V.v(224, 0)
			count_text.fit_lines = 1
			count_text.fit_size = true
			count_text.propagate_on_click = true
			group_row:add_child(count_text)

			local group_sel_all = self:make_button("全选", V.v(36, 20))
			group_sel_all.pos = V.v(426, 4)
			group_sel_all._label.font_size = 10 * rs
			group_sel_all.on_press = function()
				local fchk = state.file_checks[gname]
				for _, fname in ipairs(group.frame_order) do
					local fr = group.frames[fname]
					if fchk and fr and fr.dds_key and fchk[fr.dds_key] == false then
					-- skip
					else
						state.selected_frames[gname .. "." .. fname] = true
					end
				end
				self:rebuild_tree()
			end
			group_row:add_child(group_sel_all)

			local group_unsel_all = self:make_button("取消", V.v(36, 20))
			group_unsel_all.pos = V.v(464, 4)
			group_unsel_all._label.font_size = 10 * rs
			group_unsel_all.on_press = function()
				for _, fname in ipairs(group.frame_order) do
					state.selected_frames[gname .. "." .. fname] = nil
				end
				self:rebuild_tree()
			end
			group_row:add_child(group_unsel_all)

			local preview_btn = self:make_button("预览", V.v(36, 20))
			preview_btn.pos = V.v(502, 4)
			preview_btn._label.font_size = 10 * rs
			preview_btn.on_press = function()
				self:preview_group(gname)
			end
			group_row:add_child(preview_btn)

			local png_indicator = GGLabel:new(V.v(30, 28))
			png_indicator.font_name = "body"
			png_indicator.font_size = 11 * rs
			png_indicator.text_align = "center"
			png_indicator.vertical_align = "middle"
			if group._is_loose_group then
				png_indicator.colors.text = {100, 200, 220, 255}
				png_indicator.text = "追加"
			else
				png_indicator.colors.text = group.has_png_archive and {100, 200, 100, 255} or {150, 150, 150, 180}
				png_indicator.text = group.has_png_archive and "PNG" or "DDS"
			end
			png_indicator.pos = V.v(545, 0)
			group_row:add_child(png_indicator)

			function expand_btn._draw_self()
				local g2 = love.graphics
				local cx, cy = 7, 7
				local r = 5
				if expanded then
					g2.setColor(220, 200, 150, 255)
					g2.polygon("fill", cx - r, cy - r * 0.4, cx + r, cy - r * 0.4, cx, cy + r * 0.6)
				else
					g2.setColor(200, 180, 130, 255)
					g2.polygon("fill", cx - r * 0.4, cy - r, cx + r * 0.6, cy, cx - r * 0.4, cy + r)
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
				-- per-file selection rows
				for _, dds_key in ipairs(group.dds_files or {}) do
					local dw, dh = self:_get_dds_dim(dds_key)
					local file_frames = {}
					for _, fn in ipairs(group.frame_order) do
						local fr = group.frames[fn]
						if fr and fr.dds_key == dds_key then
							file_frames[#file_frames + 1] = fn
						end
					end
					if #file_frames > 0 then
						local fchk = state.file_checks[gname] or {}
						local file_on = fchk[dds_key] ~= false
						local any_sel = false
						for _, fn in ipairs(file_frames) do
							if state.selected_frames[gname .. "." .. fn] then
								any_sel = true
								break
							end
						end
						local file_row = KView:new(V.v(ui.tree_list.size.x, 22))
						file_row.propagate_on_click = true
						file_row.propagate_on_down = true
						file_row.propagate_on_up = true
						file_row.colors.background = any_sel and {52, 118, 210, 40} or nil

						local fcb = KView:new(V.v(13, 13))
						fcb.pos = V.v(36, 4)
						fcb.propagate_on_click = true
						file_row:add_child(fcb)
						fcb._checked = file_on

						function fcb._draw_self()
							local g2 = love.graphics
							local s = 13
							if fcb._checked then
								g2.setColor(80, 200, 120, 255)
								g2.rectangle("fill", 0, 0, s, s)
								g2.setColor(255, 255, 255, 230)
								g2.setLineWidth(2)
								g2.line(3, 7, 5, 10)
								g2.line(5, 10, 10, 3)
								g2.setLineWidth(1)
							else
								g2.setColor(150, 150, 150, 160)
								g2.setLineWidth(1.5)
								g2.rectangle("line", 0, 0, s, s)
								g2.setLineWidth(1)
							end
						end

						function fcb.on_click()
							local tbl = state.file_checks[gname]
							if not tbl then
								tbl = {}
								state.file_checks[gname] = tbl
							end
							tbl[dds_key] = not file_on
							for _, fn in ipairs(file_frames) do
								if tbl[dds_key] then
									state.selected_frames[gname .. "." .. fn] = true
								else
									state.selected_frames[gname .. "." .. fn] = nil
								end
							end
							self:rebuild_tree()
						end

						local file_label = GGLabel:new(V.v(ui.tree_list.size.x - 140, 22))
						file_label.font_name = "body"
						file_label.font_size = 11 * rs
						file_label.text_align = "left"
						file_label.vertical_align = "middle"
						file_label.colors.text = file_on and {150, 200, 150, 255} or {140, 150, 170, 200}
						file_label.text = string.format("  %s  %sx%s (%d帧)", dds_key, dw or "?", dh or "?", #file_frames)
						file_label.pos = V.v(52, 0)
						file_label.fit_lines = 1
						file_label.fit_size = true
						file_label.propagate_on_click = true
						file_row:add_child(file_label)

						local file_prev = self:make_button("预览", V.v(36, 18))
						file_prev.pos = V.v(ui.tree_list.size.x - 46, 2)
						file_prev._label.font_size = 10 * rs
						file_prev.on_press = function()
							self:preview_group_file(gname, dds_key)
						end
						file_row:add_child(file_prev)

						function file_row.on_click()
							fcb.on_click()
						end

						ui.tree_list:add_row(file_row)
					end
				end

				for _, fname in ipairs(group.frame_order) do
					local frame = group.frames[fname]
					local key = gname .. "." .. fname
					local checked = state.selected_frames[key]

					local frame_row = KView:new(V.v(ui.tree_list.size.x, 24))
					frame_row.propagate_on_click = true
					frame_row.propagate_on_down = true
					frame_row.propagate_on_up = true
					frame_row.colors.background = checked and {52, 118, 210, 80} or nil

					local cb_view = KView:new(V.v(14, 14))
					cb_view.pos = V.v(20, 5)
					cb_view.propagate_on_click = true
					frame_row:add_child(cb_view)
					cb_view._checked = checked

					function cb_view._draw_self()
						local g2 = love.graphics
						local s = 14
						if cb_view._checked then
							g2.setColor(52, 118, 210, 255)
							g2.rectangle("fill", 0, 0, s, s)
							g2.setColor(255, 255, 255, 230)
							g2.setLineWidth(2)
							g2.line(3, 8, 6, 11)
							g2.line(6, 11, 11, 3)
							g2.setLineWidth(1)
						else
							g2.setColor(100, 130, 180, 120)
							g2.setLineWidth(1.5)
							g2.rectangle("line", 0, 0, s, s)
							g2.setLineWidth(1)
						end
					end

					function cb_view.on_click()
						if state.selected_frames[key] then
							state.selected_frames[key] = nil
						else
							state.selected_frames[key] = true
						end
						self:rebuild_tree()
					end

					local label_w = ui.tree_list.size.x - (group._is_loose_group and 190 or 60)
					local frame_label = GGLabel:new(V.v(label_w, 24))
					frame_label.font_name = "body"
					frame_label.font_size = 12 * rs
					frame_label.text_align = "left"
					frame_label.vertical_align = "middle"
					frame_label.colors.text = checked and {200, 220, 255, 255} or {180, 190, 210, 255}
					local size_str = string.format("%dx%d", frame.size[1], frame.size[2])
					local alias_count = #(frame.alias or {})
					local alias_str = alias_count > 0 and string.format(" alias:%d", alias_count) or ""
					if frame._dup_of then
						alias_str = alias_str .. " 重复"
					end
					frame_label.text = string.format("  %s  [%s]%s", fname, size_str, alias_str)
					frame_label.pos = V.v(38, 0)
					frame_label.fit_lines = 1
					frame_label.fit_size = true
					frame_label.propagate_on_click = true
					frame_row:add_child(frame_label)

					if group._is_loose_group then
						-- 松散组（append）的帧就是单个 png 文件：提供单图预览与等比缩放
						local src_rel = frame._src_path
						local tmp = {
							name = fname,
							rel = src_rel,
							w = frame.size and frame.size[1] or 0,
							h = frame.size and frame.size[2] or 0,
							dds_exists = false,
							dds_match = false
						}
						local f_scale = self:make_button("缩放", V.v(46, 20))
						f_scale.pos = V.v(ui.tree_list.size.x - 170, 2)
						f_scale._label.font_size = 10 * rs
						f_scale.on_press = function()
							self:show_png_scale_dialog(tmp)
						end
						frame_row:add_child(f_scale)
						local f_prev = self:make_button("预览", V.v(40, 20))
						f_prev.pos = V.v(ui.tree_list.size.x - 118, 2)
						f_prev._label.font_size = 10 * rs
						f_prev.on_press = function()
							self:preview_png_file(tmp)
						end
						frame_row:add_child(f_prev)
					end

					function frame_row.on_click()
						cb_view.on_click()
					end

					ui.tree_list:add_row(frame_row)
				end
			end
		end
	end

	print(string.format("[atlas_manager] rebuild_tree: %d groups, %d selected", #state.group_order, sel_count))
	self:set_status(string.format("已加载 %d 个图集，已选 %d 帧", #state.group_order, sel_count))
	if saved_frac > 0 and sl._bottom_y and sl._bottom_y > sl.size.y then
		sl.scroll_origin_y = -saved_frac * (sl._bottom_y - sl.size.y)
	end
end

function atlas_manager:unload_all_textures()
end

function atlas_manager:leave()
	if self._leaving then
		return
	end
	self._leaving = true
	print("[atlas_manager] leave: start")
	if ui.window then
		ui.window:set_responder()
	end
	self:unload_all_textures()
	self:release_preview()
	state._merged_idata = nil
	print("[atlas_manager] leave: switching to map")
	self.done_callback({
		next_item_name = "map"
	})
end

function atlas_manager:destroy()
	self:unload_all_textures()
	self:release_preview()
	state._merged_idata = nil
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
	print("[atlas_manager] destroy: freed")
end

function atlas_manager:release_preview()
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas then
				f.canvas:release()
			end
		end
	end
	state.preview_files = nil
	state.preview_canvas = nil
	state.preview_valid = false
	state.merge_pages = nil
end

function atlas_manager:set_status(text)
	if ui.status_label then
		ui.status_label.text = tostring(text)
	end
	print("[atlas_manager] " .. tostring(text))
end

function atlas_manager:_is_pow2(n)
	if n <= 0 then
		return false
	end
	while n > 1 do
		if n % 2 ~= 0 then
			return false
		end
		n = n / 2
	end
	return true
end

function atlas_manager:_next_pow2(n)
	local p = 1
	while p < n do
		p = p * 2
	end
	return p
end

function atlas_manager:update(dt)
	if ui.window then
		ui.window:update(dt)
	end
	if popup.active then
		popup._dt = (popup._dt or 0) + dt
		local mx, my = love.mouse.getPosition()
		if popup._last_mx and popup._last_my then
			local dx, dy = mx - popup._last_mx, my - popup._last_my
			if popup.dragging then
				popup.ox = popup.ox + dx
				popup.oy = popup.oy + dy
			end
			if popup.sb_drag and popup._sb_scroll_h and popup._sb_h and state._sprite_list then
				local list = state._sprite_list
				local max_scroll = math.max(0, #list - 1)
				local available = popup._sb_h - popup._sb_scroll_h
				if available > 0 then
					local scroll_delta = dy * (max_scroll / available)
					popup.sb_scroll = (popup.sb_scroll or 0) + scroll_delta
					popup.scroll = math.max(0, math.min(max_scroll, math.floor(popup.sb_scroll)))
				end
			end
		end
		popup._last_mx, popup._last_my = mx, my
	end
end

function atlas_manager:update_fps()
	if ui.fps_label then
		ui.fps_label.text = string.format("FPS: %.1f", love.timer.getFPS())
	end
end

function atlas_manager:draw()
	if ui.window then
		ui.window:draw()
	end
	draw_popup()
end

function atlas_manager:_calc_utilization()
	if not state.preview_frames then
		return 0
	end
	local total_pixels = state.merge_w * state.merge_h
	local used_pixels = 0
	for _, p in ipairs(state.preview_frames) do
		used_pixels = used_pixels + p.w * p.h
	end
	if total_pixels == 0 then
		return 0
	end
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
				local frame = group and group.frames[fname]
				if frame then
					local fchk = state.file_checks[gname]
					if not (fchk and frame.dds_key and fchk[frame.dds_key] == false) then
						selected[#selected + 1] = {
							group = gname,
							frame_name = fname,
							frame = frame
						}
					end
				end
			end
		end
	end
	return selected
end

--- 帧的内容指纹。内容完全一致的帧只打包一份，其余名字写成 alias 指向规范帧。
--- - 松散帧（.images/append 的独立 png）：文件内容 md5（字节一致 → 尺寸/裁剪必然一致）
--- - 图集帧：源页 + 源矩形 + 逻辑框 + 裁剪 + 缩放，四项全等才认定可复用
function atlas_manager:_frame_content_key(sel)
	local f = sel.frame
	if f._is_loose then
		local hash = f._content_hash
		if not hash then
			hash = file_md5_hex(read_fs(f._src_path))
			f._content_hash = hash
		end
		return hash and ("png:" .. hash) or nil
	end
	local fq = f.f_quad or {0, 0, 0, 0}
	local tr = f.trim or {0, 0, 0, 0}
	local sz = f.size or {0, 0}
	return string.format("atlas:%s:%d,%d,%d,%d:%d,%d,%d,%d:%d,%d:%.6f", tostring(f.a_name), fq[1], fq[2], fq[3], fq[4], tr[1], tr[2], tr[3], tr[4], sz[1], sz[2], f.ref_scale or 1)
end

--- 按内容指纹去重选中的帧（原地排序 selected）。
--- 返回：只含规范帧的选中列表、规范帧名 -> 别名列表、统计表。
--- 规范帧取文件顺序最靠前的那个（同组按 frame_order，跨组按组顺序），保证同批选中结果稳定。
function atlas_manager:_dedup_selected(selected)
	local group_index = {}
	for gi, gname in ipairs(state.group_order) do
		group_index[gname] = gi
	end
	local order = {}
	local touched = {}
	for _, sel in ipairs(selected) do
		local gname = sel.group
		if not touched[gname] then
			touched[gname] = true
			local g = state.groups[gname]
			local gi = group_index[gname] or 0
			if g and g.frame_order then
				for fi, fname in ipairs(g.frame_order) do
					order[gname .. "." .. fname] = gi * 1000000 + fi
				end
			end
		end
	end
	table.sort(selected, function(a, b)
		local ka = order[a.group .. "." .. a.frame_name] or math.huge
		local kb = order[b.group .. "." .. b.frame_name] or math.huge
		if ka ~= kb then
			return ka < kb
		end
		return (a.group .. "." .. a.frame_name) < (b.group .. "." .. b.frame_name)
	end)
	local ok_groups = {}
	local by_key = {}
	for _, sel in ipairs(selected) do
		local key = self:_frame_content_key(sel)
		local g = key and by_key[key]
		if g then
			g[#g + 1] = sel
		else
			g = {sel}
			if key then
				by_key[key] = g
			end
			ok_groups[#ok_groups + 1] = g
		end
	end
	local kept = {}
	local alias_map = {}
	local aliased = 0
	for _, g in ipairs(ok_groups) do
		local canon = g[1]
		kept[#kept + 1] = canon
		local seen = {
			[canon.frame_name] = true
		}
		local out = {}
		local function add(n)
			if n and n ~= "" and not seen[n] then
				seen[n] = true
				out[#out + 1] = n
			end
		end
		for i = 2, #g do
			add(g[i].frame_name)
			aliased = aliased + 1
		end
		-- 原有的 alias 一并带上（原本指向的名字不能丢）
		for _, m in ipairs(g) do
			for _, al in ipairs(m.frame.alias or {}) do
				add(al)
			end
		end
		alias_map[canon.frame_name] = out
	end
	return kept, alias_map, {
		before = #selected,
		after = #kept,
		aliased = aliased
	}
end

--- 生成合并用帧数据，并把去重得到的别名合并进 alias（save 会直接写出）
function atlas_manager:_merge_frame_with_alias(sel, alias_map)
	local f = self:_make_merge_frame(sel)
	local out = {}
	if type(f.alias) == "table" then
		for _, n in ipairs(f.alias) do
			out[#out + 1] = n
		end
	end
	local extra = alias_map and alias_map[sel.frame_name]
	if extra then
		for _, n in ipairs(extra) do
			if n ~= sel.frame_name then
				local dup = false
				for i = 1, #out do
					if out[i] == n then
						dup = true
						break
					end
				end
				if not dup then
					out[#out + 1] = n
				end
			end
		end
	end
	f.alias = out
	return f
end

-- 深拷贝帧数据；size/trim/ref_scale 从原始 .lua 取逻辑值，a_size/f_quad 用物理像素值
-- 这样合并/拆分时逻辑信息（ref_scale 等）不丢失
function atlas_manager:_make_merge_frame(sel)
	local src = sel.frame
	local orig = nil
	local group = state.groups[sel.group]
	if group and group.path then
		local ok, tbl = pcall(atlas_util.load_atlas_lua, group.path)
		if ok and tbl then
			orig = tbl[sel.frame_name]
		end
	end
	local logical = orig
	return {
		a_name = src.a_name,
		size = logical and {logical.size[1], logical.size[2]} or {src.size[1], src.size[2]},
		trim = logical and {logical.trim[1], logical.trim[2], logical.trim[3], logical.trim[4]} or {src.trim[1], src.trim[2], src.trim[3], src.trim[4]},
		a_size = {src.a_size[1], src.a_size[2]},
		_orig_a_size = logical and {logical.a_size[1], logical.a_size[2]} or {src.a_size[1], src.a_size[2]},
		f_quad = {src.f_quad[1], src.f_quad[2], src.f_quad[3], src.f_quad[4]},
		alias = type(src.alias) == "table" and src.alias or {},
		ref_scale = logical and (logical.ref_scale or 1) or (src.ref_scale or 1),
		dds_key = src.dds_key,
		_is_loose = src._is_loose,
		_src_path = src._src_path,
		_merge_group = sel.group
	}
end

function atlas_manager:do_merge()

	if ui.close_size_menu then
		ui.close_size_menu()
	end
	print("[atlas_manager] merge: start")
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		-- TEMP DIAG: dump why selection resolves empty
		local parts = {}
		for key, checked in pairs(state.selected_frames) do
			if checked then
				local dot = key and key:find("%.")
				if not dot then
					parts[#parts + 1] = key .. "(no dot)"
				else
					local gname = key:sub(1, dot - 1)
					local fname = key:sub(dot + 1)
					local g = state.groups[gname]
					local f = g and g.frames[fname]
					parts[#parts + 1] = string.format("%s -> group:%s frame:%s", key, g and "Y" or "N", f and "Y" or "N")
				end
			end
		end
		self:set_status("没有选中任何帧 | " .. table.concat(parts, ", "))
		return
	end
	-- 重复帧去重：内容一致的帧只打包一份，其余名字写成 alias
	local raw_count = #selected
	local alias_map, dedup_info = nil, nil
	if state.dedup_alias then
		local kept, map, info = self:_dedup_selected(selected)
		selected, alias_map, dedup_info = kept, map, info
		if info.aliased > 0 then
			print(string.format("[atlas_manager] dedup: %d -> %d frames (%d become alias)", info.before, info.after, info.aliased))
		end
	end
	local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	if name == "" then
		name = "merged_atlas"
	end
	local w = tonumber(ui.merge_w_text and ui.merge_w_text.text) or state.merge_w
	local h = tonumber(ui.merge_h_text and ui.merge_h_text.text) or state.merge_h
	if state.non_pow2_mode then
		w = align4(w)
		h = align4(h)
	else
		if not self:_is_pow2(w) or not self:_is_pow2(h) then
			self:set_status("图集尺寸必须是2的幂次")
			return
		end
	end
	local pack_frames = {}
	for _, sel in ipairs(selected) do
		local f = sel.frame
		pack_frames[#pack_frames + 1] = {
			w = f.f_quad[3],
			h = f.f_quad[4],
			frame_name = sel.frame_name,
			group = sel.group
		}
	end
	local placements, err
	if state.non_pow2_mode then
		local step = 4
		local max_attempts = 1024
		for attempt = 1, max_attempts do
			placements, err = atlas_binpack.pack(pack_frames, w, h)
			if placements then
				break
			end
			if attempt % 2 == 1 then
				w = w + step
			else
				h = h + step
			end
		end
		if not placements then
			self:set_status("打包失败(非常规): " .. tostring(err))
			return
		end
		print(string.format("[atlas_manager] non_pow2 merge: final size %dx%d", w, h))
	else
		placements, err = atlas_binpack.pack(pack_frames, w, h)
		if not placements then
			-- 严格按用户选择的尺寸：放不下就如实报错，绝不偷偷换尺寸
			local suggest = nil
			local limit = math.max(w, h)
			for _, sz in ipairs({256, 512, 1024, 2048, 4096}) do
				if sz > limit and atlas_binpack.pack(pack_frames, sz, sz) then
					suggest = sz
					break
				end
			end
			local msg = string.format("打包失败: %s", tostring(err))
			if suggest then
				msg = msg .. string.format(" | %d 帧单页最小 %dx%d，多页请点「拆分」", #pack_frames, suggest, suggest)
			end
			print(string.format("[atlas_manager] merge: pack failed at %dx%d (%s)%s", w, h, tostring(err), suggest and string.format(", smallest single page = %dx%d", suggest, suggest) or ""))
			self:set_status(msg)
			return
		end
	end
	local all_frames = {}
	for _, sel in ipairs(selected) do
		all_frames[sel.frame_name] = self:_merge_frame_with_alias(sel, alias_map)
	end
	state.merge_pages = nil
	state.scale_factor = 1
	state.preview_frames = placements
	state._placements = placements
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
	self._merge_alias_map = alias_map
	self._merge_dedup_info = dedup_info
	self._split_ready = nil
	local util = self:_calc_utilization()
	print(string.format("[atlas_manager] merge: %d frames into %dx%d, pack=ok, util=%.1f%%", #placements, w, h, util))
	if dedup_info and dedup_info.aliased > 0 then
		self:set_status(string.format("合并完成: %d帧(去重%d个→alias)打包到 %dx%d (%.1f%%)", raw_count, dedup_info.aliased, w, h, util))
	else
		self:set_status(string.format("合并完成: %d帧打包到 %dx%d 图集 (%.1f%%)", #placements, w, h, util))
	end
	self:_build_preview()
	self:show_preview_popup()
end

function atlas_manager:_collect_need_load(placements, all_frames)
	local need_load = {}
	for _, p in ipairs(placements) do
		local frame = all_frames[p.frame_name]
		if frame and not frame._preview_texture and not frame._is_loose then
			local dds_key = frame.dds_key
			if dds_key then
				if not need_load[dds_key] then
					need_load[dds_key] = {
						frames = {},
						texture = nil,
						tex_w = 0,
						tex_h = 0
					}
				end
				need_load[dds_key].frames[p.frame_name] = frame
			end
		end
	end
	return need_load
end

-- 检查 PNG 存档尺寸不匹配；返回 "ok" / "cancel" / "blocked"(弹窗等待确认)
function atlas_manager:_ensure_png_archives(need_load)
	local real_png_dir = project_root .. "/" .. IMAGES_DIR
	os.execute("mkdir -p " .. real_png_dir:gsub(" ", "\\ "))
	local replace_candidates = {}
	for dds_key, info in pairs(need_load) do
		local dds_w, dds_h = atlas_util.get_dds_dimensions(ATLAS_DIR .. "/" .. dds_key .. ".dds")
		if dds_w and dds_w > 0 then
			local pf = io.open(real_png_dir .. "/" .. dds_key .. ".png", "rb")
			if pf then
				local blob = pf:read(24)
				pf:close()
				if blob and blob:sub(1, 8) == "\137PNG\r\n\26\n" then
					local pw = string.byte(blob, 17) * 16777216 + string.byte(blob, 18) * 65536 + string.byte(blob, 19) * 256 + string.byte(blob, 20)
					local ph = string.byte(blob, 21) * 16777216 + string.byte(blob, 22) * 65536 + string.byte(blob, 23) * 256 + string.byte(blob, 24)
					if pw ~= dds_w or ph ~= dds_h then
						replace_candidates[#replace_candidates + 1] = {
							key = dds_key,
							png = string.format("%dx%d", pw, ph),
							dds = string.format("%dx%d", dds_w, dds_h)
						}
					end
				end
			end
		end
	end
	if #replace_candidates == 0 then
		return "ok"
	end
	if self._replace_confirmed == nil then
		local msg = string.format("发现 %d 个尺寸不匹配的 PNG 存档：", #replace_candidates)
		for i = 1, math.min(5, #replace_candidates) do
			local r = replace_candidates[i]
			msg = msg .. string.format("\n  %s (PNG %s, DDS %s)", r.key, r.png, r.dds)
		end
		if #replace_candidates > 5 then
			msg = msg .. string.format("\n  ...等 %d 个", #replace_candidates)
		end
		msg = msg .. "\n\n将从 DDS 重新生成正确尺寸的 PNG 替换它们。\n此操作不可撤销。确认？"
		self._replace_pending = replace_candidates
		self._replace_confirmed = nil
		if not ui.replace_dialog then
			ui.replace_dialog = KView:new(V.v(520, 300))
			ui.replace_dialog.anchor = V.v(260, 150)
			ui.replace_dialog.pos = V.v(self.ref_w / 2, self.ref_h / 2)
			ui.replace_dialog.colors.background = {30, 21, 9, 240}
			ui.replace_dialog.shape = {
				name = "rectangle",
				args = {"fill", 0, 0, 520, 300, 12, 12}
			}
			ui.window:add_child(ui.replace_dialog)
			local title = GGLabel:new(V.v(480, 28))
			title.font_name = "body"
			title.font_size = 15 * self._rs
			title.text_align = "left"
			title.vertical_align = "middle"
			title.colors.text = {244, 221, 165, 255}
			title.text = "PNG 存档尺寸不匹配"
			title.pos = V.v(20, 10)
			ui.replace_dialog:add_child(title)
			local di = GGLabel:new(V.v(480, 200))
			di.font_name = "body"
			di.font_size = 12 * self._rs
			di.text_align = "left"
			di.vertical_align = "top"
			di.colors.text = {223, 202, 152, 255}
			di.pos = V.v(20, 44)
			di.fit_lines = 8
			di.fit_size = true
			di.line_height = 1.3
			ui.replace_info = di
			ui.replace_dialog:add_child(di)
			local confirm_btn = self:make_button("确认替换", V.v(120, 32))
			confirm_btn.pos = V.v(170, 250)
			ui.replace_dialog:add_child(confirm_btn)
			confirm_btn.on_press = function()
				ui.replace_dialog.hidden = true
				self._replace_confirmed = true
			end
			local cancel_btn = self:make_button("使用 DDS", V.v(120, 32))
			cancel_btn.pos = V.v(310, 250)
			ui.replace_dialog:add_child(cancel_btn)
			cancel_btn.on_press = function()
				ui.replace_dialog.hidden = true
				self._replace_confirmed = false
			end
			local abort_btn = self:make_button("取消", V.v(100, 32))
			abort_btn.pos = V.v(440, 250)
			ui.replace_dialog:add_child(abort_btn)
			abort_btn.on_press = function()
				ui.replace_dialog.hidden = true
				self._replace_confirmed = "cancel"
			end
		end
		ui.replace_info.text = msg
		ui.replace_dialog.hidden = false
		ui.replace_dialog:order_to_front()
		if state.preview_canvas then
			state.preview_canvas:release()
			state.preview_canvas = nil
		end
		state.preview_valid = false
		return "blocked"
	end
	if self._replace_confirmed == "cancel" then
		self._replace_confirmed = nil
		return "cancel"
	end
	self._replace_confirmed = nil
	return "ok"
end

-- 为每个 frame 填充 _preview_idata；placements 为 {frame_name,...} 列表
function atlas_manager:_load_frame_idatas(placements, all_frames)
	local need_load = self:_collect_need_load(placements, all_frames)
	local decision = self:_ensure_png_archives(need_load)
	if decision ~= "ok" then
		return nil, decision
	end
	local real_png_dir = project_root .. "/" .. IMAGES_DIR
	local total_loads = 0
	-- 优先走 CPU：直接解码 PNG 存档为 ImageData，逐帧用 ImageData:paste 子矩形拷贝裁切，
	-- 避免对 4096 等大纹理做逐帧 GPU canvas 回读（弱 GPU/虚拟机环境下会长时间卡死）
	for dds_key, info in pairs(need_load) do
		local png_idata = nil
		for _, try_key in ipairs({dds_key, dds_key:gsub("%-1$", "")}) do
			if try_key ~= "" then
				local pf = io.open(real_png_dir .. "/" .. try_key .. ".png", "rb")
				if pf then
					local blob = pf:read("*all")
					pf:close()
					local ok_id, id = pcall(love.image.newImageData, love.data.newByteData(blob))
					if ok_id and id then
						png_idata = id
						break
					end
				end
			end
		end
		if png_idata then
			info.idata = png_idata
			info.tex_w = png_idata:getWidth()
			info.tex_h = png_idata:getHeight()
			total_loads = total_loads + 1
			print(string.format("[atlas_manager] load: %s (%dx%d, CPU)", dds_key, info.tex_w, info.tex_h))
		else
			-- PNG 缺失/解码失败 → 退回 GPU 路径（load_source_preview 会按需从 DDS 生成 PNG）
			local exp_w, exp_h = 0, 0
			for _, fr in pairs(info.frames) do
				if fr.a_size then
					exp_w, exp_h = fr.a_size[1], fr.a_size[2]
				end
				break
			end
			local img, _, tw, th = atlas_util.load_source_preview(dds_key, ATLAS_DIR, real_png_dir, exp_w, exp_h)
			if not img then
				local alt_key = dds_key:gsub("%-1$", "")
				if alt_key ~= dds_key then
					img, _, tw, th = atlas_util.load_source_preview(alt_key, ATLAS_DIR, real_png_dir, exp_w, exp_h)
				end
			end
			if img then
				img:setFilter("nearest", "nearest")
				info.texture = img
				info.tex_w = tw
				info.tex_h = th
				total_loads = total_loads + 1
				print(string.format("[atlas_manager] load: %s (%dx%d, GPU)", dds_key, tw, th))
			end
		end
	end
	if total_loads == 0 and next(need_load) then
		return nil, "无法加载纹理用于预览 (文件不存在?)"
	end
	local t_extract = os.clock()
	local extract_count = 0
	for _, p in ipairs(placements) do
		local frame = all_frames[p.frame_name]
		if frame then
			if frame._is_loose then
				local ok, loaded = pcall(G.newImage, frame._src_path)
				if ok then
					local trim = frame.trim
					local fw, fh = frame.f_quad[3], frame.f_quad[4]
					frame._preview_idata = atlas_util.extract_frame_pixels(loaded, {trim[1], trim[2], fw, fh}, frame.size[1], frame.size[2])
				end
			else
				local dds_key = frame.dds_key
				local info = dds_key and need_load[dds_key]
				if info then
					local q = frame.f_quad
					local idata = nil
					if info.idata then
						idata = atlas_util.crop_idata(info.idata, q[1], q[2], q[3], q[4])
					end
					if idata then
						frame._preview_idata = idata
					elseif info.texture then
						frame._preview_idata = atlas_util.extract_frame_pixels(info.texture, q, info.tex_w, info.tex_h)
					end
				end
			end
			extract_count = extract_count + 1
			if extract_count % 100 == 0 then
				print(string.format("[atlas_manager] extract progress: %d/%d (%.1fs)", extract_count, #placements, os.clock() - t_extract))
			end
		end
	end
	print(string.format("[atlas_manager] extract done: %d/%d frames (%.1fs)", extract_count, #placements, os.clock() - t_extract))
	for _, info in pairs(need_load) do
		info.idata = nil -- 尽早释放大块 CPU 内存
	end
	return true
end

function atlas_manager:_build_preview()
	local placements = self._merge_placements
	if not placements then
		self:set_status("没有可的合并数据")
		return
	end
	local all_frames = self._merge_src_frames
	local w = state.merge_w
	local h = state.merge_h
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas then
				f.canvas:release()
			end
		end
	end
	state.preview_files = nil
	state.preview_canvas = nil
	state._sprite_list = {}
	state._sprite_group = {}
	for fname, _ in pairs(all_frames) do
		state._sprite_list[#state._sprite_list + 1] = fname
	end
	table.sort(state._sprite_list)
	for _, p in ipairs(placements) do
		if p.data and p.data.group then
			state._sprite_group[p.frame_name] = p.data.group
		end
	end
	local ok, err = self:_load_frame_idatas(placements, all_frames)
	if not ok then
		if err ~= "cancel" and err ~= "blocked" then
			self:set_status(err or "加载纹理失败")
		elseif err == "cancel" then
			self:set_status("已取消")
		end
		return
	end
	-- extract each frame as clean ImageData, then build merged ImageData

	local merged_idata = atlas_util.create_merged_atlas(placements, all_frames, w, h)
	state._merged_idata = merged_idata

	for _, p in ipairs(placements) do
		local frame = all_frames[p.frame_name]
		if frame then
			frame._preview_idata = nil
		end
	end
	print(string.format("[atlas_manager] preview_canvas: %dx%d created (unified path)", w, h))
	local canvas = G.newCanvas(w, h)
	G.setCanvas(canvas)
	local preview_img = G.newImage(merged_idata)
	G.setColor(1, 1, 1, 1)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("alpha", "premultiplied")
	G.draw(preview_img, 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	state.preview_valid = true
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas and f.canvas ~= canvas then
				f.canvas:release()
			end
		end
	end
	state.preview_files = {{
		key = state.merge_name or "merged",
		canvas = canvas,
		w = w,
		h = h,
		placements = placements,
		sprite_list = state._sprite_list,
		sprite_group = state._sprite_group
	}}
	state.preview_canvas = canvas
	popup.file_idx = 1
	self:select_preview_file(1)
end

function atlas_manager:_resample_idata(idata, new_w, new_h)
	local src_w, src_h = idata:getWidth(), idata:getHeight()
	if new_w == src_w and new_h == src_h then
		return idata
	end
	local img = G.newImage(idata)
	img:setFilter("linear", "linear")
	local canvas = G.newCanvas(new_w, new_h)
	G.setCanvas(canvas)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("alpha", "premultiplied")
	G.draw(img, 0, 0, 0, new_w / src_w, new_h / src_h)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	local out = canvas:newImageData()
	canvas:release()
	return out
end

function atlas_manager:apply_scale(factor)
	if not state._merged_idata or not self._merge_placements then
		self:set_status("请先合并生成图集")
		return
	end
	if state.merge_pages then
		self:set_status("已拆分图集，缩放请先重新合并")
		return
	end
	local old_w, old_h = state.merge_w, state.merge_h
	local new_w = math.max(4, math.floor(old_w * factor + 0.5))
	local new_h = math.max(4, math.floor(old_h * factor + 0.5))
	local sx, sy = new_w / old_w, new_h / old_h
	local idata = self:_resample_idata(state._merged_idata, new_w, new_h)
	state._merged_idata = idata
	state.merge_w = new_w
	state.merge_h = new_h
	state.scale_factor = factor
	for _, p in ipairs(self._merge_placements) do
		p.x = math.floor(p.x * sx)
		p.y = math.floor(p.y * sy)
		p.w = math.max(1, math.floor(p.w * sx))
		p.h = math.max(1, math.floor(p.h * sy))
	end
	for fname, f in pairs(self._merge_src_frames) do
		f.size = {math.max(1, math.floor(f.size[1] * sx)), math.max(1, math.floor(f.size[2] * sy))}
		f.trim = {math.floor(f.trim[1] * sx), math.floor(f.trim[2] * sy), math.floor(f.trim[3] * sx), math.floor(f.trim[4] * sy)}
		f.a_size = {new_w, new_h}
	end
	-- rebuild preview from scaled idata
	local canvas = G.newCanvas(new_w, new_h)
	G.setCanvas(canvas)
	local preview_img = G.newImage(idata)
	G.setColor(1, 1, 1, 1)
	G.clear(0, 0, 0, 0)
	G.setBlendMode("alpha", "premultiplied")
	G.draw(preview_img, 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas and f.canvas ~= canvas then
				f.canvas:release()
			end
		end
	end
	state.preview_files = {{
		key = state.merge_name or "scaled",
		canvas = canvas,
		w = new_w,
		h = new_h,
		placements = self._merge_placements,
		sprite_list = state._sprite_list,
		sprite_group = state._sprite_group
	}}
	state.preview_canvas = canvas
	state.preview_valid = true
	popup.file_idx = 1
	ui.scale_info.text = string.format("已缩放: %dx%d (%.2fMP)", new_w, new_h, new_w * new_h / 1e6)
	self:set_status(string.format("已缩放至 %dx%d", new_w, new_h))
	self:show_preview_popup()
end

function atlas_manager:do_split(max_size)
	if state.merge_pages then
		self:set_status("已经拆分过了")
		return
	end
	max_size = math.floor(max_size or 4096)
	-- 直接基于选中的帧进行拆分，无需先合并
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("没有选中任何帧")
		return
	end
	local raw_count = #selected
	local alias_map, dedup_info = nil, nil
	if state.dedup_alias then
		local kept, map, info = self:_dedup_selected(selected)
		selected, alias_map, dedup_info = kept, map, info
		if info.aliased > 0 then
			print(string.format("[atlas_manager] dedup: %d -> %d frames (%d become alias)", info.before, info.after, info.aliased))
		end
	end
	-- 深拷贝帧数据，避免污染源 group；size/trim/ref_scale 用原始 .lua 逻辑值
	local all_frames = {}
	for _, sel in ipairs(selected) do
		all_frames[sel.frame_name] = self:_merge_frame_with_alias(sel, alias_map)
	end
	local placements = {}
	for _, sel in ipairs(selected) do
		local f = sel.frame
		placements[#placements + 1] = {
			frame_name = sel.frame_name,
			x = 0,
			y = 0,
			w = f.f_quad[3],
			h = f.f_quad[4],
			data = {
				group = sel.group
			}
		}
	end
	-- 加载每帧像素 (dds/png/loose)
	local ok, err = self:_load_frame_idatas(placements, all_frames)
	if not ok then
		if err ~= "cancel" and err ~= "blocked" then
			self:set_status(err or "加载纹理失败")
		elseif err == "cancel" then
			self:set_status("已取消")
		end
		return
	end
	-- pack frames greedily into multiple pages of max_size x max_size
	local pack_frames = {}
	for _, p in ipairs(placements) do
		pack_frames[#pack_frames + 1] = {
			w = p.w,
			h = p.h,
			frame_name = p.frame_name
		}
	end
	local pages = {}
	local cur_pack = {}
	local function try_pack(list)
		return atlas_binpack.pack(list, max_size, max_size)
	end
	for _, f in ipairs(pack_frames) do
		local trial = {}
		for i, cf in ipairs(cur_pack) do
			trial[i] = cf
		end
		trial[#trial + 1] = f
		if try_pack(trial) then
			cur_pack = trial
		elseif #cur_pack == 0 then
			self:set_status(string.format("拆分失败: 帧 %s (%dx%d) 超过上限 %d", f.frame_name or "?", f.w, f.h, max_size))
			return
		else
			local placed = try_pack(cur_pack)
			if placed then
				pages[#pages + 1] = placed
			end
			if not try_pack({f}) then
				self:set_status(string.format("拆分失败: 帧 %s (%dx%d) 超过上限 %d", f.frame_name or "?", f.w, f.h, max_size))
				return
			end
			cur_pack = {f}
		end
	end
	if #cur_pack > 0 then
		local placed = try_pack(cur_pack)
		if placed then
			pages[#pages + 1] = placed
		end
	end
	if #pages <= 1 then
		self:set_status(string.format("选中帧 %d 帧，未超过 %d 无需拆分（已打包为单页）", raw_count, max_size))
		ui.split_dialog.hidden = true
		return
	end
	-- build per-page image data by pasting each frame's already-extracted pixels
	local page_entries = {}
	local preview_files = {}
	for pi, pl in ipairs(pages) do
		local pw, ph = 0, 0
		for _, p in ipairs(pl) do
			pw = math.max(pw, p.x + p.w)
			ph = math.max(ph, p.y + p.h)
		end
		pw = self:_next_pow2(pw)
		ph = self:_next_pow2(ph)
		if pw > max_size then
			pw = max_size
		end
		if ph > max_size then
			ph = max_size
		end
		local page_idata = love.image.newImageData(pw, ph)
		page_idata:mapPixel(function()
			return 0, 0, 0, 0
		end)
		local page_placements = {}
		for _, p in ipairs(pl) do
			local fname = p.frame_name
			local frame_idata = all_frames[fname] and all_frames[fname]._preview_idata
			if frame_idata then
				page_idata:paste(frame_idata, p.x, p.y, 0, 0, p.w, p.h)
			end
			page_placements[#page_placements + 1] = {
				frame_name = fname,
				x = p.x,
				y = p.y,
				w = p.w,
				h = p.h
			}
		end
		page_entries[#page_entries + 1] = {
			w = pw,
			h = ph,
			idata = page_idata,
			placements = page_placements
		}
		-- build preview canvas for this page
		local canvas = G.newCanvas(pw, ph)
		G.setCanvas(canvas)
		local pg_img = G.newImage(page_idata)
		G.setColor(1, 1, 1, 1)
		G.clear(0, 0, 0, 0)
		G.setBlendMode("alpha", "premultiplied")
		G.draw(pg_img, 0, 0)
		G.setBlendMode("alpha", "alphamultiply")
		G.setCanvas()
		local sprite_list = {}
		for _, p in ipairs(page_placements) do
			sprite_list[#sprite_list + 1] = p.frame_name
		end
		table.sort(sprite_list)
		preview_files[#preview_files + 1] = {
			key = string.format("page-%d", pi),
			canvas = canvas,
			w = pw,
			h = ph,
			placements = page_placements,
			sprite_list = sprite_list,
			sprite_group = {}
		}
		for _, p in ipairs(page_placements) do
			local srcf = all_frames[p.frame_name]
			preview_files[#preview_files].sprite_group[p.frame_name] = srcf and srcf._merge_group or nil
		end
	end
	for _, f in pairs(all_frames) do
		f._preview_idata = nil
	end
	if state.preview_files then
		for _, f in ipairs(state.preview_files) do
			if f.canvas then
				f.canvas:release()
			end
		end
	end
	state.merge_pages = page_entries
	self._merge_placements = placements
	self._merge_src_frames = all_frames
	self._merge_alias_map = alias_map
	self._merge_dedup_info = dedup_info
	self._split_ready = true
	local split_name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	if split_name == "" then
		split_name = "merged_atlas"
	end
	state.merge_name = split_name
	state.preview_files = preview_files
	state.preview_canvas = preview_files[1].canvas
	state.preview_valid = true
	popup.file_idx = 1
	self:select_preview_file(1)
	ui.split_dialog.hidden = true
	-- write split page PNGs to .images so they can be previewed / selectively converted
	local merge_name = ui.merge_name_input and ui.merge_name_input._text or state.merge_name or "merged_atlas"
	if merge_name == "" then
		merge_name = "merged_atlas"
	end
	local written = 0
	for pi, page in ipairs(page_entries) do
		local png_path = real_path(IMAGES_DIR) .. "/" .. merge_name .. "-" .. pi .. ".png"
		file_utlis.ensure_parent_dir(png_path)
		local png_data = self:merged_idata_to_png(page.idata)
		if write_real(png_path, png_data) then
			written = written + 1
		end
	end
	self:set_status(string.format("已拆分为 %d 页(去重%d→%d)，PNG已写入 .images (%s-1.png ...)", #page_entries, raw_count, #selected, merge_name))
	print(string.format("[atlas_manager] split: wrote %d page PNGs as %s-N.png", written, merge_name))
	self:show_preview_popup()
end

function atlas_manager:delete_frames()
	print("[atlas_manager] delete: start")
	local to_delete = {}
	for key, checked in pairs(state.selected_frames) do
		if checked then
			local dot = key:find("%.")
			if dot then
				local gname = key:sub(1, dot - 1)
				local fname = key:sub(dot + 1)
				local group = state.groups[gname]
				if group and group.frames[fname] and not group._is_loose_group then
					to_delete[gname] = to_delete[gname] or {}
					to_delete[gname][#to_delete[gname] + 1] = fname
					print(string.format("[atlas_manager] delete: %s/%s", gname, fname))
				end
			end
		end
	end
	local total_del = 0
	for gname, fnames in pairs(to_delete) do
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

function atlas_manager:merged_idata_to_png(idata)
	local w, h = idata:getWidth(), idata:getHeight()
	local out = love.image.newImageData(w, h)
	out:paste(idata, 0, 0, 0, 0, w, h)
	-- health bar hack
	local hb_w = math.ceil(w / 1024) + 1
	local hb_h = math.ceil(h / 1024) + 1
	for y = 0, math.min(hb_h - 1, h - 1) do
		for x = 0, math.min(hb_w - 1, w - 1) do
			out:setPixel(x, y, 255, 255, 255, 255)
		end
	end
	local png_data = out:encode("png")
	if png_data.getString then
		png_data = png_data:getString()
	end
	return png_data
end

function atlas_manager:export_png()
	local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	if name == "" then
		name = "merged_atlas"
	end
	if state.merge_pages and #state.merge_pages > 0 then
		local count = 0
		for pi, page in ipairs(state.merge_pages) do
			local png_path = real_path(IMAGES_DIR) .. "/" .. name .. "-" .. pi .. ".png"
			file_utlis.ensure_parent_dir(png_path)
			local png_data = self:merged_idata_to_png(page.idata)
			local ok = write_real(png_path, png_data)
			if ok then
				count = count + 1
				print(string.format("[atlas_manager] export_png: %s (%dx%d)", png_path, page.w, page.h))
			end
		end
		if count > 0 then
			self:set_status(string.format("已导出 %d 个PNG页: %s-1.png ... %s-%d.png", count, name, name, #state.merge_pages))
			-- 记录本次导出的各页 PNG 对应的 DDS 转换命令
			local cmds = {}
			for pi = 1, #state.merge_pages do
				cmds[#cmds + 1] = string.format("nvcompress.exe -bc3 -maximum %q %q", real_path(IMAGES_DIR) .. "/" .. name .. "-" .. pi .. ".png", real_path(ATLAS_DIR) .. "/" .. name .. "-" .. pi .. ".dds")
			end
			self._pending_dds_commands = cmds
		else
			self:set_status("PNG导出失败")
		end
		return
	end
	if not state._merged_idata then
		self:set_status("请先预览合并结果")
		return
	end
	local png_path = real_path(IMAGES_DIR) .. "/" .. name .. ".png"
	file_utlis.ensure_parent_dir(png_path)
	local png_data = self:merged_idata_to_png(state._merged_idata)
	local ok = write_real(png_path, png_data)
	if ok then
		print(string.format("[atlas_manager] export_png: %s (%dx%d)", png_path, state.merge_w, state.merge_h))
		self:set_status(string.format("已导出PNG: %s", png_path))
		-- 记录本次导出的 PNG 对应的 DDS 转换命令，避免后续「DDS转换」误用旧命令
		self._pending_dds_commands = {string.format("nvcompress.exe -bc3 -maximum %q %q", png_path, real_path(ATLAS_DIR) .. "/" .. name .. ".dds")}
	else
		self:set_status("PNG导出失败")
	end
end

--- 检查本次要写出的 alias 名字是否已被其它图集占用。
--- db_atlas 是全局表，同名会被后加载的图集覆盖（顺序不确定），因此需要提示。
--- 返回冲突描述列表（同时打印到控制台）。
function atlas_manager:_alias_conflicts(name, new_frames)
	local alias_names = {}
	for _, fdata in pairs(new_frames) do
		for _, n in ipairs(type(fdata.alias) == "table" and fdata.alias or {}) do
			alias_names[#alias_names + 1] = n
		end
	end
	if #alias_names == 0 then
		return nil
	end
	local owner = {}
	for _, gname in ipairs(state.group_order) do
		if gname ~= name then
			local g = state.groups[gname]
			if g then
				for fname, f in pairs(g.frames) do
					if owner[fname] == nil then
						owner[fname] = gname
					end
					for _, al in ipairs(f.alias or {}) do
						if owner[al] == nil then
							owner[al] = gname
						end
					end
				end
			end
		end
	end
	local hits = {}
	for _, al in ipairs(alias_names) do
		local gname = owner[al]
		if gname then
			hits[#hits + 1] = string.format("%s (已被图集 %s 占用)", al, gname)
		end
	end
	if #hits > 0 then
		print(string.format("[atlas_manager] alias conflict: %s 写出 %d 个 alias 名与其它图集重名", name, #hits))
		for i = 1, math.min(#hits, 10) do
			print("  - " .. hits[i])
		end
		if #hits > 10 then
			print(string.format("  ... 其余 %d 个见上", #hits - 10))
		end
	end
	return hits
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
					if group.frames[fn] then
						frame_count = frame_count + 1
					end
				end
				if frame_count == 0 then
					return self:set_status("图集 " .. gname .. " 已无帧, 无法保存")
				end
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
		local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
		if name == "" then
			name = "merged_atlas"
		end
		if not self._merge_placements and not self._split_ready then
			self:do_merge()
		end
		if not self._merge_placements then
			return
		end
		if not state.merge_pages and not state._merged_idata then
			return
		end
		local all_frames = self._merge_src_frames
		local w = state.merge_w
		local h = state.merge_h
		local new_frames = {}
		local dds_commands = {}
		if state.merge_pages and #state.merge_pages > 0 then
			for pi, page in ipairs(state.merge_pages) do
				local page_name = name .. "-" .. pi
				for _, p in ipairs(page.placements) do
					local src = all_frames[p.frame_name]
					if src then
						-- 物理坐标基：a_size/f_quad 直接写实际像素，size/trim ×k，ref_scale ÷k
						local kx, ky = 1, 1
						if src._orig_a_size and src._orig_a_size[1] and src.a_size and src.a_size[1] > 0 then
							kx = src.a_size[1] / src._orig_a_size[1]
							ky = src.a_size[2] / src._orig_a_size[2]
						end
						local rs = (src.ref_scale or 1) / kx
						new_frames[p.frame_name] = {
							a_name = page_name .. ".dds",
							size = {math.floor(src.size[1] * kx + 0.5), math.floor(src.size[2] * ky + 0.5)},
							trim = {math.floor(src.trim[1] * kx + 0.5), math.floor(src.trim[2] * ky + 0.5), math.floor(src.trim[3] * kx + 0.5), math.floor(src.trim[4] * ky + 0.5)},
							a_size = {page.w, page.h},
							f_quad = {p.x, p.y, p.w, p.h},
							alias = type(src.alias) == "table" and src.alias or {},
							ref_scale = rs
						}
					end
				end
				dds_commands[#dds_commands + 1] = string.format("nvcompress.exe -bc3 -maximum %q %q", real_path(IMAGES_DIR) .. "/" .. page_name .. ".png", real_path(ATLAS_DIR) .. "/" .. page_name .. ".dds")
			end
		else
			local placements = self._merge_placements
			for _, p in ipairs(placements) do
				local src = all_frames[p.frame_name]
				if src then
					-- 物理坐标基：与 split 分支同规则，保留 ref_scale
					local kx, ky = 1, 1
					if src._orig_a_size and src._orig_a_size[1] and src.a_size and src.a_size[1] > 0 then
						kx = src.a_size[1] / src._orig_a_size[1]
						ky = src.a_size[2] / src._orig_a_size[2]
					end
					local rs = (src.ref_scale or 1) / kx
					new_frames[p.frame_name] = {
						a_name = name .. ".dds",
						size = {math.floor(src.size[1] * kx + 0.5), math.floor(src.size[2] * ky + 0.5)},
						trim = {math.floor(src.trim[1] * kx + 0.5), math.floor(src.trim[2] * ky + 0.5), math.floor(src.trim[3] * kx + 0.5), math.floor(src.trim[4] * ky + 0.5)},
						a_size = {w, h},
						f_quad = {p.x, p.y, p.w, p.h},
						alias = type(src.alias) == "table" and src.alias or {},
						ref_scale = rs
					}
				end
			end
			dds_commands[#dds_commands + 1] = string.format("nvcompress.exe -bc3 -maximum %q %q", real_path(IMAGES_DIR) .. "/" .. name .. ".png", real_path(ATLAS_DIR) .. "/" .. name .. ".dds")
		end
		local atlas_real_dir = real_path(ATLAS_DIR)
		-- alias 安全网：alias 名字若本身也作为独立帧写出，同文件内会重复定义，剔除掉
		local alias_fixed = 0
		for fname, fdata in pairs(new_frames) do
			local al = fdata.alias
			if type(al) == "table" and #al > 0 then
				local filtered = {}
				for _, n in ipairs(al) do
					if n ~= fname and not new_frames[n] then
						filtered[#filtered + 1] = n
					else
						alias_fixed = alias_fixed + 1
					end
				end
				fdata.alias = filtered
			end
		end
		if alias_fixed > 0 then
			print(string.format("[atlas_manager] alias: dropped %d conflicting names while writing %s", alias_fixed, name))
		end
		local alias_conflicts = self:_alias_conflicts(name, new_frames)
		local backup_real_dir = real_path(BACKUP_DIR)
		local bp = atlas_util.backup_files(atlas_real_dir, name, backup_real_dir, read_fs, write_real)
		print(string.format("[atlas_manager] save_backup: %s -> %s", name, bp))
		local ok, err = atlas_util.write_atlas_files(atlas_real_dir, name, new_frames, write_real)
		if not ok then
			return self:set_status("写入文件失败: " .. (err or "unknown"))
		end
		print(string.format("[atlas_manager] save_compile: %s .lua/.luac/.aluac written", name))
		self._pending_dds_commands = dds_commands
		if alias_conflicts and #alias_conflicts > 0 then
			self:set_status(string.format("已保存 %s（注意: %d 个 alias 名与其它图集重名，见控制台）", name, #alias_conflicts))
		else
			self:set_status(string.format("已保存 %s.", name))
		end
		if hot_reload then
			self:_hot_reload_group(name, new_frames, w, h)
			state.preview_valid = false
			if state.preview_files then
				for _, f in ipairs(state.preview_files) do
					if f.canvas then
						f.canvas:release()
					end
				end
				state.preview_files = nil
			end
			state.preview_canvas = nil
			state._merged_idata = nil
			state.preview_frames = nil
			state.merge_pages = nil
			self._merge_placements = nil
			self._merge_src_frames = nil
			self._split_ready = nil
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
			size = {fdata.size[1], fdata.size[2]}
		}
		for i = 1, #(fdata.alias or {}) do
			I.db_atlas[fdata.alias[i]] = I.db_atlas[fname]
		end
	end
	print(string.format("[atlas_manager] hot_reload: %s from %s (%dx%d) %d frames -> image_db", name, png_path, img_w, img_h, #frames))
	self:set_status("热重载完成: " .. name)
end

function atlas_manager:print_dds_commands()
	local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	local commands = self._pending_dds_commands or {}
	if #commands == 0 then
		local png_path = real_path(IMAGES_DIR) .. "/" .. name .. ".png"
		local dds_path = real_path(ATLAS_DIR) .. "/" .. name .. ".dds"
		commands = {string.format("nvcompress.exe -bc3 -maximum %q %q", png_path, dds_path)}
	end
	print("\n===== 执行 DDS 转换 =====")
	for _, cmd in ipairs(commands) do
		print(cmd)
		local ok = os.execute(cmd)
		if ok then
			print("✅ DDS 转换完成: " .. cmd)
		else
			print("❌ DDS 转换失败")
			self:set_status("DDS 转换失败，请检查 nvcompress.exe")
			return
		end
	end
	-- 执行完毕即清空，防止残留的旧命令在下次转换时被重复执行
	self._pending_dds_commands = nil
	self:set_status("DDS 转换完成")
	print("========================================\n")
end

function atlas_manager:ai_upscale()
	local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	local src = real_path(IMAGES_DIR) .. "/" .. name .. ".png"
	local dst = real_path(IMAGES_DIR) .. "/" .. name .. "_2x.png"
	local models_path = "/usr/share/realesrgan-ncnn-vulkan/models"
	local model_name = "realesr-animevideov3-x2"
	local ultramix_dirs = {os.getenv("HOME") .. "/.local/share/upscayl/models", "/usr/share/upscayl/models", "/opt/upscayl/models"}
	for _, d in ipairs(ultramix_dirs) do
		if io.open(d .. "/ultramix.param", "rb") then
			models_path = d
			model_name = "ultramix"
			break
		end
	end
	local cmd = string.format("realesrgan-ncnn-vulkan -i %q -o %q -m %q -n %s -s 2", src, dst, models_path, model_name)
	print(string.format("[atlas_manager] ai_upscale: %s", cmd))
	self:set_status("AI 放大中...")
	local ok = os.execute(cmd)
	if ok then
		local f = io.open(dst, "rb")
		if f then
			local sz = f:seek("end")
			f:close()
			state._ai_upscaled = dst
			self:set_status(string.format("AI 放大完成: %s (%d bytes)", dst, sz))
			print(string.format("[atlas_manager] ai_upscale: done %s (%d bytes)", dst, sz))
		end
	else
		self:set_status("AI 放大失败")
	end
end

function atlas_manager:replace_with_upscaled()
	local src = state._ai_upscaled
	if not src then
		self:set_status("没有可用的 AI 放大结果，请先执行 AI 放大")
		return
	end
	local name = ui.merge_name_input and ui.merge_name_input._text or "merged_atlas"
	local dst = real_path(IMAGES_DIR) .. "/" .. name .. ".png"
	local fi = io.open(src, "rb")
	if not fi then
		self:set_status("AI 放大文件不存在: " .. src)
		return
	end
	local data = fi:read("*all")
	fi:close()
	local idata = love.image.newImageData(love.data.newByteData(data))
	local iw, ih = idata:getWidth(), idata:getHeight()
	local hb_w = math.ceil(iw / 1024)
	local hb_h = math.ceil(ih / 1024)
	for y = 0, math.min(hb_h - 1, ih - 1) do
		for x = 0, math.min(hb_w - 1, iw - 1) do
			idata:setPixel(x, y, 255, 255, 255, 255)
		end
	end
	local out_data = idata:encode("png")
	if out_data.getString then
		out_data = out_data:getString()
	end
	local fo = io.open(dst, "wb")
	if not fo then
		self:set_status("无法写入: " .. dst)
		return
	end
	fo:write(out_data)
	fo:close()
	print(string.format("[atlas_manager] replace: %s (%s) -> %s (health bar block applied)", src, idata:getWidth() .. "x" .. idata:getHeight(), dst))
	state._after_replace = true
	self:set_status("已替换为 AI 放大版本，请点击 DDS 转换生成新 DDS，不要再点击合并/保存")
end

function atlas_manager:mousepressed(x, y, button)
	if popup.active then
		if button == 1 then
			local sw = love.graphics.getWidth()
			local cs = CLOSE_BTN_SIZE
			if x > sw - cs and y < cs then
				self:hide_preview_popup()
				return
			end
			if not popup.show_list then
				-- file tab switching
				for i, tab in ipairs(popup.file_tabs) do
					if x >= tab.x and x <= tab.x + tab.w and y >= tab.y and y <= tab.y + tab.h then
						self:select_preview_file(i)
						return
					end
				end
				popup.dragging = true
				popup.lx = x
				popup.ly = y
			elseif popup._sb_x then
				if x >= popup._sb_x and x <= popup._sb_x + popup._sb_w and y >= popup._sb_y0 and y <= popup._sb_y0 + popup._sb_h then
					popup.sb_drag = true
					popup.sb_y = y
					popup.sb_scroll = popup.scroll
				end
			end
			-- sprite list item click (not on scrollbar)
			if popup.show_list and state._sprite_list and not popup.sb_drag then
				local list_w = math.min(480, math.floor(sw * 0.45))
				if x > sw - list_w then
					local font = love.graphics.newFont(12)
					local lh = font:getHeight() + 2
					local idx = math.floor((y - 4) / lh) + 1 + popup.scroll
					if idx >= 1 and idx <= #state._sprite_list then
						popup.sel_idx = idx
					end
				end
			end
		end
		return
	end
	if ui.window then
		ui.window:mousepressed(x, y, button)
	end
end

function atlas_manager:mousereleased(x, y, button)
	if popup.active then
		if button == 1 then
			popup.dragging = false
			popup.sb_drag = false
			popup.sb_scroll = nil
			popup._last_mx = nil
			popup._last_my = nil
		end
		return
	end
	if ui.window then
		ui.window:mousereleased(x, y, button)
	end
end

function atlas_manager:wheelmoved(dx, dy)
	if popup.active and state.preview_canvas then
		if popup.show_list then
			local list = state._sprite_list
			if list then
				local max_scroll = math.max(0, #list - 1)
				popup.scroll = math.max(0, math.min(max_scroll, popup.scroll - dy))
				popup.sel_idx = math.max(1, math.min(#list, popup.sel_idx - dy))
			end
		else
			popup.scale = math.max(0.1, math.min(10, popup.scale + dy * 0.1))
		end
		return
	end
	if ui.tree_list then
		ui.tree_list:on_scroll(dy < 0 and "wd" or "wu")
	end
end

function atlas_manager:textinput(t)
	if popup.active then
		return
	end
	if ui.window then
		ui.window:textinput(t)
	end
end

function atlas_manager:keypressed(key, isrepeat)
	if key == "escape" then
		if ui.size_menu_dlg and not ui.size_menu_dlg.hidden then
			ui.close_size_menu()
			return
		end
		if ui.repack_dialog and not ui.repack_dialog.hidden then
			ui.repack_dialog.hidden = true
			return
		end
		if popup.active then
			self:hide_preview_popup()
			return
		end
	end
	if popup.active then
		if key == "s" or key == "S" then
			popup.show_list = not popup.show_list
			return
		elseif key == "=" or key == "+" then
			if popup.show_list then
				popup.zoom = math.min(10, popup.zoom + 0.25)
			else
				popup.scale = math.min(10, popup.scale + 0.1)
			end
			return
		elseif key == "-" then
			if popup.show_list then
				popup.zoom = math.max(0.1, popup.zoom - 0.25)
			else
				popup.scale = math.max(0.1, popup.scale - 0.1)
			end
			return
		elseif key == "x" or key == "X" then
			if popup.show_list and state._sprite_list then
				local sel = state._sprite_list[popup.sel_idx]
				if sel then
					local grp = state._sprite_group and state._sprite_group[sel]
					local sel_key = grp and (grp .. "." .. sel) or nil
					if sel_key then
						if state.selected_frames[sel_key] then
							state.selected_frames[sel_key] = nil
						else
							state.selected_frames[sel_key] = true
						end
					end
				end
				return
			end
		elseif key == "r" or key == "R" then
			self:preview_merge()
			if not popup.active then
				self:show_preview_popup()
			end
			return
		elseif (key == "tab" or key == "." or key == "[" or key == "]") and state.preview_files and #state.preview_files > 1 then
			local dir = (key == "." or key == "]") and 1 or -1
			local ni = popup.file_idx + dir
			if ni < 1 then
				ni = #state.preview_files
			elseif ni > #state.preview_files then
				ni = 1
			end
			self:select_preview_file(ni)
			return
		end
		-- arrow keys for list navigation
		if popup.show_list and state._sprite_list then
			local list = state._sprite_list
			if key == "down" then
				popup.sel_idx = math.min(#list, popup.sel_idx + 1)
				local max_vis = math.floor((love.graphics.getHeight() - 20) / (love.graphics.newFont(12):getHeight() + 2))
				if popup.sel_idx > popup.scroll + max_vis then
					popup.scroll = popup.sel_idx - max_vis
				end
				return
			elseif key == "up" then
				popup.sel_idx = math.max(1, popup.sel_idx - 1)
				if popup.sel_idx <= popup.scroll then
					popup.scroll = popup.sel_idx - 1
				end
				return
			end
		end
	end
	if ui.window then
		ui.window:keypressed(key, isrepeat)
	end
end

function atlas_manager:preview_merge()
	print("[atlas_manager] preview_merge: start")
	self:do_merge()
end

-- ============================================================
-- 图集重打包（repack）
-- 规则：同 prefix 族的帧必须整体进入同一输出图集。
-- 打包判定只发生在点击「顺序填充」与「打包并暂存」时；
-- 切换尺寸/输出集数量仅改数值与显示，不触发打包检查。
-- 状态精简：每集只显示 帧数+占用百分比；装不下才提示。
-- ============================================================
local RPK_MAX_K = 8
local RPK_PAGE_ROWS = 12

local function rpk_frame_prefix(name)
	return (name:match("^(.-)_%d+$")) or name
end

local function rpk_build_families(selected_set)
	local fam, order = {}, {}
	for name in pairs(selected_set) do
		local p = rpk_frame_prefix(name)
		if not fam[p] then
			fam[p] = {}
			order[#order + 1] = p
		end
		fam[p][#fam[p] + 1] = name
	end
	table.sort(order)
	for _, p in ipairs(order) do
		table.sort(fam[p])
	end
	return fam, order
end

-- 懒构建全量倒排索引：帧名(含 alias) -> 出现它的图集集合。
-- 只在图集数据变化(refresh_groups)后重建一次，后续打开重打包对话框 O(1) 查询。
-- 纹理文件名（去扩展名），如 "go_stage36.dds" -> "go_stage36"
local function rpk_tex_key(a_name)
	local n = tostring(a_name or ""):match("([^/]+)$") or ""
	return (n:match("^(.+)%.[^.]+$")) or n
end

-- 懒构建倒排索引：纹理名 -> 引用它的图集集合（含示例帧）
function atlas_manager:rpk_ensure_index()
	if not state.ref_index_dirty then
		return
	end
	local idx, ex = {}, {}
	for gname, g in pairs(state.groups) do
		if g and g.frames then
			for fn, v in pairs(g.frames) do
				local tex = rpk_tex_key(v and v.a_name)
				if tex ~= "" then
					if not idx[tex] then
						idx[tex] = {}
					end
					idx[tex][gname] = true
					if not ex[tex] then
						ex[tex] = {}
					end
					if not ex[tex][gname] then
						ex[tex][gname] = {}
					end
					if #ex[tex][gname] < 2 then
						ex[tex][gname][#ex[tex][gname] + 1] = fn
					end
				end
			end
		end
	end
	ui.rpk_tex_index = idx
	ui.rpk_tex_examples = ex
	state.ref_index_dirty = false
end

-- 引用检查（按 DDS 纹理）：
-- 重打包将覆盖/删除本图集自己的 dds 页（base.dds / base-N.dds，含磁盘上残留的旧页）。
-- 若其它图集有帧的 a_name 指向这些 dds，替换后其 quad 会失效 → 阻止并列出引用方。
function atlas_manager:rpk_block_refs(removed_set, gname)
	self:rpk_ensure_index()
	local idx = ui.rpk_tex_index or {}
	local ex = ui.rpk_tex_examples or {}
	local g0 = state.groups[gname]
	-- 目标纹理集合：本组帧当前引用的纹理 + 磁盘上本组前缀(base/base-N)的 dds 页
	local target = {}
	if g0 and g0.frames then
		for _, v in pairs(g0.frames) do
			local tex = rpk_tex_key(v and v.a_name)
			if tex ~= "" then
				target[tex] = true
			end
		end
	end
	-- 磁盘上残留的同前缀页（如旧的 -2/-3），也会被清理/覆盖
	do
		local ok, items = pcall(love.filesystem.getDirectoryItems, ATLAS_DIR)
		if ok and type(items) == "table" then
			for _, nm in ipairs(items) do
				local page = nm:match("^(" .. gname .. "(?:%-%d+)?)%.dds$")
				if page then
					target[page] = true
				end
			end
		end
	end
	local refs_map = {}
	local refs_ex = {}
	for tex in pairs(target) do
		local owners = idx[tex]
		if owners then
			for g2 in pairs(owners) do
				if g2 ~= gname then
					refs_map[g2] = (refs_map[g2] or 0) + 1
					if not refs_ex[g2] then
						refs_ex[g2] = {}
					end
					local s2 = (ex[tex] and ex[tex][g2]) or {}
					for _, f in ipairs(s2) do
						if #refs_ex[g2] < 3 then
							refs_ex[g2][#refs_ex[g2] + 1] = f
						end
					end
				end
			end
		end
	end
	local refs = {}
	for g2, n in pairs(refs_map) do
		refs[#refs + 1] = string.format("%s：%d 个共享纹理（%s …）", g2, n, table.concat(refs_ex[g2] or {}, ", "))
	end
	table.sort(refs)
	-- 同组内：保留帧的 alias 指向被剔除帧
	local same = {}
	if removed_set and g0 and g0.frames then
		for fn, v in pairs(g0.frames) do
			if not removed_set[fn] then
				for _, al in ipairs(v.alias or {}) do
					if removed_set[al] then
						same[#same + 1] = string.format("%s 的 alias 指向将移除的 %s", fn, al)
					end
				end
			end
		end
	end
	return refs, same
end

function atlas_manager:rpk_block_message(refs, same)
	if #refs == 0 and #same == 0 then
		return nil
	end
	local lines = {"以下图集引用了本图集将覆盖/删除的 DDS 纹理（a_name 指向 base/base-N dds），已阻止重打包："}
	for i = 1, math.min(6, #refs) do
		lines[#lines + 1] = "  · " .. refs[i]
	end
	if #refs > 6 then
		lines[#lines + 1] = string.format("  …等 %d 个图集", #refs)
	end
	for i = 1, math.min(3, #same) do
		lines[#lines + 1] = "  · " .. same[i]
	end
	return table.concat(lines, "\n")
end

local function rpk_fam_area(rp, g0, p)
	local a = 0
	for _, fn in ipairs(rp.fam[p]) do
		local f = g0.frames[fn]
		if f then
			a = a + f.f_quad[3] * f.f_quad[4]
		end
	end
	return a
end

-- 汇总各集：names 帧列表 + 面积（不含 unplaced）
function atlas_manager:rpk_recompute()
	local rp = state.repack
	if not rp then
		return
	end
	for i = 1, RPK_MAX_K do
		rp.outs[i].names = {}
		rp.outs[i].area = 0
	end
	local g0 = state.groups[rp.gname]
	for idx, p in ipairs(rp.famOrder) do
		if not (rp.unplaced and rp.unplaced[p]) then
			local t = rp.assign[p]
			if not t or t < 1 or t > rp.k then
				t = ((idx - 1) % rp.k) + 1
				rp.assign[p] = t
			end
			for _, fn in ipairs(rp.fam[p]) do
				rp.outs[t].names[#rp.outs[t].names + 1] = fn
			end
			rp.outs[t].area = rp.outs[t].area + rpk_fam_area(rp, g0, p)
		end
	end
	for i = 1, RPK_MAX_K do
		table.sort(rp.outs[i].names)
	end
end

function atlas_manager:rpk_open_size_menu(apply, abs_cx, abs_cy)
	if not ui.size_menu_dlg then
		return
	end
	ui.size_menu_apply = apply
	local mw, mh = ui.size_menu_dlg.size.x, ui.size_menu_dlg.size.y
	ui.size_menu_dlg.anchor = V.v(mw * 0.5, mh * 0.5)
	local vw, vh = self.ref_w, self.ref_h
	local cx = math.max(mw * 0.5 + 4, math.min(abs_cx, vw - mw * 0.5 - 4))
	local cy = math.min(abs_cy + 14, vh - mh * 0.5 - 4)
	ui.size_menu_dlg.pos = V.v(cx, cy)
	ui.size_menu_dlg.hidden = false
	ui.size_menu_dlg:order_to_front()
end

function atlas_manager:build_repack_dialog()
	if ui.repack_dialog then
		return
	end
	local rs = self._rs
	local dlg = KView:new(V.v(1020, 660))
	dlg.colors.background = {26, 20, 12, 246}
	dlg.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, 1020, 660, 12, 12}
	}
	dlg.anchor = V.v(510, 330)
	ui.repack_dialog = dlg
	ui.window:add_child(dlg)

	local function lab(parent, x, y, w, h, size, align)
		local l = GGLabel:new(V.v(w, h))
		l.font_name = "body"
		l.font_size = size * rs
		l.text_align = align or "left"
		l.vertical_align = "middle"
		l.colors.text = {223, 214, 190, 255}
		l.pos = V.v(x, y)
		parent:add_child(l)
		return l
	end
	local function button(parent, text, x, y, w, h, on_press)
		local b = self:make_button(text, V.v(w, h))
		b.pos = V.v(x, y)
		b.on_press = on_press
		parent:add_child(b)
		return b
	end

	-- 顶栏：标题在左，输出集数量增减在右上（避免与任何标题重叠）
	local t = lab(dlg, 16, 8, 320, 26, 15)
	t.colors.text = {244, 221, 165, 255}
	t.text = "图集重打包"
	local kk = lab(dlg, 660, 10, 76, 22, 12)
	kk.text_align = "right"
	kk.text = "输出集数"
	ui.rpk_lab_k = lab(dlg, 740, 10, 34, 22, 13)
	ui.rpk_lab_k.text_align = "center"
	button(dlg, "-", 778, 8, 28, 22, function()
		self:rpk_set_k(-1)
	end)
	button(dlg, "+", 810, 8, 28, 22, function()
		self:rpk_set_k(1)
	end)

	ui.rpk_lab_sel = lab(dlg, 16, 38, 560, 22, 12)

	-- 左：家族列表（分页容器）
	ui.rpk_fam_box = KView:new(V.v(620, RPK_PAGE_ROWS * 26 + 4))
	ui.rpk_fam_box.pos = V.v(16, 64)
	dlg:add_child(ui.rpk_fam_box)
	ui.rpk_lab_pg = lab(dlg, 16, 64 + RPK_PAGE_ROWS * 26 + 6, 220, 20, 11)
	button(dlg, "上一页", 300, 64 + RPK_PAGE_ROWS * 26 + 4, 60, 20, function()
		local rp = state.repack
		if rp and rp.fam_page > 1 then
			rp.fam_page = rp.fam_page - 1
			self:rpk_render()
		end
	end)
	button(dlg, "下一页", 366, 64 + RPK_PAGE_ROWS * 26 + 4, 60, 20, function()
		local rp = state.repack
		if rp then
			local pages = math.max(1, math.ceil(#rp.famOrder / RPK_PAGE_ROWS))
			if rp.fam_page < pages then
				rp.fam_page = rp.fam_page + 1
				self:rpk_render()
			end
		end
	end)

	-- 右：输出图集配置（标题在增减按钮下方，互不重叠）
	ui.rpk_lab_out_head = lab(dlg, 660, 38, 340, 22, 13, "left")
	ui.rpk_out_box = KView:new(V.v(360, RPK_MAX_K * 34 + 4))
	ui.rpk_out_box.pos = V.v(660, 64)
	dlg:add_child(ui.rpk_out_box)

	ui.rpk_lab_warn = lab(dlg, 16, 64 + RPK_PAGE_ROWS * 26 + 30, 620, 40, 11)
	ui.rpk_lab_warn.fit_lines = 2
	-- 状态/操作结果区（位于按钮行上方，避免与任何控件重叠）
	ui.rpk_lab_status = lab(dlg, 16, 470, 1000, 74, 12)
	ui.rpk_lab_status.fit_lines = 4

	button(dlg, "顺序填充", 16, 566, 96, 28, function()
		self:rpk_fill_sequential()
	end)
	button(dlg, "打包并暂存", 122, 566, 110, 28, function()
		self:rpk_stage()
	end)
	button(dlg, "确认替换", 242, 566, 110, 28, function()
		self:rpk_commit()
	end)
	button(dlg, "读取排除清单", 362, 566, 150, 28, function()
		self:rpk_apply_excludes_file()
	end)
	button(dlg, "关闭", 900, 566, 100, 28, function()
		ui.repack_dialog.hidden = true
	end)
	dlg.hidden = true
end

function atlas_manager:rpk_set_k(delta)
	local rp = state.repack
	if not rp then
		return
	end
	local k = math.max(1, math.min(RPK_MAX_K, rp.k + delta))
	if k == rp.k then
		return
	end
	rp.k = k
	for p, t in pairs(rp.assign) do
		if t > k then
			rp.assign[p] = nil
		end
	end
	self:rpk_recompute()
	self:rpk_render()
end

-- 顺序填充：从第1集开始，塞得进就塞；否则第2集、第3集……依次类推（放不下则驱逐腾位）
-- 读取项目根目录 .repack_exclude.txt（每行 prefix:start-end，支持 # 注释），
-- 取消 go_enemies_common 等当前组中对应帧的勾选，之后点「顺序填充」即可。
function atlas_manager:rpk_apply_excludes_file()
	local rp = state.repack
	if not rp then
		self:set_status("请先选中帧并打开「重打包」对话框")
		return
	end
	local path = project_root .. "/" .. IMAGES_DIR .. "/.repack_exclude.txt"
	local f = io.open(path, "rb")
	if not f then
		self:set_status("未找到 " .. path)
		return
	end
	local content = f:read("*all")
	f:close()
	local group = state.groups[rp.gname]
	if not group then
		return
	end
	local total_removed = 0
	local line_no = 0
	for line in content:gmatch("[^\r\n]+") do
		line_no = line_no + 1
		line = line:gsub("%s+", "")
		if line ~= "" and line:sub(1, 1) ~= "#" then
			local p, s, e = line:match("^([%w_]+):(%d+)%-(%d+)$")
			if p then
				s, e = tonumber(s), tonumber(e)
				local here = 0
				for fn in pairs(group.frames) do
					local fp, num = fn:match("^(.-)_(%d+)$")
					if fp == p and num then
						local n = tonumber(num)
						if n >= s and n <= e then
							state.selected_frames[rp.gname .. "." .. fn] = nil
							here = here + 1
						end
					end
				end
				total_removed = total_removed + here
			else
				print("[atlas_manager] exclude file 第 " .. line_no .. " 行无法解析: " .. line)
			end
		end
	end
	self:rebuild_tree()
	self:rpk_resync()
	self:set_status(string.format("已按排除清单取消勾选 %d 帧，点「顺序填充」继续", total_removed))
	print(string.format("[atlas_manager] apply excludes: removed %d frames", total_removed))
end

-- 按“当前树勾选”重新同步重打包数据：
-- 无论勾选是在打开对话框前还是之后调整，这里都以其为准重建族集合，
-- 保证被剔除的帧绝不会出现在输出；勾选变化时旧布局/旧暂存失效。
function atlas_manager:rpk_resync()
	local rp = state.repack
	if not rp then
		return false
	end
	local group = state.groups[rp.gname]
	if not group then
		self:set_status("源图集组已不存在")
		return false
	end
	local sel = self:get_selected_frame_list()
	local sel_set = {}
	for _, s in ipairs(sel) do
		if s.group == rp.gname and group.frames[s.frame_name] then
			sel_set[s.frame_name] = true
		end
	end
	local fam, order = rpk_build_families(sel_set)
	if #order == 0 then
		ui.rpk_lab_status.text = "当前没有任何勾选帧，请先在树上勾选本组帧。"
		self:set_status("没有可重打包的帧")
		return false
	end
	local removed = {}
	for _, fn in ipairs(group.frame_order) do
		if group.frames[fn] and not sel_set[fn] then
			removed[fn] = true
		end
	end
	local removed_count = 0
	for _ in pairs(removed) do
		removed_count = removed_count + 1
	end
	for p in pairs(rp.assign) do
		if not fam[p] then
			rp.assign[p] = nil
		end
	end
	local changed = (#rp.famOrder ~= #order)
	if not changed then
		for idx, p in ipairs(order) do
			if rp.famOrder[idx] ~= p then
				changed = true
				break
			end
		end
	end
	rp.fam = fam
	rp.famOrder = order
	rp.removed = removed
	rp.removed_count = removed_count
	rp.refs, rp.same = self:rpk_block_refs(removed, rp.gname)
	if changed then
		rp.unplaced = {}
		rp.fill_ok = false
		rp.fill_k = nil
		rp.fill_sizes = nil
		rp.fill_bins = nil
		rp.assign_fp = nil
		rp.outs_staged = nil
		rp.mfs = nil
		rp.stage = nil
	end
	self:rpk_recompute()
	self:rpk_render()
	if changed then
		ui.rpk_lab_status.text = "检测到勾选集合已变化，请重新点「顺序填充」。"
		self:set_status("勾选变化，需重新「顺序填充」")
	end
	return true
end

-- 顺序填充（性能版）：
--  1) 面积贪心粗分：族按面积降序，塞进第一个放得下的集（集中式）；
--  2) 每集只做一次真实打包；放不下就把“最小族”顺延到后续集，重试直到成功；
--  3) 最终布局(placements)存档，打包并暂存直接复用，不再二次打包。
function atlas_manager:rpk_fill_sequential()
	local rp = state.repack
	local t_fill = os.clock()
	if not rp then
		return
	end
	if not self:rpk_resync() then
		return
	end
	local g0 = state.groups[rp.gname]
	if not g0 then
		return
	end
	local items = {}
	for _, p in ipairs(rp.famOrder) do
		local area, mw, mh = 0, 0, 0
		for _, fn in ipairs(rp.fam[p]) do
			local f = g0.frames[fn]
			if f then
				area = area + f.f_quad[3] * f.f_quad[4]
				mw = math.max(mw, f.f_quad[3] or 0)
				mh = math.max(mh, f.f_quad[4] or 0)
			end
		end
		items[#items + 1] = {
			p = p,
			area = area,
			mw = mw,
			mh = mh
		}
	end
	table.sort(items, function(a, b)
		return a.area > b.area
	end)
	for p in pairs(rp.assign) do
		rp.assign[p] = nil
	end
	local function cap(i)
		return rp.outs[i].w * rp.outs[i].h
	end
	local function fam_area(p)
		local a = 0
		for _, fn in ipairs(rp.fam[p]) do
			local f = g0.frames[fn]
			if f then
				a = a + f.f_quad[3] * f.f_quad[4]
			end
		end
		return a
	end
	local function fams_of(i)
		local out = {}
		for _, p in ipairs(rp.famOrder) do
			if rp.assign[p] == i then
				out[#out + 1] = p
			end
		end
		return out
	end
	local function pack_output(i)
		local list = {}
		for _, p in ipairs(fams_of(i)) do
			for _, fn in ipairs(rp.fam[p]) do
				local f = g0.frames[fn]
				if f then
					list[#list + 1] = {
						w = f.f_quad[3],
						h = f.f_quad[4],
						frame_name = fn,
						group = rp.gname
					}
				end
			end
		end
		return atlas_binpack.pack(list, rp.outs[i].w, rp.outs[i].h)
	end
	local unplaced = {}
	-- 阶段1：面积贪心粗分
	local loads = {}
	for i = 1, rp.k do
		loads[i] = 0
	end
	for _, it in ipairs(items) do
		local placed = false
		for i = 1, rp.k do
			if it.mw <= rp.outs[i].w and it.mh <= rp.outs[i].h and loads[i] + it.area <= cap(i) then
				rp.assign[it.p] = i
				loads[i] = loads[i] + it.area
				placed = true
				break
			end
		end
		if not placed then
			local best = 0
			for i = 1, rp.k do
				if it.mw <= rp.outs[i].w and it.mh <= rp.outs[i].h then
					if best == 0 or cap(i) - loads[i] > cap(best) - loads[best] then
						best = i
					end
				end
			end
			if best > 0 then
				rp.assign[it.p] = best
				loads[best] = loads[best] + it.area
			else
				unplaced[it.p] = true
			end
		end
	end
	-- 阶段2：逐集真实打包，放不下就把最小族顺延到后续集
	for i = 1, rp.k do
		local guard = 0
		while true do
			local pl = pack_output(i)
			if pl then
				rp.outs[i].pl_final = pl
				break
			end
			local fams = fams_of(i)
			local min_p
			for _, p in ipairs(fams) do
				if not min_p or fam_area(p) < fam_area(min_p) then
					min_p = p
				end
			end
			if not min_p then
				rp.outs[i].pl_final = nil
				break
			end
			local moved = false
			for j = i + 1, rp.k do
				rp.assign[min_p] = j
				loads[i] = loads[i] - fam_area(min_p)
				loads[j] = loads[j] + fam_area(min_p)
				moved = true
				break
			end
			if not moved then
				unplaced[min_p] = true
				rp.assign[min_p] = nil
				break
			end
			guard = guard + 1
			if guard > 128 then
				break
			end
		end
	end
	-- 阶段3：记录填充结果
	rp.unplaced = unplaced
	rp.fill_bins = {}
	rp.fill_outs = {}
	for i = 1, rp.k do
		rp.fill_bins[i] = {}
		local pl = rp.outs[i].pl_final or {}
		for _, p in ipairs(pl) do
			rp.fill_bins[i][#rp.fill_bins[i] + 1] = p.frame_name
		end
		if #pl > 0 then
			rp.fill_outs[i] = {
				w = rp.outs[i].w,
				h = rp.outs[i].h,
				page = (rp.k == 1) and rp.base or (rp.base .. "-" .. i),
				pl = pl
			}
		end
	end
	self:rpk_recompute()
	rp.fill_ok = not next(unplaced)
	rp.fill_k = rp.k
	rp.fill_sizes = {}
	for i = 1, rp.k do
		rp.fill_sizes[i] = {rp.outs[i].w, rp.outs[i].h}
	end
	rp.assign_fp = {}
	for _, p in ipairs(rp.famOrder) do
		rp.assign_fp[#rp.assign_fp + 1] = rp.assign[p] or 0
	end
	self:rpk_render()
	if next(unplaced) then
		local names = {}
		for p in pairs(unplaced) do
			names[#names + 1] = p
		end
		table.sort(names)
		local ex = {}
		for j = 1, math.min(4, #names) do
			ex[#ex + 1] = names[j]
		end
		ui.rpk_lab_status.text = string.format("打包不下：族 %s 等 %d 个族放不进当前任何输出集。请加大某集尺寸或增加输出集数量，再点「顺序填充」。", table.concat(ex, "、"), #names)
		self:set_status(string.format("有 %d 个族放不下，暂不能打包", #names))
	else
		ui.rpk_lab_status.text = "打包得下：已从第1集起按序填满。可「打包并暂存」预览。"
		self:set_status("顺序填充完成，打包得下")
	end
end

function atlas_manager:rpk_render()
	local rp = state.repack
	if not rp or not ui.repack_dialog then
		return
	end
	local fam_count = 0
	for _, p in ipairs(rp.famOrder) do
		fam_count = fam_count + #rp.fam[p]
	end
	ui.rpk_lab_sel.text = string.format("组:%s   选中 %d 帧 / %d 族", rp.base, fam_count, #rp.famOrder)
	ui.rpk_lab_k.text = tostring(rp.k)

	-- 家族行（分页）
	ui.rpk_fam_box:remove_children()
	local pages = math.max(1, math.ceil(#rp.famOrder / RPK_PAGE_ROWS))
	if rp.fam_page > pages then
		rp.fam_page = pages
	end
	local start_i = (rp.fam_page - 1) * RPK_PAGE_ROWS + 1
	ui.rpk_lab_pg.text = string.format("页 %d/%d   族(帧数)  右侧按钮切换归属集", rp.fam_page, pages)
	for i = start_i, math.min(#rp.famOrder, start_i + RPK_PAGE_ROWS - 1) do
		local p = rp.famOrder[i]
		local row = KView:new(V.v(620, 24))
		row.pos = V.v(0, (i - start_i) * 26)
		ui.rpk_fam_box:add_child(row)
		local cannot = rp.unplaced and rp.unplaced[p]
		local l = GGLabel:new(V.v(430, 24))
		l.font_name = "body"
		l.font_size = 12 * self._rs
		l.text_align = "left"
		l.vertical_align = "middle"
		l.colors.text = cannot and {255, 150, 130, 255} or {205, 218, 248, 255}
		l.text = string.format("  %s（%d帧）%s", p, #rp.fam[p], cannot and "装不下" or "")
		row:add_child(l)
		local t = rp.assign[p] or 1
		local b = self:make_button(string.format("集%d/%d", t, rp.k), V.v(120, 22))
		b.pos = V.v(480, 1)
		b.on_press = function()
			local cur = rp.assign[p] or 1
			rp.assign[p] = (cur % rp.k) + 1
			if rp.unplaced then
				rp.unplaced[p] = nil
			end
			self:rpk_recompute()
			self:rpk_render()
		end
		row:add_child(b)
	end

	-- 输出集：只显示帧数与占用百分比；超容量才标红
	ui.rpk_out_box:remove_children()
	ui.rpk_lab_out_head.text = "输出图集（每集独立选择宽x高）"
	local dlg_abs_x = ui.repack_dialog.pos.x - ui.repack_dialog.anchor.x
	local dlg_abs_y = ui.repack_dialog.pos.y - ui.repack_dialog.anchor.y
	for i = 1, rp.k do
		local o = rp.outs[i]
		local y = (i - 1) * 34
		local hl = GGLabel:new(V.v(30, 24))
		hl.font_name = "body"
		hl.font_size = 12 * self._rs
		hl.text_align = "left"
		hl.vertical_align = "middle"
		hl.colors.text = {223, 214, 190, 255}
		hl.text = string.format("集%d", i)
		hl.pos = V.v(0, y)
		ui.rpk_out_box:add_child(hl)
		local function size_box(ax, value, axis)
			local box = KView:new(V.v(64, 22))
			box.pos = V.v(ax, y)
			box.colors.background = {22, 28, 42, 255}
			box.shape = {
				name = "rectangle",
				args = {"fill", 0, 0, 64, 22, 4, 4}
			}
			ui.rpk_out_box:add_child(box)
			local vl = GGLabel:new(V.v(46, 22))
			vl.font_name = "body"
			vl.font_size = 13 * self._rs
			vl.text_align = "center"
			vl.vertical_align = "middle"
			vl.colors.text = {255, 255, 255, 255}
			vl.text = tostring(value)
			box:add_child(vl)
			local ar = GGLabel:new(V.v(14, 22))
			ar.font_name = "body"
			ar.font_size = 11 * self._rs
			ar.text_align = "center"
			ar.vertical_align = "middle"
			ar.colors.text = {150, 162, 192, 255}
			ar.text = "▾"
			ar.pos = V.v(48, 0)
			box:add_child(ar)
			local abs_cx = dlg_abs_x + 660 + ax + 32
			local abs_cy = dlg_abs_y + 64 + y + 11
			box.on_click = function()
				self:rpk_open_size_menu(function(sz)
					if axis == "w" then
						o.w = sz
					else
						o.h = sz
					end
					self:rpk_render()
				end, abs_cx, abs_cy)
			end
			return vl
		end
		size_box(36, o.w, "w")
		local xl = GGLabel:new(V.v(12, 24))
		xl.font_name = "body"
		xl.font_size = 12 * self._rs
		xl.text_align = "center"
		xl.vertical_align = "middle"
		xl.colors.text = {205, 218, 248, 255}
		xl.text = "x"
		xl.pos = V.v(102, y)
		ui.rpk_out_box:add_child(xl)
		size_box(114, o.h, "h")
		local util = o.w * o.h > 0 and (o.area / (o.w * o.h) * 100) or 0
		local info = GGLabel:new(V.v(220, 24))
		info.font_name = "body"
		info.font_size = 11 * self._rs
		info.text_align = "left"
		info.vertical_align = "middle"
		info.colors.text = util > 100 and {255, 130, 110, 255} or {150, 200, 150, 255}
		info.text = string.format("%d帧 占%.0f%%", #o.names, util)
		if util > 100 then
			info.text = string.format("%d帧 超容量%.0f%%", #o.names, util - 100)
		end
		info.pos = V.v(184, y)
		ui.rpk_out_box:add_child(info)
	end

	local msg = self:rpk_block_message(rp.refs, rp.same)
	if msg then
		ui.rpk_lab_warn.colors.text = {255, 130, 120, 255}
		ui.rpk_lab_warn.text = msg
	elseif rp.removed_count and rp.removed_count > 0 then
		ui.rpk_lab_warn.colors.text = {235, 200, 120, 255}
		ui.rpk_lab_warn.text = string.format("注意：本组另有 %d 帧未勾选，替换后将随旧文件移入备份目录。", rp.removed_count)
	else
		ui.rpk_lab_warn.text = ""
	end
end

function atlas_manager:show_repack_dialog()
	local t_open = os.clock()
	if ui.close_size_menu then
		ui.close_size_menu()
	end
	local selected = self:get_selected_frame_list()
	if #selected == 0 then
		self:set_status("重打包：请先勾选帧（可用组上的「全选」整组勾选，再取消个别帧）")
		return
	end
	local gname = nil
	for _, s in ipairs(selected) do
		if gname and gname ~= s.group then
			self:set_status("重打包仅支持单个图集组内的帧；跨组合并请使用「合并」")
			return
		end
		gname = s.group
	end
	local group = state.groups[gname]
	if not group then
		self:set_status("找不到源图集组")
		return
	end
	local sel_set = {}
	for _, s in ipairs(selected) do
		sel_set[s.frame_name] = true
	end
	local removed = {}
	for _, fn in ipairs(group.frame_order) do
		if group.frames[fn] and not sel_set[fn] then
			removed[fn] = true
		end
	end
	local fam, order = rpk_build_families(sel_set)
	if #order == 0 then
		self:set_status("没有可重打包的帧")
		return
	end
	local refs, same = self:rpk_block_refs(removed, gname)
	local removed_count = 0
	for _ in pairs(removed) do
		removed_count = removed_count + 1
	end
	local rp = {
		gname = gname,
		base = group.name,
		removed = removed,
		removed_count = removed_count,
		fam = fam,
		famOrder = order,
		assign = {},
		unplaced = {},
		k = 1,
		outs = {},
		fam_page = 1,
		refs = refs,
		same = same,
		stage = nil
	}
	for i = 1, RPK_MAX_K do
		rp.outs[i] = {
			w = 2048,
			h = 2048,
			area = 0,
			names = {}
		}
	end
	state.repack = rp
	self:build_repack_dialog()
	-- 打开时不打包：默认全部帧先归第1集，尺寸/归属可自由调整，点「顺序填充」后真正分配
	for _, p in ipairs(order) do
		rp.assign[p] = 1
	end
	self:rpk_recompute()
	ui.repack_dialog.hidden = false
	ui.repack_dialog.anchor = V.v(510, 330)
	ui.repack_dialog.pos = V.v(self.ref_w / 2, self.ref_h / 2)
	ui.repack_dialog:order_to_front()
	ui.rpk_lab_status.text = "提示：先点「顺序填充」自动分配（从第1集起依次填满），或手动为每族选择归属集。"
	self:rpk_render()
end

function atlas_manager:rpk_stage()
	local rp = state.repack
	if not rp then
		return
	end
	local block_msg = self:rpk_block_message(rp.refs, rp.same)
	if block_msg then
		ui.rpk_lab_status.text = block_msg .. "\n请先在其它图集中解除引用，或勾选被引用的帧一起重打包。"
		self:set_status("重打包被阻止：有其它图集引用本图集帧")
		return
	end
	local group = state.groups[rp.gname]
	if not group then
		self:set_status("源图集组已不存在")
		return
	end
	-- 以当前勾选为准（打开前后调整都生效），剔除的帧绝不会进入输出
	if not self:rpk_resync() then
		return
	end

	-- 「顺序填充」负责布局判定；这里只把那次结果落盘。
	if not rp.fill_ok then
		ui.rpk_lab_status.text = "还没有可打包的结果：请先点「顺序填充」完成分配，再「打包并暂存」。"
		self:set_status("请先「顺序填充」")
		return
	end
	-- 填充后若尺寸/数量/归属被改过，旧布局不再有效，提示重新填充（不自动改布局）
	local stale = rp.fill_k ~= rp.k
	if not stale then
		for i = 1, rp.k do
			local fs = rp.fill_sizes and rp.fill_sizes[i]
			if not fs or fs[1] ~= rp.outs[i].w or fs[2] ~= rp.outs[i].h then
				stale = true
				break
			end
		end
	end
	if not stale and rp.assign_fp then
		local idx = 0
		for _, p in ipairs(rp.famOrder) do
			idx = idx + 1
			if (rp.assign[p] or 0) ~= (rp.assign_fp[idx] or 0) then
				stale = true
				break
			end
		end
	end
	if stale then
		ui.rpk_lab_status.text = "「顺序填充」之后尺寸/数量/归属被修改过，请重新点「顺序填充」，再「打包并暂存」。"
		self:set_status("布局已过期，请重新「顺序填充」")
		return
	end

	-- 直接复用「顺序填充」时已验证放得下的布局（fill_outs），不再二次打包
	if not rp.fill_outs then
		ui.rpk_lab_status.text = "没有可用的填充结果，请先点「顺序填充」。"
		self:set_status("请先「顺序填充」")
		return
	end
	local outs = {}
	local all_placements = {}
	for i = 1, rp.k do
		local fo = rp.fill_outs[i]
		if fo and #fo.pl > 0 then
			outs[#outs + 1] = {
				w = fo.w,
				h = fo.h,
				pl = fo.pl,
				page = fo.page
			}
			for _, p in ipairs(fo.pl) do
				all_placements[#all_placements + 1] = p
			end
		end
	end
	if #outs == 0 or #all_placements == 0 then
		self:set_status("没有可打包的内容，请先「顺序填充」")
		return
	end
	-- 输出守卫：所有进入输出的帧必须属于当前勾选集合，防止剔除帧混入
	do
		local allowed = {}
		for _, p in ipairs(rp.famOrder) do
			if not (rp.unplaced and rp.unplaced[p]) then
				for _, fn in ipairs(rp.fam[p]) do
					allowed[fn] = true
				end
			end
		end
		local bad = {}
		for _, p in ipairs(all_placements) do
			if not allowed[p.frame_name] then
				bad[#bad + 1] = p.frame_name
			end
		end
		if #bad > 0 then
			local ex = {}
			for j = 1, math.min(5, #bad) do
				ex[#ex + 1] = bad[j]
			end
			ui.rpk_lab_status.text = string.format("内部错误：发现 %d 个不属于勾选集合的帧（%s …），已中止，请重新「顺序填充」。", #bad, table.concat(ex, ", "))
			self:set_status("发现越界帧，打包已中止")
			print("[atlas_manager] repack guard: bad frames: " .. table.concat(bad, ", "))
			return
		end
	end

	local mfs = {}
	for _, p in ipairs(rp.famOrder) do
		if not (rp.unplaced and rp.unplaced[p]) then
			for _, fn in ipairs(rp.fam[p]) do
				local frame = group.frames[fn]
				if frame then
					mfs[fn] = self:_make_merge_frame({
						group = rp.gname,
						frame_name = fn,
						frame = frame
					})
				end
			end
		end
	end
	local ok, err2 = self:_load_frame_idatas(all_placements, mfs)
	if not ok then
		self:set_status("加载帧像素失败：" .. tostring(err2))
		return
	end
	local ts = tostring(os.time())
	local stage_dir = project_root .. "/" .. BACKUP_DIR .. "/_repack_stage_" .. ts
	os.execute("mkdir -p " .. stage_dir:gsub(" ", "\\ "))
	local failed = false
	for _, o in ipairs(outs) do
		local idata = atlas_util.create_merged_atlas(o.pl, mfs, o.w, o.h)
		local png_data = self:merged_idata_to_png(idata)
		local f = io.open(stage_dir .. "/" .. o.page .. ".png", "wb")
		if not f then
			failed = true
			break
		end
		f:write(png_data)
		f:close()
		print(string.format("[atlas_manager] repack_stage: %s.png (%dx%d)", o.page, o.w, o.h))
	end
	for _, mf in pairs(mfs) do
		mf._preview_idata = nil
	end
	if failed then
		self:set_status("写入暂存目录失败：" .. stage_dir)
		return
	end
	rp.mfs = mfs
	rp.outs_staged = outs
	rp.stage = {
		dir = stage_dir
	}
	ui.rpk_lab_status.text = string.format("已暂存 %d 个 PNG 到：%s\n检查布局无误后点「确认替换」开始正式替换。", #outs, stage_dir:gsub(project_root .. "/", ""))
	self:set_status("已打包并暂存，等待确认替换")
end

-- 可靠备份：把 base 相关旧文件（lua/luac/aluac、base.dds、base-N.dds、旧PNG）逐一
-- 用 io 直接拷贝到 .images_backup/<时间戳>_<base>/，并返回成功拷贝的文件清单。
function atlas_manager:rpk_backup_old(base)
	local back_dir = real_path(BACKUP_DIR)
	os.execute("mkdir -p " .. back_dir:gsub(" ", "\\ "))
	local bp = back_dir .. "/" .. tostring(os.time()) .. "_" .. base
	os.execute("mkdir -p " .. bp:gsub(" ", "\\ "))
	local atlas_real = real_path(ATLAS_DIR)
	local imgs_real = project_root .. "/" .. IMAGES_DIR
	local copied = {}
	local function copy_if_exists(src)
		local f = io.open(src, "rb")
		if not f then
			return false
		end
		local blob = f:read("*all")
		f:close()
		if not blob or #blob == 0 then
			return false
		end
		local name = src:match("([^/]+)$")
		local dst = io.open(bp .. "/" .. name, "wb")
		if not dst then
			return false
		end
		dst:write(blob)
		dst:close()
		copied[#copied + 1] = name
		return true
	end
	-- 资源目录：lua 三件套 + 单页 dds + 分页 dds
	for _, ext in ipairs({".lua", ".luac", ".aluac"}) do
		copy_if_exists(atlas_real .. "/" .. base .. ext)
	end
	copy_if_exists(atlas_real .. "/" .. base .. ".dds")
	local function scan_copy(dir, pattern)
		local h = io.popen('ls "' .. dir .. '" 2>/dev/null')
		if h then
			for name in h:lines() do
				if name:match(pattern) then
					copy_if_exists(dir .. "/" .. name)
				end
			end
			h:close()
		end
	end
	scan_copy(atlas_real, "^" .. base .. "%-%d+%.dds$")
	-- .images 里的旧 png
	scan_copy(imgs_real, "^" .. base .. "%.png$")
	scan_copy(imgs_real, "^" .. base .. "%-%d+%.png$")
	return {
		dir = bp,
		files = copied
	}
end

function atlas_manager:rpk_commit()
	local rp = state.repack
	if not rp or not rp.stage or not rp.outs_staged then
		self:set_status("请先「打包并暂存」")
		return
	end
	local block_msg = self:rpk_block_message(rp.refs, rp.same)
	if block_msg then
		ui.rpk_lab_status.text = block_msg .. "\n已阻止替换。"
		self:set_status("重打包被阻止：存在外部引用")
		return
	end
	local group = state.groups[rp.gname]
	if not group then
		self:set_status("源图集组已不存在")
		return
	end
	local base = rp.base
	local atlas_real = real_path(ATLAS_DIR)
	local imgs_real = project_root .. "/" .. IMAGES_DIR

	-- 1) 备份旧文件（io 直接拷贝，含 base.dds 与 base-N.dds 及旧PNG）
	local bp = self:rpk_backup_old(base)
	print(string.format("[atlas_manager] repack_backup: %s -> %s (%d 个文件)", base, bp.dir, #bp.files))
	local backed = {}
	for _, nm in ipairs(bp.files) do
		backed[nm] = true
	end
	local function in_backup(name)
		if backed[name] then
			return true
		end
		local f = io.open(bp.dir .. "/" .. name, "rb")
		if f then
			f:close()
			backed[name] = true
			return true
		end
		return false
	end

	-- 2) 组装新帧表（与合并/保存同一套 size/ref_scale 换算）
	local new_frames = {}
	for _, o in ipairs(rp.outs_staged) do
		for _, pl in ipairs(o.pl) do
			local mf = rp.mfs[pl.frame_name]
			if mf then
				local kx, ky = 1, 1
				if mf._orig_a_size and mf._orig_a_size[1] and mf.a_size and mf.a_size[1] > 0 then
					kx = mf.a_size[1] / mf._orig_a_size[1]
					ky = mf.a_size[2] / mf._orig_a_size[2]
				end
				local rs = (mf.ref_scale or 1) / kx
				new_frames[pl.frame_name] = {
					a_name = o.page .. ".dds",
					size = {math.floor(mf.size[1] * kx + 0.5), math.floor(mf.size[2] * ky + 0.5)},
					trim = {math.floor(mf.trim[1] * kx + 0.5), math.floor(mf.trim[2] * ky + 0.5), math.floor(mf.trim[3] * kx + 0.5), math.floor(mf.trim[4] * ky + 0.5)},
					a_size = {o.w, o.h},
					f_quad = {pl.x, pl.y, pl.w, pl.h},
					alias = type(mf.alias) == "table" and mf.alias or {},
					ref_scale = rs
				}
			end
		end
	end
	-- 3) 新 png 进 .images
	for _, o in ipairs(rp.outs_staged) do
		local f = io.open(rp.stage.dir .. "/" .. o.page .. ".png", "rb")
		if f then
			local blob = f:read("*all")
			f:close()
			write_real(imgs_real .. "/" .. o.page .. ".png", blob)
		end
	end
	-- 4) nvcompress 生成 dds
	for _, o in ipairs(rp.outs_staged) do
		local cmd = string.format("nvcompress.exe -bc3 -maximum %q %q", imgs_real .. "/" .. o.page .. ".png", atlas_real .. "/" .. o.page .. ".dds")
		print("[atlas_manager] " .. cmd)
		local okrun = os.execute(cmd)
		if not okrun then
			self:set_status("DDS 转换失败（" .. o.page .. "），旧文件已在 " .. bp.dir .. " 备份，可恢复")
			return
		end
	end
	-- 5) 写 lua/luac/aluac
	local okw, errw = atlas_util.write_atlas_files(atlas_real, base, new_frames, write_real)
	if not okw then
		self:set_status("写入 lua 失败：" .. tostring(errw) .. "（旧文件备份于 " .. bp.dir .. "）")
		return
	end
	-- 6) 清理不再使用的旧文件：先确保已进备份目录，再删除
	local keep = {}
	for _, o in ipairs(rp.outs_staged) do
		keep[o.page] = true
	end
	local leftover = {}
	-- 兜底：若旧文件此前没进备份，先补拷进备份目录（能读就能删）
	local function ensure_backed(name, dir)
		if in_backup(name) then
			return true
		end
		local f = io.open(dir .. "/" .. name, "rb")
		if not f then
			return false
		end
		local blob = f:read("*all")
		f:close()
		if not blob or #blob == 0 then
			return false
		end
		local dst = io.open(bp.dir .. "/" .. name, "wb")
		if not dst then
			return false
		end
		dst:write(blob)
		dst:close()
		backed[name] = true
		return true
	end
	local function sweep(dir, pattern)
		local h = io.popen('ls "' .. dir .. '" 2>/dev/null')
		if h then
			local deleted = 0
			for name in h:lines() do
				if name ~= base .. ".lua" and name ~= base .. ".luac" and name ~= base .. ".aluac" then
					-- 注意：name 带扩展名（如 go_x-3.dds），取页名前缀时要含扩展名匹配
					local page = name:match("^(" .. base .. "%-%d+)%.[%w]+$")
					if page and not keep[page] and name:match(pattern) then
						if ensure_backed(name, dir) then
							local okdel, delerr = os.remove(dir .. "/" .. name)
							if okdel then
								deleted = deleted + 1
								print("[atlas_manager] repack cleanup: removed " .. name)
							else
								leftover[#leftover + 1] = name .. "(删除失败:" .. tostring(delerr) .. ")"
							end
						else
							leftover[#leftover + 1] = name .. "(备份失败，已保留)"
						end
					end
				end
			end
			h:close()
			print(string.format("[atlas_manager] repack cleanup: %s 扫描删除 %d 个", dir:match("([^/]+)$"), deleted))
		end
	end
	-- 仅处理资源目录/PNG 存档中旧分页文件（三件套与单页由新文件覆盖，无需清理）
	sweep(atlas_real, "^" .. base .. "%-%d+%.(dds|astc|lua|luac|aluac)$")
	sweep(imgs_real, "^" .. base .. "%-%d+%.png$")
	-- 7) 清理暂存目录
	os.execute("rm -rf " .. rp.stage.dir:gsub(" ", "\\ "))
	self:refresh_groups()
	ui.repack_dialog.hidden = true
	if #leftover > 0 then
		self:set_status(string.format("重打包完成：%s -> %d 个图集（备份于 %s）。注意残留：%s", base, #rp.outs_staged, bp.dir, table.concat(leftover, "；")))
		print(string.format("[atlas_manager] repack leftover: %s", table.concat(leftover, "; ")))
	else
		self:set_status(string.format("重打包完成：%s -> %d 个图集（旧文件备份于 %s）", base, #rp.outs_staged, bp.dir))
	end
	print(string.format("[atlas_manager] repack done: %s -> %d pages", base, #rp.outs_staged))
end

return atlas_manager
