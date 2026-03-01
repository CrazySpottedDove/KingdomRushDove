-- chunkname: @./all-desktop/mod_manager_view.lua
-- 模组管理器 GUI
local log = require("lib.klua.log"):new("mod_manager_view")
local class = require("middleclass")
local V = require("lib.klua.vector")
local G = love.graphics
local FS = love.filesystem

require("gg_views_custom") -- PopUpView, GGOptionsButton, GGPanelHeader, GGLabel 等

local PANEL_W = 720
local PANEL_H = 600
local SCROLL_H = 390
local ROW_H = 110
local ROW_PAD = 12 -- 行内左边距

-- ─────────────────────────────────────────────
-- 简单开关按钮：无需图片，用彩色文字表示状态
-- ─────────────────────────────────────────────
ModToggleButton = class("ModToggleButton", KButton)

function ModToggleButton:initialize(initial_value)
	local rs = GGLabel.static.ref_h / REF_H

	KButton.initialize(self, V.v(56, 28))

	self.value = initial_value ~= false
	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false

	self._text_label = GGLabel:new(self.size)
	self._text_label.font_name = "body"
	self._text_label.font_size = 14 * rs
	self._text_label.text_align = "center"
	self._text_label.vertical_align = "middle"
	self._text_label.propagate_on_up = true
	self._text_label.propagate_on_down = true
	self._text_label.propagate_on_click = true
	self._is_hovered = false
	self:add_child(self._text_label)
	self:_refresh()
end

function ModToggleButton:_refresh()
	if self._is_hovered then
		self.colors.background = {60, 60, 60, 150}
	else
		if self.value then
			self.colors.background = {40, 120, 60, 220}
			self._text_label.colors.text = {180, 255, 160, 255}
			self._text_label.text = "启用"
		else
			self.colors.background = {120, 40, 40, 200}
			self._text_label.colors.text = {255, 160, 140, 255}
			self._text_label.text = "禁用"
		end
	end
end

function ModToggleButton:on_down(button, x, y)
	self:set_value(not self.value)
end

function ModToggleButton:set_value(v)
	self.value = v
	self:_refresh()

	if self.on_change then
		self:on_change(v)
	end
end

function ModToggleButton:on_enter()
	self._is_hovered = true
	self:_refresh()
end

function ModToggleButton:on_exit()
	self._is_hovered = false
	self:_refresh()
end

-- ─────────────────────────────────────────────
-- 单个模组行
-- ─────────────────────────────────────────────
ModItemRow = class("ModItemRow", KView)

function ModItemRow:initialize(mod_data, row_w)
	row_w = row_w or 640
	KView.initialize(self, V.v(row_w, ROW_H))

	self.mod_data = mod_data
	self.colors.background = {28, 22, 16, 200}

	local cfg = mod_data.config or {}
	local rs = GGLabel.static.ref_h / REF_H
	local text_w = row_w - 100 -- 留出右侧开关按钮的位置

	-- 模组名称
	local name_lbl = GGLabel:new(V.v(text_w, 22))
	name_lbl.font_name = "h"
	name_lbl.font_size = 15 * rs
	name_lbl.text_align = "left"
	name_lbl.vertical_align = "middle"
	name_lbl.colors.text = {230, 210, 155, 255}
	name_lbl.text = cfg.name or mod_data.name or "?"
	name_lbl.fit_lines = 1
	name_lbl.line_height = 1
	name_lbl.pos = V.v(ROW_PAD, 6)
	name_lbl.fit_size = true
	self:add_child(name_lbl)

	-- 版本 + 作者
	local meta_lbl = GGLabel:new(V.v(text_w, 18))
	meta_lbl.font_name = "body"
	meta_lbl.font_size = 13 * rs
	meta_lbl.text_align = "left"
	meta_lbl.vertical_align = "middle"
	meta_lbl.colors.text = {170, 158, 118, 255}
	meta_lbl.line_height = 1
	meta_lbl.fit_size = true
	local ver = cfg.version and ("v" .. cfg.version) or ""
	local by = cfg.by and ("作者: " .. cfg.by) or ""
	meta_lbl.text = ver .. (ver ~= "" and by ~= "" and "  " or "") .. by
	meta_lbl.pos = V.v(ROW_PAD, 28)
	self:add_child(meta_lbl)

	-- 描述
	local desc_lbl = GGLabel:new(V.v(text_w, 48))
	desc_lbl.font_name = "body"
	desc_lbl.fit_size = true
	desc_lbl.line_height = 1.2
	desc_lbl.font_size = 12 * rs
	desc_lbl.text_align = "left"
	desc_lbl.vertical_align = "top"
	desc_lbl.line_height = 1.2
	desc_lbl.colors.text = {145, 138, 115, 255}
	desc_lbl.text = cfg.desc or ""
	desc_lbl.fit_lines = 3
	desc_lbl.pos = V.v(ROW_PAD, 50)
	self:add_child(desc_lbl)

	-- 开关按钮（右侧居中）
	local toggle = ModToggleButton:new(cfg.enabled ~= false)
	toggle.anchor = V.v(toggle.size.x / 2, toggle.size.y / 2)
	toggle.pos = V.v(row_w - 42, ROW_H / 2)
	self:add_child(toggle)
	self.toggle = toggle

	-- 分隔线
	local sep = KView:new(V.v(row_w, 1))
	sep.colors.background = {55, 44, 30, 200}
	sep.pos = V.v(0, ROW_H - 1)
	self:add_child(sep)
end

function ModItemRow:is_enabled()
	return self.toggle.value
end

-- ─────────────────────────────────────────────
-- 主面板
-- ─────────────────────────────────────────────
ModManagerView = class("ModManagerView", PopUpView)

function ModManagerView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	local rs = GGLabel.static.ref_h / REF_H

	-- 背景面板（深色矩形）
	self.back = KView:new(V.v(PANEL_W, PANEL_H))
	self.back.colors.background = {18, 14, 10, 250}
	self.back.anchor = V.v(PANEL_W / 2, PANEL_H / 2)
	self.back.pos = V.v(sw / 2, sh / 2)
	self:add_child(self.back)

	-- 边框效果（略宽、略高的半透明矩形）
	local border = KView:new(V.v(PANEL_W + 4, PANEL_H + 4))
	border.colors.background = {90, 70, 40, 160}
	border.anchor = V.v((PANEL_W + 4) / 2, (PANEL_H + 4) / 2)
	border.pos = V.v(sw / 2, sh / 2)
	border.ignore_bounds = true
	self:add_child(border, 1) -- 放到 back 之前
	self:remove_child(border)
	self:add_child(border, 1) -- 确保在最底层

	-- ── 标题 ──
	local header = GGPanelHeader:new("模组管理器", PANEL_W - 40)
	header.pos = V.v(20, 14)
	self.back:add_child(header)

	-- ── 总开关行 ──
	local global_lbl = GGOptionsLabel:new(V.v(280, 28))
	global_lbl.text = "启用模组加载器"
	global_lbl.text_align = "left"
	global_lbl.vertical_align = "middle"
	global_lbl.pos = V.v(20, 56)
	self.back:add_child(global_lbl)

	local global_toggle = ModToggleButton:new(false)
	global_toggle.anchor = V.v(global_toggle.size.x / 2, global_toggle.size.y / 2)
	global_toggle.pos = V.v(PANEL_W - 48, 70)
	self.back:add_child(global_toggle)
	self.global_toggle = global_toggle

	-- 分隔线
	local sep1 = KView:new(V.v(PANEL_W - 40, 1))
	sep1.colors.background = {75, 60, 36, 255}
	sep1.pos = V.v(20, 96)
	self.back:add_child(sep1)

	-- 提示文字
	local hint_height = 20
	local hint_lbl = GGLabel:new(V.v(PANEL_W - 40, 20))
	hint_lbl.font_name = "body"
	hint_lbl.font_size = 12 * rs
	hint_lbl.text_align = "left"
	hint_lbl.colors.text = {140, 130, 100, 255}
	hint_lbl.text = "保存后需要重启游戏才能生效"
	hint_lbl.pos = V.v(20, 100)
	self.back:add_child(hint_lbl)

	-- ── 模组列表 ──
	local list_pos_y = 100 + hint_height + 15
	local list = KScrollList:new(V.v(PANEL_W - 40, SCROLL_H))
	list.pos = V.v(20, list_pos_y)
	list.scroll_amount = ROW_H
	list.colors.scroller_background = {45, 36, 22, 200}
	list.colors.scroller_foreground = {110, 90, 50, 255}
	list.propagate_on_up = true
	list.propagate_on_down = true
	self.back:add_child(list)
	self.mod_list = list

	-- ── 保存并关闭 按钮 ──
	local y_btn = list_pos_y + SCROLL_H + hint_height
	local save_btn = GGOptionsButton:new("保存并关闭")
	save_btn:set_anchor_to_center()
	save_btn.pos = V.v(PANEL_W / 2, y_btn)

	local this = self
	function save_btn.on_click()
		this:save()
		this:hide()
	end

	self.back:add_child(save_btn)
	self._mod_rows = {}
end

-- 从磁盘重新读取 mod_main_config，返回配置表（不经过 require 缓存）
function ModManagerView:_read_main_config()
	-- 优先读保存目录（覆盖源文件），再读源目录
	local str = FS.read("mods/local/mod_main_config.lua")

	if not str then
		return nil
	end

	local chunk, err = loadstring(str)

	if not chunk then
		log.error("解析 mod_main_config.lua 失败: %s", tostring(err))

		return nil
	end

	local ok, result = pcall(chunk)

	return ok and result or nil
end

-- 从磁盘读取某个模组的 config.lua
function ModManagerView:_read_mod_config(path)
	local str = FS.read(path)

	if not str then
		return nil
	end

	local chunk, err = loadstring(str)

	if not chunk then
		return nil
	end

	local ok, result = pcall(chunk)

	return ok and result or nil
end

-- 序列化 mod_main_config 到字符串
function ModManagerView:_serialize_main_config(cfg)
	local lines = {"return {"}

	lines[#lines + 1] = "\tenabled = " .. tostring(cfg.enabled) .. ","

	if cfg.not_mod_path then
		local items = {}

		for _, v in ipairs(cfg.not_mod_path) do
			table.insert(items, string.format("%q", v))
		end

		lines[#lines + 1] = "\tnot_mod_path = {" .. table.concat(items, ", ") .. "},"
	end

	if cfg.ignored_path then
		local items = {}

		for _, v in ipairs(cfg.ignored_path) do
			table.insert(items, string.format("%q", v))
		end

		lines[#lines + 1] = "\tignored_path = {" .. table.concat(items, ", ") .. "},"
	end

	if cfg.ppref ~= nil then
		lines[#lines + 1] = "\tppref = " .. string.format("%q", cfg.ppref) .. ","
	end

	if cfg.check_paths then
		local items = {}

		for _, v in ipairs(cfg.check_paths) do
			table.insert(items, string.format("%q", v))
		end

		lines[#lines + 1] = "\tcheck_paths = {" .. table.concat(items, ", ") .. "},"
	end

	lines[#lines + 1] = "}"

	return table.concat(lines, "\n")
end

-- 序列化 mod config.lua 到字符串
function ModManagerView:_serialize_mod_config(cfg)
	local lines = {"return {"}

	local function write_val(k, v)
		if type(v) == "string" then
			lines[#lines + 1] = string.format("\t%s = %q,", k, v)
		elseif type(v) == "boolean" then
			lines[#lines + 1] = string.format("\t%s = %s,", k, tostring(v))
		elseif type(v) == "number" then
			lines[#lines + 1] = string.format("\t%s = %s,", k, tostring(v))
		elseif type(v) == "table" then
			local items = {}

			for _, item in ipairs(v) do
				table.insert(items, string.format("%q", tostring(item)))
			end

			lines[#lines + 1] = string.format("\t%s = {%s},", k, table.concat(items, ", "))
		end
	end

	-- 按固定顺序写出，保持可读性
	local ordered = {"name", "version", "game_version", "desc", "url", "by", "enabled", "priority"}
	local written = {}

	for _, k in ipairs(ordered) do
		if cfg[k] ~= nil then
			write_val(k, cfg[k])
			written[k] = true
		end
	end

	-- 写出其余键
	for k, v in pairs(cfg) do
		if not written[k] then
			write_val(k, v)
		end
	end

	lines[#lines + 1] = "}"

	return table.concat(lines, "\n")
end

-- 重新加载模组列表到滚动列表
function ModManagerView:_reload_list()
	self.mod_list:clear_rows()
	self._mod_rows = {}

	local mods_dir = "mods/local"

	-- 读取 not_mod_path 排除项（先尝试磁盘，再 require）
	local not_mod_path = {"mod_template", "all"}
	local disk_cfg = self:_read_main_config()

	if disk_cfg then
		not_mod_path = disk_cfg.not_mod_path or not_mod_path
		self.global_toggle:set_value(disk_cfg.enabled ~= false)
	else
		local ok, mmc = pcall(require, "mods.local.mod_main_config")

		if ok and mmc then
			not_mod_path = mmc.not_mod_path or not_mod_path
			self.global_toggle:set_value(mmc.enabled ~= false)
		end
	end

	local items = FS.getDirectoryItems(mods_dir)

	if not items then
		return
	end

	for _, name in ipairs(items) do
		if not table.contains(not_mod_path, name) then
			local dir_path = mods_dir .. "/" .. name

			if FS.isDirectory(dir_path) then
				local config_path = dir_path .. "/config.lua"
				local cfg = self:_read_mod_config(config_path)

				if cfg then
					local mod_data = {
						name = name,
						path = dir_path,
						config_path = config_path,
						config = cfg
					}
					local list_w = self.mod_list.size.x - self.mod_list.scroller_width - 2 * self.mod_list.scroller_margin - 4
					local row = ModItemRow:new(mod_data, list_w)

					self.mod_list:add_row(row)
					table.insert(self._mod_rows, row)
				end
			end
		end
	end
end

function ModManagerView:show()
	self:_reload_list()
	ModManagerView.super.show(self)
end

local function write_file(file_path, content)
	local f, err = io.open(file_path, "wb")
	if not f then
		return false, err
	end
	f:write(content)
	f:close()
	return true, nil
end

-- 将当前设置写入磁盘（save dir 覆盖）
function ModManagerView:save()
	-- 1. 保存总开关
	local disk_cfg = self:_read_main_config()
	local ok, mmc = pcall(require, "mods.local.mod_main_config")
	local base_cfg = (disk_cfg ~= nil) and disk_cfg or (ok and mmc) or {
		enabled = false
	}
	base_cfg.enabled = self.global_toggle.value

	local str = self:_serialize_main_config(base_cfg)
	local write_success, err = write_file("mods/local/mod_main_config.lua", str)
	if not write_success then
		log.error("写入 mods/local/mod_main_config.lua 失败: %s", tostring(err))
	end

	-- 2. 保存各模组启用状态
	for _, row in ipairs(self._mod_rows) do
		local cfg = row.mod_data.config

		if cfg then
			local new_cfg = {}

			for k, v in pairs(cfg) do
				new_cfg[k] = v
			end

			new_cfg.enabled = row:is_enabled()

			local out = self:_serialize_mod_config(new_cfg)

			write_success, err = write_file(row.mod_data.config_path, out)
			if not write_success then
				log.error("写入 %s 失败: %s", row.mod_data.config_path, tostring(err))
			end
		end
	end
end
