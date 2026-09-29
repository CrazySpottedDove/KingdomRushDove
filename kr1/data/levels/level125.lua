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
local v=V.v
local r=V.r
local controller_stage_25_torso_update
local controller_stage_25_tunnel_glow_update
local decal_stage_25_solid_snake_update
controller_stage_25_torso_update=function(this,store)
local torso
if store.level_mode==GAME_MODE_CAMPAIGN then
for i,v in pairs(store.entities) do
if v.template_name==this.torso_t then
torso=v
break
end
end
else
for i,v in pairs(store.entities) do
if v.template_name==this.torso_modes_t then
torso=v
break
end
end
end
while store.wave_group_number==0 do
coroutine.yield()
end
local last_wave=0
local start_wave_ts=store.tick_ts
local last_index_processed=0
local function choose_fist_pos()
local function is_in_valid_pos(soldier)
local nearest_nodes=P:nearest_nodes(soldier.pos.x,soldier.pos.y)
local pi,_,ni=unpack(nearest_nodes[1])
return P:is_node_valid(pi,ni)
end
local soldiers=table.filter(store.soldiers,function(k,v)
return not v.pending_removal and v.soldier and v.vis and v.health and not v.health.dead and is_in_valid_pos(v)
end)
if not soldiers or #soldiers==0 then
return nil
end
for i=#soldiers,2,-1 do
local j=math.random(i)
soldiers[i],soldiers[j]=soldiers[j],soldiers[i]
end
local near_soldiers={}
for k,v in ipairs(soldiers) do
local near=U.find_soldiers_in_range(soldiers,v.pos,0,this.fist_radius,0,0)
if #near_soldiers<#near then
near_soldiers=near
end
end
local x=0
local y=0
for k,v in ipairs(near_soldiers) do
x=x+v.pos.x
y=y+v.pos.y
end
x=x/#near_soldiers
y=y/#near_soldiers
local nearest_nodes=P:nearest_nodes(x,y)
local pi,_,ni=unpack(nearest_nodes[1])
return P:node_pos(pi,1,ni)
end
local function are_flying_heroes_behind(pos)
local dragons=table.filter(store.soldiers,function(k,v)
return not v.pending_removal and v.render and v.render.sprites[1].z==Z_FLYING_HEROES and math.abs(v.pos.x-pos.x)<100 and v.pos.y>pos.y
end)
return dragons and #dragons>0
end
local function choose_missile_target()
local targets={}
for k,v in pairs(store.towers) do
if not v.tower.blocked and v.tower.type~="holder" and (not v.tower_holder or not v.tower_holder.blocked) then
table.insert(targets,v)
end
end
if #targets==0 then
for k,v in pairs(store.towers) do
if v.tower_holder and not v.tower_holder.blocked and not v.tower.blocked then
table.insert(targets,v)
end
end
end
local target=targets[math.random(1,#targets)]
local m=E:create_entity(this.missile_mark_mod)
m.modifier.target_id=target.id
m.render.sprites[1].ts=store.tick_ts
m.tween.ts=store.tick_ts
m.pos=V.vclone(target.pos)
simulation:queue_insert_entity(m)
return target
end
local function shoot_missile(target)
S:queue(this.sound_missile)
local bullet=E:create_entity(this.missile_t)
bullet.pos=V.vclone(this.missile_spawn_pos)
bullet.bullet.from=V.vclone(bullet.pos)
bullet.bullet.to=V.vclone(target.pos)
bullet.bullet.to.y=bullet.bullet.to.y+20
bullet.bullet.target_id=target.id
bullet.bullet.source_id=this.id
simulation:queue_insert_entity(bullet)
end
local function get_wave_data_index(current_wave_data)
for index,wave_data in ipairs(current_wave_data) do
if index>last_index_processed and wave_data.time_start+this.action_duration>store.tick_ts-start_wave_ts then
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
local next_index_to_check=get_wave_data_index(current_wave_data)
if next_index_to_check and next_index_to_check~=last_index_processed then
local wave_data=current_wave_data[next_index_to_check]
if store.tick_ts-start_wave_ts>=wave_data.time_start then
if wave_data.action=="open" then
if torso.render.sprites[1].name=="doors_close" then
U.y_animation_wait_default(torso)
elseif torso.render.sprites[1].name~="idle_doors" then
U.y_animation_wait_default(torso)
U.animation_start_default(torso,"idle_machinist",nil,store.tick_ts,true)
goto label_1586_0
end
S:queue(this.sound_torso_open)
U.y_animation_play(torso,"doors_open",nil,store.tick_ts,1)
U.animation_start_default(torso,"idle_machinist",nil,store.tick_ts,true)
elseif wave_data.action=="fist" then
S:queue(this.sound_torso_lever_1)
U.animation_start_default(torso,"fist",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(15))
local fist=E:create_entity(this.fist_t)
fist.render.sprites[1].ts=store.tick_ts
fist.pos=choose_fist_pos()
if not fist.pos then
local rand_pos={V.v(256,210),V.v(808,212)}
fist.pos=rand_pos[math.random(1,#rand_pos)]
end
fist.render.sprites[1].flip_x=fist.pos.x>545
simulation:queue_insert_entity(fist)
local fist_decal=E:create_entity(this.fist_decal_t)
fist_decal.render.sprites[1].ts=store.tick_ts
fist_decal.pos=fist.pos
simulation:queue_insert_entity(fist_decal)
U.animation_start_default(fist,"in",nil,store.tick_ts,false)
U.y_animation_play(fist_decal,"in",nil,store.tick_ts,false)
U.animation_start_default(fist,"attack",nil,store.tick_ts,false)
U.animation_start_default(fist_decal,"attack",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(41))
S:queue(this.sound_fist)
U.y_wait_unconditional(store,fts(5))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=0.75
shake.aura.freq_factor=4
simulation:queue_insert_entity(shake)
local targets=table.filter(store.entities,function(k,v)
return (v.enemy or v.soldier) and v.health and not v.health.dead and U.is_inside_ellipse(v.pos,fist.pos,this.fist_radius)
end)
local enemies_count=0
for k,v in ipairs(targets) do
if v.enemy then
v.enemy.gold=0
enemies_count=enemies_count+1
end
local d=E.assign_damage(this.fist_damage_type,1,this.id,v.id)
d.pop_chance=0
queue_damage(store,d)
end
signal.emit("fist-stage25",enemies_count)
U.y_animation_wait_default(fist)
simulation:queue_remove_entity(fist)
U.animation_start_default(torso,"idle_machinist",nil,store.tick_ts,true)
elseif wave_data.action=="missile" then
S:queue(this.sound_torso_lever_2)
U.animation_start_default(torso,"missiles",nil,store.tick_ts,false)
local target=choose_missile_target()
U.y_wait_unconditional(store,this.missile_shoot_time-fts(3))
S:queue(this.sound_torso_button)
U.y_wait_unconditional(store,fts(3))
shoot_missile(target)
U.y_animation_wait_default(torso)
U.animation_start_default(torso,"idle_machinist",nil,store.tick_ts,true)
elseif wave_data.action=="close" then
if torso.render.sprites[1].name~="idle_machinist" then
U.y_animation_wait_default(torso)
U.animation_start_default(torso,"idle_machinist",nil,store.tick_ts,true)
else
S:queue(this.sound_torso_close)
U.y_animation_play(torso,"doors_close",nil,store.tick_ts,1)
U.animation_start_default(torso,"idle_doors",nil,store.tick_ts,true)
end
end
::label_1586_0::
last_index_processed=next_index_to_check
end
end
end
coroutine.yield()
end
end
controller_stage_25_tunnel_glow_update=function(this,store)
local glow
for _,e in pairs(store.entities) do
if e.template_name==this.glow_t then
glow=e
end
end
local on=false
local function find_enemies(range)
local enemies=table.filter(store.enemies,function(k,v)
return not v.pending_removal and v.enemy and v.nav_path and v.nav_path.pi==1 and v.health and not v.health.dead and U.is_inside_ellipse(v.pos,this.pos,range)
end)
return enemies
end
while true do
if on then
local ts=store.tick_ts
while store.tick_ts-ts<4 do
local targets=find_enemies(50)
if targets and #targets>0 then
goto label_1609_0
end
coroutine.yield()
end
glow.tween.reverse=true
glow.tween.ts=store.tick_ts
on=false
else
local targets=find_enemies(50)
if not targets or #targets==0 then
U.y_wait_unconditional(store,fts(5))
else
U.y_wait_unconditional(store,1.5)
glow.tween.disabled=false
glow.tween.reverse=false
glow.tween.ts=store.tick_ts
on=true
end
end
::label_1609_0::
coroutine.yield()
end
end
decal_stage_25_solid_snake_update=function(this,store)
local taps=0
local eyes_ts=store.tick_ts
local eyes_cd=math.random(5,10)
local eyes_opened=false
U.animation_start_default(this,"idle_1",nil,store.tick_ts,true)
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
eyes_opened=false
taps=taps+1
if taps<3 then
S:queue(this.sound_1_2)
else
S:queue(this.sound_3)
end
U.y_animation_play(this,"touch_"..taps,nil,store.tick_ts,1)
if taps>=3 then
this.render.sprites[1].hidden=true
simulation:queue_remove_entity(this)
signal.emit("snake-stage25",this)
return
else
this.ui.can_click=true
U.animation_start_default(this,"idle_"..taps*2+1,nil,store.tick_ts,true)
end
if taps==1 then
this.ui.click_rect=this.click_rect_2
elseif taps==2 then
this.ui.click_rect=this.click_rect_1
end
end
if eyes_opened and U.animation_finished_default(this) then
eyes_opened=false
U.animation_start_default(this,"idle_"..taps*2+1,nil,store.tick_ts,true)
end
if not eyes_opened and eyes_cd<store.tick_ts-eyes_ts then
eyes_opened=true
U.animation_start_default(this,"idle_"..taps*2+2,nil,store.tick_ts,false)
eyes_ts=store.tick_ts
eyes_cd=math.random(5,10)
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("controller_stage_25_torso",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_25_torso_update
tt.wave_config={{{},{},{},{},{},{},{},{{action="open",time_start=8},{action="fist",time_start=13},{action="close",time_start=23}},{{action="open",time_start=13},{action="missile",time_start=18},{action="close",time_start=28}},{},{{action="open",time_start=2},{action="fist",time_start=8},{action="fist",time_start=16}},{{action="missile",time_start=12},{action="missile",time_start=22}},{{action="fist",time_start=10},{action="fist",time_start=26}},{{action="missile",time_start=2},{action="missile",time_start=9},{action="missile",time_start=17}},{{action="missile",time_start=11},{action="missile",time_start=23},{action="missile",time_start=33},{action="missile",time_start=47},{action="missile",time_start=57},{action="missile",time_start=67},{action="missile",time_start=77},{action="missile",time_start=87},{action="missile",time_start=97}}},{{{action="open",time_start=2},{action="fist",time_start=17},{action="fist",time_start=27}},{{action="missile",time_start=12},{action="missile",time_start=22},{action="missile",time_start=32}},{{action="missile",time_start=8},{action="missile",time_start=26},{action="missile",time_start=38}},{{action="fist",time_start=12},{action="fist",time_start=28}},{{action="fist",time_start=17},{action="fist",time_start=26}},{{action="fist",time_start=17},{action="missile",time_start=24},{action="missile",time_start=34},{action="fist",time_start=46},{action="missile",time_start=59},{action="missile",time_start=72},{action="missile",time_start=83},{action="missile",time_start=94},{action="missile",time_start=106},{action="missile",time_start=120}}},{{{action="open",time_start=12},{action="missile",time_start=24},{action="missile",time_start=48},{action="fist",time_start=66},{action="missile",time_start=84},{action="missile",time_start=104},{action="missile",time_start=132},{action="missile",time_start=145},{action="fist",time_start=160},{action="fist",time_start=180},{action="missile",time_start=230},{action="missile",time_start=260},{action="missile",time_start=272},{action="missile",time_start=300},{action="fist",time_start=312},{action="missile",time_start=325},{action="missile",time_start=347},{action="fist",time_start=360},{action="missile",time_start=372},{action="missile",time_start=383},{action="missile",time_start=405},{action="missile",time_start=416},{action="fist",time_start=430},{action="missile",time_start=442},{action="missile",time_start=455},{action="missile",time_start=472},{action="missile",time_start=483},{action="missile",time_start=505},{action="missile",time_start=516},{action="missile",time_start=527}}}}
tt.action_duration=fts(220)
tt.fist_radius=140
tt.fist_damage_type=bor(DAMAGE_INSTAKILL,DAMAGE_NO_SPAWNS,DAMAGE_IGNORE_SHIELD,DAMAGE_NO_DODGE)
tt.torso_t="decal_stage_25_torso"
tt.torso_modes_t="decal_stage_25_torso_modes"
tt.fist_t="decal_stage_25_fist"
tt.fist_decal_t="decal_stage_25_fist_shadow"
tt.missile_shoot_time=fts(66)
tt.missile_mark_mod="mod_stage_25_torso_missile_mark"
tt.missile_t="bullet_stage_25_torso_missile"
tt.missile_spawn_pos=v(750,585)
tt.sound_torso_open="Stage25TorsoOpen"
tt.sound_torso_close="Stage25TorsoClose"
tt.sound_torso_lever_1="Stage25TorsoOperateLever1"
tt.sound_torso_lever_2="Stage25TorsoOperateLever2"
tt.sound_torso_button="Stage25TorsoButton"
tt.sound_fist="Stage25FistSlam"
tt.sound_missile="Stage25MissileLaunch"
tt=E:register_t_hot("decal_stage_25_torso","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="DLC_stage3_dwarf_machinistDef"
tt.render.sprites[1].name="idle_doors"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_25_mask_2","decal",true)
tt.render.sprites[1].name="stage25_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=18
tt=E:register_t_hot("decal_stage_25_mask_4","decal",true)
tt.render.sprites[1].name="stage25_mask4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_25_mask_3","decal",true)
tt.render.sprites[1].name="stage25_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=4
tt=E:register_t_hot("decal_stage_25_torso_modes","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="DLC_stage3_dwarf_machinist_modesDef"
tt.render.sprites[1].name="idle_doors"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_25_mask_2_glow","decal_tween",true)
tt.render.sprites[1].name="stage25_mask2_glow"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=19
tt.render.sprites[1].alpha=0
tt.tween.disabled=true
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{fts(30),255}}
tt=E:register_t_hot("decal_stage_25_solid_snake","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="DLC_Enanos_S3_EasterEgg_SolidSnakeDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=decal_stage_25_solid_snake_update
tt.ui.click_rect=r(-325,290,50,45)
tt.click_rect_1=r(-325,290,50,45)
tt.click_rect_2=r(-335,283,50,45)
tt.sound_1_2="Stage25SolidSnakeTap12"
tt.sound_3="Stage25SolidSnakeTap3"
tt=E:register_t_hot("decal_stage_25_dwarf_intro","decal_timed",true)
tt.render.sprites[1].prefix="DLC_stage3_dwarf_inDef"
tt.render.sprites[1].name="in"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("controller_stage_25_tunnel_glow",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_25_tunnel_glow_update
tt.glow_t="decal_stage_25_mask_2_glow"
end
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
signal.emit("pan-zoom-camera",1.5,{x=550,y=500},1.3)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,fts(23))
S:queue("Stage25IntroCrash")
U.y_wait_unconditional(store,fts(22))
local dwarf_intro=E:create_entity("decal_stage_25_dwarf_intro")
dwarf_intro.render.sprites[1].ts=store.tick_ts
dwarf_intro.pos=V.v(512,384)
LU.queue_insert(store,dwarf_intro)
U.animation_start_default(dwarf_intro,"in",nil,store.tick_ts)
U.y_wait_unconditional(store,fts(60))
dwarf_intro.render.sprites[1].z=Z_DECALS
U.y_wait_unconditional(store,fts(110))
S:queue("Stage25IntroCrashFinalExplosion")
U.y_animation_wait_default(dwarf_intro)
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
U.y_animation_wait_default(torso)
end
signal.emit("pan-zoom-camera",1.5,{x=550,y=500},1.3)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_animation_play(torso,"out",nil,store.tick_ts,1)
U.animation_start_default(torso,"out_loop",nil,store.tick_ts,true)
signal.emit("show-balloon_tutorial","LV25_MACHINIST_END_01",false)
U.y_wait_unconditional(store,3.5)
signal.emit("show-balloon_tutorial","LV25_MACHINIST_END_02",false)
U.y_wait_unconditional(store,3.5)
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
