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
local signal=require("lib.hump.signal")
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
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,v)
return (contains and string.find(v.template_name,template_name) or v.template_name==template_name) and (not fn or fn(k,v))
end)
end
local function cow_update(this,store,script)
local eat_ts=store.tick_ts
local eat_cd=fts(math.random(5*FPS,8*FPS))
while not this.ui.clicked do
coroutine.yield()
if eat_cd<store.tick_ts-eat_ts then
local eat_cd=fts(math.random(5*FPS,8*FPS))
eat_ts=store.tick_ts
U.animation_start(this,"eat",nil,store.tick_ts,false)
end
if this.render.sprites[1].name=="eat" and U.animation_finished(this) then
U.animation_start(this,"idle",nil,store.tick_ts,true)
end
if this.ui.clicked then
S:queue(this.sound_cast)
U.y_animation_play(this,"action",nil,store.tick_ts,1)
end
end
U.animation_start(this,"idle_symbol",nil,store.tick_ts,true)
end
local function jenkins_update(this,store,script)
local taps_count=0
while true do
if this.ui.clicked then
this.ui.clicked=nil
taps_count=taps_count+1
if taps_count==3 then
S:queue(this.sound_fall)
S:queue(this.sound_enrage,{delay=fts(60)})
end
U.y_animation_play(this,"action_"..taps_count,nil,store.tick_ts,1)
if taps_count==3 then
local enraged=E:create_entity(this.enraged_aura)
enraged.pos=this.spawn_pos
enraged.path_id=2
enraged.node_id=88
queue_insert(store,enraged)
break
else
U.animation_start(this,"idle_"..taps_count+1,nil,store.tick_ts,true)
this.ui.click_rect=this.click_rects[taps_count+1]
end
end
coroutine.yield()
end
signal.emit("baby-jenkins-stage03",this)
queue_remove(store,this)
end
local function fisherman_update(this,store,script)
local bubble_ts=store.tick_ts
local tap_bubble_cd=6
local fishes_tapped=0
this.bubble=E:create_entity(this.bubble_t)
this.bubble.pos=V.vclone(this.pos)
this.bubble.render.sprites[1].ts=store.tick_ts+3
queue_insert(store,this.bubble)
U.animation_start(this.bubble,"tap",nil,store.tick_ts,1)
while fishes_tapped<5 do
if tap_bubble_cd<store.tick_ts-bubble_ts then
U.animation_start(this.bubble,"tap",nil,store.tick_ts,1)
bubble_ts=store.tick_ts
end
if this.fish_tapped then
fishes_tapped=fishes_tapped+1
this.fish_tapped=false
S:queue(this.sound_feedback)
U.animation_start(this,"action_"..fishes_tapped,nil,store.tick_ts,1)
U.y_wait(store,this.wait_sound_single)
if fishes_tapped>=3 then
S:queue(this.sound_pile)
else
S:queue(this.sound_single)
end
tap_bubble_cd=15
end
coroutine.yield()
end
this._found_all_fish=true
U.y_animation_wait(this)
signal.emit("thats-a-lot-of-fish-stage03")
signal.emit("got-gold",this.fisherman_pos,this.reward)
end
local function fish_update_editor(this,store)
while true do
this.render.sprites[1].flip_x=this.editor.flip>0
coroutine.yield()
end
return true
end
local function fish_insert(this,store,script)
this.render.sprites[1].flip_x=this.editor.flip>0
return true
end
local function fish_update(this,store,script)
local jump_ts=store.tick_ts
local jump_cd=fts(math.random(5,10)*30)
local fisherman=find_all_t(store,this.fisherman_t)[1]
while fisherman and not fisherman._found_all_fish do
if this.ui.clicked then
this.ui.clicked=nil
if not this.render.sprites[1].hidden then
local decal=E:create_entity(this.tap_t)
decal.pos.x,decal.pos.y=this.pos.x,this.pos.y
decal.render.sprites[1].ts=store.tick_ts
queue_insert(store,decal)
fisherman.fish_tapped=true
jump_ts=store.tick_ts
jump_cd=fts(math.random(15,20)*30)
this.ui.can_click=false
end
end
if jump_cd<store.tick_ts-jump_ts then
local jump_cd=fts(math.random(5,10)*30)
jump_ts=store.tick_ts
this.render.sprites[1].hidden=false
this.ui.can_click=true
U.animation_start(this,"jump",nil,store.tick_ts,false)
end
if this.render.sprites[1].name=="jump" and U.animation_finished(this) then
this.render.sprites[1].hidden=true
end
coroutine.yield()
end
U.y_animation_wait(this)
queue_remove(store,this)
end
local function jenkins_aura_update(this,store,script)
local first_hit_ts
local last_hit_ts=0
local path_ni=this.node_id
local path_spi=1
local distSq=0
last_hit_ts=store.tick_ts-this.aura.cycle_time
if this.aura.apply_delay then
last_hit_ts=last_hit_ts+this.aura.apply_delay
end
local function hit_enemies()
local targets=U.find_enemies_in_range(store,this.pos,0,this.aura.radius,this.aura.vis_flags,this.aura.vis_bans,function(v,o)
return (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates,v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates,v.template_name)) and (not this.aura.filter_source or this.aura.source_id~=v.id) and not U.has_modifiers(store,v,this.aura.mod)
end)
if targets then
for i,target in pairs(targets) do
if target and not target.health.dead and target.enemy then
queue_damage(store,SU.create_attack_damage(this,target.id,this))
local hit_fx=E:create_entity(this.hit_fx)
hit_fx.pos=V.vclone(target.pos)
hit_fx.pos.x,hit_fx.pos.y=hit_fx.pos.x+target.unit.hit_offset.x,hit_fx.pos.y+target.unit.hit_offset.y
hit_fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,hit_fx)
local new_mod=E:create_entity(this.aura.mod)
new_mod.modifier.target_id=target.id
new_mod.modifier.source_id=this.id
queue_insert(store,new_mod)
end
end
if #targets>0 then
S:queue(this.sound_hit)
end
end
end
local target_pos=P:node_pos(this.path_id,path_spi,path_ni)
local function go_back_step()
if V.veq(this.pos,target_pos) then
this.motion.arrived=true
return false
else
U.set_destination(this,target_pos)
if U.walk(this,store.tick_length) then
return false
else
U.animation_start(this,"run",nil,store.tick_ts,true)
return true
end
end
end
local function run_backwards()
distSq=V.dist2(target_pos.x,target_pos.y,this.pos.x,this.pos.y)
if distSq<25 then
path_ni=path_ni-3
target_pos=P:node_pos(this.path_id,path_spi,path_ni)
end
go_back_step()
end
while true do
if this.interrupt then
last_hit_ts=1e+99
end
if path_ni<=3 then
break
end
local skip=false
if store.tick_ts-last_hit_ts>=this.aura.cycle_time then
if this.aura.apply_duration and first_hit_ts and store.tick_ts-first_hit_ts>this.aura.apply_duration then
skip=true
else
first_hit_ts=first_hit_ts or store.tick_ts
last_hit_ts=store.tick_ts
hit_enemies()
end
end
if not skip then
run_backwards()
end
coroutine.yield()
end
queue_remove(store,this)
end
local mask_z={Z_OBJECTS_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS,Z_BACKGROUND_COVERS}
for i=1,6 do
local tt=E:register_t_hot("decal_stage_203_mask_"..i,"decal",true)
tt.render.sprites[1].name="KR6_stage_203_mask"..i
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=mask_z[i]
if i==6 then
tt.render.sprites[1].sort_y_offset=164
end
end
local tt=E:register_t_hot("decal_stage_203_water_1","decal",true)
tt.render.sprites[1].prefix="stage_203_water_1Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt=E:register_t_hot("decal_stage_203_water_2","decal",true)
tt.render.sprites[1].prefix="stage_203_water_2Def"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt=E:register_t_hot("decal_stage_203_sheep","decal_scripted",true)
AC(tt,"ui","editor","editor_script")
tt.render.sprites[1].prefix="stage_203_sheep_01Def"
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
tt=E:register_t_hot("decal_stage_203_sheep_small","decal_stage_203_sheep",true)
tt.render.sprites[1].prefix="stage_203_sheep_small_01Def"
tt.ui.click_rect=r(-12.5,-5,25,20)
tt=E:register_t_hot("decal_stage_203_cow","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage203_easter_egg_cowDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.main_script.update=cow_update
tt.sound_cast="Stage03CowAbductionCast"
tt.ui.click_rect=r(-27.5,-10,55,40)
tt=E:register_t_hot("decal_stage_203_jenkins","decal_scripted",true)
AC(tt,"ui")
tt.render.sprites[1].prefix="stage_203_jenkinsDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.main_script.update=jenkins_update
tt.sound_fall="Stage03BabyJenkinsCastPart1"
tt.sound_enrage="Stage03BabyJenkinsCastPart2"
tt.ui.click_rect=r(-165,-250,35,40)
tt.click_rects={r(-165,-250,35,40),r(-115,-230,35,40),r(-200,-230,35,40)}
tt.enraged_aura="aura_stage_203_jenkins_enraged"
tt.spawn_pos=v(360,137)
tt=E:register_t_hot("decal_stage_203_fisherman","decal_scripted",true)
tt.render.sprites[1].prefix="stage_203_fishermanDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.bubble_t="decal_stage_203_fisherman_bubble"
tt.fish_tapped=false
tt.main_script.update=fisherman_update
tt.wait_sound_single=fts(47)
tt.waits_end={fts(40),fts(40)}
tt.sound_single="Stage03FishermanSingle"
tt.sound_pile="Stage03FishermanPile"
tt.sound_feedback="Stage03FishermanCatchFishFeedback"
tt.fisherman_pos=v(975,624)
tt.reward=20
tt=E:register_t_hot("decal_stage_203_fisherman_bubble","decal",true)
tt.render.sprites[1].prefix="stage_203_fisherman_bubbleDef"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("decal_stage_203_fish_tap","decal_timed",true)
tt.render.sprites[1].prefix="stage_203_fish_tapDef"
tt.render.sprites[1].name="tap"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.timed.runs=1
tt=E:register_t_hot("decal_stage_203_fish","decal_scripted",true)
AC(tt,"ui","editor","editor_script")
tt.render.sprites[1].prefix="stage_203_fishDef"
tt.render.sprites[1].name="jump"
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.main_script.insert=fish_insert
tt.main_script.update=fish_update
tt.editor_script.update=fish_update_editor
tt.fisherman_t="decal_stage_203_fisherman"
tt.tap_t="decal_stage_203_fish_tap"
tt.ui.click_rect=r(-25,-17,50,45)
tt.editor.flip=0
tt.editor.props={{"editor.flip",PT_NUMBER}}
tt=E:register_t_hot("aura_stage_203_jenkins_enraged","aura",true)
AC(tt,"render","motion")
tt.aura.duration=1e+99
tt.aura.radius=60
tt.aura.vis_flags=bor(F_AREA)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.cycle_time=fts(5)
tt.aura.mod="mod_stage_203_jenkins_mark"
tt.render.sprites[1].prefix="stage_203_jenkins_runDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.main_script.insert=scripts.aura_apply_mod.insert
tt.main_script.update=jenkins_aura_update
tt.motion.max_speed=100
tt.damage_min=25
tt.damage_max=35
tt.damage_type=DAMAGE_TRUE
tt.hit_fx="fx_stage_203_jenkins_enraged_hit"
tt.sound_hit="BasicBodyImpact"
tt=E:register_t_hot("mod_stage_203_jenkins_mark","modifier",true)
tt.modifier.duration=3
tt.modifier.allows_duplicates=true
tt.main_script.insert=scripts.mod_track_target.insert
tt.main_script.update=scripts.mod_track_target.update
tt=E:register_t_hot("fx_stage_203_jenkins_enraged_hit","fx",true)
tt.render.sprites[1].prefix="stage_203_jenkins_hitDef"
tt.render.sprites[1].name="hit"
tt.render.sprites[1].exo=true
self.manual_hero_insertion=false
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
