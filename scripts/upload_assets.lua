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
local COLOR = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
}
local assets_dir = read_assets_dir()
local new_index = dofile("_assets/assets_index.lua")

local is_windows = package.config:sub(1, 1) == '\\'
local null_dev = is_windows and "NUL" or "/dev/null"
local same_as_remote = false
local function table_to_string(t)
    local s = {}
    for k, v in pairs(t) do
        table.insert(s, tostring(k) .. "=" .. tostring(v.size))
    end
    table.sort(s)
    return table.concat(s, ";")
end

-- 获取远程旧索引
local git_show_cmd
if is_windows then
    git_show_cmd = 'git show origin/dev:_assets/assets_index.lua > _assets/assets_index.remote.lua || exit /b 0'
else
    git_show_cmd = 'git show origin/dev:_assets/assets_index.lua > _assets/assets_index.remote.lua || true'
end
os.execute(git_show_cmd)
local old_index = {}
local f = io.open("_assets/assets_index.remote.lua", "r")
if f then
    f:close()
    old_index = dofile("_assets/assets_index.remote.lua") or {}
end
if table_to_string(new_index) == table_to_string(old_index) then
    same_as_remote = true
end
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

local function get_release_assets(release)
    local cmd = string.format('gh release view "%s" --json assets --jq ".assets[].label"', release)
    local handle = io.popen(cmd)
    if not handle then
        return {}
    end
    local output = handle:read("*a")
    handle:close()
    local assets = {}
    if output and output ~= "" then
        created_releases[release] = true
        for line in output:gmatch("[^\r\n]+") do
            assets[line:gsub('^%s*(.-)%s*$', '%1')] = true
        end
    end

    return assets
end

local upload_batches = {} -- 按 release 分组
local release_assets_cache = {}
print("collecting upload tasks...")

if same_as_remote then
    for path, _ in pairs(new_index) do
        local filename = path:match("[^/]+$")
        local release = get_release_for_file(filename)
        -- 缓存每个 release 的 asset 列表
        if not release_assets_cache[release] then
            release_assets_cache[release] = get_release_assets(release)
        end
        local assets = release_assets_cache[release]
        if (not assets[filename]) then
            print(COLOR.blue.."[MISS] " .. filename)
            local fullpath = assets_dir .. "/" .. path
            local quoted_fullpath = '"' .. fullpath:gsub('"', '\\"') .. '"'
            local quoted_filename = '"' .. filename:gsub('"', '\\"') .. '"'
            upload_batches[release] = upload_batches[release] or {}
            table.insert(upload_batches[release], string.format('%s#%s', quoted_fullpath, quoted_filename))
        end
    end
else
    for path, info in pairs(new_index) do
        local oinfo = old_index[path]
        local filename = path:match("[^/]+$")
        local release = get_release_for_file(filename)
        if (not oinfo) or (oinfo.size ~= info.size) then
            if not oinfo then
                print(COLOR.blue.."[NEW] " .. filename)
            elseif oinfo.size ~= info.size then
                print(COLOR.blue..string.format("[MOD] %s (size %d -> %d)", filename, oinfo.size, info.size))
            end
            local fullpath = assets_dir .. "/" .. path
            local quoted_fullpath = '"' .. fullpath:gsub('"', '\\"') .. '"'
            local quoted_filename = '"' .. filename:gsub('"', '\\"') .. '"'
            upload_batches[release] = upload_batches[release] or {}
            table.insert(upload_batches[release], string.format('%s#%s', quoted_fullpath, quoted_filename))
        end
    end
end

-- 让用户确认是否上传。如果是，用户按回车，否则，可以按 q 退出
if next(upload_batches) == nil then
    print(COLOR.green.."没有需要上传的资源，退出。"..COLOR.reset)
    os.exit(0)
end
print(COLOR.yellow.."准备上传以下资源到 GitHub Release："..COLOR.reset)
for release, files in pairs(upload_batches) do
    print(COLOR.blue.."[tag]: ", release, "batch_size: ", #files)
    for _, file in ipairs(files) do
        print("  " .. file)
    end
end
print(COLOR.yellow.."按回车继续上传，或按 q 退出..."..COLOR.reset)
local answer = io.read()
if answer:lower() == "q" then
    print(COLOR.red.."上传已取消，退出。"..COLOR.reset)
    os.exit(0)
end
-- 也检测是否是回车，避免误触
if answer ~= "" then
    print(COLOR.red.."误触，退出。"..COLOR.reset)
    os.exit(0)
end

-- 执行上传
for release, files in pairs(upload_batches) do
    print(COLOR.blue.."[tag]: ", release, "batch_size: ", #files)
    ensure_release(release)
    local cmd = string.format('gh release upload %s %s --clobber', release, table.concat(files, " "))
    os.execute(cmd)
end

print(COLOR.green.."上传完成"..COLOR.reset)
