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
P:add_invalid_range(5,P:get_start_node(5),P:get_start_node(5)+5)
P:add_invalid_range(6,P:get_start_node(6),P:get_start_node(6)+5)
local statue
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_19_statue" then
statue=e
break
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
U.animation_start(statue,"idle_campaign",nil,store.tick_ts)
else
U.animation_start(statue,"idle_1",nil,store.tick_ts)
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local controller_pre_bossfight
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_19_navira" then
controller_pre_bossfight=e
break
end
end
local c_taunt=E:create_entity("taunts_s19_controller")
LU.queue_insert(store,c_taunt)
signal.emit("pan-zoom-camera",0,{x=800,y=800},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1)
controller_pre_bossfight.render.sprites[1].hidden=false
S:queue("Stage19NaviraEnter")
U.y_animation_play(controller_pre_bossfight,"teleport_in",true,store.tick_ts,1)
U.animation_start(controller_pre_bossfight,"idlecape",true,store.tick_ts,true,1,true)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_START_01",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_START_02",false)
U.y_wait(store,3.5)
U.animation_start(controller_pre_bossfight,"idlecapeout",true,store.tick_ts,false)
U.y_wait(store,fts(23.5))
local cape=E:create_entity(controller_pre_bossfight.cape_t)
cape.pos=V.vclone(controller_pre_bossfight.pos)
cape.render.sprites[1].ts=store.tick_ts
cape.tween.ts=store.tick_ts
LU.queue_insert(store,cape)
U.animation_start(cape,"run",true,store.tick_ts,true,1,true)
U.y_animation_wait(controller_pre_bossfight)
U.animation_start(controller_pre_bossfight,"idle",true,store.tick_ts,true,1,true)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_START_03",false)
U.y_wait(store,4)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=440,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=800,y=800},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1.5)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_BEFORE_BOSSFIGHT_01",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_BEFORE_BOSSFIGHT_02",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV19_NAVIRA_BEFORE_BOSSFIGHT_03",false)
U.y_wait(store,4)
controller_pre_bossfight.start_bossfight=true
while not controller_pre_bossfight.ended_entrance do
coroutine.yield()
end
local boss=E:create_entity("boss_navira")
boss.nav_path.pi=2
boss.nav_path.spi=1
boss.pos=V.v(765,424)
local node=P:nearest_nodes(boss.pos.x,boss.pos.y,{boss.nav_path.pi},{boss.nav_path.spi})[1]
local pi,spi,ni=unpack(node)
boss.nav_path.ni=ni
boss.render.sprites[1].hidden=true
LU.queue_insert(store,boss)
coroutine.yield()
controller_pre_bossfight.render.sprites[1].hidden=true
boss.render.sprites[1].hidden=false
coroutine.yield()
LU.queue_remove(store,controller_pre_bossfight)
U.y_wait(store,1)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
S:stop_group("MUSIC")
S:queue("MusicBossFight_119")
while not boss.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
signal.emit("fade-out",1)
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="1"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="4"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="11"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
coroutine.yield()
store.player_gold=starting_gold
end
end
return level
