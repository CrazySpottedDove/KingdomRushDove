-- upload_assets.lua
-- 上传新增/修改的资源到 GitHub Release
local function read_assets_dir()
    local f = io.open("makefiles/.assets_path.txt", "r")
    if not f then
        os.exit(1)
    end
    local dir = f:read("*l");
    f:close()
    return dir
end

local assets_dir = read_assets_dir()
local new_index = dofile("_assets/assets_index.lua")

-- 从远程 git 仓库获取最新版本的 assets_index.lua
os.execute("git show origin/master:_assets/assets_index.lua > _assets/assets_index.remote.lua 2>NUL || true")
local old_index = {}
local f = io.open("_assets/assets_index.remote.lua", "r")
if f then
    f:close();
    old_index = dofile("_assets/assets_index.remote.lua")
end

for path, info in pairs(new_index) do
    local oinfo = old_index[path]
    if not oinfo or oinfo.size ~= info.size or oinfo.mtime ~= info.mtime then
        local fullpath = assets_dir .. "/" .. path
        print("上传: " .. path)
        local cmd = string.format('gh release upload assets-latest "%s" --clobber', fullpath)
        os.execute(cmd)
    end
end

print("上传完成")
