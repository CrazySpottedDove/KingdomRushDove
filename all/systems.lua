-- chunkname: @./all/systems.lua
local log = require("klua.log"):new("systems")
local log_xp = log.xp or log:new("xp")
local log_hp = log.hp or log:new("hp")
local km = require("klua.macros")
local signal = require("hump.signal")

require("klua.table")
require("klua.dump")
local EU = require("endless_utils")
local A = require("animation_db")
local AC = require("achievements")
local DI = require("difficulty")
local I = require("klove.image_db")
local SH = require("klove.shader_db")
local E = require("entity_db")
local P = require("path_db")
local F = require("klove.font_db")
local GR = require("grid_db")
local GS = require("game_settings")
local S = require("sound_db")
local UP = require("upgrades")
local W = require("wave_db")
local U = require("utils")
local SU = require("script_utils")
local LU = require("level_utils")
local V = require("klua.vector")
local storage = require("storage")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local random = math.random
local ceil = math.ceil
local floor = math.floor
require("constants")

local function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

local function fts(v)
    return v / FPS
end

-- 在文件开头添加性能监控模块
local perf = {}
perf.timers = {}
perf.frame_times = {}
perf.system_times = {}
perf.report_interval = 5 -- 每5秒输出一次报告
perf.max_samples = perf.report_interval / TICK_LENGTH -- 保存最近5秒数据

-- 性能计时器函数
function perf.start_timer(name)
    perf.timers[name] = love.timer.getTime()
end

function perf.end_timer(name)
    if perf.timers[name] then
        local elapsed = love.timer.getTime() - perf.timers[name]
        perf.system_times[name] = perf.system_times[name] or {}
        table.insert(perf.system_times[name], elapsed)

        -- 保持样本数量在限制内
        if #perf.system_times[name] > perf.max_samples then
            table.remove(perf.system_times[name], 1)
        end

        perf.timers[name] = nil
        return elapsed
    end
    return 0
end

-- 生成性能报告
function perf.generate_report(store)
    local report = {"=== 性能报告 ==="}

    -- 整体帧率信息
    if #perf.frame_times > 0 then
        local total_time = 0
        for _, time in ipairs(perf.frame_times) do
            total_time = total_time + time
        end
        local fps = #perf.frame_times / total_time
        table.insert(report, string.format("平均FPS: %.1f", fps))
    end

    -- 计算各系统在这段时间内的总开销
    local system_costs = {}
    for name, times in pairs(perf.system_times) do
        if #times > 0 then
            local total_cost = 0
            for _, time in ipairs(times) do
                total_cost = total_cost + time
            end
            if total_cost > 0 then
                system_costs[name] = {
                    total = total_cost * 1000, -- 转换为毫秒
                    calls = #times
                }
            end
        end
    end

    -- 按总开销排序
    local sorted_costs = {}
    for name, data in pairs(system_costs) do
        table.insert(sorted_costs, {
            name = name,
            total = data.total,
            calls = data.calls
        })
    end

    table.sort(sorted_costs, function(a, b)
        return a.total > b.total
    end)

    -- 输出排序后的结果
    table.insert(report, "\n系统开销排行 (总耗时ms/调用次数):")

    -- 先打印开销总和
    local grand_total = 0
    for _, item in ipairs(sorted_costs) do
        grand_total = grand_total + item.total
    end
    table.insert(report, string.format("总系统开销: %.4fms", grand_total))

    -- 然后打印各个分项
    for i, item in ipairs(sorted_costs) do
        table.insert(report, string.format("%4d. %s: %.4fms (%d次)", i, item.name, item.total, item.calls))

        -- 只显示前15个最耗时的
        if i >= 15 then
            table.insert(report, "    ...")
            break
        end
    end

    -- 简单的实体统计
    if store then
        table.insert(report, string.format("\n实体数: %d | 渲染帧: %d", store.entity_count, #store.render_frames))
    end

    return table.concat(report, "\n")
end

function perf.save_store_entities(store)
    local entities = {}
    for _, e in pairs(store.entities) do
        if not entities[e.template_name] then
            entities[e.template_name] = 1
        else
            entities[e.template_name] = entities[e.template_name] + 1
        end
    end
    local filename = string.format("perf_entities_%d.txt", os.time())
    local file = love.filesystem.newFile(filename, "w")
    file:open("w")
    file:write("=== 当前实体统计 ===\n")
    local total_count = 0
    for name, count in pairs(entities) do
        file:write(string.format("%s: %d\n", name, count))
        total_count = total_count + count
    end
    file:write(string.format("总实体数: %d\n", total_count))
    file:write(string.format("store 记录总实体数: %d\n", store.entity_count))

    file:close()
end

function perf.save_report(store)
    local report = perf.generate_report(store)
    print(report)
end

local sys = {}

sys.level = {}
sys.level.name = "level"

function sys.level:init(store)
    local slot = storage:load_slot(nil, true)

    UP:set_levels(slot.upgrades)
    DI:set_level(store.level_difficulty)
    GR:load(store.level_name)
    P:load(store.level_name, store.visible_coords)
    if store.config.reverse_path then
        P:reverse_all_paths()
    end
    E:load()
    UP:patch_templates(store.level.max_upgrade_level or GS.max_upgrade_level)
    DI:patch_templates()

    W:load(store.level_name, store.level_mode, store.level_mode_override == GAME_MODE_ENDLESS)
    if store.criket and store.criket.on then
        W:patch_waves(store.criket)
    end
    A:load()
    store.selected_hero = slot.heroes.selected
    if store.selected_hero and #store.selected_hero > 0 then
        store.selected_hero_status = slot.heroes.status[slot.heroes.selected[1]]
    end

    if store.level.init then
        store.level:init(store)
    end

    if store.level.data then
        store.level.locations = {}
        LU.insert_entities(store, store.level.data.entities_list)
        LU.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)
    end

    if store.level.load then
        store.level:load(store)
    end

    store.level.co = nil
    store.level.run_complete = nil
    store.player_gold = ceil(W:initial_gold() * store.config.gold_multiplier)
    if store.criket and store.criket.on then
        store.player_gold = store.criket.cash
    end

    if slot.locked_towers then
        for _, tower in pairs(slot.locked_towers) do
            if not table.find(store.level.locked_towers, tower) then
                table.insert(store.level.locked_towers, tower)
            end
        end
    end

    for _, unlock_tower in pairs(store.level.unlock_towers) do
        table.removeobject(store.level.locked_towers, unlock_tower)
    end
    if store.criket and store.criket.on then
        store.lives = 0
    elseif store.level_mode == GAME_MODE_CAMPAIGN then
        store.lives = 20
    elseif store.level_mode == GAME_MODE_HEROIC then
        store.lives = 1
    elseif store.level_mode == GAME_MODE_IRON then
        store.lives = 1
    end
    if store.level_mode_override == GAME_MODE_ENDLESS then
        store.lives = 20
        store.player_gold = store.player_gold + W.endless.extra_cash
        store.endless = W.endless
        local endless_data = store.endless
        if endless_data.upgrade_levels then
            EU.patch_upgrades(endless_data)
        end
        if endless_data.player_gold then
            store.player_gold = endless_data.player_gold
        end
        if endless_data.lives then
            store.lives = endless_data.lives
        end
        if endless_data.wave_group_number then
            store.wave_group_number = endless_data.wave_group_number
        end
        if endless_data.towers then
            for _, tower_data in ipairs(endless_data.towers) do
                local tower = E:create_entity(tower_data.template_name)
                tower.pos = V.v(tower_data.pos.x, tower_data.pos.y)
                tower.tower.level = tower_data.tower_level
                tower.tower.spent = tower_data.spent
                tower.tower.holder_id = tower_data.holder_id
                for _, e in pairs(store.pending_inserts) do
                    if e.tower and e.tower.holder_id == tower.tower.holder_id then
                        if e.template_name == tower.template_name then
                            -- 说明是同一座塔，移除待插入的旧数据
                            goto continue
                        end
                        tower.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
                        if tower.ui and e.ui then
                            tower.ui.nav_mesh_id = e.ui.nav_mesh_id
                        end
                        queue_remove(store, e)
                    end
                end
                tower.tower.flip_x = tower_data.flip_x
                if tower_data.terrain_style then
                    tower.tower.terrain_style = tower_data.terrain_style
                    tower.render.sprites[1].name =
                        string.format(tower.render.sprites[1].name, tower.tower.terrain_style)
                end

                -- 恢复技能等级
                if tower_data.powers and tower.powers then
                    for power_name, power_data in pairs(tower_data.powers) do
                        if tower.powers[power_name] then
                            tower.powers[power_name].level = power_data.level
                            tower.powers[power_name].changed = true
                        end
                    end
                end

                -- 恢复集结点
                if tower_data.rally_pos and tower.barrack then
                    tower.barrack.rally_pos = V.v(tower_data.rally_pos.x, tower_data.rally_pos.y)
                    if tower.mercenary then
                        for i = 1, tower_data.soldier_count do
                            tower.barrack.soldiers[i] = E:create_entity(tower.barrack.soldier_type)
                            tower.barrack.soldiers[i].health.dead = true
                            tower.barrack.soldiers[i].id = -1
                        end
                    end
                end

                queue_insert(store, tower)
                ::continue::
            end
        end

    end

    store.gems_collected = 0
    store.player_score = 0
    store.game_outcome = nil
    store.main_hero = nil

    log.info("level_idx:%02d, level_mode:%d, level_difficulty:%d", store.level_idx, store.level_mode,
        store.level_difficulty)
end

function sys.level:on_update(dt, ts, store)
    local function store_hero_xp(slot)
        if store.main_hero and store.main_hero.hero and not GS.hero_xp_ephemeral then
            local hn = store.main_hero.template_name

            if not slot.heroes or not slot.heroes.status or not slot.heroes.status[hn] then
                log.error("Active slot has no heroes status information. Skipping save")
            elseif store.main_hero.hero.xp > slot.heroes.status[hn].xp then
                slot.heroes.status[hn].xp = store.main_hero.hero.xp
            end
        end
    end

    if not store.level.update then
        store.level.run_complete = true
    else
        if not store.level.co and not store.level.run_complete then
            store.level.co = coroutine.create(store.level.update)
        end

        if store.level.co then
            local success, error = coroutine.resume(store.level.co, store.level, store)

            if coroutine.status(store.level.co) == "dead" or error ~= nil then
                if error ~= nil then
                    log.error("Error running level coro: %s", debug.traceback(store.level.co, error))
                end

                store.level.co = nil
                store.level.run_complete = true
            end
        end
    end

    if not store._common_notifications then
        local slot = storage:load_slot()

        store._common_notifications = true

        if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
            signal.emit("wave-notification", "view", "TIP_UPGRADES")
        elseif store.level_mode_override == GAME_MODE_ENDLESS then
            signal.emit("wave-notification", "view", "TIP_SURVIVAL")
        elseif KR_GAME == "kr1" and store.selected_hero and #store.selected_hero ~= 0 and
            not U.is_seen(store, "TIP_HEROES") then
            signal.emit("wave-notification", "icon", "TIP_HEROES")
        elseif KR_GAME == "kr1" and store.level_mode == GAME_MODE_CAMPAIGN and store.level_idx >= 13 and
            U.count_stars(slot) < 50 and not U.is_seen(store, "TIP_ELITE") then
            signal.emit("wave-notification", "view", "TIP_ELITE")
        end
    end

    if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
        LU.insert_hero(store)
    end

    if not store.game_outcome then

        if store.lives < 1 and (not store.criket or not store.criket.on) then
            log.info("++++ DEFEAT ++++")

            store.game_outcome = {
                victory = false,
                level_idx = store.level_idx,
                level_mode = store.level_mode,
                level_difficulty = store.level_difficulty
            }
            store.paused = true
            store.defeat_count = (store.defeat_count or 0) + 1

            local slot = storage:load_slot()

            slot.last_victory = nil

            store_hero_xp(slot)

            slot.gems = (slot.gems or 0) + store.gems_collected

            -- if store.level_mode_override == GAME_MODE_ENDLESS then
            --     local slot_level = slot.levels[store.level_idx]

            --     slot_level = slot_level or {}

            --     if not slot_level[store.level_difficulty] then
            --         slot_level[store.level_difficulty] = {
            --             waves_survived = 0,
            --             high_score = 0
            --         }
            --         slot.levels[store.level_idx] = slot_level
            --     end

            --     if slot_level[store.level_difficulty].high_score < store.player_score then
            --         slot_level[store.level_difficulty].high_score = store.player_score
            --         slot_level[store.level_difficulty].waves_survived = store.wave_group_number
            --     end
            -- end

            signal.emit("game-defeat", store)
            signal.emit("game-defeat-after", store)
            storage:save_slot(slot, nil, true)
        elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
            if store.criket and store.criket.on then
                local stars = 3
                if store.lives < -10 then
                    stars = 1
                elseif store.lives < -5 then
                    stars = 2
                end
                store.criket.time_cost = store.tick_ts - store.criket.start_time
                store.game_outcome = {
                    victory = true,
                    lives_left = store.lives,
                    stars = stars,
                    level_idx = store.level_idx,
                    level_mode = store.level_mode,
                    level_difficulty = store.level_difficulty
                }
                signal.emit("game-victory", store)
                signal.emit("game-victory-after", store)
                return
            end
            log.info("++++ VICTORY ++++")

            local stars = 1

            if store.level_mode == GAME_MODE_CAMPAIGN then
                if store.lives >= 18 then
                    stars = 3
                elseif store.lives >= 6 then
                    stars = 2
                end
            end

            store.game_outcome = {
                victory = true,
                lives_left = store.lives,
                stars = stars,
                level_idx = store.level_idx,
                level_mode = store.level_mode,
                level_difficulty = store.level_difficulty
            }

            local slot = storage:load_slot()

            slot.last_victory = {
                level_idx = store.level_idx,
                level_difficulty = store.level_difficulty,
                level_mode = store.level_mode,
                stars = stars,
                unlock_towers = store.level.unlock_towers
            }

            store_hero_xp(slot)

            slot.gems = (slot.gems or 0) + store.gems_collected

            signal.emit("game-victory", store)
            signal.emit("game-victory-after", store)
            storage:save_slot(slot, nil, true)
        end
    end
end

sys.wave_spawn = {}
sys.wave_spawn.name = "wave_spawn"

local function spawner(store, wave, group_id)
    log.debug("spawner thread(%s) for wave(%s) starting", coroutine.running(), tostring(wave))

    local spawns = wave.spawns
    local pi = wave.path_index
    local last_spawn_ts = 0

    for i = 1, #spawns do
        for count = 1, store.config.enemy_count_multiplier do
            local current_count = 0
            local current_creep
            local s = spawns[i]
            local path = P.paths[pi]

            if not U.is_seen(store, s.creep) then
                signal.emit("wave-notification", "icon", s.creep)
                U.mark_seen(store, s.creep)
            end

            if s.creep_aux and not U.is_seen(store, s.creep_aux) then
                signal.emit("wave-notification", "icon", s.creep_aux)
                U.mark_seen(store, s.creep_aux)
            end

            for j = 1, s.max do
                U.y_wait(store, fts(s.interval or 0) / store.config.enemy_count_multiplier)

                if not current_creep then
                    current_creep = s.creep
                elseif s.creep_aux and s.max_same and s.max_same > 0 and current_count >= s.max_same then
                    current_creep = s.creep == current_creep and s.creep_aux or s.creep
                    current_count = 0
                end

                local e = E:create_entity(current_creep)

                if e then
                    e.nav_path.pi = pi
                    e.nav_path.spi = s.fixed_sub_path == 1 and s.path or random(#path)
                    e.nav_path.ni = P:get_start_node(pi)
                    e.spawn_data = s.spawn_data

                    queue_insert(store, e)

                    current_count = current_count + 1
                else
                    log.error("Entity template not found for %s.", s.crep)
                end
            end

            if s.max == 0 then
                U.y_wait(store, fts(s.interval or 0) / store.config.enemy_count_multiplier)
            end

            local oes = s.on_end_signal

            if oes then
                log.info("Sending spawner on_end_signal: %s", oes)

                store.wave_signals[oes] = {}
            end

            if i < #spawns then
                local interval_next = s.interval_next or 0
                if DI.level == DIFFICULTY_HARD then
                    if group_id > 12 then
                        store.last_wave_ts = store.last_wave_ts - interval_next * 0.75
                        interval_next = interval_next * 0.25
                    elseif group_id > 9 then
                        store.last_wave_ts = store.last_wave_ts - interval_next * 0.5
                        interval_next = interval_next * 0.5
                    elseif group_id > 6 then
                        store.last_wave_ts = store.last_wave_ts - interval_next * 0.25
                        interval_next = interval_next * 0.75
                    end
                end
                U.y_wait(store, fts(interval_next) / store.config.enemy_count_multiplier)
            end
        end
    end

    log.debug("spawner thread(%s) for wave(%s) about to finish", coroutine.running(), tostring(wave))

    return true
end

function sys.wave_spawn:init(store)
    store.wave_group_number = 0
    store.waves_finished = false
    store.last_wave_ts = 0
    store.waves_active = {}
    store.wave_signals = {}
    store.send_next_wave = false

    if store.level_mode_override == GAME_MODE_ENDLESS then
        store.gems_per_wave = 0
        store.wave_group_total = 0
        if store.endless and store.endless.wave_group_number then
            store.wave_group_number = store.endless.wave_group_number
        end
    else
        store.wave_group_total = W:groups_count()
    end

    local function run(store)
        log.info("Wave group spawn thread STARTING")

        local i = 1
        local start = true
        if store.endless and store.endless.wave_group_number then
            i = store.endless.wave_group_number
        end
        while W:has_group(i) do
            local group = W:get_group(i)

            group.group_idx = i
            store.next_wave_group_ready = group

            signal.emit("next-wave-ready", group)

            if start then
                -- ...
                group.group_idx = 1
                for _, wave in pairs(group.waves) do
                    if wave.notification and wave.notification ~= "" then
                        signal.emit("wave-notification", "view", wave.notification)
                    end
                end

                while not store.send_next_wave do
                    coroutine.yield()
                end
                start = false
                log.debug("Sending first WAVE. (Started by player)")
            else
                while not store.send_next_wave and not (store.tick_ts - store.last_wave_ts >= fts(group.interval)) and
                    not store.force_next_wave do
                    coroutine.yield()
                end
            end

            log.info("sending WAVE group %02d (%02d waves)", i, #group.waves)

            store.next_wave_group_ready = nil
            store.wave_group_number = i

            if store.send_next_wave == true and i > 1 then
                local score_reward
                local remaining_secs = km.round(fts(group.interval) - (store.tick_ts - store.last_wave_ts))

                if store.level_mode == -1 then
                    -- if store.level_mode == GAME_MODE_ENDLESS then
                    store.early_wave_reward = ceil(remaining_secs * GS.early_wave_reward_per_second *
                                                       W:get_endless_early_wave_reward_factor())

                    local conf = W:get_endless_score_config()
                    local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

                    score_reward = km.round((i - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor *
                                                #group.waves)
                    store.player_score = store.player_score + score_reward

                    log.debug(
                        "ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s",
                        i, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
                else
                    store.early_wave_reward = ceil(remaining_secs * GS.early_wave_reward_per_second)
                end

                store.player_gold = store.player_gold + store.early_wave_reward

                signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
            else
                store.early_wave_reward = 0
                if store.criket then
                    store.criket.start_time = store.tick_ts
                end
            end

            -- if store.level_mode == GAME_MODE_ENDLESS and i > 1 then
            --     local conf = W:get_endless_score_config()
            --     local reward = (i - 1) * conf.scorePerWave

            --     store.player_score = store.player_score + reward

            --     local gems = GS.endless_gems_for_wave * (i - 1)

            --     store.gems_collected = store.gems_collected + gems

            --     log.debug("ENDLESS: wave %s reward:%s gems:%s", i, reward, gems)
            -- end

            store.send_next_wave = false
            store.current_wave_group = group

            signal.emit("next-wave-sent", group)
            -- log.debug("GEMS:_wave_idx:%s", gems_wave_idx)

            for j, wave in pairs(group.waves) do
                wave.group_idx = i

                if i ~= 1 and wave.notification and wave.notification ~= "" then
                    signal.emit("wave-notification", "view", wave.notification)
                end

                if wave.notification_second_level and wave.notification_second_level ~= "" then
                    signal.emit("wave-notification", "icon", wave.notification_second_level)
                end

                local sco = coroutine.create(function()
                    local wave_start_ts = store.tick_ts

                    while store.tick_ts < wave_start_ts + fts(wave.delay) do
                        coroutine.yield()
                    end

                    return spawner(store, wave, i)
                end)

                store.waves_active[sco] = sco
            end

            log.info("WAVE group %d about to wait for all its spawner threads to finish", i)

            while next(store.waves_active) do
                coroutine.yield()
            end

            store.current_wave_group = nil
            store.last_wave_ts = store.tick_ts
            i = i + 1
        end

        log.info("WAVE spawn thread FINISHED")

        return true
    end

    store.wave_spawn_thread = coroutine.create(run)
end

function sys.wave_spawn:force_next_wave(store)
    if store.force_next_wave then
        store.waves_active = {}

        LU.kill_all_enemies(store, nil, true)
    end
end

function sys.wave_spawn:on_update(dt, ts, store)
    sys.wave_spawn:force_next_wave(store)

    if store.wave_spawn_thread then
        local ok, done = coroutine.resume(store.wave_spawn_thread, store)

        if ok and done then
            store.wave_spawn_thread = nil
            store.waves_finished = true

            log.debug("++++ WAVES FINISHED")
        end

        if not ok then
            log.error("Error resuming wave_spawn_thread co: %s", debug.traceback(store.wave_spawn_thread, done))

            store.wave_spawn_thread = nil
        end
    end

    local to_cleanup

    for _, co in pairs(store.waves_active) do
        local ok, done = coroutine.resume(co, store)

        if ok and done then
            log.debug("thread (%s) finished after resume()", tostring(co))

            to_cleanup = to_cleanup or {}
            to_cleanup[#to_cleanup + 1] = co
        end

        if not ok then
            local err = done

            log.error("Error resuming spawner thread (%s): %s", tostring(co), debug.traceback(co, err))
        end
    end

    if to_cleanup then
        for _, co in pairs(to_cleanup) do
            log.debug("removing spawner thread (%s)", co)

            store.waves_active[co] = nil
        end

        to_cleanup = nil
    end

    store.force_next_wave = false
end

sys.mod_lifecycle = {}
sys.mod_lifecycle.name = "mod_lifecycle"

function sys.mod_lifecycle:on_insert(entity, store)
    local mdf = entity.modifier
    if not mdf then
        return true
    end

    local this = entity
    local target_id = mdf.target_id
    local target = store.entities[target_id]
    if not target then
        return false
    end
    if not target._applied_mods then
        target._applied_mods = {}
    end

    local modifiers = target._applied_mods
    for i = 1, #modifiers do
        local m = modifiers[i].modifier
        if m.bans and table.contains(m.bans, this.template_name) then
            return false
        end
    end

    if mdf.remove_banned then
        for i = 1, #modifiers do
            local m = modifiers[i]
            local mm = m.modifier
            if mdf.bans and table.contains(mdf.bans, m.template_name) then
                mm.removed_by_ban = true
                queue_remove(store, m)
            end
            if mdf.ban_types and table.contains(mdf.ban_types, mm.type) then
                mm.removed_by_ban = true
                queue_remove(store, m)
            end
        end
    end

    mdf.ts = store.tick_ts

    if this.render then
        for i = 1, #this.render.sprites do
            this.render.sprites[i].ts = store.tick_ts
        end
    end

    if mdf.allows_duplicates then
        return true
    end

    local duplicates = {}
    for i = 1, #modifiers do
        local m = modifiers[i]
        if m.template_name == this.template_name then
            if mdf.level == m.modifier.level and mdf.max_duplicates then
                mdf.max_duplicates = mdf.max_duplicates - 1
                duplicates[#duplicates + 1] = m
                if mdf.max_duplicates < 0 then
                    return false
                end
            elseif mdf.level > m.modifier.level and mdf.replaces_lower then
                if m.render then
                    for i = 1, #this.render.sprites do
                        this.render.sprites[i].ts = m.render.sprites[i].ts
                    end
                end
                queue_remove(store, m)
            elseif mdf.level == m.modifier.level and mdf.resets_same then
                m.modifier.ts = store.tick_ts

                if mdf.resets_same_tween and m.tween then
                    m.tween.ts = store.tick_ts - (mdf.resets_same_tween_offset or 0)
                end
                return false
            else
                return false
            end
        end
    end

    if #duplicates > 0 then
        for _, d in pairs(duplicates) do
            if d.dps then
                d.dps.fx = nil
            end
            if d.render then
                for i = 1, #d.render.sprites do
                    d.render.sprites[i].hidden = true
                end
            end
        end
    end

    return true
end

sys.tower_upgrade = {}
sys.tower_upgrade.name = "tower_upgrade"

function sys.tower_upgrade:on_update(dt, ts, store)
    for _, e in pairs(store.towers) do
        if e.tower.sell or e.tower.destroy then
            log.debug("selling %s", e.id)

            if e.tower.sell then
                local refund = store.wave_group_number == 0 and e.tower.spent or
                                   km.round(e.tower.refund_factor * e.tower.spent)

                store.player_gold = store.player_gold + refund
            end

            if e.tower.sell then
                if e._applied_mods then
                    for _, mod in pairs(e._applied_mods) do
                        queue_remove(store, mod)
                    end
                end
            end

            local th = E:create_entity("tower_holder")

            th.pos = V.vclone(e.pos)
            th.tower.holder_id = e.tower.holder_id
            th.tower.flip_x = e.tower.flip_x

            if e.tower.default_rally_pos then
                th.tower.default_rally_pos = e.tower.default_rally_pos
            end

            if e.tower.terrain_style then
                th.tower.terrain_style = e.tower.terrain_style
                th.render.sprites[1].name = string.format(th.render.sprites[1].name, e.tower.terrain_style)
            end

            if th.ui and e.ui then
                th.ui.nav_mesh_id = e.ui.nav_mesh_id
            end

            queue_insert(store, th)
            queue_remove(store, e)
            signal.emit("tower-removed", e, th)

            if e.tower.sell then
                local dust = E:create_entity("fx_tower_sell_dust")

                dust.pos.x, dust.pos.y = th.pos.x, th.pos.y + 35
                dust.render.sprites[1].ts = store.tick_ts

                queue_insert(store, dust)

                if e.sound_events and e.sound_events.sell then
                    S:queue(e.sound_events.sell, e.sound_events.sell_args)
                end
            end
        elseif e.tower.upgrade_to then
            log.debug("upgrading %s to %s", e.id, e.tower.upgrade_to)
            if e._applied_mods then
                for _, mod in pairs(e._applied_mods) do
                    queue_remove(store, mod)
                end
            end

            local ne = E:create_entity(e.tower.upgrade_to)

            ne.pos = V.vclone(e.pos)
            ne.tower.holder_id = e.tower.holder_id
            ne.tower.flip_x = e.tower.flip_x

            if e.tower.default_rally_pos then
                ne.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
            end

            if e.tower.terrain_style then
                ne.tower.terrain_style = e.tower.terrain_style
                ne.render.sprites[1].name = string.format(ne.render.sprites[1].name, e.tower.terrain_style)
            end

            if ne.ui and e.ui then
                ne.ui.nav_mesh_id = e.ui.nav_mesh_id
            end

            queue_insert(store, ne)
            queue_remove(store, e)
            signal.emit("tower-upgraded", ne, e)

            local price = ne.tower.price

            if ne.tower.type == "build_animation" then
                local bt = E:get_template(ne.build_name)

                price = bt.tower.price
            elseif e.tower.type == "build_animation" then
                price = 0
            elseif e.tower_holder and e.tower_holder.unblock_price > 0 then
                price = e.tower_holder.unblock_price
            end

            store.player_gold = store.player_gold - price

            if not e.tower_holder or not e.tower_holder.blocked then
                ne.tower.spent = e.tower.spent + price
            end

            if e.tower and e.tower.type == "engineer" and ne.tower.type == "engineer" then
                if ne.ranged_attack then
                    ne.ranged_attack.ts = e.ranged_attack.ts
                elseif ne.area_attack then
                    ne.area_attack.ts = e.ranged_attack.ts
                end
            elseif e.barrack and ne.barrack then
                ne.barrack.rally_pos = V.vclone(e.barrack.rally_pos)

                for i, s in ipairs(e.barrack.soldiers) do
                    if s.health.dead then
                        -- block empty
                    else
                        if i > ne.barrack.max_soldiers then
                            U.unblock_target(store, s)
                        else
                            local soldier_type = ne.barrack.soldier_type
                            if ne.barrack.soldier_types then
                                soldier_type = ne.barrack.soldier_types[i]
                            end
                            local ns = E:create_entity(soldier_type)

                            ns.info.i18n_key = s.info.i18n_key
                            ns.soldier.tower_id = ne.id
                            ns.pos = V.vclone(s.pos)
                            ns.motion.dest = V.vclone(s.motion.dest)
                            ns.motion.arrived = s.motion.arrived
                            ns.render.sprites[1].flip_x = s.render.sprites[1].flip_x
                            ns.render.sprites[1].flip_y = s.render.sprites[1].flip_y
                            ns.render.sprites[1].name = s.render.sprites[1].name
                            ns.render.sprites[1].loop = s.render.sprites[1].loop
                            ns.render.sprites[1].ts = s.render.sprites[1].ts
                            ns.render.sprites[1].runs = s.render.sprites[1].runs
                            if ne.mercenary then
                                ns.nav_rally.pos = V.vclone(s.nav_rally.pos)
                                ns.nav_rally.center = V.vclone(s.nav_rally.center)
                                ns.nav_rally.new = s.nav_rally.new
                            else
                                ns.nav_rally.pos, ns.nav_rally.center =
                                    U.rally_formation_position(i, ne.barrack, ne.barrack.max_soldiers)
                                ns.nav_rally.new = true

                            end

                            if ns.melee then
                                for i, a in ipairs(ns.melee.attacks) do
                                    if s.melee.attacks[i] then
                                        a.ts = s.melee.attacks[i].ts
                                    end
                                end

                                U.replace_blocker(store, s, ns)
                            end

                            ne.barrack.soldiers[i] = ns

                            queue_insert(store, ns)
                        end

                        s.health.dead = true

                        queue_remove(store, s)
                    end
                end
            elseif ne.barrack then
                ne.barrack.rally_pos = V.vclone(ne.tower.default_rally_pos)
            end

            if ne.tower.type ~= "build_animation" and not ne.tower.hide_dust then
                local dust = E:create_entity("fx_tower_buy_dust")

                dust.pos.x, dust.pos.y = ne.pos.x, ne.pos.y + 10
                dust.render.sprites[1].ts = store.tick_ts

                queue_insert(store, dust)
            end
        end
    end
end

sys.game_upgrades = {}
sys.game_upgrades.name = "game_upgrades"

function sys.game_upgrades:init(store)
    store.game_upgrades_data = {}
    store.game_upgrades_data.mage_towers_count = 0
end

function sys.game_upgrades:on_insert(entity, store)
    local mage_towers = UP:mage_towers()
    local mage_bullet_names = UP:mage_tower_bolts()
    local u = UP:get_upgrade("mage_brilliance")

    if u and entity.tower and table.contains(mage_towers, entity.template_name) then
        local existing_towers = table.filter(store.towers, function(_, e)
            return table.contains(mage_towers, e.template_name)
        end)
        local dps = E:get_template("mod_ray_arcane").dps
        local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
        local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
        local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

        for _, bn in pairs(mage_bullet_names) do
            local b = E:get_template(bn).bullet
            if not b._orig_damage_min then
                b._orig_damage_min = b.damage_min
                b._orig_damage_max = b.damage_max
            end
            b.damage_min = ceil(b._orig_damage_min * f)
            b.damage_max = ceil(b._orig_damage_max * f)
        end
        if not dps._orig_damage_min then
            dps._orig_damage_min = dps.damage_min
            dps._orig_damage_max = dps.damage_max
        end
        dps.damage_min = ceil(dps._orig_damage_min * f)
        dps.damage_max = ceil(dps._orig_damage_max * f)

        if not bullet_ray_high_elven._orig_damage_min then
            bullet_ray_high_elven._orig_damage_min = bullet_ray_high_elven.damage_min
            bullet_ray_high_elven._orig_damage_max = bullet_ray_high_elven.damage_max
        end
        bullet_ray_high_elven.damage_min = ceil(bullet_ray_high_elven._orig_damage_min * f)
        bullet_ray_high_elven.damage_max = ceil(bullet_ray_high_elven._orig_damage_max * f)
        if not modifier_pixie._orig_damage_min then
            modifier_pixie._orig_damage_min = modifier_pixie.damage_min
            modifier_pixie._orig_damage_max = modifier_pixie.damage_max
        end
        modifier_pixie.damage_min = ceil(modifier_pixie._orig_damage_min * f)
        modifier_pixie.damage_max = ceil(modifier_pixie._orig_damage_max * f)

    end

    return true
end

function sys.game_upgrades:on_remove(entity, store)
    local mage_towers = UP:mage_towers()
    local mage_bullet_names = UP:mage_tower_bolts()

    local u = UP:get_upgrade("mage_brilliance")

    if u and entity.tower and table.contains(mage_towers, entity.template_name) then
        local existing_towers = table.filter(store.towers, function(_, e)
            return table.contains(mage_towers, e.template_name)
        end)
        local dps = E:get_template("mod_ray_arcane").dps
        local bullet_ray_high_elven = E:get_template("ray_high_elven_sentinel").bullet
        local modifier_pixie = E:get_template("mod_pixie_pickpocket").modifier
        local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

        for _, bn in pairs(mage_bullet_names) do
            local b = E:get_template(bn).bullet

            b.damage_min = ceil(b._orig_damage_min * f)
            b.damage_max = ceil(b._orig_damage_max * f)
        end
        dps.damage_min = ceil(dps._orig_damage_min * f)
        dps.damage_max = ceil(dps._orig_damage_max * f)

        bullet_ray_high_elven.damage_min = ceil(bullet_ray_high_elven._orig_damage_min * f)
        bullet_ray_high_elven.damage_max = ceil(bullet_ray_high_elven._orig_damage_max * f)
        modifier_pixie.damage_min = ceil(modifier_pixie._orig_damage_min * f)
        modifier_pixie.damage_max = ceil(modifier_pixie._orig_damage_max * f)
    end

    return true
end

sys.main_script = {}
sys.main_script.name = "main_script"

function sys.main_script:on_queue(entity, store, insertion)
    if entity.main_script and entity.main_script.queue then
        entity.main_script.queue(entity, store, insertion)
    end
end

function sys.main_script:on_dequeue(entity, store, insertion)
    if entity.main_script and entity.main_script.dequeue then
        entity.main_script.dequeue(entity, store, insertion)
    end
end

function sys.main_script:on_insert(entity, store)
    if entity.main_script and entity.main_script.insert then
        return entity.main_script.insert(entity, store, entity.main_script)
    else
        return true
    end
end

function sys.main_script:on_update(dt, ts, store)
    local entities_with_main_script_on_update = store.entities_with_main_script_on_update
    for _, e in pairs(store.entities_with_main_script_on_update) do
        local s = e.main_script

        if not s.co and s.runs ~= 0 then
            s.runs = s.runs - 1
            s.co = coroutine.create(s.update)
        end

        if s.co then
            local success, err = coroutine.resume(s.co, e, store, s)

            -- if coroutine.status(s.co) == "dead" or err ~= nil then
            --     if err ~= nil then
            if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
                if not success and err ~= nil then
                    -- log.error("Error running coro: %s", debug.traceback(s.co, error))
                    log.error("Error running coro: " .. err .. debug.traceback(s.co))
                    if LLDEBUGGER then
                        LLDEBUGGER.start()
                    end
                end

                s.co = nil
            end
        end
    end
end

if PERFORMANCE_MONITOR_ENABLED and false then
    function sys.main_script:init(store)
        self.print_counter = 0
        self.print_cycle = DRAW_FPS
    end

    function sys.main_script:on_update(dt, ts, store)
        local print_enabled = false
        self.print_counter = self.print_counter + 1
        if self.print_counter >= self.print_cycle then
            self.print_counter = 0
            print_enabled = true
            print("----------------")
        end

        local entities_with_main_script_on_update = store.entities_with_main_script_on_update
        for _, e in pairs(store.entities_with_main_script_on_update) do
            local s = e.main_script

            if not s.co and s.runs ~= 0 then
                s.runs = s.runs - 1
                s.co = coroutine.create(s.update)
            end

            if s.co then
                local t1 = love.timer.getTime()
                local success, err = coroutine.resume(s.co, e, store, s)

                if print_enabled then
                    local t2 = love.timer.getTime()
                    local delta_t = (t2 - t1) * 1000000
                    print(string.format("%s: %d", e.template_name, delta_t))
                end

                -- if coroutine.status(s.co) == "dead" or err ~= nil then
                --     if err ~= nil then
                if coroutine.status(s.co) == "dead" or (not success and err ~= nil) then
                    if not success and err ~= nil then
                        -- log.error("Error running coro: %s", debug.traceback(s.co, error))
                        error("Error running coro: " .. err .. debug.traceback(s.co))
                    end

                    s.co = nil
                end
            end
        end
    end
end

function sys.main_script:on_remove(entity, store)
    if entity.main_script and entity.main_script.remove then
        return entity.main_script.remove(entity, store, entity.main_script)
    else
        return true
    end
end

sys.health = {}
sys.health.name = "health"

function sys.health:init(store)
    store.damage_queue = {}
    store.damages_applied = {}
end

function sys.health:on_insert(entity, store)
    if entity.health and not entity.health.hp then
        entity.health.hp = entity.health.hp_max
    end

    return true
end

function sys.health:on_update(dt, ts, store)
    local new_damage_queue = {}
    store.damages_applied = {}
    for i = #store.damage_queue, 1, -1 do
        local d = store.damage_queue[i]

        local e = store.entities[d.target_id]

        if not e then
            -- block empty
        else
            local h = e.health

            if h.dead or band(h.immune_to, d.damage_type) ~= 0 or h.ignore_damage or h.on_damage and
                not h.on_damage(e, store, d) then
                -- block empty
            else
                local starting_hp = h.hp

                h.last_damage_types = bor(h.last_damage_types, d.damage_type)

                if band(d.damage_type, DAMAGE_EAT) ~= 0 then
                    d.damage_applied = h.hp
                    d.damage_result = bor(d.damage_result, DR_KILL)
                    h.hp = 0
                    store.damages_applied[#store.damages_applied + 1] = d
                elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then

                    d.value = d.value * (1 - e.health.armor_resilience)

                    SU.armor_dec(e, d.value)
                    d.damage_result = bor(d.damage_result, DR_ARMOR)
                elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
                    d.value = d.value * (1 - e.health.armor_resilience)

                    SU.magic_armor_dec(e, d.value)
                    d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
                else
                    local actual_damage = U.predict_damage(e, d)

                    h.hp = h.hp - actual_damage
                    d.damage_applied = actual_damage

                    if starting_hp > 0 and h.hp <= 0 then
                        d.damage_result = bor(d.damage_result, DR_KILL)
                    end

                    if actual_damage > 0 then
                        d.damage_result = bor(d.damage_result, DR_DAMAGE)

                        if e.regen then
                            e.regen.last_hit_ts = store.tick_ts
                        end

                        if d.track_damage then
                            signal.emit("entity-damaged", e, d)

                            local source = store.entities[d.source_id]

                            if source and source.track_damage then
                                table.insert(source.track_damage.damaged, {e.id, actual_damage})
                            end
                        end
                    end

                    if e and h.spiked_armor > 0 and e.soldier and d.source_id then
                        local sad_target_id = nil

                        if e.soldier.target_id == d.source_id then
                            sad_target_id = d.source_id
                        end

                        if sad_target_id then
                            local t = store.entities[sad_target_id]
                            if t and t.health and not t.health.dead then
                                local sad = E:create_entity("damage")

                                sad.damage_type = DAMAGE_TRUE
                                sad.value = h.spiked_armor * d.value
                                sad.source_id = e.id
                                sad.target_id = t.id
                                new_damage_queue[#new_damage_queue + 1] = sad
                            end
                        end
                    end
                    store.damages_applied[#store.damages_applied + 1] = d
                end

                if starting_hp > 0 and h.hp <= 0 then
                    signal.emit("entity-killed", e, d)

                    if d.track_kills then
                        local source = store.entities[d.source_id]

                        if source and source.track_kills then
                            table.insert(source.track_kills.killed, e.id)
                        end
                    end
                end
            end
        end
    end
    local enemies = store.enemies
    local soldiers = store.soldiers
    for _, e in pairs(enemies) do
        local h = e.health

        if h.hp <= 0 and not h.dead and not h.ignore_damage then
            h.hp = 0
            h.dead = true
            h.death_ts = store.tick_ts
            h.delete_after = store.tick_ts + h.dead_lifetime

            if e.health_bar then
                e.health_bar.hidden = true
            end

            store.player_gold = store.player_gold + e.enemy.gold

            signal.emit("got-enemy-gold", e, e.enemy.gold)
        end

        if not h.dead then
            h.last_damage_types = 0
        elseif not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
            queue_remove(store, e)
        end
    end

    for _, e in pairs(soldiers) do
        local h = e.health

        if h.hp <= 0 and not h.dead and not h.ignore_damage then
            h.hp = 0
            h.dead = true
            h.death_ts = store.tick_ts
            h.delete_after = store.tick_ts + h.dead_lifetime

            if e.health_bar then
                e.health_bar.hidden = true
            end
        end

        if not h.dead then
            h.last_damage_types = 0
        elseif not e.hero and not h.ignore_delete_after and
            (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
            queue_remove(store, e)
        end
    end
    store.damage_queue = new_damage_queue
end

sys.count_groups = {}
sys.count_groups.name = "count_groups"

function sys.count_groups:init(store)
    store.count_groups = {}
    store.count_groups[COUNT_GROUP_CONCURRENT] = {}
    store.count_groups[COUNT_GROUP_CUMULATIVE] = {}
end

function sys.count_groups:on_queue(entity, store, insertion)
    if insertion and entity.count_group then
        local c = entity.count_group

        if c.in_limbo then
            c.in_limbo = nil

            return true
        end

        local g = store.count_groups

        if not g[c.type][c.name] then
            g[c.type][c.name] = 0
        end

        g[c.type][c.name] = g[c.type][c.name] + 1

        signal.emit("count-group-changed", entity, g[c.type][c.name], 1)
    end
end

function sys.count_groups:on_dequeue(entity, store, insertion)
    if insertion then
        self:on_remove(entity, store)
    end
end

function sys.count_groups:on_remove(entity, store)
    if entity.count_group and not entity.count_group.in_limbo and entity.count_group.type == COUNT_GROUP_CONCURRENT then
        local c = entity.count_group
        local g = store.count_groups

        g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)

        signal.emit("count-group-changed", entity, g[c.type][c.name], -1)
    end

    return true
end

sys.hero_xp_tracking = {}
sys.hero_xp_tracking.name = "hero_xp_tracking"

function sys.hero_xp_tracking:on_update(dt, ts, store)
    for i = 1, #store.damages_applied do
        local d = store.damages_applied[i]
        if d.xp_gain_factor and d.xp_gain_factor > 0 and d.damage_applied > 0 then
            local id = d.xp_dest_id or d.source_id
            local e = store.entities[id]

            if not e or not e.hero then
                -- block empty
            else
                local amount = d.damage_applied * d.xp_gain_factor

                e.hero.xp_queued = e.hero.xp_queued + amount
            end
        end
    end
end

sys.pops = {}
sys.pops.name = "pops"

function sys.pops:on_update(dt, ts, store)
    for i = 1, #store.damages_applied do
        local d = store.damages_applied[i]
        if not d.pop or not d.target_id then
            -- block empty
        else
            local source = store.entities[d.source_id]
            local target = store.entities[d.target_id]
            local pop_entity

            if source and (source.enemy or source.soldier) then
                pop_entity = source
            elseif target then
                pop_entity = target
            else
                goto label_37_0
            end

            if (not d.pop_chance or random() < d.pop_chance) and
                (not d.pop_conds or band(d.damage_result, d.pop_conds) ~= 0) then
                local name = d.pop[random(1, #d.pop)]
                local e = E:create_entity(name)

                if e.pop_over_target and target then
                    pop_entity = target
                end

                e.pos = V.v(pop_entity.pos.x, pop_entity.pos.y)

                if pop_entity.unit and pop_entity.unit.pop_offset then
                    e.pos.y = e.pos.y + pop_entity.unit.pop_offset.y
                elseif pop_entity == target and pop_entity.unit and pop_entity.unit.hit_offset then
                    e.pos.y = e.pos.y + pop_entity.unit.hit_offset.y
                end

                e.pos.y = e.pos.y + e.pop_y_offset
                e.render.sprites[1].r = random(-21, 21) * math.pi / 180
                e.render.sprites[1].ts = store.tick_ts

                queue_insert(store, e)
            end
        end

        ::label_37_0::
    end
end

sys.timed = {}
sys.timed.name = "timed"

function sys.timed:on_update(dt, ts, store)
    local timed = store.entities_with_timed
    for _, e in pairs(timed) do
        local s = e.render.sprites[e.timed.sprite_id]

        if e.timed.disabled then
            -- block empty
        elseif s.ts == store.tick_ts then
            -- block empty
        elseif e.timed.runs and s.runs == e.timed.runs or e.timed.duration and store.tick_ts - s.ts > e.timed.duration then
            queue_remove(store, e)
        end
    end
end

sys.tween = {}
sys.tween.name = "tween"

function sys.tween:init(store)
    self.fns = {
        step = function(s)
            return 0
        end,
        linear = function(s)
            return s
        end,
        quad = function(s)
            return s * s
        end,
        sine = function(s)
            return 0.5 * (1 - math.cos(s * math.pi))
        end
    }
    self.lerp = function(a, b, t, fn)
        local ta = type(a)
        if ta == "boolean" then
            return a
        else
            local f = self.fns[fn or "linear"]
            local ft = f(t)
            if ta == "table" then
                return {
                    x = a.x + (b.x - a.x) * ft,
                    y = a.y + (b.y - a.y) * ft
                }
            else
                return a + (b - a) * ft
            end
        end
    end
end

function sys.tween:on_insert(entity, store)
    if entity.tween then
        for _, p in pairs(entity.tween.props) do
            for _, n in pairs(p.keys) do
                for i = 1, 2 do
                    if type(n[i]) == "string" then
                        local nf = loadstring("return " .. n[i])
                        local env = {}

                        env.this = entity
                        env.store = store
                        env.math = math
                        env.U = U
                        env.V = V

                        setfenv(nf, env)

                        n[i] = nf()
                    end
                end
            end
        end

        if entity.tween.random_ts then
            entity.tween.ts = U.frandom(-1 * entity.tween.random_ts, 0)
        end
    end

    return true
end

function sys.tween:on_update(dt, ts, store)
    local fns = self.fns

    local lerp = self.lerp

    local tween = store.entities_with_tween
    for _, e in pairs(tween) do
        if e.tween.disabled then
            -- block empty
        else
            local finished = true

            for _, t in pairs(e.tween.props) do
                if t.disabled then
                    -- block empty
                else
                    local sids = type(t.sprite_id) == "table" and t.sprite_id or {t.sprite_id}

                    for _, sid in pairs(sids) do
                        local value
                        local s = e.render.sprites[sid]
                        local keys = t.keys
                        local ka = keys[1]
                        local kb = keys[#keys]
                        local start_time = keys[1][1]
                        local end_time = keys[#keys][1]
                        local duration = end_time - start_time
                        local time_ref = t.ts or e.tween.ts or s.ts
                        local time = store.tick_ts - time_ref

                        if t.time_offset then
                            time = time + t.time_offset
                        end

                        if t.loop then
                            time = time % duration
                        end

                        if e.tween.reverse and not t.ignore_reverse then
                            time = duration - time
                        end

                        time = km.clamp(start_time, end_time, time)

                        for i = 1, #keys do
                            local ki = keys[i]

                            if time >= ki[1] then
                                ka = ki
                            else
                                kb = ki
                                break
                            end
                        end

                        if ka == kb then
                            value = ka[2]
                        else
                            value = lerp(ka[2], kb[2], (time - ka[1]) / (kb[1] - ka[1]), ka[3] or t.interp)
                        end

                        if t.multiply then
                            if type(value) == "boolean" then
                                s[t.name] = value and s[t.name]
                            elseif type(value) == "table" then
                                s[t.name].x = value.x * s[t.name].x
                                s[t.name].y = value.y * s[t.name].y
                            else
                                s[t.name] = value * s[t.name]
                            end
                        else
                            s[t.name] = value
                        end

                        if t.loop then
                            finished = finished and t.loop
                        elseif e.tween.reverse then
                            finished = finished and kb == keys[1]
                        else
                            finished = finished and ka == keys[#keys]
                        end
                    end
                end
            end

            if finished then
                if e.tween.remove then
                    queue_remove(store, e)
                end

                if e.tween.run_once then
                    e.tween.disabled = true
                end
            end
        end
    end
end

sys.goal_line = {}
sys.goal_line.name = "goal_line"

function sys.goal_line:on_update(dt, ts, store)
    local enemies = store.enemies
    for _, e in pairs(enemies) do
        local node_index = e.nav_path.ni
        local end_node = P:get_end_node(e.nav_path.pi)

        if end_node <= node_index and not P.path_connections[e.nav_path.pi] and e.enemy.remove_at_goal_line then
            -- log.debug("enemy %s reached goal", e.id)
            signal.emit("enemy-reached-goal", e)

            store.lives = km.clamp(-10000, 10000, store.lives - e.enemy.lives_cost)
            store.player_gold = store.player_gold + e.enemy.gold

            queue_remove(store, e)
        end
    end
end

sys.texts = {}
sys.texts.name = "texts"

function sys.texts:on_insert(entity, store)
    if entity.texts then
        for _, t in pairs(entity.texts.list) do
            local sprite_id = t.sprite_id
            local image_name = string.format("text_%s_%s_%s", entity.id, sprite_id, store.tick)
            local image = F:create_text_image(t.text, t.size, t.alignment, t.font_name, t.font_size, t.color,
                t.line_height, store.screen_scale, t.fit_height, t.debug_bg)

            I:add_image(image_name, image, "temp_game_texts", store.screen_scale)

            t.image_name = image_name
            t.image_group = "texts"
            entity.render.sprites[sprite_id].name = image_name
            entity.render.sprites[sprite_id].animated = false
        end
    end

    return true
end

function sys.texts:on_remove(entity, store)
    if entity.texts then
        for _, t in pairs(entity.texts.list) do
            if t.image_name then
                I:remove_image(t.image_name)
            end
        end
    end

    return true
end

sys.particle_system = {}
sys.particle_system.name = "particle_system"

-- local Pool = require("pool")

function sys.particle_system:init(store)
    local function create_particle(ts)
        return {
            pos = {
                x = 0,
                y = 0
            },
            r = 0,
            speed = {
                x = 0,
                y = 0
            },
            spin = 0,
            scale_factor = {
                x = 1,
                y = 1
            },
            ts = ts,
            last_ts = ts
        }
    end
    local function reset_particle(p, ts)
        -- p.pos.x = 0
        -- p.pos.y = 0
        -- p.r = 0
        -- p.speed.x = 0
        -- p.speed.y = 0
        -- p.spin = 0
        -- p.scale_factor.x = 1
        -- p.scale_factor.y = 1
        p.ts = ts
        p.last_ts = ts
    end
    -- self.pool = Pool:new(create_particle, reset_particle, 2048)
    self.new_frame = function(draw_order, z, sort_y_offset, sort_y)
        return {
            ss = nil,
            flip_x = false,
            flip_y = false,
            pos = {
                x = 0,
                y = 0
            },
            r = 0,
            scale = {
                x = 1,
                y = 1
            },
            anchor = {
                x = 0.5,
                y = 0.5
            },
            offset = {
                x = 0,
                y = 0
            },
            _draw_order = draw_order,
            z = z,
            sort_y = sort_y,
            sort_y_offset = sort_y_offset,
            alpha = 255,
            hidden = nil
        }
    end
    self.new_particle = function(ts)
        return {
            pos = {
                x = 0,
                y = 0
            },
            r = 0,
            speed = {
                x = 0,
                y = 0
            },
            spin = 0,
            scale_factor = {
                x = 1,
                y = 1
            },
            ts = ts,
            last_ts = ts
        }
    end
    self.phase_interp = function(values, phase, default)
        if not values or #values == 0 then
            return default
        end

        if #values == 1 then
            return values[1]
        end

        local intervals = #values - 1
        local interval = floor(phase * intervals)
        local interval_phase = phase * intervals - interval
        local a = values[interval + 1]
        local b = values[interval + 2]
        local ta = type(a)

        if ta == "table" then
            local out = {}

            for i = 1, #a do
                out[i] = a[i] + (b[i] - a[i]) * interval_phase
            end

            return out
        elseif ta == "boolean" then
            return a
        elseif a ~= nil and b ~= nil then
            return a + (b - a) * interval_phase
        else
            log.error("sys.particle_system:update phase_interp has nil values in %s", getdump(values))

            return default
        end
    end
end

function sys.particle_system:on_insert(entity, store)
    if entity.particle_system then
        local s = entity.particle_system

        s.emit_ts = (s.emit_ts and s.emit_ts or store.tick_ts) + s.ts_offset
        s.ts = store.tick_ts
        s.last_pos = {
            x = 0,
            y = 0
        }
    end

    return true
end

function sys.particle_system:on_remove(entity, store)
    if entity.particle_system then
        local s = entity.particle_system

        for i = #s.particles, 1, -1 do
            local p = s.particles[i]
            p.f.marked_to_remove = true
            s.particles[i] = nil
        end

    end

    return true
end

function sys.particle_system:on_update(dt, ts, store)
    local new_frame = self.new_frame
    local new_particle = self.new_particle
    local phase_interp = self.phase_interp
    local pool = self.pool
    -- local get_particle = pool.get
    -- local release_particle = pool.release

    local particle_systems = store.particle_systems
    for _, e in pairs(particle_systems) do
        local s = e.particle_system
        local tl = store.tick_length
        local to_remove = {}
        local target_rot

        if s.track_id then
            local target = store.entities[s.track_id]

            if target then
                s.last_pos.x, s.last_pos.y = e.pos.x, e.pos.y
                e.pos.x, e.pos.y = target.pos.x, target.pos.y

                if s.track_offset then
                    e.pos.x, e.pos.y = e.pos.x + s.track_offset.x, e.pos.y + s.track_offset.y
                end

                if target.render and target.render.sprites[1] then
                    target_rot = target.render.sprites[1].r
                end
            else
                s.emit = false
                s.source_lifetime = 0
            end
        end

        if s.emit_duration and s.emit then
            if not s.emit_duration_ts then
                s.emit_duration_ts = store.tick_ts
            end

            if store.tick_ts - s.emit_duration_ts > s.emit_duration then
                s.emit = false
            end
        end

        if not s.emit then
            s.emit_ts = store.tick_ts + s.ts_offset
        elseif ts - s.emit_ts > 1 / s.emission_rate then
            local count = floor((ts - s.emit_ts) * s.emission_rate)

            for i = 1, count do
                local pts = s.emit_ts + i / s.emission_rate

                local draw_order = s.draw_order and 100000 * s.draw_order + e.id or floor(pts * 100)
                local f = new_frame(draw_order, s.z, s.sort_y_offset, s.sort_y)

                store.render_frames[#store.render_frames + 1] = f

                local p = new_particle(pts)
                -- local p = get_particle(pool,pts)

                f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y

                s.particles[#s.particles + 1] = p

                p.f = f
                p.lifetime = U.frandom(s.particle_lifetime[1], s.particle_lifetime[2])

                if s.track_id then
                    local factor = (i - 1) / count
                    p.pos.x, p.pos.y = s.last_pos.x + (e.pos.x - s.last_pos.x) * factor,
                        s.last_pos.y + (e.pos.y - s.last_pos.y) * factor
                else
                    p.pos.x, p.pos.y = e.pos.x, e.pos.y
                end

                if s.emit_area_spread then
                    local sp = s.emit_area_spread

                    p.pos.x = p.pos.x + U.frandom(-sp.x * 0.5, sp.x * 0.5)
                    p.pos.y = p.pos.y + U.frandom(-sp.y * 0.5, sp.y * 0.5)
                end

                if s.emit_offset then
                    p.pos.x = p.pos.x + s.emit_offset.x
                    p.pos.y = p.pos.y + s.emit_offset.y
                end

                if s.emit_speed then
                    p.speed.x, p.speed.y = V.rotate(s.emit_direction + U.frandom(-s.emit_spread, s.emit_spread),
                        U.frandom(s.emit_speed[1], s.emit_speed[2]), 0)
                end

                if s.emit_rotation then
                    p.r = s.emit_rotation
                elseif s.track_rotation and target_rot then
                    p.r = target_rot
                else
                    p.r = s.emit_direction + U.frandom(-s.emit_rotation_spread, s.emit_rotation_spread)
                end

                if s.spin then
                    p.spin = U.frandom(s.spin[1], s.spin[2])
                end

                if s.scale_var then
                    local factor = U.frandom(s.scale_var[1], s.scale_var[2])

                    p.scale_factor = {
                        x = factor,
                        y = factor
                    }

                    if not s.scale_same_aspect then
                        p.scale_factor.y = U.frandom(s.scale_var[1], s.scale_var[2])
                    end
                end

                if s.names then
                    if s.cycle_names then
                        if not s._last_name_idx then
                            s._last_name_idx = 0
                        end

                        s._last_name_idx = km.zmod(s._last_name_idx + 1, #s.names)
                        p.name_idx = s._last_name_idx
                    else
                        p.name_idx = random(1, #s.names)
                    end
                end
            end

            s.emit_ts = s.emit_ts + count * 1 / s.emission_rate
        end

        for i = 1, #s.particles do
            do
                local p = s.particles[i]
                local tp = ts - p.last_ts
                local phase = (ts - p.ts) / p.lifetime

                if phase >= 1 then
                    to_remove[#to_remove + 1] = p

                    goto label_51_0
                elseif phase < 0 then
                    phase = 0
                end

                local f = p.f

                p.last_ts = ts
                p.pos.x, p.pos.y = p.pos.x + p.speed.x * tp, p.pos.y + p.speed.y * tp
                f.pos.x, f.pos.y = p.pos.x, p.pos.y
                p.r = p.r + p.spin * tp
                f.r = p.r

                local scale_x = phase_interp(s.scales_x, phase, 1)
                local scale_y = phase_interp(s.scales_y, phase, 1)

                f.scale.x, f.scale.y = scale_x * p.scale_factor.x, scale_y * p.scale_factor.y
                f.alpha = phase_interp(s.alphas, phase, 255)

                if s.sort_y_offsets then
                    f.sort_y_offset = phase_interp(s.sort_y_offsets, phase, 1)
                end
                if s.color then
                    f.color = s.color
                end
                local fn

                if s.animated then
                    local to = ts - p.ts

                    if s.animation_fps then
                        to = to * s.animation_fps / FPS
                    end

                    if p.name_idx then
                        fn = A:fn(s.names[p.name_idx], to, s.loop)
                    else
                        fn = A:fn(s.name, to, s.loop)
                    end
                elseif p.name_idx then
                    fn = s.names[p.name_idx]
                else
                    fn = s.name
                end

                f.ss = I:s(fn)
            end

            ::label_51_0::
        end

        for i = 1, #to_remove do
            local p = to_remove[i]

            for j = 1, #s.particles do
                if s.particles[j] == p then
                    table.remove(s.particles, j)
                    break
                end
            end
            p.f.marked_to_remove = true
        end

        if s.source_lifetime and ts - s.ts > s.source_lifetime then
            s.emit = false

            if #s.particles == 0 then
                queue_remove(store, e)
            end
        end
    end
end

sys.render = {}
sys.render.name = "render"

local ffi = require("ffi")
ffi.cdef [[
typedef struct{
    int z;
    double sort_y;
    int draw_order;
    double pos_x;
    int lua_index;
} RenderFrameFFI;
]]

function sys.render:init(store)
    store.render_frames = {}
    store.render_frames_ffi = ffi.new("RenderFrameFFI[16384]")
    store.render_frames_ffi_tmp = ffi.new("RenderFrameFFI[16384]")
    local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))

    self._hb_ss = {
        ref_scale = 1,
        quad = hb_quad,
        trim = {0, 0, 0, 0},
        size = {1, 1}
    }
    self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
    self._hb_colors = HEALTH_BAR_COLORS
    local function ffi_cmp(a, b)
        if a.z ~= b.z then
            return a.z < b.z
        end
        if a.sort_y ~= b.sort_y then
            return a.sort_y > b.sort_y
        end
        if a.draw_order ~= b.draw_order then
            return a.draw_order < b.draw_order
        end
        return a.pos_x < b.pos_x
    end

    local function ffi_merge_sort(arr, tmp, left, right)
        if right - left <= 1 then
            return
        end
        local mid = floor((left + right) / 2)
        ffi_merge_sort(arr, tmp, left, mid)
        ffi_merge_sort(arr, tmp, mid, right)
        local i, j, k = left, mid, left
        local sizeof_frame = ffi.sizeof("RenderFrameFFI")
        while i < mid and j < right do
            if ffi_cmp(arr[i], arr[j]) then
                ffi.copy(tmp + k, arr + i, sizeof_frame)
                i = i + 1
            else
                ffi.copy(tmp + k, arr + j, sizeof_frame)
                j = j + 1
            end
            k = k + 1
        end
        while i < mid do
            ffi.copy(tmp + k, arr + i, sizeof_frame)
            i = i + 1
            k = k + 1
        end
        while j < right do
            ffi.copy(tmp + k, arr + j, sizeof_frame)
            j = j + 1
            k = k + 1
        end
        for l = left, right - 1 do
            ffi.copy(arr + l, tmp + l, sizeof_frame)
        end
    end

    -- 要求渲染顺序稳定，因此不可以使用快速排序
    self.ffi_sort = ffi_merge_sort
end

function sys.render:on_insert(entity, store)
    local render_frames = store.render_frames
    if entity.render then
        for i = 1, #entity.render.sprites do
            local s = entity.render.sprites[i]
            s.marked_to_remove = false
            s._draw_order = 100000 * (s.draw_order or i) + entity.id
            if s.random_ts then
                s.ts = U.frandom(-1 * s.random_ts, 0)
            end
            if not s.pos then
                s.pos = {
                    x = entity.pos.x,
                    y = entity.pos.y
                }
                s._track_e = true
            end

            if s.shader then
                s._shader = SH:get(s.shader)
            end
            if not s.z then
                s.z = Z_OBJECTS
            end

            render_frames[#render_frames + 1] = s
        end
    end

    if entity.health_bar and store.config.show_health_bar then
        local hb = entity.health_bar
        local hbsize = self._hb_sizes[hb.type]

        local fb = {
            flip_x = false,
            pos = {
                x = 0,
                y = 0
            },
            r = 0,
            alpha = 255,
            anchor = {
                x = 0,
                y = 0
            },
            offset = {
                x = hb.offset.x,
                y = hb.offset.y
            },
            _draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id,
            z = Z_OBJECTS,
            sort_y_offset = hb.sort_y_offset,
            ss = self._hb_ss,
            color = hb.colors and hb.colors.bg or self._hb_colors.bg,
            bar_width = hbsize.x,
            scale = {
                x = hbsize.x,
                y = hbsize.y
            }
        }

        fb.offset.x = fb.offset.x - hbsize.x * fb.ss.ref_scale * 0.5

        local ff = {
            flip_x = false,
            pos = {
                x = 0,
                y = 0
            },
            r = 0,
            alpha = 255,
            anchor = {
                x = 0,
                y = 0
            },
            offset = {
                x = hb.offset.x,
                y = hb.offset.y
            },
            _draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id,
            z = Z_OBJECTS,
            sort_y_offset = hb.sort_y_offset,
            ss = self._hb_ss,
            color = hb.colors and hb.colors.fg or self._hb_colors.fg,
            bar_width = hbsize.x,
            scale = {
                x = hbsize.x,
                y = hbsize.y
            }
        }

        ff.offset.x = ff.offset.x - hbsize.x * ff.ss.ref_scale * 0.5

        for i = #hb.frames, 1, -1 do
            hb.frames[i].marked_to_remove = true
        end

        hb.frames[1] = fb
        hb.frames[2] = ff

        render_frames[#render_frames + 1] = fb
        render_frames[#render_frames + 1] = ff

        if hb.black_bar_hp then
            local fk = {
                flip_x = false,
                pos = {
                    x = 0,
                    y = 0
                },
                r = 0,
                alpha = 255,
                anchor = {
                    x = 0,
                    y = 0
                },
                offset = {
                    x = hb.offset.x - hbsize.x * 0.5,
                    y = hb.offset.y
                },
                _draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id,
                z = Z_OBJECTS,
                sort_y_offset = hb.sort_y_offset,
                ss = self._hb_ss,
                color = hb.colors and hb.colors.black or self._hb_colors.black,
                bar_width = hbsize.x,
                scale = {
                    x = hbsize.x,
                    y = hbsize.y
                }
            }
            hb.frames[3] = fk

            render_frames[#render_frames + 1] = fk
        end
    end

    return true
end

function sys.render:on_remove(entity, store)
    if entity.render then
        for i = #entity.render.sprites, 1, -1 do
            local s = entity.render.sprites[i]
            s.marked_to_remove = true
            -- entity.render.sprites[i] = nil
        end
    end

    if store.config and store.config.show_health_bar and entity.health_bar then
        for i = #entity.health_bar.frames, 1, -1 do
            local f = entity.health_bar.frames[i]
            f.marked_to_remove = true
            entity.health_bar.frames[i] = nil
        end
    end

    return true
end

function sys.render:on_update(dt, ts, store)
    local d = store
    local entities = d.entities_with_render

    for _, e in pairs(entities) do
        for i = 1, #e.render.sprites do
            local s = e.render.sprites[i]
            if s.ts > ts then
                s.hidden = true
                s._wait = true
            elseif s._wait then
                s.hidden = false
                s._wait = false
            end

            local last_runs = s.runs
            -- local fn, runs, idx
            local fn
            if s.animation then
                A:generate_frames(s.animation)
                -- fn, runs, idx = A:fni(s.animation, ts - s.ts + s.time_offset, s.loop, s.fps)
                fn, s.runs, s.frame_idx = A:fni(s.animation, ts - s.ts + s.time_offset, s.loop, s.fps)
                -- s.runs = runs
                -- s.frame_idx = idx
            elseif s.animated then
                -- fn, runs, idx = A:fn(full_name, ts - s.ts + s.time_offset, s.loop, s.fps)
                fn, s.runs, s.frame_idx = A:fn(s.prefix and (s.prefix .. "_" .. s.name) or s.name,
                    ts - s.ts + s.time_offset, s.loop, s.fps)
                s.frame_name = fn
                -- s.runs = runs
                -- s.frame_idx = idx
                -- s.frame_name = fn
            else
                s.runs = 0
                s.frame_idx = 1
                fn = s.name
            end

            s.sync_flag = last_runs ~= s.runs

            local ss = I:s(fn)

            s.ss = ss

            if s._track_e then
                s.pos.x, s.pos.y = e.pos.x, e.pos.y
            end

            s._draw_order = 100000 * (s.draw_order or i) + e.id
            if s.hide_after_runs and s.runs >= s.hide_after_runs then
                s.hidden = true
                -- s.marked_to_remove = true
            end
        end

        if e.health_bar and store.config.show_health_bar then
            local hb = e.health_bar
            local fb = hb.frames[1]
            local ff = hb.frames[2]
            local fk = hb.black_bar_hp and hb.frames[3] or nil

            if hb.hidden then
                fb.hidden = true
                ff.hidden = true

                if fk then
                    fk.hidden = true
                end
            else
                fb.hidden = false
                ff.hidden = false

                fb.pos.x, fb.pos.y = floor(e.pos.x), ceil(e.pos.y)
                ff.pos.x, ff.pos.y = fb.pos.x, fb.pos.y
                fb.offset.x, fb.offset.y = hb.offset.x - fb.bar_width * fb.ss.ref_scale * 0.5, hb.offset.y
                ff.offset.x, ff.offset.y = hb.offset.x - ff.bar_width * ff.ss.ref_scale * 0.5, hb.offset.y
                fb.z = hb.z or Z_OBJECTS
                ff.z = fb.z
                fb._draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + e.id
                ff._draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + e.id
                fb.sort_y_offset = hb.sort_y_offset
                ff.sort_y_offset = hb.sort_y_offset

                if fk then
                    fk.hidden = false
                    fk.pos.x, fk.pos.y = floor(e.pos.x), floor(e.pos.y)
                    fk.offset.x, fk.offset.y = hb.offset.x - fk.bar_width * fk.ss.ref_scale * 0.5, hb.offset.y
                    fk.z = hb.z or Z_OBJECTS
                    fk.sort_y_offset = hb.sort_y_offset
                    fk._draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + e.id
                    ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
                    fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
                else
                    ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
                end
            end
        end
    end

    -- FFI同步
    local render_frames = store.render_frames
    local render_frames_ffi = store.render_frames_ffi
    local n = 0
    for i = 1, #render_frames do
        local f = render_frames[i]
        if not f.marked_to_remove then
            local ffi_f = render_frames_ffi[n]
            ffi_f.z = f.z
            ffi_f.sort_y = f.sort_y or (f.sort_y_offset or 0) + f.pos.y
            ffi_f.draw_order = f._draw_order
            ffi_f.pos_x = f.pos.x
            ffi_f.lua_index = i
            n = n + 1
        end
    end
    self.ffi_sort(store.render_frames_ffi, store.render_frames_ffi_tmp, 0, n)
    local new_frames = {}
    for i = 0, n - 1 do
        local ffi_f = render_frames_ffi[i]
        local f = render_frames[ffi_f.lua_index]
        new_frames[i + 1] = f
    end
    store.render_frames = new_frames
end

sys.sound_events = {}
sys.sound_events.name = "sound_events"

function sys.sound_events:on_insert(entity, store)
    local se = entity.sound_events

    if se and se.insert then
        local sounds = se.insert

        if type(sounds) ~= "table" then
            sounds = {sounds}
        end

        for _, s in pairs(sounds) do
            S:queue(s, se.insert_args)
        end
    end

    return true
end

function sys.sound_events:on_remove(entity, store)
    local se = entity.sound_events

    if se then
        if se.remove then
            local sounds = se.remove

            if type(sounds) ~= "table" then
                sounds = {sounds}
            end

            for _, s in pairs(sounds) do
                S:queue(s, se.remove_args)
            end
        end

        if se.remove_stop then
            local sounds = se.remove_stop

            if type(sounds) ~= "table" then
                sounds = {sounds}
            end

            for _, s in pairs(sounds) do
                S:stop(s, se.remove_stop_args)
            end
        end
    end

    return true
end

sys.seen_tracker = {}
sys.seen_tracker.name = "seen_tracker"

function sys.seen_tracker:init(store)
    local slot = storage:load_slot()

    store.seen = slot.seen and slot.seen or {}
    store.seen_dirty = nil
end

function sys.seen_tracker:on_insert(entity, store)
    if (entity.tower or entity.enemy) and not entity.ignore_seen_tracker then
        U.mark_seen(store, entity.template_name)
    end

    return true
end

function sys.seen_tracker:on_update(dt, ts, store)
    if store.seen_dirty then
        local slot = storage:load_slot()

        slot.seen = store.seen

        storage:save_slot(slot)

        store.seen_dirty = false
    end
end

sys.dbg_enemy_tracker = {}
sys.dbg_enemy_tracker.name = "dbg_enemy_tracker"

local function format_stats(det)
    local diff = det.c_removed - (det.c_killed + det.c_end_node_reached)

    return string.format("enemy tracker - ins:%s | rem:%s (kill:%s + reach:%s = %s) %s", det.c_inserted, det.c_removed,
        det.c_killed, det.c_end_node_reached, diff, diff ~= 0 and "ERROR" or "")
end

function sys.dbg_enemy_tracker:init(store)
    store.det = {}
    store.det.c_inserted = 0
    store.det.c_removed = 0
    store.det.c_killed = 0
    store.det.c_end_node_reached = 0
end

function sys.dbg_enemy_tracker:on_insert(entity, store)
    if entity.enemy then
        store.det.c_inserted = store.det.c_inserted + 1

        log.debug(format_stats(store.det))
    end

    return true
end

function sys.dbg_enemy_tracker:on_remove(entity, store)
    if entity.enemy then
        store.det.c_removed = store.det.c_removed + 1

        if entity.enemy and entity.health.dead then
            store.det.c_killed = store.det.c_killed + 1
        end

        if entity.nav_path then
            local pi = entity.nav_path.pi
            local ni = entity.nav_path.ni
            local end_ni = P:get_end_node(pi)

            if end_ni <= ni then
                store.det.c_end_node_reached = store.det.c_end_node_reached + 1
            end
        end

        log.debug(format_stats(store.det))

        if store.det.c_removed ~= store.det.c_killed + store.det.c_end_node_reached then
            log.debug("DBG_ENEMY_TRACKER: ENEMY REMOVAL UNKNOWN: (%s) %s", entity.id, entity.template_name)
        end
    end

    return true
end

sys.editor_overrides = {}
sys.editor_overrides.name = "editor_overrides"

function sys.editor_overrides:on_insert(entity, store)
    if entity.editor and entity.editor.components then
        for _, c in pairs(entity.editor.components) do
            E:add_comps(entity, c)
        end
    end

    if entity.editor and entity.editor.overrides then
        for k, v in pairs(entity.editor.overrides) do
            LU.eval_set_prop(entity, k, v)
        end
    end

    return true
end

sys.editor_script = {}
sys.editor_script.name = "editor_script"

function sys.editor_script:on_insert(entity, store)
    if entity.editor_script and entity.editor_script.insert then
        return entity.editor_script.insert(entity, store, entity.editor_script.insert)
    else
        return true
    end
end

function sys.editor_script:on_remove(entity, store)
    if entity.editor_script and entity.editor_script.remove then
        return entity.editor_script.remove(entity, store, entity.editor_script.remove)
    else
        return true
    end
end

function sys.editor_script:on_update(dt, ts, store)
    for _, e in E:filter_iter(store.entities, "editor_script") do
        local s = e.editor_script

        if not s.update then
            -- block empty
        else
            if not s.co and s.runs ~= 0 then
                s.runs = s.runs - 1
                s.co = coroutine.create(s.update)
            end

            if s.co then
                local success, error = coroutine.resume(s.co, e, store, s)

                if coroutine.status(s.co) == "dead" or error ~= nil then
                    if error ~= nil then
                        log.error("Error running editor_script coro: %s", debug.traceback(s.co, error))
                    end

                    s.co = nil
                end
            end
        end
    end
end

sys.endless_patch = {}
sys.endless_patch.name = "endless_patch"
function sys.endless_patch:on_insert(entity, store)
    if store.level_mode_override == GAME_MODE_ENDLESS then
        if not entity._endless_strengthened then
            entity._endless_strengthened = true
            if entity.enemy then
                if entity.health.hp_max then
                    entity.health.hp_max = ceil(entity.health.hp_max * store.endless.enemy_health_factor)
                    entity.health.damage_factor = entity.health.damage_factor * store.endless.enemy_health_damage_factor
                    entity.health.instakill_resistance = entity.health.instakill_resistance +
                                                             store.endless.enemy_instakill_resistance
                end
                if entity.unit.damage_factor then
                    entity.unit.damage_factor = entity.unit.damage_factor * store.endless.enemy_damage_factor
                end
                if entity.motion.max_speed then
                    entity.motion.max_speed = entity.motion.max_speed * store.endless.enemy_speed_factor
                end
                entity.enemy.gold = ceil(entity.enemy.gold * store.endless.enemy_gold_factor)
            elseif entity.soldier then
                if entity.health and entity.health.hp_max then
                    entity.health.hp_max = ceil(entity.health.hp_max * store.endless.soldier_health_factor)
                    entity.health.hp = entity.health.hp_max
                    -- entity.health.damage_factor = entity.health.damage_factor * store.endless.soldier_health_damage_factor
                end
                if entity.unit then
                    entity.unit.damage_factor = entity.unit.damage_factor * store.endless.soldier_damage_factor
                end
                if entity.cooldown_factor then
                    entity.cooldown_factor = entity.cooldown_factor * store.endless.soldier_cooldown_factor
                end
                if entity.hero then
                    entity.unit.damage_factor = entity.unit.damage_factor * store.endless.hero_damage_factor
                    entity.cooldown_factor = entity.cooldown_factor * store.endless.hero_cooldown_factor
                    entity.health.hp_max = ceil(entity.health.hp_max * store.endless.hero_health_factor)
                    entity.health.hp = entity.health.hp_max
                end
            elseif entity.tower then
                entity.tower.damage_factor = entity.tower.damage_factor * store.endless.tower_damage_factor
                entity.tower.cooldown_factor = entity.tower.cooldown_factor * store.endless.tower_cooldown_factor
            end
        end
    end
    return true
end

local SpatialHash = require("spatial_hash")
sys.spatial_index = {}
sys.spatial_index.name = "spatial_index"

function sys.spatial_index:init(store)
    store.enemy_spatial_index = SpatialHash:new(50)
end

function sys.spatial_index:on_insert(entity, store)
    if entity.enemy then
        store.enemy_spatial_index:insert_entity(entity)
    end
    return true
end

function sys.spatial_index:on_remove(entity, store)
    if entity.enemy then
        store.enemy_spatial_index:remove_entity(entity)
    end
    return true
end

function sys.spatial_index:on_update(dt, ts, store)
    for _, e in pairs(store.enemies) do
        store.enemy_spatial_index:update_entity(e)
    end
    -- store.enemy_spatial_index:print_debug_info()
end

sys.last_hook = {}
sys.last_hook.name = "last_hook"
function sys.last_hook:init(store)
    store.dead_soldier_count = 0
    store.enemy_count = 0
end
function sys.last_hook:on_insert(e, d)
    if e.enemy then
        d.enemies[e.id] = e -- 优化分类索引
        if not e.health.patched then
            if d.level_difficulty == DIFFICULTY_IMPOSSIBLE and d.wave_group_number > 6 then
                if d.wave_group_number <= 15 then
                    e.health.hp_max = e.health.hp_max * (1 + (d.wave_group_number - 6) * 0.0167)
                else
                    e.health.hp_max = e.health.hp_max * 1.15
                end
            end
            e.health.hp_max = d.config.enemy_health_multiplier * e.health.hp_max
            e.health.hp = e.health.hp_max
            e.health.patched = true
            e.enemy.gold = math.ceil(e.enemy.gold * d.config.enemy_gold_multiplier)
        end
        d.enemy_count = d.enemy_count + 1
    elseif e.soldier and e.health then
        d.soldiers[e.id] = e
    elseif e.modifier then
        d.modifiers[e.id] = e
        local target = d.entities[e.modifier.target_id]
        if target then
            if not target._applied_mods then
                target._applied_mods = {}
                log.error("！如果看见这条消息，请截下来发给作者 target:", target.template_name,
                    "mod:", e.template_name)
            end
            local mods = target._applied_mods
            mods[#mods + 1] = e
        end
    elseif e.tower then
        d.towers[e.id] = e
    elseif e.aura then
        d.auras[e.id] = e
    end
    if e.particle_system then
        d.particle_systems[e.id] = e
    end
    if e.main_script then
        if e.main_script.update then
            d.entities_with_main_script_on_update[e.id] = e
        end
    end
    if e.timed then
        d.entities_with_timed[e.id] = e
    end
    if e.tween then
        d.entities_with_tween[e.id] = e
    end
    if e.render then
        d.entities_with_render[e.id] = e
    end

    if e.motion and e.motion.max_speed ~= 0 then
        e.motion.real_speed = e.motion.max_speed
    end
    return true
end
function sys.last_hook:on_remove(e, d)
    if e.enemy then
        d.enemies[e.id] = nil -- 优化分类索引
        d.enemy_count = d.enemy_count - 1
    elseif e.soldier then
        d.soldiers[e.id] = nil
        d.dead_soldier_count = d.dead_soldier_count + 1
    elseif e.modifier then
        d.modifiers[e.id] = nil
        local target = d.entities[e.modifier.target_id]
        if target then
            local mods = target._applied_mods
            for i = 1, #mods do
                if mods[i] == e then
                    table.remove(mods, i)
                    break
                end
            end
        end
    elseif e.tower then
        d.towers[e.id] = nil
    elseif e.aura then
        d.auras[e.id] = nil
    end
    if e.particle_system then
        d.particle_systems[e.id] = nil
    end
    if e.main_script then
        if e.main_script.update then
            d.entities_with_main_script_on_update[e.id] = nil
        end
    end
    if e.timed then
        d.entities_with_timed[e.id] = nil
    end
    if e.tween then
        d.entities_with_tween[e.id] = nil
    end
    if e.render then
        d.entities_with_render[e.id] = nil
    end
    -- log.error(e.template_name)
    return true
end

if PERFORMANCE_MONITOR_ENABLED then
    -- 需要监控的系统方法列表
    local MONITORED_METHODS = {"on_update", "on_insert", "on_remove", "on_queue", "on_dequeue"}

    -- 包装系统方法以添加性能监控
    local function create_monitored_system(original_sys)
        local monitored = {}
        for k, v in pairs(original_sys) do
            monitored[k] = v
        end

        -- 为每个需要监控的方法添加包装
        for _, method_name in ipairs(MONITORED_METHODS) do
            if original_sys[method_name] then
                local original_method = original_sys[method_name]
                local timer_name = (original_sys.name or "unknown") .. "." .. method_name

                monitored[method_name] = function(self, ...)
                    perf.start_timer(timer_name)
                    local result = original_method(self, ...)
                    perf.end_timer(timer_name)
                    return result
                end
            end
        end

        return monitored
    end

    -- 添加帧时间监控系统
    sys.performance_monitor = {}
    sys.performance_monitor.name = "performance_monitor"

    function sys.performance_monitor:init(store)
        self.last_frame_time = love.timer.getTime()
        self.last_report_time = love.timer.getTime()
    end

    function sys.performance_monitor:on_update(dt, ts, store)
        local current_time = love.timer.getTime()
        local frame_time = current_time - self.last_frame_time

        -- 记录帧时间
        table.insert(perf.frame_times, frame_time)
        if #perf.frame_times > perf.max_samples then
            table.remove(perf.frame_times, 1)
        end

        -- 定期输出报告
        if current_time - self.last_report_time > perf.report_interval then
            perf.save_report(store)
            perf.save_store_entities(store)
            self.last_report_time = current_time
        end

        self.last_frame_time = current_time
    end

    -- 包装所有现有系统以添加性能监控
    local original_systems = {}
    for name, system in pairs(sys) do
        if type(system) == "table" and system.name then
            original_systems[name] = system
            sys[name] = create_monitored_system(system)
        end
    end

    -- 添加手动触发性能报告的函数（可以在游戏中调用）
    function sys.trigger_performance_report(store)
        perf.save_report(store)
    end
end

return sys

