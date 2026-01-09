local log=require("lib.klua.log"):new("level02")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local level={}
level.required_sounds={"music_stage28","SpecialStargate"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage28","go_stage28_bg"}
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_DESERT
self.locations=LU.load_locations(store,self)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.max_upgrade_level=6
self.locked_towers={"tower_archer_3","tower_barrack_3","tower_engineer_3","tower_mage_3"}
elseif store.level_mode==GAME_MODE_HEROIC then
self.locked_hero=true
self.max_upgrade_level=3
self.locked_towers={"tower_archer_3","tower_barrack_3","tower_engineer_3","tower_mage_3"}
elseif store.level_mode==GAME_MODE_IRON then
self.locked_hero=true
self.max_upgrade_level=3
self.locked_towers={"tower_build_archer","tower_barrack_3","tower_build_engineer","tower_mage_3"}
end
end
function level:load(store)
LU.insert_background(store,"Stage02_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
for _,h in pairs(self.locations.holders) do
if h.id=="14" or h.id=="15" then
LU.insert_tower(store,"tower_archer_hammerhold",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{2,10,x,x},{11,10,1,12},{4,9,10,11},{x,7,3,13},{6,x,x,10},{x,x,5,7},{x,6,8,4},{7,5,x,9},{4,8,x,3},{3,5,x,2},{13,3,2,12},{x,11,2,x},{x,4,11,x},{4,7,3,13},{6,x,5,8}}
self.custom_spawn_pos=V.v(600,590)
end
function level:update(store)
LU.insert_hero(store)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
