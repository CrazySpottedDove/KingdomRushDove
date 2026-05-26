local FS = love.filesystem
local bit = require("bit")
local bxor, band, rshift = bit.bxor, bit.band, bit.rshift

local zip = {}

local function le_u16(s, i)
	local b1, b2 = s:byte(i, i + 1)
	if not b1 or not b2 then
		return nil
	end
	return b1 + b2 * 256
end

local function le_u32(s, i)
	local b1, b2, b3, b4 = s:byte(i, i + 3)
	if not b1 or not b2 or not b3 or not b4 then
		return nil
	end
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function encode_u16(n)
	n = n % 65536
	return string.char(band(n, 0xFF), band(rshift(n, 8), 0xFF))
end

local function encode_u32(n)
	n = n % 4294967296
	return string.char(band(n, 0xFF), band(rshift(n, 8), 0xFF), band(rshift(n, 16), 0xFF), band(rshift(n, 24), 0xFF))
end

local function sanitize_zip_path(path)
	if not path or path == "" then
		return nil
	end
	path = path:gsub("\\", "/")
	path = path:gsub("^/+", "")
	if path:find("^%.%./") or path:find("/%.%./") or path:find("%.%.%z") then
		return nil
	end
	if path:find("^%a:[/\\]") then
		return nil
	end
	return path
end

local function find_eocd(zip_data)
	local sig = string.char(0x50, 0x4b, 0x05, 0x06)
	local start = math.max(1, #zip_data - 65557)
	for i = #zip_data - 3, start, -1 do
		if zip_data:sub(i, i + 3) == sig then
			return i
		end
	end
	return nil
end

local crc32_table
local function ensure_crc32_table()
	if crc32_table then
		return
	end
	crc32_table = {}
	for i = 0, 255 do
		local crc = i
		for _ = 1, 8 do
			if band(crc, 1) == 1 then
				crc = bxor(0xEDB88320, rshift(crc, 1))
			else
				crc = rshift(crc, 1)
			end
		end
		crc32_table[i + 1] = crc
	end
end

local function crc32(data)
	ensure_crc32_table()
	local crc = 0xFFFFFFFF
	for i = 1, #data do
		local byte = data:byte(i)
		crc = bxor(rshift(crc, 8), crc32_table[band(bxor(crc, byte), 0xFF) + 1])
	end
	return bxor(crc, 0xFFFFFFFF)
end

function zip.unzip_to_dir(zip_data, output_dir)
	local eocd_pos = find_eocd(zip_data)
	if not eocd_pos then
		return false, "zip 缺少 EOCD 结构"
	end
	local cd_count = le_u16(zip_data, eocd_pos + 10)
	local cd_offset = le_u32(zip_data, eocd_pos + 16)
	if not cd_count or not cd_offset then
		return false, "zip EOCD 字段非法"
	end

	local pos = cd_offset + 1
	for _ = 1, cd_count do
		if zip_data:sub(pos, pos + 3) ~= string.char(0x50, 0x4b, 0x01, 0x02) then
			return false, "zip 中央目录头非法"
		end
		local method = le_u16(zip_data, pos + 10)
		local comp_size = le_u32(zip_data, pos + 20)
		local uncomp_size = le_u32(zip_data, pos + 24)
		local name_len = le_u16(zip_data, pos + 28)
		local extra_len = le_u16(zip_data, pos + 30)
		local comment_len = le_u16(zip_data, pos + 32)
		local local_offset = le_u32(zip_data, pos + 42)
		if not method or not comp_size or not uncomp_size or not name_len or not extra_len or not comment_len or not local_offset then
			return false, "zip 中央目录字段非法"
		end
		local name_start = pos + 46
		local name = zip_data:sub(name_start, name_start + name_len - 1)
		local safe_name = sanitize_zip_path(name)
		pos = name_start + name_len + extra_len + comment_len

		if safe_name and not safe_name:match("/$") then
			local local_pos = local_offset + 1
			if zip_data:sub(local_pos, local_pos + 3) ~= string.char(0x50, 0x4b, 0x03, 0x04) then
				return false, "zip 本地头非法"
			end
			local local_name_len = le_u16(zip_data, local_pos + 26)
			local local_extra_len = le_u16(zip_data, local_pos + 28)
			if not local_name_len or not local_extra_len then
				return false, "zip 本地头字段非法"
			end
			local data_start = local_pos + 30 + local_name_len + local_extra_len
			local comp_data = zip_data:sub(data_start, data_start + comp_size - 1)
			local out_data
			if method == 0 then
				out_data = comp_data
			elseif method == 8 then
				local ok, decompressed = pcall(love.data.decompress, "string", "deflate", comp_data)
				if not ok then
					return false, "zip 解压失败: " .. tostring(decompressed)
				end
				out_data = decompressed
			else
				return false, "zip 不支持的压缩方式: " .. tostring(method)
			end
			if uncomp_size and #out_data ~= uncomp_size then
				return false, "zip 文件大小校验失败: " .. safe_name
			end

			local out_path = output_dir .. "/" .. safe_name
			local parts = {}
			for seg in out_path:gmatch("[^/]+") do
				parts[#parts + 1] = seg
			end
			if #parts > 1 then
				local current = parts[1]
				for i = 2, #parts - 1 do
					current = current .. "/" .. parts[i]
					if not FS.getInfo(current, "directory") then
						FS.createDirectory(current)
					end
				end
			end
			local ok = FS.write(out_path, out_data)
			if not ok then
				return false, "写入失败: " .. out_path
			end
		end
	end

	return true, nil
end

function zip.create_from_dir(source_dir, opts)
	opts = opts or {}
	local exclude = opts.exclude or {}
	local skip_dirs = opts.skip_dirs or {}

	local files = {}
	local function collect(dir, prefix)
		prefix = prefix or ""
		local items = FS.getDirectoryItems(dir) or {}
		for _, name in ipairs(items) do
			local full_path = dir .. "/" .. name
			local info = FS.getInfo(full_path)
			if info then
				if info.type == "directory" then
					local skip = false
					for _, d in ipairs(skip_dirs) do
						if name == d then
							skip = true
							break
						end
					end
					if not skip then
						collect(full_path, prefix .. name .. "/")
					end
				elseif info.type == "file" then
					local excluded = false
					for _, pat in ipairs(exclude) do
						if name:match(pat) then
							excluded = true
							break
						end
					end
					if not excluded then
						local data = FS.read(full_path)
						if data then
							files[#files + 1] = {
								name = prefix .. name,
								data = data,
								crc = crc32(data)
							}
						end
					end
				end
			end
		end
	end
	collect(source_dir, "")

	if #files == 0 then
		return nil, "没有找到可打包的文件"
	end

	local local_headers = {}
	local central_entries = {}
	local offset = 0

	for _, f in ipairs(files) do
		local name_bytes = f.name
		local name_len = #name_bytes
		local data = f.data
		local crc = f.crc
		local uncomp_size = #data

		local ok, comp_data = pcall(love.data.compress, "string", "deflate", data)
		if not ok then
			return nil, "文件压缩失败: " .. f.name
		end
		local comp_size = #comp_data

		local lh = string.char(0x50, 0x4b, 0x03, 0x04)
		lh = lh .. string.char(20, 0)
		lh = lh .. string.char(0, 0)
		lh = lh .. string.char(8, 0)
		lh = lh .. string.char(0, 0)
		lh = lh .. string.char(0, 0)
		lh = lh .. encode_u32(crc)
		lh = lh .. encode_u32(comp_size)
		lh = lh .. encode_u32(uncomp_size)
		lh = lh .. encode_u16(name_len)
		lh = lh .. encode_u16(0)
		lh = lh .. name_bytes
		local_headers[#local_headers + 1] = lh
		local_headers[#local_headers + 1] = comp_data

		local ce = string.char(0x50, 0x4b, 0x01, 0x02)
		ce = ce .. string.char(20, 0)
		ce = ce .. string.char(20, 0)
		ce = ce .. string.char(0, 0)
		ce = ce .. string.char(8, 0)
		ce = ce .. string.char(0, 0)
		ce = ce .. string.char(0, 0)
		ce = ce .. encode_u32(crc)
		ce = ce .. encode_u32(comp_size)
		ce = ce .. encode_u32(uncomp_size)
		ce = ce .. encode_u16(name_len)
		ce = ce .. encode_u16(0)
		ce = ce .. encode_u16(0)
		ce = ce .. encode_u16(0)
		ce = ce .. encode_u16(0)
		ce = ce .. encode_u32(0)
		ce = ce .. encode_u32(offset)
		ce = ce .. name_bytes
		central_entries[#central_entries + 1] = ce

		offset = offset + #lh + comp_size
	end

	local zip_data = table.concat(local_headers)

	local cd = table.concat(central_entries)
	local cd_offset = #zip_data
	local cd_size = #cd
	zip_data = zip_data .. cd

	local num_files = #files
	local eocd = string.char(0x50, 0x4b, 0x05, 0x06)
	eocd = eocd .. encode_u16(0)
	eocd = eocd .. encode_u16(0)
	eocd = eocd .. encode_u16(num_files)
	eocd = eocd .. encode_u16(num_files)
	eocd = eocd .. encode_u32(cd_size)
	eocd = eocd .. encode_u32(cd_offset)
	eocd = eocd .. encode_u16(0)
	zip_data = zip_data .. eocd

	return zip_data
end

return zip
