local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local storage=require("all.storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local level={}
function level:init(store)
require("lib.klua.table")
local scripts=require("scripts")
local v=V.v
local r=V.r
local decal_stage_36_easter_egg_ranger_verde_update
local controller_stage_36_portal_splash_update
decal_stage_36_easter_egg_ranger_verde_update=function(this,store,script)
local next_rayo_ts=store.tick_ts
local clics=0
while true do
if this.ui.clicked then
this.ui.clicked=nil
this.ui.can_click=false
clics=clics+1
if clics==1 then
S:queue("Stage36EasterEggGreenRangerPart1")
U.y_animation_play(this,"transform",nil,store.tick_ts,1,1)
U.animation_start(this,"ranger_idle",nil,store.tick_ts,true,1,true)
elseif clics==2 then
S:queue("Stage36EasterEggGreenRangerPart2")
U.y_animation_play(this,"tap_2",nil,store.tick_ts,1,1)
simulation:queue_remove_entity(this)
return
end
this.ui.can_click=true
end
if clics==1 and next_rayo_ts<store.tick_ts then
U.y_animation_play(this,"ranger_idle_rayo",nil,store.tick_ts,1,1)
U.animation_start(this,"ranger_idle",nil,store.tick_ts,true,1,true)
next_rayo_ts=store.tick_ts+2+U.frandom(0,2)
end
coroutine.yield()
end
end
controller_stage_36_portal_splash_update=function(this,store)
while true do
local enemies=table.filter(store.entities,function(k,v)
if v.pending_removal then
return false
end
if not v.enemy or not v.vis or not v.nav_path then
return false
end
if band(v.vis.flags,this.vis_bans)~=0 then
return false
end
if band(v.vis.bans,this.vis_flags)~=0 then
return false
end
if not this.paths_nodes[v.nav_path.pi] then
return false
end
if v.nav_path.ni>this.paths_nodes[v.nav_path.pi] then
return false
end
if v.passed_portal_tunnel then
return false
end
return true
end)
if #enemies>0 then
for _,e in ipairs(enemies) do
local mod=E:create_entity(this.mod)
mod.modifier.target_id=e.id
mod.modifier.source_id=this.id
simulation:queue_insert_entity(mod)
e.passed_portal_tunnel=true
end
end
coroutine.yield()
end
end
local tt
tt=E:register_t_hot("decal_stage_36_mask_1","decal",true)
tt.render.sprites[1].name="stage_36_mask_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=0
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt=E:register_t_hot("controller_stage_36_portal_splash",nil,true)
E:add_comps(tt,"main_script")
tt.main_script.update=controller_stage_36_portal_splash_update
tt.mod="mod_stage_36_portal_splash"
tt.paths_nodes={23,23,23,23}
tt.vis_flags=0
tt.vis_bans=0
tt=E:register_t_hot("decal_stage_36_mask_portal","decal",true)
tt.render.sprites[1].prefix="stage_1_portalDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].sort_y_offset=25
tt=E:register_t_hot("stage_36_paths_controller","decal_scripted",true)
E:add_comps(tt,"events","editor")
tt.main_script.update=scripts.stage_36_paths_controller.update
tt.render.sprites[1].prefix="mecanica_camino_1_stage_1Def"
tt.render.sprites[1].name="in"
tt.render.sprites[1].exo=true
tt.render.sprites[1].hidden=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[2]=E:clone_c("sprite")
tt.render.sprites[2].prefix="mecanica_camino_2_stage_1Def"
tt.render.sprites[2].name="in"
tt.render.sprites[2].exo=true
tt.render.sprites[2].hidden=true
tt.render.sprites[2].z=Z_BACKGROUND_BETWEEN
tt.events.list[1].name="show_path"
tt.events.list[1].on_event=scripts.stage_36_paths_controller.on_show_path
tt.holders_list={{{ts=fts(92),pos=v(727,517)},{shake=true,ts=fts(120)}},{{ts=fts(80),pos=v(184,573)},{ts=fts(88),pos=v(64,451)},{objects=true,shake=true,ts=fts(126)}}}
tt.path_unlocks={{islands_required={1},paths={3},terrain_paths={3},extra_terrains={{radius=64,x=730,y=510,terrain_type=bor(TERRAIN_LAND,TERRAIN_NOWALK)}}},{islands_required={2},paths={2},terrain_paths={2},extra_terrains={}},{islands_required={1,2},paths={4},terrain_paths={},extra_terrains={}}}
tt.hide_exits_rects={{pos=v(-REF_W,384),size=v(REF_W,REF_H)}}
tt.cinematic={[2]={zoom=1,time=fts(67),pos=v(200,600)}}
tt.show_fx="fx_stage_36_path_dust"
tt.editor.overrides={["render.sprites[1].hidden"]=false,["render.sprites[1].name"]="idle"}
tt=E:register_t_hot("decal_stage_36_easter_egg_ranger_verde","decal_scripted",true)
E:add_comps(tt,"ui","editor")
tt.main_script.update=decal_stage_36_easter_egg_ranger_verde_update
tt.render.sprites[1].prefix="ranger_verde_character"
tt.render.sprites[1].name="idle1"
tt.ui.click_rect=r(-25,-10,50,50)
tt=E:register_t_hot("decal_stage_36_mask_path_main","decal",true)
tt.render.sprites[1].name="stage_36_mask_path"
tt.render.sprites[1].animated=false
tt.render.sprites[1].sort_y_offset=0
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
end
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=20
end
end
function level:load(store)
return
end
function level:update(store)
for i=1,4 do
local invalid_range_end_ni=P:nearest_nodes(1025,505,{i})[1][3]
P:add_invalid_range(i,0,invalid_range_end_ni)
end
if store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_HEROIC then
local controller
for _,v in pairs(store.entities) do
if v.template_name=="stage_36_paths_controller" then
controller=v
break
end
end
controller.modos=true
P:activate_path(2)
P:activate_path(3)
P:activate_path(4)
else
signal.emit("wave-notification","view","TOWER_DRAGONS")
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
return level
