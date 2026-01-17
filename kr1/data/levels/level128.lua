local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils_5")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=31
end
end
function level:load(store)
P:add_invalid_range(5,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
P:add_invalid_range(6,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
end
function level:update(store)
P:add_invalid_range(5,0,52,NF_NO_SHADOW)
P:add_invalid_range(6,0,45,NF_NO_SHADOW)
P:add_invalid_range(7,0,33,NF_NO_SHADOW)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
