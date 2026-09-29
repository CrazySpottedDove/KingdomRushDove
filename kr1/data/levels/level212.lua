local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level212")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
P:deactivate_path(8)
P:deactivate_path(9)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
