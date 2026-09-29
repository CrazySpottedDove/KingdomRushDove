local log=require("lib.klua.log"):new("level01")
local signal=require("lib.hump.signal")
local E=require("entity_db")
local S=require("sound_db")
local U=require("utils")
local LU=require("level_utils")
local V=require("lib.klua.vector")
local P=require("path_db")
local GR=require("grid_db")
require("all.constants")
local function fts(v)
return v/FPS
end
local decal_blocked_path
local blocked_cells={{19,36},{19,31},{19,32},{19,33},{19,34},{19,35},{20,30},{20,31},{20,32},{20,33},{20,34},{20,35},{21,30},{21,31},{21,32},{21,33},{21,34},{21,35},{22,30},{22,31},{22,32},{22,33},{22,34},{22,35},{23,30},{23,31},{23,32},{23,33},{23,34},{23,35},{24,30},{24,31},{24,32},{24,33},{24,34},{24,35},{25,30},{25,31},{25,32},{25,33},{25,34},{25,35},{26,30},{26,31},{26,32},{26,33},{26,34},{26,35},{27,30},{27,31},{27,32},{27,33},{27,34},{27,35},{28,30},{28,31},{28,32},{28,33},{28,34},{28,35},{29,30},{29,31},{29,32},{29,33},{29,34},{29,35},{30,30},{30,31},{30,32},{30,33},{30,34},{30,35},{31,30},{31,31},{31,32},{31,33},{31,34},{31,35},{25,29},{24,29},{25,29},{23,29},{22,29},{32,35},{32,34},{32,33},{32,32}}
local function set_terrain(cells,terrain)
for _,cell in ipairs(cells) do
GR:set_cell(cell[1],cell[2],terrain)
end
end
local level={}
function level:init(store)
require("lib.klua.table")
local SU=require("script_utils")
local AC=require("achievements")
local scripts=require("scripts")
local v=V.v
local r=V.r
local decal_stage_05_elder_rune_update
local decal_stage_05_bear_woodcutter_update
decal_stage_05_elder_rune_update=function(this,store)
local s=this.render.sprites[1]
local c=this.click_play
local clicks=0
local already_played=false
while true do
if this.ui.clicked then
this.ui.clicked=nil
clicks=clicks+1
end
if c.play_once and already_played then
elseif clicks>=c.required_clicks then
if this.tween then
this.tween.disabled=false
elseif not c.idle_animation then
s.hidden=false
end
S:queue(c.clicked_sound)
U.y_animation_play(this,c.click_animation,nil,store.tick_ts,1)
this.ui.clicked=nil
clicks=0
already_played=true
if not c.idle_animation then
s.hidden=true
else
U.animation_start_default(this,c.idle_animation,nil,store.tick_ts,true)
end
signal.emit("achievements_custom_event","RUNEQUEST_5")
if c.achievement then
AC:got(c.achievement)
end
if c.achievement_flag then
AC:flag_check(unpack(c.achievement_flag))
end
end
coroutine.yield()
end
end
decal_stage_05_bear_woodcutter_update=function(this,store)
local entity=E:create_entity(this.entity)
local nodes=P:nearest_nodes(this.waypoint_pos.x,this.waypoint_pos.y,nil,nil,false)
local pi,spi,ni=unpack(nodes[1])
entity.pos=this.spawn_pos
entity.nav_path.pi=pi
entity.nav_path.spi=spi
entity.nav_path.ni=ni
entity.motion.forced_waypoint=P:node_pos(entity.nav_path.pi,entity.nav_path.spi,entity.nav_path.ni)
U.set_destination(entity,this.waypoint_pos)
while true do
U.animation_start_group(this,"loop",false,store.tick_ts,false,"layers")
U.y_animation_wait_group(this,"layers")
if store.wave_group_number<8 then
else
U.animation_start_group(this,"wakeup",false,store.tick_ts,false,"layers")
U.y_wait_unconditional(store,fts(85))
S:queue("Stage05WoodcutterBearRoar")
U.y_wait_unconditional(store,fts(94))
for _,e in pairs(store.entities) do
if e.template_name=="stage_05_trees_mask" then
simulation:queue_remove_entity(e)
break
end
end
S:queue("Stage05WoodcutterBearChop")
U.y_wait_unconditional(store,fts(99))
S:queue("Stage05WoodcutterBearChop")
U.y_wait_unconditional(store,fts(130))
S:queue("Stage05WoodcutterBearChop")
U.y_animation_wait_group(this,"layers")
if this.holder then
this.holder.render.sprites[1].z=Z_DECALS
this.holder.render.sprites[2].z=Z_OBJECTS
this.holder.ui.can_click=true
this.holder.tower.can_hover=true
end
break
end
coroutine.yield()
end
simulation:queue_remove_entity(this)
simulation:queue_insert_entity(entity)
SU.y_enemy_walk_step(store,entity)
end
local tt
tt=E:register_t_hot("decal_stage_05_bear_woodcutter","decal_scripted",true)
tt.render.sprites[1]=E:clone_c("sprite")
tt.render.sprites[1].prefix="bear_woodcutterDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].exo=true
tt.render.sprites[1].group="layers"
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.main_script.update=decal_stage_05_bear_woodcutter_update
tt.entity="enemy_bear_woodcutter"
tt.spawn_pos=v(242,459)
tt.waypoint_pos=v(220,459)
tt=E:register_t_hot("decal_stage_05_elder_rune","decal_click_play",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].prefix="stage_5_elder_rune_5"
tt.render.sprites[1].loop=true
tt.render.sprites[1].draw_order=1
tt.main_script.update=decal_stage_05_elder_rune_update
tt.click_play.idle_animation="idle_2"
tt.click_play.click_animation="activation"
tt.click_play.play_once=true
tt.click_play.clicked_sound="Stage0506Rune"
tt.ui.can_click=true
tt.ui.click_rect=r(-50,-10,50,50)
tt=E:register_t_hot("decal_stage_05_elder_rune_static","decal",true)
E:add_comps(tt,"editor")
tt.render.sprites[1].name="stage_5_elder_rune_5_0125"
tt.render.sprites[1].animated=false
tt.render.sprites[1].loop=false
tt=E:register_t_hot("stage_05_bridge_mask_right","decal",true)
tt.render.sprites[1].name="stage_5_MaskBridge_right"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt=E:register_t_hot("stage_05_bridge_mask_left","decal",true)
tt.render.sprites[1].name="stage_5_MaskBridge_left"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
end
function level:load(store)
if store.level_mode==GAME_MODE_CAMPAIGN then
decal_blocked_path=E:create_entity("decal_stage_05_bear_woodcutter")
decal_blocked_path.pos=V.v(512,384)
LU.queue_insert(store,decal_blocked_path)
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND,TERRAIN_NOWALK))
end
end
function level:update(store)
local holders_blocked_start=0
for k,v in pairs(store.entities) do
if v.tower_holder and v.tower_holder.blocked then
holders_blocked_start=holders_blocked_start+1
end
end
if store.level_mode==GAME_MODE_CAMPAIGN then
local holder=table.filter(store.entities,function(_,v)
return v.tower and v.tower.holder_id=="3"
end)
if #holder>0 then
holder=holder[1]
holder.render.sprites[1].z=Z_BACKGROUND+1
holder.render.sprites[2].z=Z_BACKGROUND+2
holder.ui.can_click=false
holder.tower.can_hover=false
decal_blocked_path.holder=holder
end
P:deactivate_path(4)
while store.wave_group_number<8 do
coroutine.yield()
end
while store.entities[decal_blocked_path.id]~=nil do
coroutine.yield()
end
set_terrain(blocked_cells,bit.bor(TERRAIN_LAND))
P:activate_path(4)
end
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
log.debug("-- WON")
local holders_blocked_end=0
for k,v in pairs(store.entities) do
if v.tower_holder and v.tower_holder.blocked then
holders_blocked_end=holders_blocked_end+1
end
end
if holders_blocked_start==holders_blocked_end then
signal.emit("rubble-stage05",store)
end
end
return level
