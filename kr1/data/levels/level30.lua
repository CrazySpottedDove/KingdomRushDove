local log=require("lib.klua.log"):new("level04")
local signal=require("hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("constants")
local level={}
level.required_sounds={"music_stage30","LegionnaireSounds","GenieSounds","SpecialWorm"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage30","go_stage30_bg"}
function level:init(store)
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
store.level_terrain_type=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
end
function level:load(store)
LU.insert_background(store,"Stage04_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
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
log.debug("-- sandworm released")
e=E:create_entity("sand_worm")
LU.queue_insert(store,e)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
