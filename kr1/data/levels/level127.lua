local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(3,P:get_start_node(3),18)
P:add_invalid_range(4,P:get_start_node(4),18)
P:add_invalid_range(7,P:get_start_node(7),18)
P:add_invalid_range(5,P:get_start_node(5),45)
P:add_invalid_range(6,P:get_start_node(6),40)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",1.5,{x=600,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,9.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
local platform_c
for i,v in ipairs(store.entities) do
if v.template_name=="controller_stage_27_platform" then
platform_c=v
break
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=600,y=700},1.5)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local head_c
for i,v in ipairs(store.entities) do
if v.template_name=="controller_stage_27_head" then
head_c=v
break
end
end
head_c.events.list[7].on_event(head_c,store,"head_destroy")
U.y_wait(store,fts(370))
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
U.y_wait(store,fts(70))
S:stop_group("MUSIC")
S:queue("MusicBossFight_127")
U.y_wait(store,fts(80))
local boss
for i,v in pairs(store.entities) do
if v.template_name=="boss_grymbeard" then
boss=v
break
end
end
while not boss.bossfight_ended do
coroutine.yield()
end
if head_c.towers_stunned==0 then
signal.emit("head-stage27",nil)
end
U.y_wait(store,fts(80))
signal.emit("boss_fight_end")
signal.emit("fade-out",1)
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="6"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="9"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
