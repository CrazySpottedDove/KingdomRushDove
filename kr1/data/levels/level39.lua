local log=require("lib.klua.log"):new("level13")
local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local bit=require("bit")
local A=require("achievements")
local E=require("entity_db")
local P=require("path_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
level.required_sounds={"music_stage39","FrontiersUndergroundAmbienceSounds","SpecialBlackDragon"}
level.required_textures={"go_enemies_underground","go_stages_underground","go_stage39","go_stage39_bg"}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local V=require("lib.klua.vector")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local v=V.v
local r=V.r
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function button_steal_dragon_gold_update(this,store)
this.already_stolen=false
while true do
if this.ui.clicked then
this.ui.clicked=nil
if this.dragon.can_steal_gold and not this.already_stolen then
this.already_stolen=true
local gold_inc=math.floor(this.gold_to_steal/10)
for i=1,10 do
local fx=E:create_entity(this.fx)
fx.pos.x,fx.pos.y=this.pos.x+this.ui.click_rect.size.x*0.5,this.pos.y+this.ui.click_rect.size.y*0.5
fx.render.sprites[1].ts=store.tick_ts
fx.tween.props[2]=E:clone_c("tween_prop")
fx.tween.props[2].name="offset"
fx.tween.props[2].keys={{0,v(0,0)},{0.8,v(10,0)}}
simulation:queue_insert_entity(fx)
store.player_gold=store.player_gold+gold_inc
U.y_wait_unconditional(store,fts(5))
end
end
end
coroutine.yield()
end
end
local function decal_black_dragon_update(this,store)
local image_x=192
local start_x=store.visible_coords.left-image_x*0.5
local end_x=store.visible_coords.right+image_x*0.5
local wakeup_ts=0
local wakeup_cooldown=math.random(this.wakeup_cooldown_min,this.wakeup_cooldown_max)
local force_wakeup=false
local flame_comp_x=180
local fire_comp_x=120
local ps_flame_offset=v(-60,88)
local ps_fire_offset=v(-115,0)
local ps_flame=E:create_entity("ps_black_dragon_flame")
ps_flame.particle_system.track_id=this.id
ps_flame.particle_system.emit=false
ps_flame.particle_system.track_offset=V.vclone(ps_flame_offset)
simulation:queue_insert_entity(ps_flame)
local ps_fire=E:create_entity("ps_black_dragon_fire")
ps_fire.particle_system.track_id=this.id
ps_fire.particle_system.emit=false
ps_fire.particle_system.track_offset=V.vclone(ps_fire_offset)
simulation:queue_insert_entity(ps_fire)
local s=this.render.sprites[1]
local zzz=this.render.sprites[2]
local shadow=this.render.sprites[3]
local flame_hit=this.render.sprites[4]
local ma=this.attacks.list[1]
local shadow_offset=49
local shadow_ref_height=50
shadow.scale=v(1,1)
local function update_shadow()
local dy=this.pos.y-this.sleep_pos.y
local scale=km.clamp(0,1,1-dy/shadow_ref_height)
shadow.scale.x,shadow.scale.y=scale,scale
shadow.offset.y=shadow_offset-dy
end
::label_173_0::
while true do
if this.attack_requested then
local ar=this.attack_requested
local ap=this.dragon_paths[ar.path]
this.attack_requested=nil
shadow.hidden=false
update_shadow()
S:queue(this.sound_events.wakeup,{delay=fts(13)})
U.y_animation_play(this,"takeoff",nil,store.tick_ts,1,1)
this.can_steal_gold=true
U.animation_start(this,"flying",nil,store.tick_ts,true,1)
this.render.sprites[1].sort_y_offset=-200
U.update_max_speed(this,this.speed_takeoff)
U.set_destination(this,v(150,REF_H+100))
while not this.motion.arrived do
U.walk_off__accel__unsnapped(this,store.tick_length)
update_shadow()
coroutine.yield()
end
shadow.hidden=true
local flip=start_x<end_x
ps_flame.particle_system.track_offset.x=ps_flame_offset.x*(flip and -1 or 1)
ps_fire.particle_system.track_offset.x=ps_fire_offset.x*(flip and -1 or 1)
flame_hit.flip_x=flip
s.flip_x=flip
this.pos.x,this.pos.y=start_x,ap.y
U.update_max_speed(this,this.speed_fly)
U.set_destination(this,v(end_x,ap.y))
local flame_on,fire_on=false,false
local flame_i,flame_x=next(ap.x_ranges)
local fire_i,fire_x=next(ap.x_ranges)
s.loop_forced=true
while not this.motion.arrived do
if flame_x and flame_x<this.pos.x+flame_comp_x then
flame_i,flame_x=next(ap.x_ranges,flame_i)
flame_on=not flame_on
if flame_on then
S:queue(this.sound_events.fire)
ps_flame.particle_system.emit=true
U.animation_start(this,"firing",nil,store.tick_ts,true,1)
else
ps_flame.particle_system.emit=false
U.animation_start(this,"flying",nil,store.tick_ts,true,1)
end
end
if fire_x and fire_x<this.pos.x+fire_comp_x then
fire_i,fire_x=next(ap.x_ranges,fire_i)
fire_on=not fire_on
ps_fire.particle_system.emit=fire_on
flame_hit.hidden=not fire_on
if not fire_on then
local fx=E:create_entity("fx_black_dragon_flame_hit")
fx.pos.x,fx.pos.y=this.pos.x+(flip and 1 or -1)*flame_hit.offset.x,this.pos.y+flame_hit.offset.y
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
end
end
if fire_on then
local towers=table.filter(store.towers,function(_,e)
return e.tower and not e.tower_holder and V.dist(e.pos.x,e.pos.y,this.pos.x+fire_comp_x,this.pos.y)<ma.range and not e.tower.blocked
end)
for i,tower in ipairs(towers) do
local m=E:create_entity(ma.mod)
m.pos=tower.pos
m.modifier.target_id=tower.id
m.modifier.source_id=this.id
m.modifier.duration=math.random(ar.min_time,ar.max_time)
simulation:queue_insert_entity(m)
end
end
U.walk_off__accel__unsnapped(this,store.tick_length)
coroutine.yield()
end
s.loop_forced=false
U.y_wait_unconditional(store,2)
this.can_steal_gold=false
shadow.hidden=false
update_shadow()
U.animation_start_specific(this,"flying",false,store.tick_ts,true,1)
this.pos.x,this.pos.y=this.sleep_pos.x-5,this.sleep_pos.y+116
U.update_max_speed(this,this.speed_takeoff)
U.set_destination(this,this.sleep_pos)
while not this.motion.arrived do
U.walk_off__accel__unsnapped(this,store.tick_length)
update_shadow()
coroutine.yield()
end
U.y_animation_play(this,"land",nil,store.tick_ts,1,1)
U.animation_start(this,"idle",nil,store.tick_ts,true,1)
shadow.hidden=false
this.render.sprites[1].sort_y_offset=0
elseif force_wakeup or wakeup_cooldown<store.tick_ts-wakeup_ts then
force_wakeup=nil
wakeup_ts=store.tick_ts
S:queue(this.sound_events.wakeup,{delay=fts(13)})
U.y_animation_play(this,"wakeup",nil,store.tick_ts,1,1)
wakeup_cooldown=math.random(this.wakeup_cooldown_min,this.wakeup_cooldown_max)
else
this.ui.clicked=nil
zzz.hidden=false
zzz.alpha=255
U.animation_start(this,"zzz",nil,store.tick_ts,false,2)
while not U.animation_finished(this,2) do
if this.ui.clicked then
this.ui.clicked=nil
this.tween.disabled=false
this.tween.props[1].time_offset=zzz.ts-store.tick_ts
U.y_wait_unconditional(store,this.tween.props[1].keys[2][1])
this.tween.disabled=true
force_wakeup=true
goto label_173_0
end
coroutine.yield()
end
zzz.hidden=true
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("button_steal_dragon_gold",nil,true)
AC(tt,"pos","main_script","ui")
tt.main_script.update=button_steal_dragon_gold_update
tt.ui.click_rect=r(0,0,88,67)
tt.gold_to_steal=100
tt.fx="fx_coin_jump"
tt=E:register_t_hot("decal_black_dragon","decal_scripted",true)
AC(tt,"motion","attacks","tween","ui","sound_events")
tt.main_script.update=decal_black_dragon_update
tt.motion.max_speed=12*FPS
tt.attacks.list[1]=CC("mod_attack")
tt.attacks.list[1].mod="mod_black_dragon"
tt.attacks.list[1].cooldown=0.2
tt.attacks.list[1].range=30
tt.render.sprites[1].prefix="decal_black_dragon"
tt.render.sprites[1].anchor.y=0
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].prefix="decal_black_dragon"
tt.render.sprites[2].name="zzz"
tt.render.sprites[2].hidden=true
tt.render.sprites[2].loope=false
tt.render.sprites[2].anchor.y=0
tt.render.sprites[2].z=Z_OBJECTS+1
tt.render.sprites[3]=CC("sprite")
tt.render.sprites[3].name="Stage12_Dragon_Shadow"
tt.render.sprites[3].animated=false
tt.render.sprites[3].hidden=true
tt.render.sprites[3].draw_order=-1
tt.render.sprites[4]=CC("sprite")
tt.render.sprites[4].name="black_dragon_flame_hit"
tt.render.sprites[4].hidden=true
tt.render.sprites[4].offset=vec_2(105,10)
tt.sound_events.wakeup="SpecialBlackDragonTaunt"
tt.sound_events.fire="SpecialBlackDragonFire"
tt.tween.remove=false
tt.tween.disabled=true
tt.tween.props[1].keys={{0,255},{fts(8),0}}
tt.tween.props[1].sprite_id=2
tt.ui.click_rect=r(-50,30,110,90)
tt.wakeup_cooldown_min=5
tt.wakeup_cooldown_max=16
tt.sleep_pos=vec_2(610,579)
tt.speed_fly=12*FPS
tt.speed_takeoff=5*FPS
store.level_terrain_style=TERRAIN_STYLE_UNDERGROUND
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=6
self.locked_towers={}
if store.level_mode==GAME_MODE_IRON then
self.locked_towers={"tower_build_mage","tower_build_archer"}
end
local scripts=require("scripts")
tt=E:register_t_hot("mod_black_dragon","modifier",true)
AC(tt,"render")
tt.modifier.duration=7
tt.main_script.update=scripts.mod_tower_block.update
tt.render.sprites[1].prefix="black_dragon_tower_fire"
tt.render.sprites[1].name="start"
tt.render.sprites[1].anchor.y=0.19
tt.render.sprites[1].sort_y_offset=-1
tt=E:register_t_hot("ps_black_dragon_flame",nil,true)
AC(tt,"pos","particle_system")
tt.particle_system.animated=true
tt.particle_system.emission_rate=20
tt.particle_system.emit_direction=-math.pi/5
tt.particle_system.emit_area_spread=vec_2(4,4)
tt.particle_system.emit_spread=math.pi/24
tt.particle_system.emit_rotation=0
tt.particle_system.emit_speed={24*FPS,22*FPS}
tt.particle_system.loop=false
tt.particle_system.name="black_dragon_flame"
tt.particle_system.particle_lifetime={fts(6),fts(6)}
tt=E:register_t_hot("ps_black_dragon_fire",nil,true)
AC(tt,"pos","particle_system")
tt.particle_system.alphas={255,255,0}
tt.particle_system.animated=true
tt.particle_system.emission_rate=15
tt.particle_system.emit_area_spread=vec_2(4,15)
tt.particle_system.emit_rotation=0
tt.particle_system.loop=false
tt.particle_system.name="black_dragon_fire"
tt.particle_system.particle_lifetime={fts(20),fts(25)}
tt.particle_system.anchor=vec_2(0.5,0.25)
tt=E:register_t_hot("fx_black_dragon_flame_hit","decal_tween",true)
tt.render.sprites[1].name="black_dragon_flame_hit"
tt.tween.props[1].name="alpha"
tt.tween.props[1].keys={{0,255},{0.3,0}}
end
function level:load(store)
LU.insert_background(store,"Stage13_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage13_0002",Z_BACKGROUND_COVERS)
LU.insert_background(store,"Stage13_0003",Z_OBJECTS,628)
LU.insert_background(store,"Stage13_0004",Z_OBJECTS,584)
LU.insert_background(store,"Stage13_0005",Z_OBJECTS,35)
LU.insert_background(store,"Stage13_0006",Z_OBJECTS,155)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
if store.level_mode==GAME_MODE_CAMPAIGN then
for _,h in pairs(self.locations.holders) do
if table.contains({"5","7","12","16"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_underground",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
elseif store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if table.contains({"5","7","12","16"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_underground",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
else
for _,h in pairs(self.locations.holders) do
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{2,11,x,x},{4,16,1,x},{5,13,16,4},{6,3,2,x},{8,8,3,15},{7,15,4,x},{x,9,6,x},{9,10,5,15},{x,x,8,7},{9,14,13,8},{12,14,x,1},{13,14,11,16},{10,14,12,3},{9,x,13,10},{6,8,5,6},{3,12,2,2},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x},{x,x,x,x}}
P:add_invalid_range(1,1,15)
P:add_invalid_range(2,1,18)
P:add_invalid_range(5,1,10)
local e
e=E:create_entity("decal_black_dragon")
e.pos.x,e.pos.y=e.sleep_pos.x,e.sleep_pos.y
LU.queue_insert(store,e)
self.dragon=e
e=E:create_entity("button_steal_dragon_gold")
e.pos.x,e.pos.y=605,679
e.dragon=self.dragon
LU.queue_insert(store,e)
self.dragon_cave_button=e
self.dragon.dragon_paths={{y=468,x_ranges={165,530}},{y=305,x_ranges={300,450}},{y=305,x_ranges={600,765}},{y=305,x_ranges={300,450,600,765}}}
if store.level_mode==GAME_MODE_CAMPAIGN then
self.dragon_waves={{min_time=8,delay=20,max_time=12,wave=4,path=1},{min_time=8,delay=25,max_time=12,wave=7,path=4},{min_time=6,delay=10,max_time=8,wave=9,path=1},{min_time=8,delay=30,max_time=12,wave=9,path=3},{min_time=8,delay=40,max_time=12,wave=9,path=2},{min_time=8,delay=30,max_time=12,wave=10,path=2},{min_time=8,delay=45,max_time=12,wave=10,path=3},{min_time=8,delay=60,max_time=12,wave=10,path=4},{min_time=4,delay=15,max_time=6,wave=12,path=1},{min_time=4,delay=40,max_time=6,wave=12,path=4},{min_time=8,delay=5,max_time=10,wave=13,path=1},{min_time=3,delay=20,max_time=5,wave=14,path=2},{min_time=4,delay=50,max_time=6,wave=14,path=3},{min_time=3,delay=80,max_time=5,wave=14,path=2},{min_time=4,delay=110,max_time=6,wave=14,path=1},{min_time=4,delay=10,max_time=6,wave=15,path=3},{min_time=3,delay=40,max_time=5,wave=15,path=2},{min_time=4,delay=70,max_time=6,wave=15,path=1},{min_time=3,delay=100,max_time=5,wave=15,path=4},{min_time=4,delay=130,max_time=6,wave=15,path=1}}
elseif store.level_mode==GAME_MODE_HEROIC then
self.dragon_waves={{min_time=2,delay=10,max_time=5,wave=1,path=1},{min_time=6,delay=8,max_time=10,wave=2,path=1},{min_time=6,delay=4,max_time=10,wave=3,path=4},{min_time=6,delay=1,max_time=10,wave=5,path=1},{min_time=6,delay=15,max_time=10,wave=5,path=2},{min_time=3,delay=35,max_time=8,wave=5,path=3}}
else
self.dragon_waves={{min_time=5,delay=10,max_time=6,wave=1,path=3},{min_time=5,delay=110,max_time=6,wave=1,path=2},{min_time=5,delay=230,max_time=6,wave=1,path=1},{min_time=5,delay=320,max_time=6,wave=1,path=4}}
end
e=E:create_entity("background_sounds_underground")
LU.queue_insert(store,e)
end
function level:update(store)
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
local dwi,dw=next(self.dragon_waves)
local wts=store.tick_ts
while not store.waves_finished and dw do
while store.wave_group_number<dw.wave do
coroutine.yield()
wts=store.tick_ts
end
while store.tick_ts-wts<dw.delay do
if store.wave_group_number~=dw.wave then
goto label_4_0
end
coroutine.yield()
end
self.dragon.attack_requested=dw
self.dragon_cave_button.already_stolen=false
::label_4_0::
dwi,dw=next(self.dragon_waves,dwi)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
