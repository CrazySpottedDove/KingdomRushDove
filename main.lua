-- chunkname: @./main.lua
local version = require("version")
require("all.constants")

if love.system.getOS() == "Windows" then
	local ffi = require("ffi")
	ffi.cdef[[
        typedef int BOOL;
        typedef unsigned long DWORD;
        BOOL SetConsoleOutputCP(DWORD wCodePageID);
        BOOL SetConsoleCP(DWORD wCodePageID);
    ]]
	ffi.C.SetConsoleOutputCP(65001)
	ffi.C.SetConsoleCP(65001)
end

love.filesystem.setIdentity(version.identity)
IS_ANDROID = love.system.getOS() == "Android"

--- 调用 love.filesystem 来加载文件，但是在 prefixs 中进行逐个尝试，返回最先找到的文件
---@param filename string
---@param prefixs table
---@return function|nil, string|nil
function love.filesystem.loadWithPreference(filename, prefixs)
	for i = 1, #prefixs do
		local prefix = prefixs[i]
		local candidates = {}

		if _G.CUSTOM_MAP_ROOT and prefix == KR_PATH_GAME then
			if type(_G.CUSTOM_MAP_ROOT) == "table" then
				for _, p in ipairs(_G.CUSTOM_MAP_ROOT) do
					candidates[#candidates + 1] = p
				end
			else
				candidates[#candidates + 1] = _G.CUSTOM_MAP_ROOT
			end
		end
		candidates[#candidates + 1] = prefix

		for _, base in ipairs(candidates) do
			local path = base .. "/" .. filename
			local info = love.filesystem.getInfo(path)
			if info and info.type == "file" then
				return love.filesystem.load(path)
			end
		end
	end
end

local perf = require("dove_modules.perf.perf")
local configer = require("dove_modules.configer")
perf.set_enabled(configer.ui_settings().perf_enabled)

love.graphics.setColor_old = function(r, g, b, a)
	if type(r) == "table" then
		-- 支持 table 形式
		if r[1] and r[1] > 1 then
			r[1] = r[1] / 255
		end

		if r[2] and r[2] > 1 then
			r[2] = r[2] / 255
		end

		if r[3] and r[3] > 1 then
			r[3] = r[3] / 255
		end

		if r[4] and r[4] > 1 then
			r[4] = r[4] / 255
		end
		love.graphics.setColor(r)
	else
		if r and r > 1 then
			r = r / 255
		end

		if g and g > 1 then
			g = g / 255
		end

		if b and b > 1 then
			b = b / 255
		end

		if a and a > 1 then
			a = a / 255
		end
		love.graphics.setColor(r, g, b, a)
	end
end

if arg[2] == "debug" then
	LLDEBUGGER = require("lldebugger")

	LLDEBUGGER.start()
end

local G = love.graphics

require("main_globals")

-- 规范化路径：把所有反斜杠替换为正斜杠
local function norm_path(p)
	return p and p:gsub("\\", "/") or p
end

local base_dir = norm_path(love.filesystem.getSourceBaseDirectory())

-- 统一定义所有搜索路径根目录
local search_roots = {
	"", -- 当前目录
	"lib",
	"all",
	string.format("all-%s", KR_TARGET),
	KR_GAME,
	string.format("%s-%s", KR_GAME, KR_TARGET),
	"_assets",
	string.format("_assets/all-%s", KR_TARGET),
	string.format("_assets/%s-%s", KR_GAME, KR_TARGET),
	"plugin",
	"plugin/all",
	"plugins"
}

-- 从 roots 生成 require 路径字符串
local function build_require_paths(roots)
	local paths = {"?.lua", "?/init.lua"}

	for _, root in ipairs(roots) do
		if root ~= "" then
			table.insert(paths, root .. "/?.lua")
			table.insert(paths, root .. "/?/init.lua")
		end
	end

	return table.concat(paths, ";")
end

local require_paths = build_require_paths(search_roots)

-- 注册自定义 searcher
do
	local lfs = love.filesystem
	local searchers = package.searchers or package.loaders

	table.insert(searchers, 1, function(module_name)
		local name = norm_path(module_name:gsub("%.", "/"))

		-- 遍历所有根目录
		for _, root in ipairs(search_roots) do
			local base = (root == "" and "" or (root .. "/"))

			-- 尝试 .lua 和 /init.lua
			for _, pattern in ipairs({".lua", "/init.lua"}) do
				local path = norm_path(base .. name .. pattern)
				local info = lfs.getInfo(path)

				if info and info.type == "file" then
					local chunk, err = lfs.load(path)
					if chunk then
						return chunk
					end
					return nil, err
				end
			end
		end

		return nil
	end)

	-- 设置 love.filesystem 的搜索路径
	if lfs.setRequirePath then
		lfs.setRequirePath(require_paths)
	end
end

-- 定义全局路径常量
KR_FULLPATH_BASE = norm_path(base_dir .. "/src")
KR_PATH_ROOT = ""
KR_PATH_ALL = "all"
KR_PATH_ALL_TARGET = string.format("all-%s", KR_TARGET)
KR_PATH_GAME = KR_GAME
EDITOR_PATH = "game_editor"
KR_PATH_GAME_TARGET = string.format("%s-%s", KR_GAME, KR_TARGET)
KR_PATH_ASSETS_ROOT = "_assets"
KR_PATH_ASSETS_ALL_TARGET = string.format("_assets/all-%s", KR_TARGET)
KR_PATH_ASSETS_GAME_TARGET = string.format("_assets/%s-%s", KR_GAME, KR_TARGET)

local log = require("lib.klua.log")

require("lib.klua.table")
require("lib.klua.dump")

-- 伤害调试等开关：love . --damage-trace …（与 constants.lua 中 DEBUG_* 对应）
for i = 1, #arg do
	local a = arg[i]

	if a == "--damage-trace" then
		DEBUG_DAMAGE_TRACE = true
	elseif a == "--damage-trace-enemy-hits" then
		DEBUG_DAMAGE_TRACE = true
		DEBUG_DAMAGE_TRACE_ALL_ENEMY_HITS = true
	elseif a == "--damage-trace-all-targets" then
		DEBUG_DAMAGE_TRACE = true
		DEBUG_DAMAGE_TRACE_ALL_TARGETS = true
	elseif a == "--damage-trace-tower" then
		DEBUG_DAMAGE_TRACE = true
		DEBUG_DAMAGE_TRACE_TOWER_ATTACKS = true
	elseif a == "--damage-investigate" then
		DEBUG_DAMAGE_TRACE_INVESTIGATE = true
	end
end

if arg[2] == "assets" then
	ASSETS_CHECK_ENABLED = true
end

if arg[2] == "waves" then
	GEN_WAVES_ENABLED = true
end

if version.build == "RELEASE" then
	DEBUG = nil
	log:set_level("error")
else
	DEBUG = true
	log:set_level("info")
end

log.use_print = false
log = log:new("main")

local storage = require("all.storage")
local F = require("lib.klove.font_db")

F:init("_assets/all-desktop/fonts")
F:load()

local MU = require("main_utils")
local i18n = require("i18n")

main = {}
main.handler = nil
main.log_output = nil

function main:set_locale(locale)
	i18n.load_locale(locale)

	if DEBUG then
		package.loaded["data.font_subst"] = nil
	end

	local fs = require("data.font_subst")

	for _, v in pairs(fs.global) do
		F:set_font_subst(unpack(v))
	end

	local locale_subst = fs[locale] or fs.default

	for _, v in pairs(locale_subst) do
		F:set_font_subst(unpack(v))
	end
end

local function close_log()
	if main.log_output then
		log.error("<< closing >>")
		io.stderr:write("Closing log file\n")
		io.flush()
		main.log_output:close()
		io.stderr:write("Bye\n")
	end
end

local loader

local function load_director()
	local director = require("director")
	main.handler = director
	require("plugin.plugin_main"):init(director)
end

local function load_update_manager()
	local update_manager = require("dove_modules.updater.update_manager")
	main.handler = update_manager
	update_manager:init(main.params, function()
		loader:load_next()
	end)
end

local function load_must_read()
	local must_read = require("dove_modules.notice.must_read")
	main.handler = must_read
	must_read:init(main.params, function()
		storage:write_lua("must_read.lua", {
			read = true
		})
		loader:load_next()
	end)
end

local function load_app_settings()
	local settings = require("screen_settings")

	local w, h = G.getDimensions()

	local function done_cb()
		storage:save_settings(main.params)
		MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
		if not main.params.update_enabled then
			table.removeobject(loader.items, "update_manager")
		end
		loader:load_next()
	end

	settings:init(w, h, main.params, done_cb)

	main.handler = settings
end

loader = {
	items = {"settings", "must_read", "update_manager", "director"},
	methods = {
		settings = load_app_settings,
		must_read = load_must_read,
		update_manager = load_update_manager,
		director = load_director
	}
}

function loader:load()
	if main.params.tmp_restart then
		MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
		self.items = {"director"}
	else
		local launch_options = main.params.launch_options
		if launch_options.skip_must_read then
			table.removeobject(self.items, "must_read")
		end
		-- 安卓端禁用设置界面，因为也没啥自由度，而且画出来老是有问题
		if launch_options.skip_settings or IS_ANDROID then
			table.removeobject(self.items, "settings")
			MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
		end
	end

	self:load_next()
end

function loader:load_next()
	local next_item = table.remove(self.items, 1)
	if next_item then
		self.methods[next_item]()
	end
end

local function load(arg)
	local w, h = love.window.getDesktopDimensions()

	-- 安卓端强制全屏游戏
	if IS_ANDROID then
		love.window.setMode(w, h, {
			centered = false,
			vsync = false,
			fullscreen = true
		})
	else
		love.window.setMode(w, h, {
			centered = false,
			vsync = false
		})
	end

	-- 默认关闭系统文本输入（IME），避免非英文输入法拦截游戏快捷键
	-- 需要输入文本时由 KWindow:set_responder 临时开启，输入结束自动恢复关闭
	love.keyboard.setTextInput(false)

	if love.filesystem.isFused() and not love.filesystem.getInfo(KR_PATH_ALL_TARGET) then
		log.info("")
		log.info("mounting asset files...")
		log.debug("mounting base_dir")

		if not love.filesystem.mount(base_dir, "/", true) then
			log.error("error mounting assets base_dir: %s", base_dir)

			return
		end

		for _, n in pairs({KR_PATH_ALL_TARGET, KR_PATH_GAME_TARGET}) do
			local fn = string.format("%s.dat", n)
			local dn = string.format("%s", n)

			log.debug("mounting %s -> %s", fn, dn)

			if not love.filesystem.mount(fn, dn, true) then
				log.error("error mounting assets file: %s", fn)

				return
			end
		end
	end

	-- 首先，要把已持久化的设置加载到 main.params 中。
	main.params = storage:load_settings()

	MU.basic_init()

	-- 这里要检查 args 是否存在，不存在就不load了
	local success, loaded_args = pcall(require, "args")
	if success and loaded_args then
		arg = table.append(arg, loaded_args, true)
	end

	if DEBUG then
		require("debug_tools")
	end

	MU.parse_args(arg, main.params)
	MU.default_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)

	if main.params.log_level then
		log:set_level(main.params.log_level)
	end

	main.log_output = MU.redirect_output(main.params)

	if main.log_output then
		log.error(MU.get_version_info(version))
		log.error(MU.get_graphics_features())
	end

	MU.start_debugger(main.params)

	main:set_locale(main.params.locale)
	love.window.setTitle(version.title .. version.id)

	-- icon switched to krdove
	love.window.setIcon(love.image.newImageData(KR_PATH_ASSETS_GAME_TARGET .. "/icons/krdove.png"))

	loader:load()
end

function love.update(dt)
	return main.handler:update(dt)
end

function love.draw()
	main.handler:draw()
end

function love.keypressed(key, scancode, isrepeat)
	if LLDEBUGGER and key == "0" then
		LLDEBUGGER.start()
	end

	main.handler:keypressed(key, isrepeat)
end

function love.keyreleased(key, scancode)
	main.handler:keyreleased(key)
end

function love.textinput(t)
	if main.handler.textinput then
		main.handler:textinput(t)
	end
end

function love.mousepressed(x, y, button, istouch)
	main.handler:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	main.handler:mousereleased(x, y, button, istouch)
end

function love.wheelmoved(dx, dy)
	if main.handler.wheelmoved then
		main.handler:wheelmoved(dx, dy)
	end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	if main.handler.touchpressed then
		main.handler:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	if main.handler.touchreleased then
		main.handler:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	if main.handler.touchmoved then
		main.handler:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function love.resize(w, h)
	if main.handler.resize then
		main.handler:resize(w, h)
	end
end

local perf_ui = require("dove_modules.perf.perf_ui")

if IS_ANDROID then
	local S = require("sound_db")

	function love.focus(focus)
		if main.handler.focus then
			main.handler:focus(focus)
		end
		if not focus then
			main.backgrounded = true
			if not main.audio_paused_by_background then
				S:pause()
				main.audio_paused_by_background = true
			end
		else
			main.backgrounded = false
			if main.audio_paused_by_background then
				S:resume()
				main.audio_paused_by_background = false
			end
		end
	end

	if not love.filesystem.getInfo(".nomedia") then
		love.filesystem.write(".nomedia", "")
	end

	function love.run()
		love.math.setRandomSeed(os.time())

		load(arg)

		love.timer.step()

		local dt = 0
		local updated = false

		return function()
			love.event.pump()

			for name, a, b, c, d, e, f in love.event.poll() do
				if name == "quit" then
					close_log()
					return a or 0
				end

				love.handlers[name](a, b, c, d, e, f)
			end

			if main.backgrounded then
				love.timer.step()
				collectgarbage("step")
				love.timer.sleep(0.1)
			else
				dt = love.timer.step()
				updated = love.update(dt)

				G.clear()
				G.origin()

				-- perf.start("draw")
				love.draw()
				-- perf.stop("draw")
				if updated then
					perf_ui.sync_data()
					perf.reset()
				end
				perf_ui.draw()

				G.present()

				if main.handler.limit_fps then
					main.handler:limit_fps()
				else
					collectgarbage("step")
					love.timer.sleep(0.001)
				end
			end
		end
	end
else
	function love.focus(focus)
		if main.handler.focus then
			main.handler:focus(focus)
		end
	end

	function love.run()
		love.math.setRandomSeed(os.time())

		load(arg)

		love.timer.step()

		local dt = 0
		local updated = false

		return function()
			love.event.pump()

			for name, a, b, c, d, e, f in love.event.poll() do
				if name == "quit" then
					close_log()
					return a or 0
				end

				love.handlers[name](a, b, c, d, e, f)
			end

			dt = love.timer.step()
			updated = love.update(dt)

			G.clear()
			G.origin()

			-- perf.start("draw")
			love.draw()
			-- perf.stop("draw")
			if updated then
				perf_ui.sync_data()
				perf.reset()
			end
			perf_ui.draw()

			G.present()

			if main.handler.limit_fps then
				main.handler:limit_fps()
			else
				collectgarbage("step")
				love.timer.sleep(0.001)
			end
		end
	end
end

-- 从 traceback 文本中归因出导致错误的插件。
-- 规则：逐行（从最内层向外）扫描；
--   若先遇到某个插件 entry 对应的帧再遇到 hook_utils.lua 帧，说明错误发生在插件自身代码中；
--   若先遇到 hook_utils.lua 帧，说明错误发生在被插件钩子通过 next() 调用的原始函数中，不归因插件。
local function escape_lua_pattern(s)
	return (tostring(s):gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function find_plugin_dir_by_entry_in_line(line)
	if type(line) ~= "string" or type(PLUGIN_REGISTRY) ~= "table" then
		return nil
	end

	local padded_line = " " .. line .. " "

	for plugin_dir, config in pairs(PLUGIN_REGISTRY) do
		local entry = (type(config) == "table" and config.entry) or plugin_dir
		if type(entry) == "string" and entry ~= "" then
			local escaped_entry = escape_lua_pattern(entry)
			local token_pattern = "[^%w_]" .. escaped_entry .. "[^%w_]"
			if padded_line:match(token_pattern) then
				return plugin_dir
			end
		end
	end

	return nil
end

local function find_plugin_from_traceback(traceback)
	if not traceback then
		return nil
	end

	local first_plugin_dir = nil
	local first_hookutils_idx = nil
	local idx = 0

	for line in traceback:gmatch("[^\n]+") do
		idx = idx + 1

		if first_plugin_dir == nil then
			local dir = find_plugin_dir_by_entry_in_line(line)

			if dir then
				first_plugin_dir = dir
			end
		end

		if first_hookutils_idx == nil and line:match("hook_utils%.lua") then
			first_hookutils_idx = idx
		end

		if first_plugin_dir and first_hookutils_idx then
			break
		end
	end

	if not first_plugin_dir then
		return nil
	end

	-- local config = PLUGIN_REGISTRY and PLUGIN_REGISTRY[first_plugin_dir]
	-- if config then
	-- 	return string.format("%s:%s (%s)", config.name or first_plugin_dir, config.version, config.entry or first_plugin_dir)
	-- end

	return first_plugin_dir
end

local function auto_disable_crashing_plugin(plugin_dir)
	local cfg_path = "plugins/" .. plugin_dir .. "/config.lua"
	if not love.filesystem.getInfo(cfg_path, "file") then
		log.error("auto_disable_crashing_plugin: config file not found for %s", cfg_path)
		return false
	end

	local chunk, err = love.filesystem.load(cfg_path)
	if not chunk then
		log.error("auto_disable_crashing_plugin: load failed for %s: %s", cfg_path, tostring(err))
		return false
	end

	local ok, cfg = pcall(chunk)
	if not ok or type(cfg) ~= "table" then
		log.error("auto_disable_crashing_plugin: invalid config for %s", cfg_path)
		return false
	end

	if cfg.enabled == false then
		return true
	end

	cfg.enabled = false
	local persistence = require("lib.klua.persistence")
	local written = love.filesystem.write(cfg_path, persistence.serialize_to_string(cfg))
	if not written then
		log.error("auto_disable_crashing_plugin: write failed for %s", cfg_path)
		return false
	end

	return true
end

local function disabled_all_plugins()
	-- 只要把插件管理器的总开关关闭即可
	local cfg_path = "plugins/plugin_main_config.lua"
	if not love.filesystem.getInfo(cfg_path, "file") then
		return false
	end
	local chunk = love.filesystem.load(cfg_path)
	local _, cfg = pcall(chunk)
	if cfg.enabled == true then
		cfg.enabled = false
		storage:write_lua(cfg_path, cfg)
		return true
	end
	return false
end

-- 构建当前已启用（已加载或正在加载）的插件列表（名称 + 版本）文本。
-- 数据源仅 PLUGIN_REGISTRY，没有则输出 "(无)"。
local function build_enabled_plugins_text()
	local lines = {"===== 已启用插件列表 (name : version) ====="}

	local listed = 0

	if type(PLUGIN_REGISTRY) == "table" then
		for plugin_dir, config in pairs(PLUGIN_REGISTRY) do
			lines[#lines + 1] = string.format("  %s(%s) : %s", config.name, config.entry, config.version or "?")
			listed = listed + 1
		end
	end

	lines[#lines + 1] = "===== 已启用插件总数: " .. listed .. " ====="

	return table.concat(lines, "\n")
end

local function strip_noise_from_trace(trace_string)
	-- 使用纯文本子串匹配（避免把 "." 当成通配符）
	local skip_substrings = {"boot.lua", "[C]:", "in main chunk"}

	local trace_lines = {}
	-- 按行分割（保留末尾空行不影响拼接）
	for l in string.gmatch(trace_string, "(.-)\n") do
		local should_skip = false
		for _, substr in ipairs(skip_substrings) do
			-- 第三个参数 true 表示纯文本查找，不使用模式匹配
			if string.find(l, substr, 1, true) then
				should_skip = true
				break
			end
		end
		if not should_skip then
			table.insert(trace_lines, l)
		end
	end

	return table.concat(trace_lines, "\n")
end

function love.errorhandler(msg)
	local last_log_msg = log.last_log_msgs and table.concat(log.last_log_msgs, "")
	local trace = strip_noise_from_trace(debug.traceback())

	local blamed_plugins
	if PLUGIN_ERRORS and #PLUGIN_ERRORS > 0 then
		blamed_plugins = PLUGIN_ERRORS
	else
		local blamed_plugin = find_plugin_from_traceback(trace .. "\n" .. msg)
		if blamed_plugin then
			blamed_plugins = {{
				entry = blamed_plugin,
				error = ""
			}}
		end
	end

	local plugins_text = build_enabled_plugins_text()

	close_log()

	love.mouse.setVisible(true)
	love.mouse.setGrabbed(false)
	love.mouse.setRelativeMode(false)

	if love.mouse.isCursorSupported() then
		love.mouse.setCursor()
	end

	love.audio.stop()

	G.reset()

	-- 崩溃前的画面仍保留在默认帧缓冲中：直接在其上合成报错界面，不使用 canvas。
	-- （安卓端 canvas 尺寸与默认帧缓冲不一致会导致只渲染出左上角一块、文字异常大的问题）
	-- 字号按参考高度缩放（与游戏内一致），不使用 toPixels（安卓端物理/逻辑像素混用会放大文字）
	local ref_h = REF_H or 768
	local scale = math.max(1, G.getHeight() / ref_h)
	local font = G.setNewFont("_assets/all-desktop/fonts/msyh.ttc", math.floor(15 * scale))
	local cn_font = G.setNewFont("_assets/all-desktop/fonts/msyh.ttc", math.floor(16 * scale))

	-- 半透明黑色遮罩：默认背景为 0.5 透明度的崩溃前画面
	G.setColor(0, 0, 0, 0.5)
	G.rectangle("fill", 0, 0, G.getWidth(), G.getHeight())

	local tip = {}
	local err = {}

	table.insert(tip, string.format("Version %s", version.id))
	table.insert(tip, "666，程序爆炸了！如果您不想被吐槽看不懂中文的话，请首先确定版本是否为最新。如果不是最新，不要反馈，不要找作者。如果版本为最新，再完整截下本界面，反馈并用语言详细说明发生了什么。")

	table.insert(err, msg .. "\n")

	-- 归因：检查错误是否由某个插件导致（stack_msg 包含完整 traceback）

	if blamed_plugins then
		table.insert(tip, string.format("插件导致崩溃："))
		for _, plugin_error_info in ipairs(blamed_plugins) do
			local plugin_tip
			if PLUGIN_REGISTRY and PLUGIN_REGISTRY[plugin_error_info.entry] then
				local config = PLUGIN_REGISTRY[plugin_error_info.entry]
				plugin_tip = string.format("    %s(%s:%s)", config.name, config.entry, config.version or "?")
			else
				plugin_tip = string.format("    %s", plugin_error_info.entry)
			end
			local disabled_ok = auto_disable_crashing_plugin(plugin_error_info.entry)
			if disabled_ok then
				plugin_tip = plugin_tip .. "(已自动禁用)"
			end
			table.insert(tip, plugin_tip)
			if plugin_error_info.error ~= "" then
				table.insert(err, string.format("[%s]\n%s\n", plugin_error_info.entry, plugin_error_info.error))
			end
		end
	end

	-- 某个没被定位的插件导致了游戏进都进不去，采用保守措施，把所有插件全都禁用
	if not blamed_plugins and not main.screen_map_entered then
		if disabled_all_plugins() then
			table.insert(tip, "检测到未知插件导致崩溃，已自动禁用所有插件。\n重启游戏后将跳过所有插件。")
		end
	end

	local tip_text = table.concat(tip, "\n")

	tip_text = string.gsub(tip_text, "\t", "")
	tip_text = string.gsub(tip_text, "%[string \"(.-)\"%]", "%1")

	local err_text = table.concat(err, "\n")

	err_text = string.gsub(err_text, "\t", "")
	err_text = string.gsub(err_text, "%[string \"(.-)\"%]", "%1")

	-- 分区渲染：不同类型的信息使用不同颜色（更醒目）
	local margin = math.floor(28 * scale)
	local wrap_w = G.getWidth() - margin * 2

	local function text_height(f, text, wrap)
		-- LÖVE 11 的 Font:getWrap(text, wrap) 返回 (最大行宽 number, 行表 table)
		local _, lines = f:getWrap(text, wrap)
		return (type(lines) == "table" and #lines or 1) * f:getHeight()
	end

	local sections = {}
	-- 版本与插件归因/自动禁用提示：亮黄
	sections[#sections + 1] = {
		text = tip_text,
		color = {1, 0.82, 0.35, 1},
		font = cn_font
	}
	-- 错误消息：红
	sections[#sections + 1] = {
		text = err_text,
		color = {1, 0.45, 0.45, 1},
		font = cn_font
	}
	-- 堆栈：浅灰
	sections[#sections + 1] = {
		text = trace,
		color = {0.8, 0.8, 0.88, 1},
		font = font
	}
	-- 最近日志：橙
	if last_log_msg and last_log_msg ~= "" then
		sections[#sections + 1] = {
			text = "报错日志记录\n" .. last_log_msg,
			color = {1, 0.62, 0.32, 1},
			font = font
		}
	end
	-- 已启用插件列表：天蓝
	sections[#sections + 1] = {
		text = plugins_text,
		color = {0.45, 0.85, 1, 1},
		font = font
	}
	-- 操作提示：亮绿
	sections[#sections + 1] = {
		text = "按ESC以退出。",
		color = {0.62, 1, 0.62, 1},
		font = cn_font
	}

	local sum_up = ""
	local y = margin
	for _, sec in ipairs(sections) do
		G.setFont(sec.font)
		G.setColor(sec.color[1], sec.color[2], sec.color[3], sec.color[4])
		G.printf(sec.text, margin, y, wrap_w)
		y = y + text_height(sec.font, sec.text, wrap_w) + math.floor(5 * scale)
		sum_up = sum_up .. sec.text .. "\n"
	end
	G.present()

	if LLDEBUGGER then
		LLDEBUGGER.start()
	end

	print(sum_up)

	return function()
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" then
				if a == "escape" then
					return 1
				end
			elseif e == "touchpressed" then
				local name = love.window.getTitle()

				if #name == 0 or name == "Untitled" then
					name = "Game"
				end

				local buttons = {"关闭并复制报错信息"}
				local pressed = love.window.showMessageBox("关闭" .. name .. "?", "", buttons)

				if pressed == 1 then
					love.system.setClipboardText(sum_up)
					return 1
				end
			end
		end
		love.timer.sleep(0.1)
	end
end
