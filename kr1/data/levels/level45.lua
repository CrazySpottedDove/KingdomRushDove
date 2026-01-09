local log=require("lib.klua.log"):new("level19")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local S=require("sound_db")
local P=require("path_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local v=V.v
local level={}
level.required_sounds={"music_stage45","HalloweenSounds","HWFrankensteinTower"}
level.required_textures={"go_enemies_halloween","go_enemies_blackburn","go_stages_halloween","go_stage45","go_stage45_bg"}
level.show_comic_idx=17
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_HALLOWEEN
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.max_upgrade_level=6
self.locked_towers={}
self.locked_powers={}
if store.level_mode==GAME_MODE_IRON then
self.locked_towers={"tower_build_barrack","tower_build_mage"}
end
self.unlock_towers={"tower_frankenstein"}
end
function level:load(store)
LU.insert_background(store,"Stage19_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
for _,h in pairs(self.locations.holders) do
if store.level_mode==GAME_MODE_CAMPAIGN and h.id=="15" or store.level_mode==GAME_MODE_HEROIC and h.id=="9" or store.level_mode==GAME_MODE_IRON and (h.id=="7" or h.id=="9" or h.id=="11") then
LU.insert_tower(store,"tower_frankenstein",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{10,12,x,2},{7,1,1,3},{4,2,2,4},{5,7,3,x},{9,6,4,x},{8,10,7,5},{6,10,2,4},{15,11,6,9},{15,8,5,x},{11,12,1,6},{15,13,10,8},{13,x,1,10},{14,x,12,11},{x,13,11,15},{x,14,8,9}}
local e
local houses={{"Halloween_stg19_house1",362,476,0.045454545454545456},{"Halloween_stg19_house2",807,557,0.075},{"Halloween_stg19_house3",681,293,0.15517241379310345}}
for _,d in pairs(houses) do
local name,px,py,anchor_y=unpack(d)
e=E:create_entity("decal")
e.render.sprites[1].animated=false
e.render.sprites[1].name=name
e.render.sprites[1].anchor=V.v(0.5,anchor_y)
e.render.sprites[1].z=Z_OBJECTS
e.pos.x,e.pos.y=px,py
LU.queue_insert(store,e)
end
local lights={{470,146},{817,197}}
for _,d in pairs(lights) do
local px,py=unpack(d)
e=E:create_entity("decal")
e.render.sprites[1].animated=false
e.render.sprites[1].name="Halloween_stg19_light"
e.render.sprites[1].anchor=V.v(0.5,0.1)
e.render.sprites[1].z=Z_OBJECTS
e.pos.x,e.pos.y=px,py
LU.queue_insert(store,e)
end
self.moon_overlay=E:create_entity("decal_moon_overlay")
LU.queue_insert(store,self.moon_overlay)
self.decal_moon_dark=E:create_entity("decal_moon_dark")
LU.queue_insert(store,self.decal_moon_dark)
self.decal_moon_light=E:create_entity("decal_moon_light")
LU.queue_insert(store,self.decal_moon_light)
e=E:create_entity("moon_controller")
e.moon_overlay=self.moon_overlay
e.decal_moon_dark=self.decal_moon_dark
e.decal_moon_light=self.decal_moon_light
e.transit_time=fts(550)
LU.queue_insert(store,e)
self.moon_controller=e
if store.level_mode==GAME_MODE_CAMPAIGN then
self.moon_controller.waves={{2,fts(580),15},{4,fts(580),15},{9,fts(680),15},{13,fts(980),20},{15,fts(980),30}}
elseif store.level_mode==GAME_MODE_HEROIC then
self.moon_controller.waves={{2,fts(1900),30},{3,fts(1300),20},{6,fts(3400),7}}
elseif store.level_mode==GAME_MODE_IRON then
self.moon_controller.waves={{1,fts(9300),40}}
end
e=E:create_entity("points_spawner")
LU.queue_insert(store,e)
self.points_spawner=e
e.spawner_points={{path=1,from=v(249,605),to=v(182,518)},{path=1,from=v(281,610),to=v(209,518)},{path=1,from=v(472,175),to=v(510,242)},{path=1,from=v(442,175),to=v(482,248)},{path=1,from=v(675,312),to=v(582,252)},{path=2,from=v(349,524),to=v(406,441)},{path=2,from=v(632,400),to=v(564,438)},{path=2,from=v(673,388),to=v(738,362)},{path=2,from=v(806,578),to=v(713,512)},{path=4,from=v(520,546),to=v(582,506)},{path=4,from=v(492,634),to=v(582,615)}}
e.spawner_groups={[100]={1,2,3,4,5,6,7,8,9,10,11},[101]={1,2},[102]={9,10},[103]={3,4},[104]={1,2,6,10,11},[105]={7,8,9},[106]={3,4,5}}
if store.level_mode==GAME_MODE_CAMPAIGN then
e.spawner_waves={{{6,0.5,101,0,3,false,1,3,"enemy_halloween_zombie"}},{{20,0.5,100,0,1,true,1,3,"enemy_halloween_zombie"},{22,0.5,104,0,1,true,1,3,"enemy_halloween_zombie"},{24,0.5,103,0,2,false,1,3,"enemy_halloween_zombie"},{24,0.5,102,0,2,false,1,3,"enemy_halloween_zombie"}},{{5,0.5,103,0,3,false,1,2,"enemy_halloween_zombie"}},{{20,0.5,100,0,1,true,1,3,"enemy_halloween_zombie"},{22,0.5,104,0,1,true,1,3,"enemy_halloween_zombie"},{24,0.5,103,0,2,false,1,3,"enemy_halloween_zombie"},{24,0.5,102,0,2,false,1,3,"enemy_halloween_zombie"}},[6]={{2,0.5,9,0,15,false,2,4,"enemy_halloween_zombie"},{15,0.5,104,0,12,false,2,4,"enemy_halloween_zombie"},{25,0.5,104,0,12,false,2,6,"enemy_halloween_zombie"},{55,0.5,105,0,8,false,2,3,"enemy_halloween_zombie"},{80,0.5,105,0,8,false,1,2,"enemy_halloween_zombie"}},[10]={{10,0.5,104,0,2,false,1,3,"enemy_ghoul"},{32,0.5,104,0,2,false,1,4,"enemy_ghoul"},{42,0.5,104,0,1,false,1,4,"enemy_ghoul"}},[11]={{50,0.5,101,0,2,false,1,3,"enemy_halloween_zombie"},{53.333333333333336,0.5,6,0,2,false,1,4,"enemy_halloween_zombie"},{61.666666666666664,0.5,7,0,2,false,1,4,"enemy_halloween_zombie"},{66.66666666666667,0.5,10,0,4,false,1,4,"enemy_halloween_zombie"},{73.33333333333333,0.5,9,0,5,false,1,5,"enemy_halloween_zombie"}},[12]={{4,0.5,103,0,3,false,1,3,"enemy_ghoul"},{4,0.5,105,0,3,false,1,3,"enemy_ghoul"},{4,0.5,11,0,5,false,1,4,"enemy_ghoul"},{22,0.5,104,0,7,false,1,4,"enemy_ghoul"}},[13]={{33.333333333333336,0.5,100,0,2,false,1,3,"enemy_halloween_zombie"},{35.333333333333336,0.5,104,0,3,true,1,3,"enemy_halloween_zombie"}},[15]={{4,0.5,100,0,6,true,1,7,"enemy_halloween_zombie"},{24,0.5,104,0,5,true,1,3,"enemy_halloween_zombie"},{33.333333333333336,0.5,100,0,2,true,1,4,"enemy_halloween_zombie"},{36.333333333333336,0.5,104,0,5,true,1,3,"enemy_halloween_zombie"},{38.333333333333336,1,104,0,8,true,1,5,"enemy_halloween_zombie"}}}
elseif store.level_mode==GAME_MODE_HEROIC then
e.spawner_waves={{{11.666666666666666,0.5,101,0,4,true,3,5,"enemy_halloween_zombie"},{15,0.5,104,0,6,true,3,5,"enemy_halloween_zombie"},{18.333333333333332,0.5,9,0,4,true,3,5,"enemy_halloween_zombie"}},[3]={{11.666666666666666,0.5,100,0,2,true,3,5,"enemy_halloween_zombie"},{16.666666666666668,0.5,104,0,3,true,3,5,"enemy_halloween_zombie"},{40,0.5,105,0,2,true,3,5,"enemy_halloween_zombie"}},[5]={{6.666666666666667,1.5,100,0,5,true,2,3,"enemy_halloween_zombie"},{30,0.5,6,0,6,true,3,5,"enemy_halloween_zombie"},{40,0.5,9,0,10,true,3,5,"enemy_halloween_zombie"},{56.666666666666664,0.5,103,0,10,true,6,10,"enemy_halloween_zombie"},{86.66666666666667,0.5,104,0,5,true,4,6,"enemy_halloween_zombie"}},[6]={{113.33333333333333,0.5,100,0,3,true,5,8,"enemy_halloween_zombie"}}}
elseif store.level_mode==GAME_MODE_IRON then
e.spawner_waves={}
end
end
function level:update(store)
LU.insert_hero(store)
while store.wave_group_number<1 do
coroutine.yield()
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
