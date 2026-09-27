local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level209")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
local S=require("sound_db")
local scripts=require("scripts")
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
local tt
tt=E:register_t_hot("decal_stage_209_mask_1","decal",true)
tt.render.sprites[1].name="Stage_9_door_MASK-"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_209_mask_2","decal",true)
tt.render.sprites[1].name="Stage_9_troll_door_MASK"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_209_mask_3","decal",true)
tt.render.sprites[1].name="Stage_9_troll_floor_MASK"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS-1
tt=E:register_t_hot("decal_stage_209_mask_4","decal",true)
tt.render.sprites[1].name="Stage_9_door_column_MASK"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_209_mask_5","decal",true)
tt.render.sprites[1].name="Stage_9_light_MASK"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_209_cliff_mask_small","decal",true)
tt.render.sprites[1].name="Stage_9_column_shadow_MASK"
tt.render.sprites[1].animated=false
tt.render.sprites[1].scale=v(1.5,1.2)
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_209_cliff_mask_big","decal_stage_209_cliff_mask_small",true)
tt.render.sprites[1].scale=v(2.2,1.2)
tt=E:register_t_hot("decal_stage_209_entrance_cover","decal",true)
tt.render.sprites[1].prefix="troll_door_stg9Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_209_brazier","decal",true)
tt.render.sprites[1].prefix="fire_stg9Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_209_bg_brazier","decal",true)
tt.render.sprites[1].prefix="fire_small_stg9Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_209_pillar_dust","decal_tween",true)
AC(tt,"main_script")
tt.render.sprites[1].prefix="column_decal_stg9Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].offset=v(0,25)
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_DECALS
tt.tween.props[1].keys={{0,0},{1,255}}
tt.tween.remove=false
tt.tween.disabled=true
tt.tween.run_once=true
tt.wait_time=3
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.main_script.update=scripts.tween_utils.wait_update
local function decal_stage_209_mortal_kombat_update(this,store)
local character="scorpion"
local ts=store.tick_ts
local function get_opposite_character()
if character=="scorpion" then
return "subzero"
else
return "scorpion"
end
end
while true do
if store.tick_ts-ts>this.attack_cd then
if this.sound_hit then
S:queue(this.sound_hit,{delay=fts(this.sound_hit_frames[character])})
end
U.y_animation_play(this,"attk_"..character,nil,store.tick_ts,1,1)
U.animation_start(this,get_opposite_character().."_mareo_loop",nil,store.tick_ts,true,1,true)
local stun_ts=store.tick_ts
while store.tick_ts-stun_ts<this.stun_duration do
if this.ui and this.ui.clicked then
if this.sound_finisher then
S:queue(this.sound_finisher,{delay=fts(this.sound_finisher_frame)})
end
U.y_animation_play(this,get_opposite_character().."_mareo_click",nil,store.tick_ts,1,1)
signal.emit("kombat-finisher-stage09")
queue_remove(store,this)
return
end
coroutine.yield()
end
U.y_animation_play(this,get_opposite_character().."_mareo_out",nil,store.tick_ts,1,1)
U.animation_start(this,"idle",nil,store.tick_ts,true,1,true)
character=get_opposite_character()
ts=store.tick_ts
end
this.ui.clicked=false
coroutine.yield()
end
end
tt=E:register_t_hot("decal_stage_209_mortal_kombat","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easter_egg_mortal_kombatDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].offset=v(0,25)
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=decal_stage_209_mortal_kombat_update
tt.ui.click_rect=r(-40,18,80,35)
tt.sound="Stage09MortalKombat"
tt.sound_hit="Stage09MortalKombatHit"
tt.sound_hit_frames={scorpion=24,subzero=41}
tt.sound_finisher="Stage09MortalKombatFinisher"
tt.sound_finisher_frame=17
tt.attack_cd=10
tt.stun_duration=5
tt=E:register_t_hot("fx_stage_209_pillar_thump_top","fx",true)
tt.render.sprites[1].prefix="top_column_crumble_stg9Def"
tt.render.sprites[1].name="tapCrumble"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("fx_stage_209_pillar_thump_down","fx_stage_209_pillar_thump_top",true)
tt.render.sprites[1].prefix="down_column_crumble_stg9Def"
tt=E:register_t_hot("aura_pillar_stage_209_damage","aura",true)
tt.aura.radius=65
tt.aura.vis_flags=bor(F_AREA,F_ENEMY,F_FRIEND)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.damage_min=200
tt.aura.damage_max=300
tt.aura.damage_type=DAMAGE_INSTAKILL
tt.main_script.update=scripts.aura_utils.apply_area_damage
tt=E:register_t_hot("editor_pillar_rally_point","editor_rally_point",true)
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="rain_of_fire_hit_0009"
local function tower_holder_pillar_e_insert(this,store)
local rally=E:create_entity("editor_pillar_rally_point")
queue_insert(store,rally)
rally.tower_id=this.id
this.editor.pillar_point_id=rally.id
if this.pillar.pillar_damage_center and this.pillar.pillar_damage_center.x~=0 and this.pillar.pillar_damage_center.y~=0 then
rally.pos=this.pillar.pillar_damage_center
else
rally.pos=V.v(this.pos.x+50,this.pos.y+50)
this.pillar.pillar_damage_center=rally.pos
end
local rally2=E:create_entity("editor_rally_point")
queue_insert(store,rally2)
rally2.tower_id=this.id
this.editor.rally_point_id=rally2.id
if this.pillar.default_rally_pos and this.pillar.default_rally_pos.x~=0 and this.pillar.default_rally_pos.y~=0 then
rally2.pos=this.pillar.default_rally_pos
else
rally2.pos=V.v(this.pos.x+50,this.pos.y+50)
this.pillar.default_rally_pos=rally2.pos
end
if not this.pillar.holder_id then
this.pillar.holder_id=tostring(this.id)
end
if this.barrack then
this.barrack.rally_pos=rally2.pos
end
return true
end
local function tower_holder_pillar_e_remove(this,store)
local rally=store.entities[this.editor.rally_point_id]
if rally then
queue_remove(store,rally)
end
local pillar=store.entities[this.editor.pillar_point_id]
if pillar then
queue_remove(store,pillar)
end
return true
end
local function tower_holder_pillar_update(this,store)
local tap_count=0
local last_tap,crumble
local wait=math.random(this.random_min,this.random_max)
local start_ts=store.tick_ts
while wait>store.tick_ts-start_ts do
if this.ui.clicked then
goto label_pillar_idle
end
coroutine.yield()
end
U.animation_start(this,"idle",nil,store.tick_ts,true,1,true)
::label_pillar_idle::
while true do
::label_pillar_tap::
if this.ui.clicked then
this.ui.clicked=false
tap_count=tap_count+1
crumble=tap_count>=this.pillar.taps_to_break
if tap_count==1 then
S:queue(this.sound_events.tap)
U.animation_start(this,"tap",nil,store.tick_ts,false,1)
while not U.animation_finished(this,1,1) do
if this.ui.clicked then
goto label_pillar_tap
end
coroutine.yield()
end
elseif not crumble then
if tap_count==this.pillar.taps_to_break-1 then
S:queue(this.sound_events.pre_crumble)
else
S:queue(this.sound_events.tap)
end
U.animation_start(this,"tap_"..tap_count,nil,store.tick_ts,false,1)
while not U.animation_finished(this,1,1) do
if this.ui.clicked then
goto label_pillar_tap
end
coroutine.yield()
end
end
if crumble then
S:queue(this.sound_events.crumble)
local dmg_visuals=E:create_entity(this.pillar.explosion_t)
dmg_visuals.pos=V.vclone(this.pos)
dmg_visuals.render.sprites[1].ts=store.tick_ts
queue_insert(store,dmg_visuals)
coroutine.yield()
this.render.sprites[1].hidden=true
local holder=E:create_entity(this.pillar.holder_on_break)
holder.pos=V.vclone(this.pos)
holder.tower.terrain_style=this.pillar.terrain_style
holder.tower.default_rally_pos=this.pillar.default_rally_pos
holder.tower.holder_id=this.pillar.holder_id
holder.ui.nav_mesh_id=this.ui.nav_mesh_id
holder.tower.level=1
holder.tower.can_be_mod=false
queue_insert(store,holder)
signal.emit("tower-removed",this,holder)
U.y_wait(store,this.pillar.hit_time)
local dmg_aura=E:create_entity(this.pillar.damage_aura_t)
dmg_aura.pos=this.pillar.pillar_damage_center
queue_insert(store,dmg_aura)
local decal=E:create_entity(this.pillar.decal_t)
decal.pos=this.pillar.pillar_damage_center
queue_insert(store,decal)
break
else
U.animation_start(this,"idle_"..tap_count+1,nil,store.tick_ts,true,1)
end
end
coroutine.yield()
end
U.y_animation_wait(this)
queue_remove(store,this)
end
tt=E:register_t_hot("tower_holder_pillar_terrain_2_1_down",nil,true)
AC(tt,"pos","render","ui","sound_events","editor","main_script","editor_script")
tt.render.sprites[1].animated=true
tt.render.sprites[1].prefix="down_column_stg9Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].offset=v(0,-10)
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.pillar={}
tt.pillar.pillar_damage_center=v(0,0)
tt.pillar.default_rally_pos=v(0,0)
tt.pillar.holder_id="0"
tt.pillar.terrain_style=nil
tt.pillar.taps_to_break=3
tt.pillar.hit_time=fts(15)
tt.pillar.damage_aura_t="aura_pillar_stage_209_damage"
tt.pillar.explosion_t="fx_stage_209_pillar_thump_down"
tt.pillar.decal_t="decal_stage_209_pillar_dust"
tt.pillar.holder_on_break="tower_holder_blocked_terrain_2_1"
tt.editor.props={{"pillar.terrain_style",PT_NUMBER},{"pillar.default_rally_pos",PT_COORDS},{"pillar.holder_id",PT_STRING},{"ui.nav_mesh_id",PT_STRING},{"editor.game_mode",PT_NUMBER},{"pillar.pillar_damage_center",PT_COORDS}}
tt.editor_script.insert=tower_holder_pillar_e_insert
tt.editor_script.remove=scripts.editor_tower.remove
tt.main_script.update=tower_holder_pillar_update
tt.sound_events.tap="Stage09PillarTap"
tt.sound_events.pre_crumble="Stage09PillarPreCrumble"
tt.sound_events.crumble="Stage09PillarCrumble"
tt.ui.can_select=false
tt.ui.click_rect=r(-30,0,60,130)
tt.ui.hover_sprite_scale=vv(1.2)
tt.ui.hover_sprite_offset=v(4,12)
tt.random_min=0
tt.random_max=2
tt=E:register_t_hot("tower_holder_pillar_terrain_2_1_top","tower_holder_pillar_terrain_2_1_down",true)
tt.render.sprites[1].prefix="top_column_stg9Def"
tt.pillar.explosion_t="fx_stage_209_pillar_thump_top"
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(7)
while store.wave_group_number<4 do
coroutine.yield()
end
local cover=table.filter(store.entities,function(k,v)
return v.template_name=="decal_stage_209_entrance_cover"
end)[1]
U.y_animation_play(cover,"run",nil,store.tick_ts,1)
P:activate_path(7)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_209_entrance_cover" then
simulation:queue_remove_entity(v)
break
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
