local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(5)
LU.insert_hero(store,"hero_stage_205_alleria",V.v(620,270))
local signal=require("lib.hump.signal")
signal.emit("show-balloon_tutorial-pos","S05_INTRO_01",false,V.v(620,320))
U.y_wait(store,2)
signal.emit("show-balloon_tutorial-pos","S05_INTRO_02",false,V.v(620,320))
U.y_wait(store,2)
local upper_path
for k,vv in pairs(store.entities) do
if vv.template_name=="decal_stage_205_upper_path" then
upper_path=vv
break
end
end
while store.wave_group_number<9 do
coroutine.yield()
end
upper_path.goblin_out=true
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
for k,vv in pairs(store.level.ignore_walk_backwards_paths) do
if vv==5 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
P:activate_path(5)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
