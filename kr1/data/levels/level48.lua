local log=require("lib.klua.log"):new("level22")
local bit=require("bit")
local signal=require("lib.hump.signal")
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
level.required_sounds={"music_stage48","FrontiersUndergroundAmbienceSounds","SaurianKingBoss","SaurianSniperSounds","DwarfSounds"}
level.required_textures={"go_enemies_underground","go_stages_underground","go_stage48","go_stage48_bg"}
level.show_comic_idx=18
function level:init(store)
local E=require("entity_db")
local U=require("utils")
local LU=require("level_utils")
local A=require("achievements")
local scripts=require("scripts")
require("all.constants")
require("lib.klua.table")
local v=V.v
local r=V.r
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function decal_stage22_reptile_update(this,store)
while true do
if this.ui.clicked then
U.y_animation_play(this,"clicked",nil,store.tick_ts)
U.animation_start_default(this,"climb",nil,store.tick_ts,true)
U.set_destination(this,v(this.pos.x,this.pos.y+this.climb_distance))
while not U.walk_off__accel__unsnapped(this,store.tick_length) do
coroutine.yield()
end
simulation:queue_remove_entity(this)
return
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_moria_gate","decal_scripted",true)
AC(tt,"tween","ui")
tt.render.sprites[1].name="moria_0001"
tt.render.sprites[1].animated=false
tt.render.sprites[1].alpha=100
tt.render.sprites[1].anchor.y=0
tt.render.sprites[2]=CC("sprite")
tt.render.sprites[2].name="moria_0002"
tt.render.sprites[2].animated=false
tt.render.sprites[2].alpha=0
tt.render.sprites[2].anchor.y=0
tt.tween.disabled=true
tt.tween.remove=false
tt.tween.props[1].sprite_id=2
tt.tween.props[1].keys={{0,0},{0.6,255},{0.9,150}}
tt.main_script.update=scripts.click_run_tween.update
tt.ui.click_rect=r(-25,0,50,80)
tt=E:register_t_hot("decal_stage22_reptile","decal_scripted",true)
AC(tt,"ui","motion")
tt.render.sprites[1].prefix="decal_stage22_reptile"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].anchor=vec_2(0.6935483870967742,0.05555555555555555)
tt.ui.click_rect=r(-15,-5,30,40)
tt.main_script.update=decal_stage22_reptile_update
tt.climb_distance=140
tt.motion.max_speed=2*FPS
store.level_terrain_style=TERRAIN_STYLE_UNDERGROUND
self.locations=LU.load_locations(store,self)
self.locked_hero=false
self.max_upgrade_level=6
self.locked_towers={}
self.locked_powers={}
if store.level_mode==GAME_MODE_IRON then
self.locked_towers={"tower_build_mage","tower_build_barrack"}
end
end
function level:load(store)
LU.insert_background(store,"Stage22_0001",Z_BACKGROUND)
LU.insert_background(store,"Stage22_0002",Z_BACKGROUND_COVERS)
LU.insert_defend_points(store,self.locations.exits,store.level_terrain_style)
for _,h in pairs(self.locations.holders) do
if store.level_mode==GAME_MODE_IRON and table.contains({"4","6","12"},h.id) or store.level_mode~=GAME_MODE_IRON and h.id=="16" then
e=LU.insert_tower(store,"tower_barrack_dwarf",h.style,h.pos,h.rally_pos,nil,h.id)
else
LU.insert_tower(store,"tower_holder",h.style,h.pos,h.rally_pos,nil,h.id)
end
end
local x
self.nav_mesh={{10,2,x,9},{3,x,1,10},{4,x,2,11},{5,x,3,12},{6,4,4,6},{x,5,13,7},{6,6,16,16},{16,11,9,x},{8,10,1,x},{11,2,1,9},{12,3,10,8},{13,4,11,16},{6,4,12,16},[16]={7,13,8,8}}
P:add_invalid_range(5,nil,60,NF_TWISTER)
local e
local lamps={v(23,164),v(23,258),v(35,375),v(116,398),v(26,525),v(88,577),v(466,661),v(972,546),v(654,145)}
for _,p in pairs(lamps) do
e=E:create_entity("decal")
e.render.sprites[1].name="underground_burner"
e.render.sprites[1].ts=-1*U.frandom(0,0.5)
e.render.sprites[1].anchor.y=0
e.pos=p
LU.queue_insert(store,e)
end
e=E:create_entity("decal_moria_gate")
e.pos=v(902,192)
LU.queue_insert(store,e)
e=E:create_entity("decal_stage22_reptile")
e.pos=v(914,645)
LU.queue_insert(store,e)
e=E:create_entity("background_sounds_underground")
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
if store.level_mode==GAME_MODE_CAMPAIGN then
U.y_wait_unconditional(store,3)
end
log.debug("-- WON")
end
return level
