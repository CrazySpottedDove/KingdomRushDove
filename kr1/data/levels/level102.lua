local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("all.storage")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
self.manual_hero_insertion=false
if store.level_mode==GAME_MODE_CAMPAIGN then
local user_data=storage:load_slot()
local already_passed_level=true
if not already_passed_level then
self.manual_hero_insertion=true
end
end
end
function level:load(store)
local user_data=storage:load_slot()
local already_passed_level=true
if not already_passed_level then
local veznan=E:create_entity("decal_stage_02_veznan")
veznan.pos=V.v(317,350)
LU.queue_insert(store,veznan)
U.animation_start(veznan,"idle",false,store.tick_ts,true)
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
local user_data=storage:load_slot()
local already_passed_level=true
if not already_passed_level then
local c_taunt=E:create_entity("taunts_s02_controller")
LU.queue_insert(store,c_taunt)
local raelyn,defend_point,veznan
for _,e in pairs(store.entities) do
if e.template_name=="decal_defend_point" then
defend_point=e
break
end
end
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_02_veznan" then
veznan=e
break
end
end
local hero=LU.insert_hero_kr5(store,store.selected_team[1],V.v(30,500),store.selected_team_status[store.selected_team[1]])
local old_vo=hero.sound_events.change_rally_point
hero.sound_events.change_rally_point=nil
hero.nav_rally.new=true
hero.nav_rally.center=V.vclone(defend_point.pos)
hero.nav_rally.pos=V.vclone(hero.nav_rally.center)
signal.emit("pan-zoom-camera",0,{x=300,y=410},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,0.5)
while hero.render.sprites[1].name~="idle" do
coroutine.yield()
end
hero.sound_events.change_rally_point=old_vo
U.y_animation_play(veznan,"loopIn",true,store.tick_ts)
U.animation_start(veznan,"loop",true,store.tick_ts)
signal.emit("show-balloon_tutorial","LV02_VEZNAN01",false)
U.y_wait(store,4.5)
U.y_animation_play(veznan,"loopEnd",true,store.tick_ts)
U.animation_start(veznan,"idle",true,store.tick_ts)
signal.emit("show-balloon_tutorial","LV02_VEZNAN02",false)
U.y_wait(store,3.5)
local spawn_pos=V.vclone(veznan.pos)
spawn_pos.x,spawn_pos.y=spawn_pos.x+100,spawn_pos.y+5
local raelyn=LU.insert_hero_kr5(store,"hero_raelyn",spawn_pos,{xp=0,skills={ultimate=1}})
raelyn.nav_rally.center=V.vclone(raelyn.pos)
raelyn.nav_rally.pos=V.vclone(raelyn.nav_rally.center)
raelyn.spawning_in_cinematic_s2=true
S:queue("Stage02RaelynTeleport")
U.y_animation_play(raelyn,"respawn",true,store.tick_ts)
U.animation_start(raelyn,"idle",true,store.tick_ts,true)
raelyn.spawning_in_cinematic_s2=false
U.y_wait(store,1)
S:queue("Stage02VeznanTeleport")
U.y_animation_play(veznan,"out",true,store.tick_ts)
veznan.render.sprites[1].hidden=true
LU.queue_remove(store,veznan)
U.y_wait(store,1)
raelyn.render.sprites[1].flip_x=false
signal.emit("show-balloon_tutorial","LV02_RAELYN01",false)
signal.emit("hide-hero",2)
U.y_wait(store,1.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=360},OVm(1,1.3))
U.y_wait(store,0.5)
signal.emit("show-gui")
signal.emit("end-cinematic")
U.y_wait(store,0.5)
signal.emit("show-hero",2)
U.y_wait(store,1.5)
signal.emit("show-balloon_tutorial","TB_HERO2",false)
local start_ts=store.tick_ts
local hero_balloon_show=true
while store.wave_group_number<1 do
if hero_balloon_show and store.tick_ts-start_ts>5 then
signal.emit("turn-off-balloon")
hero_balloon_show=false
end
coroutine.yield()
end
if hero_balloon_show then
signal.emit("turn-off-balloon")
end
signal.emit("show-balloon_tutorial","TB_POWER3",false)
U.y_wait(store,5)
signal.emit("turn-off-balloon")
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
