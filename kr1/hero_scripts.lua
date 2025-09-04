require("klua.table")
require("i18n")
local scripts = require("scripts")
local AC = require("achievements")
local log = require("klua.log"):new("hero_scripts")
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
local v = V.v
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
    table.insert(store.damage_queue, damage)
end

local function apply_ultimate(this, store, target, animation_name)
    if animation_name then
        U.y_animation_play(this, animation_name, nil, store.tick_ts, 1)
    end
    S:queue(this.sound_events.change_rally_point)
    local e = E:create_entity(this.hero.skills.ultimate.controller_name)
    e.pos.x, e.pos.y = target.pos.x, target.pos.y
    e.damage_factor = this.unit.damage_factor
    e.level = this.hero.skills.ultimate.level
    queue_insert(store, e)
    this.ultimate.ts = store.tick_ts
    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
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

-- require("game_scripts_utils")
local function upgrade_skill(this, skill_name, upgrade_func)
    local s = this.hero.skills[skill_name]
    local sl = s.xp_level_steps[this.hero.level]
    if sl then
        s.level = sl
        upgrade_func(this, s)
    end
end

--- 判断技能/攻击可用
---@param skill_attack table 攻击或技能
---@param store table game.store
---@return bool
local function ready_to_use_skill(skill_attack, store)
    return (not skill_attack.disabled) and (store.tick_ts - skill_attack.ts > skill_attack.cooldown)
end
local function update_regen(this)
    this.regen.health = math.ceil(this.health.hp_max * GS.soldier_regen_factor)
end
local function inc_armor_by_skill(this, amount)
    this.health.raw_armor = this.health.raw_armor + amount
    this.health.armor = km.clamp(0, 1, this.health.armor + amount)
end
local function inc_magic_armor_by_skill(this, amount)
    this.health.raw_magic_armor = this.health.raw_magic_armor + amount
    this.health.magic_armor = km.clamp(0, 1, this.health.magic_armor + amount)
end
--- 升级基础属性
---@param this table 实体
---@return 英雄等级 hl, 英雄等级属性表 ls
local function level_up_basic(this)
    local hl = this.hero.level
    local ls = this.hero.level_stats
    this.health.hp_max = ls.hp_max[hl]
    update_regen(this)
    this.health.raw_armor = ls.armor[hl]
    SU.update_armor(this)
    if (ls.magic_armor) then
        this.health.raw_magic_armor = ls.magic_armor[hl]
        SU.update_magic_armor(this)
    end
    return hl, ls
end

local function find_target_at_critical_moment(this, store, range, ignore_bigguy, require_foremost, vis_bans)
    local target = nil
    local _, targets = U.find_foremost_enemy(store, this.pos, 0, range, 0, F_RANGED, vis_bans or 0)
    local num = 0

    if targets then
        num = #targets
        if not ignore_bigguy then
            for _, t in pairs(targets) do
                if t.health and t.health.hp > BIG_ENEMY_HP then
                    return t, num
                end
            end
        end
        if #targets > MANY_ENEMY_COUNT then
            if require_foremost then
                target = targets[1]
            else
                target = targets[math.random(1, #targets)]
            end
        end
    end
    return target, num
end

local function valid_land_node_nearby(pos)
    return not GR:cell_is(pos.x, pos.y, TERRAIN_FAERIE) and P:valid_node_nearby(pos.x, pos.y, 1.4285714285714286) and
               not GR:cell_is(pos.x, pos.y, TERRAIN_WATER)
end

local function valid_twister_node_nearby(pos)
    return P:valid_node_nearby(pos.x, pos.y, nil, NF_TWISTER) and
               GR:cell_is_only(pos.x, pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
end

local function valid_rally_node_nearby(pos)
    return GR:cell_is_only(pos.x, pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) and
               P:valid_node_nearby(pos.x, pos.y, nil, NF_RALLY)
end

-- 杰拉尔德
scripts.hero_gerald = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
        upgrade_skill(this, "block_counter", function(this, s)
            this.dodge.chance = this.dodge.chance_base + this.dodge.chance_inc * s.level
        end)
        upgrade_skill(this, "courage", function(this, s)
            this.timed_attacks.list[1].disabled = nil
        end)
        upgrade_skill(this, "paladin", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local e = E:get_template(a.entity)
            e.health.hp_max = s.hp_max[s.level]
            a = e.melee.attacks[1]
            a.damage_min = s.melee_damage_min[s.level]
            a.damage_max = s.melee_damage_max[s.level]
            a = e.melee.attacks[2]
            a.damage_min = s.melee_damage_min[s.level]
            a.damage_max = s.melee_damage_max[s.level]
            e.motion.max_speed = s.max_speed[s.level]
        end)
        this.health.hp = this.health.hp_max
    end,

    fn_can_dodge = function(store, this, ranged_attack, attack, source)
        if (source and source.vis and band(source.vis.flags, F_BOSS) ~= 0) and math.random() >
            this.dodge.low_chance_factor then
            return false
        end
        return true
    end,

    update = function(this, store)
        local h = this.health
        local he = this.hero
        local courage = this.timed_attacks.list[1]
        local paladin = this.timed_attacks.list[2]
        local skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                skill = this.hero.skills.block_counter

                if skill.level > 0 and this.dodge and this.dodge.active then
                    this.dodge.active = false
                    this.dodge.counter_attack_pending = true

                    local la = this.dodge.last_attack
                    local ca = this.dodge.counter_attack

                    if la then
                        ca.damage_max = la.damage_max *
                                            (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level) *
                                            this.unit.damage_factor
                        ca.damage_min = la.damage_min *
                                            (ca.reflected_damage_factor + ca.reflected_damage_factor_inc * skill.level) *
                                            this.unit.damage_factor
                    end

                    SU.hero_gain_xp_from_skill(this, skill)

                    goto label_39_0
                end

                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_39_1
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                skill = this.hero.skills.paladin
                if ready_to_use_skill(paladin, store) then
                    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)
                    if #nodes < 1 then
                        SU.delay_attack(store, paladin, 0.4)
                    else
                        U.animation_start(this, paladin.animation, nil, store.tick_ts)
                        S:queue(paladin.sound)
                        SU.hero_gain_xp_from_skill(this, skill)
                        paladin.ts = store.tick_ts
                        local pi, spi, ni = unpack(nodes[1])
                        local new_soldier = E:create_entity(paladin.entity)
                        local e_spi, e_ni = math.random(1, 3), ni
                        new_soldier.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
                        new_soldier.nav_rally.pos = V.vclone(new_soldier.nav_rally.center)
                        new_soldier.pos = V.vclone(new_soldier.nav_rally.center)
                        new_soldier.owner = this
                        queue_insert(store, new_soldier)
                    end
                    SU.y_hero_animation_wait(this)
                    goto label_39_1
                end

                skill = this.hero.skills.courage
                if ready_to_use_skill(courage, store) then
                    local triggers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, courage.range,
                        courage.vis_flags, courage.vis_bans)

                    if not triggers or #triggers < courage.min_count then
                        SU.delay_attack(store, courage, 0.13333333333333333)
                    else
                        local start_ts = store.tick_ts
                        S:queue(courage.sound)
                        U.animation_start(this, courage.animation, nil, store.tick_ts)
                        if SU.y_hero_wait(store, this, courage.shoot_time) then
                            -- block empty
                        else
                            local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, courage.range,
                                courage.vis_flags, courage.vis_bans)
                            if not targets then
                                -- block empty
                            else
                                courage.ts = start_ts
                                SU.hero_gain_xp_from_skill(this, skill)
                                for _, e in pairs(targets) do
                                    local mod = E:create_entity(courage.mod)
                                    mod.modifier.target_id = e.id
                                    mod.modifier.source_id = this.id
                                    mod.modifier.level = skill.level
                                    queue_insert(store, mod)
                                end
                                SU.y_hero_animation_wait(this)
                                goto label_39_1
                            end
                        end
                    end
                end

                ::label_39_0::

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_39_1::
            coroutine.yield()
        end
    end
}
-- 艾莉瑞亚-野猫
scripts.soldier_alleria_wildcat = {
    level_up = function(this, store, skill)
        local hp_factor = GS.difficulty_soldier_hp_max_factor[store.level_difficulty]
        this.health.hp_max = skill.hp_base + skill.hp_inc * skill.level * hp_factor
        this.health.hp = this.health.hp_max
        local at = this.melee.attacks[1]
        at.damage_max = skill.damage_max_base + skill.damage_inc * skill.level
        at.damage_min = skill.damage_min_base + skill.damage_inc * skill.level
    end,
    get_info = function(this)
        local min, max = this.melee.attacks[1].damage_min * this.unit.damage_factor,
            this.melee.attacks[1].damage_max * this.unit.damage_factor
        return {
            type = STATS_TYPE_SOLDIER,
            hp = this.health.hp,
            hp_max = this.health.hp_max,
            damage_min = min,
            damage_max = max,
            armor = this.health.armor,
            respawn = this.owner.timed_attacks.list[1].cooldown
        }
    end,
    insert = function(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        return true
    end,
    update = function(this, store)
        local brk, sta
        U.y_animation_play(this, "spawn", nil, store.tick_ts)

        while true do
            if this.health.dead then
                this.owner.timed_attacks.list[1].pet = nil
                this.owner.timed_attacks.list[1].ts = store.tick_ts
                SU.y_soldier_death(store, this)
                return
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos,
                        this.nav_grid.valid_terrains)

                    if SU.y_hero_new_rally(store, this) then
                        goto label_35_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    goto label_35_0
                end

                if SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_35_0::
            coroutine.yield()
        end
    end
}
-- 艾莉瑞亚-分裂箭
scripts.arrow_multishot_hero_alleria = {
    insert = function(this, store)
        if this.extra_arrows > 0 then
            local _, targets = U.find_foremost_enemy(store, this.bullet.to, 0, this.extra_arrows_range, nil,
                F_RANGED, F_NONE)

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
}
-- 艾莉瑞亚
scripts.hero_alleria = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        local bt = E:get_template(this.ranged.attacks[1].bullet)
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "multishot", function(this, s)
            local a = this.ranged.attacks[2]
            a.disabled = nil
            a.cooldown = s.cooldown[s.level]
            local b = E:get_template(a.bullet)
            b.extra_arrows = s.count_base + s.count_inc * s.level
        end)

        upgrade_skill(this, "callofwild", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            if a.pet then
                a.pet.level = s.level
                a.pet.fn_level_up(a.pet, store, s)
            end
        end)
        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function get_wildcat_pos()
            local positions = P:get_all_valid_pos(this.nav_rally.pos.x, this.nav_rally.pos.y, a.min_range, a.max_range,
                TERRAIN_LAND, nil, NF_RALLY)

            return positions[1]
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        this.health_bar.hidden = false
        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    a = this.timed_attacks.list[1]
                    if a.pet then
                        local pos = get_wildcat_pos()
                        if pos then
                            a.pet.nav_rally.center = pos
                            a.pet.nav_rally.pos = pos
                            a.pet.nav_rally.new = true
                        end
                    end
                    if SU.y_hero_new_rally(store, this) then
                        goto label_43_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.callofwild
                if ready_to_use_skill(a, store) then
                    if a.pet then
                        SU.delay_attack(store, a, 0.25)
                    else
                        local spawn_pos = get_wildcat_pos()
                        if not spawn_pos then
                            SU.delay_attack(store, a, 0.25)
                        else
                            S:queue(a.sound)
                            this.health.immune_to = F_ALL
                            U.animation_start(this, a.animation, nil, store.tick_ts)
                            U.y_wait(store, a.spawn_time)
                            local e = E:create_entity(a.entity)
                            e.pos = V.vclone(spawn_pos)
                            e.nav_rally.pos = V.vclone(spawn_pos)
                            e.nav_rally.center = V.vclone(spawn_pos)
                            e.render.sprites[1].flip_x = math.random() < 0.5
                            e.owner = this
                            e.fn_level_up(e, store, skill)
                            queue_insert(store, e)
                            a.pet = e
                            U.y_animation_wait(this)
                            a.ts = store.tick_ts
                            this.health.immune_to = 0
                            SU.hero_gain_xp_from_skill(this, skill)
                            goto label_43_0
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_43_0::
            coroutine.yield()
        end
    end
}
-- 幻影-攻击影子
scripts.mirage_shadow = {
    insert = function(this, store, script)
        local b = this.bullet
        local target = store.entities[b.target_id]
        if not target then
            return false
        end
        b.to = V.vclone(target.pos)
        return true
    end,
    update = function(this, store, script)
        local b = this.bullet
        local target = store.entities[b.target_id]
        local start_ts = store.tick_ts
        local mspeed = U.frandom(b.min_speed, b.max_speed)
        while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
            target = store.entities[b.target_id]

            if not target or target.health.dead then
                U.animation_start(this, "death", nil, store.tick_ts)
                S:queue(this.sound_events.death)
                local smoke = E:create_entity("fx_mirage_smoke")
                smoke.pos = V.vclone(this.pos)
                smoke.render.sprites[1].ts = store.tick_ts
                queue_insert(store, smoke)
                U.y_animation_wait(this)
                queue_remove(store, this)
                return
            end

            b.to.x, b.to.y = target.pos.x, target.pos.y
            b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
            this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                this.pos.y + b.speed.y * store.tick_length

            if V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < mspeed * fts(8) then
                if this.render.sprites[1].name ~= "attack" then
                    local an, af = U.animation_name_facing_point(this, "attack", b.to)

                    U.animation_start(this, an, af, store.tick_ts, false)
                end
            else
                local an, af = U.animation_name_facing_point(this, "running", b.to)
                U.animation_start(this, an, af, store.tick_ts, true)
            end
            coroutine.yield()
        end

        S:queue(this.sound_events.hit)

        if target and not target.health.dead then
            local d = SU.create_bullet_damage(b, target.id, this.id)
            queue_damage(store, d)
        end

        if b.hit_fx and target.unit.blood_color then
            local fx = E:create_entity(b.hit_fx)
            fx.pos = V.vclone(target.pos)

            if target.unit.hit_offset then
                fx.pos.x, fx.pos.y = fx.pos.x + target.unit.hit_offset.x, fx.pos.y + target.unit.hit_offset.y
            end

            fx.render.sprites[1].ts = store.tick_ts
            fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

            if fx.use_blood_color then
                fx.render.sprites[1].name = target.unit.blood_color
            end

            queue_insert(store, fx)
        end

        queue_remove(store, this)
    end
}
-- 幻影-闪避影子
scripts.soldier_mirage_illusion = {
    insert = function(this, store, script)
        this.lifespan.ts = store.tick_ts
        this.melee.order = U.attack_order(this.melee.attacks)
        return true
    end,
    update = function(this, store, script)
        local attack = this.melee.attacks[1]
        U.y_wait(store, attack.cooldown - fts(23))

        while true do
            if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
                this.health.hp = 0

                U.unblock_target(store, this)
                U.animation_start(this, "idle", nil, store.tick_ts)
                S:queue(this.sound_events.death)

                local smoke = E:create_entity("fx_mirage_smoke")
                smoke.pos = V.vclone(this.pos)
                smoke.render.sprites[1].ts = store.tick_ts

                queue_insert(store, smoke)

                local enemies = U.find_enemies_in_range(store, this.pos, 0, 20, F_AREA, 0)
                if enemies then
                    for _, e in pairs(enemies) do
                        if e.health and not e.health.dead then
                            local d = SU.create_attack_damage(this.melee.attacks[1], e.id, this)
                            queue_damage(store, d)
                        end
                    end
                end
                U.y_wait(store, fts(4))
                queue_remove(store, this)

                return
            end

            SU.y_soldier_melee_block_and_attacks(store, this)
            coroutine.yield()
        end
    end
}
-- 幻影
scripts.hero_mirage = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "precision", function(this, s)
            this.damage_buff = this.damage_buff + s.extra_buff[s.level]
        end)

        upgrade_skill(this, "shadowdodge", function(this, s)
            this.dodge.chance = s.dodge_chance[s.level]
            this.reward_shadowdance = s.reward_shadowdance[s.level]
            this.reward_lethalstrike = s.reward_lethalstrike[s.level]
            local e = E:get_template("soldier_mirage_illusion")
            e.lifespan.duration = s.lifespan[s.level]
        end)

        upgrade_skill(this, "swiftness", function(this, s)
            U.speed_mul_self(this, s.max_speed_factor[s.level])
            this.melee.range = this.melee.range * s.max_speed_factor[s.level]
        end)

        upgrade_skill(this, "shadowdance", function(this, s)
            this.timed_attacks.list[1].disabled = nil
            this.timed_attacks.list[1].burst = s.copies[s.level]
        end)

        upgrade_skill(this, "lethalstrike", function(this, s)
            local la = this.timed_attacks.list[2]
            la.disabled = nil
            la.instakill_chance = s.instakill_chance[s.level]
            la.damage_min = s.level * la.damage_min
            la.damage_max = s.level * la.damage_max
        end)
        this.health.hp = this.health.hp_max
    end,
    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local a_sd = this.timed_attacks.list[1]
        local s_sd = this.hero.skills.shadowdance
        local a_l = this.timed_attacks.list[2]
        local s_l = this.hero.skills.lethalstrike
        local brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                if this.dodge.active then
                    this.dodge.active = false
                    this.health.immune_to = F_ALL
                    S:queue("HeroMirageShadowDodge")
                    U.animation_start(this, "disappear", nil, store.tick_ts, false)
                    U.y_wait(store, fts(3))

                    local smoke = E:create_entity("fx_mirage_smoke")

                    smoke.pos = V.vclone(this.pos)
                    smoke.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, smoke)
                    U.y_animation_wait(this)

                    local enemy = store.entities[this.soldier.target_id]

                    if enemy and not enemy.health.dead then
                        local illu = E:create_entity("soldier_mirage_illusion")

                        illu.pos = V.vclone(this.pos)

                        queue_insert(store, illu)
                        U.replace_blocker(store, this, illu)

                        local enp = enemy.nav_path
                        local new_ni = enp.ni
                        local node_limit = 20
                        local node_jump = 12
                        local range

                        if node_jump < P:nodes_to_goal(enp) - node_limit then
                            range = {new_ni + node_jump, new_ni, -1}
                        elseif node_jump < P:nodes_from_start(enp) - node_limit then
                            range = {new_ni - node_jump, new_ni, 1}
                        else
                            goto label_296_0
                        end

                        for i = range[1], range[2], range[3] do
                            local n_pos = P:node_pos(enp.pi, enp.spi, i)

                            if P:is_node_valid(enp.pi, i) and GR:cell_is_only(n_pos.x, n_pos.y, TERRAIN_LAND) then
                                new_ni = i

                                break
                            end
                        end

                        ::label_296_0::

                        local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

                        this.pos.x, this.pos.y = new_pos.x, new_pos.y
                        this.nav_rally.center = V.vclone(this.pos)
                        this.nav_rally.pos = V.vclone(this.pos)
                    end

                    U.y_animation_play(this, "appear", nil, store.tick_ts)
                    this.health.immune_to = 0
                    if not this.dodge.from_ranged_attack then
                        if a_sd.ts then
                            a_sd.ts = a_sd.ts - a_sd.cooldown * this.reward_shadowdance
                        end
                        if a_l.ts then
                            a_l.ts = a_l.ts - a_l.cooldown * this.reward_lethalstrike
                        end
                    end
                    scripts.heal(this, this.health.hp_max * 0.1)
                    goto label_296_1
                end

                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_296_1
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                if ready_to_use_skill(a_l, store) then
                    local target

                    if U.blocker_rank(store, this) ~= nil and U.is_blocked_valid(store, this) and
                        band(store.entities[this.soldier.target_id].vis.bans, a_l.vis_flags) == 0 then
                        target = store.entities[this.soldier.target_id]
                    else
                        target = U.find_random_enemy(store, this.pos, 0, a_l.range, a_l.vis_flags, a_l.vis_bans)
                    end

                    if not target or target.health.dead then
                        SU.delay_attack(store, a_l, 0.13333333333333333)
                    else
                        SU.hero_gain_xp_from_skill(this, s_l)
                        SU.stun_inc(target)
                        S:queue(this.sound_events.lethal_vanish)
                        this.health.immune_to = F_ALL
                        U.y_animation_play(this, "lethal_out", nil, store.tick_ts)
                        local initial_pos = V.vclone(this.pos)
                        local lpos, lflip = U.melee_slot_position(this, target, 1, true)

                        this.pos.x, this.pos.y = lpos.x, lpos.y
                        S:queue(a_l.sound)
                        U.animation_start(this, "lethal_attack", not lflip, store.tick_ts)
                        U.y_wait(store, a_l.hit_time)

                        if target and not target.health.dead then
                            local d = E:create_entity("damage")
                            d.source_id = this.id
                            d.target_id = target.id
                            if math.random() < a_l.instakill_chance then
                                if band(target.vis.flags, F_BOSS) ~= 0 then
                                    d.damage_type = a_l.damage_type
                                    d.value = 2 * a_l.damage_max
                                else
                                    d.pop = {"pop_instakill"}
                                    d.damage_type = DAMAGE_INSTAKILL
                                end
                            else
                                d.damage_type = a_l.damage_type
                                d.value = a_l.damage_max
                            end
                            d.value = d.value * this.unit.damage_factor
                            queue_damage(store, d)

                            if d.damage_type ~= DAMAGE_INSTAKILL and a_l.hit_fx and target.unit.blood_color then
                                local fx = E:create_entity(a_l.hit_fx)
                                fx.pos = V.vclone(target.pos)
                                if target.unit.hit_offset then
                                    fx.pos.x = fx.pos.x + target.unit.hit_offset.x
                                    fx.pos.y = fx.pos.y + target.unit.hit_offset.y
                                end
                                fx.render.sprites[1].ts = store.tick_ts
                                fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                                if fx.use_blood_color then
                                    fx.render.sprites[1].name = target.unit.blood_color
                                end
                                queue_insert(store, fx)
                            end
                        end

                        U.y_animation_wait(this)
                        SU.stun_dec(target)
                        S:queue(this.sound_events.lethal_vanish)

                        this.pos.x, this.pos.y = initial_pos.x, initial_pos.y

                        U.y_animation_play(this, "lethal_in", lflip, store.tick_ts)

                        this.health.immune_to = 0
                        a_l.ts = store.tick_ts

                        goto label_296_1
                    end
                end

                if ready_to_use_skill(a_sd, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, a_sd.min_range, a_sd.max_range,
                        a_sd.vis_flags, a_sd.vis_bans, function(v)
                            return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and
                                       (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
                        end)

                    if targets then
                        a_sd.ts = store.tick_ts
                        S:queue(a_sd.sound)
                        this.health.immune_to = F_ALL
                        U.animation_start(this, a_sd.animation, nil, store.tick_ts)

                        while store.tick_ts - a_sd.ts < a_sd.shoot_time do
                            if this.nav_rally.new then
                                goto label_296_1
                            end

                            if this.health.dead then
                                goto label_296_1
                            end

                            if this.unit.is_stunned then
                                goto label_296_1
                            end

                            coroutine.yield()
                        end

                        SU.hero_gain_xp_from_skill(this, s_sd)

                        local targets = U.find_enemies_in_range(store, this.pos, 0, a_sd.max_range * 1.5,
                            a_sd.vis_flags, a_sd.vis_bans, function(v)
                                return (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_WATER)) and
                                           (not GR:cell_is(v.pos.x, v.pos.y, TERRAIN_FAERIE))
                            end)

                        if targets then
                            for i = 1, a_sd.burst do
                                local target = table.random(targets)
                                local b = E:create_entity(a_sd.bullet)
                                b.bullet.damage_factor = this.unit.damage_factor
                                b.pos.x, b.pos.y = this.pos.x, this.pos.y
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id
                                b.bullet.level = s_sd.level

                                queue_insert(store, b)
                            end
                        end

                        while not U.animation_finished(this) do
                            if this.nav_rally.new then
                                goto label_296_1
                            end

                            if this.health.dead then
                                goto label_296_1
                            end

                            if this.unit.is_stunned then
                                goto label_296_1
                            end

                            coroutine.yield()
                        end
                        this.health.immune_to = 0
                        a_sd.ts = store.tick_ts

                        goto label_296_1
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if sta ~= A_IN_COOLDOWN and (brk or sta ~= A_NO_TARGET) then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end
            ::label_296_1::
            coroutine.yield()
        end
    end
}
-- 纽维斯-攻击
scripts.ray_wizard_chain = {
    insert = function(this, store, script)
        if not store.entities[this.bullet.target_id] then
            return false
        end
        return true
    end,
    update = function(this, store, script)
        local b = this.bullet
        local s = this.render.sprites[1]
        local target = store.entities[b.target_id]
        local dest = b.to
        local ho = V.v(0, 0)

        s.scale = V.v(1, 1)

        local function update_sprite()
            if target and target.motion then
                if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
                    ho.x, ho.y = target.unit.hit_offset.x, target.unit.hit_offset.y
                else
                    ho.x, ho.y = 0, 0
                end

                local d = math.max(math.abs(target.pos.x + ho.x - dest.x), math.abs(target.pos.y + ho.y - dest.y))

                if d > b.max_track_distance then
                    log.paranoid("(%s) ray_wizard_chain target (%s) out of max_track_distance", this.id, target.id)

                    target = nil
                else
                    dest.x, dest.y = target.pos.x + ho.x, target.pos.y + ho.y
                end
            end

            local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

            s.r = angle
            s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
        end

        s.ts = store.tick_ts

        update_sprite()

        local fx = SU.insert_sprite(store, b.hit_fx, dest)

        if target then
            fx.pos = target.pos

            if target.unit and target.unit.hit_offset then
                fx.render.sprites[1].offset = V.vclone(target.unit.hit_offset)
            end
        end

        if target then
            if not b.mods then
                b.mods = {b.mod}
            end

            for _, modname in pairs(b.mods) do
                local mod = E:create_entity(modname)
                mod.modifier.source_id = b.source_id
                mod.modifier.target_id = target.id
                mod.xp_gain_factor = b.xp_gain_factor
                mod.xp_dest_id = b.source_id
                mod.modifier.damage_factor = b.damage_factor
                queue_insert(store, mod)
            end

            table.insert(this.seen_targets, target.id)

            if this.bounces > 0 then
                local bounce_target = U.find_nearest_enemy(store, target.pos, 0, this.bounce_range,
                    this.bounce_vis_flags, this.bounce_vis_bans, function(v)
                        return not table.contains(this.seen_targets, v.id)
                    end)

                if bounce_target then
                    log.paranoid("bounce from %s to %s dist:%s", target.id, bounce_target.id,
                        V.dist(dest.x, dest.y, bounce_target.pos.x, bounce_target.pos.y))

                    local r = E:create_entity(this.template_name)
                    r.pos = V.vclone(dest)
                    r.bullet.to = V.vclone(bounce_target.pos)

                    if not b.ignore_hit_offset and bounce_target.unit and bounce_target.unit.hit_offset then
                        r.bullet.to.x = r.bullet.to.x + bounce_target.unit.hit_offset.x
                        r.bullet.to.y = r.bullet.to.y + bounce_target.unit.hit_offset.y
                    end
                    r.bullet.damage_factor = b.damage_factor
                    r.bullet.target_id = bounce_target.id
                    r.bullet.source_id = b.source_id
                    r.bounces = this.bounces - 1
                    r.seen_targets = this.seen_targets

                    queue_insert(store, r)
                end
            end
        end

        while not U.animation_finished(this) do
            update_sprite()
            coroutine.yield()
        end

        queue_remove(store, this)
    end
}
-- 纽维斯-攻击伤害
scripts.mod_ray_wizard = {
    insert = function(this, store, script)
        local target = store.entities[this.modifier.target_id]
        if not target or not target.health or target.health.dead then
            return false
        end
        this.modifier.ts = store.tick_ts
        return true
    end,
    update = function(this, store, script)
        local m = this.modifier
        local target = store.entities[m.target_id]
        local total_damage = math.random(this.damage_min, this.damage_max) * m.damage_factor
        local final_damage = km.clamp(0, total_damage, total_damage - target.health.hp)
        local steps = math.floor(m.duration / this.damage_every)
        local step_damage = (total_damage - final_damage) / steps
        local step = 0
        local last_ts = m.ts
        local tick_steps, cycle_damage, d

        if not target then
            queue_remove(store, this)

            return
        end

        this.pos = target.pos

        while true do
            target = store.entities[m.target_id]

            if not target or target.health.dead then
                queue_remove(store, this)

                return
            end

            tick_steps = math.floor((store.tick_ts - last_ts) / this.damage_every)

            if tick_steps < 1 then
                -- block empty
            else
                step = step + tick_steps
                last_ts = last_ts + tick_steps * this.damage_every
                cycle_damage = step_damage * tick_steps

                if steps <= step then
                    cycle_damage = cycle_damage + final_damage
                end

                d = E:create_entity("damage")
                d.source_id = this.id
                d.target_id = target.id
                d.value = cycle_damage
                d.damage_type = this.damage_type
                d.pop = this.pop
                d.pop_chance = this.pop_chance
                d.pop_conds = this.pop_conds
                d.xp_gain_factor = this.xp_gain_factor
                d.xp_dest_id = this.xp_dest_id

                queue_damage(store, d)

                if steps <= step then
                    queue_remove(store, this)

                    return
                end
            end

            coroutine.yield()
        end
    end
}
-- 纽维斯-导弹
scripts.missile_wizard = {
    insert = function(this, store)
        local b = this.bullet
        if not store.entities[b.target_id] then
            return false
        end
        b.to = V.v(this.pos.x + math.random(10, 90) * (math.random() < 0.5 and -1 or 1),
            this.pos.y + math.random(100, 300))

        local ps = E:create_entity("ps_missile_wizard")
        ps.particle_system.track_id = this.id
        queue_insert(store, ps)
        for i = 1, 3 do
            local pss = E:create_entity("ps_missile_wizard_sparks")
            pss.particle_system.name = "missile_wizard_sparks" .. i
            pss.particle_system.track_id = this.id
            pss.particle_system.emit_ts = store.tick_ts + i / (3 * pss.particle_system.emission_rate)
            queue_insert(store, pss)
        end
        return true
    end
}
-- 纽维斯
scripts.hero_wizard = {
    get_info = function(this)
        local m = E:get_template("mod_ray_wizard")
        local ranged_min, ranged_max = (m.damage_min + this.damage_buff) * this.unit.damage_factor,
            (m.damage_max + this.damage_buff) * this.unit.damage_factor
        local melee_min = (this.melee.attacks[1].damage_min + this.damage_buff) * this.unit.damage_factor
        local melee_max = (this.melee.attacks[1].damage_max + this.damage_buff) * this.unit.damage_factor
        local ranged_damage_type = DAMAGE_MAGICAL
        local melee_damage_type = this.melee.attacks[1].damage_type
        return {
            type = STATS_TYPE_SOLDIER,
            hp = this.health.hp,
            hp_max = this.health.hp_max,
            damage_min = melee_min,
            damage_max = melee_max,
            damage_type = melee_damage_type,
            ranged_damage_min = ranged_min,
            ranged_damage_max = ranged_max,
            ranged_damage_type = ranged_damage_type,
            armor = this.health.armor,
            respawn = this.health.dead_lifetime
        }
    end,
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local mage_tower_types = {"mage", "archmage", "sorcerer", "sunray", "arcane_wizard", "necromancer"}
        local mage_towers = table.filter(store.towers, function(_, e)
            return e.tower and table.contains(mage_tower_types, e.tower.type)
        end)
        this.mage_tower_count = #mage_towers

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "magicmissile", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            a.loops = s.count[s.level]
            local b = E:get_template("missile_wizard")
            b.bullet.damage_max = s.damage[s.level] + this.mage_tower_count
            b.bullet.damage_min = s.damage[s.level] + this.mage_tower_count
        end)

        upgrade_skill(this, "chainspell", function(this, s)
            local a = this.ranged.attacks[2]
            a.disabled = nil
            local b = E:get_template("ray_wizard_chain")
            b.bounces = s.bounces[s.level]
        end)

        upgrade_skill(this, "disintegrate", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.total_damage = s.total_damage[s.level] + this.mage_tower_count * 15
            a.count = s.count[s.level]
        end)

        upgrade_skill(this, "arcanereach", function(this, s)
            local factor = 1 + s.extra_range_factor[s.level]
            this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range * factor
            this.ranged.attacks[2].max_range = this.ranged.attacks[2].max_range * factor
        end)

        upgrade_skill(this, "arcanefocus", function(this, s)
            this.arcanefocus_extra = s.extra_damage[s.level]
        end)

        local m = E:get_template("mod_ray_wizard")
        m.damage_max = ls.ranged_damage_max[hl] + this.mage_tower_count * 4 + this.arcanefocus_extra
        m.damage_min = ls.ranged_damage_min[hl] + this.mage_tower_count * 4 + this.arcanefocus_extra

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_326_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.disintegrate

                if ready_to_use_skill(a, store) then
                    local triggers = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans, function(v)
                            return v.health.hp <= a.total_damage
                        end)

                    if not triggers then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        local remaining_damage = a.total_damage * this.unit.damage_factor

                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                            a.vis_flags, a.vis_bans, function(v)
                                return v.health.hp <= remaining_damage
                            end)

                        if not targets then
                            SU.delay_attack(store, a, 0.13333333333333333)

                            goto label_326_0
                        end

                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)
                        U.y_wait(store, a.hit_time)

                        local count = a.count

                        for _, t in pairs(targets) do
                            if remaining_damage <= 0 or count == 0 then
                                break
                            end

                            if remaining_damage >= t.health.hp then
                                remaining_damage = remaining_damage - t.health.hp
                                count = count - 1

                                local d = E:create_entity("damage")

                                d.damage_type = DAMAGE_EAT
                                d.target_id = t.id
                                d.source_id = this.id

                                queue_damage(store, d)

                                local fx = E:create_entity("fx_wizard_disintegrate")

                                fx.pos.x, fx.pos.y = t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                            end
                        end

                        U.y_animation_wait(this)

                        goto label_326_0
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.magicmissile

                if ready_to_use_skill(a, store) then
                    local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, false,
                        a.vis_flags, a.vis_bans)

                    if target then
                        local start_ts = store.tick_ts
                        this.health.immune_to = F_ALL
                        if SU.y_soldier_do_loopable_ranged_attack(store, this, target, a) then
                            a.ts = start_ts
                            SU.hero_gain_xp_from_skill(this, skill)
                        end
                        this.health.immune_to = 0
                        goto label_326_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or U.is_blocked_valid(store, this) then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_326_0::

            coroutine.yield()
        end
    end
}
-- 阿尔里奇-沙兵
scripts.soldier_sand_warrior = {
    get_info = function(this)
        local t = scripts.soldier_barrack.get_info(this)
        t.respawn = nil
        return t
    end,
    insert = function(this, store, script)
        this.melee.order = U.attack_order(this.melee.attacks)
        this.health.hp_max = this.health.hp_max + this.health.hp_inc * this.unit.level
        local node_offset = math.random(3, 6)
        this.nav_path.ni = this.nav_path.ni + node_offset
        this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)
        if not this.pos then
            return false
        end
        return true
    end,
    update = function(this, store, script)
        local attack = this.melee.attacks[1]
        local target
        local expired = false
        local next_pos = V.vclone(this.pos)
        local brk, sta, nearest

        this.lifespan.ts = store.tick_ts

        U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

        while true do
            if this.health.dead or store.tick_ts - this.lifespan.ts > this.lifespan.duration then
                this.health.hp = 0
                if not U.flag_has(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_DISINTEGRATE)) then
                    local s = E:create_entity("decal_alric_soul_ball")
                    s.target_id = this.owner_id
                    s.source_id = this.id
                    s.source_hp = this.health.hp_max
                    queue_insert(store, s)
                end
                SU.y_soldier_death(store, this)
                queue_remove(store, this)
                return
            end

            if this.unit.is_stunned then
                U.animation_start(this, "idle", nil, store.tick_ts, -1)
            else
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

                    if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
                        this.nav_path.ni = nearest[1][3]
                    end

                    U.y_animation_play(this, "start_walk", nil, store.tick_ts, 1)

                    while next_pos and not target and not this.health.dead and not expired and not this.unit.is_stunned do
                        U.set_destination(this, next_pos)

                        local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

                        U.animation_start(this, an, af, store.tick_ts, -1)
                        U.walk(this, store.tick_length)
                        coroutine.yield()

                        target = U.find_foremost_enemy(store, this.pos, 0, this.melee.range, false,
                            attack.vis_flags, attack.vis_bans)
                        expired = store.tick_ts - this.lifespan.ts > this.lifespan.duration
                        next_pos = P:next_entity_node(this, store.tick_length)

                        if not next_pos or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or
                            GR:cell_is(next_pos.x, next_pos.y,
                                bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) then
                            next_pos = nil
                        end
                    end
                    target = nil
                    if expired or this.health.dead or not next_pos then
                        this.health.hp = 0
                        U.y_animation_play(this, "death_travel", nil, store.tick_ts, 1)
                        queue_remove(store, this)
                    end
                end
            end

            coroutine.yield()
        end
    end
}
-- 阿尔里奇
scripts.hero_alric = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        upgrade_skill(this, "swordsmanship", function(this, s)
            this.swordsmanship_extra = s.extra_damage[s.level]
        end)

        upgrade_skill(this, "spikedarmor", function(this, s)
            this.health.spiked_armor = this.health.spiked_armor + s.values[s.level]
        end)

        upgrade_skill(this, "toughness", function(this, s)
            this.toughness_hp_extra = s.hp_max[s.level]
        end)

        upgrade_skill(this, "flurry", function(this, s)
            this.melee.attacks[3].disabled = nil
            this.melee.attacks[3].cooldown = s.cooldown[s.level]
            this.melee.attacks[3].loops = s.loops[s.level]
        end)

        upgrade_skill(this, "sandwarriors", function(this, s)
            this.timed_attacks.list[1].disabled = nil
            local e = E:get_template(this.timed_attacks.list[1].entity)
            e.lifespan.duration = s.lifespan[s.level]
        end)

        for i = 1, 3 do
            this.melee.attacks[i].damage_min = ls.melee_damage_min[hl] + this.swordsmanship_extra
            this.melee.attacks[i].damage_max = ls.melee_damage_max[hl] + this.swordsmanship_extra
        end
        this.health.hp_max = this.health.hp_max + this.toughness_hp_extra
        update_regen(this)
        this.health.hp = this.health.hp_max
    end,
    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local swa = this.timed_attacks.list[1]
        local sws = this.hero.skills.sandwarriors
        local brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_289_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                if ready_to_use_skill(swa, store) then
                    local target_info = U.find_enemies_in_paths(store.enemies, this.pos, 0, swa.range_nodes, nil,
                        swa.vis_flags, swa.vis_bans, true)

                    if target_info then
                        local target = target_info[1].target
                        local origin = target_info[1].origin
                        local start_ts = store.tick_ts

                        S:queue(swa.sound)
                        U.animation_start(this, swa.animation, nil, store.tick_ts, 1)

                        while store.tick_ts - start_ts < swa.spawn_time do
                            if this.nav_rally.new then
                                goto label_289_0
                            end

                            if this.health.dead then
                                goto label_289_0
                            end

                            if this.unit.is_stunned then
                                goto label_289_0
                            end

                            coroutine.yield()
                        end

                        swa.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, sws)

                        for i = 1, sws.count[sws.level] do
                            local spawn = E:create_entity(swa.entity)

                            spawn.nav_path.pi = origin[1]
                            spawn.nav_path.spi = km.zmod(i, 3)
                            spawn.nav_path.ni = origin[3]
                            spawn.unit.level = sws.level
                            spawn.owner_id = this.id
                            queue_insert(store, spawn)
                        end

                        while not U.animation_finished(this) do
                            if this.nav_rally.new then
                                goto label_289_0
                            end

                            if this.health.dead then
                                goto label_289_0
                            end

                            if this.unit.is_stunned then
                                goto label_289_0
                            end

                            coroutine.yield()
                        end
                    else
                        swa.ts = store.tick_ts + 0.2
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
            ::label_289_0::
            coroutine.yield()
        end
    end
}
-- 博林-地雷
scripts.decal_bolin_mine = {
    update = function(this, store)
        local ts = store.tick_ts

        while true do
            if store.tick_ts - ts >= this.duration then
                break
            end

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.radius, this.vis_flags,
                this.vis_bans)

            if targets and #targets > 0 then
                local dec = E:create_entity(this.hit_decal)

                dec.pos = V.vclone(this.pos)
                dec.render.sprites[1].ts = store.tick_ts

                queue_insert(store, dec)
                S:queue(this.sound)

                local fx = E:create_entity(this.hit_fx)

                fx.pos = V.vclone(this.pos)
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
                local new_targets = U.find_enemies_in_range(store, this.pos, 0, 2 * this.radius, this.vis_flags,
                    this.vis_bans)
                for _, t in ipairs(new_targets) do
                    local d = E:create_entity("damage")
                    d.damage_type = DAMAGE_EXPLOSION
                    d.source_id = this.id
                    d.target_id = t.id
                    d.value = math.random(this.damage_min, this.damage_max)
                    queue_damage(store, d)
                end

                break
            end

            U.y_wait(store, this.check_interval)
        end

        queue_remove(store, this)
    end
}
-- 博林
scripts.hero_bolin = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        local rf = this.timed_attacks.list[1]
        local b = E:get_template(rf.bullet)
        b.bullet.damage_min = ls.ranged_damage_min[hl]
        b.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "tar", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local tar = E:get_template("aura_bolin_tar")
            tar.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "mines", function(this, s)
            local a = this.timed_attacks.list[3]
            a.disabled = nil
            local m = E:get_template("decal_bolin_mine")
            m.damage_min = s.damage_min[s.level]
            m.damage_max = s.damage_max[s.level]
        end)

        if hl == 10 then
            this.timed_attacks.list[5].disabled = nil
        end

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta
        local shoot_count = 0

        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_47_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.tar

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.5)
                    else
                        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + 5

                        if not P:is_node_valid(pi, ni) then
                            ni = target.nav_path.ni
                        end

                        if not P:is_node_valid(pi, ni) then
                            SU.delay_attack(store, a, 0.5)
                        else
                            local start_ts = store.tick_ts
                            local flip = target.pos.x < this.pos.x

                            U.animation_start(this, "tar", flip, store.tick_ts)
                            SU.hero_gain_xp_from_skill(this, skill)

                            if U.y_wait(store, a.shoot_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                -- block empty
                            else
                                a.ts = start_ts

                                local af = this.render.sprites[1].flip_x
                                local b = E:create_entity(a.bullet)
                                local o = a.bullet_start_offset

                                b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
                                b.bullet.to = P:node_pos(pi, spi, ni)
                                b.pos = V.vclone(b.bullet.from)
                                b.bullet.source_id = this.id

                                queue_insert(store, b)

                                if not U.y_animation_wait(this) then
                                    goto label_47_0
                                end
                            end
                        end
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.mines

                if ready_to_use_skill(a, store) then
                    local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

                    if not nearest or #nearest < 1 then
                        SU.delay_attack(store, a, 0.5)
                    else
                        local mine_pos
                        local _, enemy_pos = U.find_random_enemy_with_pos(store, this.pos, a.min_range,
                            a.max_range, fts(24), a.vis_flags, a.vis_bans)
                        if enemy_pos then
                            mine_pos = enemy_pos
                        end

                        if not mine_pos then
                            local pi, spi, ni = unpack(nearest[1])
                            spi = math.random(1, 3)
                            local no = math.random(a.node_offset[1], a.node_offset[2])
                            ni = ni + no
                            if not P:is_node_valid(pi, ni) then
                                ni = ni - no
                            end
                            mine_pos = P:node_pos(pi, spi, ni)
                        end

                        local start_ts = store.tick_ts
                        local flip = mine_pos.x < this.pos.x

                        U.animation_start(this, "mine", flip, store.tick_ts)
                        SU.hero_gain_xp_from_skill(this, skill)

                        if U.y_wait(store, a.shoot_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = start_ts

                            local af = this.render.sprites[1].flip_x
                            local b = E:create_entity(a.bullet)
                            local o = a.bullet_start_offset

                            b.bullet.from = V.v(this.pos.x + (af and -1 or 1) * o.x, this.pos.y + o.y)
                            b.bullet.to = mine_pos
                            b.pos = V.vclone(b.bullet.from)
                            b.bullet.source_id = this.id

                            queue_insert(store, b)

                            if not U.y_animation_wait(this) then
                                goto label_47_0
                            end
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    -- 连射或普攻
                    if ready_to_use_skill(this.timed_attacks.list[5], store) then
                        a = this.timed_attacks.list[5]
                    elseif math.random() < this.timed_attacks.list[4].chance then
                        a = this.timed_attacks.list[4]
                    else
                        a = this.timed_attacks.list[1]
                    end
                    if ready_to_attack(a, store) then
                        local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range,
                            a.max_range, a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

                        if not target then
                            -- block empty
                        else
                            local flip = target.pos.x < this.pos.x
                            local b, an, af, ai

                            an, af, ai = U.animation_name_facing_point(this, a.aim_animation, target.pos)

                            U.animation_start(this, an, af, store.tick_ts, 1)
                            U.set_destination(this, this.pos)

                            for si, st in pairs(a.shoot_times) do
                                if U.y_wait(store, a.shoot_times[si], function()
                                    return SU.hero_interrupted(this)
                                end) then
                                    goto label_47_0
                                end

                                if not target then
                                    -- block empty
                                end

                                local target_dist = V.dist(target.pos.x, target.pos.y, this.pos.x, this.pos.y)

                                if si > 1 and
                                    (not target or target.health.death or not target_dist or
                                        not (target_dist >= a.min_range) or target_dist <= a.max_range or true) then
                                    target, targets, pred_pos =
                                        U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                                            a.node_prediction, a.vis_flags, a.vis_bans, a.filter_fn, F_FLYING)

                                    if not target then
                                        break
                                    end
                                end

                                an, af, ai = U.animation_name_facing_point(this, a.shoot_animation, target.pos)

                                U.animation_start(this, an, af, store.tick_ts, 1)

                                if U.y_wait(store, a.shoot_time, function()
                                    return SU.hero_interrupted(this)
                                end) then
                                    goto label_47_0
                                end
                                for i = 1, a.count do
                                    target = targets[km.zmod(i, #targets)]
                                    b = E:create_entity(a.bullet)
                                    b.pos = V.vclone(this.pos)
                                    b.bullet.damage_type = a.damage_type
                                    if a.chance then
                                        b.bullet.damage_min = b.bullet.damage_max
                                        b.bullet.pop = {"pop_splat"}
                                    end
                                    if a.bullet_start_offset then
                                        local offset = a.bullet_start_offset[ai]
                                        b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                                    end

                                    b.bullet.from = V.vclone(b.pos)
                                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                        target.pos.y + target.unit.hit_offset.y)
                                    b.bullet.target_id = target.id
                                    b.bullet.shot_index = si
                                    b.bullet.source_id = this.id
                                    b.bullet.xp_dest_id = this.id
                                    b.bullet.damage_factor = this.unit.damage_factor
                                    queue_insert(store, b)
                                end
                            end

                            U.y_animation_wait(this)

                            a.ts = store.tick_ts

                            U.animation_start(this, "reload", nil, store.tick_ts)

                            if U.y_animation_wait(this) then
                                goto label_47_0
                            end
                        end
                    end

                    if SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end
            ::label_47_0::
            coroutine.yield()
        end
    end
}
-- 迪纳斯-火球
scripts.denas_catapult_controller = {
    update = function(this, store)
        local w = store.visible_coords.right - store.visible_coords.left
        local rock_x = this.pos.x > w * 0.5 and store.visible_coords.right + this.rock_offset.x or
                           store.visible_coords.left - this.rock_offset.x
        local rock_y = this.pos.y + this.rock_offset.y
        local a = this.initial_angle

        U.y_wait(store, this.initial_delay)

        local delay = 0

        for i = 1, math.random(2, 4) do
            S:queue(this.sound_events.shoot, {
                delay = delay
            })

            delay = delay + U.frandom(0.1, 0.3)
        end

        for i = 1, this.count do
            U.y_wait(store, U.frandom(unpack(this.rock_delay)))

            local r = U.frandom(0, 1) * 40 + 20
            local bullet = E:create_entity(this.bullet)
            bullet.pos = V.v(rock_x, rock_y)
            bullet.bullet.from = V.vclone(bullet.pos)
            bullet.bullet.to = U.point_on_ellipse(this.pos, r, a)
            bullet.bullet.target_id = nil
            bullet.bullet.source_id = this.id
            bullet.bullet.damage_factor = this.damage_factor
            queue_insert(store, bullet)
            a = a + this.angle_increment
        end

        U.y_wait(store, this.exit_time)

        this.tween.reverse = true
        this.tween.remove = true
        this.tween.ts = store.tick_ts
    end
}
-- 迪纳斯-施加buff特效
scripts.denas_cursing = {
    update = function(this, store)
        this.render.sprites[1].ts = store.tick_ts

        local source = store.entities[this.source_id]
        local source_pos = source and V.vclone(source.pos) or nil
        local ts = store.tick_ts

        if not source or not source.health or source.health.dead then
            -- block empty
        else
            this.pos = V.vclone(source.pos)
            this.pos.x = this.pos.x + this.offset.x
            this.pos.y = this.pos.y + this.offset.y
            this.render.sprites[1].flip_x = source.render.sprites[1].flip_x

            while store.tick_ts - ts < this.duration do
                if source.pos.x ~= source_pos.x or source.pos.y ~= source_pos.y or source.health.death then
                    break
                end
                coroutine.yield()
            end
        end
        queue_remove(store, this)
    end
}
-- 迪纳斯-被buff塔特效
scripts.denas_buff_aura = {
    update = function(this, store)
        local target = store.entities[this.aura.target_id]
        local ts = store.tick_ts - this.aura.cycle_time
        local start_ts = store.tick_ts
        local inserted_entities = {}
        local force_remove = false

        if not target then
            -- block empty
        else
            this.pos = V.vclone(target.pos)
            this.tween.disabled = false
            this.tween.props[1].ts = store.tick_ts

            while true do
                if store.tick_ts - start_ts >= this.aura.duration then
                    break
                end

                if target.pos.x ~= this.pos.x or target.pos.y ~= this.pos.y or target.health.death then
                    force_remove = true
                    break
                end

                if store.tick_ts - ts >= this.aura.cycle_time then
                    ts = store.tick_ts
                    local e = E:create_entity(this.entity)
                    e.pos = V.vclone(this.pos)
                    e.tween.disabled = false

                    for i, t in ipairs(e.tween.props) do
                        e.tween.props[i].ts = store.tick_ts
                    end

                    table.insert(inserted_entities, e)
                    queue_insert(store, e)
                end

                coroutine.yield()
            end
        end

        if force_remove then
            for _, e in pairs(inserted_entities) do
                queue_remove(store, e)
            end
        end

        queue_remove(store, this)
    end
}
-- 迪纳斯-buff
scripts.mod_denas_tower = {
    insert = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if not target or not target.tower then
            log.error("error inserting mod_denas_tower %s", this.id)
            return true
        end

        SU.insert_tower_cooldown_buff(target, this.cooldown_factor)
        SU.insert_tower_range_buff(target, this.range_factor, true)

        for i = 1, #this.render.sprites do
            local s = this.render.sprites[i]
            s.ts = store.tick_ts
        end

        return true
    end,
    update = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if target then
            this.pos = target.pos
        end

        m.ts = store.tick_ts
        this.tween.ts = store.tick_ts

        while store.tick_ts - m.ts < m.duration - 0.5 do
            coroutine.yield()
        end

        this.tween.reverse = true
        this.tween.ts = store.tick_ts

        U.y_wait(store, 0.5)
        queue_remove(store, this)
    end,
    remove = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if not target or not target.tower then
            log.error("error removing mod_denas_tower %s", this.id)

            return true
        end
        SU.remove_tower_cooldown_buff(target, this.cooldown_factor)
        SU.remove_tower_range_buff(target, this.range_factor, true)
        return true
    end

}
-- 迪纳斯
scripts.hero_denas = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        for _, b in pairs(this.timed_attacks.list[1].bullets) do
            local bt = E:get_template(b)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]
        end

        for _, b in pairs(this.ranged.attacks[1].bullets) do
            local bt = E:get_template(b)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]
        end

        upgrade_skill(this, "tower_buff", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local m = E:get_template(a.mod)
            m.modifier.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "catapult", function(this, s)
            local a = this.timed_attacks.list[3]
            a.disabled = nil
            local c = E:get_template(a.entity)
            c.count = s.count[s.level]
            local r = E:get_template(c.bullet)
            r.bullet.damage_min = s.damage_min[s.level]
            r.bullet.damage_max = s.damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta, target, pred_pos
        local rock_flight_time = E:get_template("denas_catapult_rock").bullet.flight_time

        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
        this.health_bar.hidden = false

        for _, t in pairs(E:filter_templates("tower")) do
            t.tower.price = math.floor(t.tower.price * 0.96)
        end

        local function do_denas_attack(target, attack, pred_pos)
            local bullet
            local bullet_to = pred_pos or target.pos
            local bullet_to_start = V.vclone(bullet_to)
            local bidx = math.random(1, #a.animations)
            local animation = attack.animations[bidx]
            local bullet_name = attack.bullets[bidx]
            local an, af, ai = U.animation_name_facing_point(this, animation, bullet_to)

            U.animation_start(this, an, af, store.tick_ts, false)

            if SU.y_hero_wait(store, this, a.shoot_time) then
                return
            end

            bullet = E:create_entity(bullet_name)
            bullet.pos = V.vclone(this.pos)

            if attack.bullet_start_offset then
                local offset = attack.bullet_start_offset[ai]
                bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
            end

            bullet.bullet.from = V.vclone(bullet.pos)
            bullet.bullet.to = V.vclone(bullet_to)
            bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
            bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
            bullet.bullet.target_id = target.id
            bullet.bullet.source_id = this.id
            bullet.bullet.xp_dest_id = this.id
            bullet.bullet.level = attack.level
            bullet.bullet.damage_factor = this.unit.damage_factor
            bullet.bullet.damage_min = bullet.bullet.damage_min + this.damage_buff
            bullet.bullet.damage_max = bullet.bullet.damage_max + this.damage_buff
            queue_insert(store, bullet)

            if U.y_animation_wait(this) then
                return
            end

            return true
        end

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_54_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.tower_buff

                if ready_to_use_skill(a, store) then
                    local towers = U.find_towers_in_range(store.towers, this.pos, a, function(t)
                        return t.tower.can_be_mod
                    end)

                    if not towers or #towers <= 0 then
                        SU.delay_attack(store, a, 0.134)
                    else
                        local start_ts = store.tick_ts

                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts, 1)

                        if SU.y_hero_wait(store, this, a.curse_time) then
                            goto label_54_0
                        end

                        local curse = E:create_entity("denas_cursing")

                        curse.source_id = this.id

                        queue_insert(store, curse)

                        if SU.y_hero_wait(store, this, a.cast_time - a.curse_time) then
                            goto label_54_0
                        end

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local au = E:create_entity(a.aura)

                        au.aura.target_id = this.id
                        au.aura.source_id = this.id

                        queue_insert(store, au)

                        for _, t in ipairs(towers) do
                            local m = E:create_entity(a.mod)
                            m.modifier.source_id = this.id
                            m.modifier.target_id = t.id
                            queue_insert(store, m)
                        end

                        SU.y_hero_animation_wait(this)

                        goto label_54_0
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.catapult

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.134)
                    else
                        local start_ts = store.tick_ts
                        local flip = target.pos.x < this.pos.x

                        S:queue(a.sound)
                        U.animation_start(this, a.animation, flip, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.cast_time) then
                            goto label_54_0
                        end

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
                        local n_off = P:predict_enemy_node_advance(target, rock_flight_time)

                        if P:is_node_valid(pi, ni + n_off) then
                            ni = ni + n_off
                        end

                        local pos = P:node_pos(pi, 1, ni)
                        local e = E:create_entity(a.entity)
                        e.damage_factor = this.unit.damage_factor
                        e.pos = pos

                        queue_insert(store, e)
                        SU.y_hero_animation_wait(this)

                        goto label_54_0
                    end
                end

                a = this.timed_attacks.list[1]
                target = SU.soldier_pick_melee_target(store, this)

                if target then
                    if SU.soldier_move_to_slot_step(store, this, target) then
                        -- block empty
                    elseif store.tick_ts - a.ts < a.cooldown then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        do_denas_attack(target, a)
                    end
                else
                    target, a, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

                    if target and a then
                        U.set_destination(this, this.pos)

                        a.ts = store.tick_ts

                        if not do_denas_attack(target, a, pred_pos) then
                            goto label_54_0
                        end
                    end

                    if SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end
            ::label_54_0::
            coroutine.yield()
        end
    end
}
-- 兽王-恢复
scripts.aura_beastmaster_regeneration = {
    update = function(this, store)
        local hps = this.hps
        local hero = store.entities[this.aura.source_id]
        if not hero then
            return
        end
        while true do
            if not hero.health.dead and store.tick_ts - hps.ts >= hps.heal_every then
                hps.ts = store.tick_ts
                hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + hps.heal_max)
            end
            coroutine.yield()
        end
    end
}
-- 兽王-犀牛
scripts.beastmaster_rhino = {
    insert = function(this, store)
        this.pos = P:node_pos(this.nav_path)
        if not this.pos then
            return false
        end
        return true
    end,
    update = function(this, store)
        local attack = this.attack
        local start_ts = store.tick_ts
        this.tween.ts = store.tick_ts

        while true do
            local next, new = P:next_entity_node(this, store.tick_length)

            if not next then
                log.debug("  X not next for %s", this.id)
                queue_remove(store, this)
                return
            end

            if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or
                band(GR:cell_type(next.x, next.y), bor(TERRAIN_CLIFF, TERRAIN_WATER, TERRAIN_FAERIE)) ~= 0 then
                local twk = this.tween.props[1].keys

                if store.tick_ts - this.tween.ts < this.duration - 0.25 then
                    log.debug("  FF finish early for %s", this.id)

                    this.tween.ts = store.tick_ts - this.duration + 0.25
                end
            end

            U.set_destination(this, next)

            local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

            U.animation_start(this, an, af, store.tick_ts)
            U.walk(this, store.tick_length)

            if store.tick_ts - attack.ts >= attack.cooldown then
                attack.ts = store.tick_ts

                local targets = U.find_enemies_in_range(store, this.pos, 0, attack.damage_radius,
                    attack.damage_flags, attack.damage_bans, function(v)
                        return not table.contains(this.shared_enemies_hit, v)
                    end)

                if not targets then
                    -- block empty
                else
                    for _, e in pairs(targets) do
                        if band(e.vis.bans, F_STUN) == 0 and band(e.vis.flags, F_BOSS) == 0 and math.random() <
                            attack.mod_chance then
                            local m = E:create_entity(attack.mod)
                            m.modifier.source_id = this.id
                            m.modifier.target_id = e.id
                            queue_insert(store, m)
                        end

                        local d = E:create_entity("damage")
                        d.source_id = this.id
                        d.target_id = e.id
                        d.value = attack.damage
                        d.damage_type = attack.damage_type
                        queue_damage(store, d)
                        table.insert(this.shared_enemies_hit, e)
                    end
                end
            end

            coroutine.yield()
        end
    end
}
-- 兽王-猎鹰
scripts.beastmaster_falcon = {
    get_info = function(this)
        return {
            armor = 0,
            type = STATS_TYPE_SOLDIER,
            hp = this.fake_hp,
            hp_max = this.fake_hp,
            damage_min = this.custom_attack.damage_min,
            damage_max = this.custom_attack.damage_max
        }
    end,
    update = function(this, store)
        local sf = this.render.sprites[1]
        local h = this.owner
        local fm = this.force_motion
        local ca = this.custom_attack

        sf.offset.y = this.flight_height

        U.y_animation_play(this, "respawn", nil, store.tick_ts)
        U.animation_start(this, "idle", nil, store.tick_ts, true)

        while true do
            if h.health.dead then
                U.y_animation_play(this, "death", nil, store.tick_ts)
                queue_remove(store, this)

                return
            end

            if store.tick_ts - ca.ts > ca.cooldown then
                local target = U.find_nearest_enemy(store, this.pos, ca.min_range, ca.max_range, ca.vis_flags,
                    ca.vis_bans)

                if not target then
                    SU.delay_attack(store, ca, 0.13333333333333333)
                else
                    S:queue(ca.sound)
                    U.animation_start(this, "attack_fly", af, store.tick_ts, false)

                    local accel = 180
                    local max_speed = 300
                    local min_speed = 60
                    local mspeed = min_speed
                    local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
                    local start_dist = dist
                    local start_h = sf.offset.y
                    local target_h = target.unit.hit_offset.y

                    while dist > mspeed * store.tick_length and not target.health.dead do
                        local tx, ty = target.pos.x, target.pos.y
                        local dx, dy = V.mul(mspeed * store.tick_length,
                            V.normalize(V.sub(tx, ty, this.pos.x, this.pos.y)))

                        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, dx, dy)
                        sf.offset.y = km.clamp(0, this.flight_height * 1.5,
                            start_h + (target_h - start_h) * (1 - dist / start_dist))
                        sf.flip_x = dx < 0

                        coroutine.yield()

                        dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
                        mspeed = km.clamp(min_speed, max_speed, mspeed + accel * store.tick_length)
                    end

                    if target.health.dead then
                        ca.ts = store.tick_ts
                    else
                        this.pos.x, this.pos.y = target.pos.x, target.pos.y - 1

                        local d = E:create_entity("damage")
                        d.source_id = this.id
                        d.target_id = target.id
                        d.value = math.random(ca.damage_min, ca.damage_max)
                        d.damage_type = ca.damage_type
                        d.xp_gain_factor = ca.xp_gain_factor
                        d.xp_dest_id = h.id
                        queue_damage(store, d)

                        local m = E:create_entity(ca.mod)
                        m.modifier.source_id = this.id
                        m.modifier.target_id = target.id
                        queue_insert(store, m)

                        U.y_animation_play(this, "attack_hit", nil, store.tick_ts, 1)
                        ca.ts = store.tick_ts
                    end
                end
            end

            U.animation_start(this, "idle", nil, store.tick_ts, true)

            local dx, dy = V.sub(h.pos.x, h.pos.y, this.pos.x, this.pos.y)

            if V.len(dx, dy) > 50 then
                fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(1440, V.mul(4, dx, dy)))
            end

            if V.len(fm.a.x, fm.a.y) > 1 then
                fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
                fm.a.x, fm.a.y = 0, 0
            else
                fm.v.x, fm.v.y = 0, 0
                fm.a.x, fm.a.y = 0, 0
            end

            this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, V.mul(store.tick_length, fm.v.x, fm.v.y))
            fm.a.x, fm.a.y = V.trim(1800, V.mul(-0.75, fm.v.x, fm.v.y))
            sf.offset.y = km.clamp(0, this.flight_height, sf.offset.y + this.flight_speed * store.tick_length)
            sf.flip_x = fm.v.x < 0

            coroutine.yield()
        end
    end
}
-- 兽王-宠物
scripts.beastmaster_pet = {
    get_info = function(this)
        local min, max = this.melee.attacks[1].damage_min * this.unit.damage_factor,
            this.melee.attacks[1].damage_max * this.unit.damage_factor
        return {
            type = STATS_TYPE_SOLDIER,
            hp = this.health.hp,
            hp_max = this.health.hp_max,
            damage_min = min,
            damage_max = max,
            armor = this.health.armor,
            respawn = this.owner.timed_attacks.list[2].cooldown
        }
    end,
    insert = function(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        return true
    end,
    update = function(this, store)
        local brk, sta
        if this.template_name == "beastmaster_boar" then
            U.y_animation_play(this, "spawn", nil, store.tick_ts)
        end

        while true do
            if this.health.dead then
                table.removeobject(this.owner.boars, this)
                SU.y_soldier_death(store, this)
                return
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else

                while this.nav_rally.new do
                    this.nav_grid.waypoints = GR:find_waypoints(this.pos, nil, this.nav_rally.pos,
                        this.nav_grid.valid_terrains)

                    if SU.y_hero_new_rally(store, this) then
                        goto label_344_0
                    end
                end

                if this.melee then
                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        goto label_344_0
                    end
                end

                if SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_344_0::

            coroutine.yield()
        end
    end,
    level_up = function(this, s)
        if this.template_name == "beastmaster_boar" then
            this.health.hp_max = s.boar_hp_max[s.level]
        elseif this.template_name == "beastmaster_wolf" then
            this.health.hp_max = s.wolf_hp_max[s.level]
        end
        this.health.hp = this.health.hp_max
    end
}
-- 兽王
scripts.hero_beastmaster = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "boarmaster", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            a.max = s.boars[s.level]
            local e = E:get_template(a.entities[1])
            e.health.hp_max = s.boar_hp_max[s.level]
            local e = E:get_template(a.entities[2])
            e.health.hp_max = s.wolf_hp_max[s.level]
            for _, pet in pairs(this.boars) do
                pet.fn_level_up(this, s)
            end
        end)

        upgrade_skill(this, "stampede", function(this, s)
            this.timed_attacks.list[1].disabled = nil
            this.timed_attacks.list[1].count = s.rhinos[s.level]
            local r = E:get_template(this.timed_attacks.list[1].entity)
            r.duration = s.duration[s.level]
            r.attack.damage = s.damage[s.level]
            r.attack.mod_chance = s.stun_chance[s.level]
            local m = E:get_template(r.attack.mod)
            m.modifier.duration = s.stun_duration[s.level]
        end)

        upgrade_skill(this, "deeplashes", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
            a.cooldown = s.cooldown[s.level]
            local m = E:get_template(a.mod)
            m.dps.damage_min = s.blood_damage[s.level] / m.modifier.duration
            m.dps.damage_max = s.blood_damage[s.level] / m.modifier.duration
        end)

        upgrade_skill(this, "falconer", function(this, s)
            this.falcons_max = s.count[s.level]
        end)

        this.health.hp = this.health.hp_max
        this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
    end,
    insert = function(this, store, script)
        this.hero.fn_level_up(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        local e = E:create_entity("aura_beastmaster_regeneration")
        e.aura.source_id = this.id
        e.aura.ts = store.tick_ts
        queue_insert(store, e)
        return true
    end,
    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function distribute_boars(x, y, qty)
            if qty < 1 then
                return nil
            end

            local nodes = P:nearest_nodes(x, y, nil, nil, true)

            if #nodes < 1 then
                log.debug("cannot insert boars, no valid nodes nearby %s,%s", x, y)
                return nil
            end

            local opi, ospi, oni = unpack(nodes[1])
            local offset_options = {-2, -4, -6, -8, 2, 4, 6, 8}
            local positions = {}

            for i, offset in ipairs(offset_options) do
                if qty <= #positions then
                    break
                end

                local ni = oni + offset
                local spi = km.zmod(ospi + i, 3)
                local npos = P:node_pos(opi, spi, ni)

                if P:is_node_valid(opi, ni) and
                    band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK, TERRAIN_FAERIE)) ==
                    0 then
                    table.insert(positions, npos)
                end
            end

            if qty > #positions then
                log.debug("could not find valid offsets for boars around %s,%s", x, y)
                return nil
            end

            return positions
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                this.falcons = {}
                SU.y_hero_death_and_respawn(store, this)
            end

            if #this.falcons < this.falcons_max then
                local e = E:create_entity(this.falcons_name)
                e.pos = V.v(math.random(10, 30) * km.rand_sign(), math.random(-15, 15))
                e.pos.x, e.pos.y = e.pos.x + this.pos.x, e.pos.y + this.pos.y
                queue_insert(store, e)
                e.owner = this
                table.insert(this.falcons, e)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    local positions = distribute_boars(this.nav_rally.pos.x, this.nav_rally.pos.y, #this.boars)

                    if positions then
                        for i, boar in ipairs(this.boars) do
                            local pos = positions[i]
                            boar.nav_rally.center = pos
                            boar.nav_rally.pos = pos
                            boar.nav_rally.new = true
                        end
                    end

                    if SU.y_hero_new_rally(store, this) then
                        goto label_339_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.boarmaster

                if not a.disabled and #this.boars >= a.max then
                    a.ts = store.tick_ts
                end

                if ready_to_use_skill(a, store) and #this.boars < a.max then
                    local positions = distribute_boars(this.pos.x, this.pos.y, a.max)

                    if not positions then
                        -- block empty
                    else
                        local start_ts = store.tick_ts
                        this.health.immune_to = F_ALL
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts, false)

                        while store.tick_ts - start_ts < a.spawn_time do
                            if this.nav_rally.new then
                                goto label_339_0
                            end

                            if this.health.dead then
                                goto label_339_0
                            end

                            if this.unit.is_stunned then
                                goto label_339_0
                            end

                            coroutine.yield()
                        end

                        a.ts = store.tick_ts

                        while #this.boars < a.max do
                            local e
                            if math.random() < 0.5 then
                                e = E:create_entity(a.entities[1])
                            else
                                e = E:create_entity(a.entities[2])
                            end

                            e.pos = positions[#this.boars + 1]
                            e.nav_rally.center = V.vclone(e.pos)
                            e.nav_rally.pos = V.vclone(e.pos)
                            e.melee.attacks[1].xp_dest_id = this.id
                            e.render.sprites[1].flip_x = math.random() < 0.5

                            queue_insert(store, e)

                            e.owner = this

                            table.insert(this.boars, e)
                        end

                        while not U.animation_finished(this) do
                            if this.nav_rally.new then
                                goto label_339_0
                            end

                            if this.health.dead then
                                goto label_339_0
                            end

                            if this.unit.is_stunned then
                                goto label_339_0
                            end

                            coroutine.yield()
                        end
                        this.health.immune_to = 0
                        a.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, skill)
                    end
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.stampede

                if ready_to_use_skill(a, store) then
                    local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min,
                        a.range_nodes_max, 60, a.vis_flags, a.vis_bans, true)

                    if not target_info then
                        SU.delay_attack(store, a, 1)
                    else
                        local target = target_info[1].enemy
                        local origin = target_info[1].origin
                        local start_ts = store.tick_ts
                        this.health.immune_to = F_ALL
                        S:queue(a.sound)

                        local flip = target.pos.x < this.pos.x

                        U.animation_start(this, a.animation, flip, store.tick_ts)

                        while store.tick_ts - start_ts < a.spawn_time do
                            if this.nav_rally.new then
                                goto label_339_0
                            end

                            if this.health.dead then
                                goto label_339_0
                            end

                            if this.unit.is_stunned then
                                goto label_339_0
                            end

                            coroutine.yield()
                        end

                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local sni = origin[3] + 2

                        for i = 1, a.count do
                            local spawn = E:create_entity(a.entity)
                            spawn.nav_path.pi = origin[1]
                            spawn.nav_path.spi = km.zmod(i, 3)
                            spawn.nav_path.ni = sni
                            spawn.shared_enemies_hit = {}
                            queue_insert(store, spawn)
                            sni = km.clamp(1, origin[3] + 2, sni - 2)
                        end

                        while not U.animation_finished(this) do
                            if this.nav_rally.new then
                                goto label_339_0
                            end

                            if this.health.dead then
                                goto label_339_0
                            end

                            if this.unit.is_stunned then
                                goto label_339_0
                            end

                            coroutine.yield()
                        end
                        this.health.immune_to = 0
                        a.ts = store.tick_ts
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_339_0::

            coroutine.yield()
        end
    end
}
-- 但丁-圣水炸弹
scripts.van_helsing_grenade = {
    update = function(this, store)
        local b = this.bullet

        while store.tick_ts - b.ts + store.tick_length < b.flight_time do
            coroutine.yield()

            b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
            this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
            this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length

            if b.hide_radius then
                this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or
                                                    V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
            end
        end

        local target = store.entities[b.target_id]
        local targets = U.find_enemies_in_range(store, this.pos, 0, b.damage_radius, b.damage_flags,
            b.damage_bans)
        if targets then
            for _, t in pairs(targets) do
                if t.health and not t.health.dead then
                    local mod = E:create_entity(b.mod)
                    mod.modifier.target_id = t.id
                    queue_insert(store, mod)
                end
            end
        end

        local fx = E:create_entity(b.hit_fx)
        fx.render.sprites[1].ts = store.tick_ts
        fx.pos = V.vclone(b.to)
        queue_insert(store, fx)
        queue_remove(store, this)
    end
}
-- 但丁-减抗
scripts.mod_van_helsing_relic = {
    update = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]
        local factor = 1 - this.armor_reduce_factor

        if not target or not target.health or target.health.dead then
            -- block empty
        else
            for _, n in pairs(this.remove_mods) do
                SU.remove_modifiers(store, target, n)
            end
            factor = factor * (1 - target.health.armor_resilience)

            if target.health.armor > 0 then
                SU.armor_dec(target, target.health.armor * factor)
            end
            if target.health.magic_armor > 0 then
                SU.magic_armor_dec(target, target.health.magic_armor * factor)
            end

            this.pos.x, this.pos.y = target.pos.x, target.pos.y
            this.render.sprites[1].offset.y = target.health_bar.offset.y
            this.render.sprites[1].ts = store.tick_ts

            U.y_animation_wait(this)
        end

        queue_remove(store, this)
    end
}
-- 但丁-光明信标
scripts.mod_van_helsing_beacon = {
    insert = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]
        if not target or not target.health or target.health.dead then
            return false
        end
        target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
        return true
    end,
    remove = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]
        if target then
            target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
        end
        return true
    end
}
-- 但丁
scripts.hero_van_helsing = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local a = this.melee.attacks[1]
        a.damage_max = ls.damage_max[hl]
        a.damage_min = ls.damage_min[hl]

        local b = E:get_template("van_helsing_shotgun")
        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "multishoot", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.loops = s.loops[s.level]
        end)

        upgrade_skill(this, "silverbullet", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local b = E:get_template(a.bullet)
            b.bullet.damage_max = s.damage[s.level]
            b.bullet.damage_min = s.damage[s.level]
        end)
        upgrade_skill(this, "holygrenade", function(this, s)
            local a = this.timed_attacks.list[3]
            a.disabled = nil
            local m = E:get_template("mod_van_helsing_silence")
            m.modifier.duration = s.silence_duration[s.level]
        end)

        upgrade_skill(this, "relicofpower", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            local m = E:get_template("mod_van_helsing_relic")
            m.armor_reduce_factor = s.armor_reduce_factor[s.level]
        end)

        upgrade_skill(this, "beaconoflight", function(this, s)
            local m = E:get_template("mod_van_helsing_beacon")
            m.inflicted_damage_factor = s.inflicted_damage_factor[s.level]
            this.info.hero_portrait_always_on = true
        end)
        this.health.hp = this.health.hp_max
    end,
    insert = function(this, store)
        this.hero.fn_level_up(this, store)
        this.ranged.order = U.attack_order(this.ranged.attacks)
        this.melee.order = U.attack_order(this.melee.attacks)
        local a = E:create_entity("van_helsing_beacon_aura")
        a.aura.source_id = this.id
        queue_insert(store, a)
        this._beaconoflight_aura = a
        return true
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local ra = this.ranged.attacks[1]
        local a, skill, brk, sta

        local function is_werewolf(e)
            local t1 = e.template_name
            return t1 == "enemy_lycan" or t1 == "enemy_lycan_werewolf" or t1 == "enemy_werewolf"
        end

        local function shot_ready()
            return ready_to_attack(this.ranged.attacks[1], store)
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        this.health_bar.hidden = false

        while true do
            if h.dead then
                if band(this.health.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) == 0 then
                    S:queue(this.sound_events.death)
                    U.unblock_target(store, this)

                    local death_ts = store.tick_ts
                    local bans, flags = this.vis.bans, this.vis.flags
                    local prefix = this.render.sprites[1].prefix

                    this.vis.bans = F_ALL
                    this.vis.flags = F_NONE
                    this.render.sprites[1].prefix = prefix .. "_ghost"
                    this.health.ignore_damage = true
                    this.info.hero_portrait = this.info.hero_portrait_dead
                    this.info.portrait = this.info.portrait_dead

                    U.y_animation_play(this, "start", nil, store.tick_ts)
                    U.animation_start(this, "idle", nil, store.tick_ts, true)

                    while store.tick_ts - death_ts < this.health.dead_lifetime do
                        SU.y_hero_new_rally(store, this)
                        this.health.ignore_damage = true
                        coroutine.yield()
                    end

                    this.vis.bans = bans
                    this.vis.flags = flags
                    this.render.sprites[1].prefix = prefix
                    this.health.hp = this.health.hp_max
                    this.health.dead = false
                    this.health.ignore_damage = false
                    this.info.hero_portrait = this.info.hero_portrait_alive
                    this.info.portrait = this.info.portrait_alive

                    S:queue(this.sound_events.respawn)
                    U.y_animation_play(this, "respawn", nil, store.tick_ts)

                    this.health_bar.hidden = false
                else
                    local a = this._beaconoflight_aura

                    if a then
                        a.aura.requires_alive_source = true
                    end

                    SU.y_hero_death_and_respawn(store, this)

                    if a then
                        a.aura.requires_alive_source = false
                    end
                end
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_419_2
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.multishoot

                if ready_to_use_skill(a, store) and not shot_ready() then
                    local target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                        a.shoot_time, a.vis_flags, a.vis_bans, function(e)
                            local center_pos = P:node_pos(e.nav_path.pi, 1, e.nav_path.ni)
                            local nearby = U.find_enemies_in_range(store, center_pos, 0, a.search_range,
                                a.vis_flags, a.vis_bans)

                            return nearby and #nearby >= a.search_min_count
                        end)

                    if not target then
                        SU.delay_attack(store, a, 0.2)
                    else
                        local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)
                        local aidx
                        U.animation_start(this, an, af, store.tick_ts, false)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                goto label_419_1
                            end
                            coroutine.yield()
                        end

                        for i = 1, a.loops * 0.5 do
                            log.paranoid("van_helsing multishoot target:%s (targets: %s)", target.id,
                                table.concat(table.map(targets, function(k, v)
                                    return v.id
                                end), ","))

                            an, af, aidx = U.animation_name_facing_point(this, a.animations[2], target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            for i = 1, 2 do
                                U.y_wait(store, fts(2))

                                local b = E:create_entity(a.bullet)
                                b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
                                b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(target.pos)
                                b.bullet.target_id = target.id
                                b.bullet.damage_factor = this.unit.damage_factor
                                queue_insert(store, b)
                            end

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    goto label_419_0
                                end
                                coroutine.yield()
                            end

                            target = table.random(targets)

                            if target.health.dead then
                                local center_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni)
                                local nearby = U.find_nearest_enemy(store, center_pos, 0, a.search_range,
                                    a.vis_flags, a.vis_bans)

                                if nearby then
                                    table.removeobject(targets, target)
                                    table.insert(targets, nearby)
                                    target = nearby
                                end
                            end
                        end

                        an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                            coroutine.yield()
                        end

                        ::label_419_0::

                        a.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, skill)
                        ra.ts = store.tick_ts

                        goto label_419_2
                    end
                end

                ::label_419_1::

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.silverbullet

                if ready_to_use_skill(a, store) then
                    local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                        a.shoot_time, a.vis_flags, a.vis_bans, function(e)
                            return math.abs(P:nodes_to_defend_point(e.nav_path)) < a.nodes_to_defend
                        end)

                    if not target then
                        local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if targets then
                            table.sort(targets, function(e1, e2)
                                local h1 = e1.health.hp / (1 - e1.health.armor)
                                local h2 = e2.health.hp / (1 - e2.health.armor)
                                local df = a.werewolf_damage_factor

                                return h1 * (is_werewolf(e1) and df or 1) > h2 * (is_werewolf(e2) and df or 1)
                            end)

                            if #targets > 0 then
                                target = targets[1]
                            end
                        end
                    end

                    if not target then
                        SU.delay_attack(store, a, 0.2)
                    else
                        local an, af, aidx = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if U.y_wait(store, a.crosshair_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            local m = E:create_entity(a.crosshair_name)

                            m.modifier.source_id = this.id
                            m.modifier.target_id = target.id
                            m.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, m)

                            if U.y_wait(store, a.shoot_time - a.crosshair_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                queue_remove(store, m)
                            else
                                local b = E:create_entity(a.bullet)

                                b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[aidx].x
                                b.pos.y = this.pos.y + a.bullet_start_offset[aidx].y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(target.pos)
                                b.bullet.target_id = target.id
                                b.bullet.damage_factor = (is_werewolf(target) and a.werewolf_damage_factor or 1) *
                                                             this.unit.damage_factor

                                queue_insert(store, b)

                                while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                    coroutine.yield()
                                end

                                a.ts = store.tick_ts

                                SU.hero_gain_xp_from_skill(this, skill)

                                ra.ts = store.tick_ts

                                goto label_419_2
                            end
                        end
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.holygrenade

                if ready_to_use_skill(a, store) and not shot_ready() then
                    local g = E:get_template("van_helsing_grenade")
                    local target, _, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                        a.shoot_time + g.bullet.flight_time, a.vis_flags, a.vis_bans, enemy_is_silent_target)

                    if not target then
                        SU.delay_attack(store, a, 0.2)
                    else
                        local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if U.y_wait(store, a.shoot_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            local b = E:create_entity(a.bullet)
                            b.pos.x = this.pos.x + (af and -1 or 1) * a.bullet_start_offset[1].x
                            b.pos.y = this.pos.y + a.bullet_start_offset[1].y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.vclone(pred_pos)
                            b.bullet.target_id = target.id
                            queue_insert(store, b)

                            while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                coroutine.yield()
                            end

                            a.ts = store.tick_ts
                            SU.hero_gain_xp_from_skill(this, skill)
                            goto label_419_2
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end
            ::label_419_2::
            coroutine.yield()
        end
    end,
    can_relic = function(this, store, attack, target)
        return (target.health.armor > 0 or target.health.magic_armor > 0) and target.health.hp_max > 500
    end
}
-- 马利克-地震
scripts.aura_malik_fissure = {
    update = function(this, store)
        local a = this.aura
        local function do_attack(pos)
            local fx = E:create_entity(a.fx)
            fx.pos.x, fx.pos.y = pos.x, pos.y
            fx.render.sprites[2].ts = store.tick_ts
            fx.tween.ts = store.tick_ts
            queue_insert(store, fx)
            local targets = U.find_enemies_in_range(store, pos, 0, a.damage_radius, a.vis_flags, a.vis_bans)
            if targets then
                for _, t in pairs(targets) do
                    local d = E:create_entity("damage")
                    d.value = math.random(a.damage_min, a.damage_max)
                    d.damage_type = a.damage_type
                    d.source_id = this.id
                    d.target_id = t.id
                    queue_damage(store, d)
                    if U.flags_pass(t.vis, this.stun) then
                        local m = E:create_entity(this.stun.mod)
                        m.modifier.source_id = this.id
                        m.modifier.target_id = t.id
                        queue_insert(store, m)
                    end
                end
                log.paranoid(">>>> aura_malik_fissure POS:%s,%s  damaged:%s", pos.x, pos.y,
                    table.concat(table.map(targets, function(k, v)
                        return v.id
                    end), ","))
            end
        end

        do_attack(this.pos)

        local pi, spi, ni

        if a.target_id and store.entities[a.target_id] then
            local np = store.entities[a.target_id].nav_path

            pi, spi, ni = np.pi, np.spi, np.ni
        else
            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

            if #nodes < 1 then
                log.error("aura_malik_fissure could not find valid nodes near %s,%s", this.pos.x, this.pos.y)

                goto label_201_0
            end

            pi, spi, ni = unpack(nodes[1])
        end

        for i = 1, a.level do
            spi = (spi == 2 or spi == 3) and 1 or math.random() < 0.5 and 2 or 3

            U.y_wait(store, a.spread_delay)

            local nni = ni + i * a.spread_nodes
            local spos = P:node_pos(pi, spi, nni)

            do_attack(spos)

            nni = ni - i * a.spread_nodes
            spos = P:node_pos(pi, spi, nni)

            do_attack(spos)
        end

        ::label_201_0::

        queue_remove(store, this)
    end
}
-- 马利克
scripts.hero_malik = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "smash", function(this, s)
            local a = this.melee.attacks[3]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
            a.mod_chance = s.stun_chance[s.level]
        end)

        upgrade_skill(this, "fissure", function(this, s)
            local a = this.melee.attacks[4]
            a.disabled = nil
            local au = E:get_template(a.hit_aura)
            au.aura.level = s.level
            au.aura.damage_min = s.damage_min[s.level]
            au.aura.damage_max = s.damage_max[s.level]
        end)
        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_81_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
            ::label_81_0::
            coroutine.yield()
        end
    end
}
-- 德得尔-护甲buff
scripts.mod_priest_armor = {
    insert = function(this, store, script)
        local target = store.entities[this.modifier.target_id]

        if not target or target.health.dead then
            return false
        end

        if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
            return false
        end

        local rate = this.armor_rate
        local function calc_inc(is_magic)
            if is_magic then
                return rate * (1 - target.health.magic_armor)
            else
                return rate * (1 - target.health.armor)
            end
        end

        this.armor_inc = calc_inc(false)
        this.magic_armor_inc = calc_inc(true)

        SU.armor_inc(target, this.armor_inc)
        SU.magic_armor_inc(target, this.magic_armor_inc)

        signal.emit("mod-applied", this, target)
        return true
    end,
    remove = function(this, store, script)
        local target = store.entities[this.modifier.target_id]
        if target then
            SU.armor_dec(target, this.armor_inc)
            SU.magic_armor_dec(target, this.magic_armor_inc)
        end
        return true
    end,
    update = function(this, store, script)
        local m = this.modifier
        local last_ts = store.tick_ts
        local target = store.entities[m.target_id]

        if not target then
            queue_remove(store, this)
            return
        end

        this.pos = target.pos

        while true do
            target = store.entities[m.target_id]
            if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
                queue_remove(store, this)
                return
            end
            if this.render and m.use_mod_offset and target.unit.mod_offset then
                this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x,
                    target.unit.mod_offset.y
            end
            coroutine.yield()
        end
    end
}
-- 德得尔-塔buff
scripts.mod_priest_consecrate = {
    update = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if not target then
            queue_remove(store, this)
            return
        end

        this.pos = V.vclone(target.pos)
        m.ts = store.tick_ts
        this.tween.disabled = false
        this.tween.ts = store.tick_ts
        SU.insert_tower_damage_factor_buff(target, this.extra_damage)

        while store.tick_ts - m.ts < m.duration do
            coroutine.yield()
            target = store.entities[m.target_id]
            if not target then
                goto label_374_0
            end
        end
        SU.remove_tower_damage_factor_buff(target, this.extra_damage)

        ::label_374_0::
        this.tween.reverse = true
        this.tween.ts = store.tick_ts
        this.tween.remove = true
    end
}
-- 德得尔
scripts.hero_priest = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local b = E:get_template("bolt_priest")
        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "holylight", function(this, s)
            local a = this.timed_attacks.list[1]
            a.max_per_cast = s.heal_count[s.level]
            a.revive_chance = s.revive_chance[s.level]
            local m = E:get_template(a.mod)
            m.hps.heal_min = s.heal_hp[s.level]
            m.hps.heal_max = s.heal_hp[s.level]
        end)

        upgrade_skill(this, "consecrate", function(this, s)
            this.timed_attacks.list[2].disabled = nil
            local m = E:get_template("mod_priest_consecrate")
            m.modifier.duration = s.duration[s.level]
            m.extra_damage = s.extra_damage[s.level]
        end)

        upgrade_skill(this, "wingsoflight", function(this, s)
            this.teleport.disabled = nil
            local m = E:get_template("mod_priest_armor")
            m.modifier.duration = s.duration[s.level]
            m.armor_rate = s.armor_rate[s.level]
        end)

        upgrade_skill(this, "blessedarmor", function(this, s)
            this.blessedarmor_extra = s.armor[s.level]
        end)

        upgrade_skill(this, "divinehealth", function(this, s)
            this.divinehealth_extra_hp = s.extra_hp[s.level]
            this.divinehealth_regen_factor = s.regen_factor[s.level]
        end)

        this.health.hp_max = this.health.hp_max + this.divinehealth_extra_hp
        update_regen(this)
        inc_armor_by_skill(this, this.blessedarmor_extra)
        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function do_armor_buff(pos, out)
            local skill = this.hero.skills.wingsoflight
            if skill.level < 1 then
                return
            end

            local targets = U.find_soldiers_in_range(store.soldiers, pos, 0, skill.range, 0, 0)

            if targets then
                for i = 1, math.min(#targets, skill.count[skill.level]) do
                    local target = targets[i]
                    local m = E:create_entity("mod_priest_armor")
                    m.modifier.target_id = target.id
                    m.render.sprites[1].ts = store.tick_ts
                    m.render.sprites[2].ts = store.tick_ts
                    m.render.sprites[2].offset.y = target.health_bar.offset.y + 7
                    queue_insert(store, m)
                end
            end

            local fx = E:create_entity("fx_priest_wave_" .. (out and "out" or "in"))
            fx.pos = V.vclone(pos)
            fx.render.sprites[1].ts = store.tick_ts
            queue_insert(store, fx)
        end

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    this.nav_rally.new = false

                    U.unblock_target(store, this)
                    S:queue(this.sound_events.change_rally_point)

                    if SU.hero_will_teleport(this, this.nav_rally.pos) then
                        local vis_bans = this.vis.bans

                        this.vis.bans = F_ALL
                        this.health_bar.hidden = true
                        this.health.ignore_damage = true

                        local tp = this.teleport

                        S:queue(tp.sound)
                        do_armor_buff(this.pos, true)
                        U.y_animation_play(this, tp.animations[1], nil, store.tick_ts)

                        this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y

                        U.set_destination(this, this.pos)
                        do_armor_buff(this.pos, false)
                        U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)

                        this.health.ignore_damage = false
                        this.health_bar.hidden = nil
                        this.vis.bans = vis_bans

                        goto label_365_0
                    else
                        local vis_bans = this.vis.bans

                        this.vis.bans = F_ALL

                        local out = SU.y_hero_walk_waypoints(store, this)

                        U.animation_start(this, "idle", nil, store.tick_ts, true)

                        this.vis.bans = vis_bans

                        if out == true then
                            goto label_365_0
                        end
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.holylight
                if ready_to_attack(a, store) then
                    local targets = table.filter(store.soldiers, function(k, v)
                        return v.health.hp < 0.7 * v.health.hp_max and U.is_inside_ellipse(v.pos, this.pos, a.range)
                    end)

                    if #targets < 1 then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        local dead_targets = table.filter(targets, function(k, v)
                            return v.health and v.health.dead
                        end)

                        local could_revive = false

                        for _, t in pairs(dead_targets) do
                            if not t.reinforcement and not table.contains(a.excluded_templates, t.template_name) then
                                could_revive = true
                                break
                            end
                        end

                        if #dead_targets == #targets and not could_revive then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            could_revive = false
                            table.sort(targets, function(e1, e2)
                                if e1.health.dead and e2.health.dead then
                                    return false
                                elseif e1.health.dead then
                                    return true
                                elseif e2.health.dead then
                                    return false
                                else
                                    return e1.health.hp_max - e1.health.hp > e2.health.hp_max - e2.health.hp
                                end
                            end)

                            if skill.level == 0 then
                                SU.hero_gain_xp(this, 7, "holylight level 0")
                            else
                                SU.hero_gain_xp_from_skill(this, skill)
                            end

                            S:queue(a.sound)
                            U.animation_start(this, a.animation, nil, store.tick_ts)
                            U.y_wait(store, a.shoot_time)

                            local count = 0

                            for _, s in pairs(targets) do
                                -- 复活
                                if s.health.dead and not s.unit.hide_during_death and (math.random() < a.revive_chance) and
                                    not s.reinforcement and not s.hero and
                                    not table.contains(a.excluded_templates, s.template_name) then

                                    s.health.dead = false
                                    s.health.hp = s.health.hp_max
                                    s.health_bar.hidden = nil
                                    s.ui.can_select = true

                                    if s.unit.hide_during_death then
                                        s.unit.hide_during_death = nil
                                        U.sprites_show(s)
                                    end

                                    s.main_script.runs = 1

                                    local fx = E:create_entity("fx_priest_revive")
                                    fx.pos = V.vclone(s.pos)
                                    fx.render.sprites[1].ts = store.tick_ts
                                    queue_insert(store, fx)
                                    count = count + 1
                                    -- 治疗
                                elseif not s.health.dead then
                                    local m = E:create_entity(a.mod)
                                    m.modifier.target_id = s.id
                                    m.modifier.source_id = this.id
                                    queue_insert(store, m)
                                    count = count + 1
                                end

                                if count >= a.max_per_cast then
                                    break
                                end
                            end

                            a.ts = store.tick_ts
                            U.y_animation_wait(this)
                            goto label_365_0
                        end
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.consecrate

                if ready_to_use_skill(a, store) then
                    local towers = table.filter(store.towers, function(_, e)
                        return e.tower and e.tower.can_be_mod and not e.tower.blocked and
                                   not table.contains(a.excluded_templates, e.template_name) and
                                   V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
                    end)

                    if #towers < 1 then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)
                        U.y_wait(store, a.shoot_time)

                        local buffed_tower_ids = {}

                        for _, e in pairs(store.modifiers) do
                            if e.template_name == "mod_priest_consecrate" then
                                table.insert(buffed_tower_ids, e.modifier.target_id)
                            end
                        end

                        local towers = table.filter(store.towers, function(_, e)
                            return e.tower.can_be_mod and not e.tower.blocked and
                                       not table.contains(a.excluded_templates, e.template_name) and
                                       V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y) < a.range
                        end)

                        table.sort(towers, function(e1, e2)
                            return V.dist2(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) <
                                       V.dist2(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
                        end)

                        local buffed_tower, unbuffed_tower

                        for _, t in pairs(towers) do
                            if not buffed_tower and table.contains(buffed_tower_ids, t.id) then
                                buffed_tower = t
                            else
                                unbuffed_tower = unbuffed_tower or t
                            end
                        end

                        local tower = unbuffed_tower or buffed_tower

                        if tower then
                            local m = E:create_entity("mod_priest_consecrate")
                            m.modifier.target_id = tower.id
                            queue_insert(store, m)
                        end

                        U.y_animation_wait(this)

                        goto label_365_0
                    end
                end

                if this.soldier.target_id then
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)
                    if brk then
                        goto label_365_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or U.is_blocked_valid(store, this) then
                    goto label_365_0
                end

                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    goto label_365_0
                end

                if SU.soldier_go_back_step(store, this) then
                    goto label_365_0
                end

                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
            ::label_365_0::
            coroutine.yield()
        end
    end
}
-- 马格努斯-奥术风暴控制器
scripts.magnus_arcane_rain_controller = {
    update = function(this, store)
        this.tween.disabled = false
        this.tween.ts = store.tick_ts
        local range_factor = this.render.sprites[1].scale.x
        local a = this.initial_angle

        for i = 1, this.count do
            U.y_wait(store, this.spawn_time)

            local r = (U.frandom(0, 1) * 40 + 15) * range_factor
            local pos = U.point_on_ellipse(this.pos, r, a)
            local e = E:create_entity(this.entity)

            e.pos = V.vclone(pos)
            if this.is_illusion then
                e.damage_min = e.damage_min * 0.35
                e.damage_max = e.damage_max * 0.35
                e.damage_type = DAMAGE_MAGICAL
                e.damage_radius = e.damage_radius * range_factor
                e.render.sprites[1].scale = V.vv(range_factor)
            end
            e.damage_factor = this.damage_factor
            queue_insert(store, e)

            a = a + this.angle_increment

            if a > 2 * math.pi then
                a = a - 2 * math.pi
            end
        end

        U.y_wait(store, 0.5)

        this.tween.reverse = true
        this.tween.remove = true
        this.tween.ts = store.tick_ts
    end
}
-- 马格努斯-奥术风暴
scripts.magnus_arcane_rain = {
    update = function(this, store)
        this.render.sprites[1].ts = store.tick_ts

        U.animation_start(this, "drop", nil, store.tick_ts, 1)
        S:queue(this.sound)
        U.y_wait(store, this.hit_time)

        local targets = U.find_enemies_in_range(store, this.pos, 0, this.damage_radius, this.damage_flags,
            this.damage_bans or 0)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")
                d.damage_type = this.damage_type
                d.source_id = this.id
                d.target_id = target.id
                d.value = math.random(this.damage_min, this.damage_max) * this.damage_factor
                queue_damage(store, d)
            end
        end

        U.y_animation_wait(this)
        queue_remove(store, this)

    end
}
-- 马格努斯-幻影
scripts.soldier_magnus_illusion = {
    update = function(this, store)
        -- as a soldier
        local brk, stam, star

        this.reinforcement.ts = store.tick_ts
        this.render.sprites[1].ts = store.tick_ts

        if this.sound_events and this.sound_events.raise then
            S:queue(this.sound_events.raise)
        end

        this.health_bar.hidden = true

        U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
        local arcane_rain = this.timed_attacks.list[1]
        while true do
            if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
                this.reinforcement.duration then
                if this.health.hp > 0 then
                    this.reinforcement.hp_before_timeout = this.health.hp
                end
                this.health.hp = 0
                SU.y_soldier_death(store, this)
                return
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                -- enable arcane rain attack
                if ready_to_use_skill(arcane_rain, store) then
                    local target = U.find_random_enemy(store, this.pos, arcane_rain.min_range,
                        arcane_rain.max_range, arcane_rain.vis_flags, arcane_rain.vis_bans)

                    if not target then
                        SU.delay_attack(store, arcane_rain, 0.13333333333333333)
                    else
                        S:queue(arcane_rain.sound)

                        local flip = target.pos.x < this.pos.x
                        this.render.sprites[1].prefix = "hero_magnus"
                        U.animation_start(this, arcane_rain.animation, flip, store.tick_ts)

                        if U.y_wait(store, arcane_rain.cast_time, function()
                            return SU.soldier_interrupted(this)
                        end) then
                            goto label_34_0
                        end

                        arcane_rain.ts = store.tick_ts

                        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

                        if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
                            ni = ni + 5
                        end

                        local pos = P:node_pos(pi, spi, ni)
                        local e = E:create_entity(arcane_rain.entity)
                        e.is_illusion = true
                        e.pos = pos
                        e.damage_factor = this.unit.damage_factor
                        e.render.sprites[1].scale = V.v(0.8, 0.8)
                        queue_insert(store, e)

                        if not U.y_animation_wait(this) then
                            this.render.sprites[1].prefix = "soldier_magnus_illusion"
                            goto label_34_0
                        end
                    end
                end
                if this.melee then
                    brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                        goto label_34_1
                    end
                end

                if this.ranged then
                    brk, star = SU.y_soldier_ranged_attacks(store, this)

                    if brk or star == A_DONE then
                        goto label_34_1
                    elseif star == A_IN_COOLDOWN then
                        goto label_34_0
                    end
                end

                if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                    goto label_34_1
                end

                if SU.soldier_go_back_step(store, this) then
                    goto label_34_1
                end

                ::label_34_0::

                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end

            ::label_34_1::

            coroutine.yield()
        end
    end
}
-- 马格努斯
scripts.hero_magnus = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local ra = this.ranged.attacks[1]
        local b = E:get_template(ra.bullet)

        b.bullet.damage_min = ls.ranged_damage_min[hl]
        b.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "mirage", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.count = s.count[s.level]
            local il = E:get_template(a.entity)
            il.level = hl
            il.health.hp_max = ls.hp_max[s.level] * s.health_factor
            il.melee.attacks[1].damage_min = ls.melee_damage_min[s.level] * s.damage_factor
            il.melee.attacks[1].damage_max = ls.melee_damage_max[s.level] * s.damage_factor
            local ira = il.ranged.attacks[1]
            local ib = E:get_template(ira.bullet)

            ib.bullet.damage_min = ls.ranged_damage_min[s.level] * s.damage_factor
            ib.bullet.damage_max = ls.ranged_damage_max[s.level] * s.damage_factor
            il.timed_attacks = il.timed_attacks or {}
            il.timed_attacks.list = il.timed_attacks.list or {}
            il.timed_attacks.list[1] = table.deepclone(this.timed_attacks.list[2])
        end)

        upgrade_skill(this, "arcane_rain", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local c = E:get_template(a.entity)
            c.count = s.count[s.level]
            local r = E:get_template(c.entity)
            r.damage_min = s.damage[s.level]
            r.damage_max = s.damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta
        local function d2r(d)
            return d * math.pi / 180
        end
        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_75_0
                    end
                end

                skill = this.hero.skills.mirage
                a = this.timed_attacks.list[1]

                if ready_to_use_skill(a, store) then
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if U.y_wait(store, a.cast_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        goto label_75_0
                    end

                    SU.hero_gain_xp_from_skill(this, skill)

                    a.ts = store.tick_ts

                    for i = 1, a.count do
                        local angle = d2r(360 * i / a.count)
                        local o = V.v(V.rotate(angle, a.initial_pos.x, a.initial_pos.y))
                        local r = V.v(V.rotate(angle, a.initial_rally.x, a.initial_rally.y))
                        local e = E:create_entity(a.entity)
                        local rx, ry = this.pos.x + r.x, this.pos.y + r.y

                        e.nav_rally.center = V.v(rx, ry)
                        e.nav_rally.pos = V.v(rx, ry)
                        e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
                        e.tween.ts = store.tick_ts
                        e.tween.props[1].keys[1][2].x = -o.x
                        e.tween.props[1].keys[1][2].y = -o.y
                        e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                        e.owner = this

                        queue_insert(store, e)
                    end

                    if not U.y_animation_wait(this) then
                        goto label_75_0
                    end
                end

                skill = this.hero.skills.arcane_rain
                a = this.timed_attacks.list[2]

                if ready_to_use_skill(a, store) then
                    local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not target then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        S:queue(a.sound)

                        local flip = target.pos.x < this.pos.x

                        U.animation_start(this, a.animation, flip, store.tick_ts)

                        if U.y_wait(store, a.cast_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            goto label_75_0
                        end

                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts

                        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

                        if #target.enemy.blockers == 0 and P:is_node_valid(pi, ni + 5) then
                            ni = ni + 5
                        end

                        local pos = P:node_pos(pi, spi, ni)
                        local e = E:create_entity(a.entity)

                        e.pos = pos
                        e.damage_factor = this.unit.damage_factor
                        e.render.sprites[1].scale = V.v(1, 1)
                        queue_insert(store, e)

                        if not U.y_animation_wait(this) then
                            goto label_75_0
                        end
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_ranged_attacks(store, this)

                    if brk then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end
            ::label_75_0::
            coroutine.yield()
        end
    end
}
-- 格劳尔-巨石
scripts.giant_boulder = {
    insert = function(this, store, script)
        if not scripts.bomb.insert(this, store, script) then
            return false
        end

        local b = this.bullet
        local target = store.entities[b.target_id]

        if not target then
            return false
        end

        if target.unit and target.unit.hit_offset then
            b.hit_fx_sort_y_offset = -1 - target.unit.hit_offset.y

            if target.unit.hit_offset.y > 23 then
                b.hit_decal = nil
            end
        end

        return true
    end
}
-- 格劳尔-岩晶肘击
scripts.mod_giant_massivedamage = {
    insert = function(this, store, script)
        local m = this.modifier
        local source = store.entities[m.source_id]
        local target = store.entities[m.target_id]

        if not source or not target or target.health.dead then
            return false
        end

        this.pos = V.vclone(target.pos)

        local s = this.render.sprites[1]

        s.name = s.name .. "_" .. s.size_names[target.unit.size]
        s.anchor.y = s.size_anchors_y[target.unit.size]
        s.flip_x = source.render.sprites[1].flip_x
        s.ts = store.tick_ts

        local d = E:create_entity("damage")

        d.source_id = this.id
        d.target_id = target.id
        d.damage_type = DAMAGE_TRUE
        d.value = source.unit.damage_factor * (math.random(this.damage_min, this.damage_max) + source.damage_buff)

        local predicted_damage = d.value * target.health.damage_factor

        if math.random() < this.instakill_chance then
            if (band(target.vis.flags, F_BOSS) ~= 0) or target.health.hp - predicted_damage > this.instakill_min_hp then
                d.value = d.value * 2
            else
                d.damage_type = DAMAGE_INSTAKILL
            end
        end

        queue_damage(store, d)

        return true
    end
}
-- 格劳尔-堡垒
scripts.aura_giant_bastion = {
    update = function(this, store, script)
        local hero = store.entities[this.aura.source_id]

        this.pos = hero.pos

        local enabled = false
        local added_damage = 0
        local attack = hero.melee.attacks[1]
        local last_tick = store.tick_ts
        local last_pos = V.vclone(this.pos)
        local s = this.render.sprites[1]

        local function add_damage(value)
            SU.damage_inc(hero, value)
            added_damage = added_damage + value
        end

        while true do
            local rally_pos = hero.nav_rally.pos

            if enabled then
                if hero.health.dead then
                    enabled = false
                    add_damage(-added_damage)
                    added_damage = 0
                elseif V.dist2(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) > this.max_distance * this.max_distance and
                    store.tick_ts - last_tick > this.tick_time then
                    add_damage(-this.damage_per_tick)
                    last_tick = store.tick_ts
                elseif added_damage < this.max_damage and store.tick_ts - last_tick > this.tick_time then
                    add_damage(this.damage_per_tick)
                    last_tick = store.tick_ts
                end
            elseif not hero.health.dead and V.dist(rally_pos.x, rally_pos.y, hero.pos.x, hero.pos.y) < this.max_distance then
                enabled = true
                added_damage = 0
                last_tick = store.tick_ts
            end

            s.hidden = added_damage == 0

            local new_scale

            new_scale = added_damage >= this.max_damage and 1 or added_damage > 0 and 0.5 or 0

            if new_scale ~= s.scale.x then
                s.ts = store.tick_ts
                s.scale.x, s.scale.y = new_scale, new_scale
            end
            coroutine.yield()
        end
    end
}
-- 格劳尔
scripts.hero_giant = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "boulderthrow", function(this, s)
            this.ranged.attacks[1].disabled = nil
            local b = E:get_template(this.ranged.attacks[1].bullet)
            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "stomp", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage = s.damage[s.level]
            a.loops = s.loops[s.level]
            local stun = E:get_template("mod_giant_stun")
            stun.modifier.duration = s.stun_duration[s.level]
        end)

        upgrade_skill(this, "bastion", function(this, s)
            local a = E:get_template(this.auras.list[1].name)
            a.damage_per_tick = s.damage_per_tick[s.level]
            a.max_damage = s.max_damage[s.level]

            local aura_baston_key = table.find(store.auras, function(k, v)
                return v.template_name == this.auras.list[1].name
            end)

            if (aura_baston_key) then
                local aura_baston = store.entities[aura_baston_key]
                aura_baston.damage_per_tick = s.damage_per_tick[s.level]
                aura_baston.max_damage = s.max_damage[s.level]
            end
        end)

        upgrade_skill(this, "hardrock", function(this, s)
            this.hardrock_extra_hp = s.extra_hp[s.level]
            this.health.damage_block = s.damage_block[s.level]
        end)

        this.health.hp_max = this.health.hp_max + this.hardrock_extra_hp
        update_regen(this)

        upgrade_skill(this, "massivedamage", function(this, s)
            this.melee.attacks[2].disabled = nil
            local mod = E:get_template(this.melee.attacks[2].mod)
            mod.instakill_chance = s.chance[s.level]
            mod.instakill_min_hp = this.health.hp_max / s.health_factor
            mod.damage_min = ls.melee_damage_min[hl] + s.extra_damage[s.level]
            mod.damage_max = ls.melee_damage_max[hl] + s.extra_damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,

    insert = function(this, store, script)
        this.hero.fn_level_up(this, store)

        this.melee.order = U.attack_order(this.melee.attacks)
        this.ranged.order = U.attack_order(this.ranged.attacks)

        local e = E:create_entity(this.auras.list[1].name)
        e.aura.source_id = this.id
        queue_insert(store, e)

        return true
    end,

    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function do_stomp(attack, targets)
            if not targets then
                return
            end

            for _, t in pairs(targets) do
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = t.id
                d.value = (attack.damage + this.damage_buff) * this.unit.damage_factor
                d.damage_type = attack.damage_type

                queue_damage(store, d)

                local m = E:create_entity("mod_giant_slow")
                m.modifier.source_id = this
                m.modifier.target_id = t.id
                queue_insert(store, m)
            end

            local stun_targets = table.filter(targets, function(k, v)
                return v.vis and band(v.vis.bans, attack.stun_vis_flags) == 0 and
                           band(v.vis.flags, attack.stun_vis_bans) == 0
            end)

            if #stun_targets > 0 and math.random() < attack.stun_chance then
                local t = table.random(stun_targets)
                local m = E:create_entity("mod_giant_stun")
                m.modifier.source_id = this
                m.modifier.target_id = t.id
                queue_insert(store, m)
            end
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_HOST, DAMAGE_EAT)) == 0 then
                    this.unit.hide_after_death = true

                    local remains = E:create_entity("giant_death_remains")

                    remains.pos.x, remains.pos.y = this.pos.x, this.pos.y
                    remains.render.sprites[1].ts = store.tick_ts
                    remains.render.sprites[2].ts = store.tick_ts

                    queue_insert(store, remains)
                end

                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_306_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.stomp

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets then
                        -- block empty
                    else
                        local targets_hp = table.map(targets, function(k, v)
                            return v.health and v.health.hp or 0
                        end)
                        local max_target_hp_idx, max_target_hp = table.maxv(targets_hp)

                        if #targets < a.trigger_min_enemies and max_target_hp < a.trigger_min_hp then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            for i = 1, a.loops do
                                if this.health.dead or this.nav_rally.new then
                                    break
                                end

                                local flip_sign = this.render.sprites[1].flip_x and -1 or 1
                                local start_ts = store.tick_ts
                                local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                                    a.damage_flags, a.damage_bans)

                                S:queue("HeroGiantStomp")
                                U.animation_start(this, "stomp", nil, store.tick_ts, false)

                                while store.tick_ts - start_ts < a.hit_times[1] do
                                    coroutine.yield()
                                end

                                do_stomp(a, targets)

                                local fx = E:create_entity("giant_stomp_decal")

                                fx.pos = V.v(this.pos.x - 20 * flip_sign, this.pos.y - 2)
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)

                                while store.tick_ts - start_ts < a.hit_times[2] do
                                    coroutine.yield()
                                end

                                do_stomp(a, targets)

                                local fx = E:create_entity("giant_stomp_decal")

                                fx.pos = V.v(this.pos.x + 19 * flip_sign, this.pos.y + 5)
                                fx.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, fx)
                                U.y_animation_wait(this)
                            end

                            goto label_306_0
                        end
                    end
                end

                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    -- block empty
                else
                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_306_0::

            coroutine.yield()
        end
    end,

    on_damage = function(this, store, damage)
        damage.value = damage.value - this.health.damage_block
        damage.value = math.max(0, damage.value)
        return true
    end
}
-- 骨龙
scripts.hero_dracolich = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local b = E:get_template("fireball_dracolich")

        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        local m = E:get_template("mod_dracolich_disease")

        m.dps.damage_min = ls.disease_damage[hl]
        m.dps.damage_max = ls.disease_damage[hl]

        upgrade_skill(this, "spinerain", function(this, s)
            this.timed_attacks.list[2].disabled = nil
            b = E:get_template("dracolich_spine")
            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "bonegolem", function(this, s)
            this.timed_attacks.list[1].disabled = nil
            local g = E:get_template("soldier_dracolich_golem")
            g.health.hp_max = s.hp_max[s.level]
            g.reinforcement.duration = s.duration[s.level]
            g.melee.attacks[1].damage_max = s.damage_max[s.level]
            g.melee.attacks[1].damage_min = s.damage_min[s.level]
        end)

        upgrade_skill(this, "plaguecarrier", function(this, s)
            this.timed_attacks.list[4].disabled = nil
            this.timed_attacks.list[4].count = s.count[s.level]
            local a = E:get_template("dracolich_plague_carrier")
            a.aura.duration = s.duration[s.level]
            E:get_template("dracolich_spine").bullet.mod = "mod_dracolich_disease"
            E:get_template("fireball_dracolich").bullet.mod = "mod_dracolich_disease"
        end)

        upgrade_skill(this, "diseasenova", function(this, s)
            local a = this.timed_attacks.list[3]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "unstabledisease", function(this, s)
            local m = E:get_template("mod_dracolich_disease")
            m.spread_damage = s.spread_damage[s.level]
            m.spread_active = true
        end)

        this.health.hp = this.health.hp_max
    end
}
function scripts.hero_dracolich.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_dracolich.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, force_idle_ts

    local function skeleton_glow_fx()
        local fx = E:create_entity("fx_dracolich_skeleton_glow")

        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x
        fx.render.sprites[1].anchor.y = this.render.sprites[1].anchor.y

        queue_insert(store, fx)
    end

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false
    force_idle_ts = true

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)

            force_idle_ts = true
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end

        a = this.timed_attacks.list[1]
        skill = this.hero.skills.bonegolem

        if not a.disabled and store.tick_ts - a.ts > a.cooldown then
            local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range * 1.5, a.vis_flags,
                a.vis_bans, function(v)
                    local offset = P:predict_enemy_node_advance(v, a.spawn_time)
                    local ppos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + offset)

                    return P:is_node_valid(v.nav_path.pi, v.nav_path.ni + offset, NF_RALLY) and
                               GR:cell_is_only(ppos.x, ppos.y, TERRAIN_LAND)
                end)
            local spawn_pos

            if target then
                local offset = P:predict_enemy_node_advance(target, a.spawn_time)

                spawn_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + offset)
            else
                local positions = P:get_all_valid_pos(this.pos.x, this.pos.y, a.min_range, a.max_range, TERRAIN_LAND,
                    nil, NF_RALLY)

                spawn_pos = table.random(positions)
            end

            if not spawn_pos then
                SU.delay_attack(store, a, 0.4)
            else
                S:queue(a.sound)
                U.animation_start(this, "golem", nil, store.tick_ts)
                skeleton_glow_fx()
                U.y_wait(store, a.spawn_time)

                local e = E:create_entity(a.entity)

                e.pos = V.vclone(spawn_pos)
                e.nav_rally.pos = V.vclone(spawn_pos)
                e.nav_rally.center = V.vclone(spawn_pos)
                e.render.sprites[1].flip_x = math.random() < 0.5

                queue_insert(store, e)

                e.owner = this

                U.y_animation_wait(this)

                force_idle_ts = true
                a.ts = store.tick_ts

                SU.hero_gain_xp_from_skill(this, skill)

                goto label_407_1
            end
        end

        a = this.timed_attacks.list[2]
        skill = this.hero.skills.spinerain

        if not a.disabled and store.tick_ts - a.ts > a.cooldown then
            local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                a.vis_bans)

            if not target then
                SU.delay_attack(store, a, 0.4)
            else
                local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
                local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

                if #nodes < 1 then
                    SU.delay_attack(store, a, 0.4)
                else
                    local s_pi, s_spi, s_ni = unpack(nodes[1])
                    local flip = target.pos.x < this.pos.x

                    U.animation_start(this, "spinerain", flip, store.tick_ts)
                    skeleton_glow_fx()
                    U.y_wait(store, a.spawn_time)

                    local delay = 0
                    local n_step = ni < s_ni and -2 or 2

                    ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

                    for i = 1, skill.count[skill.level] do
                        local e = E:create_entity(a.entity)

                        e.pos = P:node_pos(pi, spi, ni)
                        e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
                        e.render.sprites[1].flip_x = not flip
                        e.delay = delay
                        e.bullet.source_id = this.id

                        queue_insert(store, e)

                        delay = delay + fts(U.frandom(1, 3))
                        ni = ni + n_step
                        spi = km.zmod(spi + math.random(1, 2), 3)
                    end

                    U.y_animation_wait(this)

                    force_idle_ts = true
                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, skill)

                    goto label_407_1
                end
            end
        end

        a = this.timed_attacks.list[3]
        skill = this.hero.skills.diseasenova

        if not a.disabled and store.tick_ts - a.ts > a.cooldown then
            local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                a.vis_bans)

            if not targets or #targets < a.min_count then
                SU.delay_attack(store, a, 0.4)
            else
                local start_ts = store.tick_ts

                this.health_bar.hidden = true
                this.health.ignore_damage = true

                U.animation_start(this, "nova", nil, store.tick_ts)
                S:queue(a.sound, {
                    delay = fts(10)
                })
                U.y_wait(store, a.hit_time)

                for _, target in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.damage_type = a.damage_type
                    d.source_id = this.id
                    d.target_id = target.id
                    d.value = math.random(a.damage_min, a.damage_max)

                    queue_damage(store, d)

                    if a.mod then
                        local m = E:create_entity(a.mod)

                        m.modifier.source_id = this.id
                        m.modifier.target_id = target.id
                        m.modifier.xp_dest_id = this.id

                        queue_insert(store, m)
                    end
                end

                local fi, fo = 10, 35

                for i = 1, 6 do
                    local rx, ry = V.rotate(2 * math.pi * i / 6, 1, 0)
                    local fx = E:create_entity("fx_dracolich_nova_cloud")

                    fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                    fx.tween.props[2].keys = {{0, V.v(rx * fi, ry * fi)}, {fts(20), V.v(rx * fo, ry * fo)}}
                    fx.tween.ts = store.tick_ts

                    queue_insert(store, fx)
                end

                local fx = E:create_entity("fx_dracolich_nova_explosion")

                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)

                local fx = E:create_entity("fx_dracolich_nova_decal")

                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
                U.y_animation_wait(this)

                this.render.sprites[1].hidden = true

                U.y_wait(store, a.respawn_delay)

                this.render.sprites[1].hidden = nil

                S:queue(a.respawn_sound)
                U.y_animation_play(this, "respawn", nil, store.tick_ts)

                this.health_bar.hidden = false
                this.health.ignore_damage = false
                force_idle_ts = true
                a.ts = store.tick_ts

                SU.hero_gain_xp_from_skill(this, skill)
            end
        end

        a = this.timed_attacks.list[4]
        skill = this.hero.skills.plaguecarrier

        if not a.disabled and store.tick_ts - a.ts > a.cooldown then
            local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max,
                nil, a.vis_flags, a.vis_bans)

            if not targets_info then
                SU.delay_attack(store, a, 0.4)
            else
                local target

                for _, ti in pairs(targets_info) do
                    if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
                        target = ti.enemy

                        break
                    end
                end

                if not target then
                    SU.delay_attack(store, a, 0.4)
                else
                    local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
                    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {pi}, nil, nil, NF_RALLY)

                    if #nodes < 1 then
                        SU.delay_attack(store, a, 0.4)
                    else
                        local s_pi, s_spi, s_ni = unpack(nodes[1])
                        local dir = ni < s_ni and -1 or 1
                        local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

                        s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

                        local flip = P:node_pos(s_pi, s_spi, s_ni, true).x < this.pos.x

                        S:queue(a.sound)
                        U.animation_start(this, "plague", flip, store.tick_ts)
                        U.y_wait(store, a.spawn_time)

                        local delay = 0

                        for i = 1, a.count do
                            local e = E:create_entity(a.entity)

                            e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x,
                                this.pos.y + a.spawn_offset.y
                            e.nav_path.pi = s_pi
                            e.nav_path.spi = math.random(1, 3)
                            e.nav_path.ni = s_ni
                            e.nav_path.dir = dir
                            e.delay = delay
                            e.aura.source_id = this.id

                            queue_insert(store, e)

                            delay = delay + fts(U.frandom(1, 3))
                        end

                        U.y_animation_wait(this)

                        force_idle_ts = true
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        goto label_407_1
                    end
                end
            end
        end

        for _, i in pairs(this.ranged.order) do
            local a = this.ranged.attacks[i]

            if a.disabled then
                -- block empty
            elseif a.sync_animation and not this.render.sprites[1].sync_flag then
                -- block empty
            elseif store.tick_ts - a.ts < a.cooldown then
                -- block empty
            elseif math.random() > a.chance then
                -- block empty
            else
                local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
                local bullet_t = E:get_template(a.bullet)
                local bullet_speed = bullet_t.bullet.min_speed
                local flight_time = bullet_t.bullet.flight_time
                local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if target then
                    local start_ts = store.tick_ts
                    local b, emit_fx, emit_ps, emit_ts
                    local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)
                    local node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
                    local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
                    local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                    U.animation_start(this, an, af, store.tick_ts)

                    while store.tick_ts - start_ts < a.shoot_time do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_407_0
                        end

                        coroutine.yield()
                    end

                    S:queue(a.sound)

                    b = E:create_entity(a.bullet)
                    b.bullet.target_id = target.id
                    b.bullet.source_id = this.id
                    b.pos = V.vclone(this.pos)
                    b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
                    b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.v(t_pos.x, t_pos.y)

                    queue_insert(store, b)

                    a.ts = start_ts

                    while not U.animation_finished(this) do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_407_0
                        end

                        coroutine.yield()
                    end

                    force_idle_ts = true

                    ::label_407_0::

                    goto label_407_1
                elseif i == 1 and this.motion.arrived then
                    U.y_wait(store, this.soldier.guard_time)
                end
            end
        end

        SU.soldier_idle(store, this, force_idle_ts)
        SU.soldier_regen(store, this)

        force_idle_ts = nil

        ::label_407_1::

        coroutine.yield()
    end
end

-- 黑棘船长
scripts.hero_pirate = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)
        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "swordsmanship", function(this, s)
            this.swordsmanship_extra = s.extra_damage[s.level]
        end)

        upgrade_skill(this, "looting", function(this, s)
            local m = E:get_template("mod_pirate_loot")
            m.percent = s.percent[s.level]
        end)

        upgrade_skill(this, "kraken", function(this, s)
            this.timed_attacks.list[1].disabled = nil
            local ka = E:get_template("kraken_aura")
            ka.max_active_targets = s.max_enemies[s.level]
            local m = E:get_template("mod_slow_kraken")
            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "scattershot", function(this, s)
            this.timed_attacks.list[2].disabled = nil
            local b = E:get_template("pirate_exploding_barrel")
            b.fragments = s.fragments[s.level]
            local bf = E:get_template("barrel_fragment")
            bf.bullet.damage_min = s.fragment_damage[s.level]
            bf.bullet.damage_max = bf.bullet.damage_min
        end)

        upgrade_skill(this, "toughness", function(this, s)
            this.toughness_extra_hp = s.hp_max[s.level]
        end)

        this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + this.swordsmanship_extra
        this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + this.swordsmanship_extra

        this.health.hp_max = this.health.hp_max + this.toughness_extra_hp
        update_regen(this)

        this.health.hp = this.health.hp_max
    end
}
-- 冰女
scripts.hero_elora = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        for i = 1, 2 do
            local bt = E:get_template(this.ranged.attacks[i].bullet)
            bt.bullet.damage_min = ls.ranged_damage_min[hl]
            bt.bullet.damage_max = ls.ranged_damage_max[hl]
        end

        upgrade_skill(this, "chill", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            a.max_range = s.max_range[s.level]
            a.count = s.count[s.level]
            local b = E:get_template(a.bullet)
            b.aura.level = s.level
            local m = E:get_template("mod_elora_chill")
            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "ice_storm", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.count = s.count[s.level]
            a.max_range = s.max_range[s.level]
            local b = E:get_template(a.bullet)
            b.bullet.damage_min = s.damage_min[s.level]
            b.bullet.damage_max = s.damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 钢锯
scripts.hero_hacksaw = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "sawblade", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil
            local b = E:get_template(a.bullet)
            b.bounces_max = s.bounces[s.level]
        end)
        upgrade_skill(this, "timber", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.cooldown = s.cooldown[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 英格瓦
scripts.hero_ingvar = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl] * 1.2
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl] * 1.2

        upgrade_skill(this, "ancestors_call", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.count = s.count[s.level]
            local e = E:get_template(a.entity)
            e.health.hp_max = s.hp_max[s.level]
            e.melee.attacks[1].damage_min = s.damage_min[s.level]
            e.melee.attacks[1].damage_max = s.damage_max[s.level]
            e.motion.max_speed = s.max_speed[s.level]
        end)

        upgrade_skill(this, "bear", function(this, s)
            local a = this.timed_attacks.list[2]
            a.duration = s.duration[s.level]
            a.disabled = nil
            local a = this.melee.attacks[3]
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    get_info = function(this)
        local info = scripts.soldier_barrack.get_info(this)
        if this.is_bear then
            info.ranged_damage_max = nil
            info.ranged_damage_min = nil
            info.ranged_damage_type = nil
            info.damage_min = (this.melee.attacks[3].damage_min + this.damage_buff) * this.unit.damage_factor
            info.damage_max = (this.melee.attacks[3].damage_max + this.damage_buff) * this.unit.damage_factor
            info.damage_type = this.melee.attacks[3].damage_type
        end
        return info
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local ba = this.timed_attacks.list[2]
        local a, skill, brk, sta

        local function go_bear()
            this.sound_events.change_rally_point = this.sound_events.change_rally_point_bear

            for i = 1, 2 do
                this.melee.attacks[i].disabled = true
            end

            this.melee.attacks[3].disabled = false
            this.health.immune_to = ba.immune_to

            S:queue(ba.sound)
            U.y_animation_play(this, "toBear", nil, store.tick_ts, 1)

            this.render.sprites[1].prefix = "hero_ingvar_bear"
            ba.ts = store.tick_ts
            this.is_bear = true
        end

        local function go_viking()
            this.sound_events.change_rally_point = this.sound_events.change_rally_point_viking

            for i = 1, 2 do
                this.melee.attacks[i].disabled = false
            end

            this.melee.attacks[3].disabled = true

            this.is_bear = false
            U.y_animation_play(this, "toViking", nil, store.tick_ts, 1)

            this.render.sprites[1].prefix = "hero_ingvar"

            this.health.immune_to = DAMAGE_NONE

            ba.ts = store.tick_ts
        end

        for _, an in pairs(this.auras.list) do
            local aura = E:create_entity(an.name)
            aura.aura.source_id = this.id
            queue_insert(store, aura)
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                if this.is_bear then
                    go_viking()
                end

                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_67_0
                    end
                end

                if SU.hero_level_up(store, this) and not this.is_bear then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = ba
                skill = this.hero.skills.bear

                if not this.is_bear and ready_to_use_skill(a, store) and this.health.hp < this.health.hp_max *
                    a.transform_health_factor then
                    SU.hero_gain_xp_from_skill(this, skill)
                    go_bear()
                elseif this.is_bear and store.tick_ts - a.ts >= a.duration then
                    go_viking()
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.ancestors_call

                if ready_to_use_skill(a, store) then
                    if this.is_bear then
                        local compensation = ba.duration - (store.tick_ts - ba.ts)
                        go_viking()
                        ba.ts = ba.ts - compensation
                    end
                    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, nil, NF_RALLY)

                    if #nodes < 1 then
                        SU.delay_attack(store, a, 0.4)
                    else
                        U.animation_start(this, a.animation, nil, store.tick_ts, 1)
                        S:queue(a.sound, a.sound_args)

                        if SU.y_hero_wait(store, this, a.cast_time) then
                            goto label_67_0
                        end

                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts

                        local pi, spi, ni = unpack(nodes[1])
                        local no_min, no_max = unpack(a.nodes_offset)
                        local no

                        for i = 1, a.count do
                            local e = E:create_entity(a.entity)
                            local e_spi, e_ni = math.random(1, 3), ni

                            no = math.random(no_min, no_max) * U.random_sign()

                            if P:is_node_valid(pi, e_ni + no) then
                                e_ni = e_ni + no
                            end

                            e.nav_rally.center = P:node_pos(pi, e_spi, e_ni)
                            e.nav_rally.pos = V.vclone(e.nav_rally.center)
                            e.pos = V.vclone(e.nav_rally.center)
                            e.render.sprites[1].name = "raise"
                            e.owner = this

                            queue_insert(store, e)
                        end

                        SU.y_hero_animation_wait(this)

                        goto label_67_0
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_67_0::

            coroutine.yield()
        end
    end
}
-- 火男
scripts.hero_ignus = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
        if hl == 2 then
            this.melee.attacks[2].mod = "mod_ignus_burn_1"
            this.melee.attacks[2].chance = 0.4
        elseif hl == 5 then
            this.melee.attacks[2].mod = "mod_ignus_burn_2"
            this.melee.attacks[2].chance = 0.5
        elseif hl == 8 then
            this.melee.attacks[2].mod = "mod_ignus_burn_3"
            this.melee.attacks[2].chance = 0.6
        end

        upgrade_skill(this, "flaming_frenzy", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "surge_of_flame", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local aura = E:get_template("aura_ignus_surge_of_flame")
            aura.aura.damage_min = s.damage_min[s.level]
            aura.aura.damage_max = s.damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta, target, attack_done

        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        local aura = E:create_entity(this.particles_aura)

        aura.aura.source_id = this.id

        queue_insert(store, aura)

        local ps = E:create_entity(this.run_particles_name)

        ps.particle_system.track_id = this.id
        ps.particle_system.emit = false

        queue_insert(store, ps)

        local function apply_fire(target)
            local m = E:create_entity(this.melee.attacks[2].mod)
            m.modifier.source_id = this.id
            m.modifier.target_id = target.id
            m.modifier.damage_factor = this.unit.damage_factor
            queue_insert(store, m)
        end
        while true do
            ps.particle_system.emit = false

            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    ps.particle_system.emit = true

                    if SU.y_hero_new_rally(store, this) then
                        goto label_71_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or h.dead then
                    -- block empty
                else
                    a = this.timed_attacks.list[2]
                    skill = this.hero.skills.surge_of_flame

                    if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
                        local function find_surge_target()
                            return U.find_first_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                                a.vis_bans, function(e)
                                    if not e.nav_path or not e.nav_path.pi then
                                        return false
                                    end

                                    local ps, pe = P:get_visible_start_node(e.nav_path.pi),
                                        P:get_visible_end_node(e.nav_path.pi)

                                    return (#e.enemy.blockers or 0) == 0 and e.nav_path.ni > ps + a.nodes_margin and
                                               e.nav_path.ni < pe - a.nodes_margin
                                end)
                        end
                        local target = find_surge_target()

                        if not target then
                            -- block empty
                        else
                            local vis_bans = this.vis.bans
                            local function surge(target)
                                U.unblock_target(store, this)
                                U.block_enemy(store, this, target)
                                SU.hero_gain_xp_from_skill(this, skill)

                                local slot_pos, slot_flip = U.melee_slot_position(this, target, 1)

                                this.vis.bans = F_ALL
                                this.health.ignore_damage = true
                                U.speed_mul(this, a.speed_factor)
                                U.set_destination(this, slot_pos)
                                S:queue(a.sound)
                                U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

                                local aura = E:create_entity(a.aura)

                                aura.aura.source_id = this.id
                                aura.aura.damage_factor = this.unit.damage_factor
                                queue_insert(store, aura)

                                while not this.motion.arrived do
                                    U.walk(this, store.tick_length, nil, true)
                                    coroutine.yield()
                                end
                                apply_fire(target)
                                this.nav_rally.center = V.vclone(this.pos)
                                this.nav_rally.pos = V.vclone(this.pos)
                                U.speed_div(this, a.speed_factor)
                            end
                            local function surge_end()
                                S:queue(a.sound_end)
                                U.y_animation_play(this, a.animations[2], nil, store.tick_ts)

                                a.ts = store.tick_ts
                                this.vis.bans = vis_bans
                                this.health.ignore_damage = nil
                            end

                            local last_target_id = this.soldier.target_id
                            surge(target)
                            target = store.entities[last_target_id]
                            if skill.level > 2 then
                                if target and not target.health.dead then
                                    surge(target)
                                end
                                while target and target.health.dead do
                                    target = find_surge_target()
                                    if not target then
                                        break
                                    end
                                    surge(target)
                                end
                            end
                            surge_end()
                            goto label_71_0
                        end
                    end

                    a = this.timed_attacks.list[1]
                    skill = this.hero.skills.flaming_frenzy

                    if sta ~= A_NO_TARGET and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
                        if U.frandom(0, 1) >= a.chance then
                            goto label_71_0
                        end

                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                            a.vis_bans)

                        if not targets then
                            -- block empty
                        else
                            local start_ts = store.tick_ts
                            local flip = targets[1].pos.x < this.pos.x

                            U.animation_start(this, a.animation, flip, store.tick_ts)
                            S:queue(a.sound)

                            if U.y_wait(store, a.cast_time, function()
                                return SU.hero_interrupted(this)
                            end) then
                                goto label_71_0
                            end

                            SU.hero_gain_xp_from_skill(this, skill)

                            a.ts = start_ts
                            targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                                a.vis_bans)

                            if targets then
                                for _, t in pairs(targets) do
                                    local fx = E:create_entity(a.hit_fx)

                                    fx.pos = V.vclone(t.pos)

                                    if t.unit and t.unit.mod_offset then
                                        fx.pos.x, fx.pos.y = fx.pos.x + t.unit.mod_offset.x,
                                            fx.pos.y + t.unit.mod_offset.y
                                    end

                                    for i = 1, #fx.render.sprites do
                                        fx.render.sprites[i].ts = store.tick_ts
                                    end

                                    queue_insert(store, fx)

                                    local d = E:create_entity("damage")

                                    d.damage_type = a.damage_type
                                    d.source_id = this.id
                                    d.target_id = t.id
                                    d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) *
                                                  this.unit.damage_factor

                                    queue_damage(store, d)

                                    if math.random() < this.melee.attacks[2].chance * 0.5 then
                                        apply_fire(t)
                                    end
                                end
                            end

                            scripts.heal(this, this.health.hp_max * a.heal_factor)

                            local e = E:create_entity(a.decal)

                            e.pos = V.vclone(this.pos)
                            e.render.sprites[1].ts = store.tick_ts

                            queue_insert(store, e)

                            if not U.y_animation_wait(this) then
                                -- block empty
                            end

                            goto label_71_0
                        end
                    end

                    if sta ~= A_NO_TARGET then
                        -- block empty
                    elseif SU.soldier_go_back_step(store, this) then
                        -- block empty
                    else
                        SU.soldier_idle(store, this)
                        SU.soldier_regen(store, this)
                    end
                end
            end

            ::label_71_0::

            coroutine.yield()
        end
    end
}
scripts.aura_oni_rage = {
    update = function(this, store, script)
        local hero = store.entities[this.aura.source_id]
        this.pos = hero.pos
        local s = this.render.sprites[1]
        while true do
            local scale = 0
            local rate = hero.health.hp / hero.health.hp_max

            if rate < 0.2 then
                scale = 1
            elseif rate < 0.4 then
                scale = 0.7
            elseif rate < 0.6 then
                scale = 0.4
            elseif rate < 0.8 then
                scale = 0.1
            end
            if hero.health.dead then
                scale = 0
            end
            if scale ~= s.scale.x then
                s.ts = store.tick_ts
                s.scale.x, s.scale.y = scale, scale
            end
            s.hidden = scale == 0
            coroutine.yield()
        end
    end
}
-- 鬼侍
scripts.hero_oni = {
    insert = function(this, store, script)
        this.hero.fn_level_up(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        local e = E:create_entity("aura_oni_rage")
        e.aura.source_id = this.id
        queue_insert(store, e)
        return true
    end,
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "death_strike", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.chance = s.chance[s.level]
            a = this.melee.attacks[3]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
        end)

        upgrade_skill(this, "torment", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage_min = s.min_damage[s.level]
            a.damage_max = s.max_damage[s.level]
        end)

        upgrade_skill(this, "rage", function(this, s)
            this.rage_max = s.rage_max[s.level]
            this.unyield_max = s.unyield_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    on_damage = function(this, store, damage)
        if this.timed_attacks.list[1].ts then
            this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 1
        end
        if this.melee.attacks[2].ts then
            this.melee.attacks[2].ts = this.melee.attacks[2].ts - 0.5
        end
        if this.melee.attacks[3].ts then
            this.melee.attacks[3].ts = this.melee.attacks[3].ts - 0.5
        end
        if this.melee.attacks[1].ts then
            this.melee.attacks[1].ts = this.melee.attacks[1].ts - 0.1
        end
        return true
    end,

    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        local function spawn_swords(count, center, radius, angle, delay)
            for i = 1, count do
                local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
                local e = E:create_entity("decal_oni_torment_sword")

                e.pos.x, e.pos.y = p.x, p.y
                e.delay = delay

                queue_insert(store, e)
            end
        end

        U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            local rate = (this.health.hp_max - this.health.hp) / this.health.hp_max
            local rage = rate * this.rage_max
            this.damage_buff = this.damage_buff - this.rage + rage
            this.rage = rage

            local unyield = rate * this.unyield_max
            this.health.damage_factor = this.health.damage_factor + this.unyield - unyield
            this.unyield = unyield

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_83_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelUp", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.torment

                if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                    local triggers = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                        a.vis_bans)

                    if not triggers or #triggers < a.min_count then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        local start_ts = store.tick_ts
                        local af = triggers[1].pos.x < this.pos.x

                        U.animation_start(this, a.animation, af, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            goto label_83_0
                        end

                        S:queue(a.sound_hit)

                        a.ts = start_ts

                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                            a.vis_flags, a.vis_bans)

                        if not targets then
                            SU.delay_attack(store, a, 0.13333333333333333)
                        else
                            SU.hero_gain_xp_from_skill(this, skill)

                            local hit_center = V.vclone(this.pos)

                            for _, s in pairs(a.torment_swords) do
                                local d, r, c = unpack(s)

                                spawn_swords(c, hit_center, r, math.random(0, 2) * math.pi, d)
                            end

                            U.y_wait(store, a.damage_delay)

                            for _, target in pairs(targets) do
                                local d = SU.create_attack_damage(a, target.id, this)

                                if target.is_demon then
                                    d.value = d.value * 1.6
                                end

                                queue_damage(store, d)
                            end

                            SU.y_hero_animation_wait(this)

                            goto label_83_0
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if sta == A_IN_COOLDOWN then
                    U.animation_start(this, "idle", nil, store.tick_ts, true)
                end

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_83_0::

            coroutine.yield()
        end
    end
}
-- 索尔
scripts.hero_thor = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.cooldown = ls.melee_cooldown[hl]
        this.lightning_heal = ls.lightning_heal[hl]
        this.melee.attacks[1].cooldown = ls.melee_cooldown[hl]
        this.melee.attacks[2].cooldown = ls.melee_cooldown[hl]

        upgrade_skill(this, "chainlightning", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.level = s.level
            a.chance = s.chance[s.level]
            local mod = E:get_template(a.mod)
            mod.chainlightning.count = s.count[s.level]
            mod.chainlightning.damage = s.damage_max[s.level]
        end)

        upgrade_skill(this, "thunderclap", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil
            a.level = s.level
            local b = E:get_template(a.bullet)
            local mod = E:get_template(b.bullet.mod)
            mod.thunderclap.damage = s.damage_max[s.level]
            mod.thunderclap.secondary_damage = s.secondary_damage_max[s.level]
            mod.thunderclap.stun_duration_max = s.stun_duration[s.level]
            mod.thunderclap.max_range = s.max_range[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 天十
scripts.hero_10yr = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "rain", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            local au = E:get_template(a.entity)
            au.aura.loops = s.loops[s.level]
            local bt = E:get_template(au.aura.entity)
            bt.bullet.damage_min = s.damage_min[s.level]
            bt.bullet.damage_max = s.damage_max[s.level]
            if s.level == 3 then
                bt.scorch_earth = true
            end
        end)

        upgrade_skill(this, "buffed", function(this, s)
            local a = this.timed_attacks.list[2]
            a.duration = s.duration[s.level]
            a.disabled = nil
            local a = this.timed_attacks.list[3]
            a.damage_min = s.bomb_damage_min[s.level]
            a.damage_max = s.bomb_damage_max[s.level]
            if s.level == 3 then
                a.sound = a.sound_long
            end
            local au = E:get_template(a.hit_aura)
            au.aura.steps = s.bomb_steps[s.level]
            au.aura.damage_min = s.bomb_step_damage_min[s.level]
            au.aura.damage_max = s.bomb_step_damage_max[s.level]
            local a = this.melee.attacks[3]
            a.damage_min = s.spin_damage_min[s.level]
            a.damage_max = s.spin_damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local ra = this.timed_attacks.list[1]
        local ba = this.timed_attacks.list[2]
        local bma = this.timed_attacks.list[3]
        local a, skill, brk, sta

        local function go_buffed()
            this.sound_events.change_rally_point = this.sound_events.change_rally_point_buffed

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
            U.update_max_speed(this, this.motion.max_speed_buffed)
            this.melee.range = this.melee.range_buffed
        end

        local function go_normal()
            this.sound_events.change_rally_point = this.sound_events.change_rally_point_normal

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
            U.update_max_speed(this, this.motion.max_speed_normal)
            this.melee.range = this.melee.range_normal
            ba.ts = store.tick_ts
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        local aura = E:create_entity(this.particles_aura)

        aura.aura.source_id = this.id

        queue_insert(store, aura)

        while true do
            if h.dead then
                if this.is_buffed then
                    go_normal()
                end

                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if this.is_buffed and V.dist2(this.pos.x, this.pos.y, this.nav_rally.pos.x, this.nav_rally.pos.y) >
                        40000 then
                        local compensation = (ba.duration - (store.tick_ts - ba.ts)) / ba.duration * ba.cooldown
                        go_normal()
                        ba.ts = ba.ts - compensation
                    end
                    if SU.y_hero_new_rally(store, this) then
                        goto label_90_1
                    end
                end

                if SU.hero_level_up(store, this) and not this.is_buffed then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = ra
                skill = this.hero.skills.rain

                if ready_to_use_skill(a, store) then
                    local start_ts, bdy, bdt, au
                    local fired_aura = false
                    local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.trigger_range,
                        a.vis_flags, a.vis_bans)

                    if not targets then
                        SU.delay_attack(store, a, 0.2)
                    else
                        if this.is_buffed then
                            local compensation = (ba.duration - (store.tick_ts - ba.ts)) / ba.duration * ba.cooldown
                            go_normal()
                            ba.ts = ba.ts - compensation
                        end
                        S:queue(a.sound_start)
                        U.animation_start(this, a.animations[1], nil, store.tick_ts, false)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                goto label_90_0
                            end

                            coroutine.yield()
                        end

                        start_ts = store.tick_ts

                        U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
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

                            SU.hero_gain_xp_from_skill(this, skill)
                        end

                        S:queue(a.sound_end)
                        U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
                    end
                end

                a = ba
                skill = this.hero.skills.buffed

                if not this.is_buffed and not a.disabled and store.tick_ts - a.ts >= a.cooldown then
                    local targets =
                        U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                    if targets and #targets >= a.min_count then
                        SU.hero_gain_xp_from_skill(this, skill)
                        go_buffed()
                    end
                elseif this.is_buffed and store.tick_ts - a.ts >= a.duration then
                    go_normal()
                end

                a = bma

                if this.is_buffed and store.tick_ts - a.ts >= a.cooldown then
                    local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.min_nodes, a.max_nodes, nil,
                        a.vis_flags, a.vis_bans)

                    if not target_info or #target_info < a.min_count then
                        SU.delay_attack(store, a, 0.2)
                    else
                        local target = target_info[1].enemy

                        if not SU.y_soldier_do_single_area_attack(store, this, target, a) then
                            goto label_90_1
                        end
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_90_1::

            coroutine.yield()
        end
    end
}
scripts.power_fireball_10yr = {
    update = function(this, store, script)
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
            this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                this.pos.y + b.speed.y * store.tick_length
            this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

            if shadow_tracks then
                shadow.pos.x = this.pos.x
            end

            coroutine.yield()
        end

        this.pos.x, this.pos.y = b.to.x, b.to.y
        particle.particle_system.source_lifetime = 0

        local enemies = table.filter(store.enemies, function(k, v)
            return
                not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and
                    U.is_inside_ellipse(v.pos, b.to, b.damage_radius)
        end)
        local damage_value = math.ceil(b.damage_factor * math.random(b.damage_min, b.damage_max))

        for _, enemy in pairs(enemies) do
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
                local scorched = E:create_entity("power_scorched_water")

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
                local scorched = E:create_entity("power_scorched_earth")

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
}

-- 红龙
scripts.hero_dragon = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local b = E:get_template("fireball_dragon")

        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "blazingbreath", function(this, s)
            this.ranged.attacks[2].disabled = nil
            local b = E:get_template("breath_dragon")
            b.bullet.damage_min = s.damage[s.level]
            b.bullet.damage_max = s.damage[s.level]
        end)

        upgrade_skill(this, "feast", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage = s.damage[s.level]
            a.devour_chance = s.devour_chance[s.level]
        end)

        upgrade_skill(this, "fierymist", function(this, s)
            local a = this.ranged.attacks[3]
            a.disabled = nil
            local aura = E:get_template("aura_fierymist_dragon")
            aura.aura.duration = s.duration[s.level]
            local m = E:get_template("mod_slow_fierymist")
            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "wildfirebarrage", function(this, s)
            local a = this.ranged.attacks[4]
            a.disabled = nil
            local b = E:get_template("wildfirebarrage_dragon")
            b.explosions = s.explosions[s.level]
        end)

        upgrade_skill(this, "reignoffire", function(this, s)
            local m = E:get_template("mod_dragon_reign")
            m.dps.damage_min = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
            m.dps.damage_max = s.dps[s.level] * m.dps.damage_every / m.modifier.duration
            local b = E:get_template("fireball_dragon")
            b.bullet.mod = "mod_dragon_reign"
            local b = E:get_template("breath_dragon")
            b.bullet.mod = "mod_dragon_reign"
            local b = E:get_template("wildfirebarrage_dragon")
            b.bullet.mod = "mod_dragon_reign"
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 卢克雷齐娅
scripts.hero_vampiress = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        upgrade_skill(this, "vampirism", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
            local m = E:get_template("mod_vampiress_lifesteal")
            m.heal_hp = s.damage[s.level]
        end)

        upgrade_skill(this, "slayer", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        local gain = E:get_template("mod_vampiress_gain").gain
        this.health.hp_max = this.health.hp_max + this.gain_count * gain.hp
        update_regen(this)
        inc_armor_by_skill(this, this.gain_count * gain.armor)
        inc_magic_armor_by_skill(this, this.gain_count * gain.magic_armor)

        local a = this.melee.attacks[1]
        a.damage_min = ls.melee_damage_min[hl] + this.gain_count * gain.damage
        a.damage_max = ls.melee_damage_max[hl] + this.gain_count * gain.damage

        this.health.hp = this.health.hp_max
    end
}
-- 沙塔
scripts.hero_alien = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "energyglaive", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil
            local b = E:get_template(a.bullet)
            b.bullet.damage_min = s.damage[s.level]
            b.bullet.damage_max = s.damage[s.level]
            b.bounce_chance = s.bounce_chance[s.level]
        end)

        upgrade_skill(this, "purificationprotocol", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local e = E:get_template(a.entity)
            e.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "abduction", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.total_hp = s.total_hp[s.level]
            a.total_targets = s.total_targets[s.level]
        end)

        upgrade_skill(this, "vibroblades", function(this, s)
            local a = this.melee.attacks[1]
            a.damage_min = a.damage_min + s.extra_damage[s.level]
            a.damage_max = a.damage_max + s.extra_damage[s.level]
            a.damage_type = s.damage_type
        end)

        upgrade_skill(this, "finalcountdown", function(this, s)
            this.selfdestruct.disabled = nil
            this.selfdestruct.damage = s.damage[s.level]
        end)

        this.health.hp = this.health.hp_max
        this.ranged.attacks[1].ts = -this.ranged.attacks[1].cooldown
        this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
        this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
    end
}
-- 库绍
scripts.hero_monk = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
        this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "snakestyle", function(this, s)
            local a = this.melee.attacks[4]
            a.disabled = nil
            a.damage_max = s.damage[s.level]
            a.damage_min = s.damage[s.level]
            local m = E:get_template("mod_monk_damage_reduction")
            m.reduction_factor = s.damage_reduction_factor[s.level]
        end)

        upgrade_skill(this, "dragonstyle", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "tigerstyle", function(this, s)
            local a = this.melee.attacks[5]
            a.disabled = nil
            a.damage_max = s.damage[s.level]
            a.damage_min = s.damage[s.level]
        end)
        upgrade_skill(this, "leopardstyle", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            a.damage_max = s.damage_max[s.level]
            a.damage_min = s.damage_min[s.level]
            a.loops = s.loops[s.level]
        end)

        upgrade_skill(this, "cranestyle", function(this, s)
            this.dodge.disabled = nil
            this.dodge.chance = s.chance[s.level]
            this.dodge.damage = s.damage[s.level]
            this.dodge.cooldown = s.cooldown[s.level]
        end)

        this.health.hp = this.health.hp_max
        this.melee.attacks[4].ts = -this.melee.attacks[4].cooldown
        this.melee.attacks[5].ts = -this.melee.attacks[5].cooldown
        this.timed_attacks.list[1].ts = -this.timed_attacks.list[1].cooldown
        this.timed_attacks.list[2].ts = -this.timed_attacks.list[2].cooldown
    end,
    insert = function(this, store, script)
        this.hero.fn_level_up(this, store)
        this.melee.order = {
            [1] = 4,
            [2] = 5,
            [3] = 2,
            [4] = 3,
            [5] = 1
        }
        return true
    end,
    update = function(this, store, script)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                a = this.dodge
                skill = this.hero.skills.cranestyle

                if not a.disabled and a.active then
                    a.active = false

                    local target = store.entities[this.soldier.target_id]

                    if not target or target.health.dead then
                        -- block empty
                    else
                        local vis_bans = this.vis.bans

                        this.vis.bans = F_ALL
                        this.health_bar.hidden = true

                        SU.hide_modifiers(store, this, true)

                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        S:queue(a.sound, {
                            delay = fts(15)
                        })
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.hit_time) then
                            this.vis.bans = vis_bans
                            this.health_bar.hidden = this.health.dead

                            goto label_393_2
                        end

                        local d = E:create_entity("damage")

                        d.source_id = this.id
                        d.target_id = target.id
                        d.value = (a.damage + this.damage_buff) * this.unit.damage_factor
                        d.damage_type = a.damage_type

                        queue_damage(store, d)

                        this.vis.bans = vis_bans
                        this.health_bar.hidden = false

                        SU.show_modifiers(store, this, true)

                        if SU.y_hero_animation_wait(this) then
                            goto label_393_2
                        end
                    end
                end

                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_393_2
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.dragonstyle

                if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                    local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets then
                        SU.delay_attack(store, a, 0.13333333333333333)
                    else
                        local start_ts = store.tick_ts
                        this.health.ignore_damage = true
                        S:queue(a.sound, {
                            delay = fts(5)
                        })

                        local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        while store.tick_ts - start_ts < a.hit_time do
                            if SU.hero_interrupted(this) then
                                this.health.ignore_damage = nil
                                goto label_393_2
                            end

                            coroutine.yield()
                        end

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius, a.damage_flags,
                            a.damage_bans)

                        if targets then
                            for _, t in pairs(targets) do
                                local d = E:create_entity("damage")

                                d.source_id = this.id
                                d.target_id = t.id
                                d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) *
                                              this.unit.damage_factor
                                d.damage_type = a.damage_type

                                queue_damage(store, d)
                            end
                        end

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                break
                            end

                            coroutine.yield()
                        end
                        this.health.ignore_damage = nil
                        goto label_393_2
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.leopardstyle

                if not a.disabled and store.tick_ts - a.ts > a.cooldown then
                    local targets =
                        U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                    if not targets then
                        SU.delay_attack(store, a, 0.13333333333333333)

                        goto label_393_1
                    end

                    U.unblock_target(store, this)

                    this.health.ignore_damage = true
                    this.health_bar.hidden = true

                    local start_ts = store.tick_ts
                    local start_pos = V.vclone(this.pos)
                    local last_target
                    local i = 1

                    U.animation_start(this, "leopard_start", nil, store.tick_ts, false)

                    while not U.animation_finished(this) do
                        if SU.hero_interrupted(this) then
                            goto label_393_0
                        end
                        coroutine.yield()
                    end

                    a.ts = start_ts

                    SU.hero_gain_xp_from_skill(this, skill)

                    while i <= a.loops do
                        i = i + 1
                        targets = U.find_enemies_in_range(store, start_pos, 0, a.range, a.vis_flags, a.vis_bans)

                        if not targets then
                            break
                        end

                        if #targets > 1 then
                            targets = table.filter(targets, function(k, v)
                                return v ~= last_target
                            end)
                        end

                        local target = table.random(targets)

                        last_target = target

                        local animation, animation_idx = table.random(a.hit_animations)
                        local hit_time = a.hit_times[animation_idx]
                        local hit_pos = U.melee_slot_position(this, target, 1)
                        local last_ts = store.tick_ts

                        this.pos.x, this.pos.y = hit_pos.x, hit_pos.y

                        if band(target.vis.bans, F_STUN) == 0 then
                            SU.stun_inc(target)
                        end

                        local sound = (i - 1) % 3 == 0 and "HeroMonkMultihitScream" or "HeroMonkMultihitPunch"

                        S:queue(sound)

                        local an, af = U.animation_name_facing_point(this, animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts)

                        while hit_time > store.tick_ts - last_ts do
                            if SU.hero_interrupted(this) then
                                SU.stun_dec(target)

                                goto label_393_0
                            end

                            coroutine.yield()
                        end

                        local d = E:create_entity("damage")

                        d.source_id = this.id
                        d.target_id = target.id
                        d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) * this.unit.damage_factor

                        queue_damage(store, d)

                        local poff = a.particle_pos[animation_idx]
                        local fx = E:create_entity("fx")

                        fx.pos.x, fx.pos.y = (af and -1 or 1) * poff.x + this.pos.x, poff.y + this.pos.y
                        fx.render.sprites[1].name = "fx_hero_monk_particle"
                        fx.render.sprites[1].ts = store.tick_ts
                        fx.render.sprites[1].sort_y_offset = -2

                        queue_insert(store, fx)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                SU.stun_dec(target)

                                goto label_393_0
                            end

                            coroutine.yield()
                        end

                        SU.stun_dec(target)
                    end

                    ::label_393_0::

                    this.health.ignore_damage = nil
                    this.health_bar.hidden = false
                    this.pos.x, this.pos.y = start_pos.x, start_pos.y

                    U.y_animation_play(this, "leopard_end", nil, store.tick_ts, 1)
                end

                ::label_393_1::

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                    if this.cooldown_factor_dec_count < 8 then
                        this.cooldown_factor = this.cooldown_factor - 0.05
                    end

                    this.cooldown_factor_dec_count = this.cooldown_factor_dec_count + 1
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    if this.cooldown_factor_dec_count > 0 then
                        if this.cooldown_factor_dec_count <= 8 then
                            this.cooldown_factor = this.cooldown_factor + 0.05
                        end
                        this.cooldown_factor_dec_count = this.cooldown_factor_dec_count - 1
                    end
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_393_2::

            coroutine.yield()
        end
    end
}
scripts.mod_monk_damage_reduction = {
    insert = function(this, store)
        local target = store.entities[this.modifier.target_id]
        if target and target.unit then
            target.unit.damage_factor = target.unit.damage_factor * (1 - this.reduction_factor)
        end
        return false
    end
}

-- 女巫
scripts.hero_voodoo_witch = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local a = this.melee.attacks[1]
        a.damage_max = ls.damage_max[hl]
        a.damage_min = ls.damage_min[hl]

        local b = E:get_template("bolt_voodoo_witch")

        b.bullet.damage_max = ls.ranged_damage_max[hl]
        b.bullet.damage_min = ls.ranged_damage_min[hl]

        upgrade_skill(this, "laughingskulls", function(this, s)
            local b = E:get_template("bolt_voodoo_witch_skull")
            b.bullet.damage_min = b.bullet.damage_min + s.extra_damage[s.level]
            b.bullet.damage_max = b.bullet.damage_max + s.extra_damage[s.level]
        end)

        upgrade_skill(this, "deathskull", function(this, s)
            local sk = E:get_template("voodoo_witch_skull")
            sk.sacrifice.disabled = nil
            sk.sacrifice.damage = s.damage[s.level]
        end)

        upgrade_skill(this, "bonedance", function(this, s)
            local a = E:get_template("voodoo_witch_skull_aura")
            a.skull_count = s.skull_count[s.level]
            local sp = E:get_template("mod_voodoo_witch_skull_spawn")
            sp.skull_count = s.skull_count[s.level]
        end)

        upgrade_skill(this, "deathaura", function(this, s)
            local m = E:get_template("mod_voodoo_witch_aura_slow")
            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "voodoomagic", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage = s.damage[s.level]
            a.count = s.count[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 螃蟹
scripts.hero_crab = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)
        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "battlehardened", function(this, s)
            this.invuln.disabled = nil
            this.invuln.chance = s.chance[s.level]
        end)

        upgrade_skill(this, "pincerattack", function(this, s)
            local pa = this.timed_attacks.list[1]
            pa.disabled = nil
            pa.damage_min = s.damage_min[s.level]
            pa.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "shouldercannon", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil
            local b = E:get_template("crab_water_bomb")
            b.bullet.damage_max = s.damage[s.level]
            b.bullet.damage_min = s.damage[s.level]
            b.bullet.damage_radius = s.radius_inc[s.level] + b.bullet.damage_radius
            b.render.sprites[1].scale.x = b.bullet.damage_radius / 65
            b.render.sprites[1].scale.y = b.render.sprites[1].scale.x
            local aura = E:get_template("aura_slow_water_bomb")
            aura.aura.radius = aura.aura.radius + s.radius_inc[s.level]
            local m = E:get_template("mod_slow_water_bomb")
            m.modifier.duration = s.slow_duration[s.level]
            m.slow.factor = s.slow_factor[s.level]
        end)

        upgrade_skill(this, "burrow", function(this, s)
            this.burrow.disabled = nil
            this.burrow.extra_speed = s.extra_speed[s.level]
            this.nav_grid.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_ICE)
            this.burrow.damage = s.damage[s.level]
        end)

        upgrade_skill(this, "hookedclaw", function(this, s)
            local pa = this.timed_attacks.list[1]
            if not pa.disabled then
                pa.damage_min = pa.damage_min + s.extra_damage[s.level]
                pa.damage_max = pa.damage_max + s.extra_damage[s.level]
            end
            this.melee.attacks[1].damage_min = this.melee.attacks[1].damage_min + s.extra_damage[s.level]
            this.melee.attacks[1].damage_max = this.melee.attacks[1].damage_max + s.extra_damage[s.level]
        end)

        this.health.hp = this.health.hp_max
    end
}
-- 卡兹 - 代达罗斯
scripts.mod_minotaur_daedalus = {
    queue = function(this, store, insertion)
        local target = store.entities[this.modifier.target_id]

        if not target then
            return
        end

        if insertion then
            target.vis._bans = target.vis.bans
            target.vis.bans = F_ALL
            target.health.ignore_damage = true

            SU.stun_inc(target)

            local s = this.render.sprites[1]
            local m = this.modifier

            if s.size_names then
                s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
            end

            if s.size_anchor then
                s.anchor = s.size_anchors[target.unit.size]
            end

            if m.custom_offsets then
                s.offset = m.custom_offsets[target.template_name] or m.custom_offsets.default
            elseif m.use_mod_offset and target.unit.mod_offset then
                s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
            end
        else
            SU.stun_dec(target)

            if target.vis._bans then
                target.vis.bans = target.vis._bans
                target.vis._bans = nil
                target.health.ignore_damage = true
            end
        end

    end,
    update = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if not target then
            queue_remove(store, this)

            return
        end

        local fx = E:create_entity("decal_minotaur_daedalus")

        fx.pos = V.vclone(target.pos)
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
        U.y_wait(store, 0.5)

        local es = E:create_entity("daedalus_enemy_decal")

        es.pos.x, es.pos.y = target.pos.x, target.pos.y
        es.render = table.deepclone(target.render)
        es.tween.ts = store.tick_ts

        queue_insert(store, es)
        coroutine.yield()
        U.sprites_hide(target)

        target.health_bar.hidden = true

        U.y_wait(store, 0.5)

        target.nav_path.pi = this.dest_pi
        target.nav_path.spi = this.dest_spi
        target.nav_path.ni = this.dest_ni

        local pos = P:node_pos(target.nav_path)

        target.pos.x, target.pos.y = pos.x, pos.y
        es.pos = V.vclone(pos)
        this.pos = V.vclone(pos)
        es.tween.reverse = true
        es.tween.ts = store.tick_ts
        fx = E:create_entity("decal_minotaur_daedalus")
        fx.pos = V.vclone(target.pos)
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
        U.y_wait(store, 0.5)
        queue_remove(store, es)
        U.sprites_show(target)

        target.health_bar.hidden = nil
        target.health.ignore_damage = nil

        if target.vis._bans then
            target.vis.bans = target.vis._bans
            target.vis._bans = nil
        end

        local s = this.render.sprites[1]

        s.hidden = nil
        s.flip_x = target.render.sprites[1].flip_x
        m.ts = store.tick_ts

        while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
            coroutine.yield()
        end

        queue_remove(store, this)
    end
}
-- 卡兹
scripts.hero_minotaur = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local a = this.melee.attacks[1]
        a.damage_max = ls.damage_max[hl]
        a.damage_min = ls.damage_min[hl]

        upgrade_skill(this, "bullrush", function(this, s)
            local a = this.timed_attacks.list[3]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
            a.run_damage_min = s.run_damage_min[s.level]
            a.run_damage_max = s.run_damage_max[s.level]
            local m = E:get_template(a.mod)
            m.modifier.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "bloodaxe", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.damage_max = ls.damage_max[hl] * s.damage_factor[s.level]
            a.damage_min = ls.damage_min[hl] * s.damage_factor[s.level]
        end)

        upgrade_skill(this, "daedalusmaze", function(this, s)
            local a = this.timed_attacks.list[4]
            a.disabled = nil
            local m = E:get_template(a.mod)
            m.modifier.duration = s.duration[s.level]
        end)

        upgrade_skill(this, "roaroffury", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
            local m = E:get_template(a.mod)
            m.extra_damage = s.extra_damage[s.level]
        end)

        upgrade_skill(this, "doomspin", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta
        local ps = E:create_entity("ps_minotaur_bullrush")

        ps.particle_system.track_id = this.id
        ps.particle_system.emit = false

        queue_insert(store, ps)

        local function do_rush_damage(target, a, final_hit)
            local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id

            if final_hit then
                d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) * this.unit.damage_factor
            else
                d.value = (math.random(a.run_damage_min, a.run_damage_max) + this.damage_buff) * this.unit.damage_factor
            end

            d.damage_type = a.damage_type

            queue_damage(store, d)
        end

        local function do_rush_stun(target, a)
            local m = E:create_entity(a.mod)

            m.modifier.target_id = target.id
            m.modifier.source_id = this.id

            queue_insert(store, m)
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_437_2
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.doomspin

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets or #targets < a.min_count then
                        SU.delay_attack(store, a, 0.2)
                    else
                        local target = targets[1]

                        S:queue(a.sound)

                        local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if U.y_wait(store, a.hit_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local heal = 0
                            for _, e in pairs(targets) do
                                local d = E:create_entity("damage")
                                d.source_id = this.id
                                d.target_id = e.id
                                d.value = (math.random(a.damage_min, a.damage_max) + this.damage_buff) *
                                              this.unit.damage_factor
                                heal = heal + d.value * 0.25
                                d.damage_type = a.damage_type
                                queue_damage(store, d)
                            end

                            scripts.heal(this, heal)

                            while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                coroutine.yield()
                            end

                            goto label_437_2
                        end
                    end
                end

                a = this.timed_attacks.list[2]
                skill = this.hero.skills.roaroffury

                if ready_to_use_skill(a, store) then
                    local towers = table.filter(store.towers, function(_, e)
                        return e.tower and e.tower.can_be_mod and not e.tower.blocked and
                                   not table.contains(a.excluded_templates, e.template_name)
                    end)

                    if #towers < 1 then
                        SU.delay_attack(store, a, 0.2)
                    else
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts)

                        if U.y_wait(store, a.shoot_time, function()
                            return SU.hero_interrupted(this)
                        end) then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local fx = E:create_entity(a.shoot_fx)

                            fx.pos = V.vclone(this.pos)
                            fx.render.sprites[1].anchor = V.vclone(this.render.sprites[1].anchor)
                            fx.render.sprites[1].ts = store.tick_ts
                            fx.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                            queue_insert(store, fx)

                            for _, t in pairs(towers) do
                                local m = E:create_entity(a.mod)
                                m.modifier.target_id = t.id
                                queue_insert(store, m)
                            end

                            while not U.animation_finished(this) and not SU.hero_interrupted(this) do
                                coroutine.yield()
                            end

                            fx.render.sprites[1].hidden = true

                            goto label_437_2
                        end
                    end
                end

                a = this.timed_attacks.list[3]
                skill = this.hero.skills.bullrush

                if ready_to_use_skill(a, store) then
                    local target = U.find_first_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                        a.vis_bans, function(e)
                            if not e.heading or not e.nav_path then
                                return false
                            end

                            local dist = V.dist(e.pos.x, e.pos.y, this.pos.x, this.pos.y)
                            local ftime = dist / (this.motion.real_speed * a.speed_factor)
                            local pni = e.nav_path.ni + P:predict_enemy_node_advance(e, ftime)
                            local ppos = P:predict_enemy_pos(e, ftime)
                            local slot_pos = U.melee_slot_position(this, e, 1)

                            return P:nodes_to_goal(e.nav_path) > a.nodes_limit and
                                       P:is_node_valid(e.nav_path.pi, e.nav_path.ni) and
                                       P:is_node_valid(e.nav_path.pi, pni) and
                                       GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) and
                                       GR:cell_is_only(ppos.x, ppos.y, this.nav_grid.valid_terrains_dest) and
                                       GR:find_line_waypoints(this.pos, ppos, this.nav_grid.valid_terrains) ~= nil
                        end)

                    if not target then
                        SU.delay_attack(store, a, 0.2)

                        goto label_437_0
                    end

                    local damaged_enemies = {}

                    U.unblock_target(store, this)

                    this.health_bar.hidden = true
                    this.health.ignore_damage = true

                    local vis_bans = this.vis.bans

                    this.vis.bans = F_ALL
                    U.speed_mul_self(this, a.speed_factor)

                    local an, af = U.animation_name_facing_point(this, a.animations[1], target.pos)

                    U.y_animation_play(this, an, af, store.tick_ts, 1)

                    ps.particle_system.emit = true

                    local dust = E:create_entity("mod_minotaur_dust")

                    dust.modifier.target_id = this.id

                    queue_insert(store, dust)

                    local interrupted = false

                    S:queue(a.sound)
                    U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                    local slot_pos, slot_flip = U.melee_slot_position(this, target, 1)

                    U.set_destination(this, slot_pos)

                    while not U.walk(this, store.tick_length) do
                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.stun_range,
                            a.stun_vis_flags, a.stun_vis_bans, function(v)
                                return not table.contains(damaged_enemies, v)
                            end)

                        if targets then
                            for _, t in pairs(targets) do
                                table.insert(damaged_enemies, t)
                                do_rush_damage(t, a, false)
                                do_rush_stun(t, a)
                            end
                        end

                        coroutine.yield()

                        slot_pos = U.melee_slot_position(this, target, 1)

                        if not GR:cell_is_only(slot_pos.x, slot_pos.y, this.nav_grid.valid_terrains_dest) or
                            not P:is_node_valid(target.nav_path.pi, target.nav_path.ni) then
                            log.debug("bullrush interrupted")

                            interrupted = true

                            break
                        end

                        U.set_destination(this, slot_pos)
                    end

                    this.nav_rally.center = V.vclone(this.pos)
                    this.nav_rally.pos = V.vclone(this.pos)

                    queue_remove(store, dust)

                    ps.particle_system.emit = false
                    an, af = U.animation_name_facing_point(this, a.animations[3], target.pos)

                    U.animation_start(this, an, af, store.tick_ts, false)
                    U.y_wait(store, fts(5))

                    if not interrupted then
                        do_rush_damage(target, a, true)

                        if target.health and not target.health.dead and band(target.vis.flags, a.stun_vis_bans) == 0 and
                            band(target.vis.bans, a.stun_vis_flags) == 0 then
                            do_rush_stun(target, a)
                        end
                    end

                    this.health_bar.hidden = nil
                    this.health.ignore_damage = false
                    this.vis.bans = vis_bans
                    U.speed_div_self(this, a.speed_factor)
                    a.ts = store.tick_ts
                    this.timed_attacks.list[1].ts = 0

                    SU.hero_gain_xp_from_skill(this, skill)
                    U.y_animation_wait(this)

                    goto label_437_2
                end

                ::label_437_0::

                a = this.timed_attacks.list[4]
                skill = this.hero.skills.daedalusmaze

                if ready_to_use_skill(a, store) then
                    local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true, NF_NO_EXIT)

                    if #nearest_nodes < 1 then
                        SU.delay_attack(store, a, 0.2)

                        goto label_437_1
                    end

                    local pi, spi, ni = unpack(nearest_nodes[1])

                    ni = ni + a.node_offset

                    local n_pos = P:node_pos(pi, spi, ni)

                    if not U.is_inside_ellipse(this.pos, n_pos, this.melee.range) or not P:is_node_valid(pi, ni) or
                        P:nodes_to_defend_point(pi, spi, ni) < a.nodes_limit or
                        band(GR:cell_type(n_pos.x, n_pos.y), a.invalid_terrains) ~= 0 then
                        SU.delay_attack(store, a, 0.2)

                        goto label_437_1
                    end

                    local terrains = P:path_terrain_types(pi)

                    terrains = band(terrains, bnot(TERRAIN_CLIFF, TERRAIN_FAERIE))

                    local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, false,
                        a.vis_flags, a.vis_bans, function(v)
                            return (band(bnot(v.enemy.valid_terrains), terrains) == 0) and v.health.hp > 540
                        end)

                    if not target then
                        SU.delay_attack(store, a, 0.2)

                        goto label_437_1
                    end

                    SU.remove_modifiers(store, target)

                    local m = E:create_entity(a.mod)

                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id
                    m.dest_pi = pi
                    m.dest_spi = spi
                    m.dest_ni = ni

                    queue_insert(store, m)
                    S:queue(a.sound)

                    local an, af = U.animation_name_facing_point(this, a.animation, target.pos)

                    U.y_animation_play(this, an, af, store.tick_ts, 1)

                    a.ts = store.tick_ts
                    this.timed_attacks.list[1].ts = 0
                    this.timed_attacks.list[2].ts = 0

                    SU.hero_gain_xp_from_skill(this, skill)

                    goto label_437_2
                end

                ::label_437_1::

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_437_2::

            coroutine.yield()
        end

    end

}
-- 猴神
scripts.hero_monkey_god = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        local a = this.melee.attacks[1]

        a.damage_max = ls.damage_max[hl]
        a.damage_min = ls.damage_min[hl]
        a = this.melee.attacks[2]
        a.damage_max = ls.damage_max[hl]
        a.damage_min = ls.damage_min[hl]

        upgrade_skill(this, "spinningpole", function(this, s)
            local a = this.melee.attacks[3]

            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
            a.loops = s.loops[s.level]
        end)

        upgrade_skill(this, "tetsubostorm", function(this, s)
            local a = this.melee.attacks[4]

            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
        end)

        upgrade_skill(this, "monkeypalm", function(this, s)
            local a = this.melee.attacks[5]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
            local m = E:get_template(a.mod)
            m.modifier.duration = s.silence_duration[s.level]
            m.stun_duration = s.stun_duration[s.level]
        end)

        upgrade_skill(this, "angrygod", function(this, s)
            a = this.timed_attacks.list[1]
            a.disabled = nil

            local m = E:get_template(a.mod)

            m.received_damage_factor = s.received_damage_factor[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    insert = function(this, store)
        this.hero.fn_level_up(this, store)
        this.melee.order = U.attack_order(this.melee.attacks)
        local e = E:create_entity("aura_monkey_god_divinenature")
        e.aura.source_id = this.id
        e.aura.ts = store.tick_ts
        queue_insert(store, e)
        return true
    end,
    can_spinningpole = function(this, store, attack, target)
        local targets = U.find_enemies_in_range(store, this.pos, 0, attack.damage_radius, attack.vis_flags,
            attack.vis_bans)
        return targets and #targets >= attack.min_count
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta
        local cloud_trail = E:create_entity("ps_monkey_god_trail")

        cloud_trail.particle_system.track_id = this.id
        cloud_trail.particle_system.track_offset = V.v(0, 50)
        cloud_trail.particle_system.emit = false
        cloud_trail.particle_system.z = Z_OBJECTS

        queue_insert(store, cloud_trail)
        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    local r = this.nav_rally
                    local cw = this.cloudwalk
                    local force_cloudwalk = false

                    for _, p in pairs(this.nav_grid.waypoints) do
                        if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
                            force_cloudwalk = true

                            break
                        end
                    end

                    if force_cloudwalk or V.dist(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > cw.min_distance then
                        r.new = false

                        U.unblock_target(store, this)

                        local vis_bans = this.vis.bans

                        this.vis.bans = F_ALL
                        this.health.immune_to = F_ALL

                        local original_speed = this.motion.max_speed
                        U.speed_inc_self(this, cw.extra_speed)
                        this.unit.marker_hidden = true
                        this.health_bar.hidden = true

                        S:queue(this.sound_events.change_rally_point)
                        S:queue(this.sound_events.cloud_start)
                        SU.hide_modifiers(store, this, true)
                        U.y_animation_play(this, cw.animations[1], r.pos.x < this.pos.x, store.tick_ts)
                        SU.show_modifiers(store, this, true)
                        S:queue(this.sound_events.cloud_loop)

                        cloud_trail.particle_system.emit = true
                        this.render.sprites[2].hidden = nil
                        this.render.sprites[1].z = Z_BULLETS

                        local ho = this.unit.hit_offset
                        local mo = this.unit.mod_offset

                        this.unit.hit_offset = cw.hit_offset
                        this.unit.mod_offset = cw.mod_offset

                        ::label_452_0::

                        local dest = r.pos
                        local n = this.nav_grid

                        while not V.veq(this.pos, dest) do
                            local w = table.remove(n.waypoints, 1) or dest

                            U.set_destination(this, w)

                            local an, af = U.animation_name_facing_point(this, cw.animations[2], this.motion.dest)

                            U.animation_start(this, an, af, store.tick_ts, true)

                            while not this.motion.arrived do
                                if r.new then
                                    r.new = false

                                    goto label_452_0
                                end

                                U.walk(this, store.tick_length)
                                coroutine.yield()

                                this.motion.speed.x, this.motion.speed.y = 0, 0
                            end
                        end

                        cloud_trail.particle_system.emit = false

                        S:stop(this.sound_events.cloud_loop)
                        S:queue(this.sound_events.cloud_end, this.sound_events.cloud_end_args)
                        SU.hide_modifiers(store, this, true)
                        U.y_animation_play(this, cw.animations[3], nil, store.tick_ts)
                        SU.show_modifiers(store, this, true)

                        this.render.sprites[1].z = Z_OBJECTS
                        this.render.sprites[2].hidden = true
                        U.update_max_speed(this, original_speed)
                        this.vis.bans = vis_bans
                        this.health.immune_to = 0
                        this.unit.marker_hidden = nil
                        this.health_bar.hidden = nil
                        this.unit.hit_offset = ho
                        this.unit.mod_offset = mo
                    elseif SU.y_hero_new_rally(store, this) then
                        goto label_452_2
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                a = this.timed_attacks.list[1]
                skill = this.hero.skills.angrygod

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                        a.vis_flags, a.vis_bans)

                    if not targets or #targets < a.min_count then
                        SU.delay_attack(store, a, 0.2)
                    else
                        S:queue(a.sound_start)
                        U.y_animation_play(this, a.animations[1], nil, store.tick_ts, 1)

                        local loop_ts = store.tick_ts

                        a.ts = store.tick_ts
                        this.melee.attacks[3].ts = 0
                        this.melee.attacks[4].ts = 0
                        this.melee.attacks[5].ts = 0
                        SU.hero_gain_xp_from_skill(this, skill)
                        S:queue(a.sound_loop)
                        this.health.immune_to = F_ALL
                        for i = 1, a.loops do
                            U.animation_start(this, a.animations[2], nil, store.tick_ts, false)

                            local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if targets then
                                for _, target in pairs(targets) do
                                    local m = E:create_entity(a.mod)

                                    m.modifier.target_id = target.id
                                    m.modifier.source_id = this.id
                                    m.render.sprites[1].ts = store.tick_ts

                                    queue_insert(store, m)

                                    local m = E:create_entity("mod_monkey_god_fire")
                                    m.modifier.target_id = target.id
                                    m.modifier.source_id = this.id
                                    m.modifier.level = skill.level
                                    queue_insert(store, m)
                                end
                            end

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    a.ts = a.ts - a.cooldown * (a.loops - i) / a.loops
                                    goto label_452_1
                                end

                                coroutine.yield()
                            end
                        end

                        ::label_452_1::
                        this.health.immune_to = 0
                        S:stop(a.sound_loop)
                        U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)

                        goto label_452_2
                    end
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_452_2::

            coroutine.yield()
        end
    end
}
-- 猴神 - 猴掌
scripts.mod_monkey_god_palm = {
    insert = function(this, store)
        local m = this.modifier
        local target = store.entities[m.target_id]

        if target and not target.health.dead then
            local sm = E:create_entity(this.stun_mod)

            sm.modifier.target_id = target.id
            sm.modifier.source_id = this.id
            sm.modifier.duration = this.stun_duration

            queue_insert(store, sm)

            scripts.cast_silence(target, store)

            local s = this.render.sprites[1]

            s.ts = store.tick_ts

            if target.unit and target.unit.mod_offset then
                s.offset.x = target.unit.mod_offset.x
                s.offset.y = target.unit.mod_offset.y
            end

            local s_offset = this.custom_offsets[target.template_name] or this.custom_offsets.default

            if s_offset then
                s.offset.x = s.offset.x + s_offset.x
                s.offset.y = s.offset.y + s_offset.y
            end

            s.offset.x = (target.render.sprites[1].flip_x and -1 or 1) * s.offset.x

            signal.emit("mod-applied", this, target)

            return true
            -- end
        end

        return false
    end,
    remove = scripts.mod_silence.remove
}
-- 艾利丹
scripts.hero_elves_archer = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        local bt = E:get_template(this.ranged.attacks[1].bullet)

        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]

        upgrade_skill(this, "multishot", function(this, s)
            local a = this.ranged.attacks[2]
            a.disabled = nil
            a.max_loops = s.loops[s.level]
        end)

        upgrade_skill(this, "porcupine", function(this, s)
            bt.bullet.damage_inc = s.damage_inc[s.level]
        end)

        upgrade_skill(this, "nimble_fencer", function(this, s)
            this.dodge.disabled = nil
            this.dodge.chance = s.chance[s.level]
        end)

        upgrade_skill(this, "double_strike", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
        end)

        this.health.hp = this.health.hp_max
    end,
    insert = function(this, store)
        this.hero.fn_level_up(this, store)

        this.melee.order = U.attack_order(this.melee.attacks)
        this.ranged.order = U.attack_order(this.ranged.attacks)

        local a = E:create_entity("aura_elves_archer_regen")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        return true
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local brk, sta, a, skill
        local is_sword = false
        local porcupine_target, porcupine_level = nil, 0

        local function update_porcupine(attack, target)
            if porcupine_target == target then
                porcupine_level = math.min(porcupine_level + 1, 3)
                attack.level = porcupine_level
            else
                porcupine_level = 0
                attack.level = 0
            end

            porcupine_target = target
        end

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            this.regen.is_idle = nil

            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                if this.dodge and this.dodge.active then
                    this.dodge.active = false
                    this.dodge.counter_attack_pending = true
                    this.melee.attacks[2].ts = this.melee.attacks[2].ts - 0.8
                end

                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_79_4
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local enemy = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true)
                    if enemy and enemy.pos then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                        ultimate_entity.damage_factor = this.unit.damage_factor
                        ultimate_entity.pos = V.vclone(enemy.pos)
                        ultimate_entity.level = this.hero.skills.ultimate.level
                        queue_insert(store, ultimate_entity)
                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                -- 近战状态
                local target = SU.soldier_pick_melee_target(store, this)

                if not target then
                    -- block empty
                else
                    if ready_to_use_skill(this.ranged.attacks[2], store) then
                        goto bow_ready_in_sword
                    end
                    if is_sword then
                        local slot_pos = U.melee_slot_position(this, target)

                        if slot_pos and not V.veq(slot_pos, this.pos) then
                            U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

                            is_sword = false
                        end
                    end

                    if SU.soldier_move_to_slot_step(store, this, target) then
                        goto label_79_4
                    end

                    local attack = SU.soldier_pick_melee_attack(store, this, target)

                    if not attack then
                        goto label_79_4
                    end

                    if not is_sword then
                        U.y_animation_play(this, "bow2sword", nil, store.tick_ts)

                        is_sword = true
                    end

                    if attack.xp_from_skill then
                        SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
                    end

                    local attack_done = SU.y_soldier_do_single_melee_attack(store, this, target, attack)

                    U.animation_start(this, "idle_sword", nil, store.tick_ts, true)

                    goto label_79_4
                end
                ::bow_ready_in_sword::
                do
                    if is_sword then
                        U.y_animation_play(this, "sword2bow", nil, store.tick_ts)

                        is_sword = false
                    end

                    local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, this)

                    if not target then
                        goto label_79_3
                    end

                    this.regen.is_idle = true

                    if not attack then
                        goto label_79_3
                    end

                    U.set_destination(this, this.pos)

                    local attack_done
                    local start_ts = store.tick_ts

                    if attack.max_loops then
                        local an, af, ai = U.animation_name_facing_point(this, attack.animations[1], target.pos)

                        U.y_animation_play(this, an, af, store.tick_ts, 1)

                        local retarget_flag
                        local loops, loops_done = attack.max_loops, 0
                        local pred_shots
                        local b = E:create_entity(attack.bullet)
                        b.bullet.damage_factor = this.unit.damage_factor
                        local d = SU.create_bullet_damage(b.bullet)

                        ::label_79_0::

                        if retarget_flag then
                            retarget_flag = nil

                            local n_target, _, n_pred_pos = U.find_foremost_enemy(store, this.pos,
                                attack.min_range, attack.max_range, attack.node_prediction, attack.vis_flags,
                                attack.vis_bans, function(v)
                                    return v ~= target
                                end, F_FLYING)

                            if n_target then
                                target = n_target
                                pred_pos = n_pred_pos
                            else
                                goto label_79_1
                            end
                        end

                        update_porcupine(attack, target)

                        d.value = (b.bullet.damage_min + b.bullet.damage_max + 2 * attack.level *
                                      (b.bullet.damage_inc or 0)) * 0.5
                        pred_shots = math.ceil(target.health.hp / U.predict_damage(target, d))

                        log.paranoid("+++ pred_shots:%s d.value:%s target.hp:%s", pred_shots, d.value, target.health.hp)

                        loops = math.min(attack.max_loops - loops_done, pred_shots)

                        for i = 1, loops do
                            an, af, ai = U.animation_name_facing_point(this, attack.animations[2], target.pos)

                            U.animation_start(this, an, af, store.tick_ts, false)

                            while store.tick_ts - this.render.sprites[1].ts < attack.shoot_times[1] do
                                if SU.hero_interrupted(this) then
                                    goto label_79_2
                                end

                                coroutine.yield()
                            end

                            local b = E:create_entity(attack.bullet)

                            b.pos = V.vclone(this.pos)

                            if attack.bullet_start_offset then
                                local offset = attack.bullet_start_offset[1]

                                b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                            end

                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                target.pos.y + target.unit.hit_offset.y)
                            b.bullet.target_id = target.id
                            b.bullet.source_id = this.id
                            b.bullet.xp_dest_id = this.id
                            b.bullet.level = attack.level
                            b.bullet.damage_factor = this.unit.damage_factor

                            queue_insert(store, b)

                            if attack.xp_from_skill then
                                SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
                            end

                            attack_done = true
                            loops_done = loops_done + 1

                            while not U.animation_finished(this) do
                                if SU.hero_interrupted(this) then
                                    goto label_79_2
                                end

                                coroutine.yield()
                            end

                            if target.health.dead or band(F_RANGED, target.vis.bans) ~= 0 then
                                retarget_flag = true

                                goto label_79_0
                            end

                            update_porcupine(attack, target)
                        end

                        if loops_done < attack.max_loops then
                            retarget_flag = true

                            goto label_79_0
                        end

                        ::label_79_1::

                        an, af, ai = U.animation_name_facing_point(this, attack.animations[3], target.pos)

                        U.animation_start(this, an, af, store.tick_ts, 1)

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                break
                            end

                            coroutine.yield()
                        end
                    else
                        update_porcupine(attack, target)

                        attack_done = SU.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)
                    end

                    ::label_79_2::

                    if attack_done then
                        attack.ts = start_ts
                    end

                    goto label_79_4
                end
                ::label_79_3::

                if SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)

                    this.regen.is_idle = true
                end
            end

            ::label_79_4::

            coroutine.yield()
        end

    end
}
-- 艾利丹 - 大招
scripts.hero_elves_archer_ultimate = {
    update = function(this, store)
        local function spawn_arrow(pi, spi, ni)
            spi = spi or math.random(1, 3)

            local pos = P:node_pos(pi, spi, ni)

            pos.x = pos.x + math.random(-4, 4)
            pos.y = pos.y + math.random(-5, 5)

            local b = E:create_entity(this.bullet)

            b.bullet.damage_max = this.damage[this.level]
            b.bullet.damage_min = this.damage[this.level]
            b.bullet.from = V.v(pos.x + math.random(-170, -140), pos.y + REF_H)
            b.bullet.to = pos
            b.bullet.damage_factor = this.damage_factor
            b.pos = V.vclone(b.bullet.from)

            queue_insert(store, b)
        end

        local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

        if #nearest > 0 then
            local pi, spi, ni = unpack(nearest[1])

            spawn_arrow(pi, spi, ni)

            local count = this.spread[this.level]
            local sequence = {}

            for i = 1, count do
                sequence[i] = i
            end

            while #sequence > 0 do
                local i = table.remove(sequence, math.random(1, #sequence))
                local delay = U.frandom(0, 1 / count)

                U.y_wait(store, delay * 0.5)

                if P:is_node_valid(pi, ni + i) then
                    spawn_arrow(pi, nil, ni + i)
                else
                    spawn_arrow(pi, nil, ni - i)
                end

                U.y_wait(store, delay * 0.5)

                if P:is_node_valid(pi, ni - i) then
                    spawn_arrow(pi, nil, ni - i)
                else
                    spawn_arrow(pi, nil, ni + i)
                end
            end
        end

        queue_remove(store, this)
    end
}

-- 艾利丹 - 大招箭矢
scripts.arrow_hero_elves_archer_ultimate = {
    update = function(this, store)
        local b = this.bullet
        local speed = b.max_speed

        while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
            b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
            this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length,
                this.pos.y + b.speed.y * store.tick_length
            this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

            coroutine.yield()
        end

        local targets = U.find_targets_in_range(store.enemies, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.damage_type = b.damage_type
                d.value = b.damage_max * b.damage_factor
                d.source_id = this.id
                d.target_id = target.id

                queue_damage(store, d)

                if b.mod then
                    local mod = E:create_entity(b.mod)

                    mod.modifier.target_id = target.id

                    queue_insert(store, mod)
                end
            end
        end

        if b.hit_fx then
            SU.insert_sprite(store, b.hit_fx, this.pos)
        end

        if b.arrive_decal then
            local decal = E:create_entity(b.arrive_decal)

            decal.pos = V.vclone(b.to)
            decal.render.sprites[1].ts = store.tick_ts

            queue_insert(store, decal)
        end

        queue_remove(store, this)

    end
}

-- 艾利丹 - 大招箭矢 - 特效
scripts.decal_hero_elves_archer_ultimate = {
    insert = function(this, store)
        this.render.sprites[1].ts = store.tick_ts
        this.render.sprites[1].r = U.frandom(-10, 5) * math.pi / 180
        this.render.sprites[2].ts = store.tick_ts
        return true
    end
}
-- 雷格森
scripts.hero_regson = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this)

        for i = 1, 3 do
            this.melee.attacks[i].damage_min = ls.melee_damage_min[hl]
            this.melee.attacks[i].damage_max = ls.melee_damage_max[hl]
        end

        upgrade_skill(this, "blade", function(this, s)
            this.melee.attacks[4].damage_max = s.damage[s.level] * 0.5
            this.melee.attacks[4].damage_min = s.damage[s.level] * 0.5
            this.melee.attacks[5].chance = s.instakill_chance[s.level]
            this.melee.attacks[5].damage_max = s.damage[s.level] * 0.5
            this.melee.attacks[5].damage_min = s.damage[s.level] * 0.5
        end)

        upgrade_skill(this, "heal", function(this, s)
            local hb = E:get_template("decal_regson_heal_ball")
            hb.hp_factor = s.heal_factor[s.level]
        end)

        upgrade_skill(this, "path", function(this, s)
            this.path_extra = s.extra_hp[s.level]
        end)

        upgrade_skill(this, "slash", function(this, s)
            local a = this.melee.attacks[6]

            a.disabled = nil
            a.count = s.targets[s.level]
            local m = E:get_template(a.mod)

            m.damage_max = s.damage_max[s.level]
            m.damage_min = s.damage_min[s.level]

            a = this.timed_attacks.list[1]
            a.disabled = nil
            a.loops = s.loops[s.level]
        end)
        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            this.ultimate.cooldown = s.cooldown[s.level]
            local u = E:get_template("hero_regson_ultimate")
            u.damage_boss = s.damage_boss[s.level]
        end)

        this.health.hp_max = this.health.hp_max + this.path_extra
        update_regen(this)
        this.health.hp = this.health.hp_max
    end,
    insert = function(this, store)
        this.hero.fn_level_up(this, store)

        this.melee.order = U.attack_order(this.melee.attacks)

        local a = E:create_entity("aura_regson_blade")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        local a = E:create_entity("aura_regson_heal")

        a.aura.source_id = this.id
        a.aura.ts = store.tick_ts
        a.pos = this.pos

        queue_insert(store, a)

        return true

    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local a, skill, brk, sta

        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false
        local fade_start_time
        local origin_pos
        local function exit_whirlwind_mirage()
            this.pos.x = origin_pos.x
            this.pos.y = origin_pos.y
            fade_start_time = store.tick_ts
            U.animation_start(this, this.timed_attacks.list[1].animation .. "_end", nil, store.tick_ts, false)
            while not U.animation_finished(this) do
                if store.tick_ts - fade_start_time < this.timed_attacks.list[1].fade_start_end_time then
                    this.render.sprites[1].alpha = 255 * (store.tick_ts - fade_start_time) /
                                                       this.timed_attacks.list[1].fade_start_end_time
                end
                coroutine.yield()
            end
            this.render.sprites[1].alpha = 255
            this.health_bar.hidden = false
        end
        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_98_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end
                local a = this.timed_attacks.list[1]

                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, 0, 200, a.vis_flags, a.vis_bans)
                    if targets and #targets > a.min_count then
                        this.health_bar.hidden = true
                        fade_start_time = store.tick_ts
                        -- 隐形
                        S:queue(this.sound_events.change_rally_point)
                        U.animation_start(this, a.animation .. "_start", nil, store.tick_ts, false)
                        while not U.animation_finished(this) do
                            if store.tick_ts - fade_start_time < a.fade_start_end_time then
                                this.render.sprites[1].alpha = 255 *
                                                                   (1 - (store.tick_ts - fade_start_time) /
                                                                       a.fade_start_end_time)
                            end
                            if SU.hero_interrupted(this) then
                                this.render.sprites[1].alpha = 255
                                this.health_bar.hidden = false
                                goto label_98_0
                            end
                            coroutine.yield()
                        end
                        a.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.slash)
                        origin_pos = V.vclone(this.pos)
                        for i = 1, a.loops do
                            local target = targets[km.zmod(i, #targets)]
                            if not target or target.health.dead then
                                break
                            end
                            S:queue(a.sound)

                            this.pos.x = target.pos.x
                            this.pos.y = target.pos.y
                            U.animation_start(this, a.animation, nil, store.tick_ts, false)
                            fade_start_time = store.tick_ts
                            local damage_applied = false
                            local fade_out_start_time
                            while not U.animation_finished(this) do
                                -- 显形
                                if store.tick_ts - fade_start_time < a.fade_time then
                                    this.render.sprites[1].alpha = 255 * (store.tick_ts - fade_start_time) / a.fade_time
                                else
                                    if not damage_applied then
                                        this.render.sprites[1].alpha = 255
                                        damage_applied = true
                                        local whirlwind_targets =
                                            U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                                                a.vis_flags, a.vis_bans)
                                        if whirlwind_targets then
                                            for _, target in pairs(whirlwind_targets) do
                                                local m = E:create_entity(a.mod)
                                                m.modifier.target_id = target.id
                                                m.modifier.source_id = this.id
                                                m.render.sprites[1].ts = store.tick_ts
                                                m.modifier.damage_factor = this.unit.damage_factor * 0.5
                                                queue_insert(store, m)
                                            end
                                        end
                                        fade_out_start_time = store.tick_ts
                                    end
                                    -- 隐形
                                    if store.tick_ts - fade_out_start_time < a.fade_time then
                                        this.render.sprites[1].alpha = 255 *
                                                                           (1 - (store.tick_ts - fade_out_start_time) /
                                                                               a.fade_time)
                                    else
                                        this.render.sprites[1].alpha = 0
                                    end
                                end
                                if SU.hero_interrupted(this) then
                                    exit_whirlwind_mirage()
                                    a.ts = a.ts - a.cooldown * (a.loops - i) / a.loops
                                    goto label_98_0
                                end
                                coroutine.yield()
                            end
                        end
                        exit_whirlwind_mirage()
                    else
                        a.ts = a.ts + 1
                    end
                end

                if ready_to_use_skill(this.ultimate, store) then
                    local enemy = find_target_at_critical_moment(this, store, 200)

                    if enemy and enemy.pos and enemy.health.hp > 750 then
                        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                        S:queue(this.sound_events.change_rally_point)
                        local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                        ultimate_entity.level = this.hero.skills.ultimate.level
                        ultimate_entity.damage_factor = this.unit.damage_factor
                        ultimate_entity.pos = V.vclone(enemy.pos)
                        queue_insert(store, ultimate_entity)
                        this.ultimate.ts = store.tick_ts
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                    else
                        this.ultimate.ts = this.ultimate.ts + 1
                    end
                end
                if this.blade_pending then
                    this.blade_pending = nil
                    S:queue("ElvesHeroEldritchBladeCharge")
                    U.y_animation_play(this, "goBerserk", nil, store.tick_ts, 1)
                end

                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_98_0::

            coroutine.yield()
        end
    end
}

scripts.aura_regson_blade = {}

function scripts.aura_regson_blade.update(this, store)
    local hero = store.entities[this.aura.source_id]

    if not hero then
        log.error("hero not found for aura_regson_blade")
        queue_remove(store, this)

        return
    end

    this.blade_ts = store.tick_ts

    while true do
        if this.blade_active and store.tick_ts - this.blade_active_ts > this.blade_duration then
            this.blade_active = false
            this.blade_ts = store.tick_ts

            for i = 1, 3 do
                hero.melee.attacks[i].disabled = nil
            end

            hero.melee.attacks[6].disabled = hero.hero.skills.slash.level < 1

            for i = 4, 5 do
                hero.melee.attacks[i].disabled = true
            end

            hero.idle_flip.animations[1] = "idle"
            hero.render.sprites[1].angles.walk[1] = "run"
        elseif not this.blade_active and U.is_blocked_valid(store, hero) and store.tick_ts - this.blade_ts >
            this.blade_cooldown then
            hero.blade_pending = true
            this.blade_active = true
            this.blade_active_ts = store.tick_ts

            for i = 1, 3 do
                hero.melee.attacks[i].disabled = true
            end

            hero.melee.attacks[6].disabled = true

            for i = 4, 5 do
                hero.melee.attacks[i].disabled = nil
            end

            hero.idle_flip.animations[1] = "berserk_idle"
            hero.render.sprites[1].angles.walk[1] = "berserk_run"
        end

        coroutine.yield()
    end
end

scripts.aura_regson_heal = {}

function scripts.aura_regson_heal.update(this, store)
    local a = this.aura
    local hero = store.entities[a.source_id]
    local last_ts = store.tick_ts

    if not hero then
        log.error("hero not found for aura_regson_heal")
        queue_remove(store, this)

        return
    end

    while true do
        if not hero.health.dead and store.tick_ts - last_ts >= a.cycle_time then
            last_ts = store.tick_ts

            local targets = U.find_enemies_in_range(store, hero.pos, 0, a.radius, a.vis_flags, a.vis_bans)

            if targets then
                for _, target in pairs(targets) do
                    local m = E:create_entity("mod_regson_heal")

                    m.modifier.source_id = hero.id
                    m.modifier.target_id = target.id

                    queue_insert(store, m)
                end
            end
        end

        coroutine.yield()
    end
end

scripts.mod_regson_heal = {}

function scripts.mod_regson_heal.update(this, store)
    this.modifier.ts = store.tick_ts

    while true do
        local target = store.entities[this.modifier.target_id]

        if not target or store.tick_ts - this.modifier.ts > this.modifier.duration then
            break
        end

        if target.health.dead and not U.flag_has(target.health.last_damage_types, DAMAGE_NO_LIFESTEAL) then
            local s = E:create_entity("decal_regson_heal_ball")

            s.target_id = this.modifier.source_id
            s.source_id = target.id
            s.source_hp = target.health.hp_max

            queue_insert(store, s)

            break
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.decal_regson_heal_ball = {}

function scripts.decal_regson_heal_ball.update(this, store)
    local sp = this.render.sprites[1]
    local fm = this.force_motion
    local source = store.entities[this.source_id]
    local hero = store.entities[this.target_id]
    local initial_pos, initial_dest
    local initial_h = 0
    local dest_h = hero.unit.hit_offset.y
    local max_dist
    local last_pos = V.v(0, 0)

    local function move_step(dest)
        local dx, dy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
        local dist = V.len(dx, dy)

        max_dist = math.max(dist, max_dist)

        local phase = km.clamp(0, 1, 1 - dist / max_dist)
        local df = (not fm.ramp_radius or dist > fm.ramp_radius) and 1 or math.max(dist / fm.ramp_radius, 0.1)

        fm.a.x, fm.a.y = V.add(fm.a.x, fm.a.y, V.trim(fm.max_a, V.mul(fm.a_step * df, dx, dy)))
        fm.v.x, fm.v.y = V.add(fm.v.x, fm.v.y, V.mul(store.tick_length, fm.a.x, fm.a.y))
        fm.v.x, fm.v.y = V.trim(fm.max_v, fm.v.x, fm.v.y)

        local sx, sy = V.mul(store.tick_length, fm.v.x, fm.v.y)

        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
        fm.a.x, fm.a.y = V.mul(-0.05 / store.tick_length, fm.v.x, fm.v.y)
        sp.offset.y = SU.parabola_y(phase, initial_h, dest_h, fm.max_flight_height)
        sp.r = V.angleTo(this.pos.x - last_pos.x, this.pos.y + sp.offset.y - last_pos.y)
        last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y

        return dist < 2 * fm.max_v * store.tick_length
    end

    if not source or not hero then
        log.debug("source or hero entity not found for decal_regson_heal_ball")
    else
        sp.hidden = true
        this.pos.x, this.pos.y = source.pos.x, source.pos.y

        if source.unit and source.unit.hit_offset then
            initial_h = source.unit.hit_offset.y
        end

        do
            local fx = E:create_entity(this.fx_spawn)

            fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
            fx.render.sprites[1].offset.y = initial_h
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        U.y_wait(store, fts(10))

        sp.hidden = nil
        this.dest = hero.pos
        initial_pos = V.vclone(this.pos)
        initial_dest = V.vclone(hero.pos)
        initial_h = initial_h + 18
        fm.a.x, fm.a.y = 0, 2.5
        last_pos.x, last_pos.y = this.pos.x, this.pos.y + sp.offset.y
        max_dist = V.len(initial_dest.x - initial_pos.x, initial_dest.y - initial_pos.y)

        while not hero.health.dead and not move_step(this.dest) do
            coroutine.yield()
        end

        if not hero.health.dead then
            hero.health.hp = km.clamp(0, hero.health.hp_max, hero.health.hp + this.source_hp * this.hp_factor)

            local fx = E:create_entity(this.fx_receive)

            fx.pos = hero.pos
            fx.render.sprites[1].ts = store.tick_ts
            fx.render.sprites[1].offset = hero.unit.mod_offset

            queue_insert(store, fx)
            if this.side_effect then
                this.side_effect(hero, store)
            end
        end
    end

    queue_remove(store, this)
end

scripts.mod_regson_slash = {}

function scripts.mod_regson_slash.update(this, store)
    local m = this.modifier
    local sp = this.render.sprites[1]
    local target = store.entities[m.target_id]

    if not target or not target.pos or target.health.dead then
        queue_remove(store, this)

        return
    end

    sp.hidden = true
    m.ts = store.tick_ts
    this.pos = target.pos

    if target.unit and target.unit.mod_offset then
        sp.offset.x, sp.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y + 5
        sp.flip_x = not target.render.sprites[1].flip_x
    end

    local delay = (m.target_idx or 0) * this.delay_per_idx

    U.y_wait(store, delay)

    sp.hidden = nil

    U.animation_start(this, this.name, nil, store.tick_ts)
    U.y_wait(store, this.hit_time)

    local d = E:create_entity("damage")

    d.source_id = this.id
    d.target_id = target.id
    d.damage_type = this.damage_type
    d.value = math.random(this.damage_min, this.damage_max) * m.damage_factor

    queue_damage(store, d)
    U.y_animation_wait(this)
    queue_remove(store, this)
end

scripts.hero_regson_ultimate = {}

function scripts.hero_regson_ultimate.update(this, store)
    local is_boss
    local sp = this.render.sprites[1]
    local targets = table.filter(store.enemies, function(_, e)
        return e.pos and e.ui and e.ui.can_click and e.nav_path and not e.health.dead and
                   band(e.vis.flags, this.vis_bans) == 0 and band(e.vis.bans, this.vis_flags) == 0 and
                   U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y),
                V.v(this.pos.x, this.pos.y), this.range) and P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
    end)

    table.sort(targets, function(e1, e2)
        return V.dist(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) <
                   V.dist(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
    end)

    local target = targets[1]

    if not target then
        -- block empty
    else
        is_boss = band(target.vis.flags, F_BOSS) ~= 0

        if not is_boss then
            this._target_prev_bans = target.vis.bans
            target.vis.bans = F_ALL
        end

        SU.stun_inc(target)

        this.pos = target.pos
        sp.offset.x, sp.offset.y = target.unit.hit_offset.x, target.unit.hit_offset.y

        U.animation_start(this, sp.name, nil, store.tick_ts)
        U.y_wait(store, this.hit_time)

        do
            local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id

            if is_boss then
                d.damage_type = DAMAGE_TRUE
                d.value = this.damage_boss * this.damage_factor
            else
                d.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_NOT_EXPLODE)
            end

            queue_damage(store, d)
        end

        U.y_animation_wait(this)
        SU.stun_dec(target)

        if not is_boss then
            target.vis.bans = this._target_prev_bans
        end
    end

    queue_remove(store, this)
end
-- 林恩
scripts.hero_lynn = {}

function scripts.hero_lynn.fn_damage_melee(this, store, attack, target)
    local skill = this.hero.skills.hexfury
    local value = this.unit.damage_factor * (math.random(attack.damage_min, attack.damage_max + this.damage_buff))
    local mods = {"mod_lynn_curse", "mod_lynn_despair", "mod_lynn_ultimate", "mod_lynn_weakening"}

    if skill.level > 0 and U.has_modifier_in_list(store, target, mods) then
        value = value + this.unit.damage_factor * skill.extra_damage

        log.debug(" fn_damage_melee LYNN: +++ adding extra damage %s", skill.extra_damage)
    end

    return value
end

function scripts.hero_lynn.on_damage(this, store, damage)
    if math.random() < this.charm_of_unluck then
        return false
    end
    return true
end

function scripts.hero_lynn.level_up(this, store)
    local hl, ls = level_up_basic(this)
    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "hexfury", function(this, s)
        this.melee.attacks[1].mod = "mod_lynn_curse"
        this.melee.attacks[2].mod = "mod_lynn_curse"
        this.melee.attacks[3].mod = "mod_lynn_curse"
        this.melee.attacks[3].loops = s.loops[s.level]
        this.melee.attacks[3].disabled = nil
    end)
    upgrade_skill(this, "despair", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.max_count = s.max_count[s.level]
        this.timed_attacks.list[2].max_count = s.max_count[s.level]
        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
        m.speed_factor = s.speed_factor[s.level]
        m.inflicted_damage_factor = s.damage_factor[s.level]

    end)

    upgrade_skill(this, "weakening", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.max_count = s.max_count[s.level]
        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
        m.armor_reduction = s.armor_reduction[s.level]
        m.magic_armor_reduction = s.magic_armor_reduction[s.level]
    end)

    upgrade_skill(this, "charm_of_unluck", function(this, s)
        this.charm_of_unluck = s.chance[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local m = E:get_template("mod_lynn_ultimate")
        m.dps.damage_max = s.damage[s.level]
        m.dps.damage_min = s.damage[s.level]
        m.explode_damage = s.explode_damage[s.level]
        this.ultimate.curse_damage_all = s.damage[s.level] * 10
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_lynn.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    this.health_bar.hidden = false

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_183_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            if ready_to_use_skill(this.ultimate, store) then
                local enemy = U.find_biggest_enemy(store, this.pos, 0, this.timed_attacks.list[1].range, 0,
                    F_RANGED, 0, function(e, origin)
                        return e.health.hp <= this.ultimate.curse_damage_all * this.unit.damage_factor *
                                   e.health.damage_factor
                    end)
                if enemy and enemy.pos then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                    ultimate_entity.level = this.hero.skills.ultimate.level
                    ultimate_entity.damage_factor = this.unit.damage_factor
                    ultimate_entity.pos = {
                        x = enemy.pos.x + enemy.unit.hit_offset.x,
                        y = enemy.pos.y + enemy.unit.hit_offset.y
                    }
                    queue_insert(store, ultimate_entity)
                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            a = this.timed_attacks.list[1]
            skill = this.hero.skills.despair

            if ready_to_use_skill(a, store) then
                local targets = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not targets or #targets < a.min_count then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.hit_time) then
                        -- block empty
                    else
                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts
                        targets = U.find_enemies_in_range(store, this.pos, 0, a.range * 1.2, a.vis_flags,
                            a.vis_bans)

                        if targets then
                            for i, target in ipairs(targets) do
                                if i > a.max_count then
                                    break
                                end

                                local m = E:create_entity(a.mod)

                                m.modifier.source_id = this.id
                                m.modifier.target_id = target.id

                                queue_insert(store, m)
                            end
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_183_0
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.weakening

            if ready_to_use_skill(a, store) then
                local blocked = U.get_blocked(store, this)

                if not blocked or blocked.health.armor < 0.1 and blocked.health.magic_armor < 0.1 or
                    not U.is_blocked_valid(store, this) then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.hit_time) then
                        -- block empty
                    else
                        a.ts = store.tick_ts
                        blocked = U.get_blocked(store, this)

                        if blocked and U.is_blocked_valid(store, this) then
                            SU.hero_gain_xp_from_skill(this, skill)
                            local targets = U.find_enemies_in_range(store, this.pos, 0, a.range * 1.2,
                                a.vis_flags, a.vis_bans)
                            for i, target in ipairs(targets) do
                                if i > a.max_count then
                                    break
                                end

                                local m = E:create_entity(a.mod)

                                m.modifier.source_id = this.id
                                m.modifier.target_id = target.id

                                queue_insert(store, m)
                            end

                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_183_0
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_183_0::

        coroutine.yield()
    end
end

scripts.hero_lynn_ultimate = {}

function scripts.hero_lynn_ultimate.update(this, store)
    local targets = table.filter(store.enemies, function(_, e)
        return
            e.ui and e.ui.can_click and e.nav_path and not e.health.dead and band(e.vis.flags, this.vis_bans) == 0 and
                band(e.vis.bans, this.vis_flags) == 0 and
                U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y),
                    V.v(this.pos.x, this.pos.y), this.range) and
                P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1)
    end)

    table.sort(targets, function(e1, e2)
        return V.dist2(e1.pos.x + e1.unit.hit_offset.x, e1.pos.y + e1.unit.hit_offset.y, this.pos.x, this.pos.y) <
                   V.dist2(e2.pos.x + e2.unit.hit_offset.x, e2.pos.y + e2.unit.hit_offset.y, this.pos.x, this.pos.y)
    end)

    local target = targets[1]

    if target then
        local m = E:create_entity(this.mod)
        m.modifier.source_id = this.id
        m.modifier.target_id = target.id
        m.modifier.damage_factor = this.damage_factor
        queue_insert(store, m)
    end

    queue_remove(store, this)
end

scripts.mod_lynn_ultimate = {}

function scripts.mod_lynn_ultimate.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if not target or target.health.dead then
        return false
    end

    if not U.flags_pass(target.vis, this.modifier) then
        return false
    end

    this.dps.ts = store.tick_ts - this.dps.damage_every
    this.modifier.ts = store.tick_ts
    this.tween.ts = store.tick_ts
    this.pos = target.pos

    signal.emit("mod-applied", this, target)

    return true
end

function scripts.mod_lynn_ultimate.update(this, store, script)
    local target
    local m = this.modifier
    local dps = this.dps
    local s_top, s_over = this.render.sprites[1], this.render.sprites[3]

    while store.tick_ts - m.ts < m.duration do
        target = store.entities[m.target_id]

        if not target then
            break
        end

        if target.health.dead then
            local p

            if U.flag_has(target.vis.flags, F_FLYING) then
                p = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            else
                p = V.v(target.pos.x, target.pos.y)
            end

            SU.insert_sprite(store, this.explode_fx, p)

            local targets = U.find_enemies_in_range(store, target.pos, 0, this.explode_range,
                this.explode_vis_flags, this.explode_vis_bans)

            if targets then
                for _, t in pairs(targets) do
                    local new_mod = E:create_entity("mod_lynn_ultimate")
                    new_mod.modifier.source_id = this.id
                    new_mod.modifier.target_id = t.id
                    new_mod.modifier.damage_factor = this.modifier.damage_factor * 0.6
                    queue_insert(store, new_mod)

                    local d = E:create_entity("damage")
                    d.damage_type = this.explode_damage_type
                    d.value = this.explode_damage * this.modifier.damage_factor
                    d.target_id = t.id
                    d.source_id = this.id
                    queue_damage(store, d)
                end
            end

            break
        end

        s_top.offset.x = target.health_bar.offset.x + m.health_bar_offset.x
        s_top.offset.y = target.health_bar.offset.y + m.health_bar_offset.y
        s_over.offset.x = target.unit.mod_offset.x
        s_over.offset.y = target.unit.mod_offset.y

        if dps.damage_every and store.tick_ts - dps.ts >= dps.damage_every then
            dps.ts = dps.ts + dps.damage_every

            local d = E:create_entity("damage")

            d.source_id = this.id
            d.target_id = target.id
            d.value = dps.damage_max * this.modifier.damage_factor
            d.damage_type = dps.damage_type

            queue_damage(store, d)
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.mod_lynn_weakening = {}

function scripts.mod_lynn_weakening.insert(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
        return false
    end
    if this.magic_armor_reduction > target.health.magic_armor then
        this.armor_reduction = this.armor_reduction + 0.5 * target.health.magic_armor
    else
        this.armor_reduction = this.armor_reduction + 0.5 * this.magic_armor_reduction
    end
    this.magic_armor_reduction = this.magic_armor_reduction * (1 - target.health.armor_resilience)
    this.armor_reduction = this.armor_reduction * (1 - target.health.armor_resilience)
    SU.armor_dec(target, this.armor_reduction)
    SU.magic_armor_dec(target, this.magic_armor_reduction)

    -- local mods = U.get_modifiers(store, target, {"mod_lynn_despair", "mod_lynn_ultimate"})

    -- for _, m in pairs(mods) do
    --     if m ~= this then
    --         U.sprites_hide(m, nil, nil, true)
    --     end
    -- end

    signal.emit("mod-applied", this, target)

    return true
end

function scripts.mod_lynn_weakening.remove(this, store, script)
    local target = store.entities[this.modifier.target_id]

    if target then
        SU.armor_inc(target, this.armor_reduction)
        SU.magic_armor_inc(target, this.magic_armor_reduction)
    end

    return true
end

scripts.mod_lynn_despair = {}

function scripts.mod_lynn_despair.insert(this, store)
    local target = store.entities[this.modifier.target_id]

    if not target or target.health.dead or not target.unit or not target.motion then
        return false
    end

    target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor

    if not target.motion.invulnerable then
        U.speed_mul(target, this.speed_factor)
    end

    this.modifier.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts

    -- local mods = U.get_modifiers(store, target, {"mod_lynn_ultimate", "mod_lynn_weakening"})

    -- for _, m in pairs(mods) do
    --     if m ~= this then
    --         U.sprites_hide(m, nil, nil, true)
    --     end
    -- end

    signal.emit("mod-applied", this, target)

    return true
end

function scripts.mod_lynn_despair.remove(this, store)
    local target = store.entities[this.modifier.target_id]

    if target and target.health and target.unit and target.motion then
        target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor

        if not target.motion.invulnerable then
            U.speed_div(target, this.speed_factor)
        end
    end

    return true
end

scripts.mod_lynn_curse = {}

function scripts.mod_lynn_curse.insert(this, store)
    local target = store.entities[this.modifier.target_id]

    if not target or math.random() >= this.modifier.chance or not U.flags_pass(target.vis, this.modifier) then
        log.debug("mod_lynn_curse chance miss")
        return false
    end

    log.debug("mod_lynn_curse chance hit")
    scripts.cast_silence(target, store)

    return true
end

function scripts.mod_lynn_curse.update(this, store)
    this.modifier.ts = store.tick_ts

    local target

    repeat
        coroutine.yield()

        target = store.entities[this.modifier.target_id]
    until store.tick_ts - this.modifier.ts >= this.modifier.duration or not target or target.health.dead

    queue_remove(store, this)
end

function scripts.mod_lynn_curse.remove(this, store)
    local target = store.entities[this.modifier.target_id]
    scripts.remove_silence(target, store)
    return true
end

-- 威尔伯
scripts.hero_wilbur = {}

function scripts.hero_wilbur.missile_filter_fn(e, origin)
    local pp = P:predict_enemy_pos(e, 2)
    local allow = math.abs(pp.y - origin.y) < 80

    return allow
end

function scripts.hero_wilbur.level_up(this, store)
    local hl, ls = level_up_basic(this)

    local b = E:get_template(this.ranged.attacks[1].bullet)

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    upgrade_skill(this, "missile", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil

        local b = E:get_template(a.bullet)

        b.bullet.damage_max = s.damage_max[s.level]
        b.bullet.damage_min = s.damage_min[s.level]

    end)
    upgrade_skill(this, "smoke", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil

        local au = E:get_template(a.bullet)

        au.aura.duration = s.duration[s.level]

        local m = E:get_template(au.aura.mod)

        m.slow.factor = s.slow_factor[s.level]
    end)

    upgrade_skill(this, "box", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil

        local pl = E:get_template(a.payload)

        pl.spawner.count = s.count[s.level]
    end)

    upgrade_skill(this, "engine", function(this, s)
        this.engine_factor = s.speed_factor[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local m = E:get_template("drone_wilbur")
        m.custom_attack.damage_max = s.damage[s.level] - 1
        m.custom_attack.damage_min = -1
    end)
    U.update_max_speed(this, this.motion.max_speed_base * this.engine_factor)

    this.health.hp = this.health.hp_max
end

function scripts.hero_wilbur.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    local a = E:create_entity("aura_bobbing_wilbur")

    a.aura.source_id = this.id
    a.aura.ts = store.tick_ts
    a.pos = this.pos

    queue_insert(store, a)

    return true
end

function scripts.hero_wilbur.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            -- block empty
        end

        if ready_to_use_skill(this.ultimate, store) then
            local target = U.find_foremost_enemy(store, this.pos, 0, this.ranged.attacks[1].max_range, 0,
                F_RANGED, 0)

            if target and target.pos then
                S:queue(this.sound_events.change_rally_point)
                local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                e.level = this.hero.skills.ultimate.level
                e.pos = V.vclone(target.pos)

                queue_insert(store, e)
            end

            this.ultimate.ts = store.tick_ts
            SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
        end

        a = this.timed_attacks.list[1]
        skill = this.hero.skills.smoke

        if ready_to_use_skill(a, store) then
            local target = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range, a.node_prediction,
                a.vis_flags, a.vis_bans)

            if not target then
                SU.delay_attack(store, a, 0.06666666666666667)
            else
                S:queue(a.sound, a.sound_args)
                U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
                SU.hero_gain_xp_from_skill(this, skill)

                local au = E:create_entity(a.bullet)

                au.pos.x, au.pos.y = this.pos.x, this.pos.y
                queue_insert(store, au)
                U.y_animation_play(this, a.animations[2], nil, store.tick_ts)
                U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
                SU.y_hero_animation_wait(this)

                a.ts = store.tick_ts

                goto label_199_0
            end
        end

        a = this.timed_attacks.list[2]
        skill = this.hero.skills.box

        if ready_to_use_skill(a, store) then
            local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min, a.range_nodes_max,
                a.max_path_dist, a.vis_flags, a.vis_bans, true, function(e)
                    return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
                end)

            if not target_info then
                SU.delay_attack(store, a, 0.16666666666666666)
            else
                local target = target_info[1].enemy
                local origin = target_info[1].origin
                local start_ts = store.tick_ts
                local bullet_to_ni = origin[3] - math.random(8, 13)

                bullet_to_ni = km.clamp(5, P:get_end_node(origin[1]), bullet_to_ni)

                local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
                local flip = bullet_to.x < this.pos.x

                S:queue(a.sound)
                U.animation_start(this, a.animation, flip, store.tick_ts)

                if SU.y_hero_wait(store, this, a.shoot_time) then
                    goto label_199_0
                end

                SU.hero_gain_xp_from_skill(this, skill)

                a.ts = store.tick_ts

                local e = E:create_entity(a.payload)

                e.spawner.pi = origin[1]
                e.spawner.ni = bullet_to_ni
                e.pos = bullet_to

                local b = E:create_entity(a.bullet)

                b.pos.x = this.pos.x + (flip and -1 or 1) * a.bullet_start_offset.x
                b.pos.y = this.pos.y + a.bullet_start_offset.y
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.vclone(e.pos)
                b.bullet.hit_payload = e

                queue_insert(store, b)
                SU.y_hero_animation_wait(this)

                a.ts = store.tick_ts

                goto label_199_0
            end
        end

        brk, sta = SU.y_soldier_ranged_attacks(store, this)

        if brk then
            -- block empty
        else
            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
        end

        ::label_199_0::

        coroutine.yield()
    end
end

scripts.hero_wilbur_ultimate = {}

function scripts.hero_wilbur_ultimate.update(this, store)
    for i, o in ipairs(this.spawn_offsets) do
        local e = E:create_entity(this.entity)

        e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
        e.spawn_index = i
        queue_insert(store, e)
    end

    queue_remove(store, this)
end

scripts.aura_wilbur_bobbing = {}

function scripts.aura_wilbur_bobbing.update(this, store)
    local hero = store.entities[this.aura.source_id]
    local s3 = hero.render.sprites[3]
    local nr = hero.nav_rally
    local layers = {hero.render.sprites[3], hero.render.sprites[4]}
    local r_names = {"r", "r"}
    local dist_th = 40
    local max_angle = km.deg2rad(5)
    local angle_step = km.deg2rad(20) * store.tick_length
    local h_max = 4
    local h_step = 20 * store.tick_length
    local h_ts = store.tick_ts

    while true do
        local dx = this.pos.x - nr.center.x
        local sign = dx < 0 and -1 or 1
        local dest_angle = km.clamp(-max_angle, max_angle, max_angle * dx / dist_th)

        for _, s in pairs(layers) do
            local da = km.clamp(-angle_step, angle_step, dest_angle - s.r)

            s.r = s.r + da
        end

        for _, s in pairs(layers) do
            local o = s.offset

            if s3.name == "idle" then
                o.y = h_max * math.sin(2 * math.pi * (store.tick_ts - h_ts))
            else
                local dy = km.clamp(-h_step, h_step, -o.y)

                o.y = o.y + dy
                h_ts = store.tick_ts
            end
        end

        coroutine.yield()
    end
end

scripts.drone_wilbur = {}

function scripts.drone_wilbur.update(this, store)
    local sd = this.render.sprites[1]
    local ss = this.render.sprites[2]
    local ca = this.custom_attack
    local fm = this.force_motion

    local function find_target(range)
        local target, targets

        for _, set in pairs(ca.range_sets) do
            local min_range, max_range = unpack(set)

            target, targets = U.find_nearest_enemy(store, this.pos, min_range, max_range, ca.vis_flags,
                ca.vis_bans)

            if target then
                break
            end
        end

        if not target then
            return nil
        end

        local drones = LU.list_entities(store.entities, this.template_name)
        local drone_target_ids = table.map(drones, function(k, v)
            return v._chasing_target_id or 0
        end)
        local untargeted = table.filter(targets, function(k, v)
            return not table.contains(drone_target_ids, v.id)
        end)

        for _, nt in ipairs(targets) do
            if table.contains(untargeted, nt) then
                return nt
            end
        end

        return target
    end

    local shoot_ts, search_ts, shots = 0, 0, 0
    local target, targets, dist
    local dest = V.v(this.pos.x, this.pos.y)

    this.start_ts = store.tick_ts
    fm.a_step = fm.a_step + math.random(-3, 3)
    this.tween.ts = U.frandom(0, 1)

    local oos = {V.v(-6, 0), V.v(6, 2), V.v(2, 6), V.v(0, -6)}
    local oo = oos[this.spawn_index]

    U.animation_start(this, "idle", nil, store.tick_ts, true)

    while store.tick_ts - this.start_ts <= this.duration do
        search_ts = store.tick_ts

        if shots < ca.max_shots then
            target = find_target(ca.max_range)
        else
            target = nil
        end

        this._chasing_target_id = target and target.id or nil

        if target then
            repeat
                dest.x, dest.y = target.pos.x + oo.x, target.pos.y + oo.y
                sd.flip_x = this.pos.x < dest.x

                U.force_motion_step(this, store.tick_length, dest)
                coroutine.yield()

                dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
            until dist < ca.shoot_range or target.health.dead or band(ca.vis_flags, target.vis.bans) ~= 0

            if shots < ca.max_shots and store.entities[target.id] and not target.health.dead and
                band(ca.vis_flags, target.vis.bans) == 0 and store.tick_ts - shoot_ts > ca.cooldown then
                shots = shots + 1

                if math.random() < ca.sound_chance then
                    S:queue(ca.sound)
                end

                U.animation_start(this, "shoot", this.pos.x < target.pos.x, store.tick_ts, false)

                for i = 1, ca.hit_cycles do
                    local hit_ts = store.tick_ts

                    while store.tick_ts - hit_ts < ca.hit_time do
                        U.force_motion_step(this, store.tick_length, dest)

                        sd.flip_x = this.pos.x < target.pos.x

                        coroutine.yield()
                    end

                    local d = SU.create_attack_damage(ca, target.id, this)

                    queue_damage(store, d)
                end

                while not U.animation_finished(this) do
                    U.force_motion_step(this, store.tick_length, dest)

                    sd.flip_x = this.pos.x < target.pos.x

                    coroutine.yield()
                end

                U.animation_start(this, "idle", nil, store.tick_ts, true)

                shoot_ts = store.tick_ts
            end

            U.animation_start(this, "idle", nil, store.tick_ts, true)
        end

        while store.tick_ts - search_ts < ca.search_cooldown do
            U.force_motion_step(this, store.tick_length, dest)
            coroutine.yield()
        end
    end

    U.y_ease_keys(store, {sd, sd.offset, ss}, {"alpha", "y", "alpha"}, {255, 50, 255}, {0, 85, 0}, 0.4)
    queue_remove(store, this)
end

scripts.aura_box_wilbur = {}

function scripts.aura_box_wilbur.update(this, store)
    local sp = this.spawner

    this.render.sprites[1].ts = store.tick_ts

    SU.insert_sprite(store, "decal_rock_crater", this.pos)
    U.y_wait(store, sp.spawn_time)

    this.render.sprites[1].z = Z_DECALS

    S:queue(sp.sound)

    for i = 1, sp.count do
        local e = E:create_entity(sp.entity)

        e.pos.x, e.pos.y = this.pos.x, this.pos.y
        e.nav_path.pi = sp.pi
        e.nav_path.spi = km.zmod(i, 3)
        e.nav_path.ni = sp.ni

        queue_insert(store, e)
    end

    SU.insert_sprite(store, "fx_box_wilbur_smoke_b", V.v(this.pos.x + 33 - 40, this.pos.y + 32 - 20))
    SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 60 - 40, this.pos.y + 32 - 22))
    SU.insert_sprite(store, "fx_box_wilbur_smoke_a", V.v(this.pos.x + 10 - 40, this.pos.y + 32 - 22), true)
    U.y_wait(store, fts(10))
    U.y_ease_key(store, this.render.sprites[1], "alpha", 255, 0, 1)
    queue_remove(store, this)
end

scripts.shot_wilbur = {}

function scripts.shot_wilbur.update(this, store)
    local b = this.bullet
    local target = store.entities[b.target_id]
    local source = store.entities[b.source_id]

    if b.shot_index < 3 then
        local flip_x = b.to.x < source.pos.x
        local sfx = E:create_entity(b.shoot_fx)

        sfx.pos.x, sfx.pos.y = this.pos.x, this.pos.y
        sfx.render.sprites[1].flip_x = flip_x
        sfx.render.sprites[1].r = (flip_x and -1 or 1) * km.deg2rad(-30)
        sfx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, sfx)
    end

    if b.shot_index == 1 and target and not U.flag_has(target.vis.flags, F_FLYING) then
        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni

        ni = ni + 6

        for i = 1, 6 do
            local sign = i % 2 == 0 and 1 or -1
            local p = P:node_offset_pos(10 * sign, pi, spi, ni - i)
            local fx = E:create_entity(b.hit_fx)

            fx.pos.x, fx.pos.y = p.x, p.y
            fx.render.sprites[1].ts = store.tick_ts + fts(2 * i)

            queue_insert(store, fx)
        end
    end

    U.y_wait(store, b.flight_time)

    if target then
        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)
    end

    queue_remove(store, this)
end
scripts.missile_wilbur = {}

function scripts.missile_wilbur.insert(this, store, script)
    local b = this.bullet

    b.to.x = this.pos.x
    b.to.y = this.pos.y + math.random(70, 110)

    if b.shot_index ~= 1 then
        local o_target = store.entities[b.target_id]
        local o = o_target and o_target.pos or this.pos
        local target, targets = U.find_foremost_enemy(store, o, 0, b.first_retarget_range, false, b.vis_flags,
            b.vis_bans, function(e)
                return e.id ~= b.target_id
            end)

        if targets then
            local target = targets[b.shot_index - 1] or table.random(targets)

            b.target_id = target.id
        end
    end

    return scripts.missile.insert(this, store, script)
end

scripts.hero_veznan = {}

function scripts.hero_veznan.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)

    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "soulburn", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.total_hp = s.total_hp[s.level]

    end)
    upgrade_skill(this, "shackles", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.max_count = s.max_count[s.level]
    end)

    upgrade_skill(this, "hermeticinsight", function(this, s)
        this.hermeticinsight_factor = s.range_factor[s.level]
    end)

    upgrade_skill(this, "arcanenova", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.damage_max = s.damage_max[s.level]
        a.damage_min = s.damage_min[s.level]

    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template(s.controller_name)
        local m = E:get_template(u.mod)

        m.modifier.duration = s.stun_duration[s.level]

        local e = E:get_template(u.entity)

        e.health.hp_max = s.soldier_hp_max[s.level]
        e.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
        e.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]

        local b = E:get_template(e.ranged.attacks[1].bullet)

        b.bullet.damage_max = s.soldier_damage_max[s.level]
        b.bullet.damage_min = s.soldier_damage_min[s.level]

    end)

    this.ranged.attacks[1].max_range = this.ranged.attacks[1].max_range_base * this.hermeticinsight_factor
    this.timed_attacks.list[1].range = this.timed_attacks.list[1].range_base * this.hermeticinsight_factor
    this.timed_attacks.list[2].range = this.timed_attacks.list[2].range_base * this.hermeticinsight_factor
    this.timed_attacks.list[3].max_range = this.timed_attacks.list[3].max_range_base * this.hermeticinsight_factor

    this.health.hp = this.health.hp_max
end

function scripts.hero_veznan.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_154_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.soulburn

            if ready_to_use_skill(a, store) then
                local triggers = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans,
                    function(e)
                        return skill.level == 3 or e.health.hp_max <= a.total_hp
                    end)

                if not triggers then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    table.sort(triggers, function(e1, e2)
                        return e1.health.hp > e2.health.hp
                    end)

                    local targets = {}
                    local first_target = triggers[1]

                    table.insert(targets, first_target)

                    local hp_count = first_target.health.hp

                    if hp_count < a.total_hp then
                        for _, t in pairs(triggers) do
                            if t ~= first_target and hp_count + t.health.hp_max <= a.total_hp and
                                U.is_inside_ellipse(t.pos, first_target.pos, a.radius) then
                                table.insert(targets, t)

                                hp_count = hp_count + t.health.hp_max
                            end
                        end
                    end

                    S:queue(a.sound)

                    local af = first_target.pos.x < this.pos.x

                    U.animation_start(this, a.animations[1], af, store.tick_ts, false)
                    U.y_wait(store, a.cast_time)

                    local balls = {}
                    local o = V.v(a.balls_dest_offset.x * (this.render.sprites[1].flip_x and -1 or 1),
                        a.balls_dest_offset.y)

                    for _, target in pairs(targets) do
                        local d = E:create_entity("damage")

                        d.damage_type = DAMAGE_EAT
                        d.target_id = target.id
                        d.source_id = this.id

                        queue_damage(store, d)

                        local fx = E:create_entity(a.hit_fx)

                        fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
                        fx.render.sprites[1].name = fx.render.sprites[1].size_names[target.unit.size]
                        fx.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, fx)

                        local b = E:create_entity(a.ball)

                        b.from = V.v(target.pos.x + target.unit.mod_offset.x, target.pos.y + target.unit.mod_offset.y)
                        b.to = V.v(this.pos.x + o.x, this.pos.y + o.y)
                        b.pos = V.vclone(b.from)
                        b.target = target

                        queue_insert(store, b)
                        table.insert(balls, b)
                    end

                    U.y_animation_wait(this)
                    U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                    while true do
                        coroutine.yield()

                        local arrived = true

                        for _, ball in pairs(balls) do
                            arrived = arrived and ball.arrived
                        end

                        if arrived then
                            break
                        end

                        if h.dead then
                            goto label_154_0
                        end
                    end

                    SU.hero_gain_xp_from_skill(this, skill)
                    U.animation_start(this, a.animations[3], nil, store.tick_ts, false)
                    U.y_animation_wait(this)

                    a.ts = store.tick_ts
                end
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.arcanenova

            if ready_to_use_skill(a, store) then
                local target, targets = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                    a.cast_time, a.vis_flags, a.vis_bans)

                if not target or #targets < 2 then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    local af = target.pos.x < this.pos.x

                    U.animation_start(this, a.animation, af, store.tick_ts, false)
                    U.y_wait(store, a.hit_time)

                    local node = table.deepclone(target.nav_path)

                    node.spi = 1

                    local node_pos = P:node_pos(node)
                    local targets = U.find_enemies_in_range(store, node_pos, 0, a.damage_radius, a.vis_flags,
                        a.vis_bans)

                    if targets then
                        SU.hero_gain_xp_from_skill(this, skill)

                        for _, t in pairs(targets) do
                            queue_damage(store, SU.create_attack_damage(a, t.id, this))

                            local m = E:create_entity(a.mod)

                            m.modifier.source_id = this.id
                            m.modifier.target_id = t.id
                            queue_insert(store, m)
                        end
                    end

                    S:queue(a.cast_sound)

                    local fx = E:create_entity(a.hit_fx)

                    fx.pos.x, fx.pos.y = node_pos.x, node_pos.y

                    U.animation_start(fx, nil, nil, store.tick_ts, false)
                    queue_insert(store, fx)
                    U.y_wait(store, fts(5))

                    local decal = E:create_entity(a.hit_decal)

                    decal.pos.x, decal.pos.y = node_pos.x, node_pos.y
                    decal.tween.ts = store.tick_ts
                    decal.render.sprites[2].ts = store.tick_ts

                    queue_insert(store, decal)
                    U.y_animation_wait(this)

                    a.ts = store.tick_ts
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.shackles

            if ready_to_use_skill(a, store) then
                local triggers = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not triggers then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    local first_target = table.random(triggers)
                    local targets = U.find_enemies_in_range(store, first_target.pos, 0, a.radius, a.vis_flags,
                        a.vis_bans)
                    local af = first_target.pos.x < this.pos.x

                    U.animation_start(this, a.animation, af, store.tick_ts, false)
                    U.y_wait(store, a.cast_time)
                    S:queue(a.cast_sound)
                    SU.hero_gain_xp_from_skill(this, skill)

                    for i = 1, math.min(#targets, a.max_count) do
                        local target = targets[i]

                        for _, m_name in pairs(a.mods) do
                            local m = E:create_entity(m_name)

                            m.modifier.target_id = target.id
                            m.modifier.source_id = this.id

                            queue_insert(store, m)
                        end
                    end

                    U.y_animation_wait(this)

                    a.ts = store.tick_ts
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                if target and target.pos and valid_rally_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            else
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
        end

        ::label_154_0::

        coroutine.yield()
    end
end

scripts.hero_veznan_ultimate = {}

function scripts.hero_veznan_ultimate.update(this, store)
    local e = E:create_entity(this.entity)

    e.pos.x, e.pos.y = this.pos.x, this.pos.y
    e.nav_rally.pos = V.vclone(e.pos)
    e.nav_rally.center = V.vclone(e.pos)

    queue_insert(store, e)

    local targets = U.find_enemies_in_range(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans)

    if targets then
        for _, target in pairs(targets) do
            local m = E:create_entity(this.mod)

            m.modifier.source_id = this.id
            m.modifier.target_id = target.id

            queue_insert(store, m)
        end
    end

    queue_remove(store, this)
end

scripts.hero_durax = {}

function scripts.hero_durax.get_info(this)
    local info = scripts.hero_basic.get_info(this)

    if this.clone then
        info.respawn = nil
    end

    return info
end

function scripts.hero_durax.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    local upgrade_all_skill = function()
        upgrade_skill(this, "crystallites", function(this, s)
            local a = this.timed_attacks.list[2]
            a.disabled = nil
        end)
        upgrade_skill(this, "armsword", function(this, s)
            local a = this.melee.attacks[3]
            a.disabled = nil
            a.damage_min = s.damage[s.level]
            a.damage_max = s.damage[s.level]
        end)

        upgrade_skill(this, "lethal_prism", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.ray_count = s.ray_count[s.level]

            local b = E:get_template(a.bullet)

            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
        end)
        upgrade_skill(this, "shardseed", function(this, s)
            local a = this.ranged.attacks[1]
            a.disabled = nil

            local b = E:get_template(a.bullet)

            b.bullet.damage_max = s.damage[s.level]
            b.bullet.damage_min = s.damage[s.level]
        end)

        upgrade_skill(this, "ultimate", function(this, s)
            this.ultimate.disabled = nil
            local u = E:get_template(s.controller_name)
            u.max_count = s.max_count[s.level]
            u.damage = s.damage[s.level]
        end)
    end

    if this.clone and not this.first_updated then
        local level = this.hero.level
        for i = 1, level do
            this.hero.level = i
            upgrade_all_skill()
        end
        this.first_updated = true
    else
        upgrade_all_skill()
    end

    this.health.hp = this.health.hp_max
end

function scripts.hero_durax.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta, decal

    this.health_bar.hidden = false

    if not this.clone then
        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        decal = E:create_entity("decal_durax")
        decal.pos = this.pos

        queue_insert(store, decal)
    end

    while true do
        if h.dead or this.clone and store.tick_ts - this.clone.ts > this.clone.duration then
            if this.clone then
                this.ui.can_click = false
                this.health.hp = 0
                signal.emit("hero-removed-no-panel", this)
                SU.y_soldier_death(store, this)

                this.tween.disabled = nil
                this.tween.ts = store.tick_ts

                return
            else
                decal.render.sprites[1].hidden = true

                SU.y_hero_death_and_respawn(store, this)

                decal.render.sprites[1].hidden = nil
            end
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_161_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.lethal_prism

            if ready_to_use_skill(a, store) then
                local triggers = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not triggers then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    SU.remove_modifiers(store, this)

                    this.health_bar.hidden = true
                    this.health.ignore_damage = true

                    local vis_flags = this.vis.flags
                    local vis_bans = this.vis.bans

                    this.vis.flags = U.flag_clear(this.vis.flags, F_RANGED)
                    this.vis.bans = F_ALL

                    U.y_animation_play(this, a.animations[1], nil, store.tick_ts)
                    U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                    for i = 1, a.ray_count do
                        local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                        if target then
                            local bo = a.bullet_start_offset[1]
                            local b = E:create_entity(a.bullet)
                            b.bullet.damage_factor = this.unit.damage_factor
                            b.bullet.target_id = target.id
                            b.bullet.source_id = this.id
                            b.pos = V.v(this.pos.x + bo.x, this.pos.y + bo.y)
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.vclone(target.pos)

                            queue_insert(store, b)
                        end

                        U.y_wait(store, a.ray_cooldown)
                    end

                    U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                    this.vis.flags = vis_flags
                    this.vis.bans = vis_bans
                    this.health.ignore_damage = nil
                    this.health_bar.hidden = nil
                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, skill)

                    goto label_161_0
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.crystallites

            if not this.clone and ready_to_use_skill(a, store) then
                local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_RALLY)

                if #nearest < 1 then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    local ns = {}

                    ns.pi = nearest[1][1]
                    ns.spi = math.random(1, 3)
                    ns.ni = nearest[1][3] - math.random(a.nodes_offset[1], a.nodes_offset[2])

                    local node_pos = P:node_pos(ns)

                    if not P:is_node_valid(ns.pi, ns.ni, NF_RALLY) or
                        band(GR:cell_type(node_pos.x, node_pos.y), bor(TERRAIN_NOWALK, TERRAIN_FAERIE)) ~= 0 then
                        SU.delay_attack(store, a, 0.3333333333333333)
                    else
                        S:queue(a.sound)
                        U.animation_start(this, a.animation, nil, store.tick_ts, false)
                        U.y_wait(store, a.spawn_time)

                        local spawn_pos = V.v(this.pos.x + (this.render.sprites[1].flip_x and -1 or 1) *
                                                  a.spawn_offset.x, this.pos.y + a.spawn_offset.y)
                        local clone = E:create_entity(a.entity)

                        clone.pos = spawn_pos
                        clone.nav_rally.pos = node_pos
                        clone.nav_rally.center = V.vclone(node_pos)
                        clone.nav_rally.new = true
                        clone.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                        clone.clone.ts = store.tick_ts
                        clone.clone.duration = skill.duration[skill.level]
                        clone.hero.level = this.hero.level
                        clone.hero.xp = this.hero.xp
                        clone.unit.damage_factor = 0.8 * this.unit.damage_factor

                        for sn, s in pairs(this.hero.skills) do
                            clone.hero.skills[sn].level = s.level
                        end

                        queue_insert(store, clone)
                        signal.emit("hero-added-no-panel", clone)
                        SU.hero_gain_xp_from_skill(this, skill)
                        U.y_animation_wait(this)

                        a.ts = store.tick_ts
                    end
                end
            end

            if ready_to_use_skill(this.ultimate, store) then

                local target = U.find_foremost_enemy(store, this.pos, 0, this.ranged.attacks[1].max_range, 0,
                    F_RANGED, 0)

                if target and target.pos and
                    scripts.hero_durax_ultimate.can_fire_fn(nil, target.pos.x, target.pos.y, store) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(target.pos)
                    e.damage_factor = this.unit.damage_factor
                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            if not this.ranged.attacks[1].disabled then
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    goto label_161_0
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_161_0::

        coroutine.yield()
    end
end

scripts.hero_durax_ultimate = {}

function scripts.hero_durax_ultimate.can_fire_fn(this, x, y, store)
    for _, e in pairs(store.enemies) do
        if e.pos and e.ui and e.ui.can_click and e.nav_path and not e.health.dead and band(e.vis.flags, F_FLYING) == 0 and
            band(e.vis.bans, F_MOD) == 0 and
            U.is_inside_ellipse(V.v(e.pos.x + e.unit.hit_offset.x, e.pos.y + e.unit.hit_offset.y), V.v(x, y), 250) and
            P:is_node_valid(e.nav_path.pi, e.nav_path.ni, NF_POWER_1) then
            return true
        end
    end
    return false
end

function scripts.hero_durax_ultimate.update(this, store)
    this.damage = this.damage * this.damage_factor
    local targets = U.find_enemies_in_range(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
        function(e)
            return band(e.vis.flags, F_BOSS) ~= 0 or band(e.vis.bans, F_STUN) == 0
        end)

    if targets then
        local single = #targets == 1

        for i, target in pairs(targets) do
            if i > this.max_count then
                break
            end

            local d = E:create_entity("damage")

            d.value = this.damage / #targets
            d.damage_type = this.damage_type
            d.target_id = target.id
            d.source_id = this.id

            queue_damage(store, d)

            if target.unit.blood_color ~= BLOOD_NONE then
                local sfx = E:create_entity(this.hit_blood_fx)

                sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
                sfx.render.sprites[1].ts = store.tick_ts

                if sfx.use_blood_color and target.unit.blood_color then
                    sfx.render.sprites[1].name = target.unit.blood_color
                end

                queue_insert(store, sfx)
            end

            local m = E:create_entity(band(target.vis.flags, F_BOSS) ~= 0 and this.mod_slow or this.mod_stun)

            m.modifier.target_id = target.id
            m.modifier.source_id = this.id

            queue_insert(store, m)

            local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_" .. (single and "1" or "2"), target.pos)

            fx.render.sprites[1].scale = fx.render.sprites[1].size_scales[target.unit.size]

            local spikes_count = single and 12 or 8
            local radius = single and 40 or 30
            local angle = U.frandom(0, math.pi)

            for j = 1, spikes_count do
                local p = U.point_on_ellipse(target.pos, U.frandom(0.5, 1) * radius, angle)

                angle = angle + math.pi / 4.2

                local fx = SU.insert_sprite(store, "fx_durax_ultimate_fang_extra_" .. math.random(1, 2), p, nil,
                    U.frandom(0.1, 0.2))

                fx.render.sprites[1].scale = V.vv(U.frandom(0.8, 1.1))
            end
        end
    end

    queue_remove(store, this)
end

scripts.hero_elves_denas = {}

function scripts.hero_elves_denas.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "sybarite", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        local m = E:get_template("mod_elves_denas_sybarite")

        m.heal_hp = s.heal_hp[s.level]
    end)
    upgrade_skill(this, "celebrity", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.max_targets = s.max_targets[s.level]

        local m = E:get_template("mod_elves_denas_celebrity")

        m.modifier.duration = s.stun_duration[s.level]
    end)

    upgrade_skill(this, "mighty", function(this, s)
        local a = this.melee.attacks[3]
        a.disabled = nil
        a.damage_min = s.damage_min[s.level]
        a.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "shield_strike", function(this, s)
        local a = this.ranged.attacks[1]
        a.disabled = nil

        local b = E:get_template("shield_elves_denas")
        b.max_rebounds = s.rebounds[s.level]
        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        this.ultimate.cooldown = s.cooldown[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_elves_denas.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.melee.order = U.attack_order(this.melee.attacks)

    return true
end

function scripts.hero_elves_denas.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    local function shield_strike_filter_fn(e, origin)
        local a = this.ranged.attacks[1]
        local targets = U.find_enemies_in_range(store, e.pos, 0, a.rebound_range, a.vis_flags, a.vis_bans)

        return targets and #targets > 1
    end

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_66_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.celebrity

            if ready_to_use_skill(a, store) then
                local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans,
                    function(e)
                        return e.unit and not e.unit.is_stunned
                    end)

                if not target then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, skill)
                    U.animation_start(this, a.animation, nil, store.tick_ts)
                    U.y_wait(store, fts(22))
                    S:queue(a.sound)

                    local total_time = fts(52)
                    local flash_every = 1

                    for i = 1, 9 do
                        if SU.hero_interrupted(this) then
                            a.ts = a.ts - 0.1 * (9 - i) * a.cooldown
                            goto label_66_0
                        end

                        if i % flash_every == 0 then
                            local sfx = E:create_entity("fx_elves_denas_flash")

                            sfx.pos.x, sfx.pos.y = this.pos.x + math.random(-25, 25), this.pos.y + math.random(5, 40)
                            sfx.render.sprites[1].ts = store.tick_ts
                            sfx.render.sprites[1].flip_x = math.random() < 0.5

                            queue_insert(store, sfx)
                        end

                        if i <= a.max_targets then
                            target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans,
                                function(e)
                                    return e.unit and not e.unit.is_stunned
                                end)
                            target = target or
                                         U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags,
                                    a.vis_bans)

                            if target then
                                local mod = E:create_entity("mod_elves_denas_celebrity")

                                mod.modifier.target_id = target.id

                                queue_insert(store, mod)
                            end
                        end

                        U.y_wait(store, total_time / 9)
                    end

                    U.y_animation_wait(this)
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                if target and target.pos and valid_rally_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(target.pos)
                    e.owner = this
                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.sybarite

            if ready_to_use_skill(a, store) and this.health.hp <= this.health.hp_max - a.lost_health then
                U.animation_start(this, a.animation, nil, store.tick_ts)

                if SU.y_hero_wait(store, this, a.hit_time) then
                    goto label_66_0
                end

                a.ts = store.tick_ts

                S:queue(a.sound)

                local mod = E:create_entity(a.mod)

                mod.modifier.target_id = this.id
                mod.modifier.source_id = this.id

                queue_insert(store, mod)
                U.y_animation_wait(this)
                SU.hero_gain_xp_from_skill(this, skill)
            end

            a = this.ranged.attacks[1]
            skill = this.hero.skills.shield_strike

            if ready_to_use_skill(a, store) then
                local target, _, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range, a.max_range,
                    a.node_prediction, a.vis_flags, a.vis_bans, shield_strike_filter_fn, F_FLYING)

                if target then
                    local start_ts = store.tick_ts
                    local attack_done = SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos)

                    if attack_done then
                        a.ts = start_ts
                    else
                        goto label_66_0
                    end
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                a = this.wealthy

                if store.wave_group_number > a.last_wave then
                    a.last_wave = store.wave_group_number

                    S:queue(a.sound)

                    store.player_gold = store.player_gold + a.gold

                    U.animation_start(this, "coinThrow", nil, store.tick_ts)
                    U.y_wait(store, a.hit_time)

                    local fx = E:create_entity(a.fx)

                    fx.render.sprites[1].ts = store.tick_ts
                    fx.pos.x, fx.pos.y = this.pos.x + (this.render.sprites[1].flip_x and 1 or -1) * 20, this.pos.y
                    fx.tween.props[2] = E:clone_c("tween_prop")
                    fx.tween.props[2].name = "offset"
                    fx.tween.props[2].keys = {{0, V.v(0, 40)}, {0.5, V.v(0, 50)}}

                    queue_insert(store, fx)
                    U.y_animation_wait(this)
                end

                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_66_0::

        coroutine.yield()
    end
end

scripts.hero_elves_denas_ultimate = {}

function scripts.hero_elves_denas_ultimate.update(this, store)
    local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

    if #nearest > 1 then
        local pi, spi, ni = unpack(nearest[1])
        local pos = P:node_pos(pi, 1, ni)
        local count = this.guards_count[this.level]

        for i = 1, count do
            local p = U.point_on_ellipse(pos, 25, i * 2 * math.pi / count)
            local e = E:create_entity(this.guards_template)

            e.pos = p
            e.nav_rally.center = V.vclone(e.pos)
            e.nav_rally.pos = V.vclone(e.pos)
            e.melee.attacks[1].xp_dest_id = this.owner.id
            e.melee.attacks[2].xp_dest_id = this.owner.id

            queue_insert(store, e)
        end
    end

    queue_remove(store, this)
end

scripts.mod_elves_denas_sybarite = {}

function scripts.mod_elves_denas_sybarite.insert(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if not target or not target.health or target.health.dead then
        return false
    end

    target.unit.damage_factor = target.unit.damage_factor * this.inflicted_damage_factor
    target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + this.heal_hp)
    this.render.sprites[1].ts = store.tick_ts

    return true
end

function scripts.mod_elves_denas_sybarite.remove(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if target then
        target.unit.damage_factor = target.unit.damage_factor / this.inflicted_damage_factor
    end

    return true
end

scripts.shield_elves_denas = {}

function scripts.shield_elves_denas.update(this, store)
    local b = this.bullet
    local mspeed = b.max_speed
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local ps
    local bounce_count = 0
    local visited = {}

    U.animation_start(this, nil, nil, store.tick_ts, true)

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    ::label_75_0::

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead then
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
        end

        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
        this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

        coroutine.yield()
    end

    if target and not target.health.dead then
        table.insert(visited, target.id)

        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)

        if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
            local sfx = E:create_entity(b.hit_blood_fx)

            sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
            sfx.render.sprites[1].ts = store.tick_ts

            if sfx.use_blood_color and target.unit.blood_color then
                sfx.render.sprites[1].name = target.unit.blood_color
                sfx.render.sprites[1].r = this.render.sprites[1].r
            end

            queue_insert(store, sfx)
        end
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
        sfx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, sfx)
    end

    if bounce_count < this.max_rebounds then
        local last_target = target

        ::label_75_1::

        target = U.find_random_enemy(store, this.pos, 0, this.rebound_range, b.vis_flags, b.vis_bans,
            function(v)
                return not table.contains(visited, v.id)
            end)

        if not target and #visited > 1 then
            visited = {last_target.id}

            goto label_75_1
        end

        if target then
            S:queue(this.sound_events.bounce)

            bounce_count = bounce_count + 1
            b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
            b.target_id = target.id

            goto label_75_0
        end
    end

    queue_remove(store, this)
end

scripts.hero_arivan = {}

function scripts.hero_arivan.level_up(this, store)
    local hl, ls = level_up_basic(this)
    this.melee_raw_min = ls.melee_damage_min[hl]
    this.melee_raw_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)

    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "icy_prison", function(this, s)
        local a = this.ranged.attacks[3]
        a.disabled = nil
        local b = E:get_template(a.bullet)
        b.bullet.damage_min = s.damage[s.level]
        b.bullet.damage_max = s.damage[s.level]
        local m = E:get_template(b.bullet.mod)
        m.modifier.duration = s.duration[s.level]
    end)
    upgrade_skill(this, "lightning_rod", function(this, s)
        local a = this.ranged.attacks[2]
        a.disabled = nil
        local b = E:get_template(a.bullet)
        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "seal_of_fire", function(this, s)
        local a = this.timed_attacks.list[1]
        a.disabled = nil
        a.loops = s.count[s.level]
    end)

    upgrade_skill(this, "stone_dance", function(this, s)
        local a = this.timed_attacks.list[2]
        a.disabled = nil
        a.ts = -a.cooldown + 2
        local aura = E:get_template("aura_arivan_stone_dance")
        aura.max_stones = s.count[s.level]
        this.stone_extra_per_stone = s.stone_extra[s.level]
        if a.aura then
            a.aura.max_stones = s.count[s.level]
            this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
        end
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template("hero_arivan_ultimate")
        local tal = u.timed_attacks.list
        local mf = E:get_template("mod_arivan_ultimate_freeze")

        u.aura.duration = s.duration[s.level]
        tal[2].damage_max = s.damage[s.level]
        tal[2].damage_min = s.damage[s.level]
        mf.modifier.duration = s.freeze_duration[s.level]
        tal[3].chance = s.freeze_chance[s.level]
        tal[4].cooldown = s.lightning_cooldown[s.level]
        tal[4].chance = s.lightning_chance[s.level]
    end)

    this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
    this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
    this.health.hp = this.health.hp_max
end

function scripts.hero_arivan.on_damage(this, store, damage)
    local function quick_cooldown(a)
        a.ts = a.ts - 1
    end
    log.debug(" ARIVAN DAMAGE: %s", damage.value)

    local at = this.timed_attacks.list[2]
    local a = at.aura

    if not a or #a.stones < 1 then
        return true
    end

    local stone = a.stones[#a.stones]

    stone.hp = stone.hp - damage.value

    if stone.hp <= 0 then
        local fx = E:create_entity("fx_arivan_stone_explosion")

        fx.pos = stone.pos
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
        queue_remove(store, stone)
        table.remove(a.stones, #a.stones)
        quick_cooldown(this.ranged.attacks[2])
        quick_cooldown(this.ranged.attacks[3])
        quick_cooldown(this.timed_attacks.list[1])
        quick_cooldown(this.ultimate)
        this.stone_extra = #a.stones * this.stone_extra_per_stone
        this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
        this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
    end

    a.shield_active = true

    return false
end

function scripts.hero_arivan.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.melee.order = U.attack_order(this.melee.attacks)
    this.ranged.order = U.attack_order(this.ranged.attacks)

    local a = E:create_entity("aura_arivan_stone_dance")

    a.aura.source_id = this.id
    a.aura.ts = store.tick_ts
    a.pos = this.pos
    this.timed_attacks.list[2].aura = a

    queue_insert(store, a)

    return true
end

function scripts.hero_arivan.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_90_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.stone_dance

            if not a.disabled and #a.aura.stones == a.aura.max_stones then
                a.ts = store.tick_ts
            end

            if ready_to_use_skill(a, store) and #a.aura.stones < a.aura.max_stones then
                S:queue(a.sound)
                U.animation_start(this, a.animation, nil, store.tick_ts)
                U.y_wait(store, a.hit_time)

                local aura = a.aura

                for i = #a.aura.stones + 1, aura.max_stones do
                    local stone = E:create_entity("arivan_stone")
                    local angle = i * 2 * math.pi / aura.max_stones % (2 * math.pi)

                    stone.pos = U.point_on_ellipse(this.pos, aura.rot_radius, angle)
                    stone.render.sprites[1].name = string.format(stone.render.sprites[1].name, i)
                    stone.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, stone)
                    table.insert(aura.stones, stone)
                end

                aura.aura.ts = store.tick_ts

                this.stone_extra = #a.aura.stones * this.stone_extra_per_stone
                this.melee.attacks[1].damage_min = this.melee_raw_min + this.stone_extra
                this.melee.attacks[1].damage_max = this.melee_raw_max + this.stone_extra
                U.y_animation_wait(this)

                a.ts = store.tick_ts

                goto label_90_0
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.seal_of_fire

            if ready_to_use_skill(a, store) then
                local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, 0.26666666666666666)
                else
                    local pred_pos = target.pos
                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, a.animations[1], pred_pos)

                    U.y_animation_play(this, an, af, store.tick_ts, 1)

                    for i = 1, a.loops do
                        an, af = U.animation_name_facing_point(this, a.animations[2], pred_pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        for si, st in pairs(a.shoot_times) do
                            while st > store.tick_ts - this.render.sprites[1].ts do
                                if SU.hero_interrupted(this) then
                                    goto label_90_0
                                end

                                coroutine.yield()
                            end

                            local offset = a.bullet_start_offset[si]
                            local b = E:create_entity(a.bullet)

                            target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range,
                                a.vis_flags, a.vis_bans)

                            if target then
                                local dist = V.dist(this.pos.x, this.pos.y + offset.y, target.pos.x, target.pos.y)

                                pred_pos = P:predict_enemy_pos(target, dist / b.bullet.min_speed)
                            end

                            a.ts = store.tick_ts
                            b.pos = V.vclone(this.pos)
                            b.pos.x, b.pos.y = b.pos.x + (af and -1 or 1) * offset.x, b.pos.y + offset.y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.vclone(pred_pos)
                            b.bullet.to.x, b.bullet.to.y = b.bullet.to.x + U.frandom(-1, 1),
                                b.bullet.to.y + U.frandom(-1, 1)
                            b.bullet.source_id = this.id
                            b.bullet.xp_dest_id = this.id
                            b.bullet.damage_factor = this.unit.damage_factor
                            b.bullet.damage_min = b.bullet.damage_min + this.damage_buff
                            b.bullet.damage_max = b.bullet.damage_max + this.damage_buff
                            queue_insert(store, b)
                        end

                        while not U.animation_finished(this) do
                            if SU.hero_interrupted(this) then
                                goto label_90_0
                            end

                            coroutine.yield()
                        end
                    end

                    SU.hero_gain_xp_from_skill(this, skill)
                    U.animation_start(this, a.animations[3], nil, store.tick_ts, false)

                    while not U.animation_finished(this) do
                        if SU.hero_interrupted(this) then
                            break
                        end

                        coroutine.yield()
                    end

                    goto label_90_0
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true, true)

                if target and target.pos and valid_twister_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.level = this.hero.skills.ultimate.level
                    e.pos = V.vclone(target.pos)
                    e.owner = this
                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            if this.soldier.target_id then
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    goto label_90_0
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                goto label_90_0
            end

            brk, sta = SU.y_soldier_ranged_attacks(store, this)

            if brk then
                goto label_90_0
            end

            if SU.soldier_go_back_step(store, this) then
                goto label_90_0
            end
            -- brk, sta = SU.y_soldier_ranged_attacks(store, this)

            -- if brk then
            --     -- block empty
            -- elseif SU.soldier_go_back_step(store, this) then
            --     -- block empty
            -- else
            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
            -- end
        end

        ::label_90_0::

        coroutine.yield()
    end
end

scripts.fireball_arivan = {}

function scripts.fireball_arivan.update(this, store)
    local b = this.bullet
    local mspeed = b.min_speed
    local target, ps

    S:queue(this.sound_events.summon)
    U.animation_start(this, "idle", nil, store.tick_ts, false)
    U.y_wait(store, this.idle_time)

    ps = E:create_entity(b.particles_name)
    ps.particle_system.track_id = this.id

    queue_insert(store, ps)
    S:queue(this.sound_events.travel)

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > 2 * (mspeed * store.tick_length) do
        coroutine.yield()

        mspeed = mspeed + FPS * math.ceil(mspeed * (1 / FPS) * b.acceleration_factor)
        mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
        this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

        if ps then
            ps.particle_system.emit_direction = this.render.sprites[1].r
        end
    end

    local targets = U.find_enemies_in_range(store, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

    if targets then
        for _, target in pairs(targets) do
            local d = E:create_entity("damage")

            d.damage_type = b.damage_type
            d.value = U.frandom(b.damage_min, b.damage_max) * b.damage_factor
            d.source_id = this.id
            d.target_id = target.id

            queue_damage(store, d)
        end
    end

    S:queue(this.sound_events.hit)

    if b.hit_fx then
        local fx = E:create_entity(b.hit_fx)

        fx.pos = V.vclone(b.to)
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    end

    coroutine.yield()
    queue_remove(store, this)
end

scripts.aura_arivan_stone_dance = {}

function scripts.aura_arivan_stone_dance.update(this, store)
    local rot_phase = 0
    local owner = store.entities[this.aura.source_id]

    if not owner then
        log.error("aura_arivan_stone_dance owner is missing.")
        queue_remove(store, this)
        return
    end

    while true do
        if owner.health.dead and #this.stones > 1 then
            for i = #this.stones, 1, -1 do
                local stone = this.stones[i]
                local fx = E:create_entity("fx_arivan_stone_explosion")

                fx.pos = stone.pos
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)
                queue_remove(store, stone)
                table.remove(this.stones, i)
            end
        end

        if this.shield_active then
            this.shield_active = false

            local s = this.render.sprites[1]

            s.hidden = false
            s.ts = store.tick_ts
            s.runs = 0
            s.flip_x = owner.render.sprites[1].flip_x
        end

        if store.tick_ts - this.aura.ts > fts(13) then
            rot_phase = rot_phase + this.rot_speed * store.tick_length
        end

        for i, t in ipairs(this.stones) do
            local a = (i * 2 * math.pi / this.max_stones + rot_phase) % (2 * math.pi)

            t.pos = U.point_on_ellipse(this.pos, this.rot_radius, a)
        end

        if #this.stones < 1 then
            owner.vis.bans = band(owner.vis.bans, bnot(this.owner_vis_bans))
        else
            owner.vis.bans = bor(owner.vis.bans, this.owner_vis_bans)
        end

        coroutine.yield()
    end
end

scripts.hero_arivan_ultimate = {}

function scripts.hero_arivan_ultimate.update(this, store)
    local np = this.nav_path
    local nodes_step = this.aura.nodes_step
    local last_freeze_target
    local targets = U.find_enemies_in_paths(store.enemies, this.pos, 0, this.aura.range_nodes, nil, this.aura.vis_flags,
        this.aura.vis_bans, true)

    if targets then
        local o = targets[1].origin

        np.pi, np.spi, np.ni = o[1], 1, o[3] + 3
    else
        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_TWISTER)

        if #nodes < 1 then
            coroutine.yield()

            goto label_95_1
        end

        local o = nodes[1]

        np.pi, np.spi, np.ni = o[1], 1, o[3]
    end

    this.pos = P:node_pos(np)

    U.y_animation_play(this, "start", nil, store.tick_ts)
    U.animation_start(this, "travel", nil, store.tick_ts, true)

    this.aura.ts = store.tick_ts

    while true do
        local next_pos = P:node_pos(np.pi, np.spi, np.ni + nodes_step)

        if P:is_node_valid(np.pi, np.ni + nodes_step, NF_TWISTER) and
            band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
            np.ni = np.ni + nodes_step
        end

        np.spi = np.spi == 2 and 3 or 2

        U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

        while not this.motion.arrived do
            if store.tick_ts - this.aura.ts > this.aura.duration or
                band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) ~= 0 then
                goto label_95_0
            end

            U.walk(this, store.tick_length)

            for ai, a in ipairs(this.timed_attacks.list) do
                if store.tick_ts - a.ts < a.cooldown then
                    -- block empty
                else
                    a.ts = store.tick_ts

                    if a.chance and (a.chance == 0 or math.random() >= a.chance) then
                        -- block empty
                    else
                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                            a.vis_bans)

                        if not targets then
                            if ai == 3 then
                                last_freeze_target = nil
                            end
                        elseif ai == 1 then
                            for _, target in pairs(targets) do
                                local mod = E:create_entity(a.mod)

                                mod.modifier.target_id = target.id

                                queue_insert(store, mod)
                            end
                        elseif ai == 2 then
                            for _, target in pairs(targets) do
                                local d = E:create_entity("damage")

                                d.damage_type = a.damage_type
                                d.value = a.damage_max
                                d.source_id = this.id
                                d.target_id = target.id

                                queue_damage(store, d)
                            end
                        elseif ai == 3 then
                            local mod = E:create_entity(a.mod)

                            mod.modifier.target_id = targets[1].id

                            queue_insert(store, mod)

                            last_freeze_target = targets[1].id
                        elseif a.type == "bullet" then
                            if #targets > 1 and last_freeze_target then
                                table.removeobject(targets, last_freeze_target)
                            end

                            local target = table.random(targets)
                            local b = E:create_entity(a.bullet)

                            b.pos = V.vclone(this.pos)
                            b.pos.x = b.pos.x + (target.pos.x > this.pos.x and 1 or -1) * a.bullet_start_offset[1].x
                            b.pos.y = b.pos.y + a.bullet_start_offset[1].y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                target.pos.y + target.unit.hit_offset.y)
                            b.bullet.target_id = target.id
                            b.bullet.source_id = this.id

                            queue_insert(store, b)
                        end
                    end
                end
            end

            coroutine.yield()
        end
    end

    ::label_95_0::

    U.y_animation_play(this, "end", nil, store.tick_ts)

    ::label_95_1::

    queue_remove(store, this)
end

scripts.hero_phoenix = {}

function scripts.hero_phoenix.get_info(this)
    local b = E:get_template(this.ranged.attacks[1].bullet)
    local ba = E:get_template(b.bullet.hit_payload)
    local min, max = ba.aura.damage_min, ba.aura.damage_max

    return {
        type = STATS_TYPE_SOLDIER,
        hp = this.health.hp,
        hp_max = this.health.hp_max,
        ranged_damage_min = min,
        ranged_damage_max = max,
        damage_type = ba.aura.damage_type,
        armor = this.health.armor,
        respawn = this.health.dead_lifetime
    }
end

function scripts.hero_phoenix.level_up(this, store, initiaal)
    local hl, ls = level_up_basic(this)

    local b = E:get_template(this.ranged.attacks[1].bullet)
    local ba = E:get_template(b.bullet.hit_payload)

    ba.aura.damage_max = ls.ranged_damage_max[hl]
    ba.aura.damage_min = ls.ranged_damage_min[hl]

    local a = E:get_template("aura_phoenix_egg")

    a.custom_attack.damage_max = ls.egg_explosion_damage_max[hl]
    a.custom_attack.damage_min = ls.egg_explosion_damage_min[hl]

    local m = E:get_template(a.aura.mod)

    m.dps.damage_min = ls.egg_damage[hl]
    m.dps.damage_max = ls.egg_damage[hl]

    upgrade_skill(this, "inmolate", function(this, s)
        local sd = this.selfdestruct

        sd.disabled = nil
        sd.damage_min = s.damage_min[s.level]
        sd.damage_max = s.damage_max[s.level]

        local a = this.timed_attacks.list[1]

        a.disabled = nil
    end)

    upgrade_skill(this, "purification", function(this, s)
        local au = E:get_template("aura_phoenix_purification")
        au.aura.targets_per_cycle = s.max_targets[s.evel]

        for _, e in pairs(store.auras) do
            if e.template_name == "aura_phoenix_purification" then
                e.aura.targets_per_cycle = s.max_targets[s.level]
                break
            end
        end

        local b = E:get_template("missile_phoenix_small")
        b.bullet.damage_max = s.damage_max[s.level]
        b.bullet.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "blazing_offspring", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil
        a.shoot_times = {}

        for i = 1, s.count[s.level] do
            table.insert(a.shoot_times, fts(4))
        end

        local b = E:get_template(a.bullet)

        b.bullet.damage_max = s.damage_max[s.level]
        b.bullet.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "flaming_path", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil

        local m = E:get_template(a.mod)

        m.custom_attack.damage = s.damage[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local au = E:get_template(s.controller_name)

        au.aura.damage_max = s.damage_max[s.level]
        au.aura.damage_min = s.damage_min[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_phoenix.insert(this, store)
    if not scripts.hero_basic.insert(this, store) then
        return false
    end

    local a = E:create_entity("aura_phoenix_purification")

    a.aura.source_id = this.id
    a.aura.ts = store.tick_ts
    a.pos = this.pos

    queue_insert(store, a)

    return true
end

function scripts.hero_phoenix.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
            local respawn_point

            if #nodes < 1 then
                log.debug("hero_phoenix: could not find nearest node to place egg")

                respawn_point = store.level.custom_spawn_pos or store.level.locations.exits[1].pos
                this.selfdestruct.disabled = true
            else
                local pi, spi, ni, dist = unpack(nodes[1])

                respawn_point = P:node_pos(pi, spi, ni)

                if dist > 30 then
                    log.debug("hero_phoenix: too far from nearest path for inmolate")

                    this.selfdestruct.disabled = true
                end
            end

            local egg = E:create_entity("aura_phoenix_egg")

            if this.selfdestruct.disabled then
                this.hero.respawn_point = respawn_point
                egg.pos = V.vclone(respawn_point)
                egg.show_delay = fts(15)
            else
                egg.pos = V.vclone(this.pos)
                egg.show_delay = fts(28)
            end

            queue_insert(store, egg)
            U.sprites_hide(this, 2, 2)
            SU.y_hero_death_and_respawn(store, this)

            this.selfdestruct.disabled = this.hero.skills.inmolate.level < 1

            U.sprites_show(this, 2, 2)

            this.hero.respawn_point = nil

            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            -- block empty
        end

        if ready_to_use_skill(this.ultimate, store) then
            local targets = U.find_enemies_in_range(store, this.pos, 0, this.ranged.attacks[1].max_range,
                this.ranged.attacks[1].vis_flags, this.ranged.attacks[1].vis_bans)
            if targets and valid_land_node_nearby(this.pos) then
                S:queue(this.sound_events.change_rally_point)
                local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                e.level = this.hero.skills.ultimate.level
                e.pos = V.vclone(this.pos)
                e.owner = this
                e.damage_factor = this.unit.damage_factor

                queue_insert(store, e)

                this.ultimate.ts = store.tick_ts
                SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
            else
                this.ultimate.ts = this.ultimate.ts + 1
            end
        end

        a = this.timed_attacks.list[1]
        skill = this.hero.skills.inmolate

        if ready_to_use_skill(a, store) then
            local targets = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

            if not targets or #targets < a.min_count then
                SU.delay_attack(store, a, 0.16666666666666666)
            else
                a.ts = store.tick_ts
                h.dead = true
                h.hp = 0
                this.health_bar.hidden = true

                goto label_190_0
            end
        end

        a = this.timed_attacks.list[2]
        skill = this.hero.skills.flaming_path

        if ready_to_use_skill(a, store) then
            local targets = U.find_towers_in_range(store.towers, this.pos, a, function(e, o)
                local enemies = U.find_enemies_in_range(store, e.pos, 0, a.enemies_range, a.enemies_vis_flags,
                    a.enemies_vis_bans)

                return e.tower.can_be_mod and enemies and #enemies >= a.enemies_min_count
            end)

            if not targets then
                SU.delay_attack(store, a, 0.16666666666666666)
            else
                S:queue(a.sound, a.sound_args)
                U.animation_start(this, a.animation, nil, store.tick_ts)

                if SU.y_hero_wait(store, this, a.hit_time) then
                    -- block empty
                else
                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, skill)
                    table.sort(targets, function(e1, e2)
                        return V.dist(e1.pos.x, e1.pos.y, this.pos.x, this.pos.y) <
                                   V.dist(e2.pos.x, e2.pos.y, this.pos.x, this.pos.y)
                    end)

                    for i, target in ipairs(targets) do
                        if i > a.max_count then
                            break
                        end

                        local mod = E:create_entity(a.mod)

                        mod.modifier.target_id = target.id
                        mod.modifier.source_id = this.id
                        mod.pos.x, mod.pos.y = target.pos.x, target.pos.y

                        queue_insert(store, mod)
                    end

                    SU.y_hero_animation_wait(this)
                end

                goto label_190_0
            end
        end

        brk, sta = SU.y_soldier_ranged_attacks(store, this)

        if brk then
            -- block empty
        else
            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
        end

        ::label_190_0::

        coroutine.yield()
    end
end

scripts.hero_phoenix_ultimate = {}

function scripts.hero_phoenix_ultimate.update(this, store)
    local a = this.aura

    a.ts = store.tick_ts

    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)

    if #nodes < 1 then
        log.error("hero_phoenix_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local node = {
        pi = nodes[1][1],
        spi = nodes[1][2],
        ni = nodes[1][3]
    }

    this.pos = P:node_pos(node.pi, node.spi, node.ni)

    U.y_animation_play(this, "place", nil, store.tick_ts)
    U.y_wait(store, this.activate_delay)
    S:queue(this.sound_events.activate)
    U.y_animation_play(this, "activate", nil, store.tick_ts)

    this.tween.disabled = nil

    local targets

    while store.tick_ts - a.ts < a.duration and not targets do
        U.y_wait(store, 0.2)
        coroutine.yield()

        targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)
    end

    this.tween.disabled = true

    U.y_ease_key(store, this.render.sprites[2], "alpha", this.render.sprites[2].alpha, 255, 0.2)
    SU.insert_sprite(store, a.hit_fx, this.pos)
    SU.insert_sprite(store, a.hit_decal, this.pos)

    targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.damage_vis_bans)

    if targets then
        for _, t in pairs(targets) do
            local d = E:create_entity("damage")

            d.value = math.random(a.damage_min, a.damage_max) * this.damage_factor
            d.damage_type = a.damage_type
            d.target_id = t.id
            d.source_id = this.id

            queue_damage(store, d)
        end
    end

    S:queue(this.sound_events.explode)
    queue_remove(store, this)
end
scripts.hero_bravebark = {}

function scripts.hero_bravebark.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "rootspikes", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.ts = store.tick_ts
        a.damage_max = s.damage_max[s.level]
        a.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "oakseeds", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.ts = store.tick_ts

        local st = E:get_template(a.entity)

        st.health.hp_max = s.soldier_hp_max[s.level]
        st.melee.attacks[1].damage_max = s.soldier_damage_max[s.level]
        st.melee.attacks[1].damage_min = s.soldier_damage_min[s.level]
    end)

    upgrade_skill(this, "branchball", function(this, s)
        local a = this.melee.attacks[2]

        a.hp_max = s.hp_max[s.level]
        a.disabled = nil
        a.ts = store.tick_ts
    end)
    upgrade_skill(this, "springsap", function(this, s)
        local a = this.springsap

        a.disabled = nil
        a.ts = store.tick_ts

        local aura = E:get_template(a.aura)

        aura.aura.duration = s.duration[s.level]

        local mod = E:get_template(aura.aura.mod)

        mod.hps.heal_min = s.hp_per_cycle[s.level]
        mod.hps.heal_max = s.hp_per_cycle[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template("hero_bravebark_ultimate")

        u.count = s.count[s.level]
        u.damage = s.damage[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_bravebark.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    local function spawn_spikes(count, center, radius, angle, delay, scale)
        for i = 1, count do
            local p = U.point_on_ellipse(center, radius - math.random(0, 5), angle + i * 2 * math.pi / count)
            local e = E:create_entity("decal_bravebark_rootspike")

            e.pos.x, e.pos.y = p.x, p.y
            e.delay = delay
            e.scale = scale

            queue_insert(store, e)
        end
    end

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_119_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.springsap
            skill = this.hero.skills.springsap

            if ready_to_use_skill(a, store) and soldiers_around_need_heal(this, store, a.trigger_hp_factor, a.radius) then
                a.ts = store.tick_ts

                SU.hero_gain_xp_from_skill(this, skill)
                S:queue(a.sound)
                U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

                local aura = E:create_entity(a.aura)

                aura.pos.x, aura.pos.y = this.pos.x, this.pos.y
                aura.tween.ts = store.tick_ts
                aura.aura.radius = a.radius
                queue_insert(store, aura)
                U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                while store.tick_ts - a.ts <= aura.aura.duration do
                    if SU.hero_interrupted(this) then
                        queue_remove(store, aura)

                        break
                    end

                    coroutine.yield()
                end

                U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                a.ts = store.tick_ts

                goto label_119_0
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.oakseeds

            if ready_to_use_skill(a, store) then
                local target = U.find_foremost_enemy(store, this.pos, 0, a.max_range, 0.5, a.vis_flags,
                    a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    local node_offset = P:predict_enemy_node_advance(target, 0.5)
                    local ni = target.nav_path.ni + node_offset

                    S:queue(a.sound)

                    local af = target.pos.x < this.pos.x

                    U.animation_start(this, a.animation, af, store.tick_ts)

                    if U.y_wait(store, a.spawn_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        for i = 1, a.count do
                            ni = ni + math.random(4, 6)

                            if not P:is_node_valid(target.nav_path.pi, ni) then
                                -- block empty
                            else
                                local e = E:create_entity(a.entity)

                                e.pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, ni)
                                e.nav_rally.center = V.vclone(e.pos)
                                e.nav_rally.pos = V.vclone(e.pos)
                                e.melee.attacks[1].xp_dest_id = this.id

                                local b = E:create_entity(a.bullet)

                                b.pos.x, b.pos.y = this.pos.x + (af and -1 or 1) * a.spawn_offset.x,
                                    this.pos.y + a.spawn_offset.y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(e.pos)
                                b.bullet.hit_payload = e

                                queue_insert(store, b)
                            end
                        end

                        SU.y_hero_animation_wait(this)

                        goto label_119_0
                    end
                end
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.rootspikes

            if ready_to_use_skill(a, store) then
                local triggers = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not triggers or #triggers < a.trigger_count then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound)

                    local af = triggers[1].pos.x < this.pos.x

                    U.animation_start(this, a.animation, af, store.tick_ts)

                    if U.y_wait(store, a.hit_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        -- block empty
                    else
                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                            a.vis_flags, a.vis_bans)

                        if not targets then
                            -- block empty
                        else
                            a.ts = store.tick_ts

                            SU.hero_gain_xp_from_skill(this, skill)

                            local tpos = V.vclone(targets[1].pos)
                            local hit_center = V.v(this.pos.x + a.hit_offset.x * (af and -1 or 1),
                                this.pos.y + a.hit_offset.y)
                            local decal = E:create_entity(a.hit_decal)

                            decal.pos.x, decal.pos.y = hit_center.x, hit_center.y
                            decal.tween.ts = store.tick_ts

                            queue_insert(store, decal)
                            spawn_spikes(7, hit_center, a.decal_range * 0.5, 0, 0, 1)
                            spawn_spikes(9, hit_center, a.decal_range / 1.25, 0, 0.07, 0.75)
                            spawn_spikes(13, hit_center, a.decal_range, math.pi * 2 / 26, 0.17, 0.5)

                            for _, target in pairs(targets) do
                                local d = SU.create_attack_damage(a, target.id, this)

                                queue_damage(store, d)
                            end

                            SU.y_hero_animation_wait(this)

                            goto label_119_0
                        end
                    end
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ultimate.range, true)

                if target and target.pos and valid_land_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                    e.pos = V.vclone(target.pos)
                    e.owner = this
                    e.damage_factor = this.unit.damage_factor
                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_119_0::

        coroutine.yield()
    end
end

scripts.hero_bravebark_ultimate = {}

function scripts.hero_bravebark_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

    if #nodes < 1 then
        log.error("hero_bravebark_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local node_f = {
        pi = nodes[1][1],
        spi = math.random(1, 3),
        ni = nodes[1][3]
    }
    local node_b = {
        pi = nodes[1][1],
        spi = math.random(1, 3),
        ni = nodes[1][3]
    }
    local count = this.count
    local dir = 1
    local node

    for i = 1, 2 * count do
        node = dir == 1 and node_f or node_b

        local node_pos = P:node_pos(node.pi, node.spi, node.ni)

        if P:is_node_valid(node.pi, node.ni) and not GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
            local nni = node.ni + dir * math.random(this.sep_nodes_min, this.sep_nodes_max - 1)
            local nspi = km.zmod(node.spi + math.random(1, 2), 3)

            node.spi, node.ni = nspi, nni

            local e = E:create_entity(this.decal)

            e.render.sprites[1].prefix = e.render.sprites[1].prefix .. math.random(1, 3)
            e.pos = node_pos
            e.render.sprites[1].ts = store.tick_ts

            queue_insert(store, e)

            local targets = U.find_enemies_in_range(store, e.pos, 0, this.damage_radius, this.vis_flags,
                this.vis_bans)

            if targets then
                for _, target in pairs(targets) do
                    local m = E:create_entity(this.mod)

                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)

                    local d = E:create_entity("damage")

                    d.value = this.damage * this.damage_factor
                    d.source_id = this.id
                    d.target_id = target.id

                    queue_damage(store, d)
                end
            end

            if count % 2 == 0 then
                U.y_wait(store, U.frandom(this.show_delay_min, this.show_delay_max))
            end

            count = count - 1
        end

        if count <= 0 then
            break
        end

        dir = -1 * dir
    end

    queue_remove(store, this)
end
scripts.hero_catha = {}

function scripts.hero_catha.level_up(this, store)
    local hl, ls = level_up_basic(this)
    local hl = this.hero.level
    local ls = this.hero.level_stats

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)
    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]
    bt = E:get_template("knife_soldier_catha")
    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "soul", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil

        local m = E:get_template(a.mod)

        m.hps.heal_min = s.heal_hp[s.level]
        m.hps.heal_max = s.heal_hp[s.level]
    end)
    upgrade_skill(this, "tale", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.max_count = s.max_count[s.level]

        local e = E:get_template(a.entity)

        e.health.hp_max = s.hp_max[s.level]
    end)
    upgrade_skill(this, "fury", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil

        local b = E:get_template("catha_fury")

        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "curse", function(this, s)
        local m = E:get_template("mod_catha_curse")

        m.chance = s.chance[s.level]
        m.modifier.duration = s.duration[s.level]
        this.melee.attacks[1].mod = "mod_catha_curse"

        local m = E:get_template("mod_soldier_catha_curse")

        m.chance = s.chance[s.level] * s.chance_factor_tale
        m.modifier.duration = s.duration[s.level]
    end)
    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template("hero_catha_ultimate")

        u.duration = s.duration[s.level]
        u.duration_boss = s.duration_boss[s.level]
        u.range = s.range[s.level]
        this.ultimate.range = s.range[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_catha.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_133_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.fury

            if ready_to_use_skill(a, store) then
                local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not targets then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if U.y_wait(store, a.shoot_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if targets then
                            for i = 1, skill.count[skill.level] do
                                local target = table.random(targets)
                                local b = E:create_entity(a.bullet)

                                b.pos.x, b.pos.y = this.pos.x, this.pos.y
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id
                                b.bullet.level = a.level

                                queue_insert(store, b)
                            end
                        end

                        SU.y_hero_animation_wait(this)

                        a.ts = store.tick_ts

                        goto label_133_0
                    end
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.soul

            if ready_to_use_skill(a, store) then
                local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags,
                    a.vis_bans, function(e)
                        return e.health.hp / e.health.hp_max < a.max_hp_factor and
                                   not table.contains(a.excluded_templates, e.template_name)
                    end)

                if not targets then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if U.y_wait(store, a.shoot_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags,
                            a.vis_bans, function(e)
                                return not table.contains(a.excluded_templates, e.template_name)
                            end)

                        if targets then
                            table.sort(targets, function(e1, e2)
                                return e1.health.hp < e2.health.hp
                            end)

                            for i = 1, math.min(#targets, a.max_count) do
                                local target = targets[i]
                                local m = E:create_entity(a.mod)

                                m.modifier.source_id = this.id
                                m.modifier.target_id = target.id

                                queue_insert(store, m)
                            end
                        end

                        local fx = E:create_entity(a.shoot_fx)

                        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                        fx.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, fx)
                        SU.y_hero_animation_wait(this)

                        a.ts = store.tick_ts

                        goto label_133_0
                    end
                end
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.tale

            if ready_to_use_skill(a, store) then
                local targets =
                    U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

                if not targets then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if U.y_wait(store, a.spawn_time, function()
                        return SU.hero_interrupted(this)
                    end) then
                        -- block empty
                    else
                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        for i = 1, a.max_count do
                            local o = a.entity_offsets[i]
                            local e = E:create_entity(a.entity)

                            e.pos.x, e.pos.y = this.pos.x + o.x, this.pos.y + o.y
                            e.nav_rally.center = V.vclone(e.pos)
                            e.nav_rally.pos = V.vclone(e.pos)
                            e.tween.ts = store.tick_ts
                            e.tween.props[1].keys[1][2].x = -o.x
                            e.tween.props[1].keys[1][2].y = -o.y
                            e.render.sprites[1].flip_x = this.render.sprites[1].flip_x
                            e.owner = this

                            queue_insert(store, e)
                        end

                        SU.y_hero_animation_wait(this)

                        a.ts = store.tick_ts

                        goto label_133_0
                    end
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)
                local target_found = false
                if target then
                    target = U.find_foremost_enemy_with_max_coverage(store, this.pos, 0,
                        this.ranged.attacks[1].max_range, 0, bor(F_RANGED, F_MOD), 0, nil, nil, this.ultimate.range)
                    if target and target.pos and valid_land_node_nearby(target.pos) then
                        target_found = true
                    end
                end
                if target_found then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            else
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
        end

        ::label_133_0::

        coroutine.yield()
    end
end

scripts.hero_catha_ultimate = {}

function scripts.hero_catha_ultimate.update(this, store)
    U.animation_start(this, nil, nil, store.tick_ts, false)
    U.y_wait(store, this.hit_time)

    local fx = E:create_entity(this.hit_fx)

    fx.pos.x, fx.pos.y = this.pos.x, this.pos.y

    U.animation_start(fx, nil, nil, store.tick_ts, false)
    queue_insert(store, fx)

    local targets = U.find_enemies_in_range(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
        function(e)
            return U.flag_has(e.vis.flags, F_BOSS) or not U.flag_has(e.vis.bans, F_STUN)
        end)

    if targets then
        for _, target in pairs(targets) do
            local m = E:create_entity(this.mod)

            m.modifier.source_id = this.id
            m.modifier.target_id = target.id

            if U.flag_has(target.vis.flags, F_BOSS) then
                m.modifier.duration = this.duration_boss
                m.modifier.vis_flags = U.flag_clear(m.modifier.vis_flags, F_STUN)
            else
                m.modifier.duration = this.duration
            end

            queue_insert(store, m)
        end
    end

    U.y_animation_wait(this)
    queue_remove(store, this)
end

scripts.hero_lilith = {}

function scripts.hero_lilith.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)

    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "reapers_harvest", function(this, s)
        local a = this.melee.attacks[3]
        a.disabled = nil
        a.damage_min = s.damage[s.level]
        a.damage_max = s.damage[s.level]
        a = this.melee.attacks[4]
        a.disabled = nil
        a.damage_min = s.damage[s.level]
        a.damage_max = s.damage[s.level]
        a.chance = s.instakill_chance[s.level]
        a.origin_chance = s.instakill_chance[s.level]
    end)
    upgrade_skill(this, "soul_eater", function(this, s)
        local m = E:get_template("mod_lilith_soul_eater_damage_factor")

        m.soul_eater_factor = s.damage_factor[s.level]
    end)

    upgrade_skill(this, "infernal_wheel", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil

        local au = E:get_template(a.bullet)
        local m = E:get_template(au.aura.mod)

        m.dps.damage_min = s.damage[s.level]
        m.dps.damage_max = s.damage[s.level]
    end)

    upgrade_skill(this, "resurrection", function(this, s)
        local a = this.revive

        a.disabled = nil
        a.chance = s.chance[s.level]
    end)
    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template(s.controller_name)

        u.angel_count = s.angel_count[s.level]

        local e = E:get_template(u.angel_entity)

        e.melee.attacks[1].damage_max = s.angel_damage[s.level] * 2
        e.melee.attacks[1].damage_min = s.angel_damage[s.level] * 2

        local b = E:get_template(u.meteor_bullet)

        b.bullet.damage_max = s.meteor_damage[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_lilith.insert(this, store)
    scripts.hero_basic.insert(this, store)

    local a = E:create_entity("aura_lilith_soul_eater")

    a.aura.source_id = this.id
    a.aura.ts = store.tick_ts
    a.pos = this.pos
    queue_insert(store, a)

    return true
end

function scripts.hero_lilith.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    this.health_bar.hidden = false
    local function skill_come_into_cooldown(skill_attack, is_ultimate)
        if is_ultimate then
            skill_attack.ts = store.tick_ts - km.clamp(0, 1, this.revive.protect) * skill_attack.cooldown * 0.15
        else
            skill_attack.ts = store.tick_ts - km.clamp(0, 1, this.revive.protect) * skill_attack.cooldown * 0.4
        end
    end
    local function inc_instakill_chance()
        this.melee.attacks[4].chance = this.melee.attacks[4].origin_chance + 0.2 * km.clamp(0, 1, this.revive.protect)
    end
    local function update_color()
        local revive_rate = km.clamp(0, 1, this.revive.protect) * 100
        this.render.sprites[1].alpha = 155 + revive_rate
        this.render.sprites[1].color[3] = 255 - revive_rate
    end
    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    while true do
        if h.dead then
            local r = this.revive
            local chance_pass = math.random() < (this.revive.chance + this.revive.protect)

            if not this.revive.disabled and
                not U.flag_has(h.last_damage_types, bor(DAMAGE_EAT, DAMAGE_HOST, DAMAGE_DISINTEGRATE)) and chance_pass then
                h.ignore_damage = true
                h.dead = false
                h.hp = h.hp_max

                for _, s in pairs(this.render.sprites) do
                    s.hidden = false
                end

                S:queue(this.revive.sound)
                U.y_animation_play(this, this.revive.animation, nil, store.tick_ts, 1)

                this.health_bar.hidden = false
                this.ui.can_click = true
                h.ignore_damage = nil
                this.revive.protect = this.revive.protect * 0.5
                SU.hero_gain_xp_from_skill(this, this.hero.skills.resurrection)
                this.melee.attacks[3].ts = 0
                this.melee.attacks[4].ts = 0
                this.timed_attacks.list[1].ts = 0
            else
                SU.y_hero_death_and_respawn(store, this)
            end

            this.revive.ts = store.tick_ts
        end
        scripts.soldier_revive_resist(this, store)
        inc_instakill_chance()
        update_color()
        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_167_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.infernal_wheel

            if ready_to_use_skill(a, store) then
                local target = U.find_random_enemy(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.shoot_time) then
                        goto label_167_0
                    end

                    SU.hero_gain_xp_from_skill(this, skill)

                    skill_come_into_cooldown(a)

                    local pos
                    local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

                    if #nodes == 0 then
                        pos = V.vclone(this.pos)
                    else
                        pos = P:node_pos(nodes[1][1], 1, nodes[1][3])
                    end

                    local b = E:create_entity(a.bullet)

                    b.pos.x, b.pos.y = pos.x, pos.y
                    b.aura.ts = store.tick_ts

                    queue_insert(store, b)
                    SU.y_hero_animation_wait(this)

                    goto label_167_0
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target, target_num = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)

                if target and target.pos and valid_land_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)
                    if target_num <= 1 then
                        e.is_meteor = false
                    else
                        e.is_meteor = true
                    end
                    queue_insert(store, e)

                    skill_come_into_cooldown(this.ultimate, true)
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            else
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
        end

        ::label_167_0::

        coroutine.yield()
    end
end

scripts.hero_lilith_ultimate = {}

function scripts.hero_lilith_ultimate.update(this, store)
    local function spawn_meteor(pi, spi, ni)
        spi = spi or math.random(1, 3)

        local pos = P:node_pos(pi, spi, ni)

        pos.x = pos.x + math.random(-4, 4)
        pos.y = pos.y + math.random(-5, 5)

        local b = E:create_entity(this.meteor_bullet)

        b.bullet.from = V.v(pos.x + math.random(140, 170), pos.y + REF_H)
        b.bullet.to = pos
        b.pos = V.vclone(b.bullet.from)
        b.bullet.damage_factor = this.damage_factor

        queue_insert(store, b)
    end

    local pi, spi, ni
    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

    if #nearest < 1 then
        log.error("could not find node to fire lilith ultimate")
    else
        pi, spi, ni = unpack(nearest[1])

        if this.is_meteor then
            local seq = {}

            for i = 1, this.meteor_node_spread do
                seq[i] = i
            end

            spawn_meteor(pi, spi, ni)

            while #seq > 0 do
                local delay = U.frandom(0.15, 0.3)
                local i = table.remove(seq, math.random(1, #seq))
                local can_up, can_down = P:is_node_valid(pi, ni + i), P:is_node_valid(pi, ni - i)

                U.y_wait(store, delay * 0.5)

                if can_up then
                    spawn_meteor(pi, nil, ni + i)
                elseif can_down then
                    spawn_meteor(pi, nil, ni - i)
                end

                U.y_wait(store, delay * 0.5)

                if can_down then
                    spawn_meteor(pi, nil, ni - i)
                elseif can_up then
                    spawn_meteor(pi, nil, ni + i)
                end
            end
        else
            local node = {
                spi = 1,
                pi = nearest[1][1],
                ni = nearest[1][3]
            }
            local node_pos = P:node_pos(node)
            local target, targets = U.find_foremost_enemy(store, this.pos, 0, this.angel_range, fts(10),
                this.angel_vis_flags, this.angel_vis_bans)
            local idx = 1

            for i = 1, this.angel_count do
                local e = E:create_entity(this.angel_entity)

                if targets then
                    target = targets[km.zmod(idx, #targets)]
                    idx = idx + 1

                    if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
                        local m = E:create_entity(this.angel_mod)

                        m.modifier.target_id = target.id
                        m.modifier.source_id = this.id

                        queue_insert(store, m)
                    end

                    if band(target.vis.flags, F_BLOCK) ~= 0 then
                        U.block_enemy(store, e, target)
                    else
                        e.unblocked_target_id = target.id
                    end

                    local lpos, lflip = U.melee_slot_position(e, target, 1, math.random() < 0.5)

                    e.pos.x, e.pos.y = lpos.x, lpos.y
                    e.render.sprites[1].flip_x = lflip
                else
                    local nni = node.ni + math.random(-10, 10)
                    local nspi = math.random(1, 3)
                    local npos = P:node_pos(node.pi, nspi, nni)

                    if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
                        npos = node_pos
                    end

                    e.pos.x, e.pos.y = npos.x, npos.y
                end

                e.nav_rally.center = V.vclone(e.pos)
                e.nav_rally.pos = V.vclone(e.pos)

                queue_insert(store, e)
                U.y_wait(store, this.angel_delay)
            end
        end
    end

    queue_remove(store, this)
end

scripts.hero_xin = {}

function scripts.hero_xin.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "daring_strike", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.ts = store.tick_ts
        a.damage_max = s.damage_max[s.level]
        a.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "inspire", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.ts = store.tick_ts

        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
    end)
    upgrade_skill(this, "mind_over_body", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.ts = store.tick_ts
        this.mind_over_body_damage_buff_max = s.damage_buff[s.level]
        this.mind_over_body_duration = s.duration[s.level]
        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
        m.hps.heal_every = s.heal_every[s.level]
        m.hps.heal_min = s.heal_hp[s.level]
        m.hps.heal_max = s.heal_hp[s.level]
    end)

    upgrade_skill(this, "panda_style", function(this, s)
        local a = this.melee.attacks[3]

        a.disabled = nil
        a.ts = store.tick_ts
        a.damage_max = s.damage_max[s.level]
        a.damage_min = s.damage_min[s.level]
    end)
    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template("hero_xin_ultimate")

        u.count = s.count[s.level]

        local e = E:get_template(u.entity)

        for _, ma in pairs(e.melee.attacks) do
            ma.damage_max = s.damage[s.level]
            ma.damage_min = s.damage[s.level]
        end
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_xin.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if this.mind_over_body_active and store.tick_ts - this.mind_over_body_last_ts >= this.mind_over_body_duration then
            this.damage_buff = this.damage_buff - this.mind_over_body_damage_buff
            this.mind_over_body_active = false
            this.melee.attacks[3].ts = this.melee.attacks[3].ts - this.melee.attacks[3].cooldown * 0.1
            this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - this.timed_attacks.list[1].cooldown * 0.1
            this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - this.timed_attacks.list[2].cooldown * 0.1
        end
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                -- if SU.y_hero_new_rally(store, this) then
                --     goto label_126_1
                -- end
                this.motion.arrived = false
                a = this.timed_attacks.list[1]
                local initial_flip = this.render.sprites[1].flip_x
                local shadow
                S:queue(a.sounds[1])
                U.animation_start(this, a.animations[1], nil, store.tick_ts)
                SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)
                this.health_bar.hidden = true
                if U.is_blocked_valid(store, this) then
                    local blocked = store.entities[this.soldier.target_id]
                    local m = E:create_entity("mod_xin_stun")

                    m.modifier.target_id = blocked.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)

                    shadow = E:create_entity("soldier_xin_shadow")
                    shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
                    shadow.nav_rally.center = V.vclone(this.pos)
                    shadow.nav_rally.pos = V.vclone(this.pos)
                    shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                    queue_insert(store, shadow)
                    U.replace_blocker(store, this, shadow)
                end
                U.y_animation_wait(this)
                this.health_bar.hidden = nil
                this.pos.x = this.nav_rally.pos.x
                this.pos.y = this.nav_rally.pos.y

                SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)
                if shadow then
                    shadow.health.dead = true
                end
                this.nav_rally.new = false
                this.motion.arrived = true
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.mind_over_body

            if ready_to_use_skill(a, store) and this.health.hp / this.health.hp_max <= a.min_health_factor then
                SU.hero_gain_xp_from_skill(this, skill)
                this.health.ignore_damage = true
                U.animation_start(this, a.animation, nil, store.tick_ts)
                U.y_wait(store, a.cast_time)
                S:queue(a.sound)
                SU.insert_sprite(store, "decal_xin_drink_circle", this.pos)
                local mod = E:create_entity(a.mod)
                mod.modifier.target_id = this.id
                mod.modifier.source_id = this.id
                queue_insert(store, mod)
                this.mind_over_body_active = true
                this.mind_over_body_damage_buff = this.mind_over_body_damage_buff_max
                this.mind_over_body_last_ts = store.tick_ts
                this.damage_buff = this.damage_buff + this.mind_over_body_damage_buff
                U.y_animation_wait(this)
                this.health.ignore_damage = false
                a.ts = store.tick_ts
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.inspire

            if ready_to_use_skill(a, store) then
                local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range, a.vis_flags,
                    a.vis_bans)
                local enemies =
                    U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

                if not soldiers or #soldiers < a.min_count or not enemies then
                    SU.delay_attack(store, a, 0.3333333333333333)
                else
                    this.health.ignore_damage = true
                    U.animation_start(this, a.animation, nil, store.tick_ts)
                    U.y_wait(store, a.cast_time)
                    S:queue(a.sound)
                    SU.insert_sprite(store, "decal_xin_inspire", this.pos)

                    for i = 1, math.min(#soldiers, a.max_count) do
                        local soldier = soldiers[i]
                        local m = E:create_entity(a.mod)

                        m.modifier.target_id = soldier.id
                        m.modifier.source_id = this.id
                        m.modifier.ts = store.tick_ts

                        queue_insert(store, m)
                    end

                    U.y_animation_wait(this)
                    SU.hero_gain_xp_from_skill(this, skill)

                    a.ts = store.tick_ts
                    this.health.ignore_damage = false
                end
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.daring_strike

            if ready_to_use_skill(a, store) then
                local blocked_enemy = this.soldier.target_id and store.entities[this.soldier.target_id]

                if not blocked_enemy and SU.soldier_pick_melee_target(store, this) then
                    SU.delay_attack(store, a, 0.3333333333333333)

                    goto label_126_0
                end

                local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans, function(e)
                        local ni_s = P:get_visible_start_node(e.nav_path.pi)
                        local ni_e = P:get_visible_end_node(e.nav_path.pi)

                        return e ~= blocked_enemy and e.nav_path.ni > ni_s + a.node_margin and e.nav_path.ni < ni_e -
                                   a.node_margin
                    end)

                if not targets then
                    SU.delay_attack(store, a, 0.3333333333333333)

                    goto label_126_0
                end

                table.sort(targets, function(e1, e2)
                    return e1.health.hp > e2.health.hp
                end)

                local target = targets[1]
                local initial_pos = V.vclone(this.pos)
                local initial_flip = this.render.sprites[1].flip_x
                local _bans = this.vis.bans
                local shadow

                this.vis.bans = F_ALL
                this.health.ignore_damage = true

                S:queue(a.sounds[1])
                U.animation_start(this, a.animations[1], nil, store.tick_ts)
                SU.insert_sprite(store, "fx_xin_smoke_teleport_out", this.pos, initial_flip)
                -- U.y_wait(store, fts(14))

                this.health_bar.hidden = true

                -- U.y_wait(store, fts(3))

                if U.is_blocked_valid(store, this) then
                    local blocked = store.entities[this.soldier.target_id]
                    local m = E:create_entity("mod_xin_stun")

                    m.modifier.target_id = blocked.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)

                    shadow = E:create_entity("soldier_xin_shadow")
                    shadow.pos.x, shadow.pos.y = this.pos.x, this.pos.y
                    shadow.nav_rally.center = V.vclone(this.pos)
                    shadow.nav_rally.pos = V.vclone(this.pos)
                    shadow.render.sprites[1].flip_x = this.render.sprites[1].flip_x

                    queue_insert(store, shadow)
                    U.replace_blocker(store, this, shadow)
                end

                U.y_animation_wait(this)

                local m = E:create_entity("mod_xin_stun")

                m.modifier.target_id = target.id
                m.modifier.source_id = this.id

                queue_insert(store, m)

                local lpos, lflip = U.melee_slot_position(this, target, 2)

                this.pos.x, this.pos.y = lpos.x, lpos.y

                U.animation_start(this, a.animations[2], lflip, store.tick_ts)
                SU.insert_sprite(store, "fx_xin_smoke_teleport_hit", this.pos, lflip)
                -- U.y_wait(store, fts(5))
                S:queue(a.sounds[2])

                this.health_bar.hidden = nil
                queue_damage(store, SU.create_attack_damage(a, target.id, this))
                U.y_animation_wait(this)

                if target and not target.health.dead then
                    U.animation_start(this, a.animations[3], lflip, store.tick_ts)
                    queue_damage(store, SU.create_attack_damage(a, target.id, this))
                    U.y_animation_wait(this)
                end

                if target and not target.health.dead then
                    local m = E:create_entity(a.mod)
                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id
                    m.modifier.ts = store.tick_ts
                    queue_insert(store, m)
                end
                this.health_bar.hidden = true

                U.animation_start(this, a.animations[4], lflip, store.tick_ts)
                SU.insert_sprite(store, "fx_xin_smoke_teleport_hit_out", this.pos, lflip)
                U.y_animation_wait(this)

                if this.nav_rally.new then
                    this.nav_rally.new = false
                    this.pos.x, this.pos.y = this.nav_rally.pos.x, this.nav_rally.pos.y
                else
                    this.pos.x, this.pos.y = initial_pos.x, initial_pos.y
                end

                S:queue(a.sounds[5])
                U.animation_start(this, a.animations[5], initial_flip, store.tick_ts)
                SU.insert_sprite(store, "fx_xin_smoke_teleport_in", this.pos, initial_flip)

                if shadow then
                    shadow.health.dead = true

                    U.replace_blocker(store, shadow, this)
                end

                -- U.y_wait(store, fts(5))

                this.health_bar.hidden = nil
                this.vis.bans = _bans
                this.health.ignore_damage = nil

                U.y_animation_wait(this)
                SU.hero_gain_xp_from_skill(this, skill)

                a.ts = store.tick_ts
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ultimate.range)

                if target and target.pos and valid_land_node_nearby(target.pos) then
                    this.health.ignore_damage = true
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    this.health.ignore_damage = false
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            ::label_126_0::

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_126_1::

        coroutine.yield()
    end
end

scripts.hero_xin_ultimate = {}

function scripts.hero_xin_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

    if #nodes < 1 then
        log.error("hero_xin_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local node = {
        spi = 1,
        pi = nodes[1][1],
        ni = nodes[1][3]
    }
    local node_pos = P:node_pos(node)
    local count = this.count
    local target, targets = U.find_foremost_enemy(store, this.pos, 0, this.range, fts(10), this.vis_flags,
        this.vis_bans)
    local idx = 1

    while count > 0 do
        local e = E:create_entity(this.entity)

        if targets then
            target = targets[km.zmod(idx, #targets)]
            idx = idx + 1

            if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
                local m = E:create_entity("mod_xin_stun")

                m.modifier.target_id = target.id
                m.modifier.source_id = this.id

                queue_insert(store, m)
            end

            if band(target.vis.flags, F_BLOCK) ~= 0 then
                U.block_enemy(store, e, target)
            else
                e.unblocked_target_id = target.id
            end

            local lpos, lflip = U.melee_slot_position(e, target, 1)

            e.pos.x, e.pos.y = lpos.x, lpos.y
            e.render.sprites[1].flip_x = lflip
        else
            local nni = node.ni + math.random(-10, 10)
            local nspi = math.random(1, 3)
            local npos = P:node_pos(node.pi, nspi, nni)

            if not P:is_node_valid(node.pi, nni) or GR:cell_is(node_pos.x, node_pos.y, TERRAIN_FAERIE) then
                npos = node_pos
            end

            e.pos.x, e.pos.y = npos.x, npos.y
        end

        e.nav_rally.center = V.vclone(e.pos)
        e.nav_rally.pos = V.vclone(e.pos)

        queue_insert(store, e)

        count = count - 1

        U.y_wait(store, this.spawn_delay)
    end

    queue_remove(store, this)
end

scripts.hero_faustus = {}

function scripts.hero_faustus.level_up(this, store)
    local hl, ls = level_up_basic(this)

    local b = E:get_template(this.ranged.attacks[1].bullet)

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    upgrade_skill(this, "dragon_lance", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil

        local b = E:get_template(a.bullet)

        b.bullet.damage_max = s.damage_max[s.level]
        b.bullet.damage_min = s.damage_min[s.level]
    end)
    upgrade_skill(this, "teleport_rune", function(this, s)
        local a = this.ranged.attacks[3]

        a.disabled = nil

        local aura = E:get_template(a.bullet)

        aura.aura.targets_per_cycle = s.max_targets[s.level]
    end)

    upgrade_skill(this, "enervation", function(this, s)
        local a = this.ranged.attacks[4]

        a.disabled = nil

        local aura = E:get_template(a.bullet)

        aura.aura.targets_per_cycle = s.max_targets[s.level]

        local mod = E:get_template(aura.aura.mod)

        mod.modifier.duration = s.duration[s.level]
    end)
    upgrade_skill(this, "liquid_fire", function(this, s)
        local a = this.ranged.attacks[5]

        a.disabled = nil

        local b = E:get_template(a.bullet)

        b.flames_count = s.flames_count[s.level]

        local m = E:get_template("mod_liquid_fire_faustus")

        m.dps.damage_max = s.mod_damage[s.level]
        m.dps.damage_min = s.mod_damage[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local m = E:get_template("mod_minidragon_faustus")

        m.dps.damage_max = s.mod_damage[s.level]
        m.dps.damage_min = s.mod_damage[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_faustus.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_faustus.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            -- block empty
        end

        if ready_to_use_skill(this.ultimate, store) then
            local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, true)

            if target and target.pos and valid_land_node_nearby(target.pos) then
                S:queue(this.sound_events.change_rally_point)
                local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                e.pos = V.vclone(target.pos)

                queue_insert(store, e)

                this.ultimate.ts = store.tick_ts
                SU.hero_gain_xp_from_skill(this, this.ultimate)
            else
                this.ultimate.ts = this.ultimate.ts + 1
            end
        end
        for _, i in pairs(this.ranged.order) do
            local a = this.ranged.attacks[i]

            if a.disabled then
                -- block empty
            elseif a.sync_animation and not this.render.sprites[1].sync_flag then
                -- block empty
            elseif store.tick_ts - a.ts < a.cooldown then
                -- block empty
            else
                local bullet_t = E:get_template(a.bullet)
                local flight_time = a.estimated_flight_time or 1
                local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans, function(e)
                        if U.flag_has(a.vis_flags, F_SPELLCASTER) and
                            (not U.flag_has(e.vis.flags, F_SPELLCASTER) or not e.enemy.can_do_magic) then
                            log.debug("filtering (%s)%s", e.id, e.template_name)

                            return false
                        end

                        if a.target_offset_rect then
                            local node_offset = P:predict_enemy_node_advance(e, a.shoot_time + flight_time)
                            local e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni + node_offset)
                            local is_inside = V.is_inside(V.v(math.abs(e_pos.x - this.pos.x), e_pos.y - this.pos.y),
                                a.target_offset_rect)

                            if not is_inside then
                                return false
                            end

                            if a.max_count_range and a.min_count then
                                local min_count_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi,
                                    e.nav_path.ni - a.min_count_nodes_offset)
                                local nearby = U.find_enemies_in_range(store, min_count_pos, 0,
                                    a.max_count_range, a.vis_flags, a.vis_bans)

                                return nearby and #nearby >= a.min_count
                            end

                            return true
                        else
                            return true
                        end
                    end)

                if target then
                    local start_ts = store.tick_ts
                    local start_fx, b, targets
                    local node_offset = P:predict_enemy_node_advance(target, flight_time)
                    local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
                    local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                    U.animation_start(this, an, af, store.tick_ts)
                    S:queue(a.start_sound, a.start_sound_args)

                    if a.start_fx then
                        local fx = E:create_entity(a.start_fx)

                        fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                        fx.render.sprites[1].ts = store.tick_ts
                        fx.render.sprites[1].flip_x = af

                        queue_insert(store, fx)

                        start_fx = fx
                    end

                    while store.tick_ts - start_ts < a.shoot_time do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_112_0
                        end

                        coroutine.yield()
                    end

                    S:queue(a.sound)

                    targets = {}

                    if a.bullet_count then
                        local extra_targets = U.find_enemies_in_range(store, target.pos, 0, a.extra_range,
                            a.vis_flags, a.vis_bans, function(e)
                                return af and e.pos.x <= this.pos.x or e.pos.x >= this.pos.x
                            end)

                        if not extra_targets then
                            goto label_112_0
                        end

                        for i = 1, a.bullet_count do
                            table.insert(targets, extra_targets[km.zmod(i, #extra_targets)])
                        end
                    else
                        targets = {target}
                    end

                    for i, t in ipairs(targets) do
                        b = E:create_entity(a.bullet)

                        if a.type == "aura" then
                            b.pos.x, b.pos.y = target.pos.x, target.pos.y
                            b.aura.ts = store.tick_ts
                        else
                            b.bullet.target_id = t.id
                            b.bullet.source_id = this.id
                            b.bullet.xp_dest_id = this.id
                            b.bullet.damage_factor = this.unit.damage_factor
                            b.pos = V.vclone(this.pos)
                            b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
                            b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.v(t.pos.x + t.unit.hit_offset.x, t.pos.y + t.unit.hit_offset.y)
                            b.bullet.shot_index = i

                            if i == 1 then
                                b.initial_impulse = 0
                            end
                        end

                        queue_insert(store, b)
                    end

                    if a.xp_from_skill then
                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                    end

                    a.ts = start_ts

                    while not U.animation_finished(this) do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_112_0
                        end

                        coroutine.yield()
                    end

                    a.ts = start_ts

                    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil,
                        true)

                    ::label_112_0::

                    if start_fx then
                        start_fx.render.sprites[1].hidden = true
                    end

                    goto label_112_1
                elseif i == 1 and this.motion.arrived then
                    U.y_wait(store, this.soldier.guard_time)
                end
            end
        end

        SU.soldier_idle(store, this)
        SU.soldier_regen(store, this)

        ::label_112_1::

        coroutine.yield()
    end
end

scripts.hero_faustus_ultimate = {}

function scripts.hero_faustus_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

    if #nodes < 1 then
        log.error("hero_faustus_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local node = {
        spi = 1,
        pi = nodes[1][1],
        ni = nodes[1][3]
    }
    local node_offsets = {0, -this.separation_nodes, this.separation_nodes}
    local node_pos = P:node_pos(node.pi, node.spi, node.ni)
    local from_y = node_pos.y

    for i = 1, 3 do
        if P:is_node_valid(node.pi, node.ni + node_offsets[i]) then
            node_pos = P:node_pos(node.pi, node.spi, node.ni + node_offsets[i])
            from_y = node_pos.y
        end

        local e = E:create_entity("decal_minidragon_faustus")

        e.attack_pos = node_pos
        e.pos.x, e.pos.y = i % 2 == 0 and 2 * REF_W or -REF_W, from_y

        queue_insert(store, e)
        U.y_wait(store, this.show_delay)
    end

    queue_remove(store, this)
end

scripts.hero_rag = {}

function scripts.hero_rag.level_up(this, store, initial)
    local hl, ls = level_up_basic(this, store)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)
    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "raggified", function(this, s)
        local a = this.timed_attacks.list[4]

        a.disabled = nil
        a.max_target_hp = s.max_target_hp[s.level]

        local m = E:get_template("mod_rag_raggified")

        m.doll_duration = s.doll_duration[s.level]
        m.break_factor = s.break_factor[s.level]
    end)
    upgrade_skill(this, "kamihare", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.count = s.count[s.level]
    end)

    upgrade_skill(this, "angry_gnome", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil

        for _, n in pairs(a.things) do
            local b = E:get_template(a.bullet_prefix .. n)

            b.bullet.damage_max = s.damage_max[s.level]
            b.bullet.damage_min = s.damage_min[s.level]
        end
    end)
    upgrade_skill(this, "hammer_time", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template(s.controller_name)
        u.max_count = s.max_count[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_rag.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta, ranged_done

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_144_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[4]
            skill = this.hero.skills.raggified

            if ready_to_use_skill(a, store) then
                local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans, function(e)
                        return e.health.hp < a.max_target_hp * this.unit.damage_factor and
                                   GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
                    end)

                if not target then
                    SU.delay_attack(store, a, 0.16666666666666666)
                else
                    a.ts = store.tick_ts

                    if not SU.y_soldier_do_ranged_attack(store, this, target, a) then
                        goto label_144_0
                    end
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.kamihare

            if ready_to_use_skill(a, store) then
                local target_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min,
                    a.range_nodes_max, nil, a.vis_flags, a.vis_bans, true, function(e)
                        return not U.flag_has(P:path_terrain_props(e.nav_path.pi), bor(TERRAIN_FAERIE, TERRAIN_WATER))
                    end)

                if not target_info then
                    SU.delay_attack(store, a, 0.16666666666666666)
                else
                    local target = target_info[1].enemy
                    local origin = target_info[1].origin
                    local start_ts = store.tick_ts
                    local bullet_to_ni = origin[3] - 5
                    local bullet_to = P:node_pos(origin[1], 1, bullet_to_ni)
                    local flip = bullet_to.x < this.pos.x

                    S:queue(a.sound, {
                        delay = a.sound_delay
                    })
                    U.animation_start(this, a.animations[1], flip, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.spawn_time) then
                        -- block empty
                    else
                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts

                        for i = 1, a.count do
                            SU.y_hero_wait(store, this, fts(2))

                            local pi, spi, ni = origin[1], km.zmod(i, 3), bullet_to_ni + math.random(-10, 0)

                            if not P:is_node_valid(pi, ni) then
                                log.debug("cannot spawn kamihare in invalid node: %s,%s,%s", pi, spi, ni)
                            else
                                local e = E:create_entity(a.entity)

                                e.pos = P:node_pos(pi, spi, ni)
                                e.nav_path.pi = pi
                                e.nav_path.spi = spi
                                e.nav_path.ni = ni

                                local b = E:create_entity(a.bullet)

                                b.pos.x = this.pos.x + math.random(-3, 3) + a.spawn_offset.x
                                b.pos.y = this.pos.y + math.random(0, 3) + a.spawn_offset.y
                                b.bullet.from = V.vclone(b.pos)
                                b.bullet.to = V.vclone(e.pos)
                                b.bullet.hit_payload = e
                                b.bullet.damage_factor = this.unit.damage_factor
                                b.render.sprites[1].flip_x = flip
                                b.render.sprites[1].ts = store.tick_ts

                                queue_insert(store, b)
                            end
                        end

                        U.animation_start(this, a.animations[2], nil, store.tick_ts)
                        SU.y_hero_animation_wait(this)

                        a.ts = store.tick_ts
                    end

                    goto label_144_0
                end
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.angry_gnome

            if ready_to_use_skill(a, store) then
                local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    local pred_pos = P:predict_enemy_pos(target, fts(12))
                    local thing = table.random(a.things)

                    a.animation = "throw_" .. thing
                    a.bullet = a.bullet_prefix .. thing
                    a.ts = store.tick_ts

                    if not SU.y_soldier_do_ranged_attack(store, this, target, a, pred_pos) then
                        goto label_144_0
                    end
                end
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.hammer_time

            if ready_to_use_skill(a, store) then
                local nodes, start_node, end_node, next_node, damage_ts
                local target, targets = U.find_nearest_enemy(store, this.pos, 0, a.max_range, a.vis_flags,
                    a.vis_bans)
                local total_hp = not targets and 0 or table.reduce(targets, function(e, hp_sum)
                    return e.health.hp + hp_sum
                end)

                if not target or total_hp < a.trigger_hp then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    U.unblock_target(store, this)
                    S:queue(a.sound_loop)
                    U.y_animation_play(this, a.animations[1], nil, store.tick_ts)

                    if SU.hero_interrupted(this) then
                        -- block empty
                    else
                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts
                        nodes = P:nearest_nodes(this.pos.x, this.pos.y, {target.nav_path.pi}, nil, true)

                        if #nodes == 0 then
                            log.error("hammer_time could not find a valid node near %s,%s", this.pos.x, this.pos.y)

                            goto label_144_0
                        end

                        start_node = {
                            pi = nodes[1][1],
                            spi = nodes[1][2],
                            ni = nodes[1][3]
                        }
                        end_node = table.deepclone(target.nav_path)
                        next_node = table.deepclone(start_node)
                        next_node.dir = start_node.ni > end_node.ni and -1 or 1
                        end_node.ni = next_node.dir * a.nodes_range + start_node.ni

                        U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                        damage_ts = store.tick_ts - a.damage_every

                        while store.tick_ts - a.ts < a.duration and not SU.hero_interrupted(this) do
                            if U.walk(this, store.tick_length) then
                                if math.abs(next_node.ni - start_node.ni) == a.nodes_range then
                                    next_node.dir = next_node.dir * -1
                                end

                                next_node.ni = next_node.ni + next_node.dir
                                next_node.spi = next_node.spi == 3 and 2 or 3

                                U.set_destination(this, P:node_pos(next_node))

                                this.render.sprites[1].flip_x = this.motion.dest.x < this.pos.x
                            end

                            if store.tick_ts - damage_ts >= a.damage_every then
                                damage_ts = store.tick_ts

                                S:queue(a.sound_hit)

                                local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius,
                                    a.vis_flags, a.vis_bans)

                                if targets then
                                    for _, t in pairs(targets) do
                                        local d = SU.create_attack_damage(a, t.id, this)

                                        queue_damage(store, d)

                                        local m = E:create_entity(a.mod)

                                        m.modifier.source_id = this.id
                                        m.modifier.target_id = t.id

                                        queue_insert(store, m)
                                    end
                                end
                            end

                            coroutine.yield()
                        end
                    end

                    a.ts = store.tick_ts - (1 - km.clamp(0, 1, (store.tick_ts - a.ts) / a.duration)) * a.cooldown

                    S:stop(a.sound_loop)
                    U.y_animation_play(this, a.animations[3], nil, store.tick_ts)

                    goto label_144_0
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, false,
                    false, bor(F_FLYING, F_BOSS))

                if target and target.pos and valid_land_node_nearby(target.pos) then
                    this.health.ignore_damage = true
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    this.health.ignore_damage = false
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)

                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            if not ranged_done then
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    goto label_144_0
                end

                if sta == A_DONE then
                    ranged_done = true
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta == A_DONE or sta == A_NO_TARGET then
                ranged_done = nil
            end

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_144_0::

        coroutine.yield()
    end
end

scripts.hero_rag_ultimate = {}

function scripts.hero_rag_ultimate.update(this, store)
    SU.insert_sprite(store, this.hit_fx, this.pos)
    SU.insert_sprite(store, this.hit_decal, this.pos)
    U.y_wait(store, this.hit_time)

    local targets = U.find_enemies_in_range(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans,
        function(e)
            return GR:cell_is_only(e.pos.x, e.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
        end)

    if targets then
        for i, target in ipairs(targets) do
            if i > this.max_count then
                break
            end

            local m = E:create_entity(this.mod)
            m.modifier.source_id = this.id
            m.modifier.target_id = target.id
            m.doll_duration = this.doll_duration * U.frandom(0.97, 1.03)
            queue_insert(store, m)
        end
    end

    queue_remove(store, this)
end

scripts.rabbit_kamihare = {}

function scripts.rabbit_kamihare.update(this, store)
    local start_ts = store.tick_ts
    local a = this.custom_attack
    local s = this.render.sprites[1]

    s.ts = store.tick_ts + (s.random_ts and U.frandom(-s.random_ts, 0) or 0)

    while true do
        local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

        if targets or store.tick_ts - start_ts > this.duration or
            not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or not SU.y_enemy_walk_step(store, this) then
            break
        end
    end

    local aura = E:create_entity(a.aura)

    aura.pos = V.vclone(this.pos)

    queue_insert(store, aura)

    if a.hit_fx then
        local fx = E:create_entity(a.hit_fx)

        fx.pos = V.vclone(this.pos)
        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    end

    U.y_animation_play(this, "death", nil, store.tick_ts)
    queue_remove(store, this)
end

scripts.hero_bruce = {}

function scripts.hero_bruce.fn_chance_sharp_claws(this, store, attack, target)
    return U.has_modifier_types(store, target, MOD_TYPE_BLEED, MOD_TYPE_POISON) or math.random() < attack.chance
end

function scripts.hero_bruce.level_up(this, store)
    local hl, ls = level_up_basic(this, store)
    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[3].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[3].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "sharp_claws", function(this, s)
        local a = this.melee.attacks[3]
        a.disabled = nil
        local m = E:get_template(a.mod)
        m.dps.damage_min = s.damage[s.level]
        m.dps.damage_max = s.damage[s.level]
        m.extra_bleeding_damage = s.extra_damage[s.level]
    end)

    upgrade_skill(this, "kings_roar", function(this, s)
        local a = this.timed_attacks.list[1]
        a.disabled = nil
        local m = E:get_template(a.mod)
        m.modifier.duration = s.stun_duration[s.level]
    end)

    upgrade_skill(this, "lions_fur", function(this, s)
        this.lion_fur_extra = s.extra_hp[s.level]
    end)

    upgrade_skill(this, "grievous_bites", function(this, s)
        local a = this.melee.attacks[4]
        a.disabled = nil
        a.damage_max = s.damage[s.level]
        a.damage_min = s.damage[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        this.ultimate.disabled = nil
        local u = E:get_template(s.controller_name)
        u.count = s.count[s.level]
        local e = E:get_template(u.entity)
        e.custom_attack.damage_boss = s.damage_boss[s.level]
        local m = E:get_template("mod_lion_bruce_damage")
        m.dps.damage_max = s.damage_per_tick[s.level]
        m.dps.damage_min = s.damage_per_tick[s.level]
    end)

    this.health.hp_max = this.health.hp_max + this.lion_fur_extra
    update_regen(this)

    this.health.hp = this.health.hp_max
end

function scripts.hero_bruce.insert(this, store)
    if not scripts.hero_basic.insert(this, store) then
        return false
    end

    local a = E:create_entity("aura_bruce_hps")

    a.aura.source_id = this.id
    a.aura.ts = store.tick_ts
    a.pos = this.pos

    queue_insert(store, a)

    return true
end

function scripts.hero_bruce.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, brk, sta

    this.health_bar.hidden = false

    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_174_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.kings_roar

            if ready_to_use_skill(a, store) then
                local targets = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                if not targets or #targets < a.min_count then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.hit_time) then
                        -- block empty
                    else
                        SU.hero_gain_xp_from_skill(this, skill)

                        a.ts = store.tick_ts
                        targets = U.find_enemies_in_range(store, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                        if targets then
                            for i, target in ipairs(targets) do
                                if i > a.max_count then
                                    break
                                end

                                local m = E:create_entity(a.mod)
                                m.modifier.source_id = this.id
                                m.modifier.target_id = target.id
                                queue_insert(store, m)
                            end
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_174_0
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, 150)

                if target and target.pos and valid_rally_node_nearby(target.pos) then
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)

                    e.pos = V.vclone(target.pos)
                    e.damage_factor = this.unit.damage_factor
                    queue_insert(store, e)

                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end
            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_174_0::

        coroutine.yield()
    end
end

scripts.hero_bruce_ultimate = {}

function scripts.hero_bruce_ultimate.update(this, store)
    local pi, spi, ni
    local target_info = U.find_enemies_in_paths(store.enemies, this.pos, this.range_nodes_min, this.range_nodes_max,
        nil, this.vis_flags, this.vis_bans, true, function(e)
            return not U.flag_has(P:path_terrain_props(e.nav_path.pi), TERRAIN_FAERIE)
        end)

    if target_info then
        local o = target_info[1].origin

        pi, spi, ni = o[1], o[2], o[3]
    else
        local nearest = P:nearest_nodes(this.pos.x, this.pos.y)

        if #nearest > 0 then
            for _, n in pairs(nearest) do
                if band(P:path_terrain_props(n[1]), TERRAIN_FAERIE) == 0 then
                    pi, spi, ni = n[1], n[2], n[3]

                    break
                end
            end
        end
    end

    if pi then
        for i = 1, this.count do
            local e = E:create_entity(this.entity)

            e.nav_path.pi = pi
            e.nav_path.spi = spi
            e.nav_path.ni = ni
            e.damage_factor = this.damage_factor
            queue_insert(store, e)

            spi = km.zmod(spi + 1, 3)
            ni = ni - 2
        end
    end

    queue_remove(store, this)
end

scripts.lion_bruce = {}

function scripts.lion_bruce.insert(this, store)
    this.pos = P:node_pos(this.nav_path)

    if not this.pos then
        return false
    end

    return true
end

function scripts.lion_bruce.update(this, store)
    local attack = this.custom_attack
    local start_ts = store.tick_ts
    local fading

    this.tween.ts = store.tick_ts

    while true do
        local next, new = P:next_entity_node(this, store.tick_length)

        if not fading and
            (not next or not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) or store.tick_ts - start_ts >=
                this.duration) then
            fading = true
            this.tween.remove = true
            this.tween.reverse = true
            this.tween.ts = store.tick_ts

            S:queue(this.sound_events.custom_loop_end)
        end

        if next then
            U.set_destination(this, next)
        end

        local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

        U.animation_start(this, an, af, store.tick_ts)
        U.walk(this, store.tick_length)

        if not fading and store.tick_ts - attack.ts > attack.cooldown then
            attack.ts = store.tick_ts

            local targets = U.find_enemies_in_range(store, this.pos, 0, attack.range, attack.vis_flags,
                attack.vis_bans)

            if targets then
                for _, e in pairs(targets) do
                    if U.flag_has(e.vis.flags, F_BOSS) then
                        local d = E:create_entity("damage")

                        d.value = attack.damage_boss * this.damage_factor
                        d.source_id = this.id
                        d.target_id = e.id
                        d.damage_type = attack.damage_type

                        queue_damage(store, d)

                        this.render.sprites[1].loop_forced = false

                        U.y_animation_play(this, "boom", nil, store.tick_ts)

                        goto label_179_0
                    elseif U.flags_pass(e.vis, attack) then
                        for _, mn in pairs(attack.mods) do
                            local m = E:create_entity(mn)

                            m.modifier.target_id = e.id
                            m.modifier.source_id = this.id

                            queue_insert(store, m)
                        end

                        goto label_179_0
                    end
                end
            end
        end

        coroutine.yield()
    end

    ::label_179_0::

    queue_remove(store, this)
end

scripts.hero_bolverk = {}
function scripts.hero_bolverk.level_up(this, store)
    local hl, ls = level_up_basic(this, store)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "slash", function(this, s)
        this.melee.attacks[2].disabled = nil
        this.melee.attacks[2].damage_min = s.damage_min[s.level]
        this.melee.attacks[2].damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "scream", function(this, s)
        this.timed_attacks.list[1].disabled = nil
        local mod = E:get_template("mod_bolverk_fire")
        mod.dps.damage_min = s.fire_damage[s.level]
        mod.dps.damage_max = s.fire_damage[s.level]
    end)

    upgrade_skill(this, "berserker", function(this, s)
        this.berserker_factor = s.factor[s.level]
    end)

    this.health.hp = this.health.hp_max
end
function scripts.hero_bolverk.insert(this, store)
    this.hero.fn_level_up(this, store)
    this.melee.order = U.attack_order(this.melee.attacks)
    return true
end

function scripts.hero_bolverk.update(this, store)
    local h = this.health
    local he = this.hero
    local brk, sta, a, skill

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_223_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "respawn", nil, store.tick_ts)
            end

            local factor = (this.health.hp / this.health.hp_max) * (1 - this.berserker_factor) + this.berserker_factor
            this.timed_attacks.list[1].cooldown = this.timed_attacks.list[1].raw_cooldown * factor
            this.melee.attacks[1].cooldown = this.melee.attacks[1].raw_cooldown * factor
            this.melee.attacks[2].cooldown = this.melee.attacks[2].raw_cooldown * factor

            a = this.timed_attacks.list[1]

            if ready_to_use_skill(a, store) then
                local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not targets or #targets < a.min_count then
                    SU.delay_attack(store, a, 0.13333333333333333)
                else
                    S:queue(a.sound, a.sound_args)
                    U.animation_start(this, a.animation, nil, store.tick_ts)

                    if SU.y_hero_wait(store, this, a.hit_time) then
                        -- block empty
                    else
                        targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                            a.vis_flags, a.vis_bans)

                        if targets then
                            for _, target in pairs(targets) do
                                local m1 = E:create_entity(a.mods[1])
                                m1.modifier.target_id = target.id
                                m1.modifier.source_id = this.id

                                queue_insert(store, m1)
                                local m2 = E:create_entity(a.mods[2])
                                m2.modifier.target_id = target.id
                                m2.modifier.source_id = this.id
                                queue_insert(store, m2)
                            end
                        end
                        scripts.heal(this, (this.health.hp_max - this.health.hp) * 0.06)
                        SU.y_hero_animation_wait(this)
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.scream)
                        a.ts = store.tick_ts
                    end

                    goto label_223_0
                end
            end

            if this.melee then
                brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or sta ~= A_NO_TARGET then
                    goto label_223_0
                end
            end

            if SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_223_0::

        coroutine.yield()
    end
end
scripts.hero_dwarf = {
    level_up = function(this, store)
        local hl, ls = level_up_basic(this, store)

        this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
        this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

        upgrade_skill(this, "ring", function(this, s)
            local a = this.melee.attacks[2]
            a.disabled = nil
            a.damage_min = s.damage_min[s.level]
            a.damage_max = s.damage_max[s.level]
        end)

        upgrade_skill(this, "giant", function(this, s)
            local a = this.timed_attacks.list[1]
            a.disabled = nil
            a.scale = s.scale[s.level]
        end)

        this.health.hp = this.health.hp_max
    end,
    update = function(this, store)
        local h = this.health
        local he = this.hero
        local brk, sta
        local ring = this.melee.attacks[2]
        U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

        this.health_bar.hidden = false

        while true do
            if h.dead then
                SU.y_hero_death_and_respawn(store, this)
            end

            if this.unit.is_stunned then
                SU.soldier_idle(store, this)
            else
                while this.nav_rally.new do
                    if SU.y_hero_new_rally(store, this) then
                        goto label_467_0
                    end
                end

                if SU.hero_level_up(store, this) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                end

                local a = this.timed_attacks.list[1]
                if ready_to_use_skill(a, store) then
                    local targets = U.find_enemies_in_range(store, this.pos, 0, ring.damage_radius * a.scale,
                        a.vis_flags, a.vis_bans)
                    local bigger_begin_time = store.tick_ts
                    if targets and #targets >= a.min_count then
                        if targets[1].pos.x < this.pos.x then
                            this.render.sprites[1].flip_x = true
                        else
                            this.render.sprites[1].flip_x = false
                        end
                        a.ts = store.tick_ts
                        this.health.ignore_damage = true
                        this.health_bar.hidden = true
                        U.animation_start(this, a.animations[1], nil, store.tick_ts, true)
                        scripts.heal(this, this.health.hp_max * a.scale * 0.1)
                        while store.tick_ts - bigger_begin_time < a.scale_time do
                            local rate = (store.tick_ts - bigger_begin_time) / a.scale_time
                            local current_scale = 1 + (a.scale - 1) * rate
                            this.render.sprites[1].scale.x = current_scale
                            this.render.sprites[1].scale.y = current_scale
                            this.render.sprites[1].alpha = 255 - 127 * rate
                            coroutine.yield()
                        end
                        this.render.sprites[1].scale.x = a.scale
                        this.render.sprites[1].scale.y = a.scale
                        this.render.sprites[1].alpha = 128
                        U.animation_start(this, a.animations[2], nil, store.tick_ts, false)
                        S:queue(a.sound)
                        U.y_animation_wait(this)
                        SU.hero_gain_xp_from_skill(this, this.hero.skills.giant)
                        local hit_pos = V.vclone(this.pos)
                        if this.render.sprites[1].flip_x then
                            hit_pos.x = hit_pos.x - ring.hit_offset.x * a.scale
                        else
                            hit_pos.x = hit_pos.x + ring.hit_offset.x * a.scale
                        end
                        targets = U.find_enemies_in_range(store, hit_pos, 0, ring.damage_radius * a.scale,
                            a.vis_flags, a.vis_bans)
                        if targets then
                            for _, target in pairs(targets) do
                                local d = SU.create_attack_damage(ring, target.id, this)
                                d.value = d.value * a.scale
                                queue_damage(store, d)
                                local fx = E:create_entity(ring.hit_fx)
                                fx.pos = V.vclone(hit_pos)
                                fx.render.sprites[1].ts = store.tick_ts
                                fx.render.sprites[1].scale.x = a.scale
                                fx.render.sprites[1].scale.y = a.scale
                                queue_insert(store, fx)
                                local decal = E:create_entity(ring.hit_decal)
                                decal.pos = V.vclone(hit_pos)
                                decal.render.sprites[1].ts = store.tick_ts
                                decal.render.sprites[1].scale.x = a.scale * decal.render.sprites[1].scale.x
                                decal.render.sprites[1].scale.y = a.scale * decal.render.sprites[1].scale.y
                                queue_insert(store, decal)
                                local mod = E:create_entity(a.mod)
                                if band(target.vis.flags, mod.modifier.vis_bans) == 0 and
                                    band(target.vis.bans, mod.modifier.vis_flags) == 0 then
                                    mod.modifier.source_id = this.id
                                    mod.modifier.target_id = target.id
                                    mod.modifier.duration = mod.modifier.duration * a.scale
                                    queue_insert(store, mod)
                                end
                            end
                        end
                        SU.y_hero_animation_wait(this)
                        U.animation_start(this, a.animations[3], nil, store.tick_ts, true)
                        local smaller_begin_time = store.tick_ts
                        while store.tick_ts - smaller_begin_time < a.scale_time do
                            local rate = (store.tick_ts - smaller_begin_time) / a.scale_time
                            local current_scale = a.scale - (a.scale - 1) * rate
                            this.render.sprites[1].scale.x = current_scale
                            this.render.sprites[1].scale.y = current_scale
                            this.render.sprites[1].alpha = 128 + 127 * rate
                            coroutine.yield()
                        end
                        this.render.sprites[1].scale.x = 1
                        this.render.sprites[1].scale.y = 1
                        this.render.sprites[1].alpha = 255
                        this.health.ignore_damage = false
                        this.health_bar.hidden = false
                    else
                        a.ts = a.ts + 1
                    end
                end

                if this.melee then
                    brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

                    if brk or sta ~= A_NO_TARGET then
                        goto label_467_0
                    end
                end

                if SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end

            ::label_467_0::

            coroutine.yield()
        end
    end
}
-- 红龙
function scripts.hero_dragon.insert(this, store)
    this.hero.fn_level_up(this, store)
    this.ranged.order = U.attack_order(this.ranged.attacks)
    return true
end

function scripts.hero_dragon.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill, force_idle_ts

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    this.health_bar.hidden = false
    force_idle_ts = true

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)

            force_idle_ts = true
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end

        a = this.timed_attacks.list[1]
        skill = this.hero.skills.feast

        if ready_to_use_skill(a, store) then
            local target = U.find_nearest_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                a.vis_bans)

            if not target then
                SU.delay_attack(store, a, 0.13333333333333333)
            else
                SU.hero_gain_xp_from_skill(this, skill)

                a.ts = store.tick_ts

                SU.stun_inc(target)
                S:queue(a.sound)
                U.animation_start(this, "feast", target.pos.x < this.pos.x, store.tick_ts)

                local steps = math.floor(fts(9) / store.tick_length)
                local step_x, step_y = V.mul(1 / steps, target.pos.x - this.pos.x, target.pos.y - this.pos.y - 1)

                for i = 1, steps do
                    this.pos.x, this.pos.y = this.pos.x + step_x, this.pos.y + step_y

                    coroutine.yield()
                end

                local fx = E:create_entity("fx_dragon_feast")

                fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)

                local d = E:create_entity("damage")

                d.damage_type = DAMAGE_PHYSICAL
                d.value = (a.damage + this.damage_buff) * this.unit.damage_factor
                d.target_id = target.id
                d.source_id = this.id

                local actual_damage = U.predict_damage(target, d)

                if math.random() < a.devour_chance or actual_damage >= target.health.hp then
                    if band(target.vis.bans, bor(F_INSTAKILL, F_EAT)) ~= 0 then
                        d.value = d.value * 2
                    else
                        if target.unit.can_explode then
                            d.damage_type = DAMAGE_EAT

                            local fxn, default_fx

                            if target.unit.explode_fx and target.unit.explode_fx ~= "fx_unit_explode" then
                                fxn = target.unit.explode_fx
                                default_fx = false
                            else
                                fxn = "fx_dragon_feast_explode"
                                default_fx = true
                            end

                            local fx = E:create_entity(fxn)
                            local fxs = fx.render.sprites[1]

                            fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                            fxs.ts = store.tick_ts

                            if default_fx then
                                fxs.scale = fxs.size_scales[target.unit.size]
                            else
                                fxs.name = fxs.size_names[target.unit.size]
                            end

                            queue_insert(store, fx)
                        else
                            d.damage_type = DAMAGE_INSTAKILL
                        end
                    end
                end

                queue_damage(store, d)
                SU.stun_dec(target)
                U.y_animation_wait(this)

                force_idle_ts = true

                goto label_383_1
            end
        end

        for _, i in pairs(this.ranged.order) do
            local a = this.ranged.attacks[i]

            if a.disabled then
                -- block empty
            elseif a.sync_animation and not this.render.sprites[1].sync_flag then
                -- block empty
            elseif ready_to_attack(a, store, this.cooldown_factor) then
                local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
                local bullet_t = E:get_template(a.bullet)
                local bullet_speed = bullet_t.bullet.min_speed
                local flight_time = bullet_t.bullet.flight_time
                local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range, a.vis_flags,
                    a.vis_bans)

                if target then
                    local start_ts = store.tick_ts
                    local b, emit_fx, emit_ps, emit_ts, node_offset

                    if flight_time then
                        node_offset = P:predict_enemy_node_advance(target, flight_time + a.shoot_time)
                    else
                        local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)

                        node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
                    end

                    local t_pos

                    if a.name == "fierymist" or a.name == "blazingbreath" then
                        t_pos = P:node_pos(target.nav_path.pi, 1, target.nav_path.ni + node_offset)
                    else
                        t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
                    end

                    local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                    U.animation_start(this, an, af, store.tick_ts)

                    while store.tick_ts - start_ts < a.shoot_time do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_383_0
                        end

                        coroutine.yield()
                    end

                    S:queue(a.sound)

                    b = E:create_entity(a.bullet)
                    b.bullet.target_id = target.id
                    b.bullet.source_id = this.id
                    b.bullet.damage_factor = this.unit.damage_factor
                    b.bullet.damage_min = b.bullet.damage_min + this.damage_buff
                    b.bullet.damage_max = b.bullet.damage_max + this.damage_buff
                    b.pos = V.vclone(this.pos)
                    b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
                    b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.v(t_pos.x, t_pos.y)

                    queue_insert(store, b)

                    if a.xp_from_skill then
                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                    end

                    a.ts = start_ts

                    if a.emit_ps and b.bullet.flight_time then
                        local dest = V.vclone(b.bullet.to)

                        if a.name == "fierymist" or a.name == "blazingbreath" then
                            dest.y = dest.y + 15
                        end

                        emit_ts = store.tick_ts

                        local ps = E:create_entity(a.emit_ps)
                        local mspeed = V.dist(dest.x, dest.y, b.bullet.from.x, b.bullet.from.y) / b.bullet.flight_time

                        ps.particle_system.emit_direction =
                            V.angleTo(dest.x - b.bullet.from.x, dest.y - b.bullet.from.y)
                        ps.particle_system.emit_speed = {mspeed, mspeed}
                        ps.particle_system.flip_x = af
                        ps.pos.x, ps.pos.y = b.bullet.from.x, b.bullet.from.y

                        queue_insert(store, ps)

                        emit_ps = ps
                    end

                    if a.emit_fx then
                        local fx = E:create_entity(a.emit_fx)

                        fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y
                        fx.render.sprites[1].ts = store.tick_ts
                        fx.render.sprites[1].flip_x = af

                        if af and fx.render.sprites[1].offset.x then
                            fx.render.sprites[1].offset.x = -1 * fx.render.sprites[1].offset.x
                        end

                        queue_insert(store, fx)

                        emit_fx = fx
                    end

                    while not U.animation_finished(this) do
                        if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                            goto label_383_0
                        end

                        coroutine.yield()
                    end

                    force_idle_ts = true

                    ::label_383_0::

                    if emit_ps then
                        emit_ps.particle_system.emit = false
                        emit_ps.particle_system.source_lifetime = 0
                    end

                    if emit_fx then
                        emit_fx.render.sprites[1].hidden = true
                    end

                    goto label_383_1
                elseif i == 1 and this.motion.arrived then
                    U.y_wait(store, this.soldier.guard_time)
                end
            end
        end

        SU.soldier_idle(store, this, force_idle_ts)
        SU.soldier_regen(store, this)

        force_idle_ts = nil

        ::label_383_1::

        coroutine.yield()
    end
end

scripts.breath_dragon = {}

function scripts.breath_dragon.update(this, store)
    local b = this.bullet
    local tl = store.tick_length
    local insert_ts = store.tick_ts
    local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

        coroutine.yield()
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y
    this.render.sprites[1].hidden = false

    local start_ts = store.tick_ts
    local fx = E:create_entity("fx_breath_dragon_fire")

    fx.pos.x, fx.pos.y = b.to.x, b.to.y
    fx.render.sprites[1].ts = store.tick_ts

    queue_insert(store, fx)

    local fx = E:create_entity("fx_breath_dragon_fire_decal")

    fx.pos.x, fx.pos.y = b.to.x, b.to.y
    fx.render.sprites[1].ts = store.tick_ts + fts(11)

    queue_insert(store, fx)

    local targets = U.find_enemies_in_range(store, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)
    local every = fts(2)
    local steps = math.floor(this.duration / every)
    local damage_per_step = math.random(b.damage_min, b.damage_max) / steps * b.damage_factor
    local last_ts = 0

    while store.tick_ts - start_ts < this.duration do
        if targets and every < store.tick_ts - last_ts then
            last_ts = store.tick_ts

            for _, e in pairs(targets) do
                if e.health and not e.health.dead then
                    local d = E:create_entity("damage")

                    d.damage_type = b.damage_type
                    d.value = damage_per_step
                    d.target_id = e.id
                    d.source_id = this.id
                    d.xp_gain_factor = b.xp_gain_factor
                    d.xp_dest_id = b.source_id

                    queue_damage(store, d)

                    if b.mod then
                        local mod = E:create_entity(b.mod)

                        mod.modifier.target_id = e.id

                        queue_insert(store, mod)
                    end
                end
            end
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.fierymist_dragon = {}

function scripts.fierymist_dragon.update(this, store)
    local b = this.bullet
    local tl = store.tick_length
    local insert_ts = store.tick_ts
    local node
    local target = store.entities[b.target_id]
    local mspeed = V.dist(b.to.x, b.to.y, b.from.x, b.from.y) / b.flight_time
    local dist2 = mspeed * mspeed * tl * tl
    local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

    if #nodes > 0 then
        node = {
            pi = nodes[1][1],
            spi = nodes[1][2],
            ni = nodes[1][3]
        }
    end

    if not node then
        log.debug("cannot deploy fierymist_dragon: no destination node")
        queue_remove(store, this)

        return
    end

    node.spi = 1

    while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > dist2 do
        b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl

        coroutine.yield()
    end

    local aura = E:create_entity(b.hit_payload)

    aura.pos = P:node_pos(node)

    queue_insert(store, aura)

    local spi = 1

    for i = 1, 14 do
        local ni = node.ni - 6 + i

        if P:is_node_valid(node.pi, ni) then
            local fx = E:create_entity("fx_aura_fierymist_dragon")

            fx.pos = P:node_pos(node.pi, spi, ni)
            fx.pos.x, fx.pos.y = fx.pos.x + math.random(0, 8), fx.pos.y + math.random(0, 8)

            local scale = U.frandom(0.9, 1.1)

            fx.render.sprites[1].scale = V.v(scale, scale)
            fx.render.sprites[1].time_offset = fts(i * 2)
            fx.duration = aura.aura.duration
            fx.tween.ts = store.tick_ts

            queue_insert(store, fx)
        end

        spi = km.zmod(spi + 2, 3)
    end

    queue_remove(store, this)
end

scripts.aura_fiery_mist_ashbite = {}
function scripts.aura_fiery_mist_ashbite.update(this, store)
    local a = this.aura
    a.ts = store.tick_ts
    local last_cycle_ts = store.tick_ts - a.cycle_time
    while true do
        if store.tick_ts - a.ts > a.duration then
            break
        end

        if store.tick_ts - last_cycle_ts > a.cycle_time then
            last_cycle_ts = store.tick_ts

            local targets = U.find_enemies_in_range(store, this.pos, 0, a.radius, a.vis_flags, a.vis_bans)

            if targets then
                for _, target in pairs(targets) do
                    local m = E:create_entity(a.mod)

                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id
                    m.modifier.level = a.level

                    queue_insert(store, m)

                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = target.id

                    local dmin, dmax = a.damage_min, a.damage_max
                    d.value = math.random(dmin, dmax)
                    d.damage_type = a.damage_type

                    queue_damage(store, d)
                end
            end
        end

        coroutine.yield()
    end
    queue_remove(store, this)
end

scripts.wildfirebarrage_dragon = {}

function scripts.wildfirebarrage_dragon.insert(this, store)
    local b = this.bullet
    local target = store.entities[b.target_id]

    if not target then
        log.debug("target removed before inserting wildfirebarrage")

        return false
    end

    local node_offset = P:predict_enemy_node_advance(target, b.flight_time)

    b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
    b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
    b.ts = store.tick_ts
    b.last_pos = V.vclone(b.from)

    return true
end

function scripts.wildfirebarrage_dragon.update(this, store)
    local b = this.bullet
    local dradius = b.damage_radius
    local ps = E:create_entity(b.particles_name)

    ps.particle_system.track_id = this.id

    queue_insert(store, ps)

    while store.tick_ts - b.ts < b.flight_time do
        b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
        this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)
        this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)

        coroutine.yield()
    end

    this.render.sprites[1].hidden = true
    ps.particle_system.emit = false

    local delays = {0, 0.1, 0, 0.1, 0, 0.1, 0, 0.1, 0, 0, 0, 0.2, 0, 0, 0, 0}
    local node_offsets = {0, 2, 4, -4, 0, 0, 6, -6, 8, 8, -8, -8, 10, -10, 12, -12}
    local node_subpaths = {1, 1, 1, 1, 2, 3, 1, 1, 2, 3, 2, 3, 1, 1, 2, 3}
    local node
    local nodes = P:nearest_nodes(b.to.x, b.to.y, nil, nil, true)

    if #nodes < 1 then
        -- block empty
    else
        node = {
            pi = nodes[1][1],
            spi = nodes[1][2],
            ni = nodes[1][3]
        }

        for i = 1, this.explosions do
            local fx, decal, pos, targets
            local n = {
                pi = node.pi,
                spi = node_subpaths[i],
                ni = node.ni + node_offsets[i]
            }
            local pos = P:node_pos(n)

            if not P:is_node_valid(n.pi, n.ni) then
                -- block empty
            else
                fx = E:create_entity("fx_wildfirebarrage_explosion_" .. ((i == 1 or i == 5 or i == 6) and "2" or "1"))
                fx.pos = pos
                fx.render.sprites[1].ts = store.tick_ts

                queue_insert(store, fx)

                decal = E:create_entity("decal_wildfirebarrage_explosion")
                decal.pos = V.vclone(pos)
                decal.render.sprites[1].ts = store.tick_ts

                queue_insert(store, decal)

                targets = U.find_enemies_in_range(store, pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

                if targets then
                    for _, target in pairs(targets) do
                        local d = SU.create_bullet_damage(b, target.id, this.id)

                        d.xp_dest_id = b.source_id

                        queue_damage(store, d)

                        if b.mod then
                            local mod = E:create_entity(b.mod)

                            mod.modifier.target_id = target.id
                            mod.modifier.damage_factor = b.damage_factor
                            queue_insert(store, mod)
                        end
                    end
                end
            end

            if delays[i] > 0 then
                U.y_wait(store, delays[i])
            end
        end
    end

    queue_remove(store, this)
end

scripts.hero_hunter = {}
function scripts.hero_hunter.level_up(this, store)
    local hl, ls = level_up_basic(this)
    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    local b = E:get_template(this.ranged.attacks[1].bullet)
    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]
    upgrade_skill(this, "heal_strike", function(this, s)
        local a = this.timed_attacks.list[1]
        a.disabled = nil
        a.damage_min = s.damage_min[s.level]
        a.damage_max = s.damage_max[s.level]
        a.heal_factor = s.heal_factor[s.level]
    end)

    upgrade_skill(this, "ricochet", function(this, s)
        local a = this.timed_attacks.list[2]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local b = E:get_template(a.bullet)

        b.bounces = s.bounces[s.level]

        local m = E:get_template(b.bullet.mods[1])

        m.damage_min = s.damage_min[s.level]
        m.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "shoot_around", function(this, s)
        local a = this.timed_attacks.list[3]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local aura = E:get_template(a.aura)

        aura.aura.damage_min = s.damage_min[s.level]
        aura.aura.damage_max = s.damage_max[s.level]
        aura.aura.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "beasts", function(this, s)
        local a = this.timed_attacks.list[4]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local entity = E:get_template(a.entity)

        entity.duration = s.duration[s.level]
        entity.attacks.list[1].damage_min = s.damage_min[s.level]
        entity.attacks.list[1].damage_max = s.damage_max[s.level]
        entity.gold_to_steal = s.gold_to_steal[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local a = this.ultimate
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.cooldown_death_triger = a.cooldown + a.cooldown
        local uc = E:get_template(s.controller_name)

        local entity = E:get_template(uc.entity)
        local bullet = E:get_template(entity.ranged.attacks[1].bullet)
        bullet.bullet.damage_min = s.damage_min[s.level]
        bullet.bullet.damage_max = s.damage_max[s.level]

        uc.level = s.level
        local mod = E:get_template("mod_anya_ultimate_beacon")
        mod.inflicted_damage_factor = 1.5 + s.level * 0.5
    end)

    this.health.hp = this.health.hp_max
    this.hero.melee_active_status = {}

    for index, attack in ipairs(this.melee.attacks) do
        this.hero.melee_active_status[index] = attack.disabled
    end
end

function scripts.hero_hunter.insert(this, store)
    this.hero.fn_level_up(this, store, true)

    this.melee.order = U.attack_order(this.melee.attacks)
    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_hunter.update(this, store)
    local h = this.health
    local a, skill, brk, sta
    local last_ts = store.tick_ts
    local last_target
    local last_target_ts = store.tick_ts
    local base_speed = this.motion.max_speed
    local melee_attack = this.melee.attacks[1]
    local ranged_attack = this.ranged.attacks[1]
    local melee_hits = 0
    local heal_strike_ready = false
    local last_attack_ranged = false
    local aim_before_shot = true
    local shooting_state = false
    local heal_strike_attack = this.timed_attacks.list[1]
    local ricochet_attack = this.timed_attacks.list[2]
    local shoot_around_attack = this.timed_attacks.list[3]
    local beasts_attack = this.timed_attacks.list[4]
    local start_ts = 0

    ricochet_attack.ts = store.tick_ts - ricochet_attack.cooldown

    shoot_around_attack.ts = store.tick_ts - shoot_around_attack.cooldown

    beasts_attack.ts = store.tick_ts - beasts_attack.cooldown

    local function shoot_ricochet_arrow(store, this, target, attack, pred_pos)
        local attack_done = false
        local start_ts = store.tick_ts
        local bullet
        local bullet_to = pred_pos or target.pos
        local bullet_to_start = V.vclone(bullet_to)

        while store.tick_ts - start_ts < attack.shoot_time do
            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                goto label_338_0
            end

            coroutine.yield()
        end

        S:queue(attack.sound_shoot)

        bullet = E:create_entity(attack.bullet)
        bullet.pos = V.vclone(this.pos)

        if attack.bullet_start_offset then
            local offset = attack.bullet_start_offset[ai]

            bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
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
            SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
        end

        attack_done = true

        ::label_338_0::

        return attack_done, bullet
    end

    local function animation_name_facing_angle_hero_hunter(group, angle_deg)
        local a = this.render.sprites[1]
        local o_name, o_flip, o_idx
        local a1, a2, a3, a4, a5, a6, a7, a8 = 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5
        local quadrant = a._last_quadrant
        local angles = a.angles[group]

        if a1 <= angle_deg and angle_deg < a2 then
            o_name, o_flip, o_idx = angles[3], false, 3
            quadrant = 1
        elseif a2 <= angle_deg and angle_deg < a3 then
            o_name, o_flip, o_idx = angles[4], false, 4
            quadrant = 2
        elseif a3 <= angle_deg and angle_deg < a4 then
            o_name, o_flip, o_idx = angles[3], true, 3
            quadrant = 3
        elseif a4 <= angle_deg and angle_deg < a5 then
            o_name, o_flip, o_idx = angles[2], true, 2
            quadrant = 4
        elseif a5 <= angle_deg and angle_deg < a6 then
            o_name, o_flip, o_idx = angles[1], true, 1
            quadrant = 5
        elseif a6 <= angle_deg and angle_deg < a7 then
            o_name, o_flip, o_idx = angles[5], false, 5
            quadrant = 6
        elseif a7 <= angle_deg and angle_deg < a8 then
            o_name, o_flip, o_idx = angles[1], false, 1
            quadrant = 7
        else
            o_name, o_flip, o_idx = angles[2], false, 2
            quadrant = 8
        end

        return o_name, o_flip, o_idx
    end

    local function animation_name_facing_point_hero_hunter(e, group, point, idx, offset, use_path)
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
        local angle_deg = km.rad2deg(angle)

        return animation_name_facing_angle_hero_hunter(group, angle_deg)
    end

    local function y_soldier_do_ranged_attack_hero_hunter(store, this, target, attack, pred_pos)
        local attack_done = false
        start_ts = store.tick_ts
        local bullet
        local bullet_to = pred_pos or target.pos
        local bullet_to_start = V.vclone(bullet_to)
        if not shooting_state then
            local an, af, ai = U.animation_name_facing_point(this, attack.animation_prepare, bullet_to)

            U.y_animation_play(this, an, af, store.tick_ts, 1)

            local an, af, ai = animation_name_facing_point_hero_hunter(this, attack.animation_aim, bullet_to)

            U.y_animation_play(this, an, af, store.tick_ts, 1)
            shooting_state = true
            start_ts = store.tick_ts
        end

        local an, af, ai = animation_name_facing_point_hero_hunter(this, attack.animation, bullet_to)

        U.animation_start(this, an, af, store.tick_ts, false)
        S:queue(attack.sound, attack.sound_args)

        while store.tick_ts - start_ts < attack.shoot_time do
            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                goto label_343_0
            end

            coroutine.yield()
        end

        S:queue(attack.sound_shoot)

        bullet = E:create_entity(attack.bullet)
        bullet.pos = V.vclone(this.pos)

        if attack.bullet_start_offset then
            local offset = attack.bullet_start_offset[ai]

            bullet.pos.x, bullet.pos.y = bullet.pos.x + (af and -1 or 1) * offset.x, bullet.pos.y + offset.y
        end

        bullet.bullet.from = V.vclone(bullet.pos)
        bullet.bullet.to = V.vclone(bullet_to)
        bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
        bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
        bullet.bullet.target_id = target.id
        bullet.bullet.source_id = this.id
        bullet.bullet.xp_dest_id = this.id
        bullet.bullet.level = this.hero.level
        bullet.bullet.damage_factor = this.unit.damage_factor
        bullet.bullet.damage_min = bullet.bullet.damage_min + this.damage_buff
        bullet.bullet.damage_max = bullet.bullet.damage_max + this.damage_buff
        queue_insert(store, bullet)

        if attack.xp_from_skill then
            SU.hero_gain_xp_from_skill(this, this.hero.skills[attack.xp_from_skill])
        end

        attack_done = true

        while not U.animation_finished(this) do
            if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                break
            end

            coroutine.yield()
        end

        ::label_343_0::

        return attack_done
    end

    local function y_hero_ranged_attack_hero_hunter(store, hero)
        local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, hero)

        if not target then
            return false, A_NO_TARGET
        end

        if not attack then
            return false, A_IN_COOLDOWN
        end

        local attack_done

        U.set_destination(hero, hero.pos)

        attack_done = y_soldier_do_ranged_attack_hero_hunter(store, hero, target, attack, pred_pos)

        if attack_done then
            attack.ts = start_ts

            if attack.shared_cooldown then
                for _, aa in pairs(hero.ranged.attacks) do
                    if aa ~= attack and aa.shared_cooldown then
                        aa.ts = attack.ts
                    end
                end
            end

            if hero.ranged.forced_cooldown then
                hero.ranged.forced_ts = start_ts
            end
        end

        if attack_done then
            return false, A_DONE
        else
            return true
        end
    end

    local function quit_shooting_state()
        if shooting_state then
            shooting_state = false
            U.y_animation_play(this, "shoot_backtoidle", nil, store.tick_ts, 1)
        end
    end

    this.health_bar.hidden = false

    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

    while true do
        if h.dead then
            if store.tick_ts - this.ultimate.death_triger_ts > this.ultimate.cooldown_death_triger then
                local revive = true
                for _, s in pairs(store.soldiers) do
                    if s.template_name == "soldier_hero_hunter_ultimate" then
                        revive = false
                        break
                    end
                end
                if revive then
                    S:queue(this.sound_events.change_rally_point)
                    local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                    ultimate_entity.pos = V.vclone(this.pos)
                    ultimate_entity.level = this.hero.skills.ultimate.level
                    ultimate_entity.damage_factor = this.unit.damage_factor
                    ultimate_entity.owner_id = this.id
                    queue_insert(store, ultimate_entity)
                    this.ultimate.death_triger_ts = store.tick_ts
                end
            end
            shooting_state = false
            SU.y_hero_death_and_respawn(store, this)
            U.update_max_speed(this, base_speed)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
            shooting_state = false
        else
            while this.nav_rally.new do
                local r = this.nav_rally
                local tw = this.flywalk
                local force_flywalk = false
                quit_shooting_state()
                for _, p in pairs(this.nav_grid.waypoints) do
                    if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
                        force_flywalk = true

                        break
                    end
                end

                if force_flywalk or V.dist2(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance *
                    tw.min_distance then
                    r.new = false

                    U.unblock_target(store, this)

                    local vis_bans = this.vis.bans

                    this.vis.bans = F_ALL
                    this.health.immune_to = F_ALL

                    local original_speed = this.motion.max_speed
                    U.speed_inc_self(this, tw.extra_speed)
                    this.unit.marker_hidden = true
                    this.health_bar.hidden = true

                    S:queue(this.sound_events.change_rally_point)
                    S:queue(this.flywalk.sound)

                    local an, af = U.animation_name_facing_point(this, tw.animations[1], r.pos)

                    U.animation_start(this, an, af, store.tick_ts)

                    local ps

                    ::label_337_0::

                    local dest = r.pos
                    local n = this.nav_grid

                    if ps ~= nil then
                        ps.particle_system.emit = false

                        queue_remove(store, ps)

                        ps = nil
                    end

                    while not V.veq(this.pos, dest) do
                        local w = table.remove(n.waypoints, 1) or dest

                        U.set_destination(this, w)

                        local runs = this.render.sprites[1].runs

                        while not this.motion.arrived do
                            if r.new then
                                r.new = false

                                goto label_337_0
                            end

                            if w.x < this.pos.x then
                                this.render.sprites[1].flip_x = true
                            else
                                this.render.sprites[1].flip_x = false
                            end

                            if ps ~= nil then
                                local offset_index = this.pos.x > w.x and 1 or 2

                                ps.particle_system.emit_offset = ps.particle_system.emit_offsets[offset_index]
                            end

                            U.walk(this, store.tick_length)
                            coroutine.yield()

                            this.motion.speed.x, this.motion.speed.y = 0, 0

                            if this.render.sprites[1].runs ~= runs then
                                local an, af = U.animation_name_facing_point(this, tw.animations[2], w)

                                U.animation_start(this, an, af, store.tick_ts, true, 1, true)

                                runs = this.render.sprites[1].runs

                                if ps == nil then
                                    ps = E:create_entity(this.flywalk.trail)
                                    ps.particle_system.emit = true
                                    ps.particle_system.track_id = this.id

                                    local offset_index = this.pos.x > r.pos.x and 1 or 2

                                    ps.particle_system.emit_offset = ps.particle_system.emit_offsets[offset_index]

                                    queue_insert(store, ps)
                                end
                            end
                        end
                    end

                    if ps ~= nil then
                        ps.particle_system.emit = false

                        queue_remove(store, ps)
                    end

                    SU.hide_modifiers(store, this, true)
                    U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
                    SU.show_modifiers(store, this, true)

                    U.update_max_speed(this, original_speed)
                    this.vis.bans = vis_bans
                    this.health.immune_to = 0
                    this.unit.marker_hidden = nil
                    this.health_bar.hidden = nil
                elseif SU.y_hero_new_rally(store, this) then
                    goto label_337_1
                end
            end

            if SU.hero_level_up(store, this) then
                quit_shooting_state()
                U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
            end

            if ready_to_use_skill(this.ultimate, store) then
                local enemy = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range)
                if enemy and enemy.pos and valid_rally_node_nearby(enemy.pos) then
                    shooting_state = false
                    U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local ultimate_entity = E:create_entity(this.hero.skills.ultimate.controller_name)
                    ultimate_entity.pos = V.vclone(enemy.pos)
                    ultimate_entity.level = this.hero.skills.ultimate.level
                    ultimate_entity.damage_factor = this.unit.damage_factor
                    ultimate_entity.owner_id = this.id
                    queue_insert(store, ultimate_entity)
                    this.ultimate.ts = store.tick_ts
                    melee_hits = melee_hits + 1
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            skill = this.hero.skills.heal_strike
            a = heal_strike_attack

            if not heal_strike_ready or this.soldier.target_id == nil then
                -- block empty
            elseif not this.motion.arrived then
                -- block empty
            else
                local target = store.entities[this.soldier.target_id]

                if not target then
                    -- block empty
                elseif target.health.dead then
                    -- block empty
                else
                    last_ts = store.tick_ts

                    local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)
                    shooting_state = false
                    U.animation_start(this, an, af, store.tick_ts, false)
                    U.y_wait(store, fts(18))
                    S:queue(a.sound)
                    U.y_wait(store, fts(7))

                    local fx = E:create_entity(a.hit_fx)

                    fx.render.sprites[1].pos = V.vclone(this.pos)
                    fx.render.sprites[1].offset = V.v(a.hit_offset.x, a.hit_offset.y)
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                    queue_damage(store, SU.create_attack_damage(a, target.id, this))

                    this.health.hp = this.health.hp + target.health.hp_max * a.heal_factor

                    if this.health.hp > this.health.hp_max then
                        this.health.hp = this.health.hp_max
                    elseif this.health.hp > 0 and this.health.dead then
                        this.health.dead = false
                    end

                    heal_strike_ready = false
                    melee_hits = 0
                    a.ts = last_ts

                    SU.hero_gain_xp_from_skill(this, skill)
                    U.y_animation_wait(this)

                    goto label_337_1
                end
            end

            skill = this.hero.skills.ricochet
            a = ricochet_attack

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemy, enemies = U.find_foremost_enemy(store, tpos(this), a.min_range,
                    a.max_range_trigger, a.node_prediction, a.vis_flags, a.vis_bans)

                if not enemy then
                    SU.delay_attack(store, a, fts(10))
                elseif enemy and #enemies >= ricochet_attack.min_targets then
                    shooting_state = false
                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, "mist_run_in", enemy.pos, 1)

                    U.animation_start(this, an, af, store.tick_ts, 1)
                    S:queue(a.sound)
                    U.y_animation_play(this, "mist_run_in", nil, store.tick_ts, 1)

                    local attack_done, bullet = shoot_ricochet_arrow(store, this, enemy, a, V.vclone(enemy.pos))

                    U.animation_start(this, "mist_run_loop", nil, store.tick_ts, true)

                    melee_hits = melee_hits + 1

                    if attack_done then
                        while not bullet.end_bounces do
                            coroutine.yield()
                        end
                    end

                    U.y_animation_play(this, "mist_run_end", nil, store.tick_ts, 1)

                    ricochet_attack.ts = start_ts
                    last_ts = start_ts

                    goto label_337_1
                end
            end

            skill = this.hero.skills.shoot_around
            a = shoot_around_attack

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemies =
                    U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts
                    shooting_state = false
                    U.animation_start(this, a.animations[1], nil, store.tick_ts, 1)

                    if SU.y_hero_animation_wait(this) then
                        -- block empty
                    else
                        S:queue(a.sound)
                        this.health.immune_to = F_ALL
                        a.ts = start_ts
                        melee_hits = melee_hits + 1
                        last_ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        local aura = E:create_entity(a.aura)
                        aura.aura.source_id = this.id
                        aura.aura.ts = store.tick_ts
                        aura.pos = this.pos
                        aura.aura.damage_factor = this.unit.damage_factor
                        queue_insert(store, aura)
                        U.animation_start(this, a.animations[2], nil, store.tick_ts, true)

                        if SU.y_hero_wait(store, this, aura.aura.duration - (store.tick_ts - a.ts)) then
                            S:stop(a.sound)
                            S:queue(a.sound_interrupt)
                            a.ts = a.ts - (1 - (store.tick_ts - a.ts) / aura.aura.duration) * a.cooldown
                        end

                        S:stop(a.sound)
                        S:queue(a.sound_interrupt)
                        queue_remove(store, aura)
                        U.y_animation_play(this, a.animations[3], nil, store.tick_ts, 1)
                        this.health.immune_to = F_NONE
                        last_ts = start_ts
                        goto label_337_1
                    end
                end
            end

            skill = this.hero.skills.beasts
            a = beasts_attack

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemies =
                    U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

                if not enemies or #enemies < 1 then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts
                    shooting_state = false
                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts, 1)

                    a.ts = start_ts
                    last_ts = start_ts
                    melee_hits = melee_hits + 1

                    SU.hero_gain_xp_from_skill(this, skill)

                    for i = 1, 2 do
                        local offset_x = i == 1 and a.spawn_offset_x or a.spawn_offset_x * -1
                        local offset_y = a.spawn_offset_y + math.random(1, 4) - 2
                        local beast = E:create_entity(a.entity)

                        beast.owner = this
                        beast.pos = V.vclone(this.pos)
                        beast.pos.x = beast.pos.x + offset_x
                        beast.pos.y = beast.pos.y - offset_y
                        beast.owner_offset = V.v(offset_x, offset_y)

                        queue_insert(store, beast)
                        U.y_wait(store, fts(2))
                    end

                    SU.y_hero_animation_wait(this)

                    aim_before_shot = true
                    last_ts = start_ts

                    goto label_337_1
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if not heal_strike_attack.disabled and sta == A_DONE and this.melee.last_attack.attack == melee_attack then
                melee_hits = melee_hits + 1

                if melee_hits >= heal_strike_attack.hits_to_trigger then
                    heal_strike_ready = true
                end
            end

            if brk or sta ~= A_NO_TARGET then
                -- block empty
                shooting_state = false
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
                shooting_state = false
            else
                brk, sta = y_hero_ranged_attack_hero_hunter(store, this)

                if brk then
                    -- block empty
                else
                    if sta == A_DONE then
                        last_attack_ranged = true
                    end

                    if last_attack_ranged then
                        if store.tick_ts - ranged_attack.ts > 1.5 then
                            last_attack_ranged = false
                            quit_shooting_state()
                        end
                    else
                        SU.soldier_idle(store, this)
                    end

                    SU.soldier_regen(store, this)
                end
            end
        end

        ::label_337_1::

        coroutine.yield()
    end
end

scripts.arrow_hero_hunter_ricochet = {}

function scripts.arrow_hero_hunter_ricochet.update(this, store)
    local b = this.bullet
    local target = store.entities[b.target_id]
    local dest = V.vclone(b.to)
    local bounce_count = 0
    local already_hit = {}
    local last_target
    local start_ts = store.tick_ts

    this.end_bounces = false

    local function create_arrow_trail(from, target)
        local bullet = E:create_entity(this.trail_arrow)

        bullet.pos = V.vclone(this.pos)
        bullet.bullet.from = V.vclone(from)
        bullet.bullet.to = V.vclone(target.pos)
        bullet.bullet.to.x = bullet.bullet.to.x + target.unit.hit_offset.x
        bullet.bullet.to.y = bullet.bullet.to.y + target.unit.hit_offset.y
        bullet.bullet.target_id = target.id
        bullet.bullet.source_id = this.id
        bullet.bullet.xp_dest_id = this.id
        bullet.bullet.damage_factor = this.bullet.damage_factor
        queue_insert(store, bullet)
    end

    ::label_346_0::

    if not b.ignore_hit_offset and this.track_target and target and target.motion then
        b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
    end

    if last_target ~= nil then
        this.pos = V.vclone(last_target.pos)

        if last_target.unit.hit_offset then
            this.pos.x, this.pos.y = this.pos.x + last_target.unit.hit_offset.x,
                this.pos.y + last_target.unit.hit_offset.y
        end
    end

    if b.hit_time > fts(1) then
        while store.tick_ts - start_ts < b.hit_time do
            coroutine.yield()

            if target and U.flag_has(target.vis.bans, F_RANGED) then
                target = nil
            end
        end
    end

    if target then
        create_arrow_trail(this.pos, target)
    end

    if this.ray_duration then
        while store.tick_ts - start_ts < this.ray_duration do
            coroutine.yield()
        end
    end

    if target and not target.health.dead then
        S:queue(this.sound_bounce)

        if b.mod or b.mods then
            local mods = b.mods or {b.mod}

            for _, mod_name in pairs(mods) do
                local m = E:create_entity(mod_name)

                m.modifier.source_id = this.id
                m.modifier.target_id = target.id
                m.modifier.damage_factor = this.bullet.damage_factor
                m.bounce_count = bounce_count

                queue_insert(store, m)
            end
        end

        table.insert(already_hit, target.id)

        last_target = target
    end

    if b.hit_fx then
        local sfx = E:create_entity(b.hit_fx)

        sfx.pos.x, sfx.pos.y = b.to.x, b.to.y
        sfx.render.sprites[1].ts = store.tick_ts
        sfx.render.sprites[1].runs = 0

        queue_insert(store, sfx)
    end

    S:queue(this.sound)
    U.y_wait(store, this.time_between_bounces)

    if target then
        local search_pos = V.vclone(target.pos)

        if bounce_count < this.bounces then
            local targets = U.find_enemies_in_range(store, search_pos, 0, this.bounce_range, b.vis_flags,
                b.vis_bans, function(v)
                    return not table.contains(already_hit, v.id)
                end)

            if targets then
                table.sort(targets, function(e1, e2)
                    return V.dist2(this.pos.x, this.pos.y, e1.pos.x, e1.pos.y) <
                               V.dist2(this.pos.x, this.pos.y, e2.pos.x, e2.pos.y)
                end)

                target = targets[1]
                bounce_count = bounce_count + 1
                b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
                b.target_id = target.id

                goto label_346_0
            end
        end
    end

    this.end_bounces = true

    queue_remove(store, this)
end

scripts.arrow_hero_hunter_ricochet_trail = {}

function scripts.arrow_hero_hunter_ricochet_trail.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
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

    if this.ray_duration then
        while store.tick_ts - s.ts < this.ray_duration do
            update_sprite()
            coroutine.yield()
        end
    end

    queue_remove(store, this)
end

scripts.mod_hero_hunter_ricochet_attack = {}

function scripts.mod_hero_hunter_ricochet_attack.update(this, store, script)
    local m = this.modifier
    local start_ts = store.tick_ts
    local already_hit = false

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    local anim_index = km.zmod(this.bounce_count + 1, #this.animations)

    this.render.sprites[1].name = this.animations[anim_index]
    this.render.sprites[1].ts = store.tick_ts

    while true do
        if not already_hit and store.tick_ts - m.ts >= this.hit_delay then
            local d = E:create_entity("damage")

            d.damage_type = this.damage_type
            d.value = math.random(this.damage_min, this.damage_max) * this.modifier.damage_factor
            d.target_id = target.id
            d.source_id = this.id

            queue_damage(store, d)

            already_hit = true
        end

        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node then
            queue_remove(store, this)

            return
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

                if target.render.sprites[1].flip_x then
                    s.offset.x = s.offset.x - this.enemy_distance
                else
                    s.offset.x = s.offset.x + this.enemy_distance
                end

                s.flip_x = not target.render.sprites[1].flip_x
            end
        end

        coroutine.yield()
    end
end

scripts.aura_hero_hunter_shoot_around = {}

function scripts.aura_hero_hunter_shoot_around.update(this, store, script)
    this.aura.ts = store.tick_ts

    local last_hit_ts = 0
    local cycles_count = 0
    local last_fx = store.tick_ts

    local function distribute_fx(x, y, qty)
        if qty < 1 then
            return nil
        end

        local nodes = P:nearest_nodes(x, y, nil, nil, true)

        if #nodes < 1 then
            log.debug("cannot insert fx, no valid nodes nearby %s,%s", x, y)
        end

        local opi, ospi, oni = unpack(nodes[1])
        local offset_options = {-2, -4, -6, 2, 4, 6}
        local positions = {}

        for i, offset in ipairs(offset_options) do
            if qty <= #positions then
                break
            end

            local ni = oni + offset
            local spi = km.zmod(ospi + i, 3)
            local npos = P:node_pos(opi, spi, ni)

            if P:is_node_valid(opi, ni) and
                band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
                table.insert(positions, npos)
            end
        end

        return positions
    end

    while true do
        if this.aura.cycles then
            if cycles_count >= this.aura.cycles then
                break
            end
        elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration + this.aura.level *
            this.aura.duration_inc then
            break
        end

        if this.aura.track_source and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if not te or te.health and te.health.dead then
                queue_remove(store, this)

                return
            end

            if te and te.pos then
                this.pos.x, this.pos.y = te.pos.x, te.pos.y
            end
        end

        if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
            cycles_count = cycles_count + 1
            last_hit_ts = store.tick_ts
            local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags,
                this.aura.vis_bans, function(v)
                    return
                               (not this.aura.allowed_templates or
                                   table.contains(this.aura.allowed_templates, v.template_name)) and
                               (not this.aura.excluded_templates or
                                   not table.contains(this.aura.excluded_templates, v.template_name)) and
                               (not this.aura.excluded_entities or not table.contains(this.aura.excluded_entities, v.id))
                end) or {}

            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id

                local dmin, dmax = this.aura.damage_min, this.aura.damage_max

                if this.aura.damage_inc then
                    dmin = dmin + this.aura.damage_inc * this.aura.level
                    dmax = dmax + this.aura.damage_inc * this.aura.level
                end

                d.value = math.random(dmin, dmax) * this.aura.damage_factor
                d.damage_type = this.aura.damage_type
                d.track_damage = this.aura.track_damage
                d.xp_dest_id = this.aura.xp_dest_id
                d.xp_gain_factor = this.aura.xp_gain_factor

                queue_damage(store, d)

                local mods = this.aura.mods or {this.aura.mod}

                for _, mod_name in pairs(mods) do
                    local m = E:create_entity(mod_name)

                    m.modifier.level = this.aura.level
                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id

                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        m.render = nil
                    end

                    queue_insert(store, m)
                end
            end
        end

        if store.tick_ts - last_fx >= this.fx_every then
            local positions = distribute_fx(this.pos.x, this.pos.y, 9)

            positions = table.random_order(positions)

            for i = 1, this.fx_amount do
                if i <= #positions then
                    local fx = E:create_entity(this.fx)

                    fx.pos = positions[i]
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                end
            end

            last_fx = store.tick_ts
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.bullet_hero_hunter_ranged_attack = {}

function scripts.bullet_hero_hunter_ranged_attack.update(this, store)
    local b = this.bullet
    local target = store.entities[b.target_id]
    local source = store.entities[b.source_id]

    -- b.damage_min = b.damage_min_config[b.level]
    -- b.damage_max = b.damage_max_config[b.level]

    U.y_wait(store, b.flight_time)

    if target then
        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)

        if b.hit_fx then
            local fx = E:create_entity(b.hit_fx)

            fx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        if b.floor_fx and band(target.vis.flags, F_CLIFF) == 0 then
            local fx = E:create_entity(b.floor_fx)

            fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end
    end

    queue_remove(store, this)
end

scripts.bullet_hero_hunter_ultimate_ranged_attack = {}

function scripts.bullet_hero_hunter_ultimate_ranged_attack.update(this, store)
    local b = this.bullet
    local target = store.entities[b.target_id]
    local source = store.entities[b.source_id]

    U.y_wait(store, b.flight_time)

    if target then
        local d = SU.create_bullet_damage(b, target.id, this)

        queue_damage(store, d)

        if b.hit_fx then
            local fx = E:create_entity(b.hit_fx)

            fx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end

        if b.floor_fx and band(target.vis.flags, F_CLIFF) == 0 then
            local fx = E:create_entity(b.floor_fx)

            fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end
    end

    queue_remove(store, this)
end

scripts.soldier_hero_hunter_beast = {}

function scripts.soldier_hero_hunter_beast.update(this, store)
    local sf = this.render.sprites[1]
    local fm = this.force_motion
    local attack = this.attacks.list[1]
    local target = this.enemy_target
    local move_to_owner = false
    local enemies_stole_gold = {}

    sf.offset.y = this.flight_height
    attack.ts = store.tick_ts

    local last_time_change_pos = store.tick_ts
    local idle_change_pos = V.v(0, 0)

    local function move(dest)
        sf.flip_x = dest.x < this.pos.x

        U.force_motion_step(this, store.tick_length, dest)

        return V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
    end

    local function do_attack()
        local target_h = target.unit.hit_offset.y
        local target_pos = V.v(target.pos.x, target.pos.y)

        if target.unit.head_offset then
            target_pos.x, target_pos.y = target_pos.x + target.unit.head_offset.x,
                target_pos.y + target.unit.head_offset.y
        elseif target.unit.hit_offset then
            target_pos.x, target_pos.y = target_pos.x + target.unit.hit_offset.x,
                target_pos.y + target.unit.hit_offset.y
        end

        local dist = V.dist(this.pos.x, this.pos.y, target_pos.x, target_pos.y)

        while true do
            if target.health.dead then
                break
            end

            if dist < 5 and math.abs(sf.offset.y - target_h) < 5 then
                break
            end

            dist = move(target_pos)

            local move_height = target_h > sf.offset.y and 2 or -2

            sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)

            coroutine.yield()
        end

        if target.health.dead then
            attack.ts = store.tick_ts

            return false
        end

        this.pos.x, this.pos.y = target_pos.x, target_pos.y - 1
        sf.offset.y = target_h

        U.animation_start(this, "attack", nil, store.tick_ts, false)

        attack.ts = store.tick_ts

        local already_hit = false
        local start_attack_ts = store.tick_ts

        this.force_motion.max_a = this.force_motion.max_a * 1.5
        this.force_motion.max_v = this.force_motion.max_v * 1.5

        while not U.animation_finished(this) do
            if not already_hit and store.tick_ts - start_attack_ts >= attack.shoot_time then
                already_hit = true

                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id
                d.value = math.random(attack.damage_min, attack.damage_max)
                d.damage_type = attack.damage_type

                queue_damage(store, d)

                if not table.contains(enemies_stole_gold, target.id) and math.random(0, 100) <= this.chance_to_steal then
                    local fx = E:create_entity(this.steal_fx)

                    fx.pos = V.vclone(target.pos)
                    fx.pos.y = fx.pos.y + this.fx_offset_y
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)

                    store.player_gold = store.player_gold + this.gold_to_steal

                    table.insert(enemies_stole_gold, target.id)
                end
            end

            move(target.pos)
            coroutine.yield()
        end

        this.force_motion.max_a = this.force_motion.max_a / 1.5
        this.force_motion.max_v = this.force_motion.max_v / 1.5

        U.animation_start(this, "fly", nil, store.tick_ts, true)

        return true
    end

    U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
    U.animation_start(this, "fly", nil, store.tick_ts, true)

    local start_ts = store.tick_ts

    while true do
        if store.tick_ts - start_ts >= this.duration then
            break
        end

        if target and not store.entities[target.id] or target and target.health.dead then
            target = nil
        elseif target and not target.health.dead and not P:is_node_valid(target.nav_path.pi, target.nav_path.ni) then
            target = nil
        end

        local distance_from_owner = V.dist(this.owner.pos.x, this.owner.pos.y, this.pos.x, this.pos.y)

        if distance_from_owner > this.max_distance_from_owner then
            if target then
                local _, targets = U.find_foremost_enemy(store, tpos(this.owner), 0, attack.range, false,
                    attack.vis_flags, attack.vis_bans, function(v)
                        return not SU.has_modifiers(store, v, attack.mark_mod)
                    end)

                if targets and #targets > 0 then
                    target = targets[1]

                    local mark_mod = E:create_entity(this.mark_mod)

                    mark_mod.modifier.source_id = this.id
                    mark_mod.modifier.target_id = target.id
                    mark_mod.modifier.duration = this.mark_mod_duration

                    queue_insert(store, mark_mod)

                    this._mark_mod = mark_mod
                else
                    move_to_owner = true
                end
            else
                move_to_owner = true
            end
        end

        if target then
            local distance_from_target = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)

            if store.tick_ts - attack.ts > attack.cooldown and distance_from_target < this.min_distance_to_attack and
                not do_attack() then
                -- block empty
            end
        else
            local _, targets = U.find_foremost_enemy(store, tpos(this.owner), 0, attack.range, false,
                attack.vis_flags, attack.vis_bans, function(v)
                    return not SU.has_modifiers(store, v, attack.mark_mod)
                end)

            if targets and #targets > 0 then
                target = targets[1]

                local mark_mod = E:create_entity(this.mark_mod)

                mark_mod.modifier.source_id = this.id
                mark_mod.modifier.target_id = target.id
                mark_mod.modifier.duration = this.mark_mod_duration

                queue_insert(store, mark_mod)

                this._mark_mod = mark_mod
            end
        end

        if move_to_owner then
            local owner_pos = {}

            if store.tick_ts - last_time_change_pos >= this.idle_change_pos_cd then
                last_time_change_pos = store.tick_ts
                idle_change_pos.x = math.random(0, this.idle_change_pos_offset.x) - this.idle_change_pos_offset.x * 0.5
                idle_change_pos.y = math.random(0, this.idle_change_pos_offset.y) - this.idle_change_pos_offset.y * 0.5
            end

            owner_pos.x = this.owner.pos.x + this.owner_offset.x + idle_change_pos.x
            owner_pos.y = this.owner.pos.y + this.owner_offset.y + idle_change_pos.y

            move(owner_pos)

            local move_height = sf.offset.y < this.flight_height and 2 or -2

            sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)
        elseif target then
            local pos = V.vclone(target.pos)

            move(pos)
        else
            move_to_owner = true

            local owner_pos = {}

            if store.tick_ts - last_time_change_pos >= this.idle_change_pos_cd then
                last_time_change_pos = store.tick_ts
                idle_change_pos.x = math.random(0, this.idle_change_pos_offset.x) - this.idle_change_pos_offset.x * 0.5
                idle_change_pos.y = math.random(0, this.idle_change_pos_offset.y) - this.idle_change_pos_offset.y * 0.5
            end

            owner_pos.x = this.owner.pos.x + this.owner_offset.x + idle_change_pos.x
            owner_pos.y = this.owner.pos.y + this.owner_offset.y + idle_change_pos.y

            move(owner_pos)

            local move_height = sf.offset.y < this.flight_height and 2 or -2

            sf.offset.y = km.clamp(0, this.flight_height * 1.5, sf.offset.y + move_height)
        end

        coroutine.yield()
    end

    -- this.render.sprites[2].hidden = true

    U.y_animation_play(this, "leave", nil, store.tick_ts, 1)
    queue_remove(store, this)
end

function scripts.soldier_hero_hunter_beast.remove(this, store)
    if this._mark_mod then
        queue_remove(store, this._mark_mod)
    end

    return true
end

scripts.soldier_hero_hunter_beast_mark = {}

function scripts.soldier_hero_hunter_beast_mark.update(this, store)
    local m = this.modifier

    m.ts = store.tick_ts

    while true do
        local target = store.entities[m.target_id]

        if not target or m.duration >= 0 and store.tick_ts - m.ts > m.duration then
            queue_remove(store, this)

            return
        end

        coroutine.yield()
    end
end

scripts.hero_hunter_ultimate = {}

function scripts.hero_hunter_ultimate.update(this, store)
    local x, y = this.pos.x, this.pos.y
    local has_dante = false
    for _, s in pairs(store.soldiers) do
        if s.template_name == "hero_van_helsing" then
            has_dante = true
            break
        end
    end

    if has_dante then
        if store.entities[this.owner_id].health.dead then
            store.entities[this.owner_id].force_respawn = true
        end
        local mod = E:create_entity("mod_anya_ultimate_beacon")
        mod.modifier.source_id = this.id
        mod.modifier.target_id = this.owner_id
        queue_insert(store, mod)
    else
        local e = E:create_entity(this.entity)

        e.pos.x = x
        e.pos.y = y
        e.unit.damage_factor = this.damage_factor
        e.nav_rally.center = V.v(x, y)
        e.nav_rally.pos = V.vclone(e.pos)
        e.level = this.level

        queue_insert(store, e)

        local a = E:create_entity(this.aura)

        a.pos = e.pos
        a.level = this.level
        a.aura.source_id = e.id

        queue_insert(store, a)
        S:queue(this.sound)
        queue_remove(store, this)
    end
end

scripts.soldier_hero_hunter_ultimate = {}

function scripts.soldier_hero_hunter_ultimate.update(this, store, script)
    local brk, stam, star

    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts
    this.ranged.attacks[1].level = this.level
    this.hero_hunter_ref = nil

    for _, e in pairs(store.soldiers) do
        if e.template_name == "hero_hunter" then
            this.hero_hunter_ref = e

            break
        end
    end

    this.ranged.attacks[1].level = this.hero_hunter_ref.hero.skills.ultimate.level

    U.y_animation_play(this, "summon", nil, store.tick_ts, 1)

    while true do
        if this.hero_hunter_ref then
            local dist2 = V.dist2(this.pos.x, this.pos.y, this.hero_hunter_ref.pos.x, this.hero_hunter_ref.pos.y)

            if dist2 <= this.distance_to_revive * this.distance_to_revive and this.hero_hunter_ref.health.dead then
                this.hero_hunter_ref.force_respawn = true
            end
        end

        if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
            this.reinforcement.duration then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            if this.health.dead then
                this.reinforcement.fade = nil
                this.tween = nil
            else
                this.reinforcement.fade = true
            end

            this.health.hp = 0

            SU.remove_modifiers(store, this)

            this.ui.can_click = false

            SU.y_soldier_death(store, this)

            return
        end

        while this.nav_rally.new do
            if SU.y_hero_new_rally(store, this) then
                goto label_367_0
            end
        end

        if this.ranged then
            brk, star = SU.y_soldier_ranged_attacks(store, this)

            if brk or star == A_DONE then
                goto label_367_0
            elseif star == A_IN_COOLDOWN then
                -- block empty
            end
        end

        SU.soldier_idle(store, this)
        SU.soldier_regen(store, this)

        ::label_367_0::

        coroutine.yield()
    end
end

scripts.hero_space_elf = {}

function scripts.hero_space_elf.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    local bt = E:get_template(this.ranged.attacks[1].bullet)
    bt.bullet.damage_min = ls.ranged_damage_min[hl]
    bt.bullet.damage_max = ls.ranged_damage_max[hl]

    upgrade_skill(this, "astral_reflection", function(this, s)
        local a = this.timed_attacks.list[1]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.entity = string.format("%s_%i", a.entity_prefix, s.level)
    end)

    upgrade_skill(this, "black_aegis", function(this, s)
        local a = this.timed_attacks.list[2]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
        m.shield_base = s.shield_base[s.level]
        m.explosion_damage = s.explosion_damage[s.level]
    end)

    upgrade_skill(this, "void_rift", function(this, s)
        local a = this.timed_attacks.list[3]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local aura = E:get_template(a.aura)

        aura.aura.duration = s.duration[s.level]
        aura.aura.damage_max = s.damage_max[s.level]
        aura.aura.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "spatial_distortion", function(this, s)
        local a = this.timed_attacks.list[4]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local modifier = E:get_template(a.mod)

        modifier.modifier.duration = s.duration[s.level]
        modifier.range_factor = s.range_factor[s.level]
        modifier.damage_factor = s.damage_factor[s.level]
        modifier.cooldown_factor = s.cooldown_factor[s.level]
        modifier.tween.props[1].keys[2][1] = modifier.fade_duration
        modifier.tween.props[1].keys[3][1] = s.duration[s.level] - modifier.fade_duration
        modifier.tween.props[1].keys[4][1] = s.duration[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local u = this.hero.skills.ultimate
        local uc = E:get_template(u.controller_name)
        local aura = E:get_template(uc.entity)
        local modifier = E:get_template(aura.aura.mod)
        modifier.modifier.duration = s.duration[s.level]
        modifier.damage = s.damage[s.level]

        this.ultimate.disabled = nil
        this.ultimate.cooldown = s.cooldown[s.level]
    end)

    this.health.hp = this.health.hp_max
    this.hero.melee_active_status = {}

    for index, attack in ipairs(this.melee.attacks) do
        this.hero.melee_active_status[index] = attack.disabled
    end
end

function scripts.hero_space_elf.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.melee.order = U.attack_order(this.melee.attacks)
    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_space_elf.update(this, store)
    local h = this.health
    local brk, sta, a, skill
    local astral_reflection_attack = this.timed_attacks.list[1]
    local black_aegis_attack = this.timed_attacks.list[2]
    local void_rift_attack = this.timed_attacks.list[3]
    local spatial_distortion_attack = this.timed_attacks.list[4]
    local last_ts = store.tick_ts

    if not astral_reflection_attack.disabled then
        astral_reflection_attack.ts = store.tick_ts - astral_reflection_attack.cooldown
    end

    if not black_aegis_attack.disabled then
        black_aegis_attack.ts = store.tick_ts - black_aegis_attack.cooldown
    end

    if not void_rift_attack.disabled then
        void_rift_attack.ts = store.tick_ts - void_rift_attack.cooldown
    end

    if not spatial_distortion_attack.disabled then
        spatial_distortion_attack.ts = store.tick_ts - spatial_distortion_attack.cooldown
    end

    local function astral_reflection_spawn_pos(x, y)
        local nodes = P:nearest_nodes(x, y, nil, nil, true)

        if #nodes < 1 then
            log.debug("cannot insert summons, no valid nodes nearby %s,%s", x, y)

            return nil
        end

        local opi, ospi, ni = unpack(nodes[1])
        local spi = km.zmod(ospi + 1, 3)
        local npos = P:node_pos(opi, spi, ni - 1)

        if P:is_node_valid(opi, ni - 1) and
            band(GR:cell_type(npos.x, npos.y), bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0 then
            return npos
        end

        return nil
    end

    local function y_hero_space_elf_new_rally(store, this)
        local r = this.nav_rally

        if r.new then
            r.new = false

            U.unblock_target(store, this)

            if this.sound_events then
                S:queue(this.sound_events.change_rally_point)
            end

            if SU.hero_will_teleport(this, r.pos) then
                local tp = this.teleport
                local vis_bans = this.vis.bans
                tp.pending = true
                U.set_destination(this, r.pos)
                this.vis.bans = F_ALL
                this.health.ignore_damage = true
                this.health_bar.hidden = true

                S:queue(tp.sound_in)

                if tp.fx_out then
                    local fx = E:create_entity(tp.fx_out)

                    fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
                    fx.render.sprites[1].ts = store.tick_ts

                    if fx.tween then
                        fx.tween.ts = store.tick_ts
                    end

                    queue_insert(store, fx)
                end

                local an, af = U.animation_name_facing_point(this, tp.animations[1], r.pos)

                U.animation_start(this, an, af, store.tick_ts, 1, nil)
                SU.y_hero_animation_wait(this)

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

                S:queue(tp.sound_out)
                U.y_animation_play(this, tp.animations[2], nil, store.tick_ts)
                tp.pending = false
                this.health_bar.hidden = false
                this.vis.bans = vis_bans
                this.health.ignore_damage = false

                return false
            elseif SU.hero_will_transfer(this, r.pos) then
                local tr = this.transfer
                local interrupt = false
                local ps
                local vis_bans = this.vis.bans

                this.vis.bans = F_ALL
                this.health.ignore_damage = true
                this.health_bar.hidden = true

                S:queue(tr.sound_loop)

                local an, af = U.animation_name_facing_point(this, tr.animations[2], r.pos)

                U.animation_start(this, an, af, store.tick_ts, 1, nil)
                U.speed_inc_self(this, tr.extra_speed)
                if tr.particles_name then
                    ps = E:create_entity(tr.particles_name)
                    ps.particle_system.track_id = this.id

                    queue_insert(store, ps)
                end

                local first_time = true

                ::label_244_0::

                if not first_time then
                    local an, af = U.animation_name_facing_point(this, tr.animations[2], r.pos)

                    U.animation_start(this, an, af, store.tick_ts, true, 1, true)
                end

                local dest = r.pos
                local n = this.nav_grid

                while not V.veq(this.pos, dest) do
                    local w = table.remove(n.waypoints, 1) or dest

                    U.set_destination(this, w)

                    local runs = this.render.sprites[1].runs

                    while not this.motion.arrived do
                        if r.new then
                            if SU.hero_will_teleport(this, r.pos) then
                                return y_hero_space_elf_new_rally(store, this)
                            else
                                r.new = false
                                first_time = false

                                goto label_244_0
                            end
                        end

                        U.walk(this, store.tick_length)
                        coroutine.yield()

                        this.motion.speed.x, this.motion.speed.y = 0, 0

                        if this.render.sprites[1].runs ~= runs then
                            local an, af = U.animation_name_facing_point(this, tr.animations[2], this.motion.dest)

                            U.animation_start(this, an, af, store.tick_ts, true, 1, true)

                            runs = this.render.sprites[1].runs
                        end
                    end
                end

                if tr.particles_name then
                    ps.particle_system.emit = false
                    ps.particle_system.source_lifetime = 1
                end

                U.speed_dec_self(this, tr.extra_speed)

                S:stop(tr.sound_loop)
                U.y_animation_play(this, tr.animations[3], nil, store.tick_ts)

                this.health_bar.hidden = false
                this.vis.bans = vis_bans
                this.health.ignore_damage = false

                return interrupt
            end
        end
    end

    local function spatial_distortion_get_towers(a)
        local targets = table.filter(store.towers, function(k, v)
            return not v.pending_removal and not v.tower.blocked and not U.has_modifiers(store, v, a.mod) and
                       v.tower.can_be_mod
        end)

        if targets and #targets > 0 then
            return targets
        end

        return nil
    end
    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
    U.animation_start(this, "idle", nil, store.tick_ts, true)

    this.health_bar.hidden = false

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if y_hero_space_elf_new_rally(store, this) then
                    goto label_242_0
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, this.ranged.attacks[1].max_range, false,
                    false, bor(F_BOSS, F_FLYING))
                if target and valid_rally_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)

                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                    e.pos.x, e.pos.y = target.pos.x, target.pos.y
                    e.damage_factor = this.unit.damage_factor
                    e.level = this.hero.skills.ultimate.level
                    queue_insert(store, e)
                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            a = this.timed_attacks.list[1]
            skill = this.hero.skills.astral_reflection

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local targets =
                    U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a.vis_bans)

                if not targets or #targets == 0 then
                    SU.delay_attack(store, a, fts(10))
                else
                    local pos = astral_reflection_spawn_pos(this.pos.x, this.pos.y)

                    if not pos then
                        SU.delay_attack(store, a, fts(10))
                    else
                        local start_ts = store.tick_ts
                        local an, af = U.animation_name_facing_point(this, a.animation, pos)

                        U.animation_start(this, an, af, store.tick_ts, 1, nil)
                        S:queue(a.sound)

                        if SU.y_hero_wait(store, this, a.cast_time) then
                            goto label_242_0
                        end

                        local e = E:create_entity(a.entity)
                        e.unit.damage_factor = this.unit.damage_factor
                        e.pos = pos
                        e.nav_rally.center = V.vclone(e.pos)
                        e.nav_rally.pos = V.vclone(e.pos)
                        e.melee.attacks[1].xp_dest_id = this.id
                        e.render.sprites[1].flip_x = math.random() < 0.5

                        queue_insert(store, e)

                        e.owner = this

                        SU.y_hero_animation_wait(this)

                        a.ts = start_ts
                        last_ts = a.ts

                        SU.hero_gain_xp_from_skill(this, skill)
                    end
                end
            end

            a = this.timed_attacks.list[2]
            skill = this.hero.skills.black_aegis

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local targets = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags, a.vis_bans,
                    function(e)
                        return e.soldier.target_id
                    end)

                if not targets or #targets == 0 then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, a.animation, targets[1].pos)

                    U.animation_start(this, an, af, store.tick_ts, 1, nil)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        -- block empty
                    else
                        S:queue(a.sound)

                        a.ts = start_ts
                        last_ts = a.ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        targets =
                            U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags, a.vis_bans)

                        if targets and #targets > 0 then
                            table.sort(targets, function(a, b)
                                return a.soldier.target_id and not b.soldier.target_id
                            end)
                            for i = 1, 3 do
                                local target = targets[i]
                                if target then
                                    local m = E:create_entity(a.mod)
                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = target.id
                                    queue_insert(store, m)
                                end
                            end
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_242_0
                end
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.void_rift

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_trigger, a.vis_flags,
                    a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, a.animation, enemies[1].pos)

                    U.animation_start(this, an, af, store.tick_ts, 1, nil)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        goto label_242_0
                    end

                    S:queue(a.sound)

                    a.ts = start_ts
                    last_ts = a.ts

                    SU.hero_gain_xp_from_skill(this, skill)

                    local target, enemies = U.find_foremost_enemy(store, this.pos, 0, a.max_range_effect, false,
                        a.vis_flags, a.vis_bans)

                    if target and not target.health.dead then
                        local ni = target.nav_path.ni + P:predict_enemy_node_advance(target, a.predict)
                        local last_node_pos
                        local decal = E:create_entity(a.cast_decal)

                        decal.pos = this.pos
                        decal.render.sprites[1].ts = store.tick_ts
                        decal.tween.ts = store.tick_ts

                        queue_insert(store, decal)

                        local cracks_fade = 2
                        local distance_index = ni
                        local aura = E:create_entity(a.aura)

                        aura.aura.source_id = this.id
                        aura.aura.ts = store.tick_ts
                        aura.aura.damage_factor = this.unit.damage_factor
                        aura.ignore_damage = true

                        for _, s in ipairs(aura.render.sprites) do
                            s.scale = V.v(1, 1)

                            local scale = math.random(6, 8) * 0.1

                            s.scale.x, s.scale.y = scale, scale
                        end

                        aura.render.sprites[3].alpha = 150

                        local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

                        distance_index = distance_index - a.border_cracks_distance
                        aura.pos = V.vclone(pos)
                        last_node_pos = pos

                        queue_insert(store, aura)
                        U.y_wait(store, fts(cracks_fade))

                        local aura_2 = E:create_entity(a.aura)

                        aura_2.aura.source_id = this.id
                        aura_2.aura.ts = store.tick_ts
                        aura_2.ignore_damage = true
                        aura_2.aura.damage_factor = this.unit.damage_factor
                        for _, s in ipairs(aura_2.render.sprites) do
                            s.scale = V.v(1, 1)

                            local scale = math.random(4, 5) * 0.1

                            s.scale.x, s.scale.y = scale, scale
                        end

                        aura_2.render.sprites[3].alpha = 100

                        local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

                        distance_index = distance_index - a.border_cracks_distance
                        aura_2.pos = V.vclone(pos)
                        last_node_pos = pos

                        queue_insert(store, aura_2)
                        U.y_wait(store, fts(cracks_fade))

                        for i = 1, skill.cracks_amount[skill.level] do
                            local aura = E:create_entity(a.aura)

                            aura.aura.source_id = this.id
                            aura.aura.ts = store.tick_ts
                            aura.aura.damage_factor = this.unit.damage_factor
                            local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

                            distance_index = distance_index - a.cracks_distance

                            local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
                            local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

                            v1.x = v1.x / length1
                            v1.y = v1.y / length1

                            local v1perpendicular = V.v(v1.y, -v1.x)

                            pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
                            pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
                            aura.pos = pos
                            last_node_pos = pos

                            queue_insert(store, aura)
                            U.y_wait(store, fts(cracks_fade))
                        end

                        aura = E:create_entity(a.aura)
                        aura.aura.source_id = this.id
                        aura.aura.ts = store.tick_ts
                        aura.aura.damage_factor = this.unit.damage_factor
                        aura.ignore_damage = true

                        for _, s in ipairs(aura.render.sprites) do
                            s.scale = V.v(1, 1)

                            local scale = math.random(6, 8) * 0.1

                            s.scale.x, s.scale.y = scale, scale
                        end

                        aura.render.sprites[3].alpha = 150
                        distance_index = distance_index + a.cracks_distance - a.border_cracks_distance

                        local pos = P:node_pos(target.nav_path.pi, 1, distance_index)

                        distance_index = distance_index - a.border_cracks_distance

                        local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
                        local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

                        v1.x = v1.x / length1
                        v1.y = v1.y / length1

                        local v1perpendicular = V.v(v1.y, -v1.x)

                        pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
                        pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
                        aura.pos = pos
                        last_node_pos = pos

                        queue_insert(store, aura)
                        U.y_wait(store, fts(cracks_fade))

                        aura = E:create_entity(a.aura)
                        aura.aura.source_id = this.id
                        aura.aura.ts = store.tick_ts
                        aura.ignore_damage = true

                        for _, s in ipairs(aura.render.sprites) do
                            s.scale = V.v(1, 1)

                            local scale = math.random(4, 5) * 0.1

                            s.scale.x, s.scale.y = scale, scale
                        end

                        aura.render.sprites[3].alpha = 100

                        local pos = P:node_pos(target.nav_path.pi, 1, distance_index)
                        local length1 = V.dist(pos.x, pos.y, last_node_pos.x, last_node_pos.y)
                        local v1 = V.v(last_node_pos.x - pos.x, last_node_pos.y - pos.y)

                        v1.x = v1.x / length1
                        v1.y = v1.y / length1

                        local v1perpendicular = V.v(v1.y, -v1.x)

                        pos.x = pos.x + v1perpendicular.x * a.crack_offset * km.rand_sign()
                        pos.y = pos.y + v1perpendicular.y * a.crack_offset * km.rand_sign()
                        aura.pos = pos
                        last_node_pos = pos

                        queue_insert(store, aura)
                    end

                    SU.y_hero_animation_wait(this)
                end
            end

            a = this.timed_attacks.list[4]
            skill = this.hero.skills.spatial_distortion

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown and store.wave_group_number > 0 then
                local towers = spatial_distortion_get_towers(a)

                if not towers then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts

                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts, 1, nil)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        goto label_242_0
                    end

                    a.ts = start_ts
                    last_ts = a.ts

                    SU.hero_gain_xp_from_skill(this, skill)

                    local towers = spatial_distortion_get_towers(a)

                    if not towers then
                        -- block empty
                    else
                        for _, t in pairs(towers) do
                            local mod = E:create_entity(a.mod)

                            mod.modifier.level = skill.level
                            mod.modifier.target_id = t.id
                            mod.modifier.source_id = this.id

                            for k, v in pairs(mod.offset_y_per_tower) do
                                if string.find(t.template_name, k, 1, true) then
                                    mod.render.sprites[1].offset.y = v
                                end
                            end

                            queue_insert(store, mod)
                        end

                        SU.y_hero_animation_wait(this)
                    end
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            else
                brk, sta = SU.y_soldier_ranged_attacks(store, this)

                if brk then
                    -- block empty
                elseif SU.soldier_go_back_step(store, this) then
                    -- block empty
                else
                    SU.soldier_idle(store, this)
                    SU.soldier_regen(store, this)
                end
            end
        end

        ::label_242_0::

        coroutine.yield()
    end
end

scripts.soldier_hero_space_elf_astral_reflection = {}

function scripts.soldier_hero_space_elf_astral_reflection.update(this, store, script)
    local brk, stam, star, a

    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts

    if this.reinforcement.fade or this.reinforcement.fade_in then
        SU.y_reinforcement_fade_in(store, this)
    elseif this.render.sprites[1].name == "in" then
        if this.sound_events and this.sound_events.raise then
            S:queue(this.sound_events.raise)
        end

        this.health_bar.hidden = true

        U.y_animation_play(this, "in", nil, store.tick_ts, 1)

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
    end

    this.render.sprites[1].hidden = true

    local spawn_fx = E:create_entity(this.spawn_fx)

    spawn_fx.pos = V.vclone(this.pos)
    spawn_fx.render.sprites[1].ts = store.tick_ts

    queue_insert(store, spawn_fx)
    U.y_wait(store, fts(23))

    this.render.sprites[1].hidden = false

    while true do
        if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
            this.reinforcement.duration then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            this.health.hp = 0

            SU.y_soldier_death(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else

            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    goto label_249_1
                end
            end

            if this.ranged then
                brk, star = SU.y_soldier_ranged_attacks(store, this)

                if brk or star == A_DONE then
                    goto label_249_1
                elseif star == A_IN_COOLDOWN then
                    goto label_249_0
                end
            end

            if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                goto label_249_1
            end

            if SU.soldier_go_back_step(store, this) then
                goto label_249_1
            end

            ::label_249_0::

            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
        end

        ::label_249_1::

        coroutine.yield()
    end
end

scripts.mod_hero_space_elf_black_aegis = {}

function scripts.mod_hero_space_elf_black_aegis.insert(this, store)
    local m = this.modifier
    local target = store.entities[this.modifier.target_id]

    if not target or not target.health or target.health.dead then
        return false
    end

    m.ts = store.tick_ts
    if not target.health.on_damages then
        target.health.on_damages = {}
        if target.health.on_damage then
            target.health.on_damages[1] = target.health.on_damage
        end
    end
    target.health.on_damages[#target.health.on_damages + 1] = scripts.mod_hero_space_elf_black_aegis.on_damage
    this.on_damages_index = #target.health.on_damages
    SU.update_on_damage(target)

    this._hit_sources = {}
    this._blood_color = target.unit.blood_color
    target.unit.blood_color = BLOOD_NONE
    target._shield_mod_black_aegis = this
    this.health.hp = this.shield_base
    this.health.hp_max = this.shield_base

    return true
end

function scripts.mod_hero_space_elf_black_aegis.remove(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if target then
        target.health.on_damages[this.on_damages_index] = nil
        SU.update_on_damage(target)
        target._shield_mod_black_aegis = nil
        target.unit.blood_color = this._blood_color
    end

    return true
end

function scripts.mod_hero_space_elf_black_aegis.update(this, store)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    for i, s in ipairs(this.render.sprites) do
        if s.size_names then
            s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
        end

        if i == 2 then
            s.name = s.prefix
        end
    end

    U.y_animation_play(this, this.animation_start, nil, store.tick_ts, 1)

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node or this.shield_broken then
            this.render.sprites[2].hidden = true

            S:queue(this.sound_explosion)
            U.animation_start(this, this.animation_end, nil, store.tick_ts, false)
            U.y_wait(store, this.explosion_time)

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.explosion_range, 0,
                bor(F_FLYING, F_CLIFF))

            if targets then
                for _, target in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.value = this.explosion_damage * this.modifier.damage_factor
                    d.damage_type = this.explosion_damage_type
                    d.target_id = target.id
                    d.source_id = this.id

                    queue_damage(store, d)

                    local fx_pos = V.vclone(target.pos)

                    if target.unit and target.unit.mod_offset then
                        fx_pos.x = fx_pos.x + target.unit.mod_offset.x
                        fx_pos.y = fx_pos.y + target.unit.mod_offset.y
                    end

                    local fx = E:create_entity(m.damage_fx)

                    fx.pos = fx_pos
                    fx.render.sprites[1].ts = store.tick_ts

                    queue_insert(store, fx)
                end
            end

            U.y_animation_wait(this)
            queue_remove(store, this)

            return
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

        U.y_animation_play(this, this.animation_loop, nil, store.tick_ts, 1)
        coroutine.yield()
    end
end

function scripts.mod_hero_space_elf_black_aegis.on_damage(this, store, damage)
    local mod = this._shield_mod_black_aegis

    if not mod then
        log.error("mod_hero_space_elf_black_aegis.on_damage for enemy %s has no mod pointer", this.id)

        return true
    end

    if mod.shield_broken then
        return true
    end

    if U.flag_has(damage.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_IGNORE_SHIELD)) then
        mod.shield_broken = true

        queue_remove(store, mod)

        return true
    else
        mod.damage_taken = mod.damage_taken + damage.value
    end

    mod.health.hp = mod.shield_base - mod.damage_taken

    if mod.damage_taken >= mod.shield_base then
        mod.shield_broken = true

        if mod.damage_taken - mod.shield_base > 0 then
            damage.value = mod.damage_taken - mod.shield_base

            return true
        end
    end

    return false
end

scripts.aura_hero_space_elf_void_rift = {}

function scripts.aura_hero_space_elf_void_rift.update(this, store, script)
    this.aura.ts = store.tick_ts

    local last_hit_ts = 0
    local cycles_count = 0

    U.y_animation_play(this, "in", nil, store.tick_ts, 1)

    while true do
        if this.aura.cycles then
            if cycles_count >= this.aura.cycles then
                break
            end
        elseif this.aura.duration >= 0 and store.tick_ts - this.aura.ts >= this.aura.duration then
            break
        end

        if this.aura.track_source and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if not te or te.health and te.health.dead then
                queue_remove(store, this)

                return
            end

            if te and te.pos then
                this.pos.x, this.pos.y = te.pos.x, te.pos.y
            end
        end

        if this.ignore_damage then
            -- block empty
        elseif store.tick_ts - last_hit_ts >= this.aura.cycle_time then
            cycles_count = cycles_count + 1
            last_hit_ts = store.tick_ts

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                           band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius)
            end)

            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id

                local dmin, dmax = this.aura.damage_min, this.aura.damage_max

                if this.aura.damage_inc then
                    dmin = dmin + this.aura.damage_inc * this.aura.level
                    dmax = dmax + this.aura.damage_inc * this.aura.level
                end

                d.value = math.random(dmin, dmax) * this.aura.damage_factor
                d.damage_type = this.aura.damage_type
                d.track_damage = this.aura.track_damage
                d.xp_dest_id = this.aura.xp_dest_id
                d.xp_gain_factor = this.aura.xp_gain_factor

                queue_damage(store, d)

                local mods = this.aura.mods or {this.aura.mod}

                for _, mod_name in pairs(mods) do
                    local m = E:create_entity(mod_name)

                    m.modifier.level = this.aura.level
                    m.modifier.target_id = target.id
                    m.modifier.source_id = this.id
                    m.modifier.damage_factor = this.aura.damage_factor
                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        m.render = nil
                    end

                    queue_insert(store, m)
                end
            end
        end

        U.animation_start(this, "idle", nil, store.tick_ts, true)
        coroutine.yield()
    end

    U.y_animation_play(this, "out", nil, store.tick_ts, 1)
    queue_remove(store, this)
end

scripts.hero_space_elf_ultimate = {}

function scripts.hero_space_elf_ultimate.update(this, store)
    local function spawn_aura(pi, spi, ni)
        local pos = P:node_pos(pi, spi, ni)
        local a = E:create_entity(this.entity)

        a.pos = pos

        queue_insert(store, a)

        local d = E:create_entity(this.decal)

        d.pos = pos
        d.render.sprites[1].ts = store.tick_ts

        queue_insert(store, d)
    end

    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

    if #nearest > 0 then
        local pi, spi, ni = unpack(nearest[1])

        if P:is_node_valid(pi, ni) then
            spawn_aura(pi, 1, ni)
        end
    end

    queue_remove(store, this)
end

scripts.mod_hero_space_elf_ultimate = {}

function scripts.mod_hero_space_elf_ultimate.queue(this, store, insertion)
    local target = store.entities[this.modifier.target_id]

    if not target then
        return
    end

    if insertion then
        log.debug("%s (%s) queue/insertion", this.template_name, this.id)

        if U.flags_pass(target.vis, this.modifier) then
            this._target_prev_bans = target.vis.bans
            -- target.vis.bans = F_ALL
            -- target.health.ignore_damage = true
        end
    else
        log.debug("%s (%s) queue/removal", this.template_name, this.id)

        if this._target_prev_bans then
            target.vis.bans = this._target_prev_bans
            target.health.ignore_damage = false
        end

        if this._decal_timelapse then
            queue_remove(store, this._decal_timelapse)

            if target.ui then
                target.ui.can_click = true
            end

            if target.health_bar then
                target.health_bar.hidden = nil
            end

            U.sprites_show(target, nil, nil, true)
            SU.show_modifiers(store, target, true, this)
            SU.show_auras(store, target, true)
        end
    end
end

function scripts.mod_hero_space_elf_ultimate.dequeue(this, store, insertion)
    local target = store.entities[this.modifier.target_id]

    if not target then
        return
    end

    if insertion then
        log.debug("%s (%s) dequeue/insertion", this.template_name, this.id)

        if this._target_prev_bans then
            target.vis.bans = this._target_prev_bans
            target.health.ignore_damage = false
        end
    end
end

function scripts.mod_hero_space_elf_ultimate.insert(this, store)
    local target = store.entities[this.modifier.target_id]

    if target and target.health and not target.health.dead and this._target_prev_bans ~= nil then
        SU.stun_inc(target)

        return true
    else
        return false
    end
end

function scripts.mod_hero_space_elf_ultimate.remove(this, store)
    local target = store.entities[this.modifier.target_id]

    if target then
        SU.stun_dec(target)
    end

    return true
end

function scripts.mod_hero_space_elf_ultimate.update(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if not target or not target.health or target.health.dead then
        queue_remove(store, this)

        return
    end

    m.ts = store.tick_ts
    this.pos.x, this.pos.y = target.pos.x, target.pos.y
    this.render.sprites[1].offset.y = target.unit.hit_offset.y

    local s = this.render.sprites[1]

    if s.size_names then
        s.prefix = s.prefix .. "_" .. s.size_names[target.unit.size]
    end

    s.hidden = true

    local es = E:create_entity(this.decal)

    if not target.render.sprites[1].exo then
        this._decal_timelapse = es
        es.pos.x, es.pos.y = target.pos.x, target.pos.y
        es.render = table.deepclone(target.render)

        local tween_keys = es.tween.props[1].keys

        for i, s in ipairs(es.render.sprites) do
            es.tween.props[i] = E:clone_c("tween_prop")
            es.tween.props[i].keys = tween_keys
            es.tween.props[i].sprite_id = i
        end

        queue_insert(store, es)
        U.y_wait(store, fts(1))
    end

    U.unblock_all(store, target)

    if target.health_bar then
        target.health_bar.hidden = true
    end

    U.sprites_hide(target, nil, nil, true)
    SU.hide_modifiers(store, target, true, this)
    SU.hide_auras(store, target, true)

    this.tween.ts = store.tick_ts

    local tween_levitate = this.tween.props[2]

    es.tween.ts = store.tick_ts
    es.tween.disabled = false

    U.y_wait(store, fts(math.random(1, 8)))

    s.hidden = false

    U.animation_start(this, "in", nil, store.tick_ts, false, 1)
    U.y_animation_wait(this)

    tween_levitate.keys[1][2].y = this.render.sprites[1].offset.y
    tween_levitate.keys[2][2].y = this.render.sprites[1].offset.y + tween_levitate.keys[2][2].y
    tween_levitate.keys[3][2].y = this.render.sprites[1].offset.y
    tween_levitate.keys[2][1] = fts(math.random(30, 40))
    tween_levitate.keys[3][1] = tween_levitate.keys[2][1] * 2
    tween_levitate.ts = store.tick_ts
    tween_levitate.disabled = false

    U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
    U.y_wait(store, m.duration - (store.tick_ts - m.ts) - fts(10), function(store, time)
        return this.interrupt or target.health.dead
    end)

    tween_levitate.disabled = true

    U.animation_start(this, "out", nil, store.tick_ts, false, 1)

    this.tween.ts = store.tick_ts
    this.tween.reverse = true

    U.y_wait(store, fts(23))

    es.tween.reverse = true
    es.tween.ts = store.tick_ts

    S:queue(this.out_sfx)
    U.y_animation_wait(this)

    if not target.health.dead then
        if target.health_bar then
            target.health_bar.hidden = nil
        end
        U.sprites_show(target, nil, nil, true)
        SU.show_modifiers(store, target, true, this)
        SU.show_auras(store, target, true)
    end

    queue_remove(store, es)

    this._decal_timelapse = nil

    queue_remove(store, this)

    if this.interrupt then
        target.health.hp = 0

        if target.death_spawns then
            target.health.last_damage_types = DAMAGE_NO_SPAWNS
        end
    else
        local d = E:create_entity("damage")

        d.damage_type = this.damage_type
        d.value = this.damage
        d.source_id = this.id
        d.target_id = target.id

        queue_damage(store, d)
    end

    signal.emit("mod-applied", this, target)
end

scripts.hero_raelyn = {}

function scripts.hero_raelyn.level_up(this, store)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "unbreakable", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local m = E:get_template(a.mod)

        m.modifier.duration = s.duration[s.level]
        m.shield_per_enemy = s.shield_per_enemy[s.level]
        m.shield_base = s.shield_base[s.level]

    end)

    upgrade_skill(this, "inspire_fear", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local md = E:get_template(a.mods[1])

        md.modifier.duration = s.damage_duration[s.level]
        md.inflicted_damage_factor = s.inflicted_damage_factor[s.level]

        local ms = E:get_template(a.mods[2])

        ms.modifier.duration = s.stun_duration[s.level]

        local mf = E:get_template(a.mods[3])

        mf.modifier.duration = s.stun_duration[s.level]
    end)

    upgrade_skill(this, "brutal_slash", function(this, s)
        local a = this.melee.attacks[2]
        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.damage_max = s.damage_max[s.level]
        a.damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "onslaught", function(this, s)
        local a = this.melee.attacks[1]
        local o = this.timed_attacks.list[3]
        local hit_aura = E:get_template(s.hit_aura)

        hit_aura.aura.damage_max = a.damage_max * s.damage_factor[s.level]
        hit_aura.aura.damage_min = a.damage_min * s.damage_factor[s.level]
        o.hit_aura = hit_aura
        o.melee_cooldown = s.melee_cooldown[s.level]
        o.duration = s.duration[s.level]
        o.cooldown = s.cooldown[s.level]
        o.disabled = nil

    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local uc = E:get_template(s.controller_name)
        uc.entity = string.format("%s_%i", uc.entity_prefix, s.level)
        this.ultimate.cooldown = s.cooldown[s.level]
        this.ultimate.disabled = nil
    end)

    this.health.hp = this.health.hp_max
    this.hero.melee_active_status = {}

    for index, attack in ipairs(this.melee.attacks) do
        this.hero.melee_active_status[index] = attack.disabled
    end
end

function scripts.hero_raelyn.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.melee.order = U.attack_order(this.melee.attacks)

    return true
end

function scripts.hero_raelyn.update(this, store)
    local h = this.health
    local a, skill, brk, sta
    local ultimate = this.hero.skills.ultimate
    local basic_attack = this.melee.attacks[1]
    local unbreakable_attack = this.timed_attacks.list[1]
    local inspire_fear_attack = this.timed_attacks.list[2]
    local onslaught_attack = this.timed_attacks.list[3]
    local onslaught_on = false

    this.health_bar.hidden = false
    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)

    while true do
        -- while this.spawning_in_cinematic_s2 do
        --     coroutine.yield()
        -- end

        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_222_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, 140, false, true, F_FLYING)
                if target and valid_rally_node_nearby(target.pos) then
                    U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                    e.pos.x, e.pos.y = target.pos.x, target.pos.y
                    e.damage_factor = this.unit.damage_factor
                    e.level = this.hero.skills.ultimate.level
                    queue_insert(store, e)
                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            skill = this.hero.skills.inspire_fear
            a = inspire_fear_attack

            if ready_to_use_skill(a, store) then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_trigger, a.vis_flags,
                    a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts

                    S:queue(a.sound)

                    if a.mod_decal then
                        local d = E:create_entity(a.mod_decal)

                        d.modifier.source_id = this.id
                        d.modifier.target_id = this.id

                        queue_insert(store, d)
                    end

                    U.animation_start(this, a.animation, nil, store.tick_ts, 1)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        -- block empty
                    else
                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_effect, a.vis_flags,
                            a.vis_bans)

                        if enemies then
                            for _, t in ipairs(enemies) do
                                for _, mod in ipairs(a.mods) do
                                    local m = E:create_entity(mod)

                                    m.modifier.source_id = this.id
                                    m.modifier.target_id = t.id

                                    queue_insert(store, m)
                                end
                            end
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_222_0
                end
            end

            skill = this.hero.skills.unbreakable
            a = unbreakable_attack

            if ready_to_use_skill(a, store) and not U.has_modifiers(store, this, a.mod) then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_trigger, a.vis_flags,
                    a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts

                    S:queue(a.sound)
                    U.animation_start(this, a.animation, nil, store.tick_ts, 1)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        -- block empty
                    else
                        local d = E:create_entity(a.mod_decal)

                        d.modifier.source_id = this.id
                        d.modifier.target_id = this.id

                        queue_insert(store, d)

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)
                        enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_effect, a.vis_flags,
                            a.vis_bans)
                        local count
                        if enemies then
                            count = #enemies > a.max_targets and a.max_targets or #enemies
                        else
                            count = 0
                        end

                        local function apply_unbreakable(target, is_soldier)
                            local m = E:create_entity(a.mod)
                            local shield_max_damage = m.shield_base * target.health.hp_max

                            shield_max_damage = shield_max_damage + target.health.hp_max * m.shield_per_enemy * count
                            if is_soldier then
                                shield_max_damage = shield_max_damage * 0.6
                                m.render.sprites[1].scale.x = 0.5
                                m.render.sprites[1].scale.y = 0.5
                                m.health_bar.offset.y = m.health_bar.offset.y * 0.71
                            end
                            m.modifier.source_id = this.id
                            m.modifier.target_id = target.id
                            m.shield_max_damage = shield_max_damage

                            local mod_prefix

                            if count <= #m.sprites_per_enemies then
                                mod_prefix = m.sprites_per_enemies[count]
                            else
                                mod_prefix = m.sprites_per_enemies[#m.sprites_per_enemies]
                            end

                            m.render.sprites[1].prefix = mod_prefix
                            queue_insert(store, m)
                        end
                        apply_unbreakable(this, false)

                        local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.max_range_effect,
                            a.vis_flags, a.vis_bans)

                        if soldiers then
                            for index, soldier in ipairs(soldiers) do
                                if soldier.id ~= this.id and not U.has_modifiers(store, soldier, a.mod) then
                                    if index >= a.max_targets then
                                        break
                                    end
                                    if soldier.hero then
                                        apply_unbreakable(soldier, false)
                                    else
                                        apply_unbreakable(soldier, true)
                                    end
                                end
                            end
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_222_0
                end
            end

            skill = this.hero.skills.onslaught
            a = onslaught_attack

            if ready_to_use_skill(a, store) and not onslaught_on then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range_trigger, a.vis_flags,
                    a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    onslaught_on = true
                    a.duration_ts = store.tick_ts
                    a._sound = basic_attack.sound
                    a._cooldown = basic_attack.cooldown
                    a._hit_fx = basic_attack.hit_fx
                    a._hit_offset = basic_attack.hit_offset
                    basic_attack.hit_aura = a.hit_aura
                    basic_attack.cooldown = a.melee_cooldown
                    basic_attack.hit_decal = a.hit_decal
                    basic_attack.hit_fx = nil
                    basic_attack.hit_offset = a.hit_offset
                    basic_attack.sound = a.sound
                    U.speed_inc(this, this.motion.max_speed * 0.4)
                    this.melee.attacks[2].hit_aura = a.hit_aura
                end
            end

            if onslaught_on and store.tick_ts - a.duration_ts > a.duration then
                onslaught_on = false
                this.melee.attacks[2].hit_aura = nil
                basic_attack.hit_aura = nil
                basic_attack.cooldown = a._cooldown
                basic_attack.hit_decal = nil
                basic_attack.hit_fx = a._hit_fx
                basic_attack.hit_offset = a._hit_offset
                basic_attack.sound = a._sound
                a.ts = store.tick_ts
                U.speed_dec(this, this.motion.max_speed * 0.4)
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_222_0::

        coroutine.yield()
    end
end

scripts.hero_raelyn_unbreakable_mod = {}

function scripts.hero_raelyn_unbreakable_mod.insert(this, store)
    local m = this.modifier
    local target = store.entities[this.modifier.target_id]

    if not target or not target.health or target.health.dead then
        return false
    end

    m.ts = store.tick_ts
    if not target.health.on_damages then
        target.health.on_damages = {}
        if target.health.on_damage then
            target.health.on_damages[1] = target.health.on_damage
        end
    end
    target.health.on_damages[#target.health.on_damages + 1] = scripts.hero_raelyn_unbreakable_mod.on_damage
    this.on_damages_index = #target.health.on_damages

    SU.update_on_damage(target)

    this._hit_sources = {}
    this._blood_color = target.unit.blood_color
    target.unit.blood_color = BLOOD_NONE
    target._shield_mod_unbreakable = this
    this.health.hp = this.shield_max_damage
    this.health.hp_max = this.shield_max_damage

    return true
end

function scripts.hero_raelyn_unbreakable_mod.remove(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if target then
        target.health.on_damages[this.on_damages_index] = nil
        SU.update_on_damage(target)
        target._shield_mod_unbreakable = nil
        target.unit.blood_color = this._blood_color
    end

    return true
end

function scripts.hero_raelyn_unbreakable_mod.update(this, store)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    U.y_animation_play(this, this.animation_start, nil, store.tick_ts, 1)

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node then
            U.y_animation_play(this, this.animation_end, nil, store.tick_ts, 1)
            queue_remove(store, this)

            return
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

        U.y_animation_play(this, this.animation_loop, nil, store.tick_ts, 1)
        coroutine.yield()
    end
end

function scripts.hero_raelyn_unbreakable_mod.on_damage(this, store, damage)
    local mod = this._shield_mod_unbreakable

    if not mod then
        log.error("hero_raelyn_unbreakable_mod.on_damage for enemy %s has no mod pointer", this.id)

        return true
    end

    if mod.shield_broken then
        return true
    end

    if U.flag_has(damage.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_IGNORE_SHIELD)) then
        mod.shield_broken = true

        queue_remove(store, mod)

        return true
    else
        mod.damage_taken = mod.damage_taken + damage.value
    end

    mod.health.hp = mod.shield_max_damage - mod.damage_taken

    if mod.damage_taken >= mod.shield_max_damage then
        mod.shield_broken = true

        queue_remove(store, mod)

        if mod.damage_taken - mod.shield_max_damage > 0 then
            damage.value = mod.damage_taken - mod.shield_max_damage

            return true
        end
    end

    return false
end

scripts.hero_raelyn_ultimate = {}

function scripts.hero_raelyn_ultimate.update(this, store)
    local x, y = this.pos.x, this.pos.y
    local e = E:create_entity(this.entity)

    e.pos.x = x
    e.pos.y = y
    e.nav_rally.center = V.v(x, y)
    e.nav_rally.pos = V.vclone(e.pos)

    queue_insert(store, e)

    local d = E:create_entity(e.spawn_mod_decal)

    d.modifier.source_id = e.id
    d.modifier.target_id = e.id

    queue_insert(store, d)
    queue_remove(store, this)
end

scripts.hero_raelyn_command_orders_dark_knight = {}

function scripts.hero_raelyn_command_orders_dark_knight.update(this, store, script)
    local brk, stam, star

    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts

    if this.reinforcement.fade or this.reinforcement.fade_in then
        SU.y_reinforcement_fade_in(store, this)
    elseif this.render.sprites[1].name == "raise" then
        if this.sound_events and this.sound_events.raise then
            S:queue(this.sound_events.raise)
        end

        this.health_bar.hidden = true

        U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
    end

    while true do
        if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
            this.reinforcement.duration then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            if this.health.dead then
                this.reinforcement.fade = nil
                this.tween = nil
            else
                this.reinforcement.fade = true
            end

            this.health.hp = 0

            SU.remove_modifiers(store, this)

            this.ui.can_click = false

            SU.y_soldier_death(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else

            while this.nav_rally.new do
                if SU.y_hero_new_rally(store, this) then
                    goto label_229_1
                end
            end

            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    goto label_229_1
                end
            end

            if this.ranged then
                brk, star = SU.y_soldier_ranged_attacks(store, this)

                if brk or star == A_DONE then
                    goto label_229_1
                elseif star == A_IN_COOLDOWN then
                    goto label_229_0
                end
            end

            if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                goto label_229_1
            end

            if SU.soldier_go_back_step(store, this) then
                goto label_229_1
            end

            ::label_229_0::

            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
        end

        ::label_229_1::

        coroutine.yield()
    end
end

scripts.hero_venom = {}

function scripts.hero_venom.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]
    this.melee.attacks[2].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[2].damage_max = ls.melee_damage_max[hl]

    upgrade_skill(this, "ranged_tentacle", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local b = E:get_template(a.bullet)

        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]

        local m = E:get_template(b.bullet.mods[1])

        m.dps.damage_min = s.bleed_damage_min[s.level]
        m.dps.damage_max = s.bleed_damage_max[s.level]
        m.dps.damage_every = s.bleed_every[s.level]
        m.modifier.duration = s.bleed_duration[s.level]
    end)

    upgrade_skill(this, "inner_beast", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        local damage_min = ls.melee_damage_min[hl] * s.damage_factor[s.level]
        local damage_max = ls.melee_damage_max[hl] * s.damage_factor[s.level]

        this.melee.attacks[3].damage_min = damage_min
        this.melee.attacks[3].damage_max = damage_max
        this.melee.attacks[4].damage_min = damage_min
        this.melee.attacks[4].damage_max = damage_max
        this.melee.attacks[5].damage_min = damage_min
        this.melee.attacks[5].damage_max = damage_max
    end)

    upgrade_skill(this, "floor_spikes", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.spikes = s.spikes[s.level]

        local sp = E:get_template(a.spike_template[1])

        sp.damage_min = s.damage_min[s.level]
        sp.damage_max = s.damage_max[s.level]

        local sp = E:get_template(a.spike_template[2])

        sp.damage_min = s.damage_min[s.level]
        sp.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "eat_enemy", function(this, s)
        local a = this.timed_attacks.list[4]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.regen = s.regen[s.level] * this.health.hp_max
        a.damage = s.damage[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local uc = E:get_template(s.controller_name)
        this.ultimate.cooldown = s.cooldown[s.level]
        this.ultimate.disabled = nil
        local aura = E:get_template(uc.aura)
        aura.end_damage_min = s.damage_min[s.level]
        aura.end_damage_max = s.damage_max[s.level]
        aura.aura.duration = s.duration[s.level]
    end)

    this.health.hp = this.health.hp_max
    -- this.hero.melee_active_status = {}

    -- for index, attack in ipairs(this.melee.attacks) do
    --     this.hero.melee_active_status[index] = attack.disabled
    -- end
end

function scripts.hero_venom.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.melee.order = U.attack_order(this.melee.attacks)

    return true
end

function scripts.hero_venom.update(this, store)
    local h = this.health
    local a, skill, brk, sta
    local ranged_tentacle_attack = this.timed_attacks.list[1]
    local inner_beast_attack = this.timed_attacks.list[2]
    local floor_spikes_attack = this.timed_attacks.list[3]
    local eat_enemy_attack = this.timed_attacks.list[4]
    local last_ts = store.tick_ts
    local last_target
    local last_target_ts = store.tick_ts
    local base_speed = this.motion.max_speed

    this.is_transformed = false

    if not ranged_tentacle_attack.disabled then
        ranged_tentacle_attack.ts = store.tick_ts - ranged_tentacle_attack.cooldown
    end

    if not inner_beast_attack.disabled then
        inner_beast_attack.ts = store.tick_ts - inner_beast_attack.cooldown
    end

    if not floor_spikes_attack.disabled then
        floor_spikes_attack.ts = store.tick_ts - floor_spikes_attack.cooldown
    end

    if not eat_enemy_attack.disabled then
        eat_enemy_attack.ts = store.tick_ts - eat_enemy_attack.cooldown
    end

    local function play_level_up_animation()
        if this.is_transformed then
            local fx = E:create_entity(this.beast.lvl_up_fx)

            fx.pos = V.vclone(this.pos)

            for i = 1, #fx.render.sprites do
                fx.render.sprites[i].ts = store.tick_ts
            end

            queue_insert(store, fx)
        else
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end
    end

    local function y_transform_in()
        local a = inner_beast_attack
        local start_ts = store.tick_ts
        this.health.immune_to = F_ALL
        S:queue(a.sound_in, {
            delay = fts(10)
        })
        U.y_animation_play(this, a.animation_in, nil, store.tick_ts)

        a.ts = start_ts
        last_ts = start_ts

        SU.hero_gain_xp_from_skill(this, skill)

        this.melee.attacks[1].disabled = true
        this.melee.attacks[2].disabled = true
        this.melee.attacks[3].disabled = false
        this.melee.attacks[4].disabled = false
        this.melee.attacks[5].disabled = false
        eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal * 1.5
        eat_enemy_attack.disabled = true
        this._bar_offset = V.vclone(this.health_bar.offset)
        this._bar_type = this.health_bar.type
        this._click_rect = table.deepclone(this.ui.click_rect)
        this._hit_mod_offset = V.vclone(this.unit.hit_offset)
        this.health_bar.offset = V.vclone(this.beast.health_bar_offset)
        this.health_bar.type = this.beast.health_bar_type
        this.ui.click_rect = table.deepclone(this.beast.click_rect)
        this.unit.hit_offset = V.vclone(this.beast.hit_mod_offset)
        this.unit.mod_offset = V.vclone(this.beast.hit_mod_offset)
        this.render.sprites[1].prefix = "hero_venom_hero_beast"
        this.unit.size = UNIT_SIZE_MEDIUM
        this.is_transformed = true
        this.health.immune_to = 0
    end

    local function y_transform_out()
        this.health.immune_to = F_ALL
        local a = inner_beast_attack

        S:queue(a.sound_out, {
            delay = fts(10)
        })
        U.y_animation_play(this, a.animation_out, nil, store.tick_ts)

        this.melee.attacks[1].disabled = false
        this.melee.attacks[2].disabled = false
        this.melee.attacks[3].disabled = true
        this.melee.attacks[4].disabled = true
        this.melee.attacks[5].disabled = true
        -- this.melee.attacks[6].disabled = false
        eat_enemy_attack.disabled = false
        this.health_bar.offset = V.vclone(this._bar_offset)
        this.health_bar.type = this._bar_type
        this.ui.click_rect = table.deepclone(this._click_rect)
        this.unit.hit_offset = V.vclone(this._hit_mod_offset)
        this.unit.mod_offset = V.vclone(this._hit_mod_offset)
        this.render.sprites[1].prefix = "hero_venom_hero"
        this.unit.size = UNIT_SIZE_SMALL
        this.is_transformed = false
        this.health.immune_to = 0
    end

    this.health_bar.hidden = false
    play_level_up_animation()
    while true do
        if h.dead then
            if this.is_transformed then
                y_transform_out()
            end

            local d = E:create_entity(this.death_decal)

            d.pos.x, d.pos.y = this.pos.x, this.pos.y
            d.hero_venom = this

            queue_insert(store, d)
            SU.y_hero_death_and_respawn(store, this)
            U.update_max_speed(this, base_speed)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                local r = this.nav_rally
                local tw = this.slimewalk
                local force_slimewalk = false

                for _, p in pairs(this.nav_grid.waypoints) do
                    if GR:cell_is(p.x, p.y, bor(TERRAIN_WATER, TERRAIN_SHALLOW, TERRAIN_NOWALK)) then
                        force_slimewalk = true

                        break
                    end
                end

                if not this.is_transformed and
                    (force_slimewalk or V.dist2(this.pos.x, this.pos.y, r.pos.x, r.pos.y) > tw.min_distance *
                        tw.min_distance) then
                    r.new = false

                    U.unblock_target(store, this)

                    local vis_bans = this.vis.bans

                    this.vis.bans = F_ALL
                    this.health.immune_to = F_ALL

                    U.speed_inc_self(this, tw.extra_speed)

                    this.unit.marker_hidden = true
                    this.health_bar.hidden = true

                    S:queue(this.sound_events.change_rally_point)
                    S:queue(this.slimewalk.sound)

                    local an, af = U.animation_name_facing_point(this, tw.animations[1], this.motion.dest)

                    U.y_animation_play(this, an, not af, store.tick_ts)

                    ::label_294_0::

                    local dest = r.pos
                    local n = this.nav_grid

                    while not V.veq(this.pos, dest) do
                        local w = table.remove(n.waypoints, 1) or dest

                        U.set_destination(this, w)

                        local an, af = U.animation_name_facing_point(this, tw.animations[2], this.motion.dest)

                        U.animation_start(this, an, af, store.tick_ts, true, 1, true)

                        local runs = this.render.sprites[1].runs - 1

                        while not this.motion.arrived do
                            if r.new then
                                r.new = false

                                goto label_294_0
                            end

                            U.walk(this, store.tick_length)
                            coroutine.yield()

                            this.motion.speed.x, this.motion.speed.y = 0, 0

                            if this.render.sprites[1].runs ~= runs then
                                local slimewalk_decal = E:create_entity(this.slimewalk.decal)

                                slimewalk_decal.ts = store.tick_ts
                                slimewalk_decal.pos = V.vclone(this.pos)

                                U.animation_start(slimewalk_decal, "idle", false, store.tick_ts)
                                queue_insert(store, slimewalk_decal)

                                runs = this.render.sprites[1].runs
                            end
                        end
                    end

                    S:stop(this.slimewalk.sound)
                    SU.hide_modifiers(store, this, true)
                    U.y_animation_play(this, tw.animations[3], nil, store.tick_ts)
                    SU.show_modifiers(store, this, true)
                    U.speed_dec_self(this, tw.extra_speed)
                    this.vis.bans = vis_bans
                    this.health.immune_to = 0
                    this.unit.marker_hidden = nil
                    this.health_bar.hidden = nil
                elseif SU.y_hero_new_rally(store, this) then
                    goto label_294_2
                end
            end

            if SU.hero_level_up(store, this) then
                play_level_up_animation()
            end

            skill = this.hero.skills.eat_enemy
            a = eat_enemy_attack

            if (not ready_to_use_skill(eat_enemy_attack, store) or this.soldier.target_id == nil) or
                not this.motion.arrived then
                -- block empty
            else
                local target = store.entities[this.soldier.target_id]
                if not target or target.health.dead or band(target.vis.flags, F_BOSS) ~= 0 or
                    band(target.vis.bans, F_INSTAKILL) ~= 0 then
                    -- block empty
                else
                    local function do_eat_enemy_attack()
                        local start_ts = store.tick_ts
                        local an, af = U.animation_name_facing_point(this, a.animation, target.pos)
                        U.animation_start(this, an, af, store.tick_ts, 1)
                        S:queue(eat_enemy_attack.sound, eat_enemy_attack.sound_args)

                        while store.tick_ts - start_ts < eat_enemy_attack.hit_time do
                            coroutine.yield()
                        end

                        S:queue(eat_enemy_attack.sound_hit, eat_enemy_attack.sound_hit_args)
                        eat_enemy_attack.ts = start_ts - eat_enemy_attack.cooldown
                        local center = target.pos

                        local eat_targets = table.filter(store.enemies, function(k, v)
                            return not v.health.dead and band(v.vis.flags, F_BOSS) == 0 and
                                       band(v.vis.bans, F_INSTAKILL) == 0 and
                                       U.is_inside_ellipse(v.pos, center, eat_enemy_attack.radius)
                        end)

                        if eat_targets then
                            for _, eat_target in pairs(eat_targets) do
                                local d = E:create_entity("damage")
                                d.source_id = this.id
                                d.target_id = eat_target.id
                                if eat_target.health.hp <= eat_target.health.hp_max * eat_enemy_attack.hp_trigger then
                                    d.damage_type = DAMAGE_EAT
                                    d.value = 1
                                    eat_enemy_attack.ts = eat_enemy_attack.ts + (target.health.hp - 100) /
                                                              target.health.hp_max * eat_enemy_attack.cooldown
                                    scripts.heal(this, eat_enemy_attack.regen)
                                else
                                    d.damage_type = DAMAGE_RUDE
                                    d.value = (eat_enemy_attack.damage + this.damage_buff) * this.unit.damage_factor
                                end
                                queue_damage(store, d)
                                SU.hero_gain_xp_from_skill(this, skill)
                            end
                            local mod = E:create_entity(eat_enemy_attack.mod_regen)
                            mod.modifier.target_id = this.id
                            queue_insert(store, mod)
                        end

                        while not U.animation_finished(this) do
                            if this.health.dead or this.unit.is_stunned then
                                break
                            end

                            coroutine.yield()
                        end

                        S:stop(eat_enemy_attack.sound)
                        eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal
                    end

                    -- 此时必为人形
                    if target.health.hp <= target.health.hp_max * eat_enemy_attack.hp_trigger then
                        do_eat_enemy_attack()
                    elseif ready_to_use_skill(inner_beast_attack, store) and target.health.hp <= target.health.hp_max *
                        eat_enemy_attack.hp_trigger_normal * 1.5 then
                        inner_beast_attack.ts = store.tick_ts - 0.5 * inner_beast_attack.cooldown
                        eat_enemy_attack.hp_trigger = eat_enemy_attack.hp_trigger_normal * 1.5
                        do_eat_enemy_attack()
                    end
                end
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = find_target_at_critical_moment(this, store, 160, false, true, F_FLYING)
                if target and valid_rally_node_nearby(target.pos) then
                    play_level_up_animation()
                    S:queue(this.sound_events.change_rally_point)
                    local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                    e.pos.x, e.pos.y = target.pos.x, target.pos.y
                    e.damage_factor = this.unit.damage_factor
                    e.level = this.hero.skills.ultimate.level
                    queue_insert(store, e)
                    this.ultimate.ts = store.tick_ts
                    SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            a = inner_beast_attack
            skill = this.hero.skills.inner_beast

            if not this.is_transformed and ready_to_use_skill(a, store) and this.health.hp <= this.health.hp_max *
                skill.trigger_hp and store.tick_ts - last_ts > a.min_cooldown and this.soldier.target_id and
                store.entities[this.soldier.target_id] and not store.entities[this.soldier.target_id].health.dead and
                this.motion.arrived then
                y_transform_in()
            end

            if this.is_transformed then
                if this.soldier.target_id and store.tick_ts - a.ts > skill.duration * 0.5 then
                    local target = store.entities[this.soldier.target_id]

                    if target and target.health.hp <= target.health.hp_max * eat_enemy_attack.hp_trigger and
                        ready_to_attack(eat_enemy_attack, store) then
                        a.ts = a.ts - a.cooldown * 0.5
                        y_transform_out()
                        goto label_294_2
                    end
                elseif store.tick_ts - a.ts > skill.duration then
                    y_transform_out()
                end
            end

            skill = this.hero.skills.floor_spikes
            a = floor_spikes_attack

            if not this.is_transformed and ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemies = U.find_enemies_in_range(store, this.pos, a.range_trigger_min,
                    a.range_trigger_max, a.vis_flags, a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))

                    goto label_294_1
                end

                local targets = table.filter(enemies, function(k, v)
                    local vpi = v.nav_path.pi
                    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {vpi})
                    local pi, spi, ni = unpack(nearest[1])

                    return ni > v.nav_path.ni
                end)

                if not targets or #targets < a.min_targets then
                    SU.delay_attack(store, a, fts(10))

                    goto label_294_1
                end

                local path = targets[1].nav_path.pi
                local start_ts = store.tick_ts

                S:queue(a.sound_in, {
                    delay = fts(10)
                })

                local flip = targets[1].pos.x < this.pos.x

                U.animation_start(this, a.animation_in, flip, store.tick_ts, false)

                if SU.y_hero_wait(store, this, a.cast_time) then
                    goto label_294_2
                end

                a.ts = start_ts
                last_ts = start_ts

                SU.hero_gain_xp_from_skill(this, skill)

                local nodes_between_spikes = 2
                local spikes = {}

                local function spawn_spike(pi, spi, ni, spike_id)
                    local pos = P:node_pos(pi, spi, ni)

                    pos.x = pos.x + math.random(-4, 4)
                    pos.y = pos.y + math.random(-5, 5)

                    local s = E:create_entity(a.spike_template[math.random(1, #a.spike_template)])

                    s.pos = V.vclone(pos)

                    queue_insert(store, s)

                    spikes[spike_id] = s
                end

                local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {path})

                if #nearest > 0 then
                    local pi, spi, ni = unpack(nearest[1])
                    local initial_offset = 1

                    ni = ni - initial_offset

                    local count = a.spikes / 3
                    local ni_aux
                    local spike_id = 1

                    for i = 1, count do
                        ni_aux = ni - i * nodes_between_spikes

                        if P:is_node_valid(pi, ni_aux) then
                            spawn_spike(pi, 1, ni_aux, spike_id)

                            spike_id = spike_id + 1

                            U.y_wait(store, fts(1))
                        end

                        ni_aux = ni - i * (nodes_between_spikes + 1)

                        if P:is_node_valid(pi, ni_aux) then
                            spawn_spike(pi, 2, ni_aux, spike_id)

                            spike_id = spike_id + 1

                            U.y_wait(store, fts(1))
                            spawn_spike(pi, 3, ni_aux, spike_id)

                            spike_id = spike_id + 1

                            U.y_wait(store, fts(1))
                        end
                    end
                end

                U.animation_start(this, a.animation_idle, nil, store.tick_ts, true)
                U.y_wait(store, fts(10))
                S:queue(a.sound_out)

                for i = #spikes, 1, -1 do
                    spikes[i].hide = true

                    U.y_wait(store, fts(1))
                end

                U.animation_start(this, a.animation_out, nil, store.tick_ts, false)
                SU.y_hero_animation_wait(this)

                goto label_294_2
            end

            skill = this.hero.skills.ranged_tentacle
            a = ranged_tentacle_attack

            if not this.is_transformed and ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), a.min_range, a.max_range,
                    a.node_prediction, a.vis_flags, a.vis_bans)

                if not target then
                    SU.delay_attack(store, a, fts(10))
                else
                    local enemy_id = target.id
                    local enemy_pos = target.pos

                    last_ts = store.tick_ts

                    local an, af, ai = U.animation_name_facing_point(this, a.animation, enemy_pos)

                    U.animation_start(this, an, af, store.tick_ts, false)
                    S:queue(a.sound)

                    local start_offset = V.vclone(a.bullet_start_offset)

                    if af then
                        start_offset.x = start_offset.x * -1
                    end

                    U.y_wait(store, a.shoot_time)

                    if SU.soldier_interrupted(this) then
                        -- block empty
                    else
                        local target, _, pred_pos = U.find_foremost_enemy(store, tpos(this), a.min_range,
                            a.max_range, a.shoot_time, a.vis_flags, a.vis_bans)

                        if target then
                            enemy_id = target.id
                            enemy_pos = target.pos
                        end

                        if not target then
                            -- block empty
                        else
                            a.ts = last_ts

                            local b = E:create_entity(a.bullet)

                            b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
                            b.bullet.from = V.vclone(b.pos)
                            b.bullet.to = V.vclone(pred_pos)
                            b.bullet.to.x = b.bullet.to.x + target.unit.hit_offset.x
                            b.bullet.to.y = b.bullet.to.y + target.unit.hit_offset.y
                            b.bullet.target_id = enemy_id
                            b.bullet.source_id = this.id
                            b.bullet.level = this.hero.level
                            b.bullet.damage_factor = this.unit.damage_factor
                            queue_insert(store, b)
                            SU.hero_gain_xp_from_skill(this, skill)
                            U.y_animation_wait(this)

                            goto label_294_2
                        end
                    end
                end
            end

            ::label_294_1::

            if not this.soldier.target_id and ready_to_use_skill(eat_enemy_attack, store) then
                local targets = U.find_enemies_in_range(store, this.nav_rally.center, 0, this.melee.range,
                    F_BLOCK, F_CLIFF, function(e)
                        return (not e.enemy.max_blockers or #e.enemy.blockers == 0) and
                                   band(GR:cell_type(e.pos.x, e.pos.y), TERRAIN_NOWALK) == 0 and e.health.hp <
                                   e.health.hp_max * eat_enemy_attack.hp_trigger
                    end)
                if targets then
                    U.block_enemy(store, this, targets[1])
                end
            end

            brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

            if sta == A_DONE then
                if this.is_transformed then
                    this.health.hp = this.health.hp + this.health.hp_max * this.beast.regen_health

                    if this.health.hp > this.health.hp_max then
                        this.health.hp = this.health.hp_max
                    end
                end
            end

            if brk or sta ~= A_NO_TARGET then
                -- block empty
            elseif SU.soldier_go_back_step(store, this) then
                -- block empty
            else
                SU.soldier_idle(store, this)
                SU.soldier_regen(store, this)
            end
        end

        ::label_294_2::

        coroutine.yield()
    end
end

scripts.bullet_hero_venom_ranged_tentacle = {}

function scripts.bullet_hero_venom_ranged_tentacle.insert(this, store, script)
    if not this.bullet.mods then
        this.bullet.mods = {"mod_bullet_hero_venom_ranged_tentacle_stun"}
    else
        table.insert(this.bullet.mods, "mod_bullet_hero_venom_ranged_tentacle_stun")
    end

    return true
end

scripts.decal_hero_venom_spike = {}

function scripts.decal_hero_venom_spike.update(this, store, script)
    U.y_animation_play(this, "in", false, store.tick_ts)
    U.animation_start(this, "idle", false, store.tick_ts, true)

    local enemies = U.find_enemies_in_range(store, this.pos, 0, this.damage_radius, this.vis_flags,
        this.vis_bans)

    if enemies and #enemies > 0 then
        for i = 1, #enemies do
            local d = E:create_entity("damage")

            d.damage_type = this.damage_type
            d.value = math.random(this.damage_min, this.damage_max)
            d.source_id = this.id
            d.target_id = enemies[i].id

            queue_damage(store, d)
        end
    end

    while true do
        if this.hide then
            U.y_animation_play(this, "out", false, store.tick_ts)

            this.render.sprites[1].hidden = true

            break
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.mod_hero_venom_eat_enemy_regen = {}

function scripts.mod_hero_venom_eat_enemy_regen.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node then
            queue_remove(store, this)

            return
        end

        if this.render and target.unit then
            for _, s in pairs(this.render.sprites) do
                local flip_sign = 1

                if target.render then
                    flip_sign = target.render.sprites[1].flip_x and -1 or 1
                end

                s.offset.x, s.offset.y = target.render.sprites[1].offset.x * flip_sign,
                    target.render.sprites[1].offset.y
            end
        end

        coroutine.yield()
    end
end

scripts.decal_hero_venom_death = {}

function scripts.decal_hero_venom_death.update(this, store, script)
    U.y_wait(store, fts(19))

    this.render.sprites[1].hidden = false

    U.animation_start(this, "idle", false, store.tick_ts, false)

    while true do
        if this.tween.disabled and this.hero_venom.render.sprites[1].name == "respawn" then
            this.tween.disabled = false
            this.tween.remove = true
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.hero_venom_ultimate = {}

function scripts.hero_venom_ultimate.update(this, store)
    local nearest = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

    if #nearest > 0 then
        local pi, spi, ni = unpack(nearest[1])

        if P:is_node_valid(pi, ni) then
            S:queue(this.sound)

            local aura = E:create_entity(this.aura)
            aura.aura.damage_factor = this.damage_factor
            aura.aura.source_id = this.id
            aura.aura.ts = store.tick_ts

            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)

            if #nodes < 1 then
                log.debug("cannot insert venom ulti, no valid nodes nearby %s,%s", x, y)

                return nil
            end

            local pi, spi, ni = unpack(nodes[1])
            local npos = P:node_pos(pi, 1, ni)

            aura.pos = npos
            aura.pos_pi = pi
            aura.pos_ni = ni

            S:queue(this.sound)
            queue_insert(store, aura)
        end
    end

    queue_remove(store, this)
end

scripts.aura_hero_venom_ultimate = {}

function scripts.aura_hero_venom_ultimate.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

    if this.aura.track_source and this.aura.source_id then
        local te = store.entities[this.aura.source_id]

        if te and te.pos then
            this.pos = te.pos
        end
    end

    U.animation_start(this, "in", false, store.tick_ts, false)
    U.y_wait(store, this.slow_delay)

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    while true do
        if this.render.sprites[1].name == "in" and U.animation_finished(this) then
            U.animation_start(this, "idle", false, store.tick_ts, true)
        end

        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration + this.slow_delay then
            U.animation_start(this, "attack", false, store.tick_ts, false)
            S:queue(this.sound_attack)
            U.y_wait(store, fts(10))

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                           band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                local d = E:create_entity("damage")

                d.damage_type = this.end_damage_type
                d.value = math.random(this.end_damage_min, this.end_damage_max) * this.aura.damage_factor
                d.source_id = this.id
                d.target_id = target.id

                queue_damage(store, d)
            end

            U.y_animation_wait(this)

            break
        end

        if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
            break
        end

        if this.aura.track_source and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if not te or te.health and te.health.dead and not this.aura.track_dead then
                break
            end
        end

        if this.aura.source_vis_flags and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
                goto label_305_0
            end
        end

        if this.aura.requires_alive_source and this.aura.source_id then
            local te = store.entities[this.aura.source_id]

            if te and te.health and te.health.dead then
                goto label_305_0
            end
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                           band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                if this.aura.max_count and victims_count >= this.aura.max_count then
                    break
                end

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

        ::label_305_0::

        coroutine.yield()
    end

    signal.emit("aura-apply-mod-victims", this, victims_count)
    queue_remove(store, this)
end

scripts.hero_dragon_gem = {}

function scripts.hero_dragon_gem.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)
    local b = E:get_template(this.ranged.attacks[1].bullet)

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    upgrade_skill(this, "stun", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local b = E:get_template(a.bullet)
        local aura = E:get_template(b.bullet.hit_payload)
        local mod = E:get_template(aura.aura.mod)

        mod.modifier.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "floor_impact", function(this, s)
        local a = this.ranged.attacks[3]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local d = E:get_template(a.entity)

        d.damage_min = s.damage_min[s.level]
        d.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "crystal_instakill", function(this, s)
        local a = this.ranged.attacks[4]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.hp_max = s.hp_max[s.level]

        local m = E:get_template(a.mod)

        m.damage_aoe_min = s.damage_min[s.level]
        m.damage_aoe_max = s.damage_max[s.level]

    end)

    upgrade_skill(this, "crystal_totem", function(this, s)
        local a = this.ranged.attacks[5]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local bullet = E:get_template(a.bullet)
        local aura = E:get_template(bullet.bullet.hit_payload)

        aura.aura.duration = s.duration[s.level]
        aura.damage_min = s.damage_min[s.level]
        aura.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local a = this.ultimate

        a.disabled = nil

        local uc = E:get_template(s.controller_name)

        uc.max_shards = s.max_shards[s.level]

        local decal = E:get_template(uc.decal)

        decal.damage_min = s.damage_min[s.level]
        decal.damage_max = s.damage_max[s.level]

    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_dragon_gem.insert(this, store)
    this.hero.fn_level_up(this, store)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_dragon_gem.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill
    local shots_with_mod = 0
    local shadow_sprite = this.render.sprites[2]
    local stun_attack = this.ranged.attacks[2]
    local floor_impact_attack = this.ranged.attacks[3]
    local crystal_instakill_attack = this.ranged.attacks[4]
    local crystal_totem_attack = this.ranged.attacks[5]

    if not stun_attack.disabled then
        stun_attack.ts = store.tick_ts - stun_attack.cooldown
    end

    if not floor_impact_attack.disabled then
        floor_impact_attack.ts = store.tick_ts - floor_impact_attack.cooldown
    end

    if not crystal_instakill_attack.disabled then
        crystal_instakill_attack.ts = store.tick_ts - crystal_instakill_attack.cooldown
    end

    if not crystal_totem_attack.disabled then
        crystal_totem_attack.ts = store.tick_ts - crystal_totem_attack.cooldown
    end

    local function y_hero_death_and_respawn_hero_dragon_gem(store, this)
        local h = this.health
        local he = this.hero

        this.ui.can_click = false

        local death_ts = store.tick_ts
        local dead_lifetime = h.dead_lifetime

        U.unblock_target(store, this)
        if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE)) ~= 0 then
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
            U.animation_start(this, "death_dragon", nil, store.tick_ts)
        end

        this.health.death_finished_ts = store.tick_ts

        if this.unit.hide_after_death then
            for _, s in pairs(this.render.sprites) do
                s.hidden = true
            end
        end

        local tombstone

        if he and he.tombstone_show_time then
            while store.tick_ts - death_ts < he.tombstone_show_time do
                coroutine.yield()
            end

            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1, 2, 3}, true)
            local pi, spi, ni = unpack(nodes[1])
            local npos = P:node_pos(pi, spi, ni)

            tombstone = E:create_entity(he.tombstone_decal)
            tombstone.pos = npos

            queue_insert(store, tombstone)

            shadow_sprite.hidden = true
        end

        SU.y_hero_animation_wait(this)

        while dead_lifetime > store.tick_ts - death_ts do
            coroutine.yield()
        end

        this.health.death_finished_ts = nil

        U.animation_start(tombstone, "respawn_crystals", nil, store.tick_ts)
        U.y_wait(store, fts(5))

        he.respawn_point = tombstone.pos

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

        this.render.sprites[1].hidden = false
        h.ignore_damage = true

        S:queue(this.sound_events.respawn)
        U.y_animation_play(this, "respawn_dragon", nil, store.tick_ts, 1)

        if tombstone then
            queue_remove(store, tombstone)
        end

        this.health_bar.hidden = false
        this.ui.can_click = true
        h.dead = false
        h.hp = h.hp_max
        h.ignore_damage = false
    end

    this.tween.disabled = false
    this.tween.ts = store.tick_ts
    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            y_hero_death_and_respawn_hero_dragon_gem(store, this)
            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            local r = this.nav_rally
            local start_pos = V.vclone(this.pos)

            SU.y_hero_new_rally(store, this)

            if V.dist2(this.pos.x, this.pos.y, start_pos.x, start_pos.y) > this.passive_charge.distance_to_charge ^ 2 then
                local modifier = E:create_entity(this.passive_charge.mod)

                modifier.modifier.target_id = this.id

                queue_insert(store, modifier)
            end
        end

        if SU.hero_level_up(store, this) then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end

        if ready_to_use_skill(this.ultimate, store) then
            local target = find_target_at_critical_moment(this, store, 160, true, false, F_FLYING)
            if target and valid_rally_node_nearby(target.pos) then
                S:queue(this.sound_events.ultimate)
                local e = E:create_entity(this.hero.skills.ultimate.controller_name)
                e.pos.x, e.pos.y = target.pos.x, target.pos.y
                e.damage_factor = this.unit.damage_factor
                e.level = this.ultimate.level
                queue_insert(store, e)
                this.ultimate.ts = store.tick_ts
                SU.hero_gain_xp_from_skill(this, this.hero.skills.ultimate)
            else
                this.ultimate.ts = this.ultimate.ts + 1
            end
        end

        for _, i in pairs(this.ranged.order) do
            do
                local a = this.ranged.attacks[i]

                if a.disabled then
                    -- block empty
                elseif a.sync_animation and not this.render.sprites[1].sync_flag then
                    -- block empty
                elseif store.tick_ts - a.ts < a.cooldown then
                    -- block empty
                else
                    if i == 2 then
                        local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min,
                            a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

                        if not targets_info or #targets_info < a.min_targets then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local target

                        for _, ti in pairs(targets_info) do
                            if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) then
                                target = ti.enemy

                                break
                            end
                        end

                        if not target then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local start_ts = store.tick_ts
                        local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)

                        S:queue(a.sound)
                        U.animation_start(this, an, af, store.tick_ts)

                        if SU.y_hero_wait(store, this, a.shoot_time) then
                            goto label_370_2
                        end

                        local b = E:create_entity(a.bullet)

                        b.bullet.target_id = target.id
                        b.bullet.source_id = this.id
                        b.bullet.damage_factor = this.unit.damage_factor
                        b.pos = V.vclone(this.pos)

                        local bullet_start_offset = V.v(0, 0)

                        if a.bullet_start_offset and #a.bullet_start_offset == 2 then
                            local offset_index = af and 2 or 1

                            bullet_start_offset = a.bullet_start_offset[offset_index]
                        end

                        b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
                        b.pos.y = b.pos.y + bullet_start_offset.y
                        b.bullet.from = V.vclone(b.pos)

                        if b.bullet.ignore_hit_offset then
                            b.bullet.to = V.v(target.pos.x, target.pos.y)
                        else
                            b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                target.pos.y + target.unit.hit_offset.y)
                        end

                        queue_insert(store, b)
                        U.y_animation_wait(this)

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

                        goto label_370_1
                    end

                    if i == 3 then
                        local targets_info = U.find_enemies_in_paths(store.enemies, this.pos, a.range_nodes_min,
                            a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

                        if not targets_info or #targets_info < a.min_targets then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local target

                        for _, ti in pairs(targets_info) do
                            if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE)) then
                                target = ti.enemy

                                break
                            end
                        end

                        if not target then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
                        local available_paths = {}

                        for k, v in pairs(P.paths) do
                            table.insert(available_paths, k)
                        end

                        if store.level.ignore_walk_backwards_paths then
                            available_paths = table.filter(available_paths, function(k, v)
                                return not table.contains(store.level.ignore_walk_backwards_paths, v)
                            end)
                        end

                        local nodes = P:nearest_nodes(this.pos.x, this.pos.y, available_paths, nil, nil, NF_RALLY)

                        if #nodes < 1 then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local pi, spi, ni = unpack(nodes[1])
                        local nodepos = P:node_pos(pi, spi, ni)
                        local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)

                        if dist > a.distance_to_start_node then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        S:queue(a.sound)

                        local start_ts = store.tick_ts
                        local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts)
                        U.y_wait(store, a.fall_time)

                        local floor_decal = E:create_entity(a.floor_decal)

                        floor_decal.pos = V.vclone(this.pos)
                        floor_decal.render.sprites[1].ts = store.tick_ts

                        queue_insert(store, floor_decal)

                        local shards = {}

                        local function shard_too_close(new_pos)
                            for _, shard in ipairs(shards) do
                                local dist2 = V.dist2(new_pos.x, new_pos.y, shard.x, shard.y)

                                if dist2 < 100 then
                                    return true
                                end
                            end

                            return false
                        end

                        for i = 1, #nodes do
                            local pi, spi, ni = unpack(nodes[i])
                            local nodepos = P:node_pos(pi, spi, ni)
                            local dist = V.dist(this.pos.x, this.pos.y, nodepos.x, nodepos.y)

                            if dist < a.distance_to_start_node then
                                local ni_backwards = ni - a.initial_offset
                                local ni_forward = ni + a.initial_offset
                                local ni_aux

                                for j = 1, a.shards do
                                    ni_aux = ni_backwards - (j - 1) * a.nodes_between_shards

                                    local new_pos

                                    if P:is_node_valid(pi, ni_aux) then
                                        new_pos = P:node_pos(pi, 1, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end
                                    end

                                    ni_aux = ni_backwards - (j - 1) * (a.nodes_between_shards + 2)

                                    if P:is_node_valid(pi, ni_aux) then
                                        new_pos = P:node_pos(pi, 2, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end

                                        new_pos = P:node_pos(pi, 3, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end
                                    end

                                    ni_aux = ni_forward + (j - 1) * a.nodes_between_shards

                                    if P:is_node_valid(pi, ni_aux) then
                                        new_pos = P:node_pos(pi, 1, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end
                                    end

                                    ni_aux = ni_forward + (j - 1) * (a.nodes_between_shards + 2)

                                    if P:is_node_valid(pi, ni_aux) then
                                        new_pos = P:node_pos(pi, 2, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end

                                        new_pos = P:node_pos(pi, 3, ni_aux)

                                        if not shard_too_close(new_pos) then
                                            table.insert(shards, new_pos)
                                        end
                                    end
                                end
                            end
                        end

                        table.sort(shards, function(e1, e2)
                            return V.dist2(this.pos.x, this.pos.y, e1.x, e1.y) <
                                       V.dist2(this.pos.x, this.pos.y, e2.x, e2.y)
                        end)

                        local controller = E:create_entity(a.controller)

                        controller.shards = shards
                        controller.pos = V.vclone(this.pos)
                        controller.entity = a.entity

                        queue_insert(store, controller)
                        U.y_animation_wait(this)

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

                        goto label_370_1
                    end

                    if i == 4 then
                        local target, targets = U.find_foremost_enemy(store, this.pos, 0, a.max_range, 0,
                            a.vis_flags, a.vis_bans)

                        if not target then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        if target.health and target.health.hp > a.hp_max then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local start_ts = store.tick_ts

                        S:queue(a.sound, a.sound_args)

                        local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)

                        U.animation_start(this, an, af, store.tick_ts)
                        U.y_wait(store, a.shoot_time)

                        local mod = E:create_entity(a.mod)

                        mod.modifier.target_id = target.id
                        mod.modifier.source_id = this.id
                        mod.modifier.damage_factor = this.unit.damage_factor

                        queue_insert(store, mod)
                        U.y_animation_wait(this)

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

                        goto label_370_1
                    end

                    if i == 5 then
                        local aim_target, enemies = U.find_foremost_enemy_with_max_coverage(store, this.pos, 0,
                            a.max_range_trigger, a.shoot_time + E:get_template(a.bullet).bullet.flight_time,
                            a.vis_flags, a.vis_bans, nil, nil, E:get_template(
                                E:get_template(a.bullet).bullet.hit_payload).aura.radius)

                        if not enemies or #enemies < a.min_targets then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        if P:nodes_to_goal(aim_target.nav_path) < a.nodes_prediction + 10 then
                            SU.delay_attack(store, a, 0.4)

                            goto label_370_1
                        end

                        local bullet = E:create_entity(a.bullet)
                        local node_offset = P:predict_enemy_node_advance(aim_target, bullet.bullet.flight_time)

                        node_offset = node_offset + a.nodes_prediction

                        local bullet_to = P:node_pos(aim_target.nav_path.pi, 1, aim_target.nav_path.ni + node_offset,
                            true)
                        local start_ts = store.tick_ts

                        S:queue(a.sound)

                        local an, af, ai = U.animation_name_facing_point(this, a.animation, bullet_to)

                        U.animation_start(this, an, af, store.tick_ts)
                        U.y_wait(store, a.shoot_time)

                        bullet.pos = V.vclone(this.pos)
                        bullet.pos.x = bullet.pos.x + a.bullet_start_offset.x
                        bullet.pos.y = bullet.pos.y + a.bullet_start_offset.y
                        bullet.bullet.from = V.vclone(bullet.pos)
                        bullet.bullet.to = V.vclone(bullet_to)
                        bullet.bullet.target_id = aim_target.id
                        bullet.bullet.source_id = this.id
                        bullet.bullet.damage_factor = this.unit.damage_factor
                        queue_insert(store, bullet)
                        U.y_animation_wait(this)

                        a.ts = start_ts

                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

                        goto label_370_1
                    end

                    if i == 1 then
                        local bullet_t = E:get_template(a.bullet)
                        local flight_time = a.estimated_flight_time or 1

                        local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                            a.vis_bans)

                        if targets then
                            local target = targets[1]
                            local start_ts = store.tick_ts
                            local start_fx, b, targets
                            local node_offset = P:predict_enemy_node_advance(target, flight_time)
                            local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi,
                                target.nav_path.ni + node_offset)
                            local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                            U.animation_start(this, an, af, store.tick_ts)
                            S:queue(a.start_sound, a.start_sound_args)

                            while store.tick_ts - start_ts < a.shoot_time do
                                if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                                    goto label_370_0
                                end

                                coroutine.yield()
                            end

                            targets = {target}
                            b = E:create_entity(a.bullet)

                            if a.type == "aura" then
                                b.pos.x, b.pos.y = target.pos.x, target.pos.y
                                b.aura.ts = store.tick_ts
                            else
                                b.bullet.target_id = target.id
                                b.bullet.source_id = this.id
                                b.bullet.xp_dest_id = this.id

                                b.pos = V.vclone(this.pos)

                                local bullet_start_offset = V.v(0, 0)

                                if a.bullet_start_offset and #a.bullet_start_offset == 2 then
                                    local offset_index = af and 2 or 1

                                    bullet_start_offset = a.bullet_start_offset[offset_index]
                                end

                                b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
                                b.pos.y = b.pos.y + bullet_start_offset.y
                                b.bullet.from = V.vclone(b.pos)

                                if b.bullet.ignore_hit_offset then
                                    b.bullet.to = V.v(target.pos.x, target.pos.y)
                                else
                                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                                        target.pos.y + target.unit.hit_offset.y)
                                end

                                b.bullet.shot_index = i
                                b.initial_impulse = 10
                                b.bullet.damage_min = b.bullet.damage_min + this.damage_buff
                                b.bullet.damage_max = b.bullet.damage_max + this.damage_buff

                                b.bullet.damage_factor = this.unit.damage_factor
                            end

                            queue_insert(store, b)

                            if a.xp_from_skill then
                                SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                            end

                            a.ts = start_ts

                            while not U.animation_finished(this) do
                                if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                                    goto label_370_0
                                end

                                coroutine.yield()
                            end

                            a.ts = start_ts

                            if U.has_modifiers(store, this, this.passive_charge.mod) then
                                shots_with_mod = shots_with_mod + 1

                                if shots_with_mod >= this.passive_charge.shots_amount then
                                    SU.remove_modifiers(store, this, this.passive_charge.mod)

                                    shots_with_mod = 0
                                end
                            end

                            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts,
                                this.idle_flip.loop, nil, true)

                            ::label_370_0::

                            if start_fx then
                                start_fx.render.sprites[1].hidden = true
                            end

                            goto label_370_1
                        end
                    end
                end
            end

            ::label_370_1::
        end

        SU.soldier_idle(store, this)
        SU.soldier_regen(store, this)

        ::label_370_2::

        coroutine.yield()
    end
end

scripts.bolt_hero_dragon_gem_attack = {}

function scripts.bolt_hero_dragon_gem_attack.update(this, store, script)
    local b = this.bullet
    local s = this.render.sprites[1]
    local mspeed = b.min_speed
    local target, ps
    local new_target = false
    local target_invalid = false
    local target = store.entities[b.target_id]

    if not target then
        queue_remove(store, this)

        return
    end

    local is_flying = U.flag_has(target.vis.flags, F_FLYING)

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    if is_flying then
        b.hit_fx = b.hit_fx_flying
        b.ignore_hit_offset = false
    else
        b.hit_fx = b.hit_fx_floor
        b.ignore_hit_offset = true
    end

    ::label_376_0::

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

            goto label_376_0
        end
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y

    S:queue(this.sound_hit)

    local function explosion(r, damage_min, damage_max, dty)
        local target_bans = bit.bor(F_FLYING)
        local target_pos = V.vclone(this.pos)

        if is_flying then
            target_bans = 0

            if target and target.flight_height then
                target_pos.y = target_pos.y - target.flight_height
            end
        end

        local targets = U.find_enemies_in_range(store, target_pos, 0, r, 0, target_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = math.random(damage_min, damage_max) * b.damage_factor
                d.damage_type = dty
                d.target_id = target.id
                d.source_id = b.source_id
                d.xp_gain_factor = b.xp_gain_factor
                d.xp_dest_id = b.source_id

                queue_damage(store, d)
            end
        end
    end

    local p = SU.create_bullet_pop(store, this)

    if p then
        queue_insert(store, p)
    end

    explosion(this.damage_range, b.damage_min, b.damage_max, b.damage_type)

    if not is_flying and b.payload then
        for _, v in ipairs(b.payload) do
            local hp

            if type(v) == "string" then
                hp = E:create_entity(v)
            else
                hp = v
            end

            hp.pos.x, hp.pos.y = b.to.x, b.to.y
            hp.render.sprites[1].ts = store.tick_ts

            queue_insert(store, hp)
        end
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

scripts.aura_hero_dragon_gem_skill_stun = {}

function scripts.aura_hero_dragon_gem_skill_stun.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

    if this.aura.track_source and this.aura.source_id then
        local te = store.entities[this.aura.source_id]

        if te and te.pos then
            this.pos = te.pos
        end
    end

    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)
    local pi, spi, ni = unpack(nodes[1])
    local npos = P:node_pos(pi, spi, ni)
    local fx = E:create_entity(this.surround_fx)

    fx.pos.x, fx.pos.y = npos.x - 20, npos.y
    fx.render.sprites[1].ts = store.tick_ts
    fx.render.sprites[1].runs = 0

    queue_insert(store, fx)

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration then
            break
        end

        if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
            break
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                           band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                if this.aura.max_count and victims_count >= this.aura.max_count then
                    break
                end

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

        ::label_378_0::

        coroutine.yield()
    end

    U.y_wait(store, fts(5))

    fx = E:create_entity(this.surround_fx)
    fx.pos.x, fx.pos.y = npos.x + 20, npos.y - 20
    fx.render.sprites[1].ts = store.tick_ts
    fx.render.sprites[1].runs = 0

    queue_insert(store, fx)
    U.y_wait(store, fts(5))

    fx = E:create_entity(this.surround_fx)
    fx.pos.x, fx.pos.y = npos.x + 15, npos.y + 20
    fx.render.sprites[1].ts = store.tick_ts
    fx.render.sprites[1].runs = 0
    fx.render.sprites[1].flip_x = true

    queue_insert(store, fx)
    signal.emit("aura-apply-mod-victims", this, victims_count)
    queue_remove(store, this)
end

scripts.decal_hero_dragon_gem_crystal_tomb = {}

function scripts.decal_hero_dragon_gem_crystal_tomb.update(this, store)
    U.y_animation_play(this, "death_crystals", nil, store.tick_ts, 1)

    while true do
        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.controller_hero_dragon_gem_skill_floor_impact_spawner = {}

function scripts.controller_hero_dragon_gem_skill_floor_impact_spawner.update(this, store)
    local function spawn_shard(pos)
        pos.x = pos.x + math.random(-4, 4)
        pos.y = pos.y + math.random(-5, 5)

        local s = E:create_entity(this.entity)

        s.pos = V.vclone(pos)
        s.dragon_pos = V.vclone(this.pos)

        queue_insert(store, s)
    end

    for i = 1, #this.shards do
        spawn_shard(this.shards[i])
        U.y_wait(store, fts(1))
    end

    queue_remove(store, this)
end

scripts.decal_hero_dragon_gem_floor_impact_shard = {}

function scripts.decal_hero_dragon_gem_floor_impact_shard.update(this, store)
    this.render.sprites[1].flip_x = this.dragon_pos.x > this.pos.x

    U.animation_start(this, "start", nil, store.tick_ts, 1)
    U.y_wait(store, this.damage_time)
    U.y_animation_wait(this)
    U.animation_start(this, "idle", nil, store.tick_ts, 1)

    local targets =
        U.find_enemies_in_range(store, this.pos, 0, this.damage_range, 0, bit.bor(F_FLYING, F_CLIFF))

    if targets then
        for _, target in pairs(targets) do
            local d = E:create_entity("damage")

            d.value = math.random(this.damage_min, this.damage_max)
            d.damage_type = this.damage_type
            d.target_id = target.id
            d.source_id = this.id

            queue_damage(store, d)
        end
    end

    U.y_wait(store, this.duration_time + fts(math.random(1, 10) - 5))
    U.animation_start(this, "end", nil, store.tick_ts, 1)
    U.y_animation_wait(this)
    queue_remove(store, this)
end

scripts.mod_hero_dragon_gem_crystal_instakill = {}

function scripts.mod_hero_dragon_gem_crystal_instakill.update(this, store)
    local start_ts, target_hidden
    local m = this.modifier
    local target = store.entities[this.modifier.target_id]

    if not target then
        queue_remove(store, this)

        return
    end

    if target.unit.size == UNIT_SIZE_SMALL then
        this.render.sprites[1].scale = V.v(0.56, 0.56)
    else
        this.render.sprites[1].scale = V.v(0.7, 0.7)
    end

    this.pos = target.pos
    start_ts = store.tick_ts

    if m.animation_phases then
        U.animation_start(this, "start", nil, store.tick_ts)

        while not U.animation_finished(this) do
            if not target_hidden and m.hide_target_delay and store.tick_ts - start_ts > m.hide_target_delay then
                target_hidden = true

                if target.ui then
                    target.ui.can_click = false
                end

                if target.health_bar then
                    target.health_bar.hidden = true
                end

                U.sprites_hide(target, nil, nil, true)
                SU.hide_modifiers(store, target, true, this)
                SU.hide_auras(store, target, true)
            end

            coroutine.yield()
        end
    end

    local d = E:create_entity("damage")

    d.value = 1
    d.damage_type = this.damage_type
    d.target_id = target.id
    d.source_id = this.id

    queue_damage(store, d)
    U.animation_start(this, "idle", nil, store.tick_ts, true)

    while store.tick_ts - m.ts < m.duration and target and not target.health.dead do
        if this.render and m.use_mod_offset and target.unit.mod_offset and not m.custom_offsets then
            for i = 1, #this.render.sprites do
                local s = this.render.sprites[i]

                s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
            end
        end

        coroutine.yield()
    end

    S:queue(this.explode_sound)

    if m.animation_phases then
        U.animation_start(this, "explosion", nil, store.tick_ts)

        if target_hidden then
            if target.ui then
                target.ui.can_click = true
            end

            if target.health_bar and not target.health.dead then
                target.health_bar.hidden = nil
            end

            U.sprites_show(target, nil, nil, true)
            SU.show_modifiers(store, target, true, this)
            SU.show_auras(store, target, true)
        end

        U.y_wait(store, this.explode_time)

        local explode_fx = E:create_entity(this.explode_fx)

        explode_fx.pos = V.vclone(target.pos)
        explode_fx.tween.ts = store.tick_ts

        queue_insert(store, explode_fx)

        local targets = U.find_enemies_in_range(store, this.pos, 0, this.damage_range, 0, this.damage_aoe_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = math.random(this.damage_aoe_min, this.damage_aoe_max) * this.modifier.damage_factor
                d.damage_type = this.damage_type_aoe
                d.target_id = target.id
                d.source_id = this.id

                queue_damage(store, d)
            end
        end

        while not U.animation_finished(this) do
            coroutine.yield()
        end
    end

    queue_remove(store, this)
end

scripts.aura_hero_dragon_gem_crystal_totem = {}

function scripts.aura_hero_dragon_gem_crystal_totem.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

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

    local floor_decal = E:create_entity(this.floor_decal)

    floor_decal.pos = V.vclone(this.pos)
    floor_decal.tween.ts = store.tick_ts

    queue_insert(store, floor_decal)
    S:queue(this.pulse_sound)
    U.y_animation_play(this, "spawn", nil, store.tick_ts)
    U.animation_start(this, "idle", nil, store.tick_ts, true)

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration then
            break
        end

        if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
            break
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                           band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                if this.aura.max_count and victims_count >= this.aura.max_count then
                    break
                end

                local mods = this.aura.mods or {this.aura.mod}

                for _, mod_name in pairs(mods) do
                    local new_mod = E:create_entity(mod_name)

                    new_mod.modifier.level = this.aura.level
                    new_mod.modifier.target_id = target.id
                    new_mod.modifier.source_id = this.id
                    new_mod.modifier.damage_factor = this.aura.damage_factor
                    if this.aura.hide_source_fx and target.id == this.aura.source_id then
                        new_mod.render = nil
                    end

                    queue_insert(store, new_mod)

                    victims_count = victims_count + 1
                end
            end

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.damage_range, this.aura.vis_flags,
                F_NONE)

            if targets then
                for _, target in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.value = math.random(this.damage_min, this.damage_max) * this.aura.damage_factor
                    d.damage_type = this.damage_type
                    d.target_id = target.id
                    d.source_id = this.id

                    queue_damage(store, d)
                end
            end

            local floor_decal = E:create_entity(this.floor_decal)

            floor_decal.pos = V.vclone(this.pos)
            floor_decal.tween.ts = store.tick_ts

            queue_insert(store, floor_decal)
            U.y_animation_play(this, "shock", nil, store.tick_ts)
            U.animation_start(this, "idle", nil, store.tick_ts, true)
        end

        ::label_385_0::

        coroutine.yield()
    end

    this.tween.ts = store.tick_ts
    this.tween.disabled = false

    U.y_wait(store, fts(15))
    signal.emit("aura-apply-mod-victims", this, victims_count)
    queue_remove(store, this)
end

scripts.hero_dragon_gem_ultimate = {}

function scripts.hero_dragon_gem_ultimate.can_fire_fn(this, x, y)
    return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_dragon_gem_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

    if #nodes < 1 then
        log.error("hero_dragon_gem_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local target_pos = {}
    local node = {
        spi = 1,
        pi = nodes[1][1],
        ni = nodes[1][3]
    }
    local node_pos = P:node_pos(node)
    local count = this.max_shards

    local function shard_too_close(new_pos)
        for _, shard in ipairs(target_pos) do
            local dist = V.dist(new_pos.x, new_pos.y, shard.x, shard.y)

            if dist < this.distance_between_shards then
                return true
            end
        end

        return false
    end

    local _, targets = U.find_nearest_enemy(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans)

    table.insert(target_pos, node_pos)

    if targets then
        for _, v in ipairs(targets) do
            if count > #target_pos then
                local node_offset = P:predict_enemy_node_advance(v, this.prediction_nodes)
                local e_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)

                table.insert(target_pos, V.vclone(e_pos))
            end
        end
    end

    if count > #target_pos then
        local available_paths = {}

        for k, v in pairs(P.paths) do
            table.insert(available_paths, k)
        end

        if store.level.ignore_walk_backwards_paths then
            available_paths = table.filter(available_paths, function(k, v)
                return not table.contains(store.level.ignore_walk_backwards_paths, v)
            end)
        end

        local safe_break = 1000
        local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

        if nearest and #nearest > 0 then
            local path_pi, path_spi, path_ni = unpack(nearest[1])
            local spi = {1, 3, 2}

            while count > #target_pos do
                local ni_random = math.random(this.random_ni_spread * -1, this.random_ni_spread)
                local spi_random = spi[count % 3 + 1]
                local pos_spawn = P:node_pos(path_pi, spi_random, path_ni + ni_random)

                if not shard_too_close(pos_spawn) then
                    table.insert(target_pos, pos_spawn)
                end

                safe_break = safe_break - 1

                if safe_break <= 0 then
                    break
                end
            end
        end
    end

    for _, pos in ipairs(target_pos) do
        local decal = E:create_entity(this.decal)

        decal.pos = V.vclone(pos)

        queue_insert(store, decal)
        U.y_wait(store, this.spawn_delay)
    end

    queue_remove(store, this)
end

scripts.bullet_hero_dragon_gem_ultimate_shard = {}

function scripts.bullet_hero_dragon_gem_ultimate_shard.update(this, store)
    local b = this.bullet
    local speed = b.max_speed

    while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
        b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
        this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
        this.render.sprites[1].r = 0

        coroutine.yield()
    end

    local targets = U.find_targets_in_range(store.enemies, b.to, 0, b.damage_radius, b.damage_flags, b.damage_bans)

    if targets then
        for _, target in pairs(targets) do
            local d = E:create_entity("damage")

            d.damage_type = b.damage_type
            d.value = b.damage_max * b.damage_factor
            d.source_id = this.id
            d.target_id = target.id

            queue_damage(store, d)

            if b.mod then
                local mod = E:create_entity(b.mod)

                mod.modifier.target_id = target.id
                mod.modifier.damage_factor = b.damage_factor
                queue_insert(store, mod)
            end
        end
    end

    if b.hit_fx then
        SU.insert_sprite(store, b.hit_fx, this.pos)
    end

    if b.arrive_decal then
        local decal = E:create_entity(b.arrive_decal)

        decal.pos = V.vclone(b.to)
        decal.render.sprites[1].ts = store.tick_ts
        decal.tween.ts = store.tick_ts

        queue_insert(store, decal)
    end

    queue_remove(store, this)
end

scripts.decal_hero_dragon_gem_ultimate_shard = {}

function scripts.decal_hero_dragon_gem_ultimate_shard.update(this, store)
    this.render.sprites[1].hidden = true

    local x_bullet_offset = {0, 10, -10, 10}
    local y_bullet_offset = {-10, -5, 0, -5}

    for i = 1, 4 do
        local bullet = E:create_entity(this.bullet)
        local bullet_pos = V.vclone(this.pos)

        bullet_pos.x = bullet_pos.x + x_bullet_offset[i]
        bullet_pos.y = bullet_pos.y + y_bullet_offset[i]
        bullet.pos = V.vclone(bullet_pos)
        bullet.pos.y = bullet.pos.y + 200
        bullet.bullet.from = V.vclone(bullet.pos)
        bullet.bullet.to = V.vclone(bullet_pos)

        queue_insert(store, bullet)
        U.y_wait(store, fts(2))
    end

    U.y_wait(store, this.damage_time)

    this.render.sprites[1].hidden = false

    for _, v in ipairs(this.fx_on_arrival) do
        local fx = E:create_entity(v)

        fx.pos = V.vclone(this.pos)
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].runs = 0

        queue_insert(store, fx)
    end

    local floor_decal = E:create_entity(this.floor_decal)

    floor_decal.pos = V.vclone(this.pos)
    floor_decal.render.sprites[1].ts = store.tick_ts

    queue_insert(store, floor_decal)

    local targets =
        U.find_enemies_in_range(store, this.pos, 0, this.damage_range, 0, bit.bor(F_FLYING, F_CLIFF))

    if targets then
        for _, target in pairs(targets) do
            local d = E:create_entity("damage")

            d.value = math.random(this.damage_min, this.damage_max)
            d.damage_type = this.damage_type
            d.target_id = target.id
            d.source_id = this.id

            queue_damage(store, d)
        end
    end

    this.tween.ts = store.tick_ts
    this.tween.disabled = false

    U.y_wait(store, this.tween.props[1].keys[2][1])
    queue_remove(store, this)
end

scripts.mod_hero_dragon_gem_passive_charge = {}

function scripts.mod_hero_dragon_gem_passive_charge.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    local start_countdown = false

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and
            target.nav_path.ni > m.last_node then
            queue_remove(store, this)

            return
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

end

scripts.hero_witch = {}

function scripts.hero_witch.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)

    this.melee.attacks[1].damage_min = ls.melee_damage_min[hl]
    this.melee.attacks[1].damage_max = ls.melee_damage_max[hl]

    for i = 1, #this.ranged.attacks[1].bullets do
        local bt = E:get_template(this.ranged.attacks[1].bullets[i])

        bt.bullet.damage_min = ls.ranged_damage_min[hl]
        bt.bullet.damage_max = ls.ranged_damage_max[hl]
    end

    upgrade_skill(this, "soldiers", function(this, s)
        local a = this.timed_attacks.list[1]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.soldiers_amount = s.soldiers_amount[s.level]

        local e = E:get_template(a.entity)

        e.health.hp_max = s.hp_max[s.level]
        e.melee.attacks[1].damage_max = s.damage_max[s.level]
        e.melee.attacks[1].damage_min = s.damage_min[s.level]
    end)

    upgrade_skill(this, "polymorph", function(this, s)
        local a = this.timed_attacks.list[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.hp_max = s.hp_max[s.level]

        local b = E:get_template(a.bullet)
        local m = E:get_template(b.bullet.mod)

        m.modifier.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "disengage", function(this, s)
        local d = this.dodge

        d.disabled = nil
        d.cooldown = s.cooldown[s.level]

        local e = E:get_template(d.decoy)

        e.health.hp_max = s.hp_max[s.level]
        e.melee.attacks[1].damage_max = s.melee_damage_max[s.level]
        e.melee.attacks[1].damage_min = s.melee_damage_min[s.level]

        local a = E:get_template(e.death_spawns.name)
        local m = E:get_template(a.aura.mod)

        m.modifier.duration = s.stun_duration[s.level]
    end)

    upgrade_skill(this, "path_aoe", function(this, s)
        local a = this.timed_attacks.list[3]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local aur = E:get_template(a.new_entity)

        aur.aura.duration = s.duration[s.level]
        aur.damage_min = s.damage_min[s.level]
        aur.damage_max = s.damage_max[s.level]
        aur.tween.props[1].keys = {{0, 0}, {aur.start_wait_time, 0}, {aur.start_wait_time + fts(10), 255},
                                   {aur.aura.duration - 0.5, 255}, {aur.aura.duration, 0}}
        aur.tween.props[2].keys = {{0, 0}, {aur.start_wait_time + fts(4), 0}, {aur.start_wait_time + fts(5), 200},
                                   {aur.start_wait_time + fts(9), 255}, {aur.aura.duration - 0.7, 255},
                                   {aur.aura.duration, 0}}
        aur.tween.props[3].keys = {{0, v(0, 0)}, {aur.start_wait_time + fts(4), v(0, 0)},
                                   {aur.start_wait_time + fts(5), v(0.9, 0.9)},
                                   {aur.start_wait_time + fts(9), v(1.1, 1.1)}, {aur.start_wait_time + fts(11), v(1, 1)}}
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local u = this.ultimate

        u.disabled = nil

        local uc = E:get_template(s.controller_name)
        uc.max_targets = s.max_targets[s.level]

        local mtel = E:get_template(uc.mod_teleport)
        local mend = E:get_template(mtel.end_mod)

        mend.modifier.duration = s.duration[s.level]
    end)

    this.health.hp = this.health.hp_max
    this.hero.melee_active_status = {}

    for index, attack in ipairs(this.melee.attacks) do
        this.hero.melee_active_status[index] = attack.disabled
    end
end

function scripts.hero_witch.insert(this, store)
    this.hero.fn_level_up(this, store, true)

    this.melee.order = U.attack_order(this.melee.attacks)

    return true
end

function scripts.hero_witch.can_dodge(store, this, ranged_attack, attack, enemy)
    local skill = this.hero.skills.disengage

    if enemy and enemy.health and not enemy.health.dead and not this.dodge.disabled then
        local enp = enemy.nav_path
        local new_ni = enp.ni
        local node_limit = math.floor(skill.min_distance_from_end / P.average_node_dist)
        local node_jump = math.floor(skill.distance / P.average_node_dist)
        local nodes_to_goal = P:nodes_to_goal(enp)

        if node_limit < nodes_to_goal then
            new_ni = new_ni + math.min(nodes_to_goal - 1, node_jump)

            local new_pos = P:node_pos(enp.pi, enp.spi, new_ni)

            this.dodge.new_pos = new_pos

            return true
        end
    end

    return false
end

function scripts.hero_witch.update(this, store)
    local last_ts = store.tick_ts
    local h = this.health
    local a, skill, brk, stam, star
    local ultimate = this.hero.skills.ultimate
    local basic_attack = this.melee.attacks[1]
    local basic_ranged = this.ranged.attacks[1]
    local skill_soldiers_attack = this.timed_attacks.list[1]
    local skill_polymorph = this.timed_attacks.list[2]
    local skill_path_aoe_attack = this.timed_attacks.list[3]
    local p_sys

    this.health_bar.hidden = false
    p_sys = E:create_entity(this.particles_name_1)
    p_sys.particle_system.emit = false
    p_sys.particle_system.track_id = this.id

    queue_insert(store, p_sys)

    if not skill_soldiers_attack.disabled then
        skill_soldiers_attack.ts = store.tick_ts - skill_soldiers_attack.cooldown
    end

    if not skill_polymorph.disabled then
        skill_polymorph.ts = store.tick_ts - skill_polymorph.cooldown
    end

    if not skill_path_aoe_attack.disabled then
        skill_path_aoe_attack.ts = store.tick_ts - skill_path_aoe_attack.cooldown
    end

    local function custom_new_rally()
        local r = this.nav_rally

        if r.new then
            p_sys.particle_system.emit = true
            r.new = false

            U.unblock_target(store, this)

            if this.sound_events then
                S:queue(this.sound_events.change_rally_point)
            end

            local vis_bans = this.vis.bans
            local prev_immune = this.health.immune_to

            this.vis.bans = F_ALL
            this.health.immune_to = r.immune_to

            local out = SU.y_hero_walk_waypoints(store, this)

            U.animation_start(this, "idle", nil, store.tick_ts, true)

            p_sys.particle_system.emit = false
            this.vis.bans = vis_bans
            this.health.immune_to = prev_immune

            return out
        end
    end

    local function create_soldier(e_template, s_offset)
        local e = E:create_entity(e_template)

        e.pos.x = this.pos.x + s_offset.x
        e.pos.y = this.pos.y + s_offset.y
        e.nav_rally.center = V.v(this.pos.x, this.pos.y)
        e.nav_rally.pos = V.vclone(e.pos)

        queue_insert(store, e)
    end

    while true do
        if h.dead then
            p_sys.particle_system.emit = false

            SU.y_hero_death_and_respawn(store, this)
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            while this.nav_rally.new do
                if custom_new_rally(store, this) then
                    goto label_641_0
                end
            end

            if SU.hero_level_up(store, this) then
                U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
            end

            if ready_to_use_skill(this.ultimate, store) then
                local target = U.find_teleport_moment(store, this.pos, this.ranged.attacks[1].max_range, MANY_ENEMY_COUNT)
                if target and valid_rally_node_nearby(target.pos) then
                    apply_ultimate(this, store, target, "levelup")
                else
                    this.ultimate.ts = this.ultimate.ts + 1
                end
            end

            skill = this.hero.skills.soldiers
            a = skill_soldiers_attack

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local enemies = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags,
                    a.vis_bans)

                if not enemies or #enemies < a.min_targets then
                    SU.delay_attack(store, a, fts(10))
                else
                    local start_ts = store.tick_ts

                    S:queue(a.sound)

                    local an, af, _ = U.animation_name_facing_point(this, a.animation, enemies[1].pos)

                    U.animation_start(this, an, af, store.tick_ts, false)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        -- block empty
                    else
                        a.ts = start_ts
                        last_ts = start_ts

                        SU.hero_gain_xp_from_skill(this, skill)

                        for i = 1, a.soldiers_amount do
                            create_soldier(a.entity, a.soldiers_offset[i])
                        end

                        SU.y_hero_animation_wait(this)
                    end

                    goto label_641_0
                end
            end

            a = this.timed_attacks.list[3]
            skill = this.hero.skills.path_aoe

            if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                local target, targets, pred_pos = U.find_foremost_enemy_with_max_coverage(store, this.pos, 0, a.max_range,
                    a.node_prediction, a.vis_flags, a.vis_bans,nil,nil,E:get_template("aura_hero_witch_path_aoe").aura.radius)

                if not targets or #targets < a.min_targets or not pred_pos then
                    SU.delay_attack(store, a, fts(10))
                else
                    local nearest = P:nearest_nodes(pred_pos.x, pred_pos.y)

                    if #nearest > 0 then
                        local path_pi, path_spi, path_ni = unpack(nearest[1])

                        path_spi = 1
                        pred_pos = P:node_pos(path_pi, path_spi, path_ni)
                    end

                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, a.animation, pred_pos)

                    U.animation_start(this, an, af, store.tick_ts, 1, nil)
                    S:queue(a.sound)

                    if SU.y_hero_wait(store, this, a.cast_time) then
                        goto label_641_0
                    end

                    local ne = E:create_entity(a.new_entity)

                    ne.source_id = this.id
                    ne.pos.x, ne.pos.y = pred_pos.x, pred_pos.y

                    queue_insert(store, ne)
                    SU.y_hero_animation_wait(this)

                    a.ts = start_ts
                    last_ts = a.ts

                    SU.hero_gain_xp_from_skill(this, skill)
                end
            end

            if not this.dodge.disabled and this.dodge.active and this.vis.bans ~= F_ALL then
                local enemy = store.entities[this.soldier.target_id]

                if not enemy then
                    -- block empty
                else
                    local enemy_pos = enemy.pos
                    local enemy_id = enemy.id

                    this.dodge.active = false
                    this.dodge.ts = store.tick_ts

                    local new_pos = this.dodge.new_pos

                    S:queue(this.dodge.sound)
                    U.unblock_target(store, this)

                    local bans = this.vis.bans

                    this.vis.bans = F_ALL

                    SU.hide_modifiers(store, this, true)
                    SU.hide_auras(store, this, true)
                    U.animation_start(this, this.dodge.animation_dissapear, nil, store.tick_ts, false)
                    U.y_wait(store, fts(6))
                    create_soldier(this.dodge.decoy, V.v(0, 0))
                    this.timed_attacks.list[1].ts = this.timed_attacks.list[1].ts - 1
                    this.timed_attacks.list[2].ts = this.timed_attacks.list[2].ts - 1
                    this.timed_attacks.list[3].ts = this.timed_attacks.list[3].ts - 1
                    U.y_animation_wait(this)
                    U.y_wait(store, fts(3))

                    this.pos.x, this.pos.y = new_pos.x, new_pos.y
                    this.nav_rally.center = V.vclone(this.pos)
                    this.nav_rally.pos = V.vclone(this.pos)

                    SU.hero_gain_xp_from_skill(this, this.hero.skills.disengage)
                    U.y_animation_play(this, this.dodge.animation_appear, nil, store.tick_ts)

                    this.vis.bans = bans
                    this.vis._bans = nil

                    SU.show_modifiers(store, this, true)
                    SU.show_auras(store, this, true)
                    U.animation_start(this, "idle", nil, store.tick_ts, true)
                end
            end

            brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

            if brk or stam ~= A_NO_TARGET then
                -- block empty
            else
                if store.tick_ts - basic_ranged.ts >= basic_ranged.cooldown then
                    local enemy, enemies, enemy_pos = U.find_foremost_enemy(store, this.pos,
                        basic_ranged.min_range, basic_ranged.max_range, basic_ranged.node_prediction,
                        basic_ranged.vis_flags, basic_ranged.vis_bans)

                    if not enemy then
                        SU.delay_attack(store, basic_ranged, fts(10))
                    else
                        local start_ts = store.tick_ts
                        local enemy_id = enemy.id

                        S:queue(basic_ranged.sound)

                        local an, af, _ = U.animation_name_facing_point(this, basic_ranged.animation, enemy_pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if SU.y_hero_wait(store, this, basic_ranged.shoot_time) then
                            -- block empty
                        else
                            for i = 1, #basic_ranged.bullets do
                                local bullet = E:create_entity(basic_ranged.bullets[i])
                                bullet.bullet.damage_min = bullet.bullet.damage_min + this.damage_buff
                                bullet.bullet.damage_max = bullet.bullet.damage_max + this.damage_buff
                                bullet.bullet.damage_factor = this.unit.damage_factor
                                bullet.bullet.source_id = this.id
                                bullet.bullet.to = enemy_pos
                                bullet.bullet.target_id = store.entities[enemy_id] and enemy_id or nil

                                local start_offset = basic_ranged.bullet_start_offset[af and 2 or 1][i]

                                bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
                                bullet.bullet.xp_dest_id = this.id
                                bullet.bullet.xp_gain_factor = basic_ranged.xp_gain_factor
                                bullet.pos = V.vclone(bullet.bullet.from)

                                queue_insert(store, bullet)
                            end

                            basic_ranged.ts = start_ts

                            if SU.y_hero_animation_wait(this) then
                                -- block empty
                            end
                        end
                    end
                end

                a = this.timed_attacks.list[2]

                if ready_to_use_skill(a, store) and store.tick_ts - last_ts > a.min_cooldown then
                    local enemy, enemies = U.find_foremost_enemy(store, this.pos, 0, a.range, false,
                        a.vis_flags, a.vis_bans, function(e)
                            return e.health and e.health.hp_max <= a.hp_max and P:nodes_to_goal(e.nav_path) >=
                                       a.max_nodes_to_goal
                        end)

                    if not enemy then
                        SU.delay_attack(store, a, fts(10))
                    else
                        local start_ts = store.tick_ts
                        local enemy_pos = V.vclone(enemy.pos)
                        local enemy_id = enemy.id
                        local an, af, _ = U.animation_name_facing_point(this, a.animation, enemy_pos)

                        U.animation_start(this, an, af, store.tick_ts, false)

                        if SU.y_hero_wait(store, this, a.shoot_time) then
                            -- block empty
                        else
                            local bullet = E:create_entity(a.bullet)

                            bullet.bullet.damage_factor = this.unit.damage_factor
                            bullet.bullet.source_id = this.id
                            bullet.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            bullet.bullet.target_id = store.entities[enemy_id] and enemy_id or nil

                            local start_offset = a.bullet_start_offset[af and 1 or 2]

                            bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
                            bullet.bullet.xp_dest_id = this.id
                            bullet.bullet.xp_gain_factor = basic_ranged.xp_gain_factor
                            bullet.bullet.level = this.hero.skills.polymorph.level
                            bullet.pos = V.vclone(bullet.bullet.from)
                            bullet.pred_pos = enemy_pos
                            bullet.source_id = this.id

                            queue_insert(store, bullet)

                            a.ts = start_ts
                            last_ts = start_ts

                            SU.hero_gain_xp_from_skill(this, this.hero.skills.polymorph)
                            SU.y_hero_animation_wait(this)
                        end
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
        end

        ::label_641_0::

        coroutine.yield()
    end
end

scripts.hero_witch_ultimate = {}

function scripts.hero_witch_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, {1}, true)

    if #nodes < 1 then
        return false
    end

    local pi, spi, ni = unpack(nodes[1])
    local npos = P:node_pos(pi, spi, ni)

    S:queue(this.sound_cast)

    local d = E:create_entity(this.teleport_decal)

    d.pos = V.vclone(npos)
    d.render.sprites[1].ts = store.tick_ts

    queue_insert(store, d)
    U.y_wait(store, fts(5))

    local target, targets = U.find_nearest_enemy(store, npos, 0, this.radius, this.vis_flags, this.vis_bans)

    if not target or not targets or #targets < 1 then
        return true
    end

    local num_targets = math.min(#targets, this.max_targets)

    for i = 1, num_targets do
        local t = targets[i]
        local mod_mark = E:create_entity(this.mod_mark)

        mod_mark.modifier.target_id = t.id
        mod_mark.modifier.source_id = this.id

        queue_insert(store, mod_mark)
        S:queue(this.sound_teleport_in)

        local mod_teleport = E:create_entity(this.mod_teleport)

        mod_teleport.modifier.target_id = t.id
        mod_teleport.modifier.source_id = this.id

        queue_insert(store, mod_teleport)
        S:queue(this.sound_teleport_out, {
            delay = mod_teleport.hold_time
        })
    end

    queue_remove(store, this)
end

scripts.mod_hero_witch_ultimate_teleport = {}

function scripts.mod_hero_witch_ultimate_teleport.remove(this, store)
    local target = store.entities[this.modifier.target_id]

    if target then
        target.health.ignore_damage = false

        SU.stun_dec(target)

        local mod_sleep = E:create_entity(this.end_mod)

        mod_sleep.modifier.target_id = target.id
        mod_sleep.modifier.source_id = this.source_id

        queue_insert(store, mod_sleep)
    end

    return true
end

scripts.bullet_hero_witch_basic = {}

function scripts.bullet_hero_witch_basic.insert(this, store, script)
    local b = this.bullet

    if this.impulse_per_distance then
        local dx, dy = V.sub(b.to.x, b.to.y, b.from.x, b.from.y)
        local dist = V.len(dx, dy)

        this.initial_impulse = this.impulse_per_distance * dist
    end

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

    U.animation_start(this, "flying", nil, store.tick_ts, s.loop)

    return true
end

function scripts.bullet_hero_witch_basic.update(this, store)
    local b = this.bullet
    local fm = this.force_motion
    local target = store.entities[b.target_id]
    local ps

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

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.emit = true
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    local pred_pos

    if target then
        pred_pos = P:predict_enemy_pos(target, fts(5))
    else
        pred_pos = b.to
    end

    local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
    local last_pos = V.vclone(this.pos)

    b.ts = store.tick_ts

    while true do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
            local hit_offset = V.v(0, 0)

            if not b.ignore_hit_offset then
                hit_offset.x = target.unit.hit_offset.x
                hit_offset.y = target.unit.hit_offset.y
            end

            local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x),
                math.abs(target.pos.y + hit_offset.y - b.to.y))

            if d > b.max_track_distance then
                log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id,
                    this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

                target = nil
                b.target_id = nil
            else
                b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
            end
        end

        if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
            local t = store.tick_ts - b.ts

            if this.initial_impulse_angle_abs then
                fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
            else
                local angle = this.initial_impulse_angle

                if iix < 0 then
                    angle = angle * -1
                end

                fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
            end
        end

        last_pos.x, last_pos.y = this.pos.x, this.pos.y

        if move_step(b.to) then
            break
        end

        if b.align_with_trajectory then
            this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
        end

        coroutine.yield()
    end

    if target and not target.health.dead then
        local d = SU.create_bullet_damage(b, target.id, this.id)

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
    elseif b.damage_radius and b.damage_radius > 0 then
        local targets = U.find_enemies_in_range(store, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = SU.create_bullet_damage(b, target.id, this.id)

                queue_damage(store, d)
            end
        end
    end

    this.render.sprites[1].hidden = true

    if b.hit_fx then
        local fx = E:create_entity(b.hit_fx)

        fx.pos.x, fx.pos.y = b.to.x, b.to.y
        fx.render.sprites[1].ts = store.tick_ts
        fx.render.sprites[1].runs = 0

        queue_insert(store, fx)
    end

    if b.hit_decal then
        local decal = E:create_entity(b.hit_decal)

        decal.pos = V.vclone(b.to)
        decal.render.sprites[1].ts = store.tick_ts

        queue_insert(store, decal)
    end

    if ps and ps.particle_system.emit then
        ps.particle_system.emit = false

        U.y_wait(store, ps.particle_system.particle_lifetime[2])
    end

    queue_remove(store, this)
end

scripts.aura_hero_witch_path_aoe = {}

function scripts.aura_hero_witch_path_aoe.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

    this.tween.disabled = false
    this.tween.ts = store.tick_ts
    this.tween.props[1].ts = store.tick_ts
    this.tween.props[2].ts = store.tick_ts
    this.tween.props[3].ts = store.tick_ts

    local start_fx = E:create_entity(this.start_fx)

    start_fx.pos = V.vclone(this.pos)
    start_fx.render.sprites[1].ts = store.tick_ts
    start_fx.render.sprites[1].runs = 0
    start_fx.render.sprites[2].ts = store.tick_ts
    start_fx.render.sprites[2].runs = 0

    queue_insert(store, start_fx)
    U.y_wait(store, this.start_wait_time)
    S:queue(this.sound_impact)

    local targets = table.filter(store.enemies, function(k, v)
        return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and
                   band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                   (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and
                   (not this.aura.excluded_templates or
                       not table.contains(this.aura.excluded_templates, v.template_name)) and
                   (not this.aura.filter_source or this.aura.source_id ~= v.id)
    end)

    for i, target in ipairs(targets) do
        local d = E:create_entity("damage")

        d.damage_type = this.damage_type
        d.value = math.random(this.damage_min, this.damage_max) * this.aura.damage_factor
        d.source_id = this.id
        d.target_id = target.id

        queue_damage(store, d)
    end

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration then
            break
        end

        if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
            break
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) ==
                           0 and band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                if this.aura.max_count and victims_count >= this.aura.max_count then
                    break
                end

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

        ::label_651_0::

        coroutine.yield()
    end

    signal.emit("aura-apply-mod-victims", this, victims_count)
    queue_remove(store, this)
end

scripts.bullet_witch_skill_polymorph = {}

function scripts.bullet_witch_skill_polymorph.update(this, store, script)
    local b = this.bullet
    local s = this.render.sprites[1]
    local mspeed = b.min_speed
    local target, ps
    local new_target = false
    local target_invalid = false

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    ::label_654_0::

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

            goto label_654_0
        end
    end

    this.pos.x, this.pos.y = b.to.x, b.to.y

    if target and not target.health.dead then
        local d = SU.create_bullet_damage(b, target.id, this.id)

        queue_damage(store, d)

        if b.mod or b.mods then
            local mods = b.mods or {b.mod}

            for _, mod_name in pairs(mods) do
                local m = E:create_entity(mod_name)

                m.modifier.target_id = b.target_id
                m.modifier.source_id = this.source_id
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

scripts.mod_hero_witch_skill_polymorph = {}

function scripts.mod_hero_witch_skill_polymorph.insert(this, store)
    local target = store.entities[this.modifier.target_id]
    local hero = store.entities[this.modifier.source_id]

    if target then
        this.target_ref = target

        for _, s in ipairs(target.render.sprites) do
            s.hidden = true
        end

        hero.polymorph_enemy = {
            enemy = target
        }

        SU.remove_modifiers(store, target)
        SU.remove_auras(store, target)
        queue_remove(store, target)
        U.unblock_all(store, target)

        if target.ui then
            target.ui.can_click = false
        end

        target.main_script.co = nil
        target.main_script.runs = 0

        if target.count_group then
            target.count_group.in_limbo = true
        end

        target.trigger_deselect = true

        local is_flying = U.flag_has(target.vis.flags, F_FLYING)
        local pumpkin = E:create_entity(is_flying and this.entity_t_flying or this.entity_t)

        pumpkin.pos = target.pos
        pumpkin.nav_path = target.nav_path
        pumpkin.health.hp_max = target.health.hp_max * this.entity_hp[this.modifier.level]
        pumpkin.health.hp = target.health.hp * this.entity_hp[this.modifier.level]
        pumpkin.enemy.gold = target.enemy.gold

        queue_insert(store, pumpkin)

        hero.polymorph_enemy.pumpkin = pumpkin

        return true
    end

    return false
end

function scripts.mod_hero_witch_skill_polymorph.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = this.target_ref

    this.pos = target.pos

    while true do
        if m.duration >= 0 and store.tick_ts - m.ts > m.duration then
            queue_remove(store, this)

            return
        end

        coroutine.yield()
    end
end

function scripts.mod_hero_witch_skill_polymorph.remove(this, store)
    local hero = store.entities[this.modifier.source_id]

    if hero and hero.polymorph_enemy and hero.polymorph_enemy.enemy then
        local target = hero.polymorph_enemy.enemy
        local pumpkin = hero.polymorph_enemy.pumpkin

        if pumpkin and store.entities[pumpkin.id] and not pumpkin.health.dead then
            for _, s in ipairs(target.render.sprites) do
                s.hidden = false
            end

            target.main_script.runs = 1

            if target.ui then
                target.ui.can_click = true
            end

            target.pos = V.vclone(pumpkin.pos)
            target.nav_path = pumpkin.nav_path
            target.health.hp = target.health.hp_max * pumpkin.health.hp / pumpkin.health.hp_max

            queue_insert(store, target)

            pumpkin.trigger_deselect = true

            S:queue(this.sound_transform_out)

            local sfx = E:create_entity(this.transform_fx)

            sfx.pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
            sfx.render.sprites[1].ts = store.tick_ts
            sfx.render.sprites[1].runs = 0

            if target and sfx.render.sprites[1].size_names then
                sfx.render.sprites[1].name = sfx.render.sprites[1].size_names[target.unit.size]
            end

            queue_insert(store, sfx)
            queue_remove(store, pumpkin)
        end

        hero.polymorph_enemy = nil
    end

    return true
end

scripts.aura_hero_witch_decoy_explotion = {}

function scripts.aura_hero_witch_decoy_explotion.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

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

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts -
            this.aura.ts > this.actual_duration then
            break
        end

        if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
            break
        end

        if this.aura.requires_magic then
            local te = store.entities[this.aura.source_id]

            if not te or not te.enemy then
                goto label_658_0
            end

            if this.render then
                this.render.sprites[1].hidden = not te.enemy.can_do_magic
            end

            if not te.enemy.can_do_magic then
                goto label_658_0
            end
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and
            store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            if this.render and this.aura.cast_resets_sprite_id then
                this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
            end

            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = table.filter(store.enemies, function(k, v)
                return not v.health.dead and band(v.vis.flags, this.aura.vis_bans) ==
                           0 and band(v.vis.bans, this.aura.vis_flags) == 0 and
                           U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and
                           (not this.aura.allowed_templates or
                               table.contains(this.aura.allowed_templates, v.template_name)) and
                           (not this.aura.excluded_templates or
                               not table.contains(this.aura.excluded_templates, v.template_name)) and
                           (not this.aura.filter_source or this.aura.source_id ~= v.id)
            end)

            for i, target in ipairs(targets) do
                if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
                    break
                end

                if this.aura.max_count and victims_count >= this.aura.max_count then
                    break
                end

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

        ::label_658_0::

        coroutine.yield()
    end

    signal.emit("aura-apply-mod-victims", this, victims_count)
    queue_remove(store, this)
end

scripts.soldier_hero_witch_decoy = {}

function scripts.soldier_hero_witch_decoy.update(this, store, script)
    local brk, stam, star

    this.reinforcement.ts = store.tick_ts
    this.render.sprites[1].ts = store.tick_ts

    if this.reinforcement.fade or this.reinforcement.fade_in then
        SU.y_reinforcement_fade_in(store, this)
    elseif this.render.sprites[1].name == "raise" then
        if this.sound_events and this.sound_events.raise then
            S:queue(this.sound_events.raise)
        end

        this.health_bar.hidden = true

        U.y_animation_play(this, "raise", nil, store.tick_ts, 1)

        if not this.health.dead then
            this.health_bar.hidden = nil
        end
    end

    local function y_custom_death(store, this)
        U.unblock_target(store, this)
        S:queue(this.sound_death)

        local can_spawn = this.death_spawns and
                              band(this.health.last_damage_types,
                bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, this.death_spawns.no_spawn_damage_types or 0)) == 0

        if can_spawn and this.death_spawns.concurrent_with_death then
            SU.do_death_spawns(store, this)
            coroutine.yield()

            can_spawn = false
        end

        local h = this.health

        if band(h.last_damage_types, bor(DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE)) ~= 0 then
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
            SU.y_reinforcement_fade_out(store, this)

            return
        else
            S:queue(this.sound_events.death, this.sound_events.death_args)
            U.y_animation_play(this, "death", nil, store.tick_ts, 1)

            this.ui.can_select = false
        end

        this.health.death_finished_ts = store.tick_ts

        if this.ui then
            -- if IS_TRILOGY then
            --     this.ui.can_click = not this.unit.hide_after_death
            -- else
            this.ui.can_click = this.ui.can_click and not this.unit.hide_after_death
            -- end

            this.ui.z = -1
        end

        if this.unit.hide_during_death or this.unit.hide_after_death then
            for _, s in pairs(this.render.sprites) do
                s.hidden = true
            end
        end

        if this.unit.fade_time_after_death then
            local delay = this.unit.fade_time_after_death
            local duration = this.unit.fade_duration_after_death

            if this.health and this.health.delete_after and duration then
                delay = this.health.delete_after - store.tick_ts - duration
            end

            SU.fade_out_entity(store, this, delay, duration)
        end
    end

    while true do
        if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts >
            this.reinforcement.duration then
            if this.health.hp > 0 then
                this.reinforcement.hp_before_timeout = this.health.hp
            end

            this.health.hp = 0

            -- if IS_KR5 then
                SU.remove_modifiers(store, this)
            -- end

            y_custom_death(store, this)

            return
        end

        if this.unit.is_stunned then
            SU.soldier_idle(store, this)
        else
            SU.soldier_courage_upgrade(store, this)

            if this.melee then
                brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

                if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
                    goto label_660_1
                end
            end

            if this.ranged then
                brk, star = SU.y_soldier_ranged_attacks(store, this)

                if brk or star == A_DONE then
                    goto label_660_1
                elseif star == A_IN_COOLDOWN then
                    goto label_660_0
                end
            end

            if this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
                goto label_660_1
            end

            if SU.soldier_go_back_step(store, this) then
                goto label_660_1
            end

            ::label_660_0::

            SU.soldier_idle(store, this)
            SU.soldier_regen(store, this)
        end

        ::label_660_1::

        coroutine.yield()
    end
end

scripts.hero_dragon_bone = {}

function scripts.hero_dragon_bone.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)

    local b = E:get_template(this.ranged.attacks[1].bullet)

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    upgrade_skill(this, "cloud", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local b = E:get_template(a.bullet)
        local aura = E:get_template(b.bullet.hit_payload)

        aura.aura.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "nova", function(this, s)
        local a = this.ranged.attacks[3]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.damage_min = s.damage_min[s.level]
        a.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "rain", function(this, s)
        local a = this.ranged.attacks[4]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local b = E:get_template(a.entity)

        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]
        a.bones = s.bones_count[s.level]
    end)

    upgrade_skill(this, "burst", function(this, s)
        local a = this.ranged.attacks[5]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
        a.proj_count = s.proj_count[s.level]

        local bullet = E:get_template(a.bullet)

        bullet.bullet.damage_min = s.damage_min[s.level]
        bullet.bullet.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local u = this.ultimate

        u.disabled = nil

        local uc = E:get_template(s.controller_name)

        uc.cooldown = s.cooldown[s.level]

        local dog = E:get_template(uc.dog)

        dog.reinforcement.duration = s.duration[s.level]
        dog.health.hp_max = s.hp[s.level]
        dog.melee.attacks[1].damage_min = s.damage_min[s.level]
        dog.melee.attacks[1].damage_max = s.damage_max[s.level]
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_dragon_bone.insert(this, store)
    this.hero.fn_level_up(this, store, true)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_dragon_bone.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill
    local shots_with_mod = 0
    local basic_ranged = this.ranged.attacks[1]
    local cloud_attack = this.ranged.attacks[2]
    local nova_attack = this.ranged.attacks[3]
    local rain_attack = this.ranged.attacks[4]
    local burst_attack = this.ranged.attacks[5]
    local upg_lf = UP:get_upgrade("heroes_lethal_focus")

    SU.hero_spawning_set_skill_ts(this, store)

    this.tween.disabled = false
    this.tween.ts = store.tick_ts
    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts - fts(4), this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            SU.y_hero_death_and_respawn(store, this)
            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            local r = this.nav_rally
            local start_pos = V.vclone(this.pos)

            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end

        a = this.ultimate

        if ready_to_use_skill(a, store) then
            local target = U.find_foremost_enemy(store, this.pos, basic_ranged.min_range, basic_ranged.max_range, nil, 0, a.vis_bans)
            if target and valid_rally_node_nearby(target.pos) then
                apply_ultimate(this, store, target, "levelup")
            else
                a.ts = a.ts + 1
            end
        end

        skill = this.hero.skills.cloud
        a = cloud_attack

        if ready_to_use_skill(a, store) then
            local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range,
                a.max_range, a.shoot_time + fts(10), a.vis_flags, a.vis_bans, function(v, o)
                    return GR:cell_is(v.pos.x, v.pos.y, TERRAIN_LAND)
                end)

            if not targets or not pred_pos or #targets < a.min_targets then
                SU.delay_attack(store, a, 0.4)

                goto label_664_4
            end

            local target = targets[1]
            local start_ts = store.tick_ts
            local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)

            S:queue(a.sound)
            U.animation_start(this, an, af, store.tick_ts)

            if SU.y_hero_wait(store, this, a.shoot_time) then
                goto label_664_4
            end

            local b = E:create_entity(a.bullet)

            b.bullet.target_id = target.id
            b.bullet.source_id = this.id
            b.pos = V.vclone(this.pos)

            local offset_index = af and 2 or 1
            local bullet_start_offset = a.bullet_start_offset[offset_index]

            b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
            b.pos.y = b.pos.y + bullet_start_offset.y
            b.bullet.from = V.vclone(b.pos)
            b.bullet.to = V.vclone(pred_pos)

            queue_insert(store, b)

            a.ts = start_ts

            SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

            if SU.y_hero_animation_wait(this) then
                goto label_664_4
            end
        end

        skill = this.hero.skills.nova
        a = nova_attack

        if ready_to_use_skill(a, store) then
            if not GR:cell_is(this.pos.x, this.pos.y, TERRAIN_LAND) then
                goto label_664_4
            end

            local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range,
                a.max_range, a.hit_time, a.vis_flags, a.vis_bans_target, function(v, o)
                return GR:cell_is(v.pos.x, v.pos.y, TERRAIN_LAND)
            end)

            if not targets or not pred_pos or #targets < a.min_targets then
                SU.delay_attack(store, a, 0.2)

                goto label_664_4
            end

            local target = targets[1]
            local start_ts = store.tick_ts
            local an, af, ai = U.animation_name_facing_point(this, a.animation, pred_pos)

            S:queue(a.sound)
            U.animation_start(this, an, af, store.tick_ts)

            if SU.y_hero_wait(store, this, a.hit_time) then
                goto label_664_4
            end

            local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius, a
            .vis_flags, a.vis_bans_damage)

            if targets then
                for i, v in ipairs(targets) do
                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = v.id

                    local dist_factor = U.dist_factor_inside_ellipse(v.pos, this.pos, a.damage_radius)

                    d.value = math.floor(a.damage_max - (a.damage_max - a.damage_min) * dist_factor)
                    d.value = d.value * this.unit.damage_factor
                    d.damage_type = a.damage_type

                    queue_damage(store, d)

                    local m = E:create_entity(a.mod)

                    m.modifier.target_id = v.id
                    m.modifier.source_id = this.id

                    queue_insert(store, m)
                end
            end

            a.ts = start_ts

            SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
            SU.y_hero_animation_wait(this)
            U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

            goto label_664_4
        end

        skill = this.hero.skills.rain
        a = rain_attack

        if ready_to_use_skill(a, store) then
            local target = U.find_random_enemy(store, this.pos, a.min_range, a.max_range,
                a.vis_flags, a.vis_bans)

            if not target then
                SU.delay_attack(store, a, 0.4)

                goto label_664_4
            end

            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
                pi
            }, nil, nil, NF_RALLY)

            if #nodes < 1 then
                SU.delay_attack(store, a, 0.4)

                goto label_664_4
            end

            local s_pi, s_spi, s_ni = unpack(nodes[1])

            S:queue(a.sound)

            local flip = target.pos.x < this.pos.x

            U.animation_start(this, a.animation, flip, store.tick_ts)

            if SU.y_hero_wait(store, this, a.spawn_time) then
                goto label_664_4
            end

            local delay = 0
            local n_step = ni < s_ni and -2 or 2

            ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

            for i = 1, a.bones do
                local e = E:create_entity(a.entity)

                e.pos = P:node_pos(pi, spi, ni)

                local types = {
                    "a",
                    "b",
                    "c"
                }
                local type = types[math.random(1, 3)]

                e.bone_type = type
                e.render.sprites[1].flip_x = flip
                e.render.sprites[2].flip_x = flip
                e.delay = delay
                e.bullet.source_id = this.id

                queue_insert(store, e)

                delay = delay + fts(U.frandom(1, 3))
                ni = ni + n_step
                spi = km.zmod(spi + math.random(1, 2), 3)
            end

            U.y_animation_wait(this)

            a.ts = store.tick_ts

            SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

            goto label_664_4
        end

        skill = this.hero.skills.burst
        a = burst_attack

        if ready_to_use_skill(a, store) then
            local target, targets, pred_pos = U.find_foremost_enemy(store, this.pos, a.min_range,
                a.max_range, a.spawn_time + a.node_prediction, a.vis_flags, a.vis_bans_target, function(v, o)
                return GR:cell_is(v.pos.x, v.pos.y, bor(TERRAIN_LAND, TERRAIN_ICE))
            end)

            if not target or not targets or #targets < a.min_targets then
                SU.delay_attack(store, a, 0.4)
            else
                S:queue(a.sound)

                local flip = target.pos.x < this.pos.x

                U.animation_start(this, a.animation, flip, store.tick_ts)

                if SU.y_hero_wait(store, this, a.spawn_time) then
                    goto label_664_4
                end

                local function shuffle_table(nodes)
                    for i = #nodes, 2, -1 do
                        local j = math.random(i)

                        nodes[i], nodes[j] = nodes[j], nodes[i]
                    end

                    return nodes
                end

                local function shoot_bullet_to_target(target)
                    local node_offset = P:predict_enemy_node_advance(target, a.node_prediction)
                    local e_ni = target.nav_path.ni + node_offset
                    local e_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, e_ni)
                    local b = E:create_entity(a.bullet)

                    b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x,
                        this.pos.y + a.bullet_start_offset.y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = e_pos
                    b.bullet.damage_factor = this.unit.damage_factor
                    b.bullet.source_id = this.id
                    b.bullet.target_id = target.id

                    queue_insert(store, b)
                end

                local function shoot_bullet_to_pos(pos)
                    local b = E:create_entity(a.bullet)

                    b.pos.x, b.pos.y = this.pos.x + a.bullet_start_offset.x,
                        this.pos.y + a.bullet_start_offset.y
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = pos
                    b.bullet.source_id = this.id
                    b.bullet.damage_factor = this.unit.damage_factor
                    queue_insert(store, b)
                end

                local selected_targets = {}
                local selected_positions = {}
                local max_dist2 = a.max_dist_between_tgts * a.max_dist_between_tgts

                for i = 1, a.proj_count do
                    if not targets or #targets == 0 or #selected_targets > a.proj_count / 2 then
                        goto label_664_1
                    end

                    local sel_target = targets[1]

                    table.insert(selected_targets, sel_target)
                    table.remove(targets, 1)

                    -- for i = #targets, 1, -1 do
                    --     local e = targets[i]
                    --     local dz = this.danger_zones
                    --     local sd2 = this.safe_dist2

                    --     if max_dist2 > V.dist2(sel_target.pos.x, sel_target.pos.y, e.pos.x, e.pos.y) then
                    --         table.remove(targets, i)
                    --     end
                    -- end
                end

                if #selected_targets == a.proj_count then
                    goto label_664_2
                end

                ::label_664_1::

                do
                    local nodes = P:get_all_valid_pos(this.pos.x, this.pos.y, 0, a.max_range, nil, nil, nil,
                        {
                            1
                        })

                    shuffle_table(nodes)

                    for i = #selected_targets + 1, a.proj_count do
                        local sel_node = nodes[1]

                        table.insert(selected_positions, sel_node)
                        table.remove(nodes, 1)

                        for i = #nodes, 1, -1 do
                            local n = nodes[i]

                            if max_dist2 > V.dist2(sel_node.x, sel_node.y, n.x, n.y) then
                                table.remove(nodes, i)
                            end
                        end
                    end
                end

                ::label_664_2::

                shuffle_table(selected_targets)

                for _, t in pairs(selected_targets) do
                    shoot_bullet_to_target(t)
                    U.y_wait(store, a.wait_between_shots)
                end

                shuffle_table(selected_positions)

                for _, p in pairs(selected_positions) do
                    shoot_bullet_to_pos(p)
                    U.y_wait(store, a.wait_between_shots)
                end

                U.y_animation_wait(this)

                a.ts = store.tick_ts

                SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

                goto label_664_4
            end
        end

        a = basic_ranged

        if ready_to_use_skill(a, store) then
            local bullet_t = E:get_template(a.bullet)
            local flight_time = a.estimated_flight_time or 1
            local pos_offset = v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
            local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                a.vis_flags, a.vis_bans, function(e)
                return V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > a.radius * a.radius
            end)

            if targets then
                local target = targets[1]
                local start_ts = store.tick_ts
                local b, targets
                local node_offset = P:predict_enemy_node_advance(target, flight_time)
                local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi,
                    target.nav_path.ni + node_offset)
                local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                U.animation_start(this, an, af, store.tick_ts)
                S:queue(a.start_sound, a.start_sound_args)

                while store.tick_ts - start_ts < a.shoot_time do
                    if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                        goto label_664_0
                    end

                    coroutine.yield()
                end

                targets = {
                    target
                }
                b = E:create_entity(a.bullet)
                b.bullet.target_id = target.id
                b.bullet.source_id = this.id
                b.bullet.xp_dest_id = this.id
                b.pos = V.vclone(this.pos)

                if a.bullet_start_offset and #a.bullet_start_offset == 2 then
                    local bullet_start_offset = v(0, 0)

                    if #a.bullet_start_offset == 2 then
                        local offset_index = af and 2 or 1

                        bullet_start_offset = a.bullet_start_offset[offset_index]
                    else
                        bullet_start_offset = V.vclone(a.bullet_start_offset)
                    end

                    b.pos.x = b.pos.x + (af and -1 or 1) * bullet_start_offset.x
                    b.pos.y = b.pos.y + bullet_start_offset.y
                end

                b.bullet.from = V.vclone(b.pos)

                if b.bullet.ignore_hit_offset then
                    b.bullet.to = V.v(target.pos.x, target.pos.y)
                else
                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                        target.pos.y + target.unit.hit_offset.y)
                end

                b.bullet.shot_index = i

                b.bullet.damage_factor = this.unit.damage_factor

                if upg_lf then
                    if not this._lethal_focus_deck then
                        this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
                    end

                    local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)

                    if triggered_lethal_focus then
                        b.bullet.damage_factor = b.bullet.damage_factor * upg_lf.damage_factor_area
                        b.bullet.pop = {
                            "pop_crit"
                        }
                        b.bullet.pop_chance = 1
                        b.bullet.pop_conds = DR_DAMAGE
                    end
                end

                queue_insert(store, b)

                if a.xp_from_skill then
                    SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                end

                a.ts = start_ts

                while not U.animation_finished(this) do
                    if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                        goto label_664_0
                    end

                    coroutine.yield()
                end

                a.ts = start_ts

                U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts,
                    this.idle_flip.loop, nil, true)

                ::label_664_0::

                goto label_664_4
            end
        end

        ::label_664_4::

        SU.soldier_idle(store, this)
        SU.soldier_regen(store, this)

        coroutine.yield()
    end
end

scripts.bolt_dragon_bone_basic_attack = {}

function scripts.bolt_dragon_bone_basic_attack.update(this, store, script)
    local b = this.bullet
    local s = this.render.sprites[1]
    local mspeed = b.min_speed
    local target, ps
    local new_target = false
    local target_invalid = false
    local target = store.entities[b.target_id]

    if not target then
        queue_remove(store, this)

        return
    end

    local is_flying = U.flag_has(target.vis.flags, F_FLYING)

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    b.hit_fx = is_flying and b.hit_fx_flying or b.hit_fx_floor
    b.ignore_hit_offset = not is_flying

    S:queue(this.sound_events.travel)

    s.z = Z_BULLETS
    s.sort_y_offset = nil

    U.animation_start(this, "idle", nil, store.tick_ts, true)

    if ps then
        ps.particle_system.emit = true
    end

    while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length * (mspeed * store.tick_length) do
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
            b.to = V.vclone(target.pos)

            if not b.ignore_hit_offset then
                b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
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

    this.pos = V.vclone(b.to)

    S:queue(this.sound_events.hit)

    local function explosion(r, damage_min, damage_max, dty)
        local target_bans = bit.bor(F_FLYING)
        local target_pos = V.vclone(this.pos)

        if is_flying then
            target_bans = 0

            if target and target.flight_height then
                target_pos.y = target_pos.y - target.flight_height
            end
        end

        local targets = U.find_enemies_in_range(store, target_pos, 0, r, 0, target_bans)

        if targets then
            for _, target in pairs(targets) do
                local d = E:create_entity("damage")

                d.value = math.random(damage_min, damage_max)
                d.damage_type = dty
                d.target_id = target.id
                d.source_id = b.source_id
                d.xp_gain_factor = b.xp_gain_factor
                d.xp_dest_id = b.source_id

                queue_damage(store, d)

                if b.mod then
                    local mod = E:create_entity(b.mod)

                    mod.modifier.target_id = target.id
                    mod.modifier.source_id = b.source_id
                    mod.xp_dest_id = b.source_id

                    queue_insert(store, mod)
                end
            end
        end
    end

    local p = SU.create_bullet_pop(store, this)

    if p then
        queue_insert(store, p)
    end

    explosion(this.damage_range, b.damage_min, b.damage_max, b.damage_type)

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

scripts.mod_dragon_bone_plague = {}

function scripts.mod_dragon_bone_plague.remove(this, store)
    local target = store.entities[this.modifier.target_id]

    if target and target.health.dead and band(target.health.last_damage_types, DAMAGE_EAT) == 0 then
        local targets = U.find_enemies_in_range(store, this.pos, 0, this.spread_radius, this.modifier.vis_flags,
            this.modifier.vis_bans)

        if targets then
            for _, t in pairs(targets) do
                local m = E:create_entity(this.template_name)

                m.modifier.target_id = t.id
                m.modifier.source_id = this.modifier.source_id
                m.modifier.xp_dest_id = this.modifier.xp_dest_id

                queue_insert(store, m)

                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = t.id
                d.damage_type = this.dps.damage_type

                local dmin, dmax = this.spread_damage_min, this.spread_damage_max
                local dist_factor = U.dist_factor_inside_ellipse(t.pos, target.pos, this.spread_radius)

                d.value = math.floor(dmax - (dmax - dmin) * dist_factor) * this.modifier.damage_factor

                queue_damage(store, d)
            end
        end

        local fx = E:create_entity(this.spread_fx)

        fx.pos = V.vclone(this.pos)

        if target and this.modifier.use_mod_offset and target.unit.mod_offset then
            local mo = target.unit.mod_offset

            fx.pos.x, fx.pos.y = fx.pos.x + mo.x, fx.pos.y + mo.y
            fx.render.sprites[1].sort_y_offset = -mo.y
        end

        fx.render.sprites[1].ts = store.tick_ts

        queue_insert(store, fx)
    end

    return true
end

scripts.bullet_dragon_bone_cloud = {}

function scripts.bullet_dragon_bone_cloud.update(this, store)
    local b = this.bullet
    local s = this.render.sprites[1]
    local target = store.entities[b.target_id]
    local dest = V.vclone(b.to)

    s.scale = s.scale or V.v(1, 1)
    s.ts = store.tick_ts

    local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

    s.r = angle

    local dist_offset = 0

    if this.dist_offset then
        dist_offset = this.dist_offset
    end

    s.scale.x = (V.dist(dest.x, dest.y, this.pos.x, this.pos.y) + dist_offset) / this.image_width

    U.y_wait(store, b.hit_time)

    local hp = E:create_entity(b.hit_payload)

    hp.aura.level = this.bullet.level
    hp.aura.source_id = this.id
    hp.pos = V.vclone(dest)

    queue_insert(store, hp)
    U.y_animation_wait(this)
    queue_remove(store, this)
end

scripts.aura_dragon_bone_cloud = {}

function scripts.aura_dragon_bone_cloud.update(this, store, script)
    local first_hit_ts
    local last_hit_ts = 0
    local cycles_count = 0
    local victims_count = 0

    last_hit_ts = store.tick_ts - this.aura.cycle_time

    if this.aura.apply_delay then
        last_hit_ts = last_hit_ts + this.aura.apply_delay
    end

    this.tween.ts = store.tick_ts

    local nearest_nodes = P:nearest_nodes(this.pos.x, this.pos.y)
    local pi, spi, ni = unpack(nearest_nodes[1])
    local cloud_1 = E:create_entity(this.decal_cloud_t)

    cloud_1.pos = P:node_pos(pi, 1, ni + 3)
    cloud_1.tween.ts = store.tick_ts

    queue_insert(store, cloud_1)

    local cloud_2 = E:create_entity(this.decal_cloud_t)

    cloud_2.pos = P:node_pos(pi, 1, ni - 3)
    cloud_2.tween.ts = store.tick_ts

    queue_insert(store, cloud_2)

    local cloud_3 = E:create_entity(this.decal_cloud_t)

    cloud_3.pos = P:node_pos(pi, 2, ni)
    cloud_3.tween.ts = store.tick_ts

    queue_insert(store, cloud_3)

    local cloud_4 = E:create_entity(this.decal_cloud_t)

    cloud_4.pos = P:node_pos(pi, 3, ni)
    cloud_4.tween.ts = store.tick_ts

    queue_insert(store, cloud_4)

    while true do
        if this.interrupt then
            last_hit_ts = 1e+99
        end

        if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
            break
        end

        if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
            -- block empty
        else
            first_hit_ts = first_hit_ts or store.tick_ts
            last_hit_ts = store.tick_ts
            cycles_count = cycles_count + 1

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.aura.radius, this.aura.vis_flags,
                this.aura.vis_bans)

            if targets then
                for i, target in ipairs(targets) do
                    local mods = this.aura.mods or {
                        this.aura.mod
                    }

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

    this.tween.reverse = true
    this.tween.remove = true
    this.tween.ts = store.tick_ts

    local clouds = {
        cloud_1,
        cloud_2,
        cloud_3,
        cloud_4
    }

    for i, v in ipairs(clouds) do
        v.tween.reverse = true
        v.tween.remove = true
        v.tween.ts = store.tick_ts
    end
end

scripts.bullet_dragon_bone_rain = {}

function scripts.bullet_dragon_bone_rain.insert(this, store)
    this.render.sprites[1].name = this.sprite_prefix .. this.bone_type .. "_green_air"
    this.render.sprites[2].name = this.sprite_prefix .. this.bone_type .. "_ground"

    if this.render.sprites[1].flip_x then
        this.tween.props[3].keys[1][2].x = -this.tween.props[3].keys[1][2].x
        this.tween.props[3].keys[2][2].x = -this.tween.props[3].keys[2][2].x
    end

    return true
end

function scripts.bullet_dragon_bone_rain.update(this, store)
    local b = this.bullet

    U.sprites_hide(this)

    if this.delay then
        U.y_wait(store, this.delay)
    end

    U.sprites_show(this)

    this.tween.disabled = false
    this.tween.ts = store.tick_ts

    U.y_wait(store, b.hit_time)

    this.render.sprites[1].name = this.sprite_prefix .. this.bone_type .. "_green_ground"
    this.render.sprites[1].offset = V.vv(0)
    this.render.sprites[2].hidden = false

    for i = 1, 3 do
        this.tween.props[i].disabled = true
    end

    this.tween.props[4].disabled = false
    this.tween.ts = store.tick_ts

    local fx = E:create_entity(b.hit_fx)

    fx.pos = V.vclone(this.pos)
    fx.render.sprites[1].ts = store.tick_ts
    fx.render.sprites[1].runs = 0

    if this.bone_type == "c" then
        fx.render.sprites[1].scale = V.vv(0.6)
    end

    queue_insert(store, fx)

    local decal = E:create_entity(b.hit_decal)

    decal.pos = V.vclone(this.pos)
    decal.render.sprites[1].ts = store.tick_ts

    queue_insert(store, decal)
    S:queue(this.sound_events.hit)

    local targets = U.find_enemies_in_range(store, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

    if targets then
        for _, target in pairs(targets) do
            local d = E:create_entity("damage")

            d.damage_type = b.damage_type
            d.source_id = this.id
            d.target_id = target.id
            d.value = math.random(b.damage_min, b.damage_max) * this.bullet.damage_factor

            queue_damage(store, d)

            local m = E:create_entity(b.mod)

            m.modifier.source_id = this.id
            m.modifier.target_id = target.id
            m.modifier.xp_dest_id = b.source_id

            queue_insert(store, m)
        end
    end

    U.y_wait(store, b.duration - b.hit_time)

    this.render.sprites[2].hidden = true

    local fx = E:create_entity(b.vanish_fx)

    fx.pos = V.vclone(this.pos)
    fx.render.sprites[1].ts = store.tick_ts
    fx.render.sprites[1].runs = 0

    queue_insert(store, fx)

    this.tween.props[4].disabled = true
    this.tween.props[5].disabled = false
    this.tween.ts = store.tick_ts
    this.tween.remove = true
end

scripts.bolt_dragon_bone_burst = {}

function scripts.bolt_dragon_bone_burst.insert(this, store, script)
    local b = this.bullet

    b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)

    local s = this.render.sprites[1]

    if not b.ignore_rotation then
        s.r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
    end

    U.animation_start(this, "idle", nil, store.tick_ts, s.loop)

    return true
end

function scripts.bolt_dragon_bone_burst.update(this, store)
    local b = this.bullet
    local fm = this.force_motion
    local target = store.entities[b.target_id]
    local ps
    local dmin, dmax = b.damage_min, b.damage_max

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

    local function do_hit(hit_pos)
        local is_flying

        if target then
            local d = E:create_entity("damage")

            d.damage_type = b.damage_type
            d.value = math.random(dmin, dmax) * b.damage_factor
            d.source_id = this.id
            d.target_id = target.id
            queue_damage(store, d)

            is_flying = U.flag_has(target.vis.flags, F_FLYING)

            local m = E:create_entity(b.mod)

            m.modifier.source_id = this.id
            m.modifier.target_id = target.id
            m.modifier.xp_dest_id = b.source_id

            queue_insert(store, m)
        end

        S:queue(this.sound_events.hit)

        if is_flying then
            local fx = E:create_entity(b.hit_fx_flying)

            fx.pos = V.vclone(hit_pos)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        else
            local fx = E:create_entity(b.hit_fx_floor)

            fx.pos = V.vclone(hit_pos)
            fx.render.sprites[1].ts = store.tick_ts

            queue_insert(store, fx)
        end
    end

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.emit = true
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    local pred_pos

    if target then
        pred_pos = P:predict_enemy_pos(target, fts(5))
    else
        pred_pos = b.to
    end

    local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
    local last_pos = V.vclone(this.pos)

    b.ts = store.tick_ts

    while true do
        target = store.entities[b.target_id]

        if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
            local hit_offset = V.v(0, 0)

            if not b.ignore_hit_offset then
                hit_offset.x = target.unit.hit_offset.x
                hit_offset.y = target.unit.hit_offset.y
            end

            local d = math.max(math.abs(target.pos.x + hit_offset.x - b.to.x),
                math.abs(target.pos.y + hit_offset.y - b.to.y))

            if d > b.max_track_distance then
                log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id,
                    this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

                target = nil
                b.target_id = nil
            else
                b.to.x, b.to.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
            end
        end

        if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
            local t = store.tick_ts - b.ts

            if this.initial_impulse_angle_abs then
                fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
            else
                local angle = this.initial_impulse_angle

                if iix < 0 then
                    angle = angle * -1
                end

                fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(angle, iix, iiy))
            end
        end

        last_pos.x, last_pos.y = this.pos.x, this.pos.y

        if move_step(b.to) then
            break
        end

        if b.align_with_trajectory then
            this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
        end

        coroutine.yield()
    end

    this.render.sprites[1].hidden = true

    do_hit(b.to)

    if ps and ps.particle_system.emit then
        ps.particle_system.emit = false
    end

    U.y_wait(store, fts(10))
    queue_remove(store, this)
end

scripts.hero_dragon_bone_ultimate = {}

function scripts.hero_dragon_bone_ultimate.can_fire_fn(this, x, y)
    return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_dragon_bone_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

    if #nodes < 1 then
        log.error("hero_dragon_bone_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local x, y = this.pos.x, this.pos.y
    local pos1 = V.v(x + 12, y - 12)
    local pos2 = V.v(x - 12, y + 12)
    local fx = E:create_entity(this.spawn_fx)

    fx.pos = V.vclone(pos1)
    fx.render.sprites[1].ts = store.tick_ts

    queue_insert(store, fx)

    local fx = E:create_entity(this.spawn_fx)

    fx.pos = V.vclone(pos2)
    fx.render.sprites[1].ts = store.tick_ts

    queue_insert(store, fx)
    U.y_wait(store, this.spawn_time)

    local e = E:create_entity(this.dog)

    e.pos = V.vclone(pos1)
    e.nav_rally.center = V.v(x, y)
    e.nav_rally.pos = V.vclone(e.pos)
    e.reinforcement.squad_id = this.id

    queue_insert(store, e)

    e = E:create_entity(this.dog)
    e.pos = V.vclone(pos2)
    e.nav_rally.center = V.v(x, y)
    e.nav_rally.pos = V.vclone(e.pos)
    e.reinforcement.squad_id = this.id

    queue_insert(store, e)
    queue_remove(store, this)
end

scripts.hero_lumenir = {}

function scripts.hero_lumenir.level_up(this, store, initial)
    local hl, ls = level_up_basic(this)

    local b = E:get_template(this.ranged.attacks[1].bullet)

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    local b = E:get_template("bolt_lumenir_mini_death")

    b.bullet.damage_max = ls.ranged_damage_max[hl]
    b.bullet.damage_min = ls.ranged_damage_min[hl]

    local s

    s = this.hero.skills.shield
    upgrade_skill(this, "shield", function(this, s)
        local a = this.ranged.attacks[2]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local m = E:get_template(a.mod)

        m.spiked_armor = s.spiked_armor[s.level]
        m.armor = s.armor[s.level]
        m.modifier.duration = s.duration[s.level]
    end)

    upgrade_skill(this, "celestial_judgement", function(this, s)
        local a = this.ranged.attacks[3]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]
    end)

    upgrade_skill(this, "mini_dragon", function(this, s)
        local a = this.ranged.attacks[4]

        a.disabled = nil
        a.cooldown = s.cooldown[s.level]

        local e = E:get_template(a.entity)

        a.duration = s.duration[s.level]

        local b = E:get_template("bolt_lumenir_mini")

        b.bullet.damage_min = s.damage_min[s.level]
        b.bullet.damage_max = s.damage_max[s.level]
    end)

    upgrade_skill(this, "fire_balls", function(this, s)
        local a = this.ranged.attacks[5]

        a.cooldown = s.cooldown[s.level]
        a.disabled = nil
        a.count = s.flames_count[s.level]
    end)

    upgrade_skill(this, "ultimate", function(this, s)
        local u = this.ultimate

        u.disabled = nil
        
        local uc = E:get_template(s.controller_name)

        uc.cooldown = s.cooldown[s.level]
        uc.count = s.count[s.level]

        local soldier = E:get_template(uc.entity)

        soldier.melee.attacks[1].damage_max = s.damage_max[s.level]
        soldier.melee.attacks[1].damage_min = s.damage_min[s.level]
        soldier.max_attack_count = s.max_attack_count
    end)

    this.health.hp = this.health.hp_max
end

function scripts.hero_lumenir.insert(this, store)
    this.hero.fn_level_up(this, store, true)

    this.ranged.order = U.attack_order(this.ranged.attacks)

    return true
end

function scripts.hero_lumenir.update(this, store)
    local h = this.health
    local he = this.hero
    local a, skill
    local basic_ranged = this.ranged.attacks[1]
    local shield_attack = this.ranged.attacks[2]
    local celestial_judgement_attack = this.ranged.attacks[3]
    local mini_dragon_attack = this.ranged.attacks[4]
    local fire_balls_attack = this.ranged.attacks[5]
    local upg_lf = UP:get_upgrade("heroes_lethal_focus")

    SU.hero_spawning_set_skill_ts(this, store)

    local function find_hero()
        for _, e in pairs(store.entities) do
            if e.hero and e.template_name ~= "hero_lumenir" then
                return e
            end
        end

        return nil
    end

    local function find_enemy_strongest(entities, origin, min_range, max_range, min_nodes, flags, bans, filter_func)
        local max_health = -1
        local enemy

        for _, e in pairs(entities) do
            if e.pending_removal or not e.enemy or not e.nav_path or not U.is_inside_ellipse(e.pos, origin, max_range) or e.health and e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e) then
                -- block empty
            elseif max_health < e.health.hp and min_nodes < e.nav_path.ni then
                max_health = e.health.hp
                enemy = e
            end
        end

        return enemy
    end

    local function create_mini_dragon(follow, entity_t, duration, remove_hero_death)
        local d = E:create_entity(entity_t)

        d.pos = V.vclone(follow.pos)
        d.ranged.attacks[1].xp_dest_id = this.id
        d.owner = this
        d.hero_id = follow.id
        d.duration = duration
        d.remove_hero_death = remove_hero_death

        queue_insert(store, d)

        return d
    end

    this.tween.disabled = false
    this.tween.ts = store.tick_ts
    this.health_bar.hidden = false

    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)

    while true do
        if h.dead then
            S:queue(mini_dragon_attack.sound)

            local time_adjustement = 1
            local d1 = create_mini_dragon(this, this.mini_dragon, this.health.dead_lifetime - time_adjustement, false)

            d1.offset.x = 40
            d1.offset.y = 10
            d1.delay_creation = 0.2

            local d2 = create_mini_dragon(this, this.mini_dragon, this.health.dead_lifetime - time_adjustement, false)

            d2.offset.x = -40
            d2.offset.y = -10
            d2.delay_creation = 0.3
            this.tween.disabled = false
            this.tween.ts = store.tick_ts
            this.tween.reverse = true

            SU.y_hero_death_and_respawn(store, this)

            this.tween.disabled = false
            this.tween.ts = store.tick_ts
            this.tween.reverse = false

            U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, true)
        end

        while this.nav_rally.new do
            SU.y_hero_new_rally(store, this)
        end

        if SU.hero_level_up(store, this) then
            U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
        end

        a = this.ultimate

        if ready_to_use_skill(a, store) then
            local target = U.find_foremost_enemy(store, this.pos, basic_ranged.min_range, basic_ranged.max_range, nil, 0, a.vis_bans)
            if target and valid_rally_node_nearby(target.pos) then
                apply_ultimate(this, store, target, "levelup")
            else
                a.ts = a.ts + 1
            end
        end

        skill = this.hero.skills.shield
        a = shield_attack

        if ready_to_use_skill(a, store) then
            if store.wave_group_number > 0 then
                local soldiers = U.find_soldiers_in_range(store.soldiers, this.pos, 0, a.range, a.vis_flags,
                    a.vis_bans)

                if not soldiers or #soldiers <= a.min_count then
                    SU.delay_attack(store, a, fts(10))
                else
                    local middle = 0
                    local damaged = false

                    for _, s in pairs(soldiers) do
                        middle = middle + s.pos.x

                        if s.health and s.health.hp < s.health.hp_max then
                            damaged = true
                        end
                    end

                    if not damaged then
                        -- block empty
                    else
                        middle = middle / #soldiers

                        S:queue(a.sound)
                        U.animation_start(this, a.animation, middle - this.pos.x < 0, store.tick_ts)
                        U.y_wait(store, a.shoot_time)

                        for _, s in pairs(soldiers) do
                            local m = E:create_entity(a.mod)

                            m.modifier.target_id = s.id
                            m.modifier.source_id = this.id

                            queue_insert(store, m)
                        end

                        U.y_animation_wait(this, 1, 1)

                        a.ts = store.tick_ts

                        SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                    end
                end
            end
        end

        skill = this.hero.skills.celestial_judgement
        a = celestial_judgement_attack

        if ready_to_use_skill(a, store) then
            local target = find_enemy_strongest(store.entities, this.pos, 0, a.range, a.min_nodes,
                a.vis_flags, a.vis_bans)

            if target then
                local an, af, ai = U.animation_name_facing_point(this, a.animation, target.pos)

                S:queue(a.sound)

                a.ts = store.tick_ts

                U.animation_start(this, an, af, store.tick_ts)
                U.y_wait(store, a.shoot_time)

                local m = E:create_entity(a.mod)

                m.modifier.target_id = target.id
                m.modifier.source_id = this.id
                m.modifier.level = this.hero.skills.celestial_judgement.level

                queue_insert(store, m)
                U.y_animation_wait(this, 1, 1)
                SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
            else
                SU.delay_attack(store, a, fts(10))
            end

            goto label_411_1
        end

        skill = this.hero.skills.mini_dragon
        a = mini_dragon_attack

        if ready_to_use_skill(a, store) then
            if store.wave_group_number > 0 then
                local hero = find_hero()

                if hero and hero.health and not hero.health.dead then
                    S:queue(a.sound)
                    create_mini_dragon(hero, a.entity, a.duration, true)

                    a.ts = store.tick_ts

                    SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                end
            end
        end

        skill = this.hero.skills.fire_balls
        a = fire_balls_attack

        if ready_to_use_skill(a, store) then
            local targets_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min,
                a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

            if not targets_info or #targets_info < a.min_targets then
                SU.delay_attack(store, a, 0.4)

                goto label_411_2
            end

            local target

            for _, ti in pairs(targets_info) do
                if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
                    target = ti.enemy

                    break
                end
            end

            if not target then
                SU.delay_attack(store, a, 0.4)

                goto label_411_2
            end

            local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
            local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
                pi
            }, nil, nil, NF_RALLY)

            if #nodes < 1 then
                SU.delay_attack(store, a, 0.4)

                goto label_411_2
            end

            local s_pi, s_spi, s_ni = unpack(nodes[1])
            local dir = ni < s_ni and -1 or 1
            local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

            s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

            local flip = P:node_pos(s_pi, s_spi, s_ni, true).x < this.pos.x

            S:queue(a.sound)
            U.animation_start(this, a.animation, flip, store.tick_ts)
            U.y_wait(store, a.spawn_time)

            local delay = 0
            local pattern = {
                1,
                2,
                3,
                2,
                3,
                1,
                2
            }

            for i = 1, a.count do
                delay = delay + math.random(0.5, 0.66)

                local e = E:create_entity(a.entity)

                e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x,
                    this.pos.y + a.spawn_offset.y
                e.nav_path.pi = s_pi
                e.nav_path.spi = pattern[i % #pattern + 1]
                e.nav_path.ni = s_ni
                e.nav_path.dir = dir
                e.delay = delay
                e.aura.source_id = this.id
                e.level = this.hero.skills.fire_balls.level

                queue_insert(store, e)
            end

            U.y_animation_wait(this)

            a.ts = store.tick_ts

            SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])

            goto label_411_2
        end

        a = basic_ranged

        if ready_to_use_skill(a, store) then
            local pos_offset = v(this.pos.x + a.ignore_offset.x, this.pos.y + a.ignore_offset.y)
            local targets = U.find_enemies_in_range(store, this.pos, a.min_range, a.max_range,
                a.vis_flags, a.vis_bans, function(e)
                return V.dist2(pos_offset.x, pos_offset.y, e.pos.x, e.pos.y) > a.radius * a.radius
            end)

            if targets then
                local target = targets[1]
                local start_ts = store.tick_ts
                local start_fx, b, targets
                local node_offset = P:predict_enemy_node_advance(target, flight_time)
                local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi,
                    target.nav_path.ni + node_offset)
                local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                U.animation_start(this, an, af, store.tick_ts)
                S:queue(a.start_sound, a.start_sound_args)

                while store.tick_ts - start_ts < a.shoot_time do
                    if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                        goto label_411_0
                    end

                    coroutine.yield()
                end

                S:queue(a.sound)

                b = E:create_entity(a.bullet)

                b.bullet.target_id = target.id
                b.bullet.source_id = this.id
                b.bullet.xp_dest_id = this.id
                b.pos = V.vclone(this.pos)
                b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
                b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
                b.bullet.from = V.vclone(b.pos)
                b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
                    target.pos.y + target.unit.hit_offset.y)
                b.bullet.shot_index = 1
                b.initial_impulse = 10

                if b.bullet.use_unit_damage_factor then
                    b.bullet.damage_factor = this.unit.damage_factor
                end

                if upg_lf and a.basic_attack then
                    if not this._lethal_focus_deck then
                        this._lethal_focus_deck = SU.deck_new(upg_lf.trigger_cards, upg_lf.total_cards)
                    end

                    local triggered_lethal_focus = SU.deck_draw(this._lethal_focus_deck)

                    if triggered_lethal_focus then
                        b.bullet.damage_factor = b.bullet.damage_factor * upg_lf.damage_factor_area
                        b.bullet.pop = {
                            "pop_crit"
                        }
                        b.bullet.pop_chance = 1
                        b.bullet.pop_conds = DR_DAMAGE
                    end
                end

                queue_insert(store, b)

                if a.xp_from_skill then
                    SU.hero_gain_xp_from_skill(this, this.hero.skills[a.xp_from_skill])
                end

                a.ts = start_ts

                while not U.animation_finished(this) do
                    if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
                        goto label_411_0
                    end

                    coroutine.yield()
                end

                a.ts = start_ts

                U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts,
                    this.idle_flip.loop, nil, true)

                ::label_411_0::

                if start_fx then
                    start_fx.render.sprites[1].hidden = true
                end

                goto label_411_2
            end
        end

        ::label_411_1::

        SU.soldier_idle(store, this)
        SU.soldier_regen(store, this)

        ::label_411_2::

        coroutine.yield()
    end
end

scripts.hero_lumenir_ultimate = {}

function scripts.hero_lumenir_ultimate.can_fire_fn(this, x, y)
    return GR:cell_is_only(x, y, TERRAIN_LAND) and P:valid_node_nearby(x, y, nil, NF_RALLY)
end

function scripts.hero_lumenir_ultimate.update(this, store)
    local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true, NF_POWER_3)

    if #nodes < 1 then
        log.error("hero_lumenir_ultimate: could not find valid node")
        queue_remove(store, this)

        return
    end

    local node = {
        spi = 1,
        pi = nodes[1][1],
        ni = nodes[1][3]
    }
    local node_pos = P:node_pos(node)
    local count = this.count
    local target, targets = U.find_nearest_enemy(store, this.pos, 0, this.range, this.vis_flags, this.vis_bans)
    local idx = 1

    if targets and count > #targets then
        count = #targets
    end

    while count > 0 and targets do
        local e = E:create_entity(this.entity)

        target = targets[idx]
        idx = idx + 1

        if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 then
            local m = E:create_entity("mod_lumenir_ulti_stun")

            m.modifier.target_id = target.id
            m.modifier.source_id = this.id

            queue_insert(store, m)
        end

        if band(target.vis.flags, F_BLOCK) ~= 0 then
            U.block_enemy(store, e, target)
        else
            e.unblocked_target_id = target.id
        end

        local lpos, lflip = U.melee_slot_position(e, target, 1)

        e.pos.x, e.pos.y = lpos.x, lpos.y
        e.render.sprites[1].flip_x = lflip
        e.nav_rally.center = V.vclone(e.pos)
        e.nav_rally.pos = V.vclone(e.pos)

        queue_insert(store, e)

        count = count - 1

        U.y_wait(store, this.spawn_delay)
    end

    count = this.count

    if targets then
        count = count - #targets
    end

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

    if nearest and #nearest > 0 then
        local path_pi, path_spi, path_ni = unpack(nearest[1])
        local spi = {
            1,
            3,
            2
        }

        while count > 0 do
            local ni_random = math.random(-5, 5)
            local spi_random = spi[count % 3 + 1]
            local pos_spawn = P:node_pos(path_pi, spi_random, path_ni + ni_random)
            local e = E:create_entity(this.entity)

            e.pos.x, e.pos.y = pos_spawn.x, pos_spawn.y
            e.render.sprites[1].flip_x = math.random() > 0.5
            e.nav_rally.center = V.vclone(e.pos)
            e.nav_rally.pos = V.vclone(e.pos)

            queue_insert(store, e)
            U.y_wait(store, this.spawn_delay)

            count = count - 1
        end
    end

    queue_remove(store, this)
end

scripts.soldier_lumenir_ultimate = {}

function scripts.soldier_lumenir_ultimate.insert(this, store, script)
    this.melee.order = U.attack_order(this.melee.attacks)

    return true
end

function scripts.soldier_lumenir_ultimate.update(this, store)
    local target_id = this.soldier.target_id or this.unblocked_target_id
    local target = store.entities[target_id]
    local attack_count = 0

    this.render.sprites[1].ts = store.tick_ts
    this.render.sprites[1].runs = 0

    U.animation_start(this, "idle", nil, store.tick_ts, false, 2)
    U.y_wait(store, 0.4)

    this.render.sprites[1].hidden = false

    U.animation_start(this, "idle", nil, store.tick_ts, false, 1)

    if target then
        local enemies = U.find_enemies_in_range(store, target.pos, 0, this.stun_range, this.stun_flags,
            this.stun_bans)

        if enemies then
            for k, e in pairs(enemies) do
                local m = E:create_entity("mod_lumenir_ulti_stun")

                m.modifier.duration = this.stun_duration
                m.modifier.target_id = e.id
                m.modifier.source_id = this.id

                queue_insert(store, m)
            end
        end
    end

    if not target then
        U.y_wait(store, U.frandom(this.min_wait, this.max_wait))
    else
        while target and not target.health.dead and not this.health.dead and (not this.max_attack_count or attack_count < this.max_attack_count) do
            local attack = SU.soldier_pick_melee_attack(store, this, target)

            if attack then
                for _, hit_time in pairs(attack.hit_times) do
                    local start_ts = store.tick_ts
                    local an, af = U.animation_name_facing_point(this, attack.animation, target.pos)

                    U.animation_start(this, an, af, store.tick_ts, false, 1)
                    S:queue(attack.sound)
                    U.y_wait(store, hit_time)
                    S:queue(attack.sound_hit)

                    attack.ts = start_ts

                    for _, aa in pairs(this.melee.attacks) do
                        if aa ~= attack and aa.shared_cooldown then
                            aa.ts = attack.ts
                        end
                    end

                    if attack.damage_type ~= DAMAGE_NONE then
                        local d = E:create_entity("damage")

                        d.damage_type = attack.damage_type
                        d.value = math.ceil(U.frandom(attack.damage_min, attack.damage_max))
                        d.source_id = this.id
                        d.target_id = target.id

                        queue_damage(store, d)
                    end
                end

                U.y_animation_wait(this)

                attack_count = attack_count + 1
            end

            coroutine.yield()

            target = store.entities[target_id]
        end
    end

    S:queue(this.sound_events.death, {
        delay = fts(11)
    })
    U.y_animation_play(this, "out", nil, store.tick_ts, 1, 1)
    queue_remove(store, this)
end

scripts.mod_hero_lumenir_sword_hit = {}

function scripts.mod_hero_lumenir_sword_hit.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]
    local time_hit = this.time_hit
    local decal_spawn_time = this.decal_spawn_time
    local damaged = false
    local decal_spawned = false

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    S:queue(this.sound)

    while true do
        target = store.entities[m.target_id]

        if m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
            queue_remove(store, this)

            return
        end

        if not damaged and time_hit < store.tick_ts - m.ts then
            damaged = true

            if target and not target.health.dead then
                local d = E:create_entity("damage")

                d.source_id = this.id
                d.target_id = target.id
                d.value = this.damage[m.level]
                d.damage_type = this.damage_type

                queue_damage(store, d)
            end

            local targets = U.find_enemies_in_range(store, this.pos, 0, this.stun_range, this.stun_vis_flags,
                this.stun_bans)

            if targets then
                for _, target in pairs(targets) do
                    local s = E:create_entity(this.mod_stun)

                    s.modifier.target_id = target.id
                    s.modifier.source_id = m.source_id
                    s.modifier.duration = this.stun_duration[m.level]

                    queue_insert(store, s)
                end
            end
        end

        if not decal_spawned and decal_spawn_time < store.tick_ts - m.ts then
            decal_spawned = true

            local decal = E:create_entity(this.hit_decal)

            decal.pos = V.vclone(this.pos)
            decal.render.sprites[1].ts = store.tick_ts

            queue_insert(store, decal)
        end

        coroutine.yield()
    end
end

scripts.mod_hero_lumenir_shield = {}

function scripts.mod_hero_lumenir_shield.insert(this, store)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        return false
    end

    local s = this.render.sprites[1]
    local sd = this.render.sprites[2]

    s.ts = store.tick_ts

    if s.size_names then
        s.name = s.size_names[target.unit.size]
        sd.name = sd.name .. "_" .. sd.size_names[target.unit.size]
    end

    if this.custom_offsets then
        s.offset = V.vclone(this.custom_offsets[target.template_name] or this.custom_offsets.default)
        s.offset.x = s.offset.x * (s.flip_x and -1 or 1)

        if target.unit and target.unit.mod_offset and this.modifier.use_mod_offset then
            s.offset.x = s.offset.x + target.unit.mod_offset.x
            s.offset.y = s.offset.y + target.unit.mod_offset.y
        end
    end

    if target.health then
        SU.spiked_armor_inc(target, this.spiked_armor)
        SU.armor_inc(target, this.armor)
    end

    return true
end

function scripts.mod_hero_lumenir_shield.update(this, store, script)
    local m = this.modifier

    this.modifier.ts = store.tick_ts

    local target = store.entities[m.target_id]

    if not target or not target.pos then
        queue_remove(store, this)

        return
    end

    this.pos = target.pos

    while true do
        target = store.entities[m.target_id]

        if not target or target.health.dead or m.duration >= 0 and store.tick_ts - m.ts > m.duration or m.last_node and target.nav_path.ni > m.last_node then
            this.tween.reverse = true
            this.tween.remove = true
            this.tween.ts = store.tick_ts

            U.y_wait(store, 0.25)
            queue_remove(store, this)

            return
        end

        local s = this.render.sprites[1]

        if m.use_mod_offset and target.unit.mod_offset then
            s.offset.x, s.offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
        end

        coroutine.yield()
    end
end

function scripts.mod_hero_lumenir_shield.remove(this, store)
    local m = this.modifier
    local target = store.entities[m.target_id]

    if target and target.health then
        SU.spiked_armor_dec(target, this.spiked_armor)
        SU.armor_dec(target, this.armor)
    end

    return true
end

scripts.mini_dragon_hero_lumenir = {}

function scripts.mini_dragon_hero_lumenir.update(this, store)
    local sd = this.render.sprites[1]
    local ss = this.render.sprites[2]
    local a = this.ranged.attacks[1]
    local fm = this.force_motion
    local owner = this.owner
    local hero = store.entities[this.hero_id]
    local shoot_ts, search_ts = 0, 0
    local target, targets, dist
    local dest = V.v(this.pos.x, this.pos.y)

    if this.delay_creation then
        ss.hidden = true

        U.y_wait(store, this.delay_creation)

        ss.hidden = false
    end

    local flight_height = this.flight_height

    flight_height = this.custom_height and this.custom_height[hero.template_name] or flight_height
    this.tween.props[1].keys = {
        {
            0,
            v(0, flight_height + 2)
        },
        {
            0.4,
            v(0, flight_height - 2)
        },
        {
            0.8,
            v(0, flight_height + 2)
        }
    }
    this.render.sprites[1].offset.y = flight_height
    fm.a_step = fm.a_step + math.random(-3, 3)
    this.tween.disabled = false
    this.tween.ts = store.tick_ts

    local oos = {
        V.v(-15, 0),
        V.v(10, 7)
    }

    U.y_animation_play(this, "spawn", true, store.tick_ts)
    U.animation_start(this, "walk", nil, store.tick_ts, true)

    this.start_ts = store.tick_ts

    local initial_pos_offset = {}

    if this.drone_id == 1 then
        initial_pos_offset = V.v(-50, 40)
    else
        initial_pos_offset = V.v(40, 30)
    end

    while store.tick_ts - this.start_ts <= this.duration do
        if this.remove_hero_death then
            if hero.health.dead then
                break
            end
        elseif not hero.health.dead then
            break
        end

        search_ts = store.tick_ts

        if hero then
            this._chasing_target_id = hero.id
        else
            this._chasing_target_id = nil
        end

        if hero then
            repeat
                dest.x, dest.y = hero.pos.x + this.offset.x, hero.pos.y + this.offset.y
                sd.flip_x = dest.x < this.pos.x

                U.force_motion_step(this, store.tick_length, dest)
                coroutine.yield()

                dist = V.dist(this.pos.x, this.pos.y, dest.x, dest.y)
            until dist < 5

            if a.sync_animation and not this.render.sprites[1].sync_flag then
                -- block empty
            else
                local targets = U.find_enemies_in_range(store, this.pos, 0, a.max_range, a.vis_flags, a
                .vis_bans)

                if targets and #targets > 0 then
                    local start_ts = store.tick_ts
                    local start_fx, b
                    local flight_time = a.estimated_flight_time or 1
                    local target = targets[1]
                    local node_offset = P:predict_enemy_node_advance(target, 1)
                    local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
                    local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

                    U.animation_start(this, an, af, store.tick_ts)
                    S:queue(a.start_sound, a.start_sound_args)

                    while store.tick_ts - start_ts < a.shoot_time do
                        coroutine.yield()
                    end

                    S:queue(a.sound)

                    b = E:create_entity(a.bullet)
                    b.bullet.target_id = target.id
                    b.bullet.source_id = this.id
                    b.bullet.xp_dest_id = this.id
                    b.pos = V.vclone(this.pos)
                    b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset.x
                    b.pos.y = b.pos.y + a.bullet_start_offset.y + flight_height
                    b.bullet.from = V.vclone(b.pos)
                    b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
                    b.bullet.shot_index = 1
                    b.initial_impulse = 10

                    queue_insert(store, b)

                    a.ts = start_ts

                    while not U.animation_finished(this) do
                        coroutine.yield()
                    end

                    a.ts = start_ts

                    U.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil,
                        true)

                    if start_fx then
                        start_fx.render.sprites[1].hidden = true
                    end
                end

                U.animation_start(this, "walk", nil, store.tick_ts, true)
            end
        end
    end

    U.y_ease_keys(store, {
        sd,
        sd.offset,
        ss
    }, {
        "alpha",
        "y",
        "alpha"
    }, {
        255,
        this.flight_height,
        255
    }, {
        0,
        85,
        0
    }, 0.4, {
        "linear",
        "linear",
        "linear"
    })
    queue_remove(store, this)
end

scripts.aura_fire_balls_hero_lumenir = {}

function scripts.aura_fire_balls_hero_lumenir.insert(this, store)
    next_pos = P:node_pos(this.nav_path)

    if not next_pos then
        return false
    end

    return true
end

function scripts.aura_fire_balls_hero_lumenir.update(this, store)
    local y_off = 20
    local a = this.aura
    local m = this.motion
    local nav = this.nav_path
    local dt = store.tick_length
    local start_ni = nav.ni
    local start_ts = store.tick_ts
    local hit_ts = 0

    a.duration = a.duration + U.frandom(-a.duration_var, 0)
    m.max_speed = m.max_speed + math.random(0, m.max_speed_var)

    local step = m.max_speed * dt
    local next_pos = P:node_pos(nav)

    next_pos.y = next_pos.y + y_off

    U.set_destination(this, next_pos)

    local v_heading = V.v(0, 0)

    v_heading.x, v_heading.y = V.normalize(next_pos.x - this.pos.x, next_pos.y - this.pos.y)

    local th_dist = 25
    local turn_speed = math.pi * 1.5
    local enemies_hit = {}
    local speed_offset = 0
    local ps = E:create_entity("ps_bolt_lumenir_wave")

    ps.particle_system.track_id = this.id

    queue_insert(store, ps)

    while true do
        if this.tween.disabled and store.tick_ts - start_ts > a.duration then
            this.tween.disabled = nil
            this.tween.ts = store.tick_ts
        end

        if th_dist > V.len(m.dest.x - this.pos.x, m.dest.y - this.pos.y) then
            nav.ni = nav.ni + math.random(6, 11) * nav.dir

            local p_len = #P:path(nav.pi)

            if nav.ni <= 1 or p_len <= nav.ni then
                a.duration = 0
            end

            nav.ni = km.clamp(1, p_len, nav.ni)
            nav.spi = km.zmod(nav.spi + math.random(1, 2), 3)
            next_pos = P:node_pos(nav)
            next_pos.y = next_pos.y + y_off

            U.set_destination(this, next_pos)
        end

        local dx, dy = V.sub(m.dest.x, m.dest.y, this.pos.x, this.pos.y)
        local sa = km.short_angle(V.angleTo(dx, dy), V.angleTo(v_heading.x, v_heading.y))
        local angle_step = math.min(turn_speed * dt, math.abs(sa)) * km.sign(sa) * -1

        v_heading.x, v_heading.y = V.rotate(angle_step, v_heading.x, v_heading.y)

        local sx, sy = V.mul(step, v_heading.x, v_heading.y)

        if this.delay and speed_offset < this.delay then
            sx = sx * speed_offset / this.delay
            sy = sy * speed_offset / this.delay
            speed_offset = speed_offset + dt
        end

        this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
        m.speed.x, m.speed.y = sx / dt, sy / dt
        this.render.sprites[1].r = V.angleTo(v_heading.x, v_heading.y)

        if store.tick_ts - hit_ts > a.damage_cycle then
            hit_ts = store.tick_ts

            local targets = U.find_enemies_in_range(store, this.pos, 0, a.damage_radius, a.damage_flags,
                a.damage_bans, function(v)
                return not table.contains(enemies_hit, v)
            end)

            if not targets then
                -- block empty
            else
                for _, e in pairs(targets) do
                    local d = E:create_entity("damage")

                    d.source_id = this.id
                    d.target_id = e.id
                    d.value = math.random(this.flame_damage_min[this.level], this.flame_damage_max[this.level])
                    d.damage_type = a.damage_type

                    queue_damage(store, d)
                    table.insert(enemies_hit, e)
                end
            end
        end

        coroutine.yield()
    end

    queue_remove(store, this)
end

scripts.bolt_lumenir = {}

function scripts.bolt_lumenir.insert(this, store)
	return true
end

function scripts.bolt_lumenir.update(this, store)
	local b = this.bullet
	local fm = this.force_motion
	local target = store.entities[b.target_id]
	local ps

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

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.emit = true
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local pred_pos

	if target then
		pred_pos = P:predict_enemy_pos(target, fts(5))
	else
		pred_pos = b.to
	end

	local iix, iiy = V.normalize(pred_pos.x - this.pos.x, pred_pos.y - this.pos.y)
	local last_pos = V.vclone(this.pos)

	b.ts = store.tick_ts

	while true do
		target = store.entities[b.target_id]

		if target and target.health and not target.health.dead and band(target.vis.bans, F_RANGED) == 0 then
			local d = math.max(math.abs(target.pos.x + target.unit.hit_offset.x - b.to.x), math.abs(target.pos.y + target.unit.hit_offset.y - b.to.y))

			if d > b.max_track_distance then
				log.debug("BOLT MAX DISTANCE FAIL. (%s) %s / dist:%s target.pos:%s,%s b.to:%s,%s", this.id, this.template_name, d, target.pos.x, target.pos.y, b.to.x, b.to.y)

				target = nil
				b.target_id = nil
			else
				b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			end
		end

		if this.initial_impulse and store.tick_ts - b.ts < this.initial_impulse_duration then
			local t = store.tick_ts - b.ts

			if this.initial_impulse_angle_abs then
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle_abs, 1, 0))
			else
				fm.a.x, fm.a.y = V.mul((1 - t) * this.initial_impulse, V.rotate(this.initial_impulse_angle * (b.shot_index % 2 == 0 and 1 or -1), iix, iiy))
			end
		end

		last_pos.x, last_pos.y = this.pos.x, this.pos.y

		if move_step(b.to) then
			break
		end

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - last_pos.x, this.pos.y - last_pos.y)
		end

		coroutine.yield()
	end

	if target and not target.health.dead then
		local d = SU.create_bullet_damage(b, target.id, this.id)
		local u = UP:get_upgrade("mage_el_empowerment")

		if u and not this.upgrades_disabled and math.random() < u.chance then
			d.value = km.round(d.value * u.damage_factor)

			if b.pop_mage_el_empowerment then
				d.pop = b.pop_mage_el_empowerment
				d.pop_conds = DR_DAMAGE
			end
		end

		queue_damage(store, d)

		if this.alter_reality_chance and UP:has_upgrade("mage_el_alter_reality") and math.random() < this.alter_reality_chance then
			local mod = E:create_entity(this.alter_reality_mod)

			mod.modifier.target_id = target.id

			queue_insert(store, mod)
		end
	elseif b.damage_radius and b.damage_radius > 0 then
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.vis_flags, b.vis_bans)

		if targets then
			for _, target in pairs(targets) do
				local d = SU.create_bullet_damage(b, target.id, this.id)

				queue_damage(store, d)
			end
		end
	end

	this.render.sprites[1].hidden = true

	if b.hit_fx then
		local fx = E:create_entity(b.hit_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts
		fx.render.sprites[1].runs = 0

		queue_insert(store, fx)
	end

	if b.hit_decal then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if ps and ps.particle_system.emit then
		ps.particle_system.emit = false

		U.y_wait(store, ps.particle_system.particle_lifetime[2])
	end

	queue_remove(store, this)
end

return scripts
