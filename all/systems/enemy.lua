local M = {}

function M.register(sys)
	sys.enemy = {}
	sys.enemy.name = "enemy"
	local signal = require("lib.hump.signal")
	local km = require("lib.klua.macros")
	local P = require("path_db")
	local U = require("utils")
	local perf = require("dove_modules.perf.perf")

	function sys.enemy:init(store)
		local storage = require("all.storage")
		require("lib.klua.table")
		-- enemy index
		store.enemies = {}
		store.enemy_count = 0

		-- seen_tracker
		local slot = storage:load_slot()
		store.seen = slot.seen and slot.seen or {}
		store.seen_dirty = nil
		self.encyclopedia_map = table.to_map(require("kr1.game_settings").encyclopedia_enemies)

		-- spatial index
		package.loaded["spatial_index"] = nil
		store.enemy_spatial_index = require("spatial_index")

		store.enemy_spatial_index.set_entities(store.enemies)
		store.enemy_spatial_index.gc_locked(store)

		local seek = require("seek")

		seek.set_id_arrays(store.enemy_spatial_index.get_id_arrays())
		seek.set_entities(store.enemies)
	end

	function sys.enemy:on_insert_unconditional(entity, store)
		if entity.enemy then
			-- enemy insert chores
			store.enemies[entity.id] = entity
			if not entity.health.patched then
				if store.level_difficulty == DIFFICULTY_IMPOSSIBLE and store.wave_group_number > 6 then
					if store.wave_group_number <= 15 then
						entity.health.hp_max = entity.health.hp_max * (1 + (store.wave_group_number - 6) * 0.0167)
					else
						entity.health.hp_max = entity.health.hp_max * 1.15
					end
				end

				entity.health.hp = entity.health.hp_max
				entity.health.patched = true
			end

			if entity.enemy.lives_cost == 20 then
				store.game_gui:set_boss(entity)
			end

			store.enemy_count = store.enemy_count + 1

			-- seen_tracker
			if self.encyclopedia_map[entity.template_name] and not entity.ignore_seen_tracker then
				signal.emit("wave-notification", "icon", entity.template_name)
				U.mark_seen(store, entity.template_name)
			end

			-- spatial index
			store.enemy_spatial_index.insert_entity(entity)
		end
	end

	function sys.enemy:on_remove_unconditional(entity, store)
		if entity.enemy then
			-- spatial index
			store.enemy_spatial_index.remove_entity(entity)

			-- enemy index
			store.enemies[entity.id] = nil
			store.enemy_count = store.enemy_count - 1
		end
	end

	function sys.enemy:on_update(dt, ts, store)
		perf.start("enemy")
		for _, e in pairs(store.enemies) do
			-- delete after death
			local h = e.health

			if h.hp <= 0 and not h.dead and not h.ignore_damage then
				h.hp = 0
				h.dead = true
				h.death_ts = ts

				if e.render then
					h.fading_after = ts + h.dead_lifetime - 0.4
				else
					h.delete_after = ts + h.dead_lifetime
				end

				if e.health_bar then
					e.health_bar.hidden = true
				end

				store.player_gold = store.player_gold + e.enemy.gold
				signal.emit("got-enemy-gold", e, e.enemy.gold)
			end

			if not h.dead then
				h.last_damage_types = 0
			elseif not h.ignore_delete_after then
				if h.fading_after and ts > h.fading_after then
					local progress = (ts - h.fading_after) / 0.4

					if progress >= 1.0 then
						simulation:queue_remove_entity(e)
					else
						local sprites = e.render.sprites
						if not h._fade_init_alphas then
							h._fade_init_alphas = {}
							for i = 1, #sprites do
								h._fade_init_alphas[i] = sprites[i].alpha
							end
						end
						for i = 1, #sprites do
							sprites[i].alpha = h._fade_init_alphas[i] * (1 - progress)
						end
					end
				elseif h.delete_after and ts > h.delete_after then
					simulation:queue_remove_entity(e)
				end
			end

			-- goal_line
			local node_index = e.nav_path.ni
			local pi = e.nav_path.pi
			local end_node = P.path_end_node[pi] or #P.paths[pi]

			if end_node <= node_index and not P.path_connections[pi] and e.enemy.remove_at_goal_line then
				signal.emit("enemy-reached-goal", e)
				store.lives = km.clamp(-1000000, 1000000, store.lives - e.enemy.lives_cost)
				store.player_gold = store.player_gold + e.enemy.gold
				simulation:queue_remove_entity(e)
			end
		end

		store.enemy_spatial_index.on_update(dt)
		perf.stop("enemy")
	end
end

return M
