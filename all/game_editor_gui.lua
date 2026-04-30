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
local v = V.v
local r = V.r
local P = require("path_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local G = love.graphics

require("all.constants")
local timer = require("hump.timer").new()

if DEBUG then
	package.loaded.game_editor_classes = nil
end

require("game_editor_classes")
-- require("gg_views_custom")

local NODE_SELECTION_WINDOW = 8

log:set_level("debug")

local gui = {}

gui.required_textures = {}

local function wid(id)
	return gui.window:get_child_by_id(id)
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
	self.tool_names = {"general", "entities", "paths", "grid", "nav"}
	self.settings = {}
	self.settings.grid = {}
	self.settings.grid.brush_size = 1
	self.settings.grid.paint = TERRAIN_NONE
	self.tool_shortcuts = {}

	local tt = kui_db:get_table("game_editor_gui")
	local window = KWindow:new_from_table(tt)

	window.scale = V.v(self.scale, self.scale)
	window.size = V.v(self.sw, self.sh)
	window.timer = timer
	self.window = window
	wid("picker").size = V.v(self.sw, self.sh)
	wid("picker").gui = self
	wid("tools_save").on_click = function()
		-- editor:level_save(wid("tools_level_name").value, wid("tools_game_mode").value)
		editor:level_save()
	-- gui:show_save_notification("保存成功!")
	end
	wid("tools_load").on_click = function()
		editor:load_level(wid("tools_level_name").value, wid("tools_game_mode").value)
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

	wid("tg_safe_frame").on_click = function()
		gui.editor.safe_frame_visible = not gui.editor.safe_frame_visible

		if gui.editor.safe_frame_visible then
			wid("tg_safe_frame"):activate()
		else
			wid("tg_safe_frame"):deactivate()
		end
	end

	if gui.editor.safe_frame_visible then
		wid("tg_safe_frame"):activate()
	end

	-- -- 预加载出怪编辑器模块
	-- local WaveEditorView = require("game_editor_wave_editor")
	-- self._WaveEditorView = WaveEditorView

	-- -- 添加塔位快速放置区到实体面板
	-- do
	-- 	local entities_view = wid("entities")
	-- 	local entities_layout = entities_view.children[3] -- KELayout is the 3rd child
	-- 	-- 找到 entities_deselected 并在其后添加塔位区
	-- 	local deselected_layout = wid("entities_deselected")
	-- 	if deselected_layout then
	-- 		local holder_sep = KESep:new("塔位")
	-- 		deselected_layout:add_child(holder_sep)

	-- 		local holder_hint = KEButton:new("点击放置塔位")
	-- 		holder_hint.id = "entities_holder_hint"
	-- 		holder_hint.size = V.v(180, 20)
	-- 		holder_hint.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function holder_hint.on_click()
	-- 			-- 插入一个默认的 tower_holder
	-- 			gui:insert_tower_holder()
	-- 		end

	-- 		deselected_layout:add_child(holder_hint)

	-- 		-- 塔位模板列表
	-- 		local holder_list = KEList:new(V.v(180, 60))
	-- 		holder_list.id = "entities_holder_list"
	-- 		holder_list.hidden = true
	-- 		deselected_layout:add_child(holder_list)

	-- 		-- 刷新塔位列表按钮
	-- 		local refresh_btn = KEButton:new("刷新塔位列表")
	-- 		refresh_btn.id = "entities_refresh_holders"
	-- 		refresh_btn.size = V.v(180, 20)
	-- 		refresh_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function refresh_btn.on_click()
	-- 			gui:refresh_holder_list()
	-- 		end

	-- 		deselected_layout:add_child(refresh_btn)

	-- 		deselected_layout:update_layout()
	-- 	end
	-- end

	-- -- 添加"背景图"、"帮助文档"、"出怪编辑"和"返回地图"按钮到工具面板底部
	-- do
	-- 	local tools_view = wid("tools")
	-- 	local tools_layout = tools_view.children[3] -- KELayout is the 3rd child
	-- 	if tools_layout then
	-- 		-- 新建关卡按钮
	-- 		local new_level_btn = KEButton:new("新建关卡")
	-- 		new_level_btn.id = "tools_new_level"
	-- 		new_level_btn.size = V.v(180, 20)
	-- 		new_level_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		new_level_btn.colors.background = {0, 80, 40, 200}
	-- 		function new_level_btn.on_click()
	-- 			gui.editor:create_new_level()
	-- 		end

	-- 		tools_layout:add_child(new_level_btn)

	-- 		local sep = KESep:new("资源")
	-- 		tools_layout:add_child(sep)

	-- 		local bg_btn = KEButton:new("加载背景图(拖入PNG)")
	-- 		bg_btn.id = "tools_bg_image"
	-- 		bg_btn.size = V.v(180, 20)
	-- 		bg_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function bg_btn.on_click()
	-- 			gui:show_bg_prompt()
	-- 		end

	-- 		tools_layout:add_child(bg_btn)

	-- 		local wave_btn = KEButton:new("出怪编辑")
	-- 		wave_btn.id = "tools_wave_editor"
	-- 		wave_btn.size = V.v(180, 20)
	-- 		wave_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function wave_btn.on_click()
	-- 			gui:show_wave_editor()
	-- 		end

	-- 		tools_layout:add_child(wave_btn)

	-- 		local wave_cfg_btn = KEButton:new("出怪配置")
	-- 		wave_cfg_btn.id = "tools_wave_config"
	-- 		wave_cfg_btn.size = V.v(180, 20)
	-- 		wave_cfg_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function wave_cfg_btn.on_click()
	-- 			gui:show_wave_config()
	-- 		end

	-- 		tools_layout:add_child(wave_cfg_btn)

	-- 		local export_btn = KEButton:new("导出地图")
	-- 		export_btn.id = "tools_export"
	-- 		export_btn.size = V.v(180, 20)
	-- 		export_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function export_btn.on_click()
	-- 			gui:show_export_view()
	-- 		end

	-- 		tools_layout:add_child(export_btn)

	-- 		local sep2 = KESep:new("导航")
	-- 		tools_layout:add_child(sep2)

	-- 		local help_btn = KEButton:new("帮助文档")
	-- 		help_btn.id = "tools_help"
	-- 		help_btn.size = V.v(180, 20)
	-- 		help_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function help_btn.on_click()
	-- 			gui:show_help_view()
	-- 		end

	-- 		tools_layout:add_child(help_btn)

	-- 		local back_btn = KEButton:new("返回地图")
	-- 		back_btn.id = "tools_back_to_map"
	-- 		back_btn.size = V.v(180, 20)
	-- 		back_btn.text_offset = V.v(0, (20 - KE_CONST.font_size) / 2)
	-- 		function back_btn.on_click()
	-- 			if gui.editor.done_callback then
	-- 				gui.editor.done_callback({
	-- 					next_item_name = "map"
	-- 				})
	-- 			end
	-- 		end

	-- 		tools_layout:add_child(back_btn)

	-- 		tools_layout:update_layout()
	-- 	end
	-- end

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
	wid("entities_show").on_click = function()
		gui:show_template()
	end
	wid("entities_hide").on_click = function()
		gui:hide_template()
	end
	wid("entities_insert").on_click = function()
		gui:insert_entity()
	end
	wid("entities_search").on_click = function()
		gui:search_entity_suggestions()
	end
	wid("entities_selected").hidden = true
	wid("entities_duplicate").on_click = function()
		gui:duplicate_entity()
	end
	wid("entities_delete").on_click = function()
		gui:delete_entity()
	end
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
	wid("path_node_width").on_change = function(this)
		gui:path_node_width_change(this)
	end
	wid("path_node_extend").on_click = function(this)
		gui:path_node_modify(this)
	end
	wid("path_node_subdivide").on_click = function(this)
		gui:path_node_modify(this)
	end
	wid("path_node_remove").on_click = function(this)
		gui:path_node_remove(this)
	end
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
		delete = function()
			self:path_node_remove()
		end,
		backspace = function()
			self:path_node_remove()
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

	wid("tools_level_name"):update()
	wid("entities_insert_template"):set_value("tower_holder")

-- -- 最后应用主题/反馈/布局（确保所有动态元素已创建完毕）
-- gui:apply_dark_theme()
-- gui:enhance_button_feedback()
-- gui:fix_panel_layout()
end

function gui:destroy()
	self.window:destroy()

	self.window = nil
end

function gui:update(dt)
	self.window:update(dt)
	-- 更新 hump timer（PopUpView 动画需要）
	self.window.timer:update(dt)

-- -- 自动消失保存通知
-- if self._save_notification and self._save_notification_ts then
-- 	if love.timer.getTime() - self._save_notification_ts > 2.5 then
-- 		local notif = self._save_notification
-- 		notif.hidden = true -- KView 没有 hide()，用 hidden 控制
-- 		self.window:remove_child(notif)
-- 		self._save_notification = nil
-- 		self._save_notification_ts = nil
-- 	end
-- end
end

function gui:draw()
	self.window:draw()
end

function gui:keypressed(key, isrepeat)
	self.window:keypressed(key, isrepeat)
end

function gui:keyreleased(key)
	if self.window:keyreleased(key, isrepeat) then
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
	self.window:mousepressed(x, y, button)
end

function gui:mousereleased(x, y, button)
	self.window:mousereleased(x, y, button)
end

function gui:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
-- -- 转发到工具面板的滚轮（内容超出时滚动）
-- local tools = wid("tools")
-- if tools and tools.on_scroll and not self:is_any_popup_open() then
-- 	tools:on_scroll(dy)
-- end
-- -- 通用：转发滚轮到所有可见的子 PopUpView（出怪编辑器 / 预览 / 配置编辑器等）
-- local popups = {{
-- 	v = self._wave_editor,
-- 	fn = "_on_scroll"
-- }, {
-- 	v = self._wave_config_view,
-- 	fn = "_on_scroll"
-- }, {
-- 	v = self._preview_editor,
-- 	fn = "_on_scroll"
-- }}
-- for _, p in ipairs(popups) do
-- 	if p.v and not p.v.hidden then
-- 		local method = p.v[p.fn]
-- 		if method then
-- 			method(p.v, dy)
-- 		end
-- 	end
-- end
-- -- 转发到帮助文档的滚轮事件
-- if self._help_view and not self._help_view.hidden and self._help_view._on_scroll then
-- 	self._help_view._on_scroll(dy)
-- end
end

-- function gui:is_any_popup_open()
-- 	return (self._help_view and not self._help_view.hidden) or (self._wave_editor and not self._wave_editor.hidden)
-- end

-- function gui:show_bg_prompt()
-- 	if self._bg_prompt then
-- 		self._bg_prompt.hidden = not self._bg_prompt.hidden
-- 		gui.editor.waiting_for_bg = not self._bg_prompt.hidden
-- 		return
-- 	end

-- 	local pw, ph = 400, 200
-- 	local panel = KView:new(V.v(pw, ph))
-- 	panel.colors.background = {22, 28, 42, 255}
-- 	panel.anchor = V.v(pw / 2, ph / 2)
-- 	panel.pos = V.v(self.sw / 2, self.sh / 2)
-- 	self.window:add_child(panel)
-- 	self._bg_prompt = panel

-- 	local title = KLabel:new(V.v(pw, 36))
-- 	title.text = "加载背景图片"
-- 	title.text_align = "center"
-- 	title.vertical_align = "middle"
-- 	title.colors.background = {26, 33, 50, 255}
-- 	title.colors.text = {195, 148, 38, 255}
-- 	title.font_size = 16
-- 	title.font_name = KE_CONST.font_name
-- 	title.pos = V.v(0, 0)
-- 	panel:add_child(title)

-- 	local hint = KLabel:new(V.v(pw - 40, 60))
-- 	hint.pos = V.v(20, 50)
-- 	hint.text = "请将 PNG 图片文件\n从文件管理器拖入此窗口"
-- 	hint.text_align = "center"
-- 	hint.colors.text = {205, 218, 248, 255}
-- 	hint.font_size = 14
-- 	hint.font_name = KE_CONST.font_name
-- 	hint.line_height = 1.5
-- 	panel:add_child(hint)

-- 	local cancel_btn = KEButton:new("取消")
-- 	cancel_btn.size = V.v(100, 28)
-- 	cancel_btn.pos = V.v(pw / 2 - 50, ph - 45)
-- 	function cancel_btn.on_click()
-- 		panel.hidden = true
-- 		gui.editor.waiting_for_bg = false
-- 	end

-- 	panel:add_child(cancel_btn)

-- 	gui.editor.waiting_for_bg = true
-- end

-- function gui:show_wave_editor()
-- 	if not self.editor.store.level then
-- 		self:show_save_notification("请先加载一个关卡")
-- 		return
-- 	end

-- 	if self._wave_editor and not self._wave_editor.hidden then
-- 		self._wave_editor.hidden = true
-- 		return
-- 	end

-- 	local WaveEditorView = self._WaveEditorView or require("game_editor_wave_editor")
-- 	local view = WaveEditorView:new(self.sw, self.sh, self.editor)
-- 	self.window:add_child(view)
-- 	self._wave_editor = view
-- 	view:show()
-- end

-- function gui:show_wave_config()
-- 	if not self.editor.store.level then
-- 		self:show_save_notification("请先加载一个关卡")
-- 		return
-- 	end

-- 	local WaveConfigView = require("game_editor_wave_config")
-- 	local view = WaveConfigView:new(self.sw, self.sh, self.editor)
-- 	self.window:add_child(view)
-- 	self._wave_config_view = view -- 保存引用以便滚轮转发
-- 	view:show()
-- end

-- function gui:show_export_view()
-- 	if not self.editor.store.level then
-- 		self:show_save_notification("请先加载一个关卡")
-- 		return
-- 	end

-- 	local EditorExportView = require("game_editor_export")
-- 	local view = EditorExportView:new(self.sw, self.sh, self.editor)
-- 	self.window:add_child(view)
-- 	view:show()
-- end

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

-- function gui:enhance_button_feedback()
-- 	-- 为所有按钮增加悬浮样式切换（通过 id 模式匹配 + class 检测）
-- 	local function enhance_recursive(view)
-- 		if not view then
-- 			return
-- 		end
-- 		-- 检测是否为按钮：通过 class 或者 id 特征判断
-- 		local is_button = false
-- 		if view.class then
-- 			local cn = tostring(view.class)
-- 			is_button = cn:find("KEButton") or cn:find("KButton") or cn:find("KImageButton")
-- 		end
-- 		-- 分隔符也要有反馈
-- 		if not is_button and view.class then
-- 			local cn = tostring(view.class)
-- 			is_button = cn:find("KESep")
-- 		end

-- 		-- 也检测 id 特征（有些按钮可能 class 信息丢失）
-- 		if not is_button and view.id then
-- 			local id = view.id
-- 			is_button = id:match("^tools_") or id:match("^paint_") or id:match("^path_") or id:match("^nav_") or id:match("^entities_") or id:match("^brush_") or id:match("^tg_") or id:match("^grid_") or id == "tools_close"
-- 		end

-- 		if is_button and view.colors then
-- 			-- 保存原始颜色
-- 			local orig_bg = view.colors.background and {unpack(view.colors.background)} or nil

-- 			local orig_enter = view.on_enter
-- 			view.on_enter = function(self)
-- 				if orig_enter then
-- 					orig_enter(self)
-- 				end
-- 				if not self.active then
-- 					self.colors.background = {58, 130, 220, 200}
-- 				end
-- 			end

-- 			local orig_exit = view.on_exit
-- 			view.on_exit = function(self)
-- 				if orig_exit then
-- 					orig_exit(self)
-- 				end
-- 				if not self.active then
-- 					self.colors.background = orig_bg or {36, 46, 68, 200}
-- 				end
-- 			end
-- 		end
-- 		if view.children then
-- 			for _, child in pairs(view.children) do
-- 				enhance_recursive(child)
-- 			end
-- 		end
-- 	end

-- 	enhance_recursive(self.window)
-- end

-- function gui:fix_panel_layout()
-- 	local tools = wid("tools")
-- 	if not tools then
-- 		return
-- 	end

-- 	-- 强制靠左
-- 	tools.pos = V.v(0, 0)

-- 	-- 展平所有子元素的宽度：KELayout 及其子孙中所有宽度为 KE_CONST.PROP_W 的项
-- 	local function widen_recursive(view, new_w)
-- 		if not view then
-- 			return
-- 		end
-- 		if view.size and math.abs(view.size.x - KE_CONST.PROP_W) < 1 then
-- 			view.size = V.v(new_w, view.size.y)
-- 		end
-- 		if view.children then
-- 			for _, c in pairs(view.children) do
-- 				widen_recursive(c, new_w)
-- 			end
-- 		end
-- 	end
-- 	-- 先把宽度展宽（从 180 → 200），并让 layout 居于标题下方
-- 	-- 同时把 tools_title 下移，避免和坐标重叠
-- 	local tools_title = wid("tools_title")
-- 	if tools_title then
-- 		tools_title.pos = V.v(15, 4)
-- 		tools_title.size = V.v(200, 18)
-- 	end
-- 	for _, child in pairs(tools.children) do
-- 		if child.class and tostring(child.class):find("KELayout") then
-- 			widen_recursive(child, 200)
-- 			child.pos = V.v(15, 42) -- y: 给标题(0-22)和坐标(22-44)留空间
-- 			child:update_layout()
-- 		end
-- 	end

-- 	-- 计算工具面板所需高度：遍历所有子元素，取其底部的最大值
-- 	-- 先让 layout 自算出最终高度
-- 	local function calc_bottom(view)
-- 		if not view then
-- 			return 0
-- 		end
-- 		return (view.pos.y or 0) + (view.size.y or 0)
-- 	end
-- 	local max_bottom = 0
-- 	for _, child in pairs(tools.children) do
-- 		local b = calc_bottom(child)
-- 		if b > max_bottom then
-- 			max_bottom = b
-- 		end
-- 	end
-- 	local need_h = max_bottom + 10 -- 底部 padding

-- 	-- 上限：屏幕高度减去顶部/底部边距
-- 	local max_h = self.sh - 40
-- 	local final_h = math.min(need_h, max_h)
-- 	tools.size = V.v(230, final_h)

-- 	-- 如果内容超出可见区域，添加滚动支持
-- 	if need_h > max_h then
-- 		tools.clip = true
-- 		-- 将工具面板包装为可滚动
-- 		local scroll_offset = 0
-- 		tools._update_scroll = nil

-- 		-- 把内部 KELayout 做滚动偏移
-- 		for _, child in pairs(tools.children) do
-- 			if child.class and tostring(child.class):find("KELayout") then
-- 				local layout = child
-- 				local orig_y = layout.pos.y
-- 				tools.scroll_layout = layout
-- 				tools.scroll_orig_y = orig_y

-- 				-- 注册滚轮处理
-- 				function tools:on_scroll(dy)
-- 					local max_off = math.max(0, need_h - max_h)
-- 					scroll_offset = km.clamp(0, max_off, scroll_offset - dy * 30)
-- 					layout.pos = V.v(layout.pos.x, orig_y - scroll_offset)
-- 				end
-- 			end
-- 		end
-- 	end

-- 	-- 其他面板靠左上排列
-- 	local panel_names = {"general", "entities", "paths", "grid", "nav"}
-- 	local panel_x = 230
-- 	for _, name in ipairs(panel_names) do
-- 		local panel = wid(name)
-- 		if panel then
-- 			panel.pos = V.v(panel_x, panel.pos.y or 100)
-- 			panel_x = panel_x + 10
-- 		end
-- 	end
-- end

-- function gui:apply_dark_theme()
-- 	-- 深色策略游戏配色方案
-- 	local panel_bg = {26, 33, 50, 255} -- 面板背景
-- 	local title_bg = {30, 38, 56, 255} -- 标题栏
-- 	local text_color = {205, 218, 248, 255} -- 文字颜色
-- 	local accent = {195, 148, 38, 255} -- 金色装饰

-- 	-- 判断颜色是否为默认黑色（尚未被主题处理过）
-- 	local function is_black_or_nil(c)
-- 		if not c then
-- 			return true
-- 		end
-- 		return c[1] == 0 and c[2] == 0 and c[3] == 0
-- 	end

-- 	-- 递归应用配色
-- 	local function apply_theme_to_view(view, depth)
-- 		if not view then
-- 			return
-- 		end
-- 		depth = depth or 0

-- 		local id = view.id or ""
-- 		local cn = tostring(view.class or "")
-- 		local is_label = cn:find("KLabel") or cn:find("KEProp") or cn:find("KEPropNum") or cn:find("KEPropCoords") or cn:find("KENum") or cn:find("KEEnum") or cn:find("KEList") or cn:find("KEPointerPos") or cn:find("KECellInfo")
-- 		local is_btn = cn:find("KButton") or cn:find("KEButton") or cn:find("KImageButton")
-- 		local is_sep = cn:find("KESep")

-- 		-- 主面板背景色
-- 		if id == "tools" or id == "general" or id == "entities" or id == "paths" or id == "grid" or id == "nav" then
-- 			view.colors.background = panel_bg
-- 		end

-- 		-- 标题栏（面板标题 + tools_title）
-- 		if id and (id:match("_title$") or id:match("^tools_title")) then
-- 			view.colors.background = title_bg
-- 			if view.colors then
-- 				view.colors.text = accent
-- 			end
-- 		end

-- 		-- 关闭按钮
-- 		if id and id:match("_close$") then
-- 			view.colors.background = {120, 50, 50, 255}
-- 			if view.colors then
-- 				view.colors.text = {255, 255, 255, 255}
-- 			end
-- 		end

-- 		-- 分隔符标题
-- 		if is_sep then
-- 			view.colors.background = {20, 25, 40, 255}
-- 			if view.colors then
-- 				view.colors.text = accent
-- 			end
-- 		end

-- 		-- ★ 关键修复：对所有 KLabel/KButton 默认设置浅色文字（如果还是黑色）
-- 		if view.colors then
-- 			if is_label and is_black_or_nil(view.colors.text) then
-- 				view.colors.text = text_color
-- 			end
-- 			if is_btn and is_black_or_nil(view.colors.text) then
-- 				view.colors.text = {255, 255, 255, 255}
-- 			end
-- 		end

-- 		-- 递归子元素
-- 		if view.children then
-- 			for _, child in pairs(view.children) do
-- 				apply_theme_to_view(child, depth + 1)
-- 			end
-- 		end
-- 	end

-- 	apply_theme_to_view(self.window)

-- 	-- 第二轮：修复 KELayout 子元素中 KEProp 等的内部标签（KLabel 在 KEProp 内部的 children 里）
-- 	local function fix_inner_labels(view)
-- 		if not view then
-- 			return
-- 		end
-- 		if view.colors and view.class then
-- 			local cn = tostring(view.class)
-- 			-- KLabel 如果还是黑色，强制设为浅色
-- 			if cn:find("KLabel") then
-- 				if not view.colors.text or (view.colors.text[1] == 0 and view.colors.text[2] == 0 and view.colors.text[3] == 0) then
-- 					view.colors.text = text_color
-- 				end
-- 			end
-- 		end
-- 		if view.children then
-- 			for _, child in pairs(view.children) do
-- 				fix_inner_labels(child)
-- 			end
-- 		end
-- 	end
-- 	fix_inner_labels(self.window)
-- end

function gui:level_loaded(level_idx)
	wid("tools_level_name"):set_value(level_idx)
	self:update_grid_tool()
	self:refresh_nav_tool()
-- self:refresh_holder_list()
end

function gui:pointer_pos_label_update(this, dt)
	local x, y = love.mouse.getPosition()
	x, y = self:u2g(V.v(x, y))
	this.lt.text = string.format("%s,%s", x, y)
-- this.lt.colors.text = {180, 220, 255, 255}
-- this.lt.font_name = "infobar_stats" -- 中文环境下用 msyh
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
	self.window:set_responder()

	local v = self.window:get_child_by_id(name)

	if v.children[2] then
		v.children[2].colors.background = {220, 220, 220, 255}
	end
	-- -- 面板标题恢复默认
	-- local title = v and v.children[2]
	-- if title then
	-- 	title.colors.background = {30, 38, 56, 255}
	-- 	title.colors.text = {195, 148, 38, 255}
	-- end

	-- -- 对应工具按钮取消激活
	-- local btn = wid("tools_" .. name)
	-- if btn then
	-- 	btn:deactivate()
	-- end

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
	-- -- 面板标题高亮为蓝色（选中状态）
	-- local title = v and v.children[2]
	-- if title then
	-- 	title.colors.background = {58, 130, 220, 255}
	-- 	title.colors.text = {255, 255, 255, 255}
	-- end

	-- -- 对应工具按钮激活
	-- local btn = wid("tools_" .. name)
	-- if btn then
	-- 	btn:activate()
	-- end

	if name == "entities" and not self.editor.entities_selected then
		self.window:set_responder(wid("entities_insert_template"))
	end
end

function gui:click_tool(btn, x, y)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "grid" then
		self:grid_paint(wx, wy, btn)
	elseif self.active_tool == "entities" then
		local cb = self.select_entity

		self:entities_select(wx, wy, cb, 12)
	elseif self.active_tool == "nav" then
		local cb = self.select_entity_nav

		self:entities_select(wx, wy, cb, 24)
	end
end

function gui:down_tool(btn, x, y)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "paths" then
		if btn == 2 and self.path_nodes_selected then
			self:path_node_modify(nil, wx, wy)
		else
			local selected = self:path_nodes_select(wx, wy)

			if not selected then
			-- block empty
			end
		end
	end
end

function gui:up_tool(btn, x, y)
	if self.active_tool == "paths" then
	-- block empty
	end
end

function gui:move_tool(x, y, down)
	local wx, wy = gui:u2g(V.v(x, y))

	if self.active_tool == "grid" then
		self.editor.tool_pointer.tool = "grid"
		self.editor.tool_pointer.x = wx
		self.editor.tool_pointer.y = wy
		self.editor.tool_pointer.size = self.settings.grid.brush_size

		if down then
			self:grid_paint(wx, wy, down)
		end
	elseif self.active_tool == "entities" then
		if down and self.editor.entities_selected then
			self:entities_move(wx, wy)
		end
	elseif self.active_tool == "paths" then
		if down and self.path_nodes_selected then
			self:path_nodes_move(wx, wy)
		end
	else
		self.editor.tool_pointer.tool = nil
	end
end

function gui:undo()
	self:select_entity()
	self.editor:undo_pop()
end

function gui:grid_cell_info_update(this, dt)
	-- if not GR or not GR.grid or #GR.grid == 0 then
	-- 	if this.lt then
	-- 		this.lt.text = "-"
	-- 	end
	-- 	if this.gt then
	-- 		this.gt.text = "未加载"
	-- 	end
	-- 	return
	-- end
	local x, y = love.mouse.getPosition()
	local wx, wy = self:u2g(V.v(x, y))
	local ct, i, j = GR:cell_type(wx, wy)

	this.lt.text = string.format("%s,%s", i, j)
	this.gt.text = GR:print_cell(ct)
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
	prop_name = prop_view.prop_name

	if prop_name == "grid_size" then
		GR:set_grid_size(prop_view.value.x, prop_view.value.y)
	elseif prop_name == "grid_offset" then
		GR:set_grid_offset(prop_view.value.x, prop_view.value.y)
	end

	self.editor.grid_dirty = true
end

function gui:update_grid_tool()
	wid("grid_size"):set_value(V.v(GR.grid_w, GR.grid_h), true)
	wid("grid_offset"):set_value(V.v(GR.ox, GR.oy), true)
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

		self.window:set_responder()
	else
		self.editor.entities_selected = nil
		vs.hidden = true
		vd.hidden = false

		self.window:set_responder(wid("entities_insert_template"))
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
		local state, reason = self.are_axes_in_range(prop_value, self._last_prop_value)

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

function gui:insert_entity()
	local template = wid("entities_insert_template").value

	if not template or not E:get_template(template) then
		return
	end

	local e = E:create_entity(template)

	e.pos.x, e.pos.y = REF_W / 2, REF_H / 2 - 50

	LU.queue_insert(self.editor.store, e)
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

	LU.queue_remove(self.editor.store, e)

	local list = self.editor.store.level.data.entities_list
	local le = list._idx[e.id]

	table.removeobject(list, le)

	list._idx[e.id] = nil

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

function gui:search_entity_suggestions()
	local tv = wid("entities_insert_template")
	local list = wid("entities_search_suggestions")
	local str = tv.value

	if str and string.len(str) >= 3 then
		local results = E:search_entity(str)

		list:clear_rows()

		for i = 1, 10 do
			local tn = results[i]

			if not tn then
				break
			end

			local l = KLabel:new(V.v(list.size.x, 20))

			l.text_align = "left"
			l.text = tn
			l.font_name = "body"
			l.font_size = 8

			function l.on_click()
				tv:set_value(tn)
			end

			list:add_row(l)
		end
	end
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
		l.text = i

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

		self:show_path_node()
	-- self.editor.path_selected = nil
	-- self:select_list_path()
	end

	self.editor.paths_dirty = true
end

function gui:path_nodes_select(x, y, w, h)
	log.debug("x:%s,y%s,w:%s,h:%s", x, y, w, h)

	local multi = true

	if not w or not h then
		multi = false
		w, h = NODE_SELECTION_WINDOW * 2, NODE_SELECTION_WINDOW * 2
		x, y = x - w / 2, y - h / 2
	end

	local r = V.r(x, y, w, h)
	local lpi = self.editor.path_selected

	self:select_node()

	local sel = {}

	for pi, path in ipairs(self.editor.path_curves) do
		if lpi == pi then
			local n = path.nodes

			for ni = 1, #n do
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
	wid("path_node_id"):set_value(ni .. " / " .. node_type)
	wid("path_node_pos"):set_value(p, true)

	if node_width then
		wid("path_node_width"):set_value(node_width, true)
	end

	wid("path_node_width").hidden = node_width == nil
	wid("paths_node_selected").hidden = false

	wid("paths_node_selected"):update_layout()
	wid("paths_props"):update_layout()
end

function gui:path_connects_to_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, prop_view.value)

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:set_path_connection(pi, prop_view.value)
end

function gui:path_active_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, prop_view.value)

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:set_path_active(pi, prop_view.value)
end

function gui:path_node_pos_change(prop_view)
	log.debug("prop_view:%s  value:%s", prop_view, getdump(prop_view.value))

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:set_node_pos(pi, ni, prop_view.value.x, prop_view.value.y)
end

function gui:path_node_width_change(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:set_node_width(pi, ni, view.value)
end

function gui:path_nodes_move(x, y, delta)
	log.debug()

	if not self.path_nodes_selected or #self.path_nodes_selected < 1 then
		return
	end

	if delta then
		local step = love.keyboard.isDown("lshift", "rshift") and 10 or 1

		for _, item in pairs(self.path_nodes_selected) do
			local pi, ni = unpack(item)
			local n = self.editor.path_curves[pi].nodes[ni]
			local nx, ny = n.x + x * step, n.y + y * step

			self.editor:set_node_pos(pi, ni, nx, ny)
			wid("path_node_pos"):set_value(V.v(nx, ny), true)
		end
	else
		local pi, ni = unpack(self.path_nodes_selected[1])

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

function gui:path_node_remove(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:remove_path_node(pi, ni)
	self:show_path_node()
end

function gui:flip_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:flip_path(pi)

	self.path_nodes_selected = {{pi, 1}}

	self:show_path_node(pi, 1)
end

function gui:move_path(inc)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	if pi + inc < 1 or pi + inc > #self.editor.path_curves then
		return
	end

	self.editor:change_path_idx(pi, pi + inc)
	self:update_paths_list()
	self:select_node(pi + inc, 1)
end

function gui:create_path()
	local pi = self.editor:create_path()

	self:update_paths_list()
	self:select_node(pi, 1)
end

function gui:duplicate_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])
	local npi = self.editor:duplicate_path(pi)

	self:update_paths_list()
	self:select_node(npi, 1)
end

function gui:remove_path()
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

	self.editor:remove_path(pi)
	self:update_paths_list()
	self:show_path_node()
end

function gui:preview_path(view)
	if not self.path_nodes_selected or #self.path_nodes_selected ~= 1 then
		return
	end

	local pi, ni = unpack(self.path_nodes_selected[1])

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

		lt_hid = tonumber(e.ui.nav_mesh_id)

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

-- banned. Delete Input State Machine
-- if not e then
-- 	log.error("invalid entity")

-- 	return
-- end

-- local nearby = {}

-- for _, ee in pairs(gui.editor.store.entities) do
-- 	if ee ~= e and ee.ui then
-- 		table.insert(nearby, ee)
-- 	end
-- end

-- table.sort(nearby, function(e1, e2)
-- 	return V.dist(e1.pos.x, e1.pos.y, e.pos.x, e.pos.y) < V.dist(e2.pos.x, e2.pos.y, e.pos.x, e.pos.y)
-- end)

-- local nav_mesh = gui.editor.store.level.nav_mesh

-- for i = 1, 4 do
-- 	for _, ee in ipairs(nearby) do
-- 		if ism.get_dir_idx(ee.pos.x - e.pos.x, ee.pos.y - e.pos.y) == i then
-- 			nav_mesh[tonumber(e.ui.nav_mesh_id)][i] = tonumber(ee.ui.nav_mesh_id)

-- 			break
-- 		end
-- 	end
-- end

-- gui.editor.nav_dirty = true
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

-- function gui:insert_tower_holder(template_name)
-- 	local tn = template_name or "tower_holder_grass"
-- 	local template = E:get_template(tn)
-- 	if not template then
-- 		-- 如果指定模板不存在，尝试搜索所有 holder
-- 		gui:refresh_holder_list()
-- 		gui:show_save_notification("未找到模板: " .. tn .. ", 请从列表中选择")
-- 		return
-- 	end

-- 	local e = E:create_entity(tn)
-- 	-- 在屏幕中央稍微偏移放置
-- 	local cx, cy = REF_W / 2, REF_H / 2
-- 	-- 查找已存在的同类型 holder，在它们下方偏移
-- 	local offset = 0
-- 	for _, ee in pairs(gui.editor.store.entities) do
-- 		if ee.template_name == tn and ee.pos then
-- 			offset = offset + 60
-- 		end
-- 	end

-- 	e.pos.x = cx
-- 	e.pos.y = cy - 100 + offset

-- 	-- 自动分配 nav_mesh_id
-- 	if e.ui then
-- 		local max_id = 0
-- 		for _, ee in pairs(gui.editor.store.entities) do
-- 			if ee.ui and ee.ui.nav_mesh_id then
-- 				local id = tonumber(ee.ui.nav_mesh_id)
-- 				if id and id > max_id then
-- 					max_id = id
-- 				end
-- 			end
-- 		end
-- 		e.ui.nav_mesh_id = tostring(max_id + 1)
-- 	end

-- 	queue_insert(gui.editor.store, e)
-- 	gui.editor.entities_dirty = true
-- 	gui:show_save_notification("已放置: " .. tn)
-- end

-- function gui:refresh_holder_list()
-- 	local list = wid("entities_holder_list")
-- 	if not list then
-- 		return
-- 	end

-- 	list:clear_rows()
-- 	list.hidden = false

-- 	-- 真正的通用塔位模板是 tower_holder_<地形> 系列
-- 	-- 排除 tower_holder_blocked_*（被阻挡的塔位）和 tower_*_holder（特定英雄的）
-- 	local results = {}
-- 	for k, _ in pairs(E.entities) do
-- 		-- 匹配 tower_holder_<name> 但不匹配 tower_holder_blocked_*
-- 		if string.find(k, "^tower_holder_") and not string.find(k, "^tower_holder_blocked_") then
-- 			-- 检查是否包含 tower_holder 组件
-- 			local template = E:get_template(k)
-- 			if template and template.tower_holder then
-- 				table.insert(results, k)
-- 			end
-- 		end
-- 	end
-- 	table.sort(results)

-- 	-- 限制数量避免界面过长
-- 	local max_results = math.min(#results, 30)
-- 	for i = 1, max_results do
-- 		local tn = results[i]
-- 		if tn then
-- 			local l = KLabel:new(V.v(list.size.x, 18))
-- 			l.text_align = "left"
-- 			l.text = tn
-- 			l.font_name = KE_CONST.font_name
-- 			l.font_size = 8
-- 			l.colors.background = {0, 0, 0, 20}

-- 			function l.on_click()
-- 				gui:insert_tower_holder(tn)
-- 				gui:show_save_notification("已放置: " .. tn)
-- 			end

-- 			list:add_row(l)
-- 		end
-- 	end

-- 	if #results == 0 then
-- 		local l = KLabel:new(V.v(list.size.x, 18))
-- 		l.text_align = "left"
-- 		l.text = "无通用塔位模板"
-- 		l.font_name = KE_CONST.font_name
-- 		l.font_size = 8
-- 		list:add_row(l)
-- 	end

-- 	gui:show_save_notification("找到 " .. #results .. " 个通用塔位模板")
-- end

-- function gui:show_save_notification(text)
-- 	-- 如果已有通知视图，移除旧的
-- 	if self._save_notification then
-- 		self._save_notification.hidden = true
-- 		self.window:remove_child(self._save_notification)
-- 		self._save_notification = nil
-- 	end

-- 	local notif = KView:new(V.v(300, 60))
-- 	notif.colors.background = {0, 120, 0, 220} -- 深绿色背景
-- 	notif.pos = V.v(self.sw / 2 - 150, 80)
-- 	notif.anchor = V.v(0, 0)

-- 	local label = KLabel:new(V.v(300, 60))
-- 	label.text = text
-- 	label.text_align = "center"
-- 	label.vertical_align = "middle"
-- 	label.font_name = KE_CONST.font_name
-- 	label.font_size = 16
-- 	label.colors.text = {255, 255, 255, 255}
-- 	notif:add_child(label)

-- 	self.window:add_child(notif)
-- 	self._save_notification = notif
-- 	self._save_notification_ts = love.timer.getTime() -- 记录创建时间
-- end

-- function gui:show_help_view()
-- 	if self._help_view then
-- 		-- 切换可见状态（KView 没有 show/hide 方法，用 hidden 控制）
-- 		self._help_view.hidden = not self._help_view.hidden
-- 		return
-- 	end

-- 	local hw, hh = 800, 600
-- 	-- 不使用 PopUpView（避免 timer 依赖），直接用 KView 做遮罩
-- 	local help_view = KView:new(V.v(self.sw, self.sh))
-- 	help_view.pos = V.v(0, 0)
-- 	help_view.colors.background = {0, 0, 0, 160}
-- 	help_view.hidden = true

-- 	-- 主面板
-- 	local panel = KView:new(V.v(hw, hh))
-- 	panel.colors.background = {22, 28, 42, 255} -- 深色面板
-- 	panel.anchor = V.v(hw / 2, hh / 2)
-- 	panel.pos = V.v(self.sw / 2, self.sh / 2)

-- 	-- 标题
-- 	local title = KLabel:new(V.v(hw, 40))
-- 	title.text = "地图编辑器帮助文档"
-- 	title.text_align = "center"
-- 	title.vertical_align = "middle"
-- 	title.font_name = KE_CONST.font_name
-- 	title.font_size = 20
-- 	title.colors.text = {238, 244, 255, 255}
-- 	title.colors.background = {26, 33, 50, 255}
-- 	title.pos = V.v(0, 0)
-- 	panel:add_child(title)

-- 	-- 关闭按钮
-- 	local close_btn = KButton:new(V.v(30, 30))
-- 	close_btn.text = "X"
-- 	close_btn.pos = V.v(hw - 35, 5)
-- 	close_btn.colors.background = {120, 120, 120, 255}
-- 	close_btn.colors.text = {255, 255, 255, 255}
-- 	function close_btn.on_click()
-- 		help_view.hidden = true
-- 	end

-- 	panel:add_child(close_btn)

-- 	-- 文本内容（可滚动区域）
-- 	local content_text = [[
-- 地图编辑器使用说明

-- --- 基本操作 ---
-- - 左键点击工具按钮切换编辑模式
-- - 每个工具面板可拖拽移动位置
-- - 使用快捷键可快速切换工具

-- --- 关卡管理 (Level) ---
-- - 关卡编号：输入要编辑的关卡数字
-- - 游戏模式：1=战役 2=英雄 3=铁人
-- - 保存：保存当前编辑到关卡文件
-- - 加载：加载已有关卡数据
-- - 撤销：撤销上一步操作

-- --- 实体编辑 (Entities) ---
-- - 在实体面板输入模板名后点击"插入实体"
-- - 常用模板：tower_holder（塔位）
-- - 左键点击世界中的实体进行选择
-- - 选中后可修改属性或删除

-- --- 路径编辑 (Paths) ---
-- - 创建新路径后，拖动节点调整路径
-- - 节点由贝塞尔曲线控制
-- - 细分路径：在选中节点处插入新节点
-- - 扩充路径：在路径末端延长
-- - 每条路径可设置宽度、活跃状态、连接关系

-- --- 网格编辑 (Grid) ---
-- 网格用于标记地形，影响敌人行走和塔位放置：
-- - 陆地 (Land)：可放置塔，可行走
-- - 水域 (Water)：不可放置塔，不可行走
-- - 悬崖 (Cliff)：不可放置塔，不可行走
-- - 浅滩 (Shallow)：水域中的可通行区域
-- - 无法行走 (NoWalk)：强制禁止行走
-- - 仙子 (Faerie)：特殊飞行单位互动
-- - 冰面 (Ice)：影响移动速度
-- - 飞行不可行走：仅对飞行单位生效

-- --- 导航网格 (Nav) ---
-- - 用于控制塔的寻路方向
-- - 每个塔位需要分配方向ID
-- - 上/左/右/下 分别对应不同的路径方向

-- --- 快捷键 ---
-- 在网格模式下：
--   +/- 调整笔刷大小
--   Q 无地形  E 陆地  W 水域  C 悬崖
--   S 浅滩  D 无法行走  F 仙子  G 冰面

-- 在实体模式下：
--   方向键 移动选中的实体
--   ESC 取消选择

-- 在路径模式下：
--   方向键 移动选中的节点
--   V 预览子路径
--   Delete/Backspace 删除节点
-- ]]

-- 	-- 滚动容器
-- 	local scroll_h = hh - 110
-- 	local scroll_view = KView:new(V.v(hw - 20, scroll_h))
-- 	scroll_view.pos = V.v(10, 46)
-- 	scroll_view.colors.background = {0, 0, 0, 0}
-- 	scroll_view.clip = true
-- 	panel:add_child(scroll_view)
-- 	help_view._scroll_view = scroll_view

-- 	-- 滚动中的内容
-- 	local content = KLabel:new(V.v(hw - 40, 0))
-- 	content.text = content_text
-- 	content.text_align = "left"
-- 	content.vertical_align = "top"
-- 	content.font_name = KE_CONST.font_name
-- 	content.font_size = 12
-- 	content.colors.text = {205, 218, 248, 255}
-- 	content.pos = V.v(0, 0)
-- 	content.line_height = 1.3
-- 	scroll_view:add_child(content)

-- 	-- 计算内容实际高度：按文本行数估算
-- 	local function count_text_lines(text)
-- 		local count = 0
-- 		for line in text:gmatch("[^\n]+") do
-- 			count = count + 1
-- 		end
-- 		return count
-- 	end
-- 	local line_h = (content.font_size or 12) * (content.line_height or 1.5)
-- 	local total_lines = count_text_lines(content_text)
-- 	local content_h = total_lines * line_h + 40
-- 	content.size = V.v(hw - 55, math.max(scroll_h, content_h))

-- 	-- 滚动条
-- 	local scrollbar_w = 6
-- 	local scrollbar = KView:new(V.v(scrollbar_w, scroll_h))
-- 	scrollbar.pos = V.v(hw - 25, 0)
-- 	scrollbar.colors.background = {40, 50, 70, 200}
-- 	scroll_view:add_child(scrollbar)

-- 	local scrollbar_fill = KView:new(V.v(scrollbar_w, scroll_h))
-- 	scrollbar_fill.pos = V.v(0, 0)
-- 	scrollbar_fill.colors.background = {100, 140, 220, 200}
-- 	scrollbar:add_child(scrollbar_fill)

-- 	-- 滚轮事件
-- 	local content_scroll_y = 0
-- 	help_view._on_scroll = function(dy)
-- 		local max_scroll = math.max(0, content.size.y - scroll_h)
-- 		content_scroll_y = km.clamp(0, max_scroll, content_scroll_y - dy * 40)
-- 		content.pos = V.v(0, -content_scroll_y)
-- 		-- 更新滚动条位置
-- 		local fill_ratio = scroll_h / math.max(scroll_h, content.size.y)
-- 		local fill_h = scroll_h * fill_ratio
-- 		local fill_pos = (scroll_h - fill_h) * (content_scroll_y / math.max(1, max_scroll))
-- 		scrollbar_fill.size = V.v(scrollbar_w, fill_h)
-- 		scrollbar_fill.pos = V.v(0, fill_pos)
-- 	end
-- 	-- 初始更新滚动条
-- 	help_view._on_scroll(0)

-- 	help_view:add_child(panel)
-- 	self.window:add_child(help_view)
-- 	self._help_view = help_view
-- 	help_view.hidden = false -- KView 直接设置 hidden（不使用 PopUpView 的动画 show）
-- end

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
