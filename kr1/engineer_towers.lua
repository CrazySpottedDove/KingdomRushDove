local i18n = require("i18n")
require("constants")
local anchor_x = 0
local anchor_y = 0
local image_x = 0
local image_y = nil
local tt = nil
local scripts = require("game_scripts")
require("templates")
local function adx(v)
    return v - anchor_x * image_x
end
local function ady(v)
    return v - anchor_y * image_y
end
require("game_templates_utils")

tt = RT("tower_bfg", "tower")
AC(tt, "attacks", "powers")
image_y = 120
tt.tower.type = "bfg"
tt.tower.level = 1
tt.tower.price = 400
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = vec_2(0, 14)
tt.info.enc_icon = 16
tt.info.i18n_key = "TOWER_BFG"
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0012" or "info_portraits_towers_0002"
tt.powers.missile = CC("power")
tt.powers.missile.price_base = 185
tt.powers.missile.price_inc = 120
tt.powers.missile.range_inc_factor = 0.3
tt.powers.missile.damage_inc = 40
tt.powers.missile.enc_icon = 17
tt.powers.missile.cooldown_dec = 2
tt.powers.missile.cooldown_mixed_dec = 2
tt.powers.missile.attack_idx = 2
tt.powers.cluster = CC("power")
tt.powers.cluster.price_base = 175
tt.powers.cluster.price_inc = 210
tt.powers.cluster.cooldown_dec = 3.5
tt.powers.cluster.fragment_count_base = 2
tt.powers.cluster.fragment_count_inc = 2
tt.powers.cluster.enc_icon = 18
tt.powers.cluster.attack_idx = 3
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 16)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_bfg"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = vec_2(0, 51)
tt.main_script.update = scripts.tower_bfg.update
tt.sound_events.insert = "EngineerBfgTaunt"
tt.attacks.min_cooldown = 3.65
tt.attacks.range = 190
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "bomb_bfg"
tt.attacks.list[1].bullet_start_offset = vec_2(0, 64)
tt.attacks.list[1].cooldown = 3.65
tt.attacks.list[1].node_prediction = fts(25)
-- tt.attacks.list[1].range = 190
tt.attacks.list[1].shoot_time = fts(23)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].animation = "missile"
tt.attacks.list[2].bullet = "missile_bfg"
tt.attacks.list[2].bullet_start_offset = vec_2(-24, 64)
tt.attacks.list[2].cooldown_base = 16
tt.attacks.list[2].cooldown_mixed_base = 16
tt.attacks.list[2].cooldown_flying = 6.5
tt.attacks.list[2].launch_vector = vec_2(12, 110)
tt.attacks.list[2].range_base = 215
tt.attacks.list[2].range = nil
tt.attacks.list[2].shoot_time = fts(14)
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED)
tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[3].bullet = "bomb_bfg_cluster"
tt.attacks.list[3].cooldown_base = 18.5
tt.attacks.list[3].node_prediction = fts(40)
tt.attacks.list[3].vis_bans = 0

tt = RT("bomb_bfg", "bomb")
tt.bullet.damage_max = 125
tt.bullet.damage_min = 63
tt.bullet.damage_radius = 75
tt.bullet.flight_time = fts(35)
tt.bullet.hit_fx = "fx_explosion_big"
tt.render.sprites[1].name = "bombs_0005"
tt.sound_events.hit_water = nil
tt.render.sprites[1].scale = vec_1(1.1)

tt = RT("bomb_bfg_cluster", "bullet")
AC(tt, "sound_events")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(29)
tt.bullet.fragment_count = 1
tt.bullet.fragment_name = "bomb_bfg_fragment"
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.fragment_node_spread = 6
tt.bullet.fragment_pos_spread = vec_2(6, 6)
tt.bullet.dest_pos_offset = vec_2(0, 85)
tt.bullet.dest_prediction_time = 1
tt.main_script.insert = scripts.bomb_cluster.insert
tt.main_script.update = scripts.bomb_cluster.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bombs_0005"
tt.render.sprites[1].scale = vec_1(1.1)
tt.sound_events.hit = "BombExplosionSound"
tt.sound_events.insert = "BombShootSound"

tt = RT("bomb_bfg_fragment", "bomb")
tt.bullet.damage_max = 80
tt.bullet.damage_min = 60
tt.bullet.damage_radius = 55
tt.bullet.flight_time = fts(10)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = nil
tt.bullet.mod = "mod_bfg_stun"
tt.render.sprites[1].name = "bombs_0006"
tt.sound_events.hit_water = nil

tt = RT("mod_bfg_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.duration = 0.25

tt = RT("missile_bfg", "bullet")
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].loop = true
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.mod = "mod_bfg_stun"
tt.bullet.min_speed = 300
tt.bullet.max_speed = 450
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.damage_min = 60
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 41.25
tt.bullet.vis_flags = F_RANGED
tt.bullet.damage_flags = F_AREA
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = 1e+99
tt.main_script.insert = scripts.missile.insert
tt.main_script.update = scripts.missile.update
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"

tt = RT("tower_tesla", "tower")
AC(tt, "attacks", "powers")
image_y = 96
tt.tower.type = "tesla"
tt.tower.level = 1
tt.tower.price = 350
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = vec_2(0, 14)
tt.info.enc_icon = 20
tt.info.fn = scripts.tower_tesla.get_info
tt.info.i18n_key = "TOWER_TESLA"
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0011" or "info_portraits_towers_0009"
tt.powers.bolt = CC("power")
tt.powers.bolt.price_base = 175
tt.powers.bolt.price_inc = 175
tt.powers.bolt.max_level = 2
tt.powers.bolt.jumps_base = 3
tt.powers.bolt.jumps_inc = 1
tt.powers.bolt.enc_icon = 11
tt.powers.bolt.name = "CHARGED_BOLT"
tt.powers.overcharge = CC("power")
tt.powers.overcharge.price_base = 145
tt.powers.overcharge.price_inc = 145
tt.powers.overcharge.enc_icon = 10
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "tower_tesla"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = vec_2(0, 40)
tt.main_script.update = scripts.tower_tesla.update
tt.sound_events.insert = "EngineerTeslaTaunt"
tt.attacks.min_cooldown = 2.2
tt.attacks.range = 175
tt.attacks.range_check_factor = 1.2
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].bullet = "ray_tesla"
tt.attacks.list[1].bullet_start_offset = vec_2(7, 79)
tt.attacks.list[1].cooldown = 2.2
tt.attacks.list[1].node_prediction = fts(18)
tt.attacks.list[1].range = 175
tt.attacks.list[1].shoot_time = fts(48)
-- tt.attacks.list[1].shoot_time = fts(24)
tt.attacks.list[1].sound_shoot = "TeslaAttack"
tt.attacks.list[2] = CC("aura_attack")
tt.attacks.list[2].aura = "aura_tesla_overcharge"
tt.attacks.list[2].bullet_start_offset = vec_2(0, 15)

tt = RT("ray_tesla", "bullet")
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_tesla"
tt.bounces = nil
tt.bounces_lvl = {
    [0] = 2,
    3,
    4
}
tt.bounce_range = 95
tt.bounce_range_inc = 5
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = 0
tt.bounce_damage_min = 57
tt.bounce_damage_max = 105
tt.bounce_damage_factor = 0.5
tt.bounce_damage_factor_min = 0.5
tt.bounce_damage_factor_inc = 0
tt.bounce_delay = fts(2)
tt.bounce_scale_y = 1
tt.bounce_scale_y_factor = 0.88
tt.excluded_templates = {"enemy_spectral_knight", "enemy_lava_elemental"}
tt.image_width = 106
tt.seen_targets = {}
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "ray_tesla"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.ray_tesla.update

tt = RT("mod_ray_tesla", "modifier")
AC(tt, "render", "dps")
tt.modifier.duration = fts(14)
tt.modifier.vis_flags = F_MOD
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = bor(DAMAGE_ELECTRICAL, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = fts(2)
tt.dps.cocos_frames = 14
tt.dps.cocos_cycles = 13
tt.dps.pop = {"pop_bzzt"}
tt.dps.pop_chance = 1
tt.dps.pop_conds = DR_KILL
tt.modifier.allows_duplicates = true
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = RT("aura_tesla_overcharge", "aura")
tt.aura.duration = fts(22)
tt.aura.mod = "mod_tesla_overcharge"
tt.aura.radius = 170
tt.aura.damage_min = 0
tt.aura.damage_max = 11
tt.aura.damage_inc = 11
tt.aura.damage_type = DAMAGE_ELECTRICAL
tt.aura.excluded_templates = {"enemy_spectral_knight"}
tt.main_script.update = scripts.aura_tesla_overcharge.update
tt.particles_name = "ps_tesla_overcharge"

tt = RT("mod_tesla_overcharge", "modifier")
AC(tt, "render")
tt.modifier.duration = fts(20)
tt.modifier.vis_flags = F_MOD
tt.render.sprites[1].prefix = "mod_tesla_hit"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.allows_duplicates = true

local tower_dwaarp = RT("tower_dwaarp", "tower")
AC(tower_dwaarp, "attacks", "powers")
tower_dwaarp.info.portrait = "kr2_info_portraits_towers_0011"
tower_dwaarp.info.enc_icon = 14
tower_dwaarp.tower.type = "dwaarp"
tower_dwaarp.tower.price = 325
tower_dwaarp.powers.drill = CC("power")
tower_dwaarp.powers.drill.price_base = 400
tower_dwaarp.powers.drill.price_inc = 175
tower_dwaarp.powers.drill.enc_icon = 15
tower_dwaarp.powers.drill.attack_idx = 3
tower_dwaarp.powers.lava = CC("power")
tower_dwaarp.powers.lava.price_base = 375
tower_dwaarp.powers.lava.price_inc = 275
tower_dwaarp.powers.lava.name = "BLAST"
tower_dwaarp.powers.lava.enc_icon = 16
tower_dwaarp.powers.lava.attack_idx = 2
tower_dwaarp.main_script.insert = scripts.tower_dwaarp.insert
tower_dwaarp.main_script.update = scripts.tower_dwaarp.update
tower_dwaarp.render.sprites[1].animated = false
tower_dwaarp.render.sprites[1].name = "terrain_artillery_%04i"
tower_dwaarp.render.sprites[1].offset = vec_2(0, 12)
tower_dwaarp.render.sprites[2] = CC("sprite")
tower_dwaarp.render.sprites[2].animated = false
tower_dwaarp.render.sprites[2].name = "EarthquakeTower_Base"
tower_dwaarp.render.sprites[2].offset = vec_2(0, 40)
tower_dwaarp.render.sprites[3] = CC("sprite")
tower_dwaarp.render.sprites[3].prefix = "towerdwaarp"
tower_dwaarp.render.sprites[3].name = "idle"
tower_dwaarp.render.sprites[3].loop = false
tower_dwaarp.render.sprites[3].offset = vec_2(0, 40)
tower_dwaarp.render.sprites[4] = CC("sprite")
tower_dwaarp.render.sprites[4].prefix = "towerdwaarp"
tower_dwaarp.render.sprites[4].name = "siren"
tower_dwaarp.render.sprites[4].loop = true
tower_dwaarp.render.sprites[4].offset = vec_2(1, 76)
tower_dwaarp.render.sprites[4].hidden = true
tower_dwaarp.render.sprites[5] = CC("sprite")
tower_dwaarp.render.sprites[5].prefix = "towerdwaarp"
tower_dwaarp.render.sprites[5].name = "lights"
tower_dwaarp.render.sprites[5].loop = true
tower_dwaarp.render.sprites[5].offset = vec_2(-3, 40)
tower_dwaarp.render.sprites[5].hidden = true
tower_dwaarp.attacks.range = 180
tower_dwaarp.origin_range = 180
tower_dwaarp.attacks.list[1] = CC("area_attack")
tower_dwaarp.attacks.list[1].vis_flags = F_RANGED
tower_dwaarp.attacks.list[1].vis_bans = F_FLYING
tower_dwaarp.attacks.list[1].damage_flags = F_AREA
tower_dwaarp.attacks.list[1].damage_bans = F_FLYING
tower_dwaarp.attacks.list[1].cooldown = 3
tower_dwaarp.attacks.list[1].hit_time = fts(13)
tower_dwaarp.attacks.list[1].mod = "mod_slow_dwaarp"
tower_dwaarp.attacks.list[1].damage_min = 33
tower_dwaarp.attacks.list[1].damage_max = 55
tower_dwaarp.attacks.list[1].sound = "EarthquakeAttack"
tower_dwaarp.attacks.list[2] = CC("bullet_attack")
tower_dwaarp.attacks.list[2].bullet = "lava_dwaarp"
tower_dwaarp.attacks.list[2].cooldown = 15
tower_dwaarp.attacks.list[2].hit_time = fts(13)
tower_dwaarp.attacks.list[2].sound = "EarthquakeLavaSmash"
tower_dwaarp.attacks.list[3] = CC("bullet_attack")
tower_dwaarp.attacks.list[3].vis_flags = bor(F_DRILL, F_RANGED, F_INSTAKILL)
tower_dwaarp.attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tower_dwaarp.attacks.list[3].bullet = "drill"
tower_dwaarp.attacks.list[3].cooldown = 29
tower_dwaarp.attacks.list[3].cooldown_inc = -3
tower_dwaarp.attacks.list[3].hit_time = fts(46)
tower_dwaarp.attacks.list[3].sound = "EarthquakeDrillIn"
tower_dwaarp.sound_events.insert = "EarthquakeTauntReady"

local lava = RT("lava_dwaarp", "lava")
lava.main_script.update = scripts.lava_dwaarp.update

local decal_dwaarp_smoke = RT("decal_dwaarp_smoke", "decal_timed")
decal_dwaarp_smoke.render.sprites[1].prefix = "towerdwaarp_sfx"
decal_dwaarp_smoke.render.sprites[1].name = "smoke"
decal_dwaarp_smoke.render.sprites[1].z = Z_DECALS

local decal_dwaarp_smoke_water = RT("decal_dwaarp_smoke_water", "decal_timed")
decal_dwaarp_smoke_water.render.sprites[1].prefix = "towerdwaarp_sfx"
decal_dwaarp_smoke_water.render.sprites[1].name = "smokewater"
decal_dwaarp_smoke_water.render.sprites[1].z = Z_DECALS

local decal_dwaarp_pulse = RT("decal_dwaarp_pulse", "decal_tween")
decal_dwaarp_pulse.tween.props[1].name = "scale"
decal_dwaarp_pulse.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.32, vec_2(2.4, 2.4)}}
decal_dwaarp_pulse.tween.props[1].sprite_id = 1
decal_dwaarp_pulse.tween.props[2] = CC("tween_prop")
decal_dwaarp_pulse.tween.props[2].name = "alpha"
decal_dwaarp_pulse.tween.props[2].keys = {{0, 255}, {0.32, 0}}
decal_dwaarp_pulse.tween.props[2].sprite_id = 1
decal_dwaarp_pulse.render.sprites[1].animated = false
decal_dwaarp_pulse.render.sprites[1].name = "EarthquakeTower_HitDecal3"
decal_dwaarp_pulse.render.sprites[1].z = Z_DECALS

local decal_dwaarp_scorched = RT("decal_dwaarp_scorched", "decal_tween")
decal_dwaarp_scorched.tween.props[1].name = "alpha"
decal_dwaarp_scorched.tween.props[1].keys = {{0, 0}, {0.1, 255}, {3, 255}, {3.6, 0}}
decal_dwaarp_scorched.render.sprites[1].animated = false
decal_dwaarp_scorched.render.sprites[1].name = "EarthquakeTower_Lava1"
decal_dwaarp_scorched.render.sprites[1].z = Z_DECALS

local decal_dwaarp_tower_scorched = RT("decal_dwaarp_tower_scorched", "decal_tween")
decal_dwaarp_tower_scorched.tween.props[1].name = "alpha"
decal_dwaarp_tower_scorched.tween.props[1].keys = {{0, 0}, {0.1, 255}, {3, 255}, {3.6, 0}}
decal_dwaarp_tower_scorched.render.sprites[1].animated = false
decal_dwaarp_tower_scorched.render.sprites[1].name = "EarthquakeTower_Lava"
decal_dwaarp_tower_scorched.render.sprites[1].z = Z_DECALS

local decal_dwaarp_scorched_water = RT("decal_dwaarp_scorched_water", "decal_timed")
decal_dwaarp_scorched_water.timed.duration = 3
decal_dwaarp_scorched_water.timed.runs = nil
decal_dwaarp_scorched_water.render.sprites[1].prefix = "towerdwaarp_sfx"
decal_dwaarp_scorched_water.render.sprites[1].name = "vapor"
decal_dwaarp_scorched_water.render.sprites[1].z = Z_OBJECTS
decal_dwaarp_scorched_water.render.sprites[1].loop = true

tt = RT("drill", "bullet")
tt.bullet.pop = {"pop_splat"}
tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
tt.render.sprites[1].prefix = "drill"
tt.render.sprites[1].name = "ground"
tt.render.sprites[1].z = Z_OBJECTS
tt.hit_time = fts(3)
tt.main_script.update = scripts.drill.update
tt.sound_events.insert = "EarthquakeDrillOut"

tt = RT("tower_mech", "tower")
AC(tt, "barrack", "powers")
tt.tower.type = "mecha"
tt.tower.level = 1
tt.tower.price = 375
tt.info.fn = scripts.tower_mech.get_info
tt.info.portrait = "kr2_info_portraits_towers_0012"
tt.info.enc_icon = 13
tt.powers.missile = CC("power")
tt.powers.missile.price_base = 260
tt.powers.missile.price_inc = 280
tt.powers.missile.max_level = 3
tt.powers.missile.enc_icon = 17
tt.powers.oil = CC("power")
tt.powers.oil.price_base = 250
tt.powers.oil.price_inc = 200
tt.powers.oil.name = "WASTE"
tt.powers.oil.enc_icon = 18
tt.main_script.insert = scripts.tower_mech.insert
tt.main_script.update = scripts.tower_mech.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.barrack.soldier_type = "soldier_mecha"
tt.barrack.rally_range = 175
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 6)

for i = 2, 10 do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].prefix = "towermecha_layer" .. i - 1
    tt.render.sprites[i].name = "idle"
    tt.render.sprites[i].offset = vec_2(0, 46)
    tt.render.sprites[i].z = Z_TOWER_BASES
end

tt.render.sprites[10].z = Z_OBJECTS
tt.sound_events.insert = {"MechTauntReady", "MechSpawn"}
tt.sound_events.change_rally_point = "MechTaunt"
tt.ui.click_rect = r(-40, -10, 80, 50)

tt = RT("soldier_mecha")
AC(tt, "pos", "render", "motion", "nav_rally", "main_script", "vis", "idle_flip", "attacks", "powers")
tt.cooldown_factor = 1
tt.powers.missile = CC("power")
tt.powers.oil = CC("power")
tt.idle_flip.cooldown = 5
tt.idle_flip.last_dir = 1
tt.idle_flip.walk_dist = 27
tt.main_script.insert = scripts.soldier_mecha.insert
tt.main_script.remove = scripts.soldier_mecha.remove
tt.main_script.update = scripts.soldier_mecha.update
tt.vis.bans = F_RANGED
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].prefix = "soldiermecha"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].anchor.y = 0.11
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "soldiermechaoil"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor.y = 0.11
tt.motion.max_speed = 80
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "bomb_mecha"
tt.attacks.list[1].vis_bans = F_FLYING
tt.attacks.list[1].animations = {"bombleft", "bombright"}
tt.attacks.list[1].hit_times = {fts(12), fts(10)}
tt.attacks.list[1].max_range = 128
tt.attacks.list[1].start_offsets = {vec_2(-17, 79), vec_2(-28, 70)}
tt.attacks.list[1].cooldown = 0.2 + fts(24)
tt.attacks.list[1].node_prediction = true
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].bullet = "missile_mecha"
tt.attacks.list[2].power_name = "missile"
tt.attacks.list[2].animation_pre = "missilestart"
tt.attacks.list[2].animation = "missileloop"
tt.attacks.list[2].animation_post = "missileend"
tt.attacks.list[2].cooldown = 6
tt.attacks.list[2].max_range = 224
tt.attacks.list[2].burst = 0
tt.attacks.list[2].burst_inc = 2
tt.attacks.list[2].start_offsets = {vec_2(33, 44), vec_2(46, 57)}
tt.attacks.list[2].hit_times = {fts(3), fts(12)}
tt.attacks.list[2].launch_vector = vec_2(math.random(80, 240), math.random(15, 60))
tt.attacks.list[3] = CC("bullet_attack")
tt.attacks.list[3].bullet = "oil_mecha"
tt.attacks.list[3].power_name = "oil"
tt.attacks.list[3].vis_bans = F_FLYING
tt.attacks.list[3].animation = "oilposture"
tt.attacks.list[3].cooldown = 10
tt.attacks.list[3].hit_time = fts(17)
tt.attacks.list[3].start_offset = vec_2(-24, 0)
tt.attacks.list[3].sprite_ids = {1, 2}
tt.attacks.list[3].max_range = 57.6

local bomb_mecha = RT("bomb_mecha", "bomb")
bomb_mecha.render.sprites[1].name = "mech_bomb"
bomb_mecha.bullet.flight_time = fts(26)
bomb_mecha.bullet.hit_fx = "fx_explosion_fragment"
bomb_mecha.bullet.damage_min = 27
bomb_mecha.bullet.damage_max = 60
bomb_mecha.bullet.damage_radius = 57.6

local missile_mecha = RT("missile_mecha", "bullet")
missile_mecha.render.sprites[1].prefix = "missile_mecha"
missile_mecha.render.sprites[1].loop = true
missile_mecha.bullet.damage_type = DAMAGE_EXPLOSION
missile_mecha.bullet.min_speed = 350
missile_mecha.bullet.max_speed = 500
missile_mecha.bullet.turn_speed = 10 * math.pi / 180 * 30
missile_mecha.bullet.acceleration_factor = 0.1
missile_mecha.bullet.hit_fx = "fx_explosion_fragment"
missile_mecha.bullet.hit_fx_air = "fx_explosion_air"
missile_mecha.bullet.hit_fx_water = "fx_explosion_water"
missile_mecha.bullet.damage_min = 20
missile_mecha.bullet.damage_max = 80
missile_mecha.bullet.damage_radius = 41.25
missile_mecha.bullet.vis_flags = F_RANGED
missile_mecha.bullet.damage_flags = F_AREA
missile_mecha.bullet.particles_name = "ps_missile_mecha"
missile_mecha.bullet.retarget_range = math.huge
missile_mecha.main_script.insert = scripts.missile.insert
missile_mecha.main_script.update = scripts.missile.update
missile_mecha.sound_events.insert = "RocketLaunchSound"
missile_mecha.sound_events.hit = "BombExplosionSound"
missile_mecha.sound_events.hit_water = "RTWaterExplosion"

local ps_missile_mecha = RT("ps_missile_mecha")
AC(ps_missile_mecha, "pos", "particle_system")
ps_missile_mecha.particle_system.name = "particle_smokelet"
ps_missile_mecha.particle_system.animated = false
-- ps_missile_mecha.particle_system.particle_lifetime = {1.6, 1.8}
ps_missile_mecha.particle_system.particle_lifetime = {0.8, 0.9}
ps_missile_mecha.particle_system.alphas = {255, 0}
ps_missile_mecha.particle_system.scales_x = {1, 3}
ps_missile_mecha.particle_system.scales_y = {1, 3}
ps_missile_mecha.particle_system.scale_var = {0.4, 0.95}
ps_missile_mecha.particle_system.scale_same_aspect = false
ps_missile_mecha.particle_system.emit_spread = math.pi
ps_missile_mecha.particle_system.emission_rate = 30

local oil_mecha = RT("oil_mecha", "aura")
AC(oil_mecha, "render", "tween")
oil_mecha.aura.mod = "mod_slow_oil"
oil_mecha.aura.duration = 2
oil_mecha.aura.duration_inc = 2
oil_mecha.aura.cycle_time = 0.3
oil_mecha.aura.radius = 51.2
oil_mecha.aura.vis_bans = bor(F_FRIEND, F_FLYING)
oil_mecha.aura.vis_flags = F_MOD
oil_mecha.main_script.insert = scripts.aura_apply_mod.insert
oil_mecha.main_script.update = scripts.aura_apply_mod.update
oil_mecha.render.sprites[1].animated = false
oil_mecha.render.sprites[1].name = "Mecha_Shit"
oil_mecha.render.sprites[1].z = Z_DECALS
oil_mecha.tween.props[1].name = "alpha"
oil_mecha.tween.props[1].keys = {{"this.actual_duration-0.6", 255}, {"this.actual_duration", 0}}
oil_mecha.tween.props[2] = CC("tween_prop")
oil_mecha.tween.props[2].name = "scale"
oil_mecha.tween.props[2].keys = {{0, vec_2(0.6, 0.6)}, {0.3, vec_2(1, 1)}}
oil_mecha.tween.remove = false
oil_mecha.sound_events.insert = "MechOil"

tt = RT("tower_frankenstein", "tower")
AC(tt, "barrack", "attacks", "powers")
tt.tower.type = "frankenstein"
tt.tower.level = 1
tt.tower.price = 325
tt.info.fn = scripts.tower_frankenstein.get_info
tt.info.portrait = "kr2_info_portraits_towers_0022"
tt.powers.lightning = CC("power")
tt.powers.lightning.price_base = 150
tt.powers.lightning.price_inc = 150
tt.powers.lightning.enc_icon = 27
tt.powers.frankie = CC("power")
tt.powers.frankie.price_base = 200
tt.powers.frankie.price_inc = 200
tt.powers.frankie.enc_icon = 28
tt.main_script.insert = scripts.tower_frankenstein.insert
tt.main_script.update = scripts.tower_frankenstein.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.barrack.soldier_type = "soldier_frankenstein"
tt.barrack.rally_range = 180
tt.attacks.range = 205
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "ray_frankenstein"
tt.attacks.list[1].cooldown = 2.5
tt.attacks.list[1].shoot_time = fts(23)
tt.attacks.list[1].bullet_start_offset = vec_2(0, 80)
tt.attacks.list[1].sound = "TeslaAttack"
tt.attacks.list[1].node_prediction = fts(11.5)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 13)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "HalloweenTesla_layer1_0001"
tt.render.sprites[2].offset = vec_2(0, 40)
for i = 1, 4 do
    tt.render.sprites[i + 2] = CC("sprite")
    tt.render.sprites[i + 2].prefix = "tower_frankenstein_l" .. i + 1
    tt.render.sprites[i + 2].name = "idle"
    tt.render.sprites[i + 2].offset = vec_2(0, 40)
end
for i = 1, 2 do
    tt.render.sprites[i + 6] = CC("sprite")
    tt.render.sprites[i + 6].prefix = "tower_frankenstein_charge_l" .. i
    tt.render.sprites[i + 6].name = "idle"
    tt.render.sprites[i + 6].offset = vec_2(0, 40)
    tt.render.sprites[i + 6].loop = false
end
tt.render.sprites[9] = CC("sprite")
tt.render.sprites[9].prefix = "tower_frankenstein_drcrazy"
tt.render.sprites[9].name = "idle"
tt.render.sprites[9].offset = vec_2(0, 40)
tt.render.sprites[9].loop = false
tt.render.sprites[10] = CC("sprite")
tt.render.sprites[10].animated = false
tt.render.sprites[10].name = "Halloween_Frankie_lvl1_0051"
tt.render.sprites[10].offset = vec_2(2, 10)
tt.render.sprites[10].flip_x = true
for i = 1, 2 do
    tt.render.sprites[i + 10] = CC("sprite")
    tt.render.sprites[i + 10].prefix = "tower_frankenstein_helmet_l" .. i
    tt.render.sprites[i + 10].name = "idle"
    tt.render.sprites[i + 10].offset = vec_2(0, 40)
    tt.render.sprites[i + 10].loop = false
end
tt.sound_events.change_rally_point = "HWFrankensteinTaunt"
tt.sound_events.insert = "HWFrankensteinUpgradeLightning"

tt = RT("ray_frankenstein", "bullet")
tt.bullet.hit_time = fts(1)
tt.bullet.mod = "mod_ray_frankenstein"
tt.bounces = nil
tt.bounces_lvl = {
    [0] = 2,
    3,
    4,
    5
}
tt.bounce_range = 110
tt.bounce_vis_flags = F_RANGED
tt.bounce_vis_bans = 0
tt.bounce_damage_factor = 1
tt.bounce_damage_factor_min = 0.5
tt.bounce_damage_factor_inc = -0.25
tt.bounce_delay = fts(2)
tt.seen_targets = {}
tt.frankie_heal_hp = 10
tt.image_width = 98
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "ray_frankenstein"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.insert = scripts.ray_frankenstein.insert
tt.main_script.update = scripts.ray_frankenstein.update

tt = RT("mod_ray_frankenstein", "modifier")
AC(tt, "render", "dps")
tt.modifier.duration = fts(18)
tt.dps.damage_min = 50
tt.dps.damage_max = 70
tt.dps.damage_inc = 10
tt.dps.damage_type = DAMAGE_ELECTRICAL
tt.dps.damage_every = 1
tt.dps.pop = {"pop_bzzt"}
tt.dps.pop_chance = 1
tt.dps.pop_conds = DR_KILL
tt.render.sprites[1].name = "ray_frankenstein_fx"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.allows_duplicates = true

tt = RT("soldier_frankenstein", "soldier")
AC(tt, "melee")
image_y = 90
anchor_y = 25 / image_y
tt.health.armor_lvls = {0.2, 0.4, 0.6}
tt.health.armor = tt.health.armor_lvls[1]
tt.health.dead_lifetime = 12
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "kr2_info_portraits_soldiers_0014"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = scripts.soldier_barrack.update
tt.melee.attacks[1].cooldown_lvls = {2, 1, 1}
tt.melee.attacks[1].cooldown = tt.melee.attacks[1].cooldown_lvls[1]
tt.melee.attacks[1].damage_max_lvls = {20, 50, 50}
tt.melee.attacks[1].damage_max = tt.melee.attacks[1].damage_max_lvls[1]
tt.melee.attacks[1].damage_min_lvls = {10, 30, 30}
tt.melee.attacks[1].damage_min = tt.melee.attacks[1].damage_min_lvls[1]
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "pound"
tt.melee.attacks[2].cooldown = 6
tt.melee.attacks[2].damage_max = 150
tt.melee.attacks[2].damage_min = 150
tt.melee.attacks[2].damage_radius = 65
tt.melee.attacks[2].damage_type = DAMAGE_ELECTRICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_time = fts(24)
tt.melee.attacks[2].hit_fx = "fx_frankenstein_pound"
tt.melee.range = 77
tt.motion.max_speed = 45
tt.regen.cooldown = 1
-- tt.regen.health = 25
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix_lvls = {"soldier_frankie_lvl1", "soldier_frankie_lvl2", "soldier_frankie_lvl3"}
tt.render.sprites[1].prefix = tt.render.sprites[1].prefix_lvls[1]
tt.soldier.melee_slot_offset = vec_2(15, 0)
tt.unit.hit_offset = vec_2(0, 17)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POLYMORPH, F_POISON, F_LYCAN, F_SKELETON)

tt = RT("fx_frankenstein_pound", "decal_scripted")
AC(tt, "tween")
tt.main_script.insert = scripts.fx_frankenstein_pound.insert
tt.render.sprites[1].name = "frankie_punch_decal"
tt.render.sprites[1].anchor.y = 0.2777777777777778
tt.render.sprites[1].loop = false
for i = 1, 5 do
    tt.render.sprites[1 + i] = CC("sprite")
    tt.render.sprites[1 + i].name = "frankie_punch_fx"
    tt.render.sprites[1 + i].loop = true
    tt.render.sprites[1 + i].anchor.y = 0.2777777777777778
    tt.render.sprites[1 + i].z = Z_DECALS
    tt.tween.props[2 * i - 1] = CC("tween_prop")
    tt.tween.props[2 * i - 1].name = "alpha"
    tt.tween.props[2 * i - 1].sprite_id = 1 + i
    tt.tween.props[2 * i - 1].keys = {{0, 255}, {fts(10), 204}, {fts(16), 0}}
    tt.tween.props[2 * i] = CC("tween_prop")
    tt.tween.props[2 * i].name = "offset"
    tt.tween.props[2 * i].sprite_id = 1 + i
end
tt.tween.remove = true

tt = RT("tower_druid", "tower")
AC(tt, "attacks", "powers", "barrack")
tt.tower.type = "druid"
tt.tower.level = 1
tt.tower.price = 335
tt.tower.range_offset = vec_2(0, 10)
tt.info.enc_icon = 13
tt.info.portrait = "kr3_info_portraits_towers_0012"
tt.info.i18n_key = "TOWER_STONE_DRUID"
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = scripts.tower_druid.update
tt.main_script.remove = scripts.tower_druid.remove
tt.attacks.range = 190
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "rock_druid"
tt.attacks.list[1].cooldown = 1.4
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].max_loaded_bullets = 3
tt.attacks.list[1].storage_offsets = {vec_2(-25, 77), vec_2(34, 72), vec_2(5, 99)}
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].sound = "TowerDruidHengeRockThrow"
tt.attacks.list[1].node_prediction = fts(35)
tt.attacks.list[1].multi_rate = 0.2
tt.barrack.rally_range = 150
tt.barrack.rally_radius = 25
tt.barrack.soldier_type = "soldier_druid_bear"
tt.barrack.max_soldiers = 1
tt.powers.nature = CC("power")
tt.powers.nature.price_base = 320
tt.powers.nature.price_inc = 320
tt.powers.nature.max_level = 2
tt.powers.nature.entity = "druid_shooter_nature"
tt.powers.nature.enc_icon = 11
tt.powers.nature.name = "NATURES_FRIEND"
tt.powers.sylvan = CC("power")
tt.powers.sylvan.price_base = 250
tt.powers.sylvan.price_inc = 250
tt.powers.sylvan.entity = "druid_shooter_sylvan"
tt.powers.sylvan.enc_icon = 18
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 18)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "artillery_base_0005"
tt.render.sprites[2].offset = vec_2(0, 26)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "tower_druid_shooter"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
tt.render.sprites[3].angles.shoot = {"shootUp", "shootDown"}
tt.render.sprites[3].angles.load = {"castUp", "castDown"}
tt.render.sprites[3].anchor.y = 0.08333333333333333
tt.render.sprites[3].offset = vec_2(0, 44)
tt.sound_events.insert = "ElvesRockHengeTaunt"
tt.sound_events.change_rally_point = "SoldierDruidBearRallyChange"

tt = RT("mod_druid_sylvan", "modifier")
AC(tt, "render", "tween")
tt.render.sprites[1].name = "artillery_henge_curse_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "mod_druid_sylvan"
tt.render.sprites[2].size_names = {"small", "big", "big"}
tt.render.sprites[2].name = "small"
tt.render.sprites[2].draw_order = 2
tt.modifier.duration = 6
tt.attack = CC("bullet_attack")
tt.attack.max_range = 100
tt.attack.bullet = "ray_druid_sylvan"
tt.attack.damage_factor = {0.23, 0.46, 0.69}
tt.ray_cooldown = fts(15)
tt.damage = 5
tt.main_script.update = scripts.mod_druid_sylvan.update
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.5, vec_2(0.9, 0.9)}, {1, vec_2(1, 1)}}
tt.tween.props[1].loop = true

tt = RT("druid_shooter_sylvan", "decal_scripted")
AC(tt, "attacks")
tt.render.sprites[1].prefix = "tower_druid_shooter_sylvan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = vec_2(-24, 23)
tt.render.sprites[1].anchor.y = 0.06818181818181818
tt.render.sprites[1].draw_order = 2
tt.attacks.list[1] = CC("spell_attack")
tt.attacks.list[1].spell = "mod_druid_sylvan"
tt.attacks.list[1].cooldown = 12
tt.attacks.list[1].range = 190
tt.attacks.list[1].excluded_templates = {"enemy_ogre_magi"}
tt.attacks.list[1].cast_time = fts(20)
tt.attacks.list[1].sound = "TowerDruidHengeSylvanCurseCast"
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.main_script.update = scripts.druid_shooter_sylvan.update

tt = RT("druid_shooter_nature", "decal_scripted")
AC(tt, "attacks")
tt.render.sprites[1].prefix = "tower_druid_shooter_nature"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = vec_2(22, 17)
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.render.sprites[1].draw_order = 2
tt.attacks.list[1] = CC("spawn_attack")
tt.attacks.list[1].animation = "cast"
tt.attacks.list[1].cooldown = 15
tt.attacks.list[1].entity = "soldier_druid_bear"
tt.attacks.list[1].spawn_time = fts(10)
tt.main_script.update = scripts.druid_shooter_nature.update

tt = RT("soldier_druid_bear", "soldier_militia")
AC(tt, "melee", "count_group")
tt.count_group.name = "soldier_druid_bear"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.health.armor = 0.2
tt.health.magic_armor = 0.2
tt.health.hp_max = 300
tt.health_bar.offsets = {
    idle = vec_2(0, 40),
    standing = vec_2(0, 55)
}
tt.health_bar.offset = tt.health_bar.offsets.idle
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 14
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.portrait = "kr3_info_portraits_soldiers_0008"
tt.info.random_name_format = "ELVES_SOLDIER_BEAR_%i_NAME"
tt.info.random_name_count = 2
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = scripts.soldier_druid_bear.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "TowerDruidHengeBearAttack"
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = 0.28125
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_druid_bear"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.sound_events.insert = "TowerDruidHengeBearSummon"
tt.sound_events.death = "TowerDruidHengeBearDeath"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON)

tt = RT("tower_entwood", "tower")
AC(tt, "attacks", "powers")
tt.tower.type = "entwood"
tt.tower.level = 1
tt.tower.price = 400
tt.tower.range_offset = vec_2(0, 10)
tt.tower.size = TOWER_SIZE_LARGE
tt.info.enc_icon = 14
tt.info.portrait = "kr3_info_portraits_towers_0011"
tt.main_script.insert = scripts.tower_entwood.insert
tt.main_script.update = scripts.tower_entwood.update
tt.attacks.range = 210
tt.attacks.load_time = fts(54)
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "attack1"
tt.attacks.list[1].bullet = "rock_entwood"
tt.attacks.list[1].cooldown = 3.5
tt.attacks.list[1].shoot_time = fts(7)
tt.attacks.list[1].bullet_start_offset = vec_2(-38, 94)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].node_prediction = true
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].bullet = "rock_firey_nut"
tt.attacks.list[2].cooldown = 18
tt.attacks.list[2].cooldown_factor = 5.14
tt.attacks.list[2].animation = "special1"
tt.attacks.list[3] = CC("area_attack")
tt.attacks.list[3].animation = "special2"
tt.attacks.list[3].cooldown = 14
tt.attacks.list[3].damage_bans = F_FLYING
tt.attacks.list[3].damage_flags = F_AREA
tt.attacks.list[3].damage_radius = 225
tt.attacks.list[3].damage_type = DAMAGE_TRUE
tt.attacks.list[3].hit_time = fts(20)
tt.attacks.list[3].min_count = 2
tt.attacks.list[3].range = 195
tt.attacks.list[3].sound = "TowerEntwoodClobber"
-- tt.attacks.list[3].stun_chances = {1, 1, 0.75, 0.5}
tt.attacks.list[3].stun_mod = "mod_clobber"
tt.attacks.list[3].slow_mod = "mod_clobber_slow"
tt.attacks.list[3].vis_bans = F_FLYING
tt.attacks.list[3].vis_flags = F_RANGED
tt.powers.clobber = CC("power")
tt.powers.clobber.price_base = 225
tt.powers.clobber.price_inc = 225
tt.powers.clobber.attack_idx = 3
tt.powers.clobber.stun_durations = {1, 2, 3}
tt.powers.clobber.damage_values = {75, 100, 125}
tt.powers.clobber.enc_icon = 13
tt.powers.fiery_nuts = CC("power")
tt.powers.fiery_nuts.price_base = 290
tt.powers.fiery_nuts.price_inc = 235
tt.powers.fiery_nuts.attack_idx = 2
tt.powers.fiery_nuts.enc_icon = 15
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 10)

for i = 2, 10 do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].prefix = "tower_entwood_layer" .. i - 1
    tt.render.sprites[i].name = "idle"
    tt.render.sprites[i].offset = vec_2(0, 42)
    tt.render.sprites[i].group = "layers"
    tt.render.sprites[i].loop = false
end

tt.render.sprites[11] = CC("sprite")
tt.render.sprites[11].name = "tower_entwood_blink"
tt.render.sprites[11].loop = false
tt.render.sprites[11].offset = vec_2(0, 42)
tt.sound_events.insert = "ElvesRockEntwoodTaunt"

tt = RT("mod_clobber", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.render.sprites[1].prefix = "stun"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 10

tt = RT("mod_clobber_slow", "mod_slow")
tt.slow.factor = 0.6

tt = RT("rock_druid", "rock_1")
AC(tt, "tween")
tt.bullet.damage_max = 54
tt.bullet.damage_min = 32
tt.bullet.damage_radius = 50
tt.bullet.hit_decal = "decal_rock_crater"
tt.bullet.hit_fx = "fx_rock_explosion"
tt.bullet.flight_time = fts(35)
tt.bullet.pop = {"pop_druid_henge"}
tt.render.sprites[1].prefix = "druid_stone%i"
tt.render.sprites[1].name = "load"
tt.render.sprites[1].animated = true
tt.render.sprites[1].sort_y_offset = -72
tt.sound_events.load = "TowerDruidHengeRockSummon"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
tt.main_script.update = scripts.rock_druid.update
tt.main_script.insert = nil
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {0.8, vec_2(0, 2)}, {1.6, vec_2(0, 0)}}
tt.tween.props[1].loop = true

tt = RT("ray_druid_sylvan", "bullet")
tt.image_width = 42
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_druid_sylvan"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_druid_sylvan_affected"
tt.bullet.track_damage = true

tt = RT("rock_entwood", "rock_1")
tt.bullet.damage_max = 77
tt.bullet.damage_min = 45
tt.bullet.damage_radius = 55
tt.bullet.pop = {"pop_entwood"}
tt.render.sprites[1].name = "artillery_tree_proys_0001"
tt.sound_events.insert = "TowerEntwoodCocoThrow"
tt.sound_events.hit = "TowerEntwoodCocoExplosion"
tt.main_script.update = scripts.bomb_bouncing.update
tt.bounce_count = 1

tt = RT("rock_firey_nut", "rock_entwood")
tt.bullet.damage_max = 77
tt.bullet.damage_max_inc = 52
tt.bullet.damage_min = 77
tt.bullet.damage_min_inc = tt.bullet.damage_max_inc
tt.bullet.damage_radius = 65
tt.bullet.hit_payload = "aura_fiery_nut"
tt.bullet.hit_fx = "fx_fiery_nut_explosion"
tt.bullet.hit_decal = nil
tt.bullet.reduce_armor = 0.1
tt.render.sprites[1].name = "artillery_tree_proys_0002"
tt.sound_events.hit = "TowerEntwoodFieryExplote"

tt = RT("aura_fiery_nut", "aura")
AC(tt, "render", "tween")
tt.aura.cycle_time = 0.3
tt.aura.duration = 5
tt.aura.mod = "mod_fiery_nut"
tt.aura.radius = 65
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_BURN)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "decal_fiery_nut_scorched"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}

tt = RT("mod_fiery_nut", "modifier")
AC(tt, "dps", "render")
tt.dps.damage_min = 0
tt.dps.damage_max = 0
tt.dps.damage_inc = 1
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(3)
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 6
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].draw_order = 10

--[[
    五代
--]]
local balance = require("kr1.data.balance")
local b

-- 三管加农炮_START

b = balance.towers.tricannon

tt = RT("tower_tricannon_lvl4", "tower5")
AC(tt, "attacks", "powers")
image_y = 120
tt.tower.type = "tricannon"
tt.tower.level = 1
tt.tower.price = b.price[4]
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = vec_2(0, 24)
tt.info.enc_icon = 13
tt.info.i18n_key = "TOWER_TRICANNON_4"
tt.info.portrait = "kr5_portraits_towers_0004"
tt.powers.bombardment = CC("power")
tt.powers.bombardment.price_base = b.bombardment.price[1]
tt.powers.bombardment.price_inc = b.bombardment.price[2]
tt.powers.bombardment.enc_icon = 7
tt.powers.bombardment.cooldown = b.bombardment.cooldown
tt.powers.bombardment.damage_min = b.bombardment.damage_min
tt.powers.bombardment.damage_max = b.bombardment.damage_max
tt.powers.bombardment.bomb_amount = b.bombardment.bomb_amount
tt.powers.overheat = CC("power")
tt.powers.overheat.price_base = b.overheat.price[1]
tt.powers.overheat.price_inc = b.overheat.price[2]
tt.powers.overheat.enc_icon = 8
tt.powers.overheat.cooldown = b.overheat.cooldown
tt.powers.overheat.duration = b.overheat.duration
tt.main_script.update = scripts.tower_tricannon.update
tt.main_script.remove = scripts.tower_tricannon.remove
tt.sound_events.insert = "TowerTricannonTaunt"
tt.sound_events.tower_room_select = "TowerTricannonTauntSelect"
tt.attacks.min_cooldown = b.shared_min_cooldown
tt.attacks.range = b.basic_attack.range[4]
tt.attacks.attack_delay_on_spawn = fts(5)
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "tower_tricannon_bomb_4"
tt.attacks.list[1].bomb_amount = b.basic_attack.bomb_amount[4]
tt.attacks.list[1].bullet_start_offset = {vec_2(14, 71), vec_2(-14, 71), vec_2(0, 62)}
tt.attacks.list[1].cooldown = b.basic_attack.cooldown
tt.attacks.list[1].node_prediction = fts(25)
tt.attacks.list[1].range = b.basic_attack.range[4]
tt.attacks.list[1].shoot_time = fts(48)
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
tt.attacks.list[1].time_between_bombs = b.basic_attack.time_between_bombs
tt.attacks.list[1].random_x_to_dest = 30
tt.attacks.list[1].random_y_to_dest = 20
tt.attacks.list[1].sound = "TowerTricannonBasicAttackFire"
tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[2].bullet = "tower_tricannon_bomb_bombardment_bomb"
tt.attacks.list[2].bullet_start_offset = {vec_2(0, 71)}
tt.attacks.list[2].cooldown = nil
tt.attacks.list[2].bomb_amount = nil
tt.attacks.list[2].node_prediction = fts(25)
tt.attacks.list[2].range = b.bombardment.range
tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED)
tt.attacks.list[2].time_between_bombs_min = 3
tt.attacks.list[2].time_between_bombs_max = 5
tt.attacks.list[2].spread = b.bombardment.spread
tt.attacks.list[2].node_skip = b.bombardment.node_skip
tt.attacks.list[2].animation_start = "skill1"
tt.attacks.list[2].animation_loop = "loop"
tt.attacks.list[2].animation_end = "loop_end"
tt.attacks.list[2].shoot_time = fts(45)
tt.attacks.list[2].sounds = {"TowerTricannonBombardmentLvl1", "TowerTricannonBombardmentLvl2",
                                "TowerTricannonBombardmentLvl3"}
tt.attacks.list[3] = table.deepclone(tt.attacks.list[1])
tt.attacks.list[3].cooldown = nil
tt.attacks.list[3].duration = nil
tt.attacks.list[3].animation_charge = "skill_2_charge"
tt.attacks.list[3].animation_idle = "skill_2_idle"
tt.attacks.list[3].animation_shoot = "skill_2_attack"
tt.attacks.list[3].animation_end = "skill_2_fade_out"
tt.attacks.list[3].sound = "TowerTricannonOverheat"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 10)
for i = 2, 11 do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].prefix = "tricannon_tower_lvl4_tower_layer" .. i - 1
    tt.render.sprites[i].name = "idle"
    tt.render.sprites[i].group = "layers"
    tt.render.sprites[i].scale = vec_1(1.3 / 768 * 1024)
end
tt.ui.click_rect = r(-45, -3, 90, 78)

tt = RT("decalmod_tricannon_overheat", "modifier")
AC(tt, "render", "tween")
tt.main_script.insert = scripts.mod_tower_decal.insert
tt.main_script.remove = scripts.mod_tower_decal.remove
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.5, vec_2(1, 1)}, {1, vec_2(1, 1)}}
for i, p in ipairs({vec_2(22, 45), vec_2(31, 40), vec_2(40, 35), vec_2(49, 32.5), vec_2(58, 30), vec_2(67.5, 32.5),
                    vec_2(77, 35), vec_2(86, 40), vec_2(95, 45)}) do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].prefix = "crossbow_eagle_buff"
    tt.render.sprites[i].name = "idle"
    tt.render.sprites[i].anchor.y = 0.21
    tt.render.sprites[i].offset = vec_2(p.x - 58, p.y - 27)
    tt.render.sprites[i].ts = math.random()
end
-- tt.render.sprites[1].offset = vec_1(0)
for _, sprite in ipairs(tt.render.sprites) do
    sprite.offset.y = sprite.offset.y + 5 -- 向上平移 10 单位
    sprite.color = {255, 100, 50}
    -- sprite.scale = vec_2(1.2, 1.2)  -- 放大 20%
end

tt = RT("tower_tricannon_overheat_scorch_aura", "aura")
AC(tt, "render", "tween")
tt.aura.mod = "tower_tricannon_overheat_scorch_aura_mod"
tt.aura.duration = b.overheat.decal.duration
tt.aura.cycle_time = 0.5
tt.aura.radius = b.overheat.decal.radius
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "tricannon_tower_fissure_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = 2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "tricannon_tower_overheat_fire_fx"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}, {1, 0}}

tt = RT("tower_tricannon_overheat_scorch_aura_mod", "modifier")
AC(tt, "dps", "render")
tt.modifier.duration = b.overheat.decal.effect.duration
tt.dps.damage_min = b.overheat.decal.effect.damage
tt.dps.damage_max = b.overheat.decal.effect.damage
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = b.overheat.decal.effect.damage_every
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.modifier.max_duplicates = 5
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = RT("tower_tricannon_bomb", "bomb")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = b.basic_attack.damage_radius
tt.bullet.flight_time = fts(31)
tt.bullet.hit_fx = "fx_explosion_small"
tt.bullet.pop_chance = 0.2
tt.sound_events.hit_water = nil
tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(1.5, 1.5)

tt = RT("tower_tricannon_bomb_4", "tower_tricannon_bomb")
tt.bullet.damage_max = b.basic_attack.damage_max[4]
tt.bullet.damage_min = b.basic_attack.damage_min[4]
tt.bullet.align_with_trajectory = true
tt.bullet.particles_name = "tower_tricannon_bomb_4_trail"
tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb"

tt = RT("tower_tricannon_bomb_overheated", "tower_tricannon_bomb_4")
tt.bullet.hit_payload = "tower_tricannon_overheat_scorch_aura"
tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb_overheat"
tt.bullet.particles_name = "tower_tricannon_bomb_4_overheated_trail"
tt.bullet.flight_time = fts(28)
tt.bullet.g = -1.5 / (fts(1) * fts(1))

tt = RT("tower_tricannon_bomb_bombardment_bomb", "bomb")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_max_config = b.bombardment.damage_max
tt.bullet.damage_min_config = b.bombardment.damage_min
tt.bullet.damage_radius = b.bombardment.damage_radius
tt.bullet.flight_time = fts(26)
tt.bullet.g = -1.4 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_explosion_small"
tt.bullet.pop = nil
tt.bullet.align_with_trajectory = true
tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(1.5, 1.5)
tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
tt.bullet.particles_name = "tower_tricannon_bomb_4_bombardment_trail"

-- 三管加农炮_END

-- 恶魔澡坑_START

b = balance.towers.demon_pit
local basic_attack = b.basic_attack
local big_guy = b.big_guy
local master_exploders = b.master_exploders

tt = RT("tower_demon_pit_demon_trail")
AC(tt, "pos", "particle_system")
tt.particle_system.name = "demon_pit_tower_demon_projectile_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 50
tt.particle_system.particle_lifetime = {
    0.2,
    0.4
}
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(10, 10)
tt.particle_system.z = Z_BULLET_PARTICLES

tt = RT("decal_tower_demon_pit_reload", "decal_scripted")
tt.render.sprites[1].name = nil
tt.render.sprites[1].z = Z_TOWER_BASES + 1
tt.main_script.update = scripts.decal_tower_demon_pit_reload.update

tt = RT("decal_tower_demon_pit_demon_explosion_decal", "decal_tween")
AC(tt, "render", "tween")
tt.render.sprites[1].name = "demon_pit_tower_demon_minion_explosion_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
    {
        1,
        255
    },
    {
        2.5,
        0
    }
}
tt.tween.remove = true

tt = RT("tower_demon_pit_lvl4", "tower5")
AC(tt, "attacks", "powers")
tt.tower.type = "demon_pit"
tt.tower.level = 1
tt.tower.price = b.price[4]
tt.tower.menu_offset = vec_2(0, 25)
tt.powers.master_exploders = CC("power")
tt.powers.master_exploders.price_base = b.master_exploders.price[1]
tt.powers.master_exploders.price_inc = b.master_exploders.price[2]
tt.powers.master_exploders.enc_icon = 11
tt.powers.master_exploders.explosion_damage_factor = b.master_exploders.explosion_damage_factor
tt.powers.master_exploders.burning_duration = b.master_exploders.burning_duration
tt.powers.master_exploders.burning_damage_min = b.master_exploders.burning_damage_min
tt.powers.master_exploders.burning_damage_max = b.master_exploders.burning_damage_max
tt.powers.master_exploders.mod = "mod_tower_demon_pit_master_explosion_burning"
tt.powers.master_exploders.sound = "TowerDemonPitDemonExplosion"
tt.powers.big_guy = CC("power")
tt.powers.big_guy.price_base = b.big_guy.price[1]
tt.powers.big_guy.price_inc = b.big_guy.price[2]
tt.powers.big_guy.enc_icon = 12
tt.powers.big_guy.damage_max = 2
tt.powers.big_guy.damage_min = 2
tt.powers.big_guy.cooldown = b.big_guy.cooldown
tt.powers.big_guy.key = "BIG_DEMON"
tt.info.i18n_key = "TOWER_DEMON_PIT_4"
tt.info.portrait = "kr5_portraits_towers_0006"
tt.info.stat_damage = b.stats.damage
tt.info.stat_hp = b.stats.hp
tt.info.stat_armor = b.stats.armor
tt.info.enc_icon = 4
tt.info.fn = scripts.tower_demon_pit.get_info
tt.info.tower_portrait = "towerselect_portraits_big_0004"
tt.main_script.update = scripts.tower_demon_pit.update
tt.ui.click_rect = r(-30, 0, 60, 60)
tt.sound_events.insert = "TowerDemonPitTaunt"
tt.sound_events.tower_room_select = "TowerDemonPitTauntSelect"
tt.attacks.range = b.basic_attack.range[1]
tt.attacks.attack_delay_on_spawn = fts(5)
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].bullet = "bullet_tower_demon_pit_basic_attack_lvl4"
tt.attacks.list[1].cooldown = b.basic_attack.cooldown[4]
tt.attacks.list[1].shoot_time = fts(33)
tt.attacks.list[1].bullet_start_offset = vec_2(-7, 100)
-- tt.attacks.list[1].max_range = b.basic_attack.range[4]
tt.attacks.list[1].node_prediction = fts(60)
tt.attacks.list[1].animation = "attack"
tt.attacks.list[1].animation_reload = "reload_2"
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].bullet = "bullet_tower_demon_pit_big_guy_lvl4"
tt.attacks.list[2].cooldown = b.big_guy.cooldown[1]
tt.attacks.list[2].shoot_time = fts(43)
tt.attacks.list[2].bullet_start_offset = vec_2(-7, 70)
-- tt.attacks.list[2].max_range = big_guy.max_range
tt.attacks.list[2].node_prediction = fts(80)
tt.attacks.list[2].animation = "big_guy_spawn"
tt.attacks.list[2].animation_reload = "big_guy_reload_big_guy"
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[2].vis_bans = bor(F_FLYING)
tt.attacks.range = b.basic_attack.range[4]
tt.demons_sid = 4
tt.decal_reload = "decal_tower_demon_pit_reload"
tt.animation_reload = "demon_pit_tower_lvl4_tower_reload_reload_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 10)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "demon_pit_tower_lvl4_tower_base"
tt.render.sprites[2].offset = vec_2(0, 10)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "demon_pit_tower_lvl4_tower_bubbles"
tt.render.sprites[3].offset = vec_2(0, 10)
tt.render.sprites[3].animated = true
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].prefix = "demon_pit_tower_lvl4_tower_demons"
tt.render.sprites[4].offset = vec_2(0, 10)
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "demon_pit_tower_lvl4_tower_front"
tt.render.sprites[5].offset = vec_2(0, 10)

tt = RT("soldier_tower_demon_pit_basic_attack_lvl4", "soldier_militia")
AC(tt, "reinforcement", "tween")
tt.is_kr5 = true
tt.level = 4
tt.health.hp_max = b.basic_attack.hp_max[4]
tt.health.armor = b.basic_attack.armor
tt.health_bar.offset = vec_2(0, 27)
tt.health.dead_lifetime = 5
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0004"
tt.info.i18n_key = "TOWER_DEMON_PIT_SOLDIER"
tt.info.random_name_format = false
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_tower_demon_pit.update
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.range = b.basic_attack.melee_attack.range
tt.motion.max_speed = b.basic_attack.max_speed
tt.regen.cooldown = 1
tt.regen.health = b.basic_attack.regen_health
tt.reinforcement.duration = b.basic_attack.duration
tt.render.sprites[1].prefix = "demon_pit_tower_demon_minion"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.soldier.melee_slot_offset = vec_2(2, 0)
tt.tween.props[1].keys = {
    {
        0,
        0
    },
    {
        fts(5),
        255
    }
}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.level = 0
tt.ui.click_rect = r(-15, 0, 30, 28)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt.decal_on_explosion = "decal_tower_demon_pit_demon_explosion_decal"
tt.melee.attacks[1].cooldown = b.basic_attack.melee_attack.cooldown[4]
tt.melee.attacks[1].damage_max = b.basic_attack.melee_attack.damage_max[4]
tt.melee.attacks[1].damage_min = b.basic_attack.melee_attack.damage_min[4]
tt.explosion_sound = "TowerDemonPitDemonExplosion"
tt.explosion_range = b.demon_explosion.range
tt.explosion_damage_min = b.demon_explosion.damage_min
tt.explosion_damage_max = b.demon_explosion.damage_max
tt.explosion_damage_type = b.demon_explosion.damage_type
tt.explosion_mod_stun = "mod_soldier_tower_demon_pit_explosion"
tt.explosion_mod_stun_duration = b.demon_explosion.stun_duration
tt.patrol_pos_offset = vec_2(15, 10)
tt.patrol_min_cd = 3
tt.patrol_max_cd = 6

tt = RT("big_guy_tower_demon_pit_lvl4", "soldier_militia")
AC(tt, "reinforcement", "tween")
tt.is_kr5 = true
tt.health.armor = b.big_guy.armor
tt.health_bar.offset = vec_2(0, 42)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_level = b.big_guy.hp_max
tt.explosion_damage = b.big_guy.explosion_damage
tt.explosion_range = b.big_guy.explosion_range
tt.explosion_damage_type = b.big_guy.explosion_damage_type
tt.explosion_sound = "TowerDemonPitDemonExplosion"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0003"
tt.info.i18n_key = "TOWER_DEMON_PIT_SOLDIER_BIG_GUY"
tt.info.random_name_format = false
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.big_guy_tower_demon_pit.update
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[1].sound = "TowerDemonPitBigGuyBasicAttack"
tt.damage_max = b.big_guy.melee_attack.damage_max
tt.damage_min = b.big_guy.melee_attack.damage_min
tt.melee.range = b.big_guy.melee_attack.range
tt.motion.max_speed = b.big_guy.max_speed
tt.regen.cooldown = 1
tt.regen.health = b.big_guy.regen_health
tt.reinforcement.duration = b.big_guy.duration
tt.render.sprites[1].prefix = "demon_pit_tower_demon_big_guy"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.soldier.melee_slot_offset = vec_2(15, 0)
tt.tween.props[1].keys = {
    {
        0,
        0
    },
    {
        fts(10),
        255
    }
}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = vec_2(0, 5)
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

tt = RT("bullet_tower_demon_pit_basic_attack_lvl4", "bomb")
tt.sound_events.hit_water = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "demon_pit_tower_demon_projectile_idle"
tt.bullet.flight_time = fts(40)
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_payload = "soldier_tower_demon_pit_basic_attack_lvl4"
tt.bullet.rotation_speed = 40
tt.bullet.pop = nil
tt.bullet.particles_name = "tower_demon_pit_demon_trail"
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
tt.sound_events.insert = "TowerDemonPitBasicAttack"

tt = RT("bullet_tower_demon_pit_big_guy_lvl4", "bullet")
AC(tt, "main_script")
tt.bullet.flight_time = fts(31)
tt.bullet.hit_payload = "big_guy_tower_demon_pit_lvl4"
tt.sound_events.hit_water = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "demon_pit_tower_demon_big_guy_projectile"
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.rotation_speed = 0
tt.bullet.pop = nil
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.sound_events.insert = "TowerDemonPitBasicAttack"
tt.main_script.update = scripts.projecticle_big_guy_tower_demon_pit.update

tt = RT("mod_soldier_tower_demon_pit_explosion", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

tt = RT("mod_tower_demon_pit_master_explosion_burning", "modifier")
AC(tt, "dps", "render")
tt.modifier.duration = nil
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_type = b.master_exploders.damage_type
tt.dps.damage_every = b.master_exploders.damage_every
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].size_names = {
    "small",
    "medium",
    "large"
}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true

-- 恶魔澡坑_END

-- 喷火器 START
tt = E:register_t("tower_flamespitter_lvl4", "tower")
local b = balance.towers.flamespitter
E:add_comps(tt, "attacks", "powers")
tt.tower.type = "flamespitter"
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.team = TEAM_LINIREA
tt.tower.level = 1
tt.tower.price = b.price[4]
tt.tower.menu_offset = vec_2(0, 25)
tt.info.portrait = "kr5_portraits_towers_0014"
tt.info.room_portrait = "quickmenu_main_icons_main_icons_0002_0001"
tt.info.enc_icon = 1
tt.info.i18n_key = "TOWER_FLAMESPITTER_4"

tt.info.tower_portrait = "towerselect_portraits_big_" .. "0008"
tt.info.room_portrait = "quickmenu_main_icons_main_icons_0012_0001"
tt.info.stat_damage = b.stats.damage
tt.info.stat_cooldown = b.stats.cooldown
tt.info.stat_range = b.stats.range
tt.info.fn = scripts.tower_flamespitter.get_info
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = vec_2(0, 15)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = tt.render.sprites[1].offset
tt.render.sprites[2].name = "dwarven_flamespitter_tower_lvl4_tower"
tt.render.sprites[2].sort_y_offset = 5
tt.render.sprites[2].draw_order = 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = true
tt.render.sprites[3].prefix = "dwarven_flamespitter_tower_lvl4_dude"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].offset = tt.render.sprites[2].offset
tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
tt.render.sprites[3].draw_order = 3
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].animated = true
tt.render.sprites[4].name = "idle_diagonal_down"
tt.render.sprites[4].angles = {}
tt.render.sprites[4].angles.idle = { "idle_diagonal_down", "idle_side", "idle_diagonal_up", "idle_up", "idle_down" }
tt.render.sprites[4].angles.attack = { "attack_diagonal_down", "attack_side", "attack_diagonal_up", "attack_up",
    "attack_down" }
tt.render.sprites[4].offset = vec_2(1.5, tt.render.sprites[2].offset.y)
tt.render.sprites[4].prefix = "dwarven_flamespitter_tower_lvl4_cannon"
tt.render.sprites[4].offset = tt.render.sprites[2].offset
tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
tt.render.sprites[4].draw_order = 4
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].animated = true
tt.render.sprites[5].prefix = "dwarven_flamespitter_tower_lvl4_skill1"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].offset = tt.render.sprites[2].offset
tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
tt.render.sprites[5].draw_order = 1
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].animated = true
tt.render.sprites[6].prefix = "dwarven_flamespitter_tower_lvl4_skill2"
tt.render.sprites[6].name = "idle"
tt.render.sprites[6].offset = tt.render.sprites[2].offset
tt.render.sprites[6].sort_y_offset = tt.render.sprites[2].sort_y_offset
tt.render.sprites[6].draw_order = 3
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].animated = true
tt.render.sprites[7].prefix = "dwarven_flamespitter_tower_lvl4_stove_fire_fx"
tt.render.sprites[7].hidden = true
tt.render.sprites[7].offset = tt.render.sprites[2].offset
tt.render.sprites[7].sort_y_offset = tt.render.sprites[2].sort_y_offset
tt.render.sprites[7].draw_order = 2
tt.render.sid_tower_base = 2
tt.render.sid_dwarf = 3
tt.render.sid_tower_top = 4
tt.render.sid_skill_1 = 5
tt.render.sid_skill_2 = 6
tt.render.sid_stove_fire = 7
tt.main_script.insert = scripts.tower_engineer.insert
tt.main_script.update = scripts.tower_flamespitter.update
tt.main_script.remove = scripts.tower_flamespitter.remove
tt.attacks.min_cooldown = b.shared_min_cooldown
tt.attacks.range = b.basic_attack.range[4]
tt.attacks.attack_delay_on_spawn = fts(5)
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].cooldown = b.basic_attack.cooldown
tt.attacks.list[1].shoot_time = fts(8)
tt.attacks.list[1].vis_flags = bor(F_RANGED, F_AREA)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].burst_count = 5
tt.attacks.list[1].aura_offset = { vec_2(13, 35), vec_2(20, 42), vec_2(20, 58), vec_2(0, 63), vec_2(0, 28) }
tt.attacks.list[1].flame_fx = "fx_tower_flamespitter_flame"
tt.attacks.list[1].flame_fx_scale_x = { 1, 0.9, 0.8, 0.7, 1.1 }
tt.attacks.list[1].duration = b.basic_attack.duration
tt.attacks.list[1].node_prediction = fts(35)
tt.attacks.list[1].bullet_start_offset = { vec_2(20, 55), vec_2(20, 62), vec_2(20, 72), vec_2(0, 85), vec_2(0, 50) }
tt.attacks.list[1].sound = "TowerFlamespitterBasicAttack"
tt.attacks.list[1].cycle_time = b.basic_attack.cycle_time
tt.attacks.list[1].damage_min = b.basic_attack.damage_min[4]
tt.attacks.list[1].damage_max = b.basic_attack.damage_max[4]
tt.attacks.list[1].damage_type = b.basic_attack.damage_type
tt.attacks.list[1].square_half_x = 60 * math.pi / 4
tt.attacks.list[1].square_y = tt.attacks.range
tt.attacks.list[1].max_retarget_angle = 45 / 180 * math.pi
tt.attacks.list[1].mod = "mod_burning_tower_flamespitter"
tt.attacks.list[2] = E:clone_c("bullet_attack")
tt.attacks.list[2].bullet = "bullet_tower_flamespitter_skill_bomb"
tt.attacks.list[2].max_range = b.skill_bomb.max_range
tt.attacks.list[2].min_range = b.skill_bomb.min_range
tt.attacks.list[2].cooldown = b.skill_bomb.cooldown[1]
tt.attacks.list[2].shoot_time = fts(20)
tt.attacks.list[2].vis_bans = bor(F_FRIEND, F_FLYING, F_NIGHTMARE, F_CLIFF)
tt.attacks.list[2].vis_flags = bor(F_AREA)
tt.attacks.list[2].bullet_start_offset = vec_2(32, 40)
tt.attacks.list[2].node_prediction = fts(b.skill_bomb.node_prediction)
tt.attacks.list[2].damage_type = b.skill_bomb.damage_type
tt.attacks.list[2].damage_max = b.skill_bomb.damage_max
tt.attacks.list[2].damage_min = b.skill_bomb.damage_min
tt.attacks.list[2].min_targets = b.skill_bomb.min_targets
tt.attacks.list[2].sound = "TowerFlamespitterBlazingTrailCast"
tt.attacks.list[3] = E:clone_c("custom_attack")
tt.attacks.list[3].max_range = b.skill_columns.max_range
tt.attacks.list[3].min_range = b.skill_columns.min_range
tt.attacks.list[3].cooldown = b.skill_columns.cooldown[1]
tt.attacks.list[3].damage_min = b.skill_columns.damage_min
tt.attacks.list[3].damage_max = b.skill_columns.damage_max
tt.attacks.list[3].damage_type = b.skill_columns.damage_type
tt.attacks.list[3].min_targets = b.skill_columns.min_targets
tt.attacks.list[3].node_prediction = fts(40)
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
tt.attacks.list[3].vis_flags = bor(F_AREA)
tt.attacks.list[3].sound = "TowerFlamespitterScorchingTorchesCast"
tt.powers.skill_bomb = E:clone_c("power")
tt.powers.skill_bomb.price_base = b.skill_bomb.price[1]
tt.powers.skill_bomb.price_inc = b.skill_bomb.price[2]
tt.powers.skill_bomb.cooldown = b.skill_bomb.cooldown
tt.powers.skill_bomb.duration = b.skill_bomb.duration
tt.powers.skill_bomb.enc_icon = 21
tt.powers.skill_bomb.attack_idx = 2
tt.powers.skill_columns = E:clone_c("power")
tt.powers.skill_columns.cooldown = b.skill_columns.cooldown
tt.powers.skill_columns.price_base = b.skill_columns.price[1]
tt.powers.skill_columns.price_inc = b.skill_columns.price[2]
tt.powers.skill_columns.column_template = "controller_tower_flamespitter_column"
tt.powers.skill_columns.stun_time = b.skill_columns.stun_time
tt.powers.skill_columns.columns = b.skill_columns.columns
tt.powers.skill_columns.damage_type = b.skill_columns.damage_type
tt.powers.skill_columns.damage_in_max = b.skill_columns.damage_in_max
tt.powers.skill_columns.damage_in_min = b.skill_columns.damage_in_min
tt.powers.skill_columns.damage_out_max = b.skill_columns.damage_out_max
tt.powers.skill_columns.damage_out_min = b.skill_columns.damage_out_min
tt.powers.skill_columns.decal_start_offset = vec_2(-20, 0)
tt.powers.skill_columns.enc_icon = 22
tt.powers.skill_columns.attack_idx = 3

tt.tower_top_offset = vec_2(0, 20)
tt.turn_speed = b.turn_speed
tt.sound_events.insert = "TowerFlamespitterTaunt"
tt.sound_events.tower_room_select = "TowerFlamespitterTauntSelect"
tt.ui.click_rect = r(-35, 0, 70, 90)
tt.ui.click_rect_offset_y = -10

tt = E:register_t("controller_tower_flamespitter_column")
b = balance.towers.flamespitter.skill_columns
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.controller_tower_flamespitter_column.update
tt.damage_in_min = nil
tt.damage_in_max = nil
tt.damage_in_type = b.damage_in_type
tt.damage_out_min = nil
tt.damage_out_max = nil
tt.damage_out_type = b.damage_out_type
tt.radius_in = b.radius_in
tt.radius_out = b.radius_out
tt.vis_bans = bor(F_FRIEND)
tt.vis_flags = bor(F_AREA)
tt.column_fx = "fx_tower_flamespitter_column"
tt.decal = "decal_tower_flamespitter_skill_columns"
tt.mod = "mod_tower_flamesplitter_skill_columns"
tt.origin = nil
tt.dest = nil
tt.source_id = nil
tt.sound = "TowerFlamespitterScorchingTorchesFlareUp"

tt = E:register_t("bullet_tower_flamespitter_skill_bomb", "bomb")
local b = balance.towers.flamespitter.skill_bomb
tt.bullet.damage_max_config = b.damage_area_max
tt.bullet.damage_min_config = b.damage_area_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.flight_time = fts(40)
tt.bullet.hit_fx = "fx_bullet_tower_flamespitter_bomb_explosion"
tt.bullet.hit_decal = "decal_bullet_tower_flamespitter_bomb"
tt.bullet.pop_chance = 0.5
tt.bullet.particles_name = "ps_bullet_tower_flamespitter_skill_bomb"
tt.bullet.align_with_trajectory = true
tt.bullet.hit_payload = "bullet_tower_flamespitter_skill_bomb_payload"
tt.main_script.update = scripts.bomb.update
tt.sound_events.hit_water = nil
tt.sound_events.hit = "TowerFlamespitterBlazingTrailImpact"
tt.sound_events.insert = nil
tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_blazing_trail_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = false
tt.duration_config = b.duration

tt = E:register_t("bullet_tower_flamespitter_skill_bomb_payload")
E:add_comps(tt, "pos", "main_script")
local b = balance.towers.flamespitter.skill_bomb
tt.main_script.update = scripts.bullet_tower_flamespitter_skill_bomb_payload.update
tt.burn_fx = "fx_bullet_tower_flamespitter_bomb_burn"
tt.burn_radius = 30
tt.vis_flags = bor(F_BURN, F_AREA)
tt.vis_bans = bor(F_FLYING)
tt.mod_burn = "mod_burning_tower_flamespitter_skill_bomb"

tt = E:register_t("mod_burning_tower_flamespitter", "modifier")
b = balance.towers.flamespitter.burning
E:add_comps(tt, "dps", "render")
tt.modifier.duration = b.duration
tt.dps.damage_min = b.damage[4]
tt.dps.damage_max = b.damage[4]
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = b.cycle_time
tt.render.sprites[1].size_names = { "small", "medium", "large" }
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("mod_burning_tower_flamespitter_skill_bomb", "mod_burning_tower_flamespitter")
b = balance.towers.flamespitter.skill_bomb.burning
tt.modifier.duration = b.duration
tt.dps.damage_min = b.damage
tt.dps.damage_max = b.damage
tt.dps.damage_every = b.cycle_time
tt.damage = b.damage

tt = E:register_t("mod_tower_flamesplitter_skill_columns", "mod_stun")
b = balance.towers.flamespitter.skill_columns
tt.modifier.duration = fts(b.stun_time)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)

-- 喷火器 END