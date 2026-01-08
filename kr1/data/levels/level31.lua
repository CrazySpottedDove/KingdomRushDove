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
level.required_textures={"go_enemies_desert","go_enemies_desert_b","go_stages_desert","go_stage31","go_stage31_bg"}
function level:init(store)
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
store.level_terrain_type=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
end
function level:load(store)
LU.insert_background(store,"Stage05_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage05_0002",Z_OBJECT,631)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
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
U.animation_start(self.ship_door,"open",nil,store.tick_ts,false)
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
palm.timed.disabled=nil
U.animation_start(palm,"cut",nil,store.tick_ts,false)
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
local eased_phase=0
while phase<1 do
phase=math.min(1,(store.tick_ts-start_ts)/duration)
entity.pos.x=U.ease_value(from.x,to.x,phase,easing)
entity.pos.y=U.ease_value(from.y,to.y,phase,easing)
coroutine.yield()
end
end
signal.emit("wave-notification","icon","enemy_executioner")
local lumberjack=E:create_entity("decal_lumberjack")
lumberjack.pos=v(1160,440)
LU.queue_insert(store,lumberjack)
local cut_steps={{x=1079,y=430},{x=927,y=420},{x=837,y=408},{x=810,y=401},{x=760,y=395}}
for i,step in ipairs(cut_steps) do
U.animation_start(lumberjack,"cut",nil,store.tick_ts,false)
U.y_wait(store,0.5)
cut_group(i)
U.y_wait(store,0.4)
U.animation_start(lumberjack,"walk",nil,store.tick_ts,true)
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
