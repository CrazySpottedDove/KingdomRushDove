local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:update(store)
P:add_invalid_range(1,P:get_start_node(1),P:get_start_node(1)+85,bit.bor(NF_RALLY,NF_TWISTER))
P:add_invalid_range(5,P:get_start_node(5),P:get_start_node(5)+70,bit.bor(NF_RALLY,NF_TWISTER))
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",0,{x=740,y=900},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local c_taunt=E:create_entity("taunts_s115_controller")
LU.queue_insert(store,c_taunt)
local cult_leader_tower=E:create_entity("controller_stage_15_cult_leader_tower")
cult_leader_tower.pos=V.v(986,436)
cult_leader_tower.taunts=c_taunt.taunts
LU.queue_insert(store,cult_leader_tower)
local easter_egg_goblin=E:create_entity("decal_stage_15_easter_egg_goblin")
easter_egg_goblin.pos=V.v(910,500)
easter_egg_goblin.cult_leader_tower=cult_leader_tower
LU.queue_insert(store,easter_egg_goblin)
U.y_wait(store,1)
S:queue("Stage15MydriasEnter")
U.y_animation_play(cult_leader_tower,"enter",nil,store.tick_ts)
U.animation_start(cult_leader_tower,"idleup",nil,store.tick_ts,true)
U.y_wait(store,0.25)
signal.emit("show-balloon_tutorial","LV15_CULTIST01",false)
U.y_wait(store,4)
signal.emit("show-balloon_tutorial","LV15_CULTIST02",false)
U.y_wait(store,4)
S:queue("Stage15MydriasExit")
U.y_animation_play(cult_leader_tower,"leave",nil,store.tick_ts)
U.y_wait(store,0.25)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=400,y=400},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
U.y_wait(store,1.3)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
E:set_template("user_power_2",E:get_template("power_denas_control"))
cult_leader_tower.transform_out=true
while not cult_leader_tower.boss_dead do
coroutine.yield()
end
if cult_leader_tower.soldiers_grabbed==0 then
signal.emit("no_soldiers_grabbed-stage15")
end
signal.emit("boss_fight_end")
signal.emit("fade-out",1)
elseif store.level_mode==GAME_MODE_IRON then
E:set_template("user_power_2",E:get_template("power_denas_control"))
signal.emit("change_power_button","power_button_2","bottom_powers_icons_0002")
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="2"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="7"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
coroutine.yield()
store.player_gold=starting_gold
end
end
return level
