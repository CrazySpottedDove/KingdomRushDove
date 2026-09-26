local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
local V=require("lib.klua.vector")
local signal=require("lib.hump.signal")
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
local function tpos(e)
return e.tower and e.tower.range_offset and v(e.pos.x+e.tower.range_offset.x,e.pos.y+e.tower.range_offset.y) or e.pos
end
local function crane_can_select_point(this,x,y)
return P:valid_node_nearby(x,y)
end
local function crane_update(this,store)
local ab=this.attacks.list[1]
local times_repaired=0
local bubble_ts=store.tick_ts
local tap_bubble_cd=5
local explosion_c
for _,v in pairs(store.entities) do
if v.template_name=="controller_stage_204_wall_explosion" then
explosion_c=v
end
end
U.animation_start(this,"idle_1",false,store.tick_ts,true)
this.bubble=E:create_entity(this.bubble_t)
this.bubble.pos=V.vclone(this.pos)
this.bubble.render.sprites[1].alpha=0
queue_insert(store,this.bubble)
local function activate()
this.repair.active=true
times_repaired=times_repaired+1
S:queue(this.repair.sound,{delay=fts(20)})
U.y_animation_play(this,"reload",false,store.tick_ts)
U.animation_start(this,"idle_2",false,store.tick_ts,true)
ab.disabled=false
end
local function find_target(aa)
local target,_,pred_pos=U.find_foremost_enemy(store,tpos(this),0,this.attacks.range,aa.node_prediction,aa.vis_flags,aa.vis_bans)
return target, pred_pos
end
while true do
if store.wave_group_number>0 and tap_bubble_cd<store.tick_ts-bubble_ts and this.bubble.render.sprites[1].alpha<=0 and not explosion_c.trigger_explosion and store.player_gold>=this.repair.cost then
this.bubble.render.sprites[1].ts=store.tick_ts
this.bubble.tween.ts=store.tick_ts
this.bubble.tween.reverse=false
this.bubble.tween.disabled=false
bubble_ts=store.tick_ts
end
if not this.repair.active then
elseif not ab.disabled then
local enemy,pred_pos=find_target(ab)
if not enemy then
else
local enemy_id=enemy.id
local enemy_pos=V.vclone(enemy.pos)
S:queue(ab.sound)
U.animation_start(this,ab.animation,nil,store.tick_ts,false)
U.y_wait(store,ab.shoot_time)
local start_offset=ab.bullet_start_offset
enemy,pred_pos=find_target(ab)
local b=E:create_entity(ab.bullet)
b.bullet.damage_factor=this.tower.damage_factor
b.pos.x,b.pos.y=this.pos.x+start_offset.x,this.pos.y+start_offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=enemy and pred_pos or enemy_pos
local nearest=P:nearest_nodes(b.bullet.to.x,b.bullet.to.y,nil,{1},true)[1]
local pi,spi,ni=unpack(nearest)
b.bullet.to=P:node_pos(pi,spi,ni)
b.bullet.source_id=this.id
queue_insert(store,b)
U.y_animation_wait(this)
U.animation_start(this,"idle_1",nil,store.tick_ts,true)
this.repair.active=false
this.user_selection.allowed=true
ab.disabled=true
end
end
if not this.bubble.tween.reverse and (this.user_selection.menu_shown or this.bubble.render.sprites[1].alpha>0 and store.tick_ts-bubble_ts>5) then
this.bubble.tween.ts=store.tick_ts
this.bubble.tween.reverse=true
bubble_ts=store.tick_ts
tap_bubble_cd=this.user_selection.menu_shown and 30 or 10
end
if this.user_selection.in_progress and not this.repair.active then
this.user_selection.in_progress=nil
this.user_selection.allowed=false
store.player_gold=store.player_gold-this.repair.cost
activate()
end
coroutine.yield()
end
end
local function crane_remove(this,store,script)
queue_remove(store,this.bubble)
return true
end
local function wall_controller_update(this,store)
local mask1,mask3,mask4,crane
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_204_mask_1" then
mask1=v
end
if v.template_name=="decal_stage_204_mask_3" then
mask3=v
end
if v.template_name=="decal_stage_204_mask_4" then
mask4=v
end
if v.template_name=="tower_stage_204_crane" then
crane=v
end
end
while not this.trigger_explosion do
coroutine.yield()
end
crane.bubble.tween.disabled=true
crane.bubble.render.sprites[1].alpha=0
local decal_explotion=E:create_entity("decal_stage_204_wall_explosion")
decal_explotion.pos=V.v(512,384)
queue_insert(store,decal_explotion)
U.animation_start(decal_explotion,"start",nil,store.tick_ts,false)
U.y_wait(store,fts(275))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.4
shake.aura.duration=2
shake.aura.freq_factor=4
queue_insert(store,shake)
U.y_wait(store,fts(15))
mask1.render.sprites[1].z=Z_OBJECTS_COVERS
queue_remove(store,mask3)
local holder_crane=E:create_entity("tower_holder_blocked_terrain_1_3")
holder_crane.ui.can_click=true
holder_crane.tower.can_hover=true
holder_crane.tower.default_rally_pos=V.vclone(crane.tower.default_rally_pos)
holder_crane.tower.holder_id=crane.tower.holder_id
holder_crane.ui.nav_mesh_id=crane.ui.nav_mesh_id
holder_crane.pos=V.vclone(crane.pos)
queue_insert(store,holder_crane)
crane.trigger_deselect=true
queue_remove(store,crane)
U.y_wait(store,fts(5))
queue_remove(store,mask4)
P:activate_path(3)
for k,v in pairs(store.level.ignore_walk_backwards_paths) do
if v==3 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
signal.emit("wall_explosion_end")
U.y_animation_wait(decal_explotion)
U.animation_start(decal_explotion,"idle",nil,store.tick_ts,true)
end
local function wall_controller_on_event(this,store)
this.trigger_explosion=true
end
local function wall_explosion_update(this,store)
U.y_wait(store,fts(23))
S:queue(this.sound_wall)
U.y_wait(store,fts(28))
S:queue(this.sound_wall)
U.y_wait(store,fts(28))
S:queue(this.sound_wall)
U.y_wait(store,fts(31))
S:queue(this.sound_fling)
U.y_wait(store,fts(3))
S:queue(this.sound_wall)
U.y_wait(store,fts(161))
S:queue(this.sound_explosion)
end
local function minecraft_on_appear(this,store)
this._looping_on_top=false
end
local function minecraft_insert(this,store)
this._looping_on_top=true
return true
end
local function minecraft_update(this,store)
local function loop_then_wait(animation,wait,break_fn)
U.animation_start(this,animation,nil,store.tick_ts,1)
while not U.animation_finished(this,1,1) do
if break_fn and break_fn(store,wait) then
break
end
coroutine.yield()
end
U.y_wait(store,wait,break_fn)
end
while this._looping_on_top do
coroutine.yield()
S:queue(this.sound_lap)
loop_then_wait("first_pass",this.first_loop_wait)
end
U.y_animation_wait(this,1,this.render.sprites[1].runs+1)
S:queue(this.sound_lap)
U.y_animation_play(this,"second_pass",nil,store.tick_ts,1)
local taps=1
local ever_clicked=false
this.ui.clicked=nil
while taps<4 do
coroutine.yield()
if not ever_clicked then
loop_then_wait("stuck_loop",this.first_loop_wait,function(s,t)
return ever_clicked or this.ui.clicked
end)
end
if this.ui.clicked then
ever_clicked=true
this.ui.clicked=nil
taps=taps+1
if taps==4 then
U.animation_start(this,"tap_"..taps-1,nil,store.tick_ts,1)
S:queue(this.sound_last_tap)
U.y_wait(store,this.wait_creeper_loop)
S:queue(this.sound_lap)
U.y_wait(store,this.wait_crash)
S:queue(this.sound_crash)
U.y_animation_wait(this)
signal.emit("off-the-rails-stage04")
else
S:queue(this.sound_tap)
U.y_animation_play(this,"tap_"..taps-1,nil,store.tick_ts,1)
end
if taps~=4 then
U.animation_start(this,"idle_"..taps,nil,store.tick_ts,-1)
end
end
end
queue_remove(store,this)
end
local mask_z={Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS}
for i=1,4 do
local tt=E:register_t_hot("decal_stage_204_mask_"..i,"decal",true)
tt.render.sprites[1].name=string.format("kr6_stage_204_mask_%02d",i)
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=mask_z[i]
if i==3 or i==4 then
AC(tt,"editor")
end
end
for i=1,12 do
local tt=E:register_t_hot("decal_stage_204_mask_water_"..i,"decal",true)
tt.render.sprites[1].name=string.format("kr6_stage_204_mask_water_%04d",i)
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
end
local tt=E:register_t_hot("decal_stage_204_water_1","decal",true)
tt.render.sprites[1].prefix="stage_204_water_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt=E:register_t_hot("decal_stage_204_water_2","decal",true)
tt.render.sprites[1].prefix="stage_204_water_2Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt=E:register_t_hot("decal_stage_204_wall_explosion","decal_scripted",true)
tt.render.sprites[1].prefix="GobliExplosionDef"
tt.render.sprites[1].name="start"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.main_script.update=wall_explosion_update
tt.sound_wall="Stage04WallExplosionPart1"
tt.sound_fling="Stage04WallExplosionPart2"
tt.sound_explosion="Stage04WallExplosionPart3"
tt=E:register_t_hot("decal_stage_204_crane_bubble","decal_tween",true)
tt.render.sprites[1].prefix="CraneSpeechBubbleDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.tween.props[1].keys={{0,0},{fts(8),255}}
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_204_minecraft","decal_scripted",true)
AC(tt,"ui","events")
tt.render.sprites[1].prefix="stage_204_easteregg_minecraftDef"
tt.render.sprites[1].name="first_pass"
tt.render.sprites[1].exo=true
tt.main_script.insert=minecraft_insert
tt.main_script.update=minecraft_update
tt.first_loop_wait=30
tt.wait_crash=fts(56)
tt.wait_creeper_loop=fts(59)
tt.sound_tap="Stage04MinecraftTap12"
tt.sound_last_tap="Stage04MinecraftTap3"
tt.sound_lap="Stage04MinecraftLap"
tt.sound_crash="Stage04MinecraftCrashExplosion"
tt.events.list[1].name="stage04-minecraft-easteregg"
tt.events.list[1].on_event=minecraft_on_appear
tt.ui.click_rect=r(587,180,60,60)
tt=E:register_t_hot("decal_stage_204_crane_shadow","decal",true)
tt.render.sprites[1].name="kr6stage4_crane_shadow_crane_projectile_shadow"
tt.render.sprites[1].animated=false
tt.render.sprites[1].offset=vv(0)
tt=E:register_t_hot("decal_stage_204_crane_hit","decal_timed",true)
tt.render.sprites[1].prefix="CraneProjectileFXDecalDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.timed.runs=1
tt=E:register_t_hot("fx_stage_204_crane","fx",true)
tt.render.sprites[1].prefix="CraneProjectileFXDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("bullet_stage_204_crane","bomb",true)
tt.main_script.insert=scripts.bomb.insert
tt.main_script.update=scripts.bomb.update
tt.bullet.damage_min=60
tt.bullet.damage_max=120
tt.bullet.damage_radius=60
tt.bullet.damage_type=DAMAGE_EXPLOSION
tt.bullet.flight_time=fts(40)
tt.bullet.hit_fx="fx_stage_204_crane"
tt.bullet.hit_decal="decal_stage_204_crane_hit"
tt.bullet.pop_chance=0.5
tt.bullet.align_with_trajectory=false
tt.bullet.rotation_speed=10
tt.sound_events.hit_water=nil
tt.sound_events.hit="Stage04DwarvenCraneBasicAttackImpact"
tt.sound_events.insert=nil
tt.render.sprites[1].prefix="CraneProjectileDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt=E:register_t_hot("controller_stage_204_wall_explosion",nil,true)
AC(tt,"main_script","pos","events")
tt.main_script.update=wall_controller_update
tt.events.list[1].name="wall_explosion"
tt.events.list[1].on_event=wall_controller_on_event
tt=E:register_t_hot("tower_stage_204_crane","tower",true)
AC(tt,"user_selection","attacks")
tt.tower.type="stage_204_crane"
tt.tower.menu_offset=v(0,75)
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.can_hover=false
tt.info.portrait="kr6_info_portraits_towers_0006"
tt.render.sprites[1].prefix="CraneDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS
tt.user_selection.can_select_point_fn=crane_can_select_point
tt.main_script.update=crane_update
tt.main_script.remove=crane_remove
tt.attacks.range=1400
tt.attacks.list[1]=E:clone_c("bullet_attack")
tt.attacks.list[1].animation="attack"
tt.attacks.list[1].shoot_time=fts(19)
tt.attacks.list[1].bullet="bullet_stage_204_crane"
tt.attacks.list[1].bullet_start_offset=v(110,60)
tt.attacks.list[1].node_prediction=fts(10)
tt.attacks.list[1].sound="Stage04DwarvenCraneBasicAttack"
tt.attacks.list[1].vis_bans=bor(F_FLYING)
tt.repair={}
tt.repair.cost=30
tt.repair.active=nil
tt.repair.sound="Stage04DwarvenCraneActivation"
tt.bubble_t="decal_stage_204_crane_bubble"
tt.ui.click_rect=r(-50,-20,100,150)
tt.ui.hover_sprite_scale=vv(1.4)
tt.ui.hover_sprite_offset=v(0,-8)
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
