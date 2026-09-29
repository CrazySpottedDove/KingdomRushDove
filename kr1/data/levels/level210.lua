local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level210")
require("all.constants")
require("lib.klua.table")
local level={}
local target_random_defaults={V.v(711.3,415),V.v(418.2,157.2),V.v(74.3,450),V.v(895.3,454),V.v(644.3,142),V.v(700.3,476),V.v(963.3,253),V.v(641.3,440),V.v(843.3,282),V.v(-48.7,508),V.v(-149.7,250),V.v(817.3,169),V.v(852.3,204.7),V.v(154,583.8),V.v(504.3,158),V.v(1174.3,258),V.v(791.3,331),V.v(1090.3,397),V.v(1021.3,402),V.v(508.3,458),V.v(-48.7,550),V.v(856.3,486),V.v(8.2,487.2),V.v(435.3,461),V.v(784.3,464),V.v(479.3,486),V.v(728.2,144.7),V.v(366.3,473),V.v(556.3,487),V.v(232.3,523),V.v(341.3,509),V.v(15.7,230.5),V.v(694.3,358),V.v(269.3,492),V.v(-39.7,217),V.v(1163.3,374),V.v(585.7,173),V.v(181.3,517),V.v(313.2,222.2),V.v(156.5,193),V.v(1125.3,236),V.v(1023.3,241),V.v(955.3,462)}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
local W=require("wave_db")
local signal=require("lib.hump.signal")
local function find_all_t(template_name)
return table.filter(store.entities,function(k,v)
return v.template_name==template_name
end)
end
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_KR1 then
while store.wave_group_number<5 do
coroutine.yield()
end
local door=find_all_t("decal_stage_210_jt_door")[1]
local controller_swipe=find_all_t("controller_stage_210_jt_swipe")[1]
local controller_icicles=find_all_t("controller_stage_210_jt_icicles")[1]
S:queue("Stage10BellUnfreeze")
U.y_animation_play(door,"bell_defrost",nil,store.tick_ts,1,1)
U.animation_start(door,"idle_defrost",nil,store.tick_ts,true,1)
controller_swipe.swipe_active=true
while not store.waves_finished or LU.has_alive_enemies(store) or door.in_use do
coroutine.yield()
end
local jt_spawn=V.v(511.6,589.5)
door.in_use=true
door.boss_fight=true
controller_swipe.swipe_active=false
controller_icicles.icicles_active=false
U.y_wait(store,1.5)
S:queue("Stage10DoorOpen")
if door.ready then
U.animation_start(door,"out_boss_defrost",nil,store.tick_ts,nil,1)
else
U.animation_start(door,"out_boss",nil,store.tick_ts,nil,1)
end
U.y_wait(store,22/FPS)
local boss=E:create_entity("enemy_boss_stage_10")
boss.nav_path.pi=4
boss.nav_path.spi=1
boss.nav_path.ni=75
boss.motion.forced_waypoint=P:node_pos(4,1,75)
boss.pos=jt_spawn
U.bans_add(boss.vis,F_ALL)
simulation:queue_insert_entity(boss)
coroutine.yield()
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.y_wait(store,2.5)
boss.cinematic=true
S:queue("Stage10JTChestTaunt")
U.y_animation_play(boss,"death",nil,store.tick_ts,1,1)
door.in_use=false
controller_icicles._target_random=8
controller_icicles._target_allies=0
controller_icicles._target_enemies=0
controller_icicles.spawn_icicles=true
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=11/FPS*5
shake.aura.freq_factor=3
simulation:queue_insert_entity(shake)
S:queue("Stage10JTRoar")
U.y_animation_play(boss,"death_loop",nil,store.tick_ts,3,1)
U.animation_start(boss,"idle",nil,store.tick_ts,nil,1)
U.y_wait(store,10/FPS)
W:start_manual_wave("BOSS1")
boss.cinematic=false
coroutine.yield()
signal.emit("boss_fight_start",boss)
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.bans_remove(boss.vis,F_ALL)
while not boss.health.dead do
coroutine.yield()
end
local freeze_mods=table.filter(store.entities,function(k,v)
return v.template_name=="mod_boss_stage_10_tower_freeze"
end)
for k,m in pairs(freeze_mods) do
m.modifier.ts=0
end
signal.emit("boss_fight_end")
U.y_wait(store,3)
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
