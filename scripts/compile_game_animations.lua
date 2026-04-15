local input_file = arg[1] or "kr1/data/game_animations.lua"
local output_luac_file = arg[2] or "kr1/data/game_animations_compiled.luac"

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

local function is_identifier(str)
	return type(str) == "string" and str:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function is_array(tbl)
	if type(tbl) ~= "table" then
		return false
	end

	local i = 0

	for _ in pairs(tbl) do
		i = i + 1

		if tbl[i] == nil then
			return false
		end
	end

	return true
end

local function serialize(tbl, indent)
	indent = indent or ""

	local lines = {}

	lines[#lines + 1] = "{"

	if is_array(tbl) then
		for i = 1, #tbl do
			local v = tbl[i]
			local val_str

			if type(v) == "table" then
				val_str = serialize(v, indent .. "    ")
			elseif type(v) == "string" then
				local s = v:gsub("\n", "\\n")
				val_str = string.format("%q", s)
				val_str = val_str:gsub("\\\\n", "\\n")
			else
				val_str = tostring(v)
			end

			lines[#lines + 1] = string.format("%s    %s,", indent, val_str)
		end
	else
		local keys = {}

		for k in pairs(tbl) do
			keys[#keys + 1] = k
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		for _, k in ipairs(keys) do
			local v = tbl[k]
			local key_str

			if is_identifier(k) then
				key_str = k
			elseif type(k) == "string" then
				key_str = string.format("[%q]", k)
			else
				key_str = string.format("[%s]", tostring(k))
			end

			local val_str

			if type(v) == "table" then
				val_str = serialize(v, indent .. "    ")
			elseif type(v) == "string" then
				local s = v:gsub("\n", "\\n")
				val_str = string.format("%q", s)
				val_str = val_str:gsub("\\\\n", "\\n")
			else
				val_str = tostring(v)
			end

			lines[#lines + 1] = string.format("%s    %s = %s,", indent, key_str, val_str)
		end
	end

	lines[#lines + 1] = indent .. "}"

	return table.concat(lines, "\n")
end

local frame_suffix_cache = {}

local function frame_suffix(frame)
	local suffix = frame_suffix_cache[frame]

	if not suffix then
		suffix = string.format("_%04i", frame)
		frame_suffix_cache[frame] = suffix
	end

	return suffix
end

local function extract_frame_from(a)
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
					frame_names[frame_count] = prefix .. frame_suffix(frame)
				end
			else
				for j = 1, #range do
					frame_count = frame_count + 1
					frame_names[frame_count] = prefix .. frame_suffix(range[j])
				end
			end
		end
	else
		if a.pre then
			for i = 1, #a.pre do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(a.pre[i])
			end
		end

		if a.from and a.to then
			local inc = a.from > a.to and -1 or 1

			for frame = a.from, a.to, inc do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(frame)
			end
		end

		if a.post then
			for i = 1, #a.post do
				frame_count = frame_count + 1
				frame_names[frame_count] = prefix .. frame_suffix(a.post[i])
			end
		end
	end

	return {frame_count, frame_names}
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

local source_lua = "return " .. serialize(compiled, "") .. "\n"
local compile_loader = loadstring or load
local chunk, chunk_err = compile_loader(source_lua, "@" .. output_luac_file)

if not chunk then
	error("Failed to compile generated lua chunk:\n" .. tostring(chunk_err))
end

local bytecode = string.dump(chunk)
local luac_file = assert(io.open(output_luac_file, "wb"))
luac_file:write(bytecode)
luac_file:close()

print(string.format("Compiled %d source animations into %d runtime animations.", source_count, compiled_count))
if duplicate_count > 0 then
	print(string.format("Skipped %d duplicate animation keys (kept first occurrence).", duplicate_count))
	table.sort(duplicate_keys)
	print("Duplicate animation keys:")
	for i = 1, #duplicate_keys do
		print(duplicate_keys[i])
	end
end
print("LUAC output: " .. output_luac_file)
