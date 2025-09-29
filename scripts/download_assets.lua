-- download_assets.lua
-- 按索引下载缺失/过期的资源
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

    os.remove(src)
    return true
end



for path, info in pairs(index) do
    local fullpath = assets_dir .. "/" .. path
    local filename = path:match("[^/]+$") -- 提取文件名
    local need = true

    local f = io.open(fullpath, "rb")
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

        local tmpdir = "_assets/tmp_download"
        os.execute(string.format(mkdir_cmd_tpl, tmpdir))

        local quoted_pattern = '"' .. filename:gsub('"', '\\"') .. '"'
        local cmd = string.format('gh release download assets-latest --pattern %s --dir "%s" --clobber', quoted_pattern,
            tmpdir)
        os.execute(cmd)

        -- 移动到目标目录
        -- 移动到目标目录
        local tmpfile = tmpdir .. "/" .. filename
        if not move_file(tmpfile, fullpath) then
            io.stderr:write("移动文件失败: " .. filename .. "\n")
        end

    end
end

print("下载完成")
