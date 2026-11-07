local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level209")
require("all.constants")
require("lib.klua.table")
local level={}
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(7)
while store.wave_group_number<4 do
coroutine.yield()
end
local cover=table.filter(store.entities,function(k,v)
return v.template_name=="decal_stage_209_entrance_cover"
end)[1]
U.y_animation_play(cover,"run",nil,store.tick_ts,1)
P:activate_path(7)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_209_entrance_cover" then
simulation:queue_remove_entity(v)
break
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
