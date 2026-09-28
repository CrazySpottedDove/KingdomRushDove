local level={}
function level:init(store)
local E=require("entity_db")
local P=require("path_db")
local log=require("lib.klua.log"):new("level15")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function s15_rotten_spawner_update(this,store)
local cooldown,max_count,ts,last_wave
while true and (not store.boss_killed) do
::label_263_0::
while (not max_count or max_count==0) and store.wave_group_number==last_wave do
coroutine.yield()
end
if this.interrupt then
break
end
if store.wave_group_number~=last_wave then
local wave_timers=this.spawn_timers[store.wave_group_number]
cooldown,max_count=unpack(wave_timers or {cooldown,max_count})
last_wave=store.wave_group_number
ts=store.tick_ts
end
if not max_count or max_count==0 then
goto label_263_0
end
if cooldown<store.tick_ts-ts and max_count>0 then
for i=1,max_count do
do
local e=E:create_entity(this.entity)
local pos,pi,spi,ni=P:get_random_position(this.spawn_margin,bor(TERRAIN_LAND),nil,true)
if not pos then
pi,spi,ni=math.random(1,3),math.random(1,3),math.random(30,P:get_defend_point_node(1)-60)
if not P:is_node_valid(pi,ni) then
log.debug("s15_rotten_spawner: could not find random node")
goto label_263_1
end
pos=P:node_pos(pi,spi,ni)
end
e.pos,e.nav_path.pi,e.nav_path.spi,e.nav_path.ni=pos,pi,spi,ni
e.render.sprites[1].name="raise"
e.enemy.gold=0
simulation:queue_insert_entity(e)
end
::label_263_1::
end
ts=store.tick_ts
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_swamp_bubble","decal_delayed_play",true)
tt.render.sprites[1].name="decal_swamp_bubble_jump"
tt.delayed_play.flip_chance=0.5
tt.delayed_play.min_delay=fts(150)
tt.delayed_play.max_delay=fts(400)
tt.delayed_play.idle_animation=nil
tt.delayed_play.play_animation="decal_swamp_bubble_jump"
tt=E:register_t_hot("s15_rotten_spawner",nil,true)
AC(tt,"main_script","editor")
tt.main_script.update=s15_rotten_spawner_update
tt.entity="enemy_rotten_tree"
tt.spawn_margin={30,60}
tt.spawn_timers={{10,0},[11]={15,1},[14]={10,0},[15]={15,2},[17]={15,3},[20]={15,6}}
end
return level
