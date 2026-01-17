local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils_5")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:update(store)
P:add_invalid_range(1,P:get_start_node(1),P:get_start_node(1)+15)
P:add_invalid_range(3,P:get_start_node(3),P:get_start_node(3)+15)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
