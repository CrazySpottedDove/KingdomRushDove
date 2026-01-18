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
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(5,1,17)
P:add_invalid_range(6,1,17)
if store.level_mode==GAME_MODE_CAMPAIGN then
local controller_machinist
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_24_machinist" then
controller_machinist=e
break
end
end
local c_taunt=E:create_entity("taunts_s24_controller")
LU.queue_insert(store,c_taunt)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=200,y=450},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1.5)
controller_machinist.bossfight=true
local machinist
for _,e in pairs(store.entities) do
if e.template_name=="enemy_machinist" then
machinist=e
break
end
end
U.y_wait(store,2.3)
signal.emit("show-balloon_tutorial","LV24_MACHINIST_BEFORE_BOSSFIGHT_01",false)
U.y_wait(store,3)
signal.emit("show-balloon_tutorial","LV24_MACHINIST_BEFORE_BOSSFIGHT_02",false)
U.y_wait(store,2)
local boss=E:create_entity("boss_machinist")
boss.nav_path.pi=7
boss.nav_path.spi=1
boss.nav_path.ni=10
boss.pos=P:node_pos(7,1,10)
boss.tween.ts=store.tick_ts
boss.vis._bans=boss.vis.bans
boss.vis.bans=F_ALL
LU.queue_insert(store,boss)
U.y_wait(store,2.5)
while machinist and not machinist.ended_cinematic do
coroutine.yield()
end
coroutine.yield()
U.y_wait(store,1)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=400,y=384},1.5)
signal.emit("show-gui")
signal.emit("end-cinematic")
while not boss.health.dead do
coroutine.yield()
end
signal.emit("boss_fight_end")
local cam_pos=V.vclone(boss.pos)
cam_pos.y=cam_pos.y+100
signal.emit("pan-zoom-camera",1.5,cam_pos,2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,7)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="11"
end)[1]
holder.tower.upgrade_to="tower_dwarf_lvl4"
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
