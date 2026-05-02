-- DEPRECATED: 我们的 UI 并不稳定，我们并不希望有人使用这个库，保留它只是考虑历史兼容性。
local log = require("lib.klua.log"):new("kui_db")

require("lib.klua.string")

local kui_db = {}
local V = require("lib.klua.vector")
function kui_db:init(templates_path, reload)
	self.path = templates_path
	self.paths = string.split(templates_path, ";")
	self.reload = reload
	self.templates = {}
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

	env.v = V.v

	function env.rad(a)
		return a * math.pi / 180
	end

	env.r = V.r

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

return kui_db
