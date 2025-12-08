local log=require("lib.klua.log"):new("level01")
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
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.manual_hero_insertion=true
if store.selected_hero and store.selected_hero~="hero_elves_archer" then
LU.insert_hero(store)
end
while store.wave_group_number<1 do
coroutine.yield()
end
while store.wave_group_number<2 do
coroutine.yield()
end
while store.wave_group_number<3 do
coroutine.yield()
end
while store.wave_group_number<5 do
coroutine.yield()
end
if store.selected_hero and store.selected_hero=="hero_elves_archer" then
while store.paused do
coroutine.yield()
end
log.debug("-- Move hero to the left of the screen")
local dp=store.level.locations.exits[1].pos
local hero=LU.insert_hero(store)
hero.pos=V.v(-REF_OX-50,dp.y)
hero.nav_rally.center=V.v(dp.x,dp.y)
hero.nav_rally.pos=V.vclone(hero.nav_rally.center)
end
while store.wave_group_number<6 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
end
return level
