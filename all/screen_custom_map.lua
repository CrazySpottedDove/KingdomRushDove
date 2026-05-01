local log = require("lib.klua.log"):new("screen_custom_map")
local SU = require("screen_utils")
local V = require("lib.klua.vector")
local v = V.v
local persistence = require("lib.klua.persistence")
local FS = love.filesystem

require("klove.kui")

local screen = {}
screen.ref_h = 1080
screen.ref_w = 1920
screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd
screen.required_textures = {}

local PLUGINS_DIR = "game_editor/plugins"
local SAVE_FILE = "custom_slot.lua"

local function load_lua_file(path)
	local f, err = FS.load(path)
	if not f then
		return nil, err
	end
	local ok, data = pcall(f)
	if not ok then
		return nil, data
	end
	return data
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

local function save_progress(data)
	local out = persistence.serialize_to_string(data)
	FS.write(SAVE_FILE, out)
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
			if type(cfg) == "table" then
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

function screen:init(w, h, done_callback)
	self.done_callback = done_callback
	self.progress = load_progress()
	self.maps = scan_maps()
	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	self.sw, self.sh = sw, sh
	self._scroll = 0

	local window = KWindow:new(v(sw, sh))
	window.scale = v(scale, scale)
	window.origin = origin
	window.colors.background = {12, 16, 26, 255}
	self.window = window

	local header = KView:new(v(sw - 80, 84))
	header.pos = v(40, 18)
	header.colors.background = {18, 24, 38, 235}
	window:add_child(header)

	local title = KLabel:new(v(sw - 280, 56))
	title.pos = v(140, 10)
	title.text = "自定义地图"
	title.text_align = "left"
	title.vertical_align = "middle"
	title.font_size = 28
	title.colors.text = {242, 228, 188, 255}
	header:add_child(title)

	local hint = KLabel:new(v(sw - 280, 22))
	hint.pos = v(140, 52)
	hint.text = "来自插件目录 game_editor/plugins，支持战役/英雄/钢铁模式自动识别"
	hint.text_align = "left"
	hint.vertical_align = "middle"
	hint.font_size = 13
	hint.colors.text = {178, 192, 216, 255}
	header:add_child(hint)

	local back_btn = KButton:new(v(160, 36))
	back_btn.pos = v(16, 24)
	back_btn.text = "返回"
	back_btn.colors.background = {52, 66, 94, 255}
	back_btn.colors.text = {230, 230, 230, 255}
	function back_btn.on_click()
		self.done_callback({
			next_item_name = "map"
		})
	end
	header:add_child(back_btn)

	local list_view = KView:new(v(sw - 80, sh - 140))
	list_view.pos = v(40, 112)
	list_view.clip = true
	list_view.colors.background = {16, 22, 34, 225}
	window:add_child(list_view)
	self.list_view = list_view

	self.list_content = KView:new(v(list_view.size.x, 0))
	list_view:add_child(self.list_content)
	self:rebuild_cards()
end

function screen:rebuild_cards()
	self.list_content:remove_children()
	local card_w = self.list_view.size.x - 24
	local card_h = 150
	local y = 12
	local progress = self.progress.maps or {}

	if #self.maps == 0 then
		local empty = KLabel:new(v(card_w, 60))
		empty.pos = v(12, y + 40)
		empty.text = "未发现可游玩的地图插件（需存在 campaign 出怪文件）"
		empty.text_align = "center"
		empty.vertical_align = "middle"
		empty.colors.text = {210, 210, 210, 255}
		self.list_content:add_child(empty)
		self.list_content.size = v(self.list_view.size.x, y + 120)
		return
	end

	for _, map in ipairs(self.maps) do
		local card = KView:new(v(card_w, card_h))
		card.pos = v(12, y)
		card.colors.background = {28, 36, 54, 255}
		local base_y = y
		function card.on_enter(this)
			this.pos = v(this.pos.x, base_y - 2)
			this.colors.background = {42, 56, 84, 255}
		end
		function card.on_exit(this)
			this.pos = v(this.pos.x, base_y)
			this.colors.background = {28, 36, 54, 255}
		end

		local accent = KView:new(v(6, card_h))
		accent.colors.background = {194, 148, 48, 255}
		card:add_child(accent)

		local p = progress[map.entry] or {}
		local name = KLabel:new(v(card_w - 260, 30))
		name.pos = v(24, 10)
		name.text = map.cfg.name or map.entry
		name.colors.text = {242, 228, 188, 255}
		name.font_size = 22
		name.vertical_align = "middle"
		card:add_child(name)

		local meta = KLabel:new(v(card_w - 260, 24))
		meta.pos = v(24, 44)
		meta.text = string.format("作者: %s   版本: %s   星星: %d", map.cfg.by or "匿名", map.cfg.version or "1.0", tonumber(p.stars) or 0)
		meta.colors.text = {210, 210, 210, 255}
		meta.font_size = 14
		meta.vertical_align = "middle"
		card:add_child(meta)

		local desc = KLabel:new(v(card_w - 260, 52))
		desc.pos = v(24, 72)
		desc.text = map.cfg.desc or "无简介"
		desc.colors.text = {185, 196, 220, 255}
		desc.font_size = 13
		desc.line_height = 1.2
		card:add_child(desc)

		local mode_badge = KLabel:new(v(170, 26))
		mode_badge.pos = v(card_w - 340, 14)
		mode_badge.text = string.format("模式: 战役%s%s", map.has_heroic and " / 英雄" or "", map.has_iron and " / 钢铁" or "")
		mode_badge.text_align = "right"
		mode_badge.vertical_align = "middle"
		mode_badge.font_size = 12
		mode_badge.colors.text = {182, 198, 226, 255}
		card:add_child(mode_badge)

		local done_badge = KLabel:new(v(170, 22))
		done_badge.pos = v(card_w - 340, 40)
		done_badge.text = string.format("完成: 英雄[%s] 钢铁[%s]", p.heroic and "√" or " ", p.iron and "√" or " ")
		done_badge.text_align = "right"
		done_badge.vertical_align = "middle"
		done_badge.font_size = 12
		done_badge.colors.text = {160, 178, 210, 255}
		card:add_child(done_badge)

		local play_btn = KButton:new(v(130, 42))
		play_btn.pos = v(card_w - 150, card_h - 55)
		play_btn.text = "游玩"
		play_btn.colors.background = {44, 108, 68, 255}
		play_btn.colors.text = {255, 255, 255, 255}
		function play_btn.on_click()
			self:show_mode_select(map)
		end
		card:add_child(play_btn)

		self.list_content:add_child(card)
		y = y + card_h + 12
	end

	self.list_content.size = v(self.list_view.size.x, y + 8)
end

function screen:show_mode_select(map)
	if self.mode_popup then
		self.window:remove_child(self.mode_popup)
	end

	local pw, ph = 460, 240
	local panel = KView:new(v(pw, ph))
	panel.anchor = v(pw * 0.5, ph * 0.5)
	panel.pos = v(self.sw * 0.5, self.sh * 0.5)
	panel.colors.background = {18, 24, 38, 248}
	self.window:add_child(panel)
	self.mode_popup = panel

	local title = KLabel:new(v(pw, 42))
	title.text = "选择模式 - " .. (map.cfg.name or map.entry)
	title.text_align = "center"
	title.vertical_align = "middle"
	title.font_size = 18
	title.colors.text = {242, 228, 188, 255}
	panel:add_child(title)

	local function add_mode_button(text, mode, y)
		local b = KButton:new(v(180, 36))
		b.pos = v((pw - 180) * 0.5, y)
		b.text = text
		b.colors.background = {44, 62, 90, 255}
		b.colors.text = {240, 240, 240, 255}
		function b.on_click()
			self:start_custom_game(map, mode)
		end
		panel:add_child(b)
	end

	add_mode_button("战役", GAME_MODE_CAMPAIGN, 60)
	if map.has_heroic then
		add_mode_button("英雄", GAME_MODE_HEROIC, 106)
	end
	if map.has_iron then
		add_mode_button("钢铁", GAME_MODE_IRON, map.has_heroic and 152 or 106)
	end

	local close_btn = KButton:new(v(120, 30))
	close_btn.pos = v((pw - 120) * 0.5, ph - 42)
	close_btn.text = "取消"
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
	local max_scroll = math.max(0, self.list_content.size.y - self.list_view.size.y)
	self._scroll = math.max(0, math.min(max_scroll, self._scroll - dy * 28))
	self.list_content.pos = v(0, -self._scroll)
end

function screen:destroy()
	if self.window then
		self.window:destroy()
	end
	self.window = nil
end

return screen
