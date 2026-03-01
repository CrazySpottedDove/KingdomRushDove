local file_utlis = {}
local P = require("lib.klua.persistence")
local log = require("lib.klua.log"):new("file_utlis")
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

return file_utlis
