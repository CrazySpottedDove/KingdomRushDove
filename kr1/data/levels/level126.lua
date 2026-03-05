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
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local c_taunt=E:create_entity("taunts_s26_controller")
LU.queue_insert(store,c_taunt)
local boss_decal,bubbles,fist_spawner,fist_spawner_light
for i,v in pairs(store.entities) do
if v.template_name=="decal_stage_26_boss" then
boss_decal=v
end
if v.template_name=="decal_stage_26_bubbles" then
bubbles=v
end
if v.template_name=="decal_stage_26_fist_spawner" then
fist_spawner=v
end
if v.template_name=="decal_stage_26_fist_spawner_light" then
fist_spawner_light=v
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=200,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1.5)
signal.emit("show-balloon_tutorial","LV26_GRYMBEARD_BEFORE_BOSSFIGHT_01",false)
S:queue("Stage26PreBFCinematic")
U.y_animation_play(boss_decal,"grab",nil,store.tick_ts,1)
U.y_animation_play(boss_decal,"controlling_hand",nil,store.tick_ts,1)
U.animation_start(fist_spawner,"door_open",nil,store.tick_ts,false)
U.y_animation_play(boss_decal,"controlling_hand",nil,store.tick_ts,1)
U.animation_start(fist_spawner,"idle_2",nil,store.tick_ts,true)
U.animation_start(fist_spawner_light,"run",nil,store.tick_ts,true)
U.y_animation_play(boss_decal,"return_idle",nil,store.tick_ts,1)
signal.emit("show-balloon_tutorial","LV26_GRYMBEARD_BEFORE_BOSSFIGHT_02",false)
U.animation_start(boss_decal,"machine_breakdown",nil,store.tick_ts,false)
U.y_wait(store,fts(135))
bubbles.render.sprites[1].hidden=false
U.y_animation_play(bubbles,"start",nil,store.tick_ts,1)
U.animation_start(bubbles,"loop",nil,store.tick_ts,true)
U.y_animation_wait(boss_decal)
U.animation_start(boss_decal,"loop",nil,store.tick_ts,true)
local boss=E:create_entity("boss_deformed_grymbeard")
LU.queue_insert(store,boss)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
while not boss.health.dead do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=200,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
boss_decal.render.sprites[1].prefix="DLC_Enanos_S4_Boss02Def"
S:queue("Stage26Outro")
U.animation_start(boss_decal,"death",nil,store.tick_ts,1)
U.y_wait(store,fts(20))
LU.queue_remove(store,bubbles)
U.y_wait(store,fts(60))
LU.kill_all_enemies(store,true,false)
U.y_animation_wait(boss_decal)
LU.kill_all_enemies(store,true,false)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
signal.emit("boss_fight_end")
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
