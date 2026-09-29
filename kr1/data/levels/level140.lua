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
local boss_shadow_waves,moving_island
local function y_set_middle_path_walkable(store)
for x=2,87 do
for y=32,15,-1 do
GR:set_cell(x,y,TERRAIN_LAND)
end
end
for _,v in pairs(store.entities) do
if v.tower_holder or v.tower then
for xx=-25,25,3 do
for yy=-6,18,3 do
local i,j=GR:get_coords(v.pos.x+xx,v.pos.y+yy)
GR:set_cell(i,j,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
end
end
while moving_island.pos.x>76 do
coroutine.yield()
end
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
U.y_wait_unconditional(store,0.5)
S:queue("Stage40PathOpen")
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=2
shake.aura.freq_factor=2
shake.aura.reverse_fade=true
LU.queue_insert(store,shake)
local mask=E:create_entity("decal_stage_40_open_middle_mask")
mask.pos=V.v(512,384)
mask.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,mask)
local timing_start=store.tick_ts
local dirt_fx_timings_and_positions={{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x+110,moving_island.pos.y+-50)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x+125,moving_island.pos.y+-20)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+100,moving_island.pos.y+10)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x-60,moving_island.pos.y+-50)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x+60,moving_island.pos.y+-30)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+0,moving_island.pos.y+-50)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x+-30,moving_island.pos.y+-30)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x-60,moving_island.pos.y+70)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x+60,moving_island.pos.y+50)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+0,moving_island.pos.y+70)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x+-30,moving_island.pos.y+50)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x-100,moving_island.pos.y+10)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x-90,moving_island.pos.y+-10)},{lock_moving_island=true,ts=timing_start+1.85+0.1},{hide_storm=true,ts=timing_start+1.85+0.12},{boss_flight=true,ts=timing_start+0.6},{shake=true,ts=timing_start+1.9},{holders=true,ts=timing_start+1.9}}
local storm_decos
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_40_storm_decos" then
storm_decos=v
break
end
end
table.sort(dirt_fx_timings_and_positions,function(a,b)
return a.ts<b.ts
end)
local wait_until_ts=store.tick_ts+4
while wait_until_ts>store.tick_ts do
local entry=dirt_fx_timings_and_positions[1]
if entry and store.tick_ts>entry.ts then
if entry.lock_moving_island then
moving_island:on_open_path()
end
if entry.hide_storm then
storm_decos.render.sprites[7].hidden=true
end
if entry.boss_flight then
boss_shadow_waves.stun_side="RIGHT"
boss_shadow_waves.stun_with_fps=60
end
if entry.pos then
local fx=E:create_entity("fx_stage_40_moving_island_explosion_dirt")
fx.pos=entry.pos
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=V.vv(fx.render.sprites[1].scale.x*0.8+fx.render.sprites[1].scale.x*0.4*math.random())
LU.queue_insert(store,fx)
end
if entry.shake then
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=1
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
end
if entry.holders then
local holders={}
for _,v in pairs(store.towers) do
if v.tower and (v.tower.holder_id=="11" or v.tower.holder_id=="9") then
table.insert(holders,v)
local fx=E:create_entity("fx_stage_40_moving_island_explosion_dirt")
fx.pos=V.v(v.pos.x,v.pos.y-10)
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=V.vv(fx.render.sprites[1].scale.x*0.8+fx.render.sprites[1].scale.x*0.4*math.random())
LU.queue_insert(store,fx)
elseif v.template_name=="decal_stage_40_holders_mask" then
LU.queue_remove(store,v)
end
end
coroutine.yield()
for _,v in pairs(holders) do
U.sprites_show(v,nil,nil,true)
if v.tower_holder then
v.tower_holder.blocked=false
end
v.ui.can_click=true
v.ui.can_select=true
end
end
table.remove(dirt_fx_timings_and_positions,1)
end
coroutine.yield()
end
end
local function show_focus_circle(store,pos)
local screen_focus_circle=E:create_entity("screen_focus_circle")
screen_focus_circle.circle_pos=pos
screen_focus_circle.circle_radius=200
LU.queue_insert(store,screen_focus_circle)
return screen_focus_circle
end
local function remove_focus_circle(store,circle)
circle.tween.remove=true
circle.tween.ts=store.tick_ts
circle.tween.reverse=true
end
local function unclickable_all(store)
local unclickable_objects={}
for _,v in pairs(store.entities) do
if v.ui then
local orig_config={can_click=v.ui.can_click,can_select=v.ui.can_select,id=v.id}
table.insert(unclickable_objects,orig_config)
v.ui.can_click=false
v.ui.can_select=false
end
end
return unclickable_objects
end
local function reset_clickable_all(store,objects)
for _,v in pairs(objects) do
local e=store.entities[v.id]
if e and e.ui then
e.ui.can_click=v.can_click
e.ui.can_select=v.can_select
end
end
end
local level={}
function level:init(store)
require("lib.klua.table")
local SU=require("script_utils")
local scripts=require("scripts")
local v=V.v
local vv=V.vv
local controller_stage_40_boss_shadow_waves_update
local controller_stage_40_boss_shadow_waves_on_stun_stage
controller_stage_40_boss_shadow_waves_update=function(this,store,script)
local number_attack=0
local path_rock_1,path_rock_2,path_rock_3
local decoy_positions={}
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_40_path_rock_1" then
path_rock_1=e
elseif e.template_name=="decal_stage_40_path_rock_2" then
path_rock_2=e
elseif e.template_name=="decal_stage_40_path_rock_final" then
path_rock_3=e
elseif e.template_name=="decal_boss_40_waves_stun_decoy_position" then
table.insert(decoy_positions,e)
end
end
local a_stun_towers=this.timed_attacks.list[this.attack_towers_index]
local a_stun_units=this.timed_attacks.list[this.attack_units_index]
if not a_stun_units.stun_fliers then
a_stun_units.vis_bans=bor(a_stun_units.vis_bans,F_FLYING)
end
local function appear()
S:queue("Stage40BossDriveby")
U.sprites_show(this,1,1,true)
U.animation_start(this,"fly",nil,store.tick_ts,false,1,true)
end
local function get_towers(side)
local allowed_holders=a_stun_towers.holders_ids[side]
return U.find_towers_in_range(store.towers,this.pos,a_stun_towers,function(t)
if not t.tower.can_be_mod then
return false
end
if not table.contains(allowed_holders,t.tower.holder_id) then
return false
end
return true
end)
end
local function stun_tower(t,delay,decal_warning,side)
local decal_stun=E:create_entity(a_stun_towers.decal_stun)
decal_stun.pos=V.vclone(t.pos)
decal_stun.target_id=t.id
decal_stun.holder_id=t.tower.holder_id
decal_stun.delay_start=delay
decal_stun.decal_warning=decal_warning
decal_stun.side=side
simulation:queue_insert_entity(decal_stun)
end
local function stun_unit(u,delay,side)
local decal_stun=E:create_entity(a_stun_units.decal_stun)
decal_stun.pos=V.vclone(u.pos)
decal_stun.target_id=u.id
decal_stun.delay_start=delay+0.3*math.random()
decal_stun.side=side
simulation:queue_insert_entity(decal_stun)
end
local function stun_decoy(pos,delay,side)
local decal_stun=E:create_entity("decal_boss_40_waves_stun_decoy")
decal_stun.pos=V.vclone(pos)
decal_stun.delay_start=delay+0.3*math.random()
decal_stun.side=side
simulation:queue_insert_entity(decal_stun)
end
local function y_attack_side(side)
number_attack=number_attack+1
local dir
local extra_dist=-500
local speed=700
if this.stun_with_fps then
this.render.sprites[1].fps=this.stun_with_fps
speed=speed*(this.stun_with_fps/30)
end
if side=="LEFT" then
this.pos.x=REF_W+extra_dist
dir=1
this.render.sprites[1].flip_x=false
this.imaginary_position=V.v(0,384)
else
this.pos.x=-extra_dist
dir=-1
this.render.sprites[1].flip_x=true
this.imaginary_position=V.v(REF_W,384)
end
local function do_once(name,condition,fn)
if not this.do_once[name] and condition() then
this.do_once[name]=true
fn()
end
end
local function reset_do_once(name)
if not this.do_once then
this.do_once={}
end
this.do_once[name]=false
end
if number_attack~=5 then
reset_do_once("stun")
local stuns_amount=0
local towers=get_towers(side)
local units=U.find_soldiers_in_range(store.soldiers,this.pos,a_stun_units.min_range,a_stun_units.max_range,a_stun_units.vis_flags,a_stun_units.vis_bans)
local decal
local decal_warning_i=0
local bullet_delay=0
local pixel_delay_mult=0.002
if towers and #towers>0 then
for _,t in pairs(towers) do
decal=E:create_entity(a_stun_towers.decal_warning)
decal.pos=V.vclone(t.pos)
decal.delay_start=decal_warning_i*fts(2)
simulation:queue_insert_entity(decal)
decal_warning_i=decal_warning_i+1
if side=="LEFT" then
bullet_delay=(t.pos.x-this.imaginary_position.x)*pixel_delay_mult
else
bullet_delay=(this.imaginary_position.x-t.pos.x)*pixel_delay_mult
end
stun_tower(t,bullet_delay,decal,side)
stuns_amount=stuns_amount+1
end
end
if a_stun_units.enabled and units and #units>0 then
for k,u in pairs(units) do
if side=="LEFT" then
bullet_delay=(u.pos.x-this.imaginary_position.x)*pixel_delay_mult
else
bullet_delay=(this.imaginary_position.x-u.pos.x)*pixel_delay_mult
end
if u.template_name~="soldier_warden_stage_40_moving_island" then
stun_unit(u,bullet_delay,side)
stuns_amount=stuns_amount+1
end
end
end
local total_decoys=12-stuns_amount
if total_decoys>0 then
decoy_positions=table.random_order(decoy_positions)
for i=1,total_decoys do
if i>#decoy_positions then
break
end
local decoy_pos=decoy_positions[i].pos
if side=="LEFT" then
bullet_delay=(decoy_pos.x-this.imaginary_position.x)*pixel_delay_mult
else
bullet_delay=(this.imaginary_position.x-decoy_pos.x)*pixel_delay_mult
end
stun_decoy(decoy_pos,bullet_delay,side)
end
end
end
appear()
local start_shake_ts=store.tick_ts+0.3
local up_rocks
if number_attack==2 then
up_rocks={{ts=store.tick_ts+0.5,rock=path_rock_1},{ts=store.tick_ts+0.8,rock=path_rock_2},{ts=store.tick_ts+1.1,rock=path_rock_3}}
end
while not U.animation_finished_default(this) do
this.imaginary_position.x=this.imaginary_position.x+dir*speed*store.tick_length
if start_shake_ts and start_shake_ts<store.tick_ts then
start_shake_ts=nil
if store.wave_group_number~=10 and store.wave_group_number~=9 then
SU.shake_screen(store,0.3,4,4)
end
end
if up_rocks and #up_rocks>0 and store.tick_ts>=up_rocks[1].ts then
up_rocks[1].rock.go_up=true
table.remove(up_rocks,1)
end
coroutine.yield()
end
U.sprites_hide(this,nil,nil,true)
this.render.sprites[1].fps=nil
end
while true do
if this.stun_side then
y_attack_side(this.stun_side)
this.stun_side=nil
end
coroutine.yield()
end
end
controller_stage_40_boss_shadow_waves_on_stun_stage=function(this,store,action,side)
this.stun_side=side
end
local tt
tt=E:register_t_hot("decal_stage_40_top_mask","decal",true)
tt.render.sprites[1].name="stage_40_mask_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_40_storm_decos","decal",true)
tt.render.sprites[1].prefix="stage_40_storm_01Def"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.render.sprites[1].scale=vv(4)
tt.render.sprites[1].pos=v(512,384)
tt.render.sprites[2]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_y=true
tt.render.sprites[3]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix="stage_40_storm_02Def"
tt.render.sprites[3].z=Z_OBJECTS_COVERS
tt.render.sprites[3].scale=vv(1)
tt.render.sprites[4]=table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].prefix="stage_40_storm_04Def"
tt.render.sprites[4].z=Z_BACKGROUND_COVERS
tt.render.sprites[4].sort_y_offset=-1
tt.render.sprites[5]=table.deepclone(tt.render.sprites[3])
tt.render.sprites[5].pos=v(300,330)
tt.render.sprites[5].prefix="stage_40_storm_04Def"
tt.render.sprites[5].z=Z_BACKGROUND_COVERS+2
tt.render.sprites[5].sort_y_offset=55
tt.render.sprites[5].hidden=true
tt.render.sprites[6]=table.deepclone(tt.render.sprites[3])
tt.render.sprites[6].prefix="stage_40_storm_05Def"
tt.render.sprites[6].z=Z_BACKGROUND_COVERS-1
tt.render.sprites[7]=table.deepclone(tt.render.sprites[3])
tt.render.sprites[7].pos=v(800,340)
tt.render.sprites[7].prefix="stage_40_storm_04Def"
tt.render.sprites[7].z=Z_BACKGROUND_COVERS
tt.render.sprites[7].sort_y_offset=-1
tt.render.sprites[8]=table.deepclone(tt.render.sprites[3])
tt.render.sprites[8].pos=v(800,370)
tt.render.sprites[8].prefix="stage_40_storm_04Def"
tt.render.sprites[8].z=Z_BACKGROUND_COVERS-1
tt=E:register_t_hot("decal_stage_40_open_middle_mask_iron","decal_stage_40_open_middle_mask",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="rocas_idle"
tt=E:register_t_hot("decal_stage_40_holders_mask","decal",true)
tt.render.sprites[1].name="stage_40_holder_mask_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS+10
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="stage_40_holder_mask_2"
tt.render.sprites[2].animated=false
tt.render.sprites[2].z=Z_BACKGROUND_COVERS+10
tt=E:register_t_hot("decal_stage_40_bottom_mask","decal",true)
tt.render.sprites[1].name="stage_40_mask_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS+2
tt=E:register_t_hot("controller_stage_40_boss_shadow_waves","decal_scripted",true)
E:add_comps(tt,"editor","timed_attacks","events")
tt.main_script.update=controller_stage_40_boss_shadow_waves_update
tt.render.sprites[1].prefix="stage_40_bossDef"
tt.render.sprites[1].name="fly"
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.render.sprites[1].loop=false
tt.render.sprites[1].hidden=true
tt.render.sprites[1].exo=true
tt.attack_towers_index=1
tt.timed_attacks.list[tt.attack_towers_index]=E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_towers_index].decal_stun="decal_boss_40_waves_stun_towers"
tt.timed_attacks.list[tt.attack_towers_index].decal_warning="decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_towers_index].max_range=99999999
tt.timed_attacks.list[tt.attack_towers_index].min_range=0
tt.timed_attacks.list[tt.attack_towers_index].holders_ids={RIGHT={"1","4","5","10","12","6","7","8","9"},LEFT={"1","4","5","10","12","6","7","8","9"}}
tt.attack_units_index=2
tt.timed_attacks.list[tt.attack_units_index]=E:clone_c("mod_attack")
tt.timed_attacks.list[tt.attack_units_index].vis_flags=bor(F_MOD,F_STUN)
tt.timed_attacks.list[tt.attack_units_index].decal_stun="decal_boss_40_waves_stun_units"
tt.timed_attacks.list[tt.attack_units_index].decal_warning="decal_stage_40_boss_shadow_waves_warning"
tt.timed_attacks.list[tt.attack_units_index].max_range=99999999
tt.timed_attacks.list[tt.attack_units_index].min_range=0
tt.timed_attacks.list[tt.attack_units_index].enabled=true
tt.timed_attacks.list[tt.attack_units_index].stun_fliers=true
tt.timed_attacks.list[tt.attack_units_index].mod_stun_wardens="mod_boss_stage_40_stun_wardens"
tt.events.list[1].name="stun_stage"
tt.events.list[1].on_event=controller_stage_40_boss_shadow_waves_on_stun_stage
end
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=22
end
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode~=GAME_MODE_HEROIC then
P:deactivate_path(10)
end
for _,v in pairs(store.entities) do
if v.tower and (v.tower.holder_id=="11" or v.tower.holder_id=="9") then
U.sprites_hide(v,nil,nil,true)
v.tower_holder.blocked=true
v.ui.can_click=false
v.ui.can_select=false
elseif v.template_name=="controller_stage_40_moving_island" then
moving_island=v
elseif v.template_name=="controller_stage_40_boss_shadow_waves" then
boss_shadow_waves=v
elseif v.template_name=="controller_stage_40_ballista" then
ballista=v
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
self.island_soldiers_cinematic=false
self.bossfight_started=false
P:add_invalid_range(12,nil,nil)
P:add_invalid_range(13,nil,nil)
P:add_invalid_range(14,nil,nil)
P:add_invalid_range(15,nil,nil)
P:add_invalid_range(16,nil,nil)
P:add_invalid_range(17,nil,nil)
P:deactivate_path(4)
P:deactivate_path(5)
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=800,y=500},1.2)
U.y_wait_unconditional(store,4.8)
signal.emit("pan-zoom-camera",0.5,{x=800,y=384},1.2)
U.y_wait_unconditional(store,0.4)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.6
shake.aura.duration=0.5
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
U.y_wait_unconditional(store,1.5)
moving_island:talk()
signal.emit("show-balloon_tutorial","LV40_INTRO_TAUNT_01",false)
U.y_wait_unconditional(store,3)
moving_island.remove_stone_1=true
U.y_wait_unconditional(store,2.2)
signal.emit("pan-zoom-camera",2,{x=512,y=380},1)
U.y_wait_unconditional(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
else
moving_island.remove_stone_1=true
end
while not self.island_soldiers_cinematic do
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=300,y=384},1.2)
U.y_wait_unconditional(store,3)
y_set_middle_path_walkable(store)
P:activate_path(4)
P:activate_path(5)
U.y_wait_unconditional(store,0.8)
moving_island.render.sprites[moving_island.sid_top_warden].flip_x=true
U.y_wait_unconditional(store,0.2)
moving_island:talk()
signal.emit("show-balloon_tutorial","LV40_WAVE_10_TAUNT_01",false)
U.y_wait_unconditional(store,1.5)
moving_island.next_runa_wave=10
moving_island:spawn_soldiers(store)
U.y_wait_unconditional(store,2.5)
signal.emit("pan-zoom-camera",2,{x=512,y=384},1.5)
U.y_wait_unconditional(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=300,y=384},1.3)
U.y_wait_unconditional(store,2)
signal.emit("show-balloon_tutorial","LV40_BOSSFIGHT_START_TAUNT_01",false)
U.y_wait_unconditional(store,3)
U.mark_seen(store,"controller_stage_40_boss")
local boss=E:create_entity("controller_stage_40_boss")
boss.pos=V.v(512,384)
LU.queue_insert(store,boss)
coroutine.yield()
store.game_gui:set_boss(boss)
signal.emit("pan-zoom-camera",4,{x=512,y=380},1)
U.y_wait_unconditional(store,8.2)
moving_island.remove_runas=true
U.y_wait_unconditional(store,9.8)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
if not moving_island.can_attack then
moving_island.can_attack=true
end
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait_unconditional(store,1)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_HEROIC then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="41"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="44"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="45"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="47"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="48"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="49"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="50"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="51"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="52"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
for x=2,87 do
for y=32,15,-1 do
GR:set_cell(x,y,TERRAIN_LAND)
end
end
for _,v in pairs(store.entities) do
if v.tower_holder or v.tower then
for xx=-25,25,3 do
for yy=-6,18,3 do
local i,j=GR:get_coords(v.pos.x+xx,v.pos.y+yy)
GR:set_cell(i,j,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
end
end
coroutine.yield()
store.player_gold=starting_gold
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
