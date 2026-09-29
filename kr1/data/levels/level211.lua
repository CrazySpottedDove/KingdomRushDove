local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local GR=require("grid_db")
local log=require("lib.klua.log"):new("level211")
require("all.constants")
require("lib.klua.table")
local level={}
local function generate_blue_noise_cluster(count,candidates,random_fn,...)
local points={}
local x,y=random_fn(...)
points[1]={x=x,y=y}
for i=2,count do
local bestCandidate
local bestDistance2=-1
for c=1,candidates do
local px,py=random_fn(...)
local minDist2=math.huge
for _,p in ipairs(points) do
local d2=V.dist2(px,py,p.x,p.y)
if d2<minDist2 then
minDist2=d2
end
end
if bestDistance2<minDist2 then
bestDistance2=minDist2
bestCandidate={x=px,y=py}
end
end
points[i]=bestCandidate
end
return points
end
local function random_point_in_rectangle(x_min,y_min,x_max,y_max)
return math.random(x_min,x_max), math.random(y_min,y_max)
end
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
local W=require("wave_db")
local signal=require("lib.hump.signal")
local function find_all_t(template_name)
return table.filter(store.entities,function(k,v)
return v.template_name==template_name
end)
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local camp_level_ups={5,10}
while store.wave_group_number<camp_level_ups[1] do
coroutine.yield()
end
local old_camp=find_all_t("tower_stage_211_camp_lvl1")[1]
if old_camp and old_camp.tower then
old_camp.tower.upgrade_to="tower_stage_211_camp_lvl2"
end
while store.wave_group_number<camp_level_ups[2] do
coroutine.yield()
end
local old_camp2=find_all_t("tower_stage_211_camp_lvl2")[1]
if old_camp2 and old_camp2.tower then
old_camp2.tower.upgrade_to="tower_stage_211_camp_lvl3"
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
local c=find_all_t("controller_stage_211_spider_block_and_spawn")[1]
if c then
while c.in_use do
coroutine.yield()
end
c._tower_block=false
c._spawn_eggs=false
c.eggs_queue={}
end
U.y_wait(store,2)
local node=30
local descent=E:create_entity("decal_stage_211_sarelgaz_descent")
local dest=P:node_pos(1,1,node)
descent.pos.x=dest.x
descent.target_pos=V.vclone(dest)
simulation:queue_insert_entity(descent)
while not descent.finished do
coroutine.yield()
end
local boss=E:create_entity("enemy_boss_stage_11")
boss.nav_path.pi=1
boss.nav_path.spi=1
boss.nav_path.ni=node
boss.pos=V.vclone(dest)
boss.lower_path_id=1
boss.lower_node_id=node
simulation:queue_insert_entity(boss)
coroutine.yield()
signal.emit("boss_fight_start",boss)
W:start_manual_wave("BOSS1")
while not boss.health.dead do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,3)
else
for k,v in pairs(store.entities) do
if v.template_name=="decal_stage_211_torch" and v.camp_level==2 then
v.skip_to_loop=true
v.render.sprites[1].hidden=false
end
if v.template_name=="decal_stage_211_shadows_lvl1" then
v.render.sprites[1].hidden=true
end
if v.template_name=="decal_stage_211_shadows_lvl2" then
v.render.sprites[1].hidden=false
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
