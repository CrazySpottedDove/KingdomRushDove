local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level207")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
local signal=require("lib.hump.signal")
local r=V.r
local v=V.v
local vv=V.vv
local km=require("lib.klua.macros")
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
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function decal_stage_207_bonfire_update(this,store,script)
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
S:queue(this.sound_extinguish)
U.y_animation_play(this,"action",nil,store.tick_ts,1)
U.animation_start(this,"idle_ashes",nil,store.tick_ts,true)
break
end
coroutine.yield()
end
while true do
coroutine.yield()
end
end
local function decal_stage_207_horse_update(this,store,script)
this.can_do_anim=true
while true do
if this.ui.clicked then
this.ui.clicked=nil
if this.can_do_anim then
S:queue(this.tap_sfx)
U.y_animation_play(this,"tap",nil,store.tick_ts,1,1)
end
end
coroutine.yield()
end
end
local function controller_stage_207_bushes_update(this,store)
local bushes={}
local conts={}
for i,v in pairs(store.entities) do
if v.template_name==this.bush_t then
table.insert(bushes,v)
local cont=E:create_entity(this.cont_t)
cont.bush_ref=v
queue_insert(store,cont)
table.insert(conts,cont)
end
end
table.sort(bushes,function(b1,b2)
return b1.pos.x<b2.pos.x
end)
table.sort(conts,function(c1,c2)
return c1.bush_ref.pos.x<c2.bush_ref.pos.x
end)
while true do
if this.spawn_blades then
conts[this.bush_id].do_spawn=true
conts[this.bush_id].path_id=this.path_id
conts[this.bush_id].enemies_count=this.enemies_count
this.spawn_blades=false
end
coroutine.yield()
end
end
local function controller_stage_207_bushes_on_event(this,store,action,bush_id,path_id,count)
this.spawn_blades=true
this.bush_id=tonumber(bush_id)
this.path_id=tonumber(path_id)
this.enemies_count=tonumber(count)
log.info("EVENT BUSH SPAWN. COUNT: "..this.enemies_count)
end
local function controller_stage_207_bush_spawner_update(this,store)
while true do
if this.do_spawn then
local bush=this.bush_ref
local start_ts=store.tick_ts
U.animation_start(bush,"action",nil,store.tick_ts,1)
U.y_wait(store,fts(3))
S:queue(this.sound_rustle)
U.y_wait(store,fts(44))
S:queue(this.sound_rustle)
U.y_wait(store,fts(34))
S:queue(this.sound_rustle)
while not U.animation_finished(bush) do
coroutine.yield()
end
U.animation_start(bush,"idle",nil,store.tick_ts,true)
U.y_wait(store,this.spawn_delay-(store.tick_ts-start_ts))
local nearest_nodes=P:nearest_nodes(bush.pos.x,bush.pos.y,{this.path_id},{1})
local pi,spi,ni=unpack(nearest_nodes[1])
S:queue(this.sound_exit)
for i=1,this.enemies_count do
local fx=E:create_entity(this.spawn_fx)
fx.pos=V.vclone(bush.pos)
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
local enemy=E:create_entity(this.enemy_t)
enemy.nav_path.pi=this.path_id
enemy.nav_path.ni=ni+5
enemy.nav_path.spi=math.random(1,3)
enemy.pos=V.vclone(bush.pos)
enemy.source_id=this.id
queue_insert(store,enemy)
U.y_wait(store,this.delay_between)
end
this.do_spawn=false
end
coroutine.yield()
end
end
local function soldier_stage_207_barn_on_arrived(this,store)
local barn=find_all_t(store,"controller_stage_207_barn")[1]
barn.soldier_arrived=true
end
local function controller_stage_207_barn_update(this,store)
local barn,tower
local horse_conts={}
for k,v in pairs(store.entities) do
if v.template_name==this.barn_t then
barn=v
end
if v.template_name==this.tower_t then
tower=v
end
if v.template_name==this.horse_controller_t then
table.insert(horse_conts,v)
end
end
for i=1,#horse_conts do
horse_conts[i].horse_id=i
horse_conts[i].barn_cont=this
end
this.ui.can_click=false
while true do
if this.soldier_arrived then
this.soldier_arrived=nil
S:queue(this.sound_arrive)
for i=1,#horse_conts do
if not horse_conts[i].horse_ready then
horse_conts[i].soldier_arrived=true
break
end
end
end
if this.ui.clicked then
this.ui.clicked=nil
for i=1,#horse_conts do
if horse_conts[i].horse_ready then
S:queue(this.sound_release)
horse_conts[i].release_horse=true
tower.soldiers_alive=km.clamp(0,3,tower.soldiers_alive-1)
signal.emit("four-horsemen-stage207")
break
end
end
coroutine.yield()
local any_ready=false
for i=1,#horse_conts do
if horse_conts[i].horse_ready then
any_ready=true
break
end
end
if not any_ready then
queue_remove(store,this.bubble)
this.bubble=nil
this.ui.can_click=false
end
end
if this.ui.clicked then
this.ui.clicked=nil
end
coroutine.yield()
end
end
local function controller_stage_207_horse_update(this,store)
local horses=find_all_t(store,this.horse_t_prefix,true)
table.sort(horses,function(h1,h2)
return h1.idx<h2.idx
end)
local barn_c=find_all_t(store,this.barn_controller_t)[1]
while true do
if this.soldier_arrived then
this.soldier_arrived=nil
this.horse_ready=true
horses[this.horse_id].can_do_anim=false
U.y_animation_play(horses[this.horse_id],"action",nil,store.tick_ts,1)
U.animation_start(horses[this.horse_id],"idle_2",nil,store.tick_ts,true)
if not this.barn_cont.bubble then
this.barn_cont.bubble=E:create_entity(this.bubble_t)
this.barn_cont.bubble.pos.x,this.barn_cont.bubble.pos.y=horses[this.horse_id].pos.x+barn_c.bubble_offset.x,horses[this.horse_id].pos.y+barn_c.bubble_offset.y
this.barn_cont.bubble.render.sprites[1].ts=store.tick_ts
queue_insert(store,this.barn_cont.bubble)
this.barn_cont.ui.can_click=true
end
end
if this.release_horse then
this.release_horse=nil
this.horse_ready=false
U.y_animation_play(horses[this.horse_id],"out",nil,store.tick_ts,1)
local nearest_nodes=P:nearest_nodes(this.pos.x,this.pos.y,{this.knight_path},{1})
local pi,spi,ni=unpack(nearest_nodes[1])
local knight=E:create_entity(this.knight_t)
knight.pos=V.vclone(this.pos)
knight.path_id=this.knight_path
knight.node_id=ni-5
queue_insert(store,knight)
U.y_animation_play(horses[this.horse_id],"in",nil,store.tick_ts,1)
U.animation_start(horses[this.horse_id],"idle",nil,store.tick_ts,true)
horses[this.horse_id].can_do_anim=true
end
coroutine.yield()
end
end
local function aura_stage_207_knight_update(this,store,script)
local first_hit_ts
local last_hit_ts=0
local path_ni=this.node_id
local path_spi=1
local distSq=0
local ps1,ps2
last_hit_ts=store.tick_ts-this.aura.cycle_time
if this.aura.apply_delay then
last_hit_ts=last_hit_ts+this.aura.apply_delay
end
local function already_hit_enemy(enemy)
local _,mark_mods=U.has_modifiers(store,enemy,this.aura.mod)
if not mark_mods or #mark_mods==0 then
return false
end
for k,v in pairs(mark_mods) do
if v.modifier.source_id==this.id then
return true
end
end
return false
end
local function hit_enemies()
local targets=U.find_enemies_in_range(store,this.pos,0,this.aura.radius,this.aura.vis_flags,this.aura.vis_bans,function(v,o)
return (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates,v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates,v.template_name)) and (not this.aura.filter_source or this.aura.source_id~=v.id) and not already_hit_enemy(v)
end)
if targets then
for i,target in pairs(targets) do
if target and not target.health.dead and target.enemy then
queue_damage(store,SU.create_attack_damage(this,target.id,this))
local hit_fx=E:create_entity(this.hit_fx)
hit_fx.pos=V.vclone(target.pos)
hit_fx.pos.x,hit_fx.pos.y=hit_fx.pos.x+target.unit.hit_offset.x,hit_fx.pos.y+target.unit.hit_offset.y
hit_fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,hit_fx)
local new_mod=E:create_entity(this.aura.mod)
new_mod.modifier.target_id=target.id
new_mod.modifier.source_id=this.id
queue_insert(store,new_mod)
end
end
if #targets>0 then
S:queue(this.sound_hit)
end
end
end
local target_pos=P:node_pos(this.path_id,path_spi,path_ni)
local function go_back_step()
if V.veq(this.pos,target_pos) then
this.motion.arrived=true
return false
else
U.set_destination(this,target_pos)
if U.walk(this,store.tick_length) then
return false
else
U.animation_start(this,"run",nil,store.tick_ts,true)
return true
end
end
end
local function run_backwards()
local last_pos=this.pos
distSq=V.dist2(target_pos.x,target_pos.y,this.pos.x,this.pos.y)
if distSq<25 then
path_ni=path_ni-3
target_pos=P:node_pos(this.path_id,path_spi,path_ni)
end
go_back_step()
end
local start_ts=store.tick_ts
while true do
if this.interrupt then
last_hit_ts=1e+99
end
if path_ni<=10 and ps1 and ps1.particle_system.emit then
ps1.particle_system.emit=false
ps2.particle_system.emit=false
end
if path_ni<=3 then
break
end
if store.tick_ts-start_ts>0.5 and not ps1 then
if this.particles_name_1 then
ps1=E:create_entity(this.particles_name_1)
ps1.particle_system.emit=true
ps1.particle_system.track_id=this.id
queue_insert(store,ps1)
end
if this.particles_name_2 then
ps2=E:create_entity(this.particles_name_2)
ps2.particle_system.emit=true
ps2.particle_system.track_id=this.id
queue_insert(store,ps2)
end
end
if store.tick_ts-last_hit_ts>=this.aura.cycle_time then
if this.aura.apply_duration and first_hit_ts and store.tick_ts-first_hit_ts>this.aura.apply_duration then
else
first_hit_ts=first_hit_ts or store.tick_ts
last_hit_ts=store.tick_ts
hit_enemies()
end
end
run_backwards()
coroutine.yield()
end
if ps1 and ps1.particle_system.emit then
ps1.particle_system.emit=false
ps2.particle_system.emit=false
U.y_wait(store,ps1.particle_system.particle_lifetime[2])
end
queue_remove(store,this)
end
local mask_z={Z_OBJECTS,Z_OBJECTS_COVERS,Z_OBJECTS,Z_OBJECTS}
for i=1,4 do
local tt=E:register_t_hot("decal_stage_207_mask_"..i,"decal",true)
tt.render.sprites[1].name="stage207_MASK_"..i
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=mask_z[i]
if i==1 then
tt.render.sprites[1].offset=v(0,-266)
elseif i==4 then
tt.render.sprites[1].sort_y_offset=151
end
end
local tt=E:register_t_hot("decal_stage_207_shield_eastereggs","decal_scripted",true)
AC(tt,"main_script")
tt.render.sprites[1].name="stage207_bg_eastereggs"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt=E:register_t_hot("decal_stage_207_bush","decal",true)
tt.render.sprites[1].prefix="stage_207_ambush_bushDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_207_tent","decal",true)
tt.render.sprites[1].name="stage207_tent"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_207_bonfire","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage207_fogata_fire"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=decal_stage_207_bonfire_update
tt.sound_extinguish="Stage07CampfireExtinguish"
tt.ui.click_rect=r(-25,-12,50,45)
tt=E:register_t_hot("decal_stage_207_barn","decal",true)
tt.render.sprites[1]=E:clone_c("sprite")
tt.render.sprites[1].prefix="stage_207_stable_frontDef"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=-245
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_207_horse_1","decal",true)
AC(tt,"ui","main_script")
tt.main_script.update=decal_stage_207_horse_update
tt.render.sprites[1].prefix="stage_207_stable_horse1Def"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=-245
tt.render.sprites[1].z=Z_OBJECTS
tt.idx=1
tt.ui.click_rect=r(432,-239,50,30)
tt.tap_sfx="Stage07HorseTapFeedback"
tt=E:register_t_hot("decal_stage_207_horse_2","decal",true)
AC(tt,"ui","main_script")
tt.main_script.update=decal_stage_207_horse_update
tt.render.sprites[1]=E:clone_c("sprite")
tt.render.sprites[1].prefix="stage_207_stable_horse2Def"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=-244
tt.idx=2
tt.ui.click_rect=r(475,-272,50,30)
tt.tap_sfx="Stage07HorseTapFeedback"
tt=E:register_t_hot("decal_stage_207_horse_3","decal",true)
AC(tt,"ui","main_script")
tt.main_script.update=decal_stage_207_horse_update
tt.render.sprites[1]=E:clone_c("sprite")
tt.render.sprites[1].prefix="stage_207_stable_horse3Def"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=-245
tt.idx=3
tt.ui.click_rect=r(397,-291,50,30)
tt.tap_sfx="Stage07HorseTapFeedback"
tt=E:register_t_hot("decal_stage_207_bubble","decal",true)
tt.render.sprites[1].prefix="stage_207_speech_bubbleDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt=E:register_t_hot("fx_stage_207_bush","fx",true)
tt.render.sprites[1].prefix="stage_207_ambush_out_fxDef"
tt.render.sprites[1].name="out"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("fx_stage_207_knight_enraged_hit","fx",true)
tt.render.sprites[1].prefix="stage207_jinete_hit"
tt.render.sprites[1].name="Idle"
tt=E:register_t_hot("ps_stage_207_knight_1","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.z=Z_BULLET_PARTICLES
tt.particle_system.name="stage207_jinete_particle_1"
tt.particle_system.particle_lifetime={fts(15),fts(15)}
tt.particle_system.emission_rate=5
tt.particle_system.emit_offset=v(18,8)
tt.particle_system.emit_area_spread=v(5,5)
tt=E:register_t_hot("ps_stage_207_knight_2","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.z=Z_BULLET_PARTICLES
tt.particle_system.name="stage207_jinete_particle_2"
tt.particle_system.particle_lifetime={fts(35),fts(35)}
tt.particle_system.emission_rate=3
tt.particle_system.emit_offset=v(18,18)
tt.particle_system.emit_area_spread=v(5,5)
tt=E:register_t_hot("mod_stage_207_knight_mark","modifier",true)
tt.modifier.duration=3
tt.modifier.allows_duplicates=true
tt.main_script.insert=scripts.mod_track_target.insert
tt.main_script.update=scripts.mod_track_target.update
tt=E:register_t_hot("aura_stage_207_knight","aura",true)
AC(tt,"render","motion")
tt.aura.duration=1e+99
tt.aura.radius=60
tt.aura.vis_flags=bor(F_AREA)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.cycle_time=fts(3)
tt.aura.mod="mod_stage_207_knight_mark"
tt.render.sprites[1].prefix="stage207_jinete_run"
tt.render.sprites[1].name="run"
tt.main_script.insert=scripts.aura_apply_mod.insert
tt.main_script.update=aura_stage_207_knight_update
tt.motion.max_speed=130
tt.damage_min=50
tt.damage_max=100
tt.damage_type=DAMAGE_PHYSICAL
tt.hit_fx="fx_stage_207_knight_enraged_hit"
tt.particles_name_1="ps_stage_207_knight_1"
tt.particles_name_2="ps_stage_207_knight_2"
tt.sound_hit="BasicBodyImpact"
tt=E:register_t_hot("controller_stage_207_bush_spawner",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_207_bush_spawner_update
tt.spawn_fx="fx_stage_207_bush"
tt.enemy_t="enemy_shadow_blades"
tt.spawn_delay=5
tt.delay_between=1
tt.sound_rustle="Stage07BushBladesSpawnMov"
tt.sound_exit="Stage07BushBladesSpawn"
tt=E:register_t_hot("controller_stage_207_bushes",nil,true)
AC(tt,"main_script","events")
tt.main_script.update=controller_stage_207_bushes_update
tt.bush_t="decal_stage_207_bush"
tt.cont_t="controller_stage_207_bush_spawner"
tt.events.list[1].name="bush"
tt.events.list[1].on_event=controller_stage_207_bushes_on_event
tt=E:register_t_hot("controller_stage_207_horse",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_207_horse_update
tt.barn_controller_t="controller_stage_207_barn"
tt.horse_t_prefix="decal_stage_207_horse"
tt.bubble_t="decal_stage_207_bubble"
tt.knight_t="aura_stage_207_knight"
tt.knight_path=1
tt=E:register_t_hot("controller_stage_207_barn",nil,true)
AC(tt,"main_script","ui")
tt.main_script.update=controller_stage_207_barn_update
tt.bubble_offset=v(0,-15)
tt.barn_t="decal_stage_207_barn"
tt.tower_t="tower_stage_207_barn"
tt.horse_controller_t="controller_stage_207_horse"
tt.knight_path=1
tt.sound_arrive="Stage07StableKnightArrive"
tt.sound_release="Stage07StableKnightSpawn"
tt.ui.click_rect=r(55+tt.bubble_offset.x,-8+tt.bubble_offset.y,66,48)
tt=E:register_t_hot("soldier_stage_207_barn","soldier_militia",true)
AC(tt,"nav_grid")
tt.info.portrait="kr6_info_portraits_soldiers_0016"
tt.info.random_name_count=8
tt.info.random_name_format="SOLDIER_STAGE_207_BARN_%i_NAME"
tt.main_script.update=scripts.soldier_walk_to_objective.update
tt.on_arrived=soldier_stage_207_barn_on_arrived
tt.render.sprites[1].prefix="stage207_jinete_soldier"
tt.render.sprites[1].anchor=v(0.5,0.5)
tt.render.sprites[1].angles.walk={"walk"}
tt.unit.hit_offset=v(0,12)
tt.unit.marker_offset=v(0,0)
tt.unit.mod_offset=v(0,13)
tt.health.hp_max=100
tt.health.armor=0.25
tt.health_bar.offset=v(0,30)
tt.health.dead_lifetime=12
tt.regen.health=0
tt.nav_grid=nil
tt.motion.max_speed=60
tt.vis.flags=bor(F_BLOCK,F_FRIEND)
tt.melee.range=65
tt.melee.attacks[1].cooldown=1
tt.melee.attacks[1].damage_min=4
tt.melee.attacks[1].damage_max=6
tt.melee.attacks[1].hit_time=fts(10)
tt.soldier.melee_slot_offset=v(4,0)
tt.distance_sqd=25
tt.ui.click_rect=r(-13,-2,26,25)
tt=E:register_t_hot("tower_stage_207_barn","tower",true)
AC(tt,"user_selection")
tt.tower.type="stage_207_barn"
tt.tower.menu_offset=v(0,0)
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.disable_spend_highlight=true
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.info.portrait="kr6_info_portraits_towers_0008"
tt.info.fn=scripts.tower_barrack_mercenaries.get_info
tt.user_selection.can_select_point_fn=scripts.tower_spawn_soldier_on_path.can_select_point
tt.main_script.update=scripts.tower_spawn_soldier_on_path.update
tt.tower_action={}
tt.tower_action.cost=50
tt.tower_action.active=nil
tt.tower_action.sound=nil
tt.tower_action.post_sound="Stage07BuyRider"
tt.max_soldiers=3
tt.ui.click_rect=r(-50,-40,100,100)
tt.ui.hover_sprite_scale=vv(1.4)
tt.ui.hover_sprite_offset=v(0,-8)
tt.path_id=7
tt.soldier_t="soldier_stage_207_barn"
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
