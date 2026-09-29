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
local scripts=require("scripts")
local r=V.r
local log=require("lib.klua.log"):new("level127")
local controller_stage_27_platform_update
local controller_stage_27_platform_on_platform_up_event
local controller_stage_27_platform_on_platform_down_event
local controller_stage_27_platform_on_platform_destroy_event
local controller_stage_27_platform_on_cannons_event
local controller_stage_27_platform_on_taunt_event
local decal_stage_27_modes_decos_update
local decal_stage_27_beam_update
controller_stage_27_platform_update=function(this,store)
local platform,platform_bars,cannon_left,cannon_right,door_mask,cannon_c_right,cannon_c_left
print("insert controller_stage_27_platform")
for i,v in pairs(store.entities) do
if v.template_name==this.platform_t then
platform=v
end
if v.template_name==this.platform_bars_t then
platform_bars=v
end
if v.template_name==this.cannon_left_t then
cannon_left=v
end
if v.template_name==this.cannon_right_t then
cannon_right=v
end
if v.template_name==this.door_mask_t then
door_mask=v
end
if v.template_name==this.cannon_controller_t_l then
cannon_c_left=v
end
if v.template_name==this.cannon_controller_t_r then
cannon_c_right=v
end
end
cannon_c_left.cannon=cannon_left
cannon_c_right.cannon=cannon_right
S:queue(this.sound_intro)
platform.render.sprites[1].prefix="dclenanos_stage05_platform_introDef"
U.y_animation_play(platform,"intro",nil,store.tick_ts,1)
platform.render.sprites[1].prefix="dclenanos_stage05_platformDef"
U.animation_start_default(platform,"idle",nil,store.tick_ts,true)
while true do
if this.platform_up then
S:queue(this.sound_platform_up)
U.animation_start_default(platform,"raise",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(23))
platform.render.sprites[1].z=Z_DECALS
U.y_wait_unconditional(store,fts(12))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=0.3
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
simulation:queue_insert_entity(shake)
U.y_animation_wait_default(platform)
U.animation_start_default(platform,"idleopen",nil,store.tick_ts,true)
door_mask.render.sprites[1].hidden=false
this.platform_up=false
elseif this.platform_down then
S:queue(this.sound_platform_down)
door_mask.render.sprites[1].hidden=true
U.animation_start_default(platform,"lower",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(43))
platform.render.sprites[1].z=Z_BACKGROUND_COVERS
U.y_animation_wait_default(platform)
U.animation_start_default(platform,"idle",nil,store.tick_ts,true)
this.platform_down=false
elseif this.platform_destroy then
S:queue(this.sound_platform_destroy_chains)
door_mask.render.sprites[1].hidden=true
platform.render.sprites[1].z=Z_BACKGROUND_COVERS
U.animation_start_default(platform_bars,"break",nil,store.tick_ts,false)
U.animation_start_default(platform,"endfirstpart",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(120))
S:queue(this.sound_platform_destroy_impacts)
U.y_wait_unconditional(store,fts(13))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=0.6
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
U.y_wait_unconditional(store,fts(33))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.75
shake.aura.duration=0.6
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
U.y_wait_unconditional(store,fts(33))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=1
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
U.y_animation_wait_default(platform)
platform_bars.render.sprites[1].hidden=true
this.platform_destroy=false
local head_c
for i,v in ipairs(store.entities) do
if v.template_name==this.head_controller_t then
head_c=v
end
end
head_c.cannon_c_left=cannon_c_left
head_c.cannon_c_right=cannon_c_right
head_c.spawn_head=true
U.y_wait_unconditional(store,fts(1))
simulation:queue_remove_entity(platform)
simulation:queue_remove_entity(this)
elseif this.cannons_in then
S:queue(this.sound_cannon_alarm)
U.animation_start_default(platform,"risecannons",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(52))
if this.cannons_config=="both" then
local delay_between=fts(8)
cannon_c_right.shoot_cannon=true
cannon_c_right.clones_count=this.cannons_clones_count
U.y_wait_unconditional(store,delay_between)
cannon_c_left.shoot_cannon=true
cannon_c_left.clones_count=this.cannons_clones_count
elseif this.cannons_config=="left" then
cannon_c_left.shoot_cannon=true
cannon_c_left.clones_count=this.cannons_clones_count
else
cannon_c_right.shoot_cannon=true
cannon_c_right.clones_count=this.cannons_clones_count
end
U.y_animation_wait_default(platform)
U.animation_start_default(platform,"idle",nil,store.tick_ts,true)
this.cannons_in=false
elseif this.show_taunt then
local set=this.taunts.sets.fight
local taunt_id=_(string.format(set.format,this.taunt_idx))
signal.emit("show-balloon_tutorial",taunt_id,false)
U.y_animation_play(platform,"taunt"..math.random(1,2),nil,store.tick_ts,1)
U.animation_start_default(platform,"idle",nil,store.tick_ts,true)
this.show_taunt=false
end
coroutine.yield()
end
end
controller_stage_27_platform_on_platform_up_event=function(this,store,action)
log.info("EVENT: RAISE PLATFORM")
this.platform_up=true
end
controller_stage_27_platform_on_platform_down_event=function(this,store,action)
log.info("EVENT: LOWER PLATFORM")
this.platform_down=true
end
controller_stage_27_platform_on_platform_destroy_event=function(this,store,action)
log.info("EVENT: DESTROY PLATFORM")
this.platform_destroy=true
end
controller_stage_27_platform_on_cannons_event=function(this,store,action,config,clones_count)
log.info("EVENT: CANNONS - "..config)
this.cannons_in=true
this.cannons_config=config
this.cannons_clones_count=clones_count
end
controller_stage_27_platform_on_taunt_event=function(this,store,action,taunt_idx)
log.info("EVENT: TAUNT - "..taunt_idx)
this.show_taunt=true
this.taunt_idx=taunt_idx
end
decal_stage_27_modes_decos_update=function(this,store)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
S:queue("Stage09SheepyCamera")
U.y_animation_play(this,"action_"..math.random(1,3),nil,store.tick_ts,1)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
this.ui.can_click=true
end
coroutine.yield()
end
end
decal_stage_27_beam_update=function(this,store)
local taps=0
local idle_ts=store.tick_ts
local idle_cd=math.random(5,10)
local doing_idle=false
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
while true do
if taps>1 then
else
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
doing_idle=false
taps=taps+1
S:queue(this.sound_prefix..taps)
if taps==2 then
S:queue(this.sound_prefix..3,{delay=3})
end
U.y_animation_play(this,"action_"..taps,nil,store.tick_ts,1)
if taps==1 then
this.ui.can_click=true
U.animation_start_default(this,"idle_3",nil,store.tick_ts,true)
else
U.animation_start_default(this,"idle_5",nil,store.tick_ts,true)
signal.emit("workers-stage27",this)
goto label_1667_0
end
end
if doing_idle and U.animation_finished_default(this) then
doing_idle=false
if taps==0 then
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
else
U.animation_start_default(this,"idle_3",nil,store.tick_ts,true)
end
end
if not doing_idle and idle_cd<store.tick_ts-idle_ts then
doing_idle=true
if taps==0 then
U.animation_start_default(this,"idle_2",nil,store.tick_ts,false)
else
U.animation_start_default(this,"idle_4",nil,store.tick_ts,false)
end
idle_ts=store.tick_ts
idle_cd=math.random(5,10)
end
end
::label_1667_0::
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_27_modes_decos","decal_scripted",true)
E:add_comps(tt,"editor","ui")
tt.render.sprites[1].prefix="DLCstage5_deco_modosDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=decal_stage_27_modes_decos_update
tt.ui.click_rect=r(-33,60,20,20)
tt=E:register_t_hot("decal_stage_27_platform_bars","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="dclenanos_stage05_platform_barsDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt=E:register_t_hot("decal_stage_27_mask_3","decal",true)
tt.render.sprites[1].name="stage27_mask3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].hidden=true
tt=E:register_t_hot("decal_stage_27_beam","decal_scripted",true)
E:add_comps(tt,"ui","editor")
tt.render.sprites[1].prefix="DLCstage5_enanos_vigaDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.main_script.update=decal_stage_27_beam_update
tt.ui.click_rect=r(-470,200,150,60)
tt.sound_prefix="Stage27BeamWorkersTap"
tt=E:register_t_hot("decal_stage_27_mask_2","decal",true)
tt.render.sprites[1].name="stage27_mask2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_27_platform","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="dclenanos_stage05_platformDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_27_snow","decal",true)
tt.render.sprites[1].prefix="dclenanos_stage05_snowfallDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_EFFECTS
tt=E:register_t_hot("controller_stage_27_platform",nil,true)
E:add_comps(tt,"main_script","events","taunts","editor")
tt.main_script.insert=scripts.taunts_controller.insert
tt.main_script.update=controller_stage_27_platform_update
tt.platform_t="decal_stage_27_platform"
tt.platform_bars_t="decal_stage_27_platform_bars"
tt.cannon_left_t="decal_stage_27_cannon_left"
tt.cannon_right_t="decal_stage_27_cannon_right"
tt.cannon_controller_t_l="controller_stage_27_cannon_L"
tt.cannon_controller_t_r="controller_stage_27_cannon_R"
tt.head_controller_t="controller_stage_27_head"
tt.door_mask_t="decal_stage_27_mask_3"
tt.events.list[1].name="platform_up"
tt.events.list[1].on_event=controller_stage_27_platform_on_platform_up_event
tt.events.list[2]=E:clone_c("event")
tt.events.list[2].name="platform_down"
tt.events.list[2].on_event=controller_stage_27_platform_on_platform_down_event
tt.events.list[3]=E:clone_c("event")
tt.events.list[3].name="platform_destroy"
tt.events.list[3].on_event=controller_stage_27_platform_on_platform_destroy_event
tt.events.list[4]=E:clone_c("event")
tt.events.list[4].name="cannons"
tt.events.list[4].on_event=controller_stage_27_platform_on_cannons_event
tt.events.list[5]=E:clone_c("event")
tt.events.list[5].name="taunt"
tt.events.list[5].on_event=controller_stage_27_platform_on_taunt_event
tt.load_file="level101_taunts"
tt.taunts.sets={}
tt.taunts.sets.preparation=CC("taunt_set")
tt.taunts.sets.preparation.format="LV27_GRYMBEARD_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx=4
tt.taunts.sets.fight=CC("taunt_set")
tt.taunts.sets.fight.format="LV27_GRYMBEARD_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx=4
tt.sound_intro="Stage27Intro"
tt.sound_platform_up="Stage27PlatformUp"
tt.sound_platform_down="Stage27PlatformDown"
tt.sound_platform_destroy_chains="Stage27PlatformDestroyChains"
tt.sound_platform_destroy_impacts="Stage27PlatformDestroyHeadImpacts"
tt.sound_cannon_alarm="Stage27CloneCannonAlarm"
tt=E:register_t_hot("decal_stage_27_mask_5","decal",true)
tt.render.sprites[1].name="stage27_mask5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order=2
tt=E:register_t_hot("decal_stage_27_mask_4","decal",true)
tt.render.sprites[1].name="stage27_mask4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order=2
end
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(3,P:get_start_node(3),18)
P:add_invalid_range(4,P:get_start_node(4),18)
P:add_invalid_range(7,P:get_start_node(7),18)
P:add_invalid_range(5,P:get_start_node(5),45)
P:add_invalid_range(6,P:get_start_node(6),40)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",1.5,{x=600,y=700},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,9.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=600,y=700},1.5)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local head_c
for i,v in ipairs(store.entities) do
if v.template_name=="controller_stage_27_head" then
head_c=v
break
end
end
head_c.events.list[7].on_event(head_c,store,"head_destroy")
U.y_wait_unconditional(store,fts(370))
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
U.y_wait_unconditional(store,fts(70))
S:stop_group("MUSIC")
S:queue("MusicBossFight_127")
U.y_wait_unconditional(store,fts(80))
local boss
for i,v in pairs(store.entities) do
if v.template_name=="boss_grymbeard" then
boss=v
break
end
end
while not boss.bossfight_ended do
coroutine.yield()
end
if head_c.towers_stunned==0 then
signal.emit("head-stage27",nil)
end
U.y_wait_unconditional(store,fts(80))
signal.emit("boss_fight_end")
signal.emit("fade-out",1)
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="6"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="9"
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
