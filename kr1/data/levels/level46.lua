local log=require("lib.klua.log"):new("level20")
local bit=require("bit")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local S=require("sound_db")
local P=require("path_db")
require("constants")
local function fts(v)
return v/FPS
end
local v=V.v
local level={}
level.required_sounds={"music_stage46","HalloweenSounds","HWHeadlessHorseman"}
level.required_textures={"go_enemies_halloween","go_enemies_blackburn","go_stages_halloween","go_stage46","go_stage46_bg"}
function level:init(store)
store.level_terrain_type=TERRAIN_STYLE_HALLOWEEN
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.max_upgrade_level=6
self.locked_towers={}
self.locked_powers={}
if store.level_mode==GAME_MODE_IRON then
self.locked_towers={"tower_build_engineer","tower_build_mage"}
end
end
function level:load(store)
LU.insert_background(store,"Stage20_0001",Z_BACKGROUND)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_type)
for _,h in pairs(self.locations.holders) do
if store.level_mode==GAME_MODE_IRON and h.id=="11" then
LU.insert_tower(store,"tower_barrack_2",h.style,h.pos,h.rally_pos,0,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{3,3,x,2},{5,3,1,4},{5,8,1,2},{6,2,2,x},{12,9,2,6},{13,5,4,x},{10,x,x,8},{9,7,x,3},{11,10,8,5},{11,x,7,9},{x,10,9,12},{x,11,5,13},{12,12,6,x}}
for i=6,9 do
P:add_invalid_range(i,nil,nil,bit.bor(NF_RALLY,NF_TWISTER))
end
local e
local trees={v(522,491),v(595,479),v(626,463),v(653,488),v(767,452),v(823,510),v(885,497),v(961,283),v(907,237),v(884,216),v(667,229),v(30,333),v(972,501),v(813,636),v(529,664),v(746,582),v(848,586),v(775,109)}
for _,p in pairs(trees) do
e=E:create_entity("decal")
e.render.sprites[1].animated=false
e.render.sprites[1].name="Halloween_stg20_tree"
e.render.sprites[1].anchor=V.v(0.5,0.10256410256410256)
e.render.sprites[1].z=Z_OBJECTS
e.pos=p
LU.queue_insert(store,e)
end
e=E:create_entity("decal")
e.render.sprites[1].animated=false
e.render.sprites[1].name="Halloween_stg20_roots"
e.render.sprites[1].anchor.y=0.28
e.render.sprites[1].z=Z_OBJECTS
e.pos.x,e.pos.y=921,471
LU.queue_insert(store,e)
local stones={{1,v(123,133),0.2},{2,v(210,362),0.175},{3,v(437,493),0.0625},{4,v(443,660),0.1625},{5,v(582,688),0.1375}}
for _,d in pairs(stones) do
local id,pos,anchor_y=unpack(d)
e=E:create_entity("decal_moon_activated")
e.render.sprites[1].name="Halloween_stg20_stones_000"..id
e.render.sprites[1].anchor.y=anchor_y
e.render.sprites[2].name="Halloween_stg20_stone_lights_000"..id
e.render.sprites[2].anchor.y=anchor_y
e.pos=pos
LU.queue_insert(store,e)
end
e=E:create_entity("decal_moon_activated")
e.render.sprites[1].name="Halloween_stg20_house_0001"
e.render.sprites[1].anchor.y=0.1746031746031746
e.render.sprites[2].name="Halloween_stg20_house_0002"
e.render.sprites[2].anchor.y=0.1746031746031746
e.pos.x,e.pos.y=935,580
LU.queue_insert(store,e)
e=E:create_entity("decal")
e.render.sprites[1].name="decal_water_sparks_20_idle"
e.render.sprites[1].ts=U.frandom(0,0.5)
e.render.sprites[1].z=Z_DECALS
e.pos=v(705,325)
LU.queue_insert(store,e)
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
self.moon_controller.waves={{1,fts(3000),15},{4,fts(1250),18},{7,fts(1290),40},{10,fts(1500),50},{12,fts(840),39},{14,fts(700),40},{15,fts(650),33}}
elseif store.level_mode==GAME_MODE_HEROIC then
self.moon_controller.waves={{1,fts(850),15},{4,fts(1800),10},{5,fts(2100),10}}
elseif store.level_mode==GAME_MODE_IRON then
self.moon_controller.waves={{1,fts(700),15},{1,fts(2700),15},{1,fts(4500),15},{1,fts(10600),30}}
end
e=E:create_entity("points_spawner")
LU.queue_insert(store,e)
self.points_spawner=e
e.spawner_points={{path=1,from=v(180,528),to=v(259,516)},{path=1,from=v(253,617),to=v(274,546)},{path=1,from=v(450,655),to=v(432,598)},{path=1,from=v(593,535),to=v(548,586)},{path=1,from=v(443,524),to=v(444,586)},{path=2,from=v(589,452),to=v(551,393)},{path=2,from=v(436,477),to=v(398,431)},{path=3,from=v(249,179),to=v(224,230)},{path=3,from=v(253,353),to=v(325,322)},{path=4,from=v(628,236),to=v(570,239)},{path=5,from=v(628,236),to=v(570,239)},{path=6,from=v(862,598),to=v(831,618)},{path=7,from=v(858,582),to=v(825,567)},{path=8,from=v(864,566),to=v(837,543)},{path=9,from=v(932,545),to=v(944,511)},{from=v(950,391),to=v(812,391)},{from=v(812,391),to=v(560,391)},{from=v(560,391),to=v(400,391)},{from=v(590,588),to=v(430,588)},{from=v(620,222),to=v(545,222)},{from=v(580,222),to=v(440,222)}}
e.spawner_groups={[100]={3,4,6,10},[101]={3,4,5},[102]={6,4,5,7},[200]={12,13,14,15},[666]={2,3,4,5,6,7,9,10,11}}
if store.level_mode==GAME_MODE_CAMPAIGN then
e.spawner_waves={{{100.33333333333333,0.5,100,0,2,true,1,3,"enemy_halloween_zombie"}},{{28.333333333333332,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=5,s_paths={2,4},s_list={{4,"enemy_halloween_zombie"}}}},{40,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.3,lifespan=40,s_paths={2,4},s_list={{3,"enemy_halloween_zombie"}}}}},{{7,0.5,101,0,2,true,1,4,"enemy_halloween_zombie"},{10,0.5,10,0,4,true,1,4,"enemy_halloween_zombie"},{43.333333333333336,0.5,10,0,8,true,1,4,"enemy_halloween_zombie"}},{{42,2.5,10,0,7,true,1,3,"enemy_halloween_zombie"},{42,2,6,0,4,false,2,4,"enemy_halloween_zombie"}},[6]={{33.333333333333336,0,20,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=5,s_paths={5},s_list={{3,"enemy_halloween_zombie"}}}},{45,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=40,s_paths={2,3},s_list={{7,"enemy_halloween_zombie"}}}}},[7]={{43,2.5,200,0,3,true,3,6,"enemy_ghost"}},[9]={{3.3333333333333335,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=12,s_paths={2,3},s_list={{7,"enemy_ghoul"}}}},{23.333333333333332,0,20,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=5,s_paths={5},s_list={{7,"enemy_ghoul"}}}},{40,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.7,lifespan=12,s_paths={3},s_list={{7,"enemy_ghoul"}}}},{60,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.8,lifespan=40,s_paths={2,3},s_list={{7,"enemy_ghoul"}}}}},[10]={{50.333333333333336,2.5,101,0,4,true,2,4,"enemy_halloween_zombie"},{71.33333333333333,2,200,0,3,true,6,8,"enemy_ghost"}},[12]={{2,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=20,s_paths={2,3},s_list={{10,"enemy_halloween_zombie"},{5,"enemy_ghoul"}}}},{28,0,19,1,1,false,0,0,"enemy_headless_horseman",{lifespan=6}},{40,0,21,1,1,false,0,0,"enemy_headless_horseman",{lifespan=6}},{53.333333333333336,0,17,1,1,false,0,0,"enemy_headless_horseman",{lifespan=2}},{60,0,18,1,1,false,0,0,"enemy_headless_horseman",{lifespan=40}}},[13]={{10.333333333333334,2.5,666,0,2,true,2,7,"enemy_ghoul"},{38.666666666666664,3.5,101,0,5,true,4,7,"enemy_ghoul"},{33.333333333333336,3.5,102,0,10,true,3,5,"enemy_halloween_zombie"}},[14]={{23.666666666666668,2.5,666,0,2,true,4,7,"enemy_halloween_zombie"},{35.333333333333336,3.5,200,0,3,true,4,6,"enemy_ghost"},{55.333333333333336,5.5,200,0,3,true,12,12,"enemy_ghost"},{3.3333333333333335,0,21,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=10,s_paths={5},s_list={{3,"enemy_ghoul"}}}},{23.333333333333332,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=12,s_paths={2,3},s_list={{5,"enemy_halloween_zombie"}}}},{43.333333333333336,0,21,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=20,s_paths={5},s_list={{3,"enemy_ghoul"}}}},{66.66666666666667,0,19,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=20,s_paths={1},s_list={{5,"enemy_ghoul"}}}}},[15]={{23.333333333333332,3.5,200,0,2,true,3,4,"enemy_ghost"},{40,3.5,200,0,3,true,3,4,"enemy_ghost"},{23.333333333333332,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=4,s_paths={2},s_list={{3,"enemy_ghoul"}}}},{30,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=11,s_paths={2,3},s_list={{3,"enemy_halloween_zombie"}}}},{45,0,19,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=6,s_paths={1},s_list={{3,"enemy_ghoul"}}}},{66.66666666666667,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=30,s_paths={2,3},s_list={{3,"enemy_halloween_zombie"}}}}}}
elseif store.level_mode==GAME_MODE_HEROIC then
e.spawner_waves={{{3.3333333333333335,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=1,lifespan=5,s_paths={2},s_list={{3,"enemy_ghost"}}}}},{{30,3.5,101,0,1,true,5,6,"enemy_ghost"},{30,3.5,12,0,2,true,4,6,"enemy_ghost"},{31.666666666666668,3.5,13,0,2,true,4,6,"enemy_ghost"},{3.3333333333333335,0,21,1,1,false,0,0,"enemy_headless_horseman",{s_delay=1,lifespan=15,s_paths={4},s_list={{4,"enemy_halloween_zombie"}}}}},{{83.33333333333333,3.5,200,0,6,true,5,7,"enemy_ghost"},{23.333333333333332,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=1.5,lifespan=5,s_paths={2,3},s_list={{3,"enemy_ghost"}}}}},{{60,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=10,s_paths={2,3},s_list={{10,"enemy_halloween_zombie"}}}},{73.33333333333333,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=26,s_paths={3},s_list={{10,"enemy_halloween_zombie"}}}}},{{70,3.5,200,0,2,true,6,7,"enemy_ghost"},{70,3.5,666,0,2,true,6,10,"enemy_halloween_zombie"}},{{36.666666666666664,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=10,s_paths={2,3},s_list={{5,"enemy_halloween_zombie"}}}},{56.666666666666664,0,19,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=15,s_paths={1},s_list={{5,"enemy_halloween_zombie"}}}},{88.33333333333333,0,21,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.5,lifespan=15,s_paths={5},s_list={{3,"enemy_halloween_zombie"}}}}}}
elseif store.level_mode==GAME_MODE_IRON then
local t=E:get_template("enemy_headless_horseman")
t.ranged.attacks[1].cooldown=3
t.ranged.attacks[1].max_range=290
t=E:get_template("headless_horseman_pumpkin")
t.bullet.damage_min=100
t.bullet.damage_max=100
e.spawner_waves={{{0.3333333333333333,0,17,1,1,false,0,0,"enemy_headless_horseman",{lifespan=15}},{20,0,21,1,1,false,0,0,"enemy_headless_horseman",{lifespan=12}},{43.333333333333336,0,19,1,1,false,0,0,"enemy_headless_horseman",{lifespan=10}},{63.333333333333336,0,18,1,1,false,0,0,"enemy_headless_horseman",{lifespan=10}},{100,0,16,1,1,false,0,0,"enemy_headless_horseman",{lifespan=15}},{125,0,17,1,1,false,0,0,"enemy_headless_horseman",{lifespan=10}},{150,0,20,1,1,false,0,0,"enemy_headless_horseman",{lifespan=20}},{200,0,19,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=5,s_paths={1},s_list={{3,"enemy_halloween_zombie"}}}},{208.33333333333334,0,20,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=5,s_paths={4,5},s_list={{4,"enemy_halloween_zombie"}}}},{216,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=5,s_paths={2,3},s_list={{7,"enemy_halloween_zombie"}}}},{224,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=20,s_paths={2,3},s_list={{3,"enemy_halloween_zombie"}}}},{233.33333333333334,3.5,666,0,3,true,5,8,"enemy_halloween_zombie"},{250,3.5,10,0,3,true,5,6,"enemy_halloween_zombie"},{250,0,18,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=25,s_paths={2,3},s_list={{7,"enemy_halloween_zombie"}}}},{276.6666666666667,0,17,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=4,s_paths={2,3},s_list={{4,"enemy_halloween_zombie"}}}},{285,0,16,1,1,false,0,0,"enemy_headless_horseman",{s_delay=0.4,lifespan=10,s_paths={2,3},s_list={{0,"enemy_halloween_zombie"}}}}}}
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
