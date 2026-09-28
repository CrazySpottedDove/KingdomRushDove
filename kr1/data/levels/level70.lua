local km=require("lib.klua.macros")
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
local U=require("utils")
require("all.constants")
require("lib.klua.table")
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function lava_fireball_controller_update(this,store)
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished do
local start_ts
local wave_number=store.wave_group_number
local active=this.launch_active[store.level_mode][wave_number]
local cooldown_normal=this.launch_cooldown[store.level_mode]
local cooldown_boss=this.launch_cooldown_boss
local duration=this.duration[store.level_mode]
log.debug("lava_fireball_controller - running wave_number:%s active:%s waves_finished:%s",wave_number,active,store.waves_finished)
if not active then
else
start_ts=store.tick_ts
while duration>store.tick_ts-start_ts do
local boss=LU.list_entities(store.enemies,"eb_balrog")[1]
local cooldown=boss and cooldown_boss or cooldown_normal
U.y_wait_unconditional(store,cooldown)
local target=U.find_random_target(store.entities,v(0,0),0,1e+99,F_RANGED,bor(F_ENEMY,F_FLYING))
if target then
local launch_pos=table.random(this.launch_points)
SU.insert_sprite(store,this.launch_fx,launch_pos)
local b=E:create_entity(this.bullet)
b.pos=V.vclone(launch_pos)
b.bullet.from=V.vclone(launch_pos)
b.bullet.to=V.vclone(target.pos)
simulation:queue_insert_entity(b)
end
end
end
while store.wave_group_number==wave_number and not store.waves_finished do
coroutine.yield()
end
end
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_s22_lava_hole","decal_delayed_play",true)
tt.render.sprites[1].prefix="decal_s22_lava_hole"
tt.render.sprites[1].name="play"
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_DECALS+1
tt.delayed_play.max_delay=2
tt.delayed_play.idle_animation=nil
tt=E:register_t_hot("lava_fireball_controller",nil,true)
AC(tt,"main_script")
tt.main_script.update=lava_fireball_controller_update
tt.bullet="bomb_lava_fireball"
tt.launch_fx="fx_bomb_lava_fireball_launch"
local V=require("lib.klua.vector")
local LU=require("level_utils")
local scripts=require("scripts")
local SU=require("script_utils")
local km=require("lib.klua.macros")
tt=E:register_t_hot("bomb_lava_fireball","bullet",true)
tt.bullet.damage_bans=F_ENEMY
tt.bullet.damage_flags=F_AREA
tt.bullet.damage_max=250
tt.bullet.damage_min=200
tt.bullet.damage_radius=45
tt.bullet.flight_time_base=fts(25)
tt.bullet.flight_time_factor=fts(0.05)
tt.bullet.g=-0.8/(fts(1)*fts(1))
tt.bullet.hit_decal="decal_bomb_crater"
tt.bullet.hit_fx="fx_bomb_lava_fireball_explosion"
tt.bullet.mod="mod_veznan_demon_fire"
tt.bullet.particles_name="ps_bomb_lava_fireball"
tt.bullet.pop={"pop_entwood"}
tt.bullet.rotation_speed=20*FPS*math.pi/180
tt.main_script.insert=scripts.enemy_bomb.insert
tt.main_script.update=scripts.enemy_bomb.update
tt.render.sprites[1].animated=false
tt.render.sprites[1].name="Stage9_lavaShot"
tt.sound_events.hit="BombExplosionSound"
end
function level:load(store)
return
end
function level:update(store)
coroutine.yield()
LU.insert_hero(store,"hero_bolverk",V.v(769,75))
while store.wave_group_number<1 do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
local boss=E:create_entity("eb_balrog")
boss.nav_path.pi=2
boss.nav_path.ni=P:get_start_node(boss.nav_path.pi)
LU.queue_insert(store,boss)
coroutine.yield()
local megaspawner=LU.list_entities(store.entities,"mega_spawner")[1]
local spawn_nodes=table.deepclone(megaspawner.spawn_nodes)
local spawn_idx=1
while not boss.health.dead do
if spawn_nodes[1] and boss.nav_path.ni>=spawn_nodes[1] then
table.remove(spawn_nodes,1)
megaspawner.manual_wave=megaspawner.spawn_waves[spawn_idx]
spawn_idx=km.zmod(spawn_idx+1,#megaspawner.spawn_waves)
end
coroutine.yield()
end
megaspawner.interrupt=true
while boss.phase~="death-complete" do
coroutine.yield()
end
U.y_wait_unconditional(store,1)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
