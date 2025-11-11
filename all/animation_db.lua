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
local function is_file(path)
    local info = love.filesystem.getInfo(path)
    return info and info.type == "file"
end

require("constants")

local animation_db = {}

animation_db.db = {}
animation_db.fps = FPS
animation_db.tick_length = TICK_LENGTH
animation_db.missing_animations = {}
local number_format_cache = {}
for i = 0, 9999 do
    number_format_cache[i] = string.format("%04i", i)
end

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
    end

    self.db = {}

    local f = string.format("%s/data/game_animations.lua", KR_PATH_GAME)

    load_ani_file(f)

    local path = string.format("%s/data/animations", KR_PATH_GAME)
    local files = FS.getDirectoryItems(path)

    for i = 1, #files do
        local name = files[i]
        local f = path .. "/" .. name

        if is_file(f) and string.match(f, ".lua$") then
            load_ani_file(f)
        end
    end

    local expanded_keys = {}
    local deleted_keys = {}
    local next_deleted_index = 1
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

                deleted_keys[next_deleted_index] = k
                next_deleted_index = next_deleted_index + 1
            end
        end
    end

    for i = 1, next_deleted_index - 1 do
        self.db[deleted_keys[i]] = nil
    end

    for k, v in pairs(expanded_keys) do
        self.db[k] = v
    end

    self:prebuild_frames()
end

-- added: 预构建所有动画的帧数组 frames
function animation_db:prebuild_frames()
    self.prefix_s = {}
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
                    local from = range[1]
                    local to = range[2]
                    local inc = to < from and -1 or 1
                    for i = from, to, inc do
                        frames[#frames + 1] = i
                    end
                else
                    local start_idx = #frames
                    for i = 1, #range do
                        frames[start_idx + i] = range[i]
                    end
                end
            end
        else
            if a.pre then
                local start_idx = #frames
                for i = 1, #a.pre do
                    frames[start_idx + i] = a.pre[i]
                end
            end
            if a.from and a.to then
                local inc = a.from > a.to and -1 or 1
                for i = a.from, a.to, inc do
                    frames[#frames + 1] = i
                end
            end
            if a.post then
                local start_idx = #frames
                for i = 1, #a.post do
                    frames[start_idx + i] = a.post[i]
                end
            end
        end
        a.frames = frames
    end
    if a.prefix and not a.frame_names then
        if not self.prefix_s[a.prefix] then
            self.prefix_s[a.prefix] = a.prefix .. "_"
        end

        local prefix_ = self.prefix_s[a.prefix]
        a.frame_names = {}
        for i=1, #frames do
            a.frame_names[i] = prefix_ .. (number_format_cache[frames[i]] or string.format("%04i", frames[i]))
        end
    end
end

function animation_db:fni(animation, time_offset, loop, fps)
    local a = animation

    fps = fps or self.fps

    local frames = a.frames
    local eps = 1e-09
    local len = #frames

    local time_in_frames_plus_eps = time_offset * fps + eps

    local next_elapsed = ceil(time_in_frames_plus_eps + self.tick_length * fps)
    local runs = max(0, floor((next_elapsed - 1) / len))

    if loop then
        local idx = floor(time_in_frames_plus_eps) % len + 1
        return a.frame_names[idx], runs, idx
    else
        local elapsed_frames = ceil(time_in_frames_plus_eps)
        local idx = max(1, min(len, elapsed_frames))
        return a.frame_names[idx], runs, idx
    end
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
