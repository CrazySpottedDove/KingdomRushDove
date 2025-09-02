-- chunkname: @./all/animation_db.lua
local log = require("klua.log"):new("animation_db")
local km = require("klua.macros")

require("klua.table")
require("klua.dump")

local G = love.graphics
local FS = love.filesystem
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min

require("constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}

function animation_db:load()
    local function load_ani_file(f)
        local ok, achunk = pcall(FS.load, f)

        if not ok then
            assert(false, string.format("Failed to load animation file %s.\n%s", f, achunk))
        end

        local ok, atable = pcall(achunk)

        if not ok then
            assert(false, string.format("Failed to eval animation chunk for file:%s", f, atable))
        end

        if not atable then
            assert(false, string.format("Failed to load animation file %s. Could not find .animations", f))
        end

        if atable.animations then
            atable = atable.animations
        end

        for k, v in pairs(atable) do
            if self.db[k] then
                log.error("Animation %s already exists. Not loading it from file %s", k, f)
                -- assert(false, string.format("Animation %s already exists. Not loading it from file %s", k, f))
            else
                self.db[k] = v
            end
        end

        log.info("Loaded animation file %s", f)
    end

    self.db = {}

    local f = string.format("%s/data/game_animations.lua", KR_PATH_GAME)

    load_ani_file(f)

    local path = string.format("%s/data/animations", KR_PATH_GAME)
    local files = FS.getDirectoryItems(path)

    for i = 1, #files do
        local name = files[i]
        local f = path .. "/" .. name

        if FS.isFile(f) and string.match(f, ".lua$") then
            load_ani_file(f)
        end
    end

    local expanded_keys = {}
    local deleted_keys = {}

    for k, v in pairs(self.db) do
        if v.layer_from and v.layer_to and v.layer_prefix then
            for i = v.layer_from, v.layer_to do
                local nk = string.gsub(k, "layerX", "layer" .. i)
                local nv = {
                    pre = v.pre,
                    post = v.post,
                    from = v.from,
                    to = v.to,
                    ranges = v.ranges,
                    frames = v.frames,
                    prefix = string.format(v.layer_prefix, i)
                }

                expanded_keys[nk] = nv

                table.insert(deleted_keys, k)
            end

            -- table.insert(expanded_keys, k)
        end
    end

    for k, v in pairs(expanded_keys) do
        self.db[k] = v
    end

    for _, k in pairs(deleted_keys) do
        self.db[k] = nil
    end

    self:prebuild_frames()
end

-- added: 预构建所有动画的帧数组 frames
function animation_db:prebuild_frames()
    for name, a in pairs(self.db) do
        self:generate_frames(a)
    end
end

function animation_db:has_animation(animation_name)
    return self.db[animation_name] ~= nil
end

-- 完成从动画名称到具体帧名（如soldier_0001）的转换
function animation_db:fn(animation_name, time_offset, loop, fps)
    local a = self.db[animation_name]

    if not a then
        if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
            return nil
        end

        log.error("animation %s not found", animation_name)

        self.missing_animations[animation_name or "nil"] = true

        return nil
    end
    -- if not a.frame_names then
    --     log.error("animation %s has no frame_names", animation_name)
    -- end
    return self:fni(a, time_offset, loop, fps)
end

-- 完成动画 frames 和 frame_names 的生成
function animation_db:generate_frames(a)
    local frames = a.frames
    if not frames then
        frames = {}
        if a.ranges then
            for _, range in pairs(a.ranges) do
                if #range == 2 then
                    local from, to = unpack(range)
                    local inc = to < from and -1 or 1
                    for i = from, to, inc do
                        table.insert(frames, i)
                    end
                else
                    table.append(frames, range)
                end
            end
        else
            if a.pre then
                table.append(frames, a.pre)
            end
            if a.from and a.to then
                local inc = a.from > a.to and -1 or 1
                for i = a.from, a.to, inc do
                    table.insert(frames, i)
                end
            end
            if a.post then
                table.append(frames, a.post)
            end
        end
        a.frames = frames
    end
    if a.prefix then
        a.frame_names = {}
        for i, frame in ipairs(frames) do
            a.frame_names[i] = string.format("%s_%04i", a.prefix, frame)
        end
    end

end

function animation_db:fni(animation, time_offset, loop, fps, tick_length)
    local a = animation

    fps = fps or self.fps
    tick_length = tick_length or self.tick_length

    local frames = a.frames
    local eps = 1e-09
    local len = #frames
    local time_in_frames_plus_eps = time_offset * fps + eps
    local elapsed_frames = ceil(time_in_frames_plus_eps)
    local next_elapsed = ceil(time_in_frames_plus_eps + tick_length * fps)
    local runs = max(0, floor((next_elapsed - 1) / len))
    local idx

    if loop then
        idx = floor(time_in_frames_plus_eps) % len + 1
    else
        idx = max(1, min(len, elapsed_frames))
    end

    return a.frame_names[idx], runs, idx
end

function animation_db:duration(animation_name)
    local a = self.db[animation_name]

    if not a then
        if not animation_name and self.missing_animations["nil"] or self.missing_animations[animation_name] then
            return nil
        end

        log.error("animation %s not found", animation_name)

        self.missing_animations[animation_name or "nil"] = true

        return nil
    end

    if not a.frames then
        self:fni(a, 0, false)
    end

    return #a.frames / self.fps, #a.frames
end

return animation_db
