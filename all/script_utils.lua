-- chunkname: @./all/script_utils.lua
local log = require("klua.log"):new("script_utils")
local log_xp = log.xp or log:new("xp")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("klua.vector")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")
--- 将实体插入到实体队列中
--- @param store table 游戏存储对象 game.store
--- @param e table 实体对象
--- @return nil
local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end

--- 将实体插入移除队列
--- @param store table 游戏存储对象 game.store
--- @param e table 实体对象
--- @return nil
local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

--- 将伤害插入伤害队列
--- @param store table 游戏存储对象 game.store
--- @param damage table 伤害对象
--- @return nil
local function queue_damage(store, damage)
    store.damage_queue[#store.damage_queue + 1] = damage
end

--- 帧转秒
--- @param v number 帧数
--- @return number 秒数
local function fts(v)
    return v / FPS
end

--- 添加UI点击代理
--- @param proxy table 代理实体
--- @param dest table 目标实体
--- @return nil
local function ui_click_proxy_add(proxy, dest)
    if not proxy.ui then
        log.error("cannot proxy. entity has no ui component: (%s)%s", proxy.id, proxy.template_name)
        return
    end
    proxy.ui.click_proxies = proxy.ui.click_proxies or {}
    table.insert(proxy.ui.click_proxies, dest)
end

--- 移除UI点击代理
--- @param proxy table 代理实体
--- @param dest table 目标实体
--- @return nil
local function ui_click_proxy_remove(proxy, dest)
    if proxy.ui and proxy.ui.click_proxies then
        table.removeobject(proxy.ui.click_proxies, dest)
    end
end

--- 移除指定mod
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param mod_name string? mod名称（可选）
--- @param exclude_name string? 排除的mod名称（可选）
--- @return nil
local function remove_modifiers(store, entity, mod_name, exclude_name)
    local mods = table.filter(store.modifiers, function(k, v)
        return v.modifier and v.modifier.target_id == entity.id and (not mod_name or mod_name == v.template_name) and
                   (not exclude_name or exclude_name ~= v.template_name)
    end)
    for _, m in pairs(mods) do
        queue_remove(store, m)
    end
end

--- 按类型移除mod
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param mod_type string mod类型
--- @param exclude_name string? 排除的mod名称（可选）
--- @return nil
local function remove_modifiers_by_type(store, entity, mod_type, exclude_name)
    local mods = table.filter(store.modifiers, function(k, v)
        return v.modifier and v.modifier.target_id == entity.id and v.modifier.type == mod_type and
                   (not exclude_name or exclude_name ~= v.template_name)
    end)
    for _, m in pairs(mods) do
        queue_remove(store, m)
    end
end

--- 移除所有源为entity的光环
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @return nil
local function remove_auras(store, entity)
    local auras = table.filter(store.auras, function(k, v)
        return v.aura.track_source and v.aura.source_id == entity.id
    end)
    for _, a in pairs(auras) do
        queue_remove(store, a)
    end
end

--- 隐藏目标为entity的mod的精灵
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param keep boolean 是否保留
--- @param exclude_mod table? 排除的mod（可选）
--- @return nil
local function hide_modifiers(store, entity, keep, exclude_mod)
    local mods = table.filter(store.modifiers, function(k, v)
        return v.modifier and v.modifier.target_id == entity.id and v ~= exclude_mod
    end)
    for _, m in pairs(mods) do
        U.sprites_hide(m, nil, nil, keep)
    end
end

--- 显示目标为entity的mod的精灵
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param restore boolean 是否恢复
--- @param exclude_mod table? 排除的mod（可选）
--- @return nil
local function show_modifiers(store, entity, restore, exclude_mod)
    local mods = table.filter(store.modifiers, function(k, v)
        return v.modifier and v.modifier.target_id == entity.id and v ~= exclude_mod
    end)
    for _, m in pairs(mods) do
        U.sprites_show(m, nil, nil, restore)
    end
end

--- 隐藏所有源为entity的光环的精灵
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param keep boolean 是否保留
--- @return nil
local function hide_auras(store, entity, keep)
    local auras = table.filter(store.auras, function(k, v)
        return v.aura.track_source and v.aura.source_id == entity.id
    end)
    for _, a in pairs(auras) do
        U.sprites_hide(a, nil, nil, keep)
    end
end

--- 显示所有源为entity的光环的精灵
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param restore boolean 是否恢复
--- @return nil
local function show_auras(store, entity, restore)
    local auras = table.filter(store.auras, function(k, v)
        return v.aura.track_source and v.aura.source_id == entity.id
    end)
    for _, a in pairs(auras) do
        U.sprites_show(a, nil, nil, restore)
    end
end

--- 判断单位是否闪避攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 单位对象
--- @param ranged_attack boolean 是否远程攻击
--- @param attack table? 攻击对象（可选）
--- @param source table? 来源对象（可选）
--- @return boolean 是否闪避
local function unit_dodges(store, this, ranged_attack, attack, source)
    if not this.dodge then
        return false
    end
    this.dodge.last_check_ts = store.tick_ts
    local is_special_attack = ranged_attack or (attack and attack.type == "area")
    if not this.unit.is_stunned and (not this.enemy or this.enemy.can_do_magic) and
        (not ranged_attack or this.dodge.ranged) and
        (not this.dodge.cooldown or store.tick_ts - this.dodge.ts > this.dodge.cooldown) and
        (not attack or not attack.damage_type or band(attack.damage_type, DAMAGE_NO_DODGE) == 0) and
        ((not is_special_attack and math.random() <= this.dodge.chance) or
            (is_special_attack and math.random() <= 0.6 * this.dodge.chance))   and
        (not this.dodge.can_dodge or this.dodge.can_dodge(store, this, ranged_attack, attack, source)) then
        this.dodge.last_doge_ts = store.tick_ts
        this.dodge.last_attack = attack
        this.dodge.active = true
        if ranged_attack then
            this.dodge.from_ranged_attack = true
        else
            this.dodge.from_ranged_attack = false
        end
        return true
    end
    return false
end

--- 增加眩晕计数
--- @param this table 单位对象
--- @return nil
local function stun_inc(this)
    if this and this.unit and not this.unit.ignore_stun then
        local u = this.unit
        u.stun_count = u.stun_count + 1
        if u.stun_count > 0 then
            u.is_stunned = true
        end
    end
end

--- 减少眩晕计数
--- @param this table 单位对象
--- @param remove_all boolean 是否全部移除
--- @return nil
local function stun_dec(this, remove_all)
    if this and this.unit and not this.unit.ignore_stun then
        local u = this.unit
        u.stun_count = remove_all and 0 or u.stun_count - 1
        if u.stun_count < 1 then
            u.is_stunned = nil
            u.stun_count = 0
        end
    end
end

--- 更新护甲
--- @param this table 单位对象
--- @return nil
local function update_armor(this)
    if not this.health.raw_armor then
        this.health.raw_armor = this.health.armor
    end
    this.health.armor = km.clamp(0, 1, this.health.raw_armor + this.health.armor_buff)
end

--- 更新魔法护甲
--- @param this table 单位对象
--- @return nil
local function update_magic_armor(this)
    if not this.health.raw_magic_armor then
        this.health.raw_magic_armor = this.health.magic_armor
    end
    this.health.magic_armor = km.clamp(0, 1, this.health.raw_magic_armor + this.health.magic_armor_buff)
end

--- 增加护甲buff
--- @param this table 单位对象
--- @param value number 增加值
--- @return nil
local function armor_inc(this, value)
    this.health.armor_buff = this.health.armor_buff + value
    update_armor(this)
end

--- 减少护甲buff
--- @param this table 单位对象
--- @param value number 减少值
--- @return nil
local function armor_dec(this, value)
    armor_inc(this, -1 * value)
end

--- 增加魔法护甲buff
--- @param this table 单位对象
--- @param value number 增加值
--- @return nil
local function magic_armor_inc(this, value)
    this.health.magic_armor_buff = this.health.magic_armor_buff + value
    update_magic_armor(this)
end

--- 减少魔法护甲buff
--- @param this table 单位对象
--- @param value number 减少值
--- @return nil
local function magic_armor_dec(this, value)
    magic_armor_inc(this, -1 * value)
end

--- 增加伤害buff
--- @param this table 单位对象
--- @param value number 增加值
--- @return nil
local function damage_inc(this, value)
    this.damage_buff = this.damage_buff + value
end

--- 减少伤害buff
--- @param this table 单位对象
--- @param value number 减少值
--- @return nil
local function damage_dec(this, value)
    this.damage_buff = this.damage_buff - value
end

--- 增加反伤甲
--- @param this table 单位对象
--- @param value number 增加值
--- @return nil
local function spiked_armor_inc(this, value)
    if not this.health.raw_spiked_armor then
        this.health.raw_spiked_armor = this.health.spiked_armor
    end
    this.health.raw_spiked_armor = this.health.raw_spiked_armor + value
    this.health.spiked_armor = km.clamp(0, 1, this.health.raw_spiked_armor)
end

--- 减少反伤甲
--- @param this table 单位对象
--- @param value number 减少值
--- @return nil
local function spiked_armor_dec(this, value)
    spiked_armor_inc(this, -1 * value)
end

--- 增加防御塔block计数
--- @param this table 塔对象
--- @return nil
local function tower_block_inc(this)
    if this and this.tower and not this.tower_holder then
        local t = this.tower
        t.block_count = t.block_count + 1
        if t.block_count > 0 then
            t.blocked = true
            if this.ui then
                this.ui.can_click = false
            end
        end
    end
end

--- 减少防御塔block计数
--- @param this table 塔对象
--- @param remove_all boolean 是否全部移除
--- @return nil
local function tower_block_dec(this, remove_all)
    if this and this.tower and not this.tower_holder then
        local t = this.tower
        t.block_count = remove_all and 0 or t.block_count - 1
        if t.block_count < 1 then
            t.blocked = nil
            t.block_count = 0
            if this.ui then
                this.ui.can_click = true
            end
        end
    end
end

--- 更新沉默塔技能冷却
--- @param store table 游戏存储对象 game.store
--- @param this table 塔对象
--- @return nil
local function tower_update_silenced_powers(store, this)
    for k, pow in pairs(this.powers) do
        if pow.attack_idx then
            local pa = this.attacks.list[pow.attack_idx]
            if pa then
                if not this.tower.can_do_magic and not pa.silence_ts then
                    pa.silence_ts = store.tick_ts
                elseif this.tower.can_do_magic and pa.silence_ts then
                    pa.ts = store.tick_ts - (pa.silence_ts - pa.ts)
                    pa.silence_ts = nil
                end
            end
        end
    end
end

--- 召唤死亡生成物
--- @param store table 游戏存储对象 game.store
--- @param this table 实体对象
--- @return nil
local function do_death_spawns(store, this)
    if this.death_spawns.fx then
        local fx = E:create_entity(this.death_spawns.fx)
        fx.pos = V.vclone(this.pos)
        fx.render.sprites[1].ts = store.tick_ts
        if this.death_spawns.fx_flip_to_source and this.render and this.render.sprites[1] then
            fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
        end
        queue_insert(store, fx)
    end
    if this.enemy and not this.enemy.can_do_magic then
        return
    end
    for i = 1, this.death_spawns.quantity do
        local s = E:create_entity(this.death_spawns.name)
        s.pos = V.vclone(this.pos)
        if this.death_spawns.spawn_animation and s.render then
            s.render.sprites[1].name = this.death_spawns.spawn_animation
        end
        if s.render and s.render.sprites[1] and this.render and this.render.sprites[1] then
            s.render.sprites[1].flip_x = this.render.sprites[1].flip_x
        end
        if s.nav_path then
            s.nav_path.pi = this.nav_path.pi
            local spread_nodes = this.death_spawns.spread_nodes
            if spread_nodes > 0 then
                s.nav_path.spi = km.zmod(this.nav_path.spi + i, 3)
                local node_offset = spread_nodes * -2 * math.floor(i / 3)
                s.nav_path.ni = this.nav_path.ni + node_offset + spread_nodes
            else
                s.nav_path.spi = this.nav_path.spi
                s.nav_path.ni = this.nav_path.ni + 2
            end
        end
        if this.death_spawns.offset then
            s.pos.x = s.pos.x + this.death_spawns.offset.x
            s.pos.y = s.pos.y + this.death_spawns.offset.y
        end
        queue_insert(store, s)
    end
end

--- 延迟攻击
--- @param store table 游戏存储对象 game.store
--- @param attack table 攻击对象
--- @param time number 延迟时间
--- @return nil
local function delay_attack(store, attack, time)
    attack.ts = store.tick_ts - attack.cooldown + time - 1e-06
end

--- 插入精灵
--- @param store table 游戏存储对象 game.store
--- @param name string 精灵名称
--- @param pos table 位置
--- @param flip_x boolean 是否翻转
--- @param ts_offset number? 时间偏移（可选）
--- @return table 精灵实体
local function insert_sprite(store, name, pos, flip_x, ts_offset)
    local e = E:create_entity(name)
    e.pos.x, e.pos.y = pos.x, pos.y
    if e.render then
        for _, s in pairs(e.render.sprites) do
            s.ts = store.tick_ts + (ts_offset or 0)
            s.flip_x = flip_x
        end
    end
    queue_insert(store, e)
    return e
end

--- 实体淡出
--- @param store table 游戏存储对象 game.store
--- @param entity table 实体对象
--- @param delay number 延迟时间
--- @param duration number? 持续时间（可选）
--- @return nil
local function fade_out_entity(store, entity, delay, duration)
    duration = duration or 2
    if entity.tween then
        log.error("entity %s already has tween. cannot be faded out", entity.id)
        return
    end
    entity.tween = E:clone_c("tween")
    entity.tween.remove = false
    entity.tween.ts = store.tick_ts
    local p = E:clone_c("tween_prop")
    p.keys = {{0, 255}, {delay, 255}, {delay + duration, 0}}
    for i, s in ipairs(entity.render.sprites) do
        local pp = table.deepclone(p)
        pp.sprite_id = i
        entity.tween.props[i] = pp
    end
end

--- 创建弹出效果
--- @param store table 游戏存储对象 game.store
--- @param pos table 位置
--- @param pop table 弹出效果列表
--- @return table 弹出实体
local function create_pop(store, pos, pop)
    local name = pop[math.random(1, #pop)]
    local e = E:create_entity(name)
    e.pos = V.v(pos.x, pos.y + e.pop_y_offset)
    e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
    e.render.sprites[1].ts = store.tick_ts
    return e
end

--- 创建弹道弹出效果
--- @param store table 游戏存储对象 game.store
--- @param this table 弹道实体
--- @return table 弹出实体
local function create_bullet_pop(store, this)
    local b = this.bullet
    if b.pop then
        return create_pop(store, this.pos, b.pop)
    end
end

--- 创建弹道伤害
--- @param bullet table 弹道对象
--- @param target_id number 目标ID
--- @param source_id number 来源ID
--- @return table 伤害实体
local function create_bullet_damage(bullet, target_id, source_id)
    local d = E:create_entity("damage")
    d.damage_type = bullet.damage_type
    d.reduce_armor = bullet.reduce_armor
    d.reduce_magic_armor = bullet.reduce_magic_armor
    local vmin, vmax = bullet.damage_min, bullet.damage_max
    if bullet.level and bullet.level > 0 then
        if bullet.damage_min_inc then
            vmin = vmin + bullet.damage_min_inc * bullet.level
        end
        if bullet.damage_max_inc then
            vmax = vmax + bullet.damage_max_inc * bullet.level
        end
        if bullet.damage_inc then
            vmax = vmax + bullet.damage_inc * bullet.level
            vmin = vmin + bullet.damage_inc * bullet.level
        end
    end
    local value = U.frandom(vmin, vmax)
    d.value = math.max(1, bullet.damage_factor * value)
    d.target_id = target_id
    d.source_id = source_id
    d.xp_gain_factor = bullet.xp_gain_factor
    d.xp_dest_id = bullet.xp_dest_id
    d.pop = bullet.pop
    d.pop_chance = bullet.pop_chance
    d.pop_conds = bullet.pop_conds
    d.track_damage = bullet.track_damage
    return d
end

--- 创建攻击伤害
--- @param a table 攻击对象
--- @param target_id number 目标ID
--- @param this table 攻击者实体
--- @return table 伤害实体
local function create_attack_damage(a, target_id, this)
    local vmax, vmin = a.damage_max, a.damage_min
    if a.level and a.level > 0 then
        if a.damage_max_inc then
            vmax = vmax + a.damage_max_inc * a.level
        end
        if a.damage_min_inc then
            vmin = vmin + a.damage_min_inc * a.level
        end
        if a.damage_inc then
            vmax = vmax + a.damage_inc * a.level
            vmin = vmin + a.damage_inc * a.level
        end
    end
    local d = E:create_entity("damage")
    d.value = U.frandom(vmin, vmax)
    if this.damage_buff then
        d.value = d.value + this.damage_buff
    end
    if this.unit and this.unit.damage_factor then
        d.value = d.value * this.unit.damage_factor
    end
    d.damage_type = a.damage_type
    d.target_id = target_id
    d.source_id = this.id
    return d
end

--- 抛物线初速度
--- @param from table 起点
--- @param to table 终点
--- @param time number 时间
--- @param g number 重力加速度
--- @return table 速度向量
local function initial_parabola_speed(from, to, time, g)
    return V.v((to.x - from.x) / time, (to.y - from.y - 0.5 * g * time * time) / time)
end

--- 抛物线位置
--- @param t number 时间
--- @param from table 起点
--- @param speed table 速度向量
--- @param g number 重力加速度
--- @return number x坐标, number y坐标
local function position_in_parabola(t, from, speed, g)
    local x = speed.x * t + from.x
    local y = g * t * t * 0.5 + speed.y * t + from.y
    return x, y
end

--- 抛物线y坐标
--- @param phase number 阶段
--- @param from_y number 起点y
--- @param to_y number 终点y
--- @param max_y number 最大y
--- @return number y坐标
local function parabola_y(phase, from_y, to_y, max_y)
    local max_y = math.max(max_y, from_y, to_y)
    local reverse = to_y < from_y
    local offset = reverse and to_y or from_y
    local xc = (reverse and from_y or to_y) - offset
    local M = reverse and max_y - to_y or max_y - from_y
    local C = (reverse and from_y or to_y) - offset
    local x = reverse and 1 - phase or phase
    local b
    b = (M < C or C < 0.0001) and 1 or 2 / C * (M - math.sqrt(M * M - M * C))
    local y = M * 4 / (b * b) * x * (b - x)
    return y + offset
end

--- 判断士兵是否被打断
--- @param this table 士兵对象
--- @return boolean 是否被打断
local function soldier_interrupted(this)
    return this.nav_rally.new or this.health.dead or this.unit.is_stunned
end

--- 士兵等待
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵对象
--- @param time number 等待时间
--- @return boolean 是否提前结束
local function y_soldier_wait(store, this, time)
    return U.y_wait(store, time, function(store, time)
        return soldier_interrupted(this)
    end)
end

--- 士兵动画等待
--- @param this table 士兵对象
--- @return boolean 是否提前结束
local function y_soldier_animation_wait(this)
    while not U.animation_finished(this) do
        if soldier_interrupted(this) then
            return true
        end
        coroutine.yield()
    end
    return false
end

--- 判断英雄是否会传送
--- @param this table 英雄对象
--- @param new_rally_pos table 新集结点位置
--- @return boolean 是否会传送
local function hero_will_teleport(this, new_rally_pos)
    local tp = this.teleport
    local r = new_rally_pos
    return tp and not tp.disabled and V.dist2(r.x, r.y, this.pos.x, this.pos.y) > tp.min_distance * tp.min_distance
end

--- 判断英雄是否会变形
--- @param this table 英雄对象
--- @param new_rally_pos table 新集结点位置
--- @return boolean 是否会变形
local function hero_will_transfer(this, new_rally_pos)
    local tr = this.transfer
    local r = new_rally_pos
    return tr and not tr.disabled and V.dist2(r.x, r.y, this.pos.x, this.pos.y) > tr.min_distance * tr.min_distance
end

--- 英雄按路径点移动
--- @param store table 游戏存储对象 game.store
--- @param this table 英雄对象
--- @param animation string? 动画名称（可选）
--- @return boolean 是否被打断
local function y_hero_walk_waypoints(store, this, animation)
    local animation = animation or "walk"
    local r = this.nav_rally
    local n = this.nav_grid
    local dest = r.pos
    while not V.veq(this.pos, dest) do
        local w = table.remove(n.waypoints, 1) or dest
        local unsnap = #n.waypoints > 0
        U.set_destination(this, w)
        local an, af = U.animation_name_facing_point(this, animation, this.motion.dest)
        U.animation_start(this, an, af, store.tick_ts, true)
        while not this.motion.arrived do
            if this.health.dead and not this.health.ignore_damage then
                return true
            end
            if r.new then
                return false
            end
            U.walk(this, store.tick_length, nil, unsnap)
            coroutine.yield()
            this.motion.speed.x, this.motion.speed.y = 0, 0
        end
    end
end

--- 英雄新集结点处理
--- @param store table 游戏存储对象 game.store
--- @param this table 英雄对象
--- @return boolean|nil
local function y_hero_new_rally(store, this)
    local r = this.nav_rally
    if r.new then
        r.new = false
        U.unblock_target(store, this)
        if this.sound_events then
            S:queue(this.sound_events.change_rally_point)
        end
        if hero_will_teleport(this, r.pos) then
            local tp = this.teleport
            local vis_bans = this.vis.bans
            tp.pending = true
            U.set_destination(this, r.pos)
            this.vis.bans = F_ALL
            this.health.ignore_damage = true
            this.health_bar.hidden = true
            S:queue(tp.sound)
            if tp.fx_out then
                local fx = E:create_entity(tp.fx_out)
                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].ts = store.tick_ts
                if fx.tween then
                    fx.tween.ts = store.tick_ts
                end
                queue_insert(store, fx)
            end
            U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)
            if tp.delay > 0 then
                U.sprites_hide(this, nil, nil, true)
                U.y_wait(store, tp.delay)
                U.sprites_show(this, nil, nil, true)
            end
            this.pos.x, this.pos.y = r.pos.x, r.pos.y
            this.motion.speed.x, this.motion.speed.y = 0, 0
            if tp.fx_in then
                local fx = E:create_entity(tp.fx_in)
                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].ts = store.tick_ts
                if fx.tween then
                    fx.tween.ts = store.tick_ts
                end
                queue_insert(store, fx)
            end
            U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)
            tp.pending = false
            this.health_bar.hidden = false
            this.vis.bans = vis_bans
            this.health.ignore_damage = false
            return false
        elseif hero_will_transfer(this, r.pos) then
            local tr = this.transfer
            local interrupt = false
            local ps
            local vis_bans = this.vis.bans
            this.vis.bans = F_ALL
            this.health.ignore_damage = true
            this.health_bar.hidden = true
            local prev_scale, prev_color
            if tr.scale then
                prev_scale = this.render.sprites[1].scale
                this.render.sprites[1].scale = tr.scale
            end
            S:queue(tr.sound_loop)
            U.y_animation_play(this, tr.animations[1], nil, store.tick_ts)
            U.speed_inc_self(this, tr.extra_speed)
            if tr.particles_name then
                ps = E:create_entity(tr.particles_name)
                ps.particle_system.track_id = this.id
                queue_insert(store, ps)
            end
            repeat
                r.new = false
                if y_hero_walk_waypoints(store, this, tr.animations[2]) then
                    interrupt = true
                    break
                end
            until this.motion.arrived
            if tr.particles_name then
                ps.particle_system.emit = false
                ps.particle_system.source_lifetime = 1
            end
            U.speed_dec_self(this, tr.extra_speed)
            S:stop(tr.sound_loop)
            U.y_animation_play(this, tr.animations[3], nil, store.tick_ts)
            if tr.scale then
                this.render.sprites[1].scale = prev_scale
            end
            this.health_bar.hidden = false
            this.vis.bans = vis_bans
            this.health.ignore_damage = false
            return interrupt
        else
            local vis_bans = this.vis.bans
            local prev_immune = this.health.immune_to
            this.vis.bans = F_ALL
            this.health.immune_to = r.immune_to
            local out = y_hero_walk_waypoints(store, this)
            U.animation_start(this, "idle", nil, store.tick_ts, true)
            this.vis.bans = vis_bans
            this.health.immune_to = prev_immune
            return out
        end
    end
end

--- 英雄技能获得经验
--- @param this table 英雄对象
--- @param skill table 技能对象
--- @return nil
local function hero_gain_xp_from_skill(this, skill)
    if skill.level then
        local amount
        if skill.xp_gain then
            amount = skill.xp_gain[skill.level]
        else
            amount = skill.level * skill.xp_gain_factor
        end
        this.hero.xp_queued = this.hero.xp_queued + amount
        if log_xp.level >= log_xp.DEBUG_LEVEL then
            local skill_name
            for k, v in pairs(this.hero.skills) do
                if v == skill then
                    skill_name = k
                    break
                end
            end
            log_xp.debug("XP QUEUE SKILL: (%s)%s xp:%.2f skill:%s level:%s factor:%.2f", this.id, this.template_name,
                amount, skill_name, skill.level, skill.xp_gain_factor)
        end
    end
end

--- 英雄获得经验
--- @param this table 英雄对象
--- @param value number 经验值
--- @param desc string 来源描述
--- @return nil
local function hero_gain_xp(this, value, desc)
    this.hero.xp_queued = this.hero.xp_queued + value
    log_xp.debug("XP QUEUE MANUAL: (%s)%s xp:%.2f from:%s", this.id, this.template_name, value, desc)
end

--- 英雄升级
--- @param store table 游戏存储对象 game.store
--- @param this table 英雄对象
--- @return boolean 是否升级
local function hero_level_up(store, this)
    local h = this.hero
    if h.xp_queued == 0 then
        return false
    end
    local expected_level_multiplier = 1
    local level_based
    if store.level_idx <= 9 then
        expected_level_multiplier = 0.1 * store.level_idx
    elseif store.level_idx <= 35 and store.level_idx > 26 then
        expected_level_multiplier = 0.1 * (store.level_idx - 26)
    elseif store.level_idx <= 57 and store.level_idx > 48 then
        expected_level_multiplier = 0.1 * (store.level_idx - 48)
    end
    local difficulty_multiplier = GS.hero_xp_gain_per_difficulty_mode[store.level_difficulty]
    local net_xp = h.xp_queued * expected_level_multiplier * difficulty_multiplier * store.config.hero_xp_gain_multiplier
    log_xp.debug("XP+: (%s)%s xp:%07.2f + net_xp:%6.2f = %8.2f | net_xp = xp_queued:%s * exp_lvl_mul:%s * diff_mul:%s",
        this.id, this.template_name, h.xp, km.round(net_xp), h.xp + km.round(net_xp), h.xp_queued,
        expected_level_multiplier, difficulty_multiplier)
    h.xp = h.xp + km.round(net_xp)
    h.xp_queued = 0
    if h.level >= 10 or h.xp < GS.hero_xp_thresholds[h.level] then
        return false
    end
    this.hero.level = this.hero.level + 1
    this.hero.fn_level_up(this, store)
    signal.emit("hero-level-increased", this)
    S:queue("HeroLevelUp")
    return true
end

--- 英雄死亡与复活流程
--- @param store table 游戏存储对象 game.store
--- @param this table 英雄对象
--- @return nil
local function y_hero_death_and_respawn(store, this)
    local h = this.health
    local he = this.hero

    this.ui.can_click = false

    local death_ts = store.tick_ts
    local dead_lifetime = h.dead_lifetime

    U.unblock_target(store, this)

    if this.selfdestruct and not this.selfdestruct.disabled and
        band(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0 then
        local sd = this.selfdestruct

        this.unit.hide_after_death = true
        this.health_bar.hidden = true
        dead_lifetime = sd.dead_lifetime or dead_lifetime

        U.animation_start(this, sd.animation, nil, store.tick_ts)
        S:queue(this.sound_events.death, this.sound_events.death_args)
        S:queue(sd.sound, sd.sound_args)
        U.y_wait(store, sd.hit_time)
        S:queue(sd.sound_hit)

        if sd.hit_fx then
            insert_sprite(store, sd.hit_fx, this.pos)
        end

        if sd.xp_from_skill then
            hero_gain_xp_from_skill(this, this.hero.skills[sd.xp_from_skill])
        end

        local targets =
            U.find_enemies_in_range(store, this.pos, 0, sd.damage_radius, sd.vis_flags, sd.vis_bans)

        if targets then
            for _, t in pairs(targets) do
                local d = E:create_entity("damage")
                d.damage_type = sd.damage_type
                d.value = ((sd.damage and sd.damage or math.random(sd.damage_min, sd.damage_max)) + this.damage_buff) *
                    this.unit.damage_factor
                d.source_id = this.id
                d.target_id = t.id
                queue_damage(store, d)
                if sd.mod then
                    local m = E:create_entity(sd.mod)
                    m.modifier.target_id = t.id
                    m.modifier.source_id = this.id
                    m.modifier.damage_factor = this.unit.damage_factor
                    queue_insert(store, m)
                end
            end
        end

        U.y_animation_wait(this)
    elseif band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0 then
        this.unit.hide_after_death = true

        local fx = E:create_entity("fx_soldier_desintegrate")

        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
        this.unit.hide_after_death = true
    elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
        this.unit.hide_after_death = true

        S:queue("DeathEplosion")

        local fx = E:create_entity("fx_unit_explode")

        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]

        queue_insert(store, fx)

        if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
            local decal = E:create_entity("decal_blood_pool")

            decal.pos = V.vclone(this.pos)
            decal.render.sprites[1].ts = store.tick_ts
            decal.render.sprites[1].name = this.unit.blood_color

            queue_insert(store, decal)
        end
    else
        S:queue(this.sound_events.death, this.sound_events.death_args)
        U.y_animation_play(this, "death", nil, store.tick_ts, 1)
    end

    if this.unit.hide_after_death then
        for _, s in pairs(this.render.sprites) do
            s.hidden = true
        end
    end

    local tombstone

    if he and he.tombstone_show_time then
        while store.tick_ts - death_ts < he.tombstone_show_time and not this.force_respawn do
            coroutine.yield()
        end

        tombstone = E:create_entity(he.tombstone_decal)
        tombstone.pos = this.pos

        queue_insert(store, tombstone)

        for _, s in pairs(this.render.sprites) do
            s.hidden = true
        end
    end

    while dead_lifetime > store.tick_ts - death_ts and not this.force_respawn do
        coroutine.yield()
    end

    if tombstone then
        queue_remove(store, tombstone)
    end

    if he and he.respawn_point then
        local p = he.respawn_point

        this.pos.x, this.pos.y = p.x, p.y
        this.nav_rally.pos.x, this.nav_rally.pos.y = p.x, p.y
        this.nav_rally.center.x, this.nav_rally.center.y = p.x, p.y
        this.nav_rally.new = false
    end

    for _, s in pairs(this.render.sprites) do
        s.hidden = false
    end

    h.ignore_damage = true

    S:queue(this.sound_events.respawn)
    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false
    this.ui.can_click = true
    h.dead = false
    h.hp = h.hp_max
    h.ignore_damage = false
    this.force_respawn = false
end
--- 士兵援军淡入
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return nil
local function y_reinforcement_fade_in(store, this)
    U.y_wait(store, fts(10))
    this.tween.disabled = true
end

--- 士兵援军淡出
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return nil
local function y_reinforcement_fade_out(store, this)
    this.render.sprites[1].ts = store.tick_ts
    local offset = 50
    if this.render.sprites[1].flip_x then
        offset = -1 * offset
    end
    local o = V.v(this.pos.x + offset, this.pos.y)
    U.set_destination(this, o)
    local t_angle = offset > 0 and 0 or math.pi
    local an, af, ai = U.animation_name_for_angle(this, "walk", t_angle)
    U.animation_start(this, an, af, store.tick_ts, -1)
    this.tween.reverse = true
    this.tween.disabled = nil
    this.health.hp = 0
    while not this.motion.arrived do
        U.walk(this, store.tick_length)
        coroutine.yield()
    end
end

--- 士兵新集结点处理
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否被打断
local function y_soldier_new_rally(store, this)
    local r = this.nav_rally
    local out = false
    local vis_bans = this.vis.bans
    local prev_immune = this.health.immune_to
    this.health.immune_to = r.immune_to
    this.vis.bans = F_ALL
    if r.new then
        r.new = false
        U.unblock_target(store, this)
        U.set_destination(this, r.pos)
        local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
        U.animation_start(this, an, af, store.tick_ts, -1)
        while not this.motion.arrived do
            if this.health.dead or this.unit.is_stunned then
                out = true
                break
            end
            if r.new then
                out = false
                break
            end
            U.walk(this, store.tick_length)
            coroutine.yield()
            this.motion.speed.x, this.motion.speed.y = 0, 0
        end
    end
    this.vis.bans = vis_bans
    this.health.immune_to = prev_immune
    return out
end

--- 士兵复活流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否复活成功
local function y_soldier_revive(store, this)
    if not this.revive or this.revive.disabled or this.unit.is_stunned or
        band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_EAT)) ~= 0 then
        return false
    end
    local r = this.revive
    local chance = r.chance + r.protect
    if math.random() < chance then
        local r = this.revive
        r.protect = r.protect * 0.5
        if r.remove_modifiers then
            remove_modifiers(store, this)
        end
        this.health.ignore_damage = true
        this.health.dead = false
        this.health_bar.hidden = false

        -- if this.soldier.max_targets then
        --     for _, target_id in pairs(this.soldier.target_ids) do
        --         local target = store.entities[target_id]
        --         if target then
        --             U.block_enemy(store, this, target)
        --         end
        --     end
        -- elseif this.soldier.target_id then
        --     local enemy = store.entities[this.soldier.target_id]

        --     if enemy then
        --         U.block_enemy(store, this, enemy)
        --     end
        -- end

        if this.soldier.target_id then
            local enemy = store.entities[this.soldier.target_id]
            if enemy then
                U.block_enemy(store, this, enemy)
            end
        end
        if r.fx then
            local fx = E:create_entity(r.fx)
            fx.pos = this.pos
            fx.render.sprites[1].ts = store.tick_ts
            queue_insert(store, fx)
        end
        if r.animation then
            S:queue(r.sound)
            U.animation_start(this, r.animation, nil, store.tick_ts, false)
            r.ts = store.tick_ts
            while store.tick_ts - r.ts < r.hit_time do
                coroutine.yield()
            end
        end
        r.revive_count = (r.revive_count or 0) + 1
        signal.emit("entity-revived", this, r.revive_count)
        this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.health.hp_max * r.health_recover)
        if r.animation then
            while not U.animation_finished(this) do
                coroutine.yield()
            end
        end
        this.health.ignore_damage = false
        return true
    end
    return false
end

--- 士兵死亡流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return nil
local function y_soldier_death(store, this)
    U.unblock_target(store, this)
    local h = this.health
    if band(h.last_damage_types, DAMAGE_DISINTEGRATE) ~= 0 then
        this.unit.hide_during_death = true
        local fx = E:create_entity("fx_soldier_desintegrate")
        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts
        queue_insert(store, fx)
    elseif band(h.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
        this.unit.hide_during_death = true
    elseif band(h.last_damage_types, bor(DAMAGE_HOST)) ~= 0 then
        S:queue(this.sound_events.death_by_explosion)
        this.unit.hide_during_death = true
        local fx = E:create_entity("fx_unit_explode")
        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
        queue_insert(store, fx)
        if this.unit.show_blood_pool and this.unit.blood_color ~= BLOOD_NONE then
            local decal = E:create_entity("decal_blood_pool")
            decal.pos = V.vclone(this.pos)
            decal.render.sprites[1].ts = store.tick_ts
            decal.render.sprites[1].name = this.unit.blood_color
            queue_insert(store, decal)
        end
    elseif this.reinforcement and (this.reinforcement.fade or this.reinforcement.fade_out) then
        y_reinforcement_fade_out(store, this)
        return
    else
        S:queue(this.sound_events.death, this.sound_events.death_args)
        U.y_animation_play(this, "death", nil, store.tick_ts, 1)
        this.ui.can_select = false
    end
    if this.ui then
        this.ui.can_click = not this.unit.hide_after_death
        this.ui.z = -1
    end
    if this.unit.hide_during_death or this.unit.hide_after_death then
        for _, s in pairs(this.render.sprites) do
            s.hidden = true
        end
    end
end

--- 士兵循环远程攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_soldier_do_loopable_ranged_attack(store, this, target, attack)
    local attack_done = false
    local start_ts = store.tick_ts
    local b, an, af, ai
    S:queue(attack.sound, attack.sound_args)
    if attack.animations[1] then
        an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)
        U.y_animation_play_group(this, an, af, store.tick_ts, 1, attack.sprite_group)
    end
    for i = 1, attack.loops do
        an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)
        U.animation_start_group(this, an, af, store.tick_ts, false, attack.sprite_group)
        for si, st in pairs(attack.shoot_times) do
            while st > store.tick_ts - U.get_animation_ts(this, attack.sprite_group) do
                if this.unit.is_stunned then
                    goto label_59_0
                end
                if this.health.dead or this.nav_rally and this.nav_rally.new then
                    goto label_59_1
                end
                coroutine.yield()
            end
            b = E:create_entity(attack.bullet)
            b.pos = V.vclone(this.pos)
            if attack.bullet_start_offset then
                local offset = attack.bullet_start_offset[ai]
                b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
            end
            if attack.bullet_shot_start_offset then
                local offset = attack.bullet_shot_start_offset[si]
                b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
            end
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            b.bullet.target_id = target.id
            b.bullet.shot_index = si
            b.bullet.loop_index = i
            b.bullet.source_id = this.id
            b.bullet.xp_dest_id = this.id
            b.bullet.damage_factor = this.unit.damage_factor
            b.bullet.damage_max = b.bullet.damage_max + this.damage_buff
            b.bullet.damage_min = b.bullet.damage_min + this.damage_buff
            queue_insert(store, b)
            if attack.xp_from_skill then
                hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
            end
            attack_done = true
        end
        while not U.animation_finished_group(this, attack.sprite_group) do
            if this.unit.is_stunned then
                goto label_59_0
            end
            if this.health.dead or this.nav_rally and this.nav_rally.new then
                goto label_59_1
            end
            coroutine.yield()
        end
    end
    ::label_59_0::
    if attack.animations[3] then
        an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)
        U.animation_start_group(this, an, af, store.tick_ts, false, attack.sprite_group)
        while not U.animation_finished_group(this, attack.sprite_group) do
            if this.health.dead or this.nav_rally and this.nav_rally.new then
                break
            end
            coroutine.yield()
        end
    end
    ::label_59_1::
    if attack_done and attack.xp_from_skill_once then
        hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill_once])
    end
    return attack_done
end

--- 士兵远程攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @param pred_pos table? 预测位置（可选）
--- @return boolean 是否攻击完成
local function y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
    local attack_done = false
    local start_ts = store.tick_ts
    local bullet
    local bullet_to = pred_pos or target.pos
    local bullet_to_start = V.vclone(bullet_to)
    local an, af, ai = U.animation_name_facing_point(this, attack.animation, bullet_to)
    U.animation_start(this, an, af, store.tick_ts, false)
    S:queue(attack.sound)
    while store.tick_ts - start_ts < attack.shoot_time do
        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
            goto label_60_0
        end
        coroutine.yield()
    end
    if attack.check_target_before_shot then
        if (not target) or target.health.dead or (not store.entities[target.id]) then
            local trash
            local node_prediction
            if attack.node_prediction == true then
                node_prediction = 1 - attack.shoot_time
            elseif attack.node_prediction then
                node_prediction = attack.node_prediction - attack.shoot_time
            else
                node_prediction = nil
            end
            target, trash, pred_pos = U.find_foremost_enemy(store, this.pos, attack.min_range,
                attack.max_range, node_prediction, attack.vis_flags, attack.vis_bans, attack.filter_fn, F_FLYING)
            if target and not target.health.dead then
                bullet_to = pred_pos or target.pos
                bullet_to_start = V.vclone(bullet_to)
            else
                goto label_60_0
            end
        end
    end
    if attack.max_track_distance and V.dist2(target.pos.x, target.pos.y, bullet_to_start.x, bullet_to_start.y) >
        attack.max_track_distance * attack.max_track_distance then
        log.debug("target (%s) at %s,%s  exceeds attack.max_track_distance %s to %s,%s", target.id, target.pos.x,
            target.pos.y, attack.max_track_distance, bullet_to_start.x, bullet_to_start.y)
    else
        if attack.side_effect then
            attack.side_effect(this, store, attack, target)
        end
        S:queue(attack.sound_shoot)
        bullet = E:create_entity(attack.bullet)
        bullet.pos = V.vclone(this.pos)
        if attack.bullet_start_offset then
            local offset = attack.bullet_start_offset[ai]
            bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
        end
        bullet.bullet.damage_max = bullet.bullet.damage_max + this.damage_buff
        bullet.bullet.damage_min = bullet.bullet.damage_min + this.damage_buff
        if attack.mod then
            bullet.bullet.mod = attack.mod
        end
        bullet.bullet.from = V.vclone(bullet.pos)
        bullet.bullet.to = V.vclone(bullet_to)
        if not attack.ignore_hit_offset then
            bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
            bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
        end
        bullet.bullet.target_id = target.id
        bullet.bullet.source_id = this.id
        bullet.bullet.xp_dest_id = this.id
        bullet.bullet.level = attack.level
        bullet.bullet.damage_factor = this.unit.damage_factor
        queue_insert(store, bullet)
        if attack.xp_from_skill then
            hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
        end
        attack_done = true
        while not U.animation_finished(this) do
            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                break
            end
            coroutine.yield()
        end
    end
    ::label_60_0::
    return attack_done
end

--- 士兵选择远程攻击目标和攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return table 目标, table 攻击, table 预测位置
local function soldier_pick_ranged_target_and_attack(store, this)
    local in_range = false
    local awaiting_target
    for _, i in pairs(this.ranged.order) do
        local a = this.ranged.attacks[i]
        if a.disabled then
            -- block empty
        elseif a.sync_animation and not this.render.sprites[1].sync_flag then
            -- block empty
        elseif a.chance and math.random() > a.chance then
            -- block empty
        else
            local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)
            if target then
                if pred_pos then
                    log.paranoid(" target.pos:%s,%s  pred_pos:%s,%s", target.pos.x, target.pos.y, pred_pos.x, pred_pos.y)
                end
                local ready = store.tick_ts - a.ts >= a.cooldown * this.cooldown_factor
                if this.ranged.forced_cooldown then
                    ready = ready and store.tick_ts - this.ranged.forced_ts >= this.ranged.forced_cooldown *
                        this.cooldown_factor
                end
                if not ready then
                    awaiting_target = target
                elseif math.random() <= a.chance then
                    return target, a, pred_pos
                else
                    a.ts = store.tick_ts
                end
            end
        end
    end
    return awaiting_target, nil
end

--- 士兵远程攻击流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否提前结束, number 状态码
local function y_soldier_ranged_attacks(store, this)
    local target, attack, pred_pos = soldier_pick_ranged_target_and_attack(store, this)
    if not target then
        if this.motion.arrived then
            U.y_wait(store, this.soldier.guard_time)
        end
        return false, A_NO_TARGET
    end
    if not attack then
        return false, A_IN_COOLDOWN
    end
    local start_ts = store.tick_ts
    local attack_done
    U.set_destination(this, this.pos)
    if attack.loops then
        attack_done = y_soldier_do_loopable_ranged_attack(store, this, target, attack)
    else
        attack_done = y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
    end
    if attack_done then
        attack.ts = start_ts
        if attack.shared_cooldown then
            for _, aa in pairs(this.ranged.attacks) do
                if aa ~= attack and aa.shared_cooldown then
                    aa.ts = attack.ts
                end
            end
        end
        if this.ranged.forced_cooldown then
            this.ranged.forced_ts = start_ts
        end
    end
    if attack_done then
        return false, A_DONE
    else
        return true
    end
end

--- 士兵执行特殊动作
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param action table 动作对象
--- @return boolean 是否动作完成
local function y_soldier_do_timed_action(store, this, action)
    local action_done = false
    local start_ts = store.tick_ts
    U.animation_start(this, action.animation, nil, store.tick_ts)
    S:queue(action.sound)
    if action.cast_time and y_soldier_wait(store, this, action.cast_time) then
        -- block empty
    else
        action.ts = start_ts
        action_done = true
        if action.mod then
            local e = E:create_entity(action.mod)
            e.modifier.target_id = this.id
            e.modifier.source_id = this.id
            e.modifier.level = action.level
            e.modifier.damage_factor = this.unit.damage_factor
            queue_insert(store, e)
        elseif action.aura then
            local e = E:create_entity(action.aura)
            e.aura.source_id = this.id
            e.aura.level = action.level
            e.aura.damage_factor = this.unit.damage_factor
            e.pos = V.vclone(this.pos)
            queue_insert(store, e)
        end
        y_soldier_animation_wait(this)
    end
    return action_done
end

--- 士兵特殊动作流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否提前结束, number 状态码
local function y_soldier_timed_actions(store, this)
    for _, a in pairs(this.timed_actions.list) do
        if a.disabled or store.tick_ts - a.ts < a.cooldown then
            -- block empty
        elseif a.fn_can and not a.fn_can(this, store, a) then
            return false, A_NO_TARGET
        elseif not a.chance or math.random() < a.chance then
            local attack_done = y_soldier_do_timed_action(store, this, a)
            if attack_done then
                return false, A_DONE
            else
                return true
            end
        else
            a.ts = store.tick_ts
        end
    end
    return false, A_IN_COOLDOWN
end

--- 士兵特殊攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_soldier_do_timed_attack(store, this, target, attack)
    local attack_done = false
    local start_ts = store.tick_ts
    local spell
    local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)
    U.animation_start(this, an, af, store.tick_ts)
    S:queue(attack.sound)
    while store.tick_ts - start_ts < attack.cast_time do
        if this.health.dead or this.unit.is_stunned or this.nav_rally and this.nav_rally.new then
            goto label_65_0
        end
        coroutine.yield()
    end
    attack.ts = start_ts
    spell = E:create_entity(attack.spell)
    if attack.level then
        spell.spell.level = attack.level
    end
    spell.spell.source_id = this.id
    spell.spell.target_id = target.id
    queue_insert(store, spell)
    attack_done = true
    while not U.animation_finished(this) do
        if this.health.dead or this.nav_rally and this.nav_rally.new then
            break
        end
        coroutine.yield()
    end
    ::label_65_0::
    S:stop(attack.sound)
    return attack_done
end

--- 士兵特殊攻击流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否提前结束, number 状态码
local function y_soldier_timed_attacks(store, this)
    for _, a in pairs(this.timed_attacks.list) do
        if a.disabled or store.tick_ts - a.ts < a.cooldown then
            -- block empty
        else
            local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, false, a.vis_flags,
                a.vis_bans)
            if not target then
                return false, A_NO_TARGET
            elseif math.random() < a.chance then
                local attack_done = y_soldier_do_timed_attack(store, this, target, a)
                if attack_done then
                    return false, A_DONE
                else
                    return true
                end
            else
                a.ts = store.tick_ts
            end
        end
    end
    return false, A_IN_COOLDOWN
end

--- 攻击是否被打断
--- @param this table 士兵实体
--- @param attack table 攻击对象
--- @return boolean 是否被打断
local function attack_interrupted(this, attack)
    return this.health.dead or this.unit.is_stunned or
        (this.dodge and this.dodge.active and not (this.dodge.silent or attack.never_interrupt))
end

--- 士兵单次范围攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_soldier_do_single_area_attack(store, this, target, attack)
    local attack_done = false
    local start_ts = store.tick_ts
    local targets, hit_pos
    local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)
    U.animation_start(this, an, af, store.tick_ts, 1)
    S:queue(attack.sound, attack.sound_args)
    while store.tick_ts - start_ts < attack.hit_time do
        if attack_interrupted(this, attack) or this.nav_rally and this.nav_rally.new then
            goto label_67_0
        end
        coroutine.yield()
    end
    S:queue(attack.sound_hit, attack.sound_hit_args)
    attack.ts = start_ts
    if attack.shared_cooldown then
        for _, aa in pairs(this.melee.attacks) do
            if aa ~= attack and aa.shared_cooldown then
                aa.ts = attack.ts
            end
        end
    end
    if attack.forced_cooldown then
        this.melee.forced_ts = attack.ts
    end
    if attack.cooldown_group then
        for _, aa in pairs(this.melee.attacks) do
            if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
                aa.ts = attack.ts
            end
        end
    end
    if attack.signal then
        signal.emit("soldier-attack", this, attack, attack.signal)
    end
    hit_pos = V.vclone(this.pos)
    if attack.hit_offset then
        hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
        hit_pos.y = hit_pos.y + attack.hit_offset.y
    end
    targets = U.find_enemies_in_range(store, hit_pos, 0, attack.damage_radius, attack.damage_flags,
        attack.damage_bans) or {}
    if attack.count then
        table.sort(targets, function(e1, e2)
            return V.dist2(e1.pos.x, e1.pos.y, hit_pos.x, hit_pos.y) < V.dist2(e2.pos.x, e2.pos.y, hit_pos.x, hit_pos.y)
        end)
    end
    for i = 1, math.min(attack.count or #targets, #targets) do
        local e = targets[i]
        local d = E:create_entity("damage")
        d.source_id = this.id
        d.target_id = e.id
        d.damage_type = attack.damage_type
        d.value = (math.random(attack.damage_min, attack.damage_max) + this.damage_buff) * this.unit.damage_factor
        d.track_kills = this.track_kills ~= nil
        d.track_damage = attack.track_damage
        d.xp_gain_factor = attack.xp_gain_factor
        d.xp_dest_id = attack.xp_dest_id
        d.pop = attack.pop
        d.pop_chance = attack.pop_chance
        d.pop_conds = attack.pop_conds
        queue_damage(store, d)
        if attack.mod then
            if (not attack.mod_chance) or math.random() < attack.mod_chance then
                local mod = E:create_entity(attack.mod)
                mod.modifier.ts = store.tick_ts
                mod.modifier.target_id = e.id
                mod.modifier.source_id = this.id
                mod.modifier.level = attack.level
                mod.modifier.target_idx = i
                mod.modifier.damage_factor = this.unit.damage_factor
                queue_insert(store, mod)
            end
        end
    end
    if attack.hit_aura then
        local a = E:create_entity(attack.hit_aura)
        a.pos = V.vclone(hit_pos)
        a.aura.target_id = target.id
        a.aura.source_id = this.id
        queue_insert(store, a)
    end
    if attack.hit_fx then
        local fx = E:create_entity(attack.hit_fx)
        fx.pos = V.vclone(hit_pos)
        for i = 1, #fx.render.sprites do
            fx.render.sprites[i].ts = store.tick_ts
        end
        queue_insert(store, fx)
    end
    if attack.hit_decal then
        local fx = E:create_entity(attack.hit_decal)
        fx.pos = V.vclone(hit_pos)
        for i = 1, #fx.render.sprites do
            fx.render.sprites[i].ts = store.tick_ts
        end
        queue_insert(store, fx)
    end
    attack_done = true
    while not U.animation_finished(this) do
        if attack_interrupted(this, attack) or this.nav_rally and this.nav_rally.new then
            break
        end
        coroutine.yield()
    end
    ::label_67_0::
    S:stop(attack.sound)
    return attack_done
end

--- 士兵循环近战攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_soldier_do_loopable_melee_attack(store, this, target, attack)
    local attack_done = false
    local start_ts = store.tick_ts
    local an, af
    S:queue(attack.sound, attack.sound_args)
    if attack.animations[1] then
        an, af = U.animation_name_facing_point(this, attack.animations[1], target.pos)
        U.y_animation_play(this, an, af, store.tick_ts, 1)
    end
    for i = 1, attack.loops do
        if attack.interrupt_loop_on_dead_target and target.health.dead then
            log.debug("interrupt_loop_on_dead_target")
            goto label_70_1
        end
        local loop_ts = store.tick_ts
        S:queue(attack.sound_loop, attack.sound_loop_args)
        an, af = U.animation_name_facing_point(this, attack.animations[2], target.pos)
        U.animation_start(this, an, af, store.tick_ts, 1)
        local hit_times = attack.hit_times and attack.hit_times or { attack.hit_time }
        for _, ht in pairs(hit_times) do
            while ht > store.tick_ts - loop_ts do
                if this.unit.is_stunned then
                    goto label_70_0
                end
                if attack.interrupt_on_dead_target and target.health.dead then
                    log.debug("interrupt_on_dead_target")
                    goto label_70_1
                end
                if this.health.dead or this.nav_rally and this.nav_rally.new then
                    goto label_70_1
                end
                coroutine.yield()
            end
            S:queue(attack.sound_hit, attack.sound_hit_args)
            attack.ts = start_ts
            if attack.shared_cooldown then
                for _, aa in pairs(this.melee.attacks) do
                    if aa ~= attack and aa.shared_cooldown then
                        aa.ts = attack.ts
                    end
                end
            end
            if attack.forced_cooldown then
                this.melee.forced_ts = attack.ts
            end
            if attack.cooldown_group then
                for _, aa in pairs(this.melee.attacks) do
                    if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
                        aa.ts = attack.ts
                    end
                end
            end
            if attack.type == "area" then
                local hit_pos = V.vclone(this.pos)
                if attack.hit_offset then
                    hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
                    hit_pos.y = hit_pos.y + attack.hit_offset.y
                end
                local targets = U.find_enemies_in_range(store, hit_pos, 0, attack.damage_radius,
                    attack.damage_flags, attack.damage_bans) or {}
                for _, e in pairs(targets) do
                    local d = E:create_entity("damage")
                    d.source_id = this.id
                    d.target_id = e.id
                    d.damage_type = attack.damage_type
                    d.value = (math.random(attack.damage_min, attack.damage_max) + this.damage_buff) *
                        this.unit.damage_factor
                    d.track_kills = this.track_kills ~= nil
                    d.track_damage = attack.track_damage
                    d.xp_gain_factor = attack.xp_gain_factor
                    d.xp_dest_id = attack.xp_dest_id
                    d.pop = attack.pop
                    d.pop_chance = attack.pop_chance
                    d.pop_conds = attack.pop_conds

                    queue_damage(store, d)

                    if attack.mod then
                        local mod = E:create_entity(attack.mod)

                        mod.modifier.ts = store.tick_ts
                        mod.modifier.target_id = e.id
                        mod.modifier.source_id = this.id
                        mod.modifier.level = attack.level
                        mod.modifier.damage_factor = this.unit.damage_factor
                        queue_insert(store, mod)
                    end
                end

                if attack.hit_fx then
                    local fx = E:create_entity(attack.hit_fx)

                    fx.pos = V.vclone(hit_pos)

                    for i = 1, #fx.render.sprites do
                        fx.render.sprites[i].ts = store.tick_ts
                    end

                    queue_insert(store, fx)
                end

                if attack.hit_decal then
                    local fx = E:create_entity(attack.hit_decal)

                    fx.pos = V.vclone(hit_pos)

                    for i = 1, #fx.render.sprites do
                        fx.render.sprites[i].ts = store.tick_ts
                    end

                    queue_insert(store, fx)
                end
            elseif this.soldier and this.soldier.target_id == target.id then
                local d = E:create_entity("damage")

                if attack.instakill then
                    d.damage_type = DAMAGE_INSTAKILL
                elseif attack.fn_damage then
                    d.damage_type = attack.damage_type
                    d.value = attack.fn_damage(this, store, attack, target)
                else
                    d.damage_type = attack.damage_type
                    d.value = this.unit.damage_factor *
                        (math.random(attack.damage_min, attack.damage_max) + this.damage_buff)
                end

                d.source_id = this.id
                d.target_id = target.id
                d.xp_gain_factor = attack.xp_gain_factor
                d.xp_dest_id = attack.xp_dest_id
                d.pop = attack.pop
                d.pop_chance = attack.pop_chance
                d.pop_conds = attack.pop_conds

                queue_damage(store, d)
            end

            attack_done = true
        end

        while not U.animation_finished(this) do
            if this.unit.is_stunned then
                goto label_70_0
            end

            if this.health.dead or this.nav_rally and this.nav_rally.new then
                goto label_70_1
            end

            coroutine.yield()
        end
    end

    if attack.signal then
        signal.emit("soldier-attack", this, attack, attack.signal)
    end

    ::label_70_0::

    S:queue(attack.sound_end)

    if attack.animations[3] then
        an, af = U.animation_name_facing_point(this, attack.animations[3], target.pos)

        U.animation_start(this, an, af, store.tick_ts, 1)

        while not U.animation_finished(this) do
            if this.health.dead or this.nav_rally and this.nav_rally.new then
                break
            end

            coroutine.yield()
        end
    end

    ::label_70_1::

    S:stop(attack.sound)

    return attack_done
end
--- 判断士兵是否处于闪避状态
--- @param this table 士兵实体
--- @return boolean 是否闪避激活
local function dodge_active(this)
    return this.dodge and this.dodge.active
end

--- 士兵执行单次近战攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_soldier_do_single_melee_attack(store, this, target, attack)
    local attack_done = false
    local start_ts = store.tick_ts
    local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

    U.animation_start(this, an, af, store.tick_ts, 1)
    S:queue(attack.sound, attack.sound_args)

    while store.tick_ts - start_ts < attack.hit_time do
        if attack_interrupted(this, attack) or
            (not attack.ignore_rally_change and this.nav_rally and this.nav_rally.new) then
            goto label_72_0
        elseif dodge_active(this) then
            this.render.sprites[1].alpha = 128
        end

        coroutine.yield()
    end

    S:queue(attack.sound_hit, attack.sound_hit_args)

    attack.ts = start_ts

    if attack.shared_cooldown then
        for _, aa in pairs(this.melee.attacks) do
            if aa ~= attack and aa.shared_cooldown then
                aa.ts = attack.ts
            end
        end
    end

    if attack.forced_cooldown then
        this.melee.forced_ts = attack.ts
    end

    if attack.cooldown_group then
        for _, aa in pairs(this.melee.attacks) do
            if aa ~= attack and aa.cooldown_group == attack.cooldown_group then
                aa.ts = attack.ts
            end
        end
    end

    if attack.signal then
        signal.emit("soldier-attack", this, attack, attack.signal)
    end

    -- 要求攻击的敌人被这个士兵拦截
    if not unit_dodges(store, target, false, attack, this) and table.contains(target.enemy.blockers, this.id) then
        if attack.side_effect then
            attack.side_effect(this, store, attack, target)
        end

        if attack.damage_type ~= DAMAGE_NONE then
            local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id
            d.xp_gain_factor = attack.xp_gain_factor
            d.xp_dest_id = attack.xp_dest_id
            d.track_kills = this.track_kills ~= nil
            d.track_damage = attack.track_damage
            d.pop = attack.pop
            d.pop_chance = attack.pop_chance
            d.pop_conds = attack.pop_conds

            if attack.instakill then
                d.damage_type = DAMAGE_INSTAKILL
            elseif attack.fn_damage then
                d.damage_type = attack.damage_type
                d.value = attack.fn_damage(this, store, attack, target) + this.damage_buff
            elseif attack.damage_min then
                d.damage_type = attack.damage_type
                d.value = this.unit.damage_factor *
                    (math.random(attack.damage_min, attack.damage_max) + this.damage_buff)
            end

            queue_damage(store, d)
        end

        if attack.mod then
            local mod = E:create_entity(attack.mod)

            mod.modifier.ts = store.tick_ts
            mod.modifier.target_id = target.id
            mod.modifier.source_id = this.id
            mod.modifier.level = attack.level
            mod.modifier.damage_factor = this.unit.damage_factor
            queue_insert(store, mod)
        end

        if attack.mods then
            for _, m in pairs(attack.mods) do
                local mod = E:create_entity(m)

                mod.modifier.ts = store.tick_ts
                mod.modifier.target_id = target.id
                mod.modifier.source_id = this.id
                mod.modifier.level = attack.level
                mod.modifier.damage_factor = this.unit.damage_factor
                queue_insert(store, mod)
            end
        end

        local hit_pos = V.vclone(this.pos)

        if attack.hit_offset then
            hit_pos.x = hit_pos.x + (af and -1 or 1) * attack.hit_offset.x
            hit_pos.y = hit_pos.y + attack.hit_offset.y
        end

        if attack.hit_aura then
            local a = E:create_entity(attack.hit_aura)

            a.pos = V.vclone(hit_pos)
            a.aura.target_id = target.id
            a.aura.source_id = this.id

            queue_insert(store, a)
        end

        if attack.hit_fx then
            local fx = E:create_entity(attack.hit_fx)

            fx.pos = V.vclone(hit_pos)

            for i = 1, #fx.render.sprites do
                fx.render.sprites[i].ts = store.tick_ts
            end

            queue_insert(store, fx)
        end

        if attack.hit_decal then
            local fx = E:create_entity(attack.hit_decal)

            fx.pos = V.vclone(hit_pos)

            for i = 1, #fx.render.sprites do
                fx.render.sprites[i].ts = store.tick_ts
            end

            queue_insert(store, fx)
        end
    end

    if this.pickpocket and
        (not this.pickpocket.power_name or this.powers and this.powers[this.pickpocket.power_name].level > 0) and
        math.random() < this.pickpocket.chance then
        local pi = this.pickpocket

        if target.enemy and target.enemy.gold_bag > 0 then
            local q = km.clamp(0, target.enemy.gold_bag, math.floor(0.5 + U.frandom(pi.steal_min, pi.steal_max)))

            if q > 0 then
                S:queue(this.pickpocket.sound)
                signal.emit("soldier-pickpocket", this, q)
            end

            target.enemy.gold_bag = target.enemy.gold_bag - q
            store.player_gold = store.player_gold + q

            if pi.fx then
                local fx = E:create_entity(pi.fx)

                fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
            end
        end
    end

    attack_done = true

    while not U.animation_finished(this) do
        if attack_interrupted(this, attack) or
            (not attack.ignore_rally_change and this.nav_rally and this.nav_rally.new) then
            break
        elseif dodge_active(this) then
            this.render.sprites[1].alpha = 128
        end

        coroutine.yield()
    end

    ::label_72_0::

    S:stop(attack.sound)

    if dodge_active(this) and this.render.sprites[1].alpha == 128 then
        this.render.sprites[1].alpha = 255
        this.dodge.active = false
    end
    return attack_done
end
--- 士兵选择近战目标
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return table 目标实体
local function soldier_pick_melee_target(store, this)
    local target

    -- 选择 soldier.target_id 作为目标 id
    if U.blocker_rank(store, this) ~= nil then
        if not U.is_blocked_valid(store, this) then
            U.unblock_target(store, this)
        else
            target = store.entities[this.soldier.target_id]
        end
    end

    local center = this.nav_rally and this.nav_rally.center or this.pos

    if not target then
        -- 如果当前还没有 target_id，就索一下敌
        if this.hero then
            target = U.find_nearest_enemy(store, center, 0, this.melee.range, F_BLOCK, bit.bor(F_CLIFF),
                function(e)
                    return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and
                        band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and
                        (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e))
                end)
        else
            target = U.find_foremost_enemy(store, center, 0, this.melee.range, false, F_BLOCK,
                bit.bor(F_CLIFF), function(e)
                    return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and
                        band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and
                        (not this.melee.fn_can_pick or this.melee.fn_can_pick(this, e))
                end)
        end
    elseif U.blocker_rank(store, this) ~= 1 then
        -- 如果当前拦截的敌人被多个士兵拦截，就尝试寻找别的尚未被拦截的敌人作为目标
        local alt_target = U.find_foremost_enemy(store, center, 0, this.melee.range, false, F_BLOCK,
            bit.bor(F_FLYING, F_CLIFF), function(e)
                return #e.enemy.blockers == 0 and band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0
            end)

        if alt_target then
            target = alt_target
        end
    end

    return target
end

--- 士兵 block 目标，并移动到 melee_slot 对应位置
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param target table 目标实体
--- @return boolean 是否还在移动
local function soldier_move_to_slot_step(store, this, target)
    U.block_enemy(store, this, target)

    local slot_pos, slot_flip, enemy_flip = U.melee_slot_position(this, target)

    if not slot_pos then
        return true
    end

    if not (this.teleport and this.teleport.pending) and V.veq(slot_pos, this.pos) then
        this.motion.arrived = true

        return false
    else
        U.set_destination(this, slot_pos)

        local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

        U.animation_start(this, an, af, store.tick_ts, -1)

        if U.walk(this, store.tick_length) then
            local ani = this.melee and this.melee.arrived_slot_animation or "idle"

            an, af = U.animation_name_facing_point(this, ani, target.pos)

            U.animation_start(this, an, af, store.tick_ts, -1)
        end

        return true
    end
end

--- 士兵近战攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return table 攻击
local function soldier_pick_melee_attack(store, this, target)
    if this.dodge and this.dodge.counter_attack_pending then
        this.dodge.counter_attack_pending = false
        this.melee.last_attack = {
            target_id = target.id,
            attack = this.dodge.counter_attack
        }
        return this.dodge.counter_attack
    else
        for _, i in pairs(this.melee.order) do
            local a = this.melee.attacks[i]
            local cooldown = 0
            -- cooldown_factor: 全部近战攻击的冷却因子
            if a.cooldown then
                cooldown = a.cooldown * this.cooldown_factor
            end
            if this.melee.cooldown and a.shared_cooldown then
                cooldown = this.melee.cooldown * this.cooldown_factor
            end
            local forced_cooldown_ok = true
            if this.melee.forced_cooldown and a.forced_cooldown then
                forced_cooldown_ok = store.tick_ts - this.melee.forced_ts > this.melee.forced_cooldown
            end
            if not a.disabled and cooldown < store.tick_ts - a.ts and forced_cooldown_ok and
                band(a.vis_flags, target.vis.bans) == 0 and band(a.vis_bans, target.vis.flags) == 0 and
                (not a.fn_can or a.fn_can(this, store, a, target)) and
                (not a.not_first or this.melee.last_attack and this.melee.last_attack.target_id == target.id) then
                if not a.fn_chance and math.random() >= a.chance or a.fn_chance and
                    not a.fn_chance(this, store, a, target) then
                    a.ts = store.tick_ts
                else
                    if a.min_count and a.type == "area" and a.damage_radius then
                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                            a.vis_flags, a.vis_bans)
                        if not targets or #targets < a.min_count then
                            goto label_78_0
                        end
                    end
                    this.melee.last_attack = {
                        target_id = target.id,
                        attack = a
                    }
                    return a
                end
            end
            ::label_78_0::
        end
    end
    return nil
end

--- 敌人吸引源更新
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @return nil
local function y_enemy_update_attract_source(store, this)
    if this.enemy.attract_source_id then
        local attract_source = store.entities[this.enemy.attract_source_id]
        if not attract_source or attract_source.health.dead or
            not U.is_inside_ellipse(this.pos, attract_source.pos, attract_source.melee.range) then
            this.enemy.attract_source_id = nil
        end
    end
end

--- 士兵近战拦截与攻击流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否提前结束, number 状态码
local function y_soldier_melee_block_and_attacks(store, this)
    local target = soldier_pick_melee_target(store, this)
    if not target then
        if this.motion.arrived then
            U.y_wait(store, this.soldier.guard_time)
        end
        return false, A_NO_TARGET
    end
    if soldier_move_to_slot_step(store, this, target) then
        return true
    end
    local attack = soldier_pick_melee_attack(store, this, target)
    if not attack then
        return false, A_IN_COOLDOWN
    end
    if attack.xp_from_skill then
        hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
    end
    local attack_done
    if attack.loops then
        attack_done = y_soldier_do_loopable_melee_attack(store, this, target, attack)
    elseif attack.type == "area" then
        attack_done = y_soldier_do_single_area_attack(store, this, target, attack)
    else
        attack_done = y_soldier_do_single_melee_attack(store, this, target, attack)
    end
    if attack_done then
        return false, A_DONE
    else
        return true
    end
end

--- 士兵返回集结点
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return boolean 是否还在移动
local function soldier_go_back_step(store, this)
    local dest = this.nav_rally.pos
    if not (this.teleport and this.teleport.pending) and V.veq(this.pos, dest) then
        this.motion.arrived = true
        return false
    else
        U.set_destination(this, dest)
        if U.walk(this, store.tick_length) then
            return false
        else
            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
            U.animation_start(this, an, af, store.tick_ts, -1)
            return true
        end
    end
end

--- 士兵待机流程
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param force_ts number? 强制时间戳（可选）
--- @return nil
local function soldier_idle(store, this, force_ts)
    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)
    if this.unit.is_stunned then
        return
    end
    if store.tick_ts - this.idle_flip.ts > 2 * store.tick_length then
        this.idle_flip.ts_counter = 0
    end
    this.idle_flip.ts = store.tick_ts
    this.idle_flip.ts_counter = this.idle_flip.ts_counter + store.tick_length
    if this.idle_flip.ts_counter > this.idle_flip.cooldown then
        this.idle_flip.ts_counter = 0
        if math.random() < this.idle_flip.chance then
            this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
        end
        if this.idle_flip.animations then
            this.idle_flip.last_animation = table.random(this.idle_flip.animations)
        end
    end
end

--- 士兵回血
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return nil
local function soldier_regen(store, this)
    if not this.regen then
        return
    end
    if not this.regen.health then
        this.regen.health = math.ceil(this.health.hp_max * GS.soldier_regen_factor)
    end
    if store.tick_ts - this.regen.last_hit_ts > this.regen.last_hit_standoff_time then
        this.regen.ts_counter = this.regen.ts_counter + store.tick_length + this.soldier.guard_time
        if this.regen.ts_counter > this.regen.cooldown then
            if this.health.hp < this.health.hp_max then
                this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + this.regen.health)
                signal.emit("health-regen", this, this.regen.health)
            end
            this.regen.ts_counter = 0
        end
    end
end

--- 士兵技能升级
--- @param this table 士兵实体
--- @param power_name string 技能名称
--- @return nil
local function soldier_power_upgrade(this, power_name)
    local pn = power_name
    local pow = this.powers and this.powers[pn]
    if this.health.power_name == pn and this.health.hp_inc then
        this.health.hp_max = this.health.hp_max + this.health.hp_inc
        this.health.hp = this.health.hp_max
    end
    if this.health.armor_power_name == pn and this.health.armor_inc then
        armor_inc(this, this.health.armor_inc)
    end
    if this.ranged then
        for _, a in pairs(this.ranged.attacks) do
            if a.power_name == pn then
                a.level = a.level + 1
                if a.disabled then
                    a.disabled = nil
                end
                if a.cooldown_inc then
                    a.cooldown = a.cooldown + a.cooldown_inc
                end
                if a.range_inc then
                    a.max_range = a.max_range + a.range_inc
                end
                if a.chance_inc then
                    a.chance = a.chance + a.chance_inc
                end
            end
        end
    end
    if this.melee then
        local min_cooldown = 1e+99
        local cooldown_changed = false
        for _, a in pairs(this.melee.attacks) do
            if a.power_name == pn then
                a.level = a.level + 1
                if a.disabled then
                    a.disabled = nil
                end
                if a.chance_inc then
                    a.chance = a.chance + a.chance_inc
                    this.melee.order = U.attack_order(this.melee.attacks)
                end
                if a.damage_inc then
                    a.damage_min = a.damage_min + a.damage_inc
                    a.damage_max = a.damage_max + a.damage_inc
                end
                if a.damage_min_inc and a.damage_max_inc then
                    a.damage_min = a.damage_min + a.damage_min_inc
                    a.damage_max = a.damage_max + a.damage_max_inc
                end
                if a.cooldown_inc then
                    a.cooldown = a.cooldown + a.cooldown_inc
                    cooldown_changed = true
                end
            end
            if a.cooldown then
                min_cooldown = math.min(a.cooldown, min_cooldown)
            end
        end
        if cooldown_changed and this.melee.forced_cooldown and min_cooldown < this.melee.forced_cooldown then
            this.melee.forced_cooldown = min_cooldown
        end
    end
    if this.timed_actions then
        for _, a in pairs(this.timed_actions.list) do
            if a.power_name == pn then
                if a.level then
                    a.level = a.level + 1
                end
                if a.disabled then
                    a.disabled = nil
                end
            end
        end
    end
    if this.timed_attacks then
        for _, a in pairs(this.timed_attacks.list) do
            if a.power_name == pn then
                if a.level then
                    a.level = a.level + 1
                end
                if a.disabled then
                    a.disabled = nil
                end
            end
        end
    end
    if this.revive and this.revive.power_name == pn then
        this.revive.disabled = nil
        if this.revive.chance_inc then
            this.revive.chance = this.revive.chance + this.revive.chance_inc
        end
        if this.revive.health_recover then
            this.revive.health_recover = this.revive.health_recover + this.revive.health_recover_inc
        end
    end
    if this.dodge and this.dodge.power_name == pn then
        local d = this.dodge
        if d.chance_inc then
            d.chance = d.chance + d.chance_inc
        end
    end
    if this.dodge and this.dodge.counter_attack and this.dodge.counter_attack.power_name == pn then
        local d = this.dodge
        if d.counter_attack.damage_inc then
            d.counter_attack.damage_min = d.counter_attack.damage_min + d.counter_attack.damage_inc
            d.counter_attack.damage_max = d.counter_attack.damage_max + d.counter_attack.damage_inc
        end
    end
    if this.pickpocket and this.pickpocket.power_name == pn then
        local pi = this.pickpocket
        if pi.chance_inc then
            pi.chance = pi.chance + pi.chance_inc
        end
    end
    local fn = pow and pow.on_power_upgrade
    if fn then
        fn(this, power_name, pow)
    end
end

--- 士兵勇气升级
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @return nil
local function soldier_courage_upgrade(store, this)
    local upg = UP:get_upgrade("barrack_courage")
    if upg and this.soldier and this.health and store.tick_ts - this.soldier.courage_ts > upg.regen_cooldown then
        this.soldier.courage_ts = store.tick_ts
        this.health.hp = km.clamp(0, this.health.hp_max,
            km.round(this.health.hp + this.health.hp_max * upg.regen_factor))
    end
end

--- 判断敌人是否可被近战拦截
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param blocker table 士兵实体
--- @return boolean 是否可拦截
local function can_melee_blocker(store, this, blocker)
    return not this.health.dead and not this.unit.is_stunned and blocker and not blocker.health.dead and
        table.contains(this.enemy.blockers, blocker.id) and store.entities[blocker.id]
end

--- 判断敌人是否可被远程士兵攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param soldier table 士兵实体
--- @return boolean 是否可攻击
local function can_range_soldier(store, this, soldier)
    for _, ar in pairs(this.ranged.attacks) do
        if (ar.hold_advance or store.tick_ts - ar.ts > ar.cooldown) and not this.health.dead and
            not this.unit.is_stunned and not soldier.health.dead and store.entities[soldier.id] and
            band(soldier.vis.bans, ar.vis_flags) == 0 and band(soldier.vis.flags, ar.vis_bans) == 0 and
            U.is_inside_ellipse(soldier.pos, this.pos, ar.max_range) and
            (ar.min_range == 0 or not U.is_inside_ellipse(soldier.pos, this.pos, ar.min_range)) and
            (this.enemy.can_do_magic) then
            return true
        end
    end
    return false
end

--- 判断敌人是否被打断
--- @param this table 敌人实体
--- @return boolean 是否被打断
local function enemy_interrupted(this)
    return this.health.dead or this.unit.is_stunned
end

--- 敌人等待
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param time number 等待时间
--- @return boolean 是否提前结束
local function y_enemy_wait(store, this, time)
    return U.y_wait(store, time, function(store, time)
        return enemy_interrupted(this)
    end)
end

--- 敌人动画等待
--- @param this table 敌人实体
--- @return boolean 是否提前结束
local function y_enemy_animation_wait(this)
    while not U.animation_finished(this) do
        if enemy_interrupted(this) then
            return true
        end
        coroutine.yield()
    end
    return false
end

--- 敌人水域变化处理
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @return number 地形类型
local function enemy_water_change(store, this)
    local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
    local w = this.water
    if terrain_type ~= w.last_terrain_type then
        log.paranoid("terrain changed from %s to %s", w.last_terrain_type, terrain_type)
        if w.ignore_pi == this.nav_path.pi then
            log.debug("Enemy %s ignored path %s for water change", this.id, w.ignore_pi)
            w.last_terrain_type = terrain_type
            return
        end
        if w.last_terrain_type and bor(w.last_terrain_type, terrain_type) == bor(TERRAIN_WATER, TERRAIN_LAND) then
            local fx = E:create_entity("fx_enemy_splash")
            fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
            fx.render.sprites[1].ts = store.tick_ts
            fx.pos = V.vclone(this.pos)
            queue_insert(store, fx)
            if this.sound_events and this.sound_events.water_splash then
                S:queue(this.sound_events.water_splash)
            end
        end
        if terrain_type == TERRAIN_WATER then
            this.vis.flags = bor(this.vis.flags, F_WATER)
            w._orig_vis_bans = this.vis.bans
            this.vis.bans = bor(this.vis.bans, this.water.vis_bans)
            U.speed_mul_self(this, this.water.speed_factor)
            if this.health_bar then
                if this.water.health_bar_offset then
                    this.health_bar._orig_offset = this.health_bar.offset
                    this.health_bar.offset = this.water.health_bar_offset
                end
                if this.water.health_bar_hidden then
                    this.health_bar.hidden = true
                end
            end
            if this.water.hit_offset then
                this.unit._orig_hit_offset = this.unit.hit_offset
                this.unit.hit_offset = this.water.hit_offset
            end
            if this.water.mod_offset then
                this.unit._orig_mod_offset = this.unit.mod_offset
                this.unit.mod_offset = this.water.mod_offset
            end
            this.unit._orig_can_explode = this.unit.can_explode
            this.unit._orig_show_blood_pool = this.unit.show_blood_pool
            this.unit.can_explode = false
            this.unit.show_blood_pool = false
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]
                if not string.match(s.prefix, this.water.sprite_suffix .. "$") then
                    s.prefix = s.prefix .. this.water.sprite_suffix
                end
                s._orig_angles_flip_vertical = s.angles_flip_vertical
                s.angles_flip_vertical = this.water.angles_flip_vertical
            end
        elseif w.last_terrain_type == TERRAIN_WATER and terrain_type == TERRAIN_LAND then
            this.vis.flags = band(this.vis.flags, bnot(F_WATER))
            if w._orig_vis_bans then
                this.vis.bans = w._orig_vis_bans
            end
            U.speed_div_self(this, this.water.speed_factor)
            if this.water.health_bar_offset and this.health_bar._orig_offset then
                this.health_bar.offset = this.health_bar._orig_offset
            end
            if this.water.health_bar_hidden then
                this.health_bar.hidden = false
            end
            if this.water.hit_offset and this.unit._orig_hit_offset then
                this.unit.hit_offset = this.unit._orig_hit_offset
            end
            if this.water.mod_offset and this.unit._orig_mod_offset then
                this.unit.mod_offset = this.unit._orig_mod_offset
            end
            if this.unit._orig_can_explode then
                this.unit.can_explode = this.unit._orig_can_explode
            end
            if this.unit._orig_show_blood_pool then
                this.unit.show_blood_pool = this.unit._orig_show_blood_pool
            end
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]
                if string.match(s.prefix, this.water.sprite_suffix .. "$") then
                    s.prefix = string.gsub(s.prefix, this.water.sprite_suffix .. "$", "")
                end
                s.angles_flip_vertical = s._orig_angles_flip_vertical
            end
        end
        w.last_terrain_type = terrain_type
    end
    return terrain_type
end

--- 敌人悬崖变化处理
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @return number 地形类型
local function enemy_cliff_change(store, this)
    local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
    local c = this.cliff
    if terrain_type ~= c.last_terrain_type then
        if terrain_type == TERRAIN_CLIFF then
            local next_pos = P:next_entity_node(this, store.tick_length)
            if next_pos and next_pos.y < this.pos.y then
                local i, j = GR:get_coords(this.pos.x, this.pos.y)
                while j > 1 and bit.band(GR:get_cell(i, j), TERRAIN_CLIFF) ~= 0 do
                    j = j - 1
                end
                c.fall_to_pos = V.v(GR:cell_pos(i, j))
            else
                c.fall_to_pos = V.v(this.pos.x, this.pos.y)
            end
            this.vis.flags = bor(this.vis.flags, F_CLIFF)
            c._orig_vis_bans = this.vis.bans
            this.vis.bans = bor(this.vis.bans, c.vis_bans)
            U.speed_mul_self(this, c.speed_factor)
            this.health.dead_lifetime = 3
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]
                if c.hide_sprite_ids and table.contains(c.hide_sprite_ids, i) then
                    s.hidden = true
                else
                    s.z = Z_BACKGROUND_BETWEEN
                    if not string.match(s.prefix, c.sprite_suffix .. "$") then
                        s.prefix = s.prefix .. c.sprite_suffix
                    end
                end
            end
            this.health_bar.z = Z_BACKGROUND_BETWEEN + 1
        elseif c.last_terrain_type == TERRAIN_CLIFF and terrain_type == TERRAIN_LAND then
            this.vis.flags = band(this.vis.flags, bnot(F_CLIFF))
            this.vis.bans = c._orig_vis_bans
            U.speed_div_self(this, c.speed_factor)
            this.health.dead_lifetime = 2
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]
                if c.hide_sprite_ids and table.contains(c.hide_sprite_ids, i) then
                    s.hidden = false
                else
                    s.z = Z_OBJECTS
                    if string.match(s.prefix, c.sprite_suffix .. "$") then
                        s.prefix = string.gsub(s.prefix, c.sprite_suffix .. "$", "")
                    end
                end
            end
            this.health_bar.z = Z_OBJECTS
        end
        c.last_terrain_type = terrain_type
    end
    return terrain_type
end

--- 敌人死亡流程
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @return nil
local function y_enemy_death(store, this)
    local function show_blood_pool(e, terrain_type)
        if e.unit.show_blood_pool and e.unit.blood_color ~= BLOOD_NONE and band(terrain_type, TERRAIN_WATER) == 0 then
            local decal = E:create_entity("decal_blood_pool")
            decal.pos = V.vclone(e.pos)
            decal.render.sprites[1].ts = store.tick_ts
            decal.render.sprites[1].name = e.unit.blood_color
            decal.render.sprites[1].z = e.render.sprites[1].z
            decal.render.sprites[1].sort_y_offset = 1
            queue_insert(store, decal)
        end
    end
    local can_spawn = this.death_spawns and
        band(this.health.last_damage_types,
            bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, this.death_spawns.no_spawn_damage_types or 0)) == 0
    if can_spawn and this.death_spawns.concurrent_with_death then
        do_death_spawns(store, this)
        coroutine.yield()
        can_spawn = false
    end
    local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_TYPES_MASK)
    if (band(this.health.last_damage_types, bor(DAMAGE_EXPLOSION, DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_SHOT)) ~=
            0 and band(this.health.last_damage_types, bor(DAMAGE_FX_NOT_EXPLODE, DAMAGE_DISINTEGRATE)) == 0 and
            this.unit.can_explode) or (this.unit.explode_when_silenced_death and not this.enemy.can_do_magic) and
        this.unit.explode_fx and band(terrain_type, TERRAIN_WATER) == 0 then
        S:queue(this.sound_events.death_by_explosion)
        local fx = E:create_entity(this.unit.explode_fx)
        fx.pos = V.vclone(this.pos)
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
        queue_insert(store, fx)
        show_blood_pool(this, terrain_type)
        this.unit.hide_during_death = true
    elseif (band(this.health.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0 or
            this.unit.disintegrate_when_silenced_death and not this.enemy.can_do_magic) and this.unit.can_disintegrate and
        this.unit.disintegrate_fx then
        local fx = E:create_entity(this.unit.disintegrate_fx)
        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts
        if fx.render.sprites[1].size_names then
            fx.render.sprites[1].name = fx.render.sprites[1].size_names[this.unit.size]
        end
        if band(this.vis.flags, F_FLYING) ~= 0 and this.unit.hit_offset then
            fx.render.sprites[1].offset.y = this.unit.hit_offset.y
        end
        queue_insert(store, fx)
        this.unit.hide_during_death = true
        this.unit.show_blood_pool = false
    elseif band(this.health.last_damage_types, bor(DAMAGE_EAT)) ~= 0 then
        this.unit.hide_during_death = true
        this.unit.show_blood_pool = false
    elseif band(terrain_type, TERRAIN_CLIFF) ~= 0 and band(this.vis.flags, F_FLYING) == 0 then
        S:queue("WilhemScream")
        S:queue(this.sound_events.death, this.sound_events.death_args)
        U.animation_start(this, "fall", nil, store.tick_ts, true)
        U.set_destination(this, this.cliff.fall_to_pos)
        while not U.walk(this, store.tick_length, this.cliff.fall_accel) do
            coroutine.yield()
        end
        show_blood_pool(this, terrain_type)
        U.y_animation_play(this, "death", nil, store.tick_ts, 1)
    elseif band(terrain_type, TERRAIN_WATER) ~= 0 and band(this.vis.flags, F_FLYING) == 0 then
        S:queue(this.sound_events.death_water, this.sound_events.death_water_args)
        U.y_animation_play(this, this.unit.death_animation, nil, store.tick_ts, 1)
    elseif this.unit.death_animation then
        S:queue(this.sound_events.death, this.sound_events.death_args)
        show_blood_pool(this, terrain_type)
        U.animation_start(this, this.unit.death_animation, nil, store.tick_ts, false)
        if can_spawn and this.death_spawns.delay then
            U.y_wait(store, this.death_spawns.delay)
            do_death_spawns(store, this)
            can_spawn = false
        end
        while not U.animation_finished(this) do
            coroutine.yield()
        end
    end
    if can_spawn then
        do_death_spawns(store, this)
        coroutine.yield()
        can_spawn = false
    end
    if this.unit.hide_during_death or this.unit.hide_after_death then
        for _, s in pairs(this.render.sprites) do
            s.hidden = true
        end
    end
    if this.ui then
        this.ui.can_click = not this.unit.hide_after_death and not this.unit.hide_during_death
        this.ui.z = -1
    end
    if this.unit.fade_time_after_death then
        fade_out_entity(store, this, this.unit.fade_time_after_death)
    end
end

--- 敌人行走一步
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param animation_name string? 动画名称（可选）
--- @param sprite_id number? 精灵ID（可选）
--- @return boolean 是否继续行走
local function y_enemy_walk_step(store, this, animation_name, sprite_id)
    animation_name = animation_name or "walk"
    local next, new, use_path
    if this.motion.forced_waypoint then
        local w = this.motion.forced_waypoint
        next = w
        if V.dist(w.x, w.y, this.pos.x, this.pos.y) < 2 * this.motion.real_speed * store.tick_length then
            this.pos.x, this.pos.y = w.x, w.y
            this.motion.forced_waypoint = nil
            return false
        end
    else
        use_path = true
        next, new = P:next_entity_node(this, store.tick_length)
        if not next then
            log.debug("enemy %s ran out of nodes to walk", this.id)
            coroutine.yield()
            return false
        end
    end
    U.set_destination(this, next)
    local an, af = U.animation_name_facing_point(this, animation_name, this.motion.dest, sprite_id, nil, use_path)
    if this.sound_events and new then
        S:queue(this.sound_events.new_node, this.sound_events.new_node_args)
    end
    U.animation_start(this, an, af, store.tick_ts, true, sprite_id)
    U.walk(this, store.tick_length)
    coroutine.yield()
    this.motion.speed.x, this.motion.speed.y = 0, 0
    return true
end

--- 敌人行走直到被拦截
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param ignore_soldiers boolean 是否忽略士兵
--- @param func function? 额外判断函数（可选）
--- @return boolean 是否继续, table 拦截者, table 远程目标
local function y_enemy_walk_until_blocked(store, this, ignore_soldiers, func)
    local ranged, blocker
    local terrain_type = band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND))
    -- 无视士兵，或者没被拦截，且没有远程攻击属性时，敌人首先尝试远程索敌。如果远程攻击是 hold_advance 的，说明敌人会站桩攻击，于是停下，返回 true, nil, ranged
    -- 接着，如果不无视士兵，且 blockers 不为空，清除其中已经被删除的 blocker。
    -- 如果没有远程攻击，也没有 blocker，敌人继续走路。
    -- 否则，敌人呆在原地不动。
    while ignore_soldiers or not blocker and not ranged do
        if this.unit.is_stunned then
            return false
        end
        if func and func(store, this) then
            return false, nil, nil
        end
        if this.health.dead then
            return false
        end
        local node_valid = P:is_node_valid(this.nav_path.pi, this.nav_path.ni)
        if node_valid and not ignore_soldiers and this.ranged then
            for _, a in pairs(this.ranged.attacks) do
                if not a.disabled and (this.enemy.can_do_magic) and
                    (a.hold_advance or store.tick_ts - a.ts > a.cooldown) then
                    ranged = U.find_nearest_soldier(store.soldiers, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)
                    if ranged ~= nil then
                        break
                    end
                end
            end
        end
        if node_valid and not ignore_soldiers and #this.enemy.blockers > 0 then
            U.cleanup_blockers(store, this)
            blocker = store.entities[this.enemy.blockers[1]]
        end
        if ignore_soldiers or not blocker and not ranged then
            y_enemy_walk_step(store, this)
        else
            U.animation_start(this, "idle", nil, store.tick_ts, true)
        end
        if terrain_type ~= band(GR:cell_type(this.pos.x, this.pos.y), bor(TERRAIN_WATER, TERRAIN_LAND)) then
            return false, nil, nil
        end
    end
    return true, blocker, ranged
end

--- 士兵等待拦截者
--- @param store table 游戏存储对象 game.store
--- @param this table 士兵实体
--- @param blocker table 拦截者
--- @return boolean 是否等待成功
local function y_wait_for_blocker(store, this, blocker)
    local pos = blocker.motion.arrived and blocker.pos or blocker.motion.dest
    local an, af = U.animation_name_facing_point(this, "idle", pos)
    U.animation_start(this, an, af, store.tick_ts, true)
    while not blocker.motion.arrived do
        coroutine.yield()
        if this.health.dead or this.unit.is_stunned or not table.contains(this.enemy.blockers, blocker.id) or
            blocker.health.dead or not store.entities[blocker.id] then
            return false
        end
        if blocker.unit.is_stunned then
            blocker.soldier.target_id = nil
            U.dec_blocker(store, this, blocker.id)
            return false
        end
    end
    return true
end

--- 敌人远程攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param target table 士兵实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_enemy_do_ranged_attack(store, this, target, attack)
    local an, af, ai = U.animation_name_facing_point(this, attack.animation, target.pos)
    U.animation_start(this, an, af, store.tick_ts, false)
    while store.tick_ts - attack.ts < attack.shoot_time do
        if this.health.dead or this.unit.is_stunned and not attack.ignore_stun then
            return false
        end
        coroutine.yield()
    end
    local targets
    local target_num = 1
    if attack.multi_num then
        targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, attack.max_range, attack.vis_flags,
            attack.vis_bans)
        if targets and #targets < attack.multi_num then
            target_num = #targets
        end
    else
        targets = { target }
    end
    if targets then
        for index, target in pairs(targets) do
            if index > target_num then
                break
            end
            if band(target.vis.bans, attack.vis_flags) == 0 and band(target.vis.flags, attack.vis_bans) == 0 then
                local bullet = E:create_entity(attack.bullet)
                bullet.pos = V.vclone(this.pos)
                if attack.bullet_start_offset then
                    local offset = attack.bullet_start_offset[ai]
                    bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
                end
                bullet.bullet.from = V.vclone(bullet.pos)
                bullet.bullet.to = V.vclone(target.pos)
                if not attack.ignore_hit_offset then
                    bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
                    bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
                end
                bullet.bullet.target_id = target.id
                bullet.bullet.damage_factor = this.unit.damage_factor
                if attack.damage_factor then
                    bullet.bullet.damage_factor = bullet.bullet.damage_factor * attack.damage_factor
                end
                queue_insert(store, bullet)
            end
        end
    end
    while not U.animation_finished(this) do
        if this.health.dead or this.unit.is_stunned and not attack.ignore_stun then
            return false
        end
        coroutine.yield()
    end
    U.animation_start(this, "idle", nil, store.tick_ts, true)
    return true
end

--- 敌人循环远程攻击
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param target table 士兵实体
--- @param attack table 攻击对象
--- @return boolean 是否攻击完成
local function y_enemy_do_loopable_ranged_attack(store, this, target, attack)
    local attack_done = false
    local b
    S:queue(attack.sound)
    local an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)
    U.y_animation_play(this, an, af, store.tick_ts, 1)
    for i = 1, attack.loops do
        an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)
        U.animation_start(this, an, af, store.tick_ts, false)
        local shoot_times = attack.shoot_times or { attack.shoot_time }
        for si, st in pairs(shoot_times) do
            while st > store.tick_ts - this.render.sprites[1].ts do
                if this.unit.is_stunned and not attack.ignore_stun then
                    goto label_99_0
                end
                if this.health.dead then
                    goto label_99_1
                end
                coroutine.yield()
            end
            b = E:create_entity(attack.bullet)
            b.pos = V.vclone(this.pos)
            if attack.bullet_start_offset then
                local offset = attack.bullet_start_offset[ai]
                b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
            end
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            b.bullet.target_id = target.id
            b.bullet.source_id = this.id
            if attack.damage_factor then
                b.bullet.damage_factor = b.bullet.damage_factor * attack.damage_factor
            end
            queue_insert(store, b)
            attack_done = true
        end
        while not U.animation_finished(this) do
            if this.unit.is_stunned and not attack.ignore_stun then
                goto label_99_0
            end
            if this.health.dead then
                goto label_99_1
            end
            coroutine.yield()
        end
    end
    ::label_99_0::
    an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)
    U.animation_start(this, an, af, store.tick_ts, 1)
    while not U.animation_finished(this) do
        if this.health.dead then
            break
        end
        coroutine.yield()
    end
    ::label_99_1::
    return attack_done
end

--- 敌人远程攻击流程
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param target table 士兵实体
--- @return boolean 是否攻击完成
local function y_enemy_range_attacks(store, this, target)
    for _, i in ipairs(this.ranged.order) do
        local ar = this.ranged.attacks[i]
        local cooldown = ar.cooldown
        if this.ranged.cooldown and ar.shared_cooldown then
            cooldown = this.ranged.cooldown
        end
        if not ar.disabled and cooldown <= store.tick_ts - ar.ts and band(ar.vis_flags, target.vis.bans) == 0 and
            band(ar.vis_bans, target.vis.flags) == 0 and (not ar.sync_animation or this.render.sprites[1].sync_flag) then
            ar.ts = store.tick_ts
            if math.random() >= ar.chance then
                -- block empty
            else
                for _, aa in pairs(this.ranged.attacks) do
                    if aa ~= ar and aa.shared_cooldown then
                        aa.ts = ar.ts
                    end
                end
                local attack_done
                if ar.loops then
                    attack_done = y_enemy_do_loopable_ranged_attack(store, this, target, ar)
                else
                    attack_done = y_enemy_do_ranged_attack(store, this, target, ar)
                end
                return attack_done
            end
        end
    end
    return true
end

--- 敌人近战攻击流程
--- @param store table 游戏存储对象 game.store
--- @param this table 敌人实体
--- @param target table 士兵实体
--- @return boolean 是否攻击完成
local function y_enemy_melee_attacks(store, this, target)
    for _, i in ipairs(this.melee.order) do
        local ma = this.melee.attacks[i]
        local cooldown = ma.cooldown
        if ma.shared_cooldown then
            cooldown = this.melee.cooldown
        end
        if not ma.disabled and cooldown <= store.tick_ts - ma.ts and band(ma.vis_flags, target.vis.bans) == 0 and
            band(ma.vis_bans, target.vis.flags) == 0 and (not ma.fn_can or ma.fn_can(this, store, ma, target)) then
            ma.ts = store.tick_ts
            if math.random() >= ma.chance then
                -- block empty
            else
                log.paranoid("attack %i selected for entity %s", i, this.template_name)
                for _, aa in pairs(this.melee.attacks) do
                    if aa ~= ma and aa.shared_cooldown then
                        aa.ts = ma.ts
                    end
                end
                ma.ts = store.tick_ts
                S:queue(ma.sound, ma.sound_args)
                local an, af = U.animation_name_facing_point(this, ma.animation, target.pos)
                for i = 1, #this.render.sprites do
                    if this.render.sprites[i].animated then
                        U.animation_start(this, an, af, store.tick_ts, 1, i)
                    end
                end
                local hit_pos = V.vclone(this.pos)
                if ma.hit_offset then
                    hit_pos.x = hit_pos.x + (af and -1 or 1) * ma.hit_offset.x
                    hit_pos.y = hit_pos.y + ma.hit_offset.y
                end
                local hit_times = ma.hit_times and ma.hit_times or { ma.hit_time }
                for i = 1, #hit_times do
                    local hit_time = hit_times[i]
                    local dodged = false
                    if ma.dodge_time and target.dodge then
                        local dodge_time = ma.dodge_time
                        if target.dodge and target.dodge.time_before_hit then
                            dodge_time = hit_time - target.dodge.time_before_hit
                        end
                        while dodge_time > store.tick_ts - ma.ts do
                            if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and
                                this.dodge.active and not this.dodge.silent then
                                return false
                            end
                            coroutine.yield()
                        end
                        dodged = unit_dodges(store, target, false, ma, this)
                    end
                    while hit_time > store.tick_ts - ma.ts do
                        if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and
                            this.dodge.active and not this.dodge.silent then
                            return false
                        end

                        coroutine.yield()
                    end

                    S:queue(ma.sound_hit, ma.sound_hit_args)

                    if ma.type == "melee" and not dodged and table.contains(this.enemy.blockers, target.id) then
                        if ma.side_effect then
                            ma.side_effect(this, store, ma, target)
                        end
                        local d = E:create_entity("damage")

                        d.source_id = this.id
                        d.target_id = target.id
                        d.track_kills = this.track_kills ~= nil
                        d.track_damage = ma.track_damage
                        d.pop = ma.pop
                        d.pop_chance = ma.pop_chance
                        d.pop_conds = ma.pop_conds

                        if ma.instakill then
                            d.damage_type = DAMAGE_INSTAKILL

                            queue_damage(store, d)
                        elseif ma.damage_min then
                            d.damage_type = ma.damage_type
                            d.value = this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)

                            queue_damage(store, d)
                        end

                        if ma.mod then
                            local mod = E:create_entity(ma.mod)

                            mod.modifier.target_id = target.id
                            mod.modifier.source_id = this.id

                            queue_insert(store, mod)
                        end
                    elseif ma.type == "area" then
                        if ma.side_effect then
                            ma.side_effect(this, store, ma, target)
                        end
                        local targets = table.filter(store.soldiers, function(_, e)
                            return not e.health.dead and
                                       band(e.vis.flags, ma.vis_bans) == 0 and band(e.vis.bans, ma.vis_flags) == 0 and
                                       U.is_inside_ellipse(e.pos, hit_pos, ma.damage_radius) and
                                       (not ma.fn_filter or ma.fn_filter(this, store, ma, e))
                        end)

                        for i, e in ipairs(targets) do
                            if e == target and dodged then
                                -- block empty
                            else
                                if ma.count and i > ma.count then
                                    break
                                end

                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = e.id
                                d.damage_type = ma.damage_type
                                d.value = this.unit.damage_factor * math.random(ma.damage_min, ma.damage_max)
                                d.pop = ma.pop
                                d.pop_chance = ma.pop_chance
                                d.pop_conds = ma.pop_conds

                                queue_damage(store, d)

                                if ma.mod then
                                    local mod = E:create_entity(ma.mod)

                                    mod.modifier.target_id = e.id
                                    mod.modifier.source_id = this.id

                                    queue_insert(store, mod)
                                end
                            end
                        end
                    end

                    if ma.hit_fx and (not ma.hit_fx_once or i == 1) then
                        local fx = E:create_entity(ma.hit_fx)

                        fx.pos = V.vclone(hit_pos)

                        if ma.hit_fx_offset then
                            fx.pos.x = fx.pos.x + (af and -1 or 1) * ma.hit_fx_offset.x
                            fx.pos.y = fx.pos.y + ma.hit_fx_offset.y
                        end

                        if ma.hit_fx_flip then
                            fx.render.sprites[1].flip_x = af
                        end

                        fx.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, fx)
                    end

                    if ma.hit_decal then
                        local fx = E:create_entity(ma.hit_decal)

                        fx.pos = V.vclone(hit_pos)
                        fx.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, fx)
                    end
                end

                while not U.animation_finished(this) do
                    if this.health.dead or ma.ignore_stun and this.unit.is_stunned or this.dodge and this.dodge.active and
                        not this.dodge.silent then
                        return false
                    end

                    coroutine.yield()
                end

                U.animation_start(this, "idle", nil, store.tick_ts, true)

                return true
            end
        end
    end

    return true
end

local function y_enemy_stun(store, this)
    local flip_x = this.motion and this.motion.dest.x < this.pos.x or nil

    U.animation_start(this, "idle", flip_x, store.tick_ts, true)
    coroutine.yield()
end

local function y_enemy_mixed_walk_melee_ranged(store, this, ignore_soldiers, walk_break_fn, melee_break_fn,
    ranged_break_fn)
    ranged_break_fn = ranged_break_fn or melee_break_fn

    local cont, blocker, ranged = y_enemy_walk_until_blocked(store, this, ignore_soldiers, walk_break_fn)

    if not cont then
        return false
    end

    if blocker then
        if not y_wait_for_blocker(store, this, blocker) then
            return false
        end

        while can_melee_blocker(store, this, blocker) and (not melee_break_fn or not melee_break_fn(store, this)) do
            if not y_enemy_melee_attacks(store, this, blocker) then
                return false
            end

            coroutine.yield()
        end
    elseif ranged then
        while can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and
            (not ranged_break_fn or not ranged_break_fn(store, this)) do
            if not y_enemy_range_attacks(store, this, ranged) then
                return false
            end

            coroutine.yield()
        end
    end

    return true
end

local function y_show_taunt_set(store, taunts, set_name, index, pos, duration, wait, decal)
    local set = taunts.sets[set_name]

    index = index or set.idxs and table.random(set.idxs) or math.random(set.start_idx, set.end_idx)
    duration = duration or taunts.duration
    pos = pos or set.pos or taunts.pos

    local offset = set.offset or taunts.offset or v(0, 0)
    local t = E:create_entity(decal or set.decal_name or taunts.decal_name)

    t.texts.list[1].text = _(string.format(set.format, index))
    t.pos.x, t.pos.y = pos.x + offset.x, pos.y + offset.y
    t.tween.ts = store.tick_ts
    t.duration = duration
    t.start_ts = store.tick_ts

    queue_insert(store, t)

    if wait then
        U.y_wait(store, duration)
    end

    return t
end

local function y_spawner_spawn(store, this)
    local sp = this.spawner

    sp._last_subpath = sp._last_subpath or math.random(1, 3)

    local spawns = {}

    for i = 1, sp.count do
        if sp.interrupt then
            return true, spawns
        end

        local spawn = E:create_entity(sp.entity)

        spawn.nav_path.pi = sp.pi

        if sp.random_subpath then
            spawn.nav_path.spi = sp.allowed_subpaths[math.random(1, #sp.allowed_subpaths)]
        else
            sp._last_subpath = km.zmod(sp._last_subpath + 1, #sp.allowed_subpaths)
            spawn.nav_path.spi = sp.allowed_subpaths[sp._last_subpath]
        end

        if sp.forced_waypoint_offset then
            spawn.motion.forced_waypoint = V.v(this.pos.x + sp.forced_waypoint_offset.x,
                this.pos.y + sp.forced_waypoint_offset.y)
        elseif sp.forced_waypoint then
            spawn.motion.forced_waypoint = V.v(sp.forced_waypoint.x, sp.forced_waypoint.y)
        end

        if spawn.motion.forced_waypoint then
            local fw = spawn.motion.forced_waypoint
            local pis = P:get_connected_paths(sp.pi)
            local nodes = P:nearest_nodes(fw.x, fw.y, pis, {spawn.nav_path.spi}, true)

            if #nodes < 1 then
                log.error("(%s) could not find point to spawn near %s,%s", this.id, fw.x, fw.y)
            else
                spawn.nav_path.pi = nodes[1][1]
                spawn.nav_path.ni = nodes[1][3] + sp.node_offset
            end
        else
            spawn.nav_path.ni = sp.ni + sp.node_offset
            spawn.motion.forced_waypoint = P:node_pos(spawn.nav_path)
        end

        spawn.pos.x, spawn.pos.y = this.pos.x + sp.pos_offset.x, this.pos.y + sp.pos_offset.y
        spawn.render.sprites[1].name = sp.initial_spawn_animation
        spawn.unit.spawner_id = this.id

        if sp.patch_props then
            spawn = table.deepmerge(spawn, sp.patch_props)
        end

        queue_insert(store, spawn)
        table.insert(spawns, spawn)

        local spawn_ts = store.tick_ts

        while store.tick_ts - spawn_ts < sp.cycle_time do
            if sp.interrupt then
                return true, spawns
            end

            coroutine.yield()
        end
    end

    return false, spawns
end

local function merge_tables(t1, t2)
    local merged = {}

    -- 遍历 t1 的所有键值对
    for key, value in pairs(t1) do
        if t2[key] then
            -- 如果 t2 中也有相同的键，并且值是表
            if type(value) == "table" and type(t2[key]) == "table" then
                -- 如果是数组（所有键是连续的数字），合并数组
                if #value > 0 and #t2[key] > 0 then
                    local set = {}
                    for _, v in ipairs(value) do
                        set[v] = true
                    end
                    for _, v in ipairs(t2[key]) do
                        set[v] = true
                    end
                    merged[key] = {}
                    for v, _ in pairs(set) do
                        table.insert(merged[key], v)
                    end
                else
                    -- 否则递归合并
                    merged[key] = merge_tables(value, t2[key])
                end
            else
                -- 如果不是表，优先保留 t1 的值
                merged[key] = value
            end
        else
            -- 如果 t2 中没有这个键，直接保留 t1 的值
            merged[key] = value
        end
    end

    -- 遍历 t2 的所有键值对，添加 t1 中没有的键
    for key, value in pairs(t2) do
        if not t1[key] then
            merged[key] = value
        end
    end

    return merged
end

local function merge_conflict_tables(t1, t2)
    local merged = {}

    -- 遍历 t1 的所有键值对
    for key, value in pairs(t1) do
        merged[key] = value
    end

    -- 遍历 t2 的所有键值对，添加 t1 中没有的键
    for key, value in pairs(t2) do
        if not t1[key] then
            merged[key] = value
        end
    end

    return merged
end

-- 乘算
local function insert_tower_range_buff(target, range_factor, allow_barrack)
    if not target then
        return
    end

    if target.attacks and target.attacks.range then
        target.attacks.range = target.attacks.range * range_factor
    end
    if target.template_name == "tower_mech" then
        for _, s in ipairs(target.barrack.soldiers) do
            s.attacks.list[1].max_range = s.attacks.list[1].max_range * range_factor
            s.attacks.list[2].max_range = s.attacks.list[2].max_range * range_factor
        end
    end
    if allow_barrack and target.barrack then
        target.barrack.rally_range = target.barrack.rally_range * range_factor
    end

end

-- 乘算
local function insert_tower_cooldown_buff(target, cooldown_factor)
    if not target then
        return
    end

    target.tower.cooldown_factor = target.tower.cooldown_factor * cooldown_factor
    if target.barrack then
        for _, s in pairs(target.barrack.soldiers) do
            if s.unit then
                s.cooldown_factor = s.cooldown_factor * cooldown_factor
            end
        end
    end

end

local function remove_tower_range_buff(target, range_factor, allow_barrack)
    if not target then
        return
    end
    if target.attacks and target.attacks.range then
        target.attacks.range = target.attacks.range / range_factor
    end
    if target.template_name == "tower_mech" then
        for _, s in ipairs(target.barrack.soldiers) do
            s.attacks.list[1].max_range = s.attacks.list[1].max_range / range_factor
            s.attacks.list[2].max_range = s.attacks.list[2].max_range / range_factor
        end
    end
    if allow_barrack and target.barrack then
        target.barrack.rally_range = target.barrack.rally_range / range_factor
    end
end

local function remove_tower_cooldown_buff(target, cooldown_factor)
    if not target then
        return
    end
    target.tower.cooldown_factor = target.tower.cooldown_factor / cooldown_factor
    if target.barrack then
        for _, s in pairs(target.barrack.soldiers) do
            if s.unit then
                s.cooldown_factor = s.cooldown_factor / cooldown_factor
            end
        end
    end

end

local function insert_tower_damage_factor_buff(target, damage_factor)
    if not target then
        return
    end
    target.tower.damage_factor = target.tower.damage_factor + damage_factor
    if target.barrack then
        for _, s in pairs(target.barrack.soldiers) do
            if s.unit then
                s.unit.damage_factor = s.unit.damage_factor + damage_factor
            end
        end
    end
end

local function remove_tower_damage_factor_buff(target, damage_factor)
    if not target then
        return
    end
    target.tower.damage_factor = target.tower.damage_factor - damage_factor
    if target.barrack then
        for _, s in pairs(target.barrack.soldiers) do
            if s.unit then
                s.unit.damage_factor = s.unit.damage_factor - damage_factor
            end
        end
    end
end

local function y_controable_new_rally(store, this)
    local r = this.nav_rally

    if r.new then
        r.new = false

        U.unblock_target(store, this)

        if this.sound_events then
            S:queue(this.sound_events.change_rally_point)
        end

        local vis_bans = this.vis.bans
        local prev_immune = this.health.immune_to

        this.vis.bans = F_ALL
        this.health.immune_to = r.immune_to

        local out = y_hero_walk_waypoints(store, this)

        U.animation_start(this, "idle", nil, store.tick_ts, true)

        this.vis.bans = vis_bans
        this.health.immune_to = prev_immune

        return out
    end
end

local function update_on_damage(entity)
    entity.health.on_damage = function(this, store, damage)
        if #entity.health.on_damages == 0 then
            return true
        end
        local pass = false
        for _, on_damage in pairs(entity.health.on_damages) do
            pass = on_damage(this, store, damage)
            if not pass then
                return false
            end
        end
        return pass
    end
end

-- 开局重置英雄的技能冷却时间
---@param this table 实体
---@param store game.store
---@return nil
local function hero_spawning_set_skill_ts(this, store)
    if this.melee then
        for _, v in ipairs(this.melee.attacks) do
            if not v.disabled then
                v.ts = store.tick_ts - v.cooldown
            end
        end
    end
    if this.ranged then
        for _, v in ipairs(this.ranged.attacks) do
            if not v.disabled then
                v.ts = store.tick_ts - v.cooldown
            end
        end
    end
    if this.timed_attacks then
        for _, v in ipairs(this.timed_attacks.list) do
            if not v.disabled then
                v.ts = store.tick_ts - v.cooldown
            end
        end
    end
end

local SU = {
    has_modifiers = U.has_modifiers,
    ui_click_proxy_add = ui_click_proxy_add,
    ui_click_proxy_remove = ui_click_proxy_remove,
    remove_modifiers = remove_modifiers,
    remove_modifiers_by_type = remove_modifiers_by_type,
    remove_auras = remove_auras,
    hide_modifiers = hide_modifiers,
    show_modifiers = show_modifiers,
    hide_auras = hide_auras,
    show_auras = show_auras,
    unit_dodges = unit_dodges,
    stun_inc = stun_inc,
    stun_dec = stun_dec,
    update_armor = update_armor,
    update_magic_armor = update_magic_armor,
    armor_inc = armor_inc,
    armor_dec = armor_dec,
    magic_armor_inc = magic_armor_inc,
    magic_armor_dec = magic_armor_dec,
    spiked_armor_inc = spiked_armor_inc,
    spiked_armor_dec = spiked_armor_dec,
    tower_block_inc = tower_block_inc,
    tower_block_dec = tower_block_dec,
    tower_update_silenced_powers = tower_update_silenced_powers,
    do_death_spawns = do_death_spawns,
    delay_attack = delay_attack,
    insert_sprite = insert_sprite,
    fade_out_entity = fade_out_entity,
    create_pop = create_pop,
    create_bullet_pop = create_bullet_pop,
    create_bullet_damage = create_bullet_damage,
    create_attack_damage = create_attack_damage,
    initial_parabola_speed = initial_parabola_speed,
    position_in_parabola = position_in_parabola,
    parabola_y = parabola_y,
    y_hero_wait = y_soldier_wait,
    y_soldier_wait = y_soldier_wait,
    y_hero_animation_wait = y_soldier_animation_wait,
    y_soldier_animation_wait = y_soldier_animation_wait,
    hero_interrupted = soldier_interrupted,
    soldier_interrupted = soldier_interrupted,
    hero_will_teleport = hero_will_teleport,
    hero_will_transfer = hero_will_transfer,
    y_hero_walk_waypoints = y_hero_walk_waypoints,
    y_hero_new_rally = y_hero_new_rally,
    hero_gain_xp_from_skill = hero_gain_xp_from_skill,
    hero_gain_xp = hero_gain_xp,
    hero_level_up = hero_level_up,
    y_hero_death_and_respawn = y_hero_death_and_respawn,
    y_reinforcement_fade_in = y_reinforcement_fade_in,
    y_reinforcement_fade_out = y_reinforcement_fade_out,
    y_soldier_new_rally = y_soldier_new_rally,
    y_soldier_revive = y_soldier_revive,
    y_soldier_death = y_soldier_death,
    y_soldier_do_loopable_ranged_attack = y_soldier_do_loopable_ranged_attack,
    y_soldier_do_ranged_attack = y_soldier_do_ranged_attack,
    soldier_pick_ranged_target_and_attack = soldier_pick_ranged_target_and_attack,
    y_soldier_ranged_attacks = y_soldier_ranged_attacks,
    y_soldier_do_timed_action = y_soldier_do_timed_action,
    y_soldier_timed_actions = y_soldier_timed_actions,
    y_soldier_do_timed_attack = y_soldier_do_timed_attack,
    y_soldier_timed_attacks = y_soldier_timed_attacks,
    y_soldier_do_single_area_attack = y_soldier_do_single_area_attack,
    y_soldier_do_loopable_melee_attack = y_soldier_do_loopable_melee_attack,
    y_soldier_do_single_melee_attack = y_soldier_do_single_melee_attack,
    soldier_pick_melee_target = soldier_pick_melee_target,
    soldier_move_to_slot_step = soldier_move_to_slot_step,
    soldier_pick_melee_attack = soldier_pick_melee_attack,
    y_soldier_melee_block_and_attacks = y_soldier_melee_block_and_attacks,
    soldier_go_back_step = soldier_go_back_step,
    soldier_idle = soldier_idle,
    soldier_regen = soldier_regen,
    soldier_power_upgrade = soldier_power_upgrade,
    soldier_courage_upgrade = soldier_courage_upgrade,
    can_melee_blocker = can_melee_blocker,
    can_range_soldier = can_range_soldier,
    enemy_interrupted = enemy_interrupted,
    y_enemy_wait = y_enemy_wait,
    y_enemy_animation_wait = y_enemy_animation_wait,
    enemy_water_change = enemy_water_change,
    enemy_cliff_change = enemy_cliff_change,
    y_enemy_death = y_enemy_death,
    y_enemy_walk_step = y_enemy_walk_step,
    y_enemy_walk_until_blocked = y_enemy_walk_until_blocked,
    y_wait_for_blocker = y_wait_for_blocker,
    y_enemy_do_ranged_attack = y_enemy_do_ranged_attack,
    y_enemy_do_loopable_ranged_attack = y_enemy_do_loopable_ranged_attack,
    y_enemy_range_attacks = y_enemy_range_attacks,
    y_enemy_melee_attacks = y_enemy_melee_attacks,
    y_enemy_stun = y_enemy_stun,
    y_enemy_mixed_walk_melee_ranged = y_enemy_mixed_walk_melee_ranged,
    y_show_taunt_set = y_show_taunt_set,
    y_spawner_spawn = y_spawner_spawn,
    merge_tables = merge_tables,
    merge_conflict_tables = merge_conflict_tables,
    damage_inc = damage_inc,
    damage_dec = damage_dec,
    insert_tower_range_buff = insert_tower_range_buff,
    insert_tower_cooldown_buff = insert_tower_cooldown_buff,
    remove_tower_range_buff = remove_tower_range_buff,
    remove_tower_cooldown_buff = remove_tower_cooldown_buff,
    insert_tower_damage_factor_buff = insert_tower_damage_factor_buff,
    remove_tower_damage_factor_buff = remove_tower_damage_factor_buff,
    y_controable_new_rally = y_controable_new_rally,
    update_on_damage = update_on_damage,
    hero_spawning_set_skill_ts = hero_spawning_set_skill_ts,
}

return SU
