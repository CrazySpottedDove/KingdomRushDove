local M = {}

local perf = require("dove_modules.perf.perf")

local log = require("lib.klua.log"):new("systems")
local E = require("entity_db")

function M.register(sys)

	sys.main_script = {}
	sys.main_script.name = "main_script"

	function sys.main_script:init(store)
		store.entities_with_main_script_on_update_count = 0
		store.entities_with_main_script_on_update = {}
		store.entities_with_main_script_on_update_index = {}
		store.entities_with_main_script_on_update_count1 = 0
		store.entities_with_main_script_on_update1 = {}
		store.entities_with_main_script_on_update_index1 = {}
	end

	function sys.main_script:on_insert(entity, store)
		if entity.main_script then
			if entity.main_script.type == 1 then
				if entity.main_script.context == nil then
					entity.main_script.context = E:clone_c("context")
				end
			end
			if entity.main_script.insert then
				return entity.main_script.insert(entity, store)
			else
				return true
			end
		else
			return true
		end
	end

	function sys.main_script:on_insert_unconditional(e, d)
		local s = e.main_script
		if s and s.update then
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

	function sys.main_script:on_remove_unconditional(e, d)
		local s = e.main_script
		if s and s.update then
			if s.type == 0 then
				local index = d.entities_with_main_script_on_update_index[e.id]
				if not index then
					log.error(string.format("！如果看见这条消息，请截下来发给作者，实体 %s 的 main_script.update 没有正确注册到 entities_with_main_script_on_update 中", e.template_name))
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
					log.error(string.format("！如果看见这条消息，请截下来发给作者，实体 %s 的 main_script.update 没有正确注册到 entities_with_main_script_on_update 中", e.template_name))
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

	function sys.main_script:on_update(dt, ts, store)
		perf.start("main_script")
		-- for i = 1, store.entities_with_main_script_on_update_count do
		-- 	local e = store.entities_with_main_script_on_update[i]
		-- 	local s = e.main_script

		-- 	-- 协程型脚本
		-- 	if s.type == 0 then
		-- 		if not s.co and s.runs ~= 0 then
		-- 			s.runs = s.runs - 1
		-- 			s.co = coroutine.create(s.update)
		-- 		end

		-- 		if s.co then
		-- 			local success, err = coroutine.resume(s.co, e, store)

		-- 			if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
		-- 				if not success and err ~= nil then
		-- 					-- -- 安卓端逻辑：直接抛出错误，触发全局错误捕获机制，弹出错误提示框
		-- 					if IS_ANDROID then
		-- 						error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
		-- 					else
		-- 						log.error("Error running " .. e.template_name .. " coro: " .. err .. debug.traceback(s.co))
		-- 						simulation:queue_remove_entity(e)
		-- 					end

		-- 					if LLDEBUGGER then
		-- 						LLDEBUGGER.start()
		-- 					end
		-- 				end

		-- 				s.co = nil
		-- 			end
		-- 		end
		-- 	else
		-- 		-- 状态机型脚本
		-- 		s.update(e, store)
		-- 	-- local success, err = pcall(s.update, e, store)
		-- 	-- if not success and err ~= nil then
		-- 	-- 	-- -- 安卓端逻辑：直接抛出错误，触发全局错误捕获机制，弹出错误提示框
		-- 	-- 	if IS_ANDROID then
		-- 	-- 		error("Error running " .. e.template_name .. " state machine: " .. err .. debug.traceback())
		-- 	-- 	else
		-- 	-- 		log.error("Error running " .. e.template_name .. " state machine: " .. err .. debug.traceback())
		-- 	-- 		simulation:queue_remove_entity(e)
		-- 	-- 	end
		-- 	-- end
		-- 	end
		-- end

		for i = 1, store.entities_with_main_script_on_update_count do
			local e = store.entities_with_main_script_on_update[i]
			local s = e.main_script

			-- 协程型脚本
			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local success, err = coroutine.resume(s.co, e, store)

				if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
					if not success and err ~= nil then
						-- -- 安卓端逻辑：直接抛出错误，触发全局错误捕获机制，弹出错误提示框
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

		for i = 1, store.entities_with_main_script_on_update_count1 do
			local e = store.entities_with_main_script_on_update1[i]
			e.main_script.update(e, store)
		end
		perf.set_main_scripts(store.entities_with_main_script_on_update_count)
		perf.stop("main_script")
	end

	function sys.main_script:on_remove(entity, store)
		if entity.main_script and entity.main_script.remove then
			return entity.main_script.remove(entity, store)
		else
			return true
		end
	end
end

return M
