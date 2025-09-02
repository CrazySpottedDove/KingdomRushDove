-- chunkname: @./all/director.lua
local log = require("klua.log"):new("director")
local km = require("klua.macros")
local signal = require("hump.signal")

require("klua.dump")

local mod = require("mod")
local features = require("features")
local i18n = require("i18n")
local V = require("klua.vector")
local I = require("klove.image_db")
local F = require("klove.font_db")
local SH = require("klove.shader_db")
local KDB = require("klove.kui_db")
local S = require("sound_db")
local G = love.graphics
local AC = require("achievements")
local LU = require("level_utils")
local RC = require("remote_config")
local ISM = require("input_state_machine")
local marketing = require("marketing")
local PP = require("privacy_policy_consent")
local storage = require("storage")
local services = require("platform_services")
local director_data = require("data.director_data")
local GS = require("game_settings")
local function replace_locale(list, locale)
    local out = {}

    for _, v in pairs(list) do
        local ns = string.gsub(v, "LOCALE", locale or i18n.current_locale)

        table.insert(out, ns)
    end

    return out
end

director = {}
director.item_props = director_data.item_props

function director:init(params)
    KDB:init(KR_PATH_GAME_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_ALL_TARGET .. "/data/kui_templates", DEBUG)
    SH:init(KR_PATH_ASSETS_ALL_TARGET .. "/shaders", true)

    local sound_paths = KR_PATH_ASSETS_GAME_FALLBACK or {{
        path = KR_PATH_ASSETS_GAME_TARGET
    }}

    for _, v in pairs(sound_paths) do
        local p = v.path .. "/sounds"

        if love.filesystem.exists(p .. "/sounds.lua") then
            S:init(p)

            break
        end
    end

    I.use_canvas = params.image_db_uses_canvas

    RC:init()
    AC:init()

    if (KR_TARGET == "phone" or KR_TARGET == "tablet") and KR_PLATFORM == "ios" then
        storage:import_plist("NSUserDefaults")
    end

    services:init(true)
    PP:init()

    if PP:has_consent() and not features.delay_services_init then
        services:init()
        marketing:init()
    end

    self.params = params

    self:reset_screen_params()

    if params.locale then
        main:set_locale(params.locale)
        -- love.window.setTitle(_("GAME_TITLE_" .. string.upper(KR_GAME)))
        love.window.setTitle(version.title .. version.id)
    end

    if features.overrides and
        (table.contains(features.overrides, "censored_cn") or table.contains(features.overrides, "yodo1sdk")) then
        BLOOD_RED = BLOOD_GRAY
    end

    if KR_TARGET == "phone" and KR_PLATFORM == "android" then
        local filename = "/data/data/" .. version.bundle_id .. "/files/.Defaults.plist"

        storage:import_plist(filename)
    elseif KR_TARGET == "desktop" and KR_GAME == "kr1" and services.services then
        local dir

        if services.services.steam then
            dir = services.services.steam:get_install_dir()
        elseif services.services.gamecenter then
            dir = services.services.gamecenter:get_install_dir()
        elseif services.services.kart then
            dir = services.services.kart:get_install_dir()
        end

        if not dir then
            log.info("Could not find original install dir. Skipping savegame import")
        else
            storage:import_dotnet(dir)
        end
    end

    self.next_item_name = "splash"

    if params.level or params.screen then
        if not storage:load_slot(1) then
            storage:create_slot(1)
        end

        storage:set_active_slot(1)

        if params.screen then
            self.next_item_name = params.screen
            self.next_item_args = {
                custom = params.custom,
                texture_size = params.texture_size
            }
        elseif params.level then
            self.next_item_name = "game"
            self.next_item_args = {
                level_idx = tonumber(params.level),
                level_mode = params.mode and tonumber(params.mode) or GAME_MODE_CAMPAIGN,
                level_difficulty = params.diff and tonumber(params.diff) or DIFFICULTY_NORMAL
            }
        end
    end

    if KR_TARGET == "desktop" then
        if params.screen == "game_editor" then
            local c = love.mouse.newCursor(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/crosshair.png", 16, 16)

            love.mouse.setCursor(c)
        else
            local cursor_name = "hand_32"

            if params.large_pointer then
                cursor_name = params.height < 1080 and "hand_48" or "hand_64"
            end

            self.cursor_up = love.mouse.newCursor(string.format(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/%s_0001.png",
                cursor_name), 3, 2)
            self.cursor_down = love.mouse.newCursor(string.format(KR_PATH_ASSETS_ALL_TARGET .. "/cursors/%s_0002.png",
                cursor_name), 3, 2)

            love.mouse.setCursor(self.cursor_up)
        end
    end
    mod:init()
end

function director:quit()
    log.debug("quitting...")
    services:shutdown()
    love.event.quit()
end

function director:get_texture_scale(item_name, ref_res, forced_texture_size)
    local scale = ref_res / TEXTURE_SIZE_ALIAS[forced_texture_size or self.params.texture_size]
    local factors = TEXTURE_SIZE_FACTOR[forced_texture_size or self.params.texture_size]

    if factors and factors[item_name] then
        scale = scale / factors[item_name]
    end

    log.debug("item:%s ref_res:%s texture_size:%s forced_texture_size:%s-> scale:%s", item_name, ref_res,
        self.params.texture_size, forced_texture_size, scale)

    return scale
end

function director:reset_screen_params(force_scissor)
    local params = self.params
    local aw, ah = love.graphics.getDimensions()

    params.width, params.height = aw, ah

    local screen_aspect = params.width / params.height
    local max_aspect = MAX_SCREEN_ASPECT
    local min_aspect = MIN_SCREEN_ASPECT

    if screen_aspect < min_aspect then
        self.scissor_w = params.width
        self.scissor_h = params.width / min_aspect
        self.scissor_x = 0
        self.scissor_y = (params.height - self.scissor_h) * 0.5
        self.scissor_enabled = true
    elseif max_aspect < screen_aspect then
        self.scissor_w = params.height * max_aspect
        self.scissor_h = params.height
        self.scissor_x = (params.width - self.scissor_w) * 0.5
        self.scissor_y = 0
        self.scissor_enabled = true
    else
        self.scissor_enabled = false
    end

    if force_scissor ~= nil then
        log.info("forcing scissor value to %s", force_scissor)

        self.scissor_enabled = force_scissor
    end

    log.info("resetting screen params. w,h:%s,%s scissor:%s %s,%s,%s,%s", aw, ah, self.scissor_enabled, self.scissor_x,
        self.scissor_y, self.scissor_w, self.scissor_h)
end

function director:item_done_callback(item_name, outcome)
    if self.active_item and self.active_item.done_callback_called then
        log.error("  Done callback already called... Ignoring!")

        return
    end

    self.active_item.done_callback_called = true

    if self.active_item then
        local w = self.active_item.game_gui and self.active_item.game_gui.window or self.active_item.window

        if w then
            log.debug("disabling events for item:%s window:%s", self.active_item.item_name, w)
            w:disable(false)

            if ISM then
                ISM:destroy(w)
            end
        end
    end

    log.debug("DONE CALLBACK FROM %s with outcome %s", item_name, getdump(outcome))

    if outcome then
        if outcome.quit then
            self:quit()

            return
        elseif outcome.next_item_name then
            self.next_item_name = outcome.next_item_name
            self.next_item_args = outcome

            return
        elseif outcome.prevent_loading then
            self.next_item_prevent_loading = true
        end

        if outcome.privacy_policy_accepted then
            PP:give_consent_with_age(outcome.birth_month, outcome.birth_year)
            services:init()
            marketing:init()
        end

        if outcome.simple_privacy_policy_accepted then
            local global = storage:load_global()

            global.simple_privacy_policy_accepted = true

            storage:save_global(global)
        end

        if outcome.splash_done and features.delay_services_init and not features.requires_privacy_policy then
            services:init()
            marketing:init()
        end
    end

    if item_name == "comics" then
        self.queued_item = self.active_item.game_item

        return
    end

    local props = self.item_props[item_name]

    ::label_6_0::

    if props.next then
        local props_next = self.item_props[props.next]

        if props_next and props_next.skip_check and director.skip_checks[props_next.skip_check] and
            director.skip_checks[props_next.skip_check]() then
            log.debug("skipping screen %s. %s passed", props.next, props_next.skip_check)

            props = props_next

            goto label_6_0
        end

        self.next_item_name = props.next
        self.next_item_args = {}

        return
    end
end

function director:unload_item(item)
    if not item then
        log.debug("item nil")

        return
    end

    if item.item_name == "game" then
        local game = item

        self:unload_texture_groups(replace_locale(game.game_gui.required_textures), self.params.texture_size,
            game.game_gui.ref_res, "game_gui")

        local groups = {}
        local scaled_groups = {}
        groups = table.append(groups, replace_locale(game.required_textures))
        groups = table.append(groups, replace_locale(game.store.level.required_textures))
        scaled_groups = table.append(scaled_groups, replace_locale(game.scale_required_textures))
        if game.store.selected_hero then
            for _, hero in pairs(game.store.selected_hero) do
                if hero then
                    if GS.heroes_require_scaled_texture[hero] then
                        scaled_groups = table.append(scaled_groups, {"go_" .. hero})
                    else
                        groups = table.append(groups, {"go_" .. hero})
                    end
                end
            end
        end

        self:unload_texture_groups(groups, self.params.texture_size, game.ref_res, "game")
        self:unload_texture_groups(scaled_groups, self.params.texture_size, game.ref_res * game.scale_required_textures_scale, "game")
        I:unload_atlas("temp_game_texts", game.store.screen_scale)

        if item.required_sounds then
            for _, group in pairs(item.required_sounds) do
                S:unload_group(group)
            end
        end

        if game.store.level.required_sounds then
            for _, group in pairs(game.store.level.required_sounds) do
                S:unload_group(group)
            end
        end

        if game.store.selected_hero then
            for _, hero in pairs(game.store.selected_hero) do
                if hero then
                    S:unload_group(hero)
                end
            end
        end

        local criket = game.store.criket
        if criket and criket.on then
            for _, group in pairs(criket.required_sounds) do
                S:unload_group(group)
            end
        end

        game:destroy()

        game.store = nil

        collectgarbage()
    elseif not item.keep_loaded then
        local textures = item.required_textures

        if textures then
            local scale = self:get_texture_scale(item.item_name, item.ref_res)

            for _, group in pairs(replace_locale(textures, item.locale_at_requirement)) do
                I:unload_atlas(group, scale)
            end
        end

        if item.required_sounds then
            for _, group in pairs(item.required_sounds) do
                S:unload_group(group)
            end
        end

        if item.destroy then
            item:destroy()
        end

        collectgarbage()
    end
end

function director:queue_load_item_named(name, force_reload)
    local function _require(name, force)
        if force_reload or force then
            package.loaded[name] = nil
        end

        local r = require(name)

        r.locale_at_requirement = i18n.current_locale

        return r
    end

    local props = self.item_props[name]

    self:reset_screen_params(props and props.scissor)

    if DBG_REPLACE_MISSING_TEXTURES then
        self:load_texture_groups({"_debug_textures"}, self.params.texture_size, 480, false)
    end

    local show_loading = props.show_loading

    if self.next_item_prevent_loading then
        show_loading = false
        self.next_item_prevent_loading = nil
    end

    if show_loading then
        local loading = _require("screen_loading")
        local level_idx

        if game and game.store and game.store.level_idx then
            level_idx = game.store.level_idx
        elseif self.next_item_args then
            level_idx = self.next_item_args.level_idx
        end

        if loading.update_required_textures then
            loading:update_required_textures(name, level_idx)
        end

        self:load_texture_groups(loading.required_textures, self.params.texture_size, loading.ref_res, false)

        if loading.required_sounds then
            self:load_sound_groups(loading.required_sounds)
        end

        loading:init(self.params.width, self.params.height)
        loading:close()

        self.queue_unload_item = self.active_item
        self.active_item = loading
    end

    if props.type == "screen" then
        local item = _require(props.src, self.next_item_args and self.next_item_args.force_reload)

        item.item_name = name
        item.args = self.next_item_args

        if item.required_textures then
            self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res,
                true, name)
        end

        if item.ref_res then
            item.screen_scale = self:get_texture_scale(name, item.ref_res)
        end

        self.queued_item = item

        if item.required_sounds then
            self:load_sound_groups(item.required_sounds)
        end
    elseif props.type == "comic" then
        local args = self.next_item_args
        local comic_idx = args.custom
        local item = _require("screen_comics")

        item.item_name = "comics"
        item.required_textures = {"loading_common", "comic_" .. comic_idx}
        item.comic_data = love.filesystem.read(KR_PATH_GAME_TARGET .. string.format("/data/comics/%02i.csv", comic_idx))

        self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true)

        self.queued_item = item
    elseif props.type == "game" then
        local game_gui = _require("game_gui")
        local game = _require("game")

        game.item_name = "game"
        game.max_fps = DRAW_FPS

        local args = self.next_item_args

        game.store = {}
        game.store.level_idx = args.level_idx
        game.store.level_name = "level" .. string.format("%02i", args.level_idx)
        game.store.level_mode = args.level_mode
        game.store.level_difficulty = args.level_difficulty
        game.store.screen_scale = self:get_texture_scale("game", REF_H)
        game.store.texture_size = self.params.texture_size
        game.store.level = LU.load_level(game.store, game.store.level_name)

        game.store.config = storage:load_config()
        if game.store.config.endless then
            game.store.level_mode_override = GAME_MODE_ENDLESS
        end
        game.store.criket = storage:load_criket()

        local criket = game.store.criket
        if criket and criket.on then
            self:load_texture_groups(replace_locale(criket.required_textures), self.params.texture_size, game.ref_res,
                true, "game")
            self:load_sound_groups(criket.required_sounds)
        end

        self:load_texture_groups(replace_locale(game.required_textures), self.params.texture_size, game.ref_res, true,
            "game")
        self:load_texture_groups(replace_locale(game.scale_required_textures), self.params.texture_size,
            game.ref_res * game.scale_required_textures_scale, true, "game")
        self:load_texture_groups(replace_locale(game.store.level.required_textures), self.params.texture_size,
            game.ref_res, true, "game")

        self:load_texture_groups(replace_locale(game_gui.required_textures), self.params.texture_size, game_gui.ref_res,
            true, "game_gui")
        self:load_sound_groups(game.required_sounds)
        self:load_sound_groups(game.store.level.required_sounds)

        local slot = storage:load_slot()

        if slot.heroes.selected then
            for _, hero in pairs(slot.heroes.selected) do
                if hero then
                    local hero_textures = {"go_" .. hero}
                    if GS.heroes_require_scaled_texture[hero] then
                        self:load_texture_groups(hero_textures, self.params.texture_size, game.ref_res * game.scale_required_textures_scale, true, "game")
                    else
                        self:load_texture_groups(hero_textures, self.params.texture_size, game.ref_res, true, "game")
                        self:load_sound_groups({hero})
                    end
                end
            end
        end

        if game.store.level.show_comic_idx and game.store.level_mode == GAME_MODE_CAMPAIGN then
            local comic_idx = game.store.level.show_comic_idx
            local item = _require("screen_comics")

            item.item_name = "comics"
            item.required_textures = {"comic_" .. comic_idx}
            item.level_idx = game.store.level_idx
            item.comic_data = love.filesystem.read(KR_PATH_GAME_TARGET ..
                                                       string.format("/data/comics/%02i.csv", comic_idx))

            self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res,
                true, "comic")

            self.queued_item = item
            item.game_item = game
            self.queued_item = game
        else
            self.queued_item = game
        end
    end

    log.debug("queued item: %s", self.queued_item.item_name)
end

function director:unload_texture_groups(groups, texture_size, ref_height, item_name)
    local forced_texture_size

    for _, group in pairs(groups) do
        if KR_PATH_ASSETS_GAME_FALLBACK then
            local texture_path = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. texture_size

            if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
                -- block empty
            else
                for _, v in pairs(KR_PATH_ASSETS_GAME_FALLBACK) do
                    texture_path = v.path .. "/images/" .. v.texture_size

                    if love.filesystem.exists(texture_path .. "/" .. group .. ".lua") then
                        log.debug(" --- texture group %s fallback to %s", group, texture_path)

                        forced_texture_size = v.texture_size

                        break
                    end
                end
            end
        end

        local scale = 1

        if ref_height then
            scale = self:get_texture_scale(item_name, ref_height, forced_texture_size)
        end

        I:unload_atlas(group, scale)
    end
end

function director:load_texture_groups(groups, texture_size, ref_height, queue, item_name)
    if not groups then
        return
    end
    local scale = 1
    if ref_height then
        scale = self:get_texture_scale(item_name, ref_height)
    end

    for _, group in pairs(groups) do

        local texture_path = KR_PATH_ASSETS_GAME_TARGET .. "/images/" .. texture_size

        if features.overrides then
            for _, n in pairs(features.overrides) do
                local ov_path = texture_path .. "/_ov/" .. n

                if love.filesystem.exists(ov_path .. "/" .. group .. ".lua") then
                    log.debug("  +++ texture group %s overriden by %s", group, n)

                    texture_path = ov_path
                end
            end
        end

        if queue then
            I:queue_load_atlas(scale, texture_path, group)
        else
            I:load_atlas(scale, texture_path, group)
        end
    end
end

function director:load_sound_groups(groups)
    S.global_source_mode = self.params.audio_mode

    if groups then
        for _, group in pairs(groups) do
            S:queue_load_group(group)
        end
    end
end

function director:queued_item_ready(dt)
    return I:queue_load_done() and S:queue_load_done()
end

function director:update(dt)
    S:update(dt)

    if self.next_item_name then
        self:queue_load_item_named(self.next_item_name, self.force_reload)

        self.queued_item_init = false
        self.queued_item_first_draw = false
        self.last_item_name = self.next_item_name
        self.next_item_name = nil
        self.force_reload = nil
    end

    if self.active_item then
        local ai = self.active_item

        if ai.limit_fps then
            ai.next_frame_ts = ai.limit_fps and ai.next_frame_ts + 1 / ai.limit_fps or nil
        end

        ai:update(dt)
    end

    local ai = self.active_item
    local aits = ai and ai.is_transition and ai.transition_state or nil

    if aits == "closing" or aits == "opening" then
        -- block empty
    else
        if self.queue_unload_item and (not aits or aits == "closed") then
            self:unload_item(self.queue_unload_item)

            self.queue_unload_item = nil
        end

        if self.queued_item and self:queued_item_ready(dt) then
            local ai = self.active_item

            if ai and ai.hold_enabled then
                -- block empty
            else
                if not self.queued_item_init then
                    local item = self.queued_item

                    local function cb(outcome)
                        self:item_done_callback(item.item_name, outcome)
                    end

                    self.queued_item:init(self.params.width, self.params.height, cb)

                    self.queued_item.done_callback_called = nil
                    self.queued_item_init = true
                    self.queued_item_first_draw = false

                    self.queued_item:update(2 * TICK_LENGTH)

                    goto label_14_0
                end

                if ai then
                    if ai.transition_state == "closing" then
                        goto label_14_0
                    elseif ai.transition_state == "closed" and self.queued_item_first_draw then
                        ai:open()

                        goto label_14_0
                    elseif ai.transition_state == "opening" then
                        goto label_14_0
                    end
                end

                self:unload_item(self.active_item)

                self.active_item = self.queued_item
                self.queued_item = nil
                self.queued_item_init = nil

                signal.emit(SGN_DIRECTOR_ITEM_SHOWN, self.active_item.item_name, self.active_item)

                local item = self.active_item
                local fps

                if item.max_fps then
                    fps = item.max_fps
                else
                    fps = not self.params.vsync and 60 or nil
                end

                item.limit_fps = fps
                item.next_frame_ts = love.timer.getTime()
            end
        end
    end

    ::label_14_0::

    if ISM then
        local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

        ISM:update(dt, state)
    end

    services:update(dt)
end

function director:draw()
    if self.active_item then
        if self.scissor_w and self.scissor_enabled then
            G.setScissor(self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
        end

        local ai = self.active_item

        if ai.transition_state == "closing" and self.queue_unload_item then
            self.queue_unload_item:draw()
        elseif self.queued_item and self.queued_item_init then
            self.queued_item:draw()

            self.queued_item_first_draw = true
        end

        ai:draw()

        if self.scissor_w and self.scissor_enabled then
            G.setScissor()
        end
    end
end

function director:limit_fps()
    if self.active_item then
        local ai = self.active_item

        if ai.next_frame_ts then
            local current_ts = love.timer.getTime()

            if current_ts >= ai.next_frame_ts then
                ai.next_frame_ts = current_ts

                return
            end

            love.timer.sleep(ai.next_frame_ts - current_ts)
        end
    end
end

function director:keypressed(key, isrepeat)
    if key == "tab" and love.window.getFullscreen() and love.system.getOS() == "OS X" and
        (love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")) then
        love.window.minimize()

        return
    end

    if DEBUG and key == "r" and love.keyboard.isDown("lshift") and not isrepeat then
        RC:reload()

        if self.active_item and self.active_item.item_name == "game" then
            log.error("FORCING RELOAD OF GUI ONLY")
            game:reload_gui()
        else
            log.error("FORCING RELOAD OF %s", self.last_item_name)

            self.force_reload = true
            self.next_item_name = self.last_item_name
        end

        return
    end

    if self.active_item and self.active_item.keypressed and self.active_item:keypressed(key, isrepeat) then
        return
    end

    if ISM then
        local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

        ISM:proc_key(state, key, isrepeat)
    end
end

function director:keyreleased(key, isrepeat)
    if self.active_item and self.active_item.keyreleased then
        self.active_item:keyreleased(key, isrepeat)
    end
end

function director:textinput(t)
    if self.active_item and self.active_item.textinput then
        self.active_item:textinput(t)
    end
end

function director:mousepressed(x, y, button, istouch)
    if DEBUG_CLICK then
        log.debug("mouspressed at (%i,%i)", x, y)
    end

    if self.cursor_down then
        love.mouse.setCursor(self.cursor_down)
    end

    if self.active_item and self.active_item.mousepressed then
        self.active_item:mousepressed(x, y, button, istouch)
    end
end

function director:mousereleased(x, y, button, istouch)
    if self.cursor_up then
        love.mouse.setCursor(self.cursor_up)
    end

    if self.active_item and self.active_item.mousereleased then
        self.active_item:mousereleased(x, y, button, istouch)
    end
end

function director:wheelmoved(dx, dy)
    if self.active_item and self.active_item.wheelmoved then
        self.active_item:wheelmoved(dx, dy)
    end
end

function director:touchpressed(id, x, y, dx, dy, pressure)
    if self.active_item and self.active_item.touchpressed then
        self.active_item:touchpressed(id, x, y, dx, dy, pressure)
    end
end

function director:touchreleased(id, x, y, dx, dy, pressure)
    if self.active_item and self.active_item.touchreleased then
        self.active_item:touchreleased(id, x, y, dx, dy, pressure)
    end
end

function director:touchmoved(id, x, y, dx, dy, pressure)
    if self.active_item and self.active_item.touchmoved then
        self.active_item:touchmoved(id, x, y, dx, dy, pressure)
    end
end

function director:gamepadaxis(joystick, axis, value)
    if self.active_item and self.active_item.gamepadaxis then
        self.active_item:gamepadaxis(joystick, axis, value)
    end
end

function director:gamepadpressed(joystick, button)
    if self.active_item then
        if self.active_item.gamepadpressed then
            self.active_item:gamepadpressed(joystick, button)
        end

        local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

        if ISM then
            ISM:proc_button(state, joystick, button)
        end
    end
end

function director:gamepadreleased(joystick, button)
    if self.active_item and self.active_item.gamepadreleased then
        self.active_item:gamepadreleased(joystick, button)
    end
end

function director:joystickpressed(joystick, button)
    if self.active_item and self.active_item.joystickpressed then
        self.active_item:joystickpressed(joystick, button)
    end
end

function director:joystickreleased(joystick, button)
    if self.active_item and self.active_item.joystickreleased then
        self.active_item:joystickreleased(joystick, button)
    end
end

function director:joystickadded(joystick)
    if ISM then
        ISM:joystickadded(joystick)
    end

    if self.active_item and self.active_item.joystickadded then
        self.active_item:joystickadded(joystick)
    end

    signal.emit("joystick-added", joystick)
end

function director:joystickremoved(joystick)
    if ISM then
        ISM:joystickremoved(joystick)
    end

    if self.active_item and self.active_item.joystickremoved then
        self.active_item:joystickremoved(joystick)
    end

    signal.emit("joystick-removed", joystick)
end

function director:resize(w, h)
    log.debug(">>>>>>>>> screen size changed to %s,%s", w, h)
    self:reset_screen_params()
end

function director:focus(focus)
    log.paranoid("++++++++++ focus changed to :%s ++++++++++", focus)

    if self.active_item and self.active_item.focus then
        self.active_item:focus(focus)
    end
end

director.skip_checks = {}

function director.skip_checks.check_skip_consent()
    return not PP:should_ask()
end

function director.skip_checks.check_skip_splash_custom()
    return not features.show_splash_custom
end

function director.skip_checks.check_skip_consent_simple()
    if not features.show_consent_simple then
        return true
    end

    local global = storage:load_global()

    if global.simple_privacy_policy_accepted then
        return true
    end

    return false
end

return director
