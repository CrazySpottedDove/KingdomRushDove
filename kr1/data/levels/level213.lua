local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local EXO=require("all.exoskeleton")
local GR=require("grid_db")
local V=require("lib.klua.vector")
local km=require("lib.klua.macros")
local log=require("lib.klua.log"):new("level213")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
P:deactivate_path(9)
P:deactivate_path(10)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
if store.level_mode~=GAME_MODE_CAMPAIGN then
log.debug("-- WON")
return
end
local S=require("sound_db")
local signal=require("lib.hump.signal")
local fts=function(t)
return t/30
end
U.y_wait(store,2)
S:stop_group("MUSIC")
S:queue("MusicBossFight_213")
local boss_t=E:get_template("enemy_boss_stage_213")
local start_path=11
local start_node=boss_t.path_jump_destinations[1][start_path]
local cinematic_pos=P:node_pos(start_path,1,start_node)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",1,{x=cinematic_pos.x,y=cinematic_pos.y+100},1)
U.y_wait(store,1.5)
local cinematic=E:create_entity("decal_stage_213_boss_cinematics")
cinematic.pos.x,cinematic.pos.y=cinematic_pos.x,cinematic_pos.y
cinematic.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,cinematic)
local obelisks=table.filter(store.entities,function(k,val)
return val.template_name=="tower_stage_213_sunray_obelisk"
end)
local old_z
if obelisks and #obelisks>0 then
old_z=obelisks[1].render.sprites[1].z
for k,val in pairs(obelisks) do
val.render.sprites[1].z=cinematic.render.sprites[1].z
end
end
U.y_wait(store,fts(8))
S:queue("Stage13TrollKingEntranceSlide")
U.y_wait(store,fts(58))
S:queue("Stage13TrollKingEntranceJump")
U.y_wait(store,fts(37))
S:queue("Stage13TrollKingEntranceLand")
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=0.5
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
local debris_fx=E:create_entity("fx_boss_stage_213_land")
debris_fx.pos.x,debris_fx.pos.y=512,384
debris_fx.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,debris_fx)
local land_dust=E:create_entity("decal_stage_213_boss_land_dust")
land_dust.pos.x,land_dust.pos.y=cinematic_pos.x,cinematic_pos.y-0.1
land_dust.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,land_dust)
local land_crack=E:create_entity("decal_stage_213_boss_land_cracks")
land_crack.pos.x,land_crack.pos.y=cinematic_pos.x,cinematic_pos.y
land_crack.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,land_crack)
U.y_wait(store,fts(69))
local boss=E:create_entity("enemy_boss_stage_213")
boss.pos.x,boss.pos.y=cinematic_pos.x,cinematic_pos.y
boss.nav_path.pi=start_path
boss.nav_path.spi=1
boss.nav_path.ni=start_node
LU.queue_insert(store,boss)
coroutine.yield()
for k,val in pairs(obelisks) do
val.render.sprites[1].z=old_z
end
cinematic.render.sprites[1].hidden=true
LU.queue_remove(store,cinematic)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic")
coroutine.yield()
signal.emit("boss_fight_start",boss)
local W=require("wave_db")
W:start_manual_wave("BOSS_1")
while not boss.health.dead or boss.tanking_ray do
coroutine.yield()
end
signal.emit("boss_fight_end")
local achievement_controller=table.filter(store.entities,function(k,val)
return val.template_name=="controller_stage_213_achievement"
end)
if achievement_controller[1] and not achievement_controller[1].sorcerer_died then
signal.emit("sorcerer-protection-program-stage13")
end
U.y_wait(store,3)
log.debug("-- WON")
end
return level
