local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
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
level.show_comic_idx=18
end
end
function level:load(store)
local left_portal_invalid_nodes_pos=V.v(22,390)
local right_portal_invalid_nodes_pos=V.v(997,404)
level.path_invalid_nodes={[7]={first=0,last=P:nearest_nodes(left_portal_invalid_nodes_pos.x,left_portal_invalid_nodes_pos.y,{7})[1][3]},[15]={first=0,last=P:nearest_nodes(left_portal_invalid_nodes_pos.x,left_portal_invalid_nodes_pos.y,{15})[1][3]},[8]={first=0,last=P:nearest_nodes(right_portal_invalid_nodes_pos.x,right_portal_invalid_nodes_pos.y,{8})[1][3]}}
for pid,v in pairs(level.path_invalid_nodes) do
P:add_invalid_range(pid,v.first,v.last)
end
end
function level:update(store)
local fume_entradas
store.level.ignore_walk_backwards_paths={}
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_35_fume_entradas" then
fume_entradas=v
end
end
if store.level_mode==GAME_MODE_IRON then
LU.queue_remove(store,fume_entradas)
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="48"
end)[1]
holder.tower.upgrade_to="tower_rocket_gunners_lvl4"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="43"
end)[1]
holder.tower.upgrade_to="tower_rocket_gunners_lvl4"
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
if store.level_mode==GAME_MODE_HEROIC then
LU.queue_remove(store,fume_entradas)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local controller_boss_prefight,controller_redboy,controller_princess
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_35_bull_king" then
controller_boss_prefight=e
elseif e.template_name=="controller_stage_35_princess_powers" then
controller_princess=e
elseif e.template_name=="controller_stage_35_redboy_powers" then
controller_redboy=e
end
end
for i=12,15 do
local boss_path_start=P:nearest_nodes(555,270,{i})[1][3]
local boss_path_end=P:get_end_node(i)
P:add_invalid_range(i,boss_path_start,boss_path_end)
table.insert(store.level.ignore_walk_backwards_paths,i)
end
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",1,{x=512,y=500},OVtargets(nil,1.4))
U.y_wait(store,2)
controller_boss_prefight.do_taunt="LV35_BOSS_INTRO_01"
controller_princess.appear=true
U.y_wait(store,3.2)
signal.emit("pan-zoom-camera",1,{x=800,y=500},OVtargets(nil,1.2))
U.y_wait(store,1.5)
controller_redboy.appear=true
controller_princess.do_taunt="LV35_BOSS_INTRO_02"
U.y_wait(store,2.5)
signal.emit("pan-zoom-camera",1,{x=300,y=500},OVtargets(nil,1.2))
U.y_wait(store,1.5)
controller_redboy.do_taunt="LV35_BOSS_INTRO_03"
U.y_wait(store,2.5)
signal.emit("pan-zoom-camera",1,{x=512,y=382},OVtargets(nil,1))
U.y_wait(store,1.5)
fume_entradas.finish=true
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
else
LU.queue_remove(store,fume_entradas)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.summon_boss=true
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
