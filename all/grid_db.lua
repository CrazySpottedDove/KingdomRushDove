-- chunkname: @./all/grid_db.lua
local log = require("lib.klua.log"):new("grid_db")
local FS = love.filesystem
local km = require("lib.klua.macros")
require("lib.klua.table")
local GA = require("grid_a_star")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
require("constants")
local grid_db = {}
grid_db.grid = {}
grid_db.ox = 0
grid_db.oy = 0
grid_db.waypoints_cache = {}
grid_db.cell_size = 16
grid_db.grid_colors = {
	[bor(TERRAIN_NONE)] = {0, 0, 0},
	[bor(TERRAIN_LAND)] = {0, 100, 0},
	[bor(TERRAIN_LAND, TERRAIN_NOWALK)] = {80, 255, 80},
	[bor(TERRAIN_LAND, TERRAIN_FAERIE)] = {255, 100, 80},
	[bor(TERRAIN_LAND, TERRAIN_NOWALK, TERRAIN_FAERIE)] = {255, 255, 80},
	[bor(TERRAIN_LAND, TERRAIN_ICE)] = {180, 180, 180},
	[bor(TERRAIN_LAND, TERRAIN_NOWALK, TERRAIN_ICE)] = {255, 255, 255},
	[bor(TERRAIN_WATER)] = {0, 0, 100},
	[bor(TERRAIN_WATER, TERRAIN_SHALLOW)] = {80, 80, 255},
	[bor(TERRAIN_CLIFF)] = {100, 0, 0},
	[bor(TERRAIN_CLIFF, TERRAIN_NOWALK)] = {255, 80, 80},
	[bor(TERRAIN_NONE, TERRAIN_NOWALK)] = {255, 0, 0},
	path = {0, 220, 220}
}
grid_db.cell_type_names = {
	[TERRAIN_NONE] = ".",
	[TERRAIN_LAND] = "L",
	[TERRAIN_WATER] = "W",
	[TERRAIN_CLIFF] = "C",
	[TERRAIN_NOWALK] = "n",
	[TERRAIN_SHALLOW] = "s",
	[TERRAIN_FAERIE] = "f",
	[TERRAIN_ICE] = "i"
}

function grid_db:load_legacy(grid_name)
	local grid_list = require("data.levels." .. grid_name .. "_grid")
	local grid = {}
	local i_col, col

	for _, p in ipairs(grid_list.grid) do
		local p_col = 1 + tonumber(p.column)
		local p_row = 1 + tonumber(p.row)
		local p_type = tonumber(p.terrainType)

		if p_col ~= i_col then
			if col then
				grid[i_col] = col
			end

			i_col = p_col
			col = {}
		end

		local tt = 0

		if p_type == 1 then
			tt = TERRAIN_LAND
		elseif p_type == 2 then
			tt = bor(TERRAIN_LAND, TERRAIN_NOWALK)
		elseif p_type == 4 then
			tt = TERRAIN_WATER
		elseif p_type == 8 then
			tt = bor(TERRAIN_WATER, TERRAIN_SHALLOW)
		elseif p_type == 16 then
			tt = bor(TERRAIN_WATER, TERRAIN_NOWALK)
		end

		col[p_row] = tt
	end

	if i_col then
		grid[i_col] = col
	end

	self.grid = grid
	self.grid_w = #grid
	self.grid_h = #grid[1]
end

function grid_db:init_grid(w, h, ox, oy, cell_size)
	self.ox = ox
	self.oy = oy

	if cell_size then
		self.cell_size = cell_size
	end

	local grid = {}

	for i = 1, w do
		grid[i] = {}

		for j = 1, h do
			grid[i][j] = TERRAIN_NONE
		end
	end

	self.grid = grid
	self.grid_w = #grid
	self.grid_h = #grid[1]
end

function grid_db:load(name)
	self.waypoints_cache = {}
	local fn = KR_PATH_GAME .. "/data/levels/" .. name .. "_grid.lua"
	local f, err = love.filesystem.load(fn)

	if not err then
		local file_data = f()
		self.grid = file_data.grid
		self.ox = file_data.ox or 0
		self.oy = file_data.oy or 0
		self.grid_w = #self.grid
		self.grid_h = #self.grid[1]
		return true
	else
		log.error("Failed to load %s - error: %s", fn, err)
		return false
	end
end

if DEBUG then
	function grid_db:save(name)
		local filename = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. name .. "_grid.lua"
		local f = io.open(filename, "w")
		f:write("return {\n")
		f:write(string.format("ox=%s, oy=%s,\n", self.ox, self.oy))
		f:write("grid={\n")

		for i = 1, #self.grid do
			f:write("{")

			for j = 1, #self.grid[i] do
				f:write(string.format("%s,", self.grid[i][j]))
			end

			f:write("},")
		end

		f:write("}")
		f:write("}\n")
		f:flush()
		f:close()
	end
end

function grid_db:set_cell_type(x, y, type)
	local i = math.ceil((x - self.ox) / self.cell_size)
	local j = math.ceil((y - self.oy) / self.cell_size)

	if i <= 0 or i > self.grid_w or j <= 0 or j > self.grid_h then
		return 
	end

	self.grid[i][j] = type
end

function grid_db:cell_type(x, y)
	local i, j = self:get_coords(x, y)
	return self.grid[i][j], i, j
end

function grid_db:cell_is(x, y, is_type)
	local type = self:cell_type(x, y)
	return band(type, is_type) ~= 0
end

function grid_db:cell_is_only(x, y, mask)
	local type = self:cell_type(x, y)
	return band(type, bnot(mask)) == 0
end

function grid_db:get_coords(x, y)
	local i = math.ceil((x - self.ox) / self.cell_size)
	local j = math.ceil((y - self.oy) / self.cell_size)
	i = km.clamp(1, self.grid_w, i)
	j = km.clamp(1, self.grid_h, j)
	return i, j
end

function grid_db:set_cell(i, j, type)
	self.grid[i][j] = type
end

function grid_db:get_cell(i, j)
	return self.grid[i][j]
end

function grid_db:cell_pos(i, j)
	local x = i * self.cell_size + self.ox
	local y = j * self.cell_size + self.oy
	x = x - self.cell_size * 0.5
	y = y - self.cell_size * 0.5
	return x, y
end

function grid_db:set_grid_size(nw, nh)
	local dx = math.floor((nw - self.grid_w) * 0.5)
	local dy = math.floor((nh - self.grid_h) * 0.5)
	local og = self.grid
	local ng = {}

	for i = 1, nw do
		ng[i] = {}

		for j = 1, nh do
			ng[i][j] = og[i - dx] and og[i - dx][j - dy] or TERRAIN_NONE
		end
	end

	self.grid = ng
	self.grid_w = #self.grid
	self.grid_h = #self.grid[1]
end

function grid_db:set_grid_offset(x, y)
	self.ox = x
	self.oy = y
end

function grid_db:print_cell(type)
	local names = self.cell_type_names
	local st = "?"

	for i = 0, 7 do
		local v = 2 ^ i

		if band(type, v) ~= 0 then
			st = names[v]
			break
		end
	end

	local af = {}

	for i = 8, 8 + TERRAIN_PROPS_COUNT - 1 do
		local idx = i - 7
		local v = 2 ^ i

		if band(type, v) ~= 0 then
			af[idx] = names[v]
		else
			af[idx] = "."
		end
	end

	return string.format("%s:%s", st, table.concat(af, ""))
end

function grid_db:find_waypoints(from, from_fallback, to, valid_terrains, force_recalc)
	local function valid_cell_fn(i, j, cell)
		return band(cell, bnot(valid_terrains)) == 0
	end

	local fi, fj = self:get_coords(from.x, from.y)
	local ti, tj = self:get_coords(to.x, to.y)
	local path_c

	if from_fallback and not valid_cell_fn(fi, fj, self.grid[fi][fj]) then
		log.debug("find_waypoints: getting from from_fallback: %s,%s", from_fallback.x, from_fallback.y)
		fi, fj = self:get_coords(from_fallback.x, from_fallback.y)
	end

	local from_c, to_c = {
		x = fi,
		y = fj
	}, {
		x = ti,
		y = tj
	}

	if not valid_cell_fn(fi, fj, self.grid[fi][fj]) then
		log.warning("find_waypoints: starting coords %s,%s are in invalid terrain. searching nearby...", fi, fj)
		from_c = GA.find_nearest_valid(from_c, self.grid, valid_cell_fn, 5)

		if not from_c then
			return nil
		end

		fi = from_c.x
		fj = from_c.y
	end

	if not force_recalc and self.waypoints_cache and self.waypoints_cache.path and self.waypoints_cache.from_c.x == fi and self.waypoints_cache.from_c.y == fj and self.waypoints_cache.to_c.x == ti and self.waypoints_cache.to_c.y == tj then
		return self.waypoints_cache.path
	else
		self.waypoints_cache.from_c = nil
		self.waypoints_cache.to_c = nil
		self.waypoints_cache.path_c = nil
		self.waypoints_cache.path = nil
		path_c = GA.get_path(from_c, to_c, self.grid, valid_cell_fn)
	end

	if path_c == nil then
		return nil
	end

	local result = {}

	for i, p in ipairs(path_c) do
		if i == 1 then
		-- block empty
		elseif i == #path_c then
			table.insert(result, to)
		else
			local x = p.x * self.cell_size + self.ox
			local y = p.y * self.cell_size + self.oy
			x = x - self.cell_size * 0.5
			y = y - self.cell_size * 0.5
			table.insert(result, {
				x = x,
				y = y
			})
		end
	end

	self.waypoints_cache.from_c = from_c
	self.waypoints_cache.to_c = to_c
	self.waypoints_cache.path_c = path_c
	self.waypoints_cache.path = result
	log.debug("a_star path: f:%s,%s t:%s,%s p:%s", from.x, from.y, to.x, to.y, GA.dump_path(result))
	return result
end

function grid_db:find_line_waypoints(from, to, valid_terrains)
	local function get_line_coords(from, to)
		local coords = {}
		local fi, fj = self:get_coords(from.x, from.y)
		local ti, tj = self:get_coords(to.x, to.y)
		local sx, sy, dx, dy

		if fi < ti then
			dx = ti - fi
			sx = 1
		else
			dx = fi - ti
			sx = -1
		end

		if fj < tj then
			dy = tj - fj
			sy = 1
		else
			dy = fj - tj
			sy = -1
		end

		local e1, e2 = dx - dy
		local x, y = fi, fj

		while x ~= ti or y ~= tj do
			e2 = e1 + e1

			if e2 > -dy then
				e1 = e1 - dy
				x = x + sx
			end

			if e2 < dx then
				e1 = e1 + dx
				y = y + sy
			end

			table.insert(coords, {
				x = x,
				y = y
			})
		end

		return coords
	end

	local points = {}
	local coords = get_line_coords(from, to)

	for _, p in pairs(coords) do
		local cell = self:get_cell(p.x, p.y)

		if band(cell, bnot(valid_terrains)) ~= 0 then
			return nil
		end

		local x, y = self:cell_pos(p.x, p.y)
		table.insert(points, {
			x = x,
			y = y
		})
	end

	return points, coords
end

return grid_db
