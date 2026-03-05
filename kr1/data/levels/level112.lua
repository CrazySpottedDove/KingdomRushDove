local log=require("klua.log"):new("level12")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local SU=require("script_utils")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
P:add_invalid_range(5,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:add_invalid_range(6,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="6"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="7"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="10"
end)[1]
holder.tower.upgrade_to="tower_archer_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
