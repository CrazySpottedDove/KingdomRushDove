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
local level={}
function level:init(store)
self.manual_hero_insertion=false
if store.level_mode==GAME_MODE_CAMPAIGN then
local already_passed_level=true
if not already_passed_level then
self.manual_hero_insertion=true
end
end
end
function level:load(store)
local already_passed_level=true
if not already_passed_level then
local veznan=E:create_entity("decal_stage_02_veznan")
veznan.pos=V.v(317,350)
LU.queue_insert(store,veznan)
U.animation_start_default(veznan,"idle",false,store.tick_ts,true)
end
end
function level:update(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
