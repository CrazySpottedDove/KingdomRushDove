-- chunkname: @./all/main_utils.lua
local log = require("lib.klua.log")

require("lib.klua.table")

local i18n = require("i18n")
local mu = {}

function mu.basic_init()
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 100)
	math.randomseed(os.time())
	love.keyboard.setKeyRepeat(true)
end

function mu.parse_args(arg, params)
	local function has_arg(key)
		return table.contains(arg, "-" .. key)
	end

	local function argv(key)
		return arg[table.keyforobject(arg, "-" .. key) + 1]
	end

	if has_arg("audio_mode") then
		params.audio_mode = argv("audio_mode")
	end

	if has_arg("fps") then
		params.fps = argv("fps")
	end

	if has_arg("fullscreen") then
		params.fullscreen = true
	end

	if has_arg("height") then
		params.height = tonumber(argv("height"))
	end

	if has_arg("large_pointer") then
		params.large_pointer = true
	end

	if has_arg("msaa") then
		params.msaa = argv("msaa")
	end

	if has_arg("nojit") then
		params.nojit = true
	end

	if has_arg("texture_size") then
		params.texture_size = argv("texture_size")
	end

	if has_arg("vsync") then
		params.vsync = true
	end

	if has_arg("width") then
		params.width = tonumber(argv("width"))
	end

	if has_arg("windowed") then
		params.fullscreen = false
	end

	if has_arg("highdpi") then
		params.highdpi = true
	end

	if has_arg("pause_on_switch") then
		params.pause_on_switch = true
	end

	if has_arg("custom") then
		params.custom = argv("custom")
	end

	if has_arg("debug") then
		params.debug = true
	end

	if has_arg("diff") then
		params.diff = argv("diff")
	end

	if has_arg("level") then
		params.level = argv("level")
	end

	if has_arg("locale") then
		params.locale = argv("locale")
	end

	if has_arg("log_file") then
		params.log_file = argv("log_file")
	end

	if has_arg("log_level") then
		params.log_level = argv("log_level")
	end

	if has_arg("mode") then
		params.mode = argv("mode")
	end

	if has_arg("repl") then
		params.repl = argv("repl")
	end

	if has_arg("screen") then
		params.screen = argv("screen")
	end

	if has_arg("wpos") then
		params.wpos = string.split(argv("wpos"), ",")
	end
end

function mu.default_params(params, game_name, game_target, game_platform)
	local function d(k, v, override)
		if params[k] == nil or override then
			params[k] = v
		end
	end

	local api_level, has_menu_key, device_locale
	local device_profile = DEVICE_PROFILE_LOW

	if game_platform == "ios" then
		local ffi = require("ffi")

		ffi.cdef(" const char* kr_get_current_locale(); ")
		ffi.cdef(" const char* kr_get_device_model(); ")

		local s = ffi.string(ffi.C.kr_get_current_locale())

		if s then
			local ll, ls, lc = string.match(s, "^(%a%a)-?(%a*)_?(%a?%a?)")

			device_locale = i18n:find_fallback_locale(ll, ls)
		end

		local device_model = ffi.string(ffi.C.kr_get_device_model())
		local m = {string.match(device_model, "(%a+)(%d+),")}

		if m then
			local iter = tonumber(m[2])

			if m[1] == "iPhone" then
				if iter == nil then
				-- block empty
				elseif iter >= 9 then
					device_profile = DEVICE_PROFILE_HIGH
				else
					device_profile = DEVICE_PROFILE_LOW
				end
			elseif m[1] ~= "iPad" or iter == nil then
			-- block empty
			elseif iter >= 5 then
				device_profile = DEVICE_PROFILE_HIGH
			else
				device_profile = DEVICE_PROFILE_LOW
			end
		end
	elseif game_platform == "nx" and love.nx then
		local s = love.nx.getDesiredLanguage()

		if s then
			local l1, l2 = unpack(string.split(s, "-"))

			device_locale = i18n:find_fallback_locale(l1, l2)
		end
	end

	d("width", 1024)
	d("height", 768)
	d("texture_size", "fullhd")
	d("fps", 60)
	d("msaa", 0)
	d("vsync", false)
	d("volume_music", 0.5)
	d("volume_fx", 1)
	d("highdpi", false)
	d("pause_on_switch", false)
	d("image_db_uses_canvas", false)

	if params.locale and not i18n.locale_names[params.locale] then
		log.error("Invalid locale %s in settings.lua. Falling back to default.", params.locale)

		params.locale = nil
	end

	d("locale", "zh-Hans") -- 默认中文
end

function mu.apply_params(params, game_name, game_target, game_platform)
	DRAW_FPS = tonumber(params.fps)
	TICK_LENGTH = 1 / DRAW_FPS
	SOUND_POOL_SIZE_FACTOR = params.sound_pool_size

	if params.level or params.screen then
		params.skip_settings_dialog = true
	end

	if params.nojit then
		jit.off()
		log.info("jit.status: %s", jit.status())
	end

	if params.fullscreen and game_platform ~= "ios" then
		params.highdpi = nil
	end
end

function mu.redirect_output(params)
	local out_f

	if params.log_file then
		local path = params.log_file

		if not path:match("^/.-") then
			path = love.filesystem.getSaveDirectory() .. "/" .. path
		end

		local f, err = io.open(path, "w")

		if f then
			io.stderr:write(string.format("redirecting log output to %s\n", path))
			io.output(f)

			out_f = f
		else
			log.error("Failed to open log file %s for writing. Error: %s", path, err)
		end
	end

	return out_f
end

function mu.start_debugger(params)
	if DEBUG then
		if params.debug then
			local m = require("mobdebug")

			m.coro()
			m.start()
		elseif params.repl then
			require("lib.klua.repl")

			local repl_port, repl_address

			if params.repl then
				repl_address, repl_port = unpack(string.split(params.repl, ":"))
			end

			repl_port = repl_port or 9000
			repl_address = repl_address or "127.0.0.1"

			repl_init(repl_port, repl_address)
		end
	end
end

function mu.get_version_info(v)
	local o = "\n"

	o = o .. string.format("-- VERSION INFO -- \n")
	o = o .. string.format("identity  : %s\n", v.identity)
	o = o .. string.format("title     : %s\n", v.title)
	o = o .. string.format("bundle_id : %s\n", v.bundle_id)
	o = o .. string.format("string    : %s\n", v.string)

	return o
end

function mu.get_graphics_features()
	local o = "\n"

	o = o .. string.format("-- GRAPHICS FEATURES -- \n")

	local gfeatures = love.graphics.getSupported()
	local limits = love.graphics.getSystemLimits()

	for k, v in pairs(gfeatures) do
		o = o .. string.format("%s: %s\n", k, v)
	end

	for k, v in pairs(limits) do
		o = o .. string.format("%s: %s\n", k, v)
	end

	local name, version, vendor, device = love.graphics.getRendererInfo()

	o = o .. string.format("name  : %s\n", name)
	o = o .. string.format("ver   : %s\n", version)
	o = o .. string.format("vendor: %s\n", vendor)
	o = o .. string.format("device: %s\n", device)

	return o
end

function mu.get_debug_info(params)
	local o = "\n"

	o = o .. string.format("-------------------------------------------------------\n")
	o = o .. string.format("------------------- DEBUG IS ON -----------------------\n")
	o = o .. string.format("-------------------------------------------------------\n")
	o = o .. string.format("KR_GAME-KR_TARGET KR_PLATFORM: %s-%s %s\n", KR_GAME, KR_TARGET, KR_PLATFORM)
	o = o .. string.format("--\n")
	o = o .. string.format("sourceBase  : %s\n", love.filesystem.getSourceBaseDirectory())
	o = o .. string.format("working     : %s\n", love.filesystem.getWorkingDirectory())
	o = o .. string.format("realDir(\"\") : %s\n", love.filesystem.getRealDirectory(""))
	o = o .. string.format("saveDir     : %s\n", love.filesystem.getSaveDirectory())
	o = o .. string.format("userDir     : %s\n", love.filesystem.getUserDirectory())
	o = o .. string.format("--\n")
	o = o .. string.format("require path: %s\n", love.filesystem.getRequirePath())
	o = o .. string.format("package.path: %s\n", package.path)
	o = o .. string.format("-------------------------------------------------------\n")
	o = o .. string.format("-- SCREEN SETTINGS \n")
	o = o .. string.format("FPS: %s  VSYNC: %s\n", DRAW_FPS, params.vsync)
	o = o .. string.format("screen: %s,%s pixel scale:%s\n", love.graphics.getWidth(), love.graphics.getHeight(), love.window.getDPIScale())
	o = o .. string.format("supported full screen modes for display 1:\n")

	for _, v in pairs(love.window.getFullscreenModes(1)) do
		o = o .. string.format("%s,%s  ", v.width, v.height)
	end

	o = o .. "\n"
	o = o .. string.format("-------------------------------------------------------\n")
	o = o .. string.format("-- STARTING PARAMS \n")
	o = o .. string.format("\n%s", getfulldump(params))
	o = o .. string.format("-------------------------------------------------------\n")

	return o
end

return mu
