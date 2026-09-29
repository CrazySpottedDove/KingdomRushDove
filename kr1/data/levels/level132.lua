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
local tt
tt=E:register_t_hot("stage_32_mask_waterfall_1","decal",true)
tt.render.sprites[1].prefix="stage_32_lava_waterfall_1Def"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("stage_32_mask_waterfall_2","stage_32_mask_waterfall_1",true)
tt.render.sprites[1].prefix="stage_32_lava_waterfall_2Def"
tt.render.sprites[1].sort_y_offset=175
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("stage_32_mask_lava_rocks","decal",true)
tt.render.sprites[1].prefix="stage_32_rockDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("stage_32_mask_fire_decals","decal",true)
tt.render.sprites[1].prefix="stage_32_lava_buffDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("stage_32_mask_heads_2","stage_32_mask_heads",true)
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("stage_32_mask_front","decal",true)
tt.render.sprites[1].prefix="stage_32_lava_shadow_dragonDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt=E:register_t_hot("controller_stage_32_lava_splash_2","controller_stage_32_lava_splash",true)
tt.mod="mod_stage_32_lava_splash_2"
tt.paths_y={[3]=560}
tt=E:register_t_hot("stage_32_mask_waterfall_3","stage_32_mask_waterfall_2",true)
tt.render.sprites[1].prefix="stage_32_lava_waterfall_3Def"
tt=E:register_t_hot("decal_achievement_saitam_stage32","decal_achievement_saitam_stage31",true)
tt.render.sprites[1].prefix="easter_egg_saitam_saitam_stage_2"
tt=E:register_t_hot("stage_32_mask_lava_bubbles","decal",true)
tt.render.sprites[1].prefix="stage_32_lava_bubbleDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=176
tt.render.sprites[1].z=Z_OBJECTS
end
function level:load(store)
return
end
function level:update(store)
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_32_boss" then
controller_boss_prefight=e
end
end
local function y_do_boss_taunt(key)
while controller_boss_prefight.current_taunt do
coroutine.yield()
end
controller_boss_prefight.do_taunt=key
while controller_boss_prefight.last_taunt~=key do
coroutine.yield()
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("pan-zoom-camera",0.5,{x=512,y=450},1.65)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
y_do_boss_taunt("LV32_BOSS_INTRO_01")
y_do_boss_taunt("LV32_BOSS_INTRO_02")
controller_boss_prefight.end_intro=true
U.y_wait_unconditional(store,1.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=533,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic",true)
else
signal.emit("pan-zoom-camera",0,{x=533,y=430},OVm(1,1.2))
controller_boss_prefight.restarted=true
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.in_bossfight=true
while not self.bossfight_ended do
coroutine.yield()
end
controller_boss_prefight.do_boss_death=true
while not controller_boss_prefight.boss_death_ended do
coroutine.yield()
end
signal.emit("hide-curtains")
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_mage_3"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="47"
end)[1]
holder.tower.upgrade_to="tower_archer_3"
coroutine.yield()
store.player_gold=starting_gold
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
