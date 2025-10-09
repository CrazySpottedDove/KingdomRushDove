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

----------
require("foundamental_towers")()

package.loaded.mage_towers = nil
require("mage_towers")

require("engineer_towers")()
require("archer_towers")()
require("barrack_towers")()
require("enemies")()
require("heroes")()
require("boss")()
package.loaded.hero_boss = nil
require("hero_boss")
-- require("game_templates_5")()
----------

tt = E:register_t("pop_crit", "pop")
tt.render.sprites[1].name = "pop_0003"
tt = E:register_t("pop_headshot", "pop")
tt.render.sprites[1].name = "pop_0007"

tt = RT("ps_bolt_sorcerer", "particle_system")
tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = false
tt.particle_system.emit_area_spread = vec_2(6, 6)
tt.particle_system.emission_rate = 60
tt.particle_system.name = "sorcererbolt_particle"
-- tt.particle_system.particle_lifetime = {fts(2), fts(5)}
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.rotation_spread = math.pi
tt.particle_system.scale_var = {0.8, 0.6}
tt.particle_system.scales_x = {1, 0.3}
tt.particle_system.scales_y = {1, 0.3}
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

tt = E:register_t("ps_flare_flareon", "particle_system")
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
tt = RT("ps_elora_run")

AC(tt, "pos", "particle_system")

tt.particle_system.alphas = {255, 0}
tt.particle_system.animated = true
tt.particle_system.emission_rate = 10
tt.particle_system.loop = false
tt.particle_system.z = Z_DECALS + 1
tt.particle_system.name = "ps_hero_elora_run"
tt.particle_system.particle_lifetime = {0.8, 1}
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
tt = RT("ps_hero_ignus_smoke", "ps_power_fireball")
tt.particle_system.scales_x = {2, 3}
tt.particle_system.scales_y = {2, 3}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_offset = vec_2(0, 17)
tt.particle_system.name = "ps_hero_ignus_smoke"
tt.particle_system.sort_y_offset = -16
tt.particle_system.z = Z_OBJECTS
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
tt = RT("fx_teleport_arcane", "fx")
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].prefix = "fx_teleport_arcane"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}

tt = RT("fx_bolt_sorcerer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_sorcerer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_mod_polymorph_sorcerer_small", "fx")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_small"
tt.render.sprites[1].anchor.y = 0.5
tt = RT("fx_mod_polymorph_sorcerer_big", "fx_mod_polymorph_sorcerer_small")
tt.render.sprites[1].name = "fx_mod_polymorph_sorcerer_big"
tt = RT("fx_hacksaw_sawblade_hit", "fx")
tt.render.sprites[1].prefix = "fx_hacksaw_sawblade"
tt.render.sprites[1].name = "hit"
tt = RT("fx_hero_thor_thunderclap_disipate", "fx")
tt.render.sprites[1].name = "fx_hero_thor_thunderclap_disipate"
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("fx_bolt_elora_hit", "fx")
tt.render.sprites[1].prefix = "fx_bolt_elora"
tt.render.sprites[1].name = "hit"
tt = RT("fx_bolt_magnus_hit", "fx")
tt.render.sprites[1].name = "bolt_magnus_hit"
tt = E:register_t("fx_ignus_burn", "fx")
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt = RT("fx_juggernaut_smoke", "fx")
tt.render.sprites[1].name = "fx_juggernaut_smoke"
tt.render.sprites[1].anchor.y = 0.27
tt = RT("fx_jt_tower_click", "fx")
tt.render.sprites[1].name = "fx_jt_tower_click"
tt.render.sprites[1].anchor.y = 0.3
tt = RT("fx_moloch_ring", "fx")
tt.render.sprites[1].name = "fx_moloch_ring"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_moloch_rocks", "fx")
tt.render.sprites[1].name = "fx_moloch_rocks"
tt.render.sprites[1].anchor.y = 0.24242424242424243
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_myconid_spores", "fx")
tt.render.sprites[1].name = "fx_myconid_spores"
tt.render.sprites[1].anchor.y = 0.8
tt = RT("fx_blackburn_smash", "fx")
tt.render.sprites[1].name = "fx_blackburn_smash"
tt.render.sprites[1].anchor.y = 0.1588785046728972
tt = RT("fx_veznan_demon_fire", "fx")
tt.render.sprites[1].name = "fx_veznan_demon_fire"
tt = E:register_t("fx_explosion_rotten_shot", "fx")
tt.render.sprites[1].name = "explosion_rotten_shot"
tt.render.sprites[1].anchor = vec_2(0.5, 0.33783783783783783)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_explosion_flareon_flare", "fx")
tt.render.sprites[1].name = "explosion_flare_flareon"
tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bolt_necromancer_hit", "fx")
tt.render.sprites[1].prefix = "bolt_necromancer"
tt.render.sprites[1].name = "hit"
tt = RT("fx_demon_portal_out", "fx")
tt.render.sprites[1].prefix = "fx_demon_portal_out"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big"}
tt = RT("fx_bolt_witch_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_witch_hit"
tt = E:register_t("fx_hobgoblin_ground_hit", "fx")
tt.render.sprites[1].name = "fx_hobgoblin_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].draw_order = 2
tt = RT("decal_paladin_holystrike", "decal_timed")
tt.render.sprites[1].name = "decal_paladin_holystrike"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_zombiemancer_raise", "decal_timed")
tt.render.sprites[1].name = "decal_paladin_holystrike"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].color = {0, 255, 0}

tt = E:register_t("decal_oni_torment_sword", "decal_scripted")
tt.render.sprites[1].prefix = "decal_oni_torment_sword_1"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.main_script.update = scripts.decal_oni_torment_sword.update
tt.duration = 0.5
tt.delay = 0.01
tt.sword_names = {"decal_oni_torment_sword_1", "decal_oni_torment_sword_2", "decal_oni_torment_sword_3",
                  "decal_oni_torment_sword_1"}

tt = RT("decal_ignus_flaming", "decal_timed")
tt.render.sprites[1].name = "decal_ignus_flaming"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_ingvar_attack", "decal_tween")
tt.render.sprites[1].name = "hero_viking_axeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 200}, {1, 200}, {1.5, 0}}
tt = RT("decal_jt_ground_hit", "decal_timed")
tt.render.sprites[1].name = "decal_jt_ground_hit"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_jt_tap", "decal_loop")
tt.render.sprites[1].random_ts = fts(7)
tt.render.sprites[1].name = "decal_jt_tap"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y = -40
tt.render.sprites[1].offset = vec_2(20, 40)
tt = RT("decal_blackburn_smash_ground", "decal_timed")
tt.render.sprites[1].name = "fx_blackburn_smash_ground"
tt.render.sprites[1].z = Z_DECALS
tt = RT("veznan_portal", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "veznan_portal"
tt.render.sprites[1].z = Z_DECALS
tt.fx_out = "fx_demon_portal_out"
tt.main_script.update = scripts.veznan_portal.update
tt.out_nodes = nil
tt.spawn_groups = {{{0.5, {{4, 7, "enemy_demon"}}}, {0.8, {{3, 3, "enemy_demon_wolf"}}},
                    {1, {{5, 5, "enemy_demon"}, {1, 1, "enemy_demon_mage"}}}},
                   {{0.5, {{2, 5, "enemy_demon"}}}, {0.8, {{2, 2, "enemy_demon_wolf"}}}, {1, {{3, 3, "enemy_demon"}}}},
                   {{1, {{3, 3, "enemy_demon"}}}}}
tt.portal_idx = 1
tt.spawn_interval = fts(30)
tt.pi = 1
tt = E:register_t("decal_s12_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "boss_veznan_taunts_love_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
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
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
tt = RT("decal_veznan_strike", "decal_timed")
tt.render.sprites[1].name = "decal_veznan_strike"
tt.render.sprites[1].z = Z_DECALS
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
tt = RT("decal_eb_veznan_white_circle", "decal_tween")
tt.render.sprites[1].name = "decal_veznan_white_circle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(65), vec_1(1)}, {fts(65) + 0.5, vec_1(20)}, {fts(65) + 4.5, vec_1(20)}}
tt = RT("decal_hobgoblin_ground_hit", "decal_tween")
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.render.sprites[1].name = "hobgoblin_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].animated = false

tt = RT("tower_sasquash_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "main_script")

tt.tower.type = "holder_sasquash"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.main_script.update = scripts.tower_sasquash_holder.update
tt.info.i18n_key = "SPECIAL_SASQUASH_REPAIR"
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers" or "info_portraits_towers") .. "_0014"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "sasquash_frozen_0001"
tt.render.sprites[1].offset = vec_2(-9, 13)
tt.render.sprites[1].z = Z_TOWER_BASES - 2
tt.ui.click_rect = r(-40, -30, 80, 90)
tt.unfreeze_radius = 60
tt.unfreeze_fx = "fx_tower_sasquash_unfreeze"
tt.unfreeze_upgrade_to = "tower_sasquash"
tt.unfreeze_rect = r(290, 480, 120, 90)
tt = RT("fx_tower_sasquash_unfreeze", "fx")
tt.render.sprites[1].name = "tower_sasquash_unfreeze"
tt.render.sprites[1].offset = vec_2(-9, 13)
tt.render.sprites[1].z = Z_EFFECTS
tt = RT("tower_sasquash", "tower")

AC(tt, "barrack")

tt.info.portrait = (IS_PHONE_OR_TABLET and "portraits_towers" or "info_portraits_towers") .. "_0014"
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



tt = RT("soldier_sasquash", "soldier_militia")
image_y = 80
anchor_y = 0.17
tt.health.hp_max = 2500
tt.health_bar.offset = vec_2(0, ady(73))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 12
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0034" or "info_portraits_sc_0034"
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
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, ady(30))
tt.unit.price = 400

tt = RT("soldier_gerald_paladin", "soldier_militia")
AC(tt, "reinforcement", "melee", "tween", "nav_grid")
anchor_y = 0.15
anchor_x = 0.5
image_y = 41
image_x = 58
tt.controable = true
tt.controable_other = true
tt.health.armor = 0.4
tt.health.dead_lifetime = 3
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(adx(28), ady(40))
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.remove = scripts.soldier_reinforcement.remove
tt.main_script.update = scripts.soldier_reinforcement.update
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0026" or "info_portraits_sc_0026"
tt.info.random_name_count = 20
tt.info.random_name_format = "SOLDIER_PALADIN_RANDOM_%i_NAME"
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
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
tt.reinforcement.duration = 14
tt.reinforcement.fade = true
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.remove = false
tt.tween.reverse = false

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
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_sc_0026" or "info_portraits_sc_0026"
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
tt = RT("re_farmer", "soldier_militia")
AC(tt, "reinforcement", "tween", "nav_grid")
image_y = 44
anchor_y = 0.1590909090909091
tt.cooldown = 10
tt.health.armor = 0
tt.health.hp_max = 30
tt.health_bar.offset = vec_2(0, ady(32))
tt.info.portrait_idxs = {15, 16, 14}
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
tt = RT("re_farmer_well_fed", "re_farmer")
tt.unit.level = 1
tt.health.hp_max = 50
tt.health.armor = 0
tt.melee.attacks[1].damage_max = 3
tt.motion.max_speed = 65
tt = RT("re_conscript", "re_farmer")
tt.info.portrait_idxs = {41, 38, 35}
tt.unit.level = 2
tt.health.hp_max = 70
tt.health.armor = 0.1
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].damage_max = 4
tt.motion.max_speed = 70
tt = RT("re_warrior", "re_farmer")
tt.info.portrait_idxs = {42, 39, 36}
tt.unit.level = 3
tt.health.hp_max = 90
tt.health.armor = 0.2
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].damage_max = 6
tt.motion.max_speed = 75
tt = RT("re_legionnaire", "re_farmer")
tt.info.portrait_idxs = {43, 40, 37}
tt.unit.level = 4
tt.health.hp_max = 110
tt.health.armor = 0.3
tt.health_bar.offset = vec_2(0, ady(34))
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 10
tt.motion.max_speed = 80
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
    for j, name in ipairs({"re_farmer", "re_farmer_well_fed", "re_conscript", "re_warrior", "re_legionnaire",
                           "re_legionnaire_ranged"}) do
        local fn = name .. "_" .. i
        local base_t = E:get_template(name)
        local t = RT(fn, base_t)
        t.render.sprites[1].prefix = fn

        if IS_PHONE_OR_TABLET then
            t.info.portrait = string.format("portraits_sc_00%02d", t.info.portrait_idxs[i])
        else
            t.info.portrait = string.format("info_portraits_sc_00%02d", t.info.portrait_idxs[i])
        end
    end
end

for i = 1, 3 do
    E:set_template("re_current_" .. i, E:get_template("re_farmer_" .. i))
end

tt = RT("soldier_magnus_illusion", "soldier_militia")
AC(tt, "reinforcement", "ranged", "tween")
image_y = 76
image_x = 60
anchor_y = 0.14
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 33)
tt.health.dead_lifetime = fts(14)
tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_hero_0005" or "info_portraits_hero_0004"
tt.info.i18n_key = "HERO_MAGE_SHADOW"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_magnus_illusion.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 45
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_magnus_illusion"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 23)}
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].damage_max = nil
tt.ranged.attacks[1].damage_min = nil
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = fts(33)
tt.regen.cooldown = 1
tt.render.sprites[1].prefix = "soldier_magnus_illusion"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].alpha = 180
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(6), vec_2(0, 0)}}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-13, -5, 26, 32)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.price = 0
tt.vis.bans = bor(F_LYCAN, F_SKELETON, F_CANNIBALIZE)

tt = RT("spear_legionnaire", "arrow")
tt.bullet.damage_min = 24
tt.bullet.damage_max = 40
tt.bullet.flight_time = fts(20)
tt.bullet.miss_decal = "decal_spear"
tt.render.sprites[1].name = "spear"
tt.sound_events.insert = "AxeSound"

tt = RT("arrow_shadow_archer", "arrow")
tt.bullet.damage_min = 20
tt.bullet.damage_max = 30

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
tt = E:register_t("hammer_hero_thor", "bolt")
tt.bullet.acceleration_factor = 0.05
tt.bullet.min_speed = 300
tt.bullet.max_speed = 900
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hit_blood_fx = nil
tt.bullet.hit_fx = nil
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_hero_thor_thunderclap"
tt.bullet.pop = nil
tt.render.sprites[1].prefix = "hammer_hero_thor"
tt.sound_events.insert = nil
tt = RT("bolt_elora_freeze", "bolt")
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "bolt_elora"
tt.bullet.hit_fx = "fx_bolt_elora_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.mod = "mod_elora_bolt_freeze"
tt.bullet.damage_min = 14
tt.bullet.damage_max = 41
tt.bullet.xp_gain_factor = 2
tt = RT("bolt_elora_slow", "bolt_elora_freeze")
tt.bullet.mod = "mod_elora_bolt_slow"
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
tt = RT("bolt_magnus_illusion", "bolt_magnus")
tt.bullet.damage_min = nil
tt.bullet.damage_max = nil
tt.bullet.xp_gain_factor = nil

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
tt = RT("ray_arcane_disintegrate", "ray_arcane")
tt.bullet.mod = "mod_ray_arcane_disintegrate"
tt.image_width = 166
tt.render.sprites[1].name = "ray_arcane_disintegrate"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "DesintegrateSound"
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

tt = RT("ray_sunray", "bullet")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_MAGICAL, DAMAGE_NO_SPAWNS)
tt.bullet.hit_time = fts(3)
tt.bullet.mod = "mod_ray_sunray_hit"
tt.bullet.damage_max = 150
tt.bullet.damage_min = 150
tt.bullet.damage_inc = 30
tt.bullet.reduce_magic_armor = 0.05
tt.image_width = 58
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].name = "ray_sunray"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "PolymorphSound"
tt.track_target = true
tt.ray_duration = fts(11)
tt.ray_y_scales = {0.4, 0.6, 0.8, 1}

tt = RT("ray_hero_thor", "ray_tesla")
tt.bullet.mod = "mod_ray_hero_thor"
tt.render.sprites[1].name = "ray_hero_thor"
tt.main_script.update = scripts.ray_thor.update

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

tt = E:register_t("enemy_spider_rotten_egg", "decal_scripted")
E:add_comps(tt, "render", "spawner", "tween")
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

tt = E:register_t("myconid_spawner")

E:add_comps(tt, "pos", "spawner", "main_script")

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
tt = RT("elora_ice_spike", "bullet")
tt.main_script.update = scripts.elora_ice_spike.update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 51.2
tt.bullet.damage_type = DAMAGE_MAGICAL_EXPLOSION
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.mod = nil
tt.bullet.hit_time = 0.1
tt.bullet.duration = 2
tt.spike_1_anchor_y = 0.16
tt.render.sprites[1].prefix = "elora_ice_spike_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor.y = 0.2
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_frost_spikes_decal"
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.delayed_insert = "HeroFrostIceRainDrop"
tt.sound_events.ice_break = "HeroFrostIceRainBreak"



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

tt = RT("aura_chill_elora", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 3
tt.aura.mod = "mod_elora_chill"
tt.aura.radius = 44.800000000000004
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_chill_elora.update
tt.render.sprites[1].prefix = "decal_elora_chill_"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.2, 0}}

tt = RT("aura_ignus_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_ignus_idle"
tt.emit_states = {"idle", "attack"}
tt.main_script.update = scripts.aura_ignus_particles.update
tt.particle_offsets = {vec_2(-17, 16), vec_2(-12, 27), vec_2(4, 37), vec_2(2, 35), vec_2(12, 22), vec_2(14, 13)}
tt.flip_offset = vec_2(3, 0)
tt = RT("aura_ignus_surge_of_flame", "aura")
tt.aura.cycle_time = fts(1)
tt.aura.duration = 0
tt.aura.damage_min = nil
tt.aura.damage_max = nil
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_radius = 25
tt.aura.hit_fx = "fx_ignus_burn"
tt.damage_state = "surgeOfFlame"
tt.main_script.update = scripts.aura_ignus_surge_of_flame.update
tt.particles_name = "ps_hero_ignus_smoke"

tt = RT("aura_ingvar_bear_regenerate", "aura")
AC(tt, "regen")
tt.aura.duration = 0
tt.main_script.update = scripts.aura_ingvar_bear_regenerate.update
tt.regen.cooldown = 1
tt.regen.health = 5

tt = RT("aura_10yr_idle", "aura")
tt.aura.duration = 0
tt.particles_name = "ps_hero_10yr_idle"
tt.emit_states = {"idle", "running"}
tt.main_script.update = scripts.aura_10yr_particles.update
tt.particle_offsets = {vec_2(-25.714285714285715, 25.714285714285715), vec_2(-15.714285714285715, 37.142857142857146),
                       vec_2(0, 45.714285714285715), vec_2(8.571428571428571, 42.85714285714286),
                       vec_2(14.285714285714286, 32.85714285714286), vec_2(21.42857142857143, 21.42857142857143)}
tt.flip_offset = vec_2(3, 0)

tt = E:register_t("aura_troll_regen", "aura")
AC(tt, "regen")
tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 1
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false

tt = E:register_t("aura_forest_troll_regen", "aura_troll_regen")
AC(tt, "regen")
tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(4)
tt.regen.health = 4

tt = E:register_t("aura_troll_axe_thrower_regen", "aura_troll_regen")
AC(tt, "regen")
tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(6)
tt.regen.health = 2

tt = E:register_t("aura_troll_brute_regen", "aura_forest_troll_regen")

tt = E:register_t("aura_troll_chieftain_regen", "aura_troll_regen")
tt.regen.cooldown = fts(6)
tt.regen.health = 4

tt = E:register_t("aura_ulgukhai_regen", "aura_forest_troll_regen")
tt.regen.ignore_mods = true

tt = E:register_t("aura_goblin_zapper_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 50
tt.aura.damage_max = 150
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update

tt = E:register_t("aura_demon_death", "aura")
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

tt = E:register_t("aura_demon_mage_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400

tt = E:register_t("aura_demon_wolf_death", "aura_demon_death")
tt.aura.damage_min = 70
tt.aura.damage_max = 140

tt = E:register_t("aura_rotten_lesser_death", "aura")
tt.aura.cycles = 1
tt.aura.radius = 60
tt.aura.mod = "mod_rotten_lesser_pestilence"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.vis_flags = bor(F_MOD, F_POISON)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("aura_swamp_thing_regen", "aura")
AC(tt, "regen")
tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(2)
tt.regen.health = 1
tt.regen.ignore_stun = false
tt.regen.ignore_freeze = false

tt = E:register_t("aura_flareon_death", "aura_demon_death")
tt.aura.damage_min = 40
tt.aura.damage_max = 80

tt = E:register_t("aura_gulaemon_death", "aura_demon_death")
tt.aura.damage_min = 200
tt.aura.damage_max = 400

tt = E:register_t("aura_burning_floor", "aura")
E:add_comps(tt, "render", "tween")
tt.aura.active = false
tt.aura.cycle_time = 0.3
tt.aura.mod = "mod_burning_floor_burn"
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_MOD, F_BURN, F_RANGED)
tt.aura.vis_bans = bor(F_ENEMY,F_FLYING)
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

tt = E:register_t("burning_floor_controller")
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.burning_floor_controller.update
tt = E:register_t("aura_demon_cerberus_death", "aura_demon_death")
tt.aura.damage_min = 666
tt.aura.damage_max = 666
tt.aura.radius = 120

tt = E:register_t("aura_troll_skater_regen", "aura_troll_regen")

AC(tt, "regen")

tt.regen.cooldown = fts(4)
tt.regen.health = 1
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
tt = RT("graveyard_s110", "graveyard_controller")
tt.main_script.update = scripts.graveyard_s110.update
tt.graveyard.keep_gold = false
tt.graveyard.spawns_by_health = {
    {"enemy_skeleton", 400},
    {"enemy_halloween_zombie", 600},
    {"enemy_skeleton_big", 1000},
    {"enemy_gnoll_bloodsydian", 2000},
    {"enemy_blade", 3750},
    {"eb_alleria", 9e+99}
}
tt.graveyard.vis_has = bor(F_ENEMY, F_FRIEND)
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_HERO
tt = RT("swamp_controller", "graveyard_controller")
tt.graveyard.spawns_by_health = {{"enemy_zombie", 400}, {"enemy_swamp_thing", 9e+99}}
tt.graveyard.excluded_templates = {"soldier_alleria_wildcat", "soldier_magnus_illusion"}
tt.graveyard.keep_gold = false
tt.graveyard.vis_has = F_FRIEND
tt.graveyard.vis_flags = F_SKELETON
tt.graveyard.vis_bans = F_HERO
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
tt = RT("s11_lava_spawner")

AC(tt, "main_script")

tt.main_script.update = scripts.s11_lava_spawner.update
tt.entity = "enemy_lava_elemental"
tt.cooldown = 400
tt.cooldown_after = 120
tt.pi = 4
tt.sound = "RockElementalDeath"
tt = RT("jt_spawner_aura", "aura")
tt.main_script.update = scripts.jt_spawner_aura.update
tt.aura.track_source = true
tt.spawn_data = {{"enemy_whitewolf", 8, 0, 2, 1}, {"enemy_whitewolf", 8, fts(20), 2, 2}, {"enemy_yeti", 19, 0, 3, 1}}
tt = E:register_t("blackburn_aura", "aura")
tt.main_script.update = scripts.blackburn_aura.update
tt.aura.cycle_time = 0.5
tt.aura.duration = -1
tt.aura.radius = 106.38297872340426
tt.aura.raise_entity = "enemy_skeleton_big"
tt.count_group_name = "blackburn_skeletons"
tt.count_group_type = COUNT_GROUP_CONCURRENT
tt.count_group_max = 15
tt = RT("veznan_souls_aura", "aura")
tt.main_script.update = scripts.veznan_souls_aura.update
tt.aura.track_source = true
tt.souls = {
    angles = {d2r(30), d2r(130)},
    count = 60,
    delay_frames = 10,
    entity = "veznan_soul"
}
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
tt = RT("aura_elder_shaman_healing", "aura")

AC(tt, "render", "tween")

tt.aura.mod = "mod_elder_shaman_heal"
tt.aura.mod_args = nil
tt.aura.cycle_time = 0.5
tt.aura.duration = nil
tt.aura.radius = nil
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.aura.requires_magic = true
tt.render.sprites[1].alpha = 50
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "totem_groundeffect-orange_0002"
tt.render.sprites[1].scale = vec_2(0.64, 0.64)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "totem_groundeffect-orange_0001"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].anchor = vec_2(0.5, 0.12264150943396226)
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "start"
tt.render.sprites[3].prefix = "elder_shaman_totem_orange"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].anchor = vec_2(0.5, 0.12264150943396226)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].loop = true
tt.render.sprites[4].name = "elder_shaman_totem_orange_fx"
tt.main_script.update = scripts.aura_elder_shaman.update
tt.sound_events.insert = "EndlessOrcsTotemHealing"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(0.64, 0.64)}, {fts(15), vec_2(1, 1)}, {fts(30), vec_2(1.6, 1.6)}}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 50}, {fts(10), 255}, {fts(20), 255}, {fts(30), 0}}
tt.tween.props[2].loop = true
tt = RT("aura_elder_shaman_damage", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_damage"
tt.aura.cycle_time = 0.2
tt.aura.requires_magic = true
tt.aura.vis_bans = bor(F_BOSS, F_ENEMY)
tt.render.sprites[1].name = "totem_groundeffect-red_0002"
tt.render.sprites[2].name = "totem_groundeffect-red_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_red"
tt.render.sprites[4].name = "elder_shaman_totem_red_fx"
tt.sound_events.insert = "EndlessOrcsTotemDamage"
tt = RT("aura_elder_shaman_speed", "aura_elder_shaman_healing")
tt.aura.mod = "mod_elder_shaman_speed"
tt.aura.requires_magic = true
tt.aura.cycle_time = 0.2
tt.render.sprites[1].name = "totem_groundeffect-ligthBlue_0002"
tt.render.sprites[2].name = "totem_groundeffect-lightBlue_0001"
tt.render.sprites[3].prefix = "elder_shaman_totem_blue"
tt.render.sprites[4].name = "elder_shaman_totem_blue_fx"
tt.sound_events.insert = "EndlessOrcsTotemSpeed"
tt = RT("mod_arcane_shatter", "mod_damage")
tt.damage_min = 0.035
tt.damage_max = 0.035
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)

tt = RT("mod_arcane_shatter_little", "mod_damage")
tt.damage_min = 0.02
tt.damage_max = 0.02
tt.damage_type = bor(DAMAGE_ARMOR, DAMAGE_NO_SHIELD_HIT)

tt = RT("mod_slow_curse", "mod_slow")
tt.main_script.insert = scripts.mod_slow_curse.insert
tt.modifier.excluded_templates = {"enemy_demon_cerberus"}

tt = RT("mod_ray_sunray_hit", "modifier")

AC(tt, "render")

tt.modifier.duration = fts(24)
tt.render.sprites[1].name = "fx_ray_sunray_hit"
tt.render.sprites[1].z = Z_BULLETS + 1
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update

tt = E:register_t("mod_ray_hero_thor", "mod_ray_tesla")
tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(2)
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_type = DAMAGE_ELECTRICAL
tt.modifier.allows_duplicates = true

tt = RT("mod_hero_thor_chainlightning", "modifier")
tt.chainlightning = {
    bullet = "ray_hero_thor",
    count = 2,
    damage = 40,
    offset = vec_2(25, -1),
    damage_type = DAMAGE_ELECTRICAL,
    chain_delay = fts(2),
    max_range = 110,
    min_range = 40,
    mod = "mod_tesla_overcharge"
}
tt.main_script.update = scripts.mod_hero_thor_chainlightning.update

tt = RT("mod_hero_thor_thunderclap", "modifier")
AC(tt, "render")
tt.thunderclap = {
    damage = 60,
    offset = vec_2(0, 10),
    damage_type = DAMAGE_ELECTRICAL,
    explosion_delay = fts(3),
    secondary_damage = 50,
    secondary_damage_type = DAMAGE_ELECTRICAL,
    radius = 70,
    stun_duration_max = 3,
    stun_duration_min = 2,
    mod_stun = "mod_hero_thor_stun",
    mod_fx = "mod_tesla_overcharge",
    fx = "fx_hero_thor_thunderclap_disipate",
    sound = "HeroThorThunder"
}
tt.main_script.update = scripts.mod_hero_thor_thunderclap.update
tt.main_script.insert = scripts.mod_track_target.insert
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt.render.sprites[1].name = "mod_hero_thor_thunderclap"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].loop = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mod_hero_thor_thunderclap_explosion"
tt = RT("mod_hero_thor_stun", "mod_stun")
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt = RT("mod_elora_chill", "mod_slow")
tt.modifier.duration = fts(11)
tt.slow.factor = 0.8
tt = RT("mod_elora_bolt_freeze", "mod_freeze")

AC(tt, "render")

tt.modifier.duration = 2
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].loop = false
tt.custom_offsets = {
    flying = vec_2(-5, 32)
}
tt.custom_suffixes = {
    flying = "_air"
}
tt.custom_animations = {"start", "end"}
tt = RT("mod_elora_bolt_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5

tt = E:register_t("mod_shaman_heal", "modifier")

E:add_comps(tt, "hps", "render")

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
tt = E:register_t("mod_rocketeer_speed_buff", "modifier")

AC(tt, "fast")

tt.main_script.insert = scripts.mod_rocketeer_speed_buff.insert
tt.main_script.remove = scripts.mod_rocketeer_speed_buff.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 2
tt.modifier.type = MOD_TYPE_FAST
tt.sound_events.insert = "EnemyRocketeer"
tt.fast.factor = 3.6041666666666665
tt.walk_angles = {"walkingRightLeft_fast", "walkingUp_fast", "walkingDown_fast"}

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
tt = RT("mod_troll_heal", "mod_shaman_heal")
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
tt = RT("mod_rotten_lesser_pestilence", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.modifier.duration = 5 - fts(4)
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_poison_giant_rat", "mod_poison")
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 10
tt.dps.damage_min = 10
tt.modifier.duration = 2
tt.reduced_damage_factor = 0.5
tt.render.sprites[1].prefix = "poison_violet"
tt.main_script.insert = scripts.mod_giant_rat_poison.insert
tt.main_script.remove = scripts.mod_giant_rat_poison.remove
tt = RT("mod_wererat_poison", "mod_poison_giant_rat")
tt.dps.damage_max = 15
tt.dps.damage_min = 15
tt = RT("mod_flareon_burn", "mod_lava")
tt.dps.damage_min = 20
tt.dps.damage_max = 20
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_POISON
tt.modifier.duration = 3
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt = RT("mod_ignus_burn_1", "mod_lava")
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_TRUE
tt.modifier.duration = 4
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt = RT("mod_ignus_burn_2", "mod_lava")
tt.dps.damage_min = 8
tt.dps.damage_max = 8
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_TRUE
tt.modifier.duration = 5
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt = RT("mod_ignus_burn_3", "mod_lava")
tt.dps.damage_min = 10
tt.dps.damage_max = 10
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(11)
tt.dps.damage_type = DAMAGE_TRUE
tt.modifier.duration = 6
tt.modifier.vis_flags = bor(F_MOD, F_BURN)
tt.render.sprites[1].prefix = "fx_burn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
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
tt = RT("mod_burning_floor_burn", "mod_flareon_burn")
tt.modifier.duration = 0.5
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

tt = E:register_t("mod_jt_tower", "modifier")

E:add_comps(tt, "render", "tween", "ui")

tt.main_script.update = scripts.mod_jt_tower.update
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].offset.y = 36
tt.render.sprites[1].prefix = "mod_jt"
tt.render.sprites[1].z = Z_OBJECTS

if IS_CONSOLE then
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].alpha = 150
    tt.render.sprites[2].alpha_focused = 255
    tt.render.sprites[2].alpha_unfocused = 150
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
    tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
    tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
    tt.render.sprites[2].offset.y = 20
    tt.render.sprites[2].scale = vec_1(1.6)
else
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].name = "decal_jt_tap"
    tt.render.sprites[2].offset = vec_2(10, 20)
    tt.render.sprites[2].random_ts = fts(7)
end

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
tt = E:register_t("mod_gulthak_heal", "mod_shaman_heal")
tt.hps.heal_min = 200
tt.hps.heal_max = 200
tt = E:register_t("mod_kingpin_heal_self", "mod_shaman_heal")
tt.hps.heal_min = 500
tt.hps.heal_max = 500
tt.render.sprites[1].anchor.y = 0.3
tt = E:register_t("mod_kingpin_heal_others", "mod_shaman_heal")
tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt = RT("mod_myconid_poison", "mod_poison")
tt.dps.damage_every = fts(2)
tt.dps.damage_max = 4
tt.dps.damage_min = 4
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "poison_violet"
tt = RT("mod_blackburn_stun", "mod_stun")
tt.modifier.duration = 4
tt.modifier.duration_heroes = 2
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

tt = E:register_t("mod_veznan_tower", "modifier")
E:add_comps(tt, "render", "ui")
if IS_CONSOLE then
    E:add_comps(tt, "tween")
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

if IS_CONSOLE then
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].alpha = 150
    tt.render.sprites[2].alpha_focused = 255
    tt.render.sprites[2].alpha_unfocused = 150
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "joystick_shortcuts_hud_0007"
    tt.render.sprites[2].name_focused = "joystick_shortcuts_hud_halo_0007"
    tt.render.sprites[2].name_unfocused = "joystick_shortcuts_hud_0007"
    tt.render.sprites[2].offset.y = 20
    tt.render.sprites[2].scale = vec_1(1.6)
else
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].name = "decal_veznan_tap"
    tt.render.sprites[2].offset = vec_2(10, 20)
    tt.render.sprites[2].random_ts = fts(7)
end

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
tt = RT("mod_elder_shaman_heal", "mod_shaman_heal")
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt = RT("mod_elder_shaman_damage", "mod_lava")
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(15)
tt.modifier.duration = 1
tt = RT("mod_elder_shaman_speed", "mod_slow")

AC(tt, "render")

tt.slow.factor = nil
tt.modifier.duration = 3
tt.render.sprites[1].name = "mod_elder_shaman_speed"

E:set_template("user_power_1", E:get_template("power_fireball_control"))
E:set_template("user_power_2", E:get_template("power_reinforcements_control"))

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
tt = RT("decal_sheep_small", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_sheep_small"
tt = RT("decal_mill_big", "decal_click_pause")
tt.render.sprites[1].name = "decal_mill_big"
tt.ui.can_select = false
tt.ui.click_rect = r(-10, -30, 40, 65)
tt = RT("decal_mill_small", "decal_mill_big")
tt.render.sprites[1].name = "decal_mill_small"
tt.ui.click_rect = r(-10, -25, 35, 55)
tt = RT("decal_s01_trees", "decal")
tt.render.sprites[1].name = "stage1_trees"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.234375
tt = RT("decal_boat_big", "decal_loop")
tt.render.sprites[1].name = "decal_boat_big_idle"
tt = RT("decal_boat_small", "decal_loop")
tt.render.sprites[1].name = "decal_boat_small_idle"
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

tt = RT("decal_water_spark", "decal_loop")
tt.render.sprites[1].name = "decal_water_spark_play"

tt = E:register_t("decal_water_wave", "decal_delayed_play")
tt.render.sprites[1].name = "decal_water_wave_play"
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_water_wave_play"

tt = RT("decal_goat", "decal_sheep_big")
tt.render.sprites[1].prefix = "decal_goat"

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
tt = RT("decal_burner_big", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.13)
tt.render.sprites[1].name = "decal_burner_big_idle"
tt = RT("decal_burner_small", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.11)
tt.render.sprites[1].name = "decal_burner_small_idle"
tt = E:register_t("decal_fredo", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_fredo"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.1)
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_fredo.update
tt.ui.can_click = true
tt.ui.click_rect = r(-33, 104, 30, 30)
tt = RT("decal_orc_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_orc_flag", "decal_loop")
tt.render.sprites[1].anchor = vec_2(0.5, 0.07)
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_orc_flag_idle"
tt = RT("decal_swamp_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_swamp_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_swamp_bubble_jump"
tt = E:register_t("decal_demon_portal_big", "decal_scripted")

E:add_comps(tt, "tween")

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
tt = E:register_t("decal_s17_barricade", "decal")

E:add_comps(tt, "editor", "main_script")

tt.boss_name = "eb_kingpin"
tt.boss_spawn_wave = 15
tt.main_script.update = scripts.decal_s17_barricade.update
tt.render.sprites[1].prefix = "decal_s17_barricade"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.x = 0.4
tt.render.sprites[1].loop = false
tt.editor.props = {{"editor.game_mode", PT_NUMBER}}
tt = RT("decal_bandits_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(14)
tt.render.sprites[1].name = "decal_bandits_flag_idle"
tt = E:register_t("decal_scrat", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_scrat"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_scrat_ice"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
tt.render.sprites[2].loop = false
tt.touch_fx = "fx_decal_scrat_touch"
tt.main_script.update = scripts.decal_scrat.update
tt.ui.can_click = true
tt.ui.click_rect = r(-45, 5, 40, 40)
tt = RT("fx_decal_scrat_touch", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_scrat_touch_fx"
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.sound_events.insert = "JtHitIce"
tt = RT("decal_troll_flag", "decal_loop")
tt.render.sprites[1].random_ts = fts(18)
tt.render.sprites[1].name = "decal_troll_flag_idle"
tt = RT("decal_troll_burner", "decal_loop")
tt.render.sprites[1].random_ts = fts(11)
tt.render.sprites[1].name = "decal_troll_burner_idle"
tt = E:register_t("decal_frozen_mushroom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_frozen_mushroom"
tt.click_play.required_clicks = 1
tt.click_play.clicked_sound = "MushroomPoof"
tt.click_play.play_once = true
tt = RT("decal_lava_fall", "decal_loop")
tt.render.sprites[1].name = "decal_lava_fall_idle"
tt = RT("decal_inferno_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_inferno_bubble_jump"
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.min_delay = fts(150)
tt.delayed_play.max_delay = fts(400)
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_inferno_bubble_jump"
tt = RT("decal_lava_splash", "decal_inferno_bubble")
tt.render.sprites[1].name = "decal_lava_splash_jump"
tt.delayed_play.play_animation = "decal_lava_splash_jump"
tt = E:register_t("decal_inferno_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_portal_active"
tt = E:register_t("decal_inferno_ground_portal", "decal_demon_portal_big")
tt.render.sprites[1].name = "decal_inferno_ground_portal_active"
tt = E:register_t("decal_s21_veznan", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0001"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_veznan_free", "decal")
tt.render.sprites[1].name = "Inferno_Stg21_Veznan_0002"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_s21_hellboy", "decal")
tt.render.sprites[1].name = "decal_s21_hellboy_idle"
tt = E:register_t("background_sounds_blackburn", "background_sounds")
tt.min_delay = 20
tt.max_delay = 30
tt.sounds = {}
tt = E:register_t("decal_s23_splinter", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s23_splinter"
tt.render.sprites[1].loop = false
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect.pos.x = -6
tt.ui.click_rect.size.x = 25
tt = E:register_t("decal_s23_splinter_pizza", "decal_s23_splinter")
tt.main_script.update = scripts.decal_s23_splinter_pizza.update
tt.render.sprites[1].prefix = "decal_s23_splinter_pizza"
tt = E:register_t("decal_bat_flying", "decal_delayed_play")

E:add_comps(tt, "tween")

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
local bat_paths = {{vec_2(-7.74, 618.5), vec_2(-0.64, 619.52), vec_2(6.27, 620.86), vec_2(13.12, 622.27),
                    vec_2(19.97, 623.81), vec_2(26.62, 625.54), vec_2(33.41, 627.46), vec_2(40, 629.57),
                    vec_2(46.59, 631.87), vec_2(53.12, 634.43), vec_2(59.39, 637.06), vec_2(65.66, 639.87),
                    vec_2(71.74, 643.07), vec_2(77.63, 646.34), vec_2(83.52, 650.05), vec_2(89.15, 653.89),
                    vec_2(94.66, 658.11), vec_2(99.71, 662.72), vec_2(104.7, 667.65), vec_2(109.12, 672.9),
                    vec_2(113.22, 678.59), vec_2(116.86, 684.54), vec_2(119.94, 690.82), vec_2(122.5, 697.41),
                    vec_2(124.42, 704.06), vec_2(125.7, 710.91), vec_2(126.08, 717.95), vec_2(125.25, 724.8),
                    vec_2(123.2, 731.58), vec_2(120.06, 737.86), vec_2(116.1, 743.87), vec_2(111.68, 749.7),
                    vec_2(107.2, 755.26), vec_2(102.72, 760.7), vec_2(98.18, 766.21), vec_2(94.21, 771.9),
                    vec_2(90.56, 777.79), vec_2(87.68, 784.19)},
                   {vec_2(502.46, 774.14), vec_2(503.42, 767.23), vec_2(504.7, 760.38), vec_2(506.11, 753.54),
                    vec_2(507.84, 746.75), vec_2(509.76, 739.97), vec_2(511.81, 733.44), vec_2(514.18, 727.1),
                    vec_2(516.99, 720.96), vec_2(520.13, 715.01), vec_2(523.97, 709.38), vec_2(528.45, 704.38),
                    vec_2(534.21, 700.42), vec_2(540.8, 698.11), vec_2(547.71, 698.11), vec_2(554.69, 699.01),
                    vec_2(561.47, 700.86), vec_2(568, 703.36), vec_2(574.27, 706.62), vec_2(580.16, 710.46),
                    vec_2(585.73, 714.62), vec_2(590.98, 718.78), vec_2(596.29, 722.69), vec_2(602.5, 725.7),
                    vec_2(609.54, 726.59), vec_2(617.09, 725.82), vec_2(624.38, 724.93), vec_2(631.36, 724.1),
                    vec_2(638.27, 723.65), vec_2(645.12, 723.65), vec_2(652.03, 724.35), vec_2(658.82, 725.7),
                    vec_2(665.47, 728.13), vec_2(671.94, 731.33), vec_2(677.7, 735.23), vec_2(683.14, 739.97),
                    vec_2(688, 745.15), vec_2(692.42, 750.78), vec_2(696.26, 756.67), vec_2(699.71, 762.88),
                    vec_2(702.85, 769.09), vec_2(706.24, 776.83)},
                   {vec_2(1031.49, 454.02), vec_2(1024.38, 455.17), vec_2(1017.54, 456.45), vec_2(1010.62, 457.79),
                    vec_2(1003.84, 459.39), vec_2(997.12, 461.18), vec_2(990.46, 462.98), vec_2(983.74, 465.15),
                    vec_2(977.15, 467.46), vec_2(970.62, 469.95), vec_2(964.42, 472.64), vec_2(958.21, 475.46),
                    vec_2(952.13, 478.53), vec_2(946.18, 481.86), vec_2(940.35, 485.5), vec_2(934.72, 489.41),
                    vec_2(929.28, 493.7), vec_2(924.16, 498.24), vec_2(919.3, 503.1), vec_2(914.69, 508.48),
                    vec_2(910.66, 514.05), vec_2(907.01, 520), vec_2(903.94, 526.27), vec_2(901.31, 532.74),
                    vec_2(899.33, 539.52), vec_2(898.05, 546.37), vec_2(897.73, 553.28), vec_2(898.56, 560.26),
                    vec_2(900.54, 566.98), vec_2(903.55, 573.18), vec_2(907.58, 579.2), vec_2(912, 585.15),
                    vec_2(916.48, 590.72), vec_2(920.9, 596.29), vec_2(925.44, 601.6), vec_2(929.41, 607.3),
                    vec_2(933.06, 613.18), vec_2(936.38, 619.26), vec_2(939.52, 625.6), vec_2(941.95, 632.06),
                    vec_2(944, 638.72), vec_2(945.6, 645.57), vec_2(946.69, 652.61), vec_2(947.46, 659.78),
                    vec_2(947.84, 666.75), vec_2(947.9, 673.79), vec_2(947.65, 680.83), vec_2(947.14, 687.87),
                    vec_2(946.3, 694.85), vec_2(945.22, 701.89), vec_2(942.78, 708.61), vec_2(939.71, 715.26),
                    vec_2(936.32, 721.47), vec_2(932.86, 727.42), vec_2(929.02, 733.44), vec_2(925.06, 739.14),
                    vec_2(920.83, 744.77), vec_2(916.54, 750.21), vec_2(912, 755.58), vec_2(907.26, 760.7),
                    vec_2(902.34, 765.82), vec_2(897.41, 770.82), vec_2(892.29, 775.42), vec_2(887.17, 780.22)},
                   {vec_2(1028.54, 116.61), vec_2(1022.78, 120.96), vec_2(1016.9, 124.99), vec_2(1010.82, 128.83),
                    vec_2(1004.74, 132.22), vec_2(998.46, 135.3), vec_2(992, 138.18), vec_2(985.41, 140.61),
                    vec_2(978.75, 142.66), vec_2(971.78, 144.19), vec_2(964.86, 145.6), vec_2(957.76, 146.37),
                    vec_2(950.66, 146.69), vec_2(943.62, 146.56), vec_2(936.77, 145.41), vec_2(930.05, 142.98),
                    vec_2(924.1, 139.07), vec_2(918.85, 134.27), vec_2(914.37, 128.58), vec_2(910.72, 122.43),
                    vec_2(907.46, 115.71), vec_2(904.64, 108.99), vec_2(902.14, 102.27), vec_2(899.71, 95.42),
                    vec_2(897.54, 88.77), vec_2(895.49, 81.98), vec_2(893.38, 75.52), vec_2(891.26, 68.99),
                    vec_2(889.09, 62.46), vec_2(886.98, 56), vec_2(884.61, 49.6), vec_2(882.05, 43.14),
                    vec_2(879.1, 36.8), vec_2(875.84, 30.72), vec_2(872, 24.7), vec_2(867.78, 19.33),
                    vec_2(862.98, 14.21), vec_2(857.54, 9.79), vec_2(851.46, 6.02), vec_2(845.38, 2.56),
                    vec_2(839.36, -1.28), vec_2(833.47, -5.25), vec_2(827.78, -9.28), vec_2(822.4, -13.95)},
                   {vec_2(687.1, -12.1), vec_2(685.76, -5.12), vec_2(684.22, 1.79), vec_2(682.5, 8.64),
                    vec_2(680.7, 15.42), vec_2(678.72, 22.08), vec_2(676.61, 28.67), vec_2(674.3, 35.26),
                    vec_2(671.81, 41.86), vec_2(669.18, 48.26), vec_2(666.11, 54.66), vec_2(663.17, 60.8),
                    vec_2(659.78, 66.75), vec_2(656.32, 72.45), vec_2(652.42, 78.08), vec_2(648.13, 83.33),
                    vec_2(643.33, 88.19), vec_2(637.95, 92.67), vec_2(631.94, 96.13), vec_2(625.41, 98.5),
                    vec_2(618.43, 99.58), vec_2(611.52, 99.52), vec_2(604.48, 99.26), vec_2(597.5, 98.69),
                    vec_2(590.53, 97.66), vec_2(583.62, 96.26), vec_2(576.83, 94.46), vec_2(570.11, 92.35),
                    vec_2(563.46, 89.79), vec_2(556.99, 86.91), vec_2(550.66, 83.9), vec_2(544.38, 80.64),
                    vec_2(538.43, 77.12), vec_2(532.48, 73.79), vec_2(526.59, 70.34), vec_2(520.58, 67.07),
                    vec_2(514.24, 64.06), vec_2(507.9, 61.44), vec_2(501.31, 59.52), vec_2(494.34, 58.43),
                    vec_2(487.36, 59.01), vec_2(480.64, 61.12), vec_2(474.5, 64.58), vec_2(468.61, 68.8),
                    vec_2(463.3, 73.66), vec_2(458.18, 78.78), vec_2(453.25, 83.97), vec_2(448.51, 89.09),
                    vec_2(443.9, 94.02), vec_2(439.04, 98.82), vec_2(433.92, 103.49), vec_2(428.42, 107.71),
                    vec_2(422.53, 111.3), vec_2(416.06, 113.66), vec_2(409.15, 114.82), vec_2(402.18, 113.98),
                    vec_2(395.39, 111.3), vec_2(389.38, 107.33), vec_2(383.94, 102.53), vec_2(379.01, 97.34),
                    vec_2(374.4, 91.84), vec_2(370.18, 86.14), vec_2(366.14, 80.26), vec_2(362.37, 74.24),
                    vec_2(358.66, 68.1), vec_2(355.14, 62.08), vec_2(351.87, 55.94), vec_2(348.42, 50.05),
                    vec_2(345.09, 44.1), vec_2(341.82, 38.08), vec_2(338.24, 32.13), vec_2(333.95, 26.24),
                    vec_2(329.28, 20.8), vec_2(324.29, 15.74), vec_2(319.1, 10.69), vec_2(313.6, 6.08),
                    vec_2(307.97, 1.73), vec_2(302.34, -2.37), vec_2(296.45, -6.27), vec_2(290.56, -10.11),
                    vec_2(284.54, -13.76)},
                   {vec_2(-12.86, 155.9), vec_2(-5.76, 157.18), vec_2(1.34, 158.66), vec_2(8.19, 160.26),
                    vec_2(15.17, 161.98), vec_2(22.02, 163.84), vec_2(28.67, 165.89), vec_2(35.2, 168.06),
                    vec_2(41.73, 170.43), vec_2(48.13, 173.06), vec_2(54.46, 176), vec_2(60.54, 179.26),
                    vec_2(66.62, 182.91), vec_2(72.26, 187.01), vec_2(77.63, 191.62), vec_2(82.3, 196.86),
                    vec_2(85.95, 202.69), vec_2(88, 209.47), vec_2(87.55, 216.58), vec_2(84.93, 223.3),
                    vec_2(81.15, 229.44), vec_2(76.74, 235.2), vec_2(72.13, 240.77), vec_2(67.46, 246.4),
                    vec_2(63.17, 251.97), vec_2(59.71, 257.98), vec_2(57.02, 264.45), vec_2(56.06, 271.55),
                    vec_2(56.38, 278.66), vec_2(57.73, 285.7), vec_2(59.78, 292.8), vec_2(62.14, 299.78),
                    vec_2(64.58, 306.5), vec_2(66.94, 313.15), vec_2(69.31, 319.68), vec_2(71.42, 326.27),
                    vec_2(73.34, 332.99), vec_2(74.75, 339.9), vec_2(75.52, 346.82), vec_2(75.39, 353.86),
                    vec_2(74.05, 360.83), vec_2(71.04, 367.23), vec_2(66.37, 372.61), vec_2(60.03, 376.26),
                    vec_2(52.93, 378.62), vec_2(46.21, 380.93), vec_2(39.55, 383.42), vec_2(33.22, 386.37),
                    vec_2(26.82, 389.44), vec_2(20.67, 392.9), vec_2(14.72, 396.61), vec_2(9.09, 400.7),
                    vec_2(3.71, 405.25), vec_2(-1.28, 410.24), vec_2(-5.82, 415.68), vec_2(-11.46, 420.54)}}

for i, b in ipairs(bat_paths) do
    tt = E:register_t("decal_bat_flying_" .. i, "decal_bat_flying")
    local keys = {}
    local t = 0

    for _, p in pairs(b) do
        table.insert(keys, {t, p})

        t = t + bat_speed_per_node
    end

    tt.tween.props[1].keys = keys
    tt.delayed_play.play_duration = t
end

tt = E:register_t("decal_s24_nevermore", "decal_click_play")

E:add_comps(tt, "tween")

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
tt = RT("decal_blackburn_weed", "decal_loop")
tt.render.sprites[1].random_ts = fts(34)
tt.render.sprites[1].name = "decal_blackburn_weed_idle"
tt = RT("decal_blackburn_waves", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_waves_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_waves_jump"
tt = RT("decal_blackburn_bubble", "decal_delayed_play")
tt.render.sprites[1].name = "decal_blackburn_bubble_jump"
tt.delayed_play.min_delay = 0
tt.delayed_play.max_delay = 1
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "decal_blackburn_bubble_jump"
tt = RT("decal_blackburn_smoke", "decal_loop")
tt.render.sprites[1].random_ts = fts(21)
tt.render.sprites[1].name = "decal_blackburn_smoke_jump"
tt = E:register_t("decal_s25_nessie", "decal_click_play")
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
tt = RT("decal_s26_cage", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s26_cage"
tt.delayed_play.min_delay = 2
tt.delayed_play.max_delay = 6
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "play"
tt = RT("decal_s26_hangmen", "decal_s26_cage")
tt.render.sprites[1].prefix = "decal_s26_hangmen"
tt = RT("decal_endless_burner", "decal_loop")
tt.render.sprites[1].name = "decal_orc_burner_idle"
tt.render.sprites[1].random_ts = fts(14)
tt = RT("decal_s81_percussionist", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s81_percussionist"
tt.render.sprites[1].anchor.y = 0.125
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_s81_percussionist.update
tt.play_loops = 0

tt = E:register_t("tower_archer_hammerhold", "tower")
E:add_comps(tt, "attacks")
tt.tower.type = "archer_hammerhold"
tt.tower.level = 1
tt.tower.price = 0
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "kr2_info_portraits_towers_") .. "0019"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_archer_%04i"
tt.render.sprites[1].offset = vec_2(0, 12)
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "city_tower"
tt.render.sprites[2].offset = vec_2(0, 28)
tt.render.sprites[3] = E:clone_c("sprite")
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
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "arrow_hammerhold"
tt.attacks.list[1].cooldown = 0.7
tt.attacks.list[1].shoot_time = fts(5)
tt.attacks.list[1].bullet_start_offset = {vec_2(0, 50)}

tt = E:register_t("arrow_hammerhold", "arrow")
tt.bullet.damage_min = 5
tt.bullet.damage_max = 10

tt = E:register_t("decal_tusken", "decal_scripted")
E:add_comps(tt, "bullet_attack")
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

tt = E:register_t("bullet_tusken", "shotgun")
tt.bullet.damage_min = 100
tt.bullet.damage_max = 200
tt.bullet.min_speed = 40 * FPS
tt.bullet.max_speed = 40 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.miss_fx = "fx_smoke_bullet"

tt = E:register_t("sand_worm", "decal_scripted")
E:add_comps(tt, "area_attack")
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

tt = E:register_t("fx_sand_worm_incoming", "decal_tween")
tt.render.sprites[1].anchor.y = 0.44
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "sand_worm_incoming"
tt.tween.props[1].keys = {{0, 0}, {0.6, 255}}
tt.tween.remove = false

tt = E:register_t("fx_sand_worm_out", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "sandworm_decal_out"
tt.tween.props[1].keys = {{1, 255}, {3.5, 0}}

tt = E:register_t("decal_palm_tree", "decal_timed")
tt.timed.disabled = true
tt.render.sprites[1].prefix = "decal_palm_tree"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -40

tt = E:register_t("decal_palm_land", "decal_tween")
tt.pos = vec_2(REF_W * 0.5, REF_H * 0.5)
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.4, 0}}
tt.tween.remove = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t("decal_lumberjack", "decal")
tt.render.sprites[1].prefix = "lumberjack"
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].z = Z_OBJECTS

tt = E:register_t("decal_ship_door", "decal")
tt.render.sprites[1].prefix = "decal_ship_door"
tt.render.sprites[1].name = "closed"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_BACKGROUND_COVERS

tt = E:register_t("pirate_cannons", "decal_scripted")
E:add_comps(tt, "attacks")
tt.main_script.update = scripts.pirate_cannons.update
tt.render.sprites[1].prefix = "pirate_cannon_left"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "pirate_cannon_right"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2].offset = vec_2(169, -65)
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].min_range = 100
tt.attacks.list[1].max_range = 600
tt.attacks.list[1].min_cooldown = 40
tt.attacks.list[1].max_cooldown = 60
tt.attacks.list[1].shoot_time = fts(29)
tt.attacks.list[1].max_error = 20
tt.attacks.list[1].min_error = 5

tt = E:register_t("decal_pirate_cannon_target", "decal_tween")
tt.render.sprites[1].name = "Stage4_ShipCrosshair"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1.86, 1.86)}, {fts(20), vec_2(1.05, 1.05)}, {fts(23), vec_2(0.95, 0.95)},
                          {fts(26), vec_2(1.05, 1.05)}, {fts(28), vec_2(1, 1)}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 0}, {fts(20), 255}, {fts(74), 255}, {fts(78), 0}}

tt = E:register_t("bomb_pirate_cannon", "bullet")
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

tt = E:register_t("decal_efreeti_tent", "decal")
tt.render.sprites[1].name = "boss_corps_efreeti"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_efreeti_door", "decal_scripted")
tt.main_script.update = scripts.decal_efreeti_door.update
tt.smoke_positions = {vec_2(521, 674), vec_2(618, 642)}
tt.stone_positions = {{vec_2(599, 664), 1, false}, {vec_2(688, 592), 0.8, false}, {vec_2(479, 647), 0.8, false},
                      {vec_2(519, 682), 1, true}, {vec_2(625, 608), 0.8, true}, {vec_2(416, 663), 0.8, true}}
tt.render.sprites[1].prefix = "efreeti_door_floor"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "efreeti_door"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].loop = false
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "Stage06_0003"
tt.render.sprites[3].animated = false
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "efreeti_statue"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].offset = vec_2(-139, -66)
tt.render.sprites[4].anchor.y = 0.08
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].prefix = "efreeti_statue"
tt.render.sprites[5].name = "idle"
tt.render.sprites[5].offset = vec_2(72, -120)
tt.render.sprites[5].anchor.y = 0.08
tt.render.sprites[6] = E:clone_c("sprite")
tt.render.sprites[6].name = "efreeti_door_eyes"
tt.render.sprites[6].offset = vec_2(-51, -55)
tt.render.sprites[6].hidden = true
tt.render.sprites[6].loop = false
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].name = "efreeti_door_eyes_effect"
tt.render.sprites[7].offset = vec_2(-51, -55)
tt.render.sprites[7].hidden = true
tt.render.sprites[7].loop = false

tt = E:register_t("decal_efreeti_door_broken", "decal")
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].name = "efreeti_statue_left"
tt.render.sprites[1].offset = vec_2(-139, -66)
tt.render.sprites[1].anchor.y = 0.08
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "efreeti_statue_right"
tt.render.sprites[2].offset = vec_2(72, -120)
tt.render.sprites[2].anchor.y = 0.08

tt = E:register_t("decal_lumberjack_shaman", "decal")
tt.render.sprites[1].prefix = "lumberjack_shaman"
tt.render.sprites[1].anchor.y = 0.18

tt = E:register_t("background_sounds_jungle", "background_sounds")
tt.min_delay = 20
tt.max_delay = 25
tt.sounds = {"JungleAmbienceSound"}

tt = E:register_t("background_sounds_underground", "background_sounds")
tt.min_delay = 15
tt.max_delay = 20
tt.sounds = {"UndergroundAmbienceSound"}

tt = E:register_t("tower_holder_blocked")
E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "sound_events")
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower_holder.blocked = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "build_terrain_blocked_%04i"
tt.render.sprites[1].offset = vec_2(0, 17)
tt.render.sprites[1].z = Z_DECALS
tt.ui.click_rect = r(-40, -12, 80, 46)
tt.sound_events.remove = "GUITowerSell"

tt = E:register_t("tower_holder_blocked_jungle", "tower_holder_blocked")
tt.tower.type = "holder_blocked_jungle"
tt.tower_holder.unblock_price = 100

tt = E:register_t("tower_holder_blocked_underground", "tower_holder_blocked")
tt.tower.type = "holder_blocked_underground"
tt.tower_holder.unblock_price = 200

tt = E:register_t("carnivorous_plant", "decal_scripted")
E:add_comps(tt, "area_attack")
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

tt = E:register_t("enemy_cannibal_volcano", "enemy")
E:add_comps(tt, "melee", "tween")
anchor_y = 0.15
image_y = 100
tt.info.portrait = IS_PHONE and "portraits_sc_0044" or "kr2_info_portraits_enemies_0027"
tt.enemy.gold = 10
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 400
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(70))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.insert = scripts.enemy_basic.insert
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

tt = E:register_t("decal_volcano_virgin", "decal_scripted")
E:add_comps(tt, "motion")
tt.render.sprites[1].prefix = "volcano_virgin"
tt.render.sprites[1].name = "heart"
tt.render.sprites[1].anchor.y = 0.15
tt.motion.max_speed = 1 * FPS
tt.main_script.update = scripts.decal_volcano_virgin.update

tt = E:register_t("bomb_volcano", "bullet")
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

tt = E:register_t("decal_volcano_bubble", "decal_delayed_play")
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "bubble"
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "bubble"

tt = E:register_t("decal_volcano_smoke", "decal_delayed_play")
tt.render.sprites[1].prefix = "volcano_lava"
tt.render.sprites[1].name = "smoke"
tt.delayed_play.min_delay = 3
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "smoke"

tt = E:register_t("decal_bouncing_bridge", "decal_scripted")
tt.main_script.update = scripts.decal_bouncing_bridge.update
tt.render.sprites[1].prefix = "decal_bouncing_bridge"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_DECALS - 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "Stage6_Bridge_Front_Pillars"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y = 495
tt.bridge_width = 160

tt = E:register_t("decal_monkey_corps_1", "decal_tween")
tt.render.sprites[1].name = "decal_monkey_corps_1"
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "flip_x"
tt.tween.props[1].keys = {{0, false}, {3, true}, {6, false}}

tt = E:register_t("decal_monkey_corps_2", "decal")
tt.render.sprites[1].name = "decal_monkey_corps_2"

tt = E:register_t("decal_monkey_corps_3", "decal_delayed_sequence")
tt.render.sprites[1].prefix = "decal_monkey_corps_3"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = nil
tt.delayed_sequence.animations = {"jump", "jump", "jump", "idle"}
tt.delayed_sequence.min_delay = 0
tt.delayed_sequence.max_delay = 1

tt = E:register_t("indiana_puzzle_button_a", "decal")
E:add_comps(tt, "ui")
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "indiana_puzzle_button_a"
tt.render.sprites[1].z = Z_DECALS + 6
tt.ui.can_click = false
tt.ui.click_rect = r(-22, -22, 44, 44)
tt.puzzle_value = 1

tt = E:register_t("indiana_puzzle_button_b", "indiana_puzzle_button_a")
tt.render.sprites[1].prefix = "indiana_puzzle_button_b"
tt.puzzle_value = 2

tt = E:register_t("indiana_puzzle_button_c", "indiana_puzzle_button_a")
tt.render.sprites[1].prefix = "indiana_puzzle_button_c"
tt.puzzle_value = 3

tt = E:register_t("decal_indiana", "decal_tween")
tt.render.sprites[1].prefix = "decal_indiana"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 4
tt.tween.disabled = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {1, 0}}

tt = E:register_t("decal_indiana_question_marks", "decal_timed")
tt.render.sprites[1].name = "decal_indiana_question_marks"
tt.timed.runs = 5

tt = E:register_t("decal_indiana_boulder", "decal_scripted")
E:add_comps(tt, "motion")
tt.render.sprites[1].name = "decal_indiana_boulder"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS + 4
tt.motion.max_speed = 3.9 * FPS
tt.main_script.update = scripts.decal_indiana_boulder.update

tt = E:register_t("decal_black_dragon", "decal_scripted")
E:add_comps(tt, "motion", "attacks", "tween", "ui", "sound_events")
tt.main_script.update = scripts.decal_black_dragon.update
tt.motion.max_speed = 12 * FPS
tt.attacks.list[1] = E:clone_c("mod_attack")
tt.attacks.list[1].mod = "mod_black_dragon"
tt.attacks.list[1].cooldown = 0.2
tt.attacks.list[1].range = 30
tt.render.sprites[1].prefix = "decal_black_dragon"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_black_dragon"
tt.render.sprites[2].name = "zzz"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loope = false
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "Stage12_Dragon_Shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = -1
tt.render.sprites[4] = E:clone_c("sprite")
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

tt = E:register_t("fx_black_dragon_flame_hit", "decal_tween")
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "black_dragon_flame_hit"
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {0.3, 0}}

tt = E:register_t("ps_black_dragon_flame")
E:add_comps(tt, "pos", "particle_system")
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

tt = E:register_t("ps_black_dragon_fire")
E:add_comps(tt, "pos", "particle_system")
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

tt = E:register_t("mod_black_dragon", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = 7
tt.main_script.update = scripts.mod_tower_block.update
tt.render.sprites[1].prefix = "black_dragon_tower_fire"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].sort_y_offset = -1

tt = E:register_t("button_steal_dragon_gold")
E:add_comps(tt, "pos", "main_script", "ui")
tt.main_script.update = scripts.button_steal_dragon_gold.update
tt.ui.can_click = true
tt.ui.click_rect = r(0, 0, 88, 67)
tt.gold_to_steal = 100
tt.fx = "fx_coin_jump"

local decal_whale = E:register_t("decal_whale", "decal_scripted")
E:add_comps(decal_whale, "nav_path")
decal_whale.path_origin_offset = vec_2(36, 36)
decal_whale.main_script.insert = scripts.decal_whale.insert
decal_whale.main_script.update = scripts.decal_whale.update

for i = 1, 3 do
    decal_whale.render.sprites[i] = E:clone_c("sprite")
    decal_whale.render.sprites[i].prefix = "decal_whale_l" .. i
    decal_whale.render.sprites[i].name = "show"
    decal_whale.render.sprites[i].hidden = true
end

decal_whale.render.sprites[4] = E:clone_c("sprite")
decal_whale.render.sprites[4].name = "Cachalote_layer1_0090"
decal_whale.render.sprites[4].animated = false
decal_whale.render.sprites[4].hidden = true
decal_whale.render.sprites[4].sort_y_offset = -1 * decal_whale.path_origin_offset.y - 2
decal_whale.render.sprites[5] = E:clone_c("sprite")
decal_whale.render.sprites[5].prefix = "decal_whale_eye"
decal_whale.render.sprites[5].name = "idle"
decal_whale.render.sprites[5].hidden = true
decal_whale.render.sprites[5].sort_y_offset = -1 * decal_whale.path_origin_offset.y - 3

local fx_whale_incoming = E:register_t("fx_whale_incoming", "decal_tween")
fx_whale_incoming.tween.remove = true
fx_whale_incoming.tween.props[1].name = "alpha"
fx_whale_incoming.tween.props[1].keys = {{0, 0}, {2, 255}, {4, 255}}
fx_whale_incoming.render.sprites[1].name = "fx_whale_incoming"
fx_whale_incoming.render.sprites[1].z = Z_DECALS + 2
fx_whale_incoming.render.sprites[1].loop = true

tt = E:register_t("decal_water_barricade", "decal")
tt.render.sprites[1].prefix = "decal_water_barricade"
tt.render.sprites[1].name = "idle"

tt = E:register_t("ps_bomb_volcano")
E:add_comps(tt, "pos", "particle_system")
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

tt = E:register_t("ps_bomb_gunboat", "ps_bomb_volcano")
tt.particle_system.name = "bomb_gunboat_particle"
tt.particle_system.animated = true
tt.particle_system.emission_rate = 120
tt.particle_system.particle_lifetime = {0.15, 0.25}
tt.particle_system.scales_x = {1, 1.7}
tt.particle_system.scales_y = {1, 1.7}
tt.particle_system.scale_var = {0.8, 1.2}

tt = E:register_t("moon_controller", "decal_scripted")
E:add_comps(tt, "tween")
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1
tt.main_script.update = scripts.moon_controller.update
tt.render.sprites[1] = E:clone_c("sprite")
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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 4
tt.tween.props[2].keys = {{0, 0}, {0.5, 255}}

tt = E:register_t("decal_moon_dark", "decal_tween")
tt.pos.x = REF_W * 0.5
tt.pos.y = REF_H + 1 + 77 * (IS_PHONE and 1.45 or 1)
tt.render.sprites[1].name = "moon_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_SCREEN_FIXED + 3
tt.render.sprites[1].anchor.x = 3.6666666666666665
tt.render.sprites[1].scale = IS_PHONE and vec_2(1.45, 1.45) or nil
tt.tween.props[1].name = "r"
tt.tween.disabled = true
tt.tween.remove = false

tt = E:register_t("decal_moon_light", "decal_tween")
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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.25, 0}, {0.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1

tt = E:register_t("decal_moon_overlay", "decal_tween")
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

tt = E:register_t("moon_enemy_aura", "aura")
tt.main_script.update = scripts.moon_enemy_aura.update

tt = E:register_t("points_spawner")
E:add_comps(tt, "main_script")
tt.main_script.update = scripts.points_spawner.update
tt.manual_wave = nil
tt.interrupt = false

tt = E:register_t("decal_moon_activated", "decal_scripted")
E:add_comps(tt, "tween")
tt.main_script.update = scripts.decal_moon_activated.update
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.tween.remove = false
tt.tween.reverse = true
tt.tween.ts = -1
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 0}, {1, 255}}

tt = E:register_t("decal_taunting_dracula", "decal_scripted")
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

tt = E:register_t("decal_dracula_shoutbox", "decal_tween")
E:add_comps(tt, "texts", "timed")
tt.render.sprites[1].name = "HalloweenBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
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

tt = E:register_t("decal_moria_gate", "decal_scripted")
E:add_comps(tt, "tween", "ui")
tt.render.sprites[1].name = "moria_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 100
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = E:clone_c("sprite")
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

tt = E:register_t("decal_stage22_reptile", "decal_scripted")
E:add_comps(tt, "ui", "motion")
tt.render.sprites[1].prefix = "decal_stage22_reptile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = vec_2(0.6935483870967742, 0.05555555555555555)
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.main_script.update = scripts.decal_stage22_reptile.update
tt.climb_distance = 140
tt.motion.max_speed = 2 * FPS

tt = E:register_t("pop_mage", "pop")
tt.render.sprites[1].name = "elven_pops_0001"
tt = E:register_t("pop_archer", "pop")
tt.render.sprites[1].name = "elven_pops_0002"
tt = E:register_t("pop_barrack1", "pop")
tt.render.sprites[1].name = "elven_pops_0003"
tt = E:register_t("pop_barrack2", "pop")
tt.render.sprites[1].name = "elven_pops_0004"
tt = E:register_t("pop_artillery", "pop")
tt.render.sprites[1].name = "elven_pops_0005"
tt = E:register_t("pop_wild_mage", "pop")
tt.render.sprites[1].name = "elven_pops_0006"
tt = E:register_t("pop_high_elven", "pop")
tt.render.sprites[1].name = "elven_pops_0007"
tt = E:register_t("pop_ewoks", "pop")
tt.render.sprites[1].name = "elven_pops_0008"
tt = E:register_t("pop_arcane", "pop")
tt.render.sprites[1].name = "elven_pops_0009"
tt = E:register_t("pop_golden", "pop")
tt.render.sprites[1].name = "elven_pops_0010"
tt = E:register_t("pop_death", "pop")
tt.render.sprites[1].name = "elven_pops_0011"
tt = E:register_t("pop_faerie_spell", "pop")
tt.render.sprites[1].name = "elven_pops_0012"
tt = E:register_t("pop_faerie_steal", "pop")
tt.render.sprites[1].name = "elven_pops_0013"
tt = E:register_t("pop_bladesinger", "pop")
tt.render.sprites[1].name = "elven_pops_0014"
tt = E:register_t("pop_forest_keeper", "pop")
tt.render.sprites[1].name = "elven_pops_0015"
tt = E:register_t("pop_druid_henge", "pop")
tt.render.sprites[1].name = "elven_pops_0016"
tt = E:register_t("pop_entwood", "pop")
tt.render.sprites[1].name = "elven_pops_0017"
tt = E:register_t("pop_lightning1", "pop")
tt.render.sprites[1].name = "elven_pops_0018"
tt = E:register_t("pop_lightning2", "pop")
tt.render.sprites[1].name = "elven_pops_0019"
tt = E:register_t("pop_lightning3", "pop")
tt.render.sprites[1].name = "elven_pops_0020"
tt = E:register_t("pop_crit_mages", "pop")
tt.render.sprites[1].name = "elven_pops_0023"
tt = E:register_t("pop_crit_wild_magus", "pop")
tt.render.sprites[1].name = "elven_pops_0024"
tt = E:register_t("pop_crit_high_elven", "pop")
tt.render.sprites[1].name = "elven_pops_0025"
tt = E:register_t("pop_mactans", "pop")
tt.render.sprites[1].name = "mactans_pop"
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt = E:register_t("ps_arrow_arcane_special")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "archer_arcane_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {1, 0}
tt.particle_system.emission_rate = 30

tt = E:register_t("ps_bolt_elves_1")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mage_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(15), fts(15)}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_x = {0.8, 0.25}
tt.particle_system.scales_y = {0.8, 0.25}
tt.particle_system.emission_rate = 60
tt = E:register_t("ps_bolt_elves_2", "ps_bolt_elves_1")
tt.particle_system.scales_x = {0.9, 0.25}
tt.particle_system.scales_y = {0.9, 0.25}
tt = E:register_t("ps_bolt_elves_3", "ps_bolt_elves_1")
tt.particle_system.scales_x = {1, 0.25}
tt.particle_system.scales_y = {1, 0.25}
tt = E:register_t("ps_bolt_high_elven", "ps_bolt_elves_1")
tt.particle_system.name = "mage_highElven_proy_particle"
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {1, 0.5}
tt = E:register_t("ps_bolt_wild_magus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "mage_wild_proy_particle"
tt.particle_system.alphas = {180, 12}
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.scales_y = {1, 0.5}
tt.particle_system.scales_x = {1, 0.5}
tt.particle_system.emission_rate = 60
tt = E:register_t("ps_high_elven_sentinel")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("ps_bolt_plant_magic_blossom", "ps_bolt_elves_1")
tt.particle_system.name = "plant_magicBlosom_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.scales_y = {1, 0.3}
tt.particle_system.alphas = {190, 120, 0}

tt = E:register_t("ps_shield_elves_denas")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "shield_elves_denas_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(12), fts(12)}
tt.particle_system.emission_rate = 60
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.scales_y = {1.5, 0.5}
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_freeze_arivan")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "arivan_freeze_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_fireball_arivan")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.names = {"arivan_fireball_particle_1", "arivan_fireball_particle_2"}
tt.particle_system.loop = false
tt.particle_system.cycle_names = true
tt.particle_system.animated = true
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt.particle_system.z = Z_BULLETS
tt = E:register_t("ps_twilight_scourger_banshee")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("ps_nav_faerie_red")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 3
tt.particle_system.anchor.y = 0.28125
tt.particle_system.loop = false
tt.particle_system.name = "nav_faerie_particle_red"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_nav_faerie_yellow", "ps_nav_faerie_red")
tt.particle_system.name = "nav_faerie_particle_yellow"
tt = E:register_t("ps_drow_queen_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.anchor.y = 0.35384615384615387
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.emission_rate = 1
tt.particle_system.loop = false
tt.particle_system.names = {"s11_malicia_particle1", "s11_malicia_particle2"}
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.z = Z_OBJECTS
tt = E:register_t("ps_bolt_faustus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt = E:register_t("ps_bolt_lance_faustus")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "bolt_lance_faustus_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.emission_rate = 90
tt.particle_system.emit_rotation_spread = math.pi
tt = E:register_t("ps_bullet_liquid_fire_faustus")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("ps_minidragon_faustus_fire", "ps_bullet_liquid_fire_faustus")
tt.particle_system.emit_duration = nil
tt.particle_system.emit_speed = {500, 500}
tt.particle_system.emit_rotation_spread = math.pi / 8
tt = E:register_t("ps_bullet_twilight_evoker")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_evoker_bolt_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.25, 0.25}
tt.particle_system.alphas = {255, 0}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt = E:register_t("ps_bullet_twilight_heretic")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.names = {"bullet_twilight_heretic_particle_1", "bullet_twilight_heretic_particle_2"}
tt.particle_system.animated = true
tt.particle_system.cycle_names = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 45
tt.particle_system.track_rotation = true
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt = E:register_t("ps_twilight_heretic_consume_ball_particle")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "twilight_heretic_consume_ball_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.track_rotation = true
tt = E:register_t("ps_razorboar_rampage")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "razorboar_rampage_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(9), fts(11)}
tt.particle_system.emission_rate = 10
tt.particle_system.emit_area_spread = vec_2(16, 6)
tt.particle_system.emit_offset = vec_2(0, 28)
tt = E:register_t("ps_emit_breath_baby_ashbite")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_breath_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
tt = E:register_t("ps_emit_fiery_mist_baby_ashbite")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.loop = false
tt.particle_system.name = "baby_ashbite_fierymist_particle"
tt.particle_system.particle_lifetime = {fts(10), fts(10)}
tt.particle_system.source_lifetime = fts(20)
tt = RT("ps_dagger_drow")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "dagger_drow_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
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
tt = E:register_t("ps_veznan_soulburn")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "veznan_hero_soulBurn_particle"
tt.particle_system.animated = false
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.particle_lifetime = {fts(4), fts(12)}
tt.particle_system.scales_x = {1, 1.25}
tt.particle_system.scales_y = {1, 1.25}
tt.particle_system.scale_var = {0.25, 1}
tt.particle_system.alphas = {255, 0}
tt = RT("ps_bullet_rag_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "razzAndRaggs_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
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
tt = RT("ps_durax_clone_transfer", "ps_durax_transfer")
tt.particle_system.alphas = {150}
tt = RT("ps_bullet_lilith_trail")

AC(tt, "pos", "particle_system")

tt.particle_system.name = "fallen_angel_hero_proy_particle"
tt.particle_system.animated = false
tt.particle_system.particle_lifetime = {0.2, 0.2}
tt.particle_system.alphas = {255, 12}
tt.particle_system.scales_y = {0.8, 0.05}
tt.particle_system.emission_rate = 30
tt = RT("ps_missile_phoenix")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.animation_fps = 50
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_missile_phoenix"
tt.particle_system.particle_lifetime = {0.14, 0.18}
tt.particle_system.spin = {-0.3, 0.3}
tt.particle_system.track_rotation = true
tt = RT("ps_missile_phoenix_small", "ps_missile_phoenix")
tt.particle_system.scale_var = {0.65, 0.65}
tt.particle_system.emit_area_spread = vec_2(2, 2)
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
tt = RT("ps_bullet_balrog", "ps_fireball_arivan")
tt.particle_system.particle_lifetime = {fts(10), fts(15)}
tt.particle_system.animation_fps = 20
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.emission_rate = 60
tt.particle_system.track_rotation = true
tt = RT("ps_bullet_rod_dragon_fire")

AC(tt, "pos", "particle_system")

tt.particle_system.animated = true
tt.particle_system.emission_rate = 50
tt.particle_system.emit_area_spread = vec_2(4, 4)
tt.particle_system.loop = false
tt.particle_system.name = "ps_rod_dragon_fire_particle"
tt.particle_system.particle_lifetime = {0.3, 0.34}
tt.particle_system.track_rotation = true
tt = E:register_t("fx_teleport_violet", "fx")
tt.render.sprites[1].name = "fx_teleport_violet"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
tt = E:register_t("fx_teleport_orange", "fx")
tt.render.sprites[1].name = "fx_teleport_orange"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
tt = E:register_t("fx_teleport_blue", "fx")
tt.render.sprites[1].name = "fx_teleport_blue"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1.2), vec_1(1.3)}
tt = E:register_t("fx_bolt_elves_hit", "fx")
tt.render.sprites[1].name = "bolt_elves_hit"
tt = E:register_t("fx_bolt_high_elven_weak_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_weak_hit"
tt = E:register_t("fx_bolt_high_elven_strong_hit", "fx")
tt.render.sprites[1].name = "bolt_high_elven_strong_hit"
tt = E:register_t("fx_rock_explosion", "fx")
tt.render.sprites[1].name = "fx_rock_explosion"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_fiery_nut_explosion", "fx")
tt.render.sprites[1].name = "fx_fiery_nut_explosion"
tt.render.sprites[1].anchor.y = 0.19791666666666666
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_rock_druid_launch", "fx")
tt.render.sprites[1].name = "fx_rock_druid_launch"
tt = E:register_t("fx_arrow_arcane_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_arcane_hit"
tt = E:register_t("fx_arcane_slumber_explosion", "fx")
tt.render.sprites[1].name = "arcane_slumber_explosion"
tt.render.sprites[1].anchor.y = 0.32051282051282054
tt = E:register_t("fx_soldier_barrack_revive", "fx")
tt.render.sprites[1].name = "fx_soldier_barrack_revive"
tt.render.sprites[1].anchor.y = 0.15
tt = E:register_t("fx_arrow_silver_mark_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_mark_hit"
tt.render.sprites[1].sort_y_offset = -20
tt = E:register_t("fx_arrow_silver_sentence_hit", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "fx_arrow_silver_sentence_hit"
tt.sound_events.insert = "TowerGoldenBowInstakill"
tt = E:register_t("fx_arrow_silver_sentence_shot", "fx")
tt.render.sprites[1].name = "fx_arrow_silver_sentence_shot"
tt = E:register_t("fx_wild_magus_hit", "fx")
tt.render.sprites[1].name = "bolt_wild_magus_hit"
tt = E:register_t("fx_ray_wild_magus_hit", "fx")
tt.render.sprites[1].name = "fx_ray_wild_magus_hit"
tt = E:register_t("fx_eldritch_explosion", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "fx_eldritch_explosion"
tt.render.sprites[1].sort_y_offset = -5
tt.sound_events.insert = "TowerWildMagusDoomExplote"
tt = E:register_t("fx_druid_bear_spawn_rune", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = vec_2(0.48148148148148145, 0.7291666666666666)
tt.render.sprites[1].name = "fx_druid_bear_spawn_rune"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.tween.props[1].keys = {{0, 255}, {fts(9), 255}, {fts(15), 255}, {fts(25), 64}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{fts(0), vec_2(1, 1)}, {fts(9), vec_2(1, 1)}, {fts(11), vec_2(0.77, 0.77)},
                          {fts(13), vec_2(0.85, 0.85)}, {fts(19), vec_2(0.65, 0.45)}}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(0, 32)}, {fts(9), vec_2(0, 32)}, {fts(13), vec_2(0, 32)}, {fts(25), vec_2(0, 4)}}
tt = E:register_t("fx_druid_bear_spawn_effect", "fx")
tt.render.sprites[1].name = "fx_druid_bear_spawn_effect"
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt = E:register_t("fx_druid_bear_spawn_decal", "decal")

E:add_comps(tt, "tween")

tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].name = "fx_druid_bear_spawn_decal"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(6), 0}, {fts(7), 255}, {fts(26), 255}, {fts(36), 102}, {fts(41), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{fts(0), vec_2(0.35, 0.35)}, {fts(6), vec_2(0.35, 0.35)}, {fts(10), vec_2(1, 1)},
                          {fts(16), vec_2(0.8, 0.8)}}
tt = E:register_t("fx_druid_bear_death_rune", "fx_druid_bear_spawn_rune")
tt.render.sprites[1].name = "fx_druid_bear_death_rune"
tt.render.sprites[1].time_offset = fts(-38)
tt.render.sprites[1].sort_y_offset = -1
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {{0, vec_2(1, 1)}}
tt.tween.props[3].keys = {{0, vec_2(0, 20)}, {fts(10), vec_2(0, 36)}, {fts(19), vec_2(0, 40)}}
tt.tween.props[3].time_offset = fts(-28)
tt = E:register_t("fx_druid_bear_death_effect", "fx_druid_bear_spawn_effect")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "fx_druid_bear_death_effect"
tt.render.sprites[1].time_offset = fts(-28)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(1), 255}}
tt.tween.props[1].time_offset = fts(-28)
tt = E:register_t("fx_druid_bear_death_decal", "fx_druid_bear_spawn_decal")
tt.tween.props[1].keys = {{0, 0}, {fts(1), 255}, {fts(4), 255}, {fts(12), 0}}
tt.tween.props[1].time_offset = fts(-28)
tt.tween.props[2].keys = {{fts(0), vec_2(0.4, 0.35)}, {fts(6), vec_2(0.77, 0.77)}, {fts(10), vec_2(0.86, 0.86)}}
tt.tween.props[2].time_offset = fts(-28)
tt = E:register_t("fx_clobber_smoke", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke"
tt = E:register_t("fx_clobber_smoke_ring", "fx")
tt.render.sprites[1].name = "fx_clobber_smoke_ring"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("fx_forest_circle", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "forestKeeper_circle1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "forestKeeper_circle1_0001"
tt.render.sprites[2].animated = false
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {fts(2), 255}, {fts(16), 255}, {fts(29), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.2, 0.2)}, {fts(8), vec_2(0.6, 0.6)}}
tt.tween.props[3] = E:clone_c("tween_prop")
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
tt = E:register_t("fx_spear_forest_oak_hit", "fx")
tt.render.sprites[1].name = "fx_spear_forest_oak_hit"
tt = E:register_t("fx_arrow_soldier_re_hit", "fx")
tt.render.sprites[1].name = "fx_arrow_soldier_re_hit"
tt = E:register_t("fx_dagger_drow_hit", "fx")
tt.render.sprites[1].name = "fx_dagger_drow_hit"
tt = E:register_t("fx_faustus_start_attack", "fx")
tt.render.sprites[1].name = "fx_faustus_attack"
tt.render.sprites[1].anchor.y = 0.065
tt = E:register_t("fx_faustus_start_lance", "fx")
tt.render.sprites[1].name = "hero_faustus_rayShoot"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_teleport", "fx")
tt.render.sprites[1].name = "hero_faustus_teleport"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_enervation", "fx")
tt.render.sprites[1].name = "hero_faustus_silence"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_faustus_start_liquid_fire", "fx")
tt.render.sprites[1].name = "fx_faustus_start_liquid_fire"
tt.render.sprites[1].anchor.y = 0.065
tt.render.sprites[1].sort_y_offset = -1
tt = E:register_t("fx_bolt_faustus_hit", "fx")
tt.render.sprites[1].name = "bolt_faustus_hit"
tt = E:register_t("fx_bolt_lance_faustus_hit", "fx")
tt.render.sprites[1].anchor.y = 0.21428571428571427
tt.render.sprites[1].prefix = "fx_bolt_lance_faustus_hit"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt = E:register_t("fx_teleport_faustus", "fx")
tt.render.sprites[1].name = "fx_teleport_faustus"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1), vec_1(1)}
tt = E:register_t("fx_bullet_liquid_fire_faustus_hit", "decal_tween")
tt.render.sprites[1].name = "fx_bullet_liquid_fire_faustus_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {2, 0}}
tt = E:register_t("fx_bravebark_teleport_out", "decal_tween")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "bravebark_teleportOutFx"
tt.render.sprites[1].anchor.y = 0.15517241379310345
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bravebark_hero_teleportDecal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{fts(12), 0}, {fts(13), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportIn"
tt = E:register_t("fx_bravebark_teleport_in", "fx_bravebark_teleport_out")
tt.render.sprites[1].name = "bravebark_teleportInFx"
tt.tween.props[1].keys = {{fts(1), 255}, {fts(44), 0}}
tt.sound_events.insert = "ElvesHeroForestElementalTeleportOut"
tt = E:register_t("fx_bravebark_branchball_hit", "fx")
tt.render.sprites[1].name = "bravebark_superHit"
tt = RT("fx_bravebark_melee_hit", "fx")
tt.render.sprites[1].name = "bravebark_hitSmoke"
tt.render.sprites[1].anchor.y = 0.2
tt = E:register_t("fx_bravebark_ultimate", "fx")
tt.render.sprites[1].name = "bravebark_spikedRoots_spawnFx"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt = E:register_t("fx_xin_smoke_teleport_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_hit", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_hit_out", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_hit_out"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_smoke_teleport_in", "fx")
tt.render.sprites[1].name = "fx_xin_smoke_teleport_in"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = E:register_t("fx_xin_panda_style_smoke", "fx")
tt.render.sprites[1].name = "fx_xin_panda_style_smoke"
tt.render.sprites[1].anchor.y = 0.4
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_catha_ultimate", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_catha_ultimate"
tt.render.sprites[2].z = Z_DECALS
tt = RT("fx_catha_soul", "fx")
tt.render.sprites[1].name = "fx_catha_soul"
tt.render.sprites[1].anchor.y = 0.373015873015873
tt = RT("fx_knife_catha_hit", "fx")
tt.render.sprites[1].name = "fx_knife_catha_hit"
tt = RT("fx_bolt_veznan_hit", "fx")
tt.render.sprites[1].name = "veznan_hero_bolt_hit"
tt = RT("fx_fireball_veznan_demon_hit_air", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit_air"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_fireball_veznan_demon_hit", "fx")
tt.render.sprites[1].name = "fx_fireball_veznan_demon_hit"
tt.render.sprites[1].anchor.y = 0.25925925925925924
tt = RT("fx_veznan_arcanenova", "fx")
tt.render.sprites[1].name = "fx_veznan_arcanenova"
tt.render.sprites[1].anchor.y = 0.11904761904761904
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_veznan_soulburn", "decal_tween")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_desintegrate"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].anchor.y = 0.15217391304347827
tt.tween.props[1].keys = {{0.5, 255}, {1, 0}}
tt = RT("fx_veznan_soulburn_ball_spawn", "fx")
tt.render.sprites[1].prefix = "veznan_hero_soulBurn_proy_spawn"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].z = Z_BULLETS
tt = RT("fx_rag_ultimate", "fx")
tt.render.sprites[1].name = "fx_rag_ultimate"
tt.render.sprites[1].anchor.y = 0.2
tt = RT("fx_rag_raggified", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "rag_polymorphed_fx"
tt.render.sprites[1].size_scales = {vec_1(0.75), vec_1(1), vec_1(1)}
tt.sound_events.insert = "ElvesHeroRagTransform"
tt = RT("fx_rabbit_kamihare_explode", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_rabbit_kamihare_explode"
tt.render.sprites[1].anchor.y = 0.13793103448275862
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "BombExplosionSound"
tt = RT("fx_bullet_rag_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_rag_hit"
tt = RT("fx_durax_ultimate_fang_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_1"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].loop = false
tt.render.sprites[1].size_scales = {vec_1(0.7), vec_1(1), vec_1(1)}
tt.tween.props[1].keys = {{1, 255}, {1.2, 0}}
tt = RT("fx_durax_ultimate_fang_2", "fx_durax_ultimate_fang_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_2"
tt = RT("fx_durax_ultimate_fang_extra_1", "decal_tween")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_1"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{1, 255}, {1.2, 0}}
tt = RT("fx_durax_ultimate_fang_extra_2", "fx_durax_ultimate_fang_extra_1")
tt.render.sprites[1].name = "fx_durax_ultimate_fang_extra_2"
tt = E:register_t("fx_ray_durax_hit", "fx")
tt.render.sprites[1].name = "fx_ray_durax_hit"
tt = RT("fx_shardseed_hit", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_shardseed_hit"
tt.render.sprites[1].anchor.y = 0.46296296296296297
tt.sound_events.insert = "ElvesHeroDuraxShardSpearHit"
tt = RT("fx_meteor_lilith_explosion", "fx")
tt.render.sprites[1].name = "lilith_ultimate_meteor_explosion"
tt.render.sprites[1].anchor.y = 0.20930232558139536
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_lilith_soul_eater_ball_hit", "fx")
tt.render.sprites[1].name = "lilith_soul_eater_explosion_anim"
tt = RT("fx_lilith_ranged_hit", "fx")
tt.render.sprites[1].name = "fx_lilith_ranged_hit"
tt = RT("fx_lynn_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_lynn_explosion"
tt.render.sprites[1].anchor.y = 0.3706896551724138
tt.sound_events.insert = "BombExplosionSound"
tt = RT("fx_flaming_path_start", "fx")
tt.render.sprites[1].name = "fx_flaming_path_start"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt = RT("fx_flaming_path_end", "fx_flaming_path_start")
tt.render.sprites[1].name = "fx_flaming_path_end"
tt = RT("fx_phoenix_explosion", "fx")
tt.render.sprites[1].name = "hero_phoenix_explosion"
tt.render.sprites[1].anchor.y = 0.20588235294117646
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
tt = RT("fx_ray_phoenix_hit", "fx")
tt.render.sprites[1].name = "fx_ray_phoenix_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt = RT("fx_box_wilbur_smoke_a", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_a"
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_box_wilbur_smoke_b", "fx")
tt.render.sprites[1].name = "fx_box_wilbur_smoke_b"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = RT("fx_missile_wilbur_hit", "fx_fireball_veznan_demon_hit")
tt.render.sprites[1].scale = vec_1(1.4)
tt = RT("fx_missile_wilbur_hit_air", "fx_fireball_veznan_demon_hit_air")
tt.render.sprites[1].scale = vec_1(1.4)
tt = RT("fx_shot_wilbur_flash", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_flash"
tt = RT("fx_shot_wilbur_hit", "fx")
tt.render.sprites[1].name = "fx_shot_wilbur_hit"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.render.sprites[1].z = Z_OBJECTS
tt = E:register_t("fx_torch_gnoll_burner_explosion", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion"
tt.render.sprites[1].anchor.y = 0.25
tt = E:register_t("fx_bolt_gnoll_blighter_hit", "fx")
tt.render.sprites[1].name = "gnoll_blighter_proy_hit"
tt = E:register_t("fx_bandersnatch_spine", "decal_tween")
tt.render.sprites[1].name = "bandersnatch_spine_ground"
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{fts(21), 255}, {fts(21) + 0.25, 0}}
tt = E:register_t("fx_bandersnatch_spines_blood", "fx")
tt.render.sprites[1].name = "bandersnatch_spines_blood"
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_redcap_death_blow", "fx")
tt.render.sprites[1].name = "fx_redcap_death_blow"
tt.render.sprites[1].z = Z_EFFECTS
tt = E:register_t("fx_knife_satyr_hit", "fx")
tt.render.sprites[1].name = "fx_knife_satyr_hit"
tt.render.sprites[1].offset.y = 5
tt = E:register_t("fx_twilight_avenger_explosion", "fx")
tt.render.sprites[1].name = "fx_twilight_avenger_explosion"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_twilight_scourger_lash", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_lash"
tt.render.sprites[1].anchor.y = 0.19318181818181818
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_twilight_scourger_banshee_end", "fx")
tt.render.sprites[1].name = "fx_twilight_scourger_banshee_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_faerie_smoke", "fx")
tt.render.sprites[1].prefix = "fx_faerie_smoke"
tt.render.sprites[1].name = "yellow"
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].anchor.y = 0.28
tt = E:register_t("fx_bullet_twilight_evoker_hit", "fx")
tt.render.sprites[1].name = "bullet_twilight_evoker_hit"
tt = E:register_t("fx_twilight_heretic_consume", "fx")
tt.render.sprites[1].name = "fx_twilight_heretic_consume"
tt = E:register_t("fx_bullet_twilight_heretic_hit", "fx")
tt.render.sprites[1].name = "fx_bullet_twilight_heretic_hit"
tt = RT("fx_bolt_ogre_magi_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bolt_ogre_magi_hit_air", "fx")
tt.render.sprites[1].name = "fx_bolt_ogre_magi_hit_air"
tt.render.sprites[1].anchor.y = 0.5555555555555556
tt.render.sprites[1].sort_y_offset = -2
tt = RT("fx_bullet_dark_spitters_miss", "fx")
tt.render.sprites[1].name = "fx_bullet_dark_spitters_miss"
tt.render.sprites[1].anchor.y = 0.26666666666666666
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("fx_bullet_balrog_hit", "fx")
tt.render.sprites[1].name = "balrog_aura_splash"
tt.render.sprites[1].anchor.y = 0.43636363636363634
tt = RT("fx_bullet_catapult_endless_spiked_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_spikebomb"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_bullet_catapult_endless_bomb_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_bomb"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_bullet_catapult_endless_barrel_explosion", "fx_rock_explosion")
tt.render.sprites[1].name = "catapult_endless_explosions_barrel"
tt.render.sprites[1].anchor.y = 0.36875
tt = RT("fx_block_tower_ainyl_end", "fx")
tt.render.sprites[1].name = "ainyl_block_end"
tt.render.sprites[1].offset.y = 30
tt.render.sprites[1].sort_y_offset = -2
tt = E:register_t("fx_plant_magic_blossom_loading", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_loading"
tt.render.sprites[1].offset.y = 34
tt.render.sprites[1].draw_order = 10
tt = E:register_t("fx_plant_magic_blossom_idle1", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle1"
tt.render.sprites[1].offset = vec_2(4, 59)
tt.render.sprites[1].draw_order = 10
tt = E:register_t("fx_plant_magic_blossom_idle2", "decal")
tt.render.sprites[1].name = "fx_plant_magic_blossom_idle2"
tt.render.sprites[1].offset = vec_2(4, 59)
tt.render.sprites[1].draw_order = 10
tt = E:register_t("fx_bolt_plant_magic_blossom_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_plant_magic_blossom_hit"
tt = E:register_t("fx_plant_poison_pumpkin_idle", "decal")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_particles"
tt.render.sprites[1].draw_order = 10
tt = E:register_t("fx_plant_poison_pumpkin_smoke_left", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_left"
tt = E:register_t("fx_plant_poison_pumpkin_smoke_down", "fx")
tt.render.sprites[1].name = "fx_plant_poison_pumpkin_smoke_down"
tt = E:register_t("fx_plant_poison_pumpkin_smoke_fill", "decal_tween")
tt.render.sprites[1].name = "plant_venom_smoke_fill"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 46}, {fts(28), 46}, {fts(43), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.5, 0.5)}, {fts(43), vec_2(1, 1)}}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "offset"
tt.tween.props[3].keys = {{0, vec_2(0, 0)}, {fts(28), vec_2(20, 8)}, {fts(43), vec_2(26, 14)}}
tt = E:register_t("fx_bullet_pixie_instakill_hit_big", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_bullet_pixie_instakill_hit"
tt.sound_events.insert = "BombExplosionSound"
tt = E:register_t("fx_bullet_pixie_instakill_hit_small", "fx_bullet_pixie_instakill_hit_big")
tt.render.sprites[1].scale = vec_1(0.8)
tt = E:register_t("fx_bullet_pixie_poison_hit_big", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].name = "fx_bullet_pixie_poison_hit"
tt.sound_events.insert = "ElvesGnomePoison"
tt = E:register_t("fx_bullet_pixie_poison_hit_small", "fx_bullet_pixie_poison_hit_big")
tt.render.sprites[1].scale = vec_1(0.8)
tt = E:register_t("fx_mod_pixie_polymorph_big", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].anchor.y = 0.11764705882352941
tt.render.sprites[1].name = "fx_mod_pixie_polymorph"
tt.sound_events.insert = "ElvesGnomePolymorf"
tt = E:register_t("fx_mod_pixie_polymorph_small", "fx_mod_pixie_polymorph_big")
tt.render.sprites[1].scale = vec_1(0.8)
tt = E:register_t("fx_mod_pixie_teleport", "fx")
tt.render.sprites[1].prefix = "fx_mod_pixie_teleport"
tt.render.sprites[1].size_names = {"small", "small", "big"}
tt = E:register_t("fx_crystal_arcane_buff", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_towerBuff_fx_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "crystalArcane_towerBuff_fx_0002"
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vec_1(0.9)
tt.render.sprites[2].sort_y_offset = -2
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 10)}, {1, vec_2(0, 44)}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
tt = RT("fx_crystal_unstable_ring", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_ring"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 51}, {fts(5), 255}, {fts(20), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.42)}, {fts(5), vec_1(1.5)}, {fts(20), vec_1(2)}}
tt = RT("fx_crystal_unstable_glow", "decal_tween")
tt.render.sprites[1].name = "crystalUnstable_healAura_glow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}
tt = RT("fx_teleport_out_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_out_crystal_unstable"
tt = RT("fx_teleport_in_crystal_unstable", "fx")
tt.render.sprites[1].name = "fx_teleport_in_crystal_unstable"
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

for i, pos in ipairs({vec_2(-22, 8), vec_2(7, 0), vec_2(-2, 2), vec_2(23, 15), vec_2(-29, 5), vec_2(11, -4),
                      vec_2(-4, 21)}) do
    local s = CC("sprite")

    s.name = "fx_crystal_unstable_bubbles"
    s.time_offset = i * fts(1)
    s.offset = pos

    table.insert(tt.render.sprites, s)
end

tt = E:register_t("decal_arcane_burst_ground", "decal_tween")
tt.render.sprites[1].name = "archer_arcane_special_decal1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "archer_arcane_special_decal2"
tt.tween.props[1].keys = {{0, 255}, {fts(4), 255}, {fts(6), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {fts(4), vec_2(1.84, 1.84)}, {fts(6), vec_2(2.17, 2.17)}}
tt.tween.props[2].sprite_id = 1
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {{0, 255}, {fts(4), 48}, {fts(9), 0}}
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_2(1, 1)}, {fts(4), vec_2(1.64, 1.64)}, {fts(6), vec_2(2.07, 2.07)}}
tt.tween.props[4].sprite_id = 2
tt = E:register_t("decal_rock_crater", "decal_tween")
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
tt.render.sprites[1].name = "artillery_thrower_explosion_decal"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_clobber_1", "decal_tween")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal1"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2.5, 0}}
tt = E:register_t("decal_clobber_2", "decal_clobber_1")
tt.render.sprites[1].name = "EarthquakeTower_HitDecal2"
tt = E:register_t("decal_eerie_root_1", "decal_scripted")
tt.render.sprites[1].prefix = "decal_eerie_roots_1"
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.decal_eerie_root.update
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)
tt = E:register_t("decal_eerie_root_2", "decal_eerie_root_1")
tt.render.sprites[1].prefix = "decal_eerie_roots_2"
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt = E:register_t("decal_bravebark_rootspikes_hit", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_handDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
tt = RT("decal_bravebark_melee_hit", "decal_bravebark_rootspikes_hit")
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = E:register_t("decal_bravebark_rootspike", "decal_scripted")
tt.render.sprites[1].prefix = "bravebark_spike"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.25
tt.main_script.update = scripts.decal_bravebark_rootspike.update
tt.hold_duration = 1
tt.hole_decal = "decal_bravebark_rootspike_hole"
tt.delay = 0
tt.scale = 1
tt = E:register_t("decal_bravebark_rootspike_hole", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikeDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}
tt = E:register_t("decal_bravebark_branchball_enemy_clone", "decal_tween")
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {0.35, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {0.35, vec_2(0, 0)}}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "r"
tt.tween.props[3].keys = {{0, 0}, {0.35, 0}}
tt = E:register_t("decal_bravebark_ultimate", "decal_sequence")
tt.render.sprites[1].prefix = "bravebark_spikedRoots"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.3181818181818182
tt.render.sprites[1].scale = vec_1(0.75)
tt.sequence.steps = {"in", 1, "out"}
tt.sequence.fxs = {"fx_bravebark_ultimate", nil, "decal_bravebark_ultimate_crater"}
tt = E:register_t("decal_bravebark_ultimate_crater", "decal_tween")
tt.render.sprites[1].name = "bravebark_hero_spikedRootsDecal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
tt = E:register_t("decal_xin_inspire", "decal_tween")
tt.render.sprites[1].name = "xin_hero_scream_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 63}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {fts(10), vec_1(0.68)}, {fts(20), vec_1(1.25)}}
tt = E:register_t("decal_xin_drink_circle", "decal_tween")
tt.render.sprites[1].name = "xin_hero_drink_auraCircle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {fts(20), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.7)}, {fts(20), vec_1(1.5)}}
tt = RT("decal_veznan_arcanenova", "decal_bomb_crater")
tt.render.sprites[1].name =         "veznan_hero_arcaneNova_terrainDecal"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_veznan_arcanenova_terrain"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
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
tt = RT("decal_baby_malik_smash", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_ring"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].z = Z_DECALS
tt = RT("decal_baby_malik_earthquake", "decal_bomb_crater")
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_baby_malik_earthquake"
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].anchor.y = 0.24
tt = RT("decal_rag_ultimate", "fx")
tt.render.sprites[1].name = "decal_rag_ultimate"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_durax", "decal")
tt.render.sprites[1].name = "aura_durax"
tt.render.sprites[1].scale = vec_1(1.3)
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_meteor_lilith_explosion", "decal_tween")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = vec_1(0.6)
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 130}, {2.5, 130}, {3.25, 0}}

tt = RT("decal_lilith_soul_eater_ball", "decal_scripted")
AC(tt, "force_motion", "sound_events")
tt.render.sprites[1].name = "lilith_soul_eater_ball_loop"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
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

tt = RT("decal_lilith_reapers_harvest", "decal_timed")
tt.render.sprites[1].name = "lilith_reapers_harvest_decal_anim"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_phoenix_ultimate", "decal_rock_crater")
tt.render.sprites[1].name = "phoenix_hero_egg_decal"
tt = RT("decal_phoenix_flaming_path_pulse", "decal_tween")
tt.render.sprites[1].name = "phoenix_hero_towerBurn_Circle"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.32, vec_2(2.4, 2.4)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.32, 0}}
tt = E:register_t("decal_twilight_scourger_lash", "decal_tween")
tt.render.sprites[1].name = "scourger_special_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.tween.props[1].keys = {{fts(11), 153}, {fts(16), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
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
tt = E:register_t("decal_twilight_golem_attack", "decal_tween")
tt.render.sprites[1].name = "gollem_attackFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset.x = 22
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].offset.x = -22
tt.tween.props[1].keys = {{0, 255}, {fts(12), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(1)}, {fts(12), vec_1(2.3)}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
tt = E:register_t("decal_twilight_heretic_consume_ball", "decal_scripted")

E:add_comps(tt, "force_motion")

tt.render.sprites[1].name = "twilight_heretic_consumeProy"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
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
tt = E:register_t("decal_drider_clone", "decal_timed")
tt.timed.duration = 1
tt = E:register_t("decal_drider_cocoon", "decal_scripted")
tt.render.sprites[1].prefix = "decal_drider_cocoon"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_scales = {vec_1(0.8), vec_1(1), vec_1(1)}
tt.render.sprites[1].anchor.y = 0.16
tt.main_script.update = scripts.decal_drider_cocoon.update
tt.duration = 5
tt = E:register_t("decal_arachnomancer_mini_spider", "decal_scripted")

E:add_comps(tt, "motion")

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
tt = E:register_t("decal_webspawn_enemy_spider_arachnomancer", "decal_scripted")

E:add_comps(tt, "nav_path")

tt.main_script.insert = scripts.delayed_spawn.insert
tt.main_script.update = scripts.delayed_spawn.update
tt.render.sprites[1].prefix = "arachnomancer_webspawn"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].anchor.y = 0.1875
tt.render.sprites[1].sort_y_offset = -1
tt.delay = fts(8)
tt.entity = "enemy_spider_arachnomancer"
tt = E:register_t("decal_webspawn_enemy_sword_spider", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_sword_spider"
tt = E:register_t("decal_webspawn_enemy_spider_son_of_mactans", "decal_webspawn_enemy_spider_arachnomancer")
tt.entity = "enemy_spider_son_of_mactans"
tt = RT("decal_shadow_spider_son_of_mactans", "decal_tween")
tt.render.sprites[1].name = "son_of_mactans_shadow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2 + fts(21), 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_1(0)}, {2, vec_1(1)}}
tt.tween.props[2].name = "scale"
tt = RT("decal_mactans_path_web_1", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_floorNet_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.props[1].keys = {{0, 0}, {"this.fade_duration", 255}, {"this.duration-this.fade_duration", 255},
                          {"this.duration", 0}}
tt = RT("decal_mactans_path_web_2", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0002"
tt = RT("decal_mactans_path_web_3", "decal_mactans_path_web_1")
tt.render.sprites[1].name = "spiderQueen_floorNet_0003"
tt = RT("decal_bloodsydian_warlock", "decal_tween")
tt.tween.props[1].keys = {{0, 255}, {0.25, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {0.25, vec_2(2.4, 2.4)}}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "bloodsydianWarlock_convert_aura"
tt.render.sprites[1].z = Z_DECALS
tt = RT("decal_snare_hee_haw", "decal_tween")
tt.render.sprites[1].anchor = vec_2(0.4785714285714286, 0.31)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "hee-haw_net_0031"
tt.tween.props[1].keys = {{0, 0}, {1, 255}, {fts(60), 255}, {fts(65), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{fts(11), vec_1(0.3)}, {fts(65), vec_1(0.6)}}
tt.tween.props[2].name = "scale"
tt.tween.remove = true
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
tt.ranged.attacks[1].barrel_payloads = {"enemy_gnoll_reaver", "enemy_gnoll_burner", "enemy_gnoll_gnawer",
                                        "enemy_gnoll_blighter"}
tt = E:register_t("decal_crystal_arcane_freeze_center", "decal_tween")
tt.render.sprites[1].name = "crystalArcane_groundFreeze_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.duration", 255}, {"this.duration+0.3", 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.2)}, {0.2, vec_1(1)}}
tt = E:register_t("decal_crystal_arcane_freeze_1", "decal_tween")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {"this.duration", 255}, {"this.duration+0.3", 0}}
tt = E:register_t("decal_crystal_arcane_freeze_2", "decal_crystal_arcane_freeze_1")
tt.render.sprites[1].name = "decal_crystal_arcane_freeze_2"

tt = E:register_t("tower_holder_elven_woods", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ELVEN_WOODS
tt.render.sprites[1].name = "build_terrain_0001"
tt = E:register_t("tower_holder_faerie_grove", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FAERIE_GROVE
tt.render.sprites[1].name = "build_terrain_0002"
tt = E:register_t("tower_holder_ancient_metropolis", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ANCIENT_METROPOLIS
tt.render.sprites[1].name = "build_terrain_0003"
tt = E:register_t("tower_holder_hulking_rage", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_HULKING_RAGE
tt.render.sprites[1].name = "build_terrain_0004"
tt = E:register_t("tower_holder_bittering_rancor", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BITTERING_RANCOR
tt.render.sprites[1].name = "build_terrain_0005"
tt = E:register_t("tower_holder_forgotten_treasures", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FORGOTTEN_TREASURES
tt.render.sprites[1].name = "build_terrain_0006"


tt = RT("tower_bastion_holder")

AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor", "editor_script")

tt.editor.props = {{"tower.default_rally_pos", PT_COORDS}, {"tower.holder_id", PT_STRING},
                   {"editor.game_mode", PT_NUMBER}}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
tt.tower.type = "holder_bastion"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower.menu_offset = vec_2(-10, 16)
tt.info.fn = scripts.tower_bastion.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "kr3_info_portraits_towers") .. "_0020"
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
tt = RT("tower_bastion", "tower")

AC(tt, "attacks", "powers")

tt.info.portrait = (IS_PHONE and "portraits_towers" or "kr3_info_portraits_towers") .. "_0020"
tt.info.i18n_key = "ELVES_TOWER_BASTION"
tt.info.fn = scripts.tower_bastion.get_info
tt.main_script.insert = scripts.tower_bastion.insert
tt.main_script.update = scripts.tower_bastion.update
tt.powers.razor_edge = CC("power")
tt.powers.razor_edge.max_level = 2
tt.powers.razor_edge.price_base = 200
tt.powers.razor_edge.price_inc = 200
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
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].bullet = "bullet_razor_edge"
tt.attacks.list[1].payload_name = "aura_razor_edge"
tt.attacks.list[1].bullet_start_offset = {vec_2(40, 33)}
tt.attacks.list[1].cooldown = 1.5
tt.attacks.list[1].shoot_time = fts(9)
tt.attacks.list[1].sound_shoot = "ElvesTowerBastionShot"
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_FRIEND)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
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

tt = E:register_t("soldier_bravebark", "soldier_militia")
E:add_comps(tt, "reinforcement")
image_y = 58
anchor_y = 12 / image_y
tt.health.armor = 0
tt.health.hp_max = 50
tt.health_bar.offset = vec_2(0, 44)
tt.health_bar.size = HEALTH_BAR_SIZE_MEDIUM
-- tt.info.fn = scripts.soldier_reinforcement.get_info
tt.info.portrait = "kr3_portraits_sc_0057"
tt.info.i18n_key = "HERO_ELVES_FOREST_ELEMENTAL_MINION"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.cooldown = 1
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 1
tt.regen.health = 0
tt.reinforcement.duration = 20
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "bravebark_mignon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = vec_2(4, 0)
tt.sound_events.insert = nil
tt.unit.level = 0
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN, F_POISON)

tt = E:register_t("soldier_xin_shadow", "soldier")
E:add_comps(tt, "melee")
image_y = 64
anchor_y = 12 / image_y
tt.health.armor = 0
tt.health.hp_max = 50
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.info.random_name_format = nil
tt.min_wait = 0.1
tt.max_wait = 0.4
tt.main_script.insert = scripts.soldier_xin_shadow.insert
tt.main_script.update = scripts.soldier_xin_shadow.update
tt.motion.max_speed = 90
tt.regen.cooldown = 1
tt.regen.health = 0
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "xin_shadow"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].sort_y_offset = -2
tt.soldier.melee_slot_offset = vec_2(5, 0)
tt.sound_events.insert = nil
tt.sound_events.death = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.level = 0
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.flags = bor(F_FRIEND)
tt.vis.bans = bor(F_ALL)
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(4)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].xp_gain_factor = 0
tt.melee.attacks[1].chance = 1

for i = 2, 4 do
    local a = table.deepclone(tt.melee.attacks[1])

    a.animation = "attack" .. i
    a.chance = 1 / i
    tt.melee.attacks[i] = a
end

tt.melee.cooldown = fts(15)
tt.melee.range = 60
tt = E:register_t("soldier_xin_ultimate", "soldier_xin_shadow")
tt.max_attack_count = 2
tt.min_wait = 0.1
tt.max_wait = 0.4

for i = 1, 4 do
    tt.melee.attacks[i].damage_type = DAMAGE_TRUE
    tt.melee.attacks[i].sound = "ElvesHeroXinPandamoniumHit"
end

tt.sound_events.insert = "ElvesHeroXinAfterTeleportIn"
tt.sound_events.death = "ElvesHeroXinAfterTeleportOut"

tt = RT("soldier_catha", "soldier_militia")
AC(tt, "reinforcement", "ranged", "tween")
tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 45)
tt.info.portrait = "kr3_portraits_sc_0066"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.info.i18n_key = "HERO_ELVES_PIXIE_SHADOW"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.range = 60
tt.motion.max_speed = 90
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].bullet = "knife_soldier_catha"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 27)}
tt.ranged.attacks[1].shoot_time = fts(7)
tt.regen.cooldown = 1
tt.regen.health = 10
tt.reinforcement.duration = 10
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.373
tt.render.sprites[1].prefix = "soldier_catha"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.ranged = {"shoot", "shootUp", "shoot"}
tt.render.sprites[1].angles_custom = {
    ranged = {45, 135, 210, 315}
}
tt.render.sprites[1].angles_flip_vertical = {
    ranged = true
}
tt.soldier.melee_slot_offset = vec_2(3, 0)
tt.sound_events.death = "ElvesHeroCathaTaleDeath"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(6), vec_2(0, 0)}}
tt.tween.remove = false
tt.tween.run_once = true
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.level = 0
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.hide_after_death = true

tt = RT("soldier_veznan_demon", "soldier_militia")
AC(tt, "reinforcement", "ranged", "nav_grid")
tt.controable = true
tt.controable_other = true
tt.health.armor = 0
tt.health.hp_max = nil
tt.health_bar.offset = vec_2(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr3_portraits_sc_0058"
tt.info.random_name_count = 8
tt.info.random_name_format = "ELVES_SOLDIER_VEZNAN_DEMON_%i_NAME"
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = scripts.soldier_reinforcement.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].mod = "mod_veznan_demon_fire"
tt.melee.continue_in_cooldown = true

function tt.melee.fn_can_pick(soldier, target)
    return target.template_name ~= "enemy_mantaray"
end

tt.melee.range = 65
tt.motion.max_speed = 75
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 65
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].bullet = "fireball_veznan_demon"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 42)}
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].node_prediction = fts(25)
tt.regen = nil
tt.reinforcement.duration = 30
tt.reinforcement.fade = nil
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].prefix = "veznan_demon"
tt.render.sprites[1].name = "raise"
tt.soldier.melee_slot_offset = vec_2(10, 0)
tt.sound_events.death = "ElvesHeroVeznanDemonDeath"
tt.ui.click_rect = r(-10, 0, 20, 30)
tt.unit.level = 0
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(0, 28)
tt.unit.hide_after_death = true
tt.vis.flags = bor(tt.vis.flags, F_HERO)
tt.vis.bans = bor(F_POISON, F_NET, F_STUN, F_BURN)
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

tt = RT("soldier_lilith_angel", "soldier_xin_shadow")
tt.angel_damage_type = DAMAGE_TRUE
tt.sound_events.insert = "ElvesHeroLilithAngelsCast"
tt.render.sprites[1].prefix = "lilith_ultimate_angel"
tt.render.sprites[1].anchor.y = 0.1875
tt.max_attack_count = 2
tt.min_wait = 0
tt.max_wait = 0
tt.soldier.melee_slot_offset = vec_2(-13, 0)
tt.melee.attacks[1].damage_max = nil
tt.melee.attacks[1].damage_min = nil
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].sound = "ElvesHeroLilithAngelsHit"
tt.melee.attacks[2] = nil
tt.melee.attacks[3] = nil
tt.melee.attacks[4] = nil
tt.melee.cooldown = 0
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

-- tt = E:register_t("soldier_re_0", "soldier_militia")
-- E:add_comps(tt, "reinforcement", "tween")
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

-- tt = E:register_t("soldier_re_1", "soldier_re_0")
-- tt.unit.level = 1
-- tt.health.hp_max = 60
-- tt.health.armor = 0.2
-- tt.melee.attacks[1].damage_max = 5
-- tt.melee.attacks[1].damage_min = 3
-- tt.render.sprites[1].prefix = "soldier_re_%s0"

-- tt = E:register_t("soldier_re_2", "soldier_re_1")
-- E:add_comps(tt, "ranged")
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

-- tt = E:register_t("soldier_re_3", "soldier_re_2")
-- tt.unit.level = 3
-- tt.health.hp_max = 100
-- tt.health.armor = 0.35
-- tt.info.portrait_idxs = {40, 44, 48}
-- tt.melee.attacks[1].damage_max = 10
-- tt.melee.attacks[1].damage_min = 5
-- tt.render.sprites[1].prefix = "soldier_re_%s2"
-- tt.ranged.attacks[1].bullet = "arrow_soldier_re_3"
-- tt.ranged.attacks[1].max_range = 150

-- tt = E:register_t("soldier_re_4", "soldier_re_3")
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

-- tt = E:register_t("soldier_re_5", "soldier_re_4")
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
--         local t = E:register_t(fn, base_t)

--         t.render.sprites[1].prefix = string.format(t.render.sprites[1].prefix, k)
--         t.info.portrait = string.format("kr3_portraits_sc_00%02d", t.info.portrait_idxs[i])
--     end
-- end

-- for i = 1, 3 do
--     E:set_template("re_current_" .. i, E:get_template("soldier_re_0_" .. i))
-- end

tt = E:register_t("fx_elves_denas_flash", "fx")
tt.render.sprites[1].name = "fx_elves_denas_flash"
tt = E:register_t("shield_elves_denas", "bullet")
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.particles_name = "ps_shield_elves_denas"
tt.bullet.max_speed = 10 * FPS
tt.bullet.hit_blood_fx = "fx_blood_splat"
tt.bullet.hit_fx = "fx_shield_elves_denas_hit"
tt.main_script.update = scripts.shield_elves_denas.update
tt.render.sprites[1].name = "shield_elves_denas_loop"
tt.rebound_range = 125
tt = E:register_t("fx_shield_elves_denas_hit", "fx")
tt.render.sprites[1].name = "fx_shield_elves_denas_hit"
tt.render.sprites[1].z = Z_EFFECTS - 1

tt = E:register_t("decal_minidragon_faustus", "decal_scripted")
E:add_comps(tt, "motion", "attacks")
tt.main_script.update = scripts.decal_minidragon_faustus.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].disabled = true
tt.attacks.list[1].bullet = "aura_minidragon_faustus"
tt.attacks.list[1].bullet_start_offset = vec_2(25, 70)
tt.attacks.list[1].cooldown = fts(2)
tt.attacks.list[1].sound = "ElvesHeroFaustusFire"
tt.render.sprites[1].prefix = "minidragon_faustus_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].offset = vec_2(0, 70)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "minidragon_faustus_l2"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(0, 70)
tt.emit_ox = 180
tt.cast_ox = 80
tt.image_w = 40

-- tt = E:register_t("hero_alleria", "stage_hero")

-- E:add_comps(tt, "melee", "ranged")

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
-- tt.ranged.attacks[1] = E:clone_c("bullet_attack")
-- tt.ranged.attacks[1].animation = "ranged"
-- tt.ranged.attacks[1].bullet = "arrow_hero_alleria"
-- tt.ranged.attacks[1].bullet_start_offset = {vec_2(9, 24)}
-- tt.ranged.attacks[1].cooldown = 1
-- tt.ranged.attacks[1].max_range = 200
-- tt.ranged.attacks[1].min_range = 40
-- tt.ranged.attacks[1].node_prediction = fts(11)
-- tt.ranged.attacks[1].shoot_time = fts(11)
-- tt.ranged.attacks[2] = E:clone_c("bullet_attack")
-- tt.ranged.attacks[2].animation = "shootSpecial"
-- tt.ranged.attacks[2].bullet = "arrow_multishot_hero_alleria"
-- tt.ranged.attacks[2].bullet_start_offset = {vec_2(9, 24)}
-- tt.ranged.attacks[2].cooldown = 5
-- tt.ranged.attacks[2].max_range = 200
-- tt.ranged.attacks[2].min_range = 40
-- tt.ranged.attacks[2].node_prediction = fts(13)
-- tt.ranged.attacks[2].shoot_time = fts(13)
-- tt.ranged.attacks[2].sound = "ElvesHeroAlleriaShoot"
-- tt = E:register_t("hero_alleria_fixed", "hero_alleria")
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
-- tt = E:register_t("arrow_hero_alleria", "arrow")
-- tt.bullet.flight_time = fts(22)
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 15
-- tt = E:register_t("arrow_multishot_hero_alleria", "arrow")
-- tt.bullet.particles_name = "ps_arrow_multishot_hero_alleria"
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 15
-- tt.bullet.damage_true = DAMAGE_TRUE
-- tt.bullet.flight_time = fts(22)
-- tt.extra_arrows_range = 100
-- tt.extra_arrows = 2
-- tt.main_script.insert = scripts.arrow_multishot_hero_alleria.insert
-- tt.render.sprites[1].name = "hero_alleria_arrow-f"
-- tt = E:register_t("arrow_hero_alleria_fixed", "arrow_hero_alleria")
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 30
-- tt.bullet.prediction_error = nil
-- tt = E:register_t("arrow_multishot_hero_alleria_fixed", "arrow_multishot_hero_alleria")
-- tt.bullet.damage_min = 10
-- tt.bullet.damage_max = 30
-- tt.bullet.prediction_error = nil
-- tt.extra_arrows = 3
-- tt = E:register_t("alleria_cat", "soldier")

-- E:add_comps(tt, "nav_grid")

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
tt.info.hero_portrait = "kr3_hero_portraits_0013"
tt.info.i18n_key = "HERO_ELVES_MALIK"
tt.info.portrait = (IS_PHONE and "portraits_hero" or "kr3_info_portraits_heroes") .. "_0013"
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

tt = E:register_t("plant_magic_blossom", "decal_scripted")
E:add_comps(tt, "custom_attack", "ui", "plant")
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
tt = E:register_t("plant_poison_pumpkin", "decal_scripted")

E:add_comps(tt, "custom_attack", "ui", "plant", "editor")

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
tt = E:register_t("crystal_arcane", "decal_scripted")

E:add_comps(tt, "attacks", "ui", "crystal", "editor", "tween")

tt.main_script.update = scripts.crystal_arcane.update
tt.attacks.cooldown = math.floor(19.148936170212767) * 47 / 30
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].animation = "lightning"
tt.attacks.list[1].bullet = "ray_crystal_arcane"
tt.attacks.list[1].bullet_count = 5
tt.attacks.list[1].chance = 0.3
tt.attacks.list[1].range = 195
tt.attacks.list[1].sound = "ElvesCrystalRay"
tt.attacks.list[1].bullet_start_offset = vec_2(0, 40)
tt.attacks.list[2] = E:clone_c("aura_attack")
tt.attacks.list[2].animations = {"freeze_start", "freeze_loop", "freeze_end"}
tt.attacks.list[2].aura = "aura_crystal_arcane_freeze"
tt.attacks.list[2].chance = 0.4
tt.attacks.list[2].range = 195
tt.attacks.list[2].hit_time = fts(15)
tt.attacks.list[2].duration = math.floor(8) * 15 / 30
tt.attacks.list[2].sound = "ElvesCrystalIce"
tt.attacks.list[2].fx_center = "decal_crystal_arcane_freeze_center"
tt.attacks.list[2].fxs = {"decal_crystal_arcane_freeze_1", "decal_crystal_arcane_freeze_2"}
tt.attacks.list[3] = E:clone_c("aura_attack")
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
    local s = E:clone_c("sprite")

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
    local s = E:clone_c("sprite")

    s.prefix = "crystal_unstable_layer" .. i
    s.name = "loading"
    s.anchor.y = 0.18828451882845187
    tt.render.sprites[i] = s
end

tt = RT("paralyzing_tree", "decal_scripted")

E:add_comps(tt, "custom_attack", "ui", "plant")

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
tt = RT("mod_paralyzing_tree", "mod_stun")
tt.modifier.duration = 4
tt.render.sprites[1].prefix = "mod_paralyzing_tree"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
tt = RT("fx_paralyzing_tree_1", "fx")
tt.render.sprites[1].name = "fx_paralyzing_tree_1"
tt.render.sprites[1].z = Z_DECALS
tt = RT("fx_paralyzing_tree_2", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_2"
tt = RT("fx_paralyzing_tree_3", "fx_paralyzing_tree_1")
tt.render.sprites[1].name = "fx_paralyzing_tree_3"



tt = E:register_t("bolt_elves_1", "bolt_elves")
tt.alter_reality_chance = 0.1
tt.alter_reality_mod = "mod_teleport_mage"
tt.bullet.damage_min = 4
tt.bullet.damage_max = 6
tt.bullet.particles_name = "ps_bolt_elves_1"
tt.render.sprites[1].scale = vec_2(0.8, 0.8)
tt = E:register_t("bolt_elves_2", "bolt_elves_1")
tt.bullet.damage_min = 9
tt.bullet.damage_max = 15
tt.bullet.particles_name = "ps_bolt_elves_2"
tt.render.sprites[1].scale = vec_2(0.9, 0.9)
tt = E:register_t("bolt_elves_3", "bolt_elves_1")
tt.bullet.damage_min = 17
tt.bullet.damage_max = 28
tt.bullet.particles_name = "ps_bolt_elves_3"
tt.render.sprites[1].scale = vec_2(1, 1)

tt = E:register_t("arrow_soldier_barrack_2", "arrow")
tt.bullet.damage_max = 7
tt.bullet.damage_min = 3
tt.bullet.flight_time = fts(15)
tt.bullet.reset_to_target_pos = true
tt = E:register_t("arrow_soldier_barrack_3", "arrow_soldier_barrack_2")
tt.bullet.damage_max = 12
tt.bullet.damage_min = 8
tt = E:register_t("arrow_soldier_re_2", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 6
tt.bullet.reset_to_target_pos = true
tt.bullet.flight_time = fts(13)
tt.bullet.hide_radius = 2
tt.bullet.hit_fx = "fx_arrow_soldier_re_hit"
tt.bullet.miss_decal = "reinforce_proy_0010"
tt.bullet.rotation_speed = 40 * FPS * math.pi / 180
tt.render.sprites[1].name = "reinforce_proy_0001"
tt = E:register_t("arrow_soldier_re_3", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
tt = E:register_t("arrow_soldier_re_4", "arrow_soldier_re_2")
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
tt = E:register_t("arrow_soldier_re_5", "arrow_soldier_re_2")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20


tt = E:register_t("bolt_lance_faustus", "bolt")
tt.bullet.acceleration_factor = 0.25
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_lance_faustus_hit"
tt.bullet.ignore_hit_offset = true
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.pop = nil
tt.bullet.particles_name = "ps_bolt_lance_faustus"
tt.render.sprites[1].prefix = "bolt_lance_faustus"
tt.render.sprites[1].hidden = true
tt.sound_events.insert = nil
tt = E:register_t("bullet_liquid_fire_faustus", "bullet")
tt.main_script.update = scripts.bullet_liquid_fire_faustus.update
tt.render = nil
tt.bullet.particles_name = "ps_bullet_liquid_fire_faustus"
tt.bullet.flight_time = fts(10)
tt.flames_count = nil
tt.bullet.hit_fx = "fx_bullet_liquid_fire_faustus_hit"
tt = E:register_t("bullet_bravebark_seed", "bomb")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(22)
tt.bullet.hide_radius = nil
tt.bullet.pop = nil
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.render.sprites[1].name = "bravebark_hero_mignonSeed"
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

tt = RT("knife_soldier_catha", "knife_catha")
tt.bullet.xp_gain_factor = nil
tt.bullet.mod = "mod_soldier_catha_curse"

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

tt = RT("ray_rag", "bullet")
tt.image_width = 164
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].name = "ray_rag"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_time = fts(5)
tt.bullet.mod = "mod_rag_raggified"

tt = RT("bullet_rag_throw", "arrow")
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(12)
tt.bullet.miss_decal = nil
tt.bullet.miss_fx = nil
tt.bullet.miss_fx_water = nil
tt.bullet.pop = nil
tt.bullet.predict_target_pos = true
tt.bullet.rotation_speed = 15 * FPS * math.pi / 180
tt = RT("bullet_rag_throw_bolso", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0001"
tt = RT("bullet_rag_throw_anchor", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0002"
tt = RT("bullet_rag_throw_fungus", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0003"
tt = RT("bullet_rag_throw_pan", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0004"
tt = RT("bullet_rag_throw_chair", "bullet_rag_throw")
tt.render.sprites[1].name = "razzAndRaggs_hero_throw_proys_0005"
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
tt = RT("spear_durax_clone", "spear_durax")
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
    tint_color = {0, 1, 1, 1}
}

tt = RT("meteor_lilith", "bullet")
tt.main_script.update = scripts.meteor_lilith.update
tt.bullet.damage_max = nil
tt.bullet.damage_radius = 45
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.arrive_decal = "decal_meteor_lilith_explosion"
tt.bullet.arrive_fx = "fx_meteor_lilith_explosion"
tt.bullet.max_speed = 1050
tt.bullet.mod = "mod_hero_elves_archer_slow"
tt.render.sprites[1].name = "fallen_angel_hero_ultimate_meteor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 0.9166666666666666
tt.sound_events.hit = "ElvesHeroLilithMeteorsHit"


tt = E:register_t("torch_gnoll_burner", "arrow")
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
tt = E:register_t("bullet_gnoll_blighter", "bullet")
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
tt = E:register_t("arrow_twilight_elf_harasser", "arrow")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 20
tt.main_script.insert = scripts.arrow_twilight_elf_harasser.insert
tt.flight_time_range = {fts(15), fts(26)}
tt.bullet.predict_target_pos = false
tt = E:register_t("arrow_twilight_elf_harasser_shadowshot", "arrow")
tt.bullet.damage_max = 35
tt.bullet.damage_min = 25
tt.bullet.predict_target_pos = false
tt = E:register_t("knife_satyr", "arrow")
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
tt = E:register_t("bullet_twilight_evoker", "arrow")
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
tt = E:register_t("bullet_twilight_heretic", "bolt_enemy")
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
tt = E:register_t("bullet_arachnomancer_spawn", "bomb")

E:add_comps(tt, "nav_path")

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
tt = E:register_t("bolt_ogre_magi", "bolt_enemy")
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
tt = RT("snare_hee_haw", "bullet")
tt.main_script.update = scripts.snare_hee_haw.update
tt.render.sprites[1].anchor.y = 0.3418803418803419
tt.render.sprites[1].prefix = "snare_hee_haw"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].scale = vec_1(0.5)
tt.render.sprites[1].z = Z_BULLETS
tt.sound_events.insert = "EndlessHeeHawNetHit"
tt.sound_events.falling = "EndlessHeeHawNetFalling"
tt.sound_events.hit = "EndlessHeeHawNetHit"
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = bor(F_ENEMY, F_FLYING)
tt.bullet.mod = "mod_snare_hee_haw"
tt.bullet.mod_radius = 5
tt = RT("bullet_catapult_endless_rock", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0001"
tt.bullet.damage_max = 100
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_rock_explosion"
tt = RT("bullet_catapult_endless_spiked", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0002"
tt.bullet.damage_max = 200
tt.bullet.damage_min = 200
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_spiked_explosion"
tt = RT("bullet_catapult_endless_bomb", "rock_enemy_catapult")
tt.render.sprites[1].name = "bullet_catapult_endless_bomb"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = 300
tt.bullet.damage_min = 300
tt.bullet.damage_radius = 60
tt.bullet.hit_fx = "fx_bullet_catapult_endless_bomb_explosion"
tt = RT("bullet_catapult_endless_barrel", "rock_enemy_catapult")
tt.render.sprites[1].name = "catapult_endless_proy_0003"
tt.bullet.hit_fx = "fx_bullet_catapult_endless_barrel_explosion"
tt = E:register_t("bolt_plant_magic_blossom", "bolt_elves")
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

tt = E:register_t("ray_crystal_arcane", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.mod = "mod_ray_crystal_arcane"
tt.bullet.hit_time = fts(4)
tt.image_width = 92
tt.track_target = true
tt.main_script.update = scripts.ray_simple.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_crystal_arcane"

tt = E:register_t("aura_liquid_fire_flame_faustus", "aura")
E:add_comps(tt, "render", "tween")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_liquid_fire_faustus"
tt.aura.duration = 8
tt.aura.cycle_time = fts(10)
tt.aura.radius = 35
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "aura_liquid_fire_flame_faustus"
tt.sound_events.insert = "ElvesHeroFaustusFireLoop"
tt.sound_events.remove_stop = "ElvesHeroFaustusFireLoop"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {0.5, vec_1(1)}}

tt = E:register_t("aura_minidragon_faustus", "aura_liquid_fire_flame_faustus")
tt.aura.mod = "mod_minidragon_faustus"
tt.tween.props[1].keys = {{0, 0}, {0.05, 255}, {"this.aura.duration-1", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = nil
tt = E:register_t("aura_enervation_faustus", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_enervation_faustus"
tt.aura.cycle_time = 0
tt.aura.cycles = 1
tt.aura.radius = 100
tt.aura.vis_flags = bor(F_RANGED, F_SPELLCASTER)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO)
tt.aura.targets_per_cycle = nil
tt = E:register_t("aura_teleport_faustus", "aura")

E:add_comps(tt, "render", "tween")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_teleport_faustus"
tt.aura.cycle_time = 1000000000
tt.aura.duration = fts(20)
tt.aura.radius = 50
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND, F_HERO, F_FREEZE)
tt.aura.targets_per_cycle = nil
tt.render.sprites[1].name = "aura_teleport_faustus"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 55}, {fts(5), 255}, {fts(15), 255}, {fts(20), 0}}
tt = E:register_t("aura_bravebark_springsap", "aura")
E:add_comps(tt, "render", "tween")
tt.aura.cycle_time = fts(3)
tt.aura.mod = "mod_bravebark_springsap"
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.excluded_templates = {"soldier_xin_shadow"}
tt.aura.radius = 100
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "bravebark_hero_springSapDecal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "bravebark_springSapBubbles"
tt.render.sprites[2].anchor.y = 0
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {0.85, 0}}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.5)}, {0.85, vec_1(1.25)}}
tt.tween.props[2].loop = true
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
tt = RT("aura_rabbit_kamihare", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = 30
tt.aura.damage_max = 40
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.radius = 37.5
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
tt = RT("aura_lilith_infernal_wheel", "aura")

AC(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.cycle_time = fts(10)
tt.aura.mod = "mod_lilith_infernal_wheel"
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.radius = 50
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "lilith_infernal_base_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "lilith_infernal_base_fireIn_loop"
tt.render.sprites[2].hide_after_runs = 1
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
tt = RT("aura_lilith_soul_eater", "aura")
tt.aura.duration = -1
tt.aura.cooldown = 15
tt.aura.cycle_time = fts(5)
tt.aura.radius = 200
tt.aura.vis_bans = bor(F_BOSS, F_FLYING)
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.excluded_templates = {"enemy_hyena"}
tt.aura.mod = "mod_lilith_soul_eater_track"
tt.main_script.update = scripts.aura_lilith_soul_eater.update

tt = RT("aura_bruce_hps", "aura")
AC(tt, "hps")
tt.aura.duration = -1
tt.main_script.update = scripts.aura_bruce_hps.update
tt.hps.heal_max = 3
tt.hps.heal_every = 1


tt = RT("aura_bomb_wilbur", "aura_rabbit_kamihare")
tt.aura.damage_min = 110
tt.aura.damage_max = 155
tt.aura.radius = 30
tt.sound_events.insert = "BombExplosionSound"
tt = RT("aura_bobbing_wilbur", "aura")
tt.aura.duration = -1
tt.main_script.update = scripts.aura_wilbur_bobbing.update
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
tt = RT("aura_smoke_wilbur", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = 0.2
tt.aura.duration = nil
tt.aura.mod = "mod_slow_wilbur"
tt.aura.radius = 60
tt.aura.vis_bans = bor(F_FRIEND)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

for i, offset in ipairs({vec_2(25, -20), vec_2(-11, -20), vec_2(7, 5)}) do
    local s = CC("sprite")

    s.name = "decal_wilbur_smoke"
    s.offset = offset
    s.anchor.y = 0.15
    s.scale = vec_2(1, 1)
    tt.render.sprites[i] = s
    tt.tween.props[2 * i - 1] = CC("tween_prop")
    tt.tween.props[2 * i - 1].keys = {{0, 0}, {0.6, 255}, {"this.aura.duration-0.6", 255}, {"this.aura.duration", 0}}
    tt.tween.props[2 * i - 1].sprite_id = i
    tt.tween.props[2 * i] = CC("tween_prop")
    tt.tween.props[2 * i].keys = {{0, vec_1(0.3)}, {fts(13), vec_1(1.1)}, {fts(15), vec_1(1)}}
    tt.tween.props[2 * i].name = "scale"
    tt.tween.props[2 * i].sprite_id = i
end

tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].anchor.y = 0.14545454545454545
tt.render.sprites[4].name = "fx_wilbur_smoke_start"
tt.render.sprites[4].hide_after_runs = 1
tt.tween.remove = false
tt = E:register_t("aura_gnoll_gnawer", "aura")
tt.main_script.update = scripts.aura_gnoll_gnawer.update
tt.min_count = 4
tt.aura.radius = 100
tt.aura.cycle_time = 0.25
tt.aura.mod = "mod_gnoll_gnawer"
tt.aura.vis_flags = F_RANGED
tt = E:register_t("aura_ettin_regen", "aura")

E:add_comps(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
tt.regen.cooldown = fts(5)
tt.regen.health = 4
tt = E:register_t("aura_bandersnatch_spines", "aura")
tt.main_script.update = scripts.aura_bandersnatch_spines.update
tt.aura.radius = 125
tt.aura.damage_max = 200
tt.aura.damage_min = 140
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.hit_fx = "fx_bandersnatch_spines_blood"
tt.spines_count = 27
tt = E:register_t("aura_boomshrooms_death", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = {40, 40, 40, 50}
tt.aura.damage_max = {40, 40, 40, 60}
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = 87.5
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.vis_flags = bor(F_RANGED)
tt.main_script.update = scripts.aura_apply_damage.update
tt = E:register_t("aura_razorboar_rage", "aura")
tt.main_script.update = scripts.aura_razorboar_rage.update
tt.main_script.insert = scripts.aura_razorboar_rage.insert
tt.main_script.remove = scripts.aura_razorboar_rage.remove
tt.damage_hp_factor = 1
tt.aura.track_source = true
tt = RT("aura_spider_sprint", "aura")

AC(tt, "editor", "editor_script")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_spider_sprint"
tt.aura.cycle_time = fts(10)
tt.aura.allowed_templates = {"enemy_drider", "enemy_spider_tarantula", "enemy_spider_arachnomancer",
                             "enemy_spider_son_of_mactans", "enemy_sword_spider", "enemy_webspitting_spider"}
tt.editor.components = {"render"}
tt.editor.overrides = {
    ["render.sprites[1].hidden"] = false,
    ["render.sprites[1].animated"] = false,
    ["render.sprites[1].name"] = "editor_red_circle"
}
tt.editor.props = {{"aura.radius", PT_NUMBER}}
tt.editor_script.update = scripts.editor_aura_spider_sprint.update
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
tt = RT("aura_eb_spider_path_web", "aura_mactans_path_web")
tt.steps_count = 3
tt.steps_count_auras = 2
tt.step_delay = fts(0.5)
tt.aura.duration = 5
tt.fade_duration = fts(3)
tt = RT("aura_ogre_magi_regen", "aura")

AC(tt, "regen")

tt.main_script.update = scripts.aura_unit_regen.update
tt.regen.cooldown = fts(5)
tt.regen.health = 5
tt.regen.ignore_stun = true
tt.regen.ignore_freeze = false
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
tt = RT("aura_shadow_champion_death", "aura")
tt.main_script.update = scripts.aura_shadow_champion_death.update
tt.aura.radius = 80
tt.aura.vis_flags = bor(F_MOD, F_RANGED)
tt.aura.enemy_mod = "mod_shadow_champion"
tt.aura.soldier_mod = "mod_dark_spitters"
tt.aura.include_enemies = {"enemy_shadows_spawns", "enemy_dark_spitters", "enemy_grim_devourers"}
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
tt.tween.props[3].keys = {{0, vec_2(0, -10)}, {fts(55), vec_2(30, -20)}, {fts(110), vec_2(35, -5)},
                          {fts(165), vec_2(-35, -8)}, {fts(220), vec_2(25, -20)}, {fts(275), vec_2(-30, -20)}}
tt.tween.props[3].loop = true
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].interp = "step"
tt.tween.remove = false
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
tt = E:register_t("aura_crystal_arcane_freeze", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_crystal_arcane_freeze"
tt.aura.radius = 195
tt.aura.cycles_count = 1
tt.aura.vis_bans = bor(F_BOSS, F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_MOD)
tt = E:register_t("mod_teleport_mage", "mod_teleport")
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
tt = E:register_t("mod_teleport_wild_magus", "mod_teleport_mage")
tt.fx_start = "fx_teleport_orange"
tt.fx_end = "fx_teleport_orange"
tt = E:register_t("mod_teleport_high_elven", "mod_teleport_mage")
tt.fx_start = "fx_teleport_blue"
tt.fx_end = "fx_teleport_blue"
tt = E:register_t("mod_blood_elves", "mod_blood")
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
tt = E:register_t("mod_shocking_impact", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.5

for _, n in pairs({"barrack_1", "barrack_2", "barrack_3", "blade", "forest", "drow"}) do
    tt = E:register_t("mod_moon_forged_blades_" .. n, "mod_damage")
    tt.damage_max = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_min)
    tt.damage_min = math.ceil(0.15 * E:get_template("soldier_" .. n).melee.attacks[1].damage_max)
    tt.damage_type = DAMAGE_MAGICAL
end



tt = E:register_t("mod_eldritch", "modifier")
E:add_comps(tt, "render")
tt.render.sprites[1].name = "mod_eldritch"
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.main_script.update = scripts.mod_eldritch.update
tt.modifier.remove_banned = true
tt.modifier.bans = {"mod_faerie_dragon_l0", "mod_faerie_dragon_l1", "mod_faerie_dragon_l2", "mod_arivan_freeze",
                    "mod_arivan_ultimate_freeze", "mod_crystal_arcane_freeze", "mod_crystal_unstable_teleport",
                    "mod_metropolis_portal", "mod_teleport_mage", "mod_teleport_wild_magus", "mod_teleport_high_elven",
                    "mod_teleport_faustus", "mod_pixie_teleport", "mod_teleport_scroll", "mod_teleport_ainyl",
                    "mod_twilight_avenger_last_service", "mod_lynn_ultimate", "mod_shield_ainyl"}
tt.modifier.vis_flags = bor(F_MOD, F_EAT)
tt.damage_levels = {80, 180, 260}
tt.damage_radius = 87.5
tt.damage_flags = F_RANGED
tt.damage_bans = 0
tt.damage_type = DAMAGE_MAGICAL
tt.sound_events.loop = "TowerWildMagusDoomLoop"
tt = E:register_t("eldritch_enemy_decal", "decal_tween")
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {}

for i, s in ipairs({1.06, 1.02, 1.11, 1.05, 1.14, 1.08, 1.116, 1.1, 1.18, 1.13, 1.24}) do
    tt.tween.props[1].keys[i] = {(i - 1) * fts(2), vec_2(s, s)}
end

tt = E:register_t("mod_ward", "modifier")
E:add_comps(tt, "render", "tween")
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
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "mod_ward_decal"
tt.render.sprites[2].animated = true
tt.render.sprites[2].scale = vec_2(1, 0.4)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = E:clone_c("sprite")
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



tt = E:register_t("mod_druid_sylvan_affected", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = fts(18)
tt.render.sprites[1].prefix = "mod_druid_sylvan_affected"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 2
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update

tt = E:register_t("mod_plant_poison_pumpkin_slow", "mod_slow")
tt.modifier.duration = 4
tt.slow.factor = 0.5
tt = E:register_t("mod_plant_poison_pumpkin", "mod_poison")
tt.render.sprites[1].prefix = "poison_violet"
tt.render.sprites[1].size_names = {"small", "medium", "big"}
tt.modifier.duration = 4
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.kill = true
tt.dps.damage_every = fts(3)
tt.dps.damage_type = DAMAGE_POISON

tt = E:register_t("mod_teleport_faustus", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.modifier.vis_bans = bor(F_BOSS)
tt.max_times_applied = nil
tt.nodes_offset = -35
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_faustus"
tt.fx_end = "fx_teleport_faustus"
tt.damage_base = 50
tt.damage_inc = 25

tt = E:register_t("mod_enervation_faustus", "modifier")
E:add_comps(tt, "render", "tween")
tt.main_script.insert = scripts.mod_silence.insert
tt.main_script.remove = scripts.mod_silence.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = nil
tt.render.sprites[1].prefix = "mod_enervation_faustus"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt = E:register_t("mod_liquid_fire_faustus", "modifier")

E:add_comps(tt, "dps", "render")

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
tt = E:register_t("mod_minidragon_faustus", "mod_liquid_fire_faustus")
tt = E:register_t("mod_bravebark_branchball", "modifier")

E:add_comps(tt, "render")

tt.main_script.queue = scripts.mod_bravebark_branchball.queue
tt.main_script.update = scripts.mod_bravebark_branchball.update
tt.custom_anchors = {}
tt.custom_anchors.default = vec_2(0.5, 0.45)
tt.render.sprites[1].name = "bravebark_paralyzeRoots"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].anchor.y = 0.22727272727272727
tt = E:register_t("mod_bravebark_ultimate", "mod_shock_and_awe")
tt.modifier.duration = 1
tt = E:register_t("mod_bravebark_springsap", "modifier")

E:add_comps(tt, "hps", "render", "tween")

tt.modifier.use_mod_offset = false
tt.modifier.duration = 3 * fts(3)
tt.modifier.bans = {"mod_son_of_mactans_poison", "mod_drider_poison", "mod_dark_spitters", "mod_balrog"}
tt.modifier.remove_banned = true
tt.hps.heal_min = nil
tt.hps.heal_max = nil
tt.hps.heal_every = fts(3)
tt.main_script.insert = scripts.mod_bravebark_springsap.insert
tt.main_script.update = scripts.mod_hps.update
tt.render.sprites[1].name = "bravebark_hero_healFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.1
tt.render.sprites[1].sort_y_offset = -1
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.15, 255}}

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
tt = RT("mod_soldier_catha_curse", "mod_catha_curse")
tt.xp_from_skill = nil
tt = RT("mod_catha_ultimate", "mod_catha_curse")
tt.main_script.insert = scripts.mod_stun.insert
tt.modifier.vis_bans = 0
tt.xp_from_skill = nil
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
tt = RT("mod_veznan_ultimate_stun", "mod_stun")
tt.modifier.duration = 2
tt = RT("mod_veznan_demon_fire", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(29)
tt.modifier.resets_same = true
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].draw_order = 10
tt = RT("mod_veznan_arcanenova", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5
tt = RT("mod_veznan_shackles_stun", "mod_stun")
tt.render.sprites[1].prefix = "veznan_hero_shackles"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_anchors = {vec_2(0.5, 0.7222222222222222), vec_2(0.5, 0.5483870967741935),
                                     vec_2(0.5, 0.4838709677419355)}
tt.modifier.animation_phases = true
tt.modifier.duration = 3
tt = RT("mod_veznan_shackles_dps", "modifier")

AC(tt, "dps")

tt.modifier.duration = 3
tt.dps.damage_min = 2
tt.dps.damage_max = 2
tt.dps.damage_every = fts(5)
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = RT("mod_baby_malik_stun", "mod_stun")
tt = RT("mod_rag_raggified", "modifier")
tt.main_script.update = scripts.mod_rag_raggified.update
tt.modifier.bans = {"mod_twilight_avenger_last_service"}
tt.modifier.remove_banned = true
tt.entity_name = "soldier_rag"
tt.fx = "fx_rag_raggified"
tt.doll_duration = nil
tt = RT("mod_rag_hammer_time_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = F_BOSS
tt = RT("mod_durax_slow", "mod_slow")
tt.modifier.duration = fts(15)
tt.slow.factor = 0.9
tt = RT("mod_durax_stun", "mod_stun")
tt.modifier.duration = fts(20)
tt.modifier.vis_bans = F_BOSS
tt = RT("mod_lilith_angel_stun", "mod_stun")
tt.modifier.duration = fts(34)
tt = RT("mod_lilith_soul_eater_track", "modifier")
tt.main_script.update = scripts.mod_lilith_soul_eater_track.update
tt.modifier.duration = fts(11)

tt = RT("mod_lilith_soul_eater_damage_factor", "modifier")
AC(tt, "render", "tween")
tt.inflicted_damage_factor = nil
tt.soul_eater_factor = nil
tt.modifier.duration = 12
tt.modifier.use_mod_offset = false
tt.modifier.allows_duplicates = true
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "lilith_soul_eater_decal_loop"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fallen_angel_hero_soul_eater_sword"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 12)
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].offset = vec_2(-18, 22)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset = vec_2(18, 22)
tt.tween.remove = false
tt.tween.props[1] = CC("tween_prop")
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}

for i = 2, 4 do
    tt.tween.props[i] = table.deepclone(tt.tween.props[1])
    tt.tween.props[i].sprite_id = i
end

tt.tween.props[5] = CC("tween_prop")
tt.tween.props[5].name = "anchor"
tt.tween.props[5].keys = {{0, vec_2(0.5, 0.6538461538461539)}, {fts(12), vec_2(0.5, 0.34615384615384615)},
                          {fts(24), vec_2(0.5, 0.6538461538461539)}}
tt.tween.props[5].loop = true
tt.tween.props[5].interp = "sine"
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[5])
tt.tween.props[6].sprite_id = 3
tt.tween.props[7] = table.deepclone(tt.tween.props[5])
tt.tween.props[7].sprite_id = 4

tt = RT("mod_lilith_infernal_wheel", "mod_lava")
tt.modifier.duration = fts(31)
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_inc = 0
tt.dps.damage_every = fts(10)
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
tt.xp_from_skill = "sharp_claws"
tt = RT("mod_bruce_kings_roar", "mod_stun")
tt.modifier.duration = nil
tt.modifier.vis_bans = F_BOSS
tt.modifier.health_bar_offset = vec_2(0, -3)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].prefix = "mod_bruce_kings_roar"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil
tt = RT("mod_lion_bruce_stun", "mod_stun")
tt.modifier.duration = 3
tt.modifier.animation_phases = true
tt.modifier.use_mod_offset = false
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].anchor.y = 0.0975609756097561
tt.render.sprites[1].prefix = "bruce_ultimate_twister"
tt.sound_events.insert_args = {
    ignore = 1
}
tt.sound_events.insert = {"ElvesHeroBruceGuardianLionsLoopStart", "ElvesHeroBruceGuardianLionsLoop"}
tt.sound_events.remove_stop = "ElvesHeroBruceGuardianLionsLoop"
tt.sound_events.remove = "ElvesHeroBruceGuardianLionsLoopEnd"
tt = RT("mod_lion_bruce_damage", "modifier")

AC(tt, "dps", "mark_flags")

tt.dps.damage_min = nil
tt.dps.damage_max = nil
tt.dps.damage_every = fts(10)
tt.dps.damage_type = DAMAGE_TRUE
tt.mark_flags.vis_bans = F_CUSTOM
tt.modifier.duration = 3
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue

tt = RT("mod_slow_wilbur", "mod_slow")
tt.slow.factor = nil

tt = E:register_t("mod_gnoll_burner", "modifier")

E:add_comps(tt, "dps", "render", "mark_flags")

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
tt = E:register_t("mod_gnoll_gnawer", "modifier")

E:add_comps(tt, "render")

tt.modifier.duration = fts(10)
tt.modifier.use_mod_offset = false
tt.inflicted_damage_factor = 1.5
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_gnoll_gnawer"
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("mod_gnoll_blighter", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_gnoll_blighter.update
tt.modifier.duration = 4.9
tt.render.sprites[1].name = "mod_gnoll_blighter"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.28
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 10
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {tt.modifier.duration - 0.3, 255}, {tt.modifier.duration, 0}}
tt.tween.remove = false

tt = E:register_t("mod_twilight_elf_harasser", "modifier")
E:add_comps(tt, "mark_flags")
tt.mark_flags.vis_bans = F_CUSTOM
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt.modifier.duration = fts(20)

tt = E:register_t("mod_redcap_heal", "modifier")
E:add_comps(tt, "hps")
tt.main_script.insert = scripts.mod_redcap_heal.insert
tt.main_script.update = scripts.mod_hps.update
tt.hps.heal_min = 25
tt.hps.heal_max = 25
tt.hps.heal_every = fts(3)
tt.modifier.duration = 2
tt.hit_fx = "fx_redcap_death_blow"


tt = E:register_t("mod_twilight_scourger_lash", "modifier")

E:add_comps(tt, "render")

tt.render.sprites[1].prefix = "mod_twilight_scourger_lash"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[2] = E:clone_c("sprite")
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
tt = E:register_t("mod_twilight_scourger_banshee", "modifier")

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_twilight_scourger_banshee.update
tt.modifier.hide_tower = false
tt.modifier.duration = 10
tt.render.sprites[1].name = "mod_twilight_scourger_banshee_base"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.05
tt.render.sprites[1].offset.y = -10
tt.render.sprites[2] = E:clone_c("sprite")
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
    local p = E:clone_c("tween_prop")

    p.keys = {{0, 0}, {0.2, 255}, {"this.modifier.duration-0.2", 255}, {"this.modifier.duration", 0}}
    p.sprite_id = i
    tt.tween.props[i] = p
end

tt = E:register_t("mod_spider_web", "modifier")
E:add_comps(tt, "render")
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

tt = E:register_t("mod_mactans_spider_web", "mod_spider_web")
tt.modifier.duration = 5
tt.modifier.duration_heroes = 3

tt = E:register_t("mod_twilight_evoker_silence", "modifier")
E:add_comps(tt, "render", "tween")
tt.main_script.update = scripts.mod_tower_silence.update
tt.modifier.duration = 4
tt.modifier.replaces_lower = false
tt.modifier.resets_same = false
tt.render.sprites[1].name = "mod_twilight_evoker_silence_1"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[2] = E:clone_c("sprite")
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
tt = E:register_t("mod_twilight_evoker_heal", "modifier")
E:add_comps(tt, "hps", "render")
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
tt = E:register_t("mod_twilight_heretic_consume", "modifier")

E:add_comps(tt, "render")

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
tt = E:register_t("mod_twilight_heretic_servant", "modifier")

E:add_comps(tt, "render", "dps", "tween")

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
tt = E:register_t("mod_drider_poison", "modifier")

E:add_comps(tt, "render", "dps")

tt.modifier.duration = 10
tt.modifier.vis_flags = bor(F_MOD, F_POISON)
tt.render.sprites[1].name = "mod_drider_poison"
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_drider_poison.update
tt.dps.damage_every = fts(7)
tt.dps.damage_max = 2
tt.dps.damage_min = 2
tt.dps.damage_type = DAMAGE_POISON
tt = E:register_t("mod_razorboar_rampage_enemy", "modifier")

E:add_comps(tt, "dps", "render")

tt.dps.damage_min = 125
tt.dps.damage_max = 155
tt.dps.damage_every = fts(30)
tt.modifier.duration = fts(25)
tt.modifier.use_mod_offset = true
tt.render.sprites[1].name = "mod_razorboar_rampage"
tt.render.sprites[1].anchor.y = 0.34
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t("mod_razorboar_rampage_soldier", "mod_razorboar_rampage_enemy")
tt.dps.damage_min = 80
tt.dps.damage_max = 120
tt = E:register_t("mod_razorboar_rampage_speed", "modifier")
tt.modifier.duration = 1.2
tt.speed_factor = 2.818181818181818
tt.main_script.insert = scripts.mod_razorboar_rampage_speed.insert
tt.main_script.remove = scripts.mod_razorboar_rampage_speed.remove
tt.main_script.update = scripts.mod_razorboar_rampage_speed.update
tt = E:register_t("mod_son_of_mactans_poison", "mod_poison")
tt.dps.damage_every = fts(4)
tt.dps.damage_max = 6
tt.dps.damage_min = 6
tt.dps.kill = true
tt.modifier.duration = 3
tt = RT("mod_spider_sprint", "mod_slow")
tt.slow.factor = 2
tt.modifier.duration = fts(12)
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
tt = RT("mod_screecher_bat_stun", "mod_stun")
tt.modifier.duration = 5
tt.modifier.duration_heroes = 3
tt.render.sprites[1].prefix = "mod_screecher_bat_stun"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].size_names = nil

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

tt = RT("mod_shadow_champion", "mod_gnoll_boss")
tt.main_script.insert = scripts.mod_shadow_champion.insert
tt.main_script.remove = scripts.mod_shadow_champion.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 120
tt.inflicted_damage_factor = 1.2
tt.heal_factor = 1
tt = RT("mod_balrog", "mod_dark_spitters")
tt.modifier.duration = 5 - fts(11)
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
tt.tween.props[1].keys =
    {{0, 0}, {fts(10), 255}, {"this.modifier.duration-(10/30)", 255}, {"this.modifier.duration", 0}}
tt = RT("mod_teleport_ainyl", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_scroll"
tt.fx_end = "fx_teleport_scroll"
tt = RT("mod_block_tower_ainyl", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_block_tower_ainyl.update
tt.modifier.hide_tower = false
tt.modifier.duration = 10
tt.render.sprites[1].name = "ainyl_block_decal"
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].anchor.y = 0.28125
tt.render.sprites[1].offset.y = -8
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].sort_y_offset = -2
tt.render.sprites[2].anchor = vec_2(0.9655172413793104, 0.5)
tt.render.sprites[2].offset.y = 21
tt.render.sprites[2].name = "ainyl_block_fx"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].scale = vec_2(-1, 1)
tt.render.sprites[3].time_offset = fts(6)
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].offset.y = 48
tt.render.sprites[4].hidden = true
tt.render.sprites[5] = table.deepclone(tt.render.sprites[4])
tt.render.sprites[5].scale = vec_2(-1, 1)
tt.render.sprites[5].time_offset = fts(6)
tt.tween.remove = false

for i = 1, 5 do
    local p = E:clone_c("tween_prop")

    p.keys = {{0, 0}, {0.2, 255}, {"this.modifier.duration-0.2", 255}, {"this.modifier.duration", 0}}
    p.sprite_id = i
    tt.tween.props[i] = p
end

tt = RT("mod_shield_ainyl", "modifier")
AC(tt, "render")
tt.modifier.duration = nil
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.received_damage_factor = 0.001
tt.render.sprites[1].prefix = "ainyl_shield"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].anchor.y = 0.4

tt = E:register_t("mod_pixie_teleport", "mod_teleport_mage")
E:add_comps(tt, "sound_events")
tt.max_times_applied = nil
tt.hold_time = fts(10)
tt.nodes_offset = -50
tt.fx_start = "fx_mod_pixie_teleport"
tt.fx_end = "fx_mod_pixie_teleport"
tt.sound_events.insert = "ElvesGnomeTeleport"

tt = E:register_t("mod_ray_crystal_arcane", "modifier")

E:add_comps(tt, "dps")

tt.modifier.duration = fts(16)
tt.dps.damage_every = fts(4)
tt.dps.damage_min = 150 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_max = 200 / (tt.modifier.duration / tt.dps.damage_every)
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.kill = false
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt = E:register_t("mod_crystal_arcane_freeze", "mod_freeze")

E:add_comps(tt, "render")

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
tt = E:register_t("mod_crystal_arcane_buff", "modifier")

E:add_comps(tt, "render", "tween")

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
    tt.render.sprites[i] = E:clone_c("sprite")
    tt.render.sprites[i].name = "fx_crystal_arcane_tower"
    tt.render.sprites[i].anchor.y = 0.11666666666666667
    tt.render.sprites[i].sort_y_offset = -2
    tt.render.sprites[i].offset = offsets[i]
    tt.render.sprites[i].flip_x = i >= 4
    tt.tween.props[i] = E:clone_c("tween_prop")
    tt.tween.props[i].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
    tt.tween.props[i].sprite_id = i
end

tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {0.5, vec_1(1.15)}, {1, vec_1(1)}}
tt.tween.props[1].loop = true
tt.tween.props[6] = E:clone_c("tween_prop")
tt.tween.props[6].keys = {{0, 0}, {0.3, 255}, {"this.modifier.duration-0.3", 255}, {"this.modifier.duration", 0}}
tt = E:register_t("mod_crystal_arcane_buff_soldier", "modifier")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.main_script.update = scripts.mod_track_target.update
tt.inflicted_damage_factor = 1.75
tt.modifier.duration = 5
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "decal_crystal_arcane_soldier_base"
tt.render.sprites[1].anchor.y = 0.23529411764705882
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_crystal_arcane_soldier_bubbles"
tt.render.sprites[2].anchor.y = 0.23529411764705882
tt.render.sprites[2].sort_y_offset = -1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "fx_crystal_arcane_soldier"
tt.render.sprites[3].anchor.y = 0.17647058823529413
tt.render.sprites[3].sort_y_offset = -1
tt.render.sprites[3].loop = false
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
tt = RT("mod_crystal_unstable_infuse", "mod_bloodsydian_warlock")
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
tt = RT("mactans_controller")

AC(tt, "main_script")

tt.main_script.insert = scripts.mactans_controller.insert
tt.main_script.update = scripts.mactans_controller.update
tt.sequence = nil
tt.sequence_groups = nil

tt = E:register_t("power_thunder_control")
E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")
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
tt = E:register_t("mod_power_thunder_slow", "mod_slow")
tt.modifier.duration = 0.25
tt.slow.factor = 0.4
tt = E:register_t("fx_power_thunder_1", "decal_tween")

E:add_comps(tt, "sound_events")

tt.image_h = 496
tt.render.sprites[1].name = "ray_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.tween.props[1].keys = {{0, 255}, {fts(3), 255}, {fts(8), 0}}
tt.sound_events.insert = "CommonLightning"
tt = E:register_t("fx_power_thunder_2", "fx_power_thunder_1")
tt.image_h = 456
tt.render.sprites[1].name = "ray_0002"
tt = E:register_t("fx_power_thunder_explosion", "fx")
tt.render.sprites[1].name = "fx_power_thunder_explosion_half"
tt.render.sprites[1].anchor.y = 0.15714285714285714
tt.render.sprites[1].sort_y_offset = -5
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
tt = E:register_t("fx_power_thunder_explosion_decal", "fx")
tt.render.sprites[1].name = "decal_power_thunder_explosion"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("overlay_power_thunder_flash", "decal_tween")

E:add_comps(tt, "tween")

image_y = 64
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].scale = vec_2(math.ceil(REF_H * 16 / 9 * 1.1 / image_y), math.ceil(REF_H / image_y))
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "square_b8b8b8"
tt.render.sprites[2].alpha = 0
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
tt.ts = 0
tt.cooldown = 0
tt = E:register_t("fx_power_thunder_drop", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "lightning_storm_rain_drop"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 1
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("fx_power_thunder_rain_splash", "fx")
tt.render.sprites[1].name = "fx_power_thunder_rain_splash"
-- tt = E:register_t("power_hero_control")

-- E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

-- tt.main_script.insert = scripts.power_hero_control.insert
-- tt.user_selection.can_select_point_fn = scripts.power_hero_control.can_select_point

-- E:set_template("user_power_1", E:get_template("power_thunder_control"))
-- E:set_template("user_power_2", E:get_template("power_reinforcements_control"))
-- E:set_template("user_power_3", E:get_template("power_hero_control"))

tt = RT("user_item_teleport_scroll", "user_item")

AC(tt, "aura", "render", "tween", "sound_events")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_teleport_scroll"
tt.aura.cycle_time = 1000000000
tt.aura.duration = fts(30)
tt.aura.radius = 35
tt.aura.targets_per_cycle = 10
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FREEZE)
tt.aura.targets_per_cycle = nil
tt.render.sprites[1].name = "decal_user_power_teleport"

for i, o in ipairs({vec_2(-20, 26), vec_2(-4, 36), vec_2(19, 29), vec_2(-24, -3), vec_2(-3, 6), vec_2(26, 6),
                    vec_2(-11, -15), vec_2(4, -15)}) do
    tt.render.sprites[i + 1] = CC("sprite")
    tt.render.sprites[i + 1].name = "fx_user_power_teleport_bubbles"
    tt.render.sprites[i + 1].offset = o
    tt.render.sprites[i + 1].loop = false
    tt.render.sprites[i + 1].hide_after_runs = 1
    tt.render.sprites[i + 1].scale = math.random() < 0.5 and vec_2(-1, 1) or vec_2(1, 1)
    tt.render.sprites[i + 1].anchor.y = 0.078125
end

tt.sound_events.insert = "ElvesInAppTeleportScroll"
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 55}, {fts(5), 255}, {fts(15), 255}, {fts(20), 0}, {fts(30), 0}}
tt = RT("mod_teleport_scroll", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.boss_nodes_offset = -20
tt.nodes_offset = -35
tt.nodeslimit = 10
tt.delay_start = fts(2)
tt.hold_time = 0.4
tt.delay_end = fts(2)
tt.fx_start = "fx_teleport_scroll"
tt.fx_end = "fx_teleport_scroll"
tt = RT("fx_teleport_scroll", "fx")
tt.render.sprites[1].name = "fx_user_power_teleport"
tt.render.sprites[1].size_scales = {vec_1(0.8), vec_1(1), vec_1(1.5)}
tt = RT("user_item_gem_timewarp", "user_item")

AC(tt, "aura", "sound_events")

tt.main_script.update = scripts.user_item_gem_timewarp.update
tt.aura.custom_fx = "fx_gem_timewarp_bubble"
tt.aura.mod_teleport = "mod_teleport_gem"
tt.aura.mod_slow = "mod_slow_gem"
tt.aura.duration = fts(30)
tt.aura.radius = 1e+99
tt.aura.vis_flags = bor(F_RANGED, F_TELEPORT)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_FREEZE)
tt.aura.extra_slow_duration_random = {0, 2}
tt.aura.extra_slow_duration_per_clamped_node = 0.3
tt.sound_events.insert = "ElvesInAppTeleportGemEnemiesOut"
tt = RT("mod_teleport_gem", "mod_teleport_scroll")
tt.hold_time = 0.3
tt.boss_nodes_offset = -35
tt.nodes_offset = -50
tt.nodeslimit = 0
tt = RT("mod_slow_gem", "mod_slow")
tt.modifier.duration = 10
tt.slow.factor = 0.5
tt = RT("fx_gem_timewarp_bubble", "fx")

for i, o in ipairs({vec_2(-20, 26), vec_2(-4, 36), vec_2(19, 29), vec_2(-24, -3), vec_2(-3, 6), vec_2(26, 6),
                    vec_2(-11, -15), vec_2(4, -15)}) do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].name = "fx_user_power_teleport_bubbles"
    tt.render.sprites[i].offset = o
    tt.render.sprites[i].loop = false
    tt.render.sprites[i].hide_after_runs = 1
    tt.render.sprites[i].scale = math.random() < 0.5 and vec_2(-1, 1) or vec_2(1, 1)
    tt.render.sprites[i].anchor.y = 0.078125
end

tt = RT("user_item_wrath_of_elynia", "user_item")

AC(tt, "aura", "sound_events")

tt.main_script.update = scripts.user_item_wrath_of_elynia.update
tt.aura.mod_slow = "mod_slow_elynia"
tt.aura.mod_kill = "mod_kill_elynia"
tt.aura.radius = REF_W * 1.5
tt.aura.spread_speed = 1200
tt.aura.vis_flags = bor(F_RANGED)
tt.aura.vis_bans = bor(F_FRIEND, F_HERO)
tt.sound_events.insert = "ElvesInAppTearOfElynie"
tt = RT("mod_slow_elynia", "mod_slow")
tt.modifier.duration = 10
tt.slow.factor = 0.7
tt = RT("mod_kill_elynia", "modifier")
tt.main_script.queue = scripts.mod_kill_elynia.queue
tt.main_script.update = scripts.mod_kill_elynia.update
tt.modifier.damage_boss = 3000
tt = RT("decal_elynia_ray", "decal_tween")
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "elynia_ray"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].name = "square_ffffff"
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vec_2(0.1875, 5.953125)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].anchor.y = 0.40625
tt.render.sprites[3].name = "decal_elynia_ray_hit"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(0, 1)}, {fts(4), vec_2(1, 1)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.046875, 5.953125)}, {fts(2), vec_2(0.09375, 5.953125)},
                          {fts(4), vec_2(0.046875, 5.953125)}}
tt.tween.props[2].loop = true
tt = RT("decal_elynia_big_explosion", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "elynia_explosion_ring"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "elynia_base"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "elynia_sphere"
tt.render.sprites[3].offset.y = 16
tt.render.sprites[3].z = Z_EFFECTS
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "elynia_sphere_border"
tt.render.sprites[4].offset.y = 16
tt.render.sprites[4].z = Z_EFFECTS
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].animated = false
tt.render.sprites[5].name = "elynia_boom"
tt.render.sprites[5].offset.y = 10
tt.render.sprites[5].z = Z_EFFECTS

for _, d in pairs({{vec_2(6, 12), 2}, {vec_2(-30, 36), 4}, {vec_2(13, -41), 6}, {vec_2(-31, 45), 8}}) do
    local s = CC("sprite")

    s.hide_after_runs = 1
    s.loop = false
    s.name = "fx_elynia_particle"
    s.offset.x, s.offset.y = d[1].x, d[1].y
    s.scale = vec_1(1.2)
    s.time_offset = -1 * fts(d[2])

    table.insert(tt.render.sprites, s)
end

tt.tween.remove = true
tt.tween.props = {{
    name = "alpha",
    sprite_id = 1,
    keys = {{0, 255}, {fts(17), 0}}
}, {
    name = "scale",
    sprite_id = 1,
    keys = {{0, vec_1(1)}, {fts(17), vec_1(4.7)}}
}, {
    name = "alpha",
    sprite_id = 2,
    keys = {{0, 255}, {fts(26), 0}}
}, {
    name = "alpha",
    sprite_id = 3,
    keys = {{0, 255}, {fts(22), 0}}
}, {
    name = "scale",
    sprite_id = 3,
    keys = {{0, vec_1(1)}, {fts(22), vec_1(2.1)}}
}, {
    name = "alpha",
    sprite_id = 4,
    keys = {{0, 255}, {fts(17), 255}, {fts(22), 0}}
}, {
    name = "scale",
    sprite_id = 4,
    keys = {{0, vec_1(1)}, {fts(22), vec_1(2.1)}}
}, {
    name = "alpha",
    sprite_id = 5,
    keys = {{0, 255}, {fts(16), 0}}
}, {
    name = "scale",
    sprite_id = 5,
    keys = {{0, vec_1(1)}, {fts(16), vec_1(3.5)}}
}}
tt = RT("fx_elynia_creep_explosion", "decal_tween")
tt.render.sprites[1].name = "elynia_creepExplosion_glowDecal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_wrath_of_elynia_creep_explosion"
tt.render.sprites[2].anchor.y = 0.34615384615384615
tt.render.sprites[2].loop = false
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {fts(25), 0}}
tt = RT("fx_elynia_creep_ashes", "decal_tween")
tt.render.sprites[1].name = "fx_wrath_of_elynia_creep_explosion_ashes"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.2076923076923077
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {fts(25) + 1, 255}, {fts(25) + 1.2, 0}}
tt = RT("user_item_horn_heroism", "user_item")

AC(tt, "aura", "mod_attack", "sound_events", "render", "tween")

tt.main_script.update = scripts.user_item_horn_heroism.update
tt.aura.mod = "mod_horn_heroism_soldier"
tt.aura.radius = 250
tt.aura.max_soldiers = 10
tt.aura.vis_flags = bor(F_RANGED)
tt.mod_attack.max_range = 250
tt.mod_attack.min_range = 0
tt.mod_attack.max_towers = 10
tt.mod_attack.mod = "mod_horn_heroism_tower"
tt.sound_events.insert = "ElvesInAppHornOfHeroism"
tt.sound_events.insert_args = {
    delay = fts(17)
}
tt.render.sprites[1].name = "hornOfHeroism_guy_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.1111111111111111
tt.render.sprites[2].hide_after_runs = 1
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_horn_heroism_guy_layer1"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "decal_horn_heroism_guy_layer2"
tt.tween.remove = false
tt.tween.props = {{
    name = "alpha",
    sprite_id = 1,
    keys = {{fts(12), 0}, {fts(13), 255}, {fts(29), 0}}
}, {
    name = "scale",
    sprite_id = 1,
    keys = {{fts(13), vec_1(1)}, {fts(29), vec_1(2.7)}}
}}
tt = RT("mod_horn_heroism_soldier", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 10
tt.modifier.use_mod_offset = false
tt.modifier.resets_same_tween = true
tt.immune_to = DAMAGE_BASE_TYPES
tt.inflicted_damage_factor = 2
tt.main_script.insert = scripts.mod_horn_heroism_soldier.insert
tt.main_script.remove = scripts.mod_horn_heroism_soldier.remove
tt.main_script.update = scripts.mod_track_target.update
tt.render.sprites[1].name = "mod_horn_heroism_soldier"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {10 - fts(10), 255}, {10, 0}}
tt = RT("mod_horn_heroism_tower", "modifier")

AC(tt, "render", "tween")

tt.modifier.duration = 15
tt.modifier.resets_same_tween = true
tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.main_script.update = scripts.mod_tower_factors.update
tt.damage_factor = 2
tt.render.sprites[1].name = "mod_horn_heroism_tower_left"
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[1].draw_order = 20
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].flip_x = true
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "hornOfHeroism_towerBuff_topDeco"
tt.render.sprites[3].animated = false
tt.render.sprites[3].anchor.y = 0.14285714285714285
tt.render.sprites[3].draw_order = 20
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "mod_horn_heroism_tower_flame"
tt.render.sprites[4].anchor.y = 0.14285714285714285
tt.render.sprites[4].draw_order = 20
tt.tween.props = {{
    loop = true,
    name = "alpha",
    sprite_id = {1, 2, 3, 4},
    keys = {{0, 255}, {fts(10), 200}, {fts(20), 255}}
}, {
    loop = true,
    name = "scale",
    sprite_id = {1, 2, 3, 4},
    keys = {{0, vec_1(1)}, {fts(10), vec_1(1.05)}, {fts(20), vec_1(1)}}
}, {
    name = "alpha",
    multiply = true,
    sprite_id = {1, 2, 3, 4},
    keys = {{0, 0}, {fts(10), 1}, {15 - fts(10), 1}, {15, 0}}
}}
tt = RT("user_item_rod_dragon_fire", "user_item")

AC(tt, "aura", "render", "attacks")

tt.aura.duration = 10
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].cooldown = 0.6
tt.attacks.list[1].bullet = "bullet_rod_dragon_fire"
tt.attacks.list[1].bullet_start_offset = vec_2(0, 63)
tt.attacks.list[1].node_prediction = 0.5
tt.attacks.list[1].range = 175
tt.main_script.update = scripts.user_item_rod_dragon_fire.update
tt.render.sprites[1].anchor.y = 0.058333333333333334
tt.render.sprites[1].prefix = "rod_dragon_fire"
tt.render.sprites[1].name = "start"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = 0.058333333333333334
tt.render.sprites[2].name = "rod_dragon_fire_flame"
tt.render.sprites[2].hidden = true
tt.user_selection.can_select_point_fn = scripts.user_item_rod_dragon_fire.can_select_point
tt = E:register_t("bullet_rod_dragon_fire", "fireball_arivan")
tt.bullet.damage_max = 320
tt.bullet.damage_min = 100
tt.bullet.damage_radius = 55
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bullet_rod_dragon_fire_hit"
tt.bullet.particles_name = "ps_bullet_rod_dragon_fire"
tt.idle_time = 0
tt.render.sprites[1].prefix = "bullet_rod_dragon_fire"
tt.sound_events.hit = "ElvesInAppRodDragon"
tt = RT("fx_bullet_rod_dragon_fire_hit", "fx")
tt.render.sprites[1].name = "bullet_rod_dragon_fire_explosion"
tt.render.sprites[1].anchor.y = 0.19791666666666666
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("user_item_hand_midas", "user_item")
tt.gold_bonus_factor = 1
tt.duration = 35
tt.user_selection.can_select_point_fn = scripts.user_item_hand_midas.can_select_point
tt.main_script.update = scripts.user_item_hand_midas.update
tt = E:register_t("decal_water_sparks", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt = E:register_t("decal_water_sparks_small", "decal_loop")
tt.render.sprites[1].name = "decal_water_sparks_idle"
tt.render.sprites[1].scale = vec_2(0.6, 0.6)
tt = E:register_t("decal_jumping_fish", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_fish"
tt.render.sprites[1].name = "jump"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 10
tt.delayed_play.flip_chance = 0.5
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "jump"
tt = E:register_t("decal_water_wave_delayed_2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"
tt = E:register_t("decal_water_wave_1", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_1_play"
tt = E:register_t("decal_water_wave_2", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_2_play"
tt = E:register_t("decal_water_wave_3", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_3_play"
tt = E:register_t("decal_water_wave_4", "decal_loop")
tt.render.sprites[1].name = "decal_water_wave_4_play"
tt = E:register_t("decal_water_splash", "decal_loop")
tt.render.sprites[1].name = "decal_water_splash_play"
tt = E:register_t("decal_stage01_gandalf", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_gandalf"
tt.render.sprites[1].name = "idle"
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
tt.delayed_play.idle_animation = "idle"
tt.delayed_play.play_animation = "smoke"
tt = E:register_t("decal_stage01_bird1", "decal_delayed_play")

E:add_comps(tt, "tween")

tt = E:register_t("decal_bird_1", "decal_tween")
tt.render.sprites[1].prefix = "decal_bird_1"
tt.render.sprites[1].name = "play"
tt.tween.remove = true
tt.tween.props[1].name = "offset"
tt = E:register_t("decal_bird_2", "decal_bird_1")
tt.render.sprites[1].prefix = "decal_bird_2"
tt = E:register_t("birds_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.birds_controller.update
tt.origins = {}
tt.destinations = {}
tt.bird_templates = {"decal_bird_1", "decal_bird_2"}
tt.delay = {20, 40}
tt.batch_count = 2
tt.batch_delay = {1, 5}
tt.fly_speed = 116
tt = E:register_t("decal_stage_02_waterfall_1", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_1_idle"
tt = E:register_t("decal_stage_02_waterfall_2", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_2_idle"
tt = E:register_t("decal_stage_02_waterfall_3", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_3_idle"
tt = E:register_t("decal_stage_02_waterfall_4", "decal")
tt.render.sprites[1].name = "decal_stage_02_waterfall_4_idle"
tt = E:register_t("decal_stage_02_bigwaves", "decal")
tt.render.sprites[1].name = "decal_stage_02_bigwaves_idle"

for i = 1, 6 do
    tt = E:register_t("decal_stage_02_stone_" .. i, "decal")
    tt.render.sprites[1].name = "stage2_stones_000" .. i
    tt.render.sprites[1].animated = false
end

tt = E:register_t("decal_stage_02_bridge_mask", "decal")
tt.render.sprites[1].name = "stage2_bridge"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_stage_02_bridge_shadows", "decal")
tt.render.sprites[1].name = "stage2_shadows"
tt.render.sprites[1].animated = false
tt = E:register_t("decal_bambi", "decal_scripted")

E:add_comps(tt, "ui", "motion")

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
tt = E:register_t("decal_rabbit", "decal_scripted")

E:add_comps(tt, "ui", "tween")

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
tt.ani_sequence = {{"ears", 5, 15}, {"popout", 1, 3, "hide1"}, {"travel1", 1, 3, "hide2"}, {"travel2", 1.5, 3, "hide3"},
                   {"travel3", 1, 3, "hide1"}, {"hide1"}, {nil, 10, 20}}
tt = E:register_t("decal_s03_bridge", "decal_static")

E:add_comps(tt, "ui")

tt.ui.click_rect = r(-83, -48, 166, 96)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage3_bridge"
tt.render.sprites[1].z = Z_DECALS + 2
tt.render.sprites[1].sort_y_offset = 48
tt = E:register_t("decal_crane", "decal_scripted")

E:add_comps(tt, "ui")

tt.render.sprites[1].prefix = "decal_crane"
tt.render.sprites[1].name = "idle"
tt.render.sprites[2] = E:clone_c("sprite")
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
tt = E:register_t("river_object_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.river_object_controller.update
tt.river_objects = {"barrel", "barrel", "chest", "wilson", "submarine"}
tt.min_time = 12
tt.max_time = 24
tt.max_chests = 3
tt.max_hobbits = 13
tt = E:register_t("decal_river_object", "decal_scripted")

E:add_comps(tt, "nav_path", "motion", "ui", "tween", "sound_events")

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
tt = E:register_t("decal_river_object_hobbit", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_hobbit"
tt.render.sprites[1].anchor.y = 0.2818181818181818
tt.falls = 2
tt.sink_nodes = nil
tt.achievement_inc = "DWARF_FALL"
tt.sound_events.save = "ElvesAchievementHobbit"
tt.sound_events.crash = "ElvesAchievementDwarfFall"
tt = E:register_t("decal_river_object_barrel", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_barrel"
tt.render.sprites[1].anchor.y = 0.45454545454545453
tt.sound_events.save = "ElvesWaterfallMid"
tt = E:register_t("decal_river_object_chest", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_chest"
tt.render.sprites[1].anchor.y = 0.20588235294117646
tt.gold = 20
tt.sound_events.save = "ElvesGoldCoin"
tt = E:register_t("decal_river_object_wilson", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_wilson"
tt.render.sprites[1].anchor.y = 0.1527777777777778
tt.sound_events.save = "ElvesAchievementWilson"
tt = E:register_t("decal_river_object_submarine", "decal_river_object")
tt.render.sprites[1].prefix = "decal_river_object_submarine"
tt.render.sprites[1].anchor.y = 0.20454545454545456
tt.sound_events.save = "ElvesAchievementYellowSubmarine"
tt = E:register_t("fx_waterfall_splash", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_waterfall_splash"
tt.render.sprites[1].anchor.y = 0.21875
tt.render.sprites[1].sort_y_offset = -1
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "ElvesWaterfallMid"
tt = E:register_t("decal_s04_land_1", "decal_background")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "Stage04_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = E:register_t("decal_s04_land_2", "decal_s04_land_1")
tt.render.sprites[1].name = "Stage04_0004"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt = E:register_t("decal_s04_tree_burn", "decal_timed")

E:add_comps(tt, "editor")

tt.render.sprites[1].prefix = "decal_s04_tree_burn"
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].scale = vec_2(1, 1)
tt.timed.disabled = true
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].scale", PT_COORDS}, {"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt = E:register_t("decal_s04_charcoal_1", "decal_tween")

E:add_comps(tt, "editor")

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
tt = E:register_t("decal_s04_charcoal_2", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0002"
tt = E:register_t("decal_s04_charcoal_3", "decal_s04_charcoal_1")
tt.render.sprites[1].name = "stage4_fire_decal_0003"
tt = E:register_t("decal_gnoll_burner", "decal")
tt.render.sprites[1].anchor = vec_2(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.render.sprites[1].name = "idle"
tt = E:register_t("fx_torch_gnoll_burner_explosion_stage04", "fx")
tt.render.sprites[1].name = "fx_torch_gnoll_burner_explosion_stage04"
tt = E:register_t("fx_s04_tree_fire_1", "decal_timed")

E:add_comps(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s04_tree_fire_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER},
                   {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
    ["render.sprites[1].hidden"] = false,
    ["render.sprites[1].loop"] = true
}
tt = E:register_t("fx_s04_tree_fire_2", "fx_s04_tree_fire_1")
tt.render.sprites[1].name = "fx_s04_tree_fire_2"
tt = E:register_t("decal_george_jungle", "decal_scripted")

E:add_comps(tt, "ui", "tween")

tt.main_script.update = scripts.decal_george_jungle.update
tt.render.sprites[1].anchor.y = 1
tt.render.sprites[1].prefix = "decal_george_jungle_liana"
tt.render.sprites[1].r = 50 * math.pi / 180
tt.render.sprites[1].offset = vec_2(768, 830)
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_george_jungle"
tt.render.sprites[2].name = "fall"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].offset = vec_2(566, 457)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y = 343
tt.render.sprites[3] = E:clone_c("sprite")
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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0}, {0.3}}
tt.achievement = "GEORGE_FALL"
tt = E:register_t("decal_tree_ewok", "decal_scripted")

E:add_comps(tt, "motion", "nav_path", "ranged", "unit")

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
tt = E:register_t("spear_tree_ewok", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_max = 10
tt.bullet.hit_chance = 0.4
tt.bullet.miss_decal = "ewok_2_proy_0002"
tt.bullet.flight_time = fts(33)
tt.render.sprites[1].name = "ewok_2_proy_0001"
tt.sound_events.insert = "AxeSound"
tt = E:register_t("tower_ewok_holder")

E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "editor")

tt.tower.type = "holder_ewok"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.info.i18n_key = "ELVES_EWOK_TOWER"
tt.info.fn = scripts.tower_ewok_holder.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers" or "kr3_info_portraits_towers") .. "_0013"
tt.render.sprites[1].name = "terrain_barrack_%04i"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "ewok_hut_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 32)
tt.ui.click_rect = r(-40, -10, 80, 90)



tt = E:register_t("decal_s05_tree_round", "decal")
tt.render.sprites[1].name = "stage5_tree"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.13953488372093023
tt = E:register_t("decal_s05_tree_pine", "decal")
tt.render.sprites[1].name = "stage5_pine"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt = E:register_t("decal_bush_statue", "decal_scripted")

E:add_comps(tt, "ui")

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
tt = E:register_t("fx_bush_statue_click", "fx")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "fx_bush_statue_click"
tt.render.sprites[1].offset.y = 34
tt.sound_events.insert = "ElvesAchievementScissorFingers"
tt = E:register_t("decal_s06_eagle", "decal_delayed_sequence")

E:add_comps(tt, "editor")

tt.delayed_sequence.animations = {"1", "2", "3", "4"}
tt.delayed_sequence.random = true
tt.delayed_sequence.max_delay = 3
tt.render.sprites[1].prefix = "decal_s06_eagle"
tt.render.sprites[1].name = "1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt = E:register_t("decal_s06_boxed_boss", "decal_delayed_play")

E:add_comps(tt, "editor")

tt.delayed_play.min_delay = 5
tt.delayed_play.min_delay = 10
tt.render.sprites[1].prefix = "decal_s06_boxed_boss_l1"
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_s06_boxed_boss_l2"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "decal_s06_boxed_boss_l3"
tt.render.sprites[3].z = Z_OBJECTS + 1
tt = E:register_t("decal_s06_jailed_boss", "decal")

for i = 1, 6 do
    tt.render.sprites[i] = E:clone_c("sprite")
    tt.render.sprites[i].prefix = "decal_s06_jailed_boss_l" .. i
    tt.render.sprites[i].name = "walk"
    tt.render.sprites[i].anchor.y = 0.26373626373626374
end

tt.render.sprites[6].sort_y_offset = -10
tt = E:register_t("soldier_gryphon_guard", "soldier_barrack_1")

E:add_comps(tt, "ranged")

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
tt = E:register_t("arrow_soldier_gryphon_guard", "arrow")
tt.bullet.damage_max = 10
tt.bullet.damage_min = 10
tt.bullet.flight_time = fts(12)
tt.bullet.reset_to_target_pos = true
tt = E:register_t("soldier_gryphon_guard_upper", "soldier_gryphon_guard")

E:add_comps(tt, "auras")

tt.ranged.attacks[1].filter_fn = scripts.soldier_gryphon_guard.upper_ranged_filter_fn
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_upper"
tt.auras.list[1].cooldown = 0
tt = E:register_t("soldier_gryphon_guard_lower", "soldier_gryphon_guard")

E:add_comps(tt, "auras", "tween")

tt.ranged.attacks[1].filter_fn = scripts.soldier_gryphon_guard.lower_ranged_filter_fn
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_soldier_gryphon_guard_lower"
tt.auras.list[1].cooldown = 0
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}, {0.5, 255}}
tt.render.sprites[1].alpha = 0
tt = E:register_t("aura_soldier_gryphon_guard_upper", "aura")
tt.main_script.update = scripts.aura_soldier_gryphon_guard_upper.update
tt.aura.duration = -1
tt.patch_cooldown_min = fts(20)
tt.patch_cooldown_max = fts(35)
tt = E:register_t("aura_soldier_gryphon_guard_lower", "aura")
tt.main_script.update = scripts.aura_soldier_gryphon_guard_lower.update
tt.hide_pos = vec_2(459, 563)
tt.show_pos = vec_2(440, 550)
tt.hidden_max = 3
tt.hidden_min = 1
tt.idle_time_to_hide = 5
tt = E:register_t("decal_gryphon", "decal_scripted")

E:add_comps(tt, "attacks", "ui", "sound_events")

tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].cooldown = fts(3)
tt.attacks.list[1].bullet = "bullet_gryphon"
tt.attacks.list[1].loops = 3
tt.attacks.list[1].bullet_start_offset = vec_2(102, -22)
tt.main_script.update = scripts.decal_gryphon.update
tt.render.sprites[1].prefix = "gryphon_l1"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].group = "layers"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "gryphon_l2"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].group = "layers"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "ally_gryphon_0000"
tt.render.sprites[3].alpha = 60
tt.render.sprites[4] = E:clone_c("sprite")
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
tt = E:register_t("bullet_gryphon", "bullet")
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
tt = E:register_t("fx_bolt_gryphon_hit", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_hit"
tt.render.sprites[1].anchor.y = 0.23809523809523808
tt = E:register_t("fx_bolt_gryphon_flash", "fx")
tt.render.sprites[1].name = "fx_bolt_gryphon_flash"
tt = E:register_t("decal_gryphon_sign", "decal_tween")
tt.render.sprites[1].name = "ally_gryphon_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].sort_y_offset = -110
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(4), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.75, 0.75)}, {fts(4), vec_2(1.075, 1.075)}, {fts(7), vec_2(0.96, 0.96)},
                          {fts(9), vec_2(1, 1)}}
tt = E:register_t("gryphon_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.gryphon_controller.update
tt = E:register_t("decal_obelix", "decal_delayed_click_play")
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
    tt = E:register_t("decal_wisp_" .. i, "decal")
    tt.render.sprites[1].name = string.format("decal_wisp_%i_l1", i)
    tt.render.sprites[1].random_ts = 3
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = string.format("decal_wisp_%i_l2", i)
    tt.render.sprites[2].random_ts = 3

    if i ~= 4 then
        tt.render.sprites[3] = E:clone_c("sprite")
        tt.render.sprites[3].name = string.format("decal_wisp_%i_l3", i)
        tt.render.sprites[3].random_ts = 3
    end

    if i == 2 or i == 3 then
        tt.render.sprites[3] = E:clone_c("sprite")
        tt.render.sprites[3].name = string.format("decal_wisp_%i_l4", i)
        tt.render.sprites[3].random_ts = 3
    end
end

for i = 5, 10 do
    tt = E:register_t("decal_wisp_" .. i, "decal_delayed_play")
    tt.render.sprites[1].prefix = "decal_wisp_" .. i
    tt.render.sprites[1].name = "play"
    tt.delayed_play.min_delay = 3
    tt.delayed_play.max_delay = 6
    tt.delayed_play.idle_animation = nil
end

tt = E:register_t("decal_s08_magic_bean", "decal_scripted")

E:add_comps(tt, "ui")

tt.achievement_id = "BEANS"
tt.main_script.update = scripts.decal_s08_magic_bean.update
tt.ui.click_rect = r(-25, -25, 50, 50)
tt.ui.can_select = false
tt.reward_gold = 150
tt.reward_fx = "fx_coin_jump"

for i = 1, 5 do
    tt.render.sprites[i] = E:clone_c("sprite")
    tt.render.sprites[i].prefix = "decal_s08_magic_bean_l" .. i
    tt.render.sprites[i].name = "step1"
    tt.render.sprites[i].loop = false
    tt.render.sprites[i].anchor.y = 0.1076923076923077
end

tt = E:register_t("decal_s08_peekaboo", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = scripts.decal_s08_peakaboo.update
tt.render.sprites[1].name = "out"
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.pos_list = nil
tt.sound = "ElvesPeekaboo"
tt = E:register_t("decal_s08_peekaboo_wolf", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_wolf"
tt.achievement_flag = {"PEEKABOO", 1}
tt = E:register_t("decal_s08_peekaboo_rrh", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_rrh"
tt.achievement_flag = {"PEEKABOO", 2}
tt = E:register_t("decal_s08_peekaboo_pork", "decal_s08_peekaboo")
tt.render.sprites[1].prefix = "decal_s08_peekaboo_pork"
tt.achievement_flag = {"PEEKABOO", 4}
tt = E:register_t("decal_s08_hansel_gretel", "decal_scripted")

E:add_comps(tt, "ui")

tt.main_script.update = scripts.decal_s08_hansel_gretel.update
tt.ui.click_rect = r(-70, -60, 140, 120)
tt.ui.can_select = false
tt.render.sprites[1].name = "stage10_witchHouse_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "decal_s08_hansel_gretel_door"
tt.render.sprites[2].name = "close"
tt.render.sprites[2].loop = false
tt = E:register_t("decal_s08_witch", "decal_scripted")

E:add_comps(tt, "ui", "motion")

tt.render.sprites[1].prefix = "decal_s08_witch"
tt.render.sprites[1].anchor.y = 0.07407407407407407
tt.ui.click_rect = r(-30, -25, 60, 50)
tt.ui.can_select = false
tt.motion.max_speed = 90
tt = E:register_t("decal_s08_hansel", "decal_tween")
tt.render.sprites[1].name = "decal_s08_hansel_walk"
tt.render.sprites[1].anchor.y = 0.07692307692307693
tt.render.sprites[1].draw_order = 2
tt.tween.props[1].keys = {{fts(26), 255}, {fts(37), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(47, -46)}, {fts(37), vec_2(182, -58)}}
tt = E:register_t("decal_s08_gretel", "decal_s08_hansel")
tt.render.sprites[1].name = "decal_s08_gretel_walk"
tt.tween.props[2].keys = {{0, vec_2(31, -44)}, {fts(37), vec_2(166, -56)}}
tt = E:register_t("aura_waterfall_entrance", "aura")
tt.main_script.update = scripts.aura_waterfall_entrance.update
tt.waterfall_nodes = nil
tt.show_fx = "fx_waterfall_splash"
tt = E:register_t("decal_s09_land_3", "decal_background")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "Stage09_0002"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.editor.game_mode = 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(9), 255}, {fts(18), 0}}
tt = E:register_t("decal_s09_land_2", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0003"
tt = E:register_t("decal_s09_land_1", "decal_s09_land_3")
tt.render.sprites[1].name = "Stage09_0004"
tt = E:register_t("decal_s09_crystal_1", "decal_timed")

E:add_comps(tt, "editor")

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
tt = E:register_t("decal_s09_crystal_2", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_2"
tt.debris_pos = vec_2(9, 4)
tt = E:register_t("decal_s09_crystal_3", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_3"
tt.debris_pos = vec_2(9, -5)
tt = E:register_t("decal_s09_crystal_4", "decal_s09_crystal_1")
tt.render.sprites[1].prefix = "decal_s09_crystal_4"
tt.debris_pos = vec_2(-6, 6)
tt = E:register_t("decal_s09_crystal_debris", "decal_tween")
tt.render.sprites[1].name = "decal_s09_crystal_debris_1"
tt.render.sprites[1].loop = false
tt.render.sprites[1].offset = vec_2(16, 12)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].loop = false
tt.render.sprites[2].name = "decal_s09_crystal_debris_1"
tt.render.sprites[2].flip_x = true
tt.render.sprites[2].offset = vec_2(-14, 9)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].loop = false
tt.render.sprites[3].name = "decal_s09_crystal_debris_2"
tt.render.sprites[3].offset = vec_2(2, 42)
tt.render.sprites[3].time_offset = fts(-2)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].loop = false
tt.render.sprites[4].name = "decal_s09_crystal_debris_2"
tt.render.sprites[4].flip_x = true
tt.render.sprites[4].offset = vec_2(-32, 46)
tt.render.sprites[4].time_offset = fts(-2)
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "stage9_crystals_smoke"
tt.render.sprites[5].animated = false
tt.render.sprites[5].offset = vec_2(0, 30)
tt.tween.props[1].sprite_id = {1, 2, 3, 4}
tt.tween.props[1].keys = {{fts(27), 255}, {fts(35), 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = 5
tt.tween.props[2].keys = {{0, 0}, {fts(1), 255}, {fts(8), 255}, {fts(16), 0}}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].sprite_id = 5
tt.tween.props[3].keys = {{0, vec_2(0.3, 0.3)}, {fts(16), vec_2(1.03, 1.03)}}
tt = E:register_t("decal_s09_crystal_debris_mod", "decal_s09_crystal_debris")
tt.render.sprites[3].sort_y_offset = 1
tt.render.sprites[4].sort_y_offset = 1
tt = E:register_t("decal_s09_crystal_serpent_back", "decal_tween")

E:add_comps(tt, "sound_events")

tt.render.sprites[1].name = "crystal_serpent_appear"
tt.render.sprites[1].loop = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(80), vec_2(0, 0)}, {fts(114), vec_2(0, 0)}}
tt.sound_events.insert = "ElvesCrystalSerpentPassby"
tt = E:register_t("decal_s09_crystal_serpent_attack", "decal_scripted")
tt.render.sprites[1].prefix = "crystal_serpent"
tt.main_script.update = scripts.decal_s09_crystal_serpent_attack.update
tt = E:register_t("decal_s09_crystal_serpent_scream", "decal_s09_crystal_serpent_attack")
tt.main_script.update = scripts.decal_s09_crystal_serpent_scream.update
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].hidden = true
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].hidden = true
tt = E:register_t("bullet_crystal_serpent", "bullet")
tt.render.sprites[1].hidden = true
tt.bullet.mod = "mod_crystal_serpent"
tt.bullet.flight_time = fts(17)
tt.bullet.particles_name = "ps_bullet_crystal_serpent_fly"
tt.main_script.update = scripts.bullet_crystal_serpent.update
tt = E:register_t("mod_crystal_serpent", "modifier")

E:add_comps(tt, "render")

tt.main_script.update = scripts.mod_tower_block.update
tt.modifier.hide_tower = false
tt.modifier.duration = 7
tt.render.sprites[1].anchor.y = 0.234375
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "crystal_serpent_block_tower"
tt = E:register_t("ps_bullet_crystal_serpent_fly")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("ps_bullet_crystal_serpent_hit")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("decal_s09_waterfall", "decal_scripted")
tt.render.sprites[1].name = "decal_s09_waterfall_lines1"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "decal_s09_waterfall_lines2"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "decal_s09_waterfall_top"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "decal_s09_waterfall_bottom"
tt = E:register_t("decal_crystal_water_waves2", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_water_wave_2"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 3
tt.delayed_play.idle_animation = nil
tt.delayed_play.play_animation = "play"


tt = E:register_t("decal_faerie_dragon_freeze_enemy", "decal_freeze_enemy")
tt.shader_args = {
    tint_color = {0.9725490196078431, 0.6627450980392157, 0.9882352941176471, 1}
}
tt = E:register_t("decal_s10_gnome", "decal_scripted")

E:add_comps(tt, "ui")

tt.ui.click_rect = r(-23, -19, 46, 38)
tt.ui.can_select = false
tt.render.sprites[1].prefix = "decal_s10_gnome"
tt.render.sprites[1].anchor.y = 0.23684210526315788
tt.main_script.update = scripts.decal_s10_gnome.update
tt.min_delay = 5
tt.max_delay = 20
tt.gnome_actions = {"guitar", "diamond", "sleep", "teleport", "flip"}
tt = E:register_t("decal_s10_gnome_walking", "decal_s10_gnome")
tt.walk_points = nil
tt.walk_time = 1.5

table.insert(tt.gnome_actions, "walk")

tt = E:register_t("decal_faerie_crystal", "decal_scripted")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "fairy_crystals_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 0
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_crystals_0001"
tt.render.sprites[2].alpha = 255
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "faerie_grove_crystal_fx"
tt.render.sprites[3].name = "yellow"
tt.render.sprites[3].loop = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].hide_after_runs = 1
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(0), 0}, {fts(10), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{fts(0), 255}, {fts(10), 0}}
tt.tween.props[2].sprite_id = 2
tt.main_script.update = scripts.decal_faerie_crystal.update
tt = E:register_t("faerie_trails")

E:add_comps(tt, "main_script")

tt.main_script.insert = scripts.faerie_trails.insert
tt.main_script.update = scripts.faerie_trails.update
tt.path_speeds = {
    [0] = 1 * FPS,
    2.5 * FPS
}
tt.path_speed_per_wave = nil
tt = E:register_t("nav_faerie")

E:add_comps(tt, "pos", "render", "nav_path", "motion", "main_script", "tween")

tt.main_script.update = scripts.nav_faerie.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "fairy_energyBall_red_0016"
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "fairy_energyBall_yellow_0016"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "nav_faerie_red"
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "nav_faerie_yellow"
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(10), vec_1(0.8)}, {fts(20), vec_1(1)}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt = E:register_t("simon_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.simon_controller.update
tt.initial_sequence_length = 4
tt.reward_base = 25
tt.reward_inc = 15
tt.achievement_id = "SIMON"
tt.achievement_count = 9
tt = E:register_t("simon_mushroom_1", "decal_tween")

E:add_comps(tt, "ui", "sound_events")

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
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}}
tt.tween.props[2].sprite_id = 3
tt.tween.remove = false
tt.sound_events.touch = "ElvesSimonYellow"
tt = E:register_t("simon_mushroom_2", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus2_0001"
tt.render.sprites[2].name = "stage8_symon_fungus2_0002"
tt.render.sprites[3].name = "stage8_symon_fungus2_0003"
tt.sound_events.touch = "ElvesSimonGreen"
tt = E:register_t("simon_mushroom_3", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus3_0001"
tt.render.sprites[2].name = "stage8_symon_fungus3_0002"
tt.render.sprites[3].name = "stage8_symon_fungus3_0003"
tt.sound_events.touch = "ElvesSimonRed"
tt = E:register_t("simon_mushroom_4", "simon_mushroom_1")
tt.render.sprites[1].name = "stage8_symon_fungus4_0001"
tt.render.sprites[2].name = "stage8_symon_fungus4_0002"
tt.render.sprites[3].name = "stage8_symon_fungus4_0003"
tt.sound_events.touch = "ElvesSimonBlue"
tt = E:register_t("simon_gnome_mushrooom_glow", "decal_tween")

E:add_comps(tt, "ui")

tt.ui.can_select = false
tt.ui.click_rect = r(-20, -20, 40, 50)
tt.render.sprites[1].name = "stage8_symon_bigGlow"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}}
tt.tween.remove = false
tt = E:register_t("simon_gnome", "decal")
tt.render.sprites[1].prefix = "simon_gnome"
tt.render.sprites[1].sort_y_offset = -38
tt = E:register_t("simon_gnome_fx", "fx")
tt.render.sprites[1].name = "simon_gnome_fx"
tt = E:register_t("simon_gnome_sign", "fx")
tt.render.sprites[1].name = "simon_gnome_sign"
tt.render.sprites[1].offset = vec_2(30, 15)


tt = E:register_t("decal_pixie", "decal_scripted")
E:add_comps(tt, "idle_flip", "soldier", "unit")
tt.idle_flip.animations = {"idle", "scratch"}
tt.idle_flip.cooldown = fts(90)
tt.idle_flip.loop = false
tt.main_script.update = scripts.decal_pixie.update
tt.render.sprites[1].prefix = "decal_pixie"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09090909090909091
tt.soldier.melee_slot_offset = vec_2(0, 0)
tt.attack_ts = 0
tt.target_id = nil
tt.attack = nil
tt.attack_level = nil

tt = E:register_t("decal_drow_queen_portal", "decal_scripted")
E:add_comps(tt, "editor", "tween")
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
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].sprite_id = 4
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_1(1)}, {fts(23), vec_1(1.2)}}
tt.tween.props[4].loop = true
tt.tween.props[4].ignore_reverse = true
tt.pack_pi = nil
tt.pack = nil
tt.pack_finished = nil
tt = E:register_t("fx_drow_queen_portal", "fx")
tt.render.sprites[1].name = "fx_drow_queen_portal"
tt.render.sprites[1].anchor.y = 0.22
tt = E:register_t("decal_s11_door_glow", "decal_tween")

E:add_comps(tt, "editor")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage11_doorGlow"
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -30
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 100}, {0.3, 200}, {0.6, 130}, {0.9, 255}, {1.2, 100}}
tt.tween.props[1].loop = true
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {0.5, 1}, {4.8, 1}, {6, 0}}
tt.tween.props[2].multiply = true
tt.editor.tag = 1
tt.editor.props = {{"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
    ["render.sprites[1].alpha"] = 255
}
tt = E:register_t("decal_s11_zealot_rune", "decal_tween")

E:add_comps(tt, "editor")

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
tt = E:register_t("decal_s11_mactans", "decal")
tt.render.sprites[1].prefix = "mactans"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.drop_duration = 4
tt.retreat_duration = 4
tt.netting_duration = 2.6
tt = E:register_t("decal_mactans_thread", "decal")

for i = 1, math.ceil(48) do
    local s = E:clone_c("sprite")

    s.name = i % 2 == 0 and "mactans_particles_0010" or "mactans_particles_0010"
    s.animated = false
    s.anchor.y = 0
    s.offset.y = i * 16 + 60
    s.flip_x = math.random() < 0.5
    s.z = Z_OBJECTS_SKY
    tt.render.sprites[i] = s
end

tt = E:register_t("decal_mactans_shadow", "decal_tween")
tt.render.sprites[1].name = "mactans_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {4, 255}}
tt = E:register_t("decal_mactans_webbing", "decal")
tt.render.sprites[1].name = "mactans_decal1"
tt.render.sprites[1].time_offset = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "mactans_decal2"
tt.render.sprites[3] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[3].name = "mactans_decal3"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[4].name = "mactans_decal4"
tt = E:register_t("decal_s11_drow_queen_cocoon", "decal")
tt.render.sprites[1].prefix = "s11_malicia"
tt.render.sprites[1].name = "spiderNet"
tt.render.sprites[1].loop = false
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].offset = vec_2(-8, 15)
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].z = Z_OBJECTS_SKY - 1
tt = E:register_t("decal_metropolis_floating_rock", "decal_tween")
tt.render.sprites[1].animated = false
tt.tween.random_ts = fts(80)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 1)}, {fts(20), vec_2(0, 2)}, {fts(40), vec_2(0, 1)}, {fts(60), vec_2(0, 0)},
                          {fts(80), vec_2(0, 1)}}
tt.tween.props[1].loop = true
tt = E:register_t("decal_s12_lemur", "decal_scripted")

E:add_comps(tt, "nav_path", "motion", "tween", "ui")

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
tt = E:register_t("birds_formation_controller")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.birds_formation_controller.update
tt.wait_time = {20, 60}
tt.bird_template = "decal_bird_formation"
tt = E:register_t("decal_bird_formation", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "offset"
tt.render.sprites[1].z = Z_OBJECTS_SKY
tt = E:register_t("decal_metropolis_portal", "decal_scripted")

E:add_comps(tt, "tween", "editor")

tt.main_script.update = scripts.decal_metropolis_portal.update
tt.render.sprites[1].prefix = "decal_metropolis_portal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
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
    tt.tween.props[i] = E:clone_c("tween_prop")
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
tt = E:register_t("aura_metropolis_portal", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_metropolis_portal"
tt.aura.cycle_time = fts(1)
tt.aura.radius = 35
tt.aura.vis_bans = bor(F_FRIEND, F_BOSS)
tt.aura.vis_flags = bor(F_TELEPORT)
tt = E:register_t("mod_metropolis_portal", "mod_teleport")
tt.modifier.vis_flags = bor(F_MOD, F_TELEPORT)
tt.max_times_applied = nil
tt.jump_connection = true
tt.delay_start = fts(2)
tt.hold_time = 0
tt.fx_start = "fx_teleport_metropolis"
tt.fx_end = "fx_teleport_metropolis"
tt = E:register_t("fx_teleport_metropolis", "fx")
tt.render.sprites[1].name = "fx_teleport_metropolis"
tt.render.sprites[1].size_scales = {vec_1(0.83), vec_1(1), vec_1(1.5)}
tt = E:register_t("decal_s13_relic_book", "decal_delayed_click_play")

E:add_comps(tt, "tween")

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
tt = E:register_t("decal_s13_relic_broom", "decal_click_play")
tt.render.sprites[1].prefix = "decal_s13_relic_broom"
tt.ui.click_rect = r(24, 0, 40, 50)
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 2}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeBroom"
tt = E:register_t("decal_s13_relic_hat", "decal_click_play")

E:add_comps(tt, "tween")

tt.render.sprites[1].prefix = "decal_s13_relic_hat"
tt.ui.click_rect = r(-20, -40, 40, 30)
tt.tween.remove = false
tt.tween.props[1].loop = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(20), vec_2(0, 1)}, {fts(60), vec_2(0, -1)}, {fts(80), vec_2(0, 0)}}
tt.click_play.achievement_flag = {"SORCERERS_APPRENTICE", 4}
tt.click_play.play_once = true
tt.click_play.clicked_sound = "ElvesAchievementSorcapprenticeHat"
tt = E:register_t("tower_black_baby_dragon", "tower")

E:add_comps(tt, "attacks", "user_selection")

tt.tower.type = "baby_black_dragon"
tt.tower.can_be_mod = false
tt.tower.can_hover = false
tt.tower.terrain_style = nil
tt.info.i18n_key = "ELVES_BABY_BERESAD"
tt.info.fn = scripts.tower_black_baby_dragon.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "kr3_info_portraits_towers_") .. "0015"
tt.main_script.update = scripts.tower_black_baby_dragon.update
tt.attacks.list[1] = E:clone_c("custom_attack")
tt.attacks.list[1].price = 100
tt.render = nil
tt.user_selection.ignore_point = true
tt = E:register_t("decal_black_baby_dragon", "decal_scripted")

E:add_comps(tt, "motion", "attacks", "tween", "sound_events", "nav_path")

tt.main_script.update = scripts.decal_black_baby_dragon.update
tt.motion.max_speed = 10 * FPS
tt.attacks.list[1] = E:clone_c("aura_attack")
tt.attacks.list[1].cooldown = 0.2
tt.attacks.list[1].range = 30
tt.attacks.list[1].aura = "aura_black_baby_dragon"
tt.render.sprites[1].prefix = "babyBeresad"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].anchor.y = 0.10227272727272728
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "babyBeresad"
tt.render.sprites[2].name = "zzz"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loope = false
tt.render.sprites[2].anchor.y = 0.10227272727272728
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "Stage12_Dragon_Shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].draw_order = -1
tt.render.sprites[4] = E:clone_c("sprite")
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
tt = E:register_t("aura_black_baby_dragon", "aura")

E:add_comps(tt, "render", "tween")

tt.aura.duration = 5
tt.aura.mod = "mod_black_baby_dragon"
tt.aura.radius = 50
tt.aura.cycle_time = fts(6)
tt.aura.vis_bans = bor(F_FRIEND)
tt.render.sprites[1].name = "babyBeresad_fireDecal_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "aura_baby_beresad_fire"
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {"this.aura.duration-0.7", 255}, {"this.aura.duration", 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("mod_black_baby_dragon", "mod_lava")
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
tt = E:register_t("ps_baby_black_dragon_flame")

E:add_comps(tt, "pos", "particle_system")

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
tt = E:register_t("fx_baby_black_dragon_flame_hit", "decal_tween")
tt.render.sprites[1].name = "baby_beresad_flame_hit"
tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}
tt = E:register_t("tower_holder_baby_ashbite", "tower")
E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "tween")
tt.tower.level = 1
tt.tower.type = "holder_baby_ashbite"
tt.tower.can_be_mod = false
tt.info.fn = scripts.tower_baby_ashbite.get_info
tt.info.portrait = (IS_PHONE and "portraits_towers_" or "kr3_info_portraits_towers_") .. "0019"
tt.info.i18n_key = "ELVES_BABY_ASHBITE_TOWER"
tt.info.damage_icon = "fireball"
tt.render.sprites[1].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(0, 26)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].hover_off_hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "babyAshbite_tower_layer1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = vec_2(0, 26)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "babyAshbite_tower_layer2_0001"
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = vec_2(0, 26)
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "babyAshbite_tower_layer2_0004"
tt.render.sprites[4].animated = false
tt.render.sprites[4].offset = vec_2(0, 26)
tt.ui.click_rect = r(-40, -10, 80, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true


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
tt = RT("decal_s14_break_spider", "decal_scripted")

AC(tt, "tween")

tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].name = "decal_s14_break_spider"
tt.tween.props[1].keys = {{0, 255}, {0.75, 255}, {1, 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {2, vec_2(1, 1)}}
tt = RT("decal_s15_mactans", "decal_scripted")

AC(tt, "editor")

tt.render.sprites[1].prefix = "stage15_mactans_l1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.09047619047619047
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].prefix = "stage15_mactans_l2"
tt.main_script.update = scripts.decal_s15_mactans.update
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
tt = RT("decal_s15_statue", "decal_scripted")

AC(tt, "editor")

tt.main_script.update = scripts.decal_s15_statue.update
tt.render.sprites[1].prefix = "stage15_shield"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.20161290322580644
tt = RT("decal_s15_crystal", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_crystal"
tt.render.sprites[1].animated = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 2)}, {fts(25), vec_2(0, -2)}, {fts(50), vec_2(0, 2)}}
tt.tween.props[1].loop = true
tt.tween.props[1].interp = "sine"
tt = RT("fx_s15_crystal_shine", "fx")
tt.render.sprites[1].name = "stage15_crystal_fx"
tt = RT("fx_s15_crystal_transformation", "fx")

for i = 1, 4 do
    tt.render.sprites[i] = CC("sprite")
    tt.render.sprites[i].prefix = "stage15_crystal_l" .. i
    tt.render.sprites[i].name = "explosion"
end

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
tt = RT("decal_s15_finished_gem", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage15_bossDecal_gem"
tt.render.sprites[1].anchor.y = 0.22580645161290322
tt.render.sprites[1].animated = false
tt = RT("decal_s15_finished_veznan", "decal_delayed_play")

AC(tt, "editor")

tt.render.sprites[1].prefix = "decal_s15_finished_veznan"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 0.1111111111111111
tt.delayed_play.min_delay = 5
tt.delayed_play.max_delay = 15
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
tt = RT("decal_s15_finished_guard_flipped", "decal_s15_finished_guard")

for i = 1, 4 do
    tt.render.sprites[i].flip_x = true
    tt.render.sprites[i].hidden = i == 3
end

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
tt = RT("decal_s15_mactans_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[1].name = "stage15_taunts_0004"
tt.render.sprites[2].name = "stage15_taunts_0005"
tt.texts.list[1].font_size = 28
tt.texts.list[1].color = {247, 133, 102}
tt = RT("decal_s15_malicia_shoutbox", "decal_eb_spider_shoutbox")
tt.render.sprites[2].name = "stage15_taunts_0002"
tt.texts.list[1].font_size = 28
tt = RT("decal_hr_crystal_skull", "decal_delayed_click_play")
tt.render.sprites[1].prefix = "decal_hr_crystal_skull"
tt.delayed_play.play_once = true
tt.delayed_play.required_clicks = 1
tt.delayed_play.click_interrupts = true
tt.delayed_play.clicked_sound = "ElvesCrystalSkull"
tt.ui.can_select = false
tt.ui.click_rect = r(-13, -13, 28, 24)
tt = RT("decal_s16_land_1", "decal_background")

AC(tt, "tween")

tt.render.sprites[1].name = "Stage16_0003"
tt.render.sprites[1].z = Z_DECALS + 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = RT("decal_s16_land_2", "decal_s16_land_1")
tt.render.sprites[1].name = "Stage04_0002"
tt.render.sprites[1].z = Z_DECALS - 1
tt = RT("decal_s16_ground_archers_land", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "groundArchers"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.render.sprites[1].z = Z_DECALS - 1
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = RT("soldier_s16_ground_archer", "soldier_gryphon_guard_upper")

AC(tt, "editor")

tt.ranged.attacks[1].filter_fn = nil
tt.render.sprites[1].prefix = "soldier_s16_ground_archer"
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 30
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_s16_bush_holder", "decal_tween")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushHolders"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2857142857142857
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.26, 0}}
tt = RT("decal_s16_bush_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage16_bushGnollBurner"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.2777777777777778
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"editor.game_mode", PT_NUMBER}, {"editor.tag", PT_NUMBER}}
tt = RT("fx_s16_bush_burner", "fx")
tt.render.sprites[1].name = "fx_s16_bush_burner"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt = E:register_t("fx_s16_burner_explosion", "decal_timed")

E:add_comps(tt, "editor")

tt.timed.disabled = true
tt.render.sprites[1].name = "fx_s16_burner_explosion"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].anchor.y = 0.09740259740259741
tt.editor.game_mode = 1
tt.editor.tag = 1
tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"editor.game_mode", PT_NUMBER},
                   {"editor.tag", PT_NUMBER}}
tt.editor.overrides = {
    ["render.sprites[1].hidden"] = false,
    ["render.sprites[1].loop"] = true
}
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
tt = RT("decal_hr_cart", "decal")
tt.render.sprites[1].name = "stage17_carret"
tt.render.sprites[1].anchor.y = 0.08333333333333333
tt.render.sprites[1].animated = false
tt = RT("decal_hr_worker_a", "decal")
tt.render.sprites[1].name = "decal_hr_worker_a"
tt.render.sprites[1].anchor.y = 0.027777777777777776
tt = RT("decal_hr_worker_b", "decal")
tt.render.sprites[1].name = "decal_hr_worker_b"
tt.render.sprites[1].anchor.y = 0.20833333333333334
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
tt = RT("decal_gnoll_gnawer", "decal_scripted")
AC(tt, "motion", "nav_grid", "motion", "tween")
tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].prefix = "gnoll_gnawer"
tt.render.sprites[1].name = "idle"
tt.motion.max_speed = 2 * FPS
tt.main_script.update = scripts.decal_walking.update
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {1, 0}}

tt = RT("decal_baby_malik_slave", "decal_scripted")
AC(tt, "motion", "nav_grid", "motion")
tt.render.sprites[1].anchor.y = 0.184
tt.render.sprites[1].prefix = "decal_baby_malik"
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.decal_walking.update
tt.motion.max_speed = 2 * FPS
tt.main_script.update = scripts.decal_walking.update

tt = RT("decal_baby_malik_slave_banner", "decal_tween")
tt.render.sprites[1].name = "malikAfro_sign"
tt.render.sprites[1].animated = false
tt.render.sprites[1].offset = vec_2(30, 66)
tt.tween.ts = -10
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 100}, {fts(4), 255}, {fts(71), 255}, {fts(75), 0}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(0.75)}, {fts(4), vec_1(1.075)}, {fts(7), vec_1(0.9625)}, {fts(9), vec_1(1)},
                          {fts(69), vec_1(1)}, {fts(71), vec_1(1.075)}, {fts(75), vec_1(0.75)}}
tt = RT("decal_baby_malik_slave_free", "decal")
tt.render.sprites[1].name = "decal_baby_malik_free"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0.33101851851851855, 0.27976190476190477)
tt = RT("decal_s18_statue", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage18_statue"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.176056338028169
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
tt = RT("fx_roadruner_bush_explode", "fx")
tt.render.sprites[1].name = "gnollBush_explode"
tt.render.sprites[1].anchor.y = 0.3548387096774194
tt = RT("decal_s18_roadrunner", "decal_tween")

AC(tt, "sound_events")

tt.render.sprites[1].name = "decal_s18_roadrunner_run"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.125
tt.pos = vec_2(464, 473)
tt.sound_events.insert = "ElvesRoadRunner"
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {2.2, vec_2(-369, 14)}}
tt = RT("decal_s18_coyote", "decal")

AC(tt, "sound_events")

tt.render.sprites[1].prefix = "decal_s18_coyote"
tt.render.sprites[1].name = "pull"
tt.render.sprites[1].anchor.y = 0.19230769230769232
tt.pos = vec_2(138, 383)
tt.sound_events.push = "BombExplosionSound"
tt = RT("decal_s18_flag_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s18_flag_head"
tt = RT("decal_s18_boss_head", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "stage_18_head"
tt.render.sprites[1].animated = false
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
tt = E:register_t("decal_s18_shoutbox", "decal_tween")

E:add_comps(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "theBeheader_taunt"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
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
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].name = "scale"
tt.tween.props[3].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[3].sprite_id = 1
tt.tween.props[3].loop = true
tt.tween.props[4] = table.deepclone(tt.tween.props[3])
tt.tween.props[4].sprite_id = 2
tt.tween.remove = true
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
tt = RT("decal_s19_drizzt_gnoll", "decal_scripted")
tt.render.sprites[1].prefix = "decal_s19_drizzt_gnoll"
tt.render.sprites[1].name = "idle"
tt.main_script.update = scripts.decal_s19_drizzt_gnoll.update
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
tt = RT("decal_s22_lava_hole", "decal_delayed_play")
tt.render.sprites[1].prefix = "decal_s22_lava_hole"
tt.render.sprites[1].name = "play"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].scale = vec_1(1)
tt.delayed_play.min_delay = 1
tt.delayed_play.max_delay = 2
tt.delayed_play.idle_animation = nil
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
tt = RT("lava_fireball_controller")

AC(tt, "main_script")

tt.main_script.update = scripts.lava_fireball_controller.update
tt.bullet = "bomb_lava_fireball"
tt.launch_fx = "fx_bomb_lava_fireball_launch"
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
tt = RT("fx_bomb_lava_fireball_launch", "fx")
tt.render.sprites[1].name = "fx_bomb_lava_fireball_launch"
tt = RT("fx_bomb_lava_fireball_explosion", "fx")
tt.render.sprites[1].name = "fireball_explosion"
tt.render.sprites[1].anchor.y = 0.15
tt.render.sprites[1].z = Z_OBJECTS
tt = RT("decal_stage81_burner", "decal")

AC(tt, "editor")

tt.render.sprites[1].name = "decal_s81_burner"
tt = E:register_t("decal_endless_shoutbox", "decal_s18_shoutbox")
tt.render.sprites[1].name = "hee-haw_taunt"
tt.texts.list[1].color = {233, 189, 255}
tt.texts.list[1].size = vec_2(180, 58)
tt.texts.list[1].font_size = 20

tt = E:register_t("decal_regson_heal_ball", "decal_scripted")
E:add_comps(tt, "force_motion")
tt.render.sprites[1].name = "regson_heal_ball_travel"
tt.render.sprites[1].offset.y = 10
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
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

tt = E:register_t("fx_regson_heal_ball_spawn", "fx")
tt.render.sprites[1].name = "fx_regson_heal_ball_spawn"
tt.render.sprites[1].anchor.y = 0.35

tt = E:register_t("fx_regson_heal", "fx")
tt.render.sprites[1].name = "fx_regson_heal"
tt.render.sprites[1].sort_y_offset = -1


tt = E:register_t("decal_alric_soul_ball", "decal_regson_heal_ball")
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


tt = E:register_t("fx_alric_soul_ball_spawn", "fx_regson_heal_ball_spawn")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200

tt = E:register_t("fx_alric_receive_soul", "fx_regson_heal")
tt.render.sprites[1].color = {255, 122, 0}
tt.render.sprites[1].scale = vec_1(0.9)
tt.render.sprites[1].alpha = 200

-- kr5

tt = E:register_t("ps_hero_hunter_walk_trail")

E:add_comps(tt, "pos", "particle_system")

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

tt = E:register_t("fx_hero_hunter_skill_heal_strike_hit", "fx")
tt.render.sprites[1].name = "mistystep_hit_run"
tt = E:register_t("fx_hero_hunter_ranged_attack", "fx")
tt.render.sprites[1].name = "shothit_run"
tt = E:register_t("fx_hero_hunter_skill_ricochet_hit", "fx")
tt.render.sprites[1].name = "mistystep_hit_run"
tt = E:register_t("fx_hero_hunter_skill_shoot_around_decal", "fx")
tt.render.sprites[1].name = "argent_storm_decal_run"
tt = E:register_t("fx_hero_hunter_ultimate_hit", "fx")
tt.render.sprites[1].name = "hit_dante_run"
tt = E:register_t("fx_hero_hunter_steal", "fx")
tt.render.sprites[1].name = "duskbeast_coin_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS

tt = E:register_t("ps_hero_space_elf_basic_attack_trail")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_therien_ranged_particle_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 30
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.anchor = vec_2(0.5, 0.5)
tt.particle_system.emit_area_spread = vec_2(5, 5)

tt = E:register_t("fx_hero_space_elf_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_therien_ranged_hit_idle"

tt = E:register_t("fx_hero_space_elf_melee_hit", "fx")
tt.render.sprites[1].name = "hero_therien_melee_hit_idle"

tt = E:register_t("fx_hero_space_elf_astral_reflection_spawn", "fx")
tt.render.sprites[1].name = "hero_therien_reflection_spawn_fx_idle"

tt = E:register_t("fx_hero_space_elf_black_aegis_hit", "fx")
tt.render.sprites[1].name = "hero_therien_black_aegis_hit"

tt = E:register_t("decal_hero_space_elf_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_therien_void_prison_floor_fx_idle"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = true
tt = E:register_t("decal_hero_space_elf_ultimate_mod", "decal_tween")
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.13, 0}}
tt = E:register_t("decal_hero_space_elf_void_rift_therien", "decal_tween")
tt.render.sprites[1].name = "hero_therien_rift_therien_fx_idle"
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = true
tt.tween.disabled = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {1.5, 255}, {1.8, 0}}
tt.tween.remove = true

tt = E:register_t("hero_raelyn_command_orders_hit_fx", "fx")
tt.render.sprites[1].name = "hero_raelyn_command_orders_hit_fx_Idle1_1"
tt = E:register_t("hero_raelyn_ultimate_entity_spawn_mod_decal", "modifier")
E:add_comps(tt, "render")
tt.modifier.duration = fts(21)
tt.render.sprites[1].name = "hero_raelyn_command_orders_spawn_fx_Idle1_1"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].loop = false
tt.modifier.use_mod_offset = false
tt.main_script.update = scripts.mod_track_target.update
tt = E:register_t("decal_hero_raelyn_onslaught_decal", "decal_tween")
tt.render.sprites[1].name = "hero_raelyn_onslaught_fx_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].hide_after_runs = 1
tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}

tt = E:register_t("fx_hero_venom_melee_attack_hit", "fx5")
tt.render.sprites[1].name = "hero_venom_hit_fx_idle"
tt.render.sprites[1].z = Z_BULLETS + 1
tt = E:register_t("fx_hero_venom_beast_lvl_up", "fx5")
tt.render.sprites[1].name = "hero_venom_levelup_fx_idle"

tt = E:register_t("decal_hero_venom_slimewalk", "decal_timed")
tt.render.sprites[1].prefix = "hero_venom_run_particle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].fps = 15
tt.timed.duration = fts(20)

tt = E:register_t("decal_hero_venom_spike_b", "decal_hero_venom_spike_a")
tt.render.sprites[1].prefix = "hero_venom_spike_b"

tt = E:register_t("decal_hero_venom_death", "decal_scripted")
E:add_comps(tt, "tween")
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

tt = E:register_t("ps_bolt_hero_dragon_gem_attack")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_dragon_gem_attack_projectile_trail_idle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(14), fts(14)}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi * 0.5
tt.particle_system.z = Z_FLYING_HEROES

tt = E:register_t("fx_hero_dragon_gem_bolt_hit", "fx5")
tt.render.sprites[1].name = "hero_dragon_gem_attack_fx_idle"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = E:register_t("fx_hero_dragon_gem_bolt_hit_flying", "fx5")
tt.render.sprites[1].name = "hero_dragon_gem_attack_fx_air_idle"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].draw_order = DO_MOD_FX
tt = E:register_t("fx_hero_dragon_gem_skill_stun", "fx5")
tt.render.sprites[1].name = "hero_dragon_gem_breath_cloud_idle"
tt.render.sprites[1].loop = true
tt = E:register_t("fx_hero_dragon_gem_ultimate_shard_arrival_1", "fx5")
tt.render.sprites[1].name = "hero_dragon_gem_ultimate_fx_a_idle"
tt.render.sprites[1].loop = false
tt = E:register_t("fx_hero_dragon_gem_ultimate_shard_arrival_2", "fx5")
tt.render.sprites[1].name = "hero_dragon_gem_ultimate_fx_b_idle"
tt.render.sprites[1].loop = false

tt = E:register_t("decal_hero_dragon_gem_crystal_tomb", "decal_scripted")
tt.render.sprites[1].prefix = "hero_dragon_gem"
tt.render.sprites[1].name = "death_crystals"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.main_script.update = scripts.decal_hero_dragon_gem_crystal_tomb.update

tt = E:register_t("decal_bullet_hero_dragon_gem_ultimate_shard", "decal_tween")
tt.render.sprites[1].name = "hero_dragon_gem_ultimate_crystal_a_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.tween.props[1].keys = {{0, 255}, {3, 0}}
tt = E:register_t("decal_hero_dragon_gem_floor_decal", "decal_tween")
tt.render.sprites[1].name = "hero_dragon_gem_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {1.5, 255}, {2, 0}}

tt = E:register_t("decal_hero_dragon_gem_floor_circle", "decal")
E:add_comps(tt, "tween")
tt.render.sprites[1].name = "hero_dragon_gem_area_damage_fx"
tt.render.sprites[1].animated = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(6), 255}, {fts(13), 0}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.245, 0.245)}, {fts(6), vec_2(0.385, 0.385)}, {fts(13), vec_2(0.42, 0.42)}}
tt.tween.props[2].sprite_id = 1
tt.tween.remove = true
tt = E:register_t("decal_hero_dragon_gem_floor_circle_totem", "decal_hero_dragon_gem_floor_circle")
tt.tween.props[2].keys = {{0, vec_2(0.175, 0.175)}, {fts(6), vec_2(0.315, 0.315)}, {fts(13), vec_2(0.35, 0.35)}}

tt = E:register_t("ps_hero_witch_ranged_basic_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "hero_witch_ranged_attack_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.particle_lifetime = {fts(5), fts(8)}
tt.particle_system.emit_rotation_spread = math.pi * 0.5

tt = E:register_t("ps_hero_witch_spark_1")
E:add_comps(tt, "pos", "particle_system", "main_script")
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

tt = E:register_t("ps_bullet_hero_witch_skill_polymorph")
E:add_comps(tt, "pos", "particle_system")
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

tt = E:register_t("fx_hero_witch_basic_ranged_hit", "fx")
tt.render.sprites[1].name = "hero_witch_ranged_attack_hit"
tt.render.sprites[1].scale = vec_1(KR5_SCALE_FACTOR)

tt = E:register_t("fx_hero_witch_ultimate", "fx")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_fx"
tt.render.sprites[1].scale = vec_1(KR5_SCALE_FACTOR)

tt = E:register_t("fx_hero_witch_skill_path_aoe_in", "fx")
tt.render.sprites[1].name = "hero_witch_skill_4_potion_in_layer1_in"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(KR5_SCALE_FACTOR)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "hero_witch_skill_4_potion_in_layer2_in"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_EFFECTS
tt.render.sprites[2].scale = vec_1(KR5_SCALE_FACTOR)
tt = E:register_t("fx_hero_witch_skill_polymorph", "fx")
tt.render.sprites[1].name = "hero_witch_skill_1_hit_run"
tt.render.sprites[1].z = Z_OBJECTS_COVERS
tt.render.sprites[1].scale = vec_1(KR5_SCALE_FACTOR)
tt = E:register_t("decal_hero_witch_ultimate", "decal_timed")
tt.render.sprites[1].name = "hero_witch_ultimate_teleport_decal"
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_1(KR5_SCALE_FACTOR)

tt = E:register_t("tower_tricannon_bomb_4_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "tricannon_tower_lvl4_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 70
tt.particle_system.animation_fps = 15
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}

tt = E:register_t("tower_tricannon_bomb_4_bombardment_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "tricannon_tower_lvl4_particle"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 60
tt.particle_system.animation_fps = 25
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(2, 2)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}

tt = E:register_t("tower_tricannon_bomb_4_overheated_trail")
E:add_comps(tt, "pos", "particle_system")
tt.particle_system.name = "tricannon_tower_lvl4_particle_overheat"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 70
tt.particle_system.emit_rotation_spread = math.pi * 2
tt.particle_system.emit_area_spread = vec_2(3, 3)
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.particle_lifetime = {0.7, 0.85}

tt = E:register_t("mod_endless_archer_insight", "mod_health_damage_factor_inc")
-- package.loaded.soldier_enemies = nil
-- require("soldier_enemies")

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

tt = RT("mod_cricet_add_hp", "mod_shaman_heal")

tt.main_script.insert = scripts.mod_cricet_add_hp.insert
tt.main_script.update = scripts.mod_cricet_add_hp.update

tt.hps.heal = 0.4

tt = RT("mod_cricet_protection", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_protection"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_protection.insert
tt.main_script.update = scripts.mod_cricet_protection.update
tt.main_script.remove = scripts.mod_cricet_protection.remove

tt.modifier.protection = 1.3
tt.modifier.duration = -1

tt = RT("mod_cricet_attack", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_attack"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_attack.insert
tt.main_script.update = scripts.mod_cricet_attack.update
tt.main_script.remove = scripts.mod_cricet_attack.remove

tt.modifier.damage_factor = 1.5
tt.modifier.duration = -1

tt = RT("mod_cricet_faster", "modifier")

AC(tt, "render")

tt.render.sprites[1].prefix = "criket_random_eff_mod_faster"
tt.render.sprites[1].loop = true
tt.main_script.insert = scripts.mod_cricet_faster.insert
tt.main_script.update = scripts.mod_cricet_faster.update
tt.main_script.remove = scripts.mod_cricet_faster.remove

tt.modifier.speed_factor = 1.3
tt.modifier.duration = -1

tt = RT("endless_barrack_synergy_aura", "aura")
tt.aura.mod = "mod_endless_barrack_synergy"
tt.aura.radius = 180
tt.aura.cycle_time = 1
tt.main_script.insert = scripts.endless_barrack_synergy_aura.insert
tt.main_script.update = scripts.endless_barrack_synergy_aura.update

tt = RT("mod_endless_barrack_synergy", "modifier")
tt.extra_damage = nil
tt.modifier.duration = 4
tt.main_script.insert = scripts.mod_endless_barrack_synergy.insert
tt.main_script.update = scripts.mod_endless_barrack_synergy.update
tt.main_script.remove = scripts.mod_endless_barrack_synergy.remove

tt = RT("mod_endless_engineer_aftermath", "modifier")
tt.main_script.insert = scripts.mod_endless_engineer_aftermath.insert
tt.radius = 60
tt.value = 20
tt.main_script.update = nil
tt.main_script.remove = nil

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

tt = E:register_t("endless_mage_thunder")
E:add_comps(tt, "user_power", "pos", "main_script")
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

tt = E:register_t("ps_bullet_tower_ray_sheep")
E:add_comps(tt, "pos", "particle_system")
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

tt = E:register_t("fx_tower_ray_hit_start", "fx")
tt.render.sprites[1].name = "channeler_tower_crystal_union_fx_run"
tt = E:register_t("fx_tower_ray_hit_source", "fx")
tt.render.sprites[1].name = "channeler_tower_ray_start_loop"
tt.render.sprites[1].loop = true
tt.timed.runs = 1e+99
tt = E:register_t("fx_tower_ray_crystal_union", "fx")
tt.render.sprites[1].name = "channeler_tower_crystal_union_fx_run"
tt = E:register_t("fx_tower_ray_lvl4_attack", "fx")
tt.render.sprites[1].name = "channeler_tower_lvl4_tower_attack_fx_idle"
tt = E:register_t("fx_tower_ray_lvl4_attack_sheep", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_tower_fx_idle"
tt = E:register_t("fx_tower_ray_lvl4_attack_sheep_hit", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_fx_idle"
tt = E:register_t("fx_tower_ray_lvl4_attack_sheep_hit_big", "fx")
tt.render.sprites[1].name = "channeler_tower_mutation_fx_big_idle"
tt = E:register_t("fx_tower_ray_lvl4_shock", "fx")

E:add_comps(tt, "main_script")

tt.render.sprites[1].prefix = "channeler_tower_lvl4_idle_shock_fx_"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].draw_order = 3
tt.render.sprites[1].z = Z_OBJECT
tt.main_script.update = scripts.fx_tower_ray_lvl4_shock.update
tt.timed.runs = 1e+99

tt = E:register_t("moon_controller_s91", "moon_controller")
tt.main_script.update = scripts.moon_controller_s91.update
tt.transit_time = 5
tt.hold_time = 15
tt.inactive_time = 25
tt.enemy_damage_factor = 1.25
tt.enemy_speed_factor = 1.25
tt.enemy_cooldown_factor = 0.75
tt.enemy_health_factor = 0.75