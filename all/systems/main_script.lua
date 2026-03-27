local M = {}

function M.register(sys, deps)
	local perf = deps.perf
	local log = deps.log

	sys.main_script = {}
	sys.main_script.name = "main_script"

	function sys.main_script:on_queue(entity, store, insertion)
		if entity.main_script and entity.main_script.queue then
			entity.main_script.queue(entity, store, insertion)
		end
	end

	function sys.main_script:on_dequeue(entity, store, insertion)
		if entity.main_script and entity.main_script.dequeue then
			entity.main_script.dequeue(entity, store, insertion)
		end
	end

	function sys.main_script:on_insert(entity, store)
		if entity.main_script and entity.main_script.insert then
			return entity.main_script.insert(entity, store)
		else
			return true
		end
	end

	function sys.main_script:on_update(dt, ts, store)
		perf.start("main_script")

		for _, e in pairs(store.entities_with_main_script_on_update) do
			local s = e.main_script

			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local success, err = coroutine.resume(s.co, e, store)

				if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
					if not success and err ~= nil then
						log.error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))

						if LLDEBUGGER then
							LLDEBUGGER.start()
						end
					end

					s.co = nil
				end
			end
		end

		perf.stop("main_script")
	end

	function sys.main_script:on_remove(entity, store)
		if entity.main_script and entity.main_script.remove then
			return entity.main_script.remove(entity, store, entity.main_script)
		else
			return true
		end
	end
end

return M
