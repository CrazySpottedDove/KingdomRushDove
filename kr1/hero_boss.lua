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
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"
local a
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
local function enemy_do_counter_attack(store, this, target)
    local ma = this.dodge.counter_attack
    ma.ts = store.tick_ts
    this.health.ignore_damage = true
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
                    this.health.ignore_damage = false
                    return false
                end

                coroutine.yield()
            end

            dodged = SU.unit_dodges(store, target, false, ma, this)
        end

        while hit_time > store.tick_ts - ma.ts do
            if this.health.dead or this.unit.is_stunned and not ma.ignore_stun then
                this.health.ignore_damage = false
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
            this.health.ignore_damage = false
            return false
        end
        coroutine.yield()
    end
    this.health.ignore_damage = false
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
    end
    if old_t.ranged then
        t.ranged = table.deepclone(old_t.ranged)
    end
    if old_t.timed_attacks then
        t.timed_attacks = table.deepclone(old_t.timed_attacks)
    end
    if old_t.dodge then
        t.dodge = table.deepclone(old_t.dodge)
    end
    t.vis.flags = bor(t.vis.flags, U.flag_clear(old_t.vis.flags ,bor(F_HERO, F_FRIEND)))
    t.vis.bans = bor(t.vis.bans, old_t.vis.bans)
    t.health.hp_max = old_t.hero.level_stats.hp_max[10]
    t.health.armor = old_t.hero.level_stats.armor[10]
    if old_t.hero.level_stats.magic_armor then
        t.health.magic_armor = old_t.hero.level_stats.magic_armor[10]
    end
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
                    ca.damage_max = math.max(la.damage_max * (ca.reflected_damage_factor) , this.melee.attacks[1].damage_max) * this.unit.damage_factor
                    ca.damage_min = math.min(la.damage_min * (ca.reflected_damage_factor), this.melee.attacks[1].damage_min) * this.unit.damage_factor
                end
                goto while_end
            end

            if ready_to_attack(courage, store) and this.health.hp_max > this.health.hp and this.enemy.can_do_magic then
                local entities
                if store.enemies then
                    entities = store.enemies
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

-- tt = RT("eb_gerald", "hero_boss")
-- AC(tt, "melee", "timed_attacks", "dodge")
-- anchor_y = 0.12
-- anchor_x = 0.5
-- image_y = 110
-- image_x = 92
-- tt.health.hp_max = 625
-- tt.health.armor = 0.7
-- tt.motion.max_speed = 3 * FPS
-- a = tt.melee.attacks[1]
-- a.cooldown = 1
-- a.hit_time = fts(5)
-- a.sound = "MeleeSword"
-- a.shared_cooldown = true
-- a.damage_type = DAMAGE_PHYSICAL
-- a.damage_max = 50
-- a.damage_min = 29
-- tt.timed_attacks.list[1] = E:clone_c("mod_attack")
-- a = tt.timed_attacks.list[1]
-- a.animation = "courage"
-- a.cooldown = 6.5 + fts(55)
-- a.mod = "mod_eb_gerald_courage"
-- a.vis_flags = F_MOD
-- a.range = 120
-- a.shoot_time = fts(17)
-- a.sound = "HeroPaladinValor"
-- a.sound_args = {
--     delay = fts(3)
-- }
-- a = tt.dodge
-- a.animation = "counter"
-- a.chance = 0.75
-- a.time_before_hit = fts(4)
-- a.counter_attack = E:clone_c("melee_attack")
-- a = a.counter_attack
-- a.animation = "counter"
-- a.cooldown = 1
-- a.damage_type = DAMAGE_TRUE
-- a.reflected_damage_factor = 2
-- a.hit_time = fts(5)
-- a.sound = "HeroPaladinDeflect"
-- tt.enemy.melee_slot = v(10, 0)
-- tt.render.sprites[1].anchor = v(0.5, 0.12)
-- tt.render.sprites[1].prefix = "hero_gerald"
-- tt.health_bar.offset = v(0, 36)
-- tt.info.hero_portrait = IS_PHONE_OR_TABLET and "hero_portraits_0002" or "heroPortrait_portraits_0002"
-- tt.info.i18n_key = "HERO_PALADIN"
-- tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0002" or "info_portraits_hero_0005"
-- tt.info.fn = scripts.enemy_basic.get_info
-- tt.unit.marker_offset = v(0, 0)
-- tt.unit.mod_offset = v(0, 20)
-- tt.melee.cooldown = 1
-- tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
-- a = tt.melee.attacks[2]
-- a.animation = "attack2"
-- a.chance = 0.5
-- tt.main_script.update = function(this, store)
--     this.health_bar.hidden = false
--     local courage = this.timed_attacks.list[1]
--     while true do
--         if this.health.dead then
--             SU.y_enemy_death(store, this)
--             return
--         end
--         if this.unit.is_stunned then
--             SU.y_enemy_stun(store, this)
--         else
--             if this.dodge.active then
--                 this.dodge.active = false
--                 this.dodge.counter_attack_pending = true
--                 local la = this.dodge.last_attack
--                 local ca = this.dodge.counter_attack

--                 if la then
--                     ca.damage_max = la.damage_max * (ca.reflected_damage_factor) * this.unit.damage_factor
--                     ca.damage_min = la.damage_min * (ca.reflected_damage_factor) * this.unit.damage_factor
--                 end
--                 goto while_end
--             end

--             if ready_to_attack(courage, store) and this.health.hp_max > this.health.hp and this.enemy.can_do_magic then
--                 local entities
--                 if store.enemies then
--                     entities = store.enemies
--                 else
--                     entities = store.entities
--                 end
--                 local targets = U.find_enemies_in_range(entities, this.pos, 0, courage.range, courage.vis_flags, courage.vis_bans,
--                     function(v)
--                         return not U.has_modifier_in_list(store, v, {courage.mod})
--                     end)

--                 if not targets then
--                     SU.delay_attack(store, courage, 0.5)
--                 else
--                     local start_ts = store.tick_ts
--                     S:queue(courage.sound)
--                     U.animation_start(this, courage.animation, nil, store.tick_ts)
--                     if y_enemy_wait(store, this, courage.shoot_time) then
--                         goto while_end
--                     end
--                     courage.ts = start_ts
--                     for _, e in pairs(targets) do
--                         local mod = E:create_entity(courage.mod)
--                         mod.modifier.target_id = e.id
--                         mod.modifier.source_id = this.id
--                         queue_insert(store, mod)
--                     end
--                     while not U.animation_finished(this) do
--                         if this.health.dead or this.unit.is_stunned then
--                             break
--                         end
--                         coroutine.yield()
--                     end
--                     goto while_end
--                 end
--             end
--             local cont, blocker, ranged = SU.y_enemy_walk_until_blocked(store, this, false, function()
--                 return ready_to_attack(courage, store) and this.health.hp_max > this.health.hp and this.enemy.can_do_magic
--             end)
--             if cont then
--                 if blocker then
--                     if not SU.y_wait_for_blocker(store, this, blocker) then
--                         goto while_end
--                     end
--                     while SU.can_melee_blocker(store, this, blocker) do
--                         if this.dodge.counter_attack_pending and ready_to_attack(this.dodge.counter_attack, store) then
--                             this.dodge.counter_attack_pending = false
--                             this.melee.last_attack = {
--                                 target_id = blocker.id,
--                                 attack = this.dodge.counter_attack
--                             }
--                             local target = store.entities[blocker.id]
--                             enemy_do_counter_attack(store, this, target)
--                         end
--                         if not SU.y_enemy_melee_attacks(store, this, blocker) then
--                             goto while_end
--                         end
--                         coroutine.yield()
--                     end
--                 end
--             end
--         end
--         ::while_end::
--         coroutine.yield()
--     end
-- end

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
    local heal = target.health.hp_max * buff.hp
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

-- -- boss:alleria
-- tt = RT("eb_alleria", "hero_boss")
-- AC(tt, "melee", "ranged")
-- anchor_y = 0.14
-- anchor_x = 0.5
-- image_y = 76
-- image_x = 60
-- tt.health.hp_max = 4500
-- tt.info.i18n_key = "HERO_ARCHER"
-- tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0004" or "info_portraits_hero_0001"
-- tt.sound_events.death = "HeroArcherDeath"
-- tt.sound_events.insert = "HeroArcherTaunt"
-- tt.main_script.insert = scripts.enemy_basic.insert
-- tt.motion.max_speed = 2 * FPS
-- tt.render.sprites[1].anchor = v(0.5, 0.14)
-- tt.render.sprites[1].prefix = "hero_alleria"
-- tt.enemy.melee_slot_offset = v(4, 0)
-- tt.unit.marker_offset = v(0, 0)
-- tt.unit.mod_offset = v(0, 15)
-- tt.melee.attacks[1].cooldown = 1
-- tt.melee.attacks[1].hit_time = fts(8)
-- tt.melee.attacks[1].sound = "MeleeSword"
-- tt.melee.attacks[1].damage_max = 170
-- tt.melee.attacks[1].damage_min = 105
-- tt.ranged.range_while_blocking = true
-- tt.ranged.attacks[1] = E:clone_c("bullet_attack")
-- tt.ranged.attacks[1].bullet = "arrow_hero_boss_alleria"
-- tt.ranged.attacks[1].bullet_start_offset = {v(0, 12)}
-- tt.ranged.attacks[1].max_range = 185
-- tt.ranged.attacks[1].min_range = 40
-- tt.ranged.attacks[1].shoot_time = fts(5)
-- tt.ranged.attacks[1].cooldown = 0.4
-- -- tt.ranged.attacks[2] = E:clone_c("bullet_attack")
-- -- tt.ranged.attacks[2].cooldown = 3 + fts(29)
-- -- tt.ranged.attacks[2].bullet = "arrow_multishot_hero_boss_alleria"
-- -- tt.ranged.attacks[2].bullet_start_offset = {v(0, 12)}
-- -- tt.ranged.attacks[2].max_range = 200
-- -- tt.ranged.attacks[2].min_range = 40
-- -- tt.ranged.attacks[2].node_prediction = fts(10)
-- -- tt.ranged.attacks[2].shoot_time = fts(12)
-- -- tt.ranged.attacks[2].sound = "HeroArcherShoot"
-- -- tt.ranged.attacks[2].multi_num = 3

-- tt = RT("arrow_hero_boss_alleria", "arrow")
-- tt.bullet.flight_time = fts(15)
-- tt.bullet.damage_max = 250
-- tt.bullet.damage_min = 50

-- -- tt = RT("arrow_multishot_hero_boss_alleria", "arrow")
-- -- tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
-- -- tt.bullet.damage_min = 75
-- -- tt.bullet.damage_max = 250
-- -- tt.bullet.damage_type = DAMAGE_TRUE
-- -- tt.bullet.prediction_error = false
-- -- tt.render.sprites[1].name = "hero_archer_arrow"
-- -- tt.bullet.flight_time = fts(5)

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
-- tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0009" or "info_portraits_hero_0009"
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

