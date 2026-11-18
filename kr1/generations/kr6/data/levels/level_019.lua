local LU=require("level_utils")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local signal=require("lib.hump.signal")
local S=require("sound_db")
require("all.constants")
local level={}
local fts=U.fts
local INTRO_HERO_STARTS={V.v(-80,410),V.v(-50,396)}
local INTRO_HERO_WALK_TIME=0
local function move_to_intro_start(hero,start)
local dest=V.vclone(hero.pos)
hero.pos.x,hero.pos.y=start.x,start.y
hero.nav_rally.center=V.vclone(start)
hero.nav_rally.pos=V.vclone(start)
if hero.dragon then
hero.dragon.pos.x,hero.dragon.pos.y=start.x+hero.dragon.offset.x,start.y+hero.dragon.offset.y
end
return dest
end
level.skippable_cutscenes=true
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
if not store.restarted and not main.params.skip_cutscenes then
local hero1,black_knight,dest_hero1,headhunter,trickster,bandit
local intro_start_ts=store.tick_ts
signal.emit("pan-zoom-camera",0,{y=390,x=700},1.6)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
while not black_knight or not headhunter or not trickster or not bandit do
for _,v in pairs(store.entities) do
if not hero1 and store.selected_hero and v.template_name==store.selected_hero then
hero1=v
hero1.idle_flip.chance=0
hero1.render.sprites[1].flip_x=false
dest_hero1=move_to_intro_start(hero1,INTRO_HERO_STARTS[1])
end
if not black_knight and v.template_name=="soldier_black_knight_barracks_stage_219" then
black_knight=v
end
if not headhunter and v.template_name=="bandit_princess_blackguard" then
headhunter=v
end
if not trickster and v.template_name=="bandit_princess_bandit" then
trickster=v
end
if not bandit and v.template_name=="bandit_princess_trickster" then
bandit=v
end
if hero1 and black_knight and headhunter and trickster and bandit then
break
end
end
if not black_knight or not headhunter or not trickster or not bandit then
coroutine.yield()
end
end
local intro_heroes={}
if hero1 then
table.insert(intro_heroes,{hero=hero1,dest=dest_hero1})
end
U.animation_start(black_knight,"stun_idle",nil,store.tick_ts,true)
local move_camera_zoom=false
S:queue("Stage21IntroPrincessKidnapping")
local move_start_ts=store.tick_ts
local move_duration=8.8
local move_distance=600
local move_distance_y=30
local hh_x0,tr_x0,ba_x0=headhunter.pos.x,trickster.pos.x,bandit.pos.x
local hh_y0,tr_y0,ba_y0=headhunter.pos.y,trickster.pos.y,bandit.pos.y
while move_duration>store.tick_ts-move_start_ts do
local t=(store.tick_ts-move_start_ts)/move_duration
headhunter.pos.x=hh_x0+move_distance*t
trickster.pos.x=tr_x0+move_distance*t
bandit.pos.x=ba_x0+move_distance*t
headhunter.pos.y=hh_y0+move_distance_y*t
trickster.pos.y=tr_y0+move_distance_y*t
bandit.pos.y=ba_y0+move_distance_y*t
if store.tick_ts-move_start_ts>1 and not move_camera_zoom then
move_camera_zoom=true
signal.emit("pan-zoom-camera",5.5,{y=390,x=1000},1.8)
end
coroutine.yield()
end
headhunter.pos.x=hh_x0+move_distance
trickster.pos.x=tr_x0+move_distance
bandit.pos.x=ba_x0+move_distance
headhunter.pos.y=hh_y0+move_distance_y
trickster.pos.y=tr_y0+move_distance_y
bandit.pos.y=ba_y0+move_distance_y
LU.queue_remove(store,headhunter)
LU.queue_remove(store,trickster)
LU.queue_remove(store,bandit)
signal.emit("pan-zoom-camera",2,{y=390,x=500},1.8)
local pan_back_ts=store.tick_ts
U.y_wait(store,intro_start_ts+INTRO_HERO_WALK_TIME-store.tick_ts)
local saved_travel={}
for _,ih in ipairs(intro_heroes) do
local h=ih.hero
saved_travel[h]={h.teleport and h.teleport.disabled,h.transfer and h.transfer.disabled}
if h.teleport then
h.teleport.disabled=true
end
if h.transfer then
h.transfer.disabled=true
end
h.nav_grid.waypoints={ih.dest}
h.nav_rally.new=true
h.nav_rally.center=V.vclone(ih.dest)
h.nav_rally.pos=V.vclone(h.nav_rally.center)
ih.old_vo=table.deepclone(h.sound_events.change_rally_point)
h.sound_events.change_rally_point=nil
end
U.y_wait(store,pan_back_ts+1.5-store.tick_ts)
U.animation_start(black_knight,"stun_end",nil,store.tick_ts,false,nil,true)
U.y_wait(store,fts(20))
S:queue("Stage19IntroCinematicSirNoytHeadShake")
U.y_wait(store,fts(71))
S:queue("Stage19SirNoytRally")
U.y_wait(store,fts(50))
S:queue("Stage19IntroCinematicSirNoytShieldHit")
U.y_animation_wait(black_knight)
black_knight.idle_flip.chance=0
U.animation_start(black_knight,"idle",nil,store.tick_ts,true)
U.y_wait(store,0.5)
black_knight.render.sprites[1].flip_x=true
U.y_wait(store,0.5)
local balloon_pos=V.v(black_knight.pos.x,black_knight.pos.y+black_knight.health_bar.offset.y+15)
signal.emit("show-balloon_tutorial-pos","S19_INTRO_02",false,balloon_pos)
U.y_wait(store,3)
signal.emit("pan-zoom-camera",3,{y=390,x=400},1.3)
black_knight.idle_flip.chance=0.4
for _,ih in ipairs(intro_heroes) do
ih.hero.idle_flip.chance=0.4
end
U.y_wait(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic")
for _,ih in ipairs(intro_heroes) do
ih.hero.sound_events.change_rally_point=ih.old_vo
end
for h,s in pairs(saved_travel) do
if h.teleport then
h.teleport.disabled=s[1]
end
if h.transfer then
h.transfer.disabled=s[2]
end
end
else
signal.emit("pan-zoom-camera",0,{y=385,x=400},1.3)
for _,v in pairs(store.entities) do
if v.template_name=="bandit_princess_blackguard" or v.template_name=="bandit_princess_bandit" or v.template_name=="bandit_princess_trickster" then
LU.queue_remove(store,v)
end
end
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
