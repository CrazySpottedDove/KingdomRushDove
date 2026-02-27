local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("all.storage")
require("all.constants")
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
store.game_gui:set_boss(overseer)
U.insert_insert_hook(store,overseer.id,function(this,store)
if this.enemy and this.enemy.gold then
this.enemy.gold=math.ceil(this.enemy.gold*2.5)
if this.enemy.gold==0 then
this.enemy.gold=2
end
end
end)
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
U.y_wait(store,3-2)
signal.emit("fade-out",0.5,{0,0,0,255})
U.y_wait(store,0.5)
store.waves_finished=true
store.level.run_complete=true
end
end
return level
