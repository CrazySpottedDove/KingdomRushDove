local log=require("lib.klua.log"):new("level09")
local signal=require("hump.signal")
local A=require("achievements")
local E=require("entity_db")
local P=require("path_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("constants")
local function fts(v)
return v/FPS
end
local v=V.v
local level={}
level.required_sounds={"music_stage35","FrontiersJungleAmbienceSounds","SpecialAlienSounds"}
level.required_textures={"go_enemies_jungle","go_stages_jungle","go_stage35","go_stage35_bg"}
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_JUNGLE
self.locations=LU.load_locations(store,self)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=6
self.locked_towers={}
elseif store.level_mode==GAME_MODE_HEROIC then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=5
self.locked_towers={}
elseif store.level_mode==GAME_MODE_IRON then
self.locked_hero=false
self.locked_powers={}
self.max_upgrade_level=5
self.locked_towers={"tower_build_barrack","tower_build_mage"}
end
self.unlock_towers={"tower_necromancer"}
end
function level:load(store)
LU.insert_background(store,"Stage09_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
self.hidden_holders={}
if store.level_mode==GAME_MODE_CAMPAIGN then
for _,h in pairs(self.locations.holders) do
if h.id=="3" or h.id=="10" or h.id=="15" then
e=LU.insert_tower(store,"tower_holder_blocked_jungle",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
elseif store.level_mode==GAME_MODE_HEROIC then
for _,h in pairs(self.locations.holders) do
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
else
for _,h in pairs(self.locations.holders) do
if table.contains({"2","9","10","15"},h.id) then
LU.insert_tower(store,"tower_barrack_1",h.style,h.pos,h.rally_pos,nil,h.id)
else
e=LU.insert_tower(store,"tower_holder_blocked_jungle",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
end
local x
self.nav_mesh={{9,12,x,2},{14,1,x,11},{4,10,11,x},{x,15,3,x},{6,13,15,15},{x,13,5,5},[8]={x,x,12,13},[9]={13,12,1,14},[10]={15,14,11,3},[11]={10,2,x,3},[12]={8,x,1,9},[13]={x,8,9,5},[14]={13,9,2,10},[15]={5,5,10,4}}
local alien_egg_coords={top={{pi=4,pos=V.v(657,608)},{pi=4,pos=V.v(684,594)},{pi=4,pos=V.v(685,622)}},bottom={{pi=5,pos=V.v(785,497)},{pi=5,pos=V.v(812,514)},{pi=5,pos=V.v(814,484)}}}
self.alien_eggs={}
for group_name,group in pairs(alien_egg_coords) do
self.alien_eggs[group_name]={}
for _,item in pairs(group) do
local e=E:create_entity("alien_egg")
e.pos=item.pos
e.spawner.pi=item.pi
LU.queue_insert(store,e)
table.insert(self.alien_eggs[group_name],e)
end
end
self.alien_waves={[5]={delay=12,top=0,bottom=1,cycles=1},[6]={delay=25,top=0,bottom=1,cycles=1},[7]={delay=25,top=0,bottom=1,cycles=1},[8]={delay=25,top=0,bottom=1,cycles=4},[9]={delay=25,top=1,bottom=1,cycles=4},[10]={delay=25,top=1,bottom=0,cycles=5},[11]={delay=25,top=0,bottom=2,cycles=5},[12]={delay=30,top=2,bottom=0,cycles=6},[13]={delay=30,top=1,bottom=2,cycles=10},[14]={delay=15,top=2,bottom=2,cycles=15},[15]={delay=15,top=2,bottom=2,cycles=15}}
local e
e=E:create_entity("background_sounds_jungle")
LU.queue_insert(store,e)
end
function level:update(store)
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished do
local wave_number=store.wave_group_number
self:y_spawn_aliens(store)
while wave_number==store.wave_group_number and not store.waves_finished do
coroutine.yield()
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
end
function level:y_spawn_aliens(store)
local wave_number=store.wave_group_number
local w=self.alien_waves[wave_number]
if not w then
return 
end
for i=1,w.cycles do
local ts=store.tick_ts
while store.tick_ts-ts<w.delay do
coroutine.yield()
if wave_number~=store.wave_group_number then
return 
end
if store.waves_finished then
return 
end
end
for j=1,w.top do
self.alien_eggs.top[j].do_spawn=true
end
for j=1,w.bottom do
self.alien_eggs.bottom[j].do_spawn=true
end
end
end
return level
