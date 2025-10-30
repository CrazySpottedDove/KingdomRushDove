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
local balance = require("kr1.data.balance")
return function()

    DO_ENEMY_BIG = 2
    DO_SOLDIER_BIG = 3
    DO_HEROES = 3
    DO_MOD_FX = 4
    DO_TOWER_MODS = 10
    -- package.loaded["balance/balance"] = nil

    -- if H.command_line_has_arg("balance_override") then
    -- 	local balance_override_path = H.command_line_argvec_2("balance_override")

    -- 	package.loaded[balance_override_path] = nil

    -- 	require(balance_override_path)
    -- end

    -- if game and game.store and game.store.level and game.store.level.test_case and game.store.level.test_case.patch_balance then
    -- 	local new_balance = game.store.level.test_case:patch_balance()

    -- 	if new_balance then
    -- 		balance = new_balance
    -- 	end
    -- end

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
    tt = E:register_t("pop_crit", "pop")
    tt.render.sprites[1].name = "elven_pops_0021"
    tt = E:register_t("pop_headshot", "pop")
    tt.render.sprites[1].name = "elven_pops_0022"
    tt = E:register_t("pop_crit_mages", "pop")
    tt.render.sprites[1].name = "elven_pops_0023"
    tt = E:register_t("pop_crit_wild_magus", "pop")
    tt.render.sprites[1].name = "elven_pops_0024"
    tt = E:register_t("pop_crit_high_elven", "pop")
    tt.render.sprites[1].name = "elven_pops_0025"
    tt = E:register_t("pop_miss", "pop")
    tt.render.sprites[1].name = "elven_pops_0026"
    tt = E:register_t("pop_crit_heroes", "pop_crit")
    tt.pop_over_target = true
    tt = E:register_t("pop_mactans", "pop")
    tt.render.sprites[1].name = "mactans_pop"
    tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
    tt = E:register_t("ps_bolt_lumenir")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_lumenir_attack_projectile_trail_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(12), fts(12)}
    tt.particle_system.emission_rate = 30
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt.particle_system.z = Z_FLYING_HEROES
    tt = E:register_t("ps_bolt_lumenir_mini")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_lumenir_light_companion_attack_projectile_trail_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(12), fts(12)}
    tt.particle_system.emission_rate = 15
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt = E:register_t("ps_bolt_lumenir_wave")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_lumenir_light_companion_attack_projectile_trail_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(9), fts(15)}
    tt.particle_system.alphas = {255, 0}
    tt.particle_system.emission_rate = 15
    tt.particle_system.animation_fps = 30
    tt.particle_system.scales_x = {1.5, 2}
    tt.particle_system.scales_y = {1.5, 2}
    tt.particle_system.z = Z_OBJECTS
    tt.particle_system.emit_rotation_spread = math.pi / 4
    tt = E:register_t("ps_bolt_lance_lumenir")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "bolt_lance_lumenir_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.emission_rate = 90
    tt.particle_system.emit_rotation_spread = math.pi
    tt = E:register_t("ps_soul_soldier_tower_ghost")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "ghost_tower_soul_skill_projectile_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(13), fts(13)}
    tt.particle_system.emission_rate = 60
    tt.particle_system.emit_rotation_spread = math.pi
    tt = E:register_t("ps_bullet_liquid_fire_lumenir")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.emission_rate = 20
    tt.particle_system.emit_duration = fts(10)
    tt.particle_system.emit_speed = {250, 250}
    tt.particle_system.emit_rotation_spread = math.pi / 4
    tt.particle_system.animated = true
    tt.particle_system.animation_fps = 18
    tt.particle_system.loop = false
    tt.particle_system.name = "bullet_liquid_fire_lumenir_particle"
    tt.particle_system.particle_lifetime = {fts(9), fts(11)}
    tt.particle_system.alphas = {255, 255, 50}
    tt.particle_system.scales_x = {1, 1, 1.5}
    tt.particle_system.scales_y = {1, 1, 1.5}
    tt.particle_system.spin = {-math.pi * 0.5, math.pi * 0.5}
    tt.particle_system.sort_y_offsets = {-100, 0}
    tt = E:register_t("ps_minidragon_lumenir_fire", "ps_bullet_liquid_fire_lumenir")
    tt.particle_system.emit_duration = nil
    tt.particle_system.emit_speed = {500, 500}
    tt.particle_system.emit_rotation_spread = math.pi / 8
    tt = E:register_t("ps_hero_lumenir_fire_ball")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.particle_lifetime = {fts(15), fts(25)}
    tt.particle_system.scales_x = {0.75, 2.5}
    tt.particle_system.scales_y = {0.75, 2.5}
    tt.particle_system.scale_var = {0.5, 1}
    tt.particle_system.emission_rate = 10
    tt.particle_system.sort_y_offset = -20
    tt.particle_system.z = Z_OBJECTS
    tt.particle_system.name = "bolt_lance_lumenir_particle"
    tt.particle_system.animated = true
    tt.particle_system.particle_lifetime = {0.4, 2}
    tt.particle_system.alphas = {255, 0}
    tt.particle_system.scales_x = {1, 3.5}
    tt.particle_system.scales_y = {1, 3.5}
    tt.particle_system.scale_var = {0.45, 0.9}
    tt.particle_system.scale_same_aspect = false
    tt.particle_system.emit_spread = math.pi
    tt.particle_system.emission_rate = 30
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
    tt = E:register_t("tower_tricannon_bomb_4_overheated_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "tricannon_tower_lvl4_particle_overheat"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 70
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(3, 3)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("tower_demon_pit_demon_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "demon_pit_tower_demon_projectile_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 50
    tt.particle_system.particle_lifetime = {0.2, 0.4}
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(10, 10)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_soldier_tower_ghost")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "ghost_tower_spawn_trail_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 50
    tt.particle_system.particle_lifetime = {0.2, 0.4}
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(10, 10)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("royal_archer_tower_lvl4_arrow_armor_breaker_trail_particle")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "royal_archer_tower_lvl4_arrow_armor_piercer_trail_particle_idle_1"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 200
    tt.particle_system.animation_fps = 20
    tt.particle_system.track_rotation = true
    tt = E:register_t("ps_bullet_dreadeye_viper")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "dreadeye_viper_ranged_attack_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 80
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.scale_var = {1, 1.1}
    tt.particle_system.particle_lifetime = {0.6, 0.8}
    tt = E:register_t("ps_rapacious_hunter_eagle_royal_archers")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_eagle_attack_particle"
    tt.particle_system.animated = false
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 30
    tt.particle_system.particle_lifetime = {fts(1), fts(1)}
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
    tt.particle_system.emit_area_spread = vec_2(0, 5)
    tt = E:register_t("ps_tower_tricannon_bomb_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "tricannon_tower_lvl4_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 70
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(2, 2)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_stargazers_death_star_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "elven_stargazers_tower_rising_star_particle_trail_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 20
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(2, 2)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_hero_vesper_arrow_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_vesper_attack_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.animation_fps = 15
    tt.particle_system.emission_rate = 100
    tt.particle_system.track_rotation = true
    tt = E:register_t("ps_hero_vesper_arrow_to_the_knee_bullet_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_vesper_arrow_to_the_knee_particles"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 300
    tt.particle_system.animation_fps = 15
    tt.particle_system.track_rotation = true
    tt.particle_system.scales_y = {1.5, 0.7}
    tt.particle_system.scales_x = {1.5, 0.7}
    tt = E:register_t("ps_hero_vesper_ricochet_bullet_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_vesper_ricochet_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.animation_fps = 35
    tt.particle_system.emission_rate = 180
    tt.particle_system.track_rotation = true
    tt.particle_system.scales_y = {1.5, 0.7}
    tt.particle_system.scales_x = {1.5, 0.7}
    tt = E:register_t("ps_hero_vesper_ricochet_bullet_trail_bounce")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_vesper_ricochet_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.animation_fps = 30
    tt.particle_system.emission_rate = 180
    tt.particle_system.track_rotation = true
    tt.particle_system.scales_y = {1, 0.7}
    tt.particle_system.scales_x = {1, 0.7}
    tt = E:register_t("ps_hero_muyrn_verdant_blast_bolt_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_nyru_verdant_blast_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.emission_rate = 60
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt = E:register_t("ps_tower_arborean_emissary_bolt_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "arborean_emissary_particle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(15), fts(15)}
    tt.particle_system.emission_rate = 45
    tt.particle_system.emit_area_spread = vec_2(8, 8)
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.scales_y = {1, 1.5}
    tt.particle_system.scales_x = {1, 1.5}
    tt = E:register_t("ps_tower_arborean_emissary_gift_of_nature_wisps")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "arborean_emissary_gift_of_nature_pollen"
    tt.particle_system.animated = true
    tt.particle_system.loop = true
    tt.particle_system.emission_rate = 8
    tt.particle_system.emit_direction = -math.pi * 2
    tt.particle_system.emit_rotation = 0
    tt.particle_system.emit_area_spread = vec_2(20, 20)
    tt.particle_system.track_offset = vec_2(0, -10)
    tt = E:register_t("ps_enemy_rhino_charge_a")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "razing_rhino_razing_rhino_charge_dust_a"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 4
    tt.particle_system.track_offset = vec_2(0, 0)
    tt.particle_system.z = Z_DECALS
    tt = E:register_t("ps_enemy_rhino_charge_b")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "razing_rhino_razing_rhino_charge_dust_b"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 3
    tt.particle_system.track_offset = vec_2(0, 20)
    tt.particle_system.animation_fps = 15
    tt.particle_system.z = Z_DECALS
    tt = E:register_t("ps_bullet_enemy_unblinded_priest")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "unblinded_priest_projectile_trail_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 30
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.particle_lifetime = {fts(6), fts(6)}

    tt = E:register_t("ps_tower_rocket_gunners_sting_missiles_trail")

    E:add_comps(tt, "pos", "particle_system")

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
    tt = E:register_t("ps_bullet_stage_10_obelisk_priests")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "stage10_obelisk_particle_Idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 30
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.emit_area_spread = vec_2(8, 8)
    tt.particle_system.scales_y = {1, 1.5}
    tt.particle_system.scales_x = {1, 1.5}
    tt.particle_system.animation_fps = 15
    tt = E:register_t("ps_tower_necromancer_skull_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "necromancer_tower_skull_projectile_particle_trail_idle"
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
    tt.particle_system.particle_lifetime = {fts(11), fts(11)}
    tt.emit_offset_relative = vec_2(-15, 0)
    tt = E:register_t("ps_tower_necromancer_rider_trail_A")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "necromancer_tower_death_rider_trial_particle_A_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 6
    tt.particle_system.emit_area_spread = vec_2(15, 15)
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.z = Z_OBJECTS
    tt.particle_system.particle_lifetime = {fts(13), fts(13)}
    tt.particle_system.emit_offset = vec_2(0, 0)
    tt.emit_offset_relative = vec_2(-10, 0)
    tt = E:register_t("ps_tower_necromancer_rider_trail_B")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "necromancer_tower_death_rider_trial_particle_B_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 8
    tt.particle_system.emit_area_spread = vec_2(15, 15)
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.z = Z_OBJECTS + 1
    tt.particle_system.particle_lifetime = {fts(9), fts(9)}
    tt.particle_system.emit_offset = vec_2(0, 0)
    tt.emit_offset_relative = vec_2(-10, 0)
    tt = E:register_t("ps_bullet_tower_ballista_skill_bomb_trail_A")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "ballista_tower_junk_particle_projectile_1"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 15
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_2(10, 10)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_tower_ballista_skill_bomb_trail_B")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "ballista_tower_junk_particle_projectile_2"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 10
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_2(10, 10)
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_hero_mecha_smoke_1")

    E:add_comps(tt, "pos", "particle_system", "main_script")

    tt.particle_system.name = "hero_onagro_back_smoke_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 10
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt.particle_system.emit_area_spread = vec_2(2, 2)
    tt.particle_system.emit_direction = 2 * math.pi / 3
    tt.particle_system.emit_speed = {20, 25}
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.emit_offset = vec_2(-30, 45)
    tt.particle_system.z = Z_OBJECTS
    tt.particle_system.sort_y_offset = -40
    tt.main_script.update = scripts.ps_hero_mecha_smoke.update
    tt.emit_direction_sides = {2 * math.pi / 3, math.pi / 3}
    tt = E:register_t("ps_hero_mecha_smoke_2", "ps_hero_mecha_smoke_1")
    tt.particle_system.emit_offset = vec_2(-10, 50)
    tt = E:register_t("ps_bullet_hero_mecha_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_onagro_attack_particle_idle"
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
    tt = E:register_t("ps_bullet_stage_11_cult_leader")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "mydrias_proyectile_trail_run"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.anchor = vec_2(0.6, 0.5)
    tt.particle_system.emission_rate = 30
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt.particle_system.scales_y = {0.8, 0.5}
    tt.particle_system.emit_area_spread = vec_2(5, 5)
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
    tt.particle_system.emit_area_spread = vec_2(5, 5)
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt = E:register_t("ps_bullet_stage_03_heart_of_the_arborean")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "stage_3_HeartProy_trail"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(5), fts(5)}
    tt.particle_system.emission_rate = 30
    tt.particle_system.emit_area_spread = vec_1(0)
    tt.particle_system.scales_y = {1, 0.5}
    tt.particle_system.scales_x = {1, 0.5}
    tt = E:register_t("ps_bullet_tower_flamespitter_skill_bomb")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "dwarven_flamespitter_tower_blazing_trail_projectile_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 50
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_1(5)
    tt.particle_system.particle_lifetime = {fts(8), fts(8)}
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_vile_spawner_spawn")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "vile_spawner_projectile_fx_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(8), fts(8)}
    tt.particle_system.emission_rate = 30
    tt.particle_system.emit_area_spread = vec_2(0, 0)
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt = E:register_t("ps_terrain_3_spores_1")

    E:add_comps(tt, "pos", "particle_system")

    tt.pos = vec_2(512, -20)
    tt.particle_system.alphas = {200, 150, 200, 0}
    tt.particle_system.emission_rate = 1.5
    tt.particle_system.emit_area_spread = vec_2(1300, 10)
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
    tt.particle_system.emit_area_spread = vec_2(0, 0)
    tt.particle_system.emit_rotation_spread = math.pi * 2
    tt = E:register_t("ps_bullet_tower_barrel")

    E:add_comps(tt, "pos", "particle_system")

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
    tt = E:register_t("ps_bullet_tower_barrel_skill_barrel")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "barrel_tower_lvl4_bad_barrel_projectile_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 150
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_2(10, 0)
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_tower_sand")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "tower_sand_lvl1_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 150
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_2(10, 0)
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_tower_sand_skill_gold")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "tower_sand_lvl4_skill_1_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 150
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_2(10, 0)
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_aura_tower_sand_skill_big_blade")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "tower_sand_lvl4_skill_2_particle_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 20
    tt.particle_system.animation_fps = 30
    tt.particle_system.emit_area_spread = vec_1(0)
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_hero_robot_smoke_1")

    E:add_comps(tt, "pos", "particle_system", "main_script")

    tt.particle_system.name = "Blaze_humitodeatras_run"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.emission_rate = 6
    tt.particle_system.emit_rotation_spread = d2r(45)
    tt.particle_system.emit_area_spread = vec_2(2, 2)
    tt.particle_system.emit_speed = {20, 25}
    tt.particle_system.anchor = vec_2(0.5, 0.5)
    tt.particle_system.emit_offsets = {vec_2(10, 46), vec_2(20, 43)}
    tt.particle_system.z = Z_OBJECTS
    tt.particle_system.sort_y_offset = -40
    tt.particle_system.scale_var = {0.7, 0.7}
    tt.main_script.update = scripts.ps_hero_robot_smoke.update
    tt.emit_direction_sides = {d2r(95), d2r(40)}
    tt = E:register_t("ps_hero_robot_smoke_2", "ps_hero_robot_smoke_1")
    tt.particle_system.emit_offsets = {vec_2(-10, 44), vec_2(0, 41)}
    tt = E:register_t("ps_bolt_hero_dragon_gem_attack")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_dragon_gem_attack_projectile_trail_idle"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(14), fts(14)}
    tt.particle_system.emission_rate = 20
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt.particle_system.z = Z_FLYING_HEROES

    tt = E:register_t("ps_bullet_hero_bird_cluster_bomb")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "gryph_skillproy_trail_run"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(15), fts(15)}
    tt.particle_system.emission_rate = 20
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_hero_bird_cluster_bomb_part")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "gryph_skillshot_part_trail_run"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(14), fts(14)}
    tt.particle_system.emission_rate = 20
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("ps_bullet_stage_16_overseer_tentacle_spawn")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "overseer_fx_overseer_proyectile_trail_run"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(10), fts(10)}
    tt.particle_system.emission_rate = 15
    tt.particle_system.emit_rotation_spread = math.pi * 0.5
    tt.particle_system.z = Z_BULLET_PARTICLES
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
    tt = E:register_t("fx_bolt_lumenir_hit", "fx")
    tt.render.sprites[1].name = "hero_lumenir_attack_hit_fx_air"
    tt = E:register_t("fx_bolt_lumenir_hit_mini", "fx")
    tt.render.sprites[1].name = "hero_lumenir_light_companion_attack_fx_idle"
    tt = E:register_t("fx_arborean_sentinels_spearmen_spear_hit", "fx")
    tt.render.sprites[1].name = "tower_arborean_sentinels_spearmen_hitFx"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt = E:register_t("fx_hero_vesper_attack_hit", "fx")
    tt.render.sprites[1].name = "hero_vesper_attack_hit"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt.render.sprites[1].z = Z_OBJECTS
    tt = E:register_t("fx_tower_royal_archer_rapacious_hunter_dust", "fx")
    tt.render.sprites[1].name = "tower_build_dust"
    tt.render.sprites[1].scale = vec_2(0.5, 0.5)
    tt = E:register_t("fx_tower_elven_stargazers_ray_hit_start", "fx")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "elven_stargazers_tower_rising_star_hit_fx_idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].scale = vec_2(1.5, 1.5)
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(10)
    tt.timed.runs = 1e+99
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {fts(5), 255}, {fts(10), 0}}
    tt.tween.remove = false
    tt = E:register_t("fx_tower_stargazers_teleport_middle", "fx")
    tt.render.sprites[1].name = "elven_stargazers_tower_event_horizon_idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(32)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_stargazers_teleport_enemy_small", "fx")
    tt.render.sprites[1].name = "elven_stargazers_tower_event_horizon_decal_idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(32)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_stargazers_teleport_enemy_big", "fx")
    tt.render.sprites[1].name = "elven_stargazers_tower_event_horizon_decal_big_idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(32)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_elven_stargazers_ray_hit", "fx")

    E:add_comps(tt)

    tt.render.sprites[1].name = "elven_stargazers_tower_ray_end_end"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(10)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_arcane_wizard_ray_hit_start", "fx")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "arcane_wizard_tower_ray_start_idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].scale = vec_2(1.5, 1.5)
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(25)
    tt.timed.runs = 1e+99
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.1, 255}, {fts(18), 255}, {fts(25), 0}}
    tt.tween.remove = false
    tt = E:register_t("fx_tower_arcane_wizard_ray_hit", "fx")

    E:add_comps(tt)

    tt.render.sprites[1].name = "arcane_wizard_tower_ray_end_idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(10)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_arcane_wizard_disintegrate_ray_hit_start", "fx")
    tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_disintegration_ray_charge_origin"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.timed.duration = fts(37)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_arcane_wizard_ray_disintegrate_hit", "fx")
    tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_disintegration_hit_idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.render.sprites[1].fps = 25
    tt.timed.duration = fts(17)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_tower_arborean_emissary_bolt_hit", "fx")
    tt.render.sprites[1].name = "arborean_emissary_hit"
    tt = E:register_t("fx_hero_builder_overtime_work_raise", "fx")
    tt.render.sprites[1].name = "hero_obdul_skill_5_soldier_spawn_decal"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("fx_tower_stargazers_death_star_hit", "fx")
    tt.render.sprites[1].prefix = "elven_stargazers_tower_rising_star_hit_fx"

    tt = E:register_t("fx_soul_soldier_tower_ghost", "fx")
    tt.render.sprites[1].name = "ghost_tower_soul_skill_hit_fx_idle"


    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_floor", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_hit_fx_floor_idle"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_hit", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_hit_fx_idle"
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit_air", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_explosion_air_idle"
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_phosphoric_floor", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_hit_fx_floor_idle"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_phosphoric_hit", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_hit_fx_idle"
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_explosion_idle"
    tt = E:register_t("fx_tower_rocket_gunners_take_off", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_take_off_fx_idle"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].sort_y_offset = -50
    tt = E:register_t("fx_soldier_tower_rocket_gunners_land", "fx")
    tt.render.sprites[1].name = "rocket_gunners_tower_landing_fx_idle"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("fx_bullet_soldier_tower_rocket_gunners_sting_missiles_smoke", "fx")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "rocket_gunners_tower_sting_missiles_floor_decal_smoke_idle"
    tt.render.sprites[1].loop = true
    tt.timed.duration = 1e+99
    tt.timed.runs = 1e+99
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {3, 255}, {3.5, 0}}
    tt.tween.remove = true
    tt = E:register_t("fx_soldier_tower_necromancer_skeleton_spawn", "fx")
    tt.render.sprites[1].name = "necromancer_tower_revive_idle"
    tt = E:register_t("fx_soldier_tower_necromancer_skeleton_golem_spawn", "fx")
    tt.render.sprites[1].name = "necromancer_tower_revive_big_idle"
    tt = E:register_t("fx_tower_necromancer_rider_hit", "fx")
    tt.render.sprites[1].name = "necromancer_tower_skull_projectile_hit_FX_idle"
    tt = E:register_t("fx_tower_necromancer_rider_spawn_side", "fx")
    tt.render.sprites[1].name = "necromancer_tower_death_rider_start_walk_FX_side_idle"
    tt = E:register_t("fx_tower_necromancer_rider_spawn_front", "fx")
    tt.render.sprites[1].name = "necromancer_tower_death_rider_start_walk_FX_front_idle"
    tt = E:register_t("fx_tower_necromancer_rider_spawn_back", "fx")
    tt.render.sprites[1].name = "necromancer_tower_death_rider_start_walk_FX_back_idle"
    tt = E:register_t("fx_tower_ballista_shot", "fx")
    tt.render.sprites[1].name = "ballista_tower_arrow_fx_idle"
    tt = E:register_t("fx_tower_ballista_final_shot", "fx")
    tt.render.sprites[1].name = "ballista_tower_special_arrow_fx_idle"
    tt = E:register_t("fx_bullet_tower_ballista_hit", "fx")
    tt.render.sprites[1].name = "ballista_tower_hit_2"
    tt = E:register_t("fx_bullet_tower_ballista_final_shot_hit", "fx")
    tt.render.sprites[1].name = "ballista_tower_special_hit_idle"
    tt = E:register_t("fx_bullet_tower_ballista_missed_arrow", "fx")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "ballista_tower_missed_arrow"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.timed.duration = 6
    tt.timed.runs = 1e+99
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {tt.timed.duration - 0.5, 255}, {tt.timed.duration, 0}}
    tt = E:register_t("fx_bullet_tower_ballista_missed_arrow_dust", "fx")
    tt.render.sprites[1].name = "ballista_tower_missed_arrow_dust"
    tt = E:register_t("fx_bullet_tower_ballista_missed_arrow_decal", "fx")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "ballista_tower_missed_arrow_decal"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].animated = false
    tt.timed.duration = 6
    tt.timed.runs = 1e+99
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {tt.timed.duration - 0.5, 255}, {tt.timed.duration, 0}}
    tt = E:register_t("fx_bullet_tower_ballista_bomb_spawn", "fx")
    tt.render.sprites[1].name = "ballista_tower_bomb_fx_idle"
    tt = E:register_t("fx_bullet_tower_ballista_bomb_junk_floor", "fx")
    tt.render.sprites[1].name = "ballista_tower_junk_particle_floor"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.timed.duration = fts(16)
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_bullet_tower_ballista_bomb_explosion", "fx")
    tt.render.sprites[1].name = "ballista_tower_bomb_explotion_idle"
    tt = E:register_t("fx_tower_flamespitter_flame", "fx")
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_flamethrower_fx"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].z = Z_BULLETS
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_bullet_tower_flamespitter_bomb_explosion", "fx")
    tt.render.sprites[1].name = "dwarven_flamespitter_tower_blazing_trail_explosion_idle"
    tt = E:register_t("fx_bullet_tower_flamespitter_bomb_burn", "fx")
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_blazing_trail_path_fx"
    tt.render.sprites[1].name = "idle"
    tt = E:register_t("fx_tower_flamespitter_column", "fx")
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_scorching_torches_fx"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].scale = vec_1(0.75)
    tt.render.sprites[1].z = Z_OBJECTS
    tt = E:register_t("fx_bullet_tower_barrel", "fx")
    tt.render.sprites[1].name = "barrel_tower_projectile_hit_fx_idle"
    tt.render.sprites[1].z = Z_OBJECTS
    tt = E:register_t("fx_soldier_tower_barrel_skill_warrior_hit", "fx")
    tt.render.sprites[1].name = "barrel_tower_berserker_unit_hit_fx_idle"
    tt = E:register_t("fx_soldier_tower_barrel_skill_warrior_spawn", "fx")
    tt.render.sprites[1].name = "barrel_tower_lvl4_tower_berserker_spawn_fx_idle"
    tt = E:register_t("fx_bullet_tower_sand_hit", "fx")
    tt.render.sprites[1].name = "tower_sand_basic_hit"
    tt = E:register_t("fx_bullet_tower_sand_skill_gold_hit", "fx")
    tt.render.sprites[1].name = "tower_sand_lvl4_skill_1_hit"
    tt = E:register_t("fx_bullet_tower_sand_skill_gold_hit_coins", "fx")
    tt.render.sprites[1].name = "tower_sand_lvl4_skill_1_coins_hit"
    tt = E:register_t("fx_aura_tower_sand_skill_big_blade", "fx")
    tt.render.sprites[1].name = "tower_sand_lvl4_skill_2_hit_FX_loop"
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
    tt = E:register_t("fx_bullet_decal_item_portable_coil", "fx")
    tt.render.sprites[1].prefix = "item_portable_coil_hitDef"
    tt.render.sprites[1].name = "hit"
    tt.render.sprites[1].exo = true
    tt = E:register_t("fx_item_scroll_of_spaceshift", "fx")
    tt.render.sprites[1].name = "item_scroll_of_spaceshift_teleport_fx_in"
    tt = E:register_t("fx_item_loot_box_dust", "fx")
    tt.render.sprites[1].prefix = "item_loot_box_dust"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].animated = true
    tt = E:register_t("fx_item_second_breath_respawn", "fx")
    tt.render.sprites[1].name = "item_second_breath_respawn_fx_idle"
    tt = E:register_t("fx_item_second_breath_tap", "fx")
    tt.render.sprites[1].name = "item_second_breath_tap_fx"
    tt = E:register_t("fx_dreadeye_viper_hit", "fx")
    tt.render.sprites[1].name = "dreadeye_viper_ranged_attack_hit"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt = E:register_t("fx_bear_ground_hit", "fx")
    tt.render.sprites[1].name = "bear_vanguard_decal_animation"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].scale = vec_2(1.5, 1.5)
    tt.render.sprites[1].sort_y_offset = -2
    tt = E:register_t("fx_enemy_desintegrate_KR5", "fx_enemy_desintegrate")
    tt.render.sprites[1].size_names = {"small", "big", "big"}
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

    tt.render.sprites[1].name = "crystal_golem_decal"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].sort_y_offset = 2
    tt.tween.props[1].keys = {{fts(10), 255}, {0.8, 255}, {1, 0}}
    tt.tween.props[1].loop = false
    tt.tween.props[1].sprite_id = 1
    tt = E:register_t("fx_enemy_evolving_scourge_eat", "fx")
    tt.render.sprites[1].name = "evolving_scourge_eat_FX"
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
    tt = E:register_t("fx_hero_builder_melee_attack_hit", "fx")
    tt.render.sprites[1].name = "hero_obdul_basic_attack_hit"
    tt = E:register_t("fx_hero_builder_defensive_turret_hit", "fx")
    tt.render.sprites[1].name = "hero_obdul_skill_4_tower_hit"
    tt = E:register_t("fx_hero_builder_demolition_man", "fx")
    tt.render.sprites[1].prefix = "hero_obdul_skill_3_fx"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].loop = true

    tt = E:register_t("fx_bullet_hero_mecha_spawn_1", "fx")
    tt.render.sprites[1].name = "hero_onagro_attack_1_cannon_particle_idle"
    tt = E:register_t("fx_bullet_hero_mecha_spawn_2", "fx")
    tt.render.sprites[1].name = "hero_onagro_attack_2_cannon_particle_idle"
    tt = E:register_t("fx_bullet_hero_mecha_hit", "fx")
    tt.render.sprites[1].name = "hero_onagro_attack_1_hit_idle"
    tt = E:register_t("fx_bullet_drone_hero_mecha", "fx")
    tt.render.sprites[1].name = "hero_onagro_skill_1_drone_hit_fx_idle"
    tt = E:register_t("fx_bullet_hero_mecha_tar_bomb", "fx")
    tt.render.sprites[1].name = "hero_onagro_skill_2_hit"
    tt = E:register_t("fx_hero_mecha_mine_explosion", "fx")
    tt.render.sprites[1].name = "hero_onagro_skill_4_mine_explosion_idle"
    tt = E:register_t("fx_bullet_zeppelin_hero_mecha", "fx")
    tt.render.sprites[1].name = "hero_onagro_ultimate_hit_idle"
    tt = E:register_t("fx_hero_venom_melee_attack_hit", "fx")
    tt.render.sprites[1].name = "hero_venom_hit_fx_idle"
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt = E:register_t("fx_hero_venom_beast_lvl_up", "fx")
    tt.render.sprites[1].name = "hero_venom_levelup_fx_idle"
    tt = E:register_t("fx_hero_robot_skill_fire", "fx")
    tt.render.sprites[1].name = "Blaze_skill2explosion_run"
    tt = E:register_t("fx_hero_robot_ultimate_train_spawn", "fx")
    tt.render.sprites[1].name = "Blaze_tren_box"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt = E:register_t("fx_hero_robot_ultimate_smoke", "decal_tween")
    tt.render.sprites[1].name = "Blaze_skill2humo_loop"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.tween.props[1].keys = {{fts(0), 0}, {fts(10), 255}, {0.8, 255}, {1, 0}}
    tt.tween.props[1].loop = false

    tt = E:register_t("fx_hero_dragon_gem_bolt_hit", "fx")
    tt.render.sprites[1].name = "hero_dragon_gem_attack_fx_idle"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("fx_hero_dragon_gem_bolt_hit_flying", "fx")
    tt.render.sprites[1].name = "hero_dragon_gem_attack_fx_air_idle"
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("fx_hero_dragon_gem_skill_stun", "fx")
    tt.render.sprites[1].name = "hero_dragon_gem_breath_cloud_idle"
    tt.render.sprites[1].loop = true
    tt = E:register_t("fx_hero_dragon_gem_ultimate_shard_arrival_1", "fx")
    tt.render.sprites[1].name = "hero_dragon_gem_ultimate_fx_a_idle"
    tt.render.sprites[1].loop = false
    tt = E:register_t("fx_hero_dragon_gem_ultimate_shard_arrival_2", "fx")
    tt.render.sprites[1].name = "hero_dragon_gem_ultimate_fx_b_idle"
    tt.render.sprites[1].loop = false
    tt = E:register_t("fx_bullet_hero_bird", "fx")
    tt.render.sprites[1].name = "gryph_proy_explosion_run"
    tt.render.sprites[1].z = Z_OBJECTS
    tt = E:register_t("fx_bullet_hero_bird_cluster_bomb_air", "fx")
    tt.render.sprites[1].name = "gryph_skillproy_explosion_run"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt.render.sprites[1].anchor = vec_2(0.43, 0.5)
    tt = E:register_t("fx_bullet_hero_bird_cluster_bomb", "fx")
    tt.render.sprites[1].name = "gryph_skillproy_part_explosion_run"
    tt.render.sprites[1].z = Z_OBJECTS
    tt = E:register_t("fx_hero_bird_gattling", "fx")
    tt.render.sprites[1].name = "gryph_bulletskill_enemyhitfx_run"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt = E:register_t("fx_hero_bird_cluster_bomb_ray", "fx")
    tt.render.sprites[1].name = "gryph_skillshot_run"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt.render.sprites[1].scale = vec_1(1)
    tt = E:register_t("fx_hero_bird_ultimate", "fx")
    tt.render.sprites[1].name = "gryph_child_hit_run"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
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
    tt.render.sprites[1].scale = vec_1(70)
    tt.tween.remove = true
    tt.tween.props[1].name = "scale"
    tt.tween.props[1].keys = {{fts(0), vec_1(70)}}
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
    tt = E:register_t("fx_soldier_reinforcement_special_linirea", "fx")
    tt.render.sprites[1].name = "reinforcement_linirea_lvl_5_hit_vfx_idle"
    tt.render.sprites[1].scale = vec_1(0.8)
    tt = E:register_t("fx_soldier_reinforcement_special_dark_army", "fx")
    tt.render.sprites[1].name = "reinforcement_darkarmy_lvl_5_unit_hit_vfx"
    tt = E:register_t("fx_hit_crow_reinforcement_special_dark_army", "fx")
    tt.render.sprites[1].name = "reinforcement_darkarmy_lvl_5_crow_hit_idle"
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
    tt.tween.props[2].keys = {{0, 0}, {tt.scale_timing - 0.1, 0}, {tt.scale_timing, 255},
                              {tt.scale_timing + tt.scale_duration, 0}}
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[3] = E:clone_c("tween_prop")
    tt.tween.props[3].keys = {{0, 0}, {tt.prev_duration - 0.1, 0}, {tt.prev_duration, 255},
                              {tt.prev_duration + tt.decal_duration - 1, 255}, {tt.prev_duration + tt.decal_duration, 0}}
    tt.tween.props[3].sprite_id = 3
    tt.tween.props[4] = E:clone_c("tween_prop")
    tt.tween.props[4].name = "scale"
    tt.tween.props[4].keys = {{fts(0), vec_2(1, 1)}, {tt.scale_timing - 0.1, vec_2(1, 1)},
                              {tt.scale_timing + tt.scale_duration, vec_2(1.5, 1.5)}}
    tt.tween.props[4].sprite_id = 2
    tt.tween.props[5] = E:clone_c("tween_prop")
    tt.tween.props[5].keys = {{0, 0}, {tt.scale_timing - 0.1, 0}, {tt.scale_timing, 255},
                              {tt.scale_timing + tt.scale_duration + 1, 0}}
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
    tt = E:register_t("fx_stage_11_veznan_soldiers_spawn_top", "fx")
    tt.render.sprites[1].name = "stage11_veznan_export_spawn_top"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
    tt = E:register_t("fx_stage_11_veznan_spawn", "decal")
    tt.render.sprites[1].prefix = "stage11_veznan_export_rayo_spawn"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
    tt = E:register_t("fx_stage_11_veznan_spawn_base", "decal")
    tt.render.sprites[1].prefix = "stage11_veznan_export_tierrita_spawn"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
    tt = E:register_t("fx_stage_11_portal_spawn", "fx")
    tt.render.sprites[1].prefix = "stage_11_portal_fxDef"
    tt.render.sprites[1].name = "Animations"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].fps = 30
    tt = E:register_t("fx_upgrade_alliance_flux_altering_coils_teleport", "fx")
    tt.render.sprites[1].prefix = "upgrade_flags_teleport_fx"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].size_names = {"idle", "big_idle", "big_idle"}
    tt.render.sprites[1].animated = true
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt = E:register_t("fx_bullet_enemy_noxious_horror_explosion_flying", "fx")
    tt.render.sprites[1].name = "noxious_horror_projectile_splash_flying"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt = E:register_t("fx_bullet_enemy_noxious_horror_hit", "fx")
    tt.render.sprites[1].name = "noxious_horror_ranged_attack_hit_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_EFFECTS
    tt = E:register_t("fx_enemy_hardened_horror_hit", "fx")
    tt.render.sprites[1].name = "hardened_horror_hit_vfx_attack_1_hit"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_EFFECTS
    tt = E:register_t("fx_enemy_blinker_attack", "fx")
    tt.render.sprites[1].name = "blinker_stun_fx_Idle"
    tt.render.sprites[1].loop = true
    tt.timed.runs = 1e+99
    tt = E:register_t("fx_enemy_blinker_attack_glare", "fx_enemy_blinker_attack")
    tt.render.sprites[1].name = "blinker_glare_fx_Idle"
    tt = E:register_t("fx_soldier_reinforcement_stage_15_denas_hit", "fx")
    tt.render.sprites[1].name = "denas_hit_fx_Idle"
    tt = E:register_t("fx_soldier_reinforcement_stage_15_denas_floor", "decal_timed")
    tt.render.sprites[1].name = "denas_decal_Idle"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "denas_explosion_fx_idle"
    tt.render.sprites[2].z = Z_EFFECTS
    tt.render.sprites[2].loop = false
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
    tt = E:register_t("fx_item_deaths_touch", "fx")
    tt.render.sprites[1].name = "deaths_touch_fx_idle"
    tt = E:register_t("fx_item_cluster_bomb", "fx")
    tt.render.sprites[1].prefix = "cluster_bomb_main_explosion"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].draw_order = 100
    tt = E:register_t("fx_item_cluster_bomb_small", "fx")
    tt.render.sprites[1].prefix = "cluster_bomb_fragment_explosion"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].draw_order = 100
    tt = E:register_t("fx_soldier_reinforcement_item_summon_blackburn_melee_attack_hit", "fx")
    tt.render.sprites[1].name = "item_summon_blackburn_attack_1_hit_idle"
    tt = E:register_t("fx_soldier_reinforcement_item_summon_blackburn_area_attack_hit", "fx")
    tt.render.sprites[1].name = "item_summon_blackburn_attack_2_hit_idle"
    tt = E:register_t("fx_soldier_reinforcement_item_summon_blackburn_area_attack", "fx")
    tt.render.sprites[1].name = "item_summon_blackburn_attack_2_fx_idle"
    tt = E:register_t("decal_tower_arcane_wizard_empowerment_preview", "decal_tween")

    E:add_comps(tt, "render", "tween")

    tt.range_factor = 1
    tt.render.sprites[1].name = "arcane_wizard_tower_empowerment_indicator"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_TOWER_BASES + 1
    tt.render.sprites[1].offset.y = 5
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.1, 255}}
    tt.tween.remove = false
    tt = E:register_t("decal_tower_arborean_emissary_gift_of_nature_wisp", "decal_scripted")

    E:add_comps(tt, "force_motion", "tween")

    tt.render.sprites[1].name = "arborean_emissary_gift_of_nature_wisp"
    tt.render.sprites[1].z = Z_BULLETS
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 1200
    tt.force_motion.max_v = 300
    tt.main_script.update = scripts.decal_tower_arborean_emissary_gift_of_nature_wisp.update
    tt.standing_duration = fts(33)
    tt.initial_impulse = 900
    tt.initial_impulse_duration = fts(10)
    tt.initial_impulse_angle = {math.pi, math.pi * 0.5, -math.pi}
    tt.initial_destination = {vec_2(-20, 30), vec_2(20, 30), vec_2(0, 50)}

    local fly_strenght = 10
    local fly_frequency = 30

    tt.tween.disabled = true
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].interp = "sine"
    tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(fly_frequency), vec_2(0, fly_strenght)}, {fts(fly_frequency * 2), vec_2(0, 0)},
                              {fts(fly_frequency * 3), vec_2(0, -fly_strenght)}, {fts(fly_frequency * 4), vec_2(0, 0)}}
    tt.tween.props[1].loop = true
    tt.tween.props[1].disabled = true
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{0, 255}, {fts(10), 0}}
    tt.tween.props[2].disabled = true
    tt.tween.remove = false
    tt.particles_name = "ps_tower_arborean_emissary_gift_of_nature_wisps"
    tt.positions = {{{0, vec_2(100, 0)}, {0.3, vec_2(100, 50)}, {0.5, vec_2(50, 0)}, {0.7, vec_2(0, 20)}, {0.8, vec_2(10, -10)},
                     {1, vec_2(0, 0)}}, {{0, vec_2(0, 0)}, {0.3, vec_2(20, -20)}, {0.7, vec_2(-20, -20)}, {1, vec_2(0, 0)}},
                    {{0, vec_2(0, 0)}, {0.1, vec_2(-100, 0)}, {0.2, vec_2(-100, -50)}, {0.5, vec_2(-50, 0)}, {0.6, vec_2(-50, 0)},
                     {0.7, vec_2(0, 0)}, {0.8, vec_2(-20, -10)}, {1, vec_2(0, 0)}}}
    tt = E:register_t("decal_tower_demon_pit_reload", "decal_scripted")
    tt.render.sprites[1].name = nil
    tt.render.sprites[1].z = Z_TOWER_BASES + 1
    tt.main_script.update = scripts.decal_tower_demon_pit_reload.update
    tt = E:register_t("decal_tower_demon_pit_demon_explosion_decal", "decal_tween")

    E:add_comps(tt, "render", "tween")

    tt.render.sprites[1].name = "demon_pit_tower_demon_minion_explosion_decal"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_rally_range_KR5", "decal")
    tt.actual_radius = 137
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "rally_circle_full"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].scale = vec_2(1, 1)
    tt.render.sprites[1].z = Z_OBJECTS_SKY
    tt = E:register_t("decal_hero_lumenir_sword", "decal_tween")
    tt.render.sprites[1].name = "hero_lumenir_celestial_judgement_fx_decal"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.remove = false
    tt = E:register_t("decal_tower_range_KR5", "decal_rally_range_KR5")
    tt.render.sprites[1].name = "range_circle_full"
    tt = E:register_t("decal_soldier_shadow", "decal_scripted")
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].animated = false
    tt.main_script.update = scripts.decal_soldier_shadow.update
    tt.max_height = 50
    tt.shadow_shrink = 0.4
    tt.entity = nil
    tt.dissapear_time = 14
    tt = E:register_t("decal_soldier_tower_rocket_gunners_shadow", "decal_soldier_shadow")
    tt.render.sprites[1].name = "rocket_gunners_tower_gunner_shadow"
    tt.shadow_shrink = 0.25
    tt = E:register_t("decal_bullet_soldier_tower_rocket_gunners_sting_missiles", "decal_tween")
    tt.render.sprites[1].name = "rocket_gunners_tower_sting_missiles_floor_decal"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {3, 255}, {3.5, 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_bullet_tower_flamespitter_bomb", "decal_tween")
    tt.render.sprites[1].name = "dwarven_flamespitter_tower_blazing_trail_explosion_decal"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {1, 255}, {2, 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_tower_flamespitter_skill_columns", "decal_timed")
    tt.render.sprites[1].prefix = "dwarven_flamespitter_tower_scorching_torches_particle"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.timed.duration = fts(10)
    tt = E:register_t("decal_tower_stage_13_sunray", "decal_tween")
    tt.render.sprites[1].name = "sunraytower_decal1_Asst_SunrayTower_Decal1"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "sunraytower_decal2_Asst_sunraytower_decal2"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].z = Z_DECALS + 1
    tt.render.sprites[2].offset = vec_2(0, 10)
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(20), 255}, {fts(40), 0}}
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{0, 255}, {fts(10), 255}, {fts(20), 0}}
    tt.tween.props[2].sprite_id = 2
    tt.tween.remove = true
    tt = E:register_t("decal_bullet_tower_barrel", "decal_timed")
    tt.render.sprites[1].name = "barrel_tower_projectile_hit_fx_decal_idle"
    tt.render.sprites[1].animated = true
    tt.timed.duration = fts(22)
    tt = E:register_t("decal_aura_bullet_tower_barrel_skill_barrel_explosion", "decal_tween")
    tt.render.sprites[1].name = "barrel_tower_lvl4_bad_barrel_projectile_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(20), 255}, {fts(40), 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_soldier_tower_barrel_skill_warrior", "decal_tween")
    tt.render.sprites[1].prefix = "barrel_tower_berserker_unit_decal"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
    tt.tween.remove = true
    tt.tween.disabled = true
    tt = E:register_t("decal_hero_raelyn_onslaught_decal", "decal_tween")
    tt.render.sprites[1].name = "hero_raelyn_onslaught_fx_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].hide_after_runs = 1
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
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
    tt = E:register_t("decal_path_hero_movement", "decal")

    E:add_comps(tt, "main_script")

    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "unit_drag_discontinue_line"
    tt.render.sprites[1].z = Z_OBJECTS_SKY + 10
    tt = E:register_t("decal_hero_builder_defensive_turret", "decal_scripted")
    b = balance.heroes.hero_builder.defensive_turret

    E:add_comps(tt, "bullet_attack")

    for i = 1, 3 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "hero_obdul_skill_4_tower_layer" .. i
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
    end

    tt.bullet_attack.max_range = b.attack.range
    tt.bullet_attack.bullet = "arrow_hero_builder_defensive_turret"
    tt.bullet_attack.shoot_time = fts(6)
    tt.bullet_attack.cooldown = nil
    tt.bullet_attack.bullet_start_offset = {vec_2(10, 55), vec_2(-10, 55)}
    tt.bullet_attack.animation = "attack"
    tt.bullet_attack.vis_flags = bor(F_RANGED)
    tt.bullet_attack.vis_bans = bor(F_FRIEND, F_NIGHTMARE)
    tt.main_script.update = scripts.decal_hero_builder_defensive_turret.update
    tt.duration = nil
    tt = E:register_t("decal_hero_builder_ultimate_projectile", "decal_scripted")
    b = balance.heroes.hero_builder.defensive_turret

    E:add_comps(tt, "bullet")

    tt.render.sprites[1].name = "hero_obdul_ultimate_projectile"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].anchor = vec_2(0.2, 0.5)
    tt.bullet.max_speed = 3000
    tt.bullet.arrive_decal = "decal_hero_builder_ultimate_ball"
    tt.bullet.aura = "aura_hero_builder_ultimate"
    tt.main_script.update = scripts.decal_hero_builder_ultimate_projectile.update
    tt = E:register_t("decal_hero_builder_ultimate_ball", "decal_scripted")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].prefix = "hero_obdul_ultimate"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "hero_obdul_ultimate"
    tt.render.sprites[2].name = "ball"
    tt.render.sprites[2].loop = false

    for i = 1, 4 do
        tt.render.sprites[i + 2] = E:clone_c("sprite")
        tt.render.sprites[i + 2].prefix = "hero_obdul_ultimate"
        tt.render.sprites[i + 2].name = "rock_0" .. i .. "_in"
        tt.render.sprites[i + 1].loop = false
    end

    tt.render.sprites[7] = E:clone_c("sprite")
    tt.render.sprites[7].prefix = "hero_obdul_ultimate"
    tt.render.sprites[7].name = "dust_over_ball_run"
    tt.render.sprites[7].loop = false
    tt.render.sprites[8] = E:clone_c("sprite")
    tt.render.sprites[8].name = "hero_obdul_ultimate_decal"
    tt.render.sprites[8].offset = vec_2(0, 20)
    tt.render.sprites[8].loop = false
    tt.render.sprites[8].animated = false
    tt.render.sprites[8].z = Z_DECALS
    tt.render.sprites[8].scale = vec_2(0.8, 0.8)
    tt.render.sprites[9] = E:clone_c("sprite")
    tt.render.sprites[9].name = "hero_obdul_ultimate_decal"
    tt.render.sprites[9].offset = vec_2(-20, -7)
    tt.render.sprites[9].loop = false
    tt.render.sprites[9].animated = false
    tt.render.sprites[9].z = Z_DECALS
    tt.render.sprites[9].scale = vec_2(0.8, 0.8)
    tt.render.sprites[10] = E:clone_c("sprite")
    tt.render.sprites[10].name = "hero_obdul_ultimate_decal"
    tt.render.sprites[10].offset = vec_2(20, -7)
    tt.render.sprites[10].loop = false
    tt.render.sprites[10].animated = false
    tt.render.sprites[10].z = Z_DECALS
    tt.render.sprites[10].scale = vec_2(0.8, 0.8)

    local dust_scales = {vec_2(0.8, 0.8), vec_2(0.7, 0.7), vec_2(0.7, 0.7), vec_2(0.8, 0.8), vec_2(0.7, 0.7), vec_2(0.7, 0.7)}
    local dust_offset = {vec_2(-30, 20), vec_2(-35, 0), vec_2(-20, -10), vec_2(30, 20), vec_2(35, 0), vec_2(20, -10)}

    for i = 1, 6 do
        tt.render.sprites[10 + i] = E:clone_c("sprite")
        tt.render.sprites[10 + i].prefix = "hero_obdul_ultimate"
        tt.render.sprites[10 + i].name = "dust_cloud"
        tt.render.sprites[10 + i].loop = false
        tt.render.sprites[10 + i].scale = dust_scales[i]
        tt.render.sprites[10 + i].offset = dust_offset[i]
    end

    tt.main_script.update = scripts.decal_hero_builder_ultimate_ball.update
    tt.tween.remove = true
    tt.tween.disabled = true
    tt.tween.props[1].keys = {{0, 255}, {fts(20), 0}}

    for i = 2, 16 do
        tt.tween.props[i] = table.deepclone(tt.tween.props[1])
        tt.tween.props[i].sprite_id = i
    end

    tt.duration = 2.5

    tt = E:register_t("decal_hero_venom_slimewalk", "decal_timed")
    tt.render.sprites[1].prefix = "hero_venom_run_particle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].fps = 15
    tt.timed.duration = fts(20)
    tt = E:register_t("decal_hero_venom_spike_a", "decal_scripted")
    b = balance.heroes.hero_venom.floor_spikes
    tt.render.sprites[1].prefix = "hero_venom_spike_a"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].animated = true
    tt.main_script.update = scripts.decal_hero_venom_spike.update
    tt.damage_type = b.damage_type
    tt.damage_min = nil
    tt.damage_max = nil
    tt.damage_radius = b.damage_radius
    tt.vis_flags = bor(F_AREA)
    tt.vis_bans = bor(F_FLYING)
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
    tt = E:register_t("decal_hero_robot_skill_explode", "decal")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "Blaze_skill3decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "Blaze_skill1y3decal"
    tt.render.sprites[2].name = "run"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].loop = false
    tt.render.sprites[2].scale = vec_2(1.1, 1.1)
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(9), 255}, {fts(16), 0}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "scale"
    tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {fts(6), vec_2(1.7, 1.7)}, {fts(16), vec_2(2, 2)}}
    tt.tween.props[2].sprite_id = 1
    tt.tween.remove = true
    tt = E:register_t("decal_hero_robot_skill_uppercut_clone", "decal")

    E:add_comps(tt, "tween")

    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {0, 255}, {0, 0}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.remove = true
    tt = E:register_t("decal_hero_robot_ultimate_floor", "decal_tween")
    tt.render.sprites[1].name = "Blaze_trendecal_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.tween.props[1].keys = {{0, 255}, {1, 0}}
    tt = E:register_t("decal_hero_dragon_gem_crystal_tomb", "decal_scripted")
    b = balance.heroes.hero_dragon_gem
    tt.render.sprites[1].prefix = "hero_dragon_gem"
    tt.render.sprites[1].name = "death_crystals"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.main_script.update = scripts.decal_hero_dragon_gem_crystal_tomb.update
    tt = E:register_t("decal_hero_dragon_gem_floor_impact_shard", "decal_scripted")

    E:add_comps(tt, "sound_events")

    b = balance.heroes.hero_dragon_gem.floor_impact
    tt.render.sprites[1].prefix = "hero_dragon_gem_shards"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.damage_min = nil
    tt.damage_max = nil
    tt.main_script.update = scripts.decal_hero_dragon_gem_floor_impact_shard.update
    tt.damage_time = fts(5)
    tt.duration_time = fts(10)
    tt.damage_range = b.damage_range
    tt.damage_type = b.damage_type
    tt.sound_events.insert = "HeroDragonGemPrismaticShardRipple"
    tt = E:register_t("decal_hero_dragon_gem_ultimate_shard", "decal_scripted")

    E:add_comps(tt, "tween", "sound_events")

    b = balance.heroes.hero_dragon_gem.ultimate
    tt.render.sprites[1].name = "hero_dragon_gem_ultimate_crystal_b"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].loop = false
    tt.damage_min = nil
    tt.damage_max = nil
    tt.main_script.update = scripts.decal_hero_dragon_gem_ultimate_shard.update
    tt.damage_time = fts(1)
    tt.damage_range = b.damage_range
    tt.damage_type = b.damage_type
    tt.bullet = "bullet_hero_dragon_gem_ultimate_shard"
    tt.fx_on_arrival = {"fx_hero_dragon_gem_ultimate_shard_arrival_1", "fx_hero_dragon_gem_ultimate_shard_arrival_2"}
    tt.floor_decal = "decal_hero_dragon_gem_floor_decal"
    tt.tween.props[1].keys = {{0, 255}, {3, 0}}
    tt.tween.disabled = true
    tt.tween_remove = false
    tt.sound_events.insert = "HeroDragonGemUltimateCast"
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
    tt.tween.props[2].keys = {{0, vec_2(0.35, 0.35)}, {fts(6), vec_2(0.55, 0.55)}, {fts(13), vec_2(0.6, 0.6)}}
    tt.tween.props[2].sprite_id = 1
    tt.tween.remove = true
    tt = E:register_t("decal_hero_dragon_gem_floor_circle_totem", "decal_hero_dragon_gem_floor_circle")
    tt.tween.props[2].keys = {{0, vec_2(0.25, 0.25)}, {fts(6), vec_2(0.45, 0.45)}, {fts(13), vec_2(0.5, 0.5)}}
    tt = E:register_t("decal_hero_bird_tomb", "decal_scripted")

    E:add_comps(tt, "tween")

    b = balance.heroes.hero_bird
    tt.render.sprites[1].prefix = "gryph_deaththing"
    tt.render.sprites[1].name = "death"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_DECALS
    tt.main_script.update = scripts.decal_hero_bird_tomb.update
    tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
    tt.tween.disabled = true
    tt.tween.remove = true
    tt = E:register_t("decal_bullet_hero_bird", "decal_tween")
    tt.render.sprites[1].name = "gryph_proy_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].anchor = vec_2(0.5, 0.45)
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 255}, {0.5, 255}, {1.25, 0}}
    tt = E:register_t("decal_hero_bird_shout_stun", "decal_timed")
    tt.render.sprites[1].name = "gryph_stunskill_decal_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.timed.duration = fts(23)
    tt = E:register_t("decal_hero_bird_gattling", "decal_timed")
    tt.render.sprites[1].name = "gryph_bulletskill_decal_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].scale = vec_1(0.7)
    tt.timed.duration = fts(27)
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
    tt.render.sprites[1].name = "werebeast_boss_shadow"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].name = "scale"
    tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {1.5, vec_2(0, 0)}}
    tt = E:register_t("decal_enemy_amalgam_hit", "decal_scripted")
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

    tt.render.sprites[1].name = "Amalgam_Death_Decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.distance_between = 25
    tt.tween.props[1].keys = {{0, 255}, {fts(34), 255}, {fts(40), 0}}
    tt.tween.props[1].loop = false
    tt.tween.remove = true
    tt = E:register_t("decal_soldier_tower_ghost_hit", "fx")
    tt.render.sprites[1].name = "ghost_tower_hit_fx_idle"
    tt = E:register_t("decal_item_cluster_bomb_crater", "decal_tween")
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt.render.sprites[1].name = "cluster_bomb_explosion_decal"
    tt.render.sprites[1].animated = false
    tt = E:register_t("decal_defend_point5", "decal")

    E:add_comps(tt, "main_script", "editor", "editor_script")

    tt.main_script.insert = scripts.decal_defend_point5.insert
    tt.render.sprites[1].name = "defense_point_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].alpha = 100
    tt.editor.exit_id = 1
    tt.editor.orientation = 1
    tt.editor.alpha = 10
    tt.editor.flip = 0
    tt.editor_script.update = scripts.decal_defend_point5.update_editor
    tt.editor.props = {{"editor.exit_id", PT_NUMBER}, {"editor.orientation", PT_NUMBER}, {"editor.alpha", PT_NUMBER},
                       {"editor.flip", PT_NUMBER}}

    local tt = E:register_t("decal_defense_flag5", "decal_defense_flag")

    E:add_comps(tt, "main_script", "editor", "editor_script")

    tt.main_script.insert = scripts.decal_defense_flag5.insert
    tt.render.sprites[1].name = "defense_flag"
    tt.editor.flip = 0
    tt.editor_script.update = scripts.decal_defense_flag5.update_editor
    tt.editor.props = {{"editor.flip", PT_NUMBER}}
    tt = E:register_t("decal_upgrade_alliance_seal_of_punishment", "decal_scripted")
    b = balance.upgrades.alliance_seal_of_punishment
    tt.main_script.update = scripts.decal_upgrade_alliance_seal_of_punishment.update
    tt.render.sprites[1].prefix = "seal_of_punishment_seal"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "seal_of_punishment_particles"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_EFFECTS
    tt.render.sprites[2].hidden = true
    tt.vis_flags = bor(F_AREA)
    tt.vis_bans = 0
    tt.trigger_dist = b.radius
    tt.cooldown = b.cooldown
    tt.aura = "aura_upgrade_alliance_seal_of_punishment"
    tt = E:register_t("decal_upgrade_alliance_flux_altering_coils", "decal_scripted")
    b = balance.upgrades.alliance_flux_altering_coils
    tt.main_script.update = scripts.decal_upgrade_alliance_flux_altering_coils.update
    tt.render.sprites[1].prefix = "upgrade_flags_base"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "upgrade_flags_cristal"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "upgrade_flags_particle_fx"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].animated = true
    tt.render.sprites[3].z = Z_OBJECTS
    tt.render.sprites[3].hidden = true
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "upgrade_flags_circle_fx"
    tt.render.sprites[4].name = "idle"
    tt.render.sprites[4].animated = true
    tt.render.sprites[4].z = Z_OBJECTS - 1
    tt.base_sid = 1
    tt.cristal_sid = 2
    tt.particle_sid = 3
    tt.circle_sid = 4
    tt.mod_teleport = "mod_upgrade_alliance_flux_altering_coils_teleport"
    tt.mod_mark = "mod_upgrade_alliance_flux_altering_coils_mark"
    tt.trigger_dist = b.radius
    tt.cooldown = b.cooldown
    tt.nodes_teleport = b.nodes_teleport
    tt = E:register_t("decal_upgrade_alliance_display_of_true_might_dark_army_overlay", "decal")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "display_of_true_might_slow_overlay"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_OBJECTS_SKY
    tt.render.sprites[1].scale = vec_1(4096)
    tt.tween.props[1].keys = {{0, 0}, {fts(5), 50}, {fts(15), 50}, {fts(20), 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_upgrade_alliance_display_of_true_might_linirea_overlay",
        "decal_upgrade_alliance_display_of_true_might_dark_army_overlay")
    tt.render.sprites[1].name = "display_of_true_might_heal_overlay"
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
    tt = E:register_t("decal_wisp_1", "decal_delayed_play")
    tt.render.sprites[1].name = "props_wisp"
    tt.delayed_play.min_delay = 2
    tt.delayed_play.max_delay = 30
    tt.delayed_play.idle_animation = nil
    tt.delayed_play.play_animation = "props_wisp"
    tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}}
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
    tt.render.sprites[2].offset = vec_2(-36, 5)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "campfire_guy_campfire"
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "campfire_guy_tent_front"
    tt.render.sprites[4].offset = vec_2(-36, 5)
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
    tt.gold_pos_offset = vec_2(-10, 40)
    tt.gold_amount = 25
    tt.fish_animations = {"fishing_nothing", "fishing_nothing", "fishing_fish_or_boot", "fishing_nothing",
                          "fishing_nothing"}
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

    tt.load_file = "level01_taunts"
    tt.main_script.insert = scripts.taunts_controller.insert
    tt.taunts.delay_min = 10
    tt.taunts.delay_max = 20
    tt.taunts.sets = {}
    tt.taunts.sets.tutorial_arborean_build_barrack = CC("taunt_set")
    tt.taunts.sets.tutorial_arborean_build_barrack.format = "TAUNT_TUTORIAL_ARBOREAN_BARRACK_%04i"
    tt.taunts.sets.tutorial_arborean_build_barrack.decal_name = "decal_tutorial_arborean_shoutbox"
    tt.taunts.sets.tutorial_arborean_build_barrack.pos = vec_2(860, 650)
    tt.taunts.sets.tutorial_arborean_build_all = CC("taunt_set")
    tt.taunts.sets.tutorial_arborean_build_all.format = "TAUNT_TUTORIAL_ARBOREAN_ALL_%04i"
    tt.taunts.sets.tutorial_arborean_build_all.decal_name = "decal_tutorial_arborean_shoutbox"
    tt.taunts.sets.tutorial_arborean_build_all.pos = vec_2(860, 650)
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
    tt.render.sprites[3].offset = vec_2(0, 1)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(180, 58)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.editor.props = {{"render.sprites[1].name", PT_STRING}, {"render.sprites[1].scale", PT_COORDS},
                       {"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].z", PT_NUMBER}}
    tt = E:register_t("decal_waves", "decal_loop")
    tt.render.sprites[1].name = "stage_2_props_waves"
    tt = E:register_t("taunts_s02_controller")

    E:add_comps(tt, "main_script", "taunts", "editor")

    tt.load_file = "level01_taunts"
    tt.main_script.insert = scripts.taunts_controller.insert
    tt.taunts.delay_min = 10
    tt.taunts.delay_max = 20
    tt.taunts.sets = {}
    tt.taunts.sets.stage_02_veznan = CC("taunt_set")
    tt.taunts.sets.stage_02_veznan.format = "TAUNT_STAGE02_VEZNAN_%04i"
    tt.taunts.sets.stage_02_veznan.decal_name = "decal_stage02_veznan_shoutbox"
    tt.taunts.sets.stage_02_veznan.pos = vec_2(740, 670)
    tt.taunts.sets.stage_02_raelyn = CC("taunt_set")
    tt.taunts.sets.stage_02_raelyn.format = "TAUNT_STAGE02_RAELYN_%04i"
    tt.taunts.sets.stage_02_raelyn.decal_name = "decal_stage02_raelyn_shoutbox"
    tt.taunts.sets.stage_02_raelyn.pos = vec_2(460, 550)
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.render.sprites[1].scale = vec_1(1.1)
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
    tt = E:register_t("decal_bullet_stage_03_heart_of_the_arborean", "decal")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].name = "explosiondecal_asst_heart_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.disabled = false
    tt.tween.remove = true
    tt.tween.props[1].keys = {{0, 255}, {3, 255}, {4, 0}}
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
    tt.render.sprites[1].pos = vec_2(512, 384)
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
    tt.walk_destination = {vec_2(0, 0), vec_2(100, -70), vec_2(175, -100), vec_2(100, -70)}
    tt.motion.speed = vec_2(10, 10)
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
    tt.walk_destination = {vec_2(0, 0), vec_2(54, 8), vec_2(151, 55), vec_2(54, 8)}
    tt.fall_to_y = 580
    tt = E:register_t("decal_stage_04_arborean_center", "decal_stage_04_arborean_right")
    tt.render.sprites[1].prefix = "stage_4_arboreans_arborean_03"
    tt.main_script.update = scripts.decal_stage_04_arborean.update
    tt.walk_destination = {vec_2(0, 0), vec_2(142, -75)}
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
    tt.tween.props[2].keys = {{0, vec_2(0, 0)}, {duration, vec_2(0, -130)}}
    tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS}}
    tt = E:register_t("stage_4_arborean_bridge_1", "decal_scripted")

    E:add_comps(tt, "editor", "editor_script")

    local time_between_animations = fts(30 * math.random(3, 5))

    tt.render.sprites[1].prefix = "anim_puente1"
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
    tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations},
                     {"action2", time_between_animations}}
    tt.main_script.update = scripts.decal_scripted_loop_play.update
    tt = E:register_t("stage_4_arborean_bridge_2", "decal_scripted")

    E:add_comps(tt, "editor", "editor_script")

    local time_between_animations = fts(30 * math.random(3, 5))

    tt.render.sprites[1].prefix = "anim_puente2"
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
    tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations},
                     {"action2", time_between_animations}}
    tt.main_script.update = scripts.decal_scripted_loop_play.update
    tt = E:register_t("stage_4_arborean_bridge_3", "decal_scripted")

    E:add_comps(tt, "editor", "editor_script")

    local time_between_animations = fts(30 * math.random(3, 5))

    tt.render.sprites[1].prefix = "anim_puente3"
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
    tt.render.sprites[1].name = "action1"
    tt.animations = {{"action1", time_between_animations}, {"idle", time_between_animations},
                     {"action2", time_between_animations}, {"action3", time_between_animations}}
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
    tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {fts(1), vec_2(1.2, 1.2)}, {fts(3), vec_2(1, 1)}}
    tt.tween.props[2].disabled = true
    tt.tween.props[2].sprite_id = 6
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

    tt.load_file = "level01_taunts"
    tt.main_script.insert = scripts.taunts_controller.insert
    tt.taunts.delay_min = 10
    tt.taunts.delay_max = 20
    tt.taunts.sets = {}
    tt.taunts.sets.stage_06_cult_leader_greetings = CC("taunt_set")
    tt.taunts.sets.stage_06_cult_leader_greetings.format = "TAUNT_STAGE06_CULTIST_GREETING_%04i"
    tt.taunts.sets.stage_06_cult_leader_greetings.decal_name = "decal_stage06_cultist_shoutbox"
    tt.taunts.sets.stage_06_cult_leader_greetings.pos = vec_2(740, 670)
    tt.taunts.sets.stage_06_boss_pig_response = CC("taunt_set")
    tt.taunts.sets.stage_06_boss_pig_response.format = "TAUNT_STAGE06_BOSS_PIG_RESPONSE_%04i"
    tt.taunts.sets.stage_06_boss_pig_response.decal_name = "decal_stage06_boss_pig_shoutbox"
    tt.taunts.sets.stage_06_boss_pig_response.pos = vec_2(460, 550)
    tt.taunts.sets.stage_06_boss_pig_prebattle = CC("taunt_set")
    tt.taunts.sets.stage_06_boss_pig_prebattle.format = "TAUNT_STAGE06_BOSS_PIG_PREBATTLE_%04i"
    tt.taunts.sets.stage_06_boss_pig_prebattle.decal_name = "decal_stage06_boss_pig_shoutbox"
    tt.taunts.sets.stage_06_boss_pig_prebattle.pos = vec_2(460, 550)
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.tween.props[2].keys = {{0, vec_2(1, 1)}, {fts(1), vec_2(1.2, 1.2)}, {fts(3), vec_2(1, 1)}}
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
    tt.gold_pos_offset = vec_2(0, -30)
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
    tt.tween.props[1].keys = {{fts(0), vec_2(0, tt.move_distance)}, {fts(tt.move_frequency), vec_2(0, 15)},
                              {fts(tt.move_frequency * 2), vec_2(0, tt.move_distance)}}
    tt.tween.props[1].loop = true
    tt.tween.props[1].disabled = true
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "offset"
    tt.tween.props[2].interp = "sine"
    tt.tween.props[2].keys = {{fts(0), vec_2(0, 0)}, {fts(tt.move_frequency), vec_2(0, tt.move_distance)}}
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
    tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {fts(35), vec_2(0, 7)}, {fts(70), vec_2(0, 0)}}
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
    tt.render.sprites[1].scale = vec_1(1.15)
    tt.info = nil
    tt.user_selection.can_select_point_fn = scripts.decal_stage_11_veznan.can_select_point
    tt.main_script.update = scripts.decal_stage_11_veznan.update
    tt.attacks.list[1] = E:clone_c("custom_attack")
    tt.attacks.list[1].bullet = "bullet_stage_11_veznan_skill_1"
    tt.attacks.list[1].bullet_spawn_pos = vec_2(0, 50)
    tt.attacks.list[2] = E:clone_c("custom_attack")
    tt.attacks.list[2].preparation_time = fts(25)
    tt.attacks.list[2].spawn_time = fts(30)
    tt.attacks.list[2].decal = "decal_stage_11_veznan_skill_soldiers"
    tt.attacks.list[2].decal_pos = {vec_2(-40, 333), vec_2(540, 91)}
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
    tt.bullet_formation = {{vec_2(0, 50)}, {vec_2(-20, 30), vec_2(20, 30)}, {vec_2(-20, 30), vec_2(20, 30), vec_2(0, 50)},
                           {vec_2(-20, 40), vec_2(20, 40), vec_2(0, 60), vec_2(0, 30)}}
    tt.spawn_fx = "fx_stage_11_veznan_spawn"
    tt.spawn_fx_base = "fx_stage_11_veznan_spawn_base"
    tt.spawn_delay = fts(42)
    tt.sound_events.insert = "Stage11MidCinematicVeznanTeleport"
    tt.sound_ready = "Stage11MidCinematicVeznanTeleport"
    tt.sound_soul_impact_cast = "Stage11VeznanSoulImpactCast"
    tt.sound_demon_guard_cast = "Stage11VeznanDemonGuardCast"
    tt = E:register_t("taunts_s11_controller")

    E:add_comps(tt, "main_script", "taunts", "editor")

    tt.load_file = "level11_taunts"
    tt.main_script.insert = scripts.taunts_controller.insert
    tt.taunts.delay_min = 10
    tt.taunts.delay_max = 20
    tt.taunts.sets = {}
    tt.taunts.sets.stage_11_cult_leader = CC("taunt_set")
    tt.taunts.sets.stage_11_cult_leader.format = "TAUNT_STAGE06_CULTIST_GREETING_%04i"
    tt.taunts.sets.stage_11_cult_leader.decal_name = "decal_stage11_cultist_shoutbox"
    tt.taunts.sets.stage_11_cult_leader.pos = vec_2(740, 670)
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.35)
    tt.sequence.steps = {"in", "spawn", "out"}
    tt = E:register_t("decal_stage_11_veznan_skill_cage", "decal")
    tt.render.sprites[1].prefix = "stage11_veznan_export_veznan_electric_skill3"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt = E:register_t("decal_stage_11_veznan_hint", "decal_tween")
    tt.render.sprites[1].name = "stage11_veznan_export_globito"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
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
    tt.render.sprites[1].scale = vec_2(1, 1)
    tt.render.sprites[1].prefix = "stage_11_portalDef"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].draw_order = 1
    tt = E:register_t("decal_stage_11_torches", "decal")

    E:add_comps(tt, "editor")

    tt.render.sprites[1].random_ts = 1
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].scale = vec_2(1, 1)
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
    tt = E:register_t("decal_stage_11_mask", "decal")
    tt.render.sprites[1].name = "T2_Stage_11"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS
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
    tt.render.sprites[1].scale = vec_1(0.65)
    tt = E:register_t("decal_stage_11_rock_6", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_6"
    tt = E:register_t("decal_stage_11_rock_7", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_7"
    tt = E:register_t("decal_stage_11_rock_8", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_8"
    tt.render.sprites[1].scale = vec_1(0.75)
    tt = E:register_t("decal_stage_11_rock_9", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_9"
    tt = E:register_t("decal_stage_11_rock_10", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_10"
    tt = E:register_t("decal_stage_11_rock_11", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_11"
    tt = E:register_t("decal_stage_11_rock_12", "decal_stage_11_rock_11")
    tt.render.sprites[1].scale = vec_1(1.35)
    tt = E:register_t("decal_stage_11_rock_13", "decal_stage_11_rock_1")
    tt.render.sprites[1].scale = vec_1(0.85)
    tt = E:register_t("decal_stage_11_rock_14", "decal_stage_11_rock_13")
    tt.render.sprites[1].flip_x = true
    tt = E:register_t("decal_stage_11_rock_15", "decal_stage_11_rock_2")
    tt.render.sprites[1].scale = vec_1(2)
    tt.render.sprites[1].flip_x = true
    tt = E:register_t("decal_stage_11_rock_16", "decal_stage_11_rock_4")
    tt.render.sprites[1].scale = vec_1(1.25)
    tt = E:register_t("decal_stage_11_rock_17", "decal_stage_11_rock_4")
    tt.render.sprites[1].scale = vec_2(0.75, 0.5)
    tt.render.sprites[1].flip_x = true
    tt = E:register_t("decal_stage_11_rock_18", "decal_stage_11_rock_1")
    tt.render.sprites[1].name = "T2_Stage_11_floating_rocks_12"
    tt = E:register_t("decal_stage_11_rock_19", "decal_stage_11_rock_18")
    tt.render.sprites[1].scale = vec_2(0.5, 0.5)
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
    tt.render.sprites[2].offset = vec_2(0, -66)
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

    tt.pos = vec_2(512, 384)
    tt.render.sprites[1].name = "display_of_true_might_slow_overlay"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_OBJECTS_SKY
    tt.render.sprites[1].scale = vec_1(4096)
    tt.render.sprites[1].alpha = 0
    tt.tween.props[1].keys = {{0, 0}, {fts(30), 60}}
    tt.tween.remove = false
    tt.tween.disabled = true
    tt = E:register_t("decal_item_veznan_wrath_dark_overlay", "decal")

    E:add_comps(tt, "tween")

    tt.pos = vec_2(512, 384)
    tt.render.sprites[1].name = "item_veznan_wrath_overlay"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_SCREEN_FIXED
    tt.render.sprites[1].scale = vec_1(4096)
    tt.render.sprites[1].alpha = 0
    tt.render.sprites[1].hidden = false
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 100}}
    tt.tween.remove = false
    tt.tween.disabled = false
    tt = E:register_t("decal_item_veznan_wrath_green_overlay", "decal")
    tt.pos = vec_2(512, 384)
    tt.render.sprites[1].name = "item_veznan_wrath_overlay_green"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_SCREEN_FIXED
    tt.render.sprites[1].scale = vec_1(4096)
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
    tt.editor.props = {{"render.sprites[1].r", PT_NUMBER, math.pi / 180}, {"render.sprites[1].scale", PT_COORDS},
                       {"render.sprites[1].draw_order", PT_NUMBER}, {"render.sprites[1].name", PT_STRING},
                       {"render.sprites[1].z", PT_NUMBER}}
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
    tt.tween.props[1].keys = {{fts(0), vec_2(0, 0)}, {fts(tt.tween_frecuency), vec_2(0, tt.tween_amplitude)},
                              {fts(tt.tween_frecuency * 2), vec_2(0, 0)}}
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
    tt.pos_spawn = {vec_2(130, 210), vec_2(1033, 468)}
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
    tt.render.sprites[1].z = Z_OBJECT_COVERS
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
    tt.render.sprites[2].offset = vec_2(0, 13)
    tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[3].offset = vec_2(22, 0)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[4].offset = vec_2(0, -13)
    tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[5].offset = vec_2(-22, 0)
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
    tt = E:register_t("decal_soldier_reinforcement_item_summon_blackburn_area_attack", "decal_timed")
    tt.render.sprites[1].name = "item_summon_blackburn_attack_2_decal_idle"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("decal_item_portable_coil", "decal_scripted")
    b = balance.items.portable_coil
    tt.render.sprites[1].prefix = "item_portable_coilDef"
    tt.render.sprites[1].name = "spawn"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_OBJECT
    tt.main_script.update = scripts.decal_item_portable_coil.update
    tt.vis_flags = bor(F_STUN)
    tt.vis_bans = bor(F_NIGHTMARE)
    tt.range = b.range
    tt.bullet_start_offset = vec_2(0, 45)
    tt.hit_time = fts(2)
    tt.ray = "bullet_decal_item_portable_coil"
    tt.max_targets = b.max_targets
    tt.sound_cast = "ItemsPortableCoilCast"
    tt.sound_attack = "ItemsPortableCoilAttack"
    tt = E:register_t("decal_item_scroll_of_spaceshift", "decal_timed")
    tt.render.sprites[1].name = "item_scroll_of_spaceshift_decal_in"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("decal_item_loot_box_chest_projectile", "decal_scripted")
    b = balance.items.loot_box

    E:add_comps(tt, "bullet")

    tt.render.sprites[1].name = "item_loot_box_chest_projectile"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_BULLETS
    tt.render.sprites[1].scale = vec_1(0.95)
    tt.bullet.max_speed = 3000
    tt.bullet.arrive_decal = "decal_item_loot_box_chest"
    tt.bullet.aura = "aura_item_loot_box_damage"
    tt.main_script.update = scripts.decal_item_loot_box_projectile.update
    tt.dust = "fx_item_loot_box_dust"
    tt.floor_decal = "decal_item_loot_box_floor"
    tt.gold_amount = b.gold_amount
    tt.gold_pos_offset = vec_2(0, 60)
    tt.sound_hit = "ItemsLootBoxCast"
    tt = E:register_t("decal_item_loot_box_chest", "decal_tween")
    tt.render.sprites[1].prefix = "item_loot_box_chest"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].scale = vec_1(0.95)
    tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
    tt.tween.remove = true
    tt.tween.disabled = false
    tt.tween.disabled = false
    tt = E:register_t("decal_item_loot_box_pig_projectile", "decal_item_loot_box_chest_projectile")
    tt.render.sprites[1].name = "item_loot_box_pig_projectile"
    tt.bullet.arrive_decal = "decal_item_loot_box_pig"
    tt = E:register_t("decal_item_loot_box_pig", "decal_item_loot_box_chest")
    tt.render.sprites[1].prefix = "item_loot_box_pig"
    tt = E:register_t("decal_item_loot_box_statue_projectile", "decal_item_loot_box_chest_projectile")
    tt.render.sprites[1].name = "item_loot_box_statue_projectile"
    tt.render.sprites[1].scale = vec_1(1)
    tt.bullet.arrive_decal = "decal_item_loot_box_statue"
    tt = E:register_t("decal_item_loot_box_statue", "decal_item_loot_box_chest")
    tt.render.sprites[1].prefix = "item_loot_box_statue"
    tt.render.sprites[1].scale = vec_1(1)
    tt = E:register_t("decal_item_loot_box_floor", "decal_tween")
    tt.render.sprites[1].name = "item_loot_box_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 255}, {2, 255}, {2.5, 0}}
    tt.tween.remove = true
    tt.tween.disabled = false
    tt = E:register_t("decal_item_second_breath", "decal_timed")
    tt.render.sprites[1].name = "item_second_breath_decal_idle"
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("taunts_s15_controller")

    E:add_comps(tt, "main_script", "taunts", "editor")

    tt.load_file = "level15_taunts"
    tt.main_script.insert = scripts.taunts_controller.insert
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
    tt.render.sprites[3].offset = vec_2(13, -13)
    tt.texts.list[1].text = "Hello world"
    tt.texts.list[1].size = vec_2(158, 56)
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
    tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
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
    tt.render.sprites[1].offset = vec_2(-2, 5)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "overseer_fx_overseer_teleportdecal"
    tt.render.sprites[2].name = "decalactivate"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].loop = true
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].offset = vec_2(-2, 5)
    tt.duration = 2.8
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
    tt = E:register_t("decal_stage_16_overseer_blood", "decal_scripted")
    tt.main_script.update = scripts.decal_stage_16_overseer_blood.update
    tt.blood_pos = {vec_2(20, 20), vec_2(100, 100), vec_2(-100, 100), vec_2(-150, -30), vec_2(150, -70), vec_2(-30, 40)}
    tt.fx_template = "decal_stage_16_overseer_single_blood_fx"
    tt = E:register_t("decal_stage_16_overseer_single_blood_fx", "decal_tween")
    tt.render.sprites[1].name = "overseer_fx_overseer_blood"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt.render.sprites[1].offset = vec_2(20, 20)
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
    tt = E:register_t("debug_path_renderer", "decal_scripted")

    E:add_comps(tt, "editor", "editor_script")

    tt.render.sprites[1].z = Z_BACKGROUND + 1
    tt.path_debug = {}
    tt.path_debug.background_color = {255, 255, 255, 0}
    tt.path_debug.path_color = {255, 0, 0, 0}
    tt.main_script.update = scripts.debug_path_renderer.insert
    tt.editor_script.update = scripts.debug_path_renderer.editor_update
    tt = E:register_t("tool_auto_player", "decal_scripted")
    tt.auto_player = {}
    tt.auto_player.enemies = {{"enemy_hog_invader", "enemy_tusked_brawler", "enemy_turtle_shaman",
                               "enemy_bear_vanguard", "enemy_cutthroat_rat", "enemy_dreadeye_viper",
                               "enemy_surveyor_harpy", "enemy_skunk_bombardier", "enemy_hyena5", "enemy_rhino"},
                              {"enemy_acolyte", "enemy_lesser_sister", "enemy_lesser_sister_nightmare",
                               "enemy_unblinded_priest", "enemy_small_stalker", "enemy_unblinded_abomination",
                               "enemy_spiderling", "enemy_unblinded_shackler", "enemy_crystal_golem",
                               "enemy_corrupted_stalker"},
                              {"enemy_unblinded_abomination", "enemy_glareling", "enemy_blinker", "enemy_mindless_husk",
                               "enemy_vile_spawner", "enemy_noxious_horror", "enemy_hardened_horror",
                               "enemy_evolving_scourge", "enemy_amalgam"}}
    tt.auto_player.excluded_towers = {"tower_arborean_sentinels", "tower_stage_13_sunray", "decal_stage_11_veznan"}
    tt.auto_player.spawn_enemy_interval = 1
    tt.auto_player.tower_update_interval = 1
    tt.auto_player.tower_sell_chance = 0.05
    tt.main_script.insert = scripts.tool_auto_player.insert
    tt.main_script.update = scripts.tool_auto_player.update
    tt = E:register_t("decal_debug_range", "decal_rally_range")

    E:add_comps(tt, "timed", "main_script")

    tt.radius = nil
    tt.render.sprites[1].name = "range_circle"
    tt.render.sprites[2].name = "range_circle"
    tt.render.sprites[3].name = "range_circle"
    tt.render.sprites[4].name = "range_circle"
    tt.timed.duration = 1
    tt.timed.runs = nil

    function tt.main_script.insert(this, store)
        for i = 1, 4 do
            this.render.sprites[i].scale.x = (i % 2 == 0 and -1 or 1) * this.radius / this.actual_radius
            this.render.sprites[i].scale.y = (i > 2 and -1 or 1) * ASPECT * this.radius / this.actual_radius
            this.render.sprites[i].ts = store.tick_ts
        end

        return true
    end

    function tt.main_script.update(this, store)
        log.info("Updating")
    end

    tt = E:register_t("screen_focus_circle", "decal_scripted")

    E:add_comps(tt, "tween")

    tt.render.sprites[1].z = Z_EFFECTS
    tt.main_script.insert = scripts.screen_focus_circle.insert
    tt.main_script.update = scripts.screen_focus_circle.update
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {fts(30), 255}}
    tt.circle_pos = vec_2(512, 384)
    tt.circle_radius = 120
    tt.circle_gradient_size = 60
    tt.black_opacity = 140
    tt = E:register_t("stage_01_tower_build_indicator", "decal_tween")
    tt.render.sprites[1].name = "tutorial_floor_circle_glow_big"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].offset.y = 10
    tt.render.sprites[1].z = Z_TOWER_BASES
    tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "stage1_tutorial_hand_indicator"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].offset.y = 90
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{0, 0}, {fts(5), 255}}
    tt.tween.disabled = false
    tt.tween.remove = false
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
    tt = E:register_t("stage_01_dead_enemy_indicator", "decal_tween")
    tt.render.sprites[1].name = "tutorial_floor_circle_glow"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}, {fts(90), 255}, {fts(120), 0}}
    tt.tween.disabled = false
    tt.tween.remove = true
    tt = E:register_t("stage_01_drag_tutorial", "decal_tween")

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.stage_01_drag_tutorial.update
    tt.render.sprites[1].prefix = "drag_tutorialDef"
    tt.render.sprites[1].name = "action"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt.render.sprites[1].alpha = 0
    tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
    tt.tween.disabled = true
    tt.tween.reverse = true
    tt.tween.remove = false
    tt.time_limit = 10
    tt = E:register_t("decal_entity_marker_soldier_med", "decal_entity_marker_soldier_small")
    tt.render.sprites[1].scale = vec_1(1.7)
    tt = E:register_t("decal_entity_marker_soldier_big", "decal_entity_marker_soldier_small")
    tt.render.sprites[1].scale = vec_1(2)
    tt = E:register_t("decal_entity_marker_hero_small", "decal_entity_marker_soldier_small")
    tt.render.sprites[1].name = "selected_hero_small"
    tt = E:register_t("decal_entity_marker_hero_med", "decal_entity_marker_hero_small")
    tt.render.sprites[1].scale = vec_1(1.7)
    tt = E:register_t("decal_entity_marker_hero_big", "decal_entity_marker_hero_small")
    tt.render.sprites[1].scale = vec_1(2)
    tt = E:register_t("background_sounds_kr5", "background_sounds")
    tt.main_script.update = scripts.background_sounds_kr5.update
    tt.min_delay = 7
    tt.max_delay = 13
    tt.only_on_preparation = true
    tt = E:register_t("tower_holder")

    E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "editor", "editor_script")

    tt.ui.click_rect = r(-40, -12, 80, 50)
    tt.ui.has_nav_mesh = true
    tt.tower.level = 1
    tt.tower.type = "holder"
    tt.tower.can_be_mod = false
    tt.tower_holder.preview_ids = {
        rocket_gunners = 13,
        royal_archers = 8,
        ray = 18,
        demon_pit = 11,
        necromancer = 14,
        arborean_emissary = 9,
        flamespitter = 3,
        ballista = 5,
        barrel = 15,
        sand = 16,
        elven_stargazers = 12,
        ghost = 17,
        tricannon = 6,
        paladin_covenant = 7,
        arcane_wizard = 4
    }
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_holders_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[1].z = Z_TOWER_BASES
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "terrains_holders_%04i_flag"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].offset = vec_2(0, 13)
    tt.render.sprites[2].sort_y_offset = 13
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].name = "dwarven_flamespitter_tower_preview"
    tt.render.sprites[3].offset = vec_2(0, 15)
    tt.render.sprites[3].alpha = 180
    tt.render.sprites[3].hidden = true
    tt.render.sprites[3].animated = false
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].name = "arcane_wizard_tower_preview"
    tt.render.sprites[4].offset = vec_2(0, 7)
    tt.render.sprites[5] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[5].name = "ballista_tower_preview"
    tt.render.sprites[5].offset = vec_2(0, 15)
    tt.render.sprites[6] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[6].name = "tower_preview_tricannon"
    tt.render.sprites[6].offset = vec_2(0, 0)
    tt.render.sprites[7] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[7].name = "paladin_covenant_preview"
    tt.render.sprites[7].offset = vec_2(0, 9)
    tt.render.sprites[8] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[8].name = "royal_archer_tower_preview"
    tt.render.sprites[8].offset = vec_2(0, 15)
    tt.render.sprites[9] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[9].name = "arborean_emissary_tower_preview"
    tt.render.sprites[9].offset = vec_2(3, 8)
    tt.render.sprites[10] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[10].name = "arcane_wizard_tower_preview"
    tt.render.sprites[10].offset = vec_2(0, 7)
    tt.render.sprites[11] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[11].name = "demon_pit_tower_preview"
    tt.render.sprites[11].offset = vec_2(0, 15)
    tt.render.sprites[12] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[12].name = "elven_stargazers_tower_preview"
    tt.render.sprites[12].offset = vec_2(0, 15)
    tt.render.sprites[13] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[13].name = "rocket_gunners_tower_preview"
    tt.render.sprites[13].offset = vec_2(0, 15)
    tt.render.sprites[14] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[14].name = "necromancer_tower_preview"
    tt.render.sprites[14].offset = vec_2(0, 15)
    tt.render.sprites[15] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[15].name = "barrel_tower_preview"
    tt.render.sprites[15].offset = vec_2(0, 15)
    tt.render.sprites[16] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[16].name = "tower_sand_preview"
    tt.render.sprites[16].offset = vec_2(0, 15)
    tt.render.sprites[17] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[17].name = "ghost_tower_preview"
    tt.render.sprites[17].offset = vec_2(0, 15)
    tt.render.sprites[18] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[18].name = "channeler_tower_preview"
    tt.render.sprites[18].offset = vec_2(0, 10)
    tt.editor.props = {{"tower.terrain_style", PT_NUMBER}, {"tower.default_rally_pos", PT_COORDS},
                       {"tower.holder_id", PT_STRING}, {"ui.nav_mesh_id", PT_STRING}, {"editor.game_mode", PT_NUMBER}}
    tt.editor_script.insert = scripts.editor_tower.insert
    tt.editor_script.remove = scripts.editor_tower.remove
    tt = E:register_t("tower_holder_capture", "tower_holder")

    E:add_comps(tt, "main_script", "tween")

    tt.main_script.insert = scripts.tower_holder_capture.insert
    tt.aura_capture = "aura_tower_holder_capture"
    tt.ui.can_click = false
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "buildbar_bg"
    tt.render.sprites[2].offset = vec_2(0, 50)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].animated = false
    tt.render.sprites[3].name = "buildbar"
    tt.render.sprites[3].offset = vec_2(-21, 50)
    tt.render.sprites[3].anchor = vec_2(0, 0.5)
    tt.capture_duration = 15
    tt.enable_waves = {}
    tt.spawn_delay = 0

    table.insert(tt.editor.props, {"enable_waves"})
    table.insert(tt.editor.props, {"spawn_delay"})
    table.insert(tt.editor.props, {"capture_duration"})

    tt.tween.props[1].name = "scale"
    tt.tween.props[1].keys = {{0, vec_2(0, 1)}, {nil, vec_2(1, 1)}}
    tt.tween.props[1].sprite_id = 3
    tt.tween.remove = false
    tt = E:register_t("tower_holder_sea_of_trees", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES
    tt.render.sprites[1].name = "terrains_holders_0001"
    tt.render.sprites[2].name = "terrains_holders_0001_flag"
    tt = E:register_t("tower_holder_sea_of_trees_2", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_2
    tt.render.sprites[1].name = "terrains_holders_0002"
    tt.render.sprites[2].name = "terrains_holders_0002_flag"
    tt = E:register_t("tower_holder_sea_of_trees_3", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_3
    tt.render.sprites[1].name = "terrains_holders_0003"
    tt.render.sprites[2].name = "terrains_holders_0003_flag"
    tt = E:register_t("tower_holder_sea_of_trees_4", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_4
    tt.render.sprites[1].name = "terrains_holders_0004"
    tt.render.sprites[2].name = "terrains_holders_0004_flag"
    tt = E:register_t("tower_holder_sea_of_trees_5", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES_5
    tt.render.sprites[1].name = "terrains_holders_0005"
    tt.render.sprites[2].name = "terrains_holders_0005_flag"
    tt = E:register_t("tower_holder_sea_of_trees_capture", "tower_holder_capture")
    tt.tower.terrain_style = TERRAIN_STYLE_SEA_OF_TREES
    tt.render.sprites[1].name = "build_terrain_capture_0001"
    tt.enabled_sprite = "build_terrain_capture_0002"
    tt.disabled_sprite = "build_terrain_capture_0001"
    tt.tower_holder_on_capture = "tower_holder_sea_of_trees"
    tt = E:register_t("tower_holder_blocked")

    E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "sound_events", "editor")

    tt.tower.level = 1
    tt.tower.can_be_mod = false
    tt.tower_holder.blocked = true
    tt.tower.can_be_sold = false
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_holders_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "terrains_holders_%04i_flag"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].offset = vec_2(0, 13)
    tt.render.sprites[2].sort_y_offset = 13
    tt.ui.click_rect = r(-40, -12, 80, 46)
    tt.sound_events.remove = "GUITowerSell"
    tt = E:register_t("tower_holder_blocked_sea_of_trees", "tower_holder_blocked")
    b = balance.specials.trees.blocked_holders
    tt.tower.type = "holder_blocked_sea_of_trees"
    tt.tower_holder.unblock_price = b.price
    tt.render.sprites[1].name = "terrains_holders_0007"
    tt.render.sprites[2].name = "terrains_holders_0007_flag"
    tt = E:register_t("tower_holder_blocked_sea_of_trees_2", "tower_holder_blocked")
    b = balance.specials.trees.blocked_holders
    tt.tower.type = "holder_blocked_sea_of_trees"
    tt.tower_holder.unblock_price = b.price
    tt.render.sprites[1].name = "terrains_holders_0006"
    tt.render.sprites[2].name = "terrains_holders_0006_flag"
    tt = E:register_t("tower_holder_blocked_terrain_2", "tower_holder_blocked")
    b = balance.specials.terrain_2.blocked_holders
    tt.tower.type = "holder_blocked_sea_of_trees"
    tt.tower_holder.unblock_price = b.price
    tt.render.sprites[1].name = "terrains_holders_0008"
    tt.render.sprites[2].name = "terrains_holders_0008_flag"
    tt = E:register_t("tower_holder_blocked_terrain_3", "tower_holder_blocked")
    b = balance.specials.terrain_3.blocked_holders
    tt.tower.type = "holder_blocked_sea_of_trees"
    tt.tower_holder.unblock_price = b.price
    tt.render.sprites[1].name = "terrains_holders_0009"
    tt.render.sprites[2].name = "terrains_holders_0009_flag"
    tt = E:register_t("tower_build_paladin_covenant", "tower_build")
    tt.build_name = "tower_paladin_covenant_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "paladin_covenant_build"
    tt.render.sprites[2].offset = vec_2(0, 9)
    tt.render.sprites[3].offset.y = 62
    tt.render.sprites[4].offset.y = 62
    tt = E:register_t("tower_build_arcane_wizard", "tower_build")
    tt.build_name = "tower_arcane_wizard_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[2].name = "arcane_wizard_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 7)
    tt.render.sprites[3].offset.y = 62
    tt.render.sprites[4].offset.y = 62
    tt = E:register_t("tower_build_tricannon", "tower_build")
    tt.build_name = "tower_tricannon_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2].name = "tricannon_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[3].offset.y = 65
    tt.render.sprites[4].offset.y = 65
    tt = E:register_t("tower_build_royal_archers", "tower_build")
    tt.build_name = "tower_royal_archers_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 14)
    tt.render.sprites[2].name = "royal_archer_tower_build"
    tt.render.sprites[2].offset = vec_2(2, 14)
    tt.render.sprites[3].offset.y = 62
    tt.render.sprites[4].offset.y = 62
    tt = E:register_t("tower_build_viper_goblins", "tower_build")
    tt.build_name = "tower_viper_goblins_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2].name = "build_archer"
    tt.render.sprites[2].offset = vec_2(0, 26)
    tt = E:register_t("tower_build_arborean_emissary", "tower_build")
    tt.build_name = "tower_arborean_emissary_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2].name = "arborean_emissary_tower_build"
    tt.render.sprites[2].offset = vec_2(3, 8)
    tt.render.sprites[3].offset.y = 62
    tt.render.sprites[4].offset.y = 62
    tt = E:register_t("tower_build_elder_portal", "tower_build")
    tt.build_name = "tower_elder_portal_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2].name = "build_mage"
    tt.render.sprites[2].offset = vec_2(0, 24)
    tt = E:register_t("tower_build_demon_pit", "tower_build")
    tt.build_name = "tower_demon_pit_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "demon_pit_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 66
    tt.render.sprites[4].offset.y = 66
    tt = E:register_t("tower_build_elven_stargazers", "tower_build")
    tt.build_name = "tower_elven_stargazers_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "elven_stargazers_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 65
    tt.render.sprites[4].offset.y = 65
    tt = E:register_t("tower_build_rocket_gunners", "tower_build")
    tt.build_name = "tower_rocket_gunners_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "rocket_gunners_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 65
    tt.render.sprites[4].offset.y = 65
    tt = E:register_t("tower_build_necromancer", "tower_build")
    tt.build_name = "tower_necromancer_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "necromancer_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 62
    tt.render.sprites[4].offset.y = 62
    tt = E:register_t("tower_build_ballista", "tower_build")
    tt.build_name = "tower_ballista_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "ballista_tower_tower_construction"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 75
    tt.render.sprites[4].offset.y = 75
    tt = E:register_t("tower_build_flamespitter", "tower_build")
    tt.build_name = "tower_flamespitter_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "dwarven_flamespitter_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 65
    tt.render.sprites[4].offset.y = 65
    tt = E:register_t("tower_build_barrel", "tower_build")
    tt.build_name = "tower_barrel_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "barrel_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 60
    tt.render.sprites[4].offset.y = 60
    tt = E:register_t("tower_build_sand", "tower_build")
    tt.build_name = "tower_sand_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "tower_sand_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 60
    tt.render.sprites[4].offset.y = 60
    tt = E:register_t("tower_build_ghost", "tower_build")
    tt.build_name = "tower_ghost_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "ghost_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 60
    tt.render.sprites[4].offset.y = 60
    tt = E:register_t("tower_build_ray", "tower_build")
    tt.build_name = "tower_ray_lvl1"
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2].name = "channeler_tower_build"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3].offset.y = 60
    tt.render.sprites[4].offset.y = 60
    tt = E:register_t("tower_KR5", "tower")

    E:add_comps(tt, "tower_upgrade_persistent_data")

    tt = E:register_t("tower_royal_archers_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    b = balance.towers.royal_archers
    tt.tower.type = "royal_archers"
    tt.tower.kind = TOWER_KIND_ARCHER
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.portrait = "portraits_towers" .. "_0002"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0002_0001"
    tt.info.enc_icon = 1
    tt.info.i18n_key = "TOWER_ROYAL_ARCHERS_1"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0002"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 14)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "royal_archer_tower_lvl1_tower"
    tt.render.sprites[2].offset = vec_2(2, 14)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "royal_archer_tower_royal_archer_lvl1"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idle_2", "idle_1"}
    tt.render.sprites[3].angles.shoot = {"attack_2", "attack_1"}
    tt.render.sprites[3].offset = vec_2(-9, 39)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset = vec_2(13, 38)
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "royal_archer_tower_lvl1_tower_front"
    tt.render.sprites[5].offset = vec_2(2, 14)
    tt.main_script.insert = scripts.tower_archer.insert
    tt.main_script.update = scripts.tower_royal_archers.update
    tt.main_script.remove = scripts.tower_royal_archers.remove
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].bullet = "tower_royal_archers_arrow_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].bullet_start_offset = {vec_2(11, 18), vec_2(12, 22)}
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.sound_events.insert = "TowerRoyalArchersTaunt"
    tt.sound_events.tower_room_select = "TowerRoyalArchersTauntSelect"
    tt.ui.click_rect = r(-30, 3, 63, 62)
    tt = E:register_t("tower_royal_archers_lvl2", "tower_royal_archers_lvl1")
    b = balance.towers.royal_archers
    tt.info.enc_icon = 5
    tt.info.i18n_key = "TOWER_ROYAL_ARCHERS_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.render.sprites[2].name = "royal_archer_tower_lvl2_tower"
    tt.render.sprites[3].prefix = "royal_archer_tower_royal_archer_lvl2"
    tt.render.sprites[3].offset = vec_2(-9, 45)
    tt.render.sprites[4].prefix = "royal_archer_tower_royal_archer_lvl2"
    tt.render.sprites[4].offset = vec_2(13, 44)
    tt.render.sprites[5].name = "royal_archer_tower_lvl2_tower_front"
    tt.attacks.list[1].bullet = "tower_royal_archers_arrow_lvl2"
    tt.attacks.list[1].bullet_start_offset = {vec_2(11, 18), vec_2(12, 22)}
    tt.attacks.range = b.basic_attack.range[2]
    tt.ui.click_rect = r(-30, 3, 63, 67)
    tt = E:register_t("tower_royal_archers_lvl3", "tower_royal_archers_lvl1")
    b = balance.towers.royal_archers
    tt.info.enc_icon = 9
    tt.info.i18n_key = "TOWER_ROYAL_ARCHERS_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.tower.size = TOWER_SIZE_LARGE
    tt.render.sprites[2].name = "royal_archer_tower_lvl3_tower"
    tt.render.sprites[3].prefix = "royal_archer_tower_royal_archer_lvl3"
    tt.render.sprites[3].offset = vec_2(-9, 51)
    tt.render.sprites[4].prefix = "royal_archer_tower_royal_archer_lvl3"
    tt.render.sprites[4].offset = vec_2(13, 50)
    tt.render.sprites[5].name = "royal_archer_tower_lvl3_tower_front"
    tt.attacks.list[1].bullet = "tower_royal_archers_arrow_lvl3"
    tt.attacks.list[1].bullet_start_offset = {vec_2(11, 18), vec_2(12, 22)}
    tt.attacks.range = b.basic_attack.range[3]
    tt.ui.click_rect = r(-32, 3, 67, 72)
    tt = E:register_t("tower_royal_archers_lvl4", "tower_royal_archers_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.royal_archers
    image_y = 90
    tt.info.enc_icon = 18
    tt.info.i18n_key = "TOWER_ROYAL_ARCHERS_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 25)
    tt.tower.size = TOWER_SIZE_LARGE
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "tower_royal_archers_arrow_lvl4"
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].bullet_start_offset = {vec_2(11, 18), vec_2(12, 22)}
    tt.attacks.list[2] = E:clone_c("bullet_attack")
    tt.attacks.list[2].animation = "armor_piercer"
    tt.attacks.list[2].bullet = "arrow_armor_piercer_royal_archers"
    tt.attacks.list[2].range_trigger = b.armor_piercer.range_trigger
    tt.attacks.list[2].range_effect = b.armor_piercer.range_effect
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].shoot_time = fts(53)
    tt.attacks.list[2].time_between_arrows = fts(0)
    tt.attacks.list[2].nearby_range = b.armor_piercer.nearby_range
    tt.attacks.list[2].bullet_start_offset = {vec_2(6, 20), vec_2(0, 20)}
    tt.attacks.list[2].shot_fx = "fx_arrow_silver_sentence_shot"
    tt.attacks.list[2].sound = "TowerRoyalArchersArmorPiercerShot"
    tt.attacks.list[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
    tt.attacks.range = b.basic_attack.range[4]
    tt.powers.armor_piercer = E:clone_c("power")
    tt.powers.armor_piercer.attack_idx = 2
    tt.powers.armor_piercer.price = b.armor_piercer.price
    tt.powers.armor_piercer.cooldown = b.armor_piercer.cooldown
    tt.powers.armor_piercer.enc_icon = 3
    tt.powers.armor_piercer.flight_time_factor = {0.2, 0.4, 0.6}
    tt.powers.rapacious_hunter = E:clone_c("power")
    tt.powers.rapacious_hunter.attack_idx = 3
    tt.powers.rapacious_hunter.price = b.rapacious_hunter.price
    tt.powers.rapacious_hunter.enc_icon = 4
    tt.powers.rapacious_hunter.damage_max = b.rapacious_hunter.damage_max
    tt.powers.rapacious_hunter.damage_min = b.rapacious_hunter.damage_min
    tt.powers.rapacious_hunter.entity = "tower_royal_archers_pow_rapacious_hunter_tamer"
    tt.powers.rapacious_hunter.entity_offset = vec_2(31, 7)
    tt.powers.rapacious_hunter.purchase_fx = "fx_tower_royal_archer_rapacious_hunter_dust"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 14)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "royal_archer_tower_lvl4_tower"
    tt.render.sprites[2].offset = vec_2(1, 13)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "royal_archer_tower_royal_archer_lvl4"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idle_2", "idle_1"}
    tt.render.sprites[3].angles.shoot = {"attack_2", "attack_1"}
    tt.render.sprites[3].offset = vec_2(-12, 54)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset = vec_2(14, 54)
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "royal_archer_tower_lvl4_tower_front"
    tt.render.sprites[5].offset = vec_2(1, 13)
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].name = "royal_archer_tower_lvl4_tower_rapacious_hunter_base"
    tt.render.sprites[6].animated = false
    tt.render.sprites[6].offset = vec_2(1, 13)
    tt.render.sprites[6].hidden = true
    tt.render.sprites[6].draw_order = 2
    tt.sid_rapacious_hunter = 6
    tt.sound_events.insert = "TowerRoyalArchersTaunt"
    tt.ui.click_rect = r(-35, 3, 73, 77)
    tt = E:register_t("tower_royal_archers_arrow_hit_fx", "fx")
    tt.render.sprites[1].name = "royal_archer_tower_royal_archer_hit_fx_hit_fx"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt = E:register_t("tower_royal_archers_pow_armor_piercer_arrow_hit_fx", "fx")
    tt.render.sprites[1].name = "royal_archer_tower_royal_archer_lvl4_armor_breaker_hit_fx_armor_breaker_hit_fx"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt = E:register_t("tower_royal_archers_pow_rapacious_hunter_tamer", "decal_scripted")

    E:add_comps(tt, "pos", "main_script", "attacks")

    b = balance.towers.royal_archers
    tt.render.sprites[1].prefix = "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_tamer"
    tt.render.sprites[1].name = "idle_1"
    tt.render.sprites[1].offset = vec_2(0, 0)
    tt.render.sprites[1].sort_y_offset = -13
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].z = Z_OBJECTS
    tt.main_script.update = scripts.tower_royal_archers_pow_rapacious_hunter_tamer.update
    tt.min_cheer_cooldown = 1
    tt.max_time_without_cheer = 9
    tt.cheer_chance = 1
    tt.attacks.list[1] = E:clone_c("custom_attack")
    tt.attacks.list[1].animation = "leave"
    tt.attacks.list[1].range = b.rapacious_hunter.range
    tt.attacks.list[1].cooldown = b.rapacious_hunter.cooldown
    tt.attacks.list[1].entity = "tower_royal_archers_pow_rapacious_hunter"
    tt.attacks.list[1].bullet_start_offset = {vec_2(9, 4), vec_2(6, -5)}
    tt.attacks.list[1].cast_time = fts(7)
    tt.attacks.list[1].sound = "TowerGoldenBowFlareShot"
    tt.attacks.list[1].entity = "tower_royal_archers_pow_rapacious_hunter_eagle"
    tt.attacks.list[1].mark_mod = "tower_royal_archers_pow_rapacious_hunter_tamer_mark_mod"
    tt.attacks.list[1].mark_mod_duration = 1e+99
    tt.attacks.list[1].vis_flags = bor(F_MOD, F_CUSTOM, F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_CUSTOM, F_NIGHTMARE)
    tt.idle = {}
    tt.idle.min_cooldown = 4
    tt.idle.max_cooldown = 10
    tt.idle.animation = "idle_2"
    tt = E:register_t("tower_royal_archers_pow_rapacious_hunter_eagle", "decal_scripted")

    E:add_comps(tt, "pos", "main_script", "attacks", "force_motion", "tween", "sound_events")

    b = balance.towers.royal_archers
    tt.flight_speed = 45
    tt.flight_height = 27
    tt.flight_height_max = 60
    tt.owner_offset = vec_2(10, 0)
    tt.owner_flight_height = 27
    tt.offset_x_after_hit = 51
    tt.attack_accel = 600
    tt.max_speed = 600
    tt.min_speed = 300
    tt.return_accel = 180
    tt.main_script.update = scripts.tower_royal_archers_pow_rapacious_hunter_eagle.update
    tt.main_script.remove = scripts.tower_royal_archers_pow_rapacious_hunter_eagle.remove
    tt.max_distance_from_tower = b.rapacious_hunter.max_distance_from_tower
    tt.min_distance_to_attack = 60
    tt.orbital_speed = 100
    tt.attacks.list[1] = E:clone_c("custom_attack")
    tt.attacks.list[1].damage_min = b.rapacious_hunter.damage_min
    tt.attacks.list[1].damage_max = b.rapacious_hunter.damage_max
    tt.attacks.list[1].cooldown = b.rapacious_hunter.attack_cooldown
    tt.attacks.list[1].max_attacks = b.rapacious_hunter.max_attacks
    tt.attacks.list[1].hit_fx = "tower_royal_archers_pow_rapacious_hunter_eagle_hit_fx"
    tt.attacks.list[1].damage_type = DAMAGE_PHYSICAL
    tt.attacks.list[1].vis_flags = F_RANGED
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].sound = "TowerRoyalArchersRapaciousHunterHit"
    tt.attacks.list[1].trail = "ps_rapacious_hunter_eagle_royal_archers"
    tt.render.sprites[1].prefix = "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_eagle"
    tt.render.sprites[1].offset = vec_2(0, 0)
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].scale = vec_1(0.7)
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].keys = {{0, vec_2(0.75, 1)}, {fts(10), vec_2(1, 1)}}
    tt.tween.props[2].name = "scale"
    tt.sound_events.insert = "TowerRoyalArchersRapaciousHunterTakeOff"
    tt.sound_events.descend = "TowerRoyalArchersRapaciousHunterDescend"
    tt = E:register_t("tower_royal_archers_pow_rapacious_hunter_eagle_hit_fx", "fx")
    tt.render.sprites[1].name =
        "royal_archer_tower_royal_archer_lvl4_rapacious_hunter_eagle_hit_fx_rapacious_hunter_hit_fx"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt = E:register_t("tower_royal_archers_pow_rapacious_hunter_tamer_mark_mod", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_CUSTOM
    tt.main_script.queue = scripts.mod_mark_flags.queue
    tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
    tt.main_script.update = scripts.tower_royal_archers_pow_rapacious_hunter_tamer_mark_mod.update

    local b = balance.towers.arcane_wizard

    tt = E:register_t("tower_arcane_wizard_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    tt.tower.type = "arcane_wizard"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.enc_icon = 3
    tt.info.i18n_key = "TOWER_ARCANE_WIZARD_1"
    tt.info.portrait = "portraits_towers" .. "_0003"
    tt.info.fn = scripts.tower_arcane_wizard.get_info
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0003"
    tt.main_script.insert = scripts.tower_arcane_wizard.insert
    tt.main_script.update = scripts.tower_arcane_wizard.update
    tt.main_script.remove = scripts.tower_arcane_wizard.remove
    tt.attacks.range = b.basic_attack.range
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "tower_arcane_wizard_ray"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(15)
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 80), vec_2(0, 80)}
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)

    for i = 2, 6 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arcane_wizard_tower_lvl1_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 5)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
    end

    tt.render.sid_shooter = 5
    tt.shooter_offset = vec_2(0, 35)
    tt.sound_events.insert = "TowerArcaneWizardTaunt"
    tt.sound_events.tower_room_select = "TowerArcaneWizardTauntSelect"
    tt.ui.click_rect = r(-30, 0, 60, 65)
    tt = E:register_t("tower_arcane_wizard_lvl2", "tower_arcane_wizard_lvl1")
    tt.info.enc_icon = 7
    tt.info.i18n_key = "TOWER_ARCANE_WIZARD_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 88), vec_2(0, 88)}

    for i = 2, 11 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arcane_wizard_tower_lvl2_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 5)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
    end

    tt.render.sid_shooter = 10
    tt.ui.click_rect = r(-35, 0, 70, 70)
    tt = E:register_t("tower_arcane_wizard_lvl3", "tower_arcane_wizard_lvl1")
    tt.info.enc_icon = 11
    tt.info.i18n_key = "TOWER_ARCANE_WIZARD_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 90), vec_2(0, 90)}

    for i = 2, 7 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arcane_wizard_tower_lvl3_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 5)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
    end

    tt.render.sid_shooter = 6
    tt.ui.click_rect = r(-37, 0, 74, 72)
    tt = E:register_t("tower_arcane_wizard_lvl4", "tower_KR5")

    E:add_comps(tt, "attacks", "powers", "vis")

    image_y = 90
    tt.tower.type = "arcane_wizard"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.size = TOWER_SIZE_LARGE
    tt.tower.menu_offset = vec_2(0, 25)
    tt.info.enc_icon = 15
    tt.info.i18n_key = "TOWER_ARCANE_WIZARD_4"
    tt.info.fn = scripts.tower_arcane_wizard.get_info
    tt.info.portrait = "portraits_towers" .. "_0003"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0003_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0003"
    tt.info.damage_icon = "magic"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.powers.disintegrate = CC("power")
    tt.powers.disintegrate.price = b.disintegrate.price
    tt.powers.disintegrate.cooldown = b.disintegrate.cooldown
    tt.powers.disintegrate.enc_icon = 5
    tt.powers.empowerment = CC("power")
    tt.powers.empowerment.price = b.empowerment.price
    tt.powers.empowerment.damage_factor = b.empowerment.damage_factor
    tt.powers.empowerment.cooldown = b.empowerment.cooldown
    tt.powers.empowerment.duration = b.empowerment.duration
    tt.powers.empowerment.enc_icon = 6
    tt.powers.empowerment.name = "empowerment"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)

    for i = 2, 9 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arcane_wizard_tower_lvl4_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 5)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
        tt.render.sprites[i].angles.skill1 = {"skill1_back", "skill1"}
        tt.render.sprites[i].angles.skill2 = {"skill2_back", "skill2"}
    end

    tt.render.sid_shooter = 8
    tt.main_script.update = scripts.tower_arcane_wizard.update
    tt.main_script.remove = scripts.tower_arcane_wizard.remove
    tt.sound_events.insert = "TowerArcaneWizardTaunt"
    tt.sound_events.tower_room_select = "TowerArcaneWizardTauntSelect"
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "tower_arcane_wizard_ray"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(15)
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 98), vec_2(0, 98)}
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[2].animation = "skill1"
    tt.attacks.list[2].bullet = "tower_arcane_wizard_ray_disintegrate"
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].vis_flags = bor(F_DISINTEGRATED)
    tt.attacks.list[2].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[2].shoot_time = fts(31)
    tt.attacks.list[2].load_time = fts(13)
    tt.attacks.list[2].sound = "TowerArcaneWizardDisintegrate"
    tt.attacks.list[2].excluded_templates = {"enemy_overseer_hit_point"}
    tt.attacks.list[3] = CC("custom_attack")
    tt.attacks.list[3].animation = "skill2"
    tt.attacks.list[3].shoot_time = fts(20)
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].mod = "mod_tower_arcane_wizard_power_empowerment"
    tt.attacks.list[3].mod_fx = "mod_tower_arcane_wizard_power_empowerment_fx"
    tt.attacks.list[3].mark_mod = "tower_arcane_wizard_power_empowerment_mark_mod"
    tt.attacks.list[3].max_range = b.empowerment.max_range
    tt.attacks.list[3].min_range = b.empowerment.min_range
    tt.attacks.list[3].exclude_tower_kind = {}
    tt.attacks.list[3].vis_flags = bor(F_MOD, F_CUSTOM)
    tt.attacks.list[3].vis_bans = bor(F_CUSTOM)
    tt.ui.click_rect = r(-40, 0, 80, 86)
    tt = E:register_t("tower_arcane_wizard_ray_disintegrate_mod", "modifier")

    local b = balance.towers.arcane_wizard

    tt.main_script.update = scripts.tower_arcane_wizard_ray_disintegrate_mod.update
    tt.modifier.pop = {"pop_zap_arcane"}
    tt.modifier.pop_conds = DR_KILL
    tt.modifier.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_IGNORE_SHIELD)
    tt.modifier.damage = 1
    tt.modifier.duration = fts(5)
    tt.boss_damage_config = b.disintegrate.boss_damage

    local b = balance.towers.elven_stargazers

    tt = E:register_t("tower_elven_stargazers_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    tt.tower.type = "elven_stargazers"
    tt.tower.kind = TOWER_KIND_ENGINEER
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(3, 19)
    tt.info.enc_icon = 3
    tt.info.i18n_key = "TOWER_STARGAZER_1"
    tt.info.portrait = "portraits_towers" .. "_0007"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0008_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_0007"
    tt.info.fn = scripts.tower_stargazers.get_info
    tt.main_script.update = scripts.tower_stargazers.update
    tt.main_script.remove = scripts.tower_stargazers.remove
    tt.attacks.range = b.basic_attack.range
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "tower_elven_stargazers_ray"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(15)
    tt.attacks.list[1].ray_timing = b.basic_attack.ray_timing
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].sound = "TowerElvenStargazersBasicAttack"

    local base_scale = vec_2(1.1, 1.1)

    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "elven_stargazers_tower_lvl1_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 15)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].sort_y_offset = 5
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
        tt.render.sprites[i].scale = base_scale
    end

    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].prefix = "elven_stargazers_tower_ray_start_lvl3_lvl2_lvl1"
    tt.render.sprites[5].name = "start"
    tt.render.sprites[5].hidden = true
    tt.render.sprites[5].offset = vec_2(3 * base_scale.x, 65 * base_scale.y)
    tt.render.sprites[5].z = Z_BULLETS + 1
    tt.render.sprites[5].scale = base_scale
    tt.render.moon_sid = 5
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].prefix = "elven_stargazers_tower_lvl1_elf"
    tt.render.sprites[6].name = "idle"
    tt.render.sprites[6].offset = vec_2(4, 33)
    tt.render.sprites[6].scale = base_scale
    tt.render.elf_sid = 6
    tt.shooter_offset = vec_2(0, 35)
    tt.sound_events.insert = "TowerElvenStargazersTaunt"
    tt.sound_events.tower_room_select = "TowerElvenStargazersTauntSelect"
    tt.attacks.list[1].bullet_start_offset = {tt.render.sprites[tt.render.moon_sid].offset,
                                              tt.render.sprites[tt.render.moon_sid].offset}
    tt.ui.click_rect = r(-35, 0, 72, 65)
    tt = E:register_t("tower_elven_stargazers_lvl2", "tower_elven_stargazers_lvl1")
    b = balance.towers.elven_stargazers
    tt.info.i18n_key = "TOWER_STARGAZER_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(3, 22)
    tt.attacks.range = b.basic_attack.range[2]

    local base_scale = vec_2(1.1, 1.1)

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "elven_stargazers_tower_lvl2_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 14)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
        tt.render.sprites[i].scale = base_scale
    end

    tt.render.sprites[5].offset = vec_2(3.3 * base_scale.x, 73 * base_scale.y)
    tt.render.sprites[5].scale = base_scale
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].prefix = "elven_stargazers_tower_lvl2_elf"
    tt.render.sprites[6].name = "idle"
    tt.render.sprites[6].offset = vec_2(4, 32)
    tt.render.sprites[6].scale = base_scale
    tt.render.elf_sid = 6
    tt.attacks.list[1].bullet_start_offset = {tt.render.sprites[tt.render.moon_sid].offset,
                                              tt.render.sprites[tt.render.moon_sid].offset}
    tt.ui.click_rect = r(-36, 0, 75, 83)
    tt = E:register_t("tower_elven_stargazers_lvl3", "tower_elven_stargazers_lvl1")
    b = balance.towers.elven_stargazers
    tt.info.i18n_key = "TOWER_STARGAZER_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(3, 30)
    tt.attacks.range = b.basic_attack.range[3]

    local base_scale = vec_2(1.05, 1.05)

    for i = 2, 7 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "elven_stargazers_tower_lvl3_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 14)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
        tt.render.sprites[i].scale = base_scale
    end

    tt.render.sprites[8] = E:clone_c("sprite")
    tt.render.sprites[8].prefix = "elven_stargazers_tower_ray_start_lvl3_lvl2_lvl1"
    tt.render.sprites[8].name = "start"
    tt.render.sprites[8].hidden = true
    tt.render.sprites[8].z = Z_BULLETS + 1
    tt.render.sprites[8].offset = vec_2(3.3 * base_scale.x, 82 * base_scale.y)
    tt.render.sprites[8].scale = base_scale
    tt.render.moon_sid = 8
    tt.render.sprites[9] = E:clone_c("sprite")
    tt.render.sprites[9].prefix = "elven_stargazers_tower_lvl3_elf"
    tt.render.sprites[9].name = "idle"
    tt.render.sprites[9].offset = vec_2(2.5, 33)
    tt.render.sprites[9].scale = base_scale
    tt.render.elf_sid = 9
    tt.attacks.list[1].bullet_start_offset = {tt.render.sprites[tt.render.moon_sid].offset,
                                              tt.render.sprites[tt.render.moon_sid].offset}
    tt.ui.click_rect = r(-37, 0, 80, 86)
    tt = E:register_t("tower_elven_stargazers_lvl4", "tower_elven_stargazers_lvl1")

    local b = balance.towers.elven_stargazers

    E:add_comps(tt, "powers")

    tt.info.i18n_key = "TOWER_STARGAZER_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.damage_icon = "magic"
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(3, 28)
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet_start_offset = {vec_2(3, 85.7), vec_2(3, 85.7)}
    tt.powers.teleport = CC("power")
    tt.powers.teleport.price = b.teleport.price
    tt.powers.teleport.cooldown = b.teleport.cooldown
    tt.powers.teleport.teleport_nodes_back = b.teleport.teleport_nodes_back
    tt.powers.teleport.enc_icon = 13
    tt.powers.teleport.name = "teleport"
    tt.powers.teleport.key = "EVENT_HORIZON"
    tt.powers.stars_death = CC("power")
    tt.powers.stars_death.price = b.stars_death.price
    tt.powers.stars_death.enc_icon = 14
    tt.powers.stars_death.name = "stars_death"
    tt.powers.stars_death.key = "RISING_STAR"

    for i = 2, 9 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "elven_stargazers_tower_lvl4_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 14)
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].angles = {}
        tt.render.sprites[i].angles.idle = {"idle_back", "idle"}
        tt.render.sprites[i].angles.attack = {"attack_back", "attack"}
    end

    tt.render.sprites[10] = E:clone_c("sprite")
    tt.render.sprites[10].prefix = "elven_stargazers_tower_ray_start_lvl3_lvl2_lvl1"
    tt.render.sprites[10].name = "start"
    tt.render.sprites[10].hidden = true
    tt.render.sprites[10].z = Z_BULLETS + 1
    tt.render.sprites[10].offset = vec_2(3, 88.7)
    tt.render.moon_sid = 10
    tt.render.sprites[11] = E:clone_c("sprite")
    tt.render.sprites[11].prefix = "elven_stargazers_tower_lvl4_elf"
    tt.render.sprites[11].name = "idle"
    tt.render.sprites[11].offset = vec_2(3, 35)
    tt.render.elf_sid = 11
    tt.render.sprites[12] = E:clone_c("sprite")
    tt.render.sprites[12].prefix = "elven_stargazers_tower_event_horizon_tower_fx"
    tt.render.sprites[12].name = "idle"
    tt.render.sprites[12].hidden = true
    tt.render.sprites[12].offset = vec_2(3, 85.7)
    tt.render.teleport_sid = 12
    tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[2].animation = "skill1"
    tt.attacks.list[2].mod = "mod_tower_stargazers_teleport_stun"
    tt.attacks.list[2].fx = "fx_tower_stargazers_teleport_middle"
    tt.attacks.list[2].enemy_fx_small = "fx_tower_stargazers_teleport_enemy_small"
    tt.attacks.list[2].enemy_fx_big = "fx_tower_stargazers_teleport_enemy_big"
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].vis_flags = bor(F_TELEPORT)
    tt.attacks.list[2].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
    tt.attacks.list[2].shoot_time = fts(31)
    tt.attacks.list[2].load_time = fts(13)
    tt.attacks.list[2].teleport_nodes_back = b.teleport.teleport_nodes_back
    tt.attacks.list[2].max_targets = b.teleport.max_targets
    tt.attacks.list[2].sound_cast = "TowerElvenStargazersEventHorizonCast"
    tt.attacks.list[2].sound_teleport_out = "TowerElvenStargazersEventHorizonTeleportOut"
    tt.attacks.list[2].sound_teleport_in = "TowerElvenStargazersEventHorizonTeleportIn"
    tt.attacks.list[3] = CC("custom_attack")
    tt.attacks.list[3].animation = "skill2"
    tt.attacks.list[3].mod = "mod_tower_elven_stargazers_star_death"
    tt.ui.click_rect = r(-40, 0, 85, 93)
    tt = E:register_t("soldier_tower_ghost_lvl1", "soldier_militia")

    E:add_comps(tt, "nav_grid")

    b = balance.towers.ghost
    tt.info.portrait = "gui_bottom_info_image_soldiers_0040"
    tt.info.random_name_count = 18
    tt.info.random_name_format = "SOLDIER_GHOST_TOWER"
    tt.unit.blood_color = BLOOD_RED
    tt.main_script.update = scripts.tower_ghost.soldier_update
    tt.main_script.insert = scripts.tower_ghost.soldier_insert
    tt.render.sprites[1].prefix = "ghost_tower_lvl1_unit"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.unit.hit_offset = vec_2(0, 12)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.health.hp_max = b.soldier.hp[1]
    tt.health.armor = b.soldier.armor[1]
    tt.health_bar.offset = vec_2(0, 33)
    tt.health.dead_lifetime = b.soldier.dead_lifetime
    tt.regen.health = b.soldier.regen_hp[1]
    tt.motion.max_speed = b.soldier.speed
    tt.particle = "ps_soldier_tower_ghost"
    tt.melee.range = b.soldier.basic_attack.range
    tt.melee.attacks[1].cooldown = b.soldier.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[1]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[1]
    tt.melee.attacks[1].hit_time = fts(16)
    tt.melee.attacks[1].damage_type = b.soldier.basic_attack.damage_type
    tt.melee.attacks[1].hit_decal = "decal_soldier_tower_ghost_hit"
    tt.melee.attacks[1].hit_offset = vec_2(30, 20)
    tt.soldier.melee_slot_spread = vec_2(-8, -8)
    tt.sound_events.death = "TowerGhostSoulAttackTravel"
    tt.ui.click_rect = r(-10, 2, 20, 27)
    tt = E:register_t("soldier_tower_ghost_lvl2", "soldier_tower_ghost_lvl1")
    b = balance.towers.ghost
    tt.info.portrait = "gui_bottom_info_image_soldiers_0041"
    tt.render.sprites[1].prefix = "ghost_tower_lvl2_unit"
    tt.health.hp_max = b.soldier.hp[2]
    tt.health_bar.offset = vec_2(0, 35)
    tt.health.armor = b.soldier.armor[2]
    tt.regen.health = b.soldier.regen_hp[2]
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[2]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[2]
    tt = E:register_t("soldier_tower_ghost_lvl3", "soldier_tower_ghost_lvl1")
    b = balance.towers.ghost
    tt.info.portrait = "gui_bottom_info_image_soldiers_0042"
    tt.render.sprites[1].prefix = "ghost_tower_lvl3_unit"
    tt.health.hp_max = b.soldier.hp[3]
    tt.health_bar.offset = vec_2(0, 38)
    tt.health.armor = b.soldier.armor[3]
    tt.regen.health = b.soldier.regen_hp[3]
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[3]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[3]
    tt = E:register_t("soldier_tower_ghost_lvl4", "soldier_tower_ghost_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.ghost
    tt.info.portrait = "gui_bottom_info_image_soldiers_0043"
    tt.render.sprites[1].prefix = "ghost_tower_lvl4_unit"
    tt.health.hp_max = b.soldier.hp[4]
    tt.health_bar.offset = vec_2(0, 40)
    tt.health.armor = b.soldier.armor[4]
    tt.regen.health = b.soldier.regen_hp[4]
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[4]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[4]
    tt.ui.click_rect = r(-12, 2, 24, 30)
    tt.powers.soul_attack = E:clone_c("power")
    tt.powers.extra_damage = E:clone_c("power")
    tt.powers.extra_damage.damages = b.extra_damage.damage_factor
    tt.soul = "soul_soldier_tower_ghost_lvl4"
    tt.mod_extra_damage = "mod_tower_ghost_increase_damage_factor"
    tt.extra_damage_cooldown = b.extra_damage.cooldown_start
    tt = E:register_t("soul_soldier_tower_ghost_lvl4", "decal_scripted")
    tt.main_script.update = scripts.tower_ghost.soul_update
    b = balance.towers.ghost.soul_attack
    tt.render.sprites[1].prefix = "ghost_tower_soul_skill"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hidden = true
    tt.damage_min = b.damage_min
    tt.damage_max = b.damage_max
    tt.delay = fts(16)
    tt.radius = b.range
    tt.bullet = "bolt_soul_soldier_tower_ghost"
    tt = E:register_t("tower_paladin_covenant_soldier_lvl1", "soldier_militia")

    E:add_comps(tt, "nav_grid")

    b = balance.towers.paladin_covenant
    tt.info.portrait = "gui_bottom_info_image_soldiers_0001"
    tt.info.random_name_count = 18
    tt.info.random_name_format = "SOLDIER_PALADINS_%i_NAME"
    tt.main_script.update = scripts.tower_paladin_covenant.soldier_update
    tt.main_script.insert = scripts.tower_paladin_covenant.soldier_insert
    tt.render.sprites[1].prefix = "paladin_soldiers_lvl1"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.unit.hit_offset = vec_2(0, 12)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.health.hp_max = b.soldier.hp[1]
    tt.health.armor = b.soldier.armor[1]
    tt.health_bar.offset = vec_2(0, 30)
    tt.health.dead_lifetime = b.soldier.dead_lifetime
    tt.regen.health = b.soldier.regen_hp[1]
    tt.motion.max_speed = b.soldier.speed
    tt.melee.range = b.soldier.basic_attack.range
    tt.melee.attacks[1].cooldown = b.soldier.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[1]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[1]
    tt.melee.attacks[1].hit_time = fts(10)
    tt.soldier.melee_slot_spread = vec_2(-8, -8)
    tt.sound_events.death = "TowerPaladinCovenantUnitDeath"
    tt.ui.click_rect = r(-10, -2, 20, 25)
    tt = E:register_t("tower_paladin_covenant_soldier_lvl2", "tower_paladin_covenant_soldier_lvl1")
    tt.info.portrait = "gui_bottom_info_image_soldiers_0002"
    tt.render.sprites[1].prefix = "paladin_soldiers_lvl2"
    tt.health.hp_max = b.soldier.hp[2]
    tt.health.armor = b.soldier.armor[2]
    tt.regen.health = b.soldier.regen_hp[2]
    tt.motion.max_speed = b.soldier.speed
    tt.melee.range = b.soldier.basic_attack.range
    tt.melee.attacks[1].cooldown = b.soldier.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[2]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[2]
    tt.melee.attacks[1].hit_time = fts(10)
    tt = E:register_t("tower_paladin_covenant_soldier_lvl3", "tower_paladin_covenant_soldier_lvl1")
    tt.info.portrait = "gui_bottom_info_image_soldiers_0003"
    tt.render.sprites[1].prefix = "paladin_soldiers_lvl3"
    tt.health.hp_max = b.soldier.hp[3]
    tt.health.armor = b.soldier.armor[3]
    tt.health_bar.offset = vec_2(0, 30)
    tt.regen.health = b.soldier.regen_hp[3]
    tt.idle_flip.animations = {"idle", "idle2"}
    tt.motion.max_speed = b.soldier.speed
    tt.melee.range = b.soldier.basic_attack.range
    tt.melee.attacks[1].cooldown = b.soldier.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[3]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[3]
    tt.melee.attacks[1].hit_time = fts(11)
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4", "tower_paladin_covenant_soldier_lvl1")

    E:add_comps(tt, "powers", "timed_attacks")

    b = balance.towers.paladin_covenant
    tt.info.portrait = "gui_bottom_info_image_soldiers_0004"
    tt.render.sprites[1].prefix = "paladin_soldier_lvl4"
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.idle_flip.animations = {"idle"}
    tt.health.hp_max = b.soldier.hp[4]
    tt.health.armor = b.soldier.armor[4]
    tt.health_bar.offset = vec_2(0, 35)
    tt.regen.health = b.soldier.regen_hp[4]
    tt.motion.max_speed = b.soldier.speed
    tt.ui.click_rect = r(-15, -2, 30, 35)
    tt.powers.lead = E:clone_c("power")
    tt.powers.lead.b = b.lead.soldier_veteran
    tt.powers.lead.sprite_prefix = "paladin_soldiers_lvl4_captain_soldier"
    tt.powers.lead.health_bar_size = HEALTH_BAR_SIZE_MEDIUM
    tt.powers.lead.cooldown = b.lead.soldier_veteran.aura_cooldown
    tt.powers.lead.animation_upgrade = "raise"
    tt.powers.lead.hit_time = fts(12)
    tt.powers.lead.portrait = "gui_bottom_info_image_soldiers_0005"
    tt.powers.healing_prayer = E:clone_c("power")
    tt.powers.healing_prayer.health_trigger_factor = b.healing_prayer.health_trigger_factor
    tt.powers.healing_prayer.cooldown = b.healing_prayer.cooldown
    tt.melee.range = b.soldier.basic_attack.range
    tt.melee.attacks[1].animation = "attack01"
    tt.melee.attacks[1].cooldown = b.soldier.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.basic_attack.damage_min[4]
    tt.melee.attacks[1].damage_max = b.soldier.basic_attack.damage_max[4]
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[1].hit_time = fts(9)
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "attack02"
    tt.melee.attacks[2].chance = 0.5
    tt.melee.attacks[2].hit_time = fts(8)
    tt.timed_attacks.list[1] = E:clone_c("mod_attack")
    tt.timed_attacks.list[1].animation = "healing"
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].hit_time = {fts(10), fts(9)}
    tt.timed_attacks.list[1].lost_health = nil
    tt.timed_attacks.list[1].duration = b.healing_prayer.duration
    tt.timed_attacks.list[1].mods = {"tower_paladin_covenant_soldier_lvl4_healing_mod",
                                     "tower_paladin_covenant_soldier_lvl4_healing_mod_fx"}
    tt.timed_attacks.list[1].sound = "TowerPaladinCovenantHealingPrayer"
    tt.timed_attacks.list[2] = E:clone_c("aura_attack")
    tt.timed_attacks.list[2].animation = "armor"
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].hit_time = fts(8)
    tt.timed_attacks.list[2].enemies_trigger_range = 90
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[2].aura_name = "tower_paladin_covenant_soldier_lvl4_lead_aura"
    tt.timed_attacks.list[2].fx = "tower_paladin_covenant_soldier_lvl4_lead_aura_fx"
    tt.soldier.melee_slot_offset = vec_2(8, 0)
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_healing_mod", "modifier")

    E:add_comps(tt, "hps", "render")

    b = balance.towers.paladin_covenant
    tt.modifier.duration = b.healing_prayer.duration
    tt.modifier.resets_same = false
    tt.hps.heal_min = b.healing_prayer.heal
    tt.hps.heal_max = b.healing_prayer.heal
    tt.hps.heal_every = b.healing_prayer.heal_every

    function tt.main_script.insert(this, store, script)
        this.hps.heal_min = this.hps.heal_min[this.modifier.level]
        this.hps.heal_max = this.hps.heal_max[this.modifier.level]

        return scripts.mod_hps.insert(this, store, script)
    end

    tt.main_script.update = scripts.mod_hps.update
    tt.main_script.remove = scripts.tower_paladin_covenant_soldier_lvl4_healing_mod.remove
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_healing_mod_fx", "modifier")

    E:add_comps(tt, "render", "tween")

    b = balance.towers.paladin_covenant
    tt.modifier.duration = b.healing_prayer.duration
    tt.modifier.resets_same = false
    tt.modifier.use_mod_offset = false
    tt.render.sprites[1].name = "paladin_soldier_lvl4_healing_halo"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].animated = false
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].loop = false
    tt.render.sprites[2].name = "paladin_soldier_lvl4_healing_glow_0010"
    tt.render.sprites[2].sort_y_offset = 1
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].name = "paladin_soldiers_lvl4_healing_plusSymbol"
    tt.render.sprites[3].loop = true
    tt.render.sprites[3].animated = true
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {fts(4), 255}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{0, 0}, {fts(4), 255}}
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[3] = E:clone_c("tween_prop")
    tt.tween.props[3].name = "alpha"
    tt.tween.props[3].keys = {{0, 0}, {fts(4), 255}}
    tt.tween.props[3].sprite_id = 3
    tt.tween.remove = false
    tt.main_script.update = scripts.mod_track_fx.update
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_lead_aura", "aura")

    E:add_comps(tt)

    tt.aura.mods = {"tower_paladin_covenant_soldier_lvl4_lead_aura_mod",
                    "tower_paladin_covenant_soldier_lvl4_lead_aura_mod_fx"}
    tt.aura.cycles = 1
    tt.aura.radius = b.lead.soldier_veteran.aura_range
    tt.aura.track_source = true
    tt.aura.vis_bans = bor(F_ENEMY)
    tt.aura.vis_flags = F_MOD
    tt.aura.use_mod_offset = false
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.sound_events.insert = "TowerPaladinCovenantLeadByExample"
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_lead_aura_mod", "modifier")
    b = balance.towers.paladin_covenant
    tt.modifier.duration = b.lead.soldier_veteran.aura_duration
    tt.modifier.use_mod_offset = false
    tt.inflicted_damage_factor = b.lead.soldier_veteran.aura_damage_buff_factor
    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_lead_aura_mod_fx", "modifier")

    E:add_comps(tt, "render", "tween")

    tt.modifier.duration = b.lead.soldier_veteran.aura_duration
    tt.modifier.use_mod_offset = false
    tt.render.sprites[1].name = "paladin_soldiers_lvl4_captain_armor_mod_decal"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {1, 255}}
    tt.tween.remove = false
    tt.main_script.update = scripts.mod_track_fx.update
    tt = E:register_t("tower_paladin_covenant_soldier_lvl4_lead_aura_fx", "fx")
    tt.render.sprites[1].name = "paladin_soldiers_lvl4_captain_armor_decal_start"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "paladin_soldiers_lvl4_captain_armor_buff"
    tt.render.sprites[2].loop = false
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].hide_after_runs = 1
    tt = E:register_t("tower_paladin_covenant_lvl1", "tower_KR5")

    E:add_comps(tt, "barrack", "vis")

    tt.tower.type = "paladin_covenant"
    tt.tower.kind = TOWER_KIND_BARRACK
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.i18n_key = "TOWER_PALADIN_COVENANT_1"
    tt.info.portrait = "portraits_towers_0001"
    tt.info.enc_icon = 2
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0001"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "paladin_covenant_lvl1"
    tt.render.sprites[2].offset = vec_2(0, 9)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "paladin_covenant_lvl123_door"
    tt.render.sprites[3].name = "close"
    tt.render.sprites[3].loop = false
    tt.render.sprites[3].offset = vec_2(0, 7)
    tt.barrack.soldier_type = "tower_paladin_covenant_soldier_lvl1"
    tt.barrack.rally_range = b.rally_range
    tt.barrack.respawn_offset = vec_2(0, 9)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.info.fn = scripts.tower_paladin_covenant.get_info
    tt.main_script.insert = scripts.tower_barrack.insert
    tt.main_script.update = scripts.tower_barrack.update
    tt.main_script.remove = scripts.tower_barrack.remove
    tt.sound_events.insert = "TowerPaladinCovenantTaunt"
    tt.sound_events.change_rally_point = "TowerPaladinCovenantTaunt"
    tt.sound_events.tower_room_select = "TowerPaladinCovenantTauntSelect"
    tt.ui.click_rect = r(-40, 0, 80, 70)
    tt = E:register_t("tower_paladin_covenant_lvl2", "tower_paladin_covenant_lvl1")
    tt.info.enc_icon = 6
    tt.info.i18n_key = "TOWER_PALADIN_COVENANT_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 21)
    tt.render.sprites[2].name = "paladin_covenant_lvl2"
    tt.barrack.soldier_type = "tower_paladin_covenant_soldier_lvl2"
    tt.ui.click_rect = r(-40, 0, 80, 70)
    tt = E:register_t("tower_paladin_covenant_lvl3", "tower_paladin_covenant_lvl1")
    tt.info.enc_icon = 10
    tt.info.i18n_key = "TOWER_PALADIN_COVENANT_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.render.sprites[2].name = "paladin_covenant_lvl3"
    tt.barrack.soldier_type = "tower_paladin_covenant_soldier_lvl3"
    tt.ui.click_rect = r(-40, 0, 80, 80)
    tt = E:register_t("tower_paladin_covenant_lvl4", "tower_paladin_covenant_lvl1")

    E:add_comps(tt, "powers")

    tt.info.portrait = "portraits_towers_0001"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0001_0001"
    tt.info.enc_icon = 20
    tt.info.i18n_key = "TOWER_PALADIN_COVENANT_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.tower.price = b.price[4]
    tt.tower.level = 4
    tt.tower.menu_offset = vec_2(0, 25)
    tt.powers.lead = E:clone_c("power")
    tt.powers.lead.price = b.lead.price
    tt.powers.lead.enc_icon = 2
    tt.powers.lead.max_level = 1
    tt.powers.healing_prayer = E:clone_c("power")
    tt.powers.healing_prayer.price = b.healing_prayer.price
    tt.powers.healing_prayer.enc_icon = 1
    tt.barrack.soldier_type = "tower_paladin_covenant_soldier_lvl4"
    tt.barrack.rally_range = b.rally_range
    tt.render.sprites[2].name = "paladin_covenant_lvl4"
    tt.render.sprites[3].prefix = "paladin_covenant_lvl4_door"
    tt.render.sprites[3].offset = vec_2(0, 10)
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].name = "paladin_covenant_lvl4_flag"
    tt.render.sprites[4].offset = vec_2(0, 9)
    tt.sound_events.insert = "TowerPaladinCovenantTaunt"
    tt.sound_events.change_rally_point = "TowerPaladinCovenantTaunt"
    tt.ui.click_rect = r(-42, 0, 84, 90)
    tt = E:register_t("tower_ghost_lvl1", "tower_KR5")
    b = balance.towers.ghost

    E:add_comps(tt, "barrack", "vis", "tower_upgrade_persistent_data")

    tt.tower.type = "ghost"
    tt.tower.kind = TOWER_KIND_BARRACK
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.fn = scripts.tower_ghost.get_info
    tt.info.i18n_key = "TOWER_GHOST_1"
    tt.info.portrait = "portraits_towers_0016"
    tt.info.enc_icon = 16
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0015_0001"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "ghost_tower_lvl1_tower"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "ghost_tower_lvl1_tower_shadow_fx"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].loop = true
    tt.render.sprites[3].offset = vec_2(0, 15)
    tt.render.sprites[3].fps = 20
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "ghost_tower_lvl1_tower_spawn_fx"
    tt.render.sprites[4].name = "idle"
    tt.render.sprites[4].loop = false
    tt.render.sprites[4].hidden = true
    tt.render.sprites[4].offset = vec_2(2, 15)
    tt.barrack.soldier_type = "soldier_tower_ghost_lvl1"
    tt.barrack.rally_range = b.rally_range
    tt.barrack.respawn_offset = vec_2(0, 15)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.main_script.insert = scripts.tower_barrack.insert
    tt.main_script.update = scripts.tower_ghost.update
    tt.main_script.remove = scripts.tower_barrack.remove
    tt.sound_events.insert = "TowerGhostTaunt"
    tt.sound_events.change_rally_point = "TowerGhostTaunt"
    tt.sound_events.tower_room_select = "TowerGhostTauntSelect"
    tt.sound_events.spawn_unit = "TowerGhostSpawnUnit"
    tt.ui.click_rect = r(-35, 0, 70, 65)
    tt = E:register_t("tower_ghost_lvl2", "tower_ghost_lvl1")
    b = balance.towers.ghost
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.info.i18n_key = "TOWER_GHOST_2"
    tt.barrack.respawn_offset = vec_2(0, 28)
    tt.tower.menu_offset = vec_2(0, 27)
    tt.barrack.soldier_type = "soldier_tower_ghost_lvl2"
    tt.render.sprites[2].name = "ghost_tower_lvl2_tower"
    tt.render.sprites[2].offset = vec_2(0, 20)
    tt.render.sprites[3].prefix = "ghost_tower_lvl2_tower_shadow_fx"
    tt.render.sprites[3].offset = vec_2(0, 19)
    tt.render.sprites[4].prefix = "ghost_tower_lvl2_tower_spawn_fx"
    tt.render.sprites[4].offset = vec_2(0, 19)
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt = E:register_t("tower_ghost_lvl3", "tower_ghost_lvl1")
    b = balance.towers.ghost
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.info.i18n_key = "TOWER_GHOST_3"
    tt.barrack.respawn_offset = vec_2(0, 35)
    tt.tower.menu_offset = vec_2(0, 30)
    tt.barrack.soldier_type = "soldier_tower_ghost_lvl3"
    tt.render.sprites[2].name = "ghost_tower_lvl3_tower"
    tt.render.sprites[2].offset = vec_2(0, 20)
    tt.render.sprites[3].prefix = "ghost_tower_lvl3_tower_shadow_fx"
    tt.render.sprites[3].offset = vec_2(0, 20)
    tt.render.sprites[4].prefix = "ghost_tower_lvl3_tower_spawn_fx"
    tt.render.sprites[4].offset = vec_2(0, 20)
    tt.ui.click_rect = r(-35, 0, 70, 90)
    tt = E:register_t("tower_ghost_lvl4", "tower_ghost_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.ghost
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.info.i18n_key = "TOWER_GHOST_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.barrack.respawn_offset = vec_2(0, 40)
    tt.tower.menu_offset = vec_2(0, 30)
    tt.barrack.soldier_type = "soldier_tower_ghost_lvl4"
    tt.render.sprites[2].name = "ghost_tower_lvl4_tower"
    tt.render.sprites[2].offset = vec_2(0, 18)
    tt.render.sprites[3].prefix = "ghost_tower_lvl4_tower_shadow_fx"
    tt.render.sprites[3].offset = vec_2(0, 16)
    tt.render.sprites[4].prefix = "ghost_tower_lvl4_tower_spawn_fx"
    tt.render.sprites[4].offset = vec_2(0, 18)
    tt.ui.click_rect = r(-35, 0, 70, 90)
    tt.powers.extra_damage = E:clone_c("power")
    tt.powers.extra_damage.price = b.extra_damage.price
    tt.powers.extra_damage.enc_icon = 25
    tt.powers.soul_attack = E:clone_c("power")
    tt.powers.soul_attack.price = b.soul_attack.price
    tt.powers.soul_attack.enc_icon = 26
    tt = E:register_t("tower_tricannon_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    b = balance.towers.tricannon
    tt.tower.type = "tricannon"
    tt.tower.kind = TOWER_KIND_ENGINEER
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 18)
    tt.info.portrait = "portraits_towers_0004"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0006"
    tt.info.enc_icon = 4
    tt.info.i18n_key = "TOWER_TRICANNON_1"
    tt.main_script.insert = scripts.tower_engineer.insert
    tt.main_script.update = scripts.tower_tricannon.update
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].bullet = "tower_tricannon_bomb_1"
    tt.attacks.list[1].bomb_amount = b.basic_attack.bomb_amount[1]
    tt.attacks.list[1].time_between_bombs = b.basic_attack.time_between_bombs
    tt.attacks.list[1].range = b.basic_attack.range[1]
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(39)
    tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 45), vec_2(-14, 36), vec_2(14, 36)}
    tt.attacks.list[1].node_prediction = true
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].random_x_to_dest = 30
    tt.attacks.list[1].random_y_to_dest = 20
    tt.attacks.list[1].sound = "TowerTricannonBasicAttackFire"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)

    for i = 2, 8 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "tricannon_tower_lvl1_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
    end

    tt.sound_events.insert = "TowerTricannonTaunt"
    tt.ui.click_rect = r(-40, -3, 80, 55)
    tt = E:register_t("tower_tricannon_lvl2", "tower_tricannon_lvl1")
    tt.info.enc_icon = 8
    tt.info.i18n_key = "TOWER_TRICANNON_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "tower_tricannon_bomb_2"
    tt.attacks.list[1].bomb_amount = b.basic_attack.bomb_amount[2]
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 59), vec_2(-14, 50), vec_2(14, 50)}
    tt.attacks.list[1].range = b.basic_attack.range[2]

    for i = 2, 8 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "tricannon_tower_lvl2_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
    end

    tt.ui.click_rect = r(-40, -3, 80, 62)
    tt = E:register_t("tower_tricannon_lvl3", "tower_tricannon_lvl1")
    tt.info.enc_icon = 12
    tt.info.i18n_key = "TOWER_TRICANNON_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 19)
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "tower_tricannon_bomb_3"
    tt.attacks.list[1].bomb_amount = b.basic_attack.bomb_amount[3]
    tt.attacks.list[1].bullet_start_offset = {vec_2(0, 59), vec_2(-14, 50), vec_2(14, 50)}
    tt.attacks.list[1].range = b.basic_attack.range[3]

    for i = 2, 8 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "tricannon_tower_lvl3_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
    end

    tt.ui.click_rect = r(-40, -3, 80, 70)
    tt = E:register_t("tower_tricannon_lvl4", "tower_KR5")

    E:add_comps(tt, "attacks", "powers", "vis")

    image_y = 120
    tt.tower.type = "tricannon"
    tt.tower.kind = TOWER_KIND_ENGINEER
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.size = TOWER_SIZE_LARGE
    tt.tower.menu_offset = vec_2(0, 24)
    tt.info.enc_icon = 13
    tt.info.i18n_key = "TOWER_TRICANNON_4"
    tt.info.portrait = "portraits_towers_0004"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0004_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0006"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.powers.bombardment = E:clone_c("power")
    tt.powers.bombardment.price = b.bombardment.price
    tt.powers.bombardment.enc_icon = 7
    tt.powers.bombardment.cooldown = b.bombardment.cooldown
    tt.powers.bombardment.damage_min = b.bombardment.damage_min
    tt.powers.bombardment.damage_max = b.bombardment.damage_max
    tt.powers.bombardment.bomb_amount = b.bombardment.bomb_amount
    tt.powers.overheat = CC("power")
    tt.powers.overheat.price = b.overheat.price
    tt.powers.overheat.enc_icon = 8
    tt.powers.overheat.cooldown = b.overheat.cooldown
    tt.powers.overheat.duration = b.overheat.duration
    tt.main_script.update = scripts.tower_tricannon.update
    tt.sound_events.insert = "TowerTricannonTaunt"
    tt.sound_events.tower_room_select = "TowerTricannonTauntSelect"
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].bullet = "tower_tricannon_bomb_4"
    tt.attacks.list[1].bullet_overheated = "tower_tricannon_bomb_overheated"
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
    tt.attacks.list[2].bullet_overheated = "tower_tricannon_bombardment_overheated_bomb"
    tt.attacks.list[2].bullet_start_offset = {vec_2(0, 71)}
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].bomb_amount = nil
    tt.attacks.list[2].node_prediction = fts(25)
    tt.attacks.list[2].range = b.bombardment.range
    tt.attacks.list[2].vis_flags = bor(F_MOD, F_RANGED)
    tt.attacks.list[2].time_between_bombs_min = 3
    tt.attacks.list[2].time_between_bombs_max = 9
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
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)

    for i = 2, 11 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "tricannon_tower_lvl4_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
    end

    tt.ui.click_rect = r(-45, -3, 90, 78)
    tt = E:register_t("tower_tricannon_overheat_scorch_aura", "aura")

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "tower_tricannon_overheat_scorch_aura_mod"
    tt.aura.duration = b.overheat.decal.duration
    tt.aura.cycle_time = 0.3
    tt.aura.radius = b.overheat.decal.radius
    tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
    tt.aura.vis_flags = bor(F_MOD)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.render.sprites[1].name = "tricannon_tower_fissure_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].sort_y_offset = 2
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "tricannon_tower_overheat_fire_fx"
    tt.render.sprites[2].z = Z_DECALS
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}, {"this.aura.duration-0.5", 255}, {"this.aura.duration", 0}}
    tt.tween.props[1].loop = false
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].loop = true
    tt.tween.props[2].keys = {{0, 0}, {0.5, 255}, {1, 0}}
    tt = E:register_t("tower_tricannon_overheat_scorch_aura_mod", "modifier")

    E:add_comps(tt, "dps", "render")

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
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt = E:register_t("tower_arborean_emissary_lvl1", "tower_KR5")
    b = balance.towers.arborean_emissary

    E:add_comps(tt, "attacks", "vis")

    tt.tower.type = "arborean_emissary"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 19)
    tt.info.enc_icon = 3
    tt.info.i18n_key = "TOWER_ARBOREAN_EMISSARY_1"
    tt.info.portrait = "portraits_towers" .. "_0005"
    tt.info.fn = scripts.tower_mage.get_info
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0005"
    tt.main_script.insert = scripts.tower_mage.insert
    tt.main_script.update = scripts.tower_arborean_emissary.update
    tt.attacks.range = b.basic_attack.range
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "tower_arborean_emissary_bolt_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].max_range = b.basic_attack.range
    tt.attacks.list[1].shoot_time = fts(20)
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 23)
    tt.attacks.list[1].node_prediction = 0
    tt.attacks.list[1].sound = "TowerArboreanEmissaryBasicAttack"
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arborean_emissary_lvl1_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 10)
        tt.render.sprites[i].group = "layers"
    end

    tt.sound_events.insert = "TowerArboreanEmissaryTaunt"
    tt.animation_idles = {"idle_2"}
    tt.tower.long_idle_cooldown_min = 4
    tt.tower.long_idle_cooldown_max = 8
    tt.ui.click_rect = r(-35, 0, 70, 60)
    tt = E:register_t("tower_arborean_emissary_lvl2", "tower_arborean_emissary_lvl1")
    tt.info.enc_icon = 7
    tt.info.i18n_key = "TOWER_ARBOREAN_EMISSARY_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "tower_arborean_emissary_bolt_lvl2"

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arborean_emissary_lvl2_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 10)
        tt.render.sprites[i].group = "layers"
    end

    tt.ui.click_rect = r(-37, 0, 74, 62)
    tt = E:register_t("tower_arborean_emissary_lvl3", "tower_arborean_emissary_lvl1")
    tt.info.enc_icon = 11
    tt.info.i18n_key = "TOWER_ARBOREAN_EMISSARY_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "tower_arborean_emissary_bolt_lvl3"
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 22)

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arborean_emissary_lvl3_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 10)
        tt.render.sprites[i].group = "layers"
    end

    tt.ui.click_rect = r(-39, 0, 78, 64)
    tt = E:register_t("tower_arborean_emissary_lvl4", "tower_KR5")

    E:add_comps(tt, "attacks", "powers", "vis")

    image_y = 90
    tt.tower.type = "arborean_emissary"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.size = TOWER_SIZE_LARGE
    tt.tower.menu_offset = vec_2(0, 25)
    tt.info.enc_icon = 15
    tt.info.i18n_key = "TOWER_ARBOREAN_EMISSARY_4"
    tt.info.fn = scripts.tower_mage.get_info
    tt.info.portrait = "portraits_towers" .. "_0005"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0006_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0005"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.damage_icon = "magic"
    tt.powers.gift_of_nature = E:clone_c("power")
    tt.powers.gift_of_nature.price = b.gift_of_nature.price
    tt.powers.gift_of_nature.cooldown = b.gift_of_nature.cooldown
    tt.powers.gift_of_nature.aura_duration = b.gift_of_nature.duration
    tt.powers.gift_of_nature.enc_icon = 10
    tt.powers.gift_of_nature.name = "GIFT_OF_NATURE"
    tt.powers.wave_of_roots = E:clone_c("power")
    tt.powers.wave_of_roots.price = b.wave_of_roots.price
    tt.powers.wave_of_roots.count = b.wave_of_roots.count
    tt.powers.wave_of_roots.cooldown = b.wave_of_roots.cooldown
    tt.powers.wave_of_roots.damage_min = b.wave_of_roots.damage_min
    tt.powers.wave_of_roots.damage_max = b.wave_of_roots.damage_max
    tt.powers.wave_of_roots.enc_icon = 9
    tt.powers.wave_of_roots.name = "WAVE_OF_ROOTS"
    tt.ui.click_rect = r(-43, 0, 86, 68)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)

    for i = 2, 2 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "arborean_emissary_lvl4_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(3, 10)
        tt.render.sprites[i].group = "layers"
    end

    tt.main_script.update = scripts.tower_arborean_emissary.update
    tt.sound_events.insert = "TowerArboreanEmissaryTaunt"
    tt.sound_events.tower_room_select = "TowerArboreanEmissaryTauntSelect"
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "tower_arborean_emissary_bolt_lvl4"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].max_range = b.basic_attack.range
    tt.attacks.list[1].shoot_time = fts(20)
    tt.attacks.list[1].node_prediction = 1
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 23)
    tt.attacks.list[1].sound = "TowerArboreanEmissaryBasicAttack"
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[2] = E:clone_c("custom_attack")
    tt.attacks.list[2].animation = "gift_of_nature"
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].entity = "controller_tower_arborean_emissary_gift_of_nature"
    tt.attacks.list[2].cooldown = b.basic_attack.cooldown
    tt.attacks.list[2].max_range = b.gift_of_nature.max_range
    tt.attacks.list[2].shoot_time = fts(2)
    tt.attacks.list[2].min_soldiers = b.gift_of_nature.min_soldiers
    tt.attacks.list[2].min_enemies = b.gift_of_nature.min_enemies
    tt.attacks.list[2].vis_flags_soldier = bor(F_RANGED, F_FRIEND)
    tt.attacks.list[2].vis_bans_soldier = 0
    tt.attacks.list[2].vis_flags_enemy = bor(F_RANGED, F_ENEMY)
    tt.attacks.list[2].vis_bans_enemy = F_FLYING
    tt.attacks.list[2].node_prediction = fts(20)
    tt.attacks.list[2].check_melee_range = 50
    tt.attacks.list[2].sound = "TowerArboreanEmissaryGiftOfNature"
    tt.attacks.list[3] = E:clone_c("custom_attack")
    tt.attacks.list[3].animation = "thorny_garden"
    tt.attacks.list[3].shoot_time = fts(33)
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].node_prediction = fts(20)
    tt.attacks.list[3].damage_min = nil
    tt.attacks.list[3].damage_max = nil
    tt.attacks.list[3].damage_type = b.wave_of_roots.damage_type
    tt.attacks.list[3].min_targets = b.wave_of_roots.min_targets
    tt.attacks.list[3].max_targets = b.wave_of_roots.max_targets
    tt.attacks.list[3].trigger_range = b.wave_of_roots.trigger_range
    tt.attacks.list[3].effect_range = b.wave_of_roots.effect_range
    tt.attacks.list[3].mod = "tower_arborean_emissary_root_stun_mod"
    tt.attacks.list[3].mod_duration = b.wave_of_roots.mod_duration
    tt.attacks.list[3].wave_of_roots_balance = b.wave_of_roots
    tt.attacks.list[3].decal_on_grab = "tower_arborean_emissary_root_decal_on_grab"
    tt.attacks.list[3].vis_flags = bor(F_STUN, F_ENEMY)
    tt.attacks.list[3].vis_bans = bor(F_FLYING, F_BOSS, F_CLIFF, F_NIGHTMARE)
    tt.attacks.list[3].sound = "TowerArboreanEmissaryThornyGarden"
    tt.animation_idles = {"idle_2", "idle_3"}
    tt.tower.long_idle_cooldown_min = 4
    tt.tower.long_idle_cooldown_max = 8
    tt = E:register_t("tower_arborean_emissary_root_decal_on_grab", "decal_scripted")
    tt.main_script.update = scripts.tower_arborean_emissary_root_on_grab.update
    tt.render.sprites[1].prefix = "arborean_emissary_thorny_garden_thorns"
    tt.render.sprites[1].name = "run"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[1].sort_y_offset = -5
    tt.render.sprites[1].size_names = {"small", "big", "big"}
    tt.out_before = fts(18)
    tt.animation_start = "run"
    tt.animation_idle = "idle"
    tt.animation_end = "out"
    tt = E:register_t("tower_arborean_emissary_root_stun_mod", "mod_stun")
    tt.modifier.duration = nil
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)

    function tt.main_script.insert(this, store, script)
        this.modifier.duration = this.wave_of_roots.mod_duration[this.modifier.level]

        return scripts.mod_stun.insert(this, store, script)
    end

    tt = E:register_t("tower_demon_pit_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    b = balance.towers.demon_pit
    tt.tower.type = "demon_pit"
    tt.tower.kind = TOWER_KIND_BARRACK
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.portrait = "portraits_towers" .. "_0006"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0007_0001"
    tt.info.enc_icon = 4
    tt.info.i18n_key = "TOWER_DEMON_PIT_1"
    tt.info.fn = scripts.tower_demon_pit.get_info
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0004"
    tt.main_script.update = scripts.tower_demon_pit.update
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "demon_pit_tower_lvl1_tower_base"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].offset = vec_2(0, 15)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "demon_pit_tower_lvl1_tower_bubbles"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].offset = vec_2(0, 15)
    tt.render.sprites[3].animated = true
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "demon_pit_tower_lvl1_tower_demons"
    tt.render.sprites[4].name = "idle"
    tt.render.sprites[4].offset = vec_2(0, 15)
    tt.ui.click_rect = r(-30, 0, 60, 60)
    tt.sound_events.insert = "TowerDemonPitTaunt"
    tt.sound_events.tower_room_select = "TowerDemonPitTauntSelect"
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("custom_attack")
    tt.attacks.list[1].bullet = "bullet_tower_demon_pit_basic_attack_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown[1]
    tt.attacks.list[1].shoot_time = fts(33)
    tt.attacks.list[1].bullet_start_offset = vec_2(-7, 100)
    tt.attacks.list[1].max_range = b.basic_attack.range[1]
    tt.attacks.list[1].node_prediction = fts(60)
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].animation_reload = "reload_2"
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
    tt.demons_sid = 4
    tt.decal_reload = "decal_tower_demon_pit_reload"
    tt.animation_reload = "demon_pit_tower_lvl1_tower_demon_reload_reload_1"
    tt = E:register_t("tower_demon_pit_lvl2", "tower_demon_pit_lvl1")
    b = balance.towers.demon_pit
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.info.i18n_key = "TOWER_DEMON_PIT_2"
    tt.render.sprites[2].prefix = "demon_pit_tower_lvl2_tower_base"
    tt.render.sprites[3].prefix = "demon_pit_tower_lvl2_tower_bubbles"
    tt.render.sprites[4].prefix = "demon_pit_tower_lvl2_tower_demons"
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].prefix = "demon_pit_tower_lvl2_tower_front"
    tt.render.sprites[5].offset = vec_2(0, 15)
    tt.ui.click_rect = r(-32, 0, 64, 70)
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "bullet_tower_demon_pit_basic_attack_lvl2"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown[2]
    tt.attacks.list[1].max_range = b.basic_attack.range[2]
    tt.animation_reload = "demon_pit_tower_lvl2_tower_reload_reload_1"
    tt = E:register_t("tower_demon_pit_lvl3", "tower_demon_pit_lvl1")
    b = balance.towers.demon_pit
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 23)
    tt.info.i18n_key = "TOWER_DEMON_PIT_3"
    tt.render.sprites[2].prefix = "demon_pit_tower_lvl3_tower_base"
    tt.render.sprites[3].prefix = "demon_pit_tower_lvl3_tower_bubbles"
    tt.render.sprites[4].prefix = "demon_pit_tower_lvl3_tower_demons"
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].prefix = "demon_pit_tower_lvl3_tower_front"
    tt.render.sprites[5].offset = vec_2(0, 15)
    tt.ui.click_rect = r(-34, 0, 68, 78)
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "bullet_tower_demon_pit_basic_attack_lvl3"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown[3]
    tt.attacks.list[1].max_range = b.basic_attack.range[3]
    tt.animation_reload = "demon_pit_tower_lvl3_tower_reload_reload_1"
    tt = E:register_t("tower_demon_pit_lvl4", "tower_demon_pit_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.demon_pit
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 25)
    tt.info.i18n_key = "TOWER_DEMON_PIT_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.render.sprites[2].prefix = "demon_pit_tower_lvl4_tower_base"
    tt.render.sprites[3].prefix = "demon_pit_tower_lvl4_tower_bubbles"
    tt.render.sprites[4].prefix = "demon_pit_tower_lvl4_tower_demons"
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].prefix = "demon_pit_tower_lvl4_tower_front"
    tt.render.sprites[5].offset = vec_2(0, 15)
    tt.ui.click_rect = r(-40, 0, 80, 80)
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet = "bullet_tower_demon_pit_basic_attack_lvl4"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown[4]
    tt.attacks.list[1].max_range = b.basic_attack.range[4]
    tt.animation_reload = "demon_pit_tower_lvl4_tower_reload_reload_1"
    tt.powers.master_exploders = E:clone_c("power")
    tt.powers.master_exploders.price = b.master_exploders.price
    tt.powers.master_exploders.enc_icon = 11
    tt.powers.master_exploders.explosion_damage_factor = b.master_exploders.explosion_damage_factor
    tt.powers.master_exploders.burning_duration = b.master_exploders.burning_duration
    tt.powers.master_exploders.burning_damage_min = b.master_exploders.burning_damage_min
    tt.powers.master_exploders.burning_damage_max = b.master_exploders.burning_damage_max
    tt.powers.master_exploders.mod = "mod_tower_demon_pit_master_explosion_burning"
    tt.powers.master_exploders.sound = "TowerDemonPitDemonExplosion"
    tt.powers.big_guy = E:clone_c("power")
    tt.powers.big_guy.price = b.big_guy.price
    tt.powers.big_guy.enc_icon = 12
    tt.powers.big_guy.damage_max = 2
    tt.powers.big_guy.damage_min = 2
    tt.powers.big_guy.cooldown = b.big_guy.cooldown
    tt.powers.big_guy.key = "BIG_DEMON"
    tt.attacks.list[2] = E:clone_c("custom_attack")
    tt.attacks.list[2].bullet = "bullet_tower_demon_pit_big_guy_lvl4"
    tt.attacks.list[2].cooldown = b.big_guy.cooldown[1]
    tt.attacks.list[2].shoot_time = fts(43)
    tt.attacks.list[2].bullet_start_offset = vec_2(-7, 70)
    tt.attacks.list[2].max_range = b.big_guy.max_range
    tt.attacks.list[2].node_prediction = fts(80)
    tt.attacks.list[2].animation = "big_guy_spawn"
    tt.attacks.list[2].animation_reload = "big_guy_reload_big_guy"
    tt.attacks.list[2].vis_flags = bor(F_RANGED)
    tt.attacks.list[2].vis_bans = bor(F_FLYING)
    tt = E:register_t("tower_rocket_gunners_lvl1", "tower_KR5")
    b = balance.towers.rocket_gunners

    E:add_comps(tt, "barrack", "vis", "tower_upgrade_persistent_data")

    tt.tower.type = "rocket_gunners"
    tt.tower.kind = TOWER_KIND_ARCHER
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.info.i18n_key = "TOWER_ROCKET_GUNNERS_1"
    tt.info.portrait = "portraits_towers_0009"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0009_0001"
    tt.info.enc_icon = 2
    tt.tower.menu_offset = vec_2(0, 15)
    tt.info.tower_portrait = "towerselect_portraits_big_0009"
    tt.barrack.soldier_type = "soldier_tower_rocket_gunners_lvl1"
    tt.barrack.rally_range = b.rally_range[1]
    tt.barrack.respawn_offset = vec_2(1, 23)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.barrack.has_door = false
    tt.barrack.range_upgradable = true
    tt.sound_events.insert = "TowerPaladinCovenantTaunt"
    tt.sound_events.change_rally_point = "TowerPaladinCovenantTaunt"
    tt.info.fn = scripts.tower_rocket_gunners.get_info
    tt.main_script.insert = scripts.tower_barrack.insert
    tt.main_script.update = scripts.tower_rocket_gunners.update
    tt.main_script.remove = scripts.tower_barrack.remove
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].prefix = "rocket_gunners_tower_lvl1_tower"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].offset = vec_2(0, 18)
    tt.render.sprites[2].sort_y_offset = 20
    tt.ui.click_rect = r(-35, 0, 70, 50)
    tt.spawn_time = 34
    tt.spawn_delay = 10
    tt.sound_events.insert = "TowerRocketGunnersTaunt"
    tt.sound_events.change_rally_point = "TowerRocketGunnersTaunt"
    tt.sound_events.tower_room_select = "TowerRocketGunnersTauntSelect"
    tt.spawn_sound = "TowerRocketGunnersSpawn"
    tt = E:register_t("tower_rocket_gunners_lvl2", "tower_rocket_gunners_lvl1")
    b = balance.towers.rocket_gunners
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.info.i18n_key = "TOWER_ROCKET_GUNNERS_2"
    tt.tower.menu_offset = vec_2(0, 15)
    tt.barrack.soldier_type = "soldier_tower_rocket_gunners_lvl2"
    tt.barrack.rally_range = b.rally_range[2]
    tt.barrack.respawn_offset = vec_2(1, 27)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.render.sprites[2].prefix = "rocket_gunners_tower_lvl2_tower"
    tt.render.sprites[2].offset = vec_2(0, 18)
    tt.render.sprites[2].sort_y_offset = 23
    tt.spawn_time = 34
    tt = E:register_t("tower_rocket_gunners_lvl3", "tower_rocket_gunners_lvl1")
    b = balance.towers.rocket_gunners
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.info.i18n_key = "TOWER_ROCKET_GUNNERS_3"
    tt.tower.menu_offset = vec_2(0, 15)
    tt.barrack.soldier_type = "soldier_tower_rocket_gunners_lvl3"
    tt.barrack.rally_range = b.rally_range[3]
    tt.barrack.respawn_offset = vec_2(1, 30)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.render.sprites[2].prefix = "rocket_gunners_tower_lvl3_tower"
    tt.render.sprites[2].offset = vec_2(0, 18)
    tt.render.sprites[2].sort_y_offset = 26
    tt.render.sprites[2].scale = vec_2(0.95, 0.95)
    tt.spawn_time = 34
    tt = E:register_t("tower_rocket_gunners_lvl4", "tower_rocket_gunners_lvl1")
    b = balance.towers.rocket_gunners

    E:add_comps(tt, "powers")

    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.info.i18n_key = "TOWER_ROCKET_GUNNERS_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.tower.menu_offset = vec_2(0, 20)
    tt.barrack.soldier_type = "soldier_tower_rocket_gunners_lvl4"
    tt.barrack.rally_range = b.rally_range[4]
    tt.barrack.respawn_offset = vec_2(0, 34)
    tt.barrack.max_soldiers = b.max_soldiers
    tt.render.sprites[2].prefix = "rocket_gunners_tower_lvl4_tower"
    tt.render.sprites[2].offset = vec_2(0, 18)
    tt.render.sprites[2].sort_y_offset = 30
    tt.render.sprites[2].scale = vec_2(0.95, 0.95)
    tt.ui.click_rect = r(-35, -2, 70, 60)
    tt.spawn_time = 34
    tt.powers.phosphoric = E:clone_c("power")
    tt.powers.phosphoric.price = b.soldier.phosphoric.price
    tt.powers.phosphoric.enc_icon = 16
    tt.powers.sting_missiles = E:clone_c("power")
    tt.powers.sting_missiles.price = b.soldier.sting_missiles.price
    tt.powers.sting_missiles.enc_icon = 15
    tt.powers.sting_missiles.cooldown = b.sting_missiles.cooldown
    tt = E:register_t("tower_necromancer_lvl1", "tower_KR5")

    local b = balance.towers.necromancer

    E:add_comps(tt, "attacks", "vis", "tower_upgrade_persistent_data", "tween")

    tt.tower.type = "necromancer"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.enc_icon = 3
    tt.info.i18n_key = "TOWER_NECROMANCER_1"
    tt.info.portrait = "portraits_towers" .. "_0011"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0011_0001"
    tt.info.fn = scripts.tower_mage.get_info
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0010"
    tt.main_script.insert = scripts.tower_mage.insert
    tt.main_script.update = scripts.tower_necromancer.update
    tt.main_script.remove = scripts.tower_necromancer.remove
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].bullet = "bullet_tower_necromancer_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(10)
    tt.attacks.list[1].bullet_spawn_offset = {vec_2(20, 63), vec_2(-20, 63), vec_2(-36, 38), vec_2(36, 38)}
    tt.attacks.list[1].bullet_start_offset = vec_2(-15, 75)
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].node_prediction = fts(11)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "necromancer_tower_lvl1_tower"
    tt.render.sprites[2].offset = vec_2(0, 14)
    tt.render.sprites[2].sort_y_offset = 10
    tt.render.sprites[2].scale = vec_2(1.1, 1.1)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].animated = true
    tt.render.sprites[3].prefix = "necromancer_tower_lvl1_necromancer"
    tt.render.sprites[3].offset = tt.render.sprites[2].offset
    tt.render.sprites[3].z = Z_OBJECTS
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[3].scale = vec_2(1.1, 1.1)
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].animated = true
    tt.render.sprites[4].prefix = "necromancer_tower_lvl1_tower_FX_tower_FX"
    tt.render.sprites[4].offset = tt.render.sprites[2].offset
    tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[4].scale = vec_2(1.1, 1.1)
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = true
    tt.render.sprites[5].prefix = "necromancer_tower_lvl1_tower_FX_tower_FX"
    tt.render.sprites[5].offset = tt.render.sprites[2].offset
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[5].scale = vec_2(1.1, 1.1)
    tt.render.sid_tower = 2
    tt.render.sid_mage = 3
    tt.render.sid_smoke_fx = 4
    tt.render.sid_glow_fx = 5
    tt.mage_offset = vec_2(0, 35)
    tt.sound_events.insert = "TowerNecromancerTaunt"
    tt.sound_events.tower_room_select = "TowerNecromancerTauntSelect"
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {fts(20), 255}}
    tt.tween.props[1].sprite_id = tt.render.sid_smoke_fx
    tt.tween.disabled = true
    tt.max_skeletons = b.curse.max_skeletons[1]
    tt.max_golems = b.curse.max_golems
    tt = E:register_t("tower_necromancer_lvl2", "tower_necromancer_lvl1")

    local b = balance.towers.necromancer

    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 26)
    tt.info.i18n_key = "TOWER_NECROMANCER_2"
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "bullet_tower_necromancer_lvl2"
    tt.attacks.list[1].bullet_spawn_offset = {vec_2(20, 68), vec_2(-20, 68), vec_2(-36, 43), vec_2(36, 43)}
    tt.attacks.list[1].bullet_start_offset = vec_2(-15, 85)
    tt.render.sprites[2].name = "necromancer_tower_lvl2_tower"
    tt.render.sprites[2].sort_y_offset = 10
    tt.render.sprites[3].prefix = "necromancer_tower_lvl2_necromancer"
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[4].prefix = "necromancer_tower_lvl2_tower_FX_tower_FX"
    tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[5].prefix = "necromancer_tower_lvl2_tower_FX_tower_FX"
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.max_skeletons = b.curse.max_skeletons[2]
    tt.ui.click_rect = r(-35, 0, 70, 70)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_necromancer_lvl3", "tower_necromancer_lvl1")

    local b = balance.towers.necromancer

    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 31)
    tt.info.i18n_key = "TOWER_NECROMANCER_3"
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "bullet_tower_necromancer_lvl3"
    tt.attacks.list[1].bullet_spawn_offset = {vec_2(20, 80), vec_2(-20, 80), vec_2(-36, 58), vec_2(36, 58)}
    tt.attacks.list[1].bullet_start_offset = vec_2(-15, 92)
    tt.render.sprites[2].name = "necromancer_tower_lvl3_tower"
    tt.render.sprites[2].sort_y_offset = 10
    tt.render.sprites[2].scale = vec_2(1.1, 1.1)
    tt.render.sprites[3].prefix = "necromancer_tower_lvl3_necromancer"
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[3].scale = vec_2(1.1, 1.1)
    tt.render.sprites[4].prefix = "necromancer_tower_lvl3_tower_FX_tower_FX"
    tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[4].scale = vec_2(1.1, 1.1)
    tt.render.sprites[5].prefix = "necromancer_tower_lvl3_tower_FX_tower_FX"
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[5].scale = vec_2(1.1, 1.1)
    tt.max_skeletons = b.curse.max_skeletons[3]
    tt.ui.click_rect = r(-35, 0, 70, 70)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_necromancer_lvl4", "tower_necromancer_lvl1")

    local b = balance.towers.necromancer

    E:add_comps(tt, "powers")

    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 34)
    tt.info.i18n_key = "TOWER_NECROMANCER_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.damage_icon = "magic"
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet = "bullet_tower_necromancer_lvl4"
    tt.attacks.list[1].bullet_spawn_offset = {vec_2(20, 95), vec_2(-20, 95), vec_2(-36, 75), vec_2(36, 75)}
    tt.attacks.list[1].bullet_start_offset = vec_2(-15, 105)
    tt.render.sprites[2].name = "necromancer_tower_lvl4_tower"
    tt.render.sprites[2].scale = vec_2(0.9, 0.9)
    tt.render.sprites[2].sort_y_offset = 10
    tt.render.sprites[3].prefix = "necromancer_tower_lvl4_necromancer"
    tt.render.sprites[3].anchor = vec_2(0.5, 0.5175)
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[4].prefix = "necromancer_tower_lvl4_tower_FX_tower_FX"
    tt.render.sprites[4].scale = vec_2(0.9, 0.9)
    tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[5].prefix = "necromancer_tower_lvl4_tower_FX_tower_FX"
    tt.render.sprites[5].scale = vec_2(0.9, 0.9)
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].animated = true
    tt.render.sprites[6].loop = true
    tt.render.sprites[6].prefix = "necromancer_tower_lvl4_tower"
    tt.render.sprites[6].scale = vec_2(0.9, 0.9)
    tt.attacks.list[2] = E:clone_c("custom_attack")
    tt.attacks.list[2].animation = "mark_of_silence"
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].entity = "aura_tower_necromancer_skill_debuff"
    tt.attacks.list[2].max_range = b.skill_debuff.range
    tt.attacks.list[2].cast_time = fts(27)
    tt.attacks.list[2].node_prediction = fts(60)
    tt.attacks.list[2].min_cooldown = 2
    tt.attacks.list[2].min_targets = b.skill_debuff.min_targets
    tt.attacks.list[3] = E:clone_c("custom_attack")
    tt.attacks.list[3].animation = "call_death_rider"
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].entity = "aura_tower_necromancer_skill_rider"
    tt.attacks.list[3].max_range = b.skill_rider.range
    tt.attacks.list[3].cast_time = fts(27)
    tt.attacks.list[3].node_prediction = fts(60)
    tt.attacks.list[3].min_cooldown = 2
    tt.attacks.list[3].min_targets = b.skill_rider.min_targets
    tt.attacks.list[3].vis_bans = bor(F_FLYING, F_NIGHTMARE)
    tt.powers.skill_debuff = E:clone_c("power")
    tt.powers.skill_debuff.mod_duration = b.skill_debuff.mod_duration
    tt.powers.skill_debuff.aura_duration = b.skill_debuff.aura_duration
    tt.powers.skill_debuff.radius = b.skill_debuff.radius
    tt.powers.skill_debuff.cooldown = b.skill_debuff.cooldown
    tt.powers.skill_debuff.price = b.skill_debuff.price
    tt.powers.skill_debuff.enc_icon = 17
    tt.powers.skill_rider = E:clone_c("power")
    tt.powers.skill_rider.run_range = b.skill_rider.run_range
    tt.powers.skill_rider.price = b.skill_rider.price
    tt.powers.skill_rider.cooldown = b.skill_rider.cooldown
    tt.powers.skill_rider.price = b.skill_rider.price
    tt.powers.skill_rider.enc_icon = 18
    tt.max_skeletons = b.curse.max_skeletons[4]
    tt.ui.click_rect = r(-40, 0, 80, 90)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_ballista_lvl1", "tower_KR5")

    local b = balance.towers.ballista

    E:add_comps(tt, "attacks", "vis", "tower_upgrade_persistent_data")

    tt.tower.type = "ballista"
    tt.tower.kind = TOWER_KIND_ARCHER
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 25)
    tt.info.portrait = "portraits_towers" .. "_0010"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0002_0001"
    tt.info.enc_icon = 1
    tt.info.i18n_key = "TOWER_BALLISTA_1"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0008"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0010_0001"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)

    for i = 2, 4 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].animated = true
        tt.render.sprites[i].prefix = "ballista_tower_lvl1_tower_layer" .. i - 1
        tt.render.sprites[i].name = "idle_1_1"
        tt.render.sprites[i].offset = vec_2(0, 10)
        tt.render.sprites[i].group = "layers_base"
        tt.render.sprites[i].sort_y_offset = 10
    end

    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = true
    tt.render.sprites[5].prefix = "ballista_tower_lvl123_tower_goblin"
    tt.render.sprites[5].name = "idle_1_1"
    tt.render.sprites[5].offset = vec_2(2, 14)
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].animated = true
    tt.render.sprites[6].prefix = "ballista_tower_lvl1_tower_top"
    tt.render.sprites[6].name = "idle_1_1"
    tt.render.sprites[6].angles = {}
    tt.render.sprites[6].angles.idle = {"idle_1_1", "idle_1_2", "idle_1_3", "idle_1_4", "idle_1_5"}
    tt.render.sprites[6].angles.shot = {"ability1_loop_1_1", "ability1_loop_1_2", "ability1_loop_1_3",
                                        "ability1_loop_1_4", "ability1_loop_1_5"}
    tt.render.sprites[6].angles.reload = {"ability1_out_1_1", "ability1_out_1_2", "ability1_out_1_3",
                                          "ability1_out_1_4", "ability1_out_1_5"}
    tt.render.sprites[6].offset = tt.render.sprites[2].offset
    tt.render.sprites[6].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sid_tower_base_back = 2
    tt.render.sid_tower_base_arrows = 3
    tt.render.sid_tower_base_front = 4
    tt.render.sid_goblin = 5
    tt.render.sid_tower_top = 6
    tt.main_script.insert = scripts.tower_archer.insert
    tt.main_script.update = scripts.tower_ballista.update
    tt.main_script.remove = scripts.tower_ballista.remove
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].bullet = "bullet_tower_ballista_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].burst_count = 5
    tt.attacks.list[1].bullet_start_offset = {vec_2(13, 35), vec_2(20, 42), vec_2(20, 58), vec_2(0, 63), vec_2(0, 28)}
    tt.attacks.list[1].max_dist_between_shots = 30
    tt.shot_fx = "fx_tower_ballista_shot"
    tt.final_shot_fx = "fx_tower_ballista_final_shot"
    tt.tower_top_offset = vec_2(0, 20)
    tt.turn_speed = b.turn_speed
    tt.sound_events.insert = "TowerBallistaTaunt"
    tt.sound_events.tower_room_select = "TowerBallistaTauntSelect"
    tt.ui.click_rect = r(-35, 0, 70, 75)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_ballista_lvl2", "tower_ballista_lvl1")

    local b = balance.towers.ballista

    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.info.i18n_key = "TOWER_BALLISTA_2"

    for i = 2, 4 do
        tt.render.sprites[i].prefix = "ballista_tower_lvl2_tower_layer" .. i - 1
        tt.render.sprites[i].sort_y_offset = 10
    end

    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[6].prefix = "ballista_tower_lvl2_tower_top"
    tt.render.sprites[6].offset = vec_2(0, 5)
    tt.render.sprites[6].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "bullet_tower_ballista_lvl2"
    tt.attacks.list[1].bullet_start_offset = {vec_2(16, 43), vec_2(20, 49), vec_2(20, 63), vec_2(0, 68), vec_2(2, 40)}
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_ballista_lvl3", "tower_ballista_lvl1")

    local b = balance.towers.ballista

    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 33)
    tt.info.i18n_key = "TOWER_BALLISTA_3"

    for i = 2, 4 do
        tt.render.sprites[i].prefix = "ballista_tower_lvl3_tower_base_layer" .. i - 1
        tt.render.sprites[i].sort_y_offset = 10
    end

    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[6].prefix = "ballista_tower_lvl3_tower_top"
    tt.render.sprites[6].offset = tt.render.sprites[2].offset
    tt.render.sprites[6].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "bullet_tower_ballista_lvl3"
    tt.attacks.list[1].bullet_start_offset = {vec_2(16, 47), vec_2(20, 54), vec_2(15, 70), vec_2(0, 73), vec_2(2, 44)}
    tt.ui.click_rect = r(-35, 0, 70, 90)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_ballista_lvl4", "tower_ballista_lvl1")

    local b = balance.towers.ballista

    E:add_comps(tt, "powers")

    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.info.i18n_key = "TOWER_BALLISTA_4"

    for i = 2, 4 do
        tt.render.sprites[i].prefix = "ballista_tower_lvl4_tower_base_layer" .. i - 1
        tt.render.sprites[i].offset = vec_2(0, 5)
        tt.render.sprites[i].sort_y_offset = 5
    end

    tt.render.sprites[5].prefix = "ballista_tower_lvl4_tower_goblin"
    tt.render.sprites[5].name = "idle"
    tt.render.sprites[5].offset = tt.render.sprites[2].offset
    tt.render.sprites[5].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[6].prefix = "ballista_tower_lvl4_tower_top"
    tt.render.sprites[6].offset = tt.render.sprites[2].offset
    tt.render.sprites[6].angles.final_shot = {"ability2_1", "ability2_2", "ability2_3", "ability2_4", "ability2_5"}
    tt.render.sprites[6].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet = "bullet_tower_ballista_lvl4"
    tt.attacks.list[1].bullet_start_offset = {vec_2(12, 54), vec_2(23, 59), vec_2(15, 78), vec_2(0, 80), vec_2(0, 47)}
    tt.attacks.list[2] = E:clone_c("bullet_attack")
    tt.attacks.list[2].bullet = "bullet_tower_ballista_skill_bomb"
    tt.attacks.list[2].max_range = b.skill_bomb.max_range
    tt.attacks.list[2].min_range = b.skill_bomb.min_range
    tt.attacks.list[2].cooldown = b.skill_bomb.cooldown[1]
    tt.attacks.list[2].shoot_time = fts(20)
    tt.attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.attacks.list[2].bullet_start_offset = vec_2(0, 10)
    tt.attacks.list[2].node_prediction = fts(b.skill_bomb.node_prediction)
    tt.attacks.list[2].damage_type = b.skill_bomb.damage_type
    tt.attacks.list[2].damage_max = b.skill_bomb.damage_max
    tt.attacks.list[2].damage_min = b.skill_bomb.damage_min
    tt.attacks.list[2].min_targets = b.skill_bomb.min_targets
    tt.attacks.list[2].sound = "TowerTricannonBasicAttackFire"
    tt.powers.skill_final_shot = E:clone_c("power")
    tt.powers.skill_final_shot.cooldown = b.skill_final_shot.cooldown
    tt.powers.skill_final_shot.price = b.skill_final_shot.price
    tt.powers.skill_final_shot.damage_factor = b.skill_final_shot.damage_factor[1]
    tt.powers.skill_final_shot.damage_factor_config = b.skill_final_shot.damage_factor
    tt.powers.skill_final_shot.bullet = "bullet_tower_ballista_skill_final_shot"
    tt.powers.skill_final_shot.enc_icon = 19
    tt.powers.skill_bomb = E:clone_c("power")
    tt.powers.skill_bomb.price = b.skill_bomb.price
    tt.powers.skill_bomb.cooldown = b.skill_bomb.cooldown
    tt.powers.skill_bomb.duration = b.skill_bomb.duration
    tt.powers.skill_bomb.enc_icon = 20
    tt.ui.click_rect = r(-35, 0, 70, 90)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_flamespitter_lvl1", "tower_KR5")

    local b = balance.towers.flamespitter

    E:add_comps(tt, "attacks", "vis", "tower_upgrade_persistent_data")

    tt.tower.type = "flamespitter"
    tt.tower.kind = TOWER_KIND_ENGINEER
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 25)
    tt.info.portrait = "portraits_towers" .. "_0014"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0002_0001"
    tt.info.enc_icon = 1
    tt.info.i18n_key = "TOWER_FLAMESPITTER_1"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0008"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0012_0001"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.info.fn = scripts.tower_flamespitter.get_info
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "dwarven_flamespitter_tower_lvl1_tower"
    tt.render.sprites[2].offset = tt.render.sprites[1].offset
    tt.render.sprites[2].sort_y_offset = 10
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].animated = true
    tt.render.sprites[3].prefix = "dwarven_flamespitter_tower_lvl123_dude"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].offset = tt.render.sprites[2].offset
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].animated = true
    tt.render.sprites[4].prefix = "dwarven_flamespitter_tower_lvl1_cannon"
    tt.render.sprites[4].name = "idle_diagonal_down"
    tt.render.sprites[4].angles = {}
    tt.render.sprites[4].angles.idle = {"idle_diagonal_down", "idle_side", "idle_diagonal_up", "idle_up", "idle_down"}
    tt.render.sprites[4].angles.attack = {"attack_diagonal_down", "attack_side", "attack_diagonal_up", "attack_up",
                                          "attack_down"}
    tt.render.sprites[4].offset = vec_2(1.5, tt.render.sprites[2].offset.y)
    tt.render.sprites[4].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sid_tower_base = 2
    tt.render.sid_dwarf = 3
    tt.render.sid_tower_top = 4
    tt.main_script.insert = scripts.tower_engineer.insert
    tt.main_script.update = scripts.tower_flamespitter.update
    tt.main_script.remove = scripts.tower_flamespitter.remove
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE, F_FLYING)
    tt.attacks.list[1].burst_count = 5
    tt.attacks.list[1].aura_offset = {vec_2(13, 35), vec_2(20, 42), vec_2(20, 58), vec_2(0, 63), vec_2(0, 28)}
    tt.attacks.list[1].aura = "aura_tower_flamespitter"
    tt.attacks.list[1].flame_fx = "fx_tower_flamespitter_flame"
    tt.attacks.list[1].flame_fx_scale_x = {1, 0.9, 0.8, 0.7, 1.1}
    tt.attacks.list[1].duration = b.basic_attack.duration
    tt.attacks.list[1].bullet_start_offset = {vec_2(10, 55), vec_2(10, 55), vec_2(10, 55), vec_2(0, 70), vec_2(0, 45)}
    tt.attacks.list[1].node_prediction = fts(35)
    tt.attacks.list[1].damage_min = b.basic_attack.damage_min[1]
    tt.attacks.list[1].damage_max = b.basic_attack.damage_max[1]
    tt.attacks.list[1].sound = "TowerFlamespitterBasicAttack"
    tt.tower_top_offset = vec_2(0, 20)
    tt.turn_speed = b.turn_speed
    tt.sound_events.insert = "TowerFlamespitterTaunt"
    tt.sound_events.tower_room_select = "TowerFlamespitterTauntSelect"
    tt.ui.click_rect = r(-35, 0, 70, 75)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_flamespitter_lvl2", "tower_flamespitter_lvl1")

    local b = balance.towers.flamespitter

    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.info.i18n_key = "TOWER_FLAMESPITTER_2"
    tt.render.sprites[2].name = "dwarven_flamespitter_tower_lvl2_tower"
    tt.render.sprites[3].offset.y = 16
    tt.render.sprites[4].prefix = "dwarven_flamespitter_tower_lvl2_cannon"
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].damage_min = b.basic_attack.damage_min[2]
    tt.attacks.list[1].damage_max = b.basic_attack.damage_max[2]
    tt.attacks.list[1].bullet_start_offset = {vec_2(20, 50), vec_2(20, 60), vec_2(20, 62), vec_2(0, 75), vec_2(0, 45)}
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_flamespitter_lvl3", "tower_flamespitter_lvl1")

    local b = balance.towers.flamespitter

    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.info.i18n_key = "TOWER_FLAMESPITTER_3"
    tt.render.sprites[2].name = "dwarven_flamespitter_tower_lvl3_tower"
    tt.render.sprites[4].prefix = "dwarven_flamespitter_tower_lvl3_cannon"
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].damage_min = b.basic_attack.damage_min[3]
    tt.attacks.list[1].damage_max = b.basic_attack.damage_max[3]
    tt.attacks.list[1].bullet_start_offset = {vec_2(20, 50), vec_2(20, 62), vec_2(20, 62), vec_2(0, 80), vec_2(0, 50)}
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.ui.click_rect_offset_y = -10
    tt = E:register_t("tower_flamespitter_lvl4", "tower_flamespitter_lvl1")

    local b = balance.towers.flamespitter

    E:add_comps(tt, "powers")

    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.info.i18n_key = "TOWER_FLAMESPITTER_4"
    tt.render.sprites[2].name = "dwarven_flamespitter_tower_lvl4_tower"
    tt.render.sprites[2].sort_y_offset = 5
    tt.render.sprites[2].draw_order = 1
    tt.render.sprites[3].prefix = "dwarven_flamespitter_tower_lvl4_dude"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].offset = tt.render.sprites[2].offset
    tt.render.sprites[3].sort_y_offset = tt.render.sprites[2].sort_y_offset
    tt.render.sprites[3].draw_order = 3
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
    tt.render.sid_skill_1 = 5
    tt.render.sid_skill_2 = 6
    tt.render.sid_stove_fire = 7
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].damage_min = b.basic_attack.damage_min[4]
    tt.attacks.list[1].damage_max = b.basic_attack.damage_max[4]
    tt.attacks.list[1].bullet_start_offset = {vec_2(20, 55), vec_2(20, 62), vec_2(20, 72), vec_2(0, 85), vec_2(0, 50)}
    tt.attacks.list[2] = E:clone_c("bullet_attack")
    tt.attacks.list[2].bullet = "bullet_tower_flamespitter_skill_bomb"
    tt.attacks.list[2].max_range = b.skill_bomb.max_range
    tt.attacks.list[2].min_range = b.skill_bomb.min_range
    tt.attacks.list[2].cooldown = nil
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
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].damage_min = b.skill_columns.damage_min
    tt.attacks.list[3].damage_max = b.skill_columns.damage_max
    tt.attacks.list[3].damage_type = b.skill_columns.damage_type
    tt.attacks.list[3].min_targets = b.skill_columns.min_targets
    tt.attacks.list[3].node_prediction = fts(40)
    tt.attacks.list[3].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.attacks.list[3].vis_flags = bor(F_AREA)
    tt.attacks.list[3].sound = "TowerFlamespitterScorchingTorchesCast"
    tt.powers.skill_bomb = E:clone_c("power")
    tt.powers.skill_bomb.price = b.skill_bomb.price
    tt.powers.skill_bomb.cooldown = b.skill_bomb.cooldown
    tt.powers.skill_bomb.duration = b.skill_bomb.duration
    tt.powers.skill_bomb.enc_icon = 21
    tt.powers.skill_bomb.attack_idx = 2
    tt.powers.skill_columns = E:clone_c("power")
    tt.powers.skill_columns.cooldown = b.skill_columns.cooldown
    tt.powers.skill_columns.price = b.skill_columns.price
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
    tt = E:register_t("tower_barrel_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    b = balance.towers.barrel
    tt.tower.type = "barrel"
    tt.tower.kind = TOWER_KIND_ENGINEER
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 18)
    tt.info.portrait = "portraits_towers_0017"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0016_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0006"
    tt.info.enc_icon = 1
    tt.info.i18n_key = "TOWER_BARREL_1"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.main_script.insert = scripts.tower_barrel.insert
    tt.main_script.update = scripts.tower_barrel.update
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(10)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].bullet = "bullet_tower_barrel_lvl1"
    tt.attacks.list[1].range = b.basic_attack.range[1]
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.attacks.list[1].bullet_start_offset = vec_2(-3, 55)
    tt.attacks.list[1].node_prediction = fts(25)
    tt.attacks.list[1].animation = "attack"
    tt.attacks.list[1].sound = "TowerBarrelBasicAttackCast"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "barrel_tower_lvl1_tower"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].offset = vec_2(0, 10)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "barrel_tower_lvl1_tower_flow"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].offset = tt.render.sprites[2].offset
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].name = "barrel_tower_lvl1_tower_tube"
    tt.render.sprites[4].animated = false
    tt.render.sprites[4].offset = tt.render.sprites[2].offset
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].prefix = "barrel_tower_lvl1_viking"
    tt.render.sprites[5].name = "idle"
    tt.render.sprites[5].offset = vec_2(-3, 20)
    tt.sid_tower = 2
    tt.sid_viking = 5
    tt.sound_events.insert = "TowerBarrelTaunt"
    tt.sound_events.tower_room_select = "TowerBarrelTauntSelect"
    tt.ui.click_rect = r(-35, -3, 70, 55)
    tt = E:register_t("tower_barrel_lvl2", "tower_barrel_lvl1")
    b = balance.towers.barrel
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 23)
    tt.info.i18n_key = "TOWER_BARREL_2"
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "bullet_tower_barrel_lvl2"
    tt.attacks.list[1].range = b.basic_attack.range[1]
    tt.attacks.list[1].bullet_start_offset = vec_2(-3, 65)
    tt.attacks.list[1].shoot_time = fts(7)
    tt.render.sprites[2].name = "barrel_tower_lvl2_tower"
    tt.render.sprites[3].prefix = "barrel_tower_lvl2_tower_flow"
    tt.render.sprites[4].name = "barrel_tower_lvl2_tower_tube"
    tt.render.sprites[5].prefix = "barrel_tower_lvl2_viking"
    tt.render.sprites[5].offset = vec_2(-3, 30)
    tt.ui.click_rect = r(-37, -3, 74, 70)
    tt = E:register_t("tower_barrel_lvl3", "tower_barrel_lvl1")
    b = balance.towers.barrel
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 27)
    tt.info.i18n_key = "TOWER_BARREL_3"
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "bullet_tower_barrel_lvl3"
    tt.attacks.list[1].range = b.basic_attack.range[1]
    tt.attacks.list[1].bullet_start_offset = vec_2(-3, 69)
    tt.attacks.list[1].shoot_time = fts(9)
    tt.render.sprites[2].name = "barrel_tower_lvl3_tower"
    tt.render.sprites[3].prefix = "barrel_tower_lvl3_tower_flow"
    tt.render.sprites[4].name = "barrel_tower_lvl3_tower_tube"
    tt.render.sprites[5].prefix = "barrel_tower_lvl3_viking"
    tt.render.sprites[5].offset = vec_2(-3, 34)
    tt.ui.click_rect = r(-39, -3, 78, 75)
    tt = E:register_t("tower_barrel_lvl4", "tower_barrel_lvl1")

    E:add_comps(tt, "powers", "barrack")

    b = balance.towers.barrel
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 30)
    tt.tower.show_rally = false
    tt.info.i18n_key = "TOWER_BARREL_4"
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet = "bullet_tower_barrel_lvl4"
    tt.attacks.list[1].range = b.basic_attack.range[1]
    tt.attacks.list[1].bullet_start_offset = vec_2(-3, 80)
    tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[2].bullet = "bullet_tower_barrel_skill_barrel"
    tt.attacks.list[2].bullet_start_offset = vec_2(-3, 85)
    tt.attacks.list[2].shoot_time = fts(43)
    tt.attacks.list[2].min_targets = b.skill_barrel.min_targets
    tt.attacks.list[2].animation = "bad_barrel"
    tt.attacks.list[2].disabled = true
    tt.attacks.list[3] = E:clone_c("custom_attack")
    tt.attacks.list[3].entity = "controller_soldier_tower_barrel_skill_warrior_spawn"
    tt.attacks.list[3].min_targets = b.skill_warrior.min_targets
    tt.attacks.list[3].animation = "berserker"
    tt.attacks.list[3].drunk_man_spawn_delay = fts(18)
    tt.attacks.list[3].range = b.skill_warrior.range
    tt.attacks.list[3].cooldown = b.skill_warrior.cooldown
    tt.attacks.list[3].vis_bans = bor(F_FLYING, F_CLIFF)
    tt.attacks.list[3].disabled = true
    tt.render.sprites[2].prefix = "barrel_tower_lvl4_tower"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].animated = true
    tt.render.sprites[3].prefix = "barrel_tower_lvl4_tower_flow"
    tt.render.sprites[4].name = "barrel_tower_lvl4_tower_tube"
    tt.render.sprites[5].prefix = "barrel_tower_lvl4_viking"
    tt.render.sprites[5].offset = vec_2(-3, 45)
    tt.powers.skill_warrior = E:clone_c("power")
    tt.powers.skill_warrior.price = b.skill_warrior.price
    tt.powers.skill_warrior.cooldown = b.skill_warrior.cooldown
    tt.powers.skill_warrior.duration = b.skill_warrior.duration
    tt.powers.skill_warrior.hp_max = b.skill_warrior.entity.hp_max
    tt.powers.skill_warrior.armor = b.skill_warrior.entity.armor
    tt.powers.skill_warrior.enc_icon = 23
    tt.powers.skill_warrior.attack_idx = 3
    tt.powers.skill_warrior.sound_evict = "TowerBarrelElixirOfMightEvict"
    tt.powers.skill_warrior.sound_drink = "TowerBarrelElixirOfMightDrink"
    tt.powers.skill_warrior.show_rally = true
    tt.powers.skill_warrior.spawn_fx = "controller_soldier_tower_barrel_skill_warrior_spawn"
    tt.powers.skill_barrel = E:clone_c("power")
    tt.powers.skill_barrel.cooldown = b.skill_barrel.cooldown
    tt.powers.skill_barrel.price = b.skill_barrel.price
    tt.powers.skill_barrel.enc_icon = 24
    tt.powers.skill_barrel.attack_idx = 2
    tt.ui.click_rect = r(-40, -3, 80, 85)
    tt.barrack.rally_range = b.rally_range
    tt.barrack.rally_radius = 25
    tt.barrack.soldier_type = "soldier_tower_barrel_skill_warrior"
    tt.barrack.max_soldiers = 1
    tt.barrack.respawn_offset = vec_2(0, 0)
    tt = E:register_t("controller_soldier_tower_barrel_skill_warrior_spawn")

    E:add_comps(tt, "pos", "render", "main_script")

    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "barrel_tower_lvl4_tower_berserker"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].hidden = false
    tt.render.sprites[1].draw_order = 10
    tt.main_script.update = scripts.controller_soldier_tower_barrel_skill_warrior_spawn.update
    tt.berzerker_spawn_offset = vec_2(-35, -17)
    tt.berzerker_spawn_delay = fts(58)
    tt.spawn_fx = "fx_soldier_tower_barrel_skill_warrior_spawn"
    tt.berzerker_entity = "soldier_tower_barrel_skill_warrior"
    tt = E:register_t("soldier_tower_barrel_skill_warrior", "soldier_militia")

    E:add_comps(tt, "tween", "nav_grid")

    b = balance.towers.barrel.skill_warrior.entity
    tt.health_bar.offset = vec_2(0, 50)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.motion.max_speed = b.speed
    tt.info.i18n_key = "TOWER_BARREL_WARRIOR"
    tt.info.enc_icon = 12
    tt.info.portrait = "gui_bottom_info_image_soldiers_0037"
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.random_name_format = nil
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "barrel_tower_berserker_unit"
    tt.render.sprites[1].name = "spawn"
    tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.sound_events.death = "HeroRaelynUltimateDeath"
    tt.unit.hit_offset = vec_2(0, 16)
    tt.unit.size = UNIT_SIZE_LARGE
    tt.unit.fade_time_after_death = tt.health.dead_lifetime
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.main_script.insert = scripts.soldier_tower_barrel_skill_warrior.insert
    tt.main_script.update = scripts.soldier_tower_barrel_skill_warrior.update
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = true
    tt.tween.reverse = false
    tt.tween.disabled = true
    tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
    tt.melee.attacks[1].vis_flags = F_BLOCK
    tt.melee.attacks[1].damage_min_config = b.damage_min
    tt.melee.attacks[1].damage_max_config = b.damage_max
    tt.melee.attacks[1].damage_type = b.damage_type
    tt.melee.attacks[1].hit_time = fts(8)
    tt.melee.attacks[1].hit_fx = "fx_soldier_tower_barrel_skill_warrior_hit"
    tt.melee.attacks[1].hit_offset = vec_2(30, 20)
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[1].sound = "CommonNoSwordAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(8)
    }
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "attack_2"
    tt.melee.attacks[2].chance = 0.5
    tt.melee.range = b.range
    tt.melee.cooldown = b.cooldown
    tt.floor_decal = "decal_soldier_tower_barrel_skill_warrior"
    tt.ui.click_rect = r(-20, -5, 40, 50)
    tt = E:register_t("tower_sand_lvl1", "tower_KR5")

    E:add_comps(tt, "attacks", "vis")

    b = balance.towers.sand
    tt.tower.type = "sand"
    tt.tower.kind = TOWER_KIND_ARCHER
    tt.tower.team = TEAM_LINIREA
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 20)
    tt.info.portrait = "portraits_towers" .. "_0015"
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0013_0001"
    tt.info.enc_icon = 1
    tt.info.i18n_key = "TOWER_SAND_1"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0015"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 14)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "tower_sand_lvl1_tower"
    tt.render.sprites[2].offset = vec_2(2, 14)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "tower_sand_lvl1_sentinel"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idle_back", "idle"}
    tt.render.sprites[3].angles.shoot = {"attack_back", "attack"}
    tt.render.sprites[3].angles_flip_horizontal = {true, false}
    tt.render.sprites[3].offset = vec_2(-7, 48)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset = vec_2(10, 43)
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "tower_sand_lvl1_tower_front"
    tt.render.sprites[5].offset = vec_2(2, 14)
    tt.main_script.insert = scripts.tower_archer.insert
    tt.main_script.update = scripts.tower_sand.update
    tt.main_script.remove = scripts.tower_sand.remove
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].bullet = "bullet_tower_sand_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(10)
    tt.attacks.list[1].bullet_start_offset = {vec_2(-15, 13), vec_2(15, 12)}
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.sound_events.insert = "TowerSandTaunt"
    tt.sound_events.tower_room_select = "TowerSandTauntSelect"
    tt.ui.click_rect = r(-30, 3, 63, 62)
    tt = E:register_t("tower_sand_lvl2", "tower_sand_lvl1")
    b = balance.towers.sand
    tt.info.enc_icon = 5
    tt.info.i18n_key = "TOWER_SAND_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.render.sprites[2].name = "tower_sand_lvl2_tower"
    tt.render.sprites[3].prefix = "tower_sand_lvl2_sentinel"
    tt.render.sprites[3].offset = vec_2(-7, 53)
    tt.render.sprites[4].prefix = "tower_sand_lvl2_sentinel"
    tt.render.sprites[4].offset = vec_2(10, 48)
    tt.render.sprites[5].hidden = true
    tt.attacks.list[1].bullet = "bullet_tower_sand_lvl2"
    tt.attacks.list[1].bullet_start_offset = {vec_2(-15, 13), vec_2(15, 12)}
    tt.attacks.list[1].shoot_time = fts(9)
    tt.attacks.range = b.basic_attack.range[2]
    tt.ui.click_rect = r(-30, 3, 63, 67)
    tt = E:register_t("tower_sand_lvl3", "tower_sand_lvl1")
    b = balance.towers.sand
    tt.info.enc_icon = 9
    tt.info.i18n_key = "TOWER_SAND_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 22)
    tt.tower.size = TOWER_SIZE_LARGE
    tt.render.sprites[2].name = "tower_sand_lvl3_tower"
    tt.render.sprites[3].prefix = "tower_sand_lvl3_sentinel"
    tt.render.sprites[3].offset = vec_2(-7, 56)
    tt.render.sprites[4].prefix = "tower_sand_lvl3_sentinel"
    tt.render.sprites[4].offset = vec_2(10, 51)
    tt.render.sprites[5].hidden = true
    tt.attacks.list[1].bullet = "bullet_tower_sand_lvl3"
    tt.attacks.list[1].bullet_start_offset = {vec_2(-15, 13), vec_2(15, 12)}
    tt.attacks.list[1].shoot_time = fts(9)
    tt.attacks.range = b.basic_attack.range[3]
    tt.ui.click_rect = r(-32, 3, 67, 72)
    tt = E:register_t("tower_sand_lvl4", "tower_sand_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.sand
    tt.info.enc_icon = 18
    tt.info.i18n_key = "TOWER_SAND_4"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.stat_range = b.stats.range
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.menu_offset = vec_2(0, 25)
    tt.tower.size = TOWER_SIZE_LARGE
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "bullet_tower_sand_lvl4"
    tt.attacks.list[1].shoot_time = fts(9)
    tt.attacks.list[1].bullet_start_offset = {vec_2(-15, 13), vec_2(15, 12)}
    tt.attacks.list[2] = E:clone_c("bullet_attack")
    tt.attacks.list[2].animation = "skill1"
    tt.attacks.list[2].bullet = "bullet_tower_sand_skill_gold"
    tt.attacks.list[2].cooldown = nil
    tt.attacks.list[2].shoot_time = fts(17)
    tt.attacks.list[2].bullet_start_offset = {vec_2(-12, 13), vec_2(-12, 12)}
    tt.attacks.list[2].sound = "TowerSandSkillGoldCast"
    tt.attacks.list[2].vis_bans = bor(F_FRIEND, F_NIGHTMARE)
    tt.attacks.list[3] = E:clone_c("bullet_attack")
    tt.attacks.list[3].animation = "skill2"
    tt.attacks.list[3].bullet = "aura_tower_sand_skill_big_blade"
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].shoot_time = {fts(30), fts(33)}
    tt.attacks.list[3].bullet_start_offset = {vec_2(-17, 18), vec_2(17, 18)}
    tt.attacks.list[3].sound = "TowerSandSkillBigBladeCast"
    tt.attacks.list[3].vis_bans = bor(F_FRIEND, F_NIGHTMARE, F_FLYING)
    tt.attacks.list[3].range = b.skill_big_blade.range
    tt.attacks.list[3].min_targets = b.skill_big_blade.min_targets
    tt.attacks.range = b.basic_attack.range[4]
    tt.powers.skill_gold = E:clone_c("power")
    tt.powers.skill_gold.attack_idx = 2
    tt.powers.skill_gold.price = b.skill_gold.price
    tt.powers.skill_gold.cooldown = b.skill_gold.cooldown
    tt.powers.skill_gold.enc_icon = 27
    tt.powers.skill_big_blade = E:clone_c("power")
    tt.powers.skill_big_blade.attack_idx = 3
    tt.powers.skill_big_blade.price = b.skill_big_blade.price
    tt.powers.skill_big_blade.enc_icon = 28
    tt.powers.skill_big_blade.cooldown = b.skill_big_blade.cooldown
    tt.powers.skill_big_blade.damage_min = b.skill_big_blade.damage_min
    tt.powers.skill_big_blade.damage_max = b.skill_big_blade.damage_max
    tt.powers.skill_big_blade.duration = b.skill_big_blade.duration
    tt.powers.skill_big_blade.controller = "controller_tower_sand_lvl4_skill_big_blade"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 14)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].prefix = "tower_sand_lvl4_tower"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].offset = vec_2(1, 13)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "tower_sand_lvl4_sentinel"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].angles = {}
    tt.render.sprites[3].angles.idle = {"idle_back", "idle"}
    tt.render.sprites[3].angles.shoot = {"attack_back", "attack"}
    tt.render.sprites[3].angles_flip_horizontal = {true, false}
    tt.render.sprites[3].offset = vec_2(-9, 61)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[3])
    tt.render.sprites[4].offset = vec_2(10, 56)
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].name = "tower_sand_lvl4_tower_front"
    tt.render.sprites[5].offset = vec_2(1, 13)
    tt.ui.click_rect = r(-35, 3, 73, 77)
    tt.tower_sid = 2
    tt = E:register_t("controller_tower_sand_lvl4_skill_big_blade")

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_tower_sand_lvl4_skill_big_blade.update
    tt = E:register_t("tower_ray_lvl1", "tower_KR5")

    local b = balance.towers.ray

    E:add_comps(tt, "attacks", "vis", "tween")

    tt.tower.type = "ray"
    tt.tower.kind = TOWER_KIND_MAGE
    tt.tower.team = TEAM_DARK_ARMY
    tt.tower.level = 1
    tt.tower.price = b.price[1]
    tt.tower.menu_offset = vec_2(0, 33)
    tt.tower.long_idle_cooldown = 2
    tt.info.enc_icon = 17
    tt.info.i18n_key = "TOWER_RAY_1"
    tt.info.portrait = "portraits_towers" .. "_0019"
    tt.info.fn = scripts.tower_ray.get_info
    tt.info.room_portrait = "quickmenu_main_icons_main_icons_0017_0001"
    tt.info.tower_portrait = "towerselect_portraits_big_" .. "0017"
    tt.info.damage_icon = "magic"
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_range = b.stats.range
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.tower_ray.insert
    tt.main_script.update = scripts.tower_ray.update
    tt.main_script.remove = scripts.tower_ray.remove
    tt.attacks.min_cooldown = b.shared_min_cooldown
    tt.attacks.range = b.basic_attack.range[1]
    tt.attacks.extra_range = b.basic_attack.extra_range_to_stay
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation_start = "attack_start"
    tt.attacks.list[1].animation_loop = "attack_loop"
    tt.attacks.list[1].animation_end = "attack_end"
    tt.attacks.list[1].bullet = "bullet_tower_ray_lvl1"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].shoot_time = fts(9)
    tt.attacks.list[1].duration = b.basic_attack.duration
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 83)
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].vis_flags = bor(F_RANGED)
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrains_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "channeler_tower_lvl1_tower"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].offset = vec_2(0, 13)
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "channeler_tower_lvl1_rune_glow"
    tt.render.sprites[3].name = "idle"
    tt.render.sprites[3].hidden = true
    tt.render.sprites[3].offset = tt.render.sprites[2].offset
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "channeler_tower_lvl1_mage"
    tt.render.sprites[4].name = "idle"
    tt.render.sprites[4].angles = {}
    tt.render.sprites[4].angles.idle = {"idle_back", "idle"}
    tt.render.sprites[4].angles.attack_start = {"attack_back_start", "attack_start"}
    tt.render.sprites[4].angles.attack_loop = {"attack_back_loop", "attack_loop"}
    tt.render.sprites[4].angles.attack_end = {"attack_back_end", "attack_end"}
    tt.render.sprites[4].offset = tt.render.sprites[2].offset
    tt.render.sprites[5] = E:clone_c("sprite")
    tt.render.sprites[5].name = "channeler_tower_towers_decal"
    tt.render.sprites[5].animated = false
    tt.render.sprites[5].z = Z_DECALS
    tt.render.sprites[5].offset = tt.render.sprites[2].offset
    tt.render.sprites[6] = E:clone_c("sprite")
    tt.render.sprites[6].prefix = "channeler_tower_crystal_full"
    tt.render.sprites[6].name = "idle"
    tt.render.sprites[6].animated = true
    tt.render.sprites[6].z = Z_OBJECTS + 1
    tt.render.sprites[6].offset = tt.attacks.list[1].bullet_start_offset
    tt.render.sprites[6].hidden = true
    tt.render.sid_glow = 3
    tt.render.sid_mage = 4
    tt.render.sid_crystal_union = 6
    tt.render.sid_crystals = 7
    tt.crystals_ids = {"a", "b", "c", "d", "e", "f"}

    for i = 1, #tt.crystals_ids do
        local crystal_sid = tt.render.sid_crystals + i - 1

        tt.render.sprites[crystal_sid] = E:clone_c("sprite")
        tt.render.sprites[crystal_sid].prefix = "channeler_tower_lvl1_2_3_crystal_" .. tt.crystals_ids[i]
        tt.render.sprites[crystal_sid].name = "idle"
        tt.render.sprites[crystal_sid].group = "crystals"
        tt.render.sprites[crystal_sid].offset = vec_2(0, tt.attacks.list[1].bullet_start_offset.y - 15)
    end

    tt.mage_offset = vec_2(0, 80)
    tt.tween.remove = false
    tt.sound_events.insert = "TowerRayTaunt"
    tt.sound_events.tower_room_select = "TowerRayTauntSelect"
    tt.ui.click_rect = r(-30, 0, 60, 65)
    tt = E:register_t("tower_ray_lvl2", "tower_ray_lvl1")
    tt.info.enc_icon = 7
    tt.info.i18n_key = "TOWER_RAY_2"
    tt.tower.level = 2
    tt.tower.price = b.price[2]
    tt.tower.menu_offset = vec_2(0, 38)
    tt.attacks.range = b.basic_attack.range[2]
    tt.attacks.list[1].bullet = "bullet_tower_ray_lvl2"
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 92)
    tt.render.sprites[2].name = "channeler_tower_lvl2_tower"
    tt.render.sprites[3].prefix = "channeler_tower_lvl2_rune_glow"
    tt.render.sprites[4].prefix = "channeler_tower_lvl2_mage"
    tt.render.sprites[tt.render.sid_crystal_union].offset = tt.attacks.list[1].bullet_start_offset

    for i = 1, #tt.crystals_ids do
        local crystal_sid = tt.render.sid_crystals + i - 1

        tt.render.sprites[crystal_sid].offset.y = tt.attacks.list[1].bullet_start_offset.y - 15
    end

    tt.render.sid_stones = 13
    tt.stones_ids = {"a", "b", "c", "d", "e"}

    for i = 1, #tt.stones_ids do
        local stone_sid = tt.render.sid_stones + i - 1

        tt.render.sprites[stone_sid] = E:clone_c("sprite")
        tt.render.sprites[stone_sid].name = "channeler_tower_lvl2_stone_" .. tt.stones_ids[i]
        tt.render.sprites[stone_sid].animated = false
        tt.render.sprites[stone_sid].offset = tt.render.sprites[2].offset
    end

    tt.ui.click_rect = r(-35, 0, 70, 70)
    tt = E:register_t("tower_ray_lvl3", "tower_ray_lvl2")
    tt.info.enc_icon = 7
    tt.info.i18n_key = "TOWER_RAY_3"
    tt.tower.level = 3
    tt.tower.price = b.price[3]
    tt.tower.menu_offset = vec_2(0, 42)
    tt.attacks.range = b.basic_attack.range[3]
    tt.attacks.list[1].bullet = "bullet_tower_ray_lvl3"
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 95)
    tt.render.sprites[2].name = "channeler_tower_lvl3_tower"
    tt.render.sprites[3].prefix = "channeler_tower_lvl3_rune_glow"
    tt.render.sprites[4].prefix = "channeler_tower_lvl3_mage"

    for i = 1, #tt.crystals_ids do
        local crystal_sid = tt.render.sid_crystals + i - 1

        tt.render.sprites[crystal_sid].offset.y = tt.attacks.list[1].bullet_start_offset.y - 15
    end

    tt.render.sprites[tt.render.sid_crystal_union].offset = tt.attacks.list[1].bullet_start_offset
    tt.stones_ids = {"a", "b", "c", "d", "e", "f"}

    for i = 1, #tt.stones_ids do
        local stone_sid = tt.render.sid_stones + i - 1

        tt.render.sprites[stone_sid] = E:clone_c("sprite")
        tt.render.sprites[stone_sid].name = "channeler_tower_lvl3_stone_" .. tt.stones_ids[i]
        tt.render.sprites[stone_sid].animated = false
        tt.render.sprites[stone_sid].offset = tt.render.sprites[2].offset
    end

    tt.ui.click_rect = r(-35, 0, 70, 70)
    tt = E:register_t("tower_ray_lvl4", "tower_ray_lvl3")

    E:add_comps(tt, "powers")

    tt.info.enc_icon = 15
    tt.info.i18n_key = "TOWER_RAY_4"
    tt.tower.level = 4
    tt.tower.price = b.price[4]
    tt.tower.size = TOWER_SIZE_LARGE
    tt.tower.menu_offset = vec_2(0, 38)
    tt.powers.chain = CC("power")
    tt.powers.chain.price = b.skill_chain.price
    tt.powers.chain.damage_mult = b.skill_chain.damage_mult
    tt.powers.chain.enc_icon = 29
    tt.powers.sheep = CC("power")
    tt.powers.sheep.price = b.skill_sheep.price
    tt.powers.sheep.cooldown = b.skill_sheep.cooldown
    tt.powers.sheep.duration = b.skill_sheep.duration
    tt.powers.sheep.enc_icon = 30
    tt.attacks.range = b.basic_attack.range[4]
    tt.attacks.list[1].bullet = "bullet_tower_ray_lvl4"
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 102)
    tt.attacks.list[1].start_fx = "fx_tower_ray_lvl4_attack"
    tt.attacks.list[2] = table.deepclone(tt.attacks.list[1])
    tt.attacks.list[2].bullet = "bullet_tower_ray_chain"
    tt.attacks.list[2].disabled = true
    tt.attacks.list[3] = E:clone_c("bullet_attack")
    tt.attacks.list[3].animation_start = "attack_start"
    tt.attacks.list[3].animation_loop = "attack_loop"
    tt.attacks.list[3].animation_end = "attack_end"
    tt.attacks.list[3].bullet = "bullet_tower_ray_sheep"
    tt.attacks.list[3].range = b.skill_sheep.range
    tt.attacks.list[3].cooldown = nil
    tt.attacks.list[3].shoot_time = fts(10)
    tt.attacks.list[3].bullet_start_offset = tt.attacks.list[1].bullet_start_offset
    tt.attacks.list[3].node_prediction = fts(10)
    tt.attacks.list[3].start_fx = "fx_tower_ray_lvl4_attack_sheep"
    tt.attacks.list[3].vis_bans = bor(F_NIGHTMARE, F_BOSS, F_MINIBOSS)
    tt.attacks.list[3].excluded_templates = {"enemy_tower_ray_sheep", "enemy_tower_ray_sheep_flying"}
    tt.attacks.list[3].disabled = true
    tt.render.sprites[2].name = "channeler_tower_lvl4_rock_core"
    tt.render.sprites[2].draw_order = 2
    tt.render.sprites[3].hidden = true
    tt.render.sprites[4].prefix = "channeler_tower_lvl4_mage"
    tt.render.sprites[4].draw_order = 4
    tt.render.sprites[tt.render.sid_crystal_union].offset = tt.attacks.list[1].bullet_start_offset
    tt.crystals_ids = {"a", "b", "c", "d", "e", "f", "g", "h"}

    for i = 1, #tt.crystals_ids do
        local crystal_sid = tt.render.sid_crystals + i - 1

        tt.render.sprites[crystal_sid] = E:clone_c("sprite")
        tt.render.sprites[crystal_sid].prefix = "channeler_tower_lvl4_crystal_" .. tt.crystals_ids[i]
        tt.render.sprites[crystal_sid].name = "idle"
        tt.render.sprites[crystal_sid].group = "crystals"
        tt.render.sprites[crystal_sid].offset = vec_2(0, 20)
        tt.render.sprites[crystal_sid].draw_order = 4
    end

    tt.render.sid_stones = tt.render.sid_crystals + #tt.crystals_ids
    tt.stones_ids = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"}

    for i = 1, #tt.stones_ids do
        local stone_sid = tt.render.sid_stones + i - 1

        tt.render.sprites[stone_sid] = E:clone_c("sprite")
        tt.render.sprites[stone_sid].name = "channeler_tower_lvl4_stone_" .. tt.stones_ids[i]
        tt.render.sprites[stone_sid].animated = false
        tt.render.sprites[stone_sid].draw_order = 2
        tt.render.sprites[stone_sid].offset = tt.render.sprites[2].offset
    end

    tt.render.sid_core_rock_shadow = 27
    tt.render.sprites[tt.render.sid_core_rock_shadow] = E:clone_c("sprite")
    tt.render.sprites[tt.render.sid_core_rock_shadow].name = "channeler_tower_lvl4_tower_shadow"
    tt.render.sprites[tt.render.sid_core_rock_shadow].animated = false
    tt.render.sprites[tt.render.sid_core_rock_shadow].z = Z_DECALS
    tt.render.sprites[tt.render.sid_core_rock_shadow].offset = tt.render.sprites[2].offset
    tt.render.sid_rocks = 28
    tt.rocks_ids = {"a", "b", "c"}

    for i = 1, #tt.rocks_ids do
        local rock_sid = tt.render.sid_rocks + i - 1

        tt.render.sprites[rock_sid] = E:clone_c("sprite")
        tt.render.sprites[rock_sid].prefix = "channeler_tower_lvl4_rock_" .. tt.rocks_ids[i]
        tt.render.sprites[rock_sid].name = "idle"
        tt.render.sprites[rock_sid].animated = true
        tt.render.sprites[rock_sid].group = "rocks"
        tt.render.sprites[rock_sid].draw_order = 4
        tt.render.sprites[rock_sid].offset = tt.render.sprites[2].offset
    end

    tt.render.sid_back_rocks = 31
    tt.back_rocks_ids = {"d", "e"}

    for i = 1, #tt.back_rocks_ids do
        local rock_sid = tt.render.sid_back_rocks + i - 1

        tt.render.sprites[rock_sid] = E:clone_c("sprite")
        tt.render.sprites[rock_sid].name = "channeler_tower_lvl4_rock_" .. tt.back_rocks_ids[i]
        tt.render.sprites[rock_sid].animated = false
        tt.render.sprites[rock_sid].draw_order = 1
        tt.render.sprites[rock_sid].offset = tt.render.sprites[2].offset
    end

    tt.shocks_ids = {"a", "b", "c", "d"}
    tt.shock_fx = "fx_tower_ray_lvl4_shock"
    tt.ui.click_rect = r(-35, 10, 70, 70)
    tt = E:register_t("tower_stage_13_sunray", "tower_KR5")
    b = balance.specials.towers.stage_13_sunray

    E:add_comps(tt, "user_selection", "attacks", "editor")

    tt.tower.type = "tower_stage_13_sunray"
    tt.tower.menu_offset = vec_2(0, 45)
    tt.tower.can_be_sold = false
    tt.tower.can_be_mod = false
    tt.render.sprites[1].prefix = "sunraytowerDef"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.info.portrait = "portraits_towers" .. "_0018"
    tt.user_selection.can_select_point_fn = scripts.tower_stage_13_sunray.can_select_point
    tt.main_script.update = scripts.tower_stage_13_sunray.update
    tt.attacks.range = b.basic_attack.range
    tt.attacks.attack_delay_on_spawn = fts(5)
    tt.attacks.list[1] = E:clone_c("bullet_attack")
    tt.attacks.list[1].animation_in = "attackin"
    tt.attacks.list[1].animation_loop = "attackloop"
    tt.attacks.list[1].animation_out = "attackout"
    tt.attacks.list[1].bullet = "bullet_tower_stage_13_sunray"
    tt.attacks.list[1].cooldown = b.basic_attack.cooldown
    tt.attacks.list[1].bullet_start_offset = vec_2(4, 88)
    tt.attacks.list[1].ignore_out_of_range_check = 1
    tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[1].duration = b.basic_attack.duration
    tt.attacks.list[1].sound = "Stage13DarkRayAttack"
    tt.attacks.list[2] = E:clone_c("bullet_attack")
    tt.attacks.list[2].animation_in = "superattackin"
    tt.attacks.list[2].animation_loop = "superattackloop"
    tt.attacks.list[2].animation_out = "superattackinout"
    tt.attacks.list[2].bullet = "bullet_tower_stage_13_sunray_special"
    tt.attacks.list[2].cooldown = b.basic_attack.cooldown
    tt.attacks.list[2].bullet_start_offset = vec_2(4, 88)
    tt.attacks.list[2].ignore_out_of_range_check = 1
    tt.attacks.list[2].vis_bans = bor(F_NIGHTMARE)
    tt.attacks.list[2].duration = b.special_attack.duration
    tt.attacks.list[2].aura = "aura_tower_stage_13_sunray_special"
    tt.attacks.list[2].decal = "decal_tower_stage_13_sunray"
    tt.attacks.list[2].sound = "Stage13DarkRaySpecialAttack"
    tt.attacks.list[2].sound_destroy = "Stage13DarkRayDestroy"
    tt.min_attacks_before_special = b.attacks_before_special_min
    tt.max_attacks_before_special = b.attacks_before_special_max
    tt.min_attacks_before_special_iron = b.attacks_before_special_min_iron
    tt.max_attacks_before_special_iron = b.attacks_before_special_max_iron
    tt.repair = {}
    tt.repair.cost = b.repair_cost[1]
    tt.repair.active = nil
    tt.repair.sound = "Stage13DarkRayTowerRepair"
    tt.repair_cost_config = b.repair_cost
    tt.repair_cost_config_iron = b.repair_cost_iron
    tt.ui.click_rect = r(-50, -30, 100, 130)
    tt.ui.hover_sprite_scale = vec_1(1.4)
    tt.ui.hover_sprite_offset = vec_2(0, -8)
    tt.editor.props = {{"editor.game_mode", PT_NUMBER}}
    tt = E:register_t("soldier_reinforcement_basic", "soldier_militia")
    b = balance.reinforcements

    E:add_comps(tt, "reinforcement", "nav_grid", "tween")

    tt.cooldown = b.soldier.cooldown
    tt.health.armor = b.soldier.armor
    tt.health.hp_max = b.soldier.hp_max
    tt.health_bar.offset = vec_2(0, 30)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_M_%i_NAME"
    tt.info.random_name_count = 10
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_kr5.update
    tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.range = b.soldier.melee_attack.range
    tt.motion.max_speed = b.soldier.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = b.soldier.regen_health
    tt.reinforcement.duration = b.soldier.duration
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].scale = vec_1(1.075)
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.sound_events.insert = "ReinforcementTaunt"
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.unit.fade_time_after_death = tt.health.dead_lifetime
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt.ui.click_rect = r(-15, -5, 30, 35)
    tt.ui.click_rect_offset_y = -10
    tt.unit.marker_offset = vec_2(0, ady(0))
    tt.portrait_idxs = {10, 11, 12}

    for i = 1, 3 do
        local base_t = E:get_template("soldier_reinforcement_basic")
        local fn = "soldier_reinforcement_basic_0" .. i
        local t = E:register_t(fn, base_t)

        t.render.sprites[1].prefix = "reinforcements_lvl1_0" .. i
        t.info.portrait = "gui_bottom_info_image_soldiers_00" .. tt.portrait_idxs[i]

        if i == 3 then
            t.info.random_name_format = "SOLDIER_REINFORCEMENTS_F_%i_NAME"
            t.info.random_name_count = 4
        end

        E:set_template("re_current_" .. i, t)
    end

    tt = E:register_t("soldier_reinforcement_rebel_militia", "soldier_militia")
    b = balance.upgrades.reinforcements_rebel_militia

    E:add_comps(tt, "reinforcement", "nav_grid", "tween")

    tt.cooldown = b.soldier.cooldown
    tt.health.armor = b.soldier.armor
    tt.health.hp_max = b.soldier.hp_max
    tt.health_bar.offset = vec_2(0, 30)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait_idxs = {28, 30}
    tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_REBEL_MILITIA_M_%i_NAME"
    tt.info.random_name_count = 5
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_kr5.update
    tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.range = b.soldier.melee_attack.range
    tt.motion.max_speed = b.soldier.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = b.soldier.regen_health
    tt.reinforcement.duration = b.soldier.duration
    tt.render.sprites[1].prefix = "soldier_re_rebel_militia_lvl1_0"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.soldier.melee_slot_offset = vec_2(5, 0)
    tt.sound_events.insert = "ReinforcementLinireaTaunt"
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

    for i = 1, 2 do
        local base_t = E:get_template("soldier_reinforcement_rebel_militia")
        local fn = "soldier_reinforcement_rebel_militia_0" .. i
        local t = E:register_t(fn, base_t)

        t.render.sprites[1].prefix = "reinforcements_lvl3_0" .. i
        t.info.portrait = "gui_bottom_info_image_soldiers_00" .. tt.info.portrait_idxs[i]

        if i == 2 then
            t.info.random_name_format = "SOLDIER_REINFORCEMENTS_REBEL_MILITIA_F_%i_NAME"
            t.info.random_name_count = 5
        end
    end

    tt = E:register_t("soldier_reinforcement_shadow_archer", "soldier_militia")
    b = balance.upgrades.reinforcements_shadow_archer

    E:add_comps(tt, "reinforcement", "nav_grid", "ranged", "tween", "dodge")

    tt.cooldown = b.soldier.cooldown
    tt.health.armor = b.soldier.armor
    tt.health.hp_max = b.soldier.hp_max
    tt.health_bar.offset = vec_2(0, 30)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0029"
    tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_SHADOW_ARCHER_%i_NAME"
    tt.info.random_name_count = 10
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_kr5.update
    tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.attacks[1].animation = "melee"
    tt.ranged.attacks[1] = CC("bullet_attack")
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].max_range = b.soldier.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.soldier.ranged_attack.min_range
    tt.ranged.attacks[1].cooldown = b.soldier.ranged_attack.cooldown
    tt.ranged.attacks[1].bullet = "arrow_soldier_re_shadow_archer"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(12, 23)}
    tt.ranged.attacks[1].shoot_time = fts(11)
    tt.ranged.attacks[1].node_prediction = fts(12)
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.melee.range = b.soldier.melee_attack.range
    tt.motion.max_speed = b.soldier.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = b.soldier.regen_health
    tt.reinforcement.duration = b.soldier.duration
    tt.render.sprites[1].prefix = "soldier_re_shadow_archer_lvl1_0"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.sound_events.insert = "ReinforcementDarkArmyTaunt"
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.dodge.disabled = true
    tt.dodge.ranged = false
    tt.dodge.chance = 0
    tt.dodge.animation = "dodge"
    tt.dodge.sound = "HeroVesperDisengageCast"
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)

    for i = 1, 1 do
        local base_t = E:get_template("soldier_reinforcement_shadow_archer")
        local fn = "soldier_reinforcement_shadow_archer_0" .. i
        local t = E:register_t(fn, base_t)

        t.render.sprites[1].prefix = "reinforcements_lvl3_0" .. i + 2
    end

    tt = E:register_t("soldier_reinforcement_special_linirea", "soldier_militia")
    b = balance.upgrades.reinforcements_special_linirea.soldier

    E:add_comps(tt, "reinforcement", "nav_grid", "tween")

    tt.cooldown = b.cooldown
    tt.health.armor = b.armor
    tt.health.hp_max = b.hp_max
    tt.health.spiked_armor = b.spiked_armor
    tt.health_bar.offset = vec_2(3, 45)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0036"
    tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_SPECIAL_LINIREA_%i_NAME"
    tt.info.random_name_count = 1
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_kr5.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(19)
    tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_special_linirea"
    tt.melee.attacks[1].hit_offset = vec_2(30, 10)
    tt.melee.range = b.melee_attack.range
    tt.motion.max_speed = b.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = b.regen_health
    tt.reinforcement.duration = b.duration
    tt.render.sprites[1].prefix = "reinforcement_linirea_lvl_5_unit"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.soldier.melee_slot_offset = vec_2(18, 0)
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt = E:register_t("soldier_reinforcement_special_dark_army", "soldier_militia")
    b = balance.upgrades.reinforcements_special_dark_army

    E:add_comps(tt, "reinforcement", "nav_grid", "tween")

    tt.cooldown = b.soldier.cooldown
    tt.health.armor = b.soldier.armor
    tt.health.hp_max = b.soldier.hp_max
    tt.health_bar.offset = vec_2(0, 38)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0035"
    tt.info.random_name_format = "SOLDIER_REINFORCEMENTS_SPECIAL_DARK_ARMY_%i_NAME"
    tt.info.random_name_count = 1
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_special_dark_army.update
    tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_special_dark_army"
    tt.melee.attacks[1].hit_offset = vec_2(30, 15)
    tt.melee.attacks[1].animation = "melee"
    tt.melee.range = b.soldier.melee_attack.range
    tt.motion.max_speed = b.soldier.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = b.soldier.regen_health
    tt.reinforcement.duration = b.soldier.duration
    tt.render.sprites[1].prefix = "reinforcement_darkarmy_lvl_5_unit"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"run"}
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt.crow_entity = "crow_reinforcement_special_dark_army"
    tt.crows_range = b.crow.target_range
    tt = E:register_t("crow_reinforcement_special_dark_army", "decal_scripted")
    b = balance.upgrades.reinforcements_special_dark_army.crow

    E:add_comps(tt, "force_motion", "melee", "tween")

    tt.main_script.update = scripts.crow_reinforcement_special_dark_army.update
    tt.flight_height = 40
    tt.force_motion.max_a = 1200
    tt.force_motion.max_v = 180
    tt.force_motion.ramp_radius = 30
    tt.force_motion.fr = 0.05
    tt.force_motion.a_step = 20
    tt.start_ts = nil
    tt.render.sprites[1].prefix = "reinforcement_darkarmy_lvl_5_crow"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.melee.attacks[1] = E:clone_c("bullet_attack")
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].range = b.melee_attack.range
    tt.melee.attacks[1].damage_type = b.melee_attack.damage_type
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].hit_time = fts(6)
    tt.melee.attacks[1].hit_fx = "fx_hit_crow_reinforcement_special_dark_army"
    tt.melee.attacks[1].search_cooldown = 0.1
    tt.melee.attacks[1].sound = "HeroBuilderBasicAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(14)
    }
    tt.melee.attacks[1].sound_chance = 0.5
    tt.melee.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.melee.attacks[1].xp_gain_factor = b.melee_attack.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.tween.disabled = false
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {0.5, vec_2(0, 3)}, {1, vec_2(0, 0)}, {1.5, vec_2(0, -3)}, {2, vec_2(0, 0)}}
    tt.tween.props[1].loop = true
    tt.orbit_radius = 20
    tt.orbit_speed = 5 * FPS * math.pi / 180
    tt.target_range = b.target_range
    tt.chase_range = b.chase_range
    tt = E:register_t("soldier_reinforcement_stage_15_denas", "soldier_militia")

    E:add_comps(tt, "melee", "nav_grid", "reinforcement", "tween")

    b = balance.specials.stage15_denas
    tt.health_bar.offset = vec_2(0, 50)
    tt.health.armor = b.armor
    tt.health.hp_max = b.hp_max
    tt.info.i18n_key = "SOLDIER_STAGE_15_DENAS"
    tt.info.enc_icon = 12
    tt.info.portrait = "gui_bottom_info_image_soldiers_0039"
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.random_name_format = nil
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "denas_hero"
    tt.render.sprites[1].name = "spawn"
    tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.sound_events.insert = "Stage15ReinforcementDenasSummon"
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.unit.hit_offset = vec_2(0, 16)
    tt.unit.size = UNIT_SIZE_LARGE
    tt.unit.fade_time_after_death = tt.health.dead_lifetime
    tt.soldier.melee_slot_offset = vec_2(20, 0)
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
    tt.melee.attacks[1].hit_offset = vec_2(30, 20)
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
    tt.melee.attacks[3].hit_offset = vec_2(tt.soldier.melee_slot_offset.x, 0)
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
    tt = E:register_t("soldier_reinforcement_item_summon_blackburn", "soldier_militia")

    E:add_comps(tt, "melee", "timed_attacks", "nav_grid", "reinforcement")

    b = balance.items.summon_blackburn
    tt.health_bar.offset = vec_2(0, 80)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.health.armor = b.armor
    tt.health.hp_max = b.hp_max
    tt.info.i18n_key = "SOLDIER_ITEM_SUMMON_BLACKBURN"
    tt.info.enc_icon = 12
    tt.info.portrait = "gui_bottom_info_image_soldiers_0044"
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.random_name_format = nil
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "item_summon_blackburn_blackburn"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.sound_events.change_rally_point = tt.sound_events.insert
    tt.unit.hit_offset = vec_2(0, 25)
    tt.unit.mod_offset = vec_2(0, 25)
    tt.unit.size = UNIT_SIZE_LARGE
    tt.unit.fade_time_after_death = tt.health.dead_lifetime
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement_item_summon_blackburn.update
    tt.regen.cooldown = 1
    tt.idle_flip.last_animation = "idle"
    tt.idle_flip.chance = 0
    tt.vis.bans = bor(F_ALL)
    tt.melee.range = b.range
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_NIGHTMARE, F_WATER)
    tt.melee.attacks[1].vis_flags = bor(F_BLOCK, F_AREA)
    tt.melee.attacks[1].sound = "CommonNoSwordAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(8)
    }
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].hit_time = fts(13)
    tt.melee.attacks[1].hit_fx = "fx_soldier_reinforcement_item_summon_blackburn_melee_attack_hit"
    tt.melee.attacks[1].hit_offset = vec_2(50, 20)
    tt.melee.attacks[1].animation = "attack1"
    tt.melee.attacks[1].sound = "ItemsBlackburnMeleeAttack"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "attack2"
    tt.timed_attacks.list[1].cooldown = b.special_attack.cooldown
    tt.timed_attacks.list[1].min_range = b.special_attack.min_range
    tt.timed_attacks.list[1].max_range = b.special_attack.max_range
    tt.timed_attacks.list[1].damage_min = b.special_attack.damage_min
    tt.timed_attacks.list[1].damage_max = b.special_attack.damage_max
    tt.timed_attacks.list[1].damage_type = b.special_attack.damage_type
    tt.timed_attacks.list[1].damage_radius = b.special_attack.damage_radius
    tt.timed_attacks.list[1].decal_time = fts(5)
    tt.timed_attacks.list[1].hit_time = fts(25)
    tt.timed_attacks.list[1].enemies_trigger_range = 90
    tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
    tt.timed_attacks.list[1].decal = "decal_soldier_reinforcement_item_summon_blackburn_area_attack"
    tt.timed_attacks.list[1].fx = "fx_soldier_reinforcement_item_summon_blackburn_area_attack"
    tt.timed_attacks.list[1].hit_fx = "fx_soldier_reinforcement_item_summon_blackburn_area_attack_hit"
    tt.timed_attacks.list[1].sound = "ItemsBlackburnRangedAttack"
    tt.reinforcement.duration = b.duration
    tt.reinforcement.fade = nil
    tt.reinforcement.fade_out = nil
    tt.ui.click_rect = r(-25, -5, 50, 70)
    tt.spawn_damage_min = b.spawn.damage_min
    tt.spawn_damage_max = b.spawn.damage_max
    tt.spawn_damage_type = b.spawn.damage_type
    tt.spawn_damage_radius = b.spawn.damage_radius
    tt.spawn_mod = "mod_soldier_reinforcement_item_summon_blackburn_spawn_stun"
    tt.spawn_vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
    tt.spawn_vis_flags = bor(F_AREA)
    tt = E:register_t("soldier_tower_demon_pit_basic_attack", "soldier_militia")
    b = balance.towers.demon_pit

    E:add_comps(tt, "reinforcement", "tween")

    tt.health.armor = b.basic_attack.armor
    tt.health_bar.offset = vec_2(0, 27)
    tt.health.dead_lifetime = 5
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0007"
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
    tt.tween.props[1].keys = {{0, 0}, {fts(5), 255}}
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
    tt = E:register_t("soldier_tower_demon_pit_basic_attack_lvl1", "soldier_tower_demon_pit_basic_attack")
    tt.health.hp_max = b.basic_attack.hp_max[1]
    tt.melee.attacks[1].cooldown = b.basic_attack.melee_attack.cooldown[1]
    tt.melee.attacks[1].damage_max = b.basic_attack.melee_attack.damage_max[1]
    tt.melee.attacks[1].damage_min = b.basic_attack.melee_attack.damage_min[1]
    tt.level = 1
    tt = E:register_t("soldier_tower_demon_pit_basic_attack_lvl2", "soldier_tower_demon_pit_basic_attack")
    tt.health.hp_max = b.basic_attack.hp_max[2]
    tt.melee.attacks[1].cooldown = b.basic_attack.melee_attack.cooldown[2]
    tt.melee.attacks[1].damage_max = b.basic_attack.melee_attack.damage_max[2]
    tt.melee.attacks[1].damage_min = b.basic_attack.melee_attack.damage_min[2]
    tt.level = 2
    tt = E:register_t("soldier_tower_demon_pit_basic_attack_lvl3", "soldier_tower_demon_pit_basic_attack")
    tt.health.hp_max = b.basic_attack.hp_max[3]
    tt.melee.attacks[1].cooldown = b.basic_attack.melee_attack.cooldown[3]
    tt.melee.attacks[1].damage_max = b.basic_attack.melee_attack.damage_max[3]
    tt.melee.attacks[1].damage_min = b.basic_attack.melee_attack.damage_min[3]
    tt.level = 3
    tt = E:register_t("soldier_tower_demon_pit_basic_attack_lvl4", "soldier_tower_demon_pit_basic_attack")
    tt.health.hp_max = b.basic_attack.hp_max[4]
    tt.melee.attacks[1].cooldown = b.basic_attack.melee_attack.cooldown[4]
    tt.melee.attacks[1].damage_max = b.basic_attack.melee_attack.damage_max[4]
    tt.melee.attacks[1].damage_min = b.basic_attack.melee_attack.damage_min[4]
    tt.level = 4
    tt = E:register_t("big_guy_tower_demon_pit_lvl4", "soldier_militia")
    b = balance.towers.demon_pit

    E:add_comps(tt, "reinforcement", "tween")

    tt.health.armor = b.big_guy.armor
    tt.health_bar.offset = vec_2(0, 42)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health_level = b.big_guy.hp_max
    tt.explosion_damage = b.big_guy.explosion_damage
    tt.explosion_range = b.big_guy.explosion_range
    tt.explosion_damage_type = b.big_guy.explosion_damage_type
    tt.explosion_sound = "TowerDemonPitDemonExplosion"
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0006"
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
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.soldier.melee_slot_offset = vec_2(15, 0)
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt = E:register_t("soldier_hero_builder_worker", "soldier_militia")
    b = balance.heroes.hero_builder

    E:add_comps(tt, "reinforcement", "tween")

    tt.health.armor = b.overtime_work.soldier.armor
    tt.health.hp_max = nil
    tt.health_bar.offset = vec_2(0, 35)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0034"
    tt.info.random_name_format = "SOLDIER_HERO_BUILDER_WORKER_%i_NAME"
    tt.info.random_name_count = 8
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_reinforcement.update
    tt.melee.attacks[1].cooldown = b.overtime_work.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = nil
    tt.melee.attacks[1].damage_min = nil
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.range = b.overtime_work.soldier.melee_attack.range
    tt.motion.max_speed = b.overtime_work.soldier.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = 0
    tt.reinforcement.duration = b.overtime_work.soldier.duration
    tt.render.sprites[1].prefix = "hero_obdul_skill_5_soldier"
    tt.render.sprites[1].name = "raise"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.36)
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt = E:register_t("soldier_tower_rocket_gunners_lvl1", "soldier_militia")

    E:add_comps(tt, "nav_grid")

    b = balance.towers.rocket_gunners

    E:add_comps(tt, "ranged", "tween")

    tt.info.portrait = "gui_bottom_info_image_soldiers_0014"
    tt.info.random_name_format = "SOLDIER_TOWER_ROCKET_GUNNERS_%i_NAME"
    tt.info.random_name_count = 10
    tt.main_script.insert = scripts.soldier_tower_rocket_gunners.insert
    tt.main_script.update = scripts.soldier_tower_rocket_gunners.update
    tt.render.sprites[1].prefix = "rocket_gunners_tower_lvl1_gunner"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "take_off"
    tt.render.sprites[1].angles.walk = {"idle_air"}
    tt.render.sprites[1].angles.attack_floor = {"attack_floor", "attack_floor_back", "attack_floor"}
    tt.render.sprites[1].angles.attack_air = {"attack_air", "attack_air_back", "attack_air"}
    tt.render.sprites[1].angles.idle_air = {"idle_air", "idle_air_back", "idle_air"}
    tt.render.sprites[1].angles.idle_floor = {"idle_floor", "idle_floor_back", "idle_floor"}
    tt.render.sprites[1].angles_flip_vertical = {
        attack_air = true,
        idle_air = true,
        attack_floor = true,
        idle_floor = true
    }
    tt.flight_height = 65
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 12)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 13)
    tt.unit.level = 1
    tt.unit.death_animation = "death_air"
    tt.unit.show_blood_pool = false
    tt.unit.hide_after_death = true
    tt.soldier.melee_slot_spread = vec_2(-10, -10)
    tt.soldier.melee_slot_offset = vec_2(10, 0)
    tt.vis.bans = 0
    tt.vis_bans_before_take_off = F_ALL
    tt.vis_bans_after_take_off = 0
    tt.health.hp_max = b.soldier.hp[1]
    tt.health.armor = b.soldier.armor[1]
    tt.health_bar.y_offset = 30
    tt.health.dead_lifetime = b.soldier.dead_lifetime
    tt.regen.health = b.soldier.regen_hp[1]
    tt.motion.max_speed = b.soldier.speed_flight
    tt.speed_flight = b.soldier.speed_flight
    tt.speed_ground = b.soldier.speed_ground
    tt.melee.range = b.soldier.melee_attack.range
    tt.melee.attacks[1].cooldown = b.soldier.melee_attack.cooldown
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min[1]
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max[1]
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.attacks[1].animation = "attack_floor"
    tt.melee.attacks[1].hit_fx = "fx_bullet_soldier_tower_rocket_gunners_hit"
    tt.melee.attacks[1].hit_decal = "fx_bullet_soldier_tower_rocket_gunners_floor"
    tt.melee.attacks[1].hit_offset = vec_2(34, 10)
    tt.melee.arrived_slot_animation = "idle_floor"
    tt.ranged.attacks[1].animation = "attack_air"
    tt.ranged.attacks[1].bullet = "bullet_soldier_tower_rocket_gunners"
    tt.ranged.attacks[1].cooldown = b.soldier.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.soldier.ranged_attack.max_range[1]
    tt.ranged.attacks[1].min_range = b.soldier.ranged_attack.min_range[1]
    tt.ranged.attacks[1].shoot_time = fts(6)
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ui.click_rect = r(-13, 7, 25, 27)
    tt.ui.click_rect_offset_y = 0
    tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
    tt.nav_rally.delay_max = nil
    tt.spawn_fx = "fx_tower_rocket_gunners_take_off"
    tt.shadow_decal_t = "decal_soldier_tower_rocket_gunners_shadow"
    tt.land_fx = "fx_soldier_tower_rocket_gunners_land"
    tt.distance_to_land_fx = 10
    tt.current_mode = 0
    tt.arrive_epsilon = 0.5
    tt.fly_strenght = 5
    tt.fly_frequency = 13
    tt.spawn_sort_y_offset = -9
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].interp = "sine"
    tt.tween.props[1].keys = {{fts(0), vec_2(0, tt.flight_height)},
                              {fts(tt.fly_frequency), vec_2(0, tt.flight_height - tt.fly_strenght)},
                              {fts(tt.fly_frequency * 2), vec_2(0, tt.flight_height)}}
    tt.tween.props[1].loop = true
    tt.tween.props[1].disabled = true
    tt.tween.props[1].remove = false
    tt.sound_take_off = "TowerRocketGunnersTakeoff"
    tt = E:register_t("soldier_tower_rocket_gunners_lvl2", "soldier_tower_rocket_gunners_lvl1")
    b = balance.towers.rocket_gunners
    tt.info.portrait = "gui_bottom_info_image_soldiers_0015"
    tt.unit.level = 2
    tt.render.sprites[1].prefix = "rocket_gunners_tower_lvl2_gunner"
    tt.health.hp_max = b.soldier.hp[2]
    tt.health.armor = b.soldier.armor[2]
    tt.regen.health = b.soldier.regen_hp[2]
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min[2]
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max[2]
    tt.ranged.attacks[1].max_range = b.soldier.ranged_attack.max_range[2]
    tt.ranged.attacks[1].min_range = b.soldier.ranged_attack.min_range[2]
    tt = E:register_t("soldier_tower_rocket_gunners_lvl3", "soldier_tower_rocket_gunners_lvl1")
    b = balance.towers.rocket_gunners
    tt.info.portrait = "gui_bottom_info_image_soldiers_0016"
    tt.unit.level = 3
    tt.render.sprites[1].prefix = "rocket_gunners_tower_lvl3_gunner"
    tt.health.hp_max = b.soldier.hp[3]
    tt.health.armor = b.soldier.armor[3]
    tt.regen.health = b.soldier.regen_hp[3]
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min[3]
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max[3]
    tt.ranged.attacks[1].max_range = b.soldier.ranged_attack.max_range[3]
    tt.ranged.attacks[1].min_range = b.soldier.ranged_attack.min_range[3]
    tt = E:register_t("soldier_tower_rocket_gunners_lvl4", "soldier_tower_rocket_gunners_lvl1")

    E:add_comps(tt, "powers")

    b = balance.towers.rocket_gunners
    tt.info.portrait = "gui_bottom_info_image_soldiers_0017"
    tt.unit.level = 4
    tt.render.sprites[1].prefix = "rocket_gunners_tower_lvl4_gunner"
    tt.health.hp_max = b.soldier.hp[4]
    tt.health.armor = b.soldier.armor[4]
    tt.health_bar.y_offset = 33
    tt.regen.health = b.soldier.regen_hp[4]
    tt.render.sprites[1].angles.phosphoric_coating_air = {"phosphoric_coating_air", "phosphoric_coating_air_back",
                                                          "phosphoric_coating_air"}
    tt.render.sprites[1].angles.phosphoric_coating_floor = {"phosphoric_coating_floor", "phosphoric_coating_floor_back",
                                                            "phosphoric_coating_floor"}
    tt.render.sprites[1].angles.attack_air = {"attack_air", "attack_air_back", "attack_air"}
    tt.render.sprites[1].angles.idle_air = {"idle_air", "idle_air_back", "idle_air"}
    tt.render.sprites[1].angles.idle_floor = {"idle_floor", "idle_floor_back", "idle_floor"}
    tt.render.sprites[1].angles_flip_vertical = {
        idle_air = true,
        phosphoric_coating_air = true,
        attack_air = true,
        phosphoric_coating_floor = true,
        idle_floor = true,
        attack_floor = true
    }
    tt.render.sprites[1].scale = vec_2(1.1, 1.1)
    tt.melee.attacks[1].damage_min = b.soldier.melee_attack.damage_min[4]
    tt.melee.attacks[1].damage_max = b.soldier.melee_attack.damage_max[4]
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "phosphoric_coating_floor"
    tt.melee.attacks[2].disabled = true
    tt.melee.attacks[2].hit_fx = "fx_bullet_soldier_tower_rocket_gunners_phosphoric_hit"
    tt.melee.attacks[2].hit_decal = "fx_bullet_soldier_tower_rocket_gunners_phosphoric_floor"
    tt.melee.attacks[2].damage_radius = b.soldier.phosphoric.damage_radius
    tt.melee.attacks[2].damage_area_max = b.soldier.phosphoric.damage_area_max
    tt.melee.attacks[2].damage_area_min = b.soldier.phosphoric.damage_area_min
    tt.ranged.attacks[1].max_range = b.soldier.ranged_attack.max_range[4]
    tt.ranged.attacks[1].min_range = b.soldier.ranged_attack.min_range[4]
    tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
    tt.ranged.attacks[2].animation = "phosphoric_coating_air"
    tt.ranged.attacks[2].bullet = "bullet_soldier_tower_rocket_gunners_phosphoric"
    tt.ranged.attacks[2].disabled = true
    tt.ranged.attacks[2].bullet_start_offset = {vec_2(0, 0), vec_2(0, 0), vec_2(0, 0)}
    tt.ranged.attacks[2].bullet_start_offset_relative = vec_2(15, 14)
    tt.ranged.attacks[2].shoot_time = fts(7)
    tt.ranged.attacks[3] = E:clone_c("bullet_attack")
    tt.ranged.attacks[3].animation = "sting_missiles_air"
    tt.ranged.attacks[3].bullet = "bullet_soldier_tower_rocket_gunners_sting_missiles"
    tt.ranged.attacks[3].disabled = true
    tt.ranged.attacks[3].bullet_start_offset = nil
    tt.ranged.attacks[3].bullet_start_offset_relative = vec_2(0, 45)
    tt.ranged.attacks[3].cooldown = 0
    tt.ranged.attacks[3].max_range = nil
    tt.ranged.attacks[3].min_range = nil
    tt.ranged.attacks[3].shoot_time = fts(12)
    tt.ranged.attacks[3].vis_flags = bor(F_INSTAKILL, F_RANGED, F_CUSTOM)
    tt.ranged.attacks[3].vis_bans = bor(F_BOSS, F_MINIBOSS, F_NIGHTMARE)
    tt.ranged.attacks[3].mark_mod = "mod_soldier_tower_rocket_gunners_sting_missiles_mark"
    tt.powers.phosphoric = E:clone_c("power")
    tt.powers.phosphoric.damage_factor = b.soldier.phosphoric.damage_factor
    tt.powers.phosphoric.armor_reduction = b.soldier.phosphoric.armor_reduction
    tt.powers.sting_missiles = E:clone_c("power")
    tt.powers.sting_missiles.max_range = b.soldier.sting_missiles.max_range
    tt.powers.sting_missiles.min_range = b.soldier.sting_missiles.min_range
    tt.powers.sting_missiles.hp_max_target = b.soldier.sting_missiles.hp_max_target
    tt = E:register_t("soldier_tower_necromancer_skeleton", "soldier_militia")
    b = balance.towers.necromancer

    E:add_comps(tt, "reinforcement", "count_group")

    tt.health_bar.offset = vec_2(0, 29)
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0018"
    tt.info.i18n_key = "SOLDIER_TOWER_NECROMANCER_SKELETON"
    tt.info.random_name_count = nil
    tt.info.random_name_format = nil
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.soldier_tower_necromancer_skeleton.update
    tt.melee.attacks[1].hit_time = fts(8)
    tt.melee.range = b.skeleton.melee_attack.range
    tt.motion.max_speed = b.skeleton.max_speed
    tt.regen.cooldown = 1
    tt.regen.health = 0
    tt.reinforcement.fade = false
    tt.render.sprites[1].prefix = "necromancer_tower_skeleton_warrior"
    tt.render.sprites[1].name = "spawn"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 11)
    tt.unit.level = 0
    tt.unit.fade_time_after_death = b.skeleton.dead_lifetime
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt.spawn_fx = "fx_soldier_tower_necromancer_skeleton_spawn"
    tt.spawn_fx_delay = 5
    tt.spawn_delay_min = b.spawn_delay_min
    tt.spawn_delay_max = b.spawn_delay_max
    tt.spawn_sound = "TowerNecromancerSkeletonSummon"
    tt.count_group.name = "necromancer_skeletons"
    tt.count_group_type = COUNT_GROUP_CONCURRENT
    tt.count_group_max = b.curse.max_units_total
    tt.is_golem = false
    tt.patrol_pos_offset = vec_2(15, 10)
    tt.patrol_min_cd = 5
    tt.patrol_max_cd = 10
    tt = E:register_t("soldier_tower_necromancer_skeleton_lvl1", "soldier_tower_necromancer_skeleton")
    b = balance.towers.necromancer.skeleton
    tt.health.armor = b.armor[1]
    tt.health.hp_max = b.hp_max[1]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[1]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[1]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[1]
    tt.unit.level = 1
    tt = E:register_t("soldier_tower_necromancer_skeleton_lvl2", "soldier_tower_necromancer_skeleton")
    b = balance.towers.necromancer.skeleton
    tt.health.armor = b.armor[2]
    tt.health.hp_max = b.hp_max[2]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[2]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[2]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[2]
    tt.unit.level = 2
    tt = E:register_t("soldier_tower_necromancer_skeleton_lvl3", "soldier_tower_necromancer_skeleton")
    b = balance.towers.necromancer.skeleton
    tt.health.armor = b.armor[3]
    tt.health.hp_max = b.hp_max[3]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[3]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[3]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[3]
    tt.unit.level = 3
    tt = E:register_t("soldier_tower_necromancer_skeleton_lvl4", "soldier_tower_necromancer_skeleton")
    b = balance.towers.necromancer.skeleton
    tt.health.armor = b.armor[4]
    tt.health.hp_max = b.hp_max[4]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[4]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[4]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[4]
    tt.unit.level = 4
    tt = E:register_t("soldier_tower_necromancer_skeleton_golem", "soldier_tower_necromancer_skeleton")
    b = balance.towers.necromancer.skeleton_golem
    tt.health_bar.offset = vec_2(0, 47)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.info.portrait = "gui_bottom_info_image_soldiers_0019"
    tt.info.i18n_key = "SOLDIER_TOWER_NECROMANCER_SKELETON_GOLEM"
    tt.melee.range = b.melee_attack.range
    tt.motion.max_speed = b.max_speed
    tt.regen.cooldown = b.regen_cooldown
    tt.regen.health = 0
    tt.render.sprites[1].prefix = "necromancer_tower_bone_golem"
    tt.soldier.melee_slot_offset = vec_2(15, 0)
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 15)
    tt.unit.fade_time_after_death = b.dead_lifetime
    tt.unit.size = UNIT_SIZE_LARGE
    tt.spawn_fx = "fx_soldier_tower_necromancer_skeleton_golem_spawn"
    tt.spawn_delay = 3
    tt.is_golem = true
    tt = E:register_t("soldier_tower_necromancer_skeleton_golem_lvl1", "soldier_tower_necromancer_skeleton_golem")
    b = balance.towers.necromancer.skeleton_golem
    tt.health.armor = b.armor[1]
    tt.health.hp_max = b.hp_max[1]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[1]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[1]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[1]
    tt.unit.level = 1
    tt = E:register_t("soldier_tower_necromancer_skeleton_golem_lvl2", "soldier_tower_necromancer_skeleton_golem")
    b = balance.towers.necromancer.skeleton_golem
    tt.health.armor = b.armor[2]
    tt.health.hp_max = b.hp_max[2]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[2]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[2]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[2]
    tt.unit.level = 2
    tt = E:register_t("soldier_tower_necromancer_skeleton_golem_lvl3", "soldier_tower_necromancer_skeleton_golem")
    b = balance.towers.necromancer.skeleton_golem
    tt.health.armor = b.armor[3]
    tt.health.hp_max = b.hp_max[3]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[3]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[3]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[3]
    tt.unit.level = 3
    tt = E:register_t("soldier_tower_necromancer_skeleton_golem_lvl4", "soldier_tower_necromancer_skeleton_golem")
    b = balance.towers.necromancer.skeleton_golem
    tt.health.armor = b.armor[4]
    tt.health.hp_max = b.hp_max[4]
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown[4]
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max[4]
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min[4]
    tt.unit.level = 4
    tt = E:register_t("soldier_stage_10_ymca", "soldier_militia")
    b = balance.specials.stage10_ymca

    E:add_comps(tt, "reinforcement", "nav_grid", "tween")

    tt.health.armor = b.soldier.armor
    tt.health.hp_max = b.soldier.hp
    tt.health_bar.offset = vec_2(0, 30)
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].scale = vec_1(1.1)
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.sound_events.insert = nil
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.unit.level = 0
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt = E:register_t("soldier_stage_10_ymca_indio", "soldier_stage_10_ymca")
    tt.render.sprites[1].prefix = "ymca_ymca_indio"
    tt.info.portrait = "gui_bottom_info_image_soldiers_0020"
    tt = E:register_t("soldier_stage_10_ymca_constructor", "soldier_stage_10_ymca")
    tt.render.sprites[1].prefix = "ymca_ymca_constructor"
    tt.render.sprites[1].anchor = vec_2(0.5, 1)
    tt.render.sprites[1].offset.y = 35
    tt.info.portrait = "gui_bottom_info_image_soldiers_0023"
    tt = E:register_t("soldier_stage_10_ymca_biker", "soldier_stage_10_ymca")
    tt.render.sprites[1].prefix = "ymca_ymca_biker"
    tt.info.portrait = "gui_bottom_info_image_soldiers_0022"
    tt = E:register_t("soldier_stage_10_ymca_policia", "soldier_stage_10_ymca")
    tt.render.sprites[1].prefix = "ymca_ymca_policia"
    tt.info.portrait = "gui_bottom_info_image_soldiers_0021"
    tt = E:register_t("soldier_stage_11_veznan_skill_soldiers", "soldier_militia")
    b = balance.specials.stage11_veznan.skill_soldiers.soldier

    E:add_comps(tt, "reinforcement", "tween")

    tt.health.armor = b.armor
    tt.health_bar.offset = vec_2(0, 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health.hp_max = b.hp_max
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.portrait = "gui_bottom_info_image_soldiers_0024"
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.3)
    tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
    tt.soldier.melee_slot_offset = vec_2(3, 0)
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.unit.hit_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE, F_LYCAN)
    tt.spawn_fx = "fx_stage_11_veznan_soldiers_spawn"
    tt.spawn_fx_top = "fx_stage_11_veznan_soldiers_spawn_top"
    tt.spawn_delay = fts(2)
    tt.idle_time = fts(8)
    tt.nodes_from_start = b.nodes_from_start

    tt = E:register_t("boss_pig", "boss")

    local b = balance.enemies.werebeasts.boss

    E:add_comps(tt, "melee", "timed_attacks", "auras")

    tt.enemy.gold = 1
    tt.enemy.lives_cost = 999
    tt.enemy.melee_slot = vec_2(40, 0)
    tt.health.armor = b.armor
    tt.health.dead_lifetime = 100
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, 100)
    tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
    tt.info.enc_icon = 26
    tt.info.i18n_key = "ENEMY_BOSS_PIG"
    tt.info.portrait = "info_portraits_enemies_0010"
    tt.info.portrait_boss = "boss_health_bar_icon_0001"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.boss_pig.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].prefix = "GoregrindDef"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk1", "walk2", "walk2"}
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.unit.can_explode = false
    tt.unit.hit_offset = vec_2(0, 40)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 30)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_LARGE
    tt.vis.bans = bor(F_RANGED)
    tt.vis.flags_jumping = bor(F_ENEMY, F_BOSS)
    tt.vis.bans_jumping = bor(F_RANGED, F_BLOCK, F_MOD)
    tt.vis.flags_normal = bor(F_ENEMY, F_BOSS)
    tt.vis.bans_normal = 0
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(22)
    tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
    tt.melee.attacks[1].damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
    tt.melee.attacks[1].hit_decal = "decal_boss_pig_ground_attack"
    tt.melee.attacks[1].hit_fx = "decal_boss_pig_attack_dust"
    tt.melee.attacks[1].hit_time = fts(14)
    tt.melee.attacks[1].hit_offset = vec_2(50, 0)
    tt.melee.attacks[1].uninterruptible = true
    tt.melee.attacks[1].sound = "Stage06BossPigAttack"
    tt.aura_damage_on_fall = "aura_boss_pig_damage_on_fall"
    tt.shadow = "decal_werebeast_boss_shadow"
    tt.sound_jump = "Stage06BossPigJump"
    tt.sound_land = "Stage06BossPigLand"
    tt.sound_falling = "Stage06BossPigFalling"
    tt.sound_events.death = "Stage06BossPigDeath"
    tt = E:register_t("decal_boss_pig_pool", "decal_scripted")

    E:add_comps(tt, "taunts", "editor")

    tt.render.sprites[1].exo = true
    tt.render.sprites[1].prefix = "GoregrindPoolDef"
    tt.render.sprites[1].name = "sleeping"
    tt.main_script.update = scripts.decal_boss_pig_pool.update
    tt.taunts.delay_min = 10
    tt.taunts.delay_max = 20
    tt.taunts.sets = {}
    tt.taunts.sets.from_pool = CC("taunt_set")
    tt.taunts.sets.from_pool.format = "LV06_BOSS_TAUNT_%02i"
    tt.taunts.sets.from_pool.end_idx = 6
    tt.sound_horn = "Stage06BossPigHorn"
    tt = E:register_t("decal_boss_pig_flying", "decal")
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "GoregrindFlying_asst_goregrind_flying"
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt = E:register_t("decal_boss_pig_smoke", "decal_tween")
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "werebeast_boss_death_and_fall_dust"
    tt.render.sprites[1].name = "run"
    tt.render.sprites[1].loop = false
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt = E:register_t("decal_boss_pig_attack_dust", "decal_tween")
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "werebeast_boss_attack_dust"
    tt.render.sprites[1].loop = false
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt.render.sprites[1].scale = vec_2(0.5, 0.5)
    tt = E:register_t("decal_boss_pig_ground_fall", "decal_tween")
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "werebeast_boss_decal"
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 255}, {fts(22), 255}, {fts(22) + fts(5), 0}}
    tt.tween.remove = true
    tt = E:register_t("decal_boss_pig_ground_attack", "decal_boss_pig_ground_fall")
    tt.tween.props[1].keys = {{0, 255}, {fts(18), 255}, {fts(18) + fts(5), 0}}
    tt = E:register_t("decal_hero_mecha_ultimate", "decal_tween")
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "hero_onagro_ultimate_decal"
    tt.render.sprites[1].z = Z_DECALS
    tt.tween.props[1].keys = {{1, 255}, {9, 255}, {12, 0}}
    tt.tween.run_once = true
    tt = E:register_t("boss_corrupted_denas", "boss")

    E:add_comps(tt, "melee", "timed_attacks")

    b = balance.enemies.cult_of_the_overseer.boss_corrupted_denas
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.boss_corrupted_denas.update
    tt.motion.max_speed = b.speed
    tt.enemy.lives_cost = 999
    tt.enemy.melee_slot = vec_2(40, 0)
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health.dead_lifetime = 100
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, 100)
    tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
    tt.render.sprites[1].prefix = "denas_character"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk", "walk", "walk_down"}
    tt.info.i18n_key = "ENEMY_BOSS_CORRUPTED_DENAS"
    tt.info.portrait_boss = "boss_health_bar_icon_0002"
    tt.info.portrait = "info_portraits_enemies_0027"
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(17)
    tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
    tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
    tt.melee.attacks[1].hit_fx_offset = vec_2(20, -20)
    tt.melee.attacks[1].hit_fx = "decal_boss_corrupted_denas_hit"
    tt.melee.attacks[1].sound = "Stage11BossCorruptedDenasAttack"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "spawn_glareling"
    tt.timed_attacks.list[1].cooldown = b.spawn_entities.cooldown
    tt.timed_attacks.list[1].min_range = 60
    tt.timed_attacks.list[1].max_range = b.spawn_entities.max_range
    tt.timed_attacks.list[1].distance_between_entities = 40
    tt.timed_attacks.list[1].entities_amount = 3
    tt.timed_attacks.list[1].delay_between = fts(5)
    tt.timed_attacks.list[1].idle_time = fts(6)
    tt.timed_attacks.list[1].bullet_start_offset = vec_2(0, 65)
    tt.timed_attacks.list[1].bullet = "bullet_boss_corrupted_denas_spawn_entities"
    tt.life_threshold_stun = b.life_threshold_stun
    tt.cult_leader_template_name = "decal_stage_11_cult_leader"
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.unit.can_explode = false
    tt.unit.hit_offset = vec_2(0, 40)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 30)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_LARGE
    tt.sound_transform_in = "Stage11BossCorruptedDenasTransformationIn"
    tt.sound_transform_out = "Stage11BossCorruptedDenasTransformationOut"
    tt = E:register_t("boss_cult_leader", "boss")

    E:add_comps(tt, "melee", "timed_attacks", "glare_kr5")

    b = balance.enemies.void_beyond.boss_cult_leader
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.boss_cult_leader.update
    tt.motion.max_speed = b.speed
    tt.enemy.lives_cost = 999
    tt.enemy.melee_slot = vec_2(40, 0)
    tt.health.armor = b.close_armor
    tt.health.magic_armor = b.close_magic_armor
    tt.health.dead_lifetime = 100
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, 100)
    tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
    tt.render.sprites[1].prefix = "mutamydriasDef"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].flip_x = false
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.idle = {"walk", "walk", "walk"}
    tt.info.i18n_key = "ENEMY_BOSS_CULT_LEADER"
    tt.info.portrait_boss = "boss_health_bar_icon_0003"
    tt.info.portrait = "info_portraits_enemies_0040"
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(17)
    tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
    tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
    tt.melee.attacks[1].hit_fx_offset = vec_2(20, -20)
    tt.melee.attacks[2] = E:clone_c("area_attack")
    tt.melee.attacks[2].animation = "areaattack"
    tt.melee.attacks[2].cooldown = b.area_attack.cooldown
    tt.melee.attacks[2].damage_max = b.area_attack.damage_max
    tt.melee.attacks[2].damage_min = b.area_attack.damage_min
    tt.melee.attacks[2].hit_time = fts(17)
    tt.melee.attacks[2].damage_radius = b.area_attack.damage_radius
    tt.melee.attacks[2].damage_type = bor(b.area_attack.damage_type, DAMAGE_NO_DODGE)
    tt.melee.attacks[2].min_count = b.area_attack.min_count
    tt.melee.attacks[2].hit_fx = "fx_stage_15_boss_cult_leader_ray"
    tt.melee.attacks[2].hit_decal = "decal_stage_15_boss_cult_leader_ray"
    tt.melee.attacks[2].hit_decal_offset = vec_2(80, 0)
    tt.melee.attacks[2].sound = "Stage15MydriasRay"
    tt.life_threshold_teleport = b.life_threshold_teleport
    tt.teleport_away_duration = b.life_threshold_teleport.away_duration
    tt.teleport_pos = {vec_2(746, 444), vec_2(695, 290), vec_2(460, 350)}
    tt.teleport_path = {2, 4, 3}
    tt.cult_leader_template_name = "controller_stage_15_cult_leader_tower"
    tt.glare_template_name = "controller_terrain_3_stage_15_glare"
    tt.ui.click_rect = r(-35, 0, 70, 80)
    tt.unit.can_explode = false
    tt.unit.hit_offset = vec_2(0, 40)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 30)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_LARGE
    tt.sound_transform_in = "Stage11BossCorruptedDenasTransformationIn"
    tt.sound_transform_out = "Stage11BossCorruptedDenasTransformationOut"
    tt.sound_burrow_in = "Stage15MydriasBurrowIn"
    tt.sound_burrow_out = "Stage15MydriasBurrowOut"
    tt.sound_uncloak = "Stage15MydriasUncloak"
    tt.block_attack = {}
    tt.block_attack.delay = fts(20)
    tt.block_attack.damage_min = b.block_attack.damage_min
    tt.block_attack.damage_max = b.block_attack.damage_max
    tt.block_attack.damage_type = b.block_attack.damage_type
    tt.block_attack.radius = b.block_attack.radius
    tt.block_attack.vis = 0
    tt.block_attack.bans = bor(F_FLYING)
    tt.block_attack.min_targets = 1
    tt.open_armor = b.open_armor
    tt.close_armor = b.close_armor
    tt.open_magic_armor = b.open_magic_armor
    tt.close_magic_armor = b.close_magic_armor
    tt.time_death = 3
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.denas_ray_resistance = b.denas_ray_resistance

    tt = E:register_t("hero5", "hero")
    tt.relic_slot = {}
    tt.relic_slot.relid_id = nil
    tt.hero.tombstone_concurrent_with_death = nil
    tt.hero.tombstone_force_over_path = nil
    tt.hero.tombstone_respawn_animation = nil
    tt.hero.respawn_animation = "respawn"

    tt = E:register_t("hero_muyrn", "hero5")
    b = balance.heroes.hero_muyrn

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = b.basic_melee.damage_max
    tt.hero.level_stats.melee_damage_min = b.basic_melee.damage_min
    tt.hero.level_stats.ranged_damage_max = b.basic_ranged.damage_max
    tt.hero.level_stats.ranged_damage_min = b.basic_ranged.damage_min
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.sentinel_wisps = E:clone_c("hero_skill")
    tt.hero.skills.sentinel_wisps.cooldown = b.sentinel_wisps.cooldown
    tt.hero.skills.sentinel_wisps.max_summons = b.sentinel_wisps.max_summons
    tt.hero.skills.sentinel_wisps.wisp_damage_max = b.sentinel_wisps.wisp.damage_max
    tt.hero.skills.sentinel_wisps.wisp_damage_min = b.sentinel_wisps.wisp.damage_min
    tt.hero.skills.sentinel_wisps.wisp_duration = b.sentinel_wisps.wisp.duration
    tt.hero.skills.sentinel_wisps.hr_available = true
    tt.hero.skills.sentinel_wisps.hr_icon = "0012"
    tt.hero.skills.sentinel_wisps.hr_order = 1
    tt.hero.skills.sentinel_wisps.hr_cost = {2, 2, 2}
    tt.hero.skills.sentinel_wisps.xp_gain = b.sentinel_wisps.xp_gain
    tt.hero.skills.sentinel_wisps.key = "SENTINEL_WISPS"
    tt.hero.skills.verdant_blast = E:clone_c("hero_skill")
    tt.hero.skills.verdant_blast.cooldown = b.verdant_blast.cooldown
    tt.hero.skills.verdant_blast.damage_max = b.verdant_blast.damage_max
    tt.hero.skills.verdant_blast.damage_min = b.verdant_blast.damage_min
    tt.hero.skills.verdant_blast.hr_available = true
    tt.hero.skills.verdant_blast.hr_icon = "0014"
    tt.hero.skills.verdant_blast.hr_order = 2
    tt.hero.skills.verdant_blast.hr_cost = {3, 3, 3}
    tt.hero.skills.verdant_blast.xp_gain = b.verdant_blast.xp_gain
    tt.hero.skills.verdant_blast.key = "VERDANT_BLAST"
    tt.hero.skills.leaf_whirlwind = E:clone_c("hero_skill")
    tt.hero.skills.leaf_whirlwind.cooldown = b.leaf_whirlwind.cooldown
    tt.hero.skills.leaf_whirlwind.duration = b.leaf_whirlwind.duration
    tt.hero.skills.leaf_whirlwind.damage_max = b.leaf_whirlwind.damage_max
    tt.hero.skills.leaf_whirlwind.damage_min = b.leaf_whirlwind.damage_min
    tt.hero.skills.leaf_whirlwind.heal_min = b.leaf_whirlwind.heal_min
    tt.hero.skills.leaf_whirlwind.heal_max = b.leaf_whirlwind.heal_max
    tt.hero.skills.leaf_whirlwind.hr_available = true
    tt.hero.skills.leaf_whirlwind.hr_icon = "0013"
    tt.hero.skills.leaf_whirlwind.hr_order = 3
    tt.hero.skills.leaf_whirlwind.hr_cost = {2, 2, 2}
    tt.hero.skills.leaf_whirlwind.xp_gain = b.leaf_whirlwind.xp_gain
    tt.hero.skills.leaf_whirlwind.key = "LEAF_WHIRLWIND"
    tt.hero.skills.faery_dust = E:clone_c("hero_skill")
    tt.hero.skills.faery_dust.cooldown = b.faery_dust.cooldown
    tt.hero.skills.faery_dust.damage_factor = b.faery_dust.damage_factor
    tt.hero.skills.faery_dust.duration = b.faery_dust.duration
    tt.hero.skills.faery_dust.hr_available = true
    tt.hero.skills.faery_dust.hr_icon = "0011"
    tt.hero.skills.faery_dust.hr_order = 4
    tt.hero.skills.faery_dust.hr_cost = {1, 1, 1}
    tt.hero.skills.faery_dust.xp_gain = b.faery_dust.xp_gain
    tt.hero.skills.faery_dust.key = "FAERY_DUST"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_muyrn_ultimate"
    tt.hero.skills.ultimate.slow_factor = b.ultimate.slow_factor
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.skills.ultimate.hr_available = true
    tt.hero.skills.ultimate.hr_icon = "0015"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "ROOT_DEFENDER"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.entity = b.ultimate.entity
    tt.hero.team = TEAM_LINIREA
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.hero.fn_level_up = scripts.hero_muyrn.level_up
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0003"
    tt.info.i18n_key = "HERO_MUYRN"
    tt.info.portrait = "portraits_hero" .. "_0005"
    tt.info.ultimate_icon = "0003"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.info.damage_icon = "magic"
    tt.main_script.insert = scripts.hero_muyrn.insert
    tt.main_script.update = scripts.hero_muyrn.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.sound_events.change_rally_point = "HeroNyruTaunt"
    tt.sound_events.death = "HeroNyruDeath"
    tt.sound_events.respawn = "HeroNyruTauntIntro"
    tt.sound_events.hero_room_select = "HeroNyruTauntSelect"
    tt.soldier.melee_slot_offset = vec_2(10, 0)
    tt.health_bar.offset = vec_2(0, 38)
    tt.unit.hit_offset = vec_2(0, 16)
    tt.unit.mod_offset = vec_2(0, 22)
    tt.ui.click_rect = r(-25, -3, 50, 43)
    tt.treewalk = {}
    tt.treewalk.min_distance = b.distance_to_treewalk
    tt.treewalk.extra_speed = b.treewalk_speed
    tt.treewalk.animations = {"treewalk", "treewalk_end"}
    tt.treewalk.trail = "hero_muyrn_treewalk_trail"
    tt.treewalk.sound = "HeroNyruTreewalk"
    tt.render.sprites[1].prefix = "hero_nyru_muyrn"
    tt.render.sprites[1].angles.ranged = {"shoot", "shootUp", "shoot"}
    tt.render.sprites[1].angles_custom = {
        ranged = {45, 135, 210, 315}
    }
    tt.render.sprites[1].angles_flip_vertical = {
        ranged = true
    }
    tt.render.sprites[1].scale = vec_2(1.15, 1.15)
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].hit_time = fts(9)
    tt.melee.attacks[1].hit_fx = "hero_muyrn_melee_attack_hit_fx"
    tt.melee.attacks[1].hit_offset = vec_2(24, 0)
    tt.melee.attacks[1].sound = "HeroNyruBasicAttackMelee"
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.melee.attacks[1].animation = "melee_attack"
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].max_range = b.basic_ranged.max_range
    tt.ranged.attacks[1].min_range = b.basic_ranged.min_range
    tt.ranged.attacks[1].cooldown = b.basic_ranged.cooldown
    tt.ranged.attacks[1].bullet = "hero_muyrn_bullet"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(12, 32)}
    tt.ranged.attacks[1].shoot_time = fts(7)
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].animation = "ranged_attack"
    tt.ranged.attacks[1].sound = "HeroNyruBasicAttackRanged"
    tt.ranged.attacks[1].basic_attack = true
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "sentinel_wisps"
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].max_summons = nil
    tt.timed_attacks.list[1].max_range_trigger = b.sentinel_wisps.max_range_trigger
    tt.timed_attacks.list[1].min_targets = b.sentinel_wisps.min_targets
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].cast_time = fts(6)
    tt.timed_attacks.list[1].xp_from_skill = "sentinel_wisps"
    tt.timed_attacks.list[1].sound = "HeroNyruSentinelWispsCast"
    tt.timed_attacks.list[1].entity = "hero_muyrn_sentinel_wisps_entity"
    tt.timed_attacks.list[2] = E:clone_c("custom_attack")
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].max_range_trigger = b.leaf_whirlwind.max_range_trigger
    tt.timed_attacks.list[2].min_targets = b.leaf_whirlwind.min_targets
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].cast_time = fts(5)
    tt.timed_attacks.list[2].xp_from_skill = "leaf_whirlwind"
    tt.timed_attacks.list[2].sound = "HeroNyruLeafWhirlwindCast"
    tt.timed_attacks.list[2].aura = "hero_muyrn_leaf_whirlwind_aura"
    tt.timed_attacks.list[2].aura_decal = "hero_muyrn_leaf_whirlwind_decal"
    tt.timed_attacks.list[2].mod = "hero_muyrn_leaf_whirlwind_heal_mod"
    tt.timed_attacks.list[2].vis_flags = F_RANGED
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[3] = E:clone_c("aura_attack")
    tt.timed_attacks.list[3].animation = "fairy_dust"
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].max_range_trigger = b.faery_dust.max_range_trigger
    tt.timed_attacks.list[3].max_range_effect = b.faery_dust.max_range_effect
    tt.timed_attacks.list[3].min_targets = b.faery_dust.min_targets
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].cast_time = fts(10)
    tt.timed_attacks.list[3].xp_from_skill = "faery_dust"
    tt.timed_attacks.list[3].sound = "HeroNyruFairyDustCast"
    tt.timed_attacks.list[3].aura = "aura_hero_muyrn_faery_dust"
    tt.timed_attacks.list[3].vis_flags = F_RANGED
    tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[3].node_prediction = fts(10)
    tt.timed_attacks.list[4] = E:clone_c("bullet_attack")
    tt.timed_attacks.list[4].disabled = true
    tt.timed_attacks.list[4].max_range = b.verdant_blast.max_range
    tt.timed_attacks.list[4].min_range = b.verdant_blast.min_range
    tt.timed_attacks.list[4].cooldown = nil
    tt.timed_attacks.list[4].bullet = "bullet_hero_muyrn_verdant_blast"
    tt.timed_attacks.list[4].bullet_start_offset = vec_2(-7, 50)
    tt.timed_attacks.list[4].vis_bans = bor(F_NIGHTMARE)
    tt.timed_attacks.list[4].vis_flags = F_RANGED
    tt.timed_attacks.list[4].animation = "verdant_blast"
    tt.timed_attacks.list[4].shoot_time = fts(43)
    tt.timed_attacks.list[4].node_prediction = fts(43)
    tt.timed_attacks.list[4].reset_to_target_pos = true
    tt.timed_attacks.list[4].sound = "HeroNyruVerdantBlastCast"
    tt = E:register_t("hero_muyrn_bullet", "bullet")

    E:add_comps(tt, "force_motion")

    tt.render.sprites[1].name = "hero_nyru_ranged_attack_projectile"
    tt.render.sprites[1].animated = false
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_fx = "hero_muyrn_bolt_hit_fx"
    tt.bullet.particles_name = "hero_muyrn_bullet_trail"
    tt.bullet.miss_decal = nil
    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.bullet.xp_gain_factor = b.basic_ranged.xp_gain_factor
    tt.bullet.damage_type = b.basic_ranged.damage_type
    tt.bullet.max_speed = 300
    tt.bullet.min_speed = 30
    tt.bullet.use_unit_damage_factor = true
    tt.initial_impulse = 15000
    tt.initial_impulse_duration = 0.15
    tt.initial_impulse_angle_abs = math.pi * 0.5
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 3000
    tt.force_motion.max_v = 300
    tt.main_script.update = scripts.hero_muyrn_ranged_attack_bullet.update
    tt = E:register_t("hero_muyrn_melee_attack_hit_fx", "fx")
    tt.render.sprites[1].name = "hero_nyru_ranged_attack_hit"
    tt = E:register_t("hero_muyrn_bolt_hit_fx", "fx")
    tt.render.sprites[1].name = "hero_nyru_ranged_attack_hit"
    tt = E:register_t("hero_muyrn_bullet_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "hero_nyru_ranged_attack_particle"
    tt.particle_system.animated = true
    tt.particle_system.alphas = {255, 0}
    tt.particle_system.particle_lifetime = {fts(16), fts(16)}
    tt.particle_system.scales_y = {0.8, 0.8}
    tt.particle_system.scales_x = {0.8, 0.8}
    tt.particle_system.emission_rate = 70
    tt = E:register_t("hero_muyrn_sentinel_wisps_entity")

    E:add_comps(tt, "main_script", "pos", "render", "force_motion", "ranged", "tween")

    tt.duration = nil
    tt.hero_max_distance = b.sentinel_wisps.wisp.hero_max_distance
    tt.flight_height = 40
    tt.force_motion.max_a = 135000
    tt.force_motion.max_v = 300
    tt.force_motion.ramp_radius = 10
    tt.main_script.insert = scripts.hero_muyrn_sentinel_wisps_entity.insert
    tt.main_script.update = scripts.hero_muyrn_sentinel_wisps_entity.update
    tt.ranged.attacks[1].bullet = "hero_muyrn_sentinel_wisps_entity_bullet"
    tt.ranged.attacks[1].shoot_time = fts(6)
    tt.ranged.attacks[1].cooldown = b.sentinel_wisps.wisp.cooldown
    tt.ranged.attacks[1].max_range = b.sentinel_wisps.wisp.shoot_range
    tt.ranged.attacks[1].min_range = 0
    tt.ranged.attacks[1].animation = "shoot"
    tt.ranged.attacks[1].vis_flags = F_RANGED
    tt.ranged.attacks[1].vis_bans = 0
    tt.render.sprites[1].prefix = "hero_nyru_sentinel_wisps_wisp"
    tt.render.sprites[1].name = "spawn"
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].hidden = false
    tt.render.sprites[2].scale = vec_1(0.5)
    tt.flight_offset = 5
    tt.attack_fx = "fx_hero_muyrn_sentinel_wisps_attack"
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].sprite_id = 2
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.tween.disabled = true
    tt.hp = 40
    tt.sound = "HeroNyruSentinelWispsSpawn"
    tt = E:register_t("hero_muyrn_sentinel_wisps_entity_bullet", "bullet")
    tt.image_width = 75
    tt.main_script.update = scripts.ray_simple.update
    tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_ray"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].anchor = vec_2(0.05, 0.5)
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.damage_type = b.sentinel_wisps.wisp.damage_type
    tt.bullet.hit_time = fts(4)
    tt.bullet.hit_fx = "hero_muyrn_sentinel_wisps_hit_fx"
    tt.sound_events.insert = "HeroNyruSentinelWispsShoot"
    tt = E:register_t("hero_muyrn_sentinel_wisps_entity_bullet_fx_mod", "mod_track_target_fx")
    tt.render.sprites[1].name = "hero_nyru_sentinel_wisps_hit"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt.modifier.duration = fts(11)
    tt = E:register_t("hero_muyrn_verdant_blast_bolt_hit_fx", "fx")
    tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion"
    tt = E:register_t("hero_muyrn_verdant_blast_bolt_flying_hit_fx", "fx")
    tt.render.sprites[1].name = "hero_nyru_verdant_blast_explosion_air"
    tt = E:register_t("hero_muyrn_leaf_whirlwind_aura", "aura")
    tt.aura.duration = nil
    tt.aura.damage_min = nil
    tt.aura.damage_max = nil
    tt.aura.damage_type = b.leaf_whirlwind.damage_type
    tt.aura.track_source = true
    tt.aura.cycle_time = b.leaf_whirlwind.damage_every
    tt.aura.radius = b.leaf_whirlwind.radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.main_script.update = scripts.aura_apply_damage.update
    tt.aura.mods = {"hero_muyrn_leaf_whirlwind_enemy_hit_fx_mod"}
    tt = E:register_t("hero_muyrn_leaf_whirlwind_enemy_hit_fx_mod", "modifier")

    E:add_comps(tt, "render")

    tt.render.sprites[1].name = "hero_nyru_leaf_whirlwind_hit"
    tt.render.sprites[1].sort_y_offset = -1
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.remove = scripts.mod_track_target.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.duration = fts(20)
    tt = E:register_t("hero_muyrn_leaf_whirlwind_heal_mod", "modifier")

    E:add_comps(tt, "hps")

    tt.modifier.duration = nil
    tt.hps.heal_min = nil
    tt.hps.heal_max = nil
    tt.hps.heal_every = b.leaf_whirlwind.heal_every
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.update = scripts.mod_hps.update
    tt = E:register_t("hero_muyrn_leaf_whirlwind_decal", "decal_scripted")

    E:add_comps(tt, "render", "sound_events")

    tt.main_script.update = scripts.hero_muyrn_leaf_whirlwind_decal.update
    tt.render.sprites[1].prefix = "hero_nyru_leaf_whirlwind"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.duration = nil
    tt = E:register_t("hero_muyrn_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_muyrn_ultimate.can_fire_fn
    tt.main_script.update = scripts.hero_muyrn_ultimate.update
    tt.cooldown = nil
    tt.aura = "aura_hero_muyrn_ultimate"
    tt.aura_sides = "aura_hero_muyrn_ultimate_sides"
    tt.sound_events.insert = nil
    tt.sounds = {"HeroNyruRootDefenderStartLvl1", "HeroNyruRootDefenderStartLvl2", "HeroNyruRootDefenderStartLvl3"}
    tt = E:register_t("hero_lumenir", "hero5")

    E:add_comps(tt, "ranged", "timed_attacks", "tween")

    b = balance.heroes.hero_lumenir
    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.level_stats.ranged_damage_min = b.basic_ranged_shot.damage_min
    tt.hero.level_stats.ranged_damage_max = b.basic_ranged_shot.damage_max
    tt.hero.level_stats.mini_dragon_death_ranged_damage_min = b.mini_dragon_death.damage_min
    tt.hero.level_stats.mini_dragon_death_ranged_damage_max = b.mini_dragon_death.damage_max
    tt.hero.skills.shield = E:clone_c("hero_skill")
    tt.hero.skills.shield.hr_cost = {1, 1, 1}
    tt.hero.skills.shield.hr_icon = "0041"
    tt.hero.skills.shield.hr_order = 3
    tt.hero.skills.shield.hr_available = true
    tt.hero.skills.shield.spiked_armor = b.shield.spiked_armor
    tt.hero.skills.shield.armor = b.shield.armor
    tt.hero.skills.shield.duration = b.shield.duration
    tt.hero.skills.shield.cooldown = b.shield.cooldown
    tt.hero.skills.shield.xp_gain = b.shield.xp_gain
    tt.hero.skills.shield.key = "SHIELD"
    tt.hero.skills.celestial_judgement = E:clone_c("hero_skill")
    tt.hero.skills.celestial_judgement.cooldown = b.celestial_judgement.cooldown
    tt.hero.skills.celestial_judgement.hr_cost = {3, 3, 3}
    tt.hero.skills.celestial_judgement.hr_icon = "0042"
    tt.hero.skills.celestial_judgement.hr_order = 4
    tt.hero.skills.celestial_judgement.hr_available = true
    tt.hero.skills.celestial_judgement.xp_gain = b.celestial_judgement.xp_gain
    tt.hero.skills.celestial_judgement.key = "CELESTIAL_JUDGEMENT"
    tt.hero.skills.mini_dragon = E:clone_c("hero_skill")
    tt.hero.skills.mini_dragon.cooldown = b.mini_dragon.cooldown
    tt.hero.skills.mini_dragon.duration = b.mini_dragon.dragon.duration
    tt.hero.skills.mini_dragon.hr_cost = {2, 2, 2}
    tt.hero.skills.mini_dragon.hr_icon = "0043"
    tt.hero.skills.mini_dragon.hr_order = 2
    tt.hero.skills.mini_dragon.hr_available = true
    tt.hero.skills.mini_dragon.xp_gain = b.mini_dragon.xp_gain
    tt.hero.skills.mini_dragon.damage_min = b.mini_dragon.dragon.ranged_attack.damage_min
    tt.hero.skills.mini_dragon.damage_max = b.mini_dragon.dragon.ranged_attack.damage_max
    tt.hero.skills.mini_dragon.key = "MINI_DRAGON"
    tt.hero.skills.fire_balls = E:clone_c("hero_skill")
    tt.hero.skills.fire_balls.cooldown = b.fire_balls.cooldown
    tt.hero.skills.fire_balls.hr_cost = {2, 2, 2}
    tt.hero.skills.fire_balls.hr_icon = "0044"
    tt.hero.skills.fire_balls.hr_order = 1
    tt.hero.skills.fire_balls.hr_available = true
    tt.hero.skills.fire_balls.flames_count = b.fire_balls.flames_count
    tt.hero.skills.fire_balls.mod_damage = b.fire_balls.flame_damage
    tt.hero.skills.fire_balls.xp_gain = b.fire_balls.xp_gain
    tt.hero.skills.fire_balls.key = "FIRE_BALLS"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_lumenir_ultimate"
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0006"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.hr_available = true
    tt.hero.skills.ultimate.key = "ARROW_STORM"
    tt.hero.skills.ultimate.count = b.ultimate.soldier_count
    tt.hero.skills.ultimate.max_attack_count = b.ultimate.max_attack_count
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.team = TEAM_LINIREA
    tt.health.dead_lifetime = 30
    tt.health_bar.draw_order = -1
    tt.health_bar.offset = vec_2(0, 170)
    tt.health_bar.sort_y_offset = -171
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.health_bar.z = Z_FLYING_HEROES
    tt.hero.fn_level_up = scripts.hero_lumenir.level_up
    tt.hero.tombstone_show_time = nil
    tt.hero.use_custom_spawn_point = true
    tt.idle_flip.cooldown = 10
    tt.info.damage_icon = "magic"
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0007"
    tt.info.i18n_key = "HERO_LUMENIR"
    tt.info.portrait = "portraits_hero" .. "_0007"
    tt.info.ultimate_icon = "0006"
    tt.info.ultimate_pointer_style = "area"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_lumenir.insert
    tt.main_script.update = scripts.hero_lumenir.update
    tt.motion.max_speed = b.speed
    tt.nav_rally.requires_node_nearby = false
    tt.nav_grid.ignore_waypoints = true
    tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK,
        TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
    tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
    tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
    tt.drag_line_origin_offset = vec_2(0, 100)
    tt.regen.cooldown = 1
    tt.render.sprites[1].anchor.y = 0.065
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "hero_lumenir_hero"
    tt.render.sprites[1].name = "respawn"
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "hero_lumenir_hero_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].z = Z_DECALS + 1
    tt.soldier.melee_slot_offset = vec_2(0, 0)
    tt.sound_events.change_rally_point = "HeroLumenirTaunt"
    tt.sound_events.death = "HeroLumenirDeath"
    tt.sound_events.respawn = "HeroLumenirTauntIntro"
    tt.sound_events.hero_room_select = "HeroLumenirTauntSelect"
    tt.ui.click_rect = r(-37, 68, 75, 75)
    tt.unit.hit_offset = vec_2(0, 110)
    tt.unit.hide_after_death = true
    tt.unit.mod_offset = vec_2(0, 134)
    tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
    tt.vis.flags = bor(tt.vis.flags, F_FLYING)
    tt.mini_dragon = "mini_dragon_death_hero_lumenir"
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].bullet = "bolt_lumenir"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(44, 80)}
    tt.ranged.attacks[1].cooldown = 1
    tt.ranged.attacks[1].bullet_count = 3
    tt.ranged.attacks[1].min_range = b.basic_ranged_shot.min_range
    tt.ranged.attacks[1].max_range = b.basic_ranged_shot.max_range
    tt.ranged.attacks[1].shoot_time = fts(14)
    tt.ranged.attacks[1].sync_animation = true
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].start_fx = "fx_lumenir_start_attack"
    tt.ranged.attacks[1].sound = "HeroLumenirBasicAttack"
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].ignore_offset = vec_2(0, 110)
    tt.ranged.attacks[1].radius = 100
    tt.ranged.attacks[1].basic_attack = true
    tt.ranged.attacks[2] = E:clone_c("aura_attack")
    tt.ranged.attacks[2].disabled = true
    tt.ranged.attacks[2].mod = "mod_hero_dragon_shield"
    tt.ranged.attacks[2].cooldown = 25
    tt.ranged.attacks[2].animation = "hero_lumenir_hero_blessing_of_retribution"
    tt.ranged.attacks[2].shoot_time = fts(12)
    tt.ranged.attacks[2].min_count = b.shield.min_targets
    tt.ranged.attacks[2].sync_animation = true
    tt.ranged.attacks[2].animation = "blessing_of_retribution"
    tt.ranged.attacks[2].start_fx = "fx_lumenir_start_lance"
    tt.ranged.attacks[2].sound = "HeroLumenirBlessingOfRetributionCast"
    tt.ranged.attacks[2].start_sound_args = {
        delay = fts(12)
    }
    tt.ranged.attacks[2].xp_from_skill = "shield"
    tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_ENEMY)
    tt.ranged.attacks[2].vis_bans = F_HERO
    tt.ranged.attacks[2].range = b.shield.range
    tt.ranged.attacks[3] = E:clone_c("aura_attack")
    tt.ranged.attacks[3].disabled = true
    tt.ranged.attacks[3].mod = "mod_hero_lumenir_sword_hit"
    tt.ranged.attacks[3].min_nodes = 20
    tt.ranged.attacks[3].cooldown = nil
    tt.ranged.attacks[3].shoot_time = fts(24)
    tt.ranged.attacks[3].sync_animation = true
    tt.ranged.attacks[3].animation = "celestial_judgement"
    tt.ranged.attacks[3].sound = "HeroLumenirCelestialJudgementCast"
    tt.ranged.attacks[3].start_sound_args = {
        delay = fts(12)
    }
    tt.ranged.attacks[3].estimated_flight_time = 1
    tt.ranged.attacks[3].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[3].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.ranged.attacks[3].range = b.celestial_judgement.range
    tt.ranged.attacks[3].xp_from_skill = "celestial_judgement"
    tt.ranged.attacks[4] = E:clone_c("aura_attack")
    tt.ranged.attacks[4].disabled = true
    tt.ranged.attacks[4].cooldown = nil
    tt.ranged.attacks[4].spawn_pos_offset = vec_2(0, 0)
    tt.ranged.attacks[4].shoot_time = fts(4)
    tt.ranged.attacks[4].sync_animation = true
    tt.ranged.attacks[4].entity = "mini_dragon_hero_lumenir"
    tt.ranged.attacks[4].animation = "blessing_of_retribution"
    tt.ranged.attacks[4].start_fx = "fx_lumenir_start_enervation"
    tt.ranged.attacks[4].sound = "HeroLumenirLightCompanionCast"
    tt.ranged.attacks[4].estimated_flight_time = 0
    tt.ranged.attacks[4].vis_flags = bor(F_RANGED, F_SPELLCASTER)
    tt.ranged.attacks[4].vis_bans = bor(F_BOSS)
    tt.ranged.attacks[4].xp_from_skill = "mini_dragon"
    tt.ranged.attacks[5] = E:clone_c("spawn_attack")
    tt.ranged.attacks[5].animation = "radiant_wave"
    tt.ranged.attacks[5].cooldown = 20
    tt.ranged.attacks[5].disabled = true
    tt.ranged.attacks[5].entity = "aura_fire_balls_hero_lumenir"
    tt.ranged.attacks[5].spawn_offset = vec_2(43, 81)
    tt.ranged.attacks[5].spawn_time = fts(12)
    tt.ranged.attacks[5].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
    tt.ranged.attacks[5].range_nodes_max = 50
    tt.ranged.attacks[5].range_nodes_min = 10
    tt.ranged.attacks[5].sound = "HeroLumenirRadiantWaveCast"
    tt.ranged.attacks[5].count = nil
    tt.ranged.attacks[5].xp_from_skill = "fire_balls"
    tt.ranged.attacks[5].min_targets = b.fire_balls.min_targets
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].sprite_id = 2
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt = E:register_t("mini_dragon_hero_lumenir", "decal_scripted")
    b = balance.heroes.hero_lumenir.mini_dragon.dragon

    E:add_comps(tt, "force_motion", "ranged", "tween", "idle_flip")

    tt.main_script.update = scripts.mini_dragon_hero_lumenir.update
    tt.flight_height = 60
    tt.custom_height = {
        hero_vesper = 60,
        hero_dragon_gem = 40,
        hero_lumenir = 100
    }
    tt.force_motion.max_a = 1200
    tt.force_motion.max_v = 360
    tt.force_motion.ramp_radius = 30
    tt.force_motion.fr = 0.05
    tt.force_motion.a_step = 20
    tt.offset = vec_2(0, 0)
    tt.start_ts = nil
    tt.render.sprites[1].prefix = "hero_lumenir_light_companion"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].scale = vec_2(0.75, 0.75)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].alpha = 100
    tt.render.sprites[2].name = "hero_lumenir_light_companion_shadow"
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].cooldown = b.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].damage_type = b.damage_type
    tt.ranged.attacks[1].hit_time = fts(2)
    tt.ranged.attacks[1].hit_cycles = 3
    tt.ranged.attacks[1].bullet = "bolt_lumenir_mini"
    tt.ranged.attacks[1].hit_delay = fts(2)
    tt.ranged.attacks[1].search_cooldown = 0.1
    tt.ranged.attacks[1].shoot_time = fts(11)
    tt.ranged.attacks[1].shoot_range = 25
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].xp_gain_factor = b.ranged_attack.xp_gain_factor
    tt.ranged.attacks[1].basic_attack = true
    tt.ranged.attacks[1].bullet_start_offset = vec_2(16, -16)
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].loop = true
    tt.tween.props[1].interp = "sine"
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{1, 0}, {1.5, 255}}
    tt = E:register_t("mini_dragon_death_hero_lumenir", "mini_dragon_hero_lumenir")
    b = balance.heroes.hero_lumenir.mini_dragon_death
    tt.ranged.attacks[1].max_range = b.max_range
    tt.ranged.attacks[1].min_range = b.min_range
    tt.ranged.attacks[1].cooldown = b.cooldown
    tt.ranged.attacks[1].bullet = "bolt_lumenir_mini_death"
    tt = E:register_t("hero_lumenir_ultimate")
    b = balance.heroes.hero_lumenir.ultimate

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_lumenir_ultimate.can_fire_fn
    tt.main_script.update = scripts.hero_lumenir_ultimate.update
    tt.cooldown = 30
    tt.range = b.range
    tt.spawn_delay = 0.5
    tt.count = 6
    tt.vis_flags = bor(F_RANGED)
    tt.vis_bans = bor(F_FLYING)
    tt.entity = "soldier_lumenir_ultimate"
    tt = E:register_t("soldier_lumenir_ultimate", "soldier")

    E:add_comps(tt, "melee")

    b = balance.heroes.hero_lumenir.ultimate
    tt.health.armor = 0
    tt.health.hp_max = 50
    tt.health.ignore_damage = true
    tt.health_bar.hidden = true
    tt.info.random_name_format = nil
    tt.min_wait = 0.1
    tt.max_wait = 0.4
    tt.main_script.insert = scripts.soldier_lumenir_ultimate.insert
    tt.main_script.update = scripts.soldier_lumenir_ultimate.update
    tt.motion.max_speed = 90
    tt.max_attack_count = 2
    tt.stun_range = b.stun_range
    tt.stun_bans = bor(F_RANGED)
    tt.stun_flags = bor(F_FLYING, F_BOSS)
    tt.stun_duration = b.stun_duration
    tt.sound_events.death = "HeroLumenirCallOfTriumphOut"
    tt.regen.cooldown = 1
    tt.regen.health = 0
    tt.render.sprites[1].prefix = "hero_lumenir_call_of_triumph"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].sort_y_offset = -2
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].loop = false
    tt.render.sprites[2].prefix = "hero_lumenir_call_of_triumph_spawn_fx"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].sort_y_offset = -3
    tt.soldier.melee_slot_offset = vec_2(5, 0)
    tt.sound_events.insert = "HeroLumenirCallOfTriumphCast"
    tt.ui.can_click = false
    tt.ui.can_select = false
    tt.unit.level = 0
    tt.unit.mod_offset = vec_2(0, 15)
    tt.vis.flags = bor(F_FRIEND)
    tt.vis.bans = bor(F_ALL)
    tt.melee.attacks[1].damage_max = nil
    tt.melee.attacks[1].damage_min = nil
    tt.melee.attacks[1].hit_times = {fts(7), fts(15), fts(24)}
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[1].xp_gain_factor = 0
    tt.melee.attacks[1].chance = 1
    tt.melee.attacks[1].damage_type = b.damage_type
    tt.melee.attacks[1].sound_hit = "MeleeSword"
    tt.melee.cooldown = fts(15)
    tt.melee.range = 60
    tt = E:register_t("hero_vesper", "hero5")
    b = balance.heroes.hero_vesper

    E:add_comps(tt, "melee", "ranged", "dodge", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = b.basic_melee.damage_max
    tt.hero.level_stats.melee_damage_min = b.basic_melee.damage_min
    tt.hero.level_stats.ranged_short_damage_max = b.basic_ranged_short.damage_max
    tt.hero.level_stats.ranged_short_damage_min = b.basic_ranged_short.damage_min
    tt.hero.level_stats.ranged_long_damage_max = b.basic_ranged_long.damage_max
    tt.hero.level_stats.ranged_long_damage_min = b.basic_ranged_long.damage_min
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.arrow_to_the_knee = E:clone_c("hero_skill")
    tt.hero.skills.arrow_to_the_knee.cooldown = b.arrow_to_the_knee.cooldown
    tt.hero.skills.arrow_to_the_knee.damage_min = b.arrow_to_the_knee.damage_min
    tt.hero.skills.arrow_to_the_knee.damage_max = b.arrow_to_the_knee.damage_max
    tt.hero.skills.arrow_to_the_knee.stun_duration = b.arrow_to_the_knee.stun_duration
    tt.hero.skills.arrow_to_the_knee.hr_available = b.arrow_to_the_knee.available
    tt.hero.skills.arrow_to_the_knee.hr_icon = "0001"
    tt.hero.skills.arrow_to_the_knee.hr_order = 1
    tt.hero.skills.arrow_to_the_knee.hr_cost = {2, 2, 2}
    tt.hero.skills.arrow_to_the_knee.xp_gain = b.arrow_to_the_knee.xp_gain
    tt.hero.skills.arrow_to_the_knee.key = "ARROW_TO_THE_KNEE"
    tt.hero.skills.ricochet = E:clone_c("hero_skill")
    tt.hero.skills.ricochet.cooldown = b.ricochet.cooldown
    tt.hero.skills.ricochet.damage_min = b.ricochet.damage_min
    tt.hero.skills.ricochet.damage_max = b.ricochet.damage_max
    tt.hero.skills.ricochet.bounces = b.ricochet.bounces
    tt.hero.skills.ricochet.hr_available = b.ricochet.available
    tt.hero.skills.ricochet.hr_icon = "0004"
    tt.hero.skills.ricochet.hr_order = 2
    tt.hero.skills.ricochet.hr_cost = {3, 3, 3}
    tt.hero.skills.ricochet.xp_gain = b.ricochet.xp_gain
    tt.hero.skills.ricochet.key = "RICOCHET"
    tt.hero.skills.martial_flourish = E:clone_c("hero_skill")
    tt.hero.skills.martial_flourish.cooldown = b.martial_flourish.cooldown
    tt.hero.skills.martial_flourish.damage_min = b.martial_flourish.damage_min
    tt.hero.skills.martial_flourish.damage_max = b.martial_flourish.damage_max
    tt.hero.skills.martial_flourish.hr_available = b.martial_flourish.available
    tt.hero.skills.martial_flourish.hr_icon = "0002"
    tt.hero.skills.martial_flourish.hr_order = 3
    tt.hero.skills.martial_flourish.hr_cost = {2, 2, 2}
    tt.hero.skills.martial_flourish.xp_gain = b.martial_flourish.xp_gain
    tt.hero.skills.martial_flourish.key = "MARTIAL_FLOURISH"
    tt.hero.skills.disengage = E:clone_c("hero_skill")
    tt.hero.skills.disengage.cooldown = b.disengage.cooldown
    tt.hero.skills.disengage.damage_min = b.disengage.damage_min
    tt.hero.skills.disengage.damage_max = b.disengage.damage_max
    tt.hero.skills.disengage.min_distance_from_end = b.disengage.min_distance_from_end
    tt.hero.skills.disengage.distance = b.disengage.distance
    tt.hero.skills.disengage.hr_available = b.disengage.available
    tt.hero.skills.disengage.hr_icon = "0003"
    tt.hero.skills.disengage.hr_order = 4
    tt.hero.skills.disengage.hr_cost = {1, 1, 1}
    tt.hero.skills.disengage.xp_gain = b.disengage.xp_gain
    tt.hero.skills.disengage.key = "DISENGAGE"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_vesper_ultimate"
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0005"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "ARROW_STORM"
    tt.hero.skills.ultimate.duration = b.ultimate.duration
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.entity = b.ultimate.entity
    tt.hero.team = TEAM_LINIREA
    tt.health.armor = nil
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health.hp_max = nil
    tt.health_bar.offset = vec_2(0, 39)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.hero.fn_level_up = scripts.hero_vesper.level_up
    tt.idle_flip.chance = 0.4
    tt.idle_flip.cooldown = 4
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0001"
    tt.info.portrait = "portraits_hero" .. "_0001"
    tt.info.ultimate_icon = "0001"
    tt.info.ultimate_pointer_style = "area"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_vesper.insert
    tt.main_script.update = scripts.hero_vesper.update
    tt.motion.max_speed = 75
    tt.regen.cooldown = 1
    tt.regen.health = tt.hero.level_stats.regen_health[1]
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].angles.ranged = {"shoot"}
    tt.render.sprites[1].name = "idle_1"
    tt.render.sprites[1].prefix = "hero_vesper_vesper"
    tt.render.sprites[1].scale = vec_2(1.05, 1.05)
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.sound_events.change_rally_point = "HeroVesperTaunt"
    tt.sound_events.death = "HeroVesperDeath"
    tt.sound_events.respawn = "HeroVesperTauntIntro"
    tt.sound_events.hero_room_select = "HeroVesperTauntSelect"
    tt.soldier.melee_slot_offset.x = 5
    tt.unit.hit_offset = vec_2(0, 12)
    tt.unit.marker_offset = vec_2(0, -1)
    tt.unit.mod_offset = vec_2(0, 19.9)
    tt.dodge.disabled = true
    tt.dodge.ranged = false
    tt.dodge.cooldown = nil
    tt.dodge.chance = 1
    tt.dodge.bullet = "arrow_hero_vesper_disengage"
    tt.dodge.animation_dissapear = "disengage_disappear"
    tt.dodge.animation_appear = "disengage_appear"
    tt.dodge.animation_attack_start = "disengage_attack_start"
    tt.dodge.animation_attack_end = "disengage_attack_end"
    tt.dodge.animation_end = "disengage_end"
    tt.dodge.total_shoots = b.disengage.total_shoots
    tt.dodge.can_dodge = scripts.hero_vesper.can_dodge
    tt.dodge.bullet_start_offset = {vec_2(9, 28)}
    tt.dodge.shoot_time = fts(2)
    tt.dodge.sound = "HeroVesperDisengageCast"
    tt.dodge.hp_to_trigger = b.disengage.hp_to_trigger
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].animation = "melee_attack_2"
    tt.melee.attacks[1].damage_max = nil
    tt.melee.attacks[1].damage_min = nil
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[1].sound = "MeleeSword"
    tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
    tt.melee.attacks[1].vis_flags = F_BLOCK
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].hit_fx = "fx_hero_vesper_attack_hit"
    tt.melee.attacks[1].hit_offset = vec_2(30, 20)
    tt.melee.attacks[1].basic_attack = true
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "melee_attack_1"
    tt.melee.attacks[2].chance = 0.2
    tt.melee.attacks[2].hit_time = fts(16)
    tt.melee.attacks[2].hit_offset = vec_2(30, 15)
    tt.melee.attacks[2].basic_attack = true
    tt.melee.attacks[3] = E:clone_c("melee_attack")
    tt.melee.attacks[3].animations = {nil, "martial_flourish"}
    tt.melee.attacks[3].cooldown = nil
    tt.melee.attacks[3].damage_max = nil
    tt.melee.attacks[3].damage_min = nil
    tt.melee.attacks[3].damage_type = b.martial_flourish.damage_type
    tt.melee.attacks[3].disabled = true
    tt.melee.attacks[3].xp_from_skill = "martial_flourish"
    tt.melee.attacks[3].sound = "HeroVesperMartialFlourishCast"
    tt.melee.attacks[3].hit_times = {fts(8), fts(15), fts(23)}
    tt.melee.attacks[3].loops = 1
    tt.melee.attacks[3].mod = "mod_hero_vesper_martial_flourish_fx"
    tt.melee.cooldown = 1
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].animation = "ranged_attack"
    tt.ranged.attacks[1].bullet = "arrow_hero_vesper_short_arrow"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(7, 26)}
    tt.ranged.attacks[1].cooldown = b.basic_ranged_short.cooldown
    tt.ranged.attacks[1].max_range = b.basic_ranged_short.max_range
    tt.ranged.attacks[1].min_range = b.basic_ranged_short.min_range
    tt.ranged.attacks[1].shoot_time = fts(8)
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].shared_cooldown = true
    tt.ranged.attacks[1].chance = 1
    tt.ranged.attacks[1].node_prediction = fts(8) + fts(15)
    tt.ranged.attacks[1].basic_attack = true
    tt.ranged.attacks[2] = E:clone_c("bullet_attack")
    tt.ranged.attacks[2].animation = "ranged_attack"
    tt.ranged.attacks[2].bullet = "arrow_hero_vesper_long_arrow"
    tt.ranged.attacks[2].bullet_start_offset = {vec_2(7, 26)}
    tt.ranged.attacks[2].cooldown = b.basic_ranged_long.cooldown
    tt.ranged.attacks[2].max_range = b.basic_ranged_long.max_range
    tt.ranged.attacks[2].min_range = b.basic_ranged_long.min_range
    tt.ranged.attacks[2].shoot_time = fts(8)
    tt.ranged.attacks[2].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[2].shared_cooldown = true
    tt.ranged.attacks[2].chance = 1
    tt.ranged.attacks[2].node_prediction = fts(8) + fts(15)
    tt.ranged.attacks[2].basic_attack = true
    tt.ranged.attacks[3] = E:clone_c("bullet_attack")
    tt.ranged.attacks[3].animation = "arrow_to_the_knee"
    tt.ranged.attacks[3].bullet = "hero_vesper_arrow_to_the_knee_arrow"
    tt.ranged.attacks[3].bullet_start_offset = {vec_2(0, 20), vec_2(0, 20)}
    tt.ranged.attacks[3].cooldown = nil
    tt.ranged.attacks[3].disabled = true
    tt.ranged.attacks[3].max_range = b.arrow_to_the_knee.max_range
    tt.ranged.attacks[3].min_range = b.arrow_to_the_knee.min_range
    tt.ranged.attacks[3].xp_from_skill = "arrow_to_the_knee"
    tt.ranged.attacks[3].vis_bans = bor(F_BOSS, F_NIGHTMARE)
    tt.ranged.attacks[3].shoot_time = fts(16)
    tt.ranged.attacks[3].node_prediction = fts(10)
    tt.ranged.attacks[3].sound = "HeroVesperArrowToTheKneeCast"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "ricochet"
    tt.timed_attacks.list[1].bullet = "arrow_hero_vesper_ricochet"
    tt.timed_attacks.list[1].bullet_start_offset = {vec_2(0, 20)}
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].max_range = b.ricochet.max_range
    tt.timed_attacks.list[1].min_range = b.ricochet.min_range
    tt.timed_attacks.list[1].xp_from_skill = "ricochet"
    tt.timed_attacks.list[1].vis_bans = 0
    tt.timed_attacks.list[1].shoot_time = fts(19)
    tt.timed_attacks.list[1].min_targets = b.ricochet.min_targets
    tt.timed_attacks.list[1].max_range_trigger = b.ricochet.max_range_trigger
    tt.timed_attacks.list[1].sound = "HeroVesperRicochetCast"
    tt.ui.click_rect = r(-19, -5, 38, 43)
    tt = E:register_t("hero_vesper_arrow_to_the_knee_arrow_mod", "mod_stun")
    tt.modifier.duration = nil
    tt = E:register_t("hero_vesper_arrow_to_the_knee_hit", "fx")
    tt.render.sprites[1].name = "hero_vesper_arrow_to_the_knee_hit"
    tt = E:register_t("hero_vesper_ricochet_bullet_hit_fx", "fx")
    tt.render.sprites[1].name = "hero_vesper_ricochet_hit"
    tt = E:register_t("hero_vesper_ultimate")

    E:add_comps(tt, "pos", "main_script")

    b = balance.heroes.hero_vesper
    tt.can_fire_fn = scripts.hero_vesper_ultimate.can_fire_fn
    tt.main_script.update = scripts.hero_vesper_ultimate.update
    tt.cooldown = nil
    tt.bullet = "hero_vesper_ultimate_arrow"
    tt.spread = b.ultimate.spread
    tt.damage = b.ultimate.damage
    tt.duration = b.ultimate.duration
    tt.enemies_range = b.ultimate.enemies_range
    tt.node_prediction_offset = b.ultimate.node_prediction_offset
    tt.vis_flags = F_RANGED
    tt.vis_bans = 0
    tt.sounds = {"HeroVesperUltimateLvl1", "HeroVesperUltimateLvl2", "HeroVesperUltimateLvl3"}
    tt = E:register_t("hero_vesper_ultimate_arrow", "bullet")
    tt.main_script.update = scripts.hero_vesper_ultimate_arrow.update
    tt.bullet.damage_radius = 35
    tt.bullet.damage_flags = F_AREA
    tt.bullet.damage_bans = F_FRIEND
    tt.bullet.damage_type = DAMAGE_TRUE
    tt.bullet.arrive_decal = "hero_vesper_ultimate_decal"
    tt.bullet.max_speed = 1500
    tt.bullet.mod = "hero_vesper_ultimate_mod"
    tt.render.sprites[1].name = "hero_vesper_ultimate_arrow"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.sound_events.insert = "ArrowSound"
    tt = E:register_t("hero_vesper_ultimate_mod", "mod_slow")
    tt.modifier.duration = 0.1
    tt.slow.factor = 0.5
    tt = E:register_t("hero_vesper_ultimate_decal", "decal_tween")

    AC(tt, "main_script")

    tt.main_script.insert = scripts.hero_vesper_ultimate_decal.insert
    tt.tween.props[1].keys = {{0, 255}, {2, 255}, {3, 0}}
    tt.tween.props[2] = table.deepclone(tt.tween.props[1])
    tt.tween.props[2].sprite_id = 1
    tt.render.sprites[1].name = "hero_vesper_ultimate_arrow_decal"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_DECALS
    tt = E:register_t("hero_raelyn", "hero5")
    b = balance.heroes.hero_raelyn

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = b.melee_damage_max
    tt.hero.level_stats.melee_damage_min = b.melee_damage_min
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.unbreakable = E:clone_c("hero_skill")
    tt.hero.skills.unbreakable.cooldown = b.unbreakable.cooldown
    tt.hero.skills.unbreakable.duration = b.unbreakable.duration
    tt.hero.skills.unbreakable.shield_base = b.unbreakable.shield_base
    tt.hero.skills.unbreakable.shield_per_enemy = b.unbreakable.shield_per_enemy
    tt.hero.skills.unbreakable.hr_available = true
    tt.hero.skills.unbreakable.hr_icon = "0024"
    tt.hero.skills.unbreakable.hr_order = 1
    tt.hero.skills.unbreakable.hr_cost = {3, 3, 3}
    tt.hero.skills.unbreakable.xp_gain = b.unbreakable.xp_gain
    tt.hero.skills.unbreakable.key = "UNBREAKABLE"
    tt.hero.skills.inspire_fear = E:clone_c("hero_skill")
    tt.hero.skills.inspire_fear.cooldown = b.inspire_fear.cooldown
    tt.hero.skills.inspire_fear.damage_duration = b.inspire_fear.damage_duration
    tt.hero.skills.inspire_fear.stun_duration = b.inspire_fear.stun_duration
    tt.hero.skills.inspire_fear.slow_factor = b.inspire_fear.slow_factor
    tt.hero.skills.inspire_fear.inflicted_damage_factor = b.inspire_fear.inflicted_damage_factor
    tt.hero.skills.inspire_fear.hr_available = true
    tt.hero.skills.inspire_fear.hr_icon = "0022"
    tt.hero.skills.inspire_fear.hr_order = 2
    tt.hero.skills.inspire_fear.hr_cost = {3, 2, 1}
    tt.hero.skills.inspire_fear.xp_gain = b.inspire_fear.xp_gain
    tt.hero.skills.inspire_fear.key = "INSPIRE_FEAR"
    tt.hero.skills.brutal_slash = E:clone_c("hero_skill")
    tt.hero.skills.brutal_slash.cooldown = b.brutal_slash.cooldown
    tt.hero.skills.brutal_slash.damage_max = b.brutal_slash.damage_max
    tt.hero.skills.brutal_slash.damage_min = b.brutal_slash.damage_min
    tt.hero.skills.brutal_slash.hr_available = true
    tt.hero.skills.brutal_slash.hr_icon = "0023"
    tt.hero.skills.brutal_slash.hr_order = 3
    tt.hero.skills.brutal_slash.hr_cost = {2, 2, 2}
    tt.hero.skills.brutal_slash.xp_gain = b.brutal_slash.xp_gain
    tt.hero.skills.brutal_slash.key = "BRUTAL_SLASH"
    tt.hero.skills.onslaught = E:clone_c("hero_skill")
    tt.hero.skills.onslaught.hr_available = b.onslaught.available
    tt.hero.skills.onslaught.damage_factor = b.onslaught.damage_factor
    tt.hero.skills.onslaught.melee_cooldown = b.onslaught.melee_cooldown
    tt.hero.skills.onslaught.duration = b.onslaught.duration
    tt.hero.skills.onslaught.cooldown = b.onslaught.cooldown
    tt.hero.skills.onslaught.hit_aura = "hero_raelyn_onslaught_aura"
    tt.hero.skills.onslaught.hr_icon = "0025"
    tt.hero.skills.onslaught.hr_order = 4
    tt.hero.skills.onslaught.hr_cost = {1, 2, 3}
    tt.hero.skills.onslaught.xp_gain = b.onslaught.xp_gain
    tt.hero.skills.onslaught.key = "ONSLAUGHT"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_raelyn_ultimate"
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0056"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 3, 3, 3}
    tt.hero.skills.ultimate.key = "COMMAND_ORDERS"
    tt.hero.skills.ultimate.duration = b.ultimate.duration
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.team = TEAM_DARK_ARMY
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.offset = vec_2(0, 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.hero.fn_level_up = scripts.hero_raelyn.level_up
    tt.info.fn = scripts.hero_basic.get_info_melee
    tt.info.hero_portrait = "hero_portraits_0002"
    tt.info.i18n_key = "HERO_RAELYN"
    tt.info.portrait = "portraits_hero" .. "_0003"
    tt.info.ultimate_icon = "0005"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_raelyn.insert
    tt.main_script.update = scripts.hero_raelyn.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].prefix = "hero_raelyn_hero"
    tt.render.sprites[1].scale = vec_2(1.05, 1.05)
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.soldier.melee_slot_offset = vec_2(10, 0)
    tt.sound_events.change_rally_point = "HeroRaelynTaunt"
    tt.sound_events.death = "HeroRaelynDeath"
    tt.sound_events.respawn = "HeroRaelynTauntIntro"
    tt.sound_events.hero_room_select = "HeroRaelynTauntSelect"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].animation = "melee_attack"
    tt.melee.attacks[1].cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.attacks[1].hit_fx = "hero_raelyn_melee_attack_hit"
    tt.melee.attacks[1].hit_offset = vec_2(35, 15)
    tt.melee.attacks[1].sound = "HeroRaelynBasicAttack"
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.melee.attacks[2] = E:clone_c("melee_attack")
    tt.melee.attacks[2].disabled = true
    tt.melee.attacks[2].cooldown = nil
    tt.melee.attacks[2].damage_max = nil
    tt.melee.attacks[2].damage_min = nil
    tt.melee.attacks[2].hit_time = fts(18)
    tt.melee.attacks[2].sound = "HeroRaelynBrutalSlashCast"
    tt.melee.attacks[2].animation = "brutal_slash"
    tt.melee.attacks[2].damage_type = bor(b.brutal_slash.damage_type, DAMAGE_FX_EXPLODE)
    tt.melee.attacks[2].xp_gain_factor = b.brutal_slash.xp_gain_factor
    tt.melee.attacks[2].xp_from_skill = "brutal_slash"
    tt.melee.attacks[2].pop = {"pop_whaam", "pop_kapow"}
    tt.melee.attacks[2].pop_chance = 0.3
    tt.melee.attacks[2].hit_decal = "hero_raelyn_brutal_slash_decal"
    tt.melee.attacks[2].hit_offset = vec_2(35, 0)
    tt.timed_attacks.list[1] = E:clone_c("mod_attack")
    tt.timed_attacks.list[1].animation = "unbreakable"
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].max_range_trigger = b.unbreakable.max_range_trigger
    tt.timed_attacks.list[1].max_range_effect = b.unbreakable.max_range_effect
    tt.timed_attacks.list[1].min_targets = b.unbreakable.min_targets
    tt.timed_attacks.list[1].max_targets = b.unbreakable.max_targets
    tt.timed_attacks.list[1].mod = "hero_raelyn_unbreakable_mod"
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].cast_time = fts(8)
    tt.timed_attacks.list[1].xp_from_skill = "unbreakable"
    tt.timed_attacks.list[1].sound = "HeroRaelynUnbreakableCast"
    tt.timed_attacks.list[1].mod_decal = "hero_raelyn_unbreakable_floor_decal_mod"
    tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[2] = E:clone_c("mod_attack")
    tt.timed_attacks.list[2].animation = "inspire_fear"
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].cast_time = fts(13)
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_FRIEND)
    tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
    tt.timed_attacks.list[2].max_range_trigger = b.inspire_fear.max_range_trigger
    tt.timed_attacks.list[2].min_range_trigger = 0
    tt.timed_attacks.list[2].max_range_effect = b.inspire_fear.max_range_effect
    tt.timed_attacks.list[2].min_range_effect = 0
    tt.timed_attacks.list[2].min_targets = b.inspire_fear.min_targets
    tt.timed_attacks.list[2].mods = {"hero_raelyn_inspire_fear_damage_mod", "hero_raelyn_inspire_fear_stun_mod",
                                     "hero_raelyn_inspire_fear_fx_mod"}
    tt.timed_attacks.list[2].sound = "HeroRaelynInspireFearCast"
    tt.timed_attacks.list[2].xp_from_skill = "inspire_fear"
    tt.timed_attacks.list[2].mod_decal = "hero_raelyn_inspire_fear_floor_decal_mod"
    tt.timed_attacks.list[3] = E:clone_c("custom_attack")
    tt.timed_attacks.list[3].animation = nil
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].melee_cooldown = nil
    tt.timed_attacks.list[3].duration = nil
    tt.timed_attacks.list[3].max_range_trigger = b.onslaught.max_range_trigger
    tt.timed_attacks.list[3].min_targets = b.onslaught.min_targets
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[3].hit_decal = "decal_hero_raelyn_onslaught_decal"
    tt.timed_attacks.list[3].hit_offset = vec_2(35, 0)
    tt.timed_attacks.list[3].sound = "HeroRaelynOnslaughtCast"
    tt.ui.click_rect = r(-20, -5, 40, 43)
    tt = E:register_t("hero_raelyn_melee_attack_hit", "fx")
    tt.render.sprites[1].name = "hero_raelyn_melee_attack_hit"
    tt = E:register_t("hero_raelyn_brutal_slash_decal", "decal_tween")
    tt.render.sprites[1].name = "hero_raelyn_brutal_slash_decal"
    tt.render.sprites[1].animated = false
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt = E:register_t("hero_raelyn_unbreakable_floor_decal_mod", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.update = scripts.mod_track_target.update
    tt.render.sprites[1].name = "hero_raelyn_unbreakable_fx_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "hero_raelyn_unbreakable_shield_floor_glow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].hidden = false
    tt.modifier.use_mod_offset = false
    tt.modifier.duration = fts(17)
    tt = E:register_t("hero_raelyn_unbreakable_mod", "modifier")

    E:add_comps(tt, "render", "health_bar", "health")

    tt.modifier.vis_flags = bor(F_MOD)
    tt.modifier.duration = nil
    tt.modifier.use_mod_offset = false
    tt.shield_base = nil
    tt.shield_per_enemy = nil
    tt.shield_max_damage = nil
    tt.damage_taken = 0
    tt.main_script.insert = scripts.hero_raelyn_unbreakable_mod.insert
    tt.main_script.remove = scripts.hero_raelyn_unbreakable_mod.remove
    tt.main_script.update = scripts.hero_raelyn_unbreakable_mod.update
    tt.health_bar.offset = vec_2(0, 42)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health_bar.colors = {}
    tt.health_bar.colors.fg = {255, 255, 0, 255}
    tt.health_bar.colors.bg = {0, 0, 0, 255}
    tt.health_bar.sort_y_offset = -2
    tt.health_bar.disable_fade = true
    tt.sprites_per_enemies = {"hero_raelyn_unbreakable_shield_lvl1", "hero_raelyn_unbreakable_shield_lvl1",
                              "hero_raelyn_unbreakable_shield_lvl1"}
    tt.animation_start = "start"
    tt.animation_loop = "idle"
    tt.animation_end = "end"
    tt.render.sprites[1].prefix = nil
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].scale = vec_1(0.7)
    tt = E:register_t("hero_raelyn_inspire_fear_floor_decal_mod", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.update = scripts.mod_track_target.update
    tt.render.sprites[1].name = "hero_raelyn_inspire_fear_fx_area_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].hide_after_runs = 1
    tt.render.sprites[1].scale = vec_1(0.7)
    tt.modifier.use_mod_offset = false
    tt.modifier.duration = fts(28)
    tt = E:register_t("hero_raelyn_inspire_fear_damage_mod", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = nil
    tt.modifier.duration = nil
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].name = "hero_raelyn_inspire_fear_decal"
    tt.render.sprites[1].draw_order = 20
    tt.modifier.use_mod_offset = false
    tt = E:register_t("hero_raelyn_inspire_fear_stun_mod", "mod_stun")
    tt.modifier.duration = nil
    tt.render.sprites[1].hidden = true
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("hero_raelyn_inspire_fear_fx_mod", "modifier")
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.duration = nil
    tt = E:register_t("hero_raelyn_onslaught_aura", "aura")

    E:add_comps(tt, "render")

    tt.aura.duration = fts(11)
    tt.aura.cycle_time = fts(11)
    tt.aura.damage_min = nil
    tt.aura.damage_max = nil
    tt.aura.damage_type = b.onslaught.damage_type
    tt.aura.radius = b.onslaught.radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = bor(F_RANGED)
    tt.aura.excluded_entities = nil
    tt.main_script.update = scripts.aura_apply_damage.update

    function tt.main_script.insert(this, store, script)
        if this.render then
            for _, s in pairs(this.render.sprites) do
                s.ts = store.tick_ts
            end
        end

        this.aura.excluded_entities = {this.aura.target_id}

        return true
    end

    tt = E:register_t("hero_raelyn_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_raelyn_ultimate.can_fire_fn
    tt.cooldown = nil
    tt.entity = nil
    tt.entity_prefix = "hero_raelyn_ultimate_entity"
    tt.main_script.update = scripts.hero_raelyn_ultimate.update
    tt.sound_events.insert = "HeroRaelynUltimateCast"
    tt = E:register_t("hero_raelyn_ultimate_entity", "soldier_militia")

    E:add_comps(tt, "melee", "nav_grid", "reinforcement", "tween")

    b = balance.heroes.hero_raelyn
    tt.health_bar.offset = vec_2(0, 50)
    tt.info.i18n_key = "HERO_RAELYN_ULTIMATE_ENTITY"
    tt.info.enc_icon = 12
    tt.info.portrait = "gui_bottom_info_image_soldiers_0009"
    tt.info.fn = scripts.soldier_reinforcement.get_info
    tt.info.random_name_format = nil
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "hero_raelyn_command_orders_dark_knight"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].draw_order = DO_SOLDIER_BIG
    tt.sound_events.insert = "HeroRaelynUltimateTaunt"
    tt.sound_events.death = "HeroRaelynUltimateDeath"
    tt.unit.hit_offset = vec_2(0, 16)
    tt.unit.size = UNIT_SIZE_LARGE
    tt.unit.fade_time_after_death = tt.health.dead_lifetime
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.main_script.insert = scripts.soldier_reinforcement.insert
    tt.main_script.update = scripts.hero_raelyn_command_orders_dark_knight.update
    tt.regen.cooldown = 1
    tt.vis.bans = bor(F_SKELETON, F_CANNIBALIZE)
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.props[1].name = "alpha"
    tt.tween.remove = false
    tt.tween.reverse = false
    tt.tween.disabled = true
    tt.spawn_mod_decal = "hero_raelyn_ultimate_entity_spawn_mod_decal"
    tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF, F_WATER)
    tt.melee.attacks[1].vis_flags = F_BLOCK
    tt.melee.attacks[1].sound = "CommonNoSwordAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(8)
    }
    tt.melee.attacks[1].damage_type = b.ultimate.entity.damage_type
    tt.melee.attacks[1].hit_times = {fts(16), fts(28)}
    tt.melee.attacks[1].loops = 1
    tt.melee.attacks[1].hit_fx = "hero_raelyn_command_orders_hit_fx"
    tt.melee.attacks[1].hit_offset = vec_2(30, 20)
    tt.melee.attacks[1].animations = {nil, "attack_1"}
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.range = b.ultimate.entity.range
    tt.reinforcement.duration = b.ultimate.entity.duration
    tt.reinforcement.fade = nil
    tt.reinforcement.fade_out = nil
    tt.ui.click_rect = r(-20, -5, 40, 50)
    tt = E:register_t("hero_raelyn_ultimate_entity_1", "hero_raelyn_ultimate_entity")
    tt.motion.max_speed = b.ultimate.entity.speed[1]

    for _, attack in ipairs(tt.melee.attacks) do
        attack.cooldown = b.ultimate.entity.cooldown[1]
        attack.damage_max = b.ultimate.entity.damage_max[1]
        attack.damage_min = b.ultimate.entity.damage_min[1]
    end

    tt.health.hp_max = b.ultimate.entity.hp_max[1]
    tt.regen.health = b.ultimate.entity.regen_health[1]
    tt.health.armor = b.ultimate.entity.armor[1]
    tt = E:register_t("hero_raelyn_ultimate_entity_2", "hero_raelyn_ultimate_entity")
    tt.motion.max_speed = b.ultimate.entity.speed[2]

    for _, attack in ipairs(tt.melee.attacks) do
        attack.cooldown = b.ultimate.entity.cooldown[2]
        attack.damage_max = b.ultimate.entity.damage_max[2]
        attack.damage_min = b.ultimate.entity.damage_min[2]
    end

    tt.health.hp_max = b.ultimate.entity.hp_max[2]
    tt.regen.health = b.ultimate.entity.regen_health[2]
    tt.health.armor = b.ultimate.entity.armor[2]
    tt = E:register_t("hero_raelyn_ultimate_entity_3", "hero_raelyn_ultimate_entity")
    tt.motion.max_speed = b.ultimate.entity.speed[3]

    for _, attack in ipairs(tt.melee.attacks) do
        attack.cooldown = b.ultimate.entity.cooldown[3]
        attack.damage_max = b.ultimate.entity.damage_max[3]
        attack.damage_min = b.ultimate.entity.damage_min[3]
    end

    tt.health.hp_max = b.ultimate.entity.hp_max[3]
    tt.regen.health = b.ultimate.entity.regen_health[3]
    tt.health.armor = b.ultimate.entity.armor[3]
    tt = E:register_t("hero_raelyn_ultimate_entity_4", "hero_raelyn_ultimate_entity")
    tt.motion.max_speed = b.ultimate.entity.speed[4]

    for _, attack in ipairs(tt.melee.attacks) do
        attack.cooldown = b.ultimate.entity.cooldown[4]
        attack.damage_max = b.ultimate.entity.damage_max[4]
        attack.damage_min = b.ultimate.entity.damage_min[4]
    end

    tt.health.hp_max = b.ultimate.entity.hp_max[4]
    tt.regen.health = b.ultimate.entity.regen_health[4]
    tt.health.armor = b.ultimate.entity.armor[4]
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
    tt = E:register_t("hero_builder", "hero5")
    b = balance.heroes.hero_builder

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = b.melee_damage_max
    tt.hero.level_stats.melee_damage_min = b.melee_damage_min
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.overtime_work = E:clone_c("hero_skill")
    tt.hero.skills.overtime_work.cooldown = b.overtime_work.cooldown
    tt.hero.skills.overtime_work.damage_min = b.overtime_work.soldier.melee_attack.damage_min
    tt.hero.skills.overtime_work.damage_max = b.overtime_work.soldier.melee_attack.damage_max
    tt.hero.skills.overtime_work.hp_max = b.overtime_work.soldier.hp_max
    tt.hero.skills.overtime_work.hr_available = true
    tt.hero.skills.overtime_work.hr_icon = "0006"
    tt.hero.skills.overtime_work.hr_order = 1
    tt.hero.skills.overtime_work.hr_cost = {3, 3, 3}
    tt.hero.skills.overtime_work.xp_gain = b.overtime_work.xp_gain
    tt.hero.skills.overtime_work.key = "OVERTIME_WORK"
    tt.hero.skills.lunch_break = E:clone_c("hero_skill")
    tt.hero.skills.lunch_break.cooldown = b.lunch_break.cooldown
    tt.hero.skills.lunch_break.heal_hp = b.lunch_break.heal_hp
    tt.hero.skills.lunch_break.hr_available = true
    tt.hero.skills.lunch_break.hr_icon = "0007"
    tt.hero.skills.lunch_break.hr_order = 2
    tt.hero.skills.lunch_break.hr_cost = {1, 1, 1}
    tt.hero.skills.lunch_break.xp_gain = b.lunch_break.xp_gain
    tt.hero.skills.lunch_break.key = "LUNCH_BREAK"
    tt.hero.skills.demolition_man = E:clone_c("hero_skill")
    tt.hero.skills.demolition_man.cooldown = b.demolition_man.cooldown
    tt.hero.skills.demolition_man.duration = b.demolition_man.duration
    tt.hero.skills.demolition_man.damage_min = b.demolition_man.damage_min
    tt.hero.skills.demolition_man.damage_max = b.demolition_man.damage_max
    tt.hero.skills.demolition_man.hr_available = true
    tt.hero.skills.demolition_man.hr_icon = "0008"
    tt.hero.skills.demolition_man.hr_order = 3
    tt.hero.skills.demolition_man.hr_cost = {2, 2, 2}
    tt.hero.skills.demolition_man.xp_gain = b.demolition_man.xp_gain
    tt.hero.skills.demolition_man.key = "DEMOLITION_MAN"
    tt.hero.skills.defensive_turret = E:clone_c("hero_skill")
    tt.hero.skills.defensive_turret.cooldown = b.defensive_turret.cooldown
    tt.hero.skills.defensive_turret.attack_cooldown = b.defensive_turret.attack.cooldown
    tt.hero.skills.defensive_turret.duration = b.defensive_turret.duration
    tt.hero.skills.defensive_turret.damage_min = b.defensive_turret.attack.damage_min
    tt.hero.skills.defensive_turret.damage_max = b.defensive_turret.attack.damage_max
    tt.hero.skills.defensive_turret.hr_available = true
    tt.hero.skills.defensive_turret.hr_icon = "0009"
    tt.hero.skills.defensive_turret.hr_order = 4
    tt.hero.skills.defensive_turret.hr_cost = {2, 2, 2}
    tt.hero.skills.defensive_turret.xp_gain = b.defensive_turret.xp_gain
    tt.hero.skills.defensive_turret.key = "DEFENSIVE_TURRET"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "controller_hero_builder_ultimate"
    tt.hero.skills.ultimate.damage = b.ultimate.damage
    tt.hero.skills.ultimate.stun_duration = b.ultimate.stun_duration
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0010"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "WRECKING_BALL"
    tt.hero.skills.ultimate.duration = b.ultimate.duration
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.team = TEAM_LINIREA
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.offset = vec_2(0, 53)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.hero.fn_level_up = scripts.hero_builder.level_up
    tt.info.fn = scripts.hero_basic.get_info_melee
    tt.info.hero_portrait = "hero_portraits_0004"
    tt.info.ultimate_icon = "0004"
    tt.info.i18n_key = "HERO_BUILDER"
    tt.info.portrait = "portraits_hero" .. "_0004"
    tt.info.ultimate_icon = "0004"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_builder.insert
    tt.main_script.update = scripts.hero_builder.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].prefix = "hero_obdul_hero"
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.render.sprites[1].scale = vec_2(0.9, 0.9)
    tt.ui.click_rect = r(-30, -4, 60, 50)
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.sound_events.change_rally_point = "HeroBuilderTaunt"
    tt.sound_events.death = "HeroBuilderDeath"
    tt.sound_events.respawn = "HeroBuilderTauntIntro"
    tt.sound_events.hero_room_select = "HeroBuilderTauntSelect"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].hit_time = fts(14)
    tt.melee.attacks[1].hit_fx = "fx_hero_builder_melee_attack_hit"
    tt.melee.attacks[1].hit_offset = vec_2(45, 15)
    tt.melee.attacks[1].sound = "HeroBuilderBasicAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(14)
    }
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "skill_5"
    tt.timed_attacks.list[1].cast_time = fts(10)
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].entity = "soldier_hero_builder_worker"
    tt.timed_attacks.list[1].max_range = b.overtime_work.max_range
    tt.timed_attacks.list[1].min_targets = b.overtime_work.min_targets
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[1].sound = "HeroBuilderMenAtWork"
    tt.timed_attacks.list[1].min_cooldown = 5
    tt.timed_attacks.list[1].spawn_fx = "fx_hero_builder_overtime_work_raise"
    tt.timed_attacks.list[2] = E:clone_c("mod_attack")
    tt.timed_attacks.list[2].animation = "skill_2"
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].lost_health = b.lunch_break.lost_health
    tt.timed_attacks.list[2].cast_time = fts(15)
    tt.timed_attacks.list[2].mod = "mod_hero_builder_lunch_break"
    tt.timed_attacks.list[2].sound = "HeroBuilderLunchBreak"
    tt.timed_attacks.list[2].min_cooldown = 5
    tt.timed_attacks.list[3] = E:clone_c("custom_attack")
    tt.timed_attacks.list[3].animation = "skill_3"
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].cast_time = fts(15)
    tt.timed_attacks.list[3].sound = "HeroBuilderDemolitionMan"
    tt.timed_attacks.list[3].max_range = b.demolition_man.max_range
    tt.timed_attacks.list[3].min_targets = b.demolition_man.min_targets
    tt.timed_attacks.list[3].aura = "aura_hero_builder_demolition_man"
    tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[3].fx = "fx_hero_builder_demolition_man"
    tt.timed_attacks.list[3].min_cooldown = 5
    tt.timed_attacks.list[3].min_fight_cooldown = 2
    tt.timed_attacks.list[4] = E:clone_c("custom_attack")
    tt.timed_attacks.list[4].animation = "skill_4"
    tt.timed_attacks.list[4].cooldown = nil
    tt.timed_attacks.list[4].disabled = true
    tt.timed_attacks.list[4].cast_time = fts(14)
    tt.timed_attacks.list[4].sound_cast = "HeroBuilderDefensiveTurretCast"
    tt.timed_attacks.list[4].sound_destroy = "HeroBuilderDefensiveTurretDestroy"
    tt.timed_attacks.list[4].entity = "decal_hero_builder_defensive_turret"
    tt.timed_attacks.list[4].max_range = b.defensive_turret.max_range
    tt.timed_attacks.list[4].build_speed = b.defensive_turret.build_speed
    tt.timed_attacks.list[4].min_targets = b.defensive_turret.min_targets
    tt.timed_attacks.list[4].spawn_offset = vec_2(51, 0)
    tt.timed_attacks.list[4].min_cooldown = 5
    tt.timed_attacks.list[4].min_distance_from_border = 100
    tt = E:register_t("hero_mecha", "hero5")
    b = balance.heroes.hero_mecha

    E:add_comps(tt, "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.ranged_damage_min = b.basic_ranged.damage_min
    tt.hero.level_stats.ranged_damage_max = b.basic_ranged.damage_max
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.goblidrones = E:clone_c("hero_skill")
    tt.hero.skills.goblidrones.cooldown = b.goblidrones.cooldown
    tt.hero.skills.goblidrones.units = b.goblidrones.units
    tt.hero.skills.goblidrones.spawn_range = b.goblidrones.spawn_range
    tt.hero.skills.goblidrones.min_targets = b.goblidrones.min_targets
    tt.hero.skills.goblidrones.attack_cooldown = b.goblidrones.drone.cooldown
    tt.hero.skills.goblidrones.min_range = b.goblidrones.drone.ranged_attack.min_range
    tt.hero.skills.goblidrones.max_range = b.goblidrones.drone.ranged_attack.max_range
    tt.hero.skills.goblidrones.damage_type = b.goblidrones.drone.ranged_attack.damage_type
    tt.hero.skills.goblidrones.damage_min = b.goblidrones.drone.ranged_attack.damage_min
    tt.hero.skills.goblidrones.damage_max = b.goblidrones.drone.ranged_attack.damage_max
    tt.hero.skills.goblidrones.hr_available = true
    tt.hero.skills.goblidrones.hr_icon = "0006"
    tt.hero.skills.goblidrones.hr_order = 1
    tt.hero.skills.goblidrones.hr_cost = {3, 3, 3}
    tt.hero.skills.goblidrones.xp_gain = b.goblidrones.xp_gain
    tt.hero.skills.goblidrones.key = "GOBLIDRONES"
    tt.hero.skills.tar_bomb = E:clone_c("hero_skill")
    tt.hero.skills.tar_bomb.cooldown = b.tar_bomb.cooldown
    tt.hero.skills.tar_bomb.duration = b.tar_bomb.duration
    tt.hero.skills.tar_bomb.min_range = b.tar_bomb.min_range
    tt.hero.skills.tar_bomb.max_range = b.tar_bomb.max_range
    tt.hero.skills.tar_bomb.min_targets = b.tar_bomb.min_targets
    tt.hero.skills.tar_bomb.xp_gain = b.tar_bomb.xp_gain
    tt.hero.skills.tar_bomb.hr_available = true
    tt.hero.skills.tar_bomb.hr_icon = "0007"
    tt.hero.skills.tar_bomb.hr_order = 2
    tt.hero.skills.tar_bomb.hr_cost = {1, 1, 1}
    tt.hero.skills.tar_bomb.key = "TAR_BOMB"
    tt.hero.skills.power_slam = E:clone_c("hero_skill")
    tt.hero.skills.power_slam.cooldown = b.power_slam.cooldown
    tt.hero.skills.power_slam.damage_type = b.power_slam.damage_type
    tt.hero.skills.power_slam.damage_radius = b.power_slam.damage_radius
    tt.hero.skills.power_slam.damage_min = b.power_slam.damage_min
    tt.hero.skills.power_slam.damage_max = b.power_slam.damage_max
    tt.hero.skills.power_slam.stun_time = b.power_slam.stun_time
    tt.hero.skills.power_slam.xp_gain = b.power_slam.xp_gain
    tt.hero.skills.power_slam.hr_available = true
    tt.hero.skills.power_slam.hr_icon = "0008"
    tt.hero.skills.power_slam.hr_order = 3
    tt.hero.skills.power_slam.hr_cost = {2, 2, 2}
    tt.hero.skills.power_slam.key = "POWER_SLAM"
    tt.hero.skills.mine_drop = E:clone_c("hero_skill")
    tt.hero.skills.mine_drop.cooldown = b.mine_drop.cooldown
    tt.hero.skills.mine_drop.max_mines = b.mine_drop.max_mines
    tt.hero.skills.mine_drop.min_range = b.mine_drop.min_range
    tt.hero.skills.mine_drop.max_range = b.mine_drop.max_range
    tt.hero.skills.mine_drop.damage_min = b.mine_drop.damage_min
    tt.hero.skills.mine_drop.damage_max = b.mine_drop.damage_max
    tt.hero.skills.mine_drop.hr_available = true
    tt.hero.skills.mine_drop.hr_icon = "0009"
    tt.hero.skills.mine_drop.hr_order = 4
    tt.hero.skills.mine_drop.hr_cost = {2, 2, 2}
    tt.hero.skills.mine_drop.xp_gain = b.mine_drop.xp_gain
    tt.hero.skills.mine_drop.key = "MINE_DROP"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "controller_hero_mecha_ultimate"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.min_range = b.ultimate.ranged_attack.min_range
    tt.hero.skills.ultimate.max_range = b.ultimate.ranged_attack.max_range
    tt.hero.skills.ultimate.damage_min = b.ultimate.ranged_attack.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.ranged_attack.damage_max
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0010"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "DEATH_FROM_ABOVE"
    tt.hero.team = TEAM_DARK_ARMY
    tt.hero.fn_level_up = scripts.hero_mecha.level_up
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.offset = vec_2(0, 62)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0006"
    tt.info.ultimate_icon = "0007"
    tt.info.i18n_key = "HERO_MECHA"
    tt.info.portrait = "portraits_hero" .. "_0006"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_mecha.insert
    tt.main_script.update = scripts.hero_mecha.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].prefix = "hero_onagro_hero"
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.render.sprites[1].scale = vec_1(1.15)
    tt.ui.click_rect = r(-30, -4, 60, 60)
    tt.particles_name_1 = "ps_hero_mecha_smoke_1"
    tt.particles_name_2 = "ps_hero_mecha_smoke_2"
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.sound_events.change_rally_point = "HeroMechaTaunt"
    tt.sound_events.death = "HeroMechaDeath"
    tt.sound_events.respawn = "HeroMechaTauntIntro"
    tt.sound_events.hero_room_select = "HeroMechaTauntSelect"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.mod_offset = vec_2(0, 13)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].animation = "attack_1"
    tt.ranged.attacks[1].bullet = "bullet_hero_mecha"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(10, 24)}
    tt.ranged.attacks[1].cooldown = b.basic_ranged.cooldown
    tt.ranged.attacks[1].max_range = b.basic_ranged.max_range
    tt.ranged.attacks[1].min_range = b.basic_ranged.min_range
    tt.ranged.attacks[1].shoot_time = fts(8)
    tt.ranged.attacks[1].sound = "HeroMechaBasicAttack"
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].xp_gain_factor = b.basic_ranged.xp_gain_factor
    tt.ranged.attacks[1].basic_attack = true
    tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
    tt.ranged.attacks[2].animation = "attack_2"
    tt.ranged.attacks[2].bullet_start_offset = {vec_2(40, 26)}
    tt.ranged.attacks[2].disabled = true
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "skill_1"
    tt.timed_attacks.list[1].cast_time = fts(32)
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].entity = "drone_hero_mecha"
    tt.timed_attacks.list[1].spawn_pos_offset = vec_2(-10, 0)
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].sound = "HeroMechaGoblidroneCast"
    tt.timed_attacks.list[1].min_cooldown = 5
    tt.timed_attacks.list[1].spawn_range = b.goblidrones.spawn_range
    tt.timed_attacks.list[1].min_targets = b.goblidrones.min_targets
    tt.timed_attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.timed_attacks.list[2] = E:clone_c("custom_attack")
    tt.timed_attacks.list[2].animation = "skill_2"
    tt.timed_attacks.list[2].bullet = "bullet_hero_mecha_tar_bomb"
    tt.timed_attacks.list[2].bullet_start_offset = {vec_2(15, 22)}
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].cast_time = fts(20)
    tt.timed_attacks.list[2].node_prediction = fts(b.tar_bomb.node_prediction)
    tt.timed_attacks.list[2].max_range = b.tar_bomb.max_range
    tt.timed_attacks.list[2].min_targets = b.tar_bomb.min_targets
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[2].sound = "HeroMechaTarBombCast"
    tt.timed_attacks.list[2].min_cooldown = 5
    tt.timed_attacks.list[3] = E:clone_c("custom_attack")
    tt.timed_attacks.list[3].animation = "skill_3"
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].cast_time = fts(25)
    tt.timed_attacks.list[3].damage_type = b.power_slam.damage_type
    tt.timed_attacks.list[3].damage_radius = b.power_slam.damage_radius
    tt.timed_attacks.list[3].damage_max = b.power_slam.damage_max
    tt.timed_attacks.list[3].damage_min = b.power_slam.damage_min
    tt.timed_attacks.list[3].min_targets = b.power_slam.min_targets
    tt.timed_attacks.list[3].mod = "mod_hero_mecha_power_slam_stun"
    tt.timed_attacks.list[3].vis_bans_trigger = bor(F_FLYING, F_NIGHTMARE)
    tt.timed_attacks.list[3].vis_bans_damage = bor(F_FLYING)
    tt.timed_attacks.list[3].sound = "HeroMechaPowerSlamCast"
    tt.timed_attacks.list[3].min_cooldown = 5
    tt.timed_attacks.list[4] = E:clone_c("custom_attack")
    tt.timed_attacks.list[4].animation = "skill_4"
    tt.timed_attacks.list[4].bullet = "bullet_hero_mecha_mine"
    tt.timed_attacks.list[4].bullet_start_offset = {vec_2(0, 60)}
    tt.timed_attacks.list[4].cooldown = nil
    tt.timed_attacks.list[4].disabled = true
    tt.timed_attacks.list[4].cast_time = fts(23.25)
    tt.timed_attacks.list[4].min_range = b.mine_drop.min_range
    tt.timed_attacks.list[4].max_range = b.mine_drop.max_range
    tt.timed_attacks.list[4].min_targets = b.mine_drop.min_targets
    tt.timed_attacks.list[4].min_dist_between_mines = b.mine_drop.min_dist_between_mines
    tt.timed_attacks.list[4].spawn_offset = vec_2(51, 0)
    tt.timed_attacks.list[4].sound_cast = "HeroMechaMineDropCast"
    tt.timed_attacks.list[4].min_cooldown = 5
    tt.timed_attacks.list[4].min_distance_from_border = 100
    tt = E:register_t("drone_hero_mecha", "decal_scripted")
    b = balance.heroes.hero_mecha.goblidrones.drone

    E:add_comps(tt, "force_motion", "ranged", "tween")

    tt.main_script.update = scripts.drone_hero_mecha.update
    tt.flight_height = 60
    tt.force_motion.max_a = 1200
    tt.force_motion.max_v = 360
    tt.force_motion.ramp_radius = 30
    tt.force_motion.fr = 0.05
    tt.force_motion.a_step = 20
    tt.duration = b.duration
    tt.start_ts = nil
    tt.render.sprites[1].prefix = "hero_onagro_skill_1_drone"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].scale = vec_2(0.75, 0.75)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "hero_onagro_ultimate_layer1_idle"
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].scale = vec_1(0.2)
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].damage_type = b.ranged_attack.damage_type
    tt.ranged.attacks[1].damage_min_config = b.ranged_attack.damage_min
    tt.ranged.attacks[1].damage_max_config = b.ranged_attack.damage_max
    tt.ranged.attacks[1].hit_time = fts(2)
    tt.ranged.attacks[1].hit_cycles = 3
    tt.ranged.attacks[1].hit_delay = fts(2)
    tt.ranged.attacks[1].hit_fx = "fx_bullet_drone_hero_mecha"
    tt.ranged.attacks[1].search_cooldown = 0.1
    tt.ranged.attacks[1].shoot_time = fts(8)
    tt.ranged.attacks[1].shoot_range = 25
    tt.ranged.attacks[1].sound = "HeroMechaGoblidroneAttack"
    tt.ranged.attacks[1].sound_args = {
        delay = fts(14)
    }
    tt.ranged.attacks[1].sound_chance = 0.5
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].xp_gain_factor = b.ranged_attack.xp_gain_factor
    tt.ranged.attacks[1].basic_attack = true
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].loop = true
    tt.tween.props[1].keys = {{0, vec_2(0, tt.flight_height + 2)}, {0.4, vec_2(0, tt.flight_height - 2)},
                              {0.8, vec_2(0, tt.flight_height + 2)}}
    tt.tween.props[1].interp = "sine"
    tt = E:register_t("zeppelin_hero_mecha", "decal_scripted")
    b = balance.heroes.hero_mecha.ultimate

    E:add_comps(tt, "force_motion", "ranged", "tween")

    tt.decal = "decal_hero_mecha_ultimate"
    tt.main_script.update = scripts.zeppelin_hero_mecha.update
    tt.force_motion.max_a = 900
    tt.force_motion.max_v = b.speed_out_of_range
    tt.force_motion.ramp_radius = 30
    tt.force_motion.fr = 0.05
    tt.force_motion.a_step = 20
    tt.flight_height = 60
    tt.flight_height_attack = 30
    tt.duration = b.duration
    tt.start_ts = nil

    for i = 1, 5 do
        tt.render.sprites[i] = E:clone_c("sprite")
        tt.render.sprites[i].prefix = "hero_onagro_ultimate_layer" .. i
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].group = "layers"
        tt.render.sprites[i].offset = vec_2(0, tt.flight_height)
        tt.render.sprites[i].z = Z_FLYING_HEROES
    end

    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].offset = vec_2(0, 0)
    tt.render.sprites[1].scale = vec_2(0.5, 0.5)
    tt.render.sprites[4].z = Z_BULLETS + 1
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].bullet = "bullet_zeppelin_hero_mecha"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 120)}
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].damage_type = b.ranged_attack.damage_type
    tt.ranged.attacks[1].damage_min_config = b.ranged_attack.damage_min
    tt.ranged.attacks[1].damage_max_config = b.ranged_attack.damage_max
    tt.ranged.attacks[1].shoot_time = fts(4)
    tt.ranged.attacks[1].sound_args = {
        delay = fts(14)
    }
    tt.ranged.attacks[1].sound_chance = 0.5
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE, F_FLYING, F_CLIFF)
    tt.ranged.attacks[1].xp_gain_factor = b.ranged_attack.xp_gain_factor
    tt.ranged.attacks[1].basic_attack = true
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].loop = false
    tt.tween.props[1].keys = {{0, vec_2(0, tt.flight_height)}, {2, vec_2(0, tt.flight_height_attack)}}
    tt.tween.props[1].interp = "linear"
    tt.tween.props[1].sprite_id = 2
    tt.tween.props[2] = table.deepclone(tt.tween.props[1])
    tt.tween.props[2].sprite_id = 3
    tt.tween.props[3] = table.deepclone(tt.tween.props[1])
    tt.tween.props[3].sprite_id = 4
    tt.tween.props[4] = table.deepclone(tt.tween.props[1])
    tt.tween.props[4].sprite_id = 5
    tt.tween.props[5] = table.deepclone(tt.tween.props[1])
    tt.tween.props[5].name = "scale"
    tt.tween.props[5].keys = {{0, vec_2(0.5, 0.5)}, {2, vec_2(1, 1)}}
    tt.tween.props[5].sprite_id = 1
    tt.speed_out_of_range = b.speed_out_of_range
    tt.speed_in_range = b.speed_in_range
    tt.attack_radius = b.attack_radius
    tt = E:register_t("hero_venom", "hero5")
    b = balance.heroes.hero_venom

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_min = b.basic_melee.damage_min
    tt.hero.level_stats.melee_damage_max = b.basic_melee.damage_max
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.ranged_tentacle = E:clone_c("hero_skill")
    tt.hero.skills.ranged_tentacle.cooldown = b.ranged_tentacle.cooldown
    tt.hero.skills.ranged_tentacle.damage_min = b.ranged_tentacle.damage_min
    tt.hero.skills.ranged_tentacle.damage_max = b.ranged_tentacle.damage_max
    tt.hero.skills.ranged_tentacle.bleed_chance = b.ranged_tentacle.bleed_chance
    tt.hero.skills.ranged_tentacle.bleed_damage_min = b.ranged_tentacle.bleed_damage_min
    tt.hero.skills.ranged_tentacle.bleed_damage_max = b.ranged_tentacle.bleed_damage_max
    tt.hero.skills.ranged_tentacle.bleed_every = b.ranged_tentacle.bleed_every
    tt.hero.skills.ranged_tentacle.bleed_duration = b.ranged_tentacle.bleed_duration
    tt.hero.skills.ranged_tentacle.hr_available = true
    tt.hero.skills.ranged_tentacle.hr_icon = "0006"
    tt.hero.skills.ranged_tentacle.hr_order = 1
    tt.hero.skills.ranged_tentacle.hr_cost = {1, 1, 1}
    tt.hero.skills.ranged_tentacle.xp_gain = b.ranged_tentacle.xp_gain
    tt.hero.skills.ranged_tentacle.key = "RANGED_TENTACLE"
    tt.hero.skills.inner_beast = E:clone_c("hero_skill")
    tt.hero.skills.inner_beast.cooldown = b.inner_beast.cooldown
    tt.hero.skills.inner_beast.duration = b.inner_beast.duration
    tt.hero.skills.inner_beast.damage_factor = b.inner_beast.basic_melee.damage_factor
    tt.hero.skills.inner_beast.trigger_hp = b.inner_beast.trigger_hp
    tt.hero.skills.inner_beast.xp_gain = b.inner_beast.xp_gain
    tt.hero.skills.inner_beast.hr_available = true
    tt.hero.skills.inner_beast.hr_icon = "0007"
    tt.hero.skills.inner_beast.hr_order = 2
    tt.hero.skills.inner_beast.hr_cost = {2, 2, 2}
    tt.hero.skills.inner_beast.key = "INNER_BEAST"
    tt.hero.skills.floor_spikes = E:clone_c("hero_skill")
    tt.hero.skills.floor_spikes.cooldown = b.floor_spikes.cooldown
    tt.hero.skills.floor_spikes.damage_type = b.floor_spikes.damage_type
    tt.hero.skills.floor_spikes.damage_radius = b.floor_spikes.damage_radius
    tt.hero.skills.floor_spikes.damage_min = b.floor_spikes.damage_min
    tt.hero.skills.floor_spikes.damage_max = b.floor_spikes.damage_max
    tt.hero.skills.floor_spikes.spikes = b.floor_spikes.spikes
    tt.hero.skills.floor_spikes.xp_gain = b.floor_spikes.xp_gain
    tt.hero.skills.floor_spikes.hr_available = true
    tt.hero.skills.floor_spikes.hr_icon = "0008"
    tt.hero.skills.floor_spikes.hr_order = 3
    tt.hero.skills.floor_spikes.hr_cost = {2, 2, 2}
    tt.hero.skills.floor_spikes.key = "FLOOR_SPIKES"
    tt.hero.skills.eat_enemy = E:clone_c("hero_skill")
    tt.hero.skills.eat_enemy.cooldown = b.eat_enemy.cooldown
    tt.hero.skills.eat_enemy.hp_trigger = b.eat_enemy.hp_trigger
    tt.hero.skills.eat_enemy.regen = b.eat_enemy.regen
    tt.hero.skills.eat_enemy.cooldown = b.eat_enemy.cooldown
    tt.hero.skills.eat_enemy.hr_available = true
    tt.hero.skills.eat_enemy.hr_icon = "0009"
    tt.hero.skills.eat_enemy.hr_order = 4
    tt.hero.skills.eat_enemy.hr_cost = {3, 3, 3}
    tt.hero.skills.eat_enemy.xp_gain = b.eat_enemy.xp_gain
    tt.hero.skills.eat_enemy.key = "EAT_ENEMY"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "controller_hero_venom_ultimate"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.duration = b.ultimate.duration
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0010"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "CREEPING_DEATH"
    tt.hero.team = TEAM_DARK_ARMY
    tt.hero.fn_level_up = scripts.hero_venom.level_up
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.offset = vec_2(0, 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.info.fn = scripts.hero_basic.get_info_melee
    tt.info.hero_portrait = "hero_portraits_0008"
    tt.info.ultimate_icon = "0008"
    tt.info.i18n_key = "HERO_VENOM"
    tt.info.portrait = "portraits_hero" .. "_0008"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_venom.insert
    tt.main_script.update = scripts.hero_venom.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.slimewalk = {}
    tt.slimewalk.min_distance = b.distance_to_slimewalk
    tt.slimewalk.extra_speed = b.slimewalk_speed
    tt.slimewalk.animations = {"run_in", "run", "run_out"}
    tt.slimewalk.decal = "decal_hero_venom_slimewalk"
    tt.slimewalk.sound = nil
    tt.beast = {}
    tt.beast.health_bar_offset = vec_2(0, 55)
    tt.beast.health_bar_type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.beast.click_rect = r(-30, -5, 60, 60)
    tt.beast.hit_mod_offset = vec_2(0, 25)
    tt.beast.regen_health = b.inner_beast.basic_melee.regen_health
    tt.beast.lvl_up_fx = "fx_hero_venom_beast_lvl_up"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].prefix = "hero_venom_hero"
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.sound_events.change_rally_point = "HeroVenomTaunt"
    tt.sound_events.death = "HeroVenomDeath"
    tt.sound_events.respawn = "HeroVenomTauntIntro"
    tt.sound_events.hero_room_select = "HeroVenomTauntSelect"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].animation = "attack_1"
    tt.melee.attacks[1].cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].shared_cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].hit_time = fts(16)
    tt.melee.attacks[1].hit_fx = "fx_hero_venom_melee_attack_hit"
    tt.melee.attacks[1].hit_offset = vec_2(45, 15)
    tt.melee.attacks[1].sound = "HeroVenomBasicAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(14)
    }
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "attack_2"
    tt.melee.attacks[2].chance = 0.2
    tt.melee.attacks[2].hit_time = fts(20)
    tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[3].animation = "attack_1"
    tt.melee.attacks[3].cooldown = b.inner_beast.basic_melee.cooldown
    tt.melee.attacks[3].shared_cooldown = nil
    tt.melee.attacks[3].hit_time = fts(10)
    tt.melee.attacks[3].disabled = true
    tt.melee.attacks[3].xp_gain_factor = b.inner_beast.basic_melee.xp_gain_factor
    tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[3])
    tt.melee.attacks[4].animation = "attack_2"
    tt.melee.attacks[4].hit_time = fts(8)
    tt.melee.attacks[5] = table.deepclone(tt.melee.attacks[3])
    tt.melee.attacks[5].animation = "attack_3"
    tt.melee.attacks[5].hit_time = fts(8)
    tt.melee.attacks[6] = E:clone_c("melee_attack")
    tt.melee.attacks[6].animation = "instakill"
    tt.melee.attacks[6].cooldown = nil
    tt.melee.attacks[6].hp_trigger = b.eat_enemy.hp_trigger
    tt.melee.attacks[6].hit_time = fts(23)
    tt.melee.attacks[6].sound_hit = nil
    tt.melee.attacks[6].sound_hit_args = {
        delay = fts(14)
    }
    tt.melee.attacks[6].xp_from_skill = "eat_enemy"
    tt.melee.attacks[6].basic_attack = false
    tt.melee.attacks[6].instakill = true
    tt.melee.attacks[6].disabled = true
    tt.melee.attacks[6].fn_can = function(t, s, a, target)
        return target.health and target.health.hp <= target.health.hp_max * a.hp_trigger and target.unit.size ==
                   UNIT_SIZE_SMALL and not t.is_transformed
    end
    tt.melee.attacks[6].mod_regen = "mod_hero_venom_eat_enemy_regen"
    tt.melee.attacks[6].sound = "HeroVenomRenewFleshCast"
    tt.melee.attacks[6].sound_args = {
        delay = fts(10)
    }
    tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
    tt.timed_attacks.list[1].animation = "ranged_skill"
    tt.timed_attacks.list[1].min_range = b.ranged_tentacle.min_range
    tt.timed_attacks.list[1].max_range = b.ranged_tentacle.max_range
    tt.timed_attacks.list[1].bullet = "bullet_hero_venom_ranged_tentacle"
    tt.timed_attacks.list[1].shoot_time = fts(4)
    tt.timed_attacks.list[1].bullet_start_offset = vec_2(8, 15)
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].ignore_out_of_range_check = 1
    tt.timed_attacks.list[1].sound = "HeroVenomHeartseekerCast"
    tt.timed_attacks.list[1].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[1].vis_bans = bor(F_NIGHTMARE)
    tt.timed_attacks.list[2] = E:clone_c("custom_attack")
    tt.timed_attacks.list[2].animation_in = "beast_in"
    tt.timed_attacks.list[2].animation_out = "out"
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE)
    tt.timed_attacks.list[2].sound_in = "HeroVenomInnerBeastCast"
    tt.timed_attacks.list[2].sound_out = "HeroVenomInnerBeastOut"
    tt.timed_attacks.list[2].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[3] = E:clone_c("custom_attack")
    tt.timed_attacks.list[3].animation_in = "spikes_in"
    tt.timed_attacks.list[3].animation_idle = "spikes_idle"
    tt.timed_attacks.list[3].animation_out = "spikes_out"
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].cast_time = fts(12)
    tt.timed_attacks.list[3].damage_type = b.floor_spikes.damage_type
    tt.timed_attacks.list[3].range_trigger_min = b.floor_spikes.range_trigger_min
    tt.timed_attacks.list[3].range_trigger_max = b.floor_spikes.range_trigger_max
    tt.timed_attacks.list[3].spikes = b.floor_spikes.spikes
    tt.timed_attacks.list[3].min_targets = b.floor_spikes.min_targets
    tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[3].vis_flags = bor(F_AREA)
    tt.timed_attacks.list[3].sound_in = "HeroVenomDeadlySpikesCast"
    tt.timed_attacks.list[3].sound_out = "HeroVenomDeadlySpikesOut"
    tt.timed_attacks.list[3].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[3].spike_template = {"decal_hero_venom_spike_a", "decal_hero_venom_spike_b"}
    tt.ui.click_rect = r(-27, -5, 54, 50)
    tt.death_decal = "decal_hero_venom_death"
    tt = E:register_t("hero_robot", "hero5")
    b = balance.heroes.hero_robot

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_min = b.basic_melee.damage_min
    tt.hero.level_stats.melee_damage_max = b.basic_melee.damage_max
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.skills.jump = E:clone_c("hero_skill")
    tt.hero.skills.jump.cooldown = b.jump.cooldown
    tt.hero.skills.jump.damage_min = b.jump.damage_min
    tt.hero.skills.jump.damage_max = b.jump.damage_max
    tt.hero.skills.jump.stun_duration = b.jump.stun_duration
    tt.hero.skills.jump.hr_available = true
    tt.hero.skills.jump.hr_order = 1
    tt.hero.skills.jump.hr_cost = {1, 1, 1}
    tt.hero.skills.jump.xp_gain = b.jump.xp_gain
    tt.hero.skills.jump.key = "JUMP"
    tt.hero.skills.fire = E:clone_c("hero_skill")
    tt.hero.skills.fire.cooldown = b.fire.cooldown
    tt.hero.skills.fire.damage_min = b.fire.damage_min
    tt.hero.skills.fire.damage_max = b.fire.damage_max
    tt.hero.skills.fire.smoke_duration = b.fire.smoke_duration
    tt.hero.skills.fire.slow_duration = b.fire.slow_duration
    tt.hero.skills.fire.hr_available = true
    tt.hero.skills.fire.hr_order = 2
    tt.hero.skills.fire.hr_cost = {2, 2, 2}
    tt.hero.skills.fire.xp_gain = b.fire.xp_gain
    tt.hero.skills.fire.key = "FIRE"
    tt.hero.skills.explode = E:clone_c("hero_skill")
    tt.hero.skills.explode.cooldown = b.explode.cooldown
    tt.hero.skills.explode.damage_min = b.explode.damage_min
    tt.hero.skills.explode.damage_max = b.explode.damage_max
    tt.hero.skills.explode.burning_damage_min = b.explode.burning_damage_min
    tt.hero.skills.explode.burning_damage_max = b.explode.burning_damage_max
    tt.hero.skills.explode.hr_available = true
    tt.hero.skills.explode.hr_order = 3
    tt.hero.skills.explode.hr_cost = {3, 3, 3}
    tt.hero.skills.explode.xp_gain = b.explode.xp_gain
    tt.hero.skills.explode.key = "EXPLODE"
    tt.hero.skills.uppercut = E:clone_c("hero_skill")
    tt.hero.skills.uppercut.cooldown = b.uppercut.cooldown
    tt.hero.skills.uppercut.max_health = b.uppercut.max_health
    tt.hero.skills.uppercut.life_threshold = b.uppercut.life_threshold
    tt.hero.skills.uppercut.hr_available = true
    tt.hero.skills.uppercut.hr_order = 4
    tt.hero.skills.uppercut.hr_cost = {3, 2, 1}
    tt.hero.skills.uppercut.xp_gain = b.uppercut.xp_gain
    tt.hero.skills.uppercut.key = "UPPERCUT"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "controller_hero_robot_ultimate"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.skills.ultimate.burning_damage_min = b.ultimate.burning_damage_min
    tt.hero.skills.ultimate.burning_damage_max = b.ultimate.burning_damage_max
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0010"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 4, 4, 4}
    tt.hero.skills.ultimate.key = "TRAIN"
    tt.particles_name_1 = "ps_hero_robot_smoke_1"
    tt.particles_name_2 = "ps_hero_robot_smoke_2"
    tt.hero.team = TEAM_DARK_ARMY
    tt.hero.fn_level_up = scripts.hero_robot.level_up
    tt.health.dead_lifetime = b.dead_lifetime
    tt.health_bar.offset = vec_2(0, 55)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.info.fn = scripts.hero_basic.get_info_melee
    tt.info.hero_portrait = "hero_portraits_0009"
    tt.info.ultimate_icon = "0009"
    tt.info.i18n_key = "HERO_ROBOT"
    tt.info.portrait = "portraits_hero" .. "_0009"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_robot.insert
    tt.main_script.update = scripts.hero_robot.update
    tt.motion.max_speed = b.speed
    tt.regen.cooldown = b.regen_cooldown
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].prefix = "Blaze_pibe"
    tt.render.sprites[1].draw_order = DO_HEROES
    tt.soldier.melee_slot_offset = vec_2(20, 0)
    tt.sound_events.change_rally_point = "HeroRobotTaunt"
    tt.sound_events.death = "HeroRobotDeath"
    tt.sound_events.respawn = "HeroRobotTauntIntro"
    tt.sound_events.hero_room_select = "HeroRobotTauntSelect"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.melee.range = balance.heroes.common.melee_attack_range
    tt.melee.attacks[1] = E:clone_c("melee_attack")
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].shared_cooldown = b.basic_melee.cooldown
    tt.melee.attacks[1].hit_time = fts(16)
    tt.melee.attacks[1].hit_offset = vec_2(45, 15)
    tt.melee.attacks[1].xp_gain_factor = b.basic_melee.xp_gain_factor
    tt.melee.attacks[1].basic_attack = true
    tt.melee.attacks[1].sound = "CommonNoSwordAttack"
    tt.melee.attacks[1].sound_args = {
        delay = fts(8)
    }
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation_prepare = "skill1start"
    tt.timed_attacks.list[1].animation = "skill1"
    tt.timed_attacks.list[1].cooldown = nil
    tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_CLIFF)
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].sound_cast = "HeroRobotDeepImpactCast"
    tt.timed_attacks.list[1].sound_impact = "HeroRobotDeepImpactImpact"
    tt.timed_attacks.list[1].sound_impact_args = {
        delay = fts(14)
    }
    tt.timed_attacks.list[1].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[1].min_range = b.jump.min_range
    tt.timed_attacks.list[1].max_range = b.jump.max_range
    tt.timed_attacks.list[1].node_prediction = fts(36)
    tt.timed_attacks.list[1].aura = "aura_hero_robot_skill_jump"
    tt.timed_attacks.list[1].fall_ahead = 8
    tt.timed_attacks.list[1].damage_radius = b.jump.damage_radius
    tt.timed_attacks.list[1].damage_min = nil
    tt.timed_attacks.list[1].damage_max = nil
    tt.timed_attacks.list[1].damage_type = b.jump.damage_type
    tt.timed_attacks.list[1].damage_bans = bor(F_FLYING)
    tt.timed_attacks.list[1].damage_flags = bor(F_AREA)
    tt.timed_attacks.list[2] = E:clone_c("custom_attack")
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[2].animation = "skill2"
    tt.timed_attacks.list[2].min_range = b.fire.min_range
    tt.timed_attacks.list[2].max_range = b.fire.max_range
    tt.timed_attacks.list[2].node_prediction = fts(36)
    tt.timed_attacks.list[2].shoot_time = fts(25)
    tt.timed_attacks.list[2].bullet = "bullet_hero_robot_skill_fire"
    tt.timed_attacks.list[2].bullet_start_offset = vec_2(7, 26)
    tt.timed_attacks.list[2].shoots = 16
    tt.timed_attacks.list[2].min_targets = b.fire.min_targets
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[2].damage_bans = bor(F_FLYING)
    tt.timed_attacks.list[2].damage_flags = bor(F_AREA)
    tt.timed_attacks.list[2].sound = "HeroRobotSmokescreenCast"
    tt.timed_attacks.list[2].sound_args = {
        delay = fts(0)
    }
    tt.timed_attacks.list[3] = E:clone_c("custom_attack")
    tt.timed_attacks.list[3].animation = "skill4"
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].damage_min = nil
    tt.timed_attacks.list[3].damage_max = nil
    tt.timed_attacks.list[3].vis_bans = bor(F_FLYING)
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[3].min_range = b.explode.min_range
    tt.timed_attacks.list[3].max_range = b.explode.max_range
    tt.timed_attacks.list[3].node_prediction = fts(36)
    tt.timed_attacks.list[3].decal = "decal_hero_robot_skill_explode"
    tt.timed_attacks.list[3].load_time = fts(25)
    tt.timed_attacks.list[3].damage_bans = bor(F_FLYING)
    tt.timed_attacks.list[3].damage_flags = bor(F_AREA)
    tt.timed_attacks.list[3].damage_radius = b.explode.damage_radius
    tt.timed_attacks.list[3].damage_type = b.explode.damage_type
    tt.timed_attacks.list[3].mod = "mod_hero_robot_skill_explode"
    tt.timed_attacks.list[3].min_targets = b.explode.min_targets
    tt.timed_attacks.list[3].sound = "HeroRobotImmolationCast"
    tt.timed_attacks.list[4] = E:clone_c("custom_attack")
    tt.timed_attacks.list[4].disabled = true
    tt.timed_attacks.list[4].min_cooldown = b.shared_cooldown
    tt.timed_attacks.list[4].animation = "skill3"
    tt.timed_attacks.list[4].shoot_time = fts(25)
    tt.timed_attacks.list[4].enemy_move_offset = vec_2(10, 40)
    tt.timed_attacks.list[4].mod = "mod_hero_robot_skill_uppercut"
    tt.timed_attacks.list[4].life_threshold = nil
    tt.timed_attacks.list[4].sound = "HeroRobotUppercutCast"
    tt.ui.click_rect = r(-27, -5, 54, 50)
    tt.ui.click_rect_fly = r(-27, 20, 54, 50)
    tt.ui.click_rect_nofly = r(-27, -5, 54, 50)
    tt.vis.bans = bor(F_POLYMORPH, F_DISINTEGRATED, F_CANNIBALIZE, F_SKELETON, F_BLOOD, F_POISON)
    tt.flywalk = {}
    tt.flywalk.min_distance = b.distance_to_flywalk
    tt.flywalk.extra_speed = b.flywalk_speed
    tt.flywalk.animations = {"flystart", "passiveloop", "passiveout"}
    tt.flywalk.sound = "HeroRobotJetpackCast"



    tt = E:register_t("hero_dragon_gem", "hero5")

    E:add_comps(tt, "ranged", "timed_attacks", "tween")

    b = balance.heroes.hero_dragon_gem
    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.level_stats.ranged_damage_min = b.basic_ranged_shot.damage_min
    tt.hero.level_stats.ranged_damage_max = b.basic_ranged_shot.damage_max
    tt.hero.skills.stun = E:clone_c("hero_skill")
    tt.hero.skills.stun.hr_cost = {3, 2, 1}
    tt.hero.skills.stun.hr_icon = "0041"
    tt.hero.skills.stun.hr_order = 1
    tt.hero.skills.stun.hr_available = true
    tt.hero.skills.stun.duration = b.stun.duration
    tt.hero.skills.stun.cooldown = b.stun.cooldown
    tt.hero.skills.stun.xp_gain = b.stun.xp_gain
    tt.hero.skills.stun.key = "STUN"
    tt.hero.skills.floor_impact = E:clone_c("hero_skill")
    tt.hero.skills.floor_impact.cooldown = b.floor_impact.cooldown
    tt.hero.skills.floor_impact.damage_min = b.floor_impact.damage_min
    tt.hero.skills.floor_impact.damage_max = b.floor_impact.damage_max
    tt.hero.skills.floor_impact.hr_cost = {2, 2, 2}
    tt.hero.skills.floor_impact.hr_icon = "0042"
    tt.hero.skills.floor_impact.hr_order = 2
    tt.hero.skills.floor_impact.hr_available = true
    tt.hero.skills.floor_impact.xp_gain = b.floor_impact.xp_gain
    tt.hero.skills.floor_impact.key = "FLOOR_IMPACT"
    tt.hero.skills.crystal_instakill = E:clone_c("hero_skill")
    tt.hero.skills.crystal_instakill.cooldown = b.crystal_instakill.cooldown
    tt.hero.skills.crystal_instakill.damage_min = b.crystal_instakill.damage_aoe_min
    tt.hero.skills.crystal_instakill.damage_max = b.crystal_instakill.damage_aoe_max
    tt.hero.skills.crystal_instakill.hp_max = b.crystal_instakill.hp_max
    tt.hero.skills.crystal_instakill.hr_cost = {3, 3, 3}
    tt.hero.skills.crystal_instakill.hr_icon = "0043"
    tt.hero.skills.crystal_instakill.hr_order = 3
    tt.hero.skills.crystal_instakill.hr_available = true
    tt.hero.skills.crystal_instakill.xp_gain = b.crystal_instakill.xp_gain
    tt.hero.skills.crystal_instakill.key = "CRYSTAL_INSTAKILL"
    tt.hero.skills.crystal_totem = E:clone_c("hero_skill")
    tt.hero.skills.crystal_totem.cooldown = b.crystal_totem.cooldown
    tt.hero.skills.crystal_totem.duration = b.crystal_totem.duration
    tt.hero.skills.crystal_totem.damage_min = b.crystal_totem.damage_min
    tt.hero.skills.crystal_totem.damage_max = b.crystal_totem.damage_max
    tt.hero.skills.crystal_totem.hr_cost = {1, 1, 1}
    tt.hero.skills.crystal_totem.hr_icon = "0044"
    tt.hero.skills.crystal_totem.hr_order = 4
    tt.hero.skills.crystal_totem.hr_available = true
    tt.hero.skills.crystal_totem.xp_gain = b.crystal_totem.xp_gain
    tt.hero.skills.crystal_totem.key = "CRYSTAL_TOTEM"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_dragon_gem_ultimate"
    tt.hero.skills.ultimate.damage_min = b.ultimate.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.damage_max
    tt.hero.skills.ultimate.max_shards = b.ultimate.max_shards
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0006"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 3, 4, 5}
    tt.hero.skills.ultimate.hr_available = true
    tt.hero.skills.ultimate.key = "FALLING_CRYSTALS"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.team = TEAM_DARK_ARMY
    tt.flight_height = 80
    tt.health.dead_lifetime = 30
    tt.health_bar.draw_order = -1
    tt.health_bar.offset = vec_2(0, 170)
    tt.health_bar.sort_y_offset = -171
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.health_bar.z = Z_FLYING_HEROES
    tt.hero.fn_level_up = scripts.hero_dragon_gem.level_up
    tt.hero.use_custom_spawn_point = true
    tt.idle_flip.cooldown = 10
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0011"
    tt.info.i18n_key = "HERO_DRAGON_GEM"
    tt.info.portrait = "portraits_hero" .. "_0011"
    tt.info.ultimate_icon = "0011"
    tt.info.ultimate_pointer_style = "area"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_dragon_gem.insert
    tt.main_script.update = scripts.hero_dragon_gem.update
    tt.motion.max_speed = b.speed
    tt.nav_rally.requires_node_nearby = false
    tt.nav_grid.ignore_waypoints = true
    tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK,
        TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
    tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
    tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
    tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
    tt.regen.cooldown = 1
    tt.render.sprites[1].offset.y = tt.flight_height
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "hero_dragon_gem"
    tt.render.sprites[1].name = "respawn"
    tt.render.sprites[1].angles.walk = {"walk"}
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "hero_lumenir_hero_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].z = Z_DECALS + 1
    tt.soldier.melee_slot_offset = vec_2(0, 0)
    tt.sound_events.change_rally_point = "HeroDragonGemTaunt"
    tt.sound_events.death = "HeroDragonGemDeath"
    tt.sound_events.respawn = "HeroDragonGemTauntIntro"
    tt.sound_events.hero_room_select = "HeroDragonGemTauntSelect"
    tt.ui.click_rect = r(-37, tt.flight_height - 20, 75, 75)
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.death_animation = "death_dragon"
    tt.unit.hide_after_death = false
    tt.hero.tombstone_concurrent_with_death = true
    tt.hero.tombstone_show_time = fts(1)
    tt.hero.tombstone_decal = "decal_hero_dragon_gem_crystal_tomb"
    tt.hero.tombstone_force_over_path = true
    tt.hero.tombstone_respawn_animation = "respawn_crystals"
    tt.hero.respawn_animation = "respawn_dragon"
    tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
    tt.vis.flags = bor(tt.vis.flags, F_FLYING)
    tt.passive_charge = {}
    tt.passive_charge.distance_to_charge = b.passive_charge.distance_threshold
    tt.passive_charge.mod = "mod_hero_dragon_gem_passive_charge"
    tt.passive_charge.shots_amount = b.passive_charge.shots_amount
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].bullet = "bolt_hero_dragon_gem_attack"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
    tt.ranged.attacks[1].cooldown = 1
    tt.ranged.attacks[1].min_range = b.basic_ranged_shot.min_range
    tt.ranged.attacks[1].max_range = b.basic_ranged_shot.max_range
    tt.ranged.attacks[1].shoot_time = fts(14)
    tt.ranged.attacks[1].sync_animation = true
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].start_sound = "HeroDragonGemBasicAttackCast"
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.ranged.attacks[1].ignore_offset = vec_2(0, tt.flight_height + 10)
    tt.ranged.attacks[1].radius = 100
    tt.ranged.attacks[1].basic_attack = true
    tt.ranged.attacks[2] = E:clone_c("aura_attack")
    tt.ranged.attacks[2].disabled = true
    tt.ranged.attacks[2].animation = "breath"
    tt.ranged.attacks[2].shoot_time = fts(12)
    tt.ranged.attacks[2].min_targets = b.stun.min_targets
    tt.ranged.attacks[2].min_range = 0
    tt.ranged.attacks[2].max_range = b.stun.range
    tt.ranged.attacks[2].sync_animation = true
    tt.ranged.attacks[2].xp_from_skill = "stun"
    tt.ranged.attacks[2].vis_flags = bor(F_RANGED, F_ENEMY)
    tt.ranged.attacks[2].vis_bans = F_FLYING
    tt.ranged.attacks[2].bullet = "ray_hero_dragon_gem_stun"
    tt.ranged.attacks[2].range_nodes_max = 30
    tt.ranged.attacks[2].range_nodes_min = 20
    tt.ranged.attacks[2].bullet_start_offset = {vec_2(46, tt.flight_height - 23), vec_2(50, tt.flight_height - 23)}
    tt.ranged.attacks[2].sound = "HeroDragonGemParalyzingBreathCast"
    tt.ranged.attacks[3] = E:clone_c("aura_attack")
    tt.ranged.attacks[3].disabled = true
    tt.ranged.attacks[3].mod = "mod_hero_lumenir_sword_hit"
    tt.ranged.attacks[3].min_nodes = 20
    tt.ranged.attacks[3].cooldown = nil
    tt.ranged.attacks[3].fall_time = fts(24)
    tt.ranged.attacks[3].sync_animation = true
    tt.ranged.attacks[3].animation = "shards"
    tt.ranged.attacks[3].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[3].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.ranged.attacks[3].range = b.floor_impact.range
    tt.ranged.attacks[3].xp_from_skill = "floor_impact"
    tt.ranged.attacks[3].range_nodes_max = b.floor_impact.max_nodes_trigger
    tt.ranged.attacks[3].range_nodes_min = b.floor_impact.min_nodes_trigger
    tt.ranged.attacks[3].min_targets = b.floor_impact.min_targets
    tt.ranged.attacks[3].entity = "decal_hero_dragon_gem_floor_impact_shard"
    tt.ranged.attacks[3].floor_decal = "decal_hero_dragon_gem_floor_decal"
    tt.ranged.attacks[3].shards = b.floor_impact.shards
    tt.ranged.attacks[3].nodes_between_shards = b.floor_impact.nodes_between_shards
    tt.ranged.attacks[3].initial_offset = 4
    tt.ranged.attacks[3].distance_to_start_node = 20
    tt.ranged.attacks[3].controller = "controller_hero_dragon_gem_skill_floor_impact_spawner"
    tt.ranged.attacks[3].sound = "HeroDragonGemPrismaticShardCast"
    tt.ranged.attacks[4] = E:clone_c("mod_attack")
    tt.ranged.attacks[4].disabled = true
    tt.ranged.attacks[4].cooldown = nil
    tt.ranged.attacks[4].shoot_time = fts(15)
    tt.ranged.attacks[4].sync_animation = true
    tt.ranged.attacks[4].mod = "mod_hero_dragon_gem_crystal_instakill"
    tt.ranged.attacks[4].animation = "red_death"
    tt.ranged.attacks[4].max_range = b.crystal_instakill.max_range
    tt.ranged.attacks[4].hp_max = nil
    tt.ranged.attacks[4].vis_flags = bor(F_RANGED, F_MOD)
    tt.ranged.attacks[4].vis_bans = bor(F_BOSS, F_MINIBOSS, F_FLYING, F_CLIFF)
    tt.ranged.attacks[4].xp_from_skill = "crystal_instakill"
    tt.ranged.attacks[4].sound = "HeroDragonGemRedDeathCast"
    tt.ranged.attacks[4].sound_args = {
        delay = fts(11)
    }
    tt.ranged.attacks[5] = E:clone_c("bullet_attack")
    tt.ranged.attacks[5].disabled = true
    tt.ranged.attacks[5].cooldown = nil
    tt.ranged.attacks[5].animation = "conduit"
    tt.ranged.attacks[5].sync_animation = true
    tt.ranged.attacks[5].bullet = "bullet_hero_dragon_gem_crystal_totem"
    tt.ranged.attacks[5].bullet_start_offset = vec_2(0, tt.flight_height + 20)
    tt.ranged.attacks[5].shoot_time = fts(12)
    tt.ranged.attacks[5].min_targets = b.crystal_totem.min_targets
    tt.ranged.attacks[5].max_range_trigger = b.crystal_totem.max_range_trigger
    tt.ranged.attacks[5].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[5].vis_bans = bor(F_FLYING)
    tt.ranged.attacks[5].xp_from_skill = "crystal_totem"
    tt.ranged.attacks[5].nodes_prediction = 10
    tt.ranged.attacks[5].sound = "HeroDragonGemPowerConduitCast"
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].sprite_id = 2
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt = E:register_t("hero_dragon_gem_ultimate")
    b = balance.heroes.hero_dragon_gem.ultimate

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_dragon_gem_ultimate.can_fire_fn
    tt.main_script.update = scripts.hero_dragon_gem_ultimate.update
    tt.range = b.range
    tt.spawn_delay = fts(5)
    tt.vis_flags = bor(F_RANGED)
    tt.vis_bans = bor(F_FLYING)
    tt.decal = "decal_hero_dragon_gem_ultimate_shard"
    tt.max_shards = b.max_shards
    tt.prediction_nodes = fts(15)
    tt.distance_between_shards = b.distance_between_shards
    tt.random_ni_spread = b.random_ni_spread
    tt = E:register_t("hero_bird", "hero5")

    E:add_comps(tt, "ranged", "timed_attacks", "tween")

    b = balance.heroes.hero_bird
    tt.hero.level_stats.armor = b.armor
    tt.hero.level_stats.hp_max = b.hp_max
    tt.hero.level_stats.melee_damage_max = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.melee_damage_min = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    tt.hero.level_stats.regen_health = b.regen_health
    tt.hero.level_stats.ranged_damage_min = b.basic_attack.damage_min
    tt.hero.level_stats.ranged_damage_max = b.basic_attack.damage_max
    tt.hero.skills.cluster_bomb = E:clone_c("hero_skill")
    tt.hero.skills.cluster_bomb.hr_cost = {3, 3, 3}
    tt.hero.skills.cluster_bomb.hr_icon = "0041"
    tt.hero.skills.cluster_bomb.hr_order = 1
    tt.hero.skills.cluster_bomb.hr_available = true
    tt.hero.skills.cluster_bomb.cooldown = b.cluster_bomb.cooldown
    tt.hero.skills.cluster_bomb.explosion_damage_min = b.cluster_bomb.explosion_damage_min
    tt.hero.skills.cluster_bomb.explosion_damage_max = b.cluster_bomb.explosion_damage_max
    tt.hero.skills.cluster_bomb.fire_duration = b.cluster_bomb.fire_duration
    tt.hero.skills.cluster_bomb.burn_damage_min = b.cluster_bomb.burning.damage
    tt.hero.skills.cluster_bomb.burn_damage_max = b.cluster_bomb.burning.damage
    tt.hero.skills.cluster_bomb.key = "CLUSTER_BOMB"
    tt.hero.skills.shout_stun = E:clone_c("hero_skill")
    tt.hero.skills.shout_stun.cooldown = b.shout_stun.cooldown
    tt.hero.skills.shout_stun.stun_duration = b.shout_stun.stun_duration
    tt.hero.skills.shout_stun.slow_duration = b.shout_stun.slow_duration
    tt.hero.skills.shout_stun.hr_cost = {2, 2, 2}
    tt.hero.skills.shout_stun.hr_icon = "0042"
    tt.hero.skills.shout_stun.hr_order = 2
    tt.hero.skills.shout_stun.hr_available = true
    tt.hero.skills.shout_stun.xp_gain = b.shout_stun.xp_gain
    tt.hero.skills.shout_stun.key = "SHOUT_STUN"
    tt.hero.skills.gattling = E:clone_c("hero_skill")
    tt.hero.skills.gattling.cooldown = b.gattling.cooldown
    tt.hero.skills.gattling.duration = b.gattling.duration
    tt.hero.skills.gattling.damage_min = b.gattling.damage_min
    tt.hero.skills.gattling.damage_max = b.gattling.damage_max
    tt.hero.skills.gattling.hr_cost = {1, 1, 1}
    tt.hero.skills.gattling.hr_icon = "0044"
    tt.hero.skills.gattling.hr_order = 3
    tt.hero.skills.gattling.hr_available = true
    tt.hero.skills.gattling.xp_gain = b.gattling.xp_gain
    tt.hero.skills.gattling.key = "GATTLING"
    tt.hero.skills.eat_instakill = E:clone_c("hero_skill")
    tt.hero.skills.eat_instakill.cooldown = b.eat_instakill.cooldown
    tt.hero.skills.eat_instakill.damage_min = b.eat_instakill.damage_aoe_min
    tt.hero.skills.eat_instakill.damage_max = b.eat_instakill.damage_aoe_max
    tt.hero.skills.eat_instakill.hp_max = b.eat_instakill.hp_max
    tt.hero.skills.eat_instakill.hr_cost = {3, 3, 3}
    tt.hero.skills.eat_instakill.hr_icon = "0043"
    tt.hero.skills.eat_instakill.hr_order = 4
    tt.hero.skills.eat_instakill.hr_available = true
    tt.hero.skills.eat_instakill.xp_gain = b.eat_instakill.xp_gain
    tt.hero.skills.eat_instakill.key = "EAT_INSTAKILL"
    tt.hero.skills.ultimate = E:clone_c("hero_skill")
    tt.hero.skills.ultimate.controller_name = "hero_bird_ultimate"
    tt.hero.skills.ultimate.damage_min = b.ultimate.bird.melee_attack.damage_min
    tt.hero.skills.ultimate.damage_max = b.ultimate.bird.melee_attack.damage_max
    tt.hero.skills.ultimate.duration = b.ultimate.bird.duration
    tt.hero.skills.ultimate.hr_available = false
    tt.hero.skills.ultimate.hr_icon = "0006"
    tt.hero.skills.ultimate.hr_order = 5
    tt.hero.skills.ultimate.hr_cost = {1, 3, 3, 3}
    tt.hero.skills.ultimate.hr_available = true
    tt.hero.skills.ultimate.key = "BIRDS_OF_PREY"
    tt.hero.skills.ultimate.cooldown = b.ultimate.cooldown
    tt.hero.team = TEAM_LINIREA
    tt.flight_height = 80
    tt.health.dead_lifetime = 30
    tt.health_bar.draw_order = -1
    tt.health_bar.offset = vec_2(0, 120)
    tt.health_bar.sort_y_offset = -171
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.health_bar.z = Z_FLYING_HEROES
    tt.hero.fn_level_up = scripts.hero_bird.level_up
    tt.hero.use_custom_spawn_point = true
    tt.idle_flip.cooldown = 10
    tt.info.fn = scripts.hero_basic.get_info_ranged_with_damage_factor
    tt.info.hero_portrait = "hero_portraits_0012"
    tt.info.i18n_key = "HERO_BIRD"
    tt.info.portrait = "portraits_hero" .. "_0012"
    tt.info.ultimate_icon = "0012"
    tt.info.ultimate_pointer_style = "area"
    tt.info.stat_hp = b.stats.hp
    tt.info.stat_armor = b.stats.armor
    tt.info.stat_damage = b.stats.damage
    tt.info.stat_cooldown = b.stats.cooldown
    tt.main_script.insert = scripts.hero_bird.insert
    tt.main_script.update = scripts.hero_bird.update
    tt.motion.max_speed = b.speed
    tt.nav_rally.requires_node_nearby = false
    tt.nav_grid.ignore_waypoints = true
    tt.all_except_flying_nowalk = bor(TERRAIN_NONE, TERRAIN_LAND, TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK,
        TERRAIN_SHALLOW, TERRAIN_FAERIE, TERRAIN_ICE)
    tt.nav_grid.valid_terrains = tt.all_except_flying_nowalk
    tt.nav_grid.valid_terrains_dest = tt.all_except_flying_nowalk
    tt.drag_line_origin_offset = vec_2(0, tt.flight_height)
    tt.regen.cooldown = 1
    tt.render.sprites[1].offset.y = tt.flight_height
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "gryph_character"
    tt.render.sprites[1].name = "respawn"
    tt.render.sprites[1].angles.walk = {"fly"}
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[1].angles.gattling_in = {"shootskillback", "shootskill"}
    tt.render.sprites[1].angles.gattling_loop = {"shootskillloopback", "shootskillloop"}
    tt.render.sprites[1].angles.gattling_out = {"shootskillendback", "shootskillend"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "gryph_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].z = Z_DECALS + 1
    tt.soldier.melee_slot_offset = vec_2(0, 0)
    tt.sound_events.change_rally_point = "HeroBirdTaunt"
    tt.sound_events.death = "HeroBirdDeath"
    tt.sound_events.respawn = "HeroBirdTauntIntro"
    tt.sound_events.hero_room_select = "HeroBirdTauntSelect"
    tt.ui.click_rect = r(-37, tt.flight_height - 35, 75, 75)
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.hide_after_death = true
    tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON, F_MOD)
    tt.vis.flags = bor(tt.vis.flags, F_FLYING)
    tt.hero.tombstone_show_time = fts(30)
    tt.hero.tombstone_decal = "decal_hero_bird_tomb"
    tt.hero.tombstone_concurrent_with_death = true
    tt.hero.tombstone_force_over_path = true
    tt.hero.respawn_animation = "levelup"
    tt.ranged.attacks[1] = E:clone_c("bullet_attack")
    tt.ranged.attacks[1].bullet = "bullet_hero_bird"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, tt.flight_height + 40), vec_2(-20, tt.flight_height + 40)}
    tt.ranged.attacks[1].cooldown = b.basic_attack.cooldown
    tt.ranged.attacks[1].min_range = b.basic_attack.min_range
    tt.ranged.attacks[1].max_range = b.basic_attack.max_range
    tt.ranged.attacks[1].shoot_time = fts(9)
    tt.ranged.attacks[1].sync_animation = true
    tt.ranged.attacks[1].animation = "attack"
    tt.ranged.attacks[1].node_prediction = fts(40)
    tt.ranged.attacks[1].ignore_hit_offset = true
    tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE, F_FLYING, F_CLIFF)
    tt.ranged.attacks[1].basic_attack = true
    tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].animation = "skillthrowclusterbomb"
    tt.timed_attacks.list[1].shoot_time = fts(18)
    tt.timed_attacks.list[1].explosion_time = fts(21)
    tt.timed_attacks.list[1].min_targets = b.cluster_bomb.min_targets
    tt.timed_attacks.list[1].min_range = b.cluster_bomb.min_range
    tt.timed_attacks.list[1].max_range = b.cluster_bomb.max_range
    tt.timed_attacks.list[1].node_prediction = tt.timed_attacks.list[1].shoot_time +
                                                   tt.timed_attacks.list[1].explosion_time + fts(25)
    tt.timed_attacks.list[1].sync_animation = true
    tt.timed_attacks.list[1].xp_from_skill = "cluster_bomb"
    tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_ENEMY)
    tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[1].bullet = "bullet_hero_bird_cluster_bomb"
    tt.timed_attacks.list[1].bullet_start_offset = {vec_2(15, tt.flight_height + 15), vec_2(-15, tt.flight_height + 15)}
    tt.timed_attacks.list[1].first_explosion_height = b.cluster_bomb.first_explosion_height
    tt.timed_attacks.list[1].ray = "fx_hero_bird_cluster_bomb_ray"
    tt.timed_attacks.list[1].ray_start_offset = {vec_2(20, tt.flight_height + 40), vec_2(-20, tt.flight_height + 40)}
    tt.timed_attacks.list[1].ray_width = 300
    tt.timed_attacks.list[2] = E:clone_c("mod_attack")
    tt.timed_attacks.list[2].disabled = true
    tt.timed_attacks.list[2].mods = {"mod_hero_bird_shout_stun", "mod_hero_bird_shout_slow"}
    tt.timed_attacks.list[2].decal = "decal_hero_bird_shout_stun"
    tt.timed_attacks.list[2].cooldown = nil
    tt.timed_attacks.list[2].sync_animation = true
    tt.timed_attacks.list[2].animation = "stun"
    tt.timed_attacks.list[2].shoot_time = fts(15)
    tt.timed_attacks.list[2].node_prediction = tt.timed_attacks.list[2].shoot_time
    tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD)
    tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[2].xp_from_skill = "shout_stun"
    tt.timed_attacks.list[2].radius = b.shout_stun.radius
    tt.timed_attacks.list[2].min_targets = b.shout_stun.min_targets
    tt.timed_attacks.list[2].sound = "HeroBirdTerrorShriekCast"
    tt.timed_attacks.list[3] = E:clone_c("bullet_attack")
    tt.timed_attacks.list[3].disabled = true
    tt.timed_attacks.list[3].cooldown = nil
    tt.timed_attacks.list[3].shoot_time = fts(18)
    tt.timed_attacks.list[3].shoot_every = b.gattling.shoot_every
    tt.timed_attacks.list[3].sync_animation = true
    tt.timed_attacks.list[3].decal = "decal_hero_bird_gattling"
    tt.timed_attacks.list[3].hit_fx = "fx_hero_bird_gattling"
    tt.timed_attacks.list[3].animation_in = "gattling_in"
    tt.timed_attacks.list[3].animation_loop = "gattling_loop"
    tt.timed_attacks.list[3].animation_out = "gattling_out"
    tt.timed_attacks.list[3].min_range = b.gattling.min_range
    tt.timed_attacks.list[3].max_range = b.gattling.max_range
    tt.timed_attacks.list[3].damage_min = nil
    tt.timed_attacks.list[3].damage_max = nil
    tt.timed_attacks.list[3].damage_type = b.gattling.damage_type
    tt.timed_attacks.list[3].duration = nil
    tt.timed_attacks.list[3].vis_flags = bor(F_RANGED)
    tt.timed_attacks.list[3].vis_bans = bor(F_NIGHTMARE)
    tt.timed_attacks.list[3].xp_from_skill = "gattling"
    tt.timed_attacks.list[3].sound = "HeroBirdBulletRainCast"
    tt.timed_attacks.list[3].sound_end = "HeroBirdBulletRainEnd"
    tt.timed_attacks.list[4] = E:clone_c("melee_attack")
    tt.timed_attacks.list[4].disabled = true
    tt.timed_attacks.list[4].cooldown = nil
    tt.timed_attacks.list[4].animation = "instakill"
    tt.timed_attacks.list[4].sync_animation = true
    tt.timed_attacks.list[4].shoot_time = fts(19)
    tt.timed_attacks.list[4].min_range = b.eat_instakill.min_range
    tt.timed_attacks.list[4].max_range = b.eat_instakill.max_range
    tt.timed_attacks.list[4].hp_max = nil
    tt.timed_attacks.list[4].vis_flags = bor(F_INSTAKILL)
    tt.timed_attacks.list[4].vis_bans = bor(F_FLYING, F_BOSS, F_MINIBOSS, F_NIGHTMARE, F_CLIFF)
    tt.timed_attacks.list[4].xp_from_skill = "eat_instakill"
    tt.timed_attacks.list[4].node_prediction = tt.timed_attacks.list[4].shoot_time
    tt.timed_attacks.list[4].eat_offset_x = 15
    tt.timed_attacks.list[4].sound = "HeroBirdHuntingDiveCast"
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].sprite_id = 2
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].keys = {{0, vec_1(0.97)}, {fts(8), vec_1(1.03)}, {fts(16), vec_1(0.97)}}
    tt.tween.props[2].name = "scale"
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].loop = true
    tt = E:register_t("hero_bird_ultimate")
    b = balance.heroes.hero_bird.ultimate

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_bird_ultimate.can_fire_fn
    tt.main_script.update = scripts.hero_bird_ultimate.update
    tt.child = "hero_bird_ultimate_child"
    tt.sound_cast = "HeroBirdBirdsOfPreyCast"
    tt = E:register_t("hero_bird_ultimate_child", "decal_scripted")
    b = balance.heroes.hero_bird.ultimate.bird

    E:add_comps(tt, "force_motion", "melee", "tween")

    tt.main_script.update = scripts.hero_bird_ultimate_child.update
    tt.flight_height = 80
    tt.force_motion.max_a = 1200
    tt.force_motion.max_v = 180
    tt.force_motion.ramp_radius = 30
    tt.force_motion.fr = 0.05
    tt.force_motion.a_step = 20
    tt.start_ts = nil
    tt.render.sprites[1].prefix = "gryph_child"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.render.sprites[1].offset.y = tt.flight_height
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "gryph_shadow"
    tt.render.sprites[2].offset = vec_1(0)
    tt.render.sprites[2].z = Z_DECALS + 1
    tt.render.sprites[2].scale = vec_1(0.75)
    tt.melee.attacks[1] = E:clone_c("bullet_attack")
    tt.melee.attacks[1].animation = "attack_in"
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].range = b.melee_attack.range
    tt.melee.attacks[1].damage_type = b.melee_attack.damage_type
    tt.melee.attacks[1].damage_min = nil
    tt.melee.attacks[1].damage_max = nil
    tt.melee.attacks[1].hit_time = fts(6)
    tt.melee.attacks[1].hit_fx = "fx_hero_bird_ultimate"
    tt.melee.attacks[1].search_cooldown = 0.1
    tt.melee.attacks[1].sound = "HeroBirdBirdsOfPreyGryphonAttack"
    tt.melee.attacks[1].sound_chance = 1
    tt.melee.attacks[1].vis_bans = bor(F_NIGHTMARE)
    tt.tween.disabled = false
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"

    local fh = tt.flight_height

    tt.tween.props[1].keys = {{0, vec_2(0, fh - 5)}, {fts(10), vec_2(0, fh + 5)}, {fts(20), vec_2(0, fh - 5)}}
    tt.tween.props[1].loop = true
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].keys = {{0, vec_1(0.78)}, {fts(10), vec_1(0.72)}, {fts(20), vec_1(0.78)}}
    tt.tween.props[2].name = "scale"
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].loop = true
    tt.target_range = b.target_range
    tt.chase_range = b.chase_range
    tt.sid_bird = 1
    tt.sid_shadow = 2
    tt = E:register_t("enemy_KR5", "enemy")
    tt.unit.head_offset = {}
    tt.unit.head_offset = vec_2(0, 0)
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_KR5"
    tt.render.sprites[1].angles_custom = {
        walk = {55, 115, 245, 305}
    }

    local b = balance.enemies.werebeasts.hog_invader

    tt = E:register_t("enemy_hog_invader", "enemy_KR5")

    E:add_comps(tt, "melee")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(28, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 32)
    tt.info.enc_icon = 1
    tt.info.portrait = "info_portraits_enemies_0004"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(8)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "hog_invader"
    tt.sound_events.death = "EnemyTuskedBrawlerDeath"
    tt.ui.click_rect = r(-17, 0, 34, 30)

    local b = balance.enemies.werebeasts.tusked_brawler

    tt = E:register_t("enemy_tusked_brawler", "enemy_KR5")

    E:add_comps(tt, "melee")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(28, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 34)
    tt.health.dead_lifetime = 1
    tt.info.enc_icon = 2
    tt.info.portrait = "info_portraits_enemies_0009"
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.head_offset = vec_2(0, 0)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(8)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "tusked_brawler"
    tt.sound_events.death = "EnemyTuskedBrawlerDeath"
    tt.ui.click_rect = r(-20, 0, 40, 35)

    local b = balance.enemies.werebeasts.turtle_shaman

    tt = E:register_t("turtle_shaman_bullet", "bolt_enemy")
    tt.render.sprites[1].prefix = "turtle_shaman_attack_1_projectile"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.bullet.damage_max = b.ranged_attack.damage_max
    tt.bullet.damage_min = b.ranged_attack.damage_min
    tt.bullet.hit_blood_fx = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.align_with_trajectory = true
    tt.bullet.hit_fx = "turtle_shaman_bullet_hit"
    tt.sound_events.insert = "EnemyTurtleShamanBasicAttack"
    tt.bullet.pop = {"pop_mage"}
    tt.bullet.pop_conds = DR_KILL
    tt = E:register_t("turtle_shaman_bullet_hit", "fx")
    tt.render.sprites[1].name = "turtle_shaman_attack_1_hit"
    tt = E:register_t("turtle_shaman_melee_hit", "fx")
    tt.render.sprites[1].name = "turtle_shaman_attack_2_hit"

    local b = balance.enemies.werebeasts.turtle_shaman

    tt = E:register_t("enemy_turtle_shaman", "enemy_KR5")

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.info.enc_icon = 5
    tt.info.portrait = "info_portraits_enemies_0008"
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.hit_offset = vec_2(0, 18)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.marker_offset = vec_2(-1, -1)
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(34, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 42)
    tt.health.dead_lifetime = 3
    tt.unit.fade_time_after_death = 2
    tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
    tt.main_script.update = scripts.enemy_turtle_shaman.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.attacks[1].animation = "attack_2"
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "turtle_shaman"
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.ranged.attacks[1].animation = "attack_1"
    tt.ranged.attacks[1].bullet = "turtle_shaman_bullet"
    tt.ranged.attacks[1].hold_advance = true
    tt.ranged.attacks[1].shoot_time = fts(9)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].max_range_variance = 60
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 46)}
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.sound_events.death = "EnemyTurtleShamanDeath"
    tt.timed_attacks.list[1] = E:clone_c("mod_attack")
    tt.timed_attacks.list[1].cast_time = fts(7)
    tt.timed_attacks.list[1].animation = "ability_1"
    tt.timed_attacks.list[1].cooldown = b.natures_vigor.cooldown
    tt.timed_attacks.list[1].max_count = 1
    tt.timed_attacks.list[1].hp_trigger_factor = b.natures_vigor.hp_trigger_factor
    tt.timed_attacks.list[1].mod = "mod_natures_vigor"
    tt.timed_attacks.list[1].markMod = "mod_natures_vigor_mark"
    tt.timed_attacks.list[1].cast_fx = "turtle_shaman_natures_vigor_cast_fx"
    tt.timed_attacks.list[1].markDurationOffset = 0.1
    tt.timed_attacks.list[1].range = b.natures_vigor.range
    tt.timed_attacks.list[1].sound = "EnemyTurtleShamanHealing"
    tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_CUSTOM)
    tt.timed_attacks.list[1].excluded_templates = {"enemy_turtle_shaman"}
    tt.unit.blood_color = BLOOD_GREEN
    tt.unit.can_explode = false
    tt = E:register_t("mod_natures_vigor_mark", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_CUSTOM
    tt.main_script.queue = scripts.mod_mark_flags.queue
    tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
    tt.main_script.update = scripts.mod_mark_flags.update

    local b = balance.enemies.werebeasts.turtle_shaman

    tt = E:register_t("mod_natures_vigor", "modifier")

    E:add_comps(tt, "hps", "render")

    tt.modifier.duration = b.natures_vigor.duration
    tt.modifier.resets_same = false
    tt.hps.heal_min = b.natures_vigor.heal_min
    tt.hps.heal_max = b.natures_vigor.heal_max
    tt.hps.heal_every = b.natures_vigor.heal_every
    tt.main_script.insert = scripts.mod_hps.insert
    tt.main_script.update = scripts.mod_hps.update
    tt.render.sprites[1].name = "turtle_shaman_HealFX_a_Idle_1"
    tt.render.sprites[1].loop = true
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "turtle_shaman_HealFX_b_Idle_1"
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].exclude_mod_offset = true
    tt = E:register_t("turtle_shaman_natures_vigor_cast_fx", "fx")
    tt.render.sprites[1].name = "turtle_shaman_HealFX_decal"
    tt.render.sprites[1].z = Z_DECALS

    local b = balance.enemies.werebeasts.bear_vanguard

    tt = E:register_t("enemy_bear_vanguard", "enemy_KR5")

    E:add_comps(tt, "melee")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0001"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(37, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 50)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_bear_vanguard.update
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_decal = "decal_ground_enemy_bear_vanguard"
    tt.melee.attacks[1].hit_fx = "fx_bear_ground_hit"
    tt.melee.attacks[1].hit_time = fts(13)
    tt.melee.attacks[1].hit_offset = vec_2(40, 0)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "bear_vanguard"
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.sound_events.death = "EnemyBearVanguardDeath"
    tt.ui.click_rect = r(-20, 0, 40, 40)
    tt.unit.hit_offset = vec_2(0, 22)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 19)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.can_explode = false
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.wrath_of_the_fallen = {}
    tt.wrath_of_the_fallen.ts = nil
    tt.wrath_of_the_fallen.ts_max = 1
    tt.wrath_of_the_fallen.animation = "wrath"
    tt.wrath_of_the_fallen.cast_time = fts(9)
    tt.wrath_of_the_fallen.radius = b.wrath_of_the_fallen.radius
    tt.wrath_of_the_fallen.mod = "mod_wrath_of_the_fallen"
    tt.wrath_of_the_fallen.sound = "EnemyBearVanguardRage"

    local b = balance.enemies.werebeasts.bear_vanguard

    tt = E:register_t("mod_wrath_of_the_fallen", "modifier")

    E:add_comps(tt, "render")

    tt.inflicted_damage_factor = b.wrath_of_the_fallen.inflicted_damage_factor
    tt.modifier.duration = b.wrath_of_the_fallen.duration
    tt.modifier.resets_same = true
    tt.modifier.use_mod_offset = false
    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.render.sprites[1].name = "bear_vanguard_mod_fx_wrath_of_the_fallen_decal_base"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "bear_vanguard_mod_fx_wrath_of_the_fallen_decal_top"
    tt.render.sprites[2].sort_y_offset = -1

    local b = balance.enemies.werebeasts.bear_woodcutter

    tt = E:register_t("enemy_bear_woodcutter", "enemy_KR5")

    E:add_comps(tt, "melee")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0011"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(37, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 46)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_bear_vanguard.update
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_decal = "decal_ground_enemy_bear_vanguard"
    tt.melee.attacks[1].hit_fx = "fx_bear_ground_hit"
    tt.melee.attacks[1].hit_time = fts(13)
    tt.melee.attacks[1].hit_offset = vec_2(40, 0)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "bear_woodcutter"
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.sound_events.death = "EnemyBearVanguardDeath"
    tt.ui.click_rect = r(-20, 0, 40, 40)
    tt.unit.hit_offset = vec_2(0, 22)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 19)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.wrath_of_the_fallen = {}
    tt.wrath_of_the_fallen.ts = nil
    tt.wrath_of_the_fallen.ts_max = 1
    tt.wrath_of_the_fallen.animation = "wrath"
    tt.wrath_of_the_fallen.cast_time = fts(9)
    tt.wrath_of_the_fallen.radius = b.wrath_of_the_fallen.radius
    tt.wrath_of_the_fallen.mod = "mod_wrath_of_the_fallen"

    local b = balance.enemies.werebeasts.cutthroat_rat

    tt = E:register_t("enemy_cutthroat_rat", "enemy_KR5")

    E:add_comps(tt, "melee", "timed_attacks")

    tt.info.enc_icon = 4
    tt.info.portrait = "info_portraits_enemies_0002"
    tt.unit.mod_offset = vec_2(0, 12)
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.ui.click_rect = r(-20, 0, 40, 35)
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(30, 0)
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, 28)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_cutthroat_rat.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].animation = "attack_1"
    tt.melee.attacks[1].hit_time = fts(9)
    tt.melee.attacks[1].hit_fx = "enemy_cutthroat_rat_attack_fx"
    tt.melee.attacks[1].hit_fx_offset = vec_2(25, 5)
    tt.melee.attacks[1].hit_fx_flip = true
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "cutthroat_rat"
    tt.sound_events.death = "EnemyCutthroatRatDeath"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].cast_time = fts(21)
    tt.timed_attacks.list[1].hide_time = fts(25)
    tt.timed_attacks.list[1].animation = "attack_2"
    tt.timed_attacks.list[1].cooldown = b.gut_stab.cooldown
    tt.timed_attacks.list[1].damage_max = b.gut_stab.damage_max
    tt.timed_attacks.list[1].damage_min = b.gut_stab.damage_min
    tt.timed_attacks.list[1].damage_type = b.gut_stab.damage_type
    tt.timed_attacks.list[1].mod = "mod_cutthroat_rat_bleed"
    tt.timed_attacks.list[1].duration = b.gut_stab.duration
    tt.timed_attacks.list[1].min_distance_from_end = b.gut_stab.min_distance_from_end
    tt.timed_attacks.list[1].smoke_fx = "enemy_cutthroat_rat_smoke_fx"
    tt.timed_attacks.list[1].hit_fx = "enemy_cutthroat_rat_stab_fx"
    tt.timed_attacks.list[1].ts = 0
    tt.timed_attacks.list[1].sound = "EnemyCutthroatRat"
    tt = E:register_t("enemy_cutthroat_rat_smoke_fx", "fx")
    tt.render.sprites[1].name = "cutthroat_rat_attack_2_smokeFX"
    tt = E:register_t("enemy_cutthroat_rat_attack_fx", "fx")
    tt.render.sprites[1].name = "cutthroat_rat_attack_1_hit"
    tt = E:register_t("enemy_cutthroat_rat_stab_fx", "fx")
    tt.render.sprites[1].name = "cutthroat_rat_attack_2_hit"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].hide_after_runs = 1
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt = E:register_t("mod_dreadeye_viper_arrow_acidic", "mod_poison")
    b = balance.enemies.werebeasts.dreadeye_viper
    tt.dps.damage_every = b.ranged_attack.poison.every
    tt.dps.damage_min = b.ranged_attack.poison.damage_min
    tt.dps.damage_max = b.ranged_attack.poison.damage_max
    tt.dps.kill = true
    tt.modifier.duration = b.ranged_attack.poison.duration
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("mod_dreadeye_viper_basic_attack", "mod_poison")
    b = balance.enemies.werebeasts.dreadeye_viper
    tt.dps.damage_every = b.basic_attack.poison.every
    tt.dps.damage_min = b.basic_attack.poison.damage_min
    tt.dps.damage_max = b.basic_attack.poison.damage_max
    tt.dps.kill = true
    tt.modifier.duration = b.basic_attack.poison.duration
    tt = E:register_t("enemy_dreadeye_viper", "enemy_KR5")

    E:add_comps(tt, "melee", "ranged")

    b = balance.enemies.werebeasts.dreadeye_viper
    tt.info.enc_icon = 7
    tt.info.portrait = "info_portraits_enemies_0003"
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 14)
    tt.ui.click_rect = r(-20, 0, 40, 35)
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(28, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 35)
    tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.attacks[1].animation = "attack_02"
    tt.melee.attacks[1].mod = "mod_dreadeye_viper_basic_attack"
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "dreadeye_viper_creep"
    tt.ranged.attacks[1].bullet = "arrow_dreadeye_viper"
    tt.ranged.attacks[1].hold_advance = false
    tt.ranged.attacks[1].shoot_time = fts(8)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].max_range_variance = 60
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(12, 31)}
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[1].animation = "attack_01"
    tt.sound_events.death = "EnemyDreadeyeViperDeath"
    tt.unit.blood_color = BLOOD_GREEN

    local b = balance.enemies.werebeasts.surveyor_harpy

    tt = E:register_t("enemy_surveyor_harpy", "enemy_KR5")
    tt.info.enc_icon = 6
    tt.info.portrait = "info_portraits_enemies_0005"
    tt.enemy.gold = b.gold
    tt.flight_height = 47
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, tt.flight_height + 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_surveyor_harpy.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].prefix = "patrolling_vulture"
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].scale = vec_1(0.8)
    tt.sound_events.death = "EnemyPatrollingVultureDeath"
    tt.ui.click_rect = r(-18, tt.flight_height - 2, 36, 27)
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 15)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 15)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.unit.show_blood_pool = false
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt = E:register_t("enemy_rhino", "enemy_KR5")

    local b = balance.enemies.werebeasts.rhino

    E:add_comps(tt, "melee", "timed_attacks")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(37, 0)
    tt.enemy.lives_cost = b.lives_cost
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 80)
    tt.info.enc_icon = 10
    tt.info.portrait = "info_portraits_enemies_0012"
    tt.unit.hit_offset = vec_2(0, 26)
    tt.unit.head_offset = vec_2(0, 0)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_rhino.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(16)
    tt.melee.attacks[1].sound = "EnemyRazingRhinoBasicAttack"
    tt.melee.attacks[2] = E:clone_c("melee_attack")
    tt.melee.attacks[2].animation = "attack"
    tt.melee.attacks[2].cooldown = b.instakill.cooldown
    tt.melee.attacks[2].damage_max = b.instakill.damage_max
    tt.melee.attacks[2].damage_min = b.instakill.damage_min
    tt.melee.attacks[2].damage_type = bor(b.instakill.damage_type)
    tt.melee.attacks[2].vis_bans = bor(F_HERO)
    tt.melee.attacks[2].vis_flags = F_INSTAKILL
    tt.melee.attacks[2].hit_time = fts(16)
    tt.melee.attacks[2].instakill = true
    tt.melee.attacks[2].disabled = true
    tt.melee.attacks[2].sound = "EnemyRazingRhinoBasicAttack"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].cast_time = fts(21)
    tt.timed_attacks.list[1].animation = "charge"
    tt.timed_attacks.list[1].cooldown = b.charge.cooldown
    tt.timed_attacks.list[1].duration = b.charge.duration
    tt.timed_attacks.list[1].min_distance_from_end = b.charge.min_distance_from_end
    tt.timed_attacks.list[1].speed = b.charge.speed
    tt.timed_attacks.list[1].trigger_range = b.charge.trigger_range
    tt.timed_attacks.list[1].vis_flags = F_FRIEND
    tt.timed_attacks.list[1].vis_bans = bor(F_HERO, F_FLYING)
    tt.timed_attacks.list[1].vis_flags_enemies = F_RANGED
    tt.timed_attacks.list[1].vis_bans_enemies = F_BOSS
    tt.timed_attacks.list[1].vis_flags_soldiers = F_RANGED
    tt.timed_attacks.list[1].vis_bans_soldiers = bor(F_BOSS, F_FLYING)
    tt.timed_attacks.list[1].mod_enemy = "mod_enemy_rhino_charge_enemy"
    tt.timed_attacks.list[1].mod_soldier = "mod_enemy_rhino_charge_soldier"
    tt.timed_attacks.list[1].range = b.charge.range
    tt.timed_attacks.list[1].min_range = b.charge.min_range
    tt.timed_attacks.list[1].particles_name_a = "ps_enemy_rhino_charge_a"
    tt.timed_attacks.list[1].particles_name_b = "ps_enemy_rhino_charge_b"
    tt.timed_attacks.list[1].sound = "EnemyRazingRhinoCharge"
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "razing_rhino_razing_rhino"
    tt.render.sprites[1].angles.charge = {"charge_side", "charge_back", "charge_front"}
    tt.render.sprites[1].angles_custom = {
        charge = {55, 115, 245, 305}
    }
    tt.ui.click_rect = r(-30, -3, 60, 65)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.can_explode = false
    tt.unit.can_explode = false
    tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
    tt.sound_events.death = "EnemyRazingRhinoDeath"
    tt.base_speed = b.speed

    local b = balance.enemies.werebeasts.skunk_bombardier

    tt = E:register_t("enemy_skunk_bombardier", "enemy_KR5")

    E:add_comps(tt, "melee", "ranged", "death_spawns")

    tt.info.enc_icon = 9
    tt.info.portrait = "info_portraits_enemies_0007"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(28, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(10)
    tt.motion.max_speed = b.speed
    tt.ranged.attacks[1].bullet = "enemy_skunk_bombardier_bomb"
    tt.ranged.attacks[1].hold_advance = false
    tt.ranged.attacks[1].shoot_time = fts(12)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 32)}
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
    tt.ranged.attacks[1].ignore_hit_offset = true
    tt.render.sprites[1].prefix = "skunk_bombardier"
    tt.sound_events.death = "EnemySkunkBombardierDeath"
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.ui.click_rect = r(-20, 0, 40, 35)
    tt.death_spawns.name = "aura_enemy_skunk_bombardier_death_explosion"
    tt.death_spawns.concurrent_with_death = false
    tt.death_spawns.delay = fts(19)
    tt = E:register_t("enemy_skunk_bombardier_hit_fx", "fx")
    tt.render.sprites[1].name = "skunk_bombardier_bomb_hit_fx"
    tt.render.sprites[1].anchor.y = 0.25
    tt = E:register_t("enemy_skunk_bombardier_bomb_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.name = "skunk_bombardier_bomb_trail"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(9), fts(9)}
    tt.particle_system.emission_rate = 30
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt = E:register_t("enemy_hyena5", "enemy_KR5")

    local b = balance.enemies.werebeasts.hyena5

    E:add_comps(tt, "melee")

    tt.feast = {}
    tt.feast.mods = {"enemy_hyena5_feast_mod"}
    tt.feast.animation = "eat"
    tt.feast.duration = b.feast.duration
    tt.feast.cooldown = b.feast.cooldown
    tt.feast.hp_min_trigger = b.feast.hp_min_trigger
    tt.enemy.gold = b.gold
    tt.health.armor = b.armor
    tt.health.hp_max = b.hp
    tt.health.magic_armor = b.magic_armor
    tt.info.enc_icon = 8
    tt.info.portrait = "info_portraits_enemies_0006"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_hyena5.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(15)
    tt.melee.attacks[1].hit_fx = "enemy_hyena5_attack_fx"
    tt.melee.attacks[1].hit_fx_offset = vec_2(25, 5)
    tt.melee.attacks[1].hit_fx_flip = true
    tt.motion.max_speed = b.speed
    tt.sound_events.feast = "EnemyRottenfangHyenaFeast"
    tt.sound_events.death = "EnemyRottenfangHyenaDeath"
    tt.sound_events.water_splash = "SpecialMermaid"
    tt.render.sprites[1].prefix = "rottenfang_hyena"
    tt.render.sprites[1].angles_stickiness.run = 10
    tt.health_bar.offset = vec_2(0, 35)
    tt.unit.hit_offset = vec_2(0, 16)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, -1)
    tt.unit.mod_offset = vec_2(0, 17)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.enemy.melee_slot = vec_2(33, 0)
    tt.ui.click_rect = r(-20, 0, 40, 35)
    tt = E:register_t("enemy_hyena5_feast_mod", "modifier")

    E:add_comps(tt, "hps", "render")

    tt.modifier.duration = b.feast.duration
    tt.modifier.resets_same = false
    tt.hps.heal_min = b.feast.heal
    tt.hps.heal_max = b.feast.heal
    tt.hps.heal_every = b.feast.heal_every
    tt.main_script.insert = scripts.mod_hps.insert
    tt.main_script.update = scripts.mod_hps.update
    tt.render.sprites[1].prefix = "mod_twilight_evoker_heal"
    tt.render.sprites[1].size_names = {"small", "big", "big"}
    tt.render.sprites[1].loop = true
    tt = E:register_t("enemy_hyena5_attack_fx", "fx")
    tt.render.sprites[1].name = "rottenfang_hyena_attack_hit_fx"
    tt = E:register_t("enemy_tusked_brawler_duro", "enemy_tusked_brawler")
    tt.health.hp_max = 1000

    local b = balance.enemies.cult_of_the_overseer.acolyte

    tt = E:register_t("enemy_acolyte", "enemy_KR5")

    E:add_comps(tt, "melee", "death_spawns")

    tt.enemy.gold = b.gold
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.info.enc_icon = 12
    tt.info.portrait = "info_portraits_enemies_0013"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_acolyte.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.attacks[1].hit_fx = "enemy_acolyte_attack_fx"
    tt.melee.attacks[1].hit_fx_offset = vec_2(15, 10)
    tt.motion.max_speed = b.speed
    tt.death_spawns.name = "enemy_acolyte_tentacle"
    tt.death_spawns.death_animation = "sacrifice"
    tt.death_spawns.concurrent_with_death = false
    tt.death_spawns.delay = fts(28)
    tt.death_spawns.dead_lifetime = 5
    tt.render.sprites[1].prefix = "acolyte"
    tt.health_bar.offset = vec_2(0, 30)
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 15)
    tt.unit.mod_offset = vec_2(0, 15)
    tt.unit.hide_after_death = true
    tt.ui.click_rect = r(-20, -3, 40, 35)
    tt.enemy.melee_slot = vec_2(18, 0)
    tt.sound_death_with_spawn = "EnemyAcolyteDeathSpecial"
    tt.sound_death_no_spawn = "EnemyAcolyteDeath"
    tt = E:register_t("enemy_acolyte_attack_fx", "fx")
    tt.render.sprites[1].name = "acolyte_attack_hit_fx"
    tt = E:register_t("enemy_acolyte_tentacle", "enemy_KR5")

    E:add_comps(tt, "melee", "timed_attacks")

    tt.enemy.gold = 0
    tt.motion.max_speed = 0
    tt.health.hp_max = b.tentacle.hp
    tt.health.armor = b.tentacle.armor
    tt.health.magic_armor = b.tentacle.magic_armor
    tt.info.fn = scripts.enemy_acolyte_tentacle.get_info
    tt.info.portrait = "info_portraits_enemies_0024"
    tt.info.enc_icon = 13
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_acolyte_tentacle.update
    tt.vis.bans = bor(F_SKELETON, F_TELEPORT)
    tt.melee.attacks[1].cooldown = b.tentacle.hit.cooldown
    tt.melee.attacks[1].damage_max = b.tentacle.hit.damage_max
    tt.melee.attacks[1].damage_min = b.tentacle.hit.damage_min
    tt.melee.attacks[1].hit_time = fts(16)
    tt.melee.attacks[1].sound = "EnemyAcolyteTentacleBasicAttack"
    tt.timed_attacks.list[1] = E:clone_c("mod_attack")
    tt.timed_attacks.list[1].disabled = true
    tt.timed_attacks.list[1].animation = "attack"
    tt.timed_attacks.list[1].cast_time = fts(13)
    tt.timed_attacks.list[1].hit_time = fts(19)
    tt.timed_attacks.list[1].cooldown = b.tentacle.hit.cooldown
    tt.timed_attacks.list[1].duration = b.tentacle.duration
    tt.timed_attacks.list[1].first_cooldown_max = b.tentacle.hit.first_cooldown_max
    tt.timed_attacks.list[1].first_cooldown_min = b.tentacle.hit.first_cooldown_min
    tt.timed_attacks.list[1].sound = "EnemyAcolyteTentacleBasicAttack"
    tt.timed_attacks.list[1].aura_name = "acolyte_tentacle_aura"
    tt.render.sprites[1].prefix = "acolyte_tentacle"
    tt.render.sprites[1].name = "raise"
    tt.render.sprites[1].sort_y_offset = 1
    tt.render.sprites[1].angles.walk = {"idle", "idle", "idle"}
    tt.health_bar.offset = vec_2(0, 34)
    tt.unit.hit_offset = vec_2(0, 8)
    tt.unit.head_offset = vec_2(0, 8)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 18)
    tt.unit.show_blood_pool = false
    tt.ui.click_rect = r(-18, -3, 36, 35)
    tt.enemy.melee_slot = vec_2(24, 0)
    tt.sound_events.death = "EnemyAcolyteTentacleDeath"
    tt = E:register_t("acolyte_tentacle_aura", "aura")
    tt.aura.cycles = 1
    tt.aura.damage_min = b.tentacle.hit.damage_min
    tt.aura.damage_max = b.tentacle.hit.damage_max
    tt.aura.damage_type = DAMAGE_PHYSICAL
    tt.aura.radius = b.tentacle.hit.radius
    tt.aura.vis_bans = bor(F_ENEMY)
    tt.main_script.update = scripts.aura_apply_damage.update
    tt = E:register_t("enemy_lesser_sister", "enemy_KR5")

    local b = balance.enemies.cult_of_the_overseer.lesser_sister

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(15, 0)
    tt.health.hp_max = b.hp
    tt.health.magic_armor = b.magic_armor
    tt.health.armor = b.armor
    tt.health.dead_lifetime = 3
    tt.health_bar.offset = vec_2(0, 38)
    tt.unit.hit_offset = vec_2(0, 21)
    tt.unit.head_offset = vec_2(0, 21)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.ui.click_rect = r(-20, -3, 40, 35)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "lesser_sister"
    tt.sound_events.death = "EnemyTwistedSisterDeath"
    tt.info.i18n_key = "ENEMY_LESSER_SISTER"
    tt.info.enc_icon = 14
    tt.info.portrait = "info_portraits_enemies_0014"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_lesser_sister.update
    tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(18)
    tt.ranged.attacks[1].bullet = "lesser_sister_bolt"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 13)}
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = 0
    tt.ranged.attacks[1].shoot_time = fts(18)
    tt.ranged.attacks[1].hold_advance = true
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "crooked_souls"
    tt.timed_attacks.list[1].cast_time = fts(36)
    tt.timed_attacks.list[1].cooldown = b.crooked_souls.cooldown
    tt.timed_attacks.list[1].range = b.crooked_souls.max_range
    tt.timed_attacks.list[1].max_targets = b.crooked_souls.max_targets
    tt.timed_attacks.list[1].entity = "enemy_lesser_sister_nightmare"
    tt.timed_attacks.list[1].spawn_delay = 0
    tt.timed_attacks.list[1].sound = "EnemyTwistedSisterSummonCast"
    tt.timed_attacks.list[1].count_group_name = "enemy_lesser_sister_nightmare"
    tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
    tt.timed_attacks.list[1].count_group_max = b.crooked_souls.max_total
    tt.nodes_limit = b.crooked_souls.nodes_limit
    tt.node_random_min = b.crooked_souls.nodes_random_min
    tt.node_random_max = b.crooked_souls.nodes_random_max
    tt = E:register_t("lesser_sister_bolt", "bolt_enemy")

    local b = balance.enemies.cult_of_the_overseer.lesser_sister

    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.render.sprites[1].prefix = "lesser_sister_bolt"
    tt.bullet.hit_fx = "lesser_sister_bolt_hit_fx"
    tt.bullet.pop = nil
    tt.bullet.pop_conds = nil
    tt.bullet.acceleration_factor = 0.5
    tt.bullet.damage_min = b.ranged_attack.damage_min
    tt.bullet.damage_max = b.ranged_attack.damage_max
    tt.bullet.max_speed = 360
    tt.bullet.xp_gain_factor = 2.1
    tt.bullet.particles_name = "lesser_sister_bolt_trail"
    tt.bullet.damage_type = b.ranged_attack.damage_type
    tt = E:register_t("lesser_sister_bolt_hit_fx", "fx")
    tt.render.sprites[1].name = "lesser_sister_bolt_hit_fx"
    tt = E:register_t("lesser_sister_bolt_trail")

    E:add_comps(tt, "pos", "particle_system")

    tt.particle_system.anchor = vec_2(0.5, 0.45)
    tt.particle_system.name = "lesser_sister_bolt_trail"
    tt.particle_system.animated = true
    tt.particle_system.loop = false
    tt.particle_system.particle_lifetime = {fts(8), fts(8)}
    tt.particle_system.emission_rate = 30
    tt.particle_system.z = Z_BULLET_PARTICLES
    tt.particle_system.scales_y = {0.8, 0.5}
    tt = E:register_t("enemy_lesser_sister_nightmare", "enemy_KR5")

    E:add_comps(tt, "melee", "count_group", "tween")

    tt.enemy.gold = 0
    tt.enemy.lives_cost = b.nightmare.lives_cost
    tt.count_group.name = "enemy_lesser_sister_nightmare"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_lesser_sister_nightmare.update
    tt.motion.max_speed = b.nightmare.speed
    tt.health.hp_max = b.nightmare.hp
    tt.health.armor = b.nightmare.armor
    tt.health.magic_armor = b.nightmare.magic_armor
    tt.health.dead_lifetime = fts(18)
    tt.info.enc_icon = 15
    tt.info.portrait = "info_portraits_enemies_0015"
    tt.vis.flags = 0
    tt.vis.flags_unblocked = bor(F_NIGHTMARE, F_ENEMY)
    tt.vis.flags_blocked = F_ENEMY
    tt.melee.attacks[1].cooldown = b.nightmare.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.nightmare.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.nightmare.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(8)
    tt.melee.attacks[1].hit_fx = "enemy_lesser_sister_nightmare_hit_fx"
    tt.melee.attacks[1].hit_fx_offset = vec_2(25, 5)
    tt.melee.range = 51.2
    tt.render.sprites[1].name = "raise"
    tt.render.sprites[1].prefix = "lesser_sister_nightmare"
    tt.ui.click_rect = r(-20, -3, 40, 35)
    tt.sound_events.insert = "EnemyTwistedSisterSummonSpawn"
    tt.sound_events.death = "EnemyNightmareDeath"
    tt.enemy.melee_slot = vec_2(23, 0)
    tt.health_bar.offset = vec_2(0, 35)
    tt.unit.hit_offset = vec_2(0, 18)
    tt.unit.head_offset = vec_2(0, 18)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.unit.blood_color = BLOOD_VIOLET
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(10), 100}}
    tt.tween.remove = false
    tt.can_be_converted = false
    tt.nodes_to_reveal = 40

    local tt = E:register_t("enemy_lesser_sister_nightmare_hit_fx", "fx")

    tt.render.sprites[1].name = "lesser_sister_nightmare_hit_fx"
    tt = E:register_t("enemy_small_stalker", "enemy_KR5")

    E:add_comps(tt, "tween")

    local b = balance.enemies.cult_of_the_overseer.small_stalker

    tt.info.enc_icon = 16
    tt.info.portrait = "info_portraits_enemies_0038"
    tt.enemy.gold = b.gold
    tt.flight_height = 47
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, tt.flight_height + 33)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health.on_damage = scripts.enemy_small_stalker.on_damage
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_small_stalker.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].prefix = "small_stalker_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].alpha = 0
    tt.ui.click_rect = r(-15, tt.flight_height - 5, 30, 40)
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 5)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 2)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.unit.show_blood_pool = false
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt.nodes_before_exit = b.dodge.nodes_before_exit
    tt.nodes_advance = b.dodge.nodes_advance
    tt.skill_teleport = {}
    tt.skill_teleport.active = false
    tt.skill_teleport.wait_between_teleport = b.dodge.wait_between_teleport
    tt.skill_teleport.cooldown = b.dodge.cooldown
    tt.skill_teleport.sound = "EnemyVoidBlinkerTeleport"
    tt.blink_min_cd = 2
    tt.blink_max_cd = 4
    tt.animation_idle = "walk"
    tt.sound_events.death = "EnemyVoidBlinkerDeath"
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {fts(3), 255}}
    tt.tween.props[1].sprite_id = 2
    tt.tween.remove = false
    tt.tween.disabled = true
    tt.tween.reverse = true
    tt = E:register_t("enemy_unblinded_priest", "enemy_KR5")

    local b = balance.enemies.cult_of_the_overseer.unblinded_priest

    E:add_comps(tt, "melee", "ranged", "death_spawns", "glare_kr5")

    tt.enemy.gold = b.gold
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.info.enc_icon = 17
    tt.info.portrait = "info_portraits_enemies_0017"
    tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
    tt.main_script.update = scripts.enemy_unblinded_priest.update
    tt.melee.attacks[1].animation = "attack_melee"
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_priest_hit_melee"
    tt.melee.attacks[1].hit_fx_offset = vec_2(18, 20)
    tt.ranged.attacks[1].animation = "attack_ranged"
    tt.ranged.attacks[1].bullet = "bullet_enemy_unblinded_priest"
    tt.ranged.attacks[1].hold_advance = false
    tt.ranged.attacks[1].shoot_time = fts(25)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].max_range_variance = 60
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 40)}
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.motion.max_speed = b.speed
    tt.health_trigger_factor = b.health_trigger_factor
    tt.death_spawns.name = "enemy_unblinded_abomination"
    tt.death_spawns.death_animation = "transformation_end"
    tt.death_spawns.concurrent_with_death = false
    tt.death_spawns.delay = fts(32)
    tt.death_spawns.dead_lifetime = 0
    tt.render.sprites[1].prefix = "unblinded_priest"
    tt.health_bar.offset = vec_2(0, 39)
    tt.unit.show_blood_pool = false
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 15)
    tt.unit.mod_offset = vec_2(0, 15)
    tt.enemy.melee_slot = vec_2(18, 0)
    tt.glare_kr5.transform_name = "enemy_unblinded_abomination"
    tt.glare_kr5.transform_animation = "transformation_full"
    tt.glare_kr5.on_start_glare = scripts.enemy_unblinded_priest.on_start_glare
    tt.transformation_time = b.transformation_time
    tt.transformation_sound = "EnemyUnblindedPriestTransformCast"
    tt.transformation_end_sound = "EnemyUnblindedPriestTransformSpawn"
    tt.sound_events.death = "EnemyUnblindedPriestDeath"
    tt.ui.click_rect = r(-20, -3, 40, 35)
    tt = E:register_t("enemy_unblinded_abomination", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.unblinded_priest.abomination

    E:add_comps(tt, "melee", "glare_kr5")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(25, 0)
    tt.enemy.lives_cost = b.lives_cost
    tt.health.hp_max = b.hp
    tt.health.magic_armor = b.magic_armor
    tt.health.armor = b.armor
    tt.health.dead_lifetime = 3
    tt.health_bar.offset = vec_2(0, 50)
    tt.unit.hit_offset = vec_2(0, 21)
    tt.unit.head_offset = vec_2(0, 21)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "unblinded_abomination_unblinded_abomination"
    tt.info.enc_icon = 18
    tt.info.portrait = "info_portraits_enemies_0018"
    tt.eat = {}
    tt.eat.hp_required = b.eat.hp_required
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(12)
    tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_abomination_hit_melee"
    tt.melee.attacks[1].hit_fx_offset = vec_2(40, 20)
    tt.melee.attacks[2] = E:clone_c("melee_attack")
    tt.melee.attacks[2].animation = "eat"
    tt.melee.attacks[2].cooldown = b.eat.cooldown
    tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
    tt.melee.attacks[2].hit_time = fts(20)
    tt.melee.attacks[2].mod = "mod_enemy_unblinded_abomination_eat"
    tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
    tt.melee.attacks[2].vis_bans = bor(F_HERO)
    tt.melee.attacks[2].sound = "EnemyAbominationInstakill"
    tt.melee.attacks[2].fn_can = function(t, s, a, target)
        return target.health and target.health.hp <= target.health.hp_max * t.eat.hp_required
    end
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.sound_events.death = "EnemyAbominationDeath"
    tt.ui.click_rect = r(-30, -3, 60, 50)
    tt = E:register_t("enemy_unblinded_abomination_stage_8", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.abomination_stage_8

    E:add_comps(tt, "melee", "regen")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(25, 0)
    tt.health.hp_max = b.hp
    tt.health.magic_armor = b.magic_armor
    tt.health.armor = b.armor
    tt.health.dead_lifetime = 3
    tt.health_bar.offset = vec_2(0, 50)
    tt.regen.cooldown = b.regen_cooldown
    tt.regen.health = b.regen_health
    tt.unit.hit_offset = vec_2(0, 21)
    tt.unit.head_offset = vec_2(0, 21)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "Abomination2Def"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].exo = true
    tt.info.enc_icon = 10
    tt.info.portrait = "info_portraits_enemies_0028"
    tt.info.i18n_key = "ENEMY_UNBLINDED_ABOMINATION_STAGE8"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_unblinded_abomination_stage_8.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(12)
    tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_abomination_hit_melee"
    tt.melee.attacks[1].hit_fx_offset = vec_2(40, 20)
    tt.idle_cooldown_min = 7
    tt.idle_cooldown_max = 12
    tt.sleep_cooldown = 20
    tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
    tt.sound_events.death = "EnemyAbominationDeath"
    tt = E:register_t("enemy_unblinded_abomination_stage_8_lifebar")

    E:add_comps(tt, "health_bar", "pos", "render", "health")

    tt.render.sprites[1].name = "square_ffffff"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].scale = vec_2(0, 0)
    tt = E:register_t("enemy_spiderling", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.spiderling

    E:add_comps(tt, "melee", "cliff")

    tt.enemy.gold = b.gold
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.info.enc_icon = 9
    tt.info.portrait = "info_portraits_enemies_0022"
    tt.info.i18n_key = "ENEMY_SPIDERLING"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_spiderling.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(9)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "spider"
    tt.ui.click_rect = r(-20, -3, 40, 30)
    tt.health_bar.offset = vec_2(0, 25)
    tt.unit.show_blood_pool = false
    tt.unit.hit_offset = vec_2(0, 10)
    tt.unit.head_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 3)
    tt.enemy.melee_slot = vec_2(18, 0)
    tt.transformation_time = b.transformation_time
    tt.cliff.fall_accel = 400
    tt.sound_events.death = "EnemySpiderlingDeath"
    tt = E:register_t("enemy_unblinded_shackler", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.unblinded_shackler

    E:add_comps(tt, "melee", "timed_attacks")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(33, 0)
    tt.health.hp_max = b.hp
    tt.health.magic_armor = b.magic_armor
    tt.health.armor = b.armor
    tt.health.dead_lifetime = 1
    tt.health_bar.offset = vec_2(0, 41)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.unit.hit_offset = vec_2(0, 21)
    tt.unit.head_offset = vec_2(0, 21)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.fade_time_after_death = 1
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "unblinded_shackler_creep"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.info.i18n_key = "ENEMY_UNBLINDED_SHACKLER"
    tt.info.enc_icon = 19
    tt.info.portrait = "info_portraits_enemies_0019"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_unblinded_shackler.update
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(14)
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation = "skill"
    tt.timed_attacks.list[1].cast_time = fts(16)
    tt.timed_attacks.list[1].cooldown = 1
    tt.timed_attacks.list[1].max_range = b.shackles.max_range
    tt.timed_attacks.list[1].min_range = 0
    tt.timed_attacks.list[1].min_targets = b.shackles.min_targets
    tt.timed_attacks.list[1].max_targets = b.shackles.max_targets
    tt.timed_attacks.list[1].mod = "mod_enemy_unblinded_shackler_shackles"
    tt.timed_attacks.list[1].mark_mod = "mod_enemy_unblinded_shackler_mark"
    tt.timed_attacks.list[1].health_trigger_factor = b.shackles.health_trigger_factor
    tt.timed_attacks.list[1].sound = "EnemyShacklerBlockTowerBlock"
    tt.timed_attacks.list[1].sound_out = "EnemyShacklerBlockTowerUnblock"
    tt.vis.bans_on_shackles = bor(F_STUN, F_TELEPORT)
    tt.sound_events.death = "EnemyShacklerDeath"
    tt = E:register_t("enemy_armored_nightmare", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.armored_nightmare

    E:add_comps(tt, "melee", "death_spawns")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(32, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.info.enc_icon = 22
    tt.info.portrait = "info_portraits_enemies_0023"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_armored_nightmare.update
    tt.melee.cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(12)
    tt.melee.attacks[1].hit_fx = "fx_enemy_armored_nightmare_hit"
    tt.melee.attacks[1].hit_fx_offset = vec_2(tt.enemy.melee_slot.x, 5)
    tt.melee.attacks[1].animation = "attk_1"
    tt.melee.attacks[1].shared_cooldown = true
    tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[2].animation = "attk_2"
    tt.melee.attacks[2].chance = 0.5
    tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[3].animation = "attk_3"
    tt.melee.attacks[3].chance = 0.5
    tt.motion.max_speed = b.speed
    tt.death_spawns.name = "enemy_lesser_sister_nightmare"
    tt.death_spawns.death_animation = "death"
    tt.death_spawns.concurrent_with_death = false
    tt.death_spawns.fx = "fx_enemy_armored_nightmare_death_spawn"
    tt.death_spawns.delay = fts(25)
    tt.death_spawns.dead_lifetime = 0
    tt.render.sprites[1].prefix = "armored_nightmare_enemy"
    tt.health_bar.offset = vec_2(0, 49)
    tt.unit.show_blood_pool = false
    tt.unit.hit_offset = vec_2(0, 15)
    tt.unit.head_offset = vec_2(0, 15)
    tt.unit.mod_offset = vec_2(0, 15)
    tt.unit.blood_color = BLOOD_NONE
    tt.sound_events.death = "EnemyBoundNightmareDeath"
    tt = E:register_t("enemy_corrupted_stalker", "enemy_KR5")

    local b = balance.enemies.cult_of_the_overseer.corrupted_stalker

    tt.info.enc_icon = 20
    tt.info.portrait = "info_portraits_enemies_0020"
    tt.enemy.gold = b.gold
    tt.enemy.lives_cost = b.lives_cost
    tt.flight_height = 47
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, tt.flight_height + 53)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_corrupted_stalker.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].prefix = "corrupted_stalker_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "corrupted_stalker_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.sound_events.death = "EnemyPatrollingVultureDeath"
    tt.ui.click_rect = r(-25, tt.flight_height - 15, 50, 50)
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 15)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 15)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.show_blood_pool = false
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt.sound_events.death = "EnemyCorruptedStalkerDeath"
    tt = E:register_t("enemy_crystal_golem", "enemy_KR5")

    local b = balance.enemies.cult_of_the_overseer.crystal_golem

    E:add_comps(tt, "melee")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0021"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(37, 0)
    tt.enemy.lives_cost = b.lives_cost
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 60)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_crystal_golem.update
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_decal = "fx_enemy_crystal_golem_ground_decal"
    tt.melee.attacks[1].hit_time = fts(13)
    tt.melee.attacks[1].hit_offset = vec_2(40, 0)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "crystal_golem_creep"
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.sound_events.death = "EnemyBearVanguardDeath"
    tt.ui.click_rect = r(-25, 0, 50, 50)
    tt.unit.hit_offset = vec_2(0, 22)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 19)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.can_explode = false
    tt.unit.blood_color = BLOOD_GRAY
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.start_as_rock = false
    tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
    tt.sound_events.death = "EnemyCrystalGolemDeath"
    tt.wake_up_sound = "Stage10ObeliskEffectGolemSpawnGolem"
    tt = E:register_t("enemy_stage_11_cult_leader_illusion", "enemy_KR5")

    local b = balance.specials.stage11_cult_leader.illusion

    E:add_comps(tt, "melee", "ranged", "timed_attacks")

    tt.ui.click_rect = r(-23, 0, 46, 60)
    tt.enemy.melee_slot = vec_2(15, 0)
    tt.health.hp_max = b.hp_max
    tt.health.magic_armor = b.magic_armor
    tt.health.armor = b.armor
    tt.health_bar.offset = vec_2(0, 70)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.unit.hit_offset = vec_2(0, 31)
    tt.unit.head_offset = vec_2(0, 21)
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.show_blood_pool = false
    tt.motion.max_speed = b.max_speed
    tt.sound_events.death = "Stage11MydriasIllusionDeath"
    tt.info.enc_icon = 14
    tt.info.portrait = "info_portraits_enemies_0026"
    tt.main_script.update = scripts.enemy_stage_11_cult_leader_illusion.update
    tt.melee.range = 72
    tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(12)
    tt.melee.attacks[1].hit_fx = "fx_stage_11_cult_leader_attack_hit"
    tt.melee.attacks[1].hit_fx_offset = vec_2(25, 35)
    tt.ranged.attacks[1].bullet = "bullet_stage_11_cult_leader_illusion"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 45)}
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].shoot_time = fts(18)
    tt.ranged.attacks[1].hold_advance = true
    tt.ranged.attacks[1].animation = "rangedattack"
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].animation_start = "skill"
    tt.timed_attacks.list[1].animation_loop = "skillloop"
    tt.timed_attacks.list[1].animation_end = "skillout"
    tt.timed_attacks.list[1].cast_time = fts(36)
    tt.timed_attacks.list[1].cooldown = b.chain.cooldown
    tt.timed_attacks.list[1].max_range = b.chain.max_range
    tt.timed_attacks.list[1].min_range = 0
    tt.timed_attacks.list[1].mod = "mod_enemy_stage_11_cult_leader_illusion_chain"
    tt.timed_attacks.list[2] = E:clone_c("custom_attack")
    tt.timed_attacks.list[2].aura = "aura_enemy_stage_11_cult_leader_illusion_shield"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
    tt.render.sprites[1].angles_stickiness = {
        walk = 10
    }
    tt.render.sprites[1].prefix = "mydrias_clone"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].angles.walk = {"walk", "walk", "walkdown"}
    tt.chain_every = fts(15)
    tt.nodes_limit = b.nodes_limit
    tt.chain_illusion_ttl = b.chain.duration
    tt.shield_illusion_ttl = b.shield.duration
    tt.fx_spawn = "fx_stage_11_cult_leader_spawn"
    tt.spawn_charge_time = b.spawn_charge_time
    tt.sound_spawn = "EnemyTwistedSisterSummonSpawn"
    tt.sound_shield = "Stage11MydriasIllusionShieldCast"
    tt.sound_tentacles_spawn = "Stage11MydriasIllusionTendrilsCast"
    tt.sound_tentacles_death = "Stage11MydriasIllusionTendrilsDeath"
    tt.vis.bans = bor(F_TELEPORT)
    tt = E:register_t("enemy_blinker", "enemy_KR5")

    E:add_comps(tt, "glare_kr5", "ranged")

    local b = balance.enemies.void_beyond.blinker

    tt.info.enc_icon = 16
    tt.info.portrait = "info_portraits_enemies_0016"
    tt.enemy.gold = b.gold
    tt.flight_height = 47
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, tt.flight_height + 33)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_blinker.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].prefix = "blinker_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[1].angles.blink = {"blink", "walk_back", "blink_front"}
    tt.render.sprites[1].angles_custom = {
        blink = {55, 115, 245, 305},
        walk = {55, 115, 245, 305}
    }
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].scale = vec_1(0.9)
    tt.ui.click_rect = r(-15, tt.flight_height - 5, 30, 30)
    tt.ranged.attacks[1].bullet = "bullet_enemy_blinker"
    tt.ranged.attacks[1].bullet_glare = "bullet_enemy_blinker_glare"
    tt.ranged.attacks[1].aura = "aura_enemy_blinker"
    tt.ranged.attacks[1].aura_glare = "aura_enemy_blinker_glare"
    tt.ranged.attacks[1].hold_advance = true
    tt.ranged.attacks[1].shoot_time = fts(0)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].duration = b.ranged_attack.duration
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, tt.flight_height + 5)}
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
    tt.ranged.attacks[1].animation = "stun"
    tt.ranged.attacks[1].fx_normal = "fx_enemy_blinker_attack"
    tt.ranged.attacks[1].fx_glare = "fx_enemy_blinker_attack_glare"
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 5)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 2)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.unit.show_blood_pool = false
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt.blink_min_cd = 2
    tt.blink_max_cd = 4
    tt.animation_idle = "walk"
    tt.animation_blink = "blink"
    tt.sound_events.death = "EnemyVoidBlinkerDeath"
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.on_start_glare = scripts.enemy_blinker.on_start_glare
    tt.glare_kr5.on_end_glare = scripts.enemy_blinker.on_end_glare
    tt = E:register_t("enemy_mindless_husk", "enemy_KR5")

    local b = balance.enemies.void_beyond.mindless_husk

    E:add_comps(tt, "melee", "glare_kr5")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0030"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(30, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.motion.max_speed = b.speed
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mindless_husk.update
    tt.render.sprites[1].prefix = "mindless_husk_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(10)
    tt.ui.click_rect = r(-15, 0, 30, 40)
    tt.unit.hit_offset = vec_2(-2, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.vis.flags = bor(F_ENEMY)
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glareling_spawn_controller = "controller_enemy_mindless_husk_glareling_spawn"
    tt.glareling_spawn_max_nodes_to_exit = b.spawn.max_nodes_to_exit
    tt.sound_death = "EnemyMindlessHuskDeath"
    tt.sound_death_and_spawn = "EnemyMindlessHuskSpawnDeath"
    tt.sound_events.death = tt.sound_death
    tt = E:register_t("controller_enemy_mindless_husk_glareling_spawn")

    local b = balance.enemies.void_beyond.mindless_husk.spawn

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_enemy_mindless_husk_glareling_spawn.update
    tt.glareling_bullet = "bullet_boss_corrupted_denas_spawn_entities"
    tt.glareling_spawn_delay = fts(16)
    tt.start_offset = vec_2(0, 25)
    tt.min_nodes_ahead = b.min_nodes_ahead
    tt.max_nodes_ahead = b.max_nodes_ahead
    tt.sound_spawn = "EnemyMindlessHuskSpawnDeath"
    tt = E:register_t("enemy_glareling", "enemy_KR5")
    b = balance.enemies.cult_of_the_overseer.glareling

    E:add_comps(tt, "melee", "glare_kr5")

    tt.enemy.gold = b.gold
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.info.enc_icon = 9
    tt.info.portrait = "info_portraits_enemies_0029"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_glareling.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(15)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "glearling_character"
    tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
    tt.render.sprites[1].scale = vec_2(0.81, 0.81)
    tt.ui.click_rect = r(-20, -3, 40, 30)
    tt.health_bar.offset = vec_2(0, 25)
    tt.unit.show_blood_pool = false
    tt.unit.hit_offset = vec_2(0, 10)
    tt.unit.head_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 3)
    tt.enemy.melee_slot = vec_2(18, 0)
    tt.transformation_time = b.transformation_time
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.speed_factor = b.glare.speed_factor
    tt.sound_events.death = "EnemyGlarelingDeath"
    tt.sound_events.sacrifice = "Stage14BehemothPoolSplash"
    tt = E:register_t("enemy_vile_spawner", "enemy_KR5")
    b = balance.enemies.void_beyond.vile_spawner

    E:add_comps(tt, "melee", "timed_attacks", "tween", "glare_kr5")

    tt.flight_height = 2
    tt.fly_strenght = 5
    tt.fly_frequency = 13
    tt.info.enc_icon = 5
    tt.info.portrait = "info_portraits_enemies_0031"
    tt.unit.mod_offset = vec_2(0, 16)
    tt.unit.hit_offset = vec_2(0, 18)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.marker_offset = vec_2(-1, -1)
    tt.ui.click_rect = r(-25, 0, 50, 60)
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(34, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 62)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health.dead_lifetime = 5
    tt.main_script.update = scripts.enemy_vile_spawner.update
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(15)
    tt.melee.attacks[1].animation = "attack_melee"
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "vile_spawner_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.render.sprites[1].offset = vec_2(0, 8)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "big_shadow"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].z = Z_DECALS
    tt.timed_attacks.list[1] = E:clone_c("custom_attack")
    tt.timed_attacks.list[1].cast_time = fts(20)
    tt.timed_attacks.list[1].animation = "projectile_spawn"
    tt.timed_attacks.list[1].normal_cooldown = b.lesser_spawn.cooldown
    tt.timed_attacks.list[1].cooldown = b.lesser_spawn.cooldown
    tt.timed_attacks.list[1].min_range = b.lesser_spawn.min_range
    tt.timed_attacks.list[1].max_range = b.lesser_spawn.max_range
    tt.timed_attacks.list[1].distance_between_entities = b.lesser_spawn.distance_between_entities
    tt.timed_attacks.list[1].entities_amount = b.lesser_spawn.entities_amount
    tt.timed_attacks.list[1].bullet_start_offset = vec_2(-5, 50)
    tt.timed_attacks.list[1].bullet = "bullet_vile_spawner_spawn"
    tt.timed_attacks.list[1].delay_between = fts(2)
    tt.timed_attacks.list[1].bullet_aim_height = 47
    tt.timed_attacks.list[1].min_distance_from_end = b.lesser_spawn.min_distance_from_end
    tt.timed_attacks.list[1].count_group_name = "enemy_lesser_eye"
    tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
    tt.timed_attacks.list[1].count_group_max = b.lesser_spawn.max_total
    tt.glare_kr5.on_start_glare = scripts.enemy_vile_spawner.on_start_glare
    tt.glare_kr5.on_end_glare = scripts.enemy_vile_spawner.on_end_glare
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.lesser_spawn_cooldown = b.glare.lesser_spawn_cooldown
    tt.unit.blood_color = BLOOD_VIOLET
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].interp = "sine"
    tt.tween.props[1].keys = {{fts(0), vec_2(0, tt.flight_height)},
                              {fts(tt.fly_frequency), vec_2(0, tt.flight_height - tt.fly_strenght)},
                              {fts(tt.fly_frequency * 2), vec_2(0, tt.flight_height)}}
    tt.tween.props[1].loop = true
    tt.tween.props[1].sprite_id = 1
    tt.sound_events.death = "EnemyVileSpawnerDeath"
    tt.sound_events.spawn_cast = "EnemyVileSpawnerSpawnCast"
    tt = E:register_t("enemy_lesser_eye", "enemy_KR5")
    b = balance.enemies.void_beyond.lesser_eye

    E:add_comps(tt, "count_group", "tween", "glare_kr5")

    tt.info.enc_icon = 16
    tt.info.portrait = "info_portraits_enemies_0032"
    tt.enemy.gold = b.gold
    tt.count_group.name = "enemy_lesser_eye"
    tt.flight_height = 47
    tt.fly_strenght = 5
    tt.fly_frequency = 13
    tt.health.hp_max = b.hp
    tt.health_bar.offset = vec_2(0, tt.flight_height + 33)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.main_script.update = scripts.enemy_lesser_eye.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[1].prefix = "lesser_eye_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].scale = vec_1(0.8)
    tt.ui.click_rect = r(-15, tt.flight_height - 20, 30, 38)
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 5)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 2)
    tt.unit.size = UNIT_SIZE_SMALL
    tt.unit.show_blood_pool = false
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].interp = "sine"
    tt.tween.props[1].keys = {{fts(0), vec_2(0, tt.flight_height)},
                              {fts(tt.fly_frequency), vec_2(0, tt.flight_height - tt.fly_strenght)},
                              {fts(tt.fly_frequency * 2), vec_2(0, tt.flight_height)}}
    tt.tween.props[1].loop = true
    tt.tween.props[1].sprite_id = 1
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.sound_events.death = "EnemyLesserEyeDeath"
    tt = E:register_t("enemy_noxious_horror", "enemy_KR5")

    local b = balance.enemies.void_beyond.noxious_horror

    E:add_comps(tt, "melee", "ranged", "glare_kr5")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0034"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(30, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.motion.max_speed = b.speed
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_noxious_horror.update
    tt.render.sprites[1].prefix = "noxious_horror_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(14)
    tt.melee.attacks[1].animation = "attack_melee"
    tt.melee.attacks[1].hit_fx = "fx_enemy_noxious_horror_melee_hit"
    tt.ranged.cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].bullet = "bullet_enemy_noxious_horror"
    tt.ranged.attacks[1].hold_advance = false
    tt.ranged.attacks[1].shoot_time = fts(16)
    tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
    tt.ranged.attacks[1].max_range_variance = 60
    tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(18, 31)}
    tt.ranged.attacks[1].ignore_hit_offset = true
    tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
    tt.ranged.attacks[1].animation = "attack_range"
    tt.ui.click_rect = r(-20, 0, 40, 35)
    tt.unit.hit_offset = vec_2(-2, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.vis.flags = bor(F_ENEMY)
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.on_start_glare = scripts.enemy_noxious_horror.on_start_glare
    tt.glare_kr5.on_end_glare = scripts.enemy_noxious_horror.on_end_glare
    tt.glare_kr5.magic_armor = b.glare.magic_armor
    tt.glare_kr5.aura_poison = "aura_enemy_noxious_horror_glare"
    tt.sound_events.death = "EnemyNoxiousHorrorDeath"
    tt = E:register_t("enemy_hardened_horror", "enemy_KR5")

    local b = balance.enemies.void_beyond.hardened_horror

    E:add_comps(tt, "melee", "glare_kr5")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0033"
    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(35, 0)
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 50)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.motion.max_speed = b.speed
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_hardened_horror.update
    tt.render.sprites[1].prefix = "hardened_horror_creep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[1].scale = vec_1(1.1)
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_times = {fts(14), fts(20)}
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].hit_fx = "fx_enemy_hardened_horror_hit"
    tt.melee.attacks[1].hit_offset = vec_2(40, 13)
    tt.ui.click_rect = r(-25, -3, 50, 43)
    tt.unit.hit_offset = vec_2(-2, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.vis.flags = bor(F_ENEMY)
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.on_start_glare = scripts.enemy_hardened_horror.on_start_glare
    tt.glare_kr5.on_end_glare = scripts.enemy_hardened_horror.on_end_glare
    tt.glare_kr5.armor = b.glare.armor
    tt.glare_kr5.roll_speed = b.glare.roll_speed
    tt.glare_kr5.roll_angles = {"roll_loop", "roll_up", "roll_down"}
    tt.sound_events.death = "EnemyHardenedHorrorDeath"
    tt.base_speed = b.speed
    tt = E:register_t("enemy_evolving_scourge", "enemy_KR5")

    local b = balance.enemies.void_beyond.evolving_scourge

    E:add_comps(tt, "melee", "tween", "glare_kr5")

    tt.info.enc_icon = 3
    tt.info.portrait = "info_portraits_enemies_0035"
    tt.enemy.gold = b.gold[1]
    tt.enemy.melee_slot = vec_2(25, 0)
    tt.enemy.lives_cost = b.lives_cost
    tt.gold_config = b.gold
    tt.health.hp_max = b.hp[1]
    tt.hp_config = b.hp
    tt.flight_height = 40
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 35)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.health_bar_offset_config = {vec_2(0, 35), vec_2(0, 40), vec_2(0, 50 + tt.flight_height)}
    tt.health_bar_type_config = {HEALTH_BAR_SIZE_MEDIUM, HEALTH_BAR_SIZE_MEDIUM_MEDIUM, HEALTH_BAR_SIZE_LARGE}
    tt.motion.max_speed = b.speed[1]
    tt.speed_config = b.speed
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_evolving_scourge.update
    tt.render.sprites[1].prefix = "evolving_scourge_fase1"
    tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].hidden = true
    tt.eat = {}
    tt.eat.hp_required = b.eat.hp_required
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown[1]
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[1]
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[1]
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(11)
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[2] = E:clone_c("melee_attack")
    tt.melee.attacks[2].animation = "attack_2"
    tt.melee.attacks[2].cooldown = b.eat.cooldown
    tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
    tt.melee.attacks[2].hit_time = fts(21)
    tt.melee.attacks[2].mod = "mod_enemy_evolving_scourge_eat"
    tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
    tt.melee.attacks[2].vis_bans = bor(F_HERO)
    tt.melee.attacks[2].sound = "EnemyAbominationInstakill"
    tt.melee.attacks[2].fn_can = function(t, s, a, target)
        return target.health and target.health.hp <= target.health.hp_max * t.eat.hp_required
    end
    tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
    tt.melee.attacks[3].cooldown = b.basic_attack.cooldown[2]
    tt.melee.attacks[3].damage_max = b.basic_attack.damage_max[2]
    tt.melee.attacks[3].damage_min = b.basic_attack.damage_min[2]
    tt.melee.attacks[3].hit_time = fts(13)
    tt.melee.attacks[3].disabled = true
    tt.melee.attacks[4] = table.deepclone(tt.melee.attacks[2])
    tt.melee.attacks[4].animation = "attack_2"
    tt.melee.attacks[4].disabled = true
    tt.ui.click_rect = r(-23, -3, 46, 33)
    tt.click_rect_config = {r(-23, -3, 46, 33), r(-23, -3, 46, 38), r(-23, -3 + tt.flight_height, 46, 38)}
    tt.unit_y_offset_config = {0, 5, 7 + tt.flight_height}
    tt.unit.hit_offset = vec_2(-5, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.vis.flags = bor(F_ENEMY)
    tt.tween.disabled = true
    tt.tween.remove = false
    tt.tween.props[1].name = "offset"
    tt.tween.props[1].interp = "sine"
    tt.tween.props[1].keys = {{0, vec_2(0, 0)}, {1, vec_2(0, tt.flight_height)}}
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "scale"
    tt.tween.props[2].interp = "sine"
    tt.tween.props[2].sprite_id = 2
    tt.tween.props[2].keys = {{0, vec_1(2)}, {1, vec_1(1.3)}}
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.glare_kr5.on_start_glare = scripts.enemy_evolving_scourge.on_start_glare
    tt.glare_kr5.armor = b.glare.armor
    tt.sound_events.evolve = "EnemyEvolvingScourgeEvolve"
    tt.sound_events.death = "EnemyEvolvingScourgeDeath"
    tt = E:register_t("enemy_amalgam", "enemy_KR5")
    b = balance.enemies.void_beyond.amalgam

    E:add_comps(tt, "melee", "glare_kr5", "death_spawns")

    tt.enemy.gold = b.gold
    tt.enemy.melee_slot = vec_2(37, 0)
    tt.enemy.lives_cost = b.lives_cost
    tt.health.hp_max = b.hp
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 60)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
    tt.info.enc_icon = 9
    tt.info.portrait = "info_portraits_enemies_0039"
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_mixed.update
    tt.melee.attacks[1] = E:clone_c("area_attack")
    tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
    tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
    tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
    tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
    tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
    tt.melee.attacks[1].hit_time = fts(18)
    tt.melee.attacks[1].animation = "attack"
    tt.melee.attacks[1].hit_decal = "decal_enemy_amalgam_hit"
    tt.melee.attacks[1].hit_offset = vec_2(40, 0)
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "Amalgam_dude"
    tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
    tt.render.sprites[1].draw_order = DO_ENEMY_BIG
    tt.ui.click_rect = r(-32, -3, 64, 60)
    tt.unit.hit_offset = vec_2(0, 22)
    tt.unit.head_offset = vec_2(0, 10)
    tt.unit.marker_offset = vec_2(-1, 0)
    tt.unit.mod_offset = vec_2(0, 19)
    tt.unit.size = UNIT_SIZE_MEDIUM
    tt.unit.can_explode = false
    tt.unit.hide_after_death = true
    tt.unit.show_blood_pool = false
    tt.transformation_time = b.transformation_time
    tt.glare_kr5.regen_hp = b.glare.regen_hp
    tt.death_spawns.name = "aura_enemy_amalgam_death_explosion"
    tt.death_spawns.fx = "decal_enemy_amalgam_death_explosion"
    tt.death_spawns.concurrent_with_death = false
    tt.death_spawns.delay = fts(19)
    tt.sound_events.death = "EnemyAmalgamDeath"
    tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
    tt = E:register_t("enemy_overseer_hit_point", "enemy_KR5")
    tt.enemy.gold = 0
    tt.enemy.melee_slot = vec_2(0, 0)
    tt.enemy.lives_cost = 9999
    tt.health.hp_max = 1e+99
    tt.health.armor = 0
    tt.health.magic_armor = 0
    tt.unit.blood_color = BLOOD_VIOLET
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_overseer_hit_point.update
    tt.health.on_damage = scripts.enemy_overseer_hit_point.on_damage
    tt.motion.max_speed = 0
    tt.render = nil
    tt.ui.click_rect = r(-30, -3, 60, 65)
    tt.ui.can_click = false
    tt.ui.can_select = false
    tt.vis.flags = bor(F_ENEMY, F_FLYING, F_BOSS)
    tt.vis.bans = bor(F_MOD, F_BLOCK)
    tt.move_bounds = vec_2(25, 25)
    tt.move_speed = vec_2(0.2, 0.2)
    tt = E:register_t("enemy_tower_ray_sheep", "enemy_KR5")

    local b = balance.towers.ray.skill_sheep.sheep

    tt.enemy.gold = b.gold
    tt.health.armor = b.armor
    tt.health.magic_armor = b.magic_armor
    tt.health_bar.offset = vec_2(0, 32)
    tt.info.enc_icon = 1
    tt.info.portrait = "info_portraits_enemies_0042"
    tt.unit.hide_after_death = true
    tt.unit.hit_offset = vec_2(0, 14)
    tt.unit.head_offset = vec_2(0, 5)
    tt.unit.mod_offset = vec_2(0, 10)
    tt.main_script.insert = scripts.enemy_basic.insert
    tt.main_script.update = scripts.enemy_tower_ray_sheep.update
    tt.motion.max_speed = b.speed
    tt.render.sprites[1].prefix = "channeler_tower_sheep"
    tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
    tt.sound_events.death = "EnemySheepDeath"
    tt.ui.click_rect = r(-17, 0, 34, 20)
    tt.vis.bans = bor(F_BLOCK, F_SKELETON)
    tt.clicks_to_destroy = b.clicks_to_destroy
    tt = E:register_t("enemy_tower_ray_sheep_flying", "enemy_tower_ray_sheep")

    local b = balance.towers.ray.skill_sheep.sheep

    tt.info.portrait = "info_portraits_enemies_0041"
    tt.flight_height = 47
    tt.health_bar.offset = vec_2(0, tt.flight_height + 40)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.render.sprites[1].prefix = "channeler_tower_sheep_flying"
    tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
    tt.render.sprites[1].offset = vec_2(0, tt.flight_height)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "decal_flying_shadow_hard"
    tt.render.sprites[2].offset = vec_2(0, 0)
    tt.render.sprites[2].scale = vec_1(0.8)
    tt.unit.hide_after_death = true
    tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
    tt.unit.hit_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.mod_offset = vec_2(0, tt.flight_height + 10)
    tt.unit.show_blood_pool = false
    tt.sound_events.death = "EnemySheepDeath"
    tt.ui.click_rect = r(-18, tt.flight_height - 2, 36, 23)
    tt.vis.flags = bor(F_ENEMY, F_FLYING)
    tt = E:register_t("bombKR5", "bomb")
    tt.bullet.damage_decay_random = false
    tt.bullet.damage_type = DAMAGE_EXPLOSION
    tt.bullet.hit_decal = "decal_bomb_crater_KR5"
    tt.main_script.insert = scripts.bomb_KR5.insert
    tt.main_script.update = scripts.bomb_KR5.update
    tt = E:register_t("explosion_big_KR5", "fx")
    tt.render.sprites[1].prefix = "explosion_KR5"
    tt.render.sprites[1].name = "big"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].draw_order = 100
    tt.render.sprites[1].anchor = vec_2(0.5, 0.1)
    tt = E:register_t("explosion_small_KR5", "explosion_big_KR5")
    tt.render.sprites[1].scale = vec_2(0.9, 0.9)
    tt = E:register_t("decal_bomb_crater_KR5", "decal_tween")
    tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
    tt.render.sprites[1].name = "decal_bomb_crater"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].scale = vec_2(1.2, 1.2)
    tt = E:register_t("tower_tricannon_bomb", "bombKR5")

    local b = balance.towers.tricannon

    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.damage_radius = b.basic_attack.damage_radius
    tt.bullet.flight_time = fts(31)
    tt.bullet.hit_fx = "explosion_small_KR5"
    tt.bullet.pop_chance = 0.2
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
    tt.render.sprites[1].animated = false
    tt = E:register_t("tower_tricannon_bomb_1", "tower_tricannon_bomb")
    tt.bullet.damage_max = b.basic_attack.damage_max[1]
    tt.bullet.damage_min = b.basic_attack.damage_min[1]
    tt.render.sprites[1].name = "tricannon_tower_lvl1_bomb"
    tt = E:register_t("tower_tricannon_bomb_2", "tower_tricannon_bomb")
    tt.bullet.damage_max = b.basic_attack.damage_max[2]
    tt.bullet.damage_min = b.basic_attack.damage_min[2]
    tt.bullet.align_with_trajectory = true
    tt.bullet.particles_name = "ps_tower_tricannon_bomb_trail"
    tt.render.sprites[1].name = "tricannon_tower_lvl2_bomb"
    tt = E:register_t("tower_tricannon_bomb_3", "tower_tricannon_bomb")
    tt.bullet.damage_max = b.basic_attack.damage_max[3]
    tt.bullet.damage_min = b.basic_attack.damage_min[3]
    tt.bullet.align_with_trajectory = true
    tt.bullet.particles_name = "ps_tower_tricannon_bomb_trail"
    tt.render.sprites[1].name = "tricannon_tower_lvl3_bomb"
    tt = E:register_t("tower_tricannon_bomb_4", "tower_tricannon_bomb")
    tt.bullet.damage_max = b.basic_attack.damage_max[4]
    tt.bullet.damage_min = b.basic_attack.damage_min[4]
    tt.bullet.hit_fx = "explosion_big_KR5"
    tt.bullet.align_with_trajectory = true
    tt.bullet.particles_name = "tower_tricannon_bomb_4_trail"
    tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb"
    tt = E:register_t("tower_tricannon_bomb_overheated", "tower_tricannon_bomb_4")
    tt.bullet.hit_payload = "tower_tricannon_overheat_scorch_aura"
    tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb_overheat"
    tt.bullet.particles_name = "tower_tricannon_bomb_4_overheated_trail"
    tt.bullet.flight_time = fts(28)
    tt.bullet.g = -1.5 / (fts(1) * fts(1))
    tt = E:register_t("tower_tricannon_bomb_bombardment_bomb", "bombKR5")
    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.damage_max_config = b.bombardment.damage_max
    tt.bullet.damage_min_config = b.bombardment.damage_min
    tt.bullet.damage_radius = b.bombardment.damage_radius
    tt.bullet.flight_time = fts(26)
    tt.bullet.g = -1.4 / (fts(1) * fts(1))
    tt.bullet.hit_fx = "explosion_big_KR5"
    tt.bullet.pop = nil
    tt.bullet.align_with_trajectory = true
    tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb"
    tt.render.sprites[1].animated = false
    tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
    tt.bullet.particles_name = "tower_tricannon_bomb_4_bombardment_trail"

    tt = E:register_t("tower_tricannon_bombardment_overheated_bomb", "tower_tricannon_bomb_bombardment_bomb")
    tt.bullet.hit_payload = "tower_tricannon_overheat_scorch_aura"
    tt.render.sprites[1].name = "tricannon_tower_lvl4_bomb_overheat"
    tt = E:register_t("tower_viper_goblins_pow_snake_bomb_bomb", "bombKR5")
    tt.bullet.damage_bans = F_ALL
    tt.bullet.damage_flags = 0
    tt.bullet.damage_max = 0
    tt.bullet.damage_min = 0
    tt.bullet.damage_radius = 1
    tt.bullet.flight_time_base = fts(34)
    tt.bullet.flight_time_factor = fts(0.016666666666666666)
    tt.bullet.pop = nil
    tt.bullet.hit_payload = "tower_viper_goblins_pow_snake_bomb_aura"
    tt.main_script.insert = scripts.bomb.insert
    tt.main_script.update = scripts.bomb.update
    tt.bullet.hit_fx = nil
    tt.bullet.hit_decal = nil
    tt.bullet.hide_radius = nil
    tt.render.sprites[1].name = "tower_big_bertha_tar_bomb"
    tt.render.sprites[1].animated = false
    tt.sound_events.insert = "HeroRiflemanBrea"
    tt.sound_events.hit = nil
    tt.sound_events.hit_water = nil
    tt = E:register_t("enemy_skunk_bombardier_bomb", "bombKR5")
    b = balance.enemies.werebeasts.skunk_bombardier
    tt.bullet.damage_type = DAMAGE_PHYSICAL
    tt.bullet.damage_max = b.ranged_attack.damage_max
    tt.bullet.damage_min = b.ranged_attack.damage_min
    tt.bullet.damage_radius = b.ranged_attack.radius
    tt.bullet.mod = "mod_enemy_skunk_bombardier_basic_attack"
    tt.bullet.ignore_hit_offset = true
    tt.bullet.flight_time = fts(20)
    tt.bullet.hit_fx = "enemy_skunk_bombardier_hit_fx"
    tt.bullet.damage_bans = bor(F_ENEMY)
    tt.bullet.particles_name = "enemy_skunk_bombardier_bomb_trail"
    tt.main_script.insert = scripts.enemy_bomb.insert
    tt.main_script.update = scripts.enemy_bomb.update
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "EnemySkunkBombardierBasicAttackImpact"
    tt.sound_events.insert = "EnemySkunkBombardierBasicAttackCast"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "skunk_bombardier_bomb_"
    tt = E:register_t("arrow5", "bullet")
    tt.bullet.hit_distance = 22
    tt.bullet.hit_blood_fx = "fx_blood_splat"
    tt.bullet.miss_decal = "decal_arrow"
    tt.bullet.miss_fx_water = "fx_splash_small"
    tt.bullet.flight_time = fts(22)
    tt.bullet.damage_type = DAMAGE_PHYSICAL
    tt.bullet.pop = {"pop_shunt", "pop_oof"}
    tt.bullet.pop_chance = 1
    tt.bullet.pop_conds = DR_KILL
    tt.render.sprites[1].name = "arrow"
    tt.render.sprites[1].animated = false
    tt.main_script.insert = scripts.arrow.insert
    tt.main_script.update = scripts.arrow.update
    tt.sound_events.insert = "ArrowSound"
    tt.bullet.prediction_error = true
    tt.bullet.predict_target_pos = true
    tt.bullet.hide_radius = 6
    tt = E:register_t("arrow5_fixed_height", "arrow5")
    tt.main_script.insert = scripts.arrow5_fixed_height.insert
    tt = E:register_t("arrow5_45degrees", "arrow5")
    tt.main_script.insert = scripts.arrow5_45degrees.insert
    tt = E:register_t("arrow_dreadeye_viper", "arrow5_fixed_height")
    b = balance.enemies.werebeasts.dreadeye_viper
    tt.bullet.damage_min = b.basic_attack.damage_min
    tt.bullet.damage_max = b.basic_attack.damage_max
    tt.bullet.fixed_height = 40
    tt.bullet.g = -1000
    tt.bullet.mod = "mod_dreadeye_viper_arrow_acidic"
    tt.bullet.hit_blood_fx = nil
    tt.bullet.pop = nil
    tt.bullet.hide_radius = 6
    tt.bullet.prediction_error = false
    tt.bullet.predict_target_pos = false
    tt.bullet.hit_fx = "fx_dreadeye_viper_hit"
    tt.bullet.miss_decal = "dreadeye_viper_arrow2"
    tt.bullet.particles_name = "ps_bullet_dreadeye_viper"
    tt.render.sprites[1].name = "dreadeye_viper_arrow"
    tt.bullet.hit_distance = 20
    tt.bullet.extend_particles_cutoff = true
    tt = E:register_t("arrow_armor_piercer_royal_archers", "arrow5_fixed_height")
    b = balance.towers.royal_archers
    tt.bullet.pop = {"pop_archer"}
    tt.bullet.damage_type = b.armor_piercer.damage_type
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.damage_min_config = b.armor_piercer.damage_min
    tt.bullet.damage_max_config = b.armor_piercer.damage_max
    tt.bullet.reduce_armor = b.armor_piercer.armor_penetration
    tt.bullet.hit_fx = "tower_royal_archers_pow_armor_piercer_arrow_hit_fx"
    tt.bullet.particles_name = "royal_archer_tower_lvl4_arrow_armor_breaker_trail_particle"
    tt.bullet.miss_decal = "royal_archer_tower_lvl4_arrow_armor_piercer_0002"
    tt.bullet.fixed_height = 20
    tt.bullet.flight_time_variance = 10
    tt.bullet.g = -1.8 / (fts(1) * fts(1))
    tt.render.sprites[1].name = "royal_archer_tower_lvl4_arrow_armor_piercer_0001"
    tt.render.sprites[1].animated = false
    tt.sound_events.insert = nil
    tt.sound_events.hit = "TowerRoyalArchersArmorPiercerHit"
    tt = E:register_t("tower_royal_archers_arrow_lvl1", "arrow5_fixed_height")
    b = balance.towers.royal_archers
    tt.bullet.damage_min = b.basic_attack.damage_min[1]
    tt.bullet.damage_max = b.basic_attack.damage_max[1]
    tt.bullet.damage_type = b.basic_attack.damage_type
    tt.bullet.fixed_height = 40
    tt.bullet.g = -1000
    tt.bullet.pop = {"pop_archer"}
    tt.render.sprites[1].name = "royal_archer_tower_lvl1_arrow_0001"
    tt.render.sprites[1].scale = vec_1(0.9)
    tt.bullet.miss_decal = "royal_archer_tower_lvl1_arrow_0002"
    tt = E:register_t("tower_royal_archers_arrow_lvl2", "tower_royal_archers_arrow_lvl1")
    b = balance.towers.royal_archers
    tt.bullet.damage_min = b.basic_attack.damage_min[2]
    tt.bullet.damage_max = b.basic_attack.damage_max[2]
    tt = E:register_t("tower_royal_archers_arrow_lvl3", "tower_royal_archers_arrow_lvl1")
    b = balance.towers.royal_archers
    tt.bullet.damage_min = b.basic_attack.damage_min[3]
    tt.bullet.damage_max = b.basic_attack.damage_max[3]
    tt = E:register_t("tower_royal_archers_arrow_lvl4", "tower_royal_archers_arrow_lvl1")
    b = balance.towers.royal_archers
    tt.bullet.damage_min = b.basic_attack.damage_min[4]
    tt.bullet.damage_max = b.basic_attack.damage_max[4]
    tt.render.sprites[1].name = "royal_archer_tower_lvl4_arrow_0001"
    tt.bullet.miss_decal = "royal_archer_tower_lvl4_arrow_0002"
    tt = E:register_t("bolt_lumenir", "bullet")

    E:add_comps(tt, "force_motion")

    b = balance.heroes.hero_lumenir.basic_ranged_shot
    tt.bullet.damage_type = b.damage_type
    tt.bullet.hit_fx = "fx_bolt_lumenir_hit"
    tt.bullet.particles_name = "ps_bolt_lumenir"
    tt.bullet.max_speed = 600
    tt.bullet.align_with_trajectory = true
    tt.bullet.min_speed = 30
    tt.bullet.xp_gain_factor = b.xp_gain_factor
    tt.bullet.use_unit_damage_factor = true
    tt.bullet.pop_chance = 0
    tt.initial_impulse = 30000
    tt.initial_impulse_duration = 10
    tt.initial_impulse_angle = math.pi / 4
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 3000
    tt.force_motion.max_v = 600
    tt.main_script.insert = scripts.bolt_lumenir.insert
    tt.main_script.update = scripts.bolt_lumenir.update
    tt.render.sprites[1].name = "hero_lumenir_attack_projectile_idle"
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt = E:register_t("bolt_lumenir_mini", "bolt_lumenir")
    tt.bullet.damage_type = DAMAGE_TRUE
    tt.force_motion.max_v = 300
    tt.bullet.hit_fx = "fx_bolt_lumenir_hit_mini"
    tt.bullet.particles_name = "ps_bolt_lumenir_mini"
    tt.render.sprites[1].name = "hero_lumenir_light_companion_attack_projectile_idle"
    tt.sound_events.insert = "HeroLumenirLightCompanionBasicAttack"
    tt = E:register_t("bolt_lumenir_mini_death", "bolt_lumenir_mini")
    tt = E:register_t("bolt_lumenir_wave", "bolt_lumenir")
    b = balance.heroes.hero_lumenir.fire_balls
    tt.bullet.damage_type = b.damage_type
    tt.bullet.hit_fx = "fx_bolt_lumenir_hit_mini"
    tt.bullet.particles_name = "ps_bolt_lumenir_wave"
    tt.render.sprites[1].name = "hero_lumenir_radiant_wave_projectile_idle"
    tt = E:register_t("arrow_hero_vesper_short_arrow", "arrow5_fixed_height")
    b = balance.heroes.hero_vesper
    tt.render.sprites[1].name = "hero_vesper_arrow"
    tt.bullet.fixed_height = 35
    tt.bullet.g = -1000
    tt.bullet.hit_blood_fx = nil
    tt.bullet.pop = {"pop_archer"}
    tt.bullet.hide_radius = 1
    tt.bullet.prediction_error = false
    tt.bullet.predict_target_pos = false
    tt.bullet.miss_decal = "hero_vesper_arrow_miss"
    tt.bullet.particles_name = "ps_hero_vesper_arrow_trail"
    tt.bullet.xp_gain_factor = b.basic_ranged_short.xp_gain_factor
    tt.bullet.extend_particles_cutoff = true
    tt.bullet.use_unit_damage_factor = true
    tt = E:register_t("arrow_hero_vesper_long_arrow", "arrow_hero_vesper_short_arrow")
    b = balance.heroes.hero_vesper
    tt.bullet.xp_gain_factor = b.basic_ranged_long.xp_gain_factor
    tt = E:register_t("hero_vesper_arrow_to_the_knee_arrow", "arrow5_45degrees")
    tt.render.sprites[1].name = "hero_vesper_arrow_to_the_knee_arrow"
    tt.render.sprites[1].animated = false
    tt.bullet.miss_decal = "hero_vesper_arrow_to_the_knee_arrow_miss"
    tt.bullet.flight_time = fts(15)
    tt.bullet.hide_radius = nil
    tt.bullet.hit_distance = 35
    tt.bullet.mod = "hero_vesper_arrow_to_the_knee_arrow_mod"
    tt.bullet.particles_name = "ps_hero_vesper_arrow_to_the_knee_bullet_trail"
    tt.bullet.hit_fx = "hero_vesper_arrow_to_the_knee_hit"
    tt.bullet.g = -4 / (fts(1) * fts(1))
    tt.bullet.extend_particles_cutoff = true
    tt.bullet.reset_to_target_pos = true
    tt.main_script.update = scripts.arrow5.update
    tt.bullet.hit_blood_fx = nil
    tt.sound_events.hit = "HeroVesperArrowToTheKneeImpact"
    tt = E:register_t("arrow_hero_vesper_disengage", "arrow5")
    tt.render.sprites[1].name = "hero_vesper_arrow"
    tt.bullet.miss_decal = "archer_hero_proy_0002-f"
    tt.bullet.flight_time_variance = 3
    tt.bullet.flight_time = fts(8)
    tt.bullet.pop = {"pop_archer"}
    tt.bullet.hide_radius = 1
    tt.bullet.particles_name = "ps_hero_vesper_arrow_trail"
    tt.bullet.g = -2.5 / (fts(1) * fts(1))
    tt = E:register_t("arrow_hero_vesper_ricochet", "bullet")
    b = balance.heroes.hero_vesper
    tt.main_script.update = scripts.hero_vesper_ricochet_bullet.update
    tt.render.sprites[1].name = "hero_vesper_ricochet_arrow"
    tt.render.sprites[1].animated = false
    tt.bullet.damage_type = b.ricochet.damage_type
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bounce_arrow_name = "hero_vesper_ricochet_arrow"
    tt.particle_after_bounce = "ps_hero_vesper_ricochet_bullet_trail_bounce"
    tt.bullet.hit_fx = "hero_vesper_ricochet_bullet_hit_fx"
    tt.bullet.acceleration_factor = 0.2
    tt.bullet.min_speed = 600
    tt.bullet.max_speed = 600
    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.bullet.particles_name = "ps_hero_vesper_ricochet_bullet_trail"
    tt.bullet.g = -1.8 / (fts(1) * fts(1))
    tt.bounces = nil
    tt.bounce_range = b.ricochet.bounce_range
    tt.sound = "HeroVesperRicochetImpact"
    tt = E:register_t("tower_elven_stargazers_ray", "bullet")

    local b = balance.towers.elven_stargazers

    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min_config = b.basic_attack.damage_min
    tt.bullet.damage_max_config = b.basic_attack.damage_max
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_time = fts(2)
    tt.bullet.out_fx = "fx_tower_elven_stargazers_ray_hit_start"
    tt.bullet.mod = "mod_tower_elven_stargazers_ray_hit"
    tt.bullet.hit_fx = "fx_tower_elven_stargazers_ray_hit"
    tt.hit_fx_only_no_target = true
    tt.image_width = 169
    tt.main_script.update = scripts.ray5_simple.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "elven_stargazers_tower_ray_idle"
    tt.render.sprites[1].loop = false
    tt.track_target = true
    tt.ray_duration = fts(5)
    tt.sound_events.insert = "TowerElvenStargazersBasicAttack"
    tt = E:register_t("tower_arcane_wizard_ray", "bullet")

    local b = balance.towers.arcane_wizard

    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min_config = b.basic_attack.damage_min
    tt.bullet.damage_max_config = b.basic_attack.damage_max
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_time = fts(2)
    tt.bullet.out_fx = "fx_tower_arcane_wizard_ray_hit_start"
    tt.bullet.mod = "mod_tower_arcane_wizard_ray_hit"
    tt.bullet.hit_fx = "fx_tower_arcane_wizard_ray_hit"
    tt.hit_fx_only_no_target = true
    tt.image_width = 152.5
    tt.main_script.update = scripts.ray5_simple.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_ray_idle"
    tt.render.sprites[1].loop = false
    tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
    tt.track_target = true
    tt.ray_duration = fts(24)
    tt = E:register_t("tower_arcane_wizard_ray_disintegrate", "tower_arcane_wizard_ray")
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.mod = "tower_arcane_wizard_ray_disintegrate_mod"
    tt.bullet.out_fx = "fx_tower_arcane_wizard_disintegrate_ray_hit_start"
    tt.bullet.hit_fx = "fx_tower_arcane_wizard_ray_disintegrate_hit"
    tt.image_width = 155
    tt.render.sprites[1].name = "arcane_wizard_tower_lvl4_disintegration_ray_idle"
    tt.render.sprites[1].loop = false
    tt.bullet.hit_time = fts(1)
    tt.hit_fx_only_no_target = false
    tt = E:register_t("bullet_hero_muyrn_verdant_blast", "bolt")
    b = balance.heroes.hero_muyrn
    tt.render.sprites[1].prefix = "hero_nyru_verdant_blast_projectile"
    tt.render.sprites[1].name = "flying"
    tt.render.sprites[1].animated = true
    tt.bullet.damage_type = b.verdant_blast.damage_type
    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 300
    tt.bullet.max_speed = 600
    tt.bullet.hit_distance = 20
    tt.bullet.extend_particles_cutoff = true
    tt.bullet.hide_radius = 0
    tt.bullet.hit_fx = "hero_muyrn_verdant_blast_bolt_flying_hit_fx"
    tt.bullet.hit_fx_flying = "hero_muyrn_verdant_blast_bolt_flying_hit_fx"
    tt.bullet.hit_fx_ignore_hit_offset = true
    tt.bullet.hit_decal = "decal_hero_muyrn_verdant_blast_hit"
    tt.bullet.particles_name = "ps_hero_muyrn_verdant_blast_bolt_trail"
    tt.bullet.miss_decal = nil
    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.sound = "HeroNyruVerdantBlastHit"
    tt.main_script.update = scripts.bullet_hero_muyrn_verdant_blast.update
    tt = E:register_t("tower_arborean_emissary_bolt", "bolt")
    b = balance.towers.arborean_emissary

    E:add_comps(tt, "force_motion")

    tt.render.sprites[1].prefix = "arborean_emissary_projectile"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_BULLETS
    tt.bullet.damage_type = b.basic_attack.damage_type
    tt.height_attack = 70
    tt.initial_vel_y = 50
    tt.transition_time = 1
    tt.target_distance_detection = 20
    tt.main_script.update = scripts.tower_arborean_emissary_bolt.update
    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.hit_fx = "fx_tower_arborean_emissary_bolt_hit"
    tt.bullet.mod = "mod_tower_arborean_emissary_basic_attack"
    tt.bullet.particles_name = "ps_tower_arborean_emissary_bolt_trail"
    tt.bullet.max_speed = 1800
    tt.bullet.min_speed = 30
    tt.initial_impulse = 9000
    tt.initial_impulse_duration = 0.1
    tt.initial_impulse_angle = math.pi * 0.5
    tt.force_motion.a_step = 10
    tt.force_motion.max_a = 1800
    tt.force_motion.max_v = 450
    tt.sound_events.insert = nil
    tt = E:register_t("tower_arborean_emissary_bolt_lvl1", "tower_arborean_emissary_bolt")
    b = balance.towers.arborean_emissary
    tt.bullet.damage_max = b.basic_attack.damage_max[1]
    tt.bullet.damage_min = b.basic_attack.damage_min[1]
    tt = E:register_t("tower_arborean_emissary_bolt_lvl2", "tower_arborean_emissary_bolt")
    b = balance.towers.arborean_emissary
    tt.bullet.damage_max = b.basic_attack.damage_max[2]
    tt.bullet.damage_min = b.basic_attack.damage_min[2]
    tt = E:register_t("tower_arborean_emissary_bolt_lvl3", "tower_arborean_emissary_bolt")
    b = balance.towers.arborean_emissary
    tt.bullet.damage_max = b.basic_attack.damage_max[3]
    tt.bullet.damage_min = b.basic_attack.damage_min[3]
    tt = E:register_t("tower_arborean_emissary_bolt_lvl4", "tower_arborean_emissary_bolt")
    b = balance.towers.arborean_emissary
    tt.bullet.damage_max = b.basic_attack.damage_max[4]
    tt.bullet.damage_min = b.basic_attack.damage_min[4]
    tt = E:register_t("bullet_tower_demon_pit_basic_attack_lvl1", "bombKR5")
    tt.bullet.flight_time = fts(31)
    tt.bullet.hit_payload = "soldier_tower_demon_pit_basic_attack_lvl1"
    tt.sound_events.hit_water = nil
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "demon_pit_tower_demon_projectile_idle"
    tt.bullet.hit_fx = nil
    tt.bullet.hit_decal = nil
    tt.bullet.rotation_speed = 5
    tt.bullet.pop = nil
    tt.bullet.particles_name = "tower_demon_pit_demon_trail"
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.sound_events.insert = "TowerDemonPitBasicAttack"
    tt = E:register_t("bullet_tower_demon_pit_basic_attack_lvl2", "bullet_tower_demon_pit_basic_attack_lvl1")
    tt.bullet.hit_payload = "soldier_tower_demon_pit_basic_attack_lvl2"
    tt = E:register_t("bullet_tower_demon_pit_basic_attack_lvl3", "bullet_tower_demon_pit_basic_attack_lvl1")
    tt.bullet.hit_payload = "soldier_tower_demon_pit_basic_attack_lvl3"
    tt = E:register_t("bullet_tower_demon_pit_basic_attack_lvl4", "bullet_tower_demon_pit_basic_attack_lvl1")
    tt.bullet.hit_payload = "soldier_tower_demon_pit_basic_attack_lvl4"
    tt = E:register_t("bullet_tower_demon_pit_big_guy_lvl4", "bullet")

    E:add_comps(tt, "main_script")

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
    tt = E:register_t("arrow_hero_builder_defensive_turret", "arrow5")
    tt.render.sprites[1].name = "hero_obdul_skill_4_tower_projectile"
    tt.bullet.miss_decal = nil
    tt.bullet.flight_time_variance = 3
    tt.bullet.flight_time = fts(15)
    tt.bullet.hide_radius = 1
    tt.bullet.g = -2 / (fts(1) * fts(1))
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = 30 * FPS * math.pi / 180
    tt = E:register_t("bullet_enemy_unblinded_priest", "bolt_enemy")
    b = balance.enemies.cult_of_the_overseer.unblinded_priest
    tt.render.sprites[1].prefix = "unblinded_priest_projectile"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.bullet.damage_max = b.ranged_attack.damage_max
    tt.bullet.damage_min = b.ranged_attack.damage_min
    tt.bullet.damage_type = b.ranged_attack.damage_type
    tt.bullet.hit_blood_fx = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.align_with_trajectory = true
    tt.bullet.hit_fx = "fx_bullet_enemy_unblinded_priest_hit"
    tt.bullet.particles_name = "ps_bullet_enemy_unblinded_priest"
    tt = E:register_t("arrow_tower_stargazers_death_star", "arrow5")
    b = balance.towers.elven_stargazers
    tt.main_script.update = scripts.arrow5.update
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "elven_stargazers_tower_rising_star_star_idle"
    tt.bullet.particles_name = "ps_stargazers_death_star_trail"
    tt.bullet.miss_decal = nil
    tt.bullet.hit_blood_fx = nil
    tt.bullet.miss_fx = "fx_tower_stargazers_death_star_hit"
    tt.bullet.hit_fx = "fx_tower_stargazers_death_star_hit"
    tt.bullet.mod = "mod_tower_stargazers_death_star_stun"
    tt.bullet.damage_max = b.stars_death.damage_max
    tt.bullet.damage_min = b.stars_death.damage_min
    tt.bullet.flight_time_variance = 3
    tt.bullet.flight_time = fts(20)
    tt.bullet.hide_radius = 0
    tt.bullet.g = -2 / (fts(1) * fts(1))
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = 15
    tt.sound_events.hit = "TowerElvenStargazersRisingStarImpact"

    tt = E:register_t("bolt_soul_soldier_tower_ghost", "bolt")
    b = balance.towers.ghost.soul_attack
    tt.render.sprites[1].name = "ghost_tower_soul_skill_projectile"
    tt.render.sprites[1].animated = false
    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.hit_blood_fx = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.align_with_trajectory = true
    tt.bullet.mods = {"mod_tower_ghost_soul_slow", "mod_tower_ghost_soul_damage_factor"}
    tt.bullet.hit_fx = "fx_soul_soldier_tower_ghost"
    tt.bullet.use_unit_damage_factor = true
    tt.sound_events.hit = "TowerGhostSoulAttackImpact"
    tt.bullet.damage_type = b.damage_type
    tt.bullet.particles_name = "ps_soul_soldier_tower_ghost"
    tt = E:register_t("arrow_soldier_re_shadow_archer", "arrow5")
    b = balance.upgrades.reinforcements_shadow_archer
    tt.render.sprites[1].name = "reinforcements_lvl3_03_arrow"
    tt.bullet.flight_time_variance = 3
    tt.bullet.flight_time = fts(8)
    tt.bullet.pop = {"pop_archer"}
    tt.bullet.hide_radius = 1
    tt.bullet.g = -2.5 / (fts(1) * fts(1))
    tt.bullet.damage_max = b.soldier.ranged_attack.damage_max
    tt.bullet.damage_min = b.soldier.ranged_attack.damage_min
    tt = E:register_t("bullet_soldier_tower_rocket_gunners", "bullet")
    b = balance.towers.rocket_gunners.soldier.ranged_attack
    tt.bullet.hit_fx = "fx_bullet_soldier_tower_rocket_gunners_hit"
    tt.bullet.floor_fx = "fx_bullet_soldier_tower_rocket_gunners_floor"
    tt.bullet.flight_time = fts(2)
    tt.bullet.damage_type = DAMAGE_PHYSICAL
    tt.bullet.damage_max = b.damage_max
    tt.bullet.damage_min = b.damage_min
    tt.bullet.damage_max_config = b.damage_max
    tt.bullet.damage_min_config = b.damage_min
    tt.bullet.level = 1
    tt.main_script.update = scripts.bullet_soldier_tower_rocket_gunners.update
    tt.render = nil
    tt.sound_events.insert = "TowerRocketGunnersBasicAttack"
    tt = E:register_t("bullet_soldier_tower_rocket_gunners_phosphoric", "bullet")
    b = balance.towers.rocket_gunners.soldier
    tt.bullet.hit_fx = "fx_bullet_soldier_tower_rocket_gunners_phosphoric_hit"
    tt.bullet.floor_fx = "fx_bullet_soldier_tower_rocket_gunners_phosphoric_floor"
    tt.bullet.flight_time = fts(2)
    tt.bullet.hit_time = fts(2)
    tt.bullet.damage_type = DAMAGE_PHYSICAL
    tt.bullet.level = 1
    tt.main_script.update = scripts.bullet_soldier_tower_rocket_gunners_phosphoric.update
    tt.bullet.damage_max = b.ranged_attack.damage_max[4]
    tt.bullet.damage_min = b.ranged_attack.damage_min[4]
    tt.render.sprites[1].anchor = vec_2(0.2, 0.5)
    tt.render.sprites[1].name = "rocket_gunners_tower_phosphoric_coating_trace_idle"
    tt.render.sprites[1].loop = false
    tt.image_width = 70
    tt.track_target = true
    tt.ray_duration = fts(2)
    tt.sound_events.insert = "TowerRocketGunnersPhosphoricCoating"
    tt = E:register_t("bullet_soldier_tower_rocket_gunners_sting_missiles", "bullet")
    b = balance.towers.rocket_gunners.soldier

    E:add_comps(tt, "force_motion")

    tt.bullet.flight_time = fts(31)
    tt.bullet.hit_fx = "fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit"
    tt.bullet.hit_fx_air = "fx_bullet_soldier_tower_rocket_gunners_sting_missiles_hit_air"
    tt.bullet.particles_name = "ps_tower_rocket_gunners_sting_missiles_trail"
    tt.bullet.hit_decal = "decal_bullet_soldier_tower_rocket_gunners_sting_missiles"
    tt.bullet.hit_decal_fx = "fx_bullet_soldier_tower_rocket_gunners_sting_missiles_smoke"
    tt.bullet.align_with_trajectory = true
    tt.bullet.ignore_hit_offset = true
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "rocket_gunners_tower_sting_missiles_projectile_idle"
    tt.main_script.update = scripts.bullet_soldier_tower_rocket_gunners_sting_missiles.update
    tt.initial_impulse = 3000
    tt.initial_impulse_duration = 0.3
    tt.initial_impulse_angle = 0
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 1800
    tt.force_motion.max_v = 450
    tt.mod = "mod_soldier_tower_rocket_gunners_sting_missiles_target"
    tt.sound_events.insert = "TowerRocketGunnersStingMissileCast"
    tt.sound_events.hit = "TowerRocketGunnersStingMissileExplosion"
    tt = E:register_t("bullet_tower_necromancer", "bolt")
    b = balance.towers.necromancer

    E:add_comps(tt, "force_motion")

    tt.render.sprites[1].prefix = "necromancer_tower_skull_projectile"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_TOWER_BASES
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "necromancer_tower_skull_projectile_spawn_FX"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_BULLETS
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.height_attack = 70
    tt.initial_vel_y = 50
    tt.transition_time = 1
    tt.target_distance_detection = 20
    tt.main_script.insert = scripts.bullet_tower_necromancer.insert
    tt.main_script.update = scripts.bullet_tower_necromancer.update
    tt.bullet.damage_type = b.basic_attack.damage_type
    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.hit_fx = "necromancer_tower_skull_projectile_hit_FX"
    tt.bullet.mod = "mod_tower_necromancer_curse"
    tt.bullet.particles_name = "ps_tower_necromancer_skull_trail"
    tt.bullet.max_speed = 1800
    tt.bullet.min_speed = 30
    tt.bullet.max_track_distance = 50
    tt.force_motion.a_step = 6
    tt.force_motion.max_a = 3000
    tt.force_motion.max_v = 360
    tt.initial_impulse = 9000
    tt.initial_impulse_duration = 0.1
    tt.initial_impulse_angle = math.pi * 0.5
    tt.spawn_time = fts(18)
    tt.sound_events.insert = ""
    tt.shoot_sound = "TowerNecromancerBasicAttack"
    tt.hit_sound = "TowerNecromancerBasicAttackHit"
    tt.summon_sound = "TowerNecromancerBasicAttackSummon"
    tt = E:register_t("bullet_tower_necromancer_lvl1", "bullet_tower_necromancer")
    b = balance.towers.necromancer
    tt.bullet.damage_max = b.basic_attack.damage_max[1]
    tt.bullet.damage_min = b.basic_attack.damage_min[1]
    tt = E:register_t("bullet_tower_necromancer_lvl2", "bullet_tower_necromancer")
    b = balance.towers.necromancer
    tt.bullet.damage_max = b.basic_attack.damage_max[2]
    tt.bullet.damage_min = b.basic_attack.damage_min[2]
    tt = E:register_t("bullet_tower_necromancer_lvl3", "bullet_tower_necromancer")
    b = balance.towers.necromancer
    tt.bullet.damage_max = b.basic_attack.damage_max[3]
    tt.bullet.damage_min = b.basic_attack.damage_min[3]
    tt = E:register_t("bullet_tower_necromancer_lvl4", "bullet_tower_necromancer")
    b = balance.towers.necromancer
    tt.bullet.damage_max = b.basic_attack.damage_max[4]
    tt.bullet.damage_min = b.basic_attack.damage_min[4]
    tt = E:register_t("bullet_tower_ballista", "bullet")
    b = balance.towers.ballista.basic_attack
    tt.bullet.hit_fx = "fx_bullet_tower_ballista_hit"
    tt.bullet.flight_time = fts(2)
    tt.bullet.hit_time = fts(2)
    tt.bullet.damage_type = DAMAGE_PHYSICAL
    tt.bullet.level = 1
    tt.main_script.update = scripts.bullet_tower_ballista.update
    tt.render.sprites[1].anchor = vec_2(0.2, 0.5)
    tt.render.sprites[1].name = "ballista_tower_arrow_idle"
    tt.render.sprites[1].loop = false
    tt.image_width = 175
    tt.ray_duration = fts(11)
    tt.hit_delay = fts(3)
    tt.missed_arrow = "fx_bullet_tower_ballista_missed_arrow"
    tt.missed_arrow_dust = "fx_bullet_tower_ballista_missed_arrow_dust"
    tt.missed_arrow_decal = "fx_bullet_tower_ballista_missed_arrow_decal"
    tt.sound_events.insert = "TowerBallistaBasicAttack"
    tt = E:register_t("bullet_tower_ballista_lvl1", "bullet_tower_ballista")
    b = balance.towers.ballista.basic_attack
    tt.bullet.damage_max = b.damage_max[1]
    tt.bullet.damage_min = b.damage_min[1]
    tt = E:register_t("bullet_tower_ballista_lvl2", "bullet_tower_ballista")
    b = balance.towers.ballista.basic_attack
    tt.bullet.damage_max = b.damage_max[2]
    tt.bullet.damage_min = b.damage_min[2]
    tt = E:register_t("bullet_tower_ballista_lvl3", "bullet_tower_ballista")
    b = balance.towers.ballista.basic_attack
    tt.bullet.damage_max = b.damage_max[3]
    tt.bullet.damage_min = b.damage_min[3]
    tt = E:register_t("bullet_tower_ballista_lvl4", "bullet_tower_ballista")
    b = balance.towers.ballista.basic_attack
    tt.bullet.damage_max = b.damage_max[4]
    tt.bullet.damage_min = b.damage_min[4]
    tt = E:register_t("bullet_tower_ballista_skill_final_shot", "bullet_tower_ballista_lvl4")
    b = balance.towers.ballista.skill_final_shot
    tt.bullet.hit_fx = "fx_bullet_tower_ballista_final_shot_hit"
    tt.bullet.damage_factor = b.damage_factor[1]
    tt.bullet.mod = "mod_bullet_tower_ballista_skill_final_shot_stun"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "ballista_tower_special_arrow_idle"
    tt.image_width = 162.5
    tt.is_final_shot = true
    tt.sound_events.insert = "TowerBallistaFinalNail"
    tt = E:register_t("bullet_tower_ballista_skill_bomb", "bombKR5")

    local b = balance.towers.ballista.skill_bomb

    tt.bullet.damage_max_config = b.damage_area_max
    tt.bullet.damage_min_config = b.damage_area_min
    tt.bullet.damage_radius = b.damage_radius
    tt.bullet.flight_time = fts(31)
    tt.bullet.hit_fx = "fx_bullet_tower_ballista_bomb_explosion"
    tt.bullet.pop_chance = 0.5
    tt.bullet.particles_name = {"ps_bullet_tower_ballista_skill_bomb_trail_A",
                                "ps_bullet_tower_ballista_skill_bomb_trail_B"}
    tt.main_script.update = scripts.bullet_tower_ballista_skill_bomb.update
    tt.main_script.remove = scripts.bullet_tower_ballista_skill_bomb.remove
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "TowerTricannonBasicAttackImpact"
    tt.render.sprites[1].name = "ballista_tower_bomb_projectile_idle"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].hidden = false
    tt.scraps = "aura_bullet_tower_ballista_skill_bomb"
    tt.duration_config = balance.towers.ballista.skill_bomb.duration
    tt.sound_events.insert = "TowerBallistaScrapBombCast"
    tt.sound_events.hit = "TowerBallistaScrapBombExplosion"
    tt = E:register_t("bullet_hero_mecha", "bullet")
    b = balance.heroes.hero_mecha.basic_ranged

    E:add_comps(tt, "force_motion")

    tt.bullet.flight_time = fts(31)
    tt.bullet.spawn_fx_1 = "fx_bullet_hero_mecha_spawn_1"
    tt.bullet.spawn_fx_2 = "fx_bullet_hero_mecha_spawn_2"
    tt.bullet.hit_fx = "fx_bullet_hero_mecha_hit"
    tt.bullet.particles_name = "ps_bullet_hero_mecha_trail"
    tt.bullet.align_with_trajectory = true
    tt.bullet.damage_type = b.damage_type
    tt.bullet.use_unit_damage_factor = true
    tt.bullet.xp_gain_factor = b.xp_gain_factor
    tt.sound_events.hit = "HeroMechaBasicAttackHit"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "hero_onagro_attack_projectile_idle"
    tt.render.sprites[1].anchor = vec_2(0.35, 0.5)
    tt.main_script.insert = scripts.bullet_hero_mecha.insert
    tt.main_script.update = scripts.bullet_hero_mecha.update
    tt.initial_impulse = 3000
    tt.initial_impulse_duration = 0.3
    tt.initial_impulse_angle = 0
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 1800
    tt.force_motion.max_v = 450
    tt.max_rotation_speed = 12
    tt.min_speed = 2
    tt = E:register_t("bullet_hero_mecha_tar_bomb", "bombKR5")
    b = balance.heroes.hero_mecha.tar_bomb
    tt.bullet.flight_time = fts(25)
    tt.bullet.hit_fx = "fx_bullet_hero_mecha_tar_bomb"
    tt.bullet.align_with_trajectory = false
    tt.bullet.ignore_hit_offset = true
    tt.bullet.pop_chance = 0.5
    tt.bullet.rotation_speed = nil
    tt.bullet.hit_payload = "aura_bullet_hero_mecha_tar_bomb"
    tt.sound_events.hit = "HeroMechaTarBombExplosion"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "hero_onagro_skill_2_projectile"
    tt = E:register_t("bullet_hero_mecha_mine", "bombKR5")
    b = balance.heroes.hero_mecha.mine_drop
    tt.bullet.flight_time = fts(25)
    tt.bullet.align_with_trajectory = false
    tt.bullet.ignore_hit_offset = true
    tt.bullet.rotation_speed = 7.75
    tt.bullet.hit_payload = "aura_bullet_hero_mecha_mine"
    tt.bullet.hit_decal = nil
    tt.bullet.hit_fx = nil
    tt.bullet.pop_chance = 0
    tt.main_script.insert = scripts.bullet_hero_mecha_mine.insert
    tt.main_script.update = scripts.bullet_hero_mecha_mine.update
    tt.sound_events.insert = nil
    tt.sound_events.hit = nil
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "hero_onagro_skill_4_mine_projectile"
    tt = E:register_t("bullet_zeppelin_hero_mecha", "bombKR5")
    b = balance.heroes.hero_mecha.ultimate
    tt.bullet.flight_time = fts(40)
    tt.bullet.hit_fx = "fx_bullet_zeppelin_hero_mecha"
    tt.bullet.align_with_trajectory = false
    tt.bullet.ignore_hit_offset = true
    tt.bullet.pop_chance = 0.5
    tt.bullet.rotation_speed = 10
    tt.sound_events.insert = "HeroMechaDeathFromAboveAttack"
    tt.sound_events.hit = "HeroMechaDeathFromAboveExplosion"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "hero_onagro_ultimate_projectile"
    tt = E:register_t("bullet_hero_venom_ranged_tentacle", "bullet")

    local b = balance.heroes.hero_venom.ranged_tentacle

    tt.bullet.damage_type = b.damage_type
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_time = fts(4)
    tt.bullet.mods = {"mod_bullet_hero_venom_ranged_tentacle_bleed", "mod_bullet_hero_venom_ranged_tentacle_stun"}
    tt.bullet.hit_fx = "fx_hero_venom_melee_attack_hit"
    tt.image_width = 179
    tt.dist_offset = 70
    tt.main_script.insert = scripts.bullet_hero_venom_ranged_tentacle.insert
    tt.main_script.update = scripts.ray5_simple.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "hero_venom_ranged_skill_tentacle_idle"
    tt.render.sprites[1].loop = false
    tt.sound_events.insert = nil
    tt.track_target = false
    tt.ray_duration = fts(20)
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
    tt = E:register_t("bullet_stage_11_veznan_skill_1", "bolt")
    tt.render.sprites[1].prefix = "stage11_veznan_export_proyectile"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].anchor = vec_2(0.45, 0.5)
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
    tt = E:register_t("bullet_stage_11_cult_leader_illusion", "bolt_enemy")

    local b = balance.specials.stage11_cult_leader.illusion

    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.render.sprites[1].prefix = "mydrias_proyectile"
    tt.render.sprites[1].flip_x = true
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.bullet.hit_fx = "fx_stage_11_cult_leader_attack_hit"
    tt.bullet.pop = nil
    tt.bullet.pop_conds = nil
    tt.bullet.acceleration_factor = 0.5
    tt.bullet.damage_min = b.ranged_attack.damage_min
    tt.bullet.damage_max = b.ranged_attack.damage_max
    tt.bullet.max_speed = 360
    tt.bullet.particles_name = "ps_bullet_stage_11_cult_leader"
    tt.bullet.damage_type = b.ranged_attack.damage_type
    tt.bullet.align_with_trajectory = true
    tt.main_script.insert = scripts.bullet_stage_11_cult_leader_illusion.insert
    tt.main_script.update = scripts.bullet_stage_11_cult_leader_illusion.update
    tt = E:register_t("bullet_tower_flamespitter_skill_bomb", "bombKR5")

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
    tt.main_script.update = scripts.bomb_KR5.update
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
    tt = E:register_t("bullet_tower_barrel_lvl1", "bombKR5")

    local b = balance.towers.barrel.basic_attack

    tt.bullet.damage_max = b.damage_max[1]
    tt.bullet.damage_min = b.damage_min[1]
    tt.bullet.damage_radius = b.damage_radius
    tt.bullet.flight_time = fts(25)
    tt.bullet.hit_fx = "fx_bullet_tower_barrel"
    tt.bullet.hit_decal = "decal_bullet_tower_barrel"
    tt.bullet.pop_chance = 0.5
    tt.bullet.particles_name = "ps_bullet_tower_barrel"
    tt.bullet.align_with_trajectory = false
    tt.bullet.mod = "mod_bullet_tower_barrel_lvl1"
    tt.bullet.rotation_speed = 0
    tt.main_script.update = scripts.bomb_KR5.update
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "TowerBarrelBasicAttackImpact"
    tt.sound_events.insert = nil
    tt.render.sprites[1].prefix = "barrel_tower_projectile"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].hidden = false
    tt = E:register_t("bullet_tower_barrel_lvl2", "bullet_tower_barrel_lvl1")

    local b = balance.towers.barrel.basic_attack

    tt.bullet.damage_max = b.damage_max[2]
    tt.bullet.damage_min = b.damage_min[2]
    tt.bullet.mod = "mod_bullet_tower_barrel_lvl2"
    tt = E:register_t("bullet_tower_barrel_lvl3", "bullet_tower_barrel_lvl1")

    local b = balance.towers.barrel.basic_attack

    tt.bullet.damage_max = b.damage_max[3]
    tt.bullet.damage_min = b.damage_min[3]
    tt.bullet.mod = "mod_bullet_tower_barrel_lvl3"
    tt = E:register_t("bullet_tower_barrel_lvl4", "bullet_tower_barrel_lvl1")

    local b = balance.towers.barrel.basic_attack

    tt.bullet.damage_max = b.damage_max[4]
    tt.bullet.damage_min = b.damage_min[4]
    tt.bullet.mod = "mod_bullet_tower_barrel_lvl4"
    tt = E:register_t("bullet_tower_barrel_skill_barrel", "bombKR5")

    local b = balance.towers.barrel.skill_barrel

    tt.bullet.damage_max = 0
    tt.bullet.damage_min = 0
    tt.bullet.hit_fx = nil
    tt.bullet.hit_decal = nil
    tt.bullet.hit_payload = "aura_bullet_tower_barrel_skill_barrel"
    tt.bullet.flight_time = fts(25)
    tt.bullet.pop_chance = 0
    tt.bullet.particles_name = "ps_bullet_tower_barrel_skill_barrel"
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = nil
    tt.main_script.update = scripts.bomb_KR5.update
    tt.sound_events.hit_water = nil
    tt.sound_events.insert = nil
    tt.sound_events.remove = "TowerBarrelBadBatchRattle"
    tt.render.sprites[1].name = "barrel_tower_lvl4_bad_barrel_projectile"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].hidden = false
    tt.render.sprites[1].r = 0
    tt = E:register_t("bullet_tower_sand_lvl1", "bullet")
    b = balance.towers.sand.basic_attack
    tt.bullet.damage_min = b.damage_min[1]
    tt.bullet.damage_max = b.damage_max[1]
    tt.bullet.damage_type = b.damage_type
    tt.bullet.g = 0
    tt.bullet.pop = {"pop_golden"}
    tt.bullet.pop_chance = 0.1
    tt.bullet.particles_name = "ps_bullet_tower_sand"
    tt.bullet.hit_fx = "fx_bullet_tower_sand_hit"
    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = F_NIGHTMARE
    tt.bullet.fixed_speed = FPS * 12
    tt.main_script.update = scripts.bullet_tower_sand.update
    tt.render.sprites[1].prefix = "tower_sand_lvl1_projectile"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].animated = true
    tt.max_bounces = b.max_bounces[1]
    tt.bounce_range = b.bounce_range
    tt.bounce_speed_mult = b.bounce_speed_mult
    tt.bounce_damage_mult = b.bounce_damage_mult
    tt.sound_hit = "TowerSandBasicAttackHit"
    tt = E:register_t("bullet_tower_sand_lvl2", "bullet_tower_sand_lvl1")
    b = balance.towers.sand.basic_attack
    tt.bullet.damage_min = b.damage_min[2]
    tt.bullet.damage_max = b.damage_max[2]
    tt.max_bounces = b.max_bounces[2]
    tt = E:register_t("bullet_tower_sand_lvl3", "bullet_tower_sand_lvl1")
    b = balance.towers.sand.basic_attack
    tt.bullet.damage_min = b.damage_min[3]
    tt.bullet.damage_max = b.damage_max[3]
    tt.max_bounces = b.max_bounces[3]
    tt = E:register_t("bullet_tower_sand_lvl4", "bullet_tower_sand_lvl1")
    b = balance.towers.sand.basic_attack
    tt.bullet.damage_min = b.damage_min[4]
    tt.bullet.damage_max = b.damage_max[4]
    tt.max_bounces = b.max_bounces[4]
    tt.render.sprites[1].prefix = "tower_sand_lvl4_projectile"
    tt = E:register_t("bullet_tower_sand_skill_gold", "bullet_tower_sand_lvl1")
    b = balance.towers.sand.skill_gold
    tt.bullet.damage_min_config = b.damage_min
    tt.bullet.damage_max_config = b.damage_max
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.particles_name = "ps_bullet_tower_sand_skill_gold"
    tt.bullet.hit_fx = "fx_bullet_tower_sand_skill_gold_hit"
    tt.bullet.hit_fx_coins = "fx_bullet_tower_sand_skill_gold_hit_coins"
    tt.render.sprites[1].prefix = "tower_sand_lvl4_skill_1_projectile"
    tt.gold_chance = b.gold_chance
    tt.gold_extra = b.gold_extra
    tt.max_bounces = b.max_bounces
    tt = E:register_t("bullet_tower_ray_lvl1", "bullet")

    local b = balance.towers.ray.basic_attack

    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min = b.damage_min[1]
    tt.bullet.damage_max = b.damage_max[1]
    tt.bullet.hit_time = fts(2)
    tt.bullet.out_start_fx = "fx_tower_ray_hit_start"
    tt.bullet.out_fx = "fx_tower_ray_hit_source"
    tt.bullet.mods = {"mod_tower_ray_damage", "mod_tower_ray_slow"}
    tt.hit_fx_only_no_target = true
    tt.image_width = 152.5
    tt.main_script.update = scripts.bullet_tower_ray.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "channeler_tower_ray"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].loop = true
    tt.sound_events.insert = "TowerRayBasicAttackCast"
    tt.sound_events.interrupt = "TowerRayBasicAttackOffset"
    tt.track_target = true
    tt.ray_duration = b.duration
    tt.damage_mult = 1
    tt.vis_flags = F_RANGED
    tt = E:register_t("bullet_tower_ray_lvl2", "bullet_tower_ray_lvl1")
    tt.bullet.damage_min = b.damage_min[2]
    tt.bullet.damage_max = b.damage_max[2]
    tt = E:register_t("bullet_tower_ray_lvl3", "bullet_tower_ray_lvl1")
    tt.bullet.damage_min = b.damage_min[3]
    tt.bullet.damage_max = b.damage_max[3]
    tt = E:register_t("bullet_tower_ray_lvl4", "bullet_tower_ray_lvl1")
    tt.bullet.damage_min = b.damage_min[4]
    tt.bullet.damage_max = b.damage_max[4]
    tt = E:register_t("bullet_tower_ray_chain", "bullet_tower_ray_lvl4")

    local b = balance.towers.ray

    tt.damage_mult = nil
    tt.max_enemies = b.skill_chain.max_enemies
    tt.chain_pos = 1
    tt.chain_delay = b.skill_chain.chain_delay
    tt.chain_range = b.skill_chain.chain_range
    tt.chain_range_to_stay = tt.chain_range + b.basic_attack.extra_range_to_stay
    tt.vis_bans = bor(F_NIGHTMARE)
    tt = E:register_t("bullet_tower_ray_sheep", "bolt")
    b = balance.towers.ray.skill_sheep

    E:add_comps(tt, "force_motion")

    tt.render.sprites[1].hidden = true
    tt.height_attack = 70
    tt.initial_vel_y = 50
    tt.transition_time = 1
    tt.target_distance_detection = 20
    tt.main_script.insert = scripts.bolt.insert
    tt.main_script.update = scripts.bullet_tower_ray_sheep.update
    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_max = 0
    tt.bullet.damage_min = 0
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.bullet.hit_fx = "fx_tower_ray_lvl4_attack_sheep_hit"
    tt.bullet.particles_name = "ps_bullet_tower_ray_sheep"
    tt.bullet.max_speed = 1800
    tt.bullet.min_speed = 30
    tt.bullet.max_track_distance = 50
    tt.force_motion.a_step = 6
    tt.force_motion.max_a = 3000
    tt.force_motion.max_v = 360
    tt.initial_impulse = 9000
    tt.initial_impulse_duration = 0.1
    tt.initial_impulse_angle = math.pi * 0.5
    tt.spawn_time = fts(18)
    tt.sound_events.insert = "TowerRayMutationHexCast"
    tt.shoot_sound = nil
    tt.hit_sound = nil
    tt.sheep_t = "enemy_tower_ray_sheep"
    tt.sheep_flying_t = "enemy_tower_ray_sheep_flying"
    tt.sheep_hp_mult = b.sheep.hp_mult
    tt = E:register_t("bullet_decal_item_portable_coil", "bullet")
    b = balance.items.portable_coil
    tt.bullet.damage_min = b.damage_min
    tt.bullet.damage_max = b.damage_max
    tt.bullet.damage_min_chain = b.damage_min_chain
    tt.bullet.damage_max_chain = b.damage_max_chain
    tt.bullet.damage_type = b.damage_type
    tt.bullet.hit_time = fts(2)
    tt.bullet.hit_fx = "fx_bullet_decal_item_portable_coil"
    tt.bullet.mods = {"mod_decal_item_portable_coil_stun"}
    tt.hit_fx_only_no_target = false
    tt.image_width = 75
    tt.main_script.update = scripts.bullet_decal_item_portable_coil.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "portable_coil_lightning_fx"
    tt.render.sprites[1].name = "attack"
    tt.render.sprites[1].loop = false
    tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
    tt.track_target = true
    tt.chain_range = b.chain_range
    tt.chain_delay = fts(2)
    tt.chain_pos = 1
    tt.max_chain_length = b.max_chain_length
    tt.vis_flags = bor(F_STUN)
    tt.vis_bans = bor(F_NIGHTMARE)
    tt = E:register_t("bullet_boss_corrupted_denas_spawn_entities", "bombKR5")
    tt.bullet.flight_time = fts(30)
    tt.bullet.align_with_trajectory = false
    tt.bullet.ignore_hit_offset = true
    tt.bullet.pop = nil
    tt.bullet.rotation_speed = nil
    tt.bullet.hit_payload = "enemy_glareling"
    tt.bullet.particles_name = "ps_bullet_boss_corrupted_denas_spawn_entities"
    tt.sound_events.insert = "Stage11BossCorruptedDenasGlarelingSpawn"
    tt.sound_events.hit = nil
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "glearling_flying"
    tt.bullet.rotation_speed = 10
    tt.bullet.hit_decal = nil
    tt.bullet.hit_fx = nil
    tt.bullet.damage_type = DAMAGE_EXPLOSION
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.g = -0.8 / (fts(1) * fts(1))
    tt.main_script.update = scripts.bullet_boss_corrupted_denas_spawn_entities.update
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
    tt.bullet.damage_min = b.damage_max
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
    tt.initial_impulse_angle = math.pi * 0.5
    tt.force_motion.a_step = 15
    tt.force_motion.max_a = 1800
    tt.force_motion.max_v = 600
    tt.sound_events.insert = nil
    tt = E:register_t("bomb_item_cluster_bomb", "bombKR5")
    b = balance.items.cluster_bomb
    tt.bullet.damage_max = b.damage_max
    tt.bullet.damage_min = b.damage_min
    tt.bullet.damage_radius = b.damage_radius
    tt.bullet.damage_type = b.damage_type
    tt.bullet.flight_time = fts(20)
    tt.bullet.hit_fx = "fx_item_cluster_bomb"
    tt.bullet.rotation_speed = 10 * FPS * math.pi / 180
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "cluster_bomb_bomb_idle"
    tt.main_script.update = scripts.bullet_cluster_bomb.update
    tt.bomb_amounts = b.bomb_amounts
    tt.bomb_small = "bomb_item_cluster_bomb_small"
    tt.bombs_position = {{-30, -30}, {30, 30}, {-30, 30}, {30, -30}, {5, -40}}
    tt.time_between_bombs = fts(1)
    tt.bullet.hit_decal = "decal_item_cluster_bomb_crater"
    tt.sound_events.insert = "ItemsClusterBombCast"
    tt = E:register_t("bomb_item_cluster_bomb_small", "bombKR5")
    b = balance.items.cluster_bomb
    tt.bullet.damage_max = b.damage_max_small
    tt.bullet.damage_min = b.damage_min_small
    tt.bullet.damage_radius = b.damage_radius_small
    tt.bullet.damage_type = b.damage_type
    tt.bullet.flight_time = fts(20)
    tt.bullet.hit_fx = "fx_item_cluster_bomb_small"
    tt.bullet.rotation_speed = 10 * FPS * math.pi / 180 * -1
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "cluster_bomb_fragment"
    tt.bullet.pop = nil
    tt.bullet.hit_decal = "decal_item_cluster_bomb_crater"
    tt.bullet.hide_radius = 0
    tt.sound_events.insert = nil
    tt.sound_events.hit = "ItemsClusterBombSmallBombs"
    tt = E:register_t("bullet_vile_spawner_spawn", "bombKR5")
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
    tt.render.sprites[1].anchor = vec_2(0.6, 0.4)
    tt.bullet.hit_decal = nil
    tt.bullet.hit_fx = nil
    tt.bullet.damage_type = DAMAGE_EXPLOSION
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.g = -0.8 / (fts(1) * fts(1))
    tt.main_script.update = scripts.bullet_vile_spawner_spawn.update
    tt.bullet_particle = "bullet_vile_spawner_spawn_particle"
    tt = E:register_t("bullet_vile_spawner_spawn_particle", "bombKR5")
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
    tt.render.sprites[1].anchor = vec_2(0.55, 0.45)
    tt.bullet.hit_decal = nil
    tt.bullet.hit_fx = nil
    tt.bullet.damage_type = DAMAGE_EXPLOSION
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.g = -0.8 / (fts(1) * fts(1))
    tt.main_script.update = scripts.bullet_vile_spawner_spawn_particle.update
    tt = E:register_t("bullet_enemy_noxious_horror", "bombKR5")

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
    tt = E:register_t("bullet_enemy_blinker", "bullet")

    local b = balance.enemies.void_beyond.blinker

    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.hit_time = fts(0)
    tt.image_width = 112.5
    tt.main_script.update = scripts.bullet_enemy_blinker.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].prefix = "SunrayTower_BigRay"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
    tt.track_target = true
    tt.ray_duration = b.duration
    tt = E:register_t("bullet_hero_robot_skill_fire", "bullet")
    b = balance.heroes.hero_robot
    tt.main_script.update = scripts.bullet_hero_robot_skill_fire.update
    tt.render.sprites[1].name = "Blaze_skill2proyectil"
    tt.render.sprites[1].animated = false
    tt.bullet.damage_type = b.fire.damage_type
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_fx = "fx_hero_robot_skill_fire"
    tt.bullet.acceleration_factor = 0.2
    tt.bullet.min_speed = 600
    tt.bullet.max_speed = 600
    tt.bullet.vis_flags = F_RANGED
    tt.bullet.vis_bans = 0
    tt.bullet.g = -1.8 / (fts(1) * fts(1))
    tt.damage_radius = b.fire.damage_radius
    tt.damage_bans = bor(F_FLYING)
    tt.damage_flags = bor(F_RANGED)
    tt.aura_on_hit = "aura_hero_robot_skill_fire_slow"

    tt = E:register_t("bolt_hero_dragon_gem_attack", "bolt")

    E:add_comps(tt, "force_motion")

    b = balance.heroes.hero_dragon_gem.basic_ranged_shot
    tt.bullet.damage_type = b.damage_type
    tt.bullet.hit_fx = nil
    tt.bullet.hit_fx_floor = "fx_hero_dragon_gem_bolt_hit"
    tt.bullet.hit_fx_flying = "fx_hero_dragon_gem_bolt_hit_flying"
    tt.bullet.particles_name = "ps_bolt_hero_dragon_gem_attack"
    tt.bullet.max_speed = 600
    tt.bullet.align_with_trajectory = true
    tt.bullet.min_speed = 600
    tt.bullet.xp_gain_factor = b.xp_gain_factor
    tt.bullet.use_unit_damage_factor = true
    tt.bullet.ignore_hit_offset = true
    tt.bullet.payload = {"decal_hero_dragon_gem_floor_decal", "decal_hero_dragon_gem_floor_circle"}
    tt.bullet.pop_chance = 0
    tt.force_motion.a_step = 5
    tt.force_motion.max_a = 3000
    tt.force_motion.max_v = 600
    tt.render.sprites[1].prefix = "hero_dragon_gem_attack_projectile"
    tt.render.sprites[1].z = Z_FLYING_HEROES
    tt.main_script.update = scripts.bolt_hero_dragon_gem_attack.update
    tt.damage_range = b.damage_range
    tt.sound_hit = "HeroDragonGemBasicAttackImpact"
    tt = E:register_t("ray_hero_dragon_gem_stun", "bullet")
    b = balance.heroes.hero_dragon_gem
    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.hit_time = fts(0)
    tt.bullet.ignore_hit_offset = true
    tt.bullet.hit_payload = "aura_hero_dragon_gem_skill_stun"
    tt.hit_fx_only_no_target = true
    tt.image_width = 165.5
    tt.main_script.update = scripts.ray5_simple.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "hero_dragon_gem_breath_idle"
    tt.render.sprites[1].loop = false
    tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
    tt.track_target = false
    tt.ray_duration = fts(42)
    tt = E:register_t("bullet_hero_dragon_gem_crystal_totem", "bombKR5")
    tt.bullet.flight_time = fts(30)
    tt.bullet.align_with_trajectory = true
    tt.bullet.ignore_hit_offset = true
    tt.bullet.pop = nil
    tt.bullet.rotation_speed = nil
    tt.bullet.hit_payload = "aura_hero_dragon_gem_crystal_totem"
    tt.sound_events.hit = nil
    tt.sound_events.insert = nil
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].name = "hero_dragon_gem_conduit_projectile_idle"
    tt.bullet.hit_decal = nil
    tt.bullet.hit_fx = nil
    tt.bullet.damage_type = DAMAGE_EXPLOSION
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.g = -0.8 / (fts(1) * fts(1))
    tt = E:register_t("bullet_hero_dragon_gem_ultimate_shard", "bullet")
    tt.main_script.update = scripts.bullet_hero_dragon_gem_ultimate_shard.update
    tt.bullet.arrive_decal = "decal_bullet_hero_dragon_gem_ultimate_shard"
    tt.bullet.max_speed = 900
    tt.render.sprites[1].name = "hero_dragon_gem_ultimate_projectile"
    tt.render.sprites[1].animated = false
    tt = E:register_t("bullet_hero_bird", "bombKR5")

    local b = balance.heroes.hero_bird.basic_attack

    tt.bullet.damage_max = nil
    tt.bullet.damage_min = nil
    tt.bullet.damage_radius = b.damage_radius
    tt.bullet.flight_time = fts(30)
    tt.bullet.hit_fx = "fx_bullet_hero_bird"
    tt.bullet.hit_decal = "decal_bullet_hero_bird"
    tt.bullet.pop_chance = 0.5
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = 10 * FPS * math.pi / 180
    tt.bullet.xp_gain_factor = b.xp_gain_factor
    tt.main_script.update = scripts.bomb_KR5.update
    tt.sound_events.insert = "HeroBirdBasicAttackCast"
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "HeroBirdBasicAttackImpact"
    tt.render.sprites[1].name = "gryph_proy"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].hidden = false
    tt = E:register_t("bullet_hero_bird_cluster_bomb", "bombKR5")

    local b = balance.heroes.hero_bird.cluster_bomb

    tt.bullet.flight_time = fts(22)
    tt.bullet.hit_fx = "fx_bullet_hero_bird_cluster_bomb_air"
    tt.bullet.hit_decal = nil
    tt.bullet.particles_name = "ps_bullet_hero_bird_cluster_bomb"
    tt.bullet.pop_chance = 0
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = 0
    tt.bullet.hit_payload = "controller_bullet_hero_bird_cluster_bomb_part"
    tt.main_script.update = scripts.bomb_KR5.update
    tt.sound_events.insert = "HeroBirdBasicCarpetBombingCast"
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = nil
    tt.render.sprites[1].name = "gryph_skillproy_decl"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].hidden = false
    tt = E:register_t("controller_bullet_hero_bird_cluster_bomb_part")

    E:add_comps(tt, "main_script", "pos")

    local b = balance.heroes.hero_bird.cluster_bomb

    tt.main_script.update = scripts.controller_bullet_hero_bird_cluster_bomb_part.update
    tt.explosion_height = b.first_explosion_height
    tt.part_template = "bullet_hero_bird_cluster_bomb_part"
    tt = E:register_t("bullet_hero_bird_cluster_bomb_part", "bombKR5")

    local b = balance.heroes.hero_bird.cluster_bomb

    tt.bullet.damage_min = nil
    tt.bullet.damage_max = nil
    tt.bullet.damage_radius = b.explosion_damage_radius
    tt.bullet.damage_type = b.explosion_damage_type
    tt.bullet.flight_time = fts(25)
    tt.bullet.hit_fx = "fx_bullet_hero_bird_cluster_bomb"
    tt.bullet.hit_decal = nil
    tt.bullet.hit_payload = "aura_hero_bird_cluster_bomb_fire"
    tt.bullet.particles_name = "ps_bullet_hero_bird_cluster_bomb_part"
    tt.bullet.pop_chance = 0
    tt.bullet.align_with_trajectory = false
    tt.bullet.rotation_speed = 20 * FPS * math.pi / 180
    tt.main_script.update = scripts.bomb_KR5.update
    tt.sound_events.hit_water = nil
    tt.sound_events.hit = "HeroBirdBasicCarpetBombingImpact"
    tt.sound_events.insert = nil
    tt.render.sprites[1].name = "gryph_skillproy_part"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].hidden = false
    tt = E:register_t("bullet_stage_16_overseer_tentacle_spawn", "bombKR5")

    local b = balance.specials.stage16_overseer.tentacle_bullet_explosion_damage

    tt.bullet.flight_time = fts(31)
    tt.sound_events.hit_water = nil
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "overseer_fx_overseer_proyectile"
    tt.bullet.hit_fx = "fx_stage_16_overseer_tentacle_hit_decal"
    tt.bullet.hit_decal = "decal_stage_16_overseer_tentacle_projectile"
    tt.bullet.particles_name = "ps_bullet_stage_16_overseer_tentacle_spawn"
    tt.bullet.rotation_speed = 5
    tt.bullet.pop = nil
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.main_script.update = scripts.bullet_stage_16_overseer_tentacle_spawn.update
    tt.spawn_offset = {vec_2(-40, 0), vec_2(0, 20), vec_2(30, 0), vec_2(0, -30)}
    tt.explosion_damage = {}
    tt.explosion_damage.range = b.range
    tt.explosion_damage.vis_flags = bor(F_RANGED)
    tt.explosion_damage.vis_bans = bor(F_ENEMY)
    tt.explosion_damage.damage_type = b.damage_type
    tt.explosion_damage.damage_min = b.damage_min
    tt.explosion_damage.damage_max = b.damage_max
    tt.spawn_amounts_per_phase = balance.specials.stage16_overseer.tentacle_spawns_per_phase
    tt.sound_events.insert = nil
    tt.sound_events.hit = "Stage16OverseerSpawnerImpact"
    tt = E:register_t("bullet_stage_16_overseer_destroy_holders", "bullet")

    local b = balance.towers.arcane_wizard

    tt.bullet.damage_type = DAMAGE_NONE
    tt.bullet.damage_min = 0
    tt.bullet.damage_max = 0
    tt.bullet.hit_time = fts(2)
    tt.hit_fx_only_no_target = true
    tt.image_width = 381
    tt.main_script.update = scripts.ray5_simple.update
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].name = "overseer_fx_overseer_destroyray_loop"
    tt.render.sprites[1].loop = false
    tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
    tt.track_target = true
    tt.ray_duration = fts(26)
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
    tt = E:register_t("tunnel_KR5", "tunnel")
    tt.main_script.insert = scripts.tunnel_KR5.insert
    tt.main_script.update = scripts.tunnel_KR5.update
    tt.untargetable_distance = 10
    tt.flags_to_tag = {F_RANGED, F_BLOCK}
    tt = E:register_t("aura_hero_muyrn_faery_dust", "aura")

    E:add_comps(tt, "render")

    b = balance.heroes.hero_muyrn
    tt.aura.mods = {"mod_hero_muyrn_faery_dust", "mod_hero_muyrn_faery_dust_fx"}
    tt.aura.duration = fts(13)
    tt.aura.cycle_time = 0.3
    tt.aura.radius = b.faery_dust.radius
    tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
    tt.aura.vis_flags = bor(F_MOD)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.render.sprites[1].name = "hero_nyru_fairy_dust_decal"
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].anchor = vec_2(0.5, 0.8)
    tt = E:register_t("aura_hero_muyrn_ultimate", "aura")
    b = balance.heroes.hero_muyrn
    tt.aura.duration = nil
    tt.aura.cycle_time = 0.3
    tt.aura.radius = b.ultimate.radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.aura.mods = {"mod_hero_muyrn_ultimate", "mod_hero_muyrn_ultimate_damage"}
    tt.root_decal = "decal_hero_muyrn_root_defender_root"
    tt.roots_count = b.ultimate.roots_count
    tt.duration = b.ultimate.duration
    tt.main_script.insert = scripts.hero_muyrn_root_defender_aura.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.main_script.remove = scripts.hero_muyrn_root_defender_aura.remove
    tt.end_sound = "HeroNyruRootDefenderEnd"
    tt = E:register_t("aura_hero_muyrn_ultimate_sides", "aura_hero_muyrn_ultimate")
    tt.main_script.insert = scripts.hero_muyrn_root_defender_aura_sides.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.end_sound = "HeroNyruRootDefenderEnd"
    tt = E:register_t("aura_tower_arborean_emissary_gift_of_nature", "aura")
    b = balance.towers.arborean_emissary
    tt.aura.cycle_time = 0.3
    tt.aura.duration = nil
    tt.aura.mods = {"mod_tower_arborean_emissary_gift_of_nature_heal",
                    "mod_tower_arborean_emissary_gift_of_nature_heal_decal"}
    tt.aura.radius = b.gift_of_nature.radius
    tt.aura.track_source = false
    tt.aura.vis_flags = F_MOD
    tt.aura.vis_bans = bor(F_FLYING)
    tt.main_script.update = scripts.aura_tower_arborean_emissary_gift_of_nature.update
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt = E:register_t("aura_enemy_skunk_bombardier_death_explosion", "aura")
    b = balance.enemies.werebeasts.skunk_bombardier
    tt.aura.mod = "mod_enemy_skunk_bombardier_basic_attack"
    tt.aura.radius = b.ranged_attack.radius
    tt.aura.vis_flags = F_MOD
    tt.aura.vis_bans = bor(F_ENEMY)
    tt.aura.cycles = 1
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt = E:register_t("aura_boss_pig_damage_on_fall", "aura")
    b = balance.enemies.werebeasts.boss
    tt.aura.cycles = 1
    tt.aura.cycle_time = 0.3
    tt.aura.damage_min = b.fall.damage_min
    tt.aura.damage_max = b.fall.damage_max
    tt.aura.damage_type = DAMAGE_PHYSICAL
    tt.aura.track_source = true
    tt.aura.radius = b.fall.radius
    tt.aura.vis_bans = F_BOSS
    tt.aura.vis_flags = 0
    tt.main_script.update = scripts.aura_apply_damage.update
    tt = E:register_t("aura_hero_builder_demolition_man", "aura")
    b = balance.heroes.hero_builder.demolition_man
    tt.aura.duration = nil
    tt.aura.damage_min = nil
    tt.aura.damage_max = nil
    tt.aura.damage_type = b.damage_type
    tt.aura.track_source = true
    tt.aura.cycle_time = b.damage_every
    tt.aura.radius = b.radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.main_script.update = scripts.aura_apply_damage.update
    tt.aura.mods = {"mod_hero_builder_demolition_man_hit_fx"}
    tt = E:register_t("aura_hero_builder_ultimate", "aura")
    b = balance.heroes.hero_builder.ultimate
    tt.aura.cycles = 1
    tt.aura.cycle_time = 0.3
    tt.aura.damage_min = nil
    tt.aura.damage_max = nil
    tt.aura.damage_type = b.damage_type
    tt.aura.track_source = true
    tt.aura.radius = b.radius
    tt.aura.vis_bans = bor(F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.aura.mod = "mod_hero_builder_ultimate_stun"
    tt.main_script.update = scripts.aura_apply_damage.update

    tt = E:register_t("aura_stage_09_spawn_nightmare_convert", "aura")
    b = balance.specials.stage09_spawn_nightmares
    tt.aura.duration = 1e+99
    tt.aura.radius = 4
    tt.include_templates = {"enemy_lesser_sister_nightmare"}
    tt.entity_to_spawn = "enemy_armored_nightmare"
    tt.spawn_fx = "fx_stage_09_portal_path_spawn_fx"
    tt.portal_offset = vec_2(-15, 0)
    tt.main_script.update = scripts.aura_stage_09_spawn_nightmare_convert.update
    tt.wave_config = b.wave_config
    tt.sound_spawn = "EnemyTwistedSisterSummonSpawn"
    tt = E:register_t("aura_stage_09_spawn_nightmare_convert_spawn_fx", "aura")
    tt.aura.duration = 1e+99
    tt.aura.radius = 80
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.include_templates = {"enemy_lesser_sister_nightmare"}
    tt.main_script.update = scripts.aura_stage_09_spawn_nightmare_convert_spawn_fx.update
    tt = E:register_t("aura_tower_necromancer_skill_debuff", "aura")
    b = balance.towers.necromancer

    E:add_comps(tt, "render", "tween")

    tt.aura.enemy_mods = {"mod_tower_necromancer_curse"}
    tt.aura.soldier_mods = {"mod_tower_necromancer_skill_debuff_skeleton_improve"}
    tt.aura.radius = b.skill_debuff.radius
    tt.aura.enemy_vis_flags = bor(F_MOD)
    tt.aura.enemy_vis_bans = bor(F_FRIEND)
    tt.aura.soldier_vis_flags = bor(F_MOD)
    tt.aura.soldier_vis_bans = bor(F_ENEMY)
    tt.aura.duration = nil
    tt.aura.soldier_allowed_templates = {}

    for i = 1, 4 do
        table.insert(tt.aura.soldier_allowed_templates, "soldier_tower_necromancer_skeleton_lvl" .. i)
        table.insert(tt.aura.soldier_allowed_templates, "soldier_tower_necromancer_skeleton_golem_lvl" .. i)
    end

    tt.render.sprites[1].prefix = "necromancer_tower_mark_of_silence_totem"
    tt.render.sprites[1].animated = true
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "necromancer_tower_mark_of_silence_floorFX_idle"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_DECALS
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_tower_necromancer_skill_debuff.update
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt.tween.props[1].sprite_id = 2
    tt.tween.remove = false
    tt.sound_events.insert = "TowerNecromancerSigilOfSilence"
    tt.modifier_inflicted_damage_factor = b.skill_debuff.damage_factor
    tt.modifier_duration_config = b.skill_debuff.mod_duration
    tt = E:register_t("aura_tower_necromancer_skill_rider", "aura")
    b = balance.towers.necromancer.skill_rider

    E:add_comps(tt, "render", "tween", "motion")

    tt.aura.mod = "mod_tower_necromancer_skill_rider"
    tt.aura.radius = b.radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING)
    tt.aura.duration = b.duration
    tt.aura.cycle_time = fts(5)
    tt.render.sprites[1].prefix = "necromancer_tower_death_rider"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"walk_side", "walk_back", "walk_front"}
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_tower_necromancer_skill_rider.update
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.remove = false
    tt.motion.max_speed = b.speed
    tt.damage_min = nil
    tt.damage_max = nil
    tt.damage_min_config = b.damage_max
    tt.damage_max_config = b.damage_min
    tt.damage_type = b.damage_type
    tt.hit_fx = "fx_tower_necromancer_rider_hit"
    tt.spawn_side_fx = "fx_tower_necromancer_rider_spawn_side"
    tt.spawn_front_fx = "fx_tower_necromancer_rider_spawn_front"
    tt.spawn_back_fx = "fx_tower_necromancer_rider_spawn_back"
    tt.particles_name_A = "ps_tower_necromancer_rider_trail_A"
    tt.particles_name_B = "ps_tower_necromancer_rider_trail_B"
    tt.sound_events.insert = "TowerNecromancerDeathRider"
    tt = E:register_t("aura_bullet_tower_ballista_skill_bomb", "aura")
    b = balance.towers.ballista.skill_bomb

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_bullet_tower_ballista_skill_bomb_slow"
    tt.aura.radius = 35
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.duration = nil
    tt.aura.cycle_time = fts(5)
    tt.aura.excluded_templates = {}
    tt.render.sprites[1].prefix = "ballista_tower_bomb_decal"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_bullet_tower_ballista_skill_bomb.update
    tt.damage_min = 0
    tt.damage_max = 0
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].sprite_id = 1
    tt.junk_fx = "fx_bullet_tower_ballista_bomb_junk_floor"
    tt = E:register_t("aura_tower_flamespitter", "aura")
    b = balance.towers.flamespitter.basic_attack
    tt.aura.duration = b.duration
    tt.aura.radius = 60
    tt.aura.vis_bans = bor(F_FRIEND)
    tt.aura.vis_flags = bor(F_RANGED, F_AREA)
    tt.aura.mod = "mod_burning_tower_flamespitter"
    tt.aura.damage_type = b.damage_type
    tt.aura.cycle_time = b.cycle_time
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_tower_flamespitter.update
    tt.damage_min_config = b.damage_min
    tt.damage_max_config = b.damage_max
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
    tt.render.sprites[1].offset = vec_2(0, 5)
    tt.render.sprites[1].scale = vec_1(1.25)
    tt = E:register_t("aura_bullet_tower_barrel_skill_barrel", "aura")

    E:add_comps(tt, "render", "tween")

    b = balance.towers.barrel.skill_barrel
    tt.aura.duration = b.duration
    tt.aura.duration_inc = nil
    tt.aura.radius = b.radius
    tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.mods = {"mod_tower_barrel_skill_barrel_poison", "mod_tower_barrel_skill_barrel_slow"}
    tt.aura.cycle_time = fts(10)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_bullet_tower_barrel_skill_barrel.update
    tt.render.sprites[1].prefix = "barrel_tower_lvl4_bad_barrel_decal"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "barrel_tower_lvl4_bad_barrel"
    tt.render.sprites[2].name = "start"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "barrel_tower_lvl4_bad_barrel_bubbles_fx"
    tt.render.sprites[3].name = "loop"
    tt.render.sprites[3].animated = true
    tt.render.sprites[3].z = Z_EFFECTS
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 255}, {fts(18), 0}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].name = "alpha"
    tt.tween.props[2].keys = {{0, 255}, {fts(18), 0}}
    tt.tween.props[2].sprite_id = 3
    tt.tween.remove = true
    tt.tween.disabled = true
    tt.explosion_decal = "decal_aura_bullet_tower_barrel_skill_barrel_explosion"
    tt.explosion_damage_min = b.explosion.damage_min
    tt.explosion_damage_max = b.explosion.damage_max
    tt.explosion_damage_type = b.explosion.damage_type
    tt.explosion_damage_radius = b.explosion.damage_radius
    tt.explosion_vis_bans = bor(F_FRIEND, F_FLYING)
    tt.explosion_vis_flags = bor(F_AREA)
    tt.explosion_sfx = "TowerBarrelBadBatchExplosion"
    tt.sid_barrel = 2
    tt = E:register_t("aura_tower_sand_skill_big_blade", "aura")

    E:add_comps(tt, "render")

    b = balance.towers.sand.skill_big_blade
    tt.aura.duration = b.duration[1]
    tt.aura.radius = b.radius
    tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.mod = "mod_tower_sand_skill_big_blade_slow"
    tt.aura.cycle_time = b.damage_every
    tt.aura.damage_min = nil
    tt.aura.damage_max = nil
    tt.aura.damage_type = b.damage_type
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_tower_sand_skill_big_blade.update
    tt.render.sprites[1].prefix = "tower_sand_lvl4_skill_2_projectile"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_BULLETS
    tt.fixed_speed = FPS * 8
    tt.particles_name = "ps_aura_tower_sand_skill_big_blade"
    tt.hit_fx = "fx_aura_tower_sand_skill_big_blade"
    tt = E:register_t("aura_fire_balls_hero_lumenir", "aura")

    E:add_comps(tt, "render", "nav_path", "motion", "tween")

    b = balance.heroes.hero_lumenir.fire_balls
    tt.aura.duration = b.duration
    tt.aura.duration_var = 0.5
    tt.flame_damage_min = b.flame_damage_min
    tt.flame_damage_max = b.flame_damage_max
    tt.aura.damage_radius = b.damage_radius
    tt.aura.damage_type = DAMAGE_TRUE
    tt.aura.damage_cycle = b.damage_rate
    tt.aura.damage_flags = F_AREA
    tt.aura.damage_bans = 0
    tt.motion.max_speed = 3.5 * FPS
    tt.motion.max_speed_var = 0.25 * FPS
    tt.main_script.insert = scripts.aura_fire_balls_hero_lumenir.insert
    tt.main_script.update = scripts.aura_fire_balls_hero_lumenir.update
    tt.render.sprites[1].name = "hero_lumenir_radiant_wave_projectile_idle"
    tt.render.sprites[1].sort_y_offset = -21
    tt.render.sprites[1].z = Z_OBJECTS
    tt.tween.disabled = true
    tt.tween.remove = true
    tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration_var, 0}}
    tt = E:register_t("aura_bullet_hero_mecha_tar_bomb", "aura")
    b = balance.heroes.hero_mecha.tar_bomb

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_bullet_hero_mecha_tar_bomb_slow"
    tt.aura.radius = 60
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.cycle_time = fts(5)
    tt.render.sprites[1].name = "hero_onagro_skill_2_decal"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = false
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].sprite_id = 1
    tt.tween.props[1].keys = {{0, 255}, {tt.aura.duration - 0.5, 255}, {tt.aura.duration, 0}}
    tt = E:register_t("aura_bullet_hero_mecha_mine", "aura")
    b = balance.heroes.hero_mecha.mine_drop

    E:add_comps(tt, "render")

    tt.aura.radius = b.damage_radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans_trigger = bor(F_FLYING)
    tt.aura.vis_bans_damage = 0
    tt.aura.cycle_time = fts(5)
    tt.render.sprites[1].prefix = "hero_onagro_skill_4_mine"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = false
    tt.main_script.insert = scripts.aura_bullet_hero_mecha_mine.insert
    tt.main_script.update = scripts.aura_bullet_hero_mecha_mine.update
    tt.explosion_fx = "fx_hero_mecha_mine_explosion"
    tt.sound_explode = "HeroMechaMineDropExplosion"
    tt.damage_type = b.damage_type
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
    tt = E:register_t("aura_upgrade_alliance_seal_of_punishment", "aura")
    b = balance.upgrades.alliance_seal_of_punishment

    E:add_comps(tt)

    tt.aura.duration = b.duration
    tt.aura.cycle_time = fts(5)
    tt.aura.radius = b.radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FRIEND)
    tt.aura.damage_min = b.damage_min
    tt.aura.damage_max = b.damage_max
    tt.aura.damage_type = DAMAGE_TRUE
    tt.aura.mod = "mod_upgrade_alliance_seal_of_punishment"
    tt.main_script.update = scripts.aura_apply_damage.update
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
    tt = E:register_t("aura_hero_venom_ultimate", "aura")
    b = balance.heroes.hero_venom.ultimate

    E:add_comps(tt, "render")

    tt.aura.mod = "mod_hero_venom_ultimate_slow"
    tt.aura.radius = b.radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.cycle_time = fts(5)
    tt.aura.duration = nil
    tt.render.sprites[1].prefix = "hero_venom_ultimate"
    tt.render.sprites[1].name = "in"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = false
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_hero_venom_ultimate.update
    tt.slow_delay = b.slow_delay
    tt.end_damage_min = nil
    tt.end_damage_max = nil
    tt.end_damage_type = b.damage_type
    tt.sound_attack = "HeroVenomRenewCreepingDeathSpikes"
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
    tt.render.sprites[1].name = "rally_circle_full"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].scale = vec_1(1)
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
    tt.render.sprites[1].anchor = vec_2(0.5, 0.75)
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt = E:register_t("aura_enemy_blinker", "aura")
    b = balance.enemies.void_beyond.blinker.ranged_attack

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_enemy_blinker_stun"
    tt.aura.radius = b.radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
    tt.aura.cycle_time = b.stun_every
    tt.aura.duration = b.duration
    tt.aura.track_source = false
    tt.render.sprites[1].prefix = "blinker_stun_decal"
    tt.render.sprites[1].name = "Idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].anchor = vec_2(0.5, 0.9)
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt = E:register_t("aura_enemy_blinker_glare", "aura_enemy_blinker")
    tt.aura.mods = {"mod_enemy_blinker_stun", "mod_enemy_blinker_glare"}
    tt.render.sprites[1].prefix = "blinker_glare_decal"
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
    tt = E:register_t("aura_hero_robot_skill_jump", "aura")
    b = balance.heroes.hero_robot.jump

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_hero_robot_skill_jump"
    tt.aura.radius = b.radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.duration = fts(22)
    tt.render.sprites[1].prefix = "Blaze_skill1y3decal"
    tt.render.sprites[1].name = "run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].scale = vec_2(1.1, 1.1)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "Blaze_skill1humito"
    tt.render.sprites[2].name = "run"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].loop = false
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 255}, {fts(18), 255}, {fts(22), 0}}
    tt.tween.props[1].sprite_id = 1
    tt = E:register_t("aura_hero_robot_skill_fire_slow", "aura")
    b = balance.heroes.hero_robot.fire

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_hero_robot_skill_fire_slow"
    tt.aura.radius = 20
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FRIEND)
    tt.aura.duration = nil
    tt.aura.cycle_time = fts(1)
    tt.aura.track_source = true
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_hero_robot_skill_fire_slow.update
    tt.render.sprites[1].prefix = "Blaze_skill2humo"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].z = Z_OBJECTS_COVERS
    tt.render.sprites[1].scale = vec_2(1.3, 1.3)
    tt.tween.remove = false
    tt = E:register_t("aura_hero_robot_ultimate_train", "aura")
    b = balance.heroes.hero_robot.ultimate

    E:add_comps(tt, "render", "tween", "nav_rally", "motion")

    tt.render.sprites[1].prefix = "Blaze_tren"
    tt.render.sprites[1].name = "box"
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.run = {"downright", "right", "upright", "up", "down"}
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt.tween.props[1].sprite_id = 1
    tt.tween.remove = false
    tt.main_script.update = scripts.aura_hero_robot_ultimate_train.update
    tt.motion.max_speed = b.speed
    tt.aura.duration = b.duration
    tt.aura.vis_bans = bor(F_FLYING)
    tt.aura.vis_flags = bor(F_RANGED)
    tt.aura.radius = b.radius
    tt.aura.mod = "mod_hero_robot_skill_ultimate_burning"
    tt.spawn_fx = "fx_hero_robot_ultimate_train_spawn"
    tt.damage_min = nil
    tt.damage_max = nil
    tt.damage_type = b.damage_type
    tt.floor_decal = "decal_hero_robot_ultimate_floor"
    tt.smoke_fx = "fx_hero_robot_ultimate_smoke"
    tt.hit_fx = "fx_hero_robot_skill_fire"
    tt.nodes_to_floor_decal = 5
    tt.nodes_to_smoke = 3
    tt.sound = "HeroRobotMotorheadCast"

    tt = E:register_t("aura_hero_dragon_gem_skill_stun", "aura")
    b = balance.heroes.hero_dragon_gem.stun
    tt.aura.mod = "mod_hero_dragon_gem_skill_stun"
    tt.aura.radius = b.stun_radius
    tt.aura.vis_flags = bor(F_AREA)
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.surround_fx = "fx_hero_dragon_gem_skill_stun"
    tt.aura.duration = fts(1)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_hero_dragon_gem_skill_stun.update
    tt = E:register_t("aura_hero_dragon_gem_crystal_totem", "aura")
    b = balance.heroes.hero_dragon_gem.crystal_totem

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_hero_dragon_gem_crystal_totem_slow"
    tt.aura.radius = b.aura_radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.aura.cycle_time = b.trigger_every
    tt.aura.duration = nil
    tt.render.sprites[1].prefix = "hero_dragon_gem_conduit"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].scale = vec_2(0.7, 0.7)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_hero_dragon_gem_crystal_totem.update
    tt.damage_range = b.aura_radius
    tt.damage_bans = bor(F_FLYING)
    tt.damage_min = nil
    tt.damage_max = nil
    tt.damage_type = DAMAGE_MAGICAL
    tt.tween.props[1].keys = {{0, 255}, {fts(15), 0}}
    tt.tween.disabled = true
    tt.floor_decal = "decal_hero_dragon_gem_floor_circle_totem"
    tt.pulse_sound = "HeroDragonGemPowerConduitCrystal"
    tt = E:register_t("aura_controller_stage_14_amalgam", "aura")
    tt.aura.duration = 1e+99
    tt.aura.cycle_time = 0.25
    tt.aura.radius = 170
    tt.aura.allowed_templates = {"enemy_glareling"}
    tt.main_script.update = scripts.aura_controller_stage_14_amalgam.update
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
    tt.render.sprites[2].offset = vec_2(0, 13)
    tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[3].offset = vec_2(22, 0)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[4].offset = vec_2(0, -13)
    tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[5].offset = vec_2(-22, 0)
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
    tt = E:register_t("aura_hero_bird_cluster_bomb_fire", "aura")
    b = balance.heroes.hero_bird.cluster_bomb

    E:add_comps(tt, "render", "tween")

    tt.aura.mod = "mod_hero_bird_cluster_bomb_burn"
    tt.aura.radius = b.fire_radius
    tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.aura.cycle_time = 0.2
    tt.aura.duration = nil
    tt.render.sprites[1].name = "gryph_skillproy_fire_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].anchor = vec_2(0.5, 0.45)
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[1].scale = vec_1(1.2)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "gryph_skillproy_fireparticles_run"
    tt.render.sprites[2].animated = true
    tt.render.sprites[2].loop = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[2].scale = vec_1(1.3)
    tt.main_script.insert = scripts.aura_apply_mod.insert
    tt.main_script.update = scripts.aura_apply_mod.update
    tt.main_script.remove = scripts.aura_hero_bird_cluster_bomb_fire.remove
    tt.tween.props[1].keys = {{0, 0}, {fts(3), 255}}
    tt.tween.props[2] = E:clone_c("tween_prop")
    tt.tween.props[2].keys = {{0, 0}, {fts(3), 255}}
    tt.tween.props[2].sprite_id = 2
    tt.tween.disabled = false
    tt.tween.remove = false
    tt = E:register_t("aura_item_loot_box_damage", "aura")
    b = balance.items.loot_box
    tt.aura.cycles = 1
    tt.aura.cycle_time = 0.3
    tt.aura.damage_min = b.damage_min
    tt.aura.damage_max = b.damage_max
    tt.aura.damage_type = b.damage_type
    tt.aura.track_source = true
    tt.aura.radius = b.radius
    tt.aura.vis_bans = bor(F_FRIEND)
    tt.aura.vis_flags = F_RANGED
    tt.main_script.update = scripts.aura_apply_damage.update
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
    tt.render.sprites[1].scale = vec_2(1, 1)
    tt.render.sprites[1].sort_y_offset = -3
    tt.main_script.insert = scripts.trees_guardian_tree_vine_mod.insert
    tt.main_script.remove = scripts.trees_guardian_tree_vine_mod.remove
    tt.main_script.update = scripts.trees_guardian_tree_vine_mod.update
    tt = E:register_t("mod_cutthroat_rat_bleed", "mod_blood")
    b = balance.enemies.werebeasts.cutthroat_rat
    tt.dps.damage_min = b.gut_stab.bleed_damage_min
    tt.dps.damage_max = b.gut_stab.bleed_damage_max
    tt.dps.damage_inc = 0
    tt.dps.damage_every = b.gut_stab.bleed_every
    tt.dps.fx_every = fts(20)
    tt.modifier.duration = b.gut_stab.bleed_duration
    tt = E:register_t("mod_hero_lumenir_sword_hit", "modifier")

    E:add_comps(tt, "render")

    b = balance.heroes.hero_lumenir.celestial_judgement
    tt.modifier.duration = fts(39)
    tt.render.sprites[1].name = "hero_lumenir_celestial_judgement_fx_idle"
    tt.render.sprites[1].draw_order = 10
    tt.render.sprites[1].loop = false
    tt.mod_stun = "mod_hero_lumenir_stun"
    tt.hit_decal = "decal_hero_lumenir_sword"
    tt.decal_spawn_time = fts(25)
    tt.time_hit = fts(22)
    tt.damage = b.damage
    tt.stun_duration = b.stun_duration
    tt.damage_type = b.damage_type
    tt.stun_range = b.stun_range
    tt.stun_vis_flags = F_RANGED
    tt.stun_bans = bor(F_FLYING)
    tt.main_script.update = scripts.mod_hero_lumenir_sword_hit.update
    tt.sound = "HeroLumenirCelestialJudgementImpact"
    tt = E:register_t("mod_hero_lumenir_stun", "mod_stun")

    E:add_comps(tt, "render")

    tt.modifier.duration = fts(23)
    tt = E:register_t("mod_hero_dragon_shield", "modifier")

    E:add_comps(tt, "render", "tween")

    tt.modifier.duration = nil
    tt.spiked_armor = nil
    tt.armor = nil
    tt.main_script.insert = scripts.mod_hero_lumenir_shield.insert
    tt.main_script.update = scripts.mod_hero_lumenir_shield.update
    tt.main_script.remove = scripts.mod_hero_lumenir_shield.remove
    tt.render.sprites[1].prefix = "hero_lumenir_blessing_of_retribution_shield"
    tt.render.sprites[1].size_names = {"small", "mid", "big"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "hero_lumenir_blessing_of_retribution_shield_decal"
    tt.render.sprites[2].size_names = {"small", "mid", "big"}
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].z = Z_DECALS
    tt.tween.remove = false
    tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
    tt = E:register_t("mod_lumenir_ulti_stun", "mod_stun")
    b = balance.heroes.hero_lumenir
    tt.modifier.duration = b.ultimate.stun_target_duration
    tt.modifier.allows_duplicates = true
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_hero_vesper_martial_flourish_fx", "modifier")

    E:add_comps(tt, "render")

    tt.modifier.duration = fts(23)
    tt.render.sprites[1].name = "hero_vesper_martial_flourish_hit"
    tt.render.sprites[1].draw_order = 10
    tt.render.sprites[1].loop = false
    tt.main_script.update = scripts.mod_track_target.update
    tt = E:register_t("mod_tower_elven_stargazers_ray_hit", "modifier")

    AC(tt, "render")

    b = balance.towers.elven_stargazers
    tt.modifier.damage_min = nil
    tt.modifier.damage_max = nil
    tt.damage_type = DAMAGE_MAGICAL
    tt.main_script.update = scripts.mod_ray_stargazers.update
    tt.modifier.duration = fts(10)
    tt.modifier.allows_duplicates = true
    tt.modifier.use_mod_offset = true
    tt.render.sprites[1].name = "elven_stargazers_tower_ray_end_end"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.damage_from_bullet = true
    tt = E:register_t("mod_tower_elven_stargazers_star_death", "modifier")
    b = balance.towers.elven_stargazers
    tt.main_script.update = scripts.mod_stargazers_stars_death.update
    tt.modifier.duration = fts(10)
    tt.modifier.allows_duplicates = false
    tt.modifier.use_mod_offset = true
    tt.modifier.bullet = "arrow_tower_stargazers_death_star"
    tt.modifier.stars_death_min_range = b.stars_death.min_range
    tt.modifier.stars_death_max_range = b.stars_death.max_range
    tt.modifier.stars_death_chance = b.stars_death.chance
    tt.modifier.stars_death_stars = b.stars_death.stars
    tt = E:register_t("mod_tower_arcane_wizard_power_empowerment", "modifier")
    tt.main_script.insert = scripts.mod_tower_factors.insert
    tt.main_script.remove = scripts.mod_tower_arcane_wizard_power_empowerment.remove
    tt.main_script.update = scripts.mod_tower_arcane_wizard_power_empowerment.update
    tt.range_factor = 1
    tt.damage_factor = nil
    tt.modifier.duration = 1e+99
    tt.modifier.use_mod_offset = false
    tt = E:register_t("mod_tower_arcane_wizard_power_empowerment_fx", "modifier")

    E:add_comps(tt, "render", "tween")

    tt.main_script.update = scripts.tower_arcane_wizard_power_empowerment_mark_mod.update
    tt.modifier.duration = 1e+99
    tt.modifier.use_mod_offset = false
    tt.modifier.keep_on_tower_upgrade = true
    tt.render.sprites[1].name = "arcane_wizard_tower_empowerment_decal"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_TOWER_BASES + 1
    tt.render.sprites[1].offset.y = 5
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].draw_order = 11
    tt.render.sprites[2].name = "arcane_wizard_tower_empowerment_particles_idle"
    tt.render.sprites[2].loop = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[2].offset.y = 5
    tt.tween.props[1].name = "alpha"
    tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
    tt.tween.remove = false
    tt.sound_events.insert = "TowerArcaneWizardEmpowerment"
    tt = E:register_t("tower_arcane_wizard_power_empowerment_mark_mod", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_CUSTOM
    tt.main_script.update = scripts.tower_arcane_wizard_power_empowerment_mark_mod.update
    tt.modifier.allows_duplicates = true
    tt.modifier.duration = 1e+99
    tt = E:register_t("mod_tower_arcane_wizard_ray_hit", "modifier")

    AC(tt, "render", "dps")

    b = balance.towers.arcane_wizard
    tt.damage_min = b.basic_attack.damage_min
    tt.damage_max = b.basic_attack.damage_max
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_ONE_SHIELD_HIT)
    tt.dps.damage_every = b.basic_attack.damage_every
    tt.dps.pop = {"pop_zap_arcane"}
    tt.dps.pop_conds = DR_KILL
    tt.main_script.update = scripts.mod_ray_arcane.update
    tt.modifier.duration = fts(10)
    tt.modifier.allows_duplicates = true
    tt.modifier.use_mod_offset = true
    tt.render.sprites[1].name = "arcane_wizard_tower_ray_end_idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.damage_from_bullet = true
    tt = E:register_t("mod_hero_muyrn_faery_dust", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = nil
    tt.modifier.duration = nil
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].name = "hero_nyru_fairy_dust_modifier"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("mod_hero_muyrn_faery_dust_fx", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_hero_muyrn_faery_dust_fx.insert
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = nil
    tt.modifier.duration = nil
    tt.modifier.use_mod_offset = false
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].name = "hero_nyru_fairy_dust_FX"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].size_scales = {vec_1(0.9), vec_1(1), vec_1(1)}
    tt = E:register_t("mod_hero_muyrn_ultimate", "mod_slow")
    tt.modifier.duration = 1
    tt.slow.factor = nil
    tt = E:register_t("mod_hero_muyrn_ultimate_damage", "modifier")
    b = balance.heroes.hero_muyrn

    E:add_comps(tt, "dps")

    tt.modifier.duration = 1
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = b.ultimate.damage_type
    tt.dps.damage_every = b.ultimate.damage_every
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt = E:register_t("mod_tower_arborean_emissary_gift_of_nature_heal", "modifier")
    b = balance.towers.arborean_emissary

    E:add_comps(tt, "render", "hps")

    tt.heal_min = b.gift_of_nature.heal_min
    tt.heal_max = b.gift_of_nature.heal_max
    tt.duration = b.gift_of_nature.duration
    tt.hps.heal_min = nil
    tt.hps.heal_max = nil
    tt.hps.heal_every = b.gift_of_nature.heal_every
    tt.main_script.insert = scripts.tower_arborean_emissary_gift_of_nature_heal_mod.insert
    tt.main_script.update = scripts.mod_hps.update
    tt.modifier.duration = nil
    tt.render.sprites[1].name = "arborean_emissary_gift_of_nature_heal"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].animated = true
    tt.modifier.vis_bans = bor(F_ENEMY)
    tt.modifier.resets_same = false
    tt = E:register_t("mod_tower_arborean_emissary_gift_of_nature_heal_decal", "modifier")
    b = balance.towers.arborean_emissary

    E:add_comps(tt, "render")

    tt.duration = b.gift_of_nature.duration
    tt.main_script.insert = scripts.tower_arborean_emissary_gift_of_nature_heal_mod_decal.insert
    tt.main_script.update = scripts.mod_track_fx.update
    tt.modifier.duration = nil
    tt.render.sprites[1].name = "arborean_emissary_gift_of_nature_heal_glow"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].animated = true
    tt.modifier.vis_bans = bor(F_ENEMY)
    tt.modifier.use_mod_offset = false
    tt.modifier.resets_same = false
    tt = E:register_t("mod_tower_arborean_emissary_gift_of_nature_totem_inflicted_damage", "modifier")
    b = balance.towers.arborean_emissary
    tt.modifier_duration = b.basic_attack.modifier_duration
    tt.inflicted_damage_factor_config = b.gift_of_nature.inflicted_damage_factor
    tt.modifier.duration = nil
    tt.main_script.insert = scripts.mod_arborean_emissary_weak.insert
    tt.main_script.remove = scripts.mod_arborean_emissary_weak.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.vis_flags = F_MOD
    tt.inflicted_damage_factor = nil
    tt = E:register_t("mod_tower_arborean_emissary_basic_attack", "modifier")
    b = balance.towers.arborean_emissary

    E:add_comps(tt, "render")

    tt.received_damage_factor_config = b.basic_attack.received_damage_factor
    tt.modifier_duration = b.basic_attack.modifier_duration
    tt.modifier.duration = nil
    tt.main_script.insert = scripts.mod_arborean_emissary_weak.insert
    tt.main_script.remove = scripts.mod_arborean_emissary_weak.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.vis_flags = F_MOD
    tt.modifier.type = MOD_TYPE_POISON
    tt.inflicted_damage_factor = nil
    tt.received_damage_factor = nil
    tt.render.sprites[1].name = "arborean_emissary_basic_attack_modifier"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[1].size_names = {"arborean_emissary_basic_attack_modifier",
                                       "arborean_emissary_basic_attack_modifier",
                                       "arborean_emissary_basic_attack_modifier_big"}
    tt = E:register_t("mod_enemy_skunk_bombardier_basic_attack", "modifier")
    b = balance.enemies.werebeasts.skunk_bombardier

    E:add_comps(tt, "render")

    tt.modifier.duration = b.ranged_attack.mod_duration
    tt.received_damage_factor = b.ranged_attack.received_damage_factor
    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.vis_flags = F_MOD
    tt.render.sprites[1].name = "skunk_bombardier_modifier_modifier"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("mod_enemy_rhino_charge_enemy", "modifier")
    b = balance.enemies.werebeasts.rhino

    E:add_comps(tt, "dps", "render")

    tt.dps.damage_min = b.charge.damage_enemy_min
    tt.dps.damage_max = b.charge.damage_enemy_max
    tt.dps.damage_type = b.charge.damage_type
    tt.dps.damage_every = fts(10)
    tt.modifier.duration = fts(7)
    tt.modifier.use_mod_offset = true
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt.render.sprites[1].name = "razing_rhino_razing_rhino_charge_hit_fx"
    tt.render.sprites[1].loop = false
    tt = E:register_t("mod_enemy_rhino_charge_soldier", "mod_enemy_rhino_charge_enemy")
    b = balance.enemies.werebeasts.rhino
    tt.dps.damage_min = b.charge.damage_soldier_min
    tt.dps.damage_max = b.charge.damage_soldier_max
    tt = E:register_t("mod_hero_builder_lunch_break", "modifier")
    tt.heal_hp = nil
    tt.main_script.insert = scripts.mod_hero_builder_lunch_break.insert
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.bans = {}
    tt.modifier.duration = 1
    tt = E:register_t("mod_hero_builder_ultimate_stun", "mod_stun")
    tt.modifier.duration = nil
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_hero_builder_demolition_man_hit_fx", "modifier")

    E:add_comps(tt, "render")

    tt.render.sprites[1].name = "hero_obdul_skill_3_hit"
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.remove = scripts.mod_track_target.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.duration = fts(7)
    tt = E:register_t("mod_tower_stargazers_teleport_stun", "mod_stun")
    tt.modifier.duration = 5
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt.render.sprites[1] = nil
    tt = E:register_t("mod_tower_stargazers_death_star_stun", "mod_stun")
    b = balance.towers.elven_stargazers.stars_death
    tt.modifier.duration = b.stun
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt.render.sprites[1] = nil
    tt = E:register_t("mod_enemy_unblinded_abomination_eat", "modifier")
    b = balance.enemies.cult_of_the_overseer.unblinded_priest
    tt.main_script.queue = scripts.mod_enemy_unblinded_abomination_eat.queue
    tt.main_script.update = scripts.mod_enemy_unblinded_abomination_eat.update
    tt.explode_fx = "fx_enemy_unblinded_abomination_eat"
    tt.required_hp = b.abomination.eat.hp_required

    tt = E:register_t("mod_upgrade_desperate_effort", "modifier")
    b = balance.upgrades.heroes_desperate_effort
    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = b.damage_factor
    tt.modifier.duration = b.duration
    tt = E:register_t("mod_upgrade_visual_learning", "modifier")
    b = balance.upgrades.heroes_visual_learning
    tt.main_script.insert = scripts.mod_upgrade_visual_learning.insert
    tt.main_script.remove = scripts.mod_upgrade_visual_learning.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.duration = b.duration
    tt.armor_bonus = b.armor_bonus
    tt = E:register_t("mod_upgrade_lone_wolves", "modifier")
    b = balance.upgrades.heroes_lone_wolves
    tt.main_script.insert = scripts.mod_upgrade_lone_wolves.insert
    tt.main_script.remove = scripts.mod_upgrade_lone_wolves.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.xp_gain_factor = b.xp_gain_factor
    tt.modifier.duration = b.duration
    tt = E:register_t("mod_soldier_tower_demon_pit_explosion", "mod_stun")
    tt.modifier.duration = nil
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_tower_demon_pit_master_explosion_burning", "modifier")
    b = balance.towers.demon_pit.master_exploders

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = nil
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = b.damage_type
    tt.dps.damage_every = b.damage_every
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "fire"
    tt.render.sprites[1].name = "small"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
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
    tt.main_script.update = scripts.mod_enemy_unblinded_shackler_mark.update
    tt = E:register_t("mod_soldier_tower_rocket_gunners_sting_missiles_target", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.update = scripts.mod_soldier_tower_rocket_gunners_sting_missiles_target.update
    tt.modifier.use_mod_offset = true
    tt.modifier.duration = 1e+99
    tt.render.sprites[1].prefix = "rocket_gunners_tower_reticle"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("mod_soldier_tower_rocket_gunners_sting_missiles_mark", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_CUSTOM
    tt.main_script.queue = scripts.mod_mark_flags.queue
    tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
    tt.main_script.update = scripts.mod_mark_flags.update
    tt = E:register_t("mod_tower_necromancer_curse", "modifier")
    b = balance.towers.necromancer.curse

    E:add_comps(tt, "render")

    tt.modifier.duration = b.duration
    tt.main_script.insert = scripts.mod_tower_necromancer_curse.insert
    tt.main_script.remove = scripts.mod_tower_necromancer_curse.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.modifier.vis_flags = F_MOD
    tt.render.sprites[1].name = "necromancer_tower_curse_idle"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].name = "necromancer_tower_curse_decal"
    tt.render.sprites[2].z = Z_DECALS
    tt.render.sprites[2].animated = false
    tt.skeleton_prefix = "soldier_tower_necromancer_skeleton_lvl"
    tt.skeleton_golem_prefix = "soldier_tower_necromancer_skeleton_golem_lvl"
    tt.sprite_small = "necromancer_tower_curse_idle"
    tt.sprite_big = "necromancer_tower_curse_big_idle"
    tt.decal_small = "necromancer_tower_curse_decal"
    tt.decal_big = "necromancer_tower_curse_decal_big"
    tt.excluded_templates = {"enemy_acolyte_tentacle", "enemy_lesser_sister_nightmare", "enemy_spiderling",
                             "enemy_armored_nightmare", "enemy_glareling"}
    tt.excluded_templates_golem = {""}
    tt = E:register_t("mod_tower_necromancer_skill_debuff", "modifier")
    b = balance.towers.necromancer
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.modifier.duration = nil
    tt.modifier.duration_config = b.skill_debuff.mod_duration
    tt.main_script.insert = scripts.mod_tower_necromancer_skill_debuff.insert
    tt.main_script.update = scripts.mod_tower_necromancer_skill_debuff.update
    tt.main_script.remove = scripts.mod_tower_necromancer_skill_debuff.remove
    tt = E:register_t("mod_tower_necromancer_skill_debuff_skeleton_improve", "modifier")
    b = balance.towers.necromancer
    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt = E:register_t("mod_tower_necromancer_skill_rider", "modifier")
    b = balance.towers.necromancer.skill_rider
    tt.modifier.duration = 3
    tt.modifier.allows_duplicates = true
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.update = scripts.mod_track_target.update
    tt.main_script.remove = scripts.mod_track_target.remove
    tt = E:register_t("mod_bullet_tower_ballista_skill_final_shot_stun", "mod_stun")
    b = balance.towers.ballista.skill_final_shot
    tt.modifier.duration = fts(b.stun_time)
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_bullet_tower_ballista_skill_bomb_slow", "mod_slow")
    b = balance.towers.ballista.skill_bomb
    tt.slow.factor = 0.5
    tt.modifier.duration = 0.5
    tt = E:register_t("mod_bullet_hero_mecha_tar_bomb_slow", "mod_slow")
    b = balance.heroes.hero_mecha.tar_bomb
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = 0.5
    tt = E:register_t("mod_hero_mecha_power_slam_stun", "mod_stun")
    b = balance.heroes.hero_mecha.power_slam
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS, F_FLYING)
    tt = E:register_t("mod_stage_10_obelisk_stun", "mod_stun")
    tt.render.sprites[1].prefix = "stage10_obelisk_stunfx"
    tt.render.sprites[1].size_names = {"normal", "big", "big"}
    tt.prefix_flying = "stage10_obelisk_stunfx_volador"
    tt.modifier.animation_phases = true
    tt.modifier.use_mod_offset = false
    tt.main_script.update = scripts.mod_stage_10_obelisk_stun.update
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
    tt = E:register_t("mod_enemy_stage_11_cult_leader_illusion_shield_denas",
        "mod_enemy_stage_11_cult_leader_illusion_shield")
    tt.render.sprites[1].prefix = "mydrias_areaskill_status_Denas"
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "mydrias_areaskill_status_Denas_decal"
    tt.render.sprites[2].z = Z_DECALS
    tt = E:register_t("mod_upgrade_alliance_display_of_true_might_dark_army", "mod_slow")

    E:add_comps(tt, "render")

    b = balance.upgrades.alliance_display_of_true_might_dark
    tt.slow.factor = b.slowdown_factor
    tt.modifier.duration = b.slowdown_duration
    tt.modifier.vis_flags = bor(F_MOD)
    tt.main_script.insert = scripts.mod_upgrade_alliance_display_of_true_might_dark_army.insert
    tt.render.sprites[1].prefix = "display_of_true_might"
    tt.render.sprites[1].size_names = {"slow", "slow_big", "slow_big"}
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].size_names = {"display_of_true_might_slow_deco", "display_of_true_might_slow_big_deco",
                                       "display_of_true_might_slow_big_deco"}
    tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].z = Z_DECALS
    tt = E:register_t("mod_upgrade_alliance_display_of_true_might_linirea", "modifier")

    E:add_comps(tt, "render", "tween")

    b = balance.upgrades.alliance_display_of_true_might_linirea
    tt.modifier.duration = fts(44)
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.update = scripts.mod_upgrade_alliance_display_of_true_might_linirea.update
    tt.main_script.remove = scripts.mod_track_target.remove
    tt.render.sprites[1].prefix = "display_of_true_might_heal"
    tt.render.sprites[1].size_names = {"front_idle", "big_front_idle", "big_front_idle"}
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "display_of_true_might_heal"
    tt.render.sprites[2].size_names = {"back_idle", "big_back", "big_back"}
    tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[2].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
    tt = E:register_t("mod_burning_tower_flamespitter", "modifier")
    b = balance.towers.flamespitter.burning

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = b.duration
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = DAMAGE_TRUE
    tt.dps.damage_every = b.cycle_time
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "fire"
    tt.render.sprites[1].name = "small"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt.damage = b.damage
    tt = E:register_t("mod_burning_tower_flamespitter_skill_bomb", "mod_burning_tower_flamespitter")
    b = balance.towers.flamespitter.skill_bomb.burning
    tt.modifier.duration = b.duration
    tt.dps.damage_min = b.damage
    tt.dps.damage_max = b.damage
    tt.dps.damage_every = b.cycle_time
    tt.damage = b.damage
    tt = E:register_t("mod_tower_stage_13_sunray_special", "modifier")

    local b = balance.specials.towers.stage_13_sunray.special_attack

    E:add_comps(tt, "dps")

    tt.modifier.duration = b.duration
    tt.dps.damage_min = b.damage_min
    tt.dps.damage_max = b.damage_max
    tt.dps.damage_type = DAMAGE_DISINTEGRATE
    tt.dps.damage_every = 1e+99
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt.main_script.remove = scripts.mod_tower_stage_13_sunray_special.remove
    tt = E:register_t("mod_stage_11_veznan_skill_cage", "mod_stun")
    b = balance.specials.stage11_veznan.skill_cage
    tt.render.sprites[1].prefix = "stage11_veznan_export_cage"
    tt.render.sprites[1].size_names = nil
    tt.render.sprites[1].anchor = vec_2(0.5, 0.41)
    tt.render.sprites[1].scale = vec_2(1.1, 1)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "stage11_veznan_export_cage_piso"
    tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[2].z = Z_DECALS
    tt.main_script.update = scripts.mod_stage_11_veznan_skill_cage.update
    tt.modifier.animation_phases = true
    tt.modifier.use_mod_offset = false
    tt.modifier.duration = b.duration
    tt.sound_cast = "Stage11VeznanMagicShacklesCast"
    tt.sound_end = "Stage11VeznanMagicShacklesRelease"
    tt = E:register_t("mod_tower_flamesplitter_skill_columns", "mod_stun")
    b = balance.towers.flamespitter.skill_columns
    tt.modifier.duration = fts(b.stun_time)
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_upgrade_alliance_seal_of_punishment", "modifier")

    E:add_comps(tt, "render")

    tt.modifier.duration = 2
    tt.modifier.use_mod_offset = true
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].prefix = "seal_of_punishment_damage_fx"
    tt.render.sprites[1].size_names = {"idle", "big_idle", "big_idle"}
    tt.render.sprites[1].offset_y = 10
    tt.main_script.insert = scripts.mod_upgrade_alliance_seal_of_punishment.insert
    tt.main_script.update = scripts.mod_upgrade_alliance_seal_of_punishment.update
    tt.sound_burn = "UpgradeSealOfPunishmentHit"
    tt = E:register_t("mod_upgrade_alliance_flux_altering_coils_teleport", "mod_teleport")
    b = balance.upgrades.alliance_flux_altering_coils
    tt.modifier.vis_flags = bor(F_MOD)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt.modifier.duration = 1
    tt.nodes_offset = -b.nodes_teleport
    tt.nodeslimit = b.nodes_limit
    tt.max_times_applied = 5
    tt.delay_start = fts(3)
    tt.hold_time = 0.34
    tt.delay_end = fts(3)
    tt.fx_start = "fx_upgrade_alliance_flux_altering_coils_teleport"
    tt.fx_end = "fx_upgrade_alliance_flux_altering_coils_teleport"
    tt = E:register_t("mod_upgrade_alliance_flux_altering_coils_mark", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_TELEPORT
    tt.modifier.duration = fts(50)
    tt.main_script.queue = scripts.mod_mark_flags.queue
    tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
    tt.main_script.update = scripts.mod_mark_flags.update
    tt = E:register_t("mod_stage_11_portal", "modifier")

    E:add_comps(tt, "render")

    tt.modifier.duration = 1e+99
    tt.modifier.use_mod_offset = false
    tt.main_script.insert = scripts.mod_stage_11_portal.insert
    tt.fx = "fx_stage_11_portal_spawn"
    tt = E:register_t("mod_bullet_hero_venom_ranged_tentacle_bleed", "mod_blood")
    b = balance.heroes.hero_venom.ranged_tentacle
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_inc = 0
    tt.dps.damage_every = nil
    tt.dps.fx_every = tt.dps.damage_every
    tt.dps.fx_every = fts(20)
    tt.modifier.duration = nil
    tt = E:register_t("mod_bullet_hero_venom_ranged_tentacle_stun", "mod_stun")
    tt.modifier.duration = fts(7)
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt = E:register_t("mod_item_winter_age_freeze", "mod_stun")
    b = balance.items.winter_age

    E:add_comps(tt, "render")

    tt.modifier.duration = b.stun_duration
    tt.render.sprites[1].prefix = "winter_age_stun_fx"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.modifier.animation_phases = true
    tt.modifier.use_mod_offset = false
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.main_script.insert = scripts.mod_item_winter_age_freeze.insert
    tt.main_script.update = scripts.mod_item_winter_age_freeze.update
    tt.main_script.remove = scripts.mod_freeze.remove
    tt.freeze_decal_name = "decal_freeze_enemy"
    tt = E:register_t("mod_hero_venom_eat_enemy_regen", "modifier")

    E:add_comps(tt, "render", "tween")

    tt.modifier.duration = fts(43)
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.update = scripts.mod_hero_venom_eat_enemy_regen.update
    tt.main_script.remove = scripts.mod_track_target.remove
    tt.render.sprites[1].prefix = "hero_venom_heal_fx_back"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "hero_venom_heal_fx_front"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[2].z = Z_DECALS
    tt.tween.props[1].keys = {{0, 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
    tt = E:register_t("mod_hero_venom_ultimate_slow", "mod_slow")
    b = balance.heroes.hero_mecha.tar_bomb
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = 0.5
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
    tt.render.sprites[1].base_offset = vec_2(0, 10)
    tt = E:register_t("mod_bullet_tower_barrel_lvl1", "modifier")
    b = balance.towers.barrel.basic_attack.debuff

    E:add_comps(tt, "render")

    tt.modifier.duration = b.duration[1]
    tt.modifier.vis_flags = F_MOD
    tt.modifier.type = MOD_TYPE_POISON
    tt.modifier.level = 1
    tt.modifier.resets_same = true
    tt.modifier.replaces_lower = true
    tt.damage_reduction = b.damage_reduction[1]
    tt.main_script.insert = scripts.mod_bullet_tower_barrel.insert
    tt.main_script.remove = scripts.mod_bullet_tower_barrel.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.render.sprites[1].prefix = "barrel_tower_projectile_mod"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[1].size_names = {"barrel_tower_projectile_mod", "barrel_tower_projectile_mod",
                                       "barrel_tower_projectile_mod_big"}
    tt = E:register_t("mod_bullet_tower_barrel_lvl2", "mod_bullet_tower_barrel_lvl1")
    tt.modifier.level = 2
    tt.modifier.duration = b.duration[2]
    tt.damage_reduction = b.damage_reduction[2]
    tt = E:register_t("mod_bullet_tower_barrel_lvl3", "mod_bullet_tower_barrel_lvl1")
    tt.modifier.level = 3
    tt.modifier.duration = b.duration[3]
    tt.damage_reduction = b.damage_reduction[3]
    tt = E:register_t("mod_bullet_tower_barrel_lvl4", "mod_bullet_tower_barrel_lvl1")
    tt.modifier.level = 4
    tt.modifier.duration = b.duration[4]
    tt.damage_reduction = b.damage_reduction[4]
    tt = E:register_t("mod_tower_barrel_skill_barrel_poison", "mod_poison")
    b = balance.towers.barrel.skill_barrel.poison
    tt.dps.damage_every = b.every
    tt.dps.damage_min = b.damage_min
    tt.dps.damage_max = b.damage_max
    tt.dps.kill = true
    tt.modifier.duration = b.duration
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt = E:register_t("mod_tower_barrel_skill_barrel_slow", "mod_slow")
    b = balance.towers.barrel.skill_barrel.slow
    tt.slow.factor = b.factor
    tt.modifier.duration = b.duration
    tt = E:register_t("mod_tower_sand_skill_big_blade_slow", "mod_slow")
    b = balance.towers.sand.skill_big_blade
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = b.slow_duration
    tt = E:register_t("mod_tower_ghost_soul_slow", "mod_slow")
    b = balance.towers.ghost.soul_attack
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = b.slow_duration
    tt = E:register_t("mod_tower_ghost_soul_damage_factor", "modifier")
    b = balance.towers.ghost.soul_attack

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = b.damage_factor
    tt.modifier.duration = b.damage_factor_duration
    tt.modifier.use_mod_offset = false
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "ghost_tower_soul_skill_enemy_fx"
    tt.render.sprites[1].name = "small"
    tt = E:register_t("mod_tower_ghost_increase_damage_factor", "modifier")
    b = balance.towers.ghost.extra_damage

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_track_target.update
    tt.inflicted_damage_factor = nil
    tt.modifier.duration = b.duration
    tt.modifier.use_mod_offset = false
    tt.render.sprites[1].prefix = "ghost_tower_buff_skill_back"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].z = Z_OBJECTS - 1
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "ghost_tower_buff_skill_front"
    tt.render.sprites[2].name = "loop"
    tt.render.sprites[1].draw_order = 1
    tt.sound_events.insert = "TowerGhostExtraDamageCast"
    tt = E:register_t("mod_tower_ray_damage", "modifier")

    AC(tt, "render", "dps", "tween")

    b = balance.towers.ray.basic_attack
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_ONE_SHIELD_HIT)
    tt.dps.damage_every = b.damage_every
    tt.dps.pop = {"pop_zap_arcane"}
    tt.dps.pop_conds = DR_KILL
    tt.main_script.update = scripts.mod_tower_ray_damage.update
    tt.modifier.duration = b.duration
    tt.modifier.allows_duplicates = true
    tt.modifier.use_mod_offset = true
    tt.render.sprites[1].name = "channeler_tower_ray_end_loop"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].z = Z_BULLETS + 1
    tt.render.sprites[1].scale = vec_1(0.4)
    tt.damage_from_bullet = true
    tt.damage_tiers = b.damage_per_second
    tt.tween.props[1].keys = {{0, 255}, {fts(2), 0}}
    tt.tween.remove = true
    tt.tween.disabled = true
    tt = E:register_t("mod_tower_ray_slow", "mod_slow")
    b = balance.towers.ray.basic_attack
    tt.slow.factor = b.slow.factor
    tt.modifier.duration = b.duration
    tt.main_script.insert = scripts.mod_tower_ray_slow.insert
    tt.main_script.remove = scripts.mod_tower_ray_slow.remove
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
    tt = E:register_t("mod_hero_robot_skill_jump", "mod_stun")
    tt.modifier.duration = nil
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt = E:register_t("mod_hero_robot_skill_explode", "modifier")
    b = balance.heroes.hero_robot.explode

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = b.burning_duration
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = b.burning_damage_type
    tt.dps.damage_every = b.damage_every
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "fire"
    tt.render.sprites[1].name = "small"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt = E:register_t("mod_hero_robot_skill_fire_slow", "mod_slow")

    E:add_comps(tt, "render", "tween")

    b = balance.heroes.hero_robot.fire
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = nil
    tt.render.sprites[1].prefix = "Blaze_skill2humostatus"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.render.sprites[1].loop = true
    tt.modifier.use_mod_offset = false
    tt.main_script.update = scripts.mod_hero_robot_skill_fire_slow.update
    tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
    tt.tween.remove = false
    tt = E:register_t("mod_hero_robot_skill_uppercut", "modifier")
    b = balance.heroes.hero_robot.uppercut

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = fts(10)
    tt.main_script.insert = scripts.mod_hero_robot_skill_uppercut.insert
    tt.main_script.update = scripts.mod_hero_robot_skill_uppercut.update
    tt.clone_decal = "decal_hero_robot_skill_uppercut_clone"
    tt.fly_speed = vec_2(7, 8)
    tt.rotation_speed = 0.17
    tt = E:register_t("mod_hero_robot_skill_ultimate_burning", "modifier")
    b = balance.heroes.hero_robot.ultimate

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = b.burning_duration
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = b.burning_damage_type
    tt.dps.damage_every = b.damage_every
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "fire"
    tt.render.sprites[1].name = "small"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update

    tt = E:register_t("mod_hero_dragon_gem_skill_stun", "mod_stun")

    E:add_comps(tt, "render")

    tt.modifier.duration = nil
    tt.render.sprites[1].prefix = "hero_dragon_gem_breath_crystal"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].size_names = {"small", "medium", "big"}
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.modifier.animation_phases = true
    tt = E:register_t("mod_hero_dragon_gem_crystal_instakill", "modifier")
    b = balance.heroes.hero_dragon_gem.crystal_instakill

    E:add_comps(tt, "render")

    tt.modifier.duration = fts(30)
    tt.modifier.animation_phases = true
    tt.main_script.insert = scripts.mod_stun.insert
    tt.main_script.update = scripts.mod_hero_dragon_gem_crystal_instakill.update
    tt.main_script.remove = scripts.mod_stun.remove
    tt.explode_fx = "decal_hero_dragon_gem_floor_circle"
    tt.explode_sound = "HeroDragonGemRedDeathExplosion"
    tt.render.sprites[1].prefix = "hero_dragon_gem_red_death_crystal"
    tt.render.sprites[1].name = "start"
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].draw_order = DO_MOD_FX
    tt.explode_time = b.explode_time
    tt.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
    tt.damage_aoe_min = nil
    tt.damage_aoe_max = nil
    tt.damage_type_aoe = DAMAGE_PHYSICAL
    tt.damage_range = b.damage_range
    tt.damage_aoe_bans = bor(F_FLYING, F_CLIFF)
    tt = E:register_t("mod_hero_dragon_gem_crystal_totem_slow", "mod_slow")
    b = balance.heroes.hero_dragon_gem.crystal_totem
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = b.slow_duration
    tt = E:register_t("mod_hero_dragon_gem_passive_charge", "modifier")
    b = balance.heroes.hero_dragon_gem.passive_charge

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_damage_factors.insert
    tt.main_script.remove = scripts.mod_damage_factors.remove
    tt.main_script.update = scripts.mod_hero_dragon_gem_passive_charge.update
    tt.inflicted_damage_factor = b.damage_factor
    tt.modifier.duration = 1e+99
    tt.modifier.use_mod_offset = true
    tt.render.sprites[1].prefix = "hero_dragon_gem_passive"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].z = Z_FLYING_HEROES + 1
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
    tt = E:register_t("mod_hero_bird_cluster_bomb_burn", "modifier")
    b = balance.heroes.hero_bird.cluster_bomb.burning

    E:add_comps(tt, "dps", "render")

    tt.modifier.duration = b.duration
    tt.dps.damage_min = nil
    tt.dps.damage_max = nil
    tt.dps.damage_type = b.damage_type
    tt.dps.damage_every = b.cycle_time
    tt.render.sprites[1].size_names = {"small", "medium", "large"}
    tt.render.sprites[1].prefix = "fire"
    tt.render.sprites[1].name = "small"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
    tt.main_script.insert = scripts.mod_dps.insert
    tt.main_script.update = scripts.mod_dps.update
    tt.damage = b.damage
    tt = E:register_t("mod_hero_bird_shout_stun", "mod_stun")
    b = balance.heroes.hero_bird.shout_stun
    tt.modifier.duration = nil
    tt = E:register_t("mod_hero_bird_shout_slow", "mod_slow")

    E:add_comps(tt, "render")

    b = balance.heroes.hero_bird.shout_stun
    tt.slow.factor = b.slow_factor
    tt.modifier.duration = nil
    tt.modifier.health_bar_offset = vec_2(0, -5)
    tt.render.sprites[1].prefix = "gryph_slow_mod"
    tt.render.sprites[1].name = "run"
    tt.render.sprites[1].draw_order = 2
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].anchor = vec_2(0.5, 0.75)
    tt.render.sprites[1].fps = 20
    tt = E:register_t("mod_stage_16_overseer_tower_disable", "modifier")

    E:add_comps(tt, "render")

    tt.main_script.insert = scripts.mod_stage_16_overseer_tower_disable.insert
    tt.main_script.remove = scripts.mod_stage_16_overseer_tower_disable.remove
    tt.main_script.update = scripts.mod_stage_16_overseer_tower_disable.update
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
    tt.offset_y_per_tower = {
        necromancer = 16,
        royal_archers = 20,
        elven_stargazers = 16,
        tricannon = 10,
        arborean_emissary = 20,
        flamespitter = 16,
        ballista = 20
    }
    tt = E:register_t("mod_soldier_reinforcement_item_summon_blackburn_spawn_stun", "mod_stun")
    b = balance.items.summon_blackburn.spawn
    tt.modifier.duration = b.stun_duration
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_decal_item_portable_coil_stun", "mod_stun")
    b = balance.items.portable_coil
    tt.modifier.duration = b.stun_duration
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("mod_item_scroll_of_spaceshift_mark", "modifier")

    E:add_comps(tt, "mark_flags")

    tt.mark_flags.vis_bans = F_TELEPORT
    tt.modifier.duration = fts(50)
    tt.main_script.queue = scripts.mod_mark_flags.queue
    tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
    tt.main_script.update = scripts.mod_mark_flags.update
    tt = E:register_t("mod_item_scroll_of_spaceshift_teleport", "mod_teleport")
    b = balance.items.scroll_of_spaceshift
    tt.modifier.vis_flags = bor(F_MOD)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt.modifier.duration = 1
    tt.nodes_offset = -b.nodes_teleport
    tt.nodeslimit = b.nodes_limit
    tt.max_times_applied = 1e+99
    tt.delay_start = fts(3)
    tt.hold_time = 0.34
    tt.delay_end = fts(3)
    tt.fx_start = "fx_item_scroll_of_spaceshift"
    tt.fx_end = "fx_item_scroll_of_spaceshift"
    tt = E:register_t("mod_item_second_breath_heal", "modifier")

    E:add_comps(tt, "render", "tween")

    tt.modifier.duration = fts(44)
    tt.main_script.insert = scripts.mod_track_target.insert
    tt.main_script.update = scripts.mod_item_second_breath_heal.update
    tt.main_script.remove = scripts.mod_track_target.remove
    tt.render.sprites[1].prefix = "item_second_breath_healing_fx"
    tt.render.sprites[1].name = "loop"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.render.sprites[1].z = Z_EFFECTS
    tt.render.sprites[1].loop = true
    tt.tween.props[1].keys = {{0, 255}, {tt.modifier.duration - fts(10), 255}, {tt.modifier.duration, 0}}
    tt = E:register_t("mod_soldier_reinforcement_stage_15_denas_spawn_stun", "mod_stun")
    b = balance.specials.stage15_denas
    tt.modifier.duration = b.spawn_stun_duration
    tt.modifier.vis_flags = bor(F_MOD, F_STUN)
    tt.modifier.vis_bans = bor(F_BOSS)
    tt = E:register_t("controller_upgrade_heroes_nimble_physique")
    b = balance.upgrades.heroes_nimble_physique

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_upgrade_heroes_nimble_physique.update
    tt.trigger_cards = b.deck_data.trigger_cards
    tt.total_cards = b.deck_data.total_cards
    tt = E:register_t("controller_upgrades_alliance")
    b = balance.upgrades.alliance_shared_reserves

    E:add_comps(tt, "main_script")

    tt.main_script.insert = scripts.controller_upgrades_alliance.insert
    tt.main_script.update = scripts.controller_upgrades_alliance.update
    tt.extra_gold = b.extra_gold
    tt = E:register_t("controller_tower_arborean_emissary_gift_of_nature")

    E:add_comps(tt, "pos", "main_script")

    tt.main_script.update = scripts.controller_tower_arborean_emissary_gift_of_nature.update
    tt.entity = "decal_tower_arborean_emissary_gift_of_nature_wisp"
    tt.aura = "aura_tower_arborean_emissary_gift_of_nature"
    tt.start_offset = {vec_2(-35, 67), vec_2(35, 68), vec_2(0, 50)}
    tt.end_offset = {vec_2(-50, 60), vec_2(0, 80), vec_2(50, 60)}
    tt = E:register_t("controller_path_direction")

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_path_direction.update
    tt.path_marker_entity = "decal_path_hero_movement"
    tt.distance_between = 15
    tt.pool_batch_size = 10
    tt = E:register_t("controller_tower_swap")

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_tower_swap.update
    tt.path_marker_entity = "decal_path_hero_movement"
    tt.swap_sound = "TowerGhostTeleport"
    tt.tower_1 = nil
    tt.tower_2 = nil
    tt.delay = 0.25
    tt.delay_empty = 0.25
    tt.fx_out = "tower_ghost_teleport_out"
    tt.fx_in = "tower_ghost_teleport_in"
    tt.fx_spawn_delay = fts(14)
    tt.fx_in_delay = fts(14)
    tt.fx_delay_between = 0
    tt = E:register_t("controller_tower_swap_overseer", "controller_tower_swap")
    tt.delay = 0.25
    tt.delay_empty = 0.25
    tt.fx_out = "decal_tower_swap_fx_in"
    tt.fx_in = "decal_tower_swap_fx_in"
    tt.fx_spawn_delay = 0
    tt.fx_in_delay = 0
    tt.fx_delay_between = fts(14)
    tt.swap_sound = "Stage16OverseerTeleport"
    tt = E:register_t("tower_ghost_hover", "decal")
    tt.render.sprites[1].name = "ghost_tower_swap_indicator_back"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].z = Z_TOWER_BASES + 1
    tt.render.sprites[1].offset.y = 14
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].draw_order = 11
    tt.render.sprites[2].prefix = "ghost_tower_swap_indicator_particles"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].loop = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[2].offset.y = 14
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[2].draw_order = 11
    tt.render.sprites[3].name = "ghost_tower_swap_indicator_front"
    tt.render.sprites[3].animated = false
    tt.render.sprites[3].z = Z_OBJECTS
    tt.render.sprites[3].offset.y = 14
    tt.render.sprites[4] = E:clone_c("sprite")
    tt.render.sprites[4].prefix = "ghost_tower_swap_indicator_fx"
    tt.render.sprites[4].name = "idle"
    tt.render.sprites[4].loop = true
    tt.render.sprites[4].z = Z_TOWER_BASES + 1
    tt.render.sprites[4].alpha = 155
    tt.render.sprites[4].offset.y = 14
    tt.render.sprites[4].draw_order = 11
    tt = E:register_t("tower_ghost_teleport_out", "decal_timed")
    tt.render.sprites[1].name = "ghost_tower_teleport_fx_out_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.timed.duration = fts(20)
    tt = E:register_t("tower_ghost_teleport_in", "decal_timed")
    tt.render.sprites[1].name = "ghost_tower_teleport_fx_in_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.timed.duration = fts(20)
    tt = E:register_t("decal_tower_swap_fx_out", "decal_timed")
    tt.render.sprites[1].name = "overseer_fx_overseer_teleportfx_out_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.timed.duration = fts(20)
    tt = E:register_t("decal_tower_swap_fx_in", "decal_timed")
    tt.render.sprites[1].name = "overseer_fx_overseer_teleportfx_run"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
    tt.render.sprites[1].offset = vec_2(0, 10)
    tt.timed.duration = fts(20)
    tt = E:register_t("decal_soldier_tower_ghost_spawn", "decal_timed")
    tt.render.sprites[1].name = "ghost_tower_unit_spawn_fx_idle"
    tt.render.sprites[1].animated = true
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
    tt.render.sprites[1].offset = vec_2(0, 0)
    tt.timed.duration = fts(24)
    tt = E:register_t("tower_ghost_hover_controller")

    E:add_comps(tt, "main_script")

    tt.template_hover = "tower_ghost_hover"
    tt.main_script.insert = scripts.tower_ghost_hover_controller.insert
    tt.main_script.remove = scripts.tower_ghost_hover_controller.remove
    tt = E:register_t("controller_hero_builder_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_builder_ultimate.can_fire_fn
    tt.cooldown = nil
    tt.entity = "decal_hero_builder_ultimate_projectile"
    tt.main_script.update = scripts.hero_builder_ultimate.update
    tt.sound = "HeroBuilderWreckingBall"

    tt = E:register_t("controller_hero_mecha_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_mecha_ultimate.can_fire_fn
    tt.cooldown = nil
    tt.entity = "zeppelin_hero_mecha"
    tt.main_script.update = scripts.hero_mecha_ultimate.update
    tt.sound = "HeroMechaDeathFromAboveCast"
    tt = E:register_t("controller_hero_venom_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_venom_ultimate.can_fire_fn
    tt.cooldown = nil
    tt.aura = "aura_hero_venom_ultimate"
    tt.main_script.update = scripts.hero_venom_ultimate.update
    tt.sound = "HeroVenomRenewCreepingDeathCast"
    tt = E:register_t("controller_hero_robot_ultimate")

    E:add_comps(tt, "pos", "main_script", "sound_events")

    tt.can_fire_fn = scripts.hero_robot_ultimate.can_fire_fn
    tt.cooldown = nil
    tt.entity = "aura_hero_robot_ultimate_train"
    tt.main_script.update = scripts.hero_robot_ultimate.update

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
    tt.elf_pos = {vec_2(390, 625), vec_2(750, 675), vec_2(230, 625), vec_2(930, 640)}
    tt.pos_guard = vec_2(490, 550)
    tt.pos_chain = vec_2(448, 541)
    tt.pos_elf_slave = vec_2(428, 540)
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
    tt.entity_candles = {"decal_stage_09_candle_back1", "decal_stage_09_candle_back2", "decal_stage_09_candle_back3",
                         "decal_stage_09_candle_front1", "decal_stage_09_candle_front2", "decal_stage_09_candle_front3"}
    tt.entity_glows = {"decal_stage_09_candle_glow_back", "decal_stage_09_candle_glow_front"}
    tt.path_portal = "decal_stage_09_portal_path_spawn"
    tt.portal_offset = vec_2(-15, 0)
    tt.pos_portal = vec_2(1048 + tt.portal_offset.x, 446 + tt.portal_offset.y)
    tt.pos_aura = {vec_2(661 + tt.portal_offset.x, 280 + tt.portal_offset.y),
                   vec_2(659 + tt.portal_offset.x, 300 + tt.portal_offset.y),
                   vec_2(658 + tt.portal_offset.x, 260 + tt.portal_offset.y)}
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
    tt.walk_destination = vec_2(120, 0)
    tt.motion.speed = vec_2(10, 10)
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
    tt.obelisk_pos = vec_2(531, 545)
    tt.crystal_pos = vec_2(531, 539)
    tt.fx_heal_pos = vec_2(528, 557)
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
    tt.bullet_offset = vec_2(0, 20)
    tt.bullet_spawn_pos = {vec_2(-71, 38), vec_2(3, 3), vec_2(71, 35)}
    tt.golem_selected_paths = {4, 3, 1}
    tt.golem_holder_pos = {vec_2(310, 441), vec_2(482, 345), vec_2(328, 205)}
    tt.golem_activate_holder = {"4", "9", "6"}
    tt.golem_walk_pos = {vec_2(375, 465), vec_2(572, 392), vec_2(381, 275)}
    tt.template_golem = "enemy_crystal_golem"
    tt.sacrifice_duration = 4
    tt.sound_activation = "Stage10ObeliskActivation"
    tt.sound_cast_stun = "Stage10ObeliskEffectStun"
    tt.sound_cast_heal = "Stage10ObeliskEffectHealLoopStart"
    tt.sound_heal_loop = "Stage10ObeliskEffectHealLoop"
    tt.sound_change_mode = "Stage10ObeliskEffectChange"
    tt.sound_cast_golem = "Stage10ObeliskEffectGolemSpawnCast"
    tt.sound_cast_teleport = "EnemyVoidBlinkerTeleport"
    tt = E:register_t("controller_stage_10_obelisk_iron", "controller_stage_10_obelisk")
    tt.main_script.update = scripts.controller_stage_10_obelisk_iron.update
    tt.golem_holder_pos = {vec_2(74, 524), vec_2(310, 440), vec_2(60, 308), vec_2(700, 400), vec_2(328, 204)}
    tt.golem_walk_pos = {vec_2(26, -34), vec_2(50, 50), vec_2(30, 0), vec_2(0, -70), vec_2(54, 60)}
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
    tt.entities_soldiers = {"soldier_stage_10_ymca_indio", "soldier_stage_10_ymca_constructor",
                            "soldier_stage_10_ymca_biker", "soldier_stage_10_ymca_policia"}
    tt.entity_statue = "decal_stage_10_ymca_statue"
    tt.entity_dots = "decal_stage_10_ymca_dots"
    tt.entity_fireworks = "decal_stage_10_ymca_fireworks"
    tt.entity_lights = "decal_stage_10_ymca_lights"
    tt.dots_pos = vec_2(1025, 590)
    tt.start_formation = {3, 4, 2, 1}

    local sb = vec_2(-30, -30)

    tt.statue_position = {vec_2(sb.x + 975, sb.y + 620), vec_2(sb.x + 1030, sb.y + 650), vec_2(sb.x + 1090, sb.y + 645),
                          vec_2(sb.x + 1133, sb.y + 590)}
    tt.soldier_spawn_pos = {vec_2(985, 585), vec_2(1015, 600), vec_2(1045, 580), vec_2(1015, 560)}
    tt.soldier_line_pos_offset = {vec_2(25, -20), vec_2(20, -10), vec_2(-15, 5), vec_2(-25, -10)}

    local base = vec_2(925, 445)

    tt.soldier_path_pos = {vec_2(base.x - 20, base.y + 20), vec_2(base.x + 13, base.y + 33), vec_2(base.x + 25, base.y),
                           vec_2(base.x - 10, base.y - 10)}
    tt.soldier_spawn_delay = {1.5, 1.8, 1.7, 1.5}
    tt = E:register_t("controller_stage_11_cult_leader")
    b = balance.specials.stage11_cult_leader

    E:add_comps(tt, "editor", "pos", "main_script")

    tt.main_script.insert = scripts.controller_stage_11_cult_leader.insert
    tt.main_script.update = scripts.controller_stage_11_cult_leader.update
    tt.entity_cultist = "decal_stage_11_cult_leader"
    tt.entity_illusion = "enemy_stage_11_cult_leader_illusion"
    tt.cultist_pos = vec_2(730, 510)
    tt.spawn_available_pos = {vec_2(340, 476), vec_2(546, 478), vec_2(366, 296), vec_2(648, 284), vec_2(920, 390)}
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
    tt.portal_pos = vec_2(512, 384)
    tt.entity_aura = "aura_stage_11_portal"
    tt.aura_pos = vec_2(880, 580)
    tt.entity_torches = "decal_stage_11_torches"
    tt.torches_pos = vec_2(512, 384)
    tt.entity_crystals_prefix = "decal_stage_11_portal_crystal_"
    tt.crystals_count = 8
    tt.crystals_pos = vec_2(512, 384)
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

    E:add_comps(tt, "editor", "pos", "main_script", "glare_kr5", "render")

    tt.main_script.insert = scripts.controller_terrain_3_local_glare.insert
    tt.main_script.update = scripts.controller_terrain_3_local_glare.update
    tt.entity_spawner_fx = "fx_terrain_3_spawner"
    tt.aura_glare = "aura_glare_source"
    tt.eyes_t = {"decal_terrain_3_glare_eye_big", "decal_terrain_3_glare_eye_small_1",
                 "decal_terrain_3_glare_eye_small_2", "decal_terrain_3_glare_eye_small_3"}
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
    tt.eyes_t = {"decal_stage_16_glare_eye_big", "decal_stage_16_glare_eye_small_1", "decal_stage_16_glare_eye_small_2",
                 "decal_stage_16_glare_eye_small_3"}
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
    tt.amalgam_spawn_pos = vec_2(501, 482)
    tt.aura_t = "aura_controller_stage_14_amalgam"
    tt.amalgam_decal_t = "decal_controller_stage_14_amalgam"
    tt.sacrifices_to_show_1 = b.sacrifices_to_show_1
    tt.sacrifices_to_show_2 = b.sacrifices_to_show_2
    tt.sacrifices_to_spawn = b.sacrifices_to_spawn
    tt.sound_1 = "Stage14BehemothPoolSpawn1"
    tt.sound_2 = "Stage14BehemothPoolSpawn2"
    tt.sound_spawn = "Stage14BehemothPoolSpawn3"
    tt = E:register_t("controller_hero_dragon_gem_skill_floor_impact_spawner")

    E:add_comps(tt, "main_script")

    tt.main_script.update = scripts.controller_hero_dragon_gem_skill_floor_impact_spawner.update
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
    tt.render.sprites[2].offset = vec_2(-2, 2)
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
    tt = E:register_t("controller_stage_16_overseer")
    b = balance.specials.stage16_overseer

    E:add_comps(tt, "editor", "pos", "main_script", "render", "health", "info", "ui")

    tt.main_script.update = scripts.controller_stage_16_overseer.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseerDef"
    tt.render.sprites[1].name = "idle1_1"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].sort_y_offset = 2
    tt.render.sprites[1].exo_hide_prefix = {"hurt2", "hurt1"}
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "overseer_backDef"
    tt.render.sprites[2].name = "loop"
    tt.render.sprites[2].exo = true
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[2].sort_y_offset = 3
    tt.render.sprites[2].offset = vec_2(20, -620)
    tt.config_per_wave = b.config_per_wave
    tt.hit_point_template = "enemy_overseer_hit_point"
    tt.hit_point_pos = {vec_2(400, 440), vec_2(520, 400), vec_2(640, 440)}
    tt.health.armor = 0
    tt.health.hp_max = b.hp
    tt.health.ignore_delete_after = true
    tt.info.i18n_key = "ENEMY_BOSS_OVERSEER"
    tt.info.portrait_boss = "boss_health_bar_icon_0004"
    tt.phase_per_hp_threshold = b.phase_per_hp_threshold
    tt.phase_per_time = b.phase_per_time
    tt.change_tower_cooldown = b.change_tower_cooldown
    tt.change_tower_amount = b.change_tower_amount
    tt.disable_tower_cooldown = b.disable_tower_cooldown
    tt.holders_close = {"6", "7", "8", "9", "10"}
    tt.swap_delay = fts(60)
    tt.disable_delay = fts(70)
    tt.disable_tower_recover_price = b.disable_tower_recover_price
    tt.disable_tower_mod = "mod_stage_16_overseer_tower_disable"
    tt.destroy_tower_cooldown = b.destroy_tower_cooldown
    tt.destroy_holder_cooldown = b.destroy_holder.cooldown
    tt.holders_to_destroy = {"1", "13", "10", "2", "12", "4", "9", "5", "14", "3", "11", "6", "8", "15", "7"}
    tt.nav_mesh_patches = {
        ["1"] = {
            [2] = {3, 4}
        },
        ["13"] = {
            [11] = {nil, 12, 10, 14},
            [14] = {nil, 10, 15}
        },
        ["10"] = {
            [9] = {11, nil, 8, 14},
            [11] = {nil, 12, 9, 14},
            [14] = {nil, 11, 15}
        },
        ["2"] = {
            [3] = {15, 6},
            [4] = {6, 5, nil, 3}
        },
        ["12"] = {
            [11] = {nil, nil, 9, 14},
            [5] = {6, nil, nil, 4}
        },
        ["4"] = {
            [5] = {6, nil, nil, 3},
            [6] = {7, nil, 5, 3}
        },
        ["9"] = {
            [8] = {11, nil, 7, 15},
            [11] = {nil, nil, 8, 14},
            [14] = {nil, 11, 15}
        },
        ["5"] = {
            [6] = {7, nil, nil, 3},
            [3] = {15, 6}
        },
        ["14"] = {
            [11] = {nil, nil, 8},
            [15] = {nil, 8, 3}
        },
        ["3"] = {
            [6] = {7},
            [15] = {nil, 8}
        },
        ["11"] = {
            [8] = {nil, nil, 7, 15}
        },
        ["6"] = {
            [7] = {8, nil, nil, 15}
        },
        ["8"] = {
            [7] = {nil, nil, nil, 15},
            [15] = {nil, 7}
        },
        ["15"] = {
            [7] = {}
        },
        ["7"] = {}
    }
    tt.idle_cooldown_min = 2
    tt.idle_cooldown_max = 6
    tt.idle_anims = nil
    tt.idle_start_anims = {"startidle2", "startidle1"}
    tt.idle_fight_anims = {"idle1", "idle2", "idle4", "idle5", "idle6"}
    tt.first_time_cooldown = b.first_time_cooldown
    tt.life_hurt_threshold = {33, 66}
    tt.destroy_holders_template = "decal_stage_16_holder_destroy_fx"
    tt.destroy_holders_crater_template = "decal_stage_16_holder_destroy_crater"
    tt.destroy_holders_bullet = "bullet_stage_16_overseer_destroy_holders"
    tt.change_towers_template = "decal_stage_16_tower_change_fx"
    tt.ui.click_rect = r(-120, -30, 240, 180)
    tt.ui.can_click = true
    tt.info.fn = scripts.controller_stage_16_overseer.get_info
    tt.info.portrait = "info_portraits_enemies_0043"
    tt.sound_rumble = "Stage16OverseerRumble"
    tt.sound_unchain_center = "Stage16OverseerUnchainCenter"
    tt.sound_teleport_charge = "Stage16OverseerTeleportCharge"
    tt.sound_teleport = "Stage16OverseerTeleport"
    tt.sound_destroy_charge = "Stage16OverseerDestroyCharge"
    tt.sound_destroy_ray = "Stage16OverseerDestroyRay"
    tt.sound_destroy_explosion = "Stage16OverseerDestroyExplosion"
    tt.sound_hurt = "Stage16OverseerHurt"
    tt.sound_death = "Stage16OverseerDeath"
    tt = E:register_t("controller_stage_16_mouth_left")
    b = balance.specials.stage16_overseer.mouth_left

    E:add_comps(tt, "editor", "pos", "main_script", "render")

    tt.main_script.update = scripts.controller_stage_16_overseer_mouth_door.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseer_mouthDef"
    tt.render.sprites[1].name = "closeidle"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].sort_y_offset = 4
    tt.check_pos = vec_2(282, 556)
    tt.check_cooldown = fts(5)
    tt.check_radius = 150
    tt.check_vis_flags = F_ENEMY
    tt.check_vis_bans = F_BOSS
    tt.config = b
    tt = E:register_t("controller_stage_16_mouth_right", "controller_stage_16_mouth_left")
    tt.render.sprites[1].flip_x = true
    b = balance.specials.stage16_overseer.mouth_right
    tt.check_pos = vec_2(721, 553)
    tt.config = b
    tt = E:register_t("controller_stage_16_tentacle_left")
    b = balance.specials.stage16_overseer.tentacle_left

    E:add_comps(tt, "editor", "pos", "main_script", "render")

    tt.main_script.update = scripts.controller_stage_16_overseer_tentacle.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseer_tentacleDef"
    tt.render.sprites[1].name = "idletrapped"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS - 5
    tt.config = b
    tt.shot_delay = fts(24)
    tt.bullet = "bullet_stage_16_overseer_tentacle_spawn"
    tt.spawn_offset = vec_2(90, -130)
    tt.spawn_pos = {vec_2(76, 332), vec_2(218, 424)}
    tt.spawn_path = {1, 2}
    tt.tentacle_mouth_template = "controller_stage_16_tentacle_mouth_left"
    tt.first_cooldown = balance.specials.stage16_overseer.first_time_cooldown
    tt.sound_rumble = "Stage16OverseerRumble"
    tt.sound_unchain = "Stage16OverseerUnchainLeftRight"
    tt.sound_spawn = "Stage16OverseerSpawnerCast"
    tt = E:register_t("controller_stage_16_tentacle_right", "controller_stage_16_tentacle_left")
    tt.render.sprites[1].flip_x = true
    b = balance.specials.stage16_overseer.tentacle_right
    tt.config = b
    tt.is_right = true
    tt.spawn_offset = vec_2(-80, -150)
    tt.spawn_pos = {vec_2(850, 446), vec_2(860, 206)}
    tt.spawn_path = {3, 4}
    tt.tentacle_mouth_template = "controller_stage_16_tentacle_mouth_right"
    tt = E:register_t("controller_stage_16_tentacle_mouth_left")

    E:add_comps(tt, "editor", "pos", "main_script", "render")

    tt.main_script.update = scripts.controller_stage_16_overseer_tentacle_mouth.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseer_tentacle2Def"
    tt.render.sprites[1].name = "free"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
    tt = E:register_t("controller_stage_16_tentacle_mouth_right", "controller_stage_16_tentacle_mouth_left")
    tt.render.sprites[1].flip_x = true
    tt = E:register_t("controller_stage_16_overseer_eye1")

    E:add_comps(tt, "editor", "pos", "main_script", "render")

    tt.main_script.update = scripts.controller_stage_16_overseer_eye.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseer_minieye1Def"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_OBJECTS
    tt.render.sprites[1].sort_y_offset = -10
    tt.blink_min_cooldown = 3
    tt.blink_max_cooldown = 5
    tt.idle_anims = nil
    tt.idle_not_damaged = {"anim1", "anim2", "anim3"}
    tt.idle_damaged = {"eyehurttwitch"}
    tt.life_hurt_threshold = 66
    tt = E:register_t("controller_stage_16_overseer_eye2", "controller_stage_16_overseer_eye1")
    tt.render.sprites[1].prefix = "overseer_minieye2Def"
    tt.life_hurt_threshold = 33
    tt = E:register_t("controller_stage_16_overseer_eye3", "controller_stage_16_overseer_eye1")
    tt.render.sprites[1].prefix = "overseer_minieye3Def"
    tt.life_hurt_threshold = 33
    tt = E:register_t("controller_stage_16_overseer_eye4", "controller_stage_16_overseer_eye1")
    tt.render.sprites[1].prefix = "overseer_minieye4Def"
    tt.life_hurt_threshold = 66
    tt = E:register_t("controller_stage_16_tentacle_bottom_left")

    E:add_comps(tt, "editor", "pos", "render", "main_script")

    tt.main_script.update = scripts.controller_stage_16_tentacle_bottom.update
    tt.render.sprites[1] = E:clone_c("sprite")
    tt.render.sprites[1].prefix = "overseer_undertent1Def"
    tt.render.sprites[1].name = "idle"
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].exo = true
    tt.render.sprites[1].z = Z_BACKGROUND_COVERS + 1
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].prefix = "overseer_underbacktents1Def"
    tt.render.sprites[2].name = "loop"
    tt.render.sprites[2].loop = true
    tt.render.sprites[2].exo = true
    tt.render.sprites[2].z = Z_BACKGROUND_COVERS - 1
    tt.render.sprites[2].offset = vec_2(-140, -350)
    tt.phase_to_free = 4
    tt.sound_rumble = "Stage16OverseerRumble"
    tt.sound_unchain = "Stage16OverseerUnchainDown"
    tt = E:register_t("controller_stage_16_tentacle_bottom_right", "controller_stage_16_tentacle_bottom_left")
    tt.render.sprites[1].prefix = "overseer_undertent2Def"
    tt.render.sprites[2].prefix = "overseer_underbacktents2Def"
    tt.render.sprites[2].offset = vec_2(350, -20)
    tt.phase_to_free = 5
    tt = E:register_t("power_hero_control_custom")

    E:add_comps(tt, "user_power", "pos", "main_script", "user_selection")

    tt.main_script.insert = scripts.power_hero_control_custom.insert
    tt.user_selection.can_select_point_fn = scripts.power_hero_control_custom.can_select_point
    tt.power_cooldown_fn = scripts.power_hero_control_custom.get_cooldown
    tt = E:register_t("power_hero_control_custom_1", "power_hero_control_custom")
    tt.hero_id = nil
    tt = E:register_t("power_hero_control_custom_2", "power_hero_control_custom")
    tt.hero_id = nil
    tt = E:get_template("power_reinforcements_control")

    function tt.power_cooldown_fn()
        return E:get_template("re_current_1").cooldown
    end

    tt.main_script.insert = scripts.power_reinforcements_control_KR5.insert
    tt = E:register_t("power_denas_control", "power_reinforcements_control")
    tt.main_script.insert = scripts.power_stage_15_denas_control.insert
    tt.denas_t = "soldier_reinforcement_stage_15_denas"

    function tt.power_cooldown_fn()
        return E:get_template("soldier_reinforcement_stage_15_denas").power_cooldown
    end

    E:set_template("user_power_1", E:get_template("power_reinforcements_control"))
    E:set_template("user_power_2", E:get_template("power_hero_control_custom_1"))
    E:set_template("user_power_3", E:get_template("power_hero_control_custom_2"))

    tt = E:register_t("item_control_custom")

    E:add_comps(tt, "pos", "main_script", "user_selection")

    tt.main_script.insert = scripts.item_control_custom.insert
    tt.user_selection.can_select_point_fn = scripts.item_control_custom.can_select_point
    tt = E:register_t("user_item_1", "item_control_custom")
    tt.item_id = nil
    tt = E:register_t("user_item_2", "item_control_custom")
    tt.item_id = nil
    tt = E:register_t("user_item_3", "item_control_custom")
    tt.item_id = nil
    tt = E:register_t("controller_item")

    E:add_comps(tt, "pos", "main_script")

    tt = E:register_t("controller_item_cluster_bomb", "controller_item")
    tt.main_script.insert = scripts.controller_item_cluster_bomb.insert
    tt.can_fire_fn = scripts.controller_item_cluster_bomb.can_fire_fn
    tt.bullet = "bomb_item_cluster_bomb"
    tt.spawn_height = 15
    tt = E:register_t("controller_item_portable_coil", "controller_item")
    tt.main_script.insert = scripts.controller_item_portable_coil.insert
    tt.can_fire_fn = scripts.controller_item_portable_coil.can_fire_fn
    tt.coil = "decal_item_portable_coil"
    tt = E:register_t("controller_item_scroll_of_spaceshift", "controller_item")
    b = balance.items.scroll_of_spaceshift
    tt.main_script.update = scripts.controller_item_scroll_of_spaceshift.update
    tt.can_fire_fn = scripts.controller_item_scroll_of_spaceshift.can_fire_fn
    tt.teleport_decal = "decal_item_scroll_of_spaceshift"
    tt.teleport_fx = "fx_item_scroll_of_spaceshift"
    tt.vis_bans = bor(F_BOSS)
    tt.vis_flags = bor(F_TELEPORT)
    tt.radius = b.radius
    tt.teleport_dist = b.teleport_dist
    tt.max_targets = b.max_targets
    tt.mod_mark = "mod_item_scroll_of_spaceshift_mark"
    tt.mod_teleport = "mod_item_scroll_of_spaceshift_teleport"
    tt.sound_cast = "ItemsScrollOfSpaceshiftCast"
    tt.sound_teleport_in = "ItemsScrollOfSpaceshiftTeleportIn"
    tt.sound_teleport_out = "ItemsScrollOfSpaceshiftTeleportOut"
    tt = E:register_t("controller_item_second_breath", "controller_item")
    tt.main_script.insert = scripts.controller_item_second_breath.insert
    tt.main_script.update = scripts.controller_item_second_breath.update
    tt.can_fire_fn = scripts.controller_item_second_breath.can_fire_fn
    tt.decal = "decal_item_second_breath"
    tt.respawn_fx = "fx_item_second_breath_respawn"
    tt.tap_fx = "fx_item_second_breath_tap"
    tt.mod_heal = "mod_item_second_breath_heal"
    tt.sound_cast = "ItemsSecondBreathCast"
    tt = E:register_t("controller_item_deaths_touch", "controller_item")
    b = balance.items.deaths_touch
    tt.main_script.insert = scripts.controller_item_deaths_touch.insert
    tt.main_script.update = scripts.controller_item_deaths_touch.update
    tt.can_fire_fn = scripts.controller_item_deaths_touch.can_fire_fn
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.radius = b.radius
    tt.allowed_templates = nil
    tt.excluded_templates = nil
    tt.damage_type_boss = DAMAGE_TRUE
    tt.damage_boss = b.damage_boss
    tt.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
    tt.damage_delay = 0.35
    tt.fx = "fx_item_deaths_touch"
    tt.sound = "ItemsDeathsTouchCast"
    tt = E:register_t("controller_item_loot_box", "controller_item")
    b = balance.items.loot_box
    tt.main_script.insert = scripts.controller_item_loot_box.insert
    tt.can_fire_fn = scripts.controller_item_loot_box.can_fire_fn
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.radius = b.radius
    tt.damage_min = b.damage_min
    tt.damage_max = b.damage_max
    tt.damage_type = DAMAGE_TRUE
    tt.boxes_decals = {"decal_item_loot_box_chest_projectile", "decal_item_loot_box_pig_projectile",
                       "decal_item_loot_box_statue_projectile"}
    tt = E:register_t("controller_item_medical_kit", "controller_item")
    b = balance.items.medical_kit
    tt.can_fire_fn = scripts.controller_item_medical_kit.can_fire_fn
    tt.main_script.insert = scripts.controller_item_medical_kit.insert
    tt.hearts = b.hearts
    tt.sound_cast = "ItemsMedicalKitCast"
    tt = E:register_t("controller_item_winter_age", "controller_item")
    b = balance.items.winter_age
    tt.main_script.update = scripts.controller_item_winter_age.update
    tt.main_script.remove = scripts.controller_item_winter_age.remove
    tt.can_fire_fn = scripts.controller_item_winter_age.can_fire_fn
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.allowed_templates = nil
    tt.excluded_templates = nil
    tt.mod = "mod_item_winter_age_freeze"
    tt.stun_duration = b.stun_duration
    tt.sound_in = "ItemsWinterAgeCast"
    tt.sound_loop = "ItemsWinterAgeLoop"
    tt.sound_out = "ItemsWinterAgeRelease"
    tt = E:register_t("controller_item_summon_blackburn", "controller_item")
    b = balance.items.summon_blackburn
    tt.main_script.insert = scripts.controller_item_summon_blackburn.insert
    tt.can_fire_fn = scripts.controller_item_summon_blackburn.can_fire_fn
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.allowed_templates = nil
    tt.excluded_templates = nil
    tt.blackburn = "soldier_reinforcement_item_summon_blackburn"
    tt.sound_cast = "ItemsBlackburnCast"
    tt = E:register_t("controller_item_veznan_wrath", "controller_item")
    b = balance.items.veznan_wrath
    tt.main_script.update = scripts.controller_item_veznan_wrath.update
    tt.can_fire_fn = scripts.controller_item_veznan_wrath.can_fire_fn
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.allowed_templates = nil
    tt.excluded_templates = nil
    tt.damage_min = b.damage_min
    tt.damage_max = b.damage_max
    tt.controller_overlay = "controller_item_veznan_wrath_overlay"
    tt.controller_explosions = "controller_item_veznan_wrath_explosions"
    tt.fx_instakill_ground = "fx_item_veznan_wrath_instakill_ground"
    tt.decal_instakill_ground = "decal_item_veznan_wrath_instakill_ground"
    tt.fx_instakill_air = "fx_item_veznan_wrath_instakill_air"
    tt.blink_duration = fts(45)
    tt.sound_in = "ItemsVeznanWrathEnter"
    tt.sound_initial_burst = "ItemsVeznanWrathInitialBurst"
    tt.sound_explosion = "ItemsVeznanWrathExplosion"
    tt = E:register_t("controller_item_veznan_wrath_overlay", "controller_item")
    tt.main_script.update = scripts.controller_item_veznan_wrath_overlay.update
    tt.overlay_dark = "decal_item_veznan_wrath_dark_overlay"
    tt.overlay_green = "decal_item_veznan_wrath_green_overlay"
    tt = E:register_t("controller_item_veznan_wrath_explosions", "controller_item")
    tt.main_script.update = scripts.controller_item_veznan_wrath_explosions.update
    tt.fx_explosion = "fx_item_veznan_wrath_explosion"
    tt = E:register_t("trees_arborean_sages", "decal_scripted")
    b = balance.specials.trees.arborean_sages

    E:add_comps(tt, "bullet_attack", "editor")

    tt.render.sprites[1].prefix = "trees_arborean_sages"
    tt.render.sprites[1].name = "holder"
    tt.main_script.update = scripts.trees_arborean_sages.update
    tt.bullet_attack.max_range = b.range
    tt.bullet_attack.bullet = "trees_arborean_sages_bolt"
    tt.bullet_attack.shoot_time = fts(12)
    tt.bullet_attack.cooldown_min = b.cooldown_min
    tt.bullet_attack.cooldown_max = b.cooldown_max
    tt.bullet_attack.bullet_start_offset = vec_2(18, 38)
    tt.bullet_attack.animation = "attack"
    tt.spawn_wave = nil
    tt.leave_wave = nil
    tt.spawn_anim = "spawn"
    tt.leave_anim = "disappear"
    tt.gone_anim = "holder"
    tt.editor.props = {{"spawn_wave", PT_NUMBER}, {"leave_wave", PT_NUMBER}}
    tt = E:register_t("trees_arborean_sages_bolt", "bolt")
    tt.render.sprites[1].prefix = "veznan_hero_bolt"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.bullet.damage_type = b.damage_type
    tt.bullet.damage_max = b.damage_max
    tt.bullet.damage_min = b.damage_min
    tt.bullet.acceleration_factor = 0.1
    tt.bullet.min_speed = 30
    tt.bullet.max_speed = 300
    tt.sound_events.insert = "ElvesHeroVeznanRangeShoot"
    tt.bullet.pop = {"pop_mage"}
    tt.bullet.pop_conds = DR_KILL
    tt = E:register_t("trees_fruity_trees", "decal_scripted")
    b = balance.specials.trees.fruity_tree

    E:add_comps(tt, "custom_attack", "ui", "plant", "editor")

    tt.custom_attack.cooldown = nil
    tt.custom_attack.cooldown_min = b.cooldown_min
    tt.custom_attack.cooldown_max = b.cooldown_max
    tt.custom_attack.range = b.max_range
    tt.custom_attack.distance_between_fruits = 80
    tt.custom_attack.max_fruits = 3
    tt.custom_attack.bullet = "trees_fruity_tree_fruit_proy"
    tt.custom_attack.bullet_start_offset = vec_2(0, 55)
    tt.custom_attack.sound = "ElvesPlantMissile"
    tt.custom_attack.shoot_time = fts(6)
    tt.editor.props = {{"ui.nav_mesh_id", PT_STRING}}
    tt.render.sprites[1].prefix = "trees_fruity_tree"
    tt.render.sprites[1].anchor.y = 0.0641025641025641
    tt.main_script.insert = scripts.trees_fruity_tree.insert
    tt.main_script.update = scripts.trees_fruity_tree.update
    tt.ui.can_click = false
    tt.ui.can_select = false
    tt.ui.click_rect = r(-24, -5, 48, 65)
    tt = E:register_t("trees_fruity_tree_fruit_proy", "bomb")
    tt.bullet.damage_bans = F_ALL
    tt.bullet.damage_flags = 0
    tt.bullet.damage_max = 0
    tt.bullet.damage_min = 0
    tt.bullet.damage_radius = 1
    tt.bullet.flight_time = fts(24)
    tt.bullet.pop = nil
    tt.bullet.hit_payload = "trees_fruity_tree_fruit"
    tt.main_script.insert = scripts.bomb.insert
    tt.main_script.update = scripts.bomb.update
    tt.bullet.hit_fx = nil
    tt.bullet.hit_decal = nil
    tt.bullet.hide_radius = nil
    tt.render.sprites[1].name = "trees_fruity_tree_fruit_proy"
    tt.render.sprites[1].animated = false
    tt.sound_events.insert = "HeroRiflemanMine"
    tt.sound_events.hit = nil
    tt.sound_events.hit_water = nil
    tt = E:register_t("trees_fruity_tree_fruit", "decal_scripted")
    tt.check_interval = fts(3)
    tt.duration = b.duration
    tt.hit_fx = "trees_fruity_tree_fruit_apply_fx"
    tt.main_script.update = scripts.trees_fruity_tree_fruit.update
    tt.radius = b.consume_range
    tt.render.sprites[1].loop = true
    tt.render.sprites[1].name = "trees_fruity_tree_fruit"
    tt.render.sprites[1].z = Z_DECALS
    tt.sound = "BombExplosionSound"
    tt.vis_bans = 0
    tt.vis_flags = 0
    tt.mod = "instant_heal_mod"
    tt.heal_hp = b.heal
    tt = E:register_t("trees_fruity_tree_fruit_apply_fx", "fx")
    tt.render.sprites[1].name = "trees_fruity_tree_fruit_apply_fx"
    tt.render.sprites[1].z = Z_DECALS
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
        function DEBUG_RIGHT_CLICK(x, y)
            local hp = E:create_entity("trees_guardian_tree_vine_aura")

            hp.pos.x, hp.pos.y = x, y

            simulation:queue_insert_entity(hp)
        end
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
    tt.root_hand_L_pos = vec_2(0, 350)
    tt.root_hand_R_pos = vec_2(250, 450)
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
    tt.custom_attack.door1Pos = vec_2(757, 568)
    tt.custom_attack.door2Pos = vec_2(318, 566)
    tt.custom_attack.cast_time = fts(21)
    tt.custom_attack.wait_between_shots = b.wait_between_shots
    tt.custom_attack.min_dist_between_tgts = b.min_dist_between_tgts
    tt.custom_attack.node_prediction = fts(45)
    tt.custom_attack.sound = nil
    tt.custom_attack.bullet = "bullet_stage_03_heart_of_the_arborean"
    tt.custom_attack.bullet_start_offset = vec_2(0, 90)
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
    tt = E:register_t("tower_arborean_sentinels", "tower_KR5")
    b = balance.specials.towers.arborean_sentinels

    E:add_comps(tt, "vis", "barrack")

    tt.tower.type = "tower_arborean_sentinels"
    tt.tower.level = 1
    tt.tower.kind = TOWER_KIND_BARRACK
    tt.tower.can_be_sold = false
    tt.tower.can_be_mod = false
    tt.info.portrait = "portraits_towers_0008"
    tt.info.fn = scripts.tower_barrack_mercenaries.get_info
    tt.main_script.update = scripts.tower_barrack_mercenaries_KR5.update
    tt.main_script.remove = scripts.tower_barrack.remove

    function tt.main_script.insert(this, store, script)
        if this.render.sprites[1].flip_x == true then
            this.barrack.respawn_offset.x = this.barrack.respawn_offset.x * -1
        end

        return scripts.tower_barrack.insert(this, store, script)
    end

    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "stage4_barrack_holder"
    tt.render.sprites[1].offset = vec_2(0, 8)
    tt.render.sprites[2] = E:clone_c("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "arborean_barrack_lvl1"
    tt.render.sprites[2].z = Z_OBJECTS
    tt.render.sprites[2].sort_y_offset = -8
    tt.render.sprites[3] = E:clone_c("sprite")
    tt.render.sprites[3].prefix = "arborean_barrack_lvl1_door"
    tt.render.sprites[3].name = "close"
    tt.render.sprites[3].loop = false
    tt.render.sprites[3].z = Z_OBJECTS
    tt.render.sprites[3].offset = vec_2(3, -4)
    tt.render.sprites[3].sort_y_offset = -8
    tt.render.door_sid = 3
    tt.barrack.soldier_type = "soldier_arborean_sentinels_spearmen"
    tt.barrack.rally_range = 209.28
    tt.barrack.respawn_offset = vec_2(0, 5)
    tt.sound_events.change_rally_point = "Stage04ArboreanThornspears"
    tt = E:register_t("soldier_arborean_sentinels_spearmen", "soldier_militia")

    E:add_comps(tt, "powers", "timed_attacks", "ranged", "nav_grid")

    tt.health.armor = b.spearmen.armor
    tt.health.hp_max = b.spearmen.hp_max
    tt.regen.health = b.spearmen.regen_health
    tt.health_bar.offset = vec_2(0, 35)
    tt.health.delete_after = 2
    tt.health.dead_lifetime = 1
    tt.info.portrait = "gui_bottom_info_image_soldiers_0008"
    tt.info.random_name_format = "SOLDIER_ARBOREAN_SENTINELS_%i_NAME"
    tt.info.random_name_count = 9
    tt.main_script.insert = scripts.soldier_barrack.insert
    tt.main_script.update = scripts.soldier_barrack.update
    tt.melee.attacks[1].cooldown = b.spearmen.melee_attack.cooldown
    tt.melee.attacks[1].damage_max = b.spearmen.melee_attack.damage_max
    tt.melee.attacks[1].damage_min = b.spearmen.melee_attack.damage_min
    tt.melee.attacks[1].hit_time = fts(10)
    tt.melee.range = b.spearmen.melee_attack.range
    tt.motion.max_speed = b.spearmen.max_speed
    tt.ranged.attacks[1].animation = "ranged_attack"
    tt.ranged.attacks[1].bullet = "arborean_sentinels_spearmen_spear"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 25)}
    tt.ranged.attacks[1].cooldown = b.spearmen.ranged_attack.cooldown
    tt.ranged.attacks[1].max_range = b.spearmen.ranged_attack.max_range
    tt.ranged.attacks[1].min_range = b.spearmen.ranged_attack.min_range
    tt.ranged.attacks[1].shoot_time = fts(6)
    tt.render.sprites[1].prefix = "stage_4_special_arborean_sentinels_spearer_soldier"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.soldier.melee_slot_offset = vec_2(5, 0)
    tt.unit.price = b.spearmen.price
    tt.unit.fade_time_after_death = 1
    tt.sound_events.insert = "Stage04ArboreanThornspears"
    tt = E:register_t("arborean_sentinels_spearmen_spear", "arrow")
    tt.bullet.damage_max = b.spearmen.ranged_attack.damage_max
    tt.bullet.damage_min = b.spearmen.ranged_attack.damage_min
    tt.bullet.damage_type = b.spearmen.ranged_attack.damage_type
    tt.bullet.miss_decal = "stage_4_special_arborean_sentinels_spearer_spear_decal"
    tt.bullet.flight_time = fts(14)
    tt.bullet.hide_radius = 10
    tt.bullet.hit_fx = "fx_arborean_sentinels_spearmen_spear_hit"
    tt.render.sprites[1].name = "stage_4_special_arborean_sentinels_spearer_spear"
    tt.sound_events.insert = "TowerForestKeeperNormalSpear"
    tt = E:register_t("soldier_arborean_sentinels_barkshield", "soldier_militia")
    tt.info.portrait = "portraits_sc_0003"
    tt.info.random_name_format = "SOLDIER_ARBOREAN_SENTINELS_%i_NAME"
    tt.info.random_name_count = 9
    tt.render.sprites[1].prefix = "stage_4_special_arborean_sentinels_barkshield_soldier"
    tt.render.sprites[1].anchor = vec_2(0.5, 0.5)
    tt.regen.health = b.barkshield.regen_health
    tt.health.hp_max = b.barkshield.hp_max
    tt.health.armor = b.barkshield.armor
    tt.health_bar.offset = vec_2(0, 41)
    tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
    tt.melee.attacks[1].cooldown = b.barkshield.melee_attack.cooldown
    tt.melee.attacks[1].damage_min = b.barkshield.melee_attack.damage_min
    tt.melee.attacks[1].damage_max = b.barkshield.melee_attack.damage_max
    tt.melee.attacks[1].hit_time = fts(8)
    tt.melee.range = b.barkshield.melee_attack.range
    tt.motion.max_speed = b.barkshield.max_speed
    tt.main_script.insert = scripts.soldier_barrack.insert
    tt.main_script.update = scripts.soldier_barrack.update
    tt.unit.price = b.barkshield.price
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
    tt.tween.props[2].keys = {{0, vec_2(0, 80)}, {fts(5), vec_2(0, 0)}}
    tt.tween.props[2].sprite_id = 1
    tt.tween.props[3] = E:clone_c("tween_prop")
    tt.tween.props[3].name = "offset"
    tt.tween.props[3].keys = {{0, vec_2(0, 100)}, {fts(5), vec_2(0, 0)}}
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
    tt.spawn_pos = vec_2(242, 459)
    tt.waypoint_pos = vec_2(220, 459)
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
    tt.bullet_attack.bullet_start_offset = {vec_2(20, 20), vec_2(-20, 20)}
    tt.bullet_attack.animation = "shoot"
    tt.bullet_attack.vis_bans = bor(F_MINIBOSS, F_NIGHTMARE)
    tt.idle_rest_cooldown = 2
    tt = E:register_t("arrow_soldier_elf_stage_08", "arrow5_45degrees")
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

end
