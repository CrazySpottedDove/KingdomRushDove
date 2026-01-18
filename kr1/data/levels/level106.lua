local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local SU=require("script_utils")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(4,P:get_start_node(4),P:get_start_node(4)+12)
P:add_invalid_range(5,P:get_start_node(5),P:get_start_node(5)+12)
P:add_invalid_range(6,P:get_start_node(6),P:get_start_node(6)+9)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",0,{x=547,y=800},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local c_taunt=E:create_entity("taunts_s06_controller")
LU.queue_insert(store,c_taunt)
local pig,hole,door
for _,e in pairs(store.entities) do
if e.template_name=="decal_boss_pig_pool" then
pig=e
break
end
end
for _,e in pairs(store.entities) do
if e.template_name=="stage_06_hole" then
hole=e
break
end
end
for _,e in pairs(store.entities) do
if e.template_name=="stage_06_door" then
door=e
break
end
end
S:queue("Stage06BossPigSnore")
U.y_wait(store,1.5)
local cult_leader=E:create_entity("decal_stage_06_cult_leader")
cult_leader.pos.x,cult_leader.pos.y=630,580
LU.queue_insert(store,cult_leader)
S:queue("Stage11MydriasIllusionSummonCast",{delay=0})
S:queue("Stage06AcolyteTeleport",{delay=0.1})
U.y_animation_play(cult_leader,"cinematicspawn",nil,store.tick_ts)
U.animation_start(cult_leader,"idle",nil,store.tick_ts,true)
S:queue("Stage06BossPigWakeUp")
U.y_animation_play(pig,"to_idle",false,store.tick_ts,1)
U.animation_start(pig,"idle",false,store.tick_ts,true)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV06_CULTIST01",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV06_CULTIST02",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV06_BOSS01",false)
U.y_wait(store,3)
U.y_wait(store,1)
S:queue("Stage11MydriasIllusionSummonCast",{delay=0.4})
S:queue("Stage06AcolyteTeleport",{delay=0.7})
U.y_animation_play(cult_leader,"cinematicdespawn",nil,store.tick_ts)
LU.queue_remove(store,cult_leader)
U.y_animation_play(pig,"to_sleeping",false,store.tick_ts,1)
S:queue("Stage06BossPigSnore")
U.animation_start(pig,"sleeping",false,store.tick_ts,true)
U.y_wait(store,1)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=280},OVm(1,1.3))
signal.emit("show-gui")
signal.emit("end-cinematic")
local last_gas=store.tick_ts
local gas_cd=math.random(20,30)
local gas_anim=false
while store.wave_group_number<3 do
if gas_cd<store.tick_ts-last_gas then
U.animation_start(pig,"gases",false,store.tick_ts,1)
last_gas=store.tick_ts
gas_cd=math.random(20,30)
gas_anim=true
end
if U.animation_finished(pig) and gas_anim then
gas_anim=false
U.y_animation_play(pig,"to_sleeping",false,store.tick_ts,1)
U.animation_start(pig,"sleeping",false,store.tick_ts,true)
end
coroutine.yield()
end
while store.wave_group_number<10 do
if gas_cd<store.tick_ts-last_gas then
U.animation_start(pig,"gases",false,store.tick_ts,1)
last_gas=store.tick_ts
gas_cd=math.random(20,30)
gas_anim=true
end
if U.animation_finished(pig) and gas_anim then
gas_anim=false
U.y_animation_play(pig,"to_sleeping",false,store.tick_ts,1)
U.animation_start(pig,"sleeping",false,store.tick_ts,true)
end
coroutine.yield()
end
U.y_animation_play(pig,"to_idle",false,store.tick_ts,1)
U.animation_start(pig,"idle",false,store.tick_ts,true)
U.y_wait(store,1.6)
U.y_animation_play(pig,"horn_in",false,store.tick_ts,1)
U.animation_start(pig,"horn_loop",false,store.tick_ts,true)
S:queue(pig.sound_horn)
U.y_wait(store,fts(40))
U.y_animation_play(pig,"horn_out",false,store.tick_ts,1)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.1
shake.aura.duration=2
shake.aura.freq_factor=4
LU.queue_insert(store,shake)
U.y_wait(store,1)
U.animation_start(hole,"ability2_1",false,store.tick_ts,false,1)
S:queue("Stage06BurrowOpen")
U.y_wait(store,fts(10))
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.3
shake.aura.duration=0.4
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
U.y_animation_wait(hole,1,1)
local hole_mask
for _,e in pairs(store.entities) do
if e.template_name=="stage_06_hole_mask" then
hole_mask=e
break
end
end
hole_mask.render.sprites[1].hidden=false
U.y_animation_wait(pig,1,1)
U.animation_start(pig,"idle",false,store.tick_ts,true)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.info("finish waves")
U.y_wait(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=550,y=580},2)
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,2)
signal.emit("show-balloon_tutorial","LV06_BOSS02",false)
U.y_wait(store,3)
U.y_wait(store,1)
S:queue("Stage06BossPigJumpCinematic")
U.y_animation_play(pig,"salto",false,store.tick_ts,1)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
log.info("spawn pig boss")
local nodes=P:nearest_nodes(921,558)
local node=nodes[1]
local boss=E:create_entity("boss_pig")
boss.nav_path.pi=node[1]
boss.nav_path.spi=1
boss.nav_path.ni=node[3]+1
boss.mega_spawner=self.mega_spawner
LU.queue_insert(store,boss)
self.boss=boss
while self.boss.phase~="loop" do
coroutine.yield()
end
S:stop_group("MUSIC")
S:queue("MusicBossFight_106")
while self.boss.phase~="dead" do
coroutine.yield()
end
while self.boss.phase~="death-complete" do
coroutine.yield()
end
if not door.opened then
signal.emit("door-stage06",door)
end
U.y_wait(store,2)
signal.emit("boss_fight_end")
store.custom_game_outcome={postpone_unload=true,next_item_name="boss_fight_1_end"}
signal.emit("fade-out",1)
else
local function get_entity(name)
for _,e in pairs(store.entities) do
if e.template_name==name then
return e
end
end
return nil
end
local hole=get_entity("stage_06_hole")
U.animation_start(hole,"open",false,store.tick_ts,false,1)
local hole_mask=get_entity("stage_06_hole_mask")
hole_mask.render.sprites[1].hidden=false
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
