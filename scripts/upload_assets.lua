-- upload_assets.lua
-- 上传新增/修改的资源到 GitHub Release
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

-- 从远程 git 仓库获取最新版本的 assets_index.lua
os.execute(string.format(
    "git show origin/master:_assets/assets_index.lua > _assets/assets_index.remote.lua 2>%s || true", null_dev))
local old_index = {}
local f = io.open("_assets/assets_index.remote.lua", "r")
if f then
    f:close();
    old_index = dofile("_assets/assets_index.remote.lua") or {}
end

-- 确保 Release 存在
local create_release_cmd = is_windows and
                               'gh release create assets-latest --title "Assets Latest" --notes "Auto created" 2>NUL || exit /b 0' or
                               'gh release create assets-latest --title "Assets Latest" --notes "Auto created" 2>/dev/null || true'
os.execute(create_release_cmd)

for path, info in pairs(new_index) do
    local oinfo = old_index[path]
    if not oinfo or oinfo.size ~= info.size or oinfo.mtime ~= info.mtime then
        local fullpath = assets_dir .. "/" .. path
        local filename = path:match("[^/]+$") -- 只保留文件名
        print("上传: " .. path)

        local quoted_fullpath = '"' .. fullpath:gsub('"', '\\"') .. '"'
        local quoted_filename = '"' .. filename:gsub('"', '\\"') .. '"'

        -- 上传时 asset 名字只用 filename
        local cmd = string.format('gh release upload assets-latest %s#%s --clobber', quoted_fullpath, quoted_filename)
        os.execute(cmd)
    end
end

print("上传完成")
