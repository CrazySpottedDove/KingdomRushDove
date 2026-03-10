-- chunkname: @./main.lua
local version = require("version")

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
local is_android = love.system.getOS() == "Android"
local perf = require("dove_modules.perf.perf")
do
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
	"src",
	"lib",
	"all",
	string.format("all-%s", KR_TARGET),
	KR_GAME,
	string.format("%s-%s", KR_GAME, KR_TARGET),
	"_assets",
	string.format("_assets/all-%s", KR_TARGET),
	string.format("_assets/%s-%s", KR_GAME, KR_TARGET),
	"mods",
	"mods/all",
	"mods/local"
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
KR_PATH_GAME_TARGET = string.format("%s-%s", KR_GAME, KR_TARGET)
KR_PATH_ASSETS_ROOT = "_assets"
KR_PATH_ASSETS_ALL_TARGET = string.format("_assets/all-%s", KR_TARGET)
KR_PATH_ASSETS_GAME_TARGET = string.format("_assets/%s-%s", KR_GAME, KR_TARGET)

local log = require("lib.klua.log")

require("lib.klua.table")
require("lib.klua.dump")
require("all.constants")

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
	if is_android then
		director:init(main.params)
	else
		require("mods.mod_main"):init(director)
	end
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

	local w, h = love.window.getDesktopDimensions()

	love.window.setMode(w, h, {
		centered = false,
		vsync = false
	})

	local aw, ah = G.getDimensions()

	-- 安卓端尺寸适配
	if aw and ah and (aw ~= w or ah ~= h) then
		w, h = aw, ah
	end

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
		if launch_options.skip_settings then
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

	if DEBUG then
		arg = table.append(arg, require("args"), true)
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

	local font_paths = KR_PATH_ASSETS_ALL_FALLBACK or {{
		path = KR_PATH_ASSETS_ALL_TARGET
	}}

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

function love.focus(focus)
	if main.handler.focus then
		main.handler:focus(focus)
	end
end

local perf_ui = require("dove_modules.perf.perf_ui")
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

		perf.start("draw")
		love.draw()
		perf.stop("draw")
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

local function get_error_stack(msg, layer)
	return (debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", ""))
end

function love.errorhandler(msg)
	local error_canvas = G.newCanvas(G.getWidth(), G.getHeight())
	local last_canvas = G.getCanvas()

	G.setCanvas(error_canvas)

	local last_log_msg = log.last_log_msgs and table.concat(log.last_log_msgs, "")

	msg = tostring(msg)

	local stack_msg = debug.traceback("Error: " .. tostring(msg), 3):gsub("\n[^\n]+$", "")

	stack_msg = (stack_msg or "") .. "\n" .. last_log_msg

	log.error(stack_msg)
	close_log()

	love.mouse.setVisible(true)
	love.mouse.setGrabbed(false)
	love.mouse.setRelativeMode(false)

	if love.mouse.isCursorSupported() then
		love.mouse.setCursor()
	end

	love.audio.stop()

	G.reset()

	local font = G.setNewFont(math.floor(love.window.toPixels(15)))
	local cn_font = G.setNewFont("_assets/all-desktop/fonts/msyh.ttc", math.floor(love.window.toPixels(16)))

	G.setBackgroundColor(0.349, 0.616, 0.863)
	G.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	G.origin()

	local err = {}
	local tip = {}

	table.insert(tip, string.format("Version %s\n", version.id))
	table.insert(err, "\n\n\n\n\nError\n")

	table.insert(err, msg .. "\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")

			table.insert(err, l)
		end
	end

	table.insert(tip, "666，程序爆炸了！如果您不想被吐槽看不懂中文的话，请首先确定版本是否为最新。如果不是最新，不要反馈，不要找作者。如果版本为最新，再完整截下蓝屏的图，截图反馈并用语言简要说明发生了什么。按b以查看蓝屏前图片，按ESC以退出。\n")

	table.insert(err, "\n\nLast error msgs\n")
	table.insert(err, last_log_msg)

	local pt = table.concat(tip, "\n")

	pt = string.gsub(pt, "\t", "")
	pt = string.gsub(pt, "%[string \"(.-)\"%]", "%1")

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local pos = love.window.toPixels(70)

	G.setFont(font)
	G.clear(G.getBackgroundColor())
	G.printf(p, pos, pos, G.getWidth() - pos)
	G.setFont(cn_font)
	G.printf(pt, pos, pos, G.getWidth() - pos)
	G.present()

	local show_last = true

	if LLDEBUGGER then
		LLDEBUGGER.start()
	end

	return function()
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" then
				if a == "escape" then
					return 1
				elseif a == "b" then
					-- show_last = not show_last
					G.present()
				end
			elseif e == "touchpressed" then
				local name = love.window.getTitle()

				if #name == 0 or name == "Untitled" then
					name = "Game"
				end

				local buttons = {"是", "否", "关闭并复制报错"}
				local pressed = love.window.showMessageBox("关闭" .. name .. "?", "", buttons)

				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					love.system.setClipboardText(pt .. p)
					return 1
				end
			end
		end
		love.timer.sleep(0.1)
	end
end
