local file_utlis = {}
local P = require("lib.klua.persistence")
local log = require("lib.klua.log"):new("file_utlis")
local is_windows = package.config:sub(1, 1) == "\\"
local FS = love.filesystem
--- 写入文件
---@param file_path string 文件路径
---@param content string 文件内容
---@return boolean success 是否成功
function file_utlis.write_file(file_path, content)
	local f, err = io.open(file_path, "wb")
	if not f then
		log.error("Failed to open file: %s, error: %s", file_path, err)
		return false
	end
	f:write(content)
	f:close()
	return true
end

function file_utlis.write_lua(file_path, data)
	local content = P.serialize_to_string(data)
	return file_utlis.write_file(file_path, content)
end

function file_utlis.ensure_parent_dir(file_path)
	local parent_dir = file_path:match("(.+)[/\\]")
	if parent_dir then
		if is_windows then
			return os.execute('mkdir "' .. parent_dir .. '" >nul 2>nul')
		else
			return os.execute('mkdir -p "' .. parent_dir .. '" >/dev/null 2>&1')
		end
	end
	return true -- 在根目录，无需创建
end

--- 获取目录下的子目录列表。
---@param path string 目录路径
---@return table 子目录列表，相对路径。
function file_utlis.get_subdirs(path)
	local files = FS.getDirectoryItems(path)

	if not files then
		log.error("Failed to get directory items for path: %s", path)
		return {}
	end

	local file_names = {}

	for i = 1, #files do
		local file_path = path .. "/" .. files[i]
		local info = FS.getInfo(file_path)

		if info and info.type == "directory" then
			file_names[#file_names + 1] = files[i]
		end
	end

	return file_names
end

return file_utlis
