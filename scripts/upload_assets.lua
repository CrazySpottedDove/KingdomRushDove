-- upload_assets.lua
-- 上传新增/修改的资源到 GitHub Release（按文件名首字母+尾字母分桶）
local function read_assets_dir()
    local f = io.open("makefiles/.assets_path.txt", "r")
    if not f then
        os.exit(1)
    end
    local dir = f:read("*l")
    f:close()
    return dir
end

local assets_dir = read_assets_dir()
local new_index = dofile("_assets/assets_index.lua")

local is_windows = package.config:sub(1, 1) == '\\'
local null_dev = is_windows and "NUL" or "/dev/null"

-- 获取远程旧索引
os.execute(string.format(
    "git show origin/master:_assets/assets_index.lua > _assets/assets_index.remote.lua 2>%s || true", null_dev))
local old_index = {}
local f = io.open("_assets/assets_index.remote.lua", "r")
if f then
    f:close()
    old_index = dofile("_assets/assets_index.remote.lua") or {}
end

-- 分桶函数：首字母+尾字母（去扩展名）
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

-- 确保 Release 存在（避免重复创建）
local created_releases = {}
local function ensure_release(name)
    if created_releases[name] then
        return
    end
    local cmd = is_windows and
                    string.format(
            'gh release view %s >NUL 2>&1 || gh release create %s --title "%s" --notes "Auto created" 2>NUL', name,
            name, name) or string.format(
        'gh release view %s >/dev/null 2>&1 || gh release create %s --title "%s" --notes "Auto created" 2>/dev/null',
        name, name, name)
    os.execute(cmd)
    created_releases[name] = true
end

local upload_batches = {} -- 按 release 分组

for path, info in pairs(new_index) do
    local oinfo = old_index[path]
    if not oinfo or oinfo.size ~= info.size or oinfo.mtime ~= info.mtime then
        local fullpath = assets_dir .. "/" .. path
        local filename = path:match("[^/]+$")
        local quoted_fullpath = '"' .. fullpath:gsub('"', '\\"') .. '"'
        local quoted_filename = '"' .. filename:gsub('"', '\\"') .. '"'
        local release = get_release_for_file(filename)

        upload_batches[release] = upload_batches[release] or {}
        table.insert(upload_batches[release], string.format('%s#%s', quoted_fullpath, quoted_filename))
    end
end

-- 执行上传
for release, files in pairs(upload_batches) do
    ensure_release(release)
    local cmd = string.format('gh release upload %s %s --clobber', release, table.concat(args, " "))
    os.execute(cmd)
end

print("上传完成")
