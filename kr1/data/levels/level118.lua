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
local v=V.v
local r=V.r
local controller_stage_18_eridan_update
local decal_stage_18_streetlight_update
local decal_stage_18_cuckoo_update
controller_stage_18_eridan_update=function(this,store)
local ab=this.bullet_attack
ab.ts=store.tick_ts-ab.cooldown
local ai=this.custom_attack
ai.ts=store.tick_ts-ai.cooldown
local last_shot_pos
local taunt_ts=store.tick_ts
local taunt_cd=math.random(this.taunts.delay_min,this.taunts.delay_max)
local function shoot_bullet(target,flip_x)
local target_pos,offset,tid
if target then
target_pos=target.pos
offset=target.unit.hit_offset
tid=target.id
else
target_pos=last_shot_pos
target_pos.x=target_pos.x+math.random(-5,5)
target_pos.y=target_pos.y+math.random(-5,5)
offset=V.vv(0)
end
local b=E:create_entity(ab.bullet)
local boffset=ab.bullet_start_offset[flip_x and 2 or 1]
b.bullet.from=V.v(this.pos.x+boffset.x,this.pos.y+boffset.y)
b.bullet.to=V.v(target_pos.x+offset.x,target_pos.y+offset.y)
b.bullet.target_id=tid
b.bullet.source_id=this.id
b.pos=V.vclone(b.bullet.from)
simulation:queue_insert_entity(b)
S:queue("ArrowSound")
end
local function find_target()
return U.find_foremost_enemy_in_range_filter_on(this.pos,ab.max_range,false,ab.vis_flags,ab.vis_bans,function(e,o)
return P:nodes_to_goal(e.nav_path.pi,e.nav_path.spi,e.nav_path.ni)>20
end)
end
while true do
if taunt_cd<store.tick_ts-taunt_ts and store.tick_ts-ai.ts<ai.cooldown-3 then
if store.wave_group_number==0 then
SU.y_show_taunt_set(store,this.taunts,"preparation",false)
else
SU.y_show_taunt_set(store,this.taunts,"fight",false)
end
taunt_ts=store.tick_ts
taunt_cd=math.random(this.taunts.delay_min,this.taunts.delay_max)
end
if store.tick_ts-ab.ts>ab.cooldown then
local target,_,pred_pos=find_target()
if not target or not pred_pos then
SU.delay_attack(store,ab,0.2)
goto label_1332_0
end
if target and target.health and not target.health.dead then
ab.ts=store.tick_ts
last_shot_pos=target.pos
local an,af=U.animation_name_facing_point(this,ab.animation,pred_pos)
U.animation_start_default(this,an,af,store.tick_ts,false)
U.y_wait_unconditional(store,ab.shoot_times[1])
shoot_bullet(target,af)
U.y_wait_unconditional(store,ab.shoot_times[2]-ab.shoot_times[1])
local target,_=find_target()
shoot_bullet(target,af)
U.y_wait_unconditional(store,ab.shoot_times[3]-ab.shoot_times[2])
local target,_=find_target()
shoot_bullet(target,af)
U.y_animation_wait_default(this)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
end
elseif store.tick_ts-ai.ts>ai.cooldown then
local target,_,pred_pos=U.find_foremost_enemy_in_range_filter_on(this.pos,ai.max_range,false,ai.vis_flags,ai.vis_bans,function(e,o)
return e.health and e.health.hp<ai.hp_threshold and e.enemy and #e.enemy.blockers==0
end)
if not target or not pred_pos then
SU.delay_attack(store,ai,0.2)
goto label_1332_0
end
if target and target.health and not target.health.dead then
ai.ts=store.tick_ts
local start_pos=V.vclone(this.pos)
local mod=E:create_entity(ai.mod)
mod.modifier.target_id=target.id
mod.modifier.source_id=this.id
simulation:queue_insert_entity(mod)
target.health.ignore_damage=true
U.y_wait_unconditional(store,fts(1))
target.vis.bans=F_ALL
S:queue(this.sound_in_out)
U.y_animation_play(this,ai.animation_start,false,store.tick_ts)
this.pos=V.vclone(target.pos)
this.pos.x=this.pos.x-ai.melee_slot_x
this.render.sprites[1].z=Z_OBJECTS
U.y_animation_play(this,ai.animation_end,false,store.tick_ts)
S:queue(this.sound_instakill)
U.animation_start_default(this,ai.animation_fight,false,store.tick_ts,false)
U.y_wait_unconditional(store,ai.hit_time)
target.health.ignore_damage=false
local d=E.assign_damage(ai.damage_type,0,this.id,target.id)
d.pop=ai.pop
d.pop_chance=1
queue_damage(store,d)
U.y_animation_wait_default(this)
S:queue(this.sound_in_out)
U.y_animation_play(this,ai.animation_start,false,store.tick_ts)
this.pos=start_pos
this.render.sprites[1].z=Z_OBJECTS_COVERS+1
U.y_animation_play(this,ai.animation_end,false,store.tick_ts)
U.animation_start_default(this,"idle",false,store.tick_ts,true)
end
end
U.y_animation_wait_default(this)
::label_1332_0::
coroutine.yield()
end
end
decal_stage_18_streetlight_update=function(this,store)
while true do
if this.ui.clicked then
S:queue(this.sound_in)
this.ui.clicked=nil
this.ui.can_click=false
S:queue(this.sound_break)
U.y_animation_play(this,"action",nil,store.tick_ts,1)
U.animation_start_default(this,"idle_broken",nil,store.tick_ts,true)
end
coroutine.yield()
end
end
decal_stage_18_cuckoo_update=function(this,store)
local touch_times=0
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
touch_times=touch_times+1
if touch_times==this.touches_needed then
S:queue(this.sound_in)
U.y_animation_play(this,"action_2_in",nil,store.tick_ts,1)
U.animation_start_default(this,"action_2_idle",nil,store.tick_ts,true)
U.y_wait_unconditional(store,this.duration)
S:queue(this.sound_out)
U.y_animation_play(this,"action_2_out",nil,store.tick_ts,1)
this.ui.can_click=true
if this.reset_touches then
touch_times=0
end
elseif touch_times<this.touches_needed or touch_times>this.touches_needed and this.touchable_after_anim then
U.y_animation_play(this,"action_1",nil,store.tick_ts,1)
this.ui.can_click=true
end
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_18_streetlight_1","decal_scripted",true)
E:add_comps(tt,"editor","editor_script","ui")
tt.render.sprites[1].prefix="stage_18_light_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=-250
tt.main_script.update=decal_stage_18_streetlight_update
tt.ui.click_rect=r(-60,-210,30,40)
tt.sound_break="Stage18LampBreak"
tt=E:register_t_hot("decal_stage_18_streetlight_4","decal_stage_18_streetlight_1",true)
tt.render.sprites[1].prefix="stage_18_light_4Def"
tt.render.sprites[1].sort_y_offset=33
tt.ui.click_rect=r(520,73,30,40)
tt=E:register_t_hot("decal_stage_18_bubbles_water","decal",true)
tt.render.sprites[1].prefix="stage_18_bubbles_waterDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_18_bubbles","decal",true)
tt.render.sprites[1].prefix="stage_18_bubblesDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_18_streetlight_3","decal_stage_18_streetlight_1",true)
tt.render.sprites[1].prefix="stage_18_light_3Def"
tt.render.sprites[1].sort_y_offset=223
tt.ui.click_rect=r(535,263,30,40)
tt=E:register_t_hot("controller_stage_18_eridan","decal_scripted",true)
E:add_comps(tt,"bullet_attack","custom_attack","editor","taunts")
tt.render.sprites[1].prefix="eridan_s18_eridan"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.render.sprites[1].sort_y_offset=-10
tt.main_script.update=controller_stage_18_eridan_update
tt.bullet_attack.max_range=380
tt.bullet_attack.bullet="bullet_stage_18_eridan_arrow"
tt.bullet_attack.shoot_times={fts(11),fts(17),fts(23)}
tt.bullet_attack.cooldown=4
tt.bullet_attack.bullet_start_offset={v(20,30),v(-20,30)}
tt.bullet_attack.animation="shoot"
tt.custom_attack.max_range=250
tt.custom_attack.shoot_time=fts(3)
tt.custom_attack.cooldown=18
tt.custom_attack.animation_start="dash_out"
tt.custom_attack.animation_fight="fight_sequence"
tt.custom_attack.animation_end="dash_in"
tt.custom_attack.hp_threshold=700
tt.custom_attack.melee_slot_x=40
tt.custom_attack.mod="mod_stage_18_eridan_stun"
tt.custom_attack.hit_time=fts(46)
tt.custom_attack.pop={"pop_crit"}
tt.custom_attack.damage_type=DAMAGE_INSTAKILL
tt.custom_attack.vis_flags=bor(F_TELEPORT)
tt.custom_attack.vis_bans=bor(F_FLYING)
tt.sound_in_out="Stage18EridanInOut"
tt.sound_instakill="Stage18EridanInstakill"
tt.taunts.delay_min=20
tt.taunts.delay_max=30
tt.taunts.sets={}
tt.taunts.sets.preparation=CC("taunt_set")
tt.taunts.sets.preparation.format="LV18_ERIDAN_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx=4
tt.taunts.sets.fight=CC("taunt_set")
tt.taunts.sets.fight.format="LV18_ERIDAN_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx=8
tt=E:register_t_hot("decal_stage_18_cuckoo","decal_scripted",true)
E:add_comps(tt,"ui")
tt.ui.click_rect=r(-30,-30,60,60)
tt.main_script.update=decal_stage_18_cuckoo_update
tt.render.sprites[1].prefix="cuckoo_easter_egg_door"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.touches_needed=3
tt.touchable_after_anim=false
tt.reset_touches=false
tt.duration=0.6
tt.sound_in="Stage18CuckooIn"
tt.sound_out="Stage18CuckooOut"
tt=E:register_t_hot("decal_stage_18_streetlight_2","decal_stage_18_streetlight_1",true)
tt.render.sprites[1].prefix="stage_18_light_2Def"
tt.render.sprites[1].sort_y_offset=250
tt.ui.click_rect=r(135,290,30,40)
tt=E:register_t_hot("decal_stage_18_tree_1","decal_scripted",true)
E:add_comps(tt,"editor","ui")
tt.render.sprites[1].prefix="stage_18_tree_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.main_script.update=scripts.decal_stage_17_tree.update
tt.ui.click_rect=r(-335,-200,80,80)
tt.sound_tap="Terrain4HowlingTree"
tt=E:register_t_hot("decal_stage_18_tree_2","decal_stage_18_tree_1",true)
tt.render.sprites[1].prefix="stage_18_tree_2Def"
tt.ui.click_rect=r(495,-170,80,80)
end
function level:load(store)
return
end
function level:update(store)
for i=1,4 do
P:add_invalid_range(i,P:get_end_node(i)-10,P:get_end_node(i))
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
