-- 将 v3 文本格式的 exo 编译为紧凑二进制（EXO3 v1），供 all/exoskeleton.lua:load_packed 加载。
--
-- 用法：
--   luajit scripts/compile_exoskeletons.lua [输入目录] [--check]
--   默认输入目录：kr1/data/exoskeletons
--   --check：编译后立即解码并与源数据逐字段比对（float32 精度），有差异则报错
--
-- 文件布局（全部小端）：
--   header: u32 magic('EXO3') | u16 version | u8 flags | u8 reserved | u32 payload_size
--   payload（flags bit0=1 时整体 zlib 压缩）:
--     u16 part_count | u16 attach_count | u16 anim_count
--     u32 unique_frame_count | u32 total_unique_entries
--     parts    : part_count    * (u16 name_len, name, f32 ox, f32 oy)
--     attach   : attach_count  * (u16 name_len, name)
--     animations: anim_count   * (u16 name_len, name, u32 frame_count, u32 frame_ref[frame_count])
--     entry_counts: unique_frame_count * u16
--     floats   : total_unique_entries * 10 * f32

local ffi = require("ffi")

ffi.cdef([[
unsigned long compressBound(unsigned long sourceLen);
int compress2(unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen, int level);
]])

local function load_zlib()
	-- 按平台选择 zlib 动态库名（不做容错重试，加载失败直接报错）
	local name

	if jit and jit.os == "Windows" then
		name = "zlib1"
	else
		name = "z"
	end

	return ffi.load(name)
end

local Z = load_zlib()

local MAGIC = 0x334F5845 -- "EXO3"
local FORMAT_VERSION = 1
local FLAG_ZLIB = 1

local u16 = ffi.new("uint16_t[1]")
local u32 = ffi.new("uint32_t[1]")
local f32 = ffi.new("float[1]")

local function die(fmt, ...)
	io.stderr:write(string.format(fmt, ...) .. "\n")
	os.exit(1)
end

local function load_v3(path)
	local chunk, err = loadfile(path)

	if not chunk then
		die("loadfile 失败: %s (%s)", path, err or "?")
	end

	local exo = chunk()

	if type(exo) ~= "table" then
		die("文件未返回 table: %s", path)
	end

	return exo
end

-- 严格校验，任何不符合即报错，保证二进制格式的字段不变性由编译期唯一把控
local function validate(exo, path)
	if type(exo.parts) ~= "table" then
		die("%s: parts 缺失或非 table", path)
	end

	for i, p in ipairs(exo.parts) do
		if type(p) ~= "table" or #p ~= 3 or type(p[1]) ~= "string" or type(p[2]) ~= "number" or type(p[3]) ~= "number" then
			die("%s: parts[%d] 结构非法（应为 {string,number,number}）", path, i)
		end

		if #p[1] > 65535 then
			die("%s: parts[%d] 名称过长", path, i)
		end
	end

	local part_count = #exo.parts

	exo.attach_points = exo.attach_points or {}

	if type(exo.attach_points) ~= "table" then
		die("%s: attach_points 非 table", path)
	end

	for i, a in ipairs(exo.attach_points) do
		if type(a) ~= "table" or #a ~= 1 or type(a[1]) ~= "string" then
			die("%s: attach_points[%d] 结构非法（应为 {string}）", path, i)
		end

		if #a[1] > 65535 then
			die("%s: attach_points[%d] 名称过长", path, i)
		end
	end

	local attach_count = #exo.attach_points

	if part_count > 65535 or attach_count > 65535 then
		die("%s: parts/attach_points 数量超 u16", path)
	end

	if type(exo.animations) ~= "table" then
		die("%s: animations 缺失或非 table", path)
	end

	if #exo.animations > 65535 then
		die("%s: animations 数量超 u16", path)
	end

	for ai, anim in ipairs(exo.animations) do
		if type(anim) ~= "table" or type(anim.name) ~= "string" then
			die("%s: animations[%d].name 非法", path, ai)
		end

		if #anim.name > 65535 then
			die("%s: animations[%d] 名称过长", path, ai)
		end

		if type(anim.frames) ~= "table" then
			die("%s: animations[%d].frames 非 table", path, ai)
		end

		for fi, frame in ipairs(anim.frames) do
			if type(frame) ~= "table" then
				die("%s: animations[%d].frames[%d] 非 table", path, ai, fi)
			end

			for ei, e in ipairs(frame) do
				if type(e) ~= "table" or #e ~= 10 then
					die("%s: animations[%d].frames[%d].entries[%d] 长度非 10", path, ai, fi, ei)
				end

				for j = 1, 10 do
					if type(e[j]) ~= "number" then
						die("%s: animations[%d].frames[%d].entries[%d][%d] 非 number", path, ai, fi, ei, j)
					end
				end

				local et = e[1]

				if et ~= 1 and et ~= 8 then
					die("%s: animations[%d].frames[%d].entries[%d] type=%s 非法", path, ai, fi, ei, tostring(et))
				end

				local idx = e[2]

				if et == 1 then
					if idx % 1 ~= 0 or idx < 1 or idx > part_count then
						die("%s: animations[%d].frames[%d].entries[%d] part_idx=%s 越界", path, ai, fi, ei, tostring(idx))
					end
				else
					if idx % 1 ~= 0 or idx < 1 or idx > attach_count then
						die("%s: animations[%d].frames[%d].entries[%d] attach_idx=%s 越界", path, ai, fi, ei, tostring(idx))
					end
				end
			end
		end
	end
end

-- 将一帧编码为 float32 字节串（10*N 字节），用于去重与写入
local function encode_frame(frame)
	local n = #frame
	local tmp = ffi.new("float[?]", n * 10)

	for i = 0, n - 1 do
		local e = frame[i + 1]
		local base = i * 10

		for j = 0, 9 do
			tmp[base + j] = e[j + 1]
		end
	end

	return ffi.string(tmp, n * 40)
end

local function build_payload(exo)
	local part_count = #exo.parts
	local attach_count = #exo.attach_points
	local anim_count = #exo.animations

	-- 去重帧池
	local unique_frames = {} -- {count, bytes}
	local dedup = {}

	-- 每个动画：{name, refs = {unique_idx...}}
	local anim_refs = {}

	for ai, anim in ipairs(exo.animations) do
		local refs = {}

		for fi, frame in ipairs(anim.frames) do
			local bytes = encode_frame(frame)
			local uidx = dedup[bytes]

			if not uidx then
				uidx = #unique_frames + 1
				unique_frames[uidx] = {
					count = #frame,
					bytes = bytes
				}
				dedup[bytes] = uidx
			end

			refs[fi] = uidx
		end

		anim_refs[ai] = {
			name = anim.name,
			refs = refs
		}
	end

	local unique_frame_count = #unique_frames
	local total_unique_entries = 0

	for _, uf in ipairs(unique_frames) do
		total_unique_entries = total_unique_entries + uf.count
	end

	-- 计算 payload 大小
	local size = 2 + 2 + 2 + 4 + 4

	for _, p in ipairs(exo.parts) do
		size = size + 2 + #p[1] + 4 + 4
	end

	for _, a in ipairs(exo.attach_points) do
		size = size + 2 + #a[1]
	end

	for _, ar in ipairs(anim_refs) do
		size = size + 2 + #ar.name + 4 + 4 * #ar.refs
	end

	size = size + 2 * unique_frame_count
	size = size + total_unique_entries * 10 * 4

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

	local function put_f32(v)
		f32[0] = v
		ffi.copy(buf + p, f32, 4)
		p = p + 4
	end

	local function put_bytes(s)
		if #s > 0 then
			ffi.copy(buf + p, s, #s)
			p = p + #s
		end
	end

	local function put_name(s)
		put_u16(#s)
		put_bytes(s)
	end

	put_u16(part_count)
	put_u16(attach_count)
	put_u16(anim_count)
	put_u32(unique_frame_count)
	put_u32(total_unique_entries)

	for _, part in ipairs(exo.parts) do
		put_name(part[1])
		put_f32(part[2])
		put_f32(part[3])
	end

	for _, a in ipairs(exo.attach_points) do
		put_name(a[1])
	end

	for _, ar in ipairs(anim_refs) do
		put_name(ar.name)
		put_u32(#ar.refs)

		for _, ref in ipairs(ar.refs) do
			put_u32(ref)
		end
	end

	for _, uf in ipairs(unique_frames) do
		put_u16(uf.count)
	end

	for _, uf in ipairs(unique_frames) do
		put_bytes(uf.bytes)
	end

	assert(p == size, "payload 大小不一致: " .. p .. " ~= " .. size)

	return ffi.string(buf, size)
end

-- 供 --check 使用的解码器（与运行时解析保持一致）
local function decode_payload(payload)
	local p = 1

	local function rd_u16()
		local a, b = payload:byte(p, p + 1)
		p = p + 2
		return a + b * 256
	end

	local function rd_u32()
		local a, b, c, d = payload:byte(p, p + 3)
		p = p + 4
		return a + b * 256 + c * 65536 + d * 16777216
	end

	local function rd_f32()
		local b1, b2, b3, b4 = payload:byte(p, p + 3)
		p = p + 4
		local le = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
		u32[0] = le
		return ffi.cast("float*", u32)[0]
	end

	local function rd_name()
		local n = rd_u16()
		local s = payload:sub(p, p + n - 1)
		p = p + n
		return s
	end

	local out = {}
	local part_count = rd_u16()
	local attach_count = rd_u16()
	local anim_count = rd_u16()
	local unique_frame_count = rd_u32()
	local total_unique_entries = rd_u32()

	out.parts = {}

	for i = 1, part_count do
		local name = rd_name()
		local ox = rd_f32()
		local oy = rd_f32()
		out.parts[i] = {name, ox, oy}
	end

	out.attach_points = {}

	for i = 1, attach_count do
		out.attach_points[i] = {rd_name()}
	end

	local anims = {}

	for i = 1, anim_count do
		local name = rd_name()
		local fcount = rd_u32()
		local refs = {}

		for j = 1, fcount do
			refs[j] = rd_u32()
		end

		anims[i] = {
			name = name,
			refs = refs
		}
	end

	local counts = {}

	for i = 1, unique_frame_count do
		counts[i] = rd_u16()
	end

	local flat = {}

	for i = 1, unique_frame_count do
		local c = counts[i]
		local entries = {}

		for j = 1, c do
			local e = {}

			for k = 1, 10 do
				e[k] = rd_f32()
			end

			entries[j] = e
		end

		flat[i] = entries
	end

	out.animations = {}

	for i, ar in ipairs(anims) do
		local frames = {}

		for j, ref in ipairs(ar.refs) do
			frames[j] = flat[ref]
		end

		out.animations[i] = {
			name = ar.name,
			frames = frames
		}
	end

	out._total_unique_entries = total_unique_entries

	return out
end

local function compress(src)
	local src_len = #src
	local bound = Z.compressBound(src_len)
	local dst = ffi.new("uint8_t[?]", bound)
	local dst_len = ffi.new("unsigned long[1]", bound)
	local rc = Z.compress2(dst, dst_len, ffi.cast("const unsigned char*", src), src_len, 6)

	if rc ~= 0 then
		die("zlib compress2 失败: %d", rc)
	end

	return ffi.string(dst, dst_len[0])
end

local function write_file(out_path, payload)
	local header = ffi.new("uint8_t[?]", 12)
	u32[0] = MAGIC
	ffi.copy(header, u32, 4)
	u16[0] = FORMAT_VERSION
	ffi.copy(header + 4, u16, 2)
	header[6] = FLAG_ZLIB
	header[7] = 0
	u32[0] = #payload
	ffi.copy(header + 8, u32, 4)

	local body = compress(payload)
	local f, err = io.open(out_path, "wb")

	if not f then
		die("写文件失败: %s (%s)", out_path, err or "?")
	end

	f:write(ffi.string(header, 12))
	f:write(body)
	f:close()
end

local function check_roundtrip(exo, decoded, path)
	-- 与源数据逐字段比较（float32 精度）
	if #exo.parts ~= #decoded.parts then
		die("%s: check parts 数量不一致", path)
	end

	for i, part in ipairs(exo.parts) do
		local d = decoded.parts[i]

		if part[1] ~= d[1] then
			die("%s: check parts[%d].name 不一致", path, i)
		end

		f32[0] = part[2]

		if f32[0] ~= d[2] then
			die("%s: check parts[%d].ox 不一致", path, i)
		end

		f32[0] = part[3]

		if f32[0] ~= d[3] then
			die("%s: check parts[%d].oy 不一致", path, i)
		end
	end

	if #exo.animations ~= #decoded.animations then
		die("%s: check animations 数量不一致", path)
	end

	for ai, anim in ipairs(exo.animations) do
		local da = decoded.animations[ai]

		if anim.name ~= da.name then
			die("%s: check animations[%d].name 不一致", path, ai)
		end

		if #anim.frames ~= #da.frames then
			die("%s: check animations[%d] 帧数不一致", path, ai)
		end

		for fi, frame in ipairs(anim.frames) do
			local dframe = da.frames[fi]

			if #frame ~= #dframe then
				die("%s: check animations[%d].frames[%d] 条目数不一致", path, ai, fi)
			end

			for ei, e in ipairs(frame) do
				local de = dframe[ei]

				for j = 1, 10 do
					f32[0] = e[j]

					if f32[0] ~= de[j] then
						die("%s: check animations[%d].frames[%d].entries[%d][%d] 不一致 (%s ~= %s)", path, ai, fi, ei, j, tostring(f32[0]), tostring(de[j]))
					end
				end
			end
		end
	end
end

local function main()
	local input_dir = "kr1/data/exoskeletons"
	local do_check = false

	for i = 1, #arg do
		if arg[i] == "--check" then
			do_check = true
		elseif arg[i] ~= "" then
			input_dir = arg[i]
		end
	end

	local p = io.popen(string.format("find %q -maxdepth 1 -type f -name '*.lua'", input_dir))
	local files = {}

	for line in p:lines() do
		files[#files + 1] = line
	end

	p:close()

	table.sort(files)

	if #files == 0 then
		die("未在 %s 找到任何 .lua 文件", input_dir)
	end

	local total_source, total_out, total_frames, total_unique = 0, 0, 0, 0

	for _, path in ipairs(files) do
		local exo = load_v3(path)
		validate(exo, path)

		local payload = build_payload(exo)

		if do_check then
			check_roundtrip(exo, decode_payload(payload), path)
		end

		local out_path = path:gsub("%.lua$", ".exo3")

		write_file(out_path, payload)

		local sf = io.open(path, "rb")

		if sf then
			total_source = total_source + #sf:read("*a")
			sf:close()
		end

		local of = io.open(out_path, "rb")

		if of then
			total_out = total_out + #of:read("*a")
			of:close()
		end
	end

	print(string.format("编译完成: %d 个文件  %.1f MB -> %.1f MB (%.1f%%)", #files, total_source / 1048576, total_out / 1048576, total_source > 0 and total_out / total_source * 100 or 0))
end

main()
