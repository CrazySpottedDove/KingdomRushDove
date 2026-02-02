local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local SU=require("script_utils")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
signal.emit("pan-zoom-camera",0,{x=620,y=512},1.8)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
local c_taunt=E:create_entity("taunts_s11_controller")
LU.queue_insert(store,c_taunt)
local cult_leader,cult_leader_chains,controller_cult_leader,controller_portal
U.y_wait(store,1.5)
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_11_cult_leader" then
cult_leader=e
elseif e.template_name=="decal_stage_11_boss_corrupted_denas_intro_chains" then
cult_leader_chains=e
elseif e.template_name=="controller_stage_11_cult_leader" then
controller_cult_leader=e
elseif e.template_name=="controller_stage_11_portal" then
controller_portal=e
end
end
signal.emit("show-balloon_tutorial","LV11_CULTIST01",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV11_CULTIST02",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=460,y=150},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store,{"enemy_stage_11_cult_leader_illusion"}) do
coroutine.yield()
end
controller_cult_leader.taunts_enabled=false
controller_portal.in_cinematic=true
controller_portal.reset_thunder_cd=true
local illusion_enemies=table.filter(store.entities,function(_,e)
return e.main_script and (e.main_script.co or e.main_script.runs>0) and (e.enemy and e.health and not e.health.dead or e.enemy and e.death_spawns or e.spawner and not e.spawner.eternal or e.picked_enemies and #e.picked_enemies>0 or e.tunnel and #e.tunnel.picked_enemies>0 or e.template_name=="enemy_stage_11_cult_leader_illusion")
end)
for _,enemy in ipairs(illusion_enemies) do
enemy.dissapear=true
end
log.info("finish waves")
U.y_wait(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=620,y=500},1.8)
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,2)
signal.emit("show-balloon_tutorial","LV11_CULTIST03",false)
U.y_wait(store,2)
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV11_CULTIST04",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
U.animation_start(cult_leader,"breakchains",nil,store.tick_ts)
S:queue("Stage11MidCinematicChainBreak")
cult_leader_chains.render.sprites[1].z=Z_OBJECTS_COVERS
U.animation_start(cult_leader_chains,"run",nil,store.tick_ts)
U.y_wait(store,fts(48))
LU.queue_remove(store,cult_leader_chains)
S:queue("Stage11MidCinematicPlatformMove")
U.y_animation_wait(cult_leader)
U.animation_start(cult_leader,"breakchainsidle",nil,store.tick_ts,true)
local denas_jump=E:create_entity("decal_stage_11_boss_corrupted_denas_intro_jump")
denas_jump.pos=V.v(735,430)
denas_jump.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,denas_jump)
S:queue("Stage11MidCinematicDenasJump")
U.y_wait(store,fts(19))
LU.queue_remove(store,denas_jump)
local corrupted_denas=E:create_entity("boss_corrupted_denas")
corrupted_denas.pos=V.v(632,512)
LU.queue_insert(store,corrupted_denas)
local denas_decal=E:create_entity("decal_boss_corrupted_denas_hit_floor")
denas_decal.pos=V.v(632,512)
denas_decal.tween.ts=store.tick_ts
LU.queue_insert(store,denas_decal)
S:queue("Stage11MidCinematicDenasJumpLand")
local denas_dust=E:create_entity("decal_boss_corrupted_denas_dust")
denas_dust.pos=V.v(632,512)
denas_dust.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,denas_dust)
U.y_wait(store,2.5)
S:queue("Stage11MidCinematicPlatformMove")
U.y_animation_play(cult_leader,"breakchainsback",nil,store.tick_ts)
cult_leader.tween.ts=store.tick_ts
cult_leader.tween.disabled=false
U.animation_start(cult_leader,"idle",nil,store.tick_ts,true)
signal.emit("pan-zoom-camera",2,{x=400,y=600},OVm(1,1.2))
U.y_wait(store,2)
local veznan=E:create_entity("decal_stage_11_veznan")
veznan.pos=V.v(113,500)
LU.queue_insert(store,veznan)
U.y_wait(store,2.4)
signal.emit("show-balloon_tutorial","LV11_VEZNAN01",false)
U.y_wait(store,3)
S:stop_group("MUSIC")
S:queue("MusicBossFight_111")
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic")
controller_cult_leader.last_taunt=store.tick_ts
controller_cult_leader.taunts_enabled=true
controller_portal.in_cinematic=false
while not corrupted_denas.health.dead or not store.waves_finished do
coroutine.yield()
end
controller_cult_leader.taunts_enabled=false
controller_portal.in_cinematic=true
controller_portal.reset_thunder_cd=true
if corrupted_denas.health.dead then
controller_cult_leader.is_denas_dead=true
signal.emit("boss_fight_end")
U.y_wait(store,2)
LU.kill_all_enemies(store,true)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=620,y=600},1.8)
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,2)
signal.emit("show-balloon_tutorial","LV11_CULTIST05_ESCAPE",false)
U.y_wait(store,3)
U.y_wait(store,0.5)
controller_cult_leader.leave=true
U.y_wait(store,3)
if store.level_difficulty==DIFFICULTY_IMPOSSIBLE then
signal.emit("no_projections_bossfight-stage11",controller_cult_leader)
end
U.y_wait(store,2)
signal.emit("fade-out",1)
end
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="5"
end)[1]
holder.tower.upgrade_to="tower_mage_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="10"
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
