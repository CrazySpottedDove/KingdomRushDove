local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local GR=require("grid_db")
require("constants")
local function fts(v)
return v/FPS
end
local decal_blocked_path
local blocked_cells={{19,36},{19,31},{19,32},{19,33},{19,34},{19,35},{20,30},{20,31},{20,32},{20,33},{20,34},{20,35},{21,30},{21,31},{21,32},{21,33},{21,34},{21,35},{22,30},{22,31},{22,32},{22,33},{22,34},{22,35},{23,30},{23,31},{23,32},{23,33},{23,34},{23,35},{24,30},{24,31},{24,32},{24,33},{24,34},{24,35},{25,30},{25,31},{25,32},{25,33},{25,34},{25,35},{26,30},{26,31},{26,32},{26,33},{26,34},{26,35},{27,30},{27,31},{27,32},{27,33},{27,34},{27,35},{28,30},{28,31},{28,32},{28,33},{28,34},{28,35},{29,30},{29,31},{29,32},{29,33},{29,34},{29,35},{30,30},{30,31},{30,32},{30,33},{30,34},{30,35},{31,30},{31,31},{31,32},{31,33},{31,34},{31,35},{25,29},{24,29},{25,29},{23,29},{22,29},{32,35},{32,34},{32,33},{32,32}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
decal_blocked_path=E:create_entity("decal_stage_05_bear_woodcutter")
decal_blocked_path.pos=V.v(512,384)
LU.queue_insert(store,decal_blocked_path)
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
function level:update(store)
local holders_blocked_start=0
for k,v in pairs(store.entities) do
if v.tower_holder and v.tower_holder.blocked then
holders_blocked_start=holders_blocked_start+1
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local holder=table.filter(store.entities,function(_,v)
return v.tower and v.tower.holder_id=="3"
end)
if #holder>0 then
holder=holder[1]
holder.render.sprites[1].z=Z_BACKGROUND+1
holder.render.sprites[2].z=Z_BACKGROUND+2
holder.ui.can_click=false
holder.tower.can_hover=false
decal_blocked_path.holder=holder
end
P:deactivate_path(4)
while store.wave_group_number<8 do
coroutine.yield()
end
while store.entities[decal_blocked_path.id]~=nil do
coroutine.yield()
end
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
P:activate_path(4)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
local holders_blocked_end=0
for k,v in pairs(store.entities) do
if v.tower_holder and v.tower_holder.blocked then
holders_blocked_end=holders_blocked_end+1
end
end
if holders_blocked_start==holders_blocked_end then
signal.emit("rubble-stage05",store)
end
end
return level
