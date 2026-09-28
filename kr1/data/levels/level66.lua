local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local scripts=require("scripts")
require("all.constants")
require("lib.klua.table")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_s18_roadrunner_bush_update(this,store)
local clicks=0
local required_clicks=math.random(this.required_clicks[1],this.required_clicks[2])
local shake_cooldown=math.random(this.shake_cooldown[1],this.shake_cooldown[2])
local shake_ts=store.tick_ts
while true do
if this.ui.clicked then
this.ui.clicked=nil
clicks=clicks+1
if required_clicks<=clicks then
local fx=E:create_entity("fx_roadruner_bush_explode")
fx.pos.x,fx.pos.y=this.pos.x,this.pos.y
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
local rr=E:create_entity("decal_s18_roadrunner")
rr.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(rr)
local coyo=E:create_entity("decal_s18_coyote")
coyo.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(coyo)
U.animation_start_default(coyo,"pull",nil,store.tick_ts)
U.y_wait_unconditional(store,1.9)
S:queue(coyo.sound_events.push)
U.y_animation_play(coyo,"push",nil,store.tick_ts)
U.y_ease_key(store,coyo.render.sprites[1],"alpha",255,0,0.5)
simulation:queue_remove_entity(coyo)
return
else
shake_ts=-99
S:queue(this.sound_clicked)
end
end
if shake_cooldown<store.tick_ts-shake_ts then
this.render.sprites[1].ts=store.tick_ts
shake_ts=store.tick_ts
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_s18_statue","decal",true)
AC(tt,"editor")
tt.render.sprites[1].name="stage18_statue"
tt.render.sprites[1].animated=false
tt.render.sprites[1].anchor.y=0.176056338028169
tt=E:register_t_hot("decal_s18_roadrunner_bush","decal_scripted",true)
AC(tt,"editor","ui")
tt.render.sprites[1].name="decal_s18_roadrunner_bush_shake"
tt.render.sprites[1].loop=false
tt.render.sprites[1].anchor.y=0.3
tt.main_script.update=decal_s18_roadrunner_bush_update
tt.required_clicks={3,5}
tt.shake_cooldown={3,5}
tt.sound_clicked="ElvesGnollTrailOut"
tt.ui.click_rect=r(-22,-10,44,40)
tt.ui.can_select=false
tt=E:register_t_hot("decal_s18_flag_head","decal",true)
AC(tt,"editor")
tt.render.sprites[1].name="decal_s18_flag_head"
tt=E:register_t_hot("decal_s18_boss_head","decal",true)
AC(tt,"editor")
tt.render.sprites[1].name="stage_18_head"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("taunts_s18_defeated_controller",nil,true)
AC(tt,"main_script","taunts","editor")
tt.load_file="level66_taunts"
tt.main_script.insert=scripts.taunts_controller.insert
tt.main_script.update=scripts.taunts_controller.update
tt.taunts.delay_min=10
tt.taunts.sets={}
tt.taunts.sets.left_head=CC("taunt_set")
tt.taunts.sets.left_head.end_idx=8
tt.taunts.sets.left_head.format="ELVES_ENEMY_BRAM_TAUNT_%04i"
tt.taunts.sets.left_head.decal_name="decal_s18_shoutbox"
tt.taunts.sets.left_head.pos=vec_2(727,700)
tt.taunts.sets.right_head=CC("taunt_set")
tt.taunts.sets.right_head.end_idx=8
tt.taunts.sets.right_head.format="ELVES_ENEMY_DEATH_TAUNT_%04i"
tt.taunts.sets.right_head.decal_name="decal_s18_shoutbox"
tt.taunts.sets.right_head.pos=vec_2(791,680)
local A=require("achievements")
local km=require("lib.klua.macros")
tt=E:register_t_hot("fx_roadruner_bush_explode","fx",true)
tt.render.sprites[1].name="gnollBush_explode"
tt.render.sprites[1].anchor.y=0.3548387096774194
tt=E:register_t_hot("decal_s18_roadrunner","decal_tween",true)
AC(tt,"sound_events")
tt.render.sprites[1].name="decal_s18_roadrunner_run"
tt.render.sprites[1].anchor.y=0.125
tt.pos=vec_2(464,473)
tt.sound_events.insert="ElvesRoadRunner"
tt.tween.props[1].name="offset"
tt.tween.props[1].keys={{0,vec_2(0,0)},{2.2,vec_2(-369,14)}}
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.megaspawner=LU.list_entities(store.entities,"mega_spawner")[1]
local boss=E:create_entity("eb_bram")
boss.pos=V.vclone(boss.pos_sitting)
LU.queue_insert(store,boss)
self.boss=boss
coroutine.yield()
U.y_wait_unconditional(store,1)
boss.phase_signal="welcome"
while self.boss.phase~="sitting" do
coroutine.yield()
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or select(2,LU.has_alive_enemies(store))>1 do
coroutine.yield()
end
boss.phase_signal="prebattle"
while self.boss.phase~="battle" do
coroutine.yield()
end
P:activate_path(boss.nav_path.pi)
local spawn_idx=1
while self.boss.phase~="dead" do
if boss.nav_path.ni==boss.spawn_at_nodes[spawn_idx] then
self.megaspawner.manual_wave=boss.spawn_wave_names[spawn_idx]
spawn_idx=km.zmod(spawn_idx+1,#boss.spawn_at_nodes)
end
coroutine.yield()
end
self.megaspawner.interrupt=true
while self.boss.phase~="death-complete" do
coroutine.yield()
end
U.y_wait_unconditional(store,1)
end
end
return level
