local log=require("lib.klua.log"):new("level17")
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
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local V=require("lib.klua.vector")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function malik_slave_controller_fn_can_power(this,store,power_id,pos)
if this.ready_to_free and power_id==GUI_MODE_POWER_1 and V.is_inside(pos,this.thunder_rect) then
this.got_thunder=true
return true
else
return false
end
end
local function malik_slave_controller_update(this,store)
local function do_thunder_fx(pos)
if E:get_template("user_power_1").template_name=="power_fireball_control" then
local e=E:create_entity("fx_fireball_explosion")
e.pos.x,e.pos.y=pos.x,pos.y
e.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(e)
elseif E:get_template("user_power_1").template_name=="power_thunder_control" then
local e=E:create_entity("fx_power_thunder_explosion")
e.pos.x,e.pos.y=pos.x,pos.y
e.render.sprites[1].ts=store.tick_ts
e.render.sprites[2].ts=store.tick_ts
simulation:queue_insert_entity(e)
e=E:create_entity("fx_power_thunder_explosion_decal")
e.pos.x,e.pos.y=pos.x,pos.y
e.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(e)
end
end
local function y_await_arrival(entities)
coroutine.yield()
for _,e in pairs(entities) do
while not e.motion.arrived do
coroutine.yield()
end
end
end
local function is_free()
return this.got_thunder
end
while store.wave_group_number<this.starting_wave do
coroutine.yield()
end
local g1=E:create_entity("decal_gnoll_gnawer")
local g2=E:create_entity("decal_gnoll_gnawer")
local m1=E:create_entity("decal_baby_malik_slave")
local sign=E:create_entity("decal_baby_malik_slave_banner")
local free_seq=E:create_entity("decal_baby_malik_slave_free")
local decals={g1,g2,m1}
g1.walk_points=this.walk_points.gnoll_left
g2.walk_points=this.walk_points.gnoll_right
m1.walk_points=this.walk_points.malik
g1.pos=V.vclone(g1.walk_points[1])
g2.pos=V.vclone(g2.walk_points[1])
m1.pos=V.vclone(m1.walk_points[1])
sign.pos=m1.pos
simulation:queue_insert_entity(g1)
simulation:queue_insert_entity(g2)
simulation:queue_insert_entity(m1)
simulation:queue_insert_entity(sign)
simulation:queue_insert_entity(free_seq)
while true do
for _,e in pairs(decals) do
e.motion.arrived=false
e.nav_grid.waypoints=table.deepclone(e.walk_points)
end
y_await_arrival(decals)
this.ready_to_free=true
U.animation_start_default(g1,"idle",false,store.tick_ts,true)
U.animation_start_default(g2,"idle",true,store.tick_ts,true)
U.animation_start_default(m1,"work",true,store.tick_ts,true)
local t1=U.frandom(1,2)
if U.y_wait_conditional(store,t1,is_free) then
break
end
sign.tween.ts=store.tick_ts
if U.y_wait_conditional(store,this.wait_time-t1,is_free) then
break
end
this.ready_to_free=false
for _,e in pairs(decals) do
e.motion.arrived=false
e.nav_grid.waypoints=table.reverse(e.walk_points,true)
end
y_await_arrival(decals)
U.animation_start_default(g1,"idle",false,store.tick_ts,true)
U.animation_start_default(g2,"idle",true,store.tick_ts,true)
U.animation_start_default(m1,"idle",true,store.tick_ts,true)
U.y_wait_unconditional(store,this.wait_time)
coroutine.yield()
end
this.ready_to_free=false
do_thunder_fx(g1.pos)
do_thunder_fx(g2.pos)
U.animation_start_default(g1,"death",nil,store.tick_ts,false)
U.animation_start_default(g2,"death",nil,store.tick_ts,false)
U.animation_start_default(m1,"idle",true,store.tick_ts,true)
U.y_wait_unconditional(store,4)
g1.tween.ts=store.tick_ts
g2.tween.ts=store.tick_ts
g1.tween.disabled=nil
g2.tween.disabled=nil
m1.render.sprites[1].hidden=true
free_seq.render.sprites[1].hidden=false
free_seq.pos=m1.pos
S:queue("ElvesMalikHammer")
U.y_animation_play(free_seq,nil,nil,store.tick_ts)
LU.insert_hero(store,"hero_baby_malik",this.hero_spawn_pos)
coroutine.yield()
free_seq.render.sprites[1].hidden=true
simulation:queue_remove_entity(g1)
simulation:queue_remove_entity(g2)
simulation:queue_remove_entity(m1)
simulation:queue_remove_entity(sign)
simulation:queue_remove_entity(free_seq)
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_hr_cart","decal",true)
tt.render.sprites[1].name="stage17_carret"
tt.render.sprites[1].anchor.y=0.08333333333333333
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_hr_worker_a","decal",true)
tt.render.sprites[1].name="decal_hr_worker_a"
tt.render.sprites[1].anchor.y=0.027777777777777776
tt=E:register_t_hot("decal_hr_worker_b","decal",true)
tt.render.sprites[1].name="decal_hr_worker_b"
tt.render.sprites[1].anchor.y=0.20833333333333334
tt=E:register_t_hot("malik_slave_controller","decal_scripted",true)
AC(tt,"editor")
tt.fn_can_power=malik_slave_controller_fn_can_power
tt.hero_spawn_pos=vec_2(736,639)
tt.main_script.update=malik_slave_controller_update
tt.starting_wave=2
tt.thunder_rect=r(655,595,164,56)
tt.wait_time=fts(159)
tt.achievement_id="FREEDOM_FIGHTER"
tt.walk_points={malik={vec_2(973,655),vec_2(808,632),vec_2(748,666)},gnoll_left={vec_2(935,651),vec_2(700,605)},gnoll_right={vec_2(1016,673),vec_2(795,631)}}
local LU=require("level_utils")
local A=require("achievements")
local km=require("lib.klua.macros")
local function decal_walking_update(this,store)
local n=this.nav_grid
while true do
if n.waypoints and #n.waypoints>1 then
local dest=n.waypoints[#n.waypoints]
local orig=table.remove(n.waypoints,1)
this.pos.x,this.pos.y=orig.x,orig.y
while not V.veq(this.pos,dest) do
local w=table.remove(n.waypoints,1) or dest
U.set_destination(this,w)
local an,af=U.animation_name_facing_point(this,"walkingRightLeft",this.motion.dest)
U.animation_start_default(this,an,af,store.tick_ts,true)
while not this.motion.arrived do
U.walk_off__accel__unsnapped(this,store.tick_length)
coroutine.yield()
this.motion.speed.x,this.motion.speed.y=0,0
end
end
end
coroutine.yield()
end
end
tt=E:register_t_hot("decal_gnoll_gnawer","decal_scripted",true)
AC(tt,"motion","nav_grid","tween")
tt.render.sprites[1].anchor=vec_2(0.5,0.25)
tt.render.sprites[1].prefix="gnoll_gnawer"
tt.render.sprites[1].name="idle"
tt.motion.max_speed=2*FPS
tt.main_script.update=decal_walking_update
tt.tween.disabled=true
tt.tween.props[1].keys={{0,255},{1,0}}
tt=E:register_t_hot("decal_baby_malik_slave","decal_scripted",true)
AC(tt,"motion","nav_grid")
tt.render.sprites[1].anchor.y=0.184
tt.render.sprites[1].prefix="decal_baby_malik"
tt.render.sprites[1].name="idle"
tt.main_script.update=decal_walking_update
tt.motion.max_speed=2*FPS
tt=E:register_t_hot("decal_baby_malik_slave_banner","decal_tween",true)
tt.render.sprites[1].name="malikAfro_sign"
tt.render.sprites[1].animated=false
tt.render.sprites[1].offset=vec_2(30,66)
tt.tween.ts=-10
tt.tween.remove=false
tt.tween.props[1].keys={{0,100},{fts(4),255},{fts(71),255},{fts(75),0}}
tt.tween.props[2]=CC("tween_prop")
tt.tween.props[2].name="scale"
tt.tween.props[2].keys={{0,vec_1(0.75)},{fts(4),vec_1(1.075)},{fts(7),vec_1(0.9625)},{fts(9),vec_1(1)},{fts(69),vec_1(1)},{fts(71),vec_1(1.075)},{fts(75),vec_1(0.75)}}
tt=E:register_t_hot("decal_baby_malik_slave_free","decal",true)
tt.render.sprites[1].name="decal_baby_malik_free"
tt.render.sprites[1].hidden=true
tt.render.sprites[1].loop=false
tt.render.sprites[1].anchor=vec_2(0.33101851851851855,0.27976190476190477)
end
function level:fn_can_power(store,power_id,pos)
local controller=LU.list_entities(store.entities,"malik_slave_controller")[1]
return controller and controller.fn_can_power(controller,store,power_id,pos) or false
end
function level:load(store)
return
end
function level:update(store)
if store.level_mode==GAME_MODE_IRON then
coroutine.yield()
local tpl=E:get_template("hero_baby_malik")
tpl.hero.level=10
tpl.hero.skills.smash.level=3
tpl.hero.skills.fissure.level=3
LU.insert_hero(store,"hero_baby_malik",store.level.locations.exits[2].pos)
end
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
