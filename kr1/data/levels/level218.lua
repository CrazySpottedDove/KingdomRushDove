local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local GR=require("grid_db")
local GA=require("grid_a_star")
local W=require("wave_db")
local log=require("lib.klua.log"):new("level218")
local signal=require("lib.hump.signal")
local S=require("sound_db")
local scripts=require("scripts")
local RLU=require("all.rally_utils")
require("all.constants")
require("lib.klua.table")
local level={}
local v=V.v
local fts=U.fts
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function find_entity(store,template_name)
for _,e in pairs(store.entities) do
if e.template_name==template_name then
return e
end
end
return nil
end
local function insert_now(store,e)
for _,sys in ipairs(simulation.systems_on_queue_unconditional) do
sys:on_queue_unconditional(e,store)
end
simulation:insert_entity(e)
end
local function is_story_mode(store)
return store.level_mode==GAME_MODE_CAMPAIGN
end
local bit=require("bit")
local band,bnot,bor=bit.band,bit.bnot,bit.bor
local function get_random_round_robin(mutable_history,n,m)
if not m then
m=n
n=1
end
if m<n then
log.error("ERROR: Random round robin needs M to be bigger or equal than N")
end
if #mutable_history==0 then
for i=n,m do
table.insert(mutable_history,i)
end
end
local pos=math.random(1,#mutable_history)
local v=mutable_history[pos]
table.remove(mutable_history,pos)
return v
end
local function fire_puerta_event(store,action)
local handlers=store.event_handlers and store.event_handlers.stage_218_puerta
if not handlers then
return
end
for _,ev in pairs(handlers) do
ev.on_event(store.entities[ev.entity_id],store,ev.name,action)
end
end
local PHASES={{paths={1,2,3,4,5,6,7,8,9,10,17,18,19,20,21,22}},{grid="level218_fase_2",after_wave=5,paths={1,4,5,8,9,10,13,14,15,16,17,20,21,22}},{grid="level218_fase_3",after_wave=9,ensure_night=true,paths={1,9,10,11,12,13,14,15,16,17,21,22}}}
local BOSS_CENTER_SPAWN_DELAY=1.5
local BOSS_SPAWNS={{pi=1,delay=0,flip=true},{pi=12,delay=0},{pi=22,anim="walk_down",delay=BOSS_CENTER_SPAWN_DELAY}}
local IRON_EXTRA_PATHS={}
local PHASES_MAX_PATH=0
for _,ph in ipairs(PHASES) do
for _,pi in ipairs(ph.paths) do
PHASES_MAX_PATH=math.max(PHASES_MAX_PATH,pi)
end
end
local function set_phase_paths(phase_idx)
local set={}
for _,pi in ipairs(PHASES[phase_idx].paths) do
set[pi]=true
end
for pi=1,PHASES_MAX_PATH do
if set[pi] then
P:activate_path(pi)
else
P:deactivate_path(pi)
end
end
log.debug("fase %s: paths activos %s",phase_idx,table.concat(PHASES[phase_idx].paths,","))
end
local function y_wait_wave_end(store,n)
while (not store.next_wave_group_ready or not (n<store.next_wave_group_ready.group_idx)) and not (n<store.wave_group_number) and (not store.waves_finished or not not LU.has_alive_enemies(store)) do
coroutine.yield()
end
end
local function launch_next_wave(store)
if store.next_wave_group_ready then
store.force_next_wave=true
end
end
local function y_wait_level_entities(store)
while not find_entity(store,"decal_stage_218_nightfall") do
coroutine.yield()
end
end
local function trigger_nightfall(store,instant)
local nightfall=find_entity(store,"decal_stage_218_nightfall")
if nightfall then
nightfall.skip_anim=instant or false
nightfall.triggered=true
end
end
local PHASE_1_WATER_TEMPLATES={"decal_stage_218_water_1","decal_stage_218_water_2"}
local function y_fade_phase_1_water(store,instant,max_wait)
local fade_time=0
for _,template_name in ipairs(PHASE_1_WATER_TEMPLATES) do
local water=find_entity(store,template_name)
if water then
if instant then
water.render.sprites[1].hidden=true
simulation:queue_remove_entity(water)
else
water.tween.ts=store.tick_ts
water.tween.disabled=false
fade_time=math.max(fade_time,water.fade_time)
end
end
end
if not instant and fade_time>0 then
local w=math.min(fade_time,max_wait or fade_time)
if w>0 then
U.y_wait(store,w)
end
end
end
local function swap_body_to_phase_2(store)
local body=find_entity(store,"decal_stage_218_veznan_body")
if body then
body.render.sprites[1].prefix="veznan_fase2_balconDef"
U.animation_start(body,"idle",nil,store.tick_ts,true,nil,true)
end
local controller=find_entity(store,"controller_stage_218_veznan")
if controller then
controller._bolts_off=true
if controller._queue then
for i=#controller._queue,1,-1 do
if controller._queue[i].skill=="gem_blast" then
table.remove(controller._queue,i)
end
end
end
controller.hold_casts=nil
end
end
local BOTTOM_EXIT_DEFEND_POINT=v(515,44)
local BOTTOM_EXIT_FLAGS={{flip=1,x=440,y=40},{flip=1,x=590,y=40}}
local function hide_back_portal(store)
local p=find_entity(store,"decal_stage_218_portal_back")
if p then
p.render.sprites[1].hidden=true
end
local dp=E:create_entity("decal_defend_point")
dp.pos.x,dp.pos.y=BOTTOM_EXIT_DEFEND_POINT.x,BOTTOM_EXIT_DEFEND_POINT.y
dp.editor.flip=1
insert_now(store,dp)
for _,f in ipairs(BOTTOM_EXIT_FLAGS) do
local flag=E:create_entity("decal_defense_flag")
flag.pos.x,flag.pos.y=f.x,f.y
flag.editor.flip=f.flip
insert_now(store,flag)
end
end
local function set_front_portals_hidden(store,hidden)
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_218_portal_1" or e.template_name=="decal_stage_218_portal_2" or e.template_name=="decal_stage_218_portal_3" or e.template_name=="decal_stage_218_portal_4" then
e.render.sprites[1].hidden=hidden
end
end
end
local function remove_balcon_masks(store)
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_218_balcon_layer" or e.template_name=="decal_nightfall_overlay" and e.render.sprites[1].name=="stage_218_balcon_layer_02" then
for _,s in ipairs(e.render.sprites) do
s.hidden=true
end
simulation:queue_remove_entity(e)
end
end
end
local function remove_puerta_night_overlay(store)
for _,e in pairs(store.entities) do
if e.template_name=="decal_nightfall_overlay" and e.render.sprites[1].name=="stage_218_18_puerta_terreno_2" then
simulation:queue_remove_entity(e)
end
end
end
local function set_background(store,sprite_name)
local nf=find_entity(store,"decal_stage_218_nightfall")
if nf then
nf.render.sprites[1].hidden=false
for _,s in ipairs(nf.render.sprites) do
s.shader=nil
s.shader_args=nil
s._shader=nil
end
nf.set_day_bg_hidden(nf,store,true)
end
if sprite_name then
local overlay=find_entity(store,"decal_stage_218_bg_overlay")
if overlay then
overlay.render.sprites[1].name=sprite_name
else
overlay=E:create_entity("decal_stage_218_bg_overlay")
overlay.render.sprites[1].name=sprite_name
simulation:queue_insert_entity(overlay)
end
end
end
local function walk_mask(e)
return e.nav_grid and e.nav_grid.valid_terrains or bor(TERRAIN_LAND,TERRAIN_ICE)
end
local function is_walkable(x,y,mask)
return band(GR:cell_type(x,y),bnot(mask))==0
end
local function nearest_walkable_pos(x,y,mask)
local i,j=GR:get_coords(x,y)
local function vfn(_,_,cell)
return band(cell,bnot(mask))==0
end
local c=GA.find_nearest_valid(v(i,j),GR.grid,vfn,24)
if not c then
return nil
end
return V.v(GR:cell_pos(c.x,c.y))
end
local function nearest_mid_path_pos(x,y,mask)
local nn=P:nearest_nodes(x,y,nil,{1},true,NF_RALLY)
if nn and #nn>0 then
return P:node_pos(nn[1][1],nn[1][2],nn[1][3])
end
return nil
end
local function relocate_stranded_units(store,walk)
local towers_map={}
local units={}
local function mute_rally_taunt(e)
if walk and e.sound_events and e.sound_events.change_rally_point then
e._saved_rally_sound=e.sound_events.change_rally_point
e.sound_events.change_rally_point=nil
end
end
for _,e in pairs(store.entities) do
if not e.pos then
elseif e.hero or e.reinforcement then
if e.health and e.health.dead and not e.hero then
else
local mask=walk_mask(e)
local dead=e.health and e.health.dead
if not is_walkable(e.pos.x,e.pos.y,mask) then
local dest=nearest_walkable_pos(e.pos.x,e.pos.y,mask)
if dest then
dest=nearest_mid_path_pos(dest.x,dest.y,mask) or dest
if dead then
e.force_respawn=true
end
if not walk then
e.pos.x,e.pos.y=dest.x,dest.y
end
if e.nav_rally then
e.nav_rally.center=V.vclone(dest)
e.nav_rally.pos=V.vclone(dest)
if e.nav_grid then
e.nav_grid.waypoints={}
end
e.nav_rally.new=true
mute_rally_taunt(e)
end
units[#units+1]=e
else
log.warning("relocate: sin celda caminable cerca de (%s,%s) para %s",e.pos.x,e.pos.y,e.template_name)
end
elseif not dead and e.nav_rally and not is_walkable(e.nav_rally.pos.x,e.nav_rally.pos.y,mask) then
e.nav_rally.center=V.vclone(e.pos)
e.nav_rally.pos=V.vclone(e.pos)
if e.nav_grid then
e.nav_grid.waypoints={}
end
e.nav_rally.new=true
mute_rally_taunt(e)
units[#units+1]=e
end
end
elseif e.soldier and e.soldier.tower_id then
if not is_walkable(e.pos.x,e.pos.y,walk_mask(e)) then
local tw=store.entities[e.soldier.tower_id]
if tw and tw.barrack then
towers_map[tw.id]=tw
end
end
elseif e.barrack and e.tower and e.tower.default_rally_pos then
local rp=e.barrack.rally_pos
local mask=e.barrack.rally_terrains or bor(TERRAIN_LAND,TERRAIN_ICE)
if rp and not is_walkable(rp.x,rp.y,mask) then
towers_map[e.id]=e
end
end
end
local towers={}
for _,tw in pairs(towers_map) do
local def=tw.tower.default_rally_pos
if def then
local mask=tw.barrack.rally_terrains or bor(TERRAIN_LAND,TERRAIN_ICE)
local dest=is_walkable(def.x,def.y,mask) and V.vclone(def) or nearest_walkable_pos(def.x,def.y,mask) or V.vclone(def)
RLU.fire_rally_fn(tw,store,dest.x,dest.y)
end
towers[#towers+1]=tw
end
return {units=units,towers=towers}
end
local function apply_phase_terrain(store,idx,walk)
local ph=PHASES[idx]
set_phase_paths(idx)
local tracked
if ph.grid then
if GR:load(ph.grid) then
tracked=relocate_stranded_units(store,walk)
else
log.error("fase %s: no se pudo cargar el grid \"%s\"",idx,ph.grid)
end
end
return tracked
end
local function apply_phase_background(store,idx)
local ph=PHASES[idx]
if ph.background or ph.ensure_night then
set_background(store,ph.background)
end
end
local function apply_phase(store,idx)
apply_phase_terrain(store,idx,false)
apply_phase_background(store,idx)
end
local function y_wait_relocation_settled(store,tracked,timeout)
local deadline=store.tick_ts+(timeout or 6)
local function arrived(e)
if not store.entities[e.id] or not e.pos or not e.nav_rally then
return true
end
if e.health and e.health.dead then
return false
end
return not e.nav_rally.new and V.dist(e.pos.x,e.pos.y,e.nav_rally.pos.x,e.nav_rally.pos.y)<=16
end
while deadline>store.tick_ts do
local all=true
for _,e in ipairs(tracked.units) do
if not arrived(e) then
all=false
break
end
end
if all then
for _,tw in ipairs(tracked.towers) do
if store.entities[tw.id] and tw.barrack then
if tw.barrack.rally_new then
all=false
break
end
for _,s in ipairs(tw.barrack.soldiers) do
if not arrived(s) then
all=false
break
end
end
if not all then
break
end
end
end
end
if all then
break
end
coroutine.yield()
end
for _,e in ipairs(tracked.units) do
if store.entities[e.id] and e._saved_rally_sound then
e.sound_events.change_rally_point=e._saved_rally_sound
e._saved_rally_sound=nil
end
end
end
local DENAS_SQUADS_POS={{pos=V.v(388,322),entry_offset=V.v(-30,0)},{pos=V.v(634,322),entry_offset=V.v(30,0)},{pos=V.v(513,178),entry_offset=V.v(0,-30)}}
local VEZNAN_TAUNT2_FRAMES=104
local VEZNAN_SNAP_FRAME=29
local VEZNAN_REVEAL_FRAME=29
local DENAS_POS=V.v(512,234)
local DENAS_POS_INITIAL=V.v(512,-100)
local function spawn_denas(store,instant)
local denas=E:create_entity("hero_stage_218_denas")
denas.ignore_in_animation=true
denas.initial_squads_pos=DENAS_SQUADS_POS
local pos=instant and DENAS_POS or DENAS_POS_INITIAL
if not instant then
denas.cinematic_entrance_to=V.vclone(DENAS_POS)
end
denas.pos=V.vclone(pos)
if denas.nav_rally then
denas.nav_rally.center=V.vclone(denas.pos)
denas.nav_rally.pos=V.vclone(denas.pos)
end
if denas.hero then
denas.hero.xp=0
denas.hero.level=1
end
simulation:queue_insert_entity(denas)
signal.emit("hero-added-no-panel",denas)
return denas
end
local K="enemy_dark_knight_kr6"
local DENAS_INTRO_SLAYERS={{pair="f10",spi=1,delay=0,stop_ni=43,path=10,entity=K},{pair="f10",spi=2,delay=0.6,stop_ni=47,path=10,entity=K},{pair="f10",spi=3,delay=0.6,stop_ni=43,path=10,entity=K},{pair="f10",spi=1,delay=1.6,stop_ni=43,path=10},{pair="f18",spi=1,delay=1,stop_ni=33,path=18,entity=K},{pair="f18",spi=2,delay=1.6,stop_ni=40,path=18,entity=K},{pair="f18",spi=3,delay=1.6,stop_ni=36,path=18,entity=K},{pair="f18",spi=1,delay=2.6,stop_ni=33,path=18},{portal=1,pair="fi1",spi=1,delay=2.5,stop_ni=10,path=17,entity=K},{portal=1,pair="fi1",spi=2,delay=3.1,stop_ni=10,path=17,entity=K},{portal=1,pair="fi1",spi=3,delay=3.1,stop_ni=10,path=17,entity=K},{portal=1,pair="fi1",spi=1,delay=4.1,stop_ni=10,path=17},{portal=3,pair="fd1",spi=1,delay=3,stop_ni=10,path=20,entity=K},{portal=3,pair="fd1",spi=2,delay=3.6,stop_ni=10,path=20,entity=K},{portal=3,pair="fd1",spi=3,delay=3.6,stop_ni=10,path=20,entity=K},{portal=3,pair="fd1",spi=1,delay=4.6,stop_ni=10,path=20},{pair="f9",spi=1,delay=4,stop_ni=22,path=9,entity=K},{pair="f9",spi=2,delay=4.6,stop_ni=22,path=9,entity=K},{pair="f9",spi=3,delay=4.6,stop_ni=22,path=9,entity=K},{pair="f9",spi=1,delay=5.6,stop_ni=22,path=9},{pair="f19",spi=1,delay=4.3,stop_ni=22,path=19,entity=K},{pair="f19",spi=2,delay=4.9,stop_ni=22,path=19,entity=K},{pair="f19",spi=3,delay=4.9,stop_ni=22,path=19,entity=K},{pair="f19",spi=1,delay=5.9,stop_ni=22,path=19}}
local SLAYER_ENTRY_SPEED_FACTOR=2
local ENTRY_SPEED_FACTOR_BY_PATH={[20]=1,[17]=1}
local function entry_speed_factor(pi)
return ENTRY_SPEED_FACTOR_BY_PATH[pi] or SLAYER_ENTRY_SPEED_FACTOR
end
local PORTAL_OPEN_LEAD=1
local PORTAL_CLOSE_LAG=1.2
local INTRO_BOMB_DAMAGE_RADIUS=110
local function spawn_intro_slayer(store,cfg)
local e=E:create_entity(cfg.entity or "enemy_dark_slayer")
e.nav_path.pi=cfg.path
e.nav_path.spi=cfg.spi
e.nav_path.ni=1
e.pos=P:node_pos(cfg.path,cfg.spi,1)
U.bans_add(e.vis,F_ALL)
e.health.hp_max=1
e.health.hp=1
e.health_bar.hidden=true
e.enemy.gold=0
U.update_max_speed(e,E:get_template("enemy_dark_slayer").motion.max_speed*entry_speed_factor(cfg.path))
simulation:queue_insert_entity(e)
if cfg.portal then
for _,tu in pairs(store.entities) do
if tu.tunnel and tu.tunnel.place_pi==cfg.path and tu.tunnel.place_fx then
local fx=E:create_entity(tu.tunnel.place_fx)
fx.pos=V.v(e.pos.x,e.pos.y)
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
break
end
end
end
return e
end
local function spawn_intro_bomb(store,pos)
local vc=store.visible_coords
local mid_x=(vc.left+vc.right)/2
local e=E:create_entity("bullet_denas_bombardement")
e.pos.x=mid_x>pos.x and vc.left or vc.right
e.pos.y=vc.bottom-60
e.bullet.from=V.vclone(e.pos)
e.bullet.to=V.vclone(pos)
e.bullet.hit_fx="fx_denas_catapult_explosion_1"
e.bullet.hit_decal="decal_denas_catapult_floor_1"
e.bullet.damage_flags=0
e.bullet.damage_radius=INTRO_BOMB_DAMAGE_RADIUS
simulation:queue_insert_entity(e)
end
local function y_denas_intro_sequence(store)
local flight_time=E:get_template("bullet_denas_bombardement").bullet.flight_time
local base_speed=E:get_template("enemy_dark_slayer").motion.max_speed
local function lane_arc(cfg,from_ni,to_ni)
local nodes=P.paths[cfg.path][cfg.spi]
local d=0
for k=from_ni,to_ni-1 do
local a,b=nodes[k],nodes[k+1]
d=d+V.dist(a.x,a.y,b.x,b.y)
end
return d
end
local function remaining_to_stop(s)
local e=s.e
local ni=e.nav_path.ni
if ni>=s.cfg.stop_ni then
return 0
end
local nodes=P.paths[s.cfg.path][s.cfg.spi]
local nnext=nodes[ni+1] or nodes[ni]
return V.dist(e.pos.x,e.pos.y,nnext.x,nnext.y)+lane_arc(s.cfg,ni+1,s.cfg.stop_ni)
end
local slayers,singles,pair_list,by_pair={},{},{},{}
for _,cfg in ipairs(DENAS_INTRO_SLAYERS) do
local node=P:node_pos(cfg.path,cfg.spi,cfg.stop_ni)
local s={cfg=cfg,spawn_at=cfg.delay or 0}
slayers[#slayers+1]=s
if cfg.pair then
local g=by_pair[cfg.pair]
if not g then
g={arrival_sum=0,n=0,target=V.v(0,0)}
by_pair[cfg.pair]=g
pair_list[#pair_list+1]=g
end
g.target.x=g.target.x+node.x
g.target.y=g.target.y+node.y
g.arrival_sum=g.arrival_sum+s.spawn_at+lane_arc(cfg,1,cfg.stop_ni)/(base_speed*entry_speed_factor(cfg.path))
g.n=g.n+1
else
s.target=node
singles[#singles+1]=s
end
end
for _,g in ipairs(pair_list) do
g.target.x,g.target.y=g.target.x/g.n,g.target.y/g.n
g.fire_at=math.max(0,g.arrival_sum/g.n-flight_time)
end
local portal_list,by_portal={},{}
for _,s in ipairs(slayers) do
local pidx=s.cfg.portal
if pidx then
local po=by_portal[pidx]
if not po then
po={idx=pidx,open_at=s.spawn_at,close_at=s.spawn_at}
by_portal[pidx]=po
portal_list[#portal_list+1]=po
end
po.open_at=math.min(po.open_at,s.spawn_at)
po.close_at=math.max(po.close_at,s.spawn_at)
end
end
for _,po in ipairs(portal_list) do
po.open_at=math.max(0,po.open_at-PORTAL_OPEN_LEAD)
po.close_at=po.close_at+PORTAL_CLOSE_LAG
end
local t0=store.tick_ts
local unspawned=#slayers
local pending=#singles+#pair_list
local portal_pending=#portal_list*2
while (pending>0 or unspawned>0 or portal_pending>0) and store.tick_ts-t0<25 do
local elapsed=store.tick_ts-t0
for _,po in ipairs(portal_list) do
if not po.opened and elapsed>=po.open_at then
po.opened=true
portal_pending=portal_pending-1
local pe=find_entity(store,"decal_stage_218_portal_"..po.idx)
if pe then
pe._force_open=true
pe._want="open"
end
end
if not po.closed and elapsed>=po.close_at then
po.closed=true
portal_pending=portal_pending-1
local pe=find_entity(store,"decal_stage_218_portal_"..po.idx)
if pe then
pe._force_open=nil
pe._want="close"
end
end
end
for _,s in ipairs(slayers) do
if not s.e and elapsed>=s.spawn_at then
s.e=spawn_intro_slayer(store,s.cfg)
unspawned=unspawned-1
end
end
for _,g in ipairs(pair_list) do
if not g.fired and elapsed>=g.fire_at then
spawn_intro_bomb(store,g.target)
g.fired=true
pending=pending-1
end
end
for _,s in ipairs(singles) do
if not s.fired and s.e then
local e=s.e
local launch
launch=e.health.dead and true or remaining_to_stop(s)<=e.motion.max_speed*flight_time
if launch then
spawn_intro_bomb(store,s.target)
s.fired=true
pending=pending-1
end
end
end
if pending>0 or unspawned>0 or portal_pending>0 then
coroutine.yield()
end
end
U.y_wait(store,flight_time+0.3)
for _,s in ipairs(slayers) do
local e=s.e
if e and store.entities[e.id] and not e.health.dead then
e.health.last_damage_types=DAMAGE_EXPLOSION
e.health.hp=0
e.health.dead=true
end
end
end
local INTRO_TAUNTS={{"taunt3_in","S18_INTRO_01"},{"taunt1","S18_INTRO_02"}}
local BALCONY_BALLOON_OFFSET=V.v(-5,-12)
local function balcony_balloon_pos(body)
return V.v(body.pos.x+BALCONY_BALLOON_OFFSET.x,body.pos.y+BALCONY_BALLOON_OFFSET.y)
end
local function y_intro_cinematic(store)
if store.restarted or main.params.skip_cutscenes or not is_story_mode(store) then
return
end
coroutine.yield()
local body=find_entity(store,"decal_stage_218_veznan_body")
if not body then
return
end
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",0.8,v(512,768),1.3)
U.y_wait(store,1)
body.render.sprites[1].hidden=false
S:queue("Stage218IntroCinematicVeznanEyesAppear")
U.y_animation_play(body,"in",nil,store.tick_ts,1)
for _,taunt in ipairs(INTRO_TAUNTS) do
U.y_wait(store,0.3)
signal.emit("show-balloon_tutorial-pos",taunt[2],false,balcony_balloon_pos(body))
U.y_animation_play(body,taunt[1],nil,store.tick_ts,1)
end
U.animation_start(body,"idle",nil,store.tick_ts,true,nil,true)
U.y_wait(store,0.5)
signal.emit("pan-zoom-camera",0.6,v(512,450),1)
signal.emit("show-gui")
signal.emit("end-cinematic")
end
local function switch_to_phase_2_music()
S:stop_group("MUSIC")
S:queue("MusicBattle_2_218")
end
local function close_portals(store)
for _,e in pairs(store.entities) do
if e.template_name and string.find(e.template_name,"decal_stage_218_portal",1,true) then
e._want="close"
end
end
end
local function open_top_portals(store,silent)
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_218_portal_2" or e.template_name=="decal_stage_218_portal_4" then
e._want="open"
e._mute_sfx=silent or nil
end
end
end
local T2_FX={fx_stage_218_portal_efecto_flip="fx_stage_218_portal_efecto_t2_flip",fx_stage_218_portal_efecto="fx_stage_218_portal_efecto_t2"}
local function swap_portals_to_phase_2(store)
for _,e in pairs(store.entities) do
local n=e.template_name
if n=="decal_stage_218_portal_1" or n=="decal_stage_218_portal_2" or n=="decal_stage_218_portal_3" or n=="decal_stage_218_portal_4" then
e.render.sprites[1].prefix="st_218_terreno_2_animations_portal_"..string.sub(n,-1).."Def"
local anim=e._state=="open" and "on_loop" or "off_idle"
U.animation_start(e,anim,nil,store.tick_ts,true,1,true)
elseif e.tunnel then
if T2_FX[e.tunnel.pick_fx] then
e.tunnel.pick_fx=T2_FX[e.tunnel.pick_fx]
end
if T2_FX[e.tunnel.place_fx] then
e.tunnel.place_fx=T2_FX[e.tunnel.place_fx]
end
end
end
end
local function apply_night_visuals(store,sync)
y_fade_phase_1_water(store,true)
remove_puerta_night_overlay(store)
if sync then
local nightfall=find_entity(store,"decal_stage_218_nightfall")
if nightfall then
nightfall.apply_final(nightfall,store)
end
else
trigger_nightfall(store,true)
end
remove_balcon_masks(store)
hide_back_portal(store)
swap_body_to_phase_2(store)
local puerta=find_entity(store,"decal_stage_218_puerta")
if puerta then
puerta.on_nightfall(puerta,store)
end
swap_portals_to_phase_2(store)
open_top_portals(store,true)
end
local function y_phase_2_transition(store)
apply_phase(store,2)
local controller=find_entity(store,"controller_stage_218_veznan")
if controller then
controller.hold_casts=true
end
if main.params.skip_cutscenes then
apply_night_visuals(store)
spawn_denas(store,true)
switch_to_phase_2_music()
launch_next_wave(store)
return
end
signal.emit("hide-gui")
signal.emit("start-cinematic")
close_portals(store)
signal.emit("pan-zoom-camera",0.6,v(512,400),1)
U.y_wait(store,1.5)
local body=find_entity(store,"decal_stage_218_veznan_body")
if body then
signal.emit("show-balloon_tutorial-pos","S18_TRANS_00",false,balcony_balloon_pos(body))
U.animation_start(body,"taunt1",nil,store.tick_ts,false,1,true)
end
U.y_wait(store,2)
for _,cfg in ipairs(DENAS_INTRO_SLAYERS) do
if cfg.portal then
local pe=find_entity(store,"decal_stage_218_portal_"..cfg.portal)
if pe and not pe._force_open then
pe._force_open=true
pe._want="open"
end
end
end
if body then
U.y_animation_wait(body)
U.animation_start(body,"idle",nil,store.tick_ts,true,nil,true)
end
P:activate_path(18)
P:activate_path(19)
y_denas_intro_sequence(store)
P:deactivate_path(18)
P:deactivate_path(19)
local boom=E:create_entity("fx_stage_218_explosion_entrada_denas")
boom.pos=V.v(512,384)
boom.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(boom)
S:queue("Stage218MidCinematicPortalBreak")
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=0.6
shake.aura.freq_factor=6
simulation:queue_insert_entity(shake)
local denas=spawn_denas(store,false)
U.y_wait(store,0.2)
hide_back_portal(store)
local body=find_entity(store,"decal_stage_218_veznan_body")
while not denas.cinematic_entrance_done do
coroutine.yield()
end
if body then
signal.emit("show-balloon_tutorial-pos","S18_TRANS_02",false,balcony_balloon_pos(body))
U.y_animation_play(body,"taunt1",nil,store.tick_ts,1)
U.animation_start(body,"idle",nil,store.tick_ts,true,nil,true)
end
local puerta=find_entity(store,"decal_stage_218_puerta")
if body then
signal.emit("show-balloon_tutorial-pos","S18_TRANS_03",false,balcony_balloon_pos(body))
S:queue("Stage218VeznanLaugh")
S:queue("Stage218MidCinematicTowerVeznanSnap",{delay=fts(VEZNAN_TAUNT2_FRAMES+VEZNAN_SNAP_FRAME)})
U.y_animation_play(body,"taunt2",nil,store.tick_ts,1)
local balcon_mask=find_entity(store,"decal_stage_218_balcon_layer")
if balcon_mask then
balcon_mask.render.sprites[1].hidden=false
end
denas.cinematic_look_start=true
S:queue("Stage218MidCinematicTowerVeznanReveal",{delay=fts(VEZNAN_REVEAL_FRAME)})
U.y_animation_play(body,"transform_in",nil,store.tick_ts,1)
body.render.sprites[1].prefix="veznan_fase2_balconDef"
U.animation_start(body,"idle_nobalcon",nil,store.tick_ts,true,nil,true)
end
denas.cinematic_look_start=true
y_fade_phase_1_water(store,false,0)
set_front_portals_hidden(store,true)
swap_portals_to_phase_2(store)
local nf=find_entity(store,"decal_stage_218_nightfall")
remove_puerta_night_overlay(store)
trigger_nightfall(store,false)
S:queue("Stage218MidCinematicLevelIllusionReveal")
U.y_wait(store,nf and nf.reveal_time or 4)
denas.cinematic_look_end=true
if store.entities[boom.id] then
simulation:queue_remove_entity(boom)
end
if puerta and store.entities[puerta.id] then
puerta.on_nightfall(puerta,store)
end
set_front_portals_hidden(store,false)
open_top_portals(store)
remove_balcon_masks(store)
swap_body_to_phase_2(store)
while not denas.cinematic_look_done do
coroutine.yield()
end
switch_to_phase_2_music()
signal.emit("pan-zoom-camera",0.6,v(512,450),1)
signal.emit("show-gui")
signal.emit("end-cinematic")
launch_next_wave(store)
end
local PHASE3_TAUNT={"taunt2","S18_PHASE3_01"}
local GRIETA_FRAMES=66
local MOLOCH_APPEAR_DELAY=0.5
local MOLOCH_DEATH_DELAY=fts(13)
local MOLOCH_DEATH_SHAKE={freq_factor=6,amplitude=0.8,duration=fts(50)}
local MOLOCH_DEATH_RUMBLE={amplitude=0.15,freq_factor=2}
local MOLOCH_RUMBLE={delay=0.3,freq_factor=2,amplitude=0.15}
local function y_phase_3_transition(store)
local function appear_moloch()
local moloch=find_entity(store,"controller_stage_218_moloch")
if moloch then
moloch._appear=true
end
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_218_portal_3" or e.template_name=="decal_stage_218_portal_4" then
e.render.sprites[1].hidden=true
end
end
end
if not is_story_mode(store) or store.restarted or main.params.skip_cutscenes then
apply_phase(store,3)
appear_moloch()
launch_next_wave(store)
return
end
signal.emit("hide-gui")
signal.emit("start-cinematic")
close_portals(store)
signal.emit("pan-zoom-camera",0.6,v(512,400),1)
local controller=find_entity(store,"controller_stage_218_veznan")
if controller then
controller.hold_casts=true
end
local tracked=apply_phase_terrain(store,3,true)
if tracked then
y_wait_relocation_settled(store,tracked,6)
end
signal.emit("pan-zoom-camera",0.8,v(512,768),1.3)
U.y_wait(store,1)
local body=find_entity(store,"decal_stage_218_veznan_body")
if body then
while body.render.sprites[1].name~="idle" do
coroutine.yield()
end
signal.emit("show-balloon_tutorial-pos",PHASE3_TAUNT[2],false,balcony_balloon_pos(body))
U.y_animation_play(body,PHASE3_TAUNT[1],nil,store.tick_ts,1)
U.animation_start(body,"summon_oroch",nil,store.tick_ts,false)
end
U.y_wait(store,fts(54))
local campana=E:create_entity("fx_stage_218_campana")
campana.pos=V.v(512,384)
campana.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(campana)
local ct=E:get_template("fx_stage_218_campana")
local last_ray=ct.sound_bell_frames[#ct.ray_positions]+ct.ray_delay_frames
local appear_wait=fts(last_ray)+fts(GRIETA_FRAMES)+MOLOCH_APPEAR_DELAY
local rumble_start=fts(last_ray)+MOLOCH_RUMBLE.delay
U.y_wait(store,rumble_start)
local mt=E:get_template("controller_stage_218_moloch")
local rumble=E:create_entity("aura_screen_shake")
rumble.aura.amplitude=MOLOCH_RUMBLE.amplitude
rumble.aura.duration=appear_wait-rumble_start+mt.appear_shakes[1].time
rumble.aura.freq_factor=MOLOCH_RUMBLE.freq_factor
rumble.aura.reverse_fade=true
simulation:queue_insert_entity(rumble)
U.y_wait(store,appear_wait-rumble_start)
apply_phase_background(store,3)
appear_moloch()
if body then
U.y_animation_wait(body)
U.animation_start(body,"idle",nil,store.tick_ts,true,nil,true)
end
U.y_wait(store,10)
if controller then
controller.hold_casts=nil
end
signal.emit("pan-zoom-camera",0.6,v(512,450),1)
signal.emit("show-gui")
signal.emit("end-cinematic")
launch_next_wave(store)
end
local BOSS_TAUNT={"taunt3","S18_BOSS_01"}
local function y_boss_phase(store)
for _,sp in ipairs(BOSS_SPAWNS) do
P:activate_path(sp.pi)
end
local body=find_entity(store,"decal_stage_218_veznan_body")
local controller=find_entity(store,"controller_stage_218_veznan")
if controller then
controller.hold_casts=true
while body and body.render.sprites[1].name~="idle" do
coroutine.yield()
end
simulation:queue_remove_entity(controller)
end
local boss_t=E:get_template("enemy_stage_218_veznan")
local cine=is_story_mode(store) and not store.restarted and not main.params.skip_cutscenes and body~=nil
if cine then
signal.emit("hide-gui")
signal.emit("start-cinematic")
S:stop_group("MUSIC")
S:queue("MusicBossPreFight_218")
close_portals(store)
signal.emit("pan-zoom-camera",0.8,v(512,768),1.3)
U.y_wait(store,1)
signal.emit("show-balloon_tutorial-pos",BOSS_TAUNT[2],false,balcony_balloon_pos(body))
U.y_animation_play(body,BOSS_TAUNT[1],nil,store.tick_ts,1)
U.y_wait(store,0.2)
U.animation_start(body,"out_balcon",nil,store.tick_ts,false)
U.y_wait(store,3.8)
fire_puerta_event(store,"open")
U.y_animation_wait(body)
U.animation_start(body,"idle_balcononly",nil,store.tick_ts,true,nil,true)
U.y_wait(store,0.3)
signal.emit("pan-zoom-camera",0.6,v(512,450),1)
U.y_wait(store,0.6)
S:stop_group("MUSIC")
S:queue("MusicBossFight_218")
elseif body then
U.animation_start(body,"idle_balcononly",nil,store.tick_ts,true,nil,true)
U.y_wait(store,boss_t.spawn_delay or 3)
end
local shared={illusions_killed=0}
local bosses={}
local spawn_ts=store.tick_ts
for i,sp in ipairs(BOSS_SPAWNS) do
U.y_wait(store,sp.delay-(store.tick_ts-spawn_ts))
local boss=E:create_entity("enemy_stage_218_veznan_illusion")
boss.nav_path.pi=sp.pi
boss.nav_path.spi=1
boss.nav_path.ni=1
boss.pos=P:node_pos(sp.pi,1,1)
boss.shared=shared
boss.stagger_idx=#BOSS_SPAWNS-i
U.bans_add(boss.vis,F_ALL)
if sp.flip then
boss.render.sprites[1].flip_x=true
elseif sp.anim then
boss.render.sprites[1].name=sp.anim
end
simulation:queue_insert_entity(boss)
table.insert(bosses,boss)
end
U.y_wait(store,1)
for _,boss in ipairs(bosses) do
U.bans_remove(boss.vis,F_ALL)
boss.cinematic=false
end
if cine then
signal.emit("show-gui")
signal.emit("end-cinematic")
end
W:start_manual_wave("Boss_1")
if not U.is_seen(store,"enemy_stage_218_veznan_illusion") then
signal.emit("wave-notification","icon","enemy_stage_218_veznan_illusion")
U.mark_seen(store,"enemy_stage_218_veznan_illusion")
end
local function real_death_started()
local real=find_entity(store,"enemy_stage_218_veznan")
return real and real._death_started
end
while LU.has_alive_enemies(store) and not real_death_started() do
coroutine.yield()
end
local moloch=find_entity(store,"controller_stage_218_moloch")
local body=find_entity(store,"decal_stage_218_moloch_body")
if moloch then
moloch._queue={}
moloch._abort=true
while moloch._casting do
coroutine.yield()
end
for _,e in pairs(store.entities) do
if e.template_name==moloch.lava_ball.spawn_template and e.health and not e.health.dead then
local d=E:create_entity("damage")
d.source_id=moloch.id
d.target_id=e.id
d.damage_type=DAMAGE_INSTAKILL
table.insert(store.damage_queue,d)
end
end
simulation:queue_remove_entity(moloch)
end
local real=find_entity(store,"enemy_stage_218_veznan")
while real and store.entities[real.id] and not real._death_loop_ts do
coroutine.yield()
end
while real and store.entities[real.id] and store.tick_ts-real._death_loop_ts<MOLOCH_DEATH_DELAY do
coroutine.yield()
end
if body then
S:queue(body.death_sound)
U.animation_start(body,"death",nil,store.tick_ts,false)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=MOLOCH_DEATH_SHAKE.amplitude
shake.aura.duration=MOLOCH_DEATH_SHAKE.duration
shake.aura.freq_factor=MOLOCH_DEATH_SHAKE.freq_factor
simulation:queue_insert_entity(shake)
U.y_wait(store,MOLOCH_DEATH_SHAKE.duration)
if real and store.entities[real.id] then
local rumble_time=real._death_loop_ts+real.death_loop_time-real.death_end_shake_lead-store.tick_ts
if rumble_time>0 then
local rumble=E:create_entity("aura_screen_shake")
rumble.aura.amplitude=MOLOCH_DEATH_RUMBLE.amplitude
rumble.aura.duration=rumble_time
rumble.aura.freq_factor=MOLOCH_DEATH_RUMBLE.freq_factor
rumble.aura.reverse_fade=true
simulation:queue_insert_entity(rumble)
end
end
U.y_animation_wait(body)
end
while real and store.entities[real.id] and not real._death_finished do
coroutine.yield()
end
end
local function remove_veznan(store)
local body=find_entity(store,"decal_stage_218_veznan_body")
if body then
simulation:queue_remove_entity(body)
end
local controller=find_entity(store,"controller_stage_218_veznan")
if controller then
simulation:queue_remove_entity(controller)
end
end
local function apply_moloch_wasteland(store)
local mt=E:get_template("controller_stage_218_moloch")
for _,name in ipairs(mt.masks_off_on_appear or {}) do
for _,e in pairs(store.entities) do
if e.template_name==name or e.template_name=="decal_nightfall_overlay" and e.hide_from==name then
for _,s in ipairs(e.render.sprites) do
s.hidden=true
end
simulation:queue_remove_entity(e)
end
end
end
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_218_portal_3" or e.template_name=="decal_stage_218_portal_4" then
e.render.sprites[1].hidden=true
end
end
local mascara=E:create_entity(mt.mascara_fondo_decal_t)
mascara.render.sprites[1].hidden=false
mascara.render.sprites[2].hidden=false
insert_now(store,mascara)
insert_now(store,E:create_entity(mt.camino_decal_t))
end
local function setup_state_2(store)
apply_phase_terrain(store,2,false)
y_wait_level_entities(store)
apply_night_visuals(store,true)
relocate_stranded_units(store,false)
end
local function setup_state_3(store)
apply_phase_terrain(store,3,false)
y_wait_level_entities(store)
apply_phase_background(store,3)
apply_night_visuals(store,true)
apply_moloch_wasteland(store)
for _,pi in ipairs(IRON_EXTRA_PATHS) do
P:activate_path(pi)
end
spawn_denas(store,true)
coroutine.yield()
relocate_stranded_units(store,false)
end
local function y_phase_2_music_on_battle_start(store)
while store.wave_group_number<1 do
coroutine.yield()
end
switch_to_phase_2_music()
end
level.skippable_cutscenes=true
function level:init(store)
local E=require("entity_db")
local function is_story_mode(store)
return store.level_mode==GAME_MODE_CAMPAIGN
end
local body_tpl=E:get_template("decal_stage_218_veznan_body")
body_tpl.render.sprites[1].hidden=not is_story_mode(store) or (not store.restarted and not main.params.skip_cutscenes)
store.next_wave_group_ready=nil
store.wave_group_number=0
store.waves_finished=false
store.force_next_wave=false
store.send_next_wave=false
self.manual_hero_insertion=false
end
function level:update(store)
if is_story_mode(store) then
apply_phase(store,1)
y_intro_cinematic(store)
signal.emit("wave-notification","view","TOWER_FORGER")
if PHASES[2].after_wave then
y_wait_wave_end(store,PHASES[2].after_wave)
y_phase_2_transition(store)
end
if PHASES[3].after_wave then
y_wait_wave_end(store,PHASES[3].after_wave)
y_phase_3_transition(store)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
y_boss_phase(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
store.custom_game_outcome={postpone_unload=true,after_victory_screen=true}
end
else
if store.level_mode==GAME_MODE_IRON then
setup_state_3(store)
elseif store.level_mode==GAME_MODE_HEROIC then
setup_state_2(store)
else
apply_phase(store,1)
y_wait_level_entities(store)
end
remove_veznan(store)
if store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_HEROIC then
y_phase_2_music_on_battle_start(store)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
