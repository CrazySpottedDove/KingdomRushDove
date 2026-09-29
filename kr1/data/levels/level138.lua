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
local AC=require("achievements")
local scripts=require("scripts")
local v=V.v
local r=V.r
local decal_stage_38_easter_ender_egg_insert
local decal_stage_38_easter_ender_egg_update
local decal_stage_38_to_the_stars_update
decal_stage_38_easter_ender_egg_insert=function(this,store,script)
this.pos=this.positions[1][1]
this.render.sprites[1].z=this.positions[1][2]
return true
end
decal_stage_38_easter_ender_egg_update=function(this,store,script)
local current_position=math.random(1,#this.positions-1)
this.pos=this.positions[current_position][1]
local function teleport_random()
local new_object_pos,new_object_z
table.remove(this.positions,current_position)
if #this.positions>0 then
current_position=math.random(1,#this.positions)
new_object_pos=this.positions[current_position][1]
new_object_z=this.positions[current_position][2]
else
new_object_pos=this.last_position[1]
new_object_z=this.last_position[2]
end
local fx=E:create_entity(this.fx_normal)
fx.pos=V.vclone(this.pos)
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
S:queue("Stage38EasterEggEnderEgg")
U.y_animation_play(this,"tp_out",nil,store.tick_ts,1,1)
this.pos=new_object_pos
this.render.sprites[1].z=new_object_z
U.animation_start(this,"tp_in",nil,store.tick_ts,false,1,true)
local fx=E:create_entity(this.fx_final)
fx.pos.x,fx.pos.y=this.pos.x,this.pos.y+30
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
U.y_animation_wait_default(this)
U.animation_start(this,"idle",nil,store.tick_ts,true,1,true)
end
local function teleport_last()
local fx=E:create_entity(this.gold_fx)
fx.pos=V.v(this.pos.x,this.pos.y+20)
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].z=this.render.sprites[1].z
fx.render.sprites[1].sort_y_offset=-30
simulation:queue_insert_entity(fx)
S:queue("TerrainWukongElementalHolderMetalActive")
store.player_gold=store.player_gold+this.gold_amount
U.y_wait_unconditional(store,0.5)
local fx=E:create_entity(this.fx_normal)
fx.pos=V.vclone(this.pos)
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
S:queue("Stage38EasterEggEnderEgg")
U.y_animation_play(this,"tp_out",nil,store.tick_ts,1,1)
U.sprites_hide(this,nil,nil,true)
U.y_wait_unconditional(store,0.2)
AC:got("DLC3_ENDER_EGG")
simulation:queue_remove_entity(this)
end
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
if #this.positions>0 then
teleport_random()
this.ui.can_click=true
else
teleport_last()
simulation:queue_remove_entity(this)
end
end
coroutine.yield()
end
end
decal_stage_38_to_the_stars_update=function(this,store,script)
local clics=0
local appear=false
this.ui.can_click=false
this.render.sprites[1].hidden=true
while true do
if not appear and store.wave_group_number>=1 then
appear=true
this.render.sprites[1].hidden=false
U.y_animation_play(this,"appear",nil,store.tick_ts,1,1)
U.animation_start(this,"idle1",nil,store.tick_ts,true,1,true)
this.ui.can_click=true
end
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
clics=clics+1
if clics==1 then
U.y_animation_play(this,"tap1",nil,store.tick_ts,1,1)
U.animation_start(this,"idle2",nil,store.tick_ts,true,1,true)
elseif clics==2 then
signal.emit("dragon-lunar-stage38",nil)
U.y_animation_play(this,"tap2",nil,store.tick_ts,1,1)
local drake=E:create_entity("decal_stage_38_to_the_stars_drakefx")
drake.pos.x,drake.pos.y=this.pos.x+23,this.pos.y+3
drake.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(drake)
U.animation_start(this,"idle3",nil,store.tick_ts,true,1,true)
U.y_wait_unconditional(store,fts(40))
local star=E:create_entity("decal_stage_38_to_the_stars_stars")
star.pos.x,star.pos.y=this.pos.x+23,this.pos.y+3
star.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(star)
U.y_wait_unconditional(store,fts(50))
U.y_animation_play(this,"banish",nil,store.tick_ts,1,1)
U.y_wait_unconditional(store,0.2)
AC:got("DLC3_TOUCH_DRAGON")
simulation:queue_remove_entity(this)
return
end
this.ui.can_click=true
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_38_mask_08","decal",true)
tt.render.sprites[1].name="stage_38_mask_08"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_38_mask_10","decal",true)
tt.render.sprites[1].name="stage_38_mask_10"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_38_to_the_stars","decal_scripted",true)
E:add_comps(tt,"ui","editor")
tt.main_script.update=decal_stage_38_to_the_stars_update
tt.render.sprites[1].prefix="to_the_stars_guy"
tt.render.sprites[1].name="idle1"
tt.ui.click_rect=r(-60,-20,70,70)
tt=E:register_t_hot("decal_stage_38_easter_egg_ender_egg","decal_scripted",true)
E:add_comps(tt,"ui","editor")
tt.main_script.insert=decal_stage_38_easter_ender_egg_insert
tt.main_script.update=decal_stage_38_easter_ender_egg_update
tt.render.sprites[1].prefix="ender_egg_egg"
tt.render.sprites[1].name="idle"
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].name="ender_egg_mask"
tt.render.sprites[2].ignore_start=true
tt.render.sprites[2].z=Z_OBJECTS_COVERS
tt.render.sprites[2].pos=v(811,427)
tt.render.sprites[2].animated=false
tt.fx_normal="fx_ender_egg_explosion_normal"
tt.fx_final="fx_ender_egg_explosion_final"
tt.ui.click_rect=r(-20,-10,40,45)
tt.positions={{v(621,131),Z_OBJECTS},{v(558,680),Z_OBJECTS},{v(1103,603),Z_OBJECTS},{v(305,282),Z_OBJECTS}}
tt.last_position={v(805,554),Z_OBJECTS_COVERS}
tt.gold_fx="fx_elemental_metal_holder_coins"
tt.gold_amount=150
tt=E:register_t_hot("decal_stage_38_mask_02","decal",true)
tt.render.sprites[1].name="stage_38_mask_02"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=106
tt=E:register_t_hot("decal_stage_38_mask_04","decal",true)
tt.render.sprites[1].name="stage_38_mask_04"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=-100
tt=E:register_t_hot("decal_stage_38_mask_09","decal",true)
tt.render.sprites[1].name="stage_38_mask_09"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_38_mask_01","decal",true)
tt.render.sprites[1].name="stage_38_mask_01"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=142
tt=E:register_t_hot("decal_stage_38_mask_03","decal",true)
tt.render.sprites[1].name="stage_38_mask_03"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=-20
tt=E:register_t_hot("stage_38_paths_controller","decal_scripted",true)
E:add_comps(tt,"events","editor")
tt.main_script.update=scripts.stage_36_paths_controller.update
tt.render.sprites[1].prefix="mecanica_camino_stage_3Def"
tt.render.sprites[1].name="in"
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.events.list[1].name="show_path"
tt.events.list[1].on_event=scripts.stage_36_paths_controller.on_show_path
tt.skip_shake=true
tt.holders_list={{{ts=fts(165),pos=v(235,210)},{shake=true,ts=fts(165)}}}
tt.path_unlocks={{islands_required={1},paths={4},terrain_paths={4},extra_terrains={}}}
tt.hide_exits_rects={}
tt.cinematic={{zoom=1,time=fts(67),pos=v(200,300)}}
tt.show_fx="fx_stage_36_path_dust"
tt.editor.overrides={["render.sprites[1].hidden"]=false,["render.sprites[1].name"]="idle"}
tt=E:register_t_hot("decal_stage_38_mask_07","decal",true)
tt.render.sprites[1].name="stage_38_mask_07"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=-200
tt=E:register_t_hot("decal_stage_38_mask_islas","decal_tween",true)
E:add_comps(tt,"main_script")
tt.main_script.insert=scripts.decal_stage_36_mask_islas.insert
tt.islas_levels={TOP=Z_BACKGROUND_COVERS+2,MID=Z_BACKGROUND_BETWEEN-1,BACK=Z_BACKGROUND_BETWEEN-2}
tt.islas_settings={{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120},{str=-6,z="BACK",freq=120}}
tt.temp_i=0
for i=1,#tt.islas_settings do
if not tt.islas_settings[i].skip then
tt.temp_i=tt.temp_i+1
local str=tt.islas_settings[i].str
local freq=tt.islas_settings[i].freq
local z=tt.islas_levels[tt.islas_settings[i].z]
freq=freq+math.random(-20,20)
tt.render.sprites[tt.temp_i]=E:clone_c("sprite")
tt.render.sprites[tt.temp_i].name="stage_03_islas_flotantes_00"..(i<10 and "0" or "")..i
tt.render.sprites[tt.temp_i].animated=false
tt.render.sprites[tt.temp_i].z=z
tt.tween.props[tt.temp_i]=E:clone_c("tween_prop")
tt.tween.props[tt.temp_i].sprite_id=tt.temp_i
tt.tween.props[tt.temp_i].name="offset"
tt.tween.props[tt.temp_i].interp="sine"
tt.tween.props[tt.temp_i].keys={{fts(0),v(0,0)},{fts(freq),v(0,-str)},{fts(freq*2),v(0,0)}}
tt.tween.props[tt.temp_i].loop=true
end
end
tt.temp_i=nil
tt.tween.remove=false
end
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=21
end
end
function level:load(store)
return
end
function level:update(store)
if not store.main_hero and not store.level.locked_hero and not store.level.manual_hero_insertion then
LU.insert_hero(store)
end
P:add_invalid_range(1,60,90,nil)
P:add_invalid_range(2,60,85,nil)
P:add_invalid_range(3,60,85,nil)
P:add_invalid_range(4,60,85,nil)
if store.level_mode==GAME_MODE_CAMPAIGN then
local controller_cinematic
for _,v in pairs(store.entities) do
if v.template_name=="controller_stage_38_cinematic" then
controller_cinematic=v
end
end
local function y_do_boss_taunt(key)
while controller_cinematic.current_taunt do
coroutine.yield()
end
controller_cinematic.do_taunt=key
while controller_cinematic.last_taunt~=key do
coroutine.yield()
end
end
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("pan-zoom-camera",0,{x=800,y=344},1.8)
local fly_hero=U.flag_has(store.main_hero.vis.flags,F_FLYING)
store.main_hero.pos.x=445
store.main_hero.pos.y=340
store.main_hero.nav_rally.center=V.vclone(store.main_hero.pos)
store.main_hero.nav_rally.pos=store.main_hero.nav_rally.center
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local wait_until_ts=store.tick_ts+3
while wait_until_ts>store.tick_ts do
coroutine.yield()
end
signal.emit("pan-zoom-camera",3,{x=690,y=404},OVtargets(nil,1.17,1.17,1,1.2))
U.y_wait_unconditional(store,4)
if fly_hero then
y_do_boss_taunt("LV38_INTRO_TAUNT_FLY_01")
else
y_do_boss_taunt("LV38_INTRO_TAUNT_01")
end
U.y_wait_unconditional(store,4)
if fly_hero then
y_do_boss_taunt("LV38_INTRO_TAUNT_FLY_02")
else
y_do_boss_taunt("LV38_INTRO_TAUNT_02")
end
U.y_wait_unconditional(store,3)
signal.emit("pan-zoom-camera",2,{x=400,y=380},1)
U.y_wait_unconditional(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
end
else
local controller
for _,v in pairs(store.entities) do
if v.template_name=="stage_38_paths_controller" then
controller=v
break
end
end
controller.modos=true
P:activate_path(4)
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="43"
end)[1]
holder.tower.upgrade_to="tower_pandas_lvl4"
coroutine.yield()
store.player_gold=starting_gold
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
