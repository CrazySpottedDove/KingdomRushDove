local LU=require("level_utils")
local P=require("path_db")
local GR=require("grid_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level208")
require("all.constants")
require("lib.klua.table")
local level={}
local blocked_cells_phase_1={{26,37},{27,37},{28,37},{29,37},{30,37},{31,37},{32,37},{33,37},{26,36},{27,36},{28,36},{29,36},{30,36},{31,36},{32,36},{33,36},{26,35},{27,35},{28,35},{29,35},{30,35},{31,35},{32,35},{33,35},{26,34},{27,34},{28,34},{29,34},{30,34},{31,34},{32,34},{33,34},{26,33},{27,33},{28,33},{29,33},{30,33},{31,33},{32,33},{33,33},{35,21},{36,21},{37,21},{38,21},{39,21},{40,21},{41,21},{42,21},{43,21},{44,21},{35,20},{36,20},{37,20},{38,20},{39,20},{40,20},{41,20},{42,20},{43,20},{44,20},{35,19},{36,19},{37,19},{38,19},{39,19},{40,19},{41,19},{42,19},{43,19},{44,19},{35,18},{36,18},{37,18},{38,18},{39,18},{40,18},{41,18},{42,18},{43,18},{44,18},{35,17},{36,17},{37,17},{38,17},{39,17},{40,17},{41,17},{42,17},{43,17},{44,17}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
function level:init(store)
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
local E=require("entity_db")
local signal=require("lib.hump.signal")
for i=1,7 do
if i==2 then
P:add_invalid_range(i,P:get_end_node(i)-12,P:get_end_node(i),NF_RANGE)
P:add_invalid_range(i,P:get_end_node(i)-4,P:get_end_node(i))
else
P:add_invalid_range(i,P:get_end_node(i)-8,P:get_end_node(i),NF_RANGE)
P:add_invalid_range(i,P:get_end_node(i)-4,P:get_end_node(i))
end
end
if store.level_mode~=GAME_MODE_CAMPAIGN then
local cont_tower_stun=E:create_entity("controller_stage_208_tower_stun")
LU.queue_insert(store,cont_tower_stun)
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
return
end
local cont_phases,citizens_1_cont,citizens_2_cont
for k,v in pairs(store.entities) do
if v.template_name=="controller_stage_208_phases" then
cont_phases=v
end
if v.template_name=="controller_stage_208_citizens_1" then
citizens_1_cont=v
end
if v.template_name=="controller_stage_208_citizens_2" then
citizens_2_cont=v
end
end
set_terrain(blocked_cells_phase_1,bor(TERRAIN_LAND,TERRAIN_NOWALK))
citizens_1_cont.trigger_run=true
citizens_1_cont.restarted=store.restarted
citizens_2_cont.trigger_run=true
citizens_2_cont.restarted=store.restarted
S:queue("Stage08ScaredCrowd")
cont_phases.current_phase=1
cont_phases.restarted=store.restarted
while store.wave_group_number<4 do
coroutine.yield()
end
citizens_1_cont.trigger_end=true
citizens_2_cont.trigger_end=true
while store.wave_group_number<5 do
coroutine.yield()
end
set_terrain(blocked_cells_phase_1,bor(TERRAIN_LAND))
cont_phases.current_phase=2
local cont_tower_stun=E:create_entity("controller_stage_208_tower_stun")
LU.queue_insert(store,cont_tower_stun)
local strike_1=E:create_entity("controller_stage_208_tower_stun_moment")
strike_1.skip_goblin_anim=true
LU.queue_insert(store,strike_1)
U.y_wait(store,0.7)
local strike_2=E:create_entity("controller_stage_208_tower_stun_moment")
strike_2.skip_goblin_anim=true
LU.queue_insert(store,strike_2)
while store.wave_group_number<15 do
coroutine.yield()
end
S:stop_group("MUSIC")
S:queue("MusicBossFight_8")
local boss=E:create_entity("enemy_boss_stage_208")
boss.nav_path.pi=6
boss.nav_path.spi=3
boss.nav_path.ni=1
boss.pos=P:node_pos(6,3,1)
LU.queue_insert(store,boss)
P:activate_path(6)
P:add_invalid_range(6,1)
local function leave()
return boss.enraged
end
local shake_camera=true
local i=1
while not boss.enraged do
U.y_wait(store,fts(37),leave)
for j=1,4 do
if shake_camera then
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=math.max(0.8-i*0.2,0.2)
shake.aura.duration=0.2
shake.aura.freq_factor=math.max(0.8-i*0.2,0.1)
LU.queue_insert(store,shake)
end
if boss.enraged then
goto label_done
end
if j~=4 then
U.y_wait(store,fts(56),leave)
end
end
U.y_wait(store,fts(16),leave)
if i==4 then
shake_camera=false
end
i=i+1
end
::label_done::
while not boss.triggered_explosion do
coroutine.yield()
end
U.y_wait(store,fts(60))
cont_phases.current_phase=3
boss.ready_to_get_up=true
local cont_templars=E:create_entity("controller_stage_208_templar_swordsmen")
cont_templars.path_id=boss.nav_path.pi
LU.queue_insert(store,cont_templars)
while not boss.health.dead do
coroutine.yield()
end
signal.emit("boss_fight_end")
U.y_wait(store,1)
U.y_wait(store,3)
end
return level
