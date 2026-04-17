-- return {
-- 	atlas_name,
-- 	{v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2]},
-- 	{v.trim[1], v.trim[2]},
-- 	v.ref_scale or 1,
-- 	{v.size[1], v.size[2]},
-- 	alias
-- }
local input_dir = arg[1] or "_assets/kr1-desktop/images/fullhd"

local function list_lua_files(dir)
	local files = {}
	local ok_lfs, lfs = pcall(require, "lfs")

	if ok_lfs and lfs then
		for name in lfs.dir(dir) do
			if name ~= "." and name ~= ".." and name:sub(-4) == ".lua" then
				files[#files + 1] = name
			end
		end
	else
		local p = io.popen(string.format("find %q -maxdepth 1 -type f -name '*.lua'", dir), "r")
		if not p then
			error("Failed to list lua files under: " .. dir)
		end
		for path in p:lines() do
			files[#files + 1] = path:match("([^/]+)$")
		end
		p:close()
	end
	return files
end

local function append_serialized(buf, v)
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
			append_serialized(buf, v[i])
		end

		for k, vv in pairs(v) do
			if type(k) ~= "number" or k < 1 or k > n or k % 1 ~= 0 then
				if not first then
					buf[#buf + 1] = ","
				end
				first = false
				buf[#buf + 1] = "["
				buf[#buf + 1] = string.format("%q", k)
				buf[#buf + 1] = "]="
				append_serialized(buf, vv)
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
	append_serialized(out, tbl)
	return table.concat(out)
end

local function to_astc_name(name)
	return (name:gsub("%.[^%.]+$", ".astc"))
end

local function minimize_frame(v, force_astc)
	local atlas_name = force_astc and to_astc_name(v.a_name) or v.a_name
	local alias = v.alias

	if type(alias) ~= "table" or #alias == 0 then
		alias = nil
	end

	return {atlas_name, {v.f_quad[1], v.f_quad[2], v.f_quad[3], v.f_quad[4], v.a_size[1], v.a_size[2]}, {v.trim[1], v.trim[2]}, v.ref_scale or 1, {v.size[1], v.size[2]}, alias}
end

local function compile_table(tbl, force_astc)
	local out = {
		keys = {},
		values = {}
	}
	local index = 1
	for k, v in pairs(tbl) do
		out.keys[index] = k
		out.values[index] = minimize_frame(v, force_astc)
		index = index + 1
	end
	index = index - 1
	out.count = index
	return out
end

local load_chunk = loadstring or load
local files = list_lua_files(input_dir)
local ok_count = 0

for i = 1, #files do
	local name = files[i]
	local src_path = input_dir .. "/" .. name
	local base = name:sub(1, -5)

	local chunk, err = loadfile(src_path)
	if not chunk then
		error("Failed to load " .. src_path .. "\n" .. tostring(err))
	end

	local ok, src_tbl = pcall(chunk)
	if not ok then
		error("Failed to eval " .. src_path .. "\n" .. tostring(src_tbl))
	end
	if type(src_tbl) ~= "table" then
		error("Atlas file does not return table: " .. src_path)
	end

	local desktop_tbl = compile_table(src_tbl, false)
	local android_tbl = compile_table(src_tbl, true)

	local desktop_src = "return " .. serialize(desktop_tbl)
	local android_src = "return " .. serialize(android_tbl)

	local desktop_chunk, desktop_err = load_chunk(desktop_src, "@" .. input_dir .. "/" .. base .. ".luac")
	if not desktop_chunk then
		error("Failed to compile desktop chunk for " .. src_path .. "\n" .. tostring(desktop_err))
	end
	local android_chunk, android_err = load_chunk(android_src, "@" .. input_dir .. "/" .. base .. ".aluac")
	if not android_chunk then
		error("Failed to compile android chunk for " .. src_path .. "\n" .. tostring(android_err))
	end

	local desktop_out = assert(io.open(input_dir .. "/" .. base .. ".luac", "wb"))
	desktop_out:write(string.dump(desktop_chunk))
	desktop_out:close()

	local android_out = assert(io.open(input_dir .. "/" .. base .. ".aluac", "wb"))
	android_out:write(string.dump(android_chunk))
	android_out:close()

	ok_count = ok_count + 1
end

print(string.format("Compiled %d atlas lua files under %s", ok_count, input_dir))
