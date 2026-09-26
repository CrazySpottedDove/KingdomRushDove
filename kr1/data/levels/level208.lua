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
local S=require("sound_db")
local SU=require("script_utils")
local scripts=require("scripts")
local signal=require("lib.hump.signal")
local W=require("wave_db")
local r=V.r
local v=V.v
local vv=V.vv
local km=require("lib.klua.macros")
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local function queue_insert(store,e)
simulation:queue_insert_entity(e)
end
local function queue_remove(store,e)
simulation:queue_remove_entity(e)
end
local function queue_damage(store,damage)
store.damage_queue[#store.damage_queue+1]=damage
end
local function find_all_t(store,template_name,contains,fn)
if not store or not store.entities then
return {}
end
return table.filter(store.entities,function(k,val)
return (contains and string.find(val.template_name,template_name) or val.template_name==template_name) and (not fn or fn(k,val))
end)
end
local function phases_link_entities(this,store)
this.wall_1_masks={}
this.wall_2_masks={}
this.no_walls_masks={}
this.city_masks={}
this.holders_phase_1={}
this.holders_phase_2={}
this.holders_phase_3={}
this.flags_phase_1={}
this.flags_phase_2={}
this.flags_phase_3={}
this.defend_points_per_phase={{},{},{}}
this.archers_wall_1={}
this.archers_wall_2={}
this.archers_auras={}
for k,v in pairs(store.entities) do
if v.template_name==this.wall_1_t then
this.wall_1=v
end
if v.template_name==this.wall_2_t then
this.wall_2=v
end
if v.template_name==this.wall_2_broken_t then
this.wall_2_broken=v
end
if v.template_name==this.no_walls_t then
this.no_walls=v
end
if table.contains(this.wall_1_masks_t,v.template_name) then
table.insert(this.wall_1_masks,v)
end
if table.contains(this.wall_2_masks_t,v.template_name) then
table.insert(this.wall_2_masks,v)
end
if table.contains(this.no_walls_masks_t,v.template_name) then
table.insert(this.no_walls_masks,v)
end
if v.tower_holder then
if v.pos.x<this.holders_limits_x[1] then
table.insert(this.holders_phase_1,v)
elseif v.pos.x<this.holders_limits_x[2] then
table.insert(this.holders_phase_2,v)
else
table.insert(this.holders_phase_3,v)
end
end
if v.template_name=="decal_defense_flag" or v.template_name=="decal_defend_point" then
if v.pos.x<this.flags_limits_x[1] then
table.insert(this.flags_phase_1,v)
elseif v.pos.x<this.flags_limits_x[2] then
table.insert(this.flags_phase_2,v)
else
table.insert(this.flags_phase_3,v)
end
end
if v.template_name=="decal_defend_point" then
local phase=v.pos.x<this.flags_limits_x[1] and 1 or v.pos.x<this.flags_limits_x[2] and 2 or 3
table.insert(this.defend_points_per_phase[phase],v)
end
if v.template_name==this.templar_archers_t then
if v.editor and v.editor.wall_id==1 then
table.insert(this.archers_wall_1,v)
if v.nav_rally.pos.y>500 then
v.pos.x=v.nav_rally.pos.x-(v.pos.x-v.nav_rally.pos.x)
v.pos.y=v.nav_rally.pos.y-(v.pos.y-v.nav_rally.pos.y)
end
U.update_max_speed(v,0)
else
table.insert(this.archers_wall_2,v)
if v.editor and v.editor.balcony==1 then
v.pos.x,v.pos.y=v.nav_rally.pos.x,v.nav_rally.pos.y
v.render.sprites[1].z=Z_OBJECTS_COVERS+2
end
end
end
if v.template_name==this.archers_aura_t then
table.insert(this.archers_auras,v)
end
if v.template_name==this.catapult_t then
this.catapult=v
end
end
this.city_masks={}
for _,t in ipairs(this.city_masks_t) do
for k,e in pairs(store.entities) do
if e.template_name==t then
table.insert(this.city_masks,e)
end
end
end
end
local function phases_register_defend_points(this,store)
for phase,decals in ipairs(this.defend_points_per_phase) do
for _,d in pairs(decals) do
for _,item in pairs(P:nearest_nodes(d.pos.x,d.pos.y,this.paths_per_phase[phase])) do
local pi,spi,ni,dist=unpack(item,1,4)
if dist<P:path_width(pi)/2 then
P:set_defend_point_node(pi,ni)
end
end
end
end
end
local function phases_refresh_phase_elements(this,store)
this.wall_1.render.sprites[1].hidden=this.current_phase>1
this.wall_2.render.sprites[1].hidden=this.current_phase>2
this.wall_2_broken.render.sprites[1].hidden=this.current_phase~=2
this.no_walls.render.sprites[1].hidden=this.current_phase<3
this.catapult.render.sprites[1].hidden=this.current_phase>2
this.catapult.attacks.list[1].disabled=this.current_phase~=2
for k,v in pairs(this.wall_1_masks) do
v.render.sprites[1].hidden=this.current_phase~=1
end
for k,v in pairs(this.wall_2_masks) do
v.render.sprites[1].hidden=this.current_phase~=2
end
for k,v in pairs(this.no_walls_masks) do
v.render.sprites[1].hidden=this.current_phase<3
end
for k,v in pairs(this.city_masks) do
v.render.sprites[1].hidden=this.current_phase~=1
end
this.city_masks[2].tween.ts=store.tick_ts
this.city_masks[2].tween.disabled=false
for k,v in pairs(this.holders_phase_2) do
v.render.sprites[1].hidden=this.current_phase<2
v.ui.can_click=this.current_phase>=2
v.tower.can_hover=this.current_phase>=2
end
for k,v in pairs(this.holders_phase_3) do
v.render.sprites[1].hidden=this.current_phase<3
v.ui.can_click=this.current_phase==3
v.tower.can_hover=this.current_phase==3
end
for k,v in pairs(this.flags_phase_1) do
v.render.sprites[1].hidden=this.current_phase>1
end
for k,v in pairs(this.flags_phase_2) do
v.render.sprites[1].hidden=this.current_phase~=2
end
for k,v in pairs(this.flags_phase_3) do
v.render.sprites[1].hidden=this.current_phase~=3
end
for k,v in pairs(this.archers_wall_1) do
v.render.sprites[1].hidden=this.current_phase~=1
v.ranged.attacks[1].disabled=this.current_phase~=1
U.update_max_speed(v,this.current_phase~=1 and 0 or 75)
end
for k,v in pairs(this.archers_wall_2) do
v.render.sprites[1].hidden=true
v.ranged.attacks[1].disabled=this.current_phase~=2
U.update_max_speed(v,this.current_phase~=2 and 0 or 75)
end
for k,v in pairs(this.archers_auras) do
v.enabled=this.current_phase==2
end
end
local function phases_patch_nav_mesh(this,store,phase)
for h_id,dirs in pairs(this.nav_mesh_patches[phase]) do
for dir,target_id in pairs(dirs) do
store.level.nav_mesh[h_id][dir]=target_id
end
end
end
local function phases_restore_nav_mesh(this,store)
local nav_mesh=store.level.nav_mesh
local original=store.level._stage_208_nav_mesh_original
if not original then
original={}
for _,patch in pairs(this.nav_mesh_patches) do
for h_id,dirs in pairs(patch) do
original[h_id]=original[h_id] or {}
for dir in pairs(dirs) do
original[h_id][dir]=nav_mesh[h_id][dir] or false
end
end
end
store.level._stage_208_nav_mesh_original=original
end
for h_id,dirs in pairs(original) do
for dir,target_id in pairs(dirs) do
nav_mesh[h_id][dir]=target_id or nil
end
end
end
local function controller_stage_208_phases_update_editor(this,store)
this.current_phase=this.editor.phase
phases_link_entities(this,store)
phases_register_defend_points(this,store)
while true do
this.current_phase=this.editor.phase
this.wall_1.render.sprites[1].name=this.current_phase==0 and "startidle" or "idle"
phases_refresh_phase_elements(this,store)
coroutine.yield()
end
end
local function controller_stage_208_phases_update(this,store,script)
this.current_phase=(store.level_mode==GAME_MODE_IRON or store.level_mode==GAME_MODE_EXTRA_HEROES or store.level_mode==GAME_MODE_BLITZ or store.level_mode==GAME_MODE_NO_HEROES) and 3 or this.current_phase
phases_link_entities(this,store)
phases_register_defend_points(this,store)
phases_restore_nav_mesh(this,store)
this.wall_1.render.sprites[1].name=this.current_phase==0 and "startidle" or "idle"
phases_refresh_phase_elements(this,store)
for i=2,3 do
for k,v in pairs(this.paths_per_phase[i]) do
P:deactivate_path(v)
end
end
while this.current_phase==0 do
coroutine.yield()
end
local enemies,shake,barrage
if this.restarted then
else
if this.current_phase>=2 then
goto label_1110_0
end
barrage=E:create_entity(this.barrage_1_t)
barrage.pos=V.v(512,384)
barrage.render.sprites[1].ts=store.tick_ts
queue_insert(store,barrage)
if this.sound_barrage_1 then
S:queue(this.sound_barrage_1)
end
U.animation_start(this.wall_1,"start",nil,store.tick_ts,false)
U.y_wait(store,fts(8))
shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=1
shake.aura.freq_factor=3
queue_insert(store,shake)
U.y_wait(store,fts(16))
shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=1
shake.aura.freq_factor=3
queue_insert(store,shake)
U.y_wait(store,fts(16))
phases_refresh_phase_elements(this,store)
U.y_animation_wait(this.wall_1)
U.animation_start(this.wall_1,"idle",nil,store.tick_ts,true)
queue_remove(store,barrage)
end
if this.restarted then
phases_refresh_phase_elements(this,store)
U.animation_start(this.wall_1,"idle",nil,store.tick_ts,true)
end
while this.current_phase==1 do
coroutine.yield()
end
enemies=U.find_enemies_in_range(store,this.pos,0,1e+99,0,0)
if enemies then
for k,v in pairs(enemies) do
v.nav_path.pi=v.nav_path.pi==1 and 3 or 4
local nearest_nodes=P:nearest_nodes(this.pos.x,this.pos.y,{v.nav_path.pi})
local pi,spi,ni=unpack(nearest_nodes[1])
v.nav_path.spi=spi
v.nav_path.ni=ni
local nxt,new=P:next_entity_node(v,store.tick_length)
U.set_destination(v,nxt)
end
end
U.y_wait(store,1.2)
barrage=E:create_entity(this.barrage_2_t)
barrage.pos=V.v(512,384)
barrage.render.sprites[1].ts=store.tick_ts
queue_insert(store,barrage)
if this.sound_barrage_2 then
S:queue(this.sound_barrage_2)
end
U.y_wait(store,fts(10))
shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=2
shake.aura.freq_factor=3
queue_insert(store,shake)
U.y_wait(store,fts(30))
::label_1110_0::
phases_refresh_phase_elements(this,store)
phases_patch_nav_mesh(this,store,2)
for k,v in pairs(this.paths_per_phase[1]) do
P:deactivate_path(v)
end
for k,v in pairs(this.paths_per_phase[2]) do
P:activate_path(v)
end
for k,v in pairs(this.archers_wall_1) do
queue_remove(store,v)
end
if barrage then
U.y_animation_wait(barrage)
queue_remove(store,barrage)
end
while this.current_phase==2 do
coroutine.yield()
end
local enemies_2=table.filter(store.entities,function(k,v)
if not v.enemy or not v.nav_path or v.pending_removal or not v.health or not not v.health.dead then
return false
end
return v.template_name~="enemy_boss_stage_208"
end)
for k,v in pairs(this.paths_per_phase[2]) do
P:deactivate_path(v)
end
for k,v in pairs(this.paths_per_phase[3]) do
P:activate_path(v)
end
local keys=table.keys(this.path_change_map)
if enemies_2 then
for k,v in pairs(enemies_2) do
if P:nodes_to_goal(v.nav_path.pi,v.nav_path.spi,v.nav_path.ni)<52 then
local d=E:create_entity("damage")
d.source_id=this.id
d.target_id=v.id
d.damage_type=DAMAGE_TRUE
d.value=1e+99
queue_damage(store,d)
else
local path_to_change_to=this.path_change_map[v.nav_path.pi]
if path_to_change_to then
v.nav_path.pi=path_to_change_to
local nearest_nodes=P:nearest_nodes(v.pos.x,v.pos.y,{v.nav_path.pi},{v.nav_path.spi},true)
local pi,spi,ni=unpack(nearest_nodes[1])
v.nav_path.spi=spi
v.nav_path.ni=ni
local nxt,new=P:next_entity_node(v,store.tick_length)
U.set_destination(v,nxt)
end
end
end
end
local fixer=E:create_entity(this.path_fixer_t)
queue_insert(store,fixer)
phases_refresh_phase_elements(this,store)
phases_patch_nav_mesh(this,store,3)
queue_remove(store,this.catapult)
for k,v in pairs(this.archers_wall_2) do
queue_remove(store,v)
end
queue_remove(store,this)
end
local function controller_stage_208_path_fixer_update(this,store)
local run_ts=store.tick_ts-3
while true do
if store.tick_ts-run_ts>3 then
local keys=table.keys(this.path_change_map)
local enemies=table.filter(store.entities,function(k,v)
if not v.enemy or not v.nav_path or v.pending_removal or not v.health or not not v.health.dead then
return false
end
for i=1,#keys do
if keys[i]==v.nav_path.pi then
return true
end
end
return false
end)
if enemies then
for k,v in pairs(enemies) do
v.nav_path.pi=this.path_change_map[v.nav_path.pi]
local nearest_nodes=P:nearest_nodes(v.pos.x,v.pos.y,{v.nav_path.pi},{v.nav_path.spi},true)
local pi,spi,ni=unpack(nearest_nodes[1])
v.nav_path.spi=spi
v.nav_path.ni=ni
local nxt,new=P:next_entity_node(v,store.tick_length)
U.set_destination(v,nxt)
end
end
run_ts=store.tick_ts
end
coroutine.yield()
end
end
local function controller_stage_208_citizens_update(this,store)
local citizens
for k,v in pairs(store.entities) do
if v.template_name==this.citizens_t then
citizens=v
break
end
end
while not this.trigger_run do
coroutine.yield()
end
if this.restarted then
else
U.y_animation_play(citizens,"run",nil,store.tick_ts,1)
end
U.y_animation_play(citizens,"loop",nil,store.tick_ts,3)
U.y_animation_play(citizens,"end",nil,store.tick_ts,1)
end
local function controller_stage_208_crows_update(this,store)
while true do
if this.spawn_crows then
local crows=E:create_entity(this.crows_t)
crows.nav_path.pi=store.waves_finished and this.path_id_bossfight or this.path_id_pre_bossfight
crows.nav_path.ni=1
crows.nav_path.spi=1
crows.pos=P:node_pos(crows.nav_path.pi,crows.nav_path.spi,crows.nav_path.ni)
crows.source_id=this.id
crows.enemy_spawn=this.enemy_type=="sb" and "enemy_shadow_blades" or "enemy_shadow_archer_kr6"
crows.spawn_count=this.enemy_count
queue_insert(store,crows)
this.spawn_crows=false
end
coroutine.yield()
end
end
local function controller_stage_208_crows_on_event(this,store,action,enemy_type,enemy_count)
this.spawn_crows=true
this.enemy_type=enemy_type
this.enemy_count=enemy_count
log.info("EVENT CROWS SPAWN. TYPE: "..enemy_type.."  COUNT: "..enemy_count)
end
local function controller_stage_208_goblin_catapult_update(this,store)
while true do
if this.spawn_goblins then
local catapult=E:create_entity(this.catapult_t)
catapult.pos=v(-284,220)
catapult.source_id=this.id
catapult.spawn_count=this.enemy_count
queue_insert(store,catapult)
this.spawn_goblins=false
end
coroutine.yield()
end
end
local function controller_stage_208_goblin_catapult_on_event(this,store,action,enemy_count)
this.spawn_goblins=true
this.enemy_count=enemy_count
log.info("EVENT CATAPULT SPAWN. COUNT: "..enemy_count)
end
local function decal_stage_208_goblin_catapult_update(this,store)
local tap_count=0
local start_pos=V.vclone(this.pos)
U.set_destination(this,this.stop_pos)
this.motion.arrived=false
local ps1=E:create_entity(this.particles_name[1])
ps1.particle_system.emit=true
ps1.particle_system.track_id=this.id
queue_insert(store,ps1)
local ps2=E:create_entity(this.particles_name[2])
ps2.particle_system.emit=true
ps2.particle_system.track_id=this.id
queue_insert(store,ps2)
while not U.walk(this,store.tick_length) do
if this.ui.clicked then
this.ui.clicked=false
tap_count=tap_count+1
S:queue(this.sound_tap)
local fx=E:create_entity(this.tap_fx_t)
fx.pos.x=this.pos.x+10+math.random(-20,20)
fx.pos.y=this.pos.y+20+math.random(-20,20)
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
if tap_count>=this.taps_to_explode then
ps1.particle_system.emit=false
ps2.particle_system.emit=false
S:queue(this.sound_death)
U.y_animation_play(this,"death",nil,store.tick_ts,1)
goto label_1132_0
end
end
coroutine.yield()
end
this.motion.arrived=true
ps1.particle_system.emit=false
ps2.particle_system.emit=false
U.y_animation_play(this,"in",nil,store.tick_ts,1)
U.animation_start(this,"idle",nil,store.tick_ts,true)
U.y_wait(store,this.delay_before_hit)
U.animation_start(this,"attack",nil,store.tick_ts,false)
U.y_wait(store,this.hit_time)
do
local so=this.bullet_spawn_offset
local nearest=P:nearest_nodes(this.pos.x,this.pos.y,nil,nil,true)
local pi,_,ni=unpack(nearest[1])
local spi=1
if this.sound_fire then
S:queue(this.sound_fire)
end
for i=1,this.spawn_count do
local b=E:create_entity(this.bullet_t)
b.pos.x,b.pos.y=this.pos.x+so.x,this.pos.y+so.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=P:node_pos(pi,spi,ni+this.nodes_ahead+i*2)
b.bullet.source_id=this.id
b.path_to_spawn=pi
b.bullet.flight_time=b.bullet.flight_time+fts(math.random(-5,5))+fts(5)
b.bullet.rotation_speed=b.bullet.rotation_speed+math.random(-5,5)
queue_insert(store,b)
spi=spi+1
if spi>3 then
spi=1
end
end
end
U.y_animation_wait(this)
U.animation_start(this,"idle_2",nil,store.tick_ts,true)
if this.sound_out then
S:queue(this.sound_out)
end
U.y_animation_play(this,"out",nil,store.tick_ts,1)
U.animation_start(this,"walk_left",nil,store.tick_ts,true)
U.set_destination(this,start_pos)
ps1.particle_system.emit=true
ps1.particle_system.emit_offset.x=-ps1.particle_system.emit_offset.x
ps2.particle_system.emit=true
ps2.particle_system.emit_offset.x=-ps2.particle_system.emit_offset.x
this.motion.arrived=false
while not U.walk(this,store.tick_length) do
if this.ui.clicked then
this.ui.clicked=false
tap_count=tap_count+1
S:queue(this.sound_tap)
local fx=E:create_entity(this.tap_fx_t)
fx.pos.x=this.pos.x+10+math.random(-20,20)
fx.pos.y=this.pos.y+20+math.random(-20,20)
fx.render.sprites[1].ts=store.tick_ts
queue_insert(store,fx)
if tap_count>=this.taps_to_explode then
ps1.particle_system.emit=false
ps2.particle_system.emit=false
U.y_animation_play(this,"death",true,store.tick_ts,1)
break
end
end
coroutine.yield()
end
::label_1132_0::
ps1.particle_system.emit=false
ps2.particle_system.emit=false
U.y_wait(store,ps2.particle_system.particle_lifetime[2])
queue_remove(store,ps1)
queue_remove(store,ps2)
queue_remove(store,this)
end
local function controller_stage_208_boss_sound_steps_update(this,store,script)
local boss=store.entities[this.source_id]
while true do
if not boss or boss.health.dead then
queue_remove(store,this)
return
end
local boss_prefix=boss.render.sprites[1].prefix
if this.frames_to_do_sound[boss_prefix] then
for anim,frames in pairs(this.frames_to_do_sound[boss_prefix]) do
for i,f in ipairs(frames) do
local formatted_frame_name=string.format("%s_%s_%04i",boss_prefix,anim,f)
if boss.render.sprites[1].frame_name==formatted_frame_name then
S:queue(this.sound)
end
end
end
end
coroutine.yield()
end
end
local function controller_stage_208_boss_path_update(this,store,script)
local current_section=0
local decals={}
local current_invalid_range_ni=1
local ts=store.tick_ts
while not this.boss_ref.triggered_explosion do
if this.boss_ref.pos.x>current_section*this.sections_width+this.start_offset then
local decal=E:create_entity(this.sections_decals_t)
decal.pos=V.v(512,384)
decal.render.sprites[1].name=this.sections_decals_prefix..current_section
queue_insert(store,decal)
table.insert(decals,decal)
current_section=current_section+1
end
if store.tick_ts-ts>this.boss_ref.loop_walk_every then
ts=store.tick_ts
S:queue(this.boss_ref.sound_walk_loop)
end
if current_invalid_range_ni<this.boss_ref.nav_path.ni+6 then
P:remove_invalid_range(6,current_invalid_range_ni)
P:add_invalid_range(6,this.boss_ref.nav_path.ni+6)
current_invalid_range_ni=this.boss_ref.nav_path.ni+6
end
coroutine.yield()
end
P:remove_invalid_range(6,current_invalid_range_ni)
for i=current_section,9 do
local decal=E:create_entity(this.sections_decals_t)
decal.pos=V.v(512,384)
decal.render.sprites[1].name=this.sections_decals_prefix..i
queue_insert(store,decal)
table.insert(decals,decal)
end
while not this.boss_ref.ready_to_get_up do
coroutine.yield()
end
for k,v in pairs(decals) do
queue_remove(store,v)
end
queue_remove(store,this)
end
local function controller_stage_208_templar_swordsmen_update(this,store,script)
this.soldiers_alive=0
U.y_wait(store,fts(3))
while true do
local spi=1
for i=1,this.spawn_count do
local soldier=E:create_entity(this.templar_t)
soldier.path_id=this.path_id
soldier.subpath_id=spi
soldier.starting_ni=P:get_end_node(this.path_id)-3*i
soldier.pos=P:node_pos(this.path_id,spi,soldier.starting_ni)
soldier.source_id=this.id
soldier.cont_ref=this
queue_insert(store,soldier)
spi=spi+1
if spi>3 then
spi=1
end
end
this.soldiers_alive=this.spawn_count
while this.soldiers_alive>0 do
coroutine.yield()
end
U.y_wait(store,this.spawn_cooldown)
end
end
local function tower_stage_208_catapult_can_select_point(this,x,y)
return P:valid_node_nearby(x,y)
end
local function tower_stage_208_catapult_update(this,store)
local ab=this.attacks.list[1]
local bubble_ts=store.tick_ts
local tap_bubble_cd=4
U.animation_start(this,"idle",false,store.tick_ts,true)
this.bubble=E:create_entity(this.bubble_t)
this.bubble.pos=V.vclone(this.pos)
this.bubble.render.sprites[1].alpha=0
queue_insert(store,this.bubble)
while true do
if store.wave_group_number>0 and tap_bubble_cd<store.tick_ts-bubble_ts and this.bubble.render.sprites[1].alpha<=0 then
this.bubble.render.sprites[1].ts=store.tick_ts
this.bubble.tween.ts=store.tick_ts
this.bubble.tween.reverse=false
this.bubble.tween.disabled=false
bubble_ts=store.tick_ts
end
if not this.bubble.tween.reverse and (this.user_selection.menu_shown or this.bubble.render.sprites[1].alpha>0 and store.tick_ts-bubble_ts>5) then
this.bubble.tween.ts=store.tick_ts
this.bubble.tween.reverse=true
bubble_ts=store.tick_ts
tap_bubble_cd=this.user_selection.menu_shown and 20 or 6
end
if this.user_selection.new_pos then
store.player_gold=store.player_gold-ab.price
local pos=this.user_selection.new_pos
local nearest=P:nearest_nodes(pos.x,pos.y,nil,{1},true)[1]
local pi,spi,ni=unpack(nearest)
pos=P:node_pos(pi,spi,ni)
this.user_selection.new_pos=nil
ab.ts=store.tick_ts
local time_passed=store.tick_ts
local d=E:create_entity(ab.decal)
d.pos.x,d.pos.y=pos.x,pos.y
d.render.sprites[1].ts=store.tick_ts
queue_insert(store,d)
if ab.sound_load then
S:queue(ab.sound_load)
end
U.animation_start(this,"load",nil,store.tick_ts,1)
local ts=store.tick_ts
local p=false
while not U.animation_finished(this,1) do
if store.tick_ts-ts>this.sound_shoot_time and ab.sound_shoot and not p then
p=true
S:queue(ab.sound_shoot)
end
coroutine.yield()
end
U.animation_start(this,ab.animation,nil,store.tick_ts,false)
U.y_wait(store,ab.shoot_time)
time_passed=store.tick_ts-time_passed
local b=E:create_entity(ab.bullet)
b.pos.x,b.pos.y=this.pos.x+ab.bullet_start_offset.x,this.pos.y+ab.bullet_start_offset.y
b.bullet.from=V.vclone(b.pos)
b.bullet.to=V.vclone(pos)
b.bullet.source_id=this.id
queue_insert(store,b)
d.timed.duration=time_passed+b.bullet.flight_time
U.y_animation_wait(this)
U.animation_start(this,"idle",false,store.tick_ts,true)
end
coroutine.yield()
end
end
local function tower_stage_208_catapult_remove(this,store)
queue_remove(store,this.bubble)
return true
end
local function controller_stage_208_tower_stun_update(this,store,script)
while store.wave_group_number<1 do
coroutine.yield()
end
U.y_wait(store,math.random(this.cooldown_min,this.cooldown_max)+3)
while true do
local towers=table.filter(store.entities,function(k,v)
return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.can_be_mod and v.tower.type~="holder" and not v._to_be_stunned and (not v.vis or band(v.vis.bans,F_STUN)==0)
end)
if not towers or #towers<1 then
U.y_wait(store,3)
else
local tower_stun=E:create_entity(this.stun_t)
queue_insert(store,tower_stun)
U.y_wait(store,math.random(this.cooldown_min,this.cooldown_max))
end
end
end
local function controller_stage_208_tower_stun_moment_update(this,store,script)
local tower,bomb,shake
local towers=table.filter(store.entities,function(k,v)
return not v.pending_removal and v.tower and not v.tower.blocked and v.tower.can_be_mod and v.tower.type~="holder" and not v._to_be_stunned and (not v.vis or band(v.vis.bans,F_STUN)==0)
end)
if not towers or #towers<1 then
U.y_wait(store,3)
else
tower=towers[math.random(1,#towers)]
tower._to_be_stunned=true
bomb=E:create_entity(this.bomb_t)
bomb.pos=V.vclone(tower.pos)
bomb.render.sprites[1].ts=store.tick_ts
queue_insert(store,bomb)
if not this.skip_goblin_anim then
U.y_animation_play(bomb,"start",nil,store.tick_ts,1)
U.animation_start(bomb,"loop",nil,store.tick_ts,true)
U.y_wait(store,this.wait_time)
end
U.animation_start(bomb,"bomb",nil,store.tick_ts,false)
S:queue(this.sound_fire)
U.y_wait(store,this.hit_time)
S:queue(this.sound_hit)
if not tower or tower.pending_removal or tower.tower.upgrade_to then
local towers2=U.find_towers_in_range(store.towers,bomb.pos,{max_range=20,min_range=0},function(v,o)
return v.tower.can_be_mod and v.tower.type~="holder" and not v.tower.upgrade_to and (not v.vis or band(v.vis.bans,F_STUN)==0)
end)
tower=towers2 and #towers2>0 and towers2[1]
end
if tower then
local mod=E:create_entity(this.mod_t)
mod.modifier.target_id=tower.id
mod.modifier.source_id=this.id
queue_insert(store,mod)
end
shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=0.5
shake.aura.duration=1
shake.aura.freq_factor=3
queue_insert(store,shake)
U.y_animation_wait(bomb)
queue_remove(store,bomb)
end
if tower then
tower._to_be_stunned=false
end
queue_remove(store,this)
end
local function mod_stage_208_tower_stun_update(this,store)
local m=this.modifier
local target=store.entities[m.target_id]
if not target then
queue_remove(store,this)
return
end
local shown_hand=false
local function block_tower()
local t=target.tower
t.block_count=t.block_count+1
if t.block_count>0 then
t.blocked=true
if target.tower and not target.tower_holder then
t.can_be_sold=false
end
end
if target.tower and not target.tower._type then
target.tower._type=target.tower.type
target.tower.type="tower_broken_stage_208"
target.trigger_deselect=true
if not target.user_selection then
E:add_comps(target,"user_selection")
end
end
if not target.repair then
target.repair={}
target.repair.cost=this.repair_cost
target.repair.active=false
end
end
local function unblock_tower()
local t=target.tower
t.block_count=0
if t.block_count<1 then
t.blocked=nil
t.block_count=0
if target.tower and not target.tower_holder then
t.can_be_sold=true
end
end
end
m.ts=store.tick_ts
block_tower()
this.pos=target.pos
local start_ts=store.tick_ts
local tap_ts=store.tick_ts
local tap_cd=math.random(4,10)
local hand
while true do
if target.repair and target.user_selection.in_progress and not target.repair.active then
target.user_selection.in_progress=nil
target.user_selection.allowed=false
store.player_gold=store.player_gold-target.repair.cost
target.repair.active=true
S:queue(this.sound_events.repair)
this.tween.disabled=false
this.tween.reverse=true
this.tween.ts=store.tick_ts
break
end
if store.tick_ts-start_ts>this.auto_repair_time then
target.user_selection.in_progress=nil
target.user_selection.allowed=false
this.tween.disabled=false
this.tween.reverse=true
this.tween.ts=store.tick_ts
break
end
if not shown_hand and tap_cd<store.tick_ts-tap_ts then
hand=E:create_entity(this.hand_decal_t)
hand.pos=this.pos
hand.render.sprites[1].ts=store.tick_ts
hand.tween.ts=store.tick_ts
queue_insert(store,hand)
shown_hand=true
end
if target.pending_removal then
local towers=U.find_towers_in_range(store.towers,this.pos,{max_range=20,min_range=0},function(v,o)
return v.tower and not v.tower.blocked or v.tower_holder and not v.tower_holder.blocked
end)
if towers and #towers>0 then
target=towers[1]
target.test_deselect=true
this.modifier.target_id=target.id
block_tower()
end
end
coroutine.yield()
end
if hand then
queue_remove(store,hand)
end
U.y_wait(store,this.tween.props[1].keys[2][1])
unblock_tower()
target.trigger_deselect=true
target.user_selection.allowed=true
target.repair=nil
queue_remove(store,this)
end
local function mod_stage_208_tower_stun_remove(this,store)
local target=store.entities[this.modifier.target_id]
if target then
target.tower.type=target.tower._type
target.tower._type=nil
end
return true
end
local tt
tt=E:register_t_hot("decal_stage_208_city_mask_1","decal",true)
tt.render.sprites[1].name="stage208_MASK_1_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt.render.sprites[1].sort_y_offset=-43
tt=E:register_t_hot("decal_stage_208_city_mask_2","decal_tween",true)
tt.render.sprites[1].name="stage208_MASK_1_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset=69
tt.render.sprites[1].alpha=0
tt.tween.props[1].keys={{0,0},{fts(4),255}}
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_208_wall_1","decal",true)
tt.render.sprites[1].prefix="stage208_muro1Def"
tt.render.sprites[1].name="startidle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_208_wall_1_broken_mask_1","decal",true)
tt.render.sprites[1].name="stage208_MASK_2_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-158
tt=E:register_t_hot("decal_stage_208_wall_1_broken_mask_2","decal",true)
tt.render.sprites[1].name="stage208_MASK_2_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=85
tt=E:register_t_hot("decal_stage_208_wall_2","decal",true)
tt.render.sprites[1].name="stage208_MASK_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[1].draw_order=1
tt=E:register_t_hot("decal_stage_208_wall_2_broken","decal",true)
tt.render.sprites[1].name="stage208_MASK_3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_208_wall_2_broken_mask_1","decal",true)
tt.render.sprites[1].name="stage208_MASK_3_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-280
tt=E:register_t_hot("decal_stage_208_wall_2_broken_mask_2","decal",true)
tt.render.sprites[1].name="stage208_MASK_3_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=155
tt=E:register_t_hot("decal_stage_208_wall_2_broken_mask_3","decal",true)
tt.render.sprites[1].name="stage208_MASK_3_3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=169
tt=E:register_t_hot("decal_stage_208_wall_2_broken_mask_5","decal",true)
tt.render.sprites[1].name="stage208_MASK_3_5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt=E:register_t_hot("decal_stage_208_no_walls","decal",true)
tt.render.sprites[1].name="stage208_MASK_4"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_208_no_walls_mask_1","decal",true)
tt.render.sprites[1].name="stage208_MASK_4_1"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=80
tt=E:register_t_hot("decal_stage_208_no_walls_mask_2","decal",true)
tt.render.sprites[1].name="stage208_MASK_4_2"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset=-20
tt=E:register_t_hot("decal_stage_208_no_walls_mask_3","decal",true)
tt.render.sprites[1].name="stage208_MASK_4_3"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset=-20
tt=E:register_t_hot("decal_stage_208_rock_mask_1","decal",true)
tt.render.sprites[1].name="stage208_MASK_5"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.render.sprites[1].sort_y_offset=-20
tt=E:register_t_hot("decal_stage_208_torch","decal",true)
tt.render.sprites[1].prefix="stage208_torchesDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS+1
tt=E:register_t_hot("decal_stage_208_stone_barrage_1","decal",true)
tt.render.sprites[1].prefix="stage208_muro1_2Def"
tt.render.sprites[1].name="start"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=false
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY+1
tt=E:register_t_hot("decal_stage_208_stone_barrage_2","decal",true)
tt.render.sprites[1].prefix="stage208_muro2Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=false
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY+1
tt=E:register_t_hot("decal_stage_208_catapult_bubble","decal_tween",true)
tt.render.sprites[1].prefix="stage_208_catapult_speech_bubbleDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS_SKY
tt.render.sprites[1].offset=v(-65,60)
tt.tween.props[1].keys={{0,0},{fts(8),255}}
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_208_citizens_1","decal",true)
tt.render.sprites[1].prefix="stage208_civviesoverDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[1].draw_order=2
tt=E:register_t_hot("decal_stage_208_citizens_2","decal",true)
tt.render.sprites[1].prefix="stage208_civviesunderDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_BACKGROUND_BETWEEN
tt.render.sprites[1].draw_order=0
tt=E:register_t_hot("decal_stage_208_goblin_catapult","decal_scripted",true)
AC(tt,"motion","ui","sound_events")
tt.render.sprites[1].prefix="stage_208_goblin_catapultDef"
tt.render.sprites[1].name="walk_right"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.main_script.update=decal_stage_208_goblin_catapult_update
tt.motion.max_speed=75
tt.stop_pos=v(110,146)
tt.delay_before_hit=0
tt.hit_time=fts(17)
tt.bullet_t="bullet_enemy_flying"
tt.bullet_spawn_offset=v(40,50)
tt.tap_fx_t="fx_goblin_catapult_tap"
tt.taps_to_explode=6
tt.sound_events.insert="Stage08OrcSiegeEngineMoveIn"
tt.sound_fire="Stage08OrcSiegeEngineFire"
tt.sound_out="Stage08OrcSiegeEngineMoveOut"
tt.sound_tap="Stage08OrcSiegeEngineTap"
tt.sound_death="Stage08OrcSiegeEngineDeath"
tt.nodes_ahead=50
tt.particles_name={"ps_goblin_catapult_1","ps_goblin_catapult_2"}
tt.ui.click_rect=r(-40,-10,80,80)
tt=E:register_t_hot("decal_stage_208_path","decal",true)
tt.render.sprites[1].name="stage208_floorpath_0"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BACKGROUND_COVERS
tt=E:register_t_hot("decal_stage_208_tower_stun_bomb","decal",true)
tt.render.sprites[1].prefix="stage208_bombDef"
tt.render.sprites[1].name="start"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=-11
tt.render.sprites[1].offset=v(0,6)
tt=E:register_t_hot("decal_stage_208_catapult_crosshair","decal_timed",true)
tt.render.sprites[1].prefix="stage_208_catapult_crosshairDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].z=Z_DECALS
tt.timed.runs=INT_32_MAX
tt=E:register_t_hot("decal_stage_208_catapult_shadow","decal",true)
tt.render.sprites[1].name="stage_208_catapult_shadow"
tt.render.sprites[1].animated=false
tt.render.sprites[1].offset=vv(0)
tt=E:register_t_hot("decal_stage_208_catapult_hit","decal_timed",true)
tt.render.sprites[1].prefix="stage_208_catapult_decalDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.timed.runs=1
tt=E:register_t_hot("fx_stage_208_catapult","fx",true)
tt.render.sprites[1].prefix="stage_208_catapult_fxDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("fx_goblin_catapult_tap","fx",true)
tt.render.sprites[1].prefix="stage_208_goblin_catapult_tap_FXDef"
tt.render.sprites[1].name="tap"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("ps_goblin_catapult_1","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.loop=false
tt.particle_system.z=Z_BULLET_PARTICLES
tt.particle_system.name="goblin_catapult_particles_particle1_idle"
tt.particle_system.particle_lifetime={fts(15),fts(15)}
tt.particle_system.emission_rate=5
tt.particle_system.emit_offset=v(-45,15)
tt.particle_system.emit_area_spread=v(15,15)
tt=E:register_t_hot("ps_goblin_catapult_2","ps_goblin_catapult_1",true)
tt.particle_system.name="goblin_catapult_particles_particle2_idle"
tt.particle_system.particle_lifetime={fts(33),fts(33)}
tt.particle_system.emission_rate=5
tt=E:register_t_hot("mod_stage_208_tower_stun","modifier",true)
AC(tt,"render","tween")
tt.main_script.update=mod_stage_208_tower_stun_update
tt.main_script.remove=mod_stage_208_tower_stun_remove
tt.render.sprites[1].prefix="stage208_bomb_decalDef"
tt.render.sprites[1].name="loop"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].draw_order=20
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].offset=v(1,12)
tt.render.sprites[1].sort_y_offset=-10
tt.sound_events.repair="Stage08TowerRepairment"
tt.repair_cost=100
tt.auto_repair_time=45
tt.hand_decal_t="dlc2_generic_tap_hand"
tt.tween.props[1].keys={{0,0},{fts(6),255}}
tt.tween.props[1].name="alpha"
tt.tween.remove=false
tt.tween.disabled=true
tt=E:register_t_hot("tower_stage_208_catapult","tower",true)
AC(tt,"user_selection","attacks")
tt.tower.type="stage_208_catapult"
tt.tower.menu_offset=v(0,0)
tt.tower.can_be_sold=false
tt.tower.can_be_mod=false
tt.tower.disable_spend_highlight=true
tt.render.sprites[1].prefix="stage_208_catapultDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS_COVERS
tt.info.portrait="kr6_info_portraits_towers_0007"
tt.user_selection.can_select_point_fn=tower_stage_208_catapult_can_select_point
tt.user_selection.custom_pointer_name="sunray_tower"
tt.user_selection.allowed=true
tt.main_script.update=tower_stage_208_catapult_update
tt.main_script.remove=tower_stage_208_catapult_remove
tt.attacks.range=1400
tt.attacks.list[1]=CC("bullet_attack")
tt.attacks.list[1].price=50
tt.attacks.list[1].animation="attack"
tt.attacks.list[1].shoot_time=fts(5)
tt.attacks.list[1].sound_load="Stage08DefenderCatapultLoad"
tt.attacks.list[1].sound_shoot="Stage08DefenderCatapultFire"
tt.attacks.list[1].bullet="bullet_stage_208_catapult"
tt.attacks.list[1].bullet_start_offset=v(30,60)
tt.attacks.list[1].decal="decal_stage_208_catapult_crosshair"
tt.attacks.list[1].vis_bans=bor(F_FLYING)
tt.sound_shoot_time=fts(20)
tt.bubble_t="decal_stage_208_catapult_bubble"
tt.ui.click_rect=r(-50,-40,100,80)
tt.ui.hover_sprite_scale=vv(1.4)
tt.ui.hover_sprite_offset=v(0,-8)
tt.tower.can_hover=false
tt=E:register_t_hot("bullet_stage_208_catapult","bomb",true)
tt.bullet.damage_min=100
tt.bullet.damage_max=150
tt.bullet.damage_radius=80
tt.bullet.flight_time=fts(40)
tt.bullet.hit_fx="fx_stage_208_catapult"
tt.bullet.hit_decal="decal_stage_208_catapult_hit"
tt.bullet.pop_chance=0.5
tt.bullet.align_with_trajectory=false
tt.bullet.rotation_speed=10
tt.main_script.insert=scripts.bomb.insert
tt.main_script.update=scripts.bomb.update
tt.sound_events.hit_water=nil
tt.sound_events.hit="Stage08DefenderCatapultImpact"
tt.sound_events.insert=nil
tt.render.sprites[1].prefix="stage_208_catapult_projDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.screenshake_amplitude=0.3
tt.screenshake_duration=0.4
tt.screenshake_freq_factor=3
tt.decal_shadow="decal_stage_208_catapult_shadow"
tt=E:register_t_hot("controller_stage_208_phases",nil,true)
AC(tt,"main_script","editor","editor_script")
tt.editor_script.update=controller_stage_208_phases_update_editor
tt.main_script.update=controller_stage_208_phases_update
tt.editor.phase=0
tt.editor.props={{"editor.phase",PT_NUMBER}}
tt.holders_limits_x={250,750}
tt.flags_limits_x={500,900}
tt.current_phase=0
tt.wall_1_t="decal_stage_208_wall_1"
tt.wall_1_masks_t={"decal_stage_208_wall_1_broken_mask_1","decal_stage_208_wall_1_broken_mask_2"}
tt.wall_2_t="decal_stage_208_wall_2"
tt.wall_2_masks_t={"decal_stage_208_wall_2_broken_mask_1","decal_stage_208_wall_2_broken_mask_2","decal_stage_208_wall_2_broken_mask_3","decal_stage_208_wall_2_broken_mask_5"}
tt.wall_2_broken_t="decal_stage_208_wall_2_broken"
tt.no_walls_t="decal_stage_208_no_walls"
tt.no_walls_masks_t={"decal_stage_208_no_walls_mask_1","decal_stage_208_no_walls_mask_3"}
tt.city_masks_t={"decal_stage_208_city_mask_1","decal_stage_208_city_mask_2"}
tt.barrage_1_t="decal_stage_208_stone_barrage_1"
tt.barrage_2_t="decal_stage_208_stone_barrage_2"
tt.templar_archers_t="soldier_stage_208_templar_archer"
tt.archers_aura_t="aura_stage_208_archers_visibility"
tt.catapult_t="tower_stage_208_catapult"
tt.paths_per_phase={{1,2},{3,4},{5,6,7}}
tt.sound_barrage_1="Stage08StageStartFieryProjectiles"
tt.sound_barrage_2="Stage08StagePhase2FieryProjectiles"
tt.path_change_map={[3]=5,[4]=7}
tt.path_fixer_t="controller_stage_208_path_fixer"
tt.nav_mesh_patches={[2]={[5]={[1]=7},[79]={[3]=11}},[3]={[11]={[1]=13}}}
tt=E:register_t_hot("controller_stage_208_path_fixer",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_path_fixer_update
tt.path_change_map={[3]=5,[4]=7}
tt=E:register_t_hot("controller_stage_208_citizens_1",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_citizens_update
tt.citizens_t="decal_stage_208_citizens_1"
tt=E:register_t_hot("controller_stage_208_citizens_2","controller_stage_208_citizens_1",true)
tt.citizens_t="decal_stage_208_citizens_2"
tt=E:register_t_hot("controller_stage_208_crows",nil,true)
AC(tt,"main_script","events")
tt.main_script.update=controller_stage_208_crows_update
tt.crows_t="enemy_stage_208_cloud_of_crows"
tt.path_id_pre_bossfight=8
tt.path_id_bossfight=9
tt.events.list[1].name="crows"
tt.events.list[1].on_event=controller_stage_208_crows_on_event
tt=E:register_t_hot("controller_stage_208_goblin_catapult",nil,true)
AC(tt,"main_script","events")
tt.main_script.update=controller_stage_208_goblin_catapult_update
tt.catapult_t="decal_stage_208_goblin_catapult"
tt.events.list[1].name="catapult"
tt.events.list[1].on_event=controller_stage_208_goblin_catapult_on_event
tt=E:register_t_hot("controller_stage_208_boss_path",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_boss_path_update
tt.start_offset=-50
tt.sections_width=79.64444444444445
tt.sections_decals_t="decal_stage_208_path"
tt.sections_decals_prefix="stage208_floorpath_"
tt.sections_count=10
tt=E:register_t_hot("controller_stage_208_templar_swordsmen",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_templar_swordsmen_update
tt.templar_t="soldier_stage_208_templar_swordsman"
tt.spawn_cooldown=12
tt.spawn_count=3
tt=E:register_t_hot("controller_stage_208_tower_stun",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_tower_stun_update
tt.stun_t="controller_stage_208_tower_stun_moment"
tt.cooldown_min=90
tt.cooldown_max=120
tt=E:register_t_hot("controller_stage_208_tower_stun_moment",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_tower_stun_moment_update
tt.bomb_t="decal_stage_208_tower_stun_bomb"
tt.mod_t="mod_stage_208_tower_stun"
tt.wait_time=5
tt.hit_time=fts(8)
tt.sound_fire="Stage08FieryProjectilesTravel"
tt.sound_hit="Stage08FieryProjectilesExplosion"
tt=E:register_t_hot("controller_stage_208_boss_sound_steps",nil,true)
AC(tt,"main_script")
tt.main_script.update=controller_stage_208_boss_sound_steps_update
tt.frames_to_do_sound={boss_stage_208Def={walk={10,37},shout={12}},boss_stage_208_cartDef={walk={37,93,148,204},shout={12}}}
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
