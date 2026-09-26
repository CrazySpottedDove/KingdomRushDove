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
local r=V.r
local v=V.v
local vv=V.vv
local function CC(comp_name)
return E:clone_c(comp_name)
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function RT(name,ref)
return E:register_t(name,ref)
end
local signal=require("lib.hump.signal")
local function fts(t)
return t/30
end
local tt=E:register_t_hot("decal_stage_201_king","decal_scripted",true)
AC(tt,"attacks","editor")
tt.render.sprites[1].prefix="stage_201_old_kingDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].hidden=true
tt.king_offset=v(-309,135)
tt.balcony_height=135
tt.main_script.update=function(this,store)
while store.level_mode==GAME_MODE_CAMPAIGN and store.wave_group_number<1 do
coroutine.yield()
end
this.render.sprites[1].hidden=false
U.y_animation_play(this,"entrance",nil,store.tick_ts,1,1)
U.animation_start(this,"idle",nil,store.tick_ts,1,1)
local aa=this.attacks.list[1]
local min_range=this.attacks.min_range
local max_range=this.attacks.max_range
while true do
coroutine.yield()
if store.tick_ts-aa.ts>aa.cooldown then
local k_pos=V.v(this.pos.x+this.king_offset.x,this.pos.y+this.king_offset.y)
local k_pos_ground=V.v(k_pos.x,k_pos.y-this.balcony_height)
local trigger_enemy,_=U.find_foremost_enemy(store.entities,k_pos_ground,min_range,max_range,false,aa.vis_flags,aa.vis_bans)
if not trigger_enemy then
SU.delay_attack(store,aa,fts(10))
else
local fb=aa.bullet
local roll=math.random()
if roll<aa.bullet_chances[1] then
fb=fb.."_anvil"
U.animation_start(this,"attack_1",nil,store.tick_ts,false)
elseif roll<aa.bullet_chances[1]+aa.bullet_chances[2] then
fb=fb.."_bust"
U.animation_start(this,"attack_2",nil,store.tick_ts,false)
elseif roll<aa.bullet_chances[1]+aa.bullet_chances[2]+aa.bullet_chances[3] then
fb=fb.."_sheep"
U.animation_start(this,"attack_3",nil,store.tick_ts,false)
end
aa.ts=store.tick_ts
U.y_wait(store,aa.shoot_time)
local enemy,_=U.find_foremost_enemy(store.entities,k_pos_ground,min_range,max_range,false,aa.vis_flags,aa.vis_bans)
enemy=enemy or trigger_enemy
local enp=enemy.nav_path
local to_pos=P:node_pos(enp.pi,1,enp.ni)
local b=E:create_entity(fb)
b.pos.x,b.pos.y=k_pos.x+aa.bullet_start_offset.x,k_pos.y+aa.bullet_start_offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=V.vclone(to_pos)
b.bullet.source_id=this.id
simulation:queue_insert_entity(b)
S:queue(this.sound_attack)
U.y_wait(store,this.wait_laugh)
S:queue(this.sound_laugh)
U.y_animation_wait(this,1)
end
end
end
end
tt.attacks.min_range=130
tt.attacks.max_range=150
tt.attacks.list[1]=CC("bullet_attack")
tt.attacks.list[1].bullet="bullet_stage_201_king"
tt.attacks.list[1].cooldown=2
tt.attacks.list[1].shoot_time=fts(37)
tt.attacks.list[1].bullet_start_offset=v(7,38)
tt.attacks.list[1].basic_attack=true
tt.attacks.list[1].bullet_chances={0.3,0.6,0.1}
tt.wait_laugh=fts(29)
tt.sound_attack="Stage01OldKingGibberishThrow"
tt.sound_laugh="Stage01OldKingGibberishLaugh"
tt=E:register_t_hot("bullet_stage_201_king_anvil","bomb",true)
tt.bullet.damage_decay_random=false
tt.bullet.damage_type=DAMAGE_EXPLOSION
tt.bullet.hit_decal="decal_bomb_crater_KR5"
tt.decal_shadow=nil
AC(tt,"tween")
tt.bullet.damage_min=80
tt.bullet.damage_max=120
tt.bullet.damage_radius=50
tt.bullet.flight_time=fts(15)
tt.bullet.hit_fx="fx_stage_201_anvil_hit"
tt.bullet.hit_decal="decal_stage_201_anvil_bust_hit"
tt.bullet.pop_chance=-2.5
tt.bullet.g=-2.5/(fts(1)*fts(1))
tt.bullet.align_with_trajectory=false
tt.bullet.rotation_speed=0
tt.bullet.starting_rotation=0
tt.main_script.insert=scripts.bomb_kr6.insert
tt.main_script.update=scripts.bomb_kr6.update
tt.sound_events.hit_water=nil
tt.sound_events.insert=nil
tt.render.sprites[1].name="Stage_1_old_king_projectiles_pojectile_anvil"
tt.render.sprites[1].animated=false
tt.render.sprites[1].scale=vv(1)
tt.tween.props[1].name="scale"
tt.tween.props[1].keys={{0,v(1,1)},{fts(5),v(1,1)},{fts(15),v(0.8,1.4)}}
tt=E:register_t_hot("bullet_stage_201_king_bust","bullet_stage_201_king_anvil",true)
tt.bullet.hit_fx="fx_stage_201_bust_hit"
tt.render.sprites[1].name="Stage_1_old_king_projectiles_pojectile_bust"
tt=E:register_t_hot("bullet_stage_201_king_sheep","bullet_stage_201_king_anvil",true)
tt.bullet.hit_fx="fx_stage_201_sheep_hit"
tt.bullet.hit_decal="decal_stage_201_sheep_hit"
tt.render.sprites[1].prefix="Stage_1_old_king_projectiles_pojectile_sheep"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt=E:register_t_hot("fx_stage_201_anvil_hit","fx",true)
tt.render.sprites[1].prefix="Stage_1_old_king_projectiles_anvil_break_fx"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_OBJECTS-1
tt=E:register_t_hot("fx_stage_201_bust_hit","fx",true)
tt.render.sprites[1].prefix="Stage_1_old_king_projectiles_bust_break_fx"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_OBJECTS-1
tt=E:register_t_hot("fx_stage_201_sheep_hit","fx",true)
tt.render.sprites[1].prefix="Stage_1_old_king_projectiles_sheep_break_fx"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_OBJECTS-1
tt=E:register_t_hot("bullet_stage_201_king","bullet_stage_201_king_anvil",true)
tt=E:register_t_hot("decal_stage_201_anvil_bust_hit","decal_tween",true)
E:add_comps(tt,"main_script")
tt.render.sprites[1].prefix="Stage_1_old_king_projectiles_explosion_fx_a_decal"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="Stage_1_old_king_projectiles_explosion_fx_a"
tt.render.sprites[2].name="run"
tt.render.sprites[2].animated=true
tt.render.sprites[2].loop=false
tt.render.sprites[2].z=Z_OBJECTS
tt.tween.props[1].name="alpha"
tt.tween.props[1].keys={{0,255},{1.5,255},{2.5,0}}
local tt=E:register_t_hot("decal_stage_201_cow","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="stage201_cowDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS-1
tt.sound_discover="Stage01CowSpiesReveal"
tt.ui.click_rect=r(556,255,41,30)
tt.main_script.update=function(this,store,script)
local taps_count=0
while taps_count<3 do
if this.ui.clicked then
taps_count=taps_count+1
U.y_animation_play(this,"tap",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,1)
this.ui.clicked=nil
end
coroutine.yield()
end
S:queue(this.sound_discover)
U.y_animation_play(this,"action",nil,store.tick_ts,1)
signal.emit("cow-ard-spies-stage01")
simulation:queue_remove_entity(this)
end
local tt=E:register_t_hot("decal_stage_201_hp_mask_1","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="KR6_stage_201_iron_mask1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
local tt=E:register_t_hot("decal_stage_201_mask_1","decal",true)
tt.render.sprites[1].name="KR6_stage_201_mask1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
local tt=E:register_t_hot("decal_stage_201_mask_2","decal",true)
tt.render.sprites[1].name="KR6_stage_201_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
local tt=E:register_t_hot("decal_stage_201_mask_3","decal",true)
tt.render.sprites[1].name="KR6_stage_201_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
local tt=E:register_t_hot("decal_stage_201_mask_4","decal",true)
tt.render.sprites[1].name="KR6_stage_201_mask4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
local tt=E:register_t_hot("decal_stage_201_merchant","decal_scripted",true)
tt.render.sprites[1].prefix="stage_201_merchantDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS-1
tt.broken_cart=false
tt.main_script.update=function(this,store,script)
local idle_ts=store.tick_ts
local idle_cd=fts(math.random(2,4)*FPS)
local idle=1
while not this.broken_cart do
if idle_cd<store.tick_ts-idle_ts then
idle_cd=fts(math.random(2,4)*FPS)
idle_ts=store.tick_ts
idle=idle==1 and 2 or 1
U.animation_start(this,"idle_"..idle,nil,store.tick_ts,false)
end
coroutine.yield()
end
U.animation_start(this,"action",nil,store.tick_ts)
U.y_wait(store,2)
signal.emit("my-cabbages-stage01")
U.y_animation_wait(this)
end
local tt=E:register_t_hot("decal_stage_201_sheep","decal_scripted",true)
E:add_comps(tt,"ui","editor","editor_script")
tt.render.sprites[1].prefix="stage_201_sheepDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.main_script.insert=scripts.decal_terrain_1_sheep.insert
tt.main_script.update=scripts.decal_terrain_1_sheep.update
tt.editor_script.update=scripts.decal_terrain_1_sheep.update_editor
tt.sound="Stage03SheepExplosion"
tt.taps_to_explode=5
tt.ui.click_rect=r(-15,-5,30,25)
tt.editor.flip=0
tt.editor.props={{"editor.flip",PT_NUMBER}}
local tt=E:register_t_hot("decal_stage_201_sheep_hit","decal_tween",true)
E:add_comps(tt,"main_script")
tt.render.sprites[1].name="Stage_1_old_king_projectiles_explosion_fx_b_decal"
tt.render.sprites[1].animated=false
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="Stage_1_old_king_projectiles_explosion_fx_b_floor"
tt.render.sprites[2].name="run"
tt.render.sprites[2].animated=true
tt.render.sprites[2].loop=false
tt.render.sprites[2].z=Z_DECALS+1
tt.render.sprites[3]=E:clone_c("sprite")
tt.render.sprites[3].prefix="Stage_1_old_king_projectiles_explosion_fx_b"
tt.render.sprites[3].name="run"
tt.render.sprites[3].animated=true
tt.render.sprites[3].loop=false
tt.render.sprites[3].z=Z_OBJECTS
tt.tween.props[1].name="alpha"
tt.tween.props[1].keys={{0,255},{1.5,255},{2.5,0}}
local tt=E:register_t_hot("decal_stage_201_sheep_small","decal_stage_201_sheep",true)
tt.render.sprites[1].prefix="stage_201_sheep_smallDef"
tt.ui.click_rect=r(-12.5,-5,25,20)
local tt=E:register_t_hot("decal_stage_201_statue","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="stage201_statueDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.sound_tap="Stage01StatueChange"
tt.worker_t="decal_stage_201_worker_statue"
tt.ui.click_rect=r(125,100,80,110)
tt.main_script.update=function(this,store,script)
local taps_count=0
local w
for _,e in pairs(store.entities) do
if e.template_name==this.worker_t then
w=e
break
end
end
while true do
if this.ui.clicked then
taps_count=taps_count+1
if taps_count>=4 then
taps_count=1
end
local idle=taps_count==3 and "idle" or "idle_"..taps_count
S:queue(this.sound_tap)
U.animation_start(w,taps_count==3 and "action_2" or "action_1",nil,store.tick_ts,1)
U.y_animation_play(this,"tap_"..taps_count,nil,store.tick_ts,1)
U.animation_start(this,idle,nil,store.tick_ts,1)
U.animation_start(w,"idle",nil,store.tick_ts,-1)
this.ui.clicked=nil
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt=E:register_t_hot("decal_stage_201_stone","decal_scripted",true)
E:add_comps(tt,"ui")
tt.render.sprites[1].prefix="stage_201_stoneDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.merchant_t="decal_stage_201_merchant"
tt.injure_worker_t="decal_stage_201_worker_1f"
tt.sound_tap="Stage01ConstructionWorkerTap12"
tt.sound_break="Stage01ConstructionWorkerTap3"
tt.ui.click_rect=r(-358,-104,36,36)
tt.main_script.update=function(this,store,script)
local taps_count=0
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
taps_count=taps_count+1
if taps_count<=2 then
S:queue(this.sound_tap)
U.y_animation_play(this,"action_1",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,true)
this.ui.can_click=true
else
S:queue(this.sound_break)
U.animation_start(this,"action_2",nil,store.tick_ts,false)
for k,v in pairs(store.entities) do
if v.template_name==this.merchant_t then
v.broken_cart=true
break
end
end
U.y_wait(store,fts(7))
for k,v in pairs(store.entities) do
if v.template_name==this.injure_worker_t then
simulation:queue_remove_entity(v)
break
end
end
U.y_animation_wait(this)
U.animation_start(this,"idle_2",nil,store.tick_ts,true)
break
end
end
coroutine.yield()
end
while true do
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt=E:register_t_hot("decal_stage_201_water","decal",true)
tt.render.sprites[1].prefix="stage_201_water_dotsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].random_ts=fts(15)
local tt=E:register_t_hot("decal_stage_201_worker_1","decal",true)
tt.render.sprites[1].prefix="stage201_dude1Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].random_ts=fts(30)
local tt=E:register_t_hot("decal_stage_201_worker_1f","decal_stage_201_worker_1",true)
tt.render.sprites[1].flip_x=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
local tt=E:register_t_hot("decal_stage_201_worker_2","decal_scripted",true)
tt.render.sprites[1].prefix="stage201_dude2Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.random_wait_min=fts(20)
tt.random_wait_max=fts(80)
tt.main_script.update=function(this,store,script)
while true do
U.y_animation_play(this,"run",nil,store.tick_ts,math.random(1,3))
U.animation_start(this,"idle",nil,store.tick_ts,true)
U.y_wait(store,U.frandom(this.random_wait_min,this.random_wait_max))
coroutine.yield()
end
end
local tt=E:register_t_hot("decal_stage_201_worker_2f","decal_stage_201_worker_2",true)
tt.render.sprites[1].flip_x=true
local tt=E:register_t_hot("decal_stage_201_worker_3","decal_stage_201_worker_1",true)
tt.render.sprites[1].prefix="stage201_dude3Def"
tt.render.sprites[1].name="loop"
local tt=E:register_t_hot("decal_stage_201_worker_3f","decal_stage_201_worker_3",true)
tt.render.sprites[1].flip_x=true
local tt=E:register_t_hot("decal_stage_201_worker_4","decal_stage_201_worker_3",true)
tt.render.sprites[1].prefix="stage201_dude4Def"
local tt=E:register_t_hot("decal_stage_201_worker_statue","decal",true)
tt.render.sprites[1].prefix="stage201_dude1_statueDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS+1
tt.render.sprites[1].random_ts=fts(30)
self.manual_hero_insertion=false
end
function level:update(store)
P:deactivate_path(2)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
U.y_wait(store,2)
end
return level
