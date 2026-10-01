-- chunkname: @./all/animation_db.lua
local log = require("lib.klua.log"):new("animation_db")
local ffi = require("ffi")

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
-- 缺失动画时供渲染热路径复用的空 link（避免调用方判空）
animation_db.EMPTY_LINK = {}

local function build_frame_numbers(frame_numbers, frame_count)
	local nums = ffi.new("uint32_t[?]", frame_count)

	for i = 1, frame_count do
		nums[i - 1] = frame_numbers[i]
	end

	return nums
end

--- 从原始的动画定义表 a 中提取出需要的字段，返回运行时紧凑格式 {frame_count, prefix, nums}
--- nums 为 ffi uint32 数组（0 基），保存帧编号；帧名（prefix_0001）在 link 时按需生成。
function animation_db.extract_frame_from(a)
	local prefix = a.prefix
	local frame_numbers = {}
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
					frame_numbers[frame_count] = frame
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_numbers[frame_count] = range[j]
				end
			end
		end
	else
		if a.pre then
			local pre = a.pre
			for i = 1, #pre do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = pre[i]
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = frame
			end
		end

		if a.post then
			local post = a.post
			for i = 1, #post do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = post[i]
			end
		end

		if a.frames then
			local frames = a.frames
			for i = 1, #frames do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = frames[i]
			end
		end
	end

	local nums = build_frame_numbers(frame_numbers, frame_count)
	local def = {frame_count, prefix, nums}

	def.prefix = prefix
	def.nums = nums

	return def
end

--- 提供给插件的 animations 注册接口
---@param animations table
function animation_db:register_animations(animations)
	for k, v in pairs(animations) do
		self.db[k] = self.extract_frame_from(v)
	end
end

--- 加载编译产物 game_animations.bin（见 scripts/compile_game_animations.lua）：
--- header + directory(name/prefix/count) + 连续 uint16 帧号。
--- 帧号一次性 ffi.copy 成一个大数组，每个 def 用 offset 指向它。
function animation_db:load()
	if self.loaded then
		return
	end

	local bin = FS.read(KR_PATH_GAME .. "/data/game_animations.bin")

	local p = 1

	local function read_u16()
		local a, b = bin:byte(p, p + 1)

		p = p + 2

		return a + b * 256
	end

	local function read_u32()
		local a, b, c, d = bin:byte(p, p + 3)

		p = p + 4

		return a + b * 256 + c * 65536 + d * 16777216
	end

	local anim_count = read_u32()
	local db = {}
	local entries = {}
	local total = 0

	for i = 1, anim_count do
		local name_len = read_u16()
		local name = bin:sub(p, p + name_len - 1)

		p = p + name_len

		local prefix_len = read_u16()
		local prefix = bin:sub(p, p + prefix_len - 1)

		p = p + prefix_len

		local count = read_u32()
		local def = {count}

		def.prefix = prefix
		def.offset = total
		db[name] = def
		entries[i] = def
		total = total + count
	end

	if p - 1 + total * 2 > #bin then
		log.error("game_animations.bin 帧数据越界（文件损坏）")
		return
	end

	local frames = ffi.new("uint16_t[?]", total > 0 and total or 1)

	ffi.copy(frames, ffi.cast("const uint8_t*", bin) + (p - 1), total * 2)

	local base = ffi.cast("uint16_t*", frames)

	for i = 1, anim_count do
		entries[i].nums = base + entries[i].offset
	end

	-- ffi 数组的 gc 锁，不可删去
	self._frames = frames
	self.db = db
	self.loaded = true
end

function animation_db:has_animation(animation_name)
	return self.db[animation_name] ~= nil
end

function animation_db:animation_duration(animation_name)
	return self.db[animation_name][1] / self.fps
end

--- 由动画 def 生成第 idx 帧的帧名（如 soldier_0001）。idx 为 1 基。
function animation_db:def_frame_name(def, idx)
	local num = def.nums[idx - 1]

	if not num then
		return nil
	end

	return def.prefix .. string.format("_%04i", num)
end

--- 把某个动画 def 解析成"可直接渲染的帧引用数组"，缓存于 def.link。
--- 对普通动画，元素是 image_db 的 db_atlas item（miss 时直接打印）；
--- 对 exo 动画，EXO:load 会直接把 def.link 设为 exo_frame 数组，不走这里。
function animation_db:build_link(def, animation_name)
	local count = def[1]
	local prefix = def.prefix
	local nums = def.nums
	local db_atlas = require("lib.klove.image_db").db_atlas
	local link = {}
	local key = animation_name or prefix

	for i = 1, count do
		local fname = prefix .. string.format("_%04i", nums[i - 1])
		local ss = db_atlas[fname]

		if not ss then
			log.error("missing frame: animation %s -> %s", key, fname)
		end

		link[i] = ss
	end

	def.link = link

	return link
end

--- 计算当前帧下标与已循环次数
local function frame_index(len, time_offset, loop, fps)
	local time_in_frames_plus_eps = time_offset * fps
	local idx = loop and (floor(time_in_frames_plus_eps) % len + 1) or max(1, min(len, ceil(time_in_frames_plus_eps)))
	local runs = max(0, floor((ceil(time_in_frames_plus_eps + adaptive_fps.tick_length * fps) - 1) / len))

	return idx, runs
end

--- 原语义不变：完成从动画名称到具体帧名（如 soldier_0001）的转换，返回帧名字符串。
function animation_db:fn(animation_name, time_offset, loop, fps)
	local a = self.db[animation_name]

	if not a then
		if self.missing_animations[animation_name] then
			return nil, 0, nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name] = true

		return nil, 0, nil
	end

	if not fps then
		fps = self.fps
	end

	local idx, runs = frame_index(a[1], time_offset, loop, fps)

	return self:def_frame_name(a, idx), runs, idx
end

--- 新接口：直接返回渲染负载（image_db 的 db_atlas item 或 exo_frame），跳过帧名与 I:s 查找。
function animation_db:f(animation_name, time_offset, loop, fps)
	local a = self.db[animation_name]

	if not a then
		if self.missing_animations[animation_name] then
			return nil, 0, nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name] = true

		return nil, 0, nil
	end

	if not fps then
		fps = self.fps
	end

	local idx, runs = frame_index(a[1], time_offset, loop, fps)
	local link = a.link or self:build_link(a, animation_name)

	return link[idx], runs, idx
end

function animation_db:frame_name(animation_name, frame_idx)
	local a = self.db[animation_name]
	if not a then
		if self.missing_animations[animation_name] then
			return nil
		end

		log.error("animation %s not found", animation_name)

		self.missing_animations[animation_name] = true

		return nil
	end

	return self:def_frame_name(a, frame_idx)
end

--- 释放某一局对局期间建立的 def.link 缓存。必须在 atlas 卸载之前调用，避免悬垂引用。
--- exo def 由 EXO:unload 直接删除，故跳过。
function animation_db:unlink()
	for _, a in pairs(self.db) do
		if not a.exo then
			a.link = nil
		end
	end
end

--- DEPRECATED: 该方法已废弃，建议使用 extract_frame_from 来直接从原始定义表中提取出 frame_count 和帧编号。此处保留以提供部分插件代码的兼容性。
--- @param name string 动画名称，该动画应当在 animation_db 中已经有旧格式的定义
--- 生成的结构：self.db[name] = {[1] = frame_count(int), prefix = prefix(string), nums = ffi uint32 数组}
function animation_db:generate_frames(name)
	local a = self.db[name]

	if a[1] then
		return
	end

	self.db[name] = self.extract_frame_from(a)
end

function animation_db:fni(animation, time_offset, loop, fps)
	if not fps then
		fps = self.fps
	end

	local idx, runs = frame_index(animation[1], time_offset, loop, fps)

	return self:def_frame_name(animation, idx), runs, idx
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
