local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local W=require("wave_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:preprocess(store)
return
end
function level:load(store)
return
end
function level:update(store)
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
for i=1,7 do
P:add_invalid_range(i,0,7,nil)
end
for i=8,15 do
P:add_invalid_range(i,0,7)
end
P:add_invalid_range(17,0,7)
for i=18,22 do
P:add_invalid_range(i,0,7,nil)
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local boss_controller
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_39_boss" then
boss_controller=e
break
end
end
U.mark_seen(store,"controller_stage_39_boss")
if not store.restarted and not main.params.skip_cutscenes then
local fly_hero=U.flag_has(store.main_hero.vis.flags,F_FLYING)
store.main_hero.render.sprites[1].flip_x=true
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",1,{x=530,y=1000},1.18)
U.y_wait(store,1.5)
if fly_hero then
signal.emit("show-balloon_tutorial","LV39_INTRO_TAUNT_FLY_01",false)
else
signal.emit("show-balloon_tutorial","LV39_INTRO_TAUNT_01",false)
end
U.y_wait(store,4.5)
boss_controller.do_taunt="LV39_INTRO_BOSS_TAUNT"
U.y_wait(store,3)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
boss_controller.start=true
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,1)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
end
end
return level
