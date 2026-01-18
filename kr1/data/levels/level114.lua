local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("constants")
local function fts(v)
return v/FPS
end
local blocked_cells={{14,19},{15,19},{10,18},{11,18},{12,18},{13,18},{14,18},{15,18},{16,18},{17,18},{6,17},{7,17},{8,17},{9,17},{10,17},{11,17},{12,17},{13,17},{14,17},{15,17},{16,17},{17,17},{18,17},{19,17},{2,16},{3,16},{4,16},{5,16},{6,16},{7,16},{8,16},{9,16},{10,16},{11,16},{12,16},{13,16},{14,16},{15,16},{16,16},{17,16},{18,16},{19,16},{20,16},{2,15},{3,15},{4,15},{5,15},{6,15},{7,15},{8,15},{9,15},{10,15},{11,15}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(5)
while store.wave_group_number<10 do
coroutine.yield()
end
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_14_hidden_path" then
U.animation_start(v,"run",nil,store.tick_ts,false)
break
end
end
S:queue("Stage14NewPath")
local hidden_path_dust=E:create_entity("decal_stage_14_hidden_path_dust")
hidden_path_dust.pos=V.v(512,384)
LU.queue_insert(store,hidden_path_dust)
U.animation_start(hidden_path_dust,"run",nil,store.tick_ts)
U.y_wait(store,1)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.2
shake.aura.duration=1
shake.aura.freq_factor=4
LU.queue_insert(store,shake)
U.y_animation_wait(hidden_path_dust)
LU.queue_remove(store,hidden_path_dust)
P:activate_path(5)
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
if store.level.ignore_walk_backwards_paths then
for k,v in pairs(store.level.ignore_walk_backwards_paths) do
if v==5 or v==8 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="11"
end)[1]
holder.tower.upgrade_to="tower_ghost_lvl1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="13"
end)[1]
holder.tower.upgrade_to="tower_ghost_lvl1"
coroutine.yield()
store.player_gold=starting_gold
end
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_14_hidden_path" then
U.animation_start(v,"end",nil,store.tick_ts,false)
break
end
end
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
