-- lib/klove/atlas_binary.lua
-- 图集元数据紧凑二进制格式，用于替代 .bin/.abin（Lua 逐字节码），降低存储体积。
-- 加载端见 lib/klove/image_db.lua:preload_atlas_from_bytecode；
-- 生成端见 scripts/compile_image_atlas.lua 与 dove_modules/atlas_manager/atlas_util.lua。
--
-- 布局（小端；所有整数无符号）：
--   "KRAB"                 magic (4 bytes)
--   u8                     version (=1)
--   u32                    frame_count
--   u16                    atlas_name_count
--     [u16 len + bytes] * atlas_name_count
--   frame_count 条记录：
--     u16 len + bytes       帧名 (key)
--     u16                   atlas 索引 (1-based)
--     u16 fq1,fq2,fq3,fq4   f_quad
--     u16 aw,ah             a_size
--     u16 t1,t2             trim[1],trim[2]
--     f32                   ref_scale
--     u16 s1,s2             size
--     u16 alias_count
--       [u16 len + bytes] * alias_count   别名帧名

local ffi = require("ffi")

local AB = {}
AB.MAGIC = "KRAB"
AB.VERSION = 1

local fu = ffi.new("union { float f; uint32_t u; }")

local function u16(v)
	v = math.floor((v or 0) + 0.5)
	if v < 0 or v > 65535 then
		error("atlas_binary: u16 out of range: " .. tostring(v))
	end
	return string.char(v % 256, math.floor(v / 256) % 256)
end

local function u32(v)
	v = math.floor((v or 0) + 0.5)
	return string.char(v % 256, math.floor(v / 256) % 256, math.floor(v / 65536) % 256, math.floor(v / 16777216) % 256)
end

local function f32(x)
	fu.f = x or 0
	return u32(fu.u)
end

local function wstr(s)
	s = s or ""
	return u16(#s) .. s
end

--- 打包为二进制字符串
---@param frames table name -> {a_name, size, trim, a_size, f_quad, alias, ref_scale}
---@param force_astc boolean 为 true 时把 a_name 扩展名替换为 .astc（安卓）
function AB.pack(frames, force_astc)
	local function aname(v)
		if force_astc then
			return (v.a_name:gsub("%.[^%.]+$", ".astc"))
		end
		return v.a_name
	end

	local keys = {}
	for k in pairs(frames) do
		keys[#keys + 1] = k
	end
	table.sort(keys)

	local atlas_index, atlas_list = {}, {}
	local function aidx(n)
		local i = atlas_index[n]
		if not i then
			i = #atlas_list + 1
			atlas_list[i] = n
			atlas_index[n] = i
		end
		return i
	end
	for _, k in ipairs(keys) do
		aidx(aname(frames[k]))
	end

	local parts = {AB.MAGIC, string.char(AB.VERSION), u32(#keys), u16(#atlas_list)}
	for i = 1, #atlas_list do
		parts[#parts + 1] = wstr(atlas_list[i])
	end
	for _, k in ipairs(keys) do
		local v = frames[k]
		local q = v.f_quad or {}
		local a = v.a_size or {}
		local t = v.trim or {}
		local s = v.size or {}
		parts[#parts + 1] = wstr(k)
		parts[#parts + 1] = u16(atlas_index[aname(v)])
		parts[#parts + 1] = u16(q[1] or 0) .. u16(q[2] or 0) .. u16(q[3] or 0) .. u16(q[4] or 0)
		parts[#parts + 1] = u16(a[1] or 0) .. u16(a[2] or 0)
		parts[#parts + 1] = u16(t[1] or 0) .. u16(t[2] or 0)
		parts[#parts + 1] = f32(v.ref_scale or 1)
		parts[#parts + 1] = u16(s[1] or 0) .. u16(s[2] or 0)
		local al = v.alias
		if type(al) == "table" and #al > 0 then
			parts[#parts + 1] = u16(#al)
			for i = 1, #al do
				parts[#parts + 1] = wstr(al[i])
			end
		else
			parts[#parts + 1] = u16(0)
		end
	end
	return table.concat(parts)
end

--- 解析二进制字符串，返回与旧字节码一致的 info 结构 {keys, values, count}
function AB.unpack(data)
	if type(data) ~= "string" or #data < 9 or data:sub(1, 4) ~= AB.MAGIC then
		return nil, "bad magic"
	end
	local pos = 5
	local ver = data:byte(pos)
	pos = pos + 1
	if ver ~= AB.VERSION then
		return nil, "unsupported version " .. tostring(ver)
	end

	local function ru16()
		local a, b = data:byte(pos, pos + 1)
		pos = pos + 2
		return (a or 0) + (b or 0) * 256
	end
	local function ru32()
		local a, b, c, d = data:byte(pos, pos + 3)
		pos = pos + 4
		return (a or 0) + (b or 0) * 256 + (c or 0) * 65536 + (d or 0) * 16777216
	end
	local function rf32()
		fu.u = ru32()
		return fu.f
	end
	local function rstr()
		local n = ru16()
		local s = data:sub(pos, pos + n - 1)
		pos = pos + n
		return s
	end

	local n = ru32()
	local na = ru16()
	local atlas = {}
	for i = 1, na do
		atlas[i] = rstr()
	end

	local info = {
		keys = {},
		values = {},
		count = n
	}
	for i = 1, n do
		local key = rstr()
		local ai = ru16()
		local fq1, fq2, fq3, fq4 = ru16(), ru16(), ru16(), ru16()
		local aw, ah = ru16(), ru16()
		local t1, t2 = ru16(), ru16()
		local ref = rf32()
		local s1, s2 = ru16(), ru16()
		local ac = ru16()
		local alias = nil
		if ac > 0 then
			alias = {}
			for j = 1, ac do
				alias[j] = rstr()
			end
		end
		info.keys[i] = key
		info.values[i] = {atlas[ai], {fq1, fq2, fq3, fq4, aw, ah}, {t1, t2}, ref, {s1, s2}, alias}
	end
	return info
end

--- 判断一段数据是否为图集二进制格式
function AB.is_binary(data)
	return type(data) == "string" and data:sub(1, 4) == AB.MAGIC
end

return AB
