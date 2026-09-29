local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local SU=require("script_utils")
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
local vv=V.vv
local controller_stage_11_portal_insert
local controller_stage_11_portal_update
local controller_stage_11_cultist_leader_modes_update
local decal_stage_11_veznan_can_select_point
local decal_stage_11_veznan_update
local decal_stage_11_sam_and_frodo_update
controller_stage_11_portal_insert=function(this,store)
local portal=E:create_entity(this.entity_portal)
portal.pos=V.vclone(this.portal_pos)
simulation:queue_insert_entity(portal)
this.portal=portal
local aura=E:create_entity(this.entity_aura)
aura.pos=V.vclone(this.aura_pos)
simulation:queue_insert_entity(aura)
this.aura=aura
local torches=E:create_entity(this.entity_torches)
torches.pos=V.vclone(this.torches_pos)
simulation:queue_insert_entity(torches)
this.torches=torches
this.crystals={}
for i=1,this.crystals_count do
local crystal=E:create_entity(this.entity_crystals_prefix..i)
crystal.pos=V.vclone(this.crystals_pos)
crystal.tween.ts=store.tick_ts+fts(math.random(0,120))
local tween_frecueny=math.random(crystal.tween_frecueny_min,crystal.tween_frecueny_max)
crystal.tween.props[1].keys={{fts(0),v(0,0)},{fts(tween_frecueny),v(0,crystal.tween_amplitude)},{fts(tween_frecueny*2),v(0,0)}}
simulation:queue_insert_entity(crystal)
this.crystals[i]=crystal
end
return true
end
controller_stage_11_portal_update=function(this,store)
local is_on=false
local thunder_cd=math.random(this.sound_thunder_cd_min,this.sound_thunder_cd_max)
local thunder_ts=store.tick_ts-thunder_cd
local function update_lightnings()
for _,lightning in ipairs(this.lightnings) do
if store.tick_ts-lightning.ts>lightning.cd then
lightning.entity.render.sprites[1].hidden=false
U.animation_start_default(lightning.entity,"run",nil,store.tick_ts,false)
lightning.cd=math.random(1,3)
lightning.ts=store.tick_ts
end
if not lightning.entity.render.sprites[1].hidden and U.animation_finished_default(lightning.entity) then
lightning.entity.render.sprites[1].hidden=true
end
end
if this.reset_thunder_cd then
thunder_ts=store.tick_ts
this.reset_thunder_cd=false
end
if (store.wave_group_number==0 or this.in_cinematic) and store.tick_ts-thunder_ts>thunder_cd then
S:queue(this.sound_thunder)
thunder_cd=math.random(this.sound_thunder_cd_min,this.sound_thunder_cd_max)
thunder_ts=store.tick_ts
end
end
this.rocks={}
local rocks_count=0
this.lightnings={}
local lightning_templates={"decal_stage_11_lightnings_1","decal_stage_11_lightnings_2","decal_stage_11_lightnings_3"}
for _,e in pairs(store.entities) do
if string.find(e.template_name,"decal_stage_11_rock") then
rocks_count=rocks_count+1
this.rocks[rocks_count]=e
e.tween.ts=store.tick_ts+fts(math.random(0,120))
e.tween.props[1].keys={{fts(0),v(0,0)},{fts(e.tween_frecueny),v(0,e.tween_amplitude)},{fts(e.tween_frecueny*2),v(0,0)}}
end
if table.contains(lightning_templates,e.template_name) then
table.insert(this.lightnings,{entity=e,cd=math.random(1,3),ts=store.tick_ts})
end
end
while store.wave_group_number==0 do
update_lightnings()
coroutine.yield()
end
while true do
local enemies_from_portal=false
if store.level_mode==GAME_MODE_CAMPAIGN then
enemies_from_portal=table.contains(this.config.waves_campaign,store.wave_group_number)
elseif store.level_mode==GAME_MODE_HEROIC then
enemies_from_portal=table.contains(this.config.waves_heroic,store.wave_group_number)
elseif store.level_mode==GAME_MODE_IRON then
enemies_from_portal=table.contains(this.config.waves_iron,store.wave_group_number)
end
if not is_on and enemies_from_portal then
S:queue(this.sound_portal_open)
for i=1,this.crystals_count do
U.animation_start_default(this.crystals[i],"on",nil,store.tick_ts,false)
end
U.y_animation_play(this.portal,"on",nil,store.tick_ts)
U.animation_start_default(this.portal,"loop",nil,store.tick_ts,true)
for i=1,this.crystals_count do
U.animation_start_default(this.crystals[i],"idle_on",nil,store.tick_ts,true)
end
is_on=true
end
if is_on and not enemies_from_portal then
S:queue(this.sound_portal_close)
for i=1,this.crystals_count do
U.animation_start_default(this.crystals[i],"off",nil,store.tick_ts,false)
end
U.y_animation_play(this.portal,"off",nil,store.tick_ts)
U.animation_start_default(this.portal,"idle",nil,store.tick_ts,true)
for i=1,this.crystals_count do
U.animation_start_default(this.crystals[i],"idle_off",nil,store.tick_ts,true)
end
is_on=false
end
update_lightnings()
coroutine.yield()
end
end
controller_stage_11_cultist_leader_modes_update=function(this,store)
local action_cd=math.random(15,20)
local last_action_ts=store.tick_ts
for _,e in pairs(store.entities) do
if e.template_name==this.entity_tables then
this.tables=e
end
if e.template_name==this.entity_worker then
this.worker=e
end
end
while store.wave_group_number==0 do
coroutine.yield()
end
while true do
if action_cd<store.tick_ts-last_action_ts then
if math.random(1,3)<=2 then
U.y_animation_play(this.tables,"action",false,store.tick_ts)
U.animation_start_default(this.tables,"idle",false,store.tick_ts,true)
else
U.y_animation_play(this.tables,"action2",false,store.tick_ts)
U.animation_start_default(this.tables,"idle",false,store.tick_ts,true)
U.y_animation_play(this.worker,"action",false,store.tick_ts)
U.animation_start_default(this.worker,"idle",false,store.tick_ts,true)
end
action_cd=math.random(15,20)
last_action_ts=store.tick_ts
end
coroutine.yield()
end
end
decal_stage_11_veznan_can_select_point=function(this,x,y)
return P:valid_node_nearby(x,y)
end
decal_stage_11_veznan_update=function(this,store)
local SKILL_1=1
local SKILL_2=2
local SKILL_3=3
local last_skill_ts=store.tick_ts
local last_hint_ts=store.tick_ts
this.render.sprites[1].hidden=true
local fx=E:create_entity(this.spawn_fx)
fx.pos=v(113,377)
simulation:queue_insert_entity(fx)
local fx_base=E:create_entity(this.spawn_fx_base)
fx_base.pos=v(113,377)
simulation:queue_insert_entity(fx_base)
U.animation_start_default(fx_base,"start",false,store.tick_ts)
U.y_animation_play(fx,"start",false,store.tick_ts)
U.animation_start_default(fx_base,"loop",false,store.tick_ts,true)
U.animation_start_default(fx,"loop",false,store.tick_ts,true)
U.y_wait_unconditional(store,this.spawn_delay)
U.animation_start_default(fx,"end",false,store.tick_ts)
U.animation_start_default(fx_base,"end",false,store.tick_ts)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.3
shake.aura.duration=0.5
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
U.y_wait_unconditional(store,fts(13))
this.render.sprites[1].hidden=false
U.animation_start_default(this,"spawn",false,store.tick_ts)
U.y_animation_wait_default(fx)
simulation:queue_remove_entity(fx)
simulation:queue_remove_entity(fx_base)
U.y_animation_wait_default(this)
local cult_leader=table.filter(store.entities,function(k,v)
return v.template_name==this.cult_leader_template_name
end)[1]
local corrupted_denas
local function find_boss_corrupted_denas()
return table.filter(store.entities,function(k,v)
return v.template_name==this.boss_corrupted_denas_template_name
end)[1]
end
local function confirm_skill_1()
print("confirm stage 11 veznan skill 1")
local attack=this.attacks.list[1]
U.animation_start_default(this,"skill1",false,store.tick_ts)
S:queue(this.sound_soul_impact_cast)
U.y_wait_unconditional(store,fts(6))
local illusions=table.filter(store.entities,function(k,v)
return v.health and not v.health.dead and v.template_name==this.illusion_template_name
end)
local bullet_amount=#illusions+1
local bullet_formation=this.bullet_formation[bullet_amount]
for i,illusion in ipairs(illusions) do
local b=E:create_entity(attack.bullet)
local pos=V.v(bullet_formation[i].x+this.pos.x,bullet_formation[i].y+this.pos.y)
b.pos=pos
b.bullet.from=V.vclone(b.pos)
b.bullet.to=V.v(this.pos.x+bullet_formation[i].x,this.pos.y+400)
b.target_down=illusion.pos
b.target_id=illusion.id
simulation:queue_insert_entity(b)
U.y_wait_unconditional(store,fts(3))
end
local b=E:create_entity(attack.bullet)
local pos=V.v(bullet_formation[#illusions+1].x+this.pos.x,bullet_formation[#illusions+1].y+this.pos.y)
b.pos=pos
b.bullet.from=V.vclone(b.pos)
b.bullet.to=V.v(this.pos.x+bullet_formation[#illusions+1].x,this.pos.y+400)
b.target_down=cult_leader.pos
b.target_id=cult_leader.id
simulation:queue_insert_entity(b)
U.y_animation_wait_default(this)
U.animation_start_default(this,"charging",false,store.tick_ts,true)
end
local function confirm_skill_2()
local attack=this.attacks.list[2]
U.animation_start_default(this,"Skill2_loop",false,store.tick_ts,true)
U.y_wait_unconditional(store,attack.preparation_time)
for i=1,2 do
local decal=E:create_entity(attack.decal)
decal.pos=attack.decal_pos[i]
simulation:queue_insert_entity(decal)
end
U.y_wait_unconditional(store,attack.spawn_time)
S:queue(this.sound_demon_guard_cast)
for i=1,2 do
local soldier=E:create_entity(attack.entity)
soldier.pos=V.vclone(attack.decal_pos[i])
soldier.available_paths=attack.available_paths[i]
soldier.path_spi=2
simulation:queue_insert_entity(soldier)
soldier=E:create_entity(attack.entity)
soldier.pos=V.vclone({x=attack.decal_pos[i].x-10,y=attack.decal_pos[i].y-10})
soldier.available_paths=attack.available_paths[i]
soldier.path_spi=3
simulation:queue_insert_entity(soldier)
end
U.y_animation_wait_default(this)
U.y_animation_play(this,"Skill2_out",nil,store.tick_ts)
U.animation_start_default(this,"charging",false,store.tick_ts,true)
end
local function confirm_skill_cage()
if not corrupted_denas then
corrupted_denas=find_boss_corrupted_denas()
end
if corrupted_denas then
local attack=this.attacks.list[3]
local decal_fx=E:create_entity("decal_stage_11_veznan_skill_cage")
decal_fx.pos=this.pos
decal_fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(decal_fx)
U.animation_start_default(decal_fx,"loop",false,store.tick_ts,true)
U.animation_start_default(this,"skill3_loop",false,store.tick_ts,true)
U.y_wait_unconditional(store,attack.preparation_time)
local modifier=E:create_entity(attack.mod)
modifier.modifier.target_id=corrupted_denas.id
simulation:queue_insert_entity(modifier)
U.y_animation_wait_default(this)
U.animation_start_default(this,"skill3_out",false,store.tick_ts)
U.y_animation_play(decal_fx,"out",nil,store.tick_ts)
U.y_animation_wait_default(this)
U.animation_start_default(this,"charging",false,store.tick_ts,true)
end
end
U.y_animation_play(this,"talking_in",nil,store.tick_ts)
U.animation_start_default(this,"talking_loop",false,store.tick_ts,true)
U.y_wait_unconditional(store,fts(90))
U.y_animation_play(this,"talking_out",nil,store.tick_ts)
U.animation_start_default(this,"charging",false,store.tick_ts,true)
while true do
if not this.user_selection.allowed and store.tick_ts-last_skill_ts>=this.skill_cooldown then
this.user_selection.allowed=true
S:queue(this.sound_ready)
U.y_animation_play(this,"READY_in",nil,store.tick_ts)
U.animation_start_default(this,"READY_loop",false,store.tick_ts,true)
end
if this.user_selection.allowed and store.tick_ts-last_hint_ts>=this.hint_cooldown then
this.hint=E:create_entity(this.hint_template_name)
this.hint.pos=this.pos
this.hint.tween.ts=store.tick_ts
simulation:queue_insert_entity(this.hint)
last_hint_ts=store.tick_ts
end
if this.user_selection.menu_shown and this.hint then
this.hint.render.sprites[1].hidden=true
simulation:queue_remove_entity(this.hint)
this.hint=nil
end
if this.user_selection.in_progress then
this.user_selection.in_progress=nil
this.user_selection.allowed=false
local start_ts=store.tick_ts
if this.user_selection.arg==SKILL_1 then
confirm_skill_1()
elseif this.user_selection.arg==SKILL_2 then
confirm_skill_2()
elseif this.user_selection.arg==SKILL_3 then
confirm_skill_cage()
end
last_skill_ts=start_ts
last_hint_ts=start_ts
end
coroutine.yield()
end
end
decal_stage_11_sam_and_frodo_update=function(this,store)
this.render.sprites[1].hidden=true
this.ui.can_click=false
while store.wave_group_number<2 do
coroutine.yield()
end
U.y_wait_unconditional(store,20)
this.render.sprites[1].hidden=false
U.y_animation_play(this,"in",false,store.tick_ts)
this.ui.can_click=true
local last_push=store.tick_ts
local already_done_action=false
while true do
if not already_done_action then
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
S:queue("Stage11EasterEggFrodoAndSam",{delay=fts(90)})
U.y_animation_play(this,"action",nil,store.tick_ts)
already_done_action=true
signal.emit("lotr-stage11",this)
break
end
if store.tick_ts-last_push>=this.push_up_cooldown then
U.y_animation_play(this,"idle2",nil,store.tick_ts)
last_push=store.tick_ts
end
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_stage_11_cultist_leader_modes_worker","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].prefix="stage_11_deco_mydrias_workerDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].draw_order=2
tt=E:register_t_hot("decal_stage_11_boss_corrupted_denas_intro_base","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="denas_intro_baseDef"
tt.render.sprites[1].name="start"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_11_rock_4","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_4"
tt=E:register_t_hot("decal_stage_11_rock_13","decal_stage_11_rock_1",true)
tt.render.sprites[1].scale=vv(0.85)
tt=E:register_t_hot("decal_stage_11_sam_and_frodo","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="sam_and_frodoDef"
tt.render.sprites[1].name="in"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.main_script.update=decal_stage_11_sam_and_frodo_update
tt.ui.click_rect=r(370,-270,50,40)
tt.push_up_cooldown=7
tt=E:register_t_hot("controller_stage_11_portal",nil,true)
E:add_comps(tt,"editor","pos","main_script")
tt.main_script.insert=controller_stage_11_portal_insert
tt.main_script.update=controller_stage_11_portal_update
tt.entity_portal="decal_stage_11_portal"
tt.portal_pos=v(512,384)
tt.entity_aura="aura_stage_11_portal"
tt.aura_pos=v(880,580)
tt.entity_torches="decal_stage_11_torches"
tt.torches_pos=v(512,384)
tt.entity_crystals_prefix="decal_stage_11_portal_crystal_"
tt.crystals_count=8
tt.crystals_pos=v(512,384)
tt.config={waves_campaign={3,4,5,6,7,8,9,10,12,13,14,15},waves_heroic={2,3,4,5,6},waves_iron={1}}
tt.sound_thunder="Stage11AmbienceThunder"
tt.sound_thunder_cd_min=8
tt.sound_thunder_cd_max=12
tt.sound_portal_open="Stage11PortalOpen"
tt.sound_portal_close="Stage11PortalClose"
tt=E:register_t_hot("decal_stage_11_rock_11","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_11"
tt=E:register_t_hot("decal_stage_11_rock_12","decal_stage_11_rock_11",true)
tt.render.sprites[1].scale=vv(1.35)
tt=E:register_t_hot("decal_boss_corrupted_denas_dust","decal",true)
tt.render.sprites[1].name="denas_dustexplosion_run"
tt.render.sprites[1].hide_after_runs=1
tt=E:register_t_hot("controller_stage_11_cultist_leader_modes",nil,true)
E:add_comps(tt,"editor","main_script")
tt.main_script.update=controller_stage_11_cultist_leader_modes_update
tt.entity_tables="decal_stage_11_cultist_leader_modes"
tt.entity_worker="decal_stage_11_cultist_leader_modes_worker"
tt=E:register_t_hot("decal_stage_11_rock_5","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_5"
tt.render.sprites[1].scale=vv(0.65)
tt=E:register_t_hot("decal_stage_11_boss_corrupted_denas_intro_jump","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="denas_intro_jumpDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].loop=false
tt=E:register_t_hot("decal_stage_11_rock_6","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_6"
tt=E:register_t_hot("decal_stage_11_rock_8","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_8"
tt.render.sprites[1].scale=vv(0.75)
tt=E:register_t_hot("decal_stage_11_rock_3","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_3"
tt=E:register_t_hot("decal_stage_11_boss_corrupted_denas_intro_chains","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="denas_intro_chainsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_11_rock_18","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_12"
tt=E:register_t_hot("decal_stage_11_rock_19","decal_stage_11_rock_18",true)
tt.render.sprites[1].scale=v(0.5,0.5)
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_stage_11_sam_and_frodo_mask","decal",true)
tt.render.sprites[1].name="sam_and_frodo_easter_egg_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS+1
tt=E:register_t_hot("decal_stage_11_rock_16","decal_stage_11_rock_4",true)
tt.render.sprites[1].scale=vv(1.25)
tt=E:register_t_hot("decal_stage_11_veznan","tower",true)
E:add_comps(tt,"user_selection","attacks")
tt.tower.type="stage_11_veznan"
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.render.sprites[1].prefix="stage11_veznan_export_veznan"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].scale=vv(1.15)
tt.info=nil
tt.user_selection=CC("user_selection")
tt.user_selection.can_select_point_fn=decal_stage_11_veznan_can_select_point
tt.main_script.update=decal_stage_11_veznan_update
tt.attacks.list[1]=E:clone_c("custom_attack")
tt.attacks.list[1].bullet="bullet_stage_11_veznan_skill_1"
tt.attacks.list[1].bullet_spawn_pos=v(0,50)
tt.attacks.list[2]=E:clone_c("custom_attack")
tt.attacks.list[2].preparation_time=fts(25)
tt.attacks.list[2].spawn_time=fts(30)
tt.attacks.list[2].decal="decal_stage_11_veznan_skill_soldiers"
tt.attacks.list[2].decal_pos={v(-40,333),v(540,91)}
tt.attacks.list[2].entity="soldier_stage_11_veznan_skill_soldiers"
tt.attacks.list[2].available_paths={{1,4},{2,3,5}}
tt.attacks.list[3]=E:clone_c("custom_attack")
tt.attacks.list[3].preparation_time=fts(25)
tt.attacks.list[3].mod="mod_stage_11_veznan_skill_cage"
tt.skill_cooldown=12
tt.hint_cooldown=10
tt.illusion_template_name="enemy_stage_11_cult_leader_illusion"
tt.cult_leader_template_name="decal_stage_11_cult_leader"
tt.boss_corrupted_denas_template_name="boss_corrupted_denas"
tt.hint_template_name="decal_stage_11_veznan_hint"
tt.bullet_formation={{v(0,50)},{v(-20,30),v(20,30)},{v(-20,30),v(20,30),v(0,50)},{v(-20,40),v(20,40),v(0,60),v(0,30)}}
tt.spawn_fx="fx_stage_11_veznan_spawn"
tt.spawn_fx_base="fx_stage_11_veznan_spawn_base"
tt.spawn_delay=fts(42)
tt.sound_events.insert="Stage11MidCinematicVeznanTeleport"
tt.sound_ready="Stage11MidCinematicVeznanTeleport"
tt.sound_soul_impact_cast="Stage11VeznanSoulImpactCast"
tt.sound_demon_guard_cast="Stage11VeznanDemonGuardCast"
tt=E:register_t_hot("decal_stage_11_rock_10","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_10"
tt=E:register_t_hot("decal_stage_11_rock_15","decal_stage_11_rock_2",true)
tt.render.sprites[1].scale=vv(2)
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_stage_11_cultist_leader_modes","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].prefix="stage_11_deco_mydrias_baseDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].draw_order=1
tt=E:register_t_hot("decal_stage_11_rock_9","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_9"
tt=E:register_t_hot("decal_stage_11_rock_7","decal_stage_11_rock_1",true)
tt.render.sprites[1].name="T2_Stage_11_floating_rocks_7"
tt=E:register_t_hot("decal_stage_11_rock_17","decal_stage_11_rock_4",true)
tt.render.sprites[1].scale=v(0.75,0.5)
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_stage_11_veznan_modes","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].name="deco_veznan_statue_statue"
tt.render.sprites[1].animated=false
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="deco_veznan_statue_torch"
tt.render.sprites[2].name="idle"
tt.render.sprites[2].draw_order=2
tt.render.sprites[2].offset=v(0,-66)
tt=E:register_t_hot("decal_stage_11_rock_14","decal_stage_11_rock_13",true)
tt.render.sprites[1].flip_x=true
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",0,{x=620,y=512},1.8)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local cult_leader,cult_leader_chains,controller_cult_leader,controller_portal
U.y_wait_unconditional(store,1.5)
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_11_cult_leader" then
cult_leader=e
elseif e.template_name=="decal_stage_11_boss_corrupted_denas_intro_chains" then
cult_leader_chains=e
elseif e.template_name=="controller_stage_11_cult_leader" then
controller_cult_leader=e
elseif e.template_name=="controller_stage_11_portal" then
controller_portal=e
end
end
signal.emit("show-balloon_tutorial","LV11_CULTIST01",false)
U.y_wait_unconditional(store,3)
U.y_wait_unconditional(store,0.5)
signal.emit("show-balloon_tutorial","LV11_CULTIST02",false)
U.y_wait_unconditional(store,3)
U.y_wait_unconditional(store,0.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=460,y=150},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store,{"enemy_stage_11_cult_leader_illusion"}) do
coroutine.yield()
end
controller_cult_leader.taunts_enabled=false
controller_portal.in_cinematic=true
controller_portal.reset_thunder_cd=true
local illusion_enemies=table.filter(store.entities,function(_,e)
return e.main_script and (e.main_script.co or e.main_script.runs>0) and (e.enemy and e.health and not e.health.dead or e.enemy and e.death_spawns or e.spawner and not e.spawner.eternal or e.picked_enemies and #e.picked_enemies>0 or e.tunnel and #e.tunnel.picked_enemies>0 or e.template_name=="enemy_stage_11_cult_leader_illusion")
end)
for _,enemy in ipairs(illusion_enemies) do
enemy.dissapear=true
end
log.info("finish waves")
U.y_wait_unconditional(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=620,y=500},1.8)
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,2)
signal.emit("show-balloon_tutorial","LV11_CULTIST03",false)
U.y_wait_unconditional(store,2)
U.y_wait_unconditional(store,0.5)
signal.emit("show-balloon_tutorial","LV11_CULTIST04",false)
U.y_wait_unconditional(store,3)
U.y_wait_unconditional(store,0.5)
U.animation_start_default(cult_leader,"breakchains",nil,store.tick_ts)
S:queue("Stage11MidCinematicChainBreak")
cult_leader_chains.render.sprites[1].z=Z_OBJECTS_COVERS
U.animation_start_default(cult_leader_chains,"run",nil,store.tick_ts)
U.y_wait_unconditional(store,fts(48))
LU.queue_remove(store,cult_leader_chains)
S:queue("Stage11MidCinematicPlatformMove")
U.y_animation_wait_default(cult_leader)
U.animation_start_default(cult_leader,"breakchainsidle",nil,store.tick_ts,true)
local denas_jump=E:create_entity("decal_stage_11_boss_corrupted_denas_intro_jump")
denas_jump.pos=V.v(735,430)
denas_jump.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,denas_jump)
S:queue("Stage11MidCinematicDenasJump")
U.y_wait_unconditional(store,fts(19))
LU.queue_remove(store,denas_jump)
local corrupted_denas=E:create_entity("boss_corrupted_denas")
corrupted_denas.pos=V.v(632,512)
LU.queue_insert(store,corrupted_denas)
local denas_decal=E:create_entity("decal_boss_corrupted_denas_hit_floor")
denas_decal.pos=V.v(632,512)
denas_decal.tween.ts=store.tick_ts
LU.queue_insert(store,denas_decal)
S:queue("Stage11MidCinematicDenasJumpLand")
local denas_dust=E:create_entity("decal_boss_corrupted_denas_dust")
denas_dust.pos=V.v(632,512)
denas_dust.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,denas_dust)
U.y_wait_unconditional(store,2.5)
S:queue("Stage11MidCinematicPlatformMove")
U.y_animation_play(cult_leader,"breakchainsback",nil,store.tick_ts)
cult_leader.tween.ts=store.tick_ts
cult_leader.tween.disabled=false
U.animation_start_default(cult_leader,"idle",nil,store.tick_ts,true)
signal.emit("pan-zoom-camera",2,{x=400,y=600},OVm(1,1.2))
U.y_wait_unconditional(store,2)
local veznan=E:create_entity("decal_stage_11_veznan")
veznan.pos=V.v(113,500)
LU.queue_insert(store,veznan)
U.y_wait_unconditional(store,2.4)
signal.emit("show-balloon_tutorial","LV11_VEZNAN01",false)
U.y_wait_unconditional(store,3)
S:stop_group("MUSIC")
S:queue("MusicBossFight_111")
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic")
controller_cult_leader.last_taunt=store.tick_ts
controller_cult_leader.taunts_enabled=true
controller_portal.in_cinematic=false
while not corrupted_denas.health.dead or not store.waves_finished do
coroutine.yield()
end
controller_cult_leader.taunts_enabled=false
controller_portal.in_cinematic=true
controller_portal.reset_thunder_cd=true
if corrupted_denas.health.dead then
controller_cult_leader.is_denas_dead=true
signal.emit("boss_fight_end")
U.y_wait_unconditional(store,2)
LU.kill_all_enemies(store,true)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=620,y=600},1.8)
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,2)
signal.emit("show-balloon_tutorial","LV11_CULTIST05_ESCAPE",false)
U.y_wait_unconditional(store,3)
U.y_wait_unconditional(store,0.5)
controller_cult_leader.leave=true
U.y_wait_unconditional(store,3)
if store.level_difficulty==DIFFICULTY_IMPOSSIBLE then
signal.emit("no_projections_bossfight-stage11",controller_cult_leader)
end
U.y_wait_unconditional(store,2)
signal.emit("fade-out",1)
end
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="5"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="10"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
