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
local W=require("wave_db")
local decal_stage_30_door_update
local controller_stage_30_boss_spiders_update
decal_stage_30_door_update=function(this,store)
local wave_index=0
local run_this_wave=false
local wave_start_ts=store.tick_ts
local interval_index=1
local wave_config={}
local waves_mode=this.waves[store.level_mode]
local FROM=1
local TO=2
while true do
if wave_index~=store.wave_group_number or this.start_wave_boss then
wave_index=store.wave_group_number
if this.start_wave_boss then
wave_config=waves_mode.BOSS
else
wave_config=waves_mode[store.wave_group_number]
end
run_this_wave=wave_config and #wave_config>0
wave_start_ts=store.tick_ts
interval_index=1
this.start_wave_boss=false
end
if run_this_wave and store.tick_ts>=wave_start_ts+wave_config[interval_index][FROM] then
S:queue("Stage30BossfightClawOpen")
U.y_animation_play(this,this.animation_open,nil,store.tick_ts)
U.animation_start_default(this,this.animation_idle_open,nil,store.tick_ts,true)
U.y_wait_unconditional(store,wave_config[interval_index][TO]-wave_config[interval_index][FROM])
if store.level.bossfight_ended then
return
end
U.y_animation_wait_default(this)
S:queue("Stage30BossfightClawClose")
U.y_animation_play(this,this.animation_close,nil,store.tick_ts)
U.animation_start_default(this,this.animation_idle_closed,nil,store.tick_ts,true)
interval_index=interval_index+1
if interval_index>#wave_config then
run_this_wave=false
end
end
if store.level.bossfight_ended then
return
end
coroutine.yield()
end
end
controller_stage_30_boss_spiders_update=function(this,store)
local function easingJump(x)
return 1-math.cos(x*math.pi/2)
end
if store.level_difficulty==DIFFICULTY_IMPOSSIBLE then
this.wave_spawns=this.wave_spawns_impossible
end
local taunts_index=1
if not this.restarted then
U.y_animation_play(this,"walk",nil,store.tick_ts,1,this.render.sid_queen_podium)
end
U.animation_start(this,"idle",nil,store.tick_ts,true,this.render.sid_queen_podium)
local current_wave,last_wave
local start_wave_ts=store.tick_ts
while not this.do_exit do
current_wave=store.wave_group_number
if current_wave~=last_wave then
last_wave=current_wave
start_wave_ts=store.tick_ts
end
if this.do_taunt then
this.render.sprites[this.render.sid_queen_podium].runs=0
this.render.sprites[this.render.sid_queen_podium].loop=false
U.y_animation_wait(this,this.render.sid_queen_podium)
signal.emit("show-balloon_tutorial",this.do_taunt,false)
U.y_animation_play(this,"taunt",nil,store.tick_ts,1,this.render.sid_queen_podium)
U.animation_start(this,"idle",nil,store.tick_ts,true,this.render.sid_queen_podium)
this.do_taunt=nil
end
if this.wave_spawns[current_wave] then
for _,w in pairs(this.wave_spawns[current_wave]) do
if not w.done and start_wave_ts+w.delay<store.tick_ts then
w.done=true
U.animation_start(this,"ability",nil,store.tick_ts,false,this.render.sid_queen_podium)
U.y_wait_unconditional(store,fts(10))
for _,ws in pairs(w.spawns) do
local spawn=E:create_entity(this.wave_spawns_object)
spawn.pos=P:node_pos(ws.pi,ws.spi,ws.ni)
spawn.nav_path.pi=ws.pi
spawn.nav_path.spi=ws.spi
spawn.nav_path.ni=ws.ni
simulation:queue_insert_entity(spawn)
end
U.y_animation_wait(this,this.render.sid_queen_podium)
U.animation_start(this,"idle",nil,store.tick_ts,true,this.render.sid_queen_podium)
this.do_taunt="LV30_BOSS_ABILITY_0"..taunts_index
taunts_index=taunts_index+1
if taunts_index>7 then
taunts_index=1
end
end
end
end
coroutine.yield()
end
U.y_wait_unconditional(store,2.5)
S:queue("Stage30BossfightCinematic")
U.y_animation_play(this,"transform",nil,store.tick_ts,1,this.render.sid_queen_podium)
signal.emit("pan-zoom-camera",2,{x=300,y=600},1.5)
U.y_animation_play(this,"jump_in",nil,store.tick_ts,1,this.render.sid_queen_podium)
this.pos=P:node_pos(this.spawn_path,1,this.spawn_node)
this.render.sprites[this.render.sid_queen_podium].hidden=true
U.y_wait_unconditional(store,0.5)
this.render.sprites[this.render.sid_jump].hidden=false
this.render.sprites[this.render.sid_jump].sort_y_offset=-100
U.animation_start(this,"in",nil,store.tick_ts,false,this.render.sid_jump)
local start_fall_ts=store.tick_ts
local fall_duration=0.5
local fall_height=-600
while store.tick_ts<start_fall_ts+fall_duration do
local elapsed_percentage=(start_fall_ts-store.tick_ts)/fall_duration
local eased_percentage=easingJump(elapsed_percentage)
this.render.sprites[this.render.sid_jump].offset=V.v(0,fall_height-fall_height*eased_percentage)
coroutine.yield()
end
this.render.sprites[this.render.sid_jump].hidden=true
this.render.sprites[this.render.sid_smoke].hidden=false
this.render.sprites[this.render.sid_land].hidden=false
U.animation_start(this,"in",nil,store.tick_ts,false,this.render.sid_smoke)
U.y_animation_play(this,"in",nil,store.tick_ts,1,this.render.sid_land)
local boss=E:create_entity("boss_spider_queen")
boss.pos=V.vclone(this.pos)
boss.nav_path.pi=this.spawn_path
boss.nav_path.spi=1
boss.nav_path.ni=this.spawn_node
simulation:queue_insert_entity(boss)
signal.emit("hide-curtains")
coroutine.yield()
this.render.sprites[this.render.sid_land].hidden=true
U.y_wait_unconditional(store,0.3)
signal.emit("show-gui")
signal.emit("boss_fight_start_tweened",boss,0.3)
signal.emit("end-cinematic")
signal.emit("pan-zoom-camera",2,{x=300,y=430},OVm(1,1.2))
U.y_animation_wait(this,this.render.sid_smoke)
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("mask_stage_30_5","decal",true)
tt.render.sprites[1].name="stage_30_mask_05"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=0
tt=E:register_t_hot("mask_stage_30_4","decal",true)
tt.render.sprites[1].name="stage_30_mask_04"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=0
tt=E:register_t_hot("controller_stage_30_boss_spiders","decal_scripted",true)
E:add_comps(tt,"editor")
tt.main_script.update=controller_stage_30_boss_spiders_update
tt.spawn_path=1
tt.spawn_node=45
tt.render.sid_queen_podium=1
tt.wave_spawns={[3]={{delay=16,spawns={{pi=2,spi=1,ni=95}}}},[4]={{delay=3,spawns={{pi=1,spi=1,ni=78}}},{delay=7,spawns={{pi=5,spi=1,ni=55}}},{delay=43,spawns={{pi=1,spi=1,ni=78}}}},[7]={{delay=50,spawns={{pi=5,spi=1,ni=55}}}},[10]={{delay=2,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=28,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55}}}},[12]={{delay=2,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=42,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}}},[15]={{delay=2,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=15,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=45,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35},{pi=7,spi=1,ni=70},{pi=8,spi=1,ni=90}}}}}
tt.wave_spawns_impossible={[3]={{delay=16,spawns={{pi=2,spi=1,ni=95}}}},[4]={{delay=3,spawns={{pi=1,spi=1,ni=78}}},{delay=7,spawns={{pi=5,spi=1,ni=55}}},{delay=43,spawns={{pi=1,spi=1,ni=78}}},{delay=47,spawns={{pi=5,spi=1,ni=55}}}},[6]={{delay=50,spawns={{pi=2,spi=1,ni=95}}}},[7]={{delay=50,spawns={{pi=5,spi=1,ni=55}}}},[10]={{delay=2,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=28,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55}}}},[12]={{delay=2,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=42,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}}},[15]={{delay=2,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=15,spawns={{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35}}},{delay=45,spawns={{pi=1,spi=1,ni=78},{pi=5,spi=1,ni=55},{pi=7,spi=1,ni=35},{pi=8,spi=1,ni=35},{pi=7,spi=1,ni=70},{pi=8,spi=1,ni=90}}}}}
tt.wave_spawns_object="glarenwarden_thread_spawner"
tt.render.sprites[tt.render.sid_queen_podium].prefix="spiderqueen_spider_queenDef"
tt.render.sprites[tt.render.sid_queen_podium].exo=true
tt.render.sprites[tt.render.sid_queen_podium].name="walk"
tt.render.sprites[tt.render.sid_queen_podium].sort_y_offset=0
tt.render.sid_jump=2
tt.render.sprites[tt.render.sid_jump]=table.deepclone(tt.render.sprites[1])
tt.render.sprites[tt.render.sid_jump].prefix="spiderqueen_queen_assetDef"
tt.render.sprites[tt.render.sid_jump].hidden=true
tt.render.sprites[tt.render.sid_jump].name="in"
tt.render.sid_land=3
tt.render.sprites[tt.render.sid_land]=table.deepclone(tt.render.sprites[2])
tt.render.sprites[tt.render.sid_land].prefix="spiderqueen_spider_jumpDef"
tt.render.sid_smoke=4
tt.render.sprites[tt.render.sid_smoke]=table.deepclone(tt.render.sprites[2])
tt.render.sprites[tt.render.sid_smoke].prefix="spiderqueen_smokeDef"
tt=E:register_t_hot("mask_stage_30_2","decal",true)
tt.render.sprites[1].name="stage_30_mask_02"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=-112
tt=E:register_t_hot("mask_stage_30_3","decal",true)
tt.render.sprites[1].name="stage_30_mask_03"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=0
tt=E:register_t_hot("decal_stage_30_door","decal_scripted",true)
tt.render.sprites[1].prefix="stage_30_spider_doorDef"
tt.render.sprites[1].name="idle1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=100
tt.main_script.update=decal_stage_30_door_update
tt.animation_idle_open="idle2"
tt.animation_idle_closed="idle1"
tt.animation_open="open"
tt.animation_close="close"
tt.waves={{[5]={{32,42},{58,68}},[9]={{21,31},{48,58}},[11]={{10,25},{43,58}},[13]={{1,10},{18,28},{41,55}},[15]={{1,10},{18,28},{52,62}}},{{{44,52}},{{57,67}},{{0.2,10},{44,60}},{{46,60}},{{0.5,19}},{{24,34},{70,80}}},{{{155,180},{220,250}}}}
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local boss_controller
if not store.restarted then
signal.emit("pan-zoom-camera",0,{x=533,y=600},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,1)
boss_controller=E:create_entity("controller_stage_30_boss_spiders")
boss_controller.pos=V.v(512,384)
LU.queue_insert(store,boss_controller)
U.y_wait_unconditional(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_01"
U.y_wait_unconditional(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_02"
U.y_wait_unconditional(store,3.5)
boss_controller.do_taunt="LV30_BOSS_INTRO_03"
U.y_wait_unconditional(store,2.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=533,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
boss_controller=E:create_entity("controller_stage_30_boss_spiders")
boss_controller.restarted=true
boss_controller.pos=V.v(512,384)
LU.queue_insert(store,boss_controller)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("pan-zoom-camera",1.5,{x=533,y=800},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait_unconditional(store,3.5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_01"
U.y_wait_unconditional(store,5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_02"
U.y_wait_unconditional(store,5)
boss_controller.do_taunt="LV30_BOSS_PREFIGHT_03"
U.y_wait_unconditional(store,2.5)
boss_controller.do_exit=true
U.y_wait_unconditional(store,7)
S:stop_group("MUSIC")
S:queue("MusicBossFight_130")
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait_unconditional(store,4)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_IRON then
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="45"
end)[1]
holder.tower.upgrade_to="tower_sparking_geode_lvl4"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_sparking_geode_lvl4"
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
