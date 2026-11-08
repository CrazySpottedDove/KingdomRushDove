-- 插件验收命令：加载插件 / 进入插件关卡。
-- 结果通过 JSON 响应返回，不再写 plugin_test_result.json。
local plugin_paths = require("plugin_paths")
local storage = require("all.storage")
local constants = require("all.constants")
local plugin = {}

local function load_config(entry)
	local config, err = plugin_paths.load_lua_table(plugin_paths.metadata_path(entry))

	if type(config) ~= "table" then
		error(string.format("invalid config.lua for %s: %s", tostring(entry), tostring(err)))
	end

	if config.entry ~= entry then
		error(string.format("config.entry mismatch: expected %s, got %s", tostring(entry), tostring(config.entry)))
	end

	return config
end

function plugin.plugins_load_all(harness)
	harness.plugin_main:after_init()

	local names = {}

	for entry in pairs(harness.plugin_main.registry) do
		names[#names + 1] = entry
	end

	table.sort(names)

	return {
		plugins = names,
		count = #names
	}
end

function plugin.plugin_load(harness, args)
	local entry = args.entry

	if not entry then
		error("plugin_load requires entry")
	end

	local existing = harness.plugin_main.registry[entry]

	if existing then
		return {
			ok = true,
			entry = entry,
			version = existing.version or "",
			category = existing.category or "",
			cached = true
		}
	end

	local config = load_config(entry)

	config.enabled = true

	local plugin_data = {
		config = config,
		has_plugin_config = plugin_paths.has_plugin_config(entry)
	}
	local module, load_err = harness.plugin_main.load_plugin_module(plugin_data)

	if type(module) ~= "table" then
		error(string.format("plugin %s load failed: %s", entry, tostring(load_err)))
	end

	if type(module.init) ~= "function" then
		error(string.format("plugin %s init is not a function", entry))
	end

	harness.plugin_main.registry[entry] = config

	local ok, init_err = xpcall(module.init, function(err)
		return debug.traceback(err)
	end, module, plugin_data)

	if not ok then
		error(string.format("plugin %s init failed: %s", entry, tostring(init_err)))
	end

	-- 让自定义地图列表也能看到目标插件（下载包里的 config.enabled 可能是 false）。
	local plugin_db = require("plugin_db")
	local found = false

	for _, plugin_data_item in ipairs(plugin_db.plugins_datas or {}) do
		if plugin_data_item.config.entry == entry then
			plugin_data_item.config = config
			found = true

			break
		end
	end

	if not found then
		table.insert(plugin_db.plugins_datas, plugin_data)

		plugin_db.plugins_count = #plugin_db.plugins_datas
	end

	return {
		ok = true,
		entry = entry,
		version = config.version or "",
		category = config.category or ""
	}
end

function plugin.open_custom_level(harness, args)
	local entry = args.entry

	if not entry then
		error("open_custom_level requires entry")
	end

	local base = plugin_paths.plugin_dir(entry)
	local level_file = base .. "/data/levels/" .. entry .. "_data.lua"
	local wave_file = base .. "/data/waves/" .. entry .. "_waves_campaign.lua"

	if not love.filesystem.getInfo(level_file, "file") or not love.filesystem.getInfo(wave_file, "file") then
		error(string.format("level files missing: %s / %s", level_file, wave_file))
	end

	local metadata = plugin_paths.load_lua_table(base .. "/data/levels/" .. entry .. "_metadata.lua") or {}
	local config = plugin_paths.load_lua_table(plugin_paths.metadata_path(entry))

	if type(config) == "table" then
		harness.plugin_main.registry[entry] = config
	end

	if not storage:load_slot(1) then
		storage:create_slot(1)
	end

	storage:set_active_slot(1)

	harness.game_started = false
	harness.autoplay = nil

	local mode = tonumber(args.mode) or constants.GAME_MODE_CAMPAIGN
	local difficulty = tonumber(args.difficulty) or constants.DIFFICULTY_NORMAL

	harness.director.next_item_name = "game"
	harness.director.next_item_args = {
		next_item_name = "game",
		level_mode = mode,
		level_difficulty = difficulty,
		custom_map_entry = entry,
		custom_map_level_name = entry,
		custom_map_root = base,
		custom_map_return_to = "map",
		custom_battle_music = type(metadata) == "table" and metadata.battle_music or nil,
		custom_battle_prep_music = type(metadata) == "table" and metadata.battle_prep_music or nil
	}

	return {
		queued = "game",
		entry = entry,
		mode = mode,
		difficulty = difficulty
	}
end

--- 关卡插件的完整冒烟：自定义地图界面 -> 进入关卡 -> 触发第一波 -> 实跑 N 秒。
--- 这样地图元数据、关卡加载、波次和运行时脚本都会被覆盖，而不是只等 game-start。
function plugin.plugin_level_test(harness, args)
	local entry = args.entry

	if not entry then
		error("plugin_level_test requires entry")
	end

	local screen = require("dove_modules.test.handlers.screen")
	local session = require("dove_modules.test.handlers.session")
	local loaded = plugin.plugin_load(harness, {
		entry = entry
	})

	-- 1. 先打开自定义地图界面，覆盖插件地图列表/元数据/封面等路径。
	screen.open_map(harness, {
		gen_id = "custom"
	})

	local map_result = session.run_until(harness, {
		condition = "scene",
		name = "map",
		load_timeout_ms = 30000
	})

	if not map_result.met then
		error("custom map screen did not load: " .. tostring(map_result.reason))
	end

	-- 2. 进入关卡并等待 game-start。
	plugin.open_custom_level(harness, {
		entry = entry,
		mode = args.mode,
		difficulty = args.difficulty
	})

	local start_result = session.run_until(harness, {
		condition = "game_start",
		load_timeout_ms = 30000
	})

	if not start_result.met then
		error("level did not emit game-start: " .. tostring(start_result.reason))
	end

	if not harness.game_started then
		error("level reported game-start but harness flag is false")
	end

	-- 3. 主动开第一波，并实际推进 N 秒模拟，覆盖波次/地图装饰/运行时脚本。
	local game = harness:get_game()

	if game and args.start_waves ~= false then
		game.store.send_next_wave = true
	end

	local sim_seconds = tonumber(args.sim_seconds) or 30
	local fps = DRAW_FPS
	local max_ticks = math.floor(sim_seconds * fps) + 1000

	if sim_seconds > 0 then
		local run_result = session.run_until(harness, {
			condition = "tick_ts_or_outcome",
			n = sim_seconds,
			max_ticks = max_ticks,
			load_timeout_ms = 60000
		})

		if not run_result.met then
			error(string.format("level did not run for %.1fs: %s", sim_seconds, tostring(run_result.reason)))
		end
	end

	return {
		ok = true,
		entry = entry,
		version = loaded.version,
		sim_seconds = sim_seconds,
		state = harness:snapshot()
	}
end

return plugin
