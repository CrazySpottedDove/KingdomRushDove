local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
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
local decal_stage_02_fishing_link_insert
local decal_stage_02_fishing_link_update
local decal_stage_02_lion_king_insert
local decal_stage_02_lion_king_update
local trees_guardian_tree_insert
local trees_guardian_tree_update
decal_stage_02_fishing_link_insert=function(this,store)
local e=E:create_entity(this.entity_line)
e.pos=this.pos
e.fishing_link=this
simulation:queue_insert_entity(e)
return true
end
decal_stage_02_fishing_link_update=function(this,store)
local c=this.click_play
local line_move_cd=math.random(this.min_line_move_cd,this.max_line_move_cd)
local last_water_move_ts=store.tick_ts
local water_move_cd=math.random(this.min_water_move_cd,this.max_water_move_cd)
local last_line_move_ts=store.tick_ts
this.window_duration=math.random(this.min_window_duration,this.max_window_duration)
local started_first_wave=false
while true do
if not started_first_wave and store.wave_group_number>0 then
this.line_move=false
line_move_cd=math.random(this.min_line_move_cd,this.max_line_move_cd)
last_line_move_ts=store.tick_ts
water_move_cd=math.random(this.min_water_move_cd,this.max_water_move_cd)
last_water_move_ts=store.tick_ts
this.window_duration=math.random(this.min_window_duration,this.max_window_duration)
this.water_move=false
started_first_wave=true
end
if this.ui.clicked then
this.fish_anim=1
if store.wave_group_number>0 then
this.fish_anim=math.random(2,3)
end
this.fishing=true
U.animation_start_default(this,this.fish_animations[this.fish_anim],nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(30))
S:queue(c.clicked_sound)
U.y_animation_wait_default(this)
line_move_cd=math.random(this.min_line_move_cd,this.max_line_move_cd)
last_line_move_ts=store.tick_ts
this.ui.clicked=nil
this.fishing=false
end
if water_move_cd<store.tick_ts-last_water_move_ts then
water_move_cd=math.random(this.min_water_move_cd,this.max_water_move_cd)
last_water_move_ts=store.tick_ts
this.water_move=true
while this.water_move do
coroutine.yield()
end
end
if store.wave_group_number>0 and line_move_cd<store.tick_ts-last_line_move_ts then
this.line_move=true
U.y_animation_play(this,"rupees_notice_in",nil,store.tick_ts)
U.animation_start_default(this,"rupees_notice_loop",nil,store.tick_ts,true)
local start_ts=store.tick_ts
while true do
if this.ui.clicked then
this.fishing=true
this.fish_anim=4
U.animation_start_default(this,"rupees_notice_clicked",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(10))
S:queue(c.clicked_sound)
U.y_wait_unconditional(store,fts(30))
local gold_pos=V.v(this.pos.x+this.gold_pos_offset.x,this.pos.y+this.gold_pos_offset.y)
signal.emit("got-gold",gold_pos,this.gold_amount)
signal.emit("link-stage02",this)
U.y_animation_wait_default(this)
this.ui.clicked=nil
this.fishing=false
break
end
if store.tick_ts-start_ts>this.window_duration then
U.y_animation_play(this,"rupees_notice_out",nil,store.tick_ts)
break
end
coroutine.yield()
end
U.y_animation_wait_default(this)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
this.line_move=false
line_move_cd=math.random(this.min_line_move_cd,this.max_line_move_cd)
last_line_move_ts=store.tick_ts
water_move_cd=math.random(this.min_water_move_cd,this.max_water_move_cd)
last_water_move_ts=store.tick_ts
this.window_duration=math.random(this.min_window_duration,this.max_window_duration)
this.water_move=false
end
coroutine.yield()
end
end
decal_stage_02_lion_king_insert=function(this,store)
this.light=E:create_entity(this.entity_light)
this.light.pos=v(979,428)
simulation:queue_insert_entity(this.light)
return true
end
decal_stage_02_lion_king_update=function(this,store)
local last_change=store.tick_ts
local stick_cd=math.random(this.min_cooldown_idle,this.max_cooldown_idle)
while true do
if this.ui.clicked then
this.ui.can_click=false
this.ui.clicked=nil
S:queue(this.clicked_sound)
this.light.tween.disabled=false
this.light.tween.ts=store.tick_ts
this.light.render.sprites[1].hidden=false
U.y_animation_play_group(this,this.animation_click,nil,store.tick_ts,false,"layers")
last_change=store.tick_ts
stick_cd=math.random(this.min_cooldown_idle,this.max_cooldown_idle)
signal.emit("lion_king-stage02",this)
end
if this.ui.can_click and stick_cd<store.tick_ts-last_change then
U.y_animation_play_group(this,this.animation_idle2,nil,store.tick_ts,false,"layers")
last_change=store.tick_ts
stick_cd=math.random(this.min_cooldown_idle,this.max_cooldown_idle)
end
coroutine.yield()
end
end
trees_guardian_tree_insert=function(this,store)
return true
end
trees_guardian_tree_update=function(this,store)
local a=this.custom_attack
a.cooldown=U.frandom(a.cooldown_min,a.cooldown_max)
a.ts=store.tick_ts-a.cooldown
local is_active_on_wave=false
local function should_be_on()
local current_wave=store.wave_group_number
local current_config=this.wave_config[current_wave]
return current_config
end
local function can_shoot()
return store.tick_ts-a.ts>a.cooldown
end
U.y_animation_play_group(this,this.animation_idle_sleep,nil,store.tick_ts,false,"layers")
while true do
if is_active_on_wave then
if not should_be_on() then
U.y_animation_play_group(this,this.animation_go_to_sleep,nil,store.tick_ts,false,"layers")
U.y_animation_play_group(this,this.animation_idle_sleep,nil,store.tick_ts,false,"layers")
is_active_on_wave=false
else
if can_shoot() then
local enemies=U.find_enemies_between_range_filter_off(this.pos,a.min_range,a.max_range,a.vis_flags,a.vis_bans)
if not enemies then
SU.delay_attack(store,a,0.13333333333333333)
goto label_790_0
end
a.cooldown=U.frandom(a.cooldown_min,a.cooldown_max)
a.ts=store.tick_ts
S:queue(this.sound_pre_cast)
U.animation_start_group(this,a.animation,nil,store.tick_ts,false,"layers")
if U.y_wait_unconditional(store,a.shoot_time) then
goto label_790_0
end
S:queue(this.sound_cast)
local p=E:create_entity(a.entity)
p.pos=V.vclone(this.pos)
local ni=P:get_end_node(p.wave_pi)
p.wave_ni=ni
simulation:queue_insert_entity(p)
S:queue(this.sound_roots)
U.y_animation_wait_default(this)
end
U.animation_start_default(this,this.animation_idle_awake,nil,store.tick_ts)
U.y_wait_unconditional(store,fts(95),can_shoot())
end
elseif should_be_on() then
U.y_animation_play_group(this,this.animation_go_to_awake,nil,store.tick_ts,false,"layers")
is_active_on_wave=true or is_active_on_wave
end
::label_790_0::
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_02_elder_rune_static","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="stage_2_rapido_elder_rune_2_0117"
tt.render.sprites[1].animated=false
tt.render.sprites[1].loop=false
tt=E:register_t_hot("decal_stage_02_lion_king","decal_scripted",true)
E:add_comps(tt,"ui")
for i=1,4 do
tt.render.sprites[i]=E:clone_c("sprite")
tt.render.sprites[i].animated=true
tt.render.sprites[i].prefix="lion_king_easter_egg_layer"..i
tt.render.sprites[i].name="idle"
tt.render.sprites[i].group="layers"
end
tt.main_script.insert=decal_stage_02_lion_king_insert
tt.main_script.update=decal_stage_02_lion_king_update
tt.ui.can_click=true
tt.ui.click_rect=r(-30,-30,60,60)
tt.clicked_sound="Stage02LionKing"
tt.animation_idle="idle"
tt.animation_idle2="stick"
tt.animation_click="action"
tt.min_cooldown_idle=4
tt.max_cooldown_idle=7
tt.entity_light="decal_stage_02_lion_king_light"
tt=E:register_t_hot("decal_stage_02_veznan","decal_scripted",true)
E:add_comps(tt,"editor","editor_script")
tt.render.sprites[1].prefix="veznan_cinematic_veznan"
tt.render.sprites[1].name="idle"
tt=E:register_t_hot("decal_stage_02_fishing_link","decal_click_play",true)
tt.render.sprites[1].prefix="fishing_link"
tt.render.sprites[1].loop=true
tt.main_script.insert=decal_stage_02_fishing_link_insert
tt.main_script.update=decal_stage_02_fishing_link_update
tt.click_play.idle_animation="idle_2"
tt.click_play.click_animation="activation"
tt.click_play.play_once=true
tt.click_play.clicked_sound="Stage02LinkFishing"
tt.ui.can_click=true
tt.ui.click_rect=r(-30,-30,60,60)
tt.entity_line="decal_stage_02_fishing_link_line"
tt.entity_water_splash="decal_stage_02_fishing_link_water_splash"
tt.min_water_move_cd=3
tt.max_water_move_cd=7
tt.min_line_move_cd=60
tt.max_line_move_cd=90
tt.min_window_duration=3
tt.max_window_duration=3
tt.animation_line_move=""
tt.gold_pos_offset=v(-10,40)
tt.gold_amount=25
tt.fish_animations={"fishing_nothing","fishing_nothing","fishing_fish_or_boot","fishing_nothing","fishing_nothing"}
tt=E:register_t_hot("decal_waterfall_splash","decal_loop",true)
tt.render.sprites[1].name="stage_2_props_waterfall_splash"
tt=E:register_t_hot("decal_waterfall","decal_loop",true)
tt.render.sprites[1].name="stage_2_props_waterfall"
tt=E:register_t_hot("trees_guardian_tree","decal_scripted",true)
E:add_comps(tt,"custom_attack","cheats","editor")
tt.tree_disabled=false
tt.wave_config={true,true,true,true,true,true,true,true}
tt.custom_attack.cooldown=nil
tt.custom_attack.cooldown_min=16
tt.custom_attack.cooldown_max=16
tt.custom_attack.max_range=450
tt.custom_attack.min_range=15
tt.custom_attack.animation="attack"
tt.custom_attack.aura="trees_guardian_tree_vine_aura_decal"
tt.custom_attack.sound="ElvesPlantMissile"
tt.custom_attack.shoot_time=fts(35)
tt.custom_attack.entity="trees_guardian_tree_wave_of_roots"
tt.custom_attack.vis_flags=bor(F_RANGED)
tt.custom_attack.vis_bans=bor(F_BOSS,F_FLYING,F_FRIEND,F_HERO)
tt.render.sprites[1]=E:clone_c("sprite")
tt.render.sprites[1].prefix="Stage02TreePart2Def"
tt.render.sprites[1].name="idle_sleep"
tt.render.sprites[1].exo=true
tt.render.sprites[1].group="layers"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="Stage02TreeDef"
tt.render.sprites[2].name="idle_sleep"
tt.render.sprites[2].exo=true
tt.render.sprites[2].group="layers"
tt.render.sprites[2].sort_y_offset=-40
tt.animation_idle_sleep="idle_sleep"
tt.animation_go_to_awake="back_to_idle_awake"
tt.animation_idle_awake="idle_awake"
tt.animation_go_to_sleep="back_to_idle_sleep"
tt.main_script.insert=trees_guardian_tree_insert
tt.main_script.update=trees_guardian_tree_update
tt.editor.overrides={["render.sprites[2].name"]="idle_sleep"}
tt.cheats.buttons[1].text="TreeDecal"
tt.cheats.buttons[1].fn=function(button,store,e)
end
tt.cheats.buttons[2]=E:clone_c("cheats_text_button")
tt.cheats.buttons[2].text="TreeCD"
tt.cheats.buttons[2].fn=function(button,store,e)
e.custom_attack.ts=store.tick_ts-e.custom_attack.cooldown
end
tt.cheats.buttons[3]=E:clone_c("cheats_text_button")
tt.cheats.buttons[3].text="TreeRanges"
tt.cheats.buttons[3].fn=function(button,store,e)
for _,range in ipairs({e.custom_attack.max_range,e.custom_attack.min_range}) do
local hp=E:create_entity("decal_debug_range")
hp.pos.x,hp.pos.y=e.pos.x,e.pos.y
hp.radius=range
simulation:queue_insert_entity(hp)
end
end
tt.cheats.buttons[4]=E:clone_c("cheats_text_button")
tt.cheats.buttons[4].text="TreeONOFF"
tt.cheats.buttons[4].fn=function(button,store,e)
local current_wave=store.wave_group_number
local current_config=e.wave_config[current_wave]
e.wave_config[current_wave]=not current_config
end
tt.sound_pre_cast="Stage02GuardianTreePreCast"
tt.sound_cast="Stage02GuardianTreeCast"
tt.sound_roots="Stage02GuardianTreeRoots"
self.manual_hero_insertion=false
if store.level_mode==GAME_MODE_CAMPAIGN then
local already_passed_level=true
if not already_passed_level then
self.manual_hero_insertion=true
end
end
end
function level:load(store)
local already_passed_level=true
if not already_passed_level then
local veznan=E:create_entity("decal_stage_02_veznan")
veznan.pos=V.v(317,350)
LU.queue_insert(store,veznan)
U.animation_start_default(veznan,"idle",false,store.tick_ts,true)
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local already_passed_level=true
if not already_passed_level then
local defend_point,veznan
for _,e in pairs(store.entities) do
if e.template_name=="decal_defend_point" then
defend_point=e
break
end
end
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_02_veznan" then
veznan=e
break
end
end
local hero=LU.insert_hero_kr5(store,store.selected_team[1],V.v(30,500),store.selected_team_status[store.selected_team[1]])
local old_vo=hero.sound_events.change_rally_point
hero.sound_events.change_rally_point=nil
hero.nav_rally.new=true
hero.nav_rally.center=V.vclone(defend_point.pos)
hero.nav_rally.pos=V.vclone(hero.nav_rally.center)
signal.emit("pan-zoom-camera",0,{x=300,y=410},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,0.5)
while hero.render.sprites[1].name~="idle" do
coroutine.yield()
end
hero.sound_events.change_rally_point=old_vo
U.y_animation_play(veznan,"loopIn",true,store.tick_ts)
U.animation_start_default(veznan,"loop",true,store.tick_ts)
signal.emit("show-balloon_tutorial","LV02_VEZNAN01",false)
U.y_wait_unconditional(store,4.5)
U.y_animation_play(veznan,"loopEnd",true,store.tick_ts)
U.animation_start_default(veznan,"idle",true,store.tick_ts)
signal.emit("show-balloon_tutorial","LV02_VEZNAN02",false)
U.y_wait_unconditional(store,3.5)
local spawn_pos=V.vclone(veznan.pos)
spawn_pos.x,spawn_pos.y=spawn_pos.x+100,spawn_pos.y+5
local raelyn=LU.insert_hero_kr5(store,"hero_raelyn",spawn_pos,{xp=0,skills={ultimate=1}})
raelyn.nav_rally.center=V.vclone(raelyn.pos)
raelyn.nav_rally.pos=V.vclone(raelyn.nav_rally.center)
raelyn.spawning_in_cinematic_s2=true
S:queue("Stage02RaelynTeleport")
U.y_animation_play(raelyn,"respawn",true,store.tick_ts)
U.animation_start_default(raelyn,"idle",true,store.tick_ts,true)
raelyn.spawning_in_cinematic_s2=false
U.y_wait_unconditional(store,1)
S:queue("Stage02VeznanTeleport")
U.y_animation_play(veznan,"out",true,store.tick_ts)
veznan.render.sprites[1].hidden=true
LU.queue_remove(store,veznan)
U.y_wait_unconditional(store,1)
raelyn.render.sprites[1].flip_x=false
signal.emit("show-balloon_tutorial","LV02_RAELYN01",false)
signal.emit("hide-hero",2)
U.y_wait_unconditional(store,1.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=360},OVm(1,1.3))
U.y_wait_unconditional(store,0.5)
signal.emit("show-gui")
signal.emit("end-cinematic")
U.y_wait_unconditional(store,0.5)
signal.emit("show-hero",2)
U.y_wait_unconditional(store,1.5)
signal.emit("show-balloon_tutorial","TB_HERO2",false)
local start_ts=store.tick_ts
local hero_balloon_show=true
while store.wave_group_number<1 do
if hero_balloon_show and store.tick_ts-start_ts>5 then
signal.emit("turn-off-balloon")
hero_balloon_show=false
end
coroutine.yield()
end
if hero_balloon_show then
signal.emit("turn-off-balloon")
end
signal.emit("show-balloon_tutorial","TB_POWER3",false)
U.y_wait_unconditional(store,5)
signal.emit("turn-off-balloon")
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
