local registry = {
	_defs = {}
}

local function assert_id(id)
	if not id or id == "" then
		error("tech id is required")
	end
end

function registry.register(def)
	assert(type(def) == "table", "tech def must be table")
	assert_id(def.id)
	if registry._defs[def.id] then
		error("duplicate tech id register: " .. def.id)
	end
	registry._defs[def.id] = def
	return def
end

function registry.register_many(defs)
	if not defs then
		return
	end
	for _, def in pairs(defs) do
		registry.register(def)
	end
end

function registry.get(id)
	return registry._defs[id]
end

function registry.all()
	return registry._defs
end

function registry.ids()
	local out = {}
	for id, _ in pairs(registry._defs) do
		out[#out + 1] = id
	end
	table.sort(out)
	return out
end

function registry.apply_template(id, level, endless, ctx)
	local def = registry.get(id)
	if not def or not def.apply_template then
		return false
	end
	def.apply_template(level, endless, ctx)
	return true
end

function registry.apply_runtime(id, level, store, endless, ctx)
	local def = registry.get(id)
	if not def or not def.apply_runtime then
		return false
	end
	def.apply_runtime(level, store, endless, ctx)
	return true
end

return registry
