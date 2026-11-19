local bit = require("bit")

local M = {}

local INDEX_MAGIC_RUNTIME = "KRIR"
local INDEX_MAGIC_SOURCE = "KRIS"
local INDEX_FMT = 2

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

local function hash_string(s)
	return love.data.hash("sha256", s)
end

function M.hash_string(s)
	return hash_string(s)
end

function M.parse(data)
	if type(data) ~= "string" or #data < 85 + 32 then
		error("assets_index_bin: 索引过短")
	end
	local magic = data:sub(1, 4)
	if magic ~= INDEX_MAGIC_RUNTIME and magic ~= INDEX_MAGIC_SOURCE then
		error("assets_index_bin: magic 错误 " .. magic)
	end
	local fmt = r16(data, 5)
	if fmt ~= INDEX_FMT then
		error("assets_index_bin: 不支持格式 " .. tostring(fmt))
	end
	local payload = data:sub(1, #data - 32)
	if hash_string(payload) ~= data:sub(#data - 31) then
		error("assets_index_bin: trailer SHA-256 校验失败")
	end
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
	return {
		magic = magic,
		source = magic == INDEX_MAGIC_SOURCE,
		fmt = fmt,
		count = count,
		total_size = total_size,
		source_index_sha256 = source_sha,
		mirror_manifest_sha256 = manifest_sha,
		entries = entries,
		map = map
	}
end

local function read_all(path)
	if love and love.filesystem then
		local data = love.filesystem.read(path)
		if data then
			return data
		end
	end
	local f = io.open(path, "rb")
	if not f then
		return nil
	end
	local s = f:read("*a")
	f:close()
	return s
end

function M.load(path)
	local data, err = read_all(path)
	if not data then
		return nil, err or ("无法读取 " .. path)
	end
	return M.parse(data)
end

function M.verify_file(index, path)
	local e = index.map[path]
	if not e then
		return nil, "索引中没有 " .. path
	end
	local data = read_all(path)
	if not data then
		return nil, "无法读取 " .. path
	end
	local h = hash_string(data)
	if h ~= e.sha256 then
		return false, "hash mismatch: " .. path
	end
	return true
end

return M
