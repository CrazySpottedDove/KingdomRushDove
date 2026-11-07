-- chunkname: @./plugin/plugin_main.lua
local log = require("lib.klua.log"):new("plugin_main")
local json = require("lib.json")
local version = require("version")
local FS = love.filesystem
local signal = require("lib.hump.signal")
local storage = require("all.storage")
local constants = require("all.constants")
local additional_paths = {"plugin/?.lua", "plugin/all/?.lua", "plugins/?.lua", "plugins/all/?.lua"}
local plugin_paths = require("plugin_paths")

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())

package.path = FS.getRequirePath()

plugin_paths.ensure_storage_ready()

require("plugin_globals")

local plugin_utils = require("plugin_utils")
local hook_utils = require("hook_utils")
local plugin_db = require("plugin_db")
local plugin_main = {
	loaded_plugins = {},
	-- 以 entry 为键的已加载插件配置；errorhandler 通过模块读取，而不是依赖全局。
	registry = {}
}

--- 日志/提示里用的插件标签：显示名优先，没有就退回 entry
local function plugin_label(plugin_data)
	local config = plugin_data and plugin_data.config
	if not config then
		return "?"
	end
	return config.name
end

local function load_plugin_module(plugin_data)
	local entry = plugin_data.config.entry
	local entry_path = plugin_paths.entry_path(entry)
	if FS.getInfo(entry_path, "file") then
		local chunk, err = FS.load(entry_path)
		if not chunk then
			return nil, err
		end
		local ok, ret = pcall(chunk)
		if not ok then
			return nil, ret
		end
		return ret, nil
	end
	return nil, string.format("Entry file '%s' not found for plugin '%s'", entry_path, entry)
end

local function write_plugin_test_result(result)
	local encoded = json.encode(result)
	local path = main.params and main.params.plugin_test_result
	local written = false

	if path and path ~= "" then
		local f = io.open(path, "wb")
		if f then
			f:write(encoded)
			f:close()
			written = true
		end
	end

	if not written then
		love.filesystem.write("plugin_test_result.json", encoded)
	end

	print("PLUGIN_TEST_RESULT: " .. encoded)
	io.flush()
end

--- 进入关卡插件对应的 custom map，game-start 后写结果。
--- 这样不仅验证 init，还验证关卡文件、波次、模板和资源加载流程。
local function start_level_test(entry, config, director, result)
	local base = plugin_paths.plugin_dir(entry)
	local level_file = base .. "/data/levels/" .. entry .. "_data.lua"
	local wave_file = base .. "/data/waves/" .. entry .. "_waves_campaign.lua"
	if not FS.getInfo(level_file, "file") or not FS.getInfo(wave_file, "file") then
		result.phase = "level"
		result.error = string.format("level files missing: %s / %s", level_file, wave_file)
		write_plugin_test_result(result)
		love.event.quit(1)
		return
	end

	local metadata = plugin_paths.load_lua_table(base .. "/data/levels/" .. entry .. "_metadata.lua") or {}
	local finished = false
	local function on_game_start()
		if finished then
			return
		end
		finished = true
		signal.remove("game-start", on_game_start)
		result.ok = true
		result.phase = "level"
		result.error = ""
		write_plugin_test_result(result)
		love.event.quit(0)
	end

	plugin_main.registry[entry] = config
	signal.register("game-start", on_game_start)

	-- 无头测试没有用户存档；进入关卡前创建一个临时 slot。
	if not storage:load_slot(1) then
		storage:create_slot(1)
	end
	storage:set_active_slot(1)

	-- 与 screen_custom_map 的 start_game 使用同一组参数。
	director.next_item_name = "game"
	director.next_item_args = {
		next_item_name = "game",
		level_mode = constants.GAME_MODE_CAMPAIGN,
		level_difficulty = constants.DIFFICULTY_NORMAL,
		custom_map_entry = entry,
		custom_map_level_name = entry,
		custom_map_root = base,
		custom_map_return_to = "map",
		custom_battle_music = type(metadata) == "table" and metadata.battle_music or nil,
		custom_battle_prep_music = type(metadata) == "table" and metadata.battle_prep_music or nil
	}
end

--- 无头插件检查：只加载目标插件，执行 config -> module load -> init。
--- 成功和失败都会写结构化结果，worker 不依赖人类日志解析。
function plugin_main:run_plugin_test(entry, director)
	local result = {
		entry = entry,
		branch = version and version.branch or "master",
		version = "",
		phase = "config",
		ok = false,
		error = nil
	}

	local config, config_err = plugin_paths.load_lua_table(plugin_paths.metadata_path(entry))
	if type(config) ~= "table" then
		result.error = tostring(config_err or "invalid config.lua")
		write_plugin_test_result(result)
		love.event.quit(1)
		return
	end

	if config.entry ~= entry then
		result.error = string.format("config.entry mismatch: expected %s, got %s", tostring(entry), tostring(config.entry))
		write_plugin_test_result(result)
		love.event.quit(1)
		return
	end

	result.version = config.version or ""
	config.enabled = true
	local plugin_data = {
		config = config,
		has_plugin_config = plugin_paths.has_plugin_config(entry)
	}

	result.phase = "load"
	local plugin, load_err = load_plugin_module(plugin_data)
	if type(plugin) ~= "table" then
		result.error = tostring(load_err or "plugin entry must return a table")
		write_plugin_test_result(result)
		love.event.quit(1)
		return
	end

	result.phase = "init"
	if type(plugin.init) ~= "function" then
		result.error = "plugin.init is not a function"
		write_plugin_test_result(result)
		love.event.quit(1)
		return
	end

	plugin_main.registry[entry] = config
	local ok, init_err = xpcall(plugin.init, function(err)
		return debug.traceback(err)
	end, plugin, plugin_data)

	result.ok = ok
	result.phase = ok and "done" or "init"
	result.error = ok and "" or tostring(init_err)
	if ok then
		print(plugin_db.get_debug_info(config))
	end

	if ok and main.params and main.params.plugin_test_level and config.category == "level" then
		start_level_test(entry, config, director, result)
		return
	end

	write_plugin_test_result(result)
	love.event.quit(ok and 0 or 1)
end

function plugin_main:init(director)
	plugin_db:init()
	local plugin_main_config = plugin_paths.load_main_config()
	director:init(main.params)

	if main.params and main.params.plugin_test then
		self:run_plugin_test(main.params.plugin_test, director)
		return
	end

	if plugin_main_config.enabled then
		self:after_init()
	end
end

--- 初始化所有已启用的插件
---@return nil
function plugin_main:after_init()
	-- 提前初始化，确保 errorhandler 能通过模块读取 registry
	self.registry = {}
	PLUGIN_ERRORS = {}

	-- 倒序加载插件，确保加载模块顺序正确
	for i = plugin_db.plugins_count, 1, -1 do
		local plugin_data = plugin_db.plugins_datas[i]
		local plugin, load_err = load_plugin_module(plugin_data)

		if not plugin then
			log.error("Failed to load plugin '%s': %s", plugin_data.config.entry, tostring(load_err))
		elseif type(plugin) ~= "table" then
			log.error(string.format("Must return table, plugin: %s", plugin_data.config.entry))
		else
			table.insert(self.loaded_plugins, {plugin, plugin_data})
		end
	end

	local loaded_plugins_count = #self.loaded_plugins

	local function plugin_error_handler(err)
		-- 获取完整堆栈（跳过错误处理器本身和 xpcall 的 C 帧）
		local stack = debug.traceback(err)
		local lines = {}
		local is_first = true

		for line in stack:gmatch("[^\n]+") do
			if is_first then
				-- 保留第一行（错误消息）
				table.insert(lines, line)
				is_first = false
			else
				-- 遇到框架行则停止（不包含该行）
				if line:match("function 'after_init'") then
					break
				end
				if not string.find(line, "[C]: ", 1, true) then
					table.insert(lines, line)
				end
			end
		end

		return table.concat(lines, "\n")
	end
	-- 正序初始化插件，确保高优先级覆盖低优先级
	for i = loaded_plugins_count, 1, -1 do
		local loaded_plugin, plugin_data = unpack(self.loaded_plugins[i])
		self.registry[plugin_data.config.entry] = plugin_data.config
		-- 初始化插件
		local ok, err = xpcall(loaded_plugin.init, plugin_error_handler, loaded_plugin, plugin_data)
		if ok then
			-- 打印插件加载信息
			print(plugin_db.get_debug_info(plugin_data.config))
		else
			PLUGIN_ERRORS[#PLUGIN_ERRORS + 1] = {
				entry = plugin_data.config.entry,
				error = err
			}
		end
	end

	if #PLUGIN_ERRORS > 0 then
		error(_("PLUGIN_UI_INIT_ERROR"))
	end
end

-- ─────────────────────────────────────────────
-- 热重载支持（插件管理器「应用」按钮）
--
-- 插件可选的三个接口（init 为必需，启动时调用）：
--   reload(plugin_data)        热加载：运行时插件由未启用→启用时调用，模块为全新加载实例
--   unload(plugin_data)        热卸载：运行时插件由启用→未启用时调用，应撤销 init 注册的一切
--   on_config_change(new_config) 配置热加载：插件配置修改并「应用」时调用，参数为新配置数据（已写盘）
-- 任一相关插件缺少对应接口时，插件管理器会回退到原来的「保存并重启」逻辑。
-- ─────────────────────────────────────────────

--- 运行时按 entry 查找已加载插件
---@param plugin_data table 插件记录（{config, has_plugin_config}）
---@return table|nil 已加载条目 {plugin, plugin_data}
function plugin_main:find_loaded(plugin_data)
	if not plugin_data or not plugin_data.config or not plugin_data.config.entry then
		return nil
	end
	local target = plugin_data.config.entry
	for i = 1, #self.loaded_plugins do
		local entry = self.loaded_plugins[i]
		if entry and entry[2] and entry[2].config.entry == target then
			return entry
		end
	end
	return nil
end

--- 判断插件当前是否已加载（运行时）
---@param plugin_data table 插件数据
---@return boolean
function plugin_main:is_loaded(plugin_data)
	return self:find_loaded(plugin_data) ~= nil
end

--- 加载（或取缓存）插件模块。热应用检查与执行共用同一缓存，
--- 避免检查阶段加载过的模块在执行阶段被再次执行（模块顶层代码只跑一次）。
---@param plugin_data table 插件数据
---@return table|nil 插件 hook 表
function plugin_main:_hot_module(plugin_data)
	if not self._hot_module_cache then
		self._hot_module_cache = {}
	end
	local cached = self._hot_module_cache[plugin_data.config.entry]
	if cached ~= nil then
		return cached
	end
	local plugin, err = load_plugin_module(plugin_data)
	if not plugin then
		log.error("Failed to hot-load plugin '%s': %s", plugin_data.config.entry, tostring(err))
		self._hot_module_cache[plugin_data.config.entry] = false
		return nil
	end
	self._hot_module_cache[plugin_data.config.entry] = plugin
	return plugin
end

--- 按优先级插入已加载列表（与启动时顺序一致：高优先级在前）
function plugin_main:_insert_loaded(plugin, plugin_data)
	local priority = plugin_data.config.priority
	local idx = #self.loaded_plugins + 1
	for i = 1, #self.loaded_plugins do
		if self.loaded_plugins[i][2].config.priority < priority then
			idx = i
			break
		end
	end
	table.insert(self.loaded_plugins, idx, {plugin, plugin_data})
end

--- 检查热应用可行性：计划中的每一项变更都具备对应接口才算可行。
---@param plan table {unloads={plugin_data}, reloads={plugin_data}, configs={{plugin_data=..., config=新配置}}}
---@return boolean ok 是否全部可热重载
---@return string|nil reason 不可行的原因汇总（ok 为 false 时返回）
function plugin_main:can_hot_apply(plan)
	self._hot_module_cache = {}
	plan = plan or {}
	local reasons = {}

	for _i, pd in ipairs(plan.unloads or {}) do
		local entry = self:find_loaded(pd)
		if entry and type(entry[1].unload) ~= "function" then
			reasons[#reasons + 1] = string.format(_("PLUGIN_UI_HOT_UNLOAD_UNSUPPORTED"), plugin_label(pd))
		end
	end

	for _i, pd in ipairs(plan.reloads or {}) do
		local plugin = self:_hot_module(pd)
		if not plugin then
			reasons[#reasons + 1] = string.format(_("PLUGIN_UI_HOT_RELOAD_LOAD_FAILED"), plugin_label(pd))
		elseif type(plugin.reload) ~= "function" then
			reasons[#reasons + 1] = string.format(_("PLUGIN_UI_HOT_RELOAD_UNSUPPORTED"), plugin_label(pd))
		end
	end

	for _i, item in ipairs(plan.configs or {}) do
		local pd = item.plugin_data
		local entry = self:find_loaded(pd)
		if entry and type(entry[1].on_config_change) ~= "function" then
			reasons[#reasons + 1] = string.format(_("PLUGIN_UI_HOT_CONFIG_UNSUPPORTED"), plugin_label(pd))
		end
	end

	if #reasons > 0 then
		return false, table.concat(reasons, _("PLUGIN_UI_REASON_SEPARATOR"))
	end
	return true, nil
end

--- 执行热应用：先卸载、再加载、最后配置热加载。
--- 单个插件回调出错不中断其余插件（错误汇总返回，由调用方提示）。
---@param plan table 同 can_hot_apply
---@return boolean ok 是否全部成功
---@return table errors 错误信息列表（ok 为 false 时非空）
function plugin_main:apply_hot(plan)
	plan = plan or {}
	local errors = {}

	local function sort_plugins(list, desc)
		table.sort(list, function(a, b)
			local pa = a.config.priority
			local pb = b.config.priority
			if desc then
				return pa > pb
			end
			return pa < pb
		end)
	end

	-- 1. 热卸载（高优先级先卸载，与启动初始化顺序相反）
	local unloads = plan.unloads or {}
	sort_plugins(unloads, true)
	for _i, pd in ipairs(unloads) do
		local entry = self:find_loaded(pd)
		if entry then
			local plugin = entry[1]
			if type(plugin.unload) == "function" then
				local ok, err = pcall(plugin.unload, plugin, pd)
				if not ok then
					errors[#errors + 1] = string.format(_("PLUGIN_UI_HOT_UNLOAD_FAILED"), plugin_label(pd), tostring(err))
					log.error("plugin unload failed: %s", tostring(err))
				end
			end
			for i = #self.loaded_plugins, 1, -1 do
				if self.loaded_plugins[i] == entry then
					table.remove(self.loaded_plugins, i)
					break
				end
			end
			self.registry[pd.config.entry] = nil
		end
	end

	-- 2. 热加载（低优先级先加载，与启动 init 顺序一致）
	local reloads = plan.reloads or {}
	sort_plugins(reloads, false)
	for _i, pd in ipairs(reloads) do
		local plugin = self:_hot_module(pd)
		if plugin then
			self:_insert_loaded(plugin, pd)
			self.registry[pd.config.entry] = pd.config
			if type(plugin.reload) == "function" then
				local ok, err = pcall(plugin.reload, plugin, pd)
				if not ok then
					errors[#errors + 1] = string.format(_("PLUGIN_UI_HOT_RELOAD_FAILED"), plugin_label(pd), tostring(err))
					log.error("plugin reload failed: %s", tostring(err))
				end
			end
		end
	end

	-- 3. 配置热加载（参数为新配置数据，同时已由插件管理器写盘）
	for _i, item in ipairs(plan.configs or {}) do
		local pd = item.plugin_data
		local new_config = item.config
		local entry = self:find_loaded(pd)
		if entry and type(entry[1].on_config_change) == "function" then
			local ok, err = pcall(entry[1].on_config_change, entry[1], new_config)
			if not ok then
				errors[#errors + 1] = string.format(_("PLUGIN_UI_HOT_CONFIG_FAILED"), plugin_label(pd), tostring(err))
				log.error("plugin on_config_change failed: %s", tostring(err))
			end
		end
	end

	self._hot_module_cache = {}
	return #errors == 0, errors
end

return plugin_main
