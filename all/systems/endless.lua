local M = {}

function M.register(sys, deps)
	local U = deps.U
	local SU = deps.SU
	local ceil = deps.ceil

	sys.endless_patch = {}
	sys.endless_patch.name = "endless_patch"

	function sys.endless_patch:on_insert(entity, store)
		if store.level_mode_override == GAME_MODE_ENDLESS then
			if not entity._endless_strengthened then
				local endless = store.endless

				entity._endless_strengthened = true

				if entity.enemy then
					if entity.health.hp_max then
						entity.health.hp_max = ceil(entity.health.hp_max * store.endless.enemy_health_factor)
						entity.health.damage_factor = entity.health.damage_factor * store.endless.enemy_health_damage_factor
						entity.health.instakill_resistance = entity.health.instakill_resistance + store.endless.enemy_instakill_resistance
					end

					if entity.unit.damage_factor then
						entity.unit.damage_factor = entity.unit.damage_factor * store.endless.enemy_damage_factor
					end

					if entity.motion.max_speed then
						U.speed_mul_self(entity, endless.enemy_speed_factor)
					end

					entity.enemy.gold = ceil(entity.enemy.gold * store.endless.enemy_gold_factor)
				elseif entity.soldier then
					if entity.health and entity.health.hp_max then
						entity.health.hp_max = ceil(entity.health.hp_max * store.endless.soldier_health_factor)
						entity.health.hp = entity.health.hp_max
					end

					if entity.unit then
						entity.unit.damage_factor = entity.unit.damage_factor * store.endless.soldier_damage_factor
						SU.insert_unit_cooldown_buff(store.tick_ts, entity, endless.soldier_cooldown_factor)
					end

					if entity.hero then
						entity.unit.damage_factor = entity.unit.damage_factor * store.endless.hero_damage_factor
						SU.insert_unit_cooldown_buff(store.tick_ts, entity, endless.hero_cooldown_factor)
						entity.health.hp_max = ceil(entity.health.hp_max * store.endless.hero_health_factor)
						entity.health.hp = entity.health.hp_max
					end
				elseif entity.tower then
					SU.insert_tower_damage_factor_buff(entity, endless.tower_damage_factor)
					SU.insert_tower_cooldown_buff(store.tick_ts, entity, endless.tower_cooldown_factor)
				end
			end
		end

		return true
	end
end

return M
