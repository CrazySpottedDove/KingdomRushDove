local M = {}

function M.register(sys, deps)
	local W = deps.W
	local U = deps.U
	local E = deps.E
	local P = deps.P
	local LU = deps.LU
	local km = deps.km
	local GS = deps.GS
	local signal = deps.signal
	local log = deps.log
	local queue_insert = deps.queue_insert
	local fts = deps.fts

	sys.wave_spawn_tsv = {}
	sys.wave_spawn_tsv.name = "wave_spawn_tsv"
	sys.wave_spawn_tsv.cmd_fns = {}

	function sys.wave_spawn_tsv.cmd_fns.column_names(store, cmd)
		if cmd.time_columns then
			W.db.time_columns = table.deepclone(cmd.time_columns)
		end

		if cmd.path_columns then
			W.db.path_columns = table.deepclone(cmd.path_columns)
		end
	end

	function sys.wave_spawn_tsv.cmd_fns.flags(store, cmd)
		if not cmd.flags_visibility then
			return
		end

		W.db.flags_visibility = cmd.flags_visibility
	end

	function sys.wave_spawn_tsv.cmd_fns.manual_wave(store, cmd)
		log.debug("manual_wave started: %s", cmd.wave_name)
	end

	function sys.wave_spawn_tsv.cmd_fns.manual_wave_repeat(store, cmd)
		local mws = W:get_wave_status(cmd.wave_name)

		if not mws then
			log.error("manual_wave_repeat: manual_wave_index[%s] not found", cmd.wave_name)

			return
		end

		if mws.repeat_remaining == -1 then
			mws.current_idx = mws.first_idx
		elseif mws.repeat_remaining and mws.repeat_remaining > 0 then
			mws.current_idx = mws.first_idx
			mws.repeat_remaining = mws.repeat_remaining - 1
		else
			mws.status = W.WS_DONE
		end
	end

	function sys.wave_spawn_tsv.cmd_fns.call_manual_wave(store, cmd)
		log.debug("call_manual_wave: %s", cmd.value)
		W:start_manual_wave(cmd.value)
	end

	function sys.wave_spawn_tsv.cmd_fns.wave(store, cmd)
		local group = W:create_wave_group_from_tsv(cmd)

		group.group_idx = store.wave_group_number + 1
		store.next_wave_group_ready = group

		signal.emit("next-wave-ready", group)

		local wave_number = store.wave_group_number
		local wait_time = cmd.wait_time
		local start_ts = store.tick_ts

		if wait_time < 0 then
			while not store.send_next_wave and not store.force_next_wave do
				coroutine.yield()
			end
		else
			U.y_wait(store, wait_time, function(store, wait_time)
				return store.send_next_wave or store.force_next_wave
			end)
		end

		local actual_wait_time = store.tick_ts - start_ts

		store.next_wave_group_ready = nil
		store.wave_group_number = store.wave_group_number + 1

		if store.force_next_wave then
			store.force_next_wave = false
		end

		if store.send_next_wave == true and store.wave_group_number > 1 then
			local score_reward
			local remaining_secs = km.round(wait_time - actual_wait_time)

			if store.level_mode == GAME_MODE_ENDLESS then
				store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())

				local conf = W:get_endless_score_config()
				local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

				score_reward = km.round((wave_number - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
				store.player_score = store.player_score + score_reward

				log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", wave_number, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
			else
				store.early_wave_reward = math.ceil(remaining_secs * GS.early_wave_reward_per_second)
			end

			store.player_gold = store.player_gold + store.early_wave_reward

			signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
		else
			store.early_wave_reward = 0
		end

		if store.level_mode == GAME_MODE_ENDLESS and wave_number > 1 then
			local conf = W:get_endless_score_config()
			local reward = (wave_number - 1) * conf.scorePerWave

			store.player_score = store.player_score + reward
		end

		store.current_spawn_idx = 0
		store.send_next_wave = false
		store.current_wave_group = group

		signal.emit("next-wave-sent", group)
	end

	function sys.wave_spawn_tsv.cmd_fns.spawn(store, cmd, wave_name)
		local wait_time = cmd.wait_time
		local multiplier = store.config.enemy_count_multiplier

		for count = 1, multiplier do
			if wait_time and wait_time > 0 then
				U.y_wait(store, wait_time / multiplier, function(store, wait_time)
					return store.force_next_wave
				end)
			end

			if store.force_next_wave then
				log.debug("skipping spawn command due to force_next_wave")

				return
			end

			for _, o in pairs(cmd.spawns) do
				if not U.is_seen(store, o.enemy) then
					signal.emit("wave-notification", "icon", o.enemy)
					U.mark_seen(store, o.enemy)
				end

				local e = E:create_entity(o.enemy)

				if e then
					store.current_spawn_idx = store.current_spawn_idx + 1

					local path = P.paths[o.pi]

					e.nav_path.pi = o.pi
					e.nav_path.spi = o.spi == "*" and math.random(#path) or o.spi
					e.nav_path.ni = P:get_start_node(o.pi)

					queue_insert(store, e)
				else
					log.error("Entity template %s not found", o.enemy)
				end
			end
		end
	end

	function sys.wave_spawn_tsv.cmd_fns.event(store, cmd)
		local wait_time = cmd.wait_time

		if wait_time and wait_time > 0 then
			U.y_wait(store, wait_time, function(store, wait_time)
				return store.force_next_wave
			end)
		end

		local handlers = store.event_handlers

		if cmd.event_name and handlers and handlers[cmd.event_name] then
			for _, ev in pairs(handlers[cmd.event_name]) do
				local entity = store.entities[ev.entity_id]

				ev.on_event(entity, store, ev.name, unpack(cmd.event_params or {}))
			end
		end
	end

	function sys.wave_spawn_tsv.cmd_fns.signal(store, cmd)
		local wait_time = cmd.wait_time

		if wait_time and wait_time > 0 then
			U.y_wait(store, wait_time, function(store, wait_time)
				return store.force_next_wave
			end)
		end

		if cmd.signal_name then
			signal.emit(cmd.signal_name, unpack(cmd.signal_params or {}))
		end
	end

	function sys.wave_spawn_tsv.cmd_fns.wait_signal(store, cmd)
		local signal_name = cmd.signal_name

		store.wait_signal_done = nil

		local function fn(...)
			log.debug("wait_signal : signal received")

			store.wait_signal_done = "arrived"
		end

		if signal_name then
			log.debug("wait_signal: registering signal %s", signal_name)
			signal.register(signal_name, fn)
		end

		log.debug("wait_signal: waiting for signal:%s  time:%s", signal_name, cmd.wait_time)

		if cmd.wait_time < 0 then
			while not store.wait_signal_done and not store.force_next_wave do
				coroutine.yield()
			end
		else
			cmd.wait_time = km.clamp(30, 60, cmd.wait_time)
			U.y_wait(store, cmd.wait_time, function(store, wait_time)
				if store.wait_signal_done or store.force_next_wave then
					store.wait_signal_done = "interrupted"

					return true
				end
			end)
		end

		log.debug("wait_signal: deregistering signal %s", signal_name)
		signal.remove(signal_name, fn)
	end

	function sys.wave_spawn_tsv.cmd_fns.wait(store, cmd)
		local wait_time = cmd.wait_time

		if wait_time and wait_time > 0 then
			U.y_wait(store, wait_time, function(store, wait_time)
				return store.force_next_wave
			end)
		end
	end

	function sys.wave_spawn_tsv.y_run_wave(store, wave_name)
		local cmd_fns = sys.wave_spawn_tsv.cmd_fns
		local cmd = W:get_next_cmd(wave_name)

		while cmd do
			if cmd_fns[cmd.name] then
				cmd_fns[cmd.name](store, cmd, wave_name)
			elseif cmd.wait_time then
				if cmd.wait_time < 0 then
					while not store.send_next_wave and not store.force_next_wave do
						coroutine.yield()
					end
				else
					U.y_wait(store, cmd.wait_time, function(store, wait_time)
						return store.force_next_wave
					end)
				end
			end

			cmd = W:get_next_cmd(wave_name)
		end

		return true
	end

	function sys.wave_spawn_tsv:init(store)
		if W.format ~= "tsv" then
			return "skip"
		end

		store.wave_group_number = 0
		store.waves_finished = false
		store.last_wave_ts = 0
		store.send_next_wave = false
		store.manual_wave_cos = {}

		do
			local cmd_fns = sys.wave_spawn_tsv.cmd_fns
			local cmd = W:peek_next_cmd()

			while cmd and cmd.name ~= "wave" and cmd.name ~= "manual_wave" and not cmd.wait_time do
				if cmd_fns[cmd.name] then
					cmd_fns[cmd.name](store, cmd)
				end

				cmd = W:get_next_cmd()
				cmd = W:peek_next_cmd()
			end
		end

		if store.level_mode == GAME_MODE_ENDLESS then
			store.wave_group_total = 0
		else
			store.wave_group_total = W:groups_count()
		end

		store.wave_spawn_co = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
	end

	function sys.wave_spawn_tsv:on_update(dt, ts, store)
		if store.force_next_wave then
			LU.kill_all_enemies(store, nil, true)
		end

		if store.wave_spawn_co then
			local ok, done = coroutine.resume(store.wave_spawn_co, store)

			if ok and done then
				store.wave_spawn_co = nil
				store.waves_finished = true

				log.debug("wave_spawn_tsv: waves finished")
			end

			if not ok then
				log.error("wave_spawn_tsv: Error resuming wave_spawn_co co:%s", debug.traceback(store.wave_spawn_co, done))

				store.wave_spawn_co = nil
			end
		elseif store.waves_finished == false then
			local level_table = {116}
			if store.wave_group_total <= (store.wave_group_number + 0.5) and not table.contains(level_table, store.level_idx) then
				store.waves_finished = true
				print("LIUHUI349 FORCE END LEVEL")
			end
		end

		if W:has_pending_manual_waves() then
			for _, name in pairs(W:list_pending_manual_waves()) do
				local ws = W:get_wave_status(name)

				ws.state = W.WS_RUNNING
				store.manual_wave_cos = store.manual_wave_cos or {}
				store.manual_wave_cos[name] = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
			end
		end

		if store.manual_wave_cos then
			local to_remove

			for name, co in pairs(store.manual_wave_cos) do
				local ws = W:get_wave_status(name)

				if ws and ws.state == W.WS_DONE then
					to_remove = to_remove or {}

					table.insert(to_remove, name)
				else
					local ok, done = coroutine.resume(co, store, name)

					if ok and done then
						to_remove = to_remove or {}

						table.insert(to_remove, name)
					end

					if not ok then
						log.error("wave_spawn_tsv: Error resuming manual_wave_cos[%s]:%s", name, debug.traceback(co, done))

						store.wave_spawn_co = nil
					end
				end
			end

			if to_remove then
				for _, name in pairs(to_remove) do
					store.manual_wave_cos[name] = nil

					local ws = W:get_wave_status(name)

					if ws then
						ws.state = W.WS_REMOVED
					end
				end

				to_remove = nil
			end
		end

		store.force_next_wave = false
	end
end

return M
