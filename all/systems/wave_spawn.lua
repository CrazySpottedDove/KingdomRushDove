local M = {}

function M.register(sys, deps)
	local W = deps.W
	local U = deps.U
	local E = deps.E
	local P = deps.P
	local LU = deps.LU
	local DI = deps.DI
	local km = deps.km
	local GS = deps.GS
	local signal = deps.signal
	local log = deps.log
	local perf = deps.perf
	local queue_insert = deps.queue_insert
	local fts = deps.fts
	local random = deps.random
	local ceil = deps.ceil

	sys.wave_spawn = {}
	sys.wave_spawn.name = "wave_spawn"

	local function spawner(store, wave, group_id)
		log.debug("spawner thread(%s) for wave(%s) starting", coroutine.running(), tostring(wave))

		local spawns = wave.spawns
		local pi = wave.path_index

		for i = 1, #spawns do
			for count = 1, store.config.enemy_count_multiplier do
				local current_count = 0
				local current_creep
				local s = spawns[i]
				local path = P.paths[pi]

				if not U.is_seen(store, s.creep) then
					signal.emit("wave-notification", "icon", s.creep)
					U.mark_seen(store, s.creep)
				end

				if s.creep_aux and not U.is_seen(store, s.creep_aux) then
					signal.emit("wave-notification", "icon", s.creep_aux)
					U.mark_seen(store, s.creep_aux)
				end

				for j = 1, s.max do
					U.y_wait(store, fts(s.interval or 0) / store.config.enemy_count_multiplier)

					if not current_creep then
						current_creep = s.creep
					elseif s.creep_aux and s.max_same and s.max_same > 0 and current_count >= s.max_same then
						current_creep = s.creep == current_creep and s.creep_aux or s.creep
						current_count = 0
					end

					local e = E:create_entity(current_creep)

					if e then
						e.nav_path.pi = pi
						e.nav_path.spi = s.fixed_sub_path == 1 and s.path or random(#path)
						e.nav_path.ni = P:get_start_node(pi)
						e.spawn_data = s.spawn_data

						queue_insert(store, e)
						current_count = current_count + 1
					else
						log.error("Entity template not found for %s.", s.crep)
					end
				end

				if s.max == 0 then
					U.y_wait(store, fts(s.interval or 0) / store.config.enemy_count_multiplier)
				end

				local oes = s.on_end_signal
				if oes then
					log.info("Sending spawner on_end_signal: %s", oes)
					store.wave_signals[oes] = {}
				end

				if i < #spawns then
					local interval_next = s.interval_next or 0

					if DI.level == DIFFICULTY_HARD then
						if group_id > 12 then
							store.last_wave_ts = store.last_wave_ts - interval_next * 0.75
							interval_next = interval_next * 0.25
						elseif group_id > 9 then
							store.last_wave_ts = store.last_wave_ts - interval_next * 0.5
							interval_next = interval_next * 0.5
						elseif group_id > 6 then
							store.last_wave_ts = store.last_wave_ts - interval_next * 0.25
							interval_next = interval_next * 0.75
						end
					end

					U.y_wait(store, fts(interval_next) / store.config.enemy_count_multiplier)
				end
			end
		end

		log.debug("spawner thread(%s) for wave(%s) about to finish", coroutine.running(), tostring(wave))
		return true
	end

	function sys.wave_spawn:init(store)
		if W.format ~= "lua" then
			return "skip"
		end
		store.wave_group_number = 0
		store.waves_finished = false
		store.last_wave_ts = 0
		store.waves_active = {}
		store.wave_signals = {}
		store.send_next_wave = false

		if store.level_mode_override == GAME_MODE_ENDLESS then
			store.wave_group_total = 0

			if store.endless and store.endless.wave_group_number then
				store.wave_group_number = store.endless.wave_group_number
			end
		else
			store.wave_group_total = W:groups_count()
		end

		local function run(store)
			log.info("Wave group spawn thread STARTING")

			local i = 1
			local start = true

			if store.endless and store.endless.wave_group_number then
				i = store.endless.wave_group_number
			end

			while W:has_group(i) do
				local group = W:get_group(i)

				group.group_idx = i
				store.next_wave_group_ready = group
				signal.emit("next-wave-ready", group)

				if start then
					group.group_idx = 1

					for _, wave in pairs(group.waves) do
						if wave.notification and wave.notification ~= "" then
							signal.emit("wave-notification", "view", wave.notification)
						end
					end

					while not store.send_next_wave do
						coroutine.yield()
					end

					start = false
					log.debug("Sending first WAVE. (Started by player)")
				else
					while not store.send_next_wave and not (store.tick_ts - store.last_wave_ts >= fts(group.interval)) and not store.force_next_wave do
						coroutine.yield()
					end
				end

				log.info("sending WAVE group %02d (%02d waves)", i, #group.waves)
				store.next_wave_group_ready = nil
				store.wave_group_number = i

				if store.send_next_wave == true and i > 1 then
					local score_reward
					local remaining_secs = km.round(fts(group.interval) - (store.tick_ts - store.last_wave_ts))

					if store.level_mode == -1 then
						store.early_wave_reward = ceil(remaining_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())
						local conf = W:get_endless_score_config()
						local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

						score_reward = km.round((i - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
						store.player_score = store.player_score + score_reward

						log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", i, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
					else
						store.early_wave_reward = ceil(remaining_secs * GS.early_wave_reward_per_second)
					end

					store.player_gold = store.player_gold + store.early_wave_reward
					signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
				else
					store.early_wave_reward = 0

					if store.criket then
						store.criket.start_time = store.tick_ts
					end
				end

				store.send_next_wave = false
				store.current_wave_group = group
				signal.emit("next-wave-sent", group)

				for _, wave in pairs(group.waves) do
					wave.group_idx = i

					if i ~= 1 and wave.notification and wave.notification ~= "" then
						signal.emit("wave-notification", "view", wave.notification)
					end

					if wave.notification_second_level and wave.notification_second_level ~= "" then
						signal.emit("wave-notification", "icon", wave.notification_second_level)
					end

					local sco = coroutine.create(function()
						local wave_start_ts = store.tick_ts

						while store.tick_ts < wave_start_ts + fts(wave.delay) do
							coroutine.yield()
						end

						return spawner(store, wave, i)
					end)

					store.waves_active[sco] = sco
				end

				log.info("WAVE group %d about to wait for all its spawner threads to finish", i)
				while next(store.waves_active) do
					coroutine.yield()
				end

				store.current_wave_group = nil
				store.last_wave_ts = store.tick_ts
				i = i + 1
			end

			log.info("WAVE spawn thread FINISHED")
			return true
		end

		store.wave_spawn_thread = coroutine.create(run)
	end

	function sys.wave_spawn:force_next_wave(store)
		if store.force_next_wave then
			store.waves_active = {}
			LU.kill_all_enemies(store, nil, true)
		end
	end

	function sys.wave_spawn:on_update(dt, ts, store)
		perf.start("wave_spawn")
		sys.wave_spawn:force_next_wave(store)

		if store.wave_spawn_thread then
			local ok, done = coroutine.resume(store.wave_spawn_thread, store)

			if ok and done then
				store.wave_spawn_thread = nil
				store.waves_finished = true
				log.debug("++++ WAVES FINISHED")
			end

			if not ok then
				log.error("Error resuming wave_spawn_thread co: %s", debug.traceback(store.wave_spawn_thread, done))
				store.wave_spawn_thread = nil
			end
		end

		local to_cleanup

		for _, co in pairs(store.waves_active) do
			local ok, done = coroutine.resume(co, store)

			if ok and done then
				log.debug("thread (%s) finished after resume()", tostring(co))
				to_cleanup = to_cleanup or {}
				to_cleanup[#to_cleanup + 1] = co
			end

			if not ok then
				local err = done
				log.error("Error resuming spawner thread (%s): %s", tostring(co), debug.traceback(co, err))
			end
		end

		if to_cleanup then
			for _, co in pairs(to_cleanup) do
				log.debug("removing spawner thread (%s)", co)
				store.waves_active[co] = nil
			end
		end

		store.force_next_wave = false
		perf.stop("wave_spawn")
	end
end

return M
