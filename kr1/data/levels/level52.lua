local log=require("lib.klua.log"):new("level04")
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
function level:load(store)
if store.level_mode~=GAME_MODE_CAMPAIGN then
P:activate_path(3)
P:activate_path(4)
end
end
function level:update(store)
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
function level:y_burn_zone(store,zone)
local gnoll
if zone==1 then
local start_pos,end_pos,shoot_pos=V.v(770,-30),V.v(680,105),V.v(582,105)
local shoot_time=fts(8)
local flight_time=fts(12)
local bullet_offset=V.v(0,36)
local gnoll_speed=1.5*FPS
gnoll=E:create_entity("decal_gnoll_burner")
gnoll.pos=start_pos
LU.queue_insert(store,gnoll)
U.animation_start(gnoll,"walkingRightLeft",true,store.tick_ts,true)
y_walk(store,gnoll,end_pos,gnoll_speed)
U.animation_start(gnoll,"shoot",true,store.tick_ts,false)
U.y_wait(store,shoot_time)
local b=E:create_entity("torch_gnoll_burner")
b.pos=V.v(gnoll.pos.x+bullet_offset.x,gnoll.pos.y+bullet_offset.y)
b.bullet.from=V.vclone(b.pos)
b.bullet.to=shoot_pos
b.bullet.target_id=gnoll.id
b.bullet.miss_fx="fx_torch_gnoll_burner_explosion_stage04"
LU.queue_insert(store,b)
U.y_wait(store,flight_time)
local fx=E:create_entity("fx")
fx.render.sprites[1].name="fx_torch_gnoll_burner_explosion"
fx.render.sprites[1].ts=store.tick_ts
fx.pos=shoot_pos
LU.queue_insert(store,fx)
U.animation_start(gnoll,"idle",true,store.tick_ts,true)
U.y_wait(store,fts(5))
end
S:queue("ElvesSpecialExplosionPath")
local land=table.filter(store.entities,function(k,e)
return e.template_name=="decal_s04_land_"..zone
end)[1]
local trees=table.filter(store.entities,function(k,e)
return e.template_name=="decal_s04_tree_burn" and e.editor and e.editor.tag==zone
end)
local tree_fires=table.filter(store.entities,function(k,e)
return (e.template_name=="fx_s04_tree_fire_1" or e.template_name=="fx_s04_tree_fire_2") and e.editor and e.editor.tag==zone
end)
local charcoals=table.filter(store.entities,function(k,e)
return (e.template_name=="decal_s04_charcoal_1" or e.template_name=="decal_s04_charcoal_2" or e.template_name=="decal_s04_charcoal_3") and e.editor and e.editor.tag==zone
end)
local function sort_fn(e1,e2)
if zone==1 then
return e1.pos.x>e2.pos.x
else
return e1.pos.x<e2.pos.x
end
end
table.sort(trees,function(e1,e2)
return sort_fn(e1,e2)
end)
table.sort(tree_fires,function(e1,e2)
return sort_fn(e1,e2)
end)
table.sort(charcoals,function(e1,e2)
return sort_fn(e1,e2)
end)
local tree_delay=0.37/#trees
local tree_fire_delay=0.5549999999999999/#tree_fires
local charcoal_delay=0.2/#charcoals
local land_delay=0.46
log.error("#charcoals:%s #trees:%s",#charcoals,#trees)
for i,e in ipairs(trees) do
e.render.sprites[1].name="burn"
e.render.sprites[1].ts=store.tick_ts
e.render.sprites[1].time_offset=-i*tree_delay
e.timed.disabled=nil
end
for i,e in ipairs(tree_fires) do
e.render.sprites[1].hidden=false
e.render.sprites[1].ts=store.tick_ts+i*tree_fire_delay
e.timed.disabled=nil
end
for i,e in ipairs(charcoals) do
e.tween.disabled=nil
e.tween.ts=store.tick_ts+i*charcoal_delay
end
land.tween.disabled=nil
land.tween.ts=store.tick_ts+land_delay
P:activate_path(zone==1 and 3 or 4)
if zone==1 then
local holder=table.filter(store.entities,function(k,e)
return e.tower and e.tower.holder_id=="24"
end)[1]
holder.ui.can_click=true
U.y_wait(store,1)
local nodes=P:nearest_nodes(gnoll.pos.x,gnoll.pos.y,{2})
local node=nodes[1]
local e=E:create_entity("enemy_gnoll_burner")
e.pos=gnoll.pos
e.nav_path.pi=node[1]
e.nav_path.spi=1
e.nav_path.ni=node[3]+3
LU.queue_insert(store,e)
LU.queue_remove(store,gnoll)
end
end
return level
