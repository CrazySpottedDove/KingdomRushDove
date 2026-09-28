local log=require("lib.klua.log"):new("level06")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
require("all.constants")
local level={}
level.required_sounds={"music_stage32","BossEfreeti"}
level.required_textures={"go_enemies_desert","go_stages_desert","go_stage32","go_stage32_bg"}
function level:init(store)
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
require("all.constants")
require("lib.klua.table")
local v=V.v
local function decal_efreeti_door_update(this,store)
local floor_sid,door_sid,statue_left_sid,statue_right_sid,eyes_sid,eyes_fx_sid=1,2,4,5,6,7
while true do
while this.phase~="eyes" do
coroutine.yield()
end
local eyes,eyesfx=this.render.sprites[eyes_sid],this.render.sprites[eyes_fx_sid]
eyes.ts=store.tick_ts
eyes.hidden=false
S:queue("BossEfreetiSpawnBoss")
U.y_wait_unconditional(store,1.5)
this.phase="show_boss"
eyesfx.ts=store.tick_ts
eyesfx.hidden=false
U.y_animation_wait(this,eyes_sid)
eyes.hidden=true
eyesfx.hidden=true
while this.phase~="destruction" do
coroutine.yield()
end
U.animation_start(this,"destruction",nil,store.tick_ts,false,door_sid)
U.animation_start(this,"destruction",nil,store.tick_ts,false,floor_sid)
S:queue("BossEfreetiDoors")
U.y_wait_unconditional(store,0.9)
for _,p in pairs(this.smoke_positions) do
local fx=E:create_entity("fx")
fx.pos.x,fx.pos.y=p.x,p.y
fx.render.sprites[1].name="efreeti_door_smoke"
fx.render.sprites[1].ts=store.tick_ts
simulation:queue_insert_entity(fx)
end
for _,p in pairs(this.stone_positions) do
local fx=E:create_entity("fx")
fx.pos.x,fx.pos.y=p[1].x,p[1].y
fx.render.sprites[1].name="efreeti_door_stone"
fx.render.sprites[1].ts=store.tick_ts
fx.render.sprites[1].scale=v(p[2],p[2])
fx.render.sprites[1].flip_x=p[3]
simulation:queue_insert_entity(fx)
end
this.render.sprites[statue_left_sid].name="left"
this.render.sprites[statue_right_sid].name="right"
U.y_animation_wait(this,floor_sid)
this.render.sprites[floor_sid].hidden=true
U.y_wait_unconditional(store,3)
this.phase="finished"
end
end
local tt
tt=E:register_t_hot("decal_efreeti_tent","decal",true)
tt.render.sprites[1].name="boss_corps_efreeti"
tt.render.sprites[1].animated=false
tt=E:register_t_hot("decal_efreeti_door","decal_scripted",true)
tt.main_script.update=decal_efreeti_door_update
tt.smoke_positions={vec_2(521,674),vec_2(618,642)}
tt.stone_positions={{vec_2(599,664),1,false},{vec_2(688,592),0.8,false},{vec_2(479,647),0.8,false},{vec_2(519,682),1,true},{vec_2(625,608),0.8,true},{vec_2(416,663),0.8,true}}
tt.render.sprites[1].prefix="efreeti_door_floor"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].loop=false
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].prefix="efreeti_door"
tt.render.sprites[2].name="idle"
tt.render.sprites[2].loop=false
tt.render.sprites[3]=CC("sprite")
tt.render.sprites[3].name="Stage06_0003"
tt.render.sprites[3].animated=false
tt.render.sprites[4]=CC("sprite")
tt.render.sprites[4].prefix="efreeti_statue"
tt.render.sprites[4].name="idle"
tt.render.sprites[4].offset=vec_2(-139,-66)
tt.render.sprites[4].anchor.y=0.08
tt.render.sprites[5]=CC("sprite")
tt.render.sprites[5].prefix="efreeti_statue"
tt.render.sprites[5].name="idle"
tt.render.sprites[5].offset=vec_2(72,-120)
tt.render.sprites[5].anchor.y=0.08
tt.render.sprites[6]=CC("sprite")
tt.render.sprites[6].name="efreeti_door_eyes"
tt.render.sprites[6].offset=vec_2(-51,-55)
tt.render.sprites[6].hidden=true
tt.render.sprites[6].loop=false
tt.render.sprites[7]=CC("sprite")
tt.render.sprites[7].name="efreeti_door_eyes_effect"
tt.render.sprites[7].offset=vec_2(-51,-55)
tt.render.sprites[7].hidden=true
tt.render.sprites[7].loop=false
tt=E:register_t_hot("decal_efreeti_door_broken","decal",true)
tt.render.sprites[1]=CC("sprite")
tt.render.sprites[1].name="efreeti_statue_left"
tt.render.sprites[1].offset=vec_2(-139,-66)
tt.render.sprites[1].anchor.y=0.08
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="efreeti_statue_right"
tt.render.sprites[2].offset=vec_2(72,-120)
tt.render.sprites[2].anchor.y=0.08
store.level_terrain_style=TERRAIN_STYLE_DESERT
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
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
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
U.y_wait_unconditional(store,2)
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
U.y_wait_unconditional(store,5)
self.door.phase="destruction"
while self.door.phase~="finished" do
coroutine.yield()
end
log.debug("--- WON ")
end
end
return level
