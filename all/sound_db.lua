-- chunkname: @./all/sound_db.lua

local log = require("klua.log"):new("sound_db")

require("klua.table")

local km = require("klua.macros")
local LA = love.audio
local LS = love.sound
local FS = love.filesystem
local sound_db = {}

sound_db.path = nil
sound_db.sources = {}
sound_db.source_uses = {}
sound_db.sounds = {}
sound_db.groups = {}
sound_db.source_groups = {}
sound_db.group_gains = {}
sound_db.active_sources = {}
sound_db.sound_extras = {}
sound_db.ref_counters = {}
sound_db.qts = 0
sound_db.ts = 0
sound_db.paused = false
sound_db.global_source_mode = nil
sound_db.load_queue = {}
sound_db.load_queue_current = nil
sound_db.group_progress = 0
sound_db.progress = 0
sound_db.groups_total = 0
sound_db.groups_done = 0
sound_db.sounds_uses = {}
local function is_file(path)
    local info = love.filesystem.getInfo(path)
    return info and info.type == "file"
end

local _THREADS_ENABLED = true

-- 音频加载的动态线程数计算
local function calculate_audio_thread_count()
    local cpu_count = love.system.getProcessorCount() or 4

    -- 音频加载的线程数应该比图像加载更保守
    local thread_count

    if cpu_count <= 2 then
        thread_count = 2 -- 低端设备：2个线程
    elseif cpu_count <= 4 then
        thread_count = 3 -- 四核：3个线程
    elseif cpu_count <= 8 then
        thread_count = 4 -- 八核：4个线程
    else
        thread_count = 6 -- 高端CPU：最多6个线程
    end

    log.info("Audio loading: %d CPU cores -> %d threads", cpu_count, thread_count)

    return thread_count
end

-- 替换固定的 _MAX_THREADS = 8
local _MAX_THREADS = calculate_audio_thread_count()

local _LOAD_AUDIO_THREAD_CODE = "local cin,cout,th_i = ...\nrequire \"love.filesystem\"\nrequire \"love.audio\"\nrequire \"love.sound\"\nlocal file_count = 0\nwhile true do\n    -- get params\n    local file = cin:demand()\n    if file == 'QUIT' then goto quit end\n    local mode = cin:demand()\n    local id = cin:demand()\n    \n  local info = love.filesystem.getInfo(file) \n if (not info) or (info.type ~= 'file')  then\n        cout:push({'ERROR','Not a file',file})\n    else\n        local ok, result = pcall(love.audio.newSource, file, mode)\n        collectgarbage()\n        if ok and result then\n            cout:push({'OK',result,id})\n            file_count = file_count + 1\n        else\n            cout:push({'ERROR',result,file})\n        end\n    end\nend\n::quit::\ncout:supply({'DONE'})\n--print('TH  ' ..th_i.. ' QUIT - FILES LOADED ' .. file_count .. '\\n')\n"

function sound_db:init(path)
	log.debug("path:%s", path)

	self.path = path
	self.files_path = path .. "/files"

	local f_settings = FS.load(path .. "/settings.lua")()

	if f_settings.source_groups then
		for gid, group in pairs(f_settings.source_groups) do
			self.source_groups[gid] = {
				max_sources = group.max_sources
			}
            if gid ~= "MUSIC" and  gid ~= "REFCOUNTED" then
                self.source_groups[gid].max_sources = math.floor(group.max_sources * (SOUND_POOL_SIZE_FACTOR or 1))
            end
			self.active_sources[gid] = self.active_sources[gid] or {}
		end
	end

	local f_sounds = FS.load(path .. "/sounds.lua")()

	self.sounds = f_sounds

	local f_groups = FS.load(path .. "/groups.lua")()

	self.groups = f_groups

	local f_extra = FS.load(path .. "/extra.lua")()

	if f_extra.sounds then
		for k, v in pairs(f_extra.sounds) do
			self.sounds[k] = v
		end
	end

	for id, sd in pairs(self.sounds) do
		self.sound_extras[id] = {}
	end

	if f_extra.groups then
		for k, v in pairs(f_extra.groups) do
			if v.append then
				if v.sounds then
					for _, s in pairs(v.sounds) do
						local sound = self.sounds[s]

						for _, f in pairs(sound.files) do
							if not table.contains(self.groups[k].files, f) then
								table.insert(self.groups[k].files, f)
							end
						end
					end
				end

				if v.files then
					for _, f in pairs(v.files) do
						if not table.contains(self.groups[k].files, f) then
							table.insert(self.groups[k].files, f)
						end
					end
				end
			elseif v.alias then
				self.groups[k] = self.groups[v.alias]
			else
				self.groups[k] = v
			end
		end
	end
end

function sound_db:queue_load_done()
	if not self.load_queue_current and #self.load_queue == 0 then
		self.progress = 1
		self.groups_total = 0

		return true
	end
	::label_2_0::

	if not self.co then
		self.co = coroutine.create(self.load_group)
	end

	if self.load_queue_current then
		local name = self.load_queue_current
		local suc, err = coroutine.resume(self.co, self, name, true)

		if coroutine.status(self.co) ~= "dead" and err == nil then
			self.progress = (self.groups_done + self.group_progress) / self.groups_total

			return false
		end

		if err ~= nil then
			log.error("Error in sound_db load coro: %s", debug.traceback(self.co, err))
		end

		self.co = nil
		self.groups_done = self.groups_done + 1

		log.info("group %s done (%d/%d)", name, self.groups_done, self.groups_total)
	end

	if #self.load_queue > 0 then
		self.load_queue_current = table.remove(self.load_queue, 1)

		goto label_2_0
	end

	log.debug("sound queue loaded")
    collectgarbage()
	self.load_queue_current = nil
	self.progress = 1
	self.groups_total = 0

	return true
end

function sound_db:queue_load_group(name)
	log.info("queued %s", name)
	table.insert(self.load_queue, name)

	self.groups_total = self.groups_total + 1

	if #self.load_queue == 1 and not self.load_queue_current then
		self.progress = 0
		self.groups_done = 0
	end
end

function sound_db:load_group(name, yielding, filter)
	local rt_start = love.timer.getTime()

	log.debug("loading sound group %s", name)

	if not self.groups[name] then
		log.error("sound group %s not found", name)

		return
	end

	if self.sounds_uses[name] then
		self.sounds_uses[name] = self.sounds_uses[name] + 1

		log.debug("sounds %s already loaded", name)

		return
	end

	self.sounds_uses[name] = 1
	self.group_progress = 0

	local files = {}
	local group = self.groups[name]

	if group.files then
		for _, f in pairs(group.files) do
			table.insert(files, {
				f,
				group.stream or false
			})
		end
	end

	if group.sounds then
		for _, s in pairs(self.groups[name].sounds) do
			log.debug("   getting sound %s from group %s", s, name)

			local sound = self.sounds[s]

			for _, f in pairs(sound.files) do
				table.insert(files, {
					f,
					sound.stream or false
				})
			end
		end
	end

	if _THREADS_ENABLED then
		local load_threads = {}
		local th_i = 1

		for i = 1, _MAX_THREADS do
			local th = love.thread.newThread(_LOAD_AUDIO_THREAD_CODE)
			local cin = love.thread.newChannel()
			local cout = love.thread.newChannel()

			th:start(cin, cout, i)

			if love.nx then
				th:setAffinity({
					false,
					true,
					true
				})
				log.paranoid(" ++++ SOUND_DB THREAD %s AFFINITY %s", th, getdump(th:getAffinity()))
			end

			table.insert(load_threads, {
				th,
				cin,
				cout
			})
		end

		for _, item in pairs(files) do
			local fn, stream = unpack(item)
			local mode = self.global_source_mode or stream and "stream" or "static"

			if self.sources[fn] then
				self.source_uses[fn] = self.source_uses[fn] + 1
			else
				local file = string.format(self.files_path .. "/%s", fn)
				local cin = load_threads[th_i][2]

				cin:push(file)
				cin:push(mode)
				cin:push(fn)

				th_i = km.zmod(th_i + 1, #load_threads)
			end
		end

		for _, item in pairs(load_threads) do
			item[2]:push("QUIT")
		end

		local yield_every = 0

		while #load_threads > 0 do
			local th, cin, cout = unpack(load_threads[1])

			if th:isRunning() then
				local result = cout:pop()

				if result then
					local r1, r2, r3 = unpack(result)

					if r1 == "DONE" then
						table.remove(load_threads, 1)
					elseif r1 == "ERROR" then
						log.error("Failed to create audio source for file: %s. Error: %s", r3, r2)
					elseif r1 == "OK" then
						local fn, master_src = r3, r2

						self.sources[fn] = {
							master_src
						}
						self.source_uses[fn] = 1
					end
				end
			else
				log.error("Thread error:%s", th:getError())
				table.remove(load_threads, 1)
			end

			yield_every = yield_every + 1

			if yielding and yield_every == 1000 then
				yield_every = 0

				coroutine.yield()
			end
		end

		load_threads = nil

		-- collectgarbage("collect")
	else
		local yield_every = 0

		for _, item in pairs(files) do
			local fn, stream = unpack(item)
			local mode = self.global_source_mode or stream and "stream" or "static"

			if self.sources[fn] then
				self.source_uses[fn] = self.source_uses[fn] + 1
			else
				local file = string.format(self.files_path .. "/%s", fn)

				if is_file(file) then
					local ok, master_src = pcall(love.audio.newSource, file, mode)

					if ok and master_src then
						self.sources[fn] = {
							master_src
						}
						self.source_uses[fn] = 1

						log.paranoid("Created audio source for %s", file)
						-- collectgarbage()
					end
				end
			end

			yield_every = yield_every + 1

			if yielding and yield_every == 1000 then
				yield_every = 0

				coroutine.yield()
			end
		end
	end

	log.info("Done loading sounds from group %s - time: %s", name, love.timer.getTime() - rt_start)

	self.group_progress = 1
end

function sound_db:unload_group(name)
	if not self.sounds_uses[name] then
		log.error("sound group %s not loaded. cannot unload", name)

		return
	end

	self.sounds_uses[name] = self.sounds_uses[name] - 1

	if self.sounds_uses[name] > 0 then
		return
	end

	local group = self.groups[name]

	if group.keep then
		return
	end

	self.sounds_uses[name] = nil

    local sources = self.sources
    local source_uses = self.source_uses
    local files = group.files
	if files then
        for i=1,#files do
            local f = files[i]

            if sources[f] then
                for _, s in pairs(sources[f]) do
                    s:stop()
                end

                source_uses[f] = source_uses[f] - 1

                if source_uses[f] < 1 then
                    sources[f] = nil
                    source_uses[f] = 0
                end
            end
            -- collectgarbage()
		end
	end
    local sounds = group.sounds
    if sounds then
        for i=1,#sounds do
            local s = sounds[i]
            local sound = self.sounds[s]
            local sound_files = sound.files
            for i=1,#sound_files do
                local f = sound_files[i]
                if sources[f] then
                    for _, s in pairs(sources[f]) do
                        s:stop()
                    end

                    source_uses[f] = source_uses[f] - 1

                    if source_uses[f] < 1 then
                        sources[f] = nil
                        source_uses[f] = 0
                    end
                end
            end
            -- collectgarbage()
        end
    end
    -- local t1 = love.timer.getTime()
	-- collectgarbage()
    -- local t2 = love.timer.getTime()
    -- print("Sound group " .. name .. " unloaded. GC took " .. (t2 - t1) .. " seconds.")
end

sound_db.request_queue = {}

function sound_db:queue(id, options)
	if not id then
		return
	end

	if not self.sounds[id] then
		log.error("SOUND WITH ID %s NOT FOUND", tostring(id))

		return
	end

	local opts

	if options then
		opts = table.merge(self.sounds[id], options, true)
	else
		opts = self.sounds[id]
	end

	local req = {
		id = id,
		options = opts,
		qts = self.ts
	}

	table.insert(self.request_queue, req)
end

sound_db.stop_queue = {}

function sound_db:stop(id)
	if id then
		local opts = sound_db.sounds[id]

		if opts and (opts.loop or sound_db.sounds[id].interruptible) then
			log.paranoid("Sound %s stopping queued", id)

			local stop_req = {
				id = id
			}

			table.insert(sound_db.stop_queue, stop_req)
		else
			log.paranoid("Sound %s not interruptible nor loopable. Ignoring stop request.", id)
		end
	end
end

function sound_db:stop_group(gid)
	log.paranoid("Stopping sources for group: %s", gid)

	if gid then
		log.paranoid("Group %s stopping queued", gid)

		local stop_req = {
			gid = gid
		}

		table.insert(sound_db.stop_queue, stop_req)
	end
end

function sound_db:stop_all()
	LA.stop()

	self.ref_counters = {}
end

function sound_db:pause()
	self.paused = true

	for gid, group_active_sources in pairs(self.active_sources) do
		for _, ast in pairs(group_active_sources) do
			ast.source:pause()
		end
	end
end

function sound_db:resume()
	self.paused = false

	for gid, group_active_sources in pairs(self.active_sources) do
		for _, ast in pairs(group_active_sources) do
			ast.source:play()
		end
	end
end

function sound_db:sound_is_playing(id)
	local sd = sound_db.sounds[id]

	if sd then
		local gid = sd.source_group

		for _, ast in pairs(self.active_sources[gid]) do
			if ast.id == id then
				return true
			end
		end
	else
		log.error("No such sound id: %s", id)
	end

	return false
end

function sound_db:set_main_gain_fx(gain)
	local fx_groups = {
		BULLETS = gain,
		DEATH = gain,
		EXPLOSIONS = gain,
		GUI = gain,
		SFX = gain,
		SPECIALS = gain,
		SWORDS = gain,
		TAUNTS = gain,
		REFCOUNTED = gain
	}

	sound_db:set_groups_gains(fx_groups)
end

function sound_db:set_main_gain_music(gain)
	sound_db:set_groups_gains({
		MUSIC = gain
	})
end

function sound_db:set_groups_gains(ggs)
	local active_sources = self.active_sources
	local group_gains = sound_db.group_gains

	for gid, gain in pairs(ggs) do
		group_gains[gid] = gain

		if active_sources and active_sources[gid] then
			for _, ast in pairs(active_sources[gid]) do
				ast.source:setVolume(ast.ref_vol * gain)
			end
		end
	end
end

function sound_db:_stop_sources(req)
	log.paranoid("Stoping sources for stop request {id=%s, gid=%s}", req.id, req.gid)

	if req.id and self.sounds[req.id].ref_counted then
		local rc = self.ref_counters[req.id] or 0

		rc = rc - 1
		self.ref_counters[req.id] = rc

		log.paranoid("sound %s refcount is now %d", req.id, rc)

		if rc > 0 then
			return false
		end
	end

	for gid, group_active_sources in pairs(self.active_sources) do
		for _, ast in pairs(group_active_sources) do
			if gid == req.gid or ast.id == req.id then
				log.debug("about to stop source %s (ID = %s)", ast.source, id)
				ast.source:stop()
			end
		end
	end
end

function sound_db:update(dt)
	local now_ts = self.ts

	if not self.paused then
		now_ts = now_ts + dt
	end

	for i = #sound_db.stop_queue, 1, -1 do
		local stop_request = sound_db.stop_queue[i]

		self:_stop_sources(stop_request, self.active_sources)

		if not self.ref_counters[stop_request.id] then
			for j = #sound_db.request_queue, 1, -1 do
				if sound_db.request_queue[j].id == stop_request.id then
					table.remove(sound_db.request_queue, j)
				end
			end
		end

		table.remove(sound_db.stop_queue, i)
	end

	for gid, group_active_sources in pairs(self.active_sources) do
		for i = #group_active_sources, 1, -1 do
			if not group_active_sources[i].source:isPlaying() then
				log.paranoid("Reclaiming source %s", group_active_sources[i].source)
				table.remove(group_active_sources, i)
			end
		end
	end

	local queue = sound_db.request_queue
	local reqs_due = {}

	for i = #queue, 1, -1 do
		local req = queue[i]

		if not req.options.delay or now_ts - req.qts >= req.options.delay then
			self:play(req)
			table.remove(queue, i)
		end
	end

	self.ts = now_ts
end

function sound_db:play(request)
	local options = request.options
	local se = self.sound_extras[request.id]
	local last_play_ts = se.last_play_ts or 0
	local every_counter = se.every_counter or 0
	local play_due = true

	if options.chance and math.random() >= options.chance then
		return
	end

	if options.every then
		if every_counter ~= 0 then
			play_due = false

			log.paranoid("%s plays every %d requests. (remaining: %d )", request.id, options.every, options.every - every_counter)
		end

		every_counter = (every_counter + 1) % options.every
		se.every_counter = every_counter
	end

	if options.ignore and self.ts - last_play_ts < options.ignore then
		play_due = false
	end

	if options.ref_counted then
		local rc = self.ref_counters[request.id] or 0

		rc = rc + 1

		if rc ~= 1 then
			play_due = false
		end

		self.ref_counters[request.id] = rc
	end

	local pools = {}

	if options.mode == "sequence" then
		table.insert(pools, self.sources[options.files[se.sequence or 1]])

		se.sequence = (se.sequence or 1) % #options.files + 1
	elseif options.mode == "random" then
		table.insert(pools, self.sources[options.files[math.random(1, #options.files)]])
	elseif options.mode == "concurrent" then
		for _, f in pairs(options.files) do
			table.insert(pools, self.sources[f])
		end
	else
		table.insert(pools, self.sources[options.files[1]])
	end

	if not pools or #pools == 0 then
		log.error("SOUND %s defined but sound sources missing. Missing file during load?", request.id)

		return
	end

	if play_due then
		log.paranoid("TTP: %s", request.id)

		for _, sp in pairs(pools) do
			self:_play(request, sp)
		end

		se.last_play_ts = self.ts
	end
end

local function soon_to_stop_source(group_active_sources)
	local mtp = 1000000000
	local pos = 1

	for i, ast in ipairs(group_active_sources) do
		local remaining = ast.source:getDuration() - ast.source:tell()

		if remaining < mtp then
			mtp = remaining
			pos = i
		end
	end

	return pos
end

local function get_or_create_source(source_pool)
	local source

	for i = 1, #source_pool do
		source = source_pool[i]

		if not source:isPlaying() then
			log.paranoid("Found free source at %d", i)

			break
		else
			source = nil
		end
	end

	if not source then
		log.paranoid("No free sources in pool %s. Creating a new one", tostring(source_pool))

		source = source_pool[1]:clone()

		table.insert(source_pool, source)
	end

	return source
end

function sound_db:_play(request, source_pool)
	local opts = request.options
	local se = self.sound_extras[request.id]
	local active_sources = self.active_sources

	if not active_sources[opts.source_group] then
		log.error("SOUND %s group %s not found", request.id, opts.source_group)

		return
	end

	local active = #active_sources[opts.source_group]
	local max = self.source_groups[opts.source_group].max_sources
	local source

	if max == 0 then
		log.info("max_sources for %s is 0", opts.source_group)

		return
	end

	if active < max then
		source = get_or_create_source(source_pool)
	else
		log.paranoid("No free sources for %s. Source group %s maxed out at %d.", request.id, opts.source_group, max)

		local ste_idx = soon_to_stop_source(active_sources[opts.source_group])
		local ste_ast = active_sources[opts.source_group][ste_idx]

		log.paranoid("Stopping evicted source %s (%s) in group %s", ste_ast.id, tostring(ste_ast.source), opts.source_group)
		ste_ast.source:stop()
		table.remove(active_sources[opts.source_group], ste_idx)

		source = get_or_create_source(source_pool)
	end

	local vol = 1

	if opts.gain then
		if type(opts.gain) == "number" then
			vol = opts.gain
		elseif type(opts.gain) == "table" then
			local min, max = opts.gain[1], opts.gain[2]

			vol = min + (max - min) * math.random()
		end
	end

	local ref_vol = vol
	local group_gain = sound_db.group_gains[opts.source_group]

	if group_gain then
		vol = ref_vol * group_gain
	end

	source:setVolume(vol)
	source:setLooping(opts.loop or false)

	local success = source:play()

	if success then
		if opts.seek and type(opts.seek) == "number" then
			source:seek(opts.seek)

			if source:isPaused() then
				source:play()
			end
		end

		local ast = {
			id = request.id,
			source = source,
			ref_vol = ref_vol
		}

		table.insert(active_sources[opts.source_group], ast)
	else
		log.error("source:play() failed! source: %s sound_id: %s", tostring(source), request.id)
	end
end

return sound_db
