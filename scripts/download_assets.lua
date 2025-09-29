-- download_assets.lua
-- 按索引下载缺失/过期的资源（按文件名首字母+尾字母分桶）
local function read_assets_dir()
    local f = io.open("makefiles/.assets_path.txt", "r")
    if not f then
        os.exit(1)
    end
    local dir = f:read("*l")
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

-- 分桶函数
local function get_release_for_file(filename)
    local name = filename:gsub("%.%w+$", "")
    local first = name:sub(1, 1):lower()
    local last = name:sub(-1):lower()
    if not first:match("[%w]") then
        first = "other"
    end
    if not last:match("[%w]") then
        last = "other"
    end
    return string.format("assets-latest-%s-%s", first, last)
end

local function move_file(src, dst)
    local infile = io.open(src, "rb")
    if not infile then
        io.stderr:write("下载失败，未找到文件: " .. src .. "\n")
        return false
    end
    local data = infile:read("*a")
    infile:close()

    local outfile = io.open(dst, "wb")
    if not outfile then
        io.stderr:write("无法写入目标文件: " .. dst .. "\n")
        return false
    end
    outfile:write(data)
    outfile:close()
    print(dst)
    os.remove(src)
    return true
end

for path, info in pairs(index) do
    local fullpath = assets_dir .. "/" .. path
    local filename = path:match("[^/]+$")
    local need = file_size(fullpath) ~= info.size

    if need then
        local subdir = fullpath:match("^(.*)/[^/]+$")
        if subdir then
            os.execute(string.format(mkdir_cmd_tpl, subdir))
        end

        local tmpdir = "_assets/tmp_download"
        os.execute(string.format(mkdir_cmd_tpl, tmpdir))

        local release = get_release_for_file(filename)
        local quoted_pattern = '"' .. filename:gsub('"', '\\"') .. '"'
        local cmd = string.format('gh release download %s --pattern %s --dir "%s" --clobber', release, quoted_pattern,
            tmpdir)
        os.execute(cmd)

        local tmpfile = tmpdir .. "/" .. filename
        if not move_file(tmpfile, fullpath) then
            io.stderr:write("移动文件失败: " .. filename .. "\n")
        end
    end
end

print("下载完成")
