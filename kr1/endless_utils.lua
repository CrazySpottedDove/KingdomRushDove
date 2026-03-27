local E = require("entity_db")

require("all.constants")

local EL = require("kr1.data.endless")
local enemy_buff = EL.enemy_buff
local friend_buff = EL.friend_buff
local enemy_upgrade_max_levels = EL.enemy_upgrade_max_levels
local endless_template = EL.template
local TechRegistry = require("kr1.endless.tech_registry")
local TechHandlerGlobal = require("kr1.endless.tech_handlers.global")
local TechHandlerFriendCore = require("kr1.endless.tech_handlers.friend_core")
local TechHandlerArcher = require("kr1.endless.tech_handlers.archer")
local TechHandlerMage = require("kr1.endless.tech_handlers.mage")
local TechHandlerRain = require("kr1.endless.tech_handlers.rain")
local TechHandlerEngineer = require("kr1.endless.tech_handlers.engineer")
local TechHandlerBarrack = require("kr1.endless.tech_handlers.barrack")
local storage = require("all.storage")
local P = require("path_db")
local log = require("lib.klua.log"):new("endless_utils")
local bit = require("bit")
local band = bit.band

local EU = {}
local tech_registry_inited = false
local warned_unhandled_upgrade = {}
local warned_invalid_upgrade_key = {}

local function debug_enabled(flag_name)
	-- 小工具函数：集中判断开关，后面所有 debug_log 都走它。
	return EL[flag_name] == true
end

local function debug_log(flag_name, fmt, ...)
	if debug_enabled(flag_name) then
		log.info(fmt, ...)
	end
end

local function get_tech_def(key)
	return TechRegistry.get(key)
end

local function has_template_handler(key)
	local def = get_tech_def(key)
	return def and def.apply_template ~= nil
end

local function has_runtime_handler(key)
	local def = get_tech_def(key)
	return def and def.apply_runtime ~= nil
end

local function has_any_handler(key)
	return has_template_handler(key) or has_runtime_handler(key)
end

local function warn_invalid_upgrade_once(tag, fmt, ...)
	-- 同类错误只报一次，避免日志淹没关键信息。
	if warned_invalid_upgrade_key[tag] then
		return
	end
	warned_invalid_upgrade_key[tag] = true
	log.error(fmt, ...)
end

local function validate_runtime_upgrade_key(key, endless)
	-- 局内升级入口校验：不合法就早退，保证流程稳。
	if endless.upgrade_levels[key] == nil then
		warn_invalid_upgrade_once("runtime_unknown:" .. tostring(key), "ignore unknown endless upgrade key=%s", tostring(key))
		return false
	end
	if EL.upgrade_max_levels[key] == nil then
		warn_invalid_upgrade_once("runtime_missing_max:" .. tostring(key), "missing upgrade_max_levels config for key=%s", tostring(key))
		return false
	end
	return true
end

local function validate_template_upgrade_key(key, level)
	-- 读档/开局模板应用校验：历史脏数据直接跳过，不让整局崩。
	if EL.upgrade_max_levels[key] == nil then
		warn_invalid_upgrade_once("template_missing_max:" .. tostring(key), "patch_upgrades skip key without upgrade_max_levels config key=%s level=%s", tostring(key), tostring(level))
		return false
	end
	return true
end

local function audit_tech_registry_coverage()
	if not debug_enabled("debug_check_registry_coverage") then
		return
	end

	local missing = {}
	local template_missing = {}
	local runtime_missing = {}

	for key, _ in pairs(EL.upgrade_max_levels) do
		if not get_tech_def(key) then
			missing[#missing + 1] = key
		end
		if not has_template_handler(key) then
			template_missing[#template_missing + 1] = key
		end
		if not has_runtime_handler(key) then
			runtime_missing[#runtime_missing + 1] = key
		end
	end

	table.sort(missing)
	table.sort(template_missing)
	table.sort(runtime_missing)

	if #missing > 0 then
		log.error("endless tech registry missing handlers(%s): %s", #missing, table.concat(missing, ", "))
	else
		local ids = TechRegistry.ids()
		log.info("endless tech registry coverage check passed (%s/%s)", #ids, #ids)
		debug_log(
			"debug_check_registry_coverage",
			"endless tech phase coverage: template_missing=%s runtime_missing=%s",
			tostring(#template_missing),
			tostring(#runtime_missing)
		)
	end
end

local function ensure_tech_registry()
	if tech_registry_inited then
		return
	end

	local ctx = {
		EL = EL,
		friend_buff = friend_buff
	}

	TechHandlerGlobal.register(TechRegistry, ctx)
	TechHandlerFriendCore.register(TechRegistry, ctx)
	TechHandlerArcher.register(TechRegistry, ctx)
	TechHandlerMage.register(TechRegistry, ctx)
	TechHandlerRain.register(TechRegistry, ctx)
	TechHandlerEngineer.register(TechRegistry, ctx)
	TechHandlerBarrack.register(TechRegistry, ctx)

	if EL.debug_print_registered_techs then
		local ids = TechRegistry.ids()
		log.info("registered endless techs(%s): %s", #ids, table.concat(ids, ", "))
	end
	audit_tech_registry_coverage()

	tech_registry_inited = true
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

	debug_log(
		"debug_trace_init",
		"init_endless level=%s load_from_history=%s enemy_types=%s paths=%s spawn_per_wave=%s weight_per_wave=%s",
		tostring(level_name),
		tostring(endless.load_from_history),
		tostring(#endless.enemy_list),
		tostring(#endless.available_paths),
		tostring(endless.spawn_count_per_wave),
		tostring(endless.enemy_weight_per_wave)
	)

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
			local this_spawn_weight = math.ceil(endless.enemy_weight_per_wave / endless.spawn_count_per_wave * (0.8 + 0.4 * j / endless.spawn_count_per_wave))

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
	local upgraded_keys = {}

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
		upgraded_keys[#upgraded_keys + 1] = key .. ":" .. tostring(endless.enemy_upgrade_levels[key])

		if endless.enemy_upgrade_levels[key] >= enemy_upgrade_max_levels[key] then
			table.removeobject(endless.enemy_upgrade_options, key)
		end
	end

	debug_log(
		"debug_trace_enemy_growth",
		"patch_enemy_growth count=%s picked=[%s] hp=%.3f dmg=%.3f spd=%.3f instakill=%.3f",
		tostring(#upgraded_keys),
		table.concat(upgraded_keys, ", "),
		endless.enemy_health_factor,
		endless.enemy_damage_factor,
		endless.enemy_speed_factor,
		endless.enemy_instakill_resistance
	)
end

-- 老映射已废弃，逻辑都在 tech_registry。
-- 这里留空表只做兼容，防止历史调用点直接报错。
-- 我补充两句：变量名保留是刻意设计，旧逻辑进来会自然落到注册表处理，不会直接炸。
local patch_upgrade_map = {}
local patch_upgrade_in_game_map = {}

function EU.patch_upgrade_in_game(key, store, endless)
	if not key then
		return
	end

	if not validate_runtime_upgrade_key(key, endless) then
		return
	end

	ensure_tech_registry()

	endless.upgrade_levels[key] = endless.upgrade_levels[key] + 1

	if endless.upgrade_levels[key] >= EL.upgrade_max_levels[key] then
		table.removeobject(endless.upgrade_options, key)
	end

	if EL.force_upgrade_max_levels[key] and endless.upgrade_levels[key] >= EL.force_upgrade_max_levels[key] then
		table.removeobject(endless.gold_extra_upgrade_options, key)
	end

	local level = endless.upgrade_levels[key]
	local handled = TechRegistry.apply_runtime(key, level, store, endless, {
		EL = EL,
		friend_buff = friend_buff
	})

	debug_log(
		"debug_trace_upgrades",
		"patch_upgrade_in_game key=%s level=%s handled_by_registry=%s",
		tostring(key),
		tostring(level),
		tostring(handled)
	)

	if not handled then
		local patch_func = patch_upgrade_in_game_map[key]
		if patch_func then
			patch_func(level, store, endless)
		elseif debug_enabled("debug_trace_upgrades") and not has_any_handler(key) and not warned_unhandled_upgrade["runtime:" .. tostring(key)] then
			warned_unhandled_upgrade["runtime:" .. tostring(key)] = true
			log.error("no runtime handler for endless upgrade key=%s level=%s", tostring(key), tostring(level))
		elseif debug_enabled("debug_trace_upgrades") and not warned_unhandled_upgrade["runtime_template_only:" .. tostring(key)] then
			warned_unhandled_upgrade["runtime_template_only:" .. tostring(key)] = true
			debug_log("debug_trace_upgrades", "runtime phase skip key=%s (template-only handler)", tostring(key))
		end
	end
end

function EU.patch_upgrades(endless)
	ensure_tech_registry()
	local skipped_invalid_keys = {}

	for k, v in pairs(endless.upgrade_levels) do
		if v > 0 then
			if not validate_template_upgrade_key(k, v) then
				skipped_invalid_keys[#skipped_invalid_keys + 1] = k
			else
				local handled = TechRegistry.apply_template(k, v, endless, {
					EL = EL,
					friend_buff = friend_buff
				})

				debug_log(
					"debug_trace_upgrades",
					"patch_upgrades key=%s level=%s handled_by_registry=%s",
					tostring(k),
					tostring(v),
					tostring(handled)
				)

				if not handled and patch_upgrade_map[k] then
					patch_upgrade_map[k](v, endless)
				elseif not handled and debug_enabled("debug_trace_upgrades") and not has_any_handler(k) and not warned_unhandled_upgrade["template:" .. tostring(k)] then
					warned_unhandled_upgrade["template:" .. tostring(k)] = true
					log.error("no template handler for endless upgrade key=%s level=%s", tostring(k), tostring(v))
				elseif not handled and debug_enabled("debug_trace_upgrades") and not warned_unhandled_upgrade["template_runtime_only:" .. tostring(k)] then
					warned_unhandled_upgrade["template_runtime_only:" .. tostring(k)] = true
					debug_log("debug_trace_upgrades", "template phase skip key=%s (runtime-only handler)", tostring(k))
				end
			end
		end
	end

	if #skipped_invalid_keys > 0 then
		table.sort(skipped_invalid_keys)
		log.error("patch_upgrades skipped invalid keys(%s): %s", #skipped_invalid_keys, table.concat(skipped_invalid_keys, ", "))
	end
end

return EU
