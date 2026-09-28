local log=require("lib.klua.log"):new("level08")
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
local level={}
level.required_sounds={"music_stage34","FrontiersJungleAmbienceSounds","PiratesSounds","SpecialCarnivorePlantSounds","SpecialMermaid"}
level.required_textures={"go_enemies_jungle","go_stages_jungle","go_stage34","go_stage34_bg","go_stage36"}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local P=require("path_db")
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
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function carnivorous_plant_update(this,store)
local a=this.area_attack
U.animation_start_default(this,"inactive",nil,store.tick_ts,true)
while store.wave_group_number<this.activates_on_wave do
coroutine.yield()
end
U.y_animation_play(this,"activate",nil,store.tick_ts)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
local attack_ts=store.tick_ts
while true do
while store.tick_ts-attack_ts<a.cooldown do
coroutine.yield()
end
local trigger
for _,e in pairs(store.entities) do
if (e.enemy or e.soldier) and e.health and not e.health.dead and band(e.vis.bans,a.vis_flags)==0 and band(e.vis.flags,a.vis_bans)==0 and U.is_inside_ellipse(e.pos,this.attack_pos,a.damage_radius) then
trigger=e
break
end
end
if not trigger then
attack_ts=store.tick_ts-a.cooldown+1
else
attack_ts=store.tick_ts
local attack_animation=this.attack_pos.y>this.pos.y and "attack_up" or "attack_down"
U.animation_start_default(this,attack_animation,nil,store.tick_ts)
U.y_wait_unconditional(store,a.hit_time)
S:queue("SpecialCarnivorePlant")
local e=E:create_entity("pop_slurp")
local x_off=this.render.sprites[1].flip_x and -40 or 40
local y_off=this.attack_pos.y>this.pos.y and 40 or -50
e.pos=v(this.pos.x+x_off,this.pos.y+e.pop_y_offset+y_off)
e.render.sprites[1].r=math.random(-21,21)*math.pi/180
e.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(e)
local targets=table.filter(store.entities,function(_,e)
return (e.enemy or e.soldier) and e.health and not e.health.dead and e.vis and band(e.vis.bans,a.vis_flags)==0 and band(e.vis.flags,a.vis_bans)==0 and U.is_inside_ellipse(e.pos,this.attack_pos,a.damage_radius)
end)
if #targets>0 then
for _,target in ipairs(targets) do
local d=E.assign_damage(a.damage_type,0,this.id,target.id)
queue_damage(store,d)
end
end
U.y_animation_wait_default(this)
U.animation_start_default(this,"idle",nil,store.tick_ts,true)
end
end
end
local function decal_bouncing_bridge_update(this,store)
local last_loaded=false
while true do
local loaded=false
for _,e in pairs(store.entities) do
if (e.enemy or e.soldier) and not e.health.dead and e.vis and not U.flag_has(e.vis.flags,F_FLYING) and U.is_inside_ellipse(e.pos,this.pos,this.bridge_width*0.5) then
loaded=true
break
end
end
if loaded~=last_loaded then
if loaded then
U.animation_start_default(this,"bounce",nil,store.tick_ts,true)
else
U.animation_start_default(this,"idle",nil,store.tick_ts)
end
last_loaded=loaded
end
U.y_wait_unconditional(store,fts(10))
end
end
local tt
tt=E:register_t_hot("carnivorous_plant","decal_scripted",true)
AC(tt,"area_attack")
tt.main_script.update=carnivorous_plant_update
tt.render.sprites[1].prefix="carnivorous_plant"
tt.render.sprites[1].name="inactive"
tt.render.sprites[1].anchor.y=0.41
tt.activates_on_wave=1
tt.area_attack.cooldown=40
tt.area_attack.damage_radius=55
tt.area_attack.hit_time=fts(10)
tt.area_attack.vis_flags=F_EAT
tt.area_attack.damage_type=DAMAGE_EAT
tt=E:register_t_hot("decal_bouncing_bridge","decal_scripted",true)
tt.main_script.update=decal_bouncing_bridge_update
tt.render.sprites[1].prefix="decal_bouncing_bridge"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].z=Z_DECALS-1
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="Stage6_Bridge_Front_Pillars"
tt.render.sprites[2].animated=false
tt.render.sprites[2].sort_y=495
tt.bridge_width=160
store.level_terrain_style=TERRAIN_STYLE_JUNGLE
self.locations=LU.load_locations(store,self)
P:deactivate_path(4)
P:add_invalid_range(3,1,40)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=4
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=4
self.locked_towers={"tower_build_mage","tower_build_mage","tower_build_engineer"}
end
self.unlock_towers={"tower_totem"}
end
function level:load(store)
LU.insert_background(store,"Stage08_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
self.hidden_holders={}
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if h.id=="3" then
LU.insert_tower(store,"tower_barrack_pirates",h.style,h.pos,h.rally_pos,nil,h.id)
elseif h.id=="2" or h.id=="10" or h.id=="14" then
LU.insert_tower(store,"tower_holder_blocked_jungle",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
else
for _,h in pairs(self.locations.holders) do
if table.contains({"1","2","3","10","11"},h.id) then
LU.insert_tower(store,"tower_holder_blocked_jungle",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{14,14,x,2},{10,1,1,3},{4,10,2,16},{15,10,3,16},{6,7,15,x},{x,7,5,x},{x,8,9,6},{7,x,12,9},{7,8,14,11},{15,11,2,4},{9,9,14,10},{8,x,x,14},[14]={9,12,1,11},[15]={5,9,4,16},[16]={x,4,x,x}}
local carnivorous_plants={}
if store.level_mode==GAME_MODE_CAMPAIGN then
carnivorous_plants={{flipped=false,activates_on_wave=10,pos=V.v(440,588),attack_pos=V.v(483,542)},{flipped=false,activates_on_wave=8,pos=V.v(558,461),attack_pos=V.v(620,523)},{flipped=true,activates_on_wave=2,pos=V.v(769,586),attack_pos=V.v(725,538)},{flipped=true,activates_on_wave=4,pos=V.v(575,174),attack_pos=V.v(516,217)},{flipped=false,activates_on_wave=6,pos=V.v(199,200),attack_pos=V.v(266,245)}}
elseif store.level_mode==GAME_MODE_HEROIC then
carnivorous_plants={{flipped=false,activates_on_wave=1,pos=V.v(440,588),attack_pos=V.v(483,542)},{flipped=false,activates_on_wave=6,pos=V.v(558,461),attack_pos=V.v(620,523)},{flipped=true,activates_on_wave=3,pos=V.v(769,586),attack_pos=V.v(725,538)},{flipped=true,activates_on_wave=5,pos=V.v(575,174),attack_pos=V.v(516,217)},{flipped=false,activates_on_wave=6,pos=V.v(199,200),attack_pos=V.v(266,245)}}
end
for _,item in pairs(carnivorous_plants) do
local e=E:create_entity("carnivorous_plant")
e.pos=item.pos
e.attack_pos=item.attack_pos
e.activates_on_wave=item.activates_on_wave
e.render.sprites[1].flip_x=item.flipped
LU.queue_insert(store,e)
end
local e
local water_sparks={V.v(469,700),V.v(500,770),V.v(568,673),V.v(658,458),V.v(582,390),V.v(674,130),V.v(623,60),V.v(717,28),V.v(684,380),V.v(386,752)}
for _,p in pairs(water_sparks) do
e=E:create_entity("decal")
e.render.sprites[1].name="decal_water_sparks_idle"
e.render.sprites[1].z=Z_DECALS
e.pos=p
LU.queue_insert(store,e)
end
local water_waves={{V.v(636,702),33},{V.v(559,417),0},{V.v(606,352),201},{V.v(590,96),300}}
for _,item in pairs(water_waves) do
e=E:create_entity("decal_water_wave")
e.pos=item[1]
e.render.sprites[1].r=math.pi*-1*item[2]/180
LU.queue_insert(store,e)
end
e=E:create_entity("decal_bouncing_bridge")
e.pos=V.v(646,528)
LU.queue_insert(store,e)
e=E:create_entity("background_sounds_jungle")
LU.queue_insert(store,e)
end
function level:update(store)
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
