-- 用法（Windows 终端）：
--   luajit tools\exo_convert_v1_to_v3.lua path\to\foo.lua
--   或指定输出：luajit tools\exo_convert_v1_to_v3.lua path\to\foo.lua path\to\foo.v3.lua

local persistence = require("lib.klua.persistence")

local function die(msg, ...)
    io.stderr:write(string.format(msg.."\n", ...))
    os.exit(1)
end

local function load_v1(path)
    local f, err = loadfile(path)
    if not f then die("loadfile失败: %s (%s)", path, err or "?") end
    local ok, exo = pcall(f)
    if not ok then die("执行失败: %s (%s)", path, exo or "?") end
    return exo
end

local function is_v1(exo)
    return exo and exo.animations and exo.animations[1]
        and exo.animations[1].frames and exo.animations[1].frames[1]
        and exo.animations[1].frames[1].parts ~= nil
end

local function convert_to_v3(exo, name_hint)
    if not is_v1(exo) then
        die("输入不是v1格式（frames[].parts缺失）")
    end

    -- 收集 parts 为紧凑数组，并建立 name->index
    local parts_arr, parts_idx = {}, {}
    do
        -- v1通常为键值：parts[name] = {name, offsetX, offsetY} 或 {name=..., offsetX=..., offsetY=...}
        for k, p in pairs(exo.parts or {}) do
            if type(p) == "table" then
                local name = p.name or p[1]
                local ox = p.offsetX or p[2] or 0
                local oy = p.offsetY or p[3] or 0
                if name then
                    parts_arr[#parts_arr+1] = {name, ox, oy}
                    parts_idx[name] = #parts_arr
                end
            end
        end
        if #parts_arr == 0 then
            die("未在parts中找到任何部件")
        end
    end

    local ev3 = {
        name = exo.name,
        fps = exo.fps,
        partScaleCompensation = exo.partScaleCompensation,
        parts = parts_arr,
        attach_points = {},
        animations = {}
    }

    local attach_idx = {} -- name->index
    local function ensure_attach(name)
        local idx = attach_idx[name]
        if idx then return idx end
        ev3.attach_points[#ev3.attach_points+1] = {name}
        idx = #ev3.attach_points
        attach_idx[name] = idx
        return idx
    end

    for _, a in ipairs(exo.animations or {}) do
        local ta = { name = a.name or "", frames = {} }
        ev3.animations[#ev3.animations+1] = ta

        for _, af in ipairs(a.frames or {}) do
            local tf = {}

            -- parts -> {1, part_idx, alpha, x, y, sx, sy, r, kx, ky}
            for _, ap in ipairs(af.parts or {}) do
                local pname = ap.name
                local idx = parts_idx[pname]
                if not idx then
                    die("部件未定义: %s", tostring(pname))
                end
                local xf = ap.xform or {}
                tf[#tf+1] = {
                    1, idx, ap.alpha or 1,
                    xf.x or 0, xf.y or 0, xf.sx or 1, xf.sy or 1,
                    xf.r or 0, xf.kx or 0, xf.ky or 0
                }
            end

            -- attachPoints -> {8, attach_idx, alpha, x, y, sx, sy, r, kx, ky}
            for _, aa in ipairs(af.attachPoints or {}) do
                local idx = ensure_attach(aa.name)
                local xf = aa.xform or {}
                tf[#tf+1] = {
                    8, idx, aa.alpha or 1,
                    xf.x or 0, xf.y or 0, xf.sx or 1, xf.sy or 1,
                    xf.r or 0, xf.kx or 0, xf.ky or 0
                }
            end

            ta.frames[#ta.frames+1] = tf
        end
    end

    return ev3
end

local function default_out_path(inpath)
    -- 生成同目录的 .v3.lua
    local out = inpath:gsub("[/\\]?([^/\\]+)$", function(basename)
        local name = basename:gsub("%.%w+$", "")
        return name..".v3.lua"
    end)
    return out
end

local function main()
    local inpath = arg[1]
    local outpath = arg[2]
    if not inpath or inpath == "" then
        die("用法: luajit tools\\exo_convert_v1_to_v3.lua <input_v1.lua> [output_v3.lua]")
    end
    if not outpath or outpath == "" then
        outpath = default_out_path(inpath)
    end

    local exo_v1 = load_v1(inpath)
    local ev3 = convert_to_v3(exo_v1, inpath)

    -- 用 persistence 将 v3 写成紧凑 Lua 文件：return(obj1)
    -- 为减少体积，这里只写一个对象：ev3
    local content = persistence.serialize_to_string_compact(ev3)
    -- 文件首尾包装为可被 EXO:load_lua 的 FS.load() 执行的返回
    -- persistence.serialize_to_string 形如：
    --   local obj1 = {...}\nreturn obj1
    -- 直接写入即可
    local f, err = io.open(outpath, "wb")
    if not f then die("写文件失败: %s (%s)", outpath, err or "?") end
    f:write(content)
    f:close()

    print(string.format("Converted -> %s", outpath))
end

main()