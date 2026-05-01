local log = require("lib.klua.log"):new("editor_export")
require("klove.kui")
require("gg_views_custom")

local V = require("lib.klua.vector")
local v = V.v
local serpent = require("serpent")
local FS = love.filesystem

local EditorExportView = class("EditorExportView", PopUpView)

local EXPORT_ROOT = "game_editor/plugins"
local CUSTOM_SAVE_FILE = "custom_slot.lua"

local C = {
	bg = {16, 20, 32, 255},
	panel = {26, 33, 50, 255},
	text = {205, 218, 248, 255},
	accent = {195, 148, 38, 255},
	input_bg = {22, 28, 42, 255}
}

local function load_lua_table(path)
	local ok_load, chunk_or_err = pcall(FS.load, path)
	if not ok_load or not chunk_or_err then
		return nil
	end
	local ok_exec, data = pcall(chunk_or_err)
	if not ok_exec or type(data) ~= "table" then
		return nil
	end
	return data
end

local function sanitize_entry(s)
	if not s then
		return ""
	end
	return s:lower():gsub("[^%w_%-]", "_")
end

local function read_rel_or_abs(rel_path, abs_path)
	local content = FS.read(rel_path)
	if content then
		return content
	end
	if abs_path then
		local f = io.open(abs_path, "rb")
		if f then
			local c = f:read("*all")
			f:close()
			return c
		end
	end
	return nil
end

function EditorExportView.scan_custom_maps()
	local maps = {}
	local ok, dirs = pcall(FS.getDirectoryItems, EXPORT_ROOT)
	if not ok or not dirs then
		return maps
	end

	for _, entry in ipairs(dirs) do
		local cfg_path = EXPORT_ROOT .. "/" .. entry .. "/config.lua"
		local f = FS.load(cfg_path)
		if f then
			local ok_cfg, cfg = pcall(f)
			if ok_cfg and type(cfg) == "table" then
				cfg.entry = cfg.entry or entry
				cfg.map_id = cfg.entry
				cfg.level_name = cfg.level_name or string.format("level%02d", tonumber(cfg.level_idx) or 1)
				local waves_root = EXPORT_ROOT .. "/" .. entry .. "/data/waves/"
				cfg.has_campaign = FS.getInfo(waves_root .. cfg.level_name .. "_waves_campaign.lua") ~= nil
				cfg.has_heroic = FS.getInfo(waves_root .. cfg.level_name .. "_waves_heroic.lua") ~= nil
				cfg.has_iron = FS.getInfo(waves_root .. cfg.level_name .. "_waves_iron.lua") ~= nil
				maps[#maps + 1] = cfg
			end
		end
	end

	table.sort(maps, function(a, b)
		return (a.name or a.entry or "") < (b.name or b.entry or "")
	end)
	return maps
end

function EditorExportView.load_custom_save()
	local data = load_lua_table(CUSTOM_SAVE_FILE)
	if not data then
		return {
			maps = {}
		}
	end
	data.maps = data.maps or {}
	return data
end

function EditorExportView.save_custom_save(data)
	data = data or {
		maps = {}
	}
	data.maps = data.maps or {}
	FS.write(CUSTOM_SAVE_FILE, serpent.block(data, {
		indent = "    ",
		sortkeys = true,
		comment = false
	}))
end

function EditorExportView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 160}
	self.editor = editor
	self.level_idx = editor.store.level_idx or 1

	local pw, ph = 680, 460
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	self:add_child(panel)

	local title = KLabel:new(V.v(pw, 36))
	title.text = "导出地图插件"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {238, 244, 255, 255}
	title.colors.background = C.panel
	title.font_size = 16
	title.font_name = KE_CONST.font_name
	panel:add_child(title)

	local close_btn = KButton:new(V.v(30, 30))
	close_btn.text = "X"
	close_btn.pos = v(pw - 35, 5)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end
	panel:add_child(close_btn)

	local fy, fh, lw, mx = 52, 30, 130, 20
	local iw = pw - lw - mx * 2 - 10

	local function add_field(label_text, default_text)
		local lbl = KLabel:new(V.v(lw, fh))
		lbl.pos = v(mx, fy)
		lbl.text = label_text
		lbl.text_align = "right"
		lbl.colors.text = C.accent
		lbl.font_size = 13
		lbl.font_name = KE_CONST.font_name
		lbl.vertical_align = "middle"
		panel:add_child(lbl)
		local input = self:_create_text_input(panel, mx + lw + 10, fy, iw, fh, default_text)
		fy = fy + fh + 8
		return input
	end

	self._name_input = add_field("地图名称:", "我的自定义地图")
	self._entry_input = add_field("唯一标识(entry):", "my_custom_map")
	self._author_input = add_field("作者:", "匿名")
	self._version_input = add_field("版本:", "1.0")
	self._desc_input = add_field("描述:", "一张玩家自制地图")

	local info_lbl = KLabel:new(V.v(pw - 40, 70))
	info_lbl.pos = v(20, fy + 4)
	info_lbl.text = "导出路径固定为: game_editor/plugins/$entry/config.lua\n会同时导出关卡文件、路径、网格，campaign 出怪缺失时自动生成空占位文件。"
	info_lbl.text_align = "left"
	info_lbl.colors.text = C.text
	info_lbl.font_size = 12
	info_lbl.font_name = KE_CONST.font_name
	info_lbl.line_height = 1.3
	panel:add_child(info_lbl)

	local export_btn = KEButton:new("导出插件")
	export_btn.size = v(170, 32)
	export_btn.pos = v(20, ph - 50)
	export_btn.colors.background = {0, 80, 0, 220}
	function export_btn.on_click()
		self:_do_export()
	end
	panel:add_child(export_btn)

	local cancel_btn = KEButton:new("取消")
	cancel_btn.size = v(100, 32)
	cancel_btn.pos = v(pw - 120, ph - 50)
	function cancel_btn.on_click()
		self:hide()
	end
	panel:add_child(cancel_btn)
end

function EditorExportView:_create_text_input(parent, x, y, w, h, default_text)
	local container = KView:new(V.v(w, h))
	container.pos = v(x, y)
	container.colors.background = C.input_bg
	local label = KLabel:new(V.v(w - 8, h))
	label.pos = v(6, 0)
	label.text = default_text or ""
	label.text_align = "left"
	label.colors.text = C.text
	label.font_size = 12
	label.font_name = KE_CONST.font_name
	label.vertical_align = "middle"
	container:add_child(label)
	container.get_text = function()
		return label.text
	end
	container.set_text = function(this, t)
		label.text = t
	end
	container.set_focus = function(this, focused)
		this.focused = focused
		this.colors.background = focused and {40, 60, 96, 255} or C.input_bg
	end
	function container.on_click()
		if self._active_input and self._active_input.set_focus then
			self._active_input:set_focus(false)
		end
		self._active_input = container
		container:set_focus(true)
	end
	parent:add_child(container)
	return container
end

function EditorExportView:textinput(t)
	if self._active_input and self._active_input.get_text and self._active_input.set_text then
		local old = self._active_input:get_text() or ""
		self._active_input:set_text(old .. t)
	end
end

function EditorExportView:keyreleased(key)
	if not self._active_input then
		return
	end
	if key == "backspace" then
		local old = self._active_input:get_text() or ""
		self._active_input:set_text(old:sub(1, math.max(0, #old - 1)))
	elseif key == "return" or key == "kpenter" or key == "escape" then
		self._active_input:set_focus(false)
		self._active_input = nil
	end
end

function EditorExportView:_copy_into_plugin(rel_src, abs_src, rel_dst)
	local content = read_rel_or_abs(rel_src, abs_src)
	if content then
		FS.write(rel_dst, content)
		return true
	end
	return false
end

function EditorExportView:_do_export()
	local level_name = self.editor.store.level_name or string.format("level%02d", self.level_idx)
	local name = self._name_input:get_text()
	local entry = sanitize_entry(self._entry_input:get_text())
	local author = self._author_input:get_text()
	local version = self._version_input:get_text()
	local desc = self._desc_input:get_text()
	local ok_snapshot = self.editor:level_save()

	if name == "" then
		self.editor.gui:show_save_notification("请输入地图名称")
		return
	end
	if entry == "" then
		self.editor.gui:show_save_notification("请输入合法 entry")
		return
	end

	local plugin_dir = EXPORT_ROOT .. "/" .. entry
	local levels_dir = plugin_dir .. "/data/levels"
	local waves_dir = plugin_dir .. "/data/waves"
	local images_dir = plugin_dir .. "/assets/images"
	local sounds_dir = plugin_dir .. "/assets/sounds"
	FS.createDirectory(plugin_dir)
	FS.createDirectory(levels_dir)
	FS.createDirectory(waves_dir)
	FS.createDirectory(images_dir)
	FS.createDirectory(sounds_dir)

	local cfg = {
		name = name,
		entry = entry,
		by = author ~= "" and author or "匿名",
		version = version ~= "" and version or "1.0",
		desc = desc or "",
		level_idx = self.level_idx,
		level_name = level_name,
		enabled = true,
		priority = 0
	}

	local abs_base = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data"
	local has_data = self:_copy_into_plugin("game_editor/data/levels/" .. level_name .. "_data.lua", abs_base .. "/levels/" .. level_name .. "_data.lua", levels_dir .. "/" .. level_name .. "_data.lua")
	local has_paths = self:_copy_into_plugin("game_editor/data/levels/" .. level_name .. "_paths.lua", abs_base .. "/levels/" .. level_name .. "_paths.lua", levels_dir .. "/" .. level_name .. "_paths.lua")
	self:_copy_into_plugin("game_editor/data/levels/" .. level_name .. "_grid.lua", abs_base .. "/levels/" .. level_name .. "_grid.lua", levels_dir .. "/" .. level_name .. "_grid.lua")
	self:_copy_into_plugin("game_editor/data/levels/" .. level_name .. ".lua", abs_base .. "/levels/" .. level_name .. ".lua", levels_dir .. "/" .. level_name .. ".lua")

	local has_campaign = self:_copy_into_plugin("game_editor/data/waves/" .. level_name .. "_waves_campaign.lua", abs_base .. "/waves/" .. level_name .. "_waves_campaign.lua", waves_dir .. "/" .. level_name .. "_waves_campaign.lua")
	if not has_campaign then
		FS.write(waves_dir .. "/" .. level_name .. "_waves_campaign.lua", "return {\n    lives = 20,\n    cash = 800,\n    groups = {}\n}\n")
		has_campaign = true
	end
	local has_heroic = self:_copy_into_plugin("game_editor/data/waves/" .. level_name .. "_waves_heroic.lua", abs_base .. "/waves/" .. level_name .. "_waves_heroic.lua", waves_dir .. "/" .. level_name .. "_waves_heroic.lua")
	local has_iron = self:_copy_into_plugin("game_editor/data/waves/" .. level_name .. "_waves_iron.lua", abs_base .. "/waves/" .. level_name .. "_waves_iron.lua", waves_dir .. "/" .. level_name .. "_waves_iron.lua")
	cfg.has_campaign = has_campaign
	cfg.has_heroic = has_heroic
	cfg.has_iron = has_iron

	local resources = self.editor.store.level and self.editor.store.level.data and self.editor.store.level.data.custom_resources or {}

	if resources.background and resources.background.path then
		local bg = resources.background
		local content = FS.read(bg.path)
		if content then
			local exported_name = bg.filename or ((bg.sprite or "background") .. ".png")
			local target = images_dir .. "/" .. exported_name
			FS.write(target, content)
			cfg.background_image = "assets/images/" .. exported_name
			cfg.background_sprite = bg.sprite
		end
	end

	if resources.battle_music and resources.battle_music.path then
		local content = FS.read(resources.battle_music.path)
		if content then
			local exported_name = resources.battle_music.filename or "battle_music.ogg"
			FS.write(sounds_dir .. "/" .. exported_name, content)
			cfg.battle_music = "assets/sounds/" .. exported_name
		end
	end

	if resources.battle_prep_music and resources.battle_prep_music.path then
		local content = FS.read(resources.battle_prep_music.path)
		if content then
			local exported_name = resources.battle_prep_music.filename or "battle_prep_music.ogg"
			FS.write(sounds_dir .. "/" .. exported_name, content)
			cfg.battle_prep_music = "assets/sounds/" .. exported_name
		end
	end

	local cfg_str = serpent.block(cfg, {
		indent = "    ",
		sortkeys = true,
		comment = false
	})
	FS.write(plugin_dir .. "/config.lua", "return " .. cfg_str .. "\n")

	if not ok_snapshot or not has_data or not has_paths then
		self.editor.gui:show_save_notification("导出完成，但缺少关键文件(data/paths)", false)
		log.error("Plugin export incomplete for %s: snapshot=%s has_data=%s has_paths=%s", entry, tostring(ok_snapshot), tostring(has_data), tostring(has_paths))
	else
		self.editor.gui:show_save_notification("导出成功: " .. plugin_dir .. "/config.lua", true)
		log.info("Plugin exported: %s", plugin_dir)
	end
	self:hide()
end

return EditorExportView
