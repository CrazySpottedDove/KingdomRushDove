local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local SU=require("script_utils")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local blocked_cells={{42,49},{43,49},{44,49},{45,49},{46,49},{47,49},{48,49},{41,48},{42,48},{43,48},{44,48},{45,48},{46,48},{47,48},{40,47},{41,47},{42,47},{43,47},{44,47},{45,47},{46,47},{47,47},{40,46},{41,46},{42,46},{43,46},{44,46},{45,46},{46,46},{47,46},{40,45},{41,45},{42,45},{43,45},{44,45},{45,45},{46,45},{47,45},{39,44},{40,44},{41,44},{42,44},{43,44},{44,44},{45,44},{46,44},{47,44},{39,43},{40,43},{41,43},{42,43},{43,43},{44,43},{45,43},{46,43},{39,42},{40,42},{41,42},{42,42},{43,42},{44,42},{45,42},{46,42}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:init(store)
require("lib.klua.table")
local scripts=require("scripts")
local v=V.v
local r=V.r
local decal_stage_09_sheepy_easteregg_update
decal_stage_09_sheepy_easteregg_update=function(this,store)
local bridge_down=false
local function check_bridge_down()
if not bridge_down and store.wave_group_number==10 then
bridge_down=true
return true
end
return false
end
while true do
if this.ui.clicked then
this.ui.clicked=nil
S:queue("Stage09SheepyCamera")
U.animation_start_default(this,"action_"..math.random(1,3),nil,store.tick_ts)
signal.emit("sheepy_tap_achievement",1)
while not U.animation_finished_default(this) do
if check_bridge_down() then
U.y_wait_unconditional(store,fts(13))
S:queue("Stage09SheepyBridge")
U.y_animation_play(this,"bridge",true,store.tick_ts)
goto label_1416_0
end
coroutine.yield()
end
end
if check_bridge_down() then
U.y_wait_unconditional(store,fts(13))
S:queue("Stage09SheepyBridge")
U.y_animation_play(this,"bridge",true,store.tick_ts)
break
end
coroutine.yield()
end
::label_1416_0::
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_stage_09_fire","decal",true)
tt.render.sprites[1].prefix="stage_9_fireDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS+1
tt=E:register_t_hot("decal_stage_09_bridge3","decal_stage_09_bridge",true)
tt.render.sprites[1].prefix="stage_9_bridge3Def"
tt.mask_entity="decal_stage_09_bridge3_mask"
tt.mask_before=true
tt.mask_in_animation="in"
tt.mask_loop_animation="loop"
tt=E:register_t_hot("decal_stage_09_sheepy_easteregg","decal_scripted",true)
E:add_comps(tt,"ui","editor")
tt.render.sprites[1].prefix="stage_9_sheepyDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS-1
tt.main_script.update=decal_stage_09_sheepy_easteregg_update
tt.ui.click_rect=r(-20,-10,40,40)
tt=E:register_t_hot("controller_stage_09_spawn_nightmares",nil,true)
E:add_comps(tt,"editor","pos","main_script")
tt.main_script.insert=scripts.controller_stage_09_spawn_nightmares.insert
tt.main_script.update=scripts.controller_stage_09_spawn_nightmares.update
tt.wave_config={{{},{},{{duration=28,time_start=10}},{{duration=28,time_start=10}},{},{},{{duration=30,time_start=10}},{},{{duration=30,time_start=10}},{},{{duration=52,time_start=10}},{{duration=40,time_start=10}},{},{{duration=40,time_start=12}},{{duration=70,time_start=10}}},{{},{},{},{{duration=70,time_start=20}},{},{{duration=107,time_start=21}}},{{{duration=110,time_start=74},{duration=330,time_start=310}}}}
tt.entity_portal="decal_stage_09_portal"
tt.entity_aura="aura_stage_09_spawn_nightmare_convert"
tt.spawn_fx_aura="aura_stage_09_spawn_nightmare_convert_spawn_fx"
tt.entity_candles={"decal_stage_09_candle_back1","decal_stage_09_candle_back2","decal_stage_09_candle_back3","decal_stage_09_candle_front1","decal_stage_09_candle_front2","decal_stage_09_candle_front3"}
tt.entity_glows={"decal_stage_09_candle_glow_back","decal_stage_09_candle_glow_front"}
tt.path_portal="decal_stage_09_portal_path_spawn"
tt.portal_offset=v(-15,0)
tt.pos_portal=v(1048+tt.portal_offset.x,446+tt.portal_offset.y)
tt.pos_aura={v(661+tt.portal_offset.x,280+tt.portal_offset.y),v(659+tt.portal_offset.x,300+tt.portal_offset.y),v(658+tt.portal_offset.x,260+tt.portal_offset.y)}
tt.path_portal_off_delay=10
tt.sound_candles_in="Stage09NightmarePortalCandles"
tt.sound_portal_in="Stage09NightmarePortalEye"
tt=E:register_t_hot("decal_stage_09_mask","decal",true)
tt.render.sprites[1].name="T2_Stage_9_chains_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
for i=1,2 do
local bridge=E:create_entity("decal_stage_09_bridge"..i)
bridge.pos.x,bridge.pos.y=512,384
bridge.start_in_loop=true
LU.queue_insert(store,bridge)
end
if store.level_mode~=GAME_MODE_CAMPAIGN then
local bridge=E:create_entity("decal_stage_09_bridge3")
bridge.pos.x,bridge.pos.y=512,384
bridge.start_in_loop=true
LU.queue_insert(store,bridge)
end
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<10 do
coroutine.yield()
end
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.3
shake.aura.duration=1.2
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
S:queue("Stage09CultBridgeRumble")
U.y_wait_unconditional(store,1)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.6
shake.aura.duration=1
shake.aura.freq_factor=3
LU.queue_insert(store,shake)
local bridge3=E:create_entity("decal_stage_09_bridge3")
bridge3.pos.x,bridge3.pos.y=512,384
LU.queue_insert(store,bridge3)
S:queue("Stage09CultBridge")
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
for k,v in pairs(store.level.ignore_walk_backwards_paths) do
if v==1 or v==6 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
else
for k,v in pairs(store.level.ignore_walk_backwards_paths) do
if v==1 or v==6 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
