-- download_assets.lua
-- 按索引下载缺失/过期的资源
local function read_assets_dir()
    local f = io.open("makefiles/.assets_path.txt", "r")
    if not f then
        os.exit(1)
    end
    local dir = f:read("*l");
    f:close()
    return dir
end

local function file_size(path)
    local f = io.open(path, "rb")
    if not f then
        return 0
    end
    local size = f:seek("end")
    f:close()
    return size or 0
end

local assets_dir = read_assets_dir()
local index = dofile("_assets/assets_index.lua")

local is_windows = package.config:sub(1, 1) == '\\'
local mkdir_cmd_tpl = is_windows and 'mkdir "%s" 2>NUL || exit /b 0' or 'mkdir -p "%s" 2>/dev/null || true'

for path, info in pairs(index) do
    local fullpath = assets_dir .. "/" .. path
    local f = io.open(fullpath, "rb")
    local need = true
    if f then
        f:close()
        if file_size(fullpath) == info.size then
            need = false
        end
    end
    if need then
        local subdir = fullpath:match("^(.*)/[^/]+$")
        if subdir then
            os.execute(string.format(mkdir_cmd_tpl, subdir))
        end
        print("下载: " .. path)
        -- 用双引号包裹 path，防止 shell 误解析特殊字符
        local quoted_pattern = '"' .. path:gsub('"', '\\"') .. '"'
        local quoted_dir = '"' .. (subdir or assets_dir):gsub('"', '\\"') .. '"'
        local cmd = string.format('gh release download assets-latest --pattern %s --dir %s', quoted_pattern, quoted_dir)
        os.execute(cmd)
    end
end

print("下载完成")

