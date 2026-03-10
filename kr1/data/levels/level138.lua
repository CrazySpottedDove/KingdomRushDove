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
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=21
end
end
function level:load(store)
return
end
function level:update(store)
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
P:add_invalid_range(1,60,90,nil)
P:add_invalid_range(2,60,85,nil)
P:add_invalid_range(3,60,85,nil)
P:add_invalid_range(4,60,85,nil)
if store.level_mode==GAME_MODE_CAMPAIGN then
local controller_cinematic
for _,v in pairs(store.entities) do
if v.template_name=="controller_stage_38_cinematic" then
controller_cinematic=v
end
end
local function y_do_boss_taunt(key)
while controller_cinematic.current_taunt do
coroutine.yield()
end
controller_cinematic.do_taunt=key
while controller_cinematic.last_taunt~=key do
coroutine.yield()
end
end
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("pan-zoom-camera",0,{x=800,y=344},1.8)
local fly_hero=U.flag_has(store.main_hero.vis.flags,F_FLYING)
store.main_hero.pos.x=445
store.main_hero.pos.y=340
store.main_hero.nav_rally.center=V.vclone(store.main_hero.pos)
store.main_hero.nav_rally.pos=store.main_hero.nav_rally.center
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local wait_until_ts=store.tick_ts+3
while wait_until_ts>store.tick_ts do
coroutine.yield()
end
signal.emit("pan-zoom-camera",3,{x=690,y=404},OVtargets(nil,1.17,1.17,1,1.2))
U.y_wait(store,4)
if fly_hero then
y_do_boss_taunt("LV38_INTRO_TAUNT_FLY_01")
else
y_do_boss_taunt("LV38_INTRO_TAUNT_01")
end
U.y_wait(store,4)
if fly_hero then
y_do_boss_taunt("LV38_INTRO_TAUNT_FLY_02")
else
y_do_boss_taunt("LV38_INTRO_TAUNT_02")
end
U.y_wait(store,3)
signal.emit("pan-zoom-camera",2,{x=400,y=380},1)
U.y_wait(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
end
else
local controller
for _,v in pairs(store.entities) do
if v.template_name=="stage_38_paths_controller" then
controller=v
break
end
end
controller.modos=true
P:activate_path(4)
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="43"
end)[1]
holder.tower.upgrade_to="tower_pandas_lvl4"
coroutine.yield()
store.player_gold=starting_gold
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
