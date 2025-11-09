-- chunkname: @./lib/klove/kui_db.lua

local log = require("klua.log"):new("kui_db")
local serpent = require("serpent")

require("klua.string")

local kui_db = {}

function kui_db:init(templates_path, reload)
	self.path = templates_path
	self.paths = string.split(templates_path, ";")
	self.reload = reload
	self.templates = {}
end

if DEBUG then
	function kui_db:write(name, str)
		local usepath = self.paths[1]

		for _, path in pairs(self.paths) do
			local filename = path .. "/" .. name .. ".lua"

			if love.filesystem.getInfo(filename) then
				usepath = path

				break
			end
		end

		local filename = KR_FULLPATH_BASE .. "/" .. usepath .. "/" .. name .. ".lua"
		local out = "return " .. str .. "\n"
		local f = io.open(filename, "w")

		f:write(out)
		f:flush()
		f:close()
	end

	function kui_db:put(name, str)
		self:write(name, str)

		self.templates[name] = str
	end

	function kui_db:put_table(name, t)
		self:extract_templates(t)

		local str = self:pretty_print(t)

		self:put(name, str)
	end
end

function kui_db:read(name)
	for _, path in pairs(self.paths) do
		local filename = path .. "/" .. name .. ".lua"

		if love.filesystem.getInfo(filename) then
			log.debug("loading template:%s from file %s", name, filename)

			local str = love.filesystem.read(filename)

			return str
		end
	end
end

function kui_db:get(name)
	if self.reload or not self.templates[name] then
		local chunk = self:read(name)

		if not chunk then
			log.error("Error finding template %s", name)

			return nil
		end

		self.templates[name] = chunk
	end

	return self.templates[name]
end

function kui_db:get_table(name, ctx)
	local str = self:get(name)
	local chunk, err = loadstring(str)

	if not chunk then
		log.error("Error loading template %s. Error: %s", name, err)

		return nil
	end

	local env = {}

	env.ctx = ctx

	function env.v(x, y)
		return {
			x = x,
			y = y
		}
	end

	function env.rad(a)
		return a * math.pi / 180
	end

	function env.r(x, y, w, h)
		return {
			pos = env.v(x, y),
			size = env.v(w, h)
		}
	end

	env.string = string
	env.math = math
	env._ = _

	setfenv(chunk, env)

	local ok, result = pcall(chunk)

	if not ok then
		log.error("Error calling template %s. Error: %s", name, tostring(result))

		return nil
	end

	local out = self:filter_table(result, ctx)

	out = self:replace_templates(out, ctx)

	return out
end

function kui_db:filter_table(t, ctx)
	if t.WHEN ~= nil and (type(t.WHEN) == "function" and not t.WHEN() or t.WHEN == false) then
		log.debug("WHEN failed for %s", t.id)

		return nil
	end

	if t.UNLESS ~= nil and (type(t.UNLESS) == "function" and t.UNLESS() or t.UNLESS == true) then
		log.debug("UNLESS failed for %s", t.id)

		return nil
	end

	if t.children then
		local ac

		for _, ct in pairs(t.children) do
			local nc = self:filter_table(ct, ctx)

			if nc then
				ac = ac or {}

				table.insert(ac, nc)
			end
		end

		t.children = ac
	end

	return t
end

function kui_db:replace_templates(t, ctx)
	local out = t

	if t.template_name then
		local n = t.template_name
		local tt = self:get_table(n, ctx)

		if tt then
			out = table.deepmerge(tt, t, new)
		end
	elseif t.children then
		local ac = {}

		for _, ct in pairs(t.children) do
			local nc = self:replace_templates(ct, ctx)

			table.insert(ac, nc)
		end

		t.children = ac
	end

	return out
end

function kui_db:extract_templates(t)
	if t.template_name and t._template_table then
		self:put_table(t.template_name, t._template_table)

		t._template_table = nil
	end

	if t.children then
		for _, c in pairs(t.children) do
			self:extract_templates(c)
		end
	end
end

function kui_db:pretty_print(t)
	local function custom_sort(k, o)
		local function sort(a, b)
			if a == "class" then
				return true
			elseif b == "class" then
				return false
			elseif a == "id" then
				return true
			elseif b == "id" then
				return false
			elseif a == "children" then
				return false
			elseif b == "children" then
				return true
			else
				return a < b
			end
		end

		table.sort(k, sort)
	end

	require("debug")

	local function custom_format(tag, head, body, tail, level)
		local class_body = string.find(body, "^class")

		return tag .. (class_body and "\n" .. string.rep("    ", level) or "") .. head .. body .. tail
	end

	return serpent.line(t, {
		comment = false,
		sortkeys = custom_sort,
		custom = custom_format,
		keyignore = {
			_template_table = true
		}
	})
end

return kui_db
