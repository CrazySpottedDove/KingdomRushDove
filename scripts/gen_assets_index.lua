-- gen_assets_index.lua
-- 生成资源索引文件
local function read_assets_dir()
    local config_path = "makefiles/.assets_path.txt"
    local f = io.open(config_path, "r")
    if not f then
        io.stderr:write("未找到资源目录配置文件: " .. config_path .. "\n")
        os.exit(1)
    end
    local dir = f:read("*l")
    f:close()
    if not dir or dir == "" then
        io.stderr:write("资源目录配置文件内容为空: " .. config_path .. "\n")
        os.exit(1)
    end
    return dir
end

local assets_dir = read_assets_dir()

-- 检测系统
local function detect_os()
    local sep = package.config:sub(1, 1)
    if sep == '\\' then
        return "windows"
    else
        local uname = io.popen("uname -s 2>/dev/null"):read("*l") or ""
        if uname:lower():find("darwin") then
            return "macos"
        else
            return "linux"
        end
    end
end

local sys = detect_os()

-- 允许的扩展名
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

local function to_relpath(fullpath, basedir)
    -- 去掉末尾的斜杠或反斜杠
    basedir = basedir:gsub("[/\\]+$", "")
    local rel = fullpath:sub(#basedir + 2)
    if sys == "windows" then
        rel = rel:gsub("\\", "/")
    end
    print(rel)
    return rel
end

local function list_files(dir)
    local files = {}
    local cmd
    if sys == "windows" then
        cmd = 'dir /b /s "' .. dir .. '"'
    else
        cmd = 'find "' .. dir .. '" -type f'
    end
    local p = io.popen(cmd)
    for file in p:lines() do
        table.insert(files, file)
    end
    p:close()
    return files
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

-- local function file_mtime(path)
--     local cmd
--     if sys == "windows" then
--         cmd = 'for %I in ("' .. path .. '") do @echo %~tI'
--     elseif sys == "macos" then
--         cmd = 'stat -f %m "' .. path .. '"'
--     else
--         cmd = 'stat -c %Y "' .. path .. '"'
--     end
--     local p = io.popen(cmd)
--     local mtime = p:read("*l")
--     p:close()
--     return tonumber(mtime) or 0
-- end

local assets = {}
for _, path in ipairs(list_files(assets_dir)) do
    local ext = get_ext(path)
    if ext and allowed_exts[ext:lower()] then
        local relpath = to_relpath(path, assets_dir)
        assets[relpath] = {
            size = file_size(path),
        }
    end
end

-- 排序输出
local paths = {}
for path, _ in pairs(assets) do
    table.insert(paths, path)
end
table.sort(paths)
if sys == "windows" then
    os.execute('if not exist "_assets" mkdir "_assets"')
else
    os.execute("mkdir -p _assets")
end
local f = io.open("_assets/assets_index.lua", "w")
f:write("return {\n")
for _, path in ipairs(paths) do
    local info = assets[path]
    f:write(string.format("    [\"%s\"] = { size = %d},\n", path, info.size))
end
f:write("}\n")
f:close()
print("已生成 _assets/assets_index.lua")
