local log=require("klua.log"):new("level01")
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
local blocked_cells_1={{40,47},{41,47},{42,47},{43,47},{44,47},{40,46},{41,46},{42,46},{43,46},{44,46},{40,45},{41,45},{42,45},{43,45},{44,45},{39,44},{40,44},{41,44},{42,44},{43,44},{44,44},{39,43},{40,43},{41,43},{42,43},{43,43},{44,43},{39,42},{40,42},{41,42},{42,42},{43,42},{44,42}}
local blocked_cells_2={{43,24},{44,24},{45,24},{46,24},{47,24},{48,24},{49,24},{41,21},{42,21},{41,20},{42,20},{43,20},{44,20},{45,20},{46,20},{47,20},{40,19},{41,19},{42,19},{43,19},{44,19},{45,19},{46,19},{39,18},{40,18},{41,18},{42,18},{43,18},{44,18},{45,18},{46,18},{39,17},{40,17},{41,17},{42,17},{43,17},{44,17},{45,17},{43,16},{44,16},{45,16}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=25
end
end
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
set_terrain(blocked_cells_1,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
set_terrain(blocked_cells_2,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
for i=3,8 do
P:add_invalid_range(i,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
end
end
end
function level:update(store)
local soulcallers=table.filter(store.entities,function(_,v)
return v.template_name=="decal_stage_17_hidden_path_unlock_soulcaller"
end)
local soulcaller_up,soulcaller_down
if soulcallers[1].pos.y>soulcallers[2].pos.y then
soulcaller_up=soulcallers[1]
soulcaller_down=soulcallers[2]
else
soulcaller_up=soulcallers[2]
soulcaller_down=soulcallers[1]
end
soulcaller_up.render.sprites[1].hidden=true
soulcaller_down.render.sprites[1].hidden=true
if store.level_mode==GAME_MODE_CAMPAIGN then
local holders=table.filter(store.entities,function(_,v)
return v.tower and (v.tower.holder_id=="12" or v.tower.holder_id=="13")
end)
if #holders>0 then
for k,v in pairs(holders) do
v.render.sprites[1].z=Z_BACKGROUND+1
v.render.sprites[2].z=Z_BACKGROUND+2
v.ui.can_click=false
v.tower.can_hover=false
end
end
for i=3,8 do
P:deactivate_path(i)
end
while store.wave_group_number<5 do
coroutine.yield()
end
soulcaller_up.render.sprites[1].hidden=false
S:queue("Stage17RootSoulcallerIn")
U.y_animation_play(soulcaller_up,"revenant_in",nil,store.tick_ts)
U.animation_start(soulcaller_up,"revenant_idle",nil,store.tick_ts,true)
U.y_wait(store,1)
U.animation_start(soulcaller_up,"revenant_anim_reveal",nil,store.tick_ts,false)
U.y_wait(store,fts(16))
S:queue("Stage17VinesOut")
P:activate_path(3)
P:activate_path(4)
P:activate_path(6)
P:activate_path(7)
P:remove_invalid_range(3,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:remove_invalid_range(4,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:remove_invalid_range(6,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:remove_invalid_range(7,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
set_terrain(blocked_cells_1,bit.bor(TERRAIN_LAND))
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_17_hidden_path_1" then
U.animation_start(v,"run",nil,store.tick_ts,false)
break
end
end
U.y_animation_wait(soulcaller_up)
U.y_animation_play(soulcaller_up,"revenant_idle_02",nil,store.tick_ts)
S:queue("Stage17RootSoulcallerOut")
U.y_animation_play(soulcaller_up,"revenant_out",nil,store.tick_ts)
soulcaller_up.render.sprites[1].hidden=true
while store.wave_group_number<9 do
coroutine.yield()
end
soulcaller_down.render.sprites[1].hidden=false
S:queue("Stage17RootSoulcallerIn")
U.y_animation_play(soulcaller_down,"revenant_in",nil,store.tick_ts)
U.animation_start(soulcaller_down,"revenant_idle",nil,store.tick_ts,true)
U.y_wait(store,1)
U.animation_start(soulcaller_down,"revenant_anim_reveal",nil,store.tick_ts,false)
U.y_wait(store,fts(16))
S:queue("Stage17VinesOut")
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_17_hidden_path_2" then
U.animation_start(v,"run",nil,store.tick_ts,false)
break
end
end
U.y_animation_wait(soulcaller_down)
U.animation_start(soulcaller_down,"revenant_idle_02",nil,store.tick_ts,false)
U.y_wait(store,fts(30))
if #holders>0 then
for k,v in pairs(holders) do
v.render.sprites[1].z=Z_DECALS
v.render.sprites[2].z=Z_OBJECTS
v.ui.can_click=true
v.tower.can_hover=true
end
end
U.y_animation_wait(soulcaller_down)
S:queue("Stage17RootSoulcallerOut")
U.y_animation_play(soulcaller_down,"revenant_out",nil,store.tick_ts)
soulcaller_down.render.sprites[1].hidden=true
P:activate_path(5)
P:activate_path(8)
P:remove_invalid_range(5,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:remove_invalid_range(8,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
set_terrain(blocked_cells_2,bit.bor(TERRAIN_LAND))
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
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_17_hidden_path_1" or v.template_name=="decal_stage_17_hidden_path_2" then
v.render.sprites[1].hidden=true
end
end
set_terrain(blocked_cells_1,bit.bor(TERRAIN_LAND))
set_terrain(blocked_cells_2,bit.bor(TERRAIN_LAND))
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
for _,e in pairs(store.entities) do
if e.template_name=="tower_stage_17_weirdwood" then
signal.emit("tree-hugger-stage17",nil)
break
end
end
end
return level
