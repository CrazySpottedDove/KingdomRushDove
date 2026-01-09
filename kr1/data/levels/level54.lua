local log=require("lib.klua.log"):new("level06")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.gryphon_waves={{wave=5,side="left",delay=17,cooldown=120},{wave=10,side="right",delay=13,cooldown=120}}
elseif store.level_mode==GAME_MODE_HEROIC then
self.gryphon_waves={{wave=2,side="left",delay=15,cooldown=360},{wave=4,side="right",delay=15,cooldown=360}}
elseif store.level_mode==GAME_MODE_IRON then
self.gryphon_waves={{wave=1,side="left",delay=15,cooldown=48},{wave=1,side="right",delay=15,cooldown=48}}
end
local e=E:create_entity("mega_spawner")
e.load_file="level54_spawner"
LU.queue_insert(store,e)
self.mega_spawner=e
end
function level:update(store)
local function y_move(store,entity,to,speed)
local from=V.vclone(entity.pos)
local duration=V.dist(from.x,from.y,to.x,to.y)/speed
local start_ts=store.tick_ts
local phase=0
while phase<1 do
phase=math.min(1,(store.tick_ts-start_ts)/duration)
entity.pos.x=U.ease_value(from.x,to.x,phase,easing)
entity.pos.y=U.ease_value(from.y,to.y,phase,easing)
coroutine.yield()
end
end
while store.wave_group_number<1 do
coroutine.yield()
end
if self.gryphon_waves then
local e=E:create_entity("gryphon_controller")
e.gryphon_waves=self.gryphon_waves
LU.queue_insert(store,e)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
U.y_wait(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2,{x=120,y=500},2)
signal.emit("hide-gui")
local jail=E:create_entity("decal_s06_jailed_boss")
jail.pos.x,jail.pos.y=store.visible_coords.left-132,459
LU.queue_insert(store,jail)
self.jail=jail
S:queue("ElvesHyenaWagonLoop")
y_move(store,jail,V.v(120,459),47)
S:stop("ElvesHyenaWagonLoop")
S:queue("ElvesHyenaWagonExplosion")
U.animation_start(jail,"open",nil,store.tick_ts,false)
U.y_wait(store,fts(83))
S:queue("ElvesHyenaWagonEnd")
local nodes=P:nearest_nodes(jail.pos.x,jail.pos.y)
local node=nodes[1]
local boss=E:create_entity("eb_gnoll")
boss.nav_path.pi=node[1]
boss.nav_path.spi=1
boss.nav_path.ni=node[3]+1
boss.mega_spawner=self.mega_spawner
LU.queue_insert(store,boss)
self.boss=boss
U.y_wait(store,fts(3))
for i=1,5 do
jail.render.sprites[i].z=Z_DECALS
end
while self.boss.phase~="loop" do
coroutine.yield()
end
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
while self.boss.phase~="dead" do
coroutine.yield()
end
while self.boss.phase~="death-complete" do
coroutine.yield()
end
U.y_wait(store,1)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
