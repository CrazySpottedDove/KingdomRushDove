local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
require("lib.klua.table")
local tt
tt=E:register_t_hot("decal_stage_13_mask_1","decal",true)
tt.render.sprites[1].name="stage13_mask1"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_stage_13_mask_2","decal_stage_13_mask_1",true)
tt.render.sprites[1].name="stage13_mask2"
tt=E:register_t_hot("decal_stage_13_mask_4","decal_stage_13_mask_1",true)
tt.render.sprites[1].name="stage13_masktentacle2"
tt.render.sprites[1].z=Z_DECALS+1
tt=E:register_t_hot("decal_stage_13_glare","decal_stage_12_glare",true)
tt.render.sprites[1].prefix="stage_13_glareDef"
tt=E:register_t_hot("decal_stage_13_mask_3","decal_stage_13_mask_1",true)
tt.render.sprites[1].name="stage13_masktentacle1"
tt.render.sprites[1].z=Z_DECALS+1
end
function level:update(store)
P:add_invalid_range(3,P:get_start_node(3),P:get_start_node(3)+12)
P:add_invalid_range(4,P:get_start_node(4),P:get_start_node(4)+12)
P:add_invalid_range(6,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="2"
end)[1]
holder.tower.upgrade_to="tower_engineer_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="7"
end)[1]
holder.tower.upgrade_to="tower_engineer_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
if store.level_mode==GAME_MODE_CAMPAIGN then
end
end
return level
