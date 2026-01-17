local log=require("klua.log"):new("level16")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local GR=require("grid_db")
require("constants")
local function fts(v)
return v/FPS
end
local function change_grid_rect(rect,terrain)
local r=rect
local fi,fj=GR:get_coords(r.pos.x,r.pos.y)
local ti,tj=GR:get_coords(r.pos.x+r.size.x,r.pos.y+r.size.y)
for i=fi,ti do
for j=fj,tj do
GR:set_cell(i,j,terrain)
end
end
end
local function y_walk(store,entity,to,speed)
local from=V.vclone(entity.pos)
local duration=V.dist(from.x,from.y,to.x,to.y)/speed
local start_ts=store.tick_ts
local phase=0
local eased_phase=0
while phase<1 do
phase=math.min(1,(store.tick_ts-start_ts)/duration)
entity.pos.x=U.ease_value(from.x,to.x,phase,easing)
entity.pos.y=U.ease_value(from.y,to.y,phase,easing)
coroutine.yield()
end
end
local level={}
level.burner_data={{explosions=3,dest_pi=4,activate_holders=true,start_pos=V.v(889,300),shoot_pos=V.v(708,300),end_pos=V.v(820,300),explosions_delay=fts(5),grid_rect=V.r(643,254,121,110)},{explosions=2,dest_pi=5,start_pos=V.v(485,365),shoot_pos=V.v(391,379),end_pos=V.v(450,379),explosions_delay=fts(3),grid_rect=V.r(338,348,108,62)}}
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
for _,bd in pairs(self.burner_data) do
if bd.grid_rect then
change_grid_rect(bd.grid_rect,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
else
P:activate_path(4)
P:activate_path(5)
end
end
function level:update(store)
if store.level_mode~=GAME_MODE_CAMPAIGN then
local holders=table.filter(store.entities,function(k,e)
return e.tower_holder and not e.ui.can_click
end)
for _,h in pairs(holders) do
h.ui.can_click=true
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<5 do
coroutine.yield()
end
self:y_burn_zone(store,1)
while store.wave_group_number<10 do
coroutine.yield()
end
self:y_burn_zone(store,2)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
end
function level:y_burn_zone(store,zone)
local shoot_time=fts(8)
local flight_time=fts(12)
local bullet_offset=V.v(0,36)
local gnoll_speed=1.5*FPS
local bd=self.burner_data[zone]
local bush_burner=LU.list_entities(store.entities,"decal_s16_bush_burner",zone)[1]
LU.queue_remove(store,bush_burner)
local fx=E:create_entity("fx_s16_bush_burner")
fx.pos=bush_burner.pos
fx.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,fx)
local gnoll=E:create_entity("decal_gnoll_burner")
gnoll.pos=V.vclone(bd.start_pos)
LU.queue_insert(store,gnoll)
U.animation_start(gnoll,"walkingRightLeft",true,store.tick_ts,true)
y_walk(store,gnoll,bd.end_pos,gnoll_speed)
U.animation_start(gnoll,"shoot",true,store.tick_ts,false)
U.y_wait(store,shoot_time)
local b=E:create_entity("torch_gnoll_burner")
b.pos=V.v(gnoll.pos.x+bullet_offset.x,gnoll.pos.y+bullet_offset.y)
b.bullet.from=V.vclone(b.pos)
b.bullet.to=bd.shoot_pos
b.bullet.target_id=gnoll.id
b.bullet.miss_fx=nil
LU.queue_insert(store,b)
U.y_wait(store,flight_time)
U.animation_start(gnoll,"idle",true,store.tick_ts,true)
for i=1,bd.explosions do
local fxs=LU.list_entities(store.entities,"fx_s16_burner_explosion",zone*10+i)
for _,fx in pairs(fxs) do
local delay=(i-1)*bd.explosions_delay
fx.timed.disabled=nil
fx.render.sprites[1].ts=store.tick_ts+delay
fx.render.sprites[1].hidden=nil
end
S:queue("ElvesSpecialExplosionPath",{delay=delay})
end
U.y_wait(store,fts(9))
local land=LU.list_entities(store.entities,"decal_s16_land_"..zone)[1]
land.tween.disabled=nil
land.tween.ts=store.tick_ts
local tofade,toremove={},{}
if zone==1 then
tofade=LU.list_entities(store.entities,"decal_s16_bush_holder",zone)
toremove=LU.list_entities(store.entities,"tower_bastion",zone)
else
tofade=LU.list_entities(store.entities,"decal_s16_ground_archers_land",zone)
toremove=LU.list_entities(store.entities,"soldier_s16_ground_archer",zone)
end
for _,b in pairs(tofade) do
b.tween.disabled=nil
b.tween.ts=store.tick_ts
end
for _,b in pairs(toremove) do
LU.queue_remove(store,b)
end
P:activate_path(bd.dest_pi)
if bd.activate_holders then
local holders=table.filter(store.entities,function(k,e)
return e.tower_holder and not e.ui.can_click
end)
for _,h in pairs(holders) do
h.ui.can_click=true
h.tower.can_hover=true
h.render.sprites[1].z=Z_TOWER_BASES
end
end
if bd.grid_rect then
change_grid_rect(bd.grid_rect,TERRAIN_LAND)
end
U.y_wait(store,1)
local nodes=P:nearest_nodes(gnoll.pos.x,gnoll.pos.y,{bd.dest_pi})
local node=nodes[1]
local e=E:create_entity("enemy_gnoll_burner")
e.pos=gnoll.pos
e.nav_path.pi=node[1]
e.nav_path.spi=1
e.nav_path.ni=node[3]+3
local npos=P:node_pos(e.nav_path)
e.motion.forced_waypoint=npos
LU.queue_insert(store,e)
LU.queue_remove(store,gnoll)
end
return level
