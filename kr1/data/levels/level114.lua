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
local blocked_cells={{14,19},{15,19},{10,18},{11,18},{12,18},{13,18},{14,18},{15,18},{16,18},{17,18},{6,17},{7,17},{8,17},{9,17},{10,17},{11,17},{12,17},{13,17},{14,17},{15,17},{16,17},{17,17},{18,17},{19,17},{2,16},{3,16},{4,16},{5,16},{6,16},{7,16},{8,16},{9,16},{10,16},{11,16},{12,16},{13,16},{14,16},{15,16},{16,16},{17,16},{18,16},{19,16},{20,16},{2,15},{3,15},{4,15},{5,15},{6,15},{7,15},{8,15},{9,15},{10,15},{11,15}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:init(store)
require("lib.klua.table")
local scripts=require("scripts")
local aura_stage_14_prevent_polymorph_update
aura_stage_14_prevent_polymorph_update=function(this,store)
local first_hit_ts
local last_hit_ts=0
local cycles_count=0
last_hit_ts=store.tick_ts-this.aura.cycle_time
while true do
if store.tick_ts-last_hit_ts>=this.aura.cycle_time then
first_hit_ts=first_hit_ts or store.tick_ts
last_hit_ts=store.tick_ts
cycles_count=cycles_count+1
local targets=table.filter(store.enemies,function(k,v)
return v.unit and v.health and not v.health.dead and U.is_inside_ellipse(v.pos,this.pos,this.aura.radius) and not U.flag_has(v.vis.bans,F_POLYMORPH) and (v.nav_path.pi==2 or v.nav_path.pi==3) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates,v.template_name))
end)
for i,target in ipairs(targets) do
target.vis.bans=U.flag_set(target.vis.bans,F_POLYMORPH)
end
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
end
local tt
tt=E:register_t_hot("decal_terrain_3_glare_eye_big_stage_14","decal_terrain_3_glare_eye_big",true)
tt.render.sprites[1].name="glare_stage_14_eye_2_big"
tt.render.sprites[2].prefix="glare_stage_14_eyelid_2_big"
tt.render.sprites[3].prefix="glare_stage_14_eye_2_big_pupil"
tt=E:register_t_hot("decal_stage_14_mask_amalgam","decal_stage_14_mask_1",true)
tt.render.sprites[1].name="T3_S14_mask_amalgam"
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=90
tt=E:register_t_hot("decal_stage_14_glare_1","decal_stage_12_glare",true)
tt.render.sprites[1].prefix="stage_14_glare_1Def"
tt=E:register_t_hot("decal_terrain_3_glare_eye_small_3_stage_14","decal_terrain_3_glare_eye_small",true)
tt.render.sprites[1].prefix="glare_stage_14_eye_2_3"
tt.render.sprites[2].prefix="glare_stage_14_eyelid_2_3"
tt=E:register_t_hot("decal_stage_14_mask_3","decal_stage_14_mask_1",true)
tt.render.sprites[1].name="T3_S14_mask_03"
tt=E:register_t_hot("decal_stage_14_glare_2","decal_stage_12_glare",true)
tt.render.sprites[1].prefix="stage_14_glare_2Def"
tt=E:register_t_hot("decal_terrain_3_glare_eye_small_2_stage_14","decal_terrain_3_glare_eye_small",true)
tt.render.sprites[1].prefix="glare_stage_14_eye_2_2"
tt.render.sprites[2].prefix="glare_stage_14_eyelid_2_2"
tt=E:register_t_hot("decal_stage_14_hidden_path_dust","decal",true)
tt.render.sprites[1].prefix="dust_pathDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("decal_stage_14_tentacles","decal_stage_12_tentacles",true)
tt.render.sprites[1].prefix="BKtentacle14Def"
tt=E:register_t_hot("decal_stage_14_mask_2","decal_stage_14_mask_1",true)
tt.render.sprites[1].name="T3_S14_mask_02"
tt=E:register_t_hot("aura_stage_14_prevent_polymorph","aura",true)
tt.aura.duration=1e+99
tt.aura.cycle_time=0.25
tt.aura.radius=100
tt.aura.allowed_templates={"enemy_glareling"}
tt.main_script.update=aura_stage_14_prevent_polymorph_update
tt=E:register_t_hot("decal_stage_14_mask_4","decal_stage_14_mask_1",true)
tt.render.sprites[1].name="T3_S14_mask_04"
tt=E:register_t_hot("decal_terrain_3_glare_eye_small_1_stage_14","decal_terrain_3_glare_eye_small",true)
tt.render.sprites[1].prefix="glare_stage_14_eye_2_1"
tt.render.sprites[2].prefix="glare_stage_14_eyelid_2_1"
tt=E:register_t_hot("decal_stage_14_hidden_path","decal",true)
tt.render.sprites[1].prefix="hidden_pathDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
end
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
P:deactivate_path(5)
while store.wave_group_number<10 do
coroutine.yield()
end
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_14_hidden_path" then
U.animation_start_default(v,"run",nil,store.tick_ts,false)
break
end
end
S:queue("Stage14NewPath")
local hidden_path_dust=E:create_entity("decal_stage_14_hidden_path_dust")
hidden_path_dust.pos=V.v(512,384)
LU.queue_insert(store,hidden_path_dust)
U.animation_start_default(hidden_path_dust,"run",nil,store.tick_ts)
U.y_wait_unconditional(store,1)
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.2
shake.aura.duration=1
shake.aura.freq_factor=4
LU.queue_insert(store,shake)
U.y_animation_wait_default(hidden_path_dust)
LU.queue_remove(store,hidden_path_dust)
P:activate_path(5)
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
if store.level.ignore_walk_backwards_paths then
for k,v in pairs(store.level.ignore_walk_backwards_paths) do
if v==5 or v==8 then
store.level.ignore_walk_backwards_paths[k]=nil
end
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
else
if store.level_mode==GAME_MODE_IRON then
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="11"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="13"
end)[1]
holder.tower.upgrade_to="tower_barrack_1"
coroutine.yield()
store.player_gold=starting_gold
end
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_14_hidden_path" then
U.animation_start_default(v,"end",nil,store.tick_ts,false)
break
end
end
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
