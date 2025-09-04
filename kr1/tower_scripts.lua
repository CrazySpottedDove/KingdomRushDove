require("klua.table")
require("i18n")
local scripts = require("hero_scripts")
local AC = require("achievements")
local log = require("klua.log"):new("tower_scripts")
require("klua.table")
local km = require("klua.macros")
local signal = require("hump.signal")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local U = require("utils")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("klua.vector")
local W = require("wave_db")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local IS_PHONE = KR_TARGET == "phone"
local IS_CONSOLE = KR_TARGET == "console"

local function tpos(e)
    return
        e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or
            e.pos
end

local function enemy_ready_to_magic_attack(this, store, attack)
    return this.enemy.can_do_magic and store.tick_ts - attack.ts > attack.cooldown
end

local function ready_to_attack(attack, store, factor)
    return store.tick_ts - attack.ts > attack.cooldown * (factor or 1)
end

local function get_attack_ready(attack, store)
    attack.ts = store.tick_ts - attack.cooldown
end

local function enemy_is_silent_target(e)
    return (band(e.vis.flags, F_SPELLCASTER) ~= 0 or e.ranged or e.timed_attacks or e.auras or e.death_spawns) and
               e.enemy.can_do_magic
end

local function fts(v)
    return v / FPS
end

local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end
local function queue_damage(store, damage)
    store.damage_queue[#store.damage_queue + 1] = damage
end

local function soldiers_around_need_heal(this, store, trigger_hp_factor, range)
    local targets = table.filter(store.soldiers, function(k, v)
        return (not v.reinforcement) and (not v.health.dead and v.health.hp < trigger_hp_factor * v.health.hp_max) and
                   U.is_inside_ellipse(v.pos, this.pos, range)
    end)
    if not targets or #targets == 0 then
        return false
    else
        return true
    end
end

local function ready_to_use_power(power, power_attack, store, factor)
    return power.level > 0 and (store.tick_ts - power_attack.ts > power_attack.cooldown * (factor or 1)) and
               (not power_attack.silence_ts)
end
local function apply_precision(b)
    local u = UP:get_upgrade("archer_precision")
    if u and math.random() < u.chance then
        b.bullet.damage_min = b.bullet.damage_min * u.damage_factor
        b.bullet.damage_max = b.bullet.damage_max * u.damage_factor
        b.bullet.pop = {"pop_crit"}
        b.bullet.pop_conds = DR_DAMAGE
    end
end

-- 矮人射手
scripts.tower_archer_dwarf = {
    get_info = function(this)
        local pow = this.powers.extra_damage
        local a = this.attacks.list[1]
        local b = E:get_template(a.bullet)
        local min, max = b.bullet.damage_min, b.bullet.damage_max

        if pow.level > 0 then
            min = min + b.bullet.damage_inc * pow.level
            max = max + b.bullet.damage_inc * pow.level
        end

        min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

        local cooldown = a.cooldown

        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            range = this.attacks.range,
            cooldown = cooldown
        }

    end,
    update = function(this, store, script)
        local at = this.attacks
        local as = this.attacks.list[1]
        local ab = this.attacks.list[2]
        local pow_b = this.powers.barrel
        local pow_e = this.powers.extra_damage
        local shooter_sprite_ids = {3, 4}
        local shots_count = 1
        local last_target_pos = V.v(0, 0)
        local a, pow, enemy, _, pred_pos

        while true do
            if this.tower.blocked then
                -- block empty
            else
                if pow_b.changed then
                    pow_b.changed = nil
                    if pow_b.level == 1 then
                        ab.ts = store.tick_ts
                    end
                end

                a = nil
                pow = nil

                SU.tower_update_silenced_powers(store, this)

                if ready_to_use_power(pow_b, ab, store, this.tower.cooldown_factor) then
                    enemy, pred_pos = U.find_random_enemy_with_pos(store, tpos(this), 0, at.range, ab.node_prediction,
                        ab.vis_flags, ab.vis_bans)
                    if enemy then
                        a = ab
                        pow = pow_b
                    end
                end

                if not a and ready_to_attack(as, store, this.tower.cooldown_factor) then
                    enemy, _, pred_pos = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, at.range,
                        as.node_prediction, as.vis_flags, as.vis_bans)

                    if enemy then
                        a = as
                        pow = pow_e
                    end
                end

                if a then
                    last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y
                    a.ts = store.tick_ts
                    shots_count = shots_count + 1

                    local shooter_idx = shots_count % 2 + 1
                    local shooter_sid = shooter_sprite_ids[shooter_idx]
                    local start_offset = a.bullet_start_offset[shooter_idx]
                    local an, af =
                        U.animation_name_facing_point(this, a.animation, enemy.pos, shooter_sid, start_offset)

                    U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

                    while store.tick_ts - a.ts < a.shoot_time do
                        coroutine.yield()
                    end

                    local b1 = E:create_entity(a.bullet)

                    b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                    b1.bullet.damage_factor = this.tower.damage_factor
                    b1.bullet.from = V.vclone(b1.pos)
                    b1.bullet.to = pred_pos
                    b1.bullet.target_id = enemy.id
                    b1.bullet.source_id = this.id
                    b1.bullet.level = pow.level

                    if (b1.template_name == "dwarf_shotgun") then
                        apply_precision(b1)
                    end
                    queue_insert(store, b1)

                    while not U.animation_finished(this, shooter_sid) do
                        coroutine.yield()
                    end

                    an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

                    U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                else
                    U.y_wait(store, this.tower.guard_time)
                end
            end

            coroutine.yield()
        end
    end
}
-- 游侠
scripts.tower_ranger = {
    update = function(this, store)
        local shooter_sids = {3, 4}
        local shooter_idx = 2
        local druid_sid = 5
        local a = this.attacks
        local aa = this.attacks.list[1]
        local pow_p = this.powers.poison
        local pow_t = this.powers.thorn

        aa.ts = store.tick_ts

        local function shot_animation(attack, shooter_idx, enemy)
            local ssid = shooter_sids[shooter_idx]
            local soffset = this.render.sprites[ssid].offset
            local s = this.render.sprites[ssid]
            local an, af = U.animation_name_facing_point(this, attack.animation, enemy.pos, ssid, soffset)

            U.animation_start(this, an, af, store.tick_ts, 1, ssid)

            return U.animation_name_facing_point(this, "idle", enemy.pos, ssid, soffset)
        end

        local function shot_bullet(attack, shooter_idx, enemy, level)
            local ssid = shooter_sids[shooter_idx]
            local shooting_up = tpos(this).y < enemy.pos.y
            local shooting_right = tpos(this).x < enemy.pos.x
            local soffset = this.render.sprites[ssid].offset
            local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]
            local b = E:create_entity(attack.bullet)

            b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
            b.pos.y = this.pos.y + soffset.y + boffset.y
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
            b.bullet.target_id = enemy.id
            b.bullet.level = level
            b.bullet.damage_factor = this.tower.damage_factor
            if pow_p.level > 0 then
                if not b.bullet.mods then
                    b.bullet.mods = pow_p.level > 0 and pow_p.mods
                else
                    b.bullet.mods = table.append(b.bullet.mods, pow_p.mods)
                end
                if b.bullet.mod then
                    if type(b.bullet.mod) == "table" then
                        b.bullet.mods = table.append(b.bullet.mods, b.bullet.mod)
                        b.bullet.mod = nil
                    else
                        table.insert(b.bullet.mods, b.bullet.mod)
                        b.bullet.mod = nil
                    end
                end
            end

            apply_precision(b)

            queue_insert(store, b)
        end

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow == pow_t and this.render.sprites[druid_sid].hidden then
                            this.render.sprites[druid_sid].hidden = false

                            local ta = E:create_entity(pow_t.aura)
                            ta.aura.source_id = this.id
                            ta.pos = tpos(this)
                            queue_insert(store, ta)
                        end
                    end
                end
                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range,
                        false, aa.vis_flags, aa.vis_bans)

                    if not enemy then
                        U.y_wait(store, this.tower.guard_time)
                        -- block empty
                    else
                        if pow_p.level > 0 then
                            local poisonable = table.filter(enemies, function(_, e)
                                return not U.flag_has(e.vis.bans, F_POISON) and
                                           not U.has_modifiers(store, e, pow_p.mods[1])
                            end)

                            if #poisonable > 0 then
                                enemy = poisonable[1]
                            end
                        end

                        aa.ts = store.tick_ts
                        shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                        local idle_an, idle_af = shot_animation(aa, shooter_idx, enemy)

                        U.y_wait(store, aa.shoot_time)
                        if enemy.health.dead then
                            U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
                        end

                        shot_bullet(aa, shooter_idx, enemy, pow_p.level)

                        U.y_animation_wait(this, shooter_sids[shooter_idx])
                        U.animation_start(this, idle_an, idle_af, store.tick_ts, false, shooter_sids[shooter_idx])
                    end
                end

                if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
                    for _, sid in pairs(shooter_sids) do
                        local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                        U.animation_start(this, an, af, store.tick_ts, -1, sid)
                    end
                end

                coroutine.yield()
            end
        end
    end
}
-- 火枪
scripts.tower_musketeer = {
    update = function(this, store)
        local shooter_sids = {3, 4}
        local shooter_idx = 2
        local a = this.attacks
        local aa = this.attacks.list[1]
        local asn = this.attacks.list[2]
        local asi = this.attacks.list[3]
        local ash = this.attacks.list[4]
        local pow_sn = this.powers.sniper
        local pow_sh = this.powers.shrapnel

        aa.ts = store.tick_ts

        local function shot_animation(attack, shooter_idx, enemy, animation)
            local ssid = shooter_sids[shooter_idx]
            local soffset = this.render.sprites[ssid].offset
            local s = this.render.sprites[ssid]
            local an, af, ai = U.animation_name_facing_point(this, animation or attack.animation, enemy.pos, ssid,
                soffset)

            U.animation_start(this, an, af, store.tick_ts, 1, ssid)

            return an, af, ai
        end

        local function shot_bullet(attack, shooter_idx, ani_idx, enemy, level)
            local ssid = shooter_sids[shooter_idx]
            local shooting_right = tpos(this).x < enemy.pos.x
            local soffset = this.render.sprites[ssid].offset
            local boffset = attack.bullet_start_offset[ani_idx]
            local b = E:create_entity(attack.bullet)

            b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
            b.pos.y = this.pos.y + soffset.y + boffset.y
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
            b.bullet.target_id = enemy.id
            b.bullet.level = level
            b.bullet.damage_factor = this.tower.damage_factor

            if attack == asn then
                b.bullet.damage_type = DAMAGE_SHOT
                if band(enemy.vis.flags, F_BOSS) ~= 0 then
                    b.bullet.damage_max = b.bullet.damage_max * (6 + 2 * pow_sn.level)
                    b.bullet.damage_min = b.bullet.damage_min * (6 + 2 * pow_sn.level)
                else
                    local extra_damage = pow_sn.damage_factor_inc * pow_sn.level * enemy.health.hp_max
                    b.bullet.damage_max = b.bullet.damage_max + extra_damage
                    b.bullet.damage_min = b.bullet.damage_min + extra_damage
                end
            end

            apply_precision(b)

            queue_insert(store, b)

            return b
        end

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow.level == 1 then
                            for _, ax in pairs(a.list) do
                                if ax.power_name and this.powers[ax.power_name] == pow then
                                    ax.ts = store.tick_ts
                                end
                            end
                        end

                        if pow == pow_sn then
                            asi.chance = pow_sn.instakill_chance_inc * pow_sn.level
                        end
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                if pow_sn.level > 0 then
                    for _, ax in pairs({asi, asn}) do
                        if (ax.chance == 1 or math.random() < ax.chance) and
                            ready_to_use_power(pow_sn, ax, store, this.tower.cooldown_factor) then
                            local enemy = U.find_biggest_enemy(store, tpos(this), 0, ax.range, false, ax.vis_flags,
                                ax.vis_bans)

                            if not enemy then
                                break
                            end

                            if (band(enemy.vis.flags, F_BOSS) ~= 0 or band(enemy.vis.bans, F_INSTAKILL) ~= 0) and ax ==
                                asi then
                                goto continue_ax
                            end

                            for _, axx in pairs({aa, asi, asn}) do
                                axx.ts = store.tick_ts
                            end

                            shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                            local seeker_idx = km.zmod(shooter_idx + 1, #shooter_sids)
                            local an, af, ai = shot_animation(ax, shooter_idx, enemy)

                            local m = E:create_entity("mod_van_helsing_crosshair")
                            m.modifier.source_id = this.id
                            m.modifier.target_id = enemy.id
                            m.render.sprites[1].ts = store.tick_ts
                            queue_insert(store, m)

                            shot_animation(ax, seeker_idx, enemy, ax.animation_seeker)
                            U.y_wait(store, ax.shoot_time)

                            if enemy.health.dead then
                                U.refind_foremost_enemy(enemy, store, ax.vis_flags, ax.vis_bans)
                            end

                            shot_bullet(ax, shooter_idx, ai, enemy, pow_sn.level)

                            U.y_animation_wait(this, shooter_sids[shooter_idx])
                            queue_remove(store, m)
                        end
                        ::continue_ax::
                    end
                end

                if ready_to_use_power(pow_sh, ash, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, ash.range * 1.5, false,
                        ash.vis_flags, ash.vis_bans, nil, nil, ash.min_spread + 48)
                    if not enemy then
                        -- block empty
                    else
                        local distance = V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y)

                        ash.ts = store.tick_ts
                        aa.ts = store.tick_ts

                        local distance_factor = 1
                        local spread_factor = 1
                        if distance > ash.range then
                            distance_factor = 0.6
                            spread_factor = 1.5
                            ash.ts = ash.ts - 0.4 * ash.cooldown
                        end

                        shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                        local fuse_idx = km.zmod(shooter_idx + 1, #shooter_sids)
                        local ssid = shooter_sids[shooter_idx]
                        local fsid = shooter_sids[fuse_idx]
                        local an, af, ai = shot_animation(ash, shooter_idx, enemy)

                        shot_animation(ash, fuse_idx, enemy, ash.animation_seeker)

                        this.render.sprites[fsid].flip_x = fuse_idx < shooter_idx
                        this.render.sprites[ssid].draw_order = 5

                        U.y_wait(store, ash.shoot_time)

                        local shooting_right = tpos(this).x < enemy.pos.x
                        local soffset = this.render.sprites[ssid].offset
                        local boffset = ash.bullet_start_offset[ai]
                        local dest_pos = P:predict_enemy_pos(enemy, ash.node_prediction)
                        local src_pos = V.v(this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1),
                            this.pos.y + soffset.y + boffset.y)
                        local fx = SU.insert_sprite(store, ash.shoot_fx, src_pos)

                        fx.render.sprites[1].r = V.angleTo(dest_pos.x - src_pos.x, dest_pos.y - src_pos.y)

                        for i = 1, ash.loops do
                            local b = E:create_entity(ash.bullet)

                            b.bullet.flight_time = U.frandom(b.bullet.flight_time_min, b.bullet.flight_time_max)
                            b.pos = V.vclone(src_pos)
                            b.bullet.from = V.vclone(src_pos)
                            b.bullet.to = U.point_on_ellipse(dest_pos, U.frandom(ash.min_spread * spread_factor,
                                ash.max_spread * spread_factor), (i - 1) * 2 * math.pi / ash.loops)
                            b.bullet.level = pow_sh.level
                            b.bullet.damage_factor = this.tower.damage_factor * distance_factor
                            queue_insert(store, b)
                        end

                        U.y_animation_wait(this, shooter_sids[shooter_idx])

                        this.render.sprites[ssid].draw_order = nil
                    end
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range,
                        false, aa.vis_flags, aa.vis_bans)

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        aa.ts = store.tick_ts
                        shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                        local an, af, ai = shot_animation(aa, shooter_idx, enemy)

                        U.y_wait(store, aa.shoot_time)

                        if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
                            shot_bullet(aa, shooter_idx, ai, enemy, 0)
                        end

                        U.y_animation_wait(this, shooter_sids[shooter_idx])
                    end
                end

                if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
                    for _, sid in pairs(shooter_sids) do
                        local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                        U.animation_start(this, an, af, store.tick_ts, -1, sid)
                    end
                end

                coroutine.yield()
            end
        end
    end
}
-- 弩堡
scripts.tower_crossbow = {
    remove = function(this, store, script)
        local mods = table.filter(store.modifiers, function(_, e)
            return e.modifier and e.modifier.source_id == this.id
        end)

        for _, m in pairs(mods) do
            queue_remove(store, m)
        end

        if this.eagle_previews then
            for _, decal in pairs(this.eagle_previews) do
                queue_remove(store, decal)
            end

            this.eagle_previews = nil
        end
        return true
    end,
    update = function(this, store, script)
        local shooter_sprite_ids = {3, 4}
        local a = this.attacks
        local aa = this.attacks.list[1]
        local ma = this.attacks.list[2]
        local ea = this.attacks.list[3]
        local last_target_pos = V.v(0, 0)
        local shots_count = 0
        local pow_m = this.powers.multishot
        local pow_e = this.powers.eagle
        local eagle_ts = 0
        local eagle_sid = 5

        this.eagle_previews = nil

        local eagle_previews_level

        aa.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                if this.eagle_previews then
                    for _, decal in pairs(this.eagle_previews) do
                        queue_remove(store, decal)
                    end

                    this.eagle_previews = nil
                end
            else
                if this.ui.hover_active and this.ui.args == "eagle" and
                    (not this.eagle_previews or eagle_previews_level ~= pow_e.level) then
                    if this.eagle_previews then
                        for _, decal in pairs(this.eagle_previews) do
                            queue_remove(store, decal)
                        end
                    end

                    this.eagle_previews = {}
                    eagle_previews_level = pow_e.level

                    local mods = table.filter(store.modifiers, function(_, e)
                        return e.modifier and e.modifier.source_id == this.id
                    end)
                    local modded_ids = {}

                    for _, m in pairs(mods) do
                        table.insert(modded_ids, m.modifier.target_id)
                    end

                    local range = ea.range + km.clamp(1, 3, pow_e.level + 1) * ea.range_inc
                    local targets = table.filter(store.towers, function(_, e)
                        return e ~= this and not table.contains(modded_ids, e.id) and
                                   U.is_inside_ellipse(e.pos, this.pos, range)
                    end)

                    for _, target in pairs(targets) do
                        local decal = E:create_entity("decal_crossbow_eagle_preview")

                        decal.pos = target.pos
                        decal.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, decal)
                        table.insert(this.eagle_previews, decal)
                    end
                elseif this.eagle_previews and (not this.ui.hover_active or this.ui.args ~= "eagle") then
                    for _, decal in pairs(this.eagle_previews) do
                        queue_remove(store, decal)
                    end

                    this.eagle_previews = nil
                end

                if pow_m.changed then
                    pow_m.changed = nil
                    ma.near_range = ma.near_range_base + ma.near_range_inc * pow_m.level
                    if pow_m.level == 1 then
                        ma.ts = store.tick_ts
                    end
                end

                if pow_e.changed then
                    pow_e.changed = nil

                    if pow_e.level == 1 then
                        ea.ts = store.tick_ts
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                if pow_e.level > 0 then
                    if ready_to_attack(ea, store) then
                        ea.ts = store.tick_ts

                        local eagle_range = ea.range + ea.range_inc * pow_e.level
                        local existing_mods = table.filter(store.modifiers, function(_, e)
                            return e.template_name == ea.mod and e.modifier.level >= pow_e.level
                        end)
                        local busy_ids = table.map(existing_mods, function(k, v)
                            return v.modifier.target_id
                        end)
                        local towers = table.filter(store.towers, function(_, e)
                            return e.tower.can_be_mod and not table.contains(busy_ids, e.id) and
                                       U.is_inside_ellipse(e.pos, this.pos, eagle_range)
                        end)

                        for _, tower in pairs(towers) do
                            local new_mod = E:create_entity(ea.mod)
                            new_mod.modifier.level = pow_e.level
                            new_mod.modifier.target_id = tower.id
                            new_mod.modifier.source_id = this.id
                            new_mod.pos = tower.pos
                            queue_insert(store, new_mod)
                        end
                    end

                    if store.tick_ts - eagle_ts > ea.fly_cooldown then
                        this.render.sprites[eagle_sid].hidden = false
                        eagle_ts = store.tick_ts

                        U.animation_start(this, "fly", nil, store.tick_ts, 1, eagle_sid)
                        S:queue("CrossbowEagle")
                    end
                end

                if ready_to_use_power(pow_m, ma, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range, false,
                        ma.vis_flags, ma.vis_bans)

                    if not enemy then
                        -- block empty
                    else
                        ma.ts = store.tick_ts
                        shots_count = shots_count + 1
                        last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

                        local shooter_idx = shots_count % 2 + 1
                        local shooter_sid = shooter_sprite_ids[shooter_idx]
                        local start_offset = ma.bullet_start_offset[shooter_idx]

                        this.render.sprites[shooter_sid].draw_order = 5

                        local an, af = U.animation_name_facing_point(this, "multishot_start", enemy.pos, shooter_sid,
                            start_offset)

                        U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        an, af = U.animation_name_facing_point(this, "multishot_loop", enemy.pos, shooter_sid,
                            start_offset)

                        U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)

                        local last_enemy = enemy
                        local loop_ts = store.tick_ts
                        local torigin = tpos(this)
                        local range = ma.near_range
                        for i = 1, ma.shots + pow_m.level * ma.shots_inc do
                            local origin = last_enemy.pos

                            while store.tick_ts - loop_ts < ma.shoot_time do
                                coroutine.yield()
                            end

                            if last_enemy.health.dead then
                                enemy = U.find_foremost_enemy_with_flying_preference(store, origin, 0, range, false,
                                    ma.vis_flags, ma.vis_bans)
                            end

                            local shoot_pos, target_id, enemy_id

                            if enemy then
                                last_enemy = enemy
                                enemy_id = enemy.id
                                shoot_pos = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                    enemy.pos.y + enemy.unit.hit_offset.y)
                            else
                                enemy_id = nil
                                shoot_pos = V.v(last_enemy.pos.x, last_enemy.pos.y)
                            end

                            local b = E:create_entity(ma.bullet)
                            b.bullet.damage_factor = this.tower.damage_factor
                            if pow_e.level > 0 then
                                local crit_chance = aa.critical_chance + pow_e.level * aa.critical_chance_inc

                                if crit_chance > math.random() then
                                    b.bullet.damage_factor = b.bullet.damage_factor * 2
                                    b.bullet.pop = {"pop_crit"}
                                    b.bullet.pop_conds = DR_DAMAGE
                                end
                            end
                            b.bullet.target_id = enemy_id
                            b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
                            b.bullet.to = shoot_pos
                            b.pos = V.vclone(b.bullet.from)
                            apply_precision(b)
                            queue_insert(store, b)
                            -- AC:inc_check("BOLTOFTHESUN", 1)

                            while store.tick_ts - loop_ts < ma.cycle_time do
                                coroutine.yield()
                            end

                            loop_ts = 2 * store.tick_ts - (loop_ts + ma.cycle_time)
                        end

                        local an, af = U.animation_name_facing_point(this, "multishot_end", last_enemy.pos, shooter_sid,
                            start_offset)

                        U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

                        this.render.sprites[shooter_sid].draw_order = nil

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end
                    end
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range, false,
                        aa.vis_flags, aa.vis_bans)

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        aa.ts = store.tick_ts
                        shots_count = shots_count + 1
                        last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

                        local shooter_idx = shots_count % 2 + 1
                        local shooter_sid = shooter_sprite_ids[shooter_idx]
                        local start_offset = aa.bullet_start_offset[shooter_idx]

                        this.render.sprites[shooter_sid].draw_order = 5

                        local an, af =
                            U.animation_name_facing_point(this, "shoot", enemy.pos, shooter_sid, start_offset)

                        U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

                        while store.tick_ts - aa.ts < aa.shoot_time do
                            coroutine.yield()
                        end

                        local torigin = tpos(this)

                        if enemy.health.dead then
                            U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
                        end
                        local b1 = E:create_entity(aa.bullet)
                        b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                        b1.bullet.from = V.vclone(b1.pos)
                        b1.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
                        b1.bullet.target_id = enemy.id
                        b1.bullet.damage_factor = this.tower.damage_factor

                        if pow_e.level > 0 then
                            local crit_chance = aa.critical_chance + pow_e.level * aa.critical_chance_inc
                            if crit_chance > math.random() then
                                b1.bullet.damage_factor = b1.bullet.damage_factor * 2
                                b1.bullet.pop = {"pop_crit"}
                                b1.bullet.pop_conds = DR_DAMAGE
                            end
                        end

                        apply_precision(b1)
                        queue_insert(store, b1)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

                        U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)

                        this.render.sprites[shooter_sid].draw_order = nil
                    end
                end

                if store.tick_ts - math.max(aa.ts, ma.ts) > this.tower.long_idle_cooldown then
                    for _, sid in pairs(shooter_sprite_ids) do
                        local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                        U.animation_start(this, an, af, store.tick_ts, -1, sid)
                    end
                end
            end

            coroutine.yield()
        end
    end
}
-- 图腾
scripts.tower_totem = {
    update = function(this, store, script)
        local last_target_pos = V.v(0, 0)
        local shots_count = 0
        local shooter_sprite_ids = {3, 4}
        local a = this.attacks
        local aa = this.attacks.list[1]
        local eyes_sids = {8, 7}
        local attack_ids = {2, 3}

        aa.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                -- block empty
            else
                SU.tower_update_silenced_powers(store, this)

                for i, name in ipairs({"weakness", "silence"}) do
                    local pow = this.powers[name]
                    local ta = this.attacks.list[attack_ids[i]]

                    if pow.changed then
                        pow.changed = nil
                        this.render.sprites[eyes_sids[i]].hidden = false

                        if pow.level == 1 then
                            this.render.sprites[eyes_sids[i]].ts = store.tick_ts
                            ta.ts = store.tick_ts
                        end
                    end

                    if ready_to_use_power(pow, ta, store, this.tower.cooldown_factor) then
                        local enemy
                        if name == "silence" then
                            enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ta.vis_flags,
                                ta.vis_bans, enemy_is_silent_target)
                        else
                            enemy = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range, false,
                                ta.vis_flags, ta.vis_bans, nil, nil, 80)
                        end

                        if not enemy then
                            -- block empty
                        else
                            ta.ts = store.tick_ts
                            this.render.sprites[eyes_sids[i]].ts = store.tick_ts

                            local node_offset = math.random(-4, 8)
                            local totem_node = enemy.nav_path.ni

                            if P:is_node_valid(enemy.nav_path.pi, enemy.nav_path.ni + node_offset) then
                                totem_node = totem_node + node_offset
                            end

                            local totem_pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, totem_node)
                            local b = E:create_entity(ta.bullet)

                            b.pos.x, b.pos.y = totem_pos.x, totem_pos.y
                            b.aura.level = pow.level
                            b.aura.ts = store.tick_ts
                            b.aura.source_id = this.id
                            b.render.sprites[1].ts = store.tick_ts
                            b.render.sprites[2].ts = store.tick_ts
                            b.render.sprites[3].ts = store.tick_ts

                            queue_insert(store, b)
                        end
                    end
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range, false,
                        aa.vis_flags, aa.vis_bans)

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        aa.ts = store.tick_ts
                        shots_count = shots_count + 1
                        last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y

                        local shooter_idx = shots_count % 2 + 1
                        local shooter_sid = shooter_sprite_ids[shooter_idx]
                        local start_offset = aa.bullet_start_offset[shooter_idx]
                        local an, af = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid,
                            start_offset)

                        U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

                        while store.tick_ts - aa.ts < aa.shoot_time do
                            coroutine.yield()
                        end

                        if enemy.health.dead then
                            U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
                        end

                        local b1 = E:create_entity(aa.bullet)

                        b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                        b1.bullet.damage_factor = this.tower.damage_factor
                        b1.bullet.from = V.vclone(b1.pos)
                        b1.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
                        b1.bullet.target_id = enemy.id

                        apply_precision(b1)

                        queue_insert(store, b1)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

                        U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
                    end
                end

                if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
                    for _, sid in pairs(shooter_sprite_ids) do
                        local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                        U.animation_start(this, an, af, store.tick_ts, -1, sid)
                    end
                end
            end

            coroutine.yield()
        end
    end
}
-- 海盗射手
scripts.tower_pirate_watchtower = {
    get_info = function(this)
        local a = this.attacks.list[1]
        local b = E:get_template(a.bullet)
        local min, max = b.bullet.damage_min, b.bullet.damage_max

        min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            range = this.attacks.range,
            cooldown = a.cooldown
        }
    end,
    remove = function(this, store)
        for _, parrot in pairs(this.parrots) do
            parrot.owner = nil
            queue_remove(store, parrot)
        end
        return true
    end,
    update = function(this, store)
        local at = this.attacks
        local a = this.attacks.list[1]
        local pow_c = this.powers.reduce_cooldown
        local pow_p = this.powers.parrot
        local shooter_sid = 3
        local last_target_pos = V.v(0, 0)

        while true do
            if this.tower.blocked then
                -- block empty
            else
                if pow_c.changed then
                    pow_c.changed = nil
                    a.cooldown = pow_c.values[pow_c.level]
                end

                if pow_p.changed then
                    pow_p.changed = nil
                    for i = 1, (pow_p.level - #this.parrots) do
                        local e = E:create_entity("pirate_watchtower_parrot")

                        e.bombs_pos = V.v(this.pos.x + 12, this.pos.y + 6)
                        e.idle_pos = V.v(this.pos.x + (#this.parrots == 0 and -20 or 20), this.pos.y)
                        e.pos = V.vclone(e.idle_pos)
                        e.owner = this

                        queue_insert(store, e)
                        table.insert(this.parrots, e)
                    end
                end

                if ready_to_attack(a, store, this.tower.cooldown_factor) then
                    local enemy, _, pred_pos = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0,
                        at.range, a.node_prediction, a.vis_flags, a.vis_bans)

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        last_target_pos.x, last_target_pos.y = enemy.pos.x, enemy.pos.y
                        a.ts = store.tick_ts

                        local start_offset = a.bullet_start_offset[1]
                        local an, af = U.animation_name_facing_point(this, a.animation, enemy.pos, shooter_sid,
                            start_offset)

                        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

                        while store.tick_ts - a.ts < a.shoot_time do
                            coroutine.yield()
                        end

                        if enemy.health.dead then
                            U.refind_foremost_enemy(enemy, store, a.vis_flags, a.vis_bans)
                        end

                        local b1 = E:create_entity(a.bullet)

                        b1.pos.x, b1.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                        b1.bullet.damage_factor = this.tower.damage_factor
                        b1.bullet.from = V.vclone(b1.pos)
                        b1.bullet.to = pred_pos
                        b1.bullet.target_id = enemy.id
                        b1.bullet.source_id = this.id

                        apply_precision(b1)

                        queue_insert(store, b1)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        an, af = U.animation_name_facing_point(this, "idle", last_target_pos, shooter_sid, start_offset)

                        U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                    end
                end
            end
            coroutine.yield()
        end
    end
}
-- 奥术弓手
scripts.tower_arcane = {
    get_info = function(this)
        local o = scripts.tower_common.get_info(this)
        o.damage_max = o.damage_max * 2
        o.damage_min = o.damage_min * 2
        return o
    end,
    update = function(this, store)
        local shooter_sids = {3, 4}
        local shooter_idx = 2
        local a = this.attacks
        local aa = this.attacks.list[1]

        local function shot_animation(attack, shooter_idx, enemy)
            local ssid = shooter_sids[shooter_idx]
            local soffset = this.render.sprites[ssid].offset
            local s = this.render.sprites[ssid]
            local an, af = U.animation_name_facing_point(this, attack.animation, enemy.pos, ssid, soffset)

            U.animation_start(this, an, af, store.tick_ts, 1, ssid)
        end

        local function shot_bullet(attack, shooter_idx, enemy, level)
            local ssid = shooter_sids[shooter_idx]
            local shooting_up = tpos(this).y < enemy.pos.y
            local shooting_right = tpos(this).x < enemy.pos.x
            local soffset = this.render.sprites[ssid].offset
            local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]

            local b = E:create_entity(attack.bullet)
            b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
            b.pos.y = this.pos.y + soffset.y + boffset.y
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
            b.bullet.target_id = enemy.id
            b.bullet.level = level
            b.bullet.damage_factor = this.tower.damage_factor
            if attack.bullet == "arrow_arcane_burst" then
                b.bullet.payload_props["sleep_chance"] = this.attacks.list[3].chance * 5
            end
            apply_precision(b)

            local dist = V.dist(b.bullet.to.x, b.bullet.to.y, b.bullet.from.x, b.bullet.from.y)

            b.bullet.flight_time = b.bullet.flight_time_min + dist / a.range * b.bullet.flight_time_factor

            -- local u = UP:get_upgrade("archer_el_obsidian_heads")

            -- if u and enemy.health and enemy.health.armor == 0 then
            --     b.bullet.damage_min = b.bullet.damage_max
            -- end

            queue_insert(store, b)
        end

        aa.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if this.powers.burst.changed then
                    this.powers.burst.changed = nil

                    if this.powers.burst.level == 1 then
                        this.attacks.list[2].ts = store.tick_ts
                    end
                end

                if this.powers.slumber.changed then
                    this.powers.slumber.changed = nil
                    this.attacks.list[3].chance = this.attacks.list[3].chance_base + this.powers.slumber.level *
                                                      this.attacks.list[3].chance_inc
                end

                SU.tower_update_silenced_powers(store, this)

                local sa = this.attacks.list[2]
                local pow = this.powers.burst
                if ready_to_use_power(pow, sa, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range, false,
                        sa.vis_flags, sa.vis_bans, nil, nil, 57.5)

                    if not enemy then
                        -- block empty
                    else
                        sa.ts = store.tick_ts
                        shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                        shot_animation(sa, shooter_idx, enemy)

                        while store.tick_ts - sa.ts < sa.shoot_time do
                            coroutine.yield()
                        end

                        if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range * 1.1 then
                            shot_bullet(sa, shooter_idx, enemy, pow.level)
                        end

                        U.y_animation_wait(this, shooter_sids[shooter_idx])
                    end
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range,
                        false, aa.vis_flags, aa.vis_bans)

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        aa.ts = store.tick_ts

                        for i = 1, #shooter_sids do
                            shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)
                            enemy = enemies[km.zmod(shooter_idx, #enemies)]

                            shot_animation(aa, shooter_idx, enemy)

                            if i == 1 then
                                U.y_wait(store, aa.shooters_delay)
                            end
                        end

                        while store.tick_ts - aa.ts < aa.shoot_time do
                            coroutine.yield()
                        end

                        for i = 1, #shooter_sids do
                            shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)
                            enemy = enemies[km.zmod(shooter_idx, #enemies)]

                            if enemy.health.dead then
                                U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
                            end

                            if enemy.health and enemy.health.magic_armor > 0 then
                                sa.ts = sa.ts - 0.3
                            end
                            if math.random() < this.attacks.list[3].chance and band(enemy.vis.bans, F_STUN) == 0 and
                                band(enemy.vis.flags, F_BOSS) == 0 then
                                shot_bullet(this.attacks.list[3], shooter_idx, enemy, this.powers.slumber.level)
                            else
                                shot_bullet(aa, shooter_idx, enemy, 0)
                            end

                            if i == 1 then
                                U.y_wait(store, aa.shooters_delay)
                            end
                        end

                        U.y_animation_wait(this, shooter_sids[shooter_idx])
                    end
                end

                if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
                    for _, sid in pairs(shooter_sids) do
                        local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                        U.animation_start(this, an, af, store.tick_ts, -1, sid)
                    end
                end

                coroutine.yield()
            end
        end

    end
}
-- 黄金长弓
scripts.tower_silver = {
    get_info = function(this)
        local o = scripts.tower_common.get_info(this)
        o.cooldown = 1.5
        return o
    end,
    update = function(this, store)
        local a = this.attacks
        local aa = this.attacks.list[1]
        local as = this.attacks.list[2]
        local am = this.attacks.list[3]
        local pow_s = this.powers.sentence
        local pow_m = this.powers.mark
        local sid = 3

        local function is_long(enemy)
            return V.dist2(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) > a.short_range * a.short_range
        end

        local function y_do_shot(attack, enemy, level)
            S:queue(attack.sound, attack.sound_args)

            local lidx = is_long(enemy) and 2 or 1
            local soffset = this.render.sprites[sid].offset
            local an, af, ai = U.animation_name_facing_point(this, attack.animations[lidx], enemy.pos, sid, soffset)

            U.animation_start(this, an, af, store.tick_ts, false, sid)

            local shoot_time = attack.shoot_times[lidx]

            U.y_wait(store, shoot_time)

            if enemy.health.dead then
                U.refind_foremost_enemy(enemy, store, attack.vis_flags, attack.vis_bans)
            end

            if V.dist2(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range * a.range then
                local boffset = attack.bullet_start_offsets[lidx][ai]
                local b = E:create_entity(attack.bullets[lidx])

                b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
                b.pos.y = this.pos.y + soffset.y + boffset.y
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
                b.bullet.target_id = enemy.id
                b.bullet.level = level or 0
                b.bullet.damage_factor = this.tower.damage_factor
                apply_precision(b)
                local dist = V.dist(b.bullet.to.x, b.bullet.to.y, b.bullet.from.x, b.bullet.from.y)

                b.bullet.flight_time = b.bullet.flight_time_min + dist * b.bullet.flight_time_factor

                if attack.critical_chances and math.random() < attack.critical_chances[lidx] then
                    b.bullet.damage_factor = 2 * b.bullet.damage_factor
                    b.bullet.pop = {"pop_crit"}
                    b.bullet.pop_conds = DR_DAMAGE
                    b.bullet.damage_type = DAMAGE_TRUE
                end

                -- if attack.use_obsidian_upgrade then
                --     local u = UP:get_upgrade("archer_el_obsidian_heads")

                --     if u and enemy.health and enemy.health.armor == 0 then
                --         b.bullet.damage_min = b.bullet.damage_max
                --     end
                -- end

                if b.template_name == "arrow_silver_sentence" or b.template_name == "arrow_silver_sentence_long" then
                    b.bullet.damage_factor = b.bullet.damage_factor * (4 + 2 * pow_s.level)
                    if band(enemy.vis.flags, F_BOSS) ~= 0 then
                        b.bullet.damage_factor = b.bullet.damage_factor / 1.5
                    end
                end

                queue_insert(store, b)

                if attack.shot_fx then
                    local fx = E:create_entity(attack.shot_fx)

                    fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y

                    local bb = b.bullet

                    fx.render.sprites[1].r = V.angleTo(bb.to.x - bb.from.x, bb.to.y - bb.from.y)
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                end
            end

            U.y_animation_wait(this, sid)

            an, af = U.animation_name_facing_point(this, "idle", enemy.pos, sid, soffset)

            U.animation_start(this, an, af, store.tick_ts, true, sid)
        end

        local function reset_cooldowns(long)
            aa.ts = store.tick_ts
            as.ts = store.tick_ts
            aa.cooldown = long and aa.cooldowns[2] or aa.cooldowns[1]
            as.cooldown = long and as.cooldowns[2] or as.cooldowns[1]
        end

        aa.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow.level == 1 then
                            local pa = this.attacks.list[pow.attack_idx]
                            pa.ts = store.tick_ts
                        end

                        if k == "mark" then
                            this.attacks.list[3].cooldown = this.attacks.list[3].cooldown +
                                                                this.attacks.list[3].cooldown_inc
                        end
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                if ready_to_use_power(pow_m, am, store, this.tower.cooldown_factor) then
                    local enemy = U.find_biggest_enemy(store, tpos(this), 0, a.range, false, am.vis_flags, am.vis_bans,
                        function(e)
                            return not U.has_modifiers(store, e, "mod_arrow_silver_mark")
                        end)
                    if enemy then
                        am.ts = store.tick_ts

                        reset_cooldowns(is_long(enemy))
                        y_do_shot(am, enemy, pow_m.level)
                    end
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range,
                        false, aa.vis_flags, aa.vis_bans)
                    local mark = false
                    if enemies then
                        for _, enemy_iter in pairs(enemies) do
                            if U.has_modifiers(store, enemy_iter, "mod_arrow_silver_mark") then
                                enemy = enemy_iter
                                mark = true
                                break
                            end
                        end
                    end
                    if enemy then
                        local long = is_long(enemy)
                        local lidx = long and 2 or 1
                        local chance = 0
                        if pow_s.level > 0 then
                            chance = pow_s.chances[lidx][pow_s.level]
                            if mark then
                                chance = chance * 1.8
                            end
                        end
                        reset_cooldowns(long)
                        if chance > math.random() then
                            y_do_shot(as, enemy, pow_s.level)
                        else
                            y_do_shot(aa, enemy)
                        end
                    else
                        U.y_wait(store, this.tower.guard_time)
                    end
                end

                if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                    U.animation_start(this, an, af, store.tick_ts, true, sid)
                end

                coroutine.yield()
            end
        end

    end
}

-- 狂野魔术师
scripts.tower_wild_magus = {
    update = function(this, store)
        local shooter_sid = this.render.sid_shooter
        local rune_sid = this.render.sid_rune
        local a = this.attacks
        local ba = this.attacks.list[1]
        local ea = this.attacks.list[2]
        local wa = this.attacks.list[3]
        local aidx = 2
        local last_enemy, last_enemy_shots
        local pow_e, pow_w = this.powers.eldritch, this.powers.ward

        ba.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                -- block empty
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow.level == 1 then
                            local pa = this.attacks.list[pow.attack_idx]

                            pa.ts = store.tick_ts
                        end

                        if pow.cooldowns then
                            a.list[pow.attack_idx].cooldown = pow.cooldowns[pow.level]
                        end
                    end
                end

                SU.tower_update_silenced_powers(store, this)

                if ready_to_use_power(pow_e, ea, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ea.vis_flags, ea.vis_bans)

                    if not enemy then
                        -- block empty
                    else
                        ea.ts = store.tick_ts

                        local so = this.render.sprites[shooter_sid].offset
                        local an, af, ai = U.animation_name_facing_point(this, ea.animation, enemy.pos, shooter_sid, so)

                        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
                        S:queue(ea.sound)
                        U.y_wait(store, ea.shoot_time)

                        if enemy.health.dead or not U.flags_pass(enemy.vis, ea) or
                            not U.is_inside_ellipse(tpos(this), enemy.pos, a.range * 1.1) then
                            enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ea.vis_flags,
                                ea.vis_bans)
                        end

                        if enemy then
                            local bo = ea.bullet_start_offset[ai]
                            local b = E:create_entity(ea.bullet)

                            b.pos.x = this.pos.x + so.x + bo.x * (af and -1 or 1)
                            b.pos.y = this.pos.y + so.y + bo.y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            b.bullet.target_id = enemy.id
                            b.bullet.level = pow_e.level
                            b.bullet.damage_factor = this.tower.damage_factor

                            queue_insert(store, b)
                        end

                        U.y_animation_wait(this, shooter_sid)
                    end
                end

                if ready_to_use_power(pow_w, wa, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, wa.vis_flags,
                        wa.vis_bans, enemy_is_silent_target)

                    if enemy then
                        wa.ts = store.tick_ts

                        local so = this.render.sprites[shooter_sid].offset
                        local an, af, ai = U.animation_name_facing_point(this, wa.animation, enemy.pos, shooter_sid, so)

                        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
                        S:queue(wa.sound)

                        this.render.sprites[5].ts, this.render.sprites[5].hidden = store.tick_ts, false
                        this.render.sprites[6].ts, this.render.sprites[6].hidden = store.tick_ts, false
                        this.tween.props[6].ts = store.tick_ts
                        this.tween.props[7].ts = store.tick_ts
                        this.render.sprites[rune_sid].ts, this.render.sprites[rune_sid].hidden = store.tick_ts

                        U.y_wait(store, wa.cast_time)

                        for i = 1, math.min(#enemies, pow_w.target_count[pow_w.level]) do
                            local target = enemies[i]
                            local mod = E:create_entity(wa.spell)

                            mod.modifier.target_id = target.id
                            mod.modifier.level = pow_w.level

                            queue_insert(store, mod)
                        end

                        wa.ts = store.tick_ts

                        U.y_animation_wait(this, rune_sid)

                        this.render.sprites[rune_sid].hidden = true

                        U.y_animation_wait(this, shooter_sid)
                    end
                end

                if ready_to_attack(ba, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

                    if enemy then
                        ba.ts = store.tick_ts
                        aidx = km.zmod(aidx + 1, 2)

                        local so = this.render.sprites[shooter_sid].offset
                        local fo = V.v(so.x, so.y + 22 + 8)
                        local an, af, ai = U.animation_name_facing_point(this, ba.animations[aidx], enemy.pos,
                            shooter_sid, fo)

                        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
                        U.y_wait(store, ba.shoot_time)

                        if U.is_inside_ellipse(tpos(this), enemy.pos, a.range * 1.1) then
                            local bo = ba.bullet_start_offset[aidx][ai]
                            local b = E:create_entity(ba.bullet)

                            b.pos.x = this.pos.x + so.x + bo.x * (af and -1 or 1)
                            b.pos.y = this.pos.y + so.y + bo.y
                            b.tween.ts = store.tick_ts
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            b.bullet.target_id = enemy.id
                            b.bullet.damage_factor = this.tower.damage_factor

                            if last_enemy and last_enemy == enemy then
                                last_enemy_shots = last_enemy_shots + 1

                                local dmg_dec = km.clamp(0, b.bullet.damage_same_target_max,
                                    last_enemy_shots * b.bullet.damage_same_target_inc)

                                b.bullet.damage_max = b.bullet.damage_max - dmg_dec
                                b.bullet.damage_min = b.bullet.damage_min - dmg_dec
                            else
                                last_enemy = enemy
                                last_enemy_shots = 0
                            end

                            -- local u = UP:get_upgrade("mage_el_empowerment")

                            -- if u and math.random() < u.chance then
                            --     b.bullet.damage_factor = b.bullet.damage_factor * u.damage_factor
                            --     b.bullet.pop = {"pop_crit_wild_magus"}
                            --     b.bullet.pop_conds = DR_DAMAGE
                            -- end

                            -- if UP:has_upgrade("mage_el_alter_reality") and math.random() < b.alter_reality_chance then
                            --     b.bullet.mod = b.alter_reality_mod
                            -- end

                            queue_insert(store, b)
                        end

                        U.y_animation_wait(this, shooter_sid)

                        an, af = U.animation_name_facing_point(this, "idle", enemy.pos, shooter_sid, so)

                        U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                    else
                        U.y_wait(store, this.tower.guard_time)
                    end
                end

                if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                end
            end

            coroutine.yield()
        end

    end
}
-- 高等精灵法师
scripts.tower_high_elven = {
    get_info = function(this)
        local o = scripts.tower_common.get_info(this)

        o.type = STATS_TYPE_TOWER_MAGE

        local min, max = 0, 0

        if this.attacks and this.attacks.list[1].bullets then
            for _, bn in pairs(this.attacks.list[1].bullets) do
                local b = E:get_template(bn)

                min, max = min + b.bullet.damage_min, max + b.bullet.damage_max
            end
        end

        min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)
        o.damage_max = max
        o.damage_min = min

        return o
    end,
    remove = function(this, store)
        local mods = table.filter(store.modifiers, function(_, e)
            return e.modifier and e.modifier.source_id == this.id and e.template_name == "mod_high_elven"
        end)

        for _, m in pairs(mods) do
            queue_remove(store, m)
        end

        for _, s in pairs(this.sentinels) do
            s.owner = nil
            queue_remove(store, s)
        end
        return true
    end,
    insert = function(this, store)
        for i = 1, this.max_sentinels do
            local s = E:create_entity("high_elven_sentinel")
            s.pos = V.vclone(this.pos)
            queue_insert(store, s)
            table.insert(this.sentinels, s)
            s.owner = this
            s.owner_idx = #this.sentinels
        end
        return true
    end,
    update = function(this, store)
        local shooter_sid = 3
        local a = this.attacks
        local ba = this.attacks.list[1]
        local ta = this.attacks.list[2]
        local sa = this.attacks.list[3]
        local pow_t, pow_s = this.powers.timelapse, this.powers.sentinel

        ba.ts = store.tick_ts

        this.sentinel_previews = nil
        local sentinel_previews_level
        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if this.ui.hover_active and this.ui.args == "sentinel" and
                    (not this.sentinel_previews or sentinel_previews_level ~= pow_s.level) then
                    if this.sentinel_previews then
                        for _, decal in pairs(this.sentinel_previews) do
                            queue_remove(store, decal)
                        end
                    end
                    this.sentinel_previews = {}
                    sentinel_previews_level = pow_s.level
                    local mods = table.filter(store.modifiers, function(_, e)
                        return e.modifier and e.modifier.source_id == this.id
                    end)
                    local modded_ids = {}

                    for _, m in pairs(mods) do
                        table.insert(modded_ids, m.modifier.target_id)
                    end

                    local range
                    if pow_s.level == 3 then
                        range = pow_s.max_range
                    else
                        range = pow_s.range_base + pow_s.range_inc * (pow_s.level + 1)
                    end
                    local targets = table.filter(store.towers, function(_, e)
                        return e ~= this and not table.contains(modded_ids, e.id) and
                                   U.is_inside_ellipse(e.pos, this.pos, range)
                    end)

                    for _, target in pairs(targets) do
                        local decal = E:create_entity("decal_high_elven_sentinel_preview")

                        decal.pos = target.pos
                        decal.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, decal)
                        table.insert(this.sentinel_previews, decal)
                    end
                elseif this.sentinel_previews and (not this.ui.hover_active or this.ui.args ~= "sentinel") then
                    for _, decal in pairs(this.sentinel_previews) do
                        queue_remove(store, decal)
                    end

                    this.sentinel_previews = nil
                end
                if pow_t.changed and pow_t.level == 1 then
                    pow_t.changed = nil
                    ta.ts = store.tick_ts
                end

                if pow_s.changed then
                    pow_s.range = pow_s.range_base + pow_s.range_inc * pow_s.level
                    pow_s.changed = nil
                end

                SU.tower_update_silenced_powers(store, this)
                if ready_to_use_power(pow_s, pow_s, store) then
                    pow_s.ts = store.tick_ts
                    local existing_mods = table.filter(store.modifiers, function(_, e)
                        return e.template_name == "mod_high_elven" and e.modifier.level >= pow_s.level
                    end)
                    local busy_ids = table.map(existing_mods, function(k, v)
                        return v.modifier.target_id
                    end)
                    local towers = table.filter(store.towers, function(_, e)
                        return e.tower.can_be_mod and not table.contains(busy_ids, e.id) and
                                   U.is_inside_ellipse(e.pos, this.pos, pow_s.range)
                    end)

                    for _, tower in pairs(towers) do
                        local new_mod = E:create_entity("mod_high_elven")
                        new_mod.modifier.level = pow_s.level
                        new_mod.modifier.target_id = tower.id
                        new_mod.modifier.source_id = this.id
                        new_mod.pos = tower.pos
                        queue_insert(store, new_mod)
                    end
                end

                if ready_to_use_power(pow_t, ta, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ta.vis_flags,
                        ta.vis_bans)

                    if enemy then
                        if #enemies >= 3 or enemy.health.hp > 750 then
                            ta.ts = store.tick_ts

                            local an, af = U.animation_name_facing_point(this, ta.animation, enemy.pos, shooter_sid)

                            U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

                            this.tween.props[1].ts = store.tick_ts

                            S:queue(ta.sound)
                            U.y_wait(store, ta.cast_time)

                            for i = 1, math.min(#enemies, pow_t.target_count[pow_t.level]) do
                                local target = enemies[i]
                                local mod = E:create_entity(ta.spell)

                                mod.modifier.target_id = target.id
                                mod.modifier.level = pow_t.level

                                queue_insert(store, mod)
                            end

                            U.y_animation_wait(this, shooter_sid)
                        end
                    end
                end

                if ready_to_attack(ba, store, this.tower.cooldown_factor) then
                    local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ba.vis_flags,
                        ba.vis_bans)

                    if enemy then
                        ba.ts = store.tick_ts

                        local bo = ba.bullet_start_offset
                        local an, af = U.animation_name_facing_point(this, ba.animation, enemy.pos, shooter_sid, bo)

                        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)

                        this.tween.props[1].ts = store.tick_ts

                        U.y_wait(store, ba.shoot_time)

                        enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ba.vis_flags,
                            ba.vis_bans)

                        if enemy then
                            local eidx = 1

                            for i, bn in ipairs(ba.bullets) do
                                enemy = enemies[km.zmod(eidx, #enemies)]
                                eidx = eidx + 1

                                local b = E:create_entity(bn)

                                b.bullet.shot_index = i
                                b.bullet.damage_factor = this.tower.damage_factor
                                b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                    enemy.pos.y + enemy.unit.hit_offset.y)
                                b.bullet.target_id = enemy.id
                                b.bullet.from = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
                                b.pos = V.vclone(b.bullet.from)

                                queue_insert(store, b)

                                if i == 1 then
                                    table.sort(enemies, function(e1, e2)
                                        return e1.health.hp < e2.health.hp
                                    end)

                                    eidx = 1
                                end
                            end
                        end

                        U.y_animation_wait(this, shooter_sid)
                    else
                        U.y_wait(store, this.tower.guard_time)
                    end
                end

                if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                end

                coroutine.yield()
            end
        end
    end
}
-- 奥法
scripts.tower_arcane_wizard = {
    get_info = function(this)
        local m = E:get_template("mod_ray_arcane")
        local o = scripts.tower_common.get_info(this)

        o.type = STATS_TYPE_TOWER_MAGE
        o.damage_min = m.dps.damage_min * this.tower.damage_factor
        o.damage_max = m.dps.damage_max * this.tower.damage_factor
        o.damage_type = m.dps.damage_type

        return o
    end,
    remove = function(this, store)
        local mods = table.filter(store.modifiers, function(_, e)
            return e.modifier.source_id == this.id and e.template_name == "decalmod_arcane_wizard_disintegrate_ready"
        end)
        if mods then
            for _, m in pairs(mods) do
                queue_remove(store, m)
            end
        end

        return true
    end,
    update = function(this, store)
        local tower_sid = 2
        local shooter_sid = 3
        local teleport_sid = 4
        local a = this.attacks
        local ar = this.attacks.list[1]
        local ad = this.attacks.list[2]
        local at = this.attacks.list[3]
        local ray_mod = E:get_template("mod_ray_arcane")
        local ray_damage_min = ray_mod.dps.damage_min
        local ray_damage_max = ray_mod.dps.damage_max
        local pow_d = this.powers.disintegrate
        local pow_t = this.powers.teleport
        local last_ts = store.tick_ts

        ar.ts = store.tick_ts
        local aura = E:get_template(at.aura)
        local max_times_applied = E:get_template(aura.aura.mod).max_times_applied
        local function find_target(aa)
            local target, __, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, aa.node_prediction,
                aa.vis_flags, aa.vis_bans, function(e)
                    if aa == at then
                        return e.nav_path.ni >= aa.min_nodes and
                                   (not e.enemy.counts.mod_teleport or e.enemy.counts.mod_teleport < max_times_applied)
                    else
                        return true
                    end
                end)
            return target, pred_pos
        end
        local base_damage
        local upper_damage
        local base_time
        local function start_animations(attack, enemy)
            last_ts = store.tick_ts
            local soffset = this.render.sprites[shooter_sid].offset
            local an, af, ai = U.animation_name_facing_point(this, attack.animation, enemy.pos, shooter_sid, soffset)
            U.animation_start(this, attack.animation, nil, store.tick_ts, false, tower_sid)
            U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
            if attack == at then
                this.render.sprites[teleport_sid].ts = last_ts
            end
            U.y_wait(store, attack.shoot_time)
        end
        local function wizard_ready()
            return store.tick_ts - last_ts > a.min_cooldown * this.tower.cooldown_factor
        end
        local function update_base_damage()
            ray_damage_min = ray_mod.dps.damage_min
            ray_damage_max = ray_mod.dps.damage_max

            if pow_d.level == 1 then
                base_damage = ray_damage_min
            elseif pow_d.level == 2 then
                base_damage = (ray_damage_min + ray_damage_max) * 0.5
            elseif pow_d.level == 3 then
                base_damage = ray_damage_max
            end
        end
        local function wizard_attack(attack, enemy, pred_pos)
            attack.ts = last_ts
            local b
            if attack == at then
                b = E:create_entity(attack.aura)
                b.pos.x, b.pos.y = pred_pos.x, pred_pos.y
                b.aura.target_id = enemy.id
                b.aura.source_id = this.id
                b.aura.max_count = pow_t.max_count_base + pow_t.max_count_inc * pow_t.level
                b.aura.level = pow_t.level
            else
                if attack == ad then
                    update_base_damage()
                    local exact_upper_damage = upper_damage * this.tower.damage_factor
                    local exact_base_damage = base_damage * this.tower.damage_factor
                    local base_time = a.min_cooldown + 2.25 - pow_d.level * 0.75
                    if enemy.health.hp < exact_upper_damage then
                        if enemy.health.hp < exact_base_damage then
                            ad.ts = ad.ts - ad.cooldown + base_time
                        else
                            ad.ts = ad.ts - ad.cooldown + base_time + (enemy.health.hp - exact_base_damage) /
                                        (exact_upper_damage - exact_base_damage) * (ad.cooldown - base_time)
                        end
                    end
                end
                b = E:create_entity(attack.bullet)
                b.pos.x, b.pos.y = this.pos.x + attack.bullet_start_offset.x, this.pos.y + attack.bullet_start_offset.y
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.vclone(enemy.pos)
                b.bullet.damage_factor = this.tower.damage_factor
                b.bullet.target_id = enemy.id
                b.bullet.source_id = this.id
            end
            queue_insert(store, b)
            U.y_animation_wait(this, tower_sid)
        end
        while true do
            do
                if pow_d.changed then
                    pow_d.changed = nil
                    if pow_d.level == 1 then
                        ad.ts = store.tick_ts
                        --     base_damage = ray_damage_min
                        -- elseif pow_d.level == 2 then
                        --     base_damage = (ray_damage_min + ray_damage_max) * 0.5
                        -- else
                        --     base_damage = ray_damage_max
                    end
                    upper_damage = pow_d.upper_damage[pow_d.level]
                    ad.cooldown = pow_d.cooldown_base + pow_d.cooldown_inc * pow_d.level
                end
                if pow_t.changed then
                    pow_t.changed = nil
                    if pow_t.level == 1 then
                        at.ts = store.tick_ts
                    end
                end
                if this.tower.blocked then
                    goto continue
                end
                SU.tower_update_silenced_powers(store, this)
                if ready_to_use_power(pow_d, ad, store, this.tower.cooldown_factor) and wizard_ready() then
                    local enemy, _ = find_target(ad)
                    if not enemy then
                        U.y_wait(store, this.tower.guard_time)
                        goto continue_attack
                    end
                    start_animations(ad, enemy)
                    enemy, _ = find_target(ad)
                    if not enemy then
                        goto continue_attack
                    end
                    wizard_attack(ad, enemy)
                end
                ::continue_attack::
                if ready_to_attack(ar, store, this.tower.cooldown_factor) and wizard_ready() then
                    local enemy, _ = find_target(ar)
                    if not enemy then
                        U.y_wait(store, this.tower.guard_time)
                        goto continue
                    end
                    start_animations(ar, enemy)
                    enemy, _ = find_target(ar)
                    if not enemy then
                        goto continue
                    end
                    wizard_attack(ar, enemy)
                end
                if ready_to_use_power(pow_t, at, store, this.tower.cooldown_factor) and wizard_ready() then
                    local enemy, pred_pos = find_target(at)
                    if not enemy then
                        goto continue
                    end
                    start_animations(at, enemy)
                    enemy, pred_pos = find_target(at)
                    if not enemy then
                        goto continue
                    end
                    wizard_attack(at, enemy, pred_pos)
                end
            end
            ::continue::
            if ((ad.ts <= last_ts - (ad.cooldown - a.min_cooldown) * this.tower.cooldown_factor) or
                (store.tick_ts - ad.ts >= (ad.cooldown - a.min_cooldown) * this.tower.cooldown_factor)) and pow_d.level >
                0 then
                local mod = E:create_entity("decalmod_arcane_wizard_disintegrate_ready")
                mod.modifier.target_id = this.id
                mod.modifier.source_id = this.id
                mod.pos = this.pos
                queue_insert(store, mod)
                this.decalmod_disintegrate_ready = true
            elseif this.decalmod_disintegrate_ready then
                SU.remove_modifiers(store, this, nil, "decalmod_arcane_wizard_disintegrate_ready")
                this.decalmod_disintegrate_ready = false
            end
            if store.tick_ts - ar.ts > this.tower.long_idle_cooldown then
                local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)
                U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
            end
            coroutine.yield()
        end
    end
}
-- 黄法
scripts.tower_sorcerer = {
    update = function(this, store)
        local tower_sid = 2
        local shooter_sid = 3
        local polymorph_sid = 4
        local a = this.attacks
        local ab = this.attacks.list[1]
        local ap = this.attacks.list[2]
        local ab_mod = E:get_template(ab.bullet).mod
        local pow_p = this.powers.polymorph
        local pow_e = this.powers.elemental
        local ba = this.barrack
        local last_ts = store.tick_ts
        local last_soldier_pos

        ab.ts = store.tick_ts

        local aa, pow
        local attacks = {ap, ab}
        local pows = {pow_p}

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if pow_p.level > 0 and pow_p.changed then
                    pow_p.changed = nil

                    if pow_p.level == 1 then
                        ap.ts = store.tick_ts
                    end

                    ap.cooldown = pow_p.cooldown_base + pow_p.cooldown_inc * pow_p.level
                end

                if pow_e.level > 0 then
                    if pow_e.changed then
                        pow_e.changed = nil

                        local s = ba.soldiers[1]

                        if s and store.entities[s.id] then
                            s.unit.level = pow_e.level
                            s.health.armor = s.health.armor + s.health.armor_inc
                            s.health.hp_max = s.health.hp_max + s.health.hp_inc
                            s.health.hp = s.health.hp_max

                            local ma = s.melee.attacks[1]

                            ma.damage_min = ma.damage_min + ma.damage_inc
                            ma.damage_max = ma.damage_max + ma.damage_inc
                        end
                    end

                    local s = ba.soldiers[1]

                    if s and s.health.dead then
                        last_soldier_pos = s.pos
                    end

                    if not s or s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
                        local ns = E:create_entity(ba.soldier_type)

                        ns.soldier.tower_id = this.id
                        ns.pos = last_soldier_pos or V.v(ba.rally_pos.x, ba.rally_pos.y)
                        ns.nav_rally.pos = V.vclone(ba.rally_pos)
                        ns.nav_rally.center = V.vclone(ba.rally_pos)
                        ns.nav_rally.new = true
                        ns.unit.level = pow_e.level
                        ns.health.armor = ns.health.armor + ns.health.armor_inc * ns.unit.level
                        ns.health.hp_max = ns.health.hp_max + ns.health.hp_inc * ns.unit.level

                        local ma = ns.melee.attacks[1]

                        ma.damage_min = ma.damage_min + ma.damage_inc * ns.unit.level
                        ma.damage_max = ma.damage_max + ma.damage_inc * ns.unit.level

                        queue_insert(store, ns)

                        ba.soldiers[1] = ns
                        s = ns
                    end

                    if ba.rally_new then
                        ba.rally_new = false

                        signal.emit("rally-point-changed", this)

                        if s then
                            s.nav_rally.pos = V.vclone(ba.rally_pos)
                            s.nav_rally.center = V.vclone(ba.rally_pos)
                            s.nav_rally.new = true

                            if not s.health.dead then
                                S:queue(this.sound_events.change_rally_point)
                            end
                        end
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                for i, aa in pairs(attacks) do
                    pow = pows[i]

                    if (pow and ready_to_use_power(pow, aa, store, this.tower.cooldown_factor)) or
                        (not pow and ready_to_attack(aa, store, this.tower.cooldown_factor)) and store.tick_ts - last_ts >
                        a.min_cooldown * this.tower.cooldown_factor then
                        local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, aa.vis_flags,
                            aa.vis_bans)

                        if not enemy then
                            -- block empty
                            if aa == ab then
                                U.y_wait(store, this.tower.guard_time)
                            end
                        else
                            if aa == ab then
                                for _, e in pairs(enemies) do
                                    if not U.has_modifiers(store, e, ab_mod) then
                                        enemy = e

                                        break
                                    end
                                end
                            end

                            last_ts = store.tick_ts
                            aa.ts = last_ts

                            local soffset = this.render.sprites[shooter_sid].offset
                            local an, af, ai = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid,
                                soffset)

                            U.animation_start(this, an, nil, store.tick_ts, false, shooter_sid)
                            U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)

                            if aa == ap then
                                local s_poly = this.render.sprites[polymorph_sid]

                                s_poly.hidden = false
                                s_poly.ts = last_ts
                            end

                            U.y_wait(store, aa.shoot_time)

                            if aa == ap and not store.entities[enemy.id] or enemy.health.dead then
                                enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false,
                                    aa.vis_flags, aa.vis_bans)

                                if not enemy or enemy.health.dead then
                                    goto label_18_0
                                end
                            end

                            if V.dist2(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range * a.range then
                                local b
                                local boffset = aa.bullet_start_offset[ai]

                                b = E:create_entity(aa.bullet)
                                b.pos.x, b.pos.y = this.pos.x + boffset.x, this.pos.y + boffset.y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(enemy.pos)
                                b.bullet.target_id = enemy.id
                                b.bullet.source_id = this.id
                                b.bullet.damage_factor = this.tower.damage_factor
                                queue_insert(store, b)
                            end

                            ::label_18_0::

                            U.y_animation_wait(this, tower_sid)
                        end
                    end
                end

                if store.tick_ts - ab.ts > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
                end

                coroutine.yield()
            end
        end
    end
}
-- 大法
scripts.tower_archmage = {
    insert = function(this, store, script)
        this._last_t_angle = math.pi * 3 * 0.5
        this._stored_bullets = {}

        return true
    end,
    remove = function(this, store, script)
        for _, b in pairs(this._stored_bullets) do
            queue_remove(store, b)
        end

        return true
    end,
    update = function(this, store, script)
        local tower_sid = 2
        local shooter_sid = 3
        local s_tower = this.render.sprites[tower_sid]
        local s_shooter = this.render.sprites[shooter_sid]
        local a = this.attacks
        local ba = this.attacks.list[1]
        local ta = this.attacks.list[2]
        local pow_b = this.powers.blast
        local pow_t = this.powers.twister
        local blast_template = E:get_template("bolt_blast")
        local blast_range = blast_template.bullet.damage_radius
        local blast_range_inc = blast_template.bullet.damage_radius_inc
        ba.ts = store.tick_ts
        local function prepare_bullet(start_offset, i)
            if #this._stored_bullets >= ba.max_stored_bullets then
                return
            end
            local b = E:create_entity(ba.bullet)
            b.bullet.damage_factor = this.tower.damage_factor
            b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
            b.pos = V.vclone(b.bullet.from)
            b.bullet.target_id = nil
            b.bullet.store = true
            local off = ba.storage_offsets[i]
            b.bullet.to = V.v(this.pos.x + off.x, this.pos.y + off.y)
            if pow_b.level > 0 and math.random() < ba.payload_chance then
                local blast = E:create_entity(ba.payload_bullet)
                blast.bullet.level = pow_b.level
                blast.bullet.damage_factor = this.tower.damage_factor
                b.bullet.payload = blast
            end
            table.insert(this._stored_bullets, b)
            queue_insert(store, b)
        end
        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if pow_t.changed then
                    pow_t.changed = nil

                    if pow_t.level == 1 then
                        ta.ts = store.tick_ts
                    end
                end
                if pow_b.changed then
                    pow_b.changed = nil
                    blast_range = blast_range + blast_range_inc
                end

                SU.tower_update_silenced_powers(store, this)

                if ready_to_use_power(pow_t, ta, store, this.tower.cooldown_factor) then
                    local target = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ta.vis_flags,
                        ta.vis_bans, function(e)
                            return P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_TWISTER) and e.nav_path.ni >
                                       P:get_start_node(e.nav_path.pi) + ta.nodes_limit and e.nav_path.ni <
                                       P:get_end_node(e.nav_path.pi) - ta.nodes_limit and
                                       (not e.enemy.counts.twister or e.enemy.counts.twister <
                                           E:get_template("twister").max_times_applied)
                        end)

                    if not target then
                        -- block empty
                    else
                        ta.ts = store.tick_ts

                        local tx, ty = V.sub(target.pos.x, target.pos.y, this.pos.x, this.pos.y + s_tower.offset.y)

                        local t_angle = km.unroll(V.angleTo(tx, ty))
                        this._last_t_angle = t_angle

                        local an, _, ai = U.animation_name_for_angle(this, ta.animation, t_angle, shooter_sid)

                        U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

                        while store.tick_ts - ta.ts < ta.shoot_time do
                            coroutine.yield()
                        end

                        local twister = E:create_entity(ta.bullet)
                        local np = twister.nav_path

                        np.pi = target.nav_path.pi
                        np.spi = target.nav_path.spi
                        np.ni = target.nav_path.ni + P:predict_enemy_node_advance(target, true)
                        twister.pos = P:node_pos(np.pi, np.spi, np.ni)
                        twister.aura.level = pow_t.level

                        queue_insert(store, twister)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        ba.ts = store.tick_ts
                    end
                end

                if ready_to_attack(ba, store, this.tower.cooldown_factor) then
                    local target, targets = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range, nil,
                        ba.vis_flags, ba.vis_bans, nil, nil, blast_range)

                    if not target and (not ba.max_stored_bullets or ba.max_stored_bullets == #this._stored_bullets) then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        ba.ts = store.tick_ts

                        local t_angle

                        if target then
                            local tx, ty = V.sub(target.pos.x, target.pos.y, this.pos.x, this.pos.y + s_tower.offset.y)

                            t_angle = km.unroll(V.angleTo(tx, ty))
                            this._last_t_angle = t_angle
                        else
                            t_angle = this._last_t_angle
                        end

                        local an, _, ai = U.animation_name_for_angle(this, ba.animation, t_angle, shooter_sid)

                        U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

                        while store.tick_ts - ba.ts < ba.shoot_time do
                            coroutine.yield()
                        end

                        if target and #this._stored_bullets > 0 then
                            local i = 1
                            local predicted_health = {}
                            for _, b in pairs(this._stored_bullets) do
                                if b.bullet.payload then
                                    b.bullet.target_id = target.id
                                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                        target.pos.y + target.unit.hit_offset.y)
                                else
                                    local normal_target = targets[km.zmod(i, #targets)]
                                    b.bullet.target_id = normal_target.id
                                    b.bullet.to = V.v(normal_target.pos.x + normal_target.unit.hit_offset.x,
                                        normal_target.pos.y + normal_target.unit.hit_offset.y)

                                    local d = SU.create_bullet_damage(b.bullet, normal_target.id, this.id)
                                    if not predicted_health[normal_target.id] then
                                        predicted_health[normal_target.id] = normal_target.health.hp
                                    end
                                    predicted_health[normal_target.id] =
                                        predicted_health[normal_target.id] - U.predict_damage(normal_target, d)
                                    if predicted_health[normal_target.id] < 0 then
                                        i = i + 1
                                        if target.id == targets[km.zmod(i, #targets)].id then
                                            i = i + 1
                                        end
                                    end
                                end
                            end
                            this._stored_bullets = {}
                        else
                            local start_offset = ba.bullet_start_offset[ai]
                            if target then
                                for i = 1, ba.max_stored_bullets do
                                    if i == 1 or math.random() < ba.repetition_rate + pow_t.level *
                                        ba.repetition_rate_inc then
                                        prepare_bullet(start_offset, i)
                                    end
                                end
                            else
                                for i = 1, ba.max_stored_bullets do
                                    prepare_bullet(start_offset, i)
                                end
                            end
                        end

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end
                    end
                end

                local an = U.animation_name_for_angle(this, "idle", this._last_t_angle, shooter_sid)

                U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)

                if store.tick_ts - math.max(ba.ts, ta.ts) > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
                end

                coroutine.yield()
            end
        end
    end
}
-- 死法
scripts.tower_necromancer = {
    insert = function(this, store, script)
        if not store.skeletons_count then
            store.skeletons_count = 0
        end

        for _, a in pairs(this.auras.list) do
            if a.cooldown == 0 then
                local e = E:create_entity(a.name)
                e.pos = V.vclone(this.pos)
                e.aura.level = this.tower.level
                e.aura.source_id = this.id
                e.aura.ts = store.tick_ts
                queue_insert(store, e)
            end
        end

        return true
    end,
    remove = function(this, store, script)
        return true
    end,
    update = function(this, store, script)
        local shooter_sid = 3
        local skull_glow_sid = 4
        local skull_fx_sid = 5
        local b = this.barrack
        local a = this.attacks
        local ba = this.attacks.list[1]
        local pa = this.attacks.list[2]
        local pow_r = this.powers.rider
        local pow_p = this.powers.pestilence
        local t_angle = math.pi * 3 * 0.5
        local hands_raised = false

        ba.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                if hands_raised then
                    this.render.sprites[skull_fx_sid].hidden = true
                    this.render.sprites[skull_glow_sid].ts = store.tick_ts
                    this.tween.reverse = true

                    local an, _, ai = U.animation_name_for_angle(this, "shoot_end", t_angle, shooter_sid)

                    U.y_animation_play(this, an, nil, store.tick_ts, 1, shooter_sid)

                    hands_raised = false

                    local an = U.animation_name_for_angle(this, "idle", t_angle, shooter_sid)

                    U.animation_start(this, an, nil, store.tick_ts, true, shooter_sid)
                end

                coroutine.yield()
            else
                if pow_r.level > 0 then
                    if pow_r.changed then
                        pow_r.changed = nil
                        local s = b.soldiers[1]

                        if s and store.entities[s.id] then
                            s.unit.level = pow_r.level
                            s.health.hp_max = s.health.hp_max + s.health.hp_inc
                            s.health.armor = s.health.armor + s.health.armor_inc
                            s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min +
                                                                s.melee.attacks[1].damage_inc
                            s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max +
                                                                s.melee.attacks[1].damage_inc
                            s.health.hp = s.health.hp_max

                            local auras = table.filter(store.auras, function(k, v)
                                return v.aura.source_id == s.id
                            end)

                            for _, aura in pairs(auras) do
                                aura.aura.level = pow_r.level
                            end
                        end
                    end

                    local s = b.soldiers[1]

                    if not s or s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
                        s = E:create_entity(b.soldier_type)
                        s.soldier.tower_id = this.id
                        s.pos = V.v(b.rally_pos.x, b.rally_pos.y)
                        s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
                        s.nav_rally.center = V.vclone(b.rally_pos)
                        s.nav_rally.new = true
                        s.unit.level = pow_r.level
                        s.health.hp_max = s.health.hp_max + s.health.hp_inc * s.unit.level
                        s.health.armor = s.health.armor + s.health.armor_inc * s.unit.level
                        s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min + s.melee.attacks[1].damage_inc *
                                                            s.unit.level
                        s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max + s.melee.attacks[1].damage_inc *
                                                            s.unit.level

                        queue_insert(store, s)

                        b.soldiers[1] = s
                    end

                    if b.rally_new then
                        b.rally_new = false

                        signal.emit("rally-point-changed", this)

                        if s then
                            s.nav_rally.pos = V.vclone(b.rally_pos)
                            s.nav_rally.center = V.vclone(b.rally_pos)
                            s.nav_rally.new = true

                            if not s.health.dead then
                                S:queue(this.sound_events.change_rally_point)
                            end
                        end
                    end
                end

                if pow_p.changed then
                    pow_p.changed = nil
                    local e_table = table.filter(store.auras, function(k, v)
                        return v.aura.source_id == this.id and v.template_name == this.auras.list[1].name
                    end)
                    for _, e in pairs(e_table) do
                        e.max_skeletons_tower = e.max_skeletons_tower + 1
                    end
                    if pow_p.level == 1 then
                        pa.ts = store.tick_ts
                    end
                end

                SU.tower_update_silenced_powers(store, this)
                if ready_to_use_power(pow_p, pa, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, pa.vis_flags, pa.vis_bans)

                    if enemy then
                        pa.ts = store.tick_ts

                        local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y)

                        t_angle = km.unroll(V.angleTo(tx, ty))

                        local shooter = this.render.sprites[shooter_sid]
                        local an, _, ai = U.animation_name_for_angle(this, "pestilence", t_angle, shooter_sid)

                        U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

                        while store.tick_ts - pa.ts < pa.shoot_time do
                            coroutine.yield()
                        end

                        local path = P:path(enemy.nav_path.pi, enemy.nav_path.spi)
                        local ni = enemy.nav_path.ni + 3

                        ni = km.clamp(1, #path, ni)

                        local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)
                        local b = E:create_entity(pa.bullet)

                        b.aura.source_id = this.id
                        b.aura.ts = store.tick_ts
                        b.aura.level = pow_p.level
                        b.pos = V.vclone(dest)

                        queue_insert(store, b)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end
                    end
                end

                if ready_to_attack(ba, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, ba.vis_flags, ba.vis_bans)

                    if enemy then
                        local shooter_offset_y = ba.bullet_start_offset[1].y
                        local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y + shooter_offset_y)

                        t_angle = km.unroll(V.angleTo(tx, ty))

                        local shooter = this.render.sprites[shooter_sid]

                        if not hands_raised then
                            this.render.sprites[skull_fx_sid].hidden = false
                            this.render.sprites[skull_glow_sid].hidden = false
                            this.render.sprites[skull_glow_sid].ts = store.tick_ts
                            this.tween.reverse = false

                            local an, _, ai = U.animation_name_for_angle(this, "shoot_start", t_angle, shooter_sid)

                            U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

                            while not U.animation_finished(this, shooter_sid) do
                                coroutine.yield()
                            end

                            hands_raised = true
                        end

                        local an, _, ai = U.animation_name_for_angle(this, "shoot_loop", t_angle, shooter_sid)

                        U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)

                        ba.ts = store.tick_ts

                        while store.tick_ts - ba.ts < ba.shoot_time do
                            coroutine.yield()
                        end

                        local bullet = E:create_entity(ba.bullet)

                        bullet.bullet.damage_factor = this.tower.damage_factor
                        bullet.bullet.to = V.vclone(enemy.pos)
                        bullet.bullet.target_id = enemy.id

                        local start_offset = ba.bullet_start_offset[ai]

                        bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
                        bullet.pos = V.vclone(bullet.bullet.from)

                        queue_insert(store, bullet)
                    elseif hands_raised then
                        this.render.sprites[skull_fx_sid].hidden = true
                        this.render.sprites[skull_glow_sid].ts = store.tick_ts
                        this.tween.reverse = true

                        local an, _, ai = U.animation_name_for_angle(this, "shoot_end", t_angle, shooter_sid)

                        U.animation_start(this, an, nil, store.tick_ts, 1, shooter_sid)

                        while not U.animation_finished(this, shooter_sid) do
                            coroutine.yield()
                        end

                        hands_raised = false
                    else
                        U.y_wait(store, this.tower.guard_time)
                    end
                end

                if not hands_raised then
                    local an = U.animation_name_for_angle(this, "idle", t_angle, shooter_sid)

                    U.animation_start(this, an, nil, store.tick_ts, -1, shooter_sid)
                end

                if store.tick_ts - math.max(ba.ts, pa.ts) > this.tower.long_idle_cooldown then
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, -1, shooter_sid)
                end

                coroutine.yield()
            end
        end

    end
}
-- 仙女龙
scripts.tower_faerie_dragon = {
    get_info = function(this)
        local b = E:get_template("bolt_faerie_dragon")
        local min = b.bullet.damage_min * this.tower.damage_factor
        local max = b.bullet.damage_max * this.tower.damage_factor
        local cooldown = this.attacks.list[1].cooldown
        local range = this.attacks.range
        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            range = range,
            cooldown = cooldown,
            damage_type = b.bullet.damage_type
        }
    end,
    insert = function(this, store)
        local aura = E:create_entity(this.aura)
        aura.pos = V.vclone(this.pos)
        aura.aura.source_id = this.id
        aura.aura.ts = store.tick_ts
        queue_insert(store, aura)
        return true
    end,
    remove = function(this, store)
        for _, dragon in pairs(this.dragons) do
            queue_remove(store, dragon)
        end
        return true
    end,
    update = function(this, store)
        local a = this.attacks.list[1]
        local pow_m = this.powers.more_dragons
        local pow_i = this.powers.improve_shot
        local egg_sids = {3, 4}

        while true do
            if this.tower.blocked then
                -- block empty
            else
                if pow_m.changed then
                    pow_m.changed = nil

                    log.debug("pow_m:%s", getdump(pow_m))
                    for i = 1, pow_m.level do
                        if i > #this.dragons then
                            if i > 1 then
                                local egg_sid = egg_sids[i - 1]
                                local egg_s = this.render.sprites[egg_sid]

                                U.animation_start(this, "open", nil, store.tick_ts, false, egg_sid)
                                U.y_wait(store, fts(5))
                            end

                            local o = pow_m.idle_offsets[i]
                            local e = E:create_entity("faerie_dragon")

                            e.idle_pos = 0
                            e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
                            e.owner = this
                            e.idle_pos = V.vclone(e.pos)

                            queue_insert(store, e)
                            table.insert(this.dragons, e)
                        end
                    end
                end

                if pow_i.changed then
                    pow_i.changed = nil
                    this.aura_rate = this.aura_rate + this.aura_rate_inc
                end

                if #this.dragons > 0 and ready_to_attack(a, store, this.tower.cooldown_factor) then
                    a.ts = store.tick_ts

                    local assigned_target_ids = {}

                    for _, dragon in pairs(this.dragons) do
                        if dragon.custom_attack.target_id then
                            table.insert(assigned_target_ids, dragon.custom_attack.target_id)
                        end
                    end

                    for _, dragon in pairs(this.dragons) do
                        if dragon.custom_attack.target_id then
                            -- block empty
                        else
                            local targets = U.find_enemies_in_range(store, this.pos, 0, this.attacks.range, a.vis_flags,
                                a.vis_bans, function(e)
                                    return not table.contains(assigned_target_ids, e.id)
                                end)
                            if not targets then
                                U.y_wait(store, this.tower.guard_time)
                                goto label_539_0
                            end
                            local origin = dragon.pos
                            table.sort(targets, function(e1, e2)
                                local f1 = e1.unit.is_stunned
                                local f2 = e2.unit.is_stunned
                                if f1 ~= 0 then
                                    return false
                                end
                                if f2 ~= 0 then
                                    return true
                                end
                                return V.dist2(e1.pos.x, e1.pos.y, origin.x, origin.y) <
                                           V.dist2(e2.pos.x, e2.pos.y, origin.x, origin.y)
                            end)

                            dragon.custom_attack.target_id = targets[1].id

                            table.insert(assigned_target_ids, targets[1].id)
                        end
                    end
                end
            end

            ::label_539_0::

            coroutine.yield()
        end
    end
}
-- 日光
scripts.tower_sunray = {
    get_info = function(this)
        local pow = this.powers.ray
        local manual = this.powers.manual
        local auto = this.powers.auto
        if pow.level == 0 then
            return {
                type = STATS_TYPE_TEXT,
                desc = _((this.info.i18n_key or string.upper(this.template_name)) .. "_DESCRIPTION")
            }
        else
            local a = this.attacks.list[1]
            local b = E:get_template(a.bullet).bullet
            local p = this.powers.ray
            local max = b.damage_max + b.damage_inc * p.level
            local min = b.damage_min + b.damage_inc * p.level
            local d_type = b.damage_type
            local cooldown = a.cooldown_base + a.cooldown_inc * pow.level
            if auto.level == 1 then
                min = min * 0.75
                max = max * 0.75
                cooldown = cooldown * 0.6
            end
            return {
                type = STATS_TYPE_TOWER_MAGE,
                damage_min = min * this.tower.damage_factor,
                damage_max = max * this.tower.damage_factor,
                damage_type = d_type,
                range = this.attacks.range,
                cooldown = cooldown
            }
        end
    end,
    can_select_point = function(this, x, y, store)
        return U.find_entity_at_pos(store.enemies, x, y, function(e)
            return not e.health.dead and not U.flag_has(e.vis.bans, F_RANGED)
        end)
    end,
    update = function(this, store)
        local pow = this.powers.ray
        local auto = this.powers.auto
        local manual = this.powers.manual
        local a = this.attacks.list[1]
        local charging = false
        local sid_shooters = {7, 8, 9, 10}
        local group_tower = "tower"
        local splash_radius = 45
        local kill_extra_gold_factor = 0.6
        local not_kill_extra_gold_factor = 0.2
        local max_kill_extra_gold = 60
        local max_not_kill_extra_gold = 1
        local accelerate_base = 0.35
        local accelerate_inc = 0.1
        local max_accelerate = 0.6
        local min_damage_factor = 0.35
        local damage_dec = 0.2
        local range = this.attacks.range
        local mode_damage_factor = 1
        local mode_cooldown_factor = 1
        while true do
            do
                -- 升级
                if auto.changed then
                    manual.level = 0
                    auto.changed = nil
                    mode_damage_factor = 0.75
                    mode_cooldown_factor = 0.6
                    a.cooldown = (a.cooldown_base + a.cooldown_inc * pow.level) * mode_cooldown_factor
                end
                if manual.changed then
                    auto.level = 0
                    manual.changed = nil
                    mode_damage_factor = 1
                    mode_cooldown_factor = 1
                    a.cooldown = (a.cooldown_base + a.cooldown_inc * pow.level) * mode_cooldown_factor
                end
                if pow.changed then
                    pow.changed = nil
                    a.cooldown = (a.cooldown_base + a.cooldown_inc * pow.level) * mode_cooldown_factor
                    get_attack_ready(a, store)
                    for i = 1, pow.level do
                        this.render.sprites[sid_shooters[i]].hidden = false
                    end
                    charging = true
                end
                if this.tower.blocked then
                    goto continue
                end
                -- 冷却
                if not ready_to_attack(a, store, this.tower.cooldown_factor) then
                    if not charging then
                        charging = true
                    end
                    this.user_selection.allowed = false
                    U.animation_start_group(this, "charging", nil, store.tick_ts, true, group_tower)
                    for i = 1, pow.level do
                        this.render.sprites[sid_shooters[i]].name = "charge"
                    end
                    goto continue
                end
                -- 冷却完毕
                if charging then
                    charging = false
                    for i = 1, pow.level do
                        this.render.sprites[sid_shooters[i]].name = "idle"
                    end
                    U.y_animation_play_group(this, "ready_start", nil, store.tick_ts, 1, group_tower)
                    U.animation_start_group(this, "ready_idle", nil, store.tick_ts, true, group_tower)
                    if manual.level == 1 then
                        this.user_selection.allowed = true
                    end
                end
                -- 索敌
                local target
                if manual.level == 1 then
                    if this.user_selection.new_pos then
                        local pos = this.user_selection.new_pos
                        target = U.find_entity_at_pos(store.enemies, pos.x, pos.y)
                        this.user_selection.new_pos = nil
                    end
                else
                    target = U.find_foremost_enemy(store, tpos(this), 0, range, false, a.vis_flags, a.vis_bans)
                end
                -- 攻击
                if not target then
                    goto continue
                end
                a.ts = store.tick_ts
                U.animation_start_group(this, "shoot", nil, store.tick_ts, false, group_tower)
                U.y_wait(store, a.shoot_time)
                local enemies = U.find_enemies_in_range(store, target.pos, 0, splash_radius, a.vis_flags, a.vis_bans)
                if not enemies then
                    U.y_wait(store, this.tower.guard_time)
                    goto continue
                end
                local kill_count = 0
                local damage_decrease_rate = damage_dec * (#enemies - 1)
                if damage_decrease_rate > 1 - min_damage_factor then
                    damage_decrease_rate = 1 - min_damage_factor
                end
                local total_extra_gold = 0
                for _, enemy in pairs(enemies) do
                    local b = E:create_entity(a.bullet)
                    b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.vclone(enemy.pos)
                    b.bullet.target_id = enemy.id
                    b.bullet.level = 0
                    b.render.sprites[1].scale = V.v(1, b.ray_y_scales[pow.level])
                    if manual.level == 1 then
                        local deadline = (enemy.health.hp_max - enemy.health.hp) * 0.1
                        if deadline > 200 then
                            deadline = 200
                        end
                        b.bullet.damage_max = b.bullet.damage_max + deadline
                        b.bullet.damage_min = b.bullet.damage_min + deadline
                    end
                    b.bullet.damage_factor = this.tower.damage_factor
                    local damage = (b.bullet.damage_max + b.bullet.damage_inc * pow.level) * mode_damage_factor *
                                       this.tower.damage_factor
                    local decrease_damage = damage * damage_decrease_rate
                    local pure_damage = {}
                    pure_damage.damage_type = b.bullet.damage_type
                    pure_damage.value = damage - decrease_damage
                    pure_damage.reduce_armor = 0
                    pure_damage.reduce_magic_armor = 0
                    local exact_damage = U.predict_damage(enemy, pure_damage)
                    b.bullet.damage_max = pure_damage.value
                    b.bullet.damage_min = pure_damage.value
                    if exact_damage >= enemy.health.hp then
                        kill_count = kill_count + 1
                        local kill_extra_gold = enemy.enemy.gold * kill_extra_gold_factor
                        if kill_extra_gold > max_kill_extra_gold then
                            kill_extra_gold = max_kill_extra_gold
                        end
                        total_extra_gold = total_extra_gold + kill_extra_gold
                        if enemy.enemy.gold ~= 0 then
                            local fx = E:create_entity("fx_coin_jump")
                            fx.pos.x, fx.pos.y = enemy.pos.x, enemy.pos.y
                            fx.render.sprites[1].ts = store.tick_ts
                            if enemy.health_bar then
                                fx.render.sprites[1].offset.y = enemy.health_bar.offset.y
                            end
                            queue_insert(store, fx)
                        end
                    elseif enemy.enemy.gold ~= 0 then
                        local not_kill_extra_gold = enemy.enemy.gold * not_kill_extra_gold_factor
                        if not_kill_extra_gold > max_not_kill_extra_gold then
                            not_kill_extra_gold = max_not_kill_extra_gold
                        end
                        total_extra_gold = total_extra_gold + not_kill_extra_gold
                    end
                    queue_insert(store, b)
                end
                if kill_count > 0 then
                    local accelerate = accelerate_base + accelerate_inc * kill_count
                    if accelerate > max_accelerate then
                        accelerate = max_accelerate
                    end
                    a.ts = a.ts - a.cooldown * accelerate
                end
                store.player_gold = store.player_gold + math.floor(total_extra_gold)
                U.y_animation_wait_group(this, group_tower)
                AC:inc_check("SUN_BURNER")
            end
            ::continue::
            coroutine.yield()
        end
    end
}
scripts.tower_pixie = {}

function scripts.tower_pixie.get_info(this)
    local mod = E:get_template("mod_pixie_pickpocket")

    return {
        type = STATS_TYPE_TOWER,
        damage_min = math.ceil(mod.modifier.damage_min * this.tower.damage_factor),
        damage_max = math.ceil(mod.modifier.damage_max * this.tower.damage_factor),
        damage_type = mod.modifier.damage_type,
        range = this.attacks.range,
        cooldown = this.attacks.pixie_cooldown * this.tower.cooldown_factor
    }

end

function scripts.tower_pixie.remove(this, store)
    for _, pixie in pairs(this.pixies) do
        queue_remove(store, pixie)
    end
    return true
end

function scripts.tower_pixie.update(this, store)
    local a = this.attacks

    a.ts = store.tick_ts

    local pow_c = this.powers.cream
    local pow_t = this.powers.total
    local enemy_cooldowns = {}
    local pixies = this.pixies

    local function spawn_pixie()
        local e = E:create_entity("decal_pixie")
        local po = pow_c.idle_offsets[#pixies + 1]

        e.idle_pos = po
        e.pos.x, e.pos.y = this.pos.x + po.x, this.pos.y + po.y
        e.owner = this

        table.insert(pixies, e)
        queue_insert(store, e)
    end

    spawn_pixie()

    while true do
        if this.tower.blocked then
            -- block empty
        else
            if pow_c.changed and #pixies < 3 then
                pow_c.changed = nil
                while #pixies <= pow_c.level do
                    spawn_pixie()
                end
            end

            if pow_t.changed then
                pow_t.changed = nil

                for i, ch in ipairs(pow_t.chances) do
                    a.list[i].chance = ch[pow_t.level]
                end
            end

            for k, v in pairs(enemy_cooldowns) do
                if v <= store.tick_ts then
                    enemy_cooldowns[k] = nil
                end
            end

            if store.tick_ts - a.ts > a.cooldown * this.tower.cooldown_factor then
                for _, pixie in pairs(pixies) do
                    local target, attack
                    local rnd, acc = math.random(), 0

                    if pixie.target or store.tick_ts - pixie.attack_ts <= a.pixie_cooldown * this.tower.cooldown_factor then
                        -- block empty
                    else
                        for ii, aa in ipairs(a.list) do
                            if aa.chance > 0 and rnd <= aa.chance / (1 - acc) then
                                attack = aa

                                break
                            else
                                acc = acc + aa.chance
                            end
                        end

                        if not attack then
                            -- block empty
                        else
                            target = U.find_random_enemy(store, this.pos, 0, a.range, attack.vis_flags, attack.vis_bans,
                                function(e)
                                    return not table.contains(a.excluded_templates, e.template_name) and
                                               not enemy_cooldowns[e.id] and
                                               (not attack.check_gold_bag or e.enemy.gold_bag > 0)
                                end)

                            if not target then
                                -- block empty
                                U.y_wait(store, this.tower.guard_time)
                            else
                                enemy_cooldowns[target.id] =
                                    store.tick_ts + a.enemy_cooldown * this.tower.cooldown_factor
                                pixie.attack_ts = store.tick_ts
                                pixie.target_id = target.id
                                pixie.attack = attack
                                pixie.attack_level = pow_t.level
                                a.ts = store.tick_ts
                                break
                            end
                        end
                    end
                end
            end
        end

        coroutine.yield()
    end
end

scripts.decal_pixie = {}

function scripts.decal_pixie.update(this, store)
    local iflip = this.idle_flip
    local a, o, e, slot_pos, slot_flip, enemy_flip

    U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)

    while true do
        if this.target_id ~= nil then
            local target = store.entities[this.target_id]

            if not target or target.health.dead then
                -- block empty
            else
                a = this.attack

                U.y_animation_play(this, "teleportOut", nil, store.tick_ts)
                -- U.y_wait(store, 0.5)
                SU.stun_inc(target)

                slot_pos, slot_flip, enemy_flip = U.melee_slot_position(this, target, 1)
                this.pos.x, this.pos.y = slot_pos.x, slot_pos.y

                U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)
                U.animation_start(this, a.animation, nil, store.tick_ts, false)
                -- U.y_wait(store, 0.3)

                if a.type == "mod" then
                    for _, m in pairs(a.mods) do
                        e = E:create_entity(m)
                        e.modifier.source_id = this.id
                        e.modifier.target_id = target.id
                        e.modifier.level = this.attack_level
                        e.modifier.damage_factor = this.owner.tower.damage_factor
                        queue_insert(store, e)
                    end
                else
                    e = E:create_entity(a.bullet)
                    e.bullet.source_id = this.id
                    e.bullet.target_id = target.id
                    e.bullet.from = V.v(this.pos.x + a.bullet_start_offset.x, this.pos.y + a.bullet_start_offset.y)
                    e.bullet.to = V.v(target.pos.x, target.pos.y)
                    e.bullet.hit_fx = e.bullet.hit_fx .. (target.unit.size >= UNIT_SIZE_MEDIUM and "big" or "small")
                    e.bullet.damage_factor = this.owner.tower.damage_factor
                    e.pos = V.vclone(e.bullet.from)
                    queue_insert(store, e)
                end

                U.y_animation_wait(this)
                U.y_animation_play(this, "teleportOut", nil, store.tick_ts)
                SU.stun_dec(target)

                o = this.idle_pos
                this.pos.x, this.pos.y = this.owner.pos.x + o.x, this.owner.pos.y + o.y

                U.y_animation_play(this, "teleportIn", slot_flip, store.tick_ts)
            end

            this.target_id = nil
        elseif store.tick_ts - iflip.ts > iflip.cooldown then
            U.animation_start(this, table.random(iflip.animations), math.random() < 0.5, store.tick_ts, iflip.loop)

            iflip.ts = store.tick_ts
        end

        coroutine.yield()
    end
end

-- 大贝莎
scripts.tower_bfg = {
    update = function(this, store, script)
        local tower_sid = 2
        local a = this.attacks
        local ab = this.attacks.list[1]
        local am = this.attacks.list[2]
        local ac = this.attacks.list[3]
        local pow_m = this.powers.missile
        local pow_c = this.powers.cluster
        local last_ts = store.tick_ts

        ab.ts = store.tick_ts

        local aa, pow
        local attacks = {am, ac, ab}
        local pows = {pow_m, pow_c}

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow == pow_m then
                            am.range = am.range_base * (1 + pow_m.range_inc_factor * pow_m.level)
                            am.cooldown = am.cooldown_base - pow_m.cooldown_dec * pow_m.level
                            am.cooldown_mixed = am.cooldown_mixed_base - pow_m.cooldown_mixed_dec * pow_m.level
                            if pow.level == 1 then
                                am.ts = store.tick_ts
                            end
                        elseif pow == pow_c and pow.level == 1 then
                            ac.ts = store.tick_ts
                        end
                        if pow == pow_c then
                            ac.cooldown = ac.cooldown_base - pow_c.cooldown_dec * pow_c.level
                        end
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                for i, aa in pairs(attacks) do
                    pow = pows[i]

                    if (pow and ready_to_use_power(pow, aa, store, this.tower.cooldown_factor)) or
                        (not pow and ready_to_attack(aa, store, this.tower.cooldown_factor) and store.tick_ts - last_ts >
                            a.min_cooldown * this.tower.cooldown_factor) then
                        local trigger, enemies, trigger_pos =
                            U.find_foremost_enemy(store, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags,
                                aa.vis_bans)

                        if aa == ac or aa == ab then
                            if trigger then
                                am.cooldown = am.cooldown_mixed
                            else
                                am.cooldown = am.cooldown_flying
                            end
                        end

                        if not trigger then
                            U.y_wait(store, this.tower.guard_time)
                            -- block empty
                        else
                            aa.ts = store.tick_ts

                            if pow ~= pow_m then
                                last_ts = aa.ts
                            end

                            U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)
                            U.y_wait(store, aa.shoot_time)

                            local enemy, __, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, aa.range,
                                aa.node_prediction, aa.vis_flags, aa.vis_bans)
                            local dest = enemy and pred_pos or trigger_pos

                            if V.dist(tpos(this).x, tpos(this).y, dest.x, dest.y) <= aa.range then
                                local b = E:create_entity(aa.bullet)

                                b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x,
                                    this.pos.y + aa.bullet_start_offset.y
                                b.bullet.damage_factor = this.tower.damage_factor
                                b.bullet.from = V.vclone(b.pos)

                                if aa == am then
                                    b.bullet.to = V.v(b.pos.x + am.launch_vector.x, b.pos.y + am.launch_vector.y)
                                    b.bullet.damage_max = b.bullet.damage_max + pow_m.damage_inc * pow_m.level
                                    b.bullet.damage_min = b.bullet.damage_min + pow_m.damage_inc * pow_m.level

                                    AC:inc_check("ROCKETEER")
                                else
                                    b.bullet.to = dest

                                    if aa == ac then
                                        b.bullet.fragment_count =
                                            pow_c.fragment_count_base + pow_c.fragment_count_inc * pow_c.level
                                    end
                                end

                                b.bullet.target_id = enemy and enemy.id or trigger.id
                                b.bullet.source_id = this.id

                                queue_insert(store, b)
                            end

                            U.y_animation_wait(this, tower_sid)
                        end
                    end
                end

                U.animation_start(this, "idle", nil, store.tick_ts)
                coroutine.yield()
            end
        end
    end
}
-- 地震
scripts.tower_dwaarp = {
    insert = function(this, store, script)
        local function fx_points(this)
            local points = {}
            local factor = this.attacks.range / this.origin_range
            local inner_fx_radius = 100 * factor
            local outer_fx_radius = 115 * factor
            for i = 1, 12 do
                local r = outer_fx_radius

                if i % 2 == 0 then
                    r = inner_fx_radius
                end

                local p = {}

                p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * i / 12)
                p.terrain = GR:cell_type(p.pos.x, p.pos.y)

                log.debug("i:%i pos:%f,%f type:%i", i, p.pos.x, p.pos.y, p.terrain)

                if GR:cell_is(p.pos.x, p.pos.y, TERRAIN_WATER) or P:valid_node_nearby(p.pos.x, p.pos.y, 1) and
                    not GR:cell_is(p.pos.x, p.pos.y, TERRAIN_CLIFF) then
                    table.insert(points, p)
                end
            end
            return points
        end
        this.fx_points = fx_points
        return true
    end,
    update = function(this, store, script)
        local a = this.attacks
        local aa = this.attacks.list[1]
        local la = this.attacks.list[2]
        local da = this.attacks.list[3]
        local pow_d = this.powers.drill
        local pow_l = this.powers.lava
        local lava_ready = false
        local drill_ready = false
        local std_ready = false
        local anim_id = 3

        aa.ts = store.tick_ts

        ::label_89_0::

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if pow_d.changed then
                    pow_d.changed = nil

                    if pow_d.level == 1 then
                        da.ts = store.tick_ts
                    end
                    da.cooldown = da.cooldown + da.cooldown_inc
                end

                if pow_l.changed then
                    pow_l.changed = nil

                    if pow_l.level == 1 then
                        la.ts = store.tick_ts
                    end
                end
                SU.tower_update_silenced_powers(store, this)
                if ready_to_use_power(pow_d, da, store, this.tower.cooldown_factor) then
                    drill_ready = true
                end

                if ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    if ready_to_use_power(pow_l, la, store, this.tower.cooldown_factor) then
                        lava_ready = true
                        this.render.sprites[4].hidden = false
                        this.render.sprites[5].hidden = false
                    end

                    std_ready = true
                end

                if not drill_ready and not lava_ready and not std_ready then
                    coroutine.yield()
                else
                    if drill_ready then
                        local trigger_enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, true, da.vis_flags,
                            da.vis_bans, function(e, origin)
                                return e.health and e.health.hp > 1000
                            end)

                        if not trigger_enemy then
                            -- block empty
                        else
                            drill_ready = false
                            da.ts = store.tick_ts

                            S:queue(da.sound)
                            U.animation_start(this, "drill", nil, store.tick_ts, 1, anim_id)

                            while store.tick_ts - da.ts < da.hit_time do
                                coroutine.yield()
                            end

                            local enemy
                            if trigger_enemy and trigger_enemy.health.hp > 0 then
                                enemy = trigger_enemy
                            else
                                enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, true, da.vis_flags,
                                    da.vis_bans)
                            end

                            if enemy then
                                local drill = E:create_entity(da.bullet)

                                drill.bullet.target_id = enemy.id
                                drill.pos.x, drill.pos.y = enemy.pos.x, enemy.pos.y

                                queue_insert(store, drill)
                            end

                            while not U.animation_finished(this, anim_id) do
                                coroutine.yield()
                            end

                            goto label_89_0
                        end
                    end

                    local trigger_range = (lava_ready and 0.8 or 1) * a.range
                    local trigger_enemy = U.find_foremost_enemy(store, tpos(this), 0, trigger_range, false,
                        aa.vis_flags, aa.vis_bans)

                    if trigger_enemy then
                        aa.ts = store.tick_ts

                        if lava_ready then
                            la.ts = store.tick_ts
                        end

                        U.animation_start(this, "shoot", nil, store.tick_ts, 1, anim_id)

                        while store.tick_ts - aa.ts < aa.hit_time do
                            coroutine.yield()
                        end
                        local enemies = U.find_enemies_in_range(store, tpos(this), 0, a.range, aa.damage_flags,
                            aa.damage_bans)
                        if enemies then
                            for _, enemy in pairs(enemies) do
                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = enemy.id
                                d.damage_type = aa.damage_type

                                -- if alchemical_powder_on then
                                -- 	d.value = aa.damage_max
                                -- else
                                -- 	d.value = math.random(aa.damage_min, aa.damage_max)
                                -- end
                                if UP:get_upgrade("engineer_efficiency") then
                                    d.value = aa.damage_max
                                else
                                    d.value = math.random(aa.damage_min, aa.damage_max)
                                end

                                d.value = this.tower.damage_factor * d.value

                                queue_damage(store, d)

                                if aa.mod then
                                    local mod = E:create_entity(aa.mod)

                                    mod.modifier.target_id = enemy.id

                                    queue_insert(store, mod)
                                elseif aa.mods then
                                    for _, m in pairs(aa.mods) do
                                        local mod = E:create_entity(m)

                                        mod.modifier.source_id = this.id
                                        mod.modifier.target_id = enemy.id
                                        mod.modifier.damage_factor = this.tower.damage_factor
                                        queue_insert(store, mod)
                                    end
                                end

                                -- if shock_and_awe and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < shock_and_awe.chance then
                                -- 	local mod = E:create_entity("mod_shock_and_awe")

                                -- 	mod.modifier.target_id = enemy.id

                                -- 	queue_insert(store, mod)
                                -- end
                            end

                        end
                        -- local alchemical_powder = UP:get_upgrade("engineer_alchemical_powder")
                        -- local alchemical_powder_on = alchemical_powder and math.random() < alchemical_powder.chance
                        -- local shock_and_awe = UP:get_upgrade("engineer_shock_and_awe")

                        local fx_points = this.fx_points(this)
                        local radius_factor = a.range / this.origin_range
                        for i = 1, #fx_points do
                            local p = fx_points[i]

                            if lava_ready then
                                local lava = E:create_entity(la.bullet)

                                lava.pos.x, lava.pos.y = p.pos.x, p.pos.y
                                lava.aura.ts = store.tick_ts
                                lava.aura.source_id = this.id
                                lava.aura.level = pow_l.level
                                lava.aura.radius = lava.aura.radius * radius_factor
                                lava.aura.damage_factor = this.tower.damage_factor
                                queue_insert(store, lava)
                            end

                            if band(p.terrain, TERRAIN_WATER) ~= 0 then
                                local smoke = E:create_entity("decal_dwaarp_smoke_water")

                                smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
                                smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS

                                queue_insert(store, smoke)

                                if lava_ready then
                                    local vapor = E:create_entity("decal_dwaarp_scorched_water")

                                    vapor.render.sprites[1].ts = store.tick_ts + U.frandom(0, 0.5)
                                    vapor.pos.x, vapor.pos.y = p.pos.x + U.frandom(-5, 5), p.pos.y + U.frandom(-5, 5)

                                    if math.random() < 0.5 then
                                        vapor.render.sprites[1].flip_x = true
                                    end

                                    queue_insert(store, vapor)
                                end
                            else
                                local decal = E:create_entity("decal_tween")

                                decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
                                decal.tween.props[1].keys = {{0, 255}, {1, 255}, {2.5, 0}}
                                decal.tween.props[1].name = "alpha"

                                if math.random() < 0.5 then
                                    decal.render.sprites[1].name = "EarthquakeTower_HitDecal1"
                                else
                                    decal.render.sprites[1].name = "EarthquakeTower_HitDecal2"
                                end

                                decal.render.sprites[1].animated = false
                                decal.render.sprites[1].z = Z_DECALS
                                decal.render.sprites[1].ts = store.tick_ts
                                decal.render.sprites[1].scale = V.v(radius_factor, radius_factor)
                                queue_insert(store, decal)

                                local smoke = E:create_entity("decal_dwaarp_smoke")

                                smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
                                smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS
                                smoke.render.sprites[1].scale = V.v(radius_factor, radius_factor)
                                queue_insert(store, smoke)

                                if lava_ready then
                                    local scorch = E:create_entity("decal_dwaarp_scorched")

                                    if math.random() < 0.5 then
                                        scorch.render.sprites[1].name = "EarthquakeTower_Lava2"
                                    end

                                    scorch.pos.x, scorch.pos.y = p.pos.x, p.pos.y
                                    scorch.render.sprites[1].ts = store.tick_ts
                                    scorch.render.sprites[1].scale = V.v(radius_factor, radius_factor)
                                    queue_insert(store, scorch)
                                end
                            end
                        end

                        if lava_ready then
                            local tower_scorch = E:create_entity("decal_dwaarp_tower_scorched")

                            tower_scorch.pos.x, tower_scorch.pos.y = this.pos.x, this.pos.y + 10
                            tower_scorch.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, tower_scorch)
                        end

                        local pulse = E:create_entity("decal_dwaarp_pulse")

                        pulse.pos.x, pulse.pos.y = this.pos.x, this.pos.y + 16
                        pulse.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, pulse)

                        if lava_ready then
                            S:queue(la.sound)
                        end

                        S:queue(aa.sound)

                        while not U.animation_finished(this, anim_id) do
                            coroutine.yield()
                        end

                        std_ready = false
                        lava_ready = false
                        this.render.sprites[4].hidden = true
                        this.render.sprites[5].hidden = true
                    else
                        U.y_wait(store, this.tower.guard_time)
                    end

                    U.animation_start(this, "idle", nil, store.tick_ts, -1, anim_id)
                    coroutine.yield()
                end
            end
        end
    end
}
-- 大树
scripts.tower_entwood = {
    insert = function(this, store)
        local points = {}
        local inner_fx_radius = 100
        local outer_fx_radius = 115

        for i = 1, 12 do
            local r = outer_fx_radius

            if i % 2 == 0 then
                r = inner_fx_radius
            end

            local p = {}

            p.pos = U.point_on_ellipse(this.pos, r, 2 * math.pi * i / 12)
            p.terrain = GR:cell_type(p.pos.x, p.pos.y)

            if P:valid_node_nearby(p.pos.x, p.pos.y, 1) then
                table.insert(points, p)
            end
        end

        this.fx_points = points

        return true
    end,
    update = function(this, store)
        local a = this.attacks
        local aa = this.attacks.list[1]
        local fa = this.attacks.list[2]
        local ca = this.attacks.list[3]
        local pow_c = this.powers.clobber
        local pow_f = this.powers.fiery_nuts
        local blink_ts = store.tick_ts
        local blink_cooldown = 4
        local blink_sid = 11
        local loaded

        local function filter_faerie(e)
            local ppos = P:predict_enemy_pos(e, true)

            return not GR:cell_is(ppos.x, ppos.y, TERRAIN_FAERIE)
        end

        local function do_attack(at)
            SU.delay_attack(store, at, 0.25)
            local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, at.node_prediction,
                at.vis_flags, at.vis_bans, filter_faerie)

            if target then
                at.ts = store.tick_ts
                blink_ts = store.tick_ts
                loaded = nil

                U.animation_start_group(this, at.animation, nil, store.tick_ts, false, "layers")
                U.y_wait(store, at.shoot_time)

                local bo = at.bullet_start_offset
                local b = E:create_entity(at.bullet)

                local nt, _, nt_pos = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range,
                    at.node_prediction, at.vis_flags, at.vis_bans, filter_faerie, nil, b.bullet.damage_radius)
                if nt then
                    target = nt
                    pred_pos = nt_pos
                end

                b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
                b.bullet.level = pow_f.level
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.vclone(pred_pos)
                b.bullet.source_id = this.id
                b.bullet.damage_factor = this.tower.damage_factor

                if b.bullet.hit_peyload then
                    local pl = E:create_entity(b.bullet.hit_payload)

                    pl.aura.level = pow_f.level
                    b.bullet.hit_payload = pl
                end

                queue_insert(store, b)
                U.y_animation_wait_group(this, "layers")

                return true
            end
            U.y_wait(store, this.tower.guard_time)
            return false
        end

        aa.ts = store.tick_ts
        this.render.sprites[blink_sid].hidden = true

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow.level == 1 then
                            local pa = this.attacks.list[pow.attack_idx]

                            pa.ts = store.tick_ts
                        end
                    end
                end

                SU.tower_update_silenced_powers(store, this)

                if not loaded then
                    if ready_to_use_power(pow_c, ca, store, this.tower.cooldown_factor) then
                        loaded = "clobber"
                    elseif pow_f.level > 0 and not fa.silence_ts and store.tick_ts - fa.ts > aa.cooldown *
                        fa.cooldown_factor * this.tower.cooldown_factor - a.load_time then
                        S:queue("TowerEntwoodLeaves")
                        U.y_animation_play_group(this, "special1_charge", nil, store.tick_ts, 1, "layers")

                        loaded = "fiery_nuts"
                    elseif store.tick_ts - aa.ts > aa.cooldown * this.tower.cooldown_factor - a.load_time then
                        S:queue("TowerEntwoodLeaves")
                        U.y_animation_play_group(this, "attack1_charge", nil, store.tick_ts, 1, "layers")

                        loaded = "default"
                    end

                    if this.tower.blocked then
                        goto label_43_0
                    end
                end

                if loaded == "clobber" then
                    loaded = nil

                    SU.delay_attack(store, ca, 1)

                    local triggers = U.find_enemies_in_range(store, tpos(this), 0, ca.range, ca.vis_flags, ca.vis_bans)

                    if triggers and #triggers > ca.min_count then
                        ca.ts = store.tick_ts
                        blink_ts = store.tick_ts

                        S:queue(ca.sound)
                        U.animation_start_group(this, ca.animation, nil, store.tick_ts, false, "layers")
                        U.y_wait(store, ca.hit_time)

                        for i = 1, #this.fx_points do
                            local p = this.fx_points[i]
                            local decal = E:create_entity(table.random({"decal_clobber_1", "decal_clobber_2"}))

                            decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
                            decal.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, decal)

                            local smoke = E:create_entity("fx_clobber_smoke")

                            smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
                            smoke.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, smoke)
                        end

                        local fx = E:create_entity("fx_clobber_smoke_ring")

                        fx.render.sprites[1].ts = store.tick_ts
                        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

                        queue_insert(store, fx)

                        local targets = U.find_enemies_in_range(store, tpos(this), 0, ca.damage_radius, ca.vis_flags,
                            ca.vis_bans)
                        local stun_count = 0

                        if targets then
                            for i, target in ipairs(targets) do
                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = target.id
                                d.damage_type = ca.damage_type
                                d.value = pow_c.damage_values[pow_c.level] * this.tower.damage_factor

                                queue_damage(store, d)

                                local chance = ca.stun_chances[i] or ca.stun_chances[#ca.stun_chances]

                                if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, bor(F_BOSS, F_FLYING)) ==
                                    0 and chance > math.random() then
                                    local mod = E:create_entity(ca.stun_mod)

                                    mod.modifier.target_id = target.id
                                    mod.modifier.duration = pow_c.stun_durations[pow_c.level]

                                    queue_insert(store, mod)

                                    if U.predict_damage(target, d) < target.health.hp then
                                        stun_count = stun_count + 1
                                    end
                                end
                            end
                        end

                        -- AC:high_check("HEAVY_WEIGHT", stun_count)
                        U.y_animation_wait_group(this, "layers")

                        goto label_43_0
                    end
                end

                if loaded == "fiery_nuts" and do_attack(fa) then
                    -- AC:inc_check("WILDFIRE_HARVEST")
                elseif loaded == "default" and store.tick_ts - aa.ts > aa.cooldown * this.tower.cooldown_factor and
                    do_attack(aa) then
                    -- block empty
                elseif blink_cooldown < store.tick_ts - blink_ts then
                    blink_ts = store.tick_ts
                    this.render.sprites[blink_sid].hidden = false

                    U.y_animation_play(this, "tower_entwood_blink", nil, store.tick_ts, 1, blink_sid)

                    this.render.sprites[blink_sid].hidden = true
                end
            end

            ::label_43_0::

            coroutine.yield()
        end

    end
}
-- 特斯拉
scripts.tower_tesla = {
    get_info = function(this)
        local min, max, d_type
        local b = E:get_template(this.attacks.list[1].bullet)
        local m = E:get_template(b.bullet.mod)

        d_type = m.dps.damage_type

        local bounce_factor = UP:get_upgrade("engineer_efficiency") and 1 or b.bounce_damage_factor

        min, max = b.bounce_damage_min, b.bounce_damage_max
        min, max = math.ceil(min * bounce_factor * this.tower.damage_factor),
            math.ceil(max * bounce_factor * this.tower.damage_factor)

        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            damage_type = d_type,
            range = this.attacks.range,
            cooldown = this.attacks.list[1].cooldown
        }
    end,
    update = function(this, store, script)
        local tower_sid = 2
        local a = this.attacks
        local ar = this.attacks.list[1]
        local ao = this.attacks.list[2]
        local pow_b = this.powers.bolt
        local pow_o = this.powers.overcharge
        local last_ts = store.tick_ts
        local thor = nil
        for _, soldier in pairs(store.soldiers) do
            if soldier.template_name == "hero_thor" then
                thor = soldier
                break
            end
        end
        ar.ts = store.tick_ts

        local aa, pow

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow == pow_b then
                            -- block empty
                        elseif pow == pow_o then
                            -- block empty
                        end
                    end
                end

                if ready_to_attack(ar, store, this.tower.cooldown_factor) then
                    local target = U.find_foremost_enemy(store, tpos(this), 0, ar.range, ar.node_prediction,
                        ar.vis_flags, ar.vis_bans)
                    local function target_after_check_thor()
                        if not thor then
                            return nil
                        end
                        if not U.is_inside_ellipse(thor.pos, tpos(this), ar.range * a.range_check_factor) then
                            return nil
                        end
                        if thor.health.dead then
                            return nil
                        end
                        if thor.health.hp == thor.health.hp_max then
                            local bounce_target = U.find_enemies_in_range(store, thor.pos, 0,
                                E:get_template(ar.bullet).bounce_range * 2, ar.vis_flags, ar.vis_bans)
                            if bounce_target then
                                return thor
                            else
                                return nil
                            end
                        end
                        return thor
                    end
                    if not target then
                        target = target_after_check_thor()
                    end
                    if not target then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        ar.ts = store.tick_ts

                        U.animation_start(this, ar.animation, nil, store.tick_ts, false, tower_sid)
                        U.y_wait(store, ar.shoot_time)

                        if target.health.dead or not store.entities[target.id] or
                            not U.is_inside_ellipse(tpos(this), target.pos, ar.range * a.range_check_factor) then
                            target = U.find_foremost_enemy(store, tpos(this), 0, ar.range, false, ar.vis_flags,
                                ar.vis_bans)
                        end

                        if target then
                            S:queue(ar.sound_shoot)

                            local b = E:create_entity(ar.bullet)

                            b.pos.x, b.pos.y = this.pos.x + ar.bullet_start_offset.x,
                                this.pos.y + ar.bullet_start_offset.y
                            b.bullet.damage_factor = this.tower.damage_factor
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                target.pos.y + target.unit.hit_offset.y)
                            b.bullet.target_id = target.id
                            b.bullet.source_id = this.id
                            b.bullet.level = pow_b.level

                            queue_insert(store, b)
                        end

                        if pow_o.level > 0 then
                            local b = E:create_entity(ao.aura)

                            b.pos.x, b.pos.y = this.pos.x + ao.bullet_start_offset.x,
                                this.pos.y + ao.bullet_start_offset.y
                            b.aura.source_id = this.id
                            b.aura.level = pow_o.level

                            queue_insert(store, b)
                        end

                        U.y_animation_wait(this, tower_sid)
                        goto continue
                    end
                end

                U.animation_start(this, "idle", nil, store.tick_ts)
                ::continue::
                coroutine.yield()
            end
        end

    end
}
-- 高达
scripts.tower_mech = {
    get_info = function(this)
        local sm = E:get_template(this.barrack.soldier_type)
        local b = E:get_template(sm.attacks.list[1].bullet)
        local min, max = b.bullet.damage_min, b.bullet.damage_max

        min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

        local cooldown = sm.attacks.list[1].cooldown
        local range = sm.attacks.list[1].max_range

        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            range = range,
            cooldown = cooldown
        }
    end,
    insert = function(this, store, script)
        return true
    end,
    update = function(this, store, script)
        local tower_sid = 2
        local wts
        local is_open = false

        for i = 2, 10 do
            U.animation_start(this, "open", nil, store.tick_ts, 1, i)
        end

        while not U.animation_finished(this, tower_sid) do
            coroutine.yield()
        end

        local mecha = E:create_entity("soldier_mecha")

        mecha.pos.x, mecha.pos.y = this.pos.x, this.pos.y + 16
        if not this.barrack.rally_pos then
            this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
        end
        mecha.nav_rally.pos.x, mecha.nav_rally.pos.y = this.barrack.rally_pos.x, this.barrack.rally_pos.y
        mecha.nav_rally.new = true
        mecha.owner = this

        queue_insert(store, mecha)
        table.insert(this.barrack.soldiers, mecha)
        coroutine.yield()

        for i = 2, 10 do
            U.animation_start(this, "hold", nil, store.tick_ts, 1, i)
        end

        wts = store.tick_ts
        is_open = true

        local b = this.barrack

        while true do
            if is_open and store.tick_ts - wts >= 1.8 then
                is_open = false

                for i = 2, 10 do
                    U.animation_start(this, "close", nil, store.tick_ts, 1, i)
                end
            end

            if b.rally_new then
                b.rally_new = false

                signal.emit("rally-point-changed", this)
                S:queue(this.sound_events.change_rally_point)

                for i, s in ipairs(b.soldiers) do
                    s.nav_rally.pos = V.vclone(b.rally_pos)
                    s.nav_rally.center = V.vclone(b.rally_pos)
                    s.nav_rally.new = true
                end
            end

            if this.powers.missile.changed then
                this.powers.missile.changed = nil

                for i, s in ipairs(b.soldiers) do
                    s.powers.missile.changed = true
                    s.powers.missile.level = this.powers.missile.level
                end
            end

            if this.powers.oil.changed then
                this.powers.oil.changed = nil

                for i, s in ipairs(b.soldiers) do
                    s.powers.oil.changed = true
                    s.powers.oil.level = this.powers.oil.level
                end
            end
            coroutine.yield()
        end
    end
}
scripts.soldier_mecha = {}

function scripts.soldier_mecha.insert(this, store, script)
    this.attacks.order = U.attack_order(this.attacks.list)
    this.idle_flip.ts = store.tick_ts

    return true
end

function scripts.soldier_mecha.remove(this, store, script)
    S:stop("MechWalk")
    S:stop("MechSteam")

    return true
end

function scripts.soldier_mecha.update(this, store, script)
    local ab = this.attacks.list[1]
    local am = this.attacks.list[2]
    local ao = this.attacks.list[3]
    local pow_m = this.powers.missile
    local pow_o = this.powers.oil
    local ab_side = 1

    ::label_67_0::

    while true do
        local r = this.nav_rally

        while r.new do
            r.new = false

            U.set_destination(this, r.pos)

            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

            U.animation_start(this, an, af, store.tick_ts, true, 1)
            S:queue("MechWalk")

            local ts = store.tick_ts

            while not this.motion.arrived and not r.new do
                if store.tick_ts - ts > 1 then
                    ts = store.tick_ts

                    S:queue("MechSteam")
                end

                U.walk(this, store.tick_length)
                coroutine.yield()

                this.motion.speed.x, this.motion.speed.y = 0, 0
            end

            S:stop("MechWalk")
            coroutine.yield()
        end

        if pow_o.level > 0 then
            if pow_o.changed then
                pow_o.changed = nil

                if pow_o.level == 1 then
                    ao.ts = store.tick_ts
                end
            end

            if store.tick_ts - ao.ts > ao.cooldown * this.owner.tower.cooldown_factor then
                local _, targets = U.find_foremost_enemy(store, this.pos, ao.min_range, ao.max_range, true,
                    ao.vis_flags, ao.vis_bans)

                if not targets then
                    -- block empty
                else
                    local target = table.random(targets)

                    ao.ts = store.tick_ts

                    local an, af = U.animation_name_facing_point(this, ao.animation, target.pos)

                    U.animation_start(this, an, af, store.tick_ts, false)
                    U.y_wait(store, ao.hit_time)

                    local b = E:create_entity(ao.bullet)

                    b.pos.x = this.pos.x + (af and -1 or 1) * ao.start_offset.x
                    b.pos.y = this.pos.y + ao.start_offset.y
                    b.aura.level = pow_o.level
                    b.aura.ts = store.tick_ts
                    b.aura.source_id = this.id
                    b.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, b)

                    while not U.animation_finished(this) do
                        coroutine.yield()
                    end

                    goto label_67_0
                end
            end
        end

        if pow_m.level > 0 then
            if pow_m.changed then
                pow_m.changed = nil

                if pow_m.level == 1 then
                    am.ts = store.tick_ts
                end
            end

            if store.tick_ts - am.ts > am.cooldown * this.owner.tower.cooldown_factor then
                local target, targets = U.find_foremost_enemy(store, this.pos, am.min_range, am.max_range, false,
                    am.vis_flags, am.vis_bans)

                if not targets then
                    -- block empty
                else
                    -- local target = table.random(targets)

                    am.ts = store.tick_ts

                    local an, af = U.animation_name_facing_point(this, am.animation_pre, target.pos)

                    U.animation_start(this, an, af, store.tick_ts, false, 1)

                    while not U.animation_finished(this) do
                        coroutine.yield()
                    end

                    local burst_count = am.burst + pow_m.level * am.burst_inc
                    local fire_loops = burst_count / #am.hit_times

                    for i = 1, fire_loops do
                        local an, af = U.animation_name_facing_point(this, am.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false, 1)

                        for hi, ht in ipairs(am.hit_times) do
                            while ht > store.tick_ts - this.render.sprites[1].ts do
                                if this.nav_rally.new then
                                    goto label_67_1
                                end

                                coroutine.yield()
                            end

                            local b = E:create_entity(am.bullet)

                            b.pos.x = this.pos.x + (af and -1 or 1) * am.start_offsets[km.zmod(hi, #am.start_offsets)].x
                            b.pos.y = this.pos.y + am.start_offsets[hi].y
                            b.bullet.level = pow_m.level
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(b.pos.x + (af and -1 or 1) * am.launch_vector.x,
                                b.pos.y + am.launch_vector.y)
                            b.bullet.target_id = target.id
                            b.bullet.damage_factor = this.owner.tower.damage_factor

                            queue_insert(store, b)

                            target, targets = U.find_foremost_enemy(store, this.pos, am.min_range, am.max_range, false,
                                am.vis_flags, am.vis_bans)

                            if not targets then
                                goto label_67_1
                            end

                            -- target = table.random(targets)
                        end

                        while not U.animation_finished(this) do
                            coroutine.yield()
                        end
                    end

                    ::label_67_1::

                    U.animation_start(this, am.animation_post, nil, store.tick_ts, false, 1)

                    while not U.animation_finished(this) do
                        coroutine.yield()
                    end

                    am.ts = store.tick_ts

                    goto label_67_0
                end
            end
        end

        if store.tick_ts - ab.ts > ab.cooldown * this.owner.tower.cooldown_factor then
            local _, targets = U.find_foremost_enemy(store, this.pos, ab.min_range, ab.max_range, ab.node_prediction,
                ab.vis_flags, ab.vis_bans)

            if not targets then
                -- block empty
                U.y_wait(store, this.owner.tower.guard_time)
            else
                local target = table.random(targets)
                local pred_pos = P:predict_enemy_pos(target, ab.node_prediction)

                ab.ts = store.tick_ts
                ab_side = km.zmod(ab_side + 1, 2)

                local an, af = U.animation_name_facing_point(this, ab.animations[ab_side], target.pos)

                U.animation_start(this, an, af, store.tick_ts, false, 1)
                U.y_wait(store, ab.hit_times[ab_side])

                local b = E:create_entity(ab.bullet)

                b.bullet.damage_factor = this.owner.tower.damage_factor
                b.pos.x = this.pos.x + (af and -1 or 1) * ab.start_offsets[ab_side].x
                b.pos.y = this.pos.y + ab.start_offsets[ab_side].y
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = pred_pos
                b.bullet.source_id = this.id

                queue_insert(store, b)

                while not U.animation_finished(this) do
                    if this.nav_rally.new then
                        break
                    end

                    coroutine.yield()
                end

                goto label_67_0
            end
        end

        if store.tick_ts - this.idle_flip.ts > this.idle_flip.cooldown then
            this.idle_flip.ts = store.tick_ts

            local new_pos = V.vclone(this.pos)

            this.idle_flip.last_dir = -1 * this.idle_flip.last_dir
            new_pos.x = new_pos.x + this.idle_flip.last_dir * this.idle_flip.walk_dist

            if not GR:cell_is(new_pos.x, new_pos.y, TERRAIN_WATER) then
                r.new = true
                r.pos = new_pos

                goto label_67_0
            end
        end

        U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
        coroutine.yield()
    end
end

-- 黑暗熔炉
scripts.tower_frankenstein = {
    get_info = function(this)
        local l = this.powers.lightning.level
        local m = E:get_template("mod_ray_frankenstein")
        local min, max = m.dps.damage_min + l * m.dps.damage_inc, m.dps.damage_max + l * m.dps.damage_inc

        min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

        local cooldown

        if this.attacks and this.attacks.list[1].cooldown then
            cooldown = this.attacks.list[1].cooldown
        end

        return {
            type = STATS_TYPE_TOWER,
            damage_min = min,
            damage_max = max,
            damage_type = DAMAGE_ELECTRICAL,
            range = this.attacks.range,
            cooldown = cooldown
        }
    end,
    insert = function(this, store)
        return true
    end,
    update = function(this, store)
        local charges_sids = {7, 8}
        local charges_ts = store.tick_ts
        local charges_cooldown = math.random(fts(71), fts(116))
        local drcrazy_sid = 9
        local drcrazy_ts = store.tick_ts
        local drcrazy_cooldown = math.random(fts(86), fts(146))
        local fake_frankie_sid = 10
        local at = this.attacks
        local ra = this.attacks.list[1]
        local rb = E:get_template(ra.bullet)
        local b = this.barrack
        local pow_l = this.powers.lightning
        local pow_f = this.powers.frankie
        local a, pow, bu
        local thor = nil
        for _, soldier in pairs(store.soldiers) do
            if soldier.template_name == "hero_thor" then
                thor = soldier
                break
            end
        end
        local function target_after_check_thor()
            if not thor then
                return nil
            end
            if not U.is_inside_ellipse(thor.pos, tpos(this), at.range) then
                return nil
            end
            if thor.health.dead then
                return nil
            end
            if thor.health.hp == thor.health.hp_max then
                local bounce_target = U.find_enemies_in_range(store, thor.pos, 0, rb.bounce_range * 2, ra.vis_flags,
                    ra.vis_bans)
                if bounce_target then
                    return thor
                else
                    return nil
                end
            end
            return thor
        end

        ra.ts = store.tick_ts

        while true do
            if this.tower.blocked then
                coroutine.yield()
            else
                if drcrazy_cooldown < store.tick_ts - drcrazy_ts * this.tower.cooldown_factor then
                    U.animation_start(this, "idle", nil, store.tick_ts, false, drcrazy_sid)

                    drcrazy_ts = store.tick_ts
                end

                if charges_cooldown < store.tick_ts - charges_ts * this.tower.cooldown_factor then
                    for _, sid in pairs(charges_sids) do
                        U.animation_start(this, "idle", nil, store.tick_ts, false, sid)
                    end

                    charges_ts = store.tick_ts
                end

                if pow_l.changed then
                    pow_l.changed = nil
                end

                if pow_f.level > 0 then
                    if pow_f.changed then
                        pow_f.changed = nil

                        if not b.soldiers[1] then
                            for i = 1, 2 do
                                U.animation_start(this, "release", nil, store.tick_ts, false, 10 + i)
                            end

                            U.animation_start(this, "idle", nil, store.tick_ts, false, drcrazy_sid)

                            drcrazy_ts = store.tick_ts

                            U.y_wait(store, 2)

                            this.render.sprites[fake_frankie_sid].hidden = true

                            local l = pow_f.level
                            local s = E:create_entity(b.soldier_type)

                            s.soldier.tower_id = this.id
                            s.unit.damage_factor = this.tower.damage_factor
                            s.cooldown_factor = this.tower.cooldown_factor
                            s.pos = V.v(this.pos.x + 2, this.pos.y - 10)
                            s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
                            s.nav_rally.center = V.vclone(b.rally_pos)
                            s.nav_rally.new = true
                            s.unit.level = l
                            s.health.armor = s.health.armor_lvls[l]
                            s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
                            s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
                            s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
                            s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]
                            s.render.sprites[1].name = "idle"
                            s.render.sprites[1].flip_x = true

                            if l == 3 then
                                s.melee.attacks[2].disabled = nil
                            end

                            queue_insert(store, s)

                            b.soldiers[1] = s
                        end

                        if pow_f.level > 1 then
                            local s = b.soldiers[1]

                            if s and store.entities[s.id] and not s.health.dead then
                                local l = pow_f.level

                                s.unit.level = l
                                s.health.armor = s.health.armor_lvls[l]
                                s.health.hp = s.health.hp_max
                                s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
                                s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
                                s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
                                s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]

                                if l == 3 then
                                    s.melee.attacks[2].disabled = nil
                                end
                            end
                        end
                    end

                    local s = b.soldiers[1]

                    if s and s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
                        local orig_s = s

                        queue_remove(store, orig_s)

                        local l = pow_f.level

                        s = E:create_entity(b.soldier_type)
                        s.soldier.tower_id = this.id
                        s.pos = orig_s.pos
                        s.nav_rally.pos = V.v(b.rally_pos.x, b.rally_pos.y)
                        s.nav_rally.center = V.vclone(b.rally_pos)
                        s.nav_rally.new = true
                        s.unit.level = l
                        s.unit.damage_factor = this.tower.damage_factor
                        s.cooldown_factor = this.tower.cooldown_factor
                        s.health.armor = s.health.armor_lvls[l]
                        s.melee.attacks[1].damage_min = s.melee.attacks[1].damage_min_lvls[l]
                        s.melee.attacks[1].damage_max = s.melee.attacks[1].damage_max_lvls[l]
                        s.melee.attacks[1].cooldown = s.melee.attacks[1].cooldown_lvls[l]
                        s.render.sprites[1].prefix = s.render.sprites[1].prefix_lvls[l]
                        s.render.sprites[1].flip_x = orig_s.render.sprites[1].flip_x

                        if l == 3 then
                            s.melee.attacks[2].disabled = nil
                        end

                        queue_insert(store, s)

                        b.soldiers[1] = s
                    end

                    if b.rally_new then
                        b.rally_new = false

                        signal.emit("rally-point-changed", this)

                        if s then
                            s.nav_rally.pos = V.vclone(b.rally_pos)
                            s.nav_rally.center = V.vclone(b.rally_pos)
                            s.nav_rally.new = true

                            if not s.health.dead then
                                S:queue(this.sound_events.change_rally_point)
                            end
                        end
                    end
                end

                if ready_to_attack(ra, store, this.tower.cooldown_factor) then
                    local enemy = U.find_foremost_enemy(store, tpos(this), 0, at.range, ra.node_prediction,
                        ra.vis_flags, ra.vis_bans)

                    if not enemy or enemy.health.dead then
                        enemy = target_after_check_thor()
                        if not enemy then
                            local frankie = b.soldiers[1]
                            if frankie and not frankie.health.dead then
                                enemy = U.find_foremost_enemy(store, frankie.pos, 0, rb.bounce_range, false,
                                    ra.vis_flags, ra.vis_bans)
                                enemy = enemy and frankie
                            end
                        end
                    end

                    if not enemy then
                        -- block empty
                        U.y_wait(store, this.tower.guard_time)
                    else
                        ra.ts = store.tick_ts

                        S:queue("HWFrankensteinChargeLightning", {
                            delay = fts(16)
                        })

                        for i = 3, 6 do
                            U.animation_start(this, "shoot", nil, store.tick_ts, 1, i)
                        end

                        while store.tick_ts - ra.ts < ra.shoot_time do
                            coroutine.yield()
                        end
                        if not enemy or store.entities[enemy.id] == nil or enemy.health.dead or
                            not U.is_inside_ellipse(tpos(this), enemy.pos, at.range) then
                            enemy = U.find_foremost_enemy(store, tpos(this), 0, at.range, ra.node_prediction,
                                ra.vis_flags, ra.vis_bans)
                        end

                        if not enemy or enemy.health.dead then
                            -- block empty
                        else
                            S:queue(ra.sound)

                            bu = E:create_entity(ra.bullet)
                            bu.bullet.damage_factor = this.tower.damage_factor
                            bu.pos.x, bu.pos.y = this.pos.x + ra.bullet_start_offset.x,
                                this.pos.y + ra.bullet_start_offset.y
                            bu.bullet.from = V.vclone(bu.pos)
                            bu.bullet.to = V.vclone(enemy.pos)
                            bu.bullet.source_id = this.id
                            bu.bullet.target_id = enemy.id
                            bu.bullet.level = pow_l.level

                            queue_insert(store, bu)
                        end

                        while not U.animation_finished(this, 3) do
                            coroutine.yield()
                        end
                    end
                end

                for i = 2, 5 do
                    U.animation_start(this, "idle", nil, store.tick_ts, 1, i)
                end

                coroutine.yield()
            end
        end
    end
}
-- 大德
scripts.tower_druid = {}

function scripts.tower_druid.remove(this, store)
    if this.loaded_bullets then
        for _, b in pairs(this.loaded_bullets) do
            queue_remove(store, b)
        end
    end

    if this.shooters then
        for _, s in pairs(this.shooters) do
            queue_remove(store, s)
        end
    end

    for _, s in pairs(this.barrack.soldiers) do
        if s.health then
            s.health.dead = true
        end

        queue_remove(store, s)
    end

    return true
end

function scripts.tower_druid.update(this, store)
    local shooter_sid = 3
    local a = this.attacks
    local ba = this.attacks.list[1]
    local sa = this.attacks.list[2]
    local pow_n = this.powers.nature
    local pow_s = this.powers.sylvan
    local target, _, pred_pos

    this.loaded_bullets = {}
    this.shooters = {}
    ba.ts = store.tick_ts

    local function load_bullet()
        local look_pos = target and target.pos or this.tower.long_idle_pos
        local an, af = U.animation_name_facing_point(this, "load", look_pos, shooter_sid)

        U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
        U.y_wait(store, fts(16))

        local idx = #this.loaded_bullets + 1
        local b = E:create_entity(ba.bullet)
        local bo = ba.storage_offsets[idx]

        b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
        b.bullet.from = V.vclone(b.pos)
        b.bullet.to = V.vclone(b.pos)
        b.bullet.source_id = this.id
        b.bullet.target_id = nil
        b.bullet.damage_factor = this.tower.damage_factor
        b.render.sprites[1].prefix = string.format(b.render.sprites[1].prefix, idx)

        queue_insert(store, b)
        table.insert(this.loaded_bullets, b)
        U.y_animation_wait(this, shooter_sid)
    end

    while true do
        if this.tower.blocked then
            coroutine.yield()
        else
            for k, pow in pairs(this.powers) do
                if pow.changed then
                    pow.changed = nil

                    if not table.contains(table.map(this.shooters, function(k, v)
                        return v.template_name
                    end), pow.entity) then
                        local s = E:create_entity(pow.entity)

                        s.pos = V.vclone(this.pos)
                        s.owner = this

                        queue_insert(store, s)
                        table.insert(this.shooters, s)
                    end

                    if k == "nature" then
                        this.barrack.max_soldiers = pow.level
                    end
                end
            end

            if ready_to_attack(ba, store, this.tower.cooldown_factor) then
                local function filter_faerie(e)
                    local ppos = P:predict_enemy_pos(e, ba.node_prediction)

                    return not GR:cell_is(ppos.x, ppos.y, TERRAIN_FAERIE)
                end

                target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, ba.node_prediction,
                    ba.vis_flags, ba.vis_bans, filter_faerie)

                if target then
                    ba.ts = store.tick_ts

                    if #this.loaded_bullets == 0 then
                        load_bullet()
                    end

                    S:queue(ba.sound)

                    local an, af = U.animation_name_facing_point(this, ba.animation, pred_pos, shooter_sid)

                    U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
                    U.y_wait(store, ba.shoot_time)

                    local trigger_target, trigger_pos = target, pred_pos

                    target, _, pred_pos = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range,
                        ba.node_prediction, ba.vis_flags, ba.vis_bans, filter_faerie, nil, 50)

                    if not target then
                        target = trigger_target
                        pred_pos = P:predict_enemy_pos(target, ba.node_prediction)
                    end

                    local adv = P:predict_enemy_node_advance(target, ba.node_prediction)

                    if U.is_inside_ellipse(tpos(this), pred_pos, a.range * 1.05) then
                        for i, b in ipairs(this.loaded_bullets) do
                            b.bullet.target_id = target.id

                            if i > 1 then
                                local ni_pred = target.nav_path.ni + adv

                                if P:is_node_valid(target.nav_path.pi, ni_pred - (i - 2) * 5) then
                                    ni_pred = ni_pred - (i - 2) * 5
                                end

                                pred_pos = P:node_pos(target.nav_path.pi, 1, ni_pred)
                            end

                            b.bullet.to = V.v(pred_pos.x, pred_pos.y)
                        end

                        this.loaded_bullets = {}
                    end

                    U.y_animation_wait(this, shooter_sid)
                elseif #this.loaded_bullets < ba.max_loaded_bullets then
                    load_bullet()
                else
                    -- block empty
                    U.y_wait(store, this.tower.guard_time)
                end
            end

            if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
                local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

                U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
            end

            coroutine.yield()
        end
    end
end

scripts.tower_baby_ashbite = {}

function scripts.tower_baby_ashbite.get_info(this)
    local e = E:get_template("soldier_baby_ashbite")
    local b = E:get_template(e.ranged.attacks[1].bullet)
    local min, max = b.bullet.damage_min * this.tower.damage_factor, b.bullet.damage_max * this.tower.damage_factor

    return {
        type = STATS_TYPE_TOWER_BARRACK,
        hp_max = e.health.hp_max,
        damage_min = min,
        damage_max = max,
        -- damage_icon = this.info.damage_icon,
        damage_type = b.bullet.damage_type,
        armor = e.health.armor,
        magic_armor = e.health.magic_armor,
        respawn = e.health.dead_lifetime
    }
end

function scripts.tower_baby_ashbite.update(this, store)
    local b = this.barrack
    if not this.barrack.rally_pos then
        this.barrack.rally_pos = V.v(this.pos.x + b.respawn_offset.x, this.pos.y + b.respawn_offset.y)
    end

    if #b.soldiers == 0 then
        local s = E:create_entity(b.soldier_type)

        s.soldier.tower_id = this.id
        s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
        s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(1, b, b.max_soldiers)
        s.nav_rally.new = true

        if this.powers then
            for pn, p in pairs(this.powers) do
                s.powers[pn].level = p.level
            end
        end
        s.unit.damage_factor = this.tower.damage_factor
        s.cooldown_factor = this.tower.cooldown_factor
        queue_insert(store, s)
        table.insert(b.soldiers, s)
        signal.emit("tower-spawn", this, s)
    end

    while true do
        if this.powers then
            for pn, p in pairs(this.powers) do
                if p.changed then
                    p.changed = nil

                    for _, s in pairs(b.soldiers) do
                        s.powers[pn].level = p.level
                        s.powers[pn].changed = true
                    end
                end
            end
        end

        if not this.tower.blocked then
            for i = 1, b.max_soldiers do
                local s = b.soldiers[i]

                if not s or s.health.dead and not store.entities[s.id] then
                    s = E:create_entity(b.soldier_type)
                    s.soldier.tower_id = this.id
                    s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
                    s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
                    s.nav_rally.new = true

                    if this.powers then
                        for pn, p in pairs(this.powers) do
                            s.powers[pn].level = p.level
                        end
                    end
                    s.unit.damage_factor = this.tower.damage_factor
                    s.cooldown_factor = this.tower.cooldown_factor
                    queue_insert(store, s)

                    b.soldiers[i] = s

                    signal.emit("tower-spawn", this, s)
                end
            end
        end

        if b.rally_new then
            b.rally_new = false

            signal.emit("rally-point-changed", this)

            local all_dead = true

            for i, s in ipairs(b.soldiers) do
                s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers,
                    b.rally_angle_offset)
                s.nav_rally.new = true
                all_dead = all_dead and s.health.dead
            end

            if not all_dead then
                S:queue(this.sound_events.change_rally_point)
            end
        end

        coroutine.yield()
    end
end

scripts.tower_tricannon = {}

function scripts.tower_tricannon.update(this, store, script)
    local tower_sid = 2
    local a = this.attacks
    local ab = this.attacks.list[1]
    local am = this.attacks.list[2]
    local ao = this.attacks.list[3]
    local pow_m = this.powers and this.powers.bombardment
    local pow_o = this.powers and this.powers.overheat
    local last_ts = store.tick_ts - ab.cooldown
    local aa, pow
    local attacks = {ao, am, ab}
    for _, a in pairs(attacks) do
        a.ts = store.tick_ts
    end
    this.decal_mod = nil

    local pows = {pow_o, pow_m}
    local overheateble_attacks = {am, ab}

    local function shoot_bullet(attack, enemy, dest, bullet_idx)
        local b = E:create_entity(attack.bullet)
        local bullet_start_offset = bullet_idx and attack.bullet_start_offset[bullet_idx] or attack.bullet_start_offset

        b.pos.x, b.pos.y = this.pos.x + bullet_start_offset.x, this.pos.y + bullet_start_offset.y
        b.bullet.damage_factor = this.tower.damage_factor
        b.bullet.from = V.vclone(b.pos)
        b.bullet.to = dest

        if ao.active then
            b.bullet.hit_payload = "tower_tricannon_overheat_scorch_aura"
            b.bullet.level = pow_o.level
            b.render.sprites[1].name = "tricannon_tower_lvl4_bomb_overheat"
            b.bullet.particles_name = "tower_tricannon_bomb_4_overheated_trail"
        end
        if attack == am then
            b.bullet.damage_max = b.bullet.damage_max_config[pow_m.level]
            b.bullet.damage_min = b.bullet.damage_min_config[pow_m.level]
        end
        -- b.bullet.level = pow and pow.level or 1
        b.bullet.target_id = enemy and enemy.id
        b.bullet.source_id = this.id

        queue_insert(store, b)

        return b
    end

    while true do
        if this.tower.blocked then
            coroutine.yield()
        else
            if this.powers then
                for k, pow in pairs(this.powers) do
                    if pow.changed then
                        pow.changed = nil

                        if pow == pow_m then
                            am.cooldown = pow_m.cooldown[pow_m.level]

                            if pow.level == 1 then
                                am.ts = store.tick_ts - am.cooldown
                            end
                        elseif pow == pow_o then
                            ao.cooldown = pow_o.cooldown[pow_o.level]
                            ao.duration = pow_o.duration[pow_o.level]

                            if pow.level == 1 then
                                ao.ts = store.tick_ts - ao.cooldown
                            end
                        end
                    end
                end
            end

            if ao and ao.active and store.tick_ts - ao.ts > ao.duration then
                ao.active = nil

                -- for _, attack in ipairs(overheateble_attacks) do
                -- attack.bullet = attack._default_bullet
                -- end

                -- U.y_animation_play_group(this, ao.animation_end, nil, store.tick_ts, false, "layers")

                -- if am and am.cooldown and store.tick_ts - am.ts > am.cooldown then
                --     am.ts = store.tick_ts - (am.cooldown - a.min_cooldown)
                -- end

                queue_remove(store, this.decal_mod)
                this.decal_mod = nil
            end

            for i, aa in pairs(attacks) do
                pow = pows[i]

                if aa and (not pow or pow.level > 0) and aa.cooldown and
                    ready_to_attack(aa, store, this.tower.cooldown_factor) and
                    (not a.min_cooldown or store.tick_ts - last_ts > a.min_cooldown * this.tower.cooldown_factor) then
                    local trigger, enemies, trigger_pos = U.find_foremost_enemy(store, tpos(this), 0, aa.range,
                        aa.node_prediction, aa.vis_flags, aa.vis_bans)

                    if not trigger then
                        SU.delay_attack(store, aa, fts(10))
                    else
                        local trigger_path = trigger.nav_path.pi

                        if aa == ab then
                            aa.ts = store.tick_ts
                            last_ts = aa.ts

                            local trigger_target_positions = {}

                            for j = 1, aa.bomb_amount do
                                local enemy_index = km.zmod(j + 1, #enemies)
                                local enemy = enemies[enemy_index]
                                local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, aa.node_prediction)
                                local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)

                                table.insert(trigger_target_positions, dest)
                            end

                            local shoot_animation = aa.animation

                            -- if ao and ao.active then
                            --     shoot_animation = ao.animation_shoot
                            -- end

                            U.animation_start_group(this, shoot_animation, nil, store.tick_ts, false, "layers")
                            U.y_wait(store, aa.shoot_time)
                            S:queue(aa.sound)

                            local _, enemies, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, aa.range,
                                aa.node_prediction, aa.vis_flags, aa.vis_bans)
                            local target_positions = {}

                            if enemies and #enemies > 0 then
                                for j = 1, aa.bomb_amount do
                                    local enemy_index = km.zmod(j + 1, #enemies)
                                    local enemy = enemies[enemy_index]
                                    local ni = enemy.nav_path.ni +
                                                   P:predict_enemy_node_advance(enemy, aa.node_prediction)
                                    local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)

                                    table.insert(target_positions, {
                                        enemy = enemy,
                                        dest = dest
                                    })
                                end
                            else
                                for j = 1, aa.bomb_amount do
                                    local trigger_target_positions_index = km.zmod(j + 1, #trigger_target_positions)
                                    local trigger_target_position =
                                        trigger_target_positions[trigger_target_positions_index]

                                    table.insert(target_positions, {
                                        dest = trigger_target_position
                                    })
                                end
                            end

                            local enemies_hitted = {}

                            for bullet_idx, target_position_data in ipairs(target_positions) do
                                local enemy = target_position_data.enemy
                                local pred = target_position_data.dest

                                if enemy then
                                    local dest = P:predict_enemy_pos(enemy, aa.node_prediction)
                                    pred = dest

                                    table.insert(enemies_hitted, enemy.id)
                                end

                                local enemy_hit_count = table.count(enemies_hitted, function(k, v)
                                    if v == enemy.id then
                                        return true
                                    end

                                    return false
                                end)

                                if not enemy or enemy and enemy_hit_count > 1 then
                                    pred.x = pred.x + U.frandom(0, ab.random_x_to_dest) * U.random_sign()
                                    pred.y = pred.y + U.frandom(0, ab.random_y_to_dest) * U.random_sign()

                                    local nearest_nodes = P:nearest_nodes(pred.x, pred.y)
                                    local pi, spi, ni = unpack(nearest_nodes[1])

                                    pred = P:node_pos(pi, spi, ni)
                                end

                                shoot_bullet(aa, nil, pred, bullet_idx)
                                U.y_wait(store, aa.time_between_bombs)
                            end

                            U.y_animation_wait_group(this, "layers")

                            aa.ts = last_ts
                        elseif aa == am then
                            aa.ts = store.tick_ts
                            last_ts = aa.ts

                            U.animation_start_group(this, aa.animation_start, nil, store.tick_ts, false, "layers")
                            U.y_wait(store, aa.shoot_time)

                            local enemy, __, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, aa.range,
                                aa.node_prediction, aa.vis_flags, aa.vis_bans)
                            local dest = enemy and pred_pos or trigger_pos
                            local dest_path = enemy and enemy.nav_path.pi or trigger_path
                            local nearest_nodes = P:nearest_nodes(dest.x, dest.y, {dest_path})
                            local pi, spi, ni = unpack(nearest_nodes[1])
                            local spread = aa.spread[pow.level]
                            local node_skip = aa.node_skip[pow.level]
                            local nindices = {}

                            for ni_candidate = ni - spread, ni + spread, node_skip do
                                if P:is_node_valid(pi, ni_candidate) then
                                    table.insert(nindices, ni_candidate)
                                end
                            end

                            table.append(nindices, table.map(nindices, function(index, value)
                                return value + 1
                            end))
                            S:queue(aa.sounds[pow.level])
                            U.animation_start_group(this, aa.animation_loop, nil, store.tick_ts, true, "layers")

                            for _, ni_candidate in ipairs(table.random_order(nindices)) do
                                local spi = math.random(1, 3)
                                local destination = P:node_pos(pi, spi, ni_candidate)
                                local b = shoot_bullet(aa, nil, destination, 1)
                                local min_time = aa.time_between_bombs_min
                                local max_time = aa.time_between_bombs_max

                                U.y_wait(store, fts(math.random(min_time, max_time)))
                            end

                            U.y_animation_wait_group(this, "layers")
                            U.animation_start_group(this, aa.animation_end, nil, store.tick_ts, false, "layers")
                            U.y_animation_wait_group(this, "layers")

                            -- if ao and ao.cooldown and store.tick_ts - ao.ts > ao.cooldown then
                            --     ao.ts = store.tick_ts - (ao.cooldown - a.min_cooldown)
                            -- end
                        elseif aa == ao then
                            aa.ts = store.tick_ts
                            aa.active = true

                            -- for _, attack in ipairs(overheateble_attacks) do
                            --     attack._default_bullet = attack.bullet
                            --     attack.bullet = attack.bullet_overheated
                            -- end

                            S:queue(aa.sound)
                            U.y_animation_play_group(this, aa.animation_charge, nil, store.tick_ts, false, "layers")
                            local mod = E:create_entity("decalmod_tricannon_overheat")
                            mod.modifier.target_id = this.id
                            mod.modifier.source_id = this.id
                            mod.pos = this.pos
                            queue_insert(store, mod)
                            this.decal_mod = mod
                        end
                    end
                end
            end

            local idle_animation = "idle"

            -- if ao and ao.active then
            --     idle_animation = ao.animation_idle
            -- end

            U.y_animation_play_group(this, idle_animation, nil, store.tick_ts, false, "layers")
            coroutine.yield()
        end
    end
end

function scripts.tower_tricannon.remove(this, store)
    if this.decal_mod then
        queue_remove(store, this.decal_mod)
        this.decal_mod = nil
    end

    return true
end

scripts.mod_tricannon_overheat_dps = {}

function scripts.mod_tricannon_overheat_dps.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if not target or target.health.dead then
        return false
    end

    if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
        log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name,
            target.id, target.template_name)

        return false
    end

    if target and target.unit and this.render then
        local s = this.render.sprites[1]

        s.ts = store.tick_ts

        if s.size_names then
            s.name = s.size_names[target.unit.size]
        end

        if s.size_scales then
            s.scale = s.size_scales[target.unit.size]
        end

        if target.render then
            s.z = target.render.sprites[1].z
        end
    end

    this.dps.damage_min = this.dps.damage_config[this.modifier.level]
    this.dps.damage_max = this.dps.damage_config[this.modifier.level]
    this.dps.ts = store.tick_ts - this.dps.damage_every
    this.modifier.ts = store.tick_ts

    signal.emit("mod-applied", this, target)

    return true
end

return scripts
