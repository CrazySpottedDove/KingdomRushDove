local G = love.graphics
local FS = love.filesystem
local util = {}

local is_ident
do
	local id_chars = {}
	for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
		id_chars[c] = true
	end
	function is_ident(s)
		if type(s) ~= "string" or s == "" then
			return false
		end
		if not (s:match("^[a-zA-Z_]")) then
			return false
		end
		for i = 1, #s do
			if not id_chars[s:sub(i, i)] then
				return false
			end
		end
		return true
	end
end

local function sorted_keys(t)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end
	table.sort(keys, function(a, b)
		if type(a) ~= type(b) then
			return type(a) < type(b)
		end
		return a < b
	end)
	return keys
end

local function serialize_val(buf, v)
	local tv = type(v)
	if tv == "table" then
		buf[#buf + 1] = "{"
		local n = #v
		local first = true
		for i = 1, n do
			if not first then
				buf[#buf + 1] = ","
			end
			first = false
			serialize_val(buf, v[i])
		end
		local keys = sorted_keys(v)
		for _, kk in ipairs(keys) do
			if type(kk) ~= "number" or kk < 1 or kk > n or kk % 1 ~= 0 then
				if not first then
					buf[#buf + 1] = ","
				end
				first = false
				if is_ident(kk) then
					buf[#buf + 1] = kk
					buf[#buf + 1] = "="
				else
					buf[#buf + 1] = "["
					buf[#buf + 1] = string.format("%q", kk)
					buf[#buf + 1] = "]="
				end
				serialize_val(buf, v[kk])
			end
		end
		buf[#buf + 1] = "}"
	elseif tv == "string" then
		buf[#buf + 1] = string.format("%q", v)
	else
		buf[#buf + 1] = tostring(v)
	end
end

local function serialize(tbl)
	local out = {}
	serialize_val(out, tbl)
	return table.concat(out)
end

function util.serialize_atlas_table(frames)
	local parts = {}
	local keys = sorted_keys(frames)
	local first = true
	for _, k in ipairs(keys) do
		local v = frames[k]
		if not first then
			parts[#parts + 1] = ","
		end
		first = false
		if is_ident(k) then
			parts[#parts + 1] = k
			parts[#parts + 1] = "="
		else
			parts[#parts + 1] = "["
			parts[#parts + 1] = string.format("%q", k)
			parts[#parts + 1] = "]="
		end
		parts[#parts + 1] = serialize({
			a_name = v.a_name,
			size = v.size,
			trim = v.trim,
			a_size = v.a_size,
			f_quad = v.f_quad,
			alias = (type(v.alias) == "table" and #v.alias > 0) and v.alias or nil,
			ref_scale = (v.ref_scale and v.ref_scale ~= 1) and v.ref_scale or nil
		})
	end
	local src = "return {" .. table.concat(parts) .. "}"
	return src
end

local load_chunk = loadstring or load

function util.compile_bytecode(lua_source, chunk_name)
	chunk_name = chunk_name or "@atlas"
	local fn, err = load_chunk(lua_source, chunk_name)
	if not fn then
		return nil, err
	end
	local ok, bc = pcall(string.dump, fn)
	if not ok then
		return nil, bc
	end
	return bc, nil
end

function util.write_atlas_files(dir, base_name, frames, write_fn)
	write_fn = write_fn or function(path, data)
		return pcall(FS.write, path, data)
	end
	local lua_src = util.serialize_atlas_table(frames)
	local lua_path = dir .. "/" .. base_name .. ".lua"
	if not write_fn(lua_path, lua_src) then
		return nil, "Failed to write " .. lua_path
	end

	local bc, err = util.compile_bytecode("return " .. serialize(compile_table(frames, false)), "@" .. base_name .. ".luac")
	if not bc then
		return nil, "Compile .luac failed: " .. err
	end
	write_fn(dir .. "/" .. base_name .. ".luac", bc)

	local bc_android, err2 = util.compile_bytecode("return " .. serialize(compile_table(frames, true)), "@" .. base_name .. ".aluac")
	if not bc_android then
		return nil, "Compile .aluac failed: " .. err2
	end
	write_fn(dir .. "/" .. base_name .. ".aluac", bc_android)

	return true, nil
end

function compile_table(tbl, force_astc)
	local out = {
		keys = {},
		values = {}
	}
	local idx = 1
	for k, v in pairs(tbl) do
		out.keys[idx] = k
		local a_name = force_astc and v.a_name:gsub("%.[^%.]+$", ".astc") or v.a_name
		local alias = (type(v.alias) == "table" and #v.alias > 0) and v.alias or nil
		out.values[idx] = {a_name, {v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2]}, {v.trim[1], v.trim[2]}, v.ref_scale or 1, {v.size[1], v.size[2]}, alias}
		idx = idx + 1
	end
	out.count = idx - 1
	return out
end

--- Load a source texture for preview.
--- If a PNG exists in png_dir but its size differs from expected, it is
--- re-generated from DDS (png_dir must be a real filesystem path).
--- Returns (image, nil, w, h, "png") on success, preferring lossless PNG.
function util.load_source_preview(dds_key, dds_dir, png_dir, expected_w, expected_h)
	local png_path = png_dir .. "/" .. dds_key .. ".png"

	-- try existing PNG; validate size
	local function try_png(path)
		local pf = io.open(path, "rb")
		if not pf then
			return nil
		end
		local blob = pf:read("*all")
		pf:close()
		local ok, idata = pcall(love.image.newImageData, love.data.newByteData(blob))
		if not ok then
			return nil
		end
		local w, h = idata:getDimensions()
		if w ~= expected_w or h ~= expected_h then
			return nil, idata, w, h
		end
		local img = G.newImage(idata)
		return img, nil, w, h, "png"
	end

	local png_img, _, png_w, png_h = try_png(png_path)
	if png_img then
		return png_img, nil, png_w, png_h, "png"
	end

	-- PNG missing or invalid → load DDS
	local dds_path = dds_dir .. "/" .. dds_key .. ".dds"
	local ok, imd = pcall(love.image.newCompressedData, dds_path)
	if not ok then
		return nil, tostring(imd)
	end
	local ok2, img = pcall(G.newImage, imd)
	if not ok2 then
		return nil, tostring(img)
	end
	local dw, dh = img:getDimensions()

	-- generate a correctly-sized PNG from DDS and save it
	if dw > 0 and dh > 0 then
		local canvas = G.newCanvas(dw, dh)
		G.setCanvas(canvas)
		G.setBlendMode("replace", "premultiplied")
		G.draw(img, 0, 0)
		G.setBlendMode("alpha", "alphamultiply")
		G.setCanvas()
		local idata = canvas:newImageData()
		canvas:release()
		-- BC3/DXT5 stores garbage RGB for fully transparent pixels; zero them out
		idata:mapPixel(function(x, y, r, g, b, a)
			if a == 0 then
				return 0, 0, 0, 0
			end
			return r, g, b, a
		end)
		local png_bytes = idata:encode("png")
		-- try to write via io.open
		local f = io.open(png_path, "wb")
		if f then
			local data_str = png_bytes.getString and png_bytes:getString() or tostring(png_bytes)
			f:write(data_str)
			f:close()
		end
		local new_img = G.newImage(idata)
		return new_img, nil, dw, dh, "png"
	end

	return img, nil, dw, dh, "dds"
end

--- Extract frame pixels from an atlas texture.
--- After data normalization, f_quad is in actual texture pixel space.
--- Must use the same blend mode as image_db for correct DDS/BC3 rendering.
function util.extract_frame_pixels(atlas_img, f_quad, tex_w, tex_h)
	local qw, qh = f_quad[3], f_quad[4]
	local prev_min, prev_mag = atlas_img:getFilter()
	atlas_img:setFilter("nearest", "nearest")
	local canvas = G.newCanvas(qw, qh)
	G.setCanvas(canvas)
	local quad = G.newQuad(f_quad[1], f_quad[2], qw, qh, tex_w, tex_h)
	G.setBlendMode("replace", "premultiplied")
	G.draw(atlas_img, quad, 0, 0)
	G.setBlendMode("alpha", "alphamultiply")
	G.setCanvas()
	local idata = canvas:newImageData()
	canvas:release()
	atlas_img:setFilter(prev_min, prev_mag)
	return idata
end

function util.create_merged_atlas(placements, src_frames, output_w, output_h)
	local merged = love.image.newImageData(output_w, output_h)
	merged:mapPixel(function()
		return 0, 0, 0, 0
	end)

	for _, p in ipairs(placements) do
		local frame_data = src_frames[p.frame_name]
		if frame_data and frame_data._preview_idata then
			local idata = frame_data._preview_idata
			merged:paste(idata, p.x, p.y, 0, 0, idata:getWidth(), idata:getHeight())
		end
	end

	return merged
end

function util.save_png(image_data, path)
	local png_data = image_data:encode("png")
	return pcall(FS.write, path, png_data)
end

function util.backup_files(dir, base_name, backup_dir, read_fn, write_fn)
	read_fn = read_fn or function(path)
		return FS.read(path)
	end
	write_fn = write_fn or function(path, data)
		return pcall(FS.write, path, data)
	end
	local ts = tostring(os.time())
	local target = backup_dir .. "/" .. ts .. "_" .. base_name
	-- try real filesystem first, fallback to FS
	local ok = pcall(FS.createDirectory, target)
	if not ok then
		os.execute("mkdir -p " .. target:gsub(" ", "\\ "))
	end

	local suffixes = {".lua", ".luac", ".aluac"}
	for _, ext in ipairs(suffixes) do
		local src = dir .. "/" .. base_name .. ext
		local data = read_fn(src)
		if data then
			write_fn(target .. "/" .. base_name .. ext, data)
		end
	end

	local ok, files = pcall(FS.getDirectoryItems, dir)
	if not ok or type(files) ~= "table" then
		-- try real filesystem via io.popen
		local f = io.popen("ls " .. dir:gsub(" ", "\\ ") .. " 2>/dev/null", "r")
		if f then
			files = {}
			for n in f:lines() do
				files[#files + 1] = n
			end
			f:close()
		end
	end
	if type(files) == "table" then
		for _, fname in ipairs(files) do
			if fname == (base_name .. ".dds") or fname:match("^" .. base_name .. "%-%d+%.dds$") then
				local content = read_fn(dir .. "/" .. fname)
				if content then
					write_fn(target .. "/" .. fname, content)
				end
			end
		end
	end

	return target
end

function util.generate_nvcompress_commands(png_dir, dds_dir, base_name, num_pages)
	local commands = {}
	if not FS.getInfo(png_dir) then
		FS.createDirectory(png_dir)
	end
	for i = 1, num_pages do
		local png_path = png_dir .. "/" .. base_name .. "-" .. i .. ".png"
		local dds_path = dds_dir .. "/" .. base_name .. "-" .. i .. ".dds"
		commands[#commands + 1] = string.format("nvcompress.exe -bc3 -maximum %q %q", png_path, dds_path)
	end
	return commands
end

function util.load_atlas_lua(path)
	local fn, err = FS.load(path)
	if not fn then
		return nil, err
	end
	local ok, tbl = pcall(fn)
	if not ok then
		return nil, tostring(tbl)
	end
	return tbl, nil
end

function util.scan_atlas_files(dir)
	local files = FS.getDirectoryItems(dir) or {}
	local result = {}
	for _, name in ipairs(files) do
		if name:sub(-4) == ".lua" and not name:match("^%.") then
			local base = name:sub(1, -5)
			result[#result + 1] = {
				name = name,
				base = base,
				path = dir .. "/" .. name
			}
		end
	end
	table.sort(result, function(a, b)
		return a.base < b.base
	end)
	return result
end

function util.get_dds_dimensions(dds_path)
	-- only read header (128 bytes is far past the width/height fields at bytes 12-20)
	local data = FS.read(dds_path, 128)
	if not data or #data < 20 then
		return nil
	end
	local w = string.byte(data, 17) + string.byte(data, 18) * 256 + string.byte(data, 19) * 65536 + string.byte(data, 20) * 16777216
	local h = string.byte(data, 13) + string.byte(data, 14) * 256 + string.byte(data, 15) * 65536 + string.byte(data, 16) * 16777216
	if w > 0 and h > 0 then
		return w, h
	end
	return nil
end

return util
