local M = {}

local log = require("lib.klua.log"):new("systems")
local signal = require("lib.hump.signal")
local perf = require("dove_modules.perf.perf")

require("all.constants")

local EU = require("endless_utils")
local A = require("animation_db")
local DI = require("difficulty")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local W = require("wave_db")
local UP = require("kr1.upgrades")
local U = require("utils")
local LU = require("level_utils")
local V = require("lib.klua.vector")
local storage = require("all.storage")
require("lib.klua.table")

local ceil = math.ceil
local random = math.random

local EXO = require("all.exoskeleton")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

function M.register(sys)
	sys.level = {}
	sys.level.name = "level"

	function sys.level:init_coroutined(store)
		perf.clear()
		local slot = storage:load_slot(nil, true)

		UP:set_levels(slot.upgrades)
		UP:set_list_id(slot.upgrade_list_id)
		DI:set_level(store.level_difficulty)

		GR:load(store.level_name)
		P:load(store.level_name, store.visible_coords)
		coroutine.yield()

		if store.config.reverse_path then
			P:reverse_all_paths()
		end

		E:load()
		coroutine.yield()

		DI:patch_templates()
		E:patch_config(store.config)
		coroutine.yield()

		W:load(store.level_name, store.level_mode, store.level_mode_override == GAME_MODE_ENDLESS)
		coroutine.yield()

		if store.config.random_creeps then
			W:randomize_creeps()
		end

		A:load()
		coroutine.yield()

		EXO:load()
		coroutine.yield()

		store.selected_hero = slot.heroes.selected

		if store.level.init then
			store.level:init(store)
		end

		UP:patch_templates(store.level.max_upgrade_level or GS.max_upgrade_level)
		coroutine.yield()

		if store.level.data then
			store.level.locations = {}

			LU.insert_entities(store, store.level.data.entities_list)
			LU.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)
		end

		if store.level.load then
			store.level:load(store)
		end

		store.level.co = nil
		store.level.run_complete = nil
		store.player_gold = ceil(W:initial_gold() * store.config.gold_multiplier)

		store.hero_xp_multiplier = GS.hero_xp_gain_per_difficulty_mode[store.level_difficulty] * store.config.hero_xp_gain_multiplier

		if store.level_idx <= 9 then
			store.hero_xp_multiplier = 0.1 * store.level_idx * store.hero_xp_multiplier
		elseif store.level_idx <= 35 and store.level_idx > 26 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 26) * store.hero_xp_multiplier
		elseif store.level_idx <= 57 and store.level_idx > 48 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 48) * store.hero_xp_multiplier
		elseif store.level_idx <= 109 and store.level_idx > 100 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 100) * store.hero_xp_multiplier
		end

		if slot.locked_towers then
			for _, tower in pairs(slot.locked_towers) do
				if not table.find(store.level.locked_towers, tower) then
					table.insert(store.level.locked_towers, tower)
				end
			end
		end

		for _, unlock_tower in pairs(store.level.unlock_towers) do
			table.removeobject(store.level.locked_towers, unlock_tower)
		end

		if store.config.ban_random_towers then
			local locked_towers = store.level.locked_towers
			for i = 4, #GS.archer_towers do
				if math.random() < 0.5 then
					locked_towers[#locked_towers + 1] = GS.archer_towers[i]
				end
			end
			for i = 4, #GS.mage_towers do
				if math.random() < 0.5 then
					locked_towers[#locked_towers + 1] = GS.mage_towers[i]
				end
			end
			for i = 4, #GS.engineer_towers do
				if math.random() < 0.5 then
					locked_towers[#locked_towers + 1] = GS.engineer_towers[i]
				end
			end
			for i = 4, #GS.barrack_towers do
				if math.random() < 0.5 then
					locked_towers[#locked_towers + 1] = GS.barrack_towers[i]
				end
			end
		end

		if store.criket and store.criket.on then
			store.lives = 0
		elseif store.level_mode == GAME_MODE_CAMPAIGN then
			store.lives = 20
		elseif store.level_mode == GAME_MODE_HEROIC then
			store.lives = 1
		elseif store.level_mode == GAME_MODE_IRON then
			store.lives = 1
		end

		if store.level_mode_override == GAME_MODE_ENDLESS then
			store.lives = 20
			store.player_gold = store.player_gold + W.endless.extra_cash
			store.endless = W.endless

			local endless_data = store.endless

			if endless_data.upgrade_levels then
				EU.patch_upgrades(endless_data)
			end

			if endless_data.player_gold then
				store.player_gold = endless_data.player_gold
			end

			if endless_data.lives then
				store.lives = endless_data.lives
			end

			if endless_data.wave_group_number then
				store.wave_group_number = endless_data.wave_group_number
			end

			if endless_data.towers then
				for i = #endless_data.towers, 1, -1 do
					local tower_data = endless_data.towers[i]
					local tower = E:create_entity(tower_data.template_name)

					if not tower then
						log.error("endless restore: tower template missing, skip spawn (holder_id=%s name=%s)", tostring(tower_data.holder_id), tostring(tower_data.template_name))
					else
						tower.pos = V.v(tower_data.pos.x, tower_data.pos.y)
						tower.tower.level = tower_data.tower_level
						tower.tower.spent = tower_data.spent
						tower.tower.holder_id = tower_data.holder_id

						for _, e in pairs(store.pending_inserts) do
							if e.tower and e.tower.holder_id == tower.tower.holder_id then
								if e.template_name == tower.template_name then
									goto continue
								end

								tower.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)

								if tower.ui and e.ui then
									tower.ui.nav_mesh_id = e.ui.nav_mesh_id
								end

								queue_remove(store, e)
							end
						end

						tower.tower.flip_x = tower_data.flip_x

						if tower_data.terrain_style then
							U.set_terrain_style(tower, tower_data.terrain_style)
						end

						if tower_data.powers and tower.powers then
							for power_name, power_data in pairs(tower_data.powers) do
								if tower.powers[power_name] then
									tower.powers[power_name].level = power_data.level
									tower.powers[power_name].changed = true
								end
							end
						end

						if tower_data.rally_pos and tower.barrack then
							tower.barrack.rally_pos = V.v(tower_data.rally_pos.x, tower_data.rally_pos.y)

							if tower.mercenary then
								for si = 1, tower_data.soldier_count do
									tower.barrack.soldiers[si] = E:create_entity(tower.barrack.soldier_type)
									tower.barrack.soldiers[si].health.dead = true
									tower.barrack.soldiers[si].id = -1
								end
							end
						end

						queue_insert(store, tower)

						::continue::
					end
				end
			end
		end

		store.player_score = 0
		store.game_outcome = nil
		store.main_hero = nil
	end

	function sys.level:on_update(dt, ts, store)
		if not store.level.update then
			store.level.run_complete = true
		else
			if not store.level.co and not store.level.run_complete then
				store.level.co = coroutine.create(store.level.update)
			end

			if store.level.co then
				local _, error = coroutine.resume(store.level.co, store.level, store)

				if coroutine.status(store.level.co) == "dead" or error ~= nil then
					if error ~= nil then
						log.error("Error running level coro: %s", debug.traceback(store.level.co, error))
					end

					store.level.co = nil
					store.level.run_complete = true
				end
			end
		end

		if not store._common_notifications then
			store._common_notifications = true

			if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
				signal.emit("wave-notification", "view", "TIP_UPGRADES")
			elseif store.level_mode_override == GAME_MODE_ENDLESS then
				signal.emit("wave-notification", "view", "TIP_SURVIVAL")
			elseif store.selected_hero and #store.selected_hero ~= 0 and not U.is_seen(store, "TIP_HEROES") then
				signal.emit("wave-notification", "icon", "TIP_HEROES")
			end
		end

		if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
			LU.insert_hero(store)
		end

		if not store.game_outcome then
			if store.lives < 1 and (not store.criket or not store.criket.on) then
				log.info("++++ DEFEAT ++++")

				store.game_outcome = {
					victory = false,
					level_idx = store.level_idx,
					level_mode = store.level_mode,
					level_difficulty = store.level_difficulty
				}
				store.paused = true
				store.defeat_count = (store.defeat_count or 0) + 1

				local slot = storage:load_slot()

				slot.last_victory = nil

				signal.emit("game-defeat", store)
				signal.emit("game-defeat-after", store)
				storage:save_slot(slot, nil, true)
			elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
				if store.criket and store.criket.on then
					local stars = 3

					if store.lives < -10 then
						stars = 1
					elseif store.lives < -5 then
						stars = 2
					end

					store.criket.time_cost = store.tick_ts - store.criket.start_time
					store.game_outcome = {
						victory = true,
						lives_left = store.lives,
						stars = stars,
						level_idx = store.level_idx,
						level_mode = store.level_mode,
						level_difficulty = store.level_difficulty
					}

					signal.emit("game-victory", store)
					signal.emit("game-victory-after", store)

					return
				end

				log.info("++++ VICTORY ++++")

				local stars = 1

				if store.level_mode == GAME_MODE_CAMPAIGN then
					if store.lives >= 18 then
						stars = 3
					elseif store.lives >= 6 then
						stars = 2
					end
				end

				store.game_outcome = {
					victory = true,
					lives_left = store.lives,
					stars = stars,
					level_idx = store.level_idx,
					level_mode = store.level_mode,
					level_difficulty = store.level_difficulty
				}

				local slot = storage:load_slot()

				slot.last_victory = {
					level_idx = store.level_idx,
					level_difficulty = store.level_difficulty,
					level_mode = store.level_mode,
					stars = stars,
					unlock_towers = store.level.unlock_towers
				}

				signal.emit("game-victory", store)
				signal.emit("game-victory-after", store)
				storage:save_slot(slot, nil, true)
			end
		end
	end
end

return M
