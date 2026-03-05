local log=require("klua.log"):new("level01")
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
U.y_wait(store,1)
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
