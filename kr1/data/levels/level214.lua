local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local GR=require("grid_db")
local V=require("lib.klua.vector")
local km=require("lib.klua.macros")
local log=require("lib.klua.log"):new("level214")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
local S=require("sound_db")
local scripts=require("scripts")
local signal=require("lib.hump.signal")
local r=V.r
local v=V.v
local vv=V.vv
local fts=function(t)
return t/30
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function tower_stage_214_blacksmith_update(this,store,script)
local visuals=find_all_t(store,this.decal)[1]
local alert=find_all_t(store,this.alert)[1]
local achievement_tracker=find_all_t(store,this.achievement_tracker)[1]
local a
local repaired=false
alert.tween.reverse=true
local run_anim_ts=store.tick_ts-(this.bubble_cd-math.random(5,15))
while true do
if not repaired then
local price=this.powers.skill_a.level==0 and this.powers.skill_a.price_base or this.powers.skill_a.price_inc
if store.tick_ts-run_anim_ts>this.bubble_cd and store.player_gold>=price then
alert.render.sprites[1].hidden=false
alert.render.sprites[1].ts=store.tick_ts
alert.tween.ts=store.tick_ts
alert.tween.reverse=false
alert.tween.disabled=false
U.animation_start(visuals,"broken_action",nil,store.tick_ts,false,1)
U.animation_start(alert,"loop",nil,store.tick_ts,true,1)
run_anim_ts=store.tick_ts
end
if not alert.tween.reverse and store.tick_ts-run_anim_ts>this.loop_bubble_time then
alert.tween.ts=store.tick_ts
alert.tween.reverse=true
run_anim_ts=store.tick_ts-math.random(0,10)
end
end
if this.powers.skill_a.changed then
if a then
simulation:queue_remove_entity(a)
S:queue(this.upgrade_taunt)
else
repaired=true
alert.render.sprites[1].hidden=true
S:queue(this.repair_sound)
S:queue(this.repair_taunt)
U.y_animation_play(visuals,"fix",nil,store.tick_ts,1,1)
U.animation_start(visuals,"fixed",nil,store.tick_ts,true,1)
S:queue(this.aura_sound)
end
a=E:create_entity(this.aura..this.powers.skill_a.level)
a.pos.x,a.pos.y=this.pos.x+this.aura_offset.x,this.pos.y+this.aura_offset.y
simulation:queue_insert_entity(a)
if this.powers.skill_a.level==3 then
achievement_tracker.blacksmith_maxed=true
end
this.powers.skill_a.changed=false
end
coroutine.yield()
end
end
local function tower_stage_214_armory_update(this,store,script)
local b=this.barrack
local door_sid=3
local visuals=find_all_t(store,this.decal)[1]
local achievement_tracker=find_all_t(store,this.achievement_tracker)[1]
local alert=find_all_t(store,this.alert)[1]
alert.tween.reverse=true
local run_anim_ts=store.tick_ts-(this.bubble_cd-math.random(5,15))
while not this.repair.active do
if store.tick_ts-run_anim_ts>this.bubble_cd and store.player_gold>=this.repair.cost then
alert.render.sprites[1].hidden=false
alert.render.sprites[1].ts=store.tick_ts
alert.tween.ts=store.tick_ts
alert.tween.reverse=false
alert.tween.disabled=false
U.animation_start(visuals,"broken_action",nil,store.tick_ts,false,1)
U.animation_start(alert,"loop",nil,store.tick_ts,true,1)
run_anim_ts=store.tick_ts
end
if not alert.tween.reverse and store.tick_ts-run_anim_ts>this.loop_bubble_time then
alert.tween.ts=store.tick_ts
alert.tween.reverse=true
run_anim_ts=store.tick_ts-math.random(0,10)
end
if this.user_selection and this.user_selection.in_progress and not this.repair.active then
this.user_selection.in_progress=nil
this.repair.active=true
store.player_gold=store.player_gold-this.repair.cost
alert.render.sprites[1].hidden=true
S:queue(this.repair_sound)
S:queue(this.repair_taunt)
U.y_animation_play(visuals,"fix",nil,store.tick_ts,1,1)
U.animation_start(visuals,"fixed",nil,store.tick_ts,true,1)
this.tower.blocked=false
this.tower.type="stage_214_armory_fixed"
this.ui.force_can_select=nil
simulation:queue_remove_entity(alert)
U.y_wait(store,fts(10))
find_all_t(store,this.mask)[1].render.sprites[1].hidden=false
end
coroutine.yield()
end
local pow_a=this.powers and this.powers.skill_a or nil
local pow_b=this.powers and this.powers.skill_b or nil
local function check_max_level()
if this.powers.skill_a.level==1 and this.powers.skill_b.level==3 then
achievement_tracker.armory_maxed=true
end
end
local function apply_upg_b(level)
if level<=0 then
return
end
for i,s in ipairs(this.barrack.soldiers) do
s.health.dead_lifetime=pow_b.respawn_times[level]
end
end
local function check_powers()
if not this.powers then
return
end
for pn,p in pairs(this.powers) do
if p.changed then
p.changed=nil
if p==pow_a then
for i,s in ipairs(this.barrack.soldiers) do
if s.health.dead then
else
local nst=p.soldier_type
local ns=E:create_entity(nst)
ns.info.i18n_key=s.info.i18n_key
ns.soldier.tower_id=this.id
ns.soldier.tower_soldier_idx=i
ns.pos=V.vclone(s.pos)
ns.motion.dest=V.vclone(s.motion.dest)
ns.motion.arrived=s.motion.arrived
ns.render.sprites[1].flip_x=s.render.sprites[1].flip_x
ns.render.sprites[1].flip_y=s.render.sprites[1].flip_y
ns.render.sprites[1].name=s.render.sprites[1].name
ns.render.sprites[1].loop=s.render.sprites[1].loop
ns.render.sprites[1].ts=s.render.sprites[1].ts
ns.render.sprites[1].runs=s.render.sprites[1].runs
ns.nav_rally.pos=V.vclone(s.nav_rally.pos)
ns.nav_rally.center=V.vclone(s.nav_rally.center)
ns.nav_rally.new=s.nav_rally.new
for i,a in ipairs(ns.melee.attacks) do
if s.melee.attacks[i] then
a.ts=s.melee.attacks[i].ts
end
end
U.replace_blocker(store,s,ns)
this.barrack.soldiers[i]=ns
simulation:queue_insert_entity(ns)
s.health.dead=true
simulation:queue_remove_entity(s)
end
end
b.soldier_type=p.soldier_type
apply_upg_b(pow_b.level)
end
if p==pow_b then
apply_upg_b(p.level)
end
check_max_level()
end
end
end
while true do
check_powers()
if not this.tower.blocked then
for i=1,b.max_soldiers do
local s=b.soldiers[i]
if not s or s.health.dead and not store.entities[s.id] then
if b.has_door and not b.door_open then
S:queue("GUITowerOpenDoor")
U.animation_start(this,"open",nil,store.tick_ts,true,door_sid)
while not U.animation_finished(this,door_sid) do
coroutine.yield()
end
b.door_open=true
b.door_open_ts=store.tick_ts
end
s=E:create_entity(b.soldier_type)
s.soldier.tower_id=this.id
s.soldier.tower_soldier_idx=i
s.pos=V.v(this.pos.x+b.respawn_offset.x,this.pos.y+b.respawn_offset.y)
s.nav_rally.pos,s.nav_rally.center=U.rally_formation_position(i,b,b.max_soldiers,b.rally_angle_offset)
s.nav_rally.new=true
if pow_b.level>0 then
s.health.dead_lifetime=pow_b.respawn_times[pow_b.level]
end
simulation:queue_insert_entity(s)
b.soldiers[i]=s
signal.emit("tower-spawn",this,s)
U.y_wait(store,fts(25),function()
check_powers()
return false
end)
end
end
end
if b.has_door and b.door_open and store.tick_ts-b.door_open_ts>b.door_hold_time then
U.animation_start(this,"close",nil,store.tick_ts,true,door_sid)
while not U.animation_finished(this,door_sid) do
coroutine.yield()
end
b.door_open=false
end
if b.rally_new then
b.rally_new=false
signal.emit("rally-point-changed",this)
local all_dead=true
for i,s in ipairs(b.soldiers) do
s.nav_rally.pos,s.nav_rally.center=U.rally_formation_position(i,b,b.max_soldiers,b.rally_angle_offset)
s.nav_rally.new=true
all_dead=all_dead and s.health.dead
end
if not all_dead then
S:queue(this.sound_events.change_rally_point)
end
end
coroutine.yield()
end
end
local function controller_stage_214_houses_update(this,store)
local conts={}
local houses=find_all_t(store,this.bush_t)
for i,h in pairs(houses) do
local cont=E:create_entity(this.cont_t)
cont.house_id=h.id
queue_insert(store,cont)
table.insert(conts,cont)
end
table.sort(houses,function(b1,b2)
return b1.pos.x<b2.pos.x
end)
table.sort(conts,function(c1,c2)
return store.entities[c1.house_id].pos.x<store.entities[c2.house_id].pos.x
end)
while true do
if this.spawn_blades then
conts[this.house_id].do_spawn=true
conts[this.house_id].path_id=this.path_id
conts[this.house_id].enemies_count=this.enemies_count
this.spawn_blades=false
end
coroutine.yield()
end
end
local function controller_stage_214_houses_on_event(this,store,action,house_id,count)
this.spawn_blades=true
this.house_id=tonumber(house_id)
this.enemies_count=tonumber(count)
log.info("EVENT HOUSE SPAWN. COUNT: "..this.enemies_count)
end
local function controller_stage_214_house_spawner_update(this,store)
local house=store.entities[this.house_id]
while true do
if this.do_spawn then
local start_ts=store.tick_ts
U.y_wait(store,this.spawn_delay-(store.tick_ts-start_ts))
local nearest_nodes=P:nearest_nodes(house.pos.x,house.pos.y,{this.path_id},{1})
local pi,spi,ni=unpack(nearest_nodes[1])
for i=1,this.enemies_count do
local enemy=E:create_entity(this.enemy_t)
enemy.nav_path.pi=this.path_id
enemy.nav_path.ni=ni+5
enemy.nav_path.spi=math.random(1,3)
enemy.pos=V.vclone(house.pos)
enemy.source_id=this.id
queue_insert(store,enemy)
U.y_wait(store,this.delay_between)
end
this.do_spawn=false
end
coroutine.yield()
end
end
local function controller_stage_214_community_building_achievement_update(this,store)
while true do
if this.armory_maxed and this.blacksmith_maxed then
signal.emit("community-building-stage14")
queue_remove(store,this)
return
end
coroutine.yield()
end
end
local function easter_egg_stage_214_delorean_update(this,store,script)
local clicks=0
while true do
if this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
if clicks==1 then
S:queue(this.sound_turn_on)
U.y_animation_play(this,"tap_1",nil,store.tick_ts,1,1)
U.animation_start(this,"loop_1",nil,store.tick_ts,true,1)
elseif clicks==2 then
S:stop(this.sound_turn_on)
S:queue(this.sound_power_down)
U.y_animation_play(this,"tap_2",nil,store.tick_ts,1,1)
U.animation_start(this,"idle2",nil,store.tick_ts,true,1)
signal.emit("depower-of-love-stage14")
return
end
end
coroutine.yield()
end
end
local function easter_egg_stage_214_goat_fall_update(this,store,script)
local clicks=0
while true do
if this.ui.clicked then
this.ui.clicked=false
clicks=clicks+1
if this.sound_tap then
if clicks>1 then
S:stop(this.sound_tap[clicks-1])
end
local frame=this.sound_tap_frames and this.sound_tap_frames[clicks]
S:queue(this.sound_tap[clicks],frame and frame>0 and {delay=fts(frame)} or nil)
end
U.y_animation_play(this,"tap_"..clicks,nil,store.tick_ts,1,1)
U.animation_start(this,"idle_"..clicks+1,nil,store.tick_ts,true,1)
if clicks==2 then
return
end
end
coroutine.yield()
end
end
local function stage_214_goat_graveyard_update(this,store,script)
local taps_count=0
local eat_ts=store.tick_ts
local eat_cd=fts(math.random(3*FPS,7*FPS))
while true do
if this.ui.clicked then
this.ui.clicked=nil
taps_count=taps_count+1
if taps_count==this.taps_to_explode then
S:queue(this.sound)
this.health.dead=true
this.health.death_ts=store.tick_ts-1
U.y_animation_play(this,"death",nil,store.tick_ts,1)
break
else
U.animation_start(this,"tap",nil,store.tick_ts,false,1)
end
end
if eat_cd<store.tick_ts-eat_ts then
eat_cd=fts(math.random(3*FPS,7*FPS))
eat_ts=store.tick_ts
U.animation_start(this,"eat",nil,store.tick_ts,false,1)
end
if this.render.sprites[1].name=="tap" and U.animation_finished(this) then
U.animation_start(this,"idle",nil,store.tick_ts,false,1)
end
if this.render.sprites[1].name=="eat" and U.animation_finished(this) then
U.animation_start(this,"idle",nil,store.tick_ts,true,1)
end
coroutine.yield()
end
queue_remove(store,this)
end
local tt=E:register_t_hot("decal_stage_214_mask_1","decal",true)
tt.render.sprites[1].name="stage214_mask_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_214_mask_2","decal",true)
tt.render.sprites[1].name="stage214_mask_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,-147)
tt=E:register_t_hot("decal_stage_214_mask_3","decal",true)
tt.render.sprites[1].name="stage214_mask_3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,-77)
tt=E:register_t_hot("decal_stage_214_mask_4","decal",true)
tt.render.sprites[1].name="stage214_mask_4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,-45)
tt.render.sprites[1].sort_y_offset=0
tt=E:register_t_hot("decal_stage_214_mask_5","decal",true)
tt.render.sprites[1].name="stage214_mask_5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_214_mask_6","decal",true)
tt.render.sprites[1].name="stage214_mask_6"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(0,300)
tt=E:register_t_hot("decal_stage_214_mask_7","decal",true)
tt.render.sprites[1].name="stage214_mask_7"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_214_mask_8","decal",true)
tt.render.sprites[1].name="stage214_mask_8"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_214_mask_10","decal",true)
tt.render.sprites[1].name="stage214_mask_10"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].sort_y_offset=20
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_214_mask11","decal",true)
tt.render.sprites[1].name="stage214_mask_11"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS-1
tt=E:register_t_hot("decal_stage_214_mask12","decal",true)
tt.render.sprites[1].name="stage214_mask_12"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS+1
tt=E:register_t_hot("decal_stage_214_smoke","decal",true)
tt.render.sprites[1].prefix="s214_smokeDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].hidden=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_214_house","decal",true)
tt.render.sprites[1].name="stage214_mask_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_graveyard_stage_214","decal",true)
tt.render.sprites[1].animated=true
tt.render.sprites[1].prefix="stage214_graveyardDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_214_blacksmith","decal",true)
tt.render.sprites[1].prefix="stage214_blacksmithDef"
tt.render.sprites[1].name="broken"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].hidden=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_214_blacksmith_alert","decal_tween",true)
tt.render.sprites[1].prefix="stage214_blacksmith_alertDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].alpha=0
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.tween.props[1].keys={{0,0},{fts(8),255}}
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_214_armory","decal",true)
tt.render.sprites[1].prefix="stage214_barracksDef"
tt.render.sprites[1].name="broken"
tt.render.sprites[1].sort_y_offset=-21
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].hidden=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_214_armory_alert","decal_tween",true)
tt.render.sprites[1].prefix="stage214_barracks_alertDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].alpha=0
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.tween.props[1].keys={{0,0},{fts(8),255}}
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_214_goat_skeleton","decal_scripted",true)
AC(tt,"ui","vis","health","editor")
tt.render.sprites[1].exo=false
tt.render.sprites[1].prefix="stage_214_goat"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.sound="Stage15GoatExplosion"
tt.taps_to_explode=5
tt.ui.click_rect=r(-15,-5,30,25)
tt.main_script.update=stage_214_goat_graveyard_update
tt.health.dead=false
tt.health.hp_max=1
tt.vis.flags=bor(F_ENEMY)
tt.vis.bans=0
tt=E:register_t_hot("decal_easter_egg_stage_214_delorean","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="deloreanDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=easter_egg_stage_214_delorean_update
tt.sound_turn_on="Stage14DeloreanTurnOn"
tt.sound_power_down="Stage14DeloreanPowerDown"
tt.ui.click_rect=r(-320,255,100,100)
tt=E:register_t_hot("decal_easter_egg_stage_214_goat_fall","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="goatfall_goat"
tt.render.sprites[1].name="idle"
tt.main_script.update=easter_egg_stage_214_goat_fall_update
tt.sound_tap={"Stage14CeilingGoatTap1","Stage14CeilingGoatTap2"}
tt.sound_tap_frames={21,0}
tt.ui.click_rect=r(-313,-55,30,30)
tt=E:register_t_hot("controller_graveyard_stage_214","controller_graveyard_kr6",true)
tt.associated_decal="decal_graveyard_stage_214"
tt.animation_cooldown=fts(76)+3
tt.animation="glow"
tt.graveyard.dead_time=1
tt.graveyard.check_interval=0.25
tt.graveyard.spawn_interval=1
tt.graveyard.spawns_by_health={{"enemy_skeleton_goat",2},{"enemy_skeleton_kr6",599},{"enemy_skeleton_big_kr6",1e+99}}
tt=E:register_t_hot("controller_stage_214_community_building_achievement",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_214_community_building_achievement_update
tt=E:register_t_hot("controller_stage_214_houses",nil,true)
AC(tt,"main_script","events")
tt.main_script.update=controller_stage_214_houses_update
tt.bush_t="decal_stage_214_house"
tt.cont_t="controller_stage_214_house_spawner"
tt.path_id=5
tt.events.list[1].name="house"
tt.events.list[1].on_event=controller_stage_214_houses_on_event
tt=E:register_t_hot("controller_stage_214_house_spawner",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_214_house_spawner_update
tt.enemy_t="enemy_exalted_shadow_blades"
tt.spawn_delay=5
tt.delay_between=1
tt.sound_rustle="Stage07BushBladesSpawnMov"
tt.sound_exit="Stage07BushBladesSpawn"
tt=E:register_t_hot("soldier_stage_214_armory_lvl1","soldier_militia",true)
AC(tt,"nav_grid","powers")
tt.info.portrait="kr6_info_portraits_soldiers_0059"
tt.info.random_name_count=8
tt.info.random_name_format="SOLDIER_STAGE_214_ARMORY_%i_NAME"
tt.info.i18n_key="SOLDIER_STAGE_214_ARMORY"
tt.render.sprites[1].prefix="stage214_soldier_var1"
tt.render.sprites[1].anchor=v(0.5,0.5)
tt.render.sprites[1].angles.walk={"walk"}
tt.unit.hit_offset=v(0,12)
tt.unit.marker_offset=v(0,0)
tt.unit.mod_offset=v(0,13)
tt.health_bar.offset=v(0,30)
tt.health.dead_lifetime=16
tt.health.hp_max=100
tt.health.armor=0.1
tt.regen.health=8
tt.vis.flags=bor(F_BLOCK,F_FRIEND)
tt.motion.max_speed=60
tt.melee.range=65
tt.melee.attacks[1].cooldown=1
tt.melee.attacks[1].damage_min=4
tt.melee.attacks[1].damage_max=6
tt.melee.attacks[1].hit_time=fts(10)
tt.soldier.melee_slot_offset=v(4,0)
tt.ui.click_rect=r(-13,-2,26,25)
tt=E:register_t_hot("soldier_stage_214_armory_lvl2","soldier_stage_214_armory_lvl1",true)
tt.info.portrait="kr6_info_portraits_soldiers_0058"
tt.render.sprites[1].prefix="stage214_soldier_var2"
tt.health.hp_max=180
tt.health.armor=0.2
tt.health_bar.offset=v(0,40)
tt.regen.health=14
tt.motion.max_speed=60
tt.melee.range=65
tt.melee.attacks[1].cooldown=1
tt.melee.attacks[1].damage_min=6
tt.melee.attacks[1].damage_max=10
tt.melee.attacks[1].type="area"
tt.melee.attacks[1].damage_radius=50
tt.melee.attacks[1].damage_bans=bor(F_FLYING)
tt.melee.attacks[1].damage_flags=0
tt=E:register_t_hot("mod_stage_214_blacksmith_visuals_units","modifier",true)
AC(tt,"render","tween")
tt.render.sprites[1].prefix="stage214_blacksmithauraDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].offset=v(0,0)
tt.render.sprites[1].scale=vv(0.7)
tt.tween.props[1].keys={{0,0},{fts(10),255}}
tt.tween.props[1].name="alpha"
tt.tween.remove=false
tt.tween.reverse=false
tt.tween.run_once=true
tt.modifier.duration=0.6
tt.modifier.use_mod_offset=false
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.main_script.update=scripts.mod_track_target.update
tt=E:register_t_hot("mod_stage_214_blacksmith_damage_units_lvl1","modifier",true)
tt.modifier.duration=0.6
tt.modifier.use_mod_offset=false
tt.inflicted_damage_factor=1.1
tt.main_script.insert=scripts.mod_damage_factors.insert
tt.main_script.update=scripts.mod_track_target.update
tt.main_script.remove=scripts.mod_damage_factors.remove
tt=E:register_t_hot("mod_stage_214_blacksmith_damage_units_lvl2","mod_stage_214_blacksmith_damage_units_lvl1",true)
tt.inflicted_damage_factor=1.2
tt=E:register_t_hot("mod_stage_214_blacksmith_damage_units_lvl3","mod_stage_214_blacksmith_damage_units_lvl1",true)
tt.inflicted_damage_factor=1.35
tt=E:register_t_hot("mod_stage_214_blacksmith_armor_units_lvl1","modifier",true)
AC(tt,"armor_buff")
tt.modifier.duration=0.6
tt.armor_buff.max_factor=0.1
tt.armor_buff.cycle_time=1e+99
tt.main_script.insert=scripts.mod_armor_buff.insert
tt.main_script.update=scripts.mod_track_target.update
tt.main_script.remove=scripts.mod_armor_buff.remove
tt=E:register_t_hot("mod_stage_214_blacksmith_armor_units_lvl2","mod_stage_214_blacksmith_armor_units_lvl1",true)
tt.armor_buff.max_factor=0.2
tt=E:register_t_hot("mod_stage_214_blacksmith_armor_units_lvl3","mod_stage_214_blacksmith_armor_units_lvl1",true)
tt.armor_buff.max_factor=0.35
tt=E:register_t_hot("aura_stage_214_blacksmith_units_lvl1","aura",true)
tt.aura.mods={"mod_stage_214_blacksmith_damage_units_lvl1","mod_stage_214_blacksmith_armor_units_lvl1","mod_stage_214_blacksmith_visuals_units"}
tt.aura.radius=250
tt.aura.vis_flags=bor(F_AREA,F_FRIEND)
tt.aura.vis_bans=bor(F_ENEMY)
tt.aura.cycle_time=0.5
tt.aura.duration=1e+99
tt.main_script.insert=scripts.aura_apply_mod.insert
tt.main_script.update=scripts.aura_apply_mod.update
tt=E:register_t_hot("aura_stage_214_blacksmith_units_lvl2","aura_stage_214_blacksmith_units_lvl1",true)
tt.aura.mods={"mod_stage_214_blacksmith_damage_units_lvl2","mod_stage_214_blacksmith_armor_units_lvl2","mod_stage_214_blacksmith_visuals_units"}
tt=E:register_t_hot("aura_stage_214_blacksmith_units_lvl3","aura_stage_214_blacksmith_units_lvl1",true)
tt.aura.mods={"mod_stage_214_blacksmith_damage_units_lvl3","mod_stage_214_blacksmith_armor_units_lvl3","mod_stage_214_blacksmith_visuals_units"}
tt=E:register_t_hot("tower_stage_214_blacksmith","tower",true)
AC(tt,"attacks","vis","powers","user_selection")
tt.render=nil
tt.tower.type="stage_214_blacksmith"
tt.tower.menu_offset=v(0,45)
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.disable_spend_highlight=true
tt.tower.can_hover=false
tt.tower.terrain_style=TERRAIN_STYLE_KR6_TERRAIN_3_1
tt.powers.skill_a=E:clone_c("power")
tt.powers.skill_a.price_base=150
tt.powers.skill_a.price_inc=150
tt.powers.skill_a.max_level=3
tt.decal="decal_stage_214_blacksmith"
tt.alert="decal_stage_214_blacksmith_alert"
tt.achievement_tracker="controller_stage_214_community_building_achievement"
tt.info.fn=scripts.tower_barrack_mercenaries.get_info
tt.info.portrait="kr6_info_portraits_towers_0033"
tt.main_script.update=tower_stage_214_blacksmith_update
tt.aura="aura_stage_214_blacksmith_units_lvl"
tt.aura_offset=v(0,10)
tt.attacks.range=250
tt.towers_to_start_effect=3
tt.ui.click_rect=r(-68,0,130,120)
tt.ui.hover_sprite_scale=vv(1.3)
tt.ui.hover_sprite_offset=v(0,40)
tt.ui.hover_sprite_name="default"
tt.vis.bans=F_ALL
tt.repair_sound="Stage14BuildingRepaired"
tt.repair_taunt="Stage14BlacksmithBuildTaunt"
tt.upgrade_taunt="Stage14BlacksmithUpgradeTaunt"
tt.aura_sound="Stage14BlacksmithWork"
tt.bubble_cd=30
tt.loop_bubble_time=4
tt=E:register_t_hot("tower_stage_214_armory","tower",true)
AC(tt,"vis","barrack","powers","user_selection")
tt.render=nil
tt.tower.terrain_style=TERRAIN_STYLE_KR6_TERRAIN_3_1
tt.tower.type="stage_214_armory"
tt.tower.level=1
tt.tower.menu_offset=v(0,20)
tt.tower.price=200
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.disable_spend_highlight=true
tt.tower.can_hover=false
tt.tower.blocked=true
tt.powers.skill_a=E:clone_c("power")
tt.powers.skill_a.price_base=150
tt.powers.skill_a.price_inc=150
tt.powers.skill_a.max_level=1
tt.powers.skill_a.soldier_type="soldier_stage_214_armory_lvl2"
tt.powers.skill_b=E:clone_c("power")
tt.powers.skill_b.price_base=100
tt.powers.skill_b.price_inc=100
tt.powers.skill_b.max_level=3
tt.powers.skill_b.respawn_times={14,12,10}
tt.repair={cost=200,active=nil,sound="Stage14BuildingRepaired"}
tt.info.portrait="kr6_info_portraits_towers_0032"
tt.info.fn=scripts.tower_barrack.get_info
tt.main_script.insert=scripts.tower_barrack.insert
tt.main_script.update=tower_stage_214_armory_update
tt.decal="decal_stage_214_armory"
tt.alert="decal_stage_214_armory_alert"
tt.mask="decal_stage_214_mask_10"
tt.achievement_tracker="controller_stage_214_community_building_achievement"
tt.barrack.rally_range=200
tt.barrack.respawn_offset=v(0,9)
tt.barrack.has_door=false
tt.barrack.soldier_type="soldier_stage_214_armory_lvl1"
tt.first_rally_offset=v(-67,-12)
tt.ui.click_rect=r(-65,-20,130,120)
tt.ui.force_can_select=true
tt.ui.hover_sprite_scale=vv(1.7)
tt.ui.hover_sprite_offset=v(0,15)
tt.ui.hover_sprite_name="default"
tt.vis.bans=F_ALL
tt.sound_events.change_rally_point="Stage14ArmoryMoveTaunt"
tt.repair_sound="Stage14BuildingRepaired"
tt.repair_taunt="Stage14ArmoryBuildTaunt"
tt.bubble_cd=30
tt.loop_bubble_time=4
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
