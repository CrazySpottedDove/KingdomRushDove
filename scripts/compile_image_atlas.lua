-- 把图集 .lua 编译成紧凑二进制 .bin/.abin（由 lib/klove/atlas_binary.lua 定义格式）。
-- 运行：make compile_atlas  或  luajit scripts/compile_image_atlas.lua [dir] [single_file]
local input_dir = arg[1] or "_assets/kr1-desktop/images/fullhd"
local single_file = arg[2]

local AB = require("lib.klove.atlas_binary")

local function list_lua_files(dir)
	local files = {}
	if single_file then
		return {single_file}
	end
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

local function write_file(path, data)
	local f = assert(io.open(path, "wb"))
	f:write(data)
	f:close()
end

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

	write_file(input_dir .. "/" .. base .. ".bin", AB.pack(src_tbl, false))
	write_file(input_dir .. "/" .. base .. ".abin", AB.pack(src_tbl, true))
	ok_count = ok_count + 1
end

print(string.format("Compiled %d atlas lua files under %s", ok_count, input_dir))
