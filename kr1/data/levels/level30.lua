local signal=require("lib.hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local level={}
level.required_sounds={"music_stage30","LegionnaireSounds","GenieSounds","SpecialWorm"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage30","go_stage30_bg"}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local P=require("path_db")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function sand_worm_update(this,store)
local s=this.render.sprites[1]
local a=this.area_attack
s.hidden=true
while true do
U.y_wait_unconditional(store,a.cooldown*0.5)
::label_145_0::
U.y_wait_unconditional(store,a.cooldown*0.5)
local best_count=-1
local target
for _,ce in pairs(store.soldiers) do
if ce.soldier.target_id and not ce.health.dead and band(ce.vis.flags,a.vis_bans)==0 and band(ce.vis.bans,a.vis_flags)==0 and P:valid_node_nearby(ce.pos.x,ce.pos.y) then
local nearby=table.filter(store.soldiers,function(_,e)
return e.soldier.target_id and e~=ce and not e.health.dead and e.vis and band(e.vis.flags,a.vis_bans)==0 and band(e.vis.bans,a.vis_flags)==0 and U.is_inside_ellipse(e.pos,ce.pos,a.max_range)
end)
if best_count<#nearby then
target=ce
end
end
end
if not target then
local targets=table.filter(store.soldiers,function(k,v)
return not v.health.dead and band(v.vis.flags,a.vis_bans)==0 and band(v.vis.bans,a.vis_flags)==0 and v.template_name~="soldier_djinn" and v.template_name~="soldier_legionnaire" and P:valid_node_nearby(v.pos.x,v.pos.y)
end)
if #targets>0 then
target=table.random(targets)
end
end
if not target then
goto label_145_0
end
local nodes=P:nearest_nodes(target.pos.x,target.pos.y)
if #nodes<1 then
goto label_145_0
end
local attack_pos=P:node_pos(nodes[1][1],1,nodes[1][3])
local fx=E:create_entity("fx_sand_worm_incoming")
fx.pos=attack_pos
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
S:queue("SpecialWormDirtSound")
U.y_wait_unconditional(store,a.hit_time)
S:stop("SpecialWormDirtSound")
simulation:queue_remove_entity(fx)
this.pos=attack_pos
s.hidden=false
U.animation_start_default(this,a.animation,nil,store.tick_ts,false)
S:queue("SpecialWormBite")
local victims=table.filter(store.entities,function(_,e)
return (e.soldier or e.enemy) and e.vis and band(e.vis.flags,a.vis_bans)==0 and band(e.vis.bans,a.vis_flags)==0 and U.is_inside_ellipse(e.pos,attack_pos,a.max_range)
end)
for _,v in pairs(victims) do
if v.health.dead then
v.render.sprites[1].hidden=true
else
local d=E.assign_damage(a.damage_type,0,this.id,v.id)
queue_damage(store,d)
end
end
local decal=E:create_entity("fx_sand_worm_out")
decal.pos=attack_pos
decal.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(decal)
U.y_animation_wait_default(this)
s.hidden=true
end
end
local tt
tt=E:register_t_hot("sand_worm","decal_scripted",true)
AC(tt,"area_attack")
tt.render.sprites[1].prefix="sand_worm"
tt.render.sprites[1].name="attack"
tt.render.sprites[1].anchor.y=0.24
tt.render.sprites[1].draw_order=2
tt.main_script.update=sand_worm_update
tt.area_attack.animation="attack"
tt.area_attack.cooldown=90
tt.area_attack.max_range=64
tt.area_attack.max_count=30
tt.area_attack.hit_time=6
tt.area_attack.damage_type=DAMAGE_EAT
tt.area_attack.vis_flags=bor(F_EAT)
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
self.locked_towers={"tower_build_engineer","tower_build_mage"}
end
self.unlock_towers={"tower_crossbow","tower_barrack_mercenaries","tower_assassin"}
self.locked_powers={}
store.level_terrain_style=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
tt=E:register_t_hot("fx_sand_worm_incoming","decal_tween",true)
tt.render.sprites[1].anchor.y=0.44
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].name="sand_worm_incoming"
tt.tween.props[1].keys={{0,0},{0.6,255}}
tt.tween.remove=false
tt=E:register_t_hot("fx_sand_worm_out","decal_tween",true)
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].name="sandworm_decal_out"
tt.tween.props[1].keys={{1,255},{3.5,0}}
end
function level:load(store)
LU.insert_background(store,"Stage04_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if h.id=="12" then
LU.insert_tower(store,"tower_barrack_mercenaries",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
elseif store.level_mode==GAME_MODE_IRON then
for _,h in pairs(self.locations.holders) do
if table.contains({"3","13","14"},h.id) then
LU.insert_tower(store,"tower_barrack_mercenaries",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{2,9,x,x},{3,14,1,x},{15,8,2,x},{x,5,15,x},{6,6,15,4},{x,12,7,5},{6,12,8,15},{7,13,14,3},{14,10,x,1},{11,x,x,9},{13,x,10,14},{x,16,13,6},{12,16,11,8},{8,11,9,2},{5,7,3,4},{12,x,x,13}}
self.custom_spawn_pos=V.v(226,500)
LU.insert_background(store,"Stage04_0002",Z_OBJECTS_COVERS)
local e
if store.level_mode~=GAME_MODE_CAMPAIGN then
e=E:create_entity("decal")
e.render.sprites[1].name="Stage3_Worm"
e.render.sprites[1].animated=false
e.render.sprites[1].z=Z_DECALS
e.pos.x,e.pos.y=330,139
LU.queue_insert(store,e)
end
end
function level:update(store)
LU.insert_hero(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<1 do
coroutine.yield()
end
local e=E:create_entity("sand_worm")
LU.queue_insert(store,e)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
