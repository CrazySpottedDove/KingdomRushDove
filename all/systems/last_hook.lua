local last_hook = {}

last_hook.name = "last_hook"

function last_hook:init(store)
	store.dead_soldier_count = 0
	store.enemy_count = 0
	store.last_hooks = {
		on_insert = {},
		on_remove = {}
	}
end

function last_hook:on_insert_unconditional(e, d)
	if e.soldier and e.health then
		d.soldiers[e.id] = e
	elseif e.modifier then
		d.modifiers[e.id] = e

		local target = d.entities[e.modifier.target_id]

		if target then
			-- 可能的触发原因是，有不合法的脚本在运行时修改了原有的 modifier.target_id，使得它指向了一个 _applied_mods 字段未被正确初始化的实体。
			if not target._applied_mods then
				target._applied_mods = {}
				-- 这个问题应该是历史遗留问题，现在使用强制蓝屏策略，等待用户报告。
				error(string.format("！如果看见这条消息，请截下来发给作者 target: %s, mod: %s", target.template_name, e.template_name))
			end

			local mods = target._applied_mods
			mods[#mods + 1] = e
		end
	elseif e.aura then
		d.auras[e.id] = e
	end

	if e.timed then
		d.entities_with_timed[e.id] = e
	end

	if e.ui then
		d.entities_with_ui[e.id] = e
	end

	if e.motion and e.motion.max_speed ~= 0 then
		e.motion.real_speed = e.motion.max_speed
	end

	for _, hook in pairs(d.last_hooks.on_insert) do
		hook(e, d)
	end
end

function last_hook:on_remove_unconditional(e, d)
	if e.soldier then
		d.soldiers[e.id] = nil
		d.dead_soldier_count = d.dead_soldier_count + 1
	elseif e.modifier then
		d.modifiers[e.id] = nil

		local target = d.entities[e.modifier.target_id]

		if target then
			local mods = target._applied_mods

			if mods then
				for i = 1, #mods do
					if mods[i] == e then
						table.remove(mods, i)
						break
					end
				end
			end
		end
	elseif e.aura then
		d.auras[e.id] = nil
	end

	if e.timed then
		d.entities_with_timed[e.id] = nil
	end

	if e.ui then
		d.entities_with_ui[e.id] = nil
	end

	for _, hook in pairs(d.last_hooks.on_remove) do
		hook(e, d)
	end

	if e._applied_mods then
		e._applied_mods = nil
	end
end

return last_hook
