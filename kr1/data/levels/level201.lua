local LU=require("level_utils")
local P=require("path_db")
local U=require("utils")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
P:deactivate_path(2)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
U.y_wait(store,2)
end
function level:destroy(store)
end
return level
