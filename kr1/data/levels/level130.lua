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
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local boss_controller
if not store.restarted then
signal.emit("pan-zoom-camera",0,{x=533,y=600},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1)
boss_controller=E:create_entity("controller_stage_30_boss_spiders")
boss_controller.pos=V.v(512,384)
LU.queue_insert(store,boss_controller)
U.y_wait(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_01"
U.y_wait(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_02"
U.y_wait(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_03"
U.y_wait(store,2.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=533,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
boss_controller=E:create_entity("controller_stage_30_boss_spiders")
boss_controller.restarted=true
boss_controller.pos=V.v(512,384)
LU.queue_insert(store,boss_controller)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=533,y=800},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,3.5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_01"
U.y_wait(store,5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_02"
U.y_wait(store,5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_03"
U.y_wait(store,2.5)
boss_controller.do_exit=true
U.y_wait(store,7)
S:stop_group("MUSIC")
S:queue("MusicBossFight_130")
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,4)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_IRON then
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="45"
end)[1]
holder.tower.upgrade_to="tower_sparking_geode_lvl4"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_sparking_geode_lvl4"
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
