local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local v=V.v
local vv=V.vv
local r=V.r
local I=require("lib.klove.image_db")
local S=require("sound_db")
local scripts=require("scripts")
local log=require("lib.klua.log"):new("level216")
local signal=require("lib.hump.signal")
local W=require("wave_db")
require("all.constants")
require("lib.klua.table")
local level={}
local function fts(v)
return v/FPS
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function get_random_round_robin(mutable_history,n,m)
if not m then
m=n
n=1
end
if #mutable_history==0 then
for i=n,m do
table.insert(mutable_history,i)
end
end
local pos=math.random(1,#mutable_history)
local value=mutable_history[pos]
table.remove(mutable_history,pos)
return value
end
local function random_point_in_ellipse(cx,cy,a,b)
local t=2*math.pi*math.random()
local r=math.sqrt(math.random())
local x=r*math.cos(t)
local y=r*math.sin(t)
return cx+x*a, cy+y*b
end
local function generate_blue_noise_cluster(count,candidates,random_fn,...)
local points={}
local x,y=random_fn(...)
points[1]={x=x,y=y}
for i=2,count do
local best_candidate
local best_distance2=-1
for c=1,candidates do
local px,py=random_fn(...)
local min_dist2=math.huge
for _,p in ipairs(points) do
local d2=V.dist2(px,py,p.x,p.y)
if d2<min_dist2 then
min_dist2=d2
end
end
if best_distance2<min_dist2 then
best_distance2=min_dist2
best_candidate={x=px,y=py}
end
end
points[i]=best_candidate
end
return points
end
local function tpos(e)
return e.tower and e.tower.range_offset and V.v(e.pos.x+e.tower.range_offset.x,e.pos.y+e.tower.range_offset.y) or e.pos
end
local function frame_quad(sd)
if not sd or not sd.quad then
return nil
end
return sd.quad:getViewport()
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function treant_killer_on_corromper_tree(this,store,event_name,tree_name)
if tree_name~=this.tower.tree_name then
return
end
this.attacks.list[1].ability="bullets"
this.ui.can_click=false
this.tower.can_hover=false
this.transforming=true
U.animation_start(this,"transformation",nil,store.tick_ts,false,2)
if this.update_started then
S:queue(this.sound_transformation,this.sound_transformation_args)
end
end
local function treant_killer_on_tirar_treants(this,store,event_name,tree_name,zone)
if tree_name~=this.tower.tree_name then
return
end
if this.attacks.list[1].ability~="bullets" then
return
end
this.pending_bullets_zone=tonumber(zone) or 1
end
local function treant_killer_zone_landing_nodes(this,aa,zone)
local center=this.tower["bullets_zone_"..zone]
if not center or center.x==0 and center.y==0 then
return nil
end
local radius=this.tower.bullets_zone_radius or 90
local min_dist=this.tower.bullets_min_dist or 50
local near=P:nearest_nodes(center.x,center.y,nil,nil,true)
local base=near and near[1]
if not base then
return nil
end
local pi=base[1]
local nsub=1
while P:path(pi,nsub+1) do
nsub=nsub+1
end
nsub=math.min(3,nsub)
local path=P:path(pi,1)
local cands={}
for ni=1,#path do
local o=path[ni]
if radius>=V.dist(o.x,o.y,center.x,center.y) then
cands[#cands+1]=ni
end
end
if #cands==0 then
cands={base[3]}
end
local chosen={}
local pool={}
local relax=false
for i=1,#cands do
pool[i]=cands[i]
end
while #chosen<aa.projectile_count and #cands>0 do
if #pool==0 then
for i=1,#cands do
pool[i]=cands[i]
end
relax=true
end
local ni=table.remove(pool,math.random(1,#pool))
local rspi=math.random(1,nsub)
local p=P:node_pos(pi,rspi,ni)
local ok=true
if not relax then
for _,c in ipairs(chosen) do
if min_dist>V.dist(p.x,p.y,c.pos.x,c.pos.y) then
ok=false
break
end
end
end
if ok then
chosen[#chosen+1]={pi=pi,spi=rspi,ni=ni,pos=p}
end
end
return chosen
end
local function treant_killer_fire_bullets(this,store,aa,zone)
local points={}
local znodes=zone and treant_killer_zone_landing_nodes(this,aa,zone)
if znodes and #znodes>0 then
for _,n in ipairs(znodes) do
points[#points+1]=n.pos
end
else
local pred_time=aa.cast_time+E:get_template(E:get_template(aa.bullet).bullet.payload).time_to_blow
local target,targets=U.find_foremost_enemy(store,this.pos,aa.min_range,aa.max_range,pred_time,aa.vis_flags,aa.vis_bans)
local nearest=P:nearest_nodes(this.pos.x,this.pos.y)
local in_range=table.filter(nearest,function(k,v)
return v[4]<this.attacks.range
end)
local nodes=#in_range>0 and in_range or nearest
for i=1,aa.projectile_count do
if targets and #targets>0 then
local t=get_random_round_robin(targets,1)
points[i]=V.vclone(t.__ffe_pos)
else
local n=nodes[math.random(1,#nodes)]
points[i]=P:node_pos(n[1],n[2],n[3])
end
end
end
U.animation_start(this,"attack_corrupted",nil,store.tick_ts,false,2)
S:queue(aa.sound,aa.sound_args)
U.y_wait(store,aa.cast_time)
for i=1,#points do
local point=points[i]
local b=E:create_entity(aa.bullet)
b.pos.x,b.pos.y=tpos(this).x+aa.bullet_start_offset.x,tpos(this).y+aa.bullet_start_offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=v(point.x,point.y)
b.bullet.source_id=this.id
queue_insert(store,b)
U.y_wait(store,fts(3))
end
U.y_animation_wait(this,2)
end
local function treant_killer_instakill_area(this,store,aa)
local TONGUE_TIP_REACH=129
local rally_pos=this.tower.default_rally_pos
local candidates=U.find_enemies_in_range(store,rally_pos,0,aa.instakill_detection_radius,F_INSTAKILL,bor(F_BOSS,F_FLYING))
local center
if not candidates then
center=V.vclone(rally_pos)
else
local predicted_positions={}
for _,enemy in ipairs(candidates) do
table.insert(predicted_positions,P:predict_enemy_pos(enemy,aa.node_prediction))
end
if #predicted_positions==1 then
center=V.vclone(predicted_positions[1])
else
local best_group,best_count,best_distance=nil,0,math.huge
for _,candidate_pos in ipairs(predicted_positions) do
local group={}
for _,predicted_pos in ipairs(predicted_positions) do
if U.is_inside_ellipse(predicted_pos,candidate_pos,aa.instakill_radius) then
table.insert(group,predicted_pos)
end
end
local distance=V.dist(candidate_pos.x,candidate_pos.y,rally_pos.x,rally_pos.y)
if best_count<#group or #group==best_count and distance<best_distance then
best_group=group
best_count=#group
best_distance=distance
end
end
center=v(0,0)
for _,predicted_pos in ipairs(best_group) do
center.x=center.x+predicted_pos.x
center.y=center.y+predicted_pos.y
end
center.x=center.x/best_count
center.y=center.y/best_count
end
end
U.animation_start(this,aa.animation,nil,store.tick_ts,false,2)
S:queue(this.sound_instakill,this.sound_instakill_args)
U.y_wait(store,fts(6))
local origin=v(tpos(this).x+0,tpos(this).y+40)
local tongue=E:create_entity("fx_stage_216_treant_killer_tongue")
tongue.pos.x,tongue.pos.y=origin.x,origin.y
local s=tongue.render.sprites[1]
s.r=V.angleTo(center.x-origin.x,center.y-origin.y)
s.scale=V.v(V.dist(center.x,center.y,origin.x,origin.y)/TONGUE_TIP_REACH,1)
queue_insert(store,tongue)
U.animation_start(tongue,"run",nil,store.tick_ts,false,1)
U.y_wait(store,fts(2))
local enemies=U.find_enemies_in_range(store,center,0,aa.instakill_radius,F_INSTAKILL,bor(F_BOSS,F_FLYING))
if enemies then
S:queue(this.sound_eat,this.sound_eat_args)
for _,enemy in pairs(enemies) do
local m=E:create_entity("mod_stage_216_treant_killer_tangle")
m.modifier.source_id=this.id
m.modifier.target_id=enemy.id
queue_insert(store,m)
local fx=E:create_entity("fx_stage_216_treant_killer_tangle")
fx.pos=V.vclone(enemy.pos)
fx.render.sprites[1].flip_x=enemy.render.sprites[1].flip_x
queue_insert(store,fx)
U.animation_start(fx,"run",nil,store.tick_ts,false,1)
end
U.y_wait(store,fts(5))
for _,enemy in pairs(enemies) do
if store.entities[enemy.id] and not enemy.health.dead then
enemy.unit.can_explode=false
enemy.unit.death_animation=nil
enemy.unit.hide_during_death=true
local d=E:create_entity("damage")
d.source_id=this.id
d.target_id=enemy.id
d.damage_type=bor(DAMAGE_EAT,DAMAGE_INSTAKILL,DAMAGE_NO_SPAWNS)
queue_damage(store,d)
signal.emit("last-march-of-the-treants-stage16")
end
end
end
U.y_animation_wait(this,2)
if enemies then
U.animation_start(this,"eat",nil,store.tick_ts,false,2)
U.y_animation_wait(this,2)
end
return enemies~=nil
end
local function treant_killer_update(this,store)
this.update_started=true
local aa=this.attacks.list[1]
if aa.ability=="bullets" then
this.ability_available=true
this.ui.can_click=false
this.transforming=nil
U.animation_start(this,"idle_corrupted",nil,store.tick_ts,true,2)
else
this.ability_available=false
this.ui.can_click=false
U.animation_start(this,"sleep_loop",nil,store.tick_ts,true,2,true)
while store.wave_group_number<1 do
coroutine.yield()
end
if aa.ability=="instakill" then
U.animation_start(this,"wake_up",nil,store.tick_ts,false,2)
U.y_animation_wait(this,2)
end
this.ability_available=true
this.ui.clicked=nil
if aa.ability=="instakill" then
this.ui.can_click=true
U.animation_start(this,"idle",nil,store.tick_ts,true,2)
end
end
while true do
if this.transforming then
U.y_animation_wait(this,2)
this.transforming=nil
U.animation_start(this,"idle_corrupted",nil,store.tick_ts,true,2)
end
local action,zone
if this.ability_available and this.pending_bullets_zone then
zone=this.pending_bullets_zone
this.pending_bullets_zone=nil
action="bullets_zone"
elseif this.ability_available and this.ui.clicked then
this.ui.clicked=nil
action="click"
elseif this.ui.clicked then
this.ui.clicked=nil
end
if action then
local action_performed=true
this.ability_available=false
this.ui.can_click=false
if action=="bullets_zone" then
treant_killer_fire_bullets(this,store,aa,zone)
elseif aa.ability=="bullets" then
treant_killer_fire_bullets(this,store,aa)
else
action_performed=treant_killer_instakill_area(this,store,aa)
end
if not action_performed then
U.animation_start(this,"idle",nil,store.tick_ts,true,2)
this.ability_available=true
this.ui.can_click=true
elseif aa.ability=="bullets" then
U.animation_start(this,"idle_corrupted",nil,store.tick_ts,true,2)
this.ability_available=true
else
local function corrupted()
return aa.ability~="instakill"
end
if not corrupted() then
U.animation_start(this,"sleep_start",nil,store.tick_ts,false,2)
while not U.animation_finished(this,2) and not corrupted() do
coroutine.yield()
end
end
if not corrupted() then
U.animation_start(this,"sleep_loop",nil,store.tick_ts,true,2,true)
U.y_wait(store,aa.cooldown,corrupted)
end
if corrupted() then
this.ability_available=true
else
U.animation_start(this,"wake_up",nil,store.tick_ts,false,2)
U.y_animation_wait(this,2)
this.ability_available=true
if aa.ability=="instakill" then
this.ui.can_click=true
U.animation_start(this,"idle",nil,store.tick_ts,true,2)
end
end
end
end
coroutine.yield()
end
end
local function bullet_killer_bomb_insert(this,store,script)
if not scripts.bomb.insert(this,store,script) then
return false
end
local angle=V.angleTo(this.bullet.speed.x,this.bullet.speed.y)
this.render.sprites[1].r=angle
U.animation_start(this,"run",nil,store.tick_ts,true,1)
return true
end
local function decal_killer_bomb_update(this,store)
U.animation_start(this,"run",nil,store.tick_ts,nil,1)
local impact=E:create_entity("decal_stage_216_treant_killer_bomb_impact")
impact.pos=V.vclone(this.pos)
queue_insert(store,impact)
U.y_wait(store,this.spawn_time)
if this.t_enemy then
local nodes=P:nearest_nodes(this.pos.x,this.pos.y,nil,{1,2,3},true)
local n=nodes and nodes[1]
if n and P:is_node_valid(n[1],n[3]) then
local e=E:create_entity(this.t_enemy)
e.nav_path.pi=n[1]
e.nav_path.spi=n[2]
e.nav_path.ni=n[3]
queue_insert(store,e)
if not U.is_seen(store,this.t_enemy) then
signal.emit("wave-notification","icon",this.t_enemy)
U.mark_seen(store,this.t_enemy)
end
end
end
S:queue(this.sound)
U.y_wait(store,this.time_to_blow-this.spawn_time)
local aura=E:create_entity(this.t_aura)
aura.pos.x,aura.pos.y=this.pos.x,this.pos.y
queue_insert(store,aura)
U.y_animation_wait(this,1,1)
queue_remove(store,this)
end
local function easter_egg_deku_sprout_update(this,store,script)
local ts=store.tick_ts
while true do
::label_1435_0::
if this.ui.clicked then
if this.sound_tap_in then
S:queue(this.sound_tap_in,{delay=fts(this.sound_tap_in_frame)})
end
if this.sound_tap_out then
S:queue(this.sound_tap_out,{delay=fts(this.sound_tap_out_frame)})
end
U.y_animation_play(this,"run",nil,store.tick_ts,1,1)
queue_remove(store,this)
return
end
if store.tick_ts-ts>this.anim_cd then
U.animation_start(this,"shake",nil,store.tick_ts,false,1)
while not U.animation_finished(this) do
if this.ui.clicked then
goto label_1435_0
end
coroutine.yield()
end
ts=store.tick_ts
U.animation_start(this,"idle",nil,store.tick_ts,false,1)
end
coroutine.yield()
end
end
local function rider_fog_emitter_update(this,store)
local interval=1/(this.emission_rate or 6)
local last_ts=store.tick_ts-interval
local dir_x,dir_y=0,0
while true do
local target=store.entities[this.target_id]
if this.finished or not target or target.health and target.health.dead then
queue_remove(store,this)
return
end
if interval<=store.tick_ts-last_ts then
last_ts=store.tick_ts
local dx=target.motion.dest.x-target.pos.x
local dy=target.motion.dest.y-target.pos.y
local d=math.sqrt(dx*dx+dy*dy)
if d>0.001 then
dir_x,dir_y=dx/d,dy/d
end
local off=this.trail_offset or 0
local fx=E:create_entity(this.trail_fx)
fx.pos.x=target.pos.x-dir_x*off
fx.pos.y=target.pos.y-dir_y*off
local s=fx.render.sprites[1]
s.flip_x=math.random()<0.5
s.scale=V.vv(U.frandom(this.trail_scale[1],this.trail_scale[2]))
queue_insert(store,fx)
U.animation_start(fx,"run",nil,store.tick_ts,false,1)
end
coroutine.yield()
end
end
local nightfall={}
function nightfall.quad_screen_rect(pos,s)
local sd=I:s(s.name)
local vx,vy,vw,vh=frame_quad(sd)
if not vx or not sd.size then
return nil
end
local rs=sd.ref_scale or 1
local sx=rs*(s.scale and s.scale.x or 1)
local sy=rs*(s.scale and s.scale.y or 1)
local ax=s.anchor and s.anchor.x or 0.5
local ay=s.anchor and s.anchor.y or 0.5
local trim=sd.trim or {0,0,0,0}
local x=pos.x+(s.offset and s.offset.x or 0)
local y=REF_H-(pos.y+(s.offset and s.offset.y or 0))
return x-(ax*sd.size[1]-trim[1])*sx, y-((1-ay)*sd.size[2]-trim[2])*sy, vw*sx, vh*sy
end
function nightfall.front_noise(px,py)
local n=0.5+0.3*math.sin(px*2.1+py*1.3)+0.2*math.sin(px*1-py*2.6+1.7)
return math.max(0,math.min(1,n))
end
function nightfall.refresh_view_args(args,store)
local gs=game.game_scale
local rox,roy
if game.camera then
local c=game.camera
rox=-(c.x*c.zoom-game.screen_w/2)
roy=-(c.y*c.zoom-game.screen_h/2)
gs=gs*c.zoom
else
rox=game.game_ref_origin.x
roy=game.game_ref_origin.y
end
if store.world_offset then
rox=rox+store.world_offset.x
roy=roy+store.world_offset.y
end
args.view_off=args.view_off or {0,0}
args.view_off[1],args.view_off[2]=rox,roy
args.view_scale=gs
end
function nightfall.find_swap_from(this,store)
for _,e in pairs(store.entities) do
if e.template_name==this.swap_from and e.pos and (not this.holder_id or e.tower and e.tower.holder_id==this.holder_id) and V.dist(e.pos.x,e.pos.y,this.pos.x,this.pos.y)<8 then
return e
end
end
return nil
end
function nightfall.find_tower_over(this,store)
for _,e in pairs(store.entities) do
if e.tower and e.tower.holder_template==this.swap_from and e.pos and (not this.holder_id or e.tower.holder_id==this.holder_id) and V.dist(e.pos.x,e.pos.y,this.pos.x,this.pos.y)<8 then
return e
end
end
return nil
end
function nightfall.find_replace_from(this,store)
for _,e in pairs(store.entities) do
if e.template_name==this.replace_from and e.pos and V.dist(e.pos.x,e.pos.y,this.pos.x,this.pos.y)<8 then
return e
end
end
return nil
end
function nightfall.do_swap(this,store,insert_fn)
local tpl=E:get_template(this.swap_to)
local swap_style=tpl and tpl.tower and tpl.tower.terrain_style
local best=nightfall.find_swap_from(this,store)
if best then
local h=E:create_entity(this.swap_to)
h.pos=V.vclone(best.pos)
if h.tower and best.tower then
h.tower.default_rally_pos=best.tower.default_rally_pos
h.tower.holder_id=best.tower.holder_id
end
if h.ui and best.ui then
h.ui.nav_mesh_id=best.ui.nav_mesh_id
end
if insert_fn then
insert_fn(h)
for _,s in ipairs(best.render.sprites) do
s.hidden=true
end
else
queue_insert(store,h)
end
queue_remove(store,best)
local buy_c=find_all_t(store,"controller_show_buy_available")[1]
if buy_c then
buy_c.force_check=true
end
else
local tw=nightfall.find_tower_over(this,store)
if tw then
tw.tower.holder_template=this.swap_to
if swap_style then
tw.tower.terrain_style=swap_style
local twt=E:get_template(tw.template_name)
for i=1,2 do
local ts=twt and twt.render and twt.render.sprites[i]
local s=tw.render and tw.render.sprites[i]
if ts and s and type(ts.name)=="string" and string.find(ts.name,"%%") then
s.name=string.format(ts.name,swap_style)
end
end
end
elseif this.swap_from then
log.warning("nightfall_dissolve: no encontré \"%s\" ni torre encima en (%s,%s)",tostring(this.swap_from),tostring(this.pos.x),tostring(this.pos.y))
end
end
end
function nightfall.update(this,store)
if this._final_applied then
return
end
local SH=require("klove.shader_db")
local qrect=nightfall.quad_screen_rect
local find_swap_from=nightfall.find_swap_from
local find_tower_over=nightfall.find_tower_over
local find_replace_from=nightfall.find_replace_from
local function find_driver()
if this.transition_id then
return store.entities[this.transition_id]
end
local name=this.nightfall_name or "decal_stage_18_nightfall"
for _,e in pairs(store.entities) do
if e.template_name==name then
return e
end
end
return nil
end
local function full_cover_fire(driver_args,e)
e=e or this
local br=driver_args and (driver_args.mask_rect or driver_args.bg_rect)
if not br or not br[3] or br[3]==0 or not br[4] or br[4]==0 then
return 1
end
local bx,by,bw,bh=br[1],br[2],br[3],br[4]
local amp=driver_args.noise_amp or 0
local max_fire=0
for _,s in ipairs(e.render.sprites) do
if not s.hidden and (e~=this or s.shader) then
local qx,qy,qw,qh=qrect(e.pos,s)
if qx then
for _,c in ipairs({{qx,qy},{qx+qw,qy},{qx,qy+qh},{qx+qw,qy+qh}}) do
local bluvx=(c[1]-bx)/bw
local bluvy=(c[2]-by)/bh
local prog
if driver_args.origin and driver_args.dist_scale then
local dx=(bluvx-driver_args.origin[1])*driver_args.dist_scale[1]
local dy=(bluvy-driver_args.origin[2])*driver_args.dist_scale[2]
prog=math.sqrt(dx*dx+dy*dy)
else
local dir=driver_args.dir or {0,1}
local dl=math.sqrt(dir[1]*dir[1]+dir[2]*dir[2])
if dl==0 then
dl=1
end
prog=(bluvx-0.5)*dir[1]/dl+(bluvy-0.5)*dir[2]/dl+0.5
end
local fire=(prog+amp)/(1+amp)
if max_fire<fire then
max_fire=fire
end
end
end
end
end
if max_fire<=0 then
return 1
end
return math.min(max_fire,1)
end
local function share_driver(driver,sid)
local ns=driver.render.sprites[sid]
local nfr=driver.render.frames and driver.render.frames[sid]
local na=ns and ns.shader_args
if not na then
return nil
end
for i,s in ipairs(this.render.sprites) do
if s.shader and not s.hidden then
s.shader_args=na
local fr=this.render.frames and this.render.frames[i]
if fr then
fr.shader_args=na
if nfr and nfr.shader then
fr.shader=nfr.shader
end
end
end
end
return na
end
local tpl=this.swap_to and E:get_template(this.swap_to)
local swap_style=tpl and tpl.tower and tpl.tower.terrain_style
local sid=this.transition_sid or 1
local function config_holder()
for i=1,#this.render.sprites do
local ts=tpl.render.sprites[i]
local s=this.render.sprites[i]
if ts then
s.name=ts.name
s.offset=V.v(ts.offset.x,ts.offset.y)
s.z=ts.z
s.flip_x=ts.flip_x
s.hidden=ts.hidden
s.sort_y_offset=(ts.sort_y_offset or 0)-0.1
else
s.hidden=true
s.shader_args=nil
end
end
end
local function config_tower(tw)
local twt=E:get_template(tw.template_name)
local pt=twt and twt.render and twt.render.sprites[1] and twt.render.sprites[1].name
local live=tw.render and tw.render.sprites[1]
if not swap_style or not live or type(pt)~="string" or not string.find(pt,"%%") then
return false
end
local s=this.render.sprites[1]
s.name=string.format(pt,swap_style)
s.offset=V.v(live.offset.x,live.offset.y)
s.z=live.z
s.flip_x=live.flip_x
s.hidden=false
s.sort_y_offset=(live.sort_y_offset or 0)-0.1
for i=2,#this.render.sprites do
this.render.sprites[i].hidden=true
end
return true
end
local function config_none()
for _,s in ipairs(this.render.sprites) do
if s.shader then
s.hidden=true
end
end
end
if tpl then
config_holder()
else
for _,s in ipairs(this.render.sprites) do
if s.shader then
s.sort_y_offset=(s.sort_y_offset or 0)-0.1
end
end
end
coroutine.yield()
local fire,driver,driver_args,replaced,replaced_args
local hide_target=this.hide_from and find_replace_from({replace_from=this.hide_from,pos=this.pos},store) or nil
local hide_args
if hide_target then
hide_args={invert=1}
local tsh=this.transition_shader or "p_dissolve_reveal"
local hsh=SH:clone(tsh,tsh.."#invert:"..this.id)
for i,s in ipairs(hide_target.render.sprites) do
if not s.hidden then
s.shader_args=hide_args
local fr=hide_target.render.frames and hide_target.render.frames[i]
if fr then
fr.shader=hsh
fr.shader_args=hide_args
end
end
end
end
local cut_args,cut_sh,cut_target
if this.swap_from then
cut_args={invert=1}
local tsh=this.transition_shader or "p_dissolve_reveal"
cut_sh=SH:clone(tsh,tsh.."#swapcut:"..this.id)
end
local function unwire_swap_cut()
if cut_target and store.entities[cut_target.id] and cut_target.render.frames then
for _,cfr in ipairs(cut_target.render.frames) do
if cfr.shader==cut_sh then
cfr.shader=nil
cfr.shader_args=nil
end
end
end
cut_target=nil
end
local function wire_swap_cut(target,only)
if cut_target==target then
return
end
unwire_swap_cut()
if not target then
return
end
cut_target=target
for i,s in ipairs(target.render.sprites) do
if not s.hidden and (not only or only[i]) then
s.shader_args=cut_args
local cfr=target.render.frames and target.render.frames[i]
if cfr then
cfr.shader=cut_sh
cfr.shader_args=cut_args
end
end
end
end
local function tower_terrain_indices(tw)
local twt=E:get_template(tw.template_name)
local only,any={},false
for i=1,2 do
local ts=twt and twt.render and twt.render.sprites[i]
if ts and type(ts.name)=="string" and string.find(ts.name,"%%") then
only[i]=true
any=true
end
end
return any and only or nil
end
local function visual_fire()
local f=full_cover_fire(driver_args)
if hide_target and store.entities[hide_target.id] then
f=math.max(f,full_cover_fire(driver_args,hide_target))
end
return math.min(1,f+((driver_args.edge_width or 0)+(driver_args.edge_softness or 0))/(1+(driver_args.noise_amp or 0)))
end
local function resync()
driver=find_driver()
driver_args=driver and share_driver(driver,sid) or nil
if tpl then
fire=driver_args and full_cover_fire(driver_args) or nil
if fire and cut_target and store.entities[cut_target.id] then
fire=math.max(fire,full_cover_fire(driver_args,cut_target))
end
elseif this.replace_from then
fire=1
else
fire=driver_args and visual_fire() or nil
end
end
if cut_args then
wire_swap_cut(find_swap_from(this,store))
end
resync()
if this.replace_from then
replaced=find_replace_from(this,store)
if replaced then
replaced_args={invert=1}
local rsh=SH:clone("p_corrupt_reveal","p_corrupt_reveal#replace:"..this.id)
for i,s in ipairs(replaced.render.sprites) do
if not s.hidden then
s.shader_args=replaced_args
local fr=replaced.render.frames and replaced.render.frames[i]
if fr then
fr.shader=rsh
fr.shader_args=replaced_args
end
end
end
end
end
local mode_key="holder"
while true do
if tpl and this.swap_from and (not this._next_mode_check or store.tick_ts>=this._next_mode_check) then
this._next_mode_check=store.tick_ts+0.25
local holder=find_swap_from(this,store)
local tw=not holder and find_tower_over(this,store) or nil
local key=holder and "holder" or tw and "tower:"..tw.id or "none"
if holder then
wire_swap_cut(holder)
elseif tw then
local only=tower_terrain_indices(tw)
if only then
wire_swap_cut(tw,only)
else
unwire_swap_cut()
end
else
unwire_swap_cut()
end
if key~=mode_key then
mode_key=key
if holder then
config_holder()
elseif not tw or not config_tower(tw) then
config_none()
end
resync()
end
end
if not driver or not store.entities[driver.id] then
driver=find_driver()
driver_args=driver and share_driver(driver,sid) or nil
end
if driver_args and (driver_args.mask_rect or driver_args.bg_rect) then
if tpl then
fire=full_cover_fire(driver_args)
if cut_target and store.entities[cut_target.id] then
fire=math.max(fire,full_cover_fire(driver_args,cut_target))
end
elseif not this.replace_from then
fire=visual_fire()
end
end
if replaced_args and driver_args then
for k,v in pairs(driver_args) do
if k~="invert" then
replaced_args[k]=v
end
end
replaced_args.invert=1
end
if hide_args and driver_args then
for k,v in pairs(driver_args) do
if k~="invert" then
hide_args[k]=v
end
end
hide_args.invert=1
end
if cut_args and driver_args then
for k,v in pairs(driver_args) do
if k~="invert" then
cut_args[k]=v
end
end
cut_args.invert=1
end
local th=driver_args and driver_args.threshold or 0
if fire and fire<=th then
break
end
coroutine.yield()
end
local function strip(e)
if not e or not e.render or not e.render.frames then
return
end
for _,efr in ipairs(e.render.frames) do
efr.shader=nil
efr.shader_args=nil
end
end
strip(this)
if this.replace_from then
if replaced and store.entities[replaced.id] then
for _,s in ipairs(replaced.render.sprites) do
s.hidden=true
end
strip(replaced)
queue_remove(store,replaced)
elseif not replaced then
log.warning("nightfall_dissolve: no encontré \"%s\" en (%s,%s)",tostring(this.replace_from),tostring(this.pos.x),tostring(this.pos.y))
end
return
end
if not tpl then
if this.hide_from then
if hide_target and store.entities[hide_target.id] then
for _,s in ipairs(hide_target.render.sprites) do
s.hidden=true
end
strip(hide_target)
else
log.warning("nightfall_dissolve: no encontré \"%s\" en (%s,%s)",tostring(this.hide_from),tostring(this.pos.x),tostring(this.pos.y))
end
end
return
end
nightfall.do_swap(this,store)
if cut_target and store.entities[cut_target.id] and not cut_target.pending_removal then
unwire_swap_cut()
end
if this.swap_to then
queue_remove(store,this)
end
end
local bg_corrupt={}
function bg_corrupt.fire_corromper(store,tree_name)
local handlers=store.event_handlers and store.event_handlers.corromper_tree
if not handlers then
log.error("stage_216_bg_corrupt: sin handlers para corromper_tree")
return
end
for _,ev in pairs(handlers) do
ev.on_event(store.entities[ev.entity_id],store,ev.name,tree_name)
end
end
function bg_corrupt.apply_final(this,store)
local function insert_now(e)
for _,sys in ipairs(simulation.systems_on_queue_unconditional) do
sys:on_queue_unconditional(e,store)
end
simulation:insert_entity(e)
end
if this._final_applied then
return
end
if not store.entities[this.id] then
insert_now(this)
end
this._final_applied=true
this._start_final=true
this._overlays_spawned=true
for _,s in ipairs(this.render.sprites) do
s.hidden=false
if s.shader_args then
s.shader_args.threshold=1
end
s.shader=nil
end
if this.render.frames then
for _,f in ipairs(this.render.frames) do
f.shader=nil
f.shader_args=nil
end
end
for _,item in ipairs(this.corromper_list or {}) do
bg_corrupt.fire_corromper(store,item.tree)
end
for _,item in ipairs(this.overlay_list or {}) do
if item.replace_from then
local old=nightfall.find_replace_from({replace_from=item.replace_from,pos={x=item.x,y=item.y}},store)
if old then
for _,s in ipairs(old.render.sprites) do
s.hidden=true
end
queue_remove(store,old)
end
local o=E:create_entity("decal_stage_216_corrupt_overlay")
o.transition_id=this.id
o.transition_sid=item.transition_sid
o.pos.x,o.pos.y=item.x,item.y
if item.name then
local s=o.render.sprites[1]
s.name=item.name
s.z=item.z
s.sort_y_offset=item.sort_y_offset or 0
end
local sid=item.transition_sid or 1
local na=this.render.sprites[sid] and this.render.sprites[sid].shader_args
for _,s in ipairs(o.render.sprites) do
if na and s.shader then
s.shader_args=na
end
s.shader=nil
end
insert_now(o)
elseif item.swap_from and item.swap_to then
nightfall.do_swap({swap_from=item.swap_from,swap_to=item.swap_to,holder_id=item.holder_id,pos={x=item.x,y=item.y}},store,insert_now)
end
end
end
function bg_corrupt.update(this,store)
local SH=require("klove.shader_db")
local qrect=nightfall.quad_screen_rect
local refresh_view_args=nightfall.refresh_view_args
local front_noise=nightfall.front_noise
coroutine.yield()
local function refresh_view()
for _,s in ipairs(this.render.sprites) do
if s.shader_args then
refresh_view_args(s.shader_args,store)
end
end
if this._grass_shader_args then
refresh_view_args(this._grass_shader_args,store)
end
end
local function resolve_targets()
local out={}
for _,item in ipairs(this.corromper_list or {}) do
local fire
for _,s in ipairs(this.render.sprites) do
local a=s.shader_args
local br=a and a.mask_rect
if br and br[3] and br[3]~=0 and br[4] and br[4]~=0 then
local bluvx=(item.x-br[1])/br[3]
local bluvy=(REF_H-item.y-br[2])/br[4]
if bluvx>=0 and bluvx<=1 and bluvy>=0 and bluvy<=1 then
local amp=a.noise_amp or 0
local nscale=a.noise_scale or 6
local dx=(bluvx-a.origin[1])*a.dist_scale[1]
local dy=(bluvy-a.origin[2])*a.dist_scale[2]
local prog=math.sqrt(dx*dx+dy*dy)
local n=front_noise(bluvx*nscale,bluvy*nscale)
fire=(prog+amp*(1-n))/(1+amp)
break
end
end
end
if not fire then
log.warning("stage_216_bg_corrupt: (%s,%s) fuera de las máscaras, \"%s\" se corrompe al arrancar el barrido",tostring(item.x),tostring(item.y),tostring(item.tree))
fire=0
end
out[#out+1]={fired=false,tree=item.tree,fire=fire}
end
table.sort(out,function(a,b)
return a.fire<b.fire
end)
return out
end
local function fire_crossed(targets,phase)
for _,t in ipairs(targets) do
if phase<t.fire then
break
end
if not t.fired then
t.fired=true
bg_corrupt.fire_corromper(store,t.tree)
end
end
end
local function front_point(em,p,phi)
if not p or p<=0 then
return nil
end
local c,s=math.cos(phi),math.sin(phi)
local luvx=em.ox+em.sx*p*c/em.dsx
local luvy=em.oy+em.sy*p*s/em.dsy
if luvx<0 or luvx>1 or luvy<0 or luvy>1 then
return nil
end
local wx=em.qx+luvx*em.qw
local wy=REF_H-(em.qy+luvy*em.qh)
local mdx=em.qw*(em.sx*c/em.dsx)
local mdy=-em.qh*(em.sy*s/em.dsy)
local move_a=math.atan2(mdy,mdx)
return wx, wy, move_a, move_a+math.pi*0.5
end
local function front_prog_wobble(em,threshold,phi)
local amp=em.amp or 0
local nscale=em.nscale or 6
local c,s=math.cos(phi),math.sin(phi)
local p=threshold
for _=1,2 do
local luvx=em.ox+em.sx*p*c/em.dsx
local luvy=em.oy+em.sy*p*s/em.dsy
local n=front_noise(luvx*nscale,luvy*nscale)
p=threshold*(1+amp)-amp*(1-n)
end
return p
end
local grass_life=0.7333333333333333
do
local pt=this.grass_ps and E:get_template(this.grass_ps)
local pl=pt and pt.particle_system and pt.particle_system.particle_lifetime
if pl and pl[2] then
grass_life=pl[2]
end
end
local emit_stop_dt=math.max(0,(this.reveal_time or 0)-grass_life)
local function stop_all_grass_emitters()
for _,em in ipairs(this._grass_ps or {}) do
local ps=store.entities[em.id] or em.e
if ps and ps.particle_system then
ps.particle_system.emit=false
end
em.last_x,em.last_y=nil
end
end
local function update_grass_emitters(threshold,dt)
if dt==nil or dt>=emit_stop_dt or not threshold or threshold<=0 then
stop_all_grass_emitters()
return
end
for _,em in ipairs(this._grass_ps or {}) do
local ps=store.entities[em.id] or em.e
if ps and ps.particle_system then
local p=front_prog_wobble(em,threshold,em.phi)
local wx,wy,_,perp_a=front_point(em,p,em.phi)
if wx then
em.last_x,em.last_y=wx,wy
ps.pos.x,ps.pos.y=wx,wy
ps.particle_system.emit_direction=perp_a
elseif em.last_x then
ps.pos.x,ps.pos.y=em.last_x,em.last_y
end
ps.particle_system.emit=em.last_x~=nil
end
end
end
local function mask_uv_rect(sd)
local fqx,fqy,fqw,fqh=frame_quad(sd)
if not fqx or not sd.atlas then
return {0,0,0,0}
end
local _,aw,ah=I:i(sd.atlas)
if not aw or aw<=0 or not ah or ah<=0 then
return {0,0,0,0}
end
return {fqx/aw,fqy/ah,fqw/aw,fqh/ah}
end
local function spawn_grass_emitters()
local tpl=this.grass_ps
if not tpl then
return
end
local n_cfg=this.grass_emitters_per_mask or 4
local smin=this.grass_scale_min or 1
local smax=this.grass_scale_max or 1.35
local rot_spread=math.pi*0.5
local area_frac=this.grass_emit_area_frac or 0.25
this._grass_ps={}
local function n_per_for(sid)
if type(n_cfg)=="table" then
return n_cfg[sid] or n_cfg[1] or 4
end
return n_cfg
end
local total_emitters=0
for sid=1,#this.render.sprites do
total_emitters=total_emitters+n_per_for(sid)
end
local rate=(this.grass_rate or 0)/math.max(1,total_emitters)
local area_x,area_y=0,0
do
local A=require("klove.animation_db")
local pt=E:get_template(tpl)
local pname=pt and pt.particle_system and pt.particle_system.name
local fn=pname and A:fn(pname,0,false)
local psd=fn and I:s(fn)
if psd and psd.size then
area_x=psd.size[1]*area_frac
area_y=psd.size[2]*area_frac
end
end
local s1=this.render.sprites[1]
local sd1=s1 and I:s(s1.name)
local mask_im=sd1 and sd1.atlas and I:i(sd1.atlas)
local grass_args
if mask_im then
local bx,by,bw,bh=qrect(this.pos,s1)
grass_args={view_scale=1,mask=mask_im,mask_uv_rect=mask_uv_rect(sd1),mask_rect=bx and {bx,by,bw,bh} or {0,0,0,0},mask_uv_rect_2={0,0,0,0},mask_rect_2={0,0,0,0},view_off={0,0}}
local s2=this.render.sprites[2]
local sd2=s2 and I:s(s2.name)
if sd2 and sd2.atlas==sd1.atlas then
local bx2,by2,bw2,bh2=qrect(this.pos,s2)
if bx2 then
grass_args.mask_uv_rect_2=mask_uv_rect(sd2)
grass_args.mask_rect_2={bx2,by2,bw2,bh2}
end
end
refresh_view_args(grass_args,store)
this._grass_shader_args=grass_args
end
local grass_sh=grass_args and SH:get("p_ps_alpha_mask")
local flip_i=0
for sid,s in ipairs(this.render.sprites) do
local args=s.shader_args
local br=args and args.mask_rect
if br and br[3] and br[3]>0 and br[4] and br[4]>0 then
local qx,qy,qw,qh=br[1],br[2],br[3],br[4]
local ox,oy=args.origin[1],args.origin[2]
local n_per=n_per_for(sid)
local dphi=math.pi*0.5/n_per
for k=1,n_per do
local phi=(k-0.5)*dphi
local ps=E:create_entity(tpl)
flip_i=flip_i+1
local sign=flip_i%2==0 and -1 or 1
ps.particle_system.emit=false
ps.particle_system.emission_rate=rate
ps.particle_system.emit_area_spread=V.v(area_x,area_y)
ps.particle_system.emit_direction=0
ps.particle_system.emit_rotation_spread=rot_spread
ps.particle_system.scale_var={smin,smax}
ps.particle_system.scales_x={sign}
ps.particle_system.scales_y={1}
if grass_sh then
ps.particle_system.shader=grass_sh
ps.particle_system.shader_args=grass_args
end
queue_insert(store,ps)
this._grass_ps[#this._grass_ps+1]={e=ps,id=ps.id,phi=phi,amp=args.noise_amp or 0,nscale=args.noise_scale or 6,ox=ox,oy=oy,sx=ox==0 and 1 or -1,sy=oy==0 and 1 or -1,dsx=args.dist_scale[1],dsy=args.dist_scale[2],qx=qx,qy=qy,qw=qw,qh=qh}
end
end
end
end
local function spawn_overlays()
if this._overlays_spawned then
return
end
this._overlays_spawned=true
for _,item in ipairs(this.overlay_list or {}) do
local o=E:create_entity("decal_stage_216_corrupt_overlay")
o.transition_id=this.id
o.transition_sid=item.transition_sid
o.pos.x,o.pos.y=item.x,item.y
o.holder_id=item.holder_id
o.replace_from=item.replace_from
o.swap_from=item.swap_from
o.swap_to=item.swap_to
if item.name then
local s=o.render.sprites[1]
s.name=item.name
s.z=item.z
s.sort_y_offset=item.sort_y_offset or 0
end
queue_insert(store,o)
end
end
local function set_thresholds(value)
for _,s in ipairs(this.render.sprites) do
if s.shader_args then
s.shader_args.threshold=value
end
end
end
if this._start_final then
set_thresholds(1)
for _,s in ipairs(this.render.sprites) do
s.hidden=false
end
return
end
local lead_args=this.render.sprites[1].shader_args
for i,s in ipairs(this.render.sprites) do
local args=s.shader_args
local sd=I:s(s.name)
local bx,by,bw,bh=qrect(this.pos,s)
if bx then
args.mask_rect={bx,by,bw,bh}
end
if sd and sd.size then
local trim=sd.trim or {0,0}
local w=sd.size[1]-(trim[1] or 0)
local h=sd.size[2]-(trim[2] or 0)
local d=math.sqrt(w*w+h*h)
args.dist_scale={w/d,h/d}
end
refresh_view_args(args,store)
local fr=this.render.frames and this.render.frames[i]
if fr then
fr.shader=SH:clone("p_corrupt_reveal","p_corrupt_reveal#"..this.id..":"..i)
fr.shader_args=args
end
end
local function strip_shaders()
for i=1,#this.render.sprites do
local fr=this.render.frames and this.render.frames[i]
if fr then
fr.shader=nil
fr.shader_args=nil
end
end
end
spawn_overlays()
while true do
for i=1,#this.render.sprites do
local fr=this.render.frames and this.render.frames[i]
local args=this.render.sprites[i].shader_args
if fr and args and not fr.shader then
fr.shader=SH:clone("p_corrupt_reveal","p_corrupt_reveal#"..this.id..":"..i)
fr.shader_args=args
end
end
set_thresholds(0)
for _,s in ipairs(this.render.sprites) do
s.hidden=false
end
stop_all_grass_emitters()
while not this.triggered do
refresh_view()
coroutine.yield()
end
this.triggered=false
local targets=resolve_targets()
if this.skip_anim then
this.skip_anim=false
set_thresholds(1)
refresh_view()
fire_crossed(targets,1)
stop_all_grass_emitters()
else
for _,fog_t in ipairs(this.fog_fx or {}) do
queue_insert(store,E:create_entity(fog_t))
end
U.y_ease_key(store,lead_args,"threshold",0,1,this.reveal_time,this.reveal_ease,function(dt,phase)
local th=lead_args.threshold
for i=2,#this.render.sprites do
local a=this.render.sprites[i].shader_args
if a then
a.threshold=th
end
end
refresh_view()
fire_crossed(targets,th)
update_grass_emitters(th,dt)
end)
set_thresholds(1)
refresh_view()
fire_crossed(targets,1)
stop_all_grass_emitters()
end
strip_shaders()
while not this.triggered do
refresh_view()
coroutine.yield()
end
end
end
function level:init(store)
local scripts=require("scripts")
local r=V.r
local v=V.v
local vv=V.vv
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function towers_portrait_get_info(this)
return {type=STATS_TYPE_TEXT,desc=(this.info.i18n_key or string.upper(this.template_name)).."_DESCRIPTION"}
end
local tt=E:register_t_hot("decal_stage_216_mask_1","decal",true)
tt.render.sprites[1].name="stage_216_mask1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_216_mask_2","decal",true)
tt.render.sprites[1].name="stage_216_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=190
tt=E:register_t_hot("decal_stage_216_mask_3","decal",true)
tt.render.sprites[1].name="stage_216_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_216_mask_4","decal",true)
tt.render.sprites[1].name="stage_216_mask4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_216_mask_5","decal",true)
tt.render.sprites[1].name="stage_216_mask5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_216_mask_6","decal",true)
tt.render.sprites[1].name="stage_216_mask6"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_216_mask_7","decal",true)
tt.render.sprites[1].name="stage_216_mask7"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_easter_egg_stage_216_deku_sprout","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage_216_easteregg_deku_deku_sprout"
tt.render.sprites[1].name="idle"
tt.main_script.update=easter_egg_deku_sprout_update
tt.sound_tap_in="Stage16DekuSproutTapIn"
tt.sound_tap_in_frame=14
tt.sound_tap_out="Stage16DekuSproutTapOut"
tt.sound_tap_out_frame=113
tt.anim_cd=5
tt.ui.click_rect=r(-15,-5,30,30)
tt=E:register_t_hot("tower_stage_216_treant_killer","tower",true)
AC(tt,"attacks","vis","events")
tt.ability_available=true
tt.tower.kind=nil
tt.tower.type="stage_216_treant_killer"
tt.tower.tree_name=""
tt.tower.bullets_zone_1=v(0,0)
tt.tower.bullets_zone_2=v(0,0)
tt.tower.bullets_zone_3=v(0,0)
tt.tower.bullets_zone_radius=90
tt.tower.bullets_min_dist=50
tt.tower.menu_offset=v(2,28)
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.disable_spend_highlight=true
tt.info.fn=towers_portrait_get_info
tt.info.portrait="kr6_info_portraits_towers_0006"
tt.main_script.update=treant_killer_update
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="terrains_%04i"
tt.render.sprites[1].offset=v(0,13)
tt.render.sprites[1].hidden=true
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].animated=true
tt.render.sprites[2].exo=true
tt.render.sprites[2].prefix="old_treantDef"
tt.render.sprites[2].name="sleep_loop"
tt.render.sprites[2].offset=v(0,13)
tt.render.sprites[2].sort_y_offset=11
tt.attacks.range=180
tt.attacks.list[1]=E:clone_c("bullet_attack")
tt.attacks.list[1].bullet="bullet_stage_216_treant_killer_bomb"
tt.attacks.list[1].animation="attack"
tt.attacks.list[1].min_range=0
tt.attacks.list[1].max_range=180
tt.attacks.list[1].projectile_count=3
tt.attacks.list[1].vis_flags=bor(F_RANGED)
tt.attacks.list[1].vis_bans=bor(F_FLYING)
tt.attacks.list[1].cast_time=fts(25)
tt.attacks.list[1].cooldown=40
tt.attacks.list[1].bullet_start_offset=v(-10,120)
tt.attacks.list[1].ability="instakill"
tt.attacks.list[1].instakill_detection_radius=170
tt.attacks.list[1].instakill_radius=50
tt.attacks.list[1].node_prediction=fts(10)
tt.attacks.list[1].sound="Stage16CorruptedTreantLaunch"
tt.attacks.list[1].sound_args={delay=0.86}
tt.sound_transformation="Stage16GoldenGroveCorruptionTree"
tt.sound_transformation_args={delay=0}
tt.sound_instakill="Stage16GoldenTreantEatTongue"
tt.sound_instakill_args={delay=0}
tt.sound_eat="Stage16GoldenTreantEat"
tt.sound_eat_args={delay=0.3}
tt.events.list[1].name="corromper_tree"
tt.events.list[1].on_event=treant_killer_on_corromper_tree
tt.events.list[2]=E:clone_c("event")
tt.events.list[2].name="tirar_treants"
tt.events.list[2].on_event=treant_killer_on_tirar_treants
tt.root_anim="idle"
tt.ui.can_select=false
tt.ui.click_rect=r(-50,0,100,150)
tt.ui.hover_sprite_scale=vv(1.6)
tt.ui.hover_sprite_offset=v(0,20)
tt.vis.bans=F_ALL
tt=E:register_t_hot("decal_stage_216_treant_attacker_bomb_detonation","decal_scripted",true)
tt.render.sprites[1].prefix="t_unitproy_s16"
tt.render.sprites[1].name="landandspawnunit"
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS
tt.t_aura="aura_stage_216_treant_attacker_bomb_damage"
tt.t_seedling=nil
tt.time_to_blow=fts(17)
tt.spawn_count=0
tt.rally_radius=nil
tt.main_script.update=function(this,store)
while true do
coroutine.yield()
end
end
tt.sound="BombExplosionSound"
tt=E:register_t_hot("decal_stage_216_treant_killer_bomb_detonation","decal_stage_216_treant_attacker_bomb_detonation",true)
tt.t_enemy="enemy_rotten_tree_kr6"
tt.spawn_time=fts(1)
tt.sound="Stage16CorruptedTreantImpact"
tt.main_script.update=decal_killer_bomb_update
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="old_treant_hitDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].sort_y_offset=-5
tt=E:register_t_hot("decal_stage_216_treant_killer_bomb_impact","decal_timed",true)
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="old_treant_decalDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("fx_stage_216_treant_killer_tongue","fx",true)
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="old_treant_tongueDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].loop=false
tt.render.sprites[1].scale=v(1,1)
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-100
tt=E:register_t_hot("fx_stage_216_treant_killer_tangle","fx",true)
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="old_treant_tangleDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].loop=false
tt.render.sprites[1].draw_order=DO_MOD_FX
tt=E:register_t_hot("mod_stage_216_treant_killer_tangle","mod_stun",true)
tt.modifier.duration=fts(5)
tt.modifier.vis_flags=bor(F_MOD)
tt.modifier.vis_bans=bor(F_BOSS)
tt.render=nil
tt.main_script.update=scripts.mod_track_target.update
tt=E:register_t_hot("ps_stage_216_treant_killer_bomb_trail","particle_system",true)
tt.particle_system.name="trenant_trail_run"
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.particle_lifetime={fts(9),fts(9)}
tt.particle_system.emission_rate=40
tt.particle_system.emit_offset=v(5,5)
tt.particle_system.emit_rotation_spread=math.pi/2
tt=E:register_t_hot("bullet_stage_216_treant_killer_bomb","arrow5_fixed_height",true)
tt.bullet.damage_min=0
tt.bullet.damage_max=0
tt.bullet.flight_time=fts(40)
tt.bullet.payload="decal_stage_216_treant_killer_bomb_detonation"
tt.bullet.hide_radius=nil
tt.bullet.hit_blood_fx=nil
tt.bullet.hit_fx=nil
tt.bullet.miss_decal=nil
tt.bullet.miss_fx_water=nil
tt.bullet.pop=nil
tt.bullet.prediction_error=nil
tt.bullet.predict_target_pos=nil
tt.bullet.particles_name="ps_stage_216_treant_killer_bomb_trail"
tt.main_script.insert=bullet_killer_bomb_insert
tt.sound_events.insert=nil
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="old_treant_proyectileDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_BULLETS
tt=E:register_t_hot("aura_stage_216_treant_attacker_bomb_damage","aura",true)
tt.aura.radius=50
tt.aura.vis_flags=bor(F_AREA,F_ENEMY)
tt.aura.vis_bans=bor(F_FRIEND)
tt.aura.damage_min=30
tt.aura.damage_max=50
tt.aura.damage_type=DAMAGE_EXPLOSION
tt.main_script.update=scripts.aura_utils.apply_area_damage
tt=E:register_t_hot("ps_stage_216_corrupt_grass","particle_system",true)
tt.particle_system.name="pasto_transicion_proxy_grass_run"
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.animation_fps=15
tt.particle_system.particle_lifetime={0.7333333333333333,0.7333333333333333}
tt.particle_system.alphas={255}
tt.particle_system.scales_x={1}
tt.particle_system.scales_y={1}
tt.particle_system.emit=false
tt.particle_system.emission_rate=1
tt.particle_system.z=Z_OBJECTS_COVERS
local function fog_tpl(name,prefix)
local t=E:register_t_hot(name,"decal_scripted",true)
t.pos=v(512,384)
t.render.sprites[1].animated=false
t.render.sprites[1].exo=true
t.render.sprites[1].prefix=prefix
t.render.sprites[1].name="run"
t.render.sprites[1].loop=false
t.render.sprites[1].z=Z_EFFECTS
t.main_script.update=scripts.decal_utils.animation_in_loop_out.update
t.animation_start="run"
t.delay_animation_start=0
return t
end
fog_tpl("fx_stage_216_fog_a","stg216_fog_aDef")
fog_tpl("fx_stage_216_fog_b","stg216_fog_bDef")
fog_tpl("fx_stage_216_fog_c","stg216_fog_cDef")
fog_tpl("fx_stage_216_fog_d","stg216_fog_dDef")
tt=E:register_t_hot("fx_stage_216_rider_fog_trail","fx",true)
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].prefix="stg216_rider_fog_trailDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=1
tt=E:register_t_hot("controller_stage_216_rider_fog_emitter",nil,true)
AC(tt,"pos","main_script")
tt.emission_rate=2
tt.trail_offset=40
tt.trail_scale={0.8,1.2}
tt.trail_fx="fx_stage_216_rider_fog_trail"
tt.main_script.update=rider_fog_emitter_update
local function corrupt_shader_args(ox,oy)
return {edge_width=0.3,edge_softness=0.1,noise_scale=6,noise_amp=0.18,threshold=0,origin={ox,oy},dist_scale={1,1},edge_color={0.3,0.48,0.25,0.75}}
end
tt=E:register_t_hot("decal_stage_216_corrupt_overlay","decal_scripted",true)
tt.pos=v(512,384)
tt.render.sprites[1].name="stage_216_mask5_b"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].shader="p_corrupt_reveal"
tt.render.sprites[1].hidden=false
tt.transition_shader="p_corrupt_reveal"
tt.main_script.update=nightfall.update
tt=E:register_t_hot("decal_stage_216_bg_corrupt","decal_scripted",true)
tt.apply_final=bg_corrupt.apply_final
tt.pos=v(512,384)
tt.render.sprites[1].name="stage_216_01_b"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[1].shader="p_corrupt_reveal"
tt.render.sprites[1].shader_args=corrupt_shader_args(0,1)
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="stage_216_02_b"
tt.render.sprites[2].animated=false
tt.render.sprites[2].hidden=true
tt.render.sprites[2].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[2].shader="p_corrupt_reveal"
tt.render.sprites[2].shader_args=corrupt_shader_args(1,0)
tt.main_script.update=bg_corrupt.update
tt.reveal_time=2.5
tt.reveal_ease="linear"
tt.fog_fx={"fx_stage_216_fog_a","fx_stage_216_fog_b"}
tt.corromper_list={{tree="tree_1",x=904,y=541.5}}
tt.overlay_list={{replace_from="decal_stage_216_mask_5",name="stage_216_mask5_b",transition_sid=1,y=384,x=512,z=Z_OBJECTS_COVERS}}
tt.grass_ps="ps_stage_216_corrupt_grass"
tt.grass_emitters_per_mask={12,10}
tt.grass_rate=250
tt.grass_emit_area_frac=0.15
tt.grass_scale_min=1
tt.grass_scale_max=2
tt=E:register_t_hot("decal_stage_216_bg_corrupt_2","decal_scripted",true)
tt.apply_final=bg_corrupt.apply_final
tt.pos=v(512,384)
tt.render.sprites[1].name="stage_216_01_c"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[1].sort_y_offset=-10
tt.render.sprites[1].shader="p_corrupt_reveal"
tt.render.sprites[1].shader_args=corrupt_shader_args(0,1)
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="stage_216_02_c"
tt.render.sprites[2].animated=false
tt.render.sprites[2].hidden=true
tt.render.sprites[2].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[2].sort_y_offset=-10
tt.render.sprites[2].shader="p_corrupt_reveal"
tt.render.sprites[2].shader_args=corrupt_shader_args(1,0)
tt.main_script.update=bg_corrupt.update
tt.reveal_time=2.5
tt.reveal_ease="linear"
tt.fog_fx={"fx_stage_216_fog_c","fx_stage_216_fog_d"}
tt.corromper_list={{tree="tree_2",x=188,y=341}}
tt.overlay_list={{replace_from="decal_stage_216_mask_3",name="stage_216_mask3_b",transition_sid=2,y=384,x=512,z=Z_OBJECTS_COVERS},{holder_id="2",swap_from="tower_holder_terrain_3_5",y=512,transition_sid=1,swap_to="tower_holder_terrain_3_4",x=143},{holder_id="15",swap_from="tower_holder_terrain_3_5",y=353,transition_sid=2,swap_to="tower_holder_terrain_3_4",x=951}}
tt.grass_ps="ps_stage_216_corrupt_grass"
tt.grass_emitters_per_mask={12,10}
tt.grass_rate=250
tt.grass_emit_area_frac=0.15
tt.grass_scale_min=1
tt.grass_scale_max=2
self.manual_hero_insertion=false
end
local CORRUPTIONS={{decal="decal_stage_216_bg_corrupt",after_wave=4,rider_interval=1,sound="Stage16GoldenGroveCorruption1",shader_delay=5,camera={x=820,y=500},rider_paths={6,2}},{decal="decal_stage_216_bg_corrupt_2",after_wave=9,rider_interval=2,sound="Stage16GoldenGroveCorruption2",shader_delay=5,camera={x=270,y=380},rider_paths={1,3}}}
local CAM_PAN_TIME=1.8
local CAM_PAN_EASE="in-out-sine"
local RIDERS_ENTRY_DELAY=0
local RIDERS_LAUGH_DELAY=1.5
local SHADER_SOUND_DELAY=0
local function y_wait_wave_end(store,n)
while (not store.next_wave_group_ready or not (n<store.next_wave_group_ready.group_idx)) and not (n<store.wave_group_number) and (not store.waves_finished or not not LU.has_alive_enemies(store)) do
coroutine.yield()
end
end
local function find_entity(store,template_name)
for _,e in pairs(store.entities) do
if e.template_name==template_name then
return e
end
end
return nil
end
local function apply_corruption(store,template_name,instant)
local decal=find_entity(store,template_name)
if not decal then
decal=E:create_entity(template_name)
queue_insert(store,decal)
end
decal.skip_anim=instant or false
decal.triggered=true
return decal
end
local function y_spawn_death_riders(store,ph)
S:queue("Stage16DeathRiderLaugh",{delay=RIDERS_LAUGH_DELAY})
local riders,emitters={},{}
for i,pi in ipairs(ph.rider_paths or {}) do
if i>1 then
U.y_wait(store,ph.rider_interval or 0)
end
local e=E:create_entity("enemy_death_rider")
e.nav_path.pi=pi
e.nav_path.spi=1
e.nav_path.ni=1
U.bans_add(e.vis,F_ALL)
e.health.ignore_damage=true
e.timed_attacks.list[1].disabled=true
queue_insert(store,e)
riders[#riders+1]=e
if not U.is_seen(store,"enemy_death_rider") then
signal.emit("wave-notification","icon","enemy_death_rider")
U.mark_seen(store,"enemy_death_rider")
end
local em=E:create_entity("controller_stage_216_rider_fog_emitter")
em.target_id=e.id
queue_insert(store,em)
emitters[#emitters+1]=em
end
return riders, emitters
end
local function y_corruption_cinematic(store,ph)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",CAM_PAN_TIME,ph.camera,1,CAM_PAN_EASE)
U.y_wait(store,CAM_PAN_TIME+RIDERS_ENTRY_DELAY)
local riders,emitters=y_spawn_death_riders(store,ph)
U.y_wait(store,math.max(0,ph.shader_delay or 0.8))
S:queue(ph.sound,{delay=SHADER_SOUND_DELAY})
local decal=apply_corruption(store,ph.decal)
U.y_wait(store,decal and decal.reveal_time or 3)
for _,em in ipairs(emitters) do
em.finished=true
end
signal.emit("hide-curtains")
signal.emit("show-gui")
for _,r in ipairs(riders) do
if store.entities[r.id] then
U.bans_remove(r.vis,F_ALL)
r.health.ignore_damage=nil
r.timed_attacks.list[1].disabled=nil
end
end
signal.emit("end-cinematic")
end
function level:update(store)
coroutine.yield()
if store.level_mode~=GAME_MODE_CAMPAIGN and store.level_mode~=GAME_MODE_BLITZ and store.level_mode~=GAME_MODE_KR1 then
for _,ph in ipairs(CORRUPTIONS) do
local decal=find_entity(store,ph.decal) or E:create_entity(ph.decal)
decal.apply_final(decal,store)
end
return
end
if store.level_mode~=GAME_MODE_BLITZ then
for _,ph in ipairs(CORRUPTIONS) do
y_wait_wave_end(store,ph.after_wave)
if not main.params.skip_cutscenes then
y_corruption_cinematic(store,ph)
else
apply_corruption(store,ph.decal,true)
end
end
end
end
return level
