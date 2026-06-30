local log = require("lib.klua.log"):new("editor_export")
require("klove.kui")
require("gg_views_custom")

local V = require("lib.klua.vector")
local v = V.v
local storage = require("all.storage")
local FS = love.filesystem

local EditorExportView = class("EditorExportView", PopUpView)

local EXPORT_ROOT = "game_editor/plugins"
local CUSTOM_SAVE_FILE = "custom_slot.lua"

local C = {
	overlay = {20, 18, 14, 150},
	bg = {198, 177, 126, 255},
	panel = {111, 82, 36, 255},
	text = {58, 41, 20, 255},
	subtle = {93, 70, 38, 255},
	accent = {155, 107, 28, 255},
	input_bg = {242, 231, 202, 255},
	input_focus = {255, 245, 214, 255},
	input_border = {166, 127, 54, 255},
	button = {101, 139, 66, 255}
}

local function load_lua_table(path)
	local ok_load, chunk_or_err = pcall(FS.load, path)
	if not ok_load or not chunk_or_err or type(chunk_or_err) ~= "function" then
		return nil
	end
	local ok_exec, data = pcall(chunk_or_err)
	if ok_exec and type(data) == "table" then
		return data
	end
	local content = FS.read(path)
	if type(content) == "string" and content ~= "" then
		local wrapped = loadstring("return " .. content, "@" .. path .. "(wrapped)")
		if wrapped then
			local ok_wrap, wrapped_data = pcall(wrapped)
			if ok_wrap and type(wrapped_data) == "table" then
				return wrapped_data
			end
		end
	end
	return nil
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
		local cfg = load_lua_table(cfg_path)
		if type(cfg) == "table" then
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
	storage:write_lua(CUSTOM_SAVE_FILE, data)
end

function EditorExportView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = C.overlay
	self.editor = editor
	self.level_idx = editor.store.level_idx or 1

	local pw, ph = 860, 620
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	panel.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, pw, ph, 16, 16}
	}
	self:add_child(panel)
	self.panel = panel

	local title = KLabel:new(V.v(pw, 54))
	title.text = "导出地图插件"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {251, 240, 214, 255}
	title.colors.background = C.panel
	title.font_size = 22
	title.font_name = "h"
	panel:add_child(title)

	local close_btn = KButton:new(V.v(30, 20))
	close_btn.text = "x"
	close_btn.pos = v(pw - 40, 12)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end
	panel:add_child(close_btn)

	local level_name = self.editor.store.level_name or string.format("level%02d", self.level_idx)
	local fy, fh, lw, mx = 78, 34, 142, 28
	local col_gap = 28
	local iw = math.floor((pw - mx * 2 - lw * 2 - col_gap - 20) / 2)

	local function add_field(label_text, default_text, x, y)
		local prop = KEProp:new(label_text, tostring(default_text or ""), true)
		prop.pos = v(x, y)
		prop.size = v(lw + 10 + iw, fh)
		panel:add_child(prop)
		return prop
	end

	local left_x = mx
	local right_x = mx + lw + 10 + iw + col_gap - (lw + 10)
	self._name_input = add_field("地图名称:", "我的自定义地图", left_x, fy)
	self._entry_input = add_field("唯一标识:", "my_custom_map", right_x, fy)
	fy = fy + fh + 10
	self._author_input = add_field("作者:", "匿名", left_x, fy)
	self._version_input = add_field("版本:", "1.0", right_x, fy)
	fy = fy + fh + 10
	self._category_input = add_field("分类:", "level", left_x, fy)
	self._priority_input = add_field("优先级:", "0", right_x, fy)
	fy = fy + fh + 10
	self._url_input = add_field("发布链接:", "", left_x, fy)
	self._url_input.size = v(pw - mx * 2, fh)
	self._url_input.lt.size = v(pw - mx * 2, self._url_input.lt.size.y)
	self._url_input.lv.size = v(pw - mx * 2, self._url_input.lv.size.y)
	self._url_input.input_border.size = v(pw - mx * 2 + 2, self._url_input.input_border.size.y)
	fy = fy + fh + 10
	self._desc_input = add_field("描述:", "一张玩家自制地图", left_x, fy)
	self._desc_input.size = v(pw - mx * 2, fh)
	self._desc_input.lt.size = v(pw - mx * 2, self._desc_input.lt.size.y)
	self._desc_input.lv.size = v(pw - mx * 2, self._desc_input.lv.size.y)
	self._desc_input.input_border.size = v(pw - mx * 2 + 2, self._desc_input.input_border.size.y)
	fy = fy + fh + 18

	local info_lbl = KLabel:new(V.v(pw - 56, 148))
	info_lbl.pos = v(28, fy)
	info_lbl.text = string.format("导出目录：game_editor/plugins/$entry/\n关卡标识：%s\n配置格式遵循 mods/mod_template/config.lua，并附加 level_name / 背景图 / 音乐字段。\n若 campaign 出怪不存在，会自动生成空占位文件。", level_name)
	info_lbl.text_align = "left"
	info_lbl.colors.text = C.text
	info_lbl.font_size = 12
	info_lbl.font_name = "body"
	info_lbl.line_height = 1.3
	info_lbl.colors.background = {232, 220, 188, 140}
	info_lbl.shape = {
		name = "rectangle",
		args = {"fill", 0, 0, info_lbl.size.x, info_lbl.size.y, 12, 12}
	}
	panel:add_child(info_lbl)

	local export_btn = KEButton:new("导出插件")
	export_btn.size = v(170, 32)
	export_btn.pos = v(28, ph - 58)
	export_btn.colors.background = C.button
	function export_btn.on_click()
		self:_do_export()
	end
	panel:add_child(export_btn)

	local cancel_btn = KEButton:new("取消")
	cancel_btn.size = v(100, 32)
	cancel_btn.pos = v(pw - 128, ph - 58)
	function cancel_btn.on_click()
		self:hide()
	end
	panel:add_child(cancel_btn)
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
	local name = tostring(self._name_input.value or "")
	local entry = sanitize_entry(self._entry_input.value or "")
	local author = tostring(self._author_input.value or "")
	local version = tostring(self._version_input.value or "")
	local desc = tostring(self._desc_input.value or "")
	local url = tostring(self._url_input and self._url_input.value or "")
	local category = sanitize_entry(self._category_input and self._category_input.value or "")
	local priority = tonumber(self._priority_input and self._priority_input.value or "") or 0
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
		url = url ~= "" and url or "",
		category = category ~= "" and category or "level",
		level_idx = self.level_idx,
		level_name = level_name,
		enabled = true,
		priority = priority
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
	self:_copy_into_plugin("game_editor/data/waves/" .. level_name .. "_waves_heroic.lua", abs_base .. "/waves/" .. level_name .. "_waves_heroic.lua", waves_dir .. "/" .. level_name .. "_waves_heroic.lua")

	self:_copy_into_plugin("game_editor/data/waves/" .. level_name .. "_waves_iron.lua", abs_base .. "/waves/" .. level_name .. "_waves_iron.lua", waves_dir .. "/" .. level_name .. "_waves_iron.lua")

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

	storage:write_lua(plugin_dir .. "/config.lua", cfg)

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
