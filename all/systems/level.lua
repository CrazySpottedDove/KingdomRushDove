local log = require("lib.klua.log"):new("systems")
local signal = require("lib.hump.signal")
local perf = require("dove_modules.perf.perf")

require("all.constants")

local A = require("animation_db")
local DI = require("difficulty")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("kr1.game_settings")
local P = require("path_db")
local W = require("wave_db")
local UP = require("kr1.upgrades")
local SPELLS = require("spell_system")
local U = require("utils")
local LU = require("level_utils")
local storage = require("all.storage")
require("lib.klua.table")

local ceil = math.ceil
local random = math.random

local EXO = require("all.exoskeleton")
local configer = require("dove_modules.configer")

local CUSTOM_SLOT = "custom_slot.lua"

local function save_custom_victory(store, stars)
	if not store.custom_map_entry then
		return
	end

	local data = storage:load_lua(CUSTOM_SLOT)
	if type(data) ~= "table" then
		data = {
			maps = {}
		}
	end
	data.maps = data.maps or {}

	local progress = data.maps[store.custom_map_entry] or {}
	progress.stars = math.max(stars, tonumber(progress.stars) or 0)
	progress[store.level_mode] = math.max(store.level_difficulty, tonumber(progress[store.level_mode]) or 0)
	data.maps[store.custom_map_entry] = progress

	storage:write_lua(CUSTOM_SLOT, data)
end

local level = {}
level.name = "level"

function level:init_coroutined(store)
	perf.set_enabled(configer.ui_settings().perf_enabled)
	perf.clear()
	local slot = storage:load_slot(nil, true)

	UP:set_levels(slot.upgrades)

	local line_key = tostring(slot.upgrade_list_id or "1")

	if not UP.list[line_key] then
		line_key = "1"
	end

	UP:set_list_id(line_key)
	DI:set_level(store.level_difficulty)

	-- power3 法术：解析本局选择（可为 nil = 未选择）
	SPELLS:set_selected(slot.spell_power_id)

	GR:load(store.level_name)
	P:load(store.level_name, store.visible_coords)
	game.progress = 0.2
	coroutine.yield()

	if configer.config().enabled and configer.config().reverse_path then
		P:reverse_all_paths()
	end

	E:Load()
	game.progress = 0.3
	coroutine.yield()

	-- 预加载关卡的 required_templates
	if store.level.data and store.level.data.required_templates then
		local groups = store.level.data.required_templates
		for i = 1, #groups do
			local module_name = "kr1.template_groups." .. groups[i]
			require(module_name)
			package.loaded[module_name] = nil
		end
	end

	-- 支持在插件中在 level:init(store) 里面定义关卡独占的模板
	if store.level.init then
		store.level:init(store)
	end

	-- power3 法术：在预编译前热注册本局选中法术的模板
	SPELLS:register_templates(E)

	-- 选中法术时对全体敌人额外加生命
	DI:set_spell_hp_factor(SPELLS:hp_factor())
	DI:patch_templates()
	E:precompute()
	E:clear_backup()
	game.progress = 0.4
	coroutine.yield()

	W:load(store.level_name, store.level_mode)
	game.progress = 0.5
	coroutine.yield()

	A:load()
	-- 清掉上一局遗留的链接缓存，避免 atlas 卸载后悬垂
	A:unlink()
	game.progress = 0.6
	coroutine.yield()

	EXO:load()
	game.progress = 0.7
	coroutine.yield()

	store.selected_hero = slot.heroes.selected

	-- 先进行 spell apply，以使 spell 中模板可受 UP 影响
	SPELLS:apply(store)
	UP:patch_templates(store.level.max_upgrade_level or GS.max_upgrade_level)

	-- 防护：避免某些不合适的插件破坏存档中的科技。这表现为 user_power_1 未正确设置具体模板
	if E:get_template("user_power_1").template_name == "user_power_1" then
		slot.upgrade_list_id = "1"
		UP:set_list_id("1")
		UP:patch_templates(store.level.max_upgrade_level or GS.max_upgrade_level)
		storage:save_slot(slot, nil, true)
	end

	E:patch_config(configer.config())

	-- 随机化敌人放在 level:init 后面，避免 level 中定义的敌人未定义导致随机化失败的问题
	if configer.config().enabled and configer.config().random_creeps then
		W:randomize_creeps()
	end
	game.progress = 0.8
	coroutine.yield()

	if store.level.data then
		if store.level.data.entities_list then
			store.level.locations = {}

			LU.insert_entities(store, store.level.data.entities_list)
		end

		LU.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)
	end

	if store.level.load then
		store.level:load(store)
	end

	store.level.co = nil
	store.level.run_complete = nil
	store.player_gold = ceil(W:initial_gold() * (configer.config().enabled and configer.config().gold_multiplier or 1))

	store.hero_xp_multiplier = GS.hero_xp_gain_per_difficulty_mode[store.level_difficulty] * (configer.config().enabled and configer.config().hero_xp_gain_multiplier or 1)

	if not store.custom_map_entry then
		if store.level_idx <= 9 then
			store.hero_xp_multiplier = 0.1 * store.level_idx * store.hero_xp_multiplier
		elseif store.level_idx <= 35 and store.level_idx > 26 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 26) * store.hero_xp_multiplier
		elseif store.level_idx <= 57 and store.level_idx > 48 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 48) * store.hero_xp_multiplier
		elseif store.level_idx <= 109 and store.level_idx > 100 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 100) * store.hero_xp_multiplier
		elseif store.level_idx <= 209 and store.level_idx > 200 then
			store.hero_xp_multiplier = 0.1 * (store.level_idx - 200) * store.hero_xp_multiplier
		end
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

	if configer.config().enabled and configer.config().ban_random_towers then
		local locked_towers = store.level.locked_towers
		for i = 4, #GS.archer_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.archer_towers[i]
			end
		end
		for i = 4, #GS.mage_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.mage_towers[i]
			end
		end
		for i = 4, #GS.engineer_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.engineer_towers[i]
			end
		end
		for i = 4, #GS.barrack_towers do
			if math.random() < 0.5 then
				locked_towers[#locked_towers + 1] = GS.barrack_towers[i]
			end
		end
	end

	if configer.criket() and configer.criket().on then
		store.lives = 0
	elseif store.level_mode == GAME_MODE_CAMPAIGN then
		store.lives = 20
	elseif store.level_mode == GAME_MODE_HEROIC then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_IRON then
		store.lives = 1
	end

	store.player_score = 0
	store.game_outcome = nil
	store.main_hero = nil
end

function level:on_update(dt, ts, store)
	if not store.level.update then
		store.level.run_complete = true
	else
		if not store.level.co and not store.level.run_complete then
			store.level.co = coroutine.create(store.level.update)
		end

		if store.level.co then
			local _, error = coroutine.resume(store.level.co, store.level, store)

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
		store._common_notifications = true

		if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
			signal.emit("wave-notification", "view", "TIP_UPGRADES")
		elseif store.selected_hero and #store.selected_hero ~= 0 and not U.is_seen(store, "TIP_HEROES") then
			signal.emit("wave-notification", "icon", "TIP_HEROES")
		end
	end

	if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
		LU.insert_hero(store)
	end

	-- 只在有 wait_signal all_enemies_died 挂着时才轮询（否则每帧扫描全实体太贵）
	if store._waiting_all_enemies_died then
		if store.ephemeral._had_enemies then
			if not LU.has_alive_enemies(store) then
				signal.emit("all_enemies_died")

				store.ephemeral._had_enemies = false
			end
		elseif LU.has_alive_enemies(store) then
			store.ephemeral._had_enemies = true
		end
	end

	if not store.game_outcome then
		if store.lives < 1 and (not configer.criket() or not configer.criket().on) then
			log.info("++++ DEFEAT ++++")

			store.game_outcome = {
				victory = false,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}
			store.paused = true
			store.defeat_count = (store.defeat_count or 0) + 1

			signal.emit("game-defeat", store)
			signal.emit("game-defeat-after", store)

			if not store.custom_map_entry then
				local slot = storage:load_slot()
				slot.last_victory = nil
				storage:save_slot(slot, nil, true)
			end
		elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
			if configer.criket() and configer.criket().on then
				local stars = 3

				if store.lives < -10 then
					stars = 1
				elseif store.lives < -5 then
					stars = 2
				end

				configer.criket().time_cost = ts - configer.criket().start_time
				store.game_outcome = {
					victory = true,
					lives_left = store.lives,
					stars = stars,
					level_idx = store.level_idx,
					level_mode = store.level_mode,
					level_difficulty = store.level_difficulty
				}

				save_custom_victory(store, stars)
				signal.emit("game-victory", store)
				signal.emit("game-victory-after", store)

				return
			end

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

			save_custom_victory(store, stars)

			if not store.custom_map_entry then
				local slot = storage:load_slot()
				slot.last_victory = {
					level_idx = store.level_idx,
					level_difficulty = store.level_difficulty,
					level_mode = store.level_mode,
					stars = stars,
					unlock_towers = store.level.unlock_towers
				}
				storage:save_slot(slot, nil, true)
			end

			signal.emit("game-victory", store)
			signal.emit("game-victory-after", store)
		end
	end
end

return level
