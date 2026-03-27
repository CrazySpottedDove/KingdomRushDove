local M = {}

function M.register(sys, deps)
	local perf = deps.perf
	local band = deps.band
	local bor = deps.bor
	local U = deps.U
	local SU = deps.SU
	local signal = deps.signal
	local E = deps.E
	local queue_remove = deps.queue_remove

	sys.health = {}
	sys.health.name = "health"

	function sys.health:init(store)
		store.damage_queue = {}
		store.damages_applied = {}
	end

	function sys.health:on_insert(entity, store)
		if entity.health and not entity.health.hp then
			entity.health.hp = entity.health.hp_max
		end

		return true
	end

	function sys.health:on_update(dt, ts, store)
		perf.start("health")
		local new_damage_queue = {}
		local damage_queue = store.damage_queue
		local damages_applied = {}
		local damages_applied_count = 0
		local entities = store.entities
		local damage_queue_len = #damage_queue
		for i = damage_queue_len, 1, -1 do
			local d = damage_queue[i]
			local e = entities[d.target_id]

			if e then
				local h = e.health

				if not (h.dead or band(h.immune_to, d.damage_type) ~= 0 or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d)) then
					local starting_hp = h.hp

					h.last_damage_types = bor(h.last_damage_types, d.damage_type)

					if band(d.damage_type, DAMAGE_EAT) ~= 0 then
						d.damage_applied = h.hp
						d.damage_result = bor(d.damage_result, DR_KILL)
						h.hp = 0
						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
					elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
						SU.armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_ARMOR)
					elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
						SU.magic_armor_dec(e, d.value)
						d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
					else
						local actual_damage = U.predict_damage(e, d)

						h.hp = h.hp - actual_damage
						d.damage_applied = actual_damage

						if starting_hp > 0 and h.hp <= 0 then
							d.damage_result = bor(d.damage_result, DR_KILL)
						end

						if actual_damage > 0 then
							d.damage_result = bor(d.damage_result, DR_DAMAGE)

							if e.regen then
								e.regen.last_hit_ts = store.tick_ts
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = entities[d.source_id]

								if source and source.track_damage then
									table.insert(source.track_damage.damaged, {e.id, actual_damage})
								end
							end
						end

						if h.spiked_armor > 0 and e.soldier and d.source_id and e.soldier.target_id == d.source_id then
							local t = entities[d.source_id]

							if t and t.health and not t.health.dead then
								local sad = E:create_entity("damage")

								sad.damage_type = DAMAGE_TRUE
								sad.value = h.spiked_armor * d.value
								sad.source_id = e.id
								sad.target_id = t.id
								new_damage_queue[#new_damage_queue + 1] = sad
							end
						end

						damages_applied_count = damages_applied_count + 1
						damages_applied[damages_applied_count] = d
					end

					if starting_hp > 0 and h.hp <= 0 then
						signal.emit("entity-killed", e, d)

						if d.track_kills then
							local source = entities[d.source_id]

							if source and source.track_kills then
								table.insert(source.track_kills.killed, e.id)
							end
						end
					end
				end
			end
		end

		local enemies = store.enemies
		local soldiers = store.soldiers

		for _, e in pairs(enemies) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts
				h.delete_after = store.tick_ts + h.dead_lifetime

				if e.health_bar then
					e.health_bar.hidden = true
				end

				store.player_gold = store.player_gold + e.enemy.gold
				signal.emit("got-enemy-gold", e, e.enemy.gold)
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
				queue_remove(store, e)
			end
		end

		for _, e in pairs(soldiers) do
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				h.hp = 0
				h.dead = true
				h.death_ts = store.tick_ts
				h.delete_after = store.tick_ts + h.dead_lifetime

				if e.health_bar then
					e.health_bar.hidden = true
				end
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not e.hero and not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
				queue_remove(store, e)
			end
		end

		store.damage_queue = new_damage_queue

		for i = damage_queue_len + 1, #damage_queue do
			new_damage_queue[#new_damage_queue + 1] = damage_queue[i]
		end

		store.damages_applied = damages_applied
		perf.stop("health")
	end
end

return M
