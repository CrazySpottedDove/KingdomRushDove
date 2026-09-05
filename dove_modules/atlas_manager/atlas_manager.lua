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

local state = {
	groups = {},
	group_order = {},
	expanded = {},
	selected_frames = {},
	frame_checks = {},
	file_checks = {},
	sort_area_desc = true,
	non_pow2_mode = false,
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
		self:set_status(g and string.format("append 已同步: %d 张", #g.frame_order) or "append 无小图")
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
	local function make_size_input(x, initial)
		local inp = KView:new(V.v(64, 22))
		inp.pos = V.v(x, control_y)
		inp.colors.background = {22, 28, 42, 255}
		inp.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, 64, 22, 4, 4}
		}
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
		local sz = p[3]
		local btn = make_size_btn(p[1], p[2])
		btn.on_press = function()
			state.merge_w = sz
			state.merge_h = sz
			ui.merge_w_text.text = tostring(sz)
			ui.merge_h_text.text = tostring(sz)
		end
	end
	-- non-power-of-2 mode checkbox
	do
		local cb = KView:new(V.v(130, 20))
		cb.pos = V.v(880, control_y + 1)
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
	local total = bw * 6 + gap * 5
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
	for _, fn in ipairs(items) do
		if fn:sub(-4) == ".png" then
			local base = fn:sub(1, -5)
			local full_rel = append_dir .. "/" .. fn
			local trim_data, img_w, img_h = self:_compute_png_trim(full_rel)
			if trim_data then
				local crop_w = img_w - trim_data[1] - trim_data[3]
				local crop_h = img_h - trim_data[2] - trim_data[4]
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
					_src_path = full_rel
				}
				frame_order[#frame_order + 1] = base
			end
		end
	end
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
		ref_scale = (logical and logical.ref_scale) or (src.ref_scale or 1),
		dds_key = src.dds_key,
		_is_loose = src._is_loose,
		_src_path = src._src_path,
		_merge_group = sel.group
	}
end

function atlas_manager:do_merge()
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
			self:set_status("打包失败: " .. err)
			return
		end
	end
	local all_frames = {}
	for _, sel in ipairs(selected) do
		all_frames[sel.frame_name] = self:_make_merge_frame(sel)
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
	self._split_ready = nil
	local util = self:_calc_utilization()
	print(string.format("[atlas_manager] merge: %d frames into %dx%d, pack=ok, util=%.1f%%", #placements, w, h, util))
	self:set_status(string.format("合并完成: %d帧打包到 %dx%d 图集 (%.1f%%)", #placements, w, h, util))
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
	for dds_key, info in pairs(need_load) do
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
			print(string.format("[atlas_manager] load: %s (%dx%d)", dds_key, tw, th))
		end
	end
	if total_loads == 0 and next(need_load) then
		return nil, "无法加载纹理用于预览 (文件不存在?)"
	end
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
				if info and info.texture then
					frame._preview_idata = atlas_util.extract_frame_pixels(info.texture, frame.f_quad, info.tex_w, info.tex_h)
				end
			end
		end
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
	-- 深拷贝帧数据，避免污染源 group；size/trim/ref_scale 用原始 .lua 逻辑值
	local all_frames = {}
	for _, sel in ipairs(selected) do
		all_frames[sel.frame_name] = self:_make_merge_frame(sel)
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
		self:set_status(string.format("选中帧 %d 帧，未超过 %d 无需拆分（已打包为单页）", #selected, max_size))
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
	self:set_status(string.format("已拆分为 %d 页，PNG已写入 .images (%s-1.png ...)", #page_entries, merge_name))
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
		local backup_real_dir = real_path(BACKUP_DIR)
		local bp = atlas_util.backup_files(atlas_real_dir, name, backup_real_dir, read_fs, write_real)
		print(string.format("[atlas_manager] save_backup: %s -> %s", name, bp))
		local ok, err = atlas_util.write_atlas_files(atlas_real_dir, name, new_frames, write_real)
		if not ok then
			return self:set_status("写入文件失败: " .. (err or "unknown"))
		end
		print(string.format("[atlas_manager] save_compile: %s .lua/.luac/.aluac written", name))
		self._pending_dds_commands = dds_commands
		self:set_status(string.format("已保存 %s.", name))
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

return atlas_manager
