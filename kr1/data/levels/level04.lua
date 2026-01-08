local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
if store.selected_hero and store.selected_hero=="hero_gerald" then
signal.emit("wave-notification","icon","TIP_HEROES")
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
end
return level
