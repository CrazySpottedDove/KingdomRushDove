-- 分析哪些图像需要缩放（对比 Lua 定义与实际大小，考虑 ref_scale）
-- 生成纯文本格式，不依赖外部库

local lfs = require("lfs")

local IMAGES_DIR = "_assets/kr1-desktop/images/fullhd"
local OUTPUT_FILE = ".versions/.resize_map.txt"

local resize_map = {}

-- 从 DDS 文件获取实际尺寸
local function get_dds_size(filename)
	local f = io.open(filename, "rb")
	if not f then
		return nil
	end

	f:seek("set", 12)
	local h_bytes = f:read(4)
	local w_bytes = f:read(4)
	f:close()

	if not h_bytes or not w_bytes or #h_bytes < 4 or #w_bytes < 4 then
		return nil
	end

	local height = string.byte(h_bytes, 1) + string.byte(h_bytes, 2) * 256 + string.byte(h_bytes, 3) * 65536 + string.byte(h_bytes, 4) * 16777216

	local width = string.byte(w_bytes, 1) + string.byte(w_bytes, 2) * 256 + string.byte(w_bytes, 3) * 65536 + string.byte(w_bytes, 4) * 16777216

	return width, height
end

-- 从 PNG 文件获取实际尺寸
local function get_png_size(filename)
	local f = io.open(filename, "rb")
	if not f then
		return nil
	end

	f:seek("set", 16)
	local w_bytes = f:read(4)
	local h_bytes = f:read(4)
	f:close()

	if not w_bytes or not h_bytes or #w_bytes < 4 or #h_bytes < 4 then
		return nil
	end

	local width = string.byte(w_bytes, 1) * 16777216 + string.byte(w_bytes, 2) * 65536 + string.byte(w_bytes, 3) * 256 + string.byte(w_bytes, 4)

	local height = string.byte(h_bytes, 1) * 16777216 + string.byte(h_bytes, 2) * 65536 + string.byte(h_bytes, 3) * 256 + string.byte(h_bytes, 4)

	return width, height
end

-- 从 Lua 文件提取 asset 大小定义（a_size）和 ref_scale
local function extract_sizes_from_lua(lua_file)
	local sizes = {}

	-- 直接加载 Lua 文件并提取 a_name, a_size, ref_scale
	local assets = dofile(lua_file)
	for key, asset in pairs(assets) do
		if asset.a_name and asset.a_size then
			local ref_scale = asset.ref_scale or 1
			sizes[asset.a_name] = {
				width = asset.a_size[1],
				height = asset.a_size[2],
				ref_scale = ref_scale
			}
		end
	end

	return sizes
end

-- 扫描所有 Lua 文件并构建大小映射
local lua_sizes = {}
for lua_file in lfs.dir(IMAGES_DIR) do
	if lua_file:match("%.lua$") then
		local full_path = IMAGES_DIR .. "/" .. lua_file
		local sizes = extract_sizes_from_lua(full_path)
		for asset_name, size_info in pairs(sizes) do
			lua_sizes[asset_name] = size_info
		end
	end
end

-- 对比 DDS/PNG 文件
for entry in lfs.dir(IMAGES_DIR) do
	local filename = entry
	local full_path = IMAGES_DIR .. "/" .. filename
	local attr = lfs.attributes(full_path)

	if attr and attr.mode == "file" then
		local actual_w, actual_h

		if filename:match("%.dds$") then
			actual_w, actual_h = get_dds_size(full_path)
		elseif filename:match("%.png$") then
			actual_w, actual_h = get_png_size(full_path)
		else
			goto continue
		end

		if actual_w and actual_h then
			local size_info = lua_sizes[filename]

			if size_info then
				-- 检查是否需要缩放
				-- 只要 a_size × ref_scale <= 实际尺寸 × 0.5（图像被放大过一半以上），就需要缩放
				local is_enlarged = (size_info.width * size_info.ref_scale <= actual_w * 0.5 and size_info.height * size_info.ref_scale <= actual_h * 0.5)

				resize_map[filename] = is_enlarged and 1 or 0
			else
				-- 没有 Lua 定义，标记为不缩放
				resize_map[filename] = 0
				print("Warning: No Lua definition for " .. filename .. ", defaulting to no resize.")
			end
		end
	end

	::continue::
end

-- 写入纯文本格式（每行一个文件：filename=should_resize）
os.execute("mkdir -p .versions")
local output = io.open(OUTPUT_FILE, "w")
for filename, should_resize in pairs(resize_map) do
	output:write(filename .. "=" .. should_resize .. "\n")
end
output:close()

print("Generated: " .. OUTPUT_FILE)

-- 计数映射中的文件
local total_files = 0
for _ in pairs(resize_map) do
	total_files = total_files + 1
end
print("Total files analyzed: " .. total_files)

local resize_count = 0
for _, v in pairs(resize_map) do
	if v == 1 then
		resize_count = resize_count + 1
	end
end
print("Files to resize: " .. resize_count)
