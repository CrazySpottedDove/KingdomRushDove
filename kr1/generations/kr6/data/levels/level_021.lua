local LU=require("level_utils")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local GR=require("grid_db")
local W=require("wave_db")
local signal=require("lib.hump.signal")
local log=require("lib.klua.log"):new("level221")
require("all.constants")
require("lib.klua.table")
local fts=U.fts
local HUNTER="soldier_stage_21_hunter_reinforcement"
local function spawn_hunter(store,x,y,silent)
local h=E:create_entity(HUNTER)
h.reinforcement.fade_in=false
if silent then
h.sound_events.insert=nil
end
h.pos=V.v(x,y)
simulation:queue_insert_entity(h)
return h
end
local function freeze_idle(e,flip_x)
e.idle_flip.chance=0
if flip_x~=nil then
e.render.sprites[1].flip_x=flip_x
end
end
local function set_idle_flip(units,chance)
for _,e in ipairs(units) do
e.idle_flip.chance=chance
end
end
local function move_to(e,dest)
e.nav_grid.waypoints={V.vclone(dest)}
e.nav_rally.new=true
e.nav_rally.center=V.vclone(dest)
e.nav_rally.pos=V.vclone(dest)
end
local function y_wait_arrival(store,units,threshold)
threshold=threshold or 100
local function all_arrived()
for _,e in ipairs(units) do
local c=e.nav_rally.center
if V.dist2(e.pos.x,e.pos.y,c.x,c.y)>threshold then
return false
end
end
return true
end
while not all_arrived() do
coroutine.yield()
end
end
local function silence_rally_vo(units)
local saved={}
for _,e in ipairs(units) do
saved[e]=e.sound_events.change_rally_point
e.sound_events.change_rally_point=nil
end
return function()
for e,vo in pairs(saved) do
e.sound_events.change_rally_point=vo
end
end
end
local function y_find_entity(store,template_name)
while true do
for _,e in pairs(store.entities) do
if e.template_name==template_name then
return e
end
end
coroutine.yield()
end
end
local function park_at(e,x,y)
e.pos=V.v(x,y)
e.nav_rally.center=V.v(x,y)
e.nav_rally.pos=V.v(x,y)
end
local function place_hunter_at(store,x,y,silent)
local h=spawn_hunter(store,x,y,silent)
h.nav_rally.center=V.v(x,y)
h.nav_rally.pos=V.v(x,y)
return h
end
local WAVE6_HUNTERS_MAX_WAIT=6
local WAVE6_ANGRY_RELEASE_DIST=20
local STAGE_21_WAVE6_HUNTERS={{delay=0,start={y=-30,x=620},dest={y=250,x=645}},{delay=0.4,start={y=-30,x=600},dest={y=210,x=620}},{delay=0.5,start={y=-30,x=650},dest={y=210,x=670}}}
local function update_wave6_hunters(store,pending)
local t=store.tick_ts-pending.ts
local list=STAGE_21_WAVE6_HUNTERS
while pending.next<=#list and t>=list[pending.next].delay do
local h=list[pending.next]
local e=spawn_hunter(store,h.start.x,h.start.y,true)
table.insert(pending.restore_vo,silence_rally_vo({e}))
move_to(e,V.v(h.dest.x,h.dest.y))
table.insert(pending.hunters,e)
pending.next=pending.next+1
end
if pending.next<=#list then
return false
end
local timeout=t>WAVE6_HUNTERS_MAX_WAIT
local function all_within(dist)
for _,e in ipairs(pending.hunters) do
local c=e.nav_rally.center
if V.dist2(e.pos.x,e.pos.y,c.x,c.y)>dist*dist then
return false
end
end
return true
end
local throne=pending.throne
if throne and not pending.angry_released and (timeout or all_within(WAVE6_ANGRY_RELEASE_DIST)) then
pending.angry_released=true
throne._angry_release=true
throne._hold_idle=nil
end
local done=timeout or all_within(10)
if done then
for _,restore in ipairs(pending.restore_vo) do
restore()
end
end
return done
end
local function spawn_stage_21_wave6_hunters(store)
local pending={next=1,ts=store.tick_ts,hunters={},restore_vo={}}
update_wave6_hunters(store,pending)
return pending
end
local CINE_CAM_TIME=1.5
local CINE_PIP_TO_EXPLOSION=fts(106)
local CINE_EXPLOSION_TO_HUNTERS={intro=fts(95),wave6=fts(112)}
local CINE_FIRST_IMPACT=fts(22)
local INTRO_CAM_POS={y=470,x=360}
local INTRO_CAM_ZOOM=1.3
local INTRO_END_CAM_POS={y=450,x=400}
local PRINCESS_CAM_POS={y=485,x=655}
local PRINCESS_CAM_ZOOM=1.45
local PRINCESS_CAM_PAN={y=18,x=58}
local PRINCESS_CAM_PAN_DELAY=0.5
local PRINCESS_SPEED=60
local PRINCESS_DOOR={y=558,x=830}
local PRINCESS_TEMPLATES={"bandit_princess_trickster","bandit_princess_bandit","bandit_princess_blackguard_stage_221"}
local PRINCESS_CAPTIVES={hold=1,pos={y=699,x=1039},delay=fts(14),time=fts(93),cam_pos={y=500,x=850}}
PRINCESS_CAPTIVES.total=PRINCESS_CAPTIVES.delay+PRINCESS_CAPTIVES.time+PRINCESS_CAPTIVES.hold
local HEROES_ARRIVE_AFTER_CAM=0.8
local INTRO_ESCORT_SPACING=50
local INTRO_CLIMBERS_TO_KINGPIN=0.5
local INTRO_KINGPIN_CAM_POS={y=580,x=850}
local INTRO_KINGPIN_CAM_ZOOM=1.3
local INTRO_KINGPIN_MAX_WAIT=6
local INTRO_KINGPIN_TAUNT_TIME=3
local WAVE6_CAM_POS={y=300,x=760}
local WAVE6_CAM_ZOOM=1.2
local WAVE6_PIP_DELAY=fts(56)
local CINE_MASKS={intro={{frame=29,hide={"decal_stage_221_2_puerta"}},{frame=63,hide={"decal_stage_221_3_campamento","decal_stage_221_bandit_horse","decal_stage_221_shadowblade_sitting","decal_stage_221_6"}},{frame=87,hide={"decal_stage_221_4_campamento","decal_stage_221_bandit_fire_1","decal_stage_221_cuerdaropa_bandit"}}},wave6={{frame=51,hide={"decal_stage_221_medio_camp","decal_stage_221_bandit_recostado","decal_stage_221_10","decal_stage_221_15","decal_stage_221_8_spawner_2","decal_stage_221_9"},show={"decal_defense_flag","decal_defend_point"}},{frame=79,hide={"decal_stage_221_1_medio_camp_2","decal_stage_221_horse_1","decal_stage_221_horse_2","decal_stage_221_shadowblade_blackguard","decal_stage_221_16_spawner_7"}}}}
local CINE_SCARED={intro={lead=fts(60),templates={"decal_stage_221_bandit_fire_1","decal_stage_221_bandit_horse","decal_stage_221_shadowblade_sitting"}},wave6={lead=fts(31),templates={"decal_stage_221_bandit_fire_2","decal_stage_221_bandit_recostado","decal_stage_221_horse_1","decal_stage_221_horse_2","decal_stage_221_shadowblade_blackguard"}}}
local CINE_SHAKES={intro={{duration=0.35,amplitude=1,t=fts(22)},{duration=0.5,amplitude=1.4,t=fts(54)},{duration=0.3,amplitude=0.85,t=fts(67)},{duration=0.4,amplitude=1.1,t=fts(75)}},wave6={{duration=0.25,amplitude=0.85,t=fts(39)},{duration=0.25,amplitude=0.85,t=fts(46)},{duration=0.35,amplitude=1,t=fts(53)},{duration=0.5,amplitude=1.4,t=fts(71)},{duration=0.4,amplitude=1.1,t=fts(84)}}}
local CINE_MASK_FADE_TIME=0.1
local CINE_FADE_TEMPLATES={decal_stage_221_4_campamento=true,decal_stage_221_2_puerta=true,decal_stage_221_horse_2=true,decal_stage_221_1_medio_camp_2=true,decal_stage_221_3_campamento=true,decal_stage_221_medio_camp=true}
local CINE_HOLDERS={intro={{frame=23,pos={y=538,x=102}},{frame=55,pos={y=505,x=405}},{frame=57,pos={y=383,x=299}},{frame=68,pos={y=605,x=559}},{frame=81,pos={y=547,x=311}}},wave6={{frame=40,pos={y=229,x=539}},{frame=54,pos={y=204,x=753}},{frame=54,pos={y=288,x=472}},{frame=72,pos={y=203,x=915}},{frame=74,pos={y=306,x=579}},{frame=86,pos={y=363,x=844}}}}
local function run_due_calls(store,start_ts,calls)
local pending=false
for _,c in ipairs(calls) do
if not c.done then
if store.tick_ts-start_ts>=c.t then
c.done=true
c.fn()
else
pending=true
end
end
end
return not pending
end
function PRINCESS_CAPTIVES.spawn(store,play_in)
local e=E:create_entity("decal_stage_221_princess_captives")
e.pos=V.v(PRINCESS_CAPTIVES.pos.x,PRINCESS_CAPTIVES.pos.y)
e.play_in=play_in
simulation:queue_insert_entity(e)
return e
end
function PRINCESS_CAPTIVES.y_play(store,start_ts,calls)
local function run_calls()
run_due_calls(store,start_ts,calls)
end
signal.emit("pan-zoom-camera",CINE_CAM_TIME,PRINCESS_CAPTIVES.cam_pos,PRINCESS_CAM_ZOOM)
U.y_wait(store,PRINCESS_CAPTIVES.delay,run_calls)
PRINCESS_CAPTIVES.spawn(store,true)
U.y_wait(store,PRINCESS_CAPTIVES.time+PRINCESS_CAPTIVES.hold,run_calls)
end
local function princesses_walk_time(princesses)
local t=0
for _,e in ipairs(princesses) do
t=math.max(t,V.dist(e.pos.x,e.pos.y,PRINCESS_DOOR.x,PRINCESS_DOOR.y)/PRINCESS_SPEED)
end
return t
end
local function y_princesses_to_fortress(store,princesses,start_ts,calls)
local walking={}
for _,e in ipairs(princesses) do
table.insert(walking,e)
end
while #walking>0 do
run_due_calls(store,start_ts,calls)
local step=PRINCESS_SPEED*store.tick_length
for i=#walking,1,-1 do
local e=walking[i]
local dx,dy=PRINCESS_DOOR.x-e.pos.x,PRINCESS_DOOR.y-e.pos.y
local d=math.sqrt(dx*dx+dy*dy)
if d<=step then
simulation:queue_remove_entity(e)
table.remove(walking,i)
else
e.pos.x,e.pos.y=e.pos.x+dx/d*step,e.pos.y+dy/d*step
end
end
coroutine.yield()
end
end
local function y_cine_bombing(store,cine,on_last,no_curtains)
local pip=E:create_entity("fx_stage_221_cine_pip")
pip.over_curtains=not no_curtains
simulation:queue_insert_entity(pip)
local scared=CINE_SCARED[cine]
local lead=scared and scared.lead or 0
U.y_wait(store,CINE_PIP_TO_EXPLOSION-lead)
if scared then
local scare={}
for _,t in ipairs(scared.templates) do
scare[t]=true
end
for _,e in pairs(store.entities) do
if scare[e.template_name] then
e.scared=true
end
end
U.y_wait(store,lead)
end
local steps=CINE_MASKS[cine]
local calls={}
for _,step in ipairs(steps) do
local hide={}
for _,t in ipairs(step.hide) do
hide[t]=true
end
local show={}
for _,t in ipairs(step.show or {}) do
show[t]=true
end
local show_targets={}
for _,e in pairs(store.entities) do
if show[e.template_name] and e.show_at_wave and e.render.sprites[1].hidden then
e._cine_show=true
table.insert(show_targets,e)
end
end
table.insert(calls,{t=fts(step.frame-1),fn=function()
for _,e in ipairs(show_targets) do
U.sprites_show(e)
end
local fade=E:create_entity("fx_stage_221_mask_fade")
fade.fade_time=CINE_MASK_FADE_TIME
fade.targets={}
for _,e in pairs(store.entities) do
if hide[e.template_name] then
if CINE_FADE_TEMPLATES[e.template_name] then
table.insert(fade.targets,e)
else
U.sprites_hide(e)
end
end
end
simulation:queue_insert_entity(fade)
end})
end
table.insert(calls,{t=fts(steps[#steps].frame-1)+CINE_MASK_FADE_TIME,fn=function()
on_last()
end})
for _,h in ipairs(CINE_HOLDERS[cine] or {}) do
for _,e in pairs(store.entities) do
if e.tower and e.tower.type=="holder" and e.show_at_wave and V.dist2(e.pos.x,e.pos.y,h.pos.x,h.pos.y)<4 then
e._cine_show=true
table.insert(calls,{t=fts(h.frame-1),fn=function()
U.sprites_show(e,1,1)
e.ui.can_click=true
e.tower.can_hover=true
end})
end
end
end
local fx=E:create_entity("fx_stage_221_cine_explosion")
fx.render.sprites[1].prefix="stage_221_cine_explosion_"..cine.."Def"
fx.calls=calls
fx.shakes=CINE_SHAKES[cine]
simulation:queue_insert_entity(fx)
end
local function load_grid(store,name)
if not GR:load_file(LU.resolve_level_file(store,name,"_grid.lua")) then
log.error("no se pudo cargar el grid \"%s\"",name)
return false
end
GR.waypoints_cache={}
return true
end
local function y_wave6_transition(store,controller,cinematic)
store.send_next_wave=false
local pending
if cinematic then
signal.emit("hide-gui")
signal.emit("start-cinematic")
local throne=LU.list_entities(store.entities,"decal_stage_221_boss_throne")[1]
if throne then
throne._hold_idle=true
end
signal.emit("pan-zoom-camera",CINE_CAM_TIME,WAVE6_CAM_POS,WAVE6_CAM_ZOOM)
U.y_wait(store,WAVE6_PIP_DELAY)
y_cine_bombing(store,"wave6",function()
controller.visibility_wave=6
end,true)
local gate_break=fts(CINE_MASKS.wave6[1].frame-1)
U.y_wait(store,gate_break)
if throne then
throne._angry_queued=true
end
U.y_wait(store,CINE_EXPLOSION_TO_HUNTERS.wave6-gate_break)
pending=spawn_stage_21_wave6_hunters(store)
pending.throne=throne
signal.emit("pan-zoom-camera",CINE_CAM_TIME,{y=384,x=512},1)
signal.emit("show-gui")
signal.emit("end-cinematic")
else
controller.visibility_wave=6
for _,h in ipairs(STAGE_21_WAVE6_HUNTERS) do
place_hunter_at(store,h.dest.x,h.dest.y)
end
end
return pending
end
local WATCHTOWER_TEMPLATES={"enemy_shadow_archer_watchtower","enemy_crow_alchemist_watchtower"}
local function release_wave5_watchtowers(store,controller)
if store.wave_group_number~=5 then
return
end
local waiting=false
for _,name in pairs(store.wait_signal_handlers or {}) do
if name=="all_enemies_died" then
waiting=true
end
end
if not waiting then
return
end
if not LU.has_alive_enemies(store) or LU.has_alive_enemies(store,WATCHTOWER_TEMPLATES) then
return
end
if controller.spawn_queue and #controller.spawn_queue>0 then
return
end
for _,e in pairs(store.entities) do
if e.trapdoor_spawn then
return
end
end
for _,e in pairs(store.entities) do
if table.contains(WATCHTOWER_TEMPLATES,e.template_name) and e.health and not e.health.dead then
if e.timeout_fx then
local fx=E:create_entity(e.timeout_fx)
fx.pos.x,fx.pos.y=e.pos.x,e.pos.y
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
end
simulation:queue_remove_entity(e)
end
end
end
local function wave5_finished(store,controller)
local nw=store.next_wave_group_ready
if store.wave_group_number~=5 or not nw or nw.group_idx~=6 then
return false
end
if LU.has_alive_enemies(store) then
return false
end
if controller.spawn_queue and #controller.spawn_queue>0 then
return false
end
for _,e in pairs(store.entities) do
if e.trapdoor_spawn then
return false
end
end
return true
end
local BOSS_CAM_TIME=1
local BOSS_CAM_POS={y=500,x=720}
local BOSS_CAM_ZOOM=1.5
local BOSS_CAM_DEFAULT_POS={y=384,x=512}
local BOSS_BALLOON_POS=V.v(900,610)
local BOSS_TENT_POS=V.v(594,400)
local BOSS2_BAR_FILL_TIME=1
local BOSS_BAR_FADE_TIME=0.3
local BOSS_BOMB_POS=V.v(762,460)
local BOSS_PI=19
local MODE_PATHS={20,21,22,23}
local NO_FLAG_PATHS={17,18}
local BOSS_CART_POS=V.v(776,479)
local function boss_bar_view()
local ok,gg=pcall(require,"game_gui")
return ok and gg and gg.window and gg.window:ci("boss_health_bar") or nil
end
local function y_boss_bar_fade(store,from,to,duration)
local bar=boss_bar_view()
if not bar then
return
end
local ts=store.tick_ts
while duration>store.tick_ts-ts do
bar.alpha=from+(to-from)*(store.tick_ts-ts)/duration
coroutine.yield()
end
bar.alpha=to
end
local level={}
level.skippable_cutscenes=true
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
for _,pi in ipairs(NO_FLAG_PATHS) do
W.db.flags_visibility[pi]={false,false,false}
end
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(6)
P:deactivate_path(BOSS_PI)
for _,pi in ipairs(MODE_PATHS) do
P:deactivate_path(pi)
end
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("pan-zoom-camera",0,PRINCESS_CAM_POS,PRINCESS_CAM_ZOOM)
signal.emit("hide-gui")
signal.emit("start-cinematic")
local controller=y_find_entity(store,"controller_stage_221")
local throne=y_find_entity(store,"decal_stage_221_boss_throne")
throne._hold_idle=true
local princesses={}
for _,t in ipairs(PRINCESS_TEMPLATES) do
table.insert(princesses,y_find_entity(store,t))
end
local entrance,marches={},{}
for i=1,2 do
local hero=(i==1) and store.main_hero or nil
local home=hero and V.v(hero.pos.x,hero.pos.y) or V.vclone(store.level.custom_spawn_pos[i].pos)
if hero then
park_at(hero,-150,home.y+100)
table.insert(entrance,hero)
end
local escort=place_hunter_at(store,-150,home.y+100,true)
table.insert(entrance,escort)
table.insert(marches,{hero=hero,home=home,escort=escort,escort_dest=V.v(home.x-70,home.y+30)})
end
for _,e in ipairs(entrance) do
freeze_idle(e,false)
end
local restore_entrance_vo=silence_rally_vo(entrance)
coroutine.yield()
local scene_ts=store.tick_ts
local scene_time=princesses_walk_time(princesses)
S:queue("Stage21IntroPrincessKidnapping")
local arrive_t=scene_time+PRINCESS_CAPTIVES.total+CINE_CAM_TIME+HEROES_ARRIVE_AFTER_CAM
local calls={{t=PRINCESS_CAM_PAN_DELAY,fn=function()
signal.emit("pan-zoom-camera",scene_time-PRINCESS_CAM_PAN_DELAY,{x=PRINCESS_CAM_POS.x+PRINCESS_CAM_PAN.x,y=PRINCESS_CAM_POS.y+PRINCESS_CAM_PAN.y},PRINCESS_CAM_ZOOM)
end}}
local function walk_time(e,dest)
return V.dist(e.pos.x,e.pos.y,dest.x,dest.y)/e.motion.max_speed
end
for _,m in ipairs(marches) do
local hero,escort=m.hero,m.escort
local escort_t=arrive_t-walk_time(escort,m.escort_dest)
if hero then
local hero_t=arrive_t-walk_time(hero,m.home)
escort_t=math.max(escort_t,hero_t+INTRO_ESCORT_SPACING/hero.motion.max_speed)
table.insert(calls,{t=hero_t,fn=function()
move_to(hero,m.home)
end})
end
table.insert(calls,{t=escort_t,fn=function()
move_to(escort,m.escort_dest)
end})
end
y_princesses_to_fortress(store,princesses,scene_ts,calls)
PRINCESS_CAPTIVES.y_play(store,scene_ts,calls)
local march_center=V.v(0,0)
for _,m in ipairs(marches) do
march_center.x=march_center.x+(m.home.x+m.escort_dest.x)/(2*#marches)
march_center.y=march_center.y+(m.home.y+m.escort_dest.y)/(2*#marches)
end
signal.emit("pan-zoom-camera",CINE_CAM_TIME,march_center,PRINCESS_CAM_ZOOM)
while not run_due_calls(store,scene_ts,calls) do
coroutine.yield()
end
y_wait_arrival(store,entrance)
signal.emit("pan-zoom-camera",CINE_CAM_TIME,INTRO_CAM_POS,INTRO_CAM_ZOOM)
y_cine_bombing(store,"intro",function()
controller.visibility_wave=1
end,true)
U.y_wait(store,CINE_FIRST_IMPACT)
throne._angry_queued=true
U.y_wait(store,CINE_EXPLOSION_TO_HUNTERS.intro-CINE_FIRST_IMPACT)
local hunter3=spawn_hunter(store,280,800,true)
local hunter4=spawn_hunter(store,220,800,true)
local climbers={hunter3,hunter4}
for _,e in ipairs(climbers) do
freeze_idle(e)
end
local restore_climber_vo=silence_rally_vo(climbers)
move_to(hunter3,V.v(400,575))
move_to(hunter4,V.v(450,600))
U.y_wait(store,INTRO_CLIMBERS_TO_KINGPIN)
signal.emit("pan-zoom-camera",CINE_CAM_TIME,INTRO_KINGPIN_CAM_POS,INTRO_KINGPIN_CAM_ZOOM)
U.y_wait(store,CINE_CAM_TIME)
signal.emit("show-balloon_tutorial-pos","S21_INTRO_01",false,V.vclone(BOSS_BALLOON_POS))
U.y_wait(store,INTRO_KINGPIN_TAUNT_TIME)
throne._angry_release=true
U.y_wait(store,INTRO_KINGPIN_MAX_WAIT,function()
return throne._angry_done
end)
throne._hold_idle=nil
set_idle_flip(entrance,0.4)
set_idle_flip(climbers,0.4)
restore_entrance_vo()
restore_climber_vo()
signal.emit("pan-zoom-camera",CINE_CAM_TIME,INTRO_END_CAM_POS,1)
signal.emit("show-gui")
signal.emit("end-cinematic")
else
local controller=y_find_entity(store,"controller_stage_221")
for i=1,2 do
local hero=(i==1) and store.main_hero or nil
local home=hero and hero.pos or store.level.custom_spawn_pos[i].pos
place_hunter_at(store,home.x-70,home.y+30)
end
place_hunter_at(store,400,575)
place_hunter_at(store,450,600)
for _,t in ipairs(PRINCESS_TEMPLATES) do
simulation:queue_remove_entity(y_find_entity(store,t))
end
PRINCESS_CAPTIVES.spawn(store,false)
controller.visibility_wave=1
end
local controller=y_find_entity(store,"controller_stage_221")
local wave6_done,wave6_flags_pending=false,false
local wave6_hunters
while not store.waves_finished or LU.has_alive_enemies(store) do
if not wave6_done then
release_wave5_watchtowers(store,controller)
end
if not wave6_done and (wave5_finished(store,controller) or store.wave_group_number>=6) then
wave6_done,wave6_flags_pending=true,true
local cinematic=not main.params.skip_cutscenes
wave6_hunters=y_wave6_transition(store,controller,cinematic)
end
if wave6_flags_pending and controller._wave6_open then
wave6_flags_pending=false
local nw=store.next_wave_group_ready
if nw and nw.group_idx==6 then
signal.emit("next-wave-ready",nw)
end
end
if wave6_hunters and update_wave6_hunters(store,wave6_hunters) then
wave6_hunters=nil
end
coroutine.yield()
end
U.y_wait(store,2)
local throne,esclavos,camino_boss
for _,e in pairs(store.entities) do
if e.template_name=="decal_stage_221_boss_throne" then
throne=e
elseif e.template_name=="decal_stage_221_esclavos" then
esclavos=e
elseif e.template_name=="decal_stage221_7_camino_boss" then
camino_boss=e
elseif e.template_name=="decal_stage_221_spawner" then
e.render.sprites[1].hidden=true
end
end
local cinematic=not main.params.skip_cutscenes
if cinematic then
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",BOSS_CAM_TIME,BOSS_CAM_POS,BOSS_CAM_ZOOM)
end
if throne then
throne.delayed_play.disabled=true
while not throne.delayed_play.ready do
coroutine.yield()
end
end
P:activate_path(6)
P:activate_path(BOSS_PI)
local boss=E:create_entity("enemy_boss_bandit")
local BOSS_LAND_NI,best_d=1,math.huge
for ni,n in ipairs(P:path(BOSS_PI,1)) do
local dd=V.dist(n.x,n.y,BOSS_CART_POS.x,BOSS_CART_POS.y)
if dd<best_d then
BOSS_LAND_NI,best_d=ni,dd
end
end
local points={}
for ni=1,BOSS_LAND_NI-1 do
table.insert(points,P:node_pos(BOSS_PI,1,ni))
end
table.insert(points,V.vclone(BOSS_CART_POS))
local start=points[1]
boss.pos=V.vclone(start)
boss.nav_path.pi=BOSS_PI
boss.nav_path.spi=1
boss.nav_path.ni=BOSS_LAND_NI
local bomb_ni,bomb_d=BOSS_LAND_NI,math.huge
for ni,n in ipairs(P:path(BOSS_PI,1)) do
local dd=V.dist(n.x,n.y,BOSS_BOMB_POS.x,BOSS_BOMB_POS.y)
if dd<bomb_d then
bomb_ni,bomb_d=ni,dd
end
end
local intro={points=points,land_idx=BOSS_LAND_NI,throne=throne}
intro.bomb={ni=bomb_ni,to=V.vclone(BOSS_TENT_POS),on_hit=function()
if camino_boss then
camino_boss.render.sprites[1].hidden=false
end
load_grid(store,"level_021_fase_3")
end}
boss.intro=intro
local cart_time=V.dist(start.x,start.y,points[1].x,points[1].y)
for i=2,BOSS_LAND_NI do
cart_time=cart_time+V.dist(points[i-1].x,points[i-1].y,points[i].x,points[i].y)
end
cart_time=cart_time/boss.intro_speed
local jump_time=throne and throne.throne_out_duration or 0
if throne then
throne.delayed_play.go=true
while not throne.delayed_play.jump_started do
coroutine.yield()
end
if cinematic then
signal.emit("show-balloon_tutorial-pos","S21_BOSS_01",false,V.vclone(BOSS_BALLOON_POS))
end
end
if cart_time<jump_time then
U.y_wait(store,jump_time-cart_time)
end
simulation:queue_insert_entity(boss)
while throne and not throne.delayed_play.finished do
coroutine.yield()
end
if esclavos then
esclavos.delayed_play.no_boss=true
end
while not intro.done do
coroutine.yield()
end
if cinematic then
signal.emit("pan-zoom-camera",BOSS_CAM_TIME,BOSS_CAM_DEFAULT_POS,1)
signal.emit("show-gui")
signal.emit("end-cinematic")
end
S:stop_group("MUSIC")
S:queue("MusicBossFight_221")
signal.emit("boss_fight_start",boss)
W:start_manual_wave("BOSS_1")
while not boss.health.dead do
coroutine.yield()
end
W:stop_manual_wave("BOSS_1")
y_boss_bar_fade(store,1,0,BOSS_BAR_FADE_TIME)
local boss2=y_find_entity(store,"enemy_boss_bandit_spawn")
local bar={info={i18n_key=boss2.info.i18n_key,portrait=boss2.info.portrait},health={hp=0,hp_max=1}}
signal.emit("boss_fight_start",bar)
y_boss_bar_fade(store,0,1,BOSS_BAR_FADE_TIME)
local fill_ts=store.tick_ts
while store.tick_ts-fill_ts<BOSS2_BAR_FILL_TIME and not boss2.health.dead do
local k=(store.tick_ts-fill_ts)/BOSS2_BAR_FILL_TIME
bar.health.hp=k*boss2.health.hp/boss2.health.hp_max
coroutine.yield()
end
signal.emit("boss_fight_start",boss2)
W:start_manual_wave("BOSS_2")
while not boss2.health.dead do
coroutine.yield()
end
W:stop_manual_wave("BOSS_2")
controller._spawns_stopped=true
LU.kill_all_enemies(store)
signal.emit("boss_fight_end")
U.y_wait(store,3)
if store.level_mode==GAME_MODE_CAMPAIGN then
store.custom_game_outcome={after_victory_screen=true,postpone_unload=true}
end
else
local controller=y_find_entity(store,"controller_stage_221")
controller.visibility_wave=6
P:activate_path(6)
P:activate_path(BOSS_PI)
for _,pi in ipairs(MODE_PATHS) do
P:activate_path(pi)
end
y_find_entity(store,"decal_stage221_7_camino_boss").render.sprites[1].hidden=false
y_find_entity(store,"decal_stage_221_spawner").render.sprites[1].hidden=true
if store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_HEROIC then
local throne=y_find_entity(store,"decal_stage_221_boss_throne")
U.sprites_hide(throne)
simulation:queue_remove_entity(throne)
local esclavos=y_find_entity(store,"decal_stage_221_esclavos")
esclavos._no_boss_start=true
esclavos.delayed_play.no_boss=true
end
while not controller._wave6_open do
coroutine.yield()
end
load_grid(store,"level_021_fase_3")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
