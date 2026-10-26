local main_script = {}

local perf = require("dove_modules.perf.perf")

local log = require("lib.klua.log"):new("systems")

main_script.name = "main_script"

function main_script:init(store)
	store.entities_with_main_script_on_update_count = 0
	store.entities_with_main_script_on_update = {}
	store.entities_with_main_script_on_update_index = {}
	store._dominant_entity = nil
end

function main_script:on_insert(entity, store)
	if entity.main_script then
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
		d.entities_with_main_script_on_update_count = d.entities_with_main_script_on_update_count + 1
		d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count] = e
		d.entities_with_main_script_on_update_index[e.id] = d.entities_with_main_script_on_update_count
	end
end

function main_script:on_remove_unconditional(e, d)
	local s = e.main_script
	if s and s.update then
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
	end
end

function main_script:on_update(dt, ts, store)
	perf.start("coro")
	for i = 1, store.entities_with_main_script_on_update_count do
		local e = store.entities_with_main_script_on_update[i]
		local s = e.main_script

		-- 协程型脚本
		if not s.co and s.runs ~= 0 then
			s.runs = s.runs - 1
			s.co = coroutine.create(s.update)
		end

		if s.co then
			store._dominant_entity = e
			local success, err = coroutine.resume(s.co, e, store)

			if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
				if not success and err ~= nil then
					-- -- 安卓端逻辑：直接抛出错误，触发全局错误捕获机制，弹出错误提示框
					-- if IS_ANDROID then
					-- error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
					-- else
					log.error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
					simulation:queue_remove_entity(e)
					-- end

					if LLDEBUGGER then
						LLDEBUGGER.start()
					end
				end

				s.co = nil
			end
		end
	end
	perf.stop("coro")

	store._dominant_entity = nil
	perf.set_coros(store.entities_with_main_script_on_update_count)
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
