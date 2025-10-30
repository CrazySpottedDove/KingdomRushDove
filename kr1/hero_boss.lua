local i18n = require("i18n")
require("constants")
local anchor_x = 0
local anchor_y = 0
local image_x = 0
local image_y = 0
local tt = nil
local scripts = require("game_scripts")
require("templates")
require("klua.table")
local log = require("klua.log"):new("hero_boss")
local km = require("klua.macros")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local W = require("wave_db")
local S = require("sound_db")
local simulation = require("simulation")

local function ready_to_attack(attack, store, factor)
    return store.tick_ts - attack.ts > attack.cooldown * (factor or 1)
end
local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end
local function queue_damage(store, damage)
    table.insert(store.damage_queue, damage)
end

local function adx(v)
    return v - anchor_x * image_x
end
local function ady(v)
    return v - anchor_y * image_y
end
local function y_enemy_wait(store, this, time)
    return U.y_wait(store, time, function(store, time)
        return this.health.dead or this.unit.is_stunned
    end)
end

local function enemy_pick_target_and_do_ranged_attack(store, this, attack)
    local entities = store.entities
    if store.soldiers then
        entities = store.soldiers
    end
    local target = U.find_nearest_soldier(entities, this.pos, attack.min_range, attack.max_range, attack.vis_flags,
        attack.vis_bans)
    if target then
        attack.ts = store.tick_ts
        SU.y_enemy_do_ranged_attack(store, this, target, attack)
    else
        attack.ts = attack.ts + 1
    end
end

local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"
local a
local V = require("klua.vector")
local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

local function r(x, y, w, h)
    return {
        pos = v(x, y),
        size = v(w, h)
    }
end

local function fts(v)
    return v / FPS
end

local function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

local function d2r(d)
    return d * math.pi / 180
end

local function RT(name, ref)
    return E:register_t(name, ref)
end

local function AC(tpl, ...)
    return E:add_comps(tpl, ...)
end

local function CC(comp_name)
    return E:clone_c(comp_name)
end

local function unit_interrupted(this)
    return this.health.dead or this.unit.is_stunned
end

local function enemy_do_counter_attack(store, this, target)
    local ma = this.dodge.counter_attack
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

    local hit_times = ma.hit_times and ma.hit_times or {ma.hit_time}

    for i = 1, #hit_times do
        local hit_time = hit_times[i]
        local dodged = false

        if ma.dodge_time and target.dodge then
            local dodge_time = ma.dodge_time

            if target.dodge and target.dodge.time_before_hit then
                dodge_time = hit_time - target.dodge.time_before_hit
            end

            while dodge_time > store.tick_ts - ma.ts do
                if this.health.dead or this.unit.is_stunned then
                    return false
                end

                coroutine.yield()
            end

            dodged = SU.unit_dodges(store, target, false, ma, this)
        end

        while hit_time > store.tick_ts - ma.ts do
            if this.health.dead or this.unit.is_stunned and not ma.ignore_stun then
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
        if this.health.dead or ma.ignore_stun and this.unit.is_stunned then
            return false
        end
        coroutine.yield()
    end
end

local function enemy_do_single_melee_attack(store, this, target, ma)
    ma.ts = store.tick_ts
    for _, aa in pairs(this.melee.attacks) do
        if aa ~= ma and aa.shared_cooldown then
            aa.ts = ma.ts
        end
    end

    if ma.loops then
        local attack_done = false
        local start_ts = store.tick_ts
        local an, af
        local attack = ma
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
            local hit_times = attack.hit_times and attack.hit_times or {attack.hit_time}
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
                    local targets = U.find_soldiers_in_range(store.soldiers or store.entities, hit_pos, 0,
                        attack.damage_radius, attack.damage_flags, attack.damage_bans) or {}
                    for _, e in pairs(targets) do
                        local d = E:create_entity("damage")
                        d.source_id = this.id
                        d.target_id = e.id
                        d.damage_type = attack.damage_type
                        d.value = (math.random(attack.damage_min, attack.damage_max) + (this.damage_buff or 0)) *
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
                else
                    local d = E:create_entity("damage")

                    if attack.instakill then
                        d.damage_type = DAMAGE_INSTAKILL
                    elseif attack.fn_damage then
                        d.damage_type = attack.damage_type
                        d.value = attack.fn_damage(this, store, attack, target)
                    else
                        d.damage_type = attack.damage_type
                        d.value = this.unit.damage_factor *
                                      (math.random(attack.damage_min, attack.damage_max) + (this.damage_buff or 0))
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

                if this.health.dead then
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
                if this.health.dead then
                    break
                end

                coroutine.yield()
            end
        end

        ::label_70_1::

        S:stop(attack.sound)
    else
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
        local hit_times = ma.hit_times and ma.hit_times or {ma.hit_time}
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
                dodged = SU.unit_dodges(store, target, false, ma, this)
            end
            while hit_time > store.tick_ts - ma.ts do
                if this.health.dead or this.unit.is_stunned and not ma.ignore_stun or this.dodge and this.dodge.active and
                    not this.dodge.silent then
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
                local targets = U.find_soldiers_in_range(store.soldiers or store.entities, hit_pos, 0, ma.damage_radius,
                    ma.vis_flags, ma.vis_bans, ma.fn_filter) or {}

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
            if ma.hit_aura then
                local a = E:create_entity(ma.hit_aura)
                a.pos = V.vclone(hit_pos)
                a.aura.target_id = target.id
                a.aura.source_id = this.id
                queue_insert(store, a)
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
    end

    U.animation_start(this, "idle", nil, store.tick_ts, true)

    return true
end

---获取近战位置
---@param enemy table 敌人实体
---@param soldier table 士兵实体
---@param rank number|nil 排名（可选）
---@param back boolean|nil 是否在后面（可选）
---@return table|nil 敌人位置, boolean|nil 敌人是否在右侧
local function melee_slot_enemy_position(enemy, soldier, rank, back)
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

    local enemy_on_the_right = math.abs(km.signed_unroll(enemy.heading.angle)) > math.pi * 0.5

    if back then
        enemy_on_the_right = not enemy_on_the_right
    end

    local enemy_pos = {
        x = soldier.pos.x + (enemy_on_the_right and 1 or -1) *
            (enemy.enemy.melee_slot.x + x_off + soldier.soldier.melee_slot_offset.x),
        y = soldier.pos.y + (enemy.enemy.melee_slot.y + y_off + soldier.soldier.melee_slot_offset.y)
    }

    return enemy_pos, enemy_on_the_right
end

tt = RT("hero_boss", "enemy")
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].name = "idle"
tt.enemy.gold = 0
tt.enemy.lives_cost = 5
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, ady(60))
tt.vis.flags = F_ENEMY

local function inherit_from_hero_template(new_template, old_template)
    local t = RT(new_template, "hero_boss")
    local old_t = E:get_template(old_template)
    t.health_bar = table.deepclone(old_t.health_bar)
    t.info = table.deepclone(old_t.info)
    t.motion.max_speed = old_t.motion.max_speed / 1.2
    t.render.sprites = table.deepclone(old_t.render.sprites)
    t.enemy.melee_slot = v(old_t.soldier.melee_slot_offset.x * 2, old_t.soldier.melee_slot_offset.y)
    t.unit.marker_offset = V.vclone(old_t.unit.marker_offset)
    t.unit.mod_offset = V.vclone(old_t.unit.mod_offset)
    if old_t.melee then
        t.melee = table.deepclone(old_t.melee)
        for _, a in pairs(t.melee.attacks) do
            a.disabled = nil
        end
    end
    if old_t.ranged then
        t.ranged = table.deepclone(old_t.ranged)
        for _, a in pairs(t.ranged.attacks) do
            a.disabled = nil
        end
    end
    if old_t.timed_attacks then
        t.timed_attacks = table.deepclone(old_t.timed_attacks)
        for _, a in pairs(t.timed_attacks.list) do
            a.disabled = nil
        end
    end
    if old_t.dodge then
        t.dodge = table.deepclone(old_t.dodge)
    end
    t.vis.flags = bor(bor(t.vis.flags, F_SPELLCASTER), U.flag_clear(old_t.vis.flags, bor(F_HERO, F_FRIEND)))
    t.vis.bans = bor(t.vis.bans, old_t.vis.bans)
    t.health.hp_max = old_t.hero.level_stats.hp_max[10]
    t.health.armor = old_t.hero.level_stats.armor[10]
    if old_t.hero.level_stats.magic_armor then
        t.health.magic_armor = old_t.hero.level_stats.magic_armor[10]
    end
    t.sound_events.death = old_t.sound_events.death
    return t
end

local function inherit_from_soldier_template(new_template, old_template)
    local t = RT(new_template, "enemy")
    local old_t = E:get_template(old_template)
    t.health_bar = table.deepclone(old_t.health_bar)
    t.info = table.deepclone(old_t.info)
    t.motion.max_speed = old_t.motion.max_speed / 1.2
    t.render.sprites = table.deepclone(old_t.render.sprites)
    t.enemy.melee_slot = v(old_t.soldier.melee_slot_offset.x * 2, old_t.soldier.melee_slot_offset.y)
    t.unit.marker_offset = V.vclone(old_t.unit.marker_offset)
    t.unit.mod_offset = V.vclone(old_t.unit.mod_offset)
    if old_t.melee then
        t.melee = table.deepclone(old_t.melee)
        for _, a in pairs(t.melee.attacks) do
            a.disabled = nil
        end
    end
    if old_t.ranged then
        t.ranged = table.deepclone(old_t.ranged)
        for _, a in pairs(t.ranged.attacks) do
            a.disabled = nil
        end
    end
    if old_t.timed_attacks then
        t.timed_attacks = table.deepclone(old_t.timed_attacks)
        for _, a in pairs(t.timed_attacks.list) do
            a.disabled = nil
        end
    end
    if old_t.dodge then
        t.dodge = table.deepclone(old_t.dodge)
    end
    t.health.hp_max = old_t.health.hp_max
    t.health.armor = old_t.health.armor
    t.health.magic_armor = old_t.health.magic_armor
    t.vis.flags = bor(t.vis.flags, U.flag_clear(old_t.vis.flags, F_FRIEND))
    t.vis.bans = bor(t.vis.bans, old_t.vis.bans)
    return t
end

tt = inherit_from_hero_template("eb_gerald", "hero_gerald")
tt.melee.cooldown = 1
a = tt.melee.attacks[1]
a.damage_type = DAMAGE_PHYSICAL
a.damage_max = 50
a.damage_min = 29
a = tt.melee.attacks[2]
a.damage_type = DAMAGE_PHYSICAL
a.damage_max = 50
a.damage_min = 29
a = tt.timed_attacks.list[1]
a.mod = "mod_eb_gerald_courage"
a.vis_flags = F_MOD
a = tt.dodge
a.chance = 0.75
a.counter_attack = E:clone_c("melee_attack")
a = a.counter_attack
a.animation = "counter"
a.cooldown = 1
a.damage_type = DAMAGE_TRUE
a.reflected_damage_factor = 2
a.hit_time = fts(5)
a.sound = "HeroPaladinDeflect"
tt.main_script.update = function(this, store)
    this.health_bar.hidden = false
    local courage = this.timed_attacks.list[1]
    while true do
        if this.health.dead then
            SU.y_enemy_death(store, this)
            return
        end
        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if this.dodge.active then
                this.dodge.active = false
                this.dodge.counter_attack_pending = true
                local la = this.dodge.last_attack
                local ca = this.dodge.counter_attack

                if la then
                    ca.damage_max = math.max(la.damage_max * (ca.reflected_damage_factor),
                        this.melee.attacks[1].damage_max) * this.unit.damage_factor
                    ca.damage_min = math.min(la.damage_min * (ca.reflected_damage_factor),
                        this.melee.attacks[1].damage_min) * this.unit.damage_factor
                end
                goto while_end
            end

            if ready_to_attack(courage, store) and this.health.hp_max > this.health.hp and this.enemy.can_do_magic then
                local entities
                if store.enemy_spatial_index then
                    entities = store
                else
                    entities = store.entities
                end
                local targets = U.find_enemies_in_range(entities, this.pos, 0, courage.range, courage.vis_flags,
                    courage.vis_bans, function(v)
                        return not U.has_modifier_in_list(store, v, {courage.mod})
                    end)

                if not targets then
                    SU.delay_attack(store, courage, 0.5)
                else
                    local start_ts = store.tick_ts
                    S:queue(courage.sound)
                    U.animation_start(this, courage.animation, nil, store.tick_ts)
                    if y_enemy_wait(store, this, courage.shoot_time) then
                        goto while_end
                    end
                    courage.ts = start_ts
                    for _, e in pairs(targets) do
                        local mod = E:create_entity(courage.mod)
                        mod.modifier.target_id = e.id
                        mod.modifier.source_id = this.id
                        queue_insert(store, mod)
                    end
                    while not U.animation_finished(this) do
                        if this.health.dead or this.unit.is_stunned then
                            break
                        end
                        coroutine.yield()
                    end
                    goto while_end
                end
            end
            local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function()
                return ready_to_attack(courage, store) and this.health.hp_max > this.health.hp and
                           this.enemy.can_do_magic
            end)
            if cont then
                if blocker then
                    if not SU.y_wait_for_blocker(store, this, blocker) then
                        goto while_end
                    end
                    while SU.can_melee_blocker(store, this, blocker) do
                        if this.dodge.counter_attack_pending and ready_to_attack(this.dodge.counter_attack, store) then
                            this.dodge.counter_attack_pending = false
                            this.melee.last_attack = {
                                target_id = blocker.id,
                                attack = this.dodge.counter_attack
                            }
                            local target = store.entities[blocker.id]
                            enemy_do_counter_attack(store, this, target)
                        end
                        if not SU.y_enemy_melee_attacks(store, this, blocker) then
                            goto while_end
                        end
                        coroutine.yield()
                    end
                end
            end
        end
        ::while_end::
        coroutine.yield()
    end
end

tt = RT("mod_eb_gerald_courage", "modifier")
AC(tt, "render")
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "mod_gerald_courage"
tt.render.sprites[1].anchor = v(0.51, 0.17307692307692307)
tt.render.sprites[1].draw_order = 2
tt.courage = {
    hp = 0.3,
    armor = 0.15
}
tt.main_script.insert = function(this, store)
    local target = store.entities[this.modifier.target_id]
    local buff = this.courage
    if not target or target.health.dead or not target.unit then
        return false
    end
    local heal = math.min(target.health.hp_max * buff.hp, 750)
    SU.armor_inc(target, buff.armor)
    target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + heal)

    for _, s in pairs(this.render.sprites) do
        s.ts = store.tick_ts
        if s.size_names then
            s.name = s.size_names[target.unit.size]
        end
    end
    return true
end
tt.main_script.remove = function(this, store)
    local buff = this.courage
    local target = store.entities[this.modifier.target_id]
    if target then
        SU.armor_dec(target, buff.armor)
    end
    return true
end
tt.main_script.update = scripts.mod_track_target.update

tt = inherit_from_hero_template("eb_alleria", "hero_alleria")
tt.melee.cooldown = 1
a = tt.melee.attacks[1]
a.damage_type = DAMAGE_PHYSICAL
a.damage_max = 34
a.damage_min = 21
a = tt.ranged.attacks[1]
a.bullet = "arrow_eb_alleria"
a = tt.ranged.attacks[2]
a.bullet = "arrow_multishot_eb_alleria"
a.cooldown = 2.6 + fts(29)
a.min_range = 0
a = tt.ranged.attacks[3]
a.disabled = true
a = tt.timed_attacks.list[1]
a.entity = "eb_alleria_wildcat"
tt.main_script.update = function(this, store)
    this.health_bar.hidden = false
    local wildcat = this.timed_attacks.list[1]
    local multishot = this.ranged.attacks[2]
    local function wildcat_ready()
        return ready_to_attack(wildcat, store) and this.enemy.can_do_magic
    end
    local function multishot_ready()
        return ready_to_attack(this.ranged.attacks[2], store) and this.enemy.can_do_magic
    end
    local function get_wildcat_pos()
        local positions = P:get_all_valid_pos(this.pos.x, this.pos.y, wildcat.min_range, wildcat.max_range,
            TERRAIN_LAND, nil, NF_RALLY)

        return positions[1]
    end
    while true do
        if this.health.dead then
            SU.y_enemy_death(store, this)
            return
        end
        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if wildcat_ready() then
                local pos = get_wildcat_pos()
                if pos then
                    S:queue(wildcat.sound)
                    this.health.immune_to = F_ALL
                    U.animation_start(this, wildcat.animation, nil, store.tick_ts)
                    if y_enemy_wait(store, this, wildcat.spawn_time) then
                        this.health.immune_to = F_NONE
                        goto while_end
                    end

                    local e = E:create_entity(wildcat.entity)
                    e.pos = V.vclone(pos)
                    e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                    wildcat.ts = store.tick_ts
                    e.nav_path.pi = this.nav_path.pi
                    e.nav_path.spi = this.nav_path.spi
                    e.nav_path.ni = this.nav_path.ni
                    queue_insert(store, e)
                    while not U.animation_finished(this) do
                        if this.health.dead or this.unit.is_stunned then
                            break
                        end
                        coroutine.yield()
                    end
                    this.health.immune_to = F_NONE
                    goto while_end
                else
                    SU.delay_attack(store, wildcat, 0.5)
                end
            end
            if multishot_ready() then
                local entities = store.entities
                if store.soldiers then
                    entities = store.soldiers
                end
                local target = U.find_nearest_soldier(entities, this.pos, multishot.min_range, multishot.max_range,
                    multishot.vis_flags, multishot.vis_bans)
                if target then
                    multishot.ts = store.tick_ts
                    SU.y_enemy_do_ranged_attack(store, this, target, multishot)
                else
                    multishot.ts = multishot.ts + 1
                end
            end
            if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, wildcat_ready, function()
                return wildcat_ready() or multishot_ready()
            end, wildcat_ready) then
                goto while_end
            end
            ::while_end::
            coroutine.yield()
        end
    end
end

tt = inherit_from_soldier_template("eb_alleria_wildcat", "soldier_alleria_wildcat")
tt.health.hp_max = 700
a = tt.melee.attacks[1]
a.damage_min = 14
a.damage_max = 16
a.vis_flags = 0
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.info.fn = scripts.enemy_basic.get_info

tt = RT("arrow_eb_alleria", "arrow")
tt.bullet.flight_time = fts(15)
tt.bullet.damage_max = 55
tt.bullet.damage_min = 13

tt = RT("arrow_multishot_eb_alleria", "arrow")
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.damage_min = 15
tt.bullet.damage_max = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.extra_arrows_range = 100
tt.extra_arrows = 10
tt.render.sprites[1].name = "hero_archer_arrow"
tt.main_script.insert = function(this, store)
    if this.extra_arrows > 0 then
        local entities = store.entities
        if store.soldiers then
            entities = store.soldiers
        end
        local targets = U.find_soldiers_in_range(entities, this.bullet.to, 0, this.extra_arrows_range, F_RANGED, F_NONE)
        if targets then
            local rate
            if #targets > this.extra_arrows then
                rate = this.extra_arrows
            else
                rate = #targets
            end
            this.bullet.flight_time = fts(3 + 3 * rate)
            local j = 1
            local predicted_health = {}
            for i = 1, this.extra_arrows do
                local b = E:clone_entity(this)
                b.extra_arrows = 0
                local t
                if i <= #targets then
                    t = targets[i]
                else
                    while j < #targets and predicted_health[targets[j].id] <= 0 do
                        j = j + 1
                    end
                    t = targets[j]
                    b.bullet.damage_max = b.bullet.damage_max - 20
                end

                b.bullet.target_id = t.id
                b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
                local d = SU.create_bullet_damage(b.bullet, t.id, this.id)
                if not predicted_health[t.id] then
                    predicted_health[t.id] = t.health.hp
                end
                predicted_health[t.id] = predicted_health[t.id] - U.predict_damage(t, d)
                queue_insert(store, b)
            end
        else
            if store.entities[this.bullet.target_id] then
                for i = 1, this.extra_arrows do
                    local b = E:clone_entity(this)
                    b.extra_arrows = 0
                    b.bullet.damage_max = b.bullet.damage_max - 20
                    queue_insert(store, b)
                end
            end
        end
    end
    return scripts.arrow.insert(this, store)
end

tt = inherit_from_soldier_template("enemy_elf", "soldier_elf")
tt.main_script.update = scripts.enemy_mixed.update
a = tt.melee.attacks[1]
a.mod = "mod_enemy_elf_bleed"
a = tt.ranged.attacks[1]
a.bullet = "arrow_enemy_elf"
a = tt.ranged.attacks[2]
if a then
    a.bullet = "arrow_enemy_elf_cripple"
    a.chance = 0.5
end

tt = RT("arrow_enemy_elf", "arrow")
tt.bullet.damage_min = 25
tt.bullet.damage_max = 50
tt.bullet.flight_time = fts(12)
tt.bullet.reset_to_target_pos = true
tt.bullet.damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
tt.bullet.mod = "mod_enemy_elf_bleed"

tt = RT("arrow_enemy_elf_cripple", "arrow")
tt.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
tt.bullet.reset_to_target_pos = true
tt.bullet.mod = "mod_enemy_elf_bleed"
tt.bullet.flight_time = fts(8)
tt.bullet.damage_min = 95
tt.bullet.damage_max = 95

tt = RT("mod_enemy_elf_bleed", "mod_blood")
tt.dps.damage_max = 20
tt.dps.damage_min = 20
tt.dps.damage_every = 1
tt.modifier.allows_duplicate = true

tt = inherit_from_soldier_template("enemy_blade", "soldier_blade")
tt.dodge.chance = 0.3
tt.dodge.ranged = false
tt.health.on_damage = function(this, store, damage)
    local bda = this.timed_attacks.list[1]
    if this.unit.is_stuuned or this.health.dead or bda.in_progress or
        band(damage.damage_type, DAMAGE_ALL_TYPES, bnot(bor(DAMAGE_PHYSICAL, DAMAGE_MAGICAL, (DAMAGE_MIXED or 0)))) ~= 0 or
        band(damage.damage_type, DAMAGE_NO_DODGE) ~= 0 or this.dodge.chance < math.random() or (not this.enemy.can_do_magic) then
        return true
    end
    -- if #this.enemy.blockers > 0 then
        this.dodge.active = true
    -- end
    return false
end
tt.melee.cooldown = 0.8
a = tt.melee.attacks[1]
a.cooldown = 0.8
a.damage_max = 19
a.damage_min = 15
a = tt.melee.attacks[2]
a.cooldown = 0.8
a.damage_max = 19
a.damage_min = 15
a.cooldown = 0.8
a = tt.melee.attacks[3]
a.damage_max = 19
a.damage_min = 15
a.cooldown = 0.8
tt.melee.forced_cooldown = 0.8
a = tt.timed_attacks.list[1]
a.damage_max = 56
a.damage_min = 40
a.cooldown = 7.2
a.hits = 4
tt.enemy.gold = 30
tt.main_script.update = function(this, store)
    local brk, sta
    local bda = this.timed_attacks.list[1]
    local function bda_ready()
        return ready_to_attack(bda, store) and this.enemy.can_do_magic
    end
    local function break_from_melee()
        return bda_ready() or (this.dodge.active and this.enemy.can_do_magic)
    end
    this.vis._bans = this.vis.bans
    while true do
        if this.health.dead then
            SU.y_enemy_death(store, this)
            return
        end

        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if this.dodge.active and this.enemy.can_do_magic then
                local ca = this.dodge.counter_attack

                this.dodge.active = false

                local start_ts = store.tick_ts

                ca.ts = 0

                this.vis.bans = bor(this.vis.bans, F_NET)
                if not this.dodge.applied then
                    this.dodge.applied = true
                    -- this.health.damage_factor = this.health.damage_factor * 0.05
                    this.health.ignore_damage = true
                end
                S:queue(ca.sound)
                U.animation_start(this, ca.animation, nil, store.tick_ts, true)
                U.y_wait(store, ca.hit_time)

                while store.tick_ts - start_ts < ca.duration do
                    if store.tick_ts - ca.ts > ca.damage_every then
                        ca.ts = store.tick_ts
                        local entities = store.entities
                        if store.soldiers then
                            entities = store.soldiers
                        end
                        local targets = U.find_soldiers_in_range(entities, this.pos, 0, ca.damage_radius,
                            ca.damage_flags, ca.damage_bans)

                        if targets then
                            for _, target in pairs(targets) do
                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = target.id
                                d.value = ca.damage_max
                                d.damage_type = ca.damage_type

                                queue_damage(store, d)
                            end
                        end
                    end
                    coroutine.yield()
                end

                this.vis.bans = band(this.vis.bans, bnot(F_NET))
                if this.dodge.applied then
                    -- this.health.damage_factor = this.health.damage_factor * 20
                    this.health.ignore_damage = false
                    this.dodge.applied = nil
                end

                U.y_animation_wait(this)
            end

            if bda_ready() then
                local entities = store.entities
                if store.soldiers then
                    entities = store.soldiers
                end
                local targets = U.find_soldiers_in_range(entities, this.pos, 0, bda.max_range, bda.vis_flags,
                    bda.vis_bans)

                if not targets or #targets < bda.min_count then
                    SU.delay_attack(store, bda, fts(6))

                    goto label_53_1
                end

                bda.ts = store.tick_ts
                bda.in_progress = true
                this.health.ignore_damage = true
                this.vis.bans = F_ALL

                local initial_pos = V.vclone(this.pos)
                local visited = {}

                U.y_animation_play(this, "dance_out", nil, store.tick_ts)

                for i = 1, bda.hits do
                    ::label_53_0::

                    targets = U.find_soldiers_in_range(entities, this.pos, 0, bda.max_range, bda.vis_flags,
                        bda.vis_bans, function(v)
                            return not table.contains(visited, v)
                        end)

                    if not targets then
                        if #visited > 0 then
                            visited = {}

                            goto label_53_0
                        else
                            break
                        end
                    end

                    local target = targets[km.zmod(i, #targets)]

                    table.insert(visited, target)
                    SU.stun_inc(target)

                    local spos, sflip = melee_slot_enemy_position(this, target, 1)

                    this.pos.x, this.pos.y = spos.x, spos.y

                    S:queue(bda.sound)

                    local an = table.random({"dance_hit1", "dance_hit2", "dance_hit3"})

                    U.animation_start(this, an, sflip, store.tick_ts)
                    U.y_wait(store, bda.hit_time)

                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = target.id
                    d.value = U.frandom(bda.damage_min, bda.damage_max)
                    d.damage_type = bda.damage_type

                    queue_damage(store, d)
                    U.y_animation_wait(this)
                    SU.stun_dec(target)
                end

                this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

                U.y_animation_play(this, "dance_in", nil, store.tick_ts)

                this.health.ignore_damage = false
                this.vis.bans = this.vis._bans

                -- AC:inc_check("BLADE_DANCE")

                bda.in_progress = nil

                goto label_53_2
            end

            ::label_53_1::

            if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_from_melee, break_from_melee) then
                goto label_53_2
            end
        end

        ::label_53_2::

        coroutine.yield()
    end
end
tt.render.sprites[1].alpha = 180

tt = inherit_from_soldier_template("enemy_forest", "soldier_forest")
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[2].disabled = nil
tt.ranged.attacks[2].bullet = "spear_enemy_forest_oak"
tt.timed_attacks.list[1].cooldown = tt.timed_attacks.list[1].cooldown * 2
tt.timed_attacks.list[1].vis_bans = F_FRIEND
tt.timed_attacks.list[2].cooldown = tt.timed_attacks.list[2].cooldown * 2
tt.timed_attacks.list[2].bullet = "aura_enemy_forest_eerie"
tt.timed_attacks.list[2].max_range = tt.timed_attacks.list[2].max_range + 2 * tt.timed_attacks.list[2].max_range_inc
tt.timed_attacks.list[2].vis_bans = bor(F_ENEMY, F_FLYING)
tt.main_script.update = function(this, store)
    local brk, sta
    local ca = this.timed_attacks.list[1]
    local ea = this.timed_attacks.list[2]
    local entities = store.entities
    if store.soldiers then
        entities = store.soldiers
    end

    local function ea_ready()
        return ready_to_attack(ea, store) and this.enemy.can_do_magic
    end
    local function ca_ready()
        return ready_to_attack(ca, store) and this.enemy.can_do_magic
    end
    local function range_ready()
        if not ready_to_attack(this.ranged.attacks[2], store) or not this.enemy.can_do_magic then
            return false
        end
        local targets = U.find_soldiers_in_range(entities, this.pos, this.ranged.attacks[2].min_range,
            this.ranged.attacks[2].max_range, this.ranged.attacks[2].vis_flags, this.ranged.attacks[2].vis_bans)
        if targets then
            return true
        else
            this.ranged.attacks[2].ts = this.ranged.attacks[2].ts + 1
            return false
        end
    end
    local function break_from_walk()
        return ea_ready() or ca_ready()
    end

    local function break_from_melee()
        return ea_ready() or ca_ready() or range_ready()
    end

    local function break_from_range()
        return ea_ready() or ca_ready()
    end

    while true do
        if this.health.dead then
            SU.y_enemy_death(store, this)
            return
        end

        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if ea_ready() then
                local targets = U.find_soldiers_in_range(entities, this.pos, 0, ea.max_range, ea.vis_flags, ea.vis_bans,
                    function(s)
                        return not s.unit.is_stunned and s.soldier and s.soldier.target_id
                    end)

                if not targets then
                    SU.delay_attack(store, ea, fts(6))
                else
                    local target = targets[1]
                    local nodes = P:nearest_nodes(target.pos.x, target.pos.y, {this.nav_path.pi}, {this.nav_path.spi})
                    local node = nodes[1]
                    if node then
                        this._casting_eerie = true
                        ea.ts = store.tick_ts
                        U.animation_start(this, ea.animation, nil, store.tick_ts)
                        U.y_wait(store, ea.cast_time)

                        local a = E:create_entity(ea.bullet)

                        a.aura.source_id = this.id
                        a.aura.level = 2

                        a.pos = P:node_pos(node[1], node[2], node[3])
                        a.pos_pi = node[1]
                        a.pos_ni = node[3]
                        queue_insert(store, a)
                        U.y_animation_wait(this)

                        this._casting_eerie = nil
                    else
                        SU.delay_attack(store, ea, fts(6))
                    end
                end
            end

            if ca_ready() then
                if not (this.health.hp / this.health.hp_max < ca.trigger_hp_factor) then
                    SU.delay_attack(store, ca, fts(6))
                else
                    this._casting_circle = true
                    ca.ts = store.tick_ts

                    S:queue(ca.sound)
                    U.animation_start(this, ca.animation, nil, store.tick_ts)
                    U.y_wait(store, ca.cast_time)

                    local fx = E:create_entity("fx_forest_circle")

                    fx.pos.x, fx.pos.y = this.pos.x + this.unit.mod_offset.x, this.pos.y + this.unit.mod_offset.y
                    fx.tween.ts = store.tick_ts

                    queue_insert(store, fx)
                    local enemy_entities = store.entities
                    if store.enemy_spatial_index then
                        enemy_entities = store
                    end
                    local targets = U.find_enemies_in_range(enemy_entities, this.pos, 0, ca.max_range, ca.vis_flags,
                        ca.vis_bans)

                    if targets then
                        for _, target in pairs(targets) do
                            local mod = E:create_entity(ca.mod)
                            mod.modifier.level = 3
                            mod.modifier.source_id = this.id
                            mod.modifier.target_id = target.id
                            queue_insert(store, mod)
                        end

                        U.y_animation_wait(this)

                        this._casting_circle = nil
                    end
                end
            end

            if range_ready() then
                enemy_pick_target_and_do_ranged_attack(store, this, this.ranged.attacks[2])
            end

            if not SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_from_walk, break_from_melee,
                break_from_range) then
                goto label_56_3
            end
        end

        ::label_56_3::

        coroutine.yield()
    end
end

tt = RT("spear_enemy_forest_oak", "spear_forest_oak")
tt.bullet.damage_max = 160
tt.bullet.damage_min = 160
tt.bullet.damage_inc = 0

tt = RT("aura_enemy_forest_eerie", "aura_forest_eerie")
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)

tt = inherit_from_hero_template("eb_10yr", "hero_10yr")
tt.health.on_damage = function(this, store, damage)
    if not this.is_buffed and band(damage.damage_type, DAMAGE_BASE_TYPES) ~= 0 and math.random() < 0.05 then
        this.teleport.triggered = true
        return false
    end
    return true
end
tt.teleport = table.deepclone(E:get_template("hero_10yr").teleport)
tt.teleport.nodes = 8
tt.motion.max_speed_normal = E:get_template("hero_10yr").motion.max_speed_normal / 1.2
tt.motion.max_speed_buffed = E:get_template("hero_10yr").motion.max_speed_buffed / 1.2
a = tt.melee.attacks[1]
a.damage_max = 49
a.damage_min = 32
a = tt.melee.attacks[2]
a.damage_max = 49
a.damage_min = 32
a = tt.melee.attacks[3]
a.damage_min = 27
a.damage_max = 54
a.disabled = true
a = tt.timed_attacks.list[1]
a.entity = "aura_eb_10yr_fireball"
a.vis_bans = F_ENEMY
a = tt.timed_attacks.list[2]
a.duration = 12
a = tt.timed_attacks.list[3]
a.sound = a.sound_long
a.damage_min = 70
a.damage_max = 90
a.disabled = true
a.hit_aura = "aura_eb_10yr_bomb"
tt.particles_aura = "aura_10yr_idle"
tt.melee.cooldown = 1.35
tt.main_script.update = function(this, store)
    local h = this.health
    local he = this.hero
    local ra = this.timed_attacks.list[1]
    local ba = this.timed_attacks.list[2]
    local bma = this.timed_attacks.list[3]
    local a, brk, sta
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
                    enemy_do_single_melee_attack(store, this, target, ma)
                    while not U.animation_finished(this) do
                        if this.health.dead or ma.ignore_stun and this.unit.is_stunned or this.dodge and
                            this.dodge.active and not this.dodge.silent then
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

    local function y_enemy_mixed_walk_melee_ranged(store, this, ignore_soldiers, walk_break_fn, melee_break_fn,
        ranged_break_fn)
        ranged_break_fn = ranged_break_fn or melee_break_fn

        local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, ignore_soldiers, walk_break_fn)

        if not cont then
            return false
        end

        if blocker then
            if not SU.y_wait_for_blocker(store, this, blocker) then
                return false
            end

            while SU.can_melee_blocker(store, this, blocker) and (not melee_break_fn or not melee_break_fn(store, this)) do
                if not y_enemy_melee_attacks(store, this, blocker) then
                    return false
                end

                coroutine.yield()
            end
        elseif ranged then
            while SU.can_range_soldier(store, this, ranged) and #this.enemy.blockers == 0 and
                (not ranged_break_fn or not ranged_break_fn(store, this)) do
                if not SU.y_enemy_range_attacks(store, this, ranged) then
                    return false
                end

                coroutine.yield()
            end
        end

        return true
    end

    local function go_buffed()
        for i = 1, 2 do
            this.melee.attacks[i].disabled = true
        end

        this.melee.attacks[3].disabled = false
        this.health.immune_to = ba.immune_to

        for _, v in pairs(ba.sounds_buffed) do
            S:queue(v)
        end

        U.y_animation_play(this, "normal_to_buffed", nil, store.tick_ts, 1)

        this.render.sprites[1].prefix = "hero_10yr_buffed"
        ba.ts = store.tick_ts
        this.teleport.disabled = true
        this.is_buffed = true
        this.health_bar.offset = this.health_bar.offset_buffed
        if U.update_max_speed then
            U.update_max_speed(this, this.motion.max_speed_buffed)
        else
            this.motion.max_speed = this.motion.max_speed + this.motion.max_speed_buffed - this.motion.max_speed_normal
        end
    end

    local function go_normal()
        for i = 1, 2 do
            this.melee.attacks[i].disabled = false
        end

        this.melee.attacks[3].disabled = true
        this.is_buffed = false

        for _, v in pairs(ba.sounds_normal) do
            S:queue(v)
        end

        U.y_animation_play(this, "to_normal", nil, store.tick_ts, 1)
        this.health.immune_to = DAMAGE_NONE
        this.render.sprites[1].prefix = "hero_10yr"
        this.teleport.disabled = nil
        this.health_bar.offset = this.health_bar.offset_normal
        if U.update_max_speed then
            U.update_max_speed(this, this.motion.max_speed_normal)
        else
            this.motion.max_speed = this.motion.max_speed + this.motion.max_speed_normal - this.motion.max_speed_buffed
        end
        ba.ts = store.tick_ts
    end

    this.health_bar.hidden = false

    local aura = E:create_entity(this.particles_aura)

    aura.aura.source_id = this.id

    queue_insert(store, aura)

    local function ra_ready()
        return this.enemy.can_do_magic and ready_to_attack(ra, store) and not this.is_buffed
    end

    local function ba_ready()
        return this.enemy.can_do_magic and ready_to_attack(ba, store) and not this.is_buffed and this.health.hp /
                   this.health.hp_max < ba.transform_health_factor
    end

    local function bma_ready()
        return this.enemy.can_do_magic and ready_to_attack(bma, store) and this.is_buffed
    end

    local function teleport_ready()
        return this.enemy.can_do_magic and this.teleport.triggered and not this.is_buffed and P:nodes_to_defend_point(this.nav_path) > this.teleport.nodes
    end

    local function ba_exit()
        return this.is_buffed and store.tick_ts - ba.ts >= ba.duration
    end

    local function break_from_walk()
        return ra_ready() or ba_ready() or bma_ready() or ba_exit() or teleport_ready()
    end

    local function break_from_melee()
        return ra_ready() or ba_ready() or bma_ready() or ba_exit() or teleport_ready()
    end

    local soldier_entities = store.entities
    if store.soldiers then
        soldier_entities = store.soldiers
    end
    while true do
        if h.dead then
            if this.is_buffed then
                go_normal()
            end

            SU.y_enemy_death(store, this)
            return
        end

        if this.unit.is_stunned then
            SU.y_enemy_stun(store, this)
        else
            if teleport_ready() then
                local tp = this.teleport
                local vis_bans = this.vis.bans
                tp.pending = true
                local ni = this.nav_path.ni + this.teleport.nodes
                local dest = P:node_pos(this.nav_path.pi, this.nav_path.spi, ni)
                U.set_destination(this, dest)
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
                this.pos.x, this.pos.y = dest.x, dest.y
                this.motion.speed.x, this.motion.speed.y = 0, 0
                U.unblock_all(store, this)
                this.nav_path.ni = ni
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
                tp.triggered = false
            end
            a = ra
            if ra_ready() then
                local start_ts, bdy, bdt, au
                local fired_aura = false
                local targets = U.find_soldiers_in_range(soldier_entities, this.pos, a.min_range, a.trigger_range,
                    a.vis_flags, a.vis_bans)

                if not targets then
                    SU.delay_attack(store, a, 1)
                else
                    S:queue(a.sound_start)
                    U.animation_start(this, a.animations[1], nil, store.tick_ts, false)

                    while not U.animation_finished(this) do
                        if unit_interrupted(this) then
                            goto label_90_0
                        end

                        coroutine.yield()
                    end

                    start_ts = store.tick_ts

                    U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

                    while not U.animation_finished(this) do
                        if unit_interrupted(this) then
                            goto label_90_0
                        end

                        coroutine.yield()
                    end

                    au = E:create_entity(a.entity)
                    au.aura.source_id = this.id

                    queue_insert(store, au)

                    fired_aura = true

                    ::label_90_0::

                    if fired_aura then
                        a.ts = start_ts
                    end

                    S:queue(a.sound_end)
                    U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
                end
            end

            a = ba
            if ba_ready() then
                go_buffed()
            elseif this.is_buffed and store.tick_ts - a.ts >= a.duration then
                go_normal()
            end

            a = bma
            if this.is_buffed and store.tick_ts - a.ts >= a.cooldown then
                local soldiers = U.find_soldiers_in_range(soldier_entities, this.pos, a.min_range, a.max_range,
                    a.vis_flags, a.vis_bans)
                if not soldiers or #soldiers < a.min_count then
                    SU.delay_attack(store, a, 0.6)
                else
                    local target = soldiers[1]

                    enemy_do_single_melee_attack(store, this, target, a)
                end
            end

            if not y_enemy_mixed_walk_melee_ranged(store, this, false, break_from_walk, break_from_melee) then
                goto label_90_1
            end
        end

        ::label_90_1::

        coroutine.yield()
    end
end
tt = RT("aura_eb_10yr_fireball", "aura_10yr_fireball")
tt.aura.entity = "fireball_eb_10yr"
tt.aura.loops = 5
tt.main_script.update = function(this, store)
    local start_y = store.visible_coords and store.visible_coords.top or REF_H
    local bdt
    local a = this.aura
    local owner = store.entities[a.source_id]

    if not owner then
        log.error("owner %s was not found. bailing out", a.source_od)
    else
        do
            local bdy = math.abs(owner.pos.y - start_y)
            local tpl = E:get_template(a.entity)

            bdt = bdy / tpl.bullet.max_speed
        end

        for i = 1, a.loops do
            local target = U.find_nearest_soldier(store.soldiers or store.entities, owner.pos, a.min_range, a.max_range,
                a.vis_flags, a.vis_bans)
            local b = E:create_entity(a.entity)

            if target then
                local dh = start_y - target.pos.y
                local dx = dh * 0.4

                b.pos.x, b.pos.y = target.pos.x + dx, start_y
                b.bullet.to = V.v(target.pos.x, target.pos.y)
            else
                local tx = owner.pos.x + math.random(-20, 20)
                local ty = owner.pos.y + math.random(-20, 20)
                local dh = start_y - ty
                local dx = dh * 0.4

                b.pos.x, b.pos.y = tx + dx, start_y
                b.bullet.to = V.v(tx, ty)
            end

            b.bullet.from = V.vclone(b.pos)

            queue_insert(store, b)
            U.y_wait(store, a.delay)
        end
    end

    queue_remove(store, this)
end

tt = RT("power_scorched_water_eb_10yr", "power_scorched_water")
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)

tt = RT("power_scorched_earth_eb_10yr", "power_scorched_earth")
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)

tt = RT("fireball_eb_10yr", "fireball_10yr")
tt.scorch_earth = true
tt.main_script.update = function(this, store)
    local b = this.bullet
    local mspeed = 10 * FPS
    local particle = E:create_entity("ps_power_fireball")

    particle.particle_system.track_id = this.id

    queue_insert(store, particle)

    local shadow = E:create_entity("decal_fireball_shadow")

    shadow.pos.x, shadow.pos.y = b.to.x, b.to.y
    shadow.render.sprites[1].ts = store.tick_ts

    queue_insert(store, shadow)

    local shadow_tracks = b.from.x ~= b.to.x

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
        mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
        mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
        this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

        if shadow_tracks then
            shadow.pos.x = this.pos.x
        end

        coroutine.yield()
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y
    particle.particle_system.source_lifetime = 0
    local targets = U.find_soldiers_in_range(store.soldiers or store.entities, b.to, 0, b.damage_radius, b.damage_flags,
        b.damage_bans) or {}

    local damage_value = math.ceil((b.damage_factor or 1) * math.random(b.damage_min, b.damage_max))

    for _, enemy in pairs(targets) do
        local d = E:create_entity("damage")

        d.source_id = this.id
        d.target_id = enemy.id
        d.value = damage_value
        d.damage_type = b.damage_type

        queue_damage(store, d)
    end

    S:queue(this.sound_events.hit)

    local cell_type = GR:cell_type(b.to.x, b.to.y)

    if band(cell_type, TERRAIN_WATER) ~= 0 then
        local fx = E:create_entity("fx_explosion_water")

        fx.pos.x, fx.pos.y = b.to.x, b.to.y
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)

        if this.scorch_earth then
            local scorched = E:create_entity("power_scorched_water_eb_10yr")

            scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

            for i = 1, #scorched.render.sprites do
                scorched.render.sprites[i].ts = store.tick_ts
            end

            queue_insert(store, scorched)
        end
    else
        if b.hit_decal then
            local decal = E:create_entity(b.hit_decal)

            decal.pos = V.vclone(b.to)
            decal.render.sprites[1].ts = store.tick_ts

            queue_insert(store, decal)
        end

        if b.hit_fx then
            local fx = E:create_entity(b.hit_fx)

            fx.pos.x, fx.pos.y = b.to.x, b.to.y
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        if this.scorch_earth then
            local scorched = E:create_entity("power_scorched_earth_eb_10yr")

            scorched.pos.x, scorched.pos.y = b.to.x, b.to.y

            for i = 1, #scorched.render.sprites do
                scorched.render.sprites[i].ts = store.tick_ts
            end

            queue_insert(store, scorched)
        end
    end

    queue_remove(store, shadow)
    queue_remove(store, this)
end
tt.bullet.damage_max = 70
tt.bullet.damage_min = 40

tt = RT("aura_eb_10yr_bomb", "aura_10yr_bomb")
tt.stun = {
    vis_flags = bor(F_RANGED, F_STUN),
    vis_bans = bor(F_FLYING, F_ENEMY),
    mod = "mod_eb_10yr_stun"
}
tt.aura.steps = 6
tt.aura.damage_min = 20
tt.aura.damage_max = 40
tt.aura.vis_bans = F_ENEMY
tt.main_script.update = function(this, store)
    local a = this.aura

    local function do_attack(pos, last_attack)
        local fx = E:create_entity(a.fx)

        fx.pos.x, fx.pos.y = pos.x, pos.y

        if not last_attack then
            fx.render.sprites[2].scale = V.v(0.8, 0.8)
        end

        fx.render.sprites[2].ts = store.tick_ts
        fx.tween.ts = store.tick_ts

        queue_insert(store, fx)

        local radius = last_attack and a.last_attack_damage_radius or a.damage_radius
        local targets = U.find_soldiers_in_range(store.soldiers or store.entities, pos, 0, radius, a.vis_flags,
            a.vis_bans)

        if targets then
            for _, t in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = math.random(a.damage_min, a.damage_max)
                d.damage_type = a.damage_type
                d.source_id = this.id
                d.target_id = t.id

                queue_damage(store, d)

                if (last_attack or math.random() < a.stun_chance) and U.flags_pass(t.vis, this.stun) then
                    local m = E:create_entity(this.stun.mod)

                    m.modifier.source_id = this.id
                    m.modifier.target_id = t.id

                    queue_insert(store, m)
                end
            end
        end
    end

    local pi, spi, ni, target, origin
    local target = U.find_nearest_soldier(store.soldiers or store.entities, this.pos, 0,
        a.max_nodes * P.average_node_dist, a.vis_flags, a.vis_bans)

    if not target then
        -- log.error("aura_10yr_bomb could not find valid enemies in the hero paths")
    else
        local nodes = P:nearest_nodes(target.pos.x, target.pos.y)
        local origin = nodes[1]
        pi, spi, ni = unpack(origin)

        for i = 1, a.steps do
            local nni = ni + i * a.step_nodes * (math.ceil(a.steps / 2) - i)

            spi = i == a.steps and 1 or (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

            U.y_wait(store, a.step_delay)

            local spos = P:node_pos(pi, spi, nni)

            do_attack(spos, i == a.steps)
        end
    end

    queue_remove(store, this)
end

tt = RT("mod_eb_10yr_stun", "mod_10yr_stun")
tt.modifier.vis_bans = F_FLYING
-- -- boss:elora
-- tt = RT("eb_elora", "hero_boss")
-- AC(tt, "melee", "ranged")
-- anchor_y = 0.17
-- anchor_x = 0.5
-- tt.health.armor = 0.5
-- tt.health.hp_max = 4500
-- tt.main_script.insert = scripts.enemy_basic.insert
-- tt.sound_events.death = "HeroFrostDeath"
-- tt.sound_events.insert = "HeroFrostTaunt"
-- tt.melee.range = 45
-- tt.melee.attacks[1].cooldown = 1.5
-- tt.melee.attacks[1].damage_max = 105
-- tt.melee.attacks[1].damage_min = 75
-- tt.melee.attacks[1].hit_time = fts(14)
-- tt.melee.attacks[1].sound = "MeleeSword"
-- tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
-- tt.info.i18n_key = "HERO_FROST_SORCERER"
-- tt.info.fn = scripts.hero_basic.get_info
-- tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0009" or "info_portraits_heroes_0009"
-- tt.motion.max_speed = 1.75 * FPS
-- tt.render.sprites[1].anchor = v(0.5, 0.17)
-- tt.render.sprites[1].prefix = "hero_elora"
-- tt.render.sprites[2] = CC("sprite")
-- tt.render.sprites[2].name = "hero_elora_frostEffect"
-- tt.render.sprites[2].anchor = v(0.5, 0.1)
-- tt.render.sprites[2].hidden = true
-- tt.render.sprites[2].loop = true
-- tt.render.sprites[2].ignore_start = true
-- tt.run_particles_name = "ps_elora_run"
-- tt.enemy.melee_slot_offset = v(12, 0)
-- tt.ui.click_rect = r(-15, -5, 30, 40)
-- tt.unit.mod_offset = v(0, 15)
-- tt.ranged.attacks[1] = E:clone_c("bullet_attack")
-- tt.ranged.attacks[1].cooldown = fts(40)
-- tt.ranged.attacks[1].bullet = "bolt_elora_boss_freeze"
-- tt.ranged.attacks[1].bullet_start_offset = {v(18, 36)}
-- tt.ranged.attacks[1].chance = 0.2
-- tt.ranged.attacks[1].filter_fn = scripts.hero_elora.freeze_filter_fn
-- tt.ranged.attacks[1].min_range = 23.04
-- tt.ranged.attacks[1].max_range = 166.4
-- tt.ranged.attacks[1].shoot_time = fts(19)
-- tt.ranged.attacks[1].shared_cooldown = true
-- tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
-- tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
-- tt.ranged.attacks[2].bullet = "bolt_elora_boss_slow"
-- tt.ranged.attacks[2].chance = 1
-- tt.ranged.attacks[2].filter_fn = nil

-- tt = RT("bolt_elora_boss_freeze", "bolt")
-- tt.bullet.vis_flags = F_RANGED
-- tt.bullet.vis_bans = 0
-- tt.render.sprites[1].prefix = "bolt_elora"
-- tt.bullet.hit_fx = "fx_bolt_elora_hit"
-- tt.bullet.pop = nil
-- tt.bullet.pop_conds = nil
-- tt.bullet.mod = "mod_elora_bolt_freeze"
-- tt.bullet.damage_min = 190
-- tt.bullet.damage_max = 505
-- tt.bullet.xp_gain_factor = 2
-- tt = RT("bolt_elora_boss_slow", "bolt_elora_boss_freeze")
-- tt.bullet.mod = "mod_elora_bolt_slow"

