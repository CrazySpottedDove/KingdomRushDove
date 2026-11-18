local V=require("lib.klua.vector")
local LU=require("level_utils")
require("all.constants")
local INTRO_HERO_START=V.v(138,515)
local INTRO_HERO_DEST=V.v(443,489)
local level={}
function level:update(store)
if store.level_mode~=GAME_MODE_CAMPAIGN or store.restarted or main.params.skip_cutscenes then
return
end
if not store.selected_hero or #store.selected_hero==0 then
return
end
local hero
local waited=0
while not hero do
hero=store.main_hero
if not hero then
waited=waited+1
if waited>10 then
return
end
coroutine.yield()
end
end
while not store.entities[hero.id] do
coroutine.yield()
end
local vo=hero.sound_events.change_rally_point
hero.sound_events.change_rally_point=nil
hero.pos.x,hero.pos.y=INTRO_HERO_START.x,INTRO_HERO_START.y
hero.nav_grid.waypoints={V.vclone(INTRO_HERO_DEST)}
hero.nav_rally.new=true
hero.nav_rally.center=V.vclone(INTRO_HERO_DEST)
hero.nav_rally.pos=V.vclone(INTRO_HERO_DEST)
while hero.nav_rally.new and not hero.health.dead do
coroutine.yield()
end
hero.sound_events.change_rally_point=vo
while not store.waves_finished or not LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
