local E = require("entity_db")
require("constants")
local UP = require("upgrades")
local U = require("utils")
local scripts = require("scripts")
local EL = require("kr1.data.endless")
local enemy_buff = EL.enemy_buff
local friend_buff = EL.friend_buff
local enemy_upgrade_max_levels = EL.enemy_upgrade_max_levels
local endless_template = EL.template
local SU = require("script_utils")
local storage = require("storage")
local log = require("klua.log"):new("endless_utils")
local GR = require("grid_db")
local S = require("sound_db")
local P = require("path_db")
local function fts(t)
    return t / FPS
end
local function vv(x)
    return {
        x = x,
        y = x
    }
end
local V = require("klua.vector")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local function queue_damage(store, damage)
    store.damage_queue[#store.damage_queue + 1] = damage
end
local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end
local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

local EU = {}

local function engineer_focus_bomb_update(this, store, script)
    local b = this.bullet
    local dmin, dmax = b.damage_min, b.damage_max
    local dradius = b.damage_radius

    if b.level and b.level > 0 then
        if b.damage_radius_inc then
            dradius = dradius + b.level * b.damage_radius_inc
        end

        if b.damage_min_inc then
            dmin = dmin + b.level * b.damage_min_inc
        end

        if b.damage_max_inc then
            dmax = dmax + b.level * b.damage_max_inc
        end
    end

    local ps

    if b.particles_name then
        ps = E:create_entity(b.particles_name)
        ps.particle_system.track_id = this.id

        queue_insert(store, ps)
    end

    while store.tick_ts - b.ts + store.tick_length < b.flight_time do
        coroutine.yield()

        b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
        this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

        if b.align_with_trajectory then
            this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
        elseif b.rotation_speed then
            this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
        end

        if b.hide_radius then
            this.render.sprites[1].hidden = V.dist2(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius *
                                                b.hide_radius or V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) <
                                                b.hide_radius * b.hide_radius
        end
    end
    local enemies = U.find_enemies_in_range(store, b.to, 0, dradius, b.damage_flags, b.damage_bans)
    if enemies then
        for i=1,#enemies do
            local enemy = enemies[i]
            local d = E:create_entity("damage")

            d.damage_type = b.damage_type
            d.reduce_armor = b.reduce_armor
            d.reduce_magic_armor = b.reduce_magic_armor

            local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)

            d.value = dmax + (dmax - (dmax - dmin) * dist_factor) *
                          (store.endless.upgrade_levels.engineer_focus * EL.friend_buff.engineer_focus)

            d.value = b.damage_factor * d.value
            d.source_id = this.id
            d.target_id = enemy.id

            queue_damage(store, d)

            -- if this.up_shock_and_awe_chance and band(enemy.vis.bans, F_STUN) == 0 and
            --     band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < this.up_shock_and_awe_chance then
            --     local mod = E:create_entity("mod_shock_and_awe")

            --     mod.modifier.target_id = enemy.id

            --     queue_insert(store, mod)
            -- end

            local mods
            if b.mod then
                mods = type(b.mod) == "string" and {b.mod} or b.mod
            elseif b.mods then
                mods = b.mods
            end
            if mods then
                for _, mod_name in pairs(mods) do
                    local mod = E:create_entity(mod_name)
                    mod.modifier.damage_factor = b.damage_factor
                    mod.modifier.target_id = enemy.id
                    mod.modifier.source_id = this.id
                    if U.flags_pass(enemy.vis, mod.modifier) then
                        queue_insert(store, mod)
                    end
                end
            end
        end
    end

    local p = SU.create_bullet_pop(store, this)

    queue_insert(store, p)

    local cell_type = GR:cell_type(b.to.x, b.to.y)

    if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
        S:queue(this.sound_events.hit_water)

        local water_fx = E:create_entity(b.hit_fx_water)

        water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
        water_fx.render.sprites[1].ts = store.tick_ts
        water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

        queue_insert(store, water_fx)
    elseif b.hit_fx then
        S:queue(this.sound_events.hit)

        local sfx = E:create_entity(b.hit_fx)

        sfx.pos = V.vclone(b.to)
        sfx.render.sprites[1].ts = store.tick_ts
        sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

        queue_insert(store, sfx)
    end

    if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
        local decal = E:create_entity(b.hit_decal)

        decal.pos = V.vclone(b.to)
        decal.render.sprites[1].ts = store.tick_ts

        queue_insert(store, decal)
    end

    if b.hit_payload then
        local hp

        if type(b.hit_payload) == "string" then
            hp = E:create_entity(b.hit_payload)
        else
            hp = b.hit_payload
        end

        hp.pos.x, hp.pos.y = b.to.x, b.to.y

        if hp.aura then
            hp.aura.level = this.bullet.level
        end

        queue_insert(store, hp)
    end

    queue_remove(store, this)
end

local function get_enemy_weight(name)
    local tpl = E:get_template(name)
    local weight = 0
    if tpl.enemy then
        weight = tpl.enemy.lives_cost + 0.025 * tpl.enemy.gold
        if tpl.death_spawns and tpl.death_spawns.name then
            local quantity
            if type(tpl.death_spawns.quantity) == "table" then
                quantity = tpl.death_spawns.quantity[#tpl.death_spawns.quantity]
            else
                quantity = tpl.death_spawns.quantity or 1
            end
            weight = weight + get_enemy_weight(tpl.death_spawns.name) * quantity
        end
    end
    return weight
end

function EU.init_endless(level_name, groups)
    local endless
    local endless_history = storage:load_endless(level_name)
    if endless_history and (endless_history.lives > 0) then
        endless = endless_history
        endless.load_from_history = true
        local function deepcopy(table, base_table)
            for k, v in pairs(base_table) do
                if type(v) == "table" then
                    if table[k] == nil then
                        table[k] = {}
                    end
                    deepcopy(table[k], v)
                else
                    if table[k] == nil then
                        table[k] = v
                    end
                end
            end
        end
        deepcopy(endless_history, endless_template)
    else
        endless = table.deepclone(endless_template)
        local group = #groups > 1 and groups[#groups - 1] or groups[1]
        local waves = group.waves

        local total_spawns = 0
        for _, wave in pairs(waves) do
            for _, spawn in pairs(wave.spawns) do
                endless.avg_interval = endless.avg_interval + (spawn.interval or 0)
                endless.avg_interval_next = endless.avg_interval_next + (spawn.interval_next or 0)
                total_spawns = total_spawns + 1
                endless.total_enemy_weight = endless.total_enemy_weight + get_enemy_weight(spawn.creep) * spawn.max
            end
        end
        endless.avg_interval = math.min(endless.avg_interval / total_spawns, 90)
        endless.avg_interval_next = endless.avg_interval_next / total_spawns

        for i = 1, #P.paths do
            table.insert(endless.available_paths, i)
        end
        endless.only_fly_paths = table.deepclone(endless.available_paths)
        endless.only_water_paths = table.deepclone(endless.available_paths)
        endless.special_paths = table.deepclone(endless.available_paths)
        local fixed_special_paths = {}
        for _, group in pairs(groups) do
            for _, wave in pairs(group.waves) do
                for _, spawn in pairs(wave.spawns) do
                    local tpl = E:get_template(spawn.creep)
                    if tpl and tpl.enemy then
                        if endless.only_fly_paths[wave.path_index] and band(tpl.vis.flags, F_FLYING) == 0 then
                            endless.only_fly_paths[wave.path_index] = false
                        end
                        if endless.only_water_paths[wave.path_index] and (not tpl.water) and band(tpl.vis.flags, F_FLYING) == 0 and band(tpl.vis.flags, F_FLYING_FAKE) == 0 then
                            endless.only_water_paths[wave.path_index] = false
                        end
                        endless.extra_cash = endless.extra_cash + (tpl.enemy.gold or 0) * spawn.max
                        if not endless.enemy_weight_map[spawn.creep] then
                            endless.enemy_weight_map[spawn.creep] = get_enemy_weight(spawn.creep)
                        end
                        if endless.special_paths[wave.path_index] then
                            endless.special_paths[wave.path_index] = nil
                        end
                    else
                        fixed_special_paths[wave.path_index] = true
                    end
                end
            end
        end
        for k, v in pairs(fixed_special_paths) do
            endless.special_paths[k] = true
        end
        for k, v in pairs(endless.special_paths) do
            endless.available_paths[k] = nil
            endless.only_fly_paths[k] = nil
            endless.only_water_paths[k] = nil
        end
        endless.enemy_list = table.keys(endless.enemy_weight_map)
        endless.spawn_count_per_wave = math.ceil(total_spawns / #endless.available_paths)

        endless.enemy_weight_per_wave = math.ceil(endless.total_enemy_weight / #endless.available_paths)
    end

    endless.enemy_upgrade_options = table.keys(endless.enemy_upgrade_levels)

    for k, v in pairs(endless.enemy_upgrade_levels) do
        if v >= EL.enemy_upgrade_max_levels[k] then
            table.removeobject(endless.enemy_upgrade_options, k)
        end
    end

    endless.upgrade_options = table.keys(endless.upgrade_levels)
    endless.gold_extra_upgrade_options = table.deepclone(EL.gold_extra_upgrade)

    for k, v in pairs(endless.upgrade_levels) do
        if v >= EL.upgrade_max_levels[k] then
            table.removeobject(endless.upgrade_options, k)
        end
        if EL.force_upgrade_max_levels[k] and v >= EL.force_upgrade_max_levels[k] then
            table.removeobject(endless.gold_extra_upgrade_options, k)
        end
    end
    return endless
end

function EU.generate_group(endless)
    local group = {}

    group.interval = endless.interval
    group.waves = {}
    local i = 1
    for _, path_id in pairs(endless.available_paths) do
        group.waves[i] = {
            delay = 0,
            path_index = path_id,
            spawns = {}
        }
        i = i + 1
    end
    -- 加权数量的敌人列表，模拟加权随机
    local enemy_list = {}

    local remain_enemy_weight = endless.total_enemy_weight
    while remain_enemy_weight > 0 do
        local template_name = table.random(endless.enemy_list)
        local weight = endless.enemy_weight_map[template_name]
        for j = 1, math.floor(20 / weight) do
            table.insert(enemy_list, template_name)
            remain_enemy_weight = remain_enemy_weight - weight
        end
    end

    for _, wave in pairs(group.waves) do
        local wave_enemy_list = enemy_list
        if endless.only_fly_paths[wave.path_index] then
            wave_enemy_list = {}
            for _, name in pairs(endless.enemy_list) do
                if band(E:get_template(name).vis.flags, F_FLYING) ~= 0 then
                    table.insert(wave_enemy_list, name)
                end
            end
        elseif endless.only_water_paths[wave.path_index] then
            wave_enemy_list = {}
            for _, name in pairs(endless.enemy_list) do
                local tpl = E:get_template(name)
                if tpl.water or band(tpl.vis.flags, F_FLYING) ~= 0 or band(tpl.vis.flags, F_FLYING_FAKE) ~= 0 then
                    table.insert(wave_enemy_list, name)
                end
            end
        end
        for j = 1, endless.spawn_count_per_wave do
            local this_spawn_weight = math.ceil(endless.enemy_weight_per_wave / endless.spawn_count_per_wave *
                                                    (0.8 + 0.4 * j / endless.spawn_count_per_wave))
            local function generate_creep_by_weight(i)
                if i <= 0 then
                    return table.random(wave_enemy_list), 0
                elseif #wave_enemy_list == 0 then
                    return enemy_list[1], 0
                end
                local creep = table.random(wave_enemy_list)
                local weight = endless.enemy_weight_map[creep]

                -- 避免前期就出 boss，太夸张了
                local max = math.floor(this_spawn_weight / weight)
                if max > 0 then
                    return creep, max
                else
                    return generate_creep_by_weight(i - 1)
                end
            end
            local creep_by_weight, max_by_weight = generate_creep_by_weight(5)
            wave.spawns[j] = {
                interval = endless.avg_interval,
                interval_next = endless.avg_interval_next,
                fixed_sub_path = 0,
                max = max_by_weight,
                creep = creep_by_weight
            }
        end
    end
    return group
end
function EU.patch_enemy_growth(endless)
    local imax = 2
    if math.random() < 0.1 then
        imax = 3
    end
    for i = 1, imax do
        if #endless.enemy_upgrade_options == 0 then
            break
        end
        local key = table.random(endless.enemy_upgrade_options)

        if key == "health" then
            endless.enemy_health_factor = endless.enemy_health_factor * enemy_buff.health_factor
        elseif key == "damage" then
            endless.enemy_damage_factor = endless.enemy_damage_factor * enemy_buff.damage_factor
        elseif key == "speed" then
            endless.enemy_speed_factor = endless.enemy_speed_factor * enemy_buff.speed_factor
        elseif key == "health_damage_factor" then
            endless.enemy_health_damage_factor = endless.enemy_health_damage_factor * enemy_buff.health_damage_factor
        elseif key == "lives" then
            endless.total_enemy_weight = math.ceil(endless.total_enemy_weight * enemy_buff.lives_cost_factor)

            endless.enemy_weight_per_wave = math.ceil(endless.total_enemy_weight / #endless.available_paths)

            if endless.enemy_weight_per_wave / endless.spawn_count_per_wave > 40 then
                endless.spawn_count_per_wave = endless.spawn_count_per_wave + 1
            end
            endless.avg_interval = endless.avg_interval / enemy_buff.lives_cost_factor
            if endless.avg_interval < 0.1 then
                endless.avg_interval = 0.1
            end
            endless.enemy_gold_factor = endless.enemy_gold_factor - 0.01
        elseif key == "wave_interval" then
            endless.avg_interval_next = endless.avg_interval_next * enemy_buff.wave_interval_factor
        elseif key == "instakill_resistance" then
            endless.enemy_instakill_resistance = endless.enemy_instakill_resistance + enemy_buff.instakill_resistance
        end
        endless.enemy_upgrade_levels[key] = endless.enemy_upgrade_levels[key] + 1
        if endless.enemy_upgrade_levels[key] >= enemy_upgrade_max_levels[key] then
            table.removeobject(endless.enemy_upgrade_options, key)
        end
    end
end

function EU.patch_archer_bleed(level)
    local mod = E:get_template("mod_blood_elves")
    mod.damage_factor = 0.1 + friend_buff.archer_bleed * level
end
function EU.patch_archer_insight(level)
    for _, name in pairs(UP:arrows()) do
        local arrow = E:get_template(name)
        if not arrow._endless_archer_insight then
            U.append_mod(arrow.bullet, "mod_endless_archer_insight")
        end
        local mod = E:get_template("mod_endless_archer_insight")
        mod.modifier.health_damage_factor_inc = level * friend_buff.archer_insight
    end
end
function EU.patch_archer_multishot(level)
    for _, name in pairs(table.append(UP:arrows(),{"arrow_arcane_burst"},true)) do
        local arrow = E:get_template(name)
        if not arrow._endless_multishot then
            arrow.main_script.insert = U.function_append(arrow.main_script.insert,
                scripts.arrow_endless_multishot.insert)
        end
        arrow._endless_multishot = level
    end
end
function EU.patch_archer_critical(level)
    for _, name in pairs(table.append(UP:arrows(),{"arrow_arcane_burst"},true)) do
        local arrow = E:get_template(name)
        if not arrow._endless_archer_critical then
            arrow.main_script.insert = U.function_append(function(this, store, script)
                if not this.bullet._endless_archer_critical then
                    this.bullet._endless_archer_critical = true
                    if math.random() < this._endless_archer_critical then
                        this.bullet.damage_factor = this.bullet.damage_factor * 3
                        if not (this.bullet.pop and table.contains(this.bullet.pop, "pop_headshot")) then
                            this.bullet.pop = {"pop_crit"}
                            this.bullet.pop_conds = DR_DAMAGE
                        end
                    end
                end

                return true
            end, arrow.main_script.insert)
        end
        arrow._endless_archer_critical = level * friend_buff.archer_critical
    end
end

function EU.patch_rain_count_inc(level)
    local controller = E:get_template("power_fireball_control")
    controller.cataclysm_count = controller.cataclysm_count + level * friend_buff.rain_count_inc
    controller.fireball_count = controller.fireball_count + level * friend_buff.rain_count_inc
end

function EU.patch_rain_damage_inc(level)
    local fireball = E:get_template("power_fireball")
    fireball.bullet.damage_min = fireball.bullet.damage_min + level * friend_buff.rain_damage_inc
    fireball.bullet.damage_max = fireball.bullet.damage_max + level * friend_buff.rain_damage_inc
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * friend_buff.rain_damage_inc * 0.1
    scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * friend_buff.rain_damage_inc * 0.1
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * friend_buff.rain_damage_inc * 0.1
    scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * friend_buff.rain_damage_inc * 0.1
    local thunder = E:get_template("power_thunder_control")
    thunder.thunders[1].damage_min = thunder.thunders[1].damage_min + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[1].damage_max = thunder.thunders[1].damage_max + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[2].damage_min = thunder.thunders[2].damage_min + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[2].damage_max = thunder.thunders[2].damage_max + level * friend_buff.rain_damage_inc * 0.5
    thunder = E:get_template("endless_mage_thunder")
    thunder.thunders[1].damage_min = thunder.thunders[1].damage_min + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[1].damage_max = thunder.thunders[1].damage_max + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[2].damage_min = thunder.thunders[2].damage_min + level * friend_buff.rain_damage_inc * 0.5
    thunder.thunders[2].damage_max = thunder.thunders[2].damage_max + level * friend_buff.rain_damage_inc * 0.5
end

function EU.patch_rain_radius_mul(level)
    local fireball = E:get_template("power_fireball")
    fireball.bullet.damage_radius = fireball.bullet.damage_radius * friend_buff.rain_radius_mul ^ level
    fireball.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.radius = scorched_water.aura.radius * friend_buff.rain_radius_mul ^ level
    scorched_water.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.radius = scorched_earth.aura.radius * friend_buff.rain_radius_mul ^ level
    scorched_earth.render.sprites[1].scale = vv(friend_buff.rain_radius_mul ^ level)
end

function EU.patch_rain_cooldown_dec(level)
    local controller = E:get_template("power_fireball_control")
    controller.cooldown = controller.cooldown - level * friend_buff.rain_cooldown_dec
end

function EU.patch_rain_scorch_damage_true(level)
    local scorched_earth = E:get_template("power_scorched_earth")
    scorched_earth.aura.damage_type = DAMAGE_TRUE
    scorched_earth.aura.damage_min = scorched_earth.aura.damage_min + level * friend_buff.rain_scorch_damage_true
    scorched_earth.aura.damage_max = scorched_earth.aura.damage_max + level * friend_buff.rain_scorch_damage_true
    local scorched_water = E:get_template("power_scorched_water")
    scorched_water.aura.damage_type = DAMAGE_TRUE
    scorched_water.aura.damage_min = scorched_water.aura.damage_min + level * friend_buff.rain_scorch_damage_true
    scorched_water.aura.damage_max = scorched_water.aura.damage_max + level * friend_buff.rain_scorch_damage_true
end

function EU.patch_rain_thunder(level)
    local controller = E:get_template("power_fireball_control")
    if not controller._endless_rain_thunder then
        controller.main_script.insert = U.function_append(controller.main_script.insert, function(this, store)
            local thunder = E:create_entity("power_thunder_control")
            thunder.slow.disabled = false
            thunder.rain.disabled = false
            thunder.thunders[1].count = this.fireball_count
            thunder.thunders[2].count = this.cataclysm_count
            queue_insert(store, thunder)
            return true
        end)
        controller._endless_rain_thunder = true
    end
end

function EU.patch_barrack_luck(level)
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        if not s._endless_barrack_luck then
            s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
                return math.random() > this._endless_barrack_luck
            end)
        end
        s._endless_barrack_luck = level * friend_buff.barrack_luck
    end
end

function EU.patch_barrack_unity(level)
    for _, name in pairs(UP:towers_with_barrack()) do
        if name ~= "tower_pandas_lvl4" then
            local t = E:get_template(name)
            t.barrack.max_soldiers = t.barrack.max_soldiers + level * friend_buff.barrack_unity_count
        end
    end
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        s.health.dead_lifetime = s.health.dead_lifetime - friend_buff.barrack_unity_lifetime * level
    end
end

function EU.patch_barrack_synergy(level)
    for _, name in pairs(UP:barrack_soldiers()) do
        local s = E:get_template(name)
        if not s._barrack_synergy then
            if s.main_script then
                s.main_script.insert = U.function_append(s.main_script.insert, function(this, store)
                    local a = E:create_entity("endless_barrack_synergy_aura")
                    a.aura.source_id = this.id
                    queue_insert(store, a)
                    this._barrack_synergy_aura = a
                    return true
                end)
                s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
                    if this._barrack_synergy_aura then
                        queue_remove(this._barrack_synergy_aura)
                    end
                    return true
                end)
            end
            s._barrack_synergy = true
        end
    end
    local m = E:get_template("mod_endless_barrack_synergy")
    m.extra_damage = level * friend_buff.barrack_synergy
end

function EU.patch_barrack_rally(level)
    for _, name in pairs(UP:towers_with_barrack()) do
        local t = E:get_template(name)
        t.barrack.rally_range = math.huge
    end
    local pixie_tower = E:get_template("tower_pixie")
    pixie_tower.attacks.range = math.huge
end
local bombs = {"bomb", "bomb_dynamite", "bomb_black", "bomb_musketeer", "dwarf_barrel", "pirate_watchtower_bomb",
               "bomb_molotov", "bomb_molotov_big", "bomb_bfg", "bomb_bfg_fragment", "bomb_mecha",
               "tower_tricannon_bomb", "tower_tricannon_bomb_bombardment_bomb", "rock_druid", "rock_entwood",
               "rock_druid","bullet_tower_demon_pit_basic_attack_lvl4", "bullet_tower_flamespitter_skill_bomb"}

function EU.patch_engineer_focus(level)
    for _, name in pairs(bombs) do
        local b = E:get_template(name)
        if not b._endless_engineer_focus then
            if name == "rock_druid" then
                b.main_script.update = function(this, store)
                    local b = this.bullet

                    this.render.sprites[1].z = Z_OBJECTS

                    S:queue(this.sound_events.load, {
                        delay = fts(4)
                    })
                    U.y_animation_play(this, "load", nil, store.tick_ts)
                    U.y_animation_play(this, "travel", nil, store.tick_ts)

                    this.tween.disabled = false

                    while not b.target_id do
                        coroutine.yield()
                    end

                    local fx = E:create_entity("fx_rock_druid_launch")

                    fx.pos.x, fx.pos.y = b.from.x, b.from.y
                    fx.render.sprites[1].ts = store.tick_ts
                    fx.render.sprites[1].flip_x = b.to.x < fx.pos.x

                    queue_insert(store, fx)

                    this.render.sprites[1].sort_y_offset = nil
                    this.render.sprites[1].z = Z_BULLETS
                    this.tween.disabled = true
                    b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)
                    b.ts = store.tick_ts
                    b.last_pos = V.vclone(b.from)
                    b.rotation_speed = b.rotation_speed * (b.to.x > b.from.x and -1 or 1)

                    engineer_focus_bomb_update(this, store)
                end
            else
                b.main_script.update = engineer_focus_bomb_update
            end
            b._endless_engineer_focus = true
        end
    end

    local tower = E:get_template("tower_tesla")
    tower.tower.damage_factor = tower.tower.damage_factor + level * friend_buff.engineer_focus * 0.8
    tower = E:get_template("tower_dwaarp")
    tower.tower.damage_factor = tower.tower.damage_factor + level * friend_buff.engineer_focus * 0.8
    tower = E:get_template("tower_frankenstein")
    tower.tower.damage_factor = tower.tower.damage_factor + level * friend_buff.engineer_focus * 0.8
    tower = E:get_template("tower_flamespitter_lvl4")
    tower.tower.damage_factor = tower.tower.damage_factor + level * friend_buff.engineer_focus * 0.8
    local missile = E:get_template("missile_bfg")
    if not missile.bullet._engineer_focus_damage_min then
        missile.bullet._engineer_focus_damage_min = missile.bullet.damage_min
        missile.bullet._engineer_focus_damage_max = missile.bullet.damage_max
    end
    missile.bullet.damage_min = missile.bullet._engineer_focus_damage_min * (1 + 0.8 * friend_buff.engineer_focus * level)
    missile.bullet.damage_max = missile.bullet._engineer_focus_damage_max * (1 + 0.8 * friend_buff.engineer_focus * level)
    missile = E:get_template("missile_mecha")
    if not missile.bullet._engineer_focus_damage_min then
        missile.bullet._engineer_focus_damage_min = missile.bullet.damage_min
        missile.bullet._engineer_focus_damage_max = missile.bullet.damage_max
    end
    missile.bullet.damage_min = missile.bullet._engineer_focus_damage_min * (1 + 0.8 * friend_buff.engineer_focus * level)
    missile.bullet.damage_max = missile.bullet._engineer_focus_damage_max * (1 + 0.8 * friend_buff.engineer_focus * level)
end

local function endless_engineer_aftermath_ray_remove(this, store)
    local after_math = E:create_entity("aura_endless_engineer_aftermath_ray")

    after_math.pos.x, after_math.pos.y = this.bullet.to.x, this.bullet.to.y
    after_math.aura.source_id = this.id
    after_math.aura.level = store.endless.upgrade_levels.engineer_aftermath
    queue_insert(store, after_math)
    return true
end

function EU.patch_engineer_aftermath(level)
    for _, name in pairs(table.append(bombs, {"missile_mecha"}, true)) do
        local b = E:get_template(name)
        if not b._endless_engineer_aftermath then
            U.append_mod(b.bullet, "mod_endless_engineer_aftermath")
            b._endless_engineer_aftermath = true
        end
    end
    local dwarrp_attack = E:get_template("tower_dwaarp").attacks.list[1]
    if not dwarrp_attack._endless_engineer_aftermath then
        U.append_mod(dwarrp_attack, "mod_endless_engineer_aftermath")
        dwarrp_attack._endless_engineer_aftermath = true
    end
    local mod = E:get_template("mod_endless_engineer_aftermath")
    mod.value = level * friend_buff.engineer_aftermath
    local ray = E:get_template("ray_tesla")
    if not ray._endless_engineer_aftermath then
        ray.main_script.remove = U.function_append(ray.main_script.remove, endless_engineer_aftermath_ray_remove)
        ray._endless_engineer_aftermath = true
    end
    ray = E:get_template("ray_frankenstein")
    if not ray._endless_engineer_aftermath then
        ray.main_script.remove = U.function_append(ray.main_script.remove, endless_engineer_aftermath_ray_remove)
        ray._endless_engineer_aftermath = true
    end
    local tower = E:get_template("tower_flamespitter_lvl4")
    if not tower._endless_engineer_aftermath then
        tower.attacks.range = tower.attacks.range * (1 + friend_buff.engineer_seek)
        tower._endless_engineer_aftermath = true
        tower._endless_engineer_aftermath_last_level = 0
    end
    tower.tower.damage_factor = tower.tower.damage_factor + (level - tower._endless_engineer_aftermath_last_level) * friend_buff.engineer_aftermath * 0.8
    tower._endless_engineer_aftermath_last_level = level
end

function EU.patch_engineer_seek(level)
    local t = E:get_template("tower_engineer_1")
    local function clear_flying_bans(attack)
        attack.vis_bans = U.flag_clear(attack.vis_bans, F_FLYING)
    end
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_engineer_2")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_engineer_3")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_bfg")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("soldier_mecha")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_druid")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_entwood")
    clear_flying_bans(t.attacks.list[1])
    clear_flying_bans(t.attacks.list[2])
    t = E:get_template("tower_tricannon_lvl4")
    clear_flying_bans(t.attacks.list[1])
    clear_flying_bans(t.attacks.list[2])
    t = E:get_template("soldier_mecha")
    clear_flying_bans(t.attacks.list[1])
    t = E:get_template("tower_tesla")
    t.attacks.range = t.attacks.range * (1 + level * friend_buff.engineer_seek)
    t.attacks.list[1].range = t.attacks.list[1].range * (1 + level * friend_buff.engineer_seek)
    t = E:get_template("tower_frankenstein")
    t.attacks.range = t.attacks.range * (1 + level * friend_buff.engineer_seek)
    t = E:get_template("tower_dwaarp")
    t.attacks.range = t.attacks.range * (1 + level * friend_buff.engineer_seek)
    t = E:get_template("tower_flamespitter_lvl4")
    t.attacks.range = t.attacks.range * (1 + level * friend_buff.engineer_seek)
end

local function fireball_quick_up(this, store)
    store.game_gui.power_1:wait_time_dec(fts(friend_buff.engineer_fireball *
                                                 store.endless.upgrade_levels.engineer_fireball))
    return true
end

function EU.patch_engineer_fireball(level)
    for _, name in pairs(bombs) do
        local b = E:get_template(name)
        if not b._endless_engineer_fireball then
            b.main_script.remove = U.function_append(b.main_script.remove, fireball_quick_up)
            b._endless_engineer_fireball = true
        end
    end
    local ray = E:get_template("ray_tesla")
    if not ray._endless_engineer_fireball then
        ray.main_script.remove = U.function_append(ray.main_script.remove, fireball_quick_up)
        ray._endless_engineer_fireball = true
    end
    ray = E:get_template("ray_frankenstein")
    if not ray._endless_engineer_fireball then
        ray.main_script.remove = U.function_append(ray.main_script.remove, fireball_quick_up)
        ray._endless_engineer_fireball = true
    end
    local flame = E:get_template("fx_tower_flamespitter_flame")
    if not flame._endless_engineer_fireball then
        E:add_comps(flame, "main_script")
        flame._endless_engineer_fireball = true
        flame.main_script.remove = U.function_append(flame.main_script.remove, fireball_quick_up)
    end
end

function EU.patch_mage_thunder(level)
    for _, name in pairs(table.append(UP:bolts(), {"ray_arcane_disintegrate", "bullet_tower_ray_lvl4"}, true)) do
        local bolt = E:get_template(name)
        if not bolt._endless_mage_thunder then
            bolt._endless_mage_thunder = true
            if (bolt.bullet and bolt.bullet.damage_max and bolt.bullet.damage_max >= 50) or bolt.template_name ==
                "ray_arcane" then
                bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
                    local target = store.entities[this.bullet.target_id]
                    if not target or target.health.dead then
                        return true
                    end
                    if math.random() < store.endless.upgrade_levels.mage_thunder * friend_buff.mage_thunder_normal then
                        local thunder = E:create_entity("endless_mage_thunder")
                        thunder.pos = V.vclone(target.pos)
                        queue_insert(store, thunder)
                    end
                    return true
                end)
            else
                bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
                    local target = store.entities[this.bullet.target_id]
                    if not target or target.health.dead then
                        return true
                    end
                    if math.random() < store.endless.upgrade_levels.mage_thunder * friend_buff.mage_thunder_small then
                        local thunder = E:create_entity("endless_mage_thunder")
                        thunder.pos = V.vclone(target.pos)
                        queue_insert(store, thunder)
                    end
                    return true
                end)
            end
        end
    end
    local mod_pixie_pickpocket = E:get_template("mod_pixie_pickpocket")
    if not mod_pixie_pickpocket._endless_mage_thunder then
        mod_pixie_pickpocket._endless_mage_thunder = true
        mod_pixie_pickpocket.main_script.insert = U.function_append(mod_pixie_pickpocket.main_script.insert,
            function(this, store)
                local target = store.entities[this.modifier.target_id]
                if not target or target.health.dead then
                    return true
                end
                if math.random() < store.endless.upgrade_levels.mage_thunder * friend_buff.mage_thunder_normal then
                    local thunder = E:create_entity("endless_mage_thunder")
                    thunder.pos = V.vclone(target.pos)
                    queue_insert(store, thunder)
                end
                return true
            end)
    end
end

function EU.patch_mage_shatter(level)
    for _, name in pairs(table.append(UP:bolts(), {"bullet_pixie_poison"}, true)) do
        local bolt = E:get_template(name)
        if not bolt._endless_mage_shatter then
            bolt._endless_mage_shatter = true
            bolt.main_script.insert = U.function_append(bolt.main_script.insert, function(this, store)
                local target = store.entities[this.bullet.target_id]
                if not target or target.health.dead then
                    return true
                end
                if not this.bullet._endless_mage_shatter then
                    this.bullet.damage_factor = this.bullet.damage_factor *
                                                    (1 + target.health.armor * store.endless.upgrade_levels.mage_shatter *
                                                        friend_buff.mage_shatter)
                    this.bullet._endless_mage_shatter = true
                end
                return true
            end)
        end
    end
end

function EU.patch_mage_chain(level)
    for _, name in pairs(table.append(UP:bolts(),
        {"bullet_pixie_poison", "bullet_pixie_instakill", "ray_arcane_disintegrate"})) do
        local bolt = E:get_template(name)
        if not bolt._endless_mage_chain then
            bolt._endless_mage_chain = true
            bolt.main_script.remove = U.function_append(bolt.main_script.remove, function(this, store)
                local target = store.entities[this.bullet.target_id]
                if not target or target.health.dead then
                    return true
                end
                if not this.bullet._endless_mage_chain then
                    local enemies = U.find_enemies_in_range(store, target.pos, 0, friend_buff.mage_chain_radius,
                        F_RANGED, 0, function(e)
                            return e.id ~= target.id
                        end)
                    if enemies then
                        for i=1, #enemies do
                            local enemy = enemies[i]
                            local bolt = E:create_entity(this.template_name)
                            bolt.bullet.target_id = enemy.id
                            bolt.bullet.from = V.v(target.pos.x + target.unit.hit_offset.x,
                                target.pos.y + target.unit.hit_offset.y)
                            bolt.pos = V.vclone(bolt.bullet.from)
                            bolt.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x,
                                enemy.pos.y + enemy.unit.hit_offset.y)
                            bolt.bullet.damage_factor = bolt.bullet.damage_factor * friend_buff.mage_chain *
                                                            store.endless.upgrade_levels.mage_chain
                            bolt.bullet._endless_mage_chain = true
                            if bolt.tween then
                                bolt.tween.ts = store.tick_ts
                            end
                            if this.bullet.payload then
                                local payload = E:create_entity(this.bullet.payload.template_name)
                                if payload.bullet then
                                    payload.bullet.level = this.bullet.payload.bullet.level
                                    payload.bullet.damage_factor = this.bullet.payload.bullet.damage_factor
                                end
                                bolt.bullet.payload = payload
                            end
                            if this.bullet.shot_index then
                                bolt.bullet.shot_index = this.bullet.shot_index
                            end
                            queue_insert(store, bolt)

                        end

                    end

                end
                return true
            end)
        end
    end
end

function EU.patch_mage_curse(level)
    local curse = E:get_template("mod_slow_curse")
    curse.slow.factor = friend_buff.mage_curse_factor
    curse.slow.duration = friend_buff.mage_curse_duration
end

function EU.patch_upgrade_in_game(key, store, endless)
    if not key then
        return
    end
    endless.upgrade_levels[key] = endless.upgrade_levels[key] + 1
    if endless.upgrade_levels[key] >= EL.upgrade_max_levels[key] then
        table.removeobject(endless.upgrade_options, key)
    end
    if EL.force_upgrade_max_levels[key] and endless.upgrade_levels[key] >= EL.force_upgrade_max_levels[key] then
        table.removeobject(endless.gold_extra_upgrade_options, key)
    end
    if key == "ban_rain" then
        for _, name in pairs(EL.rain) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    elseif key == "ban_archer" then
        for _, name in pairs(EL.archer) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)

        end
    elseif key == "ban_barrack" then
        for _, name in pairs(EL.barrack) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    elseif key == "ban_engineer" then
        for _, name in pairs(EL.engineer) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    elseif key == "ban_mage" then
        for _, name in pairs(EL.mage) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    elseif key == "health" then
        for _, s in pairs(store.soldiers) do
            if s.health then
                s.health.hp_max = s.health.hp_max * friend_buff.health_factor
                s.health.hp = s.health.hp_max
            end
        end
        endless.soldier_health_factor = endless.soldier_health_factor * friend_buff.health_factor
    elseif key == "soldier_damage" then
        for _, s in pairs(store.soldiers) do
            if s.unit then
                s.unit.damage_factor = s.unit.damage_factor * friend_buff.soldier_damage_factor
            end
        end
        endless.soldier_damage_factor = endless.soldier_damage_factor * friend_buff.soldier_damage_factor
    elseif key == "soldier_cooldown" then
        for _, s in pairs(store.soldiers) do
            if s.cooldown_factor then
                s.cooldown_factor = s.cooldown_factor * friend_buff.soldier_cooldown_factor
            end
        end
        endless.soldier_cooldown_factor = endless.soldier_cooldown_factor * friend_buff.soldier_cooldown_factor
    elseif key == "tower_damage" then
        for _, t in pairs(store.towers) do
            SU.insert_tower_damage_factor_buff(t, friend_buff.tower_damage_factor)
        end
        endless.tower_damage_factor = endless.tower_damage_factor + friend_buff.tower_damage_factor
    elseif key == "tower_cooldown" then
        for _, t in pairs(store.towers) do
            SU.insert_tower_cooldown_buff(store.tick_ts, t, friend_buff.tower_cooldown_factor)
        end
        endless.tower_cooldown_factor = endless.tower_cooldown_factor * friend_buff.tower_cooldown_factor
    elseif key == "hero_damage" then
        for _, h in pairs(store.soldiers) do
            if h.hero then
                h.unit.damage_factor = h.unit.damage_factor * friend_buff.hero_damage_factor
                h.health.hp_max = h.health.hp_max * friend_buff.hero_health_factor
                h.health.hp = h.health.hp_max
            end
        end
        endless.hero_damage_factor = endless.hero_damage_factor * friend_buff.hero_damage_factor
        endless.hero_health_factor = endless.hero_health_factor * friend_buff.hero_health_factor
    elseif key == "hero_cooldown" then
        for _, h in pairs(store.soldiers) do
            if h.hero then
                h.cooldown_factor = h.cooldown_factor * friend_buff.hero_cooldown_factor
            end
        end
        endless.hero_cooldown_factor = endless.hero_cooldown_factor * friend_buff.hero_cooldown_factor
    elseif key == "archer_bleed" then
        EU.patch_archer_bleed(endless.upgrade_levels[key])
    elseif key == "archer_multishot" then
        EU.patch_archer_multishot(endless.upgrade_levels[key])
    elseif key == "archer_insight" then
        EU.patch_archer_insight(endless.upgrade_levels[key])
    elseif key == "archer_critical" then
        EU.patch_archer_critical(endless.upgrade_levels[key])
    elseif key == "rain_count_inc" then
        EU.patch_rain_count_inc(1)
    elseif key == "rain_damage_inc" then
        EU.patch_rain_damage_inc(1)
    elseif key == "rain_radius_mul" then
        EU.patch_rain_radius_mul(1)
    elseif key == "rain_cooldown_dec" then
        EU.patch_rain_cooldown_dec(1)
        store.game_gui.power_1:set_cooldown_time(E:get_template("power_fireball_control").cooldown)
    elseif key == "rain_scorch_damage_true" then
        EU.patch_rain_scorch_damage_true(1)
    elseif key == "rain_thunder" then
        EU.patch_rain_thunder(1)
    elseif key == "more_gold" then
        endless.enemy_gold_factor = endless.enemy_gold_factor + friend_buff.more_gold
    elseif key == "barrack_rally" then
        for _, t in pairs(store.towers) do
            if t.barrack then
                t.barrack.rally_range = math.huge
            end
        end
        EU.patch_barrack_rally(endless.upgrade_levels[key])
    elseif key == "barrack_unity" then
        for _, t in pairs(store.towers) do
            if t.barrack then
                t.barrack.max_soldiers = t.barrack.max_soldiers + friend_buff.barrack_unity_count
            elseif t.template_name == "tower_pixie" then
                t.attacks.range = math.huge
            end
        end
        EU.patch_barrack_unity(endless.upgrade_levels[key])
    elseif key == "barrack_luck" then
        EU.patch_barrack_luck(endless.upgrade_levels[key])
        for _, s in pairs(store.soldiers) do
            if s.health then
                if not s._endless_barrack_luck then
                    s.health.on_damage = U.function_append(s.health.on_damage, function(this, store, damage)
                        return math.random() > this._endless_barrack_luck
                    end)
                end
                s._endless_barrack_luck = endless.upgrade_levels[key] * friend_buff.barrack_luck
            end
        end
    elseif key == "barrack_synergy" then
        for _, s in pairs(store.soldiers) do
            if not s._barrack_synergy_aura then
                local a = E:create_entity("endless_barrack_synergy_aura")
                a.aura.source_id = s.id
                queue_insert(store, a)
                s._barrack_synergy_aura = a
                if s.main_script then
                    s.main_script.remove = U.function_append(s.main_script.remove, function(this, store)
                        if this._barrack_synergy_aura then
                            queue_remove(this._barrack_synergy_aura)
                        end
                        return true
                    end)
                end
            end
        end
        EU.patch_barrack_synergy(endless.upgrade_levels[key])
    elseif key == "engineer_focus" then
        for _, t in pairs(store.towers) do
            if t.template_name == "tower_tesla" or t.template_name == "tower_dwaarp" or t.template_name ==
                "tower_frankenstein" or t.template_name == "tower_flamespitter_lvl4" then
                t.tower.damage_factor = t.tower.damage_factor + friend_buff.engineer_focus * 0.8
            end
        end
        EU.patch_engineer_focus(1)
    elseif key == "engineer_aftermath" then
        EU.patch_engineer_aftermath(endless.upgrade_levels[key])
    elseif key == "engineer_seek" then
        EU.patch_engineer_seek(endless.upgrade_levels[key])
        for _, t in pairs(store.towers) do
            if table.contains({"tower_engineer_1", "tower_engineer_2", "tower_engineer_3", "tower_bfg", "tower_druid",
                               "tower_entwood", "tower_tricannon_lvl4"}, t.template_name) then
                t.attacks.list[1].vis_bans = U.flag_clear(t.attacks.list[1].vis_bans, F_FLYING)
            end
            if t.template_name == "tower_entwood" or t.template_name == "tower_tricannon_lvl4" then
                t.attacks.list[2].vis_bans = U.flag_clear(t.attacks.list[2].vis_bans, F_FLYING)
            elseif t.template_name == "tower_tesla" then
                t.attacks.range = t.attacks.range * (1 + friend_buff.engineer_seek)
                t.attacks.list[1].range = t.attacks.list[1].range * (1 + friend_buff.engineer_seek)
            elseif t.template_name == "tower_frankenstein" then
                t.attacks.range = t.attacks.range * (1 + friend_buff.engineer_seek)
            elseif t.template_name == "tower_dwaarp" then
                t.attacks.range = t.attacks.range * (1 + friend_buff.engineer_seek)
            elseif t.template_name == "tower_mech" then
                for _, s in pairs(t.barrack.soldiers) do
                    s.attacks.list[1].vis_bans = U.flag_clear(s.attacks.list[1].vis_bans, F_FLYING)
                end
            elseif t.template_name == "tower_flamespitter_lvl4" then
                t.attacks.range = t.attacks.range * (1 + friend_buff.engineer_seek)
            end
        end
    elseif key == "engineer_fireball" then
        EU.patch_engineer_fireball(1)
    elseif key == "mage_thunder" then
        EU.patch_mage_thunder(endless.upgrade_levels[key])
    elseif key == "mage_shatter" then
        EU.patch_mage_shatter(endless.upgrade_levels[key])
    elseif key == "mage_chain" then
        EU.patch_mage_chain(endless.upgrade_levels[key])
    elseif key == "mage_curse" then
        EU.patch_mage_curse(endless.upgrade_levels[key])
    end
end

function EU.patch_upgrades(endless)
    if endless.upgrade_levels.archer_bleed > 0 then
        EU.patch_archer_bleed(endless.upgrade_levels.archer_bleed)
    end
    if endless.upgrade_levels.archer_multishot > 0 then
        EU.patch_archer_multishot(endless.upgrade_levels.archer_multishot)
    end
    if endless.upgrade_levels.archer_insight > 0 then
        EU.patch_archer_insight(endless.upgrade_levels.archer_insight)
    end
    if endless.upgrade_levels.archer_critical > 0 then
        EU.patch_archer_critical(endless.upgrade_levels.archer_critical)
    end
    if endless.upgrade_levels.rain_count_inc > 0 then
        EU.patch_rain_count_inc(endless.upgrade_levels.rain_count_inc)
    end
    if endless.upgrade_levels.rain_damage_inc > 0 then
        EU.patch_rain_damage_inc(endless.upgrade_levels.rain_damage_inc)
    end
    if endless.upgrade_levels.rain_radius_mul > 0 then
        EU.patch_rain_radius_mul(endless.upgrade_levels.rain_radius_mul)
    end
    if endless.upgrade_levels.rain_cooldown_dec > 0 then
        EU.patch_rain_cooldown_dec(endless.upgrade_levels.rain_cooldown_dec)
    end
    if endless.upgrade_levels.rain_scorch_damage_true > 0 then
        EU.patch_rain_scorch_damage_true(endless.upgrade_levels.rain_scorch_damage_true)
    end
    if endless.upgrade_levels.rain_thunder > 0 then
        EU.patch_rain_thunder(endless.upgrade_levels.rain_thunder)
    end
    if endless.upgrade_levels.barrack_rally > 0 then
        EU.patch_barrack_rally(endless.upgrade_levels.barrack_rally)
    end
    if endless.upgrade_levels.barrack_luck > 0 then
        EU.patch_barrack_luck(endless.upgrade_levels.barrack_luck)
    end
    if endless.upgrade_levels.barrack_unity > 0 then
        EU.patch_barrack_unity(endless.upgrade_levels.barrack_unity)
    end
    if endless.upgrade_levels.barrack_synergy > 0 then
        EU.patch_barrack_synergy(endless.upgrade_levels.barrack_synergy)
    end
    if endless.upgrade_levels.engineer_focus > 0 then
        EU.patch_engineer_focus(endless.upgrade_levels.engineer_focus)
    end
    if endless.upgrade_levels.engineer_aftermath > 0 then
        EU.patch_engineer_aftermath(endless.upgrade_levels.engineer_aftermath)
    end
    if endless.upgrade_levels.engineer_seek > 0 then
        EU.patch_engineer_seek(endless.upgrade_levels.engineer_seek)
    end
    if endless.upgrade_levels.engineer_fireball > 0 then
        EU.patch_engineer_fireball(endless.upgrade_levels.engineer_fireball)
    end
    if endless.upgrade_levels.mage_thunder > 0 then
        EU.patch_mage_thunder(endless.upgrade_levels.mage_thunder)
    end
    if endless.upgrade_levels.mage_shatter > 0 then
        EU.patch_mage_shatter(endless.upgrade_levels.mage_shatter)
    end
    if endless.upgrade_levels.mage_chain > 0 then
        EU.patch_mage_chain(endless.upgrade_levels.mage_chain)
    end
    if endless.upgrade_levels.mage_curse > 0 then
        EU.patch_mage_curse(endless.upgrade_levels.mage_curse)
    end
    if endless.upgrade_levels.ban_rain > 0 then
        for _, name in pairs(EL.rain) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    end
    if endless.upgrade_levels.ban_archer > 0 then
        for _, name in pairs(EL.archer) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    end
    if endless.upgrade_levels.ban_barrack > 0 then
        for _, name in pairs(EL.barrack) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    end
    if endless.upgrade_levels.ban_engineer > 0 then
        for _, name in pairs(EL.engineer) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    end
    if endless.upgrade_levels.ban_mage > 0 then
        for _, name in pairs(EL.mage) do
            table.removeobject(endless.upgrade_options, name)
            table.removeobject(endless.gold_extra_upgrade_options, name)
        end
    end
end

return EU
