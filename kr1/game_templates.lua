local i18n = require("i18n")

require("all.constants")

local anchor_x = 0
local anchor_y = 0
local image_x = 0
local image_y = nil
local tt = nil
local scripts = require("game_scripts")
local balance = require("kr1.data.balance")
local b
require("templates")

local function adx(v)
	return v - anchor_x * image_x
end

local function ady(v)
	return v - anchor_y * image_y
end

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

require("game_templates_utils")
----------
require("foundamental_towers")
require("mage_towers")
require("archer_towers")
require("engineer_towers")
require("barrack_towers")
require("heroes")
require("enemies")
require("boss")
require("hero_boss")

----------
--#region pop_crit
tt = RT("pop_crit", "pop")
tt.render.sprites[1].name = "pop_0003"
--#endregion
--#region pop_headshot
tt = RT("pop_headshot", "pop")
tt.render.sprites[1].name = "pop_0007"
--#endregion
--#region ps_bolt_sorcerer
tt = RT("ps_bolt_sorcerer", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = false
tt.particle_system.emit_area_spread = vec_2(6, 6)
tt.particle_system.emission_rate = 60
tt.particle_system.name = "sorcererbolt_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.rotation_spread = math.pi
tt.particle_system.scale_var = {0.8, 0.6}
tt.particle_system.scales_x = {1, 0.3}
tt.particle_system.scales_y = {1, 0.3}
--#endregion
--#region ps_tesla_overcharge
tt = RT("ps_tesla_overcharge", "particle_system")
tt.particle_system.name = "decal_tesla_overcharge"
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {0.6, 1}
tt.particle_system.alphas = {0, 255, 255, 0}
tt.particle_system.scales_x = {1, 0.45}
tt.particle_system.scales_y = {1, 0.45}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {0.5, 1.5}
tt.particle_system.emit_spread = 2 * math.pi
tt.particle_system.emit_duration = fts(7)
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {120, 120}
tt.particle_system.emission_rate = 90
tt.particle_system.source_lifetime = 2
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_flare_flareon
tt = RT("ps_flare_flareon", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 40
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {0.35, 0.7}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {0.6, 0.8}
tt.particle_system.scales_x = {0.8, 1.6}
tt.particle_system.scales_y = {0.8, 1.6}
tt.particle_system.emit_rotation_spread = math.pi
--#endregion
--#region ps_veznan_soul
tt = RT("ps_veznan_soul", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emission_spread = vec_2(6, 6)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "boss_veznan_soul_particle"
tt.particle_system.particle_lifetime = {fts(4), fts(8)}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {0.8, 1.2}
tt.particle_system.scales_x = {1, 0.3}
tt.particle_system.scales_y = {1, 0.3}
--#endregion
--#region ps_hacksaw_sawblade
tt = RT("ps_hacksaw_sawblade")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 200, 0, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "ps_hacksaw_sawblade"
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.scales_y = {1.5, 0.5}
--#endregion
--#region ps_elora_run
tt = RT("ps_elora_run")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_elora_run"
tt.particle_system.particle_lifetime = {0.8, 1}
--#endregion
--#region ps_hero_ignus_idle
tt = RT("ps_hero_ignus_idle", "particle_system")
tt.particle_system.name = "ps_hero_ignus_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.5, 0.5}
tt.particle_system.alphas = {255, 255}
tt.particle_system.emit_duration = nil
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {30, 30}
tt.particle_system.emission_rate = 2.5
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_ignus_run
tt = RT("ps_ignus_run")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 200, 0}
tt.particle_system.anchor = vec_2(0.5, 0.1)
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_ignus_run"
tt.particle_system.particle_lifetime = {0.6, 0.8}
--#endregion
--#region ps_hero_ignus_smoke
tt = RT("ps_hero_ignus_smoke", "ps_power_fireball")
tt.particle_system.scales_x = {2, 3}
tt.particle_system.scales_y = {2, 3}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = vec_2(0, 17)
tt.particle_system.name = "ps_hero_ignus_smoke"
tt.particle_system.sort_y_offset = -16
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_hero_10yr_idle
tt = RT("ps_hero_10yr_idle", "particle_system")
tt.particle_system.name = "ps_hero_10yr_particle_fire"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {0.5, 0.5}
tt.particle_system.alphas = {255, 255}
tt.particle_system.emit_duration = nil
tt.particle_system.emit_direction = d2r(90)
tt.particle_system.emit_speed = {30, 30}
tt.particle_system.emission_rate = 2.5
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_stage_snow
tt = RT("ps_stage_snow")

AC(tt, "pos", "particle_system")

tt.pos = vec_2(512, 768)
tt.particle_system.alphas = {255, 255, 255, 0}
tt.particle_system.emission_rate = 8
tt.particle_system.emit_area_spread = vec_2(1200, 10)
tt.particle_system.emit_direction = 3 * math.pi * 0.5
tt.particle_system.emit_speed = {30, 40}
tt.particle_system.emit_spread = math.pi / 8
tt.particle_system.particle_lifetime = {20, 30}
tt.particle_system.scale_var = {0.4, 0.7}
tt.particle_system.ts_offset = -20
tt.particle_system.z = Z_OBJECTS_SKY
tt.particle_system.name = "Copo"
--#endregion
--#region fx_teleport_arcane
tt = RT("fx_teleport_arcane", "fx")
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].prefix = "fx_teleport_arcane"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
--#endregion
--#region fx_bolt_sorcerer_hit
tt = RT("fx_bolt_sorcerer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.render.sprites[1].name = "hit"
--#endregion
--#region fx_mod_polymorph_sorcerer_small
tt = RT("fx_mod_polymorph_sorcerer_small", "fx")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_small"
tt.render.sprites[1].anchor.y = 0.5
--#endregion
--#region fx_mod_polymorph_sorcerer_big
tt = RT("fx_mod_polymorph_sorcerer_big", "fx_mod_polymorph_sorcerer_small")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_big"
--#endregion
--#region fx_hacksaw_sawblade_hit
tt = RT("fx_hacksaw_sawblade_hit", "fx")
tt.render.sprites[1].prefix = "fx_hacksaw_sawblade"
tt.render.sprites[1].name = "hit"
--#endregion
--#region fx_hero_thor_thunderclap_disipate
tt = RT("fx_hero_thor_thunderclap_disipate", "fx")
tt.render.sprites[1].name = "fx_hero_thor_thunderclap_disipate"
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt.render.sprites[1].z = Z_EFFECTS
--#endregion
--#region fx_bolt_elora_hit
tt = RT("fx_bolt_elora_hit", "fx")
tt.render.sprites[1].prefix = "fx_bolt_elora"
tt.render.sprites[1].name = "hit"
--#endregion
--#region fx_bolt_magnus_hit
tt = RT("fx_bolt_magnus_hit", "fx")
tt.render.sprites[1].name = "bolt_magnus_hit"
--#endregion
--#region fx_ignus_burn
tt = RT("fx_ignus_burn", "fx")
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
--#endregion
--#region fx_juggernaut_smoke
tt = RT("fx_juggernaut_smoke", "fx")
tt.render.sprites[1].name = "fx_juggernaut_smoke"
tt.render.sprites[1].anchor.y = 0.27
--#endregion
--#region fx_jt_tower_click
tt = RT("fx_jt_tower_click", "fx")
tt.render.sprites[1].name = "fx_jt_tower_click"
tt.render.sprites[1].anchor.y = 0.3
--#endregion
--#region fx_moloch_ring
tt = RT("fx_moloch_ring", "fx")
tt.render.sprites[1].name = "fx_moloch_ring"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_moloch_rocks
tt = RT("fx_moloch_rocks", "fx")
tt.render.sprites[1].name = "fx_moloch_rocks"
tt.render.sprites[1].anchor.y = 0.24242424242424243
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_myconid_spores
tt = RT("fx_myconid_spores", "fx")
tt.render.sprites[1].name = "fx_myconid_spores"
tt.render.sprites[1].anchor.y = 0.8
--#endregion
--#region fx_blackburn_smash
tt = RT("fx_blackburn_smash", "fx")
tt.render.sprites[1].name = "fx_blackburn_smash"
tt.render.sprites[1].anchor.y = 0.1588785046728972
--#endregion
--#region fx_veznan_demon_fire
tt = RT("fx_veznan_demon_fire", "fx")
tt.render.sprites[1].name = "fx_veznan_demon_fire"
--#endregion
--#region fx_explosion_rotten_shot
tt = RT("fx_explosion_rotten_shot", "fx")
tt.render.sprites[1].name = "explosion_rotten_shot"
tt.render.sprites[1].anchor = vec_2(0.5, 0.33783783783783783)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_explosion_flareon_flare
tt = RT("fx_explosion_flareon_flare", "fx")
tt.render.sprites[1].name = "explosion_flare_flareon"
tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_bolt_necromancer_hit
tt = RT("fx_bolt_necromancer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.render.sprites[1].name = "hit"
--#endregion
--#region fx_demon_portal_out
tt = RT("fx_demon_portal_out", "fx")
tt.render.sprites[1].prefix = "fx_demon_portal_out"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big"}
--#endregion
--#region fx_bolt_witch_hit
tt = RT("fx_bolt_witch_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_witch_hit"
--#endregion
--#region fx_hobgoblin_ground_hit
tt = RT("fx_hobgoblin_ground_hit", "fx")
tt.render.sprites[1].name = "fx_hobgoblin_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 2
--#endregion
--#region decal_paladin_holystrike
tt = RT("decal_paladin_holystrike", "decal_timed")
tt.render.sprites[1].name = "decal_paladin_holystrike"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_zombiemancer_raise
tt = RT("decal_zombiemancer_raise", "decal_timed")
tt.render.sprites[1].name = "decal_paladin_holystrike"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].color = {0, 255, 0}
--#endregion
--#region decal_oni_torment_sword
tt = RT("decal_oni_torment_sword", "decal_scripted")
tt.render.sprites[1].prefix = "decal_oni_torment_sword_1"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.main_script.update = scripts.decal_oni_torment_sword.update
tt.duration = 0.5
tt.delay = 0.01
tt.sword_names = {"decal_oni_torment_sword_1", "decal_oni_torment_sword_2", "decal_oni_torment_sword_3", "decal_oni_torment_sword_1"}
--#endregion
--#region decal_ignus_flaming
tt = RT("decal_ignus_flaming", "decal_timed")
tt.render.sprites[1].name = "decal_ignus_flaming"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_ingvar_attack
tt = RT("decal_ingvar_attack", "decal_tween")
tt.render.sprites[1].name = "hero_viking_axeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 200}, {1, 200}, {1.5, 0}}
--#endregion
--#region decal_jt_ground_hit
tt = RT("decal_jt_ground_hit", "decal_timed")
tt.render.sprites[1].name = "decal_jt_ground_hit"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_jt_tap
tt = RT("decal_jt_tap", "decal_loop")
tt.render.sprites[1].random_ts = fts(7)
tt.render.sprites[1].name = "decal_jt_tap"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = -40
tt.render.sprites[1].offset = vec_2(20, 40)
--#endregion
--#region decal_blackburn_smash_ground
tt = RT("decal_blackburn_smash_ground", "decal_timed")
tt.render.sprites[1].name = "fx_blackburn_smash_ground"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region veznan_portal
tt = RT("veznan_portal", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "veznan_portal"
tt.render.sprites[1].z = Z_DECALS
tt.fx_out = "fx_demon_portal_out"
tt.main_script.update = scripts.veznan_portal.update
tt.out_nodes = nil
tt.spawn_groups = {{{0.5, {{4, 7, "enemy_demon"}}}, {0.8, {{3, 3, "enemy_demon_wolf"}}}, {1, {{5, 5, "enemy_demon"}, {1, 1, "enemy_demon_mage"}}}}, {{0.5, {{2, 5, "enemy_demon"}}}, {0.8, {{2, 2, "enemy_demon_wolf"}}}, {1, {{3, 3, "enemy_demon"}}}}, {{1, {{3, 3, "enemy_demon"}}}}}
tt.portal_idx = 1
tt.spawn_interval = fts(30)
tt.pi = 1
--#endregion
--#region decal_s12_shoutbox
tt = RT("decal_s12_shoutbox", "decal_tween")

AC(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "boss_veznan_taunts_love_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(-3, 6)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(164, 70)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 24
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(1, 1)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
--#endregion
--#region decal_veznan_strike
tt = RT("decal_veznan_strike", "decal_timed")
tt.render.sprites[1].name = "decal_veznan_strike"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region veznan_soul
tt = RT("veznan_soul", "decal_scripted")
tt.angle_variation = d2r(5)
tt.duration = 8
tt.main_script.update = scripts.veznan_soul.update
tt.max_angle = d2r(70)
tt.min_angle = d2r(-70)
tt.particles_name = "ps_veznan_soul"
tt.render.sprites[1].name = "decal_veznan_soul"
tt.render.sprites[1].z = Z_EFFECTS
tt.speed = {6 * FPS, 15 * FPS}
--#endregion
--#region decal_eb_veznan_white_circle
tt = RT("decal_eb_veznan_white_circle", "decal_tween")
tt.render.sprites[1].name = "decal_veznan_white_circle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(65), vec_1(1)}, {fts(65) + 0.5, vec_1(20)}, {fts(65) + 4.5, vec_1(20)}}
--#endregion
--#region decal_hobgoblin_ground_hit
tt = RT("decal_hobgoblin_ground_hit", "decal_tween")
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.render.sprites[1].name = "hobgoblin_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
--#endregion
--#region tower_sasquash_holder
tt = RT("tower_sasquash_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "main_script")

tt.tower.type = "holder_sasquash"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.main_script.update = scripts.tower_sasquash_holder.update
tt.info.i18n_key = "SPECIAL_SASQUASH_REPAIR"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.info.portrait = "info_portraits_towers_0014"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_frozen_0001"
tt.render.sprites[1].offset = vec_2(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.unfreeze_radius = 60
tt.unfreeze_fx = "fx_tower_sasquash_unfreeze"
tt.unfreeze_upgrade_to = "tower_sasquash"
tt.unfreeze_rect = r(290, 480, 120, 90)
--#endregion
--#region fx_tower_sasquash_unfreeze
tt = RT("fx_tower_sasquash_unfreeze", "fx")
tt.render.sprites[1].name = "tower_sasquash_unfreeze"
tt.render.sprites[1].offset = vec_2(-9, 13)
tt.render.sprites[1].z = Z_EFFECTS
--#endregion
--#region tower_sasquash
tt = RT("tower_sasquash", "tower")

AC(tt, "barrack")

tt.info.portrait = "info_portraits_towers_0014"
tt.barrack.max_soldiers = 1
tt.barrack.rally_range = 288
tt.barrack.respawn_offset = vec_2(-60, 0)
tt.barrack.soldier_type = "soldier_sasquash"
tt.barrack.has_door = nil
tt.editor.props = table.append(tt.editor.props, {{"barrack.rally_pos", PT_COORDS}}, true)
tt.info.i18n_key = "SPECIAL_SASQUASH"
tt.info.fn = scripts.tower_sasquash_holder.get_info
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.remove = scripts.tower_barrack.remove
tt.main_script.update = scripts.tower_barrack_mercenaries.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_cave_inside"
tt.render.sprites[1].offset = vec_2(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.sound_events.change_rally_point = "SasquashRally"
tt.sound_events.insert = nil
tt.sound_events.mute_on_level_insert = true
tt.tower.can_be_sold = false
tt.tower.level = 1
tt.tower.price = 0
tt.tower.terrain_style = nil
tt.tower.type = "sasquash"
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.ui.has_nav_mesh = true
--#endregion
--#region soldier_sasquash
tt = RT("soldier_sasquash", "soldier_militia")
image_y = 80
anchor_y = 0.17
tt.health.hp_max = 2500
tt.health_bar.offset = vec_2(0, ady(73))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 12
tt.info.portrait = "info_portraits_soldiers_0008"
tt.info.i18n_key = "SOLDIER_SASQUASH"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_sasquash.insert
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 110
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 35
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(35, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].pop = {"pop_kapow", "pop_whaam"}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].pop_conds = DR_KILL
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 83
tt.motion.max_speed = 49.5
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_sasquash"
tt.soldier.melee_slot_offset = vec_2(25, 0)
tt.sound_events.insert = "SasquashReady"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.mod_offset = vec_2(0, ady(30))
tt.unit.price = 400
--#endregion
--#region soldier_s6_imperial_guard
tt = RT("soldier_s6_imperial_guard", "soldier_militia")

AC(tt, "editor")

anchor_y = 0.15
anchor_x = 0.5
image_y = 41
image_x = 58
tt.health.armor = 0.4
tt.health.dead_lifetime = 3
tt.health.hp_max = 250
tt.health_bar.offset = vec_2(adx(28), ady(40))
tt.info.portrait = "info_portraits_soldiers_0007"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(6)
tt.melee.cooldown = 1
tt.melee.range = 72.5
tt.motion.max_speed = 60
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "soldier_s6_imperial_guard"
tt.soldier.melee_slot_offset = vec_2(8, 0)
tt.unit.mod_offset = vec_2(adx(27), ady(22))
tt.editor.props = {{"editor.game_mode", PT_NUMBER}}
tt.editor.overrides = {
	["health.hp"] = 250
}
--#endregion
--#region re_farmer
tt = RT("re_farmer", "soldier_militia")

AC(tt, "reinforcement", "tween", "nav_grid")

image_y = 44
anchor_y = 0.1590909090909091
tt.cooldown = 10
tt.health.armor = 0
tt.health.hp_max = 30
tt.health_bar.offset = vec_2(0, ady(32))
tt.info.portrait_idxs = {9, 10, 11}
tt.controable = true
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 0.9
tt.melee.attacks[1].damage_max = 2
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(5)
tt.melee.range = 60
tt.motion.max_speed = 60
tt.regen.cooldown = 1
tt.reinforcement.duration = 23
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.insert = "ReinforcementTaunt"
tt.sound_events.change_rally_point = "ReinforcementTaunt"
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
--#endregion
--#region re_farmer_well_fed
tt = RT("re_farmer_well_fed", "re_farmer")
tt.unit.level = 1
tt.health.hp_max = 50
tt.health.armor = 0
tt.melee.attacks[1].damage_max = 3
tt.motion.max_speed = 65
--#endregion
--#region re_conscript
tt = RT("re_conscript", "re_farmer")
tt.info.portrait_idxs = {12, 13, 14}
tt.unit.level = 2
tt.health.hp_max = 70
tt.health.armor = 0.1
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].damage_max = 4
tt.motion.max_speed = 70
--#endregion
--#region re_warrior
tt = RT("re_warrior", "re_farmer")
tt.info.portrait_idxs = {15, 16, 17}
tt.unit.level = 3
tt.health.hp_max = 90
tt.health.armor = 0.2
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 6
tt.motion.max_speed = 75
--#endregion
--#region re_legionnaire
tt = RT("re_legionnaire", "re_farmer")
tt.info.portrait_idxs = {18, 19, 20}
tt.unit.level = 4
tt.health.hp_max = 110
tt.health.armor = 0.3
tt.health_bar.offset = vec_2(0, ady(34))
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 10
tt.motion.max_speed = 80
--#endregion
--#region re_legionnaire_ranged
tt = RT("re_legionnaire_ranged", "re_legionnaire")

AC(tt, "ranged")

tt.unit.level = 5
tt.motion.max_speed = 85
tt.ranged.attacks[1].bullet = "spear_legionnaire"
tt.ranged.attacks[1].shoot_time = fts(3)
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 27
tt.ranged.attacks[1].animation = IS_PHONE_OR_TABLET and "ranged_attack_p" or "ranged_attack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(6, 13)}

for i = 1, 3 do
	for j, name in ipairs({"re_farmer", "re_farmer_well_fed", "re_conscript", "re_warrior", "re_legionnaire", "re_legionnaire_ranged"}) do
		local fn = name .. "_" .. i
		-- local base_t = E:get_template(name)
		local t = RT(fn, name)

		t.render.sprites[1].prefix = fn
		t.info.portrait = string.format("info_portraits_soldiers_%04d", t.info.portrait_idxs[i])
	end
end

for i = 1, 3 do
	E:set_template("re_current_" .. i, E:get_template("re_farmer_" .. i))
end

--#endregion
--#region spear_legionnaire
tt = RT("spear_legionnaire", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 40
tt.bullet.flight_time = fts(20)
tt.bullet.miss_decal = "decal_spear"
tt.render.sprites[1].name = "spear"
tt.sound_events.insert = "AxeSound"
--#endregion
--#region arrow_shadow_archer
tt = RT("arrow_shadow_archer", "arrow")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
--#endregion
--#region axe_troll_axe_thrower
tt = RT("axe_troll_axe_thrower", "arrow")
tt.bullet.damage_min = 40
tt.bullet.damage_max = 80
tt.bullet.damage_type = DAMAGE_RUDE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "troll_axethrower_proyectiles_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "troll_axethrower_proyectiles_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
--#endregion
--#region ball_raider
tt = RT("ball_raider", "arrow")
tt.bullet.damage_min = 80
tt.bullet.damage_max = 120
tt.bullet.damage_type = DAMAGE_RUDE
tt.bullet.flight_time = fts(23)
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.miss_decal = "RaiderBall_0002"
tt.bullet.reset_to_target_pos = true
tt.render.sprites[1].name = "RaiderBall_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.sound_events.insert = "AxeSound"
--#endregion
--#region flare_flareon
tt = RT("flare_flareon", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.bullet.flight_time = fts(16)
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = "fx_explosion_flareon_flare"
tt.bullet.mod = "mod_flareon_burn"
tt.bullet.particles_name = "ps_flare_flareon"
tt.bullet.pop = nil
tt.render.sprites[1].name = "demon_flareon_flare"
tt.render.sprites[1].animated = true
--#endregion
--#region bolt_necromancer
tt = RT("bolt_necromancer", "bolt_enemy")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "fx_bolt_necromancer_hit"
tt.bullet.max_speed = 450
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.sound_events.insert = "BoltSorcererSound"
--#endregion
--#region bolt_witch
tt = RT("bolt_witch", "bolt_enemy")
tt.bullet.damage_max = 60
tt.bullet.damage_min = 40
tt.bullet.hit_fx = "fx_bolt_witch_hit"
tt.bullet.min_speed = 450
tt.bullet.max_speed = 750
tt.bullet.mod = "mod_witch_frog"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].prefix = "bolt_witch"
tt.sound_events.insert = "kr4_tower_wickedsisters_attack_v1"
--#endregion
--#region bolt_magnus
tt = RT("bolt_magnus", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_magnus"
tt.bullet.hit_fx = "fx_bolt_magnus_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_min = 9
tt.bullet.damage_max = 27
tt.bullet.max_speed = 360
tt.bullet.xp_gain_factor = 2.2
--#endregion
--#region bolt_magnus_illusion
tt = RT("bolt_magnus_illusion", "bolt_magnus")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.xp_gain_factor = nil
--#endregion
--#region bomb_goblin_zapper
tt = RT("bomb_goblin_zapper", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 60
tt.bullet.damage_min = 30
tt.bullet.damage_radius = 67.5
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_fragment"
tt.bullet.pop = {"pop_kboom"}
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "zapperbomb"
tt.sound_events.insert = nil
tt.sound_events.hit = "BombExplosionSound"
--#endregion
--#region bomb_swamp_thing
tt = RT("bomb_swamp_thing", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 100
tt.bullet.damage_min = 40
tt.bullet.damage_radius = 67.5
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenShot"
tt.sound_events.insert = "swamp_thing_bomb_shot"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
--#endregion
--#region bomb_greenmuck
tt = RT("bomb_greenmuck", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = 160
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 47.25
tt.bullet.flight_time_base = fts(17)
tt.bullet.flight_time_factor = fts(0.07142857142857142)
tt.bullet.hit_fx = "fx_explosion_rotten_shot"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "Proyectile_RottenBoss"
tt.sound_events.hit = "swamp_thing_bomb_explosion"
--#endregion
--#region ray_arcane
tt = RT("ray_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_arcane"
tt.bullet.hit_time = 0
tt.image_width = 150
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "ray_arcane"
tt.render.sprites[1].loop = true
tt.sound_events.insert = "ArcaneRaySound"
tt.track_target = true
tt.ray_duration = fts(10)
--#endregion
--#region ray_arcane_disintegrate
tt = RT("ray_arcane_disintegrate", "ray_arcane")
tt.bullet.mod = "mod_ray_arcane_disintegrate"
tt.image_width = 166
tt.render.sprites[1].name = "ray_arcane_disintegrate"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "DesintegrateSound"
--#endregion
--#region ray_sorcerer_polymorph
tt = RT("ray_sorcerer_polymorph", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(3)
tt.bullet.mod = "mod_polymorph_sorcerer"
tt.image_width = 130
tt.main_script.update = scripts.ray_simple.update
tt.ray_duration = fts(10)
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_sorcerer_polymorph"
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true
--#endregion
--#region ray_hero_thor
tt = RT("ray_hero_thor", "ray_tesla")
tt.bullet.mod = "mod_ray_hero_thor"
tt.render.sprites[1].name = "ray_hero_thor"
tt.main_script.update = scripts.ray_thor.update
--#endregion
--#region shotgun_bolin
tt = RT("shotgun_bolin", "shotgun")
tt.bullet.damage_max = 90
tt.bullet.damage_min = 45
tt.bullet.damage_type = bor(DAMAGE_SHOT, DAMAGE_NO_DODGE)
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
tt.bullet.start_fx = nil
tt.bullet.min_speed = 20 * FPS
tt.bullet.max_speed = 20 * FPS
tt.bullet.xp_gain_factor = 2.4
tt.sound_events.insert = "ShotgunSound"
--#endregion
--#region enemy_spider_rotten_egg
tt = RT("enemy_spider_rotten_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_rotten_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_rotten_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region myconid_spawner
tt = RT("myconid_spawner")

AC(tt, "pos", "spawner", "main_script")

tt.main_script.update = scripts.enemies_spawner.update
tt.spawner.count = 2
tt.spawner.random_cycle = {0, 1}
tt.spawner.entity = "enemy_rotten_lesser"
tt.spawner.random_node_offset_range = {-2, 9}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.spawn_sound = "EnemyMushroomBorn"
tt.spawner.spawn_sound_args = {
	delay = fts(29)
}
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
--#endregion
--#region aura_teleport_arcane
tt = RT("aura_teleport_arcane", "aura")

AC(tt, "render")

tt.aura.mod = "mod_teleport_arcane"
tt.aura.duration = fts(23)
tt.aura.apply_delay = fts(5)
tt.aura.apply_duration = fts(10)
tt.aura.max_count = 4
tt.aura.cycle_time = fts(2)
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_RANGED, F_MOD, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "aura_teleport_arcane"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.375
tt.sound_events.insert = "TeleporthSound"
--#endregion
--#region aura_ignus_idle
tt = RT("aura_ignus_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_ignus_idle"
tt.emit_states = {"idle", "attack"}
tt.main_script.update = scripts.aura_ignus_particles.update
tt.particle_offsets = {vec_2(-17, 16), vec_2(-12, 27), vec_2(4, 37), vec_2(2, 35), vec_2(12, 22), vec_2(14, 13)}
tt.flip_offset = vec_2(3, 0)
--#endregion
--#region aura_10yr_idle
tt = RT("aura_10yr_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_10yr_idle"
tt.emit_states = {"idle", "running"}
tt.main_script.update = scripts.aura_10yr_particles.update
tt.particle_offsets = {vec_2(-25.714285714285715, 25.714285714285715), vec_2(-15.714285714285715, 37.142857142857146), vec_2(0, 45.714285714285715), vec_2(8.571428571428571, 42.85714285714286), vec_2(14.285714285714286, 32.85714285714286), vec_2(21.42857142857143, 21.42857142857143)}
tt.flip_offset = vec_2(3, 0)
--#endregion
--#region aura_troll_regen
tt = RT("aura_troll_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 1
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
--#endregion
--#region aura_forest_troll_regen
tt = RT("aura_forest_troll_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(4)
tt.regen.health = 4
--#endregion
--#region aura_troll_axe_thrower_regen
tt = RT("aura_troll_axe_thrower_regen", "aura_troll_regen")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 2
--#endregion
--#region aura_troll_brute_regen
tt = RT("aura_troll_brute_regen", "aura_forest_troll_regen")
--#endregion
--#region aura_troll_chieftain_regen
tt = RT("aura_troll_chieftain_regen", "aura_troll_regen")
tt.regen.cooldown = fts(6)
tt.regen.health = 4
--#endregion
--#region aura_ulgukhai_regen
tt = RT("aura_ulgukhai_regen", "aura_forest_troll_regen")
tt.regen.ignore_mods = true
--#endregion
--#region aura_goblin_zapper_death
tt = RT("aura_goblin_zapper_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 150
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
--#endregion
--#region aura_demon_death
tt = RT("aura_demon_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.excluded_templates = {"hero_oni"}
tt.aura.radius = 60
tt.aura.track_damage = true
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
--#endregion
--#region aura_demon_mage_death
tt = RT("aura_demon_mage_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
--#endregion
--#region aura_demon_wolf_death
tt = RT("aura_demon_wolf_death", "aura_demon_death")
tt.aura.damage_min = 70
tt.aura.damage_max = 140
--#endregion
--#region aura_rotten_lesser_death
tt = RT("aura_rotten_lesser_death", "aura")
tt.aura.cycles = 1
tt.aura.radius = 60
tt.aura.mod = "mod_rotten_lesser_pestilence"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_POISON)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
--#endregion
--#region aura_swamp_thing_regen
tt = RT("aura_swamp_thing_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(2)
tt.regen.health = 1
tt.regen.ignore_stun = false
tt.regen.ignore_freeze = false
--#endregion
--#region aura_flareon_death
tt = RT("aura_flareon_death", "aura_demon_death")
tt.aura.damage_min = 40
tt.aura.damage_max = 80
--#endregion
--#region aura_gulaemon_death
tt = RT("aura_gulaemon_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400
--#endregion
--#region aura_burning_floor
tt = RT("aura_burning_floor", "aura")

AC(tt, "render", "tween")

tt.aura.active = false
tt.aura.cycle_time = 0.3
tt.aura.mod = "mod_burning_floor_burn"
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_MOD, F_BURN, F_RANGED)
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.main_script.update = scripts.aura_burning_floor.update
tt.render.sprites[1].name = "InfernoDecal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "InfernoDecal_0002"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{fts(0), 0}, {fts(30), 255}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 2
--#endregion
--#region burning_floor_controller
tt = RT("burning_floor_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.burning_floor_controller.update
--#endregion
--#region aura_demon_cerberus_death
tt = RT("aura_demon_cerberus_death", "aura_demon_death")
tt.aura.damage_min = 666
tt.aura.damage_max = 666
tt.aura.radius = 120
--#endregion
--#region aura_troll_skater_regen
tt = RT("aura_troll_skater_regen", "aura_troll_regen")

AC(tt, "regen")

tt.regen.cooldown = fts(4)
tt.regen.health = 1
--#endregion
--#region graveyard_controller
tt = RT("graveyard_controller")

AC(tt, "graveyard", "main_script")

tt.main_script.update = scripts.graveyard_controller.update
tt.graveyard.dead_time = 0.5
tt.graveyard.check_interval = 0.25
tt.graveyard.keep_gold = true
tt.graveyard.spawn_interval = 0.1
tt.graveyard.spawns_by_health = {{"enemy_skeleton", 299}, {"enemy_skeleton_big", 9e+99}}
tt.graveyard.vis_has = F_ENEMY
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_BOSS
--#endregion
--#region graveyard_s110
tt = RT("graveyard_s110", "graveyard_controller")
tt.main_script.update = scripts.graveyard_s110.update
tt.graveyard.keep_gold = false
tt.graveyard.spawns_by_health = {{"enemy_skeleton", 400}, {"enemy_halloween_zombie", 600}, {"enemy_skeleton_big", 1000}, {"enemy_gnoll_bloodsydian", 2000}, {"enemy_blade", 3750}, {"eb_alleria", 9e+99}}
tt.graveyard.vis_has = bor(F_ENEMY, F_FRIEND)
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_HERO
--#endregion
--#region swamp_controller
tt = RT("swamp_controller", "graveyard_controller")
tt.graveyard.spawns_by_health = {{"enemy_zombie", 400}, {"enemy_swamp_thing", 9e+99}}
tt.graveyard.excluded_templates = {"soldier_alleria_wildcat", "soldier_magnus_illusion"}
tt.graveyard.keep_gold = false
tt.graveyard.vis_has = F_FRIEND
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_HERO
--#endregion
--#region s15_rotten_spawner
tt = RT("s15_rotten_spawner")

AC(tt, "main_script", "editor")

tt.main_script.update = scripts.s15_rotten_spawner.update
tt.entity = "enemy_rotten_tree"
tt.spawn_margin = {30, 60}
tt.spawn_timers = {
	{10, 0},
	[11] = {15, 1},
	[14] = {10, 0},
	[15] = {15, 2},
	[17] = {15, 3},
	[20] = {15, 6}
}
--#endregion
--#region s11_lava_spawner
tt = RT("s11_lava_spawner")

AC(tt, "main_script")

tt.main_script.update = scripts.s11_lava_spawner.update
tt.entity = "enemy_lava_elemental"
tt.cooldown = 400
tt.cooldown_after = 120
tt.pi = 4
tt.sound = "RockElementalDeath"
--#endregion
--#region jt_spawner_aura
tt = RT("jt_spawner_aura", "aura")
tt.main_script.update = scripts.jt_spawner_aura.update
tt.aura.track_source = true
tt.spawn_data = {{"enemy_whitewolf", 8, 0, 2, 1}, {"enemy_whitewolf", 8, fts(20), 2, 2}, {"enemy_yeti", 19, 0, 3, 1}}
--#endregion
--#region blackburn_aura
tt = RT("blackburn_aura", "aura")
tt.main_script.update = scripts.blackburn_aura.update
tt.aura.cycle_time = 0.5
tt.aura.duration = -1
tt.aura.radius = 106.38297872340426
tt.aura.raise_entity = "enemy_skeleton_big"
tt.count_group_name = "blackburn_skeletons"
tt.count_group_type = COUNT_GROUP_CONCURRENT
tt.count_group_max = 15
--#endregion
--#region veznan_souls_aura
tt = RT("veznan_souls_aura", "aura")
tt.main_script.update = scripts.veznan_souls_aura.update
tt.aura.track_source = true
tt.souls = {
	angles = {d2r(30), d2r(130)},
	count = 60,
	delay_frames = 10,
	entity = "veznan_soul"
}
--#endregion
--#region kingpin_damage_aura
tt = RT("kingpin_damage_aura", "aura")
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura.duration = -1
tt.aura.cycle_time = fts(2)
tt.aura.damage_min = 100
tt.aura.damage_max = 100
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 65
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.aura.vis_flags = bor(F_RANGED)
--#endregion
--#region mod_arcane_shatter
tt = RT("mod_arcane_shatter", "mod_damage")
tt.damage_min = 0.035
tt.damage_max = 0.035
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)
--#endregion
--#region mod_arcane_shatter_little
tt = RT("mod_arcane_shatter_little", "mod_damage")
tt.damage_min = 0.02
tt.damage_max = 0.02
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)
--#endregion
--#region mod_slow_curse
tt = RT("mod_slow_curse", "mod_slow")
tt.main_script.insert = scripts.mod_slow_curse.insert
tt.modifier.excluded_templates = {"enemy_demon_cerberus"}
--#endregion
--#region mod_ray_sunray_hit
tt = RT("mod_ray_sunray_hit", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(24)
tt.render.sprites[1].name = "fx_ray_sunray_hit"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
--#endregion
--#region mod_shaman_heal
tt = RT("mod_shaman_heal", "modifier")

AC(tt, "hps", "render")

tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt.hps.heal_every = 9e+99
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(24)
tt.modifier.allows_duplicates = true
--#endregion
--#region mod_rocketeer_speed_buff
tt = RT("mod_rocketeer_speed_buff", "modifier")

AC(tt, "fast")

tt.main_script.insert = scripts.mod_rocketeer_speed_buff.insert
tt.main_script.remove = scripts.mod_rocketeer_speed_buff.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.sound_events.insert = "EnemyRocketeer"
tt.fast.factor = 3.6041666666666665
tt.walk_angles = {"walkingRightLeft_fast", "walkingUp_fast", "walkingDown_fast"}
--#endregion
--#region mod_troll_rage
tt = RT("mod_troll_rage", "modifier")

AC(tt, "render")

tt.extra_armor = 0.5
tt.extra_damage_max = 30
tt.extra_damage_min = 15
tt.extra_speed = 30
tt.main_script.insert = scripts.mod_troll_rage.insert
tt.main_script.remove = scripts.mod_troll_rage.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 6
tt.modifier.type = MOD_TYPE_RAGE
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].name = "mod_troll_rage"
--#endregion
--#region mod_troll_heal
tt = RT("mod_troll_heal", "mod_shaman_heal")
--#endregion
--#region mod_demon_shield
tt = RT("mod_demon_shield", "modifier")

AC(tt, "render")

tt.modifier.bans = {"mod_sorcerer_curse_dps", "mod_sorcerer_curse_armor"}
tt.modifier.remove_banned = true
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD)
tt.shield_ignore_hits = 4
tt.main_script.insert = scripts.mod_demon_shield.insert
tt.main_script.remove = scripts.mod_demon_shield.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "fx_shield_small"
--#endregion
--#region mod_rotten_lesser_pestilence
tt = RT("mod_rotten_lesser_pestilence", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.modifier.duration = 5 - fts(4)
tt.render.sprites[1].prefix = "poison_violet"
--#endregion
--#region mod_poison_giant_rat
tt = RT("mod_poison_giant_rat", "mod_poison")
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.modifier.duration = 2
tt.reduced_damage_factor = 0.5
tt.render.sprites[1].prefix = "poison_violet"
tt.main_script.insert = scripts.mod_giant_rat_poison.insert
tt.main_script.remove = scripts.mod_giant_rat_poison.remove
--#endregion
--#region mod_wererat_poison
tt = RT("mod_wererat_poison", "mod_poison_giant_rat")
tt.dps.damage_max = 15
tt.dps.damage_min = 15
--#endregion
--#region mod_flareon_burn
tt = RT("mod_flareon_burn", "mod_lava")
tt.dps.damage_min = 20
tt.dps.damage_max = 20
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_POISON
tt.modifier.duration = 3
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
--#endregion
--#region mod_gulaemon_fly
tt = RT("mod_gulaemon_fly", "modifier")
-- tt.main_script.queue = scripts.mod_gulaemon_fly.queue
-- tt.main_script.dequeue = scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = scripts.mod_gulaemon_fly.insert
tt.main_script.remove = scripts.mod_gulaemon_fly.remove
tt.main_script.update = scripts.mod_gulaemon_fly.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 3.666666666666667
tt.nodes_limit = 20
--#endregion
--#region mod_troll_skater
tt = RT("mod_troll_skater", "modifier")
-- tt.main_script.queue = scripts.mod_gulaemon_fly.queue
-- tt.main_script.dequeue = scripts.mod_gulaemon_fly.dequeue
tt.main_script.insert = scripts.mod_gulaemon_fly.insert
tt.main_script.update = scripts.mod_gulaemon_fly.update
tt.main_script.remove = scripts.mod_gulaemon_fly.remove
tt.modifier.type = MOD_TYPE_FAST
tt.speed_factor = 2.4166666666666665
tt.nodes_limit = 1
tt.modifier.duration = 1000000000
--#endregion
--#region mod_burning_floor_burn
tt = RT("mod_burning_floor_burn", "mod_flareon_burn")
tt.modifier.duration = 0.5
--#endregion
--#region mod_witch_frog
tt = RT("mod_witch_frog", "modifier")

AC(tt, "render", "tween")

tt.animation_delay = 0.8
tt.main_script.insert = scripts.mod_witch_frog.insert
tt.main_script.update = scripts.mod_witch_frog.update
tt.modifier.damage_max = 60
tt.modifier.damage_min = 40
tt.modifier.damage_type = DAMAGE_EAT
tt.modifier.hero_damage_type = DAMAGE_MAGICAL
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "mod_witch_frog"
tt.frog_delay = fts(4)
tt.fx_delay = fts(19)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {1.5, vec_2(16, 0)}}
tt.tween.props[1].name = "offset"
tt.tween.remove = false
--#endregion
--#region mod_jt_tower
tt = RT("mod_jt_tower", "modifier")

AC(tt, "render", "tween", "ui")

tt.main_script.update = scripts.mod_jt_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_jt"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_jt_tap"
tt.render.sprites[2].offset = vec_2(10, 20)
tt.render.sprites[2].random_ts = fts(7)
tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE_OR_TABLET and 5 or 3
tt.end_delay = fts(5)
tt.sound_events.click = "JtHitIce"
tt.tween.remove = false
tt.tween.props[1].disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}

if IS_CONSOLE then
	tt.tween.props[2] = CC("tween_prop")
	tt.tween.props[2].name = "scale"
	tt.tween.props[2].keys = {{0, vec_1(1.6)}, {0.25, vec_1(1.9)}, {0.5, vec_1(1.6)}}
	tt.tween.props[2].sprite_id = 2
	tt.tween.props[2].loop = true
end

tt.ui.can_select = false
tt.ui.can_click = true
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.click_fx = "fx_jt_tower_click"
tt.ui.z = 1
--#endregion
--#region mod_gulthak_heal
tt = RT("mod_gulthak_heal", "mod_shaman_heal")
tt.hps.heal_min = 200
tt.hps.heal_max = 200
--#endregion
--#region mod_kingpin_heal_self
tt = RT("mod_kingpin_heal_self", "mod_shaman_heal")
tt.hps.heal_min = 500
tt.hps.heal_max = 500
tt.render.sprites[1].anchor.y = 0.3
--#endregion
--#region mod_kingpin_heal_others
tt = RT("mod_kingpin_heal_others", "mod_shaman_heal")
tt.hps.heal_min = 50
tt.hps.heal_max = 50
--#endregion
--#region mod_myconid_poison
tt = RT("mod_myconid_poison", "mod_poison")
tt.dps.damage_every = fts(2)
tt.dps.damage_max = 4
tt.dps.damage_min = 4
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "poison_violet"
--#endregion
--#region mod_blackburn_stun
tt = RT("mod_blackburn_stun", "mod_stun")
tt.modifier.duration = 4
tt.modifier.duration_heroes = 2
--#endregion
--#region mod_blackburn_tower
tt = RT("mod_blackburn_tower", "modifier")

AC(tt, "render", "tween", "main_script")

tt.main_script.update = scripts.mod_blackburn_tower.update
tt.modifier.duration = 4
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].name = "mod_blackburn_tower"
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
--#endregion
--#region mod_veznan_tower
tt = RT("mod_veznan_tower", "modifier")

AC(tt, "render", "ui")

if IS_CONSOLE then
	AC(tt, "tween")
end

tt.click_time = 4
tt.duration = 6
tt.main_script.update = scripts.mod_veznan_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_veznan"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_veznan_tap"
tt.render.sprites[2].offset = vec_2(10, 20)
tt.render.sprites[2].random_ts = fts(7)
tt.render.sprites[2].draw_order = 11
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.required_clicks = IS_PHONE_OR_TABLET and 5 or IS_CONSOLE and 1 or 3
tt.sound_blocked = "VeznanHoldTrap"
tt.sound_click = "VeznanHoldHit"
tt.sound_released = "VeznanHoldDissipate"

if IS_CONSOLE then
	tt.tween.remove = false
	tt.tween.props[1] = CC("tween_prop")
	tt.tween.props[1].name = "scale"
	tt.tween.props[1].keys = {{0, vec_1(1.6)}, {0.25, vec_1(1.9)}, {0.5, vec_1(1.6)}}
	tt.tween.props[1].sprite_id = 2
	tt.tween.props[1].loop = true
end

tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.z = 1
--#endregion
--#region mod_elder_shaman_heal
tt = RT("mod_elder_shaman_heal", "mod_shaman_heal")
tt.hps.heal_min = nil
tt.hps.heal_max = nil
--#endregion
--#region mod_elder_shaman_damage
tt = RT("mod_elder_shaman_damage", "mod_lava")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.modifier.duration = 1
--#endregion
--#region mod_elder_shaman_speed
tt = RT("mod_elder_shaman_speed", "mod_slow")

AC(tt, "render")

tt.slow.factor = nil
tt.modifier.duration = 3
tt.render.sprites[1].name = "mod_elder_shaman_speed"

E:set_template("user_power_1", E:get_template("power_fireball_control"))
E:set_template("user_power_2", E:get_template("power_reinforcements_control"))

--#endregion
--#region decal_sheep_big
tt = RT("decal_sheep_big", "decal_delayed_click_play")

AC(tt, "tween")

tt.delayed_play.achievement_inc = "SHEEP_KILLER"
tt.delayed_play.click_interrupts = true
tt.delayed_play.click_tweens = true
tt.delayed_play.click_sound = "Sheep"
tt.delayed_play.clicked_animation = nil
tt.delayed_play.clicked_sound = "DeathEplosion"
tt.delayed_play.clicked_sound_alt = "BombExplosionSound"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 8
tt.delayed_play.required_clicks_fx = "fx_unit_explode"
tt.delayed_play.required_clicks_fx_alt = "fx_explosion_small"
tt.delayed_play.required_clicks_fx_alt_chance = 0.1
tt.delayed_play.required_clicks_hide = true
tt.main_script.insert = scripts.decal_sheep_big.insert
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "decal_sheep_big"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.12, vec_2(1.2, 1.2)}, {0.16, vec_2(1, 1)}}
tt.tween.props[1].name = "scale"
tt.tween.remove = false
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.ui.can_select = false
--#endregion
--#region decal_sheep_small
tt = RT("decal_sheep_small", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_sheep_small"
--#endregion
--#region decal_mill_big
tt = RT("decal_mill_big", "decal_click_pause")
tt.render.sprites[1].name = "decal_mill_big"
tt.ui.can_select = false
tt.ui.click_rect = r(-10, -30, 40, 65)
--#endregion
--#region decal_mill_small
tt = RT("decal_mill_small", "decal_mill_big")
tt.render.sprites[1].name = "decal_mill_small"
tt.ui.click_rect = r(-10, -25, 35, 55)
--#endregion
--#region decal_s01_trees
tt = RT("decal_s01_trees", "decal")
tt.render.sprites[1].name = "stage1_trees"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.234375
--#endregion
--#region decal_boat_big
tt = RT("decal_boat_big", "decal_loop")
tt.render.sprites[1].name = "decal_boat_big_idle"
--#endregion
--#region decal_boat_small
tt = RT("decal_boat_small", "decal_loop")
tt.render.sprites[1].name = "decal_boat_small_idle"
--#endregion
--#region decal_fish
tt = RT("decal_fish", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_fish.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -17, 48, 34)
tt.achievement_id = "CATCH_A_FISH"
--#endregion
--#region decal_water_spark
tt = RT("decal_water_spark", "decal_loop")
tt.render.sprites[1].name = "decal_water_spark_play"
--#endregion
--#region decal_water_wave
tt = RT("decal_water_wave", "decal_delayed_play")
tt.render.sprites[1].name = "decal_water_wave_play"
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_water_wave_play"
--#endregion
--#region decal_goat
tt = RT("decal_goat", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_goat"
--#endregion
--#region decal_tunnel_light
tt = RT("decal_tunnel_light", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = scripts.decal_tunnel_light.update
tt.render.sprites[1].name = "cave_light_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, 255}, {0.15, 200}, {0.3, 255}, {0.4, 220}, {0.7, 255}}
tt.track_names = nil
tt.track_ids = nil
--#endregion
--#region decal_burner_big
tt = RT("decal_burner_big", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.13)
tt.render.sprites[1].name = "decal_burner_big_idle"
--#endregion
--#region decal_burner_small
tt = RT("decal_burner_small", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.11)
tt.render.sprites[1].name = "decal_burner_small_idle"
--#endregion
--#region decal_fredo
tt = RT("decal_fredo", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_fredo"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.1)
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_fredo.update
tt.ui.can_click = true
tt.ui.click_rect = r(-33, 104, 30, 30)
--#endregion
--#region decal_orc_burner
tt = RT("decal_orc_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
--#endregion
--#region decal_orc_flag
tt = RT("decal_orc_flag", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.07)
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_orc_flag_idle"
--#endregion
--#region decal_swamp_bubble
tt = RT("decal_swamp_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_swamp_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_swamp_bubble_jump"
--#endregion
--#region decal_demon_portal_big
tt = RT("decal_demon_portal_big", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].name = "decal_demon_portal_big_active"
tt.main_script.update = scripts.decal_demon_portal_big.update
tt.fx_out = "fx_demon_portal_out"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = false
tt.tween.props[1].keys = {{fts(0), 0}, {fts(30), 180}, {fts(40), 255}}
tt.out_nodes = nil
tt.shutdown_timeout = 5
--#endregion
--#region decal_s17_barricade
tt = RT("decal_s17_barricade", "decal")

AC(tt, "editor", "main_script")

tt.boss_name = "eb_kingpin"
tt.boss_spawn_wave = 15
tt.main_script.update = scripts.decal_s17_barricade.update
tt.render.sprites[1].prefix = "decal_s17_barricade"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.x = 0.4
tt.render.sprites[1].loop = false
tt.editor.props = {{"editor.game_mode", PT_NUMBER}}
--#endregion
--#region decal_bandits_flag
tt = RT("decal_bandits_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_bandits_flag_idle"
--#endregion
--#region decal_scrat
tt = RT("decal_scrat", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_scrat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_scrat_ice"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
tt.render.sprites[2].loop = false
tt.touch_fx = "fx_decal_scrat_touch"
tt.main_script.update = scripts.decal_scrat.update
tt.ui.can_click = true
tt.ui.click_rect = r(-45, 5, 40, 40)
--#endregion
--#region fx_decal_scrat_touch
tt = RT("fx_decal_scrat_touch", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_scrat_touch_fx"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.sound_events.insert = "JtHitIce"
--#endregion
--#region decal_troll_flag
tt = RT("decal_troll_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(18)
tt.render.sprites[1].name = "decal_troll_flag_idle"
--#endregion
--#region decal_troll_burner
tt = RT("decal_troll_burner", "decal_loop")
tt.render.sprites[1].random_ts = fts(11)
tt.render.sprites[1].name = "decal_troll_burner_idle"
--#endregion
--#region decal_frozen_mushroom
tt = RT("decal_frozen_mushroom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_frozen_mushroom"
tt.click_play.required_clicks = 1
tt.click_play.clicked_sound = "MushroomPoof"
tt.click_play.play_once = true
--#endregion
--#region decal_lava_fall
tt = RT("decal_lava_fall", "decal_loop")
tt.render.sprites[1].name = "decal_lava_fall_idle"
--#endregion
--#region decal_inferno_bubble
tt = RT("decal_inferno_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_inferno_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_inferno_bubble_jump"
--#endregion
--#region decal_lava_splash
tt = RT("decal_lava_splash", "decal_inferno_bubble")
tt.render.sprites[1].name = "decal_lava_splash_jump"
tt.delayed_play.play_animation = "decal_lava_splash_jump"
--#endregion
--#region decal_inferno_portal
tt = RT("decal_inferno_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_portal_active"
--#endregion
--#region decal_inferno_ground_portal
tt = RT("decal_inferno_ground_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_ground_portal_active"
--#endregion
--#region decal_s21_veznan
tt = RT("decal_s21_veznan", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_s21_veznan_free
tt = RT("decal_s21_veznan_free", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_s21_hellboy
tt = RT("decal_s21_hellboy", "decal")
tt.render.sprites[1].name = "decal_s21_hellboy_idle"
--#endregion
--#region background_sounds_blackburn
tt = RT("background_sounds_blackburn", "background_sounds")
tt.min_delay = 20
tt.max_delay = 30
tt.sounds = {}
--#endregion
--#region decal_s23_splinter
tt = RT("decal_s23_splinter", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s23_splinter"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.x = -6
tt.ui.click_rect.size.x = 25
--#endregion
--#region decal_s23_splinter_pizza
tt = RT("decal_s23_splinter_pizza", "decal_s23_splinter")
tt.main_script.update = scripts.decal_s23_splinter_pizza.update
tt.render.sprites[1].prefix = "decal_s23_splinter_pizza"
--#endregion
--#region decal_bat_flying
tt = RT("decal_bat_flying", "decal_delayed_play")

AC(tt, "tween")

tt.render.sprites[1].prefix = "decal_bat_flying"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.insert = scripts.decal_bat_flying.insert
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 20
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_duration = 2
tt.tween.remove = false
tt.tween.props[1].name = "offset"

local bat_speed_per_node = 0.035
local bat_paths = {{
	vec_2(-7.74, 618.5),
	vec_2(-0.64, 619.52),
	vec_2(6.27, 620.86),
	vec_2(13.12, 622.27),
	vec_2(19.97, 623.81),
	vec_2(26.62, 625.54),
	vec_2(33.41, 627.46),
	vec_2(40, 629.57),
	vec_2(46.59, 631.87),
	vec_2(53.12, 634.43),
	vec_2(59.39, 637.06),
	vec_2(65.66, 639.87),
	vec_2(71.74, 643.07),
	vec_2(77.63, 646.34),
	vec_2(83.52, 650.05),
	vec_2(89.15, 653.89),
	vec_2(94.66, 658.11),
	vec_2(99.71, 662.72),
	vec_2(104.7, 667.65),
	vec_2(109.12, 672.9),
	vec_2(113.22, 678.59),
	vec_2(116.86, 684.54),
	vec_2(119.94, 690.82),
	vec_2(122.5, 697.41),
	vec_2(124.42, 704.06),
	vec_2(125.7, 710.91),
	vec_2(126.08, 717.95),
	vec_2(125.25, 724.8),
	vec_2(123.2, 731.58),
	vec_2(120.06, 737.86),
	vec_2(116.1, 743.87),
	vec_2(111.68, 749.7),
	vec_2(107.2, 755.26),
	vec_2(102.72, 760.7),
	vec_2(98.18, 766.21),
	vec_2(94.21, 771.9),
	vec_2(90.56, 777.79),
	vec_2(87.68, 784.19)
}, {
	vec_2(502.46, 774.14),
	vec_2(503.42, 767.23),
	vec_2(504.7, 760.38),
	vec_2(506.11, 753.54),
	vec_2(507.84, 746.75),
	vec_2(509.76, 739.97),
	vec_2(511.81, 733.44),
	vec_2(514.18, 727.1),
	vec_2(516.99, 720.96),
	vec_2(520.13, 715.01),
	vec_2(523.97, 709.38),
	vec_2(528.45, 704.38),
	vec_2(534.21, 700.42),
	vec_2(540.8, 698.11),
	vec_2(547.71, 698.11),
	vec_2(554.69, 699.01),
	vec_2(561.47, 700.86),
	vec_2(568, 703.36),
	vec_2(574.27, 706.62),
	vec_2(580.16, 710.46),
	vec_2(585.73, 714.62),
	vec_2(590.98, 718.78),
	vec_2(596.29, 722.69),
	vec_2(602.5, 725.7),
	vec_2(609.54, 726.59),
	vec_2(617.09, 725.82),
	vec_2(624.38, 724.93),
	vec_2(631.36, 724.1),
	vec_2(638.27, 723.65),
	vec_2(645.12, 723.65),
	vec_2(652.03, 724.35),
	vec_2(658.82, 725.7),
	vec_2(665.47, 728.13),
	vec_2(671.94, 731.33),
	vec_2(677.7, 735.23),
	vec_2(683.14, 739.97),
	vec_2(688, 745.15),
	vec_2(692.42, 750.78),
	vec_2(696.26, 756.67),
	vec_2(699.71, 762.88),
	vec_2(702.85, 769.09),
	vec_2(706.24, 776.83)
}, {
	vec_2(1031.49, 454.02),
	vec_2(1024.38, 455.17),
	vec_2(1017.54, 456.45),
	vec_2(1010.62, 457.79),
	vec_2(1003.84, 459.39),
	vec_2(997.12, 461.18),
	vec_2(990.46, 462.98),
	vec_2(983.74, 465.15),
	vec_2(977.15, 467.46),
	vec_2(970.62, 469.95),
	vec_2(964.42, 472.64),
	vec_2(958.21, 475.46),
	vec_2(952.13, 478.53),
	vec_2(946.18, 481.86),
	vec_2(940.35, 485.5),
	vec_2(934.72, 489.41),
	vec_2(929.28, 493.7),
	vec_2(924.16, 498.24),
	vec_2(919.3, 503.1),
	vec_2(914.69, 508.48),
	vec_2(910.66, 514.05),
	vec_2(907.01, 520),
	vec_2(903.94, 526.27),
	vec_2(901.31, 532.74),
	vec_2(899.33, 539.52),
	vec_2(898.05, 546.37),
	vec_2(897.73, 553.28),
	vec_2(898.56, 560.26),
	vec_2(900.54, 566.98),
	vec_2(903.55, 573.18),
	vec_2(907.58, 579.2),
	vec_2(912, 585.15),
	vec_2(916.48, 590.72),
	vec_2(920.9, 596.29),
	vec_2(925.44, 601.6),
	vec_2(929.41, 607.3),
	vec_2(933.06, 613.18),
	vec_2(936.38, 619.26),
	vec_2(939.52, 625.6),
	vec_2(941.95, 632.06),
	vec_2(944, 638.72),
	vec_2(945.6, 645.57),
	vec_2(946.69, 652.61),
	vec_2(947.46, 659.78),
	vec_2(947.84, 666.75),
	vec_2(947.9, 673.79),
	vec_2(947.65, 680.83),
	vec_2(947.14, 687.87),
	vec_2(946.3, 694.85),
	vec_2(945.22, 701.89),
	vec_2(942.78, 708.61),
	vec_2(939.71, 715.26),
	vec_2(936.32, 721.47),
	vec_2(932.86, 727.42),
	vec_2(929.02, 733.44),
	vec_2(925.06, 739.14),
	vec_2(920.83, 744.77),
	vec_2(916.54, 750.21),
	vec_2(912, 755.58),
	vec_2(907.26, 760.7),
	vec_2(902.34, 765.82),
	vec_2(897.41, 770.82),
	vec_2(892.29, 775.42),
	vec_2(887.17, 780.22)
}, {
	vec_2(1028.54, 116.61),
	vec_2(1022.78, 120.96),
	vec_2(1016.9, 124.99),
	vec_2(1010.82, 128.83),
	vec_2(1004.74, 132.22),
	vec_2(998.46, 135.3),
	vec_2(992, 138.18),
	vec_2(985.41, 140.61),
	vec_2(978.75, 142.66),
	vec_2(971.78, 144.19),
	vec_2(964.86, 145.6),
	vec_2(957.76, 146.37),
	vec_2(950.66, 146.69),
	vec_2(943.62, 146.56),
	vec_2(936.77, 145.41),
	vec_2(930.05, 142.98),
	vec_2(924.1, 139.07),
	vec_2(918.85, 134.27),
	vec_2(914.37, 128.58),
	vec_2(910.72, 122.43),
	vec_2(907.46, 115.71),
	vec_2(904.64, 108.99),
	vec_2(902.14, 102.27),
	vec_2(899.71, 95.42),
	vec_2(897.54, 88.77),
	vec_2(895.49, 81.98),
	vec_2(893.38, 75.52),
	vec_2(891.26, 68.99),
	vec_2(889.09, 62.46),
	vec_2(886.98, 56),
	vec_2(884.61, 49.6),
	vec_2(882.05, 43.14),
	vec_2(879.1, 36.8),
	vec_2(875.84, 30.72),
	vec_2(872, 24.7),
	vec_2(867.78, 19.33),
	vec_2(862.98, 14.21),
	vec_2(857.54, 9.79),
	vec_2(851.46, 6.02),
	vec_2(845.38, 2.56),
	vec_2(839.36, -1.28),
	vec_2(833.47, -5.25),
	vec_2(827.78, -9.28),
	vec_2(822.4, -13.95)
}, {
	vec_2(687.1, -12.1),
	vec_2(685.76, -5.12),
	vec_2(684.22, 1.79),
	vec_2(682.5, 8.64),
	vec_2(680.7, 15.42),
	vec_2(678.72, 22.08),
	vec_2(676.61, 28.67),
	vec_2(674.3, 35.26),
	vec_2(671.81, 41.86),
	vec_2(669.18, 48.26),
	vec_2(666.11, 54.66),
	vec_2(663.17, 60.8),
	vec_2(659.78, 66.75),
	vec_2(656.32, 72.45),
	vec_2(652.42, 78.08),
	vec_2(648.13, 83.33),
	vec_2(643.33, 88.19),
	vec_2(637.95, 92.67),
	vec_2(631.94, 96.13),
	vec_2(625.41, 98.5),
	vec_2(618.43, 99.58),
	vec_2(611.52, 99.52),
	vec_2(604.48, 99.26),
	vec_2(597.5, 98.69),
	vec_2(590.53, 97.66),
	vec_2(583.62, 96.26),
	vec_2(576.83, 94.46),
	vec_2(570.11, 92.35),
	vec_2(563.46, 89.79),
	vec_2(556.99, 86.91),
	vec_2(550.66, 83.9),
	vec_2(544.38, 80.64),
	vec_2(538.43, 77.12),
	vec_2(532.48, 73.79),
	vec_2(526.59, 70.34),
	vec_2(520.58, 67.07),
	vec_2(514.24, 64.06),
	vec_2(507.9, 61.44),
	vec_2(501.31, 59.52),
	vec_2(494.34, 58.43),
	vec_2(487.36, 59.01),
	vec_2(480.64, 61.12),
	vec_2(474.5, 64.58),
	vec_2(468.61, 68.8),
	vec_2(463.3, 73.66),
	vec_2(458.18, 78.78),
	vec_2(453.25, 83.97),
	vec_2(448.51, 89.09),
	vec_2(443.9, 94.02),
	vec_2(439.04, 98.82),
	vec_2(433.92, 103.49),
	vec_2(428.42, 107.71),
	vec_2(422.53, 111.3),
	vec_2(416.06, 113.66),
	vec_2(409.15, 114.82),
	vec_2(402.18, 113.98),
	vec_2(395.39, 111.3),
	vec_2(389.38, 107.33),
	vec_2(383.94, 102.53),
	vec_2(379.01, 97.34),
	vec_2(374.4, 91.84),
	vec_2(370.18, 86.14),
	vec_2(366.14, 80.26),
	vec_2(362.37, 74.24),
	vec_2(358.66, 68.1),
	vec_2(355.14, 62.08),
	vec_2(351.87, 55.94),
	vec_2(348.42, 50.05),
	vec_2(345.09, 44.1),
	vec_2(341.82, 38.08),
	vec_2(338.24, 32.13),
	vec_2(333.95, 26.24),
	vec_2(329.28, 20.8),
	vec_2(324.29, 15.74),
	vec_2(319.1, 10.69),
	vec_2(313.6, 6.08),
	vec_2(307.97, 1.73),
	vec_2(302.34, -2.37),
	vec_2(296.45, -6.27),
	vec_2(290.56, -10.11),
	vec_2(284.54, -13.76)
}, {
	vec_2(-12.86, 155.9),
	vec_2(-5.76, 157.18),
	vec_2(1.34, 158.66),
	vec_2(8.19, 160.26),
	vec_2(15.17, 161.98),
	vec_2(22.02, 163.84),
	vec_2(28.67, 165.89),
	vec_2(35.2, 168.06),
	vec_2(41.73, 170.43),
	vec_2(48.13, 173.06),
	vec_2(54.46, 176),
	vec_2(60.54, 179.26),
	vec_2(66.62, 182.91),
	vec_2(72.26, 187.01),
	vec_2(77.63, 191.62),
	vec_2(82.3, 196.86),
	vec_2(85.95, 202.69),
	vec_2(88, 209.47),
	vec_2(87.55, 216.58),
	vec_2(84.93, 223.3),
	vec_2(81.15, 229.44),
	vec_2(76.74, 235.2),
	vec_2(72.13, 240.77),
	vec_2(67.46, 246.4),
	vec_2(63.17, 251.97),
	vec_2(59.71, 257.98),
	vec_2(57.02, 264.45),
	vec_2(56.06, 271.55),
	vec_2(56.38, 278.66),
	vec_2(57.73, 285.7),
	vec_2(59.78, 292.8),
	vec_2(62.14, 299.78),
	vec_2(64.58, 306.5),
	vec_2(66.94, 313.15),
	vec_2(69.31, 319.68),
	vec_2(71.42, 326.27),
	vec_2(73.34, 332.99),
	vec_2(74.75, 339.9),
	vec_2(75.52, 346.82),
	vec_2(75.39, 353.86),
	vec_2(74.05, 360.83),
	vec_2(71.04, 367.23),
	vec_2(66.37, 372.61),
	vec_2(60.03, 376.26),
	vec_2(52.93, 378.62),
	vec_2(46.21, 380.93),
	vec_2(39.55, 383.42),
	vec_2(33.22, 386.37),
	vec_2(26.82, 389.44),
	vec_2(20.67, 392.9),
	vec_2(14.72, 396.61),
	vec_2(9.09, 400.7),
	vec_2(3.71, 405.25),
	vec_2(-1.28, 410.24),
	vec_2(-5.82, 415.68),
	vec_2(-11.46, 420.54)
}}

for i, b in ipairs(bat_paths) do
	--#endregion
	--#region decal_bat_flying_" .. i, "decal_bat_flying
	tt = RT("decal_bat_flying_" .. i, "decal_bat_flying")

	local keys = {}
	local t = 0

	for _, p in pairs(b) do
		table.insert(keys, {t, p})

		t = t + bat_speed_per_node
	end

	tt.tween.props[1].keys = keys
	tt.delayed_play.play_duration = t
end

--#endregion
--#region decal_s24_nevermore
tt = RT("decal_s24_nevermore", "decal_click_play")

AC(tt, "tween")

tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].scale = vec_2(0.7, 0.7)
tt.render.sprites[1].prefix = "decal_s24_nevermore"
tt.render.sprites[1].z = Z_OBJECTS
tt.leave_time = 2
tt.main_script.update = scripts.decal_s24_nevermore.update
tt.sound = "ExtraBlackburnCrow"
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -10
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{fts(0), vec_2(0, 0)}, {fts(60), vec_2(334, 44)}}
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.y = -26
--#endregion
--#region decal_blackburn_weed
tt = RT("decal_blackburn_weed", "decal_loop")
tt.render.sprites[1].random_ts = fts(34)
tt.render.sprites[1].name = "decal_blackburn_weed_idle"
--#endregion
--#region decal_blackburn_waves
tt = RT("decal_blackburn_waves", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_waves_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_waves_jump"
--#endregion
--#region decal_blackburn_bubble
tt = RT("decal_blackburn_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_bubble_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_bubble_jump"
--#endregion
--#region decal_blackburn_smoke
tt = RT("decal_blackburn_smoke", "decal_loop")
tt.render.sprites[1].random_ts = fts(21)
tt.render.sprites[1].name = "decal_blackburn_smoke_jump"
--#endregion
--#region decal_s25_nessie
tt = RT("decal_s25_nessie", "decal_click_play")
tt.render.sprites[1].anchor = vec_2(0.5, 0.43478260869565216)
tt.render.sprites[1].prefix = "decal_s25_nessie"
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_s25_nessie.update
tt.out_pos = {vec_2(555, 600), vec_2(131, 530), vec_2(415, 450)}
tt.animation_duration = {3, 4}
tt.pause_duration = {7, 10}
tt.sound = "ExtraBlackburnNessie"
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos = vec_2(-22, 2)
tt.ui.click_rect.size = vec_2(30, 20)
--#endregion
--#region decal_s26_cage
tt = RT("decal_s26_cage", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s26_cage"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 6
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "play"
--#endregion
--#region decal_s26_hangmen
tt = RT("decal_s26_hangmen", "decal_s26_cage")
tt.render.sprites[1].prefix = "decal_s26_hangmen"
--#endregion
--#region decal_endless_burner
tt = RT("decal_endless_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
--#endregion

--#region tower_archer_hammerhold
tt = RT("tower_archer_hammerhold", "tower")

AC(tt, "attacks")

tt.tower.type = "archer_hammerhold"
tt.tower.level = 1
tt.tower.price = 0
tt.info.portrait = "kr2_info_portraits_towers_0019"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_%04i"
tt.render.sprites[1].offset = vec_2(0, 12)
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "city_tower"
tt.render.sprites[2].offset = vec_2(0, 28)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "shooterarcherhammerhold"
tt.render.sprites[3].name = "idleDown"
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.idle = {"idleUp", "idleDown"}
tt.render.sprites[3].angles.shoot = {"shootingUp", "shootingDown"}
tt.render.sprites[3].offset = vec_2(0, 59)
tt.main_script.insert = scripts.tower_archer.insert
tt.main_script.update = scripts.tower_archer.update
tt.main_script.remove = scripts.tower_archer.remove
tt.attacks.range = 166.4
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "arrow_hammerhold"
tt.attacks.list[1].cooldown = 0.7
tt.attacks.list[1].shoot_time = fts(5)
tt.attacks.list[1].bullet_start_offset = {vec_2(0, 50)}
--#endregion
--#region arrow_hammerhold
tt = RT("arrow_hammerhold", "arrow")
tt.bullet.damage_min = 5
tt.bullet.damage_max = 10
--#endregion
--#region decal_tusken
tt = RT("decal_tusken", "decal_scripted")

AC(tt, "bullet_attack")

tt.render.sprites[1].prefix = "decal_tusken"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_tusken.update
tt.bullet_attack.max_range = 350
tt.bullet_attack.bullet = "bullet_tusken"
tt.bullet_attack.shoot_time = fts(2)
tt.bullet_attack.cooldown_min = 10
tt.bullet_attack.cooldown_max = 20
tt.bullet_attack.bullet_start_offset = vec_2(3, 7)
--#endregion
--#region bullet_tusken
tt = RT("bullet_tusken", "shotgun")
tt.bullet.damage_min = 100
tt.bullet.damage_max = 200
tt.bullet.min_speed = 40 * FPS
tt.bullet.max_speed = 40 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"
--#endregion
--#region sand_worm
tt = RT("sand_worm", "decal_scripted")

AC(tt, "area_attack")

tt.render.sprites[1].prefix = "sand_worm"
tt.render.sprites[1].name = "attack"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].draw_order = 2
tt.main_script.update = scripts.sand_worm.update
tt.area_attack.animation = "attack"
tt.area_attack.cooldown = 90
tt.area_attack.max_range = 64
tt.area_attack.max_count = 30
tt.area_attack.hit_time = 6
tt.area_attack.damage_type = DAMAGE_EAT
tt.area_attack.vis_flags = bor(F_EAT)
tt.area_attack.vis_bans = bor(F_FLYING)
--#endregion
--#region fx_sand_worm_incoming
tt = RT("fx_sand_worm_incoming", "decal_tween")
tt.render.sprites[1].anchor.y = 0.44
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "sand_worm_incoming"
tt.tween.props[1].keys = {{0, 0}, {0.6, 255}}
tt.tween.remove = false
--#endregion
--#region fx_sand_worm_out
tt = RT("fx_sand_worm_out", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "sandworm_decal_out"
tt.tween.props[1].keys = {{1, 255}, {3.5, 0}}
--#endregion
--#region decal_palm_tree
tt = RT("decal_palm_tree", "decal_timed")
tt.timed.disabled = true
tt.render.sprites[1].prefix = "decal_palm_tree"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -40
--#endregion
--#region decal_palm_land
tt = RT("decal_palm_land", "decal_tween")
tt.pos = vec_2(REF_W * 0.5, REF_H * 0.5)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.4, 0}}
tt.tween.remove = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
--#endregion
--#region decal_lumberjack
tt = RT("decal_lumberjack", "decal")
tt.render.sprites[1].prefix = "lumberjack"
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region decal_ship_door
tt = RT("decal_ship_door", "decal")
tt.render.sprites[1].prefix = "decal_ship_door"
tt.render.sprites[1].name = "closed"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
--#endregion
--#region pirate_cannons
tt = RT("pirate_cannons", "decal_scripted")

AC(tt, "attacks")

tt.main_script.update = scripts.pirate_cannons.update
tt.render.sprites[1].prefix = "pirate_cannon_left"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "pirate_cannon_right"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2].offset = vec_2(169, -65)
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].min_range = 100
tt.attacks.list[1].max_range = 600
tt.attacks.list[1].min_cooldown = 40
tt.attacks.list[1].max_cooldown = 60
tt.attacks.list[1].shoot_time = fts(29)
tt.attacks.list[1].max_error = 20
tt.attacks.list[1].min_error = 5
--#endregion
--#region decal_pirate_cannon_target
tt = RT("decal_pirate_cannon_target", "decal_tween")
tt.render.sprites[1].name = "Stage4_ShipCrosshair"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1.86, 1.86)}, {fts(20), vec_2(1.05, 1.05)}, {fts(23), vec_2(0.95, 0.95)}, {fts(26), vec_2(1.05, 1.05)}, {fts(28), vec_2(1, 1)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {fts(20), 255}, {fts(74), 255}, {fts(78), 0}}
--#endregion
--#region bomb_pirate_cannon
tt = RT("bomb_pirate_cannon", "bullet")
tt.render = nil
tt.main_script.update = scripts.bomb_pirate_cannon.update
tt.bullet.damage_min = 50
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 67.2
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_explosion_small"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.sound_events.hit = "BombExplosionSound"
--#endregion
--#region decal_efreeti_tent
tt = RT("decal_efreeti_tent", "decal")
tt.render.sprites[1].name = "boss_corps_efreeti"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_efreeti_door
tt = RT("decal_efreeti_door", "decal_scripted")
tt.main_script.update = scripts.decal_efreeti_door.update
tt.smoke_positions = {vec_2(521, 674), vec_2(618, 642)}
tt.stone_positions = {{vec_2(599, 664), 1, false}, {vec_2(688, 592), 0.8, false}, {vec_2(479, 647), 0.8, false}, {vec_2(519, 682), 1, true}, {vec_2(625, 608), 0.8, true}, {vec_2(416, 663), 0.8, true}}
tt.render.sprites[1].prefix = "efreeti_door_floor"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "efreeti_door"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].loop = false
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "Stage06_0003"
tt.render.sprites[3].animated = false
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].prefix = "efreeti_statue"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].offset = vec_2(-139, -66)
tt.render.sprites[4].anchor.y = 0.08
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].prefix = "efreeti_statue"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].offset = vec_2(72, -120)
tt.render.sprites[5].anchor.y = 0.08
tt.render.sprites[6] = CC("sprite")
tt.render.sprites[6].name = "efreeti_door_eyes"
tt.render.sprites[6].offset = vec_2(-51, -55)
tt.render.sprites[6].hidden = true
tt.render.sprites[6].loop = false
tt.render.sprites[7] = CC("sprite")
tt.render.sprites[7].name = "efreeti_door_eyes_effect"
tt.render.sprites[7].offset = vec_2(-51, -55)
tt.render.sprites[7].hidden = true
tt.render.sprites[7].loop = false
--#endregion
--#region decal_efreeti_door_broken
tt = RT("decal_efreeti_door_broken", "decal")
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "efreeti_statue_left"
tt.render.sprites[1].offset = vec_2(-139, -66)
tt.render.sprites[1].anchor.y = 0.08
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "efreeti_statue_right"
tt.render.sprites[2].offset = vec_2(72, -120)
tt.render.sprites[2].anchor.y = 0.08
--#endregion
--#region decal_lumberjack_shaman
tt = RT("decal_lumberjack_shaman", "decal")
tt.render.sprites[1].prefix = "lumberjack_shaman"
tt.render.sprites[1].anchor.y = 0.18
--#endregion
--#region background_sounds_jungle
tt = RT("background_sounds_jungle", "background_sounds")
tt.min_delay = 20
tt.max_delay = 25
tt.sounds = {"JungleAmbienceSound"}
--#endregion
--#region background_sounds_underground
tt = RT("background_sounds_underground", "background_sounds")
tt.min_delay = 15
tt.max_delay = 20
tt.sounds = {"UndergroundAmbienceSound"}
--#endregion
--#region tower_holder_blocked
tt = RT("tower_holder_blocked")
AC(tt, "tower", "tower_holder", "pos", "render", "ui", "sound_events")
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower_holder.blocked = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "build_terrain_blocked_%04i"
tt.render.sprites[1].offset = vec_2(0, 17)
tt.render.sprites[1].z = Z_DECALS
tt.ui.click_rect = r(-40, -12, 80, 46)
tt.sound_events.remove = "GUITowerSell"
--#endregion

tt = RT("tower_holder_blocked_2", "tower_holder_blocked")
AC(tt, "editor")
--#region tower_holder_blocked_jungle
tt = RT("tower_holder_blocked_jungle", "tower_holder_blocked")
tt.tower.type = "holder_blocked_jungle"
tt.tower_holder.unblock_price = 100
--#endregion
--#region tower_holder_blocked_underground
tt = RT("tower_holder_blocked_underground", "tower_holder_blocked")
tt.tower.type = "holder_blocked_underground"
tt.tower_holder.unblock_price = 200
--#endregion

tt = E:register_t("tower_holder_blocked_sea_of_trees", "tower_holder_blocked_2")
b = balance.specials.trees.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0001_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0001_flag_blocked"
--tt.render.sprites[2].hidden = false
tt = E:register_t("tower_holder_blocked_sea_of_trees_2", "tower_holder_blocked_2")
b = balance.specials.trees.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0003_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0003_flag_blocked"
--tt.render.sprites[2].hidden = false
tt = E:register_t("tower_holder_blocked_terrain_2", "tower_holder_blocked_2")
b = balance.specials.terrain_2.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0004_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0004_flag_blocked"
--tt.render.sprites[2].hidden = false
tt = E:register_t("tower_holder_blocked_terrain_3", "tower_holder_blocked_2")
b = balance.specials.terrain_3.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0005_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0005_flag_blocked"
--tt.render.sprites[2].hidden = false
tt = E:register_t("tower_holder_blocked_terrain_4", "tower_holder_blocked_2")
b = balance.specials.trees.blocked_holders
-- E:add_comps(tt, "main_script")
-- tt.main_script.remove = scripts.tower_holder_animated.remove
tt.tower.type = "holder_blocked_halloween"
tt.tower_holder.unblock_price = b.price
-- tt.tower_holder.unblock_fx = "fx_tower_holder_unblock_terrain_4"
-- tt.render.sprites[1].name = "terrains_holders_0006_blocked"
-- tt.render.sprites[2].name = "UpdateHalloween_terrain_anim_0001"

tt = E:register_t("tower_holder_blocked_terrain_6", "tower_holder_blocked_2")
b = balance.specials.terrain_6.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0008_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0008_flag_blocked"
tt = E:register_t("tower_holder_blocked_terrain_6_2", "tower_holder_blocked_2")
b = balance.specials.terrain_6.blocked_holders
tt.tower.type = "holder_blocked_sea_of_trees"
tt.tower_holder.unblock_price = b.price
-- tt.render.sprites[1].name = "terrains_holders_0009_blocked"
-- tt.render.sprites[2].name = "terrains_holders_0009_flag_blocked"
--#region carnivorous_plant
tt = RT("carnivorous_plant", "decal_scripted")

AC(tt, "area_attack")

tt.main_script.update = scripts.carnivorous_plant.update
tt.render.sprites[1].prefix = "carnivorous_plant"
tt.render.sprites[1].name = "inactive"
tt.render.sprites[1].anchor.y = 0.41
tt.activates_on_wave = 1
tt.attack_pos = nil
tt.area_attack.cooldown = 40
tt.area_attack.damage_radius = 55
tt.area_attack.hit_time = fts(10)
tt.area_attack.vis_flags = F_EAT
tt.area_attack.damage_type = DAMAGE_EAT
--#endregion
--#region enemy_cannibal_volcano
tt = RT("enemy_cannibal_volcano", "enemy")

AC(tt, "melee", "tween")

anchor_y = 0.15
image_y = 100
tt.info.portrait = "kr2_info_portraits_enemies_0027"
tt.enemy.gold = 10
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 400
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(70))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_cannibal_volcano.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.067 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_cannibal_volcano"
tt.sound_events.scream = "SpecialVolcanoVirginScream"
tt.sound_events.throw = "SpecialVolcanoThrowSplash"
tt.tween.props[1].keys = {{0, vec_2(0.65, 0.65)}, {0.2, vec_2(1, 1)}}
tt.tween.props[1].name = "scale"
tt.tween.remove = false
tt.tween.run_once = true
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(16))
tt.unit.mod_offset = vec_2(0, ady(36))
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MOCKING)
tt.vis.bans = bor(F_SKELETON, F_UNDEAD)
--#endregion
--#region decal_volcano_virgin
tt = RT("decal_volcano_virgin", "decal_scripted")

AC(tt, "motion")

tt.render.sprites[1].prefix = "volcano_virgin"
tt.render.sprites[1].name = "heart"
tt.render.sprites[1].anchor.y = 0.15
tt.motion.max_speed = 1 * FPS
tt.main_script.update = scripts.decal_volcano_virgin.update
--#endregion
--#region bomb_volcano
tt = RT("bomb_volcano", "bullet")
tt.bullet.damage_max = 160
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.particles_name = "ps_bomb_volcano"
tt.bullet.pop = {"pop_kboom"}
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time_base = fts(35)
tt.bullet.flight_time_factor = fts(0.06666666666666667)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Stage9_lavaShot"
tt.sound_events.insert = "SpecialVolcanoLavaShoot"
tt.sound_events.hit = "SpecialVolcanoLavaShootHit"
tt.sound_events.remove = "BombExplosionSound"
--#endregion
--#region decal_volcano_bubble
tt = RT("decal_volcano_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "bubble"
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "bubble"
--#endregion
--#region decal_volcano_smoke
tt = RT("decal_volcano_smoke", "decal_delayed_play")
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "smoke"
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "smoke"
--#endregion
--#region decal_bouncing_bridge
tt = RT("decal_bouncing_bridge", "decal_scripted")
tt.main_script.update = scripts.decal_bouncing_bridge.update
tt.render.sprites[1].prefix = "decal_bouncing_bridge"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "Stage6_Bridge_Front_Pillars"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y = 495
tt.bridge_width = 160
--#endregion
--#region decal_monkey_corps_1
tt = RT("decal_monkey_corps_1", "decal_tween")
tt.render.sprites[1].name = "decal_monkey_corps_1"
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "flip_x"
tt.tween.props[1].keys = {{0, false}, {3, true}, {6, false}}
--#endregion
--#region decal_monkey_corps_2
tt = RT("decal_monkey_corps_2", "decal")
tt.render.sprites[1].name = "decal_monkey_corps_2"
--#endregion
--#region decal_monkey_corps_3
tt = RT("decal_monkey_corps_3", "decal_delayed_sequence")
tt.render.sprites[1].prefix = "decal_monkey_corps_3"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = nil
tt.delayed_sequence.animations = {"jump", "jump", "jump", "idle"}
tt.delayed_sequence.min_delay = 0
tt.delayed_sequence.max_delay = 1
--#endregion
--#region indiana_puzzle_button_a
tt = RT("indiana_puzzle_button_a", "decal")

AC(tt, "ui")

tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "indiana_puzzle_button_a"
tt.render.sprites[1].z = Z_DECALS + 6
tt.ui.can_click = false
tt.ui.click_rect = r(-22, -22, 44, 44)
tt.puzzle_value = 1
--#endregion
--#region indiana_puzzle_button_b
tt = RT("indiana_puzzle_button_b", "indiana_puzzle_button_a")
tt.render.sprites[1].prefix = "indiana_puzzle_button_b"
tt.puzzle_value = 2
--#endregion
--#region indiana_puzzle_button_c
tt = RT("indiana_puzzle_button_c", "indiana_puzzle_button_a")
tt.render.sprites[1].prefix = "indiana_puzzle_button_c"
tt.puzzle_value = 3
--#endregion
--#region decal_indiana
tt = RT("decal_indiana", "decal_tween")
tt.render.sprites[1].prefix = "decal_indiana"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 4
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
--#endregion
--#region decal_indiana_question_marks
tt = RT("decal_indiana_question_marks", "decal_timed")
tt.render.sprites[1].name = "decal_indiana_question_marks"
tt.timed.runs = 5
--#endregion
--#region decal_indiana_boulder
tt = RT("decal_indiana_boulder", "decal_scripted")

AC(tt, "motion")

tt.render.sprites[1].name = "decal_indiana_boulder"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS + 4
tt.motion.max_speed = 3.9 * FPS
tt.main_script.update = scripts.decal_indiana_boulder.update
--#endregion
--#region decal_black_dragon
tt = RT("decal_black_dragon", "decal_scripted")

AC(tt, "motion", "attacks", "tween", "ui", "sound_events")

tt.main_script.update = scripts.decal_black_dragon.update
tt.motion.max_speed = 12 * FPS
tt.attacks.list[1] = CC("mod_attack")
tt.attacks.list[1].mod = "mod_black_dragon"
tt.attacks.list[1].cooldown = 0.2
tt.attacks.list[1].range = 30
tt.render.sprites[1].prefix = "decal_black_dragon"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_black_dragon"
tt.render.sprites[2].name = "zzz"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loope = false
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "Stage12_Dragon_Shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = -1
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "black_dragon_flame_hit"
tt.render.sprites[4].hidden = true
tt.render.sprites[4].offset = vec_2(105, 10)
tt.sound_events.wakeup = "SpecialBlackDragonTaunt"
tt.sound_events.fire = "SpecialBlackDragonFire"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {fts(8), 0}}
tt.tween.props[1].sprite_id = 2
tt.ui.can_click = true
tt.ui.click_rect = r(-50, 30, 110, 90)
tt.wakeup_cooldown_min = 5
tt.wakeup_cooldown_max = 16
tt.sleep_pos = vec_2(610, 579)
tt.speed_fly = 12 * FPS
tt.speed_takeoff = 5 * FPS
--#endregion
--#region fx_black_dragon_flame_hit
tt = RT("fx_black_dragon_flame_hit", "decal_tween")
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "black_dragon_flame_hit"
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {0.3, 0}}
--#endregion
--#region ps_black_dragon_flame
tt = RT("ps_black_dragon_flame")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 20
tt.particle_system.emit_direction = -math.pi / 5
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.emit_spread = math.pi / 24
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {24 * FPS, 22 * FPS}
tt.particle_system.loop = false
tt.particle_system.name = "black_dragon_flame"
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt.particle_system.scale_same_aspect = true
--#endregion
--#region ps_black_dragon_fire
tt = RT("ps_black_dragon_fire")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 255, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 15
tt.particle_system.emit_area_spread = vec_2(4, 15)
tt.particle_system.emit_rotation = 0
tt.particle_system.loop = false
tt.particle_system.name = "black_dragon_fire"
tt.particle_system.particle_lifetime = {fts(20), fts(25)}
tt.particle_system.scale_same_aspect = true
tt.particle_system.anchor = vec_2(0.5, 0.25)
--#endregion
--#region mod_black_dragon
tt = RT("mod_black_dragon", "modifier")

AC(tt, "render")

tt.modifier.duration = 7
tt.main_script.update = scripts.mod_tower_block.update
tt.render.sprites[1].prefix = "black_dragon_tower_fire"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region button_steal_dragon_gold
tt = RT("button_steal_dragon_gold")

AC(tt, "pos", "main_script", "ui")

tt.main_script.update = scripts.button_steal_dragon_gold.update
tt.ui.can_click = true
tt.ui.click_rect = r(0, 0, 88, 67)
tt.gold_to_steal = 100
tt.fx = "fx_coin_jump"

local decal_whale = RT("decal_whale", "decal_scripted")

AC(decal_whale, "nav_path")

decal_whale.path_origin_offset = vec_2(36, 36)
decal_whale.main_script.insert = scripts.decal_whale.insert
decal_whale.main_script.update = scripts.decal_whale.update

for i = 1, 3 do
	decal_whale.render.sprites[i] = CC("sprite")
	decal_whale.render.sprites[i].prefix = "decal_whale_l" .. i
	decal_whale.render.sprites[i].name = "show"
	decal_whale.render.sprites[i].hidden = true
end

decal_whale.render.sprites[4] = CC("sprite")
decal_whale.render.sprites[4].name = "Cachalote_layer1_0090"
decal_whale.render.sprites[4].animated = false
decal_whale.render.sprites[4].hidden = true
decal_whale.render.sprites[4].sort_y_offset = -1 * decal_whale.path_origin_offset.y - 2
decal_whale.render.sprites[5] = CC("sprite")
decal_whale.render.sprites[5].prefix = "decal_whale_eye"
decal_whale.render.sprites[5].name = "idle"
decal_whale.render.sprites[5].hidden = true
decal_whale.render.sprites[5].sort_y_offset = -1 * decal_whale.path_origin_offset.y - 3

local fx_whale_incoming = RT("fx_whale_incoming", "decal_tween")

fx_whale_incoming.tween.remove = true
fx_whale_incoming.tween.props[1].name = "alpha"
fx_whale_incoming.tween.props[1].keys = {{0, 0}, {2, 255}, {4, 255}}
fx_whale_incoming.render.sprites[1].name = "fx_whale_incoming"
fx_whale_incoming.render.sprites[1].z = Z_DECALS + 2
fx_whale_incoming.render.sprites[1].loop = true
--#endregion
--#region decal_water_barricade
tt = RT("decal_water_barricade", "decal")
tt.render.sprites[1].prefix = "decal_water_barricade"
tt.render.sprites[1].name = "idle"
--#endregion
--#region ps_bomb_volcano
tt = RT("ps_bomb_volcano")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {200, 0}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {0.4, 0.6}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {0.6, 1.2}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.scales_y = {1, 1.5}
--#endregion
--#region ps_bomb_gunboat
tt = RT("ps_bomb_gunboat", "ps_bomb_volcano")
tt.particle_system.name = "bomb_gunboat_particle"
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.particle_lifetime = {0.15, 0.25}
tt.particle_system.scales_x = {1, 1.7}
tt.particle_system.scales_y = {1, 1.7}
tt.particle_system.scale_var = {0.8, 1.2}
--#endregion
--#region moon_controller
tt = RT("moon_controller", "decal_scripted")

AC(tt, "tween")

tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1
tt.main_script.update = scripts.moon_controller.update
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "moon_base_0004"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 2
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].scale = IS_PHONE and vec_2(1.45, 1.45) or nil
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "moon_base_0001"
tt.render.sprites[2].hidden = false
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "moon_base_0002"
tt.render.sprites[3].hidden = false
tt.render.sprites[3].z = Z_SCREEN_FIXED + 5
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].name = "moon_base_0003"
tt.render.sprites[4].z = Z_SCREEN_FIXED + 5
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 4
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}}
--#endregion
--#region decal_moon_dark
tt = RT("decal_moon_dark", "decal_tween")
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1 + 77 * (IS_PHONE and 1.45 or 1)
tt.render.sprites[1].name = "moon_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 3
tt.render.sprites[1].anchor.x = 3.6666666666666665
tt.render.sprites[1].scale = IS_PHONE and vec_2(1.45, 1.45) or nil
tt.tween.props[1].name = "r"
tt.tween.props[1].keys = {{0, math.pi / 5}, {0, math.pi * 0.5}}
tt.tween.disabled = true
tt.tween.remove = false
--#endregion
--#region decal_moon_light
tt = RT("decal_moon_light", "decal_tween")
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1 + 77 * (IS_PHONE and 1.45 or 1)
tt.render.sprites[1].name = "moon_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 4
tt.render.sprites[1].r = math.pi * 0.5
tt.render.sprites[1].anchor.x = 3.6666666666666665
tt.render.sprites[1].scale = IS_PHONE and vec_2(1.45, 1.45) or nil
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "moon_0003"
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {0.5, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.25, 0}, {0.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
--#endregion
--#region decal_moon_overlay
tt = RT("decal_moon_overlay", "decal_tween")
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H * 0.5
tt.render.sprites[1].name = "moon_overlay"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(REF_H * MAX_SCREEN_ASPECT * 1.5 / 64, REF_H * 1.5 / 64)
tt.render.sprites[1].z = Z_SCREEN_FIXED + 1
tt.tween.props[1].keys = {{0, 0}, {0.5, 44}}
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
--#endregion
--#region moon_enemy_aura
tt = RT("moon_enemy_aura", "aura")
tt.main_script.update = scripts.moon_enemy_aura.update
--#endregion
--#region points_spawner
tt = RT("points_spawner")

AC(tt, "main_script")

tt.main_script.update = scripts.points_spawner.update
tt.manual_wave = nil
tt.interrupt = false
--#endregion
--#region decal_moon_activated
tt = RT("decal_moon_activated", "decal_scripted")

AC(tt, "tween")

tt.main_script.update = scripts.decal_moon_activated.update
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
--#endregion
--#region decal_taunting_dracula
tt = RT("decal_taunting_dracula", "decal_scripted")
tt.main_script.update = scripts.decal_taunting_dracula.update
tt.render.sprites[1].prefix = "decal_taunting_dracula"
tt.render.sprites[1].name = "show"
tt.render.sprites[1].anchor.y = 0.1375
tt.render.sprites[1].sort_y = 557
tt.taunt = {}
tt.taunt.cooldown = {50, 70}
tt.taunt.min_cooldown = 10
tt.taunt.format_welcome = "DRACULA_TAUNT_WELCOME_%04d"
tt.taunt.format_moon = "DRACULA_TAUNT_MOON_%04d"
tt.taunt.format_generic = "DRACULA_TAUNT_GENERIC_%04d"
tt.taunt.idx_welcome = {1, 2}
tt.taunt.idx_moon = {1, 4}
tt.taunt.idx_generic = {1, 12}
tt.taunt.duration = 4
tt.taunt.shoutbox = "decal_dracula_shoutbox"
tt.taunt.dracula_positions = {vec_2(328, 615), vec_2(708, 615)}
tt.taunt.taunt_positions = {vec_2(327, 558), vec_2(707, 558)}
tt.taunt.ts = 0
tt.taunt.showing = nil
--#endregion
--#region decal_dracula_shoutbox
tt = RT("decal_dracula_shoutbox", "decal_tween")

AC(tt, "texts", "timed")

tt.render.sprites[1].name = "HalloweenBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, -9)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(172, 62)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {255, 114, 114}
tt.texts.list[1].line_height = i18n:cjk(0.8, nil, 1.1, 0.7)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
--#endregion
--#region decal_moria_gate
tt = RT("decal_moria_gate", "decal_scripted")

AC(tt, "tween", "ui")

tt.render.sprites[1].name = "moria_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 100
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "moria_0002"
tt.render.sprites[2].animated = false
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].anchor.y = 0
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 0}, {0.6, 255}, {0.9, 150}}
tt.main_script.update = scripts.click_run_tween.update
tt.ui.click_rect = r(-25, 0, 50, 80)
--#endregion
--#region decal_stage22_reptile
tt = RT("decal_stage22_reptile", "decal_scripted")

AC(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_stage22_reptile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.6935483870967742, 0.05555555555555555)
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.main_script.update = scripts.decal_stage22_reptile.update
tt.climb_distance = 140
tt.motion.max_speed = 2 * FPS
--#endregion
--#region pop_mage
tt = RT("pop_mage", "pop")
tt.render.sprites[1].name = "elven_pops_0001"
--#endregion
--#region pop_archer
tt = RT("pop_archer", "pop")
tt.render.sprites[1].name = "elven_pops_0002"
--#endregion
--#region pop_barrack1
tt = RT("pop_barrack1", "pop")
tt.render.sprites[1].name = "elven_pops_0003"
--#endregion
--#region pop_barrack2
tt = RT("pop_barrack2", "pop")
tt.render.sprites[1].name = "elven_pops_0004"
--#endregion
--#region pop_artillery
tt = RT("pop_artillery", "pop")
tt.render.sprites[1].name = "elven_pops_0005"
--#endregion
--#region pop_wild_mage
tt = RT("pop_wild_mage", "pop")
tt.render.sprites[1].name = "elven_pops_0006"
--#endregion
--#region pop_high_elven
tt = RT("pop_high_elven", "pop")
tt.render.sprites[1].name = "elven_pops_0007"
--#endregion
--#region pop_ewoks
tt = RT("pop_ewoks", "pop")
tt.render.sprites[1].name = "elven_pops_0008"
--#endregion
--#region pop_arcane
tt = RT("pop_arcane", "pop")
tt.render.sprites[1].name = "elven_pops_0009"
--#endregion
--#region pop_golden
tt = RT("pop_golden", "pop")
tt.render.sprites[1].name = "elven_pops_0010"
--#endregion
--#region pop_death
tt = RT("pop_death", "pop")
tt.render.sprites[1].name = "elven_pops_0011"
--#endregion
--#region pop_faerie_spell
tt = RT("pop_faerie_spell", "pop")
tt.render.sprites[1].name = "elven_pops_0012"
--#endregion
--#region pop_faerie_steal
tt = RT("pop_faerie_steal", "pop")
tt.render.sprites[1].name = "elven_pops_0013"
--#endregion
--#region pop_bladesinger
tt = RT("pop_bladesinger", "pop")
tt.render.sprites[1].name = "elven_pops_0014"
--#endregion
--#region pop_forest_keeper
tt = RT("pop_forest_keeper", "pop")
tt.render.sprites[1].name = "elven_pops_0015"
--#endregion
--#region pop_druid_henge
tt = RT("pop_druid_henge", "pop")
tt.render.sprites[1].name = "elven_pops_0016"
--#endregion
--#region pop_entwood
tt = RT("pop_entwood", "pop")
tt.render.sprites[1].name = "elven_pops_0017"
--#endregion
--#region pop_lightning1
tt = RT("pop_lightning1", "pop")
tt.render.sprites[1].name = "elven_pops_0018"
--#endregion
--#region pop_lightning2
tt = RT("pop_lightning2", "pop")
tt.render.sprites[1].name = "elven_pops_0019"
--#endregion
--#region pop_lightning3
tt = RT("pop_lightning3", "pop")
tt.render.sprites[1].name = "elven_pops_0020"
--#endregion
--#region pop_crit_mages
tt = RT("pop_crit_mages", "pop")
tt.render.sprites[1].name = "elven_pops_0023"
--#endregion
--#region pop_crit_wild_magus
tt = RT("pop_crit_wild_magus", "pop")
tt.render.sprites[1].name = "elven_pops_0024"
--#endregion
--#region pop_crit_high_elven
tt = RT("pop_crit_high_elven", "pop")
tt.render.sprites[1].name = "elven_pops_0025"
--#endregion
--#region pop_mactans
tt = RT("pop_mactans", "pop")
tt.render.sprites[1].name = "mactans_pop"
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
--#endregion
--#region ps_arrow_arcane_special
tt = RT("ps_arrow_arcane_special")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "archer_arcane_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {1, 0}
tt.particle_system.emission_rate = 30
--#endregion
--#region ps_bolt_elves_1
tt = RT("ps_bolt_elves_1")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "mage_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {0.8, 0.25}
tt.particle_system.scales_y = {0.8, 0.25}
tt.particle_system.emission_rate = 60
--#endregion
--#region ps_bolt_elves_2
tt = RT("ps_bolt_elves_2", "ps_bolt_elves_1")
tt.particle_system.scales_x = {0.9, 0.25}
tt.particle_system.scales_y = {0.9, 0.25}
--#endregion
--#region ps_bolt_elves_3
tt = RT("ps_bolt_elves_3", "ps_bolt_elves_1")
tt.particle_system.scales_x = {1, 0.25}
tt.particle_system.scales_y = {1, 0.25}
--#endregion
--#region ps_bolt_high_elven
tt = RT("ps_bolt_high_elven", "ps_bolt_elves_1")
tt.particle_system.name = "mage_highElven_proy_particle"
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {1, 0.5}
--#endregion
--#region ps_bolt_wild_magus
tt = RT("ps_bolt_wild_magus")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "mage_wild_proy_particle"
tt.particle_system.alphas = {180, 12}
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.emission_rate = 60
--#endregion
--#region ps_high_elven_sentinel
tt = RT("ps_high_elven_sentinel")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "mage_highElven_balls_0020"
tt.particle_system.animated = false
tt.particle_system.alphas = {200, 0}
tt.particle_system.particle_lifetime = {fts(5), fts(5)}
tt.particle_system.scales_y = {0.8, 0.8}
tt.particle_system.scales_x = {0.8, 0.8}
tt.particle_system.emission_rate = 60
tt.particle_system.z = Z_OBJECTS
tt.particle_system.draw_order = 4
tt.particle_system.sort_y = nil
--#endregion
--#region ps_bolt_plant_magic_blossom
tt = RT("ps_bolt_plant_magic_blossom", "ps_bolt_elves_1")
tt.particle_system.name = "plant_magicBlosom_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.scales_y = {1, 0.3}
tt.particle_system.alphas = {190, 120, 0}
--#endregion
--#region ps_shield_elves_denas
tt = RT("ps_shield_elves_denas")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "shield_elves_denas_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 60
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
--#endregion
--#region ps_freeze_arivan
tt = RT("ps_freeze_arivan")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "arivan_freeze_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLETS
--#endregion
--#region ps_fireball_arivan
tt = RT("ps_fireball_arivan")

AC(tt, "pos", "particle_system")

tt.particle_system.names = {"arivan_fireball_particle_1", "arivan_fireball_particle_2"}
tt.particle_system.loop = false
tt.particle_system.cycle_names = true
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
--#endregion
--#region ps_twilight_scourger_banshee
tt = RT("ps_twilight_scourger_banshee")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.emission_rate = 15
tt.particle_system.emit_offset = vec_2(0, 24)
tt.particle_system.loop = false
tt.particle_system.name = "scourger_shadow_particle"
tt.particle_system.particle_lifetime = {fts(20), fts(20)}
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.sort_y_offset = 2
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_nav_faerie_red
tt = RT("ps_nav_faerie_red")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 3
tt.particle_system.anchor.y = 0.28125
tt.particle_system.loop = false
tt.particle_system.name = "nav_faerie_particle_red"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_nav_faerie_yellow
tt = RT("ps_nav_faerie_yellow", "ps_nav_faerie_red")
tt.particle_system.name = "nav_faerie_particle_yellow"
--#endregion
--#region ps_drow_queen_trail
tt = RT("ps_drow_queen_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.anchor.y = 0.35384615384615387
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.emission_rate = 1
tt.particle_system.loop = false
tt.particle_system.names = {"s11_malicia_particle1", "s11_malicia_particle2"}
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region ps_bolt_faustus
tt = RT("ps_bolt_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
--#endregion
--#region ps_bolt_lance_faustus
tt = RT("ps_bolt_lance_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_lance_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 90
tt.particle_system.emit_rotation_spread = math.pi
--#endregion
--#region ps_bullet_liquid_fire_faustus
tt = RT("ps_bullet_liquid_fire_faustus")

AC(tt, "pos", "particle_system")

tt.particle_system.emission_rate = 20
tt.particle_system.emit_duration = fts(10)
tt.particle_system.emit_speed = {250, 250}
tt.particle_system.emit_rotation_spread = math.pi / 4
tt.particle_system.animated = true
tt.particle_system.animation_fps = 18
tt.particle_system.loop = false
tt.particle_system.name = "bullet_liquid_fire_faustus_particle"
tt.particle_system.particle_lifetime = {fts(9), fts(11)}
tt.particle_system.alphas = {255, 255, 50}
tt.particle_system.scales_x = {1, 1, 1.5}
tt.particle_system.scales_y = {1, 1, 1.5}
tt.particle_system.spin = {-math.pi * 0.5, math.pi * 0.5}
tt.particle_system.sort_y_offsets = {-100, 0}
--#endregion
--#region ps_minidragon_faustus_fire
tt = RT("ps_minidragon_faustus_fire", "ps_bullet_liquid_fire_faustus")
tt.particle_system.emit_duration = nil
tt.particle_system.emit_speed = {500, 500}
tt.particle_system.emit_rotation_spread = math.pi / 8
--#endregion
--#region ps_bullet_twilight_evoker
tt = RT("ps_bullet_twilight_evoker")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_evoker_bolt_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.25, 0.25}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
--#endregion
--#region ps_bullet_twilight_heretic
tt = RT("ps_bullet_twilight_heretic")

AC(tt, "pos", "particle_system")

tt.particle_system.names = {"bullet_twilight_heretic_particle_1", "bullet_twilight_heretic_particle_2"}
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 45
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
--#endregion
--#region ps_twilight_heretic_consume_ball_particle
tt = RT("ps_twilight_heretic_consume_ball_particle")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_heretic_consume_ball_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
--#endregion
--#region ps_razorboar_rampage
tt = RT("ps_razorboar_rampage")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "razorboar_rampage_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(9), fts(11)}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = vec_2(16, 6)
tt.particle_system.emit_offset = vec_2(0, 28)
--#endregion
--#region ps_emit_breath_baby_ashbite
tt = RT("ps_emit_breath_baby_ashbite")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_breath_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
--#endregion
--#region ps_emit_fiery_mist_baby_ashbite
tt = RT("ps_emit_fiery_mist_baby_ashbite")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_fierymist_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
--#endregion
--#region ps_dagger_drow
tt = RT("ps_dagger_drow")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dagger_drow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region ps_fireball_veznan_demon
tt = RT("ps_fireball_veznan_demon")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 40}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "veznan_hero_demon_proyParticle"
tt.particle_system.particle_lifetime = {fts(9), fts(11)}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scale_same_aspect = false
tt.particle_system.scale_var = {0.35, 0.8}
--#endregion
--#region ps_veznan_soulburn
tt = RT("ps_veznan_soulburn")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "veznan_hero_soulBurn_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.particle_lifetime = {fts(4), fts(12)}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.scale_var = {0.25, 1}
tt.particle_system.alphas = {255, 0}
--#endregion
--#region ps_bullet_rag_trail
tt = RT("ps_bullet_rag_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "razzAndRaggs_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
--#endregion
--#region ps_durax_transfer
tt = RT("ps_durax_transfer")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "ps_durax_transfer"
tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = vec_2(0, 16)
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.sort_y_offset = 2
--#endregion
--#region ps_durax_clone_transfer
tt = RT("ps_durax_clone_transfer", "ps_durax_transfer")
tt.particle_system.alphas = {150}
--#endregion
--#region ps_bullet_lilith_trail
tt = RT("ps_bullet_lilith_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "fallen_angel_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
--#endregion
--#region ps_missile_phoenix
tt = RT("ps_missile_phoenix")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_missile_phoenix"
tt.particle_system.particle_lifetime = {0.14, 0.18}
tt.particle_system.spin = {-0.3, 0.3}
tt.particle_system.track_rotation = true
--#endregion
--#region ps_missile_phoenix_small
tt = RT("ps_missile_phoenix_small", "ps_missile_phoenix")
tt.particle_system.scale_var = {0.65, 0.65}
tt.particle_system.emit_area_spread = vec_2(2, 2)
--#endregion
--#region ps_missile_wilbur
tt = RT("ps_missile_wilbur")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_wilburg_missile_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {1.6, 1.8}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {1, 3}
tt.particle_system.scales_y = {1, 3}
tt.particle_system.scale_var = {0.4, 0.95}
tt.particle_system.scale_same_aspect = false
tt.particle_system.emit_spread = math.pi
tt.particle_system.emission_rate = 30
--#endregion
--#region ps_bomb_lava_fireball
tt = RT("ps_bomb_lava_fireball")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {200, 0}
tt.particle_system.animated = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "Stage9_lavaShotParticle"
tt.particle_system.particle_lifetime = {0.4, 0.6}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scale_var = {0.6, 1.2}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.scales_y = {1, 1.5}
--#endregion
--#region ps_bullet_balrog
tt = RT("ps_bullet_balrog", "ps_fireball_arivan")
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.animation_fps = 20
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.emission_rate = 60
tt.particle_system.track_rotation = true
--#endregion
--#region ps_bullet_rod_dragon_fire
tt = RT("ps_bullet_rod_dragon_fire")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_rod_dragon_fire_particle"
tt.particle_system.particle_lifetime = {0.3, 0.34}
tt.particle_system.track_rotation = true
--#endregion
--#region fx_teleport_violet
tt = RT("fx_teleport_violet", "fx")
tt.render.sprites[1].name = "fx_teleport_violet"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
--#endregion
--#region fx_teleport_orange
tt = RT("fx_teleport_orange", "fx")
tt.render.sprites[1].name = "fx_teleport_orange"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
--#endregion
--#region fx_teleport_blue
tt = RT("fx_teleport_blue", "fx")
tt.render.sprites[1].name = "fx_teleport_blue"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
--#endregion
--#region fx_bolt_elves_hit
tt = RT("fx_bolt_elves_hit", "fx")
tt.render.sprites[1].name = "bolt_elves_hit"
--#endregion
--#region fx_bolt_high_elven_weak_hit
tt = RT("fx_bolt_high_elven_weak_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_weak_hit"
--#endregion
--#region fx_bolt_high_elven_strong_hit
tt = RT("fx_bolt_high_elven_strong_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_strong_hit"
--#endregion
--#region fx_rock_explosion
tt = RT("fx_rock_explosion", "fx")
tt.render.sprites[1].name = "fx_rock_explosion"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
--#endregion
--#region fx_fiery_nut_explosion
tt = RT("fx_fiery_nut_explosion", "fx")
tt.render.sprites[1].name = "fx_fiery_nut_explosion"
tt.render.sprites[1].anchor.y = 0.19791666666666666
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
--#endregion
--#region fx_rock_druid_launch
tt = RT("fx_rock_druid_launch", "fx")
tt.render.sprites[1].name = "fx_rock_druid_launch"
--#endregion
--#region fx_arrow_arcane_hit
tt = RT("fx_arrow_arcane_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_arcane_hit"
--#endregion
--#region fx_arcane_slumber_explosion
tt = RT("fx_arcane_slumber_explosion", "fx")
tt.render.sprites[1].name = "arcane_slumber_explosion"
tt.render.sprites[1].anchor.y = 0.32051282051282054
--#endregion
--#region fx_soldier_barrack_revive
tt = RT("fx_soldier_barrack_revive", "fx")
tt.render.sprites[1].name = "fx_soldier_barrack_revive"
tt.render.sprites[1].anchor.y = 0.15
--#endregion
--#region fx_arrow_silver_mark_hit
tt = RT("fx_arrow_silver_mark_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_mark_hit"
tt.render.sprites[1].sort_y_offset = -20
--#endregion
--#region fx_arrow_silver_sentence_hit
tt = RT("fx_arrow_silver_sentence_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_arrow_silver_sentence_hit"
tt.sound_events.insert = "TowerGoldenBowInstakill"
--#endregion
--#region fx_arrow_silver_sentence_shot
tt = RT("fx_arrow_silver_sentence_shot", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_sentence_shot"
--#endregion
--#region fx_wild_magus_hit
tt = RT("fx_wild_magus_hit", "fx")
tt.render.sprites[1].name = "bolt_wild_magus_hit"
--#endregion
--#region fx_ray_wild_magus_hit
tt = RT("fx_ray_wild_magus_hit", "fx")
tt.render.sprites[1].name = "fx_ray_wild_magus_hit"
--#endregion
--#region fx_eldritch_explosion
tt = RT("fx_eldritch_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_eldritch_explosion"
tt.render.sprites[1].sort_y_offset = -5
tt.sound_events.insert = "TowerWildMagusDoomExplote"
--#endregion
--#region fx_druid_bear_spawn_rune
tt = RT("fx_druid_bear_spawn_rune", "decal")

AC(tt, "tween")

tt.render.sprites[1].anchor = vec_2(0.48148148148148145, 0.7291666666666666)
tt.render.sprites[1].name = "fx_druid_bear_spawn_rune"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.tween.props[1].keys = {{0, 255}, {fts(9), 255}, {fts(15), 255}, {fts(25), 64}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{fts(0), vec_2(1, 1)}, {fts(9), vec_2(1, 1)}, {fts(11), vec_2(0.77, 0.77)}, {fts(13), vec_2(0.85, 0.85)}, {fts(19), vec_2(0.65, 0.45)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(0, 32)}, {fts(9), vec_2(0, 32)}, {fts(13), vec_2(0, 32)}, {fts(25), vec_2(0, 4)}}
--#endregion
--#region fx_druid_bear_spawn_effect
tt = RT("fx_druid_bear_spawn_effect", "fx")
tt.render.sprites[1].name = "fx_druid_bear_spawn_effect"
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
--#endregion
--#region fx_druid_bear_spawn_decal
tt = RT("fx_druid_bear_spawn_decal", "decal")

AC(tt, "tween")

tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].name = "fx_druid_bear_spawn_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(6), 0}, {fts(7), 255}, {fts(26), 255}, {fts(36), 102}, {fts(41), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{fts(0), vec_2(0.35, 0.35)}, {fts(6), vec_2(0.35, 0.35)}, {fts(10), vec_2(1, 1)}, {fts(16), vec_2(0.8, 0.8)}}
--#endregion
--#region fx_druid_bear_death_rune
tt = RT("fx_druid_bear_death_rune", "fx_druid_bear_spawn_rune")
tt.render.sprites[1].name = "fx_druid_bear_death_rune"
tt.render.sprites[1].time_offset = fts(-38)
tt.render.sprites[1].sort_y_offset = -1
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {{0, vec_2(1, 1)}}
tt.tween.props[3].keys = {{0, vec_2(0, 20)}, {fts(10), vec_2(0, 36)}, {fts(19), vec_2(0, 40)}}
tt.tween.props[3].time_offset = fts(-28)
--#endregion
--#region fx_druid_bear_death_effect
tt = RT("fx_druid_bear_death_effect", "fx_druid_bear_spawn_effect")

AC(tt, "tween")

tt.render.sprites[1].name = "fx_druid_bear_death_effect"
tt.render.sprites[1].time_offset = fts(-28)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(1), 255}}
tt.tween.props[1].time_offset = fts(-28)
--#endregion
--#region fx_druid_bear_death_decal
tt = RT("fx_druid_bear_death_decal", "fx_druid_bear_spawn_decal")
tt.tween.props[1].keys = {{0, 0}, {fts(1), 255}, {fts(4), 255}, {fts(12), 0}}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {{fts(0), vec_2(0.4, 0.35)}, {fts(6), vec_2(0.77, 0.77)}, {fts(10), vec_2(0.86, 0.86)}}
tt.tween.props[2].time_offset = fts(-28)
--#endregion
--#region fx_clobber_smoke
tt = RT("fx_clobber_smoke", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke"
--#endregion
--#region fx_clobber_smoke_ring
tt = RT("fx_clobber_smoke_ring", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke_ring"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_forest_circle
tt = RT("fx_forest_circle", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "forestKeeper_circle1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "forestKeeper_circle1_0001"
tt.render.sprites[2].animated = false
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {fts(2), 255}, {fts(16), 255}, {fts(29), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.2, 0.2)}, {fts(8), vec_2(0.6, 0.6)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {{0, 0}, {fts(20), -math.pi / 4}}
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.deepclone(tt.tween.props[2])
tt.tween.props[5].keys = {{0, vec_2(0.5, 0.5)}, {fts(8), vec_2(1, 1)}}
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[3])
tt.tween.props[6].keys = {{0, 0}, {fts(20), math.pi / 4}}
tt.tween.props[6].sprite_id = 2
--#endregion
--#region fx_spear_forest_oak_hit
tt = RT("fx_spear_forest_oak_hit", "fx")
tt.render.sprites[1].name = "fx_spear_forest_oak_hit"
--#endregion
--#region fx_arrow_soldier_re_hit
tt = RT("fx_arrow_soldier_re_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_soldier_re_hit"
--#endregion
--#region fx_dagger_drow_hit
tt = RT("fx_dagger_drow_hit", "fx")
tt.render.sprites[1].name = "fx_dagger_drow_hit"
--#endregion
--#region fx_faustus_start_attack
tt = RT("fx_faustus_start_attack", "fx")
tt.render.sprites[1].name = "fx_faustus_attack"
tt.render.sprites[1].anchor.y = 0.065
--#endregion
--#region fx_faustus_start_lance
tt = RT("fx_faustus_start_lance", "fx")
tt.render.sprites[1].name = "hero_faustus_rayShoot"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region fx_faustus_start_teleport
tt = RT("fx_faustus_start_teleport", "fx")
tt.render.sprites[1].name = "hero_faustus_teleport"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region fx_faustus_start_enervation
tt = RT("fx_faustus_start_enervation", "fx")
tt.render.sprites[1].name = "hero_faustus_silence"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region fx_faustus_start_liquid_fire
tt = RT("fx_faustus_start_liquid_fire", "fx")
tt.render.sprites[1].name = "fx_faustus_start_liquid_fire"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region fx_bolt_faustus_hit
tt = RT("fx_bolt_faustus_hit", "fx")
tt.render.sprites[1].name = "bolt_faustus_hit"
--#endregion
--#region fx_bolt_lance_faustus_hit
tt = RT("fx_bolt_lance_faustus_hit", "fx")
tt.render.sprites[1].anchor.y = 0.21428571428571427
tt.render.sprites[1].prefix = "fx_bolt_lance_faustus_hit"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
--#endregion
--#region fx_teleport_faustus
tt = RT("fx_teleport_faustus", "fx")
tt.render.sprites[1].name = "fx_teleport_faustus"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1), vec_1(1)}
--#endregion
--#region fx_bullet_liquid_fire_faustus_hit
tt = RT("fx_bullet_liquid_fire_faustus_hit", "decal_tween")
tt.render.sprites[1].name = "fx_bullet_liquid_fire_faustus_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {2, 0}}
--#endregion
--#region fx_bravebark_teleport_out
tt = RT("fx_bravebark_teleport_out", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "bravebark_teleportOutFx"
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "bravebark_hero_teleportDecal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{fts(12), 0}, {fts(13), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportIn"
--#endregion
--#region fx_bravebark_teleport_in
tt = RT("fx_bravebark_teleport_in", "fx_bravebark_teleport_out")
tt.render.sprites[1].name = "bravebark_teleportInFx"
tt.tween.props[1].keys = {{fts(1), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportOut"
--#endregion
--#region fx_bravebark_branchball_hit
tt = RT("fx_bravebark_branchball_hit", "fx")
tt.render.sprites[1].name = "bravebark_superHit"
--#endregion
--#region fx_bravebark_melee_hit
tt = RT("fx_bravebark_melee_hit", "fx")
tt.render.sprites[1].name = "bravebark_hitSmoke"
tt.render.sprites[1].anchor.y = 0.2
--#endregion
--#region fx_bravebark_ultimate
tt = RT("fx_bravebark_ultimate", "fx")
tt.render.sprites[1].name = "bravebark_spikedRoots_spawnFx"
tt.render.sprites[1].anchor.y = 0.3181818181818182
--#endregion
--#region fx_xin_smoke_teleport_out
tt = RT("fx_xin_smoke_teleport_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_xin_smoke_teleport_hit
tt = RT("fx_xin_smoke_teleport_hit", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_xin_smoke_teleport_hit_out
tt = RT("fx_xin_smoke_teleport_hit_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_xin_smoke_teleport_in
tt = RT("fx_xin_smoke_teleport_in", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_in"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_xin_panda_style_smoke
tt = RT("fx_xin_panda_style_smoke", "fx")
tt.render.sprites[1].name = "fx_xin_panda_style_smoke"
tt.render.sprites[1].anchor.y = 0.4
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_catha_ultimate
tt = RT("fx_catha_ultimate", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_catha_ultimate"
tt.render.sprites[2].z = Z_DECALS
--#endregion
--#region fx_catha_soul
tt = RT("fx_catha_soul", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
--#endregion
--#region fx_knife_catha_hit
tt = RT("fx_knife_catha_hit", "fx")
tt.render.sprites[1].name = "fx_knife_catha_hit"
--#endregion
--#region fx_bolt_veznan_hit
tt = RT("fx_bolt_veznan_hit", "fx")
tt.render.sprites[1].name = "veznan_hero_bolt_hit"
--#endregion
--#region fx_fireball_veznan_demon_hit_air
tt = RT("fx_fireball_veznan_demon_hit_air", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit_air"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_fireball_veznan_demon_hit
tt = RT("fx_fireball_veznan_demon_hit", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
--#endregion
--#region fx_veznan_arcanenova
tt = RT("fx_veznan_arcanenova", "fx")
tt.render.sprites[1].name = "fx_veznan_arcanenova"
tt.render.sprites[1].anchor.y = 0.11904761904761904
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_veznan_soulburn
tt = RT("fx_veznan_soulburn", "decal_tween")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_desintegrate"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.tween.props[1].keys = {{0.5, 255}, {1, 0}}
--#endregion
--#region fx_veznan_soulburn_ball_spawn
tt = RT("fx_veznan_soulburn_ball_spawn", "fx")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy_spawn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].z = Z_BULLETS
--#endregion
--#region fx_rag_ultimate
tt = RT("fx_rag_ultimate", "fx")
tt.render.sprites[1].name = "fx_rag_ultimate"
tt.render.sprites[1].anchor.y = 0.2
--#endregion
--#region fx_rag_raggified
tt = RT("fx_rag_raggified", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "rag_polymorphed_fx"
tt.render.sprites[1].size_scales = {vec_1(0.75), vec_1(1), vec_1(1)}
tt.sound_events.insert = "ElvesHeroRagTransform"
--#endregion
--#region fx_rabbit_kamihare_explode
tt = RT("fx_rabbit_kamihare_explode", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_rabbit_kamihare_explode"
tt.render.sprites[1].anchor.y = 0.13793103448275862
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "BombExplosionSound"
--#endregion
--#region fx_bullet_rag_hit
tt = RT("fx_bullet_rag_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_rag_hit"
--#endregion
--#region fx_durax_ultimate_fang_1
tt = RT("fx_durax_ultimate_fang_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_1"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_scales = {vec_1(0.7), vec_1(1), vec_1(1)}
tt.tween.props[1].keys = {{1, 255}, {1.2, 0}}
--#endregion
--#region fx_durax_ultimate_fang_2
tt = RT("fx_durax_ultimate_fang_2", "fx_durax_ultimate_fang_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_2"
--#endregion
--#region fx_durax_ultimate_fang_extra_1
tt = RT("fx_durax_ultimate_fang_extra_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_1"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{1, 255}, {1.2, 0}}
--#endregion
--#region fx_durax_ultimate_fang_extra_2
tt = RT("fx_durax_ultimate_fang_extra_2", "fx_durax_ultimate_fang_extra_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_2"
--#endregion
--#region fx_ray_durax_hit
tt = RT("fx_ray_durax_hit", "fx")
tt.render.sprites[1].name = "fx_ray_durax_hit"
--#endregion
--#region fx_shardseed_hit
tt = RT("fx_shardseed_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_shardseed_hit"
tt.render.sprites[1].anchor.y = 0.46296296296296297
tt.sound_events.insert = "ElvesHeroDuraxShardSpearHit"
--#endregion
--#region fx_meteor_lilith_explosion
tt = RT("fx_meteor_lilith_explosion", "fx")
tt.render.sprites[1].name = "lilith_ultimate_meteor_explosion"
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_lilith_soul_eater_ball_hit
tt = RT("fx_lilith_soul_eater_ball_hit", "fx")
tt.render.sprites[1].name = "lilith_soul_eater_explosion_anim"
--#endregion
--#region fx_lilith_ranged_hit
tt = RT("fx_lilith_ranged_hit", "fx")
tt.render.sprites[1].name = "fx_lilith_ranged_hit"
--#endregion
--#region fx_lynn_explosion
tt = RT("fx_lynn_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_lynn_explosion"
tt.render.sprites[1].anchor.y = 0.3706896551724138
tt.sound_events.insert = "BombExplosionSound"
--#endregion
--#region fx_flaming_path_start
tt = RT("fx_flaming_path_start", "fx")
tt.render.sprites[1].name = "fx_flaming_path_start"
tt.render.sprites[1].anchor.y = 0.26666666666666666
--#endregion
--#region fx_flaming_path_end
tt = RT("fx_flaming_path_end", "fx_flaming_path_start")
tt.render.sprites[1].name = "fx_flaming_path_end"
--#endregion
--#region fx_phoenix_explosion
tt = RT("fx_phoenix_explosion", "fx")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
--#endregion
--#region fx_phoenix_inmolation
tt = RT("fx_phoenix_inmolation", "decal_tween")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "phoenix_hero_suicide_decals_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "phoenix_hero_suicide_decals_0002"
tt.render.sprites[3].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{fts(20), 255}, {fts(34), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 3
tt.tween.props[2].keys = {{fts(4), 255}, {fts(10), 0}}
--#endregion
--#region fx_ray_phoenix_hit
tt = RT("fx_ray_phoenix_hit", "fx")
tt.render.sprites[1].name = "fx_ray_phoenix_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
--#endregion
--#region fx_box_wilbur_smoke_a
tt = RT("fx_box_wilbur_smoke_a", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_a"
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_box_wilbur_smoke_b
tt = RT("fx_box_wilbur_smoke_b", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_b"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
--#endregion
--#region fx_missile_wilbur_hit
tt = RT("fx_missile_wilbur_hit", "fx_fireball_veznan_demon_hit")
tt.render.sprites[1].scale = vec_1(1.4)
--#endregion
--#region fx_missile_wilbur_hit_air
tt = RT("fx_missile_wilbur_hit_air", "fx_fireball_veznan_demon_hit_air")
tt.render.sprites[1].scale = vec_1(1.4)
--#endregion
--#region fx_shot_wilbur_flash
tt = RT("fx_shot_wilbur_flash", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_flash"
--#endregion
--#region fx_shot_wilbur_hit
tt = RT("fx_shot_wilbur_hit", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_hit"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_torch_gnoll_burner_explosion
tt = RT("fx_torch_gnoll_burner_explosion", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion"
tt.render.sprites[1].anchor.y = 0.25
--#endregion
--#region fx_bolt_gnoll_blighter_hit
tt = RT("fx_bolt_gnoll_blighter_hit", "fx")
tt.render.sprites[1].name = "gnoll_blighter_proy_hit"
--#endregion
--#region fx_bandersnatch_spine
tt = RT("fx_bandersnatch_spine", "decal_tween")
tt.render.sprites[1].name = "bandersnatch_spine_ground"
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{fts(21), 255}, {fts(21) + 0.25, 0}}
--#endregion
--#region fx_bandersnatch_spines_blood
tt = RT("fx_bandersnatch_spines_blood", "fx")
tt.render.sprites[1].name = "bandersnatch_spines_blood"
tt.render.sprites[1].z = Z_EFFECTS
--#endregion
--#region fx_redcap_death_blow
tt = RT("fx_redcap_death_blow", "fx")
tt.render.sprites[1].name = "fx_redcap_death_blow"
tt.render.sprites[1].z = Z_EFFECTS
--#endregion
--#region fx_knife_satyr_hit
tt = RT("fx_knife_satyr_hit", "fx")
tt.render.sprites[1].name = "fx_knife_satyr_hit"
tt.render.sprites[1].offset.y = 5
--#endregion
--#region fx_twilight_avenger_explosion
tt = RT("fx_twilight_avenger_explosion", "fx")
tt.render.sprites[1].name = "fx_twilight_avenger_explosion"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_twilight_scourger_lash
tt = RT("fx_twilight_scourger_lash", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_lash"
tt.render.sprites[1].anchor.y = 0.19318181818181818
tt.render.sprites[1].sort_y_offset = -5
--#endregion
--#region fx_twilight_scourger_banshee_end
tt = RT("fx_twilight_scourger_banshee_end", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_banshee_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_faerie_smoke
tt = RT("fx_faerie_smoke", "fx")
tt.render.sprites[1].prefix = "fx_faerie_smoke"
tt.render.sprites[1].name = "yellow"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].anchor.y = 0.28
--#endregion
--#region fx_bullet_twilight_evoker_hit
tt = RT("fx_bullet_twilight_evoker_hit", "fx")
tt.render.sprites[1].name = "bullet_twilight_evoker_hit"
--#endregion
--#region fx_twilight_heretic_consume
tt = RT("fx_twilight_heretic_consume", "fx")
tt.render.sprites[1].name = "fx_twilight_heretic_consume"
--#endregion
--#region fx_bullet_twilight_heretic_hit
tt = RT("fx_bullet_twilight_heretic_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_twilight_heretic_hit"
--#endregion
--#region fx_bolt_ogre_magi_hit
tt = RT("fx_bolt_ogre_magi_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_bolt_ogre_magi_hit_air
tt = RT("fx_bolt_ogre_magi_hit_air", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit_air"
tt.render.sprites[1].anchor.y = 0.5555555555555556
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_bullet_dark_spitters_miss
tt = RT("fx_bullet_dark_spitters_miss", "fx")
tt.render.sprites[1].name = "fx_bullet_dark_spitters_miss"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_bullet_balrog_hit
tt = RT("fx_bullet_balrog_hit", "fx")
tt.render.sprites[1].name = "balrog_aura_splash"
tt.render.sprites[1].anchor.y = 0.43636363636363634
--#endregion
--#region fx_bullet_catapult_endless_spiked_explosion
tt = RT("fx_bullet_catapult_endless_spiked_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_spikebomb"
tt.render.sprites[1].anchor.y = 0.36875
--#endregion
--#region fx_bullet_catapult_endless_bomb_explosion
tt = RT("fx_bullet_catapult_endless_bomb_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_bomb"
tt.render.sprites[1].anchor.y = 0.36875
--#endregion
--#region fx_bullet_catapult_endless_barrel_explosion
tt = RT("fx_bullet_catapult_endless_barrel_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_barrel"
tt.render.sprites[1].anchor.y = 0.36875
--#endregion
--#region fx_block_tower_ainyl_end
tt = RT("fx_block_tower_ainyl_end", "fx")
tt.render.sprites[1].name = "ainyl_block_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
--#endregion
--#region fx_plant_magic_blossom_loading
tt = RT("fx_plant_magic_blossom_loading", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_loading"
tt.render.sprites[1].offset.y = 34
tt.render.sprites[1].draw_order = 10
--#endregion
--#region fx_plant_magic_blossom_idle1
tt = RT("fx_plant_magic_blossom_idle1", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle1"
tt.render.sprites[1].offset = vec_2(4, 59)
tt.render.sprites[1].draw_order = 10
--#endregion
--#region fx_plant_magic_blossom_idle2
tt = RT("fx_plant_magic_blossom_idle2", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle2"
tt.render.sprites[1].offset = vec_2(4, 59)
tt.render.sprites[1].draw_order = 10
--#endregion
--#region fx_bolt_plant_magic_blossom_hit
tt = RT("fx_bolt_plant_magic_blossom_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_plant_magic_blossom_hit"
--#endregion
--#region fx_plant_poison_pumpkin_idle
tt = RT("fx_plant_poison_pumpkin_idle", "decal")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_particles"
tt.render.sprites[1].draw_order = 10
--#endregion
--#region fx_plant_poison_pumpkin_smoke_left
tt = RT("fx_plant_poison_pumpkin_smoke_left", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_left"
--#endregion
--#region fx_plant_poison_pumpkin_smoke_down
tt = RT("fx_plant_poison_pumpkin_smoke_down", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_down"
--#endregion
--#region fx_plant_poison_pumpkin_smoke_fill
tt = RT("fx_plant_poison_pumpkin_smoke_fill", "decal_tween")
tt.render.sprites[1].name = "plant_venom_smoke_fill"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 46}, {fts(28), 46}, {fts(43), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.5, 0.5)}, {fts(43), vec_2(1, 1)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(0, 0)}, {fts(28), vec_2(20, 8)}, {fts(43), vec_2(26, 14)}}
--#endregion
--#region fx_bullet_pixie_instakill_hit_big
tt = RT("fx_bullet_pixie_instakill_hit_big", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_bullet_pixie_instakill_hit"
tt.sound_events.insert = "BombExplosionSound"
--#endregion
--#region fx_bullet_pixie_instakill_hit_small
tt = RT("fx_bullet_pixie_instakill_hit_small", "fx_bullet_pixie_instakill_hit_big")
tt.render.sprites[1].scale = vec_1(0.8)
--#endregion
--#region fx_bullet_pixie_poison_hit_big
tt = RT("fx_bullet_pixie_poison_hit_big", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].name = "fx_bullet_pixie_poison_hit"
tt.sound_events.insert = "ElvesGnomePoison"
--#endregion
--#region fx_bullet_pixie_poison_hit_small
tt = RT("fx_bullet_pixie_poison_hit_small", "fx_bullet_pixie_poison_hit_big")
tt.render.sprites[1].scale = vec_1(0.8)
--#endregion
--#region fx_mod_pixie_polymorph_big
tt = RT("fx_mod_pixie_polymorph_big", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_mod_pixie_polymorph"
tt.sound_events.insert = "ElvesGnomePolymorf"
--#endregion
--#region fx_mod_pixie_polymorph_small
tt = RT("fx_mod_pixie_polymorph_small", "fx_mod_pixie_polymorph_big")
tt.render.sprites[1].scale = vec_1(0.8)
--#endregion
--#region fx_mod_pixie_teleport
tt = RT("fx_mod_pixie_teleport", "fx")
tt.render.sprites[1].prefix = "fx_mod_pixie_teleport"
tt.render.sprites[1].size_names = {"small", "small", "big"}
--#endregion
--#region fx_crystal_arcane_buff
tt = RT("fx_crystal_arcane_buff", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_towerBuff_fx_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "crystalArcane_towerBuff_fx_0002"
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vec_1(0.9)
tt.render.sprites[2].sort_y_offset = -2
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 10)}, {1, vec_2(0, 44)}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
--#endregion
--#region fx_crystal_unstable_ring
tt = RT("fx_crystal_unstable_ring", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_ring"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 51}, {fts(5), 255}, {fts(20), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.42)}, {fts(5), vec_1(1.5)}, {fts(20), vec_1(2)}}
--#endregion
--#region fx_crystal_unstable_glow
tt = RT("fx_crystal_unstable_glow", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_glow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}
--#endregion
--#region fx_teleport_out_crystal_unstable
tt = RT("fx_teleport_out_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_out_crystal_unstable"
--#endregion
--#region fx_teleport_in_crystal_unstable
tt = RT("fx_teleport_in_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_in_crystal_unstable"
--#endregion
--#region fx_crystal_unstable_heal
tt = RT("fx_crystal_unstable_heal", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_glow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {fts(35), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(1)}, {fts(35), vec_1(0.23)}}

for i = 0, 2 do
	local s = CC("sprite")

	s.name = "crystalUnstable_healAura_ring"
	s.animated = false
	s.z = Z_DECALS

	table.insert(tt.render.sprites, s)

	local p = CC("tween_prop")

	p.sprite_id = #tt.render.sprites
	p.keys = {{fts(0 + i * 4), 51}, {fts(10 + i * 4), 255}, {fts(20 + i * 4), 0}}

	table.insert(tt.tween.props, p)

	p = CC("tween_prop")
	p.sprite_id = #tt.render.sprites
	p.name = "scale"
	p.keys = {{fts(0 + i * 4), vec_1(0.42)}, {fts(10 + i * 4), vec_1(0.68)}, {fts(20 + i * 4), vec_1(1)}}

	table.insert(tt.tween.props, p)
end

for i, pos in ipairs({vec_2(-22, 8), vec_2(7, 0), vec_2(-2, 2), vec_2(23, 15), vec_2(-29, 5), vec_2(11, -4), vec_2(-4, 21)}) do
	local s = CC("sprite")

	s.name = "fx_crystal_unstable_bubbles"
	s.time_offset = i * fts(1)
	s.offset = pos

	table.insert(tt.render.sprites, s)
end

--#endregion
--#region decal_arcane_burst_ground
tt = RT("decal_arcane_burst_ground", "decal_tween")
tt.render.sprites[1].name = "archer_arcane_special_decal1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "archer_arcane_special_decal2"
tt.tween.props[1].keys = {{0, 255}, {fts(4), 255}, {fts(6), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {fts(4), vec_2(1.84, 1.84)}, {fts(6), vec_2(2.17, 2.17)}}
tt.tween.props[2].sprite_id = 1
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].keys = {{0, 255}, {fts(4), 48}, {fts(9), 0}}
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_2(1, 1)}, {fts(4), vec_2(1.64, 1.64)}, {fts(6), vec_2(2.07, 2.07)}}
tt.tween.props[4].sprite_id = 2
--#endregion
--#region decal_rock_crater
tt = RT("decal_rock_crater", "decal_tween")
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.render.sprites[1].name = "artillery_thrower_explosion_decal"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_clobber_1
tt = RT("decal_clobber_1", "decal_tween")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal1"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2.5, 0}}
--#endregion
--#region decal_clobber_2
tt = RT("decal_clobber_2", "decal_clobber_1")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal2"
--#endregion
--#region decal_eerie_root_1
tt = RT("decal_eerie_root_1", "decal_scripted")
tt.render.sprites[1].prefix = "decal_eerie_roots_1"
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_eerie_root.update
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)
--#endregion
--#region decal_eerie_root_2
tt = RT("decal_eerie_root_2", "decal_eerie_root_1")
tt.render.sprites[1].prefix = "decal_eerie_roots_2"
tt.render.sprites[1].anchor.y = 0.14285714285714285
--#endregion
--#region decal_bravebark_rootspikes_hit
tt = RT("decal_bravebark_rootspikes_hit", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_handDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
--#endregion
--#region decal_bravebark_melee_hit
tt = RT("decal_bravebark_melee_hit", "decal_bravebark_rootspikes_hit")
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
--#endregion
--#region decal_bravebark_rootspike
tt = RT("decal_bravebark_rootspike", "decal_scripted")
tt.render.sprites[1].prefix = "bravebark_spike"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.25
tt.main_script.update = scripts.decal_bravebark_rootspike.update
tt.hold_duration = 1
tt.hole_decal = "decal_bravebark_rootspike_hole"
tt.delay = 0
tt.scale = 1
--#endregion
--#region decal_bravebark_rootspike_hole
tt = RT("decal_bravebark_rootspike_hole", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
--#endregion
--#region decal_bravebark_branchball_enemy_clone
tt = RT("decal_bravebark_branchball_enemy_clone", "decal_tween")
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {0.35, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {0.35, vec_2(0, 0)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {{0, 0}, {0.35, 0}}
--#endregion
--#region decal_bram_enemy_clone
tt = RT("decal_bram_enemy_clone", "decal_bravebark_branchball_enemy_clone")
--#endregion
--#region decal_bravebark_ultimate
tt = RT("decal_bravebark_ultimate", "decal_sequence")
tt.render.sprites[1].prefix = "bravebark_spikedRoots"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].scale = vec_1(0.75)
tt.sequence.steps = {"in", 1, "out"}
tt.sequence.fxs = {"fx_bravebark_ultimate", nil, "decal_bravebark_ultimate_crater"}
--#endregion
--#region decal_bravebark_ultimate_crater
tt = RT("decal_bravebark_ultimate_crater", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikedRootsDecal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
--#endregion
--#region decal_xin_inspire
tt = RT("decal_xin_inspire", "decal_tween")
tt.render.sprites[1].name = "xin_hero_scream_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 63}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {fts(10), vec_1(0.68)}, {fts(20), vec_1(1.25)}}
--#endregion
--#region decal_xin_drink_circle
tt = RT("decal_xin_drink_circle", "decal_tween")
tt.render.sprites[1].name = "xin_hero_drink_auraCircle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.7)}, {fts(20), vec_1(1.5)}}
--#endregion
--#region decal_veznan_arcanenova
tt = RT("decal_veznan_arcanenova", "decal_bomb_crater")
tt.render.sprites[1].name = "veznan_hero_arcaneNova_terrainDecal"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_veznan_arcanenova_terrain"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
--#endregion
--#region decal_veznan_soulburn_ball
tt = RT("decal_veznan_soulburn_ball", "decal_scripted")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].hidden = true
tt.from = nil
tt.to = nil
tt.target = nil
tt.speed = 14 * FPS
tt.offset = vec_2(-5, 5)
tt.particles_name = "ps_veznan_soulburn"
tt.spawn_fx = "fx_veznan_soulburn_ball_spawn"
tt.main_script.update = scripts.decal_veznan_soulburn_ball.update
--#endregion
--#region decal_baby_malik_smash
tt = RT("decal_baby_malik_smash", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_ring"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
--#endregion
--#region decal_baby_malik_earthquake
tt = RT("decal_baby_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
--#endregion
--#region decal_rag_ultimate
tt = RT("decal_rag_ultimate", "fx")
tt.render.sprites[1].name = "decal_rag_ultimate"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_durax
tt = RT("decal_durax", "decal")
tt.render.sprites[1].name = "aura_durax"
tt.render.sprites[1].scale = vec_1(1.3)
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_meteor_lilith_explosion
tt = RT("decal_meteor_lilith_explosion", "decal_tween")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_1(0.6)
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 130}, {2.5, 130}, {3.25, 0}}
--#endregion
--#region decal_lilith_soul_eater_ball
tt = RT("decal_lilith_soul_eater_ball", "decal_scripted")

AC(tt, "force_motion", "sound_events")

tt.render.sprites[1].name = "lilith_soul_eater_ball_loop"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.force_motion.max_a = 5400
tt.force_motion.max_v = 240
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.main_script.update = scripts.decal_lilith_soul_eater_ball.update
tt.hit_fx = "fx_lilith_soul_eater_ball_hit"
tt.hit_mod = "mod_lilith_soul_eater_damage_factor"
tt.stolen_damage = nil
tt.sound_events.insert = "ElvesHeroLilithSoulEater"
--#endregion
--#region decal_lilith_reapers_harvest
tt = RT("decal_lilith_reapers_harvest", "decal_timed")
tt.render.sprites[1].name = "lilith_reapers_harvest_decal_anim"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_phoenix_ultimate
tt = RT("decal_phoenix_ultimate", "decal_rock_crater")
tt.render.sprites[1].name = "phoenix_hero_egg_decal"
--#endregion
--#region decal_phoenix_flaming_path_pulse
tt = RT("decal_phoenix_flaming_path_pulse", "decal_tween")
tt.render.sprites[1].name = "phoenix_hero_towerBurn_Circle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.32, vec_2(2.4, 2.4)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.32, 0}}
--#endregion
--#region decal_twilight_scourger_lash
tt = RT("decal_twilight_scourger_lash", "decal_tween")
tt.render.sprites[1].name = "scourger_special_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.tween.props[1].keys = {{fts(11), 153}, {fts(16), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_1(0.312)}, {fts(16), vec_1(0.725)}}
tt.tween.props[2].sprite_id = 1
tt.tween.props[2].name = "scale"
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].keys = {{fts(11), 153}, {fts(16), 0}}
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].keys = {{0, vec_1(0.408)}, {fts(16), vec_1(0.961)}}
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.deepclone(tt.tween.props[1])
tt.tween.props[5].keys = {{fts(9), 153}, {fts(16), 0}}
tt.tween.props[5].sprite_id = 3
tt.tween.props[6] = table.deepclone(tt.tween.props[2])
tt.tween.props[6].keys = {{0, vec_1(0.766)}, {fts(16), vec_1(1.265)}}
tt.tween.props[6].sprite_id = 3
tt.tween.props[7] = table.deepclone(tt.tween.props[1])
tt.tween.props[7].keys = {{fts(9), 153}, {fts(16), 0}}
tt.tween.props[7].sprite_id = 4
tt.tween.props[8] = table.deepclone(tt.tween.props[2])
tt.tween.props[8].keys = {{0, vec_1(0.986)}, {fts(16), vec_1(1.627)}}
tt.tween.props[8].sprite_id = 4
--#endregion
--#region decal_twilight_golem_attack
tt = RT("decal_twilight_golem_attack", "decal_tween")
tt.render.sprites[1].name = "gollem_attackFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.x = 22
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset.x = -22
tt.tween.props[1].keys = {{0, 255}, {fts(12), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(1)}, {fts(12), vec_1(2.3)}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
--#endregion
--#region decal_twilight_heretic_consume_ball
tt = RT("decal_twilight_heretic_consume_ball", "decal_scripted")

AC(tt, "force_motion")

tt.render.sprites[1].name = "twilight_heretic_consumeProy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].alpha = 100
tt.force_motion.max_a = 4500
tt.force_motion.max_v = 150
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.force_motion.a.x = 1
tt.main_script.update = scripts.decal_twilight_heretic_consume_ball.update
tt.particles_name = "ps_twilight_heretic_consume_ball_particle"
--#endregion
--#region decal_drider_clone
tt = RT("decal_drider_clone", "decal_timed")
tt.timed.duration = 1
--#endregion
--#region decal_drider_cocoon
tt = RT("decal_drider_cocoon", "decal_scripted")
tt.render.sprites[1].prefix = "decal_drider_cocoon"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_scales = {vec_1(0.8), vec_1(1), vec_1(1)}
tt.render.sprites[1].anchor.y = 0.16
tt.main_script.update = scripts.decal_drider_cocoon.update
tt.duration = 5
--#endregion
--#region decal_arachnomancer_mini_spider
tt = RT("decal_arachnomancer_mini_spider", "decal_scripted")

AC(tt, "motion")

tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].prefix = "arachnomancer_mini_spider"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.spider_offsets = {vec_2(20, -5), vec_2(-20, -5), vec_2(0, 23)}
tt.main_script.update = scripts.decal_arachnomancer_mini_spider.update
tt.motion.max_speed = 7.5
tt.max_delta_y = 10
--#endregion
--#region decal_webspawn_enemy_spider_arachnomancer
tt = RT("decal_webspawn_enemy_spider_arachnomancer", "decal_scripted")

AC(tt, "nav_path")

tt.main_script.insert = scripts.delayed_spawn.insert
tt.main_script.update = scripts.delayed_spawn.update
tt.render.sprites[1].prefix = "arachnomancer_webspawn"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].sort_y_offset = -1
tt.delay = fts(8)
tt.entity = "enemy_spider_arachnomancer"
--#endregion
--#region decal_webspawn_enemy_sword_spider
tt = RT("decal_webspawn_enemy_sword_spider", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_sword_spider"
--#endregion
--#region decal_webspawn_enemy_spider_son_of_mactans
tt = RT("decal_webspawn_enemy_spider_son_of_mactans", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_spider_son_of_mactans"
--#endregion
--#region decal_shadow_spider_son_of_mactans
tt = RT("decal_shadow_spider_son_of_mactans", "decal_tween")
tt.render.sprites[1].name = "son_of_mactans_shadow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2 + fts(21), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_1(0)}, {2, vec_1(1)}}
tt.tween.props[2].name = "scale"
--#endregion
--#region decal_mactans_path_web_1
tt = RT("decal_mactans_path_web_1", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_floorNet_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.props[1].keys = {{0, 0}, {"this.fade_duration", 255}, {"this.duration-this.fade_duration", 255}, {"this.duration", 0}}
--#endregion
--#region decal_mactans_path_web_2
tt = RT("decal_mactans_path_web_2", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0002"
--#endregion
--#region decal_mactans_path_web_3
tt = RT("decal_mactans_path_web_3", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0003"
--#endregion
--#region decal_bloodsydian_warlock
tt = RT("decal_bloodsydian_warlock", "decal_tween")
tt.tween.props[1].keys = {{0, 255}, {0.25, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {0.25, vec_2(2.4, 2.4)}}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bloodsydianWarlock_convert_aura"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region decal_snare_hee_haw
tt = RT("decal_snare_hee_haw", "decal_tween")
tt.render.sprites[1].anchor = vec_2(0.4785714285714286, 0.31)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hee-haw_net_0031"
tt.tween.props[1].keys = {{0, 0}, {1, 255}, {fts(60), 255}, {fts(65), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{fts(11), vec_1(0.3)}, {fts(65), vec_1(0.6)}}
tt.tween.props[2].name = "scale"
tt.tween.remove = true
--#endregion
--#region decal_catapult_endless
tt = RT("decal_catapult_endless", "decal_scripted")

AC(tt, "ranged", "editor")

tt.editor.props = {{"x_inside", PT_NUMBER}}
tt.duration = 2
tt.x_inside = 955
tt.transit_time = 8
tt.render.sprites[1].prefix = "catapult_endless_layer1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "catapult_endless_layer2"
tt.main_script.update = scripts.decal_catapult_endless.update
tt.ranged.attacks[1].bullet = "rock_enemy_catapult"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-30, 90)}
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_x = 800
tt.ranged.attacks[1].min_x = 150
tt.ranged.attacks[1].shoot_time = fts(39)
tt.ranged.attacks[1].path_margins = {90, 30}
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.ranged.attacks[1].count = 1
tt.ranged.attacks[1].barrel_payload_idx = nil
tt.ranged.attacks[1].munition_type = 0
tt.ranged.attacks[1].munition_settings = {
	[0] = {
		[0] = "catapult_endless_layer8",
		"catapult_endless_layer9",
		bullet = "bullet_catapult_endless_rock"
	},
	{
		[0] = "catapult_endless_layer6",
		"catapult_endless_layer3",
		bullet = "bullet_catapult_endless_spiked"
	},
	{
		[0] = "catapult_endless_layer5",
		"catapult_endless_layer2",
		bullet = "bullet_catapult_endless_bomb"
	},
	{
		[0] = "catapult_endless_layer7",
		"catapult_endless_layer4",
		bullet = "bullet_catapult_endless_barrel"
	}
}
tt.ranged.attacks[1].barrel_payloads = {"enemy_gnoll_reaver", "enemy_gnoll_burner", "enemy_gnoll_gnawer", "enemy_gnoll_blighter"}
--#endregion
--#region decal_crystal_arcane_freeze_center
tt = RT("decal_crystal_arcane_freeze_center", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_groundFreeze_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.duration", 255}, {"this.duration+0.3", 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.2)}, {0.2, vec_1(1)}}
--#endregion
--#region decal_crystal_arcane_freeze_1
tt = RT("decal_crystal_arcane_freeze_1", "decal_tween")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.duration", 255}, {"this.duration+0.3", 0}}
--#endregion
--#region decal_crystal_arcane_freeze_2
tt = RT("decal_crystal_arcane_freeze_2", "decal_crystal_arcane_freeze_1")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_2"
--#endregion
--#region tower_holder_elven_woods
tt = RT("tower_holder_elven_woods", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ELVEN_WOODS
tt.render.sprites[1].name = "build_terrain_0001"
--#endregion
--#region tower_holder_faerie_grove
tt = RT("tower_holder_faerie_grove", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FAERIE_GROVE
tt.render.sprites[1].name = "build_terrain_0002"
--#endregion
--#region tower_holder_ancient_metropolis
tt = RT("tower_holder_ancient_metropolis", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ANCIENT_METROPOLIS
tt.render.sprites[1].name = "build_terrain_0007"
--#endregion
--#region tower_holder_hulking_rage
tt = RT("tower_holder_hulking_rage", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_HULKING_RAGE
tt.render.sprites[1].name = "build_terrain_0004"
--#endregion
--#region tower_holder_bittering_rancor
tt = RT("tower_holder_bittering_rancor", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BITTERING_RANCOR
tt.render.sprites[1].name = "build_terrain_0005"
--#endregion
--#region tower_holder_forgotten_treasures
tt = RT("tower_holder_forgotten_treasures", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FORGOTTEN_TREASURES
tt.render.sprites[1].name = "build_terrain_0006"
--#endregion
--#region tower_bastion_holder
tt = RT("tower_bastion_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")

tt.editor.props = {{"tower.default_rally_pos", PT_COORDS}, {"tower.holder_id", PT_STRING}, {"editor.game_mode", PT_NUMBER}}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
tt.tower.type = "holder_bastion"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower.menu_offset = vec_2(-10, 16)
tt.info.fn = scripts.tower_bastion.get_info
tt.info.portrait = "kr3_info_portraits_towers_0020"
tt.info.i18n_key = "ELVES_TOWER_BASTION_BROKEN"
tt.render.sprites[1].name = "galahadriansBastion_layer2_0054"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.3153846153846154
tt.render.sprites[1].offset = IS_CONSOLE and vec_2(0, 24) or vec_2(0, -9)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "galahadriansBastion_layer2_0054"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor.y = 0.3153846153846154
tt.ui.click_rect = r(-40, -10, 80, 90)
--#endregion
--#region tower_bastion
tt = RT("tower_bastion", "tower")

AC(tt, "attacks", "powers")

tt.info.portrait = "kr3_info_portraits_towers_0020"
tt.info.i18n_key = "ELVES_TOWER_BASTION"
tt.info.fn = scripts.tower_bastion.get_info
tt.main_script.insert = scripts.tower_bastion.insert
tt.main_script.update = scripts.tower_bastion.update
tt.powers.razor_edge = CC("power")
tt.powers.razor_edge.max_level = 2
tt.powers.razor_edge.price_base = 200
tt.powers.razor_edge.price_inc = 200
tt.powers.razor_edge.enc_icon = 17
tt.powers.razor_edge.attack_idx = 1
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "galahadriansBastion_layer2_0053"
tt.render.sprites[1].anchor.y = 0.3153846153846154
tt.render.sprites[1].offset = IS_CONSOLE and vec_2(0, 24) or vec_2(0, -9)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true

for i = 1, 4 do
	local s = CC("sprite")

	s.prefix = "galahadriansBastion_layer" .. i
	s.name = "idle"
	s.anchor.y = 0.3153846153846154
	s.group = "animated"
	tt.render.sprites[i + 1] = s
end

tt.sound_events.mute_on_level_insert = true
tt.sound_events.insert = {"ElvesTowerBastionInsertTaunt", "GUITowerBuilding"}
tt.tower.type = "bastion"
tt.tower.level = 1
tt.tower.price = 250
tt.tower.menu_offset = vec_2(-10, 16)
tt.ui.click_rect = r(-50, -10, 100, 80)
tt.attacks.hide_range = true
tt.attacks.range = 150
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "bullet_razor_edge"
tt.attacks.list[1].payload_name = "aura_razor_edge"
tt.attacks.list[1].bullet_start_offset = {vec_2(40, 33)}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].sound_shoot = "ElvesTowerBastionShot"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_FRIEND)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
--#endregion
--#region bullet_razor_edge
tt = RT("bullet_razor_edge", "bolt")
tt.bullet.payload = "aura_razor_edge"
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.acceleration_factor = 0.3
tt.bullet.ignore_rotation = true
tt.bullet.hit_fx = nil
tt.bullet.max_speed = 450
tt.bullet.min_speed = 150
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "bullet_razor_edge"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
--#endregion
--#region aura_razor_edge
tt = RT("aura_razor_edge", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(6)
tt.aura.damage_min = 2
tt.aura.damage_max = 4
tt.aura.damage_inc = 2
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 55
tt.aura.duration = 1
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.insert = scripts.aura_razor_edge.insert
tt.main_script.update = scripts.aura_apply_damage.update
tt.render.sprites[1].name = "bullet_razor_edge_flying"
tt.render.sprites[1].loop = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {0.2, 255}, {"this.aura.duration-0.2", 255}, {"this.aura.duration", 0}}

for i = 2, 4 do
	local s = CC("sprite")

	s.name = "bullet_razor_edge_smoke"
	s.loop = true
	s.random_ts = 0.4
	s.anchor.y = 0
	s.offset.x = ({0, -15, 0, 15})[i]
	s.offset.y = ({0, -20, -5, -20})[i]
	tt.render.sprites[i] = s
	tt.tween.props[i] = table.deepclone(tt.tween.props[1])
	tt.tween.props[i].sprite_id = i
	tt.tween.props[i].keys[1][2] = 0
end

--#endregion
--#region rabbit_kamihare
tt = RT("rabbit_kamihare", "decal_scripted")

AC(tt, "nav_path", "motion", "custom_attack")

tt.render.sprites[1].prefix = "rabbit"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt.main_script.update = scripts.rabbit_kamihare.update
tt.nav_path.dir = -1
tt.motion.max_speed = 1.25 * FPS
tt.duration = 100
tt.custom_attack.max_range = 25
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.aura = "aura_rabbit_kamihare"
tt.custom_attack.hit_fx = "fx_rabbit_kamihare_explode"
--#endregion

--#region bomb_wilbur
tt = RT("bomb_wilbur", "rabbit_kamihare")
AC(tt, "sound_events")
tt.render.sprites[1].prefix = "bomb_wilbur"
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt.render.sprites[1].random_ts = 0.5
tt.main_script.update = scripts.rabbit_kamihare.update
tt.motion.max_speed = 2 * FPS
tt.duration = 100
tt.custom_attack.max_range = 30
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.custom_attack.aura = "aura_bomb_wilbur"
tt.custom_attack.hit_fx = nil
tt.sound_events.insert = "ElvesHeroGyroBombsMarch"
tt.sound_events.remove_stop = "ElvesHeroGyroBombsMarch"
-- --#endregion
--#region soldier_re_0
tt = RT("soldier_re_0", "soldier_militia")
-- AC(tt, "reinforcement", "tween")
-- image_y = 54
-- anchor_y = 10 / image_y
-- tt.cooldown = 15
-- tt.health.armor = 0
-- tt.health.hp_max = 40
-- tt.health_bar.offset = vec_2(0, 30)
-- tt.info.portrait_idxs = {38, 42, 46}
-- tt.info.random_name_format = "ELVES_SOLDIER_REINFORCEMENT_%i_NAME"
-- tt.info.random_name_count = 20
-- tt.main_script.insert = scripts.soldier_reinforcement.insert
-- tt.main_script.update = scripts.soldier_reinforcement.update
-- tt.melee.attacks[1].cooldown = 1
-- tt.melee.attacks[1].damage_max = 3
-- tt.melee.attacks[1].damage_min = 1
-- tt.melee.attacks[1].hit_time = fts(5)
-- tt.melee.range = 60
-- tt.motion.max_speed = 60
-- tt.regen.cooldown = 1
-- tt.regen.health = 15
-- tt.reinforcement.duration = 20
-- tt.render.sprites[1].anchor.y = anchor_y
-- tt.render.sprites[1].prefix = "soldier_re_%s0"
-- tt.soldier.melee_slot_offset = vec_2(3, 0)
-- tt.sound_events.insert = "ReinforcementTaunt"
-- tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
-- tt.tween.props[1].name = "alpha"
-- tt.tween.remove = false
-- tt.tween.reverse = false
-- tt.unit.hit_offset = vec_2(0, 5)
-- tt.unit.mod_offset = vec_2(0, 14)
-- tt.unit.level = 0
-- tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
-- --#endregion
--#region soldier_re_1
tt = RT("soldier_re_1", "soldier_re_0")
-- tt.unit.level = 1
-- tt.health.hp_max = 60
-- tt.health.armor = 0.2
-- tt.melee.attacks[1].damage_max = 5
-- tt.melee.attacks[1].damage_min = 3
-- tt.render.sprites[1].prefix = "soldier_re_%s0"
-- --#endregion
--#region soldier_re_2
tt = RT("soldier_re_2", "soldier_re_1")
-- AC(tt, "ranged")
-- tt.unit.level = 2
-- tt.health.hp_max = 60
-- tt.health.armor = 0.2
-- tt.info.portrait_idxs = {39, 43, 47}
-- tt.melee.attacks[1].damage_max = 5
-- tt.melee.attacks[1].damage_min = 3
-- tt.render.sprites[1].prefix = "soldier_re_%s1"
-- tt.ranged.attacks[1].bullet = "arrow_soldier_re_2"
-- tt.ranged.attacks[1].shoot_time = fts(10)
-- tt.ranged.attacks[1].cooldown = 1 + fts(18)
-- tt.ranged.attacks[1].max_range = 140
-- tt.ranged.attacks[1].min_range = 10
-- tt.ranged.attacks[1].animation = "shoot"
-- tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 22)}
-- --#endregion
--#region soldier_re_3
tt = RT("soldier_re_3", "soldier_re_2")
-- tt.unit.level = 3
-- tt.health.hp_max = 100
-- tt.health.armor = 0.35
-- tt.info.portrait_idxs = {40, 44, 48}
-- tt.melee.attacks[1].damage_max = 10
-- tt.melee.attacks[1].damage_min = 5
-- tt.render.sprites[1].prefix = "soldier_re_%s2"
-- tt.ranged.attacks[1].bullet = "arrow_soldier_re_3"
-- tt.ranged.attacks[1].max_range = 150
-- --#endregion
--#region soldier_re_4
tt = RT("soldier_re_4", "soldier_re_3")
-- tt.cooldown = 10
-- tt.unit.level = 4
-- tt.health.hp_max = 100
-- tt.health.armor = 0.35
-- tt.info.portrait_idxs = {40, 44, 48}
-- tt.melee.attacks[1].damage_max = 10
-- tt.melee.attacks[1].damage_min = 5
-- tt.render.sprites[1].prefix = "soldier_re_%s2"
-- tt.ranged.attacks[1].bullet = "arrow_soldier_re_4"
-- tt.ranged.attacks[1].max_range = 150
-- --#endregion
--#region soldier_re_5
tt = RT("soldier_re_5", "soldier_re_4")
-- tt.unit.level = 5
-- tt.health.hp_max = 150
-- tt.health.armor = 0.5
-- tt.health_bar.offset = vec_2(0, 46)
-- tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
-- tt.info.portrait_idxs = {41, 45, 49}
-- tt.melee.attacks[1].damage_max = 15
-- tt.melee.attacks[1].damage_min = 10
-- tt.melee.attacks[1].hit_time = fts(11)
-- tt.motion.max_speed = 84
-- tt.render.sprites[1].prefix = "soldier_re_%s3"
-- tt.ranged.attacks[1].bullet = "arrow_soldier_re_5"
-- tt.ranged.attacks[1].max_range = 160
-- tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 36)}
-- tt.soldier.melee_slot_offset = vec_2(8, 0)
-- tt.unit.hit_offset = vec_2(0, 15)
-- tt.unit.mod_offset = vec_2(0, 22)
-- for i, k in ipairs({"A", "B", "C"}) do
--     for j = 0, 5 do
--         local name = string.format("soldier_re_%i", j)
--         local base_t = E:get_template(name)
--         local fn = name .. "_" .. i
--         local t = RT(fn, base_t)
--         t.render.sprites[1].prefix = string.format(t.render.sprites[1].prefix, k)
--         t.info.portrait = string.format("kr3_portraits_sc_00%02d", t.info.portrait_idxs[i])
--     end
-- end
-- for i = 1, 3 do
--     E:set_template("re_current_" .. i, E:get_template("soldier_re_0_" .. i))
-- end
--#endregion
--#region fx_elves_denas_flash
tt = RT("fx_elves_denas_flash", "fx")
tt.render.sprites[1].name = "fx_elves_denas_flash"
--#endregion
--#region fx_shield_elves_denas_hit
tt = RT("fx_shield_elves_denas_hit", "fx")
tt.render.sprites[1].name = "fx_shield_elves_denas_hit"
tt.render.sprites[1].z = Z_EFFECTS - 1
--#endregion
--#region decal_minidragon_faustus
tt = RT("decal_minidragon_faustus", "decal_scripted")

AC(tt, "motion", "attacks")

tt.main_script.update = scripts.decal_minidragon_faustus.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = CC("aura_attack")
tt.attacks.list[1].disabled = true
tt.attacks.list[1].bullet = "aura_minidragon_faustus"
tt.attacks.list[1].bullet_start_offset = vec_2(25, 70)
tt.attacks.list[1].cooldown = fts(2)
tt.attacks.list[1].sound = "ElvesHeroFaustusFire"
tt.render.sprites[1].prefix = "minidragon_faustus_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = vec_2(0, 70)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "minidragon_faustus_l2"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, 70)
tt.emit_ox = 180
tt.cast_ox = 80
tt.image_w = 40
-- --#endregion
--#region hero_alleria
-- tt = RT("hero_alleria", "stage_hero")
-- AC(tt, "melee", "ranged")
-- image_y = 66
-- anchor_y = 15 / image_y
-- tt.health.armor = 0
-- tt.health.dead_lifetime = 15
-- tt.health.hp_max = 210
-- tt.health_bar.offset = vec_2(0, 36)
-- tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
-- tt.hero.level = 3
-- tt.hero.xp = 11299
-- tt.hero.tombstone_show_time = fts(90)
-- tt.idle_flip.cooldown = 1
-- tt.info.fn = scripts.hero_basic.get_info
-- tt.info.hero_portrait = "hero_portraits_0019"
-- tt.info.i18n_key = "HERO_ARCHER"
-- tt.info.portrait = "kr3_portraits_sc_0064"
-- tt.info.damage_icon = "arrow"
-- tt.fixed_mode = nil
-- tt.main_script.insert = scripts.hero_alleria.insert
-- tt.main_script.update = scripts.hero_alleria.update
-- tt.motion.max_speed = 3 * FPS
-- tt.regen.cooldown = 1
-- tt.regen.health = 23
-- tt.render.sprites[1].anchor.y = anchor_y
-- tt.render.sprites[1].name = "idle"
-- tt.render.sprites[1].prefix = "hero_alleria"
-- tt.render.sprites[1].angles = {}
-- tt.render.sprites[1].angles.walk = {"walk"}
-- tt.render.sprites[1].angles.ranged = {"shoot"}
-- tt.soldier.melee_slot_offset.x = 2
-- tt.sound_events.change_rally_point = "ElvesHeroAlleriaTaunt"
-- tt.sound_events.death = "ElvesHeroAlleriaDeath"
-- tt.sound_events.insert = "ElvesHeroAlleriaTauntIntro"
-- tt.sound_events.respawn = "ElvesHeroAlleriaTauntIntro"
-- tt.unit.hit_offset = vec_2(0, 16)
-- tt.unit.marker_offset = vec_2(0, 0)
-- tt.unit.mod_offset = vec_2(0, 13)
-- tt.melee.attacks[1].cooldown = 1
-- tt.melee.attacks[1].damage_max = 15
-- tt.melee.attacks[1].damage_min = 10
-- tt.melee.attacks[1].hit_time = fts(8)
-- tt.melee.attacks[1].sound = "MeleeSword"
-- tt.melee.attacks[1].damage_type = DAMAGE_TRUE
-- tt.melee.range = 65
-- tt.ranged.attacks[1] = CC("bullet_attack")
-- tt.ranged.attacks[1].animation = "ranged"
-- tt.ranged.attacks[1].bullet = "arrow_hero_alleria"
-- tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 24)}
-- tt.ranged.attacks[1].cooldown = 1
-- tt.ranged.attacks[1].max_range = 200
-- tt.ranged.attacks[1].min_range = 40
-- tt.ranged.attacks[1].node_prediction = fts(11)
-- tt.ranged.attacks[1].shoot_time = fts(11)
-- tt.ranged.attacks[2] = CC("bullet_attack")
-- tt.ranged.attacks[2].animation = "shootSpecial"
-- tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria"
-- tt.ranged.attacks[2].bullet_start_offset = {vec_2(9, 24)}
-- tt.ranged.attacks[2].cooldown = 5
-- tt.ranged.attacks[2].max_range = 200
-- tt.ranged.attacks[2].min_range = 40
-- tt.ranged.attacks[2].node_prediction = fts(13)
-- tt.ranged.attacks[2].shoot_time = fts(13)
-- tt.ranged.attacks[2].sound = "ElvesHeroAlleriaShoot"
-- --#endregion
--#region hero_alleria_fixed
-- tt = RT("hero_alleria_fixed", "hero_alleria")
-- tt.fixed_mode = true
-- tt.health.ignore_damage = true
-- tt.health_bar.hidden = true
-- tt.vis.bans = F_ALL
-- tt.render.sprites[1].z = Z_OBJECTS + 1
-- tt.ui.can_click = false
-- tt.ui.can_select = false
-- tt.ranged.attacks[1].bullet = "arrow_hero_alleria_fixed"
-- tt.ranged.attacks[1].filter_fn = scripts.hero_alleria.fixed_ranged_filter_fn
-- tt.ranged.attacks[1].max_range = 600
-- tt.ranged.attacks[1].min_range = 0
-- tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria_fixed"
-- tt.ranged.attacks[2].cooldown = 7
-- tt.ranged.attacks[2].filter_fn = scripts.hero_alleria.fixed_ranged_filter_fn
-- tt.ranged.attacks[2].max_range = 600
-- tt.ranged.attacks[2].min_range = 0
-- --#endregion
--#region arrow_hero_alleria
-- tt = RT("arrow_hero_alleria", "arrow")
-- tt.bullet.flight_time = fts(22)
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 15
-- --#endregion
--#region arrow_multishot_hero_alleria
-- tt = RT("arrow_multishot_hero_alleria", "arrow")
-- tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 15
-- tt.bullet.damage_true = DAMAGE_TRUE
-- tt.bullet.flight_time = fts(22)
-- tt.extra_arrows_range = 100
-- tt.extra_arrows = 2
-- tt.main_script.insert = scripts.arrow_multishot_hero_alleria.insert
-- tt.render.sprites[1].name = "hero_alleria_arrow-f"
-- --#endregion
--#region arrow_hero_alleria_fixed
-- tt = RT("arrow_hero_alleria_fixed", "arrow_hero_alleria")
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 30
-- tt.bullet.prediction_error = nil
-- --#endregion
--#region arrow_multishot_hero_alleria_fixed
-- tt = RT("arrow_multishot_hero_alleria_fixed", "arrow_multishot_hero_alleria")
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 30
-- tt.bullet.prediction_error = nil
-- tt.extra_arrows = 3
-- --#endregion
--#region alleria_cat
-- tt = RT("alleria_cat", "soldier")
-- AC(tt, "nav_grid")
-- anchor_y = 0.2619047619047619
-- image_y = 42
-- tt.behaviour_attack = {}
-- tt.behaviour_attack.min_cooldown = 2
-- tt.behaviour_attack.max_cooldown = 3
-- tt.behaviour_attack.cooldown = tt.behaviour_attack.min_cooldown
-- tt.behaviour_attack.animation = "attack"
-- tt.behaviour_attack.sound = "ElvesAlleriaCatHit"
-- tt.behaviour_attack.hit_time = fts(9)
-- tt.behaviour_attack.min_distance = 10
-- tt.behaviour_attack.max_distance = 100
-- tt.behaviour_attack.y_offset = -6
-- tt.behaviour_scared = {}
-- tt.behaviour_scared.min_cooldown = fts(150)
-- tt.behaviour_scared.max_cooldown = fts(160)
-- tt.behaviour_scared.cooldown = tt.behaviour_scared.min_cooldown
-- tt.behaviour_scared.animation = "scared"
-- tt.health.armor = 0
-- tt.health.hp_max = 150
-- tt.health.ignore_damage = true
-- tt.health_bar.hidden = true
-- tt.info.i18n_key = "HERO_ARCHER_WILDCAT"
-- tt.main_script.update = scripts.alleria_cat.update
-- tt.motion.max_speed = 69
-- tt.render.sprites[1].anchor.y = anchor_y
-- tt.render.sprites[1].name = "idle"
-- tt.render.sprites[1].prefix = "alleria_wildcat"
-- tt.render.sprites[1].angles = {}
-- tt.render.sprites[1].angles.walk = {"walk"}
-- tt.ui.can_click = false
-- tt.ui.can_select = false
-- tt.unit.hit_offset = vec_2(0, 0)
-- tt.unit.mod_offset = vec_2(0, 10)
-- tt.unit.hide_after_death = true
-- tt.unit.explode_fx = nil
-- tt.vis.bans = F_ALL
--#endregion
--#region hero_baby_malik
tt = RT("hero_baby_malik", "stage_hero")

AC(tt, "melee")

tt.hero.level_stats.armor = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
tt.hero.level_stats.hp_max = {320, 345, 370, 395, 420, 445, 470, 495, 520, 545}
tt.hero.level_stats.melee_damage_max = {17, 18, 20, 21, 23, 24, 25, 27, 28, 30}
tt.hero.level_stats.melee_damage_min = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
tt.hero.level_stats.regen_health = {18, 19, 21, 23, 24, 26, 28, 29, 31, 33}
tt.hero.skills.smash = CC("hero_skill")
tt.hero.skills.smash.damage_min = {45, 90, 130}
tt.hero.skills.smash.damage_max = {55, 110, 170}
tt.hero.skills.smash.xp_gain = {1000, 2000, 3000}
tt.hero.skills.smash.skill_upgrade_levels = {2, 5, 8}
tt.hero.skills.fissure = CC("hero_skill")
tt.hero.skills.fissure.damage_radius = {16.5, 33, 49.5}
tt.hero.skills.fissure.damage_min = {25, 50, 75}
tt.hero.skills.fissure.damage_max = {25, 50, 75}
tt.hero.skills.fissure.xp_gain = {2000, 4000, 8000}
tt.hero.skills.fissure.skill_upgrade_levels = {4, 7, 10}
tt.health.dead_lifetime = 15
tt.health_bar.offset = vec_2(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hero.fn_level_up = scripts.hero_baby_malik.level_up
tt.hero.tombstone_show_time = fts(90)
tt.info.fn = scripts.hero_basic.get_info
tt.info.hero_portrait = "hero_portraits_0003"
tt.info.i18n_key = "HERO_ELVES_MALIK"
tt.info.portrait = "info_portraits_heroes_0003"
tt.info.ultimate_icon = "0013"
tt.main_script.update = scripts.hero_baby_malik.update
tt.motion.max_speed = 3 * FPS
tt.regen.cooldown = 1
tt.render.sprites[1].anchor.y = 0.184
tt.render.sprites[1].prefix = "baby_malik"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].angles.ranged = {"shoot"}
tt.render.sprites[1].name = "idle"
tt.soldier.melee_slot_offset = vec_2(2, 0)
tt.sound_events.change_rally_point = "HeroReinforcementTaunt"
tt.sound_events.death = "HeroReinforcementDeath"
tt.sound_events.insert = {"HeroReinforcementTaunt", "HeroReinforcementTauntIntro"}
tt.sound_events.respawn = "HeroReinforcementTauntIntro"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 13)
tt.melee.range = 65
tt.melee.cooldown = 1
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 6.5
tt.melee.attacks[1].sound_hit = "HeroReinforcementHit"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[3] = CC("area_attack")
tt.melee.attacks[3].animation = "smash"
tt.melee.attacks[3].cooldown = 10
tt.melee.attacks[3].damage_max = nil
tt.melee.attacks[3].damage_min = nil
tt.melee.attacks[3].damage_radius = 50
tt.melee.attacks[3].damage_type = DAMAGE_TRUE
tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_decal = "decal_baby_malik_smash"
tt.melee.attacks[3].hit_offset = vec_2(22, 0)
tt.melee.attacks[3].hit_time = fts(14)
tt.melee.attacks[3].min_count = 3
tt.melee.attacks[3].sound = "HeroReinforcementSpecial"
tt.melee.attacks[3].xp_from_skill = "smash"
tt.melee.attacks[4] = CC("area_attack")
tt.melee.attacks[4].animation = "jumpSmash"
tt.melee.attacks[4].cooldown = 20
tt.melee.attacks[4].damage_type = DAMAGE_TRUE
tt.melee.attacks[4].disabled = true
tt.melee.attacks[4].hit_aura = "aura_baby_malik_fissure"
tt.melee.attacks[4].hit_offset = vec_2(22, 0)
tt.melee.attacks[4].hit_time = fts(17)
tt.melee.attacks[4].sound = "HeroReinforcementJump"
tt.melee.attacks[4].xp_from_skill = "fissure"
--#endregion
--#region plant_magic_blossom
tt = RT("plant_magic_blossom", "decal_scripted")

AC(tt, "custom_attack", "ui", "plant")

tt.custom_attack.cooldown = 30
tt.custom_attack.range = 200
tt.custom_attack.bullet = "bolt_plant_magic_blossom"
tt.custom_attack.bullet_count = 8
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.bullet_start_offset = vec_2(0, 55)
tt.custom_attack.sound = "ElvesPlantMissile"
tt.custom_attack.shoot_time = fts(6)
tt.render.sprites[1].prefix = "plant_magic_blossom"
tt.render.sprites[1].name = "loading"
tt.render.sprites[1].anchor.y = 0.0641025641025641
tt.main_script.update = scripts.plant_magic_blossom.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-24, -5, 48, 78)
--#endregion
--#region plant_poison_pumpkin
tt = RT("plant_poison_pumpkin", "decal_scripted")

AC(tt, "custom_attack", "ui", "plant", "editor")

tt.custom_attack.cooldown = 25
tt.custom_attack.range = 170
tt.custom_attack.mods = {"mod_plant_poison_pumpkin_slow", "mod_plant_poison_pumpkin"}
tt.custom_attack.vis_flags = bor(F_RANGED, F_POISON)
tt.custom_attack.sound = "VenomPlantDischarge"
tt.main_script.update = scripts.plant_poison_pumpkin.update
tt.render.sprites[1].prefix = "plant_poison_pumpkin"
tt.render.sprites[1].name = "loading"
tt.render.sprites[1].anchor.y = 0.0641025641025641
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-30, -5, 60, 54)
--#endregion
--#region crystal_arcane
tt = RT("crystal_arcane", "decal_scripted")

AC(tt, "attacks", "ui", "crystal", "editor", "tween")

tt.main_script.update = scripts.crystal_arcane.update
tt.attacks.cooldown = math.floor(19.148936170212767) * 47 / 30
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "lightning"
tt.attacks.list[1].bullet = "ray_crystal_arcane"
tt.attacks.list[1].bullet_count = 5
tt.attacks.list[1].chance = 0.3
tt.attacks.list[1].range = 195
tt.attacks.list[1].sound = "ElvesCrystalRay"
tt.attacks.list[1].bullet_start_offset = vec_2(0, 40)
tt.attacks.list[2] = CC("aura_attack")
tt.attacks.list[2].animations = {"freeze_start", "freeze_loop", "freeze_end"}
tt.attacks.list[2].aura = "aura_crystal_arcane_freeze"
tt.attacks.list[2].chance = 0.4
tt.attacks.list[2].range = 195
tt.attacks.list[2].hit_time = fts(15)
tt.attacks.list[2].duration = math.floor(8) * 15 / 30
tt.attacks.list[2].sound = "ElvesCrystalIce"
tt.attacks.list[2].fx_center = "decal_crystal_arcane_freeze_center"
tt.attacks.list[2].fxs = {"decal_crystal_arcane_freeze_1", "decal_crystal_arcane_freeze_2"}
tt.attacks.list[3] = CC("aura_attack")
tt.attacks.list[3].animation = "buff"
tt.attacks.list[3].mod = "mod_crystal_arcane_buff"
tt.attacks.list[3].mod_soldier = "mod_crystal_arcane_buff_soldier"
tt.attacks.list[3].chance = 0.3
tt.attacks.list[3].hit_time = fts(30)
tt.attacks.list[3].range = 225
tt.attacks.list[3].sound = "ElvesCrystalBuff"
tt.attacks.list[3].tower_count = 1
tt.attacks.list[3].fx_base = "fx_crystal_arcane_buff"
tt.attacks.list[3].excluded_templates = {}

for i = 1, 11 do
	local s = CC("sprite")

	s.prefix = "crystal_arcane_layer" .. i
	s.name = "loading"
	s.anchor.y = 0.38461538461538464
	tt.render.sprites[i] = s
end

tt.tween.remove = false
tt.tween.props[1].keys_loading = {{0, 0}, {fts(23), 255}, {fts(47), 0}}
tt.tween.props[1].keys_ready = {{0, 0}, {fts(15), 255}}
tt.tween.props[1].keys_lightning = {{0, 0}, {fts(10), 200}, {fts(34), 0}}
tt.tween.props[1].keys_freeze = {{0, 0}, {fts(13), 255}, {fts(16), 0}}
tt.tween.props[1].keys_buff = {{0, 0}, {fts(24), 255}, {fts(45), 0}}
tt.tween.props[1].keys = tt.tween.props[1].keys_loading
tt.tween.props[1].loop = true
tt.tween.props[1].sprite_id = 2
tt.ui.click_rect = r(-30, -15, 60, 55)
tt.ui.can_select = false
--#endregion
--#region crystal_unstable
tt = RT("crystal_unstable", "decal_scripted")

AC(tt, "attacks", "crystal", "editor")

tt.main_script.update = scripts.crystal_unstable.update
tt.attacks.cooldown = 15
tt.attacks.list[1] = CC("mod_attack")
tt.attacks.list[1].animation = "teleport"
tt.attacks.list[1].cast_time = fts(26)
tt.attacks.list[1].chance = 0.3
tt.attacks.list[1].good_chance = 0.5
tt.attacks.list[1].max_count = 5
tt.attacks.list[1].max_nodes = 20
tt.attacks.list[1].min_count = 3
tt.attacks.list[1].min_nodes = 10
tt.attacks.list[1].mod = "mod_crystal_unstable_teleport"
tt.attacks.list[1].range = 125
tt.attacks.list[1].vis_flags = bor(F_TELEPORT, F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_BOSS)
tt.attacks.list[2] = CC("mod_attack")
tt.attacks.list[2].allowed_templates = {"enemy_gnoll_reaver", "enemy_gnoll_burner"}
tt.attacks.list[2].mod = "mod_crystal_unstable_infuse"
tt.attacks.list[2].animation = "infuse"
tt.attacks.list[2].cast_time = fts(26)
tt.attacks.list[2].chance = 0.3
tt.attacks.list[2].good_chance = 0.5
tt.attacks.list[2].max_count = 3
tt.attacks.list[2].min_count = 3
tt.attacks.list[2].range = 175
tt.attacks.list[2].vis_flags = bor(F_RANGED)
tt.attacks.list[3] = CC("mod_attack")
tt.attacks.list[3].mod = "mod_crystal_unstable_heal"
tt.attacks.list[3].animation = "heal"
tt.attacks.list[3].cast_time = fts(26)
tt.attacks.list[3].chance = 0.4
tt.attacks.list[3].aura_range = 75
tt.attacks.list[3].max_count = 6
tt.attacks.list[3].min_count = 4
tt.attacks.list[3].range = 175
tt.attacks.list[3].sound = "ElvesUnstableCrystalHealing"
tt.attacks.list[3].trigger_hp_factor = 0.99
tt.attacks.list[3].vis_flags = bor(F_RANGED)
tt.attacks.list[3].vis_bans = bor(F_BOSS)

for i = 1, 4 do
	local s = CC("sprite")

	s.prefix = "crystal_unstable_layer" .. i
	s.name = "loading"
	s.anchor.y = 0.18828451882845187
	tt.render.sprites[i] = s
end

--#endregion
--#region paralyzing_tree
tt = RT("paralyzing_tree", "decal_scripted")

AC(tt, "custom_attack", "ui", "plant")

tt.render.sprites[1].anchor.y = 0.31976744186046513
tt.render.sprites[1].prefix = "paralyzing_tree"
tt.render.sprites[1].name = "loading"
tt.main_script.update = scripts.paralyzing_tree.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, -5, 80, 80)
tt.custom_attack.cooldown = 15
tt.custom_attack.range = 160
tt.custom_attack.vis_flags = bor(F_RANGED, F_STUN)
tt.custom_attack.vis_bans = bor(F_BOSS)
tt.custom_attack.shoot_time = fts(6)
tt.custom_attack.animation = "shoot"
tt.custom_attack.mod = "mod_paralyzing_tree"
--#endregion
--#region mod_paralyzing_tree
tt = RT("mod_paralyzing_tree", "mod_stun")
tt.modifier.duration = 4
tt.render.sprites[1].prefix = "mod_paralyzing_tree"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
--#endregion
--#region fx_paralyzing_tree_1
tt = RT("fx_paralyzing_tree_1", "fx")
tt.render.sprites[1].name = "fx_paralyzing_tree_1"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_paralyzing_tree_2
tt = RT("fx_paralyzing_tree_2", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_2"
--#endregion
--#region fx_paralyzing_tree_3
tt = RT("fx_paralyzing_tree_3", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_3"
--#endregion
--#region bolt_elves_1
tt = RT("bolt_elves_1", "bolt_elves")
tt.alter_reality_chance = 0.1
tt.alter_reality_mod = "mod_teleport_mage"
tt.bullet.damage_min = 4
tt.bullet.damage_max = 6
tt.bullet.particles_name = "ps_bolt_elves_1"
tt.render.sprites[1].scale = vec_2(0.8, 0.8)
--#endregion
--#region bolt_elves_2
tt = RT("bolt_elves_2", "bolt_elves_1")
tt.bullet.damage_min = 9
tt.bullet.damage_max = 15
tt.bullet.particles_name = "ps_bolt_elves_2"
tt.render.sprites[1].scale = vec_2(0.9, 0.9)
--#endregion
--#region bolt_elves_3
tt = RT("bolt_elves_3", "bolt_elves_1")
tt.bullet.damage_min = 17
tt.bullet.damage_max = 28
tt.bullet.particles_name = "ps_bolt_elves_3"
tt.render.sprites[1].scale = vec_2(1, 1)
--#endregion
--#region arrow_soldier_barrack_2
tt = RT("arrow_soldier_barrack_2", "arrow")
tt.bullet.damage_max = 7
tt.bullet.damage_min = 3
tt.bullet.flight_time = fts(15)
tt.bullet.reset_to_target_pos = true
--#endregion
--#region arrow_soldier_barrack_3
tt = RT("arrow_soldier_barrack_3", "arrow_soldier_barrack_2")
tt.bullet.damage_max = 12
tt.bullet.damage_min = 8
--#endregion
--#region arrow_soldier_re_2
tt = RT("arrow_soldier_re_2", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 6
tt.bullet.reset_to_target_pos = true
tt.bullet.flight_time = fts(13)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_arrow_soldier_re_hit"
tt.bullet.miss_decal = "reinforce_proy_0010"
tt.bullet.rotation_speed = 40 * FPS * math.pi / 180
tt.render.sprites[1].name = "reinforce_proy_0001"
--#endregion
--#region arrow_soldier_re_3
tt = RT("arrow_soldier_re_3", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
--#endregion
--#region arrow_soldier_re_4
tt = RT("arrow_soldier_re_4", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
--#endregion
--#region arrow_soldier_re_5
tt = RT("arrow_soldier_re_5", "arrow_soldier_re_2")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
--#endregion
--#region bullet_bravebark_seed
tt = RT("bullet_bravebark_seed", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(22)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bravebark_hero_mignonSeed"
--#endregion
--#region catha_fury
tt = RT("catha_fury", "bullet")
tt.animations = {
	loop = "dashLoop",
	start = "dashStart",
	attack = "dashHit"
}
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.max_speed = 240
tt.bullet.min_speed = 210
tt.bullet.mod = "mod_catha_curse"
tt.lead_time = fts(12)
tt.main_script.insert = scripts.bullet_illusion.insert
tt.main_script.update = scripts.bullet_illusion.update
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[1].name = "dashStart"
tt.render.sprites[1].prefix = "hero_catha"
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.hit = "ElvesHeroCathaFuryHit"
--#endregion
--#region knife_soldier_catha
tt = RT("knife_soldier_catha", "knife_catha")
tt.bullet.xp_gain_factor = nil
tt.bullet.mod = "mod_soldier_catha_curse"
--#endregion
--#region fireball_veznan_demon
tt = RT("fireball_veznan_demon", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_radius = 40
tt.bullet.damage_max = nil
tt.bullet.damage_mix = nil
tt.bullet.mod = "mod_veznan_demon_fire"
tt.bullet.node_prediction = nil
tt.bullet.flight_time = fts(12)
tt.bullet.particles_name = "ps_fireball_veznan_demon"
tt.bullet.hit_fx_air = "fx_fireball_veznan_demon_hit_air"
tt.bullet.hit_fx = "fx_fireball_veznan_demon_hit"
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = scripts.fireball.update
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.x = 0.7352941176470589
tt.render.sprites[1].name = "fireball_veznan_demon"
tt.sound_events.insert = "ElvesHeroVeznanDemonFireballThrow"
tt.sound_events.hit = "ElvesHeroVeznanDemonFireballHit"
--#endregion
--#region ray_rag
tt = RT("ray_rag", "bullet")
tt.image_width = 164
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_rag"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_rag_raggified"
--#endregion
--#region bullet_kamihare
tt = RT("bullet_kamihare", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(17)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.g = -1.25 / (fts(1) * fts(1))
tt.bullet.rotation_speed = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bullet_kamihare"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.20512820512820512
--#endregion
--#region ray_durax
tt = RT("ray_durax", "bullet")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_ray_durax_hit"
tt.bullet.hit_time = fts(5)
tt.image_width = 164
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_durax"
tt.sound_events.insert = "ElvesHeroDuraxLethalPrismShoot"
--#endregion
--#region spear_durax
tt = RT("spear_durax", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.flight_time = fts(16)
tt.bullet.hide_radius = 1
tt.bullet.hit_fx = "fx_shardseed_hit"
tt.bullet.miss_decal = "durax_hero_proy_0002-f"
tt.bullet.miss_decal_anchor = vec_2(1, 0.5)
tt.bullet.predict_target_pos = true
tt.bullet.reset_to_target_pos = true
tt.bullet.xp_gain_factor = 0.35
tt.render.sprites[1].anchor.x = 0.8214285714285714
tt.render.sprites[1].name = "durax_hero_proy_0001-f"
tt.sound_events.insert = "ElvesHeroDuraxShardSpearThrow"
--#endregion
--#region spear_durax_clone
tt = RT("spear_durax_clone", "spear_durax")
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_color = {0, 1, 1, 1}
}
--#endregion

--#region torch_gnoll_burner
tt = RT("torch_gnoll_burner", "arrow")
tt.bullet.mod = "mod_gnoll_burner"
tt.bullet.damage_max = 6
tt.bullet.damage_min = 2
tt.bullet.hit_blood_fx = nil
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
tt.bullet.pop = nil
tt.bullet.miss_decal = nil
tt.bullet.flight_time = fts(12)
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = "fx_torch_gnoll_burner_explosion"
tt.bullet.miss_fx = "fx_torch_gnoll_burner_explosion"
tt.render.sprites[1].name = "torch_gnoll_burner"
tt.render.sprites[1].animated = true
tt.render.sprites[1].r = math.pi
--#endregion
--#region bullet_gnoll_blighter
tt = RT("bullet_gnoll_blighter", "bullet")
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.15625
tt.render.sprites[1].prefix = "gnoll_blighter_energy"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.travel = {"travel", "travelUp", "travelDown"}
tt.render.sprites[1].angles_stickiness = {
	travel = 10
}
tt.bullet.hit_fx = "fx_bolt_gnoll_blighter_hit"
tt.bullet.damage_max = 75
tt.bullet.damage_min = 50
tt.bullet.min_speed = 60
tt.bullet.max_speed = 240
tt.bullet.acceleration_factor = 0.1
tt.main_script.update = scripts.bullet_gnoll_blighter.update
tt.sound_events.insert = "BoltSorcererSound"
--#endregion
--#region arrow_twilight_elf_harasser
tt = RT("arrow_twilight_elf_harasser", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.main_script.insert = scripts.arrow_twilight_elf_harasser.insert
tt.flight_time_range = {fts(15), fts(26)}
tt.bullet.predict_target_pos = false
--#endregion
--#region arrow_twilight_elf_harasser_shadowshot
tt = RT("arrow_twilight_elf_harasser_shadowshot", "arrow")
tt.bullet.damage_max = 35
tt.bullet.damage_min = 25
tt.bullet.predict_target_pos = false
--#endregion
--#region knife_satyr
tt = RT("knife_satyr", "arrow")
tt.render.sprites[1].name = "satyr_knife_0001-f"
tt.render.sprites[1].animated = false
tt.bullet.asymmetrical = true
tt.bullet.damage_min = 4
tt.bullet.damage_max = 7
tt.bullet.flight_time = fts(10)
tt.bullet.g = -0.7 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_knife_satyr_hit"
tt.bullet.miss_decal = "satyr_knife_0002-f"
tt.bullet.pop = nil
tt.bullet.predict_target_pos = false
--#endregion
--#region bullet_twilight_evoker
tt = RT("bullet_twilight_evoker", "arrow")
tt.bullet.damage_min = 18
tt.bullet.damage_max = 27
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.predict_target_pos = false
tt.bullet.particles_name = "ps_bullet_twilight_evoker"
tt.bullet.hit_fx = "fx_bullet_twilight_evoker_hit"
tt.bullet.miss_fx = "fx_bullet_twilight_evoker_hit"
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt.bullet.flight_time = fts(18)
tt.bullet.pop = nil
tt.render.sprites[1].name = "twilight_evoker_bolt_0001"
--#endregion
--#region bullet_twilight_heretic
tt = RT("bullet_twilight_heretic", "bolt_enemy")
tt.bullet.damage_min = 60
tt.bullet.damage_max = 80
tt.bullet.min_speed = 60
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_bullet_twilight_heretic"
tt.bullet.hit_fx = "fx_bullet_twilight_heretic_hit"
tt.render.sprites[1].prefix = nil
tt.render.sprites[1].name = "twilight_heretic_proy_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "BoltSorcererSound"
--#endregion
--#region bullet_arachnomancer_spawn
tt = RT("bullet_arachnomancer_spawn", "bomb")

AC(tt, "nav_path")

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(17)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.rotation_speed = 0
tt.bullet.y = -1.25 / (fts(1) * fts(1))
tt.sound_events.insert = "ElvesCreepArachnomancerSpiderSpawn"
tt.sound_events.hit = nil
tt.render.sprites[1].name = "arachnomancer_spider_0054"
tt.render.sprites[1].anchor.y = 0.15625
tt.main_script.insert = scripts.bullet_arachnomancer_spawn.insert
tt.payload_entity = "enemy_spider_arachnomancer"
--#endregion
--#region rock_perython
tt = RT("rock_perython", "bullet")
tt.render.sprites[1].prefix = "perython_rock"
tt.render.sprites[1].name = "drop"
tt.main_script.update = scripts.rock_perython.update
tt.bullet.damage_min = 75
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 75
tt.bullet.hit_fx = "fx_rock_explosion"
tt.bullet.hit_decal = "decal_rock_crater"
tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
--#endregion
--#region bolt_ogre_magi
tt = RT("bolt_ogre_magi", "bolt_enemy")
tt.bullet.damage_max = 72
tt.bullet.damage_min = 48
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_bolt_ogre_magi_hit"
tt.bullet.hit_fx_ignore_offset = true
tt.bullet.hit_fx_air = "fx_bolt_ogre_magi_hit_air"
tt.bullet.ignore_rotation = false
tt.bullet.max_speed = 540
tt.bullet.min_speed = 60
tt.render.sprites[1].prefix = "ogre_mage_proy"
tt.render.sprites[1].name = "flying"
tt.sound_events.insert = "BoltSorcererSound"
--#endregion
--#region bullet_dark_spitters
tt = RT("bullet_dark_spitters", "arrow")
tt.bullet.damage_min = 48
tt.bullet.damage_max = 72
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = nil
tt.bullet.mod = "mod_dark_spitters"
tt.bullet.miss_fx = "fx_bullet_dark_spitters_miss"
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt.bullet.flight_time = fts(12)
tt.bullet.pop = nil
tt.render.sprites[1].name = "dark_spitters_proy"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "ElvesDarkSpitterSpit"
--#endregion
--#region bullet_balrog
tt = RT("bullet_balrog", "bomb")
tt.bullet.align_with_trajectory = true
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_bans = bor(F_ENEMY, F_FRIEND)
tt.bullet.hit_fx = "fx_bullet_balrog_hit"
tt.bullet.hit_decal = "aura_bullet_balrog"
tt.bullet.flight_time_base = fts(3)
tt.bullet.flight_time_factor = fts(0.04)
tt.bullet.particles_name = "ps_bullet_balrog"
tt.render.sprites[1].name = "bullet_balrog"
tt.render.sprites[1].animated = true
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.sound_events.insert = nil
tt.sound_events.hit = "ElvesBalrogBloodpool"
--#endregion

--#region bullet_catapult_endless_rock
tt = RT("bullet_catapult_endless_rock", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0001"
tt.bullet.damage_max = 100
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_rock_explosion"
--#endregion
--#region bullet_catapult_endless_spiked
tt = RT("bullet_catapult_endless_spiked", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0002"
tt.bullet.damage_max = 200
tt.bullet.damage_min = 200
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_spiked_explosion"
--#endregion
--#region bullet_catapult_endless_bomb
tt = RT("bullet_catapult_endless_bomb", "rock_enemy_catapult")
tt.render.sprites[1].name = "bullet_catapult_endless_bomb"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = 300
tt.bullet.damage_min = 300
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_bomb_explosion"
--#endregion
--#region bullet_catapult_endless_barrel
tt = RT("bullet_catapult_endless_barrel", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0003"
tt.bullet.hit_fx = "fx_bullet_catapult_endless_barrel_explosion"
--#endregion
--#region bolt_plant_magic_blossom
tt = RT("bolt_plant_magic_blossom", "bolt_elves")
tt.render.sprites[1].prefix = "bolt_plant_magic_blossom"
tt.bullet.max_speed = 390
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = 15
tt.bullet.damage_max = 30
tt.bullet.hit_fx = "fx_bolt_plant_magic_blossom_hit"
tt.bullet.particles_name = "ps_bolt_plant_magic_blossom"
tt.bullet.align_with_trajectory = true
tt.initial_impulse = 12000
tt.initial_impulse_duration = 0.15
tt.upgrades_disabled = true
--#endregion
--#region ray_crystal_arcane
tt = RT("ray_crystal_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_crystal_arcane"
tt.bullet.hit_time = fts(4)
tt.image_width = 92
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_crystal_arcane"
--#endregion
--#region aura_enervation_faustus
tt = RT("aura_enervation_faustus", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_enervation_faustus"
tt.aura.cycle_time = 0
tt.aura.cycles = 1
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_RANGED, F_SPELLCASTER)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO)
tt.aura.targets_per_cycle = nil
--#endregion
--#region aura_baby_malik_fissure
tt = RT("aura_baby_malik_fissure", "aura")
tt.aura.fx = "decal_baby_malik_earthquake"
tt.aura.damage_radius = nil
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.vis_flags = bor(F_RANGED, F_STUN)
tt.aura.spread_delay = fts(4)
tt.aura.spread_nodes = 4
tt.main_script.update = scripts.aura_baby_malik_fissure.update
tt.stun = {}
tt.stun.vis_flags = bor(F_RANGED, F_STUN)
tt.stun.vis_bans = bor(F_FLYING, F_BOSS)
tt.stun.mod = "mod_baby_malik_stun"
--#endregion

--#region aura_bruce_hps
tt = RT("aura_bruce_hps", "aura")

AC(tt, "hps")

tt.aura.duration = -1
tt.main_script.update = scripts.aura_bruce_hps.update
tt.hps.heal_max = 3
tt.hps.heal_every = 1
--#endregion
--#region aura_bomb_wilbur
tt = RT("aura_bomb_wilbur", "aura_rabbit_kamihare")
tt.aura.damage_min = 110
tt.aura.damage_max = 155
tt.aura.radius = 35
tt.sound_events.insert = "BombExplosionSound"
--#endregion
--#region aura_bobbing_wilbur
tt = RT("aura_bobbing_wilbur", "aura")
tt.aura.duration = -1
tt.main_script.update = scripts.aura_wilbur_bobbing.update
--#endregion
--#region aura_box_wilbur
tt = RT("aura_box_wilbur", "decal_scripted")
AC(tt, "spawner", "sound_events")
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].name = "box_wilbur_open"
tt.render.sprites[1].loop = false
tt.spawner.entity = "bomb_wilbur"
tt.spawner.spawn_time = fts(10)
tt.spawner.count = nil
tt.sound_events.insert = "ElvesHeroGyroBoombBoxTouchdown"
tt.main_script.update = scripts.aura_box_wilbur.update
--#endregion
--#region aura_gnoll_gnawer
tt = RT("aura_gnoll_gnawer", "aura")
tt.main_script.update = scripts.aura_gnoll_gnawer.update
tt.min_count = 4
tt.aura.radius = 100
tt.aura.cycle_time = 0.25
tt.aura.mod = "mod_gnoll_gnawer"
tt.aura.vis_flags = F_RANGED
--#endregion
--#region aura_ettin_regen
tt = RT("aura_ettin_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt.regen.cooldown = fts(5)
tt.regen.health = 4
--#endregion
--#region aura_bandersnatch_spines
tt = RT("aura_bandersnatch_spines", "aura")
tt.main_script.update = scripts.aura_bandersnatch_spines.update
tt.aura.radius = 125
tt.aura.damage_max = 200
tt.aura.damage_min = 140
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.hit_fx = "fx_bandersnatch_spines_blood"
tt.spines_count = 27
--#endregion
--#region aura_boomshrooms_death
tt = RT("aura_boomshrooms_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = {40, 40, 40, 50}
tt.aura.damage_max = {40, 40, 40, 60}
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 87.5
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
--#endregion
--#region aura_razorboar_rage
tt = RT("aura_razorboar_rage", "aura")
tt.main_script.update = scripts.aura_razorboar_rage.update
tt.main_script.insert = scripts.aura_razorboar_rage.insert
tt.main_script.remove = scripts.aura_razorboar_rage.remove
tt.damage_hp_factor = 1
tt.aura.track_source = true
--#endregion
--#region aura_spider_sprint
tt = RT("aura_spider_sprint", "aura")

AC(tt, "editor", "editor_script")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_spider_sprint"
tt.aura.cycle_time = fts(10)
tt.aura.allowed_templates = {"enemy_drider", "enemy_spider_tarantula", "enemy_spider_arachnomancer", "enemy_spider_son_of_mactans", "enemy_sword_spider", "enemy_webspitting_spider"}
tt.editor.components = {"render"}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_red_circle"
}
tt.editor.props = {{"aura.radius", PT_NUMBER}}
tt.editor_script.update = scripts.editor_aura_spider_sprint.update
--#endregion
--#region aura_mactans_path_web
tt = RT("aura_mactans_path_web", "aura")
tt.main_script.update = scripts.aura_mactans_path_web.update
tt.steps_count = 5
tt.steps_count_auras = 4
tt.step_nodes = 4
tt.step_delay = fts(7)
tt.fade_duration = fts(10)
tt.aura.duration = nil
tt.aura.radius = 63
tt.aura.vis_flags = bor(F_NET, F_STUN)
tt.aura.vis_bans = bor(F_FLYING)
tt.pi = nil
tt.ni = nil
--#endregion
--#region aura_eb_spider_path_web
tt = RT("aura_eb_spider_path_web", "aura_mactans_path_web")
tt.steps_count = 3
tt.steps_count_auras = 2
tt.step_delay = fts(0.5)
tt.aura.duration = 5
tt.fade_duration = fts(3)
--#endregion
--#region aura_ogre_magi_regen
tt = RT("aura_ogre_magi_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(5)
tt.regen.health = 5
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
--#endregion
--#region aura_ogre_magi_shield
tt = RT("aura_ogre_magi_shield", "aura")

AC(tt, "render")

tt.aura.cast_resets_sprite_id = 2
tt.aura.cycle_time = 1.5
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_ogre_magi_shield"
tt.aura.radius = 100
tt.aura.requires_magic = true
tt.aura.source_vis_flags = F_RANGED
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.excluded_templates = {"enemy_ogre_magi"}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.fx_cooldown = fts(10)
tt.last_fx_ts = 0
tt.render.sprites[1].name = "ogre_mage_shield_damage"
tt.render.sprites[1].loop = false
tt.render.sprites[1].ts = -10
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "ogre_mage_aura"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].loop = false
--#endregion
--#region aura_shadow_champion_death
tt = RT("aura_shadow_champion_death", "aura")
tt.main_script.update = scripts.aura_shadow_champion_death.update
tt.aura.radius = 80
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.enemy_mod = "mod_shadow_champion"
tt.aura.soldier_mod = "mod_dark_spitters"
tt.aura.include_enemies = {"enemy_shadows_spawns", "enemy_dark_spitters", "enemy_grim_devourers"}
--#endregion
--#region aura_bullet_balrog
tt = RT("aura_bullet_balrog", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 10
tt.aura.mod = "mod_balrog"
tt.aura.radius = 50
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.aura.vis_flags = bor(F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "balrog_aura_loop"
tt.render.sprites[1].anchor.y = 0.41818181818181815
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "balrog_aura_bubble_pop"
tt.render.sprites[2].loop = true
tt.tween.props[1].keys = {{0, 0}, {fts(12), 255}, {10, 255}, {10.5, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.42)}, {fts(12), vec_1(1)}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(0, -10)}, {fts(55), vec_2(30, -20)}, {fts(110), vec_2(35, -5)}, {fts(165), vec_2(-35, -8)}, {fts(220), vec_2(25, -20)}, {fts(275), vec_2(-30, -20)}}
tt.tween.props[3].loop = true
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].interp = "step"
tt.tween.remove = false
--#endregion
--#region aura_twilight_brute
tt = RT("aura_twilight_brute", "aura")

AC(tt, "render")

tt.aura.cycle_time = fts(10)
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_twilight_brute"
tt.aura.radius = 60
tt.aura.requires_magic = false
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "aura_twilight_bannerbearer"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor.y = 0.33783783783783783
--#endregion
--#region aura_crystal_arcane_freeze
tt = RT("aura_crystal_arcane_freeze", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_crystal_arcane_freeze"
tt.aura.radius = 195
tt.aura.cycles_count = 1
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
--#endregion
--#region mod_teleport_mage
tt = RT("mod_teleport_mage", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.max_times_applied = 2
tt.nodes_offset = -20
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.34
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_violet"
tt.fx_end = "fx_teleport_violet"
--#endregion
--#region mod_teleport_wild_magus
tt = RT("mod_teleport_wild_magus", "mod_teleport_mage")
tt.fx_start = "fx_teleport_orange"
tt.fx_end = "fx_teleport_orange"
--#endregion
--#region mod_teleport_high_elven
tt = RT("mod_teleport_high_elven", "mod_teleport_mage")
tt.fx_start = "fx_teleport_blue"
tt.fx_end = "fx_teleport_blue"
--#endregion
--#region mod_blood_elves
tt = RT("mod_blood_elves", "mod_blood")
tt.modifier.allows_duplicates = true
tt.modifier.max_of_same = 5
tt.modifier.source_damage = nil
tt.modifier.type = MOD_TYPE_BLEED
tt.chance = 0.15
tt.damage_factor = 0.1
tt.dps.damage_every = fts(4)
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.fx_every = fts(12)
tt.main_script.insert = scripts.mod_blood_elves.insert
--#endregion
--#region mod_shocking_impact
tt = RT("mod_shocking_impact", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.5

for _, n in pairs({"barrack_1", "barrack_2", "barrack_3", "blade", "forest", "drow"}) do
	--#endregion
	--#region mod_moon_forged_blades_" .. n, "mod_damage
	tt = RT("mod_moon_forged_blades_" .. n, "mod_damage")
	tt.damage_max = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_min)
	tt.damage_min = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_max)
	tt.damage_type = DAMAGE_MAGICAL
end

--#endregion
--#region eldritch_enemy_decal
tt = RT("eldritch_enemy_decal", "decal_tween")
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {}

for i, s in ipairs({
	1.06,
	1.02,
	1.11,
	1.05,
	1.14,
	1.08,
	1.116,
	1.1,
	1.18,
	1.13,
	1.24
}) do
	tt.tween.props[1].keys[i] = {(i - 1) * fts(2), vec_2(s, s)}
end

--#endregion
--#region mod_ward
tt = RT("mod_ward", "modifier")

AC(tt, "render", "tween")

tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.allows_duplicates = true
tt.modifier.duration = 10
tt.modifier.use_mod_offset = false
tt.modifier.remove_banned = true
tt.modifier.bans = {"mod_twilight_evoker_heal", "mod_twilight_heretic_consume", "mod_gnoll_boss", "mod_shadow_champion"}
tt.render.sprites[1].name = "mage_wild_silence_fx"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_ward_decal"
tt.render.sprites[2].animated = true
tt.render.sprites[2].scale = vec_2(1, 0.4)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "mage_wild_silence_decal_glow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {tt.modifier.duration - 0.25, 255}, {tt.modifier.duration, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.custom_offsets = {}
tt.custom_offsets.default = vec_2(0, 40)
tt.custom_offsets.enemy_arachnomancer = vec_2(0, 41)
tt.custom_offsets.enemy_bloodsydian_warlock = vec_2(0, 73)
tt.custom_offsets.enemy_ettin = vec_2(0, 60)
tt.custom_offsets.enemy_gnoll_blighter = vec_2(0, 39)
tt.custom_offsets.enemy_gnoll_bloodsydian = vec_2(0, 39)
tt.custom_offsets.enemy_gnoll_reaver = vec_2(0, 39)
tt.custom_offsets.enemy_hyena = vec_2(0, 20)
tt.custom_offsets.enemy_ogre_magi = vec_2(0, 78)
tt.custom_offsets.enemy_razorboar = vec_2(0, 53)
tt.custom_offsets.enemy_satyr_cutthroat = vec_2(0, 39)
tt.custom_offsets.enemy_satyr_hoplite = vec_2(0, 55)
tt.custom_offsets.enemy_shroom_breeder = vec_2(0, 67)
tt.custom_offsets.enemy_spider_arachnomancer = vec_2(0, 39)
tt.custom_offsets.enemy_sword_spider = vec_2(0, 39)
tt.custom_offsets.enemy_twilight_avenger = vec_2(0, 47)
tt.custom_offsets.enemy_twilight_elf_harasser = vec_2(0, 39)
tt.custom_offsets.enemy_twilight_evoker = vec_2(0, 47)
tt.custom_offsets.enemy_twilight_golem = vec_2(0, 80)
tt.custom_offsets.enemy_twilight_heretic = vec_2(0, 45)
tt.custom_offsets.enemy_twilight_scourger = vec_2(0, 40)
tt.custom_offsets.enemy_zealot = vec_2(0, 39)
tt.custom_offsets.eb_drow_queen = vec_2(0, 40)
tt.custom_offsets.eb_spider = vec_2(0, 87)
tt.custom_offsets.enemy_blood_servant = vec_2(0, 35)
tt.custom_offsets.enemy_grim_devourers = vec_2(0, 39)
tt.custom_offsets.enemy_mounted_avenger = vec_2(0, 63)
tt.custom_offsets.enemy_shadow_champion = vec_2(0, 55)
tt.custom_offsets.enemy_shadows_spawns = vec_2(0, 34)
--#endregion
--#region mod_druid_sylvan_affected
tt = RT("mod_druid_sylvan_affected", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(18)
tt.render.sprites[1].prefix = "mod_druid_sylvan_affected"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
--#endregion
--#region mod_plant_poison_pumpkin_slow
tt = RT("mod_plant_poison_pumpkin_slow", "mod_slow")
tt.modifier.duration = 4
tt.slow.factor = 0.5
--#endregion
--#region mod_plant_poison_pumpkin
tt = RT("mod_plant_poison_pumpkin", "mod_poison")
tt.render.sprites[1].prefix = "poison_violet"
tt.render.sprites[1].size_names = {"small", "medium", "big"}
tt.modifier.duration = 4
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.kill = true
tt.dps.damage_every = fts(3)
tt.dps.damage_type = DAMAGE_POISON
--#endregion
--#region mod_enervation_faustus
tt = RT("mod_enervation_faustus", "modifier")
AC(tt, "render", "tween")
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mod_enervation_faustus"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
--#endregion
--#region mod_liquid_fire_faustus
tt = RT("mod_liquid_fire_faustus", "modifier")
AC(tt, "dps", "render")
tt.dps.damage_max = nil
tt.dps.damage_min = nil
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(6)
tt.dps.kill = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 1
tt.render.sprites[1].prefix = "mod_liquid_fire_faustus"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].draw_order = 10
--#endregion
--#region mod_minidragon_faustus
tt = RT("mod_minidragon_faustus", "mod_liquid_fire_faustus")
--#endregion
--#region mod_bravebark_branchball
tt = RT("mod_bravebark_branchball", "modifier")

AC(tt, "render")

tt.main_script.queue = scripts.mod_bravebark_branchball.queue
tt.main_script.update = scripts.mod_bravebark_branchball.update
tt.custom_anchors = {}
tt.custom_anchors.default = vec_2(0.5, 0.45)
tt.render.sprites[1].name = "bravebark_paralyzeRoots"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].anchor.y = 0.22727272727272727
--#endregion
--#region mod_catha_curse
tt = RT("mod_catha_curse", "mod_stun")
tt.main_script.insert = scripts.mod_catha_curse.insert
tt.modifier.vis_bans = bor(F_BOSS)
tt.modifier.vis_flags = bor(F_STUN, F_MOD)
tt.modifier.duration = nil
tt.modifier.resets_same = false
tt.render.sprites[1].keep_flip_x = true
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].prefix = "mod_catha_curse"
tt.render.sprites[1].name = "loop"
tt.chance = 0
tt.xp_from_skill = "curse"
--#endregion
--#region mod_soldier_catha_curse
tt = RT("mod_soldier_catha_curse", "mod_catha_curse")
tt.xp_from_skill = nil
--#endregion
--#region mod_catha_ultimate
tt = RT("mod_catha_ultimate", "mod_catha_curse")
tt.main_script.insert = scripts.mod_stun.insert
tt.modifier.vis_bans = 0
tt.xp_from_skill = nil
--#endregion
--#region mod_catha_soul
tt = RT("mod_catha_soul", "modifier")

AC(tt, "render", "hps")

tt.hps.heal_every = 9e+99
tt.hps.heal_max = nil
tt.hps.heal_min = nil
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(25)
tt.modifier.bans = {"mod_son_of_mactans_poison", "mod_drider_poison", "mod_dark_spitters", "mod_balrog"}
tt.modifier.remove_banned = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "mod_catha_soul"
tt.render.sprites[1].anchor.y = 0.2631578947368421
--#endregion
--#region mod_baby_malik_stun
tt = RT("mod_baby_malik_stun", "mod_stun")
--#endregion
--#region mod_rag_hammer_time_stun
tt = RT("mod_rag_hammer_time_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = F_BOSS
--#endregion
--#region mod_durax_slow
tt = RT("mod_durax_slow", "mod_slow")
tt.modifier.duration = fts(15)
tt.slow.factor = 0.9
--#endregion
--#region mod_durax_stun
tt = RT("mod_durax_stun", "mod_stun")
tt.modifier.duration = fts(20)
tt.modifier.vis_bans = F_BOSS
--#endregion
--#region mod_lilith_angel_stun
tt = RT("mod_lilith_angel_stun", "mod_stun")
tt.modifier.duration = fts(34)
--#endregion
--#region mod_lilith_soul_eater_track
tt = RT("mod_lilith_soul_eater_track", "modifier")
tt.main_script.update = scripts.mod_lilith_soul_eater_track.update
tt.modifier.duration = fts(11)
--#endregion

--#region mod_bruce_sharp_claws
tt = RT("mod_bruce_sharp_claws", "mod_blood_elves")
tt.modifier.allows_duplicates = true
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.duration = 5
tt.main_script.insert = scripts.mod_bruce_sharp_claws.insert
tt.dps.damage_every = fts(11)
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.extra_bleeding_damage = nil
tt.extra_bleeding_damage_type = DAMAGE_RUDE
tt.xp_from_skill = "sharp_claws"
--#endregion
--#region mod_bruce_kings_roar
tt = RT("mod_bruce_kings_roar", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.modifier.health_bar_offset = vec_2(0, -3)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "mod_bruce_kings_roar"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
--#endregion
--#region mod_slow_wilbur
tt = RT("mod_slow_wilbur", "mod_slow")
tt.slow.factor = nil
--#endregion
--#region mod_gnoll_burner
tt = RT("mod_gnoll_burner", "modifier")

AC(tt, "dps", "render", "mark_flags")

tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = fts(12)
tt.dps.kill = true
tt.mark_flags.vis_bans = F_CUSTOM
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 2
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].draw_order = 10
--#endregion
--#region mod_gnoll_gnawer
tt = RT("mod_gnoll_gnawer", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(10)
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gnoll_gnawer"
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region mod_gnoll_blighter
tt = RT("mod_gnoll_blighter", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_gnoll_blighter.update
tt.modifier.duration = 4.9
tt.render.sprites[1].name = "mod_gnoll_blighter"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.28
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 10
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {tt.modifier.duration - 0.3, 255}, {tt.modifier.duration, 0}}
tt.tween.remove = false
--#endregion
--#region mod_twilight_elf_harasser
tt = RT("mod_twilight_elf_harasser", "modifier")

AC(tt, "mark_flags")

tt.mark_flags.vis_bans = F_CUSTOM
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt.modifier.duration = fts(20)
--#endregion
--#region mod_redcap_heal
tt = RT("mod_redcap_heal", "modifier")

AC(tt, "hps")

tt.main_script.insert = scripts.mod_redcap_heal.insert
tt.main_script.update = scripts.mod_hps.update
tt.hps.heal_min = 25
tt.hps.heal_max = 25
tt.hps.heal_every = fts(3)
tt.modifier.duration = 2
tt.hit_fx = "fx_redcap_death_blow"
--#endregion
--#region mod_twilight_scourger_lash
tt = RT("mod_twilight_scourger_lash", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "mod_twilight_scourger_lash"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "scourger_buff_glow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].sort_y_offset = 1
tt.modifier.duration = 5
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_twilight_scourger_lash.insert
tt.main_script.remove = scripts.mod_twilight_scourger_lash.remove
tt.main_script.update = scripts.mod_track_target.update
tt.speed_factor = 1.4
tt.damage_factor = 2
--#endregion
--#region mod_twilight_scourger_banshee
tt = RT("mod_twilight_scourger_banshee", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_twilight_scourger_banshee.update
tt.modifier.hide_tower = false
tt.modifier.duration = 10
tt.render.sprites[1].name = "mod_twilight_scourger_banshee_base"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.05
tt.render.sprites[1].offset.y = -10
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].sort_y_offset = -2
tt.render.sprites[2].anchor = vec_2(0.9545454545454546, 0.5)
tt.render.sprites[2].offset.y = 21
tt.render.sprites[2].name = "mod_twilight_scourger_banshee_fx"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].scale = vec_2(-1, 1)
tt.render.sprites[3].time_offset = fts(6)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset.y = 48
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].scale = vec_2(-1, 1)
tt.render.sprites[5].time_offset = fts(6)
tt.tween.remove = false

for i = 1, 5 do
	local p = CC("tween_prop")

	p.keys = {{0, 0}, {0.2, 255}, {"this.modifier.duration-0.2", 255}, {"this.modifier.duration", 0}}
	p.sprite_id = i
	tt.tween.props[i] = p
end

--#endregion
--#region mod_spider_web
tt = RT("mod_spider_web", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_spider_web.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.modifier.animation_phases = true
tt.modifier.bans = {"mod_dark_spitters"}
tt.modifier.remove_banned = true
tt.modifier.duration = 3
tt.modifier.duration_heroes = 2
tt.modifier.hide_target_delay = fts(5)
tt.modifier.use_mod_offset = false
tt.modifier.type = MOD_TYPE_STUN
tt.modifier.vis_flags = F_STUN
tt.render.sprites[1].prefix = "mod_spider_web"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor = vec_2(0.5, 0.14285714285714285)
tt.modifier.custom_scales = {}
tt.modifier.custom_scales.default = vec_1(0.55)
tt.modifier.custom_scales.hero_elves_denas = vec_1(0.75)
tt.modifier.custom_scales.hero_bravebark = vec_1(1)
tt.modifier.custom_scales.hero_xin = vec_1(1)
tt.modifier.custom_scales.soldier_forest = vec_1(0.75)
tt.modifier.custom_scales.soldier_druid_bear = vec_1(0.75)
--#endregion
--#region mod_mactans_spider_web
tt = RT("mod_mactans_spider_web", "mod_spider_web")
tt.modifier.duration = 5
tt.modifier.duration_heroes = 3
--#endregion
--#region mod_twilight_evoker_silence
tt = RT("mod_twilight_evoker_silence", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_tower_silence.update
tt.modifier.duration = 4
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.render.sprites[1].name = "mod_twilight_evoker_silence_1"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "mod_twilight_evoker_silence_2"
tt.render.sprites[2].draw_order = 10
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].offset.y = 0
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.custom_offsets = {}
tt.custom_offsets.tower_high_elven = vec_2(0, 50)
tt.custom_offsets.tower_wild_magus = vec_2(0, 50)
tt.custom_offsets.tower_entwood = vec_2(0, 40)
tt.custom_offsets.tower_druid = vec_2(0, 55)
--#endregion
--#region mod_twilight_evoker_heal
tt = RT("mod_twilight_evoker_heal", "modifier")

AC(tt, "hps", "render")

tt.modifier.duration = 1
tt.modifier.allows_duplicates = true
tt.hps.heal_min = 16
tt.hps.heal_max = 16
tt.hps.heal_every = 0.2
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].prefix = "mod_twilight_evoker_heal"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].loop = false
--#endregion
--#region mod_twilight_heretic_consume
tt = RT("mod_twilight_heretic_consume", "modifier")

AC(tt, "render")

tt.modifier.duration = 3
tt.render.sprites[1].name = "twilight_heretic_fire"
tt.render.sprites[1].anchor.y = 0.17567567567567569
tt.render.sprites[1].sort_y_offset = 1
tt.speed_factor = 1.9
tt.mod_offset_y = 7
tt.health_bar_offset_y = 4
tt.nodes_limit = 45
tt.angles_walk = {"flyingRightLeft", "flyingUp", "flyingDown"}
tt.main_script.insert = scripts.mod_twilight_heretic_consume.insert
tt.main_script.remove = scripts.mod_twilight_heretic_consume.remove
tt.main_script.update = scripts.mod_twilight_heretic_consume.update
--#endregion
--#region mod_twilight_heretic_servant
tt = RT("mod_twilight_heretic_servant", "modifier")

AC(tt, "render", "dps", "tween")

tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_PHYSICAL
tt.modifier.duration = 10
tt.modifier.use_mod_offset = nil
tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.remove = scripts.mod_stun.remove
tt.main_script.update = scripts.mod_twilight_heretic_servant.update
tt.render.sprites[1].prefix = "mod_twilight_heretic_servant"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.3, 0}}
--#endregion
--#region mod_drider_poison
tt = RT("mod_drider_poison", "modifier")

AC(tt, "render", "dps")

tt.modifier.duration = 10
tt.modifier.vis_flags = bor(F_MOD, F_POISON)
tt.render.sprites[1].name = "mod_drider_poison"
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_drider_poison.update
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.dps.damage_type = DAMAGE_POISON
--#endregion
--#region mod_razorboar_rampage_enemy
tt = RT("mod_razorboar_rampage_enemy", "modifier")

AC(tt, "dps", "render")

tt.dps.damage_min = 125
tt.dps.damage_max = 155
tt.dps.damage_every = fts(30)
tt.modifier.duration = fts(25)
tt.modifier.use_mod_offset = true
tt.render.sprites[1].name = "mod_razorboar_rampage"
tt.render.sprites[1].anchor.y = 0.34
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
--#endregion
--#region mod_razorboar_rampage_soldier
tt = RT("mod_razorboar_rampage_soldier", "mod_razorboar_rampage_enemy")
tt.dps.damage_min = 80
tt.dps.damage_max = 120
--#endregion
--#region mod_razorboar_rampage_speed
tt = RT("mod_razorboar_rampage_speed", "modifier")
tt.modifier.duration = 1.2
tt.speed_factor = 2.818181818181818
tt.main_script.insert = scripts.mod_razorboar_rampage_speed.insert
tt.main_script.remove = scripts.mod_razorboar_rampage_speed.remove
tt.main_script.update = scripts.mod_razorboar_rampage_speed.update
--#endregion
--#region mod_son_of_mactans_poison
tt = RT("mod_son_of_mactans_poison", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 6
tt.dps.damage_min = 6
tt.dps.kill = true
tt.modifier.duration = 3
--#endregion
--#region mod_spider_sprint
tt = RT("mod_spider_sprint", "mod_slow")
tt.slow.factor = 2
tt.modifier.duration = fts(12)
--#endregion
--#region mod_mactans_tower_block
tt = RT("mod_mactans_tower_block", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_mactans_tower_block.update
tt.modifier.duration = 5

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].anchor.y = 0.18461538461538463
	tt.render.sprites[i].draw_order = 10
	tt.render.sprites[i].sort_y_offset = -2
	tt.render.sprites[i].name = "mactans_towerWebs_000" .. i
	tt.render.sprites[i].animated = false
	tt.tween.props[i] = CC("tween_prop")
	tt.tween.props[i].keys = {{fts(17) * (i - 1), 0}, {fts(17) * i, 255}}
	tt.tween.props[i].sprite_id = i
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].anchor.y = 0.18461538461538463
tt.render.sprites[5].draw_order = 10
tt.render.sprites[5].sort_y_offset = -2
tt.render.sprites[5].prefix = "mod_mactans_tower_block"
tt.render.sprites[5].name = "end"
tt.render.sprites[5].hidden = true
tt.tween.remove = false
--#endregion
--#region mod_bloodsydian_warlock
tt = RT("mod_bloodsydian_warlock", "modifier")

AC(tt, "render", "spawner", "sound_events")

tt.main_script.update = scripts.mod_bloodsydian_warlock.update
tt.render.sprites[1].prefix = "bloodsydianGnoll_respawn"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.3
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.incubation_time = 1.5
tt.incubation_time_variance = 0.15
tt.spawn_name = "enemy_gnoll_bloodsydian"
tt.sound_events.insert = "ElvesCrystallizingGnoll"
--#endregion
--#region mod_ogre_magi_shield
tt = RT("mod_ogre_magi_shield", "modifier")

AC(tt, "render")

tt.modifier.duration = 6
tt.modifier.deflect_factor = 0.5
tt.main_script.insert = scripts.mod_ogre_magi_shield.insert
tt.main_script.remove = scripts.mod_ogre_magi_shield.remove
tt.main_script.update = scripts.mod_ogre_magi_shield.update
tt.fx_cooldown = fts(10)
tt.last_fx_ts = 0
tt.source_vis_flags = F_RANGED
tt.render.sprites[1].name = "ogre_mage_shield_damage"
tt.render.sprites[1].loop = false
tt.render.sprites[1].ts = -10
tt.render.sprites[1].size_scales = {vec_1(0.8), vec_1(1), vec_1(1)}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.05555555555555555
tt.render.sprites[2].animated = false
tt.render.sprites[2].draw_order = 5
tt.render.sprites[2].name = "ogre_mage_shield"
--#endregion
--#region mod_screecher_bat_stun
tt = RT("mod_screecher_bat_stun", "mod_stun")
tt.modifier.duration = 5
tt.modifier.duration_heroes = 3
tt.render.sprites[1].prefix = "mod_screecher_bat_stun"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
--#endregion
--#region mod_dark_spitters
tt = RT("mod_dark_spitters", "modifier")

AC(tt, "render", "dps")

tt.explode_fx = "fx_unit_explode"
tt.modifier.duration = 3 - fts(11)
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.nodes_limit = 20
tt.spawn_entity = "enemy_shadows_spawns"
tt.render.sprites[1].name = "mod_dark_spitters"
tt.render.sprites[1].draw_order = 10
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dark_spitters.update
tt.dps.damage_every = fts(11)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.dps.damage_type = DAMAGE_POISON
--#endregion
--#region mod_shadow_champion
tt = RT("mod_shadow_champion", "mod_gnoll_boss")
tt.main_script.insert = scripts.mod_shadow_champion.insert
tt.main_script.remove = scripts.mod_shadow_champion.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 120
tt.inflicted_damage_factor = 1.2
tt.heal_factor = 1
--#endregion
--#region mod_balrog
tt = RT("mod_balrog", "mod_dark_spitters")
tt.modifier.duration = 5 - fts(11)
--#endregion
--#region mod_snare_hee_haw
tt = RT("mod_snare_hee_haw", "mod_spider_web")
tt.render.sprites[1].prefix = "mod_snare_hee_haw"
tt.render.sprites[1].anchor = vec_2(0.5, 0.295)
tt.modifier.hide_target_delay = nil
tt.modifier.custom_scales = {}
tt.modifier.custom_scales.default = vec_1(0.5)
tt.modifier.custom_scales.hero_elves_denas = vec_2(0.7)
tt.modifier.custom_scales.hero_bravebark = vec_1(1)
tt.modifier.custom_scales.hero_xin = vec_1(1)
tt.modifier.custom_scales.soldier_forest = vec_1(0.7)
tt.modifier.custom_scales.soldier_druid_bear = vec_1(0.7)
--#endregion
--#region mod_twilight_brute
tt = RT("mod_twilight_brute", "modifier")

AC(tt, "render", "tween")

tt.inflicted_damage_factor = 1.25
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 3
tt.modifier.use_mod_offset = false
tt.modifier.resets_same_tween = true
tt.modifier.resets_same_tween_offset = fts(10)
tt.render.sprites[1].name = "mod_twilight_bannerbearer"
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {"this.modifier.duration-(10/30)", 255}, {"this.modifier.duration", 0}}
--#endregion

--#region mod_pixie_teleport
tt = RT("mod_pixie_teleport", "mod_teleport_mage")

AC(tt, "sound_events")

tt.max_times_applied = nil
tt.hold_time = fts(10)
tt.nodes_offset = -50
tt.fx_start = "fx_mod_pixie_teleport"
tt.fx_end = "fx_mod_pixie_teleport"
tt.sound_events.insert = "ElvesGnomeTeleport"
--#endregion
--#region mod_ray_crystal_arcane
tt = RT("mod_ray_crystal_arcane", "modifier")
AC(tt, "dps")
tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(4)
tt.dps.damage_min = 150 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_max = 200 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.kill = false
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
--#endregion
--#region mod_crystal_arcane_freeze
tt = RT("mod_crystal_arcane_freeze", "mod_freeze")
AC(tt, "render")
tt.modifier.duration = 4
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {}
tt.custom_offsets.flying = vec_2(-5, 28)
tt.custom_offsets.enemy_gloomy = vec_2(-5, 22)
tt.custom_offsets.enemy_mantaray = vec_2(-5, 16)
tt.custom_offsets.enemy_perython_rock_thrower = vec_2(-5, 46)
tt.custom_offsets.enemy_perython_gnoll_gnawer = vec_2(-5, 46)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {"start", "end"}
--#endregion
--#region mod_crystal_arcane_buff
tt = RT("mod_crystal_arcane_buff", "modifier")

AC(tt, "render", "tween")

tt.damage_factor = 1.75
tt.modifier.duration = 5
tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = scripts.mod_tower_factors.update
tt.render.sprites[1].name = "crystalArcane_towerBuff_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt.render.sprites[1].z = Z_TOWER_BASES + 1

local offsets = {nil, vec_2(-30, 10), vec_2(-10, 0), vec_2(10, 0), vec_2(30, 10)}

for i = 2, 5 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "fx_crystal_arcane_tower"
	tt.render.sprites[i].anchor.y = 0.11666666666666667
	tt.render.sprites[i].sort_y_offset = -2
	tt.render.sprites[i].offset = offsets[i]
	tt.render.sprites[i].flip_x = i >= 4
	tt.tween.props[i] = CC("tween_prop")
	tt.tween.props[i].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
	tt.tween.props[i].sprite_id = i
end

tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {0.5, vec_1(1.15)}, {1, vec_1(1)}}
tt.tween.props[1].loop = true
tt.tween.props[6] = CC("tween_prop")
tt.tween.props[6].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
--#endregion
--#region mod_crystal_arcane_buff_soldier
tt = RT("mod_crystal_arcane_buff_soldier", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.inflicted_damage_factor = 1.75
tt.modifier.duration = 5
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "decal_crystal_arcane_soldier_base"
tt.render.sprites[1].anchor.y = 0.23529411764705882
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_crystal_arcane_soldier_bubbles"
tt.render.sprites[2].anchor.y = 0.23529411764705882
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "fx_crystal_arcane_soldier"
tt.render.sprites[3].anchor.y = 0.17647058823529413
tt.render.sprites[3].sort_y_offset = -1
tt.render.sprites[3].loop = false
--#endregion
--#region mod_crystal_unstable_teleport
tt = RT("mod_crystal_unstable_teleport", "mod_teleport")
tt.delay_start = fts(5)
tt.delay_end = fts(5)
tt.fx_start = "fx_teleport_out_crystal_unstable"
tt.fx_end = "fx_teleport_in_crystal_unstable"
tt.hold_time = fts(16)
tt.max_times_applied = nil
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT, F_RANGED)
tt.modifier.vis_bans = bor(F_BOSS)
tt.nodes_offset = -10
--#endregion
--#region mod_crystal_unstable_infuse
tt = RT("mod_crystal_unstable_infuse", "mod_bloodsydian_warlock")
--#endregion
--#region mod_crystal_unstable_heal
tt = RT("mod_crystal_unstable_heal", "modifier")

AC(tt, "hps", "render")

tt.hps.heal_every = 1000000000
tt.hps.heal_max = 200
tt.hps.heal_min = 200
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(25)
tt.modifier.use_mod_offset = true
tt.modifier.vis_flags = bor(F_MOD, F_RANGED)
tt.modifier.vis_bans = bor(F_BOSS)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "fx_heal_crystal_unstable"
--#endregion
--#region mactans_controller
tt = RT("mactans_controller")

AC(tt, "main_script")

tt.main_script.insert = scripts.mactans_controller.insert
tt.main_script.update = scripts.mactans_controller.update
tt.sequence = nil
tt.sequence_groups = nil
--#endregion
--#region power_thunder_control
tt = RT("power_thunder_control")

AC(tt, "user_power", "pos", "main_script", "user_selection")

tt.cooldown = 70
tt.flash_delay_max = 0.3
tt.flash_delay_min = 0.1
tt.flash_duration_max = 0.15
tt.flash_duration_min = 0.1
tt.flash_l1_max_alphas = {0, 0}
tt.flash_l2_max_alpha = 70
tt.flash_l2_min_alpha = 60
tt.flash_delta = 0.02
tt.main_script.update = scripts.power_thunder_control.update
tt.nodes_spread = 10
tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.1
tt.rain.count = 20
tt.rain.delay_max = 0.2
tt.rain.disabled = true
tt.rain.distance_max = 550
tt.rain.distance_min = 450
tt.rain.duration = 0.2
tt.rain.ts = 0
tt.slow = {}
tt.slow.cooldown = 0.24
tt.slow.disabled = true
tt.slow.mod = "mod_power_thunder_slow"
tt.slow.range = 9999
tt.slow.ts = 0
tt.thunders = {{}, {}}
tt.thunders[1].cooldown = 0
tt.thunders[1].count = 3
tt.thunders[1].created = 0
tt.thunders[1].damage_max = 90
tt.thunders[1].damage_min = 50
tt.thunders[1].damage_radius = 100
tt.thunders[1].damage_type = DAMAGE_TRUE
-- tt.thunders[1].delay_max = 0.4
tt.thunders[1].delay_max = 0.33
-- tt.thunders[1].delay_min = 0.2
tt.thunders[1].delay_min = 0.33
tt.thunders[1].pop = {"pop_lightning1", "pop_lightning2", "pop_lightning3"}
tt.thunders[1].pop_chance = 0.3
tt.thunders[1].range = 150
tt.thunders[1].targeting = "nearest"
tt.thunders[1].ts = 0
tt.thunders[2] = table.deepclone(tt.thunders[1])
tt.thunders[2].count = 3
tt.thunders[2].pop = nil
tt.thunders[2].range = 9999
tt.thunders[2].targeting = "random"
tt.user_selection.can_select_point_fn = scripts.power_thunder_control.can_select_point
tt.vis_bans = bor(F_FRIEND)
tt.vis_flags = bor(F_RANGED)
--#endregion
--#region mod_power_thunder_slow
tt = RT("mod_power_thunder_slow", "mod_slow")
tt.modifier.duration = 0.25
tt.slow.factor = 0.4
--#endregion
--#region fx_power_thunder_1
tt = RT("fx_power_thunder_1", "decal_tween")

AC(tt, "sound_events")

tt.image_h = 496
tt.render.sprites[1].name = "ray_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.props[1].keys = {{0, 255}, {fts(3), 255}, {fts(8), 0}}
tt.sound_events.insert = "CommonLightning"
--#endregion
--#region fx_power_thunder_2
tt = RT("fx_power_thunder_2", "fx_power_thunder_1")
tt.image_h = 456
tt.render.sprites[1].name = "ray_0002"
--#endregion
--#region fx_power_thunder_explosion
tt = RT("fx_power_thunder_explosion", "fx")
tt.render.sprites[1].name = "fx_power_thunder_explosion_half"
tt.render.sprites[1].anchor.y = 0.15714285714285714
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
--#endregion
--#region fx_power_thunder_explosion_decal
tt = RT("fx_power_thunder_explosion_decal", "fx")
tt.render.sprites[1].name = "decal_power_thunder_explosion"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region overlay_power_thunder_flash
tt = RT("overlay_power_thunder_flash", "decal_tween")

AC(tt, "tween")

image_y = 64
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].scale = vec_2(math.ceil(REF_H * 16 / 9 * 1.1 / image_y), math.ceil(REF_H / image_y))
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "square_b8b8b8"
tt.render.sprites[2].alpha = 0
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.ts = 0
tt.cooldown = 0
--#endregion
--#region fx_power_thunder_drop
tt = RT("fx_power_thunder_drop", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "lightning_storm_rain_drop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 1
tt.render.sprites[1].z = Z_OBJECTS_SKY
--#endregion
--#region fx_power_thunder_rain_splash
tt = RT("fx_power_thunder_rain_splash", "fx")
tt.render.sprites[1].name = "fx_power_thunder_rain_splash"
-- --#endregion
--#region power_hero_control
tt = RT("power_hero_control")
-- AC(tt, "user_power", "pos", "main_script", "user_selection")
-- tt.main_script.insert = scripts.power_hero_control.insert
-- tt.user_selection.can_select_point_fn = scripts.power_hero_control.can_select_point
-- E:set_template("user_power_1", E:get_template("power_thunder_control"))
-- E:set_template("user_power_2", E:get_template("power_reinforcements_control"))
-- E:set_template("user_power_3", E:get_template("power_hero_control"))
--#endregion
--#region decal_water_sparks
tt = RT("decal_water_sparks", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
--#endregion
--#region decal_water_sparks_small
tt = RT("decal_water_sparks_small", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt.render.sprites[1].scale = vec_2(0.6, 0.6)
--#endregion
--#region decal_jumping_fish
tt = RT("decal_jumping_fish", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 10
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "jump"
--#endregion
--#region decal_water_wave_delayed_2
tt = RT("decal_water_wave_delayed_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"
--#endregion
--#region decal_water_wave_1
tt = RT("decal_water_wave_1", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_1_play"
--#endregion
--#region decal_water_wave_2
tt = RT("decal_water_wave_2", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_2_play"
--#endregion
--#region decal_water_wave_3
tt = RT("decal_water_wave_3", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_3_play"
--#endregion
--#region decal_water_wave_4
tt = RT("decal_water_wave_4", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_4_play"
--#endregion
--#region decal_water_splash
tt = RT("decal_water_splash", "decal_loop")
tt.render.sprites[1].name = "decal_water_splash_play"
--#endregion
--#region decal_stage01_gandalf
tt = RT("decal_stage01_gandalf", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_gandalf"
tt.render.sprites[1].name = "idle"
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "smoke"
--#endregion
--#region decal_stage01_bird1
tt = RT("decal_stage01_bird1", "decal_delayed_play")

AC(tt, "tween")

--#endregion
--#region decal_bird_1
tt = RT("decal_bird_1", "decal_tween")
tt.render.sprites[1].prefix = "decal_bird_1"
tt.render.sprites[1].name = "play"
tt.tween.remove = true
tt.tween.props[1].name = "offset"
--#endregion
--#region decal_bird_2
tt = RT("decal_bird_2", "decal_bird_1")
tt.render.sprites[1].prefix = "decal_bird_2"
--#endregion
--#region birds_controller
tt = RT("birds_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.birds_controller.update
tt.origins = {}
tt.destinations = {}
tt.bird_templates = {"decal_bird_1", "decal_bird_2"}
tt.delay = {20, 40}
tt.batch_count = 2
tt.batch_delay = {1, 5}
tt.fly_speed = 116
--#endregion
--#region decal_stage_02_waterfall_1
tt = RT("decal_stage_02_waterfall_1", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_1_idle"
--#endregion
--#region decal_stage_02_waterfall_2
tt = RT("decal_stage_02_waterfall_2", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_2_idle"
--#endregion
--#region decal_stage_02_waterfall_3
tt = RT("decal_stage_02_waterfall_3", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_3_idle"
--#endregion
--#region decal_stage_02_waterfall_4
tt = RT("decal_stage_02_waterfall_4", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_4_idle"
--#endregion
--#region decal_stage_02_bigwaves
tt = RT("decal_stage_02_bigwaves", "decal")
tt.render.sprites[1].name = "decal_stage_02_bigwaves_idle"

for i = 1, 6 do
	--#endregion
	--#region decal_stage_02_stone_" .. i, "decal
	tt = RT("decal_stage_02_stone_" .. i, "decal")
	tt.render.sprites[1].name = "stage2_stones_000" .. i
	tt.render.sprites[1].animated = false
end

--#endregion
--#region decal_stage_02_bridge_mask
tt = RT("decal_stage_02_bridge_mask", "decal")
tt.render.sprites[1].name = "stage2_bridge"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_stage_02_bridge_shadows
tt = RT("decal_stage_02_bridge_shadows", "decal")
tt.render.sprites[1].name = "stage2_shadows"
tt.render.sprites[1].animated = false
--#endregion
--#region decal_bambi
tt = RT("decal_bambi", "decal_scripted")

AC(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_bambi"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.1
tt.main_script.update = scripts.decal_bambi.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, 0, 30, 30)
tt.ui.can_select = false
tt.run_offset = nil
tt.motion.max_speed = 99.9
--#endregion
--#region decal_rabbit
tt = RT("decal_rabbit", "decal_scripted")

AC(tt, "ui", "tween")

tt.render.sprites[1].prefix = "decal_rabbit"
tt.render.sprites[1].name = "ears"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.click_rect = r(-20, -20, 40, 30)
tt.ui.can_select = false
tt.main_script.update = scripts.decal_rabbit.update
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt.tween.ts = 0
tt.ani_sequence = {{"ears", 5, 15}, {"popout", 1, 3, "hide1"}, {"travel1", 1, 3, "hide2"}, {"travel2", 1.5, 3, "hide3"}, {"travel3", 1, 3, "hide1"}, {"hide1"}, {nil, 10, 20}}
--#endregion
--#region decal_s03_bridge
tt = RT("decal_s03_bridge", "decal_static")

AC(tt, "ui")

tt.ui.click_rect = r(-83, -48, 166, 96)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage3_bridge"
tt.render.sprites[1].z = Z_DECALS + 2
tt.render.sprites[1].sort_y_offset = 48
--#endregion
--#region decal_crane
tt = RT("decal_crane", "decal_scripted")

AC(tt, "ui")

tt.render.sprites[1].prefix = "decal_crane"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_crane_fx"
tt.render.sprites[2].loop = true
tt.render.sprites[2].draw_order = -1
tt.ui.click_rect = r(-20, -40, 40, 40)
tt.ui.can_select = false
tt.main_script.update = scripts.decal_crane.update
tt.play_animation = "play"
tt.click_animation = "click"
tt.final_click_animation = "final_click"
tt.play_time = {10, 45}
tt.final_clicks = {3, 6}
--#endregion
--#region river_object_controller
tt = RT("river_object_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.river_object_controller.update
tt.river_objects = {"barrel", "barrel", "chest", "wilson", "submarine"}
tt.min_time = 12
tt.max_time = 24
tt.max_chests = 3
tt.max_hobbits = 13
--#endregion
--#region decal_river_object
tt = RT("decal_river_object", "decal_scripted")

AC(tt, "nav_path", "motion", "ui", "tween", "sound_events")

tt.main_script.update = scripts.decal_river_object.update
tt.motion.max_speed = 1.5 * FPS
tt.ui.click_rect = r(-18, -5, 36, 36)
tt.ui.can_select = false
tt.ui.z = -1
tt.render.sprites[1].z = Z_DECALS + 1
tt.nav_path.pi = 5
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.sink_nodes = 5
tt.falls = 1
tt.fall_time = 0.5
tt.fall_wait = 0.6
tt.fall_1_tween = {{0, 255}, {0.4, 255}, {0.5, 0}}
tt.travel_2_tween = {{0, 0}, {1, 255}}
tt.tween.disabled = true
tt.tween.remove = false
tt.sound_events.fall = "ElvesWaterfallStrong"
--#endregion
--#region decal_river_object_hobbit
tt = RT("decal_river_object_hobbit", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_hobbit"
tt.render.sprites[1].anchor.y = 0.2818181818181818
tt.falls = 2
tt.sink_nodes = nil
tt.achievement_inc = "DWARF_FALL"
tt.sound_events.save = "ElvesAchievementHobbit"
tt.sound_events.crash = "ElvesAchievementDwarfFall"
--#endregion
--#region decal_river_object_barrel
tt = RT("decal_river_object_barrel", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_barrel"
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.sound_events.save = "ElvesWaterfallMid"
--#endregion
--#region decal_river_object_chest
tt = RT("decal_river_object_chest", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_chest"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.gold = 20
tt.sound_events.save = "ElvesGoldCoin"
--#endregion
--#region decal_river_object_wilson
tt = RT("decal_river_object_wilson", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_wilson"
tt.render.sprites[1].anchor.y = 0.1527777777777778
tt.sound_events.save = "ElvesAchievementWilson"
--#endregion
--#region decal_river_object_submarine
tt = RT("decal_river_object_submarine", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_submarine"
tt.render.sprites[1].anchor.y = 0.20454545454545456
tt.sound_events.save = "ElvesAchievementYellowSubmarine"
--#endregion
--#region fx_waterfall_splash
tt = RT("fx_waterfall_splash", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_waterfall_splash"
tt.render.sprites[1].anchor.y = 0.21875
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "ElvesWaterfallMid"
--#endregion
--#region decal_s04_land_1
tt = RT("decal_s04_land_1", "decal_background")

AC(tt, "tween")

tt.render.sprites[1].name = "Stage04_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
--#endregion
--#region decal_s04_land_2
tt = RT("decal_s04_land_2", "decal_s04_land_1")
tt.render.sprites[1].name = "Stage04_0004"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
--#endregion
--#region decal_s04_tree_burn
tt = RT("decal_s04_tree_burn", "decal_timed")

AC(tt, "editor")

tt.render.sprites[1].prefix = "decal_s04_tree_burn"
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].scale = vec_2(1, 1)
tt.timed.disabled = true
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].scale", PT_COORDS}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
--#endregion
--#region decal_s04_charcoal_1
tt = RT("decal_s04_charcoal_1", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage4_fire_decal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_2(1, 1)
tt.render.sprites[1].z = Z_BACKGROUND + 1
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {0.4, 255}, {1.7, 0}}
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].scale", PT_COORDS}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
--#endregion
--#region decal_s04_charcoal_2
tt = RT("decal_s04_charcoal_2", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
--#endregion
--#region decal_s04_charcoal_3
tt = RT("decal_s04_charcoal_3", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0003"
--#endregion
--#region decal_gnoll_burner
tt = RT("decal_gnoll_burner", "decal")
tt.render.sprites[1].anchor = vec_2(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.render.sprites[1].name = "idle"
--#endregion
--#region fx_torch_gnoll_burner_explosion_stage04
tt = RT("fx_torch_gnoll_burner_explosion_stage04", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion_stage04"
--#endregion
--#region fx_s04_tree_fire_1
tt = RT("fx_s04_tree_fire_1", "decal_timed")

AC(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s04_tree_fire_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
--#endregion
--#region fx_s04_tree_fire_2
tt = RT("fx_s04_tree_fire_2", "fx_s04_tree_fire_1")
tt.render.sprites[1].name = "fx_s04_tree_fire_2"
--#endregion
--#region decal_george_jungle
tt = RT("decal_george_jungle", "decal_scripted")

AC(tt, "ui", "tween")

tt.main_script.update = scripts.decal_george_jungle.update
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].prefix = "decal_george_jungle_liana"
tt.render.sprites[1].r = 50 * math.pi / 180
tt.render.sprites[1].offset = vec_2(768, 830)
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_george_jungle"
tt.render.sprites[2].name = "fall"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = vec_2(566, 457)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y = 343
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "decal_george_jungle_bush"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor.y = 0
tt.render.sprites[3].offset = vec_2(553, 296)
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].sort_y = 296
tt.final_clicks = {3, 5}
tt.play_time = {3, 5}
tt.ui.click_rect = r(0, 0, 200, 120)
tt.ui.can_select = false
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "r"
tt.tween.props[1].keys = {{0, 50 * math.pi / 180}, {0.3, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(0, 0)}, {0.3, v(0, 0)}}
tt.achievement = "GEORGE_FALL"
--#endregion
--#region decal_tree_ewok
tt = RT("decal_tree_ewok", "decal_scripted")

AC(tt, "motion", "nav_path", "ranged", "unit")

tt.main_script.update = scripts.decal_tree_ewok.update
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt.render.sprites[1].prefix = "decal_tree_ewok"
tt.ranged.attacks[1].min_range = 150
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].bullet = "spear_tree_ewok"
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 15)}
tt.wait_time = 5
tt.dance_animations = {"dance1", "dance2"}
tt.ranged_center = vec_2(550, 380)
tt.motion.max_speed = 45
--#endregion
--#region spear_tree_ewok
tt = RT("spear_tree_ewok", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_max = 10
tt.bullet.hit_chance = 0.4
tt.bullet.miss_decal = "ewok_2_proy_0002"
tt.bullet.flight_time = fts(33)
tt.render.sprites[1].name = "ewok_2_proy_0001"
tt.sound_events.insert = "AxeSound"
--#endregion
--#region tower_ewok_holder
tt = RT("tower_ewok_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor")

tt.tower.type = "holder_ewok"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.info.i18n_key = "ELVES_EWOK_TOWER"
tt.info.fn = scripts.tower_ewok_holder.get_info
tt.info.portrait = "kr3_info_portraits_towers_0013"
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(0, 10)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "ewok_hut_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 32)
tt.ui.click_rect = r(-40, -10, 80, 90)
--#endregion
--#region decal_s05_tree_round
tt = RT("decal_s05_tree_round", "decal")
tt.render.sprites[1].name = "stage5_tree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.13953488372093023
--#endregion
--#region decal_s05_tree_pine
tt = RT("decal_s05_tree_pine", "decal")
tt.render.sprites[1].name = "stage5_pine"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.08333333333333333
--#endregion
--#region decal_bush_statue
tt = RT("decal_bush_statue", "decal_scripted")

AC(tt, "ui")

tt.main_script.insert = scripts.decal_bush_statue.insert
tt.main_script.update = scripts.decal_bush_statue.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage5_bushes_0001"
tt.render.sprites[1].anchor.y = 0.1744186046511628
tt.bush_frame_prefix = "stage5_bushes_"
tt.bush_frames = {"0001", "0002", "0003", "0004", "0005", "0006", "0007"}
tt.bush_indexes = nil
tt.bush_idx = nil
tt.ui.click_rect = r(-40, 0, 80, 66)
tt.ui.can_select = false
--#endregion
--#region fx_bush_statue_click
tt = RT("fx_bush_statue_click", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_bush_statue_click"
tt.render.sprites[1].offset.y = 34
tt.sound_events.insert = "ElvesAchievementScissorFingers"
--#endregion
--#region decal_s06_eagle
tt = RT("decal_s06_eagle", "decal_delayed_sequence")

AC(tt, "editor")

tt.delayed_sequence.animations = {"1", "2", "3", "4"}
tt.delayed_sequence.random = true
tt.delayed_sequence.max_delay = 3
tt.render.sprites[1].prefix = "decal_s06_eagle"
tt.render.sprites[1].name = "1"
tt.render.sprites[1].z = Z_OBJECTS + 1
--#endregion
--#region decal_s06_boxed_boss
tt = RT("decal_s06_boxed_boss", "decal_delayed_play")

AC(tt, "editor")

tt.delayed_play.min_delay = 5
tt.delayed_play.min_delay = 10
tt.render.sprites[1].prefix = "decal_s06_boxed_boss_l1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_s06_boxed_boss_l2"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "decal_s06_boxed_boss_l3"
tt.render.sprites[3].z = Z_OBJECTS + 1
--#endregion
--#region decal_s06_jailed_boss
tt = RT("decal_s06_jailed_boss", "decal")

for i = 1, 6 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s06_jailed_boss_l" .. i
	tt.render.sprites[i].name = "walk"
	tt.render.sprites[i].anchor.y = 0.26373626373626374
end

tt.render.sprites[6].sort_y_offset = -10
--#endregion
--#region soldier_gryphon_guard
tt = RT("soldier_gryphon_guard", "soldier_barrack_1")

AC(tt, "ranged")

tt.health.hp_max = 1
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.health_bar = nil
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.range = 0
tt.motion.max_speed = 75
tt.ranged.attacks[1].bullet = "arrow_soldier_gryphon_guard"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(5, 10)}
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].max_range = 1000
tt.ranged.attacks[1].min_range = 1
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].prefix = "soldier_gryphon_guard"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.ui = nil
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.level = 1
tt.unit.mod_offset = vec_2(0, 21)
tt.vis.bans = bor(tt.vis.bans, F_RANGED)
tt.vis.bans = bor(F_BLOCK, F_RANGED)
--#endregion
--#region arrow_soldier_gryphon_guard
tt = RT("arrow_soldier_gryphon_guard", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 10
tt.bullet.flight_time = fts(12)
tt.bullet.reset_to_target_pos = true
--#endregion
--#region soldier_gryphon_guard_upper
tt = RT("soldier_gryphon_guard_upper", "soldier_gryphon_guard")

AC(tt, "auras")

tt.ranged.attacks[1].filter_fn = scripts.soldier_gryphon_guard.upper_ranged_filter_fn
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_upper"
tt.auras.list[1].cooldown = 0
--#endregion
--#region soldier_gryphon_guard_lower
tt = RT("soldier_gryphon_guard_lower", "soldier_gryphon_guard")

AC(tt, "auras", "tween")

tt.ranged.attacks[1].filter_fn = scripts.soldier_gryphon_guard.lower_ranged_filter_fn
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_lower"
tt.auras.list[1].cooldown = 0
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {0.5, 255}}
tt.render.sprites[1].alpha = 0
--#endregion
--#region aura_soldier_gryphon_guard_upper
tt = RT("aura_soldier_gryphon_guard_upper", "aura")
tt.main_script.update = scripts.aura_soldier_gryphon_guard_upper.update
tt.aura.duration = -1
tt.patch_cooldown_min = fts(20)
tt.patch_cooldown_max = fts(35)
--#endregion
--#region aura_soldier_gryphon_guard_lower
tt = RT("aura_soldier_gryphon_guard_lower", "aura")
tt.main_script.update = scripts.aura_soldier_gryphon_guard_lower.update
tt.hide_pos = vec_2(459, 563)
tt.show_pos = vec_2(440, 550)
tt.hidden_max = 3
tt.hidden_min = 1
tt.idle_time_to_hide = 5
--#endregion
--#region decal_gryphon
tt = RT("decal_gryphon", "decal_scripted")

AC(tt, "attacks", "ui", "sound_events")

tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].cooldown = fts(3)
tt.attacks.list[1].bullet = "bullet_gryphon"
tt.attacks.list[1].loops = 3
tt.attacks.list[1].bullet_start_offset = vec_2(102, -22)
tt.main_script.update = scripts.decal_gryphon.update
tt.render.sprites[1].prefix = "gryphon_l1"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].group = "layers"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "gryphon_l2"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].group = "layers"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "ally_gryphon_0000"
tt.render.sprites[3].alpha = 60
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "gryphon_attack_flash"
tt.ui.click_rect = r(-40, -106, 80, 100)
tt.ui.can_select = false
tt.ui.can_click = true
tt.custom = {
	left = {},
	right = {}
}
tt.custom.left.initial_duration = 4.6
tt.custom.left.default_duration = 4
tt.custom.left.approach_duration = 0.7
tt.custom.left.attack_ranges = {{-50, 500}}
tt.custom.left.initial_curve_id = 5
tt.custom.left.default_curve_id = 6
tt.custom.left.land_curve_id = 7
tt.custom.right.initial_duration = 5
tt.custom.right.default_duration = 4.5
tt.custom.right.approach_duration = 0.7
tt.custom.right.attack_ranges = {{1050, 750}, {600, 200}}
tt.custom.right.initial_curve_id = 8
tt.custom.right.default_curve_id = 9
tt.custom.right.land_curve_id = 10
--#endregion
--#region bullet_gryphon
tt = RT("bullet_gryphon", "bullet")
tt.main_script.update = scripts.bullet_gryphon.update
tt.render.sprites[1].name = "bolt_gryphon_travel"
tt.render.sprites[1].anchor.x = 0.8857142857142857
tt.render.sprites[1].loop = false
tt.render.sprites[1].fps = 10
tt.bullet.max_speed = 300
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = 100
tt.bullet.damage_max = 120
tt.bullet.damage_radius = 30
tt.bullet.damage_flags = bor(F_RANGED)
tt.bullet.hit_fx = "fx_bolt_gryphon_hit"
tt.bullet.hit_decal = "decal_bomb_crater"
--#endregion
--#region fx_bolt_gryphon_hit
tt = RT("fx_bolt_gryphon_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_hit"
tt.render.sprites[1].anchor.y = 0.23809523809523808
--#endregion
--#region fx_bolt_gryphon_flash
tt = RT("fx_bolt_gryphon_flash", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_flash"
--#endregion
--#region decal_gryphon_sign
tt = RT("decal_gryphon_sign", "decal_tween")
tt.render.sprites[1].name = "ally_gryphon_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -110
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(4), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.75, 0.75)}, {fts(4), vec_2(1.075, 1.075)}, {fts(7), vec_2(0.96, 0.96)}, {fts(9), vec_2(1, 1)}}
--#endregion
--#region gryphon_controller
tt = RT("gryphon_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.gryphon_controller.update
--#endregion
--#region decal_obelix
tt = RT("decal_obelix", "decal_delayed_click_play")
tt.render.sprites[1].prefix = "decal_obelix"
tt.ui.click_rect = r(-50, -40, 100, 80)
tt.ui.can_select = false
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 3
tt.delayed_play.clicked_animation = "eat"
tt.delayed_play.clicked_sound = "ElvesObelix"
tt.delayed_play.play_animation = "hammer"
tt.delayed_play.required_clicks = 1

for i = 1, 4 do
	--#endregion
	--#region decal_wisp_" .. i, "decal
	tt = RT("decal_wisp_" .. i, "decal")
	tt.render.sprites[1].name = string.format("decal_wisp_%i_l1", i)
	tt.render.sprites[1].random_ts = 3
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].name = string.format("decal_wisp_%i_l2", i)
	tt.render.sprites[2].random_ts = 3

	if i ~= 4 then
		tt.render.sprites[3] = CC("sprite")
		tt.render.sprites[3].name = string.format("decal_wisp_%i_l3", i)
		tt.render.sprites[3].random_ts = 3
	end

	if i == 2 or i == 3 then
		tt.render.sprites[3] = CC("sprite")
		tt.render.sprites[3].name = string.format("decal_wisp_%i_l4", i)
		tt.render.sprites[3].random_ts = 3
	end
end

for i = 5, 10 do
	--#endregion
	--#region decal_wisp_" .. i, "decal_delayed_play
	tt = RT("decal_wisp_" .. i, "decal_delayed_play")
	tt.render.sprites[1].prefix = "decal_wisp_" .. i
	tt.render.sprites[1].name = "play"
	tt.delayed_play.min_delay = 3
	tt.delayed_play.max_delay = 6
	tt.delayed_play.idle_animation = nil
end

--#endregion
--#region decal_s08_magic_bean
tt = RT("decal_s08_magic_bean", "decal_scripted")

AC(tt, "ui")

tt.achievement_id = "BEANS"
tt.main_script.update = scripts.decal_s08_magic_bean.update
tt.ui.click_rect = r(-25, -25, 50, 50)
tt.ui.can_select = false
tt.reward_gold = 150
tt.reward_fx = "fx_coin_jump"

for i = 1, 5 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s08_magic_bean_l" .. i
	tt.render.sprites[i].name = "step1"
	tt.render.sprites[i].loop = false
	tt.render.sprites[i].anchor.y = 0.1076923076923077
end

--#endregion
--#region decal_s08_peekaboo
tt = RT("decal_s08_peekaboo", "decal_scripted")

AC(tt, "ui")

tt.main_script.update = scripts.decal_s08_peakaboo.update
tt.render.sprites[1].name = "out"
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.pos_list = nil
tt.sound = "ElvesPeekaboo"
--#endregion
--#region decal_s08_peekaboo_wolf
tt = RT("decal_s08_peekaboo_wolf", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_wolf"
tt.achievement_flag = {"PEEKABOO", 1}
--#endregion
--#region decal_s08_peekaboo_rrh
tt = RT("decal_s08_peekaboo_rrh", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_rrh"
tt.achievement_flag = {"PEEKABOO", 2}
--#endregion
--#region decal_s08_peekaboo_pork
tt = RT("decal_s08_peekaboo_pork", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_pork"
tt.achievement_flag = {"PEEKABOO", 4}
--#endregion
--#region decal_s08_hansel_gretel
tt = RT("decal_s08_hansel_gretel", "decal_scripted")

AC(tt, "ui")

tt.main_script.update = scripts.decal_s08_hansel_gretel.update
tt.ui.click_rect = r(-70, -60, 140, 120)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage10_witchHouse_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "decal_s08_hansel_gretel_door"
tt.render.sprites[2].name = "close"
tt.render.sprites[2].loop = false
--#endregion
--#region decal_s08_witch
tt = RT("decal_s08_witch", "decal_scripted")

AC(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_s08_witch"
tt.render.sprites[1].anchor.y = 0.07407407407407407
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.motion.max_speed = 90
--#endregion
--#region decal_s08_hansel
tt = RT("decal_s08_hansel", "decal_tween")
tt.render.sprites[1].name = "decal_s08_hansel_walk"
tt.render.sprites[1].anchor.y = 0.07692307692307693
tt.render.sprites[1].draw_order = 2
tt.tween.props[1].keys = {{fts(26), 255}, {fts(37), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(47, -46)}, {fts(37), vec_2(182, -58)}}
--#endregion
--#region decal_s08_gretel
tt = RT("decal_s08_gretel", "decal_s08_hansel")
tt.render.sprites[1].name = "decal_s08_gretel_walk"
tt.tween.props[2].keys = {{0, vec_2(31, -44)}, {fts(37), vec_2(166, -56)}}
--#endregion
--#region aura_waterfall_entrance
tt = RT("aura_waterfall_entrance", "aura")
tt.main_script.update = scripts.aura_waterfall_entrance.update
tt.waterfall_nodes = nil
tt.show_fx = "fx_waterfall_splash"
--#endregion
--#region decal_s09_land_3
tt = RT("decal_s09_land_3", "decal_background")

AC(tt, "tween")

tt.render.sprites[1].name = "Stage09_0002"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(9), 255}, {fts(18), 0}}
--#endregion
--#region decal_s09_land_2
tt = RT("decal_s09_land_2", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0003"
--#endregion
--#region decal_s09_land_1
tt = RT("decal_s09_land_1", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0004"
--#endregion
--#region decal_s09_crystal_1
tt = RT("decal_s09_crystal_1", "decal_timed")

AC(tt, "editor")

tt.render.sprites[1].prefix = "decal_s09_crystal_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3941176470588235
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_2(1, 1)
tt.timed.disabled = true
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.debris_pos = vec_2(-5, 1)
--#endregion
--#region decal_s09_crystal_2
tt = RT("decal_s09_crystal_2", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_2"
tt.debris_pos = vec_2(9, 4)
--#endregion
--#region decal_s09_crystal_3
tt = RT("decal_s09_crystal_3", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_3"
tt.debris_pos = vec_2(9, -5)
--#endregion
--#region decal_s09_crystal_4
tt = RT("decal_s09_crystal_4", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_4"
tt.debris_pos = vec_2(-6, 6)
--#endregion
--#region decal_s09_crystal_debris
tt = RT("decal_s09_crystal_debris", "decal_tween")
tt.render.sprites[1].name = "decal_s09_crystal_debris_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = vec_2(16, 12)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_s09_crystal_debris_1"
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = vec_2(-14, 9)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "decal_s09_crystal_debris_2"
tt.render.sprites[3].offset = vec_2(2, 42)
tt.render.sprites[3].time_offset = fts(-2)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "decal_s09_crystal_debris_2"
tt.render.sprites[4].flip_x = true
tt.render.sprites[4].offset = vec_2(-32, 46)
tt.render.sprites[4].time_offset = fts(-2)
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].name = "stage9_crystals_smoke"
tt.render.sprites[5].animated = false
tt.render.sprites[5].offset = vec_2(0, 30)
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{fts(27), 255}, {fts(35), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 5
tt.tween.props[2].keys = {{0, 0}, {fts(1), 255}, {fts(8), 255}, {fts(16), 0}}
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 5
tt.tween.props[3].keys = {{0, vec_2(0.3, 0.3)}, {fts(16), vec_2(1.03, 1.03)}}
tt.tween.props[4] = table.clone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = table.clone(tt.tween.props[1])
tt.tween.props[5].sprite_id = 3
tt.tween.props[6] = table.clone(tt.tween.props[1])
tt.tween.props[6].sprite_id = 4
--#endregion
--#region decal_s09_crystal_debris_mod
tt = RT("decal_s09_crystal_debris_mod", "decal_s09_crystal_debris")
tt.render.sprites[3].sort_y_offset = 1
tt.render.sprites[4].sort_y_offset = 1
--#endregion
--#region decal_s09_crystal_serpent_back
tt = RT("decal_s09_crystal_serpent_back", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "crystal_serpent_appear"
tt.render.sprites[1].loop = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(80), vec_2(0, 0)}, {fts(114), vec_2(0, 0)}}
tt.sound_events.insert = "ElvesCrystalSerpentPassby"
--#endregion
--#region decal_s09_crystal_serpent_attack
tt = RT("decal_s09_crystal_serpent_attack", "decal_scripted")
tt.render.sprites[1].prefix = "crystal_serpent"
tt.main_script.update = scripts.decal_s09_crystal_serpent_attack.update
--#endregion
--#region decal_s09_crystal_serpent_scream
tt = RT("decal_s09_crystal_serpent_scream", "decal_s09_crystal_serpent_attack")
tt.main_script.update = scripts.decal_s09_crystal_serpent_scream.update
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].hidden = true
--#endregion
--#region bullet_crystal_serpent
tt = RT("bullet_crystal_serpent", "bullet")
tt.render.sprites[1].hidden = true
tt.bullet.mod = "mod_crystal_serpent"
tt.bullet.flight_time = fts(17)
tt.bullet.particles_name = "ps_bullet_crystal_serpent_fly"
tt.main_script.update = scripts.bullet_crystal_serpent.update
--#endregion
--#region mod_crystal_serpent
tt = RT("mod_crystal_serpent", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_tower_block.update
tt.modifier.hide_tower = false
tt.modifier.duration = 7
tt.render.sprites[1].anchor.y = 0.234375
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "crystal_serpent_block_tower"
--#endregion
--#region ps_bullet_crystal_serpent_fly
tt = RT("ps_bullet_crystal_serpent_fly")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 255, 0}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = vec_2(10, 10)
tt.particle_system.name = "crystalSerpent_smokeParticle"
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(20), fts(35)}
tt.particle_system.scale_var = {1, 1.3}
tt.particle_system.scales_x = {0.3, 1, 1.05}
tt.particle_system.scales_y = {0.3, 1, 1.05}
tt.particle_system.scale_same_aspect = true
--#endregion
--#region ps_bullet_crystal_serpent_hit
tt = RT("ps_bullet_crystal_serpent_hit")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 255, 255, 0}
tt.particle_system.emission_rate = 120
tt.particle_system.emit_area_spread = vec_2(90, 60)
tt.particle_system.names = {"crystalSerpent_smokeParticleHit", "crystalSerpent_smokeParticle"}
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(30), fts(45)}
tt.particle_system.scale_var = {1, 1.3}
tt.particle_system.scales_x = {0.2, 1, 1.15}
tt.particle_system.scales_y = {0.2, 1, 1.15}
tt.particle_system.scale_same_aspect = true
--#endregion
--#region decal_s09_waterfall
tt = RT("decal_s09_waterfall", "decal_scripted")
tt.render.sprites[1].name = "decal_s09_waterfall_lines1"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_s09_waterfall_lines2"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "decal_s09_waterfall_top"
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "decal_s09_waterfall_bottom"
--#endregion
--#region decal_crystal_water_waves2
tt = RT("decal_crystal_water_waves2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"
--#endregion
--#region decal_faerie_dragon_freeze_enemy
tt = RT("decal_faerie_dragon_freeze_enemy", "decal_freeze_enemy")
tt.shader_args = {
	tint_color = {0.9725490196078431, 0.6627450980392157, 0.9882352941176471, 1}
}
--#endregion
--#region decal_s10_gnome
tt = RT("decal_s10_gnome", "decal_scripted")

AC(tt, "ui")

tt.ui.click_rect = r(-23, -19, 46, 38)
tt.ui.can_select = false
tt.render.sprites[1].prefix = "decal_s10_gnome"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.main_script.update = scripts.decal_s10_gnome.update
tt.min_delay = 5
tt.max_delay = 20
tt.gnome_actions = {"guitar", "diamond", "sleep", "teleport", "flip"}
--#endregion
--#region decal_s10_gnome_walking
tt = RT("decal_s10_gnome_walking", "decal_s10_gnome")
tt.walk_points = nil
tt.walk_time = 1.5

table.insert(tt.gnome_actions, "walk")

--#endregion
--#region decal_faerie_crystal
tt = RT("decal_faerie_crystal", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].name = "fairy_crystals_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_crystals_0001"
tt.render.sprites[2].alpha = 255
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "faerie_grove_crystal_fx"
tt.render.sprites[3].name = "yellow"
tt.render.sprites[3].loop = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].hide_after_runs = 1
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(0), 0}, {fts(10), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{fts(0), 255}, {fts(10), 0}}
tt.tween.props[2].sprite_id = 2
tt.main_script.update = scripts.decal_faerie_crystal.update
--#endregion
--#region faerie_trails
tt = RT("faerie_trails")

AC(tt, "main_script")

tt.main_script.insert = scripts.faerie_trails.insert
tt.main_script.update = scripts.faerie_trails.update
tt.path_speeds = {
	[0] = 1 * FPS,
	2.5 * FPS
}
tt.path_speed_per_wave = nil
--#endregion
--#region nav_faerie
tt = RT("nav_faerie")

AC(tt, "pos", "render", "nav_path", "motion", "main_script", "tween")

tt.main_script.update = scripts.nav_faerie.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "fairy_energyBall_red_0016"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_energyBall_yellow_0016"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "nav_faerie_red"
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "nav_faerie_yellow"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(10), vec_1(0.8)}, {fts(20), vec_1(1)}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
--#endregion
--#region simon_controller
tt = RT("simon_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.simon_controller.update
tt.initial_sequence_length = 4
tt.reward_base = 25
tt.reward_inc = 15
tt.achievement_id = "SIMON"
tt.achievement_count = 9
--#endregion
--#region simon_mushroom_1
tt = RT("simon_mushroom_1", "decal_tween")

AC(tt, "ui", "sound_events")

tt.ui.click_rect = r(-20, 10, 40, 30)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage8_symon_fungus1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage8_symon_fungus1_0002"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "stage8_symon_fungus1_0003"
tt.tween.props[1].keys = {{0, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}}
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.sound_events.touch = "ElvesSimonYellow"
--#endregion
--#region simon_mushroom_2
tt = RT("simon_mushroom_2", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus2_0001"
tt.render.sprites[2].name = "stage8_symon_fungus2_0002"
tt.render.sprites[3].name = "stage8_symon_fungus2_0003"
tt.sound_events.touch = "ElvesSimonGreen"
--#endregion
--#region simon_mushroom_3
tt = RT("simon_mushroom_3", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus3_0001"
tt.render.sprites[2].name = "stage8_symon_fungus3_0002"
tt.render.sprites[3].name = "stage8_symon_fungus3_0003"
tt.sound_events.touch = "ElvesSimonRed"
--#endregion
--#region simon_mushroom_4
tt = RT("simon_mushroom_4", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus4_0001"
tt.render.sprites[2].name = "stage8_symon_fungus4_0002"
tt.render.sprites[3].name = "stage8_symon_fungus4_0003"
tt.sound_events.touch = "ElvesSimonBlue"
--#endregion
--#region simon_gnome_mushrooom_glow
tt = RT("simon_gnome_mushrooom_glow", "decal_tween")

AC(tt, "ui")

tt.ui.can_select = false
tt.ui.click_rect = r(-20, -20, 40, 50)
tt.render.sprites[1].name = "stage8_symon_bigGlow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}}
tt.tween.remove = false
--#endregion
--#region simon_gnome
tt = RT("simon_gnome", "decal")
tt.render.sprites[1].prefix = "simon_gnome"
tt.render.sprites[1].sort_y_offset = -38
--#endregion
--#region simon_gnome_fx
tt = RT("simon_gnome_fx", "fx")
tt.render.sprites[1].name = "simon_gnome_fx"
--#endregion
--#region simon_gnome_sign
tt = RT("simon_gnome_sign", "fx")
tt.render.sprites[1].name = "simon_gnome_sign"
tt.render.sprites[1].offset = vec_2(30, 15)
--#endregion
--#region decal_drow_queen_portal
tt = RT("decal_drow_queen_portal", "decal_scripted")

AC(tt, "editor", "tween")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_portal_0001"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "stage11_portal_0002"
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "stage11_portal_0003"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "stage11_portal_0004"
tt.main_script.update = scripts.decal_drow_queen_portal.update
tt.spawn_offsets = {vec_2(0, 0), vec_2(0, -20), vec_2(0, 20)}
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(7), 255}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 4
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].sprite_id = 4
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_1(1)}, {fts(23), vec_1(1.2)}}
tt.tween.props[4].loop = true
tt.tween.props[4].ignore_reverse = true
tt.pack_pi = nil
tt.pack = nil
tt.pack_finished = nil
--#endregion
--#region fx_drow_queen_portal
tt = RT("fx_drow_queen_portal", "fx")
tt.render.sprites[1].name = "fx_drow_queen_portal"
tt.render.sprites[1].anchor.y = 0.22
--#endregion
--#region decal_s11_door_glow
tt = RT("decal_s11_door_glow", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_doorGlow"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -30
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 100}, {0.3, 200}, {0.6, 130}, {0.9, 255}, {1.2, 100}}
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.5, 1}, {4.8, 1}, {6, 0}}
tt.tween.props[2].multiply = true
tt.editor.tag = 1
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
--#endregion
--#region decal_s11_zealot_rune
tt = RT("decal_s11_zealot_rune", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].offset = vec_2(-40, 0)
tt.render.sprites[1].name = "stage11_zealotRune"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}}
tt.editor.tag = 1
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].alpha"] = 255
}
--#endregion
--#region decal_s11_mactans
tt = RT("decal_s11_mactans", "decal")
tt.render.sprites[1].prefix = "mactans"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.drop_duration = 4
tt.retreat_duration = 4
tt.netting_duration = 2.6
--#endregion
--#region decal_mactans_thread
tt = RT("decal_mactans_thread", "decal")

for i = 1, math.ceil(48) do
	local s = CC("sprite")

	s.name = i % 2 == 0 and "mactans_particles_0010" or "mactans_particles_0010"
	s.animated = false
	s.anchor.y = 0
	s.offset.y = i * 16 + 60
	s.flip_x = math.random() < 0.5
	s.z = Z_OBJECTS_SKY
	tt.render.sprites[i] = s
end

--#endregion
--#region decal_mactans_shadow
tt = RT("decal_mactans_shadow", "decal_tween")
tt.render.sprites[1].name = "mactans_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {4, 255}}
--#endregion
--#region decal_mactans_webbing
tt = RT("decal_mactans_webbing", "decal")
tt.render.sprites[1].name = "mactans_decal1"
tt.render.sprites[1].time_offset = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mactans_decal2"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "mactans_decal3"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].name = "mactans_decal4"
--#endregion
--#region decal_s11_drow_queen_cocoon
tt = RT("decal_s11_drow_queen_cocoon", "decal")
tt.render.sprites[1].prefix = "s11_malicia"
tt.render.sprites[1].name = "spiderNet"
tt.render.sprites[1].loop = false
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].offset = vec_2(-8, 15)
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].z = Z_OBJECTS_SKY - 1
--#endregion
--#region decal_metropolis_floating_rock
tt = RT("decal_metropolis_floating_rock", "decal_tween")
tt.render.sprites[1].animated = false
tt.tween.random_ts = fts(80)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 1)}, {fts(20), vec_2(0, 2)}, {fts(40), vec_2(0, 1)}, {fts(60), vec_2(0, 0)}, {fts(80), vec_2(0, 1)}}
tt.tween.props[1].loop = true
--#endregion
--#region decal_s12_lemur
tt = RT("decal_s12_lemur", "decal_scripted")

AC(tt, "nav_path", "motion", "tween", "ui")

tt.render.sprites[1].prefix = "decal_s12_lemur"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.13333333333333333
tt.render.sprites[1].alpha = 0
tt.motion.max_speed = 60
tt.achievement = "LIKE_TO_MOVE_IT"
tt.action_ni = 12
tt.fade_ni = 18
tt.wait_time = {5, 10}
tt.show_time = {1, 3}
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.main_script.update = scripts.decal_s12_lemur.update
tt.ui.click_rect = r(-15, 0, 30, 30)
--#endregion
--#region birds_formation_controller
tt = RT("birds_formation_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.birds_formation_controller.update
tt.wait_time = {20, 60}
tt.bird_template = "decal_bird_formation"
--#endregion
--#region decal_bird_formation
tt = RT("decal_bird_formation", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "offset"
tt.render.sprites[1].z = Z_OBJECTS_SKY
--#endregion
--#region decal_metropolis_portal
tt = RT("decal_metropolis_portal", "decal_scripted")

AC(tt, "tween", "editor")

tt.main_script.update = scripts.decal_metropolis_portal.update
tt.render.sprites[1].prefix = "decal_metropolis_portal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_metropolis_portal"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].anchor.y = 0.07142857142857142
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].random_ts = 0.5
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = vec_2(-27, -5)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = vec_2(27, -19)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = vec_2(12, 0)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[6].offset = vec_2(-11, -19)
tt.tween.ts = -1
tt.tween.reverse = true
tt.tween.remove = false

for i = 1, 6 do
	tt.tween.props[i] = CC("tween_prop")
	tt.tween.props[i].keys = {{0, 0}, {0.5, 255}}
	tt.tween.props[i].sprite_id = i
end

tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].name"] = "loop"
}
tt.detection_tags = {}
tt.detection_pahts = nil
tt.detection_rect = r(-60, -40, 120, 80)
tt.vis_flags = 0
tt.vis_bans = F_BOSS
--#endregion
--#region aura_metropolis_portal
tt = RT("aura_metropolis_portal", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_metropolis_portal"
tt.aura.cycle_time = fts(1)
tt.aura.radius = 35
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS)
tt.aura.vis_flags = bor(F_TELEPORT)
--#endregion
--#region mod_metropolis_portal
tt = RT("mod_metropolis_portal", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.jump_connection = true
tt.delay_start = fts(2)
tt.hold_time = 0
tt.fx_start = "fx_teleport_metropolis"
tt.fx_end = "fx_teleport_metropolis"
--#endregion
--#region fx_teleport_metropolis
tt = RT("fx_teleport_metropolis", "fx")
tt.render.sprites[1].name = "fx_teleport_metropolis"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1), vec_1(1.5)}
--#endregion
--#region decal_s13_relic_book
tt = RT("decal_s13_relic_book", "decal_delayed_click_play")

AC(tt, "tween")

tt.render.sprites[1].prefix = "decal_s13_relic_book"
tt.ui.click_rect = r(-20, -30, 40, 30)
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 6
tt.delayed_play.required_clicks = 1
tt.delayed_play.achievement_flag = {"SORCERERS_APPRENTICE", 1}
tt.delayed_play.play_once = true
tt.delayed_play.clicked_sound = "ElvesAchievementSorcapprenticeBook"
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0, 1)}, {fts(60), vec_2(0, -1)}, {fts(80), vec_2(0, 0)}}
--#endregion
--#region decal_s13_relic_broom
tt = RT("decal_s13_relic_broom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s13_relic_broom"
tt.ui.click_rect = r(24, 0, 40, 50)
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 2}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeBroom"
--#endregion
--#region decal_s13_relic_hat
tt = RT("decal_s13_relic_hat", "decal_click_play")

AC(tt, "tween")

tt.render.sprites[1].prefix = "decal_s13_relic_hat"
tt.ui.click_rect = r(-20, -40, 40, 30)
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0, 1)}, {fts(60), vec_2(0, -1)}, {fts(80), vec_2(0, 0)}}
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 4}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeHat"
--#endregion
--#region tower_black_baby_dragon
tt = RT("tower_black_baby_dragon", "tower")

AC(tt, "attacks", "user_selection")

tt.tower.type = "baby_black_dragon"
tt.tower.can_be_mod = false
tt.tower.can_hover = false
tt.tower.terrain_style = nil
tt.info.i18n_key = "ELVES_BABY_BERESAD"
tt.info.fn = scripts.tower_black_baby_dragon.get_info
tt.info.portrait = "kr3_info_portraits_towers_0015"
tt.main_script.update = scripts.tower_black_baby_dragon.update
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].price = 100
tt.render = nil
tt.user_selection.ignore_point = true
--#endregion
--#region decal_black_baby_dragon
tt = RT("decal_black_baby_dragon", "decal_scripted")

AC(tt, "motion", "attacks", "tween", "sound_events", "nav_path")

tt.main_script.update = scripts.decal_black_baby_dragon.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = CC("aura_attack")
tt.attacks.list[1].cooldown = 0.2
tt.attacks.list[1].range = 30
tt.attacks.list[1].aura = "aura_black_baby_dragon"
tt.render.sprites[1].prefix = "babyBeresad"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.10227272727272728
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "babyBeresad"
tt.render.sprites[2].name = "zzz"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loope = false
tt.render.sprites[2].anchor.y = 0.10227272727272728
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "Stage12_Dragon_Shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = -1
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "baby_beresad_flame_hit"
tt.render.sprites[4].hidden = true
tt.render.sprites[4].sort_y_offset = -10
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {fts(8), 0}}
tt.tween.props[1].sprite_id = 2
tt.wakeup_cooldown_min = 5
tt.wakeup_cooldown_max = 16
tt.sleep_pos = nil
tt.dragon_passes = {{
	path_id = 8,
	ranges = {{10, 75}, {125, 220}}
}, {
	path_id = 9,
	ranges = {{80, 120}}
}, {
	path_id = 10,
	ranges = {{80, 140}}
}}
tt.sound_events.fire_loop = "ElvesBlackBabyFirebreathLoop"
tt.sound_events.fire_start = "ElvesBlackBabyFirebreathLoopStart"
tt.sound_events.fire_stop = "ElvesBlackBabyFirebreathLoopEnd"
--#endregion
--#region aura_black_baby_dragon
tt = RT("aura_black_baby_dragon", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.mod = "mod_black_baby_dragon"
tt.aura.radius = 50
tt.aura.cycle_time = fts(6)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "babyBeresad_fireDecal_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "aura_baby_beresad_fire"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {"this.aura.duration-0.7", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
--#endregion
--#region mod_black_baby_dragon
tt = RT("mod_black_baby_dragon", "mod_lava")
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].size_scales = {vec_1(0.85), vec_1(1), vec_1(1)}
tt.render.sprites[1].prefix = "mod_baby_beresad"
tt.render.sprites[1].name = "big"
tt.modifier.duration = 1
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = 0.2
tt.insert_damage = 150
tt.main_script.insert = scripts.mod_black_baby_dragon.insert
--#endregion
--#region ps_baby_black_dragon_flame
tt = RT("ps_baby_black_dragon_flame")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_direction = -math.pi / 6
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.emit_spread = math.pi / 24
tt.particle_system.emit_rotation = 0
tt.particle_system.emit_speed = {18 * FPS, 22 * FPS}
tt.particle_system.loop = false
tt.particle_system.name = "ps_baby_beresad_flame"
tt.particle_system.particle_lifetime = {fts(5), fts(5)}
tt.particle_system.scale_same_aspect = true
tt.particle_system.scales_x = {1, 1}
tt.particle_system.z = Z_OBJECTS
--#endregion
--#region fx_baby_black_dragon_flame_hit
tt = RT("fx_baby_black_dragon_flame_hit", "decal_tween")
tt.render.sprites[1].name = "baby_beresad_flame_hit"
tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}
--#endregion
--#region tower_holder_baby_ashbite
tt = RT("tower_holder_baby_ashbite", "tower")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "tween")

tt.tower.level = 1
tt.tower.type = "holder_baby_ashbite"
tt.tower.can_be_mod = false
tt.info.fn = scripts.tower_baby_ashbite.get_info
tt.info.portrait = "kr3_info_portraits_towers_0019"
tt.info.i18n_key = "TOWER_BABY_ASHBITE"
tt.info.damage_icon = "fireball"
tt.render.sprites[1].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(0, 26)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 26)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "babyAshbite_tower_layer2_0001"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = vec_2(0, 26)
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "babyAshbite_tower_layer2_0004"
tt.render.sprites[4].animated = false
tt.render.sprites[4].offset = vec_2(0, 26)
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
--#endregion
--#region decal_s14_break_egg
tt = RT("decal_s14_break_egg", "decal_scripted")

AC(tt, "ui", "click_play", "tween")

tt.render.sprites[1].prefix = "decal_s14_break_egg"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.38235294117647056
tt.main_script.update = scripts.decal_s14_break_spider.update
tt.click_play.required_clicks = 5
tt.ui.can_select = false
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(1), vec_1(1.2)}, {fts(6), vec_1(1)}}
--#endregion
--#region decal_s14_break_spider
tt = RT("decal_s14_break_spider", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "decal_s14_break_spider"
tt.tween.props[1].keys = {{0, 255}, {0.75, 255}, {1, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {2, vec_2(1, 1)}}
--#endregion
--#region decal_s15_mactans
tt = RT("decal_s15_mactans", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "stage15_mactans_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09047619047619047
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage15_mactans_l2"
tt.main_script.update = scripts.decal_s15_mactans.update
--#endregion
--#region decal_s15_malicia
tt = RT("decal_s15_malicia", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "stage15_malicia"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.057692307692307696
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "stage15_malicia_ray"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].anchor = vec_2(0.64, 0.21666666666666667)
tt.render.sprites[2].offset = vec_2(-2, 57)
tt.main_script.update = scripts.decal_s15_malicia.update
--#endregion
--#region decal_s15_statue
tt = RT("decal_s15_statue", "decal_scripted")

AC(tt, "editor")

tt.main_script.update = scripts.decal_s15_statue.update
tt.render.sprites[1].prefix = "stage15_shield"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.20161290322580644
--#endregion
--#region decal_s15_crystal
tt = RT("decal_s15_crystal", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_crystal"
tt.render.sprites[1].animated = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 2)}, {fts(25), vec_2(0, -2)}, {fts(50), vec_2(0, 2)}}
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
--#endregion
--#region fx_s15_crystal_shine
tt = RT("fx_s15_crystal_shine", "fx")
tt.render.sprites[1].name = "stage15_crystal_fx"
--#endregion
--#region fx_s15_crystal_transformation
tt = RT("fx_s15_crystal_transformation", "fx")

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "stage15_crystal_l" .. i
	tt.render.sprites[i].name = "explosion"
end

--#endregion
--#region fx_s15_white_circle
tt = RT("fx_s15_white_circle", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{fts(3), vec_1(0.3)}, {fts(6), vec_1(70)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 255}, {1, 255}, {2, 0}}
--#endregion
--#region decal_s15_finished_gem
tt = RT("decal_s15_finished_gem", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_bossDecal_gem"
tt.render.sprites[1].anchor.y = 0.22580645161290322
tt.render.sprites[1].animated = false
--#endregion
--#region decal_s15_finished_veznan
tt = RT("decal_s15_finished_veznan", "decal_delayed_play")

AC(tt, "editor")

tt.render.sprites[1].prefix = "decal_s15_finished_veznan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.1111111111111111
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
--#endregion
--#region decal_s15_finished_guard
tt = RT("decal_s15_finished_guard", "decal_delayed_sequence")

AC(tt, "editor")

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "decal_s15_finished_guard_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].anchor.y = 0.12195121951219512
	tt.render.sprites[i].loop = i > 2
	tt.render.sprites[i].hidden = i == 4
end

tt.delayed_sequence.animations = {"idle", "blink", "blink", "sleep"}
tt.delayed_sequence.min_delay = 5
tt.delayed_sequence.max_delay = 15
tt.delayed_sequence.random = nil
--#endregion
--#region decal_s15_finished_guard_flipped
tt = RT("decal_s15_finished_guard_flipped", "decal_s15_finished_guard")

for i = 1, 4 do
	tt.render.sprites[i].flip_x = true
	tt.render.sprites[i].hidden = i == 3
end

--#endregion
--#region taunts_s15_controller
tt = RT("taunts_s15_controller")

AC(tt, "main_script", "taunts", "editor")

tt.load_file = "level63_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.mactans = CC("taunt_set")
tt.taunts.sets.mactans.format = "ELVES_ENEMY_MACTANS_TAUNT_%04i"
tt.taunts.sets.mactans.end_idx = 8
tt.taunts.sets.mactans.decal_name = "decal_s15_mactans_shoutbox"
tt.taunts.sets.mactans.pos = vec_2(453, 591)
tt.taunts.sets.malicia = CC("taunt_set")
tt.taunts.sets.malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_%04i"
tt.taunts.sets.malicia.end_idx = 8
tt.taunts.sets.malicia.decal_name = "decal_s15_malicia_shoutbox"
tt.taunts.sets.malicia.pos = vec_2(653, 591)
tt.taunts.sets.welcome_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.welcome_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0001"
tt.taunts.sets.welcome_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.welcome_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_WELCOME_0002"
tt.taunts.sets.pre_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.pre_mactans.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_mactans.idxs = {2, 4}
tt.taunts.sets.pre_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.pre_malicia.format = "ELVES_ENEMY_MALICIA_MACTANS_TAUNT_KIND_PREBATTLE_%04i"
tt.taunts.sets.pre_malicia.idxs = {1, 3}
tt.taunts.sets.custom_malicia = table.deepclone(tt.taunts.sets.malicia)
tt.taunts.sets.custom_malicia.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
tt.taunts.sets.custom_mactans = table.deepclone(tt.taunts.sets.mactans)
tt.taunts.sets.custom_mactans.format = "ELVES_ENEMY_MALICIA_TAUNT_KIND_%s"
--#endregion
--#region decal_s15_mactans_shoutbox
tt = RT("decal_s15_mactans_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[1].name = "stage15_taunts_0004"
tt.render.sprites[2].name = "stage15_taunts_0005"
tt.texts.list[1].font_size = 28
tt.texts.list[1].color = {247, 133, 102}
--#endregion
--#region decal_s15_malicia_shoutbox
tt = RT("decal_s15_malicia_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[2].name = "stage15_taunts_0002"
tt.texts.list[1].font_size = 28
--#endregion
--#region decal_hr_crystal_skull
tt = RT("decal_hr_crystal_skull", "decal_delayed_click_play")
tt.render.sprites[1].prefix = "decal_hr_crystal_skull"
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 1
tt.delayed_play.click_interrupts = true
tt.delayed_play.clicked_sound = "ElvesCrystalSkull"
tt.ui.can_select = false
tt.ui.click_rect = r(-13, -13, 28, 24)
--#endregion
--#region decal_s16_land_1
tt = RT("decal_s16_land_1", "decal_background")

AC(tt, "tween")

tt.render.sprites[1].name = "Stage16_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
--#endregion
--#region decal_s16_land_2
tt = RT("decal_s16_land_2", "decal_s16_land_1")
tt.render.sprites[1].name = "Stage04_0002"
tt.render.sprites[1].z = Z_DECALS - 1
--#endregion
--#region decal_s16_ground_archers_land
tt = RT("decal_s16_ground_archers_land", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "groundArchers"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
--#endregion
--#region soldier_s16_ground_archer
tt = RT("soldier_s16_ground_archer", "soldier_gryphon_guard_upper")

AC(tt, "editor")

tt.ranged.attacks[1].filter_fn = nil
tt.render.sprites[1].prefix = "soldier_s16_ground_archer"
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 30
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region decal_s16_bush_holder
tt = RT("decal_s16_bush_holder", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushHolders"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
--#endregion
--#region decal_s16_bush_burner
tt = RT("decal_s16_bush_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushGnollBurner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2777777777777778
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
--#endregion
--#region fx_s16_bush_burner
tt = RT("fx_s16_bush_burner", "fx")
tt.render.sprites[1].name = "fx_s16_bush_burner"
tt.render.sprites[1].anchor.y = 0.3548387096774194
--#endregion
--#region fx_s16_burner_explosion
tt = RT("fx_s16_burner_explosion", "decal_timed")

AC(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s16_burner_explosion"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor.y = 0.09740259740259741
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].loop"] = true
}
--#endregion
--#region gnoll_bush_spawner
tt = RT("gnoll_bush_spawner", "decal_scripted")

AC(tt, "spawner", "editor")

tt.render.sprites[1].name = "stage16_bushSpawner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2833333333333333
tt.spawner.eternal = true
tt.spawner.entity = "gnoll_bush"
tt.spawner.allowed_subpaths = {1}
tt.spawner.ni = 1
tt.main_script.update = scripts.gnoll_bush_spawner.update
tt.spawn_node_offset = 0
tt.spawn_once = nil
tt.spawn_data = nil
tt.editor.props = {{"spawner.name", PT_STRING}, {"spawner.pi", PT_NUMBER}}
--#endregion
--#region gnoll_bush
tt = RT("gnoll_bush", "decal_scripted")

AC(tt, "nav_path", "motion", "main_script", "spawner", "unit")

tt.render.sprites[1].prefix = "gnollBush"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.gnoll_bush.update
tt.motion.max_speed = 75
tt.spawn_sound = "ElvesGnollTrailOut"
tt.spawner.entity = nil
tt.spawner.count = 1
tt.spawner.random_subpath = true
tt.spawner.patch_props = {
	enemy = {
		gold = 0
	}
}
tt.walk_nodes_range = {5, 10}
tt.walk_wait = 1
--#endregion
--#region decal_hr_cart
tt = RT("decal_hr_cart", "decal")
tt.render.sprites[1].name = "stage17_carret"
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt.render.sprites[1].animated = false
--#endregion
--#region decal_hr_worker_a
tt = RT("decal_hr_worker_a", "decal")
tt.render.sprites[1].name = "decal_hr_worker_a"
tt.render.sprites[1].anchor.y = 0.027777777777777776
--#endregion
--#region decal_hr_worker_b
tt = RT("decal_hr_worker_b", "decal")
tt.render.sprites[1].name = "decal_hr_worker_b"
tt.render.sprites[1].anchor.y = 0.20833333333333334
--#endregion
--#region malik_slave_controller
tt = RT("malik_slave_controller", "decal_scripted")

AC(tt, "editor")

tt.fn_can_power = scripts.malik_slave_controller.fn_can_power
tt.hero_spawn_pos = vec_2(736, 639)
tt.main_script.update = scripts.malik_slave_controller.update
tt.starting_wave = 2
tt.thunder_rect = r(655, 595, 164, 56)
tt.wait_time = fts(159)
tt.achievement_id = "FREEDOM_FIGHTER"
tt.walk_points = {
	malik = {vec_2(973, 655), vec_2(808, 632), vec_2(748, 666)},
	gnoll_left = {vec_2(935, 651), vec_2(700, 605)},
	gnoll_right = {vec_2(1016, 673), vec_2(795, 631)}
}
--#endregion
--#region decal_gnoll_gnawer
tt = RT("decal_gnoll_gnawer", "decal_scripted")

AC(tt, "motion", "nav_grid", "motion", "tween")

tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].prefix = "gnoll_gnawer"
tt.render.sprites[1].name = "idle"
tt.motion.max_speed = 2 * FPS
tt.main_script.update = scripts.decal_walking.update
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
--#endregion
--#region decal_baby_malik_slave
tt = RT("decal_baby_malik_slave", "decal_scripted")

AC(tt, "motion", "nav_grid", "motion")

tt.render.sprites[1].anchor.y = 0.184
tt.render.sprites[1].prefix = "decal_baby_malik"
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.decal_walking.update
tt.motion.max_speed = 2 * FPS
tt.main_script.update = scripts.decal_walking.update
--#endregion
--#region decal_baby_malik_slave_banner
tt = RT("decal_baby_malik_slave_banner", "decal_tween")
tt.render.sprites[1].name = "malikAfro_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(30, 66)
tt.tween.ts = -10
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 100}, {fts(4), 255}, {fts(71), 255}, {fts(75), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.75)}, {fts(4), vec_1(1.075)}, {fts(7), vec_1(0.9625)}, {fts(9), vec_1(1)}, {fts(69), vec_1(1)}, {fts(71), vec_1(1.075)}, {fts(75), vec_1(0.75)}}
--#endregion
--#region decal_baby_malik_slave_free
tt = RT("decal_baby_malik_slave_free", "decal")
tt.render.sprites[1].name = "decal_baby_malik_free"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0.33101851851851855, 0.27976190476190477)
--#endregion
--#region decal_s18_statue
tt = RT("decal_s18_statue", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage18_statue"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.176056338028169
--#endregion
--#region decal_s18_roadrunner_bush
tt = RT("decal_s18_roadrunner_bush", "decal_scripted")

AC(tt, "editor", "ui")

tt.render.sprites[1].name = "decal_s18_roadrunner_bush_shake"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.3
tt.main_script.update = scripts.decal_s18_roadrunner_bush.update
tt.required_clicks = {3, 5}
tt.shake_cooldown = {3, 5}
tt.sound_clicked = "ElvesGnollTrailOut"
tt.ui.click_rect = r(-22, -10, 44, 40)
tt.ui.can_select = false
--#endregion
--#region fx_roadruner_bush_explode
tt = RT("fx_roadruner_bush_explode", "fx")
tt.render.sprites[1].name = "gnollBush_explode"
tt.render.sprites[1].anchor.y = 0.3548387096774194
--#endregion
--#region decal_s18_roadrunner
tt = RT("decal_s18_roadrunner", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_s18_roadrunner_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.125
tt.pos = vec_2(464, 473)
tt.sound_events.insert = "ElvesRoadRunner"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {2.2, vec_2(-369, 14)}}
--#endregion
--#region decal_s18_coyote
tt = RT("decal_s18_coyote", "decal")

AC(tt, "sound_events")

tt.render.sprites[1].prefix = "decal_s18_coyote"
tt.render.sprites[1].name = "pull"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.pos = vec_2(138, 383)
tt.sound_events.push = "BombExplosionSound"
--#endregion
--#region decal_s18_flag_head
tt = RT("decal_s18_flag_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s18_flag_head"
--#endregion
--#region decal_s18_boss_head
tt = RT("decal_s18_boss_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage_18_head"
tt.render.sprites[1].animated = false
--#endregion
--#region taunts_s18_defeated_controller
tt = RT("taunts_s18_defeated_controller")

AC(tt, "main_script", "taunts", "editor")

tt.load_file = "level66_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.left_head = CC("taunt_set")
tt.taunts.sets.left_head.end_idx = 8
tt.taunts.sets.left_head.format = "ELVES_ENEMY_BRAM_TAUNT_%04i"
tt.taunts.sets.left_head.decal_name = "decal_s18_shoutbox"
tt.taunts.sets.left_head.pos = vec_2(727, 700)
tt.taunts.sets.right_head = CC("taunt_set")
tt.taunts.sets.right_head.end_idx = 8
tt.taunts.sets.right_head.format = "ELVES_ENEMY_DEATH_TAUNT_%04i"
tt.taunts.sets.right_head.decal_name = "decal_s18_shoutbox"
tt.taunts.sets.right_head.pos = vec_2(791, 680)
--#endregion
--#region decal_s18_shoutbox
tt = RT("decal_s18_shoutbox", "decal_tween")

AC(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "theBeheader_taunt"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, 1)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(180, 58)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 22
tt.texts.list[1].color = {229, 86, 86}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 2
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
--#endregion
--#region decal_s19_drizzt
tt = RT("decal_s19_drizzt", "decal_scripted")

AC(tt, "editor", "ui")

tt.render.sprites[1].prefix = "decal_s19_drizzt"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_s19_drizzt.update
tt.idle_cooldown = {3, 5}
tt.spawn_cooldown = {10, 15}
tt.sound_clicked = "ElvesDrizztGrowl"
tt.sound_chase = "ElvesDrizztUnsheathe"
tt.sound_chase_params = {
	delay = fts(23)
}
tt.ui.click_rect = r(90, -30, 40, 30)
tt.ui.can_select = false
--#endregion
--#region decal_s19_drizzt_gnoll
tt = RT("decal_s19_drizzt_gnoll", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s19_drizzt_gnoll"
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.decal_s19_drizzt_gnoll.update
--#endregion
--#region decal_s21_lava_bubble
tt = RT("decal_s21_lava_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s21_lava_bubble"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1.5)
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 5
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
--#endregion
--#region decal_s22_lava_bubble
tt = RT("decal_s22_lava_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_bubble"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1.5)
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 5
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
--#endregion
--#region decal_s22_lava_hole
tt = RT("decal_s22_lava_hole", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_hole"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1)
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 2
tt.delayed_play.idle_animation = nil
--#endregion
--#region decal_s22_lava_smoke
tt = RT("decal_s22_lava_smoke", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_smoke"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].alpha = 200
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1)
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 8
tt.delayed_play.idle_animation = nil
--#endregion
--#region lava_fireball_controller
tt = RT("lava_fireball_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.lava_fireball_controller.update
tt.bullet = "bomb_lava_fireball"
tt.launch_fx = "fx_bomb_lava_fireball_launch"
--#endregion
--#region bomb_lava_fireball
tt = RT("bomb_lava_fireball", "bullet")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 200
tt.bullet.damage_radius = 45
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time_base = fts(25)
tt.bullet.flight_time_factor = fts(0.05)
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_bomb_lava_fireball_explosion"
tt.bullet.mod = "mod_veznan_demon_fire"
tt.bullet.particles_name = "ps_bomb_lava_fireball"
tt.bullet.pop = {"pop_entwood"}
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Stage9_lavaShot"
tt.sound_events.hit = "BombExplosionSound"
--#endregion
--#region fx_bomb_lava_fireball_launch
tt = RT("fx_bomb_lava_fireball_launch", "fx")
tt.render.sprites[1].name = "fx_bomb_lava_fireball_launch"
--#endregion
--#region fx_bomb_lava_fireball_explosion
tt = RT("fx_bomb_lava_fireball_explosion", "fx")
tt.render.sprites[1].name = "fireball_explosion"
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region decal_stage81_burner
tt = RT("decal_stage81_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s81_burner"
--#endregion
--#region decal_endless_shoutbox
tt = RT("decal_endless_shoutbox", "decal_s18_shoutbox")
tt.render.sprites[1].name = "hee-haw_taunt"
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].size = vec_2(180, 58)
tt.texts.list[1].font_size = 20
--#endregion
--#region decal_regson_heal_ball
tt = RT("decal_regson_heal_ball", "decal_scripted")

AC(tt, "force_motion")

tt.render.sprites[1].name = "regson_heal_ball_travel"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.hp_factor = nil
tt.force_motion.max_a = 5400
tt.force_motion.max_v = 180
tt.force_motion.a_step = 10
tt.force_motion.max_flight_height = 60
tt.main_script.update = scripts.decal_regson_heal_ball.update
tt.fx_spawn = "fx_regson_heal_ball_spawn"
tt.fx_receive = "fx_regson_heal"
--#endregion
--#region fx_regson_heal_ball_spawn
tt = RT("fx_regson_heal_ball_spawn", "fx")
tt.render.sprites[1].name = "fx_regson_heal_ball_spawn"
tt.render.sprites[1].anchor.y = 0.35
--#endregion
--#region fx_regson_heal
tt = RT("fx_regson_heal", "fx")
tt.render.sprites[1].name = "fx_regson_heal"
tt.render.sprites[1].sort_y_offset = -1
--#endregion
--#region decal_alric_soul_ball
tt = RT("decal_alric_soul_ball", "decal_regson_heal_ball")
tt.render.sprites[1].color = {255, 122, 0}
tt.hp_factor = 0.1
tt.fx_spawn = "fx_alric_soul_ball_spawn"
tt.fx_receive = "fx_alric_receive_soul"
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
tt.render.sprites[2].scale = vec_1(0.9)
tt.side_effect = function(hero, store)
	local cool_next = hero.melee.attacks[3].cooldown - (hero.melee.attacks[3].ts - store.tick_ts)

	if cool_next > 0 then
		hero.melee.attacks[3].ts = hero.melee.attacks[3].ts - cool_next * 0.1
	end
end
--#endregion
--#region fx_alric_soul_ball_spawn
tt = RT("fx_alric_soul_ball_spawn", "fx_regson_heal_ball_spawn")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
--#endregion
--#region fx_alric_receive_soul
tt = RT("fx_alric_receive_soul", "fx_regson_heal")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200
-- kr5
--#endregion
--#region ps_hero_hunter_walk_trail
tt = RT("ps_hero_hunter_walk_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "mist_run_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = d2r(45)
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.emit_speed = {5, 25}
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_offsets = {vec_2(13, 12), vec_2(-13, 12)}
tt.particle_system.z = Z_OBJECTS
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.emit_direction = d2r(90)
--#endregion
--#region fx_hero_hunter_skill_heal_strike_hit
tt = RT("fx_hero_hunter_skill_heal_strike_hit", "fx")
tt.render.sprites[1].name = "mistystep_hit_run"
--#endregion
--#region fx_hero_hunter_ranged_attack
tt = RT("fx_hero_hunter_ranged_attack", "fx")
tt.render.sprites[1].name = "shothit_run"
--#endregion
--#region fx_hero_hunter_skill_ricochet_hit
tt = RT("fx_hero_hunter_skill_ricochet_hit", "fx")
tt.render.sprites[1].name = "mistystep_hit_run"
--#endregion
--#region fx_hero_hunter_skill_shoot_around_decal
tt = RT("fx_hero_hunter_skill_shoot_around_decal", "fx")
tt.render.sprites[1].name = "argent_storm_decal_run"
--#endregion
--#region fx_hero_hunter_ultimate_hit
tt = RT("fx_hero_hunter_ultimate_hit", "fx")
tt.render.sprites[1].name = "hit_dante_run"
--#endregion
--#region fx_hero_hunter_steal
tt = RT("fx_hero_hunter_steal", "fx")
tt.render.sprites[1].name = "duskbeast_coin_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
--#endregion
--#region ps_hero_space_elf_basic_attack_trail
tt = RT("ps_hero_space_elf_basic_attack_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_therien_ranged_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_area_spread = vec_2(5, 5)
--#endregion
--#region fx_hero_space_elf_ranged_hit
tt = RT("fx_hero_space_elf_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_therien_ranged_hit_idle"
--#endregion
--#region fx_hero_space_elf_melee_hit
tt = RT("fx_hero_space_elf_melee_hit", "fx")
tt.render.sprites[1].name = "hero_therien_melee_hit_idle"
--#endregion
--#region fx_hero_space_elf_astral_reflection_spawn
tt = RT("fx_hero_space_elf_astral_reflection_spawn", "fx")
tt.render.sprites[1].name = "hero_therien_reflection_spawn_fx_idle"
--#endregion
--#region fx_hero_space_elf_black_aegis_hit
tt = RT("fx_hero_space_elf_black_aegis_hit", "fx")
tt.render.sprites[1].name = "hero_therien_black_aegis_hit"
--#endregion
--#region decal_hero_space_elf_ultimate
tt = RT("decal_hero_space_elf_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_therien_void_prison_floor_fx_idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = true
--#endregion
--#region decal_hero_space_elf_ultimate_mod
tt = RT("decal_hero_space_elf_ultimate_mod", "decal_tween")
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.13, 0}}
--#endregion
--#region decal_hero_space_elf_void_rift_therien
tt = RT("decal_hero_space_elf_void_rift_therien", "decal_tween")
tt.render.sprites[1].name = "hero_therien_rift_therien_fx_idle"
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = true
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {1.5, 255}, {1.8, 0}}
tt.tween.remove = true
--#endregion
--#region hero_raelyn_command_orders_hit_fx
tt = RT("hero_raelyn_command_orders_hit_fx", "fx")
tt.render.sprites[1].name = "hero_raelyn_command_orders_hit_fx_Idle1_1"
--#endregion
--#region hero_raelyn_ultimate_entity_spawn_mod_decal
tt = RT("hero_raelyn_ultimate_entity_spawn_mod_decal", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(21)
tt.render.sprites[1].name = "hero_raelyn_command_orders_spawn_fx_Idle1_1"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.modifier.use_mod_offset = false
tt.main_script.update = scripts.mod_track_target.update
--#endregion
--#region decal_hero_raelyn_onslaught_decal
tt = RT("decal_hero_raelyn_onslaught_decal", "decal_tween")
tt.render.sprites[1].name = "hero_raelyn_onslaught_fx_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hide_after_runs = 1
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
--#endregion
--#region fx_hero_venom_melee_attack_hit
tt = RT("fx_hero_venom_melee_attack_hit", "fx5")
tt.render.sprites[1].name = "hero_venom_hit_fx_idle"
tt.render.sprites[1].z = Z_BULLETS + 1
--#endregion
--#region fx_hero_venom_beast_lvl_up
tt = RT("fx_hero_venom_beast_lvl_up", "fx5")
tt.render.sprites[1].name = "hero_venom_levelup_fx_idle"
--#endregion
--#region decal_hero_venom_slimewalk
tt = RT("decal_hero_venom_slimewalk", "decal_timed")
tt.render.sprites[1].prefix = "hero_venom_run_particle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].fps = 15
tt.timed.duration = fts(20)
--#endregion
--#region decal_hero_venom_spike_b
tt = RT("decal_hero_venom_spike_b", "decal_hero_venom_spike_a")
tt.render.sprites[1].prefix = "hero_venom_spike_b"
--#endregion
--#region decal_hero_venom_death
tt = RT("decal_hero_venom_death", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1].prefix = "hero_venom_death_decal"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_hero_venom_death.update
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {1, 255}}
tt.tween.remove = false
--#endregion
--#region ps_hero_witch_ranged_basic_trail
tt = RT("ps_hero_witch_ranged_basic_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_witch_ranged_attack_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.particle_lifetime = {fts(5), fts(8)}
tt.particle_system.emit_rotation_spread = math.pi * 0.5
--#endregion
--#region ps_hero_witch_spark_1
tt = RT("ps_hero_witch_spark_1")

AC(tt, "pos", "particle_system", "main_script")

tt.particle_system.name = "hero_witch_walk_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.particle_lifetime = {fts(25), fts(30)}
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 1)
tt.particle_system.emit_direction = 2 * math.pi / 3
tt.particle_system.emit_speed = {10, 10}
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_offset = vec_2(-15, 0)
tt.particle_system.z = Z_OBJECTS
tt.particle_system.animation_fps = 15
tt.particle_system.sort_y_offset = -40
tt.main_script.update = scripts.ps_hero_mecha_smoke.update
tt.emit_direction_sides = {2 * math.pi / 3, math.pi / 3}
--#endregion
--#region ps_bullet_hero_witch_skill_polymorph
tt = RT("ps_bullet_hero_witch_skill_polymorph")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "hero_witch_skill_1_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(8, 8)
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_offset = vec_2(0, 0)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.emit_offset_relative = vec_2(-15, 0)
--#endregion
--#region fx_hero_witch_basic_ranged_hit
tt = RT("fx_hero_witch_basic_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_witch_ranged_attack_hit"
tt.render.sprites[1].scale = vec_1(1)
--#endregion
--#region fx_hero_witch_ultimate
tt = RT("fx_hero_witch_ultimate", "fx")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_fx"
tt.render.sprites[1].scale = vec_1(1)
--#endregion
--#region fx_hero_witch_skill_path_aoe_in
tt = RT("fx_hero_witch_skill_path_aoe_in", "fx")
tt.render.sprites[1].name = "hero_witch_skill_4_potion_in_layer1_in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "hero_witch_skill_4_potion_in_layer2_in"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].scale = vec_1(1)
--#endregion
--#region fx_hero_witch_skill_polymorph
tt = RT("fx_hero_witch_skill_polymorph", "fx")
tt.render.sprites[1].name = "hero_witch_skill_1_hit_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = vec_1(1)
--#endregion
--#region decal_hero_witch_ultimate
tt = RT("decal_hero_witch_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(1)
--#endregion
--#region tower_tricannon_bomb_4_trail
tt = RT("tower_tricannon_bomb_4_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tricannon_tower_lvl4_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 70
tt.particle_system.animation_fps = 15
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}
--#endregion
--#region tower_tricannon_bomb_4_bombardment_trail
tt = RT("tower_tricannon_bomb_4_bombardment_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tricannon_tower_lvl4_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.animation_fps = 25
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}
--#endregion
--#region tower_tricannon_bomb_4_overheated_trail
tt = RT("tower_tricannon_bomb_4_overheated_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tricannon_tower_lvl4_particle_overheat"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 70
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}
--#endregion
--#region mod_endless_archer_insight
tt = RT("mod_endless_archer_insight", "mod_health_damage_factor_inc")
-- package.loaded.soldier_enemies = nil
-- require("soldier_enemies")
--#endregion
--#region cricet_random_eff_aura
tt = RT("cricet_random_eff_aura", "decal_scripted")
-- AC(tt, "editor")
tt.render.sprites[1].prefix = "cricet_random_eff"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.cricet_random_eff_aura.update
tt.vis_flags = F_MOD
tt.vis_bans = 0
tt.trigger_range = 50
tt.mod = "cricet_random_eff_mod"
--#endregion
--#region cricet_random_eff_mod
tt = RT("cricet_random_eff_mod", "decal_scripted")
tt.render.sprites[1].prefix = "cricet_random_eff_mod"
tt.render.sprites[1].name = "give"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.cricet_random_eff_mod.insert
tt.main_script.update = scripts.cricet_random_eff_mod.update
tt.vis_flags = F_MOD
tt.vis_bans = 0
tt.range = 50
tt.random_mods = {"mod_cricet_add_hp", "mod_cricet_protection", "mod_cricet_attack", "mod_cricet_faster"}
--#endregion
--#region mod_cricet_add_hp
tt = RT("mod_cricet_add_hp", "mod_shaman_heal")
tt.main_script.insert = scripts.mod_cricet_add_hp.insert
tt.main_script.update = scripts.mod_cricet_add_hp.update
tt.hps.heal = 0.4
--#endregion
--#region mod_cricet_protection
tt = RT("mod_cricet_protection", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_protection"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_protection.insert
tt.main_script.update = scripts.mod_cricet_protection.update
tt.main_script.remove = scripts.mod_cricet_protection.remove
tt.modifier.protection = 1.3
tt.modifier.duration = -1
--#endregion
--#region mod_cricet_attack
tt = RT("mod_cricet_attack", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_attack"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_attack.insert
tt.main_script.update = scripts.mod_cricet_attack.update
tt.main_script.remove = scripts.mod_cricet_attack.remove
tt.modifier.damage_factor = 1.5
tt.modifier.duration = -1
--#endregion
--#region mod_cricet_faster
tt = RT("mod_cricet_faster", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_faster"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_faster.insert
tt.main_script.update = scripts.mod_cricet_faster.update
tt.main_script.remove = scripts.mod_cricet_faster.remove
tt.modifier.speed_factor = 1.3
tt.modifier.duration = -1
--#endregion
--#region endless_barrack_synergy_aura
tt = RT("endless_barrack_synergy_aura", "aura")
tt.aura.mod = "mod_endless_barrack_synergy"
tt.aura.radius = 180
tt.aura.cycle_time = 1
tt.main_script.insert = scripts.endless_barrack_synergy_aura.insert
tt.main_script.update = scripts.endless_barrack_synergy_aura.update
--#endregion
--#region mod_endless_barrack_synergy
tt = RT("mod_endless_barrack_synergy", "modifier")
tt.extra_damage = nil
tt.modifier.duration = 4
tt.main_script.insert = scripts.mod_endless_barrack_synergy.insert
tt.main_script.update = scripts.mod_endless_barrack_synergy.update
tt.main_script.remove = scripts.mod_endless_barrack_synergy.remove
--#endregion
--#region mod_endless_engineer_aftermath
tt = RT("mod_endless_engineer_aftermath", "modifier")
tt.main_script.insert = scripts.mod_endless_engineer_aftermath.insert
tt.radius = 60
tt.value = 20
tt.main_script.update = nil
tt.main_script.remove = nil
--#endregion
--#region aura_endless_engineer_aftermath_ray
tt = RT("aura_endless_engineer_aftermath_ray", "aura_tesla_overcharge")
tt.aura.duration = fts(22)
tt.aura.radius = 120
tt.aura.damage_min = 0
tt.aura.damage_max = 0
tt.aura.damage_inc = 15
tt.aura.damage_type = DAMAGE_ELECTRICAL
tt.aura.excluded_templates = {"enemy_spectral_knight"}
tt.main_script.update = scripts.aura_endless_engineer_aftermath_ray.update
tt.particles_name = "ps_tesla_overcharge"
--#endregion
--#region endless_mage_thunder
tt = RT("endless_mage_thunder")

AC(tt, "user_power", "pos", "main_script")

tt.cooldown = 70
tt.flash_delay_max = 0.3
tt.flash_delay_min = 0.1
tt.flash_duration_max = 0.15
tt.flash_duration_min = 0.1
tt.flash_l1_max_alphas = {0, 0}
tt.flash_l2_max_alpha = 70
tt.flash_l2_min_alpha = 60
tt.flash_delta = 0.02
tt.main_script.update = scripts.endless_mage_thunder.update
tt.nodes_spread = 10
tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.1
tt.rain.count = 20
tt.rain.delay_max = 0.2
tt.rain.disabled = true
tt.rain.distance_max = 550
tt.rain.distance_min = 450
tt.rain.duration = 0.2
tt.rain.ts = 0
tt.slow = {}
tt.slow.cooldown = 0.24
tt.slow.disabled = true
tt.slow.mod = "mod_power_thunder_slow"
tt.slow.range = 9999
tt.slow.ts = 0
tt.thunders = {{}, {}}
tt.thunders[1].cooldown = 0
tt.thunders[1].count = 1
tt.thunders[1].created = 0
tt.thunders[1].damage_max = 90
tt.thunders[1].damage_min = 50
tt.thunders[1].damage_radius = 80
tt.thunders[1].damage_type = DAMAGE_TRUE
tt.thunders[1].delay_max = 0.4
tt.thunders[1].delay_min = 0.2
tt.thunders[1].pop = {"pop_lightning1", "pop_lightning2", "pop_lightning3"}
tt.thunders[1].pop_chance = 0.3
tt.thunders[1].range = 150
tt.thunders[1].targeting = "nearest"
tt.thunders[1].ts = 0
tt.thunders[2] = table.deepclone(tt.thunders[1])
tt.thunders[2].count = 1
tt.thunders[2].pop = nil
tt.thunders[2].range = 9999
tt.thunders[2].targeting = "random"
tt.vis_bans = bor(F_FRIEND)
tt.vis_flags = bor(F_RANGED)
--#endregion
--#region ps_bullet_tower_ray_sheep
tt = RT("ps_bullet_tower_ray_sheep")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "channeler_tower_mutation_projectile_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(8, 8)
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_offset = vec_2(0, 0)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.emit_offset_relative = vec_2(-15, 0)
--#endregion
--#region fx_tower_ray_hit_start
tt = RT("fx_tower_ray_hit_start", "fx")
tt.render.sprites[1].name = "channeler_tower_crystal_union_fx_run"
--#endregion
--#region fx_tower_ray_hit_source
tt = RT("fx_tower_ray_hit_source", "fx")
tt.render.sprites[1].name = "channeler_tower_ray_start_loop"
tt.render.sprites[1].loop = true
tt.timed.runs = 1e+99
--#endregion
--#region fx_tower_ray_crystal_union
tt = RT("fx_tower_ray_crystal_union", "fx")
tt.render.sprites[1].name = "channeler_tower_crystal_union_fx_run"
--#endregion
--#region fx_tower_ray_lvl4_attack
tt = RT("fx_tower_ray_lvl4_attack", "fx")
tt.render.sprites[1].name = "channeler_tower_lvl4_tower_attack_fx_idle"
--#endregion
--#region fx_tower_ray_lvl4_attack_sheep
tt = RT("fx_tower_ray_lvl4_attack_sheep", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_tower_fx_idle"
--#endregion
--#region fx_tower_ray_lvl4_attack_sheep_hit
tt = RT("fx_tower_ray_lvl4_attack_sheep_hit", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_fx_idle"
--#endregion
--#region fx_tower_ray_lvl4_attack_sheep_hit_big
tt = RT("fx_tower_ray_lvl4_attack_sheep_hit_big", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_fx_big_idle"
--#endregion
--#region fx_tower_ray_lvl4_shock
tt = RT("fx_tower_ray_lvl4_shock", "fx")

AC(tt, "main_script")

tt.render.sprites[1].prefix = "channeler_tower_lvl4_idle_shock_fx_"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 3
tt.render.sprites[1].z = Z_OBJECT
tt.main_script.update = scripts.fx_tower_ray_lvl4_shock.update
tt.timed.runs = 1e+99
--#endregion
--#region moon_controller_s91
tt = RT("moon_controller_s91", "moon_controller")
tt.main_script.update = scripts.moon_controller_s91.update
tt.transit_time = 5
tt.hold_time = 15
tt.inactive_time = 25
tt.enemy_damage_factor = 1.2
tt.enemy_speed_factor = 1.2
tt.enemy_cooldown_factor = 0.8
tt.enemy_health_factor = 0.8
tt.spawn_creep = "enemy_deviltide_shark_ghost"
--#endregion
--#region ps_bullet_tower_sand
tt = RT("ps_bullet_tower_sand")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tower_sand_lvl4_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 150
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_2(10, 0)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region ps_bullet_tower_sand_skill_gold
tt = RT("ps_bullet_tower_sand_skill_gold")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tower_sand_lvl4_skill_1_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 150
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_2(10, 0)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region ps_aura_tower_sand_skill_big_blade
tt = RT("ps_aura_tower_sand_skill_big_blade")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "tower_sand_lvl4_skill_2_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_1(0)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region fx_bullet_tower_sand_hit
tt = RT("fx_bullet_tower_sand_hit", "fx")
tt.render.sprites[1].name = "tower_sand_basic_hit"
--#endregion
--#region fx_bullet_tower_sand_skill_gold_hit
tt = RT("fx_bullet_tower_sand_skill_gold_hit", "fx")
tt.render.sprites[1].name = "tower_sand_lvl4_skill_1_hit"
--#endregion
--#region fx_bullet_tower_sand_skill_gold_hit_coins
tt = RT("fx_bullet_tower_sand_skill_gold_hit_coins", "fx")
tt.render.sprites[1].name = "tower_sand_lvl4_skill_1_coins_hit"
--#endregion
--#region fx_aura_tower_sand_skill_big_blade
tt = RT("fx_aura_tower_sand_skill_big_blade", "fx")
tt.render.sprites[1].name = "tower_sand_lvl4_skill_2_hit_FX_loop"
--#endregion
--#region royal_archer_tower_lvl4_arrow_armor_breaker_trail_particle
tt = RT("royal_archer_tower_lvl4_arrow_armor_breaker_trail_particle")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "royal_archer_tower_lvl4_arrow_armor_piercer_trail_particle_idle_1"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 200
tt.particle_system.animation_fps = 20
tt.particle_system.track_rotation = true
--#endregion
--#region ps_rapacious_hunter_eagle_royal_archers
tt = RT("ps_rapacious_hunter_eagle_royal_archers")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_eagle_attack_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.particle_lifetime = {fts(1), fts(1)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region fx_tower_royal_archer_rapacious_hunter_dust
tt = RT("fx_tower_royal_archer_rapacious_hunter_dust", "fx")
tt.render.sprites[1].name = "tower_build_dust"
tt.render.sprites[1].scale = vec_2(0.5, 0.5)
--#endregion
--#region tower_royal_archers_arrow_hit_fx
tt = RT("tower_royal_archers_arrow_hit_fx", "fx")
tt.render.sprites[1].name = "royal_archer_tower_royal_archer_hit_fx_hit_fx"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
--#endregion
--#region tower_royal_archers_pow_armor_piercer_arrow_hit_fx
tt = RT("tower_royal_archers_pow_armor_piercer_arrow_hit_fx", "fx")
tt.render.sprites[1].name = "royal_archer_tower_royal_archer_lvl4_armor_breaker_hit_fx_armor_breaker_hit_fx"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
--#endregion
--#region tower_royal_archers_pow_rapacious_hunter_eagle_hit_fx
tt = RT("tower_royal_archers_pow_rapacious_hunter_eagle_hit_fx", "fx")
tt.render.sprites[1].name = "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_eagle_hit_fx_rapacious_hunter_hit_fx"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
--#endregion
--#region defend_flag
tt = RT("defend_flag", "decal")
tt.render.sprites[1].name = "defendFlag"
tt.render.sprites[1].z = Z_BACKGROUND
tt.render.sprites[1].animated = false
--#endregion
--#region defend_flag_water
tt = RT("defend_flag_water", "defend_flag")
tt.render.sprites[1].name = "defendFlag_water"
--#endregion
--#region decal_street_lamp
tt = RT("decal_street_lamp", "decal")

AC(tt, "lights")

tt.lights[1].radius = 70
--#endregion
--#region decal_lamp
tt = RT("decal_lamp", "decal_street_lamp")
tt.lights[1].radius = 70
--#endregion
--#region fx_tower_arcane_wizard_ray_hit_start
tt = RT("fx_tower_arcane_wizard_ray_hit_start", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "arcane_wizard_tower_ray_start_idle"
tt.render.sprites[1].loop = true
tt.render.sprites[1].scale = vec_2(1.5, 1.5)
tt.render.sprites[1].z = Z_BULLETS + 1
tt.timed.duration = fts(25)
tt.timed.runs = 1e+99
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {fts(18), 255}, {fts(25), 0}}
tt.tween.remove = false
--#endregion
--#region fx_tower_arcane_wizard_ray_hit
tt = RT("fx_tower_arcane_wizard_ray_hit", "fx")

AC(tt)

tt.render.sprites[1].name = "arcane_wizard_tower_ray_end_idle"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.timed.duration = fts(10)
tt.timed.runs = 1e+99
--#endregion
--#region fx_tower_arcane_wizard_disintegrate_ray_hit_start
tt = RT("fx_tower_arcane_wizard_disintegrate_ray_hit_start", "fx")
tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_disintegration_ray_charge_origin"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.timed.duration = fts(37)
tt.timed.runs = 1e+99
--#endregion
--#region fx_tower_arcane_wizard_ray_disintegrate_hit
tt = RT("fx_tower_arcane_wizard_ray_disintegrate_hit", "fx")
tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_disintegration_hit_idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].fps = 25
tt.timed.duration = fts(17)
tt.timed.runs = 1e+99
--#endregion
--#region decal_tower_arcane_wizard_empowerment_preview
tt = RT("decal_tower_arcane_wizard_empowerment_preview", "decal_tween")

AC(tt, "render", "tween")

tt.range_factor = 1
tt.render.sprites[1].name = "arcane_wizard_tower_empowerment_indicator"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_TOWER_BASES + 1
tt.render.sprites[1].offset.y = 5
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.1, 255}}
tt.tween.remove = false
--#endregion
--#region ps_tower_rocket_gunners_sting_missiles_trail
tt = RT("ps_tower_rocket_gunners_sting_missiles_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "rocket_gunners_tower_sting_missiles_particles_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 50
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_offset = vec_2(0, 0)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {fts(9), fts(9)}
tt.emit_offset_relative = vec_2(-15, 0)
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_floor
tt = RT("fx_bullet_soldier_tower_rocket_gunners_floor", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_hit_fx_floor_idle"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_hit
tt = RT("fx_bullet_soldier_tower_rocket_gunners_hit", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_hit_fx_idle"
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit_air
tt = RT("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit_air", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_explosion_air_idle"
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_phosphoric_floor
tt = RT("fx_bullet_soldier_tower_rocket_gunners_phosphoric_floor", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_hit_fx_floor_idle"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_phosphoric_hit
tt = RT("fx_bullet_soldier_tower_rocket_gunners_phosphoric_hit", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_hit_fx_idle"
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit
tt = RT("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_explosion_idle"
--#endregion
--#region fx_tower_rocket_gunners_take_off
tt = RT("fx_tower_rocket_gunners_take_off", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_take_off_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -50
--#endregion
--#region fx_soldier_tower_rocket_gunners_land
tt = RT("fx_soldier_tower_rocket_gunners_land", "fx")
tt.render.sprites[1].name = "rocket_gunners_tower_landing_fx_idle"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region fx_bullet_soldier_tower_rocket_gunners_sting_missiles_smoke
tt = RT("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_smoke", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "rocket_gunners_tower_sting_missiles_floor_decal_smoke_idle"
tt.render.sprites[1].loop = true
tt.timed.duration = 1e+99
tt.timed.runs = 1e+99
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {3.5, 0}}
tt.tween.remove = true
--#endregion
--#region decal_soldier_shadow
tt = RT("decal_soldier_shadow", "decal_scripted")
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.main_script.update = scripts.decal_soldier_shadow.update
tt.max_height = 50
tt.shadow_shrink = 0.4
tt.entity = nil
tt.dissapear_time = 14
--#endregion
--#region decal_soldier_tower_rocket_gunners_shadow
tt = RT("decal_soldier_tower_rocket_gunners_shadow", "decal_soldier_shadow")
tt.render.sprites[1].name = "rocket_gunners_tower_gunner_shadow"
tt.shadow_shrink = 0.25
--#endregion
--#region decal_bullet_soldier_tower_rocket_gunners_sting_missiles
tt = RT("decal_bullet_soldier_tower_rocket_gunners_sting_missiles", "decal_tween")
tt.render.sprites[1].name = "rocket_gunners_tower_sting_missiles_floor_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {3.5, 0}}
tt.tween.remove = true
--#endregion
--#region ps_bullet_tower_flamespitter_skill_bomb
tt = RT("ps_bullet_tower_flamespitter_skill_bomb")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dwarven_flamespitter_tower_blazing_trail_projectile_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 50
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_1(5)
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region fx_tower_flamespitter_flame
tt = RT("fx_tower_flamespitter_flame", "fx")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_flamethrower_fx"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_BULLETS
tt.timed.runs = 1e+99
--#endregion
--#region fx_bullet_tower_flamespitter_bomb_explosion
tt = RT("fx_bullet_tower_flamespitter_bomb_explosion", "fx")
tt.render.sprites[1].name = "dwarven_flamespitter_tower_blazing_trail_explosion_idle"
--#endregion
--#region fx_bullet_tower_flamespitter_bomb_burn
tt = RT("fx_bullet_tower_flamespitter_bomb_burn", "fx")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_blazing_trail_path_fx"
tt.render.sprites[1].name = "idle"
--#endregion
--#region fx_tower_flamespitter_column
tt = RT("fx_tower_flamespitter_column", "fx")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_scorching_torches_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].scale = vec_1(0.75)
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region decal_bullet_tower_flamespitter_bomb
tt = RT("decal_bullet_tower_flamespitter_bomb", "decal_tween")
tt.render.sprites[1].name = "dwarven_flamespitter_tower_blazing_trail_explosion_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
tt.tween.remove = true
--#endregion
--#region decal_tower_flamespitter_skill_columns
tt = RT("decal_tower_flamespitter_skill_columns", "decal_timed")
tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_scorching_torches_particle"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.timed.duration = fts(10)
--#endregion
--#region s72_rotten_spawner
tt = RT("s72_rotten_spawner", "s15_rotten_spawner")

AC(tt, "main_script", "editor")

tt.main_script.update = scripts.s15_rotten_spawner.update
tt.entity = "enemy_rotten_tree"
tt.spawn_margin = {30, 60}
tt.spawn_timers = {
	{9, 0},
	[10] = {15, 1},
	[11] = {13.5, 1},
	[12] = {10, 1},
	[13] = {15, 2},
	[14] = {15, 3},
	[15] = {15, 4}
}
--#endregion
--#region moon_controller_s72
tt = RT("moon_controller_s72", "moon_controller")
tt.main_script.update = scripts.moon_controller_s72.update
tt.transit_time = 5
tt.hold_time = 20
tt.inactive_time = 40
tt.enemy_armor_buff = 0.1
tt.enemy_magic_armor_buff = 0.1
tt.enemy_speed_buff = 12
tt.enemy_hp_buff = 0.1
tt.insert_hook = scripts.moon_controller_s72.insert_hook
tt.insert_hook_remove = scripts.moon_controller_s72.insert_hook_remove
tt.spawn = {
	[7] = {"enemy_zombie"},
	[4] = {"enemy_zombie"},
	[6] = {"enemy_skeleton"},
	[5] = {"enemy_ghoul"},
	[8] = {"enemy_halloween_zombie"}
}
tt.spawn_count_function = function(store)
	return 2 + (store.wave_group_number or 0) * 3
end
tt.spawn_gaps = 3
--#endregion
--#region s72_init
tt = RT("s72_init")

AC(tt, "main_script")

tt.main_script.insert = scripts.s72_init.insert
--#endregion
--#region ps_bullet_tower_ballista_skill_bomb_trail_A
tt = RT("ps_bullet_tower_ballista_skill_bomb_trail_A")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "ballista_tower_junk_particle_projectile_1"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 15
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region ps_bullet_tower_ballista_skill_bomb_trail_B
tt = RT("ps_bullet_tower_ballista_skill_bomb_trail_B")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "ballista_tower_junk_particle_projectile_2"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region fx_tower_ballista_shot
tt = RT("fx_tower_ballista_shot", "fx")
tt.render.sprites[1].name = "ballista_tower_arrow_fx_idle"
--#endregion
--#region fx_tower_ballista_final_shot
tt = RT("fx_tower_ballista_final_shot", "fx")
tt.render.sprites[1].name = "ballista_tower_special_arrow_fx_idle"
--#endregion
--#region fx_bullet_tower_ballista_hit
tt = RT("fx_bullet_tower_ballista_hit", "fx")
tt.render.sprites[1].name = "ballista_tower_hit_2"
--#endregion
--#region fx_bullet_tower_ballista_final_shot_hit
tt = RT("fx_bullet_tower_ballista_final_shot_hit", "fx")
tt.render.sprites[1].name = "ballista_tower_special_hit_idle"
--#endregion
--#region fx_bullet_tower_ballista_missed_arrow
tt = RT("fx_bullet_tower_ballista_missed_arrow", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "ballista_tower_missed_arrow"
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.duration = 6
tt.timed.runs = 1e+99
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {tt.timed.duration - 0.5, 255}, {tt.timed.duration, 0}}
--#endregion
--#region fx_bullet_tower_ballista_missed_arrow_dust
tt = RT("fx_bullet_tower_ballista_missed_arrow_dust", "fx")
tt.render.sprites[1].name = "ballista_tower_missed_arrow_dust"
--#endregion
--#region fx_bullet_tower_ballista_missed_arrow_decal
tt = RT("fx_bullet_tower_ballista_missed_arrow_decal", "fx")

AC(tt, "tween")

tt.render.sprites[1].name = "ballista_tower_missed_arrow_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.timed.duration = 6
tt.timed.runs = 1e+99
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {tt.timed.duration - 0.5, 255}, {tt.timed.duration, 0}}
--#endregion
--#region fx_bullet_tower_ballista_bomb_spawn
tt = RT("fx_bullet_tower_ballista_bomb_spawn", "fx")
tt.render.sprites[1].name = "ballista_tower_bomb_fx_idle"
--#endregion
--#region fx_bullet_tower_ballista_bomb_junk_floor
tt = RT("fx_bullet_tower_ballista_bomb_junk_floor", "fx")
tt.render.sprites[1].name = "ballista_tower_junk_particle_floor"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.duration = fts(16)
tt.timed.runs = 1e+99
--#endregion
--#region fx_bullet_tower_ballista_bomb_explosion
tt = RT("fx_bullet_tower_ballista_bomb_explosion", "fx")
tt.render.sprites[1].name = "ballista_tower_bomb_explotion_idle"
--#endregion
--#region ps_bullet_tower_barrel
tt = RT("ps_bullet_tower_barrel")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "barrel_tower_projectile_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.emission_rate = 45
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_2(10, 10)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emit_direction = math.pi / 3
tt.particle_system.emit_speed = {20, 20}
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scale_var = {0.3, 0.5}
tt.particle_system.alphas = {255, 255, 255, 0}
--#endregion
--#region ps_bullet_tower_barrel_skill_barrel
tt = RT("ps_bullet_tower_barrel_skill_barrel")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "barrel_tower_lvl4_bad_barrel_projectile_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 150
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = vec_2(10, 0)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_BULLET_PARTICLES
--#endregion
--#region fx_bullet_tower_barrel
tt = RT("fx_bullet_tower_barrel", "fx")
tt.render.sprites[1].name = "barrel_tower_projectile_hit_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
--#endregion
--#region fx_soldier_tower_barrel_skill_warrior_hit
tt = RT("fx_soldier_tower_barrel_skill_warrior_hit", "fx")
tt.render.sprites[1].name = "barrel_tower_berserker_unit_hit_fx_idle"
--#endregion
--#region fx_soldier_tower_barrel_skill_warrior_spawn
tt = RT("fx_soldier_tower_barrel_skill_warrior_spawn", "fx")
tt.render.sprites[1].name = "barrel_tower_lvl4_tower_berserker_spawn_fx_idle"
--#endregion
--#region decal_bullet_tower_barrel
tt = RT("decal_bullet_tower_barrel", "decal_timed")
tt.render.sprites[1].name = "barrel_tower_projectile_hit_fx_decal_idle"
tt.render.sprites[1].animated = true
tt.timed.duration = fts(22)
--#endregion
--#region decal_aura_bullet_tower_barrel_skill_barrel_explosion
tt = RT("decal_aura_bullet_tower_barrel_skill_barrel_explosion", "decal_tween")
tt.render.sprites[1].name = "barrel_tower_lvl4_bad_barrel_projectile_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(20), 255}, {fts(40), 0}}
tt.tween.remove = true
--#endregion
--#region decal_soldier_tower_barrel_skill_warrior
tt = RT("decal_soldier_tower_barrel_skill_warrior", "decal_tween")
tt.render.sprites[1].prefix = "barrel_tower_berserker_unit_decal"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
tt.tween.remove = true
tt.tween.disabled = true
--#endregion
--#region fx_elemental_metal_holder_broken_jarra
tt = RT("fx_elemental_metal_holder_broken_jarra", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "goldholder_jarraDef"
tt.render.sprites[1].name = "broken"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, 5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "goldholder_rayoDef"
tt.render.sprites[2].name = "ray_down"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "goldholder_rayo_explosionDef"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].exo = true
tt.render.sprites[3].offset = v(0, 5)
tt.render.sprites[3].z = Z_OBJECTS
--#endregion
--#region controller_s93
tt = RT("controller_s93")
AC(tt, "main_script")
tt.main_script.update = scripts.controller_s93.update
--#endregion

tt = RT("mod_archer_tear", "mod_damage")
tt.damage_min = 0.0075
tt.damage_max = 0.0075
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)

-- G5
local function vv(x)
	return {
		x = x,
		y = x
	}
end
tt = E:register_t("decal_stage_01_wisps", "decal")
tt.render.sprites[1].prefix = "stage_1_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_1_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt = E:register_t("decal_stage_01_butterfly_1", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_1_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30
tt = E:register_t("decal_stage_01_butterfly_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_1_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35

tt = E:register_t("decal_wisp_501", "decal_delayed_play")
tt.render.sprites[1].name = "props_wisp"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 30
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "props_wisp"
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}}
tt = E:register_t("stage_01_bush", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].prefix = "Stage_1_tutorial_bush"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t("stage_01_shaman", "decal")
tt.render.sprites[1].prefix = "Stage_1_tutorial_shaman"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("decal_stage1_waterfall1", "decal_loop")
tt.render.sprites[1].name = "stage1_waterfall_1"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage1_waterfall2", "decal_loop")
tt.render.sprites[1].name = "stage1_waterfall_2"
tt = E:register_t("decal_stage1_waterfall_ripples", "decal_loop")
tt.render.sprites[1].name = "stage1_waterfall_ripples"
tt = E:register_t("decal_stage1_decos_waterfalltop", "decal")
tt.render.sprites[1].name = "Stage_1_decos_waterfalltop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_01_decos_waterfall", "decal")
tt.render.sprites[1].name = "Stage_1_decos_waterfall_1"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_01_robin_hood", "decal_scripted")

E:add_comps(tt, "editor", "editor_script", "ui")

for i = 2, 6 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "robin_hood_easter_egg_layer" .. i - 1
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end

tt.clicked_sound = "Stage01RobinHood"
tt.animation_idle = "idle"
tt.animation_click = "fall"
tt.animation_attack = "attack"
tt.attack_cooldown_min = 4
tt.attack_cooldown_max = 7
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.main_script.update = scripts.decal_stage_01_robin_hood.update
tt.mask_to_spawn = "decal_stage_01_robin_hood_mask"
tt = E:register_t("decal_stage_01_robin_hood_mask", "decal_static")
tt.render.sprites[1].name = "robin_hood_mask"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_stage_01_campfire_guy_campfire", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].name = "campfire_guy_tent_back"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "campfire_guy_guy"
tt.render.sprites[2].offset = v(-36, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "campfire_guy_campfire"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "campfire_guy_tent_front"
tt.render.sprites[4].offset = v(-36, 5)
tt.render.sprites[4].draw_order = 11
tt.main_script.update = scripts.decal_stage_01_campfire_guy_campfire.update
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.sound_fire_off = "Stage01FireOff"
tt.sound_fire_on = "Stage01FireOn"
tt.sound_fire_final = "Stage01FireFinal"
tt.guy_sprite_id = 2
tt.campfire_sprite_id = 3
tt.tent_front_sprite_id = 4
tt = E:register_t("decal_stage_01_elder_rune", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui", "editor")

tt.render.sprites[1].prefix = "Stage_1_rapido_elder_rune_1"
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_01_rune.update
tt.click_play.idle_animation = "idle"
tt.click_play.click_animation = "activation"
tt.click_play.idle_on_animation = "idle_2"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage01Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt = E:register_t("decal_stage_02_elder_rune", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui", "editor")

tt.render.sprites[1].prefix = "stage_2_rapido_elder_rune_2_fx"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.decal_stage_02_rune.insert
tt.main_script.update = scripts.decal_stage_02_rune.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0203Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(0, -30, 60, 60)
tt.base_rock_entity = "decal_stage_02_elder_rune_base"
tt = E:register_t("decal_stage_02_elder_rune_base", "decal")

E:add_comps(tt, "main_script")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_2_rapido_elder_rune_2_base"
tt.render.sprites[1].sort_y_offset = 1
tt = E:register_t("decal_stage_02_elder_rune_static", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage_2_rapido_elder_rune_2_0117"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt = E:register_t("decal_stage_02_fishing_link", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui")

tt.render.sprites[1].prefix = "fishing_link"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.decal_stage_02_fishing_link.insert
tt.main_script.update = scripts.decal_stage_02_fishing_link.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage02LinkFishing"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.entity_line = "decal_stage_02_fishing_link_line"
tt.entity_water_splash = "decal_stage_02_fishing_link_water_splash"
tt.min_water_move_cd = 3
tt.max_water_move_cd = 7
tt.min_line_move_cd = 60
tt.max_line_move_cd = 90
tt.min_window_duration = 3
tt.max_window_duration = 3
tt.animation_line_move = ""
tt.gold_pos_offset = v(-10, 40)
tt.gold_amount = 25
tt.fish_animations = {"fishing_nothing", "fishing_nothing", "fishing_fish_or_boot", "fishing_nothing", "fishing_nothing"}
tt = E:register_t("decal_stage_02_fishing_link_line", "decal_scripted")
tt.render.sprites[1].prefix = "fishing_link_line"
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_02_fishing_link_line.update
tt.fish_animations = {"fishing_nothing", "fishing_boot", "fishing_fish", "fishing_rupee", "fishing_nothing"}
tt = E:register_t("decal_stage_02_fishing_link_water_splash", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "water_splash"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_02_lion_king", "decal_scripted")

E:add_comps(tt, "main_script", "ui")

for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "lion_king_easter_egg_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].group = "layers"
end

tt.main_script.insert = scripts.decal_stage_02_lion_king.insert
tt.main_script.update = scripts.decal_stage_02_lion_king.update
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.clicked_sound = "Stage02LionKing"
tt.animation_idle = "idle"
tt.animation_idle2 = "stick"
tt.animation_click = "action"
tt.min_cooldown_idle = 4
tt.max_cooldown_idle = 7
tt.entity_light = "decal_stage_02_lion_king_light"
tt = E:register_t("decal_stage_02_lion_king_light", "decal_scripted")

E:add_comps(tt, "main_script", "ui", "tween")

tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "light_copy"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].hidden = true
tt.tween.props[1].keys = {{0, 0}, {fts(29), 255}, {fts(77), 255}, {fts(102), 0}}
tt.tween.remove = false
tt.tween.disabled = true
tt = E:register_t("decal_stage_02_wisps", "decal")
tt.render.sprites[1].prefix = "stage_2_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_2_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt = E:register_t("decal_stage_02_butterfly_1", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_2_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30
tt = E:register_t("decal_stage_02_butterfly_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_2_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt = E:register_t("decal_stage_02_butterfly_3", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_2_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 12
tt.delayed_play.max_delay = 32
tt = E:register_t("taunts_s01_controller")

AC(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.tutorial_arborean_build_barrack = CC("taunt_set")
tt.taunts.sets.tutorial_arborean_build_barrack.format = "TAUNT_TUTORIAL_ARBOREAN_BARRACK_%04i"
tt.taunts.sets.tutorial_arborean_build_barrack.decal_name = "decal_tutorial_arborean_shoutbox"
tt.taunts.sets.tutorial_arborean_build_barrack.pos = v(860, 650)
tt.taunts.sets.tutorial_arborean_build_all = CC("taunt_set")
tt.taunts.sets.tutorial_arborean_build_all.format = "TAUNT_TUTORIAL_ARBOREAN_ALL_%04i"
tt.taunts.sets.tutorial_arborean_build_all.decal_name = "decal_tutorial_arborean_shoutbox"
tt.taunts.sets.tutorial_arborean_build_all.pos = v(860, 650)
tt = E:register_t("decal_tutorial_arborean_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "arborean_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "arborean_taunt_0004"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(0, 1)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(180, 58)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_water_shine", "decal_loop")
tt.render.sprites[1].name = "props_water_shine"
tt = E:register_t("decal_waterfall", "decal_loop")
tt.render.sprites[1].name = "stage_2_props_waterfall"
tt = E:register_t("decal_waterfall_splash", "decal_loop")
tt.render.sprites[1].name = "stage_2_props_waterfall_splash"
tt = E:register_t("decal_waterfall_waves", "decal_loop")
tt.render.sprites[1].name = "props_waterfall_waves"
tt.render.sprites[1].z = Z_DECALS + 1
tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].scale", PT_COORDS}, {"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].z", PT_NUMBER}}
tt = E:register_t("decal_waves", "decal_loop")
tt.render.sprites[1].name = "stage_2_props_waves"
tt = E:register_t("taunts_s02_controller")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_02_veznan = CC("taunt_set")
tt.taunts.sets.stage_02_veznan.format = "TAUNT_STAGE02_VEZNAN_%04i"
tt.taunts.sets.stage_02_veznan.decal_name = "decal_stage02_veznan_shoutbox"
tt.taunts.sets.stage_02_veznan.pos = v(740, 670)
tt.taunts.sets.stage_02_raelyn = CC("taunt_set")
tt.taunts.sets.stage_02_raelyn.format = "TAUNT_STAGE02_RAELYN_%04i"
tt.taunts.sets.stage_02_raelyn.decal_name = "decal_stage02_raelyn_shoutbox"
tt.taunts.sets.stage_02_raelyn.pos = v(460, 550)
tt = E:register_t("decal_stage02_veznan_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {107, 255, 10, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_stage02_raelyn_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_stage_02_veznan", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

tt.render.sprites[1].prefix = "veznan_cinematic_veznan"
tt.render.sprites[1].name = "idle"
tt = E:register_t("stage_02_arborean_old", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

tt.render.sprites[1].prefix = "stage2_decos_viejo"
tt.main_script.update = scripts.stage_02_arborean_old.update
tt = E:register_t("stage_02_arborean_baby1", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

tt.render.sprites[1].prefix = "stage2_decos_bebe1"
tt.main_script.update = scripts.stage_02_arborean_baby1.update
tt = E:register_t("controller_stage_03_arborean_babies")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_03_arborean_babies.update
tt = E:register_t("decal_arborean_baby_clickeable", "decal_scripted")

E:add_comps(tt, "editor", "editor_script", "ui")

tt.render.sprites[1].prefix = "arborean_baby"
tt.main_script.update = scripts.stage_02_arborean_baby2.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.hidden_cd = 7
tt.change_anim_cd_min = 5
tt.change_anim_cd_max = 10
tt.sound_in = "Terrain1CommonArboreanTapIn"
tt.sound_out = "Terrain1CommonArboreanTapOut"
tt.is_hidden = false
tt = E:register_t("stage_3_treeTop", "decal")
tt.render.sprites[1].name = "stage_3_treeTop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_03_fat_arborean", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui")

tt.render.sprites[1].prefix = "stage3_decos_gordito"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vv(1.1)
tt.main_script.update = scripts.decal_stage_03_fat_arborean.update
tt.click_play.idle_animation = "idle"
tt.click_play.click_animation = "comer"
tt.click_play.end_animation = "muerte"
tt.click_play.required_clicks = 3
tt.click_play.play_once = true
tt.click_play.clicked_sound = "EasterEggCommonTap"
tt.ui.can_click = true
tt.ui.click_rect = r(-60, -10, 60, 60)
tt = E:register_t("stage3_decos_barriles2", "decal_scripted")

local time_between_animations = fts(30 * math.random(10, 30))

tt.render.sprites[1].prefix = "stage3_decos_barriles2"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.animations = {{"action", time_between_animations}, {"idle", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t("stage3_decos_barriles1", "decal_scripted")

local time_between_animations = fts(30 * math.random(10, 30))

tt.render.sprites[1].prefix = "stage3_decos_barriles1"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.animations = {{"action", time_between_animations}, {"idle", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t("decal_stage_03_elder_rune", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui", "editor")

tt.render.sprites[1].prefix = "stage_3_decos_REF_elder_rune_3"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.main_script.update = scripts.decal_stage_03_elder_rune.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0203Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt = E:register_t("ps_bullet_stage_03_heart_of_the_arborean")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "stage_3_HeartProy_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(5), fts(5)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = vv(0)
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt = E:register_t("decal_bullet_stage_03_heart_of_the_arborean", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "explosiondecal_asst_heart_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = false
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {4, 0}}

tt = E:register_t("bullet_stage_03_heart_of_the_arborean", "bolt")
b = balance.specials.trees.heart_of_the_arborean
E:add_comps(tt, "force_motion")
tt.render.sprites[1].prefix = "stage_3_HeartProy_proyectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage_3_HeartProy_glow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS - 1
tt.bullet.damage_type = b.damage_type
tt.height_attack = 70
tt.initial_vel_y = 50
tt.transition_time = 1
tt.target_distance_detection = 20
tt.main_script.insert = scripts.bullet_heart_of_the_arborean.insert
tt.main_script.update = scripts.bullet_heart_of_the_arborean.update
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.particles_name = "ps_bullet_stage_03_heart_of_the_arborean"
tt.bullet.max_speed = 1800
tt.bullet.min_speed = 30
tt.bullet.hit_sound = "Stage03HeartOfTheForestBlast"
tt.bullet.hit_decal = "decal_bullet_stage_03_heart_of_the_arborean"
tt.bullet.hit_fx = "trees_heart_of_the_arborean_decal_hit_fx"
tt.bullet.align_with_trajectory = true
tt.initial_impulse = 12000
tt.initial_impulse_duration = 0.2
tt.initial_impulse_angle = math.pi / 2
tt.force_motion.a_step = 15
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 600
tt.sound_events.insert = nil

tt = E:register_t("decal_stage_03_wisps", "decal")
tt.render.sprites[1].prefix = "stage_3_wisps_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_3_wisps_2Def"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].exo = true
tt = E:register_t("decal_stage_03_butterfly_1", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_3_butterfly_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 10
tt.delayed_play.max_delay = 30
tt = E:register_t("decal_stage_03_butterfly_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_3_butterfly_2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt = E:register_t("decal_stage_03_butterfly_3", "decal_delayed_play")
tt.render.sprites[1].prefix = "stage_3_butterfly_3Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 12
tt.delayed_play.max_delay = 32
tt = E:register_t("decal_stage_04_easteregg_sheepy_baby", "decal_scripted")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].prefix = "sheepy_stage4_baby"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.main_script.update = scripts.decal_stage_04_easteregg_sheepy_baby.update
tt.jump_distance = 20
tt.fall_to_y = 450
tt.force_motion.max_a = 600
tt.force_motion.max_v = 300
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.1
tt.force_motion.a_step = 15
tt = E:register_t("decal_stage_04_easteregg_sheepy_sheepy", "decal")
tt.render.sprites[1].prefix = "sheepy_stage4_sheepy"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_04_easteregg_sheepy_old_man", "decal")
tt.render.sprites[1].prefix = "sheepy_stage4_old_arborean"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("stage_04_mask_top", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage4_elevatormask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 2
tt = E:register_t("stage_04_mask_bottom", "stage_04_mask_top")
tt.render.sprites[1].name = "stage4_elevatormask2"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 2
tt = E:register_t("stage_04_shadowtop", "decal")
tt.render.sprites[1].name = "stage4_shadowtop"
tt.render.sprites[1].animated = false
tt = E:register_t("stage_04_shadowside", "decal")
tt.render.sprites[1].name = "stage4_shadowside"
tt.render.sprites[1].animated = false
tt = E:register_t("stage_04_shadowbottom", "decal")
tt.render.sprites[1].name = "stage4_shadowbottom"
tt.render.sprites[1].animated = false
tt = E:register_t("controller_stage_04_arboreans")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_04_arboreans.update
tt = E:register_t("stage_04_mask_bridge_center_back", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "Stage4_center_bridge_back_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 3
tt.render.sprites[1].pos = v(512, 384)
tt = E:register_t("stage_04_mask_bridge_center_front", "stage_04_mask_bridge_center_back")
tt.render.sprites[1].name = "Stage4_center_bridge_front_mask"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 2
tt = E:register_t("stage_04_mask_bridge_left_back", "stage_04_mask_bridge_center_back")
tt.render.sprites[1].name = "Stage4_left_bridge_back_mask"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 1
tt = E:register_t("stage_04_mask_bridge_left_front", "stage_04_mask_bridge_center_back")
tt.render.sprites[1].name = "Stage4_left_bridge_front_mask"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 1
tt = E:register_t("stage_04_mask_bridge_right_back", "stage_04_mask_bridge_center_back")
tt.render.sprites[1].name = "Stage4_right_bridge_back_mask"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 3
tt = E:register_t("stage_04_mask_bridge_right_front", "stage_04_mask_bridge_center_back")
tt.render.sprites[1].name = "Stage4_right_bridge_front_mask"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 2
tt = E:register_t("decal_stage_04_arborean_right", "decal_scripted")

E:add_comps(tt, "ui", "motion", "force_motion")

tt.render.sprites[1].prefix = "stage_4_arboreans_arborean_01"
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 4
tt.main_script.update = scripts.decal_stage_04_arborean.update
tt.walk_destination = {v(0, 0), v(100, -70), v(175, -100), v(100, -70)}
tt.motion.speed = v(10, 10)
tt.motion.max_speed = 30
tt.ui.click_rect = r(-20, -10, 40, 40)
tt.jump_distance = 20
tt.fall_to_y = 440
tt.force_motion.max_a = 1200
tt.force_motion.max_v = 450
tt.force_motion.ramp_radius = 30
tt.force_motion.fr = 0.1
tt.force_motion.a_step = 20
tt.sound_fall = "Stage04ArboreanFall"
tt = E:register_t("decal_stage_04_arborean_left", "decal_stage_04_arborean_right")
tt.render.sprites[1].prefix = "stage_4_arboreans_arborean_02"
tt.main_script.update = scripts.decal_stage_04_arborean.update
tt.walk_destination = {v(0, 0), v(54, 8), v(151, 55), v(54, 8)}
tt.fall_to_y = 580
tt = E:register_t("decal_stage_04_arborean_center", "decal_stage_04_arborean_right")
tt.render.sprites[1].prefix = "stage_4_arboreans_arborean_03"
tt.main_script.update = scripts.decal_stage_04_arborean.update
tt.walk_destination = {v(0, 0), v(142, -75)}
tt.fall_to_y = 300
tt.sprite_change = {"stage_4_arboreans_arborean_04", "stage_4_arboreans_arborean_03"}
tt = E:register_t("stage_4_leaf_anim", "decal_delayed_play")

E:add_comps(tt, "tween")

local duration = 2.8
local fade_time = 0.2

tt.render.sprites[1].name = "stage_4_leaf_anim_idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "stage_4_leaf_anim_idle"
tt.delayed_play.play_duration = duration
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fade_time, 255}, {duration - fade_time, 255}, {duration, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(0, 0)}, {duration, v(0, -130)}}
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}}
tt = E:register_t("stage_4_arborean_bridge_1", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

local time_between_animations = fts(30 * math.random(3, 5))

tt.render.sprites[1].prefix = "anim_puente1"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations}, {"action2", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t("stage_4_arborean_bridge_2", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

local time_between_animations = fts(30 * math.random(3, 5))

tt.render.sprites[1].prefix = "anim_puente2"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations}, {"action2", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t("stage_4_arborean_bridge_3", "decal_scripted")

E:add_comps(tt, "editor", "editor_script")

local time_between_animations = fts(30 * math.random(3, 5))

tt.render.sprites[1].prefix = "anim_puente3"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
tt.render.sprites[1].name = "action1"
tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations}, {"action2", time_between_animations}, {"action3", time_between_animations}}
tt.main_script.update = scripts.decal_scripted_loop_play.update
tt = E:register_t("stage_4_arborean_vine", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "anim_liana"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -22, 60, 50)
tt.main_script.update = scripts.stage_4_arborean_vine.update
tt.animation_idle = "idle1"
tt.animation_down = "down"
tt.animation_down_idle = "idle2"
tt.animation_click = "no_tap"
tt.animation_up = "tap"
tt.down_cooldown = 14
tt.down_duration = 3
tt.sound_fall = "Stage04ArboreanFall"
tt = E:register_t("decal_stage_04_mask_tunnel", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "Stage4_NEW_Topmask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECT_COVERS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "Stage4_NEW_Submask"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = 35
tt = E:register_t("decal_stage_04_waterfall", "decal_scripted")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "anim_waterfall"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
tt = E:register_t("decal_stage_04_elder_rune", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui", "editor")

tt.render.sprites[1].prefix = "stage_4_elder_rune_4"
tt.render.sprites[1].loop = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_4_elder_rune_4_fx"
tt.render.sprites[2].loop = true
tt.main_script.update = scripts.decal_stage_04_elder_rune.update
tt.click_play.idle_animation = "idle"
tt.click_play.click_animation = "activation"
tt.click_play.idle_on_animation = "idle_2"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage04Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-35, -100, 70, 70)
tt = E:register_t("decal_stage_04_elder_rune_static", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage_4_elder_rune_4_0119"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt = E:register_t("decal_stage_05_elder_rune_base", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage_5_elder_rune_5_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 0
tt = E:register_t("decal_stage_05_elder_rune", "decal_click_play")

E:add_comps(tt, "main_script", "click_play", "ui", "editor")

tt.render.sprites[1].prefix = "stage_5_elder_rune_5"
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 1
tt.main_script.update = scripts.decal_stage_05_elder_rune.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0506Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-50, -10, 50, 50)
tt = E:register_t("decal_stage_05_elder_rune_static", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage_5_elder_rune_5_0125"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt = E:register_t("stage_05_bridge_mask_left", "decal")
tt.render.sprites[1].name = "stage_5_MaskBridge_left"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_05_bridge_mask_right", "decal")
tt.render.sprites[1].name = "stage_5_MaskBridge_right"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_05_trees_mask", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage_5_MaskTree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t("trees_guardian_tree", "decal_scripted")
b = balance.specials.trees.guardian_tree
E:add_comps(tt, "custom_attack", "cheats", "editor")
tt.tree_disabled = b.disabled
tt.wave_config = b.wave_config
tt.custom_attack.cooldown = nil
tt.custom_attack.cooldown_min = b.cooldown_min
tt.custom_attack.cooldown_max = b.cooldown_max
tt.custom_attack.max_range = b.max_range
tt.custom_attack.min_range = b.min_range
tt.custom_attack.animation = "attack"
tt.custom_attack.aura = "trees_guardian_tree_vine_aura_decal"
tt.custom_attack.sound = "ElvesPlantMissile"
tt.custom_attack.shoot_time = fts(35)
tt.custom_attack.entity = "trees_guardian_tree_wave_of_roots"
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_BOSS, F_FLYING, F_FRIEND, F_HERO)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "Stage02TreePart2Def"
tt.render.sprites[1].name = "idle_sleep"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "Stage02TreeDef"
tt.render.sprites[2].name = "idle_sleep"
tt.render.sprites[2].exo = true
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].sort_y_offset = -40
tt.animation_idle_sleep = "idle_sleep"
tt.animation_go_to_awake = "back_to_idle_awake"
tt.animation_idle_awake = "idle_awake"
tt.animation_go_to_sleep = "back_to_idle_sleep"
tt.main_script.insert = scripts.trees_guardian_tree.insert
tt.main_script.update = scripts.trees_guardian_tree.update
tt.editor.overrides = {
	["render.sprites[2].name"] = "idle_sleep"
}
tt.cheats.buttons[1].text = "TreeDecal"
tt.cheats.buttons[1].fn = function(button, store, e)
end
tt.cheats.buttons[2] = E:clone_c("cheats_text_button")
tt.cheats.buttons[2].text = "TreeCD"
tt.cheats.buttons[2].fn = function(button, store, e)
	e.custom_attack.ts = store.tick_ts - e.custom_attack.cooldown
end
tt.cheats.buttons[3] = E:clone_c("cheats_text_button")
tt.cheats.buttons[3].text = "TreeRanges"
tt.cheats.buttons[3].fn = function(button, store, e)
	for _, range in ipairs({e.custom_attack.max_range, e.custom_attack.min_range}) do
		local hp = E:create_entity("decal_debug_range")

		hp.pos.x, hp.pos.y = e.pos.x, e.pos.y
		hp.radius = range

		simulation:queue_insert_entity(hp)
	end
end
tt.cheats.buttons[4] = E:clone_c("cheats_text_button")
tt.cheats.buttons[4].text = "TreeONOFF"
tt.cheats.buttons[4].fn = function(button, store, e)
	local current_wave = store.wave_group_number
	local current_config = e.wave_config[current_wave]

	e.wave_config[current_wave] = not current_config
end
tt.sound_pre_cast = "Stage02GuardianTreePreCast"
tt.sound_cast = "Stage02GuardianTreeCast"
tt.sound_roots = "Stage02GuardianTreeRoots"
tt = E:register_t("trees_guardian_tree_wave_of_roots")

E:add_comps(tt, "pos", "main_script")

b = balance.specials.trees.guardian_tree
tt.main_script.update = scripts.trees_guardian_tree_wave_of_roots.update
tt.sep_nodes_min = b.sep_nodes_min
tt.sep_nodes_max = b.sep_nodes_max
tt.show_delay_min = b.show_delay_min
tt.show_delay_max = b.show_delay_max
tt.count = b.roots_count
tt.radius = 50
tt.wave_pi = 1
tt.root_hand_L_pos = v(0, 350)
tt.root_hand_R_pos = v(250, 450)
tt.start_offset = -20
tt.root_hand_offset_path_merge = -8
tt.decal = "trees_guardian_tree_wave_of_roots_decal"
tt.vis_flags = bor(F_STUN)
tt.vis_bans = bor(F_FLYING, F_BOSS)
tt.mod = "mod_stage_guardian_tree_wave_of_roots_stun"
tt = E:register_t("trees_guardian_tree_wave_of_roots_decal", "decal_sequence")
tt.render.sprites[1].prefix = "stage_2_special_treeFX_groundFX0"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].z = Z_DECALS
tt.sequence.steps = {"start", nil, "end"}
tt = E:register_t("trees_heart_of_the_arborean_decal", "decal_scripted")
b = balance.specials.trees.heart_of_the_arborean

E:add_comps(tt, "custom_attack", "ui", "cheats")

tt.render.sprites[1].prefix = "heartDef"
tt.render.sprites[1].name = "idleLoading"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = scripts.trees_heart_of_the_arborean_decal.insert
tt.main_script.update = scripts.trees_heart_of_the_arborean_decal.update
tt.custom_attack.cooldown_max = b.cooldown_max
tt.custom_attack.cooldown_min = b.cooldown_min
tt.custom_attack.max_range = b.max_range
tt.custom_attack.damage_radius = b.damage_radius
tt.custom_attack.damage_max = b.damage_max
tt.custom_attack.damage_min = b.damage_min
tt.custom_attack.damage_type = b.damage_type
tt.custom_attack.max_targets = b.max_targets
tt.custom_attack.min_targets = b.min_targets
tt.custom_attack.door1Pos = v(757, 568)
tt.custom_attack.door2Pos = v(318, 566)
tt.custom_attack.cast_time = fts(21)
tt.custom_attack.wait_between_shots = b.wait_between_shots
tt.custom_attack.min_dist_between_tgts = b.min_dist_between_tgts
tt.custom_attack.node_prediction = fts(45)
tt.custom_attack.sound = nil
tt.custom_attack.bullet = "bullet_stage_03_heart_of_the_arborean"
tt.custom_attack.bullet_start_offset = v(0, 90)
tt.ui.click_rect = r(-100, -100, 200, 200)
tt.cheats.buttons[1].text = "H_CD"
tt.cheats.buttons[1].fn = function(button, store, e)
	if e.custom_attack.cooldown then
		e.custom_attack.ts = store.tick_ts - e.custom_attack.cooldown
	end
end
tt.sound_ready = "Stage03HeartOfTheForestReady"
tt.sound_cast = "Stage03HeartOfTheForestCast"
tt = E:register_t("trees_heart_of_the_arborean_decal_hit", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "explosiondecalDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = E:register_t("trees_heart_of_the_arborean_decal_hit_fx", "fx")
tt.render.sprites[1].prefix = "explosionDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS - 1
tt = E:register_t("decal_stage_03_heart_back_waves", "decal")
tt.render.sprites[1].prefix = "heart_back_wavesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_03_heart_front_waves", "decal")
tt.render.sprites[1].prefix = "heart_front_wavesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("arborean_shaman_bullet", "bullet")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "tricannon_tower_lvl2_bomb"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = 10
tt.bullet.damage_max = 10
tt.bullet.particles_name = "ps_tower_tricannon_bomb_trail"
tt.bullet.miss_decal = nil
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.xp_gain_factor = 0.78
tt.bullet.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_ONE_SHIELD_HIT)
tt.bullet.max_speed = 300
tt.bullet.min_speed = 30
tt.initial_impulse = 15000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle = math.pi / 1.5
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt.main_script.update = scripts.hero_muyrn_ranged_attack_bullet.update
tt = E:register_t("trees_heart_of_the_arborean_shaman_decal", "decal_scripted")
tt.render.sprites[1].prefix = "shamanDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.insert = scripts.trees_heart_of_the_arborean_shaman_decal.insert
tt.main_script.update = scripts.trees_heart_of_the_arborean_shaman_decal.update
tt = E:register_t("trees_heart_of_the_arborean_shaman_water_decal", "decal")
tt.render.sprites[1].prefix = "wavesDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_03_river", "decal")
tt.render.sprites[1].prefix = "riverDef"
tt.render.sprites[1].name = "riverRunning"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("bush_ladder", "decal_scripted")

E:add_comps(tt, "spawner", "tween")

tt.render.sprites[1].prefix = "elevator_cosoDef"
tt.render.sprites[1].name = "idleraise"
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 3
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "elevatorDef"
tt.render.sprites[1].name = "idleraise"
tt.render.sprites[2].exo = true
tt.render.sprites[2].z = Z_BACKGROUND_COVERS - 3
tt.render.sprites[2].anchor.y = 1
tt.render.sprites[2].hidden = true
tt.animation_spawner_start = "start"
tt.animation_spawner_idle = "idleraise"
tt.main_script.update = scripts.bush_ladder_decal.update
tt.spawn_data = nil
tt.spawner.eternal = true
tt.spawner_template = "bush_spawner"
tt.break_time = fts(20)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {fts(9), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(0, 80)}, {fts(5), v(0, 0)}}
tt.tween.props[2].sprite_id = 1
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, v(0, 100)}, {fts(5), v(0, 0)}}
tt.tween.props[3].sprite_id = 2
tt = E:register_t("bush_spawner", "decal_scripted")

E:add_comps(tt, "spawner", "editor")

tt.render.sprites[1].prefix = "elevatorDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_DECALS + 1
tt.animation_spawner_start = "start"
tt.animation_spawner_end = "end"
tt.animation_spawner_idle = "idle"
tt.main_script.update = scripts.bush_spawner_decal.update
tt.spawn_data = nil
tt.spawner.eternal = true
tt = E:register_t("decal_stage_05_blocked_path", "decal_scripted")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "stage5TreesDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_05_blocked_path.update
tt.rustle_times = 1
tt.rustle_delay = 1
tt.cut_down_delay = 1
tt = E:register_t("decal_stage_05_bear_woodcutter", "decal_scripted")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "bear_woodcutterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.main_script.update = scripts.decal_stage_05_bear_woodcutter.update
tt.entity = "enemy_bear_woodcutter"
tt.spawn_pos = v(242, 459)
tt.waypoint_pos = v(220, 459)

tt = E:register_t("decal_ground_enemy_bear_vanguard", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "bear_vanguard_decal_ground_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = 2
tt.tween.props[1].keys = {{fts(10), 255}, {0.8, 255}, {1, 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt = E:register_t("decal_werebeast_boss_shadow", "decal_tween")

E:add_comps(tt, "render", "tween")

tt.range_factor = 1
-- tt.render.sprites[1].name = "werebeast_boss_shadow"
tt.render.sprites[1].name = "decal_flying_shadow"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, v(1, 1)}, {1.5, v(0, 0)}}
tt = E:register_t("instant_heal_mod", "modifier")

E:add_comps(tt, "render")

tt.heal_hp = nil
tt.main_script.insert = scripts.instant_heal_mod.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.bans = {}
tt.modifier.duration = 1
tt.render.sprites[1].name = "instant_heal_mod_fx"
tt = E:register_t("mod_stage_guardian_tree_wave_of_roots_stun", "modifier")

E:add_comps(tt, "render")

b = balance.specials.trees.guardian_tree
tt.modifier.duration = b.effect_duration
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.modifier.use_mod_offset = false
tt.modifier.immune_for_seconds = b.immune_for_seconds
tt.render.sprites[1].prefix = "stage_2_special_treeFX_holdFX"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].sort_y_offset = -3
tt.main_script.insert = scripts.trees_guardian_tree_vine_mod.insert
tt.main_script.remove = scripts.trees_guardian_tree_vine_mod.remove
tt.main_script.update = scripts.trees_guardian_tree_vine_mod.update

tt = E:register_t("controller_stage_04_easteregg_sheepy")

E:add_comps(tt, "ui", "pos", "main_script")

tt.main_script.update = scripts.controller_stage_04_easteregg_sheepy.update
tt.entity_baby = "decal_stage_04_easteregg_sheepy_baby"
tt.entity_old_man = "decal_stage_04_easteregg_sheepy_old_man"
tt.entity_sheepy = "decal_stage_04_easteregg_sheepy_sheepy"
tt.old_man_cooldown = 5
tt.sheepy_man_cooldown = 5
tt.ui.click_rect = r(-65, -10, 80, 40)
tt = E:register_t("controller_stage_06_pool_party")

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.update = scripts.controller_stage_06_pool_party.update
tt.entity_demon_in_pool = "decal_pool_party2"
tt.entity_demon_jumping = "decal_pool_party4"
tt.entity_volleyball = "decal_pool_party5"
tt = E:register_t("controller_stage_06_tiki_bar")

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_06_tiki_bar.insert
tt.main_script.update = scripts.controller_stage_06_tiki_bar.update
tt.entity_baby1 = "decal_tiki_bar2"
tt.entity_baby2 = "decal_tiki_bar3"
tt.entity_barman = "decal_tiki_bar5"
tt.entity_old_man = "decal_tiki_bar4"
tt = E:register_t("controller_stage_08_elf_rescue")
b = balance.specials.stage08_elf_rescue

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.update = scripts.controller_stage_08_elf_rescue.update
tt.entity_elf = "soldier_elf_stage_08"
tt.entity_guard = "enemy_unblinded_abomination_stage_8"
tt.entity_elf_slave = "decal_stage_08_elf_rescue_elf_slave"
tt.entity_chain = "decal_stage_08_elf_rescue_chains"
tt.elf_pos = {v(390, 625), v(750, 675), v(230, 625), v(930, 640)}
tt.pos_guard = v(490, 550)
tt.pos_chain = v(448, 541)
tt.pos_elf_slave = v(428, 540)
tt.spawn_cooldown = b.spawn_cooldown
tt = E:register_t("controller_stage_09_spawn_nightmares")
b = balance.specials.stage09_spawn_nightmares

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_09_spawn_nightmares.insert
tt.main_script.update = scripts.controller_stage_09_spawn_nightmares.update
tt.wave_config = b.wave_config
tt.entity_portal = "decal_stage_09_portal"
tt.entity_aura = "aura_stage_09_spawn_nightmare_convert"
tt.spawn_fx_aura = "aura_stage_09_spawn_nightmare_convert_spawn_fx"
tt.entity_candles = {"decal_stage_09_candle_back1", "decal_stage_09_candle_back2", "decal_stage_09_candle_back3", "decal_stage_09_candle_front1", "decal_stage_09_candle_front2", "decal_stage_09_candle_front3"}
tt.entity_glows = {"decal_stage_09_candle_glow_back", "decal_stage_09_candle_glow_front"}
tt.path_portal = "decal_stage_09_portal_path_spawn"
tt.portal_offset = v(-15, 0)
tt.pos_portal = v(1048 + tt.portal_offset.x, 446 + tt.portal_offset.y)
tt.pos_aura = {v(661 + tt.portal_offset.x, 280 + tt.portal_offset.y), v(659 + tt.portal_offset.x, 300 + tt.portal_offset.y), v(658 + tt.portal_offset.x, 260 + tt.portal_offset.y)}
tt.path_portal_off_delay = b.path_portal_off_delay
tt.sound_candles_in = "Stage09NightmarePortalCandles"
tt.sound_portal_in = "Stage09NightmarePortalEye"
tt = E:register_t("decal_stage_09_skeleton", "decal_scripted")

E:add_comps(tt, "ui", "motion")

tt.render.sprites[1].prefix = "skeleton_koopaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_09_skeleton.update
tt.death_time = 12
tt.walk_destination = v(120, 0)
tt.motion.speed = v(10, 10)
tt.motion.max_speed = 20
tt.ui.click_rect = r(-20, -10, 40, 40)
tt = E:register_t("controller_stage_10_obelisk")
b = balance.specials.stage10_obelisk

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_10_obelisk.insert
tt.main_script.update = scripts.controller_stage_10_obelisk_by_wave.update
tt.entity_cultist = "decal_stage_10_obelisk_priests"
tt.entity_crystal = "decal_stage_10_obelisk_crystal"
tt.entity_light = "decal_stage_10_obelisk_light"
tt.entity_base_crystals = "decal_stage_10_obelisk_crystals"
tt.template_crystal_fx = "decal_stage_10_obelisk_crystal_fx"
tt.fx_stun_explosion = "fx_stage_10_obelisk_stun_explosion"
tt.fx_stun_explosion_white = "fx_stage_10_obelisk_stun_explosion_white"
tt.fx_stun_circle = "fx_stage_10_obelisk_stun_circle"
tt.fx_teleport = "fx_stage_10_obelisk_teleport_crystal"
tt.obelisk_pos = v(531, 545)
tt.crystal_pos = v(531, 539)
tt.fx_heal_pos = v(528, 557)
tt.config = b
tt.stun_bans = bor(F_ENEMY, F_HERO, F_FLYING)
tt.stun_flags = bor(F_FRIEND, F_MOD)
tt.stun_mod = "mod_stage_10_obelisk_stun"
tt.heal_bans = bor(F_FRIEND)
tt.heal_flags = bor(F_ENEMY, F_MOD)
tt.heal_mod = "mod_stage_10_obelisk_heal"
tt.teleport_bans = bor(F_FRIEND, F_FLYING)
tt.teleport_flags = bor(F_ENEMY, F_MOD)
tt.teleport_aura = "aura_stage_10_obelisk_teleport"
tt.bullet_golem_spawn = "bullet_stage_10_obelisk_priests"
tt.bullet_offset = v(0, 20)
tt.bullet_spawn_pos = {v(-71, 38), v(3, 3), v(71, 35)}
tt.golem_selected_paths = {4, 3, 1}
tt.golem_holder_pos = {v(310, 441), v(482, 345), v(328, 205)}
tt.golem_activate_holder = {"4", "9", "6"}
tt.golem_walk_pos = {v(375, 465), v(572, 392), v(381, 275)}
tt.template_golem = "enemy_crystal_golem"
tt.sacrifice_duration = 4
tt.sound_activation = "Stage10ObeliskActivation"
tt.sound_cast_stun = "Stage10ObeliskEffectStun"
tt.sound_cast_heal = "Stage10ObeliskEffectHealLoopStart"
tt.sound_heal_loop = "Stage10ObeliskEffectHealLoop"
tt.sound_change_mode = "Stage10ObeliskEffectChange"
tt.sound_cast_golem = "Stage10ObeliskEffectGolemSpawnCast"
tt.sound_cast_teleport = "EnemyVoidBlinkerTeleport"

tt = E:register_t("bullet_stage_10_obelisk_priests", "bolt")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].prefix = "stage10_obelisk_projectile"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.align_with_trajectory = true
tt.main_script.update = scripts.bullet_stage_10_obelisk_priests_alternative.update
tt.bullet.hit_fx = "fx_stage_10_obelisk_priest_hit"
tt.bullet.particles_name = "ps_bullet_stage_10_obelisk_priests"
tt.bullet.max_speed = 30
tt.bullet.min_speed = 3
tt.force_motion.a_step = 5
tt.force_motion.max_a = 900
tt.force_motion.max_v = 300

tt = E:register_t("controller_stage_10_obelisk_iron", "controller_stage_10_obelisk")
tt.main_script.update = scripts.controller_stage_10_obelisk_iron.update
tt.golem_holder_pos = {v(74, 524), v(310, 440), v(60, 308), v(700, 400), v(328, 204)}
tt.golem_walk_pos = {v(26, -34), v(50, 50), v(30, 0), v(0, -70), v(54, 60)}
tt.golem_activate_holder = {"2", "4", "1", "11", "6"}
tt.golem_selected_paths = {4, 3, 2, 3, 1}
tt.prepare_delay = 3
tt = E:register_t("controller_stage_10_obelisk_wave_fixed", "controller_stage_10_obelisk")
tt.main_script.update = scripts.controller_stage_10_obelisk_wave_fixed.update
tt = E:register_t("controller_stage_10_ymca")
b = balance.specials.stage10_ymca

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_10_ymca.insert
tt.main_script.update = scripts.controller_stage_10_ymca.update
tt.entities_soldiers = {"soldier_stage_10_ymca_indio", "soldier_stage_10_ymca_constructor", "soldier_stage_10_ymca_biker", "soldier_stage_10_ymca_policia"}
tt.entity_statue = "decal_stage_10_ymca_statue"
tt.entity_dots = "decal_stage_10_ymca_dots"
tt.entity_fireworks = "decal_stage_10_ymca_fireworks"
tt.entity_lights = "decal_stage_10_ymca_lights"
tt.dots_pos = v(1025, 590)
tt.start_formation = {3, 4, 2, 1}

local sb = v(-30, -30)

tt.statue_position = {v(sb.x + 975, sb.y + 620), v(sb.x + 1030, sb.y + 650), v(sb.x + 1090, sb.y + 645), v(sb.x + 1133, sb.y + 590)}
tt.soldier_spawn_pos = {v(985, 585), v(1015, 600), v(1045, 580), v(1015, 560)}
tt.soldier_line_pos_offset = {v(25, -20), v(20, -10), v(-15, 5), v(-25, -10)}

local base = v(925, 445)

tt.soldier_path_pos = {v(base.x - 20, base.y + 20), v(base.x + 13, base.y + 33), v(base.x + 25, base.y), v(base.x - 10, base.y - 10)}
tt.soldier_spawn_delay = {1.5, 1.8, 1.7, 1.5}
tt = E:register_t("controller_stage_11_cult_leader")
b = balance.specials.stage11_cult_leader

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_11_cult_leader.insert
tt.main_script.update = scripts.controller_stage_11_cult_leader.update
tt.entity_cultist = "decal_stage_11_cult_leader"
tt.entity_illusion = "enemy_stage_11_cult_leader_illusion"
tt.cultist_pos = v(730, 510)
tt.spawn_available_pos = {v(340, 476), v(546, 478), v(366, 296), v(648, 284), v(920, 390)}
tt.config = b
tt.spawn_check_enemies_range = 150
tt.spawn_check_towers_range = 150
tt.cultist_attack_time = b.illusion.spawn_charge_time
tt.cultist_stun_time = b.stun_time
tt.illusion_delay_between = fts(24)
tt.sound_illusion_summon_cast = "Stage11MydriasIllusionSummonCast"
tt = E:register_t("controller_stage_11_portal")
b = balance.specials.stage11_portal

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.insert = scripts.controller_stage_11_portal.insert
tt.main_script.update = scripts.controller_stage_11_portal.update
tt.entity_portal = "decal_stage_11_portal"
tt.portal_pos = v(512, 384)
tt.entity_aura = "aura_stage_11_portal"
tt.aura_pos = v(880, 580)
tt.entity_torches = "decal_stage_11_torches"
tt.torches_pos = v(512, 384)
tt.entity_crystals_prefix = "decal_stage_11_portal_crystal_"
tt.crystals_count = 8
tt.crystals_pos = v(512, 384)
tt.config = b
tt.sound_thunder = "Stage11AmbienceThunder"
tt.sound_thunder_cd_min = 8
tt.sound_thunder_cd_max = 12
tt.sound_portal_open = "Stage11PortalOpen"
tt.sound_portal_close = "Stage11PortalClose"
tt = E:register_t("controller_stage_11_cultist_leader_modes")

E:add_comps(tt, "editor", "main_script")

tt.main_script.update = scripts.controller_stage_11_cultist_leader_modes.update
tt.entity_tables = "decal_stage_11_cultist_leader_modes"
tt.entity_worker = "decal_stage_11_cultist_leader_modes_worker"
tt = E:register_t("controller_terrain_3_floating_elements")

E:add_comps(tt, "editor", "pos", "main_script")

tt.main_script.update = scripts.controller_terrain_3_floating_elements.update

tt = E:register_t("controller_terrain_3_local_glare")
E:add_comps(tt, "editor", "pos", "main_script", "glare_kr5")
tt.main_script.insert = scripts.controller_terrain_3_local_glare.insert
tt.main_script.update = scripts.controller_terrain_3_local_glare.update
tt.entity_spawner_fx = "fx_terrain_3_spawner"
tt.aura_glare = "aura_glare_source"
tt.eyes_t = {"decal_terrain_3_glare_eye_big", "decal_terrain_3_glare_eye_small_1", "decal_terrain_3_glare_eye_small_2", "decal_terrain_3_glare_eye_small_3"}
tt.decal_ground = "decal_stage_12_glare"
tt.waves = nil
tt.sid_eyes = 1
tt.sid_eyelids = 2
tt.sound_small_eye_1 = "Terrain3GlareOnSmall1"
tt.sound_small_eye_2 = "Terrain3GlareOnSmall2"
tt.sound_big_eye = "Terrain3GlareOnBig"
tt.sound_off = "Terrain3GlareOff"

tt = E:register_t("controller_terrain_3_stage_15_glare", "controller_terrain_3_local_glare")

local b = balance.specials.stage15_cult_leader_tower

function tt.main_script.insert(this, store)
	return true
end

tt.main_script.update = scripts.controller_terrain_3_stage_15_glare.update
tt = E:register_t("controller_terrain_3_stage_16_glare1", "controller_terrain_3_local_glare")

local b = balance.specials.stage16_overseer

tt.main_script.update = scripts.controller_terrain_3_stage_16_glare.update
tt.phase_config = b.glare1
tt.decal_ground = "decal_stage_16_glare_1"
tt.eyes_t = {"decal_stage_16_glare_eye_big", "decal_stage_16_glare_eye_small_1", "decal_stage_16_glare_eye_small_2", "decal_stage_16_glare_eye_small_3"}
tt = E:register_t("controller_terrain_3_stage_16_glare2", "controller_terrain_3_local_glare")

local b = balance.specials.stage16_overseer

tt.main_script.update = scripts.controller_terrain_3_stage_16_glare.update
tt.phase_config = b.glare2
tt.decal_ground = "decal_stage_16_glare_2"
tt = E:register_t("controller_stage_14_amalgam")

local b = balance.specials.stage14_amalgam

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_14_amalgam.update
tt.amalgam_t = "enemy_amalgam"
tt.amalgam_spawn_pos = v(501, 482)
tt.aura_t = "aura_controller_stage_14_amalgam"
tt.amalgam_decal_t = "decal_controller_stage_14_amalgam"
tt.sacrifices_to_show_1 = b.sacrifices_to_show_1
tt.sacrifices_to_show_2 = b.sacrifices_to_show_2
tt.sacrifices_to_spawn = b.sacrifices_to_spawn
tt.sound_1 = "Stage14BehemothPoolSpawn1"
tt.sound_2 = "Stage14BehemothPoolSpawn2"
tt.sound_spawn = "Stage14BehemothPoolSpawn3"

tt = E:register_t("controller_stage_15_cult_leader_tower")
b = balance.specials.stage15_cult_leader_tower

E:add_comps(tt, "editor", "pos", "main_script", "render")

tt.main_script.update = scripts.controller_stage_15_cult_leader_tower.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "mydrias_finalstage_bottomDef"
tt.render.sprites[1].name = "idleup"
tt.render.sprites[1].exo = true
tt.render.sprites[1].group = "layers"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mydrias_finalstage_topDef"
tt.render.sprites[2].name = "idleup"
tt.render.sprites[2].exo = true
tt.render.sprites[2].group = "layers"
tt.render.sprites[2].z = Z_OBJECTS_COVERS + 20
tt.render.sprites[2].offset = v(-2, 2)
tt.config_per_wave = b.config_per_wave
tt.time_to_leave_after_attack_min = 2
tt.time_to_leave_after_attack_max = 4
tt.time_before_attack_min = 2
tt.time_before_attack_max = 4
tt.distance_to_group = 100
tt.bans = bor(F_FLYING)
tt.flags = bor(F_FRIEND, F_MOD)
tt.aura = "aura_stage_15_cult_leader_tower_stun"
tt.boss_to_spawn = "boss_cult_leader"

tt = E:register_t("controller_stage_18_eridan", "decal_scripted")
b = balance.specials.stage18_eridan

E:add_comps(tt, "bullet_attack", "custom_attack", "editor", "taunts")

tt.render.sprites[1].prefix = "eridan_s18_eridan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].sort_y_offset = -10
tt.main_script.update = scripts.controller_stage_18_eridan.update
tt.bullet_attack.max_range = b.ranged_attack.range
tt.bullet_attack.bullet = "bullet_stage_18_eridan_arrow"
tt.bullet_attack.shoot_times = {fts(11), fts(17), fts(23)}
tt.bullet_attack.cooldown = b.ranged_attack.cooldown
tt.bullet_attack.bullet_start_offset = {v(20, 30), v(-20, 30)}
tt.bullet_attack.animation = "shoot"
tt.custom_attack.max_range = b.instakill.range
tt.custom_attack.shoot_time = fts(3)
tt.custom_attack.cooldown = b.instakill.cooldown
tt.custom_attack.animation_start = "dash_out"
tt.custom_attack.animation_fight = "fight_sequence"
tt.custom_attack.animation_end = "dash_in"
tt.custom_attack.hp_threshold = b.instakill.hp_threshold
tt.custom_attack.melee_slot_x = 40
tt.custom_attack.mod = "mod_stage_18_eridan_stun"
tt.custom_attack.hit_time = fts(46)
tt.custom_attack.pop = {"pop_crit"}
tt.custom_attack.damage_type = b.instakill.damage_type
tt.custom_attack.vis_flags = bor(F_TELEPORT)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.sound_in_out = "Stage18EridanInOut"
tt.sound_instakill = "Stage18EridanInstakill"
tt.taunts.delay_min = 20
tt.taunts.delay_max = 30
tt.taunts.sets = {}
tt.taunts.sets.preparation = CC("taunt_set")
tt.taunts.sets.preparation.format = "LV18_ERIDAN_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx = 4
tt.taunts.sets.fight = CC("taunt_set")
tt.taunts.sets.fight.format = "LV18_ERIDAN_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx = 8
tt = E:register_t("controller_stage_19_mausoleum", "decal_scripted")
b = balance.specials.stage19_mausoleum

E:add_comps(tt, "editor")

tt.main_script.insert = scripts.controller_stage_19_mausoleum.insert
tt.main_script.update = scripts.controller_stage_19_mausoleum.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "spawner_mausoleumDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "spawner_mausoleum_lightDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].loop = false
tt.render.sprites[2].exo = true
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = v(5, 0)
tt.render.sprites[2].hidden = true
tt.render.sprites[2].sort_y_offset = -10
tt.wave_config = b.wave_config
tt = E:register_t("controller_stage_19_navira", "decal_scripted")

E:add_comps(tt, "taunts", "editor")

b = balance.enemies.undying_hatred.boss_navira
tt.main_script.insert = scripts.controller_stage_19_navira.insert
tt.main_script.update = scripts.controller_stage_19_navira.update
tt.render.sprites[1].prefix = "navira_navira"
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].hidden = true
tt.taunts.delay_min = 20
tt.taunts.delay_max = 30
tt.taunts.sets = {}
tt.taunts.sets.pre_bossfight = CC("taunt_set")
tt.taunts.sets.pre_bossfight.format = "LV19_NAVIRA_TAUNT_%02i"
tt.taunts.sets.pre_bossfight.end_idx = 6
tt.fire_balls_count = b.fire_balls.count
tt.fire_balls_cd = b.fire_balls.cooldown
tt.fire_balls_wait_between_balls = b.fire_balls.wait_between_balls
tt.fire_balls_wait_before_shoot = b.fire_balls.wait_before_shoot
tt.fire_balls_wait_between_shots = b.fire_balls.wait_between_shots
tt.fire_ball_t = "navira_fire_ball"
tt.fire_ball_bullet_t = "bullet_stage_19_navira_fire_ball_ray"
tt.fire_ball_rotation_controller_t = "controller_stage_19_navira_ball_rotation"
tt.hands_dust_1_t = "fx_stage_19_statue_hands_dust_1"
tt.hands_dust_2_t = "fx_stage_19_statue_hands_dust_2"
tt.hands_stones_1_t = "fx_stage_19_statue_hands_stones_1"
tt.hands_stones_2_t = "fx_stage_19_statue_hands_stones_2"
tt.cape_t = "decal_stage_19_navira_cape"
tt.sound_enter = "Stage19NaviraEnter"
tt.sound_fireball_spawn = "Stage19NaviraFireballSpawn"
tt.sound_fireball_cast = "Stage19NaviraFireballCast"
tt.sound_hands_down = "Stage19NaviraHandsDown"
tt.sound_hands_up = "Stage19NaviraHandsUp"
tt = E:register_t("controller_stage_19_navira_ball_rotation")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_19_navira_ball_rotation.update
tt.fire_ball_rot_speed = 3 * FPS * math.pi / 180
tt.fire_ball_rot_radius = 30
tt = E:register_t("controller_terrain_4_animated_armor_achievement")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_terrain_4_animated_armor_achievement.update
tt.revived = 0
tt = E:register_t("navira_fire_ball", "decal_tween")
tt.render.sprites[1].prefix = "navira_soul"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.y = 0.11666666666666667
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, v(0, 0)}, {0.5, v(0, 3)}, {1, v(0, 0)}, {1.5, v(0, -3)}, {2, v(0, 0)}}
tt.tween.props[1].loop = true
tt.tween.remove = false
tt = E:register_t("taunts_s19_controller")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_19_boss_navira_start = CC("taunt_set")
tt.taunts.sets.stage_19_boss_navira_start.format = "TAUNT_STAGE19_BOSS_NAVIRA_START_%04i"
tt.taunts.sets.stage_19_boss_navira_start.decal_name = "decal_stage19_boss_navira_shoutbox"
tt.taunts.sets.stage_19_boss_navira_start.pos = v(460, 550)
tt.taunts.sets.stage_19_boss_navira_before_bossfight = CC("taunt_set")
tt.taunts.sets.stage_19_boss_navira_before_bossfight.format = "TAUNT_STAGE19_BOSS_NAVIRA_BEFORE_BOSSFIGHT_%04i"
tt.taunts.sets.stage_19_boss_navira_before_bossfight.decal_name = "decal_stage19_boss_navira_shoutbox"
tt.taunts.sets.stage_19_boss_navira_before_bossfight.pos = v(460, 550)
tt = E:register_t("decal_stage19_boss_navira_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true

tt = E:register_t("controller_stage_22_boss_crocs", "decal_scripted")
E:add_comps(tt, "editor")
b = balance.enemies.crocs.boss_crocs.pre_fight_towers_destroy
tt.main_script.update = scripts.controller_stage_22_boss_crocs.update
tt.render.sprites[1].prefix = "boss_crocs_intro_bossDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].sort_y_offset = 300
tt.render.sprites[1].z = Z_OBJECTS
tt.mod = "mod_boss_crocs_tower_eat"
tt.waves = b.waves
tt.first_cooldown = b.first_cooldown
tt.cooldown = b.cooldown
tt.max_casts = b.max_casts
tt.excluded_templates = {"tower_stage_22_arborean_mages"}
tt.default_idle = "idle_1"
tt.idle_anims = {"idle_2"}
tt.idle_anims_min_cd = 4
tt.idle_anims_max_cd = 10
tt.taunt_keys_amount = b.taunt_keys_amount
tt.skill_anim = "skill"
tt.anim_exit = "exit"
tt.vis_bans = 0
tt.vis_flags = 0
tt.sound_set_free = "Stage22AbominorSetFree"
tt.sound_release_arm = "Stage22AbominorReleaseArm"
tt.sound_release_arm_cinematic = "Stage22AbominorReleaseArmEatTowerOneshot"
tt.sound_catch_arm = "Stage22AbominorCatchArm"

tt = E:register_t("fx_arborean_sentinels_spearmen_spear_hit", "fx")
tt.render.sprites[1].name = "tower_arborean_sentinels_spearmen_hitFx"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1

tt = E:register_t("ps_bullet_dreadeye_viper")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "dreadeye_viper_ranged_attack_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 80
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.scale_var = {1, 1.1}
tt.particle_system.particle_lifetime = {0.6, 0.8}

tt = E:register_t("ps_enemy_rhino_charge_a")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "razing_rhino_razing_rhino_charge_dust_a"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 4
tt.particle_system.track_offset = v(0, 0)
tt.particle_system.z = Z_DECALS

tt = E:register_t("ps_enemy_rhino_charge_b")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "razing_rhino_razing_rhino_charge_dust_b"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 3
tt.particle_system.track_offset = v(0, 20)
tt.particle_system.animation_fps = 15
tt.particle_system.z = Z_DECALS

tt = E:register_t("stage_06_mask_1", "decal")
tt.render.sprites[1].name = "stage_6_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("stage_06_mask_2", "decal")
tt.render.sprites[1].name = "stage_6_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_06_mask_3", "decal")
tt.render.sprites[1].name = "stage_6_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_06_mask_4", "decal")
tt.render.sprites[1].name = "stage_6_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_06_hole", "decal")
tt.render.sprites[1].prefix = "stage_6_madriguera"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("stage_06_door", "decal_scripted")
E:add_comps(tt, "spawner", "render", "sound_events", "editor", "ui", "tween")
tt.main_script.update = scripts.decal_stage_06_door.update
for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "stage_6_ascensor_ascensor_layer" .. i
	tt.render.sprites[i].name = "idle1_1"
	tt.render.sprites[i].group = "layers"
end
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "stage_6_ascensor_door"
tt.render.sprites[5].animated = false
tt.render.sprites[5].z = Z_OBJECTS_COVERS
tt.render.sprites[5].offset.x = 8.9
tt.render.sprites[5].offset.y = -13.2
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].prefix = "tusked_brawler"
tt.render.sprites[6].hidden = true
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].prefix = "stage_6_ascensor_jabali"
tt.render.sprites[7].hidden = true
tt.render.sprites[7].offset.x = -70
tt.render.sprites[7].offset.y = 15
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].name = "stage_6_ascensor_ascensor_dust"
tt.render.sprites[8].animated = false
tt.render.sprites[8].z = Z_DECALS
tt.spawner.eternal = true
tt.render.sprites[8] = E:clone_c("sprite")
tt.render.sprites[8].name = "stage_6_ascensor_ascensor_dust"
tt.render.sprites[8].animated = false
tt.render.sprites[8].z = Z_DECALS
tt.render.sprites[8].offset.x = 15
tt.render.sprites[8].offset.y = -55
tt.render.sprites[7].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[4].z = Z_OBJECTS_COVERS + 2
tt.render.sprites[3].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[1].z = Z_DECALS
tt.ui.can_click = false
tt.ui.click_rect = r(0, 0, 50, 50)
tt.clicks_to_kill = 3
tt.pig_death_sound = "EnemyTuskedBrawlerDeath"
tt.pig_click_sound = "Stage06EasterEggMinecraftClick"
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {5, 0}}
tt.tween.props[1].sprite_id = 6
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(1, 1)}, {fts(1), v(1.2, 1.2)}, {fts(3), v(1, 1)}}
tt.tween.props[2].disabled = true
tt.tween.props[2].sprite_id = 6
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, v(1, 1)}, {fts(1), v(1.2, 1.2)}, {fts(3), v(1, 1)}}
tt.tween.props[3].disabled = true
tt.tween.props[3].sprite_id = 7
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.run_once = false

tt = E:register_t("stage_06_hole_mask", "decal")
tt.render.sprites[1].name = "stage_6_maskmadriguera"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -75

tt = E:register_t("stage_06_mask_door", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_6_maskascensor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t("taunts_s06_controller")
E:add_comps(tt, "main_script", "taunts", "editor")
tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_06_cult_leader_greetings = CC("taunt_set")
tt.taunts.sets.stage_06_cult_leader_greetings.format = "TAUNT_STAGE06_CULTIST_GREETING_%04i"
tt.taunts.sets.stage_06_cult_leader_greetings.decal_name = "decal_stage06_cultist_shoutbox"
tt.taunts.sets.stage_06_cult_leader_greetings.pos = v(740, 670)
tt.taunts.sets.stage_06_boss_pig_response = CC("taunt_set")
tt.taunts.sets.stage_06_boss_pig_response.format = "TAUNT_STAGE06_BOSS_PIG_RESPONSE_%04i"
tt.taunts.sets.stage_06_boss_pig_response.decal_name = "decal_stage06_boss_pig_shoutbox"
tt.taunts.sets.stage_06_boss_pig_response.pos = v(460, 550)
tt.taunts.sets.stage_06_boss_pig_prebattle = CC("taunt_set")
tt.taunts.sets.stage_06_boss_pig_prebattle.format = "TAUNT_STAGE06_BOSS_PIG_PREBATTLE_%04i"
tt.taunts.sets.stage_06_boss_pig_prebattle.decal_name = "decal_stage06_boss_pig_shoutbox"
tt.taunts.sets.stage_06_boss_pig_prebattle.pos = v(460, 550)

tt = E:register_t("decal_stage06_cultist_shoutbox", "decal_tween")
E:add_comps(tt, "texts")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true

tt = E:register_t("decal_stage06_boss_pig_shoutbox", "decal_tween")
E:add_comps(tt, "texts")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "boss_pig_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "boss_pig_taunt_0005"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {180, 80, 52}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true

tt = E:register_t("decal_stage_06_minecraft_easter_egg", "decal_scripted")
E:add_comps(tt, "ui", "tween")
tt.render.sprites[1].prefix = "minecraft_easter_egg"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.main_script.update = scripts.decal_stage_06_minecraft_easter_egg.update
tt.animation_idle = "idle"
tt.animation_attack = "attack"
tt.animation_death = "death"
tt.sound_click = "Stage06EasterEggMinecraftClick"
tt.sound_death = "Stage06EasterEggMinecraftDeath"
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
tt.tween.props[1].disabled = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(1, 1)}, {fts(1), v(1.2, 1.2)}, {fts(3), v(1, 1)}}
tt.tween.props[2].disabled = true
tt.tween.disabled = true
tt.tween.remove = false
tt.clicks_to_kill = 3
tt.change_anim_cd_min = 4
tt.change_anim_cd_max = 7

tt = E:register_t("controller_stage_06_minecraft_easter_egg")
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.controller_stage_06_minecraft_easter_egg.update

tt = E:register_t("decal_stage_06_elder_rune", "decal_click_play")
E:add_comps(tt, "main_script", "click_play", "ui", "editor")
tt.render.sprites[1].prefix = "stage_6_elder_rune_6"
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_06_elder_rune.update
tt.click_play.idle_animation = "idle_2"
tt.click_play.click_animation = "activation"
tt.click_play.play_once = true
tt.click_play.clicked_sound = "Stage0506Rune"
tt.ui.can_click = true
tt.ui.click_rect = r(-70, -10, 90, 60)

tt = E:register_t("decal_stage_06_elder_rune_static", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].name = "stage_6_elder_rune_6_0125"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false

tt = E:register_t("decal_stage_06_cult_leader", "decal_scripted")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "mydrias_cinematic"
tt.render.sprites[1].name = "idle"

tt = E:register_t("decal_pool_party1", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_6_poolparty_deco_water"
tt.render.sprites[1].z = Z_DECALS - 1

tt = E:register_t("decal_pool_party2", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "stage_6_poolparty_deco"
tt.render.sprites[1].z = Z_DECALS - 1

tt = E:register_t("decal_pool_party3", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "stage_6_poolparty_deco_sleeping_arborean"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("decal_pool_party4", "decal")
E:add_comps(tt, "editor")
for i = 1, 2 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_demon_jump_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end

tt = E:register_t("decal_pool_party5", "decal")
E:add_comps(tt, "editor")
for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_volleyball_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end

tt = E:register_t("decal_pool_party6", "decal")
E:add_comps(tt, "editor")
for i = 1, 2 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "stage_6_poolparty_deco_music_arborean_layer" .. i
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].z = Z_DECALS
end

tt = E:register_t("decal_pool_party7", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = TEXTURE_SIZE_ALIAS
tt.render.sprites[1].name = "stage_6_poolparty_deco_baby"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("decal_pool_party8", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_6_poolparty_deco_weapons"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("decal_gold_mount", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_06_parches_espada"
tt.render.sprites[1].z = Z_DECALS - 1

tt = E:register_t("decal_tiki_bar1", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_06_parches_tiki_bottom"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = 0

tt = E:register_t("decal_tiki_bar2", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "stage_06_parches_tiki_top_bebe2"
tt.render.sprites[1].name = "Idle1"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = -2

tt = E:register_t("decal_tiki_bar3", "decal_tiki_bar2")
tt.render.sprites[1].prefix = "stage_06_parches_tiki_top_bebe1"
tt.render.sprites[1].name = "idle1"

tt = E:register_t("decal_tiki_bar4", "decal")
E:add_comps(tt, "editor")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "stage_06_parches_tiki_top_viejo"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = -2

tt = E:register_t("decal_tiki_bar5", "decal_tiki_bar2")
tt.render.sprites[1].prefix = "stage_06_parches_tiki_top_pibe"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].sort_y_offset = 1

tt = E:register_t("decal_tiki_bar6", "decal_tiki_bar1")
tt.render.sprites[1].name = "stage_06_parches_tiki_top"
tt.render.sprites[1].sort_y_offset = -1

tt = E:register_t("decal_terrain_2_smoke", "decal")
tt.render.sprites[1].prefix = "t2_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_terrain_2_dust", "decal")
tt.render.sprites[1].prefix = "t2_dustDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("decal_stage_07_fire", "decal")
tt.render.sprites[1].prefix = "fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_07_fireMask", "decal")
tt.render.sprites[1].prefix = "fire_maskDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_07_mask", "decal")
tt.render.sprites[1].name = "T2_Stage_7_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_07_cave_mask_smoke", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "T2_Stage_7_mask_cave"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_07_dust", "decal_terrain_2_dust")
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].random_ts = 1
tt = E:register_t("decal_stage_07_temple", "decal_scripted")
b = balance.specials.stage07_temple
tt.render.sprites[1].prefix = "templeDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_07_temple.update
tt.activation_wave = b.activation_wave
tt.temple_mask = "decal_stage_07_temple_mask"
tt.cave_mask = "decal_stage_07_cave_mask_smoke"
tt.sound = "Stage07CultTemple"
tt = E:register_t("decal_stage_07_temple_mask", "decal")
tt.render.sprites[1].prefix = "temple_maskDef"
tt.render.sprites[1].name = "idle_in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].loop = true
tt.render.sprites[1].hidden = true
tt = E:register_t("controller_stage_07_crows")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_07_crows.update
tt = E:register_t("decal_stage_07_crow_clickable", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.main_script.update = scripts.stage_07_crow.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -15, 30, 30)
tt = E:register_t("decal_stage_07_crow_clickable_1", "decal_stage_07_crow_clickable")
tt.render.sprites[1].prefix = "stage_7_crow1Def"
tt = E:register_t("decal_stage_07_crow_clickable_2", "decal_stage_07_crow_clickable")
tt.render.sprites[1].prefix = "stage_7_crow2Def"
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_07_crow_clickable_3", "decal_stage_07_crow_clickable")
tt.render.sprites[1].prefix = "stage_7_crow3Def"
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_07_crow_clickable_4", "decal_stage_07_crow_clickable")
tt.render.sprites[1].prefix = "stage_7_crow4Def"
tt.render.sprites[1].z = Z_FLYING_HEROES - 1
tt = E:register_t("decal_stage_07_crow_clickable_5", "decal_stage_07_crow_clickable")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "stage_7_crow5Def"
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_07_witcher_easter_egg", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "the_witcherDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.stage_07_witcher.update
tt.ui.can_click = true
tt.ui.click_rect = r(520, -220, 50, 50)
tt = E:register_t("stage_08_mask_1", "decal")
tt.render.sprites[1].name = "T2_Stage_8_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = -235
tt = E:register_t("stage_08_mask_2", "decal")
tt.render.sprites[1].name = "T2_Stage_8_mask_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = -235
tt = E:register_t("stage_08_mask_3", "decal")
tt.render.sprites[1].name = "T2_Stage_8_mask_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = -185
tt = E:register_t("stage_08_mask_4", "decal")
tt.render.sprites[1].name = "T2_Stage_8_mask_4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset.y = -250
tt = E:register_t("decal_stage_08_fire", "decal")
tt.render.sprites[1].prefix = "fire_stage_8Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].loop = true
tt = E:register_t("controller_stage_08_gem_baskets")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_08_gem_baskets.update
tt = E:register_t("decal_stage_08_gem_basket_big_clickable", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "stage_8_gems_basket_bigDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.stage_08_gem_basket.update
tt.ui.can_click = true
tt.ui.click_rect = r(-525, 200, 50, 50)
tt.gold_pos_offset = v(0, -30)
tt.gold_amount = 30
tt = E:register_t("decal_stage_08_gem_basket_small_clickable", "decal_stage_08_gem_basket_big_clickable")
tt.render.sprites[1].prefix = "stage_8_gems_basket_smallDef"
tt.ui.click_rect = r(138, 248, 40, 40)
tt = E:register_t("decal_stage_08_gem_basket_third_clickable", "decal_stage_08_gem_basket_big_clickable")
tt.render.sprites[1].prefix = "stage_8_gems_basket_thirdDef"
tt.ui.click_rect = r(477, -260, 50, 50)
tt.gold_pos_offset = nil
tt = E:register_t("decal_stage_09_mask", "decal")
tt.render.sprites[1].name = "T2_Stage_9_chains_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_09_bridge", "decal_scripted")
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].loop = false
tt.in_delay = nil
tt.animation_in = "in"
tt.animation_loop = "loop"
tt.mask_before = false
tt.main_script.insert = scripts.decal_stage_09_bridge.insert
tt.main_script.update = scripts.decal_stage_09_bridge.update
tt = E:register_t("decal_stage_09_bridge1", "decal_stage_09_bridge")
tt.render.sprites[1].prefix = "stage_9_bridge1Def"
tt.mask_entity = "decal_stage_09_bridge1_mask"
tt.in_delay = 1
tt = E:register_t("decal_stage_09_bridge2", "decal_stage_09_bridge")
tt.render.sprites[1].prefix = "stage_9_bridge2Def"
tt.mask_entity = "decal_stage_09_bridge2_mask"
tt.in_delay = 2.5
tt = E:register_t("decal_stage_09_bridge3", "decal_stage_09_bridge")
tt.render.sprites[1].prefix = "stage_9_bridge3Def"
tt.mask_entity = "decal_stage_09_bridge3_mask"
tt.mask_before = true
tt.mask_in_animation = "in"
tt.mask_loop_animation = "loop"
tt = E:register_t("decal_stage_09_bridge_mask", "decal")
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_09_bridge1_mask", "decal_stage_09_bridge_mask")
tt.render.sprites[1].prefix = "stage_9_bridge1_maskDef"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_09_bridge2_mask", "decal_stage_09_bridge_mask")
tt.render.sprites[1].prefix = "stage_9_bridge2_maskDef"
tt = E:register_t("decal_stage_09_bridge3_mask", "decal_stage_09_bridge_mask")
tt.render.sprites[1].prefix = "stage_9_bridge3_maskDef"
tt = E:register_t("decal_stage_09_candle", "decal_scripted")
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "idle_off"
tt.main_script.update = scripts.decal_stage_09_candle.update
tt = E:register_t("decal_stage_09_candle_back1", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_back_1Def"
tt = E:register_t("decal_stage_09_candle_back2", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_back_2Def"
tt = E:register_t("decal_stage_09_candle_back3", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_back_3Def"
tt = E:register_t("decal_stage_09_candle_front1", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_front_1Def"
tt = E:register_t("decal_stage_09_candle_front2", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_front_2Def"
tt = E:register_t("decal_stage_09_candle_front3", "decal_stage_09_candle")
tt.render.sprites[1].prefix = "stage_9_candles_front_3Def"
tt = E:register_t("decal_stage_09_candle_glow_back", "decal")
tt.render.sprites[1].prefix = "stage_9_candles_glow_backDef"
tt.render.sprites[1].name = "off"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_09_candle_glow_front", "decal")
tt.render.sprites[1].prefix = "stage_9_candles_glow_frontDef"
tt.render.sprites[1].name = "off"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_09_fire", "decal")
tt.render.sprites[1].prefix = "stage_9_fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_09_portal_path_spawn", "decal_scripted")
tt.render.sprites[1].prefix = "stage_9_portal_pathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_09_path_portal.update
tt = E:register_t("decal_stage_09_portal", "decal")
tt.render.sprites[1].prefix = "stage_9_portalDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_09_sheepy_easteregg", "decal_scripted")

E:add_comps(tt, "ui", "editor")

tt.render.sprites[1].prefix = "stage_9_sheepyDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_09_sheepy_easteregg.update
tt.ui.click_rect = r(-20, -10, 40, 40)
tt = E:register_t("decal_stage_10_mask", "decal")
tt.render.sprites[1].name = "T2_Stage_10_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_10_fire", "decal")
tt.render.sprites[1].prefix = "stage_10_fireDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_10_obelisk", "decal")
tt.render.sprites[1].name = "stage10_obelisk_base"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_10_obelisk_back", "decal")
tt.render.sprites[1].name = "stage10_obelisk_base_back"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_10_obelisk_priests", "decal")
tt.render.sprites[1].prefix = "stage10_obelisk_priests"
tt.render.sprites[1].name = "idle_off"
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].animated = true
tt = E:register_t("decal_stage_10_obelisk_crystals", "decal")
tt.render.sprites[1].prefix = "stage10_obelisk_base_cristalitos"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage10_obelisk_base_cristalitos_back"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_DECALS - 1
tt.render.sprites[2].animated = true
tt = E:register_t("decal_stage_10_ymca_ground_decos", "decal")
tt.render.sprites[1].name = "ymca_spawn_fx_layer_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_10_obelisk_crystal", "decal_tween")
tt.render.sprites[1].prefix = "stage10_obelisk_crystal"
tt.render.sprites[1].name = "idle_off"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].animated = true
tt.move_frequency = 25
tt.move_distance = 20
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, tt.move_distance)}, {fts(tt.move_frequency), v(0, 15)}, {fts(tt.move_frequency * 2), v(0, tt.move_distance)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].keys = {{fts(0), v(0, 0)}, {fts(tt.move_frequency), v(0, tt.move_distance)}}
tt.tween.props[2].disabled = true
tt.tween.remove = false
tt.tween.disabled = true
tt = E:register_t("decal_stage_10_obelisk_crystal_fx", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "stage10_obelisk_changestate_fx_change"
tt.render.sprites[1].loop = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(12), 0}}
tt.tween.disabled = true
tt.main_script.update = scripts.decal_stage_10_obelisk_crystal_fx.update
tt = E:register_t("decal_stage_10_ymca_statue", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "ymca_statue"
tt.main_script.update = scripts.decal_stage_10_ymca_statue.update
tt.ui.click_rect = r(-30, -10, 60, 80)
tt.click_fx = "fx_stage_10_statue_click"
tt = E:register_t("decal_stage_10_ymca_dots", "decal")
tt.render.sprites[1].prefix = "YMCAPuntosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt = E:register_t("decal_stage_10_ymca_fireworks", "decal")
tt.render.sprites[1].prefix = "ymca_spawn_fx_layer_3"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].animated = true
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("decal_stage_10_ymca_lights", "decal")
tt.render.sprites[1].prefix = "ymca_spawn_fx_layer_4"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].animated = true

tt = E:register_t("decal_stage_11_cult_leader", "decal")
E:add_comps(tt, "taunts", "tween")
tt.render.sprites[1].prefix = "mydriasDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.taunts.delay_min = 20
tt.taunts.delay_max = 30
tt.taunts.sets = {}
tt.taunts.sets.pre_bossfight = CC("taunt_set")
tt.taunts.sets.pre_bossfight.format = "LV11_CULTIST_TAUNT_%02i"
tt.taunts.sets.pre_bossfight.end_idx = 6
tt.taunts.sets.in_bossfight = CC("taunt_set")
tt.taunts.sets.in_bossfight.format = "LV11_CULTIST_TAUNT_IN_BOSSFIGHT_%02i"
tt.taunts.sets.in_bossfight.end_idx = 6
tt.tween.props[1] = E:clone_c("tween_prop")
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, v(0, 0)}, {fts(35), v(0, 7)}, {fts(70), v(0, 0)}}
tt.tween.props[1].interp = "sine"
tt.tween.disabled = true
tt.tween.remove = false
tt = E:register_t("decal_stage_11_boss_corrupted_denas_intro_base", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "denas_intro_baseDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_11_boss_corrupted_denas_intro_chains", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "denas_intro_chainsDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt = E:register_t("decal_stage_11_boss_corrupted_denas_intro_jump", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "denas_intro_jumpDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false

tt = E:register_t("decal_stage_11_veznan", "tower")
b = balance.specials.stage11_veznan
E:add_comps(tt, "user_selection", "attacks")
tt.tower.type = "stage_11_veznan"
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.render.sprites[1].prefix = "stage11_veznan_export_veznan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(1.15)
tt.info = nil
tt.user_selection = CC("user_selection")
tt.user_selection.can_select_point_fn = scripts.decal_stage_11_veznan.can_select_point
tt.main_script.update = scripts.decal_stage_11_veznan.update
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].bullet = "bullet_stage_11_veznan_skill_1"
tt.attacks.list[1].bullet_spawn_pos = v(0, 50)
tt.attacks.list[2] = E:clone_c("custom_attack")
tt.attacks.list[2].preparation_time = fts(25)
tt.attacks.list[2].spawn_time = fts(30)
tt.attacks.list[2].decal = "decal_stage_11_veznan_skill_soldiers"
tt.attacks.list[2].decal_pos = {v(-40, 333), v(540, 91)}
tt.attacks.list[2].entity = "soldier_stage_11_veznan_skill_soldiers"
tt.attacks.list[2].available_paths = {{1, 4}, {2, 3, 5}}
tt.attacks.list[3] = E:clone_c("custom_attack")
tt.attacks.list[3].preparation_time = fts(25)
tt.attacks.list[3].mod = "mod_stage_11_veznan_skill_cage"
tt.skill_cooldown = b.cooldown
tt.hint_cooldown = 10
tt.illusion_template_name = "enemy_stage_11_cult_leader_illusion"
tt.cult_leader_template_name = "decal_stage_11_cult_leader"
tt.boss_corrupted_denas_template_name = "boss_corrupted_denas"
tt.hint_template_name = "decal_stage_11_veznan_hint"
tt.bullet_formation = {{v(0, 50)}, {v(-20, 30), v(20, 30)}, {v(-20, 30), v(20, 30), v(0, 50)}, {v(-20, 40), v(20, 40), v(0, 60), v(0, 30)}}
tt.spawn_fx = "fx_stage_11_veznan_spawn"
tt.spawn_fx_base = "fx_stage_11_veznan_spawn_base"
tt.spawn_delay = fts(42)
tt.sound_events.insert = "Stage11MidCinematicVeznanTeleport"
tt.sound_ready = "Stage11MidCinematicVeznanTeleport"
tt.sound_soul_impact_cast = "Stage11VeznanSoulImpactCast"
tt.sound_demon_guard_cast = "Stage11VeznanDemonGuardCast"

tt = E:register_t("bullet_stage_11_veznan_skill_1", "bolt")
tt.render.sprites[1].prefix = "stage11_veznan_export_proyectile"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = v(0.45, 0.5)
tt.main_script.update = scripts.bullet_stage_11_veznan_skill_1.update
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.15
tt.bullet.align_with_trajectory = true
tt.bullet.max_speed = 900
tt.bullet.min_speed = 360
tt.bullet.particles_name = "ps_bullet_stage_11_veznan_skill_1"
tt.bullet.hit_fx = "fx_bullet_stage_11_veznan_skill_1"
tt.sound_events.insert = "Stage11VeznanSoulImpactImpact"

tt = E:register_t("mod_stage_11_veznan_skill_cage", "mod_stun")
b = balance.specials.stage11_veznan.skill_cage
tt.render.sprites[1].prefix = "stage11_veznan_export_cage"
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].anchor = v(0.5, 0.41)
tt.render.sprites[1].scale = v(1.1, 1)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage11_veznan_export_cage_piso"
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].z = Z_DECALS
tt.main_script.update = scripts.mod_stage_11_veznan_skill_cage.update
tt.modifier.animation_phases = true
tt.modifier.use_mod_offset = false
tt.modifier.duration = b.duration
tt.sound_cast = "Stage11VeznanMagicShacklesCast"
tt.sound_end = "Stage11VeznanMagicShacklesRelease"

tt = E:register_t("taunts_s11_controller")
E:add_comps(tt, "main_script", "taunts", "editor")
tt.load_file = "level111_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_11_cult_leader = CC("taunt_set")
tt.taunts.sets.stage_11_cult_leader.format = "TAUNT_STAGE06_CULTIST_GREETING_%04i"
tt.taunts.sets.stage_11_cult_leader.decal_name = "decal_stage11_cultist_shoutbox"
tt.taunts.sets.stage_11_cult_leader.pos = v(740, 670)
tt = E:register_t("decal_stage11_cultist_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_stage_11_veznan_skill_soldiers", "decal_sequence")
tt.render.sprites[1].prefix = "stage11_veznan_export_spawn_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor = v(0.5, 0.35)
tt.sequence.steps = {"in", "spawn", "out"}
tt = E:register_t("decal_stage_11_veznan_skill_cage", "decal")
tt.render.sprites[1].prefix = "stage11_veznan_export_veznan_electric_skill3"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt = E:register_t("decal_stage_11_veznan_hint", "decal_tween")
tt.render.sprites[1].name = "stage11_veznan_export_globito"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.tween.props[1].keys = {{0, 255}, {3, 255}, {3.1, 0}}
tt.tween.remove = true
tt = E:register_t("decal_boss_corrupted_denas_hit_floor", "decal_tween")
tt.render.sprites[1].name = "denas_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {1.9, 255}, {2.3, 0}}
tt.tween.remove = true
tt = E:register_t("decal_boss_corrupted_denas_hit_spikes_1", "decal")
tt.render.sprites[1].name = "denas_spikes1_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("decal_boss_corrupted_denas_hit_spikes_2", "decal")
tt.render.sprites[1].name = "denas_spikes2_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("decal_boss_corrupted_denas_hit", "decal_scripted")
tt.render.sprites[1].name = "denas_dustexplosion_run"
tt.render.sprites[1].hide_after_runs = 1
tt.main_script.update = scripts.decal_stage_11_boss_corrupted_denas_hit.update
tt.floor_decal = "decal_boss_corrupted_denas_hit_floor"
tt.spike_decals = {"decal_boss_corrupted_denas_hit_spikes_1", "decal_boss_corrupted_denas_hit_spikes_2"}
tt.decal_spawn_range = 50
tt.distance_between = 20
tt.decal_amount = 5
tt = E:register_t("decal_boss_corrupted_denas_dust", "decal")
tt.render.sprites[1].name = "denas_dustexplosion_run"
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("decal_stage_11_portal", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].random_ts = 1
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].prefix = "stage_11_portalDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 1
tt = E:register_t("decal_stage_11_torches", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].random_ts = 1
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = v(1, 1)
tt.render.sprites[1].prefix = "stage_11_torchesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 2
tt = E:register_t("decal_stage_11_portal_crystal_1", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].prefix = "stage_11_crystal2_1Def"
tt.render.sprites[1].name = "idle_off"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 2
tt.tween_amplitude = 10
tt.tween_frecueny_min = 60
tt.tween_frecueny_max = 90
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt = E:register_t("decal_stage_11_portal_crystal_2", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal1_1Def"
tt = E:register_t("decal_stage_11_portal_crystal_3", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal1_2Def"
tt = E:register_t("decal_stage_11_portal_crystal_4", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal2_2Def"
tt = E:register_t("decal_stage_11_portal_crystal_5", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal2_3Def"
tt.render.sprites[1].draw_order = 0
tt = E:register_t("decal_stage_11_portal_crystal_6", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal2_4Def"
tt = E:register_t("decal_stage_11_portal_crystal_7", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal2_5Def"
tt.render.sprites[1].draw_order = 0
tt = E:register_t("decal_stage_11_portal_crystal_8", "decal_stage_11_portal_crystal_1")
tt.render.sprites[1].prefix = "stage_11_crystal2_6Def"
tt = E:register_t("decal_stage_11_lightnings_1", "decal")
tt.render.sprites[1].prefix = "stage_11_elec1Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_11_lightnings_2", "decal")
tt.render.sprites[1].prefix = "stage_11_elec2Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_11_lightnings_3", "decal")
tt.render.sprites[1].prefix = "stage_11_elec3Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

-- {
-- 	template = "decal_stage_11_mask",
-- 	pos = {
-- 		x = 512,
-- 		y = 384
-- 	}
-- },
-- 原在 stage111 中使用，但我们没有这个 sprite
-- tt = E:register_t("decal_stage_11_mask", "decal")
-- tt.render.sprites[1].name = "T2_Stage_11"
-- tt.render.sprites[1].animated = false
-- tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t("decal_stage_11_rock_1", "decal")
E:add_comps(tt, "tween", "editor")
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.tween_amplitude = 30
tt.tween_frecueny = 200
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.editor.props = {{"tween_amplitude", PT_NUMBER}, {"tween_frecueny", PT_NUMBER}}
tt = E:register_t("decal_stage_11_rock_2", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_2"
tt = E:register_t("decal_stage_11_rock_3", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_3"
tt = E:register_t("decal_stage_11_rock_4", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_4"
tt = E:register_t("decal_stage_11_rock_5", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_5"
tt.render.sprites[1].scale = vv(0.65)
tt = E:register_t("decal_stage_11_rock_6", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_6"
tt = E:register_t("decal_stage_11_rock_7", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_7"
tt = E:register_t("decal_stage_11_rock_8", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_8"
tt.render.sprites[1].scale = vv(0.75)
tt = E:register_t("decal_stage_11_rock_9", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_9"
tt = E:register_t("decal_stage_11_rock_10", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_10"
tt = E:register_t("decal_stage_11_rock_11", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_11"
tt = E:register_t("decal_stage_11_rock_12", "decal_stage_11_rock_11")
tt.render.sprites[1].scale = vv(1.35)
tt = E:register_t("decal_stage_11_rock_13", "decal_stage_11_rock_1")
tt.render.sprites[1].scale = vv(0.85)
tt = E:register_t("decal_stage_11_rock_14", "decal_stage_11_rock_13")
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_11_rock_15", "decal_stage_11_rock_2")
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_11_rock_16", "decal_stage_11_rock_4")
tt.render.sprites[1].scale = vv(1.25)
tt = E:register_t("decal_stage_11_rock_17", "decal_stage_11_rock_4")
tt.render.sprites[1].scale = v(0.75, 0.5)
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_11_rock_18", "decal_stage_11_rock_1")
tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_12"
tt = E:register_t("decal_stage_11_rock_19", "decal_stage_11_rock_18")
tt.render.sprites[1].scale = v(0.5, 0.5)
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_11_cultist_leader_modes", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].prefix = "stage_11_deco_mydrias_baseDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 1
tt = E:register_t("decal_stage_11_cultist_leader_modes_worker", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].prefix = "stage_11_deco_mydrias_workerDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 2
tt = E:register_t("decal_stage_11_veznan_modes", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "deco_veznan_statue_statue"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = true
tt.render.sprites[2].prefix = "deco_veznan_statue_torch"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].draw_order = 2
tt.render.sprites[2].offset = v(0, -66)
tt = E:register_t("decal_stage_11_sam_and_frodo", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "sam_and_frodoDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.main_script.update = scripts.decal_stage_11_sam_and_frodo.update
tt.ui.click_rect = r(370, -270, 50, 40)
tt.push_up_cooldown = 7
tt = E:register_t("decal_stage_11_sam_and_frodo_mask", "decal")
tt.render.sprites[1].name = "sam_and_frodo_easter_egg_mask"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt = E:register_t("decal_glare_terrain_3_overlay", "decal")

E:add_comps(tt, "tween")

tt.pos = v(512, 384)
tt.render.sprites[1].name = "display_of_true_might_slow_overlay"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].scale = vv(4096)
tt.render.sprites[1].alpha = 0
tt.tween.props[1].keys = {{0, 0}, {fts(30), 60}}
tt.tween.remove = false
tt.tween.disabled = true
tt = E:register_t("decal_item_veznan_wrath_dark_overlay", "decal")

E:add_comps(tt, "tween")

tt.pos = v(512, 384)
tt.render.sprites[1].name = "item_veznan_wrath_overlay"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].scale = vv(4096)
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].hidden = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 100}}
tt.tween.remove = false
tt.tween.disabled = false
tt = E:register_t("decal_item_veznan_wrath_green_overlay", "decal")
tt.pos = v(512, 384)
tt.render.sprites[1].name = "item_veznan_wrath_overlay_green"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].scale = vv(4096)
tt.render.sprites[1].alpha = 100
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_item_veznan_wrath_instakill_ground", "decal")

E:add_comps(tt, "timed")

tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "veznan_wrath_instakill_effect_fx"
tt.render.sprites[1].name = "idle"
tt.timed.runs = 1
tt = E:register_t("decal_terrain_3_floating_rock", "decal")
E:add_comps(tt, "tween", "editor")
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "T3_Stage_12_floating_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.tween_amplitude = 15
tt.tween_frecueny = 150
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}, {"render.sprites[1].draw_order", PT_NUMBER}, {"render.sprites[1].name", PT_STRING}, {"render.sprites[1].z", PT_NUMBER}}

tt = E:register_t("decal_terrain_3_floating_rock_1", "decal_terrain_3_floating_rock")
tt.render.sprites[1].name = "t3_crater_asst_crater_rock1"
tt = E:register_t("decal_terrain_3_floating_rock_2", "decal_terrain_3_floating_rock")
tt.render.sprites[1].name = "t3_crater_asst_crater_rock2"
tt = E:register_t("decal_terrain_3_floating_rock_3", "decal_terrain_3_floating_rock")
tt.render.sprites[1].name = "t3_crater_asst_crater_rock3"
tt = E:register_t("decal_terrain_3_floating_rock_4", "decal_terrain_3_floating_rock")
tt.render.sprites[1].name = "t3_crater_asst_crater_rock4"
tt = E:register_t("decal_terrain_3_floating_rock_5", "decal_terrain_3_floating_rock")
tt.render.sprites[1].name = "t3_crater_asst_crater_rock5"

tt = E:register_t("decal_terrain_3_glare_eye_big", "decal_scripted")
tt.render.sprites[1].name = "glare_eye_big"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "glare_eyelids_big"
tt.render.sprites[2].name = "idle_close"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].draw_order = 4
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "glare_eye_big_pupil"
tt.render.sprites[3].name = "look"
tt.render.sprites[3].animated = true
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].draw_order = 3
tt.main_script.update = scripts.decal_terrain_3_glare_eye.update
tt.sid_eyelids = 2
tt.sid_pupil = 3
tt.is_big_eye = true
tt = E:register_t("decal_terrain_3_glare_eye_small", "decal_scripted")
tt.render.sprites[1].prefix = "glare_eye_big"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "glare_eyelids_big"
tt.render.sprites[2].name = "idle_close"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].draw_order = 3
tt.main_script.update = scripts.decal_terrain_3_glare_eye.update
tt.sid_eye = 1
tt.sid_eyelids = 2
tt = E:register_t("decal_terrain_3_glare_eye_small_1", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_eyes_1"
tt.render.sprites[2].prefix = "glare_eyelids_1"
tt = E:register_t("decal_terrain_3_glare_eye_small_2", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_eyes_2"
tt.render.sprites[2].prefix = "glare_eyelids_2"
tt = E:register_t("decal_terrain_3_glare_eye_small_3", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_eyes_3"
tt.render.sprites[2].prefix = "glare_eyelids_3"
tt = E:register_t("decal_stage_12_sheepy_easteregg", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "stage_12_sheepyDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.decal_stage_12_sheepy_easteregg.update
tt.ui.click_rect = r(410, 230, 40, 40)
tt = E:register_t("decal_stage_12_tentacles", "decal")
tt.render.sprites[1].prefix = "BKtentacleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[1].fps = 15
tt = E:register_t("decal_stage_12_glare", "decal")
tt.render.sprites[1].prefix = "stage_12_glareDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_12_mask_1", "decal")
tt.render.sprites[1].name = "T3_12_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t("decal_stage_12_mask_2", "decal_stage_12_mask_1")
tt.render.sprites[1].name = "T3_12_mask_02"
tt = E:register_t("decal_stage_12_mask_3", "decal_stage_12_mask_1")
tt.render.sprites[1].name = "T3_12_mask_03"
tt = E:register_t("decal_stage_12_mask_4", "decal_stage_12_mask_1")
tt.render.sprites[1].name = "T3_12_mask_04"
tt = E:register_t("decal_stage_12_windmill", "decal_click_pause")

E:add_comps(tt, "ui", "tween")

tt.render.sprites[1].prefix = "t3_windmillDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.ui.click_rect = r(-25, -5, 50, 70)
tt.tween_amplitude = 15
tt.tween_frecuency = 150
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, 0)}, {fts(tt.tween_frecuency), v(0, tt.tween_amplitude)}, {fts(tt.tween_frecuency * 2), v(0, 0)}}
tt.main_script.update = scripts.decal_stage_12_windmill.update
tt = E:register_t("decal_stage_12_easter_egg_strangerthings", "decal")

E:add_comps(tt, "pos", "render", "ui", "main_script")

tt.main_script.update = scripts.decal_stage_12_easter_egg_strangerthings.update
tt.render.sprites[1].prefix = "stranger_thingsDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.ui.click_rect = r(-365, -240, 95, 55)
tt = E:register_t("decal_stage_13_tentacles", "decal_stage_12_tentacles")
tt.render.sprites[1].prefix = "BKtentacle13Def"
tt = E:register_t("decal_stage_13_mask_1", "decal")
tt.render.sprites[1].name = "stage13_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_13_mask_2", "decal_stage_13_mask_1")
tt.render.sprites[1].name = "stage13_mask2"
tt = E:register_t("decal_stage_13_mask_3", "decal_stage_13_mask_1")
tt.render.sprites[1].name = "stage13_masktentacle1"
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t("decal_stage_13_mask_4", "decal_stage_13_mask_1")
tt.render.sprites[1].name = "stage13_masktentacle2"
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t("decal_stage_13_glare", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_13_glareDef"
tt = E:register_t("decal_stage_14_easter_egg_rickmorty", "decal")

E:add_comps(tt, "editor", "pos", "main_script", "render", "ui")

tt.main_script.update = scripts.decal_stage_14_easter_egg_rickmorty.update
tt.render.sprites[1].prefix = "Rick1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.idle_cooldown_min = 4
tt.idle_cooldown_max = 8
tt.ui.click_rect = r(-40, -30, 80, 50)
tt.pos_spawn = {v(130, 210), v(1033, 468)}
tt.prefix_names = {"Rick2Def", "Rick3Def"}
tt = E:register_t("decal_stage_14_glare_1", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_14_glare_1Def"
tt = E:register_t("decal_stage_14_glare_2", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_14_glare_2Def"
tt = E:register_t("decal_terrain_3_glare_eye_big_stage_14", "decal_terrain_3_glare_eye_big")
tt.render.sprites[1].name = "glare_stage_14_eye_2_big"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_big"
tt.render.sprites[3].prefix = "glare_stage_14_eye_2_big_pupil"
tt = E:register_t("decal_terrain_3_glare_eye_small_1_stage_14", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_1"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_1"
tt = E:register_t("decal_terrain_3_glare_eye_small_2_stage_14", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_2"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_2"
tt = E:register_t("decal_terrain_3_glare_eye_small_3_stage_14", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_14_eye_2_3"
tt.render.sprites[2].prefix = "glare_stage_14_eyelid_2_3"
tt = E:register_t("decal_stage_14_tentacles", "decal_stage_12_tentacles")
tt.render.sprites[1].prefix = "BKtentacle14Def"
tt = E:register_t("decal_stage_14_mask_1", "decal")
tt.render.sprites[1].name = "T3_S14_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_14_mask_2", "decal_stage_14_mask_1")
tt.render.sprites[1].name = "T3_S14_mask_02"
tt = E:register_t("decal_stage_14_mask_3", "decal_stage_14_mask_1")
tt.render.sprites[1].name = "T3_S14_mask_03"
tt = E:register_t("decal_stage_14_mask_4", "decal_stage_14_mask_1")
tt.render.sprites[1].name = "T3_S14_mask_04"
tt = E:register_t("decal_stage_14_mask_amalgam", "decal_stage_14_mask_1")
tt.render.sprites[1].name = "T3_S14_mask_amalgam"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 90
tt = E:register_t("decal_controller_stage_14_amalgam", "decal_stage_14_mask_1")
tt.render.sprites[1].prefix = "Amalgam_dude"
tt.render.sprites[1].name = "state_1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_14_hidden_path", "decal")
tt.render.sprites[1].prefix = "hidden_pathDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_14_hidden_path_dust", "decal")
tt.render.sprites[1].prefix = "dust_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_15_glare", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_15_glareDef"
tt = E:register_t("decal_stage_15_tentacles", "decal_stage_12_tentacles")
tt.render.sprites[1].prefix = "BKtentacle_S15Def"
tt = E:register_t("decal_stage_15_mask_1", "decal")
tt.render.sprites[1].name = "T3_15_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_15_mask_2", "decal_stage_15_mask_1")
tt.render.sprites[1].name = "T3_15_mask_02"
tt = E:register_t("decal_stage_15_mask_3", "decal_stage_15_mask_1")
tt.render.sprites[1].name = "T3_15_mask_03"
tt = E:register_t("decal_stage_15_mask_4", "decal_stage_15_mask_1")
tt.render.sprites[1].name = "T3_15_mask_04"
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_15_mask_5", "decal_stage_15_mask_1")
tt.render.sprites[1].name = "T3_15_mask_05"
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_terrain_3_glare_eye_big_stage_15", "decal_terrain_3_glare_eye_big")
tt.render.sprites[1].name = "glare_stage_15_eye_big"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_big"
tt.render.sprites[3].prefix = "glare_stage_15_eye_big_pupil"
tt = E:register_t("decal_terrain_3_glare_eye_small_1_stage_15", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_15_eyes_1"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_1"
tt = E:register_t("decal_terrain_3_glare_eye_small_2_stage_15", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_15_eyes_2"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_2"
tt = E:register_t("decal_terrain_3_glare_eye_small_3_stage_15", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_15_eyes_3"
tt.render.sprites[2].prefix = "glare_stage_15_eyelids_3"
tt = E:register_t("decal_soldier_reinforcement_stage_15_denas_spawn", "decal_timed")
tt.render.sprites[1].name = "denas_floor_fx_idle"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_soldier_reinforcement_stage_15_denas_floor", "decal_timed")
tt.render.sprites[1].name = "denas_decal_Idle"
tt.render.sprites[1].z = Z_DECALS + 1
tt = E:register_t("decal_stage_15_cult_leader_tower_mask", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "mutamydrias_fx_Mutamydrias_balcon"
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 15
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_15_tentacle_stun_out", "decal")

E:add_comps(tt, "editor", "tween")

tt.render.sprites[1].prefix = "mutamydrias_fx_Mutamydrias_Stuncircle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "decalfade"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mutamydrias_fx_Mutamydrias_Stuncircle_Eye"
tt.render.sprites[2].name = "decalfade"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].offset = v(0, 13)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = v(22, 0)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = v(0, -13)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = v(-22, 0)
tt.tween.remove = true
tt.duration = 1.5
tt.tween.props[1].keys = {{0, 0}, {0.6, 0}, {0.8, 255}, {tt.duration, 255}, {tt.duration + 1, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = table.deepclone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 4
tt.tween.props[5] = table.deepclone(tt.tween.props[1])
tt.tween.props[5].sprite_id = 5
tt = E:register_t("decal_stage_15_tentacle_stun_activate", "decal_stage_15_tentacle_stun_out")
tt.render.sprites[1].name = "stun"
tt.render.sprites[2].name = "stun"
tt.render.sprites[3].name = "stun"
tt.render.sprites[4].name = "stun"
tt.render.sprites[5].name = "stun"
tt.duration = 0.6
tt.tween.props[1].keys = {{0, 255}, {0.15, 255}, {tt.duration, 255}, {tt.duration + 0.25, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = table.deepclone(tt.tween.props[1])
tt.tween.props[4].sprite_id = 4
tt.tween.props[5] = table.deepclone(tt.tween.props[1])
tt.tween.props[5].sprite_id = 5
-- tt = E:register_t("decal_soldier_reinforcement_item_summon_blackburn_area_attack", "decal_timed")
-- tt.render.sprites[1].name = "item_summon_blackburn_attack_2_decal_idle"
-- tt.render.sprites[1].z = Z_DECALS
-- tt = E:register_t("decal_item_portable_coil", "decal_scripted")
-- b = balance.items.portable_coil
-- tt.render.sprites[1].prefix = "item_portable_coilDef"
-- tt.render.sprites[1].name = "spawn"
-- tt.render.sprites[1].animated = true
-- tt.render.sprites[1].exo = true
-- tt.render.sprites[1].z = Z_OBJECT
-- tt.main_script.update = scripts.decal_item_portable_coil.update
-- tt.vis_flags = bor(F_STUN)
-- tt.vis_bans = bor(F_NIGHTMARE)
-- tt.range = b.range
-- tt.bullet_start_offset = v(0, 45)
-- tt.hit_time = fts(2)
-- tt.ray = "bullet_decal_item_portable_coil"
-- tt.max_targets = b.max_targets
-- tt.sound_cast = "ItemsPortableCoilCast"
-- tt.sound_attack = "ItemsPortableCoilAttack"
-- tt = E:register_t("decal_item_scroll_of_spaceshift", "decal_timed")
-- tt.render.sprites[1].name = "item_scroll_of_spaceshift_decal_in"
-- tt.render.sprites[1].z = Z_DECALS
-- tt = E:register_t("decal_item_loot_box_chest_projectile", "decal_scripted")
-- b = balance.items.loot_box

-- E:add_comps(tt, "bullet")

-- tt.render.sprites[1].name = "item_loot_box_chest_projectile"
-- tt.render.sprites[1].animated = false
-- tt.render.sprites[1].z = Z_BULLETS
-- tt.render.sprites[1].scale = vv(0.95)
-- tt.bullet.max_speed = 3000
-- tt.bullet.arrive_decal = "decal_item_loot_box_chest"
-- tt.bullet.aura = "aura_item_loot_box_damage"
-- tt.main_script.update = scripts.decal_item_loot_box_projectile.update
-- tt.dust = "fx_item_loot_box_dust"
-- tt.floor_decal = "decal_item_loot_box_floor"
-- tt.gold_amount = b.gold_amount
-- tt.gold_pos_offset = v(0, 60)
-- tt.sound_hit = "ItemsLootBoxCast"
-- tt = E:register_t("decal_item_loot_box_chest", "decal_tween")
-- tt.render.sprites[1].prefix = "item_loot_box_chest"
-- tt.render.sprites[1].name = "in"
-- tt.render.sprites[1].scale = vv(0.95)
-- tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
-- tt.tween.remove = true
-- tt.tween.disabled = false
-- tt.tween.disabled = false
-- tt = E:register_t("decal_item_loot_box_pig_projectile", "decal_item_loot_box_chest_projectile")
-- tt.render.sprites[1].name = "item_loot_box_pig_projectile"
-- tt.bullet.arrive_decal = "decal_item_loot_box_pig"
-- tt = E:register_t("decal_item_loot_box_pig", "decal_item_loot_box_chest")
-- tt.render.sprites[1].prefix = "item_loot_box_pig"
-- tt = E:register_t("decal_item_loot_box_statue_projectile", "decal_item_loot_box_chest_projectile")
-- tt.render.sprites[1].name = "item_loot_box_statue_projectile"
-- tt.render.sprites[1].scale = vv(1)
-- tt.bullet.arrive_decal = "decal_item_loot_box_statue"
-- tt = E:register_t("decal_item_loot_box_statue", "decal_item_loot_box_chest")
-- tt.render.sprites[1].prefix = "item_loot_box_statue"
-- tt.render.sprites[1].scale = vv(1)
-- tt = E:register_t("decal_item_loot_box_floor", "decal_tween")
-- tt.render.sprites[1].name = "item_loot_box_decal"
-- tt.render.sprites[1].animated = false
-- tt.render.sprites[1].z = Z_DECALS
-- tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
-- tt.tween.remove = true
-- tt.tween.disabled = false
-- tt = E:register_t("decal_item_second_breath", "decal_timed")
-- tt.render.sprites[1].name = "item_second_breath_decal_idle"
-- tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("taunts_s115_controller")
E:add_comps(tt, "main_script", "taunts", "editor")
tt.load_file = "level115_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.taunts_controller.update
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_15_cult_leader_greetings = CC("taunt_set")
tt.taunts.sets.stage_15_cult_leader_greetings.format = "TAUNT_STAGE15_CULTIST_%04i"
tt.taunts.sets.stage_15_cult_leader_greetings.decal_name = "decal_stage15_cultist_shoutbox"
tt.taunts.sets.in_bossfight = CC("taunt_set")
tt.taunts.sets.in_bossfight.format = "LV15_CULTIST01_BOSSFIGHT_%02i"
tt.taunts.sets.in_bossfight.decal_name = "decal_stage11_cultist_shoutbox"
tt.taunts.sets.in_bossfight.start_idx = 1
tt.taunts.sets.in_bossfight.end_idx = 6

tt = E:register_t("decal_stage15_cultist_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "cultist_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "cultist_taunt_0003"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_BULLETS
tt.render.sprites[3].offset = v(13, -13)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 3
tt.texts.list[1].fit_height = true
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, v(1.01, 1.01)}, {0.4, v(0.99, 0.99)}, {0.8, v(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
tt = E:register_t("decal_stage_15_boss_cult_leader_ray", "decal_tween")
tt.render.sprites[1].prefix = "mutamydrias_ray_decalDef"
tt.render.sprites[1].name = "areaattack"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {1.5, 0}}
tt.tween.remove = true
tt = E:register_t("decal_stage_15_tentacle_spawn", "decal_tween")
tt.render.sprites[1].prefix = "mutamydrias_fx_Mutamydrias_Stuncircle_Tentacles"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS + 1
tt.tween.props[1].keys = {{0, 255}, {fts(20), 255}}
tt.tween.remove = true
tt = E:register_t("decal_stage_15_easter_egg_goblin", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = scripts.decal_stage_15_easter_egg_goblin.update
tt.render.sprites[1].prefix = "t3stage15_eastereggDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 10
tt.out_cooldown = 5
tt.sweep_cooldown = 2
tt.time_to_in_cooldown = 20
tt.ui.click_rect = r(-10, -30, 50, 50)
tt = E:register_t("decal_stage_15_easter_egg_goblin_portal", "decal")
tt.render.sprites[1].prefix = "t3stage15_easteregg_tempportalDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 10
tt = E:register_t("decal_stage_15_mask_modes", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage15modos"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 20
tt = E:register_t("decal_stage_16_mask_1", "decal")
tt.render.sprites[1].name = "stage16_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_16_mask_2", "decal")
tt.render.sprites[1].name = "stage16_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_16_mask_3", "decal")
tt.render.sprites[1].name = "stage16_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_16_mask_4", "decal")
tt.render.sprites[1].name = "stage16_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_16_holder_destroy_fx", "decal")
tt.render.sprites[1].name = "overseer_fx_overseer_crater_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("decal_stage_16_holder_destroy_crater", "decal_scripted")
tt.render.sprites[1].prefix = "t3_craterDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_stage_16_holder_destroy_crater.update
tt = E:register_t("decal_stage_16_tower_change_fx", "decal_tween")
tt.render.sprites[1].prefix = "overseer_fx_overseer_teleportdecal"
tt.render.sprites[1].name = "decalin"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(-2, 5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "overseer_fx_overseer_teleportdecal"
tt.render.sprites[2].name = "decalactivate"
tt.render.sprites[2].animated = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].offset = v(-2, 5)
tt.duration = 2.8 + fts(60)
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {1, 255}, {"this.duration-0.25", 255}, {"this.duration", 0}}
tt = E:register_t("decal_stage_16_overseer_tentacle_projectile", "decal_tween")
tt.render.sprites[1].name = "overseer_fx_overseer_proyectile_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.duration = 2.5
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration-0.5", 255}, {"this.duration", 0}}
tt = E:register_t("decal_stage_16_glare_1", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_16_glare_1Def"
tt = E:register_t("decal_stage_16_glare_2", "decal_stage_12_glare")
tt.render.sprites[1].prefix = "stage_16_glare_2Def"
tt = E:register_t("decal_stage_16_glare_eye_big", "decal_scripted")
tt.render.sprites[1].name = "glare_stage_16_eye_big"
tt.render.sprites[1].animated = false
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_big"
tt.render.sprites[2].name = "idle_close"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].draw_order = 4
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "glare_stage_16_eye_big_pupil"
tt.render.sprites[3].name = "look"
tt.render.sprites[3].animated = true
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].draw_order = 3
tt.main_script.update = scripts.decal_terrain_3_glare_eye.update
tt.sid_eyelids = 2
tt.sid_pupil = 3
tt.is_big_eye = true
tt = E:register_t("decal_stage_16_glare_eye_small_1", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_16_eyes_1"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_1"
tt = E:register_t("decal_stage_16_glare_eye_small_2", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_16_eyes_2"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_2"
tt = E:register_t("decal_stage_16_glare_eye_small_3", "decal_terrain_3_glare_eye_small")
tt.render.sprites[1].prefix = "glare_stage_16_eyes_3"
tt.render.sprites[2].prefix = "glare_stage_16_eyelids_3"
tt = E:register_t("decal_stage_16_overseer_blood")
E:add_comps(tt, "pos", "main_script")
tt.main_script.update = scripts.decal_stage_16_overseer_blood.update
tt.blood_pos = {v(20, 20), v(100, 100), v(-100, 100), v(-150, -30), v(150, -70), v(-30, 40)}
tt.fx_template = "decal_stage_16_overseer_single_blood_fx"
tt = E:register_t("decal_stage_16_overseer_single_blood_fx", "decal_tween")
tt.render.sprites[1].name = "overseer_fx_overseer_blood"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].offset = v(20, 20)
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {fts(13), 255}, {fts(16), 0}}
tt = E:register_t("decal_stage_16_death_bright", "decal")
tt.render.sprites[1].prefix = "overseer_deathbrightDef"
tt.render.sprites[1].name = "areaattack"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt = E:register_t("decal_stage_16_overseer_destroy_holder_bright", "decal_tween")
tt.render.sprites[1].name = "overseer_fx_overseer_destroyray_bright_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {fts(25), 255}, {fts(26), 0}}
tt.tween.remove = true
tt = E:register_t("decal_terrain_4_cheshire_cat_easter_egg", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "cheshire_cat_easter_egg_cat"
tt.render.sprites[1].name = "idle"
tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.main_script.update = scripts.decal_terrain_4_cheshire_cat_easter_egg.update
tt.animations_tap = {"action_1", "action_2", "action_3"}
tt.level_index = nil
tt.appear_cd_min = 7
tt.appear_cd_max = 14
tt.appear_duration_min = 3
tt.appear_duration_max = 7
tt.sound_in = "Terrain4CheshireCatIn"
tt.sound_out = "Terrain4CheshireCatOut"
tt = E:register_t("decal_stage_17_mask_3", "decal")
tt.render.sprites[1].name = "stage17_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_hidden_path_1", "decal")
tt.render.sprites[1].prefix = "hidden_path_01Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_hidden_path_2", "decal")
tt.render.sprites[1].prefix = "hidden_path_02Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_hidden_path_unlock_soulcaller", "decal")
tt.render.sprites[1].prefix = "hidden_path_reventant_revenant_roots_reveal"
tt.render.sprites[1].name = "revenant_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS + 1
tt = E:register_t("decal_stage_17_bubbles", "decal")
tt.render.sprites[1].prefix = "stage_17_bubblesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_bubbles_water", "decal")
tt.render.sprites[1].prefix = "stage_17_bubbles_waterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_tree_1", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "stage_17_tree_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_17_tree.update
tt.ui.can_click = true
tt.ui.click_rect = r(-75, -290, 90, 80)
tt.sound_tap = "Terrain4HowlingTree"
tt = E:register_t("decal_stage_17_tree_2", "decal_stage_17_tree_1")
tt.render.sprites[1].prefix = "stage_17_tree_2Def"
tt.ui.click_rect = r(-570, -230, 90, 80)
tt = E:register_t("decal_stage_17_tree_3", "decal_stage_17_tree_1")
tt.render.sprites[1].prefix = "stage_17_tree_3Def"
tt.ui.click_rect = r(20, 300, 90, 80)
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_17_tree_4", "decal_stage_17_tree_1")
tt.render.sprites[1].prefix = "stage_17_tree_4Def"
tt.render.sprites[1].z = Z_DECALS
tt.ui.click_rect = r(-227, 270, 90, 80)
tt = E:register_t("decal_stage_18_mask_1", "decal")
tt.render.sprites[1].name = "stage18_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_18_tree_1", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "stage_18_tree_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_17_tree.update
tt.ui.can_click = true
tt.ui.click_rect = r(-335, -200, 80, 80)
tt.sound_tap = "Terrain4HowlingTree"
tt = E:register_t("decal_stage_18_tree_2", "decal_stage_18_tree_1")
tt.render.sprites[1].prefix = "stage_18_tree_2Def"
tt.ui.click_rect = r(495, -170, 80, 80)
tt = E:register_t("decal_stage_18_bubbles", "decal")
tt.render.sprites[1].prefix = "stage_18_bubblesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_18_bubbles_water", "decal")
tt.render.sprites[1].prefix = "stage_18_bubbles_waterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_18_streetlight_1", "decal_scripted")

E:add_comps(tt, "editor", "editor_script", "ui")

tt.render.sprites[1].prefix = "stage_18_light_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -250
tt.main_script.update = scripts.decal_stage_18_streetlight.update
tt.ui.can_click = true
tt.ui.click_rect = r(-60, -210, 30, 40)
tt.sound_break = "Stage18LampBreak"
tt = E:register_t("decal_stage_18_streetlight_2", "decal_stage_18_streetlight_1")
tt.render.sprites[1].prefix = "stage_18_light_2Def"
tt.render.sprites[1].sort_y_offset = 250
tt.ui.click_rect = r(135, 290, 30, 40)
tt = E:register_t("decal_stage_18_streetlight_3", "decal_stage_18_streetlight_1")
tt.render.sprites[1].prefix = "stage_18_light_3Def"
tt.render.sprites[1].sort_y_offset = 223
tt.ui.click_rect = r(535, 263, 30, 40)
tt = E:register_t("decal_stage_18_streetlight_4", "decal_stage_18_streetlight_1")
tt.render.sprites[1].prefix = "stage_18_light_4Def"
tt.render.sprites[1].sort_y_offset = 33
tt.ui.click_rect = r(520, 73, 30, 40)
tt = E:register_t("decal_stage_18_cuckoo", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-30, -30, 60, 60)
tt.main_script.update = scripts.decal_stage_18_cuckoo.update
tt.render.sprites[1].prefix = "cuckoo_easter_egg_door"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.touches_needed = 3
tt.touchable_after_anim = false
tt.reset_touches = false
tt.duration = 0.6
tt.sound_in = "Stage18CuckooIn"
tt.sound_out = "Stage18CuckooOut"
tt = E:register_t("decal_stage_19_mask_1", "decal")
tt.render.sprites[1].name = "stage19_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 194
tt = E:register_t("decal_stage_19_mask_2", "decal")
tt.render.sprites[1].name = "stage19_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_19_mask_3", "decal")
tt.render.sprites[1].name = "stage19_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_19_statue", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(272, 110, 60, 60)
tt.main_script.update = scripts.decal_stage_19_statue.update
tt.render.sprites[1].prefix = "stage_19_statue_decoDef"
tt.render.sprites[1].name = "idle_campaign"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_12 = "Stage19Statue12"
tt.sound_3 = "Stage19Statue3"
tt = E:register_t("decal_stage_19_statue_hands", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "navira_hands"
tt.render.sprites[1].name = "hands_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].draw_order = -1
tt = E:register_t("decal_stage_19_bubbles", "decal")
tt.render.sprites[1].prefix = "stage_19_bubblesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_19_bubbles_water", "decal")
tt.render.sprites[1].prefix = "stage_19_bubbles_waterDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_19_smoke", "decal")
tt.render.sprites[1].prefix = "stage_19_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t("decal_stage_19_navira_cape", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "navira_naviracape"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].z = Z_EFFECTS
tt.main_script.update = scripts.decal_stage_19_navira_cape.update
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {fts(67), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(25, 50)}, {fts(22), v(50, 50)}, {fts(67), v(100, 25)}}
tt = E:register_t("stage20_arborean_house", "unit")

local b = balance.specials.stage20_arborean_house

E:add_comps(tt, "editor", "main_script", "info", "vis", "soldier")

tt.info.fn = scripts.stage20_arborean_house.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0020"
tt.info.i18n_key = "ARBOREAN_HOUSE_1"
tt.main_script.update = scripts.stage20_arborean_house.update
tt.render.sprites[1].prefix = "arborean_house_base"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].offset.y = 0
tt.life_thresholds = {0.66, 0.33, 0}
tt.threshold_fx = "fx_stage_20_arborean_house_hit_1"
tt.threshold_fx_last = "fx_stage_20_arborean_house_hit_2"
tt.unit.hit_offset = v(0, 15)
tt.health.hp_max = b.hp_max
tt.health.hp = b.hp_max
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 255, 0, 255}
tt.health_bar.colors.bg = {0, 0, 0, 255}
tt.health.ignore_delete_after = true
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.vis.flags = bor(F_FRIEND, F_RANGED)
tt.vis.bans = bor(F_AREA, F_MOD)
tt = E:register_t("decal_stage_21_mask_1", "decal")
tt.render.sprites[1].name = "stage21_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_21_mask_2", "decal")
tt.render.sprites[1].name = "stage21_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 1
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_21_mask_3", "decal")
tt.render.sprites[1].name = "stage21_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 2
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_21_mask_4", "decal")
tt.render.sprites[1].name = "stage21_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_21_bubbles", "decal")
tt.render.sprites[1].prefix = "stage_21_bubbles_02Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_21_mask_lianas", "decal")
tt.render.sprites[1].name = "stage21_mask_lianas"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_FLYING_HEROES + 1
tt = E:register_t("decal_stage_21_falling_rocks", "decal_scripted")

local b = balance.specials.stage21_falling_rocks

E:add_comps(tt, "editor", "editor_script", "ui")

tt.render.sprites[1].name = "proxy_stage_21_falling_rocks1"
tt.render.sprites[1].name_fallen = "proxy_stage_21_falling_rocks2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = v(0, 50)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "proxy_stage_21_falling_rocks3"
tt.render.sprites[2].animated = false
tt.render.sprites[2].hidden = true
tt.main_script.update = scripts.decal_stage_21_falling_rocks.update
tt.ui.can_click = true
tt.ui.click_rect = r(-20, 5, 40, 80)
tt.damage = b.damage
tt.damage_type = b.damage_type
tt.damage_radius = b.damage_radius
tt.vis_flags = bor(F_AREA)
tt.vis_bans = 0
tt.fall_position = nil
tt.fall_fx = "fx_decal_stage_21_falling_rocks"
tt = E:register_t("decal_stage_22_rune_rock", "decal_scripted")
tt.main_script.update = scripts.decal_stage_22_rune_rock.update
tt.animation_idle = "idle1"
tt.animation_start = "redin"
tt.animation_loop = "redloop"
tt.animation_end = "redout"
tt.render.sprites[1].prefix = "rune_rockDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_22_rune_doors", "decal_scripted")
tt.main_script.update = scripts.decal_stage_22_rune_rock.update
tt.animation_idle = "idleblue"
tt.animation_start = "redin"
tt.animation_loop = "idlered"
tt.animation_end = "redout"
tt.render.sprites[1].prefix = "stage_22_Glow_Rock1Def"
tt.render.sprites[1].name = tt.animation_idle
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_22_Glow_Rock2Def"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].prefix = "stage_22_Glow_Rock3Def"
tt.render.sprites[3].sort_y_offset = 100
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].prefix = "stage_22_Glow_Rock4Def"
tt.render.sprites[5] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[5].prefix = "stage_22_Glow_Rock5Def"
tt.render.sprites[5].sort_y_offset = -100
tt.render.sprites[5].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_22_remolino", "decal_scripted")

local b = balance.specials.stage22_remolino

tt.main_script.update = scripts.decal_stage_22_remolino.update
tt.animation_start = "in"
tt.animation_loop = "loop"
tt.animation_end = "out"
tt.render.sprites[1].prefix = "remolino_stage_3_anim"
tt.render.sprites[1].name = tt.animation_start
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.waves = b
tt = E:register_t("decal_stage_22_puerta1", "decal")
tt.render.sprites[1].name = "stage_22_puerta1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_22_puerta2", "decal")
tt.render.sprites[1].name = "stage_22_puerta2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_22_puerta3", "decal")
tt.render.sprites[1].name = "stage_22_puerta3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 290
tt = E:register_t("decal_stage_22_puerta4", "decal")
tt.render.sprites[1].name = "stage_22_puerta4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 290
tt = E:register_t("decal_stage_22_puerta5", "decal")
tt.render.sprites[1].name = "stage_22_puerta5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_22_puerta6", "decal")
tt.render.sprites[1].name = "stage_22_puerta6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_22_sombras", "decal")
tt.render.sprites[1].name = "stage_22_sombras"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_stage_22_water_vfx1", "decal")
tt.render.sprites[1].prefix = "stage_22_bubbles_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_22_water_vfx2", "decal_stage_22_water_vfx1")
tt.render.sprites[1].prefix = "stage_22_bubbles_02Def"
tt = E:register_t("decal_stage_22_easteregg_sheepy", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = scripts.decal_stage_22_easteregg_sheepy.update
tt.render.sprites[1].prefix = "croco_sheepy"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -5, 30, 50)
tt = E:register_t("decal_stage20_ruperto_easter_egg", "decal_scripted")

E:add_comps(tt)

tt.render.sprites[1].prefix = "anim_arborean_ruperto_arborean"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.main_script.update = scripts.decal_stage20_ruperto_easter_egg.update
tt.animations_random = {"action1", "action2"}
tt.appear_cd_min = 7
tt.appear_cd_max = 14
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage20_ruperto_ruperto_easter_egg", "decal_scripted")

E:add_comps(tt)

tt.render.sprites[1].name = "anim_arborean_ruperto_ruperto"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_achievement_stage_21_croc_boat", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-55, -20, 90, 60)
tt.main_script.update = scripts.decal_achievement_stage_21_croc_boat.update
tt.touches_needed = 2
tt.render.sid_croc = 3
tt.render.sprites[1].name = "Achievement_lagarto_juancho_boat"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(-8, -20)
tt.render.sprites[1].anchor = v(0.5833333333333334, 0.21052631578947367)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "Achievement_lagarto_juancho_water"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].anchor = v(0.7289156626506024, 0.29464285714285715)
tt.render.sprites[2].offset = v(-2, -16)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "Achievement_lagarto_juancho_creep"
tt.render.sprites[3].name = "idle1"
tt.render.sprites[3].animated = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].anchor = v(0.5, 0.38636363636363635)
tt.sound_engine_fail = "Stage21JuanchoEngineFail"
tt.sound_engine_success = "Stage21JuanchoEngineSuccess"
tt = E:register_t("decal_achievement_stage_22_croc_king", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-20, -10, 40, 40)
tt.main_script.update = scripts.decal_achievement_stage_22_croc_king.update
tt.render.sprites[1].prefix = "achievement_donkey_kong_creep"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = vv(0.5)
tt = E:register_t("decal_stage_21_dragonfly_1", "decal_delayed_play")
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.main_script.update = scripts.delayed_play_kr5.update
tt.render.sprites[1].prefix = "stage_21_dragonfly_01Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35
tt.delayed_play.start_min_delay = 1
tt.delayed_play.start_max_delay = 3

tt = E:register_t("decal_stage_21_dragonfly_2", "decal_stage_21_dragonfly_1")
tt.render.sprites[1].prefix = "stage_21_dragonfly_02Def"
tt.delayed_play.start_min_delay = 13
tt.delayed_play.start_max_delay = 20

tt = E:register_t("decal_stage_21_particlesLeft", "decal_delayed_play")
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.main_script.update = scripts.delayed_play_kr5.update
tt.render.sprites[1].prefix = "stage_21_particlesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "loop"
tt.delayed_play.min_delay = 15
tt.delayed_play.max_delay = 35

tt = E:register_t("soldier_elf_stage_08", "decal_scripted")
b = balance.specials.stage08_elf_rescue.elf
E:add_comps(tt, "bullet_attack", "editor")
tt.render.sprites[1].prefix = "elven_warrior"
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.soldier_elf_stage_08.update
tt.bullet_attack.max_range = b.range
tt.bullet_attack.bullet = "arrow_soldier_elf_stage_08"
tt.bullet_attack.shoot_time = fts(3)
tt.bullet_attack.cooldown_min = b.cooldown_min
tt.bullet_attack.cooldown_max = b.cooldown_max
tt.bullet_attack.bullet_start_offset = {v(20, 20), v(-20, 20)}
tt.bullet_attack.animation = "shoot"
tt.bullet_attack.vis_bans = bor(F_MINIBOSS, F_NIGHTMARE)
tt.idle_rest_cooldown = 2

tt = E:register_t("arrow_soldier_elf_stage_08", "arrow_45degrees")
b = balance.specials.stage08_elf_rescue.elf
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.bullet.fixed_height = 50
tt.bullet.miss_decal = "elven_warrior_arrow_0002"
tt.bullet.mod = "mod_arrow_soldier_elf_stage_08"
tt.render.sprites[1].name = "elven_warrior_arrow_0001"

tt = E:register_t("decal_stage_08_elf_rescue_chains", "decal_scripted")
tt.render.sprites[1].prefix = "ChainDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_08_elf_rescue_chains.update

tt = E:register_t("decal_stage_08_elf_rescue_elf_slave", "decal_scripted")
tt.render.sprites[1].prefix = "ElfSlaveDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.action_cooldown_min = fts(20)
tt.action_cooldown_max = fts(20)
tt.main_script.update = scripts.decal_stage_08_elf_rescue_elf_slave.update
tt.sound_rescue = "Stage08RescuedElves"

tt = E:register_t("mod_arrow_soldier_elf_stage_08", "mod_stun")
b = balance.specials.stage08_elf_rescue.elf
tt.modifier.duration = fts(b.stun_duration)
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = E:register_t("mod_enemy_blinker_stun", "mod_stun")
local b = balance.enemies.void_beyond.blinker
tt.modifier.duration = b.ranged_attack.stun_duration
tt.modifier.vis_flags = bor(F_MOD, F_STUN)

tt = E:register_t("mod_enemy_blinker_glare", "modifier")
AC(tt, "dps")
local b = balance.enemies.void_beyond.blinker.glare
tt.modifier.duration = b.dot_duration
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.dps.damage_min = b.dot_damage_min
tt.dps.damage_max = b.dot_damage_max
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_every = b.dot_every
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("mod_enemy_evolving_scourge_eat", "modifier")
tt.main_script.queue = scripts.mod_enemy_evolving_scourge_eat.queue
tt.main_script.update = scripts.mod_enemy_evolving_scourge_eat.update
tt.explode_fx = "fx_enemy_evolving_scourge_eat"

tt = E:register_t("ps_bullet_enemy_unblinded_priest")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "unblinded_priest_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt = E:register_t("fx_bullet_enemy_unblinded_priest_hit", "fx")
tt.render.sprites[1].name = "unblinded_priest_projectile_hit_fx_idle"
tt = E:register_t("fx_enemy_unblinded_priest_hit_melee", "fx")
tt.render.sprites[1].name = "unblinded_priest_melee_hit_fx"
tt = E:register_t("fx_enemy_unblinded_abomination_hit_melee", "fx")
tt.render.sprites[1].name = "unblinded_abomination_unblinded_abomination_hit_fx_idle"
tt = E:register_t("fx_enemy_unblinded_abomination_eat", "fx")
tt.render.sprites[1].name = "unblinded_abomination_unblinded_abomination_eat_fx"
tt = E:register_t("fx_enemy_armored_nightmare_hit", "fx")
tt.render.sprites[1].name = "armored_nightmare_fx_idle"
tt = E:register_t("fx_enemy_armored_nightmare_death_spawn", "fx")
tt.render.sprites[1].name = "armored_nightmare_explosion_idle"

tt = E:register_t("fx_enemy_crystal_golem_ground_decal", "decal")
E:add_comps(tt, "tween")
tt.render.sprites[1].prefix = "crystal_golem_decal"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = 2
tt.tween.props[1].keys = {{fts(10), 255}, {0.8, 255}, {1, 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt = E:register_t("fx_enemy_evolving_scourge_eat", "fx")
tt.render.sprites[1].name = "evolving_scourge_eat_FX"
tt = E:register_t("fx_bullet_enemy_corrupted_elf_hit", "fx")
tt.render.sprites[1].name = "fx_knife_satyr_hit"
tt.render.sprites[1].offset.y = 5
tt = E:register_t("fx_quickfeet_chicken_hit", "fx")
tt.render.sprites[1].name = "quickfeet_gator_hit_projectile_run"
tt = E:register_t("fx_quickfeet_bone_hit", "fx")
tt.render.sprites[1].name = "quickfeet_gator_attack_hit_run"
tt = E:register_t("fx_ranged_croc_hit", "fx")
tt.render.sprites[1].name = "ranged_croc_hit"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_crocs_egg_spawner_melee_hit", "fx")
tt.render.sprites[1].name = "crokinder_mom_hit"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_crocs_tank_melee_hit", "fx")
tt.render.sprites[1].name = "tank_hit_idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_crocs_tank_spin_hit", "fx")
tt.render.sprites[1].name = "tank_hitspin"
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "tank_hit_idle"
tt = E:register_t("fx_enemy_croc_shaman_hit", "fx")
tt.render.sprites[1].name = "shaman_hit_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_crocs_hydra_melee_hit", "fx")
tt.render.sprites[1].name = "hydra_fx_hit"
tt.render.sprites[1].loop = false
tt = E:register_t("fx_crocs_hydra_heads_transform", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "hydra_death1_headsDef"
tt.render.sprites[1].name = "transform1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {fts(40), 255}, {fts(60), 255}, {fts(72), 0}}
tt = E:register_t("fx_crocs_hydra_heads_death", "fx_crocs_hydra_heads_transform")
tt.render.sprites[1].prefix = "hydra_death_threeheadsDef"
tt.render.sprites[1].name = "death2"
tt.tween.props[1].keys = {{0, 255}, {fts(50), 255}, {fts(70), 255}, {fts(82), 0}}
tt = E:register_t("fx_crocs_boss_melee_hit", "fx")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_dirt_explosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_crocs_boss_melee_hit_1", "fx")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_dirt_explosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].scale = vv(0.6)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_crocs_boss_melee_hit_2", "fx")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_dirt_explosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].scale = vv(0.8)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("decal_crocs_boss_melee_hit", "decal_timed")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_groundcrack_lvl1Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_crocs_boss_melee_hit_2", "decal_timed")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_groundcrack_lvl2Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_crocs_boss_melee_hit_3", "decal_timed")
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "boss_gator_groundcrack_lvl3Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("mod_enemy_unblinded_shackler_shackles", "modifier")
b = balance.enemies.cult_of_the_overseer.unblinded_shackler
E:add_comps(tt, "render")
tt.main_script.update = scripts.mod_enemy_unblinded_shackler_shackles.update
tt.modifier.duration = 1e+99
tt.render.sprites[1].prefix = "unblinded_shackler_tower_mod"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10

tt = E:register_t("mod_enemy_unblinded_shackler_mark", "modifier")
E:add_comps(tt, "mark_flags")
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = 1e+99
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update

tt = E:register_t("mod_stage_10_obelisk_heal", "modifier")
b = balance.specials.stage10_obelisk.heal

E:add_comps(tt, "hps", "render")

tt.modifier.duration = b.heal_duration
tt.modifier.use_mod_offset = false
tt.hps.heal_min = b.heal_min
tt.hps.heal_max = b.heal_max
tt.hps.heal_every = b.heal_every
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_stage_10_obelisk_heal.update
tt.render.sprites[1].prefix = "HealFx1Def"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].size_prefix = {"HealFx1Def", "HealFx1BigDef", "HealFx1BigDef"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "HealFx2Def"
tt.render.sprites[2].name = "Idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].size_prefix = {"HealFx2Def", "HealFx2BigDef", "HealFx2BigDef"}
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "HealFx3Def"
tt.render.sprites[3].name = "Idle"
tt.render.sprites[3].exo = true
tt.render.sprites[3].z = Z_OBJECTS
tt = E:register_t("mod_stage_10_obelisk_teleport", "mod_teleport")
b = balance.specials.stage10_obelisk.teleport
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.nodes_offset = b.nodes_advance
tt.nodeslimit = b.nodes_limit
tt.delay_start = fts(2)
tt.hold_time = 0.34
tt.delay_end = fts(4)
tt.fx_start = "fx_stage_10_obelisk_teleport"
tt.fx_end = "fx_stage_10_obelisk_teleport"
tt.max_times_applied = 1e+99
tt = E:register_t("mod_enemy_stage_11_cult_leader_illusion_chain", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_enemy_stage_11_cult_leader_illusion_chain.update
tt.modifier.duration = 1e+99
tt.modifier.resets_same = true
tt.render.sprites[1].prefix = "mydrias_stuntower_back"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].z = Z_TOWER_BASES + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mydrias_stuntower_front"
tt.render.sprites[2].draw_order = 20
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -10
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(20), 255}}
tt.tween.disabled = true
tt = E:register_t("mod_enemy_stage_11_cult_leader_illusion_shield", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_enemy_stage_11_cult_leader_illusion_shield.insert
tt.main_script.remove = scripts.mod_enemy_stage_11_cult_leader_illusion_shield.remove
tt.main_script.update = scripts.mod_enemy_stage_11_cult_leader_illusion_shield.update
tt.render.sprites[1].prefix = "mydrias_areaskill_status"
tt = E:register_t("mod_enemy_stage_11_cult_leader_illusion_shield_denas", "mod_enemy_stage_11_cult_leader_illusion_shield")
tt.render.sprites[1].prefix = "mydrias_areaskill_status_Denas"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mydrias_areaskill_status_Denas_decal"
tt.render.sprites[2].z = Z_DECALS

tt = E:register_t("boss_gator_vfx_acid_explosion", "fx")
tt.render.sprites[1].prefix = "boss_gator_lvl2_bubbleDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt = E:register_t("boss_gator_vfx_fire_explosion", "fx")
tt.render.sprites[1].prefix = "boss_gator_lvl3_explosionDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_werebeast_boss_cultist_smoke", "fx")
tt.render.sprites[1].name = "werebeast_boss_cultist_smoke_cultist_boss_smoke"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_stage_09_portal_path_spawn_fx", "fx")
tt.render.sprites[1].prefix = "stage_9_portal_path_spawn_FXDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_10_statue_click", "fx")
tt.render.sprites[1].prefix = "ymca_statue_dust"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_stage_10_obelisk_teleport", "fx")
tt.render.sprites[1].prefix = "TeleportFxDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_10_obelisk_stun_explosion", "fx")
tt.render.sprites[1].prefix = "StunFxDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_10_obelisk_stun_explosion_white", "decal_tween")
tt.render.sprites[1].prefix = "StunWhiteDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].z = Z_GUI - 2
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(70)
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{fts(0), vv(70)}}
tt = E:register_t("fx_stage_10_obelisk_stun_circle", "fx")
tt.render.sprites[1].prefix = "StunCircleDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_10_obelisk_teleport_crystal", "decal_tween")
b = balance.specials.stage10_obelisk
tt.render.sprites[1].prefix = "stage10_obelisk_teleport_fx_teleport"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.fx_duration = 1.6
tt.tween.props[1].keys = {{fts(0), 0}, {fts(5), 255}, {tt.fx_duration - fts(7), 255}, {tt.fx_duration, 0}}
tt = E:register_t("fx_stage_10_obelisk_priest_hit", "fx")
tt.render.sprites[1].name = "stage10_obelisk_hit"

tt = E:register_t("fx_stage_11_cult_leader_attack_hit", "fx")
tt.render.sprites[1].name = "mydrias_proyectile_hit"
tt = E:register_t("fx_stage_11_cult_leader_spawn", "fx")

local b = balance.specials.stage11_cult_leader.illusion

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "mydrias_summoncircle_summoncircle_start"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "mydrias_summoncircle_summoncircle_summon"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "mydrias_summoncircle_summoncircle_fadeout"
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "mydrias_summoncircle_summoncircle_summon"
tt.render.sprites[4].z = Z_DECALS
tt.timed.duration = 1e+99
tt.prev_duration = b.spawn_charge_time + 1
tt.scale_timing = b.spawn_charge_time
tt.scale_duration = 1
tt.decal_duration = 2.5
tt.tween.props[1].keys = {{0, 0}, {0.8, 255}, {tt.prev_duration - 0.1, 255}, {tt.prev_duration + 1, 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {tt.scale_timing - 0.1, 0}, {tt.scale_timing, 255}, {tt.scale_timing + tt.scale_duration, 0}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {{0, 0}, {tt.prev_duration - 0.1, 0}, {tt.prev_duration, 255}, {tt.prev_duration + tt.decal_duration - 1, 255}, {tt.prev_duration + tt.decal_duration, 0}}
tt.tween.props[3].sprite_id = 3
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{fts(0), v(1, 1)}, {tt.scale_timing - 0.1, v(1, 1)}, {tt.scale_timing + tt.scale_duration, v(1.5, 1.5)}}
tt.tween.props[4].sprite_id = 2
tt.tween.props[5] = E:clone_c("tween_prop")
tt.tween.props[5].keys = {{0, 0}, {tt.scale_timing - 0.1, 0}, {tt.scale_timing, 255}, {tt.scale_timing + tt.scale_duration + 1, 0}}
tt.tween.props[5].sprite_id = 4
tt = E:register_t("fx_bullet_stage_11_veznan_skill_1", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "stage11_veznan_export_skill1_decal_idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage11_veznan_export_skill1_hit_piso"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].loop = false
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "stage11_veznan_export_skill1_hit_idle"
tt.render.sprites[3].z = Z_BULLET_PARTICLES
tt.render.sprites[3].loop = false
tt.timed.duration = 1e+99
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {4, 0}}
tt.tween.props[1].sprite_id = 1
tt = E:register_t("fx_stage_11_veznan_soldiers_spawn", "fx")
tt.render.sprites[1].name = "stage11_veznan_export_spawn_fire_idle"
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt = E:register_t("fx_stage_11_veznan_soldiers_spawn_top", "fx")
tt.render.sprites[1].name = "stage11_veznan_export_spawn_top_spawn"
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt = E:register_t("fx_stage_11_veznan_spawn", "decal")
tt.render.sprites[1].prefix = "stage11_veznan_export_rayo_spawn"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt = E:register_t("fx_stage_11_veznan_spawn_base", "decal")
tt.render.sprites[1].prefix = "stage11_veznan_export_tierrita_spawn"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt = E:register_t("fx_stage_11_portal_spawn", "fx")
tt.render.sprites[1].prefix = "stage_11_portal_fxDef"
tt.render.sprites[1].name = "Animations"
tt.render.sprites[1].exo = true
tt.render.sprites[1].fps = 30

tt = E:register_t("soldier_stage_10_ymca", "soldier_militia")
b = balance.specials.stage10_ymca

E:add_comps(tt, "reinforcement", "nav_grid", "tween")

tt.health.armor = b.soldier.armor
tt.health.hp_max = b.soldier.hp
tt.health_bar.offset = v(0, 30)
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.random_name_format = nil
tt.info.random_name_count = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_stage_10_ymca.update
tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.range = 72
tt.motion.max_speed = b.soldier.max_speed
tt.regen.cooldown = 1
tt.regen.health = 0
tt.reinforcement.duration = 1e+99
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(1.1)
tt.soldier.melee_slot_offset = v(3, 0)
tt.sound_events.insert = nil
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.unit.level = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt = E:register_t("soldier_stage_10_ymca_indio", "soldier_stage_10_ymca")
tt.render.sprites[1].prefix = "ymca_ymca_indio"
tt.info.portrait = "kr5_info_portraits_soldiers_0020"
tt = E:register_t("soldier_stage_10_ymca_constructor", "soldier_stage_10_ymca")
tt.render.sprites[1].prefix = "ymca_ymca_constructor"
tt.render.sprites[1].anchor = v(0.5, 1)
tt.render.sprites[1].offset.y = 35
tt.info.portrait = "kr5_info_portraits_soldiers_0023"
tt = E:register_t("soldier_stage_10_ymca_biker", "soldier_stage_10_ymca")
tt.render.sprites[1].prefix = "ymca_ymca_biker"
tt.info.portrait = "kr5_info_portraits_soldiers_0022"
tt = E:register_t("soldier_stage_10_ymca_policia", "soldier_stage_10_ymca")
tt.render.sprites[1].prefix = "ymca_ymca_policia"
tt.info.portrait = "kr5_info_portraits_soldiers_0021"
tt = E:register_t("soldier_stage_11_veznan_skill_soldiers", "soldier_militia")
b = balance.specials.stage11_veznan.skill_soldiers.soldier

E:add_comps(tt, "reinforcement", "tween")

tt.health.armor = b.armor
tt.health_bar.offset = v(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.hp_max = b.hp_max
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr5_info_portraits_soldiers_0024"
tt.info.i18n_key = "SOLDIER_STAGE11_VEZNAN_SKILL"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_stage_11_veznan_skill_soldiers.update
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "TowerDemonPitBigGuyBasicAttack"
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.range = b.melee_attack.range
tt.motion.max_speed = b.max_speed
tt.regen.cooldown = 1
tt.regen.health = b.regen_health
tt.reinforcement.duration = 1e+99
tt.render.sprites[1].prefix = "reinforcement_demon_guard"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.soldier.melee_slot_offset = v(3, 0)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.reverse = false
tt.unit.hit_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
tt.spawn_fx = "fx_stage_11_veznan_soldiers_spawn"
tt.spawn_fx_top = "fx_stage_11_veznan_soldiers_spawn_top"
tt.spawn_delay = fts(2)
tt.idle_time = fts(8)
tt.nodes_from_start = b.nodes_from_start

tt = E:register_t("aura_stage_10_obelisk_teleport", "aura")
b = balance.specials.stage10_obelisk.teleport

E:add_comps(tt, "track_damage", "render")

tt.aura.duration = fts(1)
tt.aura.radius = b.aura_radius
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = bor(F_MOD, F_TELEPORT, F_RANGED)
tt.aura.mod = "mod_stage_10_obelisk_teleport"
tt.aura.max_count = b.max_targets
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_stage_10_obelisk_teleport.update
tt.render.sprites[1].prefix = "TeleportDecalDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "decal_in"
tt.render.sprites[1].hidden = true

tt = E:register_t("aura_enemy_stage_11_cult_leader_illusion_shield", "aura")
b = balance.specials.stage11_cult_leader.illusion
E:add_comps(tt, "render", "tween")
tt.aura.mod = "mod_enemy_stage_11_cult_leader_illusion_shield"
tt.aura.mod_denas = "mod_enemy_stage_11_cult_leader_illusion_shield_denas"
tt.aura.radius = b.shield.radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND, F_HERO)
tt.aura.duration = 1e+99
tt.aura.cycle_time = fts(5)
tt.aura.track_source = true
tt.aura.excluded_templates = {"enemy_stage_11_cult_leader_illusion"}
tt.render.sprites[1].prefix = "mydrias_areaskill"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_enemy_stage_11_cult_leader_illusion_shield.update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration - 0.5, 255}, {tt.aura.duration, 0}}

tt = E:register_t("ps_bullet_stage_10_obelisk_priests")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "stage10_obelisk_particle_Idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.emit_area_spread = v(8, 8)
tt.particle_system.scales_y = {1, 1.5}
tt.particle_system.scales_x = {1, 1.5}
tt.particle_system.animation_fps = 15

tt = E:register_t("aura_stage_11_portal", "aura")
b = balance.specials.stage11_cult_leader.illusion
E:add_comps(tt, "render")
tt.aura.mod = "mod_stage_11_portal"
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_AREA)
tt.aura.duration = 1e+99
tt.aura.cycle_time = fts(1)
tt.aura.track_source = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_stage_11_portal", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = 1e+99
tt.modifier.use_mod_offset = false
tt.main_script.insert = scripts.mod_stage_11_portal.insert
tt.fx = "fx_stage_11_portal_spawn"

tt = E:register_t("ps_bullet_stage_11_cult_leader")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mydrias_proyectile_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.anchor = v(0.6, 0.5)
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {0.8, 0.5}
tt.particle_system.emit_area_spread = v(5, 5)
tt = E:register_t("ps_bullet_stage_11_veznan_skill_1")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "stage11_veznan_export_proyectile_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(18), fts(18)}
tt.particle_system.alphas = {200, 0}
tt.particle_system.emission_rate = 15
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {0.8, 0.8}
tt = E:register_t("ps_bullet_boss_corrupted_denas_spawn_entities")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "glearling_trail_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2

tt = E:register_t("aura_enemy_amalgam_death_explosion", "aura")
b = balance.enemies.void_beyond.amalgam.explosion
tt.aura.radius = b.damage_radius
tt.aura.vis_flags = F_AREA
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.cycles = 1
tt.aura.damage_min = b.damage_min
tt.aura.damage_max = b.damage_max
tt.aura.damage_type = b.damage_type
tt.main_script.update = scripts.aura_apply_damage.update

tt = E:register_t("fx_item_veznan_wrath_explosion", "fx")
tt.render.sprites[1].prefix = "veznan_wrath_explosion_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt = E:register_t("fx_item_veznan_wrath_instakill_ground", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "veznan_wrath_instakill_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.timed.runs = 1e+99
tt.tween.props[1].keys = {{0, 255}, {fts(52), 255}, {fts(52) + fts(15), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.remove = true
tt = E:register_t("fx_item_veznan_wrath_instakill_air", "fx")
tt.render.sprites[1].prefix = "veznan_wrath_instakill_voladores_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt = E:register_t("fx_terrain_3_spawner", "fx")
tt.render.sprites[1].name = "spawner_t3_spawnereffect"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_enemy_noxious_horror_melee_hit", "fx")
tt.render.sprites[1].name = "noxious_horror_hit_fx_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_bullet_enemy_noxious_horror_explosion", "fx")
tt.render.sprites[1].name = "noxious_horror_projectile_splash"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt = E:register_t("fx_bullet_enemy_noxious_horror_explosion_flying", "fx")
tt.render.sprites[1].name = "noxious_horror_projectile_splash_flying"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt = E:register_t("fx_bullet_enemy_noxious_horror_hit", "fx")
tt.render.sprites[1].name = "noxious_horror_ranged_attack_hit_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_enemy_hardened_horror_hit", "fx")
tt.render.sprites[1].name = "hardened_horror_hit_vfx_attack_1_hit"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_enemy_blinker_attack", "fx")
b = balance.enemies.void_beyond.blinker.ranged_attack
tt.render.sprites[1].name = "blinker_stun_fx_Idle"
tt.render.sprites[1].loop = true
tt.timed.duration = b.duration
tt.timed.runs = 1e+99
tt = E:register_t("fx_enemy_blinker_attack_glare", "fx_enemy_blinker_attack")
tt.render.sprites[1].name = "blinker_glare_fx_Idle"

tt = E:register_t("fx_stage_15_boss_cult_leader_ray", "fx")
tt.render.sprites[1].prefix = "mutamydrias_rayDef"
tt.render.sprites[1].name = "areaattack"
tt.render.sprites[1].exo = true
tt.render.sprites[1].flip_x = true
tt = E:register_t("fx_stage_16_overseer_tentacle_hit_decal", "fx")
tt.render.sprites[1].prefix = "overseer_fx_overseer_proyectile_explosion"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = true
tt = E:register_t("fx_enemy_specter_hit", "fx")
tt.render.sprites[1].name = "spectre_fx_idle"
tt = E:register_t("fx_enemy_revenant_harvester_hit", "fx")
tt.render.sprites[1].prefix = "harvester_hit_fx"
tt = E:register_t("fx_stage_19_statue_hands_dust_1", "fx")
tt.render.sprites[1].prefix = "navira_hands_dust_01"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_stage_19_statue_hands_dust_2", "fx")
tt.render.sprites[1].prefix = "navira_hands_dust_02"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_stage_19_statue_hands_stones_1", "fx")
tt.render.sprites[1].prefix = "navira_hands_stones_01"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_stage_19_statue_hands_stones_2", "fx")
tt.render.sprites[1].prefix = "navira_hands_stones_02"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_stage_20_arborean_house_hit_1", "fx")
tt.render.sprites[1].prefix = "arborean_house_hit_1"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_stage_20_arborean_house_hit_2", "fx")
tt.render.sprites[1].prefix = "arborean_house_hit_2"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_stage_20_watchtower_explosion", "fx")
tt.render.sprites[1].prefix = "watchtower_arborean_tower_explosion"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_stage_20_arborean_barrack_explosion", "fx")
tt.render.sprites[1].prefix = "arborean_warrior_barraca_hit_1"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_stage_20_arborean_barrack_explosion_2", "fx")
tt.render.sprites[1].prefix = "arborean_warrior_barraca_hit_2"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_stage_22_rocks_paths_fall1", "fx")
tt.render.sprites[1].prefix = "Rocks_Paths1Def"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_22_rocks_paths_fall2", "fx_stage_22_rocks_paths_fall1")
tt.render.sprites[1].prefix = "Rocks_Paths2Def"
tt = E:register_t("fx_stage_22_rocks_paths_fall3", "fx_stage_22_rocks_paths_fall1")
tt.render.sprites[1].prefix = "Rocks_Paths3Def"
tt = E:register_t("fx_stage_22_rocks_paths_fall4", "fx_stage_22_rocks_paths_fall1")
tt.render.sprites[1].prefix = "Rocks_Paths4Def"

-- 似乎是废案，没什么用，留着只是因为代码要能跑
tt = E:register_t("bullet_enemy_blinker", "bullet")
local b = balance.enemies.void_beyond.blinker
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hit_time = fts(0)
tt.image_width = 112.5
-- tt.main_script.update = scripts.bullet_enemy_blinker.update
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].hidden = true
tt.sound_events.insert = "EnemyVoidBlinkerStareCast"
tt.track_target = true
tt.ray_duration = b.ranged_attack.duration
tt = E:register_t("bullet_enemy_blinker_glare", "bullet_enemy_blinker")
tt.render.sprites[1].hidden = true

tt = E:register_t("bullet_tower_stage_13_sunray", "bullet")
local b = balance.specials.towers.stage_13_sunray
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_min = b.basic_attack.damage_min
tt.bullet.damage_max = b.basic_attack.damage_max
tt.bullet.hit_time = fts(2)
tt.bullet.mod = "mod_bullet_tower_stage_13_sunray"
tt.bullet.max_track_distance = 100
tt.hit_fx_only_no_target = true
tt.image_width = 118
tt.main_script.update = scripts.bullet_tower_stage_13_sunray.update
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "SunrayTower_SmallRay"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = true
tt.ray_duration = b.basic_attack.duration
tt = E:register_t("bullet_tower_stage_13_sunray_special", "bullet")

local b = balance.specials.towers.stage_13_sunray.special_attack

tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.image_width = 157.5
tt.main_script.update = scripts.bullet_tower_stage_13_sunray_special.update
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "SunrayTower_BigRay"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 1
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = true
tt.ray_duration = b.duration

tt = E:register_t("ps_terrain_3_spores_1")

E:add_comps(tt, "pos", "particle_system")

tt.pos = v(512, -20)
tt.particle_system.alphas = {200, 150, 200, 0}
tt.particle_system.emission_rate = 1.5
tt.particle_system.emit_area_spread = v(1300, 10)
tt.particle_system.emit_direction = math.pi * 3 / 8
tt.particle_system.emit_speed = {15, 25}
tt.particle_system.emit_spread = math.pi / 16
tt.particle_system.particle_lifetime = {35, 45}
tt.particle_system.scale_var = {0.6, 0.9}
tt.particle_system.ts_offset = -40
tt.particle_system.z = Z_OBJECTS_SKY
tt.particle_system.name = "T3_12_spore"
tt = E:register_t("ps_terrain_3_spores_2", "ps_terrain_3_spores_1")
tt.particle_system.emit_direction = math.pi * 5 / 8
tt = E:register_t("ps_bullet_enemy_noxious_horror")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "noxious_horror_projectile_vfx_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = v(0, 0)
tt.particle_system.emit_rotation_spread = math.pi * 2

tt = E:register_t("aura_glare_source", "aura")
b = balance.enemies.void_beyond.glare

E:add_comps(tt, "render")

tt.aura.mod = "mod_glare"
tt.aura.cycle_time = 0.2
tt.aura.duration = 1e+99
tt.aura.radius = b.range
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
-- tt.render.sprites[1].name = "rally_circle_full"
tt.render.sprites[1].name = "rally_circle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(1)

tt = E:register_t("aura_enemy_noxious_horror_glare", "aura")
b = balance.enemies.void_beyond.noxious_horror.glare.aura
E:add_comps(tt, "render", "tween")
tt.aura.mod = "mod_enemy_noxious_horror_poison"
tt.aura.radius = b.radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.cycle_time = fts(5)
tt.aura.duration = 1e+99
tt.aura.track_source = true
tt.render.sprites[1].prefix = "noxious_horror_glare_aura"
tt.render.sprites[1].name = "on"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = v(0.5, 0.75)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("bullet_vile_spawner_spawn", "bomb")
tt.bullet.flight_time = fts(30)
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop = nil
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "enemy_lesser_eye"
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "vile_spawner_projectile"
tt.render.sprites[1].anchor = v(0.6, 0.4)
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.main_script.update = scripts.bullet_vile_spawner_spawn.update
tt.bullet_particle = "bullet_vile_spawner_spawn_particle"
tt = E:register_t("bullet_vile_spawner_spawn_particle", "bomb")
tt.bullet.flight_time = fts(30)
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.pop = nil
tt.bullet.rotation_speed = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "vile_spawner_projectile_fx_idle"
tt.render.sprites[1].z = Z_BULLETS - 1
tt.render.sprites[1].anchor = v(0.55, 0.45)
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.main_script.update = scripts.bullet_vile_spawner_spawn_particle.update
tt = E:register_t("bullet_enemy_noxious_horror", "bomb")

local b = balance.enemies.void_beyond.noxious_horror.ranged_attack

tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.radius
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.hit_decal_flying = "fx_bullet_enemy_noxious_horror_explosion_flying"
tt.bullet.hit_decal_ground = "fx_bullet_enemy_noxious_horror_explosion"
tt.bullet.pop = {"pop_forest_keeper"}
tt.bullet.pop_chance = 0.2
tt.bullet.particles_name = "ps_bullet_enemy_noxious_horror"
tt.bullet.align_with_trajectory = true
tt.bullet.mod = "mod_enemy_noxious_horror_poison"
tt.vis_flags = bor(F_AREA)
tt.vis_bans = bor(F_FLYING, F_ENEMY)
tt.main_script.insert = scripts.bullet_enemy_noxious_horror.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].prefix = "noxious_horror_projectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "EnemyNoxiousHorrorBasicAttackCast"
tt.sound_events.hit = "EnemyNoxiousHorrorBasicAttackImpact"

tt = E:register_t("mod_enemy_noxious_horror_poison", "mod_poison")
b = balance.enemies.void_beyond.noxious_horror.poison
tt.dps.damage_every = b.every
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.kill = true
tt.modifier.duration = b.duration
tt.render.sprites[1].prefix = "noxious_horror_ranged_attack_modifier"
tt.render.sprites[1].size_names = {"idle", "idle", "idle"}
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.main_script.insert = scripts.mod_enemy_noxious_horror_poison.insert
tt.start_fx = "fx_bullet_enemy_noxious_horror_hit"
tt = E:register_t("mod_bullet_tower_stage_13_sunray", "modifier")

AC(tt, "render", "dps")

b = balance.specials.towers.stage_13_sunray
tt.dps.damage_min = b.basic_attack.damage_min
tt.dps.damage_max = b.basic_attack.damage_max
tt.dps.damage_type = bor(DAMAGE_TRUE, DAMAGE_ONE_SHIELD_HIT)
tt.dps.damage_every = b.basic_attack.damage_every
tt.dps.pop = {"pop_zap_arcane"}
tt.dps.pop_conds = DR_KILL
tt.main_script.update = scripts.mod_sunray.update
tt.modifier.duration = b.basic_attack.duration
tt.modifier.allows_duplicates = true
tt.modifier.use_mod_offset = true
tt.render.sprites[1].prefix = "sunraytower_hitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 2
tt.render.sprites[1].base_offset = v(0, 10)

tt = E:register_t("mod_glare", "modifier")
E:add_comps(tt, "hps", "render", "tween")
b = balance.enemies.void_beyond.glare
tt.modifier.duration = b.extra_duration
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = b.regen_every
tt.main_script.insert = scripts.mod_glare.insert
tt.main_script.update = scripts.mod_glare.update
tt.main_script.remove = scripts.mod_glare.remove
tt.render.sprites[1].name = "turtle_shaman_HealFX_a_Idle_1"
tt.render.sprites[1].loop = true
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "turtle_shaman_HealFX_b_Idle_1"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].exclude_mod_offset = true
tt.render.sprites[2].alpha = 0
tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 255}, {fts(10), 0}}
tt.tween.props[2].sprite_id = 2
tt.tween.disabled = true
tt.tween.reverse = true
tt.tween.remove = false

tt = E:register_t("decal_tower_stage_13_sunray", "decal_tween")
tt.render.sprites[1].name = "sunraytower_decal1_Asst_SunrayTower_Decal1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "sunraytower_decal2_Asst_sunraytower_decal2"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].offset = v(0, 10)
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(20), 255}, {fts(40), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {fts(10), 255}, {fts(20), 0}}
tt.tween.props[2].sprite_id = 2
tt.tween.remove = true

tt = E:register_t("aura_tower_stage_13_sunray_special", "aura")
E:add_comps(tt, "render")
local b = balance.specials.towers.stage_13_sunray.special_attack
tt.aura.duration = 1e+99
tt.aura.radius = b.radius
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_AREA)
tt.aura.damage_type = b.damage_type
tt.aura.cycle_time = b.damage_every
tt.aura.mod = "mod_tower_stage_13_sunray_special"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].prefix = "sunraytower_hitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS + 2
tt.render.sprites[1].offset = v(0, 5)
tt.render.sprites[1].scale = vv(1.25)

tt = E:register_t("aura_controller_stage_14_amalgam", "aura")
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.25
tt.aura.radius = 170
tt.aura.allowed_templates = {"enemy_glareling"}
tt.main_script.update = scripts.aura_controller_stage_14_amalgam.update

tt = E:register_t("aura_stage_14_prevent_polymorph", "aura")
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.25
tt.aura.radius = 100
tt.aura.allowed_templates = {"enemy_glareling"}
tt.main_script.update = scripts.aura_stage_14_prevent_polymorph.update

tt = E:register_t("aura_stage_15_cult_leader_tower_stun", "aura")
b = balance.specials.stage15_cult_leader_tower
E:add_comps(tt, "render", "tween")
tt.aura.mod = "mod_stage_15_cult_leader_tower_stun"
tt.aura.radius = b.aura_radius
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.vis_flags = band(F_RANGED, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.aura.duration = b.aura_duration
tt.aura.use_mod_offset = false
tt.render.sprites[1].prefix = "mutamydrias_fx_Mutamydrias_Stuncircle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "mutamydrias_fx_Mutamydrias_Stuncircle_Eye"
tt.render.sprites[2].name = "start"
tt.render.sprites[2].loop = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].offset = v(0, 13)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = v(22, 0)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = v(0, -13)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].offset = v(-22, 0)
tt.decal_on_grab = "decal_stage_15_tentacle_spawn"
tt.decal_on_leave = "decal_stage_15_tentacle_stun_out"
tt.decal_on_activate = "decal_stage_15_tentacle_stun_activate"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_stage_15_cult_leader_tower_stun.update
tt.time_before_stun = b.aura_time_before_stun
tt.duration = 6
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.duration", 255}}
tt.tween.props[1].sprite_id = 1

for i = 2, 5 do
	tt.eye_start = 2 + (i - 3)
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].sprite_id = i
	tt.tween.props[i].name = "alpha"
	tt.tween.props[i].keys = {{0, 0}, {tt.eye_start - 0.5, 0}, {tt.eye_start, 255}, {"this.duration", 255}}
end

tt.sound_pre = "Stage15MydriasTentacleCircleCounter"
tt.sound_grab = "Stage15MydriasTentacleCircle"

tt = E:register_t("mod_stage_15_cult_leader_tower_stun", "mod_stun")
E:add_comps(tt, "render")
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mutamydrias_fx_Mutamydrias_Tentacle"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.modifier.animation_phases = true
tt.modifier.use_mod_offset = false
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_ENEMY)
tt.main_script.remove = scripts.mod_stage_15_cult_leader_tower_stun.remove

tt = E:register_t("decal_enemy_amalgam_hit", "decal_scripted")
tt.render.sprites[1].name = "Amalgam_Attack1_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_enemy_amalgam_hit.update
tt.spike_decals = {"decal_enemy_amalgam_hit_1", "decal_enemy_amalgam_hit_2"}
tt.decal_spawn_range = 50
tt.distance_between = 20

tt = E:register_t("decal_enemy_amalgam_hit_1", "decal_timed")
tt.render.sprites[1].name = "Amalgam_Attack1_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("decal_enemy_amalgam_hit_2", "decal_enemy_amalgam_hit_1")
tt.render.sprites[1].name = "Amalgam_Attack2_run"

tt = E:register_t("decal_enemy_amalgam_death_explosion", "decal_enemy_amalgam_hit")
E:add_comps(tt, "tween")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "Amalgam_Death_Decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.distance_between = 25
tt.tween.props[1].keys = {{0, 255}, {fts(34), 255}, {fts(40), 0}}
tt.tween.props[1].loop = false
tt.tween.remove = true

tt = E:register_t("fx_soldier_reinforcement_stage_15_denas_hit", "fx")
tt.render.sprites[1].name = "denas_hit_fx_Idle"
tt = E:register_t("fx_soldier_reinforcement_stage_15_denas_floor", "decal_timed")
tt.render.sprites[1].name = "denas_decal_Idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "denas_explosion_fx_idle"
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].loop = false

tt = E:register_t("soldier_reinforcement_stage_15_denas", "soldier_militia")
E:add_comps(tt, "melee", "nav_grid", "reinforcement", "tween")
b = balance.specials.stage15_denas
tt.health_bar.offset = v(0, 50)
tt.health.armor = b.armor
tt.health.hp_max = b.hp_max
tt.info.i18n_key = "SOLDIER_STAGE_15_DENAS"
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_soldiers_0037" -- TODO: 我暂时不知道迪纳斯是哪个头像
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.random_name_format = nil
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "denas_hero"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
tt.render.sprites[1].hidden = true
tt.render.sprites[1].angles.walk = {"walk"}
tt.sound_events.insert = "Stage15ReinforcementDenasSummon"
tt.sound_events.change_rally_point = tt.sound_events.insert
tt.unit.hit_offset = v(0, 16)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.fade_time_after_death = tt.health.dead_lifetime
tt.soldier.melee_slot_offset = v(20, 0)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement_stage_15_denas.update
tt.regen.cooldown = 1
tt.idle_flip.last_animation = "idle_a"
tt.idle_flip.chance = 0
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.disabled = true
tt.spawn_decal = "decal_soldier_reinforcement_stage_15_denas_spawn"
tt.floor_decal = "decal_soldier_reinforcement_stage_15_denas_floor"
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].sound = "CommonNoSwordAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(8)
}
tt.melee.attacks[1].damage_min = b.damage_min
tt.melee.attacks[1].damage_max = b.damage_max
tt.melee.attacks[1].damage_type = b.damage_type
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_stage_15_denas_hit"
tt.melee.attacks[1].hit_offset = v(30, 20)
tt.melee.attacks[1].animation = "attack_a"
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound = "Stage15ReinforcementDenasBasicAttack1"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_b"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].shared_cooldown = false
tt.melee.attacks[2].cooldown = 0
tt.melee.attacks[1].sound = "Stage15ReinforcementDenasBasicAttack2"
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].animation = "attack_c"
tt.melee.attacks[3].damage_min = b.damage_special_min
tt.melee.attacks[3].damage_max = b.damage_special_max
tt.melee.attacks[3].hit_time = fts(18)
tt.melee.attacks[3].shared_cooldown = false
tt.melee.attacks[3].cooldown = b.attack_cooldown_special
tt.melee.attacks[3].hit_fx = "fx_soldier_reinforcement_stage_15_denas_floor"
tt.melee.attacks[3].hit_offset = v(tt.soldier.melee_slot_offset.x, 0)
tt.melee.attacks[3].sound = "Stage15ReinforcementDenasSpecialAttack"
tt.melee.range = b.range
tt.melee.cooldown = b.attack_cooldown
tt.melee.arrived_slot_animation = "idle_b"
tt.reinforcement.duration = b.duration
tt.reinforcement.fade = nil
tt.reinforcement.fade_out = nil
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.power_cooldown = b.cooldown
tt.spawn_stun_radius = b.spawn_stun_radius
tt.spawn_stun_mod = "mod_soldier_reinforcement_stage_15_denas_spawn_stun"
tt.spawn_vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.spawn_vis_flags = bor(F_AREA)
tt.spawn_sfx = "Stage15ReinforcementDenasSpawn"
tt.timeout_controller = "controller_soldier_reinforcement_stage_15_denas_timeout"

tt = E:register_t("controller_soldier_reinforcement_stage_15_denas_timeout")
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.controller_soldier_reinforcement_stage_15_denas_timeout.update

tt = E:register_t("power_denas_control", "power_reinforcements_control")
tt.main_script.insert = scripts.power_stage_15_denas_control.insert
tt.denas_t = "soldier_reinforcement_stage_15_denas"

function tt.power_cooldown_fn()
	return E:get_template("soldier_reinforcement_stage_15_denas").power_cooldown
end

tt = E:register_t("controller_tower_swap_overseer", "controller_tower_swap")
tt.delay = 0.25
tt.delay_empty = 0.25
tt.fx_out = "decal_tower_swap_fx_in"
tt.fx_in = "decal_tower_swap_fx_in"
tt.fx_spawn_delay = 0
tt.fx_in_delay = 0
tt.fx_delay_between = fts(14)
tt.swap_sound = "Stage16OverseerTeleport"

tt = E:register_t("decal_tower_swap_fx_in", "decal_timed")
tt.render.sprites[1].name = "overseer_fx_overseer_teleportfx_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[1].offset = v(0, 10)
tt.timed.duration = fts(20)

tt = E:register_t("ps_bullet_stage_16_overseer_tentacle_spawn")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "overseer_fx_overseer_proyectile_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 15
tt.particle_system.emit_rotation_spread = math.pi / 2
tt.particle_system.z = Z_BULLET_PARTICLES

tt = E:register_t("hero_muyrn_treewalk_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.animated = true
tt.particle_system.animation_fps = 15
tt.particle_system.name = "hero_nyru_walk2_roots_particle"
tt.particle_system.loop = false
tt.particle_system.emit_duration = nil
tt.particle_system.emission_rate = 10
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
tt.particle_system.emit_area_spread = v(0, 5)

tt = E:register_t("ps_hero_muyrn_verdant_blast_bolt_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_nyru_verdant_blast_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 60
tt.particle_system.emit_rotation_spread = math.pi * 2

tt = E:register_t("fx_hero_muyrn_faery_dust", "fx")
tt.render.sprites[1].name = "hero_nyru_fairy_dust_FX"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("fx_hero_muyrn_sentinel_wisps_attack", "fx")
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_attack_attack"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt = E:register_t("hero_muyrn_sentinel_wisps_hit_fx", "fx")
tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_hit"

tt = E:register_t("decal_hero_muyrn_root_defender_root_1", "decal_scripted")
tt.render.sprites[1].prefix = "hero_nyru_root_defender_root1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.hero_muyrn_root_defender_root_decal.update
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)
tt = E:register_t("decal_hero_muyrn_root_defender_root_2", "decal_hero_muyrn_root_defender_root_1")
tt.render.sprites[1].prefix = "hero_nyru_root_defender_root2"
tt = E:register_t("decal_hero_muyrn_root_defender_root_3", "decal_hero_muyrn_root_defender_root_1")
tt.render.sprites[1].prefix = "hero_nyru_root_defender_root3"
tt = E:register_t("decal_hero_muyrn_verdant_blast_hit", "decal")
tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion_decal"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hide_after_runs = 1

tt = E:register_t("fx_bullet_tower_stage_17_weirdwood", "fx")
tt.render.sprites[1].prefix = "tower_tree_projectile_explosionDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
-- tt.render.sprites[1].offset = v(0, -20)
tt.render.sprites[1].offset = v(0, 20)
tt = E:register_t("fx_tower_stage_17_weirdwood_leafless", "fx")
tt.render.sprites[1].prefix = "tower_tree_leaflessFXDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -50)
tt = E:register_t("fx_tower_stage_17_weirdwood_transformation", "fx")
tt.render.sprites[1].prefix = "tower_tree_transformationFXDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_bullet_enemy_deathwood", "fx")
tt.render.sprites[1].prefix = "deathwood_spirit_ball"
tt.render.sprites[1].name = "hit"
tt = E:register_t("fx_enemy_deathwood_hit", "fx")
tt.render.sprites[1].prefix = "deathwood_fx"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_tower_stage_18_elven_barrrack_transformation", "fx")
tt.render.sprites[1].prefix = "elven_barracks_statechange"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_tower_stage_18_elven_barrrack_state_change", "fx")
tt.render.sprites[1].prefix = "elven_barracks_specterattack"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_bullet_enemy_revenant_soulcaller_tower", "fx")
tt.render.sprites[1].prefix = "revenant_soulcaller_proy"
tt.render.sprites[1].name = "hit"
tt = E:register_t("fx_bullet_enemy_revenant_soulcaller_tower_stun", "fx")
tt.render.sprites[1].prefix = "revenant_soulcaller_transform"
tt.render.sprites[1].name = "idle"

tt = E:register_t("tower_stage_17_weirdwood", "tower_KR5")
b = balance.specials.towers.stage_17_weirdwood
E:add_comps(tt, "attacks", "vis", "corruption_kr5")
tt.tower.type = "weirdwood"
tt.tower.level = 1
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.can_be_sold = false
tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_6
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.info.portrait = "kr5_portraits_towers_0021"
tt.main_script.update = scripts.tower_stage_17_weirdwood.update
tt.attacks.range = b.basic_attack.max_range
tt.attacks.load_time = fts(54)
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "attack_shoot"
tt.attacks.list[1].bullet = "bullet_tower_stage_17_weirdwood"
tt.attacks.list[1].cooldown = b.basic_attack.cooldown
tt.attacks.list[1].shoot_time = fts(1.5)
tt.attacks.list[1].bullet_start_offset = v(-38, 94)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.attacks.list[1].node_prediction = true
tt.attacks.list[1].min_range = b.basic_attack.min_range
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_artillery_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "tower_treeDef"
tt.render.sprites[2].name = "a_idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(0, 5)
tt.tower_sid = 2
tt.sound_events.insert = nil
tt.corruption_kr5.corruption_phases = b.corruption_phases
tt.corruption_kr5.limit = b.corruption_limit
tt.corruption_kr5.on_corrupt = scripts.tower_stage_17_weirdwood.on_corrupt
tt.corruption_kr5.spawn = "enemy_deathwood"
tt.corruption_kr5.spawn_path = 2
tt.leafless_fx = "fx_tower_stage_17_weirdwood_leafless"
tt.transformation_fx = "fx_tower_stage_17_weirdwood_transformation"
tt.holder_cost = b.holder_cost
tt.editor.props = {{"corruption_kr5.spawn_path", PT_NUMBER}}
tt.sound_corruption = "TowerWeirdwoodCorruption"
tt.sound_transform = "TowerWeirdwoodTransform"

tt = E:register_t("tower_stage_18_elven_barrack", "tower_KR5")
b = balance.specials.towers.stage_18_elven_barrack
E:add_comps(tt, "vis", "barrack", "corruption_kr5")
tt.tower.type = "tower_stage_18_elven_barrack"
tt.tower.level = 1
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_6
tt.tower.menu_offset = v(0, 22)
tt.tower.price = 0
tt.info.portrait = "kr5_portraits_towers_0022"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.main_script.update = scripts.tower_stage_18_elven_barrack.update
tt.main_script.remove = scripts.tower_stage_18_elven_barrack.remove
function tt.main_script.insert(this, store)
	if this.render.sprites[1].flip_x then
		this.barrack.respawn_offset.x = this.barrack.respawn_offset.x * -1
	end

	return scripts.tower_barrack.insert(this, store)
end
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].offset = v(0, 8)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elven_barracks_tower1"
tt.render.sprites[2].sort_y_offset = 10
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "elven_barracks_tower_door"
tt.render.sprites[3].name = "close"
tt.render.sprites[3].loop = false
tt.render.sprites[3].sort_y_offset = 10
tt.render.door_sid = 3
tt.barrack.soldier_type = "soldier_tower_stage_18_elven_barrack"
tt.barrack.rally_range = b.rally_range
tt.barrack.respawn_offset = v(0, -8)
tt.barrack.max_soldiers = 3
tt.barrack.current_soldiers = 0
tt.sound_events.change_rally_point = "TowerElvenBarrackUnitTaunt"
tt.corruption_kr5.corruption_phases = b.corruption_phases
tt.corruption_kr5.limit = b.corruption_limit
tt.corruption_kr5.on_corrupt = scripts.tower_stage_18_elven_barrack.on_corrupt
tt.corruption_kr5.spawn = "spawner_stage_18_elven_barrack"
tt.current_phase = 1
tt.phases = {"1", "2", "3"}
tt.state_change_fx = "fx_tower_stage_18_elven_barrrack_state_change"
tt.transformation_fx = "fx_tower_stage_18_elven_barrrack_transformation"
tt.soldiers_bought = 0

tt = E:register_t("soldier_tower_stage_18_elven_barrack", "soldier_militia")
E:add_comps(tt, "nav_grid")
b = balance.specials.towers.stage_18_elven_barrack.soldier
tt.info.portrait = "kr5_info_portraits_soldiers_0037"
tt.info.random_name_count = 6
tt.info.random_name_format = "SOLDIER_TOWER_ELVEN_BARRACK_%i_NAME"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = scripts.soldier_barrack.update
tt.render.sprites[1].prefix = "elven_barracks_elven_soldier"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles.walk = {"walk"}
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, 13)
tt.unit.price = 75 --b.price
tt.unit.fade_time_after_death = 4
tt.health.armor = b.armor
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 33)
tt.health.dead_lifetime = b.dead_lifetime
tt.regen.health = b.regen_hp
tt.motion.max_speed = b.speed
tt.melee.range = b.basic_attack.range
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].hit_time = fts(12)
tt.soldier.melee_slot_spread = v(-8, -8)
tt.sound_events.insert = "TowerElvenBarrackUnitTaunt"
tt.sound_events.death = "TowerPaladinCovenantUnitDeath"
tt.ui.click_rect = r(-13, -2, 26, 28)

tt = E:register_t("spawner_stage_18_elven_barrack", "decal_scripted")
E:add_comps(tt, "tween", "corruption_kr5")
b = balance.specials.towers.stage_18_elven_barrack
tt.main_script.update = scripts.spawner_stage_18_elven_barrack.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_0006"
tt.render.sprites[1].offset = v(0, 8)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elven_barracks_tower4_base_0002"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "elven_barracks_tower4_top_0002"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "elven_barracks_tower4_detail_0002"
tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[5].name = "elven_barracks_tower4_base_0001"
tt.render.sprites[5].alpha = 0
tt.render.sprites[6] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[6].name = "elven_barracks_tower4_top_0001"
tt.render.sprites[6].alpha = 0
tt.render.sprites[7] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[7].name = "elven_barracks_tower4_detail_0001"
tt.render.sprites[7].alpha = 0

local floating_sprites = {3, 4, 6, 7}
local i = 1

for k, sid in pairs(floating_sprites) do
	tt.tween.props[i] = E:clone_c("tween_prop")
	tt.tween.props[i].name = "offset"

	local start_offset = tt.render.sprites[sid].offset
	local end_offset = v(start_offset.x, start_offset.y + 2.5)

	tt.tween.props[i].keys = {{0, start_offset}, {1.5, end_offset}, {3, start_offset}}
	tt.tween.props[i].sprite_id = sid
	tt.tween.props[i].loop = true
	tt.tween.props[i].interp = "sine"
	i = i + 1
end

tt.tween.remove = false
tt.corruption_kr5.on_corrupt = scripts.spawner_stage_18_elven_barrack.on_corrupt
tt.corruption_kr5.spawn = "enemy_animated_armor"
tt.corruption_kr5.enabled = false
tt.spawn_cd = b.spawn_cooldown

tt = E:register_t("bullet_tower_stage_17_weirdwood", "bomb")
b = balance.specials.towers.stage_17_weirdwood.basic_attack
tt.bullet.flight_time = fts(28)
tt.bullet.hit_fx = "fx_bullet_tower_stage_17_weirdwood"
tt.bullet.hit_decal = "decal_bullet_tower_stage_17_weirdwood"
tt.bullet.pop = {"pop_artillery"}
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_radius = b.damage_radius
tt.bullet.pop = {"pop_entwood"}
tt.render.sprites[1].name = "tower_tree_projectile_asst_projectile"
tt.sound_events.insert = "TowerWeirdwoodBasicAttackCast"
tt.sound_events.hit = "TowerWeirdwoodBasicAttackHit"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = E:register_t("bullet_enemy_corrupted_elf", "arrow_45degrees")
b = balance.enemies.undying_hatred.corrupted_elf
tt.render.sprites[1].name = "corrupted_ranger_arrow"
tt.render.sprites[1].animated = false
tt.bullet.asymmetrical = true
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.flight_time = fts(10)
tt.bullet.g = -0.7 / (fts(1) * fts(1))
tt.bullet.miss_decal = "corrupted_ranger_arrow_miss"
tt.bullet.pop = nil
tt.bullet.predict_target_pos = false
tt.bullet.particles_name = "ps_bullet_enemy_corrupted_elf"
tt = E:register_t("bullet_enemy_deathwood", "bomb")
b = balance.enemies.undying_hatred.deathwood.ranged_attack
tt.main_script.update = scripts.enemy_bomb.update
tt.bullet.flight_time = fts(28)
tt.bullet.hit_fx = "fx_bullet_enemy_deathwood"
tt.bullet.pop = {"pop_artillery"}
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_radius = b.damage_radius
tt.bullet.pop = {"pop_entwood"}
tt.bullet.align_with_trajectory = true
tt.render.sprites[1].prefix = "deathwood_ball_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLET_PARTICLES
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "deathwood_spirit_ball"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.sound_events.insert = "EnemyDeathwoodRangedAttackCast"
tt.sound_events.hit = "EnemyDeathwoodRangedAttackImpact"
tt.sound_events.hit_water = "RTWaterExplosion"
tt = E:register_t("bullet_enemy_revenant_soulcaller", "bolt_enemy")

local b = balance.enemies.undying_hatred.revenant_soulcaller

tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "revenant_soulcaller_proy"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.5
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.max_speed = 360
tt.bullet.hit_fx = "fx_bullet_enemy_revenant_soulcaller_tower_stun"
tt.bullet.particles_name = "ps_bullet_enemy_revenant_soulcaller"
tt.bullet.damage_type = b.ranged_attack.damage_type
tt.bullet.align_with_trajectory = true
tt.sound_events.insert = "EnemyRevenantSoulcallerAttackCast"
tt = E:register_t("bullet_enemy_revenant_soulcaller_tower_stun", "bullet_enemy_revenant_soulcaller")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = "fx_bullet_enemy_revenant_soulcaller_tower_stun"
tt.bullet.hit_mod = "mod_enemy_revenant_soulcaller_branches"
tt.main_script.update = scripts.bullet_enemy_revenant_soulcaller_tower_stun.update
tt = E:register_t("bullet_stage_18_eridan_arrow", "arrow_45degrees")
b = balance.specials.stage18_eridan.ranged_attack
tt.render.sprites[1].name = "eridan_s18_arrow"
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.bullet.fixed_height = 50
tt.bullet.miss_decal = "eridan_s18_arrow_miss"
tt.bullet.particles_name = "ps_bullet_stage_18_eridan_arrow"
tt = E:register_t("bullet_stage_19_navira_fire_ball_ray", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(24)
tt.bullet.mod = "mod_bullet_stage_19_navira_fire_ball_ray_stun"
tt.hit_fx_only_no_target = true
tt.image_width = 186
tt.main_script.update = scripts.bullet_stage_19_navira_fire_ball_ray.update
tt.render.sprites[1].anchor = v(0.45, 0.5)
tt.render.sprites[1].prefix = "navira_soulray"
tt.render.sprites[1].loop = false

tt = E:register_t("decal_bullet_tower_stage_17_weirdwood", "decal_tween")
tt.render.sprites[1].name = "tower_tree_explosion_decal_asst_explosion_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
tt.tween.remove = true

tt = E:register_t("ps_bullet_enemy_corrupted_elf")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "corrupted_ranger_arrow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt = E:register_t("ps_bullet_enemy_revenant_soulcaller")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "revenant_soulcaller_proy_copy_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {1, 0.75}
tt = E:register_t("ps_bullet_stage_18_eridan_arrow")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "eridan_s18_arrow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(11), fts(11)}
tt.particle_system.emission_rate = 100
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {1, 0.75}

tt = E:register_t("ps_enemy_specter_chase_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "spectre_specter_rush_particle_rush_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(29), fts(29)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 16)
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.scales_x = {0.9, 1.1}
tt = E:register_t("ps_bullet_crocs_hydra_tower_debuff")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hydra_projectile_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 15
tt.particle_system.animation_fps = 30
tt.particle_system.emit_area_spread = v(10, 0)
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_BULLET_PARTICLES

tt = E:register_t("aura_enemy_dust_cryptid", "aura")
b = balance.enemies.undying_hatred.dust_cryptid
tt.aura.mod = "mod_enemy_dust_cryptid"
tt.aura.radius = b.dust_radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.cycle_time = 0.2
tt.aura.duration = b.dust_duration
tt.aura.track_source = false
tt.main_script.insert = scripts.aura_enemy_dust_cryptid.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.main_script.remove = scripts.aura_enemy_dust_cryptid.remove
tt.decal_t = "decal_enemy_dust_cryptid_dust"

tt = E:register_t("decal_enemy_dust_cryptid_dust", "decal_tween")
tt.range_factor = 1
tt.render.sprites[1].prefix = "dust_cryptid_dust_fx"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECT
tt.render.sprites[1].loop = true
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].fps = 30
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].loop = false
tt.tween.remove = false

tt = E:register_t("mod_enemy_dust_cryptid", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = 0.25
tt.main_script.insert = scripts.mod_enemy_dust_cryptid.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_enemy_dust_cryptid.remove
tt.render.sprites[1].prefix = "dust_cryptid_modifier"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true

tt = E:register_t("mod_enemy_revenant_soulcaller_branches", "modifier")
b = balance.enemies.undying_hatred.revenant_soulcaller.tower_stun
E:add_comps(tt, "render")
tt.main_script.update = scripts.mod_enemy_revenant_soulcaller_branches.update
tt.modifier.duration = b.duration
tt.render.sprites[1].prefix = "revenant_soulcaller_stuntower"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "revenant_soulcaller_stuntower"
tt.render.sprites[2].animated = true
tt.render.sprites[2].draw_order = 20
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = 15
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = v(0, 20)
tt.sound_events.insert = "EnemyRevenantSoulcallerBlockTowerIn"
tt.sound_events.remove = "EnemyRevenantSoulcallerBlockTowerOut"

tt = E:register_t("mod_enemy_revenant_harvester_mark", "modifier")
E:add_comps(tt, "mark_flags")
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = -1
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update

tt = E:register_t("mod_enemy_revenant_soulcaller_mark", "modifier")
E:add_comps(tt, "mark_flags")
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = b.duration
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update

tt = E:register_t("mod_stage_18_eridan_stun", "mod_stun")
tt.modifier.duration = 1e+99
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt.render.sprites[1].hidden = true

tt = E:register_t("mod_bullet_stage_19_navira_fire_ball_ray_stun", "modifier")
b = balance.enemies.undying_hatred.boss_navira
E:add_comps(tt, "render")
tt.main_script.update = scripts.mod_bullet_stage_19_navira_fire_ball_ray_stun.update
tt.modifier.duration = b.fire_balls.stun_duration
tt.render.sprites[1].prefix = "navira_towerstun"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "Stage19NaviraFireballHit"

tt = E:register_t("mod_bullet_stage_19_navira_heal", "modifier")
E:add_comps(tt, "render")
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 3
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "navira_heal_fx"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].offset = v(0, 90)

tt = E:register_t("tower_stage_20_arborean_oldtree", "tower_KR5")
b = balance.specials.towers.stage_20_arborean_oldtree

E:add_comps(tt, "attacks", "user_selection")

tt.tower.type = "arborean_oldtree"
tt.tower.level = 1
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = IS_CONSOLE
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.tower.menu_offset = v(0, 30)
tt.info.fn = scripts.tower_stage_20_arborean_oldtree.get_info
tt.info.portrait = "kr5_portraits_towers_0028"
tt.info.desc = "TOWER_STAGE_20_ARBOREAN_OLDTREE_DESCRIPTION"
tt.main_script.update = scripts.tower_stage_20_arborean_oldtree.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "arborean_oldtree_decal_decal"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "arborean_treeDef"
tt.render.sprites[2].name = "idle1"
tt.render.sprites[2].exo = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "arborean_oldDef"
tt.render.sprites[3].name = "idle1"
tt.render.sprites[3].exo = true
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].price = b.price
tt.attacks.list[1].price_iron = b.price_iron
tt.attacks.list[1].cast_time = fts(60)
tt.attacks.list[1].bullet = "bullet_stage_20_arborean_oldtree"
tt.attacks.list[1].path_index = b.path_index
tt.attacks.list[1].node_index = b.node_index
tt.attacks.list[1].path_index_iron = b.path_index_iron
tt.attacks.list[1].node_index_iron = b.node_index_iron
tt.attacks.list[1].cooldown = b.cooldown
tt.attacks.list[1].entity = "stage_20_arborean_oldtree_tree"
tt.user_selection.ignore_point = true
tt.ui.has_nav_mesh = true
tt.sound_wakeup = "Stage20TreeWakeup"
tt.sound_head_scratch = "Stage20TreeHeadScratch"
tt.ui.click_rect = r(-55, -15, 110, 100)
tt = RT("stage_20_arborean_oldtree_tree", "decal_scripted")
b = balance.specials.towers.stage_20_arborean_oldtree

AC(tt, "nav_path", "motion", "custom_attack")

tt.render.sprites[1].prefix = "arborean_woodDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"idle", "idle", "idle"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].exo = true
tt.main_script.update = scripts.stage_20_arborean_oldtree_tree.update
tt.nav_path.dir = -1
tt.nav_path.pi = b.path_index
tt.nav_path.ni = b.node_index
tt.nav_path.spi = 1
tt.motion.max_speed = 5 * FPS
tt.custom_attack.max_range = b.max_range
tt.custom_attack.damage_min = b.damage_min
tt.custom_attack.damage_max = b.damage_max
tt.custom_attack.damage_type = b.damage_type
tt.custom_attack.hit_fx = "fx_tower_arborean_oldtree_hit"
tt.custom_attack.cycle_time = 0.3
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt.sound_hit_floor = "Stage20TreeHitFloor"
tt.sound_hit_floor_repeat = "Stage20TreeHitFloorRepeat"
tt = RT("stage_20_arborean_oldtree_tree_2", "decal_scripted")
b = balance.specials.towers.stage_20_arborean_oldtree

AC(tt, "nav_path", "motion", "custom_attack")

tt.render.sprites[1].prefix = "arborean_woodDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"idle", "idle", "idle"}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].exo = true
tt.main_script.update = scripts.stage_20_arborean_oldtree_tree.update
tt.nav_path.dir = -1
tt.nav_path.pi = b.path_index_iron
tt.nav_path.ni = b.node_index_iron
tt.nav_path.spi = 1
tt.motion.max_speed = 5 * FPS
tt.custom_attack.max_range = b.max_range
tt.custom_attack.damage_min = b.damage_min
tt.custom_attack.damage_max = b.damage_max
tt.custom_attack.damage_type = b.damage_type
tt.custom_attack.hit_fx = "fx_tower_arborean_oldtree_hit"
tt.custom_attack.cycle_time = 0.3
tt.custom_attack.vis_flags = bor(F_RANGED)
tt.custom_attack.vis_bans = bor(F_FLYING)
tt = E:register_t("tower_stage_20_arborean_honey", "tower_KR5")
b = balance.specials.towers.stage_20_arborean_honey

E:add_comps(tt, "attacks", "user_selection")

tt.tower.type = "arborean_honey"
tt.tower.level = 1
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = IS_CONSOLE
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.tower.cooldown_idle = 10
tt.tower.menu_offset = v(0, 20)
tt.info.fn = scripts.tower_stage_20_arborean_honey.get_info
tt.info.portrait = "kr5_portraits_towers_0027"
tt.info.desc = "TOWER_STAGE_20_ARBOREAN_HONEY_DESCRIPTION"
tt.user_selection.can_select_point_fn = scripts.tower_stage_20_arborean_honey.can_select_point
tt.main_script.update = scripts.tower_stage_20_arborean_honey.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = ""
tt.render.sprites[1].name = "arborean_honey_tower_tower_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.y = 0
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].prefix = "arborean_honey_tower_unit"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].prefix = "arborean_honey_tower_deco_unit"
tt.render.sprites[3].name = "idle_1"
tt.render.sprites[3].hidden = true
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "arborean_honey_tower_smoke"
tt.render.sprites[4].hidden = true
tt.attacks.range = b.max_range
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].bullet = "bullet_stage_20_arborean_honey"
tt.attacks.list[1].cooldown = b.cooldown
tt.attacks.list[1].disable = true
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_FLYING)
tt.price_repair_heroic = b.price_heroic
tt.price_repair = b.price
tt.repair = {}
tt.repair.active = nil
tt.user_selection.ignore_point = true
tt.ui.has_nav_mesh = true
tt.sound_bee_fly_chance = 0.2
tt.sound_bee_fly = "Stage20BeesFly"
tt.sound_bee_throw = "Stage20BeesThrow"
tt = E:register_t("tower_stage_20_arborean_barrack", "tower_KR5")
b = balance.specials.towers.tower_stage_20_arborean_barrack
E:add_comps(tt, "vis", "user_selection", "attacks")
tt.tower.type = "arborean_barrack"
tt.tower.level = 1
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = IS_CONSOLE
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.tower.menu_offset = v(0, 25)
tt.info.fn = scripts.tower_stage_20_arborean_barrack.get_info
tt.info.portrait = "kr5_portraits_towers_0026"
tt.info.desc = "TOWER_STAGE_20_ARBOREAN_BARRACK_DESCRIPTION"
tt.main_script.update = scripts.tower_stage_20_arborean_barrack.update
tt.render.sid_base = 1
tt.render.sid_tower = 2
tt.render.sid_door = 3
tt.render.sid_varitas = 4
tt.render.sprites[tt.render.sid_base] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_base].animated = false
tt.render.sprites[tt.render.sid_base].name = "arborean_warrior_barraca_decal"
tt.render.sprites[tt.render.sid_base].z = Z_DECALS
tt.render.sprites[tt.render.sid_tower] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_tower].animated = true
tt.render.sprites[tt.render.sid_tower].prefix = "arborean_warrior_barraca_base"
tt.render.sprites[tt.render.sid_tower].name = "idle1"
tt.render.sprites[tt.render.sid_door] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_door].animated = true
tt.render.sprites[tt.render.sid_door].prefix = "arborean_warrior_barraca_door"
tt.render.sprites[tt.render.sid_door].name = "closed"
tt.render.sprites[tt.render.sid_varitas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_varitas].animated = true
tt.render.sprites[tt.render.sid_varitas].prefix = "arborean_warrior_barraca_varitas"
tt.render.sprites[tt.render.sid_varitas].name = "idle1"
tt.explosion_fx = "fx_stage_20_arborean_barrack_explosion"
tt.explosion_fx2 = "fx_stage_20_arborean_barrack_explosion_2"
tt.life_thresholds = b.life_thresholds
tt.user_selection.ignore_point = true
tt.ui.has_nav_mesh = true
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].price = b.price
tt.attacks.list[1].cast_time = fts(10)
tt.attacks.list[1].cooldown_min = b.spawn_cooldown_min
tt.attacks.list[1].cooldown_max = b.spawn_cooldown_max
tt.attacks.list[1].cooldown_disable = b.cooldown_disable
tt.attacks.list[1].entity = "soldier_arborean_barrack"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
tt.attacks.list[1].vis_flags = 0
tt.attacks.list[1].spawns = b.spawns
tt.attacks.list[1].range_nodes = 100
tt.sound_get_hit = "Stage20HouseImpact"
tt.sound_destroyed = "Stage20HouseDestroyed"
E:add_comps(tt, "health", "health_bar", "soldier", "unit")
tt.unit.hit_offset = v(0, 15)
tt.health.hp_max = b.hp_max
tt.health.hp = b.hp_max
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 128, 255, 255}
tt.health_bar.colors.bg = {22, 46, 59, 255}
tt.health.ignore_delete_after = true
tt.vis.flags = bor(F_FRIEND, F_RANGED)
tt.vis.bans = bor(F_AREA, F_MOD)

tt = E:register_t("soldier_arborean_barrack", "unit")
b = balance.specials.towers.tower_stage_20_arborean_barrack

E:add_comps(tt, "soldier", "motion", "nav_path", "main_script", "vis", "info", "lifespan", "sound_events", "melee", "tween")

tt.info.portrait = "kr5_info_portraits_soldiers_0032"
tt.health.armor = b.soldier_armor
tt.health.hp_max = b.soldier_hp_max
tt.health_bar.offset = v(0, ady(30))
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.i18n_key = "SOLDIER_ARBOREAN_BARRACK"
tt.lifespan.duration = nil
tt.main_script.insert = scripts.soldier_charge.insert
tt.main_script.update = scripts.soldier_charge.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = b.soldier_damage_max
tt.melee.attacks[1].damage_min = b.soldier_damage_min
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 64
tt.motion.max_speed = 60
tt.nav_path.dir = -1
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "arborean_warrior_barraca_warrior"
tt.soldier.melee_slot_offset.x = 3
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, ady(22))
tt.vis.bans = bor(F_POISON, F_CANNIBALIZE, F_LYCAN)
tt.vis.flags = F_FRIEND
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].disabled = true
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.disabled = false
tt = E:register_t("tower_stage_20_arborean_watchtower", "tower_KR5")
b = balance.specials.towers.stage_20_arborean_watchtower

E:add_comps(tt, "attacks", "vis", "idle_flip")

tt.tower.type = "weirdwood"
tt.tower.level = 1
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.info.portrait = "kr5_portraits_towers_0021"
tt.main_script.update = scripts.tower_stage_20_arborean_watchtower.update
tt.attacks.range = b.basic_attack.max_range
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_stage_20_arborean_watchtower"
tt.attacks.list[1].cooldown = b.basic_attack.cooldown
tt.attacks.list[1].shoot_time = fts(6)
tt.attacks.list[1].bullet_start_offset = {v(0, 25), v(0, 25), v(0, 25)}
tt.attacks.list[1].vis_flags = bor(F_RANGED)

for i = 1, 4 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].prefix = "watchtower_arborean_tower_base_layer" .. i
	tt.render.sprites[i].name = "idle1"
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].z = Z_OBJECTS
	tt.render.sprites[i].sort_y_offset = -50
end

tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].prefix = "stage_4_special_arborean_sentinels_spearer_soldier"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].angles = {}
tt.render.sprites[5].angles.idle = {"idle", "idle"}
tt.render.sprites[5].angles.shoot = {"ranged_attack", "ranged_attack"}
tt.render.sprites[5].offset = v(-13, 2)
tt.render.sprites[5].z = Z_OBJECTS_COVERS
tt.render.sprites[6] = table.deepclone(tt.render.sprites[5])
tt.render.sprites[6].offset = v(32, 41)
tt.render.sprites[7] = table.deepclone(tt.render.sprites[5])
tt.render.sprites[7].offset = v(-27, 60)
tt.explosion_fx = "fx_stage_20_watchtower_explosion"
tt.tower_group = "layers"
tt.shooter_sids = {5, 6, 7}
tt.ui.click_rect = r(-45, -10, 95, 90)
tt.tunnel_spawns = {}
tt.tunnel_spawns[1] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 10,
	pick_pi = 1
}
tt.tunnel_spawns[2] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 11,
	pick_pi = 2
}
tt.picked_enemies_to_destroy = b.picked_enemies_to_destroy
tt.tunnel_check_cooldown = b.tunnel_check_cooldown
tt.vis.bans = bor(F_MOD)
tt = E:register_t("tower_stage_20_arborean_watchtower_2", "tower_stage_20_arborean_watchtower")
tt.tunnel_spawns = {}
tt.tunnel_spawns[1] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 13,
	pick_pi = 3
}
tt = E:register_t("tower_stage_20_arborean_watchtower_3", "tower_stage_20_arborean_watchtower")
tt.tunnel_spawns = {}
tt.tunnel_spawns[1] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 12,
	pick_pi = 7
}
tt.tunnel_spawns[2] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 12,
	pick_pi = 5
}
tt.tunnel_spawns[3] = {
	template = "tunnel_KR5_watchtower",
	place_pi = 12,
	pick_pi = 13
}
tt = E:register_t("tower_stage_22_arborean_mages", "tower_KR5")
b = balance.specials.towers.stage_22_arborean_mages_tower
E:add_comps(tt, "attacks", "vis")
tt.tower.type = "weirdwood"
tt.tower.level = 1
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.range_offset = v(0, 10)
tt.tower.price = 0
tt.info.portrait = "kr5_portraits_towers_0023"
tt.main_script.update = scripts.tower_stage_22_arborean_mages.update
tt.attacks.range = b.basic_attack.max_range
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_stage_22_arborean_mages"
tt.attacks.list[1].cooldown = b.basic_attack.cooldown
tt.attacks.list[1].animation = "ability"
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].prediction_time = fts(30)
tt.attacks.list[1].bullet_start_offset = v(20, 75)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.render.sid_rune = 1
tt.render.sprites[tt.render.sid_rune] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_rune].animated = true
tt.render.sprites[tt.render.sid_rune].prefix = "Shaman_baseDef"
tt.render.sprites[tt.render.sid_rune].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_rune].name = "idleblue"
tt.render.sprites[tt.render.sid_rune].exo = true
tt.render.sprites[tt.render.sid_rune].offset = v(0, 4)
tt.render.sprites[tt.render.sid_rune].anchor = v(0.5, 0.528169014084507)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = true
tt.render.sprites[2].prefix = "Stage_22_shaman_shaman_unit"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].offset = v(0, 5)
tt.attacks.list[1].bullet_start_offset.y = tt.attacks.list[1].bullet_start_offset.y + tt.render.sprites[2].offset.y
tt.render.sprites[2].anchor = v(0.5, 0.528169014084507)
tt.leave = false
tt.leave_anim = "out"
tt.appear = false
tt.appear_anim = "spawn"
tt.ui.click_rect = r(-35, -15, 70, 70)

local b = balance.enemies.crocs.quickfeet_gator

tt = E:register_t("quickfeet_gator_chicken_leg_bullet", "bullet")
tt.main_script.insert = scripts.quickfeet_gator_chicken_leg_bullet.insert
tt.main_script.update = scripts.quickfeet_gator_chicken_leg_bullet.update
tt.render.sprites[1].anchor = v(0.5, 0.6)
tt.render.sprites[1].name = "quickfeet_gator_attack_projectile_0001"
tt.render.sprites[1].animated = false
tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
tt.bullet.hit_ts_offset = fts(7)
tt.bullet.hide_radius = nil
tt.bullet.hide_radius_start = 0
tt.bullet.hide_radius_end = 4
tt.bullet.flight_time = nil
tt.bullet.g = -1.2 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_quickfeet_chicken_hit"
tt.bullet.hit_blood_fx = nil
tt.bullet.mod = "mod_chicken_leg_polymorph"
tt = E:register_t("bullet_quickfeet_gator_bone", "arrow_fixed_height")
b = balance.enemies.crocs.quickfeet_gator.ranged_attack
tt.bullet.flight_time = fts(22)
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.fixed_height = 30
tt.bullet.g = -1000
tt.bullet.hit_blood_fx = nil
tt.bullet.pop = nil
tt.bullet.hide_radius = 6
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = "fx_quickfeet_bone_hit"
tt.render.sprites[1].prefix = "quickfeet_gator_attack_projectile_bone"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.bullet.rotation_speed = 30 * FPS * math.pi / 180 * 0.6
tt.bullet.hide_radius = 2
tt.bullet.hit_distance = 20
tt.bullet.extend_particles_cutoff = true
tt = E:register_t("bullet_ranged_crocs", "arrow")
b = balance.enemies.crocs.crocs_ranged
tt.bullet.flight_time = fts(13)
tt.bullet.flight_time_variance = 3
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.g = -2.5 / (fts(1) * fts(1))
tt.bullet.hit_blood_fx = nil
tt.bullet.pop = nil
tt.bullet.hide_radius = 6
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = "fx_ranged_croc_hit"
tt.render.sprites[1].name = "ranged_croc_proyectile"
tt.render.sprites[1].animated = false
tt.bullet.hide_radius = 0
tt.bullet.hit_distance = 20
tt.bullet.extend_particles_cutoff = true
tt = E:register_t("bullet_crocs_shaman", "bolt_enemy")

local b = balance.enemies.crocs.crocs_shaman

tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "shaman_bolt"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = v(0.5, 0.485)
tt.sound_events.insert = "EnemyCrocShamanShot"
tt.bullet.hit_fx = "fx_enemy_croc_shaman_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.5
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_croc_shaman_bullet_trail"
tt.bullet.damage_type = b.ranged_attack.damage_type
tt = E:register_t("bullet_crocs_egg_spawner_spawn", "bomb")
tt.bullet.flight_time = fts(30)
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop = nil
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "enemy_crocs_basic_egg"
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "crokinder_carrier_attack_projectile"
tt.render.sprites[1].name = "run"
tt.bullet.hide_radius = 0
tt.bullet.hit_decal = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.main_script.update = scripts.bullet_crocs_egg_spawner_spawn.update
tt = E:register_t("bullet_enemy_crocs_hydra", "bomb")
local b = balance.enemies.crocs.crocs_hydra
tt.render.sprites[1].prefix = "hydra_projectileDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.bullet.hit_fx = nil
tt.bullet.hit_payload = "aura_bullet_enemy_crocs_hydra_dot"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.particles_name = "ps_bullet_crocs_hydra_tower_debuff"
tt.bullet.align_with_trajectory = true
tt = E:register_t("bullet_boss_crocs_poison_rain_lvl1", "bomb")
b = balance.enemies.crocs.boss_crocs.poison_rain
tt.bullet.flight_time = fts(40)
tt.bullet.hit_fx = "boss_gator_vfx_acid_explosion"
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "aura_bullet_boss_crocs_poison_rain_lvl1"
tt.sound_events.hit = "Stage22AbominorAcidHit"
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "boss_gator_vfx_acid_projectile"
tt.render.sprites[1].name = "run"
tt.bullet.particles_name = "ps_bullet_boss_crocs_poison_rain_lvl1"
tt = E:register_t("bullet_boss_crocs_poison_rain_lvl2", "bullet_boss_crocs_poison_rain_lvl1")
tt.bullet.hit_fx = "boss_gator_vfx_fire_explosion"
tt.bullet.hit_payload = "aura_bullet_boss_crocs_poison_rain_lvl2"
tt.render.sprites[1].prefix = "boss_gator_vfx_fire_projetile"
tt.bullet.particles_name = "ps_bullet_boss_crocs_poison_rain_lvl2"
tt.sound_events.hit = "Stage22AbominorFireballHit"
tt = E:register_t("bullet_stage_20_arborean_watchtower", "arrow_fixed_height")
b = balance.specials.towers.stage_20_arborean_watchtower
tt.bullet.damage_min = b.basic_attack.damage_min
tt.bullet.damage_max = b.basic_attack.damage_max
tt.bullet.damage_type = b.basic_attack.damage_type
tt.bullet.fixed_height = 40
tt.bullet.g = -1000
tt.render.sprites[1].name = "stage_4_special_arborean_sentinels_spearer_spear"
tt.bullet.hit_fx = "fx_arborean_sentinels_spearmen_spear_hit"
tt.bullet.hide_radius = 10
tt.bullet.miss_decal = "stage_4_special_arborean_sentinels_spearer_spear_decal"
tt = E:register_t("bullet_stage_20_arborean_oldtree", "bomb")
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = nil
tt.bullet.pop = nil
tt.bullet.hit_decal = nil
tt.bullet.hide_radius = 0
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.rotation_speed = nil
tt.bullet.hit_payload = "stage_20_arborean_oldtree_tree"
tt.bullet.particles_name = "ps_bullet_tower_arborean_oldtree_trail"
tt.render.sprites[1].prefix = "arborean_projectileDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt = E:register_t("bullet_stage_20_arborean_honey", "bomb")
b = balance.specials.towers.stage_20_arborean_honey
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_bullet_tower_arborean_honey_hit"
tt.bullet.hide_radius = 0
tt.bullet.align_with_trajectory = false
tt.bullet.ignore_hit_offset = true
tt.bullet.pop_chance = 0.5
tt.bullet.hit_payload = "aura_bullet_tower_arborean_honey"
tt.render.sprites[1].name = "arborean_honey_tower_projectil"
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.damage_type = b.damage_type
tt.sound_events.hit = "Stage20BeesImpact"

tt = E:register_t("bullet_stage_22_arborean_mages", "bolt")
E:add_comps(tt, "force_motion")
tt.main_script.update = scripts.bolt_force_motion_kr5.update
tt.main_script.insert = scripts.bolt_force_motion_kr5.insert
b = balance.specials.towers.stage_22_arborean_mages_tower
tt.render.sprites[1].prefix = "Stage_22_shaman_shaman_projectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BULLETS
tt.bullet.damage_min = b.basic_attack.damage_min
tt.bullet.damage_max = b.basic_attack.damage_max
tt.bullet.damage_type = b.basic_attack.damage_type
tt.bullet.hit_fx = "fx_bullet_tower_arborean_mage_hit"
tt.bullet.particles_name = "ps_bullet_tower_stage_22_mages_trail"
tt.bullet.align_with_trajectory = true
tt.initial_impulse = 6000
tt.initial_impulse_duration = 0.08
tt.initial_impulse_angle_abs = math.pi / 2
tt.force_motion.a_step = 10
tt.force_motion.max_a = 6000
tt.force_motion.max_v = 450
tt.sound_events.insert = nil

tt = E:register_t("ps_bullet_tower_arborean_oldtree_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "arborean_oldtree_trail_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 10
tt.particle_system.z = Z_BULLET_PARTICLES

tt = E:register_t("ps_bullet_boss_crocs_poison_rain_lvl1")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "boss_gator_vfx_acid_trail"
tt.particle_system.anchor = v(0.7, 0.5)
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLET_PARTICLES

tt = E:register_t("ps_bullet_boss_crocs_poison_rain_lvl2")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "boss_gator_vfx_fire_trail"
tt.particle_system.anchor = v(0.7, 0.5)
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("fx_tower_holder_unblock_terrain_4", "fx")
tt.render.sprites[1].prefix = "UpdateHalloween_terrain_anim"
tt.render.sprites[1].name = "out"
tt.render.sprites[1].offset = v(0, 13.5)
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("ps_bullet_tower_stage_22_mages_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "Stage_22_shaman_shaman_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 12
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(18), fts(18)}
tt = E:register_t("ps_enemy_crocs_water_trail", "ps_water_trail")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.ps_enemy_crocs_water_trail.update
tt.adjust_scale = true
tt = E:register_t("ps_enemy_crocs_water_bubbles_small", "particle_system")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.ps_enemy_crocs_water_trail.update
tt.particle_system.name = "fx_water_bubble_small"
tt.particle_system.animated = true
tt.particle_system.emit_area_spread = v(6, 6)
tt.particle_system.ts_offset = 0.1
tt.particle_system.emission_rate = 4
tt.particle_system.z = Z_OBJECTS
tt.adjust_scale = false
tt.particle_system.particle_lifetime = {fts(24), fts(24)}
tt = E:register_t("ps_enemy_crocs_water_bubbles_big", "particle_system")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.ps_enemy_crocs_water_trail.update
tt.particle_system.name = "fx_water_bubble_big"
tt.particle_system.animated = true
tt.particle_system.loop = true
tt.particle_system.particle_lifetime = {fts(66), fts(66)}
tt.particle_system.emit_area_spread = v(12, 12)
tt.particle_system.ts_offset = 1
tt.particle_system.emission_rate = 1
tt.particle_system.z = Z_OBJECTS
tt.adjust_scale = false
tt = E:register_t("ps_enemy_crocs_water_bubbles_projectile", "particle_system")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.ps_enemy_crocs_water_trail.update
tt.particle_system.name = "fx_water_bubble_big_projectile"
tt.particle_system.animated = true
tt.particle_system.emission_rate = 3
tt.particle_system.z = Z_OBJECTS + 1
tt.particle_system.loop = true
tt.particle_system.particle_lifetime = {fts(48), fts(48)}
tt.particle_system.scales_x = {1, 0.05}
tt.particle_system.scales_y = {1, 0.05}
tt.particle_system.scale_var = {0.9, 1.1}
tt.adjust_scale = false
tt = E:register_t("ps_croc_shaman_bullet_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "shaman_bolt_2"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 70
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.scales_y = {1, 0.5}
tt = E:register_t("ps_crocs_tank_charge")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "tank_trail_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 12
tt.particle_system.track_offset = v(0, 0)
tt.particle_system.z = Z_DECALS
tt.particle_system.emit_area_spread = v(4, 4)
tt.particle_system.rotation_spread = 20

tt = E:register_t("mod_chicken_leg_polymorph", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_chicken_leg_polymorph.insert
tt.entity_t = {{"enemy_crocs_basic_egg", "enemy_crocs_basic"}, {"enemy_crocs_basic", "enemy_killertile"}, {"enemy_killertile", "enemy_crocs_tank"}}
tt = E:register_t("mod_chicken_leg_polymorph_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.modifier.duration = fts(80)
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_enemy_crocs_tank_charge_soldier", "modifier")
b = balance.enemies.crocs.crocs_tank

E:add_comps(tt, "dps")

tt.dps.damage_min = b.charge.damage_soldier_min
tt.dps.damage_max = b.charge.damage_soldier_max
tt.dps.damage_type = b.charge.damage_type
tt.dps.damage_every = fts(10)
tt.dps.fx = "fx_crocs_tank_spin_hit"
tt.modifier.duration = fts(7)
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_enemy_crocs_tank_charge_soldier.update
tt = E:register_t("mod_enemy_crocs_shaman_healing", "modifier")
b = balance.enemies.crocs.crocs_shaman

E:add_comps(tt, "render", "tween", "hps")

tt.modifier.duration = b.healing.duration
tt.hps.heal_min = b.healing.heal_min
tt.hps.heal_max = b.healing.heal_max
tt.hps.heal_every = b.healing.heal_every
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].name = "shaman_buff"
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].scale = vv(0.5)
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
tt = E:register_t("mod_enemy_crocs_shaman_tower_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.modifier.duration = fts(20)
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_crocs_shaman_tower_debuff", "modifier")
b = balance.enemies.crocs.crocs_shaman.debuff_towers

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_crocs_shaman_tower_debuff.insert
tt.main_script.update = scripts.mod_crocs_shaman_tower_debuff.update
tt.modifier.duration = b.stun_duration
tt.modifier.vis_flags = F_CUSTOM
tt.render.sprites[1].prefix = "Fx_Shaman_BlocktowerDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
-- -14
tt.render.sprites[1].offset.y = 14
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.offset_y_per_tower = {
	hermit_toad = 4
}

tt = E:register_t("fx_tower_arborean_oldtree_hit", "fx")
tt.render.sprites[1].prefix = "arborean_hitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = E:register_t("aura_bullet_enemy_crocs_hydra_dot", "aura")
b = balance.enemies.crocs.crocs_hydra.dot
E:add_comps(tt, "render")
tt.aura.mod = "mod_crocs_hydra_dot"
tt.aura.radius = b.radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.cycle_time = fts(5)
tt.aura.duration = b.duration
tt.render.sprites[1].prefix = "hydra_decal_skill2Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_bullet_enemy_crocs_hydra_dot.update

tt = E:register_t("aura_bullet_boss_crocs_poison_rain_lvl1", "aura")
b = balance.enemies.crocs.boss_crocs.poison_rain
E:add_comps(tt, "render", "tween")
tt.aura.mod = "mod_croc_boss_poison_rain_lvl1"
tt.aura.radius = b.poison_radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.cycle_time = fts(5)
tt.aura.duration = b.poison_decal_duration[1]
tt.render.sprites[1].prefix = "boss_gator_lvl2_puddleDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_bullet_boss_crocs_poison_rain_lvl1.update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration - 0.5, 255}, {tt.aura.duration, 0}}

tt = E:register_t("aura_bullet_boss_crocs_poison_rain_lvl2", "aura_bullet_boss_crocs_poison_rain_lvl1")
tt.aura.duration = b.poison_decal_duration[2]
tt.render.sprites[1].prefix = "boss_gator_lvl3_puddleDef"
tt.aura.mod = "mod_croc_boss_poison_rain_lvl2"

tt = E:register_t("aura_bullet_tower_arborean_honey", "aura")
b = balance.specials.towers.stage_20_arborean_honey
E:add_comps(tt, "render", "tween")
tt.aura.mod = "mod_tower_arborean_honey_basic_slow"
tt.aura.radius = 60
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.cycle_time = fts(5)
tt.aura.duration = b.aura_duration
tt.render.sprites[1].name = "arborean_honey_tower_decal_in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 1
tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration - 0.5, 255}, {tt.aura.duration, 0}}

tt = E:register_t("mod_tower_arborean_honey_basic_slow", "mod_slow")
b = balance.specials.towers.stage_20_arborean_honey

E:add_comps(tt, "render", "tween")

tt.balance_slow_factor = b.slow_factor
tt.balance_duration = b.slow_mod_duration
tt.slow.factor = b.slow_factor
tt.modifier.duration = b.slow_mod_duration
tt.render.sprites[1].name = "arborean_honey_tower_modifier"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor = v(0.5, 0.6)
tt.render.sprites[1].loop = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}

tt = E:register_t("tunnel_KR5_stage22_boss", "tunnel_KR5")
tt.untargetable_distance = 20
tt.tunnel.speed_factor = 1000

tt = E:register_t("mod_boss_crocs_tower_timed_destroy", "modifier")
b = balance.enemies.crocs.boss_crocs.pre_fight_towers_destroy
E:add_comps(tt, "render")
tt.main_script.insert = scripts.mod_boss_crocs_tower_timed_destroy.insert
tt.main_script.remove = scripts.mod_boss_crocs_tower_timed_destroy.remove
tt.main_script.update = scripts.mod_boss_crocs_tower_timed_destroy.update
tt.modifier.duration = 1e+99
tt.render.sprites[1].prefix = "overseer_fx_overseer_tentaclesback"
tt.render.sprites[1].animated = true
tt.render.sprites[1].offset.y = 13
tt.render.sprites[1].sort_y_offset = 35
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "overseer_fx_overseer_tentaclesfront"
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset.y = 13
tt.render.sprites[2].draw_order = DO_TOWER_MODS
tt.fade_duration = 0.4
tt.can_prevent_destroy = b.can_prevent_destroy
tt._prevent_timed_destroy_price = b.prevent_timed_destroy_price
tt.destroy_tower_cooldown = b.destroy_tower_time
tt.needs_arborean_mages_to_clean = b.needs_arborean_mages_to_clean
tt.offset_y_per_tower = {
	necromancer5 = 16,
	royal_archers = 20,
	elven_stargazers = 16,
	tricannon = 10,
	arborean_emissary = 20,
	flamespitter = 16,
	ballista = 20
}
tt = E:register_t("mod_boss_crocs_tower_eat", "modifier")
E:add_comps(tt, "render")
tt.main_script.queue = scripts.mod_boss_crocs_tower_eat.queue
tt.main_script.dequeue = scripts.mod_boss_crocs_tower_eat.dequeue
tt.main_script.insert = scripts.mod_boss_crocs_tower_eat.insert
tt.main_script.remove = scripts.mod_boss_crocs_tower_eat.remove
tt.main_script.update = scripts.mod_boss_crocs_tower_eat.update
tt.modifier.duration = 1e+99
tt.render.sprites[1].prefix = "boss_gator_tower_killDef"
tt.render.sprites[1].name = "attack1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_TOWER_MODS
tt.render.sprites[1].sort_y_offset = -10
tt.sound_eat = "Stage22AbominorEatTower"
tt.sound_fist_remove = "Stage22AbominorEatTowerFistRemove"
tt.fade_duration = 0.4
tt.offset_y_per_tower = {
	necromancer5 = 16,
	royal_archers = 20,
	elven_stargazers = 16,
	tricannon = 10,
	arborean_emissary = 20,
	flamespitter = 16,
	ballista = 20
}
tt = E:register_t("mod_crocs_hydra_dot", "modifier")
b = balance.enemies.crocs.crocs_hydra.dot

E:add_comps(tt, "dps", "render")

tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.damage_every
tt.modifier.duration = fts(10)
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].prefix = "hydra_poisonDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt = E:register_t("mod_croc_boss_evolution_polymorph", "modifier")
b = balance.enemies.crocs.boss_crocs.primordial_hunger
tt.hp_evolution_method = {b[1].hp_evolution_method, b[2].hp_evolution_method, b[3].hp_evolution_method, b[4].hp_evolution_method, b[5].hp_evolution_method}
tt.hp_restore_fixed_amount = {b[1].hp_restore_fixed_amount, b[2].hp_restore_fixed_amount, b[3].hp_restore_fixed_amount, b[4].hp_restore_fixed_amount, b[5].hp_restore_fixed_amount}
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_croc_boss_evolution_polymorph.insert
tt.entity_t = {{"boss_crocs_lvl1", "boss_crocs_lvl2"}, {"boss_crocs_lvl2", "boss_crocs_lvl3"}, {"boss_crocs_lvl3", "boss_crocs_lvl4"}, {"boss_crocs_lvl4", "boss_crocs_lvl5"}}
tt = E:register_t("mod_croc_boss_poison_rain_lvl1", "modifier")
b = balance.enemies.crocs.boss_crocs.poison_rain

E:add_comps(tt, "dps", "render", "tween")

tt.dps.damage_min = b.poison_damage_min[1]
tt.dps.damage_max = b.poison_damage_max[1]
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.poison_damage_every
tt.modifier.duration = b.poison_mod_duration[1]
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].prefix = "boss_gator_vfx_acid_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = true
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
tt = E:register_t("mod_croc_boss_poison_rain_lvl2", "mod_croc_boss_poison_rain_lvl1")
tt.dps.damage_min = b.poison_damage_min[2]
tt.dps.damage_max = b.poison_damage_max[2]
tt.modifier.duration = b.poison_mod_duration[2]
tt.render.sprites[1].prefix = "boss_gator_vfx_fire_modifier"

tt = E:register_t("mod_boss_crocs_stomp", "modifier")
b = balance.enemies.crocs.boss_crocs.stomper
E:add_comps(tt, "dps")
tt.dps.damage_min = b.damage_soldiers_min
tt.dps.damage_max = b.damage_soldiers_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.damage_every
tt.modifier.duration = fts(7)
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("fx_bullet_tower_arborean_mage_hit", "fx")
tt.render.sprites[1].name = "Stage_22_shaman_shaman_hitfx_run"

tt = E:register_t("controller_darksteel_guardian")
E:add_comps(tt, "main_script", "editor")
tt.main_script.insert = scripts.controller_darksteel_guardian.insert
tt.guardian_t = "enemy_darksteel_guardian"
tt.editor.flip_x = false
tt.editor.path = 1
tt.editor.props = {{"editor.flip_x", PT_NUMBER}, {"editor.path", PT_NUMBER}}

tt = E:register_t("controller_darksteel_guardian_death")
b = balance.enemies.hammer_and_anvil.darksteel_guardian
E:add_comps(tt, "main_script", "render")
tt.main_script.update = scripts.controller_darksteel_guardian_death.update
tt.render.sprites[1].name = "darksteel_guardian_dwarf_projectile"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].animated = false
tt.clone_t = "bullet_enemy_darksteel_guardian_death"
tt.nodes_range = 20
tt.shoot_sound = nil
tt.spawn_offset = v(0, 20)
tt.legs_t = "decal_enemy_darksteel_guardian_legs"
tt.explotion_damage_min = b.death_explotion.damage_min
tt.explotion_damage_max = b.death_explotion.damage_max
tt.explotion_damage_radius = b.death_explotion.damage_radius
tt.explotion_damage_type = b.death_explotion.damage_type
tt.explotion_vis_bans = bor(F_ENEMY)
tt.explotion_vis_flags = bor(F_AREA, F_ENEMY)

tt = E:register_t("controller_basic_clone_darksteel_guardian", "enemy")
b = balance.enemies.hammer_and_anvil.common_clone
tt.info.portrait = "kr5_info_portraits_enemies_0067"
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.controller_basic_clone_darksteel_guardian.update
tt.render.sprites[1].prefix = "common_clone_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.vis.bans = F_ALL
tt.ui.can_click = false
tt.guardian_t = "enemy_darksteel_guardian"

tt = E:register_t("controller_stage_23_roboboots", "decal_scripted")
b = balance.specials.stage23_roboboots

E:add_comps(tt, "editor")

tt.main_script.update = scripts.controller_stage_23_roboboots.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "dclenanos_stage01_robobootDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -1)
tt.render.sprites[1].sort_y_offset = 200
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "dclenanos_stage01_roboboot2Def"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(2.3, -3.1)
tt.render.sprites[2].sort_y_offset = 50
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "dclenanos_stage01_roboboot_topDef"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].exo = true
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].sort_y_offset = 200
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "dclenanos_stage01_roboboot2_topDef"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].exo = true
tt.render.sprites[4].offset = v(2.3, -2.1)
tt.render.sprites[4].sort_y_offset = 50
tt.render.sprites[4].z = Z_OBJECTS
tt.wave_config = b.wave_config
tt.sound_open = "Stage23BootOpen"
tt.sound_close = "Stage23BootClose"
tt = E:register_t("controller_stage_24_machinist")
b = balance.specials.stage24_factory

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_24_machinist.update
tt.wave_config = b.wave_config
tt.machinist_t = "enemy_machinist"
tt = E:register_t("decal_stage24_boss_machinist_shoutbox", "decal_stage06_cultist_shoutbox")
tt = E:register_t("taunts_s24_controller")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_24_boss_machinist_before_bossfight = CC("taunt_set")
tt.taunts.sets.stage_24_boss_machinist_before_bossfight.format = "TAUNT_STAGE24_BOSS_MACHINIST_BEFORE_BOSSFIGHT_%04i"
tt.taunts.sets.stage_24_boss_machinist_before_bossfight.decal_name = "decal_stage24_boss_machinist_shoutbox"
tt.taunts.sets.stage_24_boss_machinist_before_bossfight.pos = v(460, 550)
tt = E:register_t("controller_stage_25_torso")
b = balance.specials.stage25_torso

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_25_torso.update
tt.wave_config = b.wave_config
tt.action_duration = fts(220)
tt.fist_radius = b.fist.radius
tt.fist_damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD, DAMAGE_NO_DODGE)
tt.torso_t = "decal_stage_25_torso"
tt.torso_modes_t = "decal_stage_25_torso_modes"
tt.fist_t = "decal_stage_25_fist"
tt.fist_decal_t = "decal_stage_25_fist_shadow"
tt.missile_shoot_time = fts(66)
tt.missile_mark_mod = "mod_stage_25_torso_missile_mark"
tt.missile_t = "bullet_stage_25_torso_missile"
tt.missile_spawn_pos = v(750, 585)
tt.sound_torso_open = "Stage25TorsoOpen"
tt.sound_torso_close = "Stage25TorsoClose"
tt.sound_torso_lever_1 = "Stage25TorsoOperateLever1"
tt.sound_torso_lever_2 = "Stage25TorsoOperateLever2"
tt.sound_torso_button = "Stage25TorsoButton"
tt.sound_fist = "Stage25FistSlam"
tt.sound_missile = "Stage25MissileLaunch"
tt = E:register_t("decal_stage25_machinist_shoutbox", "decal_stage06_cultist_shoutbox")
tt = E:register_t("taunts_s25_controller")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_25_machinist_end = CC("taunt_set")
tt.taunts.sets.stage_25_machinist_end.format = "TAUNT_STAGE25_MACHINIST_END_%04i"
tt.taunts.sets.stage_25_machinist_end.decal_name = "decal_stage25_machinist_shoutbox"
tt.taunts.sets.stage_25_machinist_end.pos = v(460, 550)
tt = E:register_t("controller_stage_25_tunnel_glow")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_25_tunnel_glow.update
tt.glow_t = "decal_stage_25_mask_2_glow"
tt = E:register_t("controller_stage_26_taunts")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.main_script.update = scripts.controller_stage_26_taunts.update
tt.taunts.delay_min = 20
tt.taunts.delay_max = 30
tt.taunts.sets = {}
tt.taunts.sets.preparation = CC("taunt_set")
tt.taunts.sets.preparation.format = "LV26_GRYMBEARD_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx = 4
tt.taunts.sets.fight = CC("taunt_set")
tt.taunts.sets.fight.format = "LV26_GRYMBEARD_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx = 4
tt = E:register_t("controller_stage_26_spawners")
b = balance.specials.stage26_spawners

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_26_spawners.update
tt.wave_config = b.wave_config
tt.fist_spawner_controller_t = "controller_stage_26_fist_spawner"
tt.tube_left_t = "decal_stage_26_tube_left"
tt.tube_right_t = "decal_stage_26_tube_right"
tt.clone_spawner_controller_t = "controller_stage_26_clone_spawner"
tt.clone_spawner_t = "decal_stage_26_clone_spawner"
tt.hulk_spawner_controller_t = "controller_stage_26_hulk_spawner"
tt.hulk_spawner_t = "decal_stage_26_hulk_spawner"
tt = E:register_t("controller_stage_26_fist_spawner")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_26_fist_spawner.update
tt.boss_t = "decal_stage_26_boss"
tt.hand_controller_t = "controller_stage_26_fist_spawner_hand"
tt = E:register_t("controller_stage_26_fist_spawner_hand")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_26_fist_spawner_hand.update
tt.fist_spawner_t = "decal_stage_26_fist_spawner"
tt.fist_spawner_light_t = "decal_stage_26_fist_spawner_light"
tt.sound_hand = "Stage26FistSpawnerHand"
tt.sound_open = "Stage26FistSpawnerBoothFrontDoorOpen"
tt.sound_close = "Stage26FistSpawnerBoothFrontDoorClose"
tt = E:register_t("controller_stage_26_clone_spawner")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_26_clone_spawner.update
tt.clone_spawner_t = "decal_stage_26_fist_spawner"
tt.tube_t = "decal_stage_26_fist_spawner_light"
tt.boss_t = "decal_stage_26_boss"
tt.sound_in = "Stage26CloneSpawnerIn"
tt.sound_out = "Stage26CloneSpawnerOut"
tt.sound_chain = "Stage26Chain"
tt = E:register_t("controller_stage_26_hulk_spawner")

E:add_comps(tt, "main_script", "events")

tt.main_script.update = scripts.controller_stage_26_hulk_spawner.update
tt.hulk_spawner_t = "decal_stage_26_hulk_spawner"
tt.hulk_t = "enemy_darksteel_hulk"
tt.hulk_spawn_delay = fts(322)
tt.path_to_spawn = 9
tt.events.list[1].name = "hulk_spawn"
tt.events.list[1].on_event = scripts.controller_stage_26_hulk_spawner.on_event
tt.sound_shot = "Stage26HulkSpawnerShotTransform"
tt = E:register_t("decal_stage26_boss_shoutbox", "decal_stage06_cultist_shoutbox")
tt = E:register_t("taunts_s26_controller")

E:add_comps(tt, "main_script", "taunts", "editor")

tt.load_file = "level101_taunts"
tt.main_script.insert = scripts.taunts_controller.insert
tt.taunts.delay_min = 10
tt.taunts.delay_max = 20
tt.taunts.sets = {}
tt.taunts.sets.stage_26_boss_before_bossfight = CC("taunt_set")
tt.taunts.sets.stage_26_boss_before_bossfight.format = "TAUNT_STAGE26_BOSS_BEFORE_BOSSFIGHT_%04i"
tt.taunts.sets.stage_26_boss_before_bossfight.decal_name = "decal_stage26_boss_shoutbox"
tt.taunts.sets.stage_26_boss_before_bossfight.pos = v(460, 550)
tt = E:register_t("decal_stage27_boss_shoutbox", "decal_stage06_cultist_shoutbox")
tt = E:register_t("controller_stage_27_platform")

E:add_comps(tt, "main_script", "events", "taunts", "editor")

tt.main_script.insert = scripts.taunts_controller.insert
tt.main_script.update = scripts.controller_stage_27_platform.update
tt.platform_t = "decal_stage_27_platform"
tt.platform_bars_t = "decal_stage_27_platform_bars"
tt.cannon_left_t = "decal_stage_27_cannon_left"
tt.cannon_right_t = "decal_stage_27_cannon_right"
tt.cannon_controller_t_l = "controller_stage_27_cannon_L"
tt.cannon_controller_t_r = "controller_stage_27_cannon_R"
tt.head_controller_t = "controller_stage_27_head"
tt.door_mask_t = "decal_stage_27_mask_3"
tt.events.list[1].name = "platform_up"
tt.events.list[1].on_event = scripts.controller_stage_27_platform.on_platform_up_event
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "platform_down"
tt.events.list[2].on_event = scripts.controller_stage_27_platform.on_platform_down_event
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "platform_destroy"
tt.events.list[3].on_event = scripts.controller_stage_27_platform.on_platform_destroy_event
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "cannons"
tt.events.list[4].on_event = scripts.controller_stage_27_platform.on_cannons_event
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "taunt"
tt.events.list[5].on_event = scripts.controller_stage_27_platform.on_taunt_event
tt.load_file = "level101_taunts"
tt.taunts.sets = {}
tt.taunts.sets.preparation = CC("taunt_set")
tt.taunts.sets.preparation.format = "LV27_GRYMBEARD_PREPARATION_TAUNT_%02i"
tt.taunts.sets.preparation.end_idx = 4
tt.taunts.sets.fight = CC("taunt_set")
tt.taunts.sets.fight.format = "LV27_GRYMBEARD_FIGHT_TAUNT_%02i"
tt.taunts.sets.fight.end_idx = 4
tt.sound_intro = "Stage27Intro"
tt.sound_platform_up = "Stage27PlatformUp"
tt.sound_platform_down = "Stage27PlatformDown"
tt.sound_platform_destroy_chains = "Stage27PlatformDestroyChains"
tt.sound_platform_destroy_impacts = "Stage27PlatformDestroyHeadImpacts"
tt.sound_cannon_alarm = "Stage27CloneCannonAlarm"
tt = E:register_t("controller_stage_27_cannon")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_27_cannon.update
tt.cannon_shot_fx_t = "fx_stage_27_cannon_shot"
tt.cannon_shoot_time = fts(30)
tt.bullet_clone_dead_t = "bullet_stage_27_clone_dead"
tt.bullet_clone_alive_t = "bullet_stage_27_clone_alive"
tt.sound_shot = "Stage27CloneCannonOneShot"
tt = E:register_t("controller_stage_27_cannon_L", "controller_stage_27_cannon")

E:add_comps(tt, "events")

tt.events.list[1].name = "shoot-cannons-L"
tt._decal = "decal_stage_27_cannon_left"
tt.events.list[1].on_event = scripts.controller_stage_27_cannon.on_cannons_event
tt = E:register_t("controller_stage_27_cannon_R", "controller_stage_27_cannon")

E:add_comps(tt, "events")

tt.events.list[1].name = "shoot-cannons-R"
tt._decal = "decal_stage_27_cannon_right"
tt.events.list[1].on_event = scripts.controller_stage_27_cannon.on_cannons_event
tt = E:register_t("controller_stage_27_head")
b = balance.specials.stage27_head

E:add_comps(tt, "main_script", "events", "ui", "editor")

tt.main_script.update = scripts.controller_stage_27_head.update
tt.head_t = "decal_stage_27_head"
tt.ray_t = "decal_stage_27_ray"
tt.ray_stun_mod_t = "mod_stage_27_ray_stun"
tt.ray_damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD, DAMAGE_NO_DODGE)
tt.goblins_t = "decal_stage_27_goblins"
tt.smoke_back_t = "decal_stage_27_smoke_back"
tt.smoke_front_t = "decal_stage_27_smoke_front"
tt.sparks_t = "decal_stage_27_sparks"
tt.scrap_bullet_t = "bullet_stage_27_scrap"
tt.scrap_fx_t = "fx_stage_27_scrap"
tt.tower_stun_bullet_t = "bullet_stage_27_tower_stun"
tt.hand_decal_t = "decal_mod_stage_25_torso_missile_stun_hand"
tt.towers_to_stun = b.towers_to_stun
tt.events.list[1].name = "head_attack_left"
tt.events.list[1].on_event = scripts.controller_stage_27_head.on_attack_left_event
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "head_attack_right"
tt.events.list[2].on_event = scripts.controller_stage_27_head.on_attack_right_event
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "head_attack_left_cannon"
tt.events.list[3].on_event = scripts.controller_stage_27_head.on_attack_left_cannon_event
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "head_attack_right_cannon"
tt.events.list[4].on_event = scripts.controller_stage_27_head.on_attack_right_cannon_event
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "head_cannons"
tt.events.list[5].on_event = scripts.controller_stage_27_head.on_cannons_event
tt.events.list[6] = E:clone_c("event")
tt.events.list[6].name = "head_ears"
tt.events.list[6].on_event = scripts.controller_stage_27_head.on_ears_event
tt.events.list[7] = E:clone_c("event")
tt.events.list[7].name = "head_destroy"
tt.events.list[7].on_event = scripts.controller_stage_27_head.on_head_destroy_event
tt.events.list[8] = E:clone_c("event")
tt.events.list[8].name = "head_scrap"
tt.events.list[8].on_event = scripts.controller_stage_27_head.on_scrap_event
tt.ui.click_rect = r(-100, 50, 350, 250)
tt.charge_time = b.charge_time
tt.attack_duration = b.attack_duration
tt.taps_to_cancel = b.taps_to_cancel
tt.sound_ears_open = "Stage27HeadOpen"
tt.sound_ears_close = "Stage27HeadClose"
tt.sound_move = "Stage27HeadMove"
tt.sound_charge = "Stage27HeadFireblastCharge"
tt.sound_shoot = "Stage27HeadFireblastRelease"
tt.sound_cancel_tap = "Stage27HeadFireblastCancelTap"
tt.sound_interrupt = "Stage27HeadFireblastInterrupt"
tt.sound_return = "Stage27HeadReturn"

tt = E:register_t("decal_stage_23_mask_1", "decal")
tt.render.sprites[1].name = "stage23_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 170
tt = E:register_t("decal_stage_23_mask_2", "decal")
tt.render.sprites[1].name = "stage23_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 51
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_23_mask_4", "decal")
tt.render.sprites[1].name = "stage23_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -8
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_23_mask_5", "decal")
tt.render.sprites[1].name = "stage23_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 50
tt.render.sprites[1].hidden = false
tt = E:register_t("decal_stage_23_mask_6", "decal")
tt.render.sprites[1].name = "stage23_mask6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 123
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_stage_23_snow", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage01_snowfallDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_23_torches", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage01_torchesDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_23_crane", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "DLCenanos_stage1_deco_gruaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_23_crane.update
tt.ui.can_click = true
tt.ui.click_rect = r(400, -220, 110, 100)
tt.sound_tap_1_2 = "Stage23TruckOneShot"
tt.sound_tap_3 = "Stage23TruckTap3"
tt = E:register_t("decal_stage_23_rock", "decal")
tt.render.sprites[1].prefix = "darksteel_guardian_stage_rock"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_24_factory", "decal_scripted")

E:add_comps(tt, "spawner", "editor")

tt.render.sprites[1].prefix = "factoryDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 2
tt.main_script.update = scripts.decal_stage_24_factory.update
tt.spawner.eternal = true
tt.sound_factory_turn_on_end = "Stage24FactoryTurnOnEnd"
tt.sound_factory_turn_off = "Stage24FactoryTurnOff"
tt = E:register_t("decal_stage_24_gear_factory", "decal")
tt.render.sprites[1].prefix = "factory2Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_24_factory_conveyor_belt", "decal")
tt.render.sprites[1].prefix = "dlc_enanos_stage_02_LAYERS_factorygate"
tt.render.sprites[1].name = "activeloop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 1
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_stage_24_factory_sparks", "decal_scripted")
tt.render.sprites[1].prefix = "dlc_dwarf_boss_operator_sparks"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_stage_24_factory_sparks.update
tt = E:register_t("decal_stage_24_elevator", "decal_scripted")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "ascensorDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS - 1
tt.main_script.update = scripts.decal_stage_24_elevator.update
tt.sound_machinist_in = "Stage24MachinistEnter"
tt.sound_machinist_out = "Stage24MachinistExit"
tt = E:register_t("decal_stage_24_mask_1", "decal")
tt.render.sprites[1].name = "stage24_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 1
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_stage_24_mask_2", "decal")
tt.render.sprites[1].name = "stage24_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_24_mask_3", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage24_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_24_mask_4", "decal")
tt.render.sprites[1].name = "stage24_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = 44
tt = E:register_t("decal_stage_24_mask_5", "decal")
tt.render.sprites[1].name = "stage24_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_24_mask_6", "decal")
tt.render.sprites[1].name = "stage24_mask6"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = 95
tt = E:register_t("decal_stage_24_fans", "decal")
tt.render.sprites[1].prefix = "stage2dlcanimsfansDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_24_gears", "decal")
tt.render.sprites[1].prefix = "stage2dlcanimstuercasDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_24_gear_floor", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "dlc_enanos_stage_02_LAYERS_gear"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_24_gears.update
tt.ui.click_rect = r(-25, -5, 50, 35)
tt = E:register_t("decal_stage_24_gear_tower", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "towerDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_24_gears.update
tt.ui.click_rect = r(15, -35, 40, 65)
tt = E:register_t("decal_stage_24_bubble", "decal_scripted")
tt.render.sprites[1].prefix = "lavabubbleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_stage_24_bubble.update
tt = E:register_t("decal_stage_24_dust", "decal")
tt.render.sprites[1].prefix = "t5_dustDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t("decal_stage_24_smoke", "decal")
tt.render.sprites[1].prefix = "t5_smokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt = E:register_t("decal_stage_24_upgrade_station", "decal_scripted")

local b = balance.specials.stage24_upgrade_station

tt.render.sprites[1].prefix = "converterDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_24_upgrade_station.update
tt.hammerer_t = "enemy_darksteel_hammerer"
tt.fist_t = "enemy_darksteel_fist"
tt.wave_config = b.wave_config
tt.path_in = 8
tt.path_out = 9
tt.sound_open = "Stage24UpgradeStationIn"
tt.sound_close = "Stage24UpgradeStationOut"
tt.sound_transform = "Stage24UpgradeStationTransform"
tt = E:register_t("decal_stage_24_modes_decos", "decal_scripted")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "stage2DLC_ascensor_modosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_24_modes_decos.update
tt = E:register_t("decal_stage_25_mask_1", "decal")
tt.render.sprites[1].name = "stage25_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 32
tt = E:register_t("decal_stage_25_mask_2", "decal")
tt.render.sprites[1].name = "stage25_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 18
tt = E:register_t("decal_stage_25_mask_2_glow", "decal_tween")
tt.render.sprites[1].name = "stage25_mask2_glow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 19
tt.render.sprites[1].alpha = 0
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(30), 255}}
tt = E:register_t("decal_stage_25_mask_3", "decal")
tt.render.sprites[1].name = "stage25_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 4
tt = E:register_t("decal_stage_25_mask_4", "decal")
tt.render.sprites[1].name = "stage25_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_25_torso", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "DLC_stage3_dwarf_machinistDef"
tt.render.sprites[1].name = "idle_doors"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_25_torso_modes", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "DLC_stage3_dwarf_machinist_modesDef"
tt.render.sprites[1].name = "idle_doors"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_25_fist", "decal")
tt.render.sprites[1].prefix = "DLC_stage3_robot_armDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -20
tt = E:register_t("decal_stage_25_fist_shadow", "decal")
tt.render.sprites[1].prefix = "DLC_stage3_robot_arm_decalsDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_25_dwarf_intro", "decal_timed")
tt.render.sprites[1].prefix = "DLC_stage3_dwarf_inDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_mod_stage_25_torso_missile_stun_water", "decal_timed")
tt.render.sprites[1].name = "DLC_stage_03_missile_water_splash"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -9
tt.render.sprites[1].offset = v(0, 5)
tt = E:register_t("decal_mod_stage_25_torso_missile_stun_hand", "decal_tween")
tt.render.sprites[1].prefix = "DLC_stage_03_missile_tower_block_tap"
tt.render.sprites[1].name = "tap"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].offset = v(23, 10)
tt.tween.props[1].keys = {{0, 0}, {fts(15), 255}, {fts(45), 255}, {fts(60), 0}}
tt.tween.remove = true

tt = E:register_t("decal_stage_25_solid_snake", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "DLC_Enanos_S3_EasterEgg_SolidSnakeDef"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_25_solid_snake.update
tt.ui.can_click = true
tt.ui.click_rect = r(-325, 290, 50, 45)
tt.click_rect_1 = r(-325, 290, 50, 45)
tt.click_rect_2 = r(-335, 283, 50, 45)
tt.sound_1_2 = "Stage25SolidSnakeTap12"
tt.sound_3 = "Stage25SolidSnakeTap3"
tt = E:register_t("decal_stage_26_mask_1", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_mask_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_26_mask_2", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_mask_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_26_mask_3", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_mask_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_26_mask_4", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_mask_4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 200
tt = E:register_t("decal_stage_26_mask_5", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_mask_5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_26_foreground_1", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_foreground_a"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_stage_26_foreground_2", "decal")
tt.render.sprites[1].name = "DLC_enanos_stage_04_foreground_b"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_stage_26_mewtwo_capsules", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "DLC_Enanos_S4_EasterEgg_Mewtwo_CanistersDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_26_mewtwo.update
tt.ui.can_click = true
tt.ui.click_rect = r(100, 270, 50, 80)
tt.mewtwo_t = "decal_stage_26_mewtwo"
tt.sound_1_2 = "Stage26MewtwoTap12"
tt.sound_3 = "Stage26MewtwoTap3"
tt.sound_end = "Stage26MewtwoFlightFullSequence"
tt = E:register_t("decal_stage_26_mewtwo", "decal_timed")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "DLC_Enanos_S4_EasterEgg_MewtwoDef"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECT
tt = E:register_t("decal_stage_26_boss", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "DLC_Enanos_S4_Boss01Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 104
tt = E:register_t("decal_stage_26_clone_spawner", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_ElevatorDef"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_26_tube_left", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_ElevatorTubeADef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BACKGROUND
tt = E:register_t("decal_stage_26_tube_right", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_ElevatorTubeBDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BACKGROUND
tt = E:register_t("decal_stage_26_fist_spawner", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_CloneActivatorDef"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_stage_26_fist_spawner_light", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_ActivatorLightDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_26_hulk_spawner", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_HulkSpawnerDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "DLC_Enanos_S4_HulkSpawnerSyringeDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].loop = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_26_gears_front", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_GearsDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_26_gears_back", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_GearsBackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_BACKGROUND
tt = E:register_t("decal_stage_26_bubbles", "decal")
tt.render.sprites[1].prefix = "DLC_Enanos_S4_BubblesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_26_modes_decos", "decal_scripted")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "DLCstage4_deco_modosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_26_modes_decos.update
tt = E:register_t("decal_stage_27_mask_1", "decal")
tt.render.sprites[1].name = "stage27_mask1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 3
tt = E:register_t("decal_stage_27_mask_2", "decal")
tt.render.sprites[1].name = "stage27_mask2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_27_mask_3", "decal")
tt.render.sprites[1].name = "stage27_mask3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hidden = true
tt = E:register_t("decal_stage_27_mask_4", "decal")
tt.render.sprites[1].name = "stage27_mask4"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 2
tt = E:register_t("decal_stage_27_mask_5", "decal")
tt.render.sprites[1].name = "stage27_mask5"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 2
tt = E:register_t("decal_stage_27_snow", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage05_snowfallDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("decal_stage_27_platform", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_platformDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_stage_27_platform_bars", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_platform_barsDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt = E:register_t("decal_stage_27_cannon_right", "decal")
tt.render.sprites[1].prefix = "dlcenanos_stage05_cannonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.shot_pos = v(924, 509)
tt.shot_target_pos = v(815, 364)
tt = E:register_t("decal_stage_27_cannon_left", "decal")
tt.render.sprites[1].prefix = "dlcenanos_stage05_cannonDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.shot_pos = v(238, 532)
tt.shot_target_pos = v(361, 345)
tt = E:register_t("decal_stage_27_clone_dead", "decal_tween")
tt.render.sprites[1].prefix = "cannonLAYERS_clonedecorative"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].keys = {{0, 255}, {fts(30), 255}, {fts(55), 0}}
tt.tween.remove = true
tt = E:register_t("decal_stage_27_clone_alive", "decal_timed")
tt.render.sprites[1].prefix = "cannonLAYERS_cloneland"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.runs = 1
tt = E:register_t("decal_stage_27_head", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_headDef"
tt.render.sprites[1].name = "headdeathsmokeidle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].draw_order = 1
tt = E:register_t("decal_stage_27_ray", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage05_headrayDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = vv(2)
tt = E:register_t("decal_stage_27_goblins", "decal")
tt.render.sprites[1].prefix = "dclenanos_head_goblinsDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -350
tt = E:register_t("decal_stage_27_smoke_back", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSmokeBackDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt = E:register_t("decal_stage_27_smoke_front", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSmokeFrontDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt = E:register_t("decal_stage_27_sparks", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "dclenanos_stage05_HeadSparksDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt = E:register_t("decal_stage_27_modes_decos", "decal_scripted")

E:add_comps(tt, "editor", "ui")

tt.render.sprites[1].prefix = "DLCstage5_deco_modosDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_stage_27_modes_decos.update
tt.ui.can_click = true
tt.ui.click_rect = r(-33, 60, 20, 20)
tt = E:register_t("decal_stage_27_beam", "decal_scripted")

E:add_comps(tt, "ui", "editor")

tt.render.sprites[1].prefix = "DLCstage5_enanos_vigaDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_BETWEEN
tt.main_script.update = scripts.decal_stage_27_beam.update
tt.ui.can_click = true
tt.ui.click_rect = r(-470, 200, 150, 60)
tt.sound_prefix = "Stage27BeamWorkersTap"
tt = E:register_t("decal_boss_grymbeard_area_attack", "decal_tween")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymbossdecalDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {fts(30), 255}, {fts(60), 0}}
tt.tween.remove = true
tt = E:register_t("decal_bullet_boss_grymbeard", "decal_tween")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymmissiledecalDef"
tt.render.sprites[1].name = "decal"
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {fts(30), 255}, {fts(60), 0}}
tt.tween.remove = true
tt = E:register_t("decal_bullet_boss_grymbeard_death_clone", "decal_stage_27_clone_dead")
tt.tween.props[1].keys = {{0, 255}, {1e+99, 255}}
tt = E:register_t("decal_bullet_boss_grymbeard_death_boss", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymbossflyDef"
tt.render.sprites[1].name = "land"
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_bullet_boss_grymbeard_death_scrap_1", "decal")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymdebree1Def"
tt.render.sprites[1].name = "land"
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_bullet_boss_grymbeard_death_scrap_2", "decal_bullet_boss_grymbeard_death_scrap_1")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymdebree2Def"

tt = E:register_t("decal_terrain_6_exodia_arm", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_arm"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.main_script.update = scripts.decal_terrain_6_exodia_part.update
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -5, 30, 20)
tt.sound_click = "Terrain6ExodiaPart"
tt = E:register_t("decal_terrain_6_exodia_arm_2", "decal_terrain_6_exodia_arm")
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_terrain_6_exodia_head", "decal_terrain_6_exodia_arm")
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_head"
tt = E:register_t("decal_terrain_6_exodia_leg", "decal_terrain_6_exodia_arm")
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_leg"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt = E:register_t("decal_terrain_6_exodia_leg_2", "decal_terrain_6_exodia_arm")
tt.render.sprites[1].prefix = "DLC_enanos_easter_egg_exodia_leg"
tt.render.sprites[1].flip_x = true
tt.ui.click_rect = r(-15, -5, 30, 30)

tt = E:register_t("ps_bullet_enemy_brute_welder_death_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "brute_welder_tank_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(23), fts(23)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 0)
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.scales_x = {0.9, 1.1}
tt = E:register_t("ps_enemy_scrap_speedster_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "scrap_speedster_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 100)
tt.particle_system.scales_y = {0.6, 1}
tt.particle_system.scales_x = {0.6, 1}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_bullet_enemy_darksteel_guardian_death_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "darksteel_guardian_dwatf_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 0)
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.scales_x = {0.9, 1.1}
tt = E:register_t("ps_enemy_darksteel_hulk_charge_a")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "darksteel_hulk_run_particle_a"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 4
tt.particle_system.track_offset = v(0, 0)
tt.particle_system.z = Z_DECALS
tt = E:register_t("ps_enemy_darksteel_hulk_charge_b")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "darksteel_hulk_run_particle_b"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 3
tt.particle_system.track_offset = v(0, 20)
tt.particle_system.animation_fps = 15
tt.particle_system.z = Z_DECALS
tt = E:register_t("ps_bullet_boss_machinist")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "dlc_dwarf_boss_operator_proytrail"
tt.particle_system.animated = false
tt.particle_system.emission_rate = 15
tt.particle_system.spin = {math.pi / 6, math.pi / 4}
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.particle_lifetime = {fts(25), fts(25)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {0.9, 1.2}
tt.particle_system.scales_y = {0.9, 1.2}
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_bullet_stage_25_torso_missile")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "DLC_stage_03_missile_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 0)
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.scales_x = {0.9, 1.1}
tt = E:register_t("ps_bullet_stage_27_scrap")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "dclenanos_stage05_ScrapProjectileTrail_asst_scrap_projectile_trail"
tt.particle_system.animated = false
tt.particle_system.emission_rate = 15
tt.particle_system.spin = {math.pi / 6, math.pi / 4}
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.particle_lifetime = {fts(25), fts(25)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {0.9, 1.2}
tt.particle_system.scales_y = {0.9, 1.2}
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_bullet_stage_27_tower_stun")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "boss_fx_scrap_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.emit_area_spread = v(10, 10)
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt.particle_system.scales_x = {0.9, 1.1}
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_bullet_boss_grymbeard_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "grymbeardbossLAYERS_missiletrail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = v(5, 5)
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_offset = v(0, 0)
tt.particle_system.scales_y = {0.9, 1.1}
tt.particle_system.scales_x = {0.9, 1.1}
tt.emit_offset_relative = v(0, 0)
tt = E:register_t("ps_bullet_boss_grymbeard_death_boss_trail", "ps_bullet_boss_grymbeard_trail")
tt.particle_system.name = "grymbeardbossLAYERS_flytrail_run"

tt = E:register_t("decal_scrap", "decal_scripted")

E:add_comps(tt, "tween")

b = balance.enemies.hammer_and_anvil.scrap
tt.render.sprites[1].prefix = "scrap_pile"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECT
tt.main_script.update = scripts.decal_scrap.update
tt.duration = b.duration
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = E:register_t("decal_ray_mad_tinkerer", "decal")

E:add_comps(tt)

b = balance.enemies.hammer_and_anvil.scrap
tt.render.sprites[1].prefix = "mad_tinkerer_skill_ray"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BULLETS
tt.duration = b.duration
tt = E:register_t("decal_scrap_bullet_mad_tinkerer", "decal")

E:add_comps(tt)

b = balance.enemies.hammer_and_anvil.scrap
tt.render.sprites[1].name = "mad_tinkerer_skill_projectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.duration = b.duration
tt = E:register_t("decal_enemy_darksteel_fist_stun", "decal_tween")
tt.render.sprites[1].name = "darksteel_fist_stun_floor_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.disabled = false
tt.tween.remove = true

tt = E:register_t("fx_enemy_common_clone_hit", "fx")
tt.render.sprites[1].name = "common_clone_hit_fx_idle"
tt = E:register_t("fx_enemy_darksteel_fist_hit", "fx")
tt.render.sprites[1].name = "darksteel_fist_hit_fx_idle"
tt = E:register_t("fx_enemy_darksteel_fist_area", "fx")

E:add_comps(tt, "main_script")

tt.render.sprites[1].name = "darksteel_fist_stun_explosion"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "darksteel_fist_stun_stones"
tt.render.sprites[2].z = Z_EFFECTS - 1
tt.main_script.insert = scripts.fx_enemy_darksteel_fist_area.insert
tt = E:register_t("fx_enemy_darksteel_guardian_hit_1", "fx")
tt.render.sprites[1].name = "darksteel_guardian_attack_1_hit_idle"
tt = E:register_t("fx_enemy_darksteel_guardian_hit_2", "fx")
tt.render.sprites[1].name = "darksteel_guardian_attack_2_hit_idle"
tt = E:register_t("fx_enemy_darksteel_anvil_hit", "fx")
tt.render.sprites[1].name = "darksteel_anvil_attack_hit_idle"
tt = E:register_t("fx_enemy_deformed_grymbeard_clone_shield", "fx")
tt.render.sprites[1].prefix = "clone_boss_shield"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 100
tt.render.sprites[1].scale = vv(0.9, 0.9)
tt.timed.runs = 1e+99
tt = E:register_t("fx_bullet_enemy_rolling_sentry", "fx")
tt.render.sprites[1].name = "rolling_sentry_hit_fx_idle"
tt = E:register_t("fx_boss_machinist_death_smoke", "fx")
tt.render.sprites[1].prefix = "dlcdwarfbossstage02_smokeDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_boss_machinist_death_particle", "fx")
tt.render.sprites[1].prefix = "dlcdwarfbossstage02_particleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true

tt = E:register_t("bullet_enemy_rolling_sentry", "bullet")
b = balance.enemies.hammer_and_anvil.rolling_sentry
tt.render = nil
tt.main_script.insert = scripts.invisible_bullet.insert
tt.main_script.update = scripts.invisible_bullet.update
tt.bullet.asymmetrical = true
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.damage_type = b.ranged_attack.damage_type
tt.bullet.hit_fx = "fx_bullet_enemy_rolling_sentry"

tt = E:register_t("bullet_enemy_brute_welder_death", "bullet")
b = balance.enemies.hammer_and_anvil.brute_welder

E:add_comps(tt, "force_motion")

tt.bullet.flight_time = fts(31)
tt.bullet.particles_name = "ps_bullet_enemy_brute_welder_death_trail"
tt.bullet.hit_fx = "fx_bullet_enemy_brute_welder_death_hit"
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.mod = "mod_bullet_enemy_brute_welder_death_stun"
tt.render.sprites[1].name = "brute_welder_tank_projectile"
tt.render.sprites[1].animated = false
tt.main_script.update = scripts.bullet_enemy_brute_welder_death.update
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.3
tt.initial_impulse_angle = 0
tt.force_motion.a_step = 5
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.sound_events.hit = "EnemyBruteWelderDeathImpact"
tt.mark_mod = "mod_bullet_enemy_brute_welder_death_mark"
tt.range = b.death_missile.range
tt = E:register_t("bullet_enemy_darksteel_guardian_death", "bomb")
b = balance.enemies.hammer_and_anvil.brute_welder

E:add_comps(tt, "force_motion")

tt.bullet.flight_time = fts(31)
tt.bullet.particles_name = "ps_bullet_enemy_darksteel_guardian_death_trail"
tt.bullet.ignore_hit_offset = true
tt.bullet.rotation_speed = 10 * FPS * math.pi / 180
tt.bullet.hit_decal = "decal_bullet_enemy_darksteel_guardian_death_clone"
tt.bullet.hit_fx = nil
tt.bullet.pop_chance = 0
tt.render.sprites[1].name = "darksteel_guardian_dwarf_projectile"
tt.render.sprites[1].animated = false
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.3
tt.initial_impulse_angle = 0
tt.force_motion.a_step = 5
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.sound_events.insert = "TowerRocketGunnersStingMissileCast"
tt.sound_events.hit = "TowerRocketGunnersStingMissileExplosion"
tt.range = b.death_missile.range
tt = E:register_t("bullet_boss_machinist", "bomb")
b = balance.enemies.hammer_and_anvil.boss_machinist.ranged_attack
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.damage_type = b.damage_type
tt.bullet.flight_time = fts(30)
tt.bullet.hit_fx = "fx_bullet_boss_machinist"
tt.bullet.pop_chance = 0.5
tt.bullet.particles_name = "ps_bullet_boss_machinist"
tt.bullet.hit_payload = "decal_scrap"
tt.sound_events.hit_water = nil
tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
tt.render.sprites[1].name = "dlc_dwarf_boss_operator_proy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = false
tt.sound_events.insert = "Stage24BFMachinistCannonCastShot"
tt.sound_events.hit = "Stage24BFMachinistCannonImpact"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt = E:register_t("bullet_stage_25_torso_missile", "bullet")
b = balance.enemies.hammer_and_anvil.brute_welder

E:add_comps(tt, "force_motion")

tt.bullet.flight_time = fts(31)
tt.bullet.particles_name = "ps_bullet_stage_25_torso_missile"
tt.bullet.hit_fx = "fx_bullet_stage_25_torso_missile_hit"
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.mod = "mod_stage_25_torso_missile_stun"
tt.render.sprites[1].name = "DLC_stage_03_missile_projectile"
tt.render.sprites[1].animated = false
tt.main_script.update = scripts.bullet_stage_25_torso_missile.update
tt.force_motion.a_step = 5
tt.force_motion.max_a = 2250
tt.force_motion.max_v = 750
tt.sound_events.hit = "Stage25MissileImpact"
tt.mark_mod = "mod_stage_25_torso_missile_mark"
tt.relative_to_source = false
tt.flight_positions = {
	v(749, 608),
	v(737, 635),
	v(707, 673),
	v(673, 695),
	v(615, 707),
	v(547, 701),
	v(472, 661),
	v(431, 627),
	v(390, 580),
	v(377, 510),
	v(437, 401),
	v(553, 412),
	v(573, 524),
	v(459, 595),
	v(389, 522)
}
tt = E:register_t("bullet_stage_27_clone_dead", "bomb")
tt.bullet.flight_time = fts(35)
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = "decal_stage_27_clone_dead"
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_radius = 0
tt.bullet.rotation_speed = 10 * FPS * math.pi / 180
tt.bullet.pop_chance = 0
tt.render.sprites[1].name = "cannonLAYERS_flyclone"
tt.render.sprites[1].animated = false
tt = E:register_t("bullet_stage_27_clone_alive", "bullet_stage_27_clone_dead")
tt.bullet.hit_decal = "decal_stage_27_clone_alive"
tt.bullet.hit_payload = "controller_spawn_enemy_common_clone"
tt = E:register_t("controller_spawn_enemy_common_clone")

E:add_comps(tt, "main_script", "pos")

tt.main_script.update = scripts.controller_spawn_enemy_common_clone.update
tt.spawn_t = "enemy_common_clone"
tt.spawn_delay = fts(32)
tt = E:register_t("bullet_stage_27_scrap", "bomb")
b = balance.specials.stage27_head.scrap_attack
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_bans = bor(F_ENEMY)
tt.bullet.flight_time = fts(60)
tt.bullet.hit_fx = "fx_bullet_stage_27_scrap"
tt.bullet.particles_name = "ps_bullet_stage_27_scrap"
tt.bullet.hit_payload = "decal_scrap"
tt.sound_events.hit_water = nil
tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
tt.render.sprites[1].name = "dclenanos_stage05_ScrapProjectile_asst_scrap"
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = false
tt.sound_events.insert = "TowerBallistaScrapBombCast"
tt.sound_events.hit = "TowerBallistaScrapBombExplosion"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt = E:register_t("bullet_stage_27_tower_stun", "bomb")
b = balance.specials.stage27_head
tt.bullet.flight_time = fts(60)
tt.bullet.particles_name = "ps_bullet_stage_27_tower_stun"
tt.bullet.hit_fx = "fx_bullet_stage_27_tower_stun"
tt.bullet.ignore_hit_offset = true
tt.bullet.mod = "mod_bullet_stage_27_tower_stun"
tt.bullet.align_with_trajectory = true
tt.render.sprites[1].name = "boss_fx_scrap_projectile"
tt.render.sprites[1].animated = false
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.bullet_stage_27_tower_stun.update
tt.sound_events.insert = "TowerRocketGunnersStingMissileCast"
tt.sound_events.hit = "TowerRocketGunnersStingMissileExplosion"
tt = E:register_t("bullet_boss_grymbeard", "bullet")
b = balance.enemies.hammer_and_anvil.boss_grymbeard.ranged_attack

E:add_comps(tt, "force_motion")

tt.bullet.flight_time = fts(31)
tt.bullet.particles_name = "ps_bullet_boss_grymbeard_trail"
tt.bullet.hit_fx = "fx_bullet_boss_grymbeard_hit"
tt.bullet.hit_decal = "decal_bullet_boss_grymbeard"
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "grymbeardbossLAYERS_missile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = true
tt.main_script.update = scripts.bullet_boss_grymbeard.update
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.3
tt.initial_impulse_angle = 0
tt.force_motion.a_step = 5
tt.force_motion.max_a = 1800
tt.force_motion.max_v = 450
tt.sound_events.insert = "Stage27BFGrymbeardRangedAttackCast"
tt.sound_events.hit = "Stage27BFGrymbeardRangedAttackImpact"
tt = E:register_t("bullet_boss_grymbeard_death_clone", "bullet_stage_27_clone_dead")
tt.bullet.flight_time = fts(32)
tt.bullet.hit_decal = "decal_bullet_boss_grymbeard_death_clone"
tt = E:register_t("bullet_boss_grymbeard_death_boss", "bullet_stage_27_clone_dead")
tt.bullet.flight_time = fts(40)
tt.bullet.hit_decal = "decal_bullet_boss_grymbeard_death_boss"
tt.bullet.align_with_trajectory = true
tt.bullet.particles_name = "ps_bullet_boss_grymbeard_death_boss_trail"
tt.render.sprites[1].prefix = "grymbeardbossLAYERS_flyboss"
tt.render.sprites[1].name = "fly"
tt.render.sprites[1].animated = true
tt = E:register_t("bullet_boss_grymbeard_death_scrap_1", "bullet_stage_27_clone_dead")
tt.bullet.hit_decal = "decal_bullet_boss_grymbeard_death_scrap_1"
tt.render.sprites[1].name = "dclenanos_stage05_grymdebree1_Asst_grymbeardebree1"
tt.render.sprites[1].animated = false
tt = E:register_t("bullet_boss_grymbeard_death_scrap_2", "bullet_boss_grymbeard_death_scrap_1")
tt.bullet.hit_decal = "decal_bullet_boss_grymbeard_death_scrap_2"
tt.render.sprites[1].name = "dclenanos_stage05_grymdebree2_asst_grym3_grymbearddebree2"

tt = E:register_t("decal_enemy_darksteel_guardian_legs", "decal_tween")
tt.render.sprites[1].name = "darksteel_guardian_creep_grave_loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {3, 0}}
tt.tween.remove = true
tt = E:register_t("decal_bullet_enemy_darksteel_guardian_death_clone", "decal_tween")
tt.render.sprites[1].name = "common_clone_creep_boss_fall"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {2, 255}, {3, 0}}
tt.tween.remove = true

tt = E:register_t("aura_enemy_brute_welder", "aura")
b = balance.enemies.hammer_and_anvil.brute_welder.basic_attack.flame
tt.aura.duration = b.duration
tt.aura.radius = b.radius
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED, F_AREA)
tt.aura.mod = "mod_burning_enemy_brute_welder"
tt.aura.cycle_time = b.cycle_time
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_burning_enemy_brute_welder", "modifier")
b = balance.enemies.hammer_and_anvil.brute_welder.basic_attack.burn

E:add_comps(tt, "dps", "render")

tt.modifier.duration = b.duration
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.cycle_time
tt.render.sprites[1].prefix = "brute_welder_attack_mod"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t("mod_enemy_darksteel_anvil_buff", "modifier")
b = balance.enemies.hammer_and_anvil.darksteel_anvil.aura

E:add_comps(tt, "render", "fast")

tt.main_script.insert = scripts.mod_enemy_darksteel_anvil_buff.insert
tt.main_script.update = scripts.mod_enemy_darksteel_anvil_buff.update
tt.main_script.remove = scripts.mod_enemy_darksteel_anvil_buff.remove
tt.modifier.use_mod_offset = true
tt.extra_armor = b.mod.extra_armor
tt.fast.factor = b.mod.speed_factor
tt.modifier.duration = b.mod.duration
tt.target_self = b.target_self
tt.render.sprites[1].prefix = "darksteel_anvil_skill_FX"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = v(0.5, 0.6)
tt = E:register_t("mod_enemy_darksteel_hulk_charge_enemy", "modifier")
b = balance.enemies.hammer_and_anvil.darksteel_hulk

E:add_comps(tt, "dps", "render")

tt.dps.damage_min = b.charge.damage_enemy_min
tt.dps.damage_max = b.charge.damage_enemy_max
tt.dps.damage_type = b.charge.damage_type
tt.dps.damage_every = fts(10)
tt.modifier.duration = fts(7)
tt.modifier.use_mod_offset = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].name = "darksteel_hulk_attack_hit_idle"
tt.render.sprites[1].loop = false
tt = E:register_t("mod_enemy_darksteel_hulk_charge_soldier", "mod_enemy_darksteel_hulk_charge_enemy")
b = balance.enemies.hammer_and_anvil.darksteel_hulk
tt.dps.damage_min = b.charge.damage_soldier_min
tt.dps.damage_max = b.charge.damage_soldier_max

tt = E:register_t("fx_bullet_enemy_brute_welder_death_hit", "fx")
tt.render.sprites[1].prefix = "brute_welder_tower_hit_fx"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_bullet_boss_machinist", "fx")
tt.render.sprites[1].prefix = "dlcdwarfbossstage02_particleDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_bullet_stage_25_torso_missile_hit", "fx")
tt.render.sprites[1].prefix = "DLC_stage_03_missile_hit"
tt.render.sprites[1].name = "run"

tt = E:register_t("fx_stage_27_cannon_shot", "fx")
tt.render.sprites[1].prefix = "dlcenanos_stage05_cannon_explosionDef"
tt.render.sprites[1].name = "shoot"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_stage_27_scrap", "fx")
tt.render.sprites[1].prefix = "dclenanos_stage05_ScrapProjectileFXDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_bullet_stage_27_scrap", "fx")
tt.render.sprites[1].prefix = "dclenanos_stage05_ScrapProjectileHitFXDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_bullet_stage_27_tower_stun", "fx")
tt.render.sprites[1].name = "boss_fx_scrap_hit"
tt = E:register_t("fx_bullet_boss_grymbeard_hit", "fx")
tt.render.sprites[1].prefix = "dclenanos_stage05_grymmissileDef"
tt.render.sprites[1].name = "explosion"
tt.render.sprites[1].exo = true

tt = E:register_t("fx_enemy_mad_tinkerer_hit", "fx")
tt.render.sprites[1].name = "mad_tinkerer_hit"

tt = E:register_t("aura_enemy_darksteel_anvil", "aura")
b = balance.enemies.hammer_and_anvil.darksteel_anvil.aura
tt.aura.duration = b.duration
tt.aura.radius = b.aura_radius
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_AREA)
tt.aura.mod = "mod_enemy_darksteel_anvil_buff"
tt.aura.cycle_time = b.cycle_time
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("aura_boss_machinist_burn", "aura")

E:add_comps(tt, "render", "tween")

b = balance.enemies.hammer_and_anvil.boss_machinist.fire_floor
tt.aura.damage_min = b.damage_min
tt.aura.damage_max = b.damage_max
tt.aura.damage_type = b.damage_type
tt.aura._radius = b.radius
tt.aura.radius = b.radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.cycle_time = b.cycle_time
tt.aura.duration = 1e+99
tt.aura.track_source = true
tt.aura.mod = "mod_boss_machinist_burn"
tt.main_script.insert = scripts.aura_apply_damage.insert
tt.main_script.update = scripts.aura_apply_damage.update
tt.aura_floor_t = "aura_boss_machinist_burn_floor"
tt.render.sprites[1].prefix = "dlcdwarfbossstage02_floorsmokeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].alpha = 0
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}

tt = E:register_t("mod_stage_22_tower_destroyed", "mod_hide_tower")

local b = balance.specials.stage22_tower_destroyed

E:add_comps(tt, "render")

tt.main_script.update = scripts.mod_stage_22_tower_destroyed.update
tt.main_script.remove = nil
tt.render.sid_holder = 1
tt.render.sprites[tt.render.sid_holder].name = "terrains_holders_0007"
tt.render.sprites[tt.render.sid_holder].animated = false
tt.render.sprites[tt.render.sid_holder].z = Z_DECALS
tt.render.sprites[tt.render.sid_holder].offset = v(0, 16)
tt.render.sid_flag = 2
tt.render.sprites[tt.render.sid_flag] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_flag].name = "terrains_holders_0019_flag"
tt.render.sprites[tt.render.sid_flag].animated = false
tt.render.sprites[tt.render.sid_flag].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_flag].offset = v(-1, 17)
tt.render.sid_exo = 3
tt.render.sprites[tt.render.sid_exo] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_exo].prefix = "animations_tower_killDef"
tt.render.sprites[tt.render.sid_exo].name = "idle"
tt.render.sprites[tt.render.sid_exo].exo = true
tt.render.sprites[tt.render.sid_exo].animated = true
tt.render.sprites[tt.render.sid_exo].draw_order = 20
tt.render.sprites[tt.render.sid_exo].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_exo].offset = v(-2, -15)
tt.sound_restore = "Stage22TowerRestore"
tt.repair_cost = b.repair_cost
tt.hand_decal_t = "decal_mod_stage_22_tower_stun_hand"
tt.skip_modifiers = {"mod_boss_crocs_tower_eat"}
tt.click_rect = r(-30, 0, 60, 46)
tt.menu_offset = v(0, 12)
tt = E:register_t("mod_boss_machinist_burn", "modifier")
b = balance.enemies.hammer_and_anvil.boss_machinist.fire_floor.burn

E:add_comps(tt, "dps", "render")

tt.modifier.duration = b.duration
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.cycle_time
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update

tt = E:register_t("bullet_darksteel_anvil", "arrow_fixed_height")
b = balance.enemies.hammer_and_anvil.darksteel_anvil
tt.bullet.flight_time = fts(8)
tt.bullet.damage_min = b.basic_ranged.damage_min
tt.bullet.damage_max = b.basic_ranged.damage_max
tt.bullet.damage_type = b.basic_ranged.damage_type
tt.bullet.fixed_height = 15
tt.bullet.g = -1.8 / (fts(1) * fts(1))
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.pop = nil
tt.bullet.hide_radius = 6
tt.bullet.prediction_error = false
tt.bullet.predict_target_pos = false
tt.bullet.hit_fx = "fx_enemy_darksteel_anvil_hit"
tt.render.sprites[1].name = "darksteel_anvil_attack_projectile"
tt.render.sprites[1].animated = true
tt.bullet.hide_radius = 0
tt.bullet.hit_distance = 20
tt.bullet.extend_particles_cutoff = true

tt = E:register_t("decal_stage_28_mask_1", "decal")
tt.render.sprites[1].name = "stage_28_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 106
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_28_mask_2", "decal")
tt.render.sprites[1].name = "stage_28_mask_02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_28_mask_3", "decal")
tt.render.sprites[1].name = "stage_28_mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_TOWER_BASES
tt = E:register_t("decal_stage_28_torches", "decal")
tt.render.sprites[1].prefix = "stage_28_antorchasDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 200
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_achievement_into_the_ogreverse", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-20, -40, 40, 50)
tt.main_script.update = scripts.decal_achievement_into_the_ogreverse.update
tt.render.sprites[1].name = "ogreverse_web"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "ogreverse_character"
tt.render.sprites[2].name = "cultist_idle"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].offset = v(0, 20)
tt.render.sprites[2].anchor = vv(0.5)
tt.render.sprites[2].sort_y_offset = -30
tt = E:register_t("decal_achievement_a_coon_of_surprises_fredo", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-20, -50, 40, 40)
tt.main_script.update = scripts.decal_achievement_a_coon_of_surprises.update
tt.give_achievement = true
tt.required_touches = 3
tt.change_z_time = fts(8)
tt.change_y_sort_offset = -160
tt.render.sid_animated = 2
tt.render.sprites[1].name = "coonsuprices_cuerdafredo"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].anchor = v(0.5, 0.11538461538461539)
tt.render.sprites[tt.render.sid_animated] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_fredo"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_animated].offset = v(5, 4)
tt.render.sprites[tt.render.sid_animated].anchor = v(0.5, 0.973404255319149)
tt = E:register_t("decal_achievement_a_coon_of_surprises_silksong", "decal_achievement_a_coon_of_surprises_fredo")

E:add_comps(tt, "ui")

tt.give_achievement = false
tt.change_z_time = fts(36)
tt.change_y_sort_offset = -400
tt.ui.click_rect = r(-18, -70, 40, 60)
tt.render.sprites[1].name = "coonsuprices_cuerdasilksong"
tt.render.sprites[1].anchor = v(0.5, 0.23958333333333334)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_silksong"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(2, -30)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)
tt = E:register_t("decal_achievement_a_coon_of_surprises_jarra", "decal_achievement_a_coon_of_surprises_fredo")

E:add_comps(tt, "ui")

tt.give_achievement = false
tt.change_z_time = fts(32)
tt.change_y_sort_offset = -210
tt.ui.click_rect = r(-20, -60, 47, 55)
tt.render.sprites[1].name = "coonsuprices_cuerdajarra"
tt.render.sprites[1].anchor = v(0.5, 0.23958333333333334)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_jarra"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(-2, -22)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)
tt = E:register_t("decal_achievement_a_coon_of_surprises_darkcrystal", "decal_achievement_a_coon_of_surprises_fredo")

E:add_comps(tt, "ui")

tt.give_achievement = false
tt.change_z_time = fts(37)
tt.change_y_sort_offset = -260
tt.ui.click_rect = r(-20, -80, 40, 80)
tt.render.sprites[1].name = "coonsuprices_cuerdadarkcrystal"
tt.render.sprites[1].anchor = v(0.5, 0.23958333333333334)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_darkcrystal"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(0, 0)
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)
tt = E:register_t("decal_achievement_a_coon_of_surprises_sheepy", "decal_achievement_a_coon_of_surprises_fredo")

E:add_comps(tt, "ui")

tt.give_achievement = false
tt.change_z_time = fts(30)
tt.change_y_sort_offset = -336
tt.ui.click_rect = r(-17, -60, 40, 70)
tt.render.sprites[1].name = "coonsuprices_cuerdadarkcrystal"
tt.render.sprites[1].anchor = v(0.5, 0.23958333333333334)
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_sheepy"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].offset = v(0, 0)
tt.render.sprites[tt.render.sid_animated].anchor = v(0.5, 0.5173913043478261)
tt = E:register_t("decal_achievement_a_coon_of_surprises_arak", "decal_achievement_a_coon_of_surprises_fredo")

E:add_comps(tt, "ui")

tt.give_achievement = false
tt.ui.click_rect = r(-20, -40, 62, 75)
tt.change_y_sort_offset = 0
tt.render.sid_animated = 1
tt.render.sprites[2] = nil
tt.render.sprites[tt.render.sid_animated].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_animated].prefix = "coonsuprices_arak"
tt.render.sprites[tt.render.sid_animated].name = "idle"
tt.render.sprites[tt.render.sid_animated].animated = true
tt.render.sprites[tt.render.sid_animated].anchor = vv(0.5)
tt = E:register_t("decal_achievement_lucas_spider", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.can_click = true
tt.ui.click_rect = r(-20, -10, 40, 40)
tt.main_script.update = scripts.decal_achievement_lucas_spider.update
tt.render.sprites[1].prefix = "export_easter_egg_lucas"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = vv(0.5)
tt = E:register_t("decal_stage_29_background_eyes", "decal")
tt.render.sprites[1].prefix = "spiders_stage29_eyes_stageDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("mask_stage_30_1", "decal")
tt.render.sprites[1].name = "stage_30_mask_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -60
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("mask_stage_30_2", "decal")
tt.render.sprites[1].name = "stage_30_mask_02"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -112
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("mask_stage_30_3", "decal")
tt.render.sprites[1].name = "stage_30_mask_03"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("mask_stage_30_4", "decal")
tt.render.sprites[1].name = "stage_30_mask_04"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("mask_stage_30_5", "decal")
tt.render.sprites[1].name = "stage_30_mask_05"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("decal_stage_30_door", "decal_scripted")
b = balance.specials.stage30_door
tt.render.sprites[1].prefix = "stage_30_spider_doorDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 100
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.decal_stage_30_door.update
tt.animation_idle_open = "idle2"
tt.animation_idle_closed = "idle1"
tt.animation_open = "open"
tt.animation_close = "close"
tt.waves = b

tt = E:register_t("mod_enemy_glarenwarden_melee_lifesteal", "modifier")
b = balance.enemies.arachnids.glarenwarden.basic_attack
tt.main_script.insert = scripts.mod_lifesteal_kr5.insert
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.heal_hp_damage_factor = b.lifesteal.damage_factor
tt.heal_hp_fixed = b.lifesteal.fixed_heal
tt.damage_type = b.damage_type
tt.only_predict_damage = true
tt.heal_fx = "fx_glarenwarden_healing"
tt.heal_fx_offset = v(0, 12)
tt = E:register_t("mod_test_head_pos_kr5", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = 5
tt.render.sprites[1].prefix = "poison"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].scale = vv(0.4)
tt.render.sprites[1].draw_order = 2

for i = 2, 20 do
	tt.render.sprites[i] = table.deepclone(tt.render.sprites[1])
	tt.render.sprites[i].r = math.rad(math.random(0, 360))
end

tt.position_test = "HEAD"
tt.main_script.update = scripts.mod_test_unit_pos_kr5.update
tt = E:register_t("mod_test_mod_pos_kr5", "mod_test_head_pos_kr5")
tt.position_test = "MOD"
tt = E:register_t("mod_test_hit_pos_kr5", "mod_test_head_pos_kr5")
tt.position_test = "HIT"
tt = E:register_t("mod_cultbrood_poison", "modifier")
b = balance.enemies.arachnids.cultbrood.poison_attack

E:add_comps(tt, "render", "dps")

tt.modifier.duration = b.poison.duration
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].name = "cultbrood_modifier_idle"
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_cultbrood_poison.update
tt.dps.damage_every = b.poison.damage_every
tt.dps.damage_max = b.poison.damage
tt.dps.damage_min = b.poison.damage
tt.dps.damage_type = b.poison.damage_type
tt.transformation_nodes_limit = b.transformation_nodes_limit
tt = E:register_t("mod_drainbrood_web", "modifier")
b = balance.enemies.arachnids.drainbrood.webspit

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_drainbrood_web.update
tt.main_script.remove = scripts.mod_stun.remove
tt.modifier.animation_phases = true
tt.modifier.duration = b.duration
tt.modifier.hide_target_delay = fts(0)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "drainblood_cucoon"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt = E:register_t("mod_boss_spider_queen_poison", "mod_poison")
b = balance.enemies.arachnids.boss_spider_queen.ranged_attack.poison
tt.dps.damage_every = b.damage_every
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.kill = true
tt.modifier.duration = b.duration
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "boss_effects_poison"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].size_names = {"idle", "idle", "idle"}
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = E:register_t("mod_boss_spider_queen_area_lifesteal_end", "modifier")
b = balance.enemies.arachnids.boss_spider_queen.drain_life.lifesteal_end
tt.main_script.insert = scripts.mod_boss_spider_queen_area_lifesteal.insert
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.heal_hp_damage_factor = b.damage_factor
tt.heal_hp_fixed = b.fixed_heal
tt.damage_type = b.damage_type
tt = E:register_t("mod_boss_spider_queen_area_lifesteal_loop", "modifier")
b = balance.enemies.arachnids.boss_spider_queen.drain_life.lifesteal_loop
tt.main_script.insert = scripts.mod_lifesteal_kr5.insert
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.heal_hp_damage_factor = b.damage_factor
tt.heal_hp_fixed = b.fixed_heal
tt.damage_type = b.damage_type
tt = E:register_t("mod_spider_web_sprint", "mod_slow")
b = balance.specials.terrain_7.spider_floor_webs
tt.slow.factor = b.sprint_factor
tt.modifier.duration = fts(5)
tt = E:register_t("mod_spider_web_slowness", "mod_spider_web_sprint")
b = balance.specials.terrain_7.spider_floor_webs
tt.slow.factor = b.slow_factor

tt = E:register_t("ps_spider_sister_bolt_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.45)
tt.particle_system.name = "spider_sister_fx_attack_1_projectile_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {0.8, 0.5}
tt = E:register_t("ps_boss_spider_queen_bolt_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "boss_effects_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(5), fts(12)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {0.8, 0.5}
tt.particle_system.alphas = {255, 0}
tt = E:register_t("ps_boss_spider_queen_lifesteal_trail_1")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "spider_queen_boss_effects_trail_0001"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 150
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_x = {1, 0.1}
tt.particle_system.scales_y = {1, 0.1}
tt.particle_system.alphas = {255, 0}
tt = E:register_t("ps_boss_spider_queen_lifesteal_trail_2")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "spider_queen_boss_effects_trail2_0001"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(2), fts(5)}
tt.particle_system.emission_rate = 150
tt.particle_system.z = Z_BULLET_PARTICLES + 1
tt.particle_system.scales_x = {1, 0.8, 0.1}
tt.particle_system.scales_y = {1, 0.8, 0.1}
tt.particle_system.alphas = {255, 170, 0}
tt = E:register_t("ps_boss_spider_queen_bullet_tower_stun_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "boss_effects_bolt_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(4), fts(4)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_x = {0.7, 0.1}
tt.particle_system.scales_y = {0.7, 0.1}
tt.particle_system.alphas = {255, 0}
tt = E:register_t("ps_boss_spider_queen_bullet_tower_stun_trail_2")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.name = "boss_effects_bolt_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 15
tt.particle_system.z = Z_BULLET_PARTICLES + 1
tt.particle_system.scales_x = {0.7, 0.1}
tt.particle_system.scales_y = {0.7, 0.1}
tt.particle_system.alphas = {255, 0}
tt = E:register_t("ps_bullet_soldier_priests_barrack_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "priest_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.particle_lifetime = {fts(7), fts(7)}
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_BULLET_PARTICLES

tt = E:register_t("fx_bullet_enemy_spider_priest_hit", "fx")
tt.render.sprites[1].name = "cultist_spider_spell_hit"
tt = E:register_t("spider_sister_bolt_hit_fx", "fx")
tt.render.sprites[1].name = "spider_sister_fx_attack_1_hit"
tt = E:register_t("fx_boss_spider_queen_bolt_hit", "fx")
tt.render.sprites[1].prefix = "boss_effects_hit"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_boss_spider_queen_lifesteal_healing", "fx")
tt.render.sprites[1].name = "boss_effects_healing"
tt = E:register_t("fx_boss_spider_queen_lifesteal_bleeding", "fx")
tt.render.sprites[1].prefix = "boss_effects_hit_drain"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].scale = vv(2)
tt = E:register_t("fx_boss_spider_queen_melee_hit", "fx")
tt.render.sprites[1].prefix = "boss_effects_hit"
tt.render.sprites[1].name = "run"
tt = E:register_t("fx_boss_spider_queen_melee_hit_decal", "fx")
tt.render.sprites[1].name = "boss_effects_decal_back"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 30
tt.render.sprites[1].offset = v(0, 20)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "boss_effects_decal_front_run"
tt.render.sprites[2].sort_y_offset = 0
tt = E:register_t("fx_glarenwarden_healing", "fx")
tt.render.sprites[1].name = "glarenwarden_healing_run"

tt = E:register_t("bullet_enemy_spider_priest", "bolt_enemy")
b = balance.enemies.arachnids.spider_priest
tt.render.sprites[1].prefix = "cultist_spider_projectile"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_type = b.ranged_attack.damage_type
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_bullet_enemy_spider_priest_hit"
tt.bullet.particles_name = "ps_bullet_enemy_spider_priest"
tt = E:register_t("spider_sister_bolt", "bolt_enemy")

local b = balance.enemies.arachnids.spider_sister

tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "spider_sister_fx_attack_1_projectile"
tt.bullet.hit_fx = "spider_sister_bolt_hit_fx"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.5
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_spider_sister_bolt_trail"
tt.bullet.damage_type = b.ranged_attack.damage_type
tt.sound_events.insert = "EnemySpiderSisterRange"
tt = E:register_t("boss_queen_spider_bolt", "bolt_enemy")

local b = balance.enemies.arachnids.boss_spider_queen

tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = "boss_effects_bolt_magic"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].anchor = vv(0.5)
tt.bullet.hit_fx = "fx_boss_spider_queen_bolt_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.5
tt.bullet.damage_min = b.ranged_attack.damage_min
tt.bullet.damage_max = b.ranged_attack.damage_max
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_boss_spider_queen_bolt_trail"
tt.bullet.damage_type = b.ranged_attack.damage_type
tt.bullet.mod = "mod_boss_spider_queen_poison"
tt.sound_events.insert = "Stage30BossfightRange"

tt = E:register_t("mod_boss_spider_queen_tower_debuff", "modifier")
b = balance.enemies.arachnids.boss_spider_queen.stun_towers
E:add_comps(tt, "render", "ui")
if IS_CONSOLE then
	E:add_comps(tt, "tween")
end
tt.main_script.insert = scripts.mod_boss_spider_queen_tower_debuff.insert
tt.main_script.update = scripts.mod_boss_spider_queen_tower_debuff.update
tt.modifier.duration = b.duration
tt.modifier.duration_long = b.duration_long
tt.render.sid_mask = 1
tt.render.sprites[tt.render.sid_mask].prefix = "spider_queen_animations_stunDef"
tt.render.sprites[tt.render.sid_mask].name = "in"
tt.render.sprites[tt.render.sid_mask].exo = true
tt.render.sprites[tt.render.sid_mask].animated = true
tt.render.sprites[tt.render.sid_mask].loop = false
tt.render.sprites[tt.render.sid_mask].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_mask].offset = v(0, 30)
tt.render.sprites[tt.render.sid_mask].sort_y_offset = -5
tt.render.sprites[tt.render.sid_mask].pos = v(0, 0)
tt.threads_separation = 38
tt.threads_amount = math.ceil(REF_H / tt.threads_separation)
tt.threads_idles = {"idle1", "idle1", "idle2", "idle3", "idle4", "idle4"}
tt.render.sid_threads_start = 2
tt.render.sid_threads_end = tt.render.sid_threads_start + tt.threads_amount * 3 - 1
tt.spiders_offsets = {{
	x = -17,
	y = 0
}, {
	x = 0,
	y = 30
}, {
	x = 17,
	y = -10
}}

for i1 = 1, 3 do
	for i2 = 1, tt.threads_amount do
		local s = E:clone_c("sprite")

		s.prefix = "glarewarden_web_spiderweb"
		s.name = tt.threads_idles[1]
		s.loop = false
		s.anchor.y = 0
		s.offset.x = tt.spiders_offsets[i1].x
		s.offset.y = (i2 - 1) * tt.threads_separation + tt.spiders_offsets[i1].y
		s.z = Z_OBJECTS
		s.sort_y_offset = -s.offset.y
		s.group = "threads"
		tt.render.sprites[tt.render.sid_threads_start + tt.threads_amount * (i1 - 1) + i2 - 1] = s
	end
end

tt.render.sid_spiders_start = tt.render.sid_threads_end + 1
tt.render.sid_spiders_end = tt.render.sid_spiders_start + 2

for i = tt.render.sid_spiders_start, tt.render.sid_spiders_end do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].prefix = "boss_spider_minispider_tower_stun_spider"
	tt.render.sprites[i].name = "climbDown"
	tt.render.sprites[i].offset = v(tt.spiders_offsets[i - tt.render.sid_spiders_start + 1].x, tt.spiders_offsets[i - tt.render.sid_spiders_start + 1].y + 30)
	tt.render.sprites[i].group = "spiders"
end

tt.render.sid_hand = tt.render.sid_spiders_end + 1
tt.render.sprites[tt.render.sid_hand] = CC("sprite")
tt.render.sprites[tt.render.sid_hand].name = "spider_queen_tap"
tt.render.sprites[tt.render.sid_hand].offset = v(10, 20)
tt.render.sprites[tt.render.sid_hand].draw_order = 11
tt.render.sprites[tt.render.sid_hand].hidden = true
tt.render.sprites[tt.render.sid_hand].z = Z_OBJECTS_COVERS
tt.required_clicks = IS_PHONE_OR_TABLET and b.required_clics_phone_tablet or IS_CONSOLE and b.required_clics_console or b.required_clics_desktop
tt.tap_fx = "fx_boss_spider_queen_melee_hit"
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.ui.z = 1

tt = E:register_t("bullet_soldier_priests_barrack", "bolt")
b = balance.specials.towers.tower_stage_28_priests_barrack.priest.ranged
tt.render.sprites[1].name = "priest_projectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.align_with_trajectory = true
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.bullet.particles_name = "ps_bullet_soldier_priests_barrack_trail"
tt.bullet.hit_fx = "fx_soldier_priests_barrack_bolt_hit"
tt = E:register_t("bullet_boss_spider_queen_tower_stun", "bomb")
tt.main_script.update = scripts.bullet_boss_spider_queen_tower_stun.update
tt.bullet.flight_time = fts(35)
tt.bullet.vis_flags = bor(F_RANGED, F_MOD)
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "boss_effects_bolt"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].scale = vv(0.7)
tt.bullet.hit_fx = nil
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.hit_mod = "mod_boss_spider_queen_tower_debuff"
tt.bullet.particles_name = "ps_boss_spider_queen_bullet_tower_stun_trail"
tt.bullet.particles_name_2 = "ps_boss_spider_queen_bullet_tower_stun_trail_2"
tt.bullet.align_with_trajectory = true
tt = E:register_t("bullet_boss_spider_queen_lifesteal", "bomb")
tt.main_script.update = scripts.bullet_boss_spider_queen_tower_stun.update
tt.bullet.flight_time = fts(10)
tt.bullet.vis_flags = bor(F_RANGED, F_MOD)
tt.bullet.vis_bans = 0
tt.render.sprites[1].name = "spider_queen_boss_effects_trail2_0001"
tt.render.sprites[1].animated = false
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.particles_name = "ps_boss_spider_queen_lifesteal_trail_1"
tt.bullet.particles_name_2 = "ps_boss_spider_queen_lifesteal_trail_2"
tt.bullet.hit_fx = "fx_boss_spider_queen_lifesteal_healing"
tt.bullet.align_with_trajectory = true
tt = E:register_t("aura_tower_holder_capture", "aura")
tt.aura.duration = -1
tt.aura.radius = 150
tt.aura.track_source = true
tt.aura.vis_bans = 0
tt.aura.vis_flags = bor(F_HERO)
tt.aura.cycle_time = 0.2
tt.capture_multiplier = 1
tt.capture_default_increment = nil
tt.capture_default_decrement = nil
tt.capture_default_decrement_multiplier = 0.5
tt.main_script.update = scripts.aura_tower_holder_capture.update

tt = E:register_t("ps_bullet_enemy_spider_priest")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "cultist_spider_projectile_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.particle_lifetime = {fts(6), fts(6)}

tt = E:register_t("fx_soldier_priests_barrack_melee_hit", "fx")
tt.render.sprites[1].name = "priest_melee_hit"
tt.render.sprites[1].sort_y_offset = -30
tt = E:register_t("fx_soldier_priests_barrack_abomination_melee_hit", "fx")
tt.render.sprites[1].name = "redemeed_cultist_barraca_unblinded_abomination_hit_fx_idle"
tt.render.sprites[1].sort_y_offset = -30
tt = E:register_t("fx_soldier_priests_barrack_abomination_eat", "fx")
tt.render.sprites[1].name = "redemeed_cultist_barraca_unblinded_abomination_eat_fx"
tt.render.sprites[1].sort_y_offset = -30
tt = E:register_t("fx_soldier_priests_barrack_bolt_hit", "fx")
tt.render.sprites[1].name = "priest_ranged_hit_idle"

tt = E:register_t("aura_boss_spider_queen_spiderweb", "aura")
b = balance.enemies.arachnids.boss_spider_queen.spiderweb
tt.aura.track_source = true
tt.aura.cycle_time = b.cycle_time
tt.main_script.update = scripts.aura_boss_spider_queen_spiderweb.update
tt.min_decal_distance = b.min_distance
tt.decal = "decal_boss_spider_queen_spiderweb"
tt.decal_duration = b.duration
tt = E:register_t("aura_spider_webs_sprint", "aura")

AC(tt, "editor", "editor_script")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_spider_webs.update
tt.aura.ignore_flywalk = true
tt.aura.duration = -1
tt.aura.mod = "mod_spider_web_sprint"
tt.aura.radius = 80
tt.aura.cycle_time = fts(3)
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.allowed_templates = {
	"enemy_spiderling",
	"enemy_spider_priest",
	"enemy_glarenwarden",
	"enemy_ballooning_spider",
	"enemy_ballooning_spider_flyer",
	"enemy_spider_sister",
	"enemy_cultbrood",
	"enemy_drainbrood",
	"enemy_spidead",
	"hero_spider",
	"soldier_hero_spider_ultimate"
}
tt.editor.components = {"render"}
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false,
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_red_circle"
}
tt.editor.props = {{"aura.radius", PT_NUMBER}}
tt.editor_script.update = scripts.editor_aura_spider_web_sprint.update
tt = E:register_t("aura_spider_webs_slowness", "aura_spider_webs_sprint")
tt.aura.allowed_templates = nil
tt.aura.mod = "mod_spider_web_slowness"
tt.aura.vis_bans = bor(F_ENEMY, F_FLYING)
tt.aura.excluded_templates = {"hero_spider", "soldier_hero_spider_ultimate", "hero_witch", "hero_space_elf"}

tt = E:register_t("controller_stage_29_spider_holders", "decal_scripted")

E:add_comps(tt, "editor", "ui")

b = balance.specials.stage29_holder_block
tt.main_script.update = scripts.controller_stage_29_spider_holders.update
tt.render.sprites[1].prefix = "spiderholder_spiderholder"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.4)
tt.render.sprites[1].name = "climbing_up_idle"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.waves = b.waves
tt.first_cooldown = b.first_cooldown
tt.cooldown = b.cooldown
tt.max_casts = b.max_casts
tt.game_start_blocked_holders = b.game_start_blocked_holders
tt.time_to_down = b.time_to_down
tt.time_to_up = b.time_to_up
tt.time_netting = b.time_netting
tt.taps_to_cancel = b.taps_to_cancel
tt.hand_decal_t = "decal_mod_stage_29_holder_block_hand"
tt.ui.click_rect = r(-35, -40, 70, 70)
tt.vis_bans = 0
tt.vis_flags = 0
tt.threads_separation = 38
tt.threads_amount = math.ceil(REF_H / tt.threads_separation)
tt.threads_idles = {"idle1", "idle1", "idle2", "idle3", "idle4", "idle4"}

for i = 1, tt.threads_amount do
	local s = E:clone_c("sprite")

	s.prefix = "glarewarden_web_spiderweb"
	s.name = tt.threads_idles[1]
	s.loop = false
	s.anchor.y = 0
	s.offset.y = (i - 1) * tt.threads_separation
	s.z = Z_OBJECTS_SKY - 1
	s.hidden = true
	tt.render.sprites[i + 1] = s
end

tt.sound_loop = "EnemySpidersMechanicTowerSpiderWorkingLoop"
tt.sound_death = "EnemySpidersMechanicTowerSpiderDeath"
tt = E:register_t("tower_holder_pre_blocked_spiders", "decal_scripted")
tt.render.sprites[1].name = "terrains_holders_00017_flag"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.3)
tt = E:register_t("controller_stage_30_boss_spiders", "decal_scripted")

E:add_comps(tt, "editor")

b = balance.enemies.arachnids.boss_spider_queen
tt.main_script.update = scripts.controller_stage_30_boss_spiders.update
tt.spawn_path = b.spawn_path
tt.spawn_node = b.spawn_node
tt.render.sid_queen_podium = 1
tt.wave_spawns = b.wave_spawns
tt.wave_spawns_impossible = b.wave_spawns_impossible
tt.wave_spawns_object = "glarenwarden_thread_spawner"
tt.render.sprites[tt.render.sid_queen_podium].prefix = "spiderqueen_spider_queenDef"
tt.render.sprites[tt.render.sid_queen_podium].animated = true
tt.render.sprites[tt.render.sid_queen_podium].exo = true
tt.render.sprites[tt.render.sid_queen_podium].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_queen_podium].name = "walk"
tt.render.sprites[tt.render.sid_queen_podium].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_queen_podium].sort_y_offset = 0
tt.render.sid_jump = 2
tt.render.sprites[tt.render.sid_jump] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[tt.render.sid_jump].prefix = "spiderqueen_queen_assetDef"
tt.render.sprites[tt.render.sid_jump].hidden = true
tt.render.sprites[tt.render.sid_jump].name = "in"
tt.render.sid_land = 3
tt.render.sprites[tt.render.sid_land] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[tt.render.sid_land].prefix = "spiderqueen_spider_jumpDef"
tt.render.sid_smoke = 4
tt.render.sprites[tt.render.sid_smoke] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[tt.render.sid_smoke].prefix = "spiderqueen_smokeDef"

tt = E:register_t("stage_29_cocoon", "decal_scripted")

E:add_comps(tt, "spawner")

tt.render.sprites[1].prefix = "cocon_stage2_coocoon"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.animation_spawner_start = "summon_in"
tt.animation_spawner_idle = "idle_anim"
tt.animation_spawner_end = "summon_out"
tt.animation_spawner_idle_broken = "idle_broken"
tt.broken_on_heroic = true
tt.broken_on_iron = true
tt.main_script.update = scripts.stage_29_cocoon.update
tt.spawn_data = nil
tt.spawner.eternal = true
tt.sound_inflate = "EnemySpidersMechanicSpawnerInflate"
tt.sound_explode = "EnemySpidersMechanicSpawnerExplode"
tt.sound_regenerate = "EnemySpidersMechanicSpawnerRegenerate"

tt = E:register_t("decal_mod_stage_29_holder_block_hand", "decal_tween")
tt.render.sprites[1].prefix = "spiderholder_block_tap"
tt.render.sprites[1].name = "tap"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].offset = v(23, 50)
tt.tween.props[1].keys = {{0, 0}, {fts(15), 255}, {fts(45), 255}, {fts(60), 0}}
tt.tween.remove = true

tt = E:register_t("tower_holder_blocked_spiders", "tower_holder_blocked_2")
E:add_comps(tt, "main_script")
b = balance.specials.stage29_holder_block.blocked_holders
tt.main_script.insert = scripts.tower_holder_blocked_spiders.insert
tt.tower.type = "holder_blocked_spiders"
tt.tower_holder.unblock_price = b.price[1]
tt.prices = b.price
tt.render.sprites[1].name = "build_terrain_blocked_0003"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "terrains_holders_0018_flag_blocked"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 17)

tt = E:register_t("glarenwarden_thread_spawner", "decal_scripted")
AC(tt, "nav_path", "motion", "spawner", "sound_events")
tt.spawn = "enemy_glarenwarden"
tt.main_script.insert = scripts.glarenwarden_thread_spawner.insert
tt.main_script.update = scripts.glarenwarden_thread_spawner.update
tt.sound_events.insert = "ElvesCreepSonOfMactansLanding"
tt.render.sprites[1].prefix = "glarenwarden_creep"
tt.render.sprites[1].name = "descending_loop"
tt.render.sprites[1].offset.y = 0
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.threads_separation = 38
tt.threads_amount = math.ceil(REF_H / tt.threads_separation)
tt.threads_idles = {"idle1", "idle1", "idle2", "idle3", "idle4", "idle4"}

for i = 1, tt.threads_amount do
	local s = E:clone_c("sprite")
	s.prefix = "glarewarden_web_spiderweb"
	s.name = tt.threads_idles[1]
	s.loop = false
	s.anchor.y = 0
	s.offset.y = (i - 1) * tt.threads_separation
	s.z = Z_OBJECTS_SKY - 1
	tt.render.sprites[i + 1] = s
end

tt = RT("controller_stage_31_water_mechanic", "decal_scripted")

AC(tt, "ui", "editor")

b = balance.specials.stage31_water_mechanic
tt.main_script.update = scripts.controller_stage_31_water_mechanic.update
tt.duration = b.duration
tt.cooldown = b.cooldown
tt.path = b.path
tt.nodes = b.nodes
tt.warn_duration = b.warn_duration
tt.unlock_wave = b.unlock_wave
tt.spawn_every_nodes = 9
tt.check_every = 3
tt.check_radius = 60
tt.first_warn_minimum_targets = b.first_warn_minimum_targets
tt.fx_entity = "stage_31_water_mechanic_fx"
tt.fx_entity_decal = "stage_31_water_mechanic_fx_decal"
tt.hand_decal_t = "dlc2_generic_tap_hand"
tt.sound_tap = nil
tt.render.sprites[1].prefix = "fuente_unitDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "water_cracksDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].exo = true
tt.render.sprites[2].sort_y_offset = 0
tt.render.sprites[2].z = Z_DECALS - 1
tt.render.sprites[2].pos = v(512, 384)
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.has_nav_mesh = true
tt.ui.click_rect = r(-50, -90, 103, 190)
tt.extra_ui_click_rects = {r(-120, -60, 243, 120), r(-85, -80, 173, 160)}
tt.extra_ui_click_rect_speach_bubble = r(50, 58, 78, 67)
tt.mods = {"mod_stage31_water_mechanic_dps"}
tt.enemies_detection = {"enemy_fire_phoenix", "enemy_fire_fox", "enemy_nine_tailed_fox", "enemy_burning_treant", "enemy_ash_spirit"}
tt = RT("generic_extra_touch_controller")

AC(tt, "pos", "ui", "main_script")

tt.main_script.update = scripts.generic_extra_touch_controller.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.has_nav_mesh = false
tt = RT("stage_31_water_mechanic_fx", "decal_scripted")
tt.main_script.update = scripts.stage_31_water_mechanic_fx.update
tt.render.sprites[1].prefix = "water_splash_unitDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("stage_31_water_mechanic_fx_decal", "decal_tween")

AC(tt, "main_script")

b = balance.specials.stage31_water_mechanic
tt.render.sprites[1].prefix = "charco_unitDef"
tt.render.sprites[1].name = "Idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.duration = b.duration
tt.added_scale = 1

function tt.main_script.insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.tween.ts = store.tick_ts
	this.render.sprites[1].flip_x = math.random() > 0.5

	local start_delay = math.random() * fts(8)

	this.tween.props[1].keys = {{0, 0}, {start_delay, 0}, {start_delay + fts(7), 255}, {start_delay + fts(7) + this.duration, 255}, {start_delay + fts(7) + this.duration + fts(27), 0}}
	this.tween.props[2].keys = {{0, vv(0.8 * this.added_scale)}, {start_delay, vv(0.8 * this.added_scale)}, {start_delay + fts(7), vv(1 * this.added_scale)}, {start_delay + fts(7) + this.duration, vv(1 * this.added_scale)}, {start_delay + fts(7) + this.duration + fts(27), vv(0.8 * this.added_scale)}}

	return true
end

tt.tween.props[1].keys = {{0, 0}, {fts(2), 0}, {fts(7), 255}, {fts(7) + tt.duration, 255}, {fts(7) + tt.duration + fts(27), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, vv(0.8)}, {fts(2), vv(0.8)}, {fts(7), vv(1)}, {fts(7) + tt.duration, vv(1)}, {fts(7) + tt.duration + fts(27), vv(0.8)}}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 1
tt.tween.remove = true
tt = E:register_t("decal_stage_31_easter_egg_oogway", "decal_scripted")

E:add_comps(tt, "ui", "editor")

tt.main_script.update = scripts.decal_stage_31_easter_egg_oogway.update
tt.render.sprites[1].prefix = "stage_31_oogwayDef"
tt.render.sprites[1].name = "idle1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.idle_cooldown_max = 20
tt.idle_cooldown_min = 5
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t("decal_stage_31_easter_egg_littledragon", "decal_scripted")

E:add_comps(tt, "ui", "editor")

tt.main_script.update = scripts.decal_stage_31_easter_egg_littledragon.update
tt.render.sprites[1].prefix = "littledragon_easteregg_stage1_easteregg"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -30
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "littledragon_easteregg_stage1_easter_egg_dead"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(5, -30)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "littledragon_easteregg_stage1_tree"
tt.render.sprites[3].animated = false
tt.render.sprites[3].anchor = v(0, 0)
tt.render.sprites[3].offset = v(-69, -23)
tt.render.sprites[3].z = Z_OBJECTS
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t("decal_stage_32_easter_egg_sheepy", "decal_scripted")

E:add_comps(tt, "ui", "editor")

tt.main_script.update = scripts.decal_stage_32_easter_egg_sheepy.update
tt.render.sprites[1].prefix = "sheepylava_sheepy"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "sheepylava_crater_1"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-45, -30)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "sheepylava_crater_2"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(-20, 0)
tt.render.sprites[3].sort_y_offset = 2
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "sheepylava_crater_3"
-- 铁皮此处代码基于bug运行，修复不了。
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].animated = true
tt.render.sprites[4].z = Z_OBJECTS
tt.render.sprites[4].offset = v(25, -20)
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t("decal_achievement_saitam_stage31", "decal_scripted")

E:add_comps(tt, "ui", "editor", "tween")

tt.main_script.update = scripts.decal_achievement_saitam.update
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(-30, 5)
tt.render.sprites[1].anchor = v(0.3333333333333333, 0.5222222222222223)
tt.ui.click_rect = r(-50, -5, 40, 30)
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.5, 0}}
tt = E:register_t("decal_achievement_saitam_stage32", "decal_achievement_saitam_stage31")
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_2"
tt = E:register_t("decal_achievement_saitam_stage33", "decal_achievement_saitam_stage31")
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_3"
tt = E:register_t("decal_achievement_saitam_stage34", "decal_achievement_saitam_stage31")
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_4"
tt = E:register_t("decal_achievement_saitam_stage35", "decal_achievement_saitam_stage31")
tt.render.sprites[1].prefix = "easter_egg_saitam_saitam_stage_5"
tt = E:register_t("dlc2_generic_tap_hand", "decal_tween")
tt.render.sprites[1].prefix = "dlc2_generic_tap_hand"
tt.render.sprites[1].name = "tap"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].offset = v(23, 10)
tt.tween.props[1].keys = {{0, 0}, {fts(15), 255}, {fts(15), 255}, {fts(60), 0}}
tt.tween.remove = true
tt = RT("controller_stage_33_lightning_strike")

AC(tt, "pos", "main_script", "editor", "editor_script")

b = balance.specials.stage32_lightning_strike
tt.main_script.update = scripts.controller_stage_33_lightning_strike.update
tt.force_target_soldier_chance = b.force_target_soldier_chance
tt.chain_strikes_chance = b.chain_strikes_chance
tt.max_chains = b.max_chains
tt.areas_configs = b.areas_configs
tt.strikes_spawn_radius = 100
tt.area_id = 1
tt.editor.components = {"render", "texts"}
tt.editor.overrides = {
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_cyan_circle"
}
tt.editor.props = {{"strikes_spawn_radius", PT_NUMBER}, {"area_id", PT_NUMBER}}
tt.editor_script.update = scripts.controller_stage_33_lightning_strike.editor_update
tt = RT("stage_33_lightning_strike", "decal_scripted")

AC(tt, "tween")

b = balance.specials.stage32_lightning_strike
tt.main_script.update = scripts.stage_33_lightning_strike.update
tt.damage_config = b.damage_config
tt.warning_duration = b.warning_duration
tt.render.sid_decal = 1
tt.render.sid_deco = 2
tt.render.sid_spawner = 3
tt.vis_bans = bor(F_FLYING, F_ENEMY)
tt.vis_flags = bor(F_AREA)
tt.render.sprites[tt.render.sid_decal] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_decal].prefix = "vfx_mecanicas_ray_decal"
tt.render.sprites[tt.render.sid_decal].name = "Idle"
tt.render.sprites[tt.render.sid_decal].hidden = true
tt.render.sprites[tt.render.sid_decal].loop = false
tt.render.sprites[tt.render.sid_decal].offset = v(0, -5)
tt.render.sprites[tt.render.sid_decal].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_deco] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_deco].prefix = "vfx_mecanicas_ray_deco"
tt.render.sprites[tt.render.sid_deco].name = "idle"
tt.render.sprites[tt.render.sid_deco].hidden = true
tt.render.sprites[tt.render.sid_deco].loop = false
tt.render.sprites[tt.render.sid_deco].offset = v(0, -5)
tt.render.sprites[tt.render.sid_deco].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_spawner] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_spawner].prefix = "vfx_mecanicas_ray_portal"
tt.render.sprites[tt.render.sid_spawner].name = "run"
tt.render.sprites[tt.render.sid_spawner].hidden = true
tt.render.sprites[tt.render.sid_spawner].loop = false
tt.render.sprites[tt.render.sid_spawner].offset = v(0, 0)
tt.render.sprites[tt.render.sid_spawner].z = Z_OBJECTS
tt.flash_delay_max = 0.3
tt.flash_delay_min = 0.1
tt.flash_duration_max = 0.3
tt.flash_duration_min = 0.2
tt.flash_l1_max_alphas = {180, 200}
tt.flash_l2_max_alpha = 70
tt.flash_l2_min_alpha = 60
tt.flash_delta = 0.02
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.4, 255}}
tt.tween.props[1].keys_end = {{0, 255}, {0.2, 255}, {0.4, 0}}
tt.tween.props[1].sprite_id = tt.render.sid_decal
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = tt.render.sid_deco
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].keys_end = {{0, 255}, {0.2, 0}, {0.4, 0}}
tt.tween.props[3].sprite_id = tt.render.sid_spawner
tt = E:register_t("stage_33_lightning_strike_overlay", "decal_tween")

E:add_comps(tt, "tween")

image_y = 64
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].scale = v(math.ceil(REF_H * 16 / 9 * 1.1 / image_y), math.ceil(REF_H / image_y))
tt.render.sprites[1].z = Z_OBJECTS_SKY + 2
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "square_ffffff"
tt.render.sprites[2].color = {184, 184, 184}
tt.render.sprites[2].alpha = 0
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.ts = 0
tt.cooldown = 0
tt = E:register_t("stage_33_lightning_strike_fx_power_thunder_1", "decal_tween")

E:add_comps(tt, "sound_events")

tt.image_h = 496
tt.render.sprites[1].name = "rayo_og_ray_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.props[1].keys = {{0, 255}, {fts(3), 255}, {fts(8), 0}}
tt.sound_events.insert = "Stage33StormLightning"
tt = E:register_t("stage_33_lightning_strike_fx_power_thunder_2", "stage_33_lightning_strike_fx_power_thunder_1")
tt.image_h = 456
tt.render.sprites[1].name = "rayo_og_ray_2"
tt = E:register_t("stage_33_lightning_strike_fx_power_thunder_explosion", "fx")
tt.render.sprites[1].name = "stage_33_lightning_strike_fx_power_thunder_explosion"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
tt = E:register_t("stage_33_lightning_strike_fx_power_thunder_explosion_decal", "fx")
tt.render.sprites[1].name = "stage_33_lightning_strike_fx_power_thunder_explosion_decal"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("controller_stage_32_lava_splash")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_32_lava_splash.update
tt.mod = "mod_stage_32_lava_splash"
tt.paths_y = {
	[2] = 560
}
tt.vis_flags = 0
tt.vis_bans = 0
tt = E:register_t("controller_stage_32_lava_splash_2", "controller_stage_32_lava_splash")
tt.mod = "mod_stage_32_lava_splash_2"
tt.paths_y = {
	[3] = 560
}
tt = E:register_t("controller_stage_34_ponds_spawner")

E:add_comps(tt, "main_script", "events")

tt.main_script.update = scripts.controller_stage_34_ponds_spawner.update
tt.unit_t = "enemy_water_spirit_spawnless"
tt.events.list[1].name = "pond_spawn_water_spirit"
tt.events.list[1].on_event = scripts.controller_stage_34_ponds_spawner.on_event
tt = E:register_t("controller_boss_princess_iron_fan_waves", "decal_scripted")

E:add_comps(tt, "main_script", "editor")

b = balance.enemies.wukong.boss_princess
tt.force_capture_hero = scripts.controller_boss_princess_iron_fan_waves.force_capture_hero
tt.force_go_middle = scripts.controller_boss_princess_iron_fan_waves.force_go_middle
tt.force_go_back = scripts.controller_boss_princess_iron_fan_waves.force_go_back
tt.main_script.update = scripts.controller_boss_princess_iron_fan_waves.update
tt.render.sid_unit = 1
tt.render.sprites[tt.render.sid_unit].prefix = "boss_princessDef"
tt.render.sprites[tt.render.sid_unit].exo = true
tt.render.sprites[tt.render.sid_unit].animated = true
tt.render.sprites[tt.render.sid_unit].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_unit].name = "idle"
tt.render.sprites[tt.render.sid_unit].z = Z_OBJECTS
tt.pos_sitting = v(1060, 405)
tt.pos_standing = v(605, 355)
tt.illusory_summon = b.waves.illusory_summon
tt.block_tower = b.waves.tower_curse
tt.block_tower_loop_duration = 3
tt.block_tower_mod = "boss_princess_iron_fan_tower_debuff"
tt.boss_unit_spawn = "boss_princess_iron_fan"
tt.stun_hero = b.waves.stun_hero
tt.stun_hero_decal = "decal_boss_princess_iron_fan_stun_heroes_waves"
tt.stun_hero_warning_duration = b.waves.stun_hero.WARNING_DURATION
tt.stun_hero_vis_flags = bor(F_MOD, F_STUN, F_AREA)
tt.stun_hero_vis_bans = bor(0)
tt.shield_duration = b.waves.shield.duration
tt.shield_decal = "decal_boss_princess_iron_fan_waves_shield"
tt.sound_teleport_in = "EnemyBossPrincessTeleportIn"
tt.sound_teleport_out = "EnemyBossPrincessTeleportOut"
tt.sound_stun_hero_channel = "EnemyBossPrincessHeroStunChannel"
tt.sound_stun_hero_fail = "EnemyBossPrincessHeroStunFail"
tt.sound_stun_hero_success = "EnemyBossPrincessHeroStunSuccess"
tt = E:register_t("controller_stage_33_ciclone", "decal_scripted")

E:add_comps(tt, "editor", "ui", "events")

tt.main_script.update = scripts.controller_stage_33_ciclone.update
tt.render.sid_tejas = 1
tt.render.sid_dirty = 2
tt.render.sid_shadow = 3
tt.render.sid_clouds_der = 4
tt.render.sid_clouds_izq = 5
tt.render.sid_shadow_2 = 6
tt.render.sid_clouds_fly = 7
tt.render.sid_shadows_fly = 8
tt.render.sid_storm_rayos = 9
tt.render.sid_tejas_puerta = 10
tt.render.sid_escombros = 11
tt.render.sprites[tt.render.sid_tejas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_tejas].prefix = "stage_33_tejasDef"
tt.render.sprites[tt.render.sid_tejas].animated = true
tt.render.sprites[tt.render.sid_tejas].exo = true
tt.render.sprites[tt.render.sid_tejas].name = "idle"
tt.render.sprites[tt.render.sid_tejas].z = Z_OBJECTS_COVERS
tt.render.sprites[tt.render.sid_tejas].group = "layers"
tt.render.sprites[tt.render.sid_tejas_puerta] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_tejas_puerta].prefix = "stage_33_tejas_puertaDef"
tt.render.sprites[tt.render.sid_tejas_puerta].animated = true
tt.render.sprites[tt.render.sid_tejas_puerta].exo = true
tt.render.sprites[tt.render.sid_tejas_puerta].name = "idle"
tt.render.sprites[tt.render.sid_tejas_puerta].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_dirty] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dirty].prefix = "stage_33_dirtyDef"
tt.render.sprites[tt.render.sid_dirty].animated = true
tt.render.sprites[tt.render.sid_dirty].exo = true
tt.render.sprites[tt.render.sid_dirty].name = "idle"
tt.render.sprites[tt.render.sid_dirty].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_dirty].group = "layers"
tt.render.sprites[tt.render.sid_shadow] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow].prefix = "stage_33_shadow_screenDef"
tt.render.sprites[tt.render.sid_shadow].animated = true
tt.render.sprites[tt.render.sid_shadow].exo = true
tt.render.sprites[tt.render.sid_shadow].name = "idle"
tt.render.sprites[tt.render.sid_shadow].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_shadow].group = "layers"
tt.render.sprites[tt.render.sid_shadows_fly] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadows_fly].prefix = "stage_33_shadows_flyDef"
tt.render.sprites[tt.render.sid_shadows_fly].animated = true
tt.render.sprites[tt.render.sid_shadows_fly].exo = true
tt.render.sprites[tt.render.sid_shadows_fly].name = "idle"
tt.render.sprites[tt.render.sid_shadows_fly].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_der] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_der].prefix = "stage_33_storm_clouds_derDef"
tt.render.sprites[tt.render.sid_clouds_der].animated = true
tt.render.sprites[tt.render.sid_clouds_der].exo = true
tt.render.sprites[tt.render.sid_clouds_der].name = "in"
tt.render.sprites[tt.render.sid_clouds_der].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_der].group = "layers"
tt.render.sprites[tt.render.sid_clouds_izq] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_izq].prefix = "stage_33_storm_clouds_izqDef"
tt.render.sprites[tt.render.sid_clouds_izq].animated = true
tt.render.sprites[tt.render.sid_clouds_izq].exo = true
tt.render.sprites[tt.render.sid_clouds_izq].name = "in"
tt.render.sprites[tt.render.sid_clouds_izq].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_izq].group = "layers"
tt.render.sprites[tt.render.sid_storm_rayos] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_storm_rayos].prefix = "stage_33_storm_rayosDef"
tt.render.sprites[tt.render.sid_storm_rayos].animated = true
tt.render.sprites[tt.render.sid_storm_rayos].exo = true
tt.render.sprites[tt.render.sid_storm_rayos].name = "in"
tt.render.sprites[tt.render.sid_storm_rayos].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_storm_rayos].group = "layers"
tt.render.sprites[tt.render.sid_clouds_fly] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_clouds_fly].prefix = "stage_33_clouds_flyDef"
tt.render.sprites[tt.render.sid_clouds_fly].animated = true
tt.render.sprites[tt.render.sid_clouds_fly].exo = true
tt.render.sprites[tt.render.sid_clouds_fly].name = "idle"
tt.render.sprites[tt.render.sid_clouds_fly].z = Z_OBJECTS_SKY
tt.render.sprites[tt.render.sid_clouds_fly].group = "layers"
tt.render.sprites[tt.render.sid_shadow_2] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow_2].prefix = "stage_33_storm_shadowDef"
tt.render.sprites[tt.render.sid_shadow_2].animated = true
tt.render.sprites[tt.render.sid_shadow_2].exo = true
tt.render.sprites[tt.render.sid_shadow_2].name = "loop"
tt.render.sprites[tt.render.sid_shadow_2].z = Z_OBJECTS_SKY + 1
tt.render.sprites[tt.render.sid_escombros] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_escombros].prefix = "stage33_explosion_escombrosDef"
tt.render.sprites[tt.render.sid_escombros].animated = true
tt.render.sprites[tt.render.sid_escombros].exo = true
tt.render.sprites[tt.render.sid_escombros].name = "idle"
tt.render.sprites[tt.render.sid_escombros].z = Z_DECALS
tt.render.sprites[tt.render.sid_escombros].hidden = true
tt.events.list[1].name = "ciclone"
tt.events.list[1].on_event = scripts.controller_stage_33_ciclone.on_event
tt = E:register_t("controller_stage_33_house_doors")

E:add_comps(tt, "main_script")

tt.main_script.insert = scripts.controller_stage_33_house_doors.insert
tt.citizen_spawned = scripts.controller_stage_33_house_doors.citizen_spawned
tt.door_positions = {{
	template = "stage_33_citizen_house_1",
	pos = v(72, 348)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(197, 348)
}, {
	template = "stage_33_citizen_house_1",
	pos = v(235, 693)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(387, 693)
}, {
	template = "stage_33_citizen_house_1",
	pos = v(799, 692)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(925, 696)
}, {
	template = "stage_33_citizen_house_2",
	pos = v(1030, 348)
}}
tt = E:register_t("controller_stage_33_boat", "decal_scripted")
tt.main_script.update = scripts.controller_stage_33_boat.update

E:add_comps(tt, "events")

tt.render.sid_boat = 1
tt.render.sid_sail = 2
tt.render.sprites[tt.render.sid_boat].prefix = "stage_3_barcoDef"
tt.render.sprites[tt.render.sid_boat].animated = true
tt.render.sprites[tt.render.sid_boat].exo = true
tt.render.sprites[tt.render.sid_boat].name = "idle"
tt.render.sprites[tt.render.sid_boat].z = Z_DECALS
tt.render.sprites[tt.render.sid_boat].hidden = true
tt.render.sprites[tt.render.sid_sail] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_sail].prefix = "stage_3_barco_velaDef"
tt.render.sprites[tt.render.sid_sail].animated = true
tt.render.sprites[tt.render.sid_sail].exo = true
tt.render.sprites[tt.render.sid_sail].name = "idle"
tt.render.sprites[tt.render.sid_sail].z = Z_DECALS
tt.render.sprites[tt.render.sid_boat].hidden = true
tt.events.list[1].name = "boat"
tt.events.list[1].on_event = scripts.controller_stage_33_boat.on_event
tt = RT("controller_stage_33_tambor", "decal_scripted")
tt.do_tambor = scripts.controller_stage_33_tambor.do_tambor
tt.main_script.update = scripts.controller_stage_33_tambor.update
tt.render.sprites[1].prefix = "stage_33_barco_call_tambor"
tt.render.sprites[1].name = "idle_tambor"
tt.render.sprites[1].anchor = v(0.05777310924369748, 0.55625)
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].group = "group"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage_33_barco_call_body"
tt.render.sprites[2].anchor = v(0.11346863468634687, 0.5290697674418605)
tt.render.sprites[2].sort_y_offset = -49
tt = E:register_t("boss_princess_iron_fan", "boss")
b = balance.enemies.wukong.boss_princess.bossfight

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(45, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 1e+99
tt.health_bar.offset = v(0, 90)
tt.unit.hit_offset = v(-5, 30)
tt.unit.head_offset = v(-2, 20)
tt.unit.mod_offset = v(-5, 30)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-35, 0, 60, 80)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_RED
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_BOSS_PRINCESS_IRON_FAN"
tt.info.enc_icon = 117
tt.info.portrait = "kr5_info_portraits_enemies_0122"
tt.info.portrait_boss = "boss_health_bar_icon_0012"
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.render.sid_unit = 1
tt.render.sprites[tt.render.sid_unit].prefix = "boss_princessDef"
tt.render.sprites[tt.render.sid_unit].exo = true
tt.render.sprites[tt.render.sid_unit].animated = true
tt.render.sprites[tt.render.sid_unit].name = "idle"
tt.render.sprites[tt.render.sid_unit].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_unit].angles = {}
tt.render.sprites[tt.render.sid_unit].angles.walk = {"walk", "walk_back", "walk_front"}
tt.unit.show_blood_pool = false
tt.spawn_pos = b.spawn_pos
tt.health.on_damage = scripts.boss_princess_iron_fan.on_damage
tt.main_script.insert = scripts.boss_princess_iron_fan.insert
tt.main_script.update = scripts.boss_princess_iron_fan.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].hit_times = {fts(12), fts(18), fts(25)}
tt.melee.attacks[1].hit_decal = "fx_boss_spider_queen_melee_hit_decal"
tt.melee.attacks[1].sound = "EnemyBossPrincessMelee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.area_attack.cooldown
tt.melee.attacks[2].damage_max = b.area_attack.damage_max
tt.melee.attacks[2].damage_min = b.area_attack.damage_min
tt.melee.attacks[2].damage_type = b.area_attack.damage_type
tt.melee.attacks[2].damage_radius = b.area_attack.radius
tt.melee.attacks[2].animation = "attack_area"
tt.melee.attacks[2].hit_time = fts(28)
tt.melee.attacks[2].hit_fx = "fx_boss_spider_queen_melee_hit"
tt.melee.attacks[2].hit_fx_offset = v(55, 10)
tt.melee.attacks[2].hit_decal = "fx_boss_princess_iron_fan_area_attack"
tt.melee.attacks[2].sound = "EnemyBossPrincessMeleeArea"
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "bullet_boss_princess_iron_fan"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 30)}
tt.ranged.attacks[1].cooldown = b.ranged_area_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_area_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_area_attack.min_range
tt.ranged.attacks[1].shoot_time = fts(21)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "stun_tower"
tt.timed_attacks.list[1].first_cooldown = b.illusory_summon.first_cooldown
tt.timed_attacks.list[1].cooldown = b.illusory_summon.cooldown
tt.timed_attacks.list[1].nodes_limit = b.illusory_summon.nodes_limit
tt.timed_attacks.list[1].shield_decal = "decal_boss_princess_iron_fan_bossfight_shield"
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation_in = "stun_tower_in"
tt.timed_attacks.list[2].animation_loop = "stun_tower_loop"
tt.timed_attacks.list[2].animation_end = "stun_tower_out"
tt.timed_attacks.list[2].first_cooldown = b.tower_curse.first_cooldown
tt.timed_attacks.list[2].cooldown = b.tower_curse.cooldown
tt.timed_attacks.list[2].loops_amount = 2
tt.timed_attacks.list[2].nodes_limit = b.tower_curse.nodes_limit
tt.timed_attacks.list[2].range = b.tower_curse.range
tt.timed_attacks.list[2].mod = "boss_princess_iron_fan_tower_debuff_bossfight"
tt.timed_attacks.list[2].holders_not_to_block = b.tower_curse.holders_not_to_block
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].animation_in = "clone_in"
tt.timed_attacks.list[3].animation_loop = "clone_loop"
tt.timed_attacks.list[3].animation_end = "clone_out"
tt.timed_attacks.list[3].first_cooldown = b.illusory_self.first_cooldown
tt.timed_attacks.list[3].cooldown = b.illusory_self.cooldown
tt.timed_attacks.list[3].nodes_limit = b.illusory_self.nodes_limit
tt.timed_attacks.list[3].spawn_pos = b.illusory_self.clon_config.spawn_pos
tt.timed_attacks.list[3].casts = 0
tt.timed_attacks.list[3].loops_amount = 3
tt.timed_attacks.list[3].entity = "boss_princess_iron_fan_clone"
tt.timed_attacks.list[4] = E:clone_c("custom_attack")
tt.timed_attacks.list[4].config = b.change_paths.config
tt.timed_attacks.list[4].cooldown = b.change_paths.cooldown
tt.timed_attacks.list[4].animation_in = "teleport_in"
tt.timed_attacks.list[4].animation_out = "teleport_out"
tt.timed_attacks.list[5] = E:clone_c("custom_attack")
tt.timed_attacks.list[5].animation = "stun_hero"
tt.timed_attacks.list[5].warning_duration = b.stun_hero.warning_duration
tt.timed_attacks.list[5].first_cooldown = b.stun_hero.first_cooldown
tt.timed_attacks.list[5].cooldown = b.stun_hero.cooldown
tt.timed_attacks.list[5].nodes_limit = b.stun_hero.nodes_limit
tt.timed_attacks.list[5].range = b.stun_hero.range
tt.timed_attacks.list[5].stun_decal = "decal_boss_princess_iron_fan_stun_heroes_bossfight"
tt.timed_attacks.list[5].vis_flags = bor(F_MOD, F_STUN, F_AREA)
tt.timed_attacks.list[5].vis_bans = bor(0)
tt.sound_death = "EnemyBossPrincessDeath"
tt.sound_teleport_out = "EnemyBossPrincessTeleportOut"
tt.sound_clone = "EnemyBossPrincessClone"
tt.sound_stun_hero_channel = "EnemyBossPrincessHeroStunChannel"
tt.sound_stun_hero_fail = "EnemyBossPrincessHeroStunFail"
tt.sound_stun_hero_success = "EnemyBossPrincessHeroStunSuccess"
tt = E:register_t("boss_princess_iron_fan_clone", "boss_princess_iron_fan")
b = balance.enemies.wukong.boss_princess.bossfight.illusory_self.clon_config
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_BOSS_PRINCESS_IRON_FAN"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0123"
tt.info.portrait_boss = nil
tt.render.sprites[tt.render.sid_unit].prefix = "boss_princess_cloneDef"
tt.render.sprites[tt.render.sid_unit].name = "spawn_in"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_decal = "fx_boss_spider_queen_melee_hit_decal"
tt.melee.attacks[2] = nil
tt.ranged.attacks[1].bullet = "bullet_boss_princess_iron_fan"
tt.ranged.attacks[1].cooldown = b.ranged_area_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_area_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_area_attack.min_range
tt.ranged.attacks[1].ignore_hit_offset = true
tt.timed_attacks.list[1] = nil
tt.timed_attacks.list[2] = nil
tt.timed_attacks.list[3] = nil
tt.timed_attacks.list[4] = nil
tt.timed_attacks.list[5] = nil
tt.unit.fade_time_after_death = 0.5
tt.unit.fade_duration_after_death = 0.5
tt.sound_death = nil
tt = E:register_t("decal_boss_princess_iron_fan_waves_shield", "enemy")
b = balance.enemies.wukong.boss_princess
tt.health.hp_max = b.waves.shield.health
tt.health.armor = b.waves.shield.armor
tt.health.magic_armor = b.waves.shield.magic_resistance
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 65, 240, 255}
tt.health_bar.colors.bg = {51, 18, 53, 255}
tt.health_bar.sort_y_offset = -2
tt.main_script.update = scripts.decal_boss_princess_iron_fan_waves_shield.update
tt.render.sprites[1].name = "boss_princess_iron_fan_vfx_stun_hero_particle_loop"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].hidden = true
tt.enemy.gold = 0
tt.enemy.melee_slot = v(0, 0)
tt.enemy.lives_cost = 0
tt.motion.max_speed = 0
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_NONE
tt.unit.hit_offset = v(0, 40)
tt.unit.mod_offset = v(0, 40)
tt.ui.can_click = false
tt.ui.can_select = false
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS, F_CLIFF)
tt.vis.bans = bor(F_ALL)
tt.can_explode = false
tt.can_disintegrate = false
tt = E:register_t("decal_boss_princess_iron_fan_bossfight_shield", "enemy")

E:add_comps(tt, "tween")

b = balance.enemies.wukong.boss_princess.bossfight
tt.health.hp_max = b.illusory_summon.shield_hp
tt.health.armor = b.illusory_summon.shield_armor
tt.health.magic_armor = b.illusory_summon.shield_magic_resistance
tt.health_bar.hidden = true
tt.health_bar.offset = v(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 65, 240, 255}
tt.health_bar.colors.bg = {51, 18, 53, 255}
tt.health_bar.sort_y_offset = -2
tt.main_script.update = scripts.decal_boss_princess_iron_fan_bossfight_shield.update
tt.render.sprites[1].name = "s34_malicia_shield_idle"
tt.render.sprites[1].anchor.y = 0.1423076923076923
tt.render.sprites[1].offset = v(-5, -10)
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -1
tt.enemy.gold = 0
tt.enemy.melee_slot = v(0, 0)
tt.enemy.lives_cost = 0
tt.motion.max_speed = 0
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_NONE
tt.unit.hit_offset = v(0, 40)
tt.unit.mod_offset = v(0, 40)
tt.ui.can_click = false
tt.ui.can_select = false
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vv(1.9)}, {fts(10), vv(2.09)}, {fts(20), vv(1.9)}}
tt.tween.props[1].loop = true
tt.tween.props[1].ignore_reverse = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {fts(11), 153}}
tt.shield_dps = tt.health.hp_max / b.illusory_summon.shield_duration
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MINIBOSS)
tt.vis.bans = bor(F_ALL)
tt.can_explode = false
tt.can_disintegrate = false
tt.manual_wave_name = b.illusory_summon.manual_wave_name
tt = E:register_t("decal_boss_princess_iron_fan_stun_heroes_waves", "decal_scripted")

E:add_comps(tt, "tween")

b = balance.enemies.wukong.boss_princess.waves.stun_hero
tt.finish = scripts.decal_boss_princess_iron_fan_stun_heroes.finish
tt.hero_escaped = scripts.decal_boss_princess_iron_fan_stun_heroes.hero_escaped
tt.capture_hero = scripts.decal_boss_princess_iron_fan_stun_heroes.capture_hero
tt.main_script.update = scripts.decal_boss_princess_iron_fan_stun_heroes.update
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_stun_hero_decal"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].sort_y_offset = -50
tt.render.sprites[1].group = "in_group"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "boss_princess_iron_fan_vfx_stun_hero_decal_2"
tt.render.sprites[2].name = "loop"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].sort_y_offset = -50
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "boss_princess_iron_fan_vfx_stun_hero_decal_3"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].animated = true
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].sort_y_offset = -50
tt.render.sprites[3].group = "in_group"
tt.warning_duration = b.WARNING_DURATION
tt.stun_radius = 60
tt.vis_flags = bor(F_AREA, F_STUN, F_MOD)
tt.vis_bans = bor(0)
tt.stun_mod = "mod_boss_princess_iron_fan_stun_heroes_waves"
tt.tween.remove = false
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].disabled = false
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[2].sprite_id = 1
tt.tween.props[2].disabled = true
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "alpha"
tt.tween.props[3].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].disabled = true
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "alpha"
tt.tween.props[4].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[4].sprite_id = 3
tt.tween.props[4].disabled = true
tt = E:register_t("decal_boss_princess_iron_fan_stun_heroes_bossfight", "decal_boss_princess_iron_fan_stun_heroes_waves")
b = balance.enemies.wukong.boss_princess.bossfight.stun_hero
tt.stun_mod = "mod_boss_princess_iron_fan_stun_heroes_bossfight"
tt = E:register_t("mod_boss_princess_iron_fan_stun_heroes_waves", "mod_stun")

E:add_comps(tt, "tween")

b = balance.enemies.wukong.boss_princess.waves.stun_hero
tt.modifier.duration = b.DURATION
tt.main_script.insert = scripts.mod_boss_princess_iron_fan_stun_heroes.insert
tt.main_script.update = scripts.mod_boss_princess_iron_fan_stun_heroes.update
tt.main_script.remove = scripts.mod_boss_princess_iron_fan_stun_heroes.remove
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_stun_hero"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].group = "stun"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].anchor = v(0.5, 0.7121212121212122)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "boss_princess_iron_fan_vfx_stun_hero_particle_loop"
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -5
tt.render.sprites[2].hidden = true
tt.render.sprites[2].anchor = v(0.5, 0.7884615384615384)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "boss_princess_iron_fan_vfx_stun_hero_loop_shadow_0001"
tt.render.sprites[3].animated = false
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].hidden = true
tt.modifier.use_mod_offset = false
tt.fx_flying = "fx_boss_princess_iron_fan_stun_heroes_flying"
tt.fx_ground = "fx_boss_princess_iron_fan_stun_heroes_ground"
tt.levitate_strength = 10
tt.levitate_speed = 2
tt.minimum_y_offset = 40
tt.tween_remove_keys = {{0, 255}, {0.4, 255}, {0.7, 0}}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "alpha"
tt.tween.props[3].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[3].sprite_id = 3
tt.tween.remove = false
tt.tween.disabled = false
tt = E:register_t("mod_boss_princess_iron_fan_stun_heroes_bossfight", "mod_boss_princess_iron_fan_stun_heroes_waves")
b = balance.enemies.wukong.boss_princess.bossfight.stun_hero
tt = E:register_t("mod_boss_princess_iron_fan_death", "mod_boss_princess_iron_fan_stun_heroes_waves")
tt.main_script.insert = scripts.mod_boss_princess_iron_fan_death.insert
tt.main_script.update = scripts.mod_boss_princess_iron_fan_death.update
tt.main_script.remove = nil
tt.modifier.duration = 1e+99
tt.minimum_y_offset = 70
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_stun_hero_loop_copy"
tt.render.sprites[3].name = "boss_princess_iron_fan_vfx_stun_hero_loop_shadow_0002"
tt.tween.props[1].keys = {{0, 0}, {0.2, 255}}
tt.tween.props[2].keys = {{0, 0}, {0.2, 255}}
tt.tween.props[3].keys = {{0, 0}, {0.2, 255}}
tt.render.sprites[1].sort_y_offset = 1
tt.render.sprites[2].sort_y_offset = 1
tt.render.sprites[2].scale = vv(1.5)
tt = E:register_t("fx_boss_princess_iron_fan_stun_heroes_flying", "fx")
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_stun_hero_dragon"
tt.render.sprites[1].name = "in_capture"
tt.render.sprites[1].anchor = v(0.5, 0.7076612903225806)
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].sort_y_offset = -6
tt.render.sprites[1].z = Z_FLYING_HEROES
tt = E:register_t("fx_boss_princess_iron_fan_stun_heroes_ground", "fx")
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_stun_hero"
tt.render.sprites[1].name = "in_capture"
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].sort_y_offset = -6
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("fx_boss_princess_iron_fan_area_attack", "fx")
tt.render.sprites[1].name = "boss_princess_iron_fan_vfx_fx_area_attack"
tt = E:register_t("fx_boss_princess_iron_fan_special_vfx", "fx")
tt.render.sprites[1].prefix = "boss_princess_vfxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt = E:register_t("boss_princess_iron_fan_tower_debuff", "modifier")
b = balance.enemies.wukong.boss_princess.waves.tower_curse

E:add_comps(tt, "render", "sound_events")

tt.main_script.insert = scripts.boss_princess_iron_fan_tower_debuff.insert
tt.main_script.update = scripts.boss_princess_iron_fan_tower_debuff.update
tt.main_script.remove = scripts.boss_princess_iron_fan_tower_debuff.remove
tt.modifier.duration = b.DURATION
tt.modifier.vis_flags = F_CUSTOM
tt.spawn_every = b.spawn_every
tt.spawn_formations = b.spawn_formations
tt.quantity_formations_spawns = b.quantity_formations_spawns
tt.spawn_offset = v(0, 35)
tt.spawn_forced_waypoint_offset = v(0, 0)
tt.render.sid_fachada = 1
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "boss_princess_iron_fan_vfx_torre_fachada"
tt.render.sprites[1].name = "tower_in"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -5
tt.render.sid_floor = 2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "boss_princess_iron_fan_vfx_torre_floor"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_DECALS
tt.render.sid_door = 3
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "boss_princess_iron_fan_vfx_torre_door"
tt.render.sprites[3].name = "idle_door_on"
tt.render.sprites[3].hidden = true
tt.render.sprites[3].draw_order = 2
tt.render.sprites[3].sort_y_offset = -5
tt.render.sid_spawn_fx = 4
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "boss_princess_iron_fan_vfx_torre_fx_externos_delante"
tt.render.sprites[4].name = "run"
tt.render.sprites[4].hidden = false
tt.render.sprites[4].scale = vv(1.6666666666666667)
tt.render.sprites[4].draw_order = 3
tt.render.sprites[4].sort_y_offset = -10
tt.offset_y_per_tower = {
	hermit_toad = 4
}
tt.sound_events.insert = "EnemyBossPrincessMudTower"
tt = E:register_t("boss_princess_iron_fan_tower_debuff_bossfight", "boss_princess_iron_fan_tower_debuff")
b = balance.enemies.wukong.boss_princess.bossfight.tower_curse
tt.spawn_every = b.spawn_every
tt.spawn_formations = b.spawn_formations
tt.quantity_formations_spawns = b.quantity_formations_spawns
tt = E:register_t("bullet_boss_princess_iron_fan", "bullet")
b = balance.enemies.wukong.boss_princess.bossfight.ranged_area_attack
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.radius
tt.bullet.ignore_hit_offset = true
tt.bullet.damage_bans = bor(F_ENEMY)
tt.bullet.pop = nil
tt.bullet.decal_fx = "fx_boss_princess_iron_fan_proyectile_hit_explosion"
tt.main_script.update = scripts.bullet_boss_princess_iron_fan.update
tt.render.sprites[1].name = "boss_princess_iron_fan_vfx_proyectile_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = false
tt.bullet.hit_time = fts(25)
tt.ray_duration = fts(23)
tt.image_width = 200
tt.sound_events.insert = "EnemyBossPrincessRangedCast"
tt = E:register_t("fx_boss_princess_iron_fan_proyectile_hit_explosion", "decal_scripted")

E:add_comps(tt, "sound_events")

tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "boss_princess_iron_fan_vfx_projectile_explosion_run"
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "boss_princess_iron_fan_vfx_projectile_explosion_run"
tt.render.sprites[2].scale = vv(1.3)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].offset = v(27, -14)
tt.render.sprites[2].sort_y_offset = -10
tt.render.sprites[2].hidden = true
tt.render.sprites[2].delay_start = 0.15
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "boss_princess_iron_fan_vfx_projectile_explosion_run"
tt.render.sprites[3].scale = vv(1)
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].offset = v(-38, 20)
tt.render.sprites[3].hidden = true
tt.render.sprites[3].delay_start = 0.3
tt.sound_events.insert = "EnemyBossPrincessRangedImpact"

tt = E:register_t("controller_stage_35_redboy_powers", "decal_scripted")

E:add_comps(tt, "events")

tt.main_script.update = scripts.controller_stage_35_redboy_powers.update
tt.render.sprites[1].prefix = "redboy_stage5Def"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -85
tt.events.list[1].name = "samadhi_right"
tt.events.list[1].on_event = scripts.controller_stage_35_redboy_powers.on_samadhi_right
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "samadhi_left"
tt.events.list[2].on_event = scripts.controller_stage_35_redboy_powers.on_samadhi_left
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "portal_left"
tt.events.list[3].on_event = scripts.controller_stage_35_redboy_powers.on_portal_left
tt = E:register_t("controller_stage_35_princess_powers", "decal_scripted")

E:add_comps(tt, "events")

b = balance.enemies.wukong.boss_princess
tt.main_script.update = scripts.controller_stage_35_princess_powers.update
tt.render.sid_unit = 1
tt.render.sprites[tt.render.sid_unit].prefix = "ironfan_stage5Def"
tt.render.sprites[tt.render.sid_unit].exo = true
tt.render.sprites[tt.render.sid_unit].flip_x = true
tt.render.sprites[tt.render.sid_unit].animated = true
tt.render.sprites[tt.render.sid_unit].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_unit].name = "idle"
tt.render.sprites[tt.render.sid_unit].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_unit].sort_y_offset = -85
tt.block_tower_mod = "boss_princess_iron_fan_tower_debuff"
tt.stun_hero_decal = "decal_boss_princess_iron_fan_stun_heroes_waves"
tt.stun_hero_vis_flags = bor(F_MOD, F_STUN, F_AREA)
tt.stun_hero_vis_bans = bor(0)
tt.stun_hero = b.waves.stun_hero
tt.stun_hero_warning_duration = b.waves.stun_hero.WARNING_DURATION
tt.events.list[1].name = "block_tower"
tt.events.list[1].on_event = scripts.controller_stage_35_princess_powers.on_block_tower
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "stun_hero"
tt.events.list[2].on_event = scripts.controller_stage_35_princess_powers.on_stun_hero
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "portal_right"
tt.events.list[3].on_event = scripts.controller_stage_35_princess_powers.on_portal_right
tt = E:register_t("controller_stage_35_portal_left", "decal_scripted")

E:add_comps(tt, "events")

tt.main_script.update = scripts.controller_stage_35_portal_door_bosses.update
tt.render.sprites[1].prefix = "stage_5_puerta_redboyDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.events.list[1].name = "portal_left"
tt.events.list[1].on_event = scripts.controller_stage_35_portal_door_bosses.on_portal_open
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "portal_left_close"
tt.events.list[2].on_event = scripts.controller_stage_35_portal_door_bosses.on_portal_close
tt = E:register_t("controller_stage_35_portal_right", "controller_stage_35_portal_left")
tt.render.sprites[1].prefix = "stage_5_puerta_princessDef"
tt.render.sprites[1].flip_x = true
tt.events.list[1].name = "portal_right"
tt.events.list[2].name = "portal_right_close"
tt.sound_open = "Stage35PortalWater"
tt = E:register_t("controller_stage_35_lava_splash", "controller_stage_32_lava_splash")
tt.main_script.update = scripts.controller_stage_35_lava_splash.update
tt.apply_if_enemy_is_to_right = false
tt.mod = "mod_stage_35_lava_splash"
tt.paths_x = {
	[15] = 0,
	[7] = 0
}
tt = E:register_t("controller_stage_35_water_splash", "controller_stage_35_lava_splash")
tt.apply_if_enemy_is_to_right = true
tt.mod = "mod_stage_35_water_splash"
tt.paths_x = {
	[8] = 1025
}
tt = E:register_t("controller_stage_35_small_spawner", "decal_scripted")

E:add_comps(tt, "events", "editor")

tt.unit_spawned = scripts.controller_stage_35_small_spawner.unit_spawned
tt.main_script.update = scripts.controller_stage_35_small_spawner.update
tt.render.sprites[1].name = "stage35_spawner_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "stage35_spawner_puerta"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -23
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "stage_5_spawnerDef"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].sort_y_offset = -23
tt.spawner_nmbr = 0
tt.events.list[1].name = "spawner_open"
tt.events.list[1].on_event = scripts.controller_stage_35_small_spawner.on_portal_open
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "spawner_close"
tt.events.list[2].on_event = scripts.controller_stage_35_small_spawner.on_portal_close
tt.sound_open = "Stage35Spawners"
tt = E:register_t("controller_stage_35_bull_king", "decal_scripted")

E:add_comps(tt, "events", "editor")

tt.main_script.update = scripts.controller_stage_35_bull_king.update
tt.render.sprites[1].prefix = "stage_35_boss_bull_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 205
tt.events.list[1].name = "samadhi_right"
tt.events.list[1].on_event = scripts.controller_stage_35_bull_king.on_samadhi_right
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "samadhi_left"
tt.events.list[2].on_event = scripts.controller_stage_35_bull_king.on_samadhi_left
tt.events.list[3] = E:clone_c("event")
tt.events.list[3].name = "stun_hero"
tt.events.list[3].on_event = scripts.controller_stage_35_bull_king.on_stun_hero
tt.events.list[4] = E:clone_c("event")
tt.events.list[4].name = "golden_beast_right"
tt.events.list[4].on_event = scripts.controller_stage_35_bull_king.on_golden_eyed
tt.events.list[5] = E:clone_c("event")
tt.events.list[5].name = "golden_beast_left"
tt.events.list[5].on_event = scripts.controller_stage_35_bull_king.on_golden_eyed
tt.events.list[6] = E:clone_c("event")
tt.events.list[6].name = "portal_left"
tt.events.list[6].on_event = scripts.controller_stage_35_bull_king.on_portal_left
tt.events.list[7] = E:clone_c("event")
tt.events.list[7].name = "portal_right"
tt.events.list[7].on_event = scripts.controller_stage_35_bull_king.on_portal_right
tt = E:register_t("controller_stage_35_golden_eyed_left", "decal_scripted")

E:add_comps(tt, "events")

tt.main_script.update = scripts.controller_stage_35_golden_beast.update
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.render.sprites[1].name = "loop_leon"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.events.list[1].name = "golden_beast_left"
tt.events.list[1].on_event = scripts.controller_stage_35_golden_beast.on_golden_eyed
tt.path_id = 5
tt.empty_wait = 2
tt.golden_eyed_entity = "enemy_golden_eyed"
tt.summon_sound = "EnemyGoldenEyedSummon"
tt = E:register_t("controller_stage_35_golden_eyed_right", "controller_stage_35_golden_eyed_left")
tt.render.sprites[1].prefix = "spawner_golden_beastDef"
tt.events.list[1].name = "golden_beast_right"
tt.path_id = 6
tt = E:register_t("boss_bull_king", "boss")
b = balance.enemies.wukong.boss_bull_king

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(80, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 1e+99
tt.health_bar.offset = v(0, 127)
tt.unit.hit_offset = v(-5, 30)
tt.unit.head_offset = v(-2, 67)
tt.unit.mod_offset = v(-5, 30)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-45, 0, 90, 90)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_RED
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_BOSS_BULL_KING"
tt.info.enc_icon = 119
tt.info.portrait = "kr5_info_portraits_enemies_0124"
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.portrait_boss = "boss_health_bar_icon_0013"
tt.render.sid_unit = 1
tt.render.sprites[tt.render.sid_unit].prefix = "stage_35_boss_bull_2Def"
tt.render.sprites[tt.render.sid_unit].name = "idle"
tt.render.sprites[tt.render.sid_unit].exo = true
tt.render.sprites[tt.render.sid_unit].animated = true
tt.render.sprites[tt.render.sid_unit].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_unit].angles = {}
tt.render.sprites[tt.render.sid_unit].angles.walk = {"walk", "walk", "walk"}
tt.unit.show_blood_pool = false
tt.spawn_pos = b.spawn_pos
tt.spawn_fx = "fx_boss_bull_king_spawn"
tt.second_manual_wave_pos = b.second_manual_wave_pos
tt.main_script.insert = scripts.boss_bull_king.insert
tt.main_script.update = scripts.boss_bull_king.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].hit_fx = "fx_boss_bull_king_hit"
tt.melee.attacks[1].hit_fx_offset = v(80, 10)
tt.melee.attacks[1].sound_hit = "Stage35BossBullKingMeleeVar1"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.melee_area_attack.cooldown
tt.melee.attacks[2].damage_max = b.melee_area_attack.damage_max
tt.melee.attacks[2].damage_min = b.melee_area_attack.damage_min
tt.melee.attacks[2].damage_type = b.melee_area_attack.damage_type
tt.melee.attacks[2].damage_radius = b.melee_area_attack.damage_radius
tt.melee.attacks[2].animation = "attack_melee_area"
tt.melee.attacks[2].hit_time = fts(35)
tt.melee.attacks[2].hit_fx = "fx_boss_bull_king_hit_area"
tt.melee.attacks[2].hit_fx_offset = v(50, 0)
tt.melee.attacks[2].hit_offset = v(50, 0)
tt.melee.attacks[2].sound_hit = "Stage35BossBullKingMeleeArea"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_in = "skill_area_kill_in"
tt.timed_attacks.list[1].animation_loop = "skill_area_kill_loop"
tt.timed_attacks.list[1].animation_end = "skill_area_kill_out"
tt.timed_attacks.list[1].loops_amount = 3
tt.timed_attacks.list[1].dome_fx = "fx_boss_bull_king_domo"
tt.timed_attacks.list[1].anime_fx = "fx_boss_bull_king_anime"
tt.timed_attacks.list[1].anime_fx_back_black = "fx_boss_bull_king_anime_black"
tt.timed_attacks.list[1].anime_fx_back_white = "fx_boss_bull_king_anime_white"
tt.timed_attacks.list[1].first_cooldown = b.area_attack.first_cooldown
tt.timed_attacks.list[1].cooldown = b.area_attack.cooldown
tt.timed_attacks.list[1].damage_type = b.area_attack.damage_type
tt.timed_attacks.list[1].damage_max = b.area_attack.damage_max
tt.timed_attacks.list[1].damage_min = b.area_attack.damage_min
tt.timed_attacks.list[1].damage_radius = b.area_attack.damage_radius
tt.timed_attacks.list[1].nodes_limit = b.area_attack.nodes_limit
tt.timed_attacks.list[1].mod_tower_debuff = "mod_bull_king_tower_debuff"
tt.timed_attacks.list[1].max_towers_block = b.area_attack.max_towers_block
tt.timed_attacks.list[1].max_range = b.area_attack.max_range_towers_block
tt.timed_attacks.list[1].min_range = b.area_attack.min_range_towers_block
tt.timed_attacks.list[1].mod_stun = "mod_bull_king_stun"
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].vis_flags_stun = bor(F_AREA)
tt.timed_attacks.list[1].vis_bans_stun = bor(F_FLYING)
tt.sound_death = "Stage35BossBullKingDeath"
tt = E:register_t("mod_bull_king_tower_debuff", "mod_hide_tower")
b = balance.enemies.wukong.boss_bull_king.area_attack

E:add_comps(tt, "render")

tt.main_script.update = scripts.mod_bull_king_tower_debuff.update
tt.main_script.remove = nil
tt.modifier.duration = b.stun_tower_duration
tt.modifier.vis_flags = F_CUSTOM
tt.modifier.handle_stun = true
tt.render.sprites[1].prefix = "stage_35_stun_towerDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset.y = 5
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt.offset_y_per_tower = {
	hermit_toad = 4
}
tt = RT("mod_bull_king_stun", "mod_stun")
b = balance.enemies.wukong.boss_bull_king.area_attack

E:add_comps(tt, "render")

tt.modifier.duration = b.stun_duration
tt.main_script.insert = scripts.mod_bull_king_stun.insert
tt.main_script.remove = scripts.mod_bull_king_stun.remove
tt.render.sprites[1].prefix = "stage_35_stun_unitDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt.modifier.animation_phases = true
tt.modifier.hide_target_delay = fts(3)
tt.modifier.use_mod_offset = false
tt = E:register_t("fx_boss_bull_king_spawn", "decal_scripted")
tt.main_script.update = scripts.fx_boss_bull_king_spawn.update
tt.render.sprites[1].prefix = "stage_35_stun_towerDef"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -20
tt = E:register_t("fx_boss_bull_king_hit", "fx")
tt.render.sprites[1].prefix = "stage_35_hitDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(2)
tt = E:register_t("fx_boss_bull_king_hit_area", "fx")
tt.render.sprites[1].prefix = "stage_35_areaattackDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_boss_bull_king_domo", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage_35_domoDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].hidden = true
tt.render.sprites[1].delay_start = fts(11)
tt = E:register_t("fx_boss_bull_king_anime", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage_35_fx_animeDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].hidden = true
tt.render.sprites[1].delay_start = 1
tt = E:register_t("fx_boss_bull_king_anime_white", "decal_scripted")
tt.main_script.update = scripts.fx_boss_bull_king_anime_color.update
tt.render.sprites[1].name = "stage_35_box_asst_box1"
tt.render.sprites[1].scale = vv(200)
tt.render.sprites[1].z = Z_OBJECTS_SKY - 1
tt.render.sprites[1].sort_y_offset = 10
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.delay_start = 1.15
tt = E:register_t("fx_boss_bull_king_anime_black", "fx_boss_bull_king_anime_white")
tt.render.sprites[1].name = "stage_35_box_asst_box2"
tt.delay_start = 1.05
tt = E:register_t("fx_boss_bull_king_explosion", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage_35_explosion_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 20
tt = E:register_t("controller_stage_35", "decal_scripted")

E:add_comps(tt, "editor", "ui", "events")

tt.main_script.update = scripts.controller_stage_35.update
tt.render.sprites[1].prefix = "stage_5_cinematicaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt.render.sprites[1].pos = v(0, 0)
tt.events.list[1].name = "barrage"
tt.events.list[1].on_event = scripts.controller_stage_35.on_event
tt.fixed_screen_offset = v(40, 40)
tt = E:register_t("debug_draw_ability_area", "decal_scripted")
tt.main_script.update = scripts.debug_draw_ability_area.update
tt.check_function = nil
tt.check_every = 0.1
tt.radius_check = 300
tt.show_red = false
tt.sprites_x = math.ceil(REF_W / 10)
tt.sprites_y = math.ceil(REF_H / 5)
tt.sprite_size = v(REF_W / tt.sprites_x, REF_H / tt.sprites_y)

for xx = 1, tt.sprites_x do
	for yy = 1, tt.sprites_y do
		local index_x = xx
		local index_y = (yy - 1) * tt.sprites_x
		local sprite_i = index_x + index_y
		local pos = v(xx * tt.sprite_size.x, yy * tt.sprite_size.y)

		tt.render.sprites[sprite_i] = E:clone_c("sprite")
		tt.render.sprites[sprite_i].pos = pos
		tt.render.sprites[sprite_i].scale = vv(0.5)
		tt.render.sprites[sprite_i].animated = false
		tt.render.sprites[sprite_i].z = Z_DECALS
		tt.render.sprites[sprite_i].name = "decal_blood_0001"
	end
end

tt = E:register_t("stage_31_mask_burned_01", "decal")

E:add_comps(tt, "editor", "editor_script")

tt.render.sprites[1].name = "stage_31_mask_burned_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -60
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true
tt.show_in_editor = true
tt.editor_script.insert = scripts.editor_mask.insert
tt = E:register_t("stage_31_mask_burned_02", "stage_31_mask_burned_01")
tt.render.sprites[1].name = "stage_31_mask_burned_02"
tt.render.sprites[1].sort_y_offset = -112
tt = E:register_t("stage_31_mask_burned_03", "stage_31_mask_burned_01")
tt.render.sprites[1].name = "stage_31_mask_burned_03"
tt.render.sprites[1].sort_y_offset = -80
tt = E:register_t("stage_31_mask_shadow_top", "decal")
tt.render.sprites[1].prefix = "stage_31_shadowDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("stage_31_exo_fire_a", "decal")

E:add_comps(tt, "editor", "editor_script")

tt.render.sprites[1].prefix = "stage_31_fire_ADef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
tt.render.sprites[1].hidden = true
tt.show_in_editor = true
tt.editor_script.insert = scripts.editor_mask.insert
tt = E:register_t("stage_31_exo_fire_b", "stage_31_exo_fire_a")
tt.render.sprites[1].prefix = "stage_31_fire_BDef"
tt = E:register_t("stage_31_exo_fire_c", "stage_31_exo_fire_a")
tt.render.sprites[1].prefix = "stage_31_fire_CDef"

for i = 1, 3 do
	tt = E:register_t("stage_31_exo_forest_" .. i, "decal")

	E:add_comps(tt, "editor", "editor_script")

	tt.render.sprites[1].prefix = "stage_31_forest_0" .. i .. "Def"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.show_in_editor = false
	tt.editor_script.insert = scripts.editor_mask.insert

	if i == 3 then
		tt.render.sprites[1].z = Z_OBJECTS + 1
		tt.render.sprites[1].sort_y_offset = -700
	else
		tt.render.sprites[1].z = Z_DECALS
	end
end

for lyr_nmbr = 1, 7 do
	tt = E:register_t("stage_31_exo_waterfall_layer_" .. lyr_nmbr, "decal")
	tt.render.sprites[1].prefix = "stage_31_waterfall_layer_" .. lyr_nmbr .. "Def"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS

	if lyr_nmbr == 1 then
		tt.render.sprites[1].sort_y_offset = -201
	elseif lyr_nmbr == 2 then
		tt.render.sprites[1].sort_y_offset = -200
	elseif lyr_nmbr == 3 then
		tt.render.sprites[1].sort_y_offset = 3
	elseif lyr_nmbr == 4 then
		tt.render.sprites[1].sort_y_offset = 4
	elseif lyr_nmbr == 5 then
		tt.render.sprites[1].sort_y_offset = 5
	elseif lyr_nmbr == 6 then
		tt.render.sprites[1].sort_y_offset = 220
	elseif lyr_nmbr == 7 then
		tt.render.sprites[1].sort_y_offset = 2001
	end
end

tt = RT("decal_generic_kill_area")

AC(tt, "pos", "editor", "editor_script")

tt.kill_area_fn = scripts.decal_generic_kill_area.kill_area_fn
tt.kill_radius = 200
tt.kill_area_id = 1
tt.editor.components = {"render"}
tt.editor.overrides = {
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_red_circle_filled"
}
tt.editor.props = {{"kill_radius", PT_NUMBER, 5, {50, 800}}, {"kill_area_id", PT_NUMBER}}
tt.editor_script.update = scripts.editor_decal_generic_kill_area.update
tt = RT("decal_generic_kill_area_rect")

AC(tt, "pos", "editor", "editor_script")

tt.kill_area_fn = scripts.decal_generic_kill_area_rect.kill_area_fn
tt.kill_size = v(100, 100)
tt.kill_area_id = 1
tt.editor.components = {"render"}
tt.editor.overrides = {
	["render.sprites[1].animated"] = false,
	["render.sprites[1].name"] = "editor_red_square_filled"
}
tt.editor.props = {{"kill_size", PT_COORDS, 5, {{50, 800}, {50, 800}}}, {"kill_area_id", PT_NUMBER}}
tt.editor_script.update = scripts.editor_decal_generic_kill_area_rect.update
tt = E:register_t("stage_32_mask_heads", "decal")
tt.render.sprites[1].name = "stage_32_masks_layer_01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 160
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("stage_32_mask_heads_2", "stage_32_mask_heads")
tt.render.sprites[1].flip_x = true
tt = E:register_t("stage_32_mask_front", "decal")
tt.render.sprites[1].prefix = "stage_32_lava_shadow_dragonDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("stage_32_mask_waterfall_1", "decal")
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_1Def"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("stage_32_mask_waterfall_2", "stage_32_mask_waterfall_1")
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_2Def"
tt.render.sprites[1].sort_y_offset = 175
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("stage_32_mask_waterfall_3", "stage_32_mask_waterfall_2")
tt.render.sprites[1].prefix = "stage_32_lava_waterfall_3Def"
tt = E:register_t("stage_32_mask_lava_bubbles", "decal")
tt.render.sprites[1].prefix = "stage_32_lava_bubbleDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = 176
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("stage_32_mask_lava_rocks", "decal")
tt.render.sprites[1].prefix = "stage_32_rockDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("stage_32_mask_fire_decals", "decal")
tt.render.sprites[1].prefix = "stage_32_lava_buffDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("stage_33_mask_props", "decal")
tt.render.sprites[1].prefix = "stage_33_anim_propsDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("stage_33_mask_water_small", "decal")
tt.render.sprites[1].prefix = "stage_33_olas_chicasDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND - 1
tt = E:register_t("stage_33_mask_water_big", "decal")
tt.render.sprites[1].prefix = "stage_33_olas_grandesDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BACKGROUND - 2
tt = E:register_t("stage_33_mask_1", "decal")
tt.render.sprites[1].name = "stage33_mask_1_casa_grande"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.pos = v(512, 384)
tt.render.sprites[1].sort_y_offset = 550 - tt.pos.y
tt = E:register_t("stage_33_mask_1_destroyed", "stage_33_mask_1")
tt.render.sprites[1].name = "stage 33_mask_intersection"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true
tt = E:register_t("stage_33_mask_2", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_2_casita"
tt.render.sprites[1].sort_y_offset = 581 - tt.pos.y
tt = E:register_t("stage_33_mask_3", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_3_casita"
tt.render.sprites[1].sort_y_offset = 544 - tt.pos.y
tt = E:register_t("stage_33_mask_4", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_4_plataforma"
tt.render.sprites[1].sort_y_offset = 371 - tt.pos.y
tt = E:register_t("stage_33_mask_5", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_5_carpa"
tt.render.sprites[1].sort_y_offset = 365 - tt.pos.y
tt = E:register_t("stage_33_mask_6", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_6_casita"
tt.render.sprites[1].sort_y_offset = 374 - tt.pos.y
tt = E:register_t("stage_33_mask_7", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_7_casita"
tt.render.sprites[1].sort_y_offset = 374 - tt.pos.y
tt = E:register_t("stage_33_mask_8", "stage_33_mask_1")
tt.render.sprites[1].name = "stage33_mask_8_casitas"
tt.render.sprites[1].sort_y_offset = 530 - tt.pos.y
tt = E:register_t("stage_33_mask_9", "stage_33_mask_1")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "stage33_mask_9_modos_relleno_holders"
tt.render.sprites[1].sort_y_offset = 450 - tt.pos.y
tt = E:register_t("stage_33_house_destroyed_decal_1", "decal")
tt.render.sprites[1].name = "stage33_casa_holder_escombros_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5760714285714286, 0.3502604166666667)
tt = E:register_t("stage_33_house_destroyed_decal_2", "decal")
tt.render.sprites[1].name = "stage33_casa_holder_escombros_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.3246428571428571, 0.23697916666666666)
tt = E:register_t("stage_33_house_destroyed_decal_3", "decal")
tt.render.sprites[1].name = "stage33_casa_holder_escombros_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.7917857142857143, 0.69140625)
tt = E:register_t("stage_33_citizen_house_1", "decal_scripted")
tt.main_script.update = scripts.stage_33_citizen_house.update
tt.open_door = scripts.stage_33_citizen_house.open_door
tt.render.sid_base = 1
tt.render.sid_door = 2
tt.render.sid_floor = 3
tt.render.sprites[tt.render.sid_base].name = "stage33_casa1_pescadores_base"
tt.render.sprites[tt.render.sid_base].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_base].animated = false
tt.render.sprites[tt.render.sid_base].sort_y_offset = -10
tt.render.sprites[tt.render.sid_door] = table.deepclone(tt.render.sprites[tt.render.sid_base])
tt.render.sprites[tt.render.sid_door].prefix = "stage33_casa1_pescadores_door"
tt.render.sprites[tt.render.sid_door].name = "open"
tt.render.sprites[tt.render.sid_door].animated = true
tt.render.sprites[tt.render.sid_door].sort_y_offset = -11
tt.render.sprites[tt.render.sid_floor] = table.deepclone(tt.render.sprites[tt.render.sid_base])
tt.render.sprites[tt.render.sid_floor].name = "stage33_casa1_pescadores_sombra"
tt.render.sprites[tt.render.sid_floor].z = Z_DECALS
tt.render.sprites[tt.render.sid_floor].sort_y_offset = 0
tt = E:register_t("stage_33_citizen_house_2", "stage_33_citizen_house_1")
tt.render.sprites[tt.render.sid_base].name = "stage33_casa2_pescadores_base"
tt.render.sprites[tt.render.sid_door].prefix = "stage33_casa2_pescadores_door"
tt.render.sprites[tt.render.sid_door].sort_y_offset = 0
tt.render.sprites[tt.render.sid_floor].name = "stage33_casa2_pescadores_sombra"
tt = E:register_t("controller_stage_34_fuentes")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.controller_stage_34_fuentes.update
tt.nodes_range = 15
tt.open_duration = 3
tt = E:register_t("decal_stage_34_fuente_1", "decal_scripted")

E:add_comps(tt, "events")

tt.start_remolino = scripts.decal_stage_34_fuente.start_remolino
tt.end_remolino = scripts.decal_stage_34_fuente.end_remolino
tt.main_script.update = scripts.decal_stage_34_fuente.update
tt.events.list[1].name = "fuente_remolino_start"
tt.events.list[1].on_event = scripts.decal_stage_34_fuente.on_event_start
tt.events.list[2] = E:clone_c("event")
tt.events.list[2].name = "fuente_remolino_end"
tt.events.list[2].on_event = scripts.decal_stage_34_fuente.on_event_end
tt.event_listen_number = 1
tt.remolino_count = 0
tt.render.sprites[1].prefix = "stage_34_fuente_1Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.connections = {{nil, 12}}
tt.sound_mud_pool_transformation = "EnemyBossPrincessMudPoolTransformation"
tt = E:register_t("decal_stage_34_fuente_2", "decal_stage_34_fuente_1")
tt.event_listen_number = 2
tt.render.sprites[1].prefix = "stage_34_fuente_2Def"
tt.connections = {{3, 9}, {4, 10}, {5, 11}}
tt = E:register_t("decal_stage_34_fuente_3", "decal_stage_34_fuente_1")
tt.event_listen_number = 3
tt.render.sprites[1].prefix = "stage_34_fuente_4Def"
tt.connections = {{6, 9}, {7, 10}, {8, 12}}
tt = E:register_t("decal_stage_34_fuente_4", "decal_stage_34_fuente_1")
tt.event_listen_number = 4
tt.render.sprites[1].prefix = "stage_34_fuente_5Def"
tt.connections = {{nil, 9}}
tt = E:register_t("decal_stage_34_fuente_5", "decal_stage_34_fuente_1")
tt.event_listen_number = 5
tt.render.sprites[1].prefix = "stage_34_fuente_6Def"
tt.connections = {{nil, 10}, {nil, 11}}
tt = E:register_t("decal_stage_34_fuente_6", "decal_stage_34_fuente_1")
tt.event_listen_number = 6
tt.render.sprites[1].prefix = "stage_34_fuente_3Def"
tt.connections = nil
tt = E:register_t("decal_stage_34_mask_2", "decal")
tt.render.sprites[1].name = "mascara2_puertas"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -100
tt = E:register_t("decal_stage_34_mask_3", "decal")
tt.render.sprites[1].name = "mascara3_gazebo"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_34_mask_cascadas_1", "decal")
tt.render.sprites[1].name = "stage_34_cascadas_1_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].animated = true
tt = E:register_t("decal_stage_34_mask_cascadas_2", "decal_stage_34_mask_cascadas_1")
tt.render.sprites[1].name = "stage_34_cascadas_2_run"
tt = E:register_t("decal_stage_34_mask_cascadas_3", "decal_stage_34_mask_cascadas_1")
tt.render.sprites[1].name = "stage_34_cascadas_3_run"
tt = E:register_t("decal_stage_34_mask_cascadas_6", "decal_stage_34_mask_cascadas_1")
tt.render.sprites[1].name = "stage_34_cascadas_6_run"
tt = E:register_t("decal_stage_34_easter_egg_mono", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = scripts.decal_stage_34_easter_egg_mono.update
tt.render.sprites[1].prefix = "wkstatue_sixear"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "wkstatue_ofrendas"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].offset = v(12, -12)
tt.ui.click_rect = r(-30, -20, 60, 60)
tt = E:register_t("stage_34_nubes_camino", "decal")
tt.render.sprites[1].prefix = "stage_4_nubescaminoDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("stage_34_nubes", "decal")
tt.render.sprites[1].prefix = "stage_4_nubesDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_35_mask_boss_bull", "decal")
tt.render.sprites[1].name = "stage35_mask_boss"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = 200
tt = E:register_t("decal_stage_35_mask_boss_bull_left", "decal")
tt.render.sprites[1].name = "stage35_mask_shadow_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_35_mask_boss_bull_right", "decal_stage_35_mask_boss_bull_left")
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_35_mask_path_open", "decal")
tt.render.sprites[1].name = "stage35_mask_path_open"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true
tt = E:register_t("stage_35_bloqueo_path", "decal")
tt.render.sprites[1].prefix = "stage_5_bloqueo_pathDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("decal_stage_35_mask_redboy_top", "decal")
tt.render.sprites[1].name = "stage35_mask_bosses"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = 0
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -86
tt = E:register_t("decal_stage_35_mask_princess_top", "decal_stage_35_mask_redboy_top")
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_35_mask_redboy_bottom", "decal")
tt.render.sprites[1].name = "stage35_mask_mask_creeps"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -30
tt = E:register_t("decal_stage_35_mask_princess_bottom", "decal_stage_35_mask_redboy_bottom")
tt.render.sprites[1].flip_x = true
tt = E:register_t("decal_stage_35_escombros_holder_1", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(2, -16)
tt = E:register_t("decal_stage_35_escombros_holder_2", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_2"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(0, -3)
tt = E:register_t("decal_stage_35_escombros_holder_3", "decal")
tt.render.sprites[1].name = "stage35_escombros_holder_3"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].offset = v(0, 0)
tt = E:register_t("decal_stage_35_escombros_cannonball_camino", "decal_tween")
tt.render.sprites[1].name = "destruccion_holder_escombros_camino"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {14, 255}, {16, 0}}
tt.tween.remove = true
tt.tween.disabled = false
tt = E:register_t("decal_stage_35_escombros_cannonball_holder", "decal_stage_35_escombros_cannonball_camino")
tt.render.sprites[1].name = "destruccion_holder_escombros_oro"
tt.render.sprites[1].offset = v(0, 20)
tt = E:register_t("decal_stage_35_fume_entradas", "decal_scripted")
tt.main_script.update = scripts.decal_stage_35_fume_entradas.update
tt.render.sprites[1].prefix = "stage_35_fumeDef"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].animated = true

tt = E:register_t("decal_dlc_wukong_flaming_ground", "decal_scripted")

E:add_comps(tt, "auras")

tt.main_script.insert = scripts.decal_dlc_wukong_flaming_ground.insert
tt.main_script.update = scripts.decal_dlc_wukong_flaming_ground.update
tt.in_anim = "in"
tt.loop_anim = "idle"
tt.end_anim = "out"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].prefix = "fire_phoenix_zhu_que_fuego_camino"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.duration = nil
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_wukong_fire_ground_dps"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = E:clone_c("aura_attack")
tt.auras.list[2].name = "aura_wukong_fire_ground_sprint"
tt.auras.list[2].cooldown = 0
tt.auras.list[3] = E:clone_c("aura_attack")
tt.auras.list[3].name = "aura_wukong_fire_ground_healing"
tt.auras.list[3].cooldown = 0
tt.auras.list[4] = E:clone_c("aura_attack")
tt.auras.list[4].name = "aura_wukong_fire_ground_wuxian"
tt.auras.list[4].cooldown = 0
tt.is_flaming_ground = true
tt = E:register_t("decal_dlc_wukong_flaming_ground_small", "decal_dlc_wukong_flaming_ground")
tt.render.sprites[1].prefix = "fire_phoenix_zhu_que_fuego_camino_small"
tt = E:register_t("decal_fire_phoenix_flaming_ground", "decal_dlc_wukong_flaming_ground")
b = balance.enemies.wukong.fire_phoenix.flaming_ground
tt.duration = b.duration
tt = E:register_t("decal_burning_treant_flaming_ground", "decal_dlc_wukong_flaming_ground")
b = balance.enemies.wukong.burning_treant.area_attack.flaming_ground
tt.duration = b.duration
tt.render.sprites[1].prefix = "burning_treant_area_attk"
tt = E:register_t("decal_hellfire_warlock_flaming_ground", "decal_dlc_wukong_flaming_ground")
b = balance.enemies.wukong.hellfire_warlock.ranged.flaming_ground
tt.duration = b.duration
tt = E:register_t("decal_wuxian_flaming_ground", "decal_dlc_wukong_flaming_ground")
b = balance.enemies.wukong.wuxian.ranged_attack.flaming_ground
tt.duration = b.duration
tt = E:register_t("decal_fire_fox_flaming_ground", "decal_dlc_wukong_flaming_ground")
b = balance.enemies.wukong.fire_fox.flaming_ground
tt.duration = b.duration
tt.sid_explotion_aura = #tt.auras.list + 1
tt.auras.list[tt.sid_explotion_aura] = E:clone_c("aura_attack")
tt.auras.list[tt.sid_explotion_aura].name = "aura_fire_fox_explotion_dps"
tt.auras.list[tt.sid_explotion_aura].cooldown = 0
tt = E:register_t("decal_stage_32_boss_fissure_ability", "decal_dlc_wukong_flaming_ground")
tt.main_script.update = scripts.decal_stage_32_boss_fissure_ability.update
tt.render.sprites[1].prefix = "dragon_cracks_floorDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].pos = v(512, 384)
tt.render.sprites[1].z = Z_DECALS - 1
tt.fx = "fx_stage_32_lava_geyser"
tt.idle_anim = "idle"
tt.in_anim = "active_in"
tt.loop_anim = "active_loop"
tt.end_anim = "active_end"
tt.max_geysers = 5
tt.geyser_delay_max = 0.5
tt.geyser_delay_min = 0.2
tt = E:register_t("decal_water_sorceress_heal_wave", "decal_scripted")
tt.main_script.insert = scripts.decal_water_sorceress_heal_wave.insert
tt.main_script.update = scripts.decal_water_sorceress_heal_wave.update
tt.handle_heal = nil
tt.pi = nil
tt.spi = nil
tt.ni = nil
tt.nodes_range = nil
tt.nodes_advance = 5
tt.trail_duration = 0.5
tt.hit_targets = {}
tt.vis_flags = 0
tt.vis_bans = 0
tt.mod = "mod_water_sorceress_heal_wave_healing"
tt.mod_damage = "mod_water_sorceress_heal_wave_dps"
tt.decal_mod_range = 45
tt.render.sid_wave = 1
tt.render.sprites[tt.render.sid_wave].prefix = "watersorceress_wave"
tt.render.sprites[tt.render.sid_wave].name = "run"
tt.render.sprites[tt.render.sid_wave].animated = true
tt.render.sprites[tt.render.sid_wave].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_wave].offset = v(0, 5)
tt.render.sid_trail = 2
tt.render.sprites[tt.render.sid_trail] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_trail].prefix = "watersorceress_trail_wave"
tt.render.sprites[tt.render.sid_trail].name = "idle"
tt.render.sprites[tt.render.sid_trail].animated = true
tt.render.sprites[tt.render.sid_trail].z = Z_DECALS
tt.scale_max = 1
tt.scale_min = 0.9
tt.center_gravity = vv(0.5)
tt.wave_template = "decal_water_sorceress_heal_wave"
tt.wave_small_deco_template = "decal_water_sorceress_heal_wave_small_deco"
tt = E:register_t("decal_water_sorceress_heal_wave_small_deco", "decal_tween")

E:add_comps(tt, "main_script")

tt.main_script.insert = scripts.decal_water_sorceress_heal_wave.insert
tt.render.sprites[1].prefix = "watersorceress_trail_wave"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {0.1, 150}}
tt.center_gravity = v(0.5, 1.2)
tt.scale_max = 0.7
tt.scale_min = 0.5
tt.tween.remove = false
tt = E:register_t("decal_redboy_teen_skyrock", "decal_scripted")
tt.main_script.update = scripts.decal_redboy_teen_skyrock.update
tt.render.sprites[1].prefix = "teen_redboy_skyrockDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.entity = "enemy_ash_spirit"
tt = E:register_t("decal_storm_elemental_area_melee", "decal_scripted")

E:add_comps(tt, "tween")

tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "storm_elemental_vfx_area_attack_crack"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "storm_elemental_vfx_asst_area_attack"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].scale = vv(2)
tt.tween.props[1].keys = {{0, 255}, {fts(13), 255}, {fts(46), 0}}
tt.tween.remove = true
tt = E:register_t("decal_demon_minotaur_area_crack", "decal_tween")
tt.render.sprites[1].name = "demon_minotaur_decal_crack"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.tween.remove = true
tt = E:register_t("decal_demon_minotaur_area_smoke", "fx")
tt.render.sprites[1].name = "demon_minotaur_smoke_hit_run"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_DECALS

tt = RT("aura_wukong_fire_ground_apply_mod", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = nil
tt.aura.radius = 55
tt.aura.cycle_time = fts(3)
tt.aura.vis_bans = bor(F_FLYING)
tt = RT("aura_wukong_fire_ground_dps", "aura_wukong_fire_ground_apply_mod")
tt.aura.mod = "mod_wukong_flaming_ground_dps"
tt.aura.vis_bans = bor(tt.aura.vis_bans, F_ENEMY)
tt.aura.excluded_templates = {"hero_lava", "hero_ignus"}
tt = RT("aura_wukong_fire_ground_sprint", "aura_wukong_fire_ground_apply_mod")
tt.aura.mod = "mod_wukong_flaming_ground_sprint"
tt.aura.allowed_templates = {"enemy_fire_fox"}
tt = RT("aura_wukong_fire_ground_healing", "aura_wukong_fire_ground_apply_mod")
tt.aura.mod = "mod_wukong_flaming_ground_healing"
tt.aura.allowed_templates = {"enemy_ash_spirit"}
tt = RT("aura_wukong_fire_ground_wuxian", "aura_wukong_fire_ground_apply_mod")
tt.aura.mod = "mod_wukong_flaming_ground_toggle_abilities"
tt.aura.allowed_templates = {"enemy_wuxian", "enemy_nine_tailed_fox", "enemy_blaze_raider", "enemy_flame_guard"}
tt = RT("aura_fire_fox_explotion_dps", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_fire_fox_explotion_dps"
tt.aura.radius = 70
tt.aura.cycle_time = 1e+99
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)

tt = RT("mod_wukong_flaming_ground_sprint", "mod_slow")
b = balance.specials.terrain_8.flaming_ground.sprint
tt.slow.factor = b.sprint_factor
tt.modifier.duration = b.duration
tt.modifier.is_fire_buff = true
tt = RT("mod_wukong_flaming_ground_dps", "modifier")
E:add_comps(tt, "dps", "render")
b = balance.specials.terrain_8.flaming_ground.dps
tt.dps.damage_every = b.damage_every
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.modifier.duration = b.duration
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.vis_flags = bor(tt.modifier.vis_flags, F_BURN)
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 4
tt.render.sprites[1].loop = true

tt = RT("mod_wukong_flaming_ground_healing", "modifier")
E:add_comps(tt, "hps", "render")
b = balance.specials.terrain_8.flaming_ground.healing
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_wukong_flaming_ground_healing.update
tt.modifier.duration = b.heal_duration
tt.modifier.is_fire_buff = true
tt.hps.heal_min = b.heal_min
tt.hps.heal_max = b.heal_max
tt.hps.heal_every = b.heal_every
tt.render.sid_behind = 1
tt.render.sid_crosses = 2
tt.render.sprites[tt.render.sid_behind].prefix = "ashspirit_fx_heal_behind"
tt.render.sprites[tt.render.sid_behind].name = "run"
tt.render.sprites[tt.render.sid_behind].animated = true
tt.render.sprites[tt.render.sid_behind].loop = false
tt.render.sprites[tt.render.sid_behind].sort_y_offset = -5
tt.render.sprites[tt.render.sid_crosses] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[tt.render.sid_crosses].prefix = "ashspirit_fx_heal_croses"
tt.render.sprites[tt.render.sid_crosses].loop = true
tt.render.sprites[tt.render.sid_crosses].name = "run"
tt.render.sprites[tt.render.sid_crosses].anchor = vv(0.5)
tt.render.sprites[tt.render.sid_crosses].offset = v(-10, 15)
tt = E:register_t("mod_wukong_flaming_ground_toggle_abilities", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = fts(10)
tt.main_script.insert = scripts.mod_wukong_flaming_ground_toggle_abilities.insert
tt.main_script.update = scripts.mod_wukong_flaming_ground_toggle_abilities.update
tt.main_script.remove = scripts.mod_wukong_flaming_ground_toggle_abilities.remove
tt.modifier.is_fire_buff = true
tt.render.sid_wuxian = 1
tt.render.sprites[tt.render.sid_wuxian].prefix = "wuxian_buff"
tt.render.sprites[tt.render.sid_wuxian].name = "run"
tt.render.sprites[tt.render.sid_wuxian].animated = true
tt.render.sprites[tt.render.sid_wuxian].loop = true
tt.render.sprites[tt.render.sid_wuxian].sort_y_offset = -1
tt.render.sprites[tt.render.sid_wuxian].hidden = true
tt.render.sprites[tt.render.sid_wuxian].use_mod_offset = false
tt.template_scripts = {
	enemy_wuxian = {
		sprite_id = tt.render.sid_wuxian,
		insert = scripts.enemy_wuxian.flaming_toggle_abilities_insert,
		remove = scripts.enemy_wuxian.flaming_toggle_abilities_remove
	},
	enemy_nine_tailed_fox = {
		insert = scripts.enemy_nine_tailed_fox.flaming_toggle_abilities_insert,
		remove = scripts.enemy_nine_tailed_fox.flaming_toggle_abilities_remove
	},
	enemy_blaze_raider = {
		insert = scripts.enemy_blaze_raider.flaming_toggle_abilities_insert,
		remove = scripts.enemy_blaze_raider.flaming_toggle_abilities_remove
	},
	enemy_flame_guard = {
		insert = scripts.enemy_flame_guard.flaming_toggle_abilities_insert,
		remove = scripts.enemy_flame_guard.flaming_toggle_abilities_remove
	}
}
tt = RT("mod_fire_fox_explotion_dps", "modifier")
E:add_comps(tt, "dps")
b = balance.enemies.wukong.fire_fox.flaming_ground.explotion
tt.dps.damage_every = 1e+99
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.modifier.duration = fts(2)
tt.modifier.vis_flags = bor(tt.modifier.vis_flags, F_BURN)
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_nine_tailed_fox_stun_attack", "mod_stun")
b = balance.enemies.wukong.nine_tailed_fox.stun_attack
tt.modifier.duration = b.stun_duration
tt = RT("mod_nine_tailed_fox_stun_teleport", "mod_stun")
b = balance.enemies.wukong.nine_tailed_fox.teleport
tt.modifier.duration = b.stun_duration
tt = RT("mod_gale_warrior_combo_counter", "modifier")
tt.main_script.insert = scripts.mod_gale_warrior_combo_counter.insert
tt.main_script.queue = scripts.mod_gale_warrior_combo_counter.queue

tt = RT("mod_gale_warrior_dot", "mod_blood")
b = balance.enemies.wukong.gale_warrior.puncturing_thrust.dot
tt.dps.damage_every = b.damage_every
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.modifier.duration = b.duration
tt.modifier.level = 0
tt.main_script.queue = scripts.mod_gale_warrior_dot.queue

tt = E:register_t("mod_enemy_storm_elemental_tower_mark", "modifier")
E:add_comps(tt, "mark_flags")
tt.modifier.duration = fts(30)
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_enemy_storm_elemental_tower_debuff", "modifier")
b = balance.enemies.wukong.storm_elemental.tower_block

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_crocs_shaman_tower_debuff.insert
tt.main_script.update = scripts.mod_crocs_shaman_tower_debuff.update
tt.main_script.remove = scripts.mod_crocs_shaman_tower_debuff.remove
tt.modifier.duration = b.duration
tt.modifier.vis_flags = F_CUSTOM
tt.render.sprites[1].prefix = "storm_elemental_vfx_stun"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.offset_y_per_tower = {
	hermit_toad = 4
}
tt = RT("mod_water_sorceress_heal_wave_healing", "modifier")

E:add_comps(tt, "hps", "render")

b = balance.enemies.wukong.water_sorceress.heal_wave
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.modifier.duration = fts(88)
tt.hps.heal_min = b.heal_min / (tt.modifier.duration / tt.hps.heal_every)
tt.hps.heal_max = b.heal_max / (tt.modifier.duration / tt.hps.heal_every)
tt.hps.heal_every = 0.1
-- tt.render.sprites[1].prefix = "watersorceress_heal"
-- tt.render.sprites[1].name = "run"
tt.render.sprites[1].name = "watersorceress_heal"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].sort_y_offset = -5
tt = RT("mod_water_sorceress_heal_wave_dps", "modifier")

E:add_comps(tt, "dps")

b = balance.enemies.wukong.water_sorceress.heal_wave
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = fts(20)
tt.dps.damage_every = 1e+99
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.fx = "fx_water_sorceress_bolt_hit"

tt = E:register_t("mod_stage31_water_mechanic_dps", "modifier")
b = balance.specials.stage31_water_mechanic

E:add_comps(tt, "dps")

tt.modifier.duration = 1
tt.dps.fx = "fx_water_sorceress_bolt_hit"
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = 1e+99
tt.main_script.insert = scripts.mod_stage31_water_mechanic_dps.insert
tt.main_script.update = scripts.mod_stage31_water_mechanic_dps.update
tt.allowed_templates = {"enemy_fire_phoenix", "enemy_fire_fox", "enemy_nine_tailed_fox", "enemy_burning_treant", "enemy_ash_spirit"}

tt = E:register_t("fx_stage_31_fireball_a", "fx")
tt.render.sprites[1].prefix = "stage_31_fireball_ADef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 1
tt = E:register_t("fx_stage_31_fireball_b", "fx")
tt.render.sprites[1].prefix = "stage_31_fireball_BDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 2
tt = E:register_t("fx_stage_31_fireball_c", "fx")
tt.render.sprites[1].prefix = "stage_31_fireball_CDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.kill_area_id = 3
tt = E:register_t("fx_stage_32_dragon_mouth_fire_left", "fx")
tt.render.sprites[1].prefix = "dragon_redboy_stun_vfx_01Def"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = DAMAGE_TRUE
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt = E:register_t("fx_stage_32_dragon_mouth_fire_right", "fx_stage_32_dragon_mouth_fire_left")
tt.render.sprites[1].prefix = "dragon_redboy_stun_vfx_02Def"
tt = E:register_t("fx_stage_32_dragon_down_splash", "fx")
tt.render.sprites[1].prefix = "dragon_redboy_splashDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -20
tt.render.sprites[1].offset = v(0, 15)
tt = E:register_t("fx_stage_32_redboy_transform_fire", "fx")
tt.render.sprites[1].prefix = "dragon_redboy_transformDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, -30)
tt = E:register_t("fx_stage_32_fireball_right", "decal_scripted")
b = balance.enemies.wukong.boss_dragon.campaign.pre_fight_meteorite
tt.main_script.update = scripts.fx_stage_32_fireball_right.update
tt.render.sprites[1].prefix = "stage_32_fireball_rDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage_31_sign_decal_rDef"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].exo = true
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS
tt.shake_time = 150
tt.flags_meteorite = bor(F_RANGED, F_AREA)
tt.bans_meteorite = bor(F_BOSS)
tt.ni_step = 3
tt.path = 3
tt.kill_radius = 80
tt.force_move_impact_positions = {v(800, 326)}
tt.fire_duration = b.fire_duration
tt.path_fires = {
	[3] = {
		finish = 100,
		begin = 20
	},
	[4] = {
		finish = 60,
		begin = 50
	}
}
tt = E:register_t("fx_stage_32_fireball_left", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_32_fireball_lDef"
tt.render.sprites[2].prefix = "stage_31_sign_decal_lDef"
tt.path = 2
tt.force_move_impact_positions = {v(207, 226)}
tt.path_fires = {
	[2] = {
		finish = 120,
		begin = 20
	},
	{
		finish = 50,
		begin = 40
	}
}
tt = E:register_t("fx_stage_35_fireball_left", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_35_fireball_lDef"
tt.render.sprites[2].prefix = "stage5_samadhi_2Def"
tt.kill_area_id = 1
tt.path_fires = {{
	finish = 180,
	begin = 20
}}
tt = E:register_t("fx_stage_35_fireball_right", "fx_stage_32_fireball_right")
tt.render.sprites[1].prefix = "stage_35_fireball_rDef"
tt.render.sprites[2].prefix = "stage5_samadhi_1Def"
tt.kill_area_id = 2
tt.path_fires = {
	[2] = {
		finish = 130,
		begin = 20
	}
}
tt = E:register_t("fx_stage_32_lava_splash", "fx")
tt.render.sprites[1].prefix = "stage_32_lava_splashDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.5599999999999999)
tt = E:register_t("fx_stage_32_lava_splash_2", "fx_stage_32_lava_splash")
tt.render.sprites[1].flip_x = true
tt = E:register_t("fx_stage_32_lava_splash_big", "fx")
tt.render.sprites[1].prefix = "stage_32_lava_splash_bigDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.7)
tt = E:register_t("fx_stage_32_lava_splash_big_2", "fx_stage_32_lava_splash_big")
tt.render.sprites[1].flip_x = true
tt = E:register_t("fx_stage_32_lava_geyser", "fx")
tt.render.sprites[1].prefix = "dragon_cracks_geyserDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("fx_stage_33_house_destroy", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "vfx_mecanicas_destroy_house_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_stage_35_lava_splash", "fx")
tt.render.sprites[1].prefix = "stage_5_splash_lavaDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].exo = true
tt.render.sprites[1].sort_y_offset = -40
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(0.5599999999999999)
tt = E:register_t("fx_stage_35_lava_splash_big", "fx_stage_35_lava_splash")
tt.render.sprites[1].scale = vv(1)
tt = E:register_t("fx_stage_35_water_splash", "fx_stage_35_lava_splash")
tt.render.sprites[1].prefix = "stage_5_splash_aguaDef"
tt = E:register_t("fx_stage_35_water_splash_big", "fx_stage_35_water_splash")
tt.render.sprites[1].scale = vv(1)
tt = E:register_t("fx_water_spirit_splash", "fx")
tt.render.sprites[1].name = "wukong_water_spirit_fx_splash"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_water_spirit_charco_caida", "fx")
tt.render.sprites[1].name = "wukong_water_spirit_charco_caida_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("fx_water_spirit_hit", "abstract_fx_mod_in_hit_pos")
tt.render.sprites[1].name = "wukong_water_spirit_hit_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5

tt = E:register_t("fx_nine_tailed_fox_hit", "fx")
tt.render.sprites[1].name = "ninetailedfox_hit_hit"
tt = E:register_t("fx_nine_tailed_fox_hit_stun", "fx")
tt.render.sprites[1].name = "ninetailedfox_stun_run"
tt = E:register_t("fx_nine_tailed_fox_tp_stun_1", "fx")
tt.render.sprites[1].name = "ninetailedfox_stunearea_explosion1_run"
tt.render.sprites[1].scale = vv(2)
tt = E:register_t("fx_nine_tailed_fox_tp_stun_2", "fx")
tt.render.sprites[1].name = "ninetailedfox_stunearea_explosion2_run"
tt.render.sprites[1].scale = vv(2)
tt = E:register_t("fx_nine_tailed_fox_tp_stun_decal", "fx")
tt.render.sprites[1].name = "ninetailedfox_stun_decal_run"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_nine_tailed_fox_summon", "fx")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.fx_nine_tailed_fox_summon.update
tt.render.sprites[1].name = "ninetailedfox_summon"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.spawn_offset = v(0, 0)
tt.spawn_time = fts(45)
tt.spawn_entity = "enemy_nine_tailed_fox"
tt = E:register_t("fx_hellfire_warlock_summong_floor_staff", "fx")
tt.render.sprites[1].name = "hellfire_warlock_summon_stafx_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_hellfire_warlock_fireball_hit", "fx")
tt.render.sprites[1].name = "hellfire_warlock_hit_fireball"
tt = E:register_t("fx_hellfire_warlock_melee_hit", "fx")
tt.render.sprites[1].name = "hellfire_warlock_hit_run"
tt = E:register_t("fx_wuxian_bolt_hit", "fx")
tt.render.sprites[1].name = "wuxian_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -3
tt = E:register_t("fx_wuxian_melee_hit", "fx")
tt.render.sprites[1].name = "wuxian_hit_mele_hit"
tt = E:register_t("fx_wuxian_kamehame_hit", "fx")
tt.render.sprites[1].name = "wuxian_hit_run"
tt = E:register_t("fx_storm_spirit_zap_in_out", "fx")
tt.render.sprites[1].name = "stormspirit_zap_in_out"
tt = E:register_t("fx_storm_elemental_bullet_start", "fx")
tt.render.sprites[1].name = "storm_elemental_vfx_proyectile_fx_run"
tt.render.sprites[1].z = Z_BULLETS
tt = E:register_t("fx_storm_elemental_bullet_hit", "fx")
tt.render.sprites[1].name = "storm_elemental_vfx_hit_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt = E:register_t("decal_storm_elemental_bullet", "fx")
tt.render.sprites[1].name = "storm_elemental_vfx_explosion_proyectil"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt = E:register_t("decal_storm_elemental_bullet_2", "fx")
tt.render.sprites[1].name = "storm_elemental_vfx_explosion_proyectil_decal"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("decal_ash_spirit_hit", "decal_scripted")

E:add_comps(tt, "tween")

tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "ashspirit_fx_floor_decal_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "ashspirit_fx_vfx_explosion"
tt.render.sprites[2].name = "attack_1"
tt.render.sprites[2].loop = false
tt.render.sprites[2].scale = vv(2)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -3
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "ashspirit_fx_floor_decal_small"
tt.render.sprites[3].name = "decal"
tt.render.sprites[3].z = Z_DECALS
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].delay_start = fts(0)
tt.render.sprites[3].hidden = true
tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[4].offset = v(-30, 20)
tt.render.sprites[4].delay_start = fts(3)
tt.render.sprites[5] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[5].offset = v(0, -20)
tt.render.sprites[5].delay_start = fts(0)
tt.render.sprites[6] = table.deepclone(tt.render.sprites[3])
tt.render.sprites[6].offset = v(30, 13)
tt.render.sprites[6].delay_start = fts(3)
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {1.9, 255}, {2.3, 0}}
tt = E:register_t("fx_redboy_teen_floor_fire_decal", "fx")
tt.render.sprites[1].prefix = "teen_redboy_decalDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_redboy_teen_hand", "fx")
tt.render.sprites[1].prefix = "teen_redboy_uiexploDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_redboy_teen_hit", "fx")
tt.render.sprites[1].prefix = "teen_redboy_hitDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt = E:register_t("fx_redboy_screen", "fx")
tt.render.sprites[1].prefix = "dragon_redboy_screenDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_SCREEN_FIXED
tt = E:register_t("fx_redboy_teen_smoke", "fx")
tt.render.sprites[1].prefix = "teen_redboy_smokeDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("fx_redboy_fireabsorb_decal", "fx")
tt.render.sprites[1].prefix = "teen_redboy_decal_fireabsorbDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_citizen_3_melee_1_hit", "fx")
tt.render.sprites[1].name = "pueblerino_3_hit_1_run"
tt = E:register_t("fx_citizen_4_melee_1_hit", "fx")
tt.render.sprites[1].name = "pueblerino_4_hit_1_run"
tt = E:register_t("fx_water_sorceress_bolt_hit", "fx")
tt.render.sprites[1].name = "watersorceress_projectile_hit_run"
tt = E:register_t("fx_terracota_hit", "fx")
tt.render.sprites[1].name = "terracota_fx_hit_run"
tt = E:register_t("fx_demon_minotaur_hit", "fx")
tt.render.sprites[1].name = "demon_minotaur_hit_run"
tt = E:register_t("fx_demon_minotaur_rebote", "fx")
tt.render.sprites[1].name = "demon_minotaur_rebote_fx_run"

tt = E:register_t("fx_blaze_raider_melee_hit", "fx")
tt.render.sprites[1].name = "blaze_rider_hit_run"
tt = E:register_t("fx_fire_phoenix_death", "fx")
tt.render.sprites[1].name = "fire_phoenix_zhu_que_explosionfuego"
tt.render.sprites[1].z = Z_DECALS

tt = E:register_t("ps_wuxian_bolt_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "wuxian_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.particle_lifetime = {fts(6), fts(6)}
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_water_sorceress_bolt_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "watersorceress_projectile_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_hellfire_warlock_bullet_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hellfire_warlock_fireball_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.particle_lifetime = {fts(13), fts(13)}
tt.particle_system.anchor = v(0.6304347826086957, 0.36363636363636365)
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_storm_elemental_bullet_trail_1")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "storm_elemental_vfx_proyectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {0.7, 0.7}
tt.particle_system.scales_x = {0.7, 0.7}
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_storm_elemental_bullet_trail_2")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "storm_elemental_vfx_ranged_attck_trail_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {0.7, 0.7}
tt.particle_system.scales_x = {0.7, 0.7}
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_BULLET_PARTICLES
tt = E:register_t("ps_nine_tailed_fox_underground_trail")

E:add_comps(tt, "pos", "particle_system", "motion", "nav_path", "main_script")

b = balance.enemies.wukong.nine_tailed_fox.teleport
tt.main_script.update = scripts.ps_nine_tailed_fox_underground_trail.update
tt.particle_system.animated = true
tt.particle_system.name = "ninetailedfox_teleport_smoke_particle_run"
tt.particle_system.loop = false
tt.particle_system.emit_duration = nil
tt.particle_system.emission_rate = 10
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
tt.particle_system.emit_area_spread = v(0, 5)
tt.damage_radius = b.damage_radius
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.damage_type = b.damage_type
tt.vis_flags = F_AREA
tt.vis_bans = F_NONE
tt = E:register_t("ps_storm_spirit_jump_ahead_trail_1")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.name = "stormspirit_trail_run"
tt.particle_system.loop = false
tt.particle_system.emit_duration = nil
tt.particle_system.emission_rate = 30
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
tt.particle_system.emit_area_spread = v(0, 5)
tt.particle_system.sort_y_offset = -10
tt = E:register_t("ps_storm_spirit_jump_ahead_trail_2", "ps_storm_spirit_jump_ahead_trail_1")
tt.particle_system.name = "stormspirit_trail_nubes_run"
tt.particle_system.emission_rate = 12
tt.particle_system.sort_y_offset = 0
tt = E:register_t("ps_water_spirit_trail_jump")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.name = "wukong_water_spirit_ranged_attck_trail_run"
tt.particle_system.loop = false
tt.particle_system.emission_rate = 20
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_OBJECTS
tt.particle_system.emit_area_spread = v(0, 5)
tt.particle_system.track_rotation = true
tt = E:register_t("ps_water_spirit_trail_swim")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = false
tt.particle_system.name = "wukong_water_spirit_trail_nadar"
tt.particle_system.loop = false
tt.particle_system.emission_rate = 12
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_DECALS
tt.particle_system.emit_area_spread = v(1, 5)
tt.particle_system.particle_lifetime = {1, 1}
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.alphas = {255, 0}
tt = E:register_t("ps_storm_elemental_walk_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = false
tt.particle_system.name = "storm_elemental_vfx_walk_trail_0001"
tt.particle_system.loop = false
tt.particle_system.emission_rate = 2
tt.particle_system.source_lifetime = nil
tt.particle_system.z = Z_DECALS
tt.particle_system.emit_area_spread = v(1, 3)
tt.particle_system.particle_lifetime = {4, 4}
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.alphas = {255, 0}

tt = E:register_t("bullet_wuxian_bolt", "bolt_enemy")
b = balance.enemies.wukong.wuxian.ranged_attack
tt.render.sprites[1].prefix = "wuxian_bolt"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.main_script.update = scripts.bullet_wuxian_bolt.update
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.damage_bans = bor(F_ENEMY)
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 42
tt.bullet.max_speed = 420
tt.bullet.align_with_trajectory = false
tt.bullet.hit_fx = "fx_wuxian_bolt_hit"
tt.bullet.hit_fx_ignore_offset = true
tt.bullet.hit_decal = "decal_wuxian_flaming_ground"
tt.bullet.particles_name = "ps_wuxian_bolt_trail"
tt = E:register_t("bullet_water_sorceress_bolt", "bolt_enemy")

E:add_comps(tt, "force_motion")

b = balance.enemies.wukong.water_sorceress.ranged_attack
tt.render.sprites[1].prefix = "watersorceress_projectile"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.main_script.update = scripts.bolt_force_motion_kr5.update
tt.main_script.insert = scripts.bolt_force_motion_kr5.insert
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_type = b.damage_type
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 60
tt.bullet.max_speed = 600
tt.bullet.ignore_rotation = true
tt.bullet.align_with_trajectory = false
tt.bullet.force_align_particles_trajectory = true
tt.bullet.force_align_particles_trajectory_offset = math.rad(-90)
tt.bullet.hit_fx = "fx_water_sorceress_bolt_hit"
tt.bullet.particles_name = "ps_water_sorceress_bolt_trail"
tt.initial_impulse = 12000
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle_abs = math.pi / 2
tt.initial_impulse_reduction = 0.7
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 300
tt = E:register_t("bullet_hellfire_warlock_fireball", "bomb")
b = balance.enemies.wukong.hellfire_warlock.ranged
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.radius
tt.bullet.ignore_hit_offset = true
tt.bullet.flight_time = fts(20)
tt.bullet.hit_fx = "fx_hellfire_warlock_fireball_hit"
tt.bullet.damage_bans = bor(F_ENEMY)
tt.bullet.pop = nil
tt.bullet.particles_name = "ps_hellfire_warlock_bullet_trail"
tt.bullet.hit_decal = "decal_hellfire_warlock_flaming_ground"
tt.bullet.rotation_random = true
tt.bullet.align_with_trajectory = false
tt.bullet.rotation_speed = 60 * FPS * math.pi / 180
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.bullet_hellfire_warlock_fireball.update
tt.render.sprites[1].prefix = "hellfire_warlock_fireball"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5128205128205128)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "hellfire_warlock_fireball"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.5128205128205128)
tt.render.sprites[2].r = math.rad(180)
tt.sound_events.insert = "EnemyWarlockRangedCast"
tt.sound_events.hit = "EnemyWarlockRangedImpact"

tt = E:register_t("controller_stage_32_boss", "decal_scripted")
E:add_comps(tt, "editor", "ui")
b = balance.enemies.wukong.boss_dragon
tt.boss_controler_balance = b
tt.main_script.insert = scripts.controller_stage_32_boss.insert
tt.main_script.update = scripts.controller_stage_32_boss.update
tt.toggle_possessed = scripts.controller_stage_32_boss.toggle_possessed
tt.show_possessed = scripts.controller_stage_32_boss.show_possessed
tt.hide_possessed = scripts.controller_stage_32_boss.hide_possessed
tt.render.sid_dragon = 1
tt.exo_anim_map = {
	under_in = "dragon_redboy_BDef",
	under_samadhi_r_end = "dragon_redboy_BDef",
	idle = "dragon_redboy_CDef",
	under_samadhi_r_in = "dragon_redboy_BDef",
	under_samadhi_r_loop = "dragon_redboy_BDef",
	death_end_01 = "dragon_redboy_ADef",
	lava_crack = "dragon_redboy_CDef",
	under_samadhi_l_end = "dragon_redboy_BDef",
	under_screen_block = "dragon_redboy_BDef",
	death_in = "dragon_redboy_ADef",
	under_transform = "dragon_redboy_BDef",
	death_end_02 = "dragon_redboy_ADef",
	attack_basic_c = "dragon_redboy_ADef",
	under_talk = "dragon_redboy_BDef",
	stun_r = "dragon_redboy_CDef",
	under_idle = "dragon_redboy_BDef",
	under_samadhi_l_loop = "dragon_redboy_BDef",
	under_out = "dragon_redboy_CDef",
	death_eat_loop_b = "dragon_redboy_ADef",
	stun_l = "dragon_redboy_CDef",
	apear_in = "dragon_redboy_ADef",
	death_eat_loop_d = "dragon_redboy_ADef",
	talk = "dragon_redboy_CDef",
	death_eat_loop_a = "dragon_redboy_ADef",
	under_samadhi_l = "dragon_redboy_BDef",
	death_eat_loop_c = "dragon_redboy_ADef"
}
tt.render.sprites[tt.render.sid_dragon].prefix = tt.exo_anim_map.idle
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "idle"
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, 20)
tt.death_taps_per_mouth_phase = b.death_taps_per_mouth_phase
tt.bossfight_start_meteorite_side = balance.enemies.wukong.boss_redboy_teen.skyfire.bossfight_start_meteorite_side
tt.death_duration = b.death_duration
tt.ui_block_hand_fx = "fx_redboy_teen_hand"
tt.hand_decal_t = "dlc2_generic_tap_hand"
tt.boss_unit_spawn = "boss_redboy_teen"
tt.decal_fissure_fixed = "decal_dlc_wukong_flaming_ground"
tt.decal_fissure = "decal_stage_32_boss_fissure_ability"
tt.mod_tower_block = "mod_stage_32_tower_block"
tt.tower_block_mouth_fx = "fx_stage_32_dragon_mouth_fire"
tt.tower_block_mouth_fx_offset = v(0, 0)
tt.down_bubbles_decal = "decal_stage_32_boss_bubbles"
tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.has_nav_mesh = false
tt.ui.click_rect = r(-140, -100, 280, 400)
tt = E:register_t("decal_stage_32_boss_bubbles", "decal_scripted")

E:add_comps(tt, "tween")

tt.main_script.update = scripts.decal_stage_32_boss_bubbles.update
tt.render.sprites[1].prefix = "dragon_redboy_bubblesDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[1].sort_y_offset = -tt.render.sprites[1].offset.y
tt.down_splash_fx = "fx_stage_32_dragon_down_splash"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {fts(4), 255}}
tt.tween.props[1].loop = false

tt = E:register_t("mod_stage_32_tower_block", "mod_hide_tower")

E:add_comps(tt, "render")

tt.main_script.update = scripts.mod_stage_32_tower_blocked.update
tt.main_script.remove = nil
tt.render.sid_lava = 1
tt.render.sprites[tt.render.sid_lava].prefix = "dragon_rock_stunDef"
tt.render.sprites[tt.render.sid_lava].exo = true
tt.render.sprites[tt.render.sid_lava].name = "idle"
tt.render.sprites[tt.render.sid_lava].animated = true
tt.render.sprites[tt.render.sid_lava].draw_order = 20
tt.render.sprites[tt.render.sid_lava].z = Z_OBJECTS
tt.sound_restore = "Stage22TowerRestore"
tt.repair_cost = nil
tt.hand_decal_t = "dlc2_generic_tap_hand"
tt.skip_modifiers = {"mod_boss_crocs_tower_eat"}
tt.click_rect = r(-30, 0, 60, 60)
tt.menu_offset = v(0, 12)
tt.modifier.duration = nil

tt = E:register_t("mod_stage_32_lava_splash", "modifier")
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_stage_32_lava_splash.update
tt.paths_y = {
	[2] = 555
}
tt.paths_y_big = {
	[2] = 555
}
tt.modifier.duration = 1e+99
tt.fx = "fx_stage_32_lava_splash"
tt.fx_big = "fx_stage_32_lava_splash_big"
tt = E:register_t("mod_stage_32_lava_splash_2", "mod_stage_32_lava_splash")
tt.paths_y = {
	[3] = 555
}
tt.paths_y_big = {
	[3] = 555
}
tt.fx = "fx_stage_32_lava_splash_2"
tt.fx_big = "fx_stage_32_lava_splash_big_2"
tt = E:register_t("mod_stage_35_lava_splash", "mod_stage_32_lava_splash")
tt.main_script.insert = scripts.mod_stage_35_lava_splash.insert
tt.main_script.update = scripts.mod_stage_35_lava_splash.update
tt.main_script.remove = scripts.mod_stage_35_lava_splash.remove
tt.apply_if_enemy_is_to_right = true
tt.paths_x = {
	[15] = 0,
	[7] = 0
}
tt.paths_x_big = {
	[15] = 0,
	[7] = 0
}
tt.fx = "fx_stage_35_lava_splash"
tt.fx_big = "fx_stage_35_lava_splash_big"
tt = E:register_t("mod_stage_35_water_splash", "mod_stage_35_lava_splash")
tt.apply_if_enemy_is_to_right = false
tt.paths_x = {
	[8] = 1025
}
tt.paths_x_big = {
	[8] = 1025
}
tt.fx = "fx_stage_35_water_splash"
tt.fx_big = "fx_stage_35_water_splash_big"

tt = E:register_t("decal_stage33_envelop_spawn_pos", "decal")

E:add_comps(tt, "editor")

tt.render.sprites[1].name = "envelops_envelop_water_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hidden = true
tt.editor.overrides = {
	["render.sprites[1].hidden"] = false
}
tt = E:register_t("controller_stage33_envelops")

E:add_comps(tt, "main_script")

b = balance.specials.stage33_envelops
tt.main_script.update = scripts.controller_stage33_envelops.update
tt.envelop_t = "decal_stage33_envelop"
tt.decoy_t = "decal_stage33_envelop_decoy"
tt.envelop_spawn_pos_t = "decal_stage33_envelop_spawn_pos"
tt.decoy_chance = b.decoy_chance
tt.cooldown_min = b.cooldown_min
tt.cooldown_max = b.cooldown_max
tt = E:register_t("decal_stage33_envelop", "decal_scripted")

E:add_comps(tt, "ui")

b = balance.specials.stage33_envelops
tt.main_script.update = scripts.decal_stage33_envelop.update
tt.render.sprites[1].prefix = "envelops_envelop_water"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].z = Z_BACKGROUND
tt.fx_open = "fx_stage33_envelop_open"
tt.max_speed = b.max_speed
tt.min_speed = b.min_speed
tt.ui.can_click = true
tt.ui.click_rect = r(-18, -7, 36, 20)
tt = E:register_t("fx_stage33_envelop_open", "decal_scripted")
b = balance.specials.stage33_envelops
tt.main_script.update = scripts.fx_stage33_envelop_open.update
tt.render.sprites[1].name = "envelops_open_run"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "envelops_money_run"
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[2].sort_y_offset = -tt.render.sprites[2].offset.y - 10
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "envelops_portraits"
tt.render.sprites[3].name = "veznan"
tt.render.sprites[3].z = Z_EFFECTS
tt.render.sprites[3].offset = v(0, 45)
tt.render.sprites[3].sort_y_offset = -tt.render.sprites[3].offset.y - 1
tt.render.sprites[3].hidden = true
tt.cards = {{
	name = "veznan",
	gold = b.gold
}, {
	name = "versper",
	gold = b.gold
}, {
	name = "nyru",
	gold = b.gold
}}
tt.balatro_card = {
	name = "balatro",
	gold = b.gold_balatro
}
tt = E:register_t("fx_stage33_envelop_balatro_coins", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "envelops_money_run"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].offset = v(-20, 45)
tt.render.sprites[1].sort_y_offset = -tt.render.sprites[1].offset.y - 10
tt.render.sprites[1].hidden = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "envelops_money_run"
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].offset = v(25, 20)
tt.render.sprites[2].sort_y_offset = -tt.render.sprites[2].offset.y - 10
tt.render.sprites[2].hidden = true
tt.render.sprites[2].delay_start = 0.1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "envelops_money_run"
tt.render.sprites[3].z = Z_EFFECTS
tt.render.sprites[3].offset = v(0, 50)
tt.render.sprites[3].sort_y_offset = -tt.render.sprites[3].offset.y - 10
tt.render.sprites[3].hidden = true
tt.render.sprites[3].delay_start = 0.2
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "envelops_money_run"
tt.render.sprites[4].z = Z_EFFECTS
tt.render.sprites[4].offset = v(10, 30)
tt.render.sprites[4].sort_y_offset = -tt.render.sprites[4].offset.y - 10
tt.render.sprites[4].hidden = true
tt.render.sprites[4].delay_start = 0.3
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "envelops_money_run"
tt.render.sprites[5].z = Z_EFFECTS
tt.render.sprites[5].offset = v(-15, 40)
tt.render.sprites[5].sort_y_offset = -tt.render.sprites[5].offset.y - 10
tt.render.sprites[5].hidden = true
tt.render.sprites[5].delay_start = 0.4
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].name = "envelops_money_run"
tt.render.sprites[6].z = Z_EFFECTS
tt.render.sprites[6].offset = v(0, 30)
tt.render.sprites[6].sort_y_offset = -tt.render.sprites[6].offset.y - 10
tt.render.sprites[6].hidden = true
tt.render.sprites[6].delay_start = 0.5
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].name = "envelops_money_run"
tt.render.sprites[7].z = Z_EFFECTS
tt.render.sprites[7].offset = v(30, 50)
tt.render.sprites[7].sort_y_offset = -tt.render.sprites[7].offset.y - 10
tt.render.sprites[7].hidden = true
tt.render.sprites[7].delay_start = 0.6
tt = E:register_t("decal_stage33_envelop_decoy", "decal_stage33_envelop")
tt.render.sprites[1].prefix = "envelops_decoy_1"
tt.decoy = true
tt.ui.click_rect = r(-18, -7, 36, 20)

tt = E:register_t("stage_33_spawner")

E:add_comps(tt, "main_script", "spawner")

tt.main_script.update = scripts.stage_33_spawner.update
tt.spawn_data = nil
tt.spawner.eternal = true

tt = E:register_t("tower_holder_blocked_stage_33_house_1", "tower_holder_blocked_2")
tt.pre_destroy_thunders = scripts.stage_33_house_holder.pre_destroy_thunders
tt.destroy_house = scripts.stage_33_house_holder.destroy_house
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "stage33_casas_holder_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = v(0.5760714285714286, 0.3502604166666667)
tt.render.sprites[2] = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt.house_destroy_fx = "fx_stage_33_house_destroy"
tt.house_destroy_decal = "stage_33_house_destroyed_decal_1"
tt.pre_destroy_thunders_list = {{
	delay = 0,
	pos = v(388, 256)
}, {
	delay = 0.5,
	pos = v(450, 300)
}, {
	delay = 1.2,
	pos = v(530, 220)
}, {
	delay = 1.7,
	pos = v(545, 306)
}, {
	delay = 2,
	pos = v(692, 248)
}, {
	delay = 3.5,
	spawn_unit = "enemy_water_spirit_spawnless",
	pos = v(660, 343)
}, {
	delay = 3.8,
	spawn_unit = "enemy_water_spirit_spawnless",
	pos = v(620, 385)
}, {
	delay = 4.1,
	spawn_unit = "enemy_water_spirit_spawnless",
	pos = v(550, 340)
}}
tt = E:register_t("tower_holder_blocked_stage_33_house_2", "tower_holder_blocked_stage_33_house_1")
tt.render.sprites[1].name = "stage33_casas_holder_2"
tt.render.sprites[1].anchor = v(0.3246428571428571, 0.23697916666666666)
tt.house_destroy_decal = "stage_33_house_destroyed_decal_2"
tt.pre_destroy_thunders_list = {{
	delay = 1.7,
	pos = v(165, 259)
}, {
	delay = 2,
	pos = v(196, 275)
}, {
	delay = 3.5,
	pos = v(333, 295)
}, {
	delay = 3.8,
	pos = v(428, 270)
}, {
	delay = 4.1,
	pos = v(512, 321)
}, {
	delay = 4.4,
	pos = v(615, 380)
}, {
	delay = 4.7,
	pos = v(630, 420)
}, {
	delay = 5,
	pos = v(583, 524)
}, {
	delay = 5.3,
	pos = v(754, 600)
}}
tt = E:register_t("tower_holder_blocked_stage_33_house_3", "tower_holder_blocked_stage_33_house_1")
tt.render.sprites[1].name = "stage33_casas_holder_3"
tt.render.sprites[1].anchor = v(0.7917857142857143, 0.69140625)
tt.house_destroy_decal = "stage_33_house_destroyed_decal_3"
tt.pre_destroy_thunders_list = {{
	delay = 0,
	pos = v(388, 256)
}, {
	delay = 0.5,
	pos = v(450, 300)
}, {
	delay = 1.2,
	pos = v(530, 220)
}, {
	delay = 1.7,
	pos = v(545, 306)
}, {
	delay = 2,
	pos = v(692, 248)
}}
tt = E:register_t("tower_holder_blocked_stage_33_invisible", "tower_holder_blocked_2")
tt.appear = scripts.tower_holder_blocked_stage_33_invisible.appear
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt = E:register_t("tower_holder_blocked_stage_35_house_1", "tower_holder_blocked_2")
tt.pre_destroy = scripts.stage_35_house_holder.pre_destroy
tt.destroy_house = scripts.stage_35_house_holder.destroy_house
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "stage35_deco1"
tt.render.sprites[1].animated = falses
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor = v(0.13035714285714287, 0.2727864583333333)
tt.render.sprites[2] = nil
tt.cannonball_fx = "fx_stage_35_cannonball"
tt.spawn_escombro = "holder"
tt.sound = "Stage35Cinematic1"
tt.unit_spawns = {{
	unit = "soldier_stage_35_cannonball",
	spi = 2,
	ni_offset = 0
}, {
	unit = "soldier_stage_35_cannonball",
	spi = 1,
	ni_offset = 8
}, {
	unit = "soldier_stage_35_cannonball",
	spi = 3,
	ni_offset = 4
}}
tt.pre_destroy_cannonballs_list = {{
	delay = 5.6,
	spawn_escombro = "camino",
	pos = v(150, 240)
}, {
	delay = 6,
	spawn_escombro = "camino",
	pos = v(80, 350)
}}
tt.cinematic_camera_duration_offset = 0
tt.ui.can_click = false
tt.ui.can_select = false
tt = E:register_t("tower_holder_blocked_stage_35_house_2", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco2"
tt.render.sprites[1].anchor = v(0.7857142857142857, 0.7272135416666666)
tt.unit_spawns = nil
tt.spawn_escombro = "holder"
tt.cinematic_camera_duration_offset = -1.4
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil
tt = E:register_t("tower_holder_blocked_stage_35_house_3", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco3"
tt.render.sprites[1].anchor = v(0.23, 0.673828125)
tt.unit_spawns = nil
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = {{
	delay = 5.5,
	spawn_escombro = "camino",
	pos = v(300, 460)
}}
tt.sound = "Stage35Cinematic3"
tt = E:register_t("tower_holder_blocked_stage_35_house_4", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].name = "stage35_deco4"
tt.render.sprites[1].anchor = v(0.7767857142857143, 0.3190104166666667)
tt.spawn_escombro = "holder"
tt.pre_destroy_cannonballs_list = {{
	delay = 5.8,
	spawn_escombro = "camino",
	pos = v(883, 397)
}}
tt.sound = "Stage35Cinematic2"
tt = E:register_t("tower_holder_blocked_stage_35_house_5", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 1
tt.decal = "decal_stage_35_escombros_holder_2"
tt.cinematic_camera_duration_offset = -0.4
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = {{
	delay = 1.1,
	spawn_escombro = "camino",
	pos = v(872, 527)
}}
tt.sound = nil
tt = E:register_t("tower_holder_blocked_stage_35_house_6", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 3
tt.decal = "decal_stage_35_escombros_holder_1"
tt.spawn_escombro = "holder"
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil
tt = E:register_t("tower_holder_blocked_stage_35_house_7", "tower_holder_blocked_stage_35_house_1")
tt.render.sprites[1].hidden = true
tt.destroy_small_spawner_nmbr = 2
tt.decal = "decal_stage_35_escombros_holder_3"
tt.spawn_escombro = nil
tt.pre_destroy_cannonballs_list = nil
tt.sound = nil

tt = E:register_t("bullet_qiongqi_lightning", "bullet")
b = balance.enemies.wukong.qiongqi.ranged_attack
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_radius = b.damage_radius
tt.bullet.hit_time = fts(1)
tt.image_width = 100
tt.main_script.update = scripts.ray_qiongqi.update
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "qiongqi_attack"
tt.render.sprites[1].loop = false
tt.track_target = false
tt.ray_duration = fts(10)
tt.sound_events.insert = "EnemyQiongqiRanged"
tt = E:register_t("bullet_storm_elemental", "bomb")
b = balance.enemies.wukong.storm_elemental.ranged_attack
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.bullet_storm_elemental.update
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_radius = 62.400000000000006
tt.render.sprites[1].prefix = "storm_elemental_vfx_proyectile"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].animated = true
tt.render.sprites[1].scale = vv(0.7)
tt.start_fx = "fx_storm_elemental_bullet_start"
tt.bullet.pop = nil
tt.bullet.hide_radius = nil
tt.bullet.miss_fx = nil
tt.bullet.particles_name_1 = "ps_storm_elemental_bullet_trail_1"
tt.bullet.particles_name_2 = "ps_storm_elemental_bullet_trail_2"
tt.bullet.miss_decal = nil
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = "fx_storm_elemental_bullet_hit"
tt.bullet.hit_decal = {"decal_storm_elemental_bullet", "decal_storm_elemental_bullet_2"}
tt.bullet.hit_fx_water = "decal_storm_elemental_bullet"
tt.bullet.flight_time_base = fts(5)
tt.bullet.flight_time_factor = fts(0.016666666666666666)
tt.bullet.g = -2 / (fts(1) * fts(1)) * 0.5
tt.bullet.align_with_trajectory = false
tt.bullet.rotation_speed = 0
tt.sound_events.hit = "EnemyElementalRangedImpact"

tt = E:register_t("fx_mecanicas_ray_spawner", "fx")
tt.render.sprites[1].name = "vfx_mecanicas_ray_spawner_run"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].scale = vv(1.5)
tt = E:register_t("fx_stage_34_fuentes_splash", "fx")
tt.render.sprites[1].prefix = "stage_34_agua_splash"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt = E:register_t("fx_stage_34_fuentes_splash_barro", "fx_stage_34_fuentes_splash")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].prefix = "stage_34_barro_splash"
tt.sound_events.insert = "EnemyBossPrincessMudPoolSummon"
tt = E:register_t("fx_stage_35_cannonball", "decal_scripted")
tt.main_script.update = scripts.fx_stage_35_cannonball.update
tt.render.sprites[1].prefix = "stage5_destruccion_holderDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -30
tt.escombro_camino = "decal_stage_35_escombros_cannonball_camino"
tt.escombro_holder = "decal_stage_35_escombros_cannonball_holder"
tt = E:register_t("fx_stage_35_cannonball_open_path", "decal_scripted")
tt.main_script.update = scripts.fx_stage_35_cannonball_open_path.update
tt.render.sprites[1].prefix = "stage_5_pokebola_tntDef"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -130
tt = E:register_t("fx_stage_35_cannonball_block_path", "decal_scripted")
tt.main_script.update = scripts.fx_stage_35_cannonball_block_path.update
tt.render.sprites[1].prefix = "stage_5_bloqueo_pathDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -450
tt = E:register_t("fx_stage_35_small_spawner_fx", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage_5_spawner_fxDef"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].delay_start = fts(2)
tt.render.sprites[1].hidden = true

tt = E:register_t("ps_stage_34_petalos_1")

E:add_comps(tt, "pos", "particle_system")

tt.pos = v(1300, 0)
tt.particle_system.alphas = {255, 200, 150, 0}
tt.particle_system.emit_area_spread = v(0, 1300)
tt.particle_system.emission_rate = 0.5
tt.particle_system.emit_direction = -3.3161255787892245
tt.particle_system.emit_offset = {
	x = 20,
	y = 65.71428571428572
}
tt.particle_system.emit_rotation = 2.0943951023931953
tt.particle_system.emit_rotation_spread = 5.235987755982985
tt.particle_system.emit_speed = {50, 100}
tt.particle_system.emit_spread = 0.7853981633974483
tt.particle_system.name = "stage34_petalos_1"
tt.particle_system.particle_lifetime = {10, 23}
tt.particle_system.spin = {0.5, 5}
tt.particle_system.z = Z_OBJECTS_SKY
tt = E:register_t("ps_stage_34_petalos_2", "ps_stage_34_petalos_1")
tt.particle_system.name = "stage34_petalos_2"
tt = E:register_t("ps_bullet_enemy_noxious_horror")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "noxious_horror_projectile_vfx_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_area_spread = v(0, 0)
tt.particle_system.emit_rotation_spread = math.pi * 2

tt = E:register_t("tunnel_KR5_stage_34_ponds", "tunnel_KR5")
tt.main_script.update = scripts.tunnel_KR5_stage_34_ponds.update
tt.untargetable_distance = 5
tt.tunnel.speed_factor = 8
tt.tunnel.fx_use_unit_offset = false
tt.tunnel.pick_fx = "fx_stage_34_fuentes_splash"
tt.tunnel.place_fx = "fx_stage_34_fuentes_splash"
tt.tunnel.place_fx_barro = "fx_stage_34_fuentes_splash_barro"

tt = E:register_t("fx_enemy_fan_guard_melee_hit", "fx")
tt.render.sprites[1].name = "fan_guard_hit_run"
tt.render.sprites[1].sort_y_offset = -30

tt = E:register_t("mod_doom_bringer_tower_block_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.modifier.duration = fts(30)
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_doom_bringer_tower_block", "modifier")

E:add_comps(tt, "render", "tween")

b = balance.enemies.wukong.doom_bringer
tt.main_script.insert = scripts.mod_doom_bringer_tower_block.insert
tt.main_script.update = scripts.mod_doom_bringer_tower_block.update
tt.main_script.remove = scripts.mod_doom_bringer_tower_block.remove
tt.render.sprites[1].prefix = "doom_bringer_tower_stun_tower_block"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -15
tt.render.sprites[1].offset = v(0, 20)
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "doom_bringer_stun_explotion"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = -20
tt.render.sprites[2].scale = vv(2)
tt.render.sprites[2].offset = v(0, 20)
tt.modifier.duration = b.tower_curse.duration
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 0}, {1, 255}, {tt.modifier.duration - 0.5, 255}, {tt.modifier.duration, 0}}

tt = E:register_t("ps_enemy_demon_minotaur_charge_a")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "demon_minotaur_charge_dust_a"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 4
tt.particle_system.track_offset = v(0, 0)
tt.particle_system.z = Z_DECALS
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt = E:register_t("ps_enemy_demon_minotaur_charge_b")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "demon_minotaur_charge_dust_b"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 3
tt.particle_system.track_offset = v(0, 20)
tt.particle_system.z = Z_DECALS
tt.particle_system.particle_lifetime = {fts(44), fts(44)}

tt = E:register_t("soldier_stage_35_cannonball", "soldier_militia")
b = balance.specials.stage35_cannonball_soldier
E:add_comps(tt, "reinforcement", "nav_path", "tween")
-- tt.info.portrait = "gui_bottom_info_image_soldiers_0076"
tt.info.portrait = "kr5_info_portraits_soldiers_0001"
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health_bar.offset = v(0, 35)
tt.info.fn = scripts.soldier_charge.get_info
tt.info.random_name_count = 5
tt.info.random_name_format = "SOLDIER_CANNONBALL_%i_NAME"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_stage_35_cannonball.update
tt.melee.range = b.basic_attack.range
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].hit_time = fts(11)
tt.soldier.melee_slot_offset = v(8, 0)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "sate_5_mono_unit"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].anchor = vv(0.5)
tt.soldier.melee_slot_offset.x = 3
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.reinforcement.fade_out = false
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, ady(22))
tt.vis.flags = F_FRIEND
tt.ui.can_click = true
tt.ui.click_rect = r(-15, -2, 30, 35)
tt.patrol_pos_offset = v(15, 10)
tt.patrol_min_cd = 5
tt.patrol_max_cd = 10
tt.nav_path.dir = -1
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false
tt.tween.loop = false
tt.tween.disabled = true

tt = RT("sandstorm")
AC(tt, "render", "main_script", "pos", "nav_path", "motion")
tt.travel_animation_names = {"hero_alric_sand_travel_start", "hero_alric_sand_travel_loop", "hero_alric_sand_travel_end"}
tt.render.sprites[1].name = tt.travel_animation_names[1]
tt.render.sprites[1].animated = true
tt.render.sprites[1].prefix = nil
tt.spawn_entity = "enemy_fallen"
tt.main_script.insert = scripts.sandstorm.insert
tt.main_script.update = scripts.sandstorm.update
tt.search_soldier_chance = 0.3
tt.motion.max_speed = 150

tt = RT("mod_sandstorm_stun", "mod_stun")
tt.modifier.duration = 2.5

tt = RT("sandstorm_controller")
AC(tt, "main_script", "pos", "editor")
tt.main_script.update = scripts.sandstorm_controller.update
-- group_number: 第几波的开始执行沙尘暴事件
-- waves: 本波内的小波列表，每小波包含 entities（敌人类型和数量）与 delay（相对本大波开始的延迟，单位秒）

tt = RT("sandstorm_controller_s2004_campaign", "sandstorm_controller")
tt.spawns = {
	{
		group_number = 2,
		waves = {{
			entities = {
				["enemy_fallen"] = 3
			},
			delay = 5
		}}
	},
	{
		group_number = 3,
		waves = {{
			entities = {
				["enemy_bouncer"] = 8,
				["enemy_desert_wolf_small"] = 5
			},
			delay = 3
		}}
	},
	{
		group_number = 5,
		waves = {{
			entities = {
				["enemy_tremor"] = 4,
				["enemy_desert_wolf"] = 3
			},
			delay = 2
		}, {
			entities = {
				["enemy_immortal"] = 2,
				["enemy_desert_raider"] = 3
			},
			delay = 16
		}}
	},
	{
		group_number = 6,
		waves = {{
			entities = {
				["enemy_bouncer"] = 5
			},
			delay = 5
		}, {
			entities = {
				["enemy_bouncer"] = 5
			},
			delay = 15
		}}
	},
	{
		group_number = 7,
		waves = {{
			entities = {
				["enemy_wasp"] = 4
			},
			delay = 0
		}, {
			entities = {
				["enemy_immortal"] = 2,
				["enemy_desert_archer"] = 3
			},
			delay = 12
		}}
	},
	{
		group_number = 9,
		waves = {{
			entities = {
				["enemy_executioner"] = 1,
				["enemy_fallen"] = 4
			},
			delay = 0
		}, {
			entities = {
				["enemy_scorpion"] = 2
			},
			delay = 14
		}}
	},
	{
		group_number = 10,
		waves = {{
			entities = {
				["enemy_bouncer"] = 20
			},
			delay = 0
		}, {
			entities = {
				["enemy_fallen"] = 8
			},
			delay = 20
		}}
	},
	{
		group_number = 11,
		waves = {{
			entities = {
				["enemy_munra"] = 1,
				["enemy_executioner"] = 1,
				["enemy_desert_raider"] = 4
			},
			delay = 0
		}, {
			entities = {
				["enemy_scorpion"] = 2
			},
			delay = 18
		}, {
			entities = {
				["enemy_executioner"] = 1,
				["enemy_immortal"] = 3
			},
			delay = 35
		}}
	},
	{
		group_number = 12,
		waves = {{
			entities = {
				["enemy_bouncer"] = 12
			},
			delay = 0
		}, {
			entities = {
				["enemy_bouncer"] = 12
			},
			delay = 10
		}, {
			entities = {
				["enemy_bouncer"] = 12
			},
			delay = 20
		}, {
			entities = {
				["enemy_desert_spider"] = 2
			},
			delay = 30
		}}
	},
	{
		group_number = 13,
		waves = {{
			entities = {
				["enemy_scorpion"] = 2,
				["enemy_executioner"] = 2
			},
			delay = 0
		}, {
			entities = {
				["enemy_munra"] = 1
			},
			delay = 16
		}, {
			entities = {
				["enemy_scorpion"] = 1,
				["enemy_executioner"] = 1,
				["enemy_immortal"] = 2,
				["enemy_desert_spider"] = 1
			},
			delay = 34
		}}
	},
	{
		group_number = 14,
		waves = {{
			entities = {
				["enemy_bouncer"] = 12,
				["enemy_fallen"] = 6
			},
			delay = 0
		}, {
			entities = {
				["enemy_bouncer"] = 12,
				["enemy_fallen"] = 6
			},
			delay = 15
		}, {
			entities = {
				["enemy_bouncer"] = 12,
				["enemy_fallen"] = 6
			},
			delay = 30
		}}
	},
	{
		group_number = 15,
		waves = {{
			entities = {
				["enemy_executioner"] = 2,
				["enemy_munra"] = 1
			},
			delay = 0
		}, {
			entities = {
				["enemy_scorpion"] = 3
			},
			delay = 12
		}, {
			entities = {
				["enemy_munra"] = 2,
				["enemy_executioner"] = 2,
				["enemy_scorpion"] = 1
			},
			delay = 28
		}, {
			entities = {
				["enemy_executioner"] = 4,
				["enemy_munra"] = 2
			},
			delay = 48
		}}
	}
}

tt = RT("sandstorm_controller_s2004_heroic", "sandstorm_controller")
tt.spawns = {{
	group_number = 1,
	waves = {{
		entities = {
			["enemy_fallen"] = 4
		},
		delay = 5
	}}
}, {
	group_number = 2,
	waves = {{
		entities = {
			["enemy_bouncer"] = 10,
			["enemy_desert_raider"] = 4
		},
		delay = 3
	}}
}, {
	group_number = 3,
	waves = {{
		entities = {
			["enemy_tremor"] = 5,
			["enemy_desert_wolf"] = 4
		},
		delay = 2
	}, {
		entities = {
			["enemy_immortal"] = 3,
			["enemy_fallen"] = 5
		},
		delay = 14
	}}
}, {
	group_number = 4,
	waves = {{
		entities = {
			["enemy_bouncer"] = 12
		},
		delay = 0
	}, {
		entities = {
			["enemy_immortal"] = 3,
			["enemy_desert_raider"] = 6
		},
		delay = 10
	}}
}, {
	group_number = 5,
	waves = {{
		entities = {
			["enemy_scorpion"] = 2,
			["enemy_bouncer"] = 15
		},
		delay = 0
	}, {
		entities = {
			["enemy_munra"] = 1,
			["enemy_immortal"] = 4
		},
		delay = 16
	}, {
		entities = {
			["enemy_executioner"] = 1,
			["enemy_fallen"] = 8
		},
		delay = 32
	}}
}, {
	group_number = 6,
	waves = {{
		entities = {
			["enemy_munra"] = 1,
			["enemy_executioner"] = 1
		},
		delay = 0
	}, {
		entities = {
			["enemy_scorpion"] = 3,
			["enemy_desert_spider"] = 1,
			["enemy_bouncer"] = 10
		},
		delay = 20
	}, {
		entities = {
			["enemy_bouncer"] = 20,
			["enemy_fallen"] = 10
		},
		delay = 35
	}, {
		entities = {
			["enemy_executioner"] = 2,
			["enemy_immortal"] = 6
		},
		delay = 50
	}}
}}

tt = RT("sandstorm_controller_s2004_iron", "sandstorm_controller")
tt.spawns = {{
	group_number = 1,
	waves = {{
		entities = {
			["enemy_bouncer"] = 3
		},
		delay = 10
	}, {
		entities = {
			["enemy_bouncer"] = 6
		},
		delay = 20
	}, {
		entities = {
			["enemy_bouncer"] = 9
		},
		delay = 30
	}, {
		entities = {
			["enemy_desert_raider"] = 9
		},
		delay = 45
	}, {
		entities = {
			["enemy_fallen"] = 9
		},
		delay = 60
	}, {
		entities = {
			["enemy_desert_archer"] = 6
		},
		delay = 80
	}, {
		entities = {
			["enemy_bouncer"] = 12,
			["enemy_fallen"] = 8
		},
		delay = 120
	}, {
		entities = {
			["enemy_desert_raider"] = 18,
			["enemy_desert_archer"] = 8
		},
		delay = 160
	}, {
		entities = {
			["enemy_immortal"] = 8,
			["enemy_fallen"] = 24
		},
		delay = 200
	}, {
		entities = {
			["enemy_bouncer"] = 12,
			["enemy_desert_archer"] = 6,
			["enemy_desert_raider"] = 6,
			["enemy_fallen"] = 12,
			["enemy_immortal"] = 6
		},
		delay = 240
	}}
}}

tt = RT("tower_random_advanced_archer", "tower")
local GS = require("kr1.game_settings")
tt.tower.price = 0
tt.info.fn = scripts.tower_random.get_info
tt.desc_key = "TOWER_RANDOM_ADVANCED_ARCHER_DESCRIPTION"
for i = 4, #GS.archer_towers do
	tt.tower.price = tt.tower.price + E:get_template(GS.archer_towers[i]).tower.price
end
tt.tower.price = math.floor(tt.tower.price / (#GS.archer_towers - 3))

tt = RT("tower_random_advanced_mage", "tower")
tt.tower.price = 0
tt.info.fn = scripts.tower_random.get_info
for i = 4, #GS.mage_towers do
	tt.tower.price = tt.tower.price + E:get_template(GS.mage_towers[i]).tower.price
end
tt.desc_key = "TOWER_RANDOM_ADVANCED_MAGE_DESCRIPTION"
tt.tower.price = math.floor(tt.tower.price / (#GS.mage_towers - 3))

tt = RT("tower_random_advanced_engineer", "tower")
tt.tower.price = 0
tt.info.fn = scripts.tower_random.get_info
for i = 4, #GS.engineer_towers do
	tt.tower.price = tt.tower.price + E:get_template(GS.engineer_towers[i]).tower.price
end
tt.desc_key = "TOWER_RANDOM_ADVANCED_ENGINEER_DESCRIPTION"
tt.tower.price = math.floor(tt.tower.price / (#GS.engineer_towers - 3))

tt = RT("tower_random_advanced_barrack", "tower")
tt.tower.price = 0
tt.info.fn = scripts.tower_random.get_info
for i = 4, #GS.barrack_towers do
	tt.tower.price = tt.tower.price + E:get_template(GS.barrack_towers[i]).tower.price
end
tt.desc_key = "TOWER_RANDOM_ADVANCED_BARRACK_DESCRIPTION"
tt.tower.price = math.floor(tt.tower.price / (#GS.barrack_towers - 3))
