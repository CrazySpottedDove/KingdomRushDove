local M = {}

local log = require("lib.klua.log"):new("systems")

function M.register(sys)

	sys.last_hook = {}
	sys.last_hook.name = "last_hook"

	function sys.last_hook:init(store)
		store.dead_soldier_count = 0
		store.enemy_count = 0
		store.last_hooks = {
			on_insert = {},
			on_remove = {}
		}
	end

	function sys.last_hook:on_insert_unconditional(e, d)
		if e.enemy then
			d.enemies[e.id] = e

			if not e.health.patched then
				if d.level_difficulty == DIFFICULTY_IMPOSSIBLE and d.wave_group_number > 6 then
					if d.wave_group_number <= 15 then
						e.health.hp_max = e.health.hp_max * (1 + (d.wave_group_number - 6) * 0.0167)
					else
						e.health.hp_max = e.health.hp_max * 1.15
					end
				end

				e.health.hp = e.health.hp_max
				e.health.patched = true
			end

			if e.enemy.lives_cost == 20 then
				simulation.store.game_gui:set_boss(e)
			end

			d.enemy_count = d.enemy_count + 1
		elseif e.soldier and e.health then
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
		elseif e.tower then
			d.towers[e.id] = e
		elseif e.aura then
			d.auras[e.id] = e
		end

		if e.particle_system then
			d.particle_systems[e.id] = e
		end

		if e.main_script and e.main_script.update then
			d.entities_with_main_script_on_update_count = d.entities_with_main_script_on_update_count + 1
			d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count] = e
			d.entities_with_main_script_on_update_index[e.id] = d.entities_with_main_script_on_update_count
		end

		if e.timed then
			d.entities_with_timed[e.id] = e
		end

		if e.tween then
			d.entities_with_tween[e.id] = e
		end

		if e.render then
			d.entities_with_render[e.id] = e
		end

		if e.lights then
			d.entities_with_lights[e.id] = e
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

		return true
	end

	function sys.last_hook:on_remove_unconditional(e, d)
		if e.enemy then
			d.enemies[e.id] = nil
			d.enemy_count = d.enemy_count - 1
		elseif e.soldier then
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
		elseif e.tower then
			d.towers[e.id] = nil
		elseif e.aura then
			d.auras[e.id] = nil
		end

		if e.particle_system then
			d.particle_systems[e.id] = nil
		end

		if e.main_script and e.main_script.update then
			local index = d.entities_with_main_script_on_update_index[e.id]

			if not index then
				log.error(string.format("！如果看见这条消息，请截下来发给作者，实体 %s 的 main_script.update 没有正确注册到 entities_with_main_script_on_update 中", e.template_name))
				-- return false
				return
			end
			-- 交换删除，保证数组的连续性
			local last_entity = d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count]
			d.entities_with_main_script_on_update[index] = last_entity
			d.entities_with_main_script_on_update_index[last_entity.id] = index
			d.entities_with_main_script_on_update[d.entities_with_main_script_on_update_count] = nil
			d.entities_with_main_script_on_update_index[e.id] = nil
			d.entities_with_main_script_on_update_count = d.entities_with_main_script_on_update_count - 1
		end

		if e.timed then
			d.entities_with_timed[e.id] = nil
		end

		if e.tween then
			d.entities_with_tween[e.id] = nil
		end

		if e.render then
			d.entities_with_render[e.id] = nil
		end

		if e.lights then
			d.entities_with_lights[e.id] = nil
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

	-- return true
	end
end

return M
