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
            os.execute(string.format('mkdir -p "%s"', subdir))
        end
        print("下载: " .. path)
        local cmd = string.format('gh release download assets-latest --pattern "%s" --dir "%s"', path,
            subdir or assets_dir)
        os.execute(cmd)
    end
end

print("下载完成")
