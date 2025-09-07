-- chunkname: @./all/game_editor.lua

local log = require("klua.log"):new("game")

log.level = log.DEBUG_LEVEL

require("klua.dump")

local km = require("klua.macros")
local signal = require("hump.signal")
local V = require("hump.vector-light")
local F = require("klove.font_db")

local simulation, A
local serpent = require("serpent")
local I = require("klove.image_db")
local E = require("entity_db")
local U = require("utils")
local RU = require("render_utils")
local E = require("entity_db")
local P = require("path_db")
local SU = require("screen_utils")
local GR = require("grid_db")
local LU = require("level_utils")
local sys = require("systems")

local IS_KR5 = KR_GAME == "kr5"

if IS_KR5 then
	simulation = require("klove.simulation")
	A = require("klove.animation_db")
else
	simulation = require("simulation")
	A = require("animation_db")
end

local EXO

if IS_KR5 then
	EXO = require("exoskeleton")
end

if DEBUG then
	package.loaded.game_editor_gui = nil
end

local game_editor_gui = require("game_editor_gui")
local G = love.graphics
local bit = require("bit")

require("constants")

BATCH_SIZE = 1000
DEFAULT_PATH_WIDTH = 40
editor = {}

editor.required_textures = {
	"go_decals",
	"go_towers",
	"go_editor"
}

editor.ref_h = REF_H
editor.ref_w = REF_W
editor.ref_res = TEXTURE_SIZE_ALIAS.ipad
editor.simulation_systems = {
	"editor_overrides",
	"editor_script",
	"render",
	"last_hook"
}

function editor.save_data(data, name)
	local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. name .. "_data.lua"
	
	local function custom_sort(k, o)
		local function sort_table(a, b)
			if a == "template" then
				return true
			elseif b == "template" then
				return false
			elseif type(a) == "number" and type(b) == "number" then
				if type(o[a]) == "table" and type(o[b]) == "table" and o[a].template and o[b].template then
					if o[a].template == o[b].template and o[a].pos and o[b].pos then
						if o[a].pos.y == o[b].pos.y then
							if o[a].pos.x == o[b].pos.x then
								if o[a]["editor.game_mode"] and o[b]["editor.game_mode"] then
									return o[a]["editor.game_mode"] < o[b]["editor.game_mode"]
								elseif o[a]["tunnel.name"] and o[b]["tunnel.name"] then
									return o[a]["tunnel.name"] < o[b]["tunnel.name"]
								else
									return o[a].pos.x < o[b].pos.x
								end
							else
								return o[a].pos.x < o[b].pos.x
							end
						else
							return o[a].pos.y < o[b].pos.y
						end
					else
						return o[a].template < o[b].template
					end
				else
					return a < b
				end
			else
				return tostring(a) < tostring(b)
			end
		end

		table.sort(k, sort_table)
	end

	local str = serpent.block(data, {
		indent = "    ",
		comment = false,
		sortkeys = custom_sort,
		keyignore = {
			_idx = true,
			_id = true,
			_before_ov = true,
			locations = true,
			frames = true
		}
	})
	local out = "return " .. str .. "\n"
	local f = io.open(fn, "w")

	f:write(out)
	f:flush()
	f:close()
end

function editor:init(screen_w, screen_h, done_callback)
	self.screen_w = screen_w
	self.screen_h = screen_h
	self.done_callback = done_callback
	-- self.game_scale = self.ref_h / TEXTURE_SIZE_ALIAS[self.args.texture_size]
	self.game_scale = self.ref_h / TEXTURE_SIZE_ALIAS["ipad"]
	self.game_scale = self.game_scale / (tsf and tsf.game_editor or 1)
	self.game_ref_origin = V.v((screen_w - self.ref_w * self.game_scale) / 2, (screen_h - self.ref_h * self.game_scale) / 2)

	RU.init()

	self.store = {}

	local systems
	if IS_KR5 then
		systems = sys
	else
		systems = self.simulation_systems
	end
	simulation:init(self.store, systems, self.simulation_systems, TICK_LENGTH)

	self.simulation = simulation
	self.undo_stack = {}
	self.undo_active = false

	game_editor_gui:init(screen_w, screen_h, self)

	self.gui = game_editor_gui
	self.paths_visible = false
	self.grid_visible = false
	self.nav_visible = false
	self.tool_pointer = {
		size = 1,
		x = 0,
		y = 0
	}
end

function editor:destroy()
	self.gui:destroy()

	self.gui = nil

	RU.destroy()
end

function editor:update(dt)
	if self.args and self.args.custom then
		local level_idx = self.args.custom

		self:level_load(level_idx, 1)

		self.args = nil
	end

	self.simulation:update(dt)
	self.gui:update(dt)
end

function editor:keypressed(key, isrepeat)
	self.gui:keypressed(key, isrepeat)
end

function editor:keyreleased(key, isrepeat)
	self.gui:keyreleased(key, isrepeat)
end

function editor:textinput(t)
	self.gui:textinput(t)
end

function editor:mousepressed(x, y, button)
	self.gui:mousepressed(x, y, button)
end

function editor:mousereleased(x, y, button)
	self.gui:mousereleased(x, y, button)
end

function editor:wheelmoved(dx, dy)
	self.gui:wheelmoved(dx, dy)
end

function editor:draw()
	love.graphics.print("Memory: " .. collectgarbage("count") .. " KB", 10, 10)
	local rox, roy = self.game_ref_origin.x, self.game_ref_origin.y
	local gs = self.game_scale
	local last_idx
	local node_w = 10
	local curve_w = 3
	local curve_selected_w = 3
	local width_w = 6
	local sel_w = 2
	local color_curve = {
		255,
		100,
		100,
		255
	}
	local color_curve_sel = {
		255,
		255,
		100,
		255
	}
	local color_node = {
		0,
		0,
		255,
		255
	}
	local color_handle = {
		100,
		100,
		255,
		255
	}
	local color_width = {
		255,
		255,
		0,
		255
	}
	local color_selected = {
		255,
		150,
		150,
		255
	}

	if self.paths_visible and (not self.paths_canvas or self.paths_dirty) then
		self.paths_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.paths_canvas = G.newCanvas()

		G.setCanvas(self.paths_canvas)

		for pi, path in ipairs(self.path_curves) do
			local w1 = path.widths[1]

			for i, bezier in ipairs(path.beziers) do
				G.setLineWidth(pi == self.path_selected and curve_selected_w or curve_w)
				G.setColor(self.path_selected == pi and color_curve_sel or color_curve)
				G.line(bezier:render())

				local p1x, p1y = bezier:getControlPoint(1)
				local p2x, p2y = bezier:getControlPoint(2)
				local p3x, p3y = bezier:getControlPoint(3)
				local p4x, p4y = bezier:getControlPoint(4)
				local w4 = path.widths[i + 1]

				if self.path_selected == pi then
					G.setLineWidth(width_w)
					G.setColor(color_width)

					if i == 1 then
						local n1x, n1y = V.mul(w1 / 2, V.rotate(km.pi_2, V.normalize(p2x - p1x, p2y - p1y)))

						G.line(p1x, p1y, p1x + n1x, p1y + n1y)
						G.line(p1x, p1y, p1x - n1x, p1y - n1y)
					end

					local n4x, n4y = V.mul(w4 / 2, V.rotate(km.pi_2, V.normalize(p4x - p3x, p4y - p3y)))

					G.line(p4x, p4y, p4x + n4x, p4y + n4y)
					G.line(p4x, p4y, p4x + -n4x, p4y - n4y)
					G.setLineWidth(1)
					G.setColor(color_handle)
					G.line(p1x, p1y, p2x, p2y)
					G.line(p3x, p3y, p4x, p4y)
					G.circle("fill", p2x, p2y, node_w / 2, 8)
					G.circle("fill", p3x, p3y, node_w / 2, 8)
				end
			end

			local fnt = G.getFont()

			G.setFont(F:f("DroidSansMono", 10))

			for i, bezier in ipairs(path.beziers) do
				local p1x, p1y = bezier:getControlPoint(1)
				local p4x, p4y = bezier:getControlPoint(4)

				G.setColor(color_node)

				if i == 1 then
					G.circle("fill", p1x, p1y, node_w, 6)
					G.setColor(color_curve)
					G.print(pi, p1x - 3, p1y + 6, 0, 1, -1)
					G.setColor(color_node)
				end

				if self.path_selected == pi then
					G.rectangle("fill", p4x - node_w / 2, p4y - node_w / 2, node_w, node_w)
				end
			end

			G.setFont(fnt)
		end

		if self.path_points then
			local fnt = G.getFont()

			G.setFont(F:f("DroidSansMono", 10))
			G.setColor(255, 255, 255, 255)

			for pi, path in ipairs(self.path_points) do
				for spi, subpath in ipairs(path) do
					for ni, o in pairs(subpath) do
						if spi == 1 and ni % 10 == 0 then
							G.circle("fill", o.x, o.y, 4, 6)
							G.setColor(0, 0, 0, 255)
							G.print(ni, o.x, o.y, 0, 1, -1)
							G.setColor(255, 255, 255, 255)
						else
							G.circle("fill", o.x, o.y, 2, 6)
						end
					end
				end
			end

			self.path_points = nil

			G.setFont(fnt)
		end

		G.setColor(255, 255, 255, 255)
		G.setCanvas()
		G.pop()
	end

	if self.grid_visible and (not self.grid_canvas or self.grid_dirty) then
		self.grid_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)
		G.translate(GR.ox, GR.oy)

		self.grid_canvas = G.newCanvas()

		G.setCanvas(self.grid_canvas)

		for i = 1, #GR.grid do
			for j = 1, #GR.grid[i] do
				local t = GR.grid[i][j]

				G.setColor(GR.grid_colors[t] or {
					100,
					100,
					100
				})
				G.rectangle("fill", (i - 1) * GR.cell_size, (j - 1) * GR.cell_size, GR.cell_size, GR.cell_size)
			end
		end

		G.setCanvas()
		G.setColor(255, 255, 255, 255)
		G.pop()
	end

	if self.entities_visible and (not self.entities_canvas or self.entities_dirty) then
		self.entities_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.entities_canvas = G.newCanvas()

		G.setCanvas(self.entities_canvas)

		for _, e in pairs(self.store.entities) do
			if e.pos then
				if e.render and e.render.sprites[1].hidden then
					G.setColor(0, 0, 200, 50)
				else
					G.setColor(0, 0, 200, 200)
				end

				G.rectangle("fill", e.pos.x - 2, e.pos.y - 8, 4, 16)
				G.rectangle("fill", e.pos.x - 8, e.pos.y - 2, 16, 4)

				if self.entities_selected and table.contains(self.entities_selected, e.id) and e.render and e.render.frames and e.render.frames[1] then
					local f = e.render.frames[1]

					if f.ss then
						local w, h = f.ss.size[1] * f.ss.ref_scale, f.ss.size[2] * f.ss.ref_scale

						G.rectangle("line", e.pos.x + f.anchor.x * -1 * w, e.pos.y + f.anchor.y * -1 * h, w, h)
					end
				end
			end
		end

		G.setCanvas()
		G.setColor(255, 255, 255, 255)
		G.pop()
	end

	if self.nav_visible and (not self.nav_canvas or self.nav_dirty) then
		self.nav_dirty = nil

		G.push()
		G.translate(rox, self.screen_h - roy)
		G.scale(gs, -gs)

		self.nav_canvas = G.newCanvas()

		G.setCanvas(self.nav_canvas)

		if self.store.level.nav_mesh then
			local sel_h_id = self.nav_entity_selected and tonumber(self.nav_entity_selected.ui.nav_mesh_id)
			local fnt = G.getFont()

			G.setFont(F:f("DroidSansMono", 24))

			local towers = {}

			for _, e in pairs(self.store.entities) do
				if e.ui and e.ui.nav_mesh_id then
					towers[tonumber(e.ui.nav_mesh_id)] = e

					local has_edges = false

					for _, v in pairs(self.store.level.nav_mesh[tonumber(e.ui.nav_mesh_id)] or {}) do
						if v ~= nil then
							has_edges = true
						end
					end

					G.setColor(0, 0, 0, 255)
					G.print(e.ui.nav_mesh_id, e.pos.x + 5, e.pos.y + 18, 0, 1, -1)

					if tonumber(e.ui.nav_mesh_id) == sel_h_id then
						G.setColor(255, 255, 0, 255)
					elseif has_edges then
						G.setColor(160, 160, 255, 255)
					else
						G.setColor(60, 60, 60, 255)
					end

					G.print(e.ui.nav_mesh_id, e.pos.x + 5 - 1, e.pos.y + 18 + 1, 0, 1, -1)
				end
			end

			G.setFont(fnt)
			G.setColor(0, 100, 255, 255)
			G.translate(0, 10)

			local ox, oy = 40, 15
			local ax, ay = 40, 15

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e or h_id ~= sel_h_id then
					G.setLineWidth(2)
					G.setColor(0, 100, 255, 50)
				else
					G.setLineWidth(4)
					G.setColor(0, 100, 255, 255)
				end

				local oe = towers[row[1]]

				if oe then
					G.line(e.pos.x + ox, e.pos.y, oe.pos.x - ax, oe.pos.y)
				end

				oe = towers[row[2]]

				if oe then
					G.line(e.pos.x, e.pos.y + oy, oe.pos.x, oe.pos.y - ay)
				end

				oe = towers[row[3]]

				if oe then
					G.line(e.pos.x - ox, e.pos.y, oe.pos.x + ax, oe.pos.y)
				end

				oe = towers[row[4]]

				if oe then
					G.line(e.pos.x, e.pos.y - oy, oe.pos.x, oe.pos.y + ay)
				end
			end

			local s2 = 10
			local s3 = 15

			G.setColor(0, 0, 200, 255)

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e or h_id ~= sel_h_id then
					G.setColor(0, 0, 200, 100)
				else
					G.setColor(0, 0, 200, 255)
				end

				for i = 1, 4 do
					local oe = towers[row[i]]

					if oe then
						local tx, ty, ta, a, r

						if i == 1 then
							tx, ty = e.pos.x + ox, e.pos.y
							a, r = V.toPolar(oe.pos.x - ax - (e.pos.x + ox), oe.pos.y - e.pos.y)
						elseif i == 2 then
							tx, ty = e.pos.x, e.pos.y + oy
							a, r = V.toPolar(oe.pos.x - e.pos.x, oe.pos.y - ay - (e.pos.y - oy))
						elseif i == 3 then
							a, r = V.toPolar(oe.pos.x + ax - (e.pos.x - ox), oe.pos.y - e.pos.y)
							tx, ty = e.pos.x - ox, e.pos.y
						else
							a, r = V.toPolar(oe.pos.x - e.pos.x, oe.pos.y + ay - (e.pos.y + oy))
							tx, ty = e.pos.x, e.pos.y - oy
						end

						if a then
							G.push()
							G.translate(tx, ty)
							G.rotate(a)
							G.translate(s3, 0)
							G.polygon("fill", s2, 0, 0, s2, 0, -s2)
							G.pop()
						end
					end
				end
			end
		end

		G.setCanvas()
		G.setColor(255, 255, 255, 255)
		G.pop()
	end

	G.push()
	G.translate(self.gui.window.pos.x, self.gui.window.pos.y)
	G.push()
	G.translate(rox, roy)
	G.scale(gs, gs)

	last_idx = RU.draw_frames_range(self.store.render_frames, 1, Z_GUI - 1)

	G.pop()

	if self.paths_visible then
		G.draw(self.paths_canvas)

		if self.gui.path_nodes_selected then
			G.push()
			G.translate(rox, self.screen_h - roy)
			G.scale(gs, -gs)
			G.setColor(color_selected)
			G.setLineWidth(sel_w)

			for _, item in pairs(self.gui.path_nodes_selected) do
				local pi, ni = unpack(item)
				local path = self.path_curves[pi]

				if path then
					local p = path.nodes[ni]

					if p then
						G.circle("line", p.x, p.y, node_w)
					end
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end
	end

	if self.grid_visible then
		G.setColor(255, 255, 255, 100)
		G.draw(self.grid_canvas)
		G.setColor(255, 255, 255, 255)

		if self.tool_pointer.tool == "grid" then
			G.push()
			G.translate(rox, self.screen_h - roy)
			G.scale(gs, -gs)

			local bx, by = self.tool_pointer.x, self.tool_pointer.y
			local bsize = self.tool_pointer.size
			local bw = bsize / 2 * GR.cell_size

			G.setColor(255, 255, 255, 200)
			G.setLineWidth(1)
			G.line(bx - bw, by - bw, bx + bw, by - bw)
			G.line(bx + bw, by - bw, bx + bw, by + bw)
			G.line(bx + bw, by + bw, bx - bw, by + bw)
			G.line(bx - bw, by + bw, bx - bw, by - bw)
			G.pop()
		end
	end

	if self.entities_visible then
		G.setColor(255, 255, 255, 255)
		G.draw(self.entities_canvas)
		G.setColor(255, 255, 255, 255)
	end

	if self.nav_visible then
		G.setColor(255, 255, 255, 255)
		G.draw(self.nav_canvas)
		G.setColor(255, 255, 255, 255)
	end

	G.setColor(0, 0, 0, 200)
	G.setLineWidth(2)
	G.push()
	G.translate(rox, self.screen_h - roy)
	G.scale(gs, -gs)
	G.line(0, 0, 0, 768)
	G.line(1024, 0, 1024, 768)
	G.print("4:3", 8, 14, 0, 1, -1)
	G.pop()
	G.setLineWidth(1)
	G.setColor(255, 255, 255, 255)
	self.gui.window:draw()
	G.pop()
end

function editor:level_save(idx, mode)
	if not idx then
		return
	end

	local s = self.store
	local ss

	s.level_idx = idx
	s.level_name = "level" .. string.format("%02i", idx)

	log.debug("saving level %s", idx)
	P:save_curves(s.level_name)
	GR:save(s.level_name)
	self:serialize_level(s)

	ss = table.deepclone(s.level.data)

	self.save_data(ss, s.level_name)
end

function editor:level_load(idx, mode)
	log.debug("loading level %s", idx)

	self.undo_active = false
	self.store = {}

	local systems
	if IS_KR5 then
		systems = sys
	else
		systems = self.simulation_systems
	end
	simulation:init(self.store, systems, self.simulation_systems, TICK_LENGTH)

	self.simulation = simulation

	A:load()
	E:load()

	local s = self.store

	s.level_idx = idx
	s.level_name = "level" .. string.format("%02i", idx)
	s.level_mode = mode
	s.level_difficulty = DIFFICULTY_EASY
	s.level = LU.load_level(s, s.level_name, true)

	director:load_texture_groups(s.level.data.required_textures, director.params.texture_size, self.ref_res, false, "game_editor")
	
	LU.insert_entities(self.store, s.level.data.entities_list, true)

	if IS_KR5 then
		EXO:load(s.level.data.required_exoskeletons)
	end

	self.entities_dirty = true

	if not GR:load(s.level_name) then
		local gox, goy = -192, 0
		local bgw, bgh = 1408, 768
		local gw, gh = math.ceil(bgw / GR.cell_size), math.ceil(bgh / GR.cell_size)

		GR:init_grid(gw, gh, gox, goy, GR.cell_size)
	end

	self.grid_dirty = true

	P:load_curves(s.level_name)

	self.path_curves = P.path_curves
	self.path_connections = P.path_connections
	self.active_paths = P.active_paths

	self:update_curves()

	self.paths_dirty = true

	self.simulation:update(0.03333333333333333)

	self.nav_entity_selected = nil

	if not s.level.nav_mesh then
		s.level.nav_mesh = {}
		s.level.data.nav_mesh = s.level.nav_mesh
	end

	self:sanitize_nav_mesh(s.level.nav_mesh)

	self.nav_dirty = true
	self.undo_stack = {}
	self.undo_active = true

	self.gui:level_loaded(idx)
end

function editor:entities_at_pos(wx, wy, size)
	local found = {}

	for _, e in pairs(self.store.entities) do
		local select_size = size or 4

		if e.pos and wx > e.pos.x - select_size and wx < e.pos.x + select_size and wy > e.pos.y - select_size and wy < e.pos.y + select_size then
			table.insert(found, e)
		end
	end

	return found
end

function editor:serialize_entity(e)
	local t = {}

	t.template = e.template_name

	if e.pos then
		t.pos = V.vclone(e.pos)
	end

	t._id = e.id

	if e.editor and e.editor.props then
		for _, prop in pairs(e.editor.props) do
			local prop_name, prop_type = unpack(prop)

			t[prop_name] = LU.eval_get_prop(e, prop_name)
		end
	end

	return t
end

function editor:serialize_level(store)
	local list = store.level.data.entities_list

	for _, e in pairs(store.entities) do
		if e.editor and e.editor.scaffold then
			-- block empty
		else
			local se = self:serialize_entity(e)
			local de = list._idx[e.id]

			if de then
				table.deepmerge(de, se)
			else
				table.insert(list, se)

				list._idx[e.id] = se
			end
		end
	end

	local data = store.level.data

	if data._before_ov then
		for k, v in pairs(data._before_ov) do
			if v == NULL then
				data[k] = nil
			else
				data[k] = table.deepclone(v)
			end
		end
	end
end

function editor:undo_push_entity(from_drag, eid, ...)
	if not self.undo_active then
		return
	end

	local args = {
		...
	}
	local props = {}

	for i = 1, #args / 2 do
		props[args[2 * i - 1]] = args[2 * i]
	end

	local last = self.undo_stack[#self.undo_stack]

	if from_drag and last and last.from_drag then
		if last.from_drag and eid == last.id then
			for k, v in pairs(props) do
				if last.props[k] then
					last.props[k] = props[k]
				end
			end

			log.debug("undo: updated last entry:%s", getdump(last))
		end
	else
		local item = {
			type = "entity",
			from_drag = from_drag,
			id = eid,
			props = props
		}

		log.debug("undo: new entry: %s", getdump(item))
		table.insert(self.undo_stack, item)
	end

	if #self.undo_stack > 1000 then
		log.error("TODO: trim undo stack!")
	end
end

function editor:undo_pop()
	local item = table.remove(self.undo_stack)

	if item and item.type == "entity" then
		local e = self.store.entities[item.id]

		if not e then
			log.error("Undo could not find entity with id:%s", item.id)

			return
		end

		for k, v in pairs(item.props) do
			LU.eval_set_prop(e, k, v)
		end
	end
end

function editor:update_curves(pi, touched)
	if pi and touched then
		local path = self.path_curves[pi]
		local nodes = path.nodes
		local beziers = path.beziers

		table.sort(touched)

		for _, ni in pairs(touched) do
			local p = nodes[ni]
			local bni = (ni - 1) % 3 + 1
			local bi = math.floor((ni - 1) / 3) + 1
			local bez_p = beziers[bi - 1]
			local bez_n = beziers[bi]

			if (ni - 1) % 3 == 0 then
				if bez_n then
					bez_n:setControlPoint(1, p.x, p.y)
				end

				if bez_p then
					bez_p:setControlPoint(4, p.x, p.y)
				end
			elseif bez_n then
				bez_n:setControlPoint(bni, p.x, p.y)
			end
		end
	else
		for _, path in pairs(self.path_curves) do
			local n = path.nodes
			local w = path.widths
			local scount = (#n - 1) / 3
			local beziers = {}

			for i = 1, scount do
				local j = 3 * (i - 1) + 1
				local p1, p2, p3, p4 = n[j], n[j + 1], n[j + 2], n[j + 3]

				table.insert(beziers, love.math.newBezierCurve({
					p1.x,
					p1.y,
					p2.x,
					p2.y,
					p3.x,
					p3.y,
					p4.x,
					p4.y
				}))
			end

			path.beziers = beziers
		end
	end

	self.paths_dirty = true
end

function editor:set_node_width(pi, ni, w)
	local wi = (ni - 1) / 3 + 1
	local path = self.path_curves[pi]

	path.widths[wi] = w
	self.paths_dirty = true
end

function editor:set_node_pos(pi, ni, x, y)
	local touched = {}
	local path = self.path_curves[pi]
	local nodes = path.nodes
	local beziers = path.beziers
	local node = nodes[ni]
	local dx, dy = x - node.x, y - node.y

	node.x, node.y = x, y

	table.insert(touched, ni)

	if (ni - 1) % 3 == 0 then
		for _, oi in pairs({
			-1,
			1
		}) do
			local i = ni + oi
			local nn = nodes[i]

			if nn then
				nn.x, nn.y = nn.x + dx, nn.y + dy

				table.insert(touched, i)
			end
		end
	else
		local oni = ni % 3 == 0 and ni + 2 or ni - 2
		local cni = ni % 3 == 0 and ni + 1 or ni - 1
		local on = nodes[oni]
		local cn = nodes[cni]
		local nn = nodes[ni]

		if nn and on and cn then
			local ol = V.len(on.x - cn.x, on.y - cn.y)
			local donx, dony = V.mul(ol, V.rotate(km.pi, V.normalize(nn.x - cn.x, nn.y - cn.y)))

			on.x, on.y = cn.x + donx, cn.y + dony

			table.insert(touched, oni)
		end
	end

	self:update_curves(pi, touched)
end

function editor:extend_path(pi, ni, x, y)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if ni ~= 1 and ni ~= #nodes then
		return
	end

	if ni == #nodes then
		local ph2 = nodes[ni - 1]
		local n1 = nodes[ni]
		local h1 = V.v(V.add(n1.x, n1.y, V.rotate(km.pi, ph2.x - n1.x, ph2.y - n1.y)))

		if not x or not y then
			x, y = n1.x + 100, n1.y
		end

		local n2 = V.v(x, y)
		local h2 = V.v(V.add(n2.x, n2.y, V.mul(0.25, n1.x - n2.x, n1.y - n2.y)))

		table.insert(nodes, h1)
		table.insert(nodes, h2)
		table.insert(nodes, n2)

		local wi = (ni - 1) / 3 + 1

		table.insert(widths, widths[wi])
	elseif ni == 1 then
		local ph1 = nodes[2]
		local n2 = nodes[1]
		local h2 = V.v(V.add(n2.x, n2.y, V.rotate(km.pi, ph1.x - n2.x, ph1.y - n2.y)))

		if not x or not y then
			x, y = n2.x - 100, n2.y
		end

		local n1 = V.v(x, y)
		local h1 = V.v(V.add(n1.x, n1.y, V.mul(0.25, n2.x - n1.x, n2.y - n1.y)))

		table.insert(nodes, 1, h2)
		table.insert(nodes, 1, h1)
		table.insert(nodes, 1, n1)
		table.insert(widths, 1, widths[1])
	end

	self:update_curves()
end

function editor:subdivide_path(pi, ni, x, y)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if (ni - 1) % 3 ~= 0 or ni == 1 or ni == #nodes then
		return
	end

	local n = nodes[ni]
	local ii = ni + 2
	local wi = (ni - 1) / 3 + 1

	if x and y then
		local ph = nodes[ni - 1]
		local nh = nodes[ni + 1]
		local xya = V.angleTo(x - n.x, y - n.y)
		local pa = math.abs(km.short_angle(xya, V.angleTo(ph.x - n.x, ph.y - n.y)))
		local na = math.abs(km.short_angle(xya, V.angleTo(nh.x - n.x, nh.y - n.y)))

		log.error("pa=%s na=%s", pa, na)

		ii = pa < na and ni - 1 or ni + 2
		wi = pa < na and wi or wi + 1
	else
		x, y = n.x + 50, n.y
	end

	local pn1 = nodes[ii - 2]
	local nn2 = nodes[ii + 1]
	local nn1 = V.v(x, y)
	local nh1 = V.v(V.add(nn1.x, nn1.y, V.mul(0.2, nn2.x - pn1.x, nn2.y - pn1.y)))
	local ph2 = V.v(V.add(nn1.x, nn1.y, V.rotate(km.pi, nh1.x - nn1.x, nh1.y - nn1.y)))

	table.insert(nodes, ii, nh1)
	table.insert(nodes, ii, nn1)
	table.insert(nodes, ii, ph2)
	table.insert(widths, wi, widths[wi - 1])
	self:update_curves()
end

function editor:remove_path(pi)
	table.remove(self.path_curves, pi)
	table.remove(self.active_paths, pi)
	table.remove(self.path_connections, pi)
	self:update_curves()
end

function editor:create_path()
	local x, y = REF_W / 2, REF_H / 2
	local d = 50
	local nodes = {
		V.v(x, y),
		V.v(x + d, y),
		V.v(x + 2 * d, y + d),
		V.v(x + 3 * d, y + d)
	}
	local widths = {
		DEFAULT_PATH_WIDTH,
		DEFAULT_PATH_WIDTH
	}

	table.insert(self.path_curves, {
		nodes = nodes,
		widths = widths
	})
	table.insert(self.active_paths, true)
	self:update_curves()

	return #self.path_curves
end

function editor:remove_path_node(pi, ni)
	local path = self.path_curves[pi]
	local widths = path.widths
	local nodes = path.nodes

	if (ni - 1) % 3 ~= 0 then
		return
	end

	if #nodes <= 4 then
		return
	end

	local wi = (ni - 1) / 3 + 1

	table.remove(widths, wi)

	if ni == #nodes then
		ni = ni - 2
	elseif ni ~= 1 then
		ni = ni - 1
	end

	for i = 1, 3 do
		table.remove(nodes, ni)
	end

	self:update_curves()
end

function editor:duplicate_path(pi)
	local path = self.path_curves[pi]
	local new_path = table.deepclone(path)

	table.insert(self.path_curves, new_path)
	table.insert(self.active_paths, true)
	self:update_curves()

	return #self.path_curves
end

function editor:flip_path(pi)
	local path = self.path_curves[pi]

	path.nodes = table.reverse(path.nodes)
	path.widths = table.reverse(path.widths)

	self:update_curves()
end

function editor:preview_path_points(pi)
	self.path_points = P:generate_paths(pi)
	self.paths_dirty = true
end

function editor:change_path_idx(pi, npi)
	local curves = self.path_curves

	if pi == npi or not curves[pi] or npi > #curves then
		return
	end

	local conn_idx = {}

	for i = 1, #self.path_connections do
		local ci = self.path_connections[i]

		conn_idx[i] = ci and curves[ci] or nil
	end

	local p = curves[pi]
	local p_active = self.active_paths[pi]

	if npi < pi then
		table.remove(curves, pi)
		table.insert(curves, npi, p)
		table.remove(self.active_paths, pi)
		table.insert(self.active_paths, npi, p_active)
	else
		table.insert(curves, npi + 1, p)
		table.remove(curves, pi)
		table.insert(self.active_paths, npi + 1, p_active)
		table.remove(self.active_paths, pi)
	end

	self.path_connections = {}

	for i = 1, #conn_idx do
		do
			local c = conn_idx[i]

			if c then
				for ci = 1, #curves do
					if curves[ci] == c then
						self.path_connections[i] = ci

						goto label_29_0
					end
				end

				self.path_connections[i] = nil
			end
		end

		::label_29_0::
	end

	self:update_curves()
end

function editor:set_path_connection(pi, cpi)
	if not self.path_connections then
		self.path_connections = {}
	end

	if cpi < 1 or cpi > #self.path_curves then
		self.path_connections[pi] = nil
	else
		self.path_connections[pi] = cpi
	end
end

function editor:set_path_active(pi, value)
	if not self.active_paths then
		self.active_paths = {}
	end

	self.active_paths[pi] = value
end

function editor:sanitize_nav_mesh(nav_mesh)
	for _, e in pairs(self.store.entities) do
		if e and e.tower and e.tower.holder_id and e.ui and not e.ui.nav_mesh_id then
			e.ui.nav_mesh_id = e.tower.holder_id
		end
	end

	local hids = {}

	for _, e in pairs(self.store.entities) do
		if e.ui and e.ui.nav_mesh_id then
			local hid = e.ui.nav_mesh_id

			if tonumber(hid) == 0 then
				log.error("WARNING: tower[%s] holder_id cannot be 0!!", e.id)
			end

			table.insert(hids, tonumber(e.ui.nav_mesh_id))
		end
	end

	table.sort(hids)

	for _, k in pairs(hids) do
		if not nav_mesh[k] then
			nav_mesh[k] = {}
		end
	end

	local remove = {}

	for k, v in pairs(nav_mesh) do
		if not table.contains(hids, k) then
			table.insert(remove, k)
		end
	end

	for _, k in pairs(remove) do
		nav_mesh[k] = nil
	end
end

return editor
