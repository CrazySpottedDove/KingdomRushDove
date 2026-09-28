local log=require("lib.klua.log"):new("level15")
local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local SU=require("script_utils")
require("all.constants")
local function fts(v)
return v/FPS
end
local v=V.v
local level={}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local scripts=require("scripts")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_s15_mactans_update(this,store)
local attack_ts,cooldown=0,0
local attack_pending,attack_loop
this.phase_signal="attack"
while true do
if this.phase_signal=="attack" then
this.phase_signal=nil
attack_loop=true
attack_pending=true
attack_ts=store.tick_ts
elseif this.phase_signal=="single_attack" then
this.phase_signal=nil
attack_ts=store.tick_ts-cooldown-1
attack_loop=false
attack_pending=true
elseif this.phase_signal=="stop" then
this.phase_signal=nil
attack_loop=false
attack_pending=false
elseif this.phase_signal=="jump_out" then
this.phase_signal=nil
U.y_animation_play(this,"jumpOut",nil,store.tick_ts)
U.sprites_hide(this)
this.phase="out"
while this.phase_signal~="jump_in" do
coroutine.yield()
end
this.phase_signal=nil
U.sprites_show(this)
U.y_animation_play(this,"jumpIn",nil,store.tick_ts)
elseif this.phase_signal=="jump" then
U.y_animation_play(this,"jumpToCrystal",nil,store.tick_ts,1)
simulation:queue_remove_entity(this)
return
end
if attack_pending and cooldown<store.tick_ts-attack_ts then
this.phase="attack"
S:queue("ElvesFinalBossGemattackSpider")
U.animation_start_default(this,"attack",nil,store.tick_ts,false)
U.y_wait_unconditional(store,fts(11))
this.decal_statue.phase_signal="hit"
U.y_animation_wait_default(this)
attack_ts=store.tick_ts
cooldown=U.frandom(4,6)
attack_pending=attack_loop
end
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
this.phase="idle"
coroutine.yield()
end
end
local function decal_s15_malicia_update(this,store)
local ray=this.render.sprites[2]
local ray_duration=U.frandom(4,6)
local attack_ts,cooldown=0,0
local attack_pending,attack_loop
this.phase_signal="attack"
while true do
if this.phase_signal=="attack" then
this.phase_signal=nil
attack_loop=true
attack_pending=true
attack_ts=store.tick_ts
elseif this.phase_signal=="single_attack" then
this.phase_signal=nil
attack_ts=store.tick_ts-cooldown-1
ray_duration=2
attack_loop=false
attack_pending=true
elseif this.phase_signal=="stop" then
this.phase_signal=nil
attack_loop=false
attack_pending=false
elseif this.phase_signal=="jump" then
U.y_animation_play(this,"jumpToCrystal",nil,store.tick_ts,1,1)
simulation:queue_remove_entity(this)
return
end
if attack_pending and cooldown<store.tick_ts-attack_ts then
this.phase="attack"
S:queue("ElvesFinalBossGemattackMalicia")
ray.hidden=false
U.animation_start(this,"attack",nil,store.tick_ts,true,1)
U.y_wait_conditional(store,ray_duration,function()
return this.phase_signal=="stop"
end)
ray.hidden=true
attack_ts=store.tick_ts
cooldown=U.frandom(5,10)
ray_duration=U.frandom(4,6)
attack_pending=attack_loop
end
U.animation_start(this,"idle",nil,store.tick_ts,true,1)
this.phase="idle"
coroutine.yield()
end
end
local function decal_s15_statue_update(this,store)
while true do
if this.phase_signal=="break" then
S:queue("ElvesFinalBossGemCrystalBreak")
U.y_animation_play(this,"break",nil,store.tick_ts)
this.render.sprites[1].z=Z_DECALS
this.phase="broken"
return
elseif this.phase_signal=="hit" then
this.phase_signal=nil
U.y_animation_play(this,"hit",nil,store.tick_ts)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_s15_mactans","decal_scripted",true)
AC(tt,"editor")
tt.render.sprites[1].prefix="stage15_mactans_l1"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.y=0.09047619047619047
tt.render.sprites[2]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix="stage15_mactans_l2"
tt.main_script.update=decal_s15_mactans_update
tt=E:register_t_hot("decal_s15_malicia","decal_scripted",true)
AC(tt,"editor")
tt.render.sprites[1].prefix="stage15_malicia"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.y=0.057692307692307696
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="stage15_malicia_ray"
tt.render.sprites[2].hidden=true
tt.render.sprites[2].anchor=vec_2(0.64,0.21666666666666667)
tt.render.sprites[2].offset=vec_2(-2,57)
tt.main_script.update=decal_s15_malicia_update
tt=E:register_t_hot("decal_s15_statue","decal_scripted",true)
AC(tt,"editor")
tt.main_script.update=decal_s15_statue_update
tt.render.sprites[1].prefix="stage15_shield"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.y=0.20161290322580644
tt=E:register_t_hot("decal_s15_crystal","decal_tween",true)
AC(tt,"editor")
tt.render.sprites[1].name="stage15_crystal"
tt.render.sprites[1].animated=false
tt.tween.remove=false
tt.tween.props[1].name="offset"
tt.tween.props[1].keys={{0,vec_2(0,2)},{fts(25),vec_2(0,-2)},{fts(50),vec_2(0,2)}}
tt.tween.props[1].loop=true
tt.tween.props[1].interp="sine"
tt=E:register_t_hot("fx_s15_crystal_shine","fx",true)
tt.render.sprites[1].name="stage15_crystal_fx"
tt=E:register_t_hot("fx_s15_crystal_transformation","fx",true)
for i=1,4 do
tt.render.sprites[i]=CC("sprite")
tt.render.sprites[i].prefix="stage15_crystal_l"..i
tt.render.sprites[i].name="explosion"
end
tt=E:register_t_hot("fx_s15_white_circle","decal_tween",true)
tt.render.sprites[1].name="spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated=false
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_GUI-2
tt.tween.props[1].name="scale"
tt.tween.props[1].keys={{fts(3),vec_1(0.3)},{fts(6),vec_1(70)}}
tt.tween.props[2]=CC("tween_prop")
tt.tween.props[2].keys={{0,255},{1,255},{2,0}}
tt=E:register_t_hot("decal_s15_finished_gem","decal",true)
AC(tt,"editor")
tt.render.sprites[1].name="stage15_bossDecal_gem"
tt.render.sprites[1].anchor.y=0.22580645161290322
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_s15_finished_veznan","decal_delayed_play",true)
tt.render.sprites[1].prefix="decal_s15_finished_veznan"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor.y=0.1111111111111111
tt.delayed_play.min_delay=5
tt.delayed_play.max_delay=15
tt=E:register_t_hot("decal_s15_finished_guard","decal_delayed_sequence",true)
AC(tt,"editor")
for i=1,4 do
tt.render.sprites[i]=CC("sprite")
tt.render.sprites[i].prefix="decal_s15_finished_guard_layer"..i
tt.render.sprites[i].name="idle"
tt.render.sprites[i].anchor.y=0.12195121951219512
tt.render.sprites[i].loop=i>2
tt.render.sprites[i].hidden=i==4
end
tt.delayed_sequence.animations={"idle","blink","blink","sleep"}
tt.delayed_sequence.min_delay=5
tt.delayed_sequence.max_delay=15
tt=E:register_t_hot("decal_s15_finished_guard_flipped","decal_s15_finished_guard",true)
for i=1,4 do
tt.render.sprites[i].flip_x=true
tt.render.sprites[i].hidden=i==3
end
tt=E:register_t_hot("taunts_s15_controller",nil,true)
AC(tt,"main_script","taunts","editor")
tt.load_file="level63_taunts"
tt.main_script.insert=scripts.taunts_controller.insert
tt.main_script.update=scripts.taunts_controller.update
tt.taunts.delay_min=10
tt.taunts.sets={}
tt.taunts.sets.mactans=CC("taunt_set")
tt.taunts.sets.mactans.format="ELVES_ENEMY_MACTANS_TAUNT_%04i"
tt.taunts.sets.mactans.end_idx=8
tt.taunts.sets.mactans.decal_name="decal_s15_mactans_shoutbox"
tt.taunts.sets.mactans.pos=vec_2(453,591)
tt.taunts.sets.malicia=CC("taunt_set")
tt.taunts.sets.malicia.format="ELVES_ENEMY_MALICIA_TAUNT_%04i"
tt.taunts.sets.malicia.end_idx=8
tt.taunts.sets.malicia.decal_name="decal_s15_malicia_shoutbox"
tt.taunts.sets.malicia.pos=vec_2(653,591)
tt.taunts.sets.welcome_mactans=table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.welcome_mactans.format="ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0001"
tt.taunts.sets.welcome_malicia=table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.welcome_malicia.format="ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0002"
tt.taunts.sets.pre_mactans=table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.pre_mactans.format="ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_mactans.idxs={2,4}
tt.taunts.sets.pre_malicia=table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.pre_malicia.format="ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_malicia.idxs={1,3}
tt.taunts.sets.custom_malicia=table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.custom_malicia.format="ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
tt.taunts.sets.custom_mactans=table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.custom_mactans.format="ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
local km=require("lib.klua.macros")
tt=E:register_t_hot("decal_s15_mactans_shoutbox","decal_eb_spider_shoutbox",true)
tt.render.sprites[1].name="stage15_taunts_0004"
tt.render.sprites[2].name="stage15_taunts_0005"
tt.texts.list[1].color={247,133,102}
tt=E:register_t_hot("decal_s15_malicia_shoutbox","decal_eb_spider_shoutbox",true)
tt.render.sprites[2].name="stage15_taunts_0002"
end
function level:load(store)
self.boss_rounds={{pi=1,qty_per_egg=2,pos=v(259,469)},{pi=5,qty_per_egg=2,pos=v(524,455)},{pi=6,qty_per_egg=3,pos=v(845,394)},{pi=4,qty_per_egg=3,pos=v(567,328)}}
self.mactans_eggs={{path_id=2,pos=v(98,322),spawn_pos=v(82,266)},{path_id=3,pos=v(185,454),spawn_pos=v(287,454)},{path_id=2,pos=v(209,344),spawn_pos=v(176,298)},{path_id=2,pos=v(266,360),spawn_pos=v(240,314)},{path_id=3,pos=v(282,501),spawn_pos=v(287,454)},{path_id=3,pos=v(303,386),spawn_pos=v(326,344)},{path_id=3,pos=v(384,434),spawn_pos=v(352,395)},{path_id=7,pos=v(458,445),spawn_pos=v(452,392)},{path_id=5,pos=v(468,306),spawn_pos=v(524,328)},{path_id=5,pos=v(474,353),spawn_pos=v(524,328)},{path_id=7,pos=v(497,402),spawn_pos=v(452,392)},{path_id=5,pos=v(540,290),spawn_pos=v(584,328)},{path_id=7,pos=v(572,495),spawn_pos=v(531,450)},{path_id=5,pos=v(600,360),spawn_pos=v(646,337)},{path_id=7,pos=v(616,438),spawn_pos=v(531,450)},{path_id=6,pos=v(800,404),spawn_pos=v(852,360)},{path_id=6,pos=v(875,392),spawn_pos=v(852,360)},{path_id=6,pos=v(891,282),spawn_pos=v(950,252)},{path_id=6,pos=v(977,298),spawn_pos=v(950,252)}}
for _,egg in pairs(self.mactans_eggs) do
local pis=P:get_connected_paths(egg.path_id)
local nodes=P:nearest_nodes(egg.spawn_pos.x,egg.spawn_pos.y,pis,nil,true)
if #nodes>0 then
egg.node_pi=nodes[1][1]
egg.node_spi=nodes[1][2]
egg.node_ni=nodes[1][3]
else
log.error("stage15: node not found for egg:%s",getfulldump(egg))
end
end
end
function level:update(store)
if store.level_mode~=GAME_MODE_CAMPAIGN then
if table.contains(store.selected_hero,"hero_veznan") then
local veznan_deco=LU.list_entities(store.entities,"decal_s15_finished_veznan")[1]
LU.queue_remove(store,veznan_deco)
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
local c_taunt=E:create_entity("taunts_s15_controller")
local s_malicia=E:create_entity("decal_s15_malicia")
local s_mactans=E:create_entity("decal_s15_mactans")
local s_statue=E:create_entity("decal_s15_statue")
local s_crystal=E:create_entity("decal_s15_crystal")
LU.queue_insert(store,c_taunt)
LU.queue_insert(store,s_malicia)
LU.queue_insert(store,s_mactans)
LU.queue_insert(store,s_statue)
LU.queue_insert(store,s_crystal)
s_malicia.pos=v(579,643)
s_mactans.pos=v(482,647)
s_mactans.decal_statue=s_statue
s_statue.pos=v(544,662)
s_crystal.pos=v(544,742)
local mactans=LU.list_entities(store.entities,"enemy_mactans")[1]
mactans.mactans_deco=s_mactans
coroutine.yield()
if not store.restarted then
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=672},2)
signal.emit("hide-gui")
U.y_wait_unconditional(store,8)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
c_taunt.interrupt=true
signal.emit("hide-gui")
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",3,{x=512,y=672},2)
s_mactans.phase_signal="stop"
s_malicia.phase_signal="stop"
repeat
coroutine.yield()
until s_mactans.phase=="idle" and s_malicia.phase=="idle"
S:queue("MusicBossPreFight15")
U.y_wait_unconditional(store,3)
SU.y_show_taunt_set(store,c_taunt.taunts,"custom_malicia","BREAKING",nil,1.5,true)
U.y_wait_unconditional(store,1.5)
s_mactans.phase_signal="single_attack"
s_malicia.phase_signal="single_attack"
repeat
coroutine.yield()
until s_mactans.phase=="idle" and s_malicia.phase=="idle"
U.y_wait_unconditional(store,1.5)
s_statue.phase_signal="break"
s_crystal.tween.disabled=true
U.y_ease_keys(store,{s_crystal.pos,s_crystal.render.sprites[1].offset},{"y","y"},{s_crystal.pos.y,s_crystal.render.sprites[1].offset.y},{s_crystal.pos.y-27,0},fts(20),{"quad-in"})
while s_statue.phase~="broken" do
coroutine.yield()
end
local fx=E:create_entity("fx_s15_crystal_shine")
fx.pos.x,fx.pos.y=s_crystal.pos.x,s_crystal.pos.y
fx.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,fx)
s_mactans.phase_signal="jump"
s_malicia.phase_signal="jump"
U.y_wait_unconditional(store,fts(34))
SU.y_show_taunt_set(store,c_taunt.taunts,"custom_malicia","MINE",nil,1,false)
SU.y_show_taunt_set(store,c_taunt.taunts,"custom_mactans","MINE",nil,1,false)
U.y_wait_unconditional(store,fts(37))
fx=E:create_entity("fx_s15_crystal_transformation")
fx.pos.x,fx.pos.y=s_crystal.pos.x,s_crystal.pos.y
U.animation_start_default(fx,"explosion",nil,store.tick_ts,false)
LU.queue_insert(store,fx)
LU.queue_remove(store,s_crystal)
U.y_wait_unconditional(store,fts(100))
local circle=E:create_entity("fx_s15_white_circle")
circle.pos.x,circle.pos.y=s_crystal.pos.x,s_crystal.pos.y
circle.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,circle)
U.y_wait_unconditional(store,0.5)
local boss=E:create_entity("eb_spider")
boss.pos.x,boss.pos.y=544,643
boss.megaspawner=LU.list_entities(store.entities,"mega_spawner")[1]
LU.queue_insert(store,boss)
LU.queue_remove(store,s_statue)
while boss.phase~="fight" do
coroutine.yield()
end
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("hide-curtains")
signal.emit("show-gui")
S:queue("MusicBossFight")
while boss.phase~="death-animation" do
coroutine.yield()
end
signal.emit("hide-gui",true)
for _,e in pairs(store.entities) do
if e and e.tower then
e.tower.blocked=true
end
end
while boss.phase~="dead" do
coroutine.yield()
end
store.custom_game_outcome={next_item_name="map"}
end
log.debug("-- WON")
end
return level
