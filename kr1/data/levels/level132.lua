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
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_32_boss" then
controller_boss_prefight=e
end
end
local function y_do_boss_taunt(key)
while controller_boss_prefight.current_taunt do
coroutine.yield()
end
controller_boss_prefight.do_taunt=key
while controller_boss_prefight.last_taunt~=key do
coroutine.yield()
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("pan-zoom-camera",0.5,{x=512,y=450},1.65)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
y_do_boss_taunt("LV32_BOSS_INTRO_01")
y_do_boss_taunt("LV32_BOSS_INTRO_02")
controller_boss_prefight.end_intro=true
U.y_wait(store,1.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=533,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic",true)
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
controller_boss_prefight.restarted=true
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.in_bossfight=true
while not self.bossfight_ended do
coroutine.yield()
end
controller_boss_prefight.do_boss_death=true
while not controller_boss_prefight.boss_death_ended do
coroutine.yield()
end
signal.emit("hide-curtains")
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_mage_3"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="47"
end)[1]
holder.tower.upgrade_to="tower_archer_3"
coroutine.yield()
store.player_gold=starting_gold
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
