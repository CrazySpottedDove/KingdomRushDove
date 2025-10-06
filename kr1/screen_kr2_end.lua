-- chunkname: @/var/folders/r9/xbxmw8n51957gv9ggzrytvf80000gp/T/com.ironhidegames.frontiers.windows.steam.ep3S4swo/kr2/screen_kr2_end.lua
require("klove.kui")

local S = require("sound_db")
local screen_comics = require("screen_comics")
local screen_credits = require("screen_credits")
local screen = {}

screen.required_sounds = {"common", "music_screen_kr2_end"}
screen.required_textures = {"loading_common", "screen_credits", "kr2_comic"}
screen.ref_h = GUI_REF_H

if KR_TARGET == "console" then
    screen.ref_res = TEXTURE_SIZE_ALIAS.fullhd * 0.5
elseif KR_TARGET == "tablet" then
    screen.ref_res = TEXTURE_SIZE_ALIAS.ipad * 1.4222222222222223
elseif KR_TARGET == "phone" then
    screen.ref_res = TEXTURE_SIZE_ALIAS.iphone
else
    screen.ref_res = TEXTURE_SIZE_ALIAS.ipad
end

function screen:init(sw, sh, done_callback)
    self.sw = sw
    self.sh = sh
    self.done_callback = done_callback
    self.phase = "comic5"

    self:next_item()
end

function screen:update(dt)
    if self.active_screen then
        self.active_screen:update(dt)
    end
end

function screen:destroy()
    screen_comics:destroy()
    screen_credits:destroy()
end

function screen:draw()
    if self.active_screen then
        self.active_screen:draw()
    end
end

function screen:keypressed(key, isrepeat)
    if self.active_screen then
        self.active_screen:keypressed(key, isrepeat)
    end
end

function screen:mousepressed(x, y, button)
    if self.active_screen then
        self.active_screen:mousepressed(x, y, button)
    end
end

function screen:mousereleased(x, y, button)
    if self.active_screen then
        self.active_screen:mousereleased(x, y, button)
    end
end

function screen:gamepadpressed(joystick, button)
    if self.active_screen and self.active_screen.gamepadpressed then
        self.active_screen:gamepadpressed(joystick, button)
    end
end

function screen:next_item()
    local function cb()
        self:next_item()
    end

    if self.phase == "comic5" then
        S:queue("MusicEndVictory", {
            loop = false
        })

        screen_comics.comic_data = love.filesystem.read(KR_PATH_GAME_TARGET .. "/data/comics/07.csv")
        screen_comics.fade_in = {1, {255, 255, 255, 255}}
        screen_comics.level_idx = nil

        screen_comics:init(self.sw, self.sh, cb)

        self.active_screen = screen_comics
        self.phase = "credits"
    elseif self.phase == "credits" then
        S:queue("MusicEndCredits2", {
            loop = false
        })
        screen_credits:init(self.sw, self.sh, cb, true)

        self.active_screen = screen_credits
        self.phase = "comic6"
    elseif self.phase == "comic6" then
        S:queue("MusicSuspense")

        screen_comics.comic_data = love.filesystem.read(KR_PATH_GAME_TARGET .. "/data/comics/08.csv")

        screen_comics:init(self.sw, self.sh, cb)

        self.active_screen = screen_comics
        self.phase = "done"
    else
        S:stop_all()

        self.active_screen = nil

        self.done_callback({
            level_idx = 37,
            next_item_name = "map"
        })
    end
end

return screen
