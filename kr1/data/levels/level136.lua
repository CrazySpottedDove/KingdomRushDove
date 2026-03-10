local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=20
end
end
function level:load(store)
return
end
function level:update(store)
for i=1,4 do
local invalid_range_end_ni=P:nearest_nodes(1025,505,{i})[1][3]
P:add_invalid_range(i,0,invalid_range_end_ni)
end
if store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_HEROIC then
local controller
for _,v in pairs(store.entities) do
if v.template_name=="stage_36_paths_controller" then
controller=v
break
end
end
controller.modos=true
P:activate_path(2)
P:activate_path(3)
P:activate_path(4)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
