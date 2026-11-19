local bit = require("bit")
local sha = require("scripts.assets.sha256")

local M = {}

local INDEX_MAGIC_RUNTIME = "KRIR"
local INDEX_MAGIC_SOURCE = "KRIS"
local INDEX_FMT = 2

local function u16(v)
	return string.char(bit.band(v, 0xff), bit.band(bit.rshift(v, 8), 0xff))
end

local function u32(v)
	return string.char(bit.band(v, 0xff), bit.band(bit.rshift(v, 8), 0xff), bit.band(bit.rshift(v, 16), 0xff), bit.band(bit.rshift(v, 24), 0xff))
end

local function u64(v)
	local lo = v % 4294967296
	local hi = math.floor(v / 4294967296)
	return u32(lo) .. u32(hi)
end

local function r16(s, pos)
	local a, b = string.byte(s, pos, pos + 1)
	return a + b * 256
end

local function r32(s, pos)
	local a, b, c, d = string.byte(s, pos, pos + 3)
	return a + b * 256 + c * 65536 + d * 16777216
end

local function r64(s, pos)
	local lo = r32(s, pos)
	local hi = r32(s, pos + 4)
	return lo + hi * 4294967296
end

local function common_prefix(a, b)
	local n = math.min(#a, #b)
	local i = 0
	while i < n and a:byte(i + 1) == b:byte(i + 1) do
		i = i + 1
	end
	return i
end

local function check_hash(h, what)
	if type(h) ~= "string" or #h ~= 32 then
		error((what or "hash") .. " 必须是 32 字节 SHA-256")
	end
	return h
end

function M.pack_index(entries, opts)
	opts = opts or {}
	local magic = opts.source and INDEX_MAGIC_SOURCE or INDEX_MAGIC_RUNTIME
	local source_sha = opts.source_index_sha256 or string.rep("\0", 32)
	local manifest_sha = opts.mirror_manifest_sha256 or string.rep("\0", 32)
	check_hash(source_sha, "source_index_sha256")
	check_hash(manifest_sha, "mirror_manifest_sha256")

	local sorted = {}
	for i = 1, #entries do
		sorted[i] = entries[i]
	end
	table.sort(sorted, function(a, b)
		return a.path < b.path
	end)

	local total = 0
	local body = {}
	body[#body + 1] = magic
	body[#body + 1] = u16(INDEX_FMT)
	body[#body + 1] = u16(opts.flags or 0)
	body[#body + 1] = u32(#sorted)
	body[#body + 1] = u64(opts.total_size or 0)
	body[#body + 1] = source_sha
	body[#body + 1] = manifest_sha

	local prev = ""
	for _, e in ipairs(sorted) do
		local path = assert(e.path, "entry.path")
		local prefix = common_prefix(prev, path)
		local suffix = path:sub(prefix + 1)
		body[#body + 1] = u16(prefix)
		body[#body + 1] = u16(#suffix)
		body[#body + 1] = suffix
		body[#body + 1] = u64(e.size or 0)
		body[#body + 1] = check_hash(e.sha256, "entry.sha256: " .. path)
		total = total + (e.size or 0)
		prev = path
	end
	local payload = table.concat(body)
	if opts.total_size == nil then
		local head = payload:sub(1, 4 + 2 + 2 + 4)
		local tail = payload:sub(4 + 2 + 2 + 4 + 8 + 1)
		payload = head .. u64(total) .. tail
	end
	return payload .. sha.hash_string(payload)
end

function M.parse_index(data)
	if type(data) ~= "string" or #data < 4 + 2 + 2 + 4 + 8 + 32 + 32 + 32 then
		error("索引文件过短")
	end
	local magic = data:sub(1, 4)
	if magic ~= INDEX_MAGIC_RUNTIME and magic ~= INDEX_MAGIC_SOURCE then
		error("索引 magic 错误: " .. magic)
	end
	local fmt = r16(data, 5)
	if fmt ~= INDEX_FMT then
		error("不支持的索引格式: " .. tostring(fmt))
	end
	local payload = data:sub(1, #data - 32)
	local trailer = data:sub(#data - 31)
	if sha.hash_string(payload) ~= trailer then
		error("索引 trailer SHA-256 校验失败")
	end
	local flags = r16(data, 7)
	local count = r32(data, 9)
	local total_size = r64(data, 13)
	local source_sha = data:sub(21, 52)
	local manifest_sha = data:sub(53, 84)
	local pos = 85
	local entries = {}
	local map = {}
	local prev = ""
	for i = 1, count do
		local prefix = r16(data, pos)
		local suffix_len = r16(data, pos + 2)
		pos = pos + 4
		local suffix = data:sub(pos, pos + suffix_len - 1)
		pos = pos + suffix_len
		local path = prev:sub(1, prefix) .. suffix
		local size = r64(data, pos)
		pos = pos + 8
		local h = data:sub(pos, pos + 31)
		pos = pos + 32
		local e = {
			path = path,
			size = size,
			sha256 = h
		}
		entries[i] = e
		map[path] = e
		prev = path
	end
	if pos - 1 ~= #payload then
		error("索引长度不匹配: " .. tostring(pos - 1) .. " != " .. tostring(#payload))
	end
	return {
		magic = magic,
		source = magic == INDEX_MAGIC_SOURCE,
		fmt = fmt,
		flags = flags,
		count = count,
		total_size = total_size,
		source_index_sha256 = source_sha,
		mirror_manifest_sha256 = manifest_sha,
		entries = entries,
		map = map
	}
end

return M
