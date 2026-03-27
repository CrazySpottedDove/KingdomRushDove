local M = {}

function M.register(sys, deps)
	local E = deps.E
	local perf = deps.perf
	local log = deps.log

	sys.editor_script = {}
	sys.editor_script.name = "editor_script"

	function sys.editor_script:on_insert(entity, store)
		if entity.editor_script and entity.editor_script.insert then
			return entity.editor_script.insert(entity, store, entity.editor_script.insert)
		else
			return true
		end
	end

	function sys.editor_script:on_remove(entity, store)
		if entity.editor_script and entity.editor_script.remove then
			return entity.editor_script.remove(entity, store, entity.editor_script.remove)
		else
			return true
		end
	end

	function sys.editor_script:on_update(dt, ts, store)
		perf.start("editor_script")
		for _, e in E:filter_iter(store.entities, "editor_script") do
			local s = e.editor_script

			if s.update then
				if not s.co and s.runs ~= 0 then
					s.runs = s.runs - 1
					s.co = coroutine.create(s.update)
				end

				if s.co then
					local success, err = coroutine.resume(s.co, e, store, s)

					if coroutine.status(s.co) == "dead" or err ~= nil then
						if err ~= nil then
							log.error("Error running editor_script coro: %s", debug.traceback(s.co, err))
						end

						s.co = nil
					end
				end
			end
		end
		perf.stop("editor_script")
	end
end

return M
