local log = require("lib.klua.log"):new("screen_custom_map")
local class = require("middleclass")
local V = require("lib.klua.vector")
local v = V.v
local persistence = require("lib.klua.persistence")
local FS = love.filesystem
local S = require("sound_db")
local km = require("lib.klua.macros")
local GS = require("kr1.game_settings")
local utf8 = require("utf8")

require("klove.kui")
require("gg_views_custom")

local PLUGINS_DIR = "plugins"
local SAVE_FILE = "custom_slot.lua"
local CARD_W = 260
local CARD_H = 340
local GAP = 24
local PAGINATION_H = 60

local C = {
	bg = {22, 18, 12, 255},
	panel_bg = {72, 56, 26, 210},
	panel_border = {153, 119, 48, 200},
	card_bg = {26, 18, 12, 220},
	card_hover = {45, 32, 18, 240},
	card_border = {153, 119, 48, 200},
	card_border_hover = {220, 180, 80, 255},
	title = {241, 222, 171, 255},
	meta = {190, 173, 128, 255},
	desc = {160, 146, 114, 255},
	status = {238, 208, 120, 255},
	accent = {207, 164, 72, 255},
	accent_done = {70, 190, 92, 255},
	btn_bg = {52, 140, 75, 255},
	btn_bg_hover = {68, 164, 92, 255},
	btn_bg_down = {40, 110, 60, 255},
	btn_text = {255, 255, 255, 255},
	nav_bg = {48, 34, 18, 210},
	nav_btn_bg = {95, 73, 32, 255},
	nav_btn_hover = {122, 92, 38, 255},
	popup_bg = {46, 32, 18, 248},
	disabled = {88, 88, 88, 200},
	thumb_border = {120, 90, 40, 200},
	thumb_placeholder = {40, 30, 18, 220}
}

local function safe_text(v, fallback)
	if v == nil or v == "" then
		return fallback or ""
	end
	return tostring(v)
end

local function load_lua_file(path)
	local ok_load, f_or_err = pcall(FS.load, path)
	if not ok_load or not f_or_err then
		return nil, f_or_err
	end
	local f = f_or_err
	if type(f) ~= "function" then
		return nil, "invalid lua chunk"
	end
	local ok, data = pcall(f)
	if not ok then
		local content = FS.read(path)
		if type(content) == "string" and content ~= "" then
			local wrapped = loadstring("return " .. content, "@" .. path .. "(wrapped)")
			if wrapped then
				local ok2, data2 = pcall(wrapped)
				if ok2 and type(data2) == "table" then
					return data2
				end
			end
		end
		return nil, data
	end
	return data
end

local function save_progress(data)
	local out = "return " .. persistence.serialize_to_string(data) .. "\n"
	local ok = FS.write(SAVE_FILE, out)
	if not ok then
		log.error("failed to save custom progress: %s", SAVE_FILE)
	end
end

local function load_progress()
	local data = load_lua_file(SAVE_FILE)
	if type(data) ~= "table" then
		return {
			maps = {}
		}
	end
	data.maps = data.maps or {}
	return data
end

local function scan_maps(out_thumbnails)
	local maps = {}
	local ok, entries = pcall(FS.getDirectoryItems, PLUGINS_DIR)
	if not ok or not entries then
		return maps
	end

	for _, entry in ipairs(entries) do
		local base = PLUGINS_DIR .. "/" .. entry
		local info = FS.getInfo(base)
		if info and info.type == "directory" then
			local cfg = load_lua_file(base .. "/config.lua")
			if type(cfg) == "table" and cfg.type == "level" then
				local wave_root = base .. "/data/waves/"
				local has_campaign = FS.getInfo(wave_root .. entry .. "_waves_campaign.lua") ~= nil
				if has_campaign then
					local level_data = load_lua_file(base .. "/data/levels/" .. entry .. "_data.lua")
					local thumbnail_view
					if type(level_data) == "table" then
						if level_data.thumbnail_sprite then
							thumbnail_view = KImageView:new(level_data.thumbnail_sprite)
						elseif level_data.thumbnail then
							local path = base .. "/" .. level_data.thumbnail
							local ok_img, img = pcall(love.graphics.newImage, path)
							if ok_img and img then
								local sprite_name = "custom_thumb_" .. entry
								I:add_image(sprite_name, img, "game_editor")
								if out_thumbnails then
									out_thumbnails[#out_thumbnails + 1] = sprite_name
								end
								thumbnail_view = KImageView:new(sprite_name)
							end
						end
					end

					maps[#maps + 1] = {
						entry = entry,
						base = base,
						cfg = cfg,
						level_data = level_data,
						thumbnail_view = thumbnail_view,
						has_heroic = FS.getInfo(wave_root .. entry .. "_waves_heroic.lua") ~= nil,
						has_iron = FS.getInfo(wave_root .. entry .. "_waves_iron.lua") ~= nil
					}
				end
			end
		end
	end

	table.sort(maps, function(a, b)
		return (a.cfg.name or a.entry) < (b.cfg.name or b.entry)
	end)
	return maps
end

-- ── Simple Text Button with hover/click feedback ──

local CustomMapTextButton = class("CustomMapTextButton", KView)

function CustomMapTextButton:initialize(size, text, font_size)
	KView.initialize(self, size)
	self.colors.background = C.btn_bg
	self._default_bg = C.btn_bg
	self._hover_bg = C.btn_bg_hover
	self._down_bg = C.btn_bg_down
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, size.x, size.y, 8, 8}
	}
	self.propagate_on_click = false

	local label = GGLabel:new(V.v(size.x - 12, size.y))
	label.pos = v(6, 0)
	label.font_name = "body"
	label.font_size = font_size or 15
	label.text_align = "center"
	label.vertical_align = "middle"
	label.colors.text = C.btn_text
	label.fit_lines = 1
	label.fit_size = true
	label.text = safe_text(text)
	label.propagate_on_click = true
	self:add_child(label)
	self._label = label
end

function CustomMapTextButton:set_text(text)
	self._label.text = safe_text(text)
end

function CustomMapTextButton:on_enter()
	self.colors.background = self._hover_bg
end

function CustomMapTextButton:on_exit()
	self.colors.background = self._default_bg
end

function CustomMapTextButton:on_down(button, x, y)
	self.colors.background = self._down_bg
end

function CustomMapTextButton:on_up(button, x, y)
	self.colors.background = self._hover_bg
end

function CustomMapTextButton:set_disabled(disabled)
	if disabled then
		self.colors.background = C.disabled
		self._label.colors.text = {120, 120, 120, 255}
		self.propagate_on_click = false
		self.propagate_on_down = false
		self.propagate_on_up = false
		self._disabled = true
	else
		self.colors.background = self._default_bg
		self._label.colors.text = C.btn_text
		self.propagate_on_click = false
		self.propagate_on_down = false
		self.propagate_on_up = false
		self._disabled = false
	end
end

-- ── Card View ──

local CustomMapCard = class("CustomMapCard", KView)

function CustomMapCard:initialize(map, card_w, card_h, on_select)
	KView.initialize(self, v(card_w, card_h))
	self.map = map
	self._on_select = on_select
	self.colors.background = C.card_bg
	self._default_bg = C.card_bg
	self._hover_bg = C.card_hover
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, card_w, card_h, 12, 12}
	}
	self.propagate_on_click = true

	local border_v = KView:new(v(card_w, card_h))
	border_v.colors.background = C.card_border
	border_v.shape = {
		name = "rectangle",
		args = {"line", 0, 0, card_w, card_h, 12, 12}
	}
	border_v.propagate_on_click = true
	border_v.propagate_on_down = true
	border_v.propagate_on_up = true
	self:add_child(border_v)
	self._border = border_v

	local thumb_area_h = card_h * 0.55
	local thumb_margin = 12
	local thumb_w = card_w - thumb_margin * 2
	local thumb_h = thumb_area_h - thumb_margin * 2

	local thumb = map.thumbnail_view
	if thumb then
		thumb.pos = v(thumb_margin, thumb_margin)
		local scale_x = thumb_w / thumb.size.x
		local scale_y = thumb_h / thumb.size.y
		local s = math.min(scale_x, scale_y)
		thumb.scale = v(s, s)
		thumb.propagate_on_click = true
		thumb.propagate_on_down = true
		thumb.propagate_on_up = true
		self:add_child(thumb)
	else
		local placeholder = KView:new(v(thumb_w, thumb_h))
		placeholder.pos = v(thumb_margin, thumb_margin)
		placeholder.colors.background = C.thumb_placeholder
		placeholder.shape = {
			name = "rectangle",
			args = {"fill", 0, 0, thumb_w, thumb_h, 8, 8}
		}
		placeholder.propagate_on_click = true
		placeholder.propagate_on_down = true
		placeholder.propagate_on_up = true
		self:add_child(placeholder)

		local ph_label = GGLabel:new(v(thumb_w, thumb_h))
		ph_label.font_name = "body"
		ph_label.font_size = 13
		ph_label.text_align = "center"
		ph_label.vertical_align = "middle"
		ph_label.colors.text = C.meta
		ph_label.text = "No Thumbnail"
		ph_label.propagate_on_click = true
		ph_label.propagate_on_down = true
		ph_label.propagate_on_up = true
		self:add_child(ph_label)
	end

	local info_y = thumb_area_h + 8
	local info_h = card_h - info_y - 8
	local label_w = card_w - 16

	local name_label = GGLabel:new(v(label_w, 24))
	name_label.pos = v(8, info_y)
	name_label.font_name = "h"
	name_label.font_size = 15
	name_label.text_align = "left"
	name_label.vertical_align = "middle"
	name_label.colors.text = C.title
	name_label.fit_lines = 1
	name_label.fit_size = true
	name_label.text = safe_text(map.cfg.name, map.entry)
	name_label.propagate_on_click = true
	name_label.propagate_on_down = true
	name_label.propagate_on_up = true
	self:add_child(name_label)

	local author_label = GGLabel:new(v(label_w, 18))
	author_label.pos = v(8, info_y + 26)
	author_label.font_name = "body"
	author_label.font_size = 11
	author_label.text_align = "left"
	author_label.vertical_align = "middle"
	author_label.colors.text = C.meta
	author_label.fit_lines = 1
	author_label.fit_size = true
	author_label.text = safe_text(map.cfg.by, "Anonymous")
	author_label.propagate_on_click = true
	author_label.propagate_on_down = true
	author_label.propagate_on_up = true
	self:add_child(author_label)

	local btn_w = label_w * 0.6
	local btn_h = 30
	local btn = CustomMapTextButton:new(v(btn_w, btn_h), "Select", 14)
	btn.pos = v((card_w - btn_w) * 0.5, card_h - btn_h - 10)
	function btn.on_click()
		if self._on_select then
			self._on_select(self.map)
		end
	end
	self:add_child(btn)
	self._select_btn = btn
end

function CustomMapCard:on_enter()
	self.colors.background = self._hover_bg
	self._border.colors.background = C.card_border_hover
end

function CustomMapCard:on_exit()
	self.colors.background = self._default_bg
	self._border.colors.background = C.card_border
end

-- ── Pagination ──

local CustomMapPagination = class("CustomMapPagination", KView)

function CustomMapPagination:initialize(size, total_pages, on_page_change)
	KView.initialize(self, size)
	self._total_pages = total_pages
	self._current_page = 1
	self._on_page_change = on_page_change

	local btn_w = 40
	local btn_h = 80

	self._prev_btn = CustomMapTextButton:new(v(btn_w, btn_h), "◀", 18)
	self._prev_btn.pos = v(4, (size.y - btn_h) * 0.5)
	function self._prev_btn.on_click()
		if self._current_page > 1 then
			self._current_page = self._current_page - 1
			self:update_display()
			if self._on_page_change then
				self._on_page_change(self._current_page)
			end
		end
	end
	self:add_child(self._prev_btn)

	self._next_btn = CustomMapTextButton:new(v(btn_w, btn_h), "▶", 18)
	self._next_btn.pos = v(size.x - btn_w - 4, (size.y - btn_h) * 0.5)
	function self._next_btn.on_click()
		if self._current_page < self._total_pages then
			self._current_page = self._current_page + 1
			self:update_display()
			if self._on_page_change then
				self._on_page_change(self._current_page)
			end
		end
	end
	self:add_child(self._next_btn)

	self:update_display()
end

function CustomMapPagination:update_display()
end

function CustomMapPagination:update_pages(new_total)
	self._total_pages = new_total
	if self._current_page > self._total_pages then
		self._current_page = math.max(self._total_pages, 1)
	end
	self:update_display()
	if self._on_page_change then
		self._on_page_change(self._current_page)
	end
end

-- ── Level Select Popup (exact copy of LevelSelectView) ──

local ls_page_l_x = 214
local ls_page_r_x = 690
local ls_page_w = 360
local ls_page_y = 104

local function add_level_title(parent, text, style, y)
	local px, pm, py, fs, lines
	py = y or ls_page_y
	if style == "left" then
		px = ls_page_l_x
		pm = ls_page_l_x + ls_page_w / 2
		fs = 36
		lines = 2
		text = string.gsub(text, "-", " ")
	elseif style == "right" then
		px = ls_page_r_x
		pm = ls_page_r_x + ls_page_w / 2
		fs = 32
		lines = 1
	elseif style == "sub" then
		px = ls_page_r_x
		pm = ls_page_r_x + ls_page_w / 2
		fs = 26
		lines = 1
	end

	local title = GGLabel:new(V.v(ls_page_w - 120, lines * 40))
	title.pos = v(px + 60, py)
	title.anchor.y = title.size.y / 2
	title.font_name = "h_book"
	title.font_size = fs
	title.font_align = "center"
	title.vertical_align = "middle"
	title.colors.text = style == "sub" and {142, 131, 91, 255} or {100, 89, 52, 255}
	title.text = text
	title.line_height = 0.9
	title.fit_lines = lines
	title:do_fit_lines()
	parent:add_child(title)

	local _, wrn, wr = title:get_wrap_lines()
	local title_w = 0
	for i = 1, wrn do
		title_w = math.max(title_w, title:get_text_width(wr[i]))
	end

	local dn = "levelSelect_volutas_0001"
	local d = KImageView:new(dn)
	d.pos = v(pm - title_w / 2 - 8, py + 3)
	d.anchor = v(0, d.size.y / 2)
	d.scale.x = -1
	d.alpha = style == "sub" and 0.5 or 1
	parent:add_child(d)

	d = KImageView:new(dn)
	d.pos = v(pm + title_w / 2 + 10, py + 3)
	d.anchor = v(0, d.size.y / 2)
	d.alpha = style == "sub" and 0.5 or 1
	parent:add_child(d)
end

local function add_level_description(parent, text)
	local LEFT_MARGIN = ls_page_r_x + 10
	local TEXT_TOP_POS = ls_page_y + 50
	local bg = KImageView:new("levelSelect_capitular_bg")
	bg.pos = v(LEFT_MARGIN - 10, TEXT_TOP_POS - 30)
	parent:add_child(bg)

	local p = string.sub(text, utf8.offset(text, 2))
	local first_letter_label = GGLabel:new(V.v(bg.size.x, bg.size.y))
	first_letter_label.pos = v(bg.pos.x - 4, bg.pos.y)
	first_letter_label.font_name = "capitals"
	first_letter_label.font_size = 64
	first_letter_label.colors.text = {247, 234, 186}
	first_letter_label.text_align = "center"
	first_letter_label.vertical_align = "bottom"
	first_letter_label.text = string.sub(text, 1, utf8.offset(text, 2) - 1)
	parent:add_child(first_letter_label)

	local desc = GGLabel:new(V.v(ls_page_w - 10, 200))
	desc.pos = v(LEFT_MARGIN, TEXT_TOP_POS)
	desc.font_name = "body"
	desc.font_size = 17.5
	desc.text_align = "left"
	desc.vertical_align = "top"
	desc.colors.text = {60, 50, 30, 255}
	desc.fit_lines = 8
	desc.line_height = 0.85
	desc.text = text or ""
	parent:add_child(desc)
end

local function add_difficulty_stamp(parent, diff, x, y)
	if diff then
		local im = KImageView:new("levelSelect_difficultyCompleted_000" .. diff)
		im.pos = v(x, y)
		parent:add_child(im)
	end
end

local CustomLevelSelectDifficultyButton = class("CustomLevelSelectDifficultyButton", KImageButton)

function CustomLevelSelectDifficultyButton:initialize()
	KImageButton.initialize(self, "levelSelect_difficulty_0001")
	self._difficulty = DIFFICULTY_NORMAL
	self:set_difficulty(self._difficulty)
end

function CustomLevelSelectDifficultyButton:set_difficulty(diff)
	local fmt = "levelSelect_difficulty_000%i"
	local img_n = string.format(fmt, 2 * diff - 1)
	local img_h = string.format(fmt, 2 * diff)
	self.default_image_name = img_n
	self.hover_image_name = img_h
	self.click_image_name = img_h
	self:set_image(self.default_image_name)
	self._difficulty = diff
end

function CustomLevelSelectDifficultyButton:get_difficulty()
	return self._difficulty
end

function CustomLevelSelectDifficultyButton:cycle_difficulty()
	local diff = self._difficulty
	diff = km.zmod(diff + 1, GS.max_difficulty)
	self:set_difficulty(diff)
	self:set_image(self.hover_image_name)
end

local function add_level_battle_button(parent, mode, on_click)
	local sh = {"p_bands", "p_outline", "p_glow"}
	local sha = {{
		margin = 0,
		p1 = 0,
		p2 = 0.4,
		c1 = {0.95, 0.78, 0.60, 1},
		c2 = {0.95, 0.78, 0.60, 1},
		c3 = {0.69, 0.54, 0.39, 1}
	}, {
		thickness = 2.5,
		outline_color = {0.37, 0.02, 0.05, 1}
	}, {
		thickness = 1.6,
		glow_color = {0, 0, 0, 0.6}
	}}
	local sha_hover = {{
		margin = 0,
		p1 = 0,
		p2 = 0.4,
		c1 = {1, 1, 1, 1},
		c2 = {1, 1, 1, 1},
		c3 = {1, 1, 0.69, 1}
	}, {
		thickness = 2.5,
		outline_color = {0.81, 0.14, 0.09, 1}
	}, {
		thickness = 1.6,
		glow_color = {0.69, 0.54, 0.39, 0.6}
	}}

	local prefix = "levelSelect_startMode_notxt_000%i"
	local nu, nh = string.format(prefix, 2 * mode - 1), string.format(prefix, 2 * mode)
	local b = KImageButton:new(nu, nh, nh)
	b.pos = v(805, 470)
	parent:add_child(b)

	function b.on_click()
		S:queue("GUIButtonCommon")
		on_click()
	end

	function b.on_enter(this)
		this.class.on_enter(this)
		this.t1.shader_args = sha_hover
		this.t2.shader_args = sha_hover
		this.t1:redraw()
		this.t2:redraw()
	end

	function b.on_exit(this)
		this.class.on_exit(this)
		this.t1.shader_args = sha
		this.t2.shader_args = sha
		this.t1:redraw()
		this.t2:redraw()
	end

	local t = GGShaderLabel:new(V.v(b.size.x, 20))
	t.pos.y = 70
	t.font_size = 15
	t.font_name = "h_noti"
	t.text_align = "center"
	t.text = _("BUTTON_TO_BATTLE_1")
	t.colors.text = {255, 255, 255, 255}
	t.shaders = sh
	t.shader_args = sha
	t.propagate_on_click = true
	b:add_child(t)
	b.t1 = t

	t = GGShaderLabel:new(V.v(b.size.x, 30))
	t.pos.y = 86
	t.font_size = 22
	t.font_name = "h_noti"
	t.text_align = "center"
	t.text = _("BUTTON_TO_BATTLE_2")
	t.colors.text = {255, 255, 255, 255}
	t.shaders = sh
	t.shader_args = sha
	t.propagate_on_click = true
	b:add_child(t)
	b.t2 = t
end

local function add_level_tab(parent, mode, y, available, on_click)
	local x = 1105
	local fmt = "levelSelect_Mode_notxt_00%02i"
	local indexes = {
		[GAME_MODE_CAMPAIGN] = {nil, 1, 2, 3},
		[GAME_MODE_HEROIC] = {4, 5, 6, 7},
		[GAME_MODE_IRON] = {8, 9, 10, 11}
	}
	local texts = {_("Campaign"), _("Heroic"), _("Iron")}
	local i_l, i_n, i_h, i_s = unpack(indexes[mode])

	if not parent._tabs then
		parent._tabs = {}
	end
	if not parent._tabs_selected then
		parent._tabs_selected = {}
	end
	if not parent._tabs_locked then
		parent._tabs_locked = {}
	end

	if not available then
		local t = KImageView:new(string.format(fmt, i_l))
		t.pos = v(x, y)
		t.alpha = 0.5
		parent.back:add_child(t)
		parent._tabs_locked[mode] = t
		return
	end

	local oy = (mode ~= GAME_MODE_CAMPAIGN and -2 or 0)
	local lx, ly = 40, 56
	local lx_sel = 53

	-- Normal (unselected) tab
	local l = GGLabel:new(V.v(68, 10))
	l.anchor = v(l.size.x / 2, l.size.y / 2)
	l.font_name = "body"
	l.font_size = 13
	l.font_align = "center"
	l.pos = v(lx, ly + oy)
	l.colors.text = {198, 134, 95, 255}
	l.text = texts[mode]
	l.fit_lines = 1
	l.propagate_on_click = true

	local t = KImageButton:new(string.format(fmt, i_n), string.format(fmt, i_h))
	t.pos = v(x, y)
	t:add_child(l)

	function t.on_click(this)
		S:queue("GUIButtonCommon")
		on_click()
	end

	parent.back:add_child(t)
	parent._tabs[mode] = t

	-- Selected tab
	local s = KImageView:new(string.format(fmt, i_s))
	s.pos = v(x, y)

	local ls = GGLabel:new(V.v(68, 10))
	ls.anchor = v(ls.size.x / 2, ls.size.y / 2)
	ls.font_name = "body"
	ls.font_size = 13
	ls.font_align = "center"
	ls.pos = v(lx_sel, ly + oy + 2)
	ls.colors.text = {255, 255, 255, 255}
	ls.text = texts[mode]
	ls.fit_lines = 1

	s:add_child(ls)
	parent.back:add_child(s)
	parent._tabs_selected[mode] = s
end

local CustomLevelSelectView = class("CustomLevelSelectView", PopUpView)

function CustomLevelSelectView:initialize(sw, sh, map, on_start)
	PopUpView.initialize(self, v(sw, sh))
	self._map = map
	self._on_start = on_start
	self._selected_mode = GAME_MODE_CAMPAIGN

	self.back = KImageView:new("levelSelect_background")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2 - 15, sh / 2 - 50)
	self:add_child(self.back)
	self.back.alpha = 0

	if IS_ANDROID then
		local scale = math.min(sw / self.back.size.x, sh / self.back.size.y) * 0.85
		self.scale = v(scale, scale)
		self.pos = v(sw * (1 - scale) / 2, sh * (1 - scale) / 2)
	end

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 50, 30)
	self.close_button = close_button

	self.back:add_child(close_button)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	add_level_title(self.back, map.cfg.name or map.entry, "left", ls_page_y + 22)

	-- Badges
	local badge_x = 310
	local badge_x_off = 35
	local badge_y = 490
	local badge_fmt = "levelSelect_badges_000%i"

	for i = 1, 5 do
		local n
		if i == 5 then
			n = 6
		elseif i == 4 then
			n = 4
		else
			n = 2
		end
		local bn = string.format(badge_fmt, n)
		local b = KImageView:new(bn)
		b.scale = v(0.8, 0.8)
		b.pos = v(badge_x, badge_y)
		badge_x = badge_x + badge_x_off
		self.back:add_child(b)
	end

	local thumb = map.thumbnail_view
	if thumb then
		thumb.pos = v(215, 190)
		self.back:add_child(thumb)
	end

	local thumb_frame = KImageView:new("levelSelect_thumbFrame")
	thumb_frame.pos = v(202, 175)
	self.back:add_child(thumb_frame)

	-- Campaign page
	self.campaign = KView:new()
	self.back:add_child(self.campaign)
	add_level_title(self.campaign, _("Campaign"), "right")
	add_level_description(self.campaign, map.cfg.desc)
	add_difficulty_stamp(self.campaign, 1, 690, 520)

	local diff_btn = CustomLevelSelectDifficultyButton:new()
	diff_btn.pos = v(982, 522)
	self.campaign:add_child(diff_btn)
	function diff_btn.on_click()
		S:queue("GUIButtonCommon")
		diff_btn:cycle_difficulty()
	end
	self._diff_btn = diff_btn

	add_level_battle_button(self.campaign, GAME_MODE_CAMPAIGN, function()
		self:start_game()
	end)

	-- Heroic page
	local rules_y = 290

	self.heroic = KView:new()
	self.back:add_child(self.heroic)
	self.heroic.hidden = true
	if map.has_heroic then
		local rbg = KImageView:new("levelSelect_modebg_notxt_0001")
		rbg.pos = v(ls_page_r_x + (ls_page_w - rbg.size.x) / 2, rules_y + 20)
		self.heroic:add_child(rbg)
		add_level_title(self.heroic, _("Heroic"), "right")
		add_level_description(self.heroic, _("LEVEL_MODE_HEROIC_DESCRIPTION"))
		add_level_title(self.heroic, _("Challenge Rules"), "sub", rules_y)
		add_difficulty_stamp(self.heroic, 1, 690, 520)

		local diff_btn_h = CustomLevelSelectDifficultyButton:new()
		diff_btn_h.pos = v(982, 522)
		self.heroic:add_child(diff_btn_h)
		function diff_btn_h.on_click()
			S:queue("GUIButtonCommon")
			diff_btn_h:cycle_difficulty()
		end

		add_level_battle_button(self.heroic, GAME_MODE_HEROIC, function()
			self._selected_mode = GAME_MODE_HEROIC
			self._diff_btn = diff_btn_h
			self:start_game()
		end)
	end

	-- Iron page
	self.iron = KView:new()
	self.back:add_child(self.iron)
	self.iron.hidden = true
	if map.has_iron then
		local rbg = KImageView:new("levelSelect_modebg_notxt_0001")
		rbg.pos = v(ls_page_r_x + (ls_page_w - rbg.size.x) / 2, rules_y + 20)
		self.iron:add_child(rbg)

		local rbbg = KImageView:new("levelSelect_modebg_notxt_0002")
		rbbg.pos = v(ls_page_r_x + (ls_page_w - rbbg.size.x) / 2, rules_y + 90)
		self.iron:add_child(rbbg)
		add_level_title(self.iron, _("Iron"), "right")
		add_level_description(self.iron, _("LEVEL_MODE_IRON_DESCRIPTION"))
		add_level_title(self.iron, _("Challenge Rules"), "sub", rules_y)
		add_difficulty_stamp(self.iron, 1, 690, 520)

		local diff_btn_i = CustomLevelSelectDifficultyButton:new()
		diff_btn_i.pos = v(982, 522)
		self.iron:add_child(diff_btn_i)
		function diff_btn_i.on_click()
			S:queue("GUIButtonCommon")
			diff_btn_i:cycle_difficulty()
		end

		add_level_battle_button(self.iron, GAME_MODE_IRON, function()
			self._selected_mode = GAME_MODE_IRON
			self._diff_btn = diff_btn_i
			self:start_game()
		end)
	end

	-- Tabs
	local tab_ys = {
		[GAME_MODE_CAMPAIGN] = 175,
		[GAME_MODE_HEROIC] = 260,
		[GAME_MODE_IRON] = 345
	}
	for _, m in ipairs({GAME_MODE_CAMPAIGN, GAME_MODE_HEROIC, GAME_MODE_IRON}) do
		local available = (m == GAME_MODE_CAMPAIGN) or (m == GAME_MODE_HEROIC and map.has_heroic) or (m == GAME_MODE_IRON and map.has_iron)
		add_level_tab(self, m, tab_ys[m], available, function()
			self._selected_mode = m
			self:show_page(m)
		end)
	end
	self:show_page(GAME_MODE_CAMPAIGN)
end

function CustomLevelSelectView:show_page(mode)
	self.campaign.hidden = mode ~= GAME_MODE_CAMPAIGN
	self.heroic.hidden = mode ~= GAME_MODE_HEROIC
	self.iron.hidden = mode ~= GAME_MODE_IRON

	for _, m in pairs({GAME_MODE_CAMPAIGN, GAME_MODE_HEROIC, GAME_MODE_IRON}) do
		if self._tabs[m] then
			self._tabs[m].hidden = mode == m
		end
		if self._tabs_selected[m] then
			self._tabs_selected[m].hidden = mode ~= m
		end
	end
end

function CustomLevelSelectView:start_game()
	if not self._on_start then
		return
	end

	local map = self._map
	local mode = self._selected_mode
	local level_data = type(map.level_data) == "table" and map.level_data or {}
	local bg_image = level_data.background_image and (map.base .. "/" .. level_data.background_image) or nil
	local bg_sprite = level_data.background_sprite
	local battle_music = level_data.battle_music and (map.base .. "/" .. level_data.battle_music) or nil
	local battle_prep_music = level_data.battle_prep_music and (map.base .. "/" .. level_data.battle_prep_music) or nil

	local difficulty = self._diff_btn and self._diff_btn:get_difficulty() or DIFFICULTY_NORMAL

	self._on_start({
		next_item_name = "game",
		level_mode = mode,
		level_difficulty = difficulty,
		custom_map_entry = map.entry,
		custom_map_level_name = map.entry,
		custom_map_root = map.base,
		custom_map_return_to = "map",
		custom_map_bg_image = bg_image,
		custom_map_bg_sprite = bg_sprite,
		custom_map_battle_music = battle_music,
		custom_map_battle_prep_music = battle_prep_music
	})
end

-- ── Screen Lifecycle ──

-- ── CustomMapListView: card grid + pagination, embeddable in any KWindow ──

local CustomMapListView = class("CustomMapListView", KView)

function CustomMapListView:initialize(size, maps, on_select)
	KView.initialize(self, size)
	self.propagate_on_click = true
	self._maps = maps
	self._on_select = on_select

	local total_maps = #maps
	local cols = math.max(1, math.floor((size.x + GAP) / (CARD_W + GAP)))
	local rows = math.max(1, math.floor((size.y + GAP) / (CARD_H + GAP)))
	local cards_per_page = cols * rows
	local total_pages = math.max(1, math.ceil(total_maps / cards_per_page))

	self._cols = cols
	self._rows = rows
	self._cards_per_page = cards_per_page
	self._current_page = 1

	local page_view = KView:new(v(size.x, size.y))
	page_view.pos = v(0, 0)
	page_view.propagate_on_click = true
	self:add_child(page_view)
	self._page_view = page_view

	local nav = CustomMapPagination:new(v(size.x, size.y), total_pages, function(page)
		self:show_page(page)
	end)
	nav.propagate_on_click = true
	self:add_child(nav)
	self._nav = nav

	self:show_page(1)
end

function CustomMapListView:show_page(page)
	self._current_page = page
	local start_idx = (page - 1) * self._cards_per_page + 1
	local end_idx = math.min(start_idx + self._cards_per_page - 1, #self._maps)
	local page_maps = {}
	for i = start_idx, end_idx do
		page_maps[#page_maps + 1] = self._maps[i]
	end

	local children = self._page_view.children
	if children then
		for i = #children, 1, -1 do
			self._page_view:remove_child(children[i])
		end
	end

	if #page_maps == 0 then
		local empty = GGLabel:new(V.v(self._page_view.size.x - 40, 60))
		empty.pos = v(20, self._page_view.size.y * 0.4)
		empty.font_name = "body"
		empty.font_size = 17
		empty.text_align = "center"
		empty.vertical_align = "middle"
		empty.colors.text = C.meta
		empty.text = "No custom maps found.\nPlace level-type plugins in the plugins/ directory."
		self._page_view:add_child(empty)
		return
	end

	local total_w = self._cols * (CARD_W + GAP) - GAP
	local start_x = (self._page_view.size.x - total_w) * 0.5
	local start_y = (self._page_view.size.y - self._rows * (CARD_H + GAP) + GAP) * 0.5

	for i, map in ipairs(page_maps) do
		local col = (i - 1) % self._cols
		local row = math.floor((i - 1) / self._cols)
		local x = start_x + col * (CARD_W + GAP)
		local y = start_y + row * (CARD_H + GAP)
		local card = CustomMapCard:new(map, CARD_W, CARD_H, function(m)
			if self._on_select then
				self._on_select(m)
			end
		end)
		card.pos = v(x, y)
		self._page_view:add_child(card)
	end
end

return {
	-- Constants
	PLUGINS_DIR = PLUGINS_DIR,
	SAVE_FILE = SAVE_FILE,
	CARD_W = CARD_W,
	CARD_H = CARD_H,
	GAP = GAP,
	PAGINATION_H = PAGINATION_H,
	C = C,

	-- Utilities
	safe_text = safe_text,
	load_lua_file = load_lua_file,
	save_progress = save_progress,
	load_progress = load_progress,
	scan_maps = scan_maps,

	-- View classes
	CustomMapTextButton = CustomMapTextButton,
	CustomMapCard = CustomMapCard,
	CustomMapPagination = CustomMapPagination,
	CustomMapListView = CustomMapListView,
	CustomLevelSelectView = CustomLevelSelectView,
	CustomLevelSelectDifficultyButton = CustomLevelSelectDifficultyButton,

	-- Layout helpers
	add_level_title = add_level_title,
	add_level_description = add_level_description,
	add_difficulty_stamp = add_difficulty_stamp,
	add_level_battle_button = add_level_battle_button,
	add_level_tab = add_level_tab,
	ls_page_l_x = ls_page_l_x,
	ls_page_r_x = ls_page_r_x,
	ls_page_w = ls_page_w,
	ls_page_y = ls_page_y
}
