local log=require("lib.klua.log"):new("level14")
local signal=require("lib.hump.signal")
local km=require("lib.klua.macros")
local bit=require("bit")
local bor=bit.bor
local band=bit.band
local bnot=bit.bnot
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
level.required_sounds={"music_stage40","FrontiersUndergroundAmbienceSounds","DwarfSounds","DwarfHeroSounds","SpecialMountainDoor"}
level.required_textures={"go_enemies_underground","go_stages_underground","go_stage40","go_stage40_bg"}
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_UNDERGROUND
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=6
self.locked_towers={}
if store.level_mode==GAME_MODE_IRON then
self.locked_towers={"tower_build_barrack","tower_build_engineer"}
end
self.unlock_towers={"tower_barrack_dwarf","tower_archer_dwarf"}
end
function level:load(store)
LU.insert_background(store,"Stage14_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage14_0002",Z_BACKGROUND_COVERS,nil,-1)
LU.insert_background(store,"Stage14_0003",Z_OBJECTS,264,-1)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.cave_closed=LU.insert_background(store,"Stage14_0004",Z_OBJECTS,263)
end
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
if store.level_mode==GAME_MODE_CAMPAIGN then
for _,h in pairs(self.locations.holders) do
if table.contains({"3","5","11","19"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_underground",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"17","16"},h.id) then
e=LU.insert_tower(store,"tower_archer_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"9"},h.id) then
e=LU.insert_tower(store,"tower_barrack_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
elseif store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
if table.contains({"3","5","11","12","17"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_underground",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"4","2"},h.id) then
e=LU.insert_tower(store,"tower_archer_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"1"},h.id) then
e=LU.insert_tower(store,"tower_barrack_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
else
for _,h in pairs(self.locations.holders) do
if table.contains({"3","1","18","4","2","6","19","7","8"},h.id) then
e=LU.insert_tower(store,"tower_holder_blocked_underground",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"10","5","14"},h.id) then
e=LU.insert_tower(store,"tower_archer_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
elseif table.contains({"11","12"},h.id) then
e=LU.insert_tower(store,"tower_barrack_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{18,x,x,3},{19,x,18,6},{4,1,x,15},{5,18,3,16},{6,2,4,11},{7,2,5,12},{8,19,6,8},{x,7,7,13},{16,3,15,10},{14,9,17,x},{12,5,16,10},{13,6,11,14},{x,8,12,14},{x,13,10,x},{9,3,x,17},{11,4,9,10},{10,15,x,x},{2,x,1,4},{x,x,2,7},{x,x,x,x},{x,x,x,x},{x,x,x,x}}
P:add_invalid_range(1,1,10)
P:add_invalid_range(4,1,6)
P:add_invalid_range(6,1,15)
P:add_invalid_range(5,1,12)
P:set_start_node(5,5)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(5)
end
local e
e=E:create_entity("background_sounds_underground")
LU.queue_insert(store,e)
end
function level:update(store)
LU.insert_hero(store)
LU.insert_hero(store,"hero_dwarf",store.level.locations.exits[2].pos)
while store.wave_group_number<1 do
coroutine.yield()
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while store.wave_group_number<10 do
coroutine.yield()
end
S:queue("SpecialMountainDoor")
P:activate_path(5)
local e=E:create_entity("decal_tween")
e.pos.x,e.pos.y=558,224
e.render.sprites[1].name="fx_stage14_cave_rocks"
e.render.sprites[2]=E:clone_c("sprite")
e.render.sprites[2].name="fx_stage14_cave_rocks"
e.render.sprites[2].flip_x=true
e.render.sprites[3]=E:clone_c("sprite")
e.render.sprites[3].name="fx_stage14_cave_clouds"
for i=1,3 do
e.render.sprites[i].loop=false
e.render.sprites[i].anchor.y=0
e.render.sprites[i].ts=store.tick_ts
e.render.sprites[i].z=Z_OBJECTS_COVERS+2
end
e.tween.remove=true
e.tween.props[1].keys={{0,255},{fts(33),255},{fts(41),0}}
e.tween.props[1].sprite_id=1
e.tween.props[2]=E:clone_c("tween_prop")
e.tween.props[2].keys={{0,255},{fts(33),255},{fts(41),0}}
e.tween.props[2].sprite_id=2
e.tween.props[3]=E:clone_c("tween_prop")
e.tween.props[3].keys={{0,255},{fts(20),255},{fts(22),0},{fts(41),0}}
e.tween.props[3].sprite_id=3
LU.queue_insert(store,e)
U.y_wait(store,fts(3))
LU.queue_remove(store,self.cave_closed)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
return level
