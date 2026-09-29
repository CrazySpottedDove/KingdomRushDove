local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local GR=require("grid_db")
local V=require("lib.klua.vector")
local km=require("lib.klua.macros")
local log=require("lib.klua.log"):new("level214")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
