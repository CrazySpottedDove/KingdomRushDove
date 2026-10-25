local main_script = {}

local perf = require("dove_modules.perf.perf")

local log = require("lib.klua.log"):new("systems")
local E = require("entity_db")

local compiler
local function get_compiler()
	compiler = compiler or require("precompile.interface")
	return compiler
end

main_script.name = "main_script"

function main_script:init(store)
	store.entities_with_main_script_on_update_count = 0
	store.entities_with_main_script_on_update = {}
	store.entities_with_main_script_on_update_index = {}
	store.entities_with_main_script_on_update_count1 = 0
	store.entities_with_main_script_on_update1 = {}
	store.entities_with_main_script_on_update_index1 = {}
	store._dominant_entity = nil
end

function main_script:on_insert(entity, store)
	if entity.main_script then
		get_compiler():ensure_entity_type(entity)
		if entity.main_script.insert then
			store._dominant_entity = entity
			local result = entity.main_script.insert(entity, store)
			store._dominant_entity = nil
			return result
		else
			return true
		end
	else
		return true
	end
end

function main_script:on_insert_unconditional(e, d)
	local s = e.main_script
	if s and s.update then
		s._pc_queue_type = s.type
		if s.type == 0 then
			d.entities_with_main_script_on_update_count = d.entities_with_main_script_on_update_count + 1
			d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count] = e
			d.entities_with_main_script_on_update_index[e.id] = d.entities_with_main_script_on_update_count
		else
			d.entities_with_main_script_on_update_count1 = d.entities_with_main_script_on_update_count1 + 1
			d.entities_with_main_script_on_update1[d.entities_with_main_script_on_update_count1] = e
			d.entities_with_main_script_on_update_index1[e.id] = d.entities_with_main_script_on_update_count1
		end
	end
end

function main_script:on_remove_unconditional(e, d)
	local s = e.main_script
	if s and s.update then
		if (s._pc_queue_type or s.type) == 0 then
			local index = d.entities_with_main_script_on_update_index[e.id]
			if not index then
				log.error(string.format(_("MAIN_SCRIPT_UPDATE_NOT_REGISTERED"), e.template_name))
				return
			end
			local last_entity = d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count]
			d.entities_with_main_script_on_update[index] = last_entity
			d.entities_with_main_script_on_update_index[last_entity.id] = index
			d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count] = nil
			d.entities_with_main_script_on_update_index[e.id] = nil
			d.entities_with_main_script_on_update_count = d.entities_with_main_script_on_update_count - 1
		else
			local index = d.entities_with_main_script_on_update_index1[e.id]
			if not index then
				log.error(string.format(_("MAIN_SCRIPT_UPDATE_NOT_REGISTERED"), e.template_name))
				return
			end
			local last_entity = d.entities_with_main_script_on_update1[d.entities_with_main_script_on_update_count1]
			d.entities_with_main_script_on_update1[index] = last_entity
			d.entities_with_main_script_on_update_index1[last_entity.id] = index
			d.entities_with_main_script_on_update1[d.entities_with_main_script_on_update_count1] = nil
			d.entities_with_main_script_on_update_index1[e.id] = nil
			d.entities_with_main_script_on_update_count1 = d.entities_with_main_script_on_update_count1 - 1
		end
	end
end

local function run_coroutine(e, store, s)
	if not s.co and s.runs ~= 0 then
		s.runs = s.runs - 1
		s.co = coroutine.create(s.update)
	end

	if s.co then
		store._dominant_entity = e
		local success, err = coroutine.resume(s.co, e, store)

		if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
			if not success and err ~= nil then
				if IS_ANDROID then
					error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
				else
					log.error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
					simulation:queue_remove_entity(e)
				end

				if LLDEBUGGER then
					LLDEBUGGER.start()
				end
			end

			s.co = nil
		end
	end
end

local function run_entity(e, store)
	local s = e.main_script
	if s.update ~= s._pc_update then
		get_compiler():ensure_entity_type(e)
	end

	if s.type == 1 then
		store._dominant_entity = e
		s.update(e, store)
	else
		run_coroutine(e, store, s)
	end
end

function main_script:on_update(dt, ts, store)
	perf.start("coro")
	for i = 1, store.entities_with_main_script_on_update_count do
		run_entity(store.entities_with_main_script_on_update[i], store)
	end
	perf.stop("coro")

	perf.start("state machine")
	for i = 1, store.entities_with_main_script_on_update_count1 do
		run_entity(store.entities_with_main_script_on_update1[i], store)
	end
	perf.stop("state machine")

	store._dominant_entity = nil
	perf.set_coros(store.entities_with_main_script_on_update_count)
	perf.set_stms(store.entities_with_main_script_on_update_count1)
end

function main_script:on_remove(entity, store)
	if entity.main_script and entity.main_script.remove then
		store._dominant_entity = entity
		local result = entity.main_script.remove(entity, store)
		store._dominant_entity = nil
		return result
	else
		return true
	end
end

return main_script
