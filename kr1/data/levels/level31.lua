local log=require("lib.klua.log"):new("level05")
local signal=require("lib.hump.signal")
local A=require("achievements")
local E=require("entity_db")
local P=require("path_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local function fts(v)
return v/FPS
end
local v=V.v
local level={}
level.required_sounds={"music_stage31","PiratesSounds","SpecialCutTreeSounds"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage31","go_stage31_bg"}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local V=require("lib.klua.vector")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local v=V.v
local function fts(t)
return t/FPS
end
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function pirate_cannons_update(this,store)
local decal
local a=this.attacks.list[1]
a.ts=store.tick_ts
while true do
a.cooldown=U.frandom(a.min_cooldown,a.max_cooldown)
if store.tick_ts-a.ts>a.cooldown then
local targets=table.filter(store.entities,function(_,e)
return e and e.soldier and e.health and not e.health.dead and e.soldier.target_id~=nil and e.motion and V.veq(e.motion.speed,v(0,0)) and e.vis and band(e.vis.flags,a.vis_bans)==0 and band(e.vis.bans,a.vis_flags)==0 and U.is_inside_ellipse(e.pos,this.pos,a.max_range) and not U.is_inside_ellipse(e.pos,this.pos,a.min_range)
end)
local target=targets[math.random(1,#targets)]
if not target then
else
decal=E:create_entity("decal_pirate_cannon_target")
decal.pos=V.vclone(target.pos)
decal.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(decal)
U.animation_start_default(this,"fire",nil,store.tick_ts,false)
U.y_wait_unconditional(store,a.shoot_time)
S:queue("PirateBombShootSound")
local dest=V.vclone(target.pos)
U.y_wait_unconditional(store,fts(28))
local b1=E:create_entity("bomb_pirate_cannon")
local b2=E:create_entity("bomb_pirate_cannon")
b1.bullet.to=v(dest.x+U.random_sign()*math.random(a.min_error,a.max_error),dest.y+U.random_sign()*math.random(a.min_error,a.max_error))
b2.bullet.to=v(dest.x+U.random_sign()*math.random(a.min_error,a.max_error),dest.y+U.random_sign()*math.random(a.min_error,a.max_error))
b1.pos=b1.bullet.to
b2.pos=b2.bullet.to
simulation:queue_insert_entity(b1)
U.y_wait_unconditional(store,fts(4))
simulation:queue_insert_entity(b2)
U.y_animation_wait_default(this)
a.ts=store.tick_ts
end
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_lumberjack","decal",true)
tt.render.sprites[1].prefix="lumberjack"
tt.render.sprites[1].anchor.y=0.19
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_ship_door","decal",true)
tt.render.sprites[1].prefix="decal_ship_door"
tt.render.sprites[1].name="closed"
tt.render.sprites[1].loop=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("pirate_cannons","decal_scripted",true)
AC(tt,"attacks")
tt.main_script.update=pirate_cannons_update
tt.render.sprites[1].prefix="pirate_cannon_left"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].prefix="pirate_cannon_right"
tt.render.sprites[2].name="idle"
tt.render.sprites[2].z=Z_OBJECTS_COVERS+1
tt.render.sprites[2].offset=vec_2(169,-65)
tt.attacks.list[1]=CC("bullet_attack")
tt.attacks.list[1].min_range=100
tt.attacks.list[1].max_range=600
tt.attacks.list[1].min_cooldown=40
tt.attacks.list[1].max_cooldown=60
tt.attacks.list[1].shoot_time=fts(29)
tt.attacks.list[1].max_error=20
tt.attacks.list[1].min_error=5
if store.level_mode==GAME_MODE_CAMPAIGN then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=3
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=3
self.locked_towers={"tower_build_barrack","tower_build_engineer"}
end
self.unlock_towers={"tower_dwaarp","tower_barrack_pirates"}
store.level_terrain_style=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local SU=require("script_utils")
local function bomb_pirate_cannon_update(this,store)
local b=this.bullet
S:queue(this.sound_events.hit)
local targets=table.filter(store.entities,function(_,e)
return e and e.health and not e.health.dead and e.vis and band(e.vis.flags,b.damage_bans)==0 and band(e.vis.bans,b.damage_flags)==0 and U.is_inside_ellipse(e.pos,b.to,b.damage_radius)
end)
for _,target in ipairs(targets) do
local d=E.assign_damage(b.damage_type,b.damage_min+U.frandom(0,b.damage_max-b.damage_min),this.id,target.id)
queue_damage(store,d)
end
local p=SU.create_bullet_pop(store,this)
if p then
simulation:queue_insert_entity(p)
end
local sfx=E:create_entity(b.hit_fx)
sfx.pos=V.vclone(b.to)
sfx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(sfx)
local decal=E:create_entity(b.hit_decal)
decal.pos=V.vclone(b.to)
decal.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(decal)
simulation:queue_remove_entity(this)
end
tt=E:register_t_hot("decal_pirate_cannon_target","decal_tween",true)
tt.render.sprites[1].name="Stage4_ShipCrosshair"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS
tt.tween.props[1].name="scale"
tt.tween.props[1].keys={{0,vec_2(1.86,1.86)},{fts(20),vec_2(1.05,1.05)},{fts(23),vec_2(0.95,0.95)},{fts(26),vec_2(1.05,1.05)},{fts(28),vec_2(1,1)}}
tt.tween.props[2]=CC("tween_prop")
tt.tween.props[2].name="alpha"
tt.tween.props[2].keys={{0,0},{fts(20),255},{fts(74),255},{fts(78),0}}
tt=E:register_t_hot("bomb_pirate_cannon","bullet",true)
tt.render=nil
tt.main_script.update=bomb_pirate_cannon_update
tt.bullet.damage_min=50
tt.bullet.damage_max=100
tt.bullet.damage_radius=67.2
tt.bullet.damage_bans=F_ENEMY
tt.bullet.damage_flags=F_AREA
tt.bullet.hit_fx="fx_explosion_small"
tt.bullet.hit_decal="decal_bomb_crater"
tt.sound_events.hit="BombExplosionSound"
end
function level:load(store)
LU.insert_background(store,"Stage05_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage05_0002",Z_OBJECTS,631)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if h.id=="13" then
LU.insert_tower(store,"tower_barrack_pirates",h.style,h.pos,h.rally_pos,nil,h.id)
elseif h.id=="18" then
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
else
for _,h in pairs(self.locations.holders) do
if table.contains({"10","17","4","13","9"},h.id) then
LU.insert_tower(store,"tower_barrack_pirates",h.style,h.pos,h.rally_pos,nil,h.id)
elseif h.id=="18" then
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{2,x,18,3},{x,x,1,4},{4,1,18,5},{x,2,3,6},{6,3,17,8},{9,4,8,13},{8,17,x,11},{6,5,7,12},{x,x,6,14},{11,7,x,x},{12,7,10,16},{13,8,11,15},{14,6,15,x},{9,9,13,x},{13,12,11,16},{15,15,11,x},{5,18,x,7},{3,x,x,17}}
local e
self.ship_door=E:create_entity("decal_ship_door")
self.ship_door.pos=V.v(620,655)
LU.queue_insert(store,self.ship_door)
e=E:create_entity("pirate_cannons")
e.pos.x,e.pos.y=545,721
LU.queue_insert(store,e)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(3)
self:load_palms(store)
end
P:add_invalid_range(1,1,20)
P:add_invalid_range(2,1,20)
end
function level:update(store)
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
P:remove_invalid_range(1,1,20)
P:remove_invalid_range(2,1,20)
P:add_invalid_range(1,1,10)
P:add_invalid_range(2,1,10)
U.animation_start_default(self.ship_door,"open",nil,store.tick_ts,false)
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<8 do
coroutine.yield()
end
self:y_cut_palms(store)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
function level:load_palms(store)
self.palm_land_groups={}
for i=3,7 do
local e=E:create_entity("decal_palm_land")
e.render.sprites[1].name="Stage05_000"..i
e.render.sprites[1].animated=false
e.render.sprites[1].z=Z_BACKGROUND_COVERS-i
LU.queue_insert(store,e)
table.insert(self.palm_land_groups,e)
end
local palm_tree_coords={{v(1213,532),v(1136,512),v(1059,491),v(1177,473),v(1091,449),v(1181,444)},{v(883,498),v(934,474),v(1002,452),v(938,431)},{v(810,483),v(858,455),v(823,422)},{v(749,474),v(747,444)},{v(734,402)}}
self.palm_tree_groups={}
for _,g in pairs(palm_tree_coords) do
local tg={}
for _,c in pairs(g) do
local e=E:create_entity("decal_palm_tree")
e.pos=c
LU.queue_insert(store,e)
table.insert(tg,e)
end
table.insert(self.palm_tree_groups,tg)
end
end
function level:y_cut_palms(store)
local function cut_group(i)
for _,palm in pairs(self.palm_tree_groups[i]) do
palm.timed.runs=1
U.animation_start_default(palm,"cut",nil,store.tick_ts,false)
end
S:queue("SpecialCutTrees")
local land=self.palm_land_groups[i]
land.tween.disabled=nil
land.render.sprites[1].ts=store.tick_ts
end
local function y_walk(store,entity,to,speed)
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
local lumberjack=E:create_entity("decal_lumberjack")
lumberjack.pos=v(1160,440)
LU.queue_insert(store,lumberjack)
local cut_steps={{x=1079,y=430},{x=927,y=420},{x=837,y=408},{x=810,y=401},{x=760,y=395}}
for i,step in ipairs(cut_steps) do
U.animation_start_default(lumberjack,"cut",nil,store.tick_ts,false)
U.y_wait_unconditional(store,0.5)
cut_group(i)
U.y_wait_unconditional(store,0.4)
U.animation_start_default(lumberjack,"walk",nil,store.tick_ts,true)
y_walk(store,lumberjack,step,1.024*FPS)
end
LU.queue_remove(store,lumberjack)
local nodes=P:nearest_nodes(lumberjack.pos.x,lumberjack.pos.y)
local node=nodes[1]
local e=E:create_entity("enemy_executioner")
e.pos=lumberjack.pos
e.nav_path.pi=node[1]
e.nav_path.spi=1
e.nav_path.ni=node[3]+3
LU.queue_insert(store,e)
P:activate_path(3)
end
return level
