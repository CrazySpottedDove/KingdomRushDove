local log=require("klua.log"):new("level01")
local signal=require("hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("klua.vector")
local P=require("path_db")
local storage=require("storage")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local mask_phase1_burned,mask_phase2_burned,mask_phase3_burned,exo_fire_a,exo_fire_b,exo_fire_c,exo_forest_1,exo_forest_2,exo_forest_3
local holders_phase_1_ids={"9","10"}
local holders_phase_2_ids={"7","8"}
local holders_phase_3_ids={"12"}
local walkable_cells_phase2={{68,36},{69,35},{69,34},{70,34},{71,34},{71,33},{72,33},{73,33}}
local walkable_cells_phase3={{45,33},{46,33},{47,33},{48,33},{48,34},{49,34},{49,35},{50,35},{31,34},{31,33},{31,32},{31,31},{31,30},{31,29},{32,29},{33,29},{34,29}}
local walkable_cells_phase4={{22,15},{23,15},{23,16},{23,17},{24,17},{24,18},{25,18},{25,19},{26,19},{26,20},{27,20},{28,20},{28,21},{29,21},{29,21},{30,21},{31,21},{45,14},{46,14},{46,13},{46,12},{47,12},{47,11},{48,11},{48,10},{49,10},{49,9}}
local function update_holders(store,holders_ids)
local holders=table.filter(store.entities,function(k,v)
return v.tower and table.contains(holders_ids,v.tower.holder_id)
end)
local nh=E:get_template("tower_holder_sea_of_trees_11")
for k,v in pairs(holders) do
v.tower.terrain_style=nh.tower.terrain_style
if v.tower.type=="holder" then
v.render.sprites[1].name=nh.render.sprites[1].name
v.render.sprites[2].name=nh.render.sprites[2].name
else
v.render.sprites[1].name=nh.render.sprites[1].name
end
if v.template_name=="tower_holder_blocked_elemental_wood" then
v.render.sprites[v.render.sid_parche].name="stage_31_quemado"
end
end
end
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local function y_meteorite_shake(store,duration,on_screen)
S:queue("TerrainWukongMeteoriteCast")
local shake_travel=E:create_entity("aura_screen_shake")
shake_travel.aura.amplitude=0.4
shake_travel.aura.duration=duration
shake_travel.aura.freq_factor=5
shake_travel.aura.reverse_fade=true
LU.queue_insert(store,shake_travel)
local spawn_wait_time=1.5
U.y_wait(store,spawn_wait_time)
S:queue("TerrainWukongMeteoriteTravelLoop")
if on_screen then
local shake_transform=E:create_entity("aura_screen_shake")
shake_transform.aura.amplitude=0.9
shake_transform.aura.duration=0.7
shake_transform.aura.freq_factor=4
LU.queue_insert(store,shake_transform)
end
U.y_wait(store,duration-spawn_wait_time)
S:stop("TerrainWukongMeteoriteTravelLoop")
S:queue("TerrainWukongMeteoriteImpact")
local shake_impact=E:create_entity("aura_screen_shake")
shake_impact.aura.amplitude=2
shake_impact.aura.duration=1.5
shake_impact.aura.freq_factor=4
LU.queue_insert(store,shake_impact)
end
local function force_move_units(store,impact_positions)
local aura_force_movement=E:create_entity("aura_force_move_unit")
aura_force_movement.impact_positions=impact_positions
LU.queue_insert(store,aura_force_movement)
end
local function create_fires(store,fire_pathes)
for path,nodes in pairs(fire_pathes) do
local ni=nodes.begin
while ni<=nodes.finish do
local fx=E:create_entity("decal_dlc_wukong_flaming_ground")
fx.pos=P:node_pos(path,1,ni)
fx.render.sprites[1].scale=V.vv(0.7+0.3*math.random())
fx.render.sprites[1].flip_x=math.random()>0.5
fx.duration=5+1*math.random()
fx.start_wait=1*math.random()
LU.queue_insert(store,fx)
ni=ni+5
local fx=E:create_entity("decal_dlc_wukong_flaming_ground_small")
fx.pos=P:node_pos(path,table.random({2,3}),ni)
fx.render.sprites[1].scale=V.vv(0.8)
fx.render.sprites[1].flip_x=math.random()>0.5
fx.duration=5+1*math.random()
fx.start_wait=1*math.random()
LU.queue_insert(store,fx)
ni=ni+5
end
end
end
local function instakill_units(store,fireball_kill_area_id)
for _,v in pairs(store.entities) do
if v.template_name=="decal_generic_kill_area" and v.kill_area_id==fireball_kill_area_id then
v:kill_area_fn(store)
end
end
end
local function y_open_paths_phase2(store,animated)
if animated then
local fireball_a=E:create_entity("fx_stage_31_fireball_a")
fireball_a.pos.x,fireball_a.pos.y=512,382
fireball_a.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,fireball_a)
y_meteorite_shake(store,fts(160))
coroutine.yield()
instakill_units(store,fireball_a.kill_area_id)
for _,v in pairs(store.entities) do
if v.template_name=="decal_stage_31_easter_egg_littledragon" then
U.sprites_hide(v,1,1,true)
U.sprites_hide(v,3,3,true)
v.ui.can_click=false
break
end
end
U.y_wait(store,fts(10))
create_fires(store,{[2]={finish=60,begin=1}})
end
P:activate_path(2)
set_terrain(walkable_cells_phase2,bit.bor(TERRAIN_LAND))
update_holders(store,holders_phase_1_ids)
LU.queue_remove(store,exo_forest_1)
exo_forest_1=nil
U.sprites_show(mask_phase1_burned)
U.sprites_show(exo_fire_a)
end
local function y_open_paths_phase3(store,animated)
if animated then
local fireball_b=E:create_entity("fx_stage_31_fireball_b")
fireball_b.pos.x,fireball_b.pos.y=512,384
fireball_b.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,fireball_b)
y_meteorite_shake(store,fts(150))
coroutine.yield()
instakill_units(store,fireball_b.kill_area_id)
U.y_wait(store,fts(10))
create_fires(store,{[3]={finish=50,begin=1}})
end
P:activate_path(3)
set_terrain(walkable_cells_phase3,bit.bor(TERRAIN_LAND))
update_holders(store,holders_phase_2_ids)
LU.queue_remove(store,exo_forest_2)
exo_forest_2=nil
U.sprites_show(mask_phase2_burned)
U.sprites_show(exo_fire_b)
end
local function y_open_paths_phase4(store,animated)
if animated then
local fireball_c=E:create_entity("fx_stage_31_fireball_c")
fireball_c.pos.x,fireball_c.pos.y=512,384
fireball_c.render.sprites[1].ts=store.tick_ts
LU.queue_insert(store,fireball_c)
y_meteorite_shake(store,fts(150),true)
coroutine.yield()
instakill_units(store,fireball_c.kill_area_id)
U.y_wait(store,fts(10))
for _,v in pairs(store.entities) do
if v.template_name=="decal_achievement_saitam_stage31" then
U.sprites_hide(v,1,1,true)
v.ui.can_click=false
break
end
end
create_fires(store,{[6]={finish=80,begin=1}})
end
P:activate_path(5)
P:activate_path(6)
set_terrain(walkable_cells_phase4,bit.bor(TERRAIN_LAND))
update_holders(store,holders_phase_3_ids)
LU.queue_remove(store,exo_forest_3)
exo_forest_3=nil
U.sprites_show(mask_phase3_burned)
U.sprites_show(exo_fire_c)
end
local level={}
function level:preprocess(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
level.show_comic_idx=17
end
end
function level:load(store)
return
end
function level:update(store)
P:deactivate_path(2)
P:deactivate_path(3)
P:deactivate_path(5)
P:deactivate_path(6)
local phase_2_start_wave=3
local phase_3_start_wave=7
local phase_4_start_wave=9
for _,v in pairs(store.entities) do
if v.template_name=="stage_31_mask_burned_01" then
mask_phase1_burned=v
elseif v.template_name=="stage_31_mask_burned_02" then
mask_phase2_burned=v
elseif v.template_name=="stage_31_mask_burned_03" then
mask_phase3_burned=v
elseif v.template_name=="stage_31_exo_fire_a" then
exo_fire_a=v
elseif v.template_name=="stage_31_exo_fire_b" then
exo_fire_b=v
elseif v.template_name=="stage_31_exo_fire_c" then
exo_fire_c=v
elseif v.template_name=="stage_31_exo_forest_1" then
exo_forest_1=v
elseif v.template_name=="stage_31_exo_forest_2" then
exo_forest_2=v
elseif v.template_name=="stage_31_exo_forest_3" then
exo_forest_3=v
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
while phase_2_start_wave>store.wave_group_number do
coroutine.yield()
end
y_open_paths_phase2(store,true)
while phase_3_start_wave>store.wave_group_number do
coroutine.yield()
end
y_open_paths_phase3(store,true)
while phase_4_start_wave>store.wave_group_number do
coroutine.yield()
end
y_open_paths_phase4(store,true)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
elseif store.level_mode==GAME_MODE_IRON then
y_open_paths_phase2(store,false)
y_open_paths_phase3(store,false)
y_open_paths_phase4(store,false)
local starting_gold=store.player_gold
local holder=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="48"
end)[1]
holder.tower.upgrade_to="tower_barrel_lvl4"
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
elseif store.level_mode==GAME_MODE_HEROIC then
y_open_paths_phase2(store,false)
y_open_paths_phase3(store,false)
y_open_paths_phase4(store,false)
local starting_gold=store.player_gold
coroutine.yield()
store.player_gold=starting_gold
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
