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
local debug = require("all.debug_macros")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local IS_PHONE = KR_TARGET == "phone"
local IS_CONSOLE = KR_TARGET == "console"
local v = V.v

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
        this.bullet = E:create_entity(this.attacks.list[1].bullet)
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
            local b = E:clone_entity(this.bullet)
            b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
            b.pos.y = this.pos.y + soffset.y + boffset.y
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
            b.bullet.target_id = enemy.id
            b.bullet.level = level
            b.bullet.damage_factor = this.tower.damage_factor

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
                        if pow == pow_p and not pow_p.applied then
                            pow_p.applied = true
                            for i = 1, #pow_p.mods do
                                U.append_mod(this.bullet.bullet, pow_p.mods[i])
                            end
                        elseif pow == pow_t and this.render.sprites[druid_sid].hidden then
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
                            enemy = U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
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
                                enemy = U.refind_foremost_enemy(enemy, store, ax.vis_flags, ax.vis_bans)
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
                            enemy = U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
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
                            enemy = U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
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
                            enemy = U.refind_foremost_enemy(enemy, store, a.vis_flags, a.vis_bans)
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
                                enemy = U.refind_foremost_enemy(enemy, store, aa.vis_flags, aa.vis_bans)
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
                enemy = U.refind_foremost_enemy(enemy, store, attack.vis_flags, attack.vis_bans)
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
                            table.sort(enemies, function(a, b)
                                local e1_magic = enemy_is_silent_target(a)
                                local e2_magic = enemy_is_silent_target(b)
                                if e1_magic and not e2_magic then
                                    return true
                                end
                                if e2_magic and not e1_magic then
                                    return false
                                end
                                return a.id < b.id
                            end)

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
                if not this.decalmod_disintegrate then
                    local mod = E:create_entity("decalmod_arcane_wizard_disintegrate_ready")
                    mod.modifier.target_id = this.id
                    mod.modifier.source_id = this.id
                    mod.pos = this.pos
                    queue_insert(store, mod)
                    this.decalmod_disintegrate = mod
                end
            elseif this.decalmod_disintegrate then
                queue_remove(store, this.decalmod_disintegrate)
                this.decalmod_disintegrate = nil
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
                        U.soldier_inherit_tower_buff_factor(ns, this)
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
                        U.soldier_inherit_tower_buff_factor(s, this)
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
                    target = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, range, nil, a.vis_flags,
                        a.vis_bans, nil, nil, splash_radius)
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
                    pure_damage.reduce_magic_armor = b.bullet.reduce_magic_armor
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
                    local acc = 0

                    if pixie.target or store.tick_ts - pixie.attack_ts <= a.pixie_cooldown * this.tower.cooldown_factor then
                        -- block empty
                    else
                        for ii, aa in ipairs(a.list) do
                            if aa.chance > 0 and math.random() <= aa.chance / (1 - acc) then
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

                if ready_to_use_power(pow_m, am, store, this.tower.cooldown_factor) then
                    local trigger = U.find_first_enemy(store, tpos(this), 0, am.range, am.vis_flags, am.vis_bans)
                    if not trigger then
                        U.y_wait(store, this.tower.guard_time)
                        -- block empty
                    else
                        am.ts = store.tick_ts
                        local trigger_pos = trigger.pos
                        U.animation_start(this, am.animation, nil, store.tick_ts, false, tower_sid)
                        U.y_wait(store, am.shoot_time)

                        local enemy, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, am.range,
                            am.node_prediction, am.vis_flags, am.vis_bans)
                        local dest = enemy and pred_pos or trigger_pos

                        local b = E:create_entity(am.bullet)

                        b.pos.x, b.pos.y = this.pos.x + am.bullet_start_offset.x, this.pos.y + am.bullet_start_offset.y
                        b.bullet.damage_factor = this.tower.damage_factor
                        b.bullet.from = V.vclone(b.pos)
                        b.bullet.to = V.v(b.pos.x + am.launch_vector.x, b.pos.y + am.launch_vector.y)
                        b.bullet.damage_max = b.bullet.damage_max + pow_m.damage_inc * pow_m.level
                        b.bullet.damage_min = b.bullet.damage_min + pow_m.damage_inc * pow_m.level

                        AC:inc_check("ROCKETEER")

                        b.bullet.target_id = enemy and enemy.id or trigger.id
                        b.bullet.source_id = this.id

                        queue_insert(store, b)

                        U.y_animation_wait(this, tower_sid)
                    end
                end

                aa = ac
                if ready_to_use_power(pow_c, aa, store, this.tower.cooldown_factor) then
                    local trigger = U.find_first_enemy(store, tpos(this), 0, a.range, aa.vis_flags, aa.vis_bans)

                    if trigger then
                        am.cooldown = am.cooldown_mixed
                    else
                        am.cooldown = am.cooldown_flying
                    end

                    if not trigger then
                        U.y_wait(store, this.tower.guard_time)
                        -- block empty
                    else
                        aa.ts = store.tick_ts
                        local trigger_pos = trigger.pos
                        last_ts = aa.ts

                        U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)
                        U.y_wait(store, aa.shoot_time)

                        local enemy, __, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range,
                            aa.node_prediction, aa.vis_flags, aa.vis_bans)
                        local dest = enemy and pred_pos or trigger_pos

                        local b = E:create_entity(aa.bullet)

                        b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
                        b.bullet.damage_factor = this.tower.damage_factor
                        b.bullet.from = V.vclone(b.pos)

                        b.bullet.to = dest

                        b.bullet.fragment_count = pow_c.fragment_count_base + pow_c.fragment_count_inc * pow_c.level

                        b.bullet.target_id = enemy and enemy.id or trigger.id
                        b.bullet.source_id = this.id

                        queue_insert(store, b)

                        U.y_animation_wait(this, tower_sid)
                    end
                end
                aa = ab
                if ready_to_attack(aa, store, this.tower.cooldown_factor) and store.tick_ts - last_ts > a.min_cooldown *
                    this.tower.cooldown_factor then
                    local trigger = U.find_first_enemy(store, tpos(this), 0, a.range, aa.vis_flags, aa.vis_bans)

                    if trigger then
                        am.cooldown = am.cooldown_mixed
                    else
                        am.cooldown = am.cooldown_flying
                    end

                    if not trigger then
                        U.y_wait(store, this.tower.guard_time)
                        -- block empty
                    else
                        aa.ts = store.tick_ts
                        local trigger_pos = trigger.pos
                        last_ts = aa.ts

                        U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)
                        U.y_wait(store, aa.shoot_time)

                        local enemy, __, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range,
                            aa.node_prediction, aa.vis_flags, aa.vis_bans)
                        local dest = enemy and pred_pos or trigger_pos

                        local b = E:create_entity(aa.bullet)

                        b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
                        b.bullet.damage_factor = this.tower.damage_factor
                        b.bullet.from = V.vclone(b.pos)

                        b.bullet.to = dest

                        b.bullet.target_id = enemy and enemy.id or trigger.id
                        b.bullet.source_id = this.id

                        queue_insert(store, b)

                        U.y_animation_wait(this, tower_sid)
                    end
                end

                U.animation_start(this, "idle", nil, store.tick_ts)
                coroutine.yield()
            end
        end
    end
}
scripts.lava_dwaarp = {
    update = function(this, store)
        local last_hit_ts = 0
        local cycles_count = 0

        if this.aura.track_source and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if te and te.pos then
                this.pos = te.pos
            end
        end

        last_hit_ts = store.tick_ts - this.aura.cycle_time

        if this.aura.apply_delay then
            last_hit_ts = last_hit_ts + this.aura.apply_delay
        end

        while true do
            if this.interrupt then
                last_hit_ts = 1e+99
            end

            if store.tick_ts - this.aura.ts > this.actual_duration then
                break
            end

            local te = store.entities[this.aura.source_id]

            if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
                if this.render and this.aura.cast_resets_sprite_id then
                    this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
                end

                last_hit_ts = store.tick_ts
                cycles_count = cycles_count + 1

                local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags,
                    this.aura.vis_bans, function(e)
                        return (not this.aura.allowed_templates or
                                   table.contains(this.aura.allowed_templates, e.template_name)) and
                                   (not this.aura.excluded_templates or
                                       not table.contains(this.aura.excluded_templates, e.template_name)) and
                                   (not this.aura.filter_source or this.aura.source_id ~= e.id)
                    end)
                if not targets then
                    -- last_hit_ts = last_hit_ts + fts(1)
                else
                    for i = 1, #targets do
                        local target = targets[i]
                        local new_mod = E:create_entity(this.aura.mod)
                        new_mod.modifier.level = this.aura.level
                        new_mod.modifier.target_id = target.id
                        new_mod.modifier.source_id = this.id
                        new_mod.modifier.damage_factor = this.aura.damage_factor
                        new_mod.template_name = new_mod.template_name .. this.id
                        queue_insert(store, new_mod)
                    end
                end
            end
            coroutine.yield()
        end
        queue_remove(store, this)
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

            local target = U.find_first_enemy(store, tpos(this), 0, a.range, at.vis_flags, at.vis_bans, filter_faerie)

            if target then
                local pred_pos = target.pos
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
                    if ready_to_use_power(pow_c, ca, store, this.tower.cooldown_factor) and
                        U.has_enough_enemies_in_range(store, tpos(this), 0, ca.range, ca.vis_flags, ca.vis_bans, nil,
                            ca.min_count) then
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

                    if U.has_enough_enemies_in_range(store, tpos(this), 0, ca.range, ca.vis_flags, ca.vis_bans, nil,
                        ca.min_count) then
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

                        if targets then
                            for i, target in ipairs(targets) do
                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = target.id
                                d.damage_type = ca.damage_type
                                d.value = pow_c.damage_values[pow_c.level] * this.tower.damage_factor

                                if U.is_inside_ellipse(target.pos, tpos(this), ca.damage_radius * 0.6) then
                                    d.value = d.value * 1.4
                                    if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
                                        local mod = E:create_entity(ca.stun_mod)

                                        mod.modifier.target_id = target.id
                                        mod.modifier.duration = pow_c.stun_durations[pow_c.level]

                                        queue_insert(store, mod)
                                    elseif band(target.vis.bans, F_MOD) == 0 then
                                        local mod = E:create_entity(ca.slow_mod)

                                        mod.modifier.target_id = target.id
                                        mod.modifier.duration = pow_c.stun_durations[pow_c.level]

                                        queue_insert(store, mod)
                                    end
                                elseif band(target.vis.bans, F_MOD) == 0 then
                                    local mod = E:create_entity(ca.slow_mod)

                                    mod.modifier.target_id = target.id
                                    mod.modifier.duration = pow_c.stun_durations[pow_c.level]

                                    queue_insert(store, mod)
                                end
                                queue_damage(store, d)
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

            if store.tick_ts - ao.ts > ao.cooldown * this.cooldown_factor then
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

            if store.tick_ts - am.ts > am.cooldown * this.cooldown_factor then
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
                            U.soldier_inherit_tower_buff_factor(s, this)
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
                        U.soldier_inherit_tower_buff_factor(s, this)
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

scripts.druid_shooter_sylvan = {}

function scripts.druid_shooter_sylvan.update(this, store)
    local a = this.attacks.list[1]

    a.ts = store.tick_ts

    while true do
        if this.owner.tower.blocked or not this.owner.tower.can_do_magic then
            -- block empty
        elseif store.tick_ts - a.ts > a.cooldown * this.owner.tower.cooldown_factor then
            local target, enemies = U.find_foremost_enemy(store, this.owner.pos, 0, a.range, nil, a.vis_flags,
                a.vis_bans, function(v)
                    return not table.contains(a.excluded_templates, v.template_name) and
                               not U.has_modifier(store, v, "mod_druid_sylvan")
                end)

            if target and #enemies > 1 then
                S:queue(a.sound)
                U.animation_start(this, a.animation, nil, store.tick_ts)
                U.y_wait(store, a.cast_time)

                a.ts = store.tick_ts

                local mod = E:create_entity(a.spell)

                mod.modifier.target_id = target.id
                mod.modifier.level = this.owner.powers.sylvan.level
                mod.modifier.damage_factor = this.owner.tower.damage_factor
                queue_insert(store, mod)
            else
                SU.delay_attack(store, a, 1)
            end
        end

        coroutine.yield()
    end
end

scripts.mod_druid_sylvan = {}

function scripts.mod_druid_sylvan.update(this, store)
    local m = this.modifier
    local a = this.attack
    local s = this.render.sprites[2]
    local target = store.entities[m.target_id]

    if not target or not target.health or target.health.dead then
        if target then
            local new_target = U.find_first_enemy(store, target.pos, 0, a.max_range, a.vis_flags, a.vis_bans,
                function(v)
                    return not U.has_modifier(store, v, "mod_druid_sylvan")
                end)
            if new_target then
                local new_mod = E:create_entity(this.template_name)
                new_mod.modifier.target_id = new_target.id
                new_mod.modifier.level = this.modifier.level
                new_mod.modifier.duration = this.modifier.duration - (store.tick_ts - m.ts) + 1
                queue_insert(store, new_mod)
            end
        end
        queue_remove(store, this)
        return
    end

    if s.size_names then
        s.name = s.size_names[target.unit.size]
    end

    local last_hp = target.health.hp
    local ray_ts = 0

    this.pos = target.pos

    while true do
        target = store.entities[m.target_id]
        if not target then
            queue_remove(store, this)
            return
        end

        if target.unit and target.unit.mod_offset then
            s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
        end

        if store.tick_ts - ray_ts > this.ray_cooldown then
            local damage = E:create_entity("damage")
            damage.value = this.damage
            damage.damage_type = DAMAGE_TRUE
            damage.target_id = target.id
            queue_damage(store, damage)
            local dhp = last_hp - target.health.hp

            if dhp > 0 then
                last_hp = target.health.hp

                local targets = U.find_enemies_in_range(store, target.pos, 0, a.max_range, a.vis_flags, a.vis_bans,
                    function(v)
                        return not U.has_modifier(store, v, "mod_druid_sylvan")
                    end)

                if targets then
                    for _, t in pairs(targets) do
                        local b = E:create_entity(a.bullet)

                        b.bullet.damage_max = dhp * a.damage_factor[m.level]
                        b.bullet.damage_min = b.bullet.damage_max
                        b.bullet.target_id = t.id
                        b.bullet.source_id = this.id
                        b.bullet.from = V.v(target.pos.x + target.unit.mod_offset.x,
                            target.pos.y + target.unit.mod_offset.y)
                        b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
                        b.pos = V.vclone(b.bullet.from)
                        b.bullet.damage_factor = m.damage_factor
                        queue_insert(store, b)
                    end
                end
            end
            ray_ts = store.tick_ts
        end
        if target.health.dead then
            local new_target = U.find_first_enemy(store, target.pos, 0, a.max_range, a.vis_flags, a.vis_bans,
                function(v)
                    return not U.has_modifier(store, v, "mod_druid_sylvan")
                end)
            if new_target then
                local new_mod = E:create_entity(this.template_name)
                new_mod.modifier.target_id = new_target.id
                new_mod.modifier.level = this.modifier.level
                new_mod.modifier.duration = this.modifier.duration - (store.tick_ts - m.ts) + 1
                queue_insert(store, new_mod)
            end

            queue_remove(store, this)
            return
        end

        if store.tick_ts - m.ts > m.duration then
            queue_remove(store, this)
            return
        end

        coroutine.yield()
    end
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
        local current_bullets = #this.loaded_bullets
        local tries = ba.max_loaded_bullets - current_bullets
        for i = 1, tries do
            if i == 1 or math.random() < ba.multi_rate then
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
                this.loaded_bullets[idx] = b
            end
        end

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
        U.soldier_inherit_tower_buff_factor(s, this)
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
                    U.soldier_inherit_tower_buff_factor(s, this)
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
                            aa.ts = store.tick_ts
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

-- 暮光长弓_START

scripts.tower_dark_elf = {}

function scripts.tower_dark_elf.get_info(this)
    local min, max, d_type

    if this.attacks and this.attacks.list[1].damage_min then
        min, max = this.attacks.list[1].damage_min, this.attacks.list[1].damage_max
    elseif this.attacks and this.attacks.list[1].bullet then
        local b = E:get_template(this.attacks.list[1].bullet)

        min, max = b.bullet.damage_min, b.bullet.damage_max
        d_type = b.bullet.damage_type
    end

    local pow_buff = this.powers and this.powers.skill_buff or nil

    if pow_buff and pow_buff.level > 0 then
        local soulsDamageMin = this.tower_upgrade_persistent_data.souls_extra_damage_min or 0
        local soulsDamageMax = this.tower_upgrade_persistent_data.souls_extra_damage_max or 0

        min = min + soulsDamageMin
        max = max + soulsDamageMax
    end

    min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

    local cooldown

    if this.attacks and this.attacks.list[1].cooldown then
        cooldown = this.attacks.list[1].cooldown
    end

    return {
        type = STATS_TYPE_TOWER,
        damage_min = min,
        damage_max = max,
        damage_type = d_type,
        range = this.attacks.range,
        cooldown = cooldown
    }
end

function scripts.tower_dark_elf.insert(this, store)
    if this.barrack and not this.barrack.rally_pos and this.tower.default_rally_pos then
        this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
    end
    return true
end

function scripts.tower_dark_elf.update(this, store)
    local last_ts = store.tick_ts
    local a_name, a_flip, angle_idx, target, pred_pos
    local attack = this.attacks.list[1]
    local attack_soldiers = this.attacks.list[2]
    local b = this.barrack
    local pow_soldiers = this.powers.skill_soldiers
    local pow_buff = this.powers.skill_buff
    local current_mode = this.tower_upgrade_persistent_data.current_mode

    local function create_mod(target, hidden_sprite)
        local m = E:create_entity(attack.mod_target)
        m.modifier.target_id = target.id
        m.modifier.source_id = this.id
        m.render.sprites[1].hidden = hidden_sprite

        queue_insert(store, m)
    end

    -- 找到范围内生命最高的、且一定能被一发子弹击杀的敌人
    local function find_target_to_kill(node_prediction)
        local target_to_kill, targets, pred_pos = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0,
            this.attacks.range, node_prediction, attack.vis_flags, attack.vis_bans)
        local d = E:create_entity("damage")
        local bullet = E:get_template(attack.bullet).bullet
        d.value = this.tower.damage_factor *
                      (bullet.damage_min + this.tower_upgrade_persistent_data.souls_extra_damage_min)
        d.damage_type = bullet.damage_type
        d.reduce_armor = bullet.reduce_armor

        if targets then
            local target_to_kill_hp = 0
            local target_to_kill_flying = band(target_to_kill.vis.flags, F_FLYING) ~= 0
            for i = 2, #targets do
                local t = targets[i]
                if U.predict_damage(t, d) >= t.health.hp then
                    if t.health.hp > target_to_kill_hp then
                        local flying = band(t.vis.flags, F_FLYING) ~= 0
                        if flying or not target_to_kill_flying then
                            target_to_kill = t
                            target_to_kill_hp = t.health.hp
                            target_to_kill_flying = flying
                            pred_pos = t.__ffe_pos
                        end
                    end
                end
            end
        end

        return target_to_kill, pred_pos
    end

    local function find_target(attack, node_prediction)
        if current_mode == MODE_FIND_FOREMOST then
            return find_target_to_kill(node_prediction)
        elseif current_mode == MODE_FIND_MAXHP then
            local target, pred_pos = U.find_biggest_enemy(store, tpos(this), 0, this.attacks.range, node_prediction,
                attack.vis_flags, attack.vis_bans)

            if target then
                create_mod(target, true)
            end

            return target, pred_pos
        end
    end

    local function retarget(node_prediction)
        local retarget, new_pos = find_target(attack)

        if retarget then
            this.attacks._last_target_pos = pred_pos

            return retarget, new_pos
        else
            target = nil
        end
    end

    local function animation_name_facing_angle_dark_elf(group, source_pos, dest_pos)
        local vx, vy = V.sub(dest_pos.x, dest_pos.y, source_pos.x, source_pos.y)
        local v_angle = V.angleTo(vx, vy)
        local angle = km.unroll(v_angle)
        local angle_deg = km.rad2deg(angle)
        local a = this.render.sprites[this.render.sid_archer]
        local o_name, o_flip, o_idx
        local a1, a2, a3, a4, a5, a6, a7, a8 = 0, 20, 90, 160, 180, 200, 270, 340
        local angles = a.angles[group]

        if a1 <= angle_deg and angle_deg < a2 then
            o_name, o_flip, o_idx = angles[1], false, 1
            -- quadrant = 1
        elseif a2 <= angle_deg and angle_deg < a3 then
            o_name, o_flip, o_idx = angles[2], false, 2
            -- quadrant = 2
        elseif a3 <= angle_deg and angle_deg < a4 then
            o_name, o_flip, o_idx = angles[2], true, 2
            -- quadrant = 3
        elseif a4 <= angle_deg and angle_deg < a5 then
            o_name, o_flip, o_idx = angles[1], true, 1
            -- quadrant = 4
        elseif a5 <= angle_deg and angle_deg < a6 then
            o_name, o_flip, o_idx = angles[4], true, 4
            -- quadrant = 5
        elseif a6 <= angle_deg and angle_deg < a7 then
            o_name, o_flip, o_idx = angles[3], true, 3
            -- quadrant = 6
        elseif a7 <= angle_deg and angle_deg < a8 then
            o_name, o_flip, o_idx = angles[3], false, 3
            -- quadrant = 7
        else
            o_name, o_flip, o_idx = angles[4], false, 4
            -- quadrant = 8
        end

        return o_name, o_flip, o_idx
    end

    local function check_change_mode()
        if this.change_mode then
            this.change_mode = false

            if current_mode == MODE_FIND_FOREMOST then
                current_mode = MODE_FIND_MAXHP
            else
                current_mode = MODE_FIND_FOREMOST
            end

            return true
        end

        return false
    end

    local function check_upgrades_purchase()
        for k, pow in pairs(this.powers) do
            if pow.changed then
                pow.changed = nil

                if pow == pow_soldiers then
                    if not this.controller_soldiers then
                        this.controller_soldiers = E:create_entity(this.controller_soldiers_template)
                        this.controller_soldiers.tower_ref = this
                        this.controller_soldiers.pos = this.pos

                        queue_insert(store, this.controller_soldiers)
                    end

                    this.controller_soldiers.pow_level = pow.level
                else
                    if not this._pow_buff_upgraded then
                        SU.insert_tower_cooldown_buff(store.tick_ts, this, 0.9)
                        this._pow_buff_upgraded = true
                    end
                    pow_buff.max_times = pow_buff.max_times_table[pow_buff.level]
                end
            end
        end
    end

    if not this.attacks._last_target_pos then
        this.attacks._last_target_pos = {}
        this.attacks._last_target_pos = vec_2(REF_W, 0)
    end

    local an, af = U.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

    U.animation_start(this, an, af, store.tick_ts, 1, this.render.sid_archer)

    if this.tower_upgrade_persistent_data.last_ts then
        last_ts = this.tower_upgrade_persistent_data.last_ts
        attack.ts = this.tower_upgrade_persistent_data.last_ts
    else
        attack.ts = store.tick_ts - attack.cooldown + attack.first_cooldown
    end

    ::label_995_0::

    while true do
        if this.tower.blocked then
            coroutine.yield()
        else
            check_upgrades_purchase()
            check_change_mode()
            SU.towers_swaped(store, this, this.attacks.list)

            if store.tick_ts - attack.ts > attack.cooldown * this.tower.cooldown_factor then
                target, pred_pos = find_target(attack, attack.node_prediction_prepare + attack.node_prediction)

                if not target then
                    attack.ts = attack.ts + fts(5)
                    goto label_995_0
                end

                local a_name, a_flip, angle_idx
                local start_ts = store.tick_ts

                this.attacks._last_target_pos = pred_pos

                local an, af = U.animation_name_facing_point(this, "shot_prepare", pred_pos, this.render.sid_archer)

                U.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

                while not U.animation_finished(this, this.render.sid_archer, 1) do
                    check_upgrades_purchase()
                    check_change_mode()

                    if this.tower.blocked then
                        local an, af = U.animation_name_facing_point(this, "idle", pred_pos, this.render.sid_archer)

                        U.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

                        if this.mod_target then
                            queue_remove(store, this.mod_target)
                        end

                        goto label_995_0
                    end

                    coroutine.yield()
                end

                local old_target = target

                if old_target.health.dead then
                    target, pred_pos = retarget(attack.node_prediction)
                end

                if not pred_pos then
                    pred_pos = this.attacks._last_target_pos
                end

                an, af, angle_idx = animation_name_facing_angle_dark_elf("shot", this.pos, pred_pos)

                U.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)
                U.y_wait(store, attack.shoot_time)

                local bullet = E:create_entity(attack.bullet)

                bullet.pos = V.vclone(this.pos)

                local offset_x = af and -attack.bullet_start_offset[angle_idx].x or
                                     attack.bullet_start_offset[angle_idx].x
                local offset_y = attack.bullet_start_offset[angle_idx].y

                bullet.pos = V.v(this.pos.x + offset_x, this.pos.y + offset_y)
                bullet.bullet.from = V.vclone(bullet.pos)
                bullet.bullet.source_id = this.id
                bullet.bullet.damage_factor = this.tower.damage_factor

                if pow_buff.level > 0 then
                    bullet.bullet.damage_min = bullet.bullet.damage_min +
                                                   this.tower_upgrade_persistent_data.souls_extra_damage_min
                    bullet.bullet.damage_max = bullet.bullet.damage_max +
                                                   this.tower_upgrade_persistent_data.souls_extra_damage_max
                end

                apply_precision(bullet)

                if target then
                    bullet.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                        target.pos.y + target.unit.hit_offset.y)
                    bullet.bullet.target_id = target.id
                else
                    bullet.bullet.to = V.vclone(pred_pos)
                    bullet.bullet.target_id = nil
                end

                queue_insert(store, bullet)

                while not U.animation_finished(this, this.render.sid_archer, 1) do
                    check_upgrades_purchase()
                    check_change_mode()
                    coroutine.yield()
                end

                local an, af = U.animation_name_facing_point(this, "shot_end", pred_pos, this.render.sid_archer)

                U.y_animation_play(this, an, af, store.tick_ts, false, this.render.sid_archer)

                attack.ts = start_ts
                last_ts = start_ts
                this.tower.long_idle_pos = V.vclone(pred_pos)
            end

            this.tower_upgrade_persistent_data.last_ts = last_ts

            if store.tick_ts - last_ts > this.tower.long_idle_cooldown then
                local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos,
                    this.render.sid_archer)
                U.animation_start(this, an, af, store.tick_ts, -1, this.render.sid_archer)
                this.attacks._last_target_pos = vec_2(REF_W, 0)
            end

            coroutine.yield()
        end
    end
end

function scripts.tower_dark_elf.remove(this, store)
    if this.controller_soldiers then
        queue_remove(store, this.controller_soldiers)
    end

    return true
end

scripts.mod_tower_dark_elf_big_target = {}

function scripts.mod_tower_dark_elf_big_target.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local source = store.entities[m.source_id]
    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    U.animation_start(this, "run", nil, store.tick_ts)

    local t_id = m.target_id

    while true do
        target = store.entities[m.target_id]

        if target and t_id ~= m.target_id then
            this.pos = target.pos
            t_id = m.target_id
        end

        this.render.sprites[1].hidden = not target or target.health.dead or
                                            source.tower_upgrade_persistent_data.current_mode == 0

        if m.duration >= 0 and store.tick_ts - m.ts > m.duration then
            queue_remove(store, this)

            return
        end

        if this.render and target and target.unit then
            local s = this.render.sprites[1]
            local flip_sign = 1

            if target.render then
                flip_sign = target.render.sprites[1].flip_x and -1 or 1
            end

            if m.health_bar_offset and target.health_bar then
                local hb = target.health_bar.offset
                local hbo = m.health_bar_offset

                s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
            elseif m.use_mod_offset and target.unit.mod_offset then
                s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
            end
        end

        coroutine.yield()
    end
end

scripts.bullet_tower_dark_elf = {}

function scripts.bullet_tower_dark_elf.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local source = store.entities[b.source_id]
    local dest = V.vclone(b.to)

    local function update_sprite()
        if this.track_target and target and target.motion then
            local tpx, tpy = target.pos.x, target.pos.y

            if not b.ignore_hit_offset then
                tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
            end

            local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

            if d > b.max_track_distance then
                log.paranoid("(%s) ray_simple target (%s) out of max_track_distance", this.id, target.id)

                target = nil
            else
                dest.x, dest.y = target.pos.x, target.pos.y

                if target.unit and target.unit.hit_offset then
                    dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
                end
            end
        end

        local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

        s.r = angle
        s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
    end

    local function hit_target()
        if target then
            local d = SU.create_bullet_damage(b, target.id, this.id)

            queue_damage(store, d)

            local mods
            if b.mod then
                mods = type(b.mod) == "table" and b.mod or {b.mod}
            elseif b.mods then
                mods = b.mods
            end
            if mods then
                for _, mod_name in pairs(mods) do
                    local mod = E:create_entity(mod_name)
                    mod.modifier.source_id = this.id
                    mod.modifier.target_id = target.id
                    mod.modifier.level = b.level
                    mod.modifier.source_damage = d
                    mod.modifier.damage_factor = b.damage_factor
                    queue_insert(store, mod)
                end
            end

            local fx = E:create_entity(b.hit_fx)

            fx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            fx.render.sprites[1].ts = store.tick_ts
            fx.render.sprites[1].r = this.render.sprites[1].r

            queue_insert(store, fx)

            local tower = store.entities[source.id]
            if tower then
                local skill_buff = tower.powers.skill_buff
                if skill_buff and skill_buff.level > 0 and skill_buff.times < skill_buff.max_times then
                    if target.health.dead or U.predict_damage(target, d) >= target.health.hp then
                        local soul_mod = E:create_entity(this.skill_buff_mod)
                        soul_mod.pos = V.v(target.pos.x + target.unit.hit_offset.x,
                            target.pos.y + target.unit.hit_offset.y)
                        soul_mod.modifier.source_id = this.id
                        soul_mod.modifier.target_id = target.id
                        soul_mod.tower_id = tower.id
                        queue_insert(store, soul_mod)
                        skill_buff.times = skill_buff.times + 1
                    end
                end
            end
        elseif this.missed_shot and GR:cell_is_only(this.pos.x, this.pos.y, TERRAIN_LAND) then
            local fx = E:create_entity(this.missed_arrow_decal)

            fx.pos = V.v(b.to.x, b.to.y)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)

            local fx = E:create_entity(this.missed_arrow_dust)

            fx.pos = V.v(b.to.x, b.to.y)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)

            local fx = E:create_entity(this.missed_arrow)

            fx.pos = V.v(b.to.x, b.to.y)
            fx.render.sprites[1].ts = store.tick_ts
            fx.render.sprites[1].flip_x = b.to.x > b.from.x

            queue_insert(store, fx)
        end
    end

    if not b.ignore_hit_offset and this.track_target and target and target.motion then
        b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
    end

    s.scale = s.scale or V.v(1, 1)
    s.ts = store.tick_ts

    update_sprite()

    if b.hit_time > fts(1) then
        while store.tick_ts - s.ts < b.hit_time do
            coroutine.yield()

            if target and U.flag_has(target.vis.bans, F_RANGED) then
                target = nil
            end

            if this.track_target then
                update_sprite()
            end
        end
    end

    local already_hit_target = false

    if this.ray_duration then
        while store.tick_ts - s.ts < this.ray_duration do
            if this.track_target then
                update_sprite()
            end

            if source and not store.entities[source.id] then
                queue_remove(store, this)

                break
            end

            if not already_hit_target and store.tick_ts - s.ts > this.hit_delay then
                hit_target()

                already_hit_target = true
            end

            coroutine.yield()

            s.hidden = false
        end
    else
        while not U.animation_finished(this, 1) do
            if source and not store.entities[source.id] then
                queue_remove(store, this)

                break
            end

            if not already_hit_target and store.tick_ts - s.ts > this.hit_delay then
                hit_target(b, target)

                already_hit_target = true
            end

            coroutine.yield()
        end
    end

    queue_remove(store, this)
end

scripts.controller_tower_dark_elf_soldiers = {}

function scripts.controller_tower_dark_elf_soldiers.update(this, store)
    local b = this.tower_ref.barrack
    local check_soldiers_ts = store.tick_ts
    local tower_id = this.tower_ref.id
    local last_pow_level = 1
    local power_data = this.tower_ref.powers.skill_soldiers

    while true do
        if this.pow_level ~= last_pow_level then
            last_pow_level = this.pow_level

            for i = 1, b.max_soldiers do
                local s = b.soldiers[i]

                if s and store.entities[s.id] then
                    s.health.hp_max = power_data.hp[this.pow_level]

                    if s.war_rations_hp_factor then
                        s.health.hp_max = math.ceil(s.health.hp_max * s.war_rations_hp_factor)
                    end

                    s.health.hp = s.health.hp_max
                    s.melee.attacks[1].damage_min = power_data.damage_min[this.pow_level]
                    s.melee.attacks[1].damage_max = power_data.damage_max[this.pow_level]
                    s.melee.attacks[2].damage_min = power_data.damage_min[this.pow_level]
                    s.melee.attacks[2].damage_max = power_data.damage_max[this.pow_level]
                    s.dodge.chance = power_data.dodge_chance[this.pow_level]
                end
            end
        end

        if store.tick_ts - check_soldiers_ts > this.check_soldiers_cooldown and not this.tower_ref.blocked then
            for i = 1, b.max_soldiers do
                local s = b.soldiers[i]

                if not s or s.health.dead and not store.entities[s.id] then
                    S:queue(this.sound_open)

                    this.render.sprites[1].hidden = false

                    U.y_animation_play(this, "open", nil, store.tick_ts)
                    U.animation_start(this, "idle", false, store.tick_ts)

                    s = E:create_entity(b.soldier_type)
                    U.soldier_inherit_tower_buff_factor(s, this.tower_ref)
                    s.soldier.tower_id = this.tower_ref.id
                    s.soldier.tower_soldier_idx = i
                    s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
                    s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
                    s.dest_pos = s.nav_rally.center
                    s.source_id = this.tower_ref.id
                    s.nav_rally.new = true
                    s.health.hp_max = power_data.hp[this.pow_level]

                    if s.war_rations_hp_factor then
                        s.health.hp_max = math.ceil(s.health.hp_max * s.war_rations_hp_factor)
                    end

                    s.melee.attacks[1].damage_min = power_data.damage_min[this.pow_level]
                    s.melee.attacks[1].damage_max = power_data.damage_max[this.pow_level]
                    s.melee.attacks[2].damage_min = power_data.damage_min[this.pow_level]
                    s.melee.attacks[2].damage_max = power_data.damage_max[this.pow_level]
                    s.dodge.chance = power_data.dodge_chance[this.pow_level]

                    queue_insert(store, s)

                    b.soldiers[i] = s
                    check_soldiers_ts = store.tick_ts

                    U.y_wait(store, this.spawn_delay)
                    U.y_animation_play(this, "close", nil, store.tick_ts)

                    this.render.sprites[1].hidden = true

                    goto label_1008_0
                end
            end
        end

        if b.rally_new then
            b.rally_new = false

            signal.emit("rally-point-changed", this)

            local all_dead = true

            for i, s in ipairs(b.soldiers) do
                s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, math.pi * 0.25)
                s.nav_rally.new = true
                all_dead = all_dead and s.health.dead
            end

            if not all_dead then
                S:queue(this.tower_ref.sound_events.change_rally_point)
            end
        end

        ::label_1008_0::

        coroutine.yield()
    end

    queue_remove(store, this)
end

function scripts.controller_tower_dark_elf_soldiers.remove(this, store)
    if this.tower_ref then
        local b = this.tower_ref.barrack

        for i = 1, b.max_soldiers do
            local s = b.soldiers[i]

            if s then
                queue_remove(store, s)
            end
        end
    end

    return true
end

scripts.mod_tower_dark_elf_skill_buff = {}

function scripts.mod_tower_dark_elf_skill_buff.remove(this, store)
    local tower = store.entities[this.tower_id]

    if not tower then
        return true
    end

    local target = store.entities[this.modifier.target_id]

    if not target or not target.health.dead then
        return true
    end

    local bullet = E:create_entity(this.skill_buff_bullet)

    bullet.pos = V.vclone(this.pos)
    bullet.bullet.to = V.v(tower.pos.x + this.tower_offset.x, tower.pos.y + this.tower_offset.y)
    bullet.bullet.from = V.vclone(bullet.pos)
    bullet.bullet.target_id = this.tower_id
    bullet.bullet.source_id = this.modifier.source_id

    queue_insert(store, bullet)

    return true
end

scripts.bullet_tower_dark_elf_skill_buff = {}

function scripts.bullet_tower_dark_elf_skill_buff.insert(this, store)
    local b = this.bullet
    local tower = store.entities[b.target_id]
    if not tower then
        return false
    end
    if this._parent then
        local towers = U.find_towers_in_range(store.towers, tower.pos, {
            min_range = 1,
            max_range = 225
        }, function(t)
            return t.tower.can_be_mod
        end)

        local other_tower = towers and towers[math.random(1, #towers)] or tower

        local new_bullet = E:clone_entity(this)
        new_bullet.bullet.to.x = other_tower.pos.x + E:get_template("mod_tower_dark_elf_skill_buff").tower_offset.x
        new_bullet.bullet.to.y = other_tower.pos.y + E:get_template("mod_tower_dark_elf_skill_buff").tower_offset.y
        new_bullet.bullet.target_id = other_tower.id
        new_bullet._parent = false
        queue_insert(store, new_bullet)
    end

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    local s = this.render.sprites[1]

    if not b.ignore_rotation then
        s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
    end

    U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

    return true
end

function scripts.bullet_tower_dark_elf_skill_buff.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local mspeed = b.min_speed
    local target, ps
    local new_target = false

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    U.y_animation_play(this, "soul_start", nil, store.tick_ts, 1)

    local tower = store.entities[b.target_id]

    if not tower and this.tween.disabled then
        this.tween.disabled = false
        this.tween.ts = store.tick_ts
    end

    S:queue(this.sound_start)
    U.y_animation_play(this, "soul_travelstart", nil, store.tick_ts, 1)

    ::label_1011_0::

    if b.store and not b.target_id then
        S:queue(this.sound_events.summon)

        s.z = Z_OBJECTS
        s.sort_y_offset = b.store_sort_y_offset

        U.animation_start(this, "idle", nil, store.tick_ts, true)

        if ps then
            ps.particle_system.emit = false
        end
    else
        S:queue(this.sound_events.travel)

        s.z = Z_BULLETS
        s.sort_y_offset = nil

        U.animation_start(this, "soul_travel", nil, store.tick_ts, s.loop)

        if ps then
            ps.particle_system.emit = true
        end
    end

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
        coroutine.yield()
        target = store.entities[b.target_id]
        mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
        mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

        if not b.ignore_rotation then
            s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
        end

        if ps then
            ps.particle_system.emit_direction = s.r
        end

        local tower = store.entities[b.target_id]

        if not tower and this.tween.disabled then
            this.tween.disabled = false
            this.tween.ts = store.tick_ts
        end
    end

    while b.store and not b.target_id do
        coroutine.yield()

        if b.target_id then
            mspeed = b.min_speed
            new_target = true

            goto label_1011_0
        end
    end

    local tower = store.entities[b.target_id]

    if not tower then
        queue_remove(store, this)

        return
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y

    if target then
        if this._parent or tower.template_name == "tower_dark_elf_lvl4" then
            if not tower.tower_upgrade_persistent_data.souls_extra_damage_min then
                tower.tower_upgrade_persistent_data.souls_extra_damage_min = 0
            end

            if not tower.tower_upgrade_persistent_data.souls_extra_damage_max then
                tower.tower_upgrade_persistent_data.souls_extra_damage_max = 0
            end

            tower.tower_upgrade_persistent_data.souls_extra_damage_min =
                tower.tower_upgrade_persistent_data.souls_extra_damage_min + tower.powers.skill_buff.damage_min
            tower.tower_upgrade_persistent_data.souls_extra_damage_max =
                tower.tower_upgrade_persistent_data.souls_extra_damage_max + tower.powers.skill_buff.damage_max

            if tower.render.sprites[3].fps < 45 then
                SU.insert_tower_cooldown_buff(store.tick_ts, tower, 0.99)
            end
        else
            if not tower.tower_upgrade_persistent_data.dark_elf_soul_damage_factor then
                tower.tower_upgrade_persistent_data.dark_elf_soul_damage_factor = 0
            end
            tower.tower_upgrade_persistent_data.dark_elf_soul_damage_factor =
                tower.tower_upgrade_persistent_data.dark_elf_soul_damage_factor + 0.08
            U.insert_tower_upgrade_function(tower, function(t, d)
                SU.insert_tower_damage_factor_buff(t, t.tower_upgrade_persistent_data.dark_elf_soul_damage_factor)
            end, "dark_elf_soul_damage_factor")
            SU.insert_tower_damage_factor_buff(tower, 0.008)
        end

        if b.mod or b.mods then
            local mods = b.mods or {b.mod}

            for _, mod_name in pairs(mods) do
                local m = E:create_entity(mod_name)

                m.modifier.target_id = b.target_id
                m.modifier.level = b.level

                queue_insert(store, m)
            end
        end

        if b.hit_payload then
            local hp = b.hit_payload

            hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

            queue_insert(store, hp)
        end
    end

    if b.payload then
        local hp = b.payload

        hp.pos.x, hp.pos.y = b.to.x, b.to.y

        queue_insert(store, hp)
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
        sfx.render.sprites[1].ts = store.tick_ts
        sfx.render.sprites[1].runs = 0

        if target and sfx.render.sprites[1].size_names then
            sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
        end

        queue_insert(store, sfx)
    end

    queue_remove(store, this)
end

-- 暮光长弓_END

-- 恶魔澡坑_START

scripts.tower_demon_pit = {}

function scripts.tower_demon_pit.get_info(this)
    local b = E:create_entity(this.attacks.list[1].bullet)
    local d = E:create_entity(b.bullet.hit_payload)

    if this.powers then
        for pn, p in pairs(this.powers) do
            for i = 1, p.level do
                SU.soldier_power_upgrade(d, pn)
            end
        end
    end

    local s_info = d.info.fn(d)
    local attacks

    if d.melee and d.melee.attacks then
        attacks = d.melee.attacks
    elseif d.ranged and d.ranged.attacks then
        attacks = d.ranged.attacks
    end

    local min, max

    for _, a in pairs(attacks) do
        if a.damage_min then
            local damage_factor = this.tower.damage_factor

            min, max = a.damage_min * damage_factor, a.damage_max * damage_factor

            break
        end
    end

    if min and max then
        min, max = math.ceil(min), math.ceil(max)
    end

    return {
        type = STATS_TYPE_TOWER_BARRACK,
        hp_max = d.health.hp_max,
        damage_min = min,
        damage_max = max,
        armor = d.health.armor,
        respawn = d.health.dead_lifetime
    }
end

function scripts.tower_demon_pit.update(this, store, script)
    local a = this.attacks
    local ab = a.list[1]
    local ag = a.list[2]
    local last_ts = store.tick_ts - ab.cooldown
    local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
    ab.ts = store.tick_ts - ab.cooldown + a.attack_delay_on_spawn
    local nodes_update_ts = store.tick_ts
    local nodes_limit = #nearest_nodes > 5 and 5 or #nearest_nodes
    local attacks = {ag, ab}
    local pows = {}
    local pow_g, pow_m

    if this.powers then
        pows[1] = this.powers.big_guy
        pow_g = this.powers.big_guy
        pow_m = this.powers.master_exploders
    end

    local function shoot_bullet(attack, dest, pow)
        local b = E:create_entity(attack.bullet)
        local bullet_start_offset = attack.bullet_start_offset

        b.pos.x, b.pos.y = this.pos.x + bullet_start_offset.x, this.pos.y + bullet_start_offset.y
        b.bullet.from = V.vclone(b.pos)
        b.bullet.to = V.vclone(dest)
        b.bullet.level = pow and pow.level or 1
        b.bullet.pow_level = pow and pow.level or nil
        b.bullet.source_id = this.id
        b.bullet.damage_factor = this.tower.damage_factor
        queue_insert(store, b)

        return b
    end

    while true do
        if this.tower.blocked then
            coroutine.yield()
        else
            if store.tick_ts - nodes_update_ts > 30 then
                nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
                nodes_update_ts = store.tick_ts
                nodes_limit = #nearest_nodes > 5 and 5 or #nearest_nodes
            end
            if pow_m.changed then
                pow_m.changed = nil
            end
            if pow_g.changed then
                pow_g.changed = nil
                ab.animation = "big_guy_attack"
                ab.animation_reload = "big_guy_reload_2"
                if pow_g.level == 1 then
                    ag.ts = store.tick_ts
                    U.animation_start(this, "big_guy_buy", nil, store.tick_ts, false, this.demons_sid)
                    U.y_animation_wait(this, this.demons_sid)
                end
                ag.cooldown = pow_g.cooldown[pow_g.level]
                ag.ts = store.tick_ts - ag.cooldown
            end

            SU.towers_swaped(store, this, this.attacks.list)

            for i, aa in pairs(attacks) do
                local pow = pows[i]

                if (not pow or pow.level > 0) and ready_to_attack(aa, store, this.tower.cooldown_factor) then
                    local is_idle_shoot = U.has_enemy_in_range(store, tpos(this), 0, a.range * 1.2, aa.vis_flags,
                        aa.vis_bans)

                    if aa == ag then
                        last_ts = store.tick_ts

                        U.animation_start(this, aa.animation, nil, store.tick_ts, false, this.demons_sid)
                        U.y_wait(store, aa.shoot_time)

                        local _, _, enemy_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range * 1.2,
                            aa.node_prediction, aa.vis_flags, aa.vis_bans)

                        if not enemy_pos then
                            local idx = math.random(1, nodes_limit)
                            enemy_pos = P:node_pos(nearest_nodes[idx][1], nearest_nodes[idx][2], nearest_nodes[idx][3])
                        end

                        local b = shoot_bullet(aa, enemy_pos, pow_g)

                        U.y_animation_wait(this, this.demons_sid)
                        U.animation_start(this, aa.animation_reload, nil, store.tick_ts, false, this.demons_sid)
                        U.y_animation_wait(this, this.demons_sid)

                        aa.ts = last_ts
                    elseif aa == ab then
                        last_ts = store.tick_ts

                        local d = E:create_entity(this.decal_reload)

                        d.render.sprites[1].name = this.animation_reload
                        d.pos = V.vclone(this.pos)

                        queue_insert(store, d)
                        U.y_animation_wait(d)
                        U.animation_start(this, aa.animation_reload, nil, store.tick_ts, false, this.demons_sid)
                        U.y_animation_wait(this, this.demons_sid)
                        U.animation_start(this, aa.animation, nil, store.tick_ts, false, this.demons_sid)
                        U.y_wait(store, aa.shoot_time)

                        local _, _, enemy_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range * 1.2,
                            aa.node_prediction, aa.vis_flags, aa.vis_bans)

                        if not enemy_pos then
                            local idx = math.random(1, nodes_limit)
                            enemy_pos = P:node_pos(nearest_nodes[idx][1], nearest_nodes[idx][2], nearest_nodes[idx][3])
                        end

                        shoot_bullet(aa, enemy_pos, pow_m)
                        U.y_animation_wait(this, this.demons_sid)

                        aa.ts = is_idle_shoot and last_ts or store.tick_ts
                    end
                end
            end

            coroutine.yield()
        end
    end
end

scripts.decal_tower_demon_pit_reload = {}

function scripts.decal_tower_demon_pit_reload.update(this, store, script)
    this.render.sprites[1].ts = store.tick_ts

    U.y_animation_wait(this)

    this.render.sprites[1].hidden = true

    queue_remove(store, this)
end

scripts.soldier_tower_demon_pit = {}

function scripts.soldier_tower_demon_pit.update(this, store, script)
    local brk, stam
    local u = UP:get_upgrade("engineer_efficiency")
    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts
    this.nav_rally.center = nil
    this.nav_rally.pos = V.vclone(this.pos)

    local tower = store.entities[this.source_id]
    local damage_factor = 1
    local pow_master_exploders

    if tower and tower.powers and tower.powers.master_exploders.level > 0 then
        local level = tower.powers.master_exploders.level

        damage_factor = tower.powers.master_exploders.explosion_damage_factor[level]
        pow_master_exploders = tower.powers.master_exploders
    end

    local function explosion(r, damage_min, damage_max, dty)
        local targets = U.find_enemies_in_range(store, this.pos, 0, r, 0, bit.bor(F_FLYING, F_CLIFF))
        local factor = damage_factor * this.unit.damage_factor
        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")
                d.value = (u and damage_max or math.random(damage_min, damage_max)) * factor
                d.damage_type = dty
                d.target_id = target.id
                d.source_id = this.id

                queue_damage(store, d)

                local m = E:create_entity(this.explosion_mod_stun)

                m.modifier.source_id = this.id
                m.modifier.target_id = target.id
                m.modifier.duration = this.explosion_mod_stun_duration[this.level]

                queue_insert(store, m)

                if pow_master_exploders then
                    m = E:create_entity(pow_master_exploders.mod)
                    m.modifier.source_id = this.id
                    m.modifier.target_id = target.id
                    m.modifier.damage_factor = this.unit.damage_factor
                    m.modifier.duration = pow_master_exploders.burning_duration[pow_master_exploders.level]
                    m.dps.damage_min = pow_master_exploders.burning_damage_min[pow_master_exploders.level]
                    m.dps.damage_max = pow_master_exploders.burning_damage_max[pow_master_exploders.level]

                    queue_insert(store, m)
                end
            end
        end
    end

    if this.sound_events and this.sound_events.raise then
        S:queue(this.sound_events.raise)
    end

    this.health_bar.hidden = true

    U.y_animation_play(this, "landing", nil, store.tick_ts, 1)

    if not this.health.dead then
        this.health_bar.hidden = nil
    end

    local starting_pos = V.vclone(this.pos)

    this.nav_rally.pos = starting_pos

    local patrol_pos = V.vclone(this.pos)

    patrol_pos.x, patrol_pos.y = patrol_pos.x + this.patrol_pos_offset.x, patrol_pos.y + this.patrol_pos_offset.y

    local nearest_node = P:nearest_nodes(patrol_pos.x, patrol_pos.y, nil, nil, false)[1]
    local pi, spi, ni = unpack(nearest_node)
    local npos = P:node_pos(pi, spi, ni)
    local patrol_pos_2 = V.vclone(this.pos)

    patrol_pos_2.x, patrol_pos_2.y = patrol_pos_2.x - this.patrol_pos_offset.x,
        patrol_pos_2.y - this.patrol_pos_offset.y

    local nearest_node = P:nearest_nodes(patrol_pos_2.x, patrol_pos_2.y, nil, nil, false)[1]
    local pi, spi, ni = unpack(nearest_node)
    local npos_2 = P:node_pos(pi, spi, ni)

    if V.dist2(patrol_pos.x, patrol_pos.y, npos.x, npos.y) > V.dist2(patrol_pos_2.x, patrol_pos_2.y, npos_2.x, npos_2.y) then
        patrol_pos = V.vclone(patrol_pos_2)
    end

    local idle_ts = store.tick_ts
    local patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

    local available_paths = {}
    for k, v in pairs(P.paths) do
        table.insert(available_paths, k)
    end
    if store.level.ignore_walk_backwards_paths then
        available_paths = table.filter(available_paths, function(k, v)
            return not table.contains(store.level.ignore_walk_backwards_paths, v)
        end)
    end

    while true do
        if this.health.dead or
            (this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration) or ni <
            -20 then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            this.health.hp = 0

            U.animation_start(this, "the_expendables", nil, store.tick_ts, false, 1)
            U.unblock_target(store, this)
            U.y_wait(store, fts(20))
            S:queue(this.explosion_sound)
            explosion(this.explosion_range[this.level], this.explosion_damage_min[this.level],
                this.explosion_damage_max[this.level], this.explosion_damage_type)

            local decal = E:create_entity(this.decal_on_explosion)

            decal.pos = V.vclone(this.pos)
            decal.tween.ts = store.tick_ts

            queue_insert(store, decal)
            U.y_animation_wait(this, 1)
            queue_remove(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)

            idle_ts = store.tick_ts
            patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
        else
            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    idle_ts = store.tick_ts
                    patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

                    goto label_833_0
                end
            end

            if V.dist2(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) < 25 then
                ni = ni - 3
                this.nav_rally.pos = P:node_pos(pi, spi, ni)
            end

            if SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)

                if patrol_cd < store.tick_ts - idle_ts then
                    if this.nav_rally.pos == starting_pos then
                        this.nav_rally.pos = patrol_pos
                    else
                        this.nav_rally.pos = starting_pos
                    end

                    idle_ts = store.tick_ts
                    patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
                end
            end
        end

        ::label_833_0::

        coroutine.yield()
    end
end

scripts.projecticle_big_guy_tower_demon_pit = {}

function scripts.projecticle_big_guy_tower_demon_pit.update(this, store, script)
    local jumping = true
    local b = this.bullet
    local bullet_fly = true
    local last_y = this.pos.y
    local flip_x = b.to.x - b.from.x < 0

    U.animation_start(this, "idle_1", flip_x, store.tick_ts, 40)

    local target = store.entities[b.target_id]

    b.ts = store.tick_ts
    b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)

    while bullet_fly do
        coroutine.yield()

        this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

        if jumping and last_y > this.pos.y then
            U.animation_start(this, "idle_2", flip_x, store.tick_ts, false, 1)

            b.g = b.g * 0.95
            jumping = false
        end

        last_y = this.pos.y

        if b.flight_time < store.tick_ts - b.ts then
            bullet_fly = false
        end
    end

    if b.hit_payload then
        local hp

        if type(b.hit_payload) == "string" then
            hp = E:create_entity(b.hit_payload)
        else
            hp = b.hit_payload
        end

        hp.pos.x, hp.pos.y = b.to.x, b.to.y
        hp.level = b.level

        if hp.aura then
            hp.aura.level = this.bullet.level
        end

        queue_insert(store, hp)
    end

    queue_remove(store, this)
end

scripts.big_guy_tower_demon_pit = {}

function scripts.big_guy_tower_demon_pit.update(this, store, script)
    this.health.hp_max = this.health_level[this.level]
    this.health.hp = this.health.hp_max

    local brk, stam

    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts
    this.melee.attacks[1].damage_max = this.damage_max[this.level]
    this.melee.attacks[1].damage_min = this.damage_min[this.level]
    this.nav_rally.center = nil
    this.nav_rally.pos = V.vclone(this.pos)

    if this.sound_events and this.sound_events.raise then
        S:queue(this.sound_events.raise)
    end

    this.health_bar.hidden = true

    U.y_animation_play(this, "landing", nil, store.tick_ts, 1)

    if not this.health.dead then
        this.health_bar.hidden = nil
    end

    local function explosion(r, damage, dty)
        local targets = U.find_enemies_in_range(store, this.pos, 0, r, 0, bit.bor(F_FLYING, F_CLIFF))

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = damage
                d.damage_type = dty
                d.target_id = target.id
                d.source_id = this.id

                queue_damage(store, d)
            end
        end
    end

    local path_ni = 1
    local path_spi = 1
    local path_pi = 1
    local node_pos
    local available_paths = {}

    for k, v in pairs(P.paths) do
        table.insert(available_paths, k)
    end

    if store.level.ignore_walk_backwards_paths then
        available_paths = table.filter(available_paths, function(k, v)
            return not table.contains(store.level.ignore_walk_backwards_paths, v)
        end)
    end

    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

    if #nearest > 0 then
        path_pi, path_spi, path_ni = unpack(nearest[1])
    end

    path_spi = 1
    path_ni = path_ni - 3

    local distance = 0
    local target

    while true do
        if this.health.dead or band(GR:cell_type(this.pos.x, this.pos.y, TERRAIN_TYPES_MASK), TERRAIN_WATER) ~= 0 then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            this.health.hp = 0

            U.animation_start(this, "death", nil, store.tick_ts, false, 1)
            U.y_wait(store, fts(20))
            S:queue(this.explosion_sound)
            explosion(this.explosion_range[this.level], this.explosion_damage[this.level] * this.unit.damage_factor,
                this.explosion_damage_type)
            U.y_animation_wait(this, 1)
            queue_remove(store, this)
            queue_remove(store, this)

            return
        end

        if path_ni < -20 then
            SU.y_soldier_death(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    goto label_837_0
                end
            end

            node_pos = this.nav_rally.pos
            distance = V.dist2(node_pos.x, node_pos.y, this.pos.x, this.pos.y)

            if distance < 25 then
                path_ni = path_ni - 3
                this.nav_rally.pos = P:node_pos(path_pi, path_spi, path_ni)
            end

            if SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_regen(store, this)
            end
        end

        ::label_837_0::

        coroutine.yield()
    end
end

-- 恶魔澡坑_END

-- 死灵法师_STARE

scripts.tower_necromancer_lvl4 = {}

function scripts.tower_necromancer_lvl4.update(this, store)
    local tower_sid = this.render.sid_tower
    local last_ts = store.tick_ts - this.attacks.list[1].cooldown
    local last_ts_shared = store.tick_ts - this.attacks.min_cooldown

    this.attacks._last_target_pos = this.attacks._last_target_pos or vec_2(REF_W, 0)
    this.attacks.list[1].ts = store.tick_ts - this.attacks.list[1].cooldown + this.attacks.attack_delay_on_spawn

    local max_skulls = #this.attacks.list[1].bullet_spawn_offset

    if this.tower_upgrade_persistent_data.swaped then
        this.tower_upgrade_persistent_data = E:clone_c("tower_upgrade_persistent_data")
        this.tower_upgrade_persistent_data.swaped = true

        SU.towers_swaped(store, this, this.attacks.list)
    end

    if not this.tower_upgrade_persistent_data.current_skulls then
        this.tower_upgrade_persistent_data.current_skulls = 0
        this.tower_upgrade_persistent_data.skulls_ref = {}
        last_ts = this.tower_upgrade_persistent_data.last_ts
        this.tower_upgrade_persistent_data.current_skeletons = 0
        this.tower_upgrade_persistent_data.current_golems = 0
        this.tower_upgrade_persistent_data.fire_skulls = false
        this.tower_upgrade_persistent_data.skeletons_ref = {}
    end

    for index, skull in pairs(this.tower_upgrade_persistent_data.skulls_ref) do
        if skull then
            local start_offset = table.safe_index(this.attacks.list[1].bullet_spawn_offset, index)

            skull.pos.x, skull.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
            skull.bullet.source_id = this.id
            skull.bullet.level = 4
        end
    end

    for index, skeleton in pairs(this.tower_upgrade_persistent_data.skeletons_ref) do
        skeleton.source_necromancer = this
    end

    local function find_target(attack)
        local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, this.attacks.range,
            attack.node_prediction, attack.vis_flags, attack.vis_bans)

        return target, pred_pos
    end

    local function is_pos_below(pos)
        return not pos or pos.y < this.pos.y + 50
    end

    local function check_skill_debuff()
        local power = this.powers.skill_debuff
        local attack = this.attacks.list[2]

        if power.level > 0 and ready_to_attack(attack, store, this.tower.cooldown_factor) and
            (store.tick_ts - last_ts_shared > attack.min_cooldown * this.tower.cooldown_factor) then
            local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, attack.max_range,
                attack.node_prediction + attack.cast_time, attack.vis_flags, attack.vis_bans, function(e, o)
                    local node_offset = P:predict_enemy_node_advance(e, attack.node_prediction + attack.cast_time)
                    local e_ni = e.nav_path.ni + node_offset
                    local n_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)

                    return band(GR:cell_type(n_pos.x, n_pos.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) == 0
                end)

            if not enemy or #enemies < attack.min_targets then
                attack.ts = attack.ts + fts(10)
                return
            end

            local start_ts = store.tick_ts

            U.animation_start(this, attack.animation, nil, store.tick_ts, false, this.render.sid_mage)
            U.animation_start(this, "mark_of_silence", nil, store.tick_ts, false, this.render.sid_glow_fx)

            while store.tick_ts - start_ts < attack.cast_time do
                coroutine.yield()
            end

            local debuff_aura = E:create_entity(attack.entity)
            local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, attack.node_prediction)

            debuff_aura.pos = P:node_pos(enemy.nav_path.pi, 1, ni)
            debuff_aura.aura.duration = power.aura_duration[power.level]
            debuff_aura.aura.level = power.level
            debuff_aura.aura.source_id = this.id

            queue_insert(store, debuff_aura)
            U.y_animation_wait(this, this.render.sid_mage)

            attack.ts = start_ts
            last_ts_shared = start_ts
        end
    end

    local function check_skill_rider()
        local power = this.powers.skill_rider
        local attack = this.attacks.list[3]

        if power.level <= 0 or not ready_to_attack(attack, store, this.tower.cooldown_factor) or
            (attack.min_cooldown and store.tick_ts - last_ts_shared < attack.min_cooldown * this.tower.cooldown_factor) then
            return
        end

        local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, attack.max_range, attack.node_prediction,
            attack.vis_flags, attack.vis_bans)

        if not enemy or #enemies < attack.min_targets then
            attack.ts = attack.ts + fts(10)
            return
        end

        local start_ts = store.tick_ts

        U.animation_start(this, attack.animation, nil, store.tick_ts, false, this.render.sid_mage)
        U.animation_start(this, "call_death_rider", nil, store.tick_ts, false, this.render.sid_glow_fx)

        while store.tick_ts - start_ts < attack.cast_time do
            coroutine.yield()
        end

        local rider = E:create_entity(attack.entity)
        local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, attack.node_prediction)

        rider.pos = P:node_pos(enemy.nav_path.pi, 1, ni)
        rider.aura.level = power.level
        rider.path_id = enemy.nav_path.pi

        queue_insert(store, rider)
        U.y_animation_wait(this, this.render.sid_mage)

        attack.ts = start_ts
        last_ts_shared = start_ts
    end

    local target, pred_pos = find_target(this.attacks.list[1])

    if is_pos_below(pred_pos) then
        U.animation_start(this, "idle", nil, store.tick_ts, true, this.render.sid_mage)
    else
        U.animation_start(this, "idle_back", nil, store.tick_ts, true, this.render.sid_mage)
    end

    local had_target = false

    ::label_895_0::

    while true do
        if U.animation_finished(this, this.render.sid_mage) then
            if this.render.sprites[this.render.sid_mage].name == "attack" then
                U.animation_start(this, "idle", nil, store.tick_ts, true, this.render.sid_mage, true)
            elseif this.render.sprites[this.render.sid_mage].name == "attack_back" then
                U.animation_start(this, "idle_back", nil, store.tick_ts, true, this.render.sid_mage)
            end
        end

        if this.tower.blocked then
            coroutine.yield()
        else
            if target and not had_target then
                this.tween.reverse = false
                this.tween.disabled = false
                this.tween.ts = store.tick_ts

                U.animation_start(this, "attack", nil, store.tick_ts, true, this.render.sid_smoke_fx)
            end

            if not target and had_target then
                this.tween.reverse = true
                this.tween.ts = store.tick_ts
            end

            had_target = target ~= nil

            for k, pow in pairs(this.powers) do
                if pow.changed then
                    pow.changed = nil

                    if pow == this.powers.skill_debuff then
                        this.attacks.list[2].cooldown = pow.cooldown[pow.level]
                        this.attacks.list[2].ts = store.tick_ts - this.attacks.list[2].cooldown
                    elseif pow == this.powers.skill_rider then
                        this.attacks.list[3].cooldown = pow.cooldown[pow.level]
                        this.attacks.list[3].ts = store.tick_ts - this.attacks.list[3].cooldown
                    end
                end
            end

            if this.tower_upgrade_persistent_data.current_skulls == 0 then
                this.tower_upgrade_persistent_data.fire_skulls = false
            end

            local attack = this.attacks.list[1]

            if ready_to_attack(attack, store, this.tower.cooldown_factor) and store.tick_ts - last_ts_shared >
                this.attacks.min_cooldown * this.tower.cooldown_factor then
                target, pred_pos = find_target(attack)

                if not target and max_skulls <= this.tower_upgrade_persistent_data.current_skulls then
                    attack.ts = attack.ts + fts(10)
                else
                    local start_ts = store.tick_ts

                    -- if this.tower.level > 1 then
                    U.animation_start(this, "skull_spawn", nil, store.tick_ts, 1, this.render.sid_glow_fx)
                    -- end

                    if is_pos_below(pred_pos) then
                        U.animation_start(this, "attack", nil, store.tick_ts, nil, this.render.sid_mage)
                    else
                        U.animation_start(this, "attack_back", nil, store.tick_ts, nil, this.render.sid_mage)
                    end

                    local b = E:create_entity(attack.bullet)

                    U.y_wait(store, attack.shoot_time)

                    target, pred_pos = find_target(this.attacks.list[1])

                    if target and this.tower_upgrade_persistent_data.current_skulls > 0 then
                        this.tower_upgrade_persistent_data.fire_skulls = true
                        attack.ts = start_ts
                        last_ts = start_ts

                        goto label_895_0
                    end

                    local start_offset
                    local fire_directly = this.tower_upgrade_persistent_data.current_skulls == 0 and target

                    if fire_directly then
                        start_offset = V.vclone(attack.bullet_start_offset)

                        if this.render.sprites[this.render.sid_mage].name == "attack_back" then
                            start_offset.x = -start_offset.x
                        end
                    else
                        start_offset = table.safe_index(attack.bullet_spawn_offset,
                            this.tower_upgrade_persistent_data.current_skulls + 1)
                    end

                    attack.ts = start_ts
                    last_ts = start_ts
                    b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.vclone(b.pos)
                    b.bullet.source_id = this.id
                    b.bullet.level = 4
                    b.bullet.damage_factor = this.tower.damage_factor
                    -- b.tower_ref = this
                    b.render.sprites[1].flip_x = this.tower_upgrade_persistent_data.current_skulls > 0 and
                                                     this.tower_upgrade_persistent_data.current_skulls < 3
                    b.fire_directly = fire_directly

                    if this.tower_upgrade_persistent_data.current_skulls < 2 then
                        b.render.sprites[1].z = Z_OBJECTS
                        b.render.sprites[1].sort_y_offset = -40 - 10 * 4
                    else
                        b.render.sprites[1].z = Z_OBJECTS
                        b.render.sprites[1].sort_y_offset = -40 * 4
                        b.render.sprites[1].draw_order = 2
                    end

                    queue_insert(store, b)

                    this.tower_upgrade_persistent_data.current_skulls =
                        this.tower_upgrade_persistent_data.current_skulls + 1
                    this.tower_upgrade_persistent_data.skulls_ref[this.tower_upgrade_persistent_data.current_skulls] = b
                end
            end

            check_skill_debuff()
            check_skill_rider()

            this.tower_upgrade_persistent_data.last_ts = last_ts

            coroutine.yield()
        end
    end
end

function scripts.tower_necromancer_lvl4.remove(this, store)
    if this.tower_upgrade_persistent_data.skulls_ref and not this.tower.upgrade_to then
        for _, skull in pairs(this.tower_upgrade_persistent_data.skulls_ref) do
            if skull then
                queue_remove(store, skull)
            end
        end
    end

    return true
end

scripts.bullet_tower_necromancer = {}

function scripts.bullet_tower_necromancer.insert(this, store, script)
    local b = this.bullet

    if b.target_id then
        local target = store.entities[b.target_id]

        if not target or band(target.vis.bans, F_RANGED) ~= 0 then
            return false
        end
    end

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    local s = this.render.sprites[1]

    if not b.ignore_rotation then
        s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
    end

    this.source = store.entities[b.source_id]

    if not this.source then
        return false
    end

    U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

    return true
end

function scripts.bullet_tower_necromancer.update(this, store)
    local b = this.bullet
    local target
    local fm = this.force_motion

    local function find_target()
        local attack = this.source.attacks.list[1]
        local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this.source), 0, this.source.attacks.range,
            attack.node_prediction, attack.vis_flags, attack.vis_bans)

        return target, pred_pos
    end

    local function move_step(dest)
        local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
        local dist = V.len(dx, dy)
        local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
        local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

        if dist <= 4 * fm.max_v * store.tick_length then
            stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
        end

        fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
        fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
        fm.a.x, fm.a.y = 0, 0

        return dist <= fm.max_v * store.tick_length
    end

    U.animation_start(this, "idle", nil, store.tick_ts, false, 1)

    local recalculate_spawn_pos = false

    if not this.source then
        queue_remove(store, this)

        return
    end

    if this.source.tower.is_blocked then
        this.fire_directly = false
        recalculate_spawn_pos = true
    end

    local enemy, pred_pos = find_target()

    if this.fire_directly and enemy then
        if enemy then
            goto label_903_0
        else
            recalculate_spawn_pos = true
        end
    else
        S:queue(this.summon_sound)
    end

    if recalculate_spawn_pos then
        local start_offset = table.safe_index(this.source.attacks.list[1].bullet_spawn_offset,
            this.source.tower_upgrade_persistent_data.current_skulls + 1)

        this.pos.x, this.pos.y = this.source.pos.x + start_offset.x, this.source.pos.y + start_offset.y
    end

    U.animation_start(this, "idle", nil, store.tick_ts, false, 2)
    U.y_wait(store, fts(math.random(0, 10)))
    U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

    while not U.animation_finished(this, 2) do
        coroutine.yield()
    end

    this.render.sprites[2].hidden = true

    while not this.source or not this.source.tower_upgrade_persistent_data.fire_skulls or not enemy or not pred_pos do
        if b.source_id ~= this.source.id and store.entities[b.source_id] ~= nil then
            this.source = store.entities[b.source_id]
        end

        if this.source and not this.source.tower.is_blocked then
            enemy, pred_pos = find_target()
        else
            enemy = nil
        end

        this.render.sprites[1].hidden = this.source.render.sprites[2].hidden

        coroutine.yield()
    end

    ::label_903_0::

    if b.source_id ~= this.source.id and store.entities[b.source_id] ~= nil then
        this.source = store.entities[b.source_id]
    end

    this.render.sprites[1].z = Z_BULLETS
    this.source.tower_upgrade_persistent_data.skulls_ref[this.source.tower_upgrade_persistent_data.current_skulls] = nil
    this.source.tower_upgrade_persistent_data.current_skulls =
        this.source.tower_upgrade_persistent_data.current_skulls - 1
    b.to = V.v(pred_pos.x + enemy.unit.hit_offset.x, pred_pos.y + enemy.unit.hit_offset.y)
    b.target_id = enemy.id
    target = store.entities[enemy.id]

    local ps

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.emit = true
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
    local last_pos = V.vclone(this.pos)

    b.ts = store.tick_ts
    this.render.sprites[1].flip_x = pred_pos.x < this.source.pos.x

    S:queue(this.shoot_sound)

    while true do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
            local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x),
                math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

            if d > b.max_track_distance then
                log.info("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id,
                    this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

                target = nil
                b.target_id = nil
            else
                b.to.x, b.to.y = pred_pos.x + target.unit.hit_offset.x, pred_pos.y + target.unit.hit_offset.y
            end
        end

        if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
            local t = store.tick_ts - b.ts

            fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(0, iix, iiy))
        end

        last_pos.x, last_pos.y = this.pos.x, this.pos.y

        if move_step(b.to) then
            break
        end

        coroutine.yield()
    end

    if target and not target.health.dead then
        if b.mods then
            for _, mod_name in pairs(b.mods) do
                local mod = E:create_entity(mod_name)
                mod.modifier.target_id = target.id
                mod.modifier.damage_factor = b.damage_factor
                mod.modifier.source_id = this.source.id
                queue_insert(store, mod)
            end
        elseif b.mod then
            local mod = E:create_entity(b.mod)
            mod.modifier.target_id = target.id
            mod.modifier.damage_factor = b.damage_factor
            mod.modifier.source_id = this.source.id
            queue_insert(store, mod)
        end

        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)
        S:queue(this.hit_sound)
    end

    U.animation_start(this, "hit_FX_idle", nil, store.tick_ts, 1, 1)

    if ps and ps.particle_system.emit then
        ps.particle_system.emit = false
    end

    while not U.animation_finished(this, 1) do
        coroutine.yield()
    end

    this.render.sprites[1].hidden = true

    queue_remove(store, this)
    coroutine.yield()
end

scripts.bullet_tower_necromancer_deathspawn = {}

function scripts.bullet_tower_necromancer_deathspawn.insert(this, store)
    local b = this.bullet

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    local s = this.render.sprites[1]

    if not b.ignore_rotation then
        s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
    end

    U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

    return true
end

function scripts.bullet_tower_necromancer_deathspawn.update(this, store)
    local b = this.bullet
    local fm = this.force_motion

    local function move_step(dest)
        local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
        local dist = V.len(dx, dy)
        local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
        local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

        if dist <= 4 * fm.max_v * store.tick_length then
            stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
        end

        fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
        fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
        fm.a.x, fm.a.y = 0, 0

        return dist <= fm.max_v * store.tick_length
    end

    U.animation_start(this, "idle", nil, store.tick_ts, false, 1)

    U.animation_start(this, "idle", nil, store.tick_ts, false, 2)
    U.y_wait(store, fts(math.random(0, 10)))
    U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

    while not U.animation_finished(this, 2) do
        coroutine.yield()
    end

    this.render.sprites[2].hidden = true

    this.render.sprites[1].z = Z_BULLETS

    local ps

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.emit = true
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
    local last_pos = V.vclone(this.pos)

    b.ts = store.tick_ts

    S:queue(this.shoot_sound)
    local target = U.find_first_enemy(store, this.pos, 0, b.search_range, F_RANGED, F_NONE)
    while not target do
        U.y_wait(store, 1)
        target = U.find_first_enemy(store, this.pos, 0, b.search_range, F_RANGED, F_NONE)
    end
    while true do
        if target then
            b.target_id = target.id
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
        end

        if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
            local t = store.tick_ts - b.ts

            fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(0, iix, iiy))
        end

        last_pos.x, last_pos.y = this.pos.x, this.pos.y

        if move_step(b.to) then
            break
        end
        target = store.entities[b.target_id]
        if not target or target.health.dead then
            U.y_wait(store, 1)
            target = U.find_first_enemy(store, this.pos, 0, b.search_range, F_RANGED, F_NONE)
        end
        coroutine.yield()
    end

    if target and not target.health.dead then
        if b.mods then
            for _, mod_name in pairs(b.mods) do
                local mod = E:create_entity(mod_name)
                mod.modifier.target_id = target.id
                mod.modifier.damage_factor = b.damage_factor
                mod.modifier.source_id = this.id
                queue_insert(store, mod)
            end
        elseif b.mod then
            local mod = E:create_entity(b.mod)
            mod.modifier.target_id = target.id
            mod.modifier.damage_factor = b.damage_factor
            mod.modifier.source_id = this.id
            queue_insert(store, mod)
        end

        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)
        S:queue(this.hit_sound)
    end

    U.animation_start(this, "hit_FX_idle", nil, store.tick_ts, 1, 1)

    if ps and ps.particle_system.emit then
        ps.particle_system.emit = false
    end

    while not U.animation_finished(this, 1) do
        coroutine.yield()
    end

    this.render.sprites[1].hidden = true

    queue_remove(store, this)
    return
end

scripts.mod_tower_necromancer_curse = {}

function scripts.mod_tower_necromancer_curse.insert(this, store, script)
    local m = this.modifier
    local target = store.entities[m.target_id]
    local source = store.entities[m.source_id]

    if not target or not source then
        return false
    end

    if target.health.dead then
        -- block empty
    else
        if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
            log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name,
                target.id, target.template_name)

            return false
        end

        if target.unit and this.render then
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]

                s.flip_x = target.render.sprites[1].flip_x
                s.ts = store.tick_ts

                if s.size_names then
                    s.name = s.size_names[target.unit.size]
                end
            end

            if band(target.vis.flags, F_FLYING) ~= 0 then
                this.render.sprites[2].hidden = true
            end
        end
    end

    if band(target.vis.flags, F_FLYING) ~= 0 or band(target.vis.flags, F_NIGHTMARE) ~= 0 then
        return true
    end

    for _, et in pairs(this.excluded_templates) do
        if et == target.template_name then
            return true
        end
    end

    local entity_name = this.skeleton_name

    this.render.sprites[1].name = this.sprite_small
    this.render.sprites[2].name = this.decal_small

    if (target.unit.size == UNIT_SIZE_MEDIUM or target.unit.size == UNIT_SIZE_LARGE) and
        not table.contains(this.excluded_templates_golem, target.template_name) then
        entity_name = this.skeleton_golem_name
        this.render.sprites[1].name = this.sprite_big
        this.render.sprites[2].name = this.decal_big
    end

    target._necromancer_entity_name = entity_name
    target.old_death_spawns = target.death_spawns

    if not target.death_spawns or target.death_spawns.name ~= entity_name then
        target.death_spawns = nil
    end

    return true
end

function scripts.mod_tower_necromancer_curse.remove(this, store, script)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if target then
        local can_spawn = target.health.dead and target._necromancer_entity_name and
                              band(target.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS)) == 0

        if can_spawn then
            target.death_spawns = nil

            local s = E:create_entity(target._necromancer_entity_name)

            s.pos = V.vclone(target.pos)
            s.source = target

            if s.render and s.render.sprites[1] and target.render and target.render.sprites[1] then
                s.render.sprites[1].flip_x = target.render.sprites[1].flip_x
            end

            if s.nav_path then
                s.nav_path.pi = this.nav_path.pi
                s.nav_path.spi = this.nav_path.spi
                s.nav_path.ni = this.nav_path.ni + 2
            end
            s.unit.damage_factor = s.unit.damage_factor * m.damage_factor
            queue_insert(store, s)

            local bullet = E:create_entity("bullet_tower_necromancer_deathspawn")
            local b = bullet.bullet
            bullet.pos.x = target.pos.x
            bullet.pos.y = target.pos.y
            b.from = V.vclone(bullet.pos)
            b.to = V.vclone(bullet.pos)
            b.damage_factor = m.damage_factor
            queue_insert(store, bullet)
        else
            target._necromancer_entity_name = nil

            if target.old_death_spawns then
                target.death_spawns = target.old_death_spawns
                target.old_death_spawns = nil
            end
        end
    end

    return true
end

scripts.soldier_tower_necromancer_skeleton = {}

function scripts.soldier_tower_necromancer_skeleton.update(this, store, script)
    local brk, stam, star
    local source = this.source

    this.reinforcement.ts = store.tick_ts
    this.nav_rally.pos = V.vclone(this.pos)
    this.nav_rally.center = V.vclone(this.pos)
    this.render.sprites[1].hidden = true
    this._vis_bans = this.vis.bans
    this.vis.bans = F_ALL
    this.ui.can_click = false

    if source and source.unit.fade_time_after_death then
        U.y_wait(store, source.health.dead_lifetime + source.unit.fade_time_after_death)
    elseif this.spawn_delay_min and this.spawn_delay_max then
        U.y_wait(store, math.random(this.spawn_delay_min, this.spawn_delay_max))
    end

    this.vis.bans = this._vis_bans
    this.ui.can_click = true
    this.source_necromancer = nil

    local targets = table.filter(store.towers, function(k, v)
        return not v.pending_removal and v.template_name == "tower_necromancer_lvl4" and
                   U.is_inside_ellipse(v.pos, this.pos, v.attacks.range * 1.1)
    end)
    local kill_oldest_skeleton = false
    local kill_oldest_golem = false

    if targets and #targets > 0 then
        if this.is_golem then
            table.sort(targets, function(e1, e2)
                return e1.tower_upgrade_persistent_data.current_golems < e2.tower_upgrade_persistent_data.current_golems
            end)
        else
            table.sort(targets, function(e1, e2)
                return e1.tower_upgrade_persistent_data.current_skeletons <
                           e2.tower_upgrade_persistent_data.current_skeletons
            end)
        end

        this.source_necromancer = targets[1]

        if this.is_golem then
            kill_oldest_golem = this.source_necromancer.tower_upgrade_persistent_data.current_golems >=
                                    this.source_necromancer.max_golems
            this.source_necromancer.tower_upgrade_persistent_data.current_golems = this.source_necromancer
                                                                                       .tower_upgrade_persistent_data
                                                                                       .current_golems + 1
        else
            kill_oldest_skeleton = this.source_necromancer.tower_upgrade_persistent_data.current_skeletons >=
                                       this.source_necromancer.max_skeletons
            this.source_necromancer.tower_upgrade_persistent_data.current_skeletons = this.source_necromancer
                                                                                          .tower_upgrade_persistent_data
                                                                                          .current_skeletons + 1
        end
    else
        queue_remove(store, this)

        return
    end

    if kill_oldest_skeleton or kill_oldest_golem then
        local targets

        if this.is_golem then
            targets = table.filter(store.soldiers, function(k, v)
                return not v.pending_removal and v.source_necromancer and this.source_necromancer ==
                           v.source_necromancer and v.is_golem and v.health and not v.health.dead and
                           not v.soldier.target_id and this.id ~= v.id
            end)
        else
            targets = table.filter(store.soldiers, function(k, v)
                return not v.pending_removal and v.source_necromancer and this.source_necromancer ==
                           v.source_necromancer and v.health and not v.health.dead and not v.soldier.target_id and
                           this.id ~= v.id
            end)
        end

        if targets and #targets > 0 then
            table.sort(targets, function(e1, e2)
                return e1.id < e2.id
            end)

            targets[1].health.dead = true
            targets[1].health_bar.hidden = true
        else
            if this.is_golem then
                this.source_necromancer.tower_upgrade_persistent_data.current_golems = this.source_necromancer
                                                                                           .tower_upgrade_persistent_data
                                                                                           .current_golems - 1
            else
                this.source_necromancer.tower_upgrade_persistent_data.current_skeletons = this.source_necromancer
                                                                                              .tower_upgrade_persistent_data
                                                                                              .current_skeletons - 1
            end

            queue_remove(store, this)

            return
        end
    end

    table.insert(this.source_necromancer.tower_upgrade_persistent_data.skeletons_ref, this)

    this.render.sprites[1].ts = store.tick_ts
    this.render.sprites[1].hidden = false

    local spawn_fx = E:create_entity(this.spawn_fx)

    spawn_fx.pos = V.vclone(this.pos)
    spawn_fx.render.sprites[1].ts = store.tick_ts

    queue_insert(store, spawn_fx)
    U.y_wait(store, fts(this.spawn_fx_delay))
    S:queue(this.spawn_sound)
    U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)

    local starting_pos = V.vclone(this.pos)

    this.nav_rally.pos = starting_pos

    local patrol_pos = V.vclone(this.pos)

    patrol_pos.x, patrol_pos.y = patrol_pos.x + this.patrol_pos_offset.x, patrol_pos.y + this.patrol_pos_offset.y

    local nearest_node = P:nearest_nodes(patrol_pos.x, patrol_pos.y, nil, nil, false)[1]
    local pi, spi, ni = unpack(nearest_node)
    local npos = P:node_pos(pi, spi, ni)
    local patrol_pos_2 = V.vclone(this.pos)

    patrol_pos_2.x, patrol_pos_2.y = patrol_pos_2.x - this.patrol_pos_offset.x,
        patrol_pos_2.y - this.patrol_pos_offset.y

    local nearest_node = P:nearest_nodes(patrol_pos_2.x, patrol_pos_2.y, nil, nil, false)[1]
    local pi, spi, ni = unpack(nearest_node)
    local npos_2 = P:node_pos(pi, spi, ni)

    if V.dist2(patrol_pos.x, patrol_pos.y, npos.x, npos.y) > V.dist2(patrol_pos_2.x, patrol_pos_2.y, npos_2.x, npos_2.y) then
        patrol_pos = V.vclone(patrol_pos_2)
    end

    local idle_ts = store.tick_ts
    local patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

    while true do
        if this.health.dead then
            SU.y_soldier_death(store, this)

            if this.is_golem then
                this.source_necromancer.tower_upgrade_persistent_data.current_golems = this.source_necromancer
                                                                                           .tower_upgrade_persistent_data
                                                                                           .current_golems - 1
            else
                this.source_necromancer.tower_upgrade_persistent_data.current_skeletons = this.source_necromancer
                                                                                              .tower_upgrade_persistent_data
                                                                                              .current_skeletons - 1
            end

            table.removeobject(this.source_necromancer.tower_upgrade_persistent_data.skeletons_ref, this)
            queue_remove(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)

            idle_ts = store.tick_ts
            patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
        else
            SU.soldier_courage_upgrade(store, this)

            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    idle_ts = store.tick_ts
                    patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

                    goto label_908_0
                end
            end

            if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)

                if patrol_cd < store.tick_ts - idle_ts then
                    if this.nav_rally.pos == starting_pos then
                        this.nav_rally.pos = patrol_pos
                    else
                        this.nav_rally.pos = starting_pos
                    end

                    idle_ts = store.tick_ts
                    patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
                end
            end
        end

        ::label_908_0::

        coroutine.yield()
    end
end

scripts.aura_tower_necromancer_skill_debuff = {}

function scripts.aura_tower_necromancer_skill_debuff.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0
    local sid_totem = 1
    local sid_fx = 2

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    this.render.sprites[sid_fx].hidden = true

    U.y_animation_play(this, "start", nil, store.tick_ts, 1, sid_totem)

    this.render.sprites[sid_fx].hidden = false
    this.tween.props[1].disabled = false
    this.tween.props[1].ts = store.tick_ts

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration then
            break
        end

        if this.aura.source_vis_flags and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
                goto label_915_0
            end
        end

        if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
            if this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
                goto label_915_0
            end

            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.enemy_vis_flags,
                this.aura.enemy_vis_bans) or {}

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                for _, mod_name in pairs(this.aura.enemy_mods) do
                    local new_mod = E:create_entity(mod_name)

                    new_mod.modifier.level = this.aura.level
                    new_mod.modifier.target_id = target.id
                    new_mod.modifier.source_id = this.aura.source_id
                    new_mod.modifier.duration = this.modifier_duration_config[this.aura.level]
                    new_mod.inflicted_damage_factor = this.modifier_inflicted_damage_factor[this.aura.level]

                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        new_mod.render = nil
                    end

                    queue_insert(store, new_mod)
                end
            end

            local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, this.aura.radius,
                this.aura.soldier_vis_flags, this.aura.soldier_vis_bans, function(t)
                    return SU.is_wraith(t.template_name)
                end) or {}

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                for _, mod_name in pairs(this.aura.soldier_mods) do
                    local new_mod = E:create_entity(mod_name)

                    new_mod.modifier.level = this.aura.level
                    new_mod.modifier.target_id = target.id
                    new_mod.modifier.source_id = this.aura.source_id
                    new_mod.modifier.duration = this.modifier_duration_config[this.aura.level]
                    new_mod.inflicted_damage_factor = this.modifier_inflicted_damage_factor[this.aura.level]

                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        new_mod.render = nil
                    end

                    queue_insert(store, new_mod)
                end
            end
        end

        U.animation_start(this, "idle", nil, store.tick_ts, 1, sid_totem)

        ::label_915_0::

        coroutine.yield()
    end

    this.tween.reverse = true
    this.tween.props[1].ts = store.tick_ts

    U.y_animation_play(this, "end", nil, store.tick_ts, 1, sid_totem)
    queue_remove(store, this)
end

scripts.aura_tower_necromancer_skill_rider = {}

function scripts.aura_tower_necromancer_skill_rider.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local sid_rider = 1
    local sid_fx = 2
    local target_pos = this.pos
    local fading = false
    local spawned_fx = false
    local path_ni = 1
    local path_spi = 1
    local path_pi = 1
    local available_paths = {}

    for k, v in pairs(P.paths) do
        table.insert(available_paths, k)
    end

    if store.level.ignore_walk_backwards_paths then
        available_paths = table.filter(available_paths, function(k, v)
            return not table.contains(store.level.ignore_walk_backwards_paths, v)
        end)
    end

    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

    if #nearest > 0 then
        path_pi, path_spi, path_ni = unpack(nearest[1])

        for _, n in pairs(nearest) do
            local _path_pi, _path_spi, _path_ni = unpack(n)

            if _path_pi == this.path_id then
                path_pi, path_spi, path_ni = _path_pi, _path_spi, _path_ni

                break
            end
        end
    end

    path_spi = 1
    path_ni = path_ni - 3

    local distance = 0

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    local function hit_enemies()
        local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags,
            this.aura.vis_bans)
        if not targets then
            return
        end
        for i, target in ipairs(targets) do
            local already_hit_target = false
            local has_mod, mods = U.has_modifiers(store, target, this.aura.mod)

            if has_mod then
                for _, mod in pairs(mods) do
                    if mod.modifier.source_id == this.id then
                        already_hit_target = true

                        break
                    end
                end
            end

            if already_hit_target then
                -- block empty
            else
                this.damage_max = this.damage_max_config[this.aura.level]
                this.damage_min = this.damage_min_config[this.aura.level]

                if target and not target.health.dead and target.enemy then
                    queue_damage(store, SU.create_attack_damage(this, target.id, this))

                    local hit_fx = E:create_entity(this.hit_fx)

                    hit_fx.pos = V.vclone(target.pos)
                    hit_fx.pos.x, hit_fx.pos.y = hit_fx.pos.x + target.unit.hit_offset.x,
                        hit_fx.pos.y + target.unit.hit_offset.y
                    hit_fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, hit_fx)

                    local new_mod = E:create_entity(this.aura.mod)

                    new_mod.modifier.target_id = target.id
                    new_mod.modifier.source_id = this.id

                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        new_mod.render = nil
                    end

                    queue_insert(store, new_mod)
                end
            end
        end
    end

    path_ni = path_ni - 3
    target_pos = P:node_pos(path_pi, path_spi, path_ni)

    local flip_x = target_pos.x < this.pos.x

    U.animation_start(this, "spawn", flip_x, store.tick_ts, 1, sid_rider)
    U.y_wait(store, fts(10))
    hit_enemies()
    U.y_wait(store, fts(10))

    this.tween.props[1].disabled = true
    this.tween.props[1].ts = store.tick_ts

    local psA = E:create_entity(this.particles_name_A)

    psA.particle_system.track_id = this.id
    psA.particle_system.emit = true

    queue_insert(store, psA)

    local psB = E:create_entity(this.particles_name_B)

    psB.particle_system.track_id = this.id
    psB.particle_system.emit = true

    queue_insert(store, psB)

    local function rider_go_back_step()
        if V.veq(this.pos, target_pos) then
            this.motion.arrived = true

            return false
        else
            U.set_destination(this, target_pos)

            if U.walk(this, store.tick_length) then
                return false
            else
                local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

                U.animation_start(this, an, af, store.tick_ts, -1)

                return true
            end
        end
    end

    local function run_backwards()
        local last_pos = this.pos

        distance = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

        if distance < 25 then
            path_ni = path_ni - 3
            target_pos = P:node_pos(path_pi, path_spi, path_ni)
        end

        rider_go_back_step()

        if not spawned_fx then
            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
            local hit_fx

            if an == "walk_side" then
                hit_fx = E:create_entity(this.spawn_side_fx)
            elseif an == "walk_front" then
                hit_fx = E:create_entity(this.spawn_front_fx)
            else
                hit_fx = E:create_entity(this.spawn_back_fx)
            end

            hit_fx.pos = V.vclone(this.pos)
            hit_fx.render.sprites[1].ts = store.tick_ts
            hit_fx.render.sprites[1].flip_x = af

            queue_insert(store, hit_fx)

            spawned_fx = true
        end

        local r = V.angleTo(target_pos.x - last_pos.x, target_pos.y - last_pos.y)

        psA.particle_system.emit_offset.x, psA.particle_system.emit_offset.y =
            V.rotate(r, psA.emit_offset_relative.x, psA.emit_offset_relative.y)
        psB.particle_system.emit_offset.x, psB.particle_system.emit_offset.y =
            V.rotate(r, psB.emit_offset_relative.x, psB.emit_offset_relative.y)
    end

    local function check_start_fade()
        if fading then
            return false
        end

        local fade_duration = this.tween.props[1].keys[2][1]
        local n_pos = P:node_pos(path_pi, path_spi, path_ni - 5)

        if band(GR:cell_type(n_pos.x, n_pos.y), bor(TERRAIN_CLIFF, TERRAIN_WATER)) ~= 0 then
            this.tween.props[1].keys[2][1] = 0.25

            return true
        end

        if this.aura.duration >= 0 and store.tick_ts - this.aura.ts + fade_duration > this.actual_duration then
            return true
        end

        local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

        if #nearest > 0 then
            path_pi, path_spi, path_ni = unpack(nearest[1])

            return path_ni < 10
        end

        return false
    end

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration or fading and
            this.render.sprites[1].alpha <= 0 then
            break
        end

        if check_start_fade() then
            fading = true
            this.tween.props[1].disabled = false
            this.tween.reverse = true
            this.tween.props[1].ts = store.tick_ts
        end

        if this.aura.source_vis_flags and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
                goto label_918_0
            end
        end

        if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
            if this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
                goto label_918_0
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts

            hit_enemies()
        end

        run_backwards()

        ::label_918_0::

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.mod_tower_necromancer_skill_debuff = {}

function scripts.mod_tower_necromancer_skill_debuff.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]
    local source = store.entities[this.modifier.source_id]

    if target and not target.health.dead and target.enemy then
        scripts.cast_silence(target, store)
        return true
    end

    return false
end

function scripts.mod_tower_necromancer_skill_debuff.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos
    m.duration = m.duration_config[m.level]

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node then
            break
        end

        if this.render and target.unit then
            local s = this.render.sprites[1]
            local flip_sign = 1

            if target.render then
                flip_sign = target.render.sprites[1].flip_x and -1 or 1
            end

            if m.health_bar_offset and target.health_bar then
                local hb = target.health_bar.offset
                local hbo = m.health_bar_offset

                s.offset.x, s.offset.y = hb.x + hbo.x * flip_sign, hb.y + hbo.y
            elseif m.use_mod_offset and target.unit.mod_offset then
                s.offset.x, s.offset.y = target.unit.mod_offset.x * flip_sign, target.unit.mod_offset.y
            end
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

function scripts.mod_tower_necromancer_skill_debuff.remove(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if target and not target.health.dead then
        scripts.remove_silence(target, store)
    end

    return true
end

-- 死灵法师_END

-- 熊猫_START

scripts.bolt_tower_pandas_ray = {}

function scripts.bolt_tower_pandas_ray.insert(this, store, script)
    local b = this.bullet

    if b.target_id then
        local target = store.entities[b.target_id]

        if not target or band(target.vis.bans, F_RANGED) ~= 0 then
            return false
        end
    end

    return true
end

function scripts.bolt_tower_pandas_ray.update(this, store, script)
    local b = this.bullet
    local target = store.entities[b.target_id]

    this.pos.x, this.pos.y = b.to.x, b.to.y

    if target and not target.health.dead then
        local d = SU.create_bullet_damage(b, target.id, this.id)
        local u = UP:get_upgrade("mage_spell_of_penetration")

        if u and math.random() < u.chance then
            d.damage_type = DAMAGE_TRUE
        end

        queue_damage(store, d)

        if b.mod or b.mods then
            local mods = b.mods or {b.mod}

            for _, mod_name in pairs(mods) do
                local m = E:create_entity(mod_name)

                m.modifier.target_id = b.target_id
                m.modifier.level = b.level

                queue_insert(store, m)
            end
        end

        if b.hit_payload then
            local hp = b.hit_payload

            hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

            queue_insert(store, hp)
        end
    end

    if b.payload then
        local hp = b.payload

        hp.pos.x, hp.pos.y = b.to.x, b.to.y

        queue_insert(store, hp)
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
        sfx.render.sprites[1].ts = store.tick_ts
        sfx.render.sprites[1].runs = 0

        if target and sfx.render.sprites[1].size_names then
            sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
        end

        queue_insert(store, sfx)
    end

    queue_remove(store, this)
end

scripts.tower_pandas = {}

function scripts.tower_pandas.get_info(this)
    local s = E:create_entity(this.attacks.list[2].soldiers[1])

    if this.powers then
        for pn, p in pairs(this.powers) do
            for i = 1, p.level do
                SU.soldier_power_upgrade(s, pn)
            end
        end
    end

    local s_info = s.info.fn(s)
    local attacks

    if s.melee and s.melee.attacks then
        attacks = s.melee.attacks
    elseif s.ranged and s.ranged.attacks then
        attacks = s.ranged.attacks
    end

    local min, max

    for _, a in pairs(attacks) do
        if a.damage_min then
            local damage_factor = this.tower.damage_factor
            local hit_times_mult = a.hit_times and #a.hit_times or 1

            min, max = a.damage_min * damage_factor * hit_times_mult, a.damage_max * damage_factor * hit_times_mult

            break
        end
    end

    if min and max then
        min, max = math.ceil(min), math.ceil(max)
    end

    return {
        type = STATS_TYPE_TOWER_BARRACK,
        hp_max = s.health.hp_max,
        damage_min = min,
        damage_max = max,
        armor = s.health.armor,
        respawn = s.health.dead_lifetime
    }
end

function scripts.tower_pandas.update(this, store, script)
    local b = this.barrack
    local formation_offset = 0
    local at = this.attacks
    local a = at.list[1]
    local a2 = at.list[2]

    a2.force_retreat_until_ts = store.tick_ts
    a2.next_force_retreat_kill = store.tick_ts

    local function check_change_rally()
        if b.rally_new then
            b.rally_new = false

            signal.emit("rally-point-changed", this)

            local sounds = {}
            local all_dead = true

            for i, s in pairs(b.soldiers) do
                s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, 3, formation_offset)
                s.nav_rally.new = true

                if s.sound_events.change_rally_point then
                    table.insert(sounds, s.sound_events.change_rally_point)
                end

                all_dead = all_dead and s.health.dead
            end

            if not all_dead then
                if #sounds > 0 then
                    S:queue(sounds[math.random(1, #sounds)])
                else
                    S:queue(this.sound_events.change_rally_point)
                end
            end
        end
    end

    local function check_powers()
        for pn, p in pairs(this.powers) do
            if p.changed then
                p.changed = nil

                for _, s in pairs(b.soldiers) do
                    if s.powers[pn] == nil then
                        -- block empty
                    else
                        s.powers[pn].level = p.level
                        s.powers[pn].changed = true
                    end
                end
            end
        end
    end

    local function check_retreat()
        if this.user_selection.in_progress and this.user_selection.arg == "pandas_retreat" then
            this.user_selection.in_progress = nil
            this.user_selection.arg = nil
            a2.ts = store.tick_ts
            a2.force_retreat_until_ts = store.tick_ts + a2.retreat_duration
            a2.next_force_retreat_kill = math.max(a2.next_force_retreat_kill, store.tick_ts)
        end
    end

    local function check_pandas_alive(pandas)
        for _, soldier in pairs(pandas) do
            if soldier.health.hp > 0 then
                return true
            end
        end

        return false
    end

    local function update_checks()
        check_change_rally()
        check_powers()
        check_retreat()
    end

    local function update_click_rect()
        local highest = this.ui.click_rect_heights_by_soldier.none

        for i = 1, #this.pandas do
            local panda = this.pandas[i]

            if panda.status == "on_tower" and highest < this.ui.click_rect_heights_by_soldier[i] then
                highest = this.ui.click_rect_heights_by_soldier[i]
            end
        end

        this.ui.click_rect.size.y = highest
    end

    local function y_panda_tower_animation_play(sid, anim, flip_x)
        U.animation_start(this, anim, flip_x, store.tick_ts, false, sid, true)

        while not U.animation_finished(this, sid) do
            update_checks()
            coroutine.yield()
        end
    end

    this.pandas = {}

    local function random_unique_pair(max)
        local a = math.random(1, max)
        local b

        repeat
            b = math.random(1, max)
        until b ~= a

        return a, b
    end

    if this.tower_upgrade_persistent_data.names == nil then
        local n1, n2 = random_unique_pair(8)
        local n3 = math.random(1, 4)

        this.tower_upgrade_persistent_data.names = {n1, n2, n3}
    end

    for i = 1, 3 do
        this.pandas[i] = {
            status = "on_tower",
            in_animation = false,
            soldier_type = a2.soldiers[i],
            spawn_bullet_type = a2.soldiers_spawn_bullets[i],
            render = i + 2,
            is_panda_green = string.find(a2.soldiers[i], "green"),
            is_panda_red = string.find(a2.soldiers[i], "red"),
            name_index = this.tower_upgrade_persistent_data.names[i]
        }
    end

    local a_base_cooldown = a.cooldown * #this.pandas

    for i = 1, #this.pandas do
        local panda = this.pandas[i]

        for _, soldier in pairs(b.soldiers) do
            if panda.soldier_type == soldier.template_name then
                panda.status = "on_floor"
                this.render.sprites[panda.render].hidden = true
                soldier.soldier.tower_soldier_idx = i
            end
        end
    end

    for i, soldier in pairs(this.barrack.soldiers) do
        soldier.bullet_arrived = true
        soldier.do_level_up_smoke = true
    end

    if this.tower_upgrade_persistent_data.fast_spawns == nil then
        this.tower_upgrade_persistent_data.fast_spawns = 3
    end

    if this.tower_upgrade_persistent_data.old_level == nil then
        this.tower_upgrade_persistent_data.old_level = 0
    end

    local last_panda_spawned_index = math.random(1, #this.pandas)
    local spawn_panda_idx = 1
    local last_target_pos = V.vv(0)
    local prev_target_pos = V.vv(0)

    update_click_rect()

    a.ts = store.tick_ts
    a2.ts = store.tick_ts

    local spawn_cooldown = a2.cooldown
    local shooter_active = false
    local last_panda_shoot_idx = math.random(1, #this.pandas)
    local panda_spawn_anims = {}
    local green_panda_sid

    for _, panda in pairs(this.pandas) do
        if not this.render.sprites[panda.render].hidden then
            U.sprites_hide(this, panda.render, panda.render, true)
            table.insert(panda_spawn_anims, panda.render)
        end

        if panda.is_panda_green then
            green_panda_sid = panda.render
        end
    end

    panda_spawn_anims = table.random_order(panda_spawn_anims)

    if panda_spawn_anims and #panda_spawn_anims > 0 then
        for i, sid in pairs(panda_spawn_anims) do
            U.y_wait(store, 0.05 * i)
            U.sprites_show(this, sid, sid, true)

            local smoke = E:create_entity("fx_panda_smoke_level_up")

            smoke.pos = V.vclone(this.pos)
            smoke.render.sprites[1].offset = V.vclone(this.render.sprites[sid].offset)
            smoke.render.sprites[1].ts = store.tick_ts

            queue_insert(store, smoke)

            U.animation_start(this, "spawn_end", nil, store.tick_ts, false, sid)
        end

        while true do
            update_checks()

            for i, sid in pairs(panda_spawn_anims) do
                if U.animation_finished(this, sid) then
                    table.remove(panda_spawn_anims, i)
                    U.animation_start(this, this.render.sprites[sid].angles.idle[1], nil, store.tick_ts, false, sid,
                        true)
                end
            end

            if #panda_spawn_anims == 0 then
                break
            end

            coroutine.yield()
        end
    end

    while true do
        local old_count = #b.soldiers

        b.soldiers = table.filter(b.soldiers, function(_, s)
            return store.entities[s.id] ~= nil
        end)

        if #b.soldiers > 0 and #b.soldiers ~= old_count then
            for i, s in ipairs(b.soldiers) do
                s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(s.soldier.tower_soldier_idx, b,
                    b.max_soldiers, math.pi * 0.25)
            end
        end

        update_checks()

        if check_pandas_alive(b.soldiers) then
            this.user_selection.actions.tw_free_action.allowed = true
        else
            this.user_selection.actions.tw_free_action.allowed = false
        end

        local enemy

        for i = 1, #this.pandas do
            local panda = this.pandas[i]
            local panda_sprite = this.render.sprites[panda.render]

            if panda.status == "on_floor" and not panda.in_animation then
                local should_continue = true

                for z = 1, #b.soldiers do
                    if panda.soldier_type == b.soldiers[z].template_name and b.soldiers[z].back_to_tower_ts and
                        store.tick_ts >= b.soldiers[z].back_to_tower_ts then
                        b.soldiers[z].back_to_tower_ts = nil
                        should_continue = false

                        break
                    end
                end

                if should_continue then
                    -- block empty
                else
                    U.sprites_show(this, panda.render, panda.render, true)

                    U.animation_start(this, "spawn_end", nil, store.tick_ts, false, panda.render, true)

                    panda.in_animation = true
                end
            end
        end

        for _, panda in pairs(this.pandas) do
            local spr = this.render.sprites[panda.render]

            if spr.name == "spawn_end" and U.animation_finished(this, panda.render) then
                U.animation_start(this, this.render.sprites[panda.render].angles.idle[1], nil, store.tick_ts, false,
                    panda.render, true)

                panda.in_animation = false
                panda.status = "on_tower"

                update_click_rect()
            end
        end

        for i, panda in pairs(this.pandas) do
            local spr = this.render.sprites[panda.render]

            if panda.status == "on_tower" and spr.name == "spawn_in" and U.animation_finished(this, panda.render) then
                local s = E:create_entity(panda.soldier_type)

                s.info.i18n_key = s.info.i18n_key .. "_" .. panda.name_index
                s.soldier.tower_id = this.id
                s.origin_spawn = true
                s.soldier.tower_soldier_idx = i
                s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, math.pi * 0.25)
                s.pos = V.vclone(s.nav_rally.pos)
                s.nav_rally.new = true
                U.soldier_inherit_tower_buff_factor(s, this)
                queue_insert(store, s)

                b.soldiers[#b.soldiers + 1] = s

                signal.emit("tower-spawn", this, s)

                panda.status = "on_floor"

                local bullet = E:create_entity(panda.spawn_bullet_type)

                bullet.pos.x, bullet.pos.y = this.pos.x + this.render.sprites[panda.render].offset.x,
                    this.pos.y + this.render.sprites[panda.render].offset.y + 20
                bullet.bullet.from = V.vclone(bullet.pos)
                bullet.bullet.to = V.vclone(s.pos)
                bullet.bullet.target_id = s.id
                bullet.bullet.source_id = this.id
                bullet.destroy_if_tower_upgraded = true

                queue_insert(store, bullet)
                coroutine.yield()

                panda.in_animation = false

                U.sprites_hide(this, panda.render, panda.render, true)
                update_click_rect()
            end
        end

        for i, panda in pairs(this.pandas) do
            local spr = this.render.sprites[panda.render]
            local start_offset = a.bullet_start_offset[i]

            if spr.name == "spell" and U.animation_finished(this, panda.render) then
                local an, af = U.animation_name_facing_point(this, this.render.sprites[panda.render].angles.idle[1],
                    last_target_pos, panda.render, start_offset)

                if panda.is_panda_green then
                    af = not af
                end

                U.animation_start(this, an, af, store.tick_ts, -1, panda.render)

                panda.in_animation = false
            end
        end

        if store.tick_ts < a2.force_retreat_until_ts and store.tick_ts > a2.next_force_retreat_kill and #b.soldiers > 0 then
            for _, soldier in pairs(b.soldiers) do
                if soldier.health.hp > 0 then
                    soldier.health.hp = 0
                    break
                end
            end

            a2.next_force_retreat_kill = store.tick_ts + 0.15 + math.random() * 0.15
        end

        for _, panda in pairs(this.pandas) do
            local spr = this.render.sprites[panda.render]
            local cfg = panda.shoot_cfg

            if cfg and store.tick_ts >= cfg.shoot_ts then
                enemy = U.find_foremost_enemy(store, tpos(this), 0, at.range + 15, false, a.vis_flags, a.vis_bans)

                if enemy then
                    last_target_pos = enemy.pos

                    local an, af = U.animation_name_facing_point(this, "shoot", enemy.pos, cfg.shooter_sid,
                        cfg.start_offset)

                    if cfg.is_panda_green then
                        af = not af
                    end

                    this.render.sprites[cfg.shooter_sid].flip_x = af

                    local bullet = E:create_entity(cfg.bullet_data.b)

                    bullet.bullet.damage_factor = this.tower.damage_factor
                    bullet.pos.x, bullet.pos.y = this.pos.x + cfg.start_offset.x + cfg.bullet_data.offset.x *
                                                     (af and -1 or 1),
                        this.pos.y + cfg.start_offset.y + cfg.bullet_data.offset.y
                    bullet.bullet.from = V.vclone(bullet.pos)
                    bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
                    bullet.bullet.target_id = enemy.id
                    bullet.bullet.source_id = this.id

                    if bullet.bullet.flight_time_min and bullet.bullet.flight_time_factor then
                        local dist = V.dist(bullet.bullet.to.x, bullet.bullet.to.y, bullet.bullet.from.x,
                            bullet.bullet.from.y)

                        bullet.bullet.flight_time = bullet.bullet.flight_time_min + dist / at.range *
                                                        bullet.bullet.flight_time_factor
                    end

                    queue_insert(store, bullet)
                end

                prev_target_pos = V.vclone(last_target_pos)
                panda.shoot_cfg = nil
            end
        end

        if store.tick_ts - a.ts > this.tower.long_idle_cooldown then
            for _, panda in pairs(this.pandas) do
                local spr = this.render.sprites[panda.render]

                if not panda.in_animation then
                    local an, af = U.animation_name_facing_point(this, this.render.sprites[panda.render].angles.idle[1],
                        this.tower.long_idle_pos, panda.render)
                    af = false
                    U.animation_start(this, an, af, store.tick_ts, -1, panda.render)
                end
            end
        end

        if this.tower.blocked then
            -- block empty
        else
            if this.tower_upgrade_persistent_data.old_level < this.tower.level then
                this.tower_upgrade_persistent_data.old_level = this.tower.level
                this.deploy_all = true
            end

            spawn_cooldown = a2.cooldown

            if this.deploy_all then
                this.deploy_all = nil
                spawn_cooldown = 0
                this.tower_upgrade_persistent_data.fast_spawns = #this.pandas - #b.soldiers
            end

            if this.tower_upgrade_persistent_data.fast_spawns > 0 then
                spawn_cooldown = math.min(spawn_cooldown, 0.2)
            end

            if #b.soldiers >= #this.pandas or spawn_cooldown > store.tick_ts - a2.ts or store.tick_ts <
                a2.force_retreat_until_ts then
                -- block empty
            else
                spawn_panda_idx = last_panda_spawned_index

                for i = 1, #this.pandas do
                    spawn_panda_idx = km.zmod(spawn_panda_idx + 1, #this.pandas)

                    local panda = this.pandas[spawn_panda_idx]
                    local panda_sprite = this.render.sprites[panda.render]

                    if panda.status == "on_tower" and not panda.in_animation then
                        last_panda_spawned_index = spawn_panda_idx

                        S:queue("TowerPandasArrival", {
                            delay = fts(7)
                        })
                        U.animation_start(this, "spawn_in", nil, store.tick_ts, false, panda.render, true)

                        panda.in_animation = true
                        this.tower_upgrade_persistent_data.fast_spawns =
                            this.tower_upgrade_persistent_data.fast_spawns - 1
                        a2.ts = store.tick_ts

                        break
                    end
                end
            end

            shooter_active = false

            for _, panda in pairs(this.pandas) do
                if not this.render.sprites[panda.render].hidden and not panda.in_animation then
                    shooter_active = true

                    break
                end
            end

            if not shooter_active then
                -- block empty
            else
                a.cooldown = a_base_cooldown / (#this.pandas - #this.barrack.soldiers)

                if store.tick_ts - a.ts < a.cooldown * this.tower.cooldown_factor then
                    -- block empty
                else
                    enemy = U.find_foremost_enemy(store, tpos(this), 0, at.range, fts(17), a.vis_flags, a.vis_bans)

                    if enemy then
                        a.ts = store.tick_ts
                        a.count = a.count + 1

                        local panda
                        local shooter_idx = last_panda_shoot_idx
                        local shooter_sid
                        local is_panda_green = false

                        for i = 1, #this.pandas do
                            shooter_idx = km.zmod(shooter_idx + 1, #this.pandas)
                            panda = this.pandas[shooter_idx]

                            if panda.status == "on_tower" and not panda.in_animation then
                                last_panda_shoot_idx = shooter_idx
                                shooter_sid = panda.render
                                is_panda_green = panda.is_panda_green
                                panda.in_animation = true

                                break
                            end
                        end

                        local bullet_data = a.bullet_list[shooter_idx]
                        local start_offset = a.bullet_start_offset[shooter_idx]
                        local an, af =
                            U.animation_name_facing_point(this, "shoot", enemy.pos, shooter_sid, start_offset)

                        if is_panda_green then
                            af = not af
                        end

                        U.animation_start(this, an, af, store.tick_ts, 1, shooter_sid)

                        last_target_pos = enemy.pos
                        panda.shoot_cfg = {
                            bullet_data = bullet_data,
                            start_offset = start_offset,
                            shooter_sid = shooter_sid,
                            is_panda_green = is_panda_green,
                            shoot_ts = a.ts + bullet_data.shoot_time
                        }
                    else
                        a.ts = a.ts + fts(2)
                    end
                end
            end
        end

        coroutine.yield()
    end
end

function scripts.tower_pandas.remove(this, store, script)
    if this.tower.sell then
        for _, panda in pairs(this.pandas) do
            if panda.status == "on_tower" then
                local fx = E:create_entity("fx_tower_panda_disappear_wood")

                fx.pos = V.vclone(this.pos)
                fx.pos.x = fx.pos.x + this.render.sprites[panda.render].offset.x

                if string.find(panda.soldier_type, "blue") then
                    fx.pos.y = fx.pos.y + 30
                elseif string.find(panda.soldier_type, "red") then
                    fx.pos.y = fx.pos.y + 10
                else
                    fx.pos.y = fx.pos.y + 0
                end

                fx.render.sprites[1].flip_x = math.random() > 0.5
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
            end
        end
    end

    return scripts.tower_barrack.remove(this, store, script)
end

scripts.bullet_tower_pandas_spawn_soldier = {}

function scripts.bullet_tower_pandas_spawn_soldier.insert(this, store, script)
    local b = this.bullet

    b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
    b.ts = store.tick_ts
    b.last_pos = V.vclone(b.from)

    return true
end

function scripts.bullet_tower_pandas_spawn_soldier.update(this, store, script)
    local b = this.bullet

    this.render.sprites[1].flip_x = b.from.x > b.to.x

    while store.tick_ts - b.ts + store.tick_length < b.flight_time do
        coroutine.yield()

        b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
        this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

        local source_tower = store.entities[b.source_id]

        if not source_tower then
            queue_remove(store, this)
        end
    end

    if b.target_id and store.entities[b.target_id] then
        local t = store.entities[b.target_id]

        t.render.sprites[1].flip_x = this.render.sprites[1].flip_x
        t.bullet_arrived = true
    end

    queue_remove(store, this)
end

scripts.tower_pandas_ray = {}

function scripts.tower_pandas_ray.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local dest = V.vclone(b.to)
    local tower = this.tower_ref

    local function update_sprite()
        if this.track_target and target and target.motion then
            local tpx, tpy = target.pos.x, target.pos.y

            if not b.ignore_hit_offset then
                tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
            end

            local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

            if d > b.max_track_distance then
                log.paranoid("(%s) ray_simple target (%s) out of max_track_distance", this.id, target.id)

                target = nil
            else
                dest.x, dest.y = target.pos.x, target.pos.y

                if target.unit and target.unit.hit_offset then
                    dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
                end
            end
        end

        local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

        s.r = angle

        local dist_offset = 0

        if this.dist_offset then
            dist_offset = this.dist_offset
        end

        s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width
    end

    if not b.ignore_hit_offset and this.track_target and target and target.motion then
        b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
    end

    s.scale = s.scale or V.v(1, 1)
    s.ts = store.tick_ts

    update_sprite()

    if b.hit_time > fts(1) then
        while store.tick_ts - s.ts < b.hit_time do
            coroutine.yield()

            if target and U.flag_has(target.vis.bans, F_RANGED) then
                target = nil
            end

            if this.track_target then
                update_sprite()
            end
        end
    end

    if target and b.damage_type ~= DAMAGE_NONE then
        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)
    end

    local mods_added = {}

    if target and (b.mod or b.mods) then
        local mods = b.mods or {b.mod}

        for _, mod_name in pairs(mods) do
            local m = E:create_entity(mod_name)
            m.modifier.damage_factor = b.damage_factor
            m.modifier.target_id = b.target_id

            if m.damage_from_bullet then
                if m.dps then
                    m.dps.damage_min = b.damage_min * b.damage_factor
                    m.dps.damage_max = b.damage_max * b.damage_factor
                else
                    m.modifier.damage_min = b.damage_min * b.damage_factor
                    m.modifier.damage_max = b.damage_max * b.damage_factor
                end
            else
                local level

                if not tower then
                    level = this.bullet.level
                else
                    level = 4
                    level = level or this.bullet.level
                end

                m.modifier.level = level
            end

            table.insert(mods_added, m)
            queue_insert(store, m)
        end
    end

    if b.hit_payload then
        local hp

        if type(b.hit_payload) == "string" then
            hp = E:create_entity(b.hit_payload)
        else
            hp = b.hit_payload
        end

        if hp.aura then
            hp.aura.level = this.bullet.level
            hp.aura.source_id = this.id

            if target then
                hp.pos.x, hp.pos.y = target.pos.x, target.pos.y
            else
                hp.pos.x, hp.pos.y = dest.x, dest.y
            end
        else
            hp.pos.x, hp.pos.y = dest.x, dest.y
        end

        queue_insert(store, hp)
    end

    local disable_hit = false

    if this.hit_fx_only_no_target then
        disable_hit = target ~= nil and not target.health.dead
    end

    local fx

    if b.hit_fx and not disable_hit then
        local is_air = target and band(target.vis.flags, F_FLYING) ~= 0

        fx = E:create_entity(b.hit_fx)

        if b.hit_fx_ignore_hit_offset and target and not is_air then
            fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
        else
            fx.pos.x, fx.pos.y = dest.x, dest.y
        end

        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].r = s.r + math.rad(90)
        fx.render.sprites[1].sort_y_offset = this.pos.y - fx.pos.y - 10

        queue_insert(store, fx)
    end

    if this.ray_duration then
        while store.tick_ts - s.ts < this.ray_duration do
            if this.track_target then
                update_sprite()
            end

            if tower and not store.entities[tower.id] then
                queue_remove(store, this)

                if fx then
                    queue_remove(store, fx)
                end

                for key, value in pairs(mods_added) do
                    queue_remove(store, value)
                end

                break
            end

            coroutine.yield()

            s.hidden = false
        end
    else
        while not U.animation_finished(this, 1) do
            if tower and not store.entities[tower.id] then
                queue_remove(store, this)

                break
            end

            coroutine.yield()
        end
    end

    queue_remove(store, this)
end

scripts.bullet_tower_pandas_air = {}

function scripts.bullet_tower_pandas_air.update(this, store, script)
    local b = this.bullet
    local s = this.render.sprites[1]
    local mspeed = b.min_speed
    local target

    this.bounces = 0

    local already_hit = {}
    local ps
    local new_target = false
    local target_invalid = false

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    ::label_1243_0::

    if b.store and not b.target_id then
        S:queue(this.sound_events.summon)

        s.z = Z_OBJECTS
        s.sort_y_offset = b.store_sort_y_offset

        U.animation_start(this, "idle", nil, store.tick_ts, true)

        if ps then
            ps.particle_system.emit = false
        end
    else
        S:queue(this.sound_events.travel)

        s.z = Z_BULLETS
        s.sort_y_offset = nil

        U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

        if ps then
            ps.particle_system.emit = true
        end
    end

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
        coroutine.yield()

        if not target_invalid then
            target = store.entities[b.target_id]
        end

        if target and not new_target then
            local tpx, tpy = target.pos.x, target.pos.y

            if not b.ignore_hit_offset then
                tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
            end

            local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

            if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
                target_invalid = true
                target = nil
            end
        end

        if target and target.health and not target.health.dead then
            if b.ignore_hit_offset then
                b.to.x, b.to.y = target.pos.x, target.pos.y
            else
                b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            end

            new_target = false
        end

        mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
        mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length

        if not b.ignore_rotation then
            s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
        end

        if ps then
            ps.particle_system.emit_direction = s.r
        end
    end

    while b.store and not b.target_id do
        coroutine.yield()

        if b.target_id then
            mspeed = b.min_speed
            new_target = true

            goto label_1243_0
        end
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y

    if target and not target.health.dead then
        table.insert(already_hit, target.id)

        local d = SU.create_bullet_damage(b, target.id, this.id)
        local u = UP:get_upgrade("mage_spell_of_penetration")

        if u and math.random() < u.chance then
            d.damage_type = DAMAGE_TRUE
        end

        queue_damage(store, d)

        if b.mod or b.mods then
            local mods = b.mods or {b.mod}

            for _, mod_name in pairs(mods) do
                local m = E:create_entity(mod_name)

                m.modifier.target_id = b.target_id
                m.modifier.level = b.level
                m.modifier.damage_factor = b.damage_factor
                queue_insert(store, m)
            end
        end

        if b.hit_payload then
            local hp = b.hit_payload

            hp.pos.x, hp.pos.y = this.pos.x, this.pos.y

            queue_insert(store, hp)
        end
    end

    if b.payload then
        local hp = b.payload

        hp.pos.x, hp.pos.y = b.to.x, b.to.y

        queue_insert(store, hp)
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
        sfx.render.sprites[1].ts = store.tick_ts
        sfx.render.sprites[1].runs = 0

        if target and sfx.render.sprites[1].size_names then
            sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
        end

        queue_insert(store, sfx)
    end

    if this.bounces < this.max_bounces[b.level] then
        local targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans,
            function(v)
                return not table.contains(already_hit, v.id)
            end)

        if targets then
            table.sort(targets, function(e1, e2)
                return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) <
                           V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
            end)

            target = targets[1]
            this.bounces = this.bounces + 1
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            b.target_id = target.id
            b.min_speed = b.min_speed * this.bounce_speed_mult
            b.damage_min = math.floor(b.damage_min * this.bounce_damage_mult)

            if b.damage_min < 1 then
                b.damage_min = 1
            end

            b.damage_max = math.floor(b.damage_max * this.bounce_damage_mult)

            if b.damage_max < 1 then
                b.damage_max = 1
            end

            goto label_1243_0
        end
    end

    queue_remove(store, this)
end

scripts.soldier_tower_pandas = {}

function scripts.soldier_tower_pandas.insert(this, store, script)
    if this.melee then
        this.melee.order = U.attack_order(this.melee.attacks)
    end

    if this.ranged then
        this.ranged.order = U.attack_order(this.ranged.attacks)
    end

    if this.info and this.info.random_name_format then
        this.info.i18n_key = string.format(string.gsub(this.info.random_name_format, "_NAME", ""),
            math.random(this.info.random_name_count))
    end

    return true
end

function scripts.soldier_tower_pandas.update(this, store, script)
    local tower = store.entities[this.soldier.tower_id]

    U.sprites_hide(this, nil, nil, true)

    this._spawn_pushed_bans = U.push_bans(this.vis, F_ALL)

    while not this.bullet_arrived do
        coroutine.yield()
    end

    U.sprites_show(this, nil, nil, true)

    if this.do_level_up_smoke then
        local smoke = E:create_entity("fx_panda_smoke_level_up")

        smoke.pos = V.vclone(this.pos)
        smoke.render.sprites[1].ts = store.tick_ts

        queue_insert(store, smoke)
    end

    U.y_animation_play(this, "scape_end", nil, store.tick_ts, 1)

    if this.nav_rally.new and V.dist(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) < 5 then
        this.nav_rally.new = false
    end

    U.pop_bans(this.vis, this._spawn_pushed_bans)

    this._spawn_pushed_bans = nil

    local brk, stam, star

    -- this.render.sprites[1].ts = store.tick_ts

    local pow_i = this.powers and this.powers.thunder or this.powers.hat or this.powers.teleport or nil
    local a_i

    if this.ranged then
        a_i = this.ranged.attacks[1]
    elseif this.attacks then
        a_i = this.attacks.list[1]
    end

    if this.render.sprites[1].name == "raise" then
        if this.sound_events and this.sound_events.raise then
            S:queue(this.sound_events.raise)
        end

        this.health_bar.hidden = true

        U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
    end

    if tower.powers then
        for ptn, p_tower in pairs(tower.powers) do
            if p_tower.level > 0 then
                for pn, p in pairs(this.powers) do
                    if ptn == pn then
                        SU.soldier_power_upgrade(this, pn)

                        if p == pow_i then
                            p.level = p_tower.level
                            a_i.disabled = nil
                            pow_i.cooldown = p.cooldown
                            a_i.level = p.level
                            a_i.cooldown = p.cooldown[p.level]
                            a_i.max_range = p.range[p.level]

                            if a_i.damage_min then
                                a_i.damage_min = p.damage_min[p.level]
                                a_i.damage_max = p.damage_max[p.level]
                            end

                            if a_i.nodes_offset_min then
                                a_i.nodes_offset_min = p.nodes_offset_min[p.level]
                                a_i.nodes_offset_max = p.nodes_offset_max[p.level]
                            end

                            a_i.ts = store.tick_ts - a_i.cooldown

                            if p == this.powers.hat then
                                a_i.bullet = "bullet_tower_pandas_air_soldier_special_lvl" .. p.level
                            end
                        end
                    end
                end
            end
        end
    end

    local function can_thunder()
        if not a_i then
            return false
        end

        if not this.powers.thunder then
            return false
        end

        if pow_i.level < 1 then
            return false
        end

        if not (store.tick_ts - a_i.ts > a_i.cooldown) then
            return false
        end

        if not U.has_enough_enemies_in_range(store, this.pos, 0, a_i.max_range, a_i.vis_flags, a_i.vis_bans, nil,
            a_i.min_targets) then
            SU.delay_attack(store, a_i, fts(10))

            return false
        end

        return true
    end

    local function can_teleport()
        if not a_i then
            return false
        end

        if not this.powers.teleport then
            return false
        end

        if pow_i.level < 1 then
            return false
        end

        if not (store.tick_ts - a_i.ts > a_i.cooldown) then
            return false
        end
        if not U.has_enemy_in_range(store, this.pos, 0, a_i.max_range, a_i.vis_flags, a_i.vis_bans, function(e)
            return not e.enemy.counts or not e.enemy.counts.mod_teleport or e.enemy.counts.mod_teleport <
                       a_i.max_times_applied
        end) then
            SU.delay_attack(store, a_i, fts(10))

            return false
        end
        return true
    end

    local function random_float(lower, greater)
        return lower + math.random() * (greater - lower)
    end

    while true do
        if this.health.dead then
            SU.remove_modifiers(store, this)

            this.back_to_tower_ts = store.tick_ts + this.death_go_back_delay

            SU.y_soldier_death(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_soldier_new_rally(store, this) then
                    goto label_1248_0
                end
            end

            SU.soldier_courage_upgrade(store, this)

            if this.powers then
                for pn, p in pairs(this.powers) do
                    if p.changed then
                        p.changed = nil

                        SU.soldier_power_upgrade(this, pn)

                        if p == pow_i then
                            a_i.disabled = nil
                            pow_i.cooldown = p.cooldown
                            a_i.level = p.level
                            a_i.cooldown = p.cooldown[p.level]
                            a_i.max_range = p.range[p.level]

                            if a_i.damage_min then
                                a_i.damage_min = p.damage_min[p.level]
                                a_i.damage_max = p.damage_max[p.level]
                            end

                            if a_i.nodes_offset_min then
                                a_i.nodes_offset_min = p.nodes_offset_min[p.level]
                                a_i.nodes_offset_max = p.nodes_offset_max[p.level]
                            end

                            if p.level == 1 then
                                a_i.ts = store.tick_ts - a_i.cooldown
                            end

                            if p == this.powers.hat then
                                a_i.bullet = "bullet_tower_pandas_air_soldier_special_lvl" .. p.level
                            end
                        end
                    end
                end
            end

            if can_thunder() then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a_i.max_range, a_i.vis_flags, a_i.vis_bans)

                if not enemies then
                    a_i.ts = a_i.ts + a_i.cooldown * 0.2
                else
                    local grid_size = a_i.damage_area * 0.8
                    local min_enemies = 2
                    local _, _, crowded_pos = U.find_foremost_enemy_with_max_coverage(store, this.pos, 0, a_i.max_range,
                        nil, a_i.vis_flags, a_i.vis_bans, nil, nil, a_i.damage_area)

                    if crowded_pos then
                        a_i.ts = store.tick_ts

                        local an, af = U.animation_name_facing_point(this, a_i.animation, crowded_pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if this.sound_events and this.sound_events.thunder then
                            S:queue(this.sound_events.thunder)
                        end

                        local start_ts = store.tick_ts

                        for shoot_index = 1, #a_i.shoot_times do
                            local shoot_time = a_i.shoot_times[shoot_index]

                            while shoot_time > store.tick_ts - start_ts do
                                coroutine.yield()
                            end

                            local fx = E:create_entity("fx_lightining_soldier_tower_pandas_blue")

                            fx.pos = V.v(crowded_pos.x, crowded_pos.y)

                            if shoot_index > 1 then
                                fx.pos.x = fx.pos.x + math.random(-30, 30)
                                fx.pos.y = fx.pos.y + math.random(-30, 30)
                            end

                            fx.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, fx)

                            if shoot_index == 2 then
                                local affected = U.find_enemies_in_range(store, crowded_pos, 0, a_i.damage_area,
                                    a_i.vis_flags, a_i.vis_bans)

                                if affected then
                                    for _, enemy in ipairs(affected) do
                                        if enemy.health and not enemy.health.dead then
                                            local d = E:create_entity("damage")

                                            d.source_id = this.id
                                            d.target_id = enemy.id

                                            local dmin, dmax = a_i.damage_min, a_i.damage_max

                                            d.value = math.random(dmin, dmax) * this.unit.damage_factor
                                            d.damage_type = a_i.damage_type

                                            queue_damage(store, d)

                                            local mod = E:create_entity(a_i.mod)

                                            mod.modifier.target_id = enemy.id
                                            mod.modifier.source_id = this.id
                                            mod.modifier.damage_factor = this.unit.damage_factor
                                            queue_insert(store, mod)
                                        end
                                    end
                                end
                            end
                        end

                        U.y_animation_wait(this)
                        U.animation_start(this, "idle", nil, store.tick_ts, true)
                    else
                        a_i.ts = a_i.ts + a_i.cooldown * 0.2
                    end
                end
            end

            if can_teleport() then
                local target, targets = U.find_nearest_enemy(store, this.pos, 0, a_i.max_range, a_i.vis_flags,
                    a_i.vis_bans)
                if not target or not targets or #targets < 1 then
                    a_i.ts = a_i.ts + a_i.cooldown * 0.2
                else
                    a_i.ts = store.tick_ts

                    U.animation_start(this, a_i.animation, nil, store.tick_ts, false)

                    if this.sound_events and this.sound_events.teleport then
                        S:queue(this.sound_events.teleport)
                    end

                    U.y_wait(store, a_i.shoot_time)

                    local target, targets = U.find_nearest_enemy(store, this.pos, 0, a_i.max_range, a_i.vis_flags,
                        a_i.vis_bans)

                    if not target or #targets < 1 then
                        a_i.ts = a_i.ts + a_i.cooldown * 0.2
                    else
                        local num_targets = math.min(#targets, a_i.max_targets)
                        local decal = E:create_entity(a_i.decal)

                        decal.pos = V.vclone(this.pos)
                        decal.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, decal)

                        for i = 1, num_targets do
                            local t = targets[i]
                            local d = E:create_entity("damage")

                            d.source_id = this.id
                            d.target_id = t.id

                            local dmin, dmax = a_i.damage_min, a_i.damage_max

                            d.value = math.random(dmin, dmax) * this.unit.damage_factor
                            d.damage_type = a_i.damage_type

                            queue_damage(store, d)

                            local mod_teleport = E:create_entity(a_i.mod)

                            mod_teleport.modifier.target_id = t.id
                            mod_teleport.modifier.source_id = this.id
                            mod_teleport.nodes_offset_min = a_i.nodes_offset_min
                            mod_teleport.nodes_offset_max = a_i.nodes_offset_max
                            mod_teleport.delay_start = random_float(fts(2), fts(5))
                            mod_teleport.hold_time = random_float(0.2, 0.4)
                            mod_teleport.delay_end = random_float(fts(2), fts(5))
                            mod_teleport.begin_wait = random_float(0, 0.2)

                            queue_insert(store, mod_teleport)
                        end

                        U.y_animation_wait(this)
                        U.animation_start(this, "idle", nil, store.tick_ts, true)
                    end
                end
            end

            if this.ranged then
                brk, star = SU.y_soldier_ranged_attacks(store, this)

                if brk or star == A_DONE then
                    goto label_1248_0
                end
            end

            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    goto label_1248_0
                end
            end

            if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_1248_0::

        coroutine.yield()
    end
end

-- 熊猫_END

-- 红法 BEGIN
scripts.tower_ray = {}

function scripts.tower_ray.update(this, store)
    local a = this.attacks
    local ab = this.attacks.list[1]
    local ac = this.attacks.list[2]
    local as = this.attacks.list[3]
    local pow_c = this.powers.chain
    local pow_s = this.powers.sheep
    local last_ts = store.tick_ts - ab.cooldown

    a._last_target_pos = a._last_target_pos or v(REF_W, 0)
    ab.ts = store.tick_ts - ab.cooldown + a.attack_delay_on_spawn

    local idle_ts = store.tick_ts
    local attacks = {}
    local pows = {}

    if as then
        table.insert(attacks, as)
        table.insert(pows, pow_s)
    end

    if ac then
        table.insert(attacks, ac)
        table.insert(pows, pow_c)
    end

    if ab then
        table.insert(attacks, ab)
        table.insert(pows, nil)
    end

    for i = 1, #this.crystals_ids do
        this.tween.props[i].ts = store.tick_ts
    end

    for i = 1, #this.rocks_ids + #this.back_rocks_ids do
        local prop_id = #this.crystals_ids + #this.stones_ids + i
        this.tween.props[prop_id].ts = store.tick_ts - i
    end

    local prop_id = #this.crystals_ids + #this.stones_ids + #this.rocks_ids + #this.back_rocks_ids + 1
    this.tween.props[prop_id].ts = store.tick_ts
    prop_id = prop_id + 1
    this.tween.props[prop_id].ts = this.tween.props[prop_id - 1].ts

    local function find_target(aa)
        local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), 0, a.range, aa.node_prediction,
            aa.vis_flags, aa.vis_bans, function(e, o)
                return not aa.excluded_templates or not table.contains(aa.excluded_templates, e.template_name)
            end)

        return target, pred_pos
    end

    do
        local soffset = this.shooter_offset
        local an, af, ai =
            U.animation_name_facing_point(this, "idle", a._last_target_pos, this.render.sid_mage, soffset)

        U.animation_start(this, an, false, store.tick_ts, true, this.render.sid_mage)
    end

    while true do
        if this.tower.blocked then
            -- block empty
        else
            if pow_c.changed then
                pow_c.changed = nil
                if pow_c.level >= 1 then
                    ab.disabled = true
                    ac.disabled = false
                end
                ac.damage_mult = pow_c.damage_mult[pow_c.level]
                -- local b = E:get_template(ac.bullet)

                -- b.damage_mult = pow_c.damage_mult[pow_c.level]
                ac.ts = store.tick_ts - ac.cooldown

                if not pow_c._shock_fx then
                    pow_c._shock_fx = true
                    for i = 1, #this.shocks_ids do
                        local shock_fx = E:create_entity(this.shock_fx)

                        shock_fx.pos = tpos(this)
                        shock_fx.render.sprites[1].prefix = shock_fx.render.sprites[1].prefix .. this.shocks_ids[i]
                        shock_fx.render.sprites[1].ts = store.tick_ts
                        shock_fx.tower_id = this.id

                        queue_insert(store, shock_fx)
                        U.animation_start(shock_fx, "idle", nil, store.tick_ts, true)
                    end
                end
            end

            if pow_s.changed then
                pow_s.changed = nil
                as.disabled = false
                as.cooldown = pow_s.cooldown[1]
                as.ts = store.tick_ts - as.cooldown
            end

            SU.towers_swaped(store, this, this.attacks.list)

            for i, aa in pairs(attacks) do
                if not aa.disabled and ready_to_attack(aa, store, this.tower.cooldown_factor) and store.tick_ts -
                    last_ts > a.min_cooldown * this.tower.cooldown_factor then
                    if aa == as then
                        local enemy, pred_pos = find_target(aa)

                        if not enemy then
                            aa.ts = aa.ts + fts(10)
                        else
                            local enemy_id = enemy.id
                            local enemy_pos = enemy.pos

                            last_ts = store.tick_ts

                            S:queue(aa.sound)

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_start, enemy.pos,
                                this.render.sid_mage, this.mage_offset)

                            a._last_target_pos.x, a._last_target_pos.y = enemy.pos.x, enemy.pos.y

                            U.animation_start(this, an, nil, store.tick_ts, false, this.render.sid_mage)
                            U.animation_start_group(this, "glow_start", nil, store.tick_ts, false, "rocks")

                            local b = E:create_entity(aa.bullet)
                            local start_offset = aa.bullet_start_offset

                            U.y_wait(store, fts(4))
                            U.animation_start_group(this, "idle_2", nil, store.tick_ts, true, "rocks")
                            U.y_wait(store, aa.shoot_time - fts(4))

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_loop, enemy.pos,
                                this.render.sid_mage, this.mage_offset)

                            a._last_target_pos.x, a._last_target_pos.y = enemy.pos.x, enemy.pos.y

                            U.animation_start(this, an, nil, store.tick_ts, true, this.render.sid_mage)

                            if aa.start_fx then
                                local fx = E:create_entity(aa.start_fx)

                                fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                            end

                            U.y_wait(store, fts(1))

                            enemy, pred_pos = find_target(aa)

                            if enemy then
                                enemy_id = enemy.id
                                enemy_pos = enemy.pos
                            else
                                goto label_989_0
                            end

                            aa.ts = last_ts
                            b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to =
                                V.v(pred_pos.x + enemy.unit.hit_offset.x, pred_pos.y + enemy.unit.hit_offset.y)
                            b.bullet.target_id = enemy_id
                            b.bullet.source_id = this.id
                            b.bullet.level = 4
                            b.tower_ref = this
                            b.pred_pos = V.vclone(pred_pos)

                            queue_insert(store, b)

                            ::label_989_0::

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_end, a._last_target_pos,
                                this.render.sid_mage, this.mage_offset)

                            U.animation_start(this, an, nil, store.tick_ts, false, this.render.sid_mage)
                            U.y_animation_play_group(this, "glow_end", nil, store.tick_ts, 1, "rocks")
                            U.animation_start_group(this, "idle", nil, store.tick_ts, true, "rocks")
                            U.y_animation_wait(this, this.render.sid_mage)

                            local soffset = this.shooter_offset
                            local an, af, ai = U.animation_name_facing_point(this, "idle", a._last_target_pos,
                                this.render.sid_mage, soffset)

                            U.animation_start(this, an, false, store.tick_ts, true, this.render.sid_mage)

                            idle_ts = store.tick_ts
                        end
                    else
                        local enemy, pred_pos = find_target(aa)

                        if not enemy then
                            aa.ts = aa.ts + fts(10)
                        else
                            local enemy_id = enemy.id
                            local enemy_pos = enemy.pos

                            last_ts = store.tick_ts

                            S:queue(aa.sound)

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_start, enemy.pos,
                                this.render.sid_mage, this.mage_offset)

                            a._last_target_pos.x, a._last_target_pos.y = enemy.pos.x, enemy.pos.y

                            U.animation_start(this, an, nil, store.tick_ts, false, this.render.sid_mage)
                            U.animation_start_group(this, "union", nil, store.tick_ts, false, "crystals")

                            U.animation_start_group(this, "glow_start", nil, store.tick_ts, false, "rocks")

                            if aa.start_fx then
                                local fx = E:create_entity(aa.start_fx)

                                fx.pos = V.vclone(tpos(this))
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                            end

                            local b = E:create_entity(aa.bullet)
                            local start_offset = aa.bullet_start_offset

                            U.y_wait(store, fts(4))

                            U.animation_start_group(this, "idle_2", nil, store.tick_ts, true, "rocks")

                            U.y_wait(store, aa.shoot_time - fts(4))

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_loop, enemy.pos,
                                this.render.sid_mage, this.mage_offset)

                            a._last_target_pos.x, a._last_target_pos.y = enemy.pos.x, enemy.pos.y

                            U.animation_start(this, an, nil, store.tick_ts, true, this.render.sid_mage)

                            if b.bullet.out_start_fx then
                                local fx = E:create_entity(b.bullet.out_start_fx)

                                fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                            end

                            if b.bullet.out_fx then
                                local fx = E:create_entity(b.bullet.out_fx)

                                fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)

                                this.ray_fx_start = fx
                            end

                            U.y_wait(store, fts(1))

                            local last_fx = store.tick_ts + fts(3)

                            this.render.sprites[this.render.sid_crystal_union].hidden = false

                            for i = this.render.sid_crystals, this.render.sid_crystals + #this.crystals_ids - 1 do
                                this.render.sprites[i].hidden = true
                            end

                            local range_to_stay = a.range + a.extra_range

                            enemy, pred_pos = find_target(aa)

                            if enemy then
                                enemy_id = enemy.id
                                enemy_pos = enemy.pos
                            else
                                goto label_989_1
                            end

                            this.chain_targets = {enemy.id}
                            b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.vclone(enemy_pos)
                            b.bullet.target_id = enemy_id
                            b.bullet.source_id = this.id
                            b.bullet.level = 4
                            b.bullet.damage_factor = this.tower.damage_factor
                            b.tower_ref = this
                            b.bullet.cooldown_factor = this.tower.cooldown_factor
                            b._is_origin = true
                            if aa == ac then
                                b.damage_mult = ac.damage_mult
                            end
                            queue_insert(store, b)

                            while store.tick_ts - last_ts < aa.duration * this.tower.cooldown_factor + aa.shoot_time and
                                enemy and not enemy.health.dead and b and not b.force_stop_ray and
                                not this.tower.blocked and V.dist2(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <=
                                range_to_stay * range_to_stay do
                                if store.tick_ts - last_fx > 1 and store.tick_ts - last_ts < aa.duration *
                                    this.tower.cooldown_factor + aa.shoot_time - 0.75 and b.bullet.out_start_fx then
                                    local fx = E:create_entity(b.bullet.out_start_fx)

                                    fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                                    fx.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, fx)

                                    last_fx = store.tick_ts
                                end

                                coroutine.yield()
                            end

                            if this.tower.blocked or V.dist2(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) >
                                range_to_stay * range_to_stay then
                                b.force_stop_ray = true
                            end

                            ::label_989_1::

                            aa.ts = last_ts

                            queue_remove(store, this.ray_fx_start)

                            this.render.sprites[this.render.sid_crystal_union].hidden = true

                            for i = this.render.sid_crystals, this.render.sid_crystals + #this.crystals_ids - 1 do
                                this.render.sprites[i].hidden = false
                            end

                            U.animation_start_group(this, "break", nil, store.tick_ts, false, "crystals")

                            local an, af, ai = U.animation_name_facing_point(this, aa.animation_end, a._last_target_pos,
                                this.render.sid_mage, this.mage_offset)

                            U.animation_start(this, an, nil, store.tick_ts, false, this.render.sid_mage)

                            U.y_animation_play_group(this, "glow_end", nil, store.tick_ts, 1, "rocks")
                            U.animation_start_group(this, "idle", nil, store.tick_ts, true, "rocks")

                            U.y_animation_wait(this, this.render.sid_mage)

                            local soffset = this.shooter_offset
                            local an, af, ai = U.animation_name_facing_point(this, "idle", a._last_target_pos,
                                this.render.sid_mage, soffset)

                            U.animation_start(this, an, false, store.tick_ts, true, this.render.sid_mage)

                            idle_ts = store.tick_ts
                        end
                    end
                end
            end

            if store.tick_ts - idle_ts > this.tower.long_idle_cooldown then
                local an, af, ai = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos,
                    this.render.sprites.sid_mage, this.mage_offset)

                U.animation_start(this, "idle", false, store.tick_ts, true, this.render.sprites.sid_mage)
            end
        end
        coroutine.yield()
    end
end

function scripts.tower_ray.remove(this, store)
    if this.ray_fx_start then
        queue_remove(store, this.ray_fx_start)
    end

    return true
end

scripts.fx_tower_ray_lvl4_shock = {}

function scripts.fx_tower_ray_lvl4_shock.update(this, store)
    local cds = {1, 2, 2, 1, 2, 1}
    local cd_id = 1

    local function hide_if_necessary()
        local t = store.entities[this.tower_id]

        if t then
            this.render.sprites[1].hidden = t.render.sprites[1].hidden
        end
    end

    local function y_wait_and_hide(time)
        local start_ts = store.tick_ts

        while time > store.tick_ts - start_ts do
            hide_if_necessary()
            coroutine.yield()
        end
    end

    while store.entities[this.tower_id] do
        this.render.sprites[1].hidden = false

        U.animation_start(this, "idle", nil, store.tick_ts, true)

        while not U.animation_finished(this, 1, cds[cd_id]) do
            hide_if_necessary()
            coroutine.yield()
        end

        this.render.sprites[1].hidden = true

        y_wait_and_hide(1)

        cd_id = cd_id + 1

        if cd_id > #cds then
            cd_id = 1
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.mod_tower_ray_damage = {}

function scripts.mod_tower_ray_damage.update(this, store)
    local current_cycle = 0
    local current_tier = 1
    local m = this.modifier
    local dps = this.dps
    local target = store.entities[m.target_id]

    if not target or target.health.dead then
        queue_remove(store, this)

        return
    end

    local source = store.entities[m.source_id]

    local function apply_damage(value)
        local d = E:create_entity("damage")

        d.source_id = this.id
        d.target_id = target.id
        d.value = value
        d.damage_type = dps.damage_type
        d.pop = dps.pop
        d.pop_chance = dps.pop_chance
        d.pop_conds = dps.pop_conds

        queue_damage(store, d)
    end

    -- 总伤由子弹给出的 dps 确定
    local raw_damage = math.random(this.dps.damage_min, this.dps.damage_max) * m.damage_factor
    local tier_count = #this.damage_tiers
    -- 每个阶段的 dps
    local dps_per_tier = {}
    -- 可以通过调整 m.duration 来调整出伤速度
    local cycles_per_tier = m.duration / (tier_count * dps.damage_every)
    for i = 1, tier_count do
        dps_per_tier[i] = raw_damage * this.damage_tiers[i] / cycles_per_tier
    end
    local current_dps = dps_per_tier[1]

    this.pos = target.pos
    dps.ts = store.tick_ts
    m.ts = store.tick_ts

    if this.forced_start_ts then
        m.ts = this.forced_start_ts
    end
    this.render.sprites[1].scale = V.vv(0.6)
    while true do
        target = store.entities[m.target_id]
        source = store.entities[m.source_id]

        if not target or target.health.dead then
            break
        end

        if not source or source.force_stop_ray then
            break
        end

        if this.render and m.use_mod_offset and target.unit.hit_offset then
            for _, s in ipairs(this.render.sprites) do
                s.offset.x, s.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y
            end
        end

        if store.tick_ts - dps.ts >= dps.damage_every then
            current_cycle = current_cycle + 1
            dps.ts = dps.ts + dps.damage_every
            if current_cycle > cycles_per_tier then
                current_cycle = current_cycle - cycles_per_tier
                current_tier = math.min(current_tier + 1, tier_count)
                current_dps = dps_per_tier[current_tier]
                this.render.sprites[1].scale = V.vv(0.333 + 0.167 * current_tier)
                source.render.sprites[1].scale.y = 0.67 + 0.33 * current_tier
            end
            apply_damage(current_dps)
        end

        coroutine.yield()
    end

    this.tween.disabled = false
    this.tween.ts = store.tick_ts
end

scripts.mod_tower_ray_slow = {}

function scripts.mod_tower_ray_slow.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if not target or target.health.dead or not target.motion or target.motion.invulnerable then
        return false
    end

    if this.modifier.excluded_templates and table.contains(this.modifier.excluded_templates, target.template_name) then
        return false
    end
    U.speed_mul(target, this.slow.factor)
    this.modifier.ts = store.tick_ts

    signal.emit("mod-applied", this, target)

    this.modifier_inserted = true

    return true
end

function scripts.mod_tower_ray_slow.remove(this, store, script)
    if not this.modifier_inserted then
        return true
    end

    local target = store.entities[this.modifier.target_id]

    if target and target.health and target.motion then
        U.speed_div(target, this.slow.factor)
    end

    this.modifier_inserted = false

    return true
end

scripts.bullet_tower_ray = {}

function scripts.bullet_tower_ray.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local dest = V.vclone(b.to)
    local tower = this.tower_ref

    local function update_sprite()
        if target and target.motion then
            local tpx, tpy = target.pos.x, target.pos.y

            if not b.ignore_hit_offset then
                tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
            end

            local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

            if d > b.max_track_distance then
                target = nil
                this.force_stop_ray = true
            else
                dest.x, dest.y = target.pos.x, target.pos.y

                if target.unit and target.unit.hit_offset then
                    dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
                end
            end

            if target then
                b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            end
        end

        local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

        s.r = angle

        local dist_offset = 0

        if this.dist_offset then
            dist_offset = this.dist_offset
        end

        s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width
    end

    if not b.ignore_hit_offset and this.track_target and target and target.motion then
        b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
    end

    s.scale = s.scale or V.vv(1)

    U.animation_start(this, "loop", nil, store.tick_ts, true)
    update_sprite()

    if b.hit_time > fts(1) then
        while store.tick_ts - s.ts < b.hit_time do
            coroutine.yield()

            if target and U.flag_has(target.vis.bans, F_RANGED) then
                target = nil
            end
            update_sprite()
        end
    end

    local mods_added = {}

    if target and (b.mod or b.mods) then
        local mods = b.mods or {b.mod}

        for _, mod_name in pairs(mods) do
            local m = E:create_entity(mod_name)

            m.modifier.target_id = b.target_id
            m.modifier.source_id = this.id
            m.modifier.damage_factor = b.damage_factor * (this._is_origin and 1 or this.damage_mult)
            if mod_name == "mod_tower_ray_damage" then
                m.dps.damage_max = b.damage_max
                m.dps.damage_min = b.damage_min
                m.modifier.duration = m.modifier.duration * b.cooldown_factor
            end
            table.insert(mods_added, m)
            queue_insert(store, m)

            if this.mod_start_ts then
                m.forced_start_ts = this.mod_start_ts
            end
        end
    end

    local disable_hit = false

    if this.hit_fx_only_no_target then
        disable_hit = target ~= nil and not target.health.dead
    end

    local fx

    if b.hit_fx and not disable_hit then
        local is_air = target and band(target.vis.flags, F_FLYING) ~= 0

        fx = E:create_entity(b.hit_fx)

        if b.hit_fx_ignore_hit_offset and target and not is_air then
            fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
        else
            fx.pos.x, fx.pos.y = dest.x, dest.y
        end

        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    end

    local start_ts = store.tick_ts
    local pending_chain = this.chain_pos and this.chain_pos < this.max_enemies
    local chained_next_ray = false
    local start_chain_delay = this.chain_delay
    local source = store.entities[b.source_id]
    local ray_duration = this.ray_duration * b.cooldown_factor
    while store.tick_ts - start_ts < ray_duration and target and not this.force_stop_ray and source do
        if target.health.dead then
            if not this.chain_pos or this.chain_pos == 1 then
                local explosion_fx = E:create_entity("fx_tower_ray_lvl4_attack_sheep_hit")
                explosion_fx.pos = {
                    x = target.pos.x + target.unit.hit_offset.x,
                    y = target.pos.y + target.unit.hit_offset.y
                }
                explosion_fx.render.sprites[1].ts = store.tick_ts
                queue_insert(store, explosion_fx)
                local explosion_targets = U.find_enemies_in_range(store, explosion_fx.pos, 0, this.explosion_radius,
                    F_AREA, F_NONE)
                if explosion_targets then
                    for i = 1, #explosion_targets do
                        local explosion_target = explosion_targets[i]
                        local d = E:create_entity("damage")
                        d.source_id = this.id
                        d.target_id = explosion_target.id
                        d.value = math.random(b.damage_min, b.damage_max) * b.damage_factor * this.explosion_factor
                        d.damage_type = DAMAGE_MAGICAL_EXPLOSION
                        queue_damage(store, d)
                    end
                end
            end

            break
        end
        if pending_chain and store.tick_ts - start_ts > this.chain_delay then
            local chain_target, _, _ = U.find_nearest_enemy(store, target.pos, 0, this.chain_range, this.vis_flags,
                this.vis_bans, function(e, o)
                    return not table.contains(tower.chain_targets, e.id)
                end)

            if chain_target then
                local chain = E:create_entity(this.template_name)
                local start_offset = target.unit.hit_offset

                chain.pos.x, chain.pos.y = target.pos.x + start_offset.x, target.pos.y + start_offset.y
                chain.bullet.from = V.vclone(chain.pos)

                local end_offset = chain_target.unit.hit_offset

                chain.bullet.to = V.vclone(chain_target.pos)
                chain.bullet.to.x, chain.bullet.to.y = chain.bullet.to.x + end_offset.x,
                    chain.bullet.to.y + end_offset.y
                chain.bullet.target_id = chain_target.id
                chain.bullet.source_id = b.target_id
                chain.bullet.level = b.level
                chain.bullet.damage_factor = b.damage_factor
                chain.tower_ref = tower
                chain.chain_pos = this.chain_pos + 1
                chain.mod_start_ts = start_ts
                chain.bullet.cooldown_factor = b.cooldown_factor
                chain.damage_mult = this.damage_mult
                queue_insert(store, chain)

                this.next_in_chain = chain

                table.insert(tower.chain_targets, chain_target.id, chain_target.id)

                pending_chain = false
                chained_next_ray = true
            else
                this.chain_delay = this.chain_delay + 0.25
            end
        end

        if chained_next_ray and (not this.next_in_chain or this.next_in_chain.render.sprites[1].hidden) then
            pending_chain = true
            chained_next_ray = false
        end

        if this.chain_pos and this.chain_pos > 1 then
            local start_offset = source.unit.hit_offset

            this.pos.x, this.pos.y = source.pos.x + start_offset.x, source.pos.y + start_offset.y
            b.from = V.vclone(this.pos)
        end

        if store.tick_ts - start_ts > ray_duration - fts(7) and this.render.sprites[1].name ~= "fade" then
            U.animation_start(this, "fade", nil, store.tick_ts)
        end

        update_sprite()

        if tower and not store.entities[tower.id] then
            break
        end

        target = store.entities[b.target_id]

        if target and this.chain_pos and this.chain_pos > 1 and
            V.dist2(this.pos.x, this.pos.y, target.pos.x, target.pos.y) > this.chain_range_to_stay *
            this.chain_range_to_stay then
            break
        end

        if target and band(target.vis.bans, this.vis_flags) ~= 0 then
            this.force_stop_ray = true

            break
        end

        coroutine.yield()

        s.hidden = false
        source = store.entities[b.source_id]
    end

    if not target or target.health.dead or this.force_stop_ray or not source then
        S:stop(this.sound_events.insert)
        S:queue(this.sound_events.interrupt)
    end

    if fx then
        queue_remove(store, fx)
    end

    for key, value in pairs(mods_added) do
        if not value.dps or not tower or this.force_stop_ray then
            if store.entities[value.id] then
                queue_remove(store, value)
            end
        end
    end

    for k, v in pairs(tower.chain_targets) do
        if v == b.target_id then
            tower.chain_targets[k] = nil
        end
    end

    if this.next_in_chain then
        this.chain_delay = start_chain_delay

        U.y_wait(store, this.chain_delay + fts(4))

        this.next_in_chain.force_stop_ray = true
    end

    if this.render.sprites[1].name == "fade" then
        U.y_animation_wait(this)
    else
        U.y_animation_play(this, "fade", nil, store.tick_ts)
    end

    this.render.sprites[1].hidden = true

    queue_remove(store, this)
end

scripts.bullet_tower_ray_sheep = {}

function scripts.bullet_tower_ray_sheep.update(this, store)
    local b = this.bullet
    local target
    local fm = this.force_motion

    local function move_step(dest)
        local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
        local dist = V.len(dx, dy)
        local nx, ny = V.mul(fm.max_v, V.normalize(dx, dy))
        local stx, sty = V.sub(nx, ny, fm.v.x, fm.v.y)

        if dist <= 4 * fm.max_v * store.tick_length then
            stx, sty = V.mul(fm.max_a, V.normalize(stx, sty))
        end

        fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step, stx, sty)))
        fm.v.x, fm.v.y = V.trim(fm.max_v, V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y)))
        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
        fm.a.x, fm.a.y = 0, 0

        return dist <= fm.max_v * store.tick_length
    end

    target = store.entities[b.target_id]

    local ps

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.emit = true
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    local iix, iiy = V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y)
    local last_pos = V.vclone(this.pos)

    b.ts = store.tick_ts

    S:queue(this.shoot_sound)

    while true do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
            local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x),
                math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

            if d > b.max_track_distance then
                target = nil
                b.target_id = nil
            else
                b.to.x, b.to.y = this.pred_pos.x + target.unit.hit_offset.x, this.pred_pos.y + target.unit.hit_offset.y
            end
        end

        if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
            local t = store.tick_ts - b.ts

            fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(0, iix, iiy))
        end

        last_pos.x, last_pos.y = this.pos.x, this.pos.y

        if move_step(b.to) then
            break
        end

        coroutine.yield()
    end

    if target and not target.health.dead then
        local sheep_t = this.sheep_t

        if band(target.vis.flags, F_FLYING) ~= 0 then
            sheep_t = this.sheep_flying_t
        end

        local sheep = E:create_entity(sheep_t)

        sheep.pos = V.vclone(target.pos)
        sheep.nav_path.pi = target.nav_path.pi
        sheep.nav_path.spi = target.nav_path.spi
        sheep.nav_path.ni = target.nav_path.ni
        sheep.source_id = b.source_id
        sheep.enemy.gold = target.enemy.gold
        sheep.health.hp_max = target.health.hp_max * this.sheep_hp_mult
        sheep.health.hp = target.health.hp * this.sheep_hp_mult
        sheep.health.patched = true
        queue_insert(store, sheep)

        target.trigger_deselect = true
        target.gold = 0

        queue_remove(store, target)
        S:queue(this.hit_sound)
    end

    if b.hit_fx then
        local fx = E:create_entity(b.hit_fx)

        fx.pos = V.vclone(this.pos)
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    end

    if ps and ps.particle_system.emit then
        ps.particle_system.emit = false
    end

    queue_remove(store, this)
    coroutine.yield()
end

scripts.enemy_tower_ray_sheep = {}

function scripts.enemy_tower_ray_sheep.update(this, store)
    local clicks = 0

    while true do
        if this.health.dead then
            SU.y_enemy_death(store, this)

            return
        end

        if this.ui.clicked then
            this.ui.clicked = nil
            clicks = clicks + 1
        end

        if clicks >= this.clicks_to_destroy then
            this.health.hp = 0

            coroutine.yield()
        elseif this.unit.is_stunned then
            U.animation_start(this, "idle", nil, store.tick_ts, -1)
            coroutine.yield()
        else
            SU.y_enemy_walk_until_blocked(store, this, true, function(store, this)
                return this.ui.clicked
            end)
        end
    end
end

-- 红法 END

-- 观星 BEGIN
scripts.tower_stargazers = {}
function scripts.tower_stargazers.create_star_death(this, store, enemy, factor)
    local mod_star_m = E:get_template("mod_tower_elven_stargazers_star_death").modifier
    local pow_s = this.powers.stars_death
    if pow_s.level > 0 then
        local e_pos = {
            x = enemy.pos.x + enemy.unit.hit_offset.x,
            y = enemy.pos.y + enemy.unit.hit_offset.y
        }
        local targets = U.find_enemies_in_range(store, e_pos, 0, mod_star_m.stars_death_max_range, F_ENEMY, F_NONE)
        if targets then
            local targets_count = #targets
            for i = 1, mod_star_m.stars_death_stars[pow_s.level] do
                local target = targets[km.zmod(i, targets_count)]
                local b = E:create_entity(mod_star_m.bullet)
                b.pos = e_pos
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
                b.bullet.target_id = target.id
                b.bullet.level = pow_s.level
                b.bullet.damage_factor = factor * this.tower.damage_factor
                queue_insert(store, b)
            end
        end
    end
end

function scripts.tower_stargazers.update(this, store, script)
    local last_target_pos
    local a = this.attacks
    local aa = this.attacks.list[1]
    local at = this.attacks.list[2]
    local as = this.attacks.list[3]
    local moon_sid = this.render.moon_sid
    local elf_sid = this.render.elf_sid
    local teleport_sid = this.render.teleport_sid
    local shots = 5
    local pow_t = this.powers.teleport
    local pow_s = this.powers.stars_death
    local mod_star_m = E:get_template("mod_tower_elven_stargazers_star_death").modifier
    local last_ts = store.tick_ts - aa.cooldown
    this.teleport_targets = {}
    a._last_target_pos = a._last_target_pos or v(REF_W, 0)
    aa.ts = store.tick_ts - aa.cooldown + a.attack_delay_on_spawn

    local ray_timing = aa.ray_timing

    local tw = this.tower
    while true do
        local enemy, enemies

        if pow_t.changed then
            pow_t.changed = nil
            at.cooldown = pow_t.cooldown[pow_t.level]
            at.teleport_nodes_back = pow_t.teleport_nodes_back[pow_t.level]

            if pow_t.level == 1 then
                at.ts = store.tick_ts - at.cooldown
            end
        end
        if pow_s.changed then
            pow_s.changed = nil
        end

        SU.towers_swaped(store, this, this.attacks.list)

        if this.tower.blocked then
            -- block empty
        else
            if ready_to_attack(aa, store, tw.cooldown_factor) then
                local enemy, enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, aa.vis_flags,
                    aa.vis_bans)
                if not enemy then
                    aa.ts = aa.ts + fts(10)
                else
                    local shooter_offset_y = aa.bullet_start_offset[1].y
                    local tx, ty = V.sub(enemy.pos.x, enemy.pos.y, this.pos.x, this.pos.y + shooter_offset_y)
                    local t_angle = km.unroll(V.angleTo(tx, ty))

                    last_target_pos = V.vclone(enemy.pos)

                    local start_ts = store.tick_ts

                    U.animation_start(this, "attack_in", nil, store.tick_ts, false, elf_sid)
                    U.y_wait(store, 0.5 * tw.cooldown_factor)
                    U.animation_start(this, "attack_loop", nil, store.tick_ts, true, elf_sid)
                    U.animation_start_group(this, "attack_in", nil, store.tick_ts, 1, "layers")
                    U.y_wait(store, 0.25 * tw.cooldown_factor)
                    U.animation_start_group(this, "atack_loop", nil, store.tick_ts, true, "layers")

                    this.render.sprites[moon_sid].hidden = false

                    U.animation_start(this, "start", nil, store.tick_ts, false, moon_sid)
                    U.y_wait(store, 0.25 * tw.cooldown_factor)
                    U.animation_start(this, "loop", nil, store.tick_ts, true, moon_sid)
                    local _, new_enemies = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, aa.vis_flags,
                        aa.vis_bans)
                    if new_enemies then
                        enemies = new_enemies
                    end
                    for i = 1, shots do
                        enemy = enemies[km.zmod(i, #enemies)]

                        local bullet = E:create_entity(aa.bullet)

                        bullet.bullet.shot_index = i
                        bullet.bullet.damage_factor = this.tower.damage_factor
                        bullet.bullet.source_id = this.id

                        if enemy.health and not enemy.health.dead then
                            bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            bullet.bullet.target_id = enemy.id
                            if pow_s.level > 0 then
                                local m = E:create_entity(as.mod)

                                m.modifier.target_id = enemy.id
                                m.modifier.source_id = this.id
                                m.modifier.damage_factor = tw.damage_factor
                                m.modifier.level = pow_s.level

                                queue_insert(store, m)
                            end
                        else
                            bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            bullet.bullet.target_id = nil
                            -- new: 鞭尸时，也触发星爆
                            scripts.tower_stargazers.create_star_death(this, store, enemy, 1)
                        end

                        local start_offset = aa.bullet_start_offset[1]

                        bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
                        bullet.pos = V.vclone(bullet.bullet.from)
                        bullet.bullet.level = this.tower.level

                        queue_insert(store, bullet)
                        U.y_wait(store, ray_timing * tw.cooldown_factor)

                        enemy = U.find_foremost_enemy(store, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

                        if not enemy then
                            break
                        end
                    end

                    U.animation_start(this, "attack_out", nil, store.tick_ts, false, elf_sid)
                    U.y_wait(store, 0.25 * tw.cooldown_factor)
                    U.animation_start(this, "idle", nil, store.tick_ts, true, elf_sid)
                    U.animation_start_group(this, "attack_out", nil, store.tick_ts, 1, "layers")
                    U.animation_start(this, "end", nil, store.tick_ts, false, moon_sid)
                    U.y_wait(store, 0.25 * tw.cooldown_factor)

                    this.render.sprites[moon_sid].hidden = true

                    U.animation_start_group(this, "idle", nil, store.tick_ts, true, "layers")

                    aa.ts = start_ts
                end
            end
            if ready_to_use_power(pow_t, at, store, tw.cooldown_factor) then
                if not U.has_enemy_in_range(store, tpos(this), 0, a.range, at.vis_flags, at.vis_bans) then
                    at.ts = at.ts + fts(10)
                else
                    local start_ts = store.tick_ts

                    S:queue(aa.sound_cast)
                    U.y_animation_play(this, "attack_in_event_horizon", nil, store.tick_ts, false, elf_sid)

                    this.render.sprites[teleport_sid].hidden = false

                    U.animation_start(this, "idle", nil, store.tick_ts, false, teleport_sid)
                    U.animation_start(this, "attack_loop_event_horizon", nil, store.tick_ts, true, elf_sid)
                    S:queue(aa.sound_teleport_out)
                    U.y_animation_play_group(this, "attack_in", nil, store.tick_ts, 1, "layers")
                    U.animation_start_group(this, "atack_loop", nil, store.tick_ts, true, "layers")

                    local enemy, _ = U.find_foremost_enemy_with_max_coverage(store, tpos(this), 0, a.range, false,
                        at.vis_flags, at.vis_bans, nil, 0, 100)
                    if enemy then
                        enemies = U.find_enemies_in_range(store, enemy.pos, 0, 100, at.vis_flags, at.vis_bans)

                        local place_pi = enemy.nav_path.pi
                        local middle = V.v(enemy.pos.x, enemy.pos.y)

                        local count = at.max_targets[pow_t.level]

                        if enemies then
                            if count > #enemies then
                                count = #enemies
                            end

                            for i = 1, count do
                                local enemy = enemies[i]
                                local m = E:create_entity(at.mod)

                                m.modifier.target_id = enemy.id
                                m.modifier.source_id = this.id

                                queue_insert(store, m)

                                local fx_size

                                if enemy.unit.size == UNIT_SIZE_LARGE then
                                    fx_size = at.enemy_fx_big
                                else
                                    fx_size = at.enemy_fx_small
                                end

                                local fx = E:create_entity(fx_size)

                                fx.pos.x = enemy.pos.x + enemy.unit.mod_offset.x
                                fx.pos.y = enemy.pos.y + enemy.unit.mod_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                                scripts.tower_stargazers.create_star_death(this, store, enemy, 0.25)
                            end

                            local fx = E:create_entity(at.fx)

                            fx.pos.x = middle.x
                            fx.pos.y = middle.y
                            fx.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, fx)
                            U.y_wait(store, 0.2 * tw.cooldown_factor)

                            for i = 1, count do
                                local enemy = enemies[i]
                                if enemy then
                                    local tni = enemy.nav_path.ni - at.teleport_nodes_back - 5

                                    if band(enemy.vis.flags, at.vis_bans) == 0 and band(enemy.vis.bans, at.vis_flags) ==
                                        0 then
                                        local place_ni = tni + math.random(0, 5)

                                        if place_ni < 0 then
                                            place_ni = 1
                                        end
                                        enemy.vis.bans = bor(enemy.vis.bans, F_TELEPORT)
                                        -- enemy._stargazer_bans = U.push_bans(enemy.vis, teleport_bans)

                                        table.insert(this.teleport_targets, {
                                            ni = place_ni,
                                            entity = enemy
                                        })
                                        SU.remove_modifiers(store, enemy)
                                        SU.remove_auras(store, enemy)
                                        U.unblock_all(store, enemy)

                                        if enemy.ui then
                                            enemy.ui.can_click = false
                                        end

                                        if enemy.health_bar then
                                            enemy.health_bar._hidden = enemy.health_bar.hidden
                                            enemy.health_bar.hidden = true
                                        end

                                        U.sprites_hide(enemy, nil, nil, true)
                                    end
                                end
                            end

                            U.y_wait(store, 0.5 * tw.cooldown_factor)
                            queue_insert(store, fx)
                            S:queue(at.sound_teleport_in)
                            U.y_animation_play(this, "attack_out", nil, store.tick_ts, false, elf_sid)
                            U.animation_start(this, "idle", nil, store.tick_ts, true, elf_sid)
                            U.animation_start_group(this, "attack_out", nil, store.tick_ts, 1, "layers")

                            for i = #this.teleport_targets, 1, -1 do
                                local p = this.teleport_targets[i]
                                local enemy = p.entity

                                enemy.nav_path.ni = p.ni
                                enemy.pos = P:node_pos(enemy.nav_path)

                                if enemy.ui then
                                    enemy.ui.can_click = true
                                end

                                if enemy.health_bar then
                                    enemy.health_bar.hidden = enemy.health_bar._hidden
                                end

                                U.sprites_show(enemy, nil, nil, true)
                                -- U.pop_bans(enemy.vis, enemy._stargazer_bans)
                                enemy.vis.bans = U.flag_clear(enemy.vis.bans, F_TELEPORT)
                                -- enemy._stargazer_bans = nil

                                table.remove(this.teleport_targets, i)

                                local fx_size

                                if enemy.unit.size == UNIT_SIZE_LARGE then
                                    fx_size = at.enemy_fx_big
                                else
                                    fx_size = at.enemy_fx_small
                                end

                                local fx = E:create_entity(fx_size)

                                fx.pos.x = enemy.pos.x + enemy.unit.mod_offset.x
                                fx.pos.y = enemy.pos.y + enemy.unit.mod_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                            end

                            this.render.sprites[teleport_sid].hidden = true

                            U.y_animation_wait_group(this, "layers")

                            at.ts = start_ts
                        else
                            U.y_wait(store, 0.5 * tw.cooldown_factor)
                            U.y_animation_play(this, "attack_out", nil, store.tick_ts, false, elf_sid)
                            U.animation_start(this, "idle", nil, store.tick_ts, true, elf_sid)
                            U.animation_start_group(this, "attack_out", nil, store.tick_ts, 1, "layers")
                            U.y_animation_wait_group(this, "layers")
                        end
                    else
                        U.y_wait(store, 0.5 * tw.cooldown_factor)
                        U.y_animation_play(this, "attack_out", nil, store.tick_ts, false, elf_sid)
                        U.animation_start(this, "idle", nil, store.tick_ts, true, elf_sid)
                        U.animation_start_group(this, "attack_out", nil, store.tick_ts, 1, "layers")
                        U.y_animation_wait_group(this, "layers")
                    end
                end
            end
        end

        coroutine.yield()
    end
end

function scripts.tower_stargazers.remove(this, store)
    local at = this.attacks.list[2]
    if this.teleport_targets then
        for i = #this.teleport_targets, 1, -1 do
            local p = this.teleport_targets[i]
            local enemy = p.entity

            enemy.nav_path.ni = p.ni
            enemy.pos = P:node_pos(enemy.nav_path)

            if enemy.ui then
                enemy.ui.can_click = true
            end

            if enemy.health_bar then
                enemy.health_bar.hidden = enemy.health_bar._hidden
            end

            U.sprites_show(enemy, nil, nil, true)
            U.pop_bans(enemy.vis, enemy._stargazer_bans)

            enemy._stargazer_bans = nil

            table.remove(this.teleport_targets, i)

            local fx_size

            if enemy.unit.size == UNIT_SIZE_LARGE then
                fx_size = at.enemy_fx_big
            else
                fx_size = at.enemy_fx_small
            end

            local fx = E:create_entity(fx_size)

            fx.pos.x = enemy.pos.x + enemy.unit.mod_offset.x
            fx.pos.y = enemy.pos.y + enemy.unit.mod_offset.y
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end
    end
    return true
end

scripts.mod_ray_stargazers = {}

function scripts.mod_ray_stargazers.update(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if not target or target.health.dead then
        queue_remove(store, this)

        return
    end

    -- local function apply_damage(value)
    --     local d = E:create_entity("damage")

    --     d.source_id = this.id
    --     d.target_id = target.id
    --     d.value = value * m.damage_factor
    --     d.damage_type = this.damage_type

    --     queue_damage(store, d)
    -- end

    -- local raw_damage = math.random(this.modifier.damage_min, this.modifier.damage_max)

    this.pos = target.pos
    m.ts = store.tick_ts

    -- apply_damage(raw_damage)

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead then
            break
        end

        if this.render and m.use_mod_offset and target.unit.hit_offset then
            for _, s in ipairs(this.render.sprites) do
                s.offset.x, s.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y
            end
        end

        if store.tick_ts - m.ts > m.duration then
            break
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.mod_stargazers_stars_death = {}

function scripts.mod_stargazers_stars_death.update(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]
    local chance = m.stars_death_chance[m.level]
    local radius = m.stars_death_max_range
    local total_stars = m.stars_death_stars[m.level]
    local bullet = m.bullet
    local time = store.tick_ts
    local duration = this.modifier.duration

    if not target or target.health.dead then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    local function shoot_bullet(enemy, level)
        local b = E:create_entity(bullet)

        b.pos.x = this.pos.x
        b.pos.y = this.pos.y
        b.bullet.from = V.vclone(b.pos)
        b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
        b.bullet.target_id = enemy.id
        b.bullet.level = level
        b.bullet.damage_factor = m.damage_factor
        queue_insert(store, b)
    end

    while true do
        if not target or target.health.dead then
            if target and chance > math.random() then
                local targets = U.find_enemies_in_range(store, target.pos, 0, radius, F_ENEMY, F_NONE)

                if targets then
                    for i = 1, total_stars do
                        if targets[i] == nil then
                            break
                        end

                        shoot_bullet(targets[i], m.level)
                    end
                end
            end

            break
        end

        if time + duration < store.tick_ts then
            break
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

-- 观星 END

-- 沙丘哨兵 BEGIN
scripts.tower_sand = {}

function scripts.tower_sand.update(this, store, script)
    local a = this.attacks
    local ba = a.list[1]

    ba.ts = store.tick_ts - ba.cooldown + a.attack_delay_on_spawn

    local ga = a.list[2]
    local bba = a.list[3]
    local shooter_sids = {3, 4}
    local shooter_idx = 1

    if not a._last_target_pos then
        a._last_target_pos = {}

        for i = 1, #shooter_sids do
            a._last_target_pos[i] = v(REF_W, 0)
        end
    end

    local function shoot_animation(attack, shooter_idx, pos)
        local ssid = shooter_sids[shooter_idx]
        local soffset = this.render.sprites[ssid].offset
        local s = this.render.sprites[ssid]
        local an, af = U.animation_name_facing_point(this, attack.animation, pos, ssid, soffset)

        if attack == ga then
            af = not af
        end

        U.animation_start(this, an, af, store.tick_ts, 1, ssid)
    end

    local function shoot_bullet(attack, shooter_idx, enemy, level)
        local ssid = shooter_sids[shooter_idx]
        local shooting_up = this.render.sprites[ssid].name == this.render.sprites[ssid].angles.shoot[1]
        local shooting_right = not this.render.sprites[ssid].flip_x
        local soffset = this.render.sprites[ssid].offset
        local boffset = attack.bullet_start_offset[shooting_up and 1 or 2]
        local b = E:create_entity(attack.bullet)

        if attack == ga then
            b.bullet.damage_min = b.bullet.damage_min_config[this.powers.skill_gold.level]
            b.bullet.damage_max = b.bullet.damage_max_config[this.powers.skill_gold.level]
        end

        b.pos.x = this.pos.x + soffset.x + boffset.x * (shooting_right and 1 or -1)
        b.pos.y = this.pos.y + soffset.y + boffset.y
        b.bullet.from = V.vclone(b.pos)
        b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
        b.bullet.target_id = enemy.id
        b.bullet.source_id = this.id
        b.bullet.level = level
        b.bullet.damage_factor = this.tower.damage_factor
        b.bounces = 0

        queue_insert(store, b)
    end

    local function check_upgrades_purchase()
        for _, pow in pairs(this.powers) do
            if pow.changed then
                pow.changed = nil

                local pa = this.attacks.list[pow.attack_idx]

                pa.cooldown = pow.cooldown[pow.level]
                pa.ts = store.tick_ts - pa.cooldown
            end
        end
    end

    for idx, ssid in ipairs(shooter_sids) do
        local soffset = this.render.sprites[ssid].offset
        local s = this.render.sprites[ssid]
        local an, af = U.animation_name_facing_point(this, "idle", a._last_target_pos[idx], ssid, soffset)

        U.animation_start(this, an, af, store.tick_ts, 1, ssid)
    end
    local tw = this.tower
    while true do
        local at

        if this.tower.blocked then
            coroutine.yield()
        else
            check_upgrades_purchase()
            SU.towers_swaped(store, this, this.attacks.list)

            if bba.cooldown and ready_to_attack(bba, store, tw.cooldown_factor) then
                local _, enemies, pred_pos = U.find_foremost_enemy(store, this.pos, 0, bba.range,
                    bba.shoot_time[1] + fts(20), bba.vis_flags, bba.vis_bans)

                if not enemies or #enemies < bba.min_targets then
                    bba.ts = bba.ts + fts(10)
                else
                    local nearest_nodes = P:nearest_nodes(pred_pos.x, pred_pos.y, {enemies[1].nav_path.pi})

                    if #nearest_nodes == 0 then
                        SU.delay_attack(store, bba, fts(10))
                    else
                        bba.ts = store.tick_ts

                        U.animation_start(this, bba.animation, nil, store.tick_ts, false, this.tower_sid)
                        S:queue(bba.sound)

                        local c = E:create_entity(this.powers.skill_big_blade.controller)

                        c.target_node = nearest_nodes[1]
                        c.tower_ref = this

                        queue_insert(store, c)
                    end
                end
            end

            if ga.cooldown and ready_to_attack(ga, store, tw.cooldown_factor) then
                at = ga
            elseif ready_to_attack(ba, store, tw.cooldown_factor) then
                at = ba
            end

            if at then
                local trigger_enemy, _ = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range, false,
                    at.vis_flags, at.vis_bans)

                if not trigger_enemy then
                    at.ts = at.ts + fts(10)
                else
                    at.ts = store.tick_ts
                    shooter_idx = km.zmod(shooter_idx + 1, #shooter_sids)

                    shoot_animation(at, shooter_idx, trigger_enemy.pos)
                    S:queue(at.sound)

                    while store.tick_ts - at.ts < at.shoot_time do
                        check_upgrades_purchase()
                        coroutine.yield()
                    end

                    local enemy, _ = U.find_foremost_enemy_with_flying_preference(store, tpos(this), 0, a.range, false, at.vis_flags,
                        at.vis_bans)

                    enemy = enemy or trigger_enemy

                    shoot_bullet(at, shooter_idx, enemy, 0)

                    a._last_target_pos[shooter_idx].x, a._last_target_pos[shooter_idx].y = enemy.pos.x, enemy.pos.y

                    U.y_animation_wait(this, shooter_sids[shooter_idx])
                end
            end

            if store.tick_ts - ba.ts > this.tower.long_idle_cooldown then
                for _, sid in pairs(shooter_sids) do
                    local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

                    U.animation_start(this, an, af, store.tick_ts, -1, sid)
                end
            end
        end

        coroutine.yield()
    end
end

scripts.bullet_tower_sand = {}

function scripts.bullet_tower_sand.update(this, store)
    local b = this.bullet
    local target, ps

    this.bounces = 0

    local already_hit = {}
    local tower = store.entities[b.source_id]
    local skill_level

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    if b.damage_min_config then
        skill_level = tower.powers.skill_gold.level
        b.damage_min = b.damage_min_config[skill_level]
        b.damage_max = b.damage_max_config[skill_level]
    end

    ::label_981_0::

    while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > b.fixed_speed * store.tick_length *
        (b.fixed_speed * store.tick_length) do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead then
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
        end

        b.speed.x, b.speed.y = V.mul(b.fixed_speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
        this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

        coroutine.yield()
    end

    local will_kill

    if target and not target.health.dead then
        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)
        local mods
        if b.mod then
            mods = type(b.mod) == "table" and b.mod or {b.mod}
        elseif b.mods then
            mods = b.mods
        end

        if mods then
            for _, mod_name in ipairs(mods) do
                local m = E:create_entity(mod_name)
                m.modifier.source_id = this.id
                m.modifier.target_id = target.id
                m.modifier.source_damage = d
                m.modifier.damage_factor = b.damage_factor
                m.modifier.level = b.level
                queue_insert(store, m)
            end
        end
        will_kill = U.predict_damage(target, d) >= target.health.hp

        table.insert(already_hit, target.id)
        S:queue(this.sound_hit)
    end

    if this.gold_chance and will_kill then
        local stole_gold = math.random(0, 100) <= this.gold_chance * 100

        if stole_gold then
            local sfx = E:create_entity(b.hit_fx_coins)

            sfx.pos = V.vclone(b.to)
            sfx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, sfx)

            local gold_pos = V.v(sfx.pos.x, sfx.pos.y)

            signal.emit("got-gold", gold_pos, this.gold_extra[skill_level])
        end
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos = V.vclone(b.to)
        sfx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, sfx)
    end

    S:queue(this.sound)

    if this.bounces < this.max_bounces then
        local targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans,
            function(v)
                return not table.contains(already_hit, v.id)
            end)

        if not targets then
            if target and not target.health.dead then
                already_hit = {target.id}
            else
                already_hit = {}
            end

            targets = U.find_enemies_in_range(store, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans,
                function(v)
                    return not table.contains(already_hit, v.id)
                end)
        end

        if targets then
            table.sort(targets, function(e1, e2)
                return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) <
                           V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
            end)

            local target = targets[1]

            this.bounces = this.bounces + 1
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            b.target_id = target.id
            b.fixed_speed = b.fixed_speed * this.bounce_speed_mult
            b.damage_min = math.floor(b.damage_min * this.bounce_damage_mult)

            if b.damage_min < 1 then
                b.damage_min = 1
            end

            b.damage_max = math.floor(b.damage_max * this.bounce_damage_mult)

            if b.damage_max < 1 then
                b.damage_max = 1
            end

            goto label_981_0
        end
    end

    queue_remove(store, this)
end

scripts.controller_tower_sand_lvl4_skill_big_blade = {}

function scripts.controller_tower_sand_lvl4_skill_big_blade.update(this, store)
    local bba = this.tower_ref.attacks.list[3]

    local function shoot_big_blade(idx, dest)
        local boffset = bba.bullet_start_offset[idx]
        local b = E:create_entity(bba.bullet)

        b.pos.x = this.tower_ref.pos.x + boffset.x
        b.pos.y = this.tower_ref.pos.y + boffset.y
        b.origin_pos = V.vclone(b.pos)
        b.dest_pos = V.vclone(dest)
        b.aura.source_id = this.tower_ref.id
        b.aura.level = this.tower_ref.powers.skill_big_blade.level
        b.aura.damage_factor = this.tower_ref.tower.damage_factor
        b.aura.damage_min = this.tower_ref.powers.skill_big_blade.damage_min[b.aura.level]
        b.aura.damage_max = this.tower_ref.powers.skill_big_blade.damage_max[b.aura.level]
        b.aura.duration = this.tower_ref.powers.skill_big_blade.duration[b.aura.level]

        queue_insert(store, b)
    end

    local pi, spi, ni = unpack(this.target_node)
    local pos1 = P:node_pos(pi, 2, ni + 3)
    local pos2 = P:node_pos(pi, 3, ni - 3)

    U.y_wait(store, bba.shoot_time[1])
    shoot_big_blade(1, pos1)
    U.y_wait(store, bba.shoot_time[2] - bba.shoot_time[1])
    shoot_big_blade(2, pos2)
    queue_remove(store, this)
end

scripts.aura_tower_sand_skill_big_blade = {}

function scripts.aura_tower_sand_skill_big_blade.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0
    local reached_dest = false
    local source_tower = store.entities[this.aura.source_id]

    this.speed = V.vv(0)
    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    local ps = E:create_entity(this.particles_name)

    ps.particle_system.track_id = this.id

    queue_insert(store, ps)
    U.animation_start(this, "idle", nil, store.tick_ts, true)

    while true do
        local d = this.dest_pos
        local s = this.speed
        local p = this.pos

        if reached_dest then
            -- block empty
        elseif V.dist2(p.x, p.y, d.x, d.y) > this.fixed_speed * store.tick_length *
            (this.fixed_speed * store.tick_length) then
            s.x, s.y = V.mul(this.fixed_speed, V.normalize(d.x - p.x, d.y - p.y))
            p.x, p.y = p.x + s.x * store.tick_length, p.y + s.y * store.tick_length
        else
            reached_dest = true
            this.render.sprites[1].prefix = "tower_sand_lvl4_skill_2_decal"

            U.y_animation_play(this, "in", nil, store.tick_ts)
            U.animation_start(this, "loop", nil, store.tick_ts, true)

            this.render.sprites[1].z = Z_DECALS
            ps.particle_system.emit = false
        end

        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration or not source_tower then
            break
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags,
                this.aura.vis_bans)

            if targets then
                for i, target in ipairs(targets) do
                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = target.id

                    local dmin, dmax = this.aura.damage_min, this.aura.damage_max

                    d.value = math.random(dmin, dmax) * this.aura.damage_factor
                    d.damage_type = this.aura.damage_type
                    d.track_damage = this.aura.track_damage
                    d.xp_dest_id = this.aura.xp_dest_id
                    d.xp_gain_factor = this.aura.xp_gain_factor

                    queue_damage(store, d)

                    local fx = E:create_entity(this.hit_fx)

                    fx.pos = V.vclone(target.pos)
                    fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)

                    local mods = this.aura.mods or {this.aura.mod}

                    for _, mod_name in pairs(mods) do
                        local new_mod = E:create_entity(mod_name)

                        new_mod.modifier.level = this.aura.level
                        new_mod.modifier.target_id = target.id
                        new_mod.modifier.source_id = this.id

                        if this.aura.hide_source_fx and target.id == this.aura.source_id then
                            new_mod.render = nil
                        end

                        queue_insert(store, new_mod)

                        victims_count = victims_count + 1
                    end
                end
            end
        end

        coroutine.yield()
    end

    signal.emit("aura-apply-mod-victims", this, victims_count)

    this.render.sprites[1].prefix = "tower_sand_lvl4_skill_2_decal"

    U.y_animation_play(this, "out", nil, store.tick_ts)
    queue_remove(store, this)
end

-- 沙丘哨兵 END
return scripts
