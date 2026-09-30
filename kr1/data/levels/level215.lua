local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local v=V.v
local log=require("lib.klua.log"):new("level215")
local signal=require("lib.hump.signal")
local W=require("wave_db")
require("all.constants")
require("lib.klua.table")
local level={}
local function fts(v)
return v/FPS
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function get_random_round_robin(mutable_history,n,m)
if not m then
m=n
n=1
end
if #mutable_history==0 then
for i=n,m do
table.insert(mutable_history,i)
end
end
local pos=math.random(1,#mutable_history)
local value=mutable_history[pos]
table.remove(mutable_history,pos)
return value
end
local function random_point_in_ellipse(cx,cy,a,b)
local t=2*math.pi*math.random()
local r=math.sqrt(math.random())
local x=r*math.cos(t)
local y=r*math.sin(t)
return cx+x*a, cy+y*b
end
local function generate_blue_noise_cluster(count,candidates,random_fn,...)
local points={}
local x,y=random_fn(...)
points[1]=v(x,y)
for i=2,count do
local best_candidate
local best_distance2=-1
for c=1,candidates do
local px,py=random_fn(...)
local min_dist2=math.huge
for _,p in ipairs(points) do
local d2=V.dist2(px,py,p.x,p.y)
if d2<min_dist2 then
min_dist2=d2
end
end
if best_distance2<min_dist2 then
best_distance2=min_dist2
best_candidate=v(px,py)
end
end
points[i]=best_candidate
end
return points
end
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
local function corrupt_black_burn(bb)
if bb.health and bb.health.dead then
bb.force_respawn=true
end
bb.corrupt=true
bb.unit.is_stunned=true
end
local function insert_stage_hero(store,count)
local hero=E:create_entity("hero_stage_215_lord_blackburn")
hero.pos=V.v(850,324)
hero.nav_rally.center=V.vclone(hero.pos)
hero.nav_rally.pos=V.vclone(hero.pos)
hero.hero.xp=0
hero.hero.level=1
hero.skip_cutscene=true
hero.corrupt_count=count
simulation:queue_insert_entity(hero)
signal.emit("hero-added-no-panel",hero)
return hero
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local aux=E:create_entity("controller_stage_215_wave_report")
simulation:queue_insert_entity(aux)
local bb=insert_stage_hero(store,1)
local witch=find_all_t(store,"decal_stage_215_witch")[1]
local cauldron=find_all_t(store,"decal_stage_215_cauldron")[1]
local bb_idle=find_all_t(store,"decal_stage_215_lord_blackburn_corrupt_level_1_idle")[1]
if bb_idle then
simulation:queue_remove_entity(bb_idle)
end
if cauldron then
U.animation_start(cauldron,"idle",nil,store.tick_ts,true,1)
end
if witch then
witch.render.sprites[1].hidden=true
end
while store.wave_group_number<10 do
coroutine.yield()
end
corrupt_black_burn(bb)
while store.wave_group_number~=14 or not aux.no_more_enemies or LU.has_alive_enemies(store) or bb.corrupting do
coroutine.yield()
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
signal.emit("pan-zoom-camera",2,v(bb.pos.x,bb.pos.y),1.5)
U.y_wait(store,2.25)
corrupt_black_burn(bb)
if bb.sound_events then
bb.sound_events.change_rally_point=nil
end
bb.nav_rally.new=true
bb.nav_rally.pos=V.vclone(bb.pos)
bb.nav_rally.center=V.vclone(bb.pos)
U.y_wait(store,1e+99,function()
return not store.entities[bb.id]
end)
U.y_wait(store,fts(52))
local bbb=find_all_t(store,"enemy_boss_stage_215")[1]
U.y_wait(store,fts(13)+fts(30)+0.6+3)
signal.emit("hide-curtains")
signal.emit("show-gui")
signal.emit("end-cinematic")
signal.emit("boss_fight_start",bbb)
W:start_manual_wave("BOSS1")
W:start_manual_wave("BOSS_BUBBLES")
U.y_wait(store,1e+99,function()
return bbb.bossfight_ended
end)
store.custom_game_outcome={postpone_unload=true,after_victory_screen=true}
elseif store.level_mode==GAME_MODE_IRON then
local bb_idle=find_all_t(store,"decal_stage_215_lord_blackburn_corrupt_level_3_idle")[1]
if bb_idle then
simulation:queue_remove_entity(bb_idle)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
