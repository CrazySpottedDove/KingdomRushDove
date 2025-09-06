-- chunkname: @./all/game_editor_gui.lua
local log = require("klua.log"):new("game_editor_gui")

local ism
local km = require("klua.macros")
require("klua.table")
require("klove.kui")
local kui_db = require("klove.kui_db")
local F = require("klove.font_db")
local I = require("klove.image_db")
local SU = require("screen_utils")
local LU = require("level_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local v = V.v
local r = V.r
local P = require("path_db")
local GR = require("grid_db")
local GS = require("game_settings")
local G = love.graphics
require("constants")

local IS_KR5 = KR_GAME == "kr5"

if IS_KR5 then
	ism = require("klove.input_state_machine")
else
	ism = require("input_state_machine")
end

if DEBUG then
	package.loaded.game_editor_classes = nil
end
require("game_editor_classes")
local NODE_SELECTION_WINDOW = 8
log.level = log.DEBUG_LEVEL

local gui = {}

gui.required_textures = {}

local function wid(id)
	return gui.window:get_child_by_id(id)
end

--- 计算两个坐标之差的绝对值是否小于给定值
--- @param axi1 table 坐标1
--- @param axi2 table 坐标2
--- @param range number? 值（可选，默认 550）
--- @return boolean
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
	self.tool_names = {
		"general",
		"entities",
		"paths",
		"grid",
		"nav"
	}
	self.settings = {}
	self.settings.grid = {}
	self.settings.grid.brush_size = 1
	self.settings.grid.paint = TERRAIN_NONE
	self.tool_shortcuts = {}

	local tt = kui_db:get_table("game_editor_gui")
	local window = KWindow:new_from_table(tt)

	window.scale = {
		x = self.scale,
		y = self.scale
	}
	window.size = {
		x = self.sw,
		y = self.sh
	}
	self.window = window
	wid("picker").size = {
		x = self.sw,
		y = self.sh
	}
	wid("picker").gui = self
	wid("tools_save").on_click = function()
		editor:level_save(wid("tools_level_name").value, wid("tools_game_mode").value)
	end
	wid("tools_load").on_click = function()
		editor:level_load(wid("tools_level_name").value, wid("tools_game_mode").value)
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
end

function gui:destroy()
	self.window:destroy()

	self.window = nil
end

function gui:update(dt)
	self.window:update(dt)
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
		v.children[2].colors.background = {
			220,
			220,
			220,
			255
		}
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
		v.children[2].colors.background = {
			255,
			255,
			200,
			255
		}
	end

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
		[TERRAIN_ICE] = "ice",
		[TERRAIN_FLYING_NOWALK] = "flying_nw"
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
		self.editor.entities_selected = {
			e.id
		}
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
		self._last_prop_value = {
			x = prop_value.x,
			y = prop_value.y
		}
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

	if e.editor then
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
			l.font_name = "DroidSansMono"
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
			v.colors.background = {
				0,
				0,
				0,
				40
			}
		else
			v.colors.background = {
				0,
				0,
				0,
				0
			}
		end
	end
end

function gui:select_node(pi, ni, add)
	if pi and ni then
		local sel = {
			pi,
			ni
		}

		if add and self.path_nodes_selected then
			table.insert(self.path_nodes_selected, sel)
		else
			self.path_nodes_selected = {
				sel
			}

			self:select_list_path(pi)
		end

		self:show_path_node(unpack(sel))

		self.editor.path_selected = pi
	else
		self.path_nodes_selected = nil

		self:show_path_node()

		self.editor.path_selected = nil

		self:select_list_path()
	end

	self.editor.paths_dirty = true
end

function gui:path_nodes_select(x, y, w, h)
	log.debug("x:%s,y%s,w:%s,h:%s", x, y, w, h)

	local multi = true

	if not w or not h then
		multi = false
		w, h = NODE_SELECTION_WINDOW, NODE_SELECTION_WINDOW
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

			self.path_nodes_selected = {
				{
					pi,
					nni
				}
			}

			self:show_path_node(pi, nni)
		else
			self.editor:subdivide_path(pi, ni, x, y)

			local nni = ni + 1

			self.path_nodes_selected = {
				{
					pi,
					nni
				}
			}

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

	self.path_nodes_selected = {
		{
			pi,
			1
		}
	}

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

	local v_dir_ids = {
		"nav_id_right",
		"nav_id_top",
		"nav_id_left",
		"nav_id_bottom"
	}

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
	if not e then
		log.error("invalid entity")

		return
	end

	local nearby = {}

	for _, ee in pairs(gui.editor.store.entities) do
		if ee ~= e and ee.ui then
			table.insert(nearby, ee)
		end
	end

	table.sort(nearby, function(e1, e2)
		return V.dist(e1.pos.x, e1.pos.y, e.pos.x, e.pos.y) < V.dist(e2.pos.x, e2.pos.y, e.pos.x, e.pos.y)
	end)

	local nav_mesh = gui.editor.store.level.nav_mesh

	for i = 1, 4 do
		for _, ee in ipairs(nearby) do
			if ism.get_dir_idx(ee.pos.x - e.pos.x, ee.pos.y - e.pos.y) == i then
				nav_mesh[tonumber(e.ui.nav_mesh_id)][i] = tonumber(ee.ui.nav_mesh_id)

				break
			end
		end
	end

	gui.editor.nav_dirty = true
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
