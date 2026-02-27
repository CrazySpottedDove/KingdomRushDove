local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=29
end
end
function level:load(store)
return
end
function level:update(store)
P:add_invalid_range(1,P:get_start_node(1),13)
P:add_invalid_range(8,P:get_start_node(8),P:get_start_node(8)+5)
P:add_invalid_range(9,P:get_start_node(9),P:get_start_node(9)+23)
if store.level_mode==GAME_MODE_CAMPAIGN then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="6"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl4"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
