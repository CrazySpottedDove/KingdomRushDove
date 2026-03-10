local log=require("klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local boss_shadow_waves,moving_island,ballista
local function y_set_middle_path_walkable(store)
for x=2,87 do
for y=32,15,-1 do
GR:set_cell(x,y,TERRAIN_LAND)
end
end
for _,v in pairs(store.entities) do
if v.tower_holder or v.tower then
for xx=-25,25,3 do
for yy=-6,18,3 do
local i,j=GR:get_coords(v.pos.x+xx,v.pos.y+yy)
GR:set_cell(i,j,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
end
end
while moving_island.pos.x>76 do
coroutine.yield()
end
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
U.y_wait(store,0.5)
S:queue("Stage40PathOpen")
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=2
shake.aura.freq_factor=2
shake.aura.reverse_fade=true
LU.queue_insert(store,shake)
local mask=E:create_entity("decal_stage_40_open_middle_mask")
mask.pos=V.v(512,384)
mask.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,mask)
local timing_start=store.tick_ts
local dirt_fx_timings_and_positions={{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x+110,moving_island.pos.y+-50)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x+125,moving_island.pos.y+-20)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+100,moving_island.pos.y+10)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x-60,moving_island.pos.y+-50)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x+60,moving_island.pos.y+-30)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+0,moving_island.pos.y+-50)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x+-30,moving_island.pos.y+-30)},{ts=timing_start+1.85+0,pos=V.v(moving_island.pos.x-60,moving_island.pos.y+70)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x+60,moving_island.pos.y+50)},{ts=timing_start+1.85+0.1,pos=V.v(moving_island.pos.x+0,moving_island.pos.y+70)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x+-30,moving_island.pos.y+50)},{ts=timing_start+1.85+0.05,pos=V.v(moving_island.pos.x-100,moving_island.pos.y+10)},{ts=timing_start+1.85+0.15,pos=V.v(moving_island.pos.x-90,moving_island.pos.y+-10)},{lock_moving_island=true,ts=timing_start+1.85+0.1},{hide_storm=true,ts=timing_start+1.85+0.12},{boss_flight=true,ts=timing_start+0.6},{shake=true,ts=timing_start+1.9},{holders=true,ts=timing_start+1.9}}
local storm_decos
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_40_storm_decos" then
storm_decos=v
break
end
end
table.sort(dirt_fx_timings_and_positions,function(a,b)
return a.ts<b.ts
end)
local wait_until_ts=store.tick_ts+4
while wait_until_ts>store.tick_ts do
local entry=dirt_fx_timings_and_positions[1]
if entry and store.tick_ts>entry.ts then
if entry.lock_moving_island then
moving_island:on_open_path()
end
if entry.hide_storm then
storm_decos.render.sprites[7].hidden=true
end
if entry.boss_flight then
boss_shadow_waves.stun_side="RIGHT"
boss_shadow_waves.stun_with_fps=60
end
if entry.pos then
local fx=E:create_entity("fx_stage_40_moving_island_explosion_dirt")
fx.pos=entry.pos
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=V.vv(fx.render.sprites[1].scale.x*0.8+fx.render.sprites[1].scale.x*0.4*math.random())
LU.queue_insert(store,fx)
end
if entry.shake then
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=1
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
end
if entry.holders then
local holders={}
for _,v in pairs(store.towers) do
if v.tower and (v.tower.holder_id=="11" or v.tower.holder_id=="9") then
table.insert(holders,v)
local fx=E:create_entity("fx_stage_40_moving_island_explosion_dirt")
fx.pos=V.v(v.pos.x,v.pos.y-10)
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=V.vv(fx.render.sprites[1].scale.x*0.8+fx.render.sprites[1].scale.x*0.4*math.random())
LU.queue_insert(store,fx)
elseif v.template_name=="decal_stage_40_holders_mask" then
LU.queue_remove(store,v)
end
end
coroutine.yield()
for _,v in pairs(holders) do
U.sprites_show(v,nil,nil,true)
if v.tower_holder then
v.tower_holder.blocked=false
end
v.ui.can_click=true
v.ui.can_select=true
end
end
table.remove(dirt_fx_timings_and_positions,1)
end
coroutine.yield()
end
end
local function show_focus_circle(store,pos)
local screen_focus_circle=E:create_entity("screen_focus_circle")
screen_focus_circle.circle_pos=pos
screen_focus_circle.circle_radius=200
LU.queue_insert(store,screen_focus_circle)
return screen_focus_circle
end
local function remove_focus_circle(store,circle)
circle.tween.remove=true
circle.tween.ts=store.tick_ts
circle.tween.reverse=true
end
local function unclickable_all(store)
local unclickable_objects={}
for _,v in pairs(store.entities) do
if v.ui then
local orig_config={can_click=v.ui.can_click,can_select=v.ui.can_select,id=v.id}
table.insert(unclickable_objects,orig_config)
v.ui.can_click=false
v.ui.can_select=false
end
end
return unclickable_objects
end
local function reset_clickable_all(store,objects)
for _,v in pairs(objects) do
local e=store.entities[v.id]
if e and e.ui then
e.ui.can_click=v.can_click
e.ui.can_select=v.can_select
end
end
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=22
end
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode~=GAME_MODE_HEROIC then
P:deactivate_path(10)
end
for _,v in pairs(store.entities) do
if v.tower and (v.tower.holder_id=="11" or v.tower.holder_id=="9") then
U.sprites_hide(v,nil,nil,true)
v.tower_holder.blocked=true
v.ui.can_click=false
v.ui.can_select=false
elseif v.template_name=="controller_stage_40_moving_island" then
moving_island=v
elseif v.template_name=="controller_stage_40_boss_shadow_waves" then
boss_shadow_waves=v
elseif v.template_name=="controller_stage_40_ballista" then
ballista=v
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
self.island_soldiers_cinematic=false
self.bossfight_started=false
P:add_invalid_range(12,nil,nil)
P:add_invalid_range(13,nil,nil)
P:add_invalid_range(14,nil,nil)
P:add_invalid_range(15,nil,nil)
P:add_invalid_range(16,nil,nil)
P:add_invalid_range(17,nil,nil)
P:deactivate_path(4)
P:deactivate_path(5)
if not store.restarted and not main.params.skip_cutscenes then
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=800,y=500},1.2)
U.y_wait(store,4.8)
signal.emit("pan-zoom-camera",0.5,{x=800,y=384},1.2)
U.y_wait(store,0.4)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.6
shake.aura.duration=0.5
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
U.y_wait(store,1.5)
moving_island:talk()
signal.emit("show-balloon_tutorial","LV40_INTRO_TAUNT_01",false)
U.y_wait(store,3)
moving_island.remove_stone_1=true
U.y_wait(store,2.2)
signal.emit("pan-zoom-camera",2,{x=512,y=380},1)
U.y_wait(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
else
moving_island.remove_stone_1=true
end
while not self.island_soldiers_cinematic do
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=300,y=384},1.2)
U.y_wait(store,3)
y_set_middle_path_walkable(store)
P:activate_path(4)
P:activate_path(5)
U.y_wait(store,0.8)
moving_island.render.sprites[moving_island.sid_top_warden].flip_x=true
U.y_wait(store,0.2)
moving_island:talk()
signal.emit("show-balloon_tutorial","LV40_WAVE_10_TAUNT_01",false)
U.y_wait(store,1.5)
moving_island.next_runa_wave=10
moving_island:spawn_soldiers(store)
U.y_wait(store,2.5)
signal.emit("pan-zoom-camera",2,{x=512,y=384},1.5)
U.y_wait(store,2)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,{x=300,y=384},1.3)
U.y_wait(store,2)
signal.emit("show-balloon_tutorial","LV40_BOSSFIGHT_START_TAUNT_01",false)
U.y_wait(store,3)
local boss=E:create_entity("controller_stage_40_boss")
boss.pos=V.v(512,384)
LU.queue_insert(store,boss)
coroutine.yield()
store.game_gui:set_boss(boss)
signal.emit("pan-zoom-camera",4,{x=512,y=380},1)
U.y_wait(store,8.2)
moving_island.remove_runas=true
U.y_wait(store,9.8)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic",true)
if not moving_island.can_attack then
moving_island.can_attack=true
end
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,1)
signal.emit("fade-out",1)
store.waves_finished=true
store.level.run_complete=true
elseif store.level_mode==GAME_MODE_HEROIC then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
elseif store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="41"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="44"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="45"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="46"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="47"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="48"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="49"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="50"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="51"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="52"
end)[1]
holder.tower.upgrade_to="tower_paladin_covenant_lvl1"
for x=2,87 do
for y=32,15,-1 do
GR:set_cell(x,y,TERRAIN_LAND)
end
end
for _,v in pairs(store.entities) do
if v.tower_holder or v.tower then
for xx=-25,25,3 do
for yy=-6,18,3 do
local i,j=GR:get_coords(v.pos.x+xx,v.pos.y+yy)
GR:set_cell(i,j,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
end
end
coroutine.yield()
store.player_gold=starting_gold
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
