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
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_boss_princess_iron_fan_waves" then
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
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
if not store.restarted and not main.params.skip_cutscenes then
store.main_hero.nav_grid.waypoints={}
local hero_path=10
local hero_subpath=1
local hero_move_start_node=P:nearest_nodes(23,463,{hero_path},{hero_subpath},false)[1]
local hero_move_end_node=P:nearest_nodes(295,400,{hero_path},{hero_subpath},false)[1]
for ni=hero_move_start_node[3],hero_move_end_node[3],-3 do
local pos=P:node_pos(hero_path,hero_subpath,ni)
table.insert(store.main_hero.nav_grid.waypoints,pos)
end
store.main_hero.nav_rally.new=true
store.main_hero.nav_rally.center=V.vclone(store.main_hero.nav_grid.waypoints[#store.main_hero.nav_grid.waypoints])
store.main_hero.nav_rally.pos=V.vclone(store.main_hero.nav_rally.center)
local old_vo=table.deepclone(store.main_hero.sound_events.change_rally_point)
store.main_hero.sound_events.change_rally_point=nil
signal.emit("pan-zoom-camera",4,{x=512,y=384},OVtargets(nil,1.2))
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
controller_boss_prefight:force_go_middle(store)
U.y_wait(store,4)
y_do_boss_taunt("LV34_BOSS_INTRO_01")
while U.flag_has(store.main_hero.vis.bans,controller_boss_prefight.stun_hero_vis_flags) do
coroutine.yield()
end
controller_boss_prefight:force_capture_hero(store.main_hero)
U.y_wait(store,5)
controller_boss_prefight:force_go_back(store)
U.y_wait(store,6)
store.main_hero.sound_events.change_rally_point=old_vo
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.do_boss_unit_spawn=true
while not self.bossfight_ended do
coroutine.yield()
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
