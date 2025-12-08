local log=require("lib.klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.manual_hero_insertion=true
signal.emit("show-balloon","TB_START")
signal.emit("show-balloon","TB_BUILD")
signal.emit("wave-notification","view","TUTORIAL_1")
if store.selected_hero then
LU.insert_hero(store)
end
while store.wave_group_number<1 do
coroutine.yield()
end
self.show_next_wave_balloon=true
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
end
return level
