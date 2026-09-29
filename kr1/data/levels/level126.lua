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
function level:init(store)
require("lib.klua.table")
local scripts=require("scripts")
local r=V.r
local controller_stage_26_spawners_update
local controller_stage_26_fist_spawner_update
local controller_stage_26_fist_spawner_hand_update
local controller_stage_26_clone_spawner_update
local controller_stage_26_hulk_spawner_update
local controller_stage_26_hulk_spawner_on_event
local decal_stage_26_mewtwo_update
local decal_stage_26_modes_decos_update
controller_stage_26_spawners_update=function(this,store)
local fist_spawner_c,clone_spawner_c_left,clone_spawner_c_right,tube_left,tube_right,clone_spawner_left,clone_spawner_right,hulk_spawner_c
for i,v in pairs(store.entities) do
if v.template_name==this.fist_spawner_controller_t then
fist_spawner_c=v
end
if v.template_name==this.clone_spawner_controller_t then
if not clone_spawner_c_left then
clone_spawner_c_left=v
else
clone_spawner_c_right=v
end
end
if v.template_name==this.tube_left_t then
tube_left=v
end
if v.template_name==this.tube_right_t then
tube_right=v
end
if v.template_name==this.clone_spawner_t then
if not clone_spawner_left then
clone_spawner_left=v
elseif clone_spawner_left.pos.x<v.pos.x then
clone_spawner_right=v
else
clone_spawner_right=clone_spawner_left
clone_spawner_left=v
end
end
if v.template_name==this.hulk_spawner_controller_t then
hulk_spawner_c=v
end
end
clone_spawner_c_left.spawner_decal=clone_spawner_left
clone_spawner_c_left.tube_decal=tube_left
clone_spawner_c_right.spawner_decal=clone_spawner_right
clone_spawner_c_right.tube_decal=tube_right
while store.wave_group_number==0 do
coroutine.yield()
end
local last_wave=0
local start_wave_ts=store.tick_ts
local last_index_processed=0
local function get_wave_data_index(current_wave_data)
for index,wave_data in ipairs(current_wave_data) do
if index>last_index_processed and wave_data.time_start+fts(30)>store.tick_ts-start_wave_ts then
return index
end
end
return nil
end
while true do
local current_wave=store.wave_group_number
local current_wave_data=this.wave_config[store.level_mode][current_wave]
if current_wave~=last_wave then
last_wave=current_wave
start_wave_ts=store.tick_ts
last_index_processed=0
end
if current_wave_data and #current_wave_data>0 then
if store.waves_finished then
simulation:queue_remove_entity(fist_spawner_c)
simulation:queue_remove_entity(clone_spawner_c_left)
simulation:queue_remove_entity(clone_spawner_c_right)
return
end
local next_index_to_check=get_wave_data_index(current_wave_data)
if next_index_to_check and next_index_to_check~=last_index_processed then
local wave_data=current_wave_data[next_index_to_check]
if store.tick_ts-start_wave_ts>=wave_data.time_start then
if wave_data.spawner=="fist" then
if wave_data.action=="open" then
fist_spawner_c.open=true
fist_spawner_c.fists=wave_data.count
else
fist_spawner_c.close=true
end
elseif wave_data.spawner=="clone_left" then
if wave_data.action=="open" then
clone_spawner_c_left.open=true
else
clone_spawner_c_left.close=true
end
elseif wave_data.spawner=="clone_right" then
if wave_data.action=="open" then
clone_spawner_c_right.open=true
else
clone_spawner_c_right.close=true
end
elseif wave_data.spawner=="hulk" and wave_data.action=="activate" then
hulk_spawner_c.activate=true
end
last_index_processed=next_index_to_check
end
end
end
coroutine.yield()
end
end
controller_stage_26_fist_spawner_update=function(this,store)
local boss,hand_c
for i,v in pairs(store.entities) do
if v.template_name==this.boss_t then
boss=v
end
if v.template_name==this.hand_controller_t then
hand_c=v
end
end
while true do
if this.open then
if boss then
U.y_animation_play(boss,"grab",nil,store.tick_ts,1)
end
hand_c.open=true
hand_c.fists=this.fists
if boss then
U.y_animation_play(boss,"controlling_hand",nil,store.tick_ts,this.fists)
U.y_animation_play(boss,"return_idle",nil,store.tick_ts,false)
U.animation_start_default(boss,"idle",nil,store.tick_ts,true)
end
this.open=false
end
if this.close then
hand_c.close=true
this.close=false
end
coroutine.yield()
end
end
controller_stage_26_fist_spawner_hand_update=function(this,store)
local fist_spawner,fist_spawner_light
for i,v in pairs(store.entities) do
if v.template_name==this.fist_spawner_t then
fist_spawner=v
end
if v.template_name==this.fist_spawner_light_t then
fist_spawner_light=v
end
end
while true do
if this.open then
S:queue(this.sound_hand)
U.y_animation_play(fist_spawner,"hand_start",nil,store.tick_ts,1)
for i=1,this.fists-1 do
S:queue(this.sound_hand)
U.y_animation_play(fist_spawner,"hand_loop",nil,store.tick_ts,1)
end
U.y_animation_play(fist_spawner,"hand_end",nil,store.tick_ts,1)
S:queue(this.sound_open)
U.y_animation_play(fist_spawner,"door_open",nil,store.tick_ts,1)
U.animation_start_default(fist_spawner,"idle_2",nil,store.tick_ts,true)
U.animation_start_default(fist_spawner_light,"run",nil,store.tick_ts,true)
this.open=false
end
if this.close then
U.animation_start_default(fist_spawner_light,"idle",nil,store.tick_ts,true)
S:queue(this.sound_close)
U.y_animation_play(fist_spawner,"door_close",nil,store.tick_ts,1)
U.animation_start_default(fist_spawner,"idle_1",nil,store.tick_ts,true)
this.close=false
end
coroutine.yield()
end
end
controller_stage_26_clone_spawner_update=function(this,store)
local boss
for i,v in pairs(store.entities) do
if v.template_name==this.boss_t then
boss=v
end
end
while true do
if this.open then
if boss then
S:queue(this.sound_chain)
U.y_animation_play(boss,"elevator_spawning",nil,store.tick_ts,1)
end
U.y_animation_play(this.tube_decal,"run",nil,store.tick_ts,1)
U.animation_start_default(this.tube_decal,"idle",nil,store.tick_ts,true)
S:queue(this.sound_in)
U.y_animation_play(this.spawner_decal,"run",nil,store.tick_ts,1)
U.animation_start_default(this.spawner_decal,"idle_2",nil,store.tick_ts,true)
this.open=false
end
if this.close then
S:queue(this.sound_out)
U.y_animation_play(this.spawner_decal,"reset",nil,store.tick_ts,1)
U.animation_start_default(this.spawner_decal,"idle_1",nil,store.tick_ts,true)
this.close=false
end
coroutine.yield()
end
end
controller_stage_26_hulk_spawner_update=function(this,store)
local spawner_decal
for i,v in pairs(store.entities) do
if v.template_name==this.hulk_spawner_t then
spawner_decal=v
break
end
end
while true do
if this.activate then
U.animation_start_default(spawner_decal,"run",nil,store.tick_ts,false)
U.y_wait_unconditional(store,5.5)
S:queue(this.sound_shot)
U.y_wait_unconditional(store,this.hulk_spawn_delay-5.5)
local hulk=E:create_entity(this.hulk_t)
hulk.nav_path.pi=this.path_to_spawn
hulk.nav_path.ni=1
hulk.nav_path.spi=1
hulk.pos=P:node_pos(this.path_to_spawn,1,1)
hulk.source_id=this.id
simulation:queue_insert_entity(hulk)
U.y_animation_wait_default(spawner_decal)
U.y_wait_unconditional(store,fts(60))
U.y_animation_play(spawner_decal,"reset",nil,store.tick_ts,1)
U.animation_start_default(spawner_decal,"idle",nil,store.tick_ts,true)
this.activate=false
end
coroutine.yield()
end
end
controller_stage_26_hulk_spawner_on_event=function(this,store)
this.activate=true
end
decal_stage_26_mewtwo_update=function(this,store)
local taps=0
U.animation_start_default(this,"idle_1",nil,store.tick_ts,true)
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
taps=taps+1
if taps<3 then
S:queue(this.sound_1_2)
else
S:queue(this.sound_3)
S:queue(this.sound_end,{delay=1})
end
U.y_animation_play(this,"touch_"..taps,nil,store.tick_ts,1)
if taps>=3 then
local mewtwo=E:create_entity(this.mewtwo_t)
mewtwo.pos=V.vclone(this.pos)
mewtwo.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(mewtwo)
U.animation_start_default(mewtwo,"spawn",nil,store.tick_ts,false)
U.y_animation_play(this,"idle_4",nil,store.tick_ts,1)
U.y_animation_wait_default(mewtwo)
signal.emit("mewtwo-stage26",this)
else
this.ui.can_click=true
U.animation_start_default(this,"idle_"..taps+1,nil,store.tick_ts,true)
end
end
coroutine.yield()
end
end
decal_stage_26_modes_decos_update=function(this,store)
local cd=math.random(3,7)
while true do
U.y_wait_unconditional(store,cd)
U.y_animation_play(this,"action_"..math.random(1,2),nil,store.tick_ts)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
cd=math.random(3,7)
end
end
local tt
tt=E:register_t_hot("decal_stage_26_bubbles","decal",true)
tt.render.sprites[1].prefix="DLC_Enanos_S4_BubblesDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("controller_stage_26_fist_spawner_hand",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_26_fist_spawner_hand_update
tt.fist_spawner_t="decal_stage_26_fist_spawner"
tt.fist_spawner_light_t="decal_stage_26_fist_spawner_light"
tt.sound_hand="Stage26FistSpawnerHand"
tt.sound_open="Stage26FistSpawnerBoothFrontDoorOpen"
tt.sound_close="Stage26FistSpawnerBoothFrontDoorClose"
tt=E:register_t_hot("decal_stage_26_foreground_2","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_foreground_b"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_26_modes_decos","decal_scripted",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="DLCstage4_deco_modosDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=decal_stage_26_modes_decos_update
tt=E:register_t_hot("controller_stage_26_hulk_spawner",nil,true)
E:add_comps(tt,"main_script","events")
tt.main_script.update=controller_stage_26_hulk_spawner_update
tt.hulk_spawner_t="decal_stage_26_hulk_spawner"
tt.hulk_t="enemy_darksteel_hulk"
tt.hulk_spawn_delay=fts(322)
tt.path_to_spawn=9
tt.events.list[1].name="hulk_spawn"
tt.events.list[1].on_event=controller_stage_26_hulk_spawner_on_event
tt.sound_shot="Stage26HulkSpawnerShotTransform"
tt=E:register_t_hot("decal_stage_26_mask_5","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_mask_5"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_stage_26_gears_front","decal",true)
tt.render.sprites[1].prefix="DLC_Enanos_S4_GearsDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("controller_stage_26_spawners",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_26_spawners_update
tt.wave_config={{{},{},{{action="open",time_start=8,spawner="fist",count=2},{action="close",time_start=17,spawner="fist"},{action="open",time_start=18,spawner="fist",count=2},{action="close",time_start=27,spawner="fist"}},{},{{action="open",time_start=1,spawner="clone_left"},{action="open",time_start=6,spawner="fist",count=2},{action="close",time_start=11,spawner="clone_left"},{action="close",time_start=16,spawner="fist"},{action="open",time_start=18,spawner="clone_left"},{action="close",time_start=38,spawner="clone_left"}},{{action="activate",time_start=1,spawner="hulk"},{action="open",time_start=4,spawner="fist",count=4},{action="close",time_start=25,spawner="fist"}},{{action="open",time_start=1,spawner="clone_right"},{action="close",time_start=9,spawner="clone_right"},{action="open",time_start=10,spawner="clone_right"},{action="close",time_start=19,spawner="clone_right"},{action="open",time_start=23,spawner="clone_right"},{action="close",time_start=32,spawner="clone_right"}},{{action="open",time_start=1,spawner="clone_left"},{action="open",time_start=4,spawner="fist",count=2},{action="close",time_start=13,spawner="fist"},{action="close",time_start=11,spawner="clone_left"},{action="open",time_start=12,spawner="clone_left"},{action="open",time_start=14,spawner="fist",count=4},{action="close",time_start=24,spawner="clone_left"},{action="open",time_start=26,spawner="clone_left"},{action="close",time_start=30,spawner="fist"},{action="close",time_start=36,spawner="clone_left"}},{{action="activate",time_start=1,spawner="hulk"}},{{action="activate",time_start=1,spawner="hulk"}},{{action="open",time_start=2,spawner="fist",count=4},{action="open",time_start=9,spawner="clone_right"},{action="close",time_start=18,spawner="fist"},{action="close",time_start=19,spawner="clone_right"},{action="open",time_start=31,spawner="fist",count=4},{action="open",time_start=38,spawner="clone_right"},{action="close",time_start=47,spawner="fist"},{action="close",time_start=48,spawner="clone_right"}},{{action="open",time_start=1,spawner="fist",count=2},{action="open",time_start=4,spawner="clone_left"},{action="close",time_start=10,spawner="fist"},{action="close",time_start=15,spawner="clone_left"},{action="open",time_start=16,spawner="fist",count=2},{action="open",time_start=20,spawner="clone_left"},{action="close",time_start=26,spawner="fist"},{action="close",time_start=31,spawner="clone_left"}},{{action="activate",time_start=1,spawner="hulk"},{action="open",time_start=3,spawner="clone_right"},{action="close",time_start=14,spawner="clone_right"},{action="activate",time_start=20,spawner="hulk"},{action="open",time_start=26,spawner="clone_right"},{action="close",time_start=38,spawner="clone_right"}},{{action="open",time_start=1,spawner="clone_left"},{action="open",time_start=3,spawner="clone_right"},{action="open",time_start=5,spawner="fist",count=4},{action="close",time_start=13,spawner="clone_left"},{action="close",time_start=14,spawner="clone_right"},{action="open",time_start=15,spawner="clone_left"},{action="open",time_start=17,spawner="clone_right"},{action="close",time_start=20.5,spawner="fist"},{action="open",time_start=20.5,spawner="fist",count=4},{action="close",time_start=28,spawner="clone_left"},{action="close",time_start=30,spawner="clone_right"},{action="close",time_start=37,spawner="fist"},{action="open",time_start=38,spawner="clone_left"},{action="open",time_start=40,spawner="clone_right"},{action="close",time_start=48,spawner="clone_left"},{action="close",time_start=50,spawner="clone_right"}},{{action="open",time_start=1,spawner="fist",count=4},{action="activate",time_start=3,spawner="hulk"},{action="close",time_start=16,spawner="fist"},{action="open",time_start=23,spawner="fist",count=4},{action="activate",time_start=27,spawner="hulk"},{action="close",time_start=38,spawner="fist"},{action="open",time_start=48,spawner="fist",count=4},{action="activate",time_start=52,spawner="hulk"},{action="close",time_start=63,spawner="fist"}}},{{},{{action="open",time_start=0,spawner="fist",count=4},{action="close",time_start=16,spawner="fist"},{action="open",time_start=34,spawner="fist",count=4},{action="close",time_start=50,spawner="fist"}},{{action="activate",time_start=0,spawner="hulk"},{action="open",time_start=4,spawner="clone_right"},{action="close",time_start=15,spawner="clone_right"},{action="open",time_start=33,spawner="clone_right"},{action="close",time_start=43,spawner="clone_right"},{action="open",time_start=53,spawner="clone_right"},{action="close",time_start=63,spawner="clone_right"}},{{action="activate",time_start=0,spawner="hulk"}},{{action="open",time_start=0,spawner="fist",count=4},{action="open",time_start=7,spawner="clone_left"},{action="close",time_start=16,spawner="fist"},{action="open",time_start=21,spawner="fist",count=4},{action="close",time_start=23,spawner="clone_left"},{action="open",time_start=28,spawner="clone_left"},{action="close",time_start=37,spawner="fist"},{action="close",time_start=42,spawner="clone_left"}},{{action="open",time_start=0,spawner="fist",count=4},{action="activate",time_start=10,spawner="hulk"},{action="close",time_start=16,spawner="fist"},{action="open",time_start=34,spawner="clone_left"},{action="activate",time_start=56,spawner="hulk"},{action="close",time_start=62,spawner="clone_left"},{action="activate",time_start=74,spawner="hulk"},{action="open",time_start=76,spawner="fist",count=4},{action="close",time_start=92,spawner="fist"}}},{{{action="open",time_start=1,spawner="clone_left"},{action="close",time_start=9,spawner="clone_left"},{action="open",time_start=15,spawner="clone_left"},{action="close",time_start=24,spawner="clone_left"},{action="open",time_start=54,spawner="clone_left"},{action="close",time_start=64,spawner="clone_left"},{action="open",time_start=80,spawner="fist",count=6},{action="close",time_start=106,spawner="fist"},{action="open",time_start=109,spawner="fist",count=4},{action="close",time_start=125,spawner="fist"},{action="open",time_start=142,spawner="clone_right"},{action="open",time_start=145,spawner="fist",count=3},{action="close",time_start=151,spawner="clone_right"},{action="open",time_start=154,spawner="clone_right"},{action="close",time_start=158,spawner="fist"},{action="open",time_start=159,spawner="fist",count=7},{action="close",time_start=163,spawner="clone_right"},{action="open",time_start=173,spawner="clone_right"},{action="close",time_start=188,spawner="fist"},{action="close",time_start=195,spawner="clone_right"},{action="activate",time_start=260,spawner="hulk"},{action="open",time_start=264,spawner="fist",count=4},{action="close",time_start=279,spawner="fist"},{action="open",time_start=294,spawner="clone_right"},{action="open",time_start=295,spawner="fist",count=4},{action="close",time_start=305,spawner="clone_right"},{action="close",time_start=309,spawner="fist"},{action="open",time_start=325,spawner="clone_right"},{action="close",time_start=335,spawner="clone_right"},{action="open",time_start=342,spawner="clone_left"},{action="close",time_start=352,spawner="clone_left"},{action="open",time_start=370,spawner="clone_left"},{action="close",time_start=380,spawner="clone_left"},{action="open",time_start=397,spawner="clone_right"},{action="open",time_start=400,spawner="clone_left"},{action="activate",time_start=419,spawner="hulk"},{action="close",time_start=430,spawner="clone_right"},{action="open",time_start=431,spawner="fist",count=4},{action="close",time_start=432,spawner="clone_left"},{action="close",time_start=445,spawner="fist"},{action="activate",time_start=464,spawner="hulk"},{action="open",time_start=469,spawner="fist",count=8},{action="close",time_start=506,spawner="fist"}}}}
tt.fist_spawner_controller_t="controller_stage_26_fist_spawner"
tt.tube_left_t="decal_stage_26_tube_left"
tt.tube_right_t="decal_stage_26_tube_right"
tt.clone_spawner_controller_t="controller_stage_26_clone_spawner"
tt.clone_spawner_t="decal_stage_26_clone_spawner"
tt.hulk_spawner_controller_t="controller_stage_26_hulk_spawner"
tt.hulk_spawner_t="decal_stage_26_hulk_spawner"
tt=E:register_t_hot("decal_stage_26_mewtwo_capsules","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="DLC_Enanos_S4_EasterEgg_Mewtwo_CanistersDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=decal_stage_26_mewtwo_update
tt.ui.click_rect=r(100,270,50,80)
tt.mewtwo_t="decal_stage_26_mewtwo"
tt.sound_1_2="Stage26MewtwoTap12"
tt.sound_3="Stage26MewtwoTap3"
tt.sound_end="Stage26MewtwoFlightFullSequence"
tt=E:register_t_hot("controller_stage_26_fist_spawner",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_26_fist_spawner_update
tt.boss_t="decal_stage_26_boss"
tt.hand_controller_t="controller_stage_26_fist_spawner_hand"
tt=E:register_t_hot("decal_stage_26_mask_2","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_mask_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_26_gears_back","decal",true)
tt.render.sprites[1].prefix="DLC_Enanos_S4_GearsBackDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND
tt=E:register_t_hot("decal_stage_26_mask_4","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_mask_4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=200
tt=E:register_t_hot("controller_stage_26_clone_spawner",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_26_clone_spawner_update
tt.clone_spawner_t="decal_stage_26_fist_spawner"
tt.tube_t="decal_stage_26_fist_spawner_light"
tt.boss_t="decal_stage_26_boss"
tt.sound_in="Stage26CloneSpawnerIn"
tt.sound_out="Stage26CloneSpawnerOut"
tt.sound_chain="Stage26Chain"
tt=E:register_t_hot("decal_stage_26_foreground_1","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_foreground_a"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_26_mask_3","decal",true)
tt.render.sprites[1].name="DLC_enanos_stage_04_mask_3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_terrain_6_exodia_arm_2","decal_terrain_6_exodia_arm",true)
tt.render.sprites[1].flip_x=true
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local boss_decal,bubbles,fist_spawner,fist_spawner_light
for i,v in pairs(store.entities) do
if v.template_name=="decal_stage_26_boss" then
boss_decal=v
end
if v.template_name=="decal_stage_26_bubbles" then
bubbles=v
end
if v.template_name=="decal_stage_26_fist_spawner" then
fist_spawner=v
end
if v.template_name=="decal_stage_26_fist_spawner_light" then
fist_spawner_light=v
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=200,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,1.5)
signal.emit("show-balloon_tutorial","LV26_GRYMBEARD_BEFORE_BOSSFIGHT_01",false)
S:queue("Stage26PreBFCinematic")
U.y_animation_play(boss_decal,"grab",nil,store.tick_ts,1)
U.y_animation_play(boss_decal,"controlling_hand",nil,store.tick_ts,1)
U.animation_start_default(fist_spawner,"door_open",nil,store.tick_ts,false)
U.y_animation_play(boss_decal,"controlling_hand",nil,store.tick_ts,1)
U.animation_start_default(fist_spawner,"idle_2",nil,store.tick_ts,true)
U.animation_start_default(fist_spawner_light,"run",nil,store.tick_ts,true)
U.y_animation_play(boss_decal,"return_idle",nil,store.tick_ts,1)
signal.emit("show-balloon_tutorial","LV26_GRYMBEARD_BEFORE_BOSSFIGHT_02",false)
U.animation_start_default(boss_decal,"machine_breakdown",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(135))
bubbles.render.sprites[1].hidden=false
U.y_animation_play(bubbles,"start",nil,store.tick_ts,1)
U.animation_start_default(bubbles,"loop",nil,store.tick_ts,true)
U.y_animation_wait_default(boss_decal)
U.animation_start_default(boss_decal,"loop",nil,store.tick_ts,true)
local boss=E:create_entity("boss_deformed_grymbeard")
LU.queue_insert(store,boss)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
while not boss.health.dead do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=200,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
boss_decal.render.sprites[1].prefix="DLC_Enanos_S4_Boss02Def"
S:queue("Stage26Outro")
U.animation_start_default(boss_decal,"death",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(20))
LU.queue_remove(store,bubbles)
U.y_wait_unconditional(store,fts(60))
LU.kill_all_enemies(store,true,false)
U.y_animation_wait_default(boss_decal)
LU.kill_all_enemies(store,true,false)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
signal.emit("boss_fight_end")
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
