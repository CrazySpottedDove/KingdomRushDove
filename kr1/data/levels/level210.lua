local LU=require("level_utils")
local P=require("path_db")
local E=require("entity_db")
local U=require("utils")
local V=require("lib.klua.vector")
local log=require("lib.klua.log"):new("level210")
require("all.constants")
require("lib.klua.table")
local level={}
local target_random_defaults={V.v(711.3,415),V.v(418.2,157.2),V.v(74.3,450),V.v(895.3,454),V.v(644.3,142),V.v(700.3,476),V.v(963.3,253),V.v(641.3,440),V.v(843.3,282),V.v(-48.7,508),V.v(-149.7,250),V.v(817.3,169),V.v(852.3,204.7),V.v(154,583.8),V.v(504.3,158),V.v(1174.3,258),V.v(791.3,331),V.v(1090.3,397),V.v(1021.3,402),V.v(508.3,458),V.v(-48.7,550),V.v(856.3,486),V.v(8.2,487.2),V.v(435.3,461),V.v(784.3,464),V.v(479.3,486),V.v(728.2,144.7),V.v(366.3,473),V.v(556.3,487),V.v(232.3,523),V.v(341.3,509),V.v(15.7,230.5),V.v(694.3,358),V.v(269.3,492),V.v(-39.7,217),V.v(1163.3,374),V.v(585.7,173),V.v(181.3,517),V.v(313.2,222.2),V.v(156.5,193),V.v(1125.3,236),V.v(1023.3,241),V.v(955.3,462)}
function level:init(store)
local S=require("sound_db")
local scripts=require("scripts")
local r=V.r
local v=V.v
local vv=V.vv
local function AC(tpl,...)
return E:add_comps(tpl,...)
end
local function fts(t)
return t/30
end
local tt
tt=E:register_t_hot("ps_stage_210_under_ice","particle_system",true)
tt.particle_system.animated=true
tt.particle_system.name="water_splash_underice_shadow_particle_run"
tt.particle_system.particle_lifetime={fts(12),fts(12)}
tt.particle_system.emission_rate=60
tt.particle_system.z=Z_DECALS
tt=E:register_t_hot("ps_stage_210_jacuzzi","particle_system",true)
tt.particle_system.alphas={5,90,0}
tt.particle_system.emission_rate=5
tt.particle_system.emit_area_spread={x=80,y=30.714285714285722}
tt.particle_system.emit_direction=1.628973968528041
tt.particle_system.emit_speed={30,55}
tt.particle_system.name="stage_10_water_particles"
tt.particle_system.animated=false
tt.particle_system.particle_lifetime={2,2}
tt.particle_system.scales_x={1,3,4}
tt.particle_system.scales_y={1,3,2}
tt.particle_system.z=3500
tt=E:register_t_hot("ps_stage_210_snow","particle_system",true)
tt.particle_system.alphas={205,200,0}
tt.particle_system.emission_rate=2.4691358024691357
tt.particle_system.emit_area_spread={x=1200,y=30.714285714285722}
tt.particle_system.emit_direction=-1.5514037795505151
tt.particle_system.emit_offset={x=0,y=0}
tt.particle_system.emit_rotation=0.03878509448876288
tt.particle_system.emit_speed={40,70}
tt.particle_system.name="stage_10_water_particles"
tt.particle_system.animated=false
tt.particle_system.particle_lifetime={9,18}
tt.particle_system.scale_var={0.18571428571428558,0.2999999999999976}
tt.particle_system.spin={-1,3.5}
tt.particle_system.z=3500
tt=E:register_t_hot("ps_stage_210_jt_door_icicles","particle_system",true)
tt.particle_system.name="JT_icicles_particle_run"
tt.particle_system.animated=true
tt.particle_system.particle_lifetime={fts(9),fts(9)}
tt.particle_system.emission_rate=5
tt.particle_system.scale_var={0.8,1}
tt=E:register_t_hot("fx_stage_210_enter_puddle","fx",true)
tt.render.sprites[1].prefix="water_splash_waterSplash"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_stage_210_icicle_crash","fx",true)
tt.render.sprites[1].prefix="JT_icicles_hit_fx"
tt.render.sprites[1].name="run"
tt=E:register_t_hot("fx_stage_210_tower_freeze_thaw_out","fx",true)
tt.render.sprites[1].prefix="JT_stage10_unit_tower_fxDef"
tt.render.sprites[1].name="out"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("fx_stage_210_at_at_hit","fx",true)
tt.render.sprites[1].prefix="animations_hitDef"
tt.render.sprites[1].name="run"
tt.render.sprites[1].exo=true
tt=E:register_t_hot("decal_stage_210_jt_door","decal",true)
AC(tt,"main_script","ui","sound_events")
tt.render.sprites[1].prefix="JT_stage10_houseDef"
tt.render.sprites[1].name="idle"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt.render.sprites[1].sort_y_offset=212
tt.main_script.update=scripts.decal_stage_210_jt_door.update
tt.defrost_anim="bell_defrost"
tt.swipe_controller="controller_stage_210_jt_swipe"
tt.swipe_cooldown=40
tt.swipe_active=false
tt.ui.click_rect=r(-155,185,35,55)
tt.sound_events.bell_ring="Stage10BellRing"
tt.sound_events.bell_unfreeze="Stage10BellUnfreeze"
tt.sound_events.door_open="Stage10DoorOpen"
tt=E:register_t_hot("decal_stage_210_jt_door_icicle","decal",true)
AC(tt,"main_script","vis","bullet","sound_events")
tt.render.sprites[1].name="JT_icicles_projectile"
tt.render.sprites[1].z=Z_BULLETS
tt.render.sprites[1].animated=false
tt.bullet.min_speed=0
tt.bullet.max_speed=30*FPS
tt.bullet.acceleration_factor=0.2
tt.bullet.hit_decal="decal_stage_210_jt_door_icicle_bored"
tt.particles="ps_stage_210_jt_door_icicles"
tt.vis.flags=bor(F_AREA)
tt.damage_radius=50
tt.damage_min=40
tt.damage_max=60
tt.damage_type=DAMAGE_PHYSICAL
tt.main_script.update=scripts.decal_stage_210_jt_door_icicle.update
tt.sound_events.hit="Stage10StalactitesFall"
tt=E:register_t_hot("decal_stage_210_jt_door_icicle_cracks","decal_timed",true)
AC(tt,"tween","main_script")
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.timed.runs=INT_32_MAX
tt.timed.duration=3
tt.render.sprites[1].name="JT_icicles_decal"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].animated=false
tt.tween.props[1].keys={{0,0},{fts(17),255}}
tt.tween.props[1].loop=false
tt.tween.props[1].name="alpha"
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_210_jt_door_icicle_bored","decal_scripted",true)
AC(tt,"tween")
tt.main_script.update=scripts.decal_utils.animation_in_loop_out.update
tt.main_script.remove=scripts.tween_utils.reverse_remove
tt.animation_start="hit"
tt.animation_idle="idle"
tt.duration=2
tt.render.sprites[1].prefix="JT_icicles_projectile_hit"
tt.render.sprites[1].name="hit"
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].loop=false
tt.tween.props[1].keys={{0,0},{fts(17),255}}
tt.tween.props[1].loop=false
tt.tween.props[1].name="alpha"
tt.tween.disabled=true
tt=E:register_t_hot("decal_stage_210_under_ice","decal",true)
AC(tt,"main_script")
tt.render.sprites[1].animated=true
tt.render.sprites[1].loop=true
tt.render.sprites[1].prefix="water_splash_underice_shadow"
tt.render.sprites[1].name="run"
tt.main_script.update=scripts.decal_utils.track_target_update
tt=E:register_t_hot("decal_stage_210_mask_1","decal",true)
tt.render.sprites[1].name="Stage_10_mask_01"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_mask_2","decal",true)
tt.render.sprites[1].name="Stage_10_mask_02"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_mask_3","decal",true)
tt.render.sprites[1].name="Stage_10_mask_03"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_mask_5","decal",true)
tt.render.sprites[1].name="Stage_10_mask_05"
tt.render.sprites[1].animated=false
tt.render.sprites[1].z=Z_BULLETS+1
tt=E:register_t_hot("decal_stage_210_waterfall","decal",true)
tt.render.sprites[1].prefix="stage_10_waterfall"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_jacuzzi","decal",true)
tt.render.sprites[1].prefix="bubbles_jacuzzi_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_steam_jacuzzi","decal",true)
tt.render.sprites[1].prefix="steam_jacuzzi_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_OBJECTS
tt=E:register_t_hot("decal_stage_210_well","decal",true)
tt.render.sprites[1].prefix="well_st10Def"
tt.render.sprites[1].name="run"
tt.render.sprites[1].animated=true
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt=E:register_t_hot("decal_stage_210_at_at","decal",true)
AC(tt,"pos","render","ui","sound_events","editor","main_script","editor_script")
tt.render.sprites[1].prefix="easteregg_starwars_st10Def"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].z=Z_DECALS
tt.ui.click_rect=r(550,80,200,200)
tt.editor_script.insert=scripts.decal_stage_210_at_at.e_insert
tt.main_script.insert=scripts.decal_utils.censor_cn_insert
tt.main_script.update=scripts.decal_stage_210_at_at.update
tt.shoot_pos={}
tt.sound_tap_1="Stage10AtAtTap1"
tt.sound_tap_2="Stage10AtAtTap2"
tt.sound_break="Stage10AtAtTapBreak"
tt.editor.props={{"shoot_pos.pos",PT_COORDS}}
tt.bullet="bullet_stage_210_at_at"
tt.bullet_offsets={v(560,180),v(585,170)}
tt.bullet_hit_times={fts(32),fts(10),fts(10),fts(10)}
tt=E:register_t_hot("decal_stage_210_sasquatch","decal",true)
AC(tt,"main_script","ui")
tt.render.sprites[1].prefix="easteregg_sasquatchDef"
tt.render.sprites[1].name="idle_1"
tt.render.sprites[1].exo=true
tt.render.sprites[1].animated=true
tt.render.sprites[1].z=Z_DECALS
tt.render.sprites[1].hidden=true
tt.main_script.update=scripts.decal_stage_210_sasquatch.update
tt.ui.click_rect=r(172,265,100,50)
tt=E:register_t_hot("bullet_stage_210_at_at","bomb",true)
tt.bullet.flight_time=fts(6)
tt.bullet.damage_min=0
tt.bullet.damage_max=0
tt.bullet.damage_type=DAMAGE_NONE
tt.bullet.hit_payload="aura_stage_210_at_at"
tt.bullet.damage_radius=0
tt.bullet.ignore_rotation=true
tt.bullet.g=0
tt.bullet.align_with_trajectory=true
tt.bullet.hit_fx="fx_stage_210_at_at_hit"
tt.render.sprites[1].name="starwars_projectile_asst_projectile"
tt.render.sprites[1].z=Z_BULLETS
tt.render.sprites[1].sort_y_offset=1
tt.sound_events.insert="Stage10AtAtShoot"
tt=E:register_t_hot("aura_stage_210_jt_swipe","aura",true)
tt.aura.radius=70
tt.aura.vis_flags=bor(F_ENEMY,F_FRIEND,F_AREA,F_EAT)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.damage_min=0
tt.aura.damage_max=0
tt.aura.damage_type=DAMAGE_EAT
tt.main_script.update=scripts.aura_utils.apply_area_damage
tt=E:register_t_hot("aura_stage_210_puddle_entrance","aura",true)
AC(tt,"editor")
tt.aura.radius=50
tt.aura.vis_flags=bor(F_ENEMY)
tt.aura.vis_bans=bor(F_FLYING)
tt.aura.excluded_templates={}
tt.pid=0
tt.ice_shadow="decal_stage_210_under_ice"
tt.ps_ice_shadow="ps_stage_210_under_ice"
tt.splash_fx="fx_stage_210_enter_puddle"
tt.hide_healthbar=true
tt.override_health_bar_offset=v(0,20)
tt.remove_mods=true
tt.remove_ui=true
tt.main_script.update=scripts.aura_stage_210_puddle_entrance.update
tt.editor.props={{"pid",PT_NUMBER}}
tt.sound_events.water_splash="Stage10WaterSplashIn"
tt=E:register_t_hot("aura_stage_210_puddle_exit","aura",true)
AC(tt,"editor")
tt.aura.radius=50
tt.aura.vis_flags=bor(F_ENEMY,F_WATER)
tt.aura.vis_bans=bor(F_FLYING)
tt.pid=0
tt.splash_fx="fx_stage_210_enter_puddle"
tt.exit_grace_period=3
tt.main_script.update=scripts.aura_stage_210_puddle_exit.update
tt.editor.props={{"pid",PT_NUMBER}}
tt.sound_events.water_splash="Stage10WaterSplashOut"
tt=E:register_t_hot("aura_stage_210_at_at","aura",true)
tt.aura.duration=1e+99
tt.aura.radius=50
tt.aura.vis_flags=bor(F_AREA)
tt.aura.vis_bans=bor(F_FLYING,F_FRIEND)
tt.aura.cycles=1
tt.aura.cycle_time=0
tt.aura.damage_min=40
tt.aura.damage_max=60
tt.aura.damage_type=DAMAGE_PHYSICAL
tt.main_script.update=scripts.aura_apply_damage.update
tt=E:register_t_hot("controller_stage_210_jt_icicles",nil,true)
AC(tt,"main_script","events","sound_events")
tt.main_script.update=scripts.controller_stage_210_jt_icicles.update
tt.jt_door="decal_stage_210_jt_door"
tt.door_slam_timing=fts(58)
tt.icicle_t="decal_stage_210_jt_door_icicle"
tt.swipe_controller="controller_stage_210_jt_swipe"
tt.cluster_controller="controller_stage_210_jt_icicle_cluster"
tt.door_anim_defrosted="action_defrost"
tt.door_anim="action"
tt.excluded_templates={"enemy_boss_stage_10"}
tt.icicle_fall_time=fts(21)
tt.target_random=3
tt.target_random_defaults=target_random_defaults
tt.target_allies=2
tt.target_enemies=2
tt.icicle_spread=30
tt.scale_min=0.7
tt.time_to_free_door=0.5
tt.icicles_per_cluster=3
tt.max_delay_clusters=0.2
tt.max_delay_icicles=0.2
tt.sound_events.door_open="Stage10DoorOpenAndGrumble"
tt.sound_events.door_close="Stage10DoorClose"
tt.events.list[1].name="jt_icicles"
tt.events.list[1].on_event=scripts.controller_stage_210_jt_icicles.on_event
tt=E:register_t_hot("controller_stage_210_jt_icicle_cluster",nil,true)
AC(tt,"pos","main_script")
tt.main_script.update=scripts.controller_stage_210_jt_icicle_cluster.update
tt.hit_fx="fx_stage_210_icicle_crash"
tt.hit_decal="decal_stage_210_jt_door_icicle_cracks"
tt=E:register_t_hot("controller_stage_210_jt_swipe",nil,true)
AC(tt,"main_script","sound_events")
tt.icicles_controller="controller_stage_210_jt_icicles"
tt.jt_door="decal_stage_210_jt_door"
tt.aura_swipe="aura_stage_210_jt_swipe"
tt.door_idle_anim="idle_2"
tt.door_eat_anim="eat"
tt.bell_frost_anim="frost"
tt.door_end_anim="in"
tt.swipe_wait=3
tt.swipe_pos=v(498.5,470)
tt.swipe_timing=fts(16)
tt.time_to_free_door=2
tt.sound_events.bell_freeze="Stage10BellFreeze"
tt.sound_events.eat="Stage10JTDevour"
tt.sound_events.door_close="Stage10DoorClose"
tt.main_script.update=scripts.controller_stage_210_jt_swipe.update
self.manual_hero_insertion=false
end
function level:update(store)
local S=require("sound_db")
local U=require("utils")
local W=require("wave_db")
local signal=require("lib.hump.signal")
local function find_all_t(template_name)
return table.filter(store.entities,function(k,v)
return v.template_name==template_name
end)
end
if store.level_mode==GAME_MODE_CAMPAIGN or store.level_mode==GAME_MODE_KR1 then
while store.wave_group_number<5 do
coroutine.yield()
end
local door=find_all_t("decal_stage_210_jt_door")[1]
local controller_swipe=find_all_t("controller_stage_210_jt_swipe")[1]
local controller_icicles=find_all_t("controller_stage_210_jt_icicles")[1]
S:queue("Stage10BellUnfreeze")
U.y_animation_play(door,"bell_defrost",nil,store.tick_ts,1,1)
U.animation_start(door,"idle_defrost",nil,store.tick_ts,true,1)
controller_swipe.swipe_active=true
while not store.waves_finished or LU.has_alive_enemies(store) or door.in_use do
coroutine.yield()
end
local jt_spawn=V.v(511.6,589.5)
door.in_use=true
door.boss_fight=true
controller_swipe.swipe_active=false
controller_icicles.icicles_active=false
U.y_wait(store,1.5)
S:queue("Stage10DoorOpen")
if door.ready then
U.animation_start(door,"out_boss_defrost",nil,store.tick_ts,nil,1)
else
U.animation_start(door,"out_boss",nil,store.tick_ts,nil,1)
end
U.y_wait(store,22/FPS)
local boss=E:create_entity("enemy_boss_stage_10")
boss.nav_path.pi=4
boss.nav_path.spi=1
boss.nav_path.ni=75
boss.motion.forced_waypoint=P:node_pos(4,1,75)
boss.pos=jt_spawn
U.bans_add(boss.vis,F_ALL)
simulation:queue_insert_entity(boss)
coroutine.yield()
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.y_wait(store,2.5)
boss.cinematic=true
S:queue("Stage10JTChestTaunt")
U.y_animation_play(boss,"death",nil,store.tick_ts,1,1)
door.in_use=false
controller_icicles._target_random=8
controller_icicles._target_allies=0
controller_icicles._target_enemies=0
controller_icicles.spawn_icicles=true
local shake=E:create_entity("aura_screen_shake")
shake.aura.amplitude=1
shake.aura.duration=11/FPS*5
shake.aura.freq_factor=3
simulation:queue_insert_entity(shake)
S:queue("Stage10JTRoar")
U.y_animation_play(boss,"death_loop",nil,store.tick_ts,3,1)
U.animation_start(boss,"idle",nil,store.tick_ts,nil,1)
U.y_wait(store,10/FPS)
W:start_manual_wave("BOSS1")
boss.cinematic=false
coroutine.yield()
signal.emit("boss_fight_start",boss)
if door.ready then
U.animation_start(door,"idle_3_defrost",nil,store.tick_ts,true,1)
else
U.animation_start(door,"idle_3",nil,store.tick_ts,true,1)
end
U.bans_remove(boss.vis,F_ALL)
while not boss.health.dead do
coroutine.yield()
end
local freeze_mods=table.filter(store.entities,function(k,v)
return v.template_name=="mod_boss_tower_block"
end)
for k,m in pairs(freeze_mods) do
m.modifier.ts=0
end
signal.emit("boss_fight_end")
U.y_wait(store,3)
else
while not store.waves_finished or LU.has_alive_enemies(store) do
coroutine.yield()
end
end
log.debug("-- WON")
end
return level
