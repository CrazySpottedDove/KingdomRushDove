local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
require("lib.klua.table")
local AC=require("achievements")
local scripts=require("scripts")
local v=V.v
local r=V.r
local km=require("lib.klua.macros")
local decal_stage_04_arborean_update
local stage_4_arborean_vine_update
local decal_stage_04_elder_rune_update
local controller_stage_04_easteregg_sheepy_update
decal_stage_04_arborean_update=function(this,store)
local is_dead=false
local destination_idx=1
local start_pos=V.vclone(this.pos)
local next_destination=this.walk_destination[destination_idx]
local reach_height=false
local fm=this.force_motion
local controller
for _,v in pairs(store.entities) do
if v.template_name=="controller_stage_04_arboreans" then
controller=v
break
end
end
U.animation_start_default(this,"walk",nil,store.tick_ts,true)
U.set_destination(this,V.v(start_pos.x+next_destination.x,start_pos.y+next_destination.y))
local function move_step(dest)
local dx,dy=V.sub(dest.x,dest.y,this.pos.x,this.pos.y)
local dist=V.len(dx,dy)
local nx,ny=V.mul(fm.max_v,V.normalize(dx,dy))
local stx,sty=V.sub(nx,ny,fm.v.x,fm.v.y)
if dist<=4*fm.max_v*store.tick_length then
stx,sty=V.mul(fm.max_a,V.normalize(stx,sty))
end
fm.a.x,fm.a.y=V.add(fm.a.x,fm.a.y,V.trim(fm.max_a,V.mul(fm.a_step,stx,sty)))
fm.v.x,fm.v.y=V.trim(fm.max_v,V.add(fm.v.x,fm.v.y,V.mul(store.tick_length,fm.a.x,fm.a.y)))
this.pos.x,this.pos.y=V.add(this.pos.x,this.pos.y,V.mul(store.tick_length,fm.v.x,fm.v.y))
fm.a.x,fm.a.y=0,0
return dist<=fm.max_v*store.tick_length
end
while true do
if is_dead then
if move_step(this.motion.dest) then
if not reach_height then
reach_height=true
U.set_destination(this,V.v(this.pos.x,this.fall_to_y))
else
break
end
end
else
local furthest_distance=this.walk_destination[#this.walk_destination/2+1]
local distance_destination=V.dist(this.pos.x,this.pos.y,start_pos.x+furthest_distance.x,start_pos.y+furthest_distance.y)
local distance_origin=V.dist(this.pos.x,this.pos.y,start_pos.x,start_pos.y)
if distance_destination>45 and distance_origin>45 then
this.ui.can_click=true
else
this.ui.can_click=false
end
if this.ui.can_click and this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
this.render.sprites[1].z=Z_BACKGROUND_COVERS-3
S:queue(this.sound_fall)
U.y_animation_play(this,"tap",nil,store.tick_ts)
U.y_wait_unconditional(store,0.5)
is_dead=true
controller.arboreans_down=controller.arboreans_down+1
U.set_destination(this,V.v(this.pos.x,this.pos.y+this.jump_distance))
end
if this.motion.arrived then
destination_idx=km.zmod(destination_idx+1,#this.walk_destination)
next_destination=this.walk_destination[destination_idx]
if next_destination.x-(this.pos.x-start_pos.x)>0 then
this.render.sprites[1].flip_x=false
else
this.render.sprites[1].flip_x=true
end
U.set_destination(this,V.v(start_pos.x+next_destination.x,start_pos.y+next_destination.y))
if this.sprite_change then
this.render.sprites[1].prefix=this.sprite_change[destination_idx]
end
end
U.walk_off__accel__unsnapped(this,store.tick_length)
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
stage_4_arborean_vine_update=function(this,store)
local can_click=false
local clicked=false
local time_down=store.tick_ts
local controller
for _,v in pairs(store.entities) do
if v.template_name=="controller_stage_04_arboreans" then
controller=v
break
end
end
U.y_animation_play(this,this.animation_idle,nil,store.tick_ts,1)
while true do
if clicked then
else
if can_click and this.ui.clicked then
this.ui.clicked=nil
S:queue(this.sound_fall)
U.y_animation_play(this,this.animation_click,nil,store.tick_ts,1)
can_click=false
time_down=store.tick_ts
clicked=true
controller.arboreans_down=controller.arboreans_down+1
end
if not can_click and store.tick_ts-time_down>this.down_cooldown then
U.y_animation_play(this,this.animation_down,nil,store.tick_ts,1)
U.y_animation_play(this,this.animation_down_idle,nil,store.tick_ts,1)
can_click=true
time_down=store.tick_ts
end
if can_click and store.tick_ts-time_down>this.down_duration then
U.y_animation_play(this,this.animation_up,nil,store.tick_ts,1)
can_click=false
time_down=store.tick_ts
end
end
coroutine.yield()
end
end
decal_stage_04_elder_rune_update=function(this,store)
local s=this.render.sprites[1]
local c=this.click_play
local clicks=0
local already_played=false
while true do
if this.ui.clicked then
this.ui.clicked=nil
clicks=clicks+1
end
if c.play_once and already_played then
elseif clicks>=c.required_clicks then
if this.tween then
this.tween.disabled=false
elseif not c.idle_animation then
s.hidden=false
end
S:queue(c.clicked_sound)
U.y_animation_play(this,c.click_animation,nil,store.tick_ts,1)
this.ui.clicked=nil
clicks=0
already_played=true
U.animation_start_default(this,c.idle_on_animation,nil,store.tick_ts,true)
signal.emit("achievements_custom_event","RUNEQUEST_4")
if c.achievement then
AC:got(c.achievement)
end
if c.achievement_flag then
AC:flag_check(unpack(c.achievement_flag))
end
end
coroutine.yield()
end
end
controller_stage_04_easteregg_sheepy_update=function(this,store)
local decal_old_man=table.filter(store.entities,function(k,v)
return v.template_name=="decal_stage_04_easteregg_sheepy_old_man"
end)[1]
local decal_sheepy=table.filter(store.entities,function(k,v)
return v.template_name=="decal_stage_04_easteregg_sheepy_sheepy"
end)[1]
local old_man_ts=store.tick_ts
local sheepy_ts=store.tick_ts
local already_fell=false
while true do
if store.tick_ts-old_man_ts>=this.old_man_cooldown then
U.animation_start_default(decal_old_man,"talk",nil,store.tick_ts,false)
old_man_ts=store.tick_ts
end
if not already_fell and store.tick_ts-sheepy_ts>=this.sheepy_man_cooldown then
U.animation_start_default(decal_sheepy,"annotation",nil,store.tick_ts,false)
sheepy_ts=store.tick_ts
end
if not already_fell and this.ui.clicked then
this.ui.clicked=nil
local entity=E:create_entity("decal_stage_04_easteregg_sheepy_baby")
entity.pos=V.v(decal_sheepy.pos.x,decal_sheepy.pos.y+150)
entity.fall_dest=V.v(decal_sheepy.pos.x,decal_sheepy.pos.y+14)
simulation:queue_insert_entity(entity)
S:queue("Stage04SheepyFall")
S:queue("Stage04SheepyImpact")
U.y_wait_unconditional(store,fts(25))
U.y_animation_play(decal_sheepy,"fall",nil,store.tick_ts)
U.animation_start_default(decal_sheepy,"idle_fallen",nil,store.tick_ts,true)
already_fell=true
signal.emit("sheepy_tap_achievement",0)
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("stage_04_mask_bridge_right_front","stage_04_mask_bridge_center_back",true)
tt.render.sprites[1].name="Stage4_right_bridge_front_mask"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-2
tt=E:register_t_hot("decal_stage_04_arborean_right","decal_scripted",true)
E:add_comps(tt,"ui","motion","force_motion")
tt.render.sprites[1].prefix="stage_4_arboreans_arborean_01"
tt.render.sprites[1].name="walk"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-4
tt.main_script.update=decal_stage_04_arborean_update
tt.walk_destination={v(0,0),v(100,-70),v(175,-100),v(100,-70)}
tt.motion.speed=v(10,10)
tt.motion.max_speed=30
tt.ui.click_rect=r(-20,-10,40,40)
tt.jump_distance=20
tt.fall_to_y=440
tt.force_motion.max_a=1200
tt.force_motion.max_v=450
tt.force_motion.ramp_radius=30
tt.force_motion.fr=0.1
tt.force_motion.a_step=20
tt.sound_fall="Stage04ArboreanFall"
tt=E:register_t_hot("decal_stage_04_arborean_center","decal_stage_04_arborean_right",true)
tt.render.sprites[1].prefix="stage_4_arboreans_arborean_03"
tt.main_script.update=decal_stage_04_arborean_update
tt.walk_destination={v(0,0),v(142,-75)}
tt.fall_to_y=300
tt.sprite_change={"stage_4_arboreans_arborean_04","stage_4_arboreans_arborean_03"}
tt=E:register_t_hot("stage_04_mask_bridge_left_back","stage_04_mask_bridge_center_back",true)
tt.render.sprites[1].name="Stage4_left_bridge_back_mask"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-1
tt=E:register_t_hot("decal_stage_04_elder_rune","decal_click_play",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="stage_4_elder_rune_4"
tt.render.sprites[1].loop=true
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="stage_4_elder_rune_4_fx"
tt.render.sprites[2].loop=true
tt.main_script.update=decal_stage_04_elder_rune_update
tt.click_play.idle_animation="idle"
tt.click_play.click_animation="activation"
tt.click_play.idle_on_animation="idle_2"
tt.click_play.play_once=true
tt.click_play.clicked_sound="Stage04Rune"
tt.ui.can_click=true
tt.ui.click_rect=r(-35,-100,70,70)
tt=E:register_t_hot("stage_4_leaf_anim","decal_delayed_play",true)
E:add_comps(tt,"tween")
local duration=2.8
local fade_time=0.2
tt.render.sprites[1].name="stage_4_leaf_anim_idle"
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.delayed_play.min_delay=5
tt.delayed_play.max_delay=15
tt.delayed_play.idle_animation=nil
tt.delayed_play.play_animation="stage_4_leaf_anim_idle"
tt.delayed_play.play_duration=duration
tt.tween.disabled=false
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{fade_time,255},{duration-fade_time,255},{duration,0}}
tt.tween.props[2]=E:clone_c("tween_prop")
tt.tween.props[2].name="offset"
tt.tween.props[2].keys={{0,v(0,0)},{duration,v(0,-130)}}
tt.editor.props={{"render.sprites[1].r",PT_NUMBER,math.pi/180},{"render.sprites[1].scale",PT_COORDS}}
tt=E:register_t_hot("stage_04_mask_bottom","stage_04_mask_top",true)
tt.render.sprites[1].name="stage4_elevatormask2"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-2
tt=E:register_t_hot("decal_stage_04_arborean_left","decal_stage_04_arborean_right",true)
tt.render.sprites[1].prefix="stage_4_arboreans_arborean_02"
tt.main_script.update=decal_stage_04_arborean_update
tt.walk_destination={v(0,0),v(54,8),v(151,55),v(54,8)}
tt.fall_to_y=580
tt=E:register_t_hot("stage_4_arborean_vine","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="anim_liana"
tt.ui.can_click=true
tt.ui.click_rect=r(-30,-22,60,50)
tt.main_script.update=stage_4_arborean_vine_update
tt.animation_idle="idle1"
tt.animation_down="down"
tt.animation_down_idle="idle2"
tt.animation_click="no_tap"
tt.animation_up="tap"
tt.down_cooldown=14
tt.down_duration=3
tt.sound_fall="Stage04ArboreanFall"
tt=E:register_t_hot("decal_stage_04_mask_tunnel","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="Stage4_NEW_Topmask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="Stage4_NEW_Submask"
tt.render.sprites[2].animated=false
tt.render.sprites[2].z=Z_OBJECTS
tt.render.sprites[2].sort_y_offset=35
tt=E:register_t_hot("controller_stage_04_easteregg_sheepy",nil,true)
E:add_comps(tt,"ui","pos","main_script")
tt.main_script.update=controller_stage_04_easteregg_sheepy_update
tt.entity_baby="decal_stage_04_easteregg_sheepy_baby"
tt.entity_old_man="decal_stage_04_easteregg_sheepy_old_man"
tt.entity_sheepy="decal_stage_04_easteregg_sheepy_sheepy"
tt.old_man_cooldown=5
tt.sheepy_man_cooldown=5
tt.ui.click_rect=r(-65,-10,80,40)
tt=E:register_t_hot("stage_04_mask_bridge_right_back","stage_04_mask_bridge_center_back",true)
tt.render.sprites[1].name="Stage4_right_bridge_back_mask"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-3
tt=E:register_t_hot("stage_04_mask_bridge_left_front","stage_04_mask_bridge_center_back",true)
tt.render.sprites[1].name="Stage4_left_bridge_front_mask"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-1
tt=E:register_t_hot("decal_stage_04_elder_rune_static","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="stage_4_elder_rune_4_0119"
tt.render.sprites[1].animated=false
tt.render.sprites[1].loop=false
tt=E:register_t_hot("stage_04_mask_bridge_center_front","stage_04_mask_bridge_center_back",true)
tt.render.sprites[1].name="Stage4_center_bridge_front_mask"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-2
tt=E:register_t_hot("decal_stage_04_waterfall","decal_scripted",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="anim_waterfall"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-5
end
function level:update(store)
P:add_invalid_range(1,P:get_start_node(1),P:get_start_node(1)+15)
P:add_invalid_range(3,P:get_start_node(3),P:get_start_node(3)+15)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
