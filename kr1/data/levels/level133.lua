local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
local function create_thunder(store,pos)
local fx=E:create_entity("fx_stage_33_house_destroy")
fx.pos=pos
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=V.vv(1.3)
fx.render.sprites[1].z=Z_EFFECTS
LU.queue_insert(store,fx)
local e=E:create_entity("stage_33_lightning_strike_fx_power_thunder_"..math.random(1,2))
e.pos=pos
e.render.sprites[1].flip_x=math.random()<0.5
e.render.sprites[1].ts=store.tick_ts
if REF_H-pos.y>e.image_h then
e.render.sprites[1].scale=V.v(1,(REF_H-pos.y)/e.image_h)
end
LU.queue_insert(store,e)
e=E:create_entity("stage_33_lightning_strike_fx_power_thunder_explosion")
e.pos=pos
e.render.sprites[1].ts=store.tick_ts
e.render.sprites[2].ts=store.tick_ts
LU.queue_insert(store,e)
e=E:create_entity("stage_33_lightning_strike_fx_power_thunder_explosion_decal")
e.pos=pos
e.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,e)
end
function level.open_middle_path(store,skip_anim)
local kill_area
local all_ray_offsets=V.v(0,0)
local ray_positions={{x=545,y=555},{x=697,y=669},{x=609,y=641},{x=649,y=571},{x=523,y=700},{x=727,y=573},{x=595,y=530},{x=507,y=640},{x=620,y=669},{x=490,y=526}}
if not skip_anim then
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=1.5
shake.aura.freq_factor=2
LU.queue_insert(store,shake)
for _,v in pairs(store.entities) do
if v.template_name=="decal_generic_kill_area" and v.kill_area_id==1 then
kill_area=v
break
end
end
kill_area:kill_area_fn(store)
for i=1,8 do
create_thunder(store,V.v(ray_positions[i].x+all_ray_offsets.x,ray_positions[i].y+all_ray_offsets.y))
U.y_wait(store,fts(2))
end
end
for _,e in pairs(store.entities) do
if e.template_name=="stage_33_mask_1" then
LU.queue_remove(store,e)
elseif e.template_name=="stage_33_mask_1_destroyed" then
e.render.sprites[1].hidden=false
elseif e.template_name=="tower_holder_blocked_stage_33_invisible" then
e:appear()
end
end
if not skip_anim then
for i=9,#ray_positions do
create_thunder(store,V.v(ray_positions[i].x+all_ray_offsets.x,ray_positions[i].y+all_ray_offsets.y))
U.y_wait(store,fts(2))
end
kill_area:kill_area_fn(store)
end
for pid,v in pairs(level.path_invalid_nodes) do
P:remove_invalid_range(pid,v.first,v.last)
end
P:activate_path(5)
P:activate_path(6)
end
function level:load(store)
local mid_path_lower_end_invalid_nodes_y_pos=590
level.path_invalid_nodes={{first=P:nearest_nodes(495,630,{1})[1][3],last=P:nearest_nodes(612,mid_path_lower_end_invalid_nodes_y_pos,{1})[1][3]},{first=P:nearest_nodes(734,630,{2})[1][3],last=P:nearest_nodes(612,mid_path_lower_end_invalid_nodes_y_pos,{2})[1][3]},{first=0,last=P:nearest_nodes(-10,277,{3})[1][3]},[5]={first=0,last=P:nearest_nodes(612,mid_path_lower_end_invalid_nodes_y_pos,{5})[1][3]},[6]={first=0,last=P:nearest_nodes(612,mid_path_lower_end_invalid_nodes_y_pos,{6})[1][3]},[7]={first=0,last=P:nearest_nodes(-10,277,{7})[1][3]}}
for pid,v in pairs(level.path_invalid_nodes) do
P:add_invalid_range(pid,v.first,v.last)
end
end
function level:update(store)
if store.level_mode==GAME_MODE_HEROIC then
level.open_middle_path(store,true)
end
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="47"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
coroutine.yield()
store.player_gold=starting_gold
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
