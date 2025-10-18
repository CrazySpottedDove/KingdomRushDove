-- chunkname: @./main.lua
if arg[2] == "debug" then
    LLDEBUGGER = require("lldebugger")
    LLDEBUGGER.start()
end
require("main_globals")

if KR_TARGET == "universal" then
    if KR_PLATFORM == "ios" then
        local ffi = require("ffi")

        ffi.cdef(" const char* kr_get_device_model(); ")

        local device_model = ffi.string(ffi.C.kr_get_device_model())
        local m = { string.match(device_model, "(%a+)(%d+),") }

        if m[1] == "iPad" then
            KR_TARGET = "tablet"
        else
            KR_TARGET = "phone"
        end

        print("UNIVERSAL TARGET SOLVED:", KR_TARGET)
    else
        print("ERROR: KR_TARGET==universal and not solved in this platform")

        return
    end
end

local base_dir = love.filesystem.getSourceBaseDirectory()
local work_dir = love.filesystem.getWorkingDirectory()
local ppref

if love.filesystem.isFused() then
    ppref = ""
elseif KR_PLATFORM == "android" then
    ppref = base_dir .. "/lovegame/"
else
    ppref = base_dir ~= work_dir and "" or "src/"
end

local apref = ppref .. "_assets/"
local rel_ppref = ""
local rel_apref = "_assets/"
local jpref = "joint_apk"

if love.filesystem.isFused() and KR_PLATFORM == "android" and love.filesystem.isDirectory(jpref) then
    local ffi = require("ffi")
    local arch = ffi.abi("gc64") and "64" or "32"

    ppref = jpref .. "/gc" .. arch .. "/"
    apref = jpref .. "/"
    rel_ppref = ppref
    rel_apref = apref

    print(string.format("main.lua - joint_apk found: configuring ppref:%s apref:%s", ppref, apref))
end

local additional_paths = { string.format("%s?.lua", ppref), string.format("%s%s-%s/?.lua", ppref, KR_GAME, KR_TARGET),
    string.format("%s%s/?.lua", ppref, KR_GAME),
    string.format("%sall-%s/?.lua", ppref, KR_TARGET), string.format("%sall/?.lua", ppref),
    string.format("%slib/?.lua", ppref), string.format("%slib/?/init.lua", ppref),
    string.format("%s%s-%s/?.lua", apref, KR_GAME, KR_TARGET),
    string.format("%sall-%s/?.lua", apref, KR_TARGET) }

package.path = package.path .. ";" .. table.concat(additional_paths, ";")

love.filesystem.setRequirePath("?.lua;?/init.lua" .. ";" .. table.concat(additional_paths, ";"))

KR_FULLPATH_BASE = base_dir .. "/src"
KR_PATH_ROOT = string.format("%s", rel_ppref)
KR_PATH_ALL = string.format("%s%s", rel_ppref, "all")
KR_PATH_ALL_TARGET = string.format("%s%s-%s", rel_ppref, "all", KR_TARGET)
KR_PATH_GAME = string.format("%s%s", rel_ppref, KR_GAME)
KR_PATH_GAME_TARGET = string.format("%s%s-%s", rel_ppref, KR_GAME, KR_TARGET)
KR_PATH_ASSETS_ROOT = string.format("%s", rel_apref)
KR_PATH_ASSETS_ALL_TARGET = string.format("%s%s-%s", rel_apref, "all", KR_TARGET)
KR_PATH_ASSETS_GAME_TARGET = string.format("%s%s-%s", rel_apref, KR_GAME, KR_TARGET)

if KR_TARGET == "tablet" then
    KR_PATH_ASSETS_ALL_FALLBACK = { {
        path = string.format("%s%s-%s", rel_apref, "all", "tablet")
    }, {
        path = string.format("%s%s-%s", rel_apref, "all", "phone")
    } }
    KR_PATH_ASSETS_GAME_FALLBACK = { {
        texture_size = "ipadhd",
        path = string.format("%s%s-%s", rel_apref, KR_GAME, "tablet")
    }, {
        texture_size = "iphonehd",
        path = string.format("%s%s-%s", rel_apref, KR_GAME, "phone")
    } }
end

local log = require("klua.log")

require("klua.table")
require("klua.dump")
require("version")
require("constants")

if arg[2] == "monitor" then
    PERFORMANCE_MONITOR_ENABLED = true
end
if version.build == "RELEASE" then
    DEBUG = nil
    log.level = log.ERROR_LEVEL

    local ok, l = pcall(require, "log_levels_release")

    log.default_level_by_name = ok and l or {}
else
    DEBUG = true
    log.level = log.INFO_LEVEL

    local ok, l = pcall(require, "log_levels_debug")

    log.default_level_by_name = ok and l or {}
end

log.use_print = KR_PLATFORM == "android"

local features = require("features")
local storage = require("storage")
local F = require("klove.font_db")
local MU = require("main_utils")
local i18n = require("i18n")

main = {}
main.handler = nil
main.profiler = nil
main.profiler_displayed = false
main.draw_stats = nil
main.draw_stats_displayed = false
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

local function load_director()
    love.window.setMode(main.params.width, main.params.height, {
        fullscreentype = "exclusive",
        centered = false,
        fullscreen = main.params.fullscreen,
        vsync = main.params.vsync,
        msaa = main.params.msaa,
        highdpi = main.params.highdpi
    })

    local aw, ah = love.graphics.getDimensions()

    if aw and ah and (aw ~= main.params.width or ah ~= main.params.height) then
        log.debug("patching width/height from %s,%s, to %s,%s dpi scale:%s", main.params.width, main.params.height, aw,
            ah, love.window.getPixelScale())

        main.params.width, main.params.height = aw, ah
    end

    if main.params.wpos then
        local x, y = unpack(main.params.wpos)

        love.window.setPosition(x or 1, y or 1)
    end

    local director = require("director")

    director:init(main.params)

    main.handler = director
end

local function load_app_settings()
    local I = require("klove.image_db")
    local settings = require("screen_settings")
    local w, h = 400, 500

    for _, t in pairs(settings.required_textures) do
        I:load_atlas(1, KR_PATH_ASSETS_GAME_TARGET .. "/images/fullhd", t)
    end

    local function done_cb()
        storage:save_settings(main.params)

        main.handler = nil

        for _, t in pairs(settings.required_textures) do
            I:unload_atlas(t, 1)
        end
        collectgarbage()
        load_director()
    end

    settings:init(w, h, main.params, done_cb)

    main.handler = settings

    love.window.setMode(w, h, {
        centered = true,
        vsync = false
    })
end
function love.load(arg)
    love.filesystem.setIdentity(version.identity)

    if love.filesystem.isFused() and not love.filesystem.exists(KR_PATH_ALL_TARGET) then
        log.info("")
        log.info("mounting asset files...")
        log.debug("mounting base_dir")

        if not love.filesystem.mount(base_dir, "/", true) then
            log.error("error mounting assets base_dir: %s", base_dir)

            return
        end

        for _, n in pairs({ KR_PATH_ALL_TARGET, KR_PATH_GAME_TARGET }) do
            local fn = string.format("%s.dat", n)
            local dn = string.format("%s", n)

            log.debug("mounting %s -> %s", fn, dn)

            if not love.filesystem.mount(fn, dn, true) then
                log.error("error mounting assets file: %s", fn)

                return
            end
        end
    end

    main.params = storage:load_settings()

    MU.basic_init()

    if DEBUG and love.filesystem.isFile(KR_PATH_ROOT .. "args.lua") then
        if KR_TARGET == "desktop" then
            print("WARNING: Appending parameters from args.lua with command line args.")

            arg = table.append(arg, require("args"), true)
        else
            print("WARNING: Reading parameters from args.lua. Overrides all cmdline arguments")

            arg = require("args")
        end
    end

    MU.parse_args(arg, main.params)
    MU.default_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)
    MU.apply_params(main.params, KR_GAME, KR_TARGET, KR_PLATFORM)

    if main.params.log_level then
        log.level = tonumber(main.params.log_level)
    end

    main.log_output = MU.redirect_output(main.params)

    if main.log_output then
        log.error(MU.get_version_info(version))
        log.error(MU.get_graphics_features())
    end

    MU.start_debugger(main.params)

    if DEBUG then
        log.info(MU.get_debug_info(main.params))
    end

    local font_paths = KR_PATH_ASSETS_ALL_FALLBACK or { {
        path = KR_PATH_ASSETS_ALL_TARGET
    } }

    for _, v in pairs(font_paths) do
        local p = v.path .. "/fonts"

        if love.filesystem.exists(p .. "/ObelixPro.ttf") then
            F:init(p)
            F:load()
        end
    end

    main:set_locale(main.params.locale)
    -- love.window.setTitle(_("GAME_TITLE_" .. string.upper(KR_GAME)))
    love.window.setTitle(version.title .. version.id)
    -- icon switched
    local icon = KR_PATH_ASSETS_GAME_TARGET .. "/icons/krdove.png"

    if love.filesystem.isFile(icon) then
        love.window.setIcon(love.image.newImageData(icon))
    end

    if not main.params.skip_settings_dialog then
        load_app_settings()
    else
        load_director()
    end

    if main.params.profiler then
        main.profiler = require("profiler")
    end

    if main.params.draw_stats then
        main.draw_stats = require("draw_stats")
        main.draw_stats_displayed = true

        main.draw_stats:init(main.params.width, main.params.height)
    end

    if DEBUG then
        require("debug_tools")

        if main.params.localuser then
            log.error("---- LOADING LOCALUSER -----")
            require("localuser")
        end
    end

    if main.params.custom_script then
        log.error("---- LOADING CUSTOM SCRIPT %s ----", main.params.custom_script)
        require(main.params.custom_script)

        if custom_script.init then
            custom_script:init()
        end
    end

    if KR_PLATFORM == "ios" then
        local ffi = require("ffi")

        ffi.cdef(" void kr_init_ios(); ")
        ffi.C.kr_init_ios()
    end
end

function love.update(dt)
    if DEBUG and not main.params.debug and main.params.repl then
        repl_t()
    end

    storage:update(dt)
    main.handler:update(dt)

    if DEBUG and main.params.localuser and localuser_update then
        localuser_update(dt)
    end

    if custom_script and custom_script.update then
        custom_script:update(dt)
    end
end

function love.draw()
    main.handler:draw()

    if main.profiler and main.profiler_displayed then
        main.profiler.draw(main.params.width, main.params.height, F:f("DroidSansMono", 14))
    end

    if main.draw_stats and main.draw_stats_displayed then
        main.draw_stats:draw(main.params.width, main.params.height)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if LLDEBUGGER and key == "0" then
        LLDEBUGGER.start()
    end

    if main.profiler then
        if key == "f1" then
            main.profiler.start()
        elseif key == "f2" then
            main.profiler.stop()
        elseif key == "f3" then
            main.profiler_displayed = not main.profiler_displayed
        elseif key == "f4" then
            main.profiler.flag_l2_shown = not main.profiler.flag_l2_shown
            main.profiler.flag_dirty = true
        end
    end

    if main.draw_stats and key == "f" then
        main.draw_stats_displayed = not main.draw_stats_displayed
    end

    if custom_script and custom_script.keypressed then
        custom_script:keypressed(key, isrepeat)
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
    if custom_script and custom_script.mousepressed then
        custom_script:mousepressed(x, y, button, istouch)
    end

    main.handler:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    main.handler:mousereleased(x, y, button, istouch)
end

function love.wheelmoved(dx, dy)
    if main.handler.wheelmoved then
        main.handler:wheelmoved(dx, dy, button)
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

function love.gamepadaxis(joystick, axis, value)
    if main.handler.gamepadaxis then
        main.handler:gamepadaxis(joystick, axis, value)
    end
end

function love.gamepadpressed(joystick, button)
    if custom_script and custom_script.gamepadpressed then
        custom_script:gamepadpressed(joystick, button)
    end

    if main.handler.gamepadpressed then
        main.handler:gamepadpressed(joystick, button)
    end
end

function love.gamepadreleased(joystick, button)
    if main.handler.gamepadreleased then
        main.handler:gamepadreleased(joystick, button)
    end
end

function love.joystickpressed(joystick, button)
    if main.handler.joystickpressed then
        main.handler:joystickpressed(joystick, button)
    end
end

function love.joystickreleased(joystick, button)
    if main.handler.joystickreleased then
        main.handler:joystickreleased(joystick, button)
    end
end

function love.joystickadded(joystick)
    if main.handler.joystickadded then
        main.handler:joystickadded(joystick)
    end
end

function love.joystickremoved(joystick)
    if main.handler.joystickremoved then
        main.handler:joystickremoved(joystick)
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

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())

        for i = 1, 3 do
            love.math.random()
        end
    end

    if love.load then
        love.load(arg)
    end

    if love.timer then
        love.timer.step()
    end

    local dt = 0
    local updatei, updatef, presi, presf, drawi, drawf
    local nx = love.nx

    while true do
        if main.profiler and nx and nx.isProfiling() then
            nx.profilerHeartbeat()
            if love.event then
                love.event.pump()

                for e, a, b, c, d in love.event.poll() do
                    if e == "quit" and (not love.quit or not love.quit()) then
                        return
                    end

                    love.handlers[e](a, b, c, d)
                end
            end

            if love.timer then
                love.timer.step()

                dt = love.timer.getDelta()
            end
            if main.draw_stats then
                updatei = love.timer.getTime()
            end
            nx.profilerEnterCodeBlock("update")
            if love.update then
                love.update(dt)
            end
            nx.profilerExitCodeBlock("update")
            if main.draw_stats then
                updatef = love.timer.getTime()

                main.draw_stats:update_lap(dt, updatei, updatef)
            end
            if love.window and love.graphics and love.window.isCreated() and love.graphics.isActive() then
                nx.profilerEnterCodeBlock("clear")

                love.graphics.clear()
                love.graphics.origin()

                nx.profilerExitCodeBlock("clear")

                if love.draw then
                    if main.draw_stats then
                        drawi = love.timer.getTime()
                    end

                    nx.profilerEnterCodeBlock("draw")

                    love.draw()

                    nx.profilerExitCodeBlock("draw")

                    if main.draw_stats then
                        drawf = love.timer.getTime()

                        main.draw_stats:draw_lap(drawi, drawf)
                    end
                end

                collectgarbage("step")

                if main.draw_stats then
                    presi = love.timer.getTime()
                end

                nx.profilerEnterCodeBlock("present")

                love.graphics.present()

                nx.profilerExitCodeBlock("present")

                if main.draw_stats then
                    presf = love.timer.getTime()

                    main.draw_stats:present_lap(presi, presf)
                end

                if main.handler.limit_fps then
                    nx.profilerEnterCodeBlock("limit_fps")

                    main.handler:limit_fps()

                    nx.profilerExitCodeBlock("limit_fps")
                end
            end

            if love.timer then
                love.timer.sleep(0.001)
            end
        else
            -- normal mode，逻辑看这里即可
            if love.event then
                love.event.pump()

                for e, a, b, c, d in love.event.poll() do
                    if e == "quit" and (not love.quit or not love.quit()) then
                        return
                    end
                    love.handlers[e](a, b, c, d)
                end
            end

            if love.timer then
                love.timer.step()
                dt = love.timer.getDelta()
            end
            if main.draw_stats then
                updatei = love.timer.getTime()
            end
            if love.update then
                love.update(dt)
            end
            if main.draw_stats then
                updatef = love.timer.getTime()
                main.draw_stats:update_lap(dt, updatei, updatef)
            end
            if love.window and love.graphics and love.window.isCreated() and love.graphics.isActive() then
                love.graphics.clear()
                love.graphics.origin()

                if love.draw then
                    if main.draw_stats then
                        drawi = love.timer.getTime()
                    end

                    love.draw()

                    if main.draw_stats then
                        drawf = love.timer.getTime()

                        main.draw_stats:draw_lap(drawi, drawf)
                    end
                end

                if main.draw_stats then
                    presi = love.timer.getTime()
                end

                love.graphics.present()

                if main.draw_stats then
                    presf = love.timer.getTime()

                    main.draw_stats:present_lap(presi, presf)
                end

                if main.handler.limit_fps then
                    main.handler:limit_fps()
                else
                    collectgarbage("step")
                    love.timer.sleep(0.001)
                end
            else
                if love.timer then
                    love.timer.sleep(0.001)
                end
            end
        end
    end
end

function love.quit()
    log.info("Quitting...")
    close_log()
end

local function get_error_stack(msg, layer)
    return (debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", ""))
end

local function crash_report(str)
    if KR_PLATFORM == "android" then
        local jnia = require("jni_android")

        jnia.crashlytics_log_and_crash(str)
    elseif KR_PLATFORM == "ios" then
        local PS = require("platform_services")

        if PS.services.analytics then
            PS.services.analytics:log_and_crash(str)
        end
    end
end

function love.errhand(msg)
    local error_canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    local last_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(error_canvas)

    local last_log_msg = log.last_log_msgs and table.concat(log.last_log_msgs, "")

    msg = tostring(msg)

    local stack_msg = debug.traceback("Error: " .. tostring(msg), 3):gsub("\n[^\n]+$", "")

    stack_msg = (stack_msg or "") .. "\n" .. last_log_msg

    print(stack_msg)
    log.error(stack_msg)
    close_log()
    pcall(crash_report, stack_msg)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)

        if not success or not status then
            return
        end
    end

    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)

        if love.mouse.hasCursor() then
            love.mouse.setCursor()
        end
    end

    if love.joystick then
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end

    if love.audio then
        love.audio.stop()
    end

    love.graphics.reset()

    local font = love.graphics.setNewFont(math.floor(love.window.toPixels(15)))
    local cn_font = love.graphics.setNewFont("_assets/all-desktop/fonts/msyh.ttc",
        math.floor(love.window.toPixels(16)))

    love.graphics.setBackgroundColor(89, 157, 220)
    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    --love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()

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
        table.insert(tip, "666，程序爆炸了! 如果您不想被吐槽看不懂中文的话，请先按照提示说的做。还是搞不定，再将本界面与此前界面截图并反馈，而不是仅语言描述。按 “z” 显示此前界面以截图。\n")
    elseif not has_tip then
        table.insert(tip, "666，程序爆炸了！如果您不想被吐槽看不懂中文的话，请首先确定版本是否为最新。如果不是最新，不要反馈，不要找作者。如果版本为最新，再完整截下蓝屏的图，并按 “z” 显示崩溃前界面，一并截图展示，并用语言简要说明发生了什么。\n")
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

    love.graphics.setFont(font)
    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)

    love.graphics.setFont(cn_font)
    love.graphics.printf(pt, pos, pos, love.graphics.getWidth() - pos)

    love.graphics.present()

    local function draw()
        if love.keyboard.isDown("z") then
            love.graphics.present()
            love.timer.sleep(0.4)
        else
            love.graphics.draw(error_canvas, 0, 0)
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
                return
            elseif e == "keypressed" and a == "escape" then
                if error_type == "coro" then
                    quiterr = true
                    break
                else
                    return
                end
            elseif e == "touchpressed" then
                local name = love.window.getTitle()

                if #name == 0 or name == "Untitled" then
                    name = "Game"
                end

                local buttons = { "OK", "Cancel" }
                local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)

                if pressed == 1 then
                    return
                end
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end

        if quiterr then
            break
        end
    end
end
