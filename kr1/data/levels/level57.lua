local log=require("lib.klua.log"):new("level04")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local V=require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local v=V.v
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function aura_waterfall_entrance_update(this,store)
local show_queue={}
while true do
for _,e in pairs(store.enemies) do
if e.nav_path and e._waterfall_entrance_done~=true then
for _,item in pairs(this.waterfall_nodes) do
local pi,nin,nout=item.path_id,item.from,item.to
if pi~=e.nav_path.pi then
elseif e.nav_path.ni==nin and e._waterfall_entrance_done==nil then
e._waterfall_entrance_done=false
U.sprites_hide(e)
if e.health_bar then
e.health_bar.hidden=true
end
elseif e.nav_path.ni==nout and e._waterfall_entrance_done==false then
e._waterfall_entrance_done=true
local fx=E:create_entity(this.show_fx)
fx.pos.x,fx.pos.y=e.pos.x,e.pos.y-3
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
table.insert(show_queue,e)
end
end
end
end
coroutine.yield()
for i=#show_queue,1,-1 do
local e=show_queue[i]
U.sprites_show(e)
if e.health_bar then
e.health_bar.hidden=nil
end
table.remove(show_queue,i)
end
end
end
local function decal_s09_crystal_serpent_attack_update(this,store)
local hids=this.holder_ids
local towers_by_idx={}
for _,e in E:filter_iter(store.entities,"tower") do
for i,hid in ipairs(hids) do
if e.tower.holder_id==hid then
towers_by_idx[i]=e
log.debug(" tower %s holder:%s pos_y:%s",i,e.tower.holder_id,e.pos.y)
end
end
end
S:queue("ElvesCrystalSerpentEmerge")
U.animation_start_default(this,"spawn",this.flip_x,store.tick_ts,false)
U.y_animation_wait_default(this)
S:queue("ElvesCrystalSerpentAttack",{delay=fts(5)})
U.animation_start_default(this,"shootSmoke",this.flip_x,store.tick_ts,false)
U.y_wait_unconditional(store,fts(13))
local first_dest=towers_by_idx[1].pos
for i=1,3 do
local target=towers_by_idx[i]
local b=E:create_entity("bullet_crystal_serpent")
b.bullet.target_id=target.id
b.pos=this.flip_x and v(this.pos.x-30,this.pos.y-17) or v(this.pos.x+33,this.pos.y-13)
b.bullet.from=V.vclone(b.pos)
if i==1 then
b.bullet.to=v(first_dest.x,first_dest.y)
else
b.bullet.to=v((first_dest.x+target.pos.x)*0.5,(first_dest.y+target.pos.y)*0.5)
end
simulation:queue_insert_entity(b)
if i==1 then
U.y_wait_unconditional(store,fts(3))
end
end
U.y_animation_wait_default(this)
S:queue("ElvesCrystalSerpentSubmerge",{delay=fts(8)})
U.y_animation_play(this,"dive",this.flip_x,store.tick_ts)
simulation:queue_remove_entity(this)
end
local function decal_s09_crystal_serpent_scream_update(this,store)
S:queue("ElvesCrystalSerpentEmerge")
U.animation_start(this,"spawn",this.flip_x,store.tick_ts,false,1)
this.render.sprites[3].hidden=false
U.animation_start(this,"waterWaves",this.flip_x,store.tick_ts,true,3)
U.y_animation_wait_default(this)
S:queue("ElvesCrystalSerpentScream")
this.render.sprites[2].hidden=false
U.animation_start(this,"superScream",this.flip_x,store.tick_ts,false,1)
U.animation_start(this,"superScreamRays",this.flip_x,store.tick_ts,false,2)
U.y_animation_wait_default(this)
this.render.sprites[2].hidden=true
S:queue("ElvesCrystalSerpentSubmerge",{delay=fts(8)})
U.animation_start(this,"dive",this.flip_x,store.tick_ts,false,1)
U.y_wait_unconditional(store,fts(19))
this.render.sprites[3].hidden=true
U.y_animation_wait_default(this)
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("aura_waterfall_entrance","aura",true)
tt.main_script.update=aura_waterfall_entrance_update
tt.show_fx="fx_waterfall_splash"
tt=E:register_t_hot("decal_s09_land_3","decal_background",true)
AC(tt,"tween")
tt.render.sprites[1].name="Stage09_0002"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.editor.game_mode=1
tt.tween.disabled=true
tt.tween.props[1].keys={{fts(9),255},{fts(18),0}}
tt=E:register_t_hot("decal_s09_land_2","decal_s09_land_3",true)
tt.render.sprites[1].name="Stage09_0003"
tt=E:register_t_hot("decal_s09_land_1","decal_s09_land_3",true)
tt.render.sprites[1].name="Stage09_0004"
tt=E:register_t_hot("decal_s09_crystal_1","decal_timed",true)
AC(tt,"editor")
tt.render.sprites[1].prefix="decal_s09_crystal_1"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.y=0.3941176470588235
tt.render.sprites[1].scale=vec_2(1,1)
tt.timed.runs=INT_32_MAX
tt.editor.game_mode=1
tt.editor.tag=1
tt.editor.props={{"editor.game_mode",PT_NUMBER},{"editor.tag",PT_NUMBER}}
tt.debris_pos=vec_2(-5,1)
tt=E:register_t_hot("decal_s09_crystal_2","decal_s09_crystal_1",true)
tt.render.sprites[1].prefix="decal_s09_crystal_2"
tt.debris_pos=vec_2(9,4)
tt=E:register_t_hot("decal_s09_crystal_3","decal_s09_crystal_1",true)
tt.render.sprites[1].prefix="decal_s09_crystal_3"
tt.debris_pos=vec_2(9,-5)
tt=E:register_t_hot("decal_s09_crystal_4","decal_s09_crystal_1",true)
tt.render.sprites[1].prefix="decal_s09_crystal_4"
tt.debris_pos=vec_2(-6,6)
tt=E:register_t_hot("decal_s09_crystal_serpent_back","decal_tween",true)
AC(tt,"sound_events")
tt.render.sprites[1].name="crystal_serpent_appear"
tt.render.sprites[1].loop=false
tt.tween.props[1].name="offset"
tt.tween.props[1].keys={{0,vec_2(0,0)},{fts(80),vec_2(0,0)},{fts(114),vec_2(0,0)}}
tt.sound_events.insert="ElvesCrystalSerpentPassby"
tt=E:register_t_hot("decal_s09_crystal_serpent_attack","decal_scripted",true)
tt.render.sprites[1].prefix="crystal_serpent"
tt.main_script.update=decal_s09_crystal_serpent_attack_update
tt=E:register_t_hot("decal_s09_crystal_serpent_scream","decal_s09_crystal_serpent_attack",true)
tt.main_script.update=decal_s09_crystal_serpent_scream_update
tt.render.sprites[2]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].hidden=true
tt.render.sprites[3]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].hidden=true
tt=E:register_t_hot("decal_s09_waterfall","decal_scripted",true)
tt.render.sprites[1].name="decal_s09_waterfall_lines1"
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="decal_s09_waterfall_lines2"
tt.render.sprites[3]=CC("sprite")
tt.render.sprites[3].name="decal_s09_waterfall_top"
tt.render.sprites[4]=CC("sprite")
tt.render.sprites[4].name="decal_s09_waterfall_bottom"
tt=E:register_t_hot("decal_crystal_water_waves2","decal_delayed_play",true)
tt.render.sprites[1].prefix="decal_water_wave_2"
tt.render.sprites[1].name="play"
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_DECALS
tt.delayed_play.max_delay=3
tt.delayed_play.idle_animation=nil
tt.delayed_play.play_animation="play"
local scripts=require("scripts")
local km=require("lib.klua.macros")
local function bullet_crystal_serpent_update(this,store)
local b=this.bullet
b.ts=store.tick_ts
local psf=E:create_entity(b.particles_name)
psf.particle_system.track_id=this.id
simulation:queue_insert_entity(psf)
while store.tick_ts-b.ts+store.tick_length<=b.flight_time do
coroutine.yield()
local phase=km.clamp(0,1,(store.tick_ts-b.ts)/b.flight_time)
this.pos.x=b.from.x+(b.to.x-b.from.x)*phase
this.pos.y=b.from.y+(b.to.y-b.from.y)*phase
end
psf.particle_system.emit=false
local target=store.entities[b.target_id]
if target then
local psh=E:create_entity("ps_bullet_crystal_serpent_hit")
psh.pos.x,psh.pos.y=target.pos.x,target.pos.y+20
psh.particle_system.emit=true
simulation:queue_insert_entity(psh)
U.y_wait_unconditional(store,fts(7))
psh.particle_system.emit=false
end
local wait_time
if target and target.tower and target.tower.can_be_mod and not target.tower.blocked then
local m=E:create_entity(b.mod)
m.modifier.target_id=b.target_id
m.pos.x,m.pos.y=target.pos.x,target.pos.y
wait_time=m.modifier.duration
simulation:queue_insert_entity(m)
end
if wait_time then
U.y_wait_unconditional(store,wait_time)
S:queue("ElvesCrystalSerpentBreakingCrystal")
local s=E:create_entity("decal_s09_crystal_debris_mod")
s.pos.x,s.pos.y=target.pos.x,target.pos.y
U.animation_start_default(s,nil,nil,store.tick_ts)
s.tween.ts=store.tick_ts
simulation:queue_insert_entity(s)
end
simulation:queue_remove_entity(this)
end
tt=E:register_t_hot("bullet_crystal_serpent","bullet",true)
tt.render.sprites[1].hidden=true
tt.bullet.mod="mod_crystal_serpent"
tt.bullet.flight_time=fts(17)
tt.bullet.particles_name="ps_bullet_crystal_serpent_fly"
tt.main_script.update=bullet_crystal_serpent_update
end
local WARNING=1
local ATTACK=2
local OPEN_PATH=3
level.blocked_path_sections={[2]={from=140},[5]={from=96}}
level.serpent_action_data={[WARNING]={{V.v(435,523),false},{V.v(435,523),true},{V.v(500,436),true}},[ATTACK]={{V.v(451,571),false,V.v(592,496),true,V.v(398,447),true,{"2","7","1"}},{V.v(578,555),true,V.v(417,501),false,V.v(492,421),true,{"1","2","4"}},{V.v(439,553),false,V.v(583,493),true,V.v(494,414),false,{"6","3","5"}},{V.v(516,423),true,V.v(422,488),false,V.v(617,518),false,{"10","5","9"}}},[OPEN_PATH]={{V.v(435,523),false,V.v(530,451),true,{1},{6}},{V.v(571,556),true,V.v(450,471),false,{2,3},{2,3,5}}}}
level.serpent_sequence={[GAME_MODE_CAMPAIGN]={{{WARNING,15}},{{WARNING,5},{WARNING,20}},{{WARNING,5},{ATTACK,12,2}},{{WARNING,5},{WARNING,12},{ATTACK,30,3}},{{OPEN_PATH,20,1}},{{ATTACK,10,3}},{{WARNING,10},{WARNING,18}},{{WARNING,5},{WARNING,20},{WARNING,35}},{{WARNING,5},{ATTACK,10,2},{ATTACK,25,3}},{{OPEN_PATH,5,2},{WARNING,15},{WARNING,25}},{{ATTACK,9,2},{ATTACK,22,3},{WARNING,35}},{{ATTACK,5,3},{ATTACK,20,2},{WARNING,35}},{{WARNING,5}},{{WARNING,5},{WARNING,15},{WARNING,20},{WARNING,25}},{{WARNING,5},{ATTACK,10,2},{ATTACK,20,3},{ATTACK,30,2}},{{ATTACK,7,2},{ATTACK,15,3},{ATTACK,30,2},{WARNING,40},{ATTACK,45,3}}},[GAME_MODE_HEROIC]={{{WARNING,5},{WARNING,10},{WARNING,15}},{{WARNING,5},{WARNING,10},{WARNING,15}}},[GAME_MODE_IRON]={{{WARNING,5},{WARNING,10},{WARNING,15},{ATTACK,20,2},{ATTACK,30,3},{WARNING,40},{ATTACK,50,1},{ATTACK,60,4},{WARNING,70},{ATTACK,80,2},{ATTACK,90,3},{WARNING,100},{ATTACK,110,1},{ATTACK,120,4},{WARNING,130},{ATTACK,140,1},{ATTACK,150,4},{WARNING,160},{ATTACK,170,1},{ATTACK,180,4}}}}
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local flags=LU.list_entities(store.pending_inserts,"decal_defense_flag",2)
local defend_point=LU.list_entities(store.pending_inserts,"decal_defense_flag",2)[1]
for _,flag in pairs(flags) do
flag.render.sprites[1].hidden=true
end
defend_point.render.sprites[1].hidden=true
for pid,v in pairs(self.blocked_path_sections) do
P:add_invalid_range(pid,v.from,v.to,NF_ALL)
end
else
for _,d in pairs(self.serpent_action_data[OPEN_PATH]) do
local path_ids=d[6]
for _,pid in pairs(path_ids) do
P:activate_path(pid)
end
end
end
end
function level:update(store)
local this_wave=0
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished do
local wave_seq=self.serpent_sequence[store.level_mode][DEBUG_SERPENT_WAVE or store.wave_group_number]
if wave_seq then
local start_ts=store.tick_ts
log.debug("crystal serpent / wave_seq:%s ts:%s",getdump(wave_seq),start_ts)
this_wave=store.wave_group_number
local interrupted=false
for _,seq in pairs(wave_seq) do
local action,delay,data=unpack(seq)
log.debug(" seq. action:%s delay:%s",action,delay)
interrupted=U.y_wait_conditional(store,delay-(store.tick_ts-start_ts),function(store,time)
return this_wave~=store.wave_group_number or store.waves_finished
end)
if not interrupted or action==OPEN_PATH then
self:y_serpent_seq(store,action,data)
end
end
while not store.waves_finished and (DEBUG_SERPENT_WAVE or store.wave_group_number)==this_wave do
coroutine.yield()
end
end
U.y_wait_unconditional(store,0.5)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
function level:y_serpent_seq(store,action,data)
if action==WARNING then
local t=table.random(self.serpent_action_data[WARNING])
local pos,flip_x=unpack(t)
self:add_serpent_back(store,pos,flip_x)
elseif action==ATTACK then
local back1_pos,back1_flip,back2_pos,back2_flip,attack_pos,attack_flip,holder_ids=unpack(self.serpent_action_data[ATTACK][data])
self:add_serpent_back(store,back1_pos,back1_flip)
U.y_wait_unconditional(store,1.4)
self:add_serpent_back(store,back2_pos,back2_flip)
U.y_wait_unconditional(store,3.3)
self:add_serpent_attack(store,attack_pos,attack_flip,holder_ids)
elseif action==OPEN_PATH then
local back_pos,back_flip,scream_pos,scream_flip,zone_ids,path_ids=unpack(self.serpent_action_data[OPEN_PATH][data])
self:add_serpent_back(store,back_pos,back_flip)
U.y_wait_unconditional(store,3.3)
self:add_serpent_scream(store,scream_pos,scream_flip,path_ids)
U.y_wait_unconditional(store,1.7)
S:queue("ElvesCrystalSerpentBreakingCrystal")
for _,z in pairs(zone_ids) do
self:open_zone(store,z)
end
for _,pid in pairs(path_ids) do
P:activate_path(pid)
if self.blocked_path_sections[pid] then
local s=self.blocked_path_sections[pid]
P:remove_invalid_range(pid,s.from,s.to,NF_ALL)
end
end
end
end
function level:add_serpent_back(store,pos,flip_x)
local e=E:create_entity("decal_s09_crystal_serpent_back")
e.pos.x,e.pos.y=pos.x,pos.y
e.render.sprites[1].ts=store.tick_ts
e.render.sprites[1].flip_x=flip_x
e.tween.props[1].keys[2][2].x=flip_x and -65 or 65
e.tween.props[1].keys[3][2].x=e.tween.props[1].keys[2][2].x
LU.queue_insert(store,e)
end
function level:add_serpent_attack(store,pos,flip_x,holder_ids)
local e=E:create_entity("decal_s09_crystal_serpent_attack")
e.flip_x=flip_x
e.holder_ids=holder_ids
e.pos.x,e.pos.y=pos.x,pos.y
LU.queue_insert(store,e)
end
function level:add_serpent_scream(store,pos,flip_x,path_ids)
local e=E:create_entity("decal_s09_crystal_serpent_scream")
e.flip_x=flip_x
e.path_ids=path_ids
e.pos.x,e.pos.y=pos.x,pos.y
LU.queue_insert(store,e)
end
function level:open_zone(store,zone)
local land=LU.list_entities(store.entities,"decal_s09_land_"..zone)[1]
local flags=LU.list_entities(store.entities,"decal_defense_flag",zone)
local defend_point=LU.list_entities(store.entities,"decal_defense_point",zone)[1]
local crystals=table.filter(store.entities,function(k,e)
return string.find(e.template_name,"decal_s09_crystal_",1,true) and e.editor and e.editor.tag==zone
end)
if land then
land.tween.ts=store.tick_ts
land.tween.disabled=nil
end
local delay=0.05
for i,c in ipairs(crystals) do
local d=delay*i
c.render.sprites[1].name="break"
c.render.sprites[1].ts=store.tick_ts
c.render.sprites[1].time_offset=-1*d
c.timed.runs=1
local s=E:create_entity("decal_s09_crystal_debris")
s.pos.x,s.pos.y=c.pos.x+c.debris_pos.x,c.pos.y+c.debris_pos.y
U.animation_start(s,nil,nil,store.tick_ts+d+fts(7))
s.tween.ts=store.tick_ts+d+fts(7)
LU.queue_insert(store,s)
end
for _,flag in pairs(flags) do
flag.render.sprites[1].hidden=nil
flag.render.sprites[1].ts=store.tick_ts+0.7
end
if defend_point then
defend_point.render.sprites[1].hidden=nil
defend_point.render.sprites[1].ts=store.tick_ts+0.7
end
end
return level
