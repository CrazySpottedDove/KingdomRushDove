local signal=require("lib.hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local level={}
level.required_sounds={"music_stage29","SpecialBanthaSounds","SpecialFrog","SpecialTusken"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage29","go_stage29_bg"}
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
local function decal_tusken_update(this,store)
local a=this.bullet_attack
a.cooldown=U.frandom(a.cooldown_min,a.cooldown_max)
while true do
U.animation_start_default(this,"idle",nil,store.tick_ts)
local targets=table.filter(store.soldiers,function(_,e)
return e.soldier.target_id and not e.health.dead and U.is_inside_ellipse(e.pos,this.target_center,a.max_range)
end)
if #targets==0 then
U.y_wait_unconditional(store,1)
else
local attack_ts=store.tick_ts
local target=targets[1]
if math.random()<0.7 then
target=store.entities[target.soldier.target_id]
end
if target and target.health and not target.health.dead then
local b=E:create_entity(a.bullet)
b.bullet.from=v(this.pos.x+a.bullet_start_offset.x,this.pos.y+a.bullet_start_offset.y)
b.bullet.to=v(target.pos.x+target.unit.hit_offset.x,target.pos.y+target.unit.hit_offset.y)
b.bullet.target_id=target.id
b.bullet.source_id=this.id
b.pos=V.vclone(b.bullet.from)
U.animation_start_default(this,a.animation,nil,store.tick_ts)
S:queue("SpecialTusken",{delay=fts(19)})
U.y_wait_unconditional(store,a.shoot_time)
simulation:queue_insert_entity(b)
S:queue("ShotgunSound")
U.y_animation_wait_default(this)
U.y_wait_unconditional(store,a.cooldown-(store.tick_ts-attack_ts))
end
end
end
end
local tt
tt=E:register_t_hot("decal_tusken","decal_scripted",true)
AC(tt,"bullet_attack")
tt.render.sprites[1].prefix="decal_tusken"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].loop=false
tt.main_script.update=decal_tusken_update
tt.bullet_attack.max_range=350
tt.bullet_attack.bullet="bullet_tusken"
tt.bullet_attack.shoot_time=fts(2)
tt.bullet_attack.cooldown_min=10
tt.bullet_attack.cooldown_max=20
tt.bullet_attack.bullet_start_offset=vec_2(3,7)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.locked_hero=true
self.max_upgrade_level=3
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.locked_hero=true
self.max_upgrade_level=3
self.locked_towers={"tower_build_engineer"}
end
store.level_terrain_style=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
tt=E:register_t_hot("bullet_tusken","shotgun",true)
tt.bullet.damage_min=100
tt.bullet.damage_max=200
tt.bullet.min_speed=40*FPS
tt.bullet.max_speed=40*FPS
tt.bullet.hit_blood_fx="fx_blood_splat"
tt.bullet.miss_fx="fx_smoke_bullet"
end
function level:load(store)
LU.insert_background(store,"Stage03_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage03_0002",Z_OBJECTS_COVERS)
LU.insert_background(store,"Stage03_0003",Z_OBJECTS_COVERS)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
for _,h in pairs(self.locations.holders) do
if store.level_mode==GAME_MODE_IRON then
if h.id=="07" or h.id=="09" then
LU.insert_tower(store,"tower_barrack_1",h.style,h.pos,h.rally_pos,nil,h.id)
elseif h.id=="14" then
LU.insert_tower(store,"tower_barrack_2",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{14,x,x,6},{3,x,14,7},{4,x,2,8},{x,5,3,9},{x,x,3,4},{7,14,14,12},{8,2,6,13},{9,3,7,13},{10,4,8,13},{11,9,13,13},{x,x,10,x},{13,6,x,x},{10,8,12,12},{2,x,1,6}}
local e
e=E:create_entity("decal_tusken")
e.pos.x,e.pos.y=193,570
e.target_center=V.v(565,280)
LU.queue_insert(store,e)
end
function level:update(store)
LU.insert_hero(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
