-- chunkname: @./all/sound_db.lua
local log = require("lib.klua.log"):new("sound_db")
local perf = require("dove_modules.perf.perf")
require("lib.klua.table")

local km = require("lib.klua.macros")
local LA = love.audio
local FS = love.filesystem
local sound_db = {}

-- FFI：用紧凑 C 数组替代 2000+ 个散列 Lua 表，减少 GC 压力
local ffi = require("ffi")
ffi.cdef[[
	typedef struct { float last_play_ts; int32_t every_counter; int32_t sequence; } SdSoundExtra;
]]
-- 随着 sound 变多手动调整。
local _EXTRAS_CAP = 3072
local _extras_arr = ffi.new("SdSoundExtra[?]", _EXTRAS_CAP) -- 零初始化
local _extras_cnt = 0

-- 请求对象池：重用 req 表，避免每次 queue() 堆分配
local _req_pool = {}

local function _get_req(id, opts, ts)
	local n = #_req_pool
	local req = _req_pool[n]
	_req_pool[n] = nil
	if req then
		req.id = id
		req.options = opts
		req.qts = ts
	else
		req = {
			id = id,
			options = opts,
			qts = ts
		}
	end
	return req
end

-- play() 的临时 source_pool 列表，模块级避免每帧分配
local _ps = {}

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
sound_db.ts = 0
sound_db.paused = false
sound_db.load_queue = {}
sound_db.threads = {}
sound_db.load_file_queue = {}
sound_db.load_path_queue = {}
sound_db.load_mode_queue = {}
sound_db.load_file_total = 0
sound_db.load_file_done = 0
sound_db.progress = 0
sound_db.sounds_uses = {}
sound_db.missing_sources_warned = {}
sound_db.missing_sources_summary_printed = false

local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

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

	return thread_count
end

-- 替换固定的 _MAX_THREADS = 8
local _MAX_THREADS = calculate_audio_thread_count()
local _LOAD_AUDIO_THREAD_CODE = [[local cin,cout,th_i = ...
require "love.filesystem"
require "love.audio"
require "love.sound"
local file_count = 0
while true do
local file = cin:demand()
if file == 'QUIT' then
goto quit
end
local mode = cin:demand()
local id = cin:demand()
local info = love.filesystem.getInfo(file)
if (not info) or (info.type ~= 'file') then
cout:push({'ERROR','Not a file',file})
else
local ok, result = pcall(love.audio.newSource, file, mode)
if ok and result then
cout:push({'OK',result,id})
file_count = file_count + 1
else
cout:push({'ERROR',result,file})
end
end
end
::quit::
cout:supply({'DONE'})]]

function sound_db:init(path)
	self.path = path
	self.files_path = path .. "/files"
	self.missing_sources_warned = {}
	self.missing_sources_summary_printed = false

	local f_settings = FS.load(path .. "/settings.lua")()

	if f_settings.source_groups then
		for gid, group in pairs(f_settings.source_groups) do
			self.source_groups[gid] = {
				max_sources = group.max_sources
			}

			if gid ~= "MUSIC" and gid ~= "REFCOUNTED" then
				self.source_groups[gid].max_sources = math.floor(group.max_sources * (SOUND_POOL_SIZE_FACTOR or 1))
			end

			self.active_sources[gid] = self.active_sources[gid] or {}
		end
	end

	local f_sounds = FS.load(path .. "/sounds.lua")()

	self.sounds = f_sounds

	local f_groups = FS.load(path .. "/groups.lua")()

	self.groups = f_groups

	for id, sd in pairs(self.sounds) do
		self:_precache_sound(id, sd)
	end
end

-- 预缓存 per-sound 热路径字段，在 init() 和 mod 懒初始化时调用。
-- 只写 _ 前缀字段，不影响声音定义的公共字段。
function sound_db:_precache_sound(id, sd)
	local se = _extras_arr + _extras_cnt
	_extras_cnt = _extras_cnt + 1
	self.sound_extras[id] = se

	sd._files_n = sd.files and #sd.files or 0
end

function sound_db:queue_load_group(name)
	table.insert(self.load_queue, name)

	if #self.load_queue == 1 and #self.threads == 0 and #self.load_file_queue == 0 then
		self.progress = 0
	end
end

function sound_db:queue_load_done()
	-- 加载队列已空，而且所有线程都完成工作，说明加载已结束
	if #self.load_queue == 0 and #self.threads == 0 then
		self.progress = 1
		return true
	end

	::label_2_0::

	local load_queue_length = #self.load_queue
	for i = load_queue_length, 1, -1 do
		local name = self.load_queue[i]
		self.load_queue[i] = nil

		local group = self.groups[name]

		if not group then
			log.error("sound group %s not found", name)
		elseif self.sounds_uses[name] then
			-- 已经有声音的使用了，只添加引用计数
			self.sounds_uses[name] = self.sounds_uses[name] + 1
		else
			self.sounds_uses[name] = 1

			if group.files then
				local mode = group.stream and "stream" or "static"
				for j = 1, #group.files do
					local fn = group.files[j]

					if self.source_uses[fn] then
						self.source_uses[fn] = self.source_uses[fn] + 1
					else
						self.source_uses[fn] = 1
						local insert_index = #self.load_file_queue + 1
						-- 允许在 group 中指定 parent_dir，以允许 mod 自定义声音资源的加载路径
						local parent_dir = (group.parent_dir and group.parent_dir or self.files_path) .. "/"
						self.load_file_queue[insert_index] = fn
						self.load_path_queue[insert_index] = parent_dir .. fn
						self.load_mode_queue[insert_index] = mode
					end
				end
			end

			if group.sounds then
				for j = 1, #group.sounds do
					local sound = self.sounds[group.sounds[j]]
					if sound and sound.files then
						local mode = sound.stream and "stream" or "static"
						local parent_dir = (sound.parent_dir and sound.parent_dir or self.files_path) .. "/"
						for k = 1, #sound.files do
							local fn = sound.files[k]

							if self.source_uses[fn] then
								self.source_uses[fn] = self.source_uses[fn] + 1
							else
								self.source_uses[fn] = 1
								local insert_index = #self.load_file_queue + 1
								self.load_file_queue[insert_index] = fn
								self.load_path_queue[insert_index] = parent_dir .. fn
								self.load_mode_queue[insert_index] = mode
							end
						end
					end
				end
			end
		end

		self.load_file_total = #self.load_file_queue
		self.load_file_done = 0
	end

	if #self.load_file_queue > 0 then
		local thread_count = math.min(_MAX_THREADS, #self.load_file_queue)
		for i = 1, thread_count do
			local th = love.thread.newThread(_LOAD_AUDIO_THREAD_CODE)
			local cin = love.thread.newChannel()
			local cout = love.thread.newChannel()

			th:start(cin, cout, i)
			self.threads[i] = {th, cin, cout}
		end

		local last_thread_used = 1
		for i = #self.load_file_queue, 1, -1 do
			local cin = self.threads[last_thread_used][2]

			cin:push(self.load_path_queue[i])
			cin:push(self.load_mode_queue[i])
			cin:push(self.load_file_queue[i])
			self.load_path_queue[i] = nil
			self.load_file_queue[i] = nil
			self.load_mode_queue[i] = nil

			last_thread_used = km.zmod(last_thread_used + 1, thread_count)
		end

		for i = 1, thread_count do
			self.threads[i][2]:push("QUIT")
		end
	end

	for i = #self.threads, 1, -1 do
		local th, _, cout = unpack(self.threads[i])

		if th:isRunning() then
			while true do
				local result = cout:pop()
				if result then
					local r1, r2, r3 = unpack(result)
					if r1 == "DONE" then
						table.remove(self.threads, i)
					elseif r1 == "ERROR" then
						log.error("Failed to create audio source for file: %s. Error: %s", r3, r2)
						self.load_file_done = self.load_file_done + 1
					elseif r1 == "OK" then
						local fn, master_src = r3, r2
						self.sources[fn] = {master_src}
						self.load_file_done = self.load_file_done + 1
					end
				else
					break
				end
			end
		else
			log.error("Thread error:%s", th:getError())
			table.remove(self.threads, i)
		end
	end

	if #self.threads > 0 then
		self.progress = self.load_file_done / self.load_file_total
		return false
	end

	self.progress = 1
	self.load_file_done = 0
	self.load_file_total = 0

	return true
end

-- DEPRECATED: 现在不建议使用该接口进行资源加载，sound_db 的主要加载方式是 queue_load_group() + queue_load_done() 的组合，该方法只是考虑历史兼容性的保留！
function sound_db:load_group(name, yielding, filter)
	-- 保持接口兼容：走统一队列状态机，不再维护单独路径
	self:queue_load_group(name)
	while true do
		if self:queue_load_done() then
			break
		end
		if yielding then
			love.timer.sleep(0.001)
		end
	end
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
		for i = 1, #files do
			local f = files[i]

			if sources[f] then
				for _, s in pairs(sources[f]) do
					s:stop()
				end

				source_uses[f] = source_uses[f] - 1

				if source_uses[f] < 1 then
					sources[f] = nil
					source_uses[f] = nil
				end
			end
		end
	end

	local sounds = group.sounds

	if sounds then
		for i = 1, #sounds do
			local s = sounds[i]
			local sound = self.sounds[s]
			local sound_files = sound.files

			for i = 1, #sound_files do
				local f = sound_files[i]

				if sources[f] then
					for _, s in pairs(sources[f]) do
						s:stop()
					end

					source_uses[f] = source_uses[f] - 1

					if source_uses[f] < 1 then
						sources[f] = nil
						source_uses[f] = nil
					end
				end
			end
		end
	end
end

sound_db.request_queue = {}

function sound_db:queue(id, options)
	if not id then
		return
	end

	local sd = self.sounds[id]

	if not sd then
		log.error("SOUND WITH ID %s NOT FOUND", tostring(id))
		log.error(debug.traceback())

		return
	end

	-- mod 在 init() 后动态注册的声音，首次入队时补做预缓存
	if not sd._files_n then
		self:_precache_sound(id, sd)
	end

	local opts = sd

	if options then
		opts = table.merge(sd, options, true)
	end

	self.request_queue[#self.request_queue + 1] = _get_req(id, opts, self.ts)
end

-- 声音终止队列，有两种请求：{id}和{gid}，分别表示停止指定声音ID和停止指定声音组的所有声音
sound_db.stop_queue = {}

function sound_db:stop(id)
	if id then
		local opts = sound_db.sounds[id]

		if opts and (opts.loop or sound_db.sounds[id].interruptible) then
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
	if gid then
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

--- 暂停所有正在播放的声音
function sound_db:pause()
	self.paused = true

	for gid, group_active_sources in pairs(self.active_sources) do
		for _, ast in pairs(group_active_sources) do
			ast.source:pause()
		end
	end
end

--- 恢复所有暂停的声音
function sound_db:resume()
	self.paused = false

	for gid, group_active_sources in pairs(self.active_sources) do
		for _, ast in pairs(group_active_sources) do
			ast.source:play()
		end
	end
end

--- 检查指定声音ID是否正在播放
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

---@param req table {id} or {gid}
function sound_db:_stop_sources(stop_request)
	if stop_request.id then
		if self.sounds[stop_request.id].ref_counted then
			local rc = self.ref_counters[stop_request.id] or 0
			rc = rc - 1
			self.ref_counters[stop_request.id] = rc
			if rc > 0 then
				return
			end
		end
		for _, group_active_sources in pairs(self.active_sources) do
			for i = 1, #group_active_sources do
				if group_active_sources[i].id == stop_request.id then
					group_active_sources[i].source:stop()
				end
			end
		end
		return
	end

	if stop_request.gid then
		local group_active_sources = self.active_sources[stop_request.gid]
		if group_active_sources then
			for i = 1, #group_active_sources do
				group_active_sources[i].source:stop()
			end
		end
		return
	end
end

function sound_db:update(dt)
	local now_ts = self.ts

	if not self.paused then
		now_ts = now_ts + dt
	end

	-- 处理所有停止请求
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

		sound_db.stop_queue[i] = nil
	end

	-- 回收已停止的声音源
	if not self.paused then
		for gid, group_active_sources in pairs(self.active_sources) do
			for i = #group_active_sources, 1, -1 do
				if not group_active_sources[i].source:isPlaying() then
					table.remove(group_active_sources, i)
				end
			end
		end
	end

	-- 处理所有播放请求，如果请求设置了delay选项，则会在指定的延迟时间后才播放
	local queue = sound_db.request_queue

	for i = #queue, 1, -1 do
		local req = queue[i]

		if not req.options.delay or now_ts - req.qts >= req.options.delay then
			self:play(req)
			table.remove(queue, i)
			req.options = nil
			_req_pool[#_req_pool + 1] = req
		end
	end

	if not self.missing_sources_summary_printed and next(self.missing_sources_warned) ~= nil then
		local missing = {}
		for sid, _ in pairs(self.missing_sources_warned) do
			missing[#missing + 1] = sid
		end
		table.sort(missing)
		self.missing_sources_summary_printed = true
		-- 这里给一条总清单，方便后续一次性补资源文件。
		log.error("Missing sound sources summary (%s): %s", #missing, table.concat(missing, ", "))
	end

	self.ts = now_ts
end

function sound_db:play(request)
	local options = request.options
	local se = self.sound_extras[request.id]
	local last_play_ts = se.last_play_ts -- FFI float，零初始化，无需 or 0
	local play_due = true

	if options.chance and math.random() >= options.chance then
		return
	end

	-- 如果设置了every选项，则每隔指定的请求次数才会播放一次
	if options.every then
		local every_counter = se.every_counter -- FFI int32，零初始化

		if every_counter ~= 0 then
			play_due = false
		end

		se.every_counter = (every_counter + 1) % options.every
	end

	-- 如果设置了ignore选项，则在上次播放后指定的时间内再次请求播放同一声音时会被忽略
	if options.ignore and self.ts - last_play_ts < options.ignore then
		play_due = false
	end

	-- 如果设置了ref_counted选项，则会维护一个引用计数器，后续请求不发出实际声音
	if options.ref_counted then
		local rc = self.ref_counters[request.id] or 0

		rc = rc + 1

		if rc ~= 1 then
			play_due = false
		end

		self.ref_counters[request.id] = rc
	end

	local n_ps = 0

	if options.mode == "sequence" then
		-- FFI int32 零初始化为 0，用 == 0 代替 not 判断
		if se.sequence == 0 then
			se.sequence = 1
		end
		local src = self.sources[options.files[se.sequence]]
		if src then
			n_ps = 1
			_ps[1] = src
		end
		se.sequence = se.sequence % #options.files + 1
	elseif options.mode == "random" then
		local src = self.sources[options.files[math.random(1, #options.files)]]
		if src then
			n_ps = 1
			_ps[1] = src
		end
	elseif options.mode == "concurrent" then
		for _, f in ipairs(options.files) do
			local src = self.sources[f]
			if src then
				n_ps = n_ps + 1
				_ps[n_ps] = src
			end
		end
	else
		local src = self.sources[options.files[1]]
		if src then
			n_ps = 1
			_ps[1] = src
		end
	end

	if n_ps == 0 then
		if not self.missing_sources_warned[request.id] then
			self.missing_sources_warned[request.id] = true
			-- 同一声音缺资源只记录一次，避免重复刷屏。
			log.error("SOUND %s defined but sound sources missing. Missing file during load?", request.id)
		end

		return
	end

	if play_due then
		for i = 1, n_ps do
			self:_play(request, _ps[i])
			_ps[i] = nil
		end
		se.last_play_ts = self.ts
	else
		for i = 1, n_ps do
			_ps[i] = nil
		end
	end
end

-- 在指定的声音源池中找到最早将要停止的声音源，返回其索引位置
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
	-- 先遍历，有空闲的资源，直接返回即可
	for i = 1, #source_pool do
		local source = source_pool[i]

		if not source:isPlaying() then
			return source
		end
	end

	-- 否则，克隆一个新的资源加入池中
	local new_source = source_pool[1]:clone()
	source_pool[#source_pool + 1] = new_source

	return new_source
end

function sound_db:_play(request, source_pool)
	local opts = request.options
	local active_list = self.active_sources[opts.source_group]

	if not active_list then
		log.error("SOUND %s group %s not found", request.id, opts.source_group)

		return
	end

	local max = self.source_groups[opts.source_group].max_sources
	local source

	if max == 0 then
		log.error("看到报告作者：max_sources for %s is 0", opts.source_group)

		return
	end

	if #active_list < max then
		source = get_or_create_source(source_pool)
	else
		local ste_idx = soon_to_stop_source(active_list)
		local ste_ast = active_list[ste_idx]

		ste_ast.source:stop()

		table.remove(active_list, ste_idx)

		source = get_or_create_source(source_pool)
	end

	local vol = opts.gain or 1
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

			if not source:isPlaying() then
				source:play()
			end
		end

		local ast = {
			id = request.id,
			source = source,
			ref_vol = ref_vol
		}

		active_list[#active_list + 1] = ast
	else
		log.error("source:play() failed! source: %s sound_id: %s", tostring(source), request.id)
	end
end

return sound_db
