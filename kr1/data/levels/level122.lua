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
local prebossfight_blocked_paths={9,12,19,20}
local bossfight_blocked_paths={}
local walkable_cells_bossfight={{34,32},{35,32},{36,32},{37,32},{38,32},{39,32},{40,32},{41,32},{34,31},{35,31},{36,31},{37,31},{38,31},{39,31},{40,31},{41,31},{34,30},{35,30},{36,30},{37,30},{38,30},{39,30},{40,30},{41,30},{34,29},{35,29},{36,29},{37,29},{38,29},{39,29},{40,29},{41,29},{34,28},{35,28},{36,28},{37,28},{38,28},{39,28},{40,28},{41,28},{45,20},{43,19},{44,19},{45,19},{46,19},{47,19},{48,19},{49,19},{50,19},{40,18},{41,18},{42,18},{43,18},{44,18},{45,18},{46,18},{47,18},{48,18},{49,18},{50,18},{40,17},{41,17},{42,17},{43,17},{44,17},{45,17},{46,17},{47,17},{48,17},{49,17},{50,17},{40,16},{41,16},{42,16},{43,16},{44,16},{45,16},{46,16},{47,16},{48,16},{49,16},{50,16},{40,15},{41,15},{42,15},{43,15},{44,15},{45,15},{46,15},{47,15},{48,15},{49,15},{50,15}}
local blocked_cells_heroic={}
local walkable_cells_heroic={}
local blocked_cells_iron={{44,19},{45,19},{46,19},{44,18},{45,18},{46,18},{47,18}}
local ignore_walk_backwards_paths_start={4,5,7,8,9,11,12,13,14,15,16,17,18,19,20}
local stop_ignore_walk_backwards_paths_bossfight={9,12,19,20}
local ignore_walk_backwards_paths_bossfight={4,5,7,8,10,11,15}
local ignore_walk_backwards_paths_heroic={4,5,7,8,10,11,13,14,15,16,17,18}
local walkable_cells_iron={}
local masks_heroic={"stage_22_paths_mask1","stage_22_paths_mask2","stage_22_paths_mask3","stage_22_paths_mask4"}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:load(store)
store.level.ignore_walk_backwards_paths={}
if store.level_mode==GAME_MODE_HEROIC then
for _,path in pairs(ignore_walk_backwards_paths_heroic) do
table.insert(store.level.ignore_walk_backwards_paths,path)
end
else
for _,path in pairs(ignore_walk_backwards_paths_start) do
table.insert(store.level.ignore_walk_backwards_paths,path)
end
end
if store.level_mode==GAME_MODE_IRON then
set_terrain(blocked_cells_iron,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
set_terrain(walkable_cells_iron,bit.bor(TERRAIN_LAND))
elseif store.level_mode==GAME_MODE_HEROIC then
set_terrain(walkable_cells_bossfight,bit.bor(TERRAIN_LAND))
set_terrain(blocked_cells_heroic,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
set_terrain(walkable_cells_heroic,bit.bor(TERRAIN_LAND))
end
if store.level_mode==GAME_MODE_CAMPAIGN then
for _,v in pairs(prebossfight_blocked_paths) do
P:deactivate_path(v)
end
elseif store.level_mode==GAME_MODE_HEROIC then
for _,v in pairs(bossfight_blocked_paths) do
P:deactivate_path(v)
end
elseif store.level_mode==GAME_MODE_IRON then
for _,v in pairs(prebossfight_blocked_paths) do
P:deactivate_path(v)
end
end
end
function level:update(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
self.bossfight_ended=false
local starting_gold=store.player_gold
local cinematic_tower_template=E:get_template("tower_engineer_1")
local tower_template_sounds=table.deepclone(cinematic_tower_template.sound_events)
cinematic_tower_template.sound_events={}
local tower_template_hide_dust=cinematic_tower_template.tower.hide_dust
cinematic_tower_template.tower.hide_dust=true
local cinematic_tower=table.filter(game.store.entities,function(k,e)
return e.tower and e.tower.holder_id=="4"
end)[1]
cinematic_tower.tower.upgrade_to="tower_engineer_1"
coroutine.yield()
cinematic_tower_template.sound_events=table.deepclone(tower_template_sounds)
cinematic_tower_template.tower.hide_dust=tower_template_hide_dust
store.player_gold=starting_gold
local controller_boss_prefight
for _,e in pairs(store.entities) do
if e.template_name=="controller_stage_22_boss_crocs" then
controller_boss_prefight=e
end
end
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
coroutine.yield()
signal.emit("pan-zoom-camera",25,{x=450,y=800},2,"linear")
U.y_wait(store,2.5)
signal.emit("show-balloon_tutorial","LV22_BOSS_INTRO_01",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV22_BOSS_INTRO_02",false)
U.y_wait(store,2.5)
controller_boss_prefight.start_cinematic_eat=true
while not controller_boss_prefight.cinematic_eat_finished do
coroutine.yield()
end
U.y_wait(store,0.5)
signal.emit("show-balloon_tutorial","LV22_MAGE_INTRO_01",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","LV22_MAGE_INTRO_02",false)
U.y_wait(store,3.5)
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=440,y=430},OVm(1,1.2))
signal.emit("show-gui")
signal.emit("end-cinematic")
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
controller_boss_prefight.eat_towers_disabled=true
local camera_pan=30
local camera_center=500
signal.emit("pan-zoom-camera",1.5,{y=700,x=camera_center-camera_pan/2},2)
signal.emit("show-curtains")
signal.emit("hide-gui")
signal.emit("start-cinematic")
U.y_wait(store,1.6)
signal.emit("pan-zoom-camera",10,{y=800,x=camera_center+camera_pan/2},2,"linear")
U.y_wait(store,2.5)
signal.emit("show-balloon_tutorial","TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0001",false)
U.y_wait(store,3.5)
signal.emit("show-balloon_tutorial","TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0002",false)
U.y_wait(store,3.5)
controller_boss_prefight.do_exit=true
while not controller_boss_prefight.finished do
coroutine.yield()
end
U.y_wait(store,1)
local boss=E:create_entity("boss_crocs_lvl1")
boss.enemy.wave_group_idx=store.wave_group_number
boss.nav_path.pi=19
boss.nav_path.spi=1
boss.nav_path.ni=45
boss.pos=P:node_pos(boss.nav_path)
LU.queue_insert(store,boss)
set_terrain(walkable_cells_bossfight,bit.bor(TERRAIN_LAND))
for _,v in pairs(prebossfight_blocked_paths) do
P:activate_path(v)
end
for _,v in pairs(bossfight_blocked_paths) do
P:deactivate_path(v)
end
for k,ignored_path in pairs(store.level.ignore_walk_backwards_paths) do
for _,path in pairs(stop_ignore_walk_backwards_paths_bossfight) do
if ignored_path==path then
store.level.ignore_walk_backwards_paths[k]=nil
break
end
end
end
for _,path in pairs(ignore_walk_backwards_paths_bossfight) do
table.insert(store.level.ignore_walk_backwards_paths,path)
end
U.y_wait(store,0.5)
S:stop_group("MUSIC")
S:queue("MusicBossFight_122")
signal.emit("hide-curtains")
signal.emit("pan-zoom-camera",2,{x=512,y=600},OVm(1,1.3))
while not self.bossfight_ended do
coroutine.yield()
end
signal.emit("boss_fight_end")
signal.emit("fade-out",1)
elseif store.level_mode==GAME_MODE_HEROIC then
for _,mask_settings in pairs(masks_heroic) do
for _,e in pairs(store.entities) do
if e.template_name==mask_settings then
e.render.sprites[1].hidden=false
end
end
end
for _,e in pairs(store.entities) do
if e.pos and e.pos.y<100 and (e.template_name=="decal_defense_flag" or e.template_name=="decal_defend_point" or e.template_name=="decal_upgrade_alliance_flux_altering_coils" or e.template_name=="decal_upgrade_alliance_seal_of_punishment") then
LU.queue_remove(store,e)
end
if e.template_name=="tower_stage_22_arborean_mages" then
LU.queue_remove(store,e)
end
if e.template_name=="decal_stage_22_rune_rock" and e.pos.x>400 and e.pos.x<600 then
LU.queue_remove(store,e)
end
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
end
return level
