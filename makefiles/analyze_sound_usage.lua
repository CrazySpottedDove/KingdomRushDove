-- 分析哪些音频文件是多余的（未被使用的）
-- 对比 Lua 定义文件中引用的声音和实际存在的文件
-- 使用方法：
--   lua makefiles/analyze_sound_usage.lua           # 仅分析
--   lua makefiles/analyze_sound_usage.lua --delete  # 分析并删除未使用的文件

local lfs = require("lfs")

local SOUNDS_DIR = "_assets/kr1-desktop/sounds"
local FILES_DIR = SOUNDS_DIR .. "/files"
local OUTPUT_FILE = ".versions/.unused_sounds.txt"
local DELETED_LOG = ".versions/.deleted_sounds.txt"

-- 检查是否有 --delete 参数
local should_delete = false
for i = 1, #arg do
	if arg[i] == "--delete" or arg[i] == "-d" then
		should_delete = true
		break
	end
end

-- 收集所有声音定义文件中引用的文件名
local function collect_referenced_files()
	local referenced = {}

	-- 加载 sounds.lua
	local sounds_def_path = SOUNDS_DIR .. "/sounds.lua"
	local ok, sounds = pcall(dofile, sounds_def_path)
	if ok and sounds then
		for sound_name, sound_data in pairs(sounds) do
			if sound_data.files then
				for _, filename in ipairs(sound_data.files) do
					referenced[filename] = true
				end
			end
		end
	else
		print("Warning: Failed to load " .. sounds_def_path)
	end

	-- 加载 extra.lua（如果有额外的声音定义）
	-- extra.lua 有特殊结构：包含 groups 和 sounds 两个部分
	local extra_path = SOUNDS_DIR .. "/extra.lua"
	ok, sounds = pcall(dofile, extra_path)
	if ok and sounds then
		-- 处理 sounds 部分
		if sounds.sounds then
			for sound_name, sound_data in pairs(sounds.sounds) do
				if sound_data.files then
					for _, filename in ipairs(sound_data.files) do
						referenced[filename] = true
					end
				end
			end
		end
		-- 处理 groups 部分（可能包含 files 字段）
		if sounds.groups then
			for group_name, group_data in pairs(sounds.groups) do
				if group_data.files then
					for _, filename in ipairs(group_data.files) do
						referenced[filename] = true
					end
				end
			end
		end
	else
		print("Warning: Failed to load " .. extra_path)
	end

	-- 加载 groups.lua（如果有声音组定义）
	local groups_path = SOUNDS_DIR .. "/groups.lua"
	ok, groups = pcall(dofile, groups_path)
	if ok and groups then
		for group_name, group_data in pairs(groups) do
			if group_data.files then
				for _, filename in ipairs(group_data.files) do
					referenced[filename] = true
				end
			end
		end
	else
		print("Warning: Failed to load " .. groups_path)
	end

	return referenced
end

-- 收集实际存在的所有音频文件
local function collect_actual_files()
	local actual = {}

	for entry in lfs.dir(FILES_DIR) do
		if entry ~= "." and entry ~= ".." then
			local full_path = FILES_DIR .. "/" .. entry
			local attr = lfs.attributes(full_path)

			if attr and attr.mode == "file" then
				-- 检查是否是音频文件
				if entry:match("%.ogg$") or entry:match("%.mp3$") or entry:match("%.wav$") then
					actual[entry] = full_path
				end
			end
		end
	end

	return actual
end

-- 主逻辑
print("Scanning sound definitions...")
local referenced_files = collect_referenced_files()

print("Scanning actual sound files...")
local actual_files = collect_actual_files()

-- 统计被引用的文件数量
local referenced_count = 0
for _ in pairs(referenced_files) do
	referenced_count = referenced_count + 1
end

-- 统计实际文件数量
local actual_count = 0
for _ in pairs(actual_files) do
	actual_count = actual_count + 1
end

print("Referenced files: " .. referenced_count)
print("Actual files: " .. actual_count)

-- 查找未被引用的文件
local unused_files = {}
local unused_count = 0
local total_unused_size = 0

for filename, filepath in pairs(actual_files) do
	if not referenced_files[filename] then
		local attr = lfs.attributes(filepath)
		local size = attr and attr.size or 0
		table.insert(unused_files, {
			name = filename,
			size = size,
			path = filepath
		})
		unused_count = unused_count + 1
		total_unused_size = total_unused_size + size
	end
end

-- 排序便于查看（按文件名）
table.sort(unused_files, function(a, b)
	return a.name < b.name
end)

-- 格式化文件大小
local function format_size(bytes)
	if bytes < 1024 then
		return string.format("%d B", bytes)
	elseif bytes < 1024 * 1024 then
		return string.format("%.2f KB", bytes / 1024)
	else
		return string.format("%.2f MB", bytes / (1024 * 1024))
	end
end

-- 写入结果
os.execute("mkdir -p .versions")
local output = io.open(OUTPUT_FILE, "w")

output:write("# Unused Sound Files Analysis\n")
output:write("# Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
output:write("# Total sound files: " .. actual_count .. "\n")
output:write("# Referenced files: " .. referenced_count .. "\n")
output:write("# Unused files: " .. unused_count .. "\n")
output:write("# Unused percentage: " .. string.format("%.2f%%", (unused_count / actual_count * 100)) .. "\n")
output:write("# Total unused size: " .. format_size(total_unused_size) .. "\n")
output:write("\n")

if unused_count > 0 then
	output:write("# List of unused files (not referenced in any Lua definition):\n")
	output:write("# Format: filename (size)\n")
	output:write("\n")
	for _, file_info in ipairs(unused_files) do
		output:write(file_info.name .. " (" .. format_size(file_info.size) .. ")\n")
	end
else
	output:write("# All sound files are being used!\n")
end

output:close()

print("\nGenerated: " .. OUTPUT_FILE)
print("Unused files: " .. unused_count .. " (" .. string.format("%.2f%%", (unused_count / actual_count * 100)) .. ")")
print("Total unused size: " .. format_size(total_unused_size))

-- 可选：也检查被引用但不存在的文件（可能是错误引用）
local missing_files = {}
for filename in pairs(referenced_files) do
	if not actual_files[filename] then
		table.insert(missing_files, filename)
	end
end

if #missing_files > 0 then
	table.sort(missing_files)
	print("\nWarning: Found " .. #missing_files .. " referenced files that don't exist:")
	for _, filename in ipairs(missing_files) do
		print("  - " .. filename)
	end

	-- 也写入输出文件
	output = io.open(OUTPUT_FILE, "a")
	output:write("\n")
	output:write("# Referenced but missing files (possible errors in Lua definitions):\n")
	for _, filename in ipairs(missing_files) do
		output:write("# MISSING: " .. filename .. "\n")
	end
	output:close()
end

-- 删除未使用的文件（如果指定了 --delete 参数）
if should_delete and unused_count > 0 then
	print("\n" .. string.rep("=", 60))
	print("DELETE MODE ENABLED")
	print(string.rep("=", 60))
	print("About to delete " .. unused_count .. " unused files (" .. format_size(total_unused_size) .. ")")
	print("Press Enter to continue, or Ctrl+C to cancel...")
	io.read()

	local deleted_count = 0
	local deleted_size = 0
	local failed_deletions = {}

	-- 创建删除日志
	local delete_log = io.open(DELETED_LOG, "w")
	delete_log:write("# Deleted Sound Files Log\n")
	delete_log:write("# Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
	delete_log:write("# Total files deleted: " .. unused_count .. "\n")
	delete_log:write("# Total size freed: " .. format_size(total_unused_size) .. "\n")
	delete_log:write("\n")

	print("\nDeleting files...")
	for _, file_info in ipairs(unused_files) do
		local success = os.remove(file_info.path)
		if success then
			deleted_count = deleted_count + 1
			deleted_size = deleted_size + file_info.size
			delete_log:write(file_info.name .. " (" .. format_size(file_info.size) .. ")\n")
			print("  ✓ Deleted: " .. file_info.name)
		else
			table.insert(failed_deletions, file_info.name)
			delete_log:write("# FAILED: " .. file_info.name .. "\n")
			print("  ✗ Failed: " .. file_info.name)
		end
	end

	delete_log:close()

	print("\n" .. string.rep("=", 60))
	print("DELETION COMPLETE")
	print(string.rep("=", 60))
	print("Successfully deleted: " .. deleted_count .. " / " .. unused_count .. " files")
	print("Space freed: " .. format_size(deleted_size))
	print("Deletion log saved to: " .. DELETED_LOG)

	if #failed_deletions > 0 then
		print("\nFailed to delete " .. #failed_deletions .. " files:")
		for _, filename in ipairs(failed_deletions) do
			print("  - " .. filename)
		end
	end
elseif should_delete and unused_count == 0 then
	print("\nNo unused files to delete!")
else
	print("\nTo delete these unused files, run:")
	print("  lua makefiles/analyze_sound_usage.lua --delete")
end
