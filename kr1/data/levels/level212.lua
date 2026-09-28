local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level212")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local scripts=require("scripts")
local signal=require("lib.hump.signal")
local r=V.r
local v=V.v
local vv=V.vv
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function controller_stage_212_elevator_insert(this,store)
this.elevator=find_all_t(store,this.elevator_t)[1]
if not this.elevator then
log.info("There is no elevator, spawning one")
local e=E:create_entity(this.elevator_t)
e.pos.x,e.pos.y=512,384
this.elevator=e
queue_insert(store,e)
end
this.mask1=find_all_t(store,this.elevator_mask_1_t)[1]
this.mask2=find_all_t(store,this.elevator_mask_2_t)[1]
return true
end
local function controller_stage_212_elevator_update(this,store)
local right_pos_elevator,left_pos_elevator=this.elevator.pos.x,this.elevator.pos.x+this.left_offset_x
local left_pos_mask_1,left_pos_mask_2,right_pos_mask_1,right_pos_mask_2
local function deal_area_damage(hit_pos)
local targets=U.find_soldiers_in_range(store.soldiers,hit_pos,0,this.elevator.crush.damage_radius,this.elevator.crush.vis_flags,this.elevator.crush.vis_bans)
if targets then
for i,e in ipairs(targets) do
local d=E.assign_damage(DAMAGE_TRUE,1e+99,this.id,e.id)
store.damage_queue[#store.damage_queue+1]=d
end
end
end
local lowered=false
while true do
if not this.mask1 then
this.mask1=find_all_t(store,this.elevator_mask_1_t)[1]
right_pos_mask_1=this.mask1.pos.x
left_pos_mask_1=this.mask1.pos.x+this.left_offset_x
end
if not this.mask2 then
this.mask2=find_all_t(store,this.elevator_mask_2_t)[1]
right_pos_mask_2=this.mask2.pos.x
left_pos_mask_2=this.mask2.pos.x+this.left_offset_x
end
if this.lower and not lowered then
lowered=true
this.elevator.render.sprites[1].hidden=false
this.elevator.render.sprites[1].z=Z_OBJECTS_COVERS+1
if this.elevator_flip then
this.elevator.pos.x=left_pos_elevator
this.mask1.pos.x=left_pos_mask_1
this.mask2.pos.x=left_pos_mask_2
else
this.elevator.pos.x=right_pos_elevator
this.mask1.pos.x=right_pos_mask_1
this.mask2.pos.x=right_pos_mask_2
end
U.animation_start(this.elevator,"start",this.elevator_flip,store.tick_ts,false,1)
S:queue(this.sound_events.creaks)
U.y_wait(store,fts(35))
S:queue(this.sound_events.creaks)
U.y_wait(store,fts(41))
S:queue(this.sound_events.creaks)
U.y_wait(store,fts(56))
S:queue(this.sound_events.creaks)
U.y_wait(store,fts(31))
S:queue(this.sound_events.land)
deal_area_damage(this.elevator.crush.hit_pos)
U.y_wait(store,fts(1))
this.elevator.render.sprites[1].z=Z_OBJECTS
this.mask1.render.sprites[1].hidden=false
this.mask1.render.sprites[1].flip_x=this.elevator_flip
this.mask2.render.sprites[1].hidden=false
this.mask2.render.sprites[1].flip_x=this.elevator_flip
if this.elevator_flip then
P:activate_path(this.path_r)
this._last_activated_path=this.path_r
else
P:activate_path(this.path_l)
this._last_activated_path=this.path_l
end
U.y_animation_wait(this.elevator,1)
U.animation_start(this.elevator,"idle",this.elevator_flip,store.tick_ts,true,1)
this.lower=false
end
if this.rise and lowered then
lowered=false
this.mask1.render.sprites[1].hidden=true
this.mask2.render.sprites[1].hidden=true
P:deactivate_path(this._last_activated_path)
local path_enemies=table.filter(store.entities,function(k,v)
return v.nav_path and v.nav_path.pi==this._last_activated_path
end)
for _,e in pairs(path_enemies) do
local npi=this._last_activated_path==8 and 12 or 13
local nn=P:nearest_nodes(e.pos.x,e.pos.y,{npi},{1,2,3},true)
e.nav_path.pi=nn[1][1]
e.nav_path.ni=nn[1][3]
end
U.animation_start(this.elevator,"leave",this.elevator_flip,store.tick_ts,false,1)
U.y_wait(store,fts(71))
S:queue(this.sound_events.out)
U.y_wait(store,fts(32))
this.elevator.render.sprites[1].z=Z_OBJECTS_COVERS+1
U.y_animation_wait(this.elevator,1)
this.elevator.render.sprites[1].hidden=true
this.rise=false
end
coroutine.yield()
end
end
local function controller_stage_212_elevator_on_lower_event(this,store,action,direction)
if direction==nil or direction~="l" and direction~="left" and direction~="r" and direction~="right" then
direction="r"
log.error("ERROR: Elevator on lower event wrong direction naming. Defaulting to \"right\" direction.")
end
this.lower=true
if direction=="r" or direction=="right" then
this.elevator_flip=false
elseif direction=="l" or direction=="left" then
this.elevator_flip=true
end
end
local function controller_stage_212_elevator_on_rise_event(this,store,action)
this.rise=true
end
local function decal_stage_212_troll_warrior_rappel_spawn_update(this,store,script)
local shadow,string=scripts.decal_rappel_utils.y_descend(this,store)
string.dissolve=true
local sp=E:create_entity(this.spawn_t)
sp.pos.x,sp.pos.y=this.target_pos.x,this.target_pos.y
sp.render.sprites[1].flip_x=this.render.sprites[1].flip_x
sp.nav_path.pi=this.pi
sp.nav_path.spi=this.spi
sp.nav_path.ni=this.ni
queue_insert(store,sp)
queue_remove(store,shadow)
queue_remove(store,this)
end
local function decal_stage_212_torch_update(this,store)
local old_anim=this.render.sprites[1].name
while true do
if this.ui.clicked then
U.y_animation_play(this,this.anim_on_tap,nil,store.tick_ts,1,1)
U.animation_start(this,old_anim,nil,store.tick_ts,true,1)
this.ui.clicked=false
end
coroutine.yield()
end
end
local function decal_stage_212_trollcito_update(this,store)
local clicks=0
while true do
if this.ui and this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
if clicks==1 then
U.y_animation_play(this,"click_1",nil,store.tick_ts,1,1)
U.animation_start(this,"idle_2",nil,store.tick_ts,true,1)
elseif clicks==2 then
U.y_animation_play(this,"click_2",nil,store.tick_ts,1,1)
U.animation_start(this,"idle_1",nil,store.tick_ts,true,1)
clicks=0
end
end
coroutine.yield()
end
end
local function decal_stage_212_campfire_update(this,store)
local clicks=0
while true do
if this.ui and this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
if clicks==1 or clicks==2 then
U.y_animation_play(this,"click_1_y_2",nil,store.tick_ts,1,1)
U.animation_start(this,"idle_1_2_y_3",nil,store.tick_ts,true,1)
elseif clicks==3 then
U.y_animation_play(this,"click_3",nil,store.tick_ts,1,1)
U.animation_start(this,"idle_4",nil,store.tick_ts,true,1)
return
end
end
coroutine.yield()
end
end
local function decal_stage_212_vase_update(this,store)
while true do
if this.ui and this.ui.clicked then
this.ui.clicked=false
local tracker=find_all_t(store,this.achievement_tracker)[1]
if tracker then
tracker.broken_vases=tracker.broken_vases+1
end
S:queue(this.sound_click)
U.y_animation_play(this,"click",nil,store.tick_ts,1,1)
return
end
coroutine.yield()
end
end
local function controller_stage_212_wreak_havoc_achievement_update(this,store)
local total_vases=#find_all_t(store,this.vase_t,true)
if total_vases>0 then
while total_vases>this.broken_vases do
coroutine.yield()
end
signal.emit("wreak-havoc-stage12")
end
queue_remove(store,this)
end
local tt=E:register_t_hot("ps_stage_212_snow","particle_system",true)
tt.particle_system.alphas={205,200,0}
tt.particle_system.emission_rate=1.23
tt.particle_system.emit_area_spread=v(670,30.714285714285722)
tt.particle_system.emit_direction=-1.725936704749948
tt.particle_system.emit_offset=v(0,0)
tt.particle_system.emit_rotation=0.03878509448876288
tt.particle_system.emit_speed={40,70}
tt.particle_system.emit_spread=0.0872664625997164
tt.particle_system.name="stage_12_water_particles"
tt.particle_system.animated=false
tt.particle_system.particle_lifetime={9,18}
tt.particle_system.scale_var={0.18571428571428558,0.2999999999999976}
tt.particle_system.spin={-1,3.5}
tt.particle_system.z=3500
tt=E:register_t_hot("decal_stage_212_mask_1","decal",true)
tt.render.sprites[1].name="stage12_mask1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_212_mask_2","decal",true)
tt.render.sprites[1].name="stage12_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-54
tt=E:register_t_hot("decal_stage_212_mask_3","decal",true)
tt.render.sprites[1].name="stage12_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_212_mask_14","decal",true)
tt.render.sprites[1].name="stage12_mask3_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,64)
tt=E:register_t_hot("decal_stage_212_mask_4","decal",true)
tt.render.sprites[1].name="stage12_mask4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(483,-199)
tt=E:register_t_hot("decal_stage_212_mask_5","decal",true)
tt.render.sprites[1].name="stage12_mask5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-60
tt=E:register_t_hot("decal_stage_212_mask_6","decal",true)
tt.render.sprites[1].name="stage12_mask6"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,64)
tt=E:register_t_hot("decal_stage_212_mask_7","decal",true)
tt.render.sprites[1].name="stage12_mask7"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].offset=v(0,0)
tt=E:register_t_hot("decal_stage_212_mask_13","decal",true)
tt.render.sprites[1].name="stage12_mask7_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,-191)
tt=E:register_t_hot("decal_stage_212_mask_8","decal",true)
tt.render.sprites[1].name="stage12_mask8"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].hidden=true
tt.render.sprites[1].offset=v(0,94)
tt=E:register_t_hot("decal_stage_212_mask_9","decal",true)
tt.render.sprites[1].name="stage12_mask9"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,-68)
tt=E:register_t_hot("decal_stage_212_mask_10","decal",true)
tt.render.sprites[1].name="stage12_mask10"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_212_mask_11","decal",true)
tt.render.sprites[1].name="stage12_mask11"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_212_mask_12","decal",true)
tt.render.sprites[1].name="stage12_mask12"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,94)
tt=E:register_t_hot("decal_stage_212_elevator","decal",true)
tt.render.sprites[1].prefix="stage12_elevatorDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_OBJECTS
tt.crush={}
tt.crush.hit_pos=v(665.2,326.1)
tt.crush.damage_radius=150
tt.crush.vis_flags=bor(F_FRIEND,F_HERO,F_INSTAKILL)
tt.crush.vis_bans=bor(F_ENEMY,F_FLYING,F_BOSS,F_MINIBOSS)
tt=E:register_t_hot("decal_stage_212_troll_rappel_string","decal_rappel_string",true)
tt.dissolution_duration=3
tt.dissolution_ease="e_o_cubic"
tt.dissolution_movement_duration=3
tt.dissolution_movement_ease="linear"
tt.string_prefix="troll_warrior_rope"
tt.string_start_anim=nil
tt.string_parts=16
tt.string_offset=-10
tt.is_animated=false
tt=E:register_t_hot("decal_stage_212_troll_rappel_shadow","decal",true)
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="decal_flying_shadow"
tt=E:register_t_hot("decal_stage_212_troll_warrior_rappel_spawn","decal",true)
AC(tt,"main_script","sound_events")
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].prefix="troll_warrior_creep"
tt.render.sprites[1].name="rope"
tt.render.sprites[1].z=Z_FLYING_HEROES
tt.render.sprites[1].draw_order=3
tt.target_pos=vv(0)
tt.offset_drop=40
tt.rappel_flight_height=0
tt.trigger_land_distance=25
tt.spawn_t="enemy_troll_warrior_landing"
tt.string_t="decal_stage_212_troll_rappel_string"
tt.shadow_t="decal_stage_212_troll_rappel_shadow"
tt.offset_extra=0
tt.descend_rappel_ease="back-in"
tt.descend_rappel_duration=0.7+fts(17)
tt.end_rappel_anim="rope_end"
tt.animation_rappel_descent_sequence={{"rope_end",0.7}}
tt.main_script.update=decal_stage_212_troll_warrior_rappel_spawn_update
tt.sound_events.rappel_down="Stage12TrollRappel"
tt=E:register_t_hot("decal_stage_212_torch","decal_scripted",true)
AC(tt,"editor","ui")
tt.render.sprites[1].prefix="stage12torchDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].hidden=false
tt.anim_on_tap="tap"
tt.main_script.update=decal_stage_212_torch_update
tt.ui.click_rect=r(-9,0,20,60)
tt=E:register_t_hot("decal_stage_212_trollcito","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easteregg_trollcitoDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].hidden=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS+2
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=decal_stage_212_trollcito_update
tt.ui.click_rect=r(-590,125,60,60)
tt=E:register_t_hot("decal_stage_212_campfire","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easteregg_trollsfogataDef"
tt.render.sprites[1].name="idle_1_2_y_3"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].hidden=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS+2
tt.main_script.update=decal_stage_212_campfire_update
tt.ui.click_rect=r(470,100,80,60)
tt=E:register_t_hot("decal_stage_212_vase_1","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easteregg_jarronroto_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+2
tt.main_script.update=decal_stage_212_vase_update
tt.sound_click="Stage12VaseBreak"
tt.achievement_tracker="controller_stage_212_wreak_havoc_achievement"
tt.ui.click_rect=r(-513,160,22,40)
tt=E:register_t_hot("decal_stage_212_vase_2","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_2Def"
tt.ui.click_rect=r(-315,35,38,40)
tt=E:register_t_hot("decal_stage_212_vase_3","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_3Def"
tt.render.sprites[1].sort_y_offset=-70
tt.render.sprites[1].z=Z_OBJECTS
tt.ui.click_rect=r(-210,-60,50,40)
tt=E:register_t_hot("decal_stage_212_vase_4","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_4Def"
tt.ui.click_rect=r(-270,-230,70,40)
tt=E:register_t_hot("decal_stage_212_vase_5","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_5Def"
tt.render.sprites[1].sort_y_offset=-59
tt.render.sprites[1].z=Z_OBJECTS
tt.ui.click_rect=r(0,-60,25,40)
tt=E:register_t_hot("decal_stage_212_vase_6","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_6Def"
tt.ui.click_rect=r(250,65,70,40)
tt=E:register_t_hot("decal_stage_212_vase_7","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_7Def"
tt.ui.click_rect=r(440,65,25,40)
tt=E:register_t_hot("decal_stage_212_vase_8","decal_stage_212_vase_1",true)
tt.render.sprites[1].prefix="easteregg_jarronroto_8Def"
tt.render.sprites[1].sort_y_offset=-66
tt.render.sprites[1].z=Z_OBJECTS
tt.ui.click_rect=r(560,-70,35,40)
tt=E:register_t_hot("controller_stage_212_elevator",nil,true)
AC(tt,"main_script","events","pos","sound_events")
tt.elevator_t="decal_stage_212_elevator"
tt.elevator_mask_1_t="decal_stage_212_mask_8"
tt.elevator_mask_2_t="decal_stage_212_mask_12"
tt.main_script.insert=controller_stage_212_elevator_insert
tt.main_script.update=controller_stage_212_elevator_update
tt.left_offset_x=300
tt.path_r=9
tt.path_l=8
tt.events.list[1].name="lower_elevator"
tt.events.list[1].on_event=controller_stage_212_elevator_on_lower_event
tt.events.list[2]={}
tt.events.list[2].name="rise_elevator"
tt.events.list[2].on_event=controller_stage_212_elevator_on_rise_event
tt.sound_events.creaks="Stage12ElevatorInCreak"
tt.sound_events.land="Stage12ElevatorInFall"
tt.sound_events.out="Stage12ElevatorOut"
tt=E:register_t_hot("controller_stage_212_troll_rappel_spawning","controller_remote_balance_rappel_spawning",true)
tt.spawner_t="controller_stage_212_troll_rappel_spawner"
tt.events.list[1].name="troll_rappel"
tt=E:register_t_hot("controller_stage_212_troll_rappel_spawner","controller_remote_balance_rappel_spawner",true)
tt.spawn_decal="decal_stage_212_troll_warrior_rappel_spawn"
tt.node_random=8
tt=E:register_t_hot("controller_stage_212_wreak_havoc_achievement",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_212_wreak_havoc_achievement_update
tt.vase_t="decal_stage_212_vase"
tt.broken_vases=0
self.manual_hero_insertion=false
end
function level:update(store)
P:deactivate_path(8)
P:deactivate_path(9)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
