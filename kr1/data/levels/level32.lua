local log=require("lib.klua.log"):new("level06")
local signal=require("hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("constants")
local level={}
level.required_sounds={"music_stage32","BossEfreeti"}
level.required_textures={"go_enemies_desert","go_enemies_desert_b","go_stages_desert","go_stage32","go_stage32_bg"}
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_DESERT
if store.level_mode==GAME_MODE_CAMPAIGN then
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.max_upgrade_level=4
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.max_upgrade_level=4
self.locked_towers={"tower_build_archer","tower_build_barrack"}
end
self.unlock_towers={"tower_archmage"}
self.locked_powers={}
self.locations=LU.load_locations(store,self)
end
function level:load(store)
LU.insert_background(store,"Stage06_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
for _,h in pairs(self.locations.holders) do
if store.level_mode==GAME_MODE_IRON then
if h.id=="10" then
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_barrack_1",h.style,h.pos,h.rally_pos,nil,h.id)
end
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{2,x,x,5},{11,x,1,10},[4]={5,1,x,7},[5]={6,1,4,7},[6]={10,1,5,8},[7]={8,5,x,x},[8]={9,6,7,x},[9]={13,10,8,x},[10]={11,2,6,9},[11]={12,2,10,15},[12]={x,x,11,15},[13]={14,10,9,x},[14]={15,11,13,x},[15]={x,11,14,x}}
if store.level_mode==GAME_MODE_CAMPAIGN then
local door=E:create_entity("decal_efreeti_door")
door.pos.x,door.pos.y=587,686
door.render.sprites[3].offset.x,door.render.sprites[3].offset.y=-587+REF_W*0.5,-686+REF_H*0.5
self.door=door
LU.queue_insert(store,door)
else
local broken_door=E:create_entity("decal_efreeti_door_broken")
broken_door.pos.x,broken_door.pos.y=587,686
LU.queue_insert(store,broken_door)
local tent=E:create_entity("decal_efreeti_tent")
tent.pos.x,tent.pos.y=878,516
LU.queue_insert(store,tent)
end
end
function level:update(store)
LU.insert_hero(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
U.y_wait(store,2)
signal.emit("show-curtains")
signal.emit("pan-zoom-camera",2.5,{x=512,y=576},2)
signal.emit("hide-gui")
self.door.phase="eyes"
while self.door.phase~="show_boss" do
coroutine.yield()
end
local boss=E:create_entity("eb_efreeti")
boss.nav_path.pi=4
boss.nav_path.spi=1
boss.nav_path.ni=9
LU.queue_insert(store,boss)
self.boss=boss
while self.boss.phase~="loop" do
coroutine.yield()
end
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=384},1)
signal.emit("show-gui")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
U.y_wait(store,5)
self.door.phase="destruction"
while self.door.phase~="finished" do
coroutine.yield()
end
log.debug("--- WON ")
end
end
return level
