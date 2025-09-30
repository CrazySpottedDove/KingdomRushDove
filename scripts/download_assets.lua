-- download_assets.lua
-- 按索引分批下载缺失/过期的资源（按文件名首字母+尾字母分桶）
local allowed_exts = {
    png = true,
    jpg = true,
    jpeg = true,
    bmp = true,
    tga = true,
    psd = true,
    fbx = true,
    obj = true,
    gif = true,
    webp = true,
    svg = true,
    mp3 = true,
    wav = true,
    dds = true,
    ogg = true,
    mp4 = true,
    otf = true,
    ttf = true,
    ttc = true,
}

local function get_ext(filename)
    return filename:match("^.+%.([a-zA-Z0-9]+)$")
end
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
    local len = #name
    if len == 0 then
        return "other"
    end
    local mid = math.floor((len + 1) / 2)
    local ch = name:sub(mid, mid):lower()
    if not ch:match("[%w]") then
        ch = "other"
    end
    return ch
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

print("正在检查本地多余或不匹配的资源...")
local parent_dir = assets_dir:match("^(.*)[/\\][^/\\]+$") or "."
local trashed_dir = parent_dir .. "/_trashed_assets"
-- 移动多余或不匹配的资源到 _trashed_assets
local function trash_unindexed_assets()
    local scan_cmd = is_windows and 'dir /b /s "' .. assets_dir .. '"' or 'find "' .. assets_dir .. '" -type f'

    local p = io.popen(scan_cmd)
    for fullpath in p:lines() do
        local ext = get_ext(fullpath)
        if ext and allowed_exts[ext:lower()] == nil then
            -- 非允许的扩展名，跳过
            goto continue
        end
        -- 转为相对路径
        local relpath = fullpath:sub(#assets_dir + 2)
        if is_windows then
            relpath = relpath:gsub("\\", "/")
        end
        local info = index[relpath]
        local local_file_size = file_size(fullpath)

        if (not info) or (info.size ~= local_file_size) then
            local trash_path = trashed_dir .. "/" .. relpath
            local trash_dir = trash_path:match("(.+)/[^/]+$")
            if trash_dir then
                if is_windows then
                    os.execute(string.format('mkdir "%s" 2>NUL', trash_dir))
                else
                    os.execute(string.format('mkdir -p "%s" 2>/dev/null', trash_dir))
                end
            end
            print("迁移文件: " .. fullpath .. " -> " .. trash_path)
            if not move_file(fullpath, trash_path) then
                io.stderr:write("移动文件失败: " .. fullpath .. "\n")
            end
        end
        ::continue::
    end
    p:close()
end

trash_unindexed_assets()
print("已迁移本地多余或不匹配的资源到" .. trashed_dir .. "目录")

-- 1. 收集需要下载的文件
print("正在检查需要下载的资源...")
local download_batches = {} -- release -> { {path=..., filename=..., fullpath=...}, ... }
for path, info in pairs(index) do
    local fullpath = assets_dir .. "/" .. path
    local filename = path:match("[^/]+$")
    local need = file_size(fullpath) ~= info.size

    if need then
        local subdir = fullpath:match("^(.*)/[^/]+$")
        if subdir then
            os.execute(string.format(mkdir_cmd_tpl, subdir))
        end
        local release = get_release_for_file(filename)
        download_batches[release] = download_batches[release] or {}
        table.insert(download_batches[release], {
            path = path,
            filename = filename,
            fullpath = fullpath
        })
    end
end
print("检查完毕，开始下载...")

-- 2. 执行分批下载
local tmpdir = "_assets/tmp_download"
os.execute(string.format(mkdir_cmd_tpl, tmpdir))

for release, files in pairs(download_batches) do
    print(string.format("正在下载资源包 '%s' (%d 个文件)...", release, #files))
    -- 构造 --pattern 参数
    local patterns = {}
    for _, f in ipairs(files) do
        local quoted = '"' .. f.filename:gsub('"', '\\"') .. '"'
        table.insert(patterns, quoted)
    end
    local cmd = string.format('gh release download %s %s --dir "%s" --clobber', release, table.concat(patterns, " "),
        tmpdir)
    os.execute(cmd)

    -- 逐个移动到目标目录
    for _, f in ipairs(files) do
        local tmpfile = tmpdir .. "/" .. f.filename
        if not move_file(tmpfile, f.fullpath) then
            io.stderr:write("移动文件失败: " .. f.filename .. "\n")
        end
    end
end

print("下载完成")
