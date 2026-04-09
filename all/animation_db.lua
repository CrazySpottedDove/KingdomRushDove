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

local function is_file(path)
	local info = love.filesystem.getInfo(path)

	return info and info.type == "file"
end

require("all.constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}
animation_db.loaded = false

local perf = require("dove_modules.perf.perf")

function animation_db:load()
	if self.loaded then
		return
	end

	-- collectgarbage()
	-- local before = collectgarbage("count")
	-- perf.tmp_start("animation_db:load")

	local function load_ani_file(f)
		local ok, achunk = pcall(FS.load, f)

		if not ok then
			assert(false, string.format("Failed to load animation file %s.\n%s", f, achunk))
		end

		local ok, atable = pcall(achunk)

		if not ok then
			assert(false, string.format("Failed to eval animation chunk for file:%s", f, atable))
		end

		if not atable then
			assert(false, string.format("Failed to load animation file %s. Could not find .animations", f))
		end

		if atable.animations then
			atable = atable.animations
		end

		for k, v in pairs(atable) do
			if self.db[k] then
				log.error("Animation %s already exists. Not loading it from file %s", k, f)
			-- assert(false, string.format("Animation %s already exists. Not loading it from file %s", k, f))
			else
				self.db[k] = v
			end
		end
	end
	self.tick_length = TICK_LENGTH
	self.db = {}

	local f = string.format("%s/data/game_animations.lua", KR_PATH_GAME)

	load_ani_file(f)

	local path = string.format("%s/data/animations", KR_PATH_GAME)
	local files = FS.getDirectoryItems(path)

	for i = 1, #files do
		local name = files[i]
		local f = path .. "/" .. name

		if is_file(f) and string.match(f, ".lua$") then
			load_ani_file(f)
		end
	end

	local expanded_keys = {}
	local deleted_keys = {}
	local next_deleted_index = 1

	for k, v in pairs(self.db) do
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

				expanded_keys[nk] = nv
				deleted_keys[next_deleted_index] = k
				next_deleted_index = next_deleted_index + 1
			end
		end
	end

	for i = 1, next_deleted_index - 1 do
		self.db[deleted_keys[i]] = nil
	end

	for k, v in pairs(expanded_keys) do
		self.db[k] = v
	end

	self.loaded = true

	self:prebuild_frames()

-- perf.tmp_stop("animation_db:load")
-- collectgarbage()
-- local after = collectgarbage("count")
-- print(string.format("animation_db:load memory usage before: %.2f KB, after: %.2f KB, diff: %.2f KB", before, after, after - before))

-- self:save_to_file()
end

-- added: 预构建所有动画的帧数组 frames
function animation_db:prebuild_frames()
	for name, a in pairs(self.db) do
		self:generate_frames(name)
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

-- 完成动画 frames 和 frame_names 的生成。所有从文件加载的动画都还处于不可用阶段，需要通过 generate_frames 来生成 frame_names 和 frame_count，以取得运行时的最高效率。
function animation_db:generate_frames(name)
	local a = self.db[name]
	local frames = a.frames

	if not frames then
		frames = {}

		if a.ranges then
			for _, range in pairs(a.ranges) do
				if #range == 2 then
					local from = range[1]
					local to = range[2]
					local inc = to < from and -1 or 1

					for i = from, to, inc do
						frames[#frames + 1] = i
					end
				else
					local start_idx = #frames

					for i = 1, #range do
						frames[start_idx + i] = range[i]
					end
				end
			end
		else
			if a.pre then
				local start_idx = #frames

				for i = 1, #a.pre do
					frames[start_idx + i] = a.pre[i]
				end
			end

			if a.from and a.to then
				local inc = a.from > a.to and -1 or 1

				for i = a.from, a.to, inc do
					frames[#frames + 1] = i
				end
			end

			if a.post then
				local start_idx = #frames

				for i = 1, #a.post do
					frames[start_idx + i] = a.post[i]
				end
			end
		end

		a.frames = frames
	end

	if a.prefix and not a.frame_names then
		a.frame_names = {}
		local frame_count = #frames
		for i = 1, frame_count do
			a.frame_names[i] = a.prefix .. string.format("_%04i", frames[i])
		end
		a.frame_count = frame_count
	end

	-- 重建数据结构，除去了无效字段，减少内存开销
	self.db[name] = {
		frame_names = a.frame_names,
		frame_count = a.frame_count
	}

	-- 解引用，避免占用内存
	a.frame_names = nil
end

function animation_db:fni(animation, time_offset, loop, fps)
	local a = animation

	fps = fps or self.fps

	-- local frames = a.frames
	local eps = 1e-09
	-- local len = #frames
	local len = a.frame_count
	local time_in_frames_plus_eps = time_offset * fps + eps
	local next_elapsed = ceil(time_in_frames_plus_eps + self.tick_length * fps)
	local runs = max(0, floor((next_elapsed - 1) / len))

	if loop then
		local idx = floor(time_in_frames_plus_eps) % len + 1

		return a.frame_names[idx], runs, idx
	else
		local elapsed_frames = ceil(time_in_frames_plus_eps)
		local idx = max(1, min(len, elapsed_frames))

		return a.frame_names[idx], runs, idx
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

	if not a.frame_names then
		self:fni(a, 0, false)
	end

	return a.frame_count / self.fps, a.frame_count
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
		frame_count = frame_count + v.frame_count
	end
	print(string.format("animation count: %d, total frame count: %d", animation_count, frame_count))
end

return animation_db
