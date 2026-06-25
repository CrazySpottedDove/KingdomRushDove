local log = require("lib.klua.log"):new("screen_custom_map")
local class = require("middleclass")
local SU = require("screen_utils")
local V = require("lib.klua.vector")
local v = V.v
local persistence = require("lib.klua.persistence")
local FS = love.filesystem

require("klove.kui")
require("gg_views_custom")

local screen = {}
screen.ref_h = 1080
screen.ref_w = 1920
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd
screen.required_textures = {}
screen.plugin_required_textures = {}
screen.plugin_required_sounds = {}

local PLUGINS_DIR = "game_editor/plugins"
local SAVE_FILE = "custom_slot.lua"
local PANEL_MARGIN = 36
local ROW_H = 156
local ROW_GAP = 12
local ACCENT_W = 6

local C = {
	window_bg = {22, 18, 12, 255},
	panel_bg = {72, 56, 26, 210},
	panel_border = {153, 119, 48, 200},
	list_bg = {28, 20, 12, 200},
	row_bg = {26, 18, 12, 220},
	row_hover = {40, 28, 16, 235},
	title = {241, 222, 171, 255},
	meta = {190, 173, 128, 255},
	desc = {160, 146, 114, 255},
	status = {238, 208, 120, 255},
	accent = {207, 164, 72, 255},
	accent_done = {70, 190, 92, 255},
	action_bg = {52, 140, 75, 255},
	action_bg_hover = {68, 164, 92, 255},
	action_text = {255, 255, 255, 255},
	mode_bg = {95, 73, 32, 255},
	mode_bg_hover = {122, 92, 38, 255}
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

local function scan_maps()
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
			local supported = true
			if type(cfg) == "table" and type(cfg.game_version) == "table" and #cfg.game_version > 0 then
				supported = false
				for _, game_version in ipairs(cfg.game_version) do
					if game_version == KR_GAME then
						supported = true
						break
					end
				end
			end
			if supported and type(cfg) == "table" then
				local level_name = cfg.level_name or string.format("level%02d", tonumber(cfg.level_idx) or 1)
				local level_idx = tonumber(cfg.level_idx) or tonumber(level_name:match("level(%d+)")) or 1
				local wave_root = base .. "/data/waves/"
				local has_campaign = FS.getInfo(wave_root .. level_name .. "_waves_campaign.lua") ~= nil
				if has_campaign then
					maps[#maps + 1] = {
						entry = entry,
						base = base,
						cfg = cfg,
						level_name = level_name,
						level_idx = level_idx,
						has_heroic = FS.getInfo(wave_root .. level_name .. "_waves_heroic.lua") ~= nil,
						has_iron = FS.getInfo(wave_root .. level_name .. "_waves_iron.lua") ~= nil
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

local MapActionButton = class("MapActionButton", KButton)

function MapActionButton:initialize(text, size, style)
	KButton.initialize(self, size or v(140, 40))
	self.text = safe_text(text)
	self.text_align = "center"
	self.vertical_align = "middle"
	self.font_size = 18
	self.font_name = "body"
	self.colors.background = style == "mode" and C.mode_bg or C.action_bg
	self.colors.text = C.action_text
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, self.size.x, self.size.y, 10, 10}
	}
	self._style = style
end

function MapActionButton:on_enter()
	self.colors.background = self._style == "mode" and C.mode_bg_hover or C.action_bg_hover
end

function MapActionButton:on_exit()
	self.colors.background = self._style == "mode" and C.mode_bg or C.action_bg
end

local MapCardRow = class("MapCardRow", KView)

function MapCardRow:initialize(map, progress, row_w, on_play)
	KView.initialize(self, v(row_w, ROW_H))
	self.map = map
	self.on_play = on_play
	self._base_bg = C.row_bg
	self._hover_bg = C.row_hover
	self.colors.background = self._base_bg
	self.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, row_w, ROW_H, 14, 14}
	}

	local accent = KView:new(v(ACCENT_W, ROW_H))
	accent.colors.background = (progress and (progress.heroic or progress.iron or tonumber(progress.stars) or 0) > 0) and C.accent_done or C.accent
	self:add_child(accent)

	local rs = GGLabel.static.ref_h / REF_H
	local right_pad = 26
	local action_w = 138
	local action_h = 40
	local action_x = row_w - right_pad - action_w
	local text_w = math.max(320, action_x - (ACCENT_W + 24) - 24)
	local modes = {"战役"}
	if map.has_heroic then
		modes[#modes + 1] = "英雄"
	end
	if map.has_iron then
		modes[#modes + 1] = "钢铁"
	end

	local title = GGLabel:new(v(text_w, 30))
	title.font_name = "h"
	title.font_size = 16 * rs
	title.text_align = "left"
	title.vertical_align = "middle"
	title.colors.text = C.title
	title.fit_lines = 1
	title.fit_size = true
	title.text = safe_text(map.cfg.name, map.entry)
	title.pos = v(ACCENT_W + 18, 10)
	self:add_child(title)

	local meta = GGLabel:new(v(text_w, 22))
	meta.font_name = "body"
	meta.font_size = 12.5 * rs
	meta.text_align = "left"
	meta.vertical_align = "middle"
	meta.colors.text = C.meta
	meta.fit_lines = 1
	meta.fit_size = true
	meta.text = string.format("本地版本 v%s  作者: %s  星星: %d", safe_text(map.cfg.version, "1.0"), safe_text(map.cfg.by, "匿名"), tonumber(progress and progress.stars) or 0)
	meta.pos = v(ACCENT_W + 18, 40)
	self:add_child(meta)

	local desc = GGLabel:new(v(text_w, 62))
	desc.font_name = "body"
	desc.font_size = 12 * rs
	desc.text_align = "left"
	desc.vertical_align = "top"
	desc.colors.text = C.desc
	desc.fit_lines = 3
	desc.fit_size = true
	desc.line_height = 1.2
	desc.text = safe_text(map.cfg.desc, "无简介")
	desc.pos = v(ACCENT_W + 18, 68)
	self:add_child(desc)

	local status = GGLabel:new(v(260, 24))
	status.font_name = "body"
	status.font_size = 12 * rs
	status.text_align = "right"
	status.vertical_align = "middle"
	status.colors.text = C.status
	status.fit_lines = 1
	status.fit_size = true
	status.text = string.format("模式：%s", table.concat(modes, " / "))
	status.pos = v(row_w - right_pad - 260, 10)
	self:add_child(status)

	local done = GGLabel:new(v(260, 22))
	done.font_name = "body"
	done.font_size = 11.5 * rs
	done.text_align = "right"
	done.vertical_align = "middle"
	done.colors.text = C.meta
	done.fit_lines = 1
	done.fit_size = true
	done.text = string.format("完成：英雄[%s]  钢铁[%s]", progress and progress.heroic and "√" or " ", progress and progress.iron and "√" or " ")
	done.pos = v(row_w - right_pad - 260, 36)
	self:add_child(done)

	local play_btn = MapActionButton:new("游玩", v(action_w, action_h))
	play_btn.pos = v(action_x, ROW_H - action_h - 18)
	function play_btn.on_click()
		if self.on_play then
			self.on_play(map)
		end
	end
	self:add_child(play_btn)
end

function MapCardRow:on_enter()
	self.colors.background = self._hover_bg
end

function MapCardRow:on_exit()
	self.colors.background = self._base_bg
end

function screen:init(w, h, done_callback)
	self.done_callback = done_callback
	self.progress = load_progress()
	self.maps = scan_maps()
	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	self.sw, self.sh = sw, sh

	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	local window = KWindow:new(v(sw, sh))
	window.scale = v(scale, scale)
	window.origin = origin
	window.colors.background = C.window_bg
	self.window = window

	local back = KView:new(v(sw - PANEL_MARGIN * 2, sh - PANEL_MARGIN * 2))
	back.pos = v(PANEL_MARGIN, PANEL_MARGIN)
	back.colors.background = C.panel_bg
	back.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, back.size.x, back.size.y, 18, 18}
	}
	window:add_child(back)
	self.back = back

	local header = KView:new(v(back.size.x - 40, 126))
	header.pos = v(20, 18)
	header.colors.background = {48, 34, 18, 210}
	header.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, header.size.x, header.size.y, 14, 14}
	}
	back:add_child(header)

	local title = GGLabel:new(v(header.size.x - 280, 44))
	title.pos = v(220, 12)
	title.text = "自定义地图"
	title.font_name = "h"
	title.font_size = 28
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = C.title
	header:add_child(title)

	local hint = GGLabel:new(v(header.size.x - 280, 28))
	hint.pos = v(220, 58)
	hint.text = "来自插件目录 game_editor/plugins，自动识别战役 / 英雄 / 钢铁模式"
	hint.font_name = "body"
	hint.font_size = 13
	hint.text_align = "center"
	hint.vertical_align = "middle"
	hint.colors.text = C.meta
	hint.fit_lines = 1
	hint.fit_size = true
	header:add_child(hint)

	local back_btn = MapActionButton:new("返回", v(152, 44), "mode")
	back_btn.pos = v(18, 22)
	function back_btn.on_click()
		self.done_callback({
			next_item_name = "map"
		})
	end
	header:add_child(back_btn)

	local list_h = back.size.y - 180
	self.mod_list = KScrollList:new(v(back.size.x - 40, list_h))
	self.mod_list.pos = v(20, 162)
	self.mod_list.drag_scroll_threshold = IS_ANDROID and 20 or 6
	self.mod_list.scroll_amount = ROW_H
	self.mod_list.colors.background = C.list_bg
	self.mod_list.colors.scroller_background = {78, 58, 28, 180}
	self.mod_list.colors.scroller_foreground = {165, 130, 62, 255}
	self.mod_list.scroller_width = 20
	self.mod_list.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, self.mod_list.size.x, self.mod_list.size.y, 14, 14}
	}
	back:add_child(self.mod_list)

	self:rebuild_cards()
end

function screen:rebuild_cards()
	self.mod_list:clear_rows()

	local list_w = self.mod_list.size.x - self.mod_list.scroller_width - 2 * self.mod_list.scroller_margin - 4
	local progress = self.progress.maps or {}

	if #self.maps == 0 then
		local empty = GGLabel:new(v(list_w, 80))
		empty.font_name = "body"
		empty.font_size = 16
		empty.text_align = "center"
		empty.vertical_align = "middle"
		empty.colors.text = C.meta
		empty.text = "未发现可游玩的地图插件（需存在 campaign 出怪文件）"
		self.mod_list:add_row(empty)
		return
	end

	for _, map in ipairs(self.maps) do
		local row = MapCardRow:new(map, progress[map.entry] or {}, list_w, function(selected)
			self:show_mode_select(selected)
		end)
		self.mod_list:add_row(row)
		self.mod_list:add_row(KView:new(v(list_w, ROW_GAP)))
	end
end

function screen:show_mode_select(map)
	if self.mode_popup then
		self.window:remove_child(self.mode_popup)
	end

	local pw, ph = 480, 280
	local panel = KView:new(v(pw, ph))
	panel.anchor = v(pw * 0.5, ph * 0.5)
	panel.pos = v(self.sw * 0.5, self.sh * 0.5)
	panel.colors.background = {46, 32, 18, 248}
	panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, pw, ph, 16, 16}
	}
	self.window:add_child(panel)
	self.mode_popup = panel

	local title = GGLabel:new(v(pw - 40, 40))
	title.text = "选择模式 - " .. safe_text(map.cfg.name, map.entry)
	title.text_align = "center"
	title.vertical_align = "middle"
	title.font_name = "h"
	title.font_size = 18
	title.colors.text = C.title
	title.pos = v(20, 18)
	panel:add_child(title)

	local buttons = {{
		text = "战役",
		mode = GAME_MODE_CAMPAIGN
	}}

	if map.has_heroic then
		buttons[#buttons + 1] = {
			text = "英雄",
			mode = GAME_MODE_HEROIC
		}
	end
	if map.has_iron then
		buttons[#buttons + 1] = {
			text = "钢铁",
			mode = GAME_MODE_IRON
		}
	end

	local start_y = 76
	for i, item in ipairs(buttons) do
		local btn = MapActionButton:new(item.text, v(190, 38), "mode")
		btn.pos = v((pw - btn.size.x) * 0.5, start_y + (i - 1) * 48)
		function btn.on_click()
			self:start_custom_game(map, item.mode)
		end
		panel:add_child(btn)
	end

	local close_btn = MapActionButton:new("取消", v(120, 34), "mode")
	close_btn.pos = v((pw - close_btn.size.x) * 0.5, ph - 52)
	function close_btn.on_click()
		panel.hidden = true
	end
	panel:add_child(close_btn)
end

function screen:start_custom_game(map, mode)
	self.done_callback({
		next_item_name = "game",
		level_idx = map.level_idx,
		level_mode = mode,
		level_difficulty = DIFFICULTY_NORMAL,
		custom_map_entry = map.entry,
		custom_map_level_name = map.level_name,
		custom_map_root = map.base,
		custom_map_return_to = "custom_map",
		custom_map_bg_image = map.cfg.background_image and (map.base .. "/" .. map.cfg.background_image) or nil,
		custom_map_bg_sprite = map.cfg.background_sprite,
		custom_map_battle_music = map.cfg.battle_music and (map.base .. "/" .. map.cfg.battle_music) or nil,
		custom_map_battle_prep_music = map.cfg.battle_prep_music and (map.base .. "/" .. map.cfg.battle_prep_music) or nil
	})
end

function screen:update(dt)
	self.window:update(dt)
	return true
end

function screen:draw()
	self.window:draw()
end

function screen:keypressed(key, isrepeat)
	self.window:keypressed(key, isrepeat)
	if key == "escape" then
		self.done_callback({
			next_item_name = "map"
		})
	end
end

function screen:keyreleased(key)
	self.window:keyreleased(key)
end

function screen:textinput(t)
	self.window:textinput(t)
end

function screen:mousepressed(x, y, button)
	self.window:mousepressed(x, y, button)
end

function screen:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function screen:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
end

function screen:destroy()
	if self.window then
		self.window:destroy()
	end
	self.window = nil
end

return screen
