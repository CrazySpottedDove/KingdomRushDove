local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils_5")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=22
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local overseer=table.filter(store.entities,function(k,v)
return v.template_name=="controller_stage_16_overseer"
end)[1]
while not store.waves_finished or LU.has_alive_enemies(store) do
if overseer.health.dead then
break
end
coroutine.yield()
end
S:stop_group("MUSIC")
U.y_wait(store,15)
signal.emit("fade-out",1,{255,255,255,255})
U.y_wait(store,1)
signal.emit("hide-curtains")
U.y_wait(store,3)
signal.emit("fade-out",0.5,{0,0,0,255})
U.y_wait(store,0.5)
store.waves_finished=true
store.level.run_complete=true
store.custom_game_outcome={postpone_unload=true,next_item_name="kr5_end"}
end
end
return level
