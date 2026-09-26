local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
local V=require("lib.klua.vector")
local signal=require("lib.hump.signal")
local log=require("lib.klua.log"):new("level205")
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
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,v)
return (contains and string.find(v.template_name,template_name) or v.template_name==template_name) and (not fn or fn(k,v))
end)
end
local function lamp_update(this,store,script)
this.tree_stun=false
while true do
if this.ui.clicked then
S:queue(this.sound_in)
this.ui.clicked=nil
this.ui.can_click=false
S:queue(this.sound_break)
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
U.animation_start(this,"idlebreak",nil,store.tick_ts,true)
end
if this.tree_stun then
this.tree_stun=false
if this.ui.can_click then
U.animation_start(this,"treestun",nil,store.tick_ts,false)
else
U.animation_start(this,"treestunbreak",nil,store.tick_ts,false)
end
end
if this.render.sprites[1].name=="treestun" and U.animation_finished(this) then
U.animation_start(this,"idle",nil,store.tick_ts,true)
end
if this.render.sprites[1].name=="treestunbreak" and U.animation_finished(this) then
U.animation_start(this,"idlebreak",nil,store.tick_ts,true)
end
coroutine.yield()
end
end
local function upper_path_update(this,store,script)
local idle_ts=store.tick_ts
local idle_cd=math.random(3,7)
while not this.goblin_out do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
S:queue(this.sound_rustle)
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
U.animation_start(this,"idlestart",nil,store.tick_ts,true)
idle_ts=store.tick_ts
idle_cd=math.random(3,7)
this.ui.can_click=true
end
if this.ui.can_click and idle_cd<store.tick_ts-idle_ts then
idle_ts=store.tick_ts
idle_cd=math.random(3,7)
U.animation_start(this,"anim",nil,store.tick_ts,false)
end
if this.render.sprites[1].name=="action" and U.animation_finished(this) then
U.animation_start(this,"idlestart",nil,store.tick_ts,true)
end
coroutine.yield()
end
U.animation_start(this,"goblinout",nil,store.tick_ts,1)
U.y_wait(store,fts(134))
S:queue(this.sound_barrel)
while not U.animation_finished(this) do
coroutine.yield()
end
U.animation_start(this,"idlebarrel",nil,store.tick_ts,true)
while not this.open_path do
coroutine.yield()
end
U.animation_start(this,"openpath",nil,store.tick_ts,1)
U.y_wait(store,fts(44))
S:queue(this.sound_fling)
U.y_wait(store,fts(45))
S:queue(this.sound_explosion)
while not U.animation_finished(this) do
coroutine.yield()
end
queue_remove(store,this)
end
local function citizen_basic_update_editor(this,store)
while true do
this.render.sprites[1].flip_x=this.editor.flip>0
coroutine.yield()
end
return true
end
local function citizen_basic_insert(this,store,script)
this.render.sprites[1].flip_x=this.editor.flip>0
return true
end
local function house_on_fire_update(this,store,script)
while store.wave_group_number<10 do
coroutine.yield()
end
U.y_wait(store,6)
this.render.sprites[1].hidden=false
U.y_animation_play(this,"secondsafterexplosion",nil,store.tick_ts,1)
this.ui.clicked=nil
while true do
if this.ui.clicked then
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
this.ui.clicked=nil
end
coroutine.yield()
end
end
local function citizen_old_window_update(this,store,script)
local lamp=find_all_t(store,"decal_stage_205_lamp_window")[1]
while lamp.render.sprites[1].name~="tap" do
coroutine.yield()
end
U.y_wait(store,0.5)
S:queue(this.sound_break)
this.render.sprites[1].hidden=false
U.y_animation_play(this,"breakclosestlamp",nil,store.tick_ts,1)
this.render.sprites[1].hidden=true
queue_remove(store,this)
end
local function citizen_loop_update(this,store,script)
local loop_ts=store.tick_ts
local loop_cd=fts(math.random(150,300))
while true do
if loop_cd<store.tick_ts-loop_ts then
this.render.sprites[1].hidden=false
U.y_animation_play(this,"loopeveryxseconds",nil,store.tick_ts,1)
this.render.sprites[1].hidden=true
loop_ts=store.tick_ts
loop_cd=fts(math.random(150,300))
end
coroutine.yield()
end
end
local function kodama_update(this,store,script)
U.y_wait(store,U.frandom(0,5))
local c=find_all_t(store,this.controller_t)[1]
local appeared=false
local out_ts=store.tick_ts
local appeared_ts=store.tick_ts
local tweening_ts=store.tick_ts
local disappearing=false
local fadein_wait=U.frandom(this.fadein_min_wait,this.fadein_max_wait)
while c do
if fadein_wait<store.tick_ts-out_ts and not appeared then
appeared_ts=store.tick_ts
appeared=true
this.ui.can_click=true
U.animation_start(this,"idle",nil,store.tick_ts,true)
this.tween.reverse=false
this.tween.run_once=false
this.tween.disabled=false
this.tween.ts=store.tick_ts
end
if store.tick_ts-appeared_ts>this.appeared_wait and appeared then
out_ts=store.tick_ts
appeared=false
disappearing=true
tweening_ts=store.tick_ts
this.tween.reverse=true
this.tween.run_once=true
this.tween.ts=store.tick_ts
end
if disappearing and store.tick_ts-tweening_ts>this.tween.props[1].keys[2][1] then
disappearing=false
this.ui.can_click=false
end
if this.ui.clicked then
this.ui.clicked=nil
this.tween.reverse=false
this.tween.run_once=true
this.tween.ts=store.tick_ts
this.tween.props[1].keys[1][1]=0
this.tween.props[1].keys[1][2]=this.render.sprites[1].alpha
this.tween.props[1].keys[2][1]=1
this.tween.props[1].keys[2][2]=255
U.y_wait(store,1.75)
U.y_animation_play(this,"fadeout",nil,store.tick_ts,1)
U.animation_start(this,"idlefadeout",nil,store.tick_ts,true)
c.kodama_tapped=c.kodama_tapped+1
break
end
coroutine.yield()
end
this.render.sprites[1].alpha=255
while not this.final_animation do
coroutine.yield()
end
U.y_wait(store,this.random_wait)
U.y_animation_play(this,"fadein",nil,store.tick_ts,1)
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
queue_remove(store,this)
end
local function controller_kodama_update(this,store,script)
local kodamas=find_all_t(store,this.kodama_t,true)
while this.kodama_tapped<#kodamas do
coroutine.yield()
end
local max_wait=0
for i,ko in ipairs(kodamas) do
ko.final_animation=true
local rf=math.random(2,12)
ko.random_wait=fts(rf)
max_wait=math.max(max_wait,rf)
end
U.y_wait(store,fts(132+max_wait))
signal.emit("frenzied-spirits-stage05")
queue_remove(store,this)
end
local function controller_leaves_update(this,store,script)
local tree
for k,vv in pairs(store.entities) do
if vv.template_name==this.tree_t then
tree=vv
break
end
end
while true do
if tree and tree.render.sprites[1].name=="idle" then
local leaf=E:create_entity(this.leaf_t)
leaf.pos=v(this.pos.x+math.random(-this.spawn_width/2,this.spawn_width/2),this.pos.y)
leaf.render.sprites[1].flip_x=math.random(1,2)==1
leaf.render.sprites[1].ts=store.tick_ts
queue_insert(store,leaf)
U.y_wait(store,fts(math.random(this.spawn_cd_min*30,this.spawn_cd_max*30)))
end
coroutine.yield()
end
end
local function controller_tree_update(this,store,script)
local tree,zone
local lamps={}
if store.level_mode==GAME_MODE_IRON then
this.cooldown=this.cooldown_iron
end
for k,vv in pairs(store.entities) do
if vv.template_name==this.tree_t then
tree=vv
end
if vv.template_name==this.zone_t then
zone=vv
end
if vv.template_name==this.lamp_t or vv.template_name==this.lamp_t.."_f" then
table.insert(lamps,vv)
end
end
this.pos=V.vclone(tree.pos)
local aura_pos=V.vclone(tree.pos)
aura_pos.y=aura_pos.y-20
local decal_buff=E:create_entity(this.decal_buff_t)
decal_buff.render.sprites[1].ts=store.tick_ts
decal_buff.pos=v(609,340)
decal_buff.tween.ts=store.tick_ts
queue_insert(store,decal_buff)
local souls=E:create_entity(this.souls_t)
souls.render.sprites[1].ts=store.tick_ts
souls.pos=v(609,340)
souls.tween.ts=store.tick_ts
queue_insert(store,souls)
U.animation_start(tree,"idlecharging",nil,store.tick_ts,true,1)
while store.wave_group_number==0 do
coroutine.yield()
end
local decal_ready=E:create_entity(this.decal_ready_t)
decal_ready.render.sprites[1].ts=store.tick_ts
decal_ready.pos=v(609,340)
queue_insert(store,decal_ready)
if this.recover_sound then
S:queue(this.recover_sound,{delay=fts(this.recover_sound_frame)})
end
U.y_animation_play(tree,"backtoidle",nil,store.tick_ts,1)
U.animation_start(tree,"idle",nil,store.tick_ts,true,1,true)
this.ui.clicked=nil
local aura=E:create_entity(this.aura_t)
aura.pos=aura_pos
queue_insert(store,aura)
U.y_animation_play(zone,"appear2",nil,store.tick_ts,1)
U.animation_start(zone,"idle2",nil,store.tick_ts,1)
this.path_unlocked=false
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
decal_buff.tween.reverse=true
decal_buff.tween.remove=true
souls.tween.reverse=true
souls.tween.remove=true
queue_remove(store,aura)
aura=nil
if this.path_unlocked then
U.animation_start(zone,"disappear",nil,store.tick_ts,false)
else
U.animation_start(zone,"disappear2",nil,store.tick_ts,false)
end
local decal_stun=E:create_entity(this.decal_stun_t)
decal_stun.render.sprites[1].ts=store.tick_ts
decal_stun.pos=V.vclone(this.pos)
queue_insert(store,decal_stun)
S:queue(this.sound_activation)
U.animation_start(tree,"stun",nil,store.tick_ts,false)
U.y_wait(store,this.stun_delay)
for k,vv in pairs(lamps) do
vv.tree_stun=true
end
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=0.4
shake.aura.freq_factor=2
queue_insert(store,shake)
local enemies=U.find_enemies_in_range(store,aura_pos,0,this.radius,this.vis_flags,this.vis_bans)
if enemies then
for k,vv in pairs(enemies) do
local mod=E:create_entity(this.mod_stun)
mod.modifier.target_id=vv.id
mod.modifier.source_id=this.id
queue_insert(store,mod)
local d=E.create_damage()
d.value=math.random(this.damage_min,this.damage_max)
d.source_id=this.id
d.target_id=vv.id
d.damage_type=this.damage_type
queue_damage(store,d)
end
end
U.y_animation_wait(tree)
U.animation_start(tree,"idlecharging",nil,store.tick_ts,true)
U.y_wait(store,this.cooldown)
if this.path_unlocked then
U.animation_start(zone,"appear",nil,store.tick_ts,1)
else
U.animation_start(zone,"appear2",nil,store.tick_ts,1)
end
aura=E:create_entity(this.aura_t)
aura.pos=aura_pos
queue_insert(store,aura)
decal_buff=E:create_entity(this.decal_buff_t)
decal_buff.render.sprites[1].ts=store.tick_ts
decal_buff.pos=v(609,340)
decal_buff.tween.ts=store.tick_ts
queue_insert(store,decal_buff)
souls=E:create_entity(this.souls_t)
souls.render.sprites[1].ts=store.tick_ts
souls.pos=v(609,340)
souls.tween.ts=store.tick_ts
queue_insert(store,souls)
decal_ready=E:create_entity(this.decal_ready_t)
decal_ready.render.sprites[1].ts=store.tick_ts
decal_ready.pos=v(609,340)
queue_insert(store,decal_ready)
if this.recover_sound then
S:queue(this.recover_sound,{delay=fts(this.recover_sound_frame)})
end
U.y_animation_play(tree,"backtoidle",nil,store.tick_ts,1)
U.animation_start(tree,"idle",nil,store.tick_ts,true,1,true)
this.ui.can_click=true
end
if zone.render.sprites[1].name=="appear2" and U.animation_finished(zone) then
U.animation_start(zone,"idle2",nil,store.tick_ts,true)
end
if zone.render.sprites[1].name=="appear" and U.animation_finished(zone) then
U.animation_start(zone,"idle",nil,store.tick_ts,true)
end
if zone.render.sprites[1].name=="thirdpathspawn" and U.animation_finished(zone) then
U.animation_start(zone,"idle",nil,store.tick_ts,true)
end
if this.path_unlocked and zone.render.sprites[1].name=="idle2" then
U.animation_start(zone,"thirdpathspawn",nil,store.tick_ts,false)
end
coroutine.yield()
end
end
local function controller_fire_update(this,store)
local upper_path,light,light_spores,tree_cont
for k,vv in pairs(store.entities) do
if vv.template_name=="decal_stage_205_upper_path" then
upper_path=vv
end
if vv.template_name=="decal_stage_205_light" then
light=vv
end
if vv.template_name=="decal_stage_205_light_spores" then
light_spores=vv
end
if vv.template_name=="controller_stage_205_tree" then
tree_cont=vv
end
end
while not this.trigger_fire do
coroutine.yield()
end
upper_path.open_path=true
U.y_wait(store,fts(139))
light.tween.disabled=false
light.tween.ts=store.tick_ts
light_spores.tween.disabled=false
light_spores.tween.ts=store.tick_ts
local decal_fire=E:create_entity("decal_stage_205_fire")
decal_fire.pos=v(-189,770)
decal_fire.render.sprites[1].ts=store.tick_ts
decal_fire.tween.ts=store.tick_ts
queue_insert(store,decal_fire)
local decal_fire_light=E:create_entity("decal_stage_205_fire_light")
decal_fire_light.pos=v(-189,770)
decal_fire_light.render.sprites[1].ts=store.tick_ts
decal_fire_light.tween.ts=store.tick_ts
queue_insert(store,decal_fire_light)
local ps=E:create_entity("ps_stage_205_fire")
ps.pos=v(580,780)
ps.particle_system.emit=true
queue_insert(store,ps)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.4
shake.aura.duration=2
shake.aura.freq_factor=4
queue_insert(store,shake)
P:activate_path(5)
tree_cont.path_unlocked=true
for k,vv in pairs(store.level.ignore_walk_backwards_paths) do
if vv==5 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
signal.emit("fire_end")
end
local function controller_fire_on_event(this,store)
this.trigger_fire=true
end
local function mod_tree_stun_insert(this,store,script)
local m=this.modifier
local target=store.entities[m.target_id]
if not target or target.health.dead then
return false
end
if target.vis and not U.flags_pass(target.vis,this.modifier) then
return false
end
if target and target.unit and this.render then
for i=1,#this.render.sprites do
local s=this.render.sprites[i]
if s.size_names then
s.prefix=s.prefix..s.size_names[target.unit.size]
end
end
end
m.ts=store.tick_ts
SU.stun_inc(target)
signal.emit("mod-applied",this,target)
return true
end
local function mod_tree_stun_update(this,store,script)
local m=this.modifier
local target=store.entities[this.modifier.target_id]
if not target then
queue_remove(store,this)
return
end
this.pos=target.pos
U.y_animation_play(this,this.animation_start,nil,store.tick_ts,1)
U.animation_start(this,this.animation_idle,nil,store.tick_ts,false)
while store.tick_ts-m.ts<m.duration-this.out_before and target and not target.health.dead do
if this.render and m.use_mod_offset and target.unit.mod_offset and not m.custom_offsets then
for i=1,#this.render.sprites do
local s=this.render.sprites[i]
s.offset.x,s.offset.y=target.unit.mod_offset.x,target.unit.mod_offset.y
end
end
coroutine.yield()
end
U.y_animation_play(this,this.animation_end,nil,store.tick_ts,1)
queue_remove(store,this)
end
local function aura_tree_update(this,store,script)
local first_hit_ts
local last_hit_ts=0
last_hit_ts=store.tick_ts-this.aura.cycle_time
while true do
if this.aura.duration>=0 and store.tick_ts-this.aura.ts>this.actual_duration then
break
end
if not (store.tick_ts-last_hit_ts>=this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts-first_hit_ts>this.aura.apply_duration then
else
first_hit_ts=first_hit_ts or store.tick_ts
last_hit_ts=store.tick_ts
local targets=U.find_soldiers_in_range(store.entities,this.pos,0,this.aura.radius,0,0,function(vv,o)
return not this.aura.allowed_templates or table.contains(this.aura.allowed_templates,vv.template_name)
end)
if targets then
for i,target in ipairs(targets) do
local new_mod=E:create_entity(this.aura.mod)
new_mod.modifier.level=this.aura.level
new_mod.modifier.target_id=target.id
new_mod.modifier.source_id=this.id
queue_insert(store,new_mod)
end
end
end
coroutine.yield()
end
queue_remove(store,this)
end
local function mod_tree_buff_insert(this,store,script)
local m=this.modifier
local target=store.entities[m.target_id]
if not target or target.health.dead then
return false
end
if band(this.modifier.vis_flags or 0,target.vis.bans)~=0 or band(this.modifier.vis_bans or 0,target.vis.flags)~=0 then
return false
end
this.tween.ts=store.tick_ts
if target.template_name=="hero_stage_205_alleria" then
if target.motion then
U.speed_mul_self(target,this.alleria_speed_buff)
end
if target.regen and target.regen.health then
target.regen.health=target.regen.health*this.alleria_regen_buff
end
elseif target.template_name~="soldier_alleria_cat" then
return false
end
return true
end
local function mod_tree_buff_update(this,store,script)
local m=this.modifier
this.modifier.ts=store.tick_ts
local target=store.entities[m.target_id]
if not target or not target.pos then
queue_remove(store,this)
return
end
this.pos=target.pos
while true do
target=store.entities[m.target_id]
if not target or target.health.dead or m.duration>=0 and store.tick_ts-m.ts>m.duration then
this.tween.ts=store.tick_ts
this.tween.reverse=true
this.tween.remove=true
return
end
if this.render and target.unit then
local s=this.render.sprites[1]
local flip_sign=1
if target.render then
flip_sign=target.render.sprites[1].flip_x and -1 or 1
end
if m.health_bar_offset and target.health_bar then
local hb=target.health_bar.offset
local hbo=m.health_bar_offset
s.offset.x,s.offset.y=hb.x+hbo.x*flip_sign,hb.y+hbo.y
elseif m.use_mod_offset and target.unit.mod_offset then
s.offset.x,s.offset.y=target.unit.mod_offset.x*flip_sign,target.unit.mod_offset.y
end
end
coroutine.yield()
end
end
local function mod_tree_buff_remove(this,store,script)
local m=this.modifier
local target=store.entities[m.target_id]
if target and target.template_name=="hero_stage_205_alleria" then
if target.motion then
U.speed_div_self(target,this.alleria_speed_buff)
end
if target.regen and target.regen.health then
target.regen.health=target.regen.health/this.alleria_regen_buff
end
end
return true
end
local mask_z={Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS_COVERS,Z_OBJECTS,Z_OBJECTS_COVERS,Z_OBJECTS,Z_OBJECTS_COVERS+1}
for i=1,10 do
local tt=E:register_t_hot("decal_stage_205_mask_"..i,"decal",true)
tt.render.sprites[1].name="stage5_MASK_"..i
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=mask_z[i]
end
local tt=E:register_t_hot("decal_stage_205_lamp","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="treelampDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=lamp_update
tt.sound_break="Stage05LampBreak"
tt.ui.can_click=true
tt.ui.click_rect=r(-20,25,30,40)
tt=E:register_t_hot("decal_stage_205_lamp_f","decal_stage_205_lamp",true)
tt.render.sprites[1].flip_x=true
tt.ui.click_rect=r(-10,27,30,40)
tt=E:register_t_hot("decal_stage_205_lamp_window","decal_stage_205_lamp_f",true)
tt=E:register_t_hot("decal_stage_205_wisps","decal",true)
tt.render.sprites[1].prefix="treewispsDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_205_light","decal_tween",true)
tt.render.sprites[1].name="stage5_overlay01"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.tween.remove=true
tt.tween.disabled=true
tt.tween.props[1].keys={{0,255},{0.5,0}}
tt=E:register_t_hot("decal_stage_205_light_spores","decal_tween",true)
tt.render.sprites[1].prefix="treelightsDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.tween.remove=true
tt.tween.disabled=true
tt.tween.props[1].keys={{0,255},{0.5,0}}
tt=E:register_t_hot("decal_stage_205_tree","decal",true)
tt.render.sprites[1].prefix="treeDef"
tt.render.sprites[1].name="idlecharging"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-70
tt=E:register_t_hot("decal_stage_205_tree_stun","decal_timed",true)
tt.render.sprites[1].prefix="treedecalDef"
tt.render.sprites[1].name="stun"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.timed.runs=1
tt=E:register_t_hot("decal_stage_205_tree_buff","decal_tween",true)
tt.render.sprites[1].prefix="treeauraDef"
tt.render.sprites[1].name="Idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{0.5,255}}
tt=E:register_t_hot("decal_stage_205_tree_ready","decal_timed",true)
tt.render.sprites[1].prefix="treeauraDef"
tt.render.sprites[1].name="backtoidle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.timed.runs=1
tt=E:register_t_hot("decal_stage_205_tree_souls","decal_tween",true)
tt.render.sprites[1].prefix="treesoulsDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-100
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{0.5,255}}
tt=E:register_t_hot("decal_stage_205_tree_zone","decal",true)
tt.render.sprites[1].prefix="treezoneDef"
tt.render.sprites[1].name="idlenothing"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_205_leaf","decal_timed",true)
tt.render.sprites[1].prefix="treeleaffallDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.timed.runs=1
tt=E:register_t_hot("decal_stage_205_upper_path","decal_scripted",true)
AC(tt,"ui","editor")
tt.render.sprites[1].prefix="stage205_pathDef"
tt.render.sprites[1].name="idlestart"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.main_script.update=upper_path_update
tt.sound_rustle="Stage05BushGoblinTap"
tt.sound_barrel="Stage05ForestBurnPrep"
tt.sound_fling="Stage05ForestBurnExplosionPart1ThrowTorch"
tt.sound_explosion="Stage05ForestBurnExplosionPart2"
tt.ui.click_rect=r(760,-180,70,35)
tt=E:register_t_hot("decal_stage_205_fire","decal_tween",true)
tt.render.sprites[1].prefix="stage205_pathburnDef"
tt.render.sprites[1].name="idleburn"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{2,255}}
tt=E:register_t_hot("decal_stage_205_fire_light","decal_tween",true)
tt.render.sprites[1].prefix="stage205_pathburnlightDef"
tt.render.sprites[1].name="idleburn"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.tween.remove=false
tt.tween.props[1].keys={{0,0},{2,255}}
tt=E:register_t_hot("decal_stage_205_citizen_basic","decal_scripted",true)
AC(tt,"ui","editor","editor_script")
tt.render.sprites[1].prefix="stage205_elfDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.insert=citizen_basic_insert
tt.editor_script.update=citizen_basic_update_editor
tt.editor.flip=0
tt.editor.props={{"editor.flip",PT_NUMBER}}
tt=E:register_t_hot("decal_stage_205_citizen_basic_2","decal_stage_205_citizen_basic",true)
tt.render.sprites[1].prefix="stage205_elf2Def"
tt=E:register_t_hot("decal_stage_205_citizen_guitar","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage205_elfguitarDef"
tt.render.sprites[1].name="start"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.tap_anim="taploop"
tt.tap_anim_play_times=3
tt.loop_anim="start"
tt.main_script.update=scripts.decal_utils.animation_on_tap_update
tt.tap_sound="Stage05ElvenMusicianPlay"
tt.ui.click_rect=r(-20,-10,40,35)
tt=E:register_t_hot("decal_stage_205_citizen_house_on_fire","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage205_elfhouseonfireDef"
tt.render.sprites[1].name="secondsafterexplosion"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].hidden=true
tt.main_script.update=house_on_fire_update
tt.ui.click_rect=r(10,-60,60,35)
tt=E:register_t_hot("decal_stage_205_citizen_old","decal_stage_205_citizen_guitar",true)
tt.render.sprites[1].prefix="stage205_elfoldDef"
tt.render.sprites[1].name="idle"
tt.tap_anim="tap"
tt.tap_anim_play_times=1
tt.tap_sound="Stage05OldManElfShout"
tt.loop_anim="idle"
tt=E:register_t_hot("decal_stage_205_citizen_old_window","decal_scripted",true)
tt.render.sprites[1].prefix="stage205_elfoldwindowDef"
tt.render.sprites[1].name="breakclosestlamp"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].hidden=true
tt.main_script.update=citizen_old_window_update
tt.sound_break="Stage05OldManElfShout"
tt=E:register_t_hot("decal_stage_205_citizen_running","decal_scripted",true)
tt.render.sprites[1].prefix="stage205_elfrunningDef"
tt.render.sprites[1].name="loopeveryxseconds"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.render.sprites[1].hidden=true
tt.main_script.update=citizen_loop_update
tt=E:register_t_hot("decal_stage_205_citizen_window","decal_stage_205_citizen_running",true)
tt.render.sprites[1].prefix="stage205_elfwindowDef"
tt.render.sprites[1].name="loopeveryxseconds"
tt=E:register_t_hot("decal_stage_205_kodama_1","decal_scripted",true)
AC(tt,"ui","tween")
tt.render.sprites[1].prefix="stage205_kodamaDef"
tt.render.sprites[1].name="idlefadeout"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.render.sprites[1].alpha=0
tt.tween.props[1].keys={{0,0},{1.5,100}}
tt.tween.props[1].name="alpha"
tt.tween.remove=false
tt.tween.disabled=true
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=kodama_update
tt.final_animation=false
tt.random_wait=0
tt.fadein_min_wait=7
tt.fadein_max_wait=12
tt.appeared_wait=6
tt.controller_t="controller_stage_205_kodama"
tt.ui.click_rect=r(-10,-5,20,25)
tt.ui.can_click=false
tt=E:register_t_hot("decal_stage_205_kodama_2","decal_stage_205_kodama_1",true)
tt.render.sprites[1].prefix="stage205_kodama2Def"
tt=E:register_t_hot("decal_stage_205_kodama_3","decal_stage_205_kodama_1",true)
tt.render.sprites[1].prefix="stage205_kodama3Def"
tt=E:register_t_hot("controller_stage_205_kodama",nil,true)
AC(tt,"main_script","pos")
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=controller_kodama_update
tt.kodama_tapped=0
tt.kodama_t="decal_stage_205_kodama"
tt=E:register_t_hot("controller_stage_205_leaves",nil,true)
AC(tt,"main_script","pos")
tt.main_script.update=controller_leaves_update
tt.tree_t="decal_stage_205_tree"
tt.leaf_t="decal_stage_205_leaf"
tt.spawn_width=200
tt.spawn_cd_min=2
tt.spawn_cd_max=4
tt=E:register_t_hot("controller_stage_205_fire",nil,true)
AC(tt,"main_script","pos","events")
tt.main_script.update=controller_fire_update
tt.events.list[1].name="fire"
tt.events.list[1].on_event=controller_fire_on_event
tt=E:register_t_hot("controller_stage_205_tree",nil,true)
AC(tt,"main_script","ui","pos")
tt.main_script.update=controller_tree_update
tt.recover_sound="Stage05SilveroakTreeRecoverCast"
tt.recover_sound_frame=17
tt.tree_t="decal_stage_205_tree"
tt.aura_t="aura_stage_205_tree"
tt.decal_stun_t="decal_stage_205_tree_stun"
tt.decal_buff_t="decal_stage_205_tree_buff"
tt.decal_ready_t="decal_stage_205_tree_ready"
tt.zone_t="decal_stage_205_tree_zone"
tt.souls_t="decal_stage_205_tree_souls"
tt.lamp_t="decal_stage_205_lamp"
tt.cooldown=25
tt.cooldown_iron=10
tt.damage_min=20
tt.damage_max=40
tt.damage_type=DAMAGE_TRUE
tt.radius=260
tt.sound_activation="Stage05SilveroakTreeActivationCast"
tt.stun_delay=fts(22)
tt.mod_stun="mod_stage_205_tree_stun"
tt.vis_flags=bor(F_AREA,F_FRIEND)
tt.vis_bans=bor(F_FLYING)
tt.ui.click_rect=r(-100,-100,210,190)
tt=E:register_t_hot("aura_stage_205_tree","aura",true)
tt.aura.duration=1e+99
tt.aura.radius=260
tt.aura.vis_flags=bor(F_AREA)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.cycle_time=0.2
tt.aura.mod="mod_stage_205_tree_buff"
tt.aura.allowed_templates={"hero_stage_205_alleria","soldier_alleria_cat"}
tt.alleria_speed_buff=2
tt.alleria_regen_buff=2.5
tt.cat_hp_buff=1.5
tt.cat_dmg_buff=2
tt.main_script.insert=scripts.aura_apply_mod.insert
tt.main_script.update=aura_tree_update
tt=E:register_t_hot("mod_stage_205_tree_stun","mod_stun",true)
tt.modifier.duration=4
tt.modifier.vis_flags=bor(F_MOD,F_STUN)
tt.modifier.vis_bans=bor(F_BOSS)
tt.modifier.use_mod_offset=false
tt.render.sprites[1].prefix="treestun"
tt.render.sprites[1].name="start"
tt.render.sprites[1].loop=false
tt.render.sprites[1].exo=true
tt.render.sprites[1].draw_order=DO_MOD_FX
tt.render.sprites[1].sort_y_offset=-5
tt.render.sprites[1].size_names={"smallDef","bigDef","bigDef"}
tt.main_script.insert=mod_tree_stun_insert
tt.main_script.update=mod_tree_stun_update
tt.out_before=fts(18)
tt.animation_start="start"
tt.animation_idle="idle"
tt.animation_end="end"
tt=E:register_t_hot("mod_stage_205_tree_buff","modifier",true)
AC(tt,"render","tween")
tt.modifier.duration=0.5
tt.modifier.use_mod_offset=false
tt.render.sprites[1].prefix="treeunitdecalDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.insert=mod_tree_buff_insert
tt.main_script.update=mod_tree_buff_update
tt.main_script.remove=mod_tree_buff_remove
tt.alleria_speed_buff=2
tt.alleria_regen_buff=2.5
tt.cat_hp_buff=1.5
tt.cat_dmg_buff=2
tt.tween.props[1].keys={{0,0},{0.5,255}}
tt.tween.remove=false
tt=E:register_t_hot("ps_stage_205_fire","particle_system",true)
tt.particle_system.alphas={255,218.46153846153845,0}
tt.particle_system.anchor=v(2.5,1.5)
tt.particle_system.animated=false
tt.particle_system.loop=false
tt.particle_system.emission_rate=1.2345679012345678
tt.particle_system.emit_area_spread=v(970,0)
tt.particle_system.emit_direction=-1.4738335905729893
tt.particle_system.emit_offset=v(0,0)
tt.particle_system.emit_rotation=2.4434609527920608
tt.particle_system.emit_rotation_spread=1.7453292519943295
tt.particle_system.emit_speed={30,40}
tt.particle_system.emit_spread=0.7853981633974483
tt.particle_system.name="fire_spark"
tt.particle_system.particle_lifetime={20,25}
tt.particle_system.scale_var={0.8999999999999999,1.328571428571427}
tt.particle_system.spin={1,-0.5}
tt.particle_system.z=3500
self.manual_hero_insertion=(store.level_mode==GAME_MODE_CAMPAIGN)
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(5)
LU.insert_hero(store,"hero_stage_205_alleria",V.v(620,270))
local upper_path
for k,vv in pairs(store.entities) do
if vv.template_name=="decal_stage_205_upper_path" then
upper_path=vv
break
end
end
while store.wave_group_number<9 do
coroutine.yield()
end
upper_path.goblin_out=true
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
for k,vv in pairs(store.level.ignore_walk_backwards_paths) do
if vv==5 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
P:activate_path(5)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
