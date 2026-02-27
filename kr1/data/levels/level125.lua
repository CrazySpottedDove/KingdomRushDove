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
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(1,P:get_end_node(1)-5,P:get_end_node(1))
P:add_invalid_range(2,P:get_end_node(2)-15,P:get_end_node(2))
P:add_invalid_range(3,P:get_end_node(3)-5,P:get_end_node(3))
P:add_invalid_range(4,P:get_end_node(4)-15,P:get_end_node(4))
P:add_invalid_range(5,P:get_end_node(5)-5,P:get_end_node(5))
P:add_invalid_range(6,P:get_end_node(6)-15,P:get_end_node(6))
if store.level_mode==GAME_MODE_CAMPAIGN then
local c_taunt=E:create_entity("taunts_s25_controller")
LU.queue_insert(store,c_taunt)
signal.emit("pan-zoom-camera",1.5,{x=550,y=500},1.3)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,fts(23))
S:queue("Stage25IntroCrash")
U.y_wait(store,fts(22))
local dwarf_intro=E:create_entity("decal_stage_25_dwarf_intro")
dwarf_intro.render.sprites[1].ts=store.tick_ts
dwarf_intro.pos=V.v(512,384)
LU.queue_insert(store,dwarf_intro)
U.animation_start(dwarf_intro,"in",nil,store.tick_ts)
U.y_wait(store,fts(60))
dwarf_intro.render.sprites[1].z=Z_DECALS
U.y_wait(store,fts(110))
S:queue("Stage25IntroCrashFinalExplosion")
U.y_animation_wait(dwarf_intro)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=480,y=384},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
local torso,controller_torso
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_25_torso" then
torso=e
end
if e.template_name=="controller_stage_25_torso" then
controller_torso=e
end
end
LU.queue_remove(store,controller_torso)
if torso.render.sprites[1].name~="name" then
U.y_animation_wait(torso)
end
signal.emit("pan-zoom-camera",1.5,{x=550,y=500},1.3)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_animation_play(torso,"out",nil,store.tick_ts,1)
U.animation_start(torso,"out_loop",nil,store.tick_ts,true)
signal.emit("show-balloon_tutorial","LV25_MACHINIST_END_01",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV25_MACHINIST_END_02",false)
U.y_wait(store,3.5)
S:queue("Stage25Outro")
U.y_animation_play(torso,"eject",nil,store.tick_ts,1)
signal.emit("hide-curtains")
signal.emit("end-cinematic")
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="5"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="11"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
