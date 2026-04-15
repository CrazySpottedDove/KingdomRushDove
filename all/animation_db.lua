-- chunkname: @./all/animation_db.lua
local log = require("lib.klua.log"):new("animation_db")
local km = require("lib.klua.macros")

require("lib.klua.table")
require("lib.klua.dump")

local G = love.graphics
local FS = love.filesystem
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min

require("all.constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}
animation_db.loaded = false

local perf = require("dove_modules.perf.perf")
local frame_suffix_cache = {}

local function frame_suffix(frame)
	local suffix = frame_suffix_cache[frame]

	if not suffix then
		suffix = string.format("_%04i", frame)
		frame_suffix_cache[frame] = suffix
	end

	return suffix
end

--- 私有方法，从原始的动画定义表 a 中提取出需要的字段，返回实际运行时使用的数据格式 {frame_count, frame_names}
local function extract_frame_from(a)
	local prefix = a.prefix
	local frame_names = {}
	local frame_count = 0

	if a.ranges then
		for i = 1, #a.ranges do
			local range = a.ranges[i]

			if #range == 2 then
				local from = range[1]
				local to = range[2]
				local inc = to < from and -1 or 1

				for frame = from, to, inc do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. frame_suffix(frame)
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. frame_suffix(range[j])
				end
			end
		end
	else
		if a.pre then
			local pre = a.pre
			for i = 1, #pre do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(pre[i])
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(frame)
			end
		end

		if a.post then
			local post = a.post
			for i = 1, #post do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(post[i])
			end
		end
	end
	return {frame_count, frame_names}
end

function animation_db:load()
	if self.loaded then
		return
	end

	perf.tmp_start("animation_db:load")
	self.tick_length = TICK_LENGTH
	self.db = {}

	local animation_file = KR_PATH_GAME .. "/data/game_animations.lua"
	local achunk, load_err = FS.load(animation_file)
	if not achunk then
		assert(false, string.format("Failed to load animation file %s.\n%s", animation_file, load_err))
	end

	local ok, atable = pcall(achunk)

	if not ok then
		assert(false, string.format("Failed to eval animation chunk for file:%s", animation_file, atable))
	end

	if not atable then
		assert(false, string.format("Failed to load animation file %s. Could not find .animations", animation_file))
	end

	for k, v in pairs(atable) do
		-- 处理 layerX 的特殊语法糖，生成对应的 layer1, layer2, ... 的动画定义
		if v.layer_from and v.layer_to and v.layer_prefix then
			for i = v.layer_from, v.layer_to do
				local nk = string.gsub(k, "layerX", "layer" .. i)
				local nv = {
					pre = v.pre,
					post = v.post,
					from = v.from,
					to = v.to,
					ranges = v.ranges,
					frames = v.frames,
					prefix = string.format(v.layer_prefix, i)
				}

				self.db[nk] = extract_frame_from(nv)
			end
		else
			self.db[k] = extract_frame_from(v)
		end
	end

	self.loaded = true
	perf.tmp_stop("animation_db:load")
end

-- added: 预构建所有动画的帧数组 frames
function animation_db:prebuild_frames()
	local generate_frames = self.generate_frames

	for name in pairs(self.db) do
		generate_frames(self, name)
	end
end

-- 完成从动画名称到具体帧名（如soldier_0001）的转换
function animation_db:fn(animation_name, time_offset, loop, fps)
	local a = self.db[animation_name]

	if not a then
		if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
			return nil, 0, nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name or "nil"] = true

		return nil, 0, nil
	end

	return self:fni(a, time_offset, loop, fps)
end

--- 完成动画 frames 和 frame_names 的生成。所有从文件加载的动画都还处于不可用阶段，需要通过 generate_frames 来生成 frame_names 和 frame_count，以取得运行时的最高效率。
--- @param name string 动画名称，该动画应当在 animation_db 中已经有旧格式的定义
--- 生成的结构：self.db[name] = {[1] = frame_count(int), [2] = frame_names(array of string)}
function animation_db:generate_frames(name)
	local a = self.db[name]

	if a[1] then
		return
	end

	local prefix = a.prefix
	local frame_names = {}
	local frame_count = 0

	if a.ranges then
		for i = 1, #a.ranges do
			local range = a.ranges[i]

			if #range == 2 then
				local from = range[1]
				local to = range[2]
				local inc = to < from and -1 or 1

				for frame = from, to, inc do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. frame_suffix(frame)
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. frame_suffix(range[j])
				end
			end
		end
	else
		if a.pre then
			local pre = a.pre
			for i = 1, #pre do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(pre[i])
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(frame)
			end
		end

		if a.post then
			local post = a.post
			for i = 1, #post do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(post[i])
			end
		end
	end

	self.db[name] = {frame_count, frame_names}
end

function animation_db:fni(animation, time_offset, loop, fps)
	local a = animation

	fps = fps or self.fps

	-- local frames = a.frames
	local eps = 1e-09
	-- local len = #frames
	-- local len = a.frame_count
	local len = a[1]
	local time_in_frames_plus_eps = time_offset * fps + eps
	local next_elapsed = ceil(time_in_frames_plus_eps + self.tick_length * fps)
	local runs = max(0, floor((next_elapsed - 1) / len))

	if loop then
		local idx = floor(time_in_frames_plus_eps) % len + 1

		-- return a.frame_names[idx], runs, idx
		return a[2][idx], runs, idx
	else
		local elapsed_frames = ceil(time_in_frames_plus_eps)
		local idx = max(1, min(len, elapsed_frames))

		-- return a.frame_names[idx], runs, idx
		return a[2][idx], runs, idx
	end
end

function animation_db:duration(animation_name)
	local a = self.db[animation_name]

	if not a then
		if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
			return nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name or "nil"] = true

		return nil
	end

	-- if not a.frame_names then
	if not a[2] then
		self:fni(a, 0, false)
	end

	-- return a.frame_count / self.fps, a.frame_count
	return a[1] / self.fps, a[1]
end

function animation_db:save_to_file()
	local storage = require("all.storage")
	storage:write_lua("animation_db_dump.lua", self.db)
end

function animation_db:dump()
	local animation_count = 0
	local frame_count = 0
	for k, v in pairs(self.db) do
		animation_count = animation_count + 1
		-- frame_count = frame_count + v.frame_count
		frame_count = frame_count + v[1]
	end
	print(string.format("animation count: %d, total frame count: %d", animation_count, frame_count))
end

return animation_db
