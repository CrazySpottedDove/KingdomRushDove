-- chunkname: @./all/animation_db.lua
local log = require("lib.klua.log"):new("animation_db")
local km = require("lib.klua.macros")

require("lib.klua.table")
require("lib.klua.dump")

local FS = love.filesystem
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local adaptive_fps = require("dove_modules.perf.adaptive_fps")
require("all.constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
-- animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}
animation_db.loaded = false

local perf = require("dove_modules.perf.perf")

--- 从原始的动画定义表 a 中提取出需要的字段，返回实际运行时使用的数据格式 {frame_count, frame_names}
function animation_db.extract_frame_from(a)
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
					frame_names[frame_count] = prefix .. string.format("_%04i", frame)
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. string.format("_%04i", range[j])
				end
			end
		end
	else
		if a.pre then
			local pre = a.pre
			for i = 1, #pre do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", pre[i])
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", frame)
			end
		end

		if a.post then
			local post = a.post
			for i = 1, #post do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", post[i])
			end
		end
	end

	return {frame_count, frame_names}
end

function animation_db:load()
	if self.loaded then
		return
	end
	-- self.tick_length = TICK_LENGTH
	self.db = FS.load(KR_PATH_GAME .. "/data/game_animations.luac")()
	self.loaded = true
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

	if not fps then
		fps = self.fps
	end

	local len = a[1]
	local time_in_frames_plus_eps = time_offset * fps
	local idx = loop and (floor(time_in_frames_plus_eps) % len + 1) or max(1, min(len, ceil(time_in_frames_plus_eps)))

	return a[2][idx], max(0, floor((ceil(time_in_frames_plus_eps + adaptive_fps.tick_length * fps) - 1) / len)), idx
end

--- DEPRECATED: 该方法已废弃，建议使用 extrace_frame_from 来直接从原始定义表中提取出 frame_count 和 frame_names。此处保留以提供部分插件代码的兼容性。
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
					frame_names[frame_count] = prefix .. string.format("_%04i", frame)
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. string.format("_%04i", range[j])
				end
			end
		end
	else
		if a.pre then
			local pre = a.pre
			for i = 1, #pre do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", pre[i])
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", frame)
			end
		end

		if a.post then
			local post = a.post
			for i = 1, #post do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. string.format("_%04i", post[i])
			end
		end
	end

	self.db[name] = {frame_count, frame_names}
end

function animation_db:fni(animation, time_offset, loop, fps)
	if not fps then
		fps = self.fps
	end

	local len = animation[1]
	local time_in_frames_plus_eps = time_offset * fps
	-- local next_elapsed = ceil(time_in_frames_plus_eps + self.tick_length * fps)
	local runs = max(0, floor((ceil(time_in_frames_plus_eps + self.tick_length * fps) - 1) / len))

	if loop then
		local idx = floor(time_in_frames_plus_eps) % len + 1

		return animation[2][idx], runs, idx
	else
		local elapsed_frames = ceil(time_in_frames_plus_eps)
		local idx = max(1, min(len, elapsed_frames))

		return animation[2][idx], runs, idx
	end
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
		frame_count = frame_count + v[1]
	end
	print(string.format("animation count: %d, total frame count: %d", animation_count, frame_count))
end

return animation_db
