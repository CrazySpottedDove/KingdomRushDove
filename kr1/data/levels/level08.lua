local log=require("lib.klua.log"):new("level08")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("constants")
local function fts(v)
return v/FPS
end
local level={}
function level:fn_can_power(store,power_id,pos)
local holder=LU.list_entities(store.entities,"tower_sasquash_holder")[1]
if holder then
return power_id==GUI_MODE_POWER_1 and V.is_inside(pos,holder.unfreeze_rect)
end
end
return level
