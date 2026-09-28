local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level210")
require("all.constants")
require("lib.klua.table")
local level={}
local target_random_defaults={V.v(711.3,415),V.v(418.2,157.2),V.v(74.3,450),V.v(895.3,454),V.v(644.3,142),V.v(700.3,476),V.v(963.3,253),V.v(641.3,440),V.v(843.3,282),V.v(-48.7,508),V.v(-149.7,250),V.v(817.3,169),V.v(852.3,204.7),V.v(154,583.8),V.v(504.3,158),V.v(1174.3,258),V.v(791.3,331),V.v(1090.3,397),V.v(1021.3,402),V.v(508.3,458),V.v(-48.7,550),V.v(856.3,486),V.v(8.2,487.2),V.v(435.3,461),V.v(784.3,464),V.v(479.3,486),V.v(728.2,144.7),V.v(366.3,473),V.v(556.3,487),V.v(232.3,523),V.v(341.3,509),V.v(15.7,230.5),V.v(694.3,358),V.v(269.3,492),V.v(-39.7,217),V.v(1163.3,374),V.v(585.7,173),V.v(181.3,517),V.v(313.2,222.2),V.v(156.5,193),V.v(1125.3,236),V.v(1023.3,241),V.v(955.3,462)}
function level:init(store)
local S=require("sound_db")
local scripts=require("scripts")
local r=V.r
local v=V.v
local bit=require("bit")
local band=bit.band
local bor=bit.bor
local bnot=bit.bnot
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local SU=require("script_utils")
local km=require("lib.klua.macros")
local signal=require("lib.hump.signal")
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function stage_210_filter_t(entities,origin,range,filter_func)
return table.filter(entities,function(k,v)
return not filter_func or filter_func(v,origin)
end)
end
local function stage_210_index_at(t,v,eq_fn)
for i=1,#t do
if eq_fn and eq_fn(t[i],v) then
return i
end
if not eq_fn and t[i]==v then
return i
end
end
return nil
end
local function stage_210_find_all_t(store,template_name,contains,fn)
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local STAGE_210_PUDDLE_BANS=band(F_ALL,bnot(bor(F_ENEMY,F_WATER)))
local function controller_stage_210_jt_icicles_update(this,store)
local start_y=store.visible_coords and store.visible_coords.top or REF_H
local door=stage_210_find_all_t(store,this.jt_door)[1]
this._target_random,this._target_enemies,this._target_allies=0,0,0
this.icicles_active=true
local function spawn_icicle(dest)
local controller=E:create_entity(this.cluster_controller)
controller.pos.x,controller.pos.y=dest.x,dest.y
queue_insert(store,controller)
for i=1,this.icicles_per_cluster do
local icicles=E:create_entity(this.icicle_t)
icicles._controller=controller
local xr=U.frandom(-this.icicle_spread,this.icicle_spread)
local yr=U.frandom(-this.icicle_spread,this.icicle_spread)
icicles.pos.x,icicles.pos.y=dest.x+xr,start_y
icicles.bullet.from=V.vclone(icicles.pos)
icicles.render.sprites[1].scale=V.vv(U.frandom(this.scale_min,1))
if i==1 then
icicles.bullet.to=v(dest.x,dest.y)
else
icicles.bullet.to=v(dest.x+xr,dest.y+yr)
end
queue_insert(store,icicles)
U.y_wait(store,U.frandom(0,this.max_delay_icicles))
end
end
local excluded_paths={2,3,6}
local function target_random()
local dest,pi
for _=1,3 do
dest,pi=P:get_random_position(10,bor(TERRAIN_LAND,TERRAIN_ICE))
if dest and not table.contains(excluded_paths,pi) then
break
end
dest=nil
end
dest=dest or this.target_random_defaults[math.random(#this.target_random_defaults)]
spawn_icicle(dest)
end
local function target_enemies()
local enemies=table.filter(store.entities,function(k,vv)
return not vv.pending_removal and vv.enemy and vv.nav_path and vv.health and not vv.health.dead and (not this.excluded_templates or not table.contains(this.excluded_templates,vv.template_name)) and band(bor(F_WATER),vv.vis.flags)==0
end)
if not enemies or #enemies==0 then
target_random()
return
end
local r_enemy=enemies[math.random(1,#enemies)]
local pred_pos
if r_enemy.motion.forced_waypoint then
local dt=this.icicle_fall_time
pred_pos=V.v(r_enemy.pos.x+dt*r_enemy.motion.speed.x,r_enemy.pos.y+dt*r_enemy.motion.speed.y)
else
local node_offset=P:predict_enemy_node_advance(r_enemy,this.icicle_fall_time)
pred_pos=P:node_pos(r_enemy.nav_path.pi,r_enemy.nav_path.spi,r_enemy.nav_path.ni+node_offset)
end
spawn_icicle(pred_pos)
end
local function target_allies()
local soldiers=table.filter(store.entities,function(k,vv)
return not vv.pending_removal and vv.soldier and vv.vis and vv.health and not vv.health.dead
end)
if not soldiers or #soldiers==0 then
target_random()
return
end
local dest=V.vclone(soldiers[math.random(1,#soldiers)].pos)
spawn_icicle(dest)
end
local function y_spawn_icicle_barrage()
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=0.5
shake.aura.freq_factor=3
queue_insert(store,shake)
local all_targets=this._target_random+this._target_enemies+this._target_allies
local cr,ca,ce=0,0,0
local o={1,2,3}
for i=1,all_targets do
if cr>=this._target_random then
table.remove(o,stage_210_index_at(o,1))
cr=-1
end
if ca>=this._target_allies then
table.remove(o,stage_210_index_at(o,2))
ca=-1
end
if ce>=this._target_enemies then
table.remove(o,stage_210_index_at(o,3))
ce=-1
end
if #o==0 then
break
end
local r=o[math.random(1,#o)]
if r==1 then
target_random()
cr=cr+1
elseif r==2 then
target_allies()
ca=ca+1
elseif r==3 then
target_enemies()
ce=ce+1
end
U.y_wait(store,U.frandom(0,this.max_delay_clusters))
end
this._target_random,this._target_enemies,this._target_allies=0,0,0
end
while true do
if not door.in_use and this.spawn_icicles and this.icicles_active then
door.in_use=true
S:queue(this.sound_events.door_open)
if door.ready then
U.animation_start(door,this.door_anim_defrosted,nil,store.tick_ts)
else
U.animation_start(door,this.door_anim,nil,store.tick_ts)
end
U.y_wait(store,this.door_slam_timing)
S:queue(this.sound_events.door_close)
door.in_use=false
y_spawn_icicle_barrage()
U.y_wait(store,this.time_to_free_door)
U.y_animation_wait(door,1,1)
this.spawn_icicles=false
end
if not door.in_use and this.spawn_icicles and not this.icicles_active then
door.in_use=true
y_spawn_icicle_barrage()
this.spawn_icicles=false
U.y_wait(store,this.time_to_free_door)
door.in_use=false
end
coroutine.yield()
end
end
local function controller_stage_210_jt_icicles_on_event(this,store,action,t_random,t_allies,t_enemies)
this.spawn_icicles=true
if t_random and tonumber(t_random) then
this._target_random=tonumber(t_random)
else
this._target_random=this.target_random
end
if t_allies and tonumber(t_allies) then
this._target_allies=tonumber(t_allies)
else
this._target_allies=this.target_allies
end
if t_enemies and tonumber(t_enemies) then
this._target_enemies=tonumber(t_enemies)
else
this._target_enemies=this.target_enemies
end
end
local function decal_stage_210_jt_door_icicle_update(this,store)
local b=this.bullet
local mspeed=10*FPS
local particle=E:create_entity(this.particles)
particle.particle_system.track_id=this.id
queue_insert(store,particle)
while V.dist(this.pos.x,this.pos.y,b.to.x,b.to.y)>mspeed*store.tick_length do
mspeed=mspeed+FPS*math.ceil(mspeed*(1/FPS)*b.acceleration_factor)
mspeed=km.clamp(b.min_speed,b.max_speed,mspeed)
b.speed.x,b.speed.y=V.mul(mspeed,V.normalize(b.to.x-this.pos.x,b.to.y-this.pos.y))
this.pos.x,this.pos.y=this.pos.x+b.speed.x*store.tick_length,this.pos.y+b.speed.y*store.tick_length
coroutine.yield()
end
this.pos.x,this.pos.y=b.to.x,b.to.y
particle.particle_system.source_lifetime=0
if this._controller then
this._controller._spawn=true
end
local targets=U.find_targets_in_range(store.entities,this.pos,0,this.damage_radius,this.vis.flags,this.vis.bans)
if targets then
for _,enemy in ipairs(targets) do
local d=E:create_entity("damage")
d.damage_type=this.damage_type
d.value=U.frandom(this.damage_min,this.damage_max)
d.source_id=this.id
d.target_id=enemy.id
queue_damage(store,d)
end
end
S:queue(this.sound_events.hit)
local d=E:create_entity(b.hit_decal)
d.pos.x,d.pos.y=this.pos.x,this.pos.y
d.render.sprites[1].ts=store.tick_ts
d.render.sprites[1].scale=V.vclone(this.render.sprites[1].scale)
queue_insert(store,d)
queue_remove(store,this)
end
local function controller_stage_210_jt_icicle_cluster_update(this,store,script)
this._spawn=false
while not this._spawn do
coroutine.yield()
end
if this.hit_fx then
local hfx=E:create_entity(this.hit_fx)
hfx.pos.x,hfx.pos.y=this.pos.x,this.pos.y
hfx.render.sprites[1].ts=store.tick_ts
queue_insert(store,hfx)
end
if this.hit_decal then
local d=E:create_entity(this.hit_decal)
d.pos.x,d.pos.y=this.pos.x,this.pos.y
d.render.sprites[1].ts=store.tick_ts
queue_insert(store,d)
end
queue_remove(store,this)
end
local function decal_stage_210_jt_door_update(this,store,script)
local controller=stage_210_find_all_t(store,this.swipe_controller)[1]
this.ready=true
this._swipe_ts=store.tick_ts
this.in_use=false
while true do
if not controller.swipe_active or this.in_use then
this.ui.clicked=false
end
if this.ui.clicked and this.ready then
this.ui.clicked=false
this.in_use=true
this.ready=false
S:queue(this.sound_events.bell_ring)
S:queue(this.sound_events.door_open,{delay=fts(27)})
U.y_animation_play(this,"out",nil,store.tick_ts,1)
controller._signal=true
this._swipe_ts=store.tick_ts
end
if store.tick_ts-this._swipe_ts>this.swipe_cooldown and not this.ready and not this.boss_fight and not this.in_use then
S:queue(this.sound_events.bell_unfreeze)
U.y_animation_play(this,this.defrost_anim,nil,store.tick_ts,1)
this.ui.clicked=false
this.ready=true
end
coroutine.yield()
end
end
local function controller_stage_210_jt_swipe_update(this,store,script)
local door=stage_210_find_all_t(store,this.jt_door)[1]
local function has_targets()
local at=E:get_template(this.aura_swipe)
local targets=U.find_targets_in_range(store.entities,this.swipe_pos,0,at.aura.radius,at.aura.vis_flags,at.aura.vis_bans)
return targets and #targets>0
end
this._signal=false
while true do
if this._signal then
if this.swipe_active then
U.animation_start(door,this.door_idle_anim,nil,store.tick_ts,true)
local ts=store.tick_ts
local timer_running=true
local no_targets=true
local aura
while timer_running and no_targets do
timer_running=store.tick_ts-ts<this.swipe_wait
no_targets=not has_targets()
coroutine.yield()
end
if no_targets and not timer_running then
else
U.animation_start(door,this.door_eat_anim,nil,store.tick_ts,false)
S:queue(this.sound_events.eat,{delay=fts(23)})
U.y_wait(store,this.swipe_timing)
aura=E:create_entity(this.aura_swipe)
aura.pos.x,aura.pos.y=this.swipe_pos.x,this.swipe_pos.y
queue_insert(store,aura)
U.y_animation_wait(door,1,1)
end
S:queue(this.sound_events.bell_freeze,{delay=fts(4)})
U.y_animation_play(door,this.bell_frost_anim,nil,store.tick_ts,1)
S:queue(this.sound_events.door_close,{delay=fts(73)})
U.y_animation_play(door,this.door_end_anim,nil,store.tick_ts,1)
end
this._signal=false
door._swipe_ts=store.tick_ts
U.y_wait(store,this.time_to_free_door)
door.in_use=false
end
coroutine.yield()
end
end
local function aura_stage_210_puddle_entrance_update(this,store,script)
while true do
local enemies=stage_210_filter_t(store.entities,this.pos,this.aura.radius,function(v,o)
return v.enemy and v.nav_path and not v.health.dead and band(v.vis.flags,this.aura.vis_bans)==0 and band(v.vis.bans,this.aura.vis_flags)==0 and (not this.excluded_templates or not table.contains(this.aura.excluded_templates,v.template_name)) and U.is_inside_ellipse(v.pos,this.pos,this.aura.radius) and not v._exit_grace_period and v.nav_path.pi==this.pid and not v._passed_entrance and not v._flying
end)
if not enemies or #enemies==0 then
else
for i,e in ipairs(enemies) do
e._passed_entrance=true
local fx=E:create_entity(this.splash_fx)
fx.render.sprites[1].ts=store.tick_ts
fx.pos=V.vclone(e.pos)
queue_insert(store,fx)
if this.sound_events and this.sound_events.water_splash then
S:queue(this.sound_events.water_splash)
end
U.flags_add(e.vis,bor(F_WATER))
U.bans_add(e.vis,STAGE_210_PUDDLE_BANS)
if game and game.game_gui and game.game_gui.selected_entity and game.game_gui.selected_entity.id==this.id then
signal.emit("hide-bottom-info")
end
if e.health_bar then
if this.override_health_bar_offset then
e.health_bar._orig_offset=e.health_bar.offset
U.change_health_bar_offset_run_time(e.health_bar,this.override_health_bar_offset.y)
end
if this.hide_healthbar then
e.health_bar.hidden=true
end
end
if this.remove_mods then
SU.remove_modifiers(store,e)
end
if this.remove_ui and e.ui then
e.ui.can_click=false
end
e.unit._orig_can_explode=e.unit.can_explode
e.unit._orig_show_blood_pool=e.unit.show_blood_pool
e.unit.can_explode=false
e.unit.show_blood_pool=false
for i=1,#e.render.sprites do
local s=e.render.sprites[i]
if not s._ignore_stage_10_puddles then
s.hidden=true
end
end
local decal=E:create_entity(this.ice_shadow)
decal.target_id=e.id
queue_insert(store,decal)
e._ice_shadow_decal=decal
local ps=E:create_entity(this.ps_ice_shadow)
ps.particle_system.emit=true
ps.particle_system.track_id=e.id
queue_insert(store,ps)
e._ps_ice_shadow_decal=ps
end
end
coroutine.yield()
end
end
local function aura_stage_210_puddle_exit_update(this,store,script)
local grace_period_e={}
while true do
local r={}
if #grace_period_e>0 then
for i=1,#grace_period_e do
local e=grace_period_e[i]
if store.tick_ts-e._exit_grace_period>this.exit_grace_period then
table.insert(r,e.id)
end
end
for i=1,#r do
local p=stage_210_index_at(grace_period_e,r[i],function(e,id)
return e.id==id
end)
local e=grace_period_e[p]
e._exit_grace_period=nil
table.remove(grace_period_e,p)
end
end
local enemies=stage_210_filter_t(store.entities,this.pos,this.aura.radius,function(v,o)
return v.enemy and v.nav_path and not v.health.dead and band(v.vis.flags,this.aura.vis_bans)==0 and band(v.vis.bans,this.aura.vis_flags)==0 and U.is_inside_ellipse(v.pos,this.pos,this.aura.radius) and v.nav_path.pi==this.pid and v._passed_entrance
end)
if not enemies or #enemies==0 then
else
for i,e in ipairs(enemies) do
e._passed_entrance=false
e._exit_grace_period=store.tick_ts
table.insert(grace_period_e,e)
local fx=E:create_entity(this.splash_fx)
fx.render.sprites[1].ts=store.tick_ts
fx.pos=V.vclone(e.pos)
queue_insert(store,fx)
if this.sound_events and this.sound_events.water_splash then
S:queue(this.sound_events.water_splash)
end
U.flags_remove(e.vis,bor(F_WATER))
U.bans_remove(e.vis,STAGE_210_PUDDLE_BANS)
if e.health_bar then
if e.health_bar._orig_offset then
U.change_health_bar_offset_run_time(e.health_bar,e.health_bar._orig_offset.y)
end
e.health_bar.hidden=false
end
if e.ui then
e.ui.can_click=true
end
e.unit.can_explode=e.unit._orig_can_explode
e.unit.show_blood_pool=e.unit._orig_show_blood_pool
for i=1,#e.render.sprites do
local s=e.render.sprites[i]
if not s._ignore_stage_10_puddles then
s.hidden=false
end
end
if e._ice_shadow_decal then
queue_remove(store,e._ice_shadow_decal)
e._ice_shadow_decal=nil
end
if e._ps_ice_shadow_decal then
queue_remove(store,e._ps_ice_shadow_decal)
e._ps_ice_shadow_decal=nil
end
end
end
coroutine.yield()
end
end
local function decal_stage_210_at_at_e_insert(this,store)
local r=E:create_entity("editor_pillar_rally_point")
queue_insert(store,r)
this.editor.shoot_pos_point_id=r.id
if this.shoot_pos.pos and this.shoot_pos.pos.x~=0 and this.shoot_pos.pos.y~=0 then
r.pos=this.shoot_pos.pos
else
r.pos=V.v(this.pos.x-50,this.pos.y-50)
this.shoot_pos.pos=r.pos
end
return true
end
local function decal_stage_210_at_at_update(this,store)
local clicks=0
local finished_shooting=false
while true do
if not finished_shooting and this.ui and this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
if clicks==1 or clicks==3 then
S:queue(this.sound_tap_1)
end
if clicks==2 then
S:queue(this.sound_tap_2)
end
U.animation_start(this,"click_"..clicks,nil,store.tick_ts,false,1)
if clicks==4 then
S:queue(this.sound_break)
for i=1,#this.bullet_hit_times do
U.y_wait(store,this.bullet_hit_times[i])
local bullet=E:create_entity(this.bullet)
bullet.pos=V.v(this.pos.x+this.bullet_offsets[1].x,this.pos.y+this.bullet_offsets[1].y)
bullet.bullet.from=V.vclone(bullet.pos)
bullet.bullet.to=this.shoot_pos.pos
queue_insert(store,bullet)
local bullet=E:create_entity(this.bullet)
bullet.pos=V.v(this.pos.x+this.bullet_offsets[2].x,this.pos.y+this.bullet_offsets[2].y)
bullet.bullet.from=V.vclone(bullet.pos)
bullet.bullet.to=this.shoot_pos.pos
queue_insert(store,bullet)
end
finished_shooting=true
end
end
coroutine.yield()
end
end
local function decal_stage_210_sasquatch_update(this,store)
local clicks=0
while true do
if clicks<2 and this.ui and this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
this.render.sprites[1].hidden=false
U.y_animation_play(this,"click_"..clicks,nil,store.tick_ts,1,1)
U.animation_start(this,"idle_"..clicks,nil,store.tick_ts,true,1)
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("ps_stage_210_under_ice","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.name="water_splash_underice_shadow_particle_run"
tt.particle_system.particle_lifetime={fts(12),fts(12)}
tt.particle_system.emission_rate=60
tt.particle_system.z=Z_DECALS
tt=E:register_t_hot("ps_stage_210_jacuzzi","particle_system",true)
tt.particle_system.alphas={5,90,0}
tt.particle_system.emission_rate=5
tt.particle_system.emit_area_spread=v(80,30.714285714285722)
tt.particle_system.emit_direction=1.628973968528041
tt.particle_system.emit_speed={30,55}
tt.particle_system.name="stage_10_water_particles"
tt.particle_system.animated=false
tt.particle_system.particle_lifetime={2,2}
tt.particle_system.scales_x={1,3,4}
tt.particle_system.scales_y={1,3,2}
tt.particle_system.z=3500
tt=E:register_t_hot("ps_stage_210_snow","particle_system",true)
tt.particle_system.alphas={205,200,0}
tt.particle_system.emission_rate=2.4691358024691357
tt.particle_system.emit_area_spread=v(1200,30.714285714285722)
tt.particle_system.emit_direction=-1.5514037795505151
tt.particle_system.emit_offset=v(0,0)
tt.particle_system.emit_rotation=0.03878509448876288
tt.particle_system.emit_speed={40,70}
tt.particle_system.name="stage_10_water_particles"
tt.particle_system.animated=false
tt.particle_system.particle_lifetime={9,18}
tt.particle_system.scale_var={0.18571428571428558,0.2999999999999976}
tt.particle_system.spin={-1,3.5}
tt.particle_system.z=3500
tt=E:register_t_hot("ps_stage_210_jt_door_icicles","particle_system",true)
tt.particle_system.name="JT_icicles_particle_run"
tt.particle_system.animated=true
tt.particle_system.particle_lifetime={fts(9),fts(9)}
tt.particle_system.emission_rate=5
tt.particle_system.scale_var={0.8,1}
tt=E:register_t_hot("fx_stage_210_enter_puddle","fx",true)
tt.render.sprites[1].prefix="water_splash_waterSplash"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_stage_210_icicle_crash","fx",true)
tt.render.sprites[1].prefix="JT_icicles_hit_fx"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_stage_210_tower_freeze_thaw_out","fx",true)
tt.render.sprites[1].prefix="JT_stage10_unit_tower_fxDef"
tt.render.sprites[1].name="out"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("fx_stage_210_at_at_hit","fx",true)
tt.render.sprites[1].prefix="animations_hitDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_210_jt_door","decal",true)
AC(tt,"main_script","ui","sound_events")
tt.render.sprites[1].prefix="JT_stage10_houseDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=212
tt.main_script.update=decal_stage_210_jt_door_update
tt.defrost_anim="bell_defrost"
tt.swipe_controller="controller_stage_210_jt_swipe"
tt.swipe_cooldown=40
tt.swipe_active=false
tt.ui.click_rect=r(-155,185,35,55)
tt.sound_events.bell_ring="Stage10BellRing"
tt.sound_events.bell_unfreeze="Stage10BellUnfreeze"
tt.sound_events.door_open="Stage10DoorOpen"
tt=E:register_t_hot("decal_stage_210_jt_door_icicle","decal",true)
AC(tt,"main_script","vis","bullet","sound_events")
tt.render.sprites[1].name="JT_icicles_projectile"
tt.render.sprites[1].z=Z_BULLETS
tt.render.sprites[1].animated=false
tt.bullet.min_speed=0
tt.bullet.max_speed=30*FPS
tt.bullet.acceleration_factor=0.2
tt.bullet.hit_decal="decal_stage_210_jt_door_icicle_bored"
tt.particles="ps_stage_210_jt_door_icicles"
tt.vis.flags=bor(F_AREA)
tt.damage_radius=50
tt.damage_min=40
tt.damage_max=60
tt.damage_type=DAMAGE_PHYSICAL
tt.main_script.update=decal_stage_210_jt_door_icicle_update
tt.sound_events.hit="Stage10StalactitesFall"
tt=E:register_t_hot("decal_stage_210_jt_door_icicle_cracks","decal_timed",true)
AC(tt,"tween","main_script")
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.timed.runs=INT_32_MAX
tt.timed.duration=3
tt.render.sprites[1].name="JT_icicles_decal"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].animated=false
tt.tween.props[1].keys={{0,0},{fts(17),255}}
tt.tween.props[1].loop=false
tt.tween.props[1].name="alpha"
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_210_jt_door_icicle_bored","decal_scripted",true)
AC(tt,"tween")
tt.main_script.update=scripts.decal_utils.animation_in_loop_out.update
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.animation_start="hit"
tt.animation_idle="idle"
tt.duration=2
tt.render.sprites[1].prefix="JT_icicles_projectile_hit"
tt.render.sprites[1].name="hit"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].loop=false
tt.tween.props[1].keys={{0,0},{fts(17),255}}
tt.tween.props[1].loop=false
tt.tween.props[1].name="alpha"
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_210_under_ice","decal",true)
AC(tt,"main_script")
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].prefix="water_splash_underice_shadow"
tt.render.sprites[1].name="run"
tt.main_script.update=scripts.decal_utils.track_target_update
tt=E:register_t_hot("decal_stage_210_mask_1","decal",true)
tt.render.sprites[1].name="Stage_10_mask_01"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_mask_2","decal",true)
tt.render.sprites[1].name="Stage_10_mask_02"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_mask_3","decal",true)
tt.render.sprites[1].name="Stage_10_mask_03"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_mask_5","decal",true)
tt.render.sprites[1].name="Stage_10_mask_05"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_waterfall","decal",true)
tt.render.sprites[1].prefix="stage_10_waterfall"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_jacuzzi","decal",true)
tt.render.sprites[1].prefix="bubbles_jacuzzi_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_steam_jacuzzi","decal",true)
tt.render.sprites[1].prefix="steam_jacuzzi_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_well","decal",true)
tt.render.sprites[1].prefix="well_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_210_at_at","decal",true)
AC(tt,"pos","render","ui","sound_events","editor","main_script","editor_script")
tt.render.sprites[1].prefix="easteregg_starwars_st10Def"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.ui.click_rect=r(550,80,200,200)
tt.editor_script.insert=decal_stage_210_at_at_e_insert
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=decal_stage_210_at_at_update
tt.shoot_pos={}
tt.sound_tap_1="Stage10AtAtTap1"
tt.sound_tap_2="Stage10AtAtTap2"
tt.sound_break="Stage10AtAtTapBreak"
tt.editor.props={{"shoot_pos.pos",PT_COORDS}}
tt.bullet="bullet_stage_210_at_at"
tt.bullet_offsets={v(560,180),v(585,170)}
tt.bullet_hit_times={fts(32),fts(10),fts(10),fts(10)}
tt=E:register_t_hot("decal_stage_210_sasquatch","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easteregg_sasquatchDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].hidden=true
tt.main_script.update=decal_stage_210_sasquatch_update
tt.ui.click_rect=r(172,265,100,50)
tt=E:register_t_hot("bullet_stage_210_at_at","bomb",true)
tt.bullet.flight_time=fts(6)
tt.bullet.damage_min=0
tt.bullet.damage_max=0
tt.bullet.damage_type=DAMAGE_NONE
tt.bullet.hit_payload="aura_stage_210_at_at"
tt.bullet.damage_radius=0
tt.bullet.ignore_rotation=true
tt.bullet.g=0
tt.bullet.align_with_trajectory=true
tt.bullet.hit_fx="fx_stage_210_at_at_hit"
tt.render.sprites[1].name="starwars_projectile_asst_projectile"
tt.render.sprites[1].z=Z_BULLETS
tt.render.sprites[1].sort_y_offset=1
tt.sound_events.insert="Stage10AtAtShoot"
tt=E:register_t_hot("aura_stage_210_jt_swipe","aura",true)
tt.aura.radius=70
tt.aura.vis_flags=bor(F_ENEMY,F_FRIEND,F_AREA,F_EAT)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.damage_min=0
tt.aura.damage_max=0
tt.aura.damage_type=DAMAGE_EAT
tt.main_script.update=scripts.aura_utils.apply_area_damage
tt=E:register_t_hot("aura_stage_210_puddle_entrance","aura",true)
AC(tt,"editor")
tt.aura.radius=50
tt.aura.vis_flags=bor(F_ENEMY)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.excluded_templates={}
tt.pid=0
tt.ice_shadow="decal_stage_210_under_ice"
tt.ps_ice_shadow="ps_stage_210_under_ice"
tt.splash_fx="fx_stage_210_enter_puddle"
tt.hide_healthbar=true
tt.override_health_bar_offset=v(0,20)
tt.remove_mods=true
tt.remove_ui=true
tt.main_script.update=aura_stage_210_puddle_entrance_update
tt.editor.props={{"pid",PT_NUMBER}}
tt.sound_events.water_splash="Stage10WaterSplashIn"
tt=E:register_t_hot("aura_stage_210_puddle_exit","aura",true)
AC(tt,"editor")
tt.aura.radius=50
tt.aura.vis_flags=bor(F_ENEMY,F_WATER)
tt.aura.vis_bans=bor(F_FLYING)
tt.pid=0
tt.splash_fx="fx_stage_210_enter_puddle"
tt.exit_grace_period=3
tt.main_script.update=aura_stage_210_puddle_exit_update
tt.editor.props={{"pid",PT_NUMBER}}
tt.sound_events.water_splash="Stage10WaterSplashOut"
tt=E:register_t_hot("aura_stage_210_at_at","aura",true)
tt.aura.duration=1e+99
tt.aura.radius=50
tt.aura.vis_flags=bor(F_AREA)
tt.aura.vis_bans=bor(F_FLYING,F_FRIEND)
tt.aura.cycles=1
tt.aura.cycle_time=0
tt.aura.damage_min=40
tt.aura.damage_max=60
tt.aura.damage_type=DAMAGE_PHYSICAL
tt.main_script.update=scripts.aura_apply_damage.update
tt=E:register_t_hot("controller_stage_210_jt_icicles",nil,true)
AC(tt,"main_script","events","sound_events")
tt.main_script.update=controller_stage_210_jt_icicles_update
tt.jt_door="decal_stage_210_jt_door"
tt.door_slam_timing=fts(58)
tt.icicle_t="decal_stage_210_jt_door_icicle"
tt.swipe_controller="controller_stage_210_jt_swipe"
tt.cluster_controller="controller_stage_210_jt_icicle_cluster"
tt.door_anim_defrosted="action_defrost"
tt.door_anim="action"
tt.excluded_templates={"enemy_boss_stage_10"}
tt.icicle_fall_time=fts(21)
tt.target_random=3
tt.target_random_defaults=target_random_defaults
tt.target_allies=2
tt.target_enemies=2
tt.icicle_spread=30
tt.scale_min=0.7
tt.time_to_free_door=0.5
tt.icicles_per_cluster=3
tt.max_delay_clusters=0.2
tt.max_delay_icicles=0.2
tt.sound_events.door_open="Stage10DoorOpenAndGrumble"
tt.sound_events.door_close="Stage10DoorClose"
tt.events.list[1].name="jt_icicles"
tt.events.list[1].on_event=controller_stage_210_jt_icicles_on_event
tt=E:register_t_hot("controller_stage_210_jt_icicle_cluster",nil,true)
AC(tt,"pos","main_script")
tt.main_script.update=controller_stage_210_jt_icicle_cluster_update
tt.hit_fx="fx_stage_210_icicle_crash"
tt.hit_decal="decal_stage_210_jt_door_icicle_cracks"
tt=E:register_t_hot("controller_stage_210_jt_swipe",nil,true)
AC(tt,"main_script","sound_events")
tt.icicles_controller="controller_stage_210_jt_icicles"
tt.jt_door="decal_stage_210_jt_door"
tt.aura_swipe="aura_stage_210_jt_swipe"
tt.door_idle_anim="idle_2"
tt.door_eat_anim="eat"
tt.bell_frost_anim="frost"
tt.door_end_anim="in"
tt.swipe_wait=3
tt.swipe_pos=v(498.5,470)
tt.swipe_timing=fts(16)
tt.time_to_free_door=2
tt.sound_events.bell_freeze="Stage10BellFreeze"
tt.sound_events.eat="Stage10JTDevour"
tt.sound_events.door_close="Stage10DoorClose"
tt.main_script.update=controller_stage_210_jt_swipe_update
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
local W=require("wave_db")
local signal=require("lib.hump.signal")
local function find_all_t(template_name)
return table.filter(store.entities,function(k,v)
return v.template_name==template_name
end)
end
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_KR1 then
while store.wave_group_number<5 do
coroutine.yield()
end
local door=find_all_t("decal_stage_210_jt_door")[1]
local controller_swipe=find_all_t("controller_stage_210_jt_swipe")[1]
local controller_icicles=find_all_t("controller_stage_210_jt_icicles")[1]
S:queue("Stage10BellUnfreeze")
U.y_animation_play(door,"bell_defrost",nil,store.tick_ts,1,1)
U.animation_start(door,"idle_defrost",nil,store.tick_ts,true,1)
controller_swipe.swipe_active=true
while not store.waves_finished or LU.has_alive_enemies(store) or door.in_use do
coroutine.yield()
end
local jt_spawn=V.v(511.6,589.5)
door.in_use=true
door.boss_fight=true
controller_swipe.swipe_active=false
controller_icicles.icicles_active=false
U.y_wait(store,1.5)
S:queue("Stage10DoorOpen")
if door.ready then
U.animation_start(door,"out_boss_defrost",nil,store.tick_ts,nil,1)
else
U.animation_start(door,"out_boss",nil,store.tick_ts,nil,1)
end
U.y_wait(store,22/FPS)
local boss=E:create_entity("enemy_boss_stage_10")
boss.nav_path.pi=4
boss.nav_path.spi=1
boss.nav_path.ni=75
boss.motion.forced_waypoint=P:node_pos(4,1,75)
boss.pos=jt_spawn
U.bans_add(boss.vis,F_ALL)
simulation:queue_insert_entity(boss)
coroutine.yield()
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.y_wait(store,2.5)
boss.cinematic=true
S:queue("Stage10JTChestTaunt")
U.y_animation_play(boss,"death",nil,store.tick_ts,1,1)
door.in_use=false
controller_icicles._target_random=8
controller_icicles._target_allies=0
controller_icicles._target_enemies=0
controller_icicles.spawn_icicles=true
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=11/FPS*5
shake.aura.freq_factor=3
simulation:queue_insert_entity(shake)
S:queue("Stage10JTRoar")
U.y_animation_play(boss,"death_loop",nil,store.tick_ts,3,1)
U.animation_start(boss,"idle",nil,store.tick_ts,nil,1)
U.y_wait(store,10/FPS)
W:start_manual_wave("BOSS1")
boss.cinematic=false
coroutine.yield()
signal.emit("boss_fight_start",boss)
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.bans_remove(boss.vis,F_ALL)
while not boss.health.dead do
coroutine.yield()
end
local freeze_mods=table.filter(store.entities,function(k,v)
return v.template_name=="mod_boss_stage_10_tower_freeze"
end)
for k,m in pairs(freeze_mods) do
m.modifier.ts=0
end
signal.emit("boss_fight_end")
U.y_wait(store,3)
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
