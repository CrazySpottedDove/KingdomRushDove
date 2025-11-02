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

local function foundamental_towers()
    tt = RT("tower_holder")
    AC(tt, "tower", "tower_holder", "pos", "render", "ui", "editor", "editor_script")
    tt.ui.click_rect = r(-40, -12, 80, 46)
    tt.ui.has_nav_mesh = true
    tt.tower.level = 1
    tt.tower.type = "holder"
    tt.tower.can_be_mod = false
    tt.tower_holder.preview_ids = {
        archer = 2,
        engineer = 5,
        barrack = 3,
        mage = 4
    }
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "build_terrain_%04i"
    tt.render.sprites[1].offset = vec_2(0, 17)
    tt.render.sprites[1].z = Z_DECALS
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].name = "tower_preview_archer"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].hidden = true
    tt.render.sprites[2].offset = vec_2(0, 37)
    tt.render.sprites[2].alpha = 180
    tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[3].name = "tower_preview_barrack"
    tt.render.sprites[3].offset = vec_2(0, 38)
    tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[4].name = "tower_preview_mage"
    tt.render.sprites[4].offset = vec_2(0, 30)
    tt.render.sprites[5] = table.deepclone(tt.render.sprites[2])
    tt.render.sprites[5].name = "tower_preview_artillery"
    tt.render.sprites[5].offset = vec_2(0, 41)
    tt.editor.props = {{"tower.terrain_style", PT_NUMBER}, {"tower.default_rally_pos", PT_COORDS},
                       {"tower.holder_id", PT_STRING}, {"ui.nav_mesh_id", PT_STRING}, {"editor.game_mode", PT_NUMBER}}
    tt.editor_script.insert = scripts.editor_tower.insert
    tt.editor_script.remove = scripts.editor_tower.remove
    tt = RT("tower_holder_grass", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_GRASS
    tt.render.sprites[1].name = "build_terrain_0001"
    tt = RT("tower_holder_snow", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_SNOW
    tt.render.sprites[1].name = "build_terrain_0002"
    tt = RT("tower_holder_wasteland", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_WASTELAND
    tt.render.sprites[1].name = "build_terrain_0003"
    tt = RT("tower_holder_blackburn", "tower_holder")
    tt.tower.terrain_style = TERRAIN_STYLE_BLACKBURN
    tt.render.sprites[1].name = "build_terrain_0008"
    tt = RT("tower_build_archer", "tower_build")
    tt.build_name = "tower_archer_1"
    tt.render.sprites[2].name = "tower_constructing_0004"
    tt.render.sprites[2].offset = vec_2(0, 39)
    tt = RT("tower_build_barrack", "tower_build_archer")
    tt.build_name = "tower_barrack_1"
    tt.render.sprites[2].name = "tower_constructing_0002"
    tt.render.sprites[2].offset = vec_2(0, 40)
    tt = RT("tower_build_mage", "tower_build_archer")
    tt.build_name = "tower_mage_1"
    tt.render.sprites[2].name = "tower_constructing_0003"
    tt.render.sprites[2].offset = vec_2(0, 31)
    tt = RT("tower_build_engineer", "tower_build_archer")
    tt.build_name = "tower_engineer_1"
    tt.render.sprites[2].name = "tower_constructing_0001"
    tt.render.sprites[2].offset = vec_2(0, 41)

    tt = RT("tower_mage_1", "tower")
    AC(tt, "attacks")
    tt.tower.type = "mage"
    tt.tower.level = 1
    tt.tower.price = 100
    tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0003" or "info_portraits_towers_0010"
    tt.info.enc_icon = 3
    tt.info.fn = scripts.tower_mage.get_info
    tt.main_script.insert = scripts.tower_mage.insert
    tt.main_script.update = scripts.tower_mage.update
    tt.attacks.range = 140
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].animation = "shoot"
    tt.attacks.list[1].bullet = "bolt_1"
    tt.attacks.list[1].cooldown = 1.5
    tt.attacks.list[1].shoot_time = fts(8)
    tt.attacks.list[1].bullet_start_offset = {vec_2(8, 66), vec_2(-5, 62)}
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_mage_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].prefix = "towermagelvl1"
    tt.render.sprites[2].name = "idle"
    tt.render.sprites[2].offset = vec_2(0, 30)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "shootermage"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {
        idle = {"idleUp", "idleDown"},
        shoot = {"shootingUp", "shootingDown"}
    }
    tt.render.sprites[3].offset = vec_2(1, 57)
    tt.render.sid_tower = 2
    tt.render.sid_shooter = 3
    tt.sound_events.insert = "MageTaunt"
    tt = RT("tower_mage_2", "tower_mage_1")
    tt.info.enc_icon = 7
    tt.tower.level = 2
    tt.tower.price = 160
    tt.attacks.range = 160
    tt.attacks.list[1].bullet = "bolt_2"
    tt.attacks.list[1].bullet_start_offset = {vec_2(8, 66), vec_2(-5, 64)}
    tt.render.sprites[2].prefix = "towermagelvl2"
    tt.render.sprites[3].offset = vec_2(1, 57)
    tt = RT("tower_mage_3", "tower_mage_1")
    tt.info.enc_icon = 11
    tt.tower.level = 3
    tt.tower.price = 240
    tt.attacks.range = 180
    tt.attacks.list[1].bullet = "bolt_3"
    tt.attacks.list[1].bullet_start_offset = {vec_2(8, 70), vec_2(-5, 69)}
    tt.render.sprites[2].prefix = "towermagelvl3"
    tt.render.sprites[3].offset = vec_2(1, 62)

    tt = RT("bolt_1", "bolt")
    tt.bullet.damage_min = 11
    tt.bullet.damage_max = 19
    tt = RT("bolt_2", "bolt")
    tt.bullet.damage_min = 25
    tt.bullet.damage_max = 47
    tt = RT("bolt_3", "bolt")
    tt.bullet.damage_min = 44
    tt.bullet.damage_max = 81

    tt = RT("tower_engineer_1", "tower")
    AC(tt, "attacks")
    tt.tower.type = "engineer"
    tt.tower.level = 1
    tt.tower.price = 125
    tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0004" or "info_portraits_towers_0003"
    tt.info.enc_icon = 4
    tt.main_script.insert = scripts.tower_engineer.insert
    tt.main_script.update = scripts.tower_engineer.update
    tt.attacks.range = 160
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].bullet = "bomb"
    tt.attacks.list[1].cooldown = 3
    tt.attacks.list[1].shoot_time = fts(12)
    tt.attacks.list[1].vis_bans = bor(F_FLYING)
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 50)
    tt.attacks.list[1].node_prediction = true
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_artillery_%04i"
    tt.render.sprites[1].offset = vec_2(0, 15)

    for i = 2, 8 do
        tt.render.sprites[i] = CC("sprite")
        tt.render.sprites[i].prefix = "towerengineerlvl1_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 41)
    end

    tt.sound_events.insert = "EngineerTaunt"
    tt = RT("tower_engineer_2", "tower_engineer_1")
    tt.info.enc_icon = 8
    tt.tower.level = 2
    tt.tower.price = 220
    tt.attacks.list[1].bullet = "bomb_dynamite"
    tt.attacks.list[1].cooldown = 3
    tt.attacks.list[1].shoot_time = fts(12)
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 53)

    for i = 2, 8 do
        tt.render.sprites[i] = CC("sprite")
        tt.render.sprites[i].prefix = "towerengineerlvl2_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 42)
    end

    tt = RT("tower_engineer_3", "tower_engineer_1")
    tt.info.enc_icon = 12
    tt.tower.level = 3
    tt.tower.price = 320
    tt.attacks.range = 180
    tt.attacks.list[1].bullet = "bomb_black"
    tt.attacks.list[1].cooldown = 3
    tt.attacks.list[1].shoot_time = fts(12)
    tt.attacks.list[1].bullet_start_offset = vec_2(0, 57)

    for i = 2, 8 do
        tt.render.sprites[i] = CC("sprite")
        tt.render.sprites[i].prefix = "towerengineerlvl3_layer" .. i - 1
        tt.render.sprites[i].name = "idle"
        tt.render.sprites[i].offset = vec_2(0, 43)
    end

    tt = RT("tower_archer_1", "tower")

    AC(tt, "attacks")

    tt.tower.type = "archer"
    tt.tower.level = 1
    tt.tower.price = 70
    tt.info.portrait = "info_portraits_towers_0001"
    tt.info.enc_icon = 1
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_archer_%04i"
    tt.render.sprites[1].offset = vec_2(0, 12)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "archer_tower_0001"
    tt.render.sprites[2].offset = vec_2(0, 37)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "shooterarcherlvl1"
    tt.render.sprites[3].name = "idleDown"
    tt.render.sprites[3].angles = {
        idle = {"idleUp", "idleDown"},
        shoot = {"shootingUp", "shootingDown"}
    }
    tt.render.sprites[3].offset = vec_2(-9, 51)
    tt.render.sprites[4] = CC("sprite")
    tt.render.sprites[4].prefix = "shooterarcherlvl1"
    tt.render.sprites[4].name = "idleDown"
    tt.render.sprites[4].angles = {
        idle = {"idleUp", "idleDown"},
        shoot = {"shootingUp", "shootingDown"}
    }
    tt.render.sprites[4].offset = vec_2(9, 51)
    tt.main_script.insert = scripts.tower_archer.insert
    tt.main_script.update = scripts.tower_archer.update
    tt.main_script.remove = scripts.tower_archer.remove
    tt.attacks.range = 140
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].bullet = "arrow_1"
    tt.attacks.list[1].cooldown = 0.8
    tt.attacks.list[1].shoot_time = fts(5)
    tt.attacks.list[1].bullet_start_offset = {vec_2(-10, 50), vec_2(10, 50)}
    tt.sound_events.insert = "ArcherTaunt"
    tt = RT("tower_archer_2", "tower_archer_1")
    tt.info.enc_icon = 5
    tt.tower.level = 2
    tt.tower.price = 110
    tt.render.sprites[2].name = "archer_tower_0002"
    tt.render.sprites[3].prefix = "shooterarcherlvl2"
    tt.render.sprites[3].offset = vec_2(-9, 52)
    tt.render.sprites[4].prefix = "shooterarcherlvl2"
    tt.render.sprites[4].offset = vec_2(9, 52)
    tt.attacks.range = 160
    tt.attacks.list[1].bullet = "arrow_2"
    tt.attacks.list[1].cooldown = 0.6
    tt = RT("tower_archer_3", "tower_archer_1")
    tt.info.enc_icon = 9
    tt.tower.level = 3
    tt.tower.price = 160
    tt.render.sprites[2].name = "archer_tower_0003"
    tt.render.sprites[3].prefix = "shooterarcherlvl3"
    tt.render.sprites[3].offset = vec_2(-9, 57)
    tt.render.sprites[4].prefix = "shooterarcherlvl3"
    tt.render.sprites[4].offset = vec_2(9, 57)
    tt.attacks.range = 180
    tt.attacks.list[1].bullet = "arrow_3"
    tt.attacks.list[1].cooldown = 0.5

    tt = RT("arrow_1", "arrow")
    tt.bullet.damage_min = 4
    tt.bullet.damage_max = 7

    tt = RT("arrow_2", "arrow")
    tt.bullet.damage_min = 8
    tt.bullet.damage_max = 12
    tt.bullet.flight_time = fts(21)

    tt = RT("arrow_3", "arrow")
    tt.bullet.damage_min = 11
    tt.bullet.damage_max = 18
    tt.bullet.flight_time = fts(20)

    tt = RT("tower_barrack_1", "tower")
    AC(tt, "barrack")
    tt.tower.type = "barrack"
    tt.tower.level = 1
    tt.tower.price = 70
    tt.info.fn = scripts.tower_barrack.get_info
    tt.info.portrait = IS_PHONE_OR_TABLET and "portraits_towers_0002" or "info_portraits_towers_0007"
    tt.info.enc_icon = 2
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].name = "terrain_barrack_%04i"
    tt.render.sprites[1].offset = vec_2(0, 13)
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].name = "tower_barracks_lvl1_layer1_0001"
    tt.render.sprites[2].offset = vec_2(0, 38)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].prefix = "towerbarracklvl1_door"
    tt.render.sprites[3].name = "close"
    tt.render.sprites[3].loop = false
    tt.render.sprites[3].offset = vec_2(0, 38)
    tt.barrack.soldier_type = "soldier_militia"
    tt.barrack.rally_range = 145
    tt.barrack.respawn_offset = vec_2(0, 0)
    tt.main_script.insert = scripts.tower_barrack.insert
    tt.main_script.update = scripts.tower_barrack.update
    tt.main_script.remove = scripts.tower_barrack.remove
    tt.sound_events.insert = "BarrackTaunt"
    tt.sound_events.change_rally_point = "BarrackTaunt"
    tt = RT("tower_barrack_2", "tower_barrack_1")
    tt.info.enc_icon = 6
    tt.tower.level = 2
    tt.tower.price = 110
    tt.render.sprites[2].name = "tower_barracks_lvl2_layer1_0001"
    tt.render.sprites[3].prefix = "towerbarracklvl2_door"
    tt.barrack.soldier_type = "soldier_footmen"
    tt.barrack.rally_range = 150
    tt = RT("tower_barrack_3", "tower_barrack_1")
    tt.info.enc_icon = 10
    tt.tower.level = 3
    tt.tower.price = 150
    tt.render.sprites[2].name = "tower_barracks_lvl3_layer1_0001"
    tt.render.sprites[3].prefix = "towerbarracklvl3_door"
    tt.barrack.soldier_type = "soldier_knight"
    tt.barrack.rally_range = 155

    tt = RT("tower_neptune_holder")
    AC(tt, "tower", "tower_holder", "pos", "render", "ui", "info")
    tt.tower.level = 1
    tt.tower.type = "holder_neptune"
    tt.tower.can_be_mod = false
    tt.info.fn = scripts.tower_neptune_holder.get_info
    tt.info.portrait = "kr2_info_portraits_towers_0021"
    tt.render.sprites[1].name = "neptuno_0001"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].offset = vec_2(0, 7)
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].hover_off_hidden = true
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].name = "neptuno_0001"
    tt.render.sprites[2].animated = false
    tt.render.sprites[2].offset = vec_2(0, 39)
    tt.ui.click_rect = r(-40, -10, 80, 90)

    tt = RT("tower_neptune", "tower")
    AC(tt, "powers", "user_selection", "attacks")
    tt.tower.level = 1
    tt.tower.type = "neptune"
    tt.tower.price = 500
    tt.tower.can_be_mod = false
    tt.tower.terrain_style = nil
    tt.info.portrait = "kr2_info_portraits_towers_0021"
    tt.info.fn = scripts.tower_neptune.get_info
    tt.ui.click_rect = r(-40, -10, 80, 90)
    tt.powers.ray = CC("power")
    tt.powers.ray.level = 1
    tt.powers.ray.max_level = 3
    tt.powers.ray.price_inc = 500
    tt.powers.ray.enc_icon = 26
    tt.main_script.insert = scripts.tower_neptune.insert
    tt.main_script.update = scripts.tower_neptune.update
    tt.render.sprites[1].name = "neptuno_0002"
    tt.render.sprites[1].animated = false
    tt.render.sprites[1].offset = vec_2(0, 7)
    tt.render.sprites[1].hidden = true
    tt.render.sprites[1].hover_off_hidden = true
    tt.render.sprites[2] = CC("sprite")
    tt.render.sprites[2].name = "towerneptune_trident_glow"
    tt.render.sprites[2].offset = vec_2(0, 39)
    tt.render.sprites[3] = CC("sprite")
    tt.render.sprites[3].name = "neptuno_0002"
    tt.render.sprites[3].animated = false
    tt.render.sprites[3].offset = vec_2(0, 39)
    tt.render.sprites[4] = CC("sprite")
    tt.render.sprites[4].prefix = "towerneptune"
    tt.render.sprites[4].name = "charged"
    tt.render.sprites[4].offset = vec_2(0, 39)
    tt.render.sprites[5] = CC("sprite")
    tt.render.sprites[5].prefix = "towerneptune_gems_3"
    tt.render.sprites[5].name = "ready"
    tt.render.sprites[5].offset = vec_2(0, 39)
    tt.render.sprites[5].fps = 15
    tt.render.sprites[6] = CC("sprite")
    tt.render.sprites[6].prefix = "towerneptune_gems_1"
    tt.render.sprites[6].name = "empty"
    tt.render.sprites[6].offset = vec_2(0, 39)
    tt.render.sprites[6].fps = 15
    tt.render.sprites[6].hidden = true
    tt.render.sprites[7] = CC("sprite")
    tt.render.sprites[7].prefix = "towerneptune_gems_2"
    tt.render.sprites[7].name = "empty"
    tt.render.sprites[7].offset = vec_2(0, 39)
    tt.render.sprites[7].fps = 15
    tt.render.sprites[7].hidden = true
    tt.render.sprites[8] = CC("sprite")
    tt.render.sprites[8].prefix = "towerneptune_gems_eyes"
    tt.render.sprites[8].name = "empty"
    tt.render.sprites[8].offset = vec_2(0, 39)
    tt.render.sprites[8].loop = false
    tt.render.sprites[9] = CC("sprite")
    tt.render.sprites[9].prefix = "towerneptune_gems_trident"
    tt.render.sprites[9].name = "empty"
    tt.render.sprites[9].offset = vec_2(0, 39)
    tt.render.sprites[9].loop = false
    tt.render.sprites[10] = CC("sprite")
    tt.render.sprites[10].prefix = "towerneptune_tip_glow"
    tt.render.sprites[10].name = "pick"
    tt.render.sprites[10].offset = vec_2(17, 105)
    tt.render.sprites[10].hidden = true
    tt.sound_events.insert = "GUITowerBuilding"
    tt.sound_events.mute_on_level_insert = true
    tt.attacks.list[1] = CC("bullet_attack")
    tt.attacks.list[1].bullet = "ray_neptune"
    tt.attacks.list[1].cooldown = 30
    tt.attacks.list[1].bullet_start_offset = vec_2(17, 105)

    tt = RT("ray_neptune", "bullet")
    tt.image_width = 358
    tt.main_script.update = scripts.ray_neptune.update
    tt.render.sprites[1].name = "ray_neptune"
    tt.render.sprites[1].loop = false
    tt.render.sprites[1].anchor = vec_2(0, 0.5)
    tt.bullet.damage_type = DAMAGE_TRUE
    tt.bullet.damage_min_levels = {250, 500, 1000}
    tt.bullet.damage_max_levels = {750, 1500, 2000}
    tt.bullet.damage_radius = 38.4
    tt.bullet.damage_rect = r(-40, -2, 80, 50)
    tt.bullet.hit_fx = "fx_ray_neptune_explosion"
    tt.sound_events.insert = "PolymorphSound"
    tt = RT("fx_ray_neptune_explosion", "decal_timed")
    tt.render.sprites[1].name = "ray_neptune_explosion"
    tt.render.sprites[1].anchor.y = 0.24444444444444444
    tt.render.sprites[1].z = Z_BULLETS

    tt = RT("rock_1", "bomb")
    tt.bullet.flight_time = fts(28)
    tt.bullet.damage_radius = 60
    tt.bullet.damage_max = 12
    tt.bullet.damage_min = 7
    tt.bullet.hit_fx = "fx_rock_explosion"
    tt.bullet.hit_decal = "decal_rock_crater"
    tt.bullet.pop = {"pop_artillery"}
    tt.bullet.mod = "mod_rock_slow"
    tt.render.sprites[1].name = "artillery_thrower_proy"
    tt.sound_events.insert = "TowerStoneDruidBoulderThrow"
    tt.sound_events.hit = "TowerStoneDruidBoulderExplote"
    tt.sound_events.hit_water = "RTWaterExplosion"

    tt = RT("rock_2", "rock_1")
    tt.bullet.damage_max = 30
    tt.bullet.damage_min = 18
    tt = RT("rock_3", "rock_1")
    tt.bullet.damage_max = 50
    tt.bullet.damage_min = 30

    tt = RT("mod_rock_slow", "mod_slow")
    tt.modifier.duration = 0.75

    tt = RT("soldier_barrack_1", "soldier_militia")
    AC(tt, "revive")
    image_y = 46
    anchor_y = 11 / image_y
    tt.health.armor = 0.3
    tt.health.dead_lifetime = 14
    tt.health.hp_max = 50
    tt.health_bar.offset = vec_2(0, 27)
    tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
    tt.idle_flip.chance = 0.4
    tt.idle_flip.cooldown = 5
    tt.info.fn = scripts.soldier_barrack.get_info
    tt.info.portrait = "info_portraits_soldiers_0001"
    tt.info.random_name_count = 25
    tt.info.random_name_format = "ELVES_SOLDIER_BARRACKS_%i_NAME"
    tt.main_script.insert = scripts.soldier_barrack.insert
    tt.main_script.remove = scripts.soldier_barrack.remove
    tt.main_script.update = scripts.soldier_barrack.update
    tt.melee.attacks[1].cooldown = 1
    tt.melee.attacks[1].damage_max = 4
    tt.melee.attacks[1].damage_min = 1
    tt.melee.attacks[1].hit_time = fts(5)
    tt.melee.attacks[1].pop = {"pop_barrack1", "pop_barrack2"}
    tt.melee.attacks[1].sound = "MeleeSword"
    tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
    tt.melee.attacks[1].vis_flags = F_BLOCK
    tt.melee.range = 60
    tt.motion.max_speed = 75
    tt.regen.cooldown = 1
    tt.render.sprites[1] = CC("sprite")
    tt.render.sprites[1].anchor.y = anchor_y
    tt.render.sprites[1].angles = {}
    tt.render.sprites[1].angles.walk = {"running"}
    tt.render.sprites[1].prefix = "soldier_barrack_1"
    tt.revive.disabled = true
    tt.revive.chance = 0.1
    tt.revive.health_recover = 1
    tt.revive.fx = "fx_soldier_barrack_revive"
    tt.soldier.melee_slot_offset = vec_2(5, 0)
    tt.ui.click_rect = r(-10, -2, 20, 25)
    tt.unit.hit_offset = vec_2(0, 12)
    tt.unit.marker_offset = vec_2(0, 0)
    tt.unit.mod_offset = vec_2(0, 10)
    tt = RT("soldier_barrack_2", "soldier_barrack_1")

    AC(tt, "ranged")

    image_y = 46
    anchor_y = 11 / image_y
    tt.health.armor = 0.4
    tt.health.hp_max = 90
    tt.health_bar.offset = vec_2(0, 27)
    tt.info.portrait = "info_portraits_soldiers_0002"
    tt.melee.attacks[1].damage_max = 7
    tt.melee.attacks[1].damage_min = 3
    tt.ranged.attacks[1].animation = "ranged_attack"
    tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_2"
    tt.ranged.attacks[1].bullet_start_offset = {vec_2(6, 10)}
    tt.ranged.attacks[1].cooldown = 1.2 + fts(15)
    tt.ranged.attacks[1].max_range = 140
    tt.ranged.attacks[1].min_range = 25
    tt.ranged.attacks[1].shoot_time = fts(5)
    tt.render.sprites[1].prefix = "soldier_barrack_2"
    tt = RT("soldier_barrack_3", "soldier_barrack_2")
    image_y = 46
    anchor_y = 11 / image_y
    tt.health.armor = 0.5
    tt.health.hp_max = 140
    tt.health_bar.offset = vec_2(0, 32)
    tt.info.portrait = "info_portraits_soldiers_0003"
    tt.melee.attacks[1].damage_max = 12
    tt.melee.attacks[1].damage_min = 8
    tt.ranged.attacks[1].bullet = "arrow_soldier_barrack_3"
    tt.ranged.attacks[1].cooldown = 1 + fts(15)
    tt.ranged.attacks[1].max_range = 150
    tt.ranged.attacks[1].min_range = 25
    tt.render.sprites[1].prefix = "soldier_barrack_3"
    tt.unit.mod_offset = vec_2(0, 12)

end

return foundamental_towers
