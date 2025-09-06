-- chunkname: @./all/utils.lua
local log = require("klua.log"):new("utils")

require("klua.table")

local km = require("klua.macros")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local V = require("klua.vector")
local P = require("path_db")

require("constants")

local U = {}

--- 返回从 from 到 to 的随机数
--- @param from number 起始值
--- @param to number 结束值
--- @return number 随机数
function U.frandom(from, to)
    return math.random() * (to - from) + from
end

--- 随机返回 -1 或 1
--- @return number 随机符号（-1 或 1）
function U.random_sign()
    if math.random() < 0.5 then
        return -1
    else
        return 1
    end
end

--- 对于索引从 1 开始的连续的数组，返回一个随机索引
--- @param list table 概率数组（元素值表示权重）
--- @return number 随机索引
function U.random_table_idx(list)
    local rn = math.random()
    local acc = 0

    for i = 1, #list do
        if rn <= list[i] + acc then
            return i
        end

        acc = acc + list[i]
    end

    return #list
end

--- 协程：渐变多个键值
--- @param store table game.store
--- @param key_tables table 目标表数组
--- @param key_names table 键名数组
--- @param froms table 起始值数组
--- @param tos table 目标值数组
--- @param duration number 持续时间
--- @param easings table|nil 缓动函数数组（可选）
--- @param fn function|nil 每帧回调函数（可选）
function U.y_ease_keys(store, key_tables, key_names, froms, tos, duration, easings, fn)
    local start_ts = store.tick_ts
    local phase

    easings = easings or {}

    repeat
        local dt = store.tick_ts - start_ts

        phase = km.clamp(0, 1, dt / duration)

        for i, t in ipairs(key_tables) do
            local kn = key_names[i]

            t[kn] = U.ease_value(froms[i], tos[i], phase, easings[i])
        end

        if fn then
            fn(dt, phase)
        end

        coroutine.yield()
    until phase >= 1
end

--- 协程：渐变单个键值
--- @param store table game.store
--- @param key_table table 目标表
--- @param key_name string 键名
--- @param from number 起始值
--- @param to number 目标值
--- @param duration number 持续时间
--- @param easing string|nil 缓动函数（可选）
--- @param fn function|nil 每帧回调函数（可选）
function U.y_ease_key(store, key_table, key_name, from, to, duration, easing, fn)
    U.y_ease_keys(store, { key_table }, { key_name }, { from }, { to }, duration, { easing }, fn)
end

--- 计算缓动值
--- @param from number 起始值
--- @param to number 目标值
--- @param phase number 进度（0-1）
--- @param easing string|nil 缓动函数（可选）
--- @return number 缓动后的值
function U.ease_value(from, to, phase, easing)
    return from + (to - from) * U.ease_phase(phase, easing)
end

--- 根据距离终点位置排序敌人
--- @param enemies table 敌人数组
--- @return nil
--- @desc 优先处理嘲讽标志（F_MOCKING），飞行单位不受嘲讽影响
function U.sort_foremost_enemies(enemies)
    table.sort(enemies, function(e1, e2)
        local e1_mocking = band(e1.vis.flags, F_MOCKING) ~= 0
        local e2_mocking = band(e2.vis.flags, F_MOCKING) ~= 0
        local e1_flying = band(e1.vis.flags, F_FLYING) ~= 0
        local e2_flying = band(e2.vis.flags, F_FLYING) ~= 0
        -- 优先处理嘲讽标志，且嘲讽对空中单位无保护效果
        if e1_mocking and not (e2_mocking or e2_flying) then
            return true
        elseif not (e1_mocking or e1_flying) and e2_mocking then
            return false
        end

        local p1 = e1.nav_path
        local p2 = e2.nav_path

        return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
    end)
end

--- 根据距离终点位置排序敌人，优先处理飞行单位
--- @param enemies table 敌人数组
function U.sort_foremost_enemies_with_flying_preference(enemies)
    table.sort(enemies, function(e1, e2)
        local e1_mocking = band(e1.vis.flags, F_MOCKING) ~= 0
        local e2_mocking = band(e2.vis.flags, F_MOCKING) ~= 0
        local e1_flying = band(e1.vis.flags, F_FLYING) ~= 0
        local e2_flying = band(e2.vis.flags, F_FLYING) ~= 0
        if e1_flying and not e2_flying then
            return true
        elseif e2_flying and not e1_flying then
            return false
        elseif e1_mocking and not (e2_mocking or e2_flying) then
            return true
        elseif e2_mocking and not (e1_mocking or e1_flying) then
            return false
        end
        local p1 = e1.nav_path
        local p2 = e2.nav_path
        return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
    end)
end

--- 计算缓动进度
--- @param phase number 原始进度（0-1）
--- @param easing string|nil 缓动函数名（可选）
--- @return number 缓动后的进度
function U.ease_phase(phase, easing)
    phase = km.clamp(0, 1, phase)
    easing = easing or ""

    local function rotate_fn(f)
        return function(s, ...)
            return 1 - f(1 - s, ...)
        end
    end

    local easing_functions = {
        linear = function(s)
            return s
        end,
        quad = function(s)
            return s * s
        end,
        cubic = function(s)
            return s * s * s
        end,
        quart = function(s)
            return s * s * s * s
        end,
        quint = function(s)
            return s * s * s * s * s
        end,
        sine = function(s)
            return 1 - math.cos(s * math.pi * 0.5)
        end,
        expo = function(s)
            return 2 ^ (10 * (s - 1))
        end,
        circ = function(s)
            return 1 - math.sqrt(1 - s * s)
        end
    }
    local fn_name, first_ease = string.match(easing, "([^-]+)%-([^-]+)")
    local fn = easing_functions[fn_name]

    fn = fn or easing_functions.linear

    if first_ease == "outin" then
        if phase <= 0.5 then
            return fn(phase * 2) * 0.5
        else
            return 0.5 + rotate_fn(fn)((phase - 0.5) * 2) * 0.5
        end
    elseif first_ease == "inout" then
        if phase <= 0.5 then
            return rotate_fn(fn)(phase * 2) * 0.5
        else
            return 0.5 + fn((phase - 0.5) * 2) * 0.5
        end
    elseif first_ease == "in" then
        return rotate_fn(fn)(phase)
    else
        return fn(phase)
    end
end

--- 计算悬停脉冲透明度
--- @param t number 时间
--- @return number 透明度值
function U.hover_pulse_alpha(t)
    local min, max, per = HOVER_PULSE_ALPHA_MIN, HOVER_PULSE_ALPHA_MAX, HOVER_PULSE_PERIOD

    return min + (max - min) * 0.5 * (1 + math.sin(t * km.twopi / per))
end

--- 检测点是否在椭圆内
--- @param p table 点坐标 {x, y}
--- @param center table 椭圆中心 {x, y}
--- @param radius number 椭圆长轴半径
--- @param aspect number|nil 椭圆纵横比（可选，默认0.7）
--- @return boolean 是否在椭圆内
function U.is_inside_ellipse(p, center, radius, aspect)
    aspect = aspect or 0.7

    local a = radius
    local b = radius * aspect
    local x = (p.x - center.x) / a
    local y = (p.y - center.y) / b
    return x * x + y * y <= 1
end

--- 返回椭圆上指定角度的点
--- @param center table 椭圆中心 {x, y}
--- @param radius number 椭圆长轴半径
--- @param angle number|nil 角度（弧度，可选，默认0）
--- @param aspect number|nil 椭圆纵横比（可选，默认0.7）
--- @return table 椭圆上的点坐标 {x, y}
function U.point_on_ellipse(center, radius, angle, aspect)
    aspect = aspect or 0.7
    angle = angle or 0

    local a = radius
    local b = radius * aspect

    return V.v(center.x + a * math.cos(angle), center.y + b * math.sin(angle))
end

--- 计算点在椭圆内的距离因子
--- @param p table 点坐标 {x, y}
--- @param center table 椭圆中心 {x, y}
--- @param radius number 椭圆长轴半径
--- @param min_radius number|nil 最小半径（可选）
--- @param aspect number|nil 椭圆纵横比（可选，默认0.7）
--- @return number 距离因子（0-1）
function U.dist_factor_inside_ellipse(p, center, radius, min_radius, aspect)
    aspect = aspect or 0.7

    local vx, vy = p.x - center.x, p.y - center.y
    local angle = V.angleTo(vx, vy)
    local a = radius
    local b = radius * aspect
    local v_len = V.len(vx, vy)
    local ab_len = V.len(a * math.cos(angle), b * math.sin(angle))

    if min_radius then
        local ma, mb = min_radius, min_radius * aspect
        local mab_len = V.len(ma * math.cos(angle), mb * math.sin(angle))

        return km.clamp(0, 1, (v_len - mab_len) / (ab_len - mab_len))
    else
        return km.clamp(0, 1, v_len / ab_len)
    end
end

--- 协程：等待指定时间，可提前中断
--- @param store table game.store
--- @param time number 等待时间
--- @param break_func function|nil 中断函数（可选）
--- @return boolean 是否被中断
function U.y_wait(store, time, break_func)
    local start_ts = store.tick_ts

    while time > store.tick_ts - start_ts do
        if break_func and break_func(store, time) then
            return true
        end

        coroutine.yield()
    end

    return false
end

--- 开始实体动画
--- @param entity table 实体
--- @param name string 动画名称
--- @param flip_x boolean|nil 是否水平翻转（可选）
--- @param ts number|nil 时间戳（可选）
--- @param loop boolean|nil 是否循环（可选）
--- @param idx number|nil 指定精灵索引（可选，默认所有精灵）
--- @param force_ts boolean|nil 是否强制设置时间戳（可选）
function U.animation_start(entity, name, flip_x, ts, loop, idx, force_ts)
    loop = (loop == -1 or loop == true) and true or false

    local first, last

    if idx then
        first, last = idx, idx
    else
        first, last = 1, #entity.render.sprites
    end

    for i = first, last do
        local a = entity.render.sprites[i]

        if not a.ignore_start then
            local flip_x_i = flip_x

            if flip_x_i == nil then
                flip_x_i = a.flip_x
            end

            a.flip_x = flip_x_i
            if a.animated then
                a.loop = loop or a.loop_forced == true

                if not a.loop or force_ts then
                    a.ts = ts
                    a.runs = 0
                end

                if name and a.name ~= name then
                    a.name = name
                end
            end
        end
    end
end

--- 检查动画是否完成指定次数
--- @param entity table 实体
--- @param idx number|nil 精灵索引（可选，默认1）
--- @param times number|nil 完成次数（可选，默认1）
--- @return boolean 是否完成
function U.animation_finished(entity, idx, times)
    idx = idx or 1
    times = times or 1

    local a = entity.render.sprites[idx]

    if a.loop then
        if times == 1 then
            log.debug("waiting for looping animation for entity %s - ", entity.id, entity.template_name)
        end

        return times <= a.runs
    else
        return a.runs > 0
    end
end

--- 协程：等待动画完成指定次数
--- @param entity table 实体
--- @param idx number|nil 精灵索引（可选，默认1）
--- @param times number|nil 完成次数（可选，默认1）
function U.y_animation_wait(entity, idx, times)
    idx = idx or 1

    while not U.animation_finished(entity, idx, times) do
        coroutine.yield()
    end
end

--- 根据角度获取动画名称和翻转状态
--- @param e table 实体
--- @param group string 动画组名
--- @param angle number 角度（弧度）
--- @param idx number|nil 精灵索引（可选，默认1）
--- @return string 动画名称, boolean 是否水平翻转, number 象限索引
function U.animation_name_for_angle(e, group, angle, idx)
    idx = idx or 1

    local a = e.render.sprites[idx]
    local angles = a.angles and a.angles[group] or nil

    if not angles then
        return group, angle > math.pi * 0.5 and angle < 3 * math.pi * 0.5, 1
    elseif #angles == 1 then
        return angles[1], angle > math.pi * 0.5 and angle < 3 * math.pi * 0.5, 1
    elseif #angles == 2 then
        local flip_x = angle > math.pi * 0.5 and angle < 3 * math.pi * 0.5

        if angle > 0 and angle < math.pi then
            if a.angles_flip_horizontal and a.angles_flip_horizontal[1] then
                flip_x = not flip_x
            end

            return angles[1], flip_x, 1
        else
            if a.angles_flip_horizontal and a.angles_flip_horizontal[2] then
                flip_x = not flip_x
            end

            return angles[2], flip_x, 2
        end
    elseif #angles == 3 then
        local o_name, o_flip, o_idx
        local a1, a2, a3, a4 = 45, 135, 225, 315

        if a.angles_custom and a.angles_custom[group] then
            a1, a2, a3, a4 = unpack(a.angles_custom[group], 1, 4)
        end

        local quadrant = a._last_quadrant
        local stickiness = a.angles_stickiness and a.angles_stickiness[group]

        if stickiness and quadrant then
            local skew = stickiness * ((quadrant == 1 or quadrant == 3) and 1 or -1)

            a1, a3 = a1 - skew, a3 - skew
            a2, a4 = a2 + skew, a4 + skew
        end

        local angle_deg = angle * 180 / math.pi

        if a1 <= angle_deg and angle_deg < a2 then
            o_name, o_flip, o_idx = angles[2], false, 2
            quadrant = 1
        elseif a2 <= angle_deg and angle_deg < a3 then
            o_name, o_flip, o_idx = angles[1], true, 1
            quadrant = 2
        elseif a3 <= angle_deg and angle_deg < a4 then
            o_name, o_flip, o_idx = angles[3], false, 3
            quadrant = 3
        else
            o_name, o_flip, o_idx = angles[1], false, 1
            quadrant = 4
        end

        if stickiness then
            a._last_quadrant = quadrant
        end

        if a.angles_flip_vertical and a.angles_flip_vertical[group] then
            o_flip = angle > math.pi * 0.5 and angle < 3 * math.pi * 0.5
        end

        return o_name, o_flip, o_idx
    end
end

--- 根据面向点获取动画名称
--- @param e table 实体
--- @param group string 动画组名
--- @param point table 目标点 {x, y}
--- @param idx number|nil 精灵索引（可选）
--- @param offset table|nil 偏移量 {x, y}（可选）
--- @param use_path boolean|nil 是否使用路径点（可选）
--- @return string 动画名称, boolean 是否水平翻转, number 象限索引
function U.animation_name_facing_point(e, group, point, idx, offset, use_path)
    local fx, fy

    if e.nav_path and use_path then
        local npos = P:node_pos(e.nav_path)

        fx, fy = npos.x, npos.y
    else
        fx, fy = e.pos.x, e.pos.y
    end

    if offset then
        fx, fy = fx + offset.x, fy + offset.y
    end

    local vx, vy = V.sub(point.x, point.y, fx, fy)
    local v_angle = V.angleTo(vx, vy)
    local angle = km.unroll(v_angle)

    return U.animation_name_for_angle(e, group, angle, idx)
end

--- 协程：播放动画并等待完成
--- @param entity table 实体
--- @param name string 动画名称
--- @param flip_x boolean|nil 是否水平翻转（可选）
--- @param ts number|nil 时间戳（可选）
--- @param times number|nil 播放次数（可选）
--- @param idx number|nil 精灵索引（可选）
function U.y_animation_play(entity, name, flip_x, ts, times, idx)
    local loop = times and times > 1

    U.animation_start(entity, name, flip_x, ts, loop, idx, true)

    while not U.animation_finished(entity, idx, times) do
        coroutine.yield()
    end
end

--- 开始指定组的动画
--- @param entity table 实体
--- @param name string 动画名称
--- @param flip_x boolean|nil 是否水平翻转（可选）
--- @param ts number|nil 时间戳（可选）
--- @param loop boolean|nil 是否循环（可选）
--- @param group string|nil 组名（可选）
function U.animation_start_group(entity, name, flip_x, ts, loop, group)
    if not group then
        U.animation_start(entity, name, flip_x, ts, loop)

        return
    end

    for i = 1, #entity.render.sprites do
        local s = entity.render.sprites[i]

        if s.group == group then
            U.animation_start(entity, name, flip_x, ts, loop, i)
        end
    end
end

--- 检查指定组的动画是否完成
--- @param entity table 实体
--- @param group string|nil 组名（可选）
--- @param times number|nil 完成次数（可选）
--- @return boolean 是否完成
function U.animation_finished_group(entity, group, times)
    if not group then
        return U.animation_finished(entity, nil, times)
    end

    for i = 1, #entity.render.sprites do
        local s = entity.render.sprites[i]

        if s.group == group and U.animation_finished(entity, i, times) then
            return true
        end
    end
end

--- 协程：播放指定组的动画并等待完成
--- @param entity table 实体
--- @param name string 动画名称
--- @param flip_x boolean|nil 是否水平翻转（可选）
--- @param ts number|nil 时间戳（可选）
--- @param times number|nil 播放次数（可选）
--- @param group string|nil 组名（可选）
function U.y_animation_play_group(entity, name, flip_x, ts, times, group)
    if not group then
        U.y_animation_play(entity, name, flip_x, ts, times)

        return
    end

    local loop = times and times > 1

    U.animation_start_group(entity, name, flip_x, ts, loop, group)

    local idx

    for i = 1, #entity.render.sprites do
        local s = entity.render.sprites[i]

        if s.group == group then
            idx = i

            break
        end
    end

    if idx then
        while not U.animation_finished(entity, idx, times) do
            coroutine.yield()
        end
    end
end

--- 协程：等待指定组的动画完成
--- @param entity table 实体
--- @param group string|nil 组名（可选）
--- @param times number|nil 完成次数（可选）
function U.y_animation_wait_group(entity, group, times)
    if not group then
        U.y_animation_wait(entity, nil, times)

        return
    end

    for i = 1, #entity.render.sprites do
        local s = entity.render.sprites[i]

        if s.group == group then
            U.y_animation_wait(entity, i, times)

            break
        end
    end
end

--- 获取实体的动画时间戳
--- @param entity table 实体
--- @param group string|nil 组名（可选）
--- @return number 时间戳
function U.get_animation_ts(entity, group)
    if not group then
        return entity.render.sprites[1].ts
    else
        for i = 1, #entity.render.sprites do
            local s = entity.render.sprites[i]

            if s.group == group then
                return s.ts
            end
        end
    end
end

--- 隐藏指定范围的精灵
--- @param entity table 实体
--- @param from number|nil 起始索引（可选，默认1）
--- @param to number|nil 结束索引（可选）
--- @param keep boolean|nil 是否保持隐藏计数（可选）
function U.sprites_hide(entity, from, to, keep)
    if not entity or not entity.render then
        return
    end

    from = from or 1
    to = to or #entity.render.sprites

    for i = from, to do
        local s = entity.render.sprites[i]

        if keep then
            if s.hidden and s.hidden_count == 0 then
                s.hidden_count = 1
            end

            if not s.hidden and s.hidden_count > 0 then
                s.hidden_count = 0
            end

            s.hidden_count = s.hidden_count + 1
        end

        s.hidden = true
    end
end

--- 显示指定范围的精灵
--- @param entity table 实体
--- @param from number|nil 起始索引（可选，默认1）
--- @param to number|nil 结束索引（可选）
--- @param restore boolean|nil 是否恢复隐藏状态（可选）
function U.sprites_show(entity, from, to, restore)
    if not entity or not entity.render then
        return
    end

    from = from or 1
    to = to or #entity.render.sprites

    for i = from, to do
        local s = entity.render.sprites[i]

        if restore then
            s.hidden_count = math.max(0, s.hidden_count - 1)
            s.hidden = s.hidden_count > 0
        else
            s.hidden_count = 0
            s.hidden = nil
        end
    end
end

--- 设置移动目标
--- @param e table 实体
--- @param pos table 目标位置 {x, y}
function U.set_destination(e, pos)
    e.motion.dest = V.vclone(pos)
    e.motion.arrived = false
end

--- 设置实体朝向
--- @param e table 实体
--- @param dest table 目标位置 {x, y}
function U.set_heading(e, dest)
    if e.heading then
        local vx, vy = V.sub(dest.x, dest.y, e.pos.x, e.pos.y)
        local v_angle = V.angleTo(vx, vy)

        e.heading.angle = v_angle
    end
end

--- 移动实体到目标位置
--- @param e table 实体
--- @param dt number 时间增量
--- @param accel number|nil 加速度（可选）
--- @param unsnapped boolean|nil 是否不强制停在目标点（可选）
--- @return boolean 是否到达目标
function U.walk(e, dt, accel, unsnapped)
    if e.motion.arrived then
        return true
    end

    local m = e.motion
    local pos = e.pos
    local vx, vy = V.sub(m.dest.x, m.dest.y, pos.x, pos.y)
    local v_angle = V.angleTo(vx, vy)
    local v_len = V.len(vx, vy)

    if accel then
        if not (m.speed_limit and m.max_speed >= m.speed_limit) then
            U.speed_inc_self(e, accel * dt)
        end
    end

    local step = e.motion.real_speed * dt

    local nx, ny = V.normalize(V.rotate(v_angle, 1, 0))

    if v_len <= step and not (e.teleport and e.teleport.pending) then
        if unsnapped then
            local sx, sy = V.mul(step, nx, ny)

            pos.x, pos.y = V.add(pos.x, pos.y, sx, sy)
        else
            pos.x, pos.y = m.dest.x, m.dest.y
        end

        m.speed.x, m.speed.y = 0, 0
        m.arrived = true

        return true
    end

    if e.heading then
        e.heading.angle = v_angle
    end

    local sx, sy = V.mul(math.min(step, v_len), nx, ny)

    pos.x, pos.y = V.add(pos.x, pos.y, sx, sy)
    m.speed.x, m.speed.y = sx / dt, sy / dt
    m.arrived = false

    return false
end

--- 强制移动一步
--- @param this table 实体
--- @param dt number 时间增量
--- @param dest table 目标位置 {x, y}
function U.force_motion_step(this, dt, dest)
    local fm = this.force_motion
    local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
    local dist = V.len(dx, dy)
    local ramp_radius = fm.ramp_radius
    local df

    if not ramp_radius then
        df = 1
    elseif ramp_radius < dist then
        df = fm.ramp_max_factor
    else
        df = math.max(dist / ramp_radius, fm.ramp_min_factor)
    end

    fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
    fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(dt, fm.a.x, fm.a.y))
    fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)
    this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(dt, fm.v.x, fm.v.y))
    fm.a.x, fm.a.y = V.mul(-1 * fm.fr / dt, fm.v.x, fm.v.y)
end

--- 查找最近的士兵
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 最近的士兵
function U.find_nearest_soldier(entities, origin, min_range, max_range, flags, bans, filter_func)
    local soldiers = U.find_soldiers_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)

    if not soldiers or #soldiers == 0 then
        return nil
    else
        table.sort(soldiers, function(e1, e2)
            local e1_mock = band(e1.vis.flags, F_MOCKING) ~= 0
            local e2_mock = band(e2.vis.flags, F_MOCKING) ~= 0
            if e1_mock and not e2_mock then
                return true
            elseif not e1_mock and e2_mock then
                return false
            end
            return V.dist2(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist2(e2.pos.x, e2.pos.y, origin.x, origin.y)
        end)

        return soldiers[1]
    end
end

--- 查找范围内的士兵
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 范围内的士兵列表
function U.find_soldiers_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
    local soldiers = table.filter(entities, function(k, v)
        return not v.pending_removal and v.vis and v.health and not v.health.dead and band(v.vis.flags, bans) == 0 and
            band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and
            (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and
            (not filter_func or filter_func(v, origin))
    end)

    if not soldiers or #soldiers == 0 then
        return nil
    else
        return soldiers
    end
end

--- 查找最近的敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 最近的敌人, table|nil 所有范围内的敌人
function U.find_nearest_enemy(store, origin, min_range, max_range, flags, bans, filter_func)
    local targets = U.find_enemies_in_range(store, origin, min_range, max_range, flags, bans, filter_func)

    if not targets or #targets == 0 then
        return nil
    else
        table.sort(targets, function(e1, e2)
            return V.dist2(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist2(e2.pos.x, e2.pos.y, origin.x, origin.y)
        end)

        return targets[1], targets
    end
end

--- 查找最近的目标
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 最近的目标, table|nil 所有范围内的目标
function U.find_nearest_target(entities, origin, min_range, max_range, flags, bans, filter_func)
    local targets = U.find_targets_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)

    if not targets or #targets == 0 then
        return nil
    else
        table.sort(targets, function(e1, e2)
            return V.dist2(e1.pos.x, e1.pos.y, origin.x, origin.y) < V.dist2(e2.pos.x, e2.pos.y, origin.x, origin.y)
        end)

        return targets[1], targets
    end
end

--- 查找范围内的目标
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 范围内的目标列表
function U.find_targets_in_range(entities, origin, min_range, max_range, flags, bans, filter_func)
    local targets = table.filter(entities, function(k, v)
        return not v.pending_removal and v.vis and (v.enemy or v.soldier) and v.health and not v.health.dead and
            band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and
            U.is_inside_ellipse(v.pos, origin, max_range) and
            (not v.nav_path or P:is_node_valid(v.nav_path.pi, v.nav_path.ni)) and
            (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and
            (not filter_func or filter_func(v, origin))
    end)

    if not targets or #targets == 0 then
        return nil
    else
        return targets
    end
end

--- 查找第一个敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 第一个敌人
function U.find_first_enemy(store, origin, min_range, max_range, flags, bans, filter_func)
    flags = flags or 0
    bans = bans or 0
    if max_range == math.huge then
        for _, e in pairs(store.enemies) do
            if not e.pending_removal and not e.health.dead and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) == 0 and
                (not filter_func or filter_func(e, origin)) then
                return e
            end
        end
        return nil
    end
    return store.enemy_spatial_index:query_first_entity_in_ellipse(origin.x, origin.y, max_range, min_range, function(v)
        return not v.pending_removal and not v.health.dead and band(v.vis.flags, bans) == 0 and
        band(v.vis.bans, flags) == 0 and (not filter_func or filter_func(v, origin))
    end)
end

--- 随机选择一个目标
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 随机目标
function U.find_random_target(entities, origin, min_range, max_range, flags, bans, filter_func)
    flags = flags or 0
    bans = bans or 0

    local targets = table.filter(entities, function(k, v)
        return not v.pending_removal and v.health and not v.health.dead and v.vis and band(v.vis.flags, bans) == 0 and
            band(v.vis.bans, flags) == 0 and U.is_inside_ellipse(v.pos, origin, max_range) and
            (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and
            (not filter_func or filter_func(v, origin))
    end)

    if not targets or #targets == 0 then
        return nil
    else
        local idx = math.random(1, #targets)

        return targets[idx]
    end
end

--- 随机选择一个敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 随机敌人
function U.find_random_enemy(store, origin, min_range, max_range, flags, bans, filter_func)
    flags = flags or 0
    bans = bans or 0

    -- local enemies = table.filter(entities, function(k, v)
    --     return not v.pending_removal and v.vis and v.nav_path and v.health and not v.health.dead and
    --                band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and
    --                U.is_inside_ellipse(v.pos, origin, max_range) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and
    --                (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and
    --                (not filter_func or filter_func(v, origin))
    -- end)
    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, min_range,
        function(v)
            return not v.pending_removal and v.nav_path and not v.health.dead and band(v.vis.flags, bans) == 0 and
                band(v.vis.bans, flags) == 0 and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and
                (not filter_func or filter_func(v, origin))
        end)

    if not enemies or #enemies == 0 then
        return nil
    else
        local idx = math.random(1, #enemies)

        return enemies[idx]
    end
end

--- 查找随机敌人及其预测位置
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param prediction_time number|boolean 预测时间
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 随机敌人, table|nil 敌人预测位置
function U.find_random_enemy_with_pos(store, origin, min_range, max_range, prediction_time, flags, bans, filter_func)
    flags = flags or 0
    bans = bans or 0
    -- local enemies = {}
    -- for _, e in pairs(entities) do
    --     if e.pending_removal or not e.nav_path or not e.vis or e.health and e.health.dead or band(e.vis.flags, bans) ~=
    --         0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e, origin) then
    --         -- block empty
    --     else
    --         local e_pos, e_ni
    --         if e.motion and e.motion.speed then
    --             if e.motion.forced_waypoint then
    --                 local dt = prediction_time
    --                 e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
    --                 e_ni = e.nav_path.ni
    --             else
    --                 local node_offset = P:predict_enemy_node_advance(e, prediction_time)
    --                 e_ni = e.nav_path.ni + node_offset
    --                 e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
    --             end
    --         else
    --             e_pos = e.pos
    --             e_ni = e.nav_path.ni
    --         end
    --         if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and
    --             (min_range == 0 or not U.is_inside_ellipse(e_pos, origin, min_range)) then
    --             e.__ffe_pos = V.vclone(e_pos)
    --             table.insert(enemies, e)
    --         end
    --     end
    -- end

    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, min_range,
        function(e)
            if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e, origin) then
                return false
            end

            if prediction_time and e.motion.speed then
                if e.motion.forced_waypoint then
                    local dt = prediction_time == true and 1 or prediction_time

                    e.__ffe_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
                else
                    local node_offset = P:predict_enemy_node_advance(e, prediction_time)

                    local e_ni = e.nav_path.ni + node_offset
                    e.__ffe_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
                end
            else
                e.__ffe_pos = V.vclone(e.pos)
            end

            return true
        end)

    if not enemies or #enemies == 0 then
        return nil, nil
    else
        local idx = math.random(1, #enemies)
        return enemies[idx], enemies[idx].__ffe_pos
    end
end

--- 查找范围内的敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 范围内的敌人列表
function U.find_enemies_in_range(store, origin, min_range, max_range, flags, bans, filter_func)
    -- local enemies = table.filter(entities, function(k, v)
    --     return not v.pending_removal and v.nav_path and not v.health.dead and
    --                band(v.vis.flags, bans) == 0 and band(v.vis.bans, flags) == 0 and
    --                U.is_inside_ellipse(v.pos, origin, max_range) and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and
    --                (min_range == 0 or not U.is_inside_ellipse(v.pos, origin, min_range)) and
    --                (not filter_func or filter_func(v, origin))
    -- end)
    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, min_range,
        function(v)
            return not v.pending_removal and v.nav_path and not v.health.dead and band(v.vis.flags, bans) == 0 and
                band(v.vis.bans, flags) == 0 and P:is_node_valid(v.nav_path.pi, v.nav_path.ni) and
                (not filter_func or filter_func(v, origin))
        end)
    if #enemies == 0 then
        return nil
    else
        return enemies
    end
end

--- 查找路径上的敌人
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param min_node_range number 最小节点范围
--- @param max_node_range number 最大节点范围
--- @param max_path_dist number|nil 最大路径距离（可选，默认30）
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param only_upstream boolean|nil 是否只查找上游（可选）
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 路径上的敌人列表
function U.find_enemies_in_paths(entities, origin, min_node_range, max_node_range, max_path_dist, flags, bans,
                                 only_upstream, filter_func)
    max_path_dist = max_path_dist or 30
    flags = flags or 0
    bans = bans or 0

    local result = {}
    local nearest_nodes = P:nearest_nodes(origin.x, origin.y)

    for _, n in pairs(nearest_nodes) do
        local opi, ospi, oni, odist = unpack(n, 1, 4)

        if max_path_dist < odist or not P:is_node_valid(opi, oni) then
            -- block empty
        else
            for _, e in pairs(entities) do
                if not e.pending_removal and e.nav_path and e.health and not e.health.dead and e.nav_path.pi == opi and
                    (only_upstream == true and oni > e.nav_path.ni or only_upstream == false and oni < e.nav_path.ni or
                        only_upstream == nil) and e.vis and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) ==
                    0 and min_node_range <= math.abs(e.nav_path.ni - oni) and max_node_range >=
                    math.abs(e.nav_path.ni - oni) and (not filter_func or filter_func(e, origin)) then
                    table.insert(result, {
                        enemy = e,
                        origin = n
                    })
                end
            end
        end
    end

    if not result or #result == 0 then
        return nil
    else
        table.sort(result, function(e1, e2)
            local p1 = e1.enemy.nav_path
            local p2 = e2.enemy.nav_path

            return P:nodes_to_goal(p1.pi, p1.spi, p1.ni) < P:nodes_to_goal(p2.pi, p2.spi, p2.ni)
        end)

        return result
    end
end

--- 查找血量最高的敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param prediction_time number|boolean 预测时间
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @param min_override_flags number|nil 最小覆盖标志（可选）
--- @return table|nil 血量最高的敌人, table|nil 敌人预测位置
function U.find_biggest_enemy(store, origin, min_range, max_range, prediction_time, flags, bans, filter_func,
                              min_override_flags)
    flags = flags or 0
    bans = bans or 0
    min_override_flags = min_override_flags or 0

    local biggest_enemy = nil
    local biggest_hp = -1

    -- for _, e in pairs(entities) do
    --     if not e.pending_removal and not e.health.dead and band(e.vis.flags, bans) == 0 and band(e.vis.bans, flags) == 0 and
    --         (not filter_func or filter_func(e, origin)) then

    --         local e_pos, e_ni
    --         if prediction_time and e.motion.speed then
    --             if e.motion.forced_waypoint then
    --                 local dt = prediction_time == true and 1 or prediction_time
    --                 e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
    --                 e_ni = e.nav_path.ni
    --             else
    --                 local node_offset = P:predict_enemy_node_advance(e, prediction_time)
    --                 e_ni = e.nav_path.ni + node_offset
    --                 e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
    --             end
    --         else
    --             e_pos = e.pos
    --             e_ni = e.nav_path.ni
    --         end

    --         if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and
    --             (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
    --                 not U.is_inside_ellipse(e_pos, origin, min_range)) then
    --             e.__ffe_pos = V.vclone(e_pos)

    --             if e.health.hp > biggest_hp then
    --                 biggest_hp = e.health.hp
    --                 biggest_enemy = e
    --             end
    --         end
    --     end
    -- end
    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, 0, function(e)
        if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or
            not (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
                not U.is_inside_ellipse(e.pos, origin, min_range)) or filter_func and not filter_func(e, origin) then
            return false
        end

        if prediction_time and e.motion.speed then
            if e.motion.forced_waypoint then
                local dt = prediction_time == true and 1 or prediction_time

                e.__ffe_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
            else
                local node_offset = P:predict_enemy_node_advance(e, prediction_time)

                local e_ni = e.nav_path.ni + node_offset
                e.__ffe_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
            end
        else
            e.__ffe_pos = V.vclone(e.pos)
        end

        return true
    end)
    for i = 1, #enemies do
        local e = enemies[i]
        if e.health.hp > biggest_hp then
            biggest_hp = e.health.hp
            biggest_enemy = e
        end
    end
    if biggest_enemy then
        return biggest_enemy, biggest_enemy.__ffe_pos
    else
        return nil, nil
    end
end

--- 重新查找最前面的敌人
--- @param last_enemy table 上一个敌人
--- @param store table game.store
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @param min_override_flags number|nil 最小覆盖标志（可选）
function U.refind_foremost_enemy(last_enemy, store, flags, bans, filter_func, min_override_flags)
    local new_enemy = U.find_foremost_enemy(store, last_enemy.pos, 0, 50, nil, flags, bans, filter_func,
        min_override_flags)
    if new_enemy then
        last_enemy = new_enemy
    end
end

--- 查找具有最大覆盖范围的最前面敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param prediction_time number|boolean 预测时间
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @param min_override_flags number|nil 最小覆盖标志（可选）
--- @param cover_range number 覆盖范围
--- @return table|nil 最前面的敌人, table|nil 所有范围内的敌人
function U.find_foremost_enemy_with_max_coverage(store, origin, min_range, max_range, prediction_time, flags, bans,
                                                 filter_func, min_override_flags, cover_range)
    flags = flags or 0
    bans = bans or 0
    min_override_flags = min_override_flags or 0

    -- local enemies = {}

    -- for _, e in pairs(entities) do
    --     if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or
    --         filter_func and not filter_func(e, origin) then
    --         -- block empty
    --     else
    --         local e_pos, e_ni

    --         if prediction_time and e.motion.speed then
    --             if e.motion.forced_waypoint then
    --                 local dt = prediction_time == true and 1 or prediction_time

    --                 e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
    --                 e_ni = e.nav_path.ni
    --             else
    --                 local node_offset = P:predict_enemy_node_advance(e, prediction_time)

    --                 e_ni = e.nav_path.ni + node_offset
    --                 e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
    --             end
    --         else
    --             e_pos = e.pos
    --             e_ni = e.nav_path.ni
    --         end

    --         if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and
    --             (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
    --                 not U.is_inside_ellipse(e_pos, origin, min_range)) then
    --             e.__ffe_pos = V.vclone(e_pos)

    --             table.insert(enemies, e)
    --         end
    --     end
    -- end
    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, 0, function(e)
        if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or
            not (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
                not U.is_inside_ellipse(e.pos, origin, min_range)) or filter_func and not filter_func(e, origin) then
            return false
        end

        if prediction_time and e.motion.speed then
            if e.motion.forced_waypoint then
                local dt = prediction_time == true and 1 or prediction_time

                e.__ffe_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
            else
                local node_offset = P:predict_enemy_node_advance(e, prediction_time)

                local e_ni = e.nav_path.ni + node_offset
                e.__ffe_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
            end
        else
            e.__ffe_pos = V.vclone(e.pos)
        end

        return true
    end)

    if not enemies or #enemies == 0 then
        return nil, nil
    else
        U.sort_foremost_enemies(enemies)
        local foremost_enemy = enemies[1]
        local max_cover_enemy_idx = 1
        for i = 2, #enemies do
            local e = enemies[i]

            if V.dist2(e.__ffe_pos.x, e.__ffe_pos.y, foremost_enemy.__ffe_pos.x, foremost_enemy.__ffe_pos.y) <=
                cover_range * cover_range then
                max_cover_enemy_idx = i
            else
                break
            end
        end
        foremost_enemy = enemies[max_cover_enemy_idx]
        if foremost_enemy then
            return foremost_enemy, enemies, foremost_enemy.__ffe_pos
        else
            return nil, nil
        end
    end
end

--- 查找优先飞行单位的最前面敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param prediction_time number|boolean 预测时间
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @param min_override_flags number|nil 最小覆盖标志（可选）
--- @return table|nil 最前面的敌人, table|nil 所有范围内的敌人
function U.find_foremost_enemy_with_flying_preference(store, origin, min_range, max_range, prediction_time, flags, bans,
                                                      filter_func, min_override_flags)
    flags = flags or 0
    bans = bans or 0
    min_override_flags = min_override_flags or 0

    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, 0, function(e)
        if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or
            not (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
                not U.is_inside_ellipse(e.pos, origin, min_range)) or filter_func and not filter_func(e, origin) then
            return false
        end

        if prediction_time and e.motion.speed then
            if e.motion.forced_waypoint then
                local dt = prediction_time == true and 1 or prediction_time

                e.__ffe_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
            else
                local node_offset = P:predict_enemy_node_advance(e, prediction_time)

                local e_ni = e.nav_path.ni + node_offset
                e.__ffe_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
            end
        else
            e.__ffe_pos = V.vclone(e.pos)
        end

        return true
    end)

    if not enemies or #enemies == 0 then
        return nil, nil
    else
        U.sort_foremost_enemies_with_flying_preference(enemies)

        return enemies[1], enemies, enemies[1].__ffe_pos
    end
end

--- 查找最前面的敌人
--- @param store table game.store
--- @param origin table 原点 {x, y}
--- @param min_range number 最小范围
--- @param max_range number 最大范围
--- @param prediction_time number|boolean 预测时间
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @param min_override_flags number|nil 最小覆盖标志（可选）
--- @return table|nil 最前面的敌人, table|nil 所有范围内的敌人
function U.find_foremost_enemy(store, origin, min_range, max_range, prediction_time, flags, bans, filter_func,
                               min_override_flags)
    flags = flags or 0
    bans = bans or 0
    min_override_flags = min_override_flags or 0

    local enemies = store.enemy_spatial_index:query_entities_in_ellipse(origin.x, origin.y, max_range, 0, function(e)
        if e.pending_removal or e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or
            (not (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or
                not U.is_inside_ellipse(e.pos, origin, min_range))) or (filter_func and not filter_func(e, origin)) then
            return false
        end

        if prediction_time and e.motion.speed then
            if e.motion.forced_waypoint then
                local dt = prediction_time == true and 1 or prediction_time

                e.__ffe_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
            else
                local node_offset = P:predict_enemy_node_advance(e, prediction_time)

                local e_ni = e.nav_path.ni + node_offset
                e.__ffe_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
            end
        else
            e.__ffe_pos = V.vclone(e.pos)
        end

        return true
    end)
    if not enemies or #enemies == 0 then
        return nil, nil
    else
        U.sort_foremost_enemies(enemies)

        return enemies[1], enemies, enemies[1].__ffe_pos
    end
end

--- 查找范围内的塔
--- @param entities table 实体列表
--- @param origin table 原点 {x, y}
--- @param attack table 攻击属性
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 范围内的塔列表
function U.find_towers_in_range(entities, origin, attack, filter_func)
    local towers = table.filter(entities, function(k, v)
        return not v.pending_removal and not v.tower.blocked and
            (not attack.excluded_templates or not table.contains(attack.excluded_templates, v.template_name)) and
            U.is_inside_ellipse(v.pos, origin, attack.max_range) and
            (attack.min_range == 0 or not U.is_inside_ellipse(v.pos, origin, attack.min_range)) and
            (not filter_func or filter_func(v, origin, attack))
    end)

    if not towers or #towers == 0 then
        return nil
    else
        return towers
    end
end

--- 查找指定位置的实体
--- @param entities table 实体列表
--- @param x number X坐标
--- @param y number Y坐标
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 找到的实体
function U.find_entity_at_pos(entities, x, y, filter_func)
    local found = {}

    for _, e in pairs(entities) do
        if e.pos and e.ui and e.ui.can_click then
            local r = e.ui.click_rect

            if x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y +
                r.pos.y + r.size.y and (not filter_func or filter_func(e)) then
                table.insert(found, e)
            end
        end
    end

    table.sort(found, function(e1, e2)
        if e1.ui.z == e2.ui.z then
            return e1.pos.y < e2.pos.y
        else
            return e1.ui.z > e2.ui.z
        end
    end)

    if #found > 0 then
        local e = found[1]

        log.paranoid("entity:%s template:%s", e.id, e.template_name)

        return e
    else
        return nil
    end
end

--- 查找指定位置的所有实体
--- @param entities table 实体列表
--- @param x number X坐标
--- @param y number Y坐标
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 找到的实体列表
function U.find_entities_at_pos(entities, x, y, filter_func)
    local found = {}

    for _, e in pairs(entities) do
        if e.pos and e.ui and e.ui.can_click then
            local r = e.ui.click_rect

            if x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y +
                r.pos.y + r.size.y and (not filter_func or filter_func(e)) then
                table.insert(found, e)
            end
        end
    end
    if #found == 0 then
        return nil
    end
    return found
end

--- 查找有敌人的路径
--- @param entities table 实体列表
--- @param flags number 标志位
--- @param bans number 禁止标志位
--- @param filter_func function|nil 过滤函数（可选）
--- @return table|nil 有敌人的路径列表
function U.find_paths_with_enemies(entities, flags, bans, filter_func)
    local pis = {}

    for _, e in pairs(entities) do
        if not e.pending_removal and e.nav_path and e.health and not e.health.dead and e.vis and band(e.vis.flags, bans) ==
            0 and band(e.vis.bans, flags) == 0 and (not filter_func or filter_func(e)) then
            pis[e.nav_path.pi] = true
        end
    end

    local out = {}

    for pi, _ in pairs(pis) do
        table.insert(out, pi)
    end

    if #out < 1 then
        return nil
    else
        return out
    end
end

--- 获取攻击顺序
--- @param attacks table 攻击列表
--- @return table 攻击顺序索引数组
function U.attack_order(attacks)
    local order = {}

    for i = 1, #attacks do
        local a = attacks[i]

        table.insert(order, {
            id = i,
            chance = a.chance or 1,
            cooldown = a.cooldown
        })
    end

    table.sort(order, function(o1, o2)
        if o1.chance ~= o2.chance then
            return o1.chance < o2.chance
        elseif o1.cooldown and o2.cooldown and o1.cooldown ~= o2.cooldown then
            return o1.cooldown > o2.cooldown
        else
            return o1.id < o2.id
        end
    end)

    local out = {}

    for i = 1, #order do
        out[i] = order[i].id
    end

    return out
end

--- 获取近战位置
--- @param soldier table 士兵实体
--- @param enemy table 敌人实体
--- @param rank number|nil 排名（可选）
--- @param back boolean|nil 是否在后面（可选）
--- @return table|nil 士兵位置, boolean|nil 士兵是否在右侧
function U.melee_slot_position(soldier, enemy, rank, back)
    if not rank then
        rank = table.keyforobject(enemy.enemy.blockers, soldier.id)

        if not rank then
            return nil
        end
    end

    local idx = km.zmod(rank, 3)
    local x_off, y_off = 0, 0

    if idx == 2 then
        x_off = -3
        y_off = -6
    elseif idx == 3 then
        x_off = -3
        y_off = 6
    end

    local soldier_on_the_right = math.abs(km.signed_unroll(enemy.heading.angle)) < math.pi * 0.5

    if back then
        soldier_on_the_right = not soldier_on_the_right
    end

    local soldier_pos = V.v(enemy.pos.x + (enemy.enemy.melee_slot.x + x_off + soldier.soldier.melee_slot_offset.x) *
        (soldier_on_the_right and 1 or -1),
        enemy.pos.y + enemy.enemy.melee_slot.y + y_off + soldier.soldier.melee_slot_offset.y)

    return soldier_pos, soldier_on_the_right
end

--- 获取集结队形位置
--- @param idx number 索引
--- @param barrack table 兵营实体
--- @param count number|nil 总数（可选）
--- @param angle_offset number|nil 角度偏移（可选）
--- @return table 位置坐标, table 中心点坐标
function U.rally_formation_position(idx, barrack, count, angle_offset)
    local pos

    count = count or #barrack.soldiers
    angle_offset = angle_offset or 0

    if count == 1 then
        pos = V.vclone(barrack.rally_pos)
    else
        local a = 2 * math.pi / count

        pos = U.point_on_ellipse(barrack.rally_pos, barrack.rally_radius, (idx - 1) * a - math.pi * 0.5 + angle_offset)
    end

    local center = V.vclone(barrack.rally_pos)

    return pos, center
end

--- 获取拦截者
--- @param store table game.store
--- @param blocked table 被拦截实体
--- @return table|nil 拦截者实体
function U.get_blocker(store, blocked)
    if blocked.enemy and #blocked.enemy.blockers > 0 then
        local blocker_id = blocked.enemy.blockers[1]
        local blocker = store.entities[blocker_id]

        return blocker
    end

    return nil
end

--- 获取被拦截者
--- @param store table game.store
--- @param blocker table 拦截者实体
--- @return table|nil 被拦截者实体
function U.get_blocked(store, blocker)
    local blocked_id = blocker.soldier.target_id
    local blocked = store.entities[blocked_id]

    return blocked
end

--- 获取拦截者排名
--- @param store table game.store
--- @param blocker table 拦截者实体
--- @return number|nil 排名
function U.blocker_rank(store, blocker)
    local blocked_id = blocker.soldier.target_id
    local blocked = store.entities[blocked_id]

    if blocked then
        return table.keyforobject(blocked.enemy.blockers, blocker.id)
    end

    return nil
end

--- 检查被拦截者是否有效
--- @param store table game.store
--- @param blocker table 拦截者实体
--- @return boolean 是否有效
function U.is_blocked_valid(store, blocker)
    local blocked_id = blocker.soldier.target_id
    local blocked = store.entities[blocked_id]

    return blocked and not blocked.health.dead and (not blocked.vis or bit.band(blocked.vis.bans, F_BLOCK) == 0)
end

--- 解除所有拦截
--- @param store table game.store
--- @param blocked table 被拦截实体
function U.unblock_all(store, blocked)
    for _, blocker_id in pairs(blocked.enemy.blockers) do
        local blocker = store.entities[blocker_id]

        if blocker then
            blocker.soldier.target_id = nil
        end
    end

    blocked.enemy.blockers = {}
end

--- 安全移除拦截者
--- @param store table game.store
--- @param blocked table 被拦截实体
--- @param blocker_id number 拦截者ID
function U.dec_blocker(store, blocked, blocker_id)
    table.removeobject(blocked.enemy.blockers, blocker_id)
    if #blocked.enemy.blockers > 1 then
        local last = table.remove(blocked.enemy.blockers)
        table.insert(blocked.enemy.blockers, 1, last)
    end
end

--- 解除目标拦截
--- @param store table game.store
--- @param blocker table 拦截者实体
function U.unblock_target(store, blocker)
    local blocked_id = blocker.soldier.target_id
    local blocked = store.entities[blocked_id]

    if blocked then
        U.dec_blocker(store, blocked, blocker.id)
    end

    blocker.soldier.target_id = nil
end

--- 拦截敌人
--- @param store table game.store
--- @param blocker table 拦截者实体
--- @param blocked table 被拦截实体
function U.block_enemy(store, blocker, blocked)
    -- if blocker.max_targets then
    --     -- 士兵还有空闲的拦截位
    --     if blocker.max_targets > #blocker.target_ids then
    --         -- 若敌人并没有被士兵拦截，就让它被士兵拦截
    --         if not table.keyforobject(blocked.enemy.blockers, blocker.id) then
    --             table.insert(blocked.enemy.blockers, blocker.id)
    --             table.insert(blocker.soldier.target_ids, blocked.id)
    --             if not blocker.soldier.target_id then
    --                 blocker.soldier.target_id = blocked.id
    --             end
    --         end
    --     -- 士兵没有空闲的拦截位了
    --     else

    --     end
    -- else
    --     if blocker.soldier.target_id ~= blocked.id then
    --         U.unblock_target(store, blocker)
    --     end

    --     if not table.keyforobject(blocked.enemy.blockers, blocker.id) then
    --         table.insert(blocked.enemy.blockers, blocker.id)

    --         blocker.soldier.target_id = blocked.id
    --     end
    -- end
    if blocker.soldier.target_id ~= blocked.id then
        U.unblock_target(store, blocker)
    end

    if not table.keyforobject(blocked.enemy.blockers, blocker.id) then
        table.insert(blocked.enemy.blockers, blocker.id)

        blocker.soldier.target_id = blocked.id
    end
end

--- 替换拦截者
--- @param store table game.store
--- @param old table 旧拦截者
--- @param new table 新拦截者
function U.replace_blocker(store, old, new)
    local blocked_id = old.soldier.target_id
    local blocked = store.entities[blocked_id]

    if blocked then
        local idx = table.keyforobject(blocked.enemy.blockers, old.id)

        if idx then
            blocked.enemy.blockers[idx] = new.id
            new.soldier.target_id = blocked.id
            old.soldier.target_id = nil
        end
    end
end

--- 清理无效拦截者
--- @param store table game.store
--- @param blocked table 被拦截实体
function U.cleanup_blockers(store, blocked)
    local blockers = blocked.enemy.blockers

    if not blockers then
        return
    end

    for i = #blockers, 1, -1 do
        local blocker_id = blockers[i]

        if not store.entities[blocker_id] then
            log.debug("cleanup_blockers for (%s) %s removing id %s", blocked.id, blocked.template_name, blocker_id)
            table.remove(blockers, i)
        end
    end
end

--- 预测伤害
--- @param entity table 实体
--- @param damage table 伤害属性
--- @return number 实际伤害值
function U.predict_damage(entity, damage)
    local e = entity
    local d = damage

    if band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 then
        if e.health.damage_factor > 1 then
            return e.health.hp_max * (1 - e.health.instakill_resistance) * e.health.damage_factor
        else
            return e.health.hp_max * (1 - e.health.instakill_resistance)
        end
    end

    local protection

    local function calc_explosion_protection(armor)
        return armor * (0.2 * armor + 0.4)
    end

    local function calc_stab_protection(armor)
        return armor * (2 - armor)
    end

    local function calc_mixed_protection(armor, magic_armor)
        if magic_armor > armor then
            return armor
        else
            return (magic_armor + armor) * 0.5
        end
    end

    if band(d.damage_type, DAMAGE_POISON) ~= 0 then
        protection = e.health.poison_armor
    elseif band(d.damage_type, DAMAGE_TRUE) ~= 0 then
        protection = 0
    elseif band(d.damage_type, DAMAGE_PHYSICAL) ~= 0 then
        protection = e.health.armor - d.reduce_armor
    elseif band(d.damage_type, DAMAGE_MAGICAL) ~= 0 then
        protection = e.health.magic_armor - d.reduce_magic_armor
    elseif band(d.damage_type, DAMAGE_MAGICAL_EXPLOSION) ~= 0 then
        protection = calc_explosion_protection(e.health.magic_armor - d.reduce_magic_armor)
    elseif band(d.damage_type, DAMAGE_DISINTEGRATE) ~= 0 then
        protection = 0
    elseif band(d.damage_type, bor(DAMAGE_EXPLOSION, DAMAGE_ELECTRICAL, DAMAGE_RUDE)) ~= 0 then
        protection = calc_explosion_protection(e.health.armor - d.reduce_armor)
    elseif band(d.damage_type, DAMAGE_SHOT) ~= 0 then
        protection = (e.health.armor - d.reduce_armor) * 0.7
    elseif band(d.damage_type, DAMAGE_STAB) ~= 0 then
        protection = calc_stab_protection(e.health.armor - d.reduce_armor)
    elseif band(d.damage_type, DAMAGE_MIXED) ~= 0 then
        protection = calc_mixed_protection(e.health.armor - d.reduce_armor, e.health.magic_armor - d.reduce_magic_armor)
    elseif d.damage_type == DAMAGE_NONE then
        protection = 1
    end

    protection = protection or 0

    local rounded_damage = d.value
    if band(d.damage_type, bor(DAMAGE_MAGICAL, DAMAGE_MAGICAL_EXPLOSION)) ~= 0 then
        rounded_damage = km.round(rounded_damage * e.health.damage_factor_magical)
    end

    if band(d.damage_type, DAMAGE_ELECTRICAL) ~= 0 and e.health.damage_factor_electrical then
        rounded_damage = km.round(rounded_damage * e.health.damage_factor_electrical)
    end

    rounded_damage = km.round(rounded_damage * e.health.damage_factor)

    local actual_damage = math.ceil(rounded_damage * km.clamp(0, 1, 1 - protection))

    if band(d.damage_type, DAMAGE_NO_KILL) ~= 0 and e.health and actual_damage >= e.health.hp then
        actual_damage = e.health.hp - 1
    end

    return actual_damage
end

--- 检查是否已见过
--- @param store table game.store
--- @param id number 实体ID
--- @return boolean 是否已见过
function U.is_seen(store, id)
    return store.seen[id]
end

--- 标记为已见过
--- @param store table game.store
--- @param id number 实体ID
function U.mark_seen(store, id)
    if not store.seen[id] then
        store.seen[id] = true
        store.seen_dirty = true
    end
end

--- 计算星星数量
--- @param slot table 存档槽位
--- @return number 战役星星数, number 英雄模式星星数, number 铁人模式星星数
function U.count_stars(slot)
    local campaign = 0
    local heroic = 0
    local iron = 0

    for i, v in pairs(slot.levels) do
        if i < 80 then
            heroic = heroic + (v[GAME_MODE_HEROIC] and 1 or 0)
            iron = iron + (v[GAME_MODE_IRON] and 1 or 0)
            campaign = campaign + (v.stars or 0)
        end
    end

    return campaign + heroic + iron, heroic, iron
end

--- 查找范围内的下一个关卡
--- @param ranges table 关卡范围数组
--- @param cur number 当前关卡
--- @return number 下一个关卡
function U.find_next_level_in_ranges(ranges, cur)
    local last_range = ranges[#ranges]
    local nex = last_range[#last_range]

    for ri, r in ipairs(ranges) do
        if r.list then
            local idx = table.keyforobject(r, cur)

            if idx then
                if idx < #r then
                    nex = r[idx + 1]

                    break
                elseif ri < #ranges then
                    nex = ranges[ri + 1][1]

                    break
                end
            end
        else
            local r1, r2 = unpack(r)

            if r1 == cur or r2 and r1 <= cur and cur < r2 then
                nex = cur + 1

                break
            elseif r2 and cur == r2 and ri < #ranges then
                nex = ranges[ri + 1][1]

                break
            end
        end
    end

    return nex
end

--- 解锁范围内的下一个关卡
--- @param unlock_data table 解锁数据
--- @param levels table 关卡数据
--- @param game_settings table 游戏设置
--- @param generation number 世代
--- @return boolean 是否有变化
function U.unlock_next_levels_in_ranges(unlock_data, levels, game_settings, generation)
    local level_ranges = game_settings["level_ranges" .. generation]
    local last_campaign_level = game_settings["main_campaign_levels" .. generation]
    local dirty = false

    local function sanitize_unlock(idx)
        levels[idx] = {}

        if not unlock_data.new_level then
            unlock_data.new_level = idx
        end

        table.insert(unlock_data.unlocked_levels, idx)

        dirty = true

        log.debug(">>> sanitizing : added level %s", idx)
    end

    if levels[last_campaign_level] and levels[last_campaign_level][GAME_MODE_CAMPAIGN] then
        for i = 2, #level_ranges do
            local range = level_ranges[i]

            if not levels[range[1]] then
                levels[range[1]] = {}

                table.insert(unlock_data.unlocked_levels, range[1])

                dirty = true
            end
        end
    end

    for _, range in pairs(level_ranges) do
        if range[2] then
            if range.list then
                local prev

                for i, v in ipairs(range) do
                    if prev and levels[prev] and levels[prev][GAME_MODE_CAMPAIGN] and not levels[v] then
                        sanitize_unlock(v)

                        break
                    end

                    prev = v
                end
            else
                for i = range[1], range[2] - 1 do
                    if levels[i] and levels[i][GAME_MODE_CAMPAIGN] and not levels[i + 1] then
                        sanitize_unlock(i + 1)

                        break
                    end
                end
            end
        end
    end

    return dirty
end

--- 检查标志是否通过
--- @param vis table 视觉属性
--- @param vis_x table 目标视觉属性
--- @return boolean 是否通过
function U.flags_pass(vis, vis_x)
    return band(vis.flags, vis_x.vis_bans) == 0 and band(vis.bans, vis_x.vis_flags) == 0
end

--- 设置标志位
--- @param value number 原始值
--- @param flag number 要设置的标志位
--- @return number 设置后的值
function U.flag_set(value, flag)
    return bor(value, flag)
end

--- 清除标志位
--- @param value number 原始值
--- @param flag number 要清除的标志位
--- @return number 清除后的值
function U.flag_clear(value, flag)
    return band(value, bnot(flag))
end

--- 检查是否包含标志位
--- @param value number 原始值
--- @param flag number 要检查的标志位
--- @return boolean 是否包含
function U.flag_has(value, flag)
    return band(value, flag) ~= 0
end

--- 获取英雄等级
--- @param xp number 经验值
--- @param thresholds table 等级阈值数组
--- @return number 等级, number 下一级进度（0-1）
function U.get_hero_level(xp, thresholds)
    local level = 1

    while level < 10 and xp >= thresholds[level] do
        level = level + 1
    end

    local phase

    if level > #thresholds then
        phase = 1
    elseif xp == thresholds[level] then
        phase = 0
    else
        local this_xp = thresholds[level - 1] or 0
        local next_xp = thresholds[level]

        phase = (xp - this_xp) / (next_xp - this_xp)
    end

    return level, phase
end

--- 获取所有作用于实体的mod
--- @param store table game.store
--- @param entity table 实体
--- @param list table|nil 排除列表（可选）
--- @return table mod列表
function U.get_modifiers(store, entity, list)
    local result = {}
    local mods = entity._applied_mods
    if not mods then
        return result
    end
    for i = 1, #mods do
        local mod = mods[i]
        if not list or table.contains(list, mod.template_name) then
            result[#result + 1] = mod
        end
    end
    return result
end

--- 检查实体是否有指定mod
--- @param store table game.store
--- @param entity table 实体
--- @param mod_name string|nil mod名称（可选）
--- @return boolean 是否有mod
--- @return table mod列表
function U.has_modifiers(store, entity, mod_name)
    local mods = entity._applied_mods
    if not mods then
        return false, {}
    end
    local result = {}
    for i = 1, #mods do
        local mod = mods[i]
        if not mod_name or mod_name == mod.template_name then
            result[#result + 1] = mod
        end
    end

    return #result > 0, result
end

--- 检查实体是否有列表中的mod
--- @param store table game.store
--- @param entity table 实体
--- @param list table mod名称列表
--- @return boolean 是否有列表中的mod
function U.has_modifier_in_list(store, entity, list)
    local mods = entity._applied_mods
    if not mods then
        return false
    end
    for i = 1, #mods do
        local mod = mods[i]
        if table.contains(list, mod.template_name) then
            return true
        end
    end
    return false
end

--- 检查实体是否有指定类型的mod
--- @param store table game.store
--- @param entity table 实体
--- @param ... string mod类型
--- @return boolean 是否有指定类型的mod, table mod列表
function U.has_modifier_types(store, entity, ...)
    local mods = entity._applied_mods
    if not mods then
        return false, {}
    end
    local result = {}
    local types = { ... }
    for i = 1, #mods do
        local mod = mods[i]
        if table.contains(types, mod.modifier.type) then
            result[#result + 1] = mod
        end
    end

    return #result > 0, result
end

--- 计算实体的真实最大速度
--- @param entity table 实体
--- @return number 真实最大速度
function U.real_max_speed(entity)
    return km.clamp(1, 10000, (entity.motion.max_speed + entity.motion.buff) * entity.motion.factor)
end

--- 乘以速度因子
--- @param entity table 实体
--- @param factor number 因子
function U.speed_mul(entity, factor)
    entity.motion.factor = entity.motion.factor * factor
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 除以速度因子
--- @param entity table 实体
--- @param factor number 因子
function U.speed_div(entity, factor)
    entity.motion.factor = entity.motion.factor / factor
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 增加速度增益
--- @param entity table 实体
--- @param amount number 增量
function U.speed_inc(entity, amount)
    entity.motion.buff = entity.motion.buff + amount
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 减少速度增益
--- @param entity table 实体
--- @param amount number 减量
function U.speed_dec(entity, amount)
    entity.motion.buff = entity.motion.buff - amount
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 乘以自身速度
--- @param entity table 实体
--- @param factor number 因子
function U.speed_mul_self(entity, factor)
    entity.motion.max_speed = entity.motion.max_speed * factor
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 除以自身速度
--- @param entity table 实体
--- @param factor number 因子
function U.speed_div_self(entity, factor)
    entity.motion.max_speed = entity.motion.max_speed / factor
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 增加自身速度
--- @param entity table 实体
--- @param amount number 增量
function U.speed_inc_self(entity, amount)
    entity.motion.max_speed = entity.motion.max_speed + amount
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 减少自身速度
--- @param entity table 实体
--- @param amount number 减量
function U.speed_dec_self(entity, amount)
    entity.motion.max_speed = entity.motion.max_speed - amount
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 更新最大速度
--- @param entity table 实体
--- @param max_speed number 最大速度
function U.update_max_speed(entity, max_speed)
    entity.motion.max_speed = max_speed
    entity.motion.real_speed = U.real_max_speed(entity)
end

--- 查找传送时机
--- @param store table game.store
--- @param center table 中心点 {x, y}
--- @param range number 范围
--- @param trigger_count number 触发数量
--- @return table|nil 传送目标
function U.find_teleport_moment(store, center, range, trigger_count)
    local enemies = U.find_enemies_in_range(store, center, 0, range, F_NONE, F_NONE)
    if not enemies then
        return nil
    end
    local enemy_hp_max = 0
    local target = nil
    local soldier_count = 0

    for _, e in pairs(enemies) do
        target = e
        if e.health.hp > enemy_hp_max then
            enemy_hp_max = e.health.hp
        end
    end
    local enemy_count = #enemies

    for _, s in pairs(store.soldiers) do
        if not s.pending_removal and not s.health.dead and U.is_inside_ellipse(s.pos, center, range) then
            soldier_count = soldier_count + 1
        end
    end
    if ((enemy_count >= trigger_count) or (enemy_hp_max >= BIG_ENEMY_HP)) and enemy_count > soldier_count then
        return target
    end
    return nil
end

--- 函数追加
--- @param f1 function|nil 第一个函数（可选）
--- @param f2 function 第二个函数
--- @return function 组合后的函数
function U.function_append(f1, f2)
    return function(...)
        if not f1 or f1(...) then
            return f2(...)
        else
            return false
        end
    end
end

--- 追加mod
--- @param entity table 实体
--- @param mod_name string mod名称
function U.append_mod(entity, mod_name)
    if entity.mod then
        if type(entity.mod) == "table" then
            entity.mods = entity.mod
            table.insert(entity.mods, mod_name)
            entity.mod = nil
        else
            entity.mods = { entity.mod, mod_name }
            entity.mod = nil
        end
    else
        entity.mods = entity.mods or {}
        table.insert(entity.mods, mod_name)
    end
end

return U
