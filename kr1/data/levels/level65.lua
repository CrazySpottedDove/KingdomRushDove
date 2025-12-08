local log=require("lib.klua.log"):new("level17")
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
local controller=LU.list_entities(store.entities,"malik_slave_controller")[1]
return controller and controller.fn_can_power(controller,store,power_id,pos) or false
end
function level:load(store)
return 
end
function level:update(store)
if store.level_mode==GAME_MODE_IRON then
coroutine.yield()
local tpl=E:get_template("hero_baby_malik")
tpl.hero.level=10
tpl.hero.skills.smash.level=3
tpl.hero.skills.fissure.level=3
local h=LU.insert_hero(store,"hero_baby_malik",store.level.locations.exits[2].pos)
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
