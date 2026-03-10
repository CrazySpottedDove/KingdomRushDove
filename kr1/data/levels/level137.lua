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
return
end
function level:load(store)
return
end
function level:update(store)
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_37_dragon_boss" then
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
if not store.restarted and not main.params.skip_cutscenes then
store.main_hero.nav_grid.waypoints={}
local hero_path=1
local hero_subpath=1
local hero_move_start_node=P:nearest_nodes(61,555,{hero_path},{hero_subpath},false)[1]
local hero_move_end_node=P:nearest_nodes(420,450,{hero_path},{hero_subpath},false)[1]
local hero_end_pos=P:node_pos(hero_path,hero_subpath,hero_move_end_node[3])
for ni=hero_move_start_node[3],hero_move_end_node[3],-3 do
local pos=P:node_pos(hero_path,hero_subpath,ni)
table.insert(store.main_hero.nav_grid.waypoints,pos)
end
store.main_hero.nav_rally.new=true
store.main_hero.nav_rally.center=V.vclone(store.main_hero.nav_grid.waypoints[#store.main_hero.nav_grid.waypoints])
store.main_hero.nav_rally.pos=V.vclone(store.main_hero.nav_rally.center)
local old_vo=table.deepclone(store.main_hero.sound_events.change_rally_point)
store.main_hero.sound_events.change_rally_point=nil
local fly_hero=U.flag_has(store.main_hero.vis.flags,F_FLYING)
signal.emit("pan-zoom-camera",4,{x=700,y=384},OVtargets(nil,1.2))
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,4)
y_do_boss_taunt("LV37_BOSS_INTRO_01")
U.y_wait(store,1.8)
while V.dist(store.main_hero.pos.x,store.main_hero.pos.y,hero_end_pos.x,hero_end_pos.y)>10 do
coroutine.yield()
end
U.y_wait(store,0.2)
if fly_hero then
signal.emit("show-balloon_tutorial","LV37_BOSS_INTRO_HERO_FLYING",false)
else
signal.emit("show-balloon_tutorial","LV37_BOSS_INTRO_HERO",false)
end
U.y_wait(store,2)
signal.emit("pan-zoom-camera",2,{x=400,y=380},OVtargets(nil,1))
U.y_wait(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
store.main_hero.sound_events.change_rally_point=old_vo
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.do_boss_unit_spawn=true
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,1)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
else
local controller
for _,v in pairs(store.entities) do
if v.template_name=="stage_37_paths_controller" then
controller=v
break
end
end
controller.modos=true
P:activate_path(3)
P:activate_path(4)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
