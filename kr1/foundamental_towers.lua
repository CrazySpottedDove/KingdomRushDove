local i18n = require("i18n")

require("all.constants")

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

local v = require("lib.klua.vector").v
local vv = require("lib.klua.vector").vv

require("game_templates_utils")

--#region tower_holder
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
tt.editor.props = {{"tower.terrain_style", PT_NUMBER}, {"tower.default_rally_pos", PT_COORDS}, {"tower.holder_id", PT_STRING}, {"ui.nav_mesh_id", PT_STRING}, {"editor.game_mode", PT_NUMBER}}
tt.editor_script.insert = scripts.editor_tower.insert
tt.editor_script.remove = scripts.editor_tower.remove
--#endregion
--#region tower_holder_grass
tt = RT("tower_holder_grass", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_GRASS
tt.render.sprites[1].name = "build_terrain_0001"
--#endregion
--#region tower_holder_snow
tt = RT("tower_holder_snow", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_SNOW
tt.render.sprites[1].name = "build_terrain_0002"
--#endregion
--#region tower_holder_wasteland
tt = RT("tower_holder_wasteland", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WASTELAND
tt.render.sprites[1].name = "build_terrain_0003"
--#endregion
--#region tower_holder_blackburn
tt = RT("tower_holder_blackburn", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_BLACKBURN
tt.render.sprites[1].name = "build_terrain_0008"
--#endregion
tt = E:register_t("tower_holder_sea_of_trees", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FOREST
-- tt.render.sprites[1].name = "build_terrain_0016"
tt.render.sprites[1].name = "build_terrain_0001"
tt = E:register_t("tower_holder_sea_of_trees_2", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_DEFOREST
-- tt.render.sprites[1].name = "build_terrain_0017"
tt.render.sprites[1].name = "build_terrain_0007"
tt = E:register_t("tower_holder_sea_of_trees_3", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WILDBOAR
-- tt.render.sprites[1].name = "build_terrain_0018"
tt.render.sprites[1].name = "build_terrain_0007"
tt = E:register_t("tower_holder_sea_of_trees_4", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_TEMPLE
-- tt.render.sprites[1].name = "build_terrain_0019"
tt.render.sprites[1].name = "build_terrain_0003"
tt = E:register_t("tower_holder_sea_of_trees_5", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ROTTEN
-- tt.render.sprites[1].name = "build_terrain_0020"
tt.render.sprites[1].name = "build_terrain_0006"
tt = E:register_t("tower_holder_sea_of_trees_6", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_ANGER
-- tt.render.sprites[1].name = "build_terrain_0021"
tt.render.sprites[1].name = "build_terrain_0002"
tt = E:register_t("tower_holder_sea_of_trees_7", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_HUNGER
-- tt.render.sprites[1].name = "build_terrain_0022"
tt.render.sprites[1].name = "build_terrain_0005"
tt = E:register_t("tower_holder_sea_of_trees_8", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_DWARF
-- tt.render.sprites[1].name = "build_terrain_0023"
tt.render.sprites[1].name = "build_terrain_0006"
tt = E:register_t("tower_holder_sea_of_trees_9", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_FACTORY
-- tt.render.sprites[1].name = "build_terrain_0024"
tt.render.sprites[1].name = "build_terrain_0006"
tt = E:register_t("tower_holder_sea_of_trees_10", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_1
-- tt.render.sprites[1].name = "build_terrain_0025"
tt.render.sprites[1].name = "build_terrain_0001"
tt = E:register_t("tower_holder_sea_of_trees_11", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_2
-- tt.render.sprites[1].name = "build_terrain_0026"
tt.render.sprites[1].name = "build_terrain_0001"
tt = E:register_t("tower_holder_sea_of_trees_12", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_3
tt.render.sprites[1].name = "build_terrain_0027"
tt = E:register_t("tower_holder_sea_of_trees_13", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_4
tt.render.sprites[1].name = "build_terrain_0028"
tt = E:register_t("tower_holder_sea_of_trees_14", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_5
tt.render.sprites[1].name = "build_terrain_0029"
tt = E:register_t("tower_holder_sea_of_trees_15", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_6
tt.render.sprites[1].name = "build_terrain_0030"
tt = E:register_t("tower_holder_sea_of_trees_16", "tower_holder")
tt.tower.terrain_style = TERRAIN_STYLE_WUKONG_7
tt.render.sprites[1].name = "build_terrain_0031"

--#region tower_build_archer
tt = RT("tower_build_archer", "tower_build")
tt.build_name = "tower_archer_1"
tt.render.sprites[2].name = "tower_constructing_0004"
tt.render.sprites[2].offset = vec_2(0, 39)
--#endregion
--#region tower_build_barrack
tt = RT("tower_build_barrack", "tower_build_archer")
tt.build_name = "tower_barrack_1"
tt.render.sprites[2].name = "tower_constructing_0002"
tt.render.sprites[2].offset = vec_2(0, 40)
--#endregion
--#region tower_build_mage
tt = RT("tower_build_mage", "tower_build_archer")
tt.build_name = "tower_mage_1"
tt.render.sprites[2].name = "tower_constructing_0003"
tt.render.sprites[2].offset = vec_2(0, 31)
--#endregion
--#region tower_build_engineer
tt = RT("tower_build_engineer", "tower_build_archer")
tt.build_name = "tower_engineer_1"
tt.render.sprites[2].name = "tower_constructing_0001"
tt.render.sprites[2].offset = vec_2(0, 41)
--#endregion
--#region tower_mage_1
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
--#endregion
--#region tower_mage_2
tt = RT("tower_mage_2", "tower_mage_1")
tt.info.enc_icon = 7
tt.tower.level = 2
tt.tower.price = 160
tt.attacks.range = 160
tt.attacks.list[1].bullet = "bolt_2"
tt.attacks.list[1].bullet_start_offset = {vec_2(8, 66), vec_2(-5, 64)}
tt.render.sprites[2].prefix = "towermagelvl2"
tt.render.sprites[3].offset = vec_2(1, 57)
--#endregion
--#region tower_mage_3
tt = RT("tower_mage_3", "tower_mage_1")
tt.info.enc_icon = 11
tt.tower.level = 3
tt.tower.price = 240
tt.attacks.range = 180
tt.attacks.list[1].bullet = "bolt_3"
tt.attacks.list[1].bullet_start_offset = {vec_2(8, 70), vec_2(-5, 69)}
tt.render.sprites[2].prefix = "towermagelvl3"
tt.render.sprites[3].offset = vec_2(1, 62)
--#endregion
--#region bolt_1
tt = RT("bolt_1", "bolt")
tt.bullet.damage_min = 11
tt.bullet.damage_max = 19
--#endregion
--#region bolt_2
tt = RT("bolt_2", "bolt")
tt.bullet.damage_min = 25
tt.bullet.damage_max = 47
--#endregion
--#region bolt_3
tt = RT("bolt_3", "bolt")
tt.bullet.damage_min = 44
tt.bullet.damage_max = 81
--#endregion
--#region tower_engineer_1
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
--#endregion
--#region tower_engineer_2
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

--#endregion
--#region tower_engineer_3
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

--#endregion
--#region tower_archer_1
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
--#endregion
--#region tower_archer_2
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
--#endregion
--#region tower_archer_3
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
--#endregion
--#region arrow_1
tt = RT("arrow_1", "arrow")
tt.bullet.damage_min = 4
tt.bullet.damage_max = 7
--#endregion
--#region arrow_2
tt = RT("arrow_2", "arrow")
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12
tt.bullet.flight_time = fts(21)
--#endregion
--#region arrow_3
tt = RT("arrow_3", "arrow")
tt.bullet.damage_min = 11
tt.bullet.damage_max = 18
tt.bullet.flight_time = fts(20)
--#endregion
--#region tower_barrack_1
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
--#endregion
--#region tower_barrack_2
tt = RT("tower_barrack_2", "tower_barrack_1")
tt.info.enc_icon = 6
tt.tower.level = 2
tt.tower.price = 110
tt.render.sprites[2].name = "tower_barracks_lvl2_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl2_door"
tt.barrack.soldier_type = "soldier_footmen"
tt.barrack.rally_range = 150
--#endregion
--#region tower_barrack_3
tt = RT("tower_barrack_3", "tower_barrack_1")
tt.info.enc_icon = 10
tt.tower.level = 3
tt.tower.price = 150
tt.render.sprites[2].name = "tower_barracks_lvl3_layer1_0001"
tt.render.sprites[3].prefix = "towerbarracklvl3_door"
tt.barrack.soldier_type = "soldier_knight"
tt.barrack.rally_range = 155
--#endregion
--#region tower_neptune_holder
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
--#endregion
--#region tower_neptune
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
--#endregion
--#region ray_neptune
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
--#endregion
--#region fx_ray_neptune_explosion
tt = RT("fx_ray_neptune_explosion", "decal_timed")
tt.render.sprites[1].name = "ray_neptune_explosion"
tt.render.sprites[1].anchor.y = 0.24444444444444444
tt.render.sprites[1].z = Z_BULLETS
--#endregion
--#region rock_1
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
--#endregion
--#region rock_2
tt = RT("rock_2", "rock_1")
tt.bullet.damage_max = 30
tt.bullet.damage_min = 18
--#endregion
--#region rock_3
tt = RT("rock_3", "rock_1")
tt.bullet.damage_max = 50
tt.bullet.damage_min = 30
--#endregion
--#region mod_rock_slow
tt = RT("mod_rock_slow", "mod_slow")
tt.modifier.duration = 0.75
--#endregion
--#region soldier_barrack_1
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
--#endregion
--#region soldier_barrack_2
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
--#endregion
--#region soldier_barrack_3
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

local b
local balance = require("kr1.data.balance")

---龙魂宝壶
--#endregion
--#region tower_holder_blocked_elemental
tt = RT("tower_holder_blocked_elemental", "tower")

E:add_comps(tt, "tower", "tower_holder", "pos", "render", "ui", "info", "tween", "sound_events", "editor")

tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower_holder.blocked = true
tt.tower.can_be_sold = false
tt.tower.type = "holder_baby_ashbite"
tt.tower.kind = TOWER_KIND_BARRACK
tt.info.fn = scripts.tower_holder_blocked_elemental_holder.get_info
tt.info.portrait = "kr5_portraits_towers_0019"
tt.info.i18n_key = "BLOCKED_ELEMENTAL_TOWER"
tt.info.damage_icon = "fireball"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_barrack_%04i" --"terrains_holders_%04i"
tt.render.sprites[1].offset = v(0, 13)
tt.render.sprites[1].z = Z_DECALS
tt.ui.click_rect = r(-40, -12, 80, 46)
---龙魂宝壶 金
--#endregion
--#region tower_holder_blocked_elemental_metal_b
tt = RT("tower_holder_blocked_elemental_metal_b", "tower_holder_blocked_elemental")

E:add_comps(tt, "main_script")

b = balance.specials.terrain_8.elemental_holders.metal_holder
tt.main_script.insert = scripts.tower_holder_blocked_elemental_holder.insert
tt.main_script.remove = scripts.tower_holder_blocked_elemental_holder.remove
tt.info.i18n_key = "BLOCKED_ELEMENTAL_TOWER_METAL"
tt.tower.type = "holder_blocked_elemental_metal"
tt.tower_holder.unblock_price = b.price
tt.tower.menu_offset = v(0, 35)
tt.render.sid_parche = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "goldholder_jarraDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 11)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "goldholder_jarrahojasDef"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[3].offset = v(0, 6)
tt.render.sprites[tt.render.sid_parche] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_parche].prefix = "stage33_water_holder_animations_parcheDef"
tt.render.sprites[tt.render.sid_parche].name = "stage_33"
tt.render.sprites[tt.render.sid_parche].exo = true
tt.render.sprites[tt.render.sid_parche].animated = true
tt.render.sprites[tt.render.sid_parche].offset = v(-5.5, 9.5)
tt.render.sprites[tt.render.sid_parche].hidden = true
tt.render.sprites[tt.render.sid_parche].hidden_count = 1
tt.remove_fx = "fx_elemental_metal_holder_broken_jarra"
tt.ui.click_rect = r(-45, -8, 90, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
--#endregion

---龙魂宝壶 木
--#region tower_holder_blocked_elemental_wood
tt = RT("tower_holder_blocked_elemental_wood", "tower_holder_blocked_elemental")
E:add_comps(tt, "main_script")
b = balance.specials.terrain_8.elemental_holders.wooden_holder
tt.main_script.insert = scripts.tower_holder_blocked_elemental_holder.insert
tt.main_script.remove = scripts.tower_holder_blocked_elemental_holder.remove
tt.info.i18n_key = "SPECIAL_REPAIR_HOLDER_ELEMENTAL_WOOD"
tt.tower.type = "holder_blocked_elemental_wood"
tt.tower_holder.unblock_price = b.price
tt.tower.menu_offset = v(0, 35)
tt.render.sid_parche = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage31_wood_holder_jarraDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "stage31_wood_holder_jarrahojasDef"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[tt.render.sid_parche] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_parche].prefix = "stage31_wood_holder_animations_parcheDef"
tt.render.sprites[tt.render.sid_parche].name = "stage_31_clean"
tt.render.sprites[tt.render.sid_parche].exo = true
tt.render.sprites[tt.render.sid_parche].animated = true
tt.render.sprites[tt.render.sid_parche].offset = v(-5.5, 3.5)
tt.remove_fx = "fx_elemental_wood_holder_broken_jarra"
tt.ui.click_rect = r(-45, -8, 90, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
--#endregion
--#region tower_holder_blocked_elemental_wood_enhance
tt = RT("tower_holder_blocked_elemental_wood_enhance", "tower_holder_blocked_elemental_wood")
tt.tower.type = "holder_blocked_elemental_wood_enhance"
tt.tower_holder.unblock_price = 50
---龙魂宝壶 水
--#endregion
--#region tower_holder_blocked_elemental_water_b
tt = RT("tower_holder_blocked_elemental_water_b", "tower_holder_blocked_elemental")

E:add_comps(tt, "main_script")

b = balance.specials.terrain_8.elemental_holders.water_holder
tt.main_script.insert = scripts.tower_holder_blocked_elemental_holder.insert
tt.main_script.remove = scripts.tower_holder_blocked_elemental_holder.remove
tt.info.i18n_key = "BLOCKED_ELEMENTAL_TOWER_WATER"
tt.tower.type = "holder_blocked_elemental_water"
tt.tower_holder.unblock_price = b.price
tt.tower.menu_offset = v(0, 35)
tt.render.sid_parche = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage33_water_holder_jarraDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "stage33_water_holder_jarrahojasDef"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[tt.render.sid_parche] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_parche].prefix = "stage33_water_holder_animations_parcheDef"
tt.render.sprites[tt.render.sid_parche].name = "stage_33"
tt.render.sprites[tt.render.sid_parche].exo = true
tt.render.sprites[tt.render.sid_parche].animated = true
tt.render.sprites[tt.render.sid_parche].offset = v(-5.5, 3.5)
tt.remove_fx = "fx_elemental_water_holder_broken_jarra"
tt.ui.click_rect = r(-45, -8, 90, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
---龙魂宝壶 火
--#endregion
--#region tower_holder_blocked_elemental_fire_b
tt = RT("tower_holder_blocked_elemental_fire_b", "tower_holder_blocked_elemental")

E:add_comps(tt, "main_script")

b = balance.specials.terrain_8.elemental_holders.fire_holder
tt.main_script.insert = scripts.tower_holder_blocked_elemental_holder.insert
tt.main_script.remove = scripts.tower_holder_blocked_elemental_holder.remove
tt.info.i18n_key = "BLOCKED_ELEMENTAL_TOWER_FIRE"
tt.tower.type = "holder_blocked_elemental_fire"
tt.tower_holder.unblock_price = b.price
tt.tower.menu_offset = v(0, 35)
tt.render.sid_parche = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "fireholder_jarraDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "fireholder_jarrahojasDef"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[tt.render.sid_parche] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_parche].prefix = "stage31_wood_holder_animations_parcheDef"
tt.render.sprites[tt.render.sid_parche].name = "stage_32"
tt.render.sprites[tt.render.sid_parche].exo = true
tt.render.sprites[tt.render.sid_parche].animated = true
tt.render.sprites[tt.render.sid_parche].offset = v(-5.5, 3.5)
tt.remove_fx = "fx_elemental_fire_holder_broken_jarra"
tt.ui.click_rect = r(-45, -8, 90, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
---龙魂宝壶 土
--#endregion
--#region tower_holder_blocked_elemental_earth_b
tt = RT("tower_holder_blocked_elemental_earth_b", "tower_holder_blocked_elemental")

E:add_comps(tt, "main_script")

b = balance.specials.terrain_8.elemental_holders.earth_holder
tt.main_script.insert = scripts.tower_holder_blocked_elemental_holder.insert
tt.main_script.remove = scripts.tower_holder_blocked_elemental_holder.remove
tt.info.i18n_key = "BLOCKED_ELEMENTAL_TOWER_EARTH"
tt.tower.type = "holder_blocked_elemental_earth"
tt.tower_holder.unblock_price = b.price
tt.tower.menu_offset = v(0, 35)
tt.render.sid_parche = 4
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "dirtholder_jarraDef"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].exo = true
tt.render.sprites[2].animated = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "dirtholder_jarrahojasDef"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].exo = true
tt.render.sprites[3].animated = true
tt.render.sprites[tt.render.sid_parche] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_parche].prefix = "dirtholder_parcheDef"
tt.render.sprites[tt.render.sid_parche].name = "stage_33"
tt.render.sprites[tt.render.sid_parche].exo = true
tt.render.sprites[tt.render.sid_parche].animated = true
tt.render.sprites[tt.render.sid_parche].offset = v(-5.5, 3.5)
tt.remove_fx = "fx_elemental_earth_holder_broken_jarra"
tt.ui.click_rect = r(-45, -8, 90, 90)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {2, 255}, {2.5, 255}, {4.5, 0}}
tt.tween.props[1].sprite_id = 4
tt.tween.props[1].loop = true
-- 龙魂宝壶-防御塔
--#endregion
--#region tower_holder_elemental
tt = RT("tower_holder_elemental", "tower_holder")

E:add_comps(tt, "main_script")

tt.main_script.update = scripts.tower_holder_elemental.update
tt.main_script.remove = scripts.tower_holder_elemental.remove
tt.tower.terrain_style = nil
--#endregion
--#region tower_holder_elemental_wood
tt = RT("tower_holder_elemental_wood", "tower_holder_elemental")
tt.tower.terrain_style = nil
tt.render.sid_base = 1
tt.render.sid_gradiente = #tt.render.sprites + 1
tt.render.sid_dragon = #tt.render.sprites + 2
tt.render.sprites[tt.render.sid_gradiente] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_gradiente].prefix = "stage31_wood_holder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "buy"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "stage31_wood_holder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "buy"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.controller_name = "controller_elemental_wood"
tt.cannot_be_swapped = true
--#endregion
--#region tower_holder_elemental_wood_enhance
tt = RT("tower_holder_elemental_wood_enhance", "tower_holder_elemental_wood")
tt.controller_name = "controller_elemental_wood_enhance"
--#endregion
--#region tower_holder_elemental_fire
tt = RT("tower_holder_elemental_fire", "tower_holder_elemental")
tt.tower.terrain_style = nil
tt.render.sid_base = 1
tt.render.sid_gradiente = #tt.render.sprites + 1
tt.render.sid_dragon = #tt.render.sprites + 2
tt.render.sprites[tt.render.sid_gradiente] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_gradiente].prefix = "fireholder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "buy"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "fireholder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "buy"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.controller_name = "controller_elemental_fire"
tt.cannot_be_swapped = true
--#endregion
--#region tower_holder_elemental_water
tt = RT("tower_holder_elemental_water", "tower_holder_elemental")
tt.tower.terrain_style = nil
tt.render.sid_base = 1
tt.render.sid_gradiente = #tt.render.sprites + 1
tt.render.sid_dragon = #tt.render.sprites + 2
tt.render.sprites[tt.render.sid_gradiente] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_gradiente].prefix = "stage33_water_holder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "buy"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "stage33_water_holder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "buy"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.controller_name = "controller_elemental_water"
tt.cannot_be_swapped = true
--#endregion
--#region tower_holder_elemental_earth
tt = RT("tower_holder_elemental_earth", "tower_holder_elemental")
tt.tower.terrain_style = nil
tt.render.sid_base = 1
tt.render.sprites[2].name = "terrains_holders_0014_flag"
tt.render.sid_gradiente = #tt.render.sprites + 1
tt.render.sid_dragon = #tt.render.sprites + 2
tt.render.sprites[tt.render.sid_gradiente] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_gradiente].prefix = "dirtholder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "buy"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "dirtholder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "buy"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.controller_name = "controller_elemental_earth"
tt.cannot_be_swapped = true
--#endregion
--#region tower_holder_elemental_metal
tt = RT("tower_holder_elemental_metal", "tower_holder_elemental")
b = balance.specials.terrain_8.elemental_holders.metal_holder
tt.tower.terrain_style = nil
tt.tower.upgrade_price_multiplier = b.upgrade_price_multiplier
tt.render.sid_base = 1
tt.render.sid_gradiente = #tt.render.sprites + 1
tt.render.sid_dragon = #tt.render.sprites + 2
tt.render.sprites[tt.render.sid_gradiente] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_gradiente].prefix = "goldholder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "buy"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].offset = v(0, 0)
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "goldholder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "buy"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.controller_name = "controller_elemental_metal"
tt.cannot_be_swapped = true
-- 龙魂宝壶 控制器
--#endregion
--#region controller_elemental_wood
tt = RT("controller_elemental_wood")

E:add_comps(tt, "main_script", "pos", "render", "tween")

b = balance.specials.terrain_8.elemental_holders.wooden_holder
tt.main_script.update = scripts.controller_elemental_wood.update
tt.main_script.remove = scripts.controller_elemental_generic.remove
tt.first_cooldown = b.first_cooldown
tt.cooldown = b.cooldown
tt.slow_factor = b.slow_factor
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.vis_bans = bor(F_FLYING, F_FRIEND)
tt.vis_flags = F_RANGED
tt.duration = b.duration
tt.root_decal = "decal_elemental_wood_holder_root"
tt.root_decal_dragon = "decal_elemental_wood_holder_root_dragon"
tt.default_max_range = b.default_max_range
tt.skill_detection_range_factor = b.skill_detection_range_factor
tt.rally_range_factor = b.rally_range_factor
tt.range_factor = b.range_factor
tt.controller_aura_name = "aura_elemental_wood"
tt.render.sid_gradiente = 1
tt.render.sid_wings = 2
tt.render.sid_hojas = 3
tt.render.sid_dragon = 4
tt.render.sid_dragon_ability = 5
tt.render.sprites[tt.render.sid_gradiente].prefix = "stage31_wood_holder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "idle"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_wings] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_wings].prefix = "stage31_wood_holder_cuernosDef"
tt.render.sprites[tt.render.sid_wings].name = "run"
tt.render.sprites[tt.render.sid_wings].exo = true
tt.render.sprites[tt.render.sid_wings].animated = true
tt.render.sprites[tt.render.sid_wings].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_wings].sort_y_offset = -10
tt.render.sprites[tt.render.sid_wings].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_wings].alpha = 0
tt.render.sprites[tt.render.sid_hojas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_hojas].prefix = "stage31_wood_holder_jarrahojasDef"
tt.render.sprites[tt.render.sid_hojas].exo = true
tt.render.sprites[tt.render.sid_hojas].name = "run"
tt.render.sprites[tt.render.sid_hojas].animated = true
tt.render.sprites[tt.render.sid_hojas].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_hojas].offset = v(0, -10)
tt.render.sprites[tt.render.sid_hojas].sort_y_offset = -10
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "stage31_wood_holder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "idle"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.render.sprites[tt.render.sid_dragon].anchor = vv(0.5)
tt.render.sprites[tt.render.sid_dragon_ability] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon_ability].prefix = "stage31_wood_holder_habilidad_1Def"
tt.render.sprites[tt.render.sid_dragon_ability].exo = true
tt.render.sprites[tt.render.sid_dragon_ability].name = "start_hability"
tt.render.sprites[tt.render.sid_dragon_ability].animated = true
tt.render.sprites[tt.render.sid_dragon_ability].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon_ability].hidden = true
tt.render.sprites[tt.render.sid_dragon_ability].anchor = vv(0.5)
tt.update_on_path_active = {2, 3, 6}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].sprite_id = tt.render.sid_wings
tt.tween.props[1].loop = false
tt.tween.disabled = true
tt.tween.reverse = true
tt.tween.remove = false
--#endregion
--#region controller_elemental_wood_enhance
tt = RT("controller_elemental_wood_enhance", "controller_elemental_wood")
b = balance.specials.terrain_8.elemental_holders.wooden_holder_enhance
tt.main_script.update = scripts.controller_elemental_wood.update
tt.main_script.remove = scripts.controller_elemental_generic.remove
tt.first_cooldown = b.first_cooldown
tt.cooldown = b.cooldown
tt.slow_factor = b.slow_factor
tt.damage_min = b.damage_min
tt.damage_max = b.damage_max
tt.vis_bans = bor(F_FLYING, F_FRIEND)
tt.vis_flags = F_RANGED
tt.duration = b.duration
tt.root_decal = "decal_elemental_wood_holder_root"
tt.root_decal_dragon = "decal_elemental_wood_holder_root_dragon"
tt.default_max_range = b.default_max_range
tt.skill_detection_range_factor = b.skill_detection_range_factor
tt.rally_range_factor = b.rally_range_factor
tt.range_factor = b.range_factor
tt.damage_factor = b.damage_factor
tt.controller_aura_name = "aura_elemental_wood"
tt.render.sid_gradiente = 1
tt.render.sid_wings = 2
tt.render.sid_hojas = 3
tt.render.sid_dragon = 4
tt.render.sid_dragon_ability = 5
tt.render.sprites[tt.render.sid_gradiente].prefix = "stage31_wood_holder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "idle"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_wings] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_wings].prefix = "stage31_wood_holder_cuernosDef"
tt.render.sprites[tt.render.sid_wings].name = "run"
tt.render.sprites[tt.render.sid_wings].exo = true
tt.render.sprites[tt.render.sid_wings].animated = true
tt.render.sprites[tt.render.sid_wings].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_wings].sort_y_offset = -10
tt.render.sprites[tt.render.sid_wings].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_wings].alpha = 0
tt.render.sprites[tt.render.sid_hojas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_hojas].prefix = "stage31_wood_holder_jarrahojasDef"
tt.render.sprites[tt.render.sid_hojas].exo = true
tt.render.sprites[tt.render.sid_hojas].name = "run"
tt.render.sprites[tt.render.sid_hojas].animated = true
tt.render.sprites[tt.render.sid_hojas].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_hojas].offset = v(0, -10)
tt.render.sprites[tt.render.sid_hojas].sort_y_offset = -10
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "stage31_wood_holder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "idle"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.render.sprites[tt.render.sid_dragon].anchor = vv(0.5)
tt.render.sprites[tt.render.sid_dragon_ability] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon_ability].prefix = "stage31_wood_holder_habilidad_1Def"
tt.render.sprites[tt.render.sid_dragon_ability].exo = true
tt.render.sprites[tt.render.sid_dragon_ability].name = "start_hability"
tt.render.sprites[tt.render.sid_dragon_ability].animated = true
tt.render.sprites[tt.render.sid_dragon_ability].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon_ability].hidden = true
tt.render.sprites[tt.render.sid_dragon_ability].anchor = vv(0.5)
tt.update_on_path_active = {2, 3, 6}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].sprite_id = tt.render.sid_wings
tt.tween.props[1].loop = false
tt.tween.disabled = true
tt.tween.reverse = true
tt.tween.remove = false
--#endregion
--#region decal_elemental_wood_holder_root_1
tt = RT("decal_elemental_wood_holder_root_1", "decal_scripted")
tt.render.sprites[1].prefix = "stage31_wood_holder_root1Def"
tt.render.sprites[1].exo = true
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = true
tt.main_script.update = scripts.hero_muyrn_root_defender_root_decal.update
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)
--#endregion
--#region decal_elemental_wood_holder_root_2
tt = RT("decal_elemental_wood_holder_root_2", "decal_elemental_wood_holder_root_1")
tt.render.sprites[1].prefix = "stage31_wood_holder_root2Def"
--#endregion
--#region decal_elemental_wood_holder_root_3
tt = RT("decal_elemental_wood_holder_root_3", "decal_elemental_wood_holder_root_1")
tt.render.sprites[1].prefix = "stage31_wood_holder_root3Def"
--#endregion
--#region decal_elemental_wood_holder_root_4
tt = RT("decal_elemental_wood_holder_root_4", "decal_elemental_wood_holder_root_1")
tt.render.sprites[1].prefix = "stage31_wood_holder_root4Def"
--#endregion
--#region decal_elemental_wood_holder_root_dragon
tt = RT("decal_elemental_wood_holder_root_dragon", "decal_scripted")
tt.render.sprites[1].prefix = "stage31_wood_holder_dragon_rootDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "in"
tt.loop_times = 2
tt.main_script.update = scripts.decal_elemental_wood_holder_root_dragon.update
--#endregion
--#region fx_elemental_wood_holder_broken_jarra
tt = RT("fx_elemental_wood_holder_broken_jarra", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "stage31_wood_holder_jarraDef"
tt.render.sprites[1].name = "broken"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, 5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage31_wood_holder_rayoDef"
tt.render.sprites[2].name = "ray_down"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "stage31_wood_holder_rayo_explosionDef"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].exo = true
tt.render.sprites[3].offset = v(0, 5)
tt.render.sprites[3].z = Z_OBJECTS
--#endregion
--#region aura_elemental_wood
tt = RT("aura_elemental_wood", "aura")
tt.aura.duration = b.duration
tt.aura.cycle_time = 0.3
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.aura.mods = {"mod_elemental_wood_slow", "mod_elemental_wood_damage"}
tt.duration = b.duration
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.main_script.remove = scripts.aura_apply_mod.remove
--#endregion
--#region mod_elemental_wood_slow
tt = RT("mod_elemental_wood_slow", "mod_slow")
tt.modifier.duration = 1
tt.slow.factor = b.slow_factor
--#endregion
--#region mod_elemental_wood_damage
tt = RT("mod_elemental_wood_damage", "modifier")

E:add_comps(tt, "dps")

tt.modifier.duration = 1
tt.dps.damage_min = b.damage_min
tt.dps.damage_max = b.damage_max
tt.dps.damage_type = b.damage_type
tt.dps.damage_every = b.damage_every
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
--#endregion
--#region controller_elemental_fire
tt = RT("controller_elemental_fire")

E:add_comps(tt, "main_script", "pos", "render", "tween")

b = balance.specials.terrain_8.elemental_holders.fire_holder
tt.main_script.update = scripts.controller_elemental_fire.update
tt.main_script.remove = scripts.controller_elemental_generic.remove
tt.first_cooldown = b.first_cooldown
tt.cooldown = b.cooldown
tt.damage_factor = b.damage_factor
tt.default_max_range = b.default_max_range
tt.vis_bans = bor(F_FLYING, F_FRIEND, F_BOSS, F_MINIBOSS)
tt.vis_flags = bor(F_RANGED, F_INSTAKILL)
tt.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_FX_NOT_EXPLODE)
tt.damage_delay = 0.35
tt.fx = "fx_elemental_fire_holder_explosion"
tt.root_decal_dragon = "decal_elemental_fire_holder_root_dragon"
tt.root_decal_dragon_kill = "decal_elemental_fire_holder_root_dragon_kill"
tt.render.sid_gradiente = 1
tt.render.sid_sparks = 2
tt.render.sid_wings = 3
tt.render.sid_hojas = 4
tt.render.sid_dragon = 5
tt.render.sid_dragon_ability = 6
tt.render.sprites[tt.render.sid_gradiente].prefix = "fireholder_gradienteDef"
tt.render.sprites[tt.render.sid_gradiente].exo = true
tt.render.sprites[tt.render.sid_gradiente].name = "idle"
tt.render.sprites[tt.render.sid_gradiente].animated = true
tt.render.sprites[tt.render.sid_gradiente].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_gradiente].offset = v(-60, 85)
tt.render.sprites[tt.render.sid_sparks] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_sparks].prefix = "fireholder_jarrahojasDef"
tt.render.sprites[tt.render.sid_sparks].name = "run"
tt.render.sprites[tt.render.sid_sparks].exo = true
tt.render.sprites[tt.render.sid_sparks].animated = true
tt.render.sprites[tt.render.sid_sparks].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_sparks].sort_y_offset = -10
tt.render.sprites[tt.render.sid_sparks].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_sparks].alpha = 255
tt.render.sprites[tt.render.sid_wings] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_wings].prefix = "fireholder_cuernosDef"
tt.render.sprites[tt.render.sid_wings].name = "run"
tt.render.sprites[tt.render.sid_wings].exo = true
tt.render.sprites[tt.render.sid_wings].animated = true
tt.render.sprites[tt.render.sid_wings].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_wings].sort_y_offset = -10
tt.render.sprites[tt.render.sid_wings].anchor = v(0.5, 0.5)
tt.render.sprites[tt.render.sid_wings].alpha = 0
tt.render.sprites[tt.render.sid_hojas] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_hojas].prefix = "fireholder_jarrahojasDef"
tt.render.sprites[tt.render.sid_hojas].exo = true
tt.render.sprites[tt.render.sid_hojas].name = "run"
tt.render.sprites[tt.render.sid_hojas].animated = true
tt.render.sprites[tt.render.sid_hojas].z = Z_OBJECTS
tt.render.sprites[tt.render.sid_hojas].offset = v(0, -10)
tt.render.sprites[tt.render.sid_hojas].sort_y_offset = -10
tt.render.sprites[tt.render.sid_dragon] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon].prefix = "fireholder_dragonDef"
tt.render.sprites[tt.render.sid_dragon].exo = true
tt.render.sprites[tt.render.sid_dragon].name = "idle"
tt.render.sprites[tt.render.sid_dragon].animated = true
tt.render.sprites[tt.render.sid_dragon].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon].offset = v(0, -10)
tt.render.sprites[tt.render.sid_dragon].anchor = vv(0.5)
tt.render.sprites[tt.render.sid_dragon_ability] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_dragon_ability].prefix = "fireholder_habilidad_1Def"
tt.render.sprites[tt.render.sid_dragon_ability].exo = true
tt.render.sprites[tt.render.sid_dragon_ability].name = "start_hability"
tt.render.sprites[tt.render.sid_dragon_ability].animated = true
tt.render.sprites[tt.render.sid_dragon_ability].z = Z_EFFECTS
tt.render.sprites[tt.render.sid_dragon_ability].hidden = true
tt.render.sprites[tt.render.sid_dragon_ability].anchor = vv(0.5)
tt.update_on_path_active = {2, 3, 6}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}}
tt.tween.props[1].sprite_id = tt.render.sid_wings
tt.tween.props[1].loop = false
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[2].sprite_id = tt.render.sid_sparks
tt.tween.props[2].loop = false
tt.tween.disabled = true
tt.tween.reverse = true
tt.tween.remove = false
--#endregion
--#region decal_elemental_fire_holder_root_dragon
tt = RT("decal_elemental_fire_holder_root_dragon", "decal_scripted")
tt.render.sprites[1].prefix = "fireholder_dragon_rootDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "in"
tt.loop_times = 1
tt.main_script.update = scripts.decal_elemental_wood_holder_root_dragon.update
--#endregion
--#region decal_elemental_fire_holder_root_dragon_kill
tt = RT("decal_elemental_fire_holder_root_dragon_kill", "decal_scripted")
tt.render.sprites[1].prefix = "fireholder_dragon_executionDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "in"
tt.main_script.update = scripts.decal_elemental_wood_holder_root_dragon_kill.update
--#endregion
--#region fx_elemental_fire_holder_explosion
tt = RT("fx_elemental_fire_holder_explosion", "fx")
tt.render.sprites[1].prefix = "fireholder_dragon_executionDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].name = "in"
--#endregion
--#region fx_elemental_fire_holder_broken_jarra
tt = RT("fx_elemental_fire_holder_broken_jarra", "decal_scripted")
tt.main_script.update = scripts.multi_sprite_fx.update
tt.render.sprites[1].prefix = "fireholder_jarraDef"
tt.render.sprites[1].name = "broken"
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(0, 5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "fireholder_rayoDef"
tt.render.sprites[2].name = "ray_down"
tt.render.sprites[2].exo = true
tt.render.sprites[2].offset = v(0, 5)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "fireholder_rayo_explosionDef"
tt.render.sprites[3].name = "in"
tt.render.sprites[3].exo = true
tt.render.sprites[3].offset = v(0, 5)
tt.render.sprites[3].z = Z_OBJECTS
--#endregion

tt = E:register_t("tower_stage_13_sunray", "tower_KR5")
b = balance.specials.towers.stage_13_sunray
E:add_comps(tt, "user_selection", "attacks", "editor")
tt.tower.type = "tower_stage_13_sunray"
tt.tower.menu_offset = v(0, 45)
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.render.sprites[1].prefix = "sunraytowerDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.info.portrait = "kr5_portraits_towers_0018"
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
tt.attacks.list[1].bullet_start_offset = v(4, 88)
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
tt.attacks.list[2].bullet_start_offset = v(4, 88)
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
tt.ui.hover_sprite_scale = vv(1.4)
tt.ui.hover_sprite_offset = v(0, -8)
tt.editor.props = {{"editor.game_mode", PT_NUMBER}}

