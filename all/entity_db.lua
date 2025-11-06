-- chunkname: @./all/entity_db.lua
local log = require("klua.log"):new("entity_db")

require("klua.table")

local copy = table.deepclone
local entity_db = {}

entity_db.last_id = 1

function entity_db:load()
    self.last_id = 1
    self.components = {}
    self.entities = {}
    package.loaded.components = nil
    package.loaded.game_templates = nil
    package.loaded.templates = nil
    package.loaded.game_scripts = nil
    package.loaded.scripts = nil
    package.loaded.script_utils = nil
    package.loaded["kr1.data.balance"] = nil
    require("components")
    require("templates")
    require("game_templates")
end

-- 性能与内存测试函数
function entity_db:test()
    -- 记录初始内存
    collectgarbage("collect")
    local mem_before = collectgarbage("count") -- 单位：KB

    local t0 = os.clock()
    self:load()
    local t1 = os.clock()

    -- 统计模板数量
    local template_count = 0
    if self.entities then
        for _ in pairs(self.entities) do
            template_count = template_count + 1
        end
    end

    local component_count = 0
    if self.components then
        for _ in pairs(self.components) do
            component_count = component_count + 1
        end
    end

    -- 记录load后内存
    collectgarbage("collect")
    local mem_after = collectgarbage("count") -- 单位：KB

    print("entity_db:load() 用时: " .. string.format("%.4f", t1 - t0) .. " 秒")
    print("entity_db:load() 前内存: " .. string.format("%.2f", mem_before) .. " KB")
    print("entity_db:load() 后内存: " .. string.format("%.2f", mem_after) .. " KB")
    print("entity_db:load() 增加内存: " .. string.format("%.2f", mem_after - mem_before) .. " KB")
    print("模板数量: " .. template_count)
    print("组件数量: " .. component_count)

    -- 可选：测试批量创建实体的性能和内存
    local create_count = 1000
    local t2 = os.clock()
    local tmp_entities = {}
    for k in pairs(self.entities) do
        for i = 1, create_count do
            tmp_entities[#tmp_entities + 1] = self:create_entity(k)
        end
        break -- 只测一个模板
    end
    local t3 = os.clock()
    collectgarbage("collect")
    local mem_entities = collectgarbage("count")
    print("批量创建 " .. create_count .. " 个实体用时: " .. string.format("%.4f", t3 - t2) .. " 秒")
    print("批量创建后内存: " .. string.format("%.2f", mem_entities) .. " KB")
    print("批量创建增加内存: " .. string.format("%.2f", mem_entities - mem_after) .. " KB")
end

function entity_db:register_t(name, base)
    if self.entities[name] then
        log.error("template %s already exists", name)

        return
    end

    local t

    if base then
        t = copy(self.entities[base])
    else
        t = {}
    end

    t.template_name = name
    self.entities[name] = t

    return t
end

function entity_db:register_c(name, base)
    if self.components[name] then
        log.error("component %s already exists", name)

        return
    end

    local c = {}

    if base then
        c = copy(self.components[base])
    end

    self.components[name] = c

    return c
end

function entity_db:clone_c(name)
    if not self.components[name] then
        log.error("component %s does not exist", name)

        return
    end

    return copy(self.components[name])
end

function entity_db:add_comps(entity, ...)
    if entity == nil then
        log.error("entity is nil")

        return
    end

    for _, v in pairs({...}) do
        if not self.components[v] then
            log.error("component %s does not exist", v)

            return
        end

        entity[v] = copy(self.components[v])
    end
end

--- 只接收字符串模板名，创建对应实体
---@param t string 模板名
function entity_db:create_entity(t)
    local tpl = self.entities[t]

    -- if type(t) == "string" then
    -- 	tpl = self.entities[t]
    -- else
    -- 	tpl = t
    -- end

    if not tpl then
        log.error("template %s not found", t)

        return nil
    end

    local out = copy(tpl)

    out.id = self.last_id
    self.last_id = self.last_id + 1

    return out
end

function entity_db:clone_entity(e)
    local out = copy(e)

    out.id = self.last_id
    self.last_id = self.last_id + 1

    return out
end

function entity_db:append_templates(entity, ...)
    if entity == nil then
        log.error("entity is nil")

        return
    end

    for _, tn in pairs({...}) do
        local tpl = self.entities[tn]

        if not tpl then
            log.error("template %s not found", tn)

            return
        end

        for k, v in pairs(tpl) do
            entity[k] = copy(v)
        end
    end
end

function entity_db:get_component(c)
    local cmp

    if type(c) == "string" then
        cmp = self.components[c]
    else
        cmp = c
    end

    if not cmp then
        log.error("component %s not found", c)

        return nil
    end

    return cmp
end

--- 获取对应实体模板
---@param t string 模板名
function entity_db:get_template(t)
    local tpl = self.entities[t]

    -- if type(t) == "string" then
    -- 	tpl = self.entities[t]
    -- else
    -- 	tpl = t
    -- end

    if not tpl then
        log.error("template %s not found", t)

        return nil
    end

    return tpl
end

function entity_db:set_template(name, t)
    self.entities[name] = t
end

function entity_db:filter(entities, ...)
    local result = {}

    for id, e in pairs(entities) do
        for _, n in pairs({...}) do
            if not e[n] then
                goto label_12_0
            end
        end

        table.insert(result, e)

        ::label_12_0::
    end

    return result
end

function entity_db:filter_iter(entities, c1, c2, c3)
    local function next_entity(t, i)
        local k, v = i

        while true do
            ::label_14_0::

            k, v = next(t, k)

            if not k then
                return nil
            end

            if c1 and not v[c1] then
                goto label_14_0
            end

            if c2 and not v[c2] then
                goto label_14_0
            end

            if c3 and not v[c3] then
                goto label_14_0
            end

            return k, v
        end
    end

    return next_entity, entities, nil
end

function entity_db:filter_templates(...)
    return self:filter(self.entities, ...)
end

function entity_db:search_entity(p)
    local results = {}

    for k, e in pairs(self.entities) do
        if string.match(k, p) then
            table.insert(results, k)
        end
    end

    return results
end
function entity_db:gen_wave(level_idx, game_mode)
    local game_mode_str_map = {
        [GAME_MODE_CAMPAIGN] = "campaign",
        [GAME_MODE_HEROIC] = "heroic",
        [GAME_MODE_IRON] = "iron"
    }
    local file_name = string.format("data.waveconfigs.level%02d_waves_%s_config", level_idx,
        game_mode_str_map[game_mode])
    local cfg = require(file_name)

    -- 让小权重的敌人更容易得到机会
    local function weighted_random(list, weight_map, wave_i)
        local result = nil
        local factor = ((cfg.max_waves - wave_i) / cfg.max_waves) * 0.5
        while not result do
            local possible_choice = list[math.random(1, #list)]
            local weight = weight_map[possible_choice]
            if math.random() < (1 / (weight ^ factor)) then
                result = possible_choice
            end
        end
        return result
    end
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    local function shuffle(tbl)
        for i = #tbl, 2, -1 do
            local j = math.random(1, i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end
    local function get_size(t)
        local size = 0
        for _, _ in pairs(t) do
            size = size + 1
        end
        return size
    end
    local bit = require("bit")

    local groups = {}

    local total_cash = cfg.initial_cash
    for enemy, _ in pairs(cfg.enemy_weight_map) do
        local ok = true
        if not self.entities[enemy] then
            log.error("entity %s not found in entity_db", enemy)
            ok = false
        end
        if not ok then
            return
        end
    end

    -- 遍历每一波
    for wave_i = 1, cfg.max_waves do
        local group = {}
        group.interval = lerp(cfg.initial_inverval, cfg.final_interval,
            cfg.max_waves > 1 and (wave_i - 1) / (cfg.max_waves - 1) or 0)
        group.waves = {}

        -- 本波总权重预算 = wave_weight_function
        local total_weight = cfg.wave_weight_function(wave_i, total_cash)

        -- 计算在本波激活的路径，并根据 cfg.path_weight_map 计算相对权重
        local active_paths = {}
        local active_weight_sum = 0
        for _, path in ipairs(cfg.paths) do
            local active_from = (cfg.path_active_map and cfg.path_active_map[path]) or 1
            if wave_i >= active_from then
                table.insert(active_paths, path)
                local pw = (cfg.path_weight_map and cfg.path_weight_map[path]) or 1
                active_weight_sum = active_weight_sum + pw
            end
        end

        -- 如果没有活跃路径，跳到下一波
        if #active_paths == 0 then
            table.insert(groups, group)
        else
            -- 分配权重到每个活跃路径（带小幅浮动）
            local path_weights = {}
            local path_count = #active_paths
            local remaining_weight = total_weight
            local fluctuation_factor = 0.2 -- 浮动比例（20%）

            for i, path in ipairs(active_paths) do
                local base_share = total_weight *
                                       (((cfg.path_weight_map and cfg.path_weight_map[path]) or 1) / active_weight_sum)
                if i < path_count then
                    local fluctuation = base_share * (math.random() * 2 - 1) * fluctuation_factor
                    path_weights[path] = math.max(0, base_share + fluctuation)
                    remaining_weight = remaining_weight - path_weights[path]
                else
                    path_weights[path] = math.max(0, remaining_weight)
                end
            end

            -- 每条路径生成子波
            for _, path in ipairs(cfg.paths) do
                -- 只对本波被激活的路径生成 subwave
                if not path_weights[path] then
                    goto continue_path
                end

                local subwave = {
                    delay = 0,
                    path_index = path,
                    spawns = {}
                }

                -- 计算本波可用敌人池，并处理必须出现与删除规则
                local enemy_pool = {}
                local guaranteed_enemies = {} -- 必须出现的敌人

                -- 支持两种 delete 表结构：以路径 id 为键，或以路径在 cfg.paths 中的序号为键
                local deleted_list = nil
                if cfg.enemy_delete_wave_map then
                    deleted_list = (cfg.enemy_delete_wave_map[path] and cfg.enemy_delete_wave_map[path][wave_i]) or nil
                end

                for _, enemy in ipairs(cfg.path_enemy_map[path] or {}) do
                    -- 如果被删除清单包含，跳过该敌人
                    local skip = false
                    if deleted_list then
                        for _, d in ipairs(deleted_list) do
                            if d == enemy then
                                skip = true
                                break
                            end
                        end
                    end
                    if skip then
                        goto continue_enemy
                    end

                    if cfg.enemy_comeout_wave_map[enemy] and cfg.enemy_comeout_wave_map[enemy] <= wave_i then
                        table.insert(enemy_pool, enemy)
                    end
                    if cfg.enemy_comeout_wave_map[enemy] and cfg.enemy_comeout_wave_map[enemy] == wave_i then
                        table.insert(guaranteed_enemies, enemy)
                    end

                    ::continue_enemy::
                end

                local remain_weight = path_weights[path]
                shuffle(enemy_pool)
                enemy_pool = table.slice(enemy_pool, 1, math.min(#enemy_pool, cfg.wave_max_types))

                -- 先处理 guaranteed_enemies，确保它们一定会出现在当前波次
                for _, enemy in ipairs(guaranteed_enemies) do
                    -- 如果 guaranteed_enemies 不在 enemy_pool（可能因类型上限），仍然强制加入
                    local weight = cfg.enemy_weight_map[enemy] or 1
                    local spawn_weight = math.min(cfg.min_spawn_weight, math.max(cfg.min_spawn_weight, remain_weight))
                    local count = math.max(1, math.floor(spawn_weight / weight))

                    local interval = cfg.interval_function(weight, self.entities[enemy], wave_i)
                    local spawn = {
                        interval = interval * (1 + (math.random() - 0.5) * 0.2), -- ±10%
                        interval_next = interval * 0.5,
                        creep = enemy,
                        path = 1,
                        fixed_sub_path = 0,
                        max_same = 0,
                        max = count
                    }

                    remain_weight = remain_weight - count * weight
                    table.insert(subwave.spawns, spawn)
                end

                -- 分段建立 spawn，处理其他敌人
                while remain_weight > cfg.min_spawn_weight and #enemy_pool > 0 do
                    -- 随机选敌人，但按权重倾向
                    local enemy = weighted_random(enemy_pool, cfg.enemy_weight_map, wave_i)

                    local weight = cfg.enemy_weight_map[enemy] or 1
                    local spawn_weight = math.random(cfg.min_spawn_weight, cfg.max_spawn_weight)
                    spawn_weight = math.min(spawn_weight, remain_weight)

                    local count = math.max(1, math.floor(spawn_weight / weight))

                    local interval = cfg.interval_function(weight, self.entities[enemy], wave_i)
                    local spawn = {
                        interval = interval * (1 + (math.random() - 0.5) * 0.2), -- ±10%
                        interval_next = interval * 0.5,
                        creep = enemy,
                        path = 1,
                        fixed_sub_path = 0,
                        max_same = 0,
                        max = count
                    }

                    remain_weight = remain_weight - count * weight
                    table.insert(subwave.spawns, spawn)

                    -- 如果 enemy_pool 中类型过多，可能希望限制重复选择，简单做法是移除已选或降低权重 —— 这里移除以鼓励多样性
                    for i = #enemy_pool, 1, -1 do
                        if enemy_pool[i] == enemy then
                            table.remove(enemy_pool, i)
                            break
                        end
                    end
                end

                table.insert(group.waves, subwave)

                ::continue_path::
            end

            -- ===== 按 spawn.interval*max + interval_next 估算每个 subwave 时长，并参考权重大的子波做平衡调整 =====
            do
                -- 计算每个 subwave 的估算时长（取 spawn 中最大的 estimate）
                local est_list = {}
                local max_est = 0
                for i, sw in ipairs(group.waves) do
                    local est = 0
                    for _, spawn in ipairs(sw.spawns) do
                        local s_est = (spawn.interval or 0) * (spawn.max or 1) + (spawn.interval_next or 0)
                        if s_est > est then
                            est = s_est
                        end
                    end
                    est_list[i] = est
                    if est > max_est then
                        max_est = est
                    end
                end

                -- 参考值：取组内最长的子波时长与 group.interval 的较大者（保证不会比最长子波更短）
                local reference = math.max(max_est, group.interval or 0)

                -- 对每个子波做缩放，避免权重小的子波瞬间刷完
                for i, sw in ipairs(group.waves) do
                    local est = est_list[i] or 0
                    if est > 0 then
                        -- 目标最小占比（避免微小子波）与最大缩放限制
                        local min_ratio = 0.85
                        local min_target = reference * min_ratio

                        if est < min_target then
                            local scale = min_target / est
                            -- 限制缩放幅度，避免过度拉伸或压缩
                            scale = math.max(0.6, math.min(scale, 3))

                            for _, spawn in ipairs(sw.spawns) do
                                -- 按比例调整 interval 与 interval_next（保持二者相对关系）
                                spawn.interval = (spawn.interval or 1) * scale
                                spawn.interval_next = (spawn.interval_next or (spawn.interval * 0.5)) * scale
                                -- 保持原有 ±10% 抖动
                                spawn.interval = spawn.interval * (1 + (math.random() - 0.5) * 0.2)
                            end
                        end
                    end
                end
            end

            for _, subwave in ipairs(group.waves) do
                for _, spawn in ipairs(subwave.spawns) do
                    local e = self.entities[spawn.creep]
                    if bit.band(e.vis.flags, F_FLYING) ~= 0 then
                        subwave.some_flying = true
                    end
                    total_cash = total_cash + e.enemy.gold * spawn.max
                end
            end

            table.insert(groups, group)
        end
    end

    -- 遍历每个 group，打乱 spawns
    for _, group in ipairs(groups) do
        for _, subwave in ipairs(group.waves) do
            shuffle(subwave.spawns)
        end
    end

    local file_data = {
        cash = cfg.initial_cash,
        groups = groups
    }

    local save_file_name = string.format("kr1/data/waves/level%02d_waves_%s.lua", level_idx,
        game_mode_str_map[game_mode])
    local persistence = require("klua.persistence")
    local data_string = persistence.serialize_to_string(file_data)

    -- 写入文件
    local file, err = io.open(save_file_name, "w")
    if not file then
        return false, err
    end

    file:write(data_string)
    file:close()
end

return entity_db
