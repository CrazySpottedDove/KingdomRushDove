local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
require("lib.klua.table")
local scripts=require("scripts")
local GR=require("grid_db")
local r=V.r
local decal_stage_07_temple_update
local controller_stage_07_crows_update
local stage_07_witcher_update
decal_stage_07_temple_update=function(this,store)
local freed_cells={{30,35},{31,35},{32,35},{33,35},{34,35},{35,35},{29,34},{30,34},{31,34},{32,34},{33,34},{34,34},{35,34},{36,34},{29,33},{30,33},{31,33},{32,33},{33,33},{34,33},{35,33},{36,33},{37,33},{38,33},{29,32},{30,32},{31,32},{32,32},{33,32},{34,32},{35,32},{36,32},{37,32},{38,32},{30,31},{31,31},{32,31},{33,31},{34,31},{35,31},{36,31},{37,31},{38,31},{34,30},{35,30}}
if store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_HEROIC then
else
while store.wave_group_number<this.activation_wave do
coroutine.yield()
end
S:queue(this.sound)
do
local cave_mask
for _,e in pairs(store.entities) do
if e.template_name==this.cave_mask then
cave_mask=e
break
end
end
cave_mask.render.sprites[1].hidden=true
end
do
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.4
shake.aura.duration=4
shake.aura.freq_factor=2
simulation:queue_insert_entity(shake)
end
U.animation_start_default(this,"temple_in",nil,store.tick_ts,false)
U.y_wait_unconditional(store,4)
do
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.6
shake.aura.duration=0.8
shake.aura.freq_factor=4
simulation:queue_insert_entity(shake)
end
U.y_animation_wait_default(this)
end
do
local mask
for _,e in pairs(store.entities) do
if e.template_name==this.temple_mask then
mask=e
break
end
end
mask.render.sprites[1].hidden=false
end
for _,cell in ipairs(freed_cells) do
GR:set_cell(cell[1],cell[2],bor(TERRAIN_LAND,TERRAIN_ICE))
end
P:remove_invalid_range(4,33,57)
P:remove_invalid_range(5,33,57)
store.level.ignore_walk_backwards_paths={4,5}
while true do
U.y_animation_play(this,"idle_in",nil,store.tick_ts)
coroutine.yield()
end
end
controller_stage_07_crows_update=function(this,store)
local crows={}
local count=1
for _,v in pairs(store.entities) do
if string.find(v.template_name,"decal_stage_07_crow_clickable") then
crows[count]=v
count=count+1
end
end
while true do
local all_away=true
for k,v in pairs(crows) do
if v~=nil and not v.gone_away then
all_away=false
break
end
end
if all_away then
signal.emit("crows-stage07",this)
break
end
coroutine.yield()
end
end
stage_07_witcher_update=function(this,store)
while store.wave_group_number<=0 do
coroutine.yield()
end
local last_show=store.tick_ts
local time_hiding=math.random(5,10)
U.animation_start_default(this,"idle",false,store.tick_ts,true)
while true do
if time_hiding<store.tick_ts-last_show then
U.y_animation_play(this,"in",nil,store.tick_ts,1)
local time_showing=math.random(1.5,2.5)
local start_time=store.tick_ts
U.animation_start_default(this,"idle_leshy",false,store.tick_ts,true)
while time_showing>store.tick_ts-start_time do
if this.ui.clicked then
this.ui.clicked=nil
S:queue("Stage07Witcher")
U.y_animation_play(this,"action",nil,store.tick_ts,1)
signal.emit("witcher-stage07",this)
goto label_1072_0
end
coroutine.yield()
end
U.y_animation_play(this,"out",nil,store.tick_ts,1)
U.animation_start_default(this,"idle",false,store.tick_ts,true)
last_show=store.tick_ts
end
coroutine.yield()
end
::label_1072_0::
return true
end
local tt
tt=E:register_t_hot("decal_stage_07_crow_clickable_2","decal_stage_07_crow_clickable",true)
tt.render.sprites[1].prefix="stage_7_crow2Def"
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("controller_stage_07_crows",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_07_crows_update
tt=E:register_t_hot("decal_stage_07_mask","decal",true)
tt.render.sprites[1].name="T2_Stage_7_mask"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_07_crow_clickable_1","decal_stage_07_crow_clickable",true)
tt.render.sprites[1].prefix="stage_7_crow1Def"
tt=E:register_t_hot("decal_stage_07_witcher_easter_egg","decal_scripted",true)
E:add_comps(tt,"editor","ui")
tt.render.sprites[1].prefix="the_witcherDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.main_script.update=stage_07_witcher_update
tt.ui.click_rect=r(520,-220,50,50)
tt=E:register_t_hot("decal_stage_07_crow_clickable_4","decal_stage_07_crow_clickable",true)
tt.render.sprites[1].prefix="stage_7_crow4Def"
tt.render.sprites[1].z=Z_FLYING_HEROES-1
tt=E:register_t_hot("decal_stage_07_temple_mask","decal",true)
tt.render.sprites[1].prefix="temple_maskDef"
tt.render.sprites[1].name="idle_in"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].hidden=true
tt=E:register_t_hot("decal_stage_07_fireMask","decal",true)
tt.render.sprites[1].prefix="fire_maskDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS-1
tt=E:register_t_hot("decal_stage_07_dust","decal_terrain_2_dust",true)
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt.render.sprites[1].random_ts=1
tt=E:register_t_hot("decal_stage_07_crow_clickable_3","decal_stage_07_crow_clickable",true)
tt.render.sprites[1].prefix="stage_7_crow3Def"
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_stage_07_crow_clickable_5","decal_stage_07_crow_clickable",true)
tt.render.sprites[1].prefix="stage_7_crow5Def"
tt.render.sprites[1].flip_x=true
tt=E:register_t_hot("decal_stage_07_cave_mask_smoke","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="T2_Stage_7_mask_cave"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_07_temple","decal_scripted",true)
tt.render.sprites[1].prefix="templeDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.main_script.update=decal_stage_07_temple_update
tt.activation_wave=10
tt.temple_mask="decal_stage_07_temple_mask"
tt.cave_mask="decal_stage_07_cave_mask_smoke"
tt.sound="Stage07CultTemple"
tt=E:register_t_hot("decal_stage_07_fire","decal",true)
tt.render.sprites[1].prefix="fireDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS-1
end
function level:update(store)
P:add_invalid_range(4,31,55,NF_NO_SHADOW)
P:add_invalid_range(5,31,55,NF_NO_SHADOW)
P:add_invalid_range(4,P:get_start_node(4),P:get_start_node(4)+8)
P:add_invalid_range(5,P:get_start_node(5),P:get_start_node(5)+8)
P:add_invalid_range(6,P:get_start_node(6),P:get_start_node(6)+14)
P:add_invalid_range(7,P:get_start_node(7),P:get_start_node(7)+14)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
if store.level_mode==GAME_MODE_CAMPAIGN then
end
end
return level
