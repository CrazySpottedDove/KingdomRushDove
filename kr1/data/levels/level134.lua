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
local SU=require("script_utils")
local scripts=require("scripts")
local W=require("wave_db")
local v=V.v
local r=V.r
local log=require("lib.klua.log"):new("level134")
local controller_boss_princess_iron_fan_waves_force_capture_hero
local controller_boss_princess_iron_fan_waves_force_go_middle
local controller_boss_princess_iron_fan_waves_force_go_back
local controller_boss_princess_iron_fan_waves_update
local controller_stage_34_fuentes_update
local decal_stage_34_fuente_start_remolino
local decal_stage_34_fuente_end_remolino
local decal_stage_34_fuente_update
local decal_stage_34_fuente_on_event_start
local decal_stage_34_fuente_on_event_end
local decal_stage_34_easter_egg_mono_update
local tunnel_KR5_stage_34_ponds_update
controller_boss_princess_iron_fan_waves_force_capture_hero=function(this,hero)
this.force_capture_hero_entity=hero
end
controller_boss_princess_iron_fan_waves_force_go_middle=function(this,store)
this.force_go_middle_bool=true
end
controller_boss_princess_iron_fan_waves_force_go_back=function(this,store)
this.force_go_middle_bool=false
this.shield_end_ts=0
end
controller_boss_princess_iron_fan_waves_update=function(this,store)
local cfg_illusory_summon,cfg_block_tower,cfg_stun_hero,current_manual_wave,current_manual_wave_index
local function block_tower_ids(holder_ids)
for _,e in E:filter_iter(store.entities,"tower") do
if e.tower.can_be_mod and table.contains(holder_ids,e.tower.holder_id) then
local m=E:create_entity(this.block_tower_mod)
m.modifier.source_id=this.id
m.modifier.target_id=e.id
simulation:queue_insert_entity(m)
end
end
end
local function stun_hero(forced_hero)
local hero_id
if forced_hero then
hero_id=forced_hero.id
end
local heroes=U.find_soldiers_in_range(store.soldiers,this.pos,0,1e+99,this.stun_hero_vis_flags,this.stun_hero_vis_bans,function(e)
if hero_id then
return e.id==hero_id
end
return e.hero
end)
if not heroes or #heroes==0 then
return
end
local decal_pos=V.vclone(table.random(heroes).pos)
U.y_animation_play(this,"stun_hero_in",nil,store.tick_ts)
U.animation_start_default(this,"stun_hero_loop",nil,store.tick_ts,true)
local heroes=U.find_soldiers_in_range(store.soldiers,this.pos,0,1e+99,this.stun_hero_vis_flags,this.stun_hero_vis_bans,function(e)
if hero_id then
return e.id==hero_id
end
return e.hero
end)
if heroes and #heroes>0 then
decal_pos=V.vclone(table.random(heroes).pos)
end
S:queue(this.sound_stun_hero_channel)
local decal=E:create_entity(this.stun_hero_decal)
decal.pos=decal_pos
simulation:queue_insert_entity(decal)
local failed=false
local warning_duration=forced_hero and 1 or this.stun_hero_warning_duration
local wait_until_ts=store.tick_ts+warning_duration
while wait_until_ts>store.tick_ts do
if decal:hero_escaped(store) then
failed=true
break
end
coroutine.yield()
end
if not failed and decal:capture_hero(store) then
S:queue(this.sound_stun_hero_success)
U.y_animation_play(this,"stun_hero_action",nil,store.tick_ts)
else
S:queue(this.sound_stun_hero_fail)
decal:finish(store)
U.y_animation_play(this,"stun_hero_canceled",nil,store.tick_ts)
end
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
end
local function block_random_tower(holder_ids)
local towers=table.filter(store.entities,function(_,e)
return e.tower and not table.contains(this.block_tower.holders_not_to_block,e.tower.holder_id) and e.tower.can_be_mod and table.contains(holder_ids,tonumber(e.tower.holder_id)) and not e.tower.blocked
end)
local tower=table.random(towers)
if tower then
U.y_animation_play(this,"stun_tower_in",nil,store.tick_ts)
block_tower_ids({tower.tower.holder_id})
U.y_animation_wait_default(this)
U.animation_start_default(this,"stun_tower_loop",nil,store.tick_ts,true)
U.y_wait_unconditional(store,this.block_tower_loop_duration)
U.y_animation_wait_default(this)
U.y_animation_play(this,"stun_tower_out",nil,store.tick_ts)
end
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
end
this.last_taunt=nil
this.current_taunt=nil
local function manage_taunts()
if not this.do_taunt then
return false
end
local taunt=this.do_taunt
this.do_taunt=nil
this.last_taunt=this.current_taunt
this.current_taunt=taunt
U.y_animation_wait(this,1,this.render.sprites[1].runs+1)
signal.emit("show-balloon_tutorial",taunt,false)
local speak_anim="1"
U.animation_start_default(this,"speak_loop"..speak_anim,nil,store.tick_ts,true)
U.y_wait_unconditional(store,4)
U.animation_start_default(this,"idle",true,store.tick_ts,true)
this.last_taunt=this.current_taunt
this.current_taunt=nil
return true
end
local in_middle=false
local function go_middle()
if in_middle then
return
end
U.y_animation_play(this,"te_out",nil,store.tick_ts)
S:queue(this.sound_teleport_in)
U.y_animation_play(this,"teleport_in",nil,store.tick_ts)
this.pos=V.vclone(this.pos_standing)
S:queue(this.sound_teleport_out)
U.y_animation_play(this,"teleport_out",nil,store.tick_ts)
U.animation_start_default(this,"idle",true,store.tick_ts,true)
local d_shield=E:create_entity(this.shield_decal)
d_shield.pos=this.pos
simulation:queue_insert_entity(d_shield)
coroutine.yield()
this.shield_id=d_shield.id
this.shield_end_ts=store.tick_ts+this.shield_duration
in_middle=true
if store.wave_group_number==5 and not this.did_taunt_5 then
this.do_taunt="LV34_BOSS_BOSS_WAVES_01"
manage_taunts()
elseif store.wave_group_number==12 and not this.did_taunt_12 then
this.do_taunt="LV34_BOSS_BOSS_WAVES_02"
manage_taunts()
end
end
local function end_skills()
if cfg_block_tower and cfg_block_tower.next_ts then
cfg_block_tower.next_ts=nil
end
if cfg_illusory_summon and cfg_illusory_summon.next_ts then
cfg_illusory_summon.next_ts=nil
end
if current_manual_wave then
W:stop_manual_wave(current_manual_wave)
current_manual_wave=nil
end
end
local function go_back()
if not in_middle then
return
end
local shield=store.entities[this.shield_id]
if shield and store.tick_ts<this.shield_end_ts then
return
end
if shield then
shield.health.hp=0
shield.health_bar.hidden=true
end
if this.force_go_middle_bool then
return
end
if store.wave_group_number>=15 then
end_skills()
return
end
S:queue(this.sound_teleport_in)
U.y_animation_play(this,"teleport_in",nil,store.tick_ts)
this.pos=V.vclone(this.pos_sitting)
S:queue(this.sound_teleport_out)
U.y_animation_play(this,"teleport_out",nil,store.tick_ts)
U.y_animation_play(this,"te_in",nil,store.tick_ts)
U.animation_start_default(this,"te_idle",true,store.tick_ts,true)
in_middle=false
end_skills()
end
this.pos=V.vclone(this.pos_sitting)
U.animation_start_default(this,"te_idle",true,store.tick_ts,true)
local loaded_wave_index,wave_start_ts
while true do
if loaded_wave_index~=store.wave_group_number then
loaded_wave_index=store.wave_group_number
wave_start_ts=store.tick_ts
cfg_illusory_summon=this.illusory_summon[store.wave_group_number]
cfg_block_tower=this.block_tower[store.wave_group_number]
cfg_stun_hero=this.stun_hero[store.wave_group_number]
end
local wave_elapsed_time=store.tick_ts-wave_start_ts
if cfg_block_tower and #cfg_block_tower.first_cd>0 and wave_elapsed_time>cfg_block_tower.first_cd[1] then
cfg_block_tower.next_ts=store.tick_ts
table.remove(cfg_block_tower.first_cd,1)
go_middle()
end
if cfg_illusory_summon and #cfg_illusory_summon.first_cd>0 and wave_elapsed_time>cfg_illusory_summon.first_cd[1] then
cfg_illusory_summon.next_ts=store.tick_ts
current_manual_wave_index=1
table.remove(cfg_illusory_summon.first_cd,1)
go_middle()
end
if cfg_stun_hero and #cfg_stun_hero.first_cd>0 and wave_elapsed_time>cfg_stun_hero.first_cd[1] then
cfg_stun_hero.next_ts=store.tick_ts
table.remove(cfg_stun_hero.first_cd,1)
go_middle()
end
if this.force_go_middle_bool and not in_middle then
go_middle()
end
if in_middle then
if cfg_block_tower and cfg_block_tower.next_ts and store.tick_ts>cfg_block_tower.next_ts then
block_random_tower(cfg_block_tower.towers)
cfg_block_tower.next_ts=store.tick_ts+cfg_block_tower.cd
end
if cfg_stun_hero and cfg_stun_hero.next_ts and store.tick_ts>cfg_stun_hero.next_ts then
stun_hero()
cfg_stun_hero.next_ts=store.tick_ts+cfg_stun_hero.cd
end
if this.force_capture_hero_entity then
stun_hero(this.force_capture_hero_entity)
this.force_capture_hero_entity=nil
end
if cfg_illusory_summon and cfg_illusory_summon.next_ts and store.tick_ts>cfg_illusory_summon.next_ts then
if current_manual_wave then
W:stop_manual_wave(current_manual_wave)
end
U.y_animation_play(this,"summon_terracota",nil,store.tick_ts)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
current_manual_wave=cfg_illusory_summon.wave[current_manual_wave_index]
W:start_manual_wave(current_manual_wave)
cfg_illusory_summon.next_ts=store.tick_ts+cfg_illusory_summon.cd
current_manual_wave_index=current_manual_wave_index+1
if current_manual_wave_index>#cfg_illusory_summon.wave then
current_manual_wave_index=1
end
end
end
go_back()
if this.do_boss_unit_spawn then
U.y_animation_wait(this,1,this.render.sprites[1].runs+1)
local u=E:create_entity(this.boss_unit_spawn)
simulation:queue_insert_entity(u)
simulation:queue_remove_entity(this)
return
end
manage_taunts()
coroutine.yield()
end
end
controller_stage_34_fuentes_update=function(this,store)
local fountains={}
for _,e in pairs(store.entities) do
if not string.find(e.template_name,"decal_stage_34_fuente") then
elseif not e.connections then
else
table.insert(fountains,e)
end
end
local f_links={}
for _,e in pairs(fountains) do
for _,v in pairs(e.connections) do
if not v[1] then
else
table.insert(f_links,{from_path=v[1],to_path=v[2],check_node=P:get_end_node(v[1])-this.nodes_range})
end
end
end
for _,link in pairs(f_links) do
for _,f in pairs(fountains) do
for _,c in pairs(f.connections) do
if not c[1] and c[2]==link.to_path then
link.to_fuente=f
elseif c[1]==link.from_path then
link.from_fuente=f
end
end
end
end
while true do
for _,e in pairs(store.entities) do
if e.pending_removal or not e.enemy or not e.vis or not e.nav_path or not e.health or e.health.dead then
else
for _,link in pairs(f_links) do
if link.from_path==e.nav_path.pi and e.nav_path.ni>=link.check_node then
if not link.close_ts then
link.from_fuente:start_remolino(store)
link.to_fuente:start_remolino(store)
end
link.close_ts=store.tick_ts+this.open_duration
break
end
end
end
end
for _,link in pairs(f_links) do
if not link.close_ts then
elseif store.tick_ts>link.close_ts then
link.close_ts=nil
link.from_fuente:end_remolino(store)
link.to_fuente:end_remolino(store)
end
end
coroutine.yield()
end
end
decal_stage_34_fuente_start_remolino=function(this,store,terracota)
if this.remolino_count==0 then
this.go_start=true
end
if terracota then
this.is_terracota=true
end
this.remolino_count=this.remolino_count+1
end
decal_stage_34_fuente_end_remolino=function(this,store)
this.remolino_count=this.remolino_count-1
if this.remolino_count>0 then
return
end
this.is_terracota=false
this.go_end=true
end
decal_stage_34_fuente_update=function(this,store)
U.animation_start(this,"idle",nil,store.tick_ts-10*math.random(),true,this.render.sid_door,true)
while true do
if this.go_start then
this.go_start=nil
if this.is_terracota then
S:queue(this.sound_mud_pool_transformation)
U.y_animation_play(this,"remolino_barro_in",nil,store.tick_ts)
U.animation_start(this,"remolino_barro_loop",nil,store.tick_ts,true,this.render.sid_door,true)
else
U.y_animation_play(this,"remolino_in",nil,store.tick_ts)
U.animation_start(this,"remolino_loop",nil,store.tick_ts,true,this.render.sid_door,true)
end
end
if this.go_end then
this.go_end=nil
if this.is_terracota then
U.y_animation_play(this,"remolino_barro_out",nil,store.tick_ts)
else
U.y_animation_play(this,"remolino_out",nil,store.tick_ts)
end
U.animation_start(this,"idle",nil,store.tick_ts,true,this.render.sid_door,true)
end
coroutine.yield()
end
end
decal_stage_34_fuente_on_event_start=function(this,store,action,fuente,is_terracota)
if tonumber(fuente)~=this.event_listen_number then
return
end
if is_terracota=="terracota" then
this.is_terracota=true
end
this:start_remolino(store)
end
decal_stage_34_fuente_on_event_end=function(this,store,action,fuente)
if tonumber(fuente)~=this.event_listen_number then
return
end
this.is_terracota=false
this:end_remolino(store)
end
decal_stage_34_easter_egg_mono_update=function(this,store)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
local clicks=0
while true do
if this.ui.clicked then
clicks=clicks+1
this.ui.clicked=nil
this.ui.can_click=false
U.y_animation_play(this,"click_"..clicks,nil,store.tick_ts)
if clicks==1 then
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
this.ui.can_click=true
elseif clicks==2 then
U.animation_start_default(this,"idle_click2",nil,store.tick_ts,true)
this.ui.can_click=true
elseif clicks==3 then
U.sprites_hide(this,1,1,false)
end
end
coroutine.yield()
end
end
tunnel_KR5_stage_34_ponds_update=function(this,store)
local tu=this.tunnel
if not tu.pick_ni then
tu.pick_ni=P:get_end_node(tu.pick_pi)-1
end
if not tu.place_ni then
tu.place_ni=1
end
local pf=P:node_pos(tu.pick_pi,1,tu.pick_ni)
local pt=P:node_pos(tu.place_pi,1,tu.place_ni)
local length=V.dist(pf.x,pf.y,pt.x,pt.y)
local picked_enemies=tu.picked_enemies
tu.length=length
this.total_picked_enemies=0
local nearest_place_fountain
for _,e in pairs(store.entities) do
if not string.find(e.template_name,"decal_stage_34_fuente") then
elseif not nearest_place_fountain or V.dist(e.pos.x,e.pos.y,pt.x,pt.y)<V.dist(nearest_place_fountain.pos.x,nearest_place_fountain.pos.y,pt.x,pt.y) then
nearest_place_fountain=e
end
end
while true do
local enemies=table.filter(store.entities,function(_,e)
return e and e.enemy and e.health and not e.health.dead and e.main_script and e.main_script.co~=nil and e.nav_path and e.nav_path.pi==tu.pick_pi and e.nav_path.ni>=tu.pick_ni and (tu.pick_pi~=tu.place_pi or e.nav_path.ni<tu.place_ni)
end)
for _,enemy in ipairs(enemies) do
if tu.pick_fx then
local fx=E:create_entity(tu.pick_fx)
fx.pos=V.v(enemy.pos.x,enemy.pos.y)
if tu.fx_use_unit_offset then
fx.pos.x,fx.pos.y=fx.pos.x+enemy.unit.mod_offset.x,fx.pos.y+enemy.unit.mod_offset.y
end
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
end
local release_ts=store.tick_ts+length/(tu.speed_factor*enemy.motion.real_speed)
log.debug("tunnel %s picked %s",this.id,enemy.id)
table.insert(picked_enemies,{release_ts=release_ts,entity=enemy})
SU.remove_modifiers(store,enemy)
SU.remove_auras(store,enemy)
simulation:queue_remove_entity(enemy)
U.unblock_all(store,enemy)
if enemy.ui then
enemy.ui.can_click=false
end
enemy.main_script.co=nil
enemy.main_script.runs=0
if enemy.count_group then
enemy.count_group.in_limbo=true
end
this.total_picked_enemies=this.total_picked_enemies+1
end
for i=#picked_enemies,1,-1 do
local p=picked_enemies[i]
if p.release_ts>store.tick_ts then
else
local enemy=p.entity
enemy.nav_path.pi=tu.place_pi
enemy.nav_path.ni=tu.place_ni
enemy.pos=P:node_pos(enemy.nav_path.pi,enemy.nav_path.spi,enemy.nav_path.ni)
enemy.main_script.runs=1
enemy._placed_from_tunnel=true
if enemy.ui then
enemy.ui.can_click=true
end
simulation:queue_insert_entity(enemy)
table.remove(picked_enemies,i)
if tu.place_fx then
local fx
if nearest_place_fountain.is_terracota then
fx=E:create_entity(tu.place_fx_barro)
else
fx=E:create_entity(tu.place_fx)
end
fx.pos=V.v(enemy.pos.x,enemy.pos.y)
if tu.fx_use_unit_offset then
fx.pos.x,fx.pos.y=fx.pos.x+enemy.unit.mod_offset.x,fx.pos.y+enemy.unit.mod_offset.y
end
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
end
log.debug("tunnel %s placed %s",this.id,enemy.id)
end
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_34_fuente_1","decal_scripted",true)
E:add_comps(tt,"events")
tt.start_remolino=decal_stage_34_fuente_start_remolino
tt.end_remolino=decal_stage_34_fuente_end_remolino
tt.main_script.update=decal_stage_34_fuente_update
tt.events.list[1].name="fuente_remolino_start"
tt.events.list[1].on_event=decal_stage_34_fuente_on_event_start
tt.events.list[2]=E:clone_c("event")
tt.events.list[2].name="fuente_remolino_end"
tt.events.list[2].on_event=decal_stage_34_fuente_on_event_end
tt.event_listen_number=1
tt.remolino_count=0
tt.render.sprites[1].prefix="stage_34_fuente_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.connections={{nil,12}}
tt.sound_mud_pool_transformation="EnemyBossPrincessMudPoolTransformation"
tt=E:register_t_hot("decal_stage_34_fuente_5","decal_stage_34_fuente_1",true)
tt.event_listen_number=5
tt.render.sprites[1].prefix="stage_34_fuente_6Def"
tt.connections={{nil,10},{nil,11}}
tt=E:register_t_hot("stage_34_nubes","decal",true)
tt.render.sprites[1].prefix="stage_4_nubesDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_34_fuente_3","decal_stage_34_fuente_1",true)
tt.event_listen_number=3
tt.render.sprites[1].prefix="stage_34_fuente_4Def"
tt.connections={{6,9},{7,10},{8,12}}
tt=E:register_t_hot("decal_stage_34_fuente_2","decal_stage_34_fuente_1",true)
tt.event_listen_number=2
tt.render.sprites[1].prefix="stage_34_fuente_2Def"
tt.connections={{3,9},{4,10},{5,11}}
tt=E:register_t_hot("controller_boss_princess_iron_fan_waves","decal_scripted",true)
E:add_comps(tt,"editor")
tt.force_capture_hero=controller_boss_princess_iron_fan_waves_force_capture_hero
tt.force_go_middle=controller_boss_princess_iron_fan_waves_force_go_middle
tt.force_go_back=controller_boss_princess_iron_fan_waves_force_go_back
tt.main_script.update=controller_boss_princess_iron_fan_waves_update
tt.render.sid_unit=1
tt.render.sprites[tt.render.sid_unit].prefix="boss_princessDef"
tt.render.sprites[tt.render.sid_unit].exo=true
tt.render.sprites[tt.render.sid_unit].name="idle"
tt.pos_sitting=v(1060,405)
tt.pos_standing=v(605,355)
tt.illusory_summon={[7]={cd=13,first_cd={3},wave={"mud_spawner_w7_1","mud_spawner_w7_2","mud_spawner_w7_3"}},[10]={cd=26,first_cd={23},wave={"mud_spawner_w10_1","mud_spawner_w10_2"}},[12]={cd=90,first_cd={20},wave={"mud_spawner_w12_1"}},[15]={cd=25,first_cd={1},wave={"mud_spawner_w15_1","mud_spawner_w15_2"}}}
tt.block_tower={spawn_every=5,quantity_formations_spawns=1,spawn_formations={{{enemy="enemy_big_terracota",subpath=1},{delay=2,enemy="enemy_terracota",subpath=3},{enemy="enemy_terracota",subpath=2},{delay=2,enemy="enemy_terracota",subpath=3},{enemy="enemy_terracota",subpath=2}}},holders_not_to_block={"3","4","5"},[12]={cd=18,first_cd={10},towers={1,2,6,7,8}},[14]={cd=18,first_cd={8},towers={1,2,6,7,8}},[15]={cd=11,first_cd={6},towers={1,2,6,7,8}}}
tt.block_tower_loop_duration=3
tt.block_tower_mod="boss_princess_iron_fan_tower_debuff"
tt.boss_unit_spawn="boss_princess_iron_fan"
tt.stun_hero={WARNING_DURATION=4,DURATION=13,[5]={cd=15,first_cd={5}},[9]={cd=12.5,first_cd={8}},[14]={cd=8,first_cd={13}},[15]={cd=7.5,first_cd={10}}}
tt.stun_hero_decal="decal_boss_princess_iron_fan_stun_heroes_waves"
tt.stun_hero_warning_duration=4
tt.stun_hero_vis_flags=bor(F_MOD,F_STUN,F_AREA)
tt.stun_hero_vis_bans=bor(0)
tt.shield_duration=40
tt.shield_decal="decal_boss_princess_iron_fan_waves_shield"
tt.sound_teleport_in="EnemyBossPrincessTeleportIn"
tt.sound_teleport_out="EnemyBossPrincessTeleportOut"
tt.sound_stun_hero_channel="EnemyBossPrincessHeroStunChannel"
tt.sound_stun_hero_fail="EnemyBossPrincessHeroStunFail"
tt.sound_stun_hero_success="EnemyBossPrincessHeroStunSuccess"
tt=E:register_t_hot("decal_stage_34_mask_cascadas_1","decal",true)
tt.render.sprites[1].name="stage_34_cascadas_1_run"
tt=E:register_t_hot("decal_stage_34_mask_cascadas_3","decal_stage_34_mask_cascadas_1",true)
tt.render.sprites[1].name="stage_34_cascadas_3_run"
tt=E:register_t_hot("stage_34_nubes_camino","decal",true)
tt.render.sprites[1].prefix="stage_4_nubescaminoDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_34_easter_egg_mono","decal_scripted",true)
E:add_comps(tt,"ui")
tt.main_script.update=decal_stage_34_easter_egg_mono_update
tt.render.sprites[1].prefix="wkstatue_sixear"
tt.render.sprites[1].name="idle"
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="wkstatue_ofrendas"
tt.render.sprites[2].animated=false
tt.render.sprites[2].z=Z_EFFECTS
tt.render.sprites[2].offset=v(12,-12)
tt.ui.click_rect=r(-30,-20,60,60)
tt=E:register_t_hot("decal_stage_34_mask_cascadas_6","decal_stage_34_mask_cascadas_1",true)
tt.render.sprites[1].name="stage_34_cascadas_6_run"
tt=E:register_t_hot("decal_stage_34_mask_cascadas_2","decal_stage_34_mask_cascadas_1",true)
tt.render.sprites[1].name="stage_34_cascadas_2_run"
tt=E:register_t_hot("decal_stage_34_fuente_6","decal_stage_34_fuente_1",true)
tt.event_listen_number=6
tt.render.sprites[1].prefix="stage_34_fuente_3Def"
tt.connections=nil
tt=E:register_t_hot("decal_stage_34_mask_2","decal",true)
tt.render.sprites[1].name="mascara2_puertas"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=-100
tt=E:register_t_hot("ps_stage_34_petalos_2","ps_stage_34_petalos_1",true)
tt.particle_system.name="stage34_petalos_2"
tt=E:register_t_hot("decal_stage_34_mask_3","decal",true)
tt.render.sprites[1].name="mascara3_gazebo"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("controller_stage_34_fuentes",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_34_fuentes_update
tt.nodes_range=15
tt.open_duration=3
tt=E:register_t_hot("decal_stage_34_fuente_4","decal_stage_34_fuente_1",true)
tt.event_listen_number=4
tt.render.sprites[1].prefix="stage_34_fuente_5Def"
tt.connections={{nil,9}}
tt=E:register_t_hot("tunnel_KR5_stage_34_ponds","tunnel_KR5",true)
tt.main_script.update=tunnel_KR5_stage_34_ponds_update
tt.untargetable_distance=5
tt.tunnel.speed_factor=8
tt.tunnel.fx_use_unit_offset=false
tt.tunnel.pick_fx="fx_stage_34_fuentes_splash"
tt.tunnel.place_fx="fx_stage_34_fuentes_splash"
tt.tunnel.place_fx_barro="fx_stage_34_fuentes_splash_barro"
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_boss_princess_iron_fan_waves" then
controller_boss_prefight=e
end
end
local function y_do_boss_taunt(key)
while controller_boss_prefight.current_taunt do
coroutine.yield()
end
controller_boss_prefight.do_taunt=key
while controller_boss_prefight.last_taunt~=key do
coroutine.yield()
end
end
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
if not store.restarted and not main.params.skip_cutscenes and not U.flag_has(store.main_hero.vis.bans,controller_boss_prefight.stun_hero_vis_flags) then
store.main_hero.nav_grid.waypoints={}
local hero_path=10
local hero_subpath=1
local hero_move_start_node=P:nearest_nodes(23,463,{hero_path},{hero_subpath},false)[1]
local hero_move_end_node=P:nearest_nodes(295,400,{hero_path},{hero_subpath},false)[1]
for ni=hero_move_start_node[3],hero_move_end_node[3],-3 do
local pos=P:node_pos(hero_path,hero_subpath,ni)
table.insert(store.main_hero.nav_grid.waypoints,pos)
end
store.main_hero.nav_rally.new=true
store.main_hero.nav_rally.center=V.vclone(store.main_hero.nav_grid.waypoints[#store.main_hero.nav_grid.waypoints])
store.main_hero.nav_rally.pos=V.vclone(store.main_hero.nav_rally.center)
local old_vo=table.deepclone(store.main_hero.sound_events.change_rally_point)
store.main_hero.sound_events.change_rally_point=nil
signal.emit("pan-zoom-camera",4,{x=512,y=384},OVtargets(nil,1.2))
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
controller_boss_prefight:force_go_middle(store)
U.y_wait_unconditional(store,4)
y_do_boss_taunt("LV34_BOSS_INTRO_01")
while U.flag_has(store.main_hero.vis.bans,controller_boss_prefight.stun_hero_vis_flags) do
coroutine.yield()
end
controller_boss_prefight:force_capture_hero(store.main_hero)
U.y_wait_unconditional(store,5)
controller_boss_prefight:force_go_back(store)
U.y_wait_unconditional(store,6)
store.main_hero.sound_events.change_rally_point=old_vo
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.do_boss_unit_spawn=true
while not self.bossfight_ended do
coroutine.yield()
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
