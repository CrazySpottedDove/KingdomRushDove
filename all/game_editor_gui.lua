-- chunkname: @./all/game_editor_gui.lua
local log = require("lib.klua.log"):new("game_editor_gui")
local km = require("lib.klua.macros")

require("lib.klua.table")
require("klove.kui")

local kui_db = require("klove.kui_db")
local F = require("lib.klove.font_db")
local I = require("lib.klove.image_db")
local SU = require("screen_utils")
local LU = require("level_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("lib.klua.vector")
local P = require("path_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local G = love.graphics
local bit = require("bit")
local band = bit.band

require("all.constants")
local timer = require("hump.timer").new()
require("all.game_editor_classes")
-- require("gg_views_custom")

local NODE_SELECTION_WINDOW = 8

log:set_level("debug")

local gui = {}

gui.required_textures = {}
gui.plugin_required_textures = {}
gui.plugin_required_sounds = {}

local function wid(id)
	return gui.window:get_child_by_id(id)
end

local function set_gui_responder(window, view)
	local prev = window.responder

	if prev and prev ~= view and prev.set_input_focused then
		prev:set_input_focused(false)
	end

	window:set_responder(view)

	if view and view.set_input_focused then
		view:set_input_focused(true)
	end
end

local function is_kbutton_instance(view)
	local c = view and view.class

	while c do
		if c.name == "KButton" then
			return true
		end

		c = c.super
	end

	return false
end

local function fit_button_text(btn, min_font_size)
	if not btn or not btn.size then
		return
	end

	min_font_size = min_font_size or 7
	btn.text_size = V.v(btn.size.x, btn.size.y)
	btn.text_align = "center"

	local font_size = btn.font_size or KE_CONST.font_size
	local target_w = btn.size.x - 8

	while font_size > min_font_size do
		btn.font_size = font_size
		if btn._load_font then
			btn:_load_font()
		end
		local w = btn.font and btn.font.getWidth and btn.font:getWidth(btn.text or "") or 0
		if w <= target_w then
			break
		end
		font_size = font_size - 1
	end

	btn.font_size = font_size
	btn.text_offset = V.v(0, math.floor((btn.size.y - btn.font_size) / 2))
end

---计算两个坐标之差的绝对值是否小于给定值
---@param axi1 table 坐标1
---@param axi2 table 坐标2
---@param range number? 值（可选，默认 550）
---@return boolean
function gui.are_axes_in_range(axi1, axi2, range)
	range = range or 550

	local vx = math.abs(axi1.x - axi2.x)
	local vy = math.abs(axi1.y - axi2.y)

	if vx < range and vy < range then
		return true
	elseif vx == 0 and vy == 0 then
		return nil, "is_0"
	end
end

function gui:init(w, h, editor)
	self.editor = editor
	self.w = w
	self.h = h
	self.sw = w
	self.sh = h
	self.scale = 1
	self.active_tool = nil
	self.tool_names = {"entities", "paths", "grid"}
	self.settings = {}
	self.settings.grid = {}
	self.settings.grid.brush_size = 1
	self.settings.grid.paint = TERRAIN_NONE
	self.settings.grid.show_terrain = true
	self.settings.grid.show_tags = true
	self.tool_shortcuts = {}

	local tt = kui_db:get_table("game_editor_gui")
	local window = KWindow:new_from_table(tt)

	window.scale = V.v(self.scale, self.scale)
	window.size = V.v(self.sw, self.sh)
	window.timer = timer
	self.window = window

	local general_btn = wid("tools_general")
	if general_btn and general_btn.parent then
		general_btn.parent:remove_child(general_btn)
	end

	local general_panel = wid("general")
	if general_panel and general_panel.parent then
		general_panel.parent:remove_child(general_panel)
	end

	local safe_frame_btn = wid("tg_safe_frame")
	if safe_frame_btn and safe_frame_btn.parent then
		safe_frame_btn.parent:remove_child(safe_frame_btn)
	end

	-- 暂时停用“方向键导航”工具，仅保留底层逻辑代码
	local nav_btn = wid("tools_nav")
	if nav_btn and nav_btn.parent then
		nav_btn.parent:remove_child(nav_btn)
	end

	local nav_panel = wid("nav")
	if nav_panel then
		nav_panel.hidden = true
	end

	self:compact_tools_panel()
	self:compact_entities_panel()
	self:add_back_to_map_button()
	self:add_extension_tools_buttons()
	self:apply_fixed_tool_layout()

	wid("picker").size = V.v(self.sw, self.sh)
	wid("picker").gui = self
	wid("tools_save").on_click = function()
		local ok = editor:level_save()
		if ok then
			self:show_save_notification("保存成功", true)
		else
			self:show_save_notification("保存失败", false)
		end
	end
	wid("tools_load").on_click = function()
		editor:load_level(wid("tools_level_name").value, wid("tools_game_mode").value)
	end
	wid("tools_recover").on_click = function()
		editor:load_level(editor.store.level_idx, editor.store.level_mode, true)
	end
	wid("tools_undo").on_click = function()
		self:undo()
	end
	wid("tools_pointer_pos").update = function(this, dt)
		self:pointer_pos_label_update(this, dt)
	end

	for _, n in pairs(self.tool_names) do
		wid(n).hidden = true
		wid("tools_" .. n).on_click = function()
			self:toggle_tool(n)
		end
	end

	for _, n in pairs(self.tool_names) do
		wid(n).on_click = function()
			self:select_tool(n)
		end
		wid(n .. "_title").on_click = function()
			self:select_tool(n)
		end
		wid(n .. "_close").on_click = function()
			self:hide_tool(n)
		end
	end

	wid("cell_info").update = function(this, dt)
		self:grid_cell_info_update(this, dt)
	end

	self:set_grid_paint_type(TERRAIN_NONE)

	wid("paint_type_none").on_click = function()
		self:set_grid_paint_type(TERRAIN_NONE)
	end
	wid("paint_type_land").on_click = function()
		self:set_grid_paint_type(TERRAIN_LAND)
	end
	wid("paint_type_water").on_click = function()
		self:set_grid_paint_type(TERRAIN_WATER)
	end
	wid("paint_type_cliff").on_click = function()
		self:set_grid_paint_type(TERRAIN_CLIFF)
	end
	wid("paint_flag_shallow").on_click = function()
		self:toggle_grid_paint_flag(TERRAIN_SHALLOW)
	end
	wid("paint_flag_nowalk").on_click = function()
		self:toggle_grid_paint_flag(TERRAIN_NOWALK)
	end
	wid("paint_flag_faerie").on_click = function()
		self:toggle_grid_paint_flag(TERRAIN_FAERIE)
	end
	wid("paint_flag_ice").on_click = function()
		self:toggle_grid_paint_flag(TERRAIN_ICE)
	end
	wid("paint_flag_flying_nw").on_click = function()
		self:toggle_grid_paint_flag(TERRAIN_FLYING_NOWALK)
	end
	wid("brush_size_inc").on_click = function()
		self:grid_brush_size_change(2)
	end
	wid("brush_size_dec").on_click = function()
		self:grid_brush_size_change(-2)
	end
	wid("grid_size").on_change = function(this)
		self:update_grid_prop(this)
	end
	wid("grid_offset").on_change = function(this)
		self:update_grid_prop(this)
	end
	self:ensure_grid_layer_toggle_buttons()
	self.tool_shortcuts.grid = {
		["-"] = function()
			self:grid_brush_size_change(-2)
		end,
		["="] = function()
			self:grid_brush_size_change(2)
		end,
		q = function()
			self:set_grid_paint_type(TERRAIN_NONE)
		end,
		e = function()
			self:set_grid_paint_type(TERRAIN_LAND)
		end,
		w = function()
			self:set_grid_paint_type(TERRAIN_WATER)
		end,
		c = function()
			self:set_grid_paint_type(TERRAIN_CLIFF)
		end,
		s = function()
			self:toggle_grid_paint_flag(TERRAIN_SHALLOW)
		end,
		d = function()
			self:toggle_grid_paint_flag(TERRAIN_NOWALK)
		end,
		f = function()
			self:toggle_grid_paint_flag(TERRAIN_FAERIE)
		end,
		g = function()
			self:toggle_grid_paint_flag(TERRAIN_ICE)
		end
	}
	wid("entities_insert").on_click = nil
	wid("entities_insert").text = "插入实体(A) [仅快捷键]"
	wid("entities_selected").hidden = true

	-- 设置实体自动补全
	self:_setup_entity_autocomplete()
	wid("entities_duplicate").on_click = function()
		gui:duplicate_entity()
	end
	wid("entities_delete").on_click = function()
		gui:delete_entity()
	end
	wid("entities_delete").text = "删除实体(D)"
	wid("entities_pos").on_change = function(this)
		gui:update_entity_prop(this)
	end
	self.tool_shortcuts.entities = {
		up = function()
			self:move_entity("up")
		end,
		down = function()
			self:move_entity("down")
		end,
		left = function()
			self:move_entity("left")
		end,
		right = function()
			self:move_entity("right")
		end,
		a = function()
			self:insert_entity()
		end,
		d = function()
			self:delete_entity()
		end,
		escape = function()
			self:select_entity(nil)
		end
	}
	wid("path_create").on_click = function(this)
		gui:create_path()
	end
	wid("path_remove").on_click = function(this)
		gui:remove_path()
	end
	wid("path_move_up").on_click = function(this)
		gui:move_path(-1)
	end
	wid("path_move_down").on_click = function(this)
		gui:move_path(1)
	end
	local move_up_btn = wid("path_move_up")
	if move_up_btn and move_up_btn.parent then
		local row = move_up_btn.parent
		row:remove_child(move_up_btn)
		if #row.children == 0 and row.parent then
			row.parent:remove_child(row)
		else
			row:update_layout()
		end
	end
	local move_down_btn = wid("path_move_down")
	if move_down_btn and move_down_btn.parent then
		local row = move_down_btn.parent
		row:remove_child(move_down_btn)
		if #row.children == 0 and row.parent then
			row.parent:remove_child(row)
		else
			row:update_layout()
		end
	end
	wid("path_duplicate").on_click = function(this)
		gui:duplicate_path()
	end
	wid("path_flip").on_click = function(this)
		gui:flip_path()
	end
	wid("path_preview").on_click = function(this)
		gui:preview_path()
	end
	wid("path_active").on_change = function(this)
		gui:path_active_change(this)
	end
	wid("path_connects_to").on_change = function(this)
		gui:path_connects_to_change(this)
	end
	wid("path_node_pos").on_change = function(this)
		gui:path_node_pos_change(this)
	end
	wid("path_node_id").editable = true
	wid("path_node_id").defer_change = true
	wid("path_node_id").on_change = function(this)
		gui:path_node_id_change(this)
	end
	wid("path_node_width").on_change = function(this)
		gui:path_node_width_change(this)
	end
	wid("path_node_extend").on_click = nil
	wid("path_node_extend").text = "添加节点(A) [仅快捷键]"
	wid("path_node_extend").font_size = KE_CONST.font_size
	local path_node_row = wid("path_node_extend").parent
	if path_node_row and path_node_row.style == "horizontal" then
		path_node_row.style = "vertical"
		path_node_row:update_layout()
	end
	local subdivide_btn = wid("path_node_subdivide")
	if subdivide_btn then
		subdivide_btn.on_click = nil
		subdivide_btn.text = "细分路径(W) [仅快捷键]"
		subdivide_btn.font_size = KE_CONST.font_size
		subdivide_btn.size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
		fit_button_text(subdivide_btn)
	end
	wid("path_node_extend").size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
	fit_button_text(wid("path_node_extend"))
	local list_section = wid("paths_list_section")
	if list_section then
		list_section:update_layout()
	end
	wid("paths_node_selected"):update_layout()
	wid("paths_props"):update_layout()
	wid("path_node_remove").on_click = function(this)
		gui:path_node_remove(this)
	end
	wid("path_node_remove").text = "移除(D)"
	wid("path_node_remove").text_offset = V.v(0, (KE_CONST.PROP_H - KE_CONST.font_size) / 2)
	self.tool_shortcuts.paths = {
		up = function()
			self:path_nodes_move(0, 1, true)
		end,
		down = function()
			self:path_nodes_move(0, -1, true)
		end,
		left = function()
			self:path_nodes_move(-1, 0, true)
		end,
		right = function()
			self:path_nodes_move(1, 0, true)
		end,
		d = function()
			self:path_node_remove()
		end,
		a = function()
			self:path_node_add()
		end,
		w = function()
			self:path_node_subdivide_at_mouse()
		end,
		v = function()
			self:preview_path()
		end
	}
	wid("nav_id_top").on_change = function(this)
		gui.set_nav_mesh(this, 2)
	end
	wid("nav_id_left").on_change = function(this)
		gui.set_nav_mesh(this, 3)
	end
	wid("nav_id_right").on_change = function(this)
		gui.set_nav_mesh(this, 1)
	end
	wid("nav_id_bottom").on_change = function(this)
		gui.set_nav_mesh(this, 4)
	end
	wid("nav_nearest_sel").on_click = function(this)
		gui.assign_nearest_selected(gui.editor.nav_entity_selected)
		gui:select_entity_nav(gui.editor.nav_entity_selected)
	end
	wid("nav_nearest_all").on_click = function(this)
		if not gui.editor.nav_entity_selected then
			return
		end

		gui.assign_nearest_all()
		gui:select_entity_nav(gui.editor.nav_entity_selected)
	end
	wid("nav_clear_all").on_click = function(this)
		gui.clear_nav_all()
	end
	wid("nav_renumber_holders").on_click = function(this)
		gui.renumber_holders()
	end
	wid("nav_adds_missing_numbers").on_click = function(this)
		gui.adds_missing_numbers()
	end
	wid("tools_level_name").value = 1

	-- 修改关卡时，自动更新关卡名称以保持一致
	wid("tools_level_name").on_change = function(self)
		editor.store.level_idx = self.value
		editor.store.level_name = "level" .. string.format("%02i", self.value)
	end

	wid("tools_game_mode").on_change = function(self)
		editor.store.game_mode = self.value
	end

	wid("tools_level_name"):update()
	wid("entities_insert_template"):set_value("tower_holder")
	self:enhance_button_feedback()
end

function gui:compact_tools_panel()
	local tools = wid("tools")

	local layout = tools.children[3]

	for i = #layout.children, 1, -1 do
		local c = layout.children[i]
		if c and c.isInstanceOf and c:isInstanceOf(KESep) and (c.text == "Level" or c.text == "Tools" or c.text == "Toggles") then
			layout:remove_child(c)
		end
	end

	layout:update_layout()
end

function gui:add_back_to_map_button()
	local tools = wid("tools")
	local layout = tools and tools.children and tools.children[3]
	if not layout then
		return
	end

	if wid("tools_back_to_map") then
		return
	end

	local back_btn = KEButton:new("返回地图")
	back_btn.id = "tools_back_to_map"
	back_btn.size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
	back_btn.text_offset = V.v(0, (KE_CONST.PROP_H - KE_CONST.font_size) / 2)

	function back_btn.on_click()
		if gui.editor and gui.editor.done_callback then
			gui.editor.done_callback({
				next_item_name = "map"
			})
		else
			gui:show_save_notification("无法返回地图", false)
		end
	end

	layout:add_child(back_btn)
	layout:update_layout()
end

function gui:add_extension_tools_buttons()
	local tools = wid("tools")
	local layout = tools.children[3]

	local function add_btn(id, title, on_click)
		if wid(id) then
			return
		end
		local b = KEButton:new(title)
		b.id = id
		b.size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
		b.text_offset = V.v(0, (KE_CONST.PROP_H - KE_CONST.font_size) / 2)
		function b.on_click()
			on_click()
		end
		layout:add_child(b)
	end

	add_btn("tools_wave_config", "出怪配置", function()
		self:show_wave_config()
	end)
	add_btn("tools_wave_preview", "出怪预览", function()
		self:show_wave_editor()
	end)
	-- TODO: 确认效果，审查逻辑
	-- add_btn("tools_import_bg", "导入背景图", function()
	-- 	local next_mode = self.editor.drop_import_mode == "background" and nil or "background"
	-- 	self.editor:set_drop_import_mode(next_mode)
	-- 	self:show_save_notification(next_mode and "已进入背景图拖拽模式，请拖入 PNG 文件" or "已取消背景图拖拽模式", next_mode ~= nil)
	-- end)
	-- add_btn("tools_import_battle_prep_music", "导入备战音乐", function()
	-- 	local next_mode = self.editor.drop_import_mode == "battle_prep_music" and nil or "battle_prep_music"
	-- 	self.editor:set_drop_import_mode(next_mode)
	-- 	self:show_save_notification(next_mode and "已进入备战音乐拖拽模式，请拖入 OGG / MP3 / WAV" or "已取消备战音乐拖拽模式", next_mode ~= nil)
	-- end)
	-- add_btn("tools_import_battle_music", "导入战斗音乐", function()
	-- 	local next_mode = self.editor.drop_import_mode == "battle_music" and nil or "battle_music"
	-- 	self.editor:set_drop_import_mode(next_mode)
	-- 	self:show_save_notification(next_mode and "已进入战斗音乐拖拽模式，请拖入 OGG / MP3 / WAV" or "已取消战斗音乐拖拽模式", next_mode ~= nil)
	-- end)
	-- add_btn("tools_export_plugin", "导出插件", function()
	-- self:show_export_view()
	-- end)
	layout:update_layout()
	self:update_drop_import_buttons()
end

function gui:update_drop_import_buttons()
	local active_mode = self.editor and self.editor.drop_import_mode or nil
	local button_modes = {
		tools_import_bg = "background",
		tools_import_battle_prep_music = "battle_prep_music",
		tools_import_battle_music = "battle_music"
	}

	for id, mode in pairs(button_modes) do
		local button = wid(id)
		if button then
			if active_mode == mode then
				button:activate()
			else
				button:deactivate()
			end
		end
	end
end

function gui:compact_entities_panel()
	local entities_deselected = wid("entities_deselected")
	if not entities_deselected or not entities_deselected.children then
		return
	end

	local show_btn = wid("entities_show")
	if show_btn and show_btn.parent then
		local row = show_btn.parent
		row:remove_child(show_btn)
		if #row.children == 0 and row.parent then
			row.parent:remove_child(row)
		end
	end

	local hide_btn = wid("entities_hide")
	if hide_btn and hide_btn.parent then
		local row = hide_btn.parent
		row:remove_child(hide_btn)
		if #row.children == 0 and row.parent then
			row.parent:remove_child(row)
		end
	end

	entities_deselected:update_layout()
end

function gui:apply_fixed_tool_layout()
	local tools = wid("tools")
	local entities = wid("entities")
	local paths = wid("paths")
	local grid = wid("grid")
	local nav = wid("nav")

	if not tools then
		return
	end

	local margin_x = 28
	local margin_y = 88
	local gap_x = 18
	local right_x = margin_x + tools.size.x + gap_x

	tools.can_drag = false
	tools.pos = V.v(margin_x, margin_y)

	if entities then
		entities.can_drag = false
		entities.pos = V.v(right_x, margin_y)
	end

	if paths then
		paths.can_drag = false
		paths.pos = V.v(right_x, margin_y)
	end

	if grid then
		grid.can_drag = false
		grid.pos = V.v(right_x, margin_y)
	end

	if nav then
		nav.can_drag = false
	end
end

function gui:enhance_button_feedback()
	local function clone_color(c)
		return c and {c[1], c[2], c[3], c[4]} or nil
	end

	local function resolve_visual(v)
		local f = v._btn_feedback
		local active = v.active == true or v.value == true

		if v._btn_feedback_pressed then
			return f.pressed
		elseif active then
			return v._btn_feedback_hovered and f.active_hover or f.active
		else
			return v._btn_feedback_hovered and f.hover or f.normal
		end
	end

	local function apply_visual(v)
		local visual = resolve_visual(v)

		if visual and v.colors then
			v.colors.background = clone_color(visual)
		end
	end

	local function hook_button(v)
		if not is_kbutton_instance(v) then
			return
		end

		if not v.colors then
			v.colors = {}
		end

		local normal = clone_color(v.colors.background) or {0, 0, 0, 40}
		local alpha = normal[4] or 255

		v._btn_feedback = {
			normal = normal,
			hover = {math.min(255, normal[1] + 34), math.min(255, normal[2] + 34), math.min(255, normal[3] + 34), alpha},
			active = {math.min(255, normal[1] + 72), math.min(255, normal[2] + 72), math.min(255, normal[3] + 24), alpha},
			active_hover = {math.min(255, normal[1] + 96), math.min(255, normal[2] + 96), math.min(255, normal[3] + 48), alpha},
			pressed = {math.max(0, normal[1] - 18), math.max(0, normal[2] - 18), math.max(0, normal[3] - 18), alpha}
		}
		v._btn_feedback_hovered = false
		v._btn_feedback_pressed = false
		v._btn_feedback_scale = V.v(v.scale.x, v.scale.y)

		local orig_enter = v.on_enter
		v.on_enter = function(self, ...)
			self._btn_feedback_hovered = true
			apply_visual(self)

			if orig_enter then
				return orig_enter(self, ...)
			end
		end

		local orig_exit = v.on_exit
		v.on_exit = function(self, ...)
			self._btn_feedback_hovered = false
			self._btn_feedback_pressed = false
			if self._btn_feedback_tween and gui.window and gui.window.timer then
				gui.window.timer:cancel(self._btn_feedback_tween)
				self._btn_feedback_tween = nil
			end
			self.scale = V.v(self._btn_feedback_scale.x, self._btn_feedback_scale.y)
			apply_visual(self)

			if orig_exit then
				return orig_exit(self, ...)
			end
		end

		local orig_down = v.on_down
		v.on_down = function(self, ...)
			self._btn_feedback_pressed = true
			local tx, ty = self._btn_feedback_scale.x * 0.96, self._btn_feedback_scale.y * 0.96

			if gui.window and gui.window.timer and gui.window.timer.tween then
				if self._btn_feedback_tween then
					gui.window.timer:cancel(self._btn_feedback_tween)
				end

				self._btn_feedback_tween = gui.window.timer:tween(0.06, self.scale, {
					x = tx,
					y = ty
				}, "out-quad")
			else
				self.scale = V.v(tx, ty)
			end

			apply_visual(self)

			if orig_down then
				return orig_down(self, ...)
			end
		end

		local orig_up = v.on_up
		v.on_up = function(self, ...)
			self._btn_feedback_pressed = false
			local tx, ty = self._btn_feedback_scale.x, self._btn_feedback_scale.y

			if gui.window and gui.window.timer and gui.window.timer.tween then
				if self._btn_feedback_tween then
					gui.window.timer:cancel(self._btn_feedback_tween)
				end

				self._btn_feedback_tween = gui.window.timer:tween(0.08, self.scale, {
					x = tx,
					y = ty
				}, "out-back")
			else
				self.scale = V.v(tx, ty)
			end

			apply_visual(self)

			if orig_up then
				return orig_up(self, ...)
			end
		end

		apply_visual(v)
	end

	local function walk(v)
		hook_button(v)

		if v.children then
			for _, c in pairs(v.children) do
				walk(c)
			end
		end
	end

	walk(self.window)
end

function gui:destroy()
	self.window:destroy()

	self.window = nil
end

function gui:update(dt)
	self.window:update(dt)
	-- 更新 hump timer（PopUpView 动画需要）
	self.window.timer:update(dt)

	if self._save_notification and self._save_notification_ts then
		if love.timer.getTime() - self._save_notification_ts > 2.5 then
			local notif = self._save_notification
			notif.hidden = true
			self.window:remove_child(notif)
			self._save_notification = nil
			self._save_notification_ts = nil
		end
	end

	-- 更新实体自动补全
	self._active_entity_prop = nil
	local template_prop = wid("entities_insert_template")
	if template_prop and template_prop.is_focused then
		self._active_entity_prop = template_prop
	end
	local active_id = self._active_entity_prop and tostring(self._active_entity_prop) or ""
	local active_val = self._active_entity_prop and tostring(self._active_entity_prop.value or "") or ""
	local key = active_id .. "|" .. active_val .. "|" .. tostring(self._entity_hint_index) .. "|" .. tostring(self._entity_hint_offset)
	if key ~= self._entity_hint_cache_key then
		self._entity_hint_cache_key = key
		self:_rebuild_entity_hint()
	end
end

function gui:draw()
	self.window:draw()
end

function gui:keypressed(key, isrepeat)
	self.window:keypressed(key, isrepeat)
end

function gui:keyreleased(key)
	local responder = self.window and self.window.responder
	if responder and responder.is_focused then
		if key == "return" or key == "kpenter" or key == "escape" then
			if responder.set_input_focused then
				responder:set_input_focused(false)
			end
			self.window:set_responder()
		else
			return
		end
	end

	if self.window:keyreleased(key) then
		return
	elseif self.tool_shortcuts then
		local shortcuts = self.tool_shortcuts[self.active_tool]

		if shortcuts and shortcuts[key] then
			shortcuts[key]()
		end
	end
end

function gui:textinput(t)
	self.window:textinput(t)
end

function gui:mousepressed(x, y, button)
	if button == 2 and self.active_tool == "entities" and self.editor.entities_selected then
		self:select_entity(nil)
	end

	self.window:mousepressed(x, y, button)
end

function gui:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function gui:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
	local popups = {{
		v = self._wave_editor,
		fn = "_on_scroll"
	}, {
		v = self._wave_config_view,
		fn = "_on_scroll"
	}, {
		v = self._preview_editor,
		fn = "_on_scroll"
	}, {
		v = self._enemy_glossary,
		fn = "_on_scroll"
	}}
	for _, p in ipairs(popups) do
		if p.v and not p.v.hidden then
			local method = p.v[p.fn]
			if method then
				method(p.v, dy)
			end
		end
	end
end

function gui:show_wave_editor()
	if not self.editor.store.level then
		self:show_save_notification("请先加载一个关卡")
		return
	end
	if self._wave_editor and not self._wave_editor.hidden then
		self._wave_editor.hidden = true
		return
	end
	local WaveEditorView = require("game_editor_wave_editor")
	local view = WaveEditorView:new(self.sw, self.sh, self.editor)
	self.window:add_child(view)
	self._wave_editor = view
	view:show()
end

function gui:show_wave_config()
	if not self.editor.store.level then
		self:show_save_notification("请先加载一个关卡")
		return
	end
	local WaveConfigView = require("game_editor_wave_config")
	local view = WaveConfigView:new(self.sw, self.sh, self.editor)
	self.window:add_child(view)
	self._wave_config_view = view
	view:show()
end

function gui:show_export_view()
	if not self.editor.store.level then
		self:show_save_notification("请先加载一个关卡")
		return
	end
	local EditorExportView = require("game_editor_export")
	local view = EditorExportView:new(self.sw, self.sh, self.editor)
	self.window:add_child(view)
	view:show()
end

function gui:g2u(p, snap)
	local sx = (p.x * self.editor.game_scale + self.editor.game_ref_origin.x - self.window.origin.x) / self.scale
	local sy = (-1 * (p.y * self.editor.game_scale + self.editor.game_ref_origin.y - self.sh * self.scale) - self.window.origin.y) / self.scale

	if snap then
		sx, sy = math.floor(sx + 0.5), math.floor(sy + 0.5)
	end

	return sx, sy
end

function gui:u2g(s)
	local px = (s.x * self.scale + self.window.origin.x - self.editor.game_ref_origin.x) / self.editor.game_scale
	local py = (self.sh * self.scale - (s.y * self.scale + self.window.origin.y) - self.editor.game_ref_origin.y) / self.editor.game_scale

	return px, py
end

function gui:level_loaded(level_idx)
	wid("tools_level_name"):set_value(level_idx)
	self:update_paths_list()
	self:update_grid_tool()
	self:refresh_nav_tool()
end

function gui:pointer_pos_label_update(this, dt)
	local x, y = love.mouse.getPosition()
	x, y = self:u2g(V.v(x, y))
	this.lt.text = string.format("%s,%s", x, y)
end

function gui:hide_tool(name)
	local v = self.window:get_child_by_id(name)

	v.hidden = true

	self:deselect_tool(name)

	if name == "grid" then
		self.editor.grid_visible = nil
		self.editor.grid_dirty = nil
	elseif name == "entities" then
		self.editor.entities_visible = nil
		self.editor.entities_dirty = nil
	elseif name == "paths" then
		self.editor.paths_visible = nil
		self.editor.paths_dirty = nil
		self.editor.path_selected = nil
	elseif name == "nav" then
		self.editor.nav_visible = nil
		self.editor.nav_dirty = nil
		self.editor.nav_entity_selected = nil
	end

	self.active_tool = nil
end

function gui:show_tool(name)
	if not self.editor.store.level then
		return
	end

	local v = self.window:get_child_by_id(name)

	for _, n in pairs(self.tool_names) do
		if n ~= name then
			local ov = self.window:get_child_by_id(n)
			if ov and not ov.hidden then
				self:hide_tool(n)
			end
		end
	end

	v.hidden = nil

	self:select_tool(name)

	if name == "grid" then
		self.editor.grid_visible = true
		self.editor.grid_dirty = true

		self:update_grid_tool()
	elseif name == "entities" then
		self.editor.entities_visible = true
		self.editor.entities_dirty = true
	elseif name == "paths" then
		self.editor.paths_visible = true
		self.editor.paths_dirty = true
		self.editor.path_selected = nil

		self:update_paths_list()
	elseif name == "nav" then
		self.editor.nav_visible = true
		self.editor.nav_dirty = true
	end

	self:apply_fixed_tool_layout()
end

function gui:toggle_tool(name)
	local v = self.window:get_child_by_id(name)

	if v.hidden then
		self:show_tool(name)
	else
		self:hide_tool(name)
	end
end

function gui:deselect_tool(name)
	set_gui_responder(self.window)

	local v = self.window:get_child_by_id(name)

	if v.children[2] then
		v.children[2].colors.background = {220, 220, 220, 255}
	end

	if name == "grid" then
		self.editor.grid_brush = nil
	end
end

function gui:select_tool(name)
	for _, n in pairs(self.tool_names) do
		if n ~= name then
			self:deselect_tool(n)
		end
	end

	self.active_tool = name

	local v = self.window:get_child_by_id(name)

	if v.children[2] then
		v.children[2].colors.background = {255, 255, 200, 255}
	end

	if name == "entities" then
		set_gui_responder(self.window)
	end
end

function gui:click_tool(btn, x, y)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "grid" and not wid("grid").hidden then
		self:grid_paint(wx, wy, btn)
	elseif self.active_tool == "entities" and not wid("entities").hidden then
		if btn == 2 then
			self:select_entity(nil)
			return
		end

		local cb = self.select_entity

		self:entities_select(wx, wy, cb, 12)
	elseif self.active_tool == "nav" then
		local cb = self.select_entity_nav

		self:entities_select(wx, wy, cb, 24)
	end
end

function gui:down_tool(btn, x, y)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "paths" and not wid("paths").hidden then
		if btn == 2 then
			self.path_dragging = false
			self:select_node()
			return
		end

		local selected = self:path_nodes_select(wx, wy)
		self.path_dragging = selected and btn == 1

		if not selected then
		-- block empty
		end
	end
end

function gui:up_tool(btn, x, y)
	if self.active_tool == "paths" then
		self.path_dragging = false
	end
end

function gui:move_tool(x, y, down)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "grid" and not wid("grid").hidden then
		self.editor.tool_pointer.tool = "grid"
		self.editor.tool_pointer.x = wx
		self.editor.tool_pointer.y = wy
		self.editor.tool_pointer.size = self.settings.grid.brush_size

		if down then
			self:grid_paint(wx, wy, down)
		end
	elseif self.active_tool == "entities" and not wid("entities").hidden then
		if down and self.editor.entities_selected then
			self:entities_move(wx, wy)
		end
	elseif self.active_tool == "paths" and not wid("paths").hidden then
		if down and self.path_dragging and self.path_nodes_selected then
			self:path_nodes_move(wx, wy)
		end
	else
		self.editor.tool_pointer.tool = nil
	end
end

function gui:undo()
	self:select_entity()
	self:select_node()
	self.editor:undo_pop()

	if self.active_tool == "paths" then
		self:update_paths_list()
		self:show_path_node()
	elseif self.active_tool == "grid" then
		self:update_grid_tool()
	end
end

function gui:grid_cell_info_update(this, dt)
	local x, y = love.mouse.getPosition()
	local wx, wy = self:u2g(V.v(x, y))
	local ct, i, j = GR:cell_type(wx, wy)
	local terrain = band(ct, TERRAIN_TYPES_MASK)
	local terrain_name = ({
		[TERRAIN_NONE] = "无",
		[TERRAIN_LAND] = "陆地",
		[TERRAIN_WATER] = "水",
		[TERRAIN_CLIFF] = "悬崖"
	})[terrain] or "未知"
	local tags = {}

	if band(ct, TERRAIN_NOWALK) ~= 0 then
		tags[#tags + 1] = "禁行"
	end
	if band(ct, TERRAIN_SHALLOW) ~= 0 then
		tags[#tags + 1] = "浅滩"
	end
	if band(ct, TERRAIN_FAERIE) ~= 0 then
		tags[#tags + 1] = "仙子"
	end
	if band(ct, TERRAIN_ICE) ~= 0 then
		tags[#tags + 1] = "冰"
	end
	if band(ct, TERRAIN_FLYING_NOWALK) ~= 0 then
		tags[#tags + 1] = "禁飞"
	end
	if #tags == 0 then
		tags[1] = "无"
	end

	this.lt.text = string.format("%s,%s", i, j)
	this.gt.text = string.format("%s|%s", terrain_name, table.concat(tags, "+"))
end

function gui:set_grid_paint_type(type)
	local buttons = {
		[TERRAIN_NONE] = "none",
		[TERRAIN_LAND] = "land",
		[TERRAIN_WATER] = "water",
		[TERRAIN_CLIFF] = "cliff"
	}

	for k, n in pairs(buttons) do
		if k == type then
			self.window:get_child_by_id("paint_type_" .. n):activate()
		else
			self.window:get_child_by_id("paint_type_" .. n):deactivate()
		end
	end

	local p = self.settings.grid.paint

	p = bit.band(p, TERRAIN_PROPS_MASK)
	self.settings.grid.paint = bit.bor(type, p)
end

function gui:toggle_grid_paint_flag(flag)
	local buttons = {
		[TERRAIN_SHALLOW] = "shallow",
		[TERRAIN_NOWALK] = "nowalk",
		[TERRAIN_FAERIE] = "faerie",
		[TERRAIN_ICE] = "ice"
	-- [TERRAIN_FLYING_NOWALK] = "flying_nw"
	}

	for k, n in pairs(buttons) do
		if k == flag then
			local b = self.window:get_child_by_id("paint_flag_" .. n)

			if b.active then
				b:deactivate()

				self.settings.grid.paint = bit.band(self.settings.grid.paint, bit.bnot(flag))
			else
				b:activate()

				self.settings.grid.paint = bit.bor(self.settings.grid.paint, flag)
			end
		end
	end
end

function gui:grid_brush_size_change(value)
	local b = self.settings.grid.brush_size

	b = b + value
	self.settings.grid.brush_size = km.clamp(1, 21, b)
end

function gui:grid_paint(wx, wy, btn)
	local s = self.settings.grid
	local bw = (s.brush_size - 1) / 2
	local temp_brush = s.paint
	local picker = wid("picker")

	self.editor:undo_push_grid(picker and picker.tracking)

	if btn == "2" then
		local f = TERRAIN_NOWALK
		local fs = bit.band(s.paint, f)

		fs = bit.band(bit.bnot(fs), f)
		temp_brush = bit.bor(bit.band(s.paint, bit.bnot(f)), fs)
	end

	for i = -bw, bw do
		for j = -bw, bw do
			local bx, by = wx + i * GR.cell_size, wy + j * GR.cell_size

			GR:set_cell_type(bx, by, temp_brush)
		end
	end

	self.editor.grid_dirty = true
end

function gui:update_grid_prop(prop_view)
	local prop_name = prop_view.prop_name
	self.editor:undo_push_grid(false)

	if prop_name == "grid_size" then
		GR:set_grid_size(prop_view.value.x, prop_view.value.y)
	elseif prop_name == "grid_offset" then
		GR:set_grid_offset(prop_view.value.x, prop_view.value.y)
	end

	self.editor.grid_dirty = true
end

function gui:ensure_grid_layer_toggle_buttons()
	local grid_view = wid("grid")
	local layout = grid_view and grid_view.children and grid_view.children[3]
	if not layout or wid("grid_show_mode") then
		return
	end

	for i = #layout.children, 1, -1 do
		local c = layout.children[i]
		if c and c.class and c.class.name == "KESep" and c.text == "网格" then
			layout:remove_child(c)
			break
		end
	end

	local row = KELayout:new("vertical")
	row.size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
	row.separation = V.v(0, 0)

	local mode_btn = KEButton:new("显示：地形和标签")
	mode_btn.id = "grid_show_mode"
	mode_btn.size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
	mode_btn.text_size = V.v(KE_CONST.PROP_W, KE_CONST.PROP_H)
	mode_btn.text_offset = V.v(0, (KE_CONST.PROP_H - KE_CONST.font_size) / 2)
	mode_btn.text_align = "center"
	fit_button_text(mode_btn)
	row:add_child(mode_btn)

	layout:add_child(row)

	mode_btn.on_click = function()
		local st = self.settings.grid.show_terrain
		local sg = self.settings.grid.show_tags
		if st and sg then
			self.settings.grid.show_terrain = true
			self.settings.grid.show_tags = false
		elseif st then
			self.settings.grid.show_terrain = false
			self.settings.grid.show_tags = true
		else
			self.settings.grid.show_terrain = true
			self.settings.grid.show_tags = true
		end
		self:update_grid_layer_toggle_state()
		self.editor.grid_dirty = true
	end

	layout:update_layout()
	self:update_grid_layer_toggle_state()
end

function gui:update_grid_layer_toggle_state()
	local mode_btn = wid("grid_show_mode")
	if mode_btn then
		local st = self.settings.grid.show_terrain
		local sg = self.settings.grid.show_tags
		if st and sg then
			mode_btn.text = "显示：地形和标签"
		elseif st then
			mode_btn.text = "显示：仅地形"
		elseif sg then
			mode_btn.text = "显示：仅标签"
		else
			mode_btn.text = "显示：地形和标签"
			self.settings.grid.show_terrain = true
			self.settings.grid.show_tags = true
		end
		mode_btn:activate()
	end
end

function gui:update_grid_tool()
	wid("grid_size"):set_value(V.v(GR.grid_w, GR.grid_h), true)
	wid("grid_offset"):set_value(V.v(GR.ox, GR.oy), true)
	self:update_grid_layer_toggle_state()
end

function gui:refresh_nav_tool()
	local editor = self.editor

	if editor.store.level_mode == 1 then
		wid("nav_mode_override_active").on_change = nil

		wid("nav_mode_override_active"):set_value(false)
		wid("nav_mode_override_active"):disable()
	else
		wid("nav_mode_override_active").active_title = "mesh for mode " .. editor.store.level_mode
		wid("nav_mode_override_active").on_change = nil

		if editor.store.level.data.level_mode_overrides[editor.store.level_mode].nav_mesh then
			wid("nav_mode_override_active"):set_value(true)
		else
			wid("nav_mode_override_active"):set_value(false)
		end

		wid("nav_mode_override_active").on_change = function(this)
			gui:nav_mode_override_change(this)
		end

		wid("nav_mode_override_active"):enable()
	end
end

function gui:entities_select(wx, wy, callback, size)
	local e
	local es = self.editor:entities_at_pos(wx, wy, size)

	log.debug("es:%s", es and getdump(es) or "-")

	if es and #es > 0 then
		local idx = 1
		local prev = self.editor.entities_selected and self.editor.store.entities[self.editor.entities_selected[1]] or nil

		if prev then
			local prev_idx = table.keyforobject(es, prev)

			if prev_idx ~= nil then
				idx = km.zmod(prev_idx + 1, #es)
			end
		end

		e = es[idx]
	end

	callback(self, e, es)
end

function gui:select_entity(e)
	local get_prop = LU.eval_get_prop
	local vs = wid("entities_selected")
	local vd = wid("entities_deselected")

	if e then
		self.editor.entities_selected = {e.id}
		vd.hidden = true
		vs.hidden = false

		wid("entities_id"):set_value(e.id)
		wid("entities_template"):set_value(e.template_name)

		if e.pos then
			wid("entities_pos"):set_value(e.pos)
		end

		local cv = wid("entities_custom_props")

		cv:remove_children()

		if e.editor and e.editor.props then
			for _, prop in pairs(e.editor.props) do
				local prop_name, prop_type, prop_custom = unpack(prop)
				local v

				if prop_type == PT_STRING then
					v = KEProp:new(prop_name, get_prop(e, prop_name))
				elseif prop_type == PT_COORDS then
					v = KEPropCoords:new(prop_name, get_prop(e, prop_name))
				elseif prop_type == PT_NUMBER then
					v = KEPropNum:new(prop_name, get_prop(e, prop_name), prop_custom)
				else
					log.error("Property:%s unknown property type: %s", prop_name, prop_type)
				end

				if v then
					v.prop_name = prop_name

					function v.on_change(this)
						gui:update_entity_prop(this)
					end

					cv:add_child(v)
				end
			end

			cv:update_layout()
		end

		set_gui_responder(self.window)
	else
		self.editor.entities_selected = nil
		vs.hidden = true
		vd.hidden = false

		set_gui_responder(self.window)
	end

	self.editor.entities_dirty = true
end

function gui:update_entity_prop(prop_view)
	local set_prop = LU.eval_set_prop
	local get_prop = LU.eval_get_prop
	local prop_name = prop_view.prop_name
	local prop_type = prop_view.prop_type

	if not prop_name or not prop_type then
		log.error("Property view %s has no prop_name or prop_type", prop_view)

		return
	end

	local eid = self.editor.entities_selected and self.editor.entities_selected[1]

	if not eid then
		return
	end

	local e = self.editor.store.entities[eid]

	if not e then
		return
	end

	local prop_value = prop_view.value
	local picker = wid("picker")

	if not self._last_prop_value then
		self._last_prop_value = V.v(prop_value.x, prop_value.y)
	end

	if prop_type == PT_COORDS then
		local state = self.are_axes_in_range(prop_value, self._last_prop_value)

		if state then
			self.editor:undo_push_entity(picker.tracking, e.id, prop_name .. ".x", get_prop(e, prop_name .. ".x"), prop_name .. ".y", get_prop(e, prop_name .. ".y"))
			set_prop(e, prop_name .. ".x", prop_value.x)
			set_prop(e, prop_name .. ".y", prop_value.y)

			self._last_prop_value.x = prop_value.x
			self._last_prop_value.y = prop_value.y
		end
	else
		self.editor:undo_push_entity(picker.tracking, e.id, prop_name, get_prop(e, prop_name), picker.tracking)
		set_prop(e, prop_name, prop_value)
	end

	self.editor.entities_dirty = true
end

function gui:entities_move(wx, wy)
	local eid = self.editor.entities_selected and self.editor.entities_selected[1]

	if not eid then
		return
	end

	local p = wid("entities_pos")

	p:set_value(V.v(wx, wy))
end

function gui:move_entity(direction)
	local eid = self.editor.entities_selected and self.editor.entities_selected[1]

	if not eid then
		return
	end

	local step = love.keyboard.isDown("lshift", "rshift") and 10 or 1
	local dx = direction == "left" and -step or direction == "right" and step or 0
	local dy = direction == "down" and -step or direction == "up" and step or 0
	local p = wid("entities_pos")

	p:set_value(V.v(V.add(p.value.x, p.value.y, dx, dy)))
end

function gui:hide_template()
	local template = wid("entities_insert_template").value

	if not template or not E:get_template(template) then
		return
	end

	for _, e in pairs(self.editor.store.entities) do
		if e.template_name == template and e.render then
			U.sprites_hide(e)
		end
	end

	self.editor.entities_dirty = true
end

function gui:show_template()
	local template = wid("entities_insert_template").value

	if not template or not E:get_template(template) then
		return
	end

	for _, e in pairs(self.editor.store.entities) do
		if e.template_name == template and e.render then
			U.sprites_show(e)
		end
	end

	self.editor.entities_dirty = true
end

function gui:show_save_notification(text, is_success)
	if self._save_notification then
		self._save_notification.hidden = true
		self.window:remove_child(self._save_notification)
		self._save_notification = nil
	end

	local notif = KView:new(V.v(320, 44))
	notif.colors.background = is_success and {28, 125, 66, 230} or {170, 64, 64, 230}
	notif.pos = V.v(math.floor((self.sw - 320) / 2), 72)
	notif.anchor = V.v(0, 0)

	local label = KLabel:new(V.v(320, 44))
	label.text = text
	label.text_align = "center"
	label.font_name = KE_CONST.font_name
	label.font_size = KE_CONST.font_size
	label.text_offset = V.v(0, 13)
	label.colors.text = {255, 255, 255, 255}
	notif:add_child(label)

	self.window:add_child(notif)
	self._save_notification = notif
	self._save_notification_ts = love.timer.getTime()
end

function gui:_setup_entity_autocomplete()
	local entities_panel = wid("entities")
	if not entities_panel then
		return
	end

	-- 创建实体提示下拉框
	local hint_w, hint_h = 320, 170
	self._entity_hint = KView:new(V.v(hint_w, hint_h))
	self._entity_hint.colors.background = {245, 245, 245, 255}
	self._entity_hint.hidden = true
	self._entity_hint.clip = true
	self.window:add_child(self._entity_hint)

	self._entity_hint_content = KView:new(V.v(self._entity_hint.size.x, 0))
	self._entity_hint:add_child(self._entity_hint_content)

	self._entity_hint_index = 1
	self._entity_hint_items = {}
	self._entity_hint_all = {}
	self._entity_hint_offset = 1
	self._active_entity_prop = nil
	self._entity_rows = nil

	-- 绑定实体模板输入框的按键处理
	local template_prop = wid("entities_insert_template")
	if template_prop then
		self:_bind_entity_template_keys(template_prop)
	end
end

function gui:_ensure_entity_rows()
	if self._entity_rows then
		return
	end
	E:ensure_loaded()
	self._entity_rows = {}
	for name, tpl in pairs(E.entities or {}) do
		self._entity_rows[#self._entity_rows + 1] = {
			name = name
		}
	end
	table.sort(self._entity_rows, function(a, b)
		return a.name < b.name
	end)
end

function gui:_bind_entity_template_keys(prop)
	local owner = self
	function prop.on_keypressed(this, key)
		if owner._entity_hint and not owner._entity_hint.hidden and #owner._entity_hint_all > 0 then
			if key == "down" then
				owner._entity_hint_index = math.min(#owner._entity_hint_all, owner._entity_hint_index + 1)
				owner:_refresh_entity_hint_focus()
				return true
			elseif key == "up" then
				owner._entity_hint_index = math.max(1, owner._entity_hint_index - 1)
				owner:_refresh_entity_hint_focus()
				return true
			elseif key == "return" or key == "kpenter" then
				owner:_accept_entity_hint(owner._entity_hint_all[owner._entity_hint_index].name)
				return true
			elseif key == "escape" then
				owner._entity_hint.hidden = true
				return true
			end
		end
		return KEProp.on_keypressed(this, key)
	end
end

function gui:_rebuild_entity_hint()
	self:_ensure_entity_rows()
	local prop = self._active_entity_prop
	if not prop or prop.hidden or not prop.is_focused then
		self._entity_hint.hidden = true
		return
	end
	local text = tostring(prop.value or "")
	local prefix = text:match("([^,%s]*)$") or ""
	local low = string.lower(prefix)
	if low == "" then
		self._entity_hint.hidden = true
		return
	end
	self._entity_hint_all = {}
	for _, row in ipairs(self._entity_rows) do
		if string.find(string.lower(row.name), low, 1, true) then
			self._entity_hint_all[#self._entity_hint_all + 1] = row
		end
	end
	if #self._entity_hint_all == 0 then
		self._entity_hint.hidden = true
		return
	end
	self._entity_hint_index = math.max(1, math.min(self._entity_hint_index or 1, #self._entity_hint_all))
	self._entity_hint_offset = math.max(1, math.min(self._entity_hint_offset or 1, self._entity_hint_index))
	self:_render_entity_hint_items()
	self._entity_hint.hidden = false

	local entities_panel = wid("entities")
	if not entities_panel then
		self._entity_hint.hidden = true
		return
	end
	local left = entities_panel.pos.x + prop.pos.x
	local top = entities_panel.pos.y + prop.pos.y
	local text_w = G.getFont():getWidth(tostring(prop.value or ""))
	local px = math.min(self.sw - self._entity_hint.size.x - 12, left + 8 + text_w)
	local py = top + prop.size.y + 30
	if py + self._entity_hint.size.y > self.sh - 8 then
		py = top - self._entity_hint.size.y - 30
	end
	py = math.max(38, py)
	self._entity_hint.pos = V.v(px, py)
end

function gui:_render_entity_hint_items()
	self._entity_hint_content:remove_children()
	self._entity_hint_items = {}
	local row_h = 26
	local max_rows = math.max(1, math.floor((self._entity_hint.size.y - 8) / row_h))
	local max_offset = math.max(1, #self._entity_hint_all - max_rows + 1)
	self._entity_hint_offset = math.max(1, math.min(self._entity_hint_offset, max_offset))
	local y = 4
	for i = self._entity_hint_offset, math.min(#self._entity_hint_all, self._entity_hint_offset + max_rows - 1) do
		local row = self._entity_hint_all[i]
		local btn = KButton:new(V.v(self._entity_hint.size.x - 8, 24))
		btn.pos = V.v(4, y)
		btn.text = row.name
		btn.text_align = "left"
		btn.colors.background = {236, 236, 236, 255}
		btn.colors.text = {20, 20, 20, 255}
		function btn.on_click()
			self:_accept_entity_hint(row.name)
		end
		self._entity_hint_content:add_child(btn)
		self._entity_hint_items[#self._entity_hint_items + 1] = {
			name = row.name,
			idx = i,
			btn = btn
		}
		y = y + row_h
	end
	self._entity_hint_content.size = V.v(self._entity_hint.size.x, y + 4)
	self:_refresh_entity_hint_focus()
end

function gui:_refresh_entity_hint_focus()
	for _, item in ipairs(self._entity_hint_items) do
		if item.idx == self._entity_hint_index then
			item.btn.colors.background = {200, 200, 255, 255}
		else
			item.btn.colors.background = {236, 236, 236, 255}
		end
	end
end

function gui:_accept_entity_hint(name)
	local prop = self._active_entity_prop
	if not prop or not name then
		return
	end
	prop:set_value(name)
	self._entity_hint.hidden = true
	self._entity_hint_all = {}
end

function gui:insert_entity()
	local template = wid("entities_insert_template").value

	if not template or not E:get_template(template) then
		self:show_save_notification("模板不存在，无法插入", false)
		return
	end

	local e = E:create_entity(template)
	local mx, my = love.mouse.getPosition()
	local wx, wy = self:u2g(V.v(mx, my))

	e.pos.x, e.pos.y = wx, wy

	self.editor:undo_push_entity_insert(e.id)
	LU.queue_insert(self.editor.store, e)
	self.editor.entities_dirty = true
	self:select_entity(e)
end

function gui:delete_entity()
	local eid = self.editor.entities_selected and self.editor.entities_selected[1]

	if not eid then
		return
	end

	local e = self.editor.store.entities[eid]

	if not e then
		return
	end

	self.editor:undo_push_entity_delete(e)
	LU.queue_remove(self.editor.store, e)

	local list = self.editor.store.level.data.entities_list
	if list then
		if not list._idx then
			list._idx = {}
			for _, item in pairs(list) do
				local iid = item and (item._id or item.id)
				if iid then
					list._idx[iid] = item
				end
			end
		end

		local le = list._idx[e.id]
		if le then
			table.removeobject(list, le)
			list._idx[e.id] = nil
		end
	end

	self:select_entity(nil)
end

function gui:duplicate_entity()
	local eid = self.editor.entities_selected and self.editor.entities_selected[1]

	if not eid then
		return
	end

	local e = self.editor.store.entities[eid]

	if not e then
		return
	end

	local de = E:create_entity(e.template_name)

	de.pos = V.v(e.pos.x, e.pos.y - 50)

	if e.editor and e.editor.props then
		for _, item in pairs(e.editor.props) do
			local k, kt = unpack(item)

			if kt == PT_COORDS then
				local x = LU.eval_get_prop(e, k .. ".x")
				local y = LU.eval_get_prop(e, k .. ".y")

				LU.eval_set_prop(de, k .. ".x", x)
				LU.eval_set_prop(de, k .. ".y", y)
			else
				local v = LU.eval_get_prop(e, k)

				LU.eval_set_prop(de, k, v)
			end
		end
	end

	LU.queue_insert(self.editor.store, de)
	self:select_entity(de)
end

function gui:update_paths_list()
	local list = wid("paths_list")

	list:clear_rows()

	local paths = self.editor.path_curves

	if not paths then
		return
	end

	for i, path in ipairs(paths) do
		local l = KLabel:new(V.v(list.size.x, 20))

		l.text_align = "left"
		l.text = tostring(i)

		function l.on_click()
			self:select_node(i, 1)
		end

		list:add_row(l)
	end
end

function gui:select_list_path(pi)
	local list = wid("paths_list")

	for i, v in ipairs(list.children) do
		if i == pi then
			v.colors.background = {0, 0, 0, 40}
		else
			v.colors.background = {0, 0, 0, 0}
		end
	end
end

function gui:select_node(pi, ni, add)
	if pi and ni then
		local sel = {pi, ni}

		if add and self.path_nodes_selected then
			table.insert(self.path_nodes_selected, sel)
		else
			self.path_nodes_selected = {sel}

			self:select_list_path(pi)
		end

		self:show_path_node(unpack(sel))

		self.editor.path_selected = pi
	else
		self.path_nodes_selected = nil
		self.path_dragging = false

		self:show_path_node()
	-- self.editor.path_selected = nil
	-- self:select_list_path()
	end

	self.editor.paths_dirty = true
end

function gui:path_nodes_select(x, y, w, h)
	log.debug("x:%s,y%s,w:%s,h:%s", x, y, w, h)

	if not w or not h then
		w, h = NODE_SELECTION_WINDOW * 2, NODE_SELECTION_WINDOW * 2
		x, y = x - w / 2, y - h / 2
	end

	local r = V.r(x, y, w, h)
	local lpi = self.editor.path_selected

	self:select_node()

	for pi, path in ipairs(self.editor.path_curves) do
		if not lpi or lpi == pi then
			local n = path.nodes

			for ni = 1, #n, 3 do
				if V.is_inside(n[ni], r) then
					self:select_node(pi, ni, true)
				end
			end
		end
	end

	return self.path_nodes_selected and #self.path_nodes_selected > 0 or false
end

function gui:show_path_node(pi, ni)
	if not pi or not ni then
		wid("paths_node_selected").hidden = true

		wid("paths_props"):update_layout()

		return
	end

	local path = self.editor.path_curves[pi]

	if not pi then
		log.error("Path id not found:%s", pi)

		return
	end

	local p = path.nodes[ni]

	if not p then
		log.error("Path node id not found:%s", ni)

		return
	end

	local node_type = (ni - 1) % 3 == 0 and "node" or "handle"
	local node_width

	if node_type == "node" then
		local wi = (ni - 1) / 3 + 1

		node_width = path.widths[wi]
	end

	wid("path_active"):set_value(self.editor.active_paths[pi])

	local cpi = -1

	if self.editor.path_connections and self.editor.path_connections[pi] then
		cpi = self.editor.path_connections[pi]
	end

	wid("path_connects_to"):set_value(cpi)
	local knot_idx = math.floor((ni - 1) / 3) + 1
	wid("path_node_id"):set_value(tostring(knot_idx), true)
	wid("path_node_pos"):set_value(p, true)

	if node_width then
		wid("path_node_width"):set_value(node_width, true)
	end

	wid("path_node_width").hidden = node_width == nil
	wid("paths_node_selected").hidden = false

	wid("paths_node_selected"):update_layout()
	wid("paths_props"):update_layout()
end

function gui:path_node_id_change(prop_view)
	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi = self.path_nodes_selected[1][1]
	local path = self.editor.path_curves[pi]
	if not path or not path.nodes or #path.nodes == 0 then
		return
	end

	local knot_idx = tonumber(prop_view.value)
	if not knot_idx then
		knot_idx = 1
	end

	local ni = (math.floor(knot_idx) - 1) * 3 + 1
	if ni < 1 or not path.nodes[ni] then
		ni = 1
	end

	self:select_node(pi, ni)
end

function gui:path_connects_to_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, prop_view.value)

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi = unpack(self.path_nodes_selected[1])
	local cpi = prop_view.value
	local current = self.editor.path_connections and self.editor.path_connections[pi] or nil
	if cpi < 1 or cpi > #self.editor.path_curves then
		cpi = nil
	end
	if current == cpi then
		return
	end

	self.editor:undo_push_paths(false)
	self.editor:set_path_connection(pi, cpi or -1)
end

function gui:path_active_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, prop_view.value)

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi = unpack(self.path_nodes_selected[1])
	local current = self.editor.active_paths and self.editor.active_paths[pi]
	if current == prop_view.value then
		return
	end

	self.editor:undo_push_paths(false)
	self.editor:set_path_active(pi, prop_view.value)
end

function gui:path_node_pos_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, getdump(prop_view.value))

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])
	if (ni - 1) % 3 ~= 0 then
		return
	end

	self.editor:undo_push_paths(false)
	self.editor:set_node_pos(pi, ni, prop_view.value.x, prop_view.value.y)
end

function gui:path_node_width_change(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:undo_push_paths(false)
	self.editor:set_node_width(pi, ni, view.value)
end

function gui:path_nodes_move(x, y, delta)
	log.debug()

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local picker = wid("picker")
	self.editor:undo_push_paths(delta and false or (picker and picker.tracking))

	if delta then
		local step = love.keyboard.isDown("lshift", "rshift") and 10 or 1

		for _, item in pairs(self.path_nodes_selected) do
			local pi, ni = unpack(item)
			if (ni - 1) % 3 ~= 0 then
				goto continue
			end
			local n = self.editor.path_curves[pi].nodes[ni]
			local nx, ny = n.x + x * step, n.y + y * step

			self.editor:set_node_pos(pi, ni, nx, ny)
			wid("path_node_pos"):set_value(V.v(nx, ny), true)
			::continue::
		end
	else
		local pi, ni = unpack(self.path_nodes_selected[1])
		if (ni - 1) % 3 ~= 0 then
			return
		end

		self.editor:set_node_pos(pi, ni, x, y)
		wid("path_node_pos"):set_value(V.v(x, y), true)
	end
end

function gui:path_node_modify(view, x, y)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])
	local path = self.editor.path_curves[pi]

	if path and path.nodes and path.nodes[ni] then
		if ni == 1 or ni == #path.nodes then
			self.editor:extend_path(pi, ni, x, y)

			local nni = ni == 1 and 1 or #path.nodes

			self.path_nodes_selected = {{pi, nni}}

			self:show_path_node(pi, nni)
		else
			self.editor:subdivide_path(pi, ni, x, y)

			local nni = ni + 1

			self.path_nodes_selected = {{pi, nni}}

			self:show_path_node(pi, nni)
		end
	end
end

function gui:path_node_add(view, x, y)
	local pi = self.editor.path_selected

	if not pi and self.path_nodes_selected and self.path_nodes_selected[1] then
		pi = self.path_nodes_selected[1][1]
	end

	self.editor:undo_push_paths(false)

	if not pi or not self.editor.path_curves[pi] then
		pi = self.editor:create_path()
		self.editor:clear_path_points(pi)
		self:update_paths_list()
	end

	local mx, my = love.mouse.getPosition()
	-- u2g 返回两个独立数值 px, py，不是向量
	local wpx, wpy = self:u2g(V.v(mx, my))

	self.editor:add_smooth_point(pi, wpx, wpy)

	local path = self.editor.path_curves[pi]
	local ni = path and path.nodes and #path.nodes or 1

	self:select_node(pi, ni)
end

function gui:path_node_subdivide_at_mouse()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		self:show_save_notification("请先选中一个路径点")
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])
	local path = self.editor.path_curves[pi]
	if not path or not path.user_points then
		return
	end

	-- 找到选中节点对应的 knot 索引
	local knot_idx = (ni - 1) / 3 + 1
	if knot_idx < 1 or knot_idx > #path.user_points then
		return
	end

	-- 在选中 knot 和下一个 knot 之间插入新点（鼠标位置）
	local mx, my = love.mouse.getPosition()
	local wpx, wpy = self:u2g(V.v(mx, my))
	self.editor:undo_push_paths(false)
	table.insert(path.user_points, knot_idx + 1, {
		x = wpx,
		y = wpy
	})
	self.editor:recalc_smooth_control_points(pi, path.user_points)

	-- 选中新插入的点
	local new_ni = knot_idx * 3 + 1 -- 新 knot 在 nodes 中的索引
	self:select_node(pi, new_ni)
end

function gui:path_node_remove(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])
	local path = self.editor.path_curves[pi]
	if not path then
		return
	end

	if not path.user_points or #path.user_points == 0 then
		path.user_points = {}
		for i = 1, #path.nodes, 3 do
			local p = path.nodes[i]
			if p then
				table.insert(path.user_points, {
					x = p.x,
					y = p.y
				})
			end
		end
	end

	local knot_idx = math.floor((ni - 1) / 3) + 1
	if knot_idx < 1 or knot_idx > #path.user_points then
		return
	end

	if #path.user_points <= 2 then
		return
	end

	self.editor:undo_push_paths(false)
	table.remove(path.user_points, knot_idx)
	self.editor:recalc_smooth_control_points(pi, path.user_points)

	local next_idx = math.min(knot_idx, #path.user_points)
	local next_ni = (next_idx - 1) * 3 + 1
	self:select_node(pi, next_ni)
end

function gui:flip_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi = unpack(self.path_nodes_selected[1])

	self.editor:undo_push_paths(false)
	self.editor:flip_path(pi)

	self.path_nodes_selected = {{pi, 1}}

	self:show_path_node(pi, 1)
end

function gui:move_path(inc)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi = unpack(self.path_nodes_selected[1])

	if pi + inc < 1 or pi + inc > #self.editor.path_curves then
		return
	end

	self.editor:undo_push_paths(false)
	self.editor:change_path_idx(pi, pi + inc)
	self:update_paths_list()
	self:select_node(pi + inc, 1)
end

function gui:create_path()
	self.editor:undo_push_paths(false)
	local pi = self.editor:create_path()

	self:update_paths_list()
	self:select_node(pi, 1)
end

function gui:duplicate_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	self.editor:undo_push_paths(false)
	local pi = unpack(self.path_nodes_selected[1])
	local npi = self.editor:duplicate_path(pi)
	self:update_paths_list()
	self:select_node(npi, 1)
end

function gui:remove_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	self.editor:undo_push_paths(false)
	local pi = unpack(self.path_nodes_selected[1])

	self.editor:remove_path(pi)
	self:update_paths_list()
	self:show_path_node()
end

function gui:preview_path(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi = unpack(self.path_nodes_selected[1])

	self.editor:preview_path_points(pi)
end

function gui:nav_mode_override_change(prop_view)
	log.debug("prop view:%s value:%s", prop_view, prop_view.value)

	local ov = self.editor.store.level.data.level_mode_overrides

	if prop_view.value then
		if not ov[self.editor.store.level_mode].nav_mesh then
			self.editor.store.level.data._before_ov.nav_mesh = table.deepclone(self.editor.store.level.nav_mesh)
		end

		ov[self.editor.store.level_mode].nav_mesh = self.editor.store.level.nav_mesh
	else
		ov[self.editor.store.level_mode].nav_mesh = nil
		self.editor.store.level.nav_mesh = self.editor.store.level.data._before_ov.nav_mesh

		self.editor:sanitize_nav_mesh(self.editor.store.level.nav_mesh)

		self.editor.nav_dirty = true
	end
end

function gui:select_entity_nav(e, es)
	if not e or not es then
		return
	end

	local v_dir_ids = {"nav_id_right", "nav_id_top", "nav_id_left", "nav_id_bottom"}

	if not e or not e.ui or not e.ui.nav_mesh_id then
		for _, ee in pairs(es) do
			if ee and ee.ui and ee.ui.nav_mesh_id then
				e = ee
			end
		end
	end

	if e and e.ui and e.ui.nav_mesh_id then
		self.editor.nav_entity_selected = e

		wid("nav_sel_id"):set_value(e.id)

		local lt_hid = tonumber(e.ui.nav_mesh_id)

		wid("nav_holder_id"):set_value(lt_hid)

		local nav_mesh = self.editor.store.level.nav_mesh

		self.editor:sanitize_nav_mesh(nav_mesh)

		local edges = nav_mesh[lt_hid]

		for i, n in pairs(v_dir_ids) do
			local w = wid(n)

			w.list = table.keys(nav_mesh)

			table.sort(w.list)

			local idx = table.keyforobject(w.list, edges[i] or -1)

			w:set_value(idx)
		end
	else
		self.editor.nav_entity_selected = nil

		wid("nav_sel_id"):set_value("")
		wid("nav_holder_id"):set_value("")

		for _, n in pairs(v_dir_ids) do
			local w = wid(n)

			w.list = {}

			w:set_value(nil)
		end
	end

	self.editor.nav_dirty = true
end

function gui.set_nav_mesh(view, edge_idx)
	local e = gui.editor.nav_entity_selected

	if not e or not e.ui then
		return
	end

	local nav_mesh = gui.editor.store.level.nav_mesh
	local nav_mesh_id = e.ui.nav_mesh_id

	if not nav_mesh_id then
		log.error("invalid nav_mesh_id:%s for entity (%s)%s", nav_mesh_id, e.id, e.template_name)

		return
	end

	local edge_value = view:get_value()

	if not edge_idx then
		log.error("invalid edge_idx:%s", edge_idx)

		return
	end

	nav_mesh_id = tonumber(nav_mesh_id)
	edge_idx = tonumber(edge_idx)
	nav_mesh[nav_mesh_id][edge_idx] = edge_value
	gui.editor.nav_dirty = true
end

function gui.assign_nearest_selected(e)
	return
end

function gui.assign_nearest_all()
	for _, e in pairs(gui.editor.store.entities) do
		if e.ui and e.ui.nav_mesh_id then
			gui.assign_nearest_selected(e)
		end
	end
end

function gui.clear_nav_all()
	for _, v in pairs(gui.editor.store.level.nav_mesh) do
		v = {}
	end

	gui.editor.nav_dirty = true
end

function gui.renumber_holders()
	local last_id = 0
	local pos_ids = {}

	for _, e in pairs(gui.editor.store.entities) do
		if e and e.ui and e.ui.has_nav_mesh then
			local se = string.format("%d,%d", e.pos.x, e.pos.y)

			if pos_ids[se] then
				e.ui.nav_mesh_id = pos_ids[se]
			else
				last_id = last_id + 1
				e.ui.nav_mesh_id = tostring(last_id)
				pos_ids[se] = tostring(last_id)
			end
		end
	end

	gui.clear_nav_all()
	gui.editor:sanitize_nav_mesh(gui.editor.store.level.nav_mesh)
end

function gui.adds_missing_numbers()
	local last_id = 0
	local pos_ids = {}

	for _, e in pairs(gui.editor.store.entities) do
		if e and e.ui and e.ui.has_nav_mesh and e.ui.nav_mesh_id then
			local id = tonumber(e.ui.nav_mesh_id)

			last_id = math.max(id, last_id)

			local se = string.format("%d,%d", e.pos.x, e.pos.y)

			if not pos_ids[se] then
				pos_ids[se] = tostring(last_id)
			end
		end
	end

	for _, e in pairs(gui.editor.store.entities) do
		if e and e.ui and e.ui.has_nav_mesh and not e.ui.nav_mesh_id then
			local se = string.format("%d,%d", e.pos.x, e.pos.y)

			if pos_ids[se] then
				e.ui.nav_mesh_id = pos_ids[se]
			else
				last_id = last_id + 1
				e.ui.nav_mesh_id = tostring(last_id)
				pos_ids[se] = tostring(last_id)
			end
		end
	end

	gui.editor.nav_dirty = true
end

return gui
