-- chunkname: @./all/game_editor_export.lua
-- 地图编辑器 - 导出为插件 & 自定义地图管理
local log = require("lib.klua.log"):new("editor_export")
local km = require("lib.klua.macros")
require("lib.klua.table")
require("klove.kui")
require("gg_views_custom")
local V = require("lib.klua.vector")
local v = V.v
local serpent = require("serpent")
local FS = love.filesystem

local EditorExportView = class("EditorExportView", PopUpView)

local C = {
	bg = {16, 20, 32, 255},
	panel = {26, 33, 50, 255},
	text = {205, 218, 248, 255},
	accent = {195, 148, 38, 255},
	input_bg = {22, 28, 42, 255},
	button_bg = {36, 46, 68, 255}
}

-- 自定义地图的存档路径（相对于 love.filesystem 的根目录）
local CUSTOM_MAPS_DIR = "dove_map_editor/maps"
local CUSTOM_SAVE_FILE = "dove_map_editor/save_data.lua"

-- 扫描已安装的自定义地图
function EditorExportView.scan_custom_maps()
	local maps = {}
	local ok, dirs = pcall(FS.getDirectoryItems, CUSTOM_MAPS_DIR)
	if not ok or not dirs then
		return maps
	end

	for _, dir_name in ipairs(dirs) do
		local config_path = CUSTOM_MAPS_DIR .. "/" .. dir_name .. "/config.lua"
		local ok2, content = pcall(FS.read, config_path)
		if ok2 and content then
			local ok3, cfg = pcall(loadstring, "return " .. content)
			if ok3 and cfg then
				cfg.map_id = dir_name
				table.insert(maps, cfg)
			end
		end
	end

	table.sort(maps, function(a, b)
		return (a.name or "") < (b.name or "")
	end)
	return maps
end

-- 加载自定义地图的存档数据
function EditorExportView.load_custom_save()
	local ok, data = pcall(function()
		local content = FS.read(CUSTOM_SAVE_FILE)
		if content then
			return loadstring("return " .. content)()
		end
	end)
	return ok and data or {
		maps = {}
	}
end

-- 保存自定义地图的存档数据
function EditorExportView.save_custom_save(data)
	local str = serpent.block(data, {
		indent = "    ",
		sortkeys = true,
		comment = false
	})
	local dir = CUSTOM_SAVE_FILE:match("(.+)/")
	if dir then
		FS.createDirectory(dir)
	end
	FS.write(CUSTOM_SAVE_FILE, "return " .. str .. "\n")
end

function EditorExportView:initialize(sw, sh, editor)
	PopUpView.initialize(self, V.v(sw, sh))
	self.colors.background = {0, 0, 0, 160}
	self.editor = editor
	self.level_idx = editor.store.level_idx or 1

	local pw, ph = 600, 450
	local panel = KView:new(V.v(pw, ph))
	panel.colors.background = C.bg
	panel.anchor = v(pw / 2, ph / 2)
	panel.pos = v(sw / 2, sh / 2)
	self:add_child(panel)

	-- 标题
	local title = KLabel:new(V.v(pw, 36))
	title.text = "导出地图为插件"
	title.text_align = "center"
	title.vertical_align = "middle"
	title.colors.text = {238, 244, 255, 255}
	title.colors.background = C.panel
	title.font_size = 16
	title.font_name = KE_CONST.font_name
	title.pos = v(0, 0)
	panel:add_child(title)

	-- 关闭
	local close_btn = KButton:new(V.v(30, 30))
	close_btn.text = "X"
	close_btn.pos = v(pw - 35, 5)
	close_btn.colors.background = {120, 50, 50, 255}
	close_btn.colors.text = {255, 255, 255, 255}
	function close_btn.on_click()
		self:hide()
	end
	panel:add_child(close_btn)

	-- 表单
	local fy = 50
	local fh = 28
	local lw = 120
	local iw = pw - 160
	local mx = 30

	-- 地图名称
	local name_lbl = self:_create_label("地图名称:", mx, fy, lw, fh)
	panel:add_child(name_lbl)
	self._name_input = self:_create_text_input(panel, mx + lw, fy, iw, fh, "我的自定义地图")

	-- 作者
	fy = fy + fh + 8
	local author_lbl = self:_create_label("作者:", mx, fy, lw, fh)
	panel:add_child(author_lbl)
	self._author_input = self:_create_text_input(panel, mx + lw, fy, iw, fh, "匿名")

	-- 版本
	fy = fy + fh + 8
	local ver_lbl = self:_create_label("版本:", mx, fy, lw, fh)
	panel:add_child(ver_lbl)
	self._version_input = self:_create_text_input(panel, mx + lw, fy, iw, fh, "1.0")

	-- 描述
	fy = fy + fh + 8
	local desc_lbl = self:_create_label("描述:", mx, fy, lw, fh)
	panel:add_child(desc_lbl)
	self._desc_input = self:_create_text_input(panel, mx + lw, fy, iw, fh, "一张玩家自制地图")

	-- 说明文字
	fy = fy + fh + 16
	local info_lbl = KLabel:new(V.v(pw - 60, 40))
	info_lbl.pos = v(mx, fy)
	info_lbl.text = "导出后地图将保存到自定义地图目录，\n同时也可作为 Mod 插件在模组管理器中加载。"
	info_lbl.text_align = "left"
	info_lbl.colors.text = C.text
	info_lbl.font_size = 11
	info_lbl.font_name = KE_CONST.font_name
	info_lbl.line_height = 1.4
	panel:add_child(info_lbl)

	-- 按钮
	fy = ph - 55
	local export_btn = KEButton:new("导出到自定义地图")
	export_btn.size = v(180, 30)
	export_btn.pos = v(mx, fy)
	export_btn.colors.background = {0, 80, 0, 200}
	function export_btn.on_click()
		self:_do_export(false)
	end
	panel:add_child(export_btn)

	local export_mod_btn = KEButton:new("导出为 Mod 插件")
	export_mod_btn.size = v(170, 30)
	export_mod_btn.pos = v(mx + 200, fy)
	function export_mod_btn.on_click()
		self:_do_export(true)
	end
	panel:add_child(export_mod_btn)

	local cancel_btn = KEButton:new("取消")
	cancel_btn.size = v(100, 30)
	cancel_btn.pos = v(pw - 120, fy)
	function cancel_btn.on_click()
		self:hide()
	end
	panel:add_child(cancel_btn)
end

function EditorExportView:_create_label(text, x, y, w, h)
	local lbl = KLabel:new(V.v(w, h))
	lbl.pos = v(x, y)
	lbl.text = text
	lbl.text_align = "right"
	lbl.colors.text = C.accent
	lbl.font_size = 13
	lbl.font_name = KE_CONST.font_name
	lbl.vertical_align = "middle"
	return lbl
end

function EditorExportView:_create_text_input(parent, x, y, w, h, default_text)
	local container = KView:new(V.v(w, h))
	container.pos = v(x, y)
	container.colors.background = C.input_bg

	local label = KLabel:new(V.v(w - 4, h))
	label.pos = v(4, 0)
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
	container.set_text = function(self, t)
		label.text = t
	end

	parent:add_child(container)
	return container
end

function EditorExportView:_do_export(as_mod)
	local name = self._name_input:get_text()
	local author = self._author_input:get_text()
	local version = self._version_input:get_text()
	local desc = self._desc_input:get_text()

	if not name or name == "" then
		self.editor.gui:show_save_notification("请输入地图名称")
		return
	end

	-- 生成地图ID
	local map_id = "custom_" .. string.lower(name:gsub("[^%w_]", "_"))
	local level_name = "level" .. string.format("%02i", self.level_idx)
	local mode_str = "campaign"

	-- 构建config
	local config = {
		name = name,
		version = version or "1.0",
		entry = "map_" .. map_id,
		game_version = {"kr1"},
		desc = desc or "",
		by = author or "匿名",
		enabled = true,
		priority = 0,
		map_id = map_id,
		level_name = level_name,
		level_idx = self.level_idx
	}

	-- 保存到自定义地图目录
	if not as_mod then
		local map_dir = CUSTOM_MAPS_DIR .. "/" .. map_id
		FS.createDirectory(map_dir)

		-- 保存 config.lua
		local cfg_str = serpent.block(config, {
			indent = "    ",
			sortkeys = true,
			comment = false
		})
		FS.write(map_dir .. "/config.lua", "return " .. cfg_str .. "\n")

		-- 复制关卡数据
		local data_fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. level_name .. "_data.lua"
		local f = io.open(data_fn, "r")
		if f then
			local content = f:read("*all")
			f:close()
			FS.write(map_dir .. "/" .. level_name .. "_data.lua", content)
		end

		-- 复制路径数据
		local paths_fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. level_name .. "_paths.lua"
		local pf = io.open(paths_fn, "r")
		if pf then
			local content = pf:read("*all")
			pf:close()
			FS.write(map_dir .. "/" .. level_name .. "_paths.lua", content)
		end

		-- 复制出怪文件
		local wave_fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/waves/" .. level_name .. "_waves_" .. mode_str .. ".lua"
		local wf = io.open(wave_fn, "r")
		if wf then
			local content = wf:read("*all")
			wf:close()
			FS.write(map_dir .. "/" .. level_name .. "_waves_" .. mode_str .. ".lua", content)
		end

		self.editor.gui:show_save_notification("已导出到自定义地图: " .. name)
		log.info("Custom map exported to: %s", map_dir)

	else
		-- 导出为 Mod 插件格式：放到 mods/local/ 下
		local mod_dir = FS.getWorkingDirectory() .. "/mods/local/map_" .. map_id
		os.execute("mkdir \"" .. mod_dir .. "\"")

		-- config.lua
		config.entry = "map_" .. map_id
		local cfg_str = serpent.block(config, {
			indent = "    ",
			sortkeys = true,
			comment = false
		})
		local cfg_out = "return " .. cfg_str .. "\n"
		local cfg_f = io.open(mod_dir .. "/config.lua", "w")
		if cfg_f then
			cfg_f:write(cfg_out)
			cfg_f:close()
		end

		-- 插件主文件（加载关卡数据的入口）
		local mod_main = [[
-- 自定义地图Mod: ]] .. name .. [[
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()

function hook:init(mod_data)
    -- Mod初始化
end

return hook
]]
		local main_f = io.open(mod_dir .. "/map_" .. map_id .. ".lua", "w")
		if main_f then
			main_f:write(mod_main)
			main_f:close()
		end

		-- 复制关卡数据到 mod 目录
		local data_fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. level_name .. "_data.lua"
		local f = io.open(data_fn, "r")
		if f then
			local content = f:read("*all")
			f:close()
			local df = io.open(mod_dir .. "/" .. level_name .. "_data.lua", "w")
			if df then
				df:write(content)
				df:close()
			end
		end

		self.editor.gui:show_save_notification("已导出为 Mod 插件: " .. name)
		log.info("Mod exported to: %s", mod_dir)
	end

	self:hide()
end

return EditorExportView
