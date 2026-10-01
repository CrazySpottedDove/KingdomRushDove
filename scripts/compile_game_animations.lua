local ffi = require("ffi")

local input_file = arg[1] or "kr1/data/game_animations.lua"
local output_file = arg[2] or "kr1/data/game_animations.bin"

-- 文件布局（全部小端）：
--   header: u32 anim_count
--   directory: anim_count * (u16 name_len, name, u16 prefix_len, prefix, u32 frame_count)
--   frames: total_frames * u16  （按 directory 顺序连续存放）
-- 帧名（prefix_0001）不入文件，运行时按 prefix + 帧号生成。

local u16 = ffi.new("uint16_t[1]")
local u32 = ffi.new("uint32_t[1]")

local function load_table_from_file(filename)
	local chunk, err = loadfile(filename)

	if not chunk then
		error("Failed to load file: " .. filename .. "\n" .. tostring(err))
	end

	local ok, tbl = pcall(chunk)

	if not ok then
		error("Failed to eval file: " .. filename .. "\n" .. tostring(tbl))
	end

	if type(tbl) ~= "table" then
		error("File does not return table: " .. filename)
	end

	if tbl.animations and type(tbl.animations) == "table" then
		tbl = tbl.animations
	end

	return tbl
end

-- 从原始定义里展开出帧号，返回 {frame_count, prefix, frame_numbers}
local function extract_frame_from(a)
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
			for i = 1, #a.pre do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = a.pre[i]
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
			for i = 1, #a.post do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = a.post[i]
			end
		end

		if a.frames then
			for i = 1, #a.frames do
				frame_count = frame_count + 1
				frame_numbers[frame_count] = a.frames[i]
			end
		end
	end

	return {frame_count, prefix, frame_numbers}
end

local src = load_table_from_file(input_file)
local compiled = {}
local source_count = 0
local compiled_count = 0
local duplicate_count = 0
local duplicate_keys = {}

for k, v in pairs(src) do
	source_count = source_count + 1

	if v.layer_prefix then
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

			if compiled[nk] then
				duplicate_count = duplicate_count + 1
				duplicate_keys[#duplicate_keys + 1] = string.format("%s (from %s)", nk, k)
			else
				compiled[nk] = extract_frame_from(nv)
				compiled_count = compiled_count + 1
			end
		end
	else
		if compiled[k] then
			duplicate_count = duplicate_count + 1
			duplicate_keys[#duplicate_keys + 1] = k
		else
			compiled[k] = extract_frame_from(v)
			compiled_count = compiled_count + 1
		end
	end
end

-- 排序，保证产物可复现（帧池顺序与 directory 顺序一致）
local keys = {}

for k in pairs(compiled) do
	keys[#keys + 1] = k
end

table.sort(keys)

local total_frames = 0
local size = 4

for i = 1, #keys do
	local def = compiled[keys[i]]
	total_frames = total_frames + def[1]
	size = size + 2 + #keys[i] + 2 + #(def[2] or "") + 4
end

size = size + total_frames * 2

local buf = ffi.new("uint8_t[?]", size)
local p = 0

local function put_u16(v)
	u16[0] = v
	ffi.copy(buf + p, u16, 2)
	p = p + 2
end

local function put_u32(v)
	u32[0] = v
	ffi.copy(buf + p, u32, 4)
	p = p + 4
end

local function put_bytes(s)
	if #s > 0 then
		ffi.copy(buf + p, s, #s)
		p = p + #s
	end
end

put_u32(#keys)

for i = 1, #keys do
	local name = keys[i]
	local prefix = compiled[name][2] or ""

	if #name > 65535 or #prefix > 65535 then
		error(string.format("animation %s name/prefix too long", name))
	end

	put_u16(#name)
	put_bytes(name)
	put_u16(#prefix)
	put_bytes(prefix)
	put_u32(compiled[name][1])
end

local frame_buf = ffi.new("uint16_t[?]", total_frames > 0 and total_frames or 1)
local cursor = 0

for i = 1, #keys do
	local def = compiled[keys[i]]
	local count = def[1]
	local numbers = def[3]

	for j = 1, count do
		local n = numbers[j]

		if type(n) ~= "number" or n < 0 or n > 65535 or n % 1 ~= 0 then
			error(string.format("animation %s frame number out of uint16 range: %s", keys[i], tostring(n)))
		end

		frame_buf[cursor + j - 1] = n
	end

	cursor = cursor + count
end

ffi.copy(buf + p, frame_buf, total_frames * 2)
p = p + total_frames * 2

assert(p == size, string.format("binary size mismatch: %d ~= %d", p, size))

local out = assert(io.open(output_file, "wb"))
out:write(ffi.string(buf, size))
out:close()

print(string.format("Compiled %d source animations into %d runtime animations.", source_count, compiled_count))

if duplicate_count > 0 then
	print(string.format("Skipped %d duplicate animation keys (kept first occurrence).", duplicate_count))
	table.sort(duplicate_keys)
	print("Duplicate animation keys:")

	for i = 1, #duplicate_keys do
		print(duplicate_keys[i])
	end
end

print(string.format("Output: %s (%d animations, %d frames, %.1f KB)", output_file, #keys, total_frames, size / 1024))
