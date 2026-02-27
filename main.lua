-- chunkname: @./main.lua
local version = require("version")
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

local base_dir = love.filesystem.getSourceBaseDirectory()
local work_dir = love.filesystem.getWorkingDirectory()

-- 规范化路径：把所有反斜杠替换为正斜杠，并可选保证目录以 / 结尾
local function norm_path(p, ensure_trail)
	if not p then
		return p
	end

	p = p:gsub("\\", "/")

	if ensure_trail and p:sub(-1) ~= "/" then
		p = p .. "/"
	end

	return p
end

base_dir = norm_path(base_dir, true)
work_dir = norm_path(work_dir, true)

local ppref

if love.filesystem.isFused() then
	ppref = ""
else
	ppref = base_dir ~= work_dir and "" or "src/"
end

ppref = norm_path(ppref, true)

local apref = norm_path(ppref .. "_assets/", true)
local rel_ppref = ""
local rel_apref = "_assets/"
local jpref = "joint_apk"

-- 统一构造 additional_paths 并全部规范化为 "/"
local additional_paths = {string.format("%s?.lua", ppref), string.format("%s%s-%s/?.lua", ppref, KR_GAME, KR_TARGET), string.format("%s%s/?.lua", ppref, KR_GAME), string.format("%sall-%s/?.lua", ppref, KR_TARGET), string.format("%sall/?.lua", ppref), string.format("%slib/?.lua", ppref), string.format("%slib/?/init.lua", ppref), string.format("%s%s-%s/?.lua", apref, KR_GAME, KR_TARGET), string.format("%sall-%s/?.lua", apref, KR_TARGET)}

for i, p in ipairs(additional_paths) do
	additional_paths[i] = norm_path(p)
end

local require_paths = "?.lua;?/init.lua;" .. table.concat(additional_paths, ";")

require_paths = norm_path(require_paths)

-- 在 ppref/apref 准备好后，注册基于 love.filesystem 的优先 searcher（保证使用 "/"）
do
	if love and love.filesystem then
		local lfs = love.filesystem
		local searchers = package.searchers or package.loaders

		local function lnorm(p)
			return p and p:gsub("\\", "/") or p
		end

		-- 构造要尝试的根（优先包含 ppref/apref 相关）
		local roots = { -- module itself
			"",
			ppref:gsub("/$", ""), -- ppref
			apref:gsub("/$", ""), -- apref
			"src",
			"lib",
			"all",
			"_assets",
			"kr1",
			"kr1-desktop",
			"_assets/kr1-desktop",
			"all-desktop",
			"mods",
			"mods/all"
		}
		-- 去重并规范
		local seen = {}
		local real_roots = {}

		for _, r in ipairs(roots) do
			r = lnorm(r or "")
			r = (r:sub(-1) == "/") and r:sub(1, -2) or r

			if not seen[r] then
				seen[r] = true

				table.insert(real_roots, r)
			end
		end

		table.insert(searchers, 1, function(module_name)
			local name = lnorm((module_name or ""):gsub("%.", "/"))
			-- 尝试候选路径（均用 "/"）
			local candidates = {}

			for _, root in ipairs(real_roots) do
				local base = (root == "" and "" or (root .. "/"))

				table.insert(candidates, base .. name .. ".lua")
				table.insert(candidates, base .. name .. "/init.lua")
			end

			-- 也尝试 KR_PATH_* 运行时可能包含的目标目录
			if KR_PATH_ALL_TARGET then
				table.insert(candidates, lnorm(KR_PATH_ALL_TARGET .. "/" .. name .. ".lua"))
				table.insert(candidates, lnorm(KR_PATH_ALL_TARGET .. "/" .. name .. "/init.lua"))
			end

			if KR_PATH_GAME_TARGET then
				table.insert(candidates, lnorm(KR_PATH_GAME_TARGET .. "/" .. name .. ".lua"))
				table.insert(candidates, lnorm(KR_PATH_GAME_TARGET .. "/" .. name .. "/init.lua"))
			end

			for _, p in ipairs(candidates) do
				p = lnorm(p)

				local info = lfs.getInfo and lfs.getInfo(p)

				if info and info.type == "file" then
					local chunk, err = lfs.load(p)

					if chunk then
						return chunk
					end

					return nil, err
				end
			end

			return nil
		end)

		if lfs.setRequirePath then
			lfs.setRequirePath(require_paths)
		end
	end
end

KR_FULLPATH_BASE = norm_path(base_dir .. "/src", true)
KR_PATH_ROOT = norm_path(tostring(rel_ppref))
KR_PATH_ALL = norm_path(string.format("%s%s", rel_ppref, "all"))
KR_PATH_ALL_TARGET = norm_path(string.format("%s%s-%s", rel_ppref, "all", KR_TARGET))
KR_PATH_GAME = norm_path(string.format("%s%s", rel_ppref, KR_GAME))
KR_PATH_GAME_TARGET = norm_path(string.format("%s%s-%s", rel_ppref, KR_GAME, KR_TARGET))
KR_PATH_ASSETS_ROOT = norm_path(string.format("%s", rel_apref))
KR_PATH_ASSETS_ALL_TARGET = norm_path(string.format("%s%s-%s", rel_apref, "all", KR_TARGET))
KR_PATH_ASSETS_GAME_TARGET = norm_path(string.format("%s%s-%s", rel_apref, KR_GAME, KR_TARGET))

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

log.use_print = KR_PLATFORM == "android"
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

	require("mods.mod_main"):init(director)
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
	local params = main.params
	if not params.update_enabled then
		table.removeobject(self.items, "update_manager")
	end
	local launch_options = params.launch_options
	if launch_options.skip_must_read then
		table.removeobject(self.items, "must_read")
	end
	if launch_options.skip_settings then
		table.removeobject(self.items, "settings")
		MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
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

	-- load_app_settings()
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

	while true do
		love.event.pump()

		for e, a, b, c, d in love.event.poll() do
			if e == "quit" then
				close_log()
				return
			end

			love.handlers[e](a, b, c, d)
		end

		love.timer.step()

		dt = love.timer.getDelta()

		updated = love.update(dt)

		if love.window.isOpen() and G.isActive() then
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
		else
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

	if not love.window or not G or not love.event then
		return
	end

	if not G.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)

		if not success or not status then
			return
		end
	end

	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)

		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end

	if love.audio then
		love.audio.stop()
	end

	G.reset()

	local font = G.setNewFont(math.floor(love.window.toPixels(15)))
	local cn_font = G.setNewFont("_assets/all-desktop/fonts/msyh.ttc", math.floor(love.window.toPixels(16)))

	G.setBackgroundColor(0.349, 0.616, 0.863)
	G.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	G.origin()

	local err = {}
	local tip = {}
	local tip_trigger_errors = {
		["Texture expected, got nil"] = "你在老本体上放了新版本补丁，请先安装新的本体。\n"
	}
	local has_tip

	table.insert(tip, string.format("Version %s: Tip\n", version.id))

	for e, v in pairs(tip_trigger_errors) do
		if string.find(msg, e, 1, true) then
			table.insert(tip, "提示: " .. v)

			has_tip = true
		end
	end

	if has_tip then
		table.insert(err, "\n\n\n\n\n\n\nError\n")
	else
		table.insert(err, "\n\n\n\n\nError\n")
	end

	local error_type = "common"

	if string.find(msg, "Error running coro", 1, true) then
		msg = msg:gsub("^[^:]+:%d+: ", "")

		local l = string.gsub(msg, "stack traceback:", "\n\n\nTraceback\n")

		table.insert(err, l)

		for l in string.gmatch(trace, "(.-)\n") do
			if not string.match(l, "boot.lua") then
				l = string.gsub(l, "stack traceback:", "")

				table.insert(err, l)
			end
		end

		error_type = "coro"
	else
		table.insert(err, msg .. "\n\n")

		for l in string.gmatch(trace, "(.-)\n") do
			if not string.match(l, "boot.lua") then
				l = string.gsub(l, "stack traceback:", "Traceback\n")

				table.insert(err, l)
			end
		end
	end

	-- if error_type == "coro" then
	-- 	table.insert(tip, "oops, 发生协程错误! 请将本界面与此前界面截图并反馈，而不是仅语言描述，按 “z” 显示此前界面，由于是协程错误不影响游戏可按 “Esc” 关闭本界面\n")
	if has_tip then
		table.insert(tip, "666，程序爆炸了! 如果您不想被吐槽看不懂中文的话，请先按照提示说的做。还是搞不定，再将本界面与此前界面截图并反馈，而不是仅语言描述。\n")
	elseif not has_tip then
		table.insert(tip, "666，程序爆炸了！如果您不想被吐槽看不懂中文的话，请首先确定版本是否为最新。如果不是最新，不要反馈，不要找作者。如果版本为最新，再完整截下蓝屏的图，截图反馈并用语言简要说明发生了什么。按b以查看蓝屏前图片，按ESC以退出\n")
	end

	if love.nx then
		table.insert(err, "\n\nFree memory:" .. love.nx.allocGetTotalFreeSize() .. "\n")
	end

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

	local function draw()
		if show_last then
			G.present()
		else
			G.draw(error_canvas, 0, 0)
		end
	end

	local quiterr

	if LLDEBUGGER then
		LLDEBUGGER.start()
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				quiterr = true

				love.event.quit()

				return
			elseif e == "keypressed" then
				if a == "escape" then
					return
				elseif a == "b" then
					show_last = not show_last
				end
			elseif e == "touchpressed" then
				local name = love.window.getTitle()

				if #name == 0 or name == "Untitled" then
					name = "Game"
				end

				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)

				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(2)
		end
	end
end
