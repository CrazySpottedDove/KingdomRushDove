local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local signal=require("lib.hump.signal")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("wave-notification","view","TOWER_CULVERINE")
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
