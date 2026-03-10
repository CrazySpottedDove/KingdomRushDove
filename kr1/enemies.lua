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

local function melee_slot_y_flying()
	return (1 - anchor_y) * image_y
end

local U = require("utils")

require("game_templates_utils")

--#region enemy_sheep_ground
tt = RT("enemy_sheep_ground", "enemy")
anchor_y = 0.2
image_y = 38
tt.enemy.gold = 0
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 80
tt.health_bar.offset = vec_2(0, ady(32))
tt.info.i18n_key = "ENEMY_SHEEP"
tt.info.portrait = "info_portraits_enemies_0008"
tt.info.enc_icon = nil
tt.main_script.update = scripts.enemy_sheep.update
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_ground"
tt.sound_events.insert = "Sheep"
tt.sound_events.death = "DeathEplosion"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.mod_offset = vec_2(0, ady(15))
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY)
tt.clicks_to_destroy = 8
--#endregion
--#region enemy_sheep_fly
tt = RT("enemy_sheep_fly", "enemy_sheep_ground")
anchor_y = 0.038461538461538464
image_y = 78
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 389
tt.health_bar.offset = vec_2(0, ady(68))
tt.motion.max_speed = 2.08 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_sheep_fly"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.ui.click_rect.pos.y = 40
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = vec_2(0, ady(56))
tt.unit.mod_offset = vec_2(0, ady(48))
tt.unit.show_blood_pool = false
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_goblin
tt = RT("enemy_goblin", "enemy")

AC(tt, "melee")

image_y = 32
image_x = 46
anchor_y = 0.2
anchor_x = 0.5
tt.enemy.gold = 3
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 20
tt.health_bar.offset = vec_2(0, 25)
tt.info.i18n_key = "ENEMY_GOBLIN"
tt.info.enc_icon = 1
tt.info.portrait = "info_portraits_enemies_0001"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, anchor_y)
tt.render.sprites[1].prefix = "goblin"
tt.sound_events.death = "DeathGoblin"
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.mod_offset = vec_2(adx(22), ady(15))
--#endregion
--#region enemy_fat_orc
tt = RT("enemy_fat_orc", "enemy")

AC(tt, "melee")

anchor_y = 0.19
anchor_x = 0.5
image_y = 42
image_x = 58
tt.enemy.gold = 9
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0.3
tt.health.hp_max = 80
tt.health_bar.offset = vec_2(0, 30)
tt.info.i18n_key = "ENEMY_FAT_ORC"
tt.info.enc_icon = 2
tt.info.portrait = "info_portraits_enemies_0002"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_fat_orc"
tt.sound_events.death = "DeathOrc"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(adx(30), ady(20))
--#endregion
--#region enemy_wolf_small
tt = RT("enemy_wolf_small", "enemy")

AC(tt, "dodge", "melee")

anchor_y = 0.21
anchor_x = 0.5
image_y = 28
image_x = 38
tt.dodge.chance = 0.3
tt.dodge.silent = true
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 35
tt.health_bar.offset = vec_2(0, 25)
tt.info.i18n_key = "ENEMY_WULF"
tt.info.enc_icon = 13
tt.info.portrait = "info_portraits_enemies_0007"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2.5 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.21)
tt.render.sprites[1].prefix = "enemy_wolf_small"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 11)
tt.unit.mod_offset = vec_2(adx(22), ady(14))
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_wolf
tt = RT("enemy_wolf", "enemy")

AC(tt, "dodge", "melee")

anchor_y = 0.26
anchor_x = 0.5
image_y = 50
image_x = 60
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 12
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 120
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 35)
tt.info.i18n_key = "ENEMY_WORG"
tt.info.enc_icon = 14
tt.info.portrait = "info_portraits_enemies_0011"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.26)
tt.render.sprites[1].prefix = "enemy_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = vec_2(adx(29), ady(26))
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_shadow_archer
tt = RT("enemy_shadow_archer", "enemy")

AC(tt, "melee", "ranged")

anchor_y = 0.2
anchor_x = 0.5
image_y = 36
image_x = 54
tt.enemy.gold = 16
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 180
tt.health.magic_armor = 0.3
tt.health_bar.offset = vec_2(0, 31)
tt.info.i18n_key = "ENEMY_SHADOW_ARCHER"
tt.info.enc_icon = 11
tt.info.portrait = "info_portraits_enemies_0016"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "arrow_shadow_archer"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(4, 12.5)}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].requires_magic = true
tt.render.sprites[1].anchor = vec_2(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shadow_archer"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(adx(26), ady(20))
tt.unit.marker_offset.y = 1
--#endregion
--#region enemy_shaman
tt = RT("enemy_shaman", "enemy")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.2
anchor_x = 0.5
image_y = 60
image_x = 60
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 100
tt.health.magic_armor = 0.85
tt.health_bar.offset = vec_2(0, 33)
tt.info.i18n_key = "ENEMY_SHAMAN"
tt.info.enc_icon = 3
tt.info.portrait = "info_portraits_enemies_0004"
tt.main_script.update = scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(18)
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 3
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.2)
tt.render.sprites[1].prefix = "enemy_shaman"
tt.sound_events.death = "DeathGoblin"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].max_range = 95
tt.timed_attacks.list[1].mod = "mod_shaman_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, -2)
tt.unit.mod_offset = vec_2(adx(30), ady(20))
--#endregion
--#region enemy_gargoyle
tt = RT("enemy_gargoyle", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 88
image_x = 58
tt.enemy.gold = 12
tt.health.hp_max = 90
tt.health_bar.offset = vec_2(adx(29), ady(69))
tt.info.i18n_key = "ENEMY_GARGOYLE"
tt.info.enc_icon = 10
tt.info.portrait = "info_portraits_enemies_0005"
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_gargoyle"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 34, 28, 30)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = vec_2(0, 52)
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(adx(31), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_ogre
tt = RT("enemy_ogre", "enemy")

AC(tt, "melee")

anchor_y = 0.2
anchor_x = 0.5
image_y = 80
image_x = 86
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 800
tt.health_bar.offset = vec_2(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_OGRE"
tt.info.enc_icon = 4
tt.info.portrait = "info_portraits_enemies_0006"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_ogre"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(34, 45)
tt.ui.click_rect.pos.x = -17
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(42), ady(33))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_spider_tiny
tt = RT("enemy_spider_tiny", "enemy")

AC(tt, "melee")

anchor_y = 0.25
anchor_x = 0.5
image_y = 24
image_x = 30
tt.enemy.gold = 1
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 10
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 16)
tt.info.i18n_key = "ENEMY_SPIDERTINY"
tt.info.portrait = "info_portraits_enemies_0014"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(adx(18), ady(13))
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region enemy_spider_small
tt = RT("enemy_spider_small", "enemy")

AC(tt, "melee")

anchor_y = 0.25
anchor_x = 0.5
image_y = 28
image_x = 36
tt.enemy.gold = 6
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 60
tt.health.magic_armor = 0.65
tt.health_bar.offset = vec_2(0, 22)
tt.info.i18n_key = "ENEMY_SPIDERSMALL"
tt.info.enc_icon = 8
tt.info.portrait = "info_portraits_enemies_0013"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_small"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.marker_offset = vec_2(0, -1)
tt.unit.mod_offset = vec_2(adx(20), ady(15))
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region enemy_spider_small_derived
tt = RT("enemy_spider_small_derived", "enemy_spider_small")
tt.enemy.gold = 0
tt.motion.max_speed = 2 * FPS
--#endregion
--#region enemy_spider_small_big
tt = RT("enemy_spider_small_big", "enemy")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.25
anchor_x = 0.5
image_y = 28
image_x = 36
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(20 * 2, 0)
tt.health.hp_max = 600
tt.health.magic_armor = 0.65
tt.health_bar.offset = vec_2(0, 22 * 2)
tt.info.i18n_key = "ENEMY_SPIDER_SMALL_BIG"
tt.info.enc_icon = 8
tt.info.portrait = "info_portraits_enemies_0013"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.main_script.update = scripts.enemy_spider_big.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_small"
tt.render.sprites[1].scale = vec_1(1.3)
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 8 * 2)
tt.unit.marker_offset = vec_2(0, -1 * 2)
tt.unit.mod_offset = vec_2(adx(20) * 2, ady(15) * 2)
tt.vis.bans = bor(F_SKELETON, F_POISON)
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_bigger_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 3
tt.timed_attacks.list[1].min_cooldown = 5
--#endregion
--#region enemy_spider_bigger_egg
tt = RT("enemy_spider_bigger_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.render.sprites[1].scale = vec_1(1.4)
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_small_derived"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region enemy_spider_big
tt = RT("enemy_spider_big", "enemy")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.25
anchor_x = 0.5
image_y = 40
image_x = 56
tt.enemy.gold = 20
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.8
tt.health_bar.offset = vec_2(0, 32)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPIDER"
tt.info.enc_icon = 9
tt.info.portrait = "info_portraits_enemies_0012"
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = {3, 3, 3, 4}
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect = r(-20, -5, 40, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.marker_offset = vec_2(-0.4, -2.2)
tt.unit.mod_offset = vec_2(adx(26), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region enemy_spider_egg
tt = RT("enemy_spider_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_spider_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region enemy_brigand
tt = RT("enemy_brigand", "enemy")

AC(tt, "melee")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 50
tt.enemy.gold = 15
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0.5
tt.health.hp_max = 160
tt.health_bar.offset = vec_2(0, 31)
tt.info.i18n_key = "ENEMY_BRIGAND"
tt.info.enc_icon = 6
tt.info.portrait = "info_portraits_enemies_0009"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_brigand"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(adx(24), ady(19))
--#endregion
--#region enemy_dark_knight
tt = RT("enemy_dark_knight", "enemy")

AC(tt, "melee")

anchor_y = 0.2
anchor_x = 0.5
image_y = 46
image_x = 64
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0.8
tt.health.hp_max = 300
tt.health_bar.offset = vec_2(0, 35)
tt.info.i18n_key = "ENEMY_DARK_KNIGHT"
tt.info.enc_icon = 12
tt.info.portrait = "info_portraits_enemies_0015"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_dark_knight"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(adx(32), ady(20))
tt.unit.marker_offset.y = -2
--#endregion
--#region enemy_marauder
tt = RT("enemy_marauder", "enemy")

AC(tt, "melee")

anchor_y = 0.22
anchor_x = 0.5
image_y = 56
image_x = 78
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0.6
tt.health.hp_max = 600
tt.health_bar.offset = vec_2(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_MARAUDER"
tt.info.enc_icon = 7
tt.info.portrait = "info_portraits_enemies_0010"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(10)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_marauder"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-20, -5, 40, 40)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(39), ady(24))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_bandit
tt = RT("enemy_bandit", "enemy")

AC(tt, "melee", "dodge")

anchor_y = 0.2
anchor_x = 0.5
image_y = 34
image_x = 48
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 8
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 70
tt.health_bar.offset = vec_2(0, 30)
tt.info.i18n_key = "ENEMY_BANDIT"
tt.info.enc_icon = 5
tt.info.portrait = "info_portraits_enemies_0003"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(4)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_bandit"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, 2)
tt.unit.mod_offset = vec_2(adx(24), ady(17))
--#endregion
--#region enemy_slayer
tt = RT("enemy_slayer", "enemy")

AC(tt, "melee")

anchor_y = 0.22
anchor_x = 0.5
image_y = 66
image_x = 74
tt.enemy.gold = 100
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0.95
tt.health.hp_max = 1200
tt.health_bar.offset = vec_2(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SLAYER"
tt.info.enc_icon = 22
tt.info.portrait = "info_portraits_enemies_0025"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(7)
tt.melee.attacks[1].side_effect = function(this, store, attack, target)
	if this.enemy.can_do_magic then
		local regen = (this.health.hp_max - this.health.hp) * 0.04

		this.health.hp = this.health.hp + regen
	end
end
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_slayer"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = vec_2(32, 42)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(37), ady(25))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_rocketeer
tt = RT("enemy_rocketeer", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 88
image_x = 80
tt.enemy.gold = 30
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 340
tt.health.on_damage = scripts.enemy_rocketeer.on_damage
tt.health_bar.offset = vec_2(0, 78)
tt.info.i18n_key = "ENEMY_ROCKETEER"
tt.info.enc_icon = 21
tt.info.portrait = "info_portraits_enemies_0024"
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0)
tt.render.sprites[1].prefix = "enemy_rocketeer"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "BombExplosionSound"
tt.ui.click_rect = r(-14, 40, 28, 34)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 58)
tt.unit.mod_offset = vec_2(adx(40), ady(56))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_troll
tt = RT("enemy_troll", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.22727272727272727
anchor_x = 0.5
image_y = 44
image_x = 60
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 280
tt.info.i18n_key = "ENEMY_TROLL"
tt.info.enc_icon = 17
tt.info.portrait = "info_portraits_enemies_0019"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.9 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll"
tt.sound_events.death = "DeathTroll"
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(adx(28), ady(23))
--#endregion
--#region enemy_whitewolf
tt = RT("enemy_whitewolf", "enemy")

AC(tt, "melee", "dodge")

anchor_y = 0.3275862068965517
anchor_x = 0.5
image_y = 58
image_x = 64
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 35
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 350
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 39)
tt.info.i18n_key = "ENEMY_WHITE_WOLF"
tt.info.enc_icon = 16
tt.info.portrait = "info_portraits_enemies_0022"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_whitewolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(adx(32), ady(32))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_yeti
tt = RT("enemy_yeti", "enemy")

AC(tt, "melee")

anchor_y = 0.19
anchor_x = 0.5
image_y = 80
image_x = 100
tt.enemy.gold = 120
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 2200
tt.health_bar.offset = vec_2(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_YETI"
tt.info.enc_icon = 20
tt.info.portrait = "info_portraits_enemies_0023"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(13)
}
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_yeti"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(50, 50)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.mod_offset = vec_2(adx(47), ady(35))
tt.unit.size = UNIT_SIZE_LARGE
--#endregion
--#region enemy_forest_troll
tt = RT("enemy_forest_troll", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.21
anchor_x = 0.5
image_y = 100
image_x = 156
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_forest_troll_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.hp_max = 4000
tt.health_bar.offset = vec_2(0, 76)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FOREST_TROLL"
tt.info.enc_icon = 39
tt.info.portrait = "info_portraits_enemies_0039"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "AreaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(15)
}
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_forest_troll"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(58, 55)
tt.ui.click_rect.pos = vec_2(-30, 3)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(1, 2)
tt.unit.mod_offset = vec_2(adx(78), ady(45))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_THORN, F_POISON, F_STUN, F_FREEZE)
--#endregion
--#region enemy_orc_armored
tt = RT("enemy_orc_armored", "enemy")

AC(tt, "melee")

anchor_y = 0.14
anchor_x = 0.5
image_y = 48
image_x = 70
tt.enemy.gold = 30
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0.8
tt.health.hp_max = 400
tt.health_bar.offset = vec_2(0, 36)
tt.info.i18n_key = "ENEMY_ORC_ARMORED"
tt.info.enc_icon = 36
tt.info.portrait = "info_portraits_enemies_0038"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(6)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_armored"
tt.sound_events.death = "DeathOrc"
tt.ui.click_rect.size.y = 28
tt.ui.click_rect.pos.y = 3
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset.y = 2
tt.unit.mod_offset = vec_2(adx(34), ady(21))
tt.accelerated = false
tt.health.on_damage = function(this, store, damage)
	if this.health.hp <= this.health.hp_max * 0.5 and not this.accelerated then
		U.speed_inc(this, 0.2 * FPS)

		this.melee.attacks[1].mod = "mod_orc_blood"
		this.accelerated = true
	end

	return true
end
--#endregion
--#region mod_orc_blood
tt = RT("mod_orc_blood", "mod_blood")
tt.dps.damage_max = 5
tt.dps.damage_min = 5
tt.dps.damage_every = 0.5
--#endregion
--#region enemy_orc_armored_mad
tt = RT("enemy_orc_armored_mad", "enemy_orc_armored")
tt.motion.max_speed = 1.1 * FPS
tt.melee.attacks[1].mod = "mod_orc_blood"
tt.strengthened = false
tt.health.on_damage = function(this, store, damage)
	if this.health.hp <= this.health.hp_max * 0.5 and not this.strengthened then
		U.speed_dec(this, 0.5 * FPS)

		this.health.damage_factor = 0.3
		this.strengthened = true
	end

	return true
end
--#endregion
--#region enemy_orc_rider
tt = RT("enemy_orc_rider", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.14
anchor_x = 0.5
image_y = 62
image_x = 62
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "enemy_orc_armored_mad"
tt.enemy.gold = 25
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(30, 0)
tt.health.hp_max = 400
tt.health.magic_armor = 0.8
tt.health_bar.offset = vec_2(0, 48)
tt.info.i18n_key = "ENEMY_ORC_RIDER"
tt.info.enc_icon = 37
tt.info.portrait = "info_portraits_enemies_0038"
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.4 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_orc_rider"
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect.size = vec_2(32, 38)
tt.ui.click_rect.pos = vec_2(-16, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 23)
tt.unit.mod_offset = vec_2(adx(31), ady(29))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_troll_axe_thrower
tt = RT("enemy_troll_axe_thrower", "enemy")

AC(tt, "melee", "ranged", "auras")

anchor_y = 0.2
anchor_x = 0.5
image_y = 50
image_x = 60
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_troll_axe_thrower_regen"
tt.enemy.gold = 50
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 750
tt.health_bar.offset = vec_2(0, 43)
tt.info.i18n_key = "ENEMY_TROLL_AXE_THROWER"
tt.info.enc_icon = 18
tt.info.portrait = "info_portraits_enemies_0020"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.8 * FPS
tt.ranged.attacks[1].bullet = "axe_troll_axe_thrower"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(4, 15)}
tt.ranged.attacks[1].cooldown = 1 + fts(15)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].requires_magic = true
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_axe_thrower"
tt.sound_events.death = "DeathTroll"
tt.ui.click_rect.size = vec_2(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(adx(29), ady(21))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_raider
tt = RT("enemy_raider", "enemy")

AC(tt, "melee", "ranged")

anchor_y = 0.23
anchor_x = 0.5
image_y = 68
image_x = 88
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.armor = 0.95
tt.health.hp_max = 1250
tt.health_bar.offset = vec_2(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_RAIDER"
tt.info.enc_icon = 46
tt.info.portrait = "info_portraits_enemies_0049"
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(6)
tt.ranged.attacks[1].bullet = "ball_raider"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 24)}
tt.ranged.attacks[1].cooldown = 1.5 + fts(15)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 55
tt.ranged.attacks[1].shoot_time = fts(15)
tt.ranged.attacks[1].requires_magic = true
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_raider"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect.size = vec_2(32, 44)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(43), ady(34))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_pillager
tt = RT("enemy_pillager", "enemy")

AC(tt, "melee")

anchor_y = 0.23
anchor_x = 0.5
image_y = 118
image_x = 154
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(33, 0)
tt.health.hp_max = 2800
tt.health.magic_armor = 0.9
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 61)
tt.info.i18n_key = "ENEMY_PILLAGER"
tt.info.enc_icon = 47
tt.info.portrait = "info_portraits_enemies_0050"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_pillager"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(44, 58)
tt.ui.click_rect.pos.x = -22
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(adx(75), ady(47))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_troll_brute
tt = RT("enemy_troll_brute", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.2125
anchor_x = 0.5
image_y = 80
image_x = 104
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_troll_brute_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 160
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.armor = 0.6
tt.health.hp_max = 2800
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 54)
tt.info.i18n_key = "ENEMY_TROLL_BRUTE"
tt.info.enc_icon = 51
tt.info.portrait = "info_portraits_enemies_0053"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 3
tt.melee.attacks[1].damage_max = 165
tt.melee.attacks[1].damage_min = 95
tt.melee.attacks[1].damage_radius = 44
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_brute"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(30, 40)
tt.ui.click_rect.pos.x = -15
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_troll_chieftain
tt = RT("enemy_troll_chieftain", "enemy")

AC(tt, "melee", "auras", "timed_attacks")

anchor_y = 0.2
anchor_x = 0.5
image_y = 58
image_x = 78
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_troll_chieftain_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 75
tt.enemy.lives_cost = 6
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 1200
tt.health_bar.offset = vec_2(0, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_TROLL_CHIEFTAIN"
tt.info.enc_icon = 19
tt.info.portrait = "info_portraits_enemies_0021"
tt.main_script.update = scripts.enemy_troll_chieftain.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].cast_sound = "EnemyChieftain"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].max_count = {3, 3, 3, 4}
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mods = {"mod_troll_rage", "mod_troll_heal"}
tt.timed_attacks.list[1].exclude_with_mods = {"mod_troll_rage"}
tt.timed_attacks.list[1].allowed_templates = {"enemy_troll", "enemy_troll_axe_thrower", "enemy_troll_skater", "enemy_troll_chieftain", "enemy_troll_brute"}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_chieftain"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(37), ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_goblin_zapper
tt = RT("enemy_goblin_zapper", "enemy")

AC(tt, "melee", "ranged", "death_spawns")

anchor_y = 0.22
anchor_x = 0.5
image_y = 58
image_x = 52
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_goblin_zapper_death"
tt.unit.explode_when_silenced_death = true
tt.death_spawns.delay = 0.11
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 140
tt.health_bar.offset = vec_2(0, 34)
tt.info.i18n_key = "ENEMY_GOBLIN_ZAPPER"
tt.info.enc_icon = 38
tt.info.portrait = "info_portraits_enemies_0040"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "bomb_goblin_zapper"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(4, 12.5)}
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(7)
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_goblin_zapper"
tt.sound_events.death = "BombExplosionSound"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(adx(26), ady(22))
tt.unit.show_blood_pool = false
--#endregion
--#region enemy_demon
tt = RT("enemy_demon", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 44
tt.death_spawns.concurrent_with_death = true
tt.unit.disintegrate_when_silenced_death = true
tt.death_spawns.name = "aura_demon_death"
tt.death_spawns.delay = 0.11
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, 29)
tt.info.i18n_key = "ENEMY_DEMON"
tt.info.enc_icon = 23
tt.info.portrait = "info_portraits_enemies_0027"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(7)
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_RED
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(adx(22), ady(19))
tt.unit.show_blood_pool = false
tt.is_demon = true
--#endregion
--#region enemy_demon_mage
tt = RT("enemy_demon_mage", "enemy")

AC(tt, "melee", "death_spawns", "timed_attacks")

anchor_y = 0.15
anchor_x = 0.5
image_y = 56
image_x = 58
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_mage_death"
tt.unit.disintegrate_when_silenced_death = true
tt.death_spawns.delay = 0.11
tt.enemy.gold = 60
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_DEMON_MAGE"
tt.info.enc_icon = 24
tt.info.portrait = "info_portraits_enemies_0028"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_mage.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 75
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_mage"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].max_count = {4, 4, 4, 5}
tt.timed_attacks.list[1].max_range = 180
tt.timed_attacks.list[1].mod = "mod_demon_shield"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].allowed_templates = {"enemy_demon", "enemy_demon_cerberus", "enemy_demon_flareon", "enemy_demon_gulaemon", "enemy_demon_legion", "enemy_demon_wolf"}
tt.ui.click_rect.size = vec_2(32, 40)
tt.ui.click_rect.pos.x = -16
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.is_demon = true
--#endregion
--#region enemy_demon_wolf
tt = RT("enemy_demon_wolf", "enemy")

AC(tt, "melee", "death_spawns", "dodge")

anchor_y = 0.15
anchor_x = 0.5
image_y = 40
image_x = 58
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_wolf_death"
tt.unit.disintegrate_when_silenced_death = true
tt.death_spawns.delay = 0.11
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 350
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, 31)
tt.info.i18n_key = "ENEMY_DEMON_WOLF"
tt.info.enc_icon = 25
tt.info.portrait = "info_portraits_enemies_0029"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 1.5 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_wolf"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size.x = 32
tt.ui.click_rect.pos = vec_2(-16, 0.5)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(adx(30), ady(20))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt.is_demon = true
--#endregion
--#region enemy_demon_imp
tt = RT("enemy_demon_imp", "enemy")
anchor_y = 0
anchor_x = 0.5
image_y = 96
image_x = 78
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 350
tt.health_bar.offset = vec_2(0, 72)
tt.info.i18n_key = "ENEMY_DEMON_IMP"
tt.info.enc_icon = 26
tt.info.portrait = "info_portraits_enemies_0030"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_imp"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-14, 35, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 58)
tt.unit.mod_offset = vec_2(adx(38), ady(50))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.is_demon = true
--#endregion
--#region enemy_lava_elemental
tt = RT("enemy_lava_elemental", "enemy")

AC(tt, "melee")

anchor_y = 0.19
anchor_x = 0.5
image_y = 84
image_x = 108
tt.enemy.gold = 100
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 2500
tt.health.armor = 0.4
tt.health.magic_armor = 0.2
tt.health.damage_factor_electrical = 0.6
tt.health_bar.offset = vec_2(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "info_portraits_enemies_0034"
tt.info.i18n_key = "ENEMY_LAVA_ELEMENTAL"
tt.info.enc_icon = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 150
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_lava_elemental"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect.size = vec_2(50, 56)
tt.ui.click_rect.pos.x = -25
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.mod_offset = vec_2(adx(53), ady(38))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_POISON, F_BURN)
--#endregion
--#region enemy_sarelgaz_small
tt = RT("enemy_sarelgaz_small", "enemy")
AC(tt, "melee")
anchor_y = 0.19
anchor_x = 0.5
image_y = 68
image_x = 96
tt.enemy.gold = 80
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.armor = 0.65
tt.health.hp_max = 1500
tt.health.magic_armor = 0.65
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 51)
tt.info.portrait = "info_portraits_enemies_0037"
tt.info.i18n_key = "ENEMY_SARELGAZ_SMALL"
tt.info.enc_icon = 31
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "SpiderAttack"
tt.motion.max_speed = 0.8 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_sarelgaz_small"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect.size = vec_2(54, 50)
tt.ui.click_rect.pos.x = -27
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 23)
tt.unit.mod_offset = vec_2(adx(45), ady(35))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)
--#endregion
--#region enemy_rotten_lesser
tt = RT("enemy_rotten_lesser", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.21621621621621623
anchor_x = 0.5
image_y = 74
image_x = 90
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_rotten_lesser_death"
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.hp_max = 500
tt.info.i18n_key = "ENEMY_ROTTEN_LESSER"
tt.info.enc_icon = 58
tt.info.portrait = "info_portraits_enemies_0060"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.21621621621621623)
tt.render.sprites[1].prefix = "enemy_rotten_lesser"
tt.sound_events.death = "EnemyMushroomDeath"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.show_blood_pool = false
--#endregion
--#region enemy_swamp_thing
tt = RT("enemy_swamp_thing", "enemy")

AC(tt, "melee", "ranged", "auras")

anchor_y = 0.24
anchor_x = 0.5
image_y = 87
image_x = 108
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_swamp_thing_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.hp_max = 3000
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 69)
tt.info.i18n_key = "ENEMY_SWAMP_THING"
tt.info.enc_icon = 44
tt.info.portrait = "info_portraits_enemies_0047"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.6 * FPS
tt.ranged.attacks[1].bullet = "bomb_swamp_thing"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(adx(66), ady(86))}
tt.ranged.attacks[1].cooldown = 1 + fts(32)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 165
tt.ranged.attacks[1].min_range = 110
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].requires_magic = true
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_swamp_thing"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect.size = vec_2(50, 54)
tt.ui.click_rect.pos.x = -25
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(0, 24)
tt.unit.size = UNIT_SIZE_LARGE
--#endregion
--#region enemy_spider_rotten
tt = RT("enemy_spider_rotten", "enemy")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.20967741935483872
anchor_x = 0.5
image_y = 62
image_x = 82
tt.enemy.gold = 40
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(34, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 47)
tt.info.portrait = "info_portraits_enemies_0044"
tt.info.i18n_key = "ENEMY_SPIDER_ROTTEN"
tt.info.enc_icon = 42
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].mod = "mod_spider_rotten_poison"
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_spider_rotten_egg"
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].max_count = 6
tt.timed_attacks.list[1].min_cooldown = 5
tt.ui.click_rect.size = vec_2(44, 40)
tt.ui.click_rect.pos = vec_2(-22, -1)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(adx(40), ady(28))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)
--#endregion
--#region mod_spider_rotten_poison
tt = RT("mod_spider_rotten_poison", "mod_poison")
tt.dps.damage_every = 0.5
--#endregion
--#region enemy_spider_rotten_tiny
tt = RT("enemy_spider_rotten_tiny", "enemy")

AC(tt, "melee")

anchor_y = 0.1875
anchor_x = 0.5
image_y = 32
image_x = 42
tt.enemy.gold = 0
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 100
tt.health.magic_armor = 0.25
tt.health_bar.offset = vec_2(0, 20)
tt.info.portrait = "info_portraits_enemies_0045"
tt.info.i18n_key = "ENEMY_SPIDERTINY_ROTTEN"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.melee.attacks[1].mod = "mod_spider_rotten_tiny_poison"
tt.motion.max_speed = 1.0 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spider_rotten_tiny"
tt.sound_events.death = "DeathEplosionShortA"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(adx(1), ady(14))
tt.unit.mod_offset = vec_2(adx(18), ady(13))
tt.vis.bans = bor(F_POISON, F_SKELETON)
--#endregion
--#region mod_spider_rotten_tiny_poison
tt = RT("mod_spider_rotten_tiny_poison", "mod_poison")
tt.dps.damage_every = 1
--#endregion
--#region enemy_rotten_tree
tt = RT("enemy_rotten_tree", "enemy")

AC(tt, "melee")

anchor_y = 0.18421052631578946
anchor_x = 0.5
image_y = 76
image_x = 82
tt.enemy.gold = 60
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.armor = 0.8
tt.health.hp_max = 1000
tt.health_bar.offset = vec_2(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_ROTTEN_TREE"
tt.info.enc_icon = 43
tt.info.portrait = "info_portraits_enemies_0046"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_rotten_tree"
tt.sound_events.death = "DeathSkeleton"
tt.ui.click_rect.size = vec_2(44, 40)
tt.ui.click_rect.pos = vec_2(-22, -1)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false
--#endregion
--#region enemy_giant_rat
tt = RT("enemy_giant_rat", "enemy")

AC(tt, "melee")

anchor_y = 0.275
anchor_x = 0.5
image_y = 40
image_x = 64
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.hp_max = 100
tt.health_bar.offset = vec_2(0, 26)
tt.info.i18n_key = "ENEMY_GIANT_RAT"
tt.info.enc_icon = 61
tt.info.portrait = "info_portraits_enemies_0063"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].mod = "mod_poison_giant_rat"
tt.melee.attacks[1].sound_hit = "EnemyBlackburnGiantRat"
tt.melee.attacks[1].sound_hit_args = {
	chance = 0.1
}
tt.motion.max_speed = 1.3950892857142858 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_giant_rat"
tt.sound_events.death = nil
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 13)
tt.vis.bans = F_SKELETON
--#endregion
--#region enemy_wererat
tt = RT("enemy_wererat", "enemy")

AC(tt, "melee")

anchor_y = 0.17647058823529413
anchor_x = 0.5
image_y = 68
image_x = 94
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.armor = 0.2
tt.health.magic_armor = 0.2
tt.health.hp_max = 450
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 47)
tt.info.i18n_key = "ENEMY_WERERAT"
tt.info.enc_icon = 62
tt.info.portrait = "info_portraits_enemies_0064"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].mod = "mod_wererat_poison"
tt.motion.max_speed = 1.6622340425531914 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_wererat"
tt.sound_events.death = nil
tt.ui.click_rect.size = vec_2(32, 40)
tt.ui.click_rect.pos = vec_2(-16, -1)
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.marker_offset = vec_2(0, 2)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_skeleton
tt = RT("enemy_skeleton", "enemy")

AC(tt, "melee")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 50
tt.enemy.gold = 2
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 120
tt.health_bar.offset = vec_2(0, 30)
tt.info.i18n_key = "ENEMY_SKELETON"
tt.info.enc_icon = 27
tt.info.portrait = "info_portraits_enemies_0031"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(adx(25), ady(17))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH, F_BLOOD)
tt.unit.show_blood_pool = false
--#endregion
--#region enemy_skeleton_big
tt = RT("enemy_skeleton_big", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.2
anchor_x = 0.5
image_y = 50
image_x = 58
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_skeleton_big"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.armor = 0.3
tt.health.hp_max = 400
tt.health_bar.offset = vec_2(0, 39)
tt.info.portrait = "info_portraits_enemies_0032"
tt.info.i18n_key = "ENEMY_SKELETON_BIG"
tt.info.enc_icon = 28
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_skeleton_big"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(adx(30), ady(22))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH, F_BLOOD)
tt.unit.show_blood_pool = false
--#endregion
--#region aura_skeleton_big
tt = RT("aura_skeleton_big", "aura")

AC(tt, "render", "tween")

tt.aura.active = false
tt.aura.allowed_templates = {"enemy_skeleton", "enemy_skeleton_blackburn"}
tt.aura.cooldown = 0
tt.aura.delay = fts(30)
tt.aura.duration = -1
tt.aura.mod = "mod_skeleton_big"
tt.aura.requires_magic = true
tt.aura.radius = 100
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.aura.vis_bans = F_FRIEND
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_skeleton_big.update
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_aura_0001"
tt.render.sprites[1].offset = vec_2(0, -8)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].scale = vec_2(0.5, 0.5)
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "spectral_knight_aura"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(20), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
--#endregion
--#region mod_skeleton_big
tt = RT("mod_skeleton_big", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_skeleton_big.insert
tt.main_script.remove = scripts.mod_skeleton_big.remove
tt.main_script.update = scripts.mod_track_target.update
tt.max_times_applied = 1
tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_buffed"
tt.render.sprites[1].scale = vec_2(0.5, 0.5)
tt.health_damage_factor_dec = 0.15
--#endregion
--#region enemy_zombie
tt = RT("enemy_zombie", "enemy")

AC(tt, "melee")

anchor_y = 0.22
anchor_x = 0.5
image_y = 48
image_x = 42
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0.4
tt.health.hp_max = 320
tt.health_bar.offset = vec_2(0, 35)
tt.info.i18n_key = "ENEMY_ZOMBIE"
tt.info.enc_icon = 41
tt.info.portrait = "info_portraits_enemies_0043"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_zombie"
tt.render.sprites[1].name = "raise"
tt.sound_events.death = "DeathSkeleton"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(adx(23), ady(20))
tt.vis.bans = bor(F_SKELETON, F_POISON, F_POLYMORPH)
tt.unit.show_blood_pool = false
--#endregion
--#region enemy_demon_flareon
tt = RT("enemy_demon_flareon", "enemy")

AC(tt, "melee", "ranged", "death_spawns")

anchor_y = 0.16666666666666666
anchor_x = 0.5
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_flareon_death"
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 250
tt.health.magic_armor = 0.8
tt.health_bar.offset.y = 34
tt.info.i18n_key = "ENEMY_DEMON_FLAREON"
tt.info.enc_icon = 54
tt.info.portrait = "info_portraits_enemies_0055"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.ranged.attacks[1].bullet = "flare_flareon"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 25)}
tt.ranged.attacks[1].cooldown = 3 + fts(36)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_flareon"
tt.render.sprites[1].offset.y = 1
tt.sound_events.death = "DeathPuff"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 12)
tt.unit.show_blood_pool = false
tt.unit.disintegrate_when_silenced_death = true
tt.is_demon = true
--#endregion
--#region enemy_demon_legion
tt = RT("enemy_demon_legion", "enemy")

AC(tt, "melee", "timed_attacks", "death_spawns")

image_y = 86
image_x = 106
anchor_y = 0.1511627906976744
anchor_x = 0.5
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_death"
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.gold = 60
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.armor = 0.8
tt.health.hp_max = 666
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 42
tt.info.i18n_key = "ENEMY_DEMON_LEGION"
tt.info.enc_icon = 56
tt.info.portrait = "info_portraits_enemies_0056"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_legion.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_legion"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].spawn_time = fts(5)
tt.timed_attacks.list[1].clone_time = fts(31)
tt.timed_attacks.list[1].generation = 2
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].spawn_animation = "spawn"
tt.timed_attacks.list[1].entity = "enemy_demon_legion"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].cooldown_after = 10
tt.timed_attacks.list[1].spawn_offset_nodes = {5, 10}
tt.timed_attacks.list[1].nodes_limit = 20
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 12)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.is_demon = true
--#endregion
--#region enemy_demon_gulaemon
tt = RT("enemy_demon_gulaemon", "enemy")

AC(tt, "melee", "timed_actions", "death_spawns")

anchor_y = 0.21296296296296297
anchor_x = 0.5
image_y = 108
image_x = 108
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_gulaemon_death"
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(28, 0)
tt.health.hp_max = 2500
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset.y = 68
tt.info.i18n_key = "ENEMY_DEMON_GULAEMON"
tt.info.enc_icon = 53
tt.info.portrait = "info_portraits_enemies_0057"
tt.main_script.insert = scripts.enemy_base_portal.insert
tt.main_script.update = scripts.enemy_demon_gulaemon.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix_ground = "enemy_demon_gulaemon"
tt.render.sprites[1].prefix_air = "enemy_demon_gulaemon_fly"
tt.render.sprites[1].prefix = tt.render.sprites[1].prefix_ground
tt.render.sprites[1].angles.takeoff = {"initFlyRightLeft", "initFlyUp", "initFlyDown"}
tt.render.sprites[1].angles.land = {"endFlyRightLeft", "endFlyUp", "endFlyDown"}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Inferno_FatDemon_0178"
tt.render.sprites[2].offset = vec_2(0.5, 30)
tt.render.sprites[2].z = Z_DECALS
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].cooldown = 15
tt.timed_actions.list[1].charge_time = fts(3)
tt.timed_actions.list[1].mod = "mod_gulaemon_fly"
tt.timed_actions.list[1].nodes_limit_start = 20
tt.timed_actions.list[1].off_health_bar_y = 17
tt.timed_actions.list[1].off_click_rect_y = 24
tt.timed_actions.list[1].off_mod_offset_y = 23
tt.timed_actions.list[1].off_hit_offset_y = 23
tt.timed_actions.list[1].flags_air = bor(F_FLYING)
tt.timed_actions.list[1].bans_air = bor(F_BLOCK, F_THORN)
tt.ui.click_rect = r(-20, 0, 40, 56)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(0, 20)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.is_demon = true
--#endregion
--#region enemy_necromancer
tt = RT("enemy_necromancer", "enemy")

AC(tt, "melee", "ranged", "timed_actions")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 44
tt.enemy.gold = 60
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 850
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 30)
tt.info.i18n_key = "ENEMY_NECROMANCER"
tt.info.enc_icon = 29
tt.info.portrait = "info_portraits_enemies_0033"
tt.main_script.update = scripts.enemy_necromancer.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.motion.max_speed = 0.5 * FPS
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_necromancer"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-8, 22)}
tt.ranged.attacks[1].cooldown = 1 + fts(23)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_necromancer"
tt.ranged.attacks[1].requires_magic = true
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = CC("spawn_attack")
tt.timed_actions.list[1].cooldown = 8
tt.timed_actions.list[1].spawn_time = fts(12)
tt.timed_actions.list[1].spawn_delay = fts(4)
tt.timed_actions.list[1].entity_chances = {0.06, 1}
tt.timed_actions.list[1].entity_names = {"enemy_skeleton_big", "enemy_skeleton"}
tt.timed_actions.list[1].animation = "summon"
tt.timed_actions.list[1].spawn_animation = "raise"
tt.timed_actions.list[1].max_count = 5
tt.timed_actions.list[1].count_group_name = "necromancer_skeletons"
tt.timed_actions.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_actions.list[1].count_group_max = 35
tt.timed_actions.list[1].summon_offsets = {{2, 0, 0}, {3, 0, 0}, {1, 3, 8}, {2, 3, 8}, {3, 3, 8}, {1, -3, -8}, {2, -3, -8}, {3, -3, -8}}
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(adx(23), ady(17))
--#endregion
--#region enemy_zombiemancer
tt = RT("enemy_zombiemancer", "enemy")

AC(tt, "melee", "ranged", "timed_actions")

anchor_y = 0.2
anchor_x = 0.5
image_y = 38
image_x = 44
tt.enemy.gold = 70
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 30)
tt.info.i18n_key = "ENEMY_ZOMBIEMANCER"
tt.info.enc_icon = 29
tt.info.portrait = "info_portraits_enemies_0033"
tt.main_script.update = scripts.enemy_zombiemancer.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.motion.max_speed = 0.5 * FPS
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bolt_necromancer"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-8, 22)}
tt.ranged.attacks[1].cooldown = 1 + fts(23)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 145
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].shoot_time = fts(9)
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_necromancer"
tt.render.sprites[1].color = {0, 255, 0}
tt.sound_events.death = "DeathPuff"
tt.timed_actions.list[1] = CC("spawn_attack")
tt.timed_actions.list[1].cooldown = 8
tt.timed_actions.list[1].spawn_time = fts(12)
tt.timed_actions.list[1].spawn_delay = fts(4)
tt.timed_actions.list[1].entity = "enemy_halloween_zombie"
tt.timed_actions.list[1].animation = "summon"
tt.timed_actions.list[1].spawn_animation = "raise"
tt.timed_actions.list[1].max_count = 5
tt.timed_actions.list[1].count_group_name = "zombiemancer_zombies"
tt.timed_actions.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_actions.list[1].count_group_max = 35
tt.timed_actions.list[1].summon_offsets = {{2, 0, 0}, {3, 0, 0}, {1, 3, 8}, {2, 3, 8}, {3, 3, 8}, {1, -3, -8}, {2, -3, -8}, {3, -3, -8}}
tt.timed_actions.list[2] = CC("spawn_attack")
tt.timed_actions.list[2].cooldown = 16
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(adx(23), ady(17))
--#endregion
--#region enemy_skeleton_blackburn
tt = RT("enemy_skeleton_blackburn", "enemy_skeleton")
--#endregion
--#region enemy_halloween_zombie
tt = RT("enemy_halloween_zombie", "enemy")

AC(tt, "melee", "moon")

anchor_y = 0.18
image_y = 50

AC(tt, "auras")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 7
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 360
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 32)
tt.info.i18n_key = "ENEMY_HALLOWEEN_ZOMBIE"
tt.info.portrait = "info_portraits_enemies_0062"
tt.info.enc_icon = 60
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound = "HWZombieAmbient"
tt.motion.max_speed = 0.4 * FPS
tt.moon.speed_factor = 2
tt.render.sprites[1].prefix = "enemy_halloween_zombie"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].anchor.y = anchor_y
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, 12)
tt.sound_events.death = "DeathSkeleton"
tt.sound_events.insert = "HWZombieAmbient"
tt.vis.bans = bor(F_POISON)
--#endregion
--#region enemy_zombie_blackburn
tt = RT("enemy_zombie_blackburn", "enemy_halloween_zombie")
--#endregion
--#region enemy_skeleton_warrior
tt = RT("enemy_skeleton_warrior", "enemy_skeleton_big")
--#endregion
--#region enemy_demon_cerberus
tt = RT("enemy_demon_cerberus", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.14285714285714285
anchor_x = 0.5
image_y = 70
image_x = 128
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_demon_cerberus_death"
tt.death_spawns.delay = 0.11
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.gold = 350
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(41, 0)
tt.health.armor = 0.8
tt.health.hp_max = 6000
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 57)
tt.info.i18n_key = "ENEMY_DEMON_CERBERUS"
tt.info.enc_icon = 55
tt.info.portrait = "info_portraits_enemies_0058"
tt.main_script.update = scripts.enemy_demon_cerberus.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 70
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].dodge_time = fts(7)
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_offset = vec_2(20, 0)
tt.motion.max_speed = 1.3 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_demon_cerberus"
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
tt.ui.click_rect.size = vec_2(45, 43)
tt.ui.click_rect.pos = vec_2(-22.5, 2)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_STUN, F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.is_demon = true
--#endregion
--#region enemy_witch
tt = RT("enemy_witch", "enemy")

AC(tt, "ranged")

anchor_y = 0.05319148936170213
anchor_x = 0.5
image_y = 94
image_x = 88
tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.hp_max = 600
tt.health.magic_armor = 0.9
tt.health_bar.offset = vec_2(0, 72)
tt.info.i18n_key = "ENEMY_WITCH"
tt.info.enc_icon = 66
tt.info.portrait = "info_portraits_enemies_0069"
tt.motion.max_speed = 1.4960106382978726 * FPS
tt.ranged.attacks[1].bullet = "bolt_witch"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(13, 45)}
tt.ranged.attacks[1].cooldown = fts(60) + fts(34)
tt.ranged.attacks[1].requires_magic = true
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].max_range = 319.1489361702128
tt.ranged.attacks[1].min_range = 35.46099290780142
tt.ranged.attacks[1].shoot_time = fts(23)
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_witch"
tt.sound_events.death = "EnemyBlackburnWitchDeath"
tt.sound_events.insert = "EnemyBlackburnWitch"
tt.ui.click_rect = r(-14, 30, 30, 32)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.mod_offset = vec_2(0, 47)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_THORN)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion

--#region enemy_spectral_knight
tt = RT("enemy_spectral_knight", "enemy")
AC(tt, "melee", "auras")
image_y = 94
image_x = 128
anchor_y = 0.1595744680851064
anchor_x = 0.5
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "aura_spectral_knight"
tt.enemy.gold = 40
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.armor = 1
tt.health.hp_max = 400
tt.health.immune_to = DAMAGE_PHYSICAL_GROUP
tt.health_bar.offset = vec_2(0, 61)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_SPECTRAL_KNIGHT"
tt.info.enc_icon = 64
tt.info.portrait = "info_portraits_enemies_0067"
tt.main_script.insert = scripts.enemy_spectral_knight.insert
tt.main_script.update = scripts.enemy_spectral_knight.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 0.775709219858156 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_spectral_knight"
tt.sound_events.death = nil
tt.sound_events.insert = "CBSpectralKnight"
tt.sound_events.insert_args = {
	delay = 0.5
}
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 21)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_THORN)
tt.vis.flags = bor(F_ENEMY)
--#endregion
--#region aura_spectral_knight
tt = RT("aura_spectral_knight", "aura")

AC(tt, "render", "tween")

tt.aura.active = false
tt.aura.allowed_templates = {"enemy_fallen_knight", "enemy_skeleton", "enemy_skeleton_warrior", "enemy_skeleton_big", "enemy_skeleton_blackburn"}
tt.aura.cooldown = 0
tt.aura.delay = fts(30)
tt.aura.duration = -1
tt.aura.mod = "mod_spectral_knight"
tt.aura.radius = 106.38297872340426
tt.aura.requires_magic = true
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.aura.vis_bans = F_FRIEND
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_spectral_knight.update
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_aura_0001"
tt.render.sprites[1].offset = vec_2(0, -16)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "spectral_knight_aura"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(20), 255}}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
--#endregion
--#region mod_spectral_knight
tt = RT("mod_spectral_knight", "modifier")

AC(tt, "render")

tt.damage_factor_increase = 1.2
tt.main_script.insert = scripts.mod_spectral_knight.insert
tt.main_script.remove = scripts.mod_spectral_knight.remove
tt.main_script.update = scripts.mod_track_target.update
tt.max_times_applied = 1
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.modifier.vis_flags = bor(F_MOD)
tt.render.sprites[1].name = "mod_spectral_knight_fx"
tt.render.sprites[1].offset = vec_2(0, 32)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "CB_DeathKnight_buffed"
--#endregion
--#region enemy_spectral_knight_spawn
tt = RT("enemy_spectral_knight_spawn", "enemy_spectral_knight")
tt.enemy.gold = 0
--#endregion
--#region enemy_fallen_knight
tt = RT("enemy_fallen_knight", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.1595744680851064
anchor_x = 0.5
image_y = 94
image_x = 128
tt.death_spawns.name = "enemy_spectral_knight_spawn"
tt.death_spawns.spawn_animation = "raise"
tt.death_spawns.delay = fts(11)
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.gold = 40
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.dead_lifetime = 1
tt.health.hp_max = 1000
tt.health.magic_armor = 0.9
tt.health_bar.offset = vec_2(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_FALLEN_KNIGHT"
tt.info.enc_icon = 63
tt.info.portrait = "info_portraits_enemies_0066"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(13)
tt.motion.max_speed = 0.44326241134751776 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_fallen_knight"
tt.sound_events.death = nil
tt.sound_events.death_by_explosion = nil
tt.ui.click_rect = r(-15, 0, 30, 45)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 19)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_troll_skater
tt = RT("enemy_troll_skater", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.18
anchor_x = 0.5
image_y = 50
image_x = 82
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_troll_skater_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 30
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 300
tt.health.armor = 0.15
tt.info.i18n_key = "ENEMY_TROLL_SKATER"
tt.info.enc_icon = 50
tt.info.portrait = "info_portraits_enemies_0052"
tt.main_script.update = scripts.enemy_troll_skater.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.2 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_troll_skater"
tt.sound_events.death = "DeathTroll"
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(0, 13)
tt.skate = {
	mod = "mod_troll_skater",
	vis_bans_extra = bor(F_BLOCK),
	prefix = "enemy_troll",
	walk_angles = {"skateRightLeft", "skateUp", "skateDown"}
}
--#endregion
--#region abomination_explosion_aura
tt = RT("abomination_explosion_aura", "aura")
tt.main_script.update = scripts.abomination_explosion_aura.update
tt.sound_events.insert = "HWAbominationExplosion"
tt.aura.damage_min = 250
tt.aura.damage_max = 250
tt.aura.damage_type = DAMAGE_EXPLOSION
tt.aura.radius = 100
tt.aura.hit_time = fts(10)
--#endregion
--#region werewolf_regen_aura
tt = RT("werewolf_regen_aura", "aura")
tt.main_script.update = scripts.werewolf_regen_aura.update
--#endregion
--#region mod_lycanthropy
tt = RT("mod_lycanthropy", "modifier")

AC(tt, "moon")

tt.moon.transform_name = "enemy_werewolf"
tt.main_script.insert = scripts.mod_lycanthropy.insert
tt.main_script.update = scripts.mod_lycanthropy.update
tt.spawn_hp = nil
tt.active = false
tt.nodeslimit = 30
tt.extra_health = 700
tt.modifier.vis_flags = bor(F_MOD, F_LYCAN)
tt.modifier.vis_bans = bor(F_HERO)
tt.sound_events.transform = "HWWerewolfTransformation"
--#endregion
--#region enemy_abomination
tt = RT("enemy_abomination", "enemy")

AC(tt, "melee", "moon", "death_spawns", "auras")

anchor_y = 0.13157894736842105
image_y = 115
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].cooldown = 0
tt.auras.list[2].name = "aura_abomination"
tt.death_spawns.name = "abomination_explosion_aura"
tt.death_spawns.concurrent_with_death = true
tt.unit.disintegrate_when_silenced_death = true
tt.enemy.lives_cost = 3
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(38, 0)
tt.health.damage_factor_magical = 1.5
tt.health.hp_max = 3500
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 66)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.i18n_key = "ENEMY_ABOMINATION"
tt.info.portrait = "info_portraits_enemies_0065"
tt.info.enc_icon = 65
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 45
tt.melee.attacks[1].damage_min = 35
tt.melee.attacks[1].hit_time = fts(12)
tt.moon.speed_factor = 2
tt.motion.max_speed = 0.45 * FPS
tt.render.sprites[1].prefix = "enemy_abomination"
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.death = "HWAbominationExplosion"
tt.ui.click_rect = r(-25, -10, 50, 60)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(0, 2)
tt.unit.mod_offset = vec_2(0, 30)
tt.unit.hide_after_death = true
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_POISON
tt.vis.flags = bor(tt.vis.flags, F_MOCKING)
--#endregion
--#region aura_abomination
tt = RT("aura_abomination", "aura")

AC(tt, "render", "tween")

tt.aura.active = false
tt.aura.allowed_templates = {"enemy_halloween_zombie", "enemy_zombie_blackburn", "enemy_cannibal_zombie"}
tt.aura.cooldown = 0
tt.aura.delay = fts(30)
tt.aura.duration = -1
tt.aura.requires_magic = true
tt.aura.mod = "mod_abomination"
tt.aura.radius = 120
tt.aura.track_source = true
tt.aura.use_mod_offset = false
tt.aura.vis_bans = F_FRIEND
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_abomination.update
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].anchor = vec_2(0.5, 0.28125)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "CB_DeathKnight_aura_0001"
tt.render.sprites[1].offset = vec_2(0, -16)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].alpha = 0
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "spectral_knight_aura"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 0}, {fts(20), 200}}
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
tt.tween.remove = false
--#endregion
--#region mod_abomination
tt = RT("mod_abomination", "mod_blood")
tt.dps.damage_max = -2
tt.dps.damage_min = -2
tt.dps.damage_every = 1
tt.max_times_applied = 1
--#endregion
--#region enemy_werewolf
tt = RT("enemy_werewolf", "enemy")

AC(tt, "melee", "moon", "auras", "regen")

anchor_y = 0.18181818181818182
image_y = 66
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "werewolf_regen_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "moon_enemy_aura"
tt.auras.list[2].cooldown = 0
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 700
tt.health.magic_armor = 0.3
tt.health_bar.offset = vec_2(0, 38)
tt.info.i18n_key = "ENEMY_WEREWOLF"
tt.info.portrait = "info_portraits_enemies_0068"
tt.info.enc_icon = 67
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(12)
tt.moon.regen_hp = 4
tt.motion.max_speed = 1.3 * FPS
tt.render.sprites[1].prefix = "enemy_werewolf"
tt.render.sprites[1].anchor.y = anchor_y
tt.regen.cooldown = 0.25
tt.regen.health = 2
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 14)
--#endregion
--#region enemy_lycan
tt = RT("enemy_lycan", "enemy")

AC(tt, "melee", "moon", "auras")

anchor_y = 0.14516129032258066
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 65
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 400
tt.health.magic_armor = 0.3
tt.health.on_damage = scripts.enemy_lycan.on_damage
tt.health_bar.offset = vec_2(0, 37)
tt.info.i18n_key = "ENEMY_LYCAN"
tt.info.portrait = "info_portraits_enemies_0070"
tt.info.enc_icon = 68
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(10)
tt.moon.transform_name = "enemy_lycan_werewolf"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].prefix = "enemy_lycan"
tt.render.sprites[1].anchor.y = anchor_y
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 14)
tt.sound_events.death = nil
tt.lycan_trigger_factor = 0.25
--#endregion
--#region enemy_lycan_werewolf
tt = RT("enemy_lycan_werewolf", "enemy")

AC(tt, "melee", "moon", "auras", "regen")

anchor_y = 0.18181818181818182
image_y = 66
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "werewolf_regen_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "moon_enemy_aura"
tt.auras.list[2].cooldown = 0
tt.enemy.gold = 65
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 1100
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_LYCAN"
tt.info.portrait = "info_portraits_enemies_0070"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].mod = "mod_lycanthropy"
tt.melee.attacks[2].chance = 0.2
tt.moon.regen_hp = 8
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].prefix = "enemy_lycan_werewolf"
tt.render.sprites[1].anchor.y = anchor_y
tt.regen.cooldown = 0.25
tt.regen.health = 4
tt.ui.click_rect = r(-20, -10, 40, 50)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = vec_2(0, 22)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.sound_events.insert = "HWAlphaWolf"
--#endregion
--#region enemy_lycan_werewolf_phantom
tt = RT("enemy_lycan_werewolf_phantom", "enemy")

AC(tt, "melee", "moon", "auras", "regen")

anchor_y = 0.18181818181818182
image_y = 66
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "werewolf_regen_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "moon_enemy_aura"
tt.auras.list[2].cooldown = 0
tt.auras.list[3] = CC("aura_attack")
tt.auras.list[3].name = "phantom_warrior_aura"
tt.auras.list[3].cooldown = 0
tt.enemy.gold = 120
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 1250
tt.health.immune_to = DAMAGE_PHYSICAL_GROUP
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "info_portraits_enemies_0070"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 75
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].mod = "mod_lycanthropy"
tt.melee.attacks[2].chance = 0.2
tt.moon.regen_hp = 12
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].prefix = "enemy_lycan_werewolf"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].color = {50, 255, 200}
tt.render.sprites[1].alpha = 150
tt.regen.cooldown = 0.25
tt.regen.health = 6
tt.ui.click_rect = r(-20, -10, 40, 50)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = vec_2(0, 22)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.sound_events.insert = "HWAlphaWolf"
-- -- unknown
-- --#endregion
--#region enemy_hobgoblin
tt = RT("enemy_hobgoblin", "enemy")
-- AC(tt, "melee", "death_spawns")
-- anchor_y = 0.17532467532467533
-- anchor_x = 0.5
-- image_y = 154
-- image_x = 224
-- tt.death_spawns.concurrent_with_death = true
-- tt.death_spawns.name = "fx_coin_shower"
-- tt.death_spawns.offset = vec_2(0, 60)
-- tt.enemy.gold = 250
-- tt.enemy.lives_cost = 20
-- tt.enemy.melee_slot = vec_2(40, 0)
-- tt.health.hp_max = 2000
-- tt.health_bar.offset = vec_2(0, 82)
-- tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
-- tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_ORC"
-- tt.info.portrait = "info_portraits_sc_0094"
-- tt.melee.attacks[1] = CC("area_attack")
-- tt.melee.attacks[1].cooldown = 2
-- tt.melee.attacks[1].count = 10
-- tt.melee.attacks[1].damage_max = 90
-- tt.melee.attacks[1].damage_min = 40
-- tt.melee.attacks[1].damage_radius = 45
-- tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
-- tt.melee.attacks[1].hit_decal = "decal_hobgoblin_ground_hit"
-- tt.melee.attacks[1].hit_fx = "fx_hobgoblin_ground_hit"
-- tt.melee.attacks[1].hit_offset = vec_2(72, -9)
-- tt.melee.attacks[1].hit_time = fts(24)
-- tt.melee.attacks[1].sound = "AreaAttack"
-- tt.melee.attacks[1].sound_args = {
--     delay = fts(24)
-- }
-- tt.motion.max_speed = 0.7 * FPS
-- tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
-- tt.render.sprites[1].prefix = "enemy_hobgoblin"
-- tt.sound_events.death = "DeathJuggernaut"
-- tt.ui.click_rect = r(-30, 0, 60, 70)
-- tt.unit.can_explode = false
-- tt.unit.hit_offset = vec_2(0, 34)
-- tt.unit.mod_offset = vec_2(0, 34)
-- tt.unit.show_blood_pool = false
-- tt.unit.size = UNIT_SIZE_LARGE
-- tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
-- tt.vis.flags = bor(F_ENEMY, F_BOSS)
-- kr2
--#endregion
--#region enemy_bouncer
tt = RT("enemy_bouncer", "enemy")

AC(tt, "melee")

anchor_y = 0.22
image_y = 36
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = {40, 50, 60, 70}
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(38))
tt.info.portrait = "kr2_info_portraits_enemies_0001"
tt.info.enc_icon = 1
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_desertthug"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(8))
tt.unit.mod_offset = vec_2(0, ady(20))
--#endregion
--#region enemy_desert_raider
tt = RT("enemy_desert_raider", "enemy")

AC(tt, "melee")

anchor_y = 0.21
image_y = 38
tt.enemy.gold = 16
tt.enemy.melee_slot = vec_2(21, 0)
tt.health.armor = 0.3
tt.health.hp_max = 200
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(39))
tt.info.portrait = "kr2_info_portraits_enemies_0002"
tt.info.enc_icon = 2
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.07 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_desertraider"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(9))
tt.unit.mod_offset = vec_2(0, ady(21))
--#endregion
--#region enemy_desert_wolf_small
tt = RT("enemy_desert_wolf_small", "enemy")

AC(tt, "melee", "dodge")

anchor_y = 0.21
image_y = 28
tt.dodge.chance = 0.3
tt.dodge.silent = true
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 25
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(32))
tt.info.portrait = "kr2_info_portraits_enemies_0008"
tt.info.enc_icon = 8
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound_hit = "WolfAttack"
tt.motion.max_speed = 2.67 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_wulf"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 11)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(0, ady(14))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
--#endregion
--#region enemy_desert_wolf
tt = RT("enemy_desert_wolf", "enemy")

AC(tt, "melee", "dodge")

anchor_y = 0.28
image_y = 52
tt.dodge.chance = 0.5
tt.dodge.silent = true
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(27, 0)
tt.health.hp_max = 120
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, ady(45))
tt.info.portrait = "kr2_info_portraits_enemies_0009"
tt.info.enc_icon = 9
tt.melee.attacks[1].cooldown = 1 + fts(14)
tt.melee.attacks[1].damage_max = 18
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound_hit = "WolfAttack"
tt.motion.max_speed = 2.13 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_desertwolf"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.marker_offset = vec_2(0, ady(16))
tt.unit.mod_offset = vec_2(0, ady(28))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt.sound_events.death = "DeathPuff"
tt.sound_events.death_by_explosion = "DeathPuff"
--#endregion
--#region enemy_immortal
tt = RT("enemy_immortal", "enemy")

AC(tt, "melee", "death_spawns")

anchor_y = 0.2
image_y = 50
tt.death_spawns.name = "enemy_fallen"
tt.death_spawns.concurrent_with_death = true
tt.enemy.gold = 24
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0.6
tt.health.hp_max = 360
tt.health_bar.offset = vec_2(0, ady(51))
tt.info.portrait = "kr2_info_portraits_enemies_0003"
tt.info.enc_icon = 3
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 28
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(22)
tt.motion.max_speed = 0.854 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_immortal"
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(28))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_fallen
tt = RT("enemy_fallen", "enemy")

AC(tt, "melee")

anchor_y = 0.17
image_y = 40
tt.enemy.gold = 0
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.dead_lifetime = 3
tt.health.hp_max = 120
tt.health_bar.offset = vec_2(0, ady(42))
tt.info.portrait = "kr2_info_portraits_enemies_0007"
tt.info.enc_icon = 7
tt.main_script.remove = scripts.enemy_basic.remove
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 28
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(20)
tt.motion.max_speed = 0.747 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "enemy_fallen"
tt.sound_events.death = "DeathSkeleton"
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(8))
tt.unit.mod_offset = vec_2(0, ady(21))
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
--#endregion
--#region enemy_desert_archer
tt = RT("enemy_desert_archer", "enemy")

AC(tt, "melee", "ranged")

anchor_y = 0.2
image_y = 36
tt.info.portrait = "kr2_info_portraits_enemies_0004"
tt.info.enc_icon = 4
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.marker_offset = vec_2(0, ady(8))
tt.unit.mod_offset = vec_2(0, ady(20))
tt.health.hp_max = 180
tt.health.armor = 0
tt.health.magic_armor = 0.3
tt.health_bar.offset = vec_2(0, ady(39))
tt.render.sprites[1].prefix = "enemy_desertarcher"
tt.render.sprites[1].anchor.y = anchor_y
tt.motion.max_speed = 1.28 * FPS
tt.enemy.gold = 12
tt.enemy.melee_slot = vec_2(18, 0)
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_max = 20
tt.ranged.attacks[1].bullet = "arrow_desert_archer"
tt.ranged.attacks[1].requires_magic = true
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].cooldown = 1 + fts(12)
tt.ranged.attacks[1].max_range = 147.20000000000002
tt.ranged.attacks[1].min_range = 25.6
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(4, 12)}
--#endregion
--#region arrow_desert_archer
tt = RT("arrow_desert_archer", "arrow")

AC(tt, "endless")

tt.bullet.damage_min = 20
tt.bullet.damage_max = 30
tt.bullet.pop = nil
tt.bullet.predict_target_pos = false
tt.endless.factor_map = {{"enemy_desert_archer.rangedDamage", "bullet.damage_min", true}, {"enemy_desert_archer.rangedDamage", "bullet.damage_max", true}}
--#endregion
--#region enemy_scorpion
tt = RT("enemy_scorpion", "enemy")

AC(tt, "melee")

anchor_y = 0.16
image_y = 50
tt.enemy.gold = 28
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(38, 0)
tt.health.armor = 0.85
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, ady(48))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0011"
tt.info.enc_icon = 11
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 28
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "poison"
tt.melee.attacks[2].cooldown = 10
tt.melee.attacks[2].damage_max = 1
tt.melee.attacks[2].damage_min = 1
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].mod = "mod_poison"
tt.melee.attacks[2].vis_flags = bor(F_POISON)
tt.motion.max_speed = 0.854 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_scorpion"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-20, -5, 40, 25)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, ady(8))
tt.unit.mod_offset = vec_2(0, ady(20))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_tremor
tt = RT("enemy_tremor", "enemy")

AC(tt, "melee")

anchor_y = 0.42
image_y = 52
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.hp_max = 120
tt.health_bar.offset = vec_2(0, ady(44))
tt.info.portrait = "kr2_info_portraits_enemies_0010"
tt.info.enc_icon = 10
tt.main_script.update = scripts.enemy_tremor.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.6 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_tremor"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.marker_offset = vec_2(0, -2)
tt.unit.mod_offset = vec_2(1, ady(30))
tt.vis.bans_above_surface = bor(F_SKELETON)
tt.vis.bans_below_surface = bor(F_RANGED, F_SKELETON, F_MOD, F_AREA, F_POLYMORPH)
tt.vis.bans = tt.vis.bans_below_surface
--#endregion
--#region enemy_wasp
tt = RT("enemy_wasp", "enemy")
anchor_y = 0
image_y = 66
tt.enemy.gold = 8
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 80
tt.health_bar.offset = vec_2(0, ady(67))
tt.info.portrait = "kr2_info_portraits_enemies_0012"
tt.info.enc_icon = 12
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.387 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_wasp"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.new_node = "WaspTaunt"
tt.sound_events.new_node_args = {
	gain = {0.3, 0.6}
}
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-10, 34, 20, 20)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 52)
tt.unit.mod_offset = vec_2(0, ady(47))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_wasp_queen
tt = RT("enemy_wasp_queen", "enemy")

AC(tt, "death_spawns")

anchor_y = 0
image_y = 94
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "enemy_wasp"
tt.death_spawns.quantity = 5
tt.death_spawns.spread_nodes = 3
tt.enemy.gold = 40
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 400
tt.health_bar.offset = vec_2(0, ady(85))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0013"
tt.info.enc_icon = 13
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.07 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_wasp_queen"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.new_node = "WaspTaunt"
tt.sound_events.new_node_args = {
	gain = {0.3, 0.6}
}
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-15, 38, 30, 40)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 58)
tt.unit.mod_offset = vec_2(0, ady(60))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_executioner
tt = RT("enemy_executioner", "enemy")

AC(tt, "melee")

anchor_y = 0.19
image_y = 90
tt.enemy.gold = 130
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(29, 0)
tt.health.dead_lifetime = 3
tt.health.hp_max = 2000
tt.health_bar.offset = vec_2(0, ady(87))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0005"
tt.info.enc_icon = 5
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].dodge_time = fts(11)
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].instakill = true
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.attacks[1].vis_bans = F_HERO
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].instakill = nil
tt.melee.attacks[2].vis_bans = 0
tt.melee.cooldown = 1.5
tt.motion.max_speed = 0.64 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_executioner"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-25, -5, 50, 65)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.pop_offset = vec_2(0, 20)
tt.unit.marker_offset = vec_2(0, ady(16))
tt.unit.mod_offset = vec_2(0, ady(39))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_munra
tt = RT("enemy_munra", "enemy")

AC(tt, "melee", "ranged", "timed_attacks", "count_group")

anchor_y = 0.17
image_y = 44
tt.count_group.name = "enemy_munra"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.enemy.gold = 100
tt.enemy.melee_slot = vec_2(19, 0)
tt.health.hp_max = 1000
tt.health_bar.offset = vec_2(0, ady(39))
tt.info.portrait = "kr2_info_portraits_enemies_0006"
tt.info.enc_icon = 6
tt.main_script.update = scripts.enemy_munra.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(13)
tt.motion.max_speed = 0.427 * FPS
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].bullet = "bolt_munra"
tt.ranged.attacks[1].requires_magic = true
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-9, ady(37))}
tt.ranged.attacks[1].cooldown = 1.3
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 115.2
tt.ranged.attacks[1].min_range = 25.6
tt.ranged.attacks[1].shoot_time = fts(11)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_munra"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].entity = "munra_sarcophagus"
tt.timed_attacks.list[1].node_random_max = 40
tt.timed_attacks.list[1].node_random_min = 20
tt.timed_attacks.list[1].nodes_limit = 50
tt.timed_attacks.list[1].sound = "SandwraithCoffin"
tt.timed_attacks.list[1].spawn_time = fts(12)
tt.timed_attacks.list[1].count_group_name = "munra_sarcophagus"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = 35
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].cooldown = 8
tt.timed_attacks.list[2].max_per_cast = {3, 3, 3, 4}
tt.timed_attacks.list[2].mod = "mod_munra_heal"
tt.timed_attacks.list[2].range = 96
tt.timed_attacks.list[2].shoot_time = fts(13)
tt.timed_attacks.list[2].sound = "EnemyHealing"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 9)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(0, ady(20))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region mod_munra_heal
tt = RT("mod_munra_heal", "modifier")

AC(tt, "hps", "render", "endless")

tt.modifier.duration = fts(24)
tt.hps.heal_min = 100
tt.hps.heal_max = 100
tt.hps.heal_every = 9e+99
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].name = "small"
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.endless.factor_map = {{"enemy_munra.healPoints", "hps.heal_min", true}, {"enemy_munra.healPoints", "hps.heal_max", true}}
--#endregion
--#region bolt_munra
tt = RT("bolt_munra", "bolt_enemy")

AC(tt, "endless")

tt.render.sprites[1].prefix = "bolt_munra"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 40
tt.bullet.damage_min = 20
tt.bullet.max_speed = 390
tt.bullet.hit_fx = "fx_bolt_munra_hit"
tt.bullet.max_track_distance = 50
tt.endless.factor_map = {{"enemy_munra.rangedDamage", "bullet.damage_min", true}, {"enemy_munra.rangedDamage", "bullet.damage_max", true}}
--#endregion
--#region fx_bolt_munra_hit
tt = RT("fx_bolt_munra_hit", "fx")
tt.render.sprites[1].name = "bolt_munra_hit"
--#endregion
--#region munra_sarcophagus
tt = RT("munra_sarcophagus", "decal_scripted")

AC(tt, "render", "spawner")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.25
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].prefix = "munra_sarcophagus"
tt.spawner.allowed_subpaths = {1, 3}
tt.spawner.animation_start = "start"
tt.spawner.animation_end = "end"
tt.spawner.count = 4
tt.spawner.cycle_time = fts(75)
tt.spawner.entity = "enemy_fallen"
tt.spawner.forced_waypoint_offset = vec_2(-25, 1)
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.random_subpath = false
--#endregion
--#region enemy_efreeti_small
tt = RT("enemy_efreeti_small", "enemy")

AC(tt, "melee")

anchor_y = 0.11
image_y = 64
tt.enemy.gold = 20
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 250
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(62))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0014"
tt.info.enc_icon = 15
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.07 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "enemy_efreeti_small"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(6))
tt.unit.mod_offset = vec_2(0, ady(24))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.sound_events.death = "DeathPuff"
--#endregion
--#region enemy_cannibal
tt = RT("enemy_cannibal", "enemy")

AC(tt, "melee", "water")

anchor_y = 0.21428571428571427
image_y = 42
tt.cannibalize = {}
tt.cannibalize.extra_hp = 60
tt.cannibalize.hps = 3 * FPS
tt.cannibalize.max_hp = 600
tt.enemy.gold = 15
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 250
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(44))
tt.info.portrait = "kr2_info_portraits_enemies_0019"
tt.info.enc_icon = 18
tt.main_script.update = scripts.enemy_cannibal.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_cannibal"
tt.sound_events.cannibalize = "CanibalEating"
tt.sound_events.water_splash = "SpecialMermaid"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(23))
tt.water.hit_offset = vec_2(0, 5)
tt.water.mod_offset = vec_2(0, 5)
tt.water.health_bar_hidden = true
--#endregion
--#region enemy_cannibal_volcano_normal
tt = RT("enemy_cannibal_volcano_normal", "enemy")

AC(tt, "melee", "tween")

anchor_y = 0.15
image_y = 100
tt.info.portrait = "kr2_info_portraits_enemies_0027"
tt.enemy.gold = 25
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = vec_2(24, 0)
tt.info.i18n_key = "ENEMY_CANNIBAL_VOLCANO"
tt.health.armor = 0
tt.health.hp_max = 900
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(70))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
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
tt.unit.can_explode = true
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(16))
tt.unit.mod_offset = vec_2(0, ady(36))
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_MOCKING)
tt.vis.bans = bor(F_SKELETON, F_UNDEAD)
--#endregion
--#region enemy_hunter
tt = RT("enemy_hunter", "enemy")

AC(tt, "melee", "ranged", "water")

anchor_y = 0.25
image_y = 44
tt.enemy.gold = 15
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 150
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(46))
tt.info.portrait = "kr2_info_portraits_enemies_0020"
tt.info.enc_icon = 19
tt.main_script.insert = scripts.enemy_hunter.insert
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.387 * FPS
tt.ranged.attacks[1].bullet = "dart"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(5, 25)}
tt.ranged.attacks[1].cooldown = fts(22)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 147.2
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(11)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_hunter"
tt.sound_events.water_splash = "SpecialMermaid"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(11))
tt.unit.mod_offset = vec_2(0, ady(24))
tt.water.hit_offset = vec_2(0, 5)
tt.water.mod_offset = vec_2(0, 5)
tt.water.health_bar_hidden = true
--#endregion
--#region dart
tt = RT("dart", "arrow")
tt.bullet.miss_decal = "DartDecal"
tt.bullet.flight_time = fts(17)
tt.bullet.mod = "mod_dart_poison"
tt.bullet.damage_max = 20
tt.bullet.damage_min = 10
tt.bullet.predict_target_pos = false
tt.render.sprites[1].name = "Dart"
tt.render.sprites[1].animated = false
tt.pop = nil
--#endregion
--#region mod_dart_poison
tt = RT("mod_dart_poison", "mod_poison")
tt.modifier.duration = 4
tt.dps.damage_min = 3
tt.dps.damage_max = 3
--#endregion
--#region enemy_shaman_priest
tt = RT("enemy_shaman_priest", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.18
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "shaman_priest_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0
tt.health.hp_max = 700
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(50))
tt.info.portrait = "kr2_info_portraits_enemies_0021"
tt.info.enc_icon = 20
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 26
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_shaman_priest"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(11))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region shaman_priest_aura
tt = RT("shaman_priest_aura", "aura")

AC(tt, "render")

tt.aura.mod = "mod_shaman_priest_heal"
tt.aura.cycle_time = 4
tt.aura.duration = -1
tt.aura.radius = 128
tt.aura.requires_magic = true
tt.aura.track_source = true
tt.aura.targets_per_cycle = 10
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.aura.hide_source_fx = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "shaman_priest_healing"
tt.render.sprites[1].loop = true
--#endregion
--#region mod_shaman_priest_heal
tt = RT("mod_shaman_priest_heal", "modifier")

AC(tt, "hps", "render")

tt.modifier.duration = fts(24)
tt.hps.heal_min = 50
tt.hps.heal_max = 50
tt.hps.heal_every = 9e+99
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
--#endregion
--#region enemy_shaman_magic
tt = RT("enemy_shaman_magic", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.18
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "shaman_magic_aura"
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0
tt.health.hp_max = 700
tt.health.magic_armor = 0.9
tt.health_bar.offset = vec_2(0, ady(50))
tt.info.portrait = "kr2_info_portraits_enemies_0023"
tt.info.enc_icon = 22
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 26
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_shaman_magic"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(11))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region shaman_magic_aura
tt = RT("shaman_magic_aura", "aura")

AC(tt, "render")

tt.aura.allowed_templates = {"enemy_hunter", "enemy_cannibal", "enemy_shaman_priest", "enemy_shaman_shield", "enemy_shaman_necro", "enemy_shaman_rage", "enemy_gorilla", "enemy_cannibal_volcano_normal", "enemy_shaman_gravity"}
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.mod = "mod_shaman_magic_armor"
tt.aura.radius = 115.2
tt.aura.requires_magic = true
tt.aura.targets_per_cycle = 10
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "shaman_magic_aura"
--#endregion
--#region mod_shaman_magic_armor
tt = RT("mod_shaman_magic_armor", "modifier")

AC(tt, "render", "armor_buff")

tt.armor_buff.cycle_time = 1
tt.armor_buff.magic = true
tt.armor_buff.max_factor = 0.8
tt.armor_buff.step_factor = 0.03
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update
tt.modifier.duration = 1.5
tt.render.sprites[1].name = "shaman_magic_mod"
--#endregion
--#region enemy_shaman_rage
tt = RT("enemy_shaman_rage", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.18
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "shaman_rage_aura"
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0
tt.health.hp_max = 800
tt.health_bar.offset = vec_2(0, ady(50))
tt.info.portrait = "kr2_info_portraits_enemies_0023"
tt.info.enc_icon = 22
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 26
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_shaman_magic"
tt.render.sprites[1].color = {255, 150, 150}
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(11))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region shaman_rage_aura
tt = RT("shaman_rage_aura", "aura")

AC(tt, "render")

tt.aura.allowed_templates = {"enemy_hunter", "enemy_cannibal", "enemy_shaman_priest", "enemy_shaman_shield", "enemy_shaman_necro", "enemy_shaman_rage", "enemy_shaman_magic", "enemy_gorilla", "enemy_cannibal_volcano_normal", "enemy_shaman_gravity"}
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.mod = "mod_shaman_rage"
tt.aura.radius = 115.2
tt.aura.requires_magic = true
tt.aura.targets_per_cycle = 10
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].loop = true
tt.render.sprites[1].name = "shaman_magic_aura"
tt.render.sprites[1].color = {255, 0, 255}
--#endregion
--#region mod_shaman_rage
tt = RT("mod_shaman_rage", "modifier")

AC(tt, "render")

tt.extra_armor = 0
tt.extra_damage_max = 40
tt.extra_damage_min = 20
tt.extra_speed = 30
tt.main_script.insert = scripts.mod_troll_rage.insert
tt.main_script.remove = scripts.mod_troll_rage.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 1
tt.modifier.type = MOD_TYPE_RAGE
tt.modifier.vis_flags = bor(F_MOD)
tt.modifier.use_mod_offset = false
tt.render.sprites[1].name = "shaman_magic_mod"
tt.render.sprites[1].color = {255, 0, 255}
--#endregion
--#region enemy_shaman_shield
tt = RT("enemy_shaman_shield", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.16
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "shaman_shield_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0.8
tt.health.hp_max = 700
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(47))
tt.info.portrait = "kr2_info_portraits_enemies_0022"
tt.info.enc_icon = 21
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 26
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_shaman_shield"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region shaman_shield_aura
tt = RT("shaman_shield_aura", "aura")

AC(tt, "render")

tt.aura.mod = "mod_shaman_armor"
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.radius = 115.2
tt.aura.track_source = true
tt.aura.targets_per_cycle = 10
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.aura.allowed_templates = {"enemy_hunter", "enemy_cannibal", "enemy_shaman_priest", "enemy_shaman_magic", "enemy_shaman_necro", "enemy_shaman_rage", "enemy_gorilla", "enemy_cannibal_volcano_normal", "enemy_shaman_gravity"}
tt.aura.requires_magic = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "shaman_shield_aura"
tt.render.sprites[1].loop = true
--#endregion
--#region mod_shaman_armor
tt = RT("mod_shaman_armor", "modifier")

AC(tt, "render", "armor_buff")

tt.modifier.duration = 1.5
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = false
tt.armor_buff.max_factor = 0.8
tt.armor_buff.step_factor = 0.03
tt.armor_buff.cycle_time = 1
tt.render.sprites[1].name = "buff_armor"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.15625
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update
--#endregion
--#region enemy_shaman_necro
tt = RT("enemy_shaman_necro", "enemy")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.22
image_y = 58
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(21, 0)
tt.health.armor = 0
tt.health.hp_max = 900
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(51))
tt.info.portrait = "kr2_info_portraits_enemies_0024"
tt.info.enc_icon = 23
tt.main_script.update = scripts.enemy_shaman_necro.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.ranged.attacks[1].bullet = "bolt_shaman_necro"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-8, 32)}
tt.ranged.attacks[1].cooldown = 1 + fts(28)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 147.2
tt.ranged.attacks[1].min_range = 25.6
tt.ranged.attacks[1].shoot_time = fts(11)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_shaman_necro"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].allowed_templates = {"enemy_cannibal", "enemy_hunter", "enemy_shaman_shield", "enemy_shaman_magic", "enemy_shaman_priest", "enemy_shaman_rage", "enemy_gorilla", "enemy_savage_bird_rider", "enemy_cannibal_volcano_normal", "enemy_shaman_gravity"}
tt.timed_attacks.list[1].animation = "necromancer"
tt.timed_attacks.list[1].cast_time = fts(16)
tt.timed_attacks.list[1].cooldown = 1
tt.timed_attacks.list[1].max_range = 179.2
tt.timed_attacks.list[1].sound = "CanibalNecromancer"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(12))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region bolt_shaman_necro
tt = RT("bolt_shaman_necro", "bolt_enemy")
tt.render.sprites[1].prefix = "bolt_shaman_necro"
tt.render.sprites[1].anchor = vec_2(0.625, 0.5)
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 50
tt.bullet.damage_min = 30
tt.bullet.max_speed = 450
tt.bullet.max_track_distance = 50
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.hit_fx = "fx_bolt_shaman_necro_hit"
--#endregion
--#region fx_bolt_shaman_necro_hit
tt = RT("fx_bolt_shaman_necro_hit", "fx")
tt.render.sprites[1].name = "bolt_shaman_necro_hit"
--#endregion
--#region enemy_cannibal_zombie
tt = RT("enemy_cannibal_zombie", "enemy")

AC(tt, "melee")

anchor_y = 0.2
image_y = 48
tt.enemy.gold = 0
tt.enemy.melee_slot = vec_2(17, 0)
tt.health.armor = 0
tt.health.hp_max = 500
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(42))
tt.info.portrait = "kr2_info_portraits_enemies_0028"
tt.info.enc_icon = 24
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound = "CanibalZombie"
tt.motion.max_speed = 0.64 * FPS
tt.render.sprites[1].prefix = "enemy_cannibal_zombie"
tt.render.sprites[1].anchor.y = anchor_y
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(21))
tt.sound_events.insert = "CanibalZombie"
tt.vis.bans = F_POLYMORPH
--#endregion
--#region enemy_jungle_spider_tiny
tt = RT("enemy_jungle_spider_tiny", "enemy")

AC(tt, "melee")

anchor_y = 0.17
image_y = 32
tt.enemy.gold = 0
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0
tt.health.hp_max = {15, 20, 25, 30}
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, ady(24))
tt.info.portrait = "kr2_info_portraits_enemies_0018"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 5
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 3.2 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_jungle_spider_tiny"
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(0, ady(17))
tt.unit.explode_fx = "fx_spider_explode"
tt.sound_events.death = "DeathEplosion"
tt.sound_events.death_args = {
	gain = 0.2
}
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region enemy_jungle_spider_small
tt = RT("enemy_jungle_spider_small", "enemy")

AC(tt, "melee")

anchor_y = 0.17
image_y = 34
tt.enemy.gold = 8
tt.enemy.melee_slot = vec_2(22, 0)
tt.health.armor = 0
tt.health.hp_max = 100
tt.health.magic_armor = 0.65
tt.health_bar.offset = vec_2(0, ady(35))
tt.info.portrait = "kr2_info_portraits_enemies_0016"
tt.info.enc_icon = 16
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.6 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_jungle_spider_small"
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, ady(5))
tt.unit.mod_offset = vec_2(0, ady(17))
tt.unit.explode_fx = "fx_spider_explode"
tt.sound_events.death = "DeathEplosion"
tt.sound_events.death_args = {
	gain = 0.3
}
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region enemy_jungle_spider_big
tt = RT("enemy_jungle_spider_big", "enemy")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.19
image_y = 50
tt.enemy.gold = 40
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 500
tt.health.magic_armor = 0.8
tt.health_bar.offset = vec_2(0, ady(49))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0017"
tt.info.enc_icon = 17
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound_hit = "SpiderAttack"
tt.motion.max_speed = 1.6 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_jungle_spider_big"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "jungle_spider_egg"
tt.timed_attacks.list[1].max_cooldown = 6
tt.timed_attacks.list[1].max_count = {3, 3, 3, 4}
tt.timed_attacks.list[1].min_cooldown = 2
tt.unit.blood_color = BLOOD_GREEN
tt.unit.explode_fx = "fx_spider_explode"
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, ady(6))
tt.unit.mod_offset = vec_2(0, ady(17))
tt.vis.bans = bor(F_SKELETON, F_POISON)
--#endregion
--#region jungle_spider_egg
tt = RT("jungle_spider_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "jungle_spider_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 3
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_jungle_spider_tiny"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region enemy_gorilla
tt = RT("enemy_gorilla", "enemy")

AC(tt, "melee")

anchor_y = 0.12
image_y = 108
tt.enemy.gold = 160
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(29, 0)
tt.health.armor = 0
tt.health.hp_max = 2800
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(93))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0025"
tt.info.enc_icon = 25
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 51.2
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(30, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.motion.max_speed = 0.854 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_gorilla"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-25, -10, 50, 70)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.marker_offset = vec_2(0, ady(13))
tt.unit.mod_offset = vec_2(0, ady(36))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_EAT)
tt.vis.flags = bor(tt.vis.flags, F_MOCKING)
--#endregion
--#region alien_egg
tt = RT("alien_egg", "decal_scripted")

AC(tt, "spawner", "sound_events")

tt.main_script.update = scripts.alien_egg.update
tt.render.sprites[1].prefix = "alien_egg"
tt.sound_events.destroy = "SpecialAlienEggOpen"
tt.sound_events.open = "SpecialAlienEggOpen"
tt.spawner.count = 3
tt.spawner.cycle_time = 0.25
tt.spawner.entity = "enemy_alien_breeder"
tt.spawner.random_subpath = true
tt.spawner.eternal = true
tt.spawner.ni = 1
--#endregion
--#region enemy_alien_breeder
tt = RT("enemy_alien_breeder", "enemy")

AC(tt, "track_kills", "tween")

anchor_y = 0.23
image_y = 40
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(17, 0)
tt.health.armor = 0
tt.health.hp_max = 140
tt.health.magic_armor = 0.6
tt.health_bar.offset = vec_2(0, ady(30))
tt.info.portrait = "kr2_info_portraits_enemies_0053"
tt.info.enc_icon = 27
tt.info.fn = scripts.enemy_alien_breeder.get_info
tt.main_script.insert = scripts.enemy_alien_breeder.insert
tt.main_script.update = scripts.enemy_alien_breeder.update
tt.motion.max_speed = 2.454 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_alien_breeder"
tt.sound_events.death = "DeathEplosion"
tt.tween.props[1].name = "offset"
tt.tween.disabled = true
tt.tween.remove = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.marker_offset = vec_2(0, ady(9))
tt.unit.mod_offset = vec_2(0, ady(19))
tt.vis.bans = bor(F_SKELETON)
tt.facehug_offsets = {}
tt.facehug_offsets.soldier_default = vec_2(2, -2)
tt.facehug_offsets.soldier_templar = vec_2(2, 0)
tt.facehug_offsets.soldier_assassin = vec_2(2, 0)
tt.facehug_offsets.soldier_death_rider = vec_2(3, 16)
tt.facehug_offsets.soldier_frankenstein = vec_2(0, 41)
tt.facehug_offsets.hero_default = vec_2(0, 4)
tt.facehug_offsets.hero_alien = vec_2(0, 10)
tt.facehug_offsets.hero_beastmaster = vec_2(0, 8)
tt.facehug_offsets.hero_giant = vec_2(0, 20)
tt.facehug_offsets.hero_pirate = vec_2(0, 6)
tt.facehug_offsets.hero_priest = vec_2(0, 7)
tt.facehug_offsets.hero_wizard = vec_2(0, 6)
tt.facehug_offsets.hero_voodoo_witch = vec_2(3, 4)
tt.facehug_offsets.hero_crab = vec_2(6, 7)
tt.facehug_offsets.hero_minotaur = vec_2(11, 14)
tt.facehug_offsets.hero_monk = vec_2(0, 2)
tt.facehug_offsets.hero_monkey_god = vec_2(10, 5)
tt.facehug_offsets.hero_vampiress = vec_2(0, 20)
tt.facehug_offsets.hero_van_helsing = vec_2(1, 5)
--#endregion
--#region enemy_alien_reaper
tt = RT("enemy_alien_reaper", "enemy")

AC(tt, "melee")

anchor_y = 0.13
image_y = 50
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(29, 0)
tt.health.armor = 0
tt.health.hp_max = 500
tt.health.magic_armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, ady(50))
tt.info.portrait = "kr2_info_portraits_enemies_0054"
tt.info.enc_icon = 28
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.067 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_alien_reaper"
tt.ui.click_rect = r(-15, -5, 30, 40)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.marker_offset = vec_2(0, ady(6))
tt.unit.mod_offset = vec_2(0, ady(18))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.sound_events.death = "DeathEplosion"
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_savage_bird
tt = RT("enemy_savage_bird", "enemy")
anchor_y = 0
image_y = 112
tt.enemy.gold = 15
tt.health.armor = 0
tt.health.hp_max = 150
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(84))
tt.info.portrait = "kr2_info_portraits_enemies_0057"
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 2.134 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_savage_bird"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-20, 42, 40, 45)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 58)
tt.unit.marker_offset = vec_2(0, ady(1))
tt.unit.mod_offset = vec_2(0, ady(60))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_savage_bird_rider
tt = RT("enemy_savage_bird_rider", "enemy")

AC(tt, "ranged", "death_spawns")

anchor_y = 0
image_y = 112
tt.info.portrait = "kr2_info_portraits_enemies_0026"
tt.info.enc_icon = 26
tt.death_spawns.name = "enemy_savage_bird"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.fx = "savage_bird_rider_drop_dead"
tt.death_spawns.fx_flip_to_source = true
tt.enemy.gold = 25
tt.health.armor = 0
tt.health.hp_max = 250
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(90))
tt.motion.max_speed = 1.067 * FPS
tt.ranged.attacks[1].bullet = "savage_bird_spear"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(4, 75)}
tt.ranged.attacks[1].cooldown = fts(41)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 166.4
tt.ranged.attacks[1].min_range = 32
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].sync_animation = true
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_savage_bird_rider"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = nil
tt.ui.click_rect = r(-20, 42, 40, 45)
tt.unit.death_animation = nil
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 62)
tt.unit.marker_offset = vec_2(0, ady(1))
tt.unit.mod_offset = vec_2(0, ady(60))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region savage_bird_rider_drop_dead
tt = RT("savage_bird_rider_drop_dead", "decal")

AC(tt, "enemy", "health", "vis", "unit", "heading", "nav_path", "motion", "sound_events")

tt.health.hp = 0
tt.health.hp_max = 0
tt.health.dead_lifetime = 2
tt.render.sprites[1].name = "savage_bird_rider_drop_dead"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0
tt.enemy.necromancer_offset = vec_2(-25, 14)
tt.sound_events.insert = "DeathHuman"
--#endregion
--#region savage_bird_spear
tt = RT("savage_bird_spear", "arrow")
tt.bullet.miss_decal = "decal_spear"
tt.bullet.flight_time = fts(18)
tt.bullet.damage_max = 80
tt.bullet.damage_min = 40
tt.bullet.predict_target_pos = false
tt.render.sprites[1].name = "spear"
tt.render.sprites[1].animated = false
--#endregion
--#region enemy_broodguard
tt = RT("enemy_broodguard", "enemy")

AC(tt, "melee", "cliff", "auras")

anchor_y = 0.19
image_y = 42
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_damage_sprint"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 300
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(44))
tt.info.portrait = "kr2_info_portraits_enemies_0029"
tt.info.enc_icon = 29
tt.main_script.update = scripts.enemy_mixed_cliff.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.067 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_broodguard"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.marker_offset = vec_2(0, ady(9))
tt.unit.mod_offset = vec_2(0, ady(20))
tt.damage_sprint_factor = 0.78125
tt.vis.bans = F_POLYMORPH
--#endregion
--#region aura_damage_sprint
tt = RT("aura_damage_sprint", "aura")
tt.aura.duration = -1
tt.aura.track_source = true
tt.main_script.update = scripts.aura_damage_sprint.update
tt.main_script.insert = scripts.aura_damage_sprint.insert
tt.main_script.remove = scripts.aura_damage_sprint.remove
--#endregion
--#region enemy_blazefang
tt = RT("enemy_blazefang", "enemy")

AC(tt, "melee", "ranged", "death_spawns")

anchor_y = 0.2
image_y = 58
tt.death_spawns.name = "blazefang_explosion"
tt.death_spawns.quantity = 1
tt.death_spawns.concurrent_with_death = true
tt.unit.explode_when_silenced_death = true
tt.enemy.gold = 40
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.armor = 0
tt.health.hp_max = 600
tt.health.magic_armor = 0.7
tt.health_bar.offset = vec_2(0, ady(60))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0032"
tt.info.enc_icon = 30
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 18
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.854 * FPS
tt.ranged.cooldown = 1 + fts(32)
tt.ranged.attacks[1].bullet = "bolt_blazefang"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(25, 10), vec_2(12, 22), vec_2(6, 4)}
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 147.20000000000002
tt.ranged.attacks[1].min_range = 25.6
tt.ranged.attacks[1].shoot_time = fts(24)
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].shared_cooldown = true
tt.ranged.attacks[2] = table.deepclone(tt.ranged.attacks[1])
tt.ranged.attacks[2].bullet = "bolt_blazefang_instakill"
tt.ranged.attacks[2].chance = 0.2
tt.ranged.attacks[2].vis_flags = bor(F_DISINTEGRATED, F_RANGED)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_blazefang"
tt.render.sprites[1].angles.ranged = {"ranged_side", "ranged_up", "ranged_down"}
tt.render.sprites[1].angles_flip_vertical = {
	ranged = true
}
tt.render.sprites[1].angles_custom = {
	ranged = {35, 145, 210, 335}
}
tt.sound_events.death = "SaurianBlazefangDeath"
tt.ui.click_rect = r(-25, -10, 50, 55)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(30))
--#endregion
--#region blazefang_explosion
tt = RT("blazefang_explosion", "bullet")
tt.render = nil
tt.sound_events = nil
tt.main_script.update = scripts.blazefang_explosion.update
tt.bullet.damage_min = 100
tt.bullet.damage_max = 100
tt.bullet.damage_radius = 76.8
--#endregion
--#region bolt_blazefang
tt = RT("bolt_blazefang", "bolt_enemy")
tt.render.sprites[1].prefix = "bolt_blazefang"
tt.render.sprites[1].anchor = vec_2(0.53, 0.58)
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 100
tt.bullet.damage_min = 60
tt.bullet.max_speed = 1200
tt.bullet.acceleration_factor = 0.3
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_TRUE)
tt.bullet.hit_fx = "fx_bolt_blazefang_hit"
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianBlazefangAttack"
--#endregion
--#region bolt_blazefang_instakill
tt = RT("bolt_blazefang_instakill", "bolt_blazefang")
tt.bullet.damage_type = bor(DAMAGE_DISINTEGRATE, DAMAGE_INSTAKILL)
--#endregion
--#region fx_bolt_blazefang_hit
tt = RT("fx_bolt_blazefang_hit", "fx")
tt.render.sprites[1].name = "bolt_blazefang_hit"
--#endregion
--#region enemy_brute
tt = RT("enemy_brute", "enemy")

AC(tt, "melee")

anchor_y = 0.16
image_y = 88
tt.enemy.gold = 200
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(29, 0)
tt.health.armor = 0
tt.health.hp_max = 4400
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(75))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0035"
tt.info.enc_icon = 32
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 60
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.melee.attacks[1].dodge_time = fts(6)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound_hit = "SaurianBruteAttack"
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].animation = "area_attack"
tt.melee.attacks[2].cooldown = 13.333333333333334
tt.melee.attacks[2].damage_max = 120
tt.melee.attacks[2].damage_min = 80
tt.melee.attacks[2].damage_radius = 38.4
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].hit_offset = vec_2(30, 0)
tt.melee.attacks[2].hit_times = {fts(10), fts(20), fts(30)}
tt.melee.attacks[2].sound_hit = "SaurianBruteAttack"
tt.motion.max_speed = 0.64 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_brute"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-25, -10, 50, 65)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(15))
tt.unit.mod_offset = vec_2(0, ady(30))
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_myrmidon
tt = RT("enemy_myrmidon", "enemy")

AC(tt, "melee")

anchor_y = 0.21
image_y = 62
tt.enemy.gold = 50
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.armor = 0.6
tt.health.hp_max = 800
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(63))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0034"
tt.info.enc_icon = 33
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 34
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "bite_attack"
tt.melee.attacks[2].cooldown = 12
tt.melee.attacks[2].damage_max = 150
tt.melee.attacks[2].damage_min = 75
tt.melee.attacks[2].mod = "mod_myrmidon_lifesteal"
tt.melee.attacks[2].sound_hit = "SaurianMyrmidonBite"
tt.melee.attacks[2].hit_time = fts(5)
tt.motion.max_speed = 0.854 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_myrmidon"
tt.ui.click_rect = r(-25, -10, 50, 50)
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, ady(12))
tt.unit.mod_offset = vec_2(0, ady(30))
--#endregion
--#region mod_myrmidon_lifesteal
tt = RT("mod_myrmidon_lifesteal", "modifier")
tt.heal_hp = 125
tt.main_script.insert = scripts.mod_simple_lifesteal.insert
--#endregion
--#region enemy_nightscale
tt = RT("enemy_nightscale", "enemy")

AC(tt, "melee", "cliff")

anchor_y = 0.26
image_y = 48
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 350
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, ady(48))
tt.info.portrait = "kr2_info_portraits_enemies_0031"
tt.info.enc_icon = 34
tt.main_script.update = scripts.enemy_nightscale.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 42
tt.melee.attacks[1].damage_min = 28
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.28 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_nightscale"
tt.sound_events.hide = "SaurianNightscaleInvisible"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(12))
tt.unit.mod_offset = vec_2(0, ady(22))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.hidden = {}
tt.hidden.trigger_health_factor = 0.6
tt.hidden.duration = 8
tt.hidden.max_times = 1
tt.hidden.nodeslimit = 25
tt.hidden.ts = 0
--#endregion
--#region enemy_darter
tt = RT("enemy_darter", "enemy")

AC(tt, "melee", "cliff")

anchor_y = 0.19
image_y = 36
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 250
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(39))
tt.info.portrait = "kr2_info_portraits_enemies_0030"
tt.info.enc_icon = 31
tt.main_script.update = scripts.enemy_darter.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 22
tt.melee.attacks[1].damage_min = 18
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.6 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_darter"
tt.sound_events.blink = "SaurianDarterTeleporth"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.marker_offset = vec_2(0, ady(7))
tt.unit.mod_offset = vec_2(0, ady(16))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.blink = {}
tt.blink.cooldown = 4
tt.blink.nodeslimit = 45
tt.blink.nodeslimit_conn = 15
tt.blink.nodes_offset_min = 15
tt.blink.nodes_offset_max = 25
tt.blink.travel_time = fts(11)
tt.blink.fx = "fx_darter_blink"
tt.blink.ts = 0
--#endregion
--#region fx_darter_blink
tt = RT("fx_darter_blink", "fx")
tt.render.sprites[1].name = "darter_blink"
tt.render.sprites[1].anchor.y = 0.22
--#endregion
--#region enemy_savant
tt = RT("enemy_savant", "enemy")

AC(tt, "melee", "ranged", "timed_attacks")

anchor_y = 0.26
image_y = 42
tt.enemy.gold = 100
tt.enemy.melee_slot = vec_2(22, 0)
tt.health.armor = 0
tt.health.hp_max = 1000
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, ady(45))
tt.info.portrait = "kr2_info_portraits_enemies_0033"
tt.info.enc_icon = 37
tt.main_script.update = scripts.enemy_savant.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 66
tt.melee.attacks[1].damage_min = 34
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.64 * FPS
tt.ranged.attacks[1].bullet = "savant_ray"
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 147.20000000000002
tt.ranged.attacks[1].min_range = 44.800000000000004
tt.ranged.attacks[1].bullet_start_offset = {vec_2(28, ady(28))}
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_savant"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].animations = {"portal_start", "portal_loop", "portal_end"}
tt.timed_attacks.list[1].min_cooldown = 5
tt.timed_attacks.list[1].max_cooldown = 10
tt.timed_attacks.list[1].entity = "savant_portal"
tt.timed_attacks.list[1].nodes_limit = 20
tt.timed_attacks.list[1].node_offset = 12
tt.timed_attacks.list[1].count_group_name = "savant_portals"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = 25
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(9))
tt.unit.mod_offset = vec_2(0, ady(22))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region savant_portal
tt = RT("savant_portal", "decal_scripted")

AC(tt, "render", "spawner", "sound_events")

tt.main_script.update = scripts.savant_portal.update
tt.render.sprites[1].anchor.y = 0.5
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].prefix = "savant_portal"
tt.render.sprites[1].z = Z_DECALS
tt.portal = {}
tt.portal.entities = {{0.1, "enemy_darter"}, {0.3, "enemy_nightscale"}, {1, "enemy_broodguard"}}
tt.portal.node_var = {-5, 5}
tt.portal.cycle_time = 1
tt.portal.duration = 6
tt.portal.max_count = 20
tt.portal.spawn_fx = "fx_darter_blink"
tt.portal.pi = nil
tt.portal.spi = nil
tt.portal.ni = nil
tt.portal.finished = false
tt.sound_events.insert = "SaurianSavantOpenPortal"
tt.sound_events.spawn = "SaurianSavantTeleporth"
tt.sound_events.loop = "SaurianSavantPortalLoop"
--#endregion
--#region savant_ray
tt = RT("savant_ray", "bullet")
tt.image_width = 115
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "savant_ray"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 90
tt.bullet.damage_max = 160
tt.bullet.hit_time = fts(3)
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianSavantAttack"
--#endregion
--#region enemy_sniper
tt = RT("enemy_sniper", "enemy")

AC(tt, "melee", "ranged")

image_y = 42
anchor_y = 0.16666666666666666
tt.info.portrait = "kr2_info_portraits_enemies_0041"
tt.info.enc_icon = 59
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 14)
tt.main_script.insert = scripts.enemy_sniper.insert
tt.main_script.update = scripts.enemy_sniper.update
tt.health.hp_max = 500
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 37)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].prefix = "enemy_sniper"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles.ranged_start = {"ranged_start_side", "ranged_start_up", "ranged_start_down"}
tt.render.sprites[1].angles.ranged_loop = {"ranged_loop_side", "ranged_loop_up", "ranged_loop_down"}
tt.render.sprites[1].angles.ranged_end = {"ranged_end_side", "ranged_end_up", "ranged_end_down"}
tt.render.sprites[1].angles_flip_vertical = {
	ranged_end = true,
	ranged_loop = true,
	ranged_start = true
}
tt.render.sprites[1].angles_custom = {
	ranged = {35, 145, 210, 335}
}
tt.motion.max_speed = 1.6 * FPS
tt.enemy.gold = 40
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(25, 0)
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 12
tt.melee.attacks[1].damage_max = 22
tt.ranged.attacks[1].bullet = "bolt_sniper"
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].shoot_time = fts(5)
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 450
tt.ranged.attacks[1].min_range = 51
tt.ranged.attacks[1].range_var = 100
tt.ranged.attacks[1].animations = {"ranged_start", "ranged_loop", "ranged_end"}
tt.ranged.attacks[1].bullet_start_offset = {vec_2(14, ady(21)), vec_2(10, ady(34)), vec_2(8, ady(10))}
--#endregion
--#region bolt_sniper
tt = RT("bolt_sniper", "bolt_enemy")
tt.render.sprites[1].prefix = "bolt_sniper"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_max = 100
tt.bullet.damage_min = 100
tt.bullet.max_speed = 30 * FPS
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.max_track_distance = 50
tt.sound_events.insert = "SaurianSniperBullet"
--#endregion
--#region enemy_razorwing
tt = RT("enemy_razorwing", "enemy")

AC(tt, "cliff")

anchor_y = 0
image_y = 88
tt.cliff.hide_sprite_ids = {2}
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 100
tt.health_bar.offset = vec_2(0, ady(79))
tt.info.portrait = "kr2_info_portraits_enemies_0036"
tt.info.enc_icon = 36
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 1.387 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_razorwing"
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-20, 44, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 64)
tt.unit.marker_offset = vec_2(0, ady(1))
tt.unit.mod_offset = vec_2(0, ady(56))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_quetzal
tt = RT("enemy_quetzal", "enemy")

AC(tt, "timed_attacks")

anchor_y = 0
image_y = 114
tt.enemy.gold = 100
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, ady(97))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0037"
tt.info.enc_icon = 35
tt.main_script.update = scripts.enemy_quetzal.update
tt.motion.max_speed = 2.134 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_quetzal"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "quetzal_egg"
tt.timed_attacks.list[1].max_cooldown = 1.5
tt.timed_attacks.list[1].min_cooldown = 1.5
tt.timed_attacks.list[1].max_count = 8
tt.ui.click_rect = r(-20, 42, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 68)
tt.unit.marker_offset = vec_2(0, ady(1))
tt.unit.mod_offset = vec_2(0, ady(70))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region quetzal_egg
tt = RT("quetzal_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.18
tt.render.sprites[1].prefix = "quetzal_egg"
tt.render.sprites[1].loop = false
tt.spawner.count = 1
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_razorwing"
tt.spawner.allowed_subpaths = nil
tt.spawner.animation_start = "start"
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.keep_gold = true
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region enemy_redspine
tt = RT("enemy_redspine", "enemy")

AC(tt, "melee", "ranged", "water")

anchor_y = 0.22
image_y = 64
tt.enemy.gold = 40
tt.enemy.melee_slot = vec_2(32, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 1700
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0046"
tt.info.enc_icon = 46
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(20)
tt.motion.max_speed = 32
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet = "harpoon_redspine"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 40)}
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(8)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_redspine"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.unit.hit_offset = vec_2(0, 17)
tt.unit.mod_offset = vec_2(0, 18)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.water.health_bar_offset = vec_2(0, tt.health_bar.offset.y - 20)
tt.water.hit_offset = vec_2(0, 5)
tt.water.mod_offset = vec_2(0, 12)
tt.water.speed_factor = 1.5
--#endregion
--#region harpoon_redspine
tt = RT("harpoon_redspine", "arrow")
tt.render.sprites[1].name = "Redspine_spear"
tt.render.sprites[1].animated = false
tt.bullet.damage_min = 100
tt.bullet.damage_max = 130
tt.bullet.flight_time = fts(10)
tt.bullet.miss_decal = "Redspine_spear_decal"
tt.bullet.pop = nil
--#endregion
--#region enemy_bluegale
tt = RT("enemy_bluegale", "enemy")

AC(tt, "melee", "ranged", "timed_attacks", "water")

anchor_y = 0.20689655172413793
image_y = 116
tt.enemy.gold = 60
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(30, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 2400
tt.health.immune_to = DAMAGE_MAGICAL_GROUP
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 57)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0045"
tt.info.enc_icon = 43
tt.main_script.update = scripts.enemy_bluegale.update
tt.motion.max_speed = 25.6
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_bluegale"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].prefix = "bluegale_lightning"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-25, -10, 50, 60)
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 20)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.water.health_bar_offset = vec_2(0, tt.health_bar.offset.y - 30)
tt.water.hit_offset = vec_2(0, 5)
tt.water.mod_offset = vec_2(0, 12)
tt.water.speed_factor = 1.625
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 60
tt.melee.attacks[1].hit_time = fts(30)
tt.ranged.attacks[1].animation = "rangedAttack"
tt.ranged.attacks[1].bullet = "ray_bluegale"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(27, 70)}
tt.ranged.attacks[1].cooldown = 0
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(18)
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].animation = "castStorm"
tt.timed_attacks.list[1].bullet = "bluegale_clouds_aura"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].node_random_max = 30
tt.timed_attacks.list[1].node_random_min = 15
tt.timed_attacks.list[1].nodes_limit = 40
tt.timed_attacks.list[1].shoot_time = fts(14)
--#endregion
--#region ray_bluegale
tt = RT("ray_bluegale", "bullet")
tt.image_width = 120
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "ray_bluegale"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_min = 25
tt.bullet.damage_max = 45
tt.bullet.max_track_distance = 50
tt.bullet.hit_time = fts(5)
tt.sound_events.insert = "SaurianSavantAttack"
--#endregion
--#region bluegale_clouds_aura
tt = RT("bluegale_clouds_aura", "aura")

AC(tt, "sound_events")

tt.main_script.insert = scripts.bluegale_clouds.insert
tt.main_script.update = scripts.bluegale_clouds.update
tt.aura.duration = 10
tt.clouds_min_radius = 35
tt.clouds_max_radius = 55
tt.clouds_count = 6
tt.sound_events.insert = "RTBluegaleStormSummon"
--#endregion
--#region decal_bluegale_cloud_dark
tt = RT("decal_bluegale_cloud_dark", "decal_tween")

AC(tt, "ui")

tt.ui.click_rect = r(-58, -31, 116, 62)
tt.ui.z = 999
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_2(0, 3)}, {1, vec_2(0, -3)}, {2, vec_2(0, 3)}}
tt.tween.props[2].name = "offset"
tt.tween.props[2].loop = true
tt.render.sprites[1].name = "Bluegale_stormCloud_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
--#endregion
--#region decal_bluegale_cloud_bright
tt = RT("decal_bluegale_cloud_bright", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_2(0, 3)}, {1, vec_2(0, -3)}, {2, vec_2(0, 3)}}
tt.tween.props[2].name = "offset"
tt.tween.props[2].loop = true
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].name = "hidden"
tt.render.sprites[1].name = "Bluegale_stormCloud_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
--#endregion
--#region decal_bluegale_cloud_shadow
tt = RT("decal_bluegale_cloud_shadow", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.render.sprites[1].name = "atomicBomb_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS_SKY
--#endregion
--#region bluegale_heal_aura
tt = RT("bluegale_heal_aura", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_bluegale_heal"
tt.aura.vis_bans = F_FRIEND
tt.aura.vis_flags = F_MOD
tt.aura.cycle_time = 1
tt.aura.duration = 10
tt.aura.radius = 50
--#endregion
--#region bluegale_damage_aura
tt = RT("bluegale_damage_aura", "aura")
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_bluegale_damage"
tt.aura.vis_bans = F_ENEMY
tt.aura.vis_flags = F_MOD
tt.aura.cycle_time = 1
tt.aura.duration = 10
tt.aura.radius = 50

local mod_bluegale_damage = RT("mod_bluegale_damage", "modifier")

AC(mod_bluegale_damage, "dps")

mod_bluegale_damage.modifier.duration = 0.9
mod_bluegale_damage.dps.damage_min = 15
mod_bluegale_damage.dps.damage_max = 15
mod_bluegale_damage.dps.damage_type = DAMAGE_TRUE
mod_bluegale_damage.dps.damage_every = 1
mod_bluegale_damage.main_script.insert = scripts.mod_dps.insert
mod_bluegale_damage.main_script.update = scripts.mod_dps.update

local mod_bluegale_heal = RT("mod_bluegale_heal", "modifier")

AC(mod_bluegale_heal, "hps")

mod_bluegale_heal.modifier.duration = 0.9
mod_bluegale_heal.hps.heal_min = 15
mod_bluegale_heal.hps.heal_max = 15
mod_bluegale_heal.hps.heal_every = 1
mod_bluegale_heal.main_script.insert = scripts.mod_hps.insert
mod_bluegale_heal.main_script.update = scripts.mod_hps.update
--#endregion
--#region enemy_bloodshell
tt = RT("enemy_bloodshell", "enemy")

AC(tt, "melee", "water")

anchor_y = 0.26
image_y = 72
tt.enemy.gold = 75
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(34, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0.95
tt.health.hp_max = 3200
tt.health.immune_to = DAMAGE_EXPLOSION
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(76))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0048"
tt.info.enc_icon = 42
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 22.4
tt.render.sprites[1].anchor.y = 0.26
tt.render.sprites[1].prefix = "enemy_bloodshell"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.ui.click_rect = r(-30, -10, 60, 60)
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(0, ady(19))
tt.unit.mod_offset = vec_2(0, ady(47))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_DRILL
tt.water.health_bar_offset = vec_2(0, tt.health_bar.offset.y - 28)
tt.water.hit_offset = vec_2(0, 7)
tt.water.mod_offset = vec_2(0, ady(33))
tt.water.speed_factor = 1.43
tt.water.vis_bans = bor(F_BLOCK, F_SKELETON, F_DRILL)
--#endregion
--#region enemy_greenfin
tt = RT("enemy_greenfin", "enemy")

AC(tt, "melee", "water")

anchor_y = 0.185
image_y = 54
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(26, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0
tt.health.hp_max = 450
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(47))
tt.info.portrait = "kr2_info_portraits_enemies_0043"
tt.info.enc_icon = 44
tt.main_script.update = scripts.enemy_mixed_water.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 14
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "netAttack"
tt.melee.attacks[2].cooldown = 8
tt.melee.attacks[2].hit_time = fts(9)
tt.melee.attacks[2].mod = "mod_greenfin_net"
tt.melee.attacks[2].vis_flags = bor(F_STUN, F_NET)
tt.motion.max_speed = 48
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_greenfin"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.marker_offset = vec_2(0, ady(9))
tt.unit.mod_offset = vec_2(2, ady(23))
tt.water.health_bar_offset = vec_2(0, tt.health_bar.offset.y - 15)
tt.water.hit_offset = vec_2(0, 5)
tt.water.mod_offset = vec_2(2, ady(20))
tt.water.speed_factor = 1.2
--#endregion
--#region mod_greenfin_net
tt = RT("mod_greenfin_net", "modifier")

AC(tt, "render")

tt.main_script.insert = scripts.mod_stun.insert
tt.main_script.update = scripts.mod_stun.update
tt.main_script.remove = scripts.mod_stun.remove
tt.modifier.duration = 6
tt.modifier.duration_heroes = 1
tt.modifier.animation_phases = true
tt.render.sprites[1].prefix = "greenfin_net"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "start"
tt.render.sprites[1].size_anchors = {vec_2(0.5, 1), vec_2(0.5, 0.8409090909090909), vec_2(0.5, 0.8409090909090909)}
tt.render.sprites[1].anchor = vec_2(0.5, 1)
tt.modifier.custom_offsets = {}
tt.modifier.custom_offsets.default = vec_2(0, 26)
tt.modifier.custom_offsets.hero_alien = vec_2(0, 32)
tt.modifier.custom_offsets.hero_alric = vec_2(0, 31)
tt.modifier.custom_offsets.hero_beastmaster = vec_2(0, 32)
tt.modifier.custom_offsets.hero_voodoo_witch = vec_2(0, 32)
tt.modifier.custom_offsets.hero_crab = vec_2(0, 46)
tt.modifier.custom_offsets.hero_giant = vec_2(-2, 50)
tt.modifier.custom_offsets.hero_minotaur = vec_2(6, 46)
tt.modifier.custom_offsets.hero_mirage = vec_2(0, 31)
tt.modifier.custom_offsets.hero_monkey_god = vec_2(2, 37)
tt.modifier.custom_offsets.hero_pirate = vec_2(0, 30)
tt.modifier.custom_offsets.hero_priest = vec_2(0, 29)
tt.modifier.custom_offsets.hero_van_helsing = vec_2(0, 36)
tt.modifier.custom_offsets.hero_wizard = vec_2(0, 29)
tt.modifier.custom_offsets.soldier_death_rider = vec_2(0, 38)
tt.modifier.custom_offsets.soldier_pirate_anchor = vec_2(0, 34)
tt.modifier.custom_offsets.soldier_frankenstein = vec_2(0, 41)
--#endregion
--#region enemy_deviltide
tt = RT("enemy_deviltide", "enemy_greenfin")
tt.enemy.gold = 20
tt.health.armor = 0.5
tt.health.hp_max = 500
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0044"
tt.info.enc_icon = 47
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.motion.max_speed = 41.6
tt.render.sprites[1].prefix = "enemy_deviltide"
tt.sound_events.water_splash = "SpecialMermaid"
tt.water.speed_factor = 1.15
--#endregion
--#region enemy_deviltide_shark
tt = RT("enemy_deviltide_shark", "enemy")
anchor_y = 0.19230769230769232
image_y = 104
tt.enemy.gold = 20
tt.enemy.valid_terrains = TERRAIN_WATER
tt.health.armor = 0.5
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, 39)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = scripts.enemy_deviltide_shark.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0058"
tt.main_script.update = scripts.enemy_deviltide_shark.update
tt.motion.max_speed = 70.4
tt.payload = "enemy_deviltide"
tt.payload_time = fts(24)
tt.render.sprites[1].anchor = vec_2(0.44660194174757284, 0.19230769230769232)
tt.render.sprites[1].prefix = "enemy_deviltide_shark"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.deploy = "RTWaterExplosion"
tt.ui.click_rect = r(-30, -10, 60, 40)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_WATER)
--#endregion
--#region enemy_blacksurge
tt = RT("enemy_blacksurge", "enemy")

AC(tt, "melee", "timed_attacks", "water", "regen")

anchor_y = 0.31
image_y = 74
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(35, 0)
tt.enemy.valid_terrains = bor(TERRAIN_LAND, TERRAIN_WATER)
tt.health.armor = 0.7
tt.health.hp_max = 1200
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(72))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.hidden = {}
tt.hidden.cooldown = 20
tt.hidden.duration = 12
tt.hidden.nodeslimit = 20
tt.hidden.trigger_health_factor = 0.3
tt.hidden.vis_bans = bor(F_BLOCK, F_STUN, F_BLOOD, F_TWISTER, F_LETHAL)
tt.hidden.sprite_suffix = "_hidden"
tt.hidden.ts = 0
tt.info.portrait = "kr2_info_portraits_enemies_0047"
tt.info.enc_icon = 45
tt.main_script.update = scripts.enemy_blacksurge.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(28)
tt.motion.max_speed = 16
tt.regen.cooldown = 0.1
tt.regen.duration = 3
tt.regen.health = 20
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_blacksurge"
tt.sound_events.death_water = "RTWaterDead"
tt.sound_events.water_splash = "SpecialMermaid"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "curse"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_count = 2
tt.timed_attacks.list[1].mod = "mod_blacksurge"
tt.timed_attacks.list[1].range = 200
tt.timed_attacks.list[1].shoot_time = fts(26)
tt.timed_attacks.list[1].sound = "RTBlacksurgeHoldTower"
tt.ui.click_rect = r(-30, -10, 60, 55)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.marker_offset = vec_2(0, ady(23))
tt.unit.mod_offset = vec_2(0, ady(42))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.water.health_bar_offset = vec_2(0, tt.health_bar.offset.y - 8)
tt.water.hit_offset = vec_2(0, 15)
tt.water.mod_offset = vec_2(0, ady(37))
tt.water.speed_factor = 2

local mod_blacksurge = RT("mod_blacksurge", "modifier")

AC(mod_blacksurge, "render")

mod_blacksurge.modifier.duration = 7
mod_blacksurge.main_script.update = scripts.mod_tower_block.update
mod_blacksurge.render.sprites[1].prefix = "blacksurge_curse"
mod_blacksurge.render.sprites[1].name = "start"
mod_blacksurge.render.sprites[1].anchor.y = 0.24
mod_blacksurge.render.sprites[1].draw_order = 10
--#endregion
--#region enemy_bat
tt = RT("enemy_bat", "enemy")

AC(tt, "moon", "auras")

anchor_y = 0
image_y = 108
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(0, 0)
tt.health.hp_max = 75
tt.health_bar.offset = vec_2(0, ady(90))
tt.info.portrait = "kr2_info_portraits_enemies_0052"
tt.info.enc_icon = 49
tt.main_script.update = scripts.enemy_passive.update
tt.moon.speed_factor = 1.5
tt.motion.max_speed = 2.56 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_bat"
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-20, 40, 40, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 68)
tt.unit.marker_offset = vec_2(0, ady(0))
tt.unit.mod_offset = vec_2(0, ady(68))
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_EAT)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_ghost
tt = RT("enemy_ghost", "enemy")

AC(tt, "auras")

anchor_y = 0.08333333333333333
image_y = 48
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "ghost_sound_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(24, 0)
tt.health.armor = 0
tt.health.hp_max = 100
tt.health.immune_to = DAMAGE_PHYSICAL_GROUP
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 37)
tt.info.portrait = "kr2_info_portraits_enemies_0063"
tt.info.enc_icon = 52
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 0.967 * FPS
tt.render.sprites[1].prefix = "enemy_ghost"
tt.render.sprites[1].anchor.y = anchor_y
tt.unit.blood_color = BLOOD_NONE
tt.unit.show_blood_pool = false
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 19)
tt.unit.marker_offset = vec_2(0, ady(0))
tt.unit.mod_offset = vec_2(0, 19)
tt.sound_events.death = nil
tt.sound_events.insert = "HWGhosts"
tt.vis.flags = bor(tt.vis.flags, F_FLYING_FAKE)
tt.vis.bans = bor(F_SKELETON, F_BLOOD, F_DRILL, F_POISON, F_STUN, F_BLOCK, F_POLYMORPH)
--#endregion
--#region ghost_sound_aura
tt = RT("ghost_sound_aura", "aura")
tt.loop_delay = fts(70)
tt.sound_name = "HWGhosts"
tt.main_script.update = scripts.loop_sound_aura.update
--#endregion
--#region enemy_ghoul
tt = RT("enemy_ghoul", "enemy")

AC(tt, "melee", "moon", "auras")

anchor_y = 0.07894736842105263
image_y = 60
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "moon_enemy_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(20, 0)
tt.cannibalize = {}
tt.cannibalize.extra_hp = 50
tt.cannibalize.hps = 3 * FPS
tt.cannibalize.max_hp = 600
tt.health.armor = 0.2
tt.health.hp_max = 400
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 33)
tt.info.portrait = "kr2_info_portraits_enemies_0049"
tt.info.enc_icon = 56
tt.main_script.update = scripts.enemy_cannibal.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].sound = "HWZombieAmbient"
tt.melee.attacks[1].pop = {"pop_sok", "pop_kapow"}
tt.moon.damage_factor = 1.5
tt.motion.max_speed = 1.92 * FPS
tt.render.sprites[1].prefix = "enemy_ghoul"
tt.render.sprites[1].anchor.y = anchor_y
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.sound_events.insert = "HWZombieAmbient"
tt.sound_events.cannibalize = "CanibalEating"
--#endregion
--#region enemy_phantom_warrior
tt = RT("enemy_phantom_warrior", "enemy")

AC(tt, "melee", "auras")

image_y = 88
anchor_y = 10 / image_y
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "phantom_warrior_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 90
tt.enemy.melee_slot = vec_2(27, 0)
tt.health.armor = 0
tt.health.hp_max = 1000
tt.health.immune_to = DAMAGE_PHYSICAL_GROUP
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 56)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0062"
tt.info.enc_icon = 51
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.747 * FPS
tt.render.sprites[1].prefix = "enemy_phantom_warrior"
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.death = nil
tt.ui.click_rect = r(-20, -5, 40, 55)
tt.unit.blood_color = BLOOD_NONE
tt.unit.show_blood_pool = false
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 21)
tt.unit.mod_offset = vec_2(0, 21)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER, F_FLYING_FAKE)
tt.vis.bans = bor(F_SKELETON, F_BLOOD, F_DRILL, F_POISON)
--#endregion
--#region phantom_warrior_aura
tt = RT("phantom_warrior_aura", "aura")
tt.aura.cycle_time = fts(3)
tt.aura.duration = -1
tt.aura.radius = 128
tt.aura.vis_bans = bor(F_ENEMY, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.aura.damage_min = 3
tt.aura.damage_max = 3
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.hero_damage_factor = 0.3333333333333333
tt.main_script.update = scripts.phantom_warrior_aura.update
--#endregion
--#region enemy_elvira
tt = RT("enemy_elvira", "enemy")

AC(tt, "melee")

anchor_y = 0.1
image_y = 50
tt.enemy.gold = 16
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 1200
tt.health.magic_armor = 0.95
tt.health_bar.offset = vec_2(0, 43)
tt.info.portrait = "kr2_info_portraits_enemies_0066"
tt.info.enc_icon = 58
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].cooldown = 8
tt.melee.attacks[2].damage_max = 0
tt.melee.attacks[2].damage_min = 0
tt.melee.attacks[2].hit_time = fts(3)
tt.melee.attacks[2].mod = "mod_elvira_lifesteal"
tt.melee.attacks[2].animation = "lifesteal"
tt.melee.attacks[2].health_trigger_factor = 0.7
tt.melee.attacks[2].fn_can = scripts.enemy_elvira.can_lifesteal
tt.motion.max_speed = 0.9 * FPS
tt.render.sprites[1].prefix = "enemy_elvira"
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.death = nil
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.hide_after_death = true
--#endregion
--#region elvira_bat
tt = RT("elvira_bat", "decal_scripted")

AC(tt, "nav_path", "motion", "spawner")

anchor_y = 0.1
image_y = 50
tt.main_script.update = scripts.elvira_bat.update
tt.motion.max_speed = 2 * FPS
tt.render.sprites[1].prefix = "elvira_bat"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.payload = "enemy_elvira"
tt.health_factor = 1
--#endregion
--#region mod_elvira_lifesteal
tt = RT("mod_elvira_lifesteal", "modifier")

AC(tt, "moon")

tt.heal_hp = 360
tt.damage = 150
tt.main_script.insert = scripts.mod_elvira_lifesteal.insert
tt.moon.heal_hp_factor = 2
tt.moon.damage_factor = 1.5
--#endregion
--#region enemy_headless_horseman
tt = RT("enemy_headless_horseman", "enemy")

AC(tt, "melee", "ranged", "lifespan", "idle_flip", "auras")

image_y = 104
anchor_y = 12 / image_y
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "headless_horseman_spawner_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 200
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = vec_2(36, 0)
tt.health.armor = 0
tt.health.hp_max = 500
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, 65)
tt.idle_flip.cooldown = 3
tt.idle_flip.last_dir = -1
tt.idle_flip.walk_dist = 30
tt.info.portrait = "kr2_info_portraits_enemies_0064"
tt.lifespan.duration = 15
tt.lifespan.animation_in = "rise"
tt.lifespan.animation_out = "death"
tt.main_script.update = scripts.enemy_headless_horseman.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 3.74 * FPS
tt.ranged.attacks[1].bullet = "headless_horseman_pumpkin"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 65)}
tt.ranged.attacks[1].cooldown = 4
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].max_range = 190
tt.ranged.attacks[1].shoot_time = fts(28)
tt.render.sprites[1].prefix = "enemy_headless_horseman"
tt.render.sprites[1].anchor.y = anchor_y
tt.sound_events.insert = {"HWHeadlessHorsemanLaugh", "HWHeadlessHorsemanEntry"}
tt.sound_events.death = nil
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 35)
tt.unit.mod_offset = vec_2(0, 35)
tt.unit.hide_after_death = true
tt.vis.flags = bor(F_ENEMY)
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region headless_horseman_pumpkin
tt = RT("headless_horseman_pumpkin", "bomb")
tt.bullet.damage_min = 50
tt.bullet.damage_max = 70
tt.bullet.damage_radius = 40
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time = fts(20)
tt.render.sprites[1].name = "HalloweenRider_bomb"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.sound_events.insert = nil
--#endregion
--#region headless_horseman_spawner_aura
tt = RT("headless_horseman_spawner_aura", "aura")

AC(tt, "spawner")

tt.main_script.update = scripts.headless_horseman_spawner_aura.update
tt.spawner.cycle_time = 10
--#endregion
--#region enemy_gunboat
tt = RT("enemy_gunboat", "enemy")

AC(tt, "attacks")

anchor_y = 0.20666666666666667
image_y = 150
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animations = {"fire_start", "fire_loop", "fire_end"}
tt.attacks.list[1].bullet = "bomb_gunboat"
tt.attacks.list[1].bullet_start_offset = vec_2(21, 73)
tt.attacks.list[1].cooldown = 1
tt.attacks.list[1].max_range = 5000
tt.attacks.list[1].min_range = 0
tt.attacks.list[1].shoot_time = fts(1)
tt.attacks.list[1].vis_bans = bor(F_ENEMY, F_BOSS, F_FLYING)
tt.attacks.list[1].vis_flags = F_RANGED
tt.enemy.gold = 150
tt.enemy.lives_cost = 0
tt.health.armor = 0.2
tt.health.dead_lifetime = 3
tt.health.hp_max = 1000
tt.health_bar.offset = vec_2(7, 85)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.fn = scripts.enemy_gunboat.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0059"
tt.main_script.update = scripts.enemy_gunboat.update
tt.motion.max_speed = 0.854 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "enemy_gunboat_l1"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].prefix = "enemy_gunboat_l2"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].anchor.y = anchor_y
tt.render.sprites[3].prefix = "enemy_gunboat_l3"
tt.ui.click_rect = r(-40, 0, 80, 60)
tt.unit.blood_color = BLOOD_NONE
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.mod_offset = vec_2(0, 28)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_STUN, F_BLOCK, F_DRILL, F_POISON, F_TWISTER, F_SKELETON, F_EAT)
tt.sound_events.death_water = "RTGunboatDeath"
--#endregion
--#region bomb_gunboat
tt = RT("bomb_gunboat", "bullet")
tt.bullet.damage_max = 120
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 51.2
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.g = -0.8 / (fts(1) * fts(1))
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_fireball_explosion"
tt.bullet.particles_name = "ps_bomb_gunboat"
tt.bullet.pop = {"pop_kboom"}
tt.bullet.align_with_trajectory = true
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time_base = fts(50)
tt.bullet.flight_time_factor = fts(0.04)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "waterCannon_proy"
tt.sound_events.insert = "SpecialVolcanoLavaShoot"
tt.sound_events.hit = "BombExplosionSound"
--#endregion
--#region enemy_gnoll_reaver
tt = RT("enemy_gnoll_reaver", "enemy")

AC(tt, "melee")

image_y = 54
anchor_y = 9 / image_y
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.armor = 0
tt.health.hp_max = 50
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(38))
tt.info.enc_icon = 1
tt.info.portrait = "kr3_info_portraits_enemies_0001"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {6, 6, 7}
tt.melee.attacks[1].damage_min = {3, 3, 4}
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.245 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "gnoll_reaver"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(8))
tt.unit.mod_offset = vec_2(0, ady(20))
--#endregion
--#region enemy_gnoll_burner
tt = RT("enemy_gnoll_burner", "enemy")

AC(tt, "melee", "ranged")

tt.info.enc_icon = 2
tt.info.portrait = "kr3_info_portraits_enemies_0003"
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(27, 0)
tt.health.hp_max = 50
tt.health_bar.offset = vec_2(0, 38)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {4, 4, 10}
tt.melee.attacks[1].damage_min = {2, 2, 5}
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.245 * FPS
tt.ranged.attacks[1].bullet = "torch_gnoll_burner"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 36)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_CUSTOM, F_BURN)
tt.render.sprites[1].anchor = vec_2(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "gnoll_burner"
tt.sound_events.death = "DeathGoblin"
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.size = UNIT_SIZE_SMALL
--#endregion
--#region enemy_gnoll_gnawer
tt = RT("enemy_gnoll_gnawer", "enemy")

AC(tt, "melee", "auras")

tt.info.enc_icon = 3
tt.info.portrait = "kr3_info_portraits_enemies_0002"
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_gnoll_gnawer"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.armor = {0.4, 0.4, 0.6}
tt.health.hp_max = {200, 250, 300, 300}
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.25)
tt.render.sprites[1].prefix = "gnoll_gnawer"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = vec_2(0, 22)
tt.unit.mod_offset = vec_2(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
--#endregion
--#region enemy_gnoll_blighter
tt = RT("enemy_gnoll_blighter", "enemy")

AC(tt, "melee", "ranged", "timed_attacks")

tt.info.portrait = "kr3_info_portraits_enemies_0016"
tt.info.enc_icon = 4
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(30, 0)
tt.health.hp_max = 700
tt.health.magic_armor = {0.75, 0.75, 0.85}
tt.health_bar.offset = vec_2(0, 42)
tt.main_script.update = scripts.enemy_gnoll_blighter.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(23)
tt.motion.max_speed = 0.664 * FPS
tt.ranged.attacks[1].animation = "energy"
tt.ranged.attacks[1].bullet = "bullet_gnoll_blighter"
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].shoot_time = fts(20)
tt.ranged.attacks[1].cooldown = 1 + fts(23) + fts(6)
tt.ranged.attacks[1].max_range = 160
tt.ranged.attacks[1].min_range = 30
tt.ranged.attacks[1].bullet_start_offset = {vec_2(14, 0)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].vis_bans = F_FLYING
tt.ranged.attacks[1].requires_magic = true
tt.render.sprites[1].anchor = vec_2(0.5, 0.1891891891891892)
tt.render.sprites[1].prefix = "gnoll_blighter"
tt.sound_events.death = "DeathBig"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].mod = "mod_gnoll_blighter"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].animation = "attackPlants"
tt.timed_attacks.list[1].range = 175
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 16)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region enemy_hyena
tt = RT("enemy_hyena", "enemy")

AC(tt, "melee")

tt.info.enc_icon = 7
tt.info.portrait = "kr3_info_portraits_enemies_0005"
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(10, 0)
tt.health.hp_max = 40
tt.health.magic_armor = {0.3, 0.3, 0.7}
tt.health_bar.offset = vec_2(0, 35)
tt.main_script.update = scripts.enemy_hyena.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].hit_time = fts(22)
tt.motion.max_speed = 2.158 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.3382352941176471)
tt.render.sprites[1].prefix = "hyena"
tt.render.sprites[1].angles.run = {"runningRightLeft", "runningUp", "runningDown"}
tt.render.sprites[1].angles_stickiness.run = 10
tt.sound_events.death = "DeathGoblin"
tt.sound_events.insert = "ElvesCreepHyena"
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 15)
tt.coward_duration = 1.2
tt.coward_speed_factor = 1.5
--#endregion
--#region enemy_ettin
tt = RT("enemy_ettin", "enemy")

AC(tt, "melee", "auras", "endless")

tt.info.portrait = "kr3_info_portraits_enemies_0011"
tt.info.enc_icon = 5
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ettin_regen"
tt.auras.list[1].cooldown = 0
tt.endless.factor_map = {{"enemy_ettin.basicCooldownTime", "insane.cooldown_min", true}, {"enemy_ettin.basicCooldownTime", "insane.cooldown_max", true}}
tt.enemy.gold = 70
tt.enemy.lives_cost = {2, 2, 4}
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.hp_max = 900
tt.health_bar.offset = vec_2(0, 72)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_ettin.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = {95, 95, 105}
tt.melee.attacks[1].damage_min = {85, 85, 85}
tt.melee.attacks[1].hit_time = fts(23)
tt.motion.max_speed = 0.581 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1111111111111111)
tt.render.sprites[1].prefix = "ettin"
tt.sound_events.death = "DeathBig"
tt.unit.hit_offset = vec_2(0, 32)
tt.unit.mod_offset = vec_2(0, 30)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.insane = {}
tt.insane.cooldown_max = 22
tt.insane.cooldown_min = 12
tt.insane.damage_max = 10
tt.insane.damage_min = 5
tt.insane.damage_type = DAMAGE_TRUE
tt.insane.stun_duration = 2
tt.insane.hit_time = fts(28)
tt.ui.click_rect = r(-25, -5, 50, 60)
--#endregion
--#region enemy_perython
tt = RT("enemy_perython", "enemy")
tt.info.enc_icon = 6
tt.info.portrait = "kr3_info_portraits_enemies_0006"
tt.enemy.gold = 18
tt.health.hp_max = {90, 120, 120, 140}
tt.health_bar.offset = vec_2(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = {1.494 * FPS, 1.494 * FPS, 1.992 * FPS}
tt.render.sprites[1].anchor = vec_2(0.5, 0.058823529411764705)
tt.render.sprites[1].prefix = "perython"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.ui.click_rect = r(-15, 50, 30, 25)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 65)
tt.unit.mod_offset = vec_2(0, 60)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_perython_gnoll_gnawer
tt = RT("enemy_perython_gnoll_gnawer", "enemy_perython")

AC(tt, "death_spawns")

tt.info.i18n_key = "ENEMY_PERYTHON"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "gnoll_gnawer_flying"
tt.render.sprites[3].anchor = vec_2(0.5, 0.25)
tt.death_spawns.name = "enemy_gnoll_gnawer"
tt.death_spawns.concurrent_with_death = false
tt.main_script.update = scripts.enemy_perython_carrier.update
tt.spawn_trigger_range = 100
--#endregion
--#region enemy_twilight_elf_harasser
tt = RT("enemy_twilight_elf_harasser", "enemy")

AC(tt, "melee", "ranged", "dodge")

tt.info.enc_icon = 8
tt.info.portrait = "kr3_info_portraits_enemies_0018"
tt.dodge.ranged = false
tt.dodge.cooldown = 7
tt.dodge.chance = 1
tt.dodge.max_nodes = -15
tt.dodge.min_nodes = -24
tt.dodge.nodeslimit = 15
tt.enemy.gold = 25
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.armor = {0.3, 0.45, 0.6}
tt.health.hp_max = 240
tt.health_bar.offset = vec_2(0, 34)
tt.health.armor_resilience = 0.6
tt.info.enc_icon = 8
tt.main_script.update = scripts.enemy_twilight_elf_harasser.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {30, 30, 35}
tt.melee.attacks[1].damage_min = {20, 20, 25}
tt.melee.attacks[1].hit_time = fts(24)
tt.motion.max_speed = 1.245 * FPS
tt.ranged.attacks[1].animations = {"shoot_start", "shoot_loop", "shoot_end"}
tt.ranged.attacks[1].bullet = "arrow_twilight_elf_harasser"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(0, 27)}
tt.ranged.attacks[1].cooldown = 10
tt.ranged.attacks[1].loops = 4
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 60
tt.ranged.attacks[1].repeat_cooldown = fts(20)
tt.ranged.attacks[1].shoot_time = fts(3)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_CUSTOM)
tt.render.sprites[1].anchor = vec_2(0.5, 0.1891891891891892)
tt.render.sprites[1].prefix = "harraser"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 15)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.shadow_shot = CC("bullet_attack")
tt.shadow_shot.bullet = "arrow_twilight_elf_harasser_shadowshot"
tt.shadow_shot.animation = "shadow_shot"
tt.shadow_shot.shoot_time = fts(14)
tt.shadow_shot.bullet_start_offset = {vec_2(0, 27)}
tt.shadow_shot.min_range = 0
tt.shadow_shot.max_range = 200
--#endregion
--#region enemy_catapult
tt = RT("enemy_catapult", "enemy")

AC(tt, "ranged")

tt.duration = nil
tt.enemy.gold = 100
tt.enemy.melee_slot = vec_2(40, -10)
tt.enemy.remove_at_goal_line = false
tt.health.hp_max = 200
tt.health.dead_lifetime = 3
tt.health_bar.offset = vec_2(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_GNOLL_CATAPULT"
tt.info.portrait = "kr3_info_portraits_enemies_0033"
tt.main_script.update = scripts.enemy_catapult.update
tt.motion.max_speed = 37.35
tt.phase_1_ni = nil
tt.ranged.attacks[1].bullet = "rock_enemy_catapult"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(30, 90)}
tt.ranged.attacks[1].cooldown = 3 + fts(80)
tt.ranged.attacks[1].max_x = 800
tt.ranged.attacks[1].min_x = 150
tt.ranged.attacks[1].shoot_time = fts(33)
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor.y = 0.14285714285714285
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].prefix = "catapult"
tt.ui.click_rect = r(-35, -10, 70, 60)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.mod_offset = vec_2(0, 34)
tt.unit.hit_offset = vec_2(0, 34)
tt.unit.marker_offset = vec_2(0, -5)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_STUN, F_TELEPORT, F_DRILL, F_POISON, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
--#endregion
--#region rock_enemy_catapult
tt = RT("rock_enemy_catapult", "bomb")
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 200
tt.bullet.damage_min = 150
tt.bullet.damage_radius = 50
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time_base = fts(60)
tt.bullet.flight_time_factor = fts(0.04)
tt.bullet.hit_decal = "decal_rock_crater"
tt.bullet.hit_fx = "fx_rock_explosion"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "catapult_proy"
tt.sound_events.insert = "TowerStoneDruidBoulderThrow"
--#endregion
--#region enemy_bandersnatch
tt = RT("enemy_bandersnatch", "enemy")

AC(tt, "melee", "timed_attacks")

tt.info.enc_icon = 16
tt.info.portrait = "kr3_info_portraits_enemies_0009"
tt.enemy.gold = 300
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(42, 0)
tt.health.hp_max = 3000
tt.health_bar.offset = vec_2(0, 63)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_radius = 100
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].fn_filter = scripts.enemy_bandersnatch.fn_filter_melee
tt.timed_attacks.list[1] = CC("aura_attack")
tt.timed_attacks.list[1].animation = "spineAttack"
tt.timed_attacks.list[1].bullet = "aura_bandersnatch_spines"
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].shoot_time = fts(31)
tt.main_script.update = scripts.enemy_bandersnatch.update
tt.motion.min_speed = 2.075 * FPS
tt.motion.max_speed = 2.075 * FPS
tt.motion.speed_limit = {3.5 * FPS, 3.5 * FPS, 4.5 * FPS}
tt.motion.accel = 0.2 * FPS
tt.motion.invulnerable = true
tt.render.sprites[1].anchor = vec_2(0.5, 0.25862068965517243)
tt.render.sprites[1].prefix = "bandersnatch"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, -2, 40, 52)
tt.unit.hit_offset = vec_2(0, 19)
tt.unit.mod_offset = vec_2(0, 24)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans_rolling = bor(F_SKELETON, F_STUN, F_FREEZE)
tt.vis.bans_standing = bor(F_SKELETON)
tt.vis.bans = tt.vis.bans_standing
--#endregion
--#region enemy_boomshrooms
tt = RT("enemy_boomshrooms", "enemy")

AC(tt, "death_spawns")

tt.info.enc_icon = 32
tt.info.portrait = "kr3_info_portraits_enemies_0014"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "aura_boomshrooms_death"
tt.unit.explode_when_silenced_death = true
tt.enemy.gold = 6
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 75
tt.health.poison_armor = 0.5
tt.health_bar.offset = vec_2(0, 25)
tt.main_script.update = scripts.enemy_boomshrooms.update
tt.motion.max_speed = 1.66 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1956521739130435)
tt.render.sprites[1].prefix = "fungusRider_small"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 13)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_munchshrooms
tt = RT("enemy_munchshrooms", "enemy")

AC(tt, "melee", "death_spawns")

tt.info.enc_icon = 31
tt.info.portrait = "kr3_info_portraits_enemies_0013"
tt.death_spawns.name = "enemy_boomshrooms"
tt.death_spawns.delay = 0.93
tt.death_spawns.quantity = {2, 2, 3}
tt.death_spawns.spread_nodes = 2
tt.enemy.gold = 12
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.hp_max = 200
tt.health.poison_armor = 0.5
tt.health_bar.offset = vec_2(0, 40)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {15, 15, 30}
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(21)
tt.motion.max_speed = 1.245 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.17142857142857143)
tt.render.sprites[1].prefix = "fungusRider_medium"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_shroom_breeder
tt = RT("enemy_shroom_breeder", "enemy")

AC(tt, "melee", "death_spawns", "timed_attacks")

tt.info.enc_icon = 15
tt.info.portrait = "kr3_info_portraits_enemies_0012"
tt.death_spawns.name = "enemy_munchshrooms"
tt.death_spawns.delay = 0.5
tt.death_spawns.quantity = {2, 2, 3}
tt.death_spawns.spread_nodes = 2
tt.enemy.gold = 25
tt.enemy.lives_cost = 4
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 600
tt.health.poison_armor = 0.5
tt.health_bar.offset = vec_2(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_shroom_breeder.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = fts(25)
tt.motion.max_speed = 0.83 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.125)
tt.render.sprites[1].prefix = "fungusRider"
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].allowed_templates = {"enemy_boomshrooms"}
tt.timed_attacks.list[1].spawn_name = "enemy_munchshrooms"
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].cast_time = fts(19)
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 22)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region enemy_gloomy
tt = RT("enemy_gloomy", "enemy")

AC(tt, "melee", "timed_attacks", "count_group")

tt.info.enc_icon = 17
tt.info.portrait = "kr3_info_portraits_enemies_0015"
tt.count_group.name = "enemy_gloomy"
tt.count_group.type = COUNT_GROUP_CONCURRENT
tt.enemy.gold = 5
tt.enemy.melee_slot = vec_2(18, 0)
tt.health.hp_max = {30, 35, 40, 45}
tt.health_bar.offset = vec_2(0, 67)
tt.main_script.update = scripts.enemy_gloomy.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].hit_time = fts(19)
tt.motion.max_speed = 1.245 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.04054054054054054)
tt.render.sprites[1].prefix = "gloomy"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = vec_2(0, 0)
tt.sound_events.death = "DeathPuff"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].spawn_name = "enemy_gloomy"
tt.timed_attacks.list[1].animation = "castClone"
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].cooldown_after = 5
tt.timed_attacks.list[1].cooldown = 3
tt.timed_attacks.list[1].count_group_max = 100
tt.timed_attacks.list[1].nodes_limit = 30
tt.timed_attacks.list[1].max_clones = {2, 2, 3}
tt.ui.click_rect = r(-12, 24, 24, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 32)
tt.unit.mod_offset = vec_2(0, 37)
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
--#endregion
--#region enemy_redcap
tt = RT("enemy_redcap", "enemy")

AC(tt, "melee")

tt.info.enc_icon = 14
tt.info.portrait = "kr3_info_portraits_enemies_0021"
tt.enemy.gold = 12
tt.enemy.melee_slot = vec_2(27, 0)
tt.health.hp_max = 120
tt.health_bar.offset = vec_2(0, 28)
tt.melee.attacks[1].damage_max = {25, 25, 35}
tt.melee.attacks[1].damage_min = {15, 15, 25}
tt.melee.attacks[1].hit_time = fts(23)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "special"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) == 0
end
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].hit_offset = vec_2(24, 10)
tt.melee.attacks[2].instakill = true
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].side_effect = scripts.redcap_heal_side_effect
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].chance = 0.1
tt.melee.attacks[3].damage_max = 100
tt.melee.attacks[3].damage_min = 100
tt.melee.attacks[3].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) ~= 0
end
tt.melee.attacks[3].instakill = nil
tt.melee.cooldown = 1.2
tt.motion.max_speed = 1.8 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.20833333333333334)
tt.render.sprites[1].prefix = "redcap"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 10)
tt.unit.mod_offset = vec_2(0, 12)
--#endregion
--#region enemy_satyr_cutthroat
tt = RT("enemy_satyr_cutthroat", "enemy")

AC(tt, "melee", "ranged")

tt.info.enc_icon = 12
tt.info.portrait = "kr3_info_portraits_enemies_0022"
tt.enemy.gold = 15
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 150
tt.health_bar.offset = vec_2(0, 35)
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].hit_time = fts(20)
tt.motion.max_speed = 1.826 * FPS
tt.ranged.attacks[1].animations = {"shoot_start", "shoot_loop", "shoot_end"}
tt.ranged.attacks[1].bullet = "knife_satyr"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(13, 15), vec_2(13, 15)}
tt.ranged.attacks[1].cooldown = {3, 3, 2.5}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].max_range = 90
tt.ranged.attacks[1].min_range = 10
tt.ranged.attacks[1].shoot_times = {fts(5), fts(15)}
tt.render.sprites[1].anchor = vec_2(0.5, 0.125)
tt.render.sprites[1].prefix = "satyr"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 14)
--#endregion
--#region enemy_satyr_hoplite
tt = RT("enemy_satyr_hoplite", "enemy")

AC(tt, "melee", "timed_attacks")

tt.info.enc_icon = 13
tt.info.portrait = "kr3_info_portraits_enemies_0023"
tt.enemy.gold = 60
tt.enemy.melee_slot = vec_2(32, 0)
tt.health.armor = {0.5, 0.5, 0.75}
tt.health.hp_max = 700
tt.health_bar.offset = vec_2(0, 49)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_satyr_hoplite.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 25
tt.melee.attacks[1].hit_time = fts(24)
tt.motion.max_speed = 1.245 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1167)
tt.render.sprites[1].prefix = "satyrHoplite"
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].entity = "satyr_hoplite_spawner"
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].spawn_time = fts(16)
tt.timed_attacks.list[1].cooldown = {8, 8, 6}
tt.timed_attacks.list[1].count_group_name = "enemy_satyr_cutthroat_from_hoplite"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = 12
tt.timed_attacks.list[1].nodes_limit = 60
tt.timed_attacks.list[1].sound = "ElvesCreepHoplite"
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-25, 0, 50, 60)
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 20)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region satyr_hoplite_spawner
tt = RT("satyr_hoplite_spawner")

AC(tt, "pos", "spawner", "main_script")

tt.main_script.update = scripts.enemies_spawner.update
tt.spawner.count = 3
tt.spawner.random_cycle = {0, 1}
tt.spawner.entity = "enemy_satyr_cutthroat"
tt.spawner.random_node_offset_range = {-12, -7}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "raise"
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
--#endregion
--#region enemy_twilight_avenger
tt = RT("enemy_twilight_avenger", "enemy")

AC(tt, "melee", "timed_attacks")

tt.info.enc_icon = 9
tt.info.portrait = "kr3_info_portraits_enemies_0029"
tt.enemy.gold = 30
tt.enemy.melee_slot = vec_2(30, 0)
tt.health.armor = 0.5
tt.health.hp_max = 1100
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor_resilience = 0.4
tt.main_script.update = scripts.enemy_twilight_avenger.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {75, 75, 125}
tt.melee.attacks[1].damage_min = {50, 50, 100}
tt.melee.attacks[1].hit_time = fts(24)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].cast_time = fts(16)
tt.timed_attacks.list[1].cooldown = 7
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS, F_DARK_ELF)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_ENEMY)
tt.timed_attacks.list[1].max_range = 125
tt.timed_attacks.list[1].mod = "mod_twilight_avenger_last_service"
tt.timed_attacks.list[1].sound = "ElvesCreepAvenger"
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.15)
tt.render.sprites[1].prefix = "twilight_avenger"
tt.sound_events.death = "DeathHuman"
tt.shield_extra_armor = 0.4
tt.shield_off_armor = tt.health.armor
tt.shield_on_armor = tt.health.armor + tt.shield_extra_armor
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = vec_2(0, 22)
tt.unit.mod_offset = vec_2(0, 23)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region mod_twilight_avenger_last_service
tt = RT("mod_twilight_avenger_last_service", "modifier")

AC(tt, "render")

tt.modifier.duration = -1
tt.render.sprites[1].prefix = "mod_twilight_avenger_last_service"
tt.render.sprites[1].size_names = {"small", "big", "big"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 10
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_twilight_avenger_last_service.remove
tt.explode_fx = "fx_twilight_avenger_explosion"
tt.explode_range = 60
tt.explode_damage = 80
tt.explode_vis_bans = bor(F_DARK_ELF, F_BOSS)
tt.explode_vis_flags = F_RANGED
tt.explode_excluded_templates = {"hero_regson"}
--#endregion
--#region enemy_twilight_scourger
tt = RT("enemy_twilight_scourger", "enemy")

AC(tt, "melee", "death_spawns", "timed_attacks")

tt.info.enc_icon = 11
tt.info.portrait = "kr3_info_portraits_enemies_0024"
tt.death_spawns.name = "enemy_twilight_scourger_banshee"
tt.death_spawns.delay = fts(5)
tt.death_spawns.quantity = 1
tt.enemy.gold = 40
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 500
tt.health.magic_armor = {0.8, 0.8, 0.9}
tt.health_bar.offset = vec_2(0, 37)
tt.health.dead_lifetime = 2.5
tt.main_script.update = scripts.enemy_twilight_scourger.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 35
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].hit_time = fts(23)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].event_times = {fts(8), fts(14), fts(16), fts(24)}
tt.timed_attacks.list[1].cooldown = {7, 7, 5}
tt.timed_attacks.list[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1].damage_min = 5
tt.timed_attacks.list[1].damage_max = 10
tt.timed_attacks.list[1].vis_bans = bor(F_BOSS)
tt.timed_attacks.list[1].excluded_templates = {"enemy_twilight_scourger", "enemy_twilight_scourger_banshee"}
tt.timed_attacks.list[1].max_range = 75
tt.timed_attacks.list[1].max_cast_range = 50
tt.timed_attacks.list[1].mod = "mod_twilight_scourger_lash"
tt.timed_attacks.list[1].sound = "ElvesCreepScreecher"
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].loops = 3
tt.timed_attacks.list[1].cast_fx = "fx_twilight_scourger_lash"
tt.timed_attacks.list[1].cast_decal = "decal_twilight_scourger_lash"
tt.motion.max_speed = 0.83 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.14705882352941177)
tt.render.sprites[1].prefix = "scourger"
tt.sound_events.death = "ElvesScourgerDeath"
tt.unit.hit_offset = vec_2(0, 20)
tt.unit.mod_offset = vec_2(0, 18)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
--#endregion
--#region enemy_twilight_scourger_banshee
tt = RT("enemy_twilight_scourger_banshee", "enemy")

AC(tt, "mod_attack", "tween")

tt.info.portrait = "kr3_info_portraits_enemies_0025"
tt.mod_attack.cooldown = 1
tt.mod_attack.mod = "mod_twilight_scourger_banshee"
tt.mod_attack.max_range = 180
tt.mod_attack.excluded_templates = {"tower_baby_ashbite", "tower_black_baby_dragon"}
tt.mod_attack.max_speed = 12 * FPS
tt.enemy.gold = 0
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = vec_2(29, 0)
tt.fade_nodes_to_defend_point = 25
tt.health.armor = 1
tt.health.hp_max = 90
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.health_bar.offset = vec_2(0, 42)
tt.health_bar.hidden = true
tt.main_script.update = scripts.enemy_twilight_scourger_banshee.update
tt.motion.max_speed = 4.98 * FPS
tt.particles_name = "ps_twilight_scourger_banshee"
tt.sound_events.death = nil
tt.render.sprites[1].anchor = vec_2(0.5, 0.13043478260869565)
tt.render.sprites[1].prefix = "scourger_shadow"
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.unit.blood_color = BLOOD_NONE
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 18)
tt.vis.flags = 0
tt.vis.bans = band(F_ALL, bnot(bor(F_MOD, F_TELEPORT)))
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {{0, 255}, {2, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 2
--#endregion
--#region enemy_webspitting_spider
tt = RT("enemy_webspitting_spider", "enemy")

AC(tt, "melee", "timed_attacks")

tt.info.enc_icon = 18
tt.info.portrait = "kr3_info_portraits_enemies_0032"
tt.enemy.gold = 60
tt.enemy.melee_slot = vec_2(36, 0)
tt.health.hp_max = 550
tt.health.magic_armor = 0.85
tt.health.poison_armor = 0.5
tt.health_bar.offset = vec_2(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 14
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(18)
tt.main_script.update = scripts.enemy_webspitting_spider.update
tt.motion.max_speed = 1.7 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.2714285714285714)
tt.render.sprites[1].prefix = "webspitting_spider"
tt.sound_events.death = "DeathEplosion"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "spitWeb"
tt.timed_attacks.list[1].cast_time = fts(11)
tt.timed_attacks.list[1].cooldown = {6, 6, 6, 4}
tt.timed_attacks.list[1].mod = "mod_spider_web"
tt.timed_attacks.list[1].vis_flags = bor(F_NET, F_STUN)
tt.ui.click_rect = r(-20, 0, 40, 30)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 12)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_sword_spider
tt = RT("enemy_sword_spider", "enemy")

AC(tt, "melee")

tt.info.enc_icon = 10
tt.info.portrait = "kr3_info_portraits_enemies_0004"
tt.enemy.gold = 16
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 135
tt.health.magic_armor = {0.75, 0.75, 0.9}
tt.health.poison_armor = 0.5
tt.health_bar.offset = vec_2(0, 28)
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.411 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.13157894736842105)
tt.render.sprites[1].prefix = "sword_spider"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 12)
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_rabbit
tt = RT("enemy_rabbit", "enemy")
tt.info.portrait = "kr3_info_portraits_enemies_0020"
tt.enemy.gold = 7
tt.health.hp_max = 80
tt.health_bar.offset = vec_2(0, 20)
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 0.747 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.21428571428571427)
tt.render.sprites[1].prefix = "rabbit"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-10, -5, 20, 20)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(0, 10)
tt.unit.size = UNIT_SIZE_SMALL
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
--#endregion
--#region enemy_zealot
tt = RT("enemy_zealot", "enemy")

AC(tt, "melee", "tween")

tt.enemy.gold = 40
tt.enemy.lives_cost = 0
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 0
tt.health_bar.offset = vec_2(0, 36)
tt.info.portrait = "kr3_info_portraits_enemies_0040"
tt.info.i18n_key = "ENEMY_BOSS_DROW_QUEEN_ZEALOT"
tt.main_script.update = scripts.enemy_zealot.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.078125)
tt.render.sprites[1].prefix = "zealot"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "zealot_glow_0001"
tt.render.sprites[2].anchor.y = 0.06666666666666667
tt.render.sprites[2].draw_order = 2
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "zealot_glow_0002"
tt.render.sprites[3].anchor.y = 0.06666666666666667
tt.render.sprites[3].draw_order = -2
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {0.3, 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].sprite_id = 3
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
--#endregion
--#region enemy_twilight_evoker
tt = RT("enemy_twilight_evoker", "enemy")

AC(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = 65
tt.enemy.melee_slot = vec_2(15, 0)
tt.info.i18n_key = "ENEMY_TWILIGHT_EVOKER"
tt.info.enc_icon = 21
tt.info.portrait = "kr3_info_portraits_enemies_0030"
tt.health.hp_max = 600
tt.health.magic_armor = {0.75, 0.75, 0.9}
tt.health.armor_resilience = 0.6
tt.health_bar.offset = vec_2(0, 38)
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.175)
tt.render.sprites[1].prefix = "twilight_evoker"
tt.sound_events.death = "ElvesScourgerDeath"
tt.unit.hit_offset = vec_2(0, 21)
tt.unit.mod_offset = vec_2(0, 16)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.main_script.update = scripts.enemy_twilight_evoker.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(17)
tt.ranged.attacks[1].bullet = "bullet_twilight_evoker"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(3, 42)}
tt.ranged.attacks[1].cooldown = 1.5 + fts(19)
tt.ranged.attacks[1].max_range = 110
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].hold_advance = true
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "towerAttack"
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].cooldown = {7, 7, 7, 4}
tt.timed_attacks.list[1].mod = "mod_twilight_evoker_silence"
tt.timed_attacks.list[1].range = 165
tt.timed_attacks.list[1].included_templates = {
	"tower_high_elven",
	"tower_wild_magus",
	"tower_druid",
	"tower_entwood",
	"tower_archer_dwarf",
	"tower_musketeer",
	"tower_crossbow",
	"tower_totem",
	"tower_arcane",
	"tower_silver",
	"tower_arcane_wizard",
	"tower_sorcerer",
	"tower_archmage",
	"tower_necromancer",
	"tower_bfg",
	"tower_dwaarp"
}
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].cast_time = fts(16)
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].cooldown = {7, 7, 4}
tt.timed_attacks.list[2].max_count = 4
tt.timed_attacks.list[2].hp_trigger_factor = 0.7
tt.timed_attacks.list[2].mod = "mod_twilight_evoker_heal"
tt.timed_attacks.list[2].range = 110
tt.timed_attacks.list[2].sound = "ElvesCreepEvokerHeal"
tt.timed_attacks.list[2].vis_flags = F_RANGED
--#endregion
--#region enemy_twilight_golem
tt = RT("enemy_twilight_golem", "enemy")

AC(tt, "melee")

tt.enemy.gold = 125
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(20, 0)
tt.info.portrait = "kr3_info_portraits_enemies_0037"
tt.info.enc_icon = 25
tt.health.armor = 0.9
tt.health.hp_max = 4000
tt.health_bar.offset = vec_2(0, 80)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.on_damage = scripts.enemy_twilight_golem.on_damage
tt.motion.max_speed = {0.996 * FPS, 0.996 * FPS, 1.494 * FPS}
tt.motion.min_speed_sub_factor = 0.7
tt.render.sprites[1].anchor = vec_2(0.5, 0.28448275862068967)
tt.render.sprites[1].prefix = "twilight_golem"
tt.sound_events.death = "ElvesCreepGolemDeath"
tt.sound_events.death_args = {
	delay = fts(10)
}
tt.ui.click_rect = r(-30, 0, 60, 60)
tt.unit.blood_color = BLOOD_NONE
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.mod_offset = vec_2(0, 30)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_INSTAKILL
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 180
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound_hit = "ElvesCreepGolemAreaAttack"
tt.melee.attacks[1].hit_fx = "decal_twilight_golem_attack"
--#endregion
--#region enemy_twilight_heretic
tt = RT("enemy_twilight_heretic", "enemy")

AC(tt, "melee", "ranged", "timed_attacks")

tt.info.portrait = "kr3_info_portraits_enemies_0031"
tt.info.enc_icon = 24
tt.enemy.gold = 150
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.dead_lifetime = 3
tt.health.hp_max = 1600
tt.health.magic_armor = 0.9
tt.health_bar.offset = vec_2(0, 40)
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.17567567567567569)
tt.render.sprites[1].prefix = "twilight_heretic"
tt.sound_events.death = "DeathHuman"
tt.unit.hit_offset = vec_2(0, 17)
tt.unit.hide_after_death = true
tt.unit.mod_offset = vec_2(0, 14)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.main_script.update = scripts.enemy_twilight_heretic.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].hit_time = fts(14)
tt.ranged.attacks[1].bullet = "bullet_twilight_heretic"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(3, 42)}
tt.ranged.attacks[1].cooldown = 0.8 + fts(23)
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].min_range = 5
tt.ranged.attacks[1].shoot_time = fts(15)
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].vis_bans = bor(F_SERVANT)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animations = {"consumeStart", "consumeLoop", "consumeEnd"}
tt.timed_attacks.list[1].cast_time = 0.4
tt.timed_attacks.list[1].cooldown = {5, 5, 4}
tt.timed_attacks.list[1].mod = "mod_twilight_heretic_consume"
tt.timed_attacks.list[1].range = 125
tt.timed_attacks.list[1].nodes_limit = 45
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING, F_HERO, F_ENEMY, F_SERVANT)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].hit_fx = "fx_twilight_heretic_consume"
tt.timed_attacks.list[1].ball = "decal_twilight_heretic_consume_ball"
tt.timed_attacks.list[1].balls_count = 3
tt.timed_attacks.list[1].balls_dest_offset = vec_2(20, 10)
tt.timed_attacks.list[2] = CC("mod_attack")
tt.timed_attacks.list[2].animation = "shadowCast"
tt.timed_attacks.list[2].cast_time = fts(15)
tt.timed_attacks.list[2].cooldown = {20, 20, 13}
tt.timed_attacks.list[2].mod = "mod_twilight_heretic_servant"
tt.timed_attacks.list[2].range = 175
tt.timed_attacks.list[2].radius = 50
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING, F_HERO, F_ENEMY, F_SERVANT)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED, F_MOD)
--#endregion
--#region enemy_drider
tt = RT("enemy_drider", "enemy")

AC(tt, "melee")

tt.info.portrait = "kr3_info_portraits_enemies_0035"
tt.info.enc_icon = 20
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(28, 0)
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = 1.411 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.15517241379310345)
tt.render.sprites[1].prefix = "drider"
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-20, 0, 40, 35)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.show_blood_pool = false
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.marker_offset = vec_2(0, 3)
tt.unit.mod_offset = vec_2(0, 17)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.melee.attacks[1].cooldown = 1 - fts(12)
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "poison"
tt.melee.attacks[2].cooldown = {5, 5, 5, 4}
tt.melee.attacks[2].cooldown_inc = 5
tt.melee.attacks[2].hit_time = fts(15)
tt.melee.attacks[2].mod = "mod_drider_poison"
tt.generation = 0
--#endregion
--#region enemy_mantaray
tt = RT("enemy_mantaray", "enemy")

AC(tt, "tween", "track_kills")

tt.info.enc_icon = 28
tt.info.portrait = "kr3_info_portraits_enemies_0038"
tt.enemy.gold = 15
tt.enemy.max_blockers = 1
tt.enemy.melee_slot = vec_2(17, 0)
tt.health.hp_max = 70
tt.health_bar.offset = vec_2(0, 42)
tt.motion.max_speed = {2.9 * FPS, 2.9 * FPS, 3.5 * FPS}
tt.render.sprites[1].anchor = vec_2(0.5, 0.07142857142857142)
tt.render.sprites[1].prefix = "mantaray"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect = r(-20, 15, 40, 25)
tt.unit.mod_offset_fly = vec_2(0, 27)
tt.unit.mod_offset_facehug = vec_2(0, 15)
tt.unit.mod_offset = tt.unit.mod_offset_fly
tt.unit.hit_offset_fly = vec_2(0, 24)
tt.unit.hit_offset_facehug = vec_2(0, 16)
tt.unit.hit_offset = tt.unit.hit_offset_fly
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.vis.bans = bor(tt.vis.bans, F_SKELETON, F_BLOOD)
tt.main_script.update = scripts.enemy_mantaray.update
tt.main_script.remove = scripts.enemy_mantaray.remove
tt.tween.props[1].name = "offset"
tt.tween.disabled = true
tt.tween.remove = false
tt.facehug_damage_cooldown = 1
tt.facehug_offsets = {}
tt.facehug_offsets.hero_default = vec_2(0, 4)
tt.facehug_offsets.soldier_default = vec_2(-2, 3)
tt.facehug_offsets.hero_arivan = vec_2(4, 5)
tt.facehug_offsets.hero_bravebark = vec_2(10, 22)
tt.facehug_offsets.hero_bruce = vec_2(3, 23)
tt.facehug_offsets.hero_catha = vec_2(3, 15)
tt.facehug_offsets.hero_durax = vec_2(4, 28)
tt.facehug_offsets.hero_durax_clone = vec_2(4, 28)
tt.facehug_offsets.hero_elves_archer = vec_2(3, 9)
tt.facehug_offsets.hero_elves_denas = vec_2(4, 13)
tt.facehug_offsets.hero_lilith = vec_2(0, 17)
tt.facehug_offsets.hero_lynn = vec_2(0, 8)
tt.facehug_offsets.hero_rag = vec_2(9, 18)
tt.facehug_offsets.hero_regson = vec_2(5, 3)
tt.facehug_offsets.hero_veznan = vec_2(0, 8)
tt.facehug_offsets.hero_xin = vec_2(2, 16)
tt.facehug_offsets.soldier_blade = vec_2(0, 10)
tt.facehug_offsets.soldier_bravebark = vec_2(0, 1)
tt.facehug_offsets.soldier_catha = vec_2(0, 14)
tt.facehug_offsets.soldier_drow = vec_2(0, 10)
tt.facehug_offsets.soldier_druid_bear = vec_2(15, 0)
tt.facehug_offsets.soldier_elves_denas_guard = vec_2(0, 10)
tt.facehug_offsets.soldier_forest = vec_2(0, 13)
tt.facehug_offsets.soldier_rag = vec_2(0, 10)
tt.facehug_offsets.soldier_re_5_1 = vec_2(-3, 18)
tt.facehug_offsets.soldier_re_5_2 = vec_2(-3, 18)
tt.facehug_offsets.soldier_re_5_3 = vec_2(-3, 18)
tt.facehug_offsets.soldier_veznan_demon = vec_2(10, 21)
tt.facehug_damage_soldier_min = 15
tt.facehug_damage_soldier_max = 20
tt.facehug_damage_hero_min = 10
tt.facehug_damage_hero_max = 30
tt.facehug_spawn_bans = {"soldier_druid_bear", "soldier_xin_ultimate", "soldier_xin_shadow", "soldier_bravebark", "hero_alleria", "soldier_veznan_demon", "hero_baby_malik"}
--#endregion
--#region enemy_razorboar
tt = RT("enemy_razorboar", "enemy")

AC(tt, "melee", "timed_attacks", "auras")

tt.info.enc_icon = 23
tt.info.portrait = "kr3_info_portraits_enemies_0034"
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_razorboar_rage"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 75
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.armor = {0.6, 0.6, 0.75}
tt.health.hp_max = 1250
tt.health_bar.offset = vec_2(0, 47)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.15625)
tt.render.sprites[1].prefix = "razorboar"
tt.render.sprites[1].angles.run = {"runningRightLeft", "runningDown", "runningUp"}
tt.render.sprites[1].angles_stickiness.run = 10
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 30)
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 16)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.main_script.update = scripts.enemy_razorboar.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {40, 40, 80}
tt.melee.attacks[1].damage_min = {30, 30, 60}
tt.melee.attacks[1].hit_time = fts(14)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].nodes_limit = 35
tt.timed_attacks.list[1].vis_flags_enemies = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[1].vis_bans_enemies = bor(F_FLYING, F_BOSS)
tt.timed_attacks.list[1].vis_flags_soldiers = bor(F_MOD, F_RANGED)
tt.timed_attacks.list[1].vis_bans_soldiers = bor(F_FLYING)
tt.timed_attacks.list[1].trigger_range = 50
tt.timed_attacks.list[1].range = 37.5
tt.timed_attacks.list[1].sound = "ElvesCreepRazorboarCharge"
tt.timed_attacks.list[1].duration = 1.2
tt.timed_attacks.list[1].mod_enemy = "mod_razorboar_rampage_enemy"
tt.timed_attacks.list[1].mod_soldier = "mod_razorboar_rampage_soldier"
tt.timed_attacks.list[1].mod_self = "mod_razorboar_rampage_speed"
tt.timed_attacks.list[1].particles_name = "ps_razorboar_rampage"
--#endregion
--#region enemy_arachnomancer
tt = RT("enemy_arachnomancer", "enemy")

AC(tt, "melee", "timed_attacks", "death_spawns")

tt.info.portrait = "kr3_info_portraits_enemies_0007"
tt.info.enc_icon = 22
tt.death_spawns.name = "bullet_arachnomancer_spawn"
tt.death_spawns.delay = fts(26)
tt.death_spawns.spread_nodes = 3
tt.death_spawns.offset = vec_2(0, 6)
tt.death_spawns.quantity = 3
tt.enemy.gold = 110
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(22, 0)
tt.health.hp_max = 750
tt.health_bar.offset = vec_2(0, 33)
tt.motion.max_speed = 1.079 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.136)
tt.render.sprites[1].prefix = "arachnomancer"
tt.sound_events.death = "DeathHuman"
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 15)
tt.unit.can_explode = false
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.vis.bans = bor(tt.vis.bans, F_POLYMORPH)
tt.main_script.update = scripts.enemy_arachnomancer.update
tt.melee.attacks[1].cooldown = 1 - fts(23)
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(23)
tt.timed_attacks.list[1] = CC("spawn_attack")
tt.timed_attacks.list[1].entity = "arachnomancer_random_spawner"
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].spawn_time = fts(20)
tt.timed_attacks.list[1].cooldown = {7, 7, 5}
tt.timed_attacks.list[1].nodes_limit = 40
tt.timed_attacks.list[1].spawn_sets = {{4, "decal_webspawn_enemy_spider_arachnomancer"}, {3, "decal_webspawn_enemy_sword_spider"}, {2, "decal_webspawn_enemy_spider_son_of_mactans"}}
--#endregion
--#region arachnomancer_random_spawner
tt = RT("arachnomancer_random_spawner")

AC(tt, "pos", "spawner", "main_script", "sound_events")

tt.main_script.update = scripts.enemies_spawner.update
tt.spawner.count = nil
tt.spawner.random_cycle = {0, fts(2)}
tt.spawner.entity = nil
tt.spawner.random_node_offset_range = {-8, 2}
tt.spawner.random_subpath = true
tt.spawner.initial_spawn_animation = "idle"
tt.spawner.check_node_valid = true
tt.spawner.use_node_pos = true
tt.sound_events.insert = "ElvesCreepArachnomancerSpiderSpawn"
--#endregion
--#region enemy_spider_arachnomancer
tt = RT("enemy_spider_arachnomancer", "enemy")

AC(tt, "melee")

tt.enemy.gold = 15
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 80
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 21)
tt.info.portrait = "kr3_info_portraits_enemies_0036"
tt.info.i18n_key = "ENEMY_ARACHNOMANCER_SPIDER"
tt.info.enc_icon = 30
tt.motion.max_speed = 1.992 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.15625)
tt.render.sprites[1].prefix = "arachnomancer_spider"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 12)
tt.unit.mod_offset = vec_2(0, 12)
tt.vis.bans = bor(tt.vis.bans, F_POISON, F_SKELETON)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(14)
--#endregion
--#region spider_arachnomancer_egg_spawner
tt = RT("spider_arachnomancer_egg_spawner", "decal_scripted")

AC(tt, "spawner", "sound_events", "tween", "editor")

tt.render.sprites[1].prefix = "spider_egg_spawner"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor.y = 0.4
tt.spawner.entity = "enemy_spider_arachnomancer"
tt.spawner.eternal = true
tt.spawner.random_subpath = true
tt.spawner.cycle_time = fts(10)
tt.main_script.update = scripts.spider_arachnomancer_egg_spawner.update
tt.sound_events.open = "ElvesSpecialSpiderEggs"
tt.idle_range = {5, 15}
tt.spawn_time = fts(8)
tt.spawn_once = nil
tt.spawn_data = nil
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {fts(10), 0}}
--#endregion
--#region enemy_spider_son_of_mactans
tt = RT("enemy_spider_son_of_mactans", "enemy")

AC(tt, "melee")

tt.info.portrait = "kr3_info_portraits_enemies_0028"
tt.info.enc_icon = 29
tt.enemy.gold = 35
tt.enemy.melee_slot = vec_2(32, 0)
tt.health.hp_max = 260
tt.health.magic_armor = 0.9
tt.health_bar.offset = vec_2(0, 32)
tt.info.i18n_key = "ENEMY_SPIDER_SON_OF_MACTANS"
tt.motion.max_speed = {2 * FPS, 2 * FPS, 2.2 * FPS}
tt.render.sprites[1].anchor = vec_2(0.5, 0.128571)
tt.render.sprites[1].prefix = "son_of_mactans"
tt.sound_events.death = "DeathEplosion"
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = vec_2(0, 15)
tt.unit.mod_offset = vec_2(0, 15)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 12
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].mod = "mod_son_of_mactans_poison"
tt.melee.attacks[2].cooldown = 6
--#endregion
--#region spider_son_of_mactans_drop_spawner
tt = RT("spider_son_of_mactans_drop_spawner", "decal_scripted")

AC(tt, "nav_path", "motion", "spawner", "sound_events")

tt.spawn = "enemy_spider_son_of_mactans"
tt.main_script.update = scripts.spider_son_of_mactans_drop_spawner.update
tt.sound_events.insert = "ElvesCreepSonOfMactansLanding"
tt.render.sprites[1].prefix = "son_of_mactans"
tt.render.sprites[1].name = "netDescend"
tt.render.sprites[1].anchor.y = 0.12857142857142856
tt.render.sprites[1].z = Z_OBJECTS_SKY

for i = 1, math.ceil(REF_H / 18) do
	local s = CC("sprite")

	s.prefix = "son_of_mactans_thread_" .. (i % 2 == 0 and "1" or "2")
	s.name = "idle"
	s.loop = false
	s.anchor.y = 0
	s.offset.y = (i - 1) * 18 + 40
	s.z = Z_OBJECTS_SKY - 1
	tt.render.sprites[i + 1] = s
end

--#endregion
--#region enemy_mactans
tt = RT("enemy_mactans", "decal_scripted")

AC(tt, "ui", "tween", "editor")

tt.render.sprites[1].prefix = "mactans"
tt.render.sprites[1].name = "falling"
tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].z = Z_OBJECTS_SKY + 1
tt.drop_duration = 2
tt.retreat_duration = 1.5
tt.netting_duration = 2.6
tt.main_script.update = scripts.enemy_mactans.update
tt.ui.can_select = false
tt.ui.can_click = true
tt.ui.click_rect = r(-40, 30, 80, 80)
tt.ui.z = 1
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].keys = {{0, vec_1(0)}, {fts(2), vec_2(0, 7)}, {fts(4), vec_2(0, 2)}, {fts(6), vec_2(0, 1)}, {fts(8), vec_2(0, -3)}, {fts(10), vec_2(0, -8)}, {fts(12), vec_2(0, -2)}, {fts(14), vec_2(0, 3)}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "r"
tt.tween.props[2].keys = {{0, 0}, {fts(2), d2r(-6)}, {fts(4), d2r(-1)}, {fts(6), d2r(3)}, {fts(8), d2r(5)}, {fts(10), d2r(0)}, {fts(12), d2r(0)}, {fts(14), d2r(0)}}
tt.editor.overrides = {
	["render.sprites[1].name"] = "retreat"
}
--#endregion
--#region enemy_gnoll_bloodsydian
tt = RT("enemy_gnoll_bloodsydian", "enemy")

AC(tt, "melee")

tt.info.portrait = "kr3_info_portraits_enemies_0043"
tt.info.enc_icon = 35
tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(32, 0)
tt.health.damage_factor_magical = 1.3
tt.health.hp_max = 400
tt.health_bar.offset = vec_2(0, 38)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {24, 24, 40}
tt.melee.attacks[1].damage_min = {16, 16, 20}
tt.melee.attacks[1].hit_time = fts(16)
tt.motion.max_speed = 2.075 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.3111111111111111)
tt.render.sprites[1].prefix = "bloodsydianGnoll"
tt.sound_events.death = "ElvesDeathGnolls"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 16)
--#endregion
--#region enemy_bloodsydian_warlock
tt = RT("enemy_bloodsydian_warlock", "enemy")

AC(tt, "melee", "timed_attacks")

tt.info.enc_icon = 37
tt.info.portrait = "kr3_info_portraits_enemies_0044"
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(37, 0)
tt.health.hp_max = 1200
tt.health.magic_armor = {0.5, 0.5, 0.75}
tt.health_bar.offset = vec_2(0, 58)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_bloodsydian_warlock.update
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 23
tt.melee.attacks[1].hit_time = fts(27)
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.16279069767441862)
tt.render.sprites[1].prefix = "bloodsydianWarlock"
tt.sound_events.death = "ElvesDeathGnolls"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.mod_offset = vec_2(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].allowed_templates = {"enemy_gnoll_burner", "enemy_gnoll_reaver"}
tt.timed_attacks.list[1].mod = "mod_bloodsydian_warlock"
tt.timed_attacks.list[1].animation = "convert"
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].hit_decal = "decal_bloodsydian_warlock"
tt.timed_attacks.list[1].cooldown = {8, 8, 5}
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].max_count = 5
tt.timed_attacks.list[1].min_count = 2
tt.timed_attacks.list[1].nodes_min = 30
tt.timed_attacks.list[1].nodes_limit = 20
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
--#endregion
--#region enemy_perython_rock_thrower
tt = RT("enemy_perython_rock_thrower", "enemy_perython")

AC(tt, "death_spawns")

tt.info.i18n_key = "ENEMY_PERYTHON"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "perython_rock"
tt.render.sprites[3].name = "flySide"
tt.render.sprites[3].anchor = vec_2(0.5, 0.5)
tt.render.sprites[3].offset.y = 10
tt.death_spawns.name = "rock_perython"
tt.death_spawns.concurrent_with_death = true
tt.main_script.update = scripts.enemy_perython_carrier.update
tt.spawn_trigger_range = 50
tt.drop_delay = {0.5, 0.9}
--#endregion
--#region enemy_ogre_magi
tt = RT("enemy_ogre_magi", "enemy")

AC(tt, "ranged", "auras")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ogre_magi_shield"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "aura_ogre_magi_regen"
tt.auras.list[2].cooldown = 0
tt.info.enc_icon = 36
tt.info.portrait = "kr3_info_portraits_enemies_0032"
tt.enemy.gold = 100
tt.enemy.lives_cost = {2, 2, 2, 3}
tt.enemy.melee_slot = vec_2(38, 0)
tt.health.hp_max = 1700
tt.health.magic_armor = {0.75, 0.75, 0.8}
tt.health_bar.offset = vec_2(0, 63)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_ogre_magi.update
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].damage_max = 72
tt.ranged.attacks[1].damage_min = 48
tt.ranged.attacks[1].shoot_time = fts(17)
tt.ranged.attacks[1].bullet = "bolt_ogre_magi"
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].bullet_start_offset = {vec_2(-25, 53)}
tt.motion.max_speed = 0.83 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.17777777777777778)
tt.render.sprites[1].prefix = "ogre_mage"
tt.sound_events.death = "DeathBig"
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.hit_offset = vec_2(0, 27)
tt.unit.mod_offset = vec_2(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region enemy_ogre_magi_custody_ettin
tt = RT("enemy_ogre_magi_custody_ettin", "enemy_ettin")
tt.motion.max_speed = 0.83 * FPS
tt.info.i18n_key = "ENEMY_ETTIN"
--#endregion
--#region enemy_ogre_magi_custody_gnoll_gnawer
tt = RT("enemy_ogre_magi_custody_gnoll_gnawer", "enemy_gnoll_gnawer")
tt.motion.max_speed = 0.83 * FPS
tt.info.i18n_key = "ENEMY_GNOLL_GNAWER"
--#endregion
--#region enemy_ogre_magi_custody_warlock
tt = RT("enemy_ogre_magi_custody_warlock", "enemy_bloodsydian_warlock")
tt.motion.max_speed = 0.83 * FPS
tt.info.i18n_key = "ENEMY_BLOODSYDIAN_WARLOCK"
--#endregion
--#region enemy_blood_servant
tt = RT("enemy_blood_servant", "enemy")

AC(tt, "melee")

tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(30, 0)
tt.health.hp_max = 200
tt.health_bar.offset = vec_2(0, 30)
tt.info.enc_icon = 39
tt.info.portrait = "kr3_info_portraits_enemies_0046"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {24, 24, 30}
tt.melee.attacks[1].damage_min = {16, 16, 20}
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "WolfAttack"
tt.motion.max_speed = 2.241 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.14285714285714285)
tt.render.sprites[1].prefix = "bloodServant"
tt.sound_events.death = "ElvesCreepServantDeath"
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 14)
--#endregion
--#region enemy_mounted_avenger
tt = RT("enemy_mounted_avenger", "enemy")

AC(tt, "melee", "death_spawns")

tt.death_spawns.name = "enemy_twilight_avenger"
tt.death_spawns.delay = fts(21)
tt.death_spawns.offset = vec_2(0, 7)
tt.enemy.gold = 60
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.hp_max = 1000
tt.health.magic_armor = {0.5, 0.5, 0.7}
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 65)
tt.info.enc_icon = 40
tt.info.portrait = "kr3_info_portraits_enemies_0047"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {90, 90, 110}
tt.melee.attacks[1].damage_min = {60, 60, 70}
tt.melee.attacks[1].hit_time = fts(19)
tt.motion.max_speed = 1.411 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1875)
tt.render.sprites[1].prefix = "mountedAvenger"
tt.ui.click_rect = r(-20, 0, 40, 50)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 21)
tt.unit.marker_offset = vec_2(0, -2)
tt.unit.mod_offset = vec_2(0, 27)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.sound_events.death = "ElvesCreepMountedAvengerDeath"
tt.sound_events.death_args = {
	delay = fts(15)
}
--#endregion
--#region enemy_screecher_bat
tt = RT("enemy_screecher_bat", "enemy")

AC(tt, "timed_attacks")

tt.enemy.gold = 30
tt.health.hp_max = 90
tt.health_bar.offset = vec_2(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 41
tt.info.portrait = "kr3_info_portraits_enemies_0048"
tt.main_script.update = scripts.enemy_screecher_bat.update
tt.motion.max_speed = {1.9 * FPS, 1.9 * FPS, 2 * FPS}
tt.render.sprites[1].anchor = vec_2(0.5, 0.05)
tt.render.sprites[1].prefix = "screecher_bat"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].animated = false
tt.sound_events.death = "ElvesCreepScreecherDeath"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "attack"
tt.timed_attacks.list[1].mod = "mod_screecher_bat_stun"
tt.timed_attacks.list[1].cooldown = {5, 5, 4.5}
tt.timed_attacks.list[1].max_range = 50
tt.timed_attacks.list[1].attack_time = fts(10)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].vis_flags = bor(F_STUN)
tt.timed_attacks.list[1].sound = "ElvesCreepScreecherScream"
tt.ui.click_rect = r(-15, 45, 30, 35)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 54)
tt.unit.mod_offset = vec_2(0, 50)
tt.unit.show_blood_pool = false
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.vis.bans = bor(F_BLOCK)
--#endregion
--#region enemy_dark_spitters
tt = RT("enemy_dark_spitters", "enemy")

AC(tt, "melee", "ranged")

tt.enemy.gold = 70
tt.enemy.melee_slot = vec_2(27, 0)
tt.health.armor = {0.5, 0.5, 0.8}
tt.health.hp_max = 800
tt.health_bar.offset = vec_2(0, 53)
tt.info.enc_icon = 45
tt.info.portrait = "kr3_info_portraits_enemies_0053"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 36
tt.melee.attacks[1].damage_min = 24
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 0.83 * FPS
tt.ranged.attacks[1].bullet = "bullet_dark_spitters"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(8, 36)}
tt.ranged.attacks[1].cooldown = 1.5 + fts(19)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_BURN)
tt.render.sprites[1].anchor = vec_2(0.5, 0.12857142857142856)
tt.render.sprites[1].prefix = "dark_spitters"
tt.sound_events.death = "ElvesDarkSpitterDeath"
tt.ui.click_rect = r(-15, 0, 30, 40)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 16)
--#endregion
--#region enemy_shadows_spawns
tt = RT("enemy_shadows_spawns", "enemy")

AC(tt, "melee")

tt.enemy.gold = 20
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = 350
tt.health_bar.offset = vec_2(0, 34)
tt.info.enc_icon = 44
tt.info.portrait = "kr3_info_portraits_enemies_0052"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 24
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(17)
tt.motion.max_speed = 1.66 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.29411764705882354)
tt.render.sprites[1].prefix = "shadow_spawn"
tt.sound_events.death = "ElvesShadowSpawnDeath"
tt.sound_events.raise = "ElvesShadowSpawnSpawn"
tt.sound_events.raise_args = {
	delay = fts(2)
}
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.mod_offset = vec_2(0, 16)
--#endregion
--#region enemy_grim_devourers
tt = RT("enemy_grim_devourers", "enemy")

AC(tt, "melee")

tt.cannibalize = {}
tt.cannibalize.extra_hp = 50
tt.cannibalize.cycles = 26
tt.cannibalize.hp_per_cycle = 2
tt.enemy.gold = 40
tt.enemy.melee_slot = vec_2(23, 0)
tt.health.armor = {0.3, 0.3, 0.6}
tt.health.hp_max = 500
tt.health_bar.offset = vec_2(0, 42)
tt.info.enc_icon = 46
tt.info.portrait = "kr3_info_portraits_enemies_0054"
tt.main_script.update = scripts.enemy_grim_devourers.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = {48, 48, 55}
tt.melee.attacks[1].damage_min = {32, 32, 40}
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = 1.245 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.14705882352941177)
tt.render.sprites[1].prefix = "grim_devourers"
tt.sound_events.death = "ElvesGrimDevourerDeath"
tt.sound_events.cannibalize = "ElvesGrimDevourerConsume"
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = vec_2(0, 18)
tt.unit.mod_offset = vec_2(0, 16)
--#endregion
--#region enemy_shadow_champion
tt = RT("enemy_shadow_champion", "enemy")

AC(tt, "melee", "death_spawns")

tt.death_spawns.name = "aura_shadow_champion_death"
tt.death_spawns.delay = fts(26)
tt.death_spawns.no_spawn_damage_types = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE)
tt.enemy.gold = 140
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.armor = 0.9
tt.health.hp_max = 2200
tt.health_bar.offset = vec_2(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 47
tt.info.portrait = "kr3_info_portraits_enemies_0055"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 50
tt.melee.attacks[1].damage_max = 96
tt.melee.attacks[1].damage_min = 64
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_offset = vec_2(40, 0)
tt.melee.attacks[1].sound_hit = "ElvesShadowChampionAttack"
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.203125)
tt.render.sprites[1].prefix = "shadow_champion"
tt.sound_events.death = "ElvesShadowChampionDeath"
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.hit_offset = vec_2(0, 27)
tt.unit.mod_offset = vec_2(0, 27)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_INSTAKILL
--#endregion
--#region enemy_gnoll_warleader
tt = RT("enemy_gnoll_warleader", "enemy")

AC(tt, "melee", "death_spawns")

tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = vec_2(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(43, 0)
tt.health.hp_max = 2500
tt.health_bar.offset = vec_2(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 34
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_GNOLL"
tt.info.portrait = "kr3_info_portraits_enemies_0042"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_offset = vec_2(43, 0)
tt.melee.attacks[1].sound_hit = "EndlessWarleaderDoubleSword"
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.2222222222222222)
tt.render.sprites[1].prefix = "enemy_gnoll_warleader"
tt.sound_events.death = "EndlessWarleaderDeath"
tt.unit.hit_offset = vec_2(0, 27)
tt.unit.mod_offset = vec_2(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
--#endregion
--#region enemy_twilight_brute
tt = RT("enemy_twilight_brute", "enemy")

AC(tt, "melee", "auras", "death_spawns")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_twilight_brute"
tt.auras.list[1].cooldown = 0
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "fx_coin_shower"
tt.death_spawns.offset = vec_2(0, 60)
tt.enemy.gold = 250
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(43, 0)
tt.health.hp_max = 2500
tt.health_bar.offset = vec_2(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 43
tt.info.i18n_key = "ENEMY_ENDLESS_MINIBOSS_TWILIGHT"
tt.info.portrait = "kr3_info_portraits_enemies_0050"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 80
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_offset = vec_2(43, 3)
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1875)
tt.render.sprites[1].prefix = "enemy_twilight_bannerbearer"
tt.sound_events.death = "EndlessBruteDeath"
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 25)
tt.unit.mod_offset = vec_2(0, 25)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
-- 萨雷格兹主母
--#endregion
--#region enemy_sarelgaz_big
tt = RT("enemy_sarelgaz_big", "enemy")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.1484375
anchor_x = 0.5
image_y = 128
image_x = 220
tt.enemy.gold = 160
tt.enemy.lives_cost = 5
tt.enemy.melee_slot = vec_2(70, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 2700
tt.health.magic_armor = 0.3
tt.health.armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.offset = vec_2(0, 82)
tt.info.i18n_key = "ENEMY_SARELGAS_BIG"
tt.info.enc_icon = 35
tt.info.portrait = "info_portraits_enemies_0036"
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 125
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].sound = "SpiderAttack"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_sarelgaz_bigger_egg"
tt.timed_attacks.list[1].max_cooldown = 17
tt.timed_attacks.list[1].max_count = 15
tt.timed_attacks.list[1].min_cooldown = 9
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "enemy_sarelgaz_big_aura"
tt.auras.list[1].cooldown = 0
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].scale = vec_1(0.75)
tt.render.sprites[1].prefix = "eb_sarelgaz"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.ui.click_rect = r(-45, 0, 90, 80)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.sound_events.death = "DeathEplosion"
tt.vis.bans = F_POISON
tt.vis.flags = F_ENEMY
tt.health_judger = true
--#endregion
--#region enemy_sarelgaz_big_aura
tt = RT("enemy_sarelgaz_big_aura", "aura")
tt.aura.duration = -1
tt.aura.mod = "mod_enemy_sarelgaz_big"
tt.aura.cycle_time = fts(10)
tt.aura.track_source = true
tt.aura.radius = 70
tt.aura.excluded_templates = {"enemy_sarelgaz_big"}
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
--#endregion
--#region mod_enemy_sarelgaz_big
tt = RT("mod_enemy_sarelgaz_big", "mod_slow")
tt.slow.factor = 1.2
tt.modifier.duration = fts(12)
--#endregion
--#region enemy_sarelgaz_bigger_egg
tt = RT("enemy_sarelgaz_bigger_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].scale = vec_1(1.75)
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.render.sprites[1].color = {40, 80, 255}
tt.spawner.count = 1
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_sarelgaz_small"
tt.spawner.node_offset = 5
tt.spawner.pos_offset = vec_2(0, 1)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.spawner.animation_start = "start"
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
--#endregion
--#region enemy_jungle_spider_tiny_with_gold
tt = RT("enemy_jungle_spider_tiny_with_gold", "enemy_jungle_spider_tiny")
tt.enemy.gold = 1
--#endregion
--#region enemy_spider_rotten_tiny_with_gold
tt = RT("enemy_spider_rotten_tiny_with_gold", "enemy_spider_rotten_tiny")
tt.enemy.gold = 1
--#endregion
--#region enemy_redgale
tt = RT("enemy_redgale", "enemy_bluegale")
tt.main_script.update = scripts.enemy_mixed_water.update
tt.timed_attacks = nil
tt.melee.attacks[1].damage_max = 144
tt.melee.attacks[1].damage_min = 72
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].bullet = "ray_redgale"
tt.render.sprites[1].color = {255, 100, 100}
tt.render.sprites[2].color = {255, 100, 100}
--#endregion
--#region ray_redgale
tt = RT("ray_redgale", "ray_bluegale")
tt.render.sprites[1].color = {255, 100, 100}
tt.bullet.damage_min = 50
tt.bullet.damage_max = 90
--#endregion
--#region enemy_greenshell
tt = RT("enemy_greenshell", "enemy_bloodshell")

AC(tt, "auras")

tt.render.sprites[1].color = {100, 255, 100}
tt.health.armor = 0.45
tt.health.magic_armor = 0.55
tt.health.immune_to = DAMAGE_EXPLOSION
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "greenshell_shield_aura"
tt.auras.list[1].cooldown = 0
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region greenshell_shield_aura
tt = RT("greenshell_shield_aura", "shaman_shield_aura")
tt.aura.mod = "mod_greenshell_shield"
tt.aura.allowed_templates = {"enemy_greenfin", "enemy_deviltide", "enemy_redspine", "enemy_bluegale", "enemy_redgale", "enemy_deviltide_shark", "enemy_deviltide_shark_ghost", "enemy_deviltide_ghost"}
--#endregion
--#region mod_greenshell_shield
tt = RT("mod_greenshell_shield", "mod_shaman_armor")
tt.armor_buff.max_factor = 0.35
--#endregion
--#region enemy_deviltide_shark_ghost
tt = RT("enemy_deviltide_shark_ghost", "enemy_deviltide_shark")
tt.payload = "enemy_deviltide_ghost"
tt.motion.max_speed = 90
tt.render.sprites[1].alpha = 180
tt.enemy.gold = 0
--#endregion
--#region enemy_deviltide_ghost
tt = RT("enemy_deviltide_ghost", "enemy_deviltide")
tt.enemy.gold = 0
tt.motion.max_speed = 50
tt.render.sprites[1].alpha = 180
--#endregion
--#region enemy_phantom_death_rider
tt = RT("enemy_phantom_death_rider", "enemy")

AC(tt, "auras", "melee")

anchor_y = 0.18
image_y = 50
tt.health.armor = 0.45
tt.health.hp_max = 1200
tt.health_bar.offset = vec_2(0, 47.76)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.enemy.melee_slot = vec_2(30, 0)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POLYMORPH, F_POISON, F_LYCAN, F_CANNIBALIZE, F_SKELETON)
tt.melee.cooldown = 1
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].sound = "MeleeSword"
tt.melee.attacks[1].vis_bans = bor(F_FLYING)
tt.info.portrait = "kr2_info_portraits_soldiers_0003"
tt.motion.max_speed = 50
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = 0.18
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"running"}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "soldier_death_rider"
tt.render.sprites[1].color = {180, 180, 255}
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].cooldown = 0
tt.auras.list[1].name = "phantom_death_rider_aura"
--#endregion
--#region phantom_death_rider_aura
tt = RT("phantom_death_rider_aura", "aura")

AC(tt, "render")

tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.mod = "mod_phantom_death_rider"
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.radius = 128
tt.aura.track_source = true
tt.aura.targets_per_cycle = 10
tt.aura.vis_bans = bor(F_FRIEND, F_HERO, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.render.sprites[1].name = "soldier_death_rider_aura"
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].color = {180, 180, 255}
--#endregion
--#region mod_phantom_death_rider
tt = RT("mod_phantom_death_rider", "modifier")

AC(tt, "render", "armor_buff")

tt.modifier.duration = 1
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = false
tt.armor_buff.max_factor = 0.3
tt.armor_buff.step_factor = 0.02
tt.armor_buff.cycle_time = 1
tt.render.sprites[1].name = "NecromancerSkeletonAura"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].color = {180, 180, 255}
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update
--#endregion
--#region enemy_shaman_gravity
tt = RT("enemy_shaman_gravity", "enemy")

AC(tt, "melee", "auras")

anchor_y = 0.16
image_y = 62
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "shaman_gravity_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 50
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.armor = 0.25
tt.health.hp_max = 1200
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(47))
tt.info.portrait = "kr2_info_portraits_enemies_0022"
tt.info.enc_icon = 21
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 26
tt.melee.attacks[1].damage_min = 14
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.96 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "krdove_enemy_shaman_gravity"
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(10))
tt.unit.mod_offset = vec_2(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
--#endregion
--#region shaman_gravity_aura
tt = RT("shaman_gravity_aura", "aura")
tt.aura.cycle_time = 0.125
tt.main_script.update = scripts.shaman_gravity_aura.update
tt.aura.radius = 180
tt.gravity_inc = 0.3 / (fts(1) * fts(1))
--#endregion
--#region enemy_witch_strong
tt = RT("enemy_witch_strong", "enemy_witch")
tt.enemy.gold = 88
tt.health.hp_max = 1200
tt.info.i18n_key = "ENEMY_WITCH_STRONG"
tt.vis.bans = bor(F_BLOCK, F_THORN, F_POISON)
tt.render.sprites[1].scale = vec_1(1.2)
--#endregion
--#region enemy_spectral_knight_strong
tt = RT("enemy_spectral_knight_strong", "enemy_spectral_knight")
tt.health.hp_max = 1200
tt.info.i18n_key = "ENEMY_SPECTRAL_KNIGHT_STRONG"
tt.render.sprites[1].scale = vec_1(1.2)
tt.enemy.gold = tt.enemy.gold * 1.2
tt.health_bar.offset.y = tt.health_bar.offset.y * 1.2
tt.enemy.melee_slot.x = tt.enemy.melee_slot.x * 1.2
--#endregion
--#region enemy_fallen_knight_strong
tt = RT("enemy_fallen_knight_strong", "enemy_fallen_knight")
tt.death_spawns.name = "enemy_spectral_knight_strong_spawn"
tt.health.hp_max = 2800
tt.info.i18n_key = "ENEMY_FALLEN_KNIGHT_STRONG"
tt.render.sprites[1].scale = vec_1(1.2)
tt.enemy.gold = tt.enemy.gold * 1.2
tt.health_bar.offset.y = tt.health_bar.offset.y * 1.2
tt.enemy.melee_slot.x = tt.enemy.melee_slot.x * 1.2
--#endregion
--#region enemy_spectral_knight_strong_spawn
tt = RT("enemy_spectral_knight_strong_spawn", "enemy_spectral_knight_strong")
tt.enemy.gold = 0
tt.render.sprites[1].scale = vec_1(1.2)
tt.enemy.melee_slot.x = tt.enemy.melee_slot.x * 1.2
--#endregion
--#region enemy_abomination_strong
tt = RT("enemy_abomination_strong", "enemy_abomination")
tt.info.i18n_key = "ENEMY_ABOMINATION_STRONG"
tt.motion.max_speed = 1.28 * 0.5 * FPS
tt.health.hp_max = 7800
tt.render.sprites[1].scale = vec_1(1.2)
tt.enemy.gold = tt.enemy.gold * 1.2
tt.health_bar.offset.y = tt.health_bar.offset.y * 1.2
tt.enemy.melee_slot.x = tt.enemy.melee_slot.x * 1.2

--#endregion
-- G5
local v = vec_2
local vv = vec_1
local balance = require("kr1.data.balance")

local b = balance.enemies.werebeasts.hog_invader

tt = E:register_t("enemy_hog_invader", "enemy")

E:add_comps(tt, "melee")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 1
tt.info.portrait = "kr5_info_portraits_enemies_0004"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, 10)
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "hog_invader"
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)

local b = balance.enemies.werebeasts.tusked_brawler

tt = E:register_t("enemy_tusked_brawler", "enemy")

E:add_comps(tt, "melee")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 34)
tt.health.dead_lifetime = 1
tt.info.enc_icon = 2
tt.info.portrait = "kr5_info_portraits_enemies_0009"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
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
tt.render.sprites[1].anchor = v(0.5, 0.5)
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

tt = E:register_t("enemy_turtle_shaman", "enemy")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.enc_icon = 5
tt.info.portrait = "kr5_info_portraits_enemies_0008"
tt.unit.mod_offset = v(0, 16)
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.marker_offset = v(-1, -1)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 42)
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
tt.ranged.attacks[1].bullet_start_offset = {v(25, 46)}
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

tt = E:register_t("enemy_bear_vanguard", "enemy")

E:add_comps(tt, "melee")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0001"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 50)
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
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "bear_vanguard"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.sound_events.death = "EnemyBearVanguardDeath"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
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

tt = E:register_t("fx_bear_ground_hit", "fx")
tt.render.sprites[1].name = "bear_vanguard_decal_animation"
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = v(1.5, 1.5)
tt.render.sprites[1].sort_y_offset = -2

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

tt = E:register_t("enemy_bear_woodcutter", "enemy")

E:add_comps(tt, "melee")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0011"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 46)
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
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "bear_woodcutter"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.sound_events.death = "EnemyBearVanguardDeath"
tt.ui.click_rect = r(-20, 0, 40, 40)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
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

tt = E:register_t("enemy_cutthroat_rat", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 4
tt.info.portrait = "kr5_info_portraits_enemies_0002"
tt.unit.mod_offset = v(0, 12)
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 5)
tt.ui.click_rect = r(-20, 0, 40, 35)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 28)
tt.main_script.update = scripts.enemy_cutthroat_rat.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].hit_fx = "enemy_cutthroat_rat_attack_fx"
tt.melee.attacks[1].hit_fx_offset = v(25, 5)
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
tt.render.sprites[1].offset = v(0, 10)
tt = E:register_t("mod_cutthroat_rat_bleed", "mod_blood")
b = balance.enemies.werebeasts.cutthroat_rat
tt.dps.damage_min = b.gut_stab.bleed_damage_min
tt.dps.damage_max = b.gut_stab.bleed_damage_max
tt.dps.damage_inc = 0
tt.dps.damage_every = b.gut_stab.bleed_every
tt.dps.fx_every = fts(20)
tt.modifier.duration = b.gut_stab.bleed_duration
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
tt = E:register_t("enemy_dreadeye_viper", "enemy")

E:add_comps(tt, "melee", "ranged")

b = balance.enemies.werebeasts.dreadeye_viper
tt.info.enc_icon = 7
tt.info.portrait = "kr5_info_portraits_enemies_0003"
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, 14)
tt.ui.click_rect = r(-20, 0, 40, 35)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 35)
tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
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
tt.ranged.attacks[1].bullet_start_offset = {v(12, 31)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].animation = "attack_01"
tt.sound_events.death = "EnemyDreadeyeViperDeath"
tt.unit.blood_color = BLOOD_GREEN

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
local b = balance.enemies.werebeasts.surveyor_harpy

tt = E:register_t("enemy_surveyor_harpy", "enemy")
tt.info.enc_icon = 6
tt.info.portrait = "kr5_info_portraits_enemies_0005"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_surveyor_harpy.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "patrolling_vulture"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.8)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 2, 36, 27)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

tt = E:register_t("enemy_rhino", "enemy")
local b = balance.enemies.werebeasts.rhino
E:add_comps(tt, "melee", "timed_attacks")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 80)
tt.info.enc_icon = 10
tt.info.portrait = "kr5_info_portraits_enemies_0012"
tt.unit.hit_offset = v(0, 26)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
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
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED)
tt.sound_events.death = "EnemyRazingRhinoDeath"
tt.base_speed = b.speed

local b = balance.enemies.werebeasts.skunk_bombardier

tt = E:register_t("enemy_skunk_bombardier", "enemy")

E:add_comps(tt, "melee", "ranged", "death_spawns")

tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0007"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
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
tt.ranged.attacks[1].bullet_start_offset = {v(0, 32)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.ranged.attacks[1].ignore_hit_offset = true
tt.render.sprites[1].prefix = "skunk_bombardier"
tt.sound_events.death = "EnemySkunkBombardierDeath"
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, 16)
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

tt = E:register_t("enemy_skunk_bombardier_bomb", "bomb")
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

tt = E:register_t("aura_enemy_skunk_bombardier_death_explosion", "aura")
b = balance.enemies.werebeasts.skunk_bombardier
tt.aura.mod = "mod_enemy_skunk_bombardier_basic_attack"
tt.aura.radius = b.ranged_attack.radius
tt.aura.vis_flags = F_MOD
tt.aura.vis_bans = bor(F_ENEMY)
tt.aura.cycles = 1
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

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

tt = E:register_t("enemy_hyena5", "enemy")

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
tt.info.portrait = "kr5_info_portraits_enemies_0006"
tt.main_script.update = scripts.enemy_hyena5.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_fx = "enemy_hyena5_attack_fx"
tt.melee.attacks[1].hit_fx_offset = v(25, 5)
tt.melee.attacks[1].hit_fx_flip = true
tt.motion.max_speed = b.speed
tt.sound_events.feast = "EnemyRottenfangHyenaFeast"
tt.sound_events.death = "EnemyRottenfangHyenaDeath"
tt.sound_events.water_splash = "SpecialMermaid"
tt.render.sprites[1].prefix = "rottenfang_hyena"
tt.render.sprites[1].angles_stickiness.run = 10
tt.health_bar.offset = v(0, 35)
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, -1)
tt.unit.mod_offset = v(0, 17)
tt.unit.size = UNIT_SIZE_SMALL
tt.enemy.melee_slot = v(33, 0)
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

tt = E:register_t("fx_dreadeye_viper_hit", "fx")
tt.render.sprites[1].name = "dreadeye_viper_ranged_attack_hit"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1

local b = balance.enemies.cult_of_the_overseer.acolyte

tt = E:register_t("enemy_acolyte", "enemy")

E:add_comps(tt, "melee", "death_spawns")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_enemies_0013"
tt.main_script.update = scripts.enemy_acolyte.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_fx = "enemy_acolyte_attack_fx"
tt.melee.attacks[1].hit_fx_offset = v(15, 10)
tt.motion.max_speed = b.speed
tt.death_spawns.name = "enemy_acolyte_tentacle"
tt.death_spawns.death_animation = "sacrifice"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(28)
tt.death_spawns.dead_lifetime = 5
tt.render.sprites[1].prefix = "acolyte"
tt.health_bar.offset = v(0, 30)
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.unit.hide_after_death = true
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.enemy.melee_slot = v(18, 0)
tt.sound_death_with_spawn = "EnemyAcolyteDeathSpecial"
tt.sound_death_no_spawn = "EnemyAcolyteDeath"
tt = E:register_t("enemy_acolyte_attack_fx", "fx")
tt.render.sprites[1].name = "acolyte_attack_hit_fx"
tt = E:register_t("enemy_acolyte_tentacle", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = 0
tt.motion.max_speed = 0
tt.health.hp_max = b.tentacle.hp
tt.health.armor = b.tentacle.armor
tt.health.magic_armor = b.tentacle.magic_armor
tt.info.fn = scripts.enemy_acolyte_tentacle.get_info
tt.info.portrait = "kr5_info_portraits_enemies_0024"
tt.info.enc_icon = 13
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
tt.health_bar.offset = v(0, 34)
tt.unit.hit_offset = v(0, 8)
tt.unit.head_offset = v(0, 8)
tt.unit.mod_offset = v(0, 18)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-18, -3, 36, 35)
tt.enemy.melee_slot = v(24, 0)
tt.sound_events.death = "EnemyAcolyteTentacleDeath"
tt = E:register_t("acolyte_tentacle_aura", "aura")
tt.aura.cycles = 1
tt.aura.damage_min = b.tentacle.hit.damage_min
tt.aura.damage_max = b.tentacle.hit.damage_max
tt.aura.damage_type = DAMAGE_PHYSICAL
tt.aura.radius = b.tentacle.hit.radius
tt.aura.vis_bans = bor(F_ENEMY)
tt.main_script.update = scripts.aura_apply_damage.update
tt = E:register_t("enemy_lesser_sister", "enemy")

local b = balance.enemies.cult_of_the_overseer.lesser_sister

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(15, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 38)
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "lesser_sister"
tt.sound_events.death = "EnemyTwistedSisterDeath"
tt.info.i18n_key = "ENEMY_LESSER_SISTER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0014"
tt.main_script.update = scripts.enemy_lesser_sister.update
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(18)
tt.ranged.attacks[1].bullet = "lesser_sister_bolt"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 13)}
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

tt.particle_system.anchor = v(0.5, 0.45)
tt.particle_system.name = "lesser_sister_bolt_trail"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {fts(8), fts(8)}
tt.particle_system.emission_rate = 30
tt.particle_system.z = Z_BULLET_PARTICLES
tt.particle_system.scales_y = {0.8, 0.5}
tt = E:register_t("enemy_lesser_sister_nightmare", "enemy")

E:add_comps(tt, "melee", "count_group", "tween")

tt.enemy.gold = 0
tt.enemy.lives_cost = b.nightmare.lives_cost
tt.count_group.name = "enemy_lesser_sister_nightmare"
tt.main_script.update = scripts.enemy_lesser_sister_nightmare.update
tt.motion.max_speed = b.nightmare.speed
tt.health.hp_max = b.nightmare.hp
tt.health.armor = b.nightmare.armor
tt.health.magic_armor = b.nightmare.magic_armor
tt.health.dead_lifetime = fts(18)
tt.info.enc_icon = 15
tt.info.portrait = "kr5_info_portraits_enemies_0015"
tt.vis.flags = 0
tt.vis.flags_unblocked = bor(F_NIGHTMARE, F_ENEMY)
tt.vis.flags_blocked = F_ENEMY
tt.melee.attacks[1].cooldown = b.nightmare.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.nightmare.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.nightmare.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].hit_fx = "enemy_lesser_sister_nightmare_hit_fx"
tt.melee.attacks[1].hit_fx_offset = v(25, 5)
tt.melee.range = 51.2
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "lesser_sister_nightmare"
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.sound_events.insert = "EnemyTwistedSisterSummonSpawn"
tt.sound_events.death = "EnemyNightmareDeath"
tt.enemy.melee_slot = v(23, 0)
tt.health_bar.offset = v(0, 35)
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 18)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_VIOLET
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(10), 100}}
tt.tween.remove = false
tt.can_be_converted = false
tt.nodes_to_reveal = 40

local tt = E:register_t("enemy_lesser_sister_nightmare_hit_fx", "fx")

tt.render.sprites[1].name = "lesser_sister_nightmare_hit_fx"
tt = E:register_t("enemy_small_stalker", "enemy")

E:add_comps(tt, "tween")

local b = balance.enemies.cult_of_the_overseer.small_stalker

tt.info.enc_icon = 16
tt.info.portrait = "kr5_info_portraits_enemies_0038"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.on_damage = scripts.enemy_small_stalker.on_damage
tt.main_script.update = scripts.enemy_small_stalker.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "small_stalker_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].alpha = 0
tt.ui.click_rect = r(-15, tt.flight_height - 5, 30, 40)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 5)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 2)
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
tt = E:register_t("enemy_unblinded_priest", "enemy")

local b = balance.enemies.cult_of_the_overseer.unblinded_priest

E:add_comps(tt, "melee", "ranged", "death_spawns", "glare_kr5")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 17
tt.info.portrait = "kr5_info_portraits_enemies_0017"
tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
tt.main_script.update = scripts.enemy_unblinded_priest.update
tt.melee.attacks[1].animation = "attack_melee"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_priest_hit_melee"
tt.melee.attacks[1].hit_fx_offset = v(18, 20)
tt.ranged.attacks[1].animation = "attack_ranged"
tt.ranged.attacks[1].bullet = "bullet_enemy_unblinded_priest"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(25)
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].max_range_variance = 60
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].bullet_start_offset = {v(0, 40)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.motion.max_speed = b.speed
tt.health_trigger_factor = b.health_trigger_factor
tt.death_spawns.name = "enemy_unblinded_abomination"
tt.death_spawns.death_animation = "transformation_end"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(32)
tt.death_spawns.dead_lifetime = 0
tt.render.sprites[1].prefix = "unblinded_priest"
tt.health_bar.offset = v(0, 39)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.enemy.melee_slot = v(18, 0)
tt.glare_kr5.transform_name = "enemy_unblinded_abomination"
tt.glare_kr5.transform_animation = "transformation_full"
tt.glare_kr5.on_start_glare = scripts.enemy_unblinded_priest.on_start_glare
tt.transformation_time = b.transformation_time
tt.transformation_sound = "EnemyUnblindedPriestTransformCast"
tt.transformation_end_sound = "EnemyUnblindedPriestTransformSpawn"
tt.sound_events.death = "EnemyUnblindedPriestDeath"
tt.ui.click_rect = r(-20, -3, 40, 35)

tt = E:register_t("bullet_enemy_unblinded_priest", "bolt_enemy")
b = balance.enemies.cult_of_the_overseer.unblinded_priest
tt.render.sprites[1].prefix = "unblinded_priest_projectile"
tt.render.sprites[1].anchor = v(0.5, 0.5)
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

tt = E:register_t("enemy_unblinded_abomination", "enemy")
b = balance.enemies.cult_of_the_overseer.unblinded_priest.abomination

E:add_comps(tt, "melee", "glare_kr5")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 50)
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "unblinded_abomination_unblinded_abomination"
tt.info.enc_icon = 18
tt.info.portrait = "kr5_info_portraits_enemies_0018"
tt.eat = {}
tt.eat.hp_required = b.eat.hp_required
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_abomination_hit_melee"
tt.melee.attacks[1].hit_fx_offset = v(40, 20)
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

tt = E:register_t("mod_enemy_unblinded_abomination_eat", "modifier")
b = balance.enemies.cult_of_the_overseer.unblinded_priest
tt.main_script.queue = scripts.mod_enemy_unblinded_abomination_eat.queue
tt.main_script.update = scripts.mod_enemy_unblinded_abomination_eat.update
tt.explode_fx = "fx_enemy_unblinded_abomination_eat"
tt.required_hp = b.abomination.eat.hp_required

tt = E:register_t("enemy_unblinded_abomination_stage_8", "enemy")
b = balance.enemies.cult_of_the_overseer.abomination_stage_8
E:add_comps(tt, "melee", "regen")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 50)
tt.regen.cooldown = b.regen_cooldown
tt.regen.health = b.regen_health
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "Abomination2Def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].exo = true
tt.info.enc_icon = 10
tt.info.portrait = "kr5_info_portraits_enemies_0028"
tt.info.i18n_key = "ENEMY_UNBLINDED_ABOMINATION_STAGE_8"
tt.main_script.update = scripts.enemy_unblinded_abomination_stage_8.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_enemy_unblinded_abomination_hit_melee"
tt.melee.attacks[1].hit_fx_offset = v(40, 20)
tt.idle_cooldown_min = 7
tt.idle_cooldown_max = 12
tt.sleep_cooldown = 20
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED)
tt.sound_events.death = "EnemyAbominationDeath"
tt = E:register_t("enemy_unblinded_abomination_stage_8_lifebar")

E:add_comps(tt, "health_bar", "pos", "render", "health")

tt.render.sprites[1].name = "square_ffffff"
tt.render.sprites[1].animated = false
tt.render.sprites[1].scale = v(0, 0)
tt = E:register_t("enemy_spiderling", "enemy")
b = balance.enemies.cult_of_the_overseer.spiderling

E:add_comps(tt, "melee", "cliff")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0022"
tt.info.i18n_key = "ENEMY_SPIDERLING"
tt.main_script.update = scripts.enemy_spiderling.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(9)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "spider"
tt.ui.click_rect = r(-20, -3, 40, 30)
tt.health_bar.offset = v(0, 25)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 3)
tt.enemy.melee_slot = v(18, 0)
tt.transformation_time = b.transformation_time
tt.cliff.fall_accel = 400
tt.sound_events.death = "EnemySpiderlingDeath"
tt = E:register_t("enemy_unblinded_shackler", "enemy")
b = balance.enemies.cult_of_the_overseer.unblinded_shackler

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(33, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 1
tt.health_bar.offset = v(0, 41)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.fade_time_after_death = 1
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "unblinded_shackler_creep"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.info.i18n_key = "ENEMY_UNBLINDED_SHACKLER"
tt.info.enc_icon = 19
tt.info.portrait = "kr5_info_portraits_enemies_0019"
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
tt = E:register_t("enemy_armored_nightmare", "enemy")
b = balance.enemies.cult_of_the_overseer.armored_nightmare

E:add_comps(tt, "melee", "death_spawns")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(32, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.unit.size = UNIT_SIZE_MEDIUM
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 22
tt.info.portrait = "kr5_info_portraits_enemies_0023"
tt.main_script.update = scripts.enemy_armored_nightmare.update
tt.melee.cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_enemy_armored_nightmare_hit"
tt.melee.attacks[1].hit_fx_offset = v(tt.enemy.melee_slot.x, 5)
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
tt.health_bar.offset = v(0, 49)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.unit.blood_color = BLOOD_NONE
tt.sound_events.death = "EnemyBoundNightmareDeath"
tt = E:register_t("enemy_corrupted_stalker", "enemy")

local b = balance.enemies.cult_of_the_overseer.corrupted_stalker

tt.info.enc_icon = 20
tt.info.portrait = "kr5_info_portraits_enemies_0020"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 47
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.main_script.update = scripts.enemy_corrupted_stalker.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "corrupted_stalker_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "corrupted_stalker_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-25, tt.flight_height - 15, 50, 50)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.sound_events.death = "EnemyCorruptedStalkerDeath"
tt = E:register_t("enemy_crystal_golem", "enemy")

local b = balance.enemies.cult_of_the_overseer.crystal_golem

E:add_comps(tt, "melee")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0021"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.main_script.update = scripts.enemy_crystal_golem.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_decal = "fx_enemy_crystal_golem_ground_decal"
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "crystal_golem_creep"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.sound_events.death = "EnemyBearVanguardDeath"
tt.ui.click_rect = r(-28, 0, 56, 53)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.start_as_rock = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED)
tt.sound_events.death = "EnemyCrystalGolemDeath"
tt.wake_up_sound = "Stage10ObeliskEffectGolemSpawnGolem"
tt = E:register_t("enemy_stage_11_cult_leader_illusion", "enemy")

local b = balance.specials.stage11_cult_leader.illusion

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.ui.click_rect = r(-23, 0, 46, 60)
tt.enemy.melee_slot = v(15, 0)
tt.health.hp_max = b.hp_max
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health_bar.offset = v(0, 70)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 31)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.motion.max_speed = b.max_speed
tt.sound_events.death = "Stage11MydriasIllusionDeath"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0026"
tt.main_script.update = scripts.enemy_stage_11_cult_leader_illusion.update
tt.melee.range = 72
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_stage_11_cult_leader_attack_hit"
tt.melee.attacks[1].hit_fx_offset = v(25, 35)
tt.ranged.attacks[1].bullet = "bullet_stage_11_cult_leader_illusion"
tt.ranged.attacks[1].bullet_start_offset = {v(25, 45)}
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

tt = E:register_t("bullet_stage_11_cult_leader_illusion", "bolt_enemy")
local b = balance.specials.stage11_cult_leader.illusion
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "mydrias_proyectile"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
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

tt = E:register_t("enemy_blinker", "enemy")
E:add_comps(tt, "glare_kr5", "ranged")
local b = balance.enemies.void_beyond.blinker
tt.info.enc_icon = 16
tt.info.portrait = "kr5_info_portraits_enemies_0016"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_blinker.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
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
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.9)
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
tt.ranged.attacks[1].bullet_start_offset = {v(0, tt.flight_height + 5)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.ranged.attacks[1].animation = "stun"
tt.ranged.attacks[1].fx_normal = "fx_enemy_blinker_attack"
tt.ranged.attacks[1].fx_glare = "fx_enemy_blinker_attack_glare"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 5)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 2)
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
tt.render.sprites[1].anchor = v(0.5, 0.9)
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.25, 255}}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt = E:register_t("aura_enemy_blinker_glare", "aura_enemy_blinker")
tt.aura.mods = {"mod_enemy_blinker_stun", "mod_enemy_blinker_glare"}
tt.render.sprites[1].prefix = "blinker_glare_decal"

tt = E:register_t("enemy_mindless_husk", "enemy")

local b = balance.enemies.void_beyond.mindless_husk

E:add_comps(tt, "melee", "glare_kr5")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0030"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.enemy_mindless_husk.update
tt.render.sprites[1].prefix = "mindless_husk_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(10)
tt.ui.click_rect = r(-15, 0, 30, 40)
tt.unit.hit_offset = v(-2, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 10)
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
tt.start_offset = v(0, 25)
tt.min_nodes_ahead = b.min_nodes_ahead
tt.max_nodes_ahead = b.max_nodes_ahead
tt.sound_spawn = "EnemyMindlessHuskSpawnDeath"
tt = E:register_t("enemy_glareling", "enemy")
b = balance.enemies.cult_of_the_overseer.glareling

E:add_comps(tt, "melee", "glare_kr5")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0029"
tt.main_script.update = scripts.enemy_glareling.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(15)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "glearling_character"
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.render.sprites[1].scale = v(0.81, 0.81)
tt.ui.click_rect = r(-20, -3, 40, 30)
tt.health_bar.offset = v(0, 25)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 6)
tt.enemy.melee_slot = v(18, 0)
tt.transformation_time = b.transformation_time
tt.glare_kr5.regen_hp = b.glare.regen_hp
tt.glare_kr5.speed_factor = b.glare.speed_factor
tt.sound_events.death = "EnemyGlarelingDeath"
tt.sound_events.sacrifice = "Stage14BehemothPoolSplash"
tt = E:register_t("enemy_vile_spawner", "enemy")
b = balance.enemies.void_beyond.vile_spawner

E:add_comps(tt, "melee", "timed_attacks", "tween", "glare_kr5")

tt.flight_height = 2
tt.fly_strenght = 5
tt.fly_frequency = 13
tt.info.enc_icon = 5
tt.info.portrait = "kr5_info_portraits_enemies_0031"
tt.unit.mod_offset = v(0, 16)
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.marker_offset = v(-1, -1)
tt.ui.click_rect = r(-25, 0, 50, 60)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 62)
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
tt.render.sprites[1].offset = v(0, 8)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "big_shadow"
tt.render.sprites[2].offset = v(0, 0)
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
tt.timed_attacks.list[1].bullet_start_offset = v(-5, 50)
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
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].sprite_id = 1
tt.sound_events.death = "EnemyVileSpawnerDeath"
tt.sound_events.spawn_cast = "EnemyVileSpawnerSpawnCast"
tt = E:register_t("enemy_lesser_eye", "enemy")
b = balance.enemies.void_beyond.lesser_eye

E:add_comps(tt, "count_group", "tween", "glare_kr5")

tt.info.enc_icon = 16
tt.info.portrait = "kr5_info_portraits_enemies_0032"
tt.enemy.gold = b.gold
tt.count_group.name = "enemy_lesser_eye"
tt.flight_height = 47
tt.fly_strenght = 5
tt.fly_frequency = 13
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 33)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_lesser_eye.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "lesser_eye_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.8)
tt.ui.click_rect = r(-15, tt.flight_height - 20, 30, 38)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 5)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 2)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].sprite_id = 1
tt.glare_kr5.regen_hp = b.glare.regen_hp
tt.sound_events.death = "EnemyLesserEyeDeath"
tt = E:register_t("enemy_noxious_horror", "enemy")

local b = balance.enemies.void_beyond.noxious_horror

E:add_comps(tt, "melee", "ranged", "glare_kr5")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0034"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = b.speed
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
tt.ranged.attacks[1].bullet_start_offset = {v(18, 31)}
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].animation = "attack_range"
tt.ui.click_rect = r(-20, 0, 40, 35)
tt.unit.hit_offset = v(-2, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(F_ENEMY)
tt.glare_kr5.regen_hp = b.glare.regen_hp
tt.glare_kr5.on_start_glare = scripts.enemy_noxious_horror.on_start_glare
tt.glare_kr5.on_end_glare = scripts.enemy_noxious_horror.on_end_glare
tt.glare_kr5.magic_armor = b.glare.magic_armor
tt.glare_kr5.aura_poison = "aura_enemy_noxious_horror_glare"
tt.sound_events.death = "EnemyNoxiousHorrorDeath"

-- 骇人刃爪
tt = E:register_t("enemy_hardened_horror", "enemy")
local b = balance.enemies.void_beyond.hardened_horror
E:add_comps(tt, "melee", "glare_kr5")
tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0033"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.enemy_hardened_horror.update
tt.render.sprites[1].prefix = "hardened_horror_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].scale = vv(1.1)
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_times = {fts(14), fts(20)}
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_enemy_hardened_horror_hit"
tt.melee.attacks[1].hit_offset = v(40, 13)
tt.ui.click_rect = r(-25, -3, 50, 43)
tt.unit.hit_offset = v(-2, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 10)
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

tt = E:register_t("enemy_evolving_scourge", "enemy")
local b = balance.enemies.void_beyond.evolving_scourge
E:add_comps(tt, "melee", "tween", "glare_kr5")
tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0035"
tt.enemy.gold = b.gold[1]
tt.enemy.melee_slot = v(25, 0)
tt.enemy.lives_cost = b.lives_cost
tt.gold_config = b.gold
tt.health.hp_max = b.hp[1]
tt.hp_config = b.hp
tt.flight_height = 40
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar_offset_config = {v(0, 35), v(0, 40), v(0, 50 + tt.flight_height)}
tt.health_bar_type_config = {HEALTH_BAR_SIZE_MEDIUM, HEALTH_BAR_SIZE_MEDIUM_MEDIUM, HEALTH_BAR_SIZE_LARGE}
tt.motion.max_speed = b.speed[1]
tt.speed_config = b.speed
tt.main_script.update = scripts.enemy_evolving_scourge.update
tt.render.sprites[1].prefix = "evolving_scourge_fase1"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
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
tt.unit.hit_offset = v(-5, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.flags = bor(F_ENEMY)
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{0, v(0, 0)}, {1, v(0, tt.flight_height)}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{0, vv(2)}, {1, vv(1.3)}}
tt.glare_kr5.regen_hp = b.glare.regen_hp
tt.glare_kr5.on_start_glare = scripts.enemy_evolving_scourge.on_start_glare
tt.glare_kr5.armor = b.glare.armor
tt.sound_events.evolve = "EnemyEvolvingScourgeEvolve"
tt.sound_events.death = "EnemyEvolvingScourgeDeath"

-- 血壤巨兽
tt = E:register_t("enemy_amalgam", "enemy")
b = balance.enemies.void_beyond.amalgam
E:add_comps(tt, "melee", "glare_kr5", "death_spawns")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0039"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_decal = "decal_enemy_amalgam_hit"
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "Amalgam_dude"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.ui.click_rect = r(-32, -3, 64, 60)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
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
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED)

tt = E:register_t("enemy_corrupted_elf", "enemy")
b = balance.enemies.undying_hatred.corrupted_elf

E:add_comps(tt, "melee", "ranged", "death_spawns")

tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_enemies_0044"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 35)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_corrupted_elf.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].animation_in = "attack_2_in"
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].animation_out = "attack_2_out"
tt.motion.max_speed = b.speed
tt.ranged.attacks[1].animations = {"attack_1_in", "attack_1", "attack_1_out"}
tt.ranged.attacks[1].bullet = "bullet_enemy_corrupted_elf"
tt.ranged.attacks[1].bullet_start_offset = {v(5, 23), v(5, 23), v(5, 23)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].shoot_times = {fts(7), fts(13), fts(18)}
tt.ranged.attacks[1].loops = 1
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].prefix = "corrupted_ranger_creep"
tt.sound_events.death = "EnemyCorruptedElfDeath"
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 14)
tt.unit.blood_color = BLOOD_GRAY
tt.ui.click_rect = r(-16, -3, 32, 30)
tt.spawn_nodes_limit = b.spawn_nodes_limit
tt.death_spawns.name = "enemy_specter"
tt.death_spawns.death_animation = "death"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(25)
tt.death_spawns.dead_lifetime = 0
tt.sound_specter_spawn = "EnemyCorruptedElfSpawn"
tt = E:register_t("enemy_specter", "enemy")
b = balance.enemies.undying_hatred.specter

E:add_comps(tt, "melee", "count_group")

tt.enemy.gold = 0
tt.enemy.lives_cost = b.lives_cost
tt.count_group.name = "enemy_specter"
tt.main_script.insert = scripts.enemy_specter.insert
tt.main_script.update = scripts.enemy_specter.update
tt.main_script.remove = scripts.enemy_specter.remove
tt.motion.max_speed = b.speed
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = fts(18)
tt.info.enc_icon = 15
tt.info.portrait = "kr5_info_portraits_enemies_0045"
tt.vis.flags = F_ENEMY
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(19)
tt.melee.attacks[1].hit_fx = "fx_enemy_specter_hit"
tt.melee.attacks[1].hit_fx_offset = v(25, 5)
tt.melee.attacks[1].animation = "attack_1"
tt.melee.range = 51.2
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "spectre_specter"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.ui.click_rect = r(-18, -3, 36, 35)
tt.sound_events.death = "EnemySpecterDeath"
tt.enemy.melee_slot = v(23, 0)
tt.health_bar.offset = v(0, 35)
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 18)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hide_after_death = true
tt.animation_corrupt = "crash"
tt.speed_chase = b.speed_chase
tt.angles_chase = {"walk_fast"}
tt.chase_trail = "ps_enemy_specter_chase_trail"
tt.chase_dist = 110
tt.chase_delay = fts(30)
tt.sound_rush_anticipation = "EnemySpecterRushAnticipation"
tt.sound_rush = "EnemySpecterRush"
tt.sound_corruption = "EnemySpecterCorruption"
tt = E:register_t("enemy_dust_cryptid", "enemy")

E:add_comps(tt, "death_spawns")

local b = balance.enemies.undying_hatred.dust_cryptid

tt.info.enc_icon = 20
tt.info.portrait = "kr5_info_portraits_enemies_0047"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 40
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_dust_cryptid.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "dust_cryptid_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 5, 36, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_ORANGE
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.sound_events.death = "EnemyDustCryptidDeath"
tt.death_spawns.name = "aura_enemy_dust_cryptid"
tt.death_spawns.death_animation = "death"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.delay = fts(9)
tt.death_spawns.dead_lifetime = 0
tt.nodes_to_prevent_dust = b.nodes_to_prevent_dust
tt = E:register_t("enemy_bane_wolf", "enemy")
local b = balance.enemies.undying_hatred.bane_wolf
E:add_comps(tt, "melee", "auras")
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_damage_sprint"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 35)
tt.info.portrait = "kr5_info_portraits_enemies_0046"
tt.info.enc_icon = 29
tt.main_script.update = scripts.enemy_mixed_cliff.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "bane_wolf_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = v(0, 16)
tt.unit.mod_offset = v(0, 20)
tt.damage_sprint_factor = b.max_speed_mult - 1
tt.ui.click_rect = r(-18, -3, 36, 35)
tt.sound_events.death = "EnemyBaneWolfDeath"
tt = E:register_t("enemy_deathwood", "enemy")

local b = balance.enemies.undying_hatred.deathwood

E:add_comps(tt, "melee", "ranged")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0048"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.main_script.update = scripts.enemy_deathwood.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_fx = "fx_enemy_deathwood_hit"
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].hit_offset = v(45, 10)
tt.melee.attacks[1].animation = "melee"
tt.ranged.attacks[1].bullet = "bullet_enemy_deathwood"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(23)
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].max_range_variance = 60
tt.ranged.attacks[1].bullet_start_offset = {v(0, 31)}
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING)
tt.ranged.attacks[1].animation = "throw_attack"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "deathwood_creep"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyDeathwoodDeath"
tt.ui.click_rect = r(-25, 0, 50, 50)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.start_as_rock = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED)
tt.sound_events.death = "EnemyDeathwoodDeath"

tt = E:register_t("enemy_animated_armor", "enemy")
b = balance.enemies.undying_hatred.animated_armor
E:add_comps(tt, "melee", "corruption_kr5")
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.main_script.insert = scripts.enemy_animated_armor.insert
tt.main_script.update = scripts.enemy_animated_armor.update
tt.motion.max_speed = b.speed
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = fts(18)
tt.health.ignore_delete_after = true
tt.info.enc_icon = 15
tt.info.portrait = "kr5_info_portraits_enemies_0052"
tt.vis.flags = F_ENEMY
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_time = fts(29)
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.melee.range = 51.2
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "armor"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-18, -3, 36, 35)
tt.sound_events.death = "EnemyAnimatedArmorDeath"
tt.enemy.melee_slot = v(23, 0)
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 18)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.fade_time_after_death = b.death_duration + 5
tt.death_duration = b.death_duration
tt.respawn_health_factor = b.respawn_health_factor
tt.respawn_sound = "EnemyAnimatedArmorRevive"
tt.corruption_kr5.limit = 1
tt.corruption_kr5.on_corrupt = scripts.enemy_animated_armor.on_corrupt
tt.corruption_kr5.enabled = false

tt = E:register_t("enemy_revenant_soulcaller", "enemy")
local b = balance.enemies.undying_hatred.revenant_soulcaller
E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 43)
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "revenant_soulcaller_unit"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.sound_events.death = "EnemyRevenantSoulcallerDeath"
tt.info.i18n_key = "ENEMY_REVENANT_SOULCALLER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0051"
tt.main_script.update = scripts.enemy_revenant_soulcaller.update
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].animation = "melee"
tt.ranged.attacks[1].bullet = "bullet_enemy_revenant_soulcaller"
tt.ranged.attacks[1].bullet_start_offset = {v(-10, 50)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_time = fts(24)
tt.ranged.attacks[1].animation = "stun"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].cooldown = b.summon.cooldown
tt.timed_attacks.list[1].range = b.summon.max_range
tt.timed_attacks.list[1].entity = "enemy_specter"
tt.timed_attacks.list[1].spawn_delay = 0
tt.timed_attacks.list[1].sound = "EnemyCorruptedElfSpawn"
tt.timed_attacks.list[1].count_group_name = "enemy_specter"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.summon.max_total
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation = "stun"
tt.timed_attacks.list[2].cast_time = fts(24)
tt.timed_attacks.list[2].cooldown = b.tower_stun.cooldown
tt.timed_attacks.list[2].max_range = b.tower_stun.max_range
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].bullet = "bullet_enemy_revenant_soulcaller_tower_stun"
tt.timed_attacks.list[2].bullet_start_offset = tt.ranged.attacks[1].bullet_start_offset
tt.timed_attacks.list[2].mark_mod = "mod_enemy_revenant_soulcaller_mark"
tt.nodes_limit = b.summon.nodes_limit
tt.node_random_min = b.summon.nodes_random_min
tt.node_random_max = b.summon.nodes_random_max
tt = E:register_t("enemy_revenant_harvester", "enemy")

local b = balance.enemies.undying_hatred.revenant_harvester

E:add_comps(tt, "melee", "timed_attacks", "count_group")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.count_group.name = "enemy_revenant_harvester"
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 47)
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 10)
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.ui.click_rect = r(-17, -3, 34, 40)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "harvester_harvester"
tt.sound_events.death = "EnemyRevenantHarvesterDeath"
tt.info.i18n_key = "ENEMY_REVENANT_HARVESTER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0053"
tt.main_script.update = scripts.enemy_revenant_harvester.update
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_enemy_revenant_harvester_hit"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "cloning"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = b.clone.cooldown
tt.timed_attacks.list[1].range = b.clone.max_range
tt.timed_attacks.list[1].entity = "enemy_specter"
tt.timed_attacks.list[1].spawn_delay = 0
tt.timed_attacks.list[1].sound = "EnemyRevenantHarvesterClone"
tt.timed_attacks.list[1].count_group_name = "enemy_revenant_harvester"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.clone.max_total
tt.timed_attacks.list[1].mark_mod = "mod_enemy_revenant_harvester_mark"
tt.nodes_limit = b.clone.nodes_limit
tt = E:register_t("enemy_crocs_basic_egg", "enemy")

local b = balance.enemies.crocs.crocs_basic_egg

E:add_comps(tt, "water")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 2
tt.info.portrait = "kr5_info_portraits_enemies_0056"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_crocs_basic_egg.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "crokinder_creep"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.evolve = "EnemyCrokinderEvolve"
tt.sound_events.death = "EnemyCrokinderDeath"
tt.ui.click_rect = r(-12, 0, 24, 25)
tt.evolve_cooldown_min = b.evolve.cooldown_min
tt.evolve_cooldown_max = b.evolve.cooldown_max
tt.evolve_mod = "mod_chicken_leg_polymorph"
tt.can_evolve_chicken_leg = true
tt.vis.bans = bor(F_BLOCK)
tt.unit.blood_color = BLOOD_NONE
tt.transform_anim = "transform"
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_fixed_speed = b.water_fixed_speed

local b = balance.enemies.crocs.crocs_basic

tt = E:register_t("enemy_crocs_basic", "enemy")
E:add_comps(tt, "melee", "water")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 1
tt.info.portrait = "kr5_info_portraits_enemies_0057"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_crocs_basic.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "gator_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)
tt.evolve_mod = "mod_chicken_leg_polymorph"
tt.evolve_sound = "EnemyCrocsBasicEvolve"
tt.can_evolve_chicken_leg = false
tt.transform_anim = "transform"
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_fixed_speed = b.water_fixed_speed

local b = balance.enemies.crocs.quickfeet_gator

tt = E:register_t("enemy_quickfeet_gator_chicken_leg", "enemy")

E:add_comps(tt, "melee", "ranged", "timed_attacks", "water")

tt.info.i18n_key = "ENEMY_CROCS_QUICKFEET_GATOR"
tt.info.enc_icon = 5
tt.info.portrait = "kr5_info_portraits_enemies_0059"
tt.unit.mod_offset = v(0, 14)
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.marker_offset = v(-1, -1)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 63)
tt.health.dead_lifetime = 3
tt.unit.fade_time_after_death = 2
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_quickfeet_gator.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].sound = "EnemyQuickfeetMelee"
tt.ranged.attacks[1].bullet = "bullet_quickfeet_gator_bone"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(2)
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].max_range_variance = 60
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].bullet_start_offset = {v(14, 33)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].animation = "ability"
tt.ranged.attacks[1].disabled = true
tt.ranged.attacks[1].sound = "EnemyQuickfeetRanged"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "quickfeet_gator_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "quickfeet_gator_chicken_leg_bullet"
tt.timed_attacks.list[1].mark_mod = "mod_chicken_leg_polymorph_mark"
tt.timed_attacks.list[1].cast_time = fts(2)
tt.timed_attacks.list[1].node_prediction_base = -fts(3)
tt.timed_attacks.list[1].bullet_start_offset = {v(25, 46), v(-25, 46)}
tt.timed_attacks.list[1].animation = "ability"
tt.timed_attacks.list[1].new_anim_prefix = "quickfeet_gator_creep_no_chicken"
tt.timed_attacks.list[1].new_health_bar_offset = v(0, 42)
tt.timed_attacks.list[1].cooldown = 0.2
tt.timed_attacks.list[1].target_nodes_from_start = b.chicken_leg.target_nodes_from_start
tt.timed_attacks.list[1].self_nodes_from_start = b.chicken_leg.self_nodes_from_start
tt.timed_attacks.list[1].max_count = 1
tt.timed_attacks.list[1].min_range = b.chicken_leg.min_range
tt.timed_attacks.list[1].max_range = b.chicken_leg.max_range
tt.timed_attacks.list[1].min_flight_time = fts(12)
tt.timed_attacks.list[1].max_flight_time = fts(24)
tt.timed_attacks.list[1].sound = "EnemyQuickfeetRanged"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_CUSTOM)
tt.timed_attacks.list[1].allowed_templates = {"enemy_crocs_basic"}
tt.timed_attacks.list[1].disabled = false
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_fixed_speed = b.water_fixed_speed
tt = E:register_t("enemy_quickfeet_gator", "enemy_quickfeet_gator_chicken_leg")
tt.health_bar.offset = tt.timed_attacks.list[1].new_health_bar_offset
tt.render.sprites[1].prefix = tt.timed_attacks.list[1].new_anim_prefix
tt.ranged.attacks[1].disabled = false
tt.timed_attacks.list[1].disabled = true

local b = balance.enemies.crocs.killertile

tt = E:register_t("enemy_killertile", "enemy")

E:add_comps(tt, "melee", "water")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.dead_lifetime = 1.3
tt.unit.size = UNIT_SIZE_MEDIUM
tt.info.enc_icon = 2
tt.info.portrait = "kr5_info_portraits_enemies_0058"
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 40)
tt.unit.mod_offset = v(0, 20)
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_killertile.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].sound = "EnemyKillertileMelee"
tt.melee.attacks[1].hit_time = fts(13)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "killertile_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-20, 0, 40, 42)
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water_fixed_speed = b.water_fixed_speed
tt.water.remove_modifiers = true
tt.water.hide_sprites_range = {}
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_particles_scale_var = {1.6, 1.9}

local b = balance.enemies.crocs.crocs_flier

tt = E:register_t("enemy_crocs_flier", "enemy")

E:add_comps(tt, "tween")

tt.info.enc_icon = 6
tt.info.portrait = "kr5_info_portraits_enemies_0063"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.fly_strenght = -5
tt.fly_frequency = 8
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 40)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_crocs_flier.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "winged_crock_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.8)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 10, 36, 28)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 2)
tt.unit.head_offset = v(0, tt.flight_height + 6)
tt.unit.mod_offset = v(0, tt.flight_height)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "quad"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = false
tt.tween.props[1].remove = false
tt = E:register_t("enemy_crocs_ranged", "enemy")

E:add_comps(tt, "melee", "ranged", "water")

b = balance.enemies.crocs.crocs_ranged
tt.info.enc_icon = 7
tt.info.portrait = "kr5_info_portraits_enemies_0060"
tt.unit.hit_offset = v(0, 11)
tt.unit.head_offset = v(0, 19)
tt.unit.mod_offset = v(0, 11)
tt.ui.click_rect = r(-21, 0, 35, 30)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 35)
tt.main_script.insert = scripts.enemy_crocs_ranged.insert
tt.main_script.update = scripts.enemy_crocs_ranged.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].animation = "attack_02"
tt.melee.attacks[1].sound = "EnemyCrocsRangedMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "ranged_croc_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.ranged.attacks[1].bullet = "bullet_ranged_crocs"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(9)
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].max_range_variance = 60
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].bullet_start_offset = {v(0, 28)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].animation = "attack_01"
tt.ranged.attacks[1].sound = "EnemyCrocsRangedShot"
tt.unit.blood_color = BLOOD_GREEN
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_fixed_speed = b.water_fixed_speed
tt = E:register_t("enemy_crocs_shaman", "enemy")

local b = balance.enemies.crocs.crocs_shaman

E:add_comps(tt, "melee", "ranged", "timed_attacks", "water")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(40, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "shaman_creep"
tt.render.sprites[1].angles.walk = {"walk_side", "walk_up", "walk_down"}
tt.render.sprites[1].offset = v(-2, 1)
tt.info.i18n_key = "ENEMY_CROCS_SHAMAN"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0061"
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_crocs_shaman.update
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(9)
tt.melee.attacks[1].animation = "attack_melee"
tt.ranged.attacks[1].bullet = "bullet_crocs_shaman"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 80)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].animation = "attack_range"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(32)
tt.timed_attacks.list[1].cooldown = b.healing.cooldown
tt.timed_attacks.list[1].range = b.healing.range
tt.timed_attacks.list[1].min_targets = b.healing.min_targets
tt.timed_attacks.list[1].max_targets = b.healing.max_targets
tt.timed_attacks.list[1].mod = "mod_enemy_crocs_shaman_healing"
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].vis_flags = F_CUSTOM
tt.timed_attacks.list[2].animation = "attack_block"
tt.timed_attacks.list[2].cast_time = fts(20)
tt.timed_attacks.list[2].cooldown = b.debuff_towers.cooldown
tt.timed_attacks.list[2].max_range = b.debuff_towers.max_range
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].mod = "mod_crocs_shaman_tower_debuff"
tt.timed_attacks.list[2].mark_mod = "mod_enemy_crocs_shaman_tower_mark"
tt.timed_attacks.list[2].nodes_limit = b.debuff_towers.nodes_limit
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_particles_scale_var = {1.6, 1.9}
tt.water_fixed_speed = b.water_fixed_speed

local b = balance.enemies.crocs.crocs_tank

tt = E:register_t("enemy_crocs_tank", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(42, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.info.enc_icon = 10
tt.info.portrait = "kr5_info_portraits_enemies_0062"
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 50)
tt.unit.mod_offset = v(0, 17)
tt.main_script.update = scripts.enemy_crocs_tank.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].hit_fx = "fx_crocs_tank_melee_hit"
tt.melee.attacks[1].hit_offset = v(44, 15)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cast_time = fts(15)
tt.timed_attacks.list[1].animation_start = "in_attack_1"
tt.timed_attacks.list[1].animation_end = "out_attack_1"
tt.timed_attacks.list[1].blocker_charge_delay = b.charge.blocker_charge_delay
tt.timed_attacks.list[1].cooldown = b.charge.cooldown
tt.timed_attacks.list[1].duration = b.charge.duration
tt.timed_attacks.list[1].min_distance_from_end = b.charge.min_distance_from_end
tt.timed_attacks.list[1].speed = b.charge.speed
tt.timed_attacks.list[1].vis_flags = F_FRIEND
tt.timed_attacks.list[1].vis_bans = bor(F_HERO, F_FLYING)
tt.timed_attacks.list[1].vis_flags_enemies = F_RANGED
tt.timed_attacks.list[1].vis_bans_enemies = F_BOSS
tt.timed_attacks.list[1].vis_flags_soldiers = F_RANGED
tt.timed_attacks.list[1].vis_bans_soldiers = bor(F_BOSS, F_FLYING)
tt.timed_attacks.list[1].mod_soldier = "mod_enemy_crocs_tank_charge_soldier"
tt.timed_attacks.list[1].particles_name = "ps_crocs_tank_charge"
tt.timed_attacks.list[1].range = b.charge.range
tt.timed_attacks.list[1].sound = "EnemyCrocTankSpin"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "Tank_crocs_animationsDef"
tt.render.sprites[1].angles.walk = {"walk_side", "walk_up", "walk_down"}
tt.render.sprites[1].angles.charge = {"attack_1", "attack_1", "attack_1"}
tt.render.sprites[1].angles_custom = {
	charge = {55, 115, 245, 305}
}
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(-2, 0)
tt.ui.click_rect = r(-30, -3, 60, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.can_explode = false
tt.unit.can_explode = false
tt.vis.flags = bor(F_ENEMY)
tt.sound_events.death = "EnemyRazingRhinoDeath"
tt.base_speed = b.speed
tt = E:register_t("enemy_crocs_egg_spawner", "enemy")
b = balance.enemies.crocs.crocs_egg_spawner

E:add_comps(tt, "melee", "timed_attacks", "water")

tt.info.enc_icon = 5
tt.info.portrait = "kr5_info_portraits_enemies_0055"
tt.unit.mod_offset = v(0, 16)
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 10)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.marker_offset = v(-1, -1)
tt.ui.click_rect = r(-25, -2, 50, 40)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(34, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health.dead_lifetime = 5
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_crocs_egg_spawner.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_crocs_egg_spawner_melee_hit"
tt.melee.attacks[1].hit_offset = v(30, 10)
tt.melee.attacks[1].sound = "EnemyNestingGatorMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "crokinder_mom_creep"
tt.render.sprites[1].angles.walk = {"walk_side", "walk_up", "walk_down"}
tt.render.sprites[1].anchor = v(0.5, 0.375)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cast_time = fts(7)
tt.timed_attacks.list[1].animation = "spawn"
tt.timed_attacks.list[1].normal_cooldown = b.eggs_spawn.cooldown
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range
tt.timed_attacks.list[1].distance_between_entities = b.eggs_spawn.distance_between_entities
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount
tt.timed_attacks.list[1].bullet_start_offset = v(-5, 50)
tt.timed_attacks.list[1].bullet = "bullet_crocs_egg_spawner_spawn"
tt.timed_attacks.list[1].delay_between = fts(2)
tt.timed_attacks.list[1].min_distance_from_end = b.eggs_spawn.min_distance_from_end
tt.timed_attacks.list[1].count_group_name = "enemy_crocs_basic_egg"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.eggs_spawn.max_total
tt.timed_attacks.list[1].sound = "EnemyNestingGatorAbility"
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_particles_scale_var = {1.6, 1.9}
tt.water_fixed_speed = b.water_fixed_speed
tt = E:register_t("enemy_crocs_hydra", "enemy")

local b = balance.enemies.crocs.crocs_hydra

E:add_comps(tt, "melee", "timed_attacks", "water")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0064"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.enemy.melee_slot = v(52, 0)
tt.health.hp_max = b.hp[1]
tt.health.hp_max_evolved = b.hp[2]
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 85)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health.on_damage = scripts.enemy_crocs_hydra.on_damage
tt.health.dead_lifetime = 4.5
tt.motion.max_speed = b.speed
tt.main_script.insert = scripts.enemy_crocs_basic.insert
tt.main_script.update = scripts.enemy_crocs_hydra.update
tt.render.sprites[1].prefix = "hydra_unitDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_times = {fts(19), fts(20)}
tt.melee.attacks[1].retarget_blockers = true
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_offset = v(52, 13)
tt.melee.attacks[1].hit_fx = "fx_crocs_hydra_melee_hit"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].animation = "ability"
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].cast_time = fts(17)
tt.timed_attacks.list[1].cooldown = b.dot.cooldown
tt.timed_attacks.list[1].max_range = b.dot.max_range
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].bullet = "bullet_enemy_crocs_hydra"
tt.timed_attacks.list[1].bullet_start_offset = {v(17, 150)}
tt.timed_attacks.list[1].extra_bullets_start_offset = {v(-7, 110), v(34, 100)}
tt.timed_attacks.list[1].nodes_limit = b.dot.nodes_limit
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation = "transform"
tt.timed_attacks.list[2].new_anim_prefix = "hydra_unit_transformedDef"
tt.timed_attacks.list[2].new_health_bar_offset = v(0, 105)
tt.timed_attacks.list[2].new_click_rect = r(-25, -3, 50, 85)
tt.timed_attacks.list[2].new_size = UNIT_SIZE_LARGE
tt.timed_attacks.list[2].new_hit_times = {fts(20), fts(20), fts(20)}
tt.ui.click_rect = r(-25, -3, 50, 65)
tt.unit.hit_offset = v(0, 25)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 25)
tt.unit.head_offset = v(0, 60)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DRILL, F_DISINTEGRATED, F_TELEPORT)
tt.sound_events.death = "DeathEplosion"
tt.water.hit_offset = v(0, 5)
tt.water.mod_offset = v(0, 5)
tt.water.health_bar_hidden = true
tt.water.sprite_suffix = ""
tt.water.vis_bans = bor(F_BLOCK, F_RANGED)
tt.water_fixed_speed = b.water_fixed_speed
tt.water.hide_sprites_range = {}
tt.water.remove_modifiers = true
tt.water.splash_fx = "fx_enemy_splash_crocs"
tt.water_particles_scale_var = {2.4, 2.6}
tt.water_trail_ts_offset = 0.5
tt.water_trail_with_bubbles_projectile = true
tt.transform_fx = "fx_crocs_hydra_heads_transform"
tt.death_fx = "fx_crocs_hydra_heads_death"
tt = E:register_t("boss_crocs_lvl1", "boss")
b = balance.enemies.crocs.boss_crocs

E:add_comps(tt, "melee", "timed_attacks")

tt.next_level_template = "boss_crocs_lvl2"
tt.boss_crocs_level = 1
tt.info.enc_icon = 5
tt.info.portrait = "kr5_info_portraits_enemies_0066"
tt.info.i18n_key = "ENEMY_BOSS_CROCS"
tt.info.enc_icon = 63
tt.info.portrait_boss = "boss_health_bar_icon_new0006"
tt.unit.mod_offset = v(0, 32)
tt.unit.hit_offset = v(0, 36)
tt.unit.head_offset = v(20, 20)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.marker_offset = v(-1, -1)
tt.ui.click_rect = r(-50, -2, 100, 80)
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(63, 0)
tt.health.hp_max = b.hp[1]
tt.health.armor = b.armor[1]
tt.health.magic_armor = b.magic_armor[1]
tt.health_bar.offset = v(0, 145)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health.dead_lifetime = 5
tt.main_script.update = scripts.boss_crocs.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[1]
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[1]
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_crocs_boss_melee_hit_1"
tt.melee.attacks[1].hit_decal = "decal_crocs_boss_melee_hit"
tt.melee.attacks[1].hit_offset = v(55, 0)
tt.melee.attacks[1].mod = "mod_boss_crocs_melee_hit"
tt.melee.attacks[1].sound = "Stage22AbominorMeleeHit"
tt.melee.attacks[1].sound_instakill = "Stage22AbominorEatEnemy"
tt.motion.max_speed = b.speed[1]
tt.render.sprites[1].prefix = "boss_gator1Def"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].anchor = v(0.5, 0.375)
tt.render.sprites[1].scale = vv(1)
tt.render.sprites[1].exo = true
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_INSTAKILL)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_start = "spawnIn"
tt.timed_attacks.list[1].animation_loop = "spawnLoop"
tt.timed_attacks.list[1].animation_end = "spawnOut"
tt.timed_attacks.list[1].loop_times = b.eggs_spawn.loop_times[1]
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown[1]
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range[1]
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range[1]
tt.timed_attacks.list[1].distance_between_entities = b.eggs_spawn.distance_between_entities
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount[1]
tt.timed_attacks.list[1].bullet_start_offset = {v(50, 120), v(-50, 120)}
tt.timed_attacks.list[1].bullet = "bullet_crocs_egg_spawner_spawn"
tt.timed_attacks.list[1].min_distance_from_end = b.eggs_spawn.min_distance_from_end
tt.timed_attacks.list[1].count_group_name = "enemy_crocs_basic_egg"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.eggs_spawn.max_total
tt.timed_attacks.list[1].sound = "Stage22AbominorSpitEggs"
tt.timed_attacks.list[2] = E:clone_c("melee_attack")
tt.timed_attacks.list[2].hit_time = fts(19)
tt.timed_attacks.list[2].action_time_eat = fts(20)
tt.timed_attacks.list[2].animation = "execute"
tt.timed_attacks.list[2].hp_threshold = b.basic_attack.instakill_threshold[1]
tt.timed_attacks.list[2].damage_type = bor(DAMAGE_EAT, DAMAGE_NO_DODGE)
tt.timed_attacks.list[2].hit_fx = "fx_crocs_egg_spawner_melee_hit"
tt.timed_attacks.list[2].hit_offset = v(63, 60)
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].cooldown = b.tower_destruction.cooldown[1]
tt.timed_attacks.list[3].max_range = b.tower_destruction.max_range[1]
tt.timed_attacks.list[3].mod = "mod_boss_crocs_tower_eat"
tt.timed_attacks.list[3].action_time_mod = fts(21)
tt.timed_attacks.list[3].action_time_eat = fts(95)
tt.timed_attacks.list[3].animation = "hability"
tt.eat_tower_evolution = b.eat_tower_evolution[1]
tt.life_percentage_evolution = b.life_percentage_evolution[1]
tt.evolution_mod = "mod_croc_boss_evolution_polymorph"
tt.evolution_anim = "transform"
tt.evolve_sound = "Stage22AbominorScreamTransformation"
tt.sound_death = "Stage22AbominorDeath"
tt.hp_ticks = 20
tt.evolution_health_update_tick_time = fts(20)
tt.evolution_health_update_time = fts(79)
tt.hp_evolution_method = b.primordial_hunger[tt.boss_crocs_level].hp_evolution_method
tt.hp_restore_fixed_amount = b.primordial_hunger[tt.boss_crocs_level].hp_restore_fixed_amount
tt.can_evolve = true
tt.pre_evolution_step_cap = b.primordial_hunger[1].pre_evolution_step_cap
tt.masks_to_spawn = {{"stage_22_paths_mask1", fts(19), {{{
	x = 200,
	y = 465
}, 100}, {{
	x = 270,
	y = 470
}, 100}, {{
	x = 320,
	y = 530
}, 100}, {{
	x = 400,
	y = 490
}, 100}, {{
	x = 510,
	y = 470
}, 100}}}, {"stage_22_paths_mask2", fts(25), {{{
	x = 512,
	y = 357
}, 100}}}, {"stage_22_paths_mask3", fts(35), {{{
	x = 475,
	y = 240
}, 100}, {{
	x = 570,
	y = 270
}, 100}, {{
	x = 670,
	y = 290
}, 100}}}, {"stage_22_paths_mask4", fts(45), {{{
	x = 490,
	y = 180
}, 100}, {{
	x = 520,
	y = 140
}, 100}, {{
	x = 535,
	y = 90
}, 100}, {{
	x = 535,
	y = 40
}, 100}}}}
tt.rocks_fall_fx = {"fx_stage_22_rocks_paths_fall1", "fx_stage_22_rocks_paths_fall2", "fx_stage_22_rocks_paths_fall3", "fx_stage_22_rocks_paths_fall4"}
tt.rocks_fall_fx_pos = v(512, 384)
tt.sound_events.raise = "Stage22AbominorFallToPath"
tt = E:register_t("stage_22_paths_mask1", "decal_static")
tt.render.sprites[1].name = "stage_22_mascara1"
tt.render.sprites[1].z = Z_BACKGROUND_COVERS
tt.render.sprites[1].hidden = true
tt = E:register_t("stage_22_paths_mask2", "stage_22_paths_mask1")
tt.render.sprites[1].name = "stage_22_mascara4"
tt = E:register_t("stage_22_paths_mask3", "stage_22_paths_mask1")
tt.render.sprites[1].name = "stage_22_mascara2"
tt = E:register_t("stage_22_paths_mask4", "stage_22_paths_mask1")
tt.render.sprites[1].name = "stage_22_mascara3"
tt = E:register_t("boss_crocs_lvl2", "boss_crocs_lvl1")
b = balance.enemies.crocs.boss_crocs
tt.next_level_template = "boss_crocs_lvl3"
tt.boss_crocs_level = 2
tt.can_evolve = true
tt.ui.click_rect = r(-50, -2, 100, 80)
tt.enemy.melee_slot = v(70, 0)
tt.health.hp_max = b.hp[2]
tt.health.armor = b.armor[2]
tt.health.magic_armor = b.magic_armor[2]
tt.health_bar.offset = v(0, 172)
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[2]
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[2]
tt.melee.attacks[1].hit_offset = v(65, 0)
tt.melee.attacks[1].hit_fx = "fx_crocs_boss_melee_hit_2"
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.motion.max_speed = b.speed[2]
tt.render.sprites[1].prefix = "boss_gator2Def"
tt.timed_attacks.list[1].loop_times = b.eggs_spawn.loop_times[2]
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount[2]
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown[2]
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range[2]
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range[2]
tt.timed_attacks.list[1].bullet_start_offset = {v(70, 150), v(-70, 150)}
tt.timed_attacks.list[2].hp_threshold = b.basic_attack.instakill_threshold[2]
tt.timed_attacks.list[2].hit_offset = v(126, 40)
tt.timed_attacks.list[3].cooldown = b.tower_destruction.cooldown[2]
tt.timed_attacks.list[3].max_range = b.tower_destruction.max_range[2]
tt.eat_tower_evolution = b.eat_tower_evolution[2]
tt.life_percentage_evolution = b.life_percentage_evolution[2]
tt.pre_evolution_step_cap = b.primordial_hunger[2].pre_evolution_step_cap
tt.hp_ticks = 20
tt.evolution_health_update_tick_time = fts(20)
tt.evolution_health_update_time = fts(79)
tt.hp_evolution_method = b.primordial_hunger[tt.boss_crocs_level].hp_evolution_method
tt.hp_restore_fixed_amount = b.primordial_hunger[tt.boss_crocs_level].hp_restore_fixed_amount
tt = E:register_t("boss_crocs_lvl3", "boss_crocs_lvl1")
b = balance.enemies.crocs.boss_crocs
tt.next_level_template = "boss_crocs_lvl4"
tt.boss_crocs_level = 3
tt.can_evolve = true
tt.ui.click_rect = r(-50, -2, 100, 80)
tt.enemy.melee_slot = v(90, 0)
tt.info.i18n_key = "ENEMY_BOSS_CROCS_2"
tt.health.hp_max = b.hp[3]
tt.health.armor = b.armor[3]
tt.health.magic_armor = b.magic_armor[3]
tt.health_bar.offset = v(0, 200)
tt.melee.attacks[1].type = "area"
tt.melee.attacks[1].vis_bans = F_FLYING
tt.melee.attacks[1].vis_flags = F_RANGED
tt.melee.attacks[1].damage_bans = F_FLYING
tt.melee.attacks[1].damage_flags = F_AREA
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[3]
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[3]
tt.melee.attacks[1].hit_offset = v(80, 0)
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].hit_fx = "fx_crocs_boss_melee_hit"
tt.melee.attacks[1].hit_decal = "decal_crocs_boss_melee_hit_2"
tt.motion.max_speed = b.speed[3]
tt.render.sprites[1].prefix = "boss_gator3Def"
tt.timed_attacks.list[1].loop_times = b.eggs_spawn.loop_times[3]
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount[3]
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown[3]
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range[3]
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range[3]
tt.timed_attacks.list[1].bullet_start_offset = {v(75, 155), v(-75, 155)}
tt.timed_attacks.list[2].hp_threshold = b.basic_attack.instakill_threshold[3]
tt.timed_attacks.list[2].hit_offset = v(126, 40)
tt.timed_attacks.list[3].cooldown = b.tower_destruction.cooldown[3]
tt.timed_attacks.list[3].max_range = b.tower_destruction.max_range[3]
tt.timed_attacks.list[4] = E:clone_c("custom_attack")
tt.timed_attacks.list[4].cooldown = b.poison_rain.cooldown[1]
tt.timed_attacks.list[4].min_range = b.poison_rain.min_range[1]
tt.timed_attacks.list[4].max_range = b.poison_rain.max_range[1]
tt.timed_attacks.list[4].bullet = "bullet_boss_crocs_poison_rain_lvl1"
tt.timed_attacks.list[4].animation_start = "acid"
tt.timed_attacks.list[4].action_time_shoot = fts(27)
tt.timed_attacks.list[4].shots_delay = fts(2)
tt.timed_attacks.list[4].shots_amount = b.poison_rain.shots_amount[1]
tt.timed_attacks.list[4].bullet_start_offset = v(95, 130)
tt.timed_attacks.list[4].sound = "Stage22AbominorShootAcid"
tt.eat_tower_evolution = b.eat_tower_evolution[3]
tt.life_percentage_evolution = b.life_percentage_evolution[3]
tt.pre_evolution_step_cap = b.primordial_hunger[3].pre_evolution_step_cap
tt.hp_ticks = 20
tt.evolution_health_update_tick_time = fts(20)
tt.evolution_health_update_time = fts(79)
tt.hp_evolution_method = b.primordial_hunger[tt.boss_crocs_level].hp_evolution_method
tt.hp_restore_fixed_amount = b.primordial_hunger[tt.boss_crocs_level].hp_restore_fixed_amount
tt = E:register_t("boss_crocs_lvl4", "boss_crocs_lvl3")
b = balance.enemies.crocs.boss_crocs
tt.next_level_template = "boss_crocs_lvl5"
tt.boss_crocs_level = 4
tt.can_evolve = true
tt.ui.click_rect = r(-50, -2, 100, 80)
tt.enemy.melee_slot = v(90, 0)
tt.health.hp_max = b.hp[4]
tt.health.armor = b.armor[4]
tt.health.magic_armor = b.magic_armor[4]
tt.health_bar.offset = v(0, 210)
tt.melee.attacks[1].type = "area"
tt.melee.attacks[1].vis_bans = F_FLYING
tt.melee.attacks[1].vis_flags = F_RANGED
tt.melee.attacks[1].damage_bans = F_FLYING
tt.melee.attacks[1].damage_flags = F_AREA
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[4]
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[4]
tt.melee.attacks[1].hit_offset = v(90, 0)
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].hit_decal = "decal_crocs_boss_melee_hit_2"
tt.motion.max_speed = b.speed[4]
tt.render.sprites[1].prefix = "boss_gator4Def"
tt.timed_attacks.list[1].loop_times = b.eggs_spawn.loop_times[4]
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount[4]
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown[4]
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range[4]
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range[4]
tt.timed_attacks.list[1].bullet_start_offset = {v(90, 175), v(-90, 175)}
tt.timed_attacks.list[2].hp_threshold = b.basic_attack.instakill_threshold[4]
tt.timed_attacks.list[2].hit_offset = v(126, 40)
tt.timed_attacks.list[3].cooldown = b.tower_destruction.cooldown[4]
tt.timed_attacks.list[3].max_range = b.tower_destruction.max_range[4]
tt.timed_attacks.list[4] = E:clone_c("custom_attack")
tt.timed_attacks.list[4].cooldown = b.poison_rain.cooldown[1]
tt.timed_attacks.list[4].min_range = b.poison_rain.min_range[1]
tt.timed_attacks.list[4].max_range = b.poison_rain.max_range[1]
tt.timed_attacks.list[4].bullet = "bullet_boss_crocs_poison_rain_lvl1"
tt.timed_attacks.list[4].animation_start = "acid"
tt.timed_attacks.list[4].action_time_shoot = fts(27)
tt.timed_attacks.list[4].shots_delay = fts(2)
tt.timed_attacks.list[4].shots_amount = b.poison_rain.shots_amount[1]
tt.timed_attacks.list[4].bullet_start_offset = v(120, 135)
tt.timed_attacks.list[4].sound = "Stage22AbominorShootAcid"
tt.eat_tower_evolution = b.eat_tower_evolution[4]
tt.life_percentage_evolution = b.life_percentage_evolution[4]
tt.pre_evolution_step_cap = b.primordial_hunger[4].pre_evolution_step_cap
tt.hp_ticks = 20
tt.evolution_health_update_tick_time = fts(20)
tt.evolution_health_update_time = fts(79)
tt.hp_evolution_method = b.primordial_hunger[tt.boss_crocs_level].hp_evolution_method
tt.hp_restore_fixed_amount = b.primordial_hunger[tt.boss_crocs_level].hp_restore_fixed_amount
tt = E:register_t("boss_crocs_lvl5", "boss_crocs_lvl3")
b = balance.enemies.crocs.boss_crocs
tt.next_level_template = nil
tt.boss_crocs_level = 5
tt.can_evolve = false
tt.melee.attacks[1].disabled = true
tt.vis.bans = bor(F_BLOCK)
tt.ui.click_rect = r(-50, -2, 100, 80)
tt.enemy.melee_slot = v(120, 0)
tt.info.i18n_key = "ENEMY_BOSS_CROCS_3"
tt.health.hp_max = b.hp[5]
tt.health.armor = b.armor[5]
tt.health.magic_armor = b.magic_armor[5]
tt.health_bar.offset = v(0, 240)
tt.health.dead_lifetime = 1e+99
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max[5]
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min[5]
tt.melee.attacks[1].hit_offset = v(100, 0)
tt.motion.max_speed = b.speed[5]
tt.render.sprites[1].prefix = "boss_gator5Def"
tt.timed_attacks.list[1].loop_times = b.eggs_spawn.loop_times[5]
tt.timed_attacks.list[1].entities_amount = b.eggs_spawn.entities_amount[5]
tt.timed_attacks.list[1].cooldown = b.eggs_spawn.cooldown[5]
tt.timed_attacks.list[1].min_range = b.eggs_spawn.min_range[5]
tt.timed_attacks.list[1].max_range = b.eggs_spawn.max_range[5]
tt.timed_attacks.list[1].bullet_start_offset = {v(100, 200), v(-100, 200)}
tt.timed_attacks.list[2].hp_threshold = b.basic_attack.instakill_threshold[5]
tt.timed_attacks.list[2].hit_offset = v(189, 60)
tt.timed_attacks.list[3].cooldown = b.tower_destruction.cooldown[5]
tt.timed_attacks.list[3].max_range = b.tower_destruction.max_range[5]
tt.timed_attacks.list[4].bullet = "bullet_boss_crocs_poison_rain_lvl2"
tt.timed_attacks.list[4].cooldown = b.poison_rain.cooldown[2]
tt.timed_attacks.list[4].min_range = b.poison_rain.min_range[2]
tt.timed_attacks.list[4].max_range = b.poison_rain.max_range[2]
tt.timed_attacks.list[4].animation_start = "acid"
tt.timed_attacks.list[4].sound = "Stage22AbominorShootFireball"
tt.timed_attacks.list[4].action_time_shoot = fts(27)
tt.timed_attacks.list[4].shots_delay = fts(1)
tt.timed_attacks.list[4].bullet_start_offset = v(130, 160)
tt.timed_attacks.list[4].shots_amount = b.poison_rain.shots_amount[2]
tt.stomp_passive = {}
tt.stomp_passive.range = b.stomper.range
tt.stomp_passive.vis_flags_soldiers = F_RANGED
tt.stomp_passive.vis_bans_soldiers = bor(F_BOSS, F_FLYING)
tt.stomp_passive.step_fx = "decal_crocs_boss_melee_hit_3"
tt.stomp_passive.damage_min = b.stomper.damage_soldiers_min
tt.stomp_passive.damage_max = b.stomper.damage_soldiers_max
tt.stomp_passive.damage_type = b.stomper.damage_type
tt.pre_evolution_step_cap = b.primordial_hunger[5].pre_evolution_step_cap
tt.hp_evolution_method = b.primordial_hunger[tt.boss_crocs_level].hp_evolution_method
tt.hp_restore_fixed_amount = b.primordial_hunger[tt.boss_crocs_level].hp_restore_fixed_amount
tt = E:register_t("boss_crocs_level_render", "decal")
b = balance.enemies.crocs.boss_crocs

E:add_comps(tt, "texts")

tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "crokinder_mom_creep"
tt.render.sprites[1].scale = vv(0.75)
tt.render.sprites[1].offset = v(0, -30)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.texts.list[1].text = "asdaasd"
tt.texts.list[1].size = v(158, 56)
tt.texts.list[1].font_name = "taunts"
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].color = {255, 30, 30}
tt.texts.list[1].line_height = i18n:cjk(0.8, 0.9, 1.1, 0.7)
tt.texts.list[1].sprite_id = 1
tt = RT("mod_boss_crocs_melee_hit", "modifier")
tt.modifier.hit_fx = "fx_boss_crocs_melee_hit"
tt.main_script.insert = scripts.mod_croc_boss_melee_hit.insert

tt = E:register_t("fx_boss_crocs_melee_hit", "fx")
tt.render.sprites[1].name = "boss_gator_vfx_hit_melee_run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_BULLETS

tt = E:register_t("aura_stage_09_spawn_nightmare_convert", "aura")
b = balance.specials.stage09_spawn_nightmares
tt.aura.duration = 1e+99
tt.aura.radius = 4
tt.include_templates = {"enemy_lesser_sister_nightmare"}
tt.entity_to_spawn = "enemy_armored_nightmare"
tt.spawn_fx = "fx_stage_09_portal_path_spawn_fx"
tt.portal_offset = v(-15, 0)
tt.main_script.update = scripts.aura_stage_09_spawn_nightmare_convert.update
tt.wave_config = b.wave_config
tt.sound_spawn = "EnemyTwistedSisterSummonSpawn"

tt = E:register_t("aura_stage_09_spawn_nightmare_convert_spawn_fx", "aura")
tt.aura.duration = 1e+99
tt.aura.radius = 80
tt.aura.vis_bans = bor(F_FLYING, F_FRIEND)
tt.aura.vis_flags = F_RANGED
tt.include_templates = {"enemy_lesser_sister_nightmare"}

tt = E:register_t("enemy_darksteel_guardian", "enemy")
b = balance.enemies.hammer_and_anvil.darksteel_guardian
E:add_comps(tt, "melee", "death_spawns")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0084"
tt.main_script.update = scripts.enemy_darksteel_guardian.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_enemy_darksteel_guardian_hit_1"
tt.melee.attacks[1].hit_offset = v(40, 15)
tt.melee.attacks[1].sound = "EnemyDarksteelGuardianAttack"
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].cooldown = b.rage_attack.cooldown
tt.melee.attacks[2].damage_max = b.rage_attack.damage_max
tt.melee.attacks[2].damage_min = b.rage_attack.damage_min
tt.melee.attacks[2].damage_type = b.rage_attack.damage_type
tt.melee.attacks[2].hit_times = {fts(14), fts(24)}
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].hit_offset = v(40, 15)
tt.melee.attacks[2].hit_fx = "fx_enemy_darksteel_guardian_hit_2"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].sound = "EnemyDarksteelRageAttack"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_guardian_creep"
tt.render.sprites[1].name = "idle_1"
tt.render.sprites[1].angles.walk = {"walk_1", "walk_front_1", "walk_front_1"}
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].scale = vv(1.1)
tt.ui.click_rect = r(-32, -3, 64, 60)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_STUN)
tt.start_asleep = false
tt.rage_hp_trigger = b.rage_hp_trigger
tt.death_spawns.name = "controller_darksteel_guardian_death"
tt.death_spawns.delay = fts(35)
tt.legs_t = "decal_enemy_darksteel_guardian_legs"
tt.sound_events.death = "EnemyDarksteelGuardianDeath"
tt.sound_activation = "EnemyDarksteelGuardianActivation"
tt.sound_rock = "EnemyDarksteelGuardianRock"
tt.sound_enrage = "EnemyDarksteelEnrage"

tt = E:register_t("enemy_darksteel_hammerer", "enemy")

local b = balance.enemies.hammer_and_anvil.darksteel_hammerer

E:add_comps(tt, "melee")

tt.info.i18n_key = "ENEMY_DARKSTEEL_HAMMERER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0073"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.health_bar.offset = v(0, 33)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.unit.hit_offset = v(0, 12)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 12)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-17, -3, 34, 32)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_hammerer_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyDarksteelHammererDeath"
tt.vis.flags = bor(tt.vis.flags)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].animation = "attack"
tt = E:register_t("enemy_darksteel_shielder", "enemy")

local b = balance.enemies.hammer_and_anvil.darksteel_shielder

E:add_comps(tt, "melee", "death_spawns")

tt.info.i18n_key = "ENEMY_DARKSTEEL_SHIELDER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0074"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health_bar.offset = v(0, 28)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 10)
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.ui.click_rect = r(-17, -3, 34, 30)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_shielder_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyDarksteelShielderDeath"
tt.main_script.update = scripts.enemy_darksteel_shielder.update
tt.vis.flags = bor(tt.vis.flags)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].animation = "attack"
tt.death_spawns.name = "enemy_darksteel_hammerer"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(46.1)
tt = E:register_t("enemy_surveillance_sentry", "enemy")

E:add_comps(tt, "death_spawns", "tween")

local b = balance.enemies.hammer_and_anvil.surveillance_sentry

tt.info.enc_icon = 20
tt.info.portrait = "kr5_info_portraits_enemies_0077"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 40
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_surveillance_sentry.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "rolling_sentry_creep_flying"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 5, 36, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.death_spawns.name = "enemy_rolling_sentry"
tt.death_spawns.death_animation = "death"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(12)
tt.death_spawns.dead_lifetime = 0
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].sprite_id = 2
tt = E:register_t("enemy_rolling_sentry", "enemy")
b = balance.enemies.hammer_and_anvil.rolling_sentry

E:add_comps(tt, "melee", "ranged", "death_spawns")

tt.info.enc_icon = 12
tt.info.portrait = "kr5_info_portraits_enemies_0076"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 35)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_rolling_sentry.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_type = b.melee_attack.damage_type
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[1].animation_in = "walk_out"
tt.melee.attacks[1].animation = "attack_loop_side"
tt.melee.attacks[1].animation_out = "walk_in"
tt.motion.max_speed = b.speed
tt.ranged.attacks[1].animation_in = "walk_out"
tt.ranged.attacks[1].animation = "attack_loop_side"
tt.ranged.attacks[1].animation_out = "walk_in"
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].bullet = "bullet_enemy_rolling_sentry"
tt.ranged.attacks[1].bullet_start_offset = {v(5, 23), v(5, 23), v(5, 23)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].sound = "EnemyRollingSentryAttack"
tt.render.sprites[1].angles.walk = {"walk_loop", "walk_loop_back", "walk_loop_front"}
tt.render.sprites[1].angles.attack = {"attack_loop_side", "attack_loop_back", "attack_loop_front"}
tt.render.sprites[1].prefix = "rolling_sentry_creep"
tt.sound_events.death = "EnemyRollingSentryDeath"
tt.unit.hit_offset = v(0, 10)
tt.unit.mod_offset = v(0, 14)
tt.unit.blood_color = BLOOD_GRAY
tt.ui.click_rect = r(-16, -3, 32, 30)
tt.death_spawns.name = "decal_scrap"
tt.death_spawns.death_animation = "death"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(12)
tt = E:register_t("enemy_mad_tinkerer", "enemy")

local b = balance.enemies.hammer_and_anvil.mad_tinkerer

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 47)
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 10)
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.ui.click_rect = r(-17, -3, 34, 40)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "mad_tinkerer"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyMadTinkererDeath"
tt.info.i18n_key = "ENEMY_MAD_TINKERER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0080"
tt.main_script.update = scripts.enemy_mad_tinkerer.update
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_fx = "fx_enemy_mad_tinkerer_hit"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "skill"
tt.timed_attacks.list[1].loop_time = fts(30)
tt.timed_attacks.list[1].cast_time = fts(34)
tt.timed_attacks.list[1].cooldown = b.clone.cooldown
tt.timed_attacks.list[1].radius = b.clone.max_range
tt.timed_attacks.list[1].min_range = b.clone.min_range
tt.timed_attacks.list[1].entity_search = "decal_scrap"
tt.timed_attacks.list[1].entity_spawn = "enemy_scrap_drone"
tt.timed_attacks.list[1].ray = "decal_ray_mad_tinkerer"
tt.timed_attacks.list[1].bullet = "decal_scrap_bullet_mad_tinkerer"
tt.timed_attacks.list[1].spawn_delay = 0
tt.timed_attacks.list[1].sound = "EnemyMadTinkererRayCast"
tt.timed_attacks.list[1].count_group_name = "enemy_mad_tinkerer"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.clone.max_total
tt.nodes_limit = b.clone.nodes_limit
tt.sound_summon = "EnemyMadTinkererSummon"
tt = E:register_t("enemy_scrap_drone", "enemy")

E:add_comps(tt, "tween")

local b = balance.enemies.hammer_and_anvil.scrap_drone

tt.info.enc_icon = 20
tt.info.portrait = "kr5_info_portraits_enemies_0081"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 40
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_surveillance_sentry.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "scrap_drone_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "scrap_drone_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "EnemyScrapDroneDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 5, 36, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[1].sprite_id = 2
tt = E:register_t("enemy_brute_welder", "enemy")

local b = balance.enemies.hammer_and_anvil.brute_welder

E:add_comps(tt, "melee", "death_spawns")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0078"
tt.info.fn = scripts.enemy_brute_welder.get_info
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 40)
tt.main_script.update = scripts.enemy_brute_welder.update
tt.melee.attacks[1] = E:clone_c("aura_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].aura = "aura_enemy_brute_welder"
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].aura_offset = v(b.basic_attack.flame.radius, 0)
tt.melee.attacks[1].vis_bans = 0
tt.melee.attacks[1].vis_flags = bor(F_AREA, F_BURN, F_ENEMY)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "brute_welder_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.sound_events.death = "EnemyBruteWelderDeath"
tt.ui.click_rect = r(-20, -3, 40, 33)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 14)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.death_spawns.name = "controller_enemy_brute_welder_death"
tt.death_spawns.delay = fts(30)

tt = E:register_t("controller_enemy_brute_welder_death")
local b = balance.enemies.hammer_and_anvil.brute_welder
E:add_comps(tt, "main_script", "render")
tt.main_script.update = scripts.controller_enemy_brute_welder_death.update
tt.render.sprites[1].name = "brute_welder_tank_projectile"
tt.render.sprites[1].hidden = true
tt.render.sprites[1].animated = false
tt.missile_t = "bullet_enemy_brute_welder_death"
tt.missile_range = b.death_missile.range
tt.shoot_sound = nil
tt.spawn_offset = v(-5, 20)
tt.mark_mod = "mod_bullet_enemy_brute_welder_death_mark"

tt = E:register_t("enemy_scrap_speedster", "enemy")
local b = balance.enemies.hammer_and_anvil.scrap_speedster
E:add_comps(tt, "melee", "death_spawns")
tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0075"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.main_script.update = scripts.enemy_scrap_speedster.update
tt.main_script.remove = scripts.enemy_scrap_speedster.remove
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "scrap_speedster_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyScrapSpeedsterDeath"
tt.ui.click_rect = r(-17, -3, 34, 30)
tt.unit.hit_offset = v(0, 11)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 11)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.death_spawns.name = "decal_scrap"
tt.death_spawns.delay = fts(14)
tt.trail_t = "ps_enemy_scrap_speedster_trail"
tt = E:register_t("enemy_common_clone", "enemy")

local b = balance.enemies.hammer_and_anvil.common_clone

E:add_comps(tt, "melee")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(20, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 1
tt.info.portrait = "kr5_info_portraits_enemies_0072"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, 10)
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_fx = "fx_enemy_common_clone_hit"
tt.melee.attacks[1].hit_offset = v(20, 10)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "common_clone_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyCommonCloneDeath"
tt.ui.click_rect = r(-13, 0, 26, 26)
tt = E:register_t("enemy_darksteel_fist", "enemy")

local b = balance.enemies.hammer_and_anvil.darksteel_fist

E:add_comps(tt, "melee")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0079"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.main_script.update = scripts.enemy_darksteel_fist.update
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_times = {fts(3), fts(12)}
tt.melee.attacks[1].hit_fx = "fx_enemy_darksteel_fist_hit"
tt.melee.attacks[1].hit_offset = v(35, 10)
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.stun_attack.cooldown
tt.melee.attacks[2].animation = "stun"
tt.melee.attacks[2].hit_time = fts(18)
tt.melee.attacks[2].hit_decal = "decal_enemy_darksteel_fist_stun"
tt.melee.attacks[2].hit_fx = "fx_enemy_darksteel_fist_area"
tt.melee.attacks[2].hit_offset = v(35, 0)
tt.melee.attacks[2].damage_min = b.stun_attack.damage_min
tt.melee.attacks[2].damage_max = b.stun_attack.damage_max
tt.melee.attacks[2].damage_radius = b.stun_attack.damage_radius
tt.melee.attacks[2].damage_type = b.stun_attack.damage_type
tt.melee.attacks[2].mod = "mod_enemy_darksteel_fist_stun"
tt.melee.attacks[2].sound = "EnemyDarksteelFistStun"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_fist_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyDarksteelFistDeath"
tt.ui.click_rect = r(-20, -3, 40, 28)
tt.unit.hit_offset = v(0, 11)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 11)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.can_explode = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM

tt = E:register_t("mod_bullet_enemy_brute_welder_death_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.mark_flags.vis_bans = F_STUN
tt.modifier.duration = 5
tt.main_script.queue = scripts.mod_bullet_enemy_brute_welder_death_mark.queue
tt.main_script.dequeue = scripts.mod_bullet_enemy_brute_welder_death_mark.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = E:register_t("mod_bullet_enemy_brute_welder_death_stun", "modifier")

local b = balance.enemies.hammer_and_anvil.brute_welder

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_bullet_enemy_brute_welder_death_stun.update
tt.modifier.duration = b.death_missile.block_duration
tt.render.sprites[1].prefix = "brute_welder_tower_mod"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(2, 10)
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "EnemyRevenantSoulcallerBlockTowerIn"
tt.sound_events.remove = "EnemyRevenantSoulcallerBlockTowerOut"
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(0.7, 0.7)}, {fts(10), v(1, 1)}}
tt.tween.remove = false
tt = E:register_t("mod_enemy_darksteel_fist_stun", "mod_stun")

local b = balance.enemies.hammer_and_anvil.darksteel_fist.stun_attack

tt.modifier.duration = b.stun_duration
tt.modifier.vis_flags = bor(F_MOD, F_STUN)
tt.modifier.vis_bans = bor(F_BOSS)
tt = E:register_t("mod_stage_25_torso_missile_mark", "modifier")

E:add_comps(tt, "mark_flags", "render", "tween")

tt.mark_flags.vis_bans = F_STUN
tt.modifier.duration = 7
tt.main_script.queue = scripts.mod_stage_25_torso_missile_mark.queue
tt.main_script.dequeue = scripts.mod_stage_25_torso_missile_mark.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt.render.sprites[1].prefix = "DLC_stage_03_missile_decal_tower"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 0}, {fts(15), 255}}
tt.tween.remove = false
tt = E:register_t("mod_stage_25_torso_missile_stun", "modifier")

local b = balance.specials.stage25_torso.missile

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_stage_25_torso_missile_stun.update
tt.main_script.remove = scripts.mod_stage_25_torso_missile_stun.remove
tt.modifier.duration = 9 --b.max_duration
tt.render.sprites[1].prefix = "DLC_stage_03_missile_tower_fx"
tt.render.sprites[1].name = "loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(2, 10)
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "EnemyRevenantSoulcallerBlockTowerIn"
tt.sound_events.remove = "EnemyRevenantSoulcallerBlockTowerOut"
tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, v(0.7, 0.7)}, {fts(10), v(1, 1)}}
tt.tween.remove = false
tt.repair_cost = b.repair_cost
tt.water_decal_t = "decal_mod_stage_25_torso_missile_stun_water"
tt.hand_decal_t = "decal_mod_stage_25_torso_missile_stun_hand"
tt = E:register_t("mod_stage_27_ray_stun", "modifier")
b = balance.specials.stage27_head

E:add_comps(tt, "render", "tween")

tt.main_script.update = scripts.mod_stage_27_ray_stun.update
tt.modifier.duration = b.ray_stun_duration
tt.render.sprites[1].prefix = "dclenanos_stage05_headplasmaDef"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "dclenanos_stage05_headplasmabgDef"
tt.render.sprites[2].animated = true
tt.render.sprites[2].exo = true
tt.render.sprites[2].draw_order = 20
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].sort_y_offset = 15
tt.tween.props[1].keys = {{0, 0}, {fts(15), 255}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{0, 0}, {fts(15), 255}}
tt.tween.remove = false
tt.sound_events.insert = "EnemyRevenantSoulcallerBlockTowerIn"
tt.sound_events.remove = "EnemyRevenantSoulcallerBlockTowerOut"

tt = E:register_t("mod_bullet_stage_27_tower_stun", "modifier")
local b = balance.specials.stage27_head
E:add_comps(tt, "render")
tt.main_script.update = scripts.mod_bullet_stage_27_tower_stun.update
tt.main_script.remove = scripts.mod_bullet_stage_27_tower_stun.remove
tt.render.sprites[1].prefix = "boss_fx_scrap_tower_fx"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].offset = v(-1, 10)
tt.render.sprites[1].sort_y_offset = -10
tt.sound_events.insert = "EnemyRevenantSoulcallerBlockTowerIn"
tt.sound_events.remove = "EnemyRevenantSoulcallerBlockTowerOut"
tt.repair_cost = b.tower_stun_repair_cost
tt.hand_decal_t = "decal_mod_stage_25_torso_missile_stun_hand"
tt.modifier.duration = 4

tt = E:register_t("enemy_darksteel_anvil", "enemy")

local b = balance.enemies.hammer_and_anvil.darksteel_anvil

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.enc_icon = 3
tt.info.portrait = "kr5_info_portraits_enemies_0082"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 40)
tt.main_script.update = scripts.enemy_darksteel_anvil.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_times = {fts(14)}
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].hit_offset = v(40, 15)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].cooldown = b.basic_ranged.cooldown
tt.ranged.attacks[1].max_range = b.basic_ranged.max_range
tt.ranged.attacks[1].min_range = b.basic_ranged.min_range
tt.ranged.attacks[1].bullet = "bullet_darksteel_anvil"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 10), v(-20, 10)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.ranged.attacks[1].shoot_times = {fts(12), fts(20)}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].animations = {"idle", "attack", "idle"}
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].animation_in = "skill_in"
tt.timed_attacks.list[1].animation_loop = "skill_loop"
tt.timed_attacks.list[1].animation_end = "skill_out"
tt.timed_attacks.list[1].cooldown = b.aura.cooldown
tt.timed_attacks.list[1].max_range = b.aura.trigger_range
tt.timed_attacks.list[1].min_targets = b.aura.min_targets
tt.timed_attacks.list[1].duration = b.aura.duration
tt.timed_attacks.list[1].nodes_limit_start = b.aura.nodes_limit_start
tt.timed_attacks.list[1].nodes_limit_end = b.aura.nodes_limit_end
tt.timed_attacks.list[1].aura = "aura_enemy_darksteel_anvil"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].sound = "EnemyDarksteelAnvilBeat"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_anvil_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.sound_events.death = "EnemyDarksteelAnvilDeath"
tt.ui.click_rect = r(-20, -3, 40, 28)
tt.unit.hit_offset = v(0, 11)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 11)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.can_explode = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt = E:register_t("enemy_darksteel_hulk", "enemy")

local b = balance.enemies.hammer_and_anvil.darksteel_hulk

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 57)
tt.info.enc_icon = 10
tt.info.portrait = "kr5_info_portraits_enemies_0083"
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.update = scripts.enemy_darksteel_hulk.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "EnemyRazingRhinoBasicAttack"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].cast_time = fts(21)
tt.timed_attacks.list[1].animation = "charge"
tt.timed_attacks.list[1].cooldown = b.charge.cooldown
tt.timed_attacks.list[1].speed_mult = b.charge.speed_mult
tt.timed_attacks.list[1].health_threshold = b.charge.health_threshold
tt.timed_attacks.list[1].min_distance_from_end = b.charge.min_distance_from_end
tt.timed_attacks.list[1].vis_flags = F_FRIEND
tt.timed_attacks.list[1].vis_bans = bor(F_HERO, F_FLYING)
tt.timed_attacks.list[1].vis_flags_enemies = F_RANGED
tt.timed_attacks.list[1].vis_bans_enemies = F_BOSS
tt.timed_attacks.list[1].vis_flags_soldiers = F_RANGED
tt.timed_attacks.list[1].vis_bans_soldiers = bor(F_BOSS, F_FLYING)
tt.timed_attacks.list[1].mod_enemy = "mod_enemy_darksteel_hulk_charge_enemy"
tt.timed_attacks.list[1].mod_soldier = "mod_enemy_darksteel_hulk_charge_soldier"
tt.timed_attacks.list[1].range = b.charge.range
tt.timed_attacks.list[1].particles_name_a = "ps_enemy_darksteel_hulk_charge_a"
tt.timed_attacks.list[1].particles_name_b = "ps_enemy_darksteel_hulk_charge_b"
tt.timed_attacks.list[1].sound = "EnemyDarksteelHulkCharge"
tt.timed_attacks.list[1].charge_while_blocked = b.charge.charge_while_blocked
tt.timed_attacks.list[1].damage_enemies = b.charge.damage_enemy_max > 0
tt.timed_attacks.list[1].damage_soldiers = b.charge.damage_soldier_max > 0
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "darksteel_hulk_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].angles.charge = {"charge_side", "charge_back", "charge_front"}
tt.render.sprites[1].angles_custom = {
	charge = {55, 115, 245, 305}
}
tt.ui.click_rect = r(-24, -3, 48, 46)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.can_explode = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.sound_events.death = "EnemyDarksteelHulkDeath"
tt.base_speed = b.speed
tt = E:register_t("enemy_machinist", "enemy")
b = balance.enemies.hammer_and_anvil.machinist

E:add_comps(tt, "melee", "regen")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.regen.cooldown = b.regen_cooldown
tt.regen.health = b.regen_health
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0085"
tt.main_script.update = scripts.enemy_machinist.update
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_offset = v(20, 12)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "dlc_dwarf_boss_operator_bossengineer"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.idle = {"idle", "idle"}
tt.render.sprites[1].angles.walk = {"walk", "walk"}
tt.ui.click_rect = r(-23, -3, 46, 40)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_TELEPORT)
tt.operation_pos = v(-1, 385)
tt.timeout = b.timeout
tt.op_cd = b.operation_cd
tt.op_needed = b.operations_needed
tt.sound_lever = {"Stage24MachinistLever1", "Stage24MachinistLever2", "Stage24MachinistLever3"}
tt.sound_factory_on = "Stage24FactoryTurnOnStart"
tt = E:register_t("enemy_deformed_grymbeard_clone", "enemy")

E:add_comps(tt)

local b = balance.enemies.hammer_and_anvil.deformed_grymbeard_clone

tt.info.enc_icon = 20
tt.info.portrait = "kr5_info_portraits_enemies_0087"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 25
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.shield_magic_armor
tt.main_script.insert = scripts.enemy_deformed_grymbeard_clone.insert
tt.main_script.update = scripts.enemy_deformed_grymbeard_clone.update
tt.main_script.remove = scripts.enemy_deformed_grymbeard_clone.remove
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "clone_boss_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk_front"}
tt.render.sprites[1].scale = vv(0.9)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "scrap_drone_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.9)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ui.click_rect = r(-18, tt.flight_height - 5, 36, 45)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 5)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GRAY
tt.vis.bans = bor(F_BLOCK, F_SKELETON, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.shield_hp_threshold = b.shield_hp_threshold
tt.no_shield_speed_factor = b.speed_factor
tt.shield_t = "fx_enemy_deformed_grymbeard_clone_shield"

tt = E:register_t("enemy_spider_priest", "enemy")

local b = balance.enemies.arachnids.spider_priest

E:add_comps(tt, "melee", "ranged", "death_spawns")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = 5
tt.info.enc_icon = 17
tt.info.portrait = "kr5_info_portraits_enemies_0091"
tt.main_script.insert = scripts.enemy_basic_with_random_range.insert
tt.main_script.update = scripts.enemy_spider_priest.update
tt.melee.attacks[1].animation = "hit"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(12)
tt.ranged.attacks[1].animation = "spell"
tt.ranged.attacks[1].bullet = "bullet_enemy_spider_priest"
tt.ranged.attacks[1].hold_advance = false
tt.ranged.attacks[1].shoot_time = fts(25)
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].max_range_variance = 60
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].bullet_start_offset = {v(0, 40)}
tt.ranged.attacks[1].vis_flags = bor(F_RANGED)
tt.motion.max_speed = b.speed
tt.health_trigger_factor = b.health_trigger_factor
tt.death_spawns.name = "enemy_glarenwarden"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(32)
tt.death_spawns.death_animation = "transformation"
tt.death_spawns.dead_lifetime = 0
tt.render.sprites[1].prefix = "cultist_spider_creep"
tt.render.sprites[1].angles.walk = {"side_walking", "walk_back", "walk_front"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.health_bar.offset = v(0, 39)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 16)
tt.unit.head_offset = v(0, 16)
tt.unit.mod_offset = v(0, 16)
tt.enemy.melee_slot = v(25, 0)
tt.transformation_nodes_limit = b.transformation_nodes_limit
tt.transformation_time = b.transformation_time
tt.transformation_anim = "transformation"
tt.transformation_sound = "EnemyUnblindedPriestTransformCast"
tt.transformation_end_sound = "EnemySpiderPriestTransform"
tt.sound_events.death = "EnemyUnblindedPriestDeath"
tt.ui.click_rect = r(-15, -3, 30, 32)
tt = E:register_t("enemy_glarenwarden", "enemy")
b = balance.enemies.arachnids.glarenwarden

E:add_comps(tt, "melee", "cliff")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0094"
tt.info.i18n_key = "ENEMY_GLARENWARDEN"
tt.main_script.update = scripts.enemy_glarenwarden.update
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].mod = "mod_enemy_glarenwarden_melee_lifesteal"
tt.melee.attacks[1].sound = "EnemyGlarenwardenMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "glarenwarden_creep"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = v(0, 50)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 25)
tt.unit.head_offset = v(0, 25)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_LARGE
tt.enemy.melee_slot = v(30, 0)
tt.cliff.fall_accel = 400
tt.sound_events.death = "EnemyGlarenwardenDeath"
tt = E:register_t("enemy_ballooning_spider", "enemy")

E:add_comps(tt, "tween")

local b = balance.enemies.arachnids.ballooning_spider

tt.info.enc_icon = 16
tt.info.portrait = "kr5_info_portraits_enemies_0090"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.fly_strenght = -10
tt.fly_frequency = 25
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 23)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_ballooning_spider.update
tt.motion.max_speed = b.speed
tt.base_speed = b.speed
tt.render.sprites[1].prefix = "balooning_spider_exo_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].angles.takeoff = {"takeoff", "takeoff_up", "takeoff_down"}
tt.render.sprites[1].angles_stickiness = {
	takeoff = 15,
	walk = 15
}
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.9)
tt.render.sprites[2].hidden = true
tt.ui.click_rect = r(-15, -5, 30, 30)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = v(0, 7)
tt.unit.head_offset = v(0, 7)
tt.unit.mod_offset = v(0, 7)
tt.vis.bans = bor(F_BLOCK)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.sound_events.death = "EnemySpiderlingDeath"
tt.detection_range = b.detection_range
tt.detection_flags = bor(F_FRIEND, F_BLOCK)
tt.detection_bans = bor(F_FLYING)
tt.takeoff = {}
tt.takeoff.health_bar_offset_mid = v(0, tt.flight_height + 20)
tt.takeoff.health_bar_offset = v(0, tt.flight_height + 75)
tt.takeoff.sprite_offset = v(0, tt.flight_height)
tt.takeoff.ui_click_rect = r(-15, tt.flight_height + 15, 30, 30)
tt.takeoff.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.takeoff.hit_offset = v(0, tt.flight_height + 20)
tt.takeoff.mod_offset = v(0, tt.flight_height + 20)
tt.takeoff.max_speed = b.speed_air
tt.takeoff.anims_prefix = "balooning_spider_exo_creep_air"
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = false
tt.tween.props[1].remove = false
tt = E:register_t("enemy_ballooning_spider_flyer", "enemy_ballooning_spider")
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt = E:register_t("enemy_spider_sister", "enemy")

local b = balance.enemies.arachnids.spider_sister

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(15, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 38)
tt.unit.hit_offset = v(0, 21)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 13)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "spider_sister_enemy"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.death = "EnemyTwistedSisterDeath"
tt.info.i18n_key = "ENEMY_SPIDER_SISTER"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0092"
tt.main_script.update = scripts.enemy_spider_sister.update
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].hit_time = fts(18)
tt.ranged.attacks[1].bullet = "spider_sister_bolt"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 13)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].animation = "attack_1"
tt.ranged.attacks[1].shoot_time = fts(18)
tt.ranged.attacks[1].hold_advance = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "ability_1"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = b.spiderlings_summon.cooldown
tt.timed_attacks.list[1].cooldown_init = b.spiderlings_summon.cooldown_init
tt.timed_attacks.list[1].cooldown_increment = b.spiderlings_summon.cooldown_increment
tt.timed_attacks.list[1].cooldown_max = b.spiderlings_summon.cooldown_max
tt.timed_attacks.list[1].range = b.spiderlings_summon.max_range
tt.timed_attacks.list[1].max_targets = 1
tt.timed_attacks.list[1].entity = "enemy_glarebrood_crystal"
tt.timed_attacks.list[1].spawn_delay = 0
tt.timed_attacks.list[1].sound = "EnemySpiderSisterSpawn"
tt.timed_attacks.list[1].count_group_name = "enemy_spiderling"
tt.timed_attacks.list[1].count_group_type = COUNT_GROUP_CONCURRENT
tt.timed_attacks.list[1].count_group_max = b.spiderlings_summon.max_total
tt.nodes_limit = b.spiderlings_summon.nodes_limit
tt.node_random_min = b.spiderlings_summon.nodes_random_min
tt.node_random_max = b.spiderlings_summon.nodes_random_max
tt = E:register_t("enemy_glarebrood_crystal", "enemy")
b = balance.enemies.arachnids.glarebrood_crystal

E:add_comps(tt, "death_spawns")

tt.enemy.gold = b.gold
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.info.enc_icon = 9
tt.info.portrait = "kr5_info_portraits_enemies_0093"
tt.info.i18n_key = "ENEMY_GLAREBROOD_CRYSTAL"
tt.main_script.update = scripts.enemy_glarebrood_crystal.update
tt.render.sprites[1].prefix = "glarebrood_crystal_enemy"
tt.render.sprites[1].anchor = v(0.5, 0.5364583333333334)
tt.ui.click_rect = r(-20, -3, 40, 30)
tt.health_bar.offset = v(0, 25)
tt.unit.show_blood_pool = false
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.enemy.melee_slot = v(18, 0)
tt.unit.size = UNIT_SIZE_SMALL
tt.death_spawns.name = "enemy_spiderling_from_crystal"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.death_animation = "glarebrood_in"
tt.death_spawns.dead_lifetime = 0
tt.transform_anim = "glarebrood_in"
tt.transform_time = b.transformation_time
tt.sound_events.death = "EnemySpiderlingDeath"
tt.hp_threshold_1 = {0.66, "degradacion_1"}
tt.hp_threshold_2 = {0.33, "degradacion_2"}
tt = E:register_t("enemy_spiderling_from_crystal", "enemy_spiderling")
b = balance.enemies.arachnids.glarebrood_crystal.spiderling_spawn
tt.enemy.gold = b.gold
tt.info.portrait = "kr5_info_portraits_enemies_0089"
tt = E:register_t("enemy_cultbrood", "enemy")
b = balance.enemies.arachnids.cultbrood

E:add_comps(tt, "melee")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 55)
tt.unit.hit_offset = v(0, 23)
tt.unit.head_offset = v(0, 26)
tt.unit.mod_offset = v(0, 25)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 35)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_CULTBROOD"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0095"
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "cultbrood_unit"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.ui.click_rect = r(-20, 0, 40, 45)
tt.unit.show_blood_pool = false
tt.main_script.update = scripts.enemy_cultbrood.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack1"
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].sound = "EnemyCultbroodMelee"
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "attack2"
tt.melee.attacks[2].cooldown = b.poison_attack.cooldown
tt.melee.attacks[2].cooldown_init = b.poison_attack.cooldown_init
tt.melee.attacks[2].damage_max = b.poison_attack.damage_max
tt.melee.attacks[2].damage_min = b.poison_attack.damage_min
tt.melee.attacks[2].damage_type = b.poison_attack.damage_type
tt.melee.attacks[2].hit_time = fts(14)
tt.melee.attacks[2].mod = "mod_cultbrood_poison"
tt.melee.attacks[2].sound = "EnemyCultbroodMelee"
tt.generation = 0
tt.spawn_time = b.spawn_time
tt.sound_events.death = "EnemyCultbroodDeath"
tt = E:register_t("enemy_drainbrood", "enemy")
b = balance.enemies.arachnids.drainbrood

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 40)
tt.unit.hit_offset = v(0, 23)
tt.unit.head_offset = v(0, 23)
tt.unit.mod_offset = v(0, 21)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 33)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_GREEN
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_DRAINBROOD"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0096"
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "drainblood_enemy"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.unit.show_blood_pool = false
tt.main_script.update = scripts.enemy_drainbrood.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound = "EnemyDrainbroodMelee"
tt.timed_attacks.list[1] = E:clone_c("mod_attack")
tt.timed_attacks.list[1].animation = "attack_spit"
tt.timed_attacks.list[1].cast_time = fts(11)
tt.timed_attacks.list[1].drain_time = fts(13)
tt.timed_attacks.list[1].cooldown = b.webspit.cooldown
tt.timed_attacks.list[1].mod = "mod_drainbrood_web"
tt.timed_attacks.list[1].damage_max = b.webspit.damage_max
tt.timed_attacks.list[1].damage_min = b.webspit.damage_min
tt.timed_attacks.list[1].damage_type = b.webspit.damage_type
tt.timed_attacks.list[1].heal_hp_damage_factor = b.webspit.lifesteal.damage_factor
tt.timed_attacks.list[1].heal_hp_fixed = b.webspit.lifesteal.fixed_heal
tt.timed_attacks.list[1].vis_flags = bor(F_NET, F_STUN)
tt.timed_attacks.list[1].vis_bans = bor(F_HERO)

tt = E:register_t("enemy_spidead", "enemy")
b = balance.enemies.arachnids.spidead
E:add_comps(tt, "melee", "death_spawns")
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 3
tt.health_bar.offset = v(0, 40)
tt.unit.hit_offset = v(0, 23)
tt.unit.head_offset = v(0, 23)
tt.unit.mod_offset = v(0, 21)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-20, -3, 40, 33)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_GREEN
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_SPIDEAD"
tt.info.enc_icon = 14
tt.info.portrait = "kr5_info_portraits_enemies_0098"
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "spider_web_enemy"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.unit.show_blood_pool = false
tt.unit.hide_during_death = true
tt.main_script.update = scripts.enemy_spidead.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].sound = "EnemyDrainbroodMelee"
tt.death_spawns.name = "decal_spidead_spiderweb"
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.delay = fts(30)
tt.nodes_to_prevent_web = b.nodes_to_prevent_web

tt = E:register_t("decal_spidead_spiderweb", "decal_tween")
b = balance.enemies.arachnids.spidead.spiderweb
E:add_comps(tt, "auras", "main_script")
tt.main_script.insert = scripts.decal_spidead_spiderweb.insert
tt.main_script.remove = scripts.decal_spidead_spiderweb.remove
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_spider_webs_slowness"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = E:clone_c("aura_attack")
tt.auras.list[2].name = "aura_spider_webs_sprint"
tt.auras.list[2].cooldown = 0
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].name = "spider_queen_boss_effects_web_decal"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {{0, 0}, {0.3, 255}, {b.duration - 0.8, 255}, {b.duration, 0}}
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vv(0.8)}, {0.3, vv(1)}, {b.duration - 0.8, vv(1)}, {b.duration, vv(0.8)}}
tt.tween.disabled = false
tt.tween.remove = true

tt = E:register_t("enemy_fire_phoenix", "enemy")
b = balance.enemies.wukong.fire_phoenix

E:add_comps(tt, "tween")

tt.info.enc_icon = 94
tt.info.portrait = "kr5_info_portraits_enemies_0099"
tt.enemy.gold = b.gold
tt.flight_height = 47
tt.fly_strenght = -5
tt.fly_frequency = 8
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 44)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.enemy_fire_phoenix.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "fire_phoenix_zhu_que_firephoenixzhuque"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(0.8)
tt.sound_events.death_custom = "EnemyFirePhoenixDeath"
tt.sound_events.death = nil
tt.ui.click_rect = r(-18, tt.flight_height - 10, 36, 32)
tt.unit.death_animation = "normal_death"
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 4)
tt.unit.head_offset = v(0, 17)
tt.unit.mod_offset = v(0, tt.flight_height)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "quad"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = false
tt.tween.props[1].remove = false
tt.explode_nodes_limit = b.explode_nodes_limit
tt.decal_flaming_ground = "decal_fire_phoenix_flaming_ground"
tt = E:register_t("enemy_blaze_raider", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.blaze_raider
tt.main_script.insert = scripts.enemy_basic_kr5_stage35.insert
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(36, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 97
tt.info.portrait = "kr5_info_portraits_enemies_0101"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 10)
tt.melee.attacks[1].disabled = true
tt.melee.attacks[1].cooldown = b.heavy_attack.cooldown
tt.melee.attacks[1].damage_max = b.heavy_attack.damage_max
tt.melee.attacks[1].damage_min = b.heavy_attack.damage_min
tt.melee.attacks[1].damage_type = b.heavy_attack.damage_type
tt.melee.attacks[1].animation = "attk_1"
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].hit_fx = "fx_blaze_raider_melee_hit"
tt.melee.attacks[1].hit_offset = v(35, 5)
tt.melee.attacks[1].sound = "EnemyBlazeRaiderMeleeSpecial"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].disabled = false
tt.melee.attacks[2].cooldown = b.punzada_attack.cooldown
tt.melee.attacks[2].damage_max = b.punzada_attack.damage_max
tt.melee.attacks[2].damage_min = b.punzada_attack.damage_min
tt.melee.attacks[2].damage_type = b.punzada_attack.damage_type
tt.melee.attacks[2].animation = "attk_2"
tt.melee.attacks[2].hit_time = fts(12)
tt.melee.attacks[2].hit_fx = "fx_blaze_raider_melee_hit"
tt.melee.attacks[2].hit_offset = v(40, 15)
tt.melee.attacks[2].sound = nil
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[3].disabled = false
tt.melee.attacks[3].cooldown = b.double_attack.cooldown
tt.melee.attacks[3].damage_max = b.double_attack.damage_max
tt.melee.attacks[3].damage_min = b.double_attack.damage_min
tt.melee.attacks[3].damage_type = b.double_attack.damage_type
tt.melee.attacks[3].animation = "attk_3"
tt.melee.attacks[3].hit_times = {fts(12), fts(22)}
tt.melee.attacks[3].hit_fx = "fx_blaze_raider_melee_hit"
tt.melee.attacks[3].hit_offset = v(38, 10)
tt.melee.attacks[3].sound = nil
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "blaze_rider"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-13, -3, 26, 32)
tt = E:register_t("enemy_flame_guard", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.flame_guard
tt.main_script.insert = scripts.enemy_basic_kr5_stage35.insert
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(18, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 96
tt.info.portrait = "kr5_info_portraits_enemies_0102"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 10)
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_02"
tt.melee.attacks[1].hit_times = {fts(18), fts(26)}
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_01"
tt.melee.attacks[2].hit_times = {fts(18), fts(26)}
tt.melee.attacks[2].cooldown = b.special_attack.cooldown
tt.melee.attacks[2].damage_max = b.special_attack.damage_max
tt.melee.attacks[2].damage_min = b.special_attack.damage_min
tt.melee.attacks[2].damage_type = b.special_attack.damage_type
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].sound = "EnemyFlameGuardMeleeSpecial"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "flame_guard"
tt.render.sprites[1].angles.walk = {"walk", "walkup", "walkdown"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-13, -3, 26, 32)
tt = E:register_t("enemy_wuxian", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

b = balance.enemies.wukong.wuxian
tt.main_script.update = scripts.enemy_wuxian.update
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(36, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 53)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.enc_icon = 98
tt.info.portrait = "kr5_info_portraits_enemies_0103"
tt.unit.hit_offset = v(0, 25)
tt.unit.head_offset = v(0, 45)
tt.unit.mod_offset = v(0, 25)
tt.unit.size = UNIT_SIZE_LARGE
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_mele_2"
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].hit_fx = "fx_wuxian_melee_hit"
tt.melee.attacks[1].hit_fx_offset = v(48, 10)
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.kamehame_attack.cooldown
tt.melee.attacks[2].damage_max = b.kamehame_attack.damage_max
tt.melee.attacks[2].damage_min = b.kamehame_attack.damage_min
tt.melee.attacks[2].damage_type = b.kamehame_attack.damage_type
tt.melee.attacks[2].animation = "attack_mele"
tt.melee.attacks[2].hit_time = fts(16)
tt.melee.attacks[2].hit_fx = "fx_wuxian_kamehame_hit"
tt.melee.attacks[2].hit_fx_offset = v(55, 5)
tt.melee.attacks[2].sound = "EnemyWuxianSpecial"
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].vis_flags = 0
tt.melee.attacks[2].include_blocked = true
tt.melee.attacks[2].hit_offset = v(55, 0)
tt.melee.attacks[2].damage_radius = 90
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].animation = "attack_range"
tt.timed_attacks.list[1].bullet = "bullet_wuxian_bolt"
tt.timed_attacks.list[1].bullet_start_offset = {v(0, 75)}
tt.timed_attacks.list[1].cooldown = b.ranged_attack.cooldown
tt.timed_attacks.list[1].max_range = b.ranged_attack.max_range
tt.timed_attacks.list[1].min_range = b.ranged_attack.min_range
tt.timed_attacks.list[1].shoot_time = fts(27)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].sound = "EnemyWuxianRanged"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "wuxian_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.sound_events.death = "EnemyWuxianDeath"
tt.ui.click_rect = r(-19, -3, 38, 37)

tt = E:register_t("enemy_fire_fox", "enemy")
E:add_comps(tt, "melee", "death_spawns")
b = balance.enemies.wukong.fire_fox
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 25)
tt.info.enc_icon = 95
tt.info.portrait = "kr5_info_portraits_enemies_0100"
tt.unit.hit_offset = v(0, 10)
tt.unit.head_offset = v(0, 15)
tt.unit.mod_offset = v(0, 10)
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.main_script.update = scripts.enemy_fire_fox.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].sound = "EnemyFireFoxMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "firefox_creep"
tt.render.sprites[1].angles.walk = {"walk", "walkup", "walkdown"}
tt.sound_events.death = "EnemyFireFoxDeath"
tt.ui.click_rect = r(-16, -3, 32, 30)
tt.death_spawns.name = "enemy_nine_tailed_fox"
tt.death_spawns.concurrent_with_death = false
tt.death_spawns.delay = fts(19)
tt.death_spawns.death_animation = "transformation_out"
tt.death_spawns.dead_lifetime = 0
tt.flaming_ground_decal_delay = fts(8)
tt.flaming_ground_decal = "decal_fire_fox_flaming_ground"
tt.transform_duration = b.transform_duration
tt.transform_hp_threshold = b.transform_hp_threshold
tt.transformation_sound = "EnemyUnblindedPriestTransformCast"
tt.transformation_end_sound = "EnemyUnblindedPriestTransformSpawn"
tt = E:register_t("enemy_nine_tailed_fox", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

b = balance.enemies.wukong.nine_tailed_fox
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(50, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 62)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.enc_icon = 101
tt.info.portrait = "kr5_info_portraits_enemies_0106"
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 35)
tt.unit.mod_offset = v(0, 20)
tt.unit.size = UNIT_SIZE_LARGE
tt.main_script.update = scripts.enemy_nine_tailed_fox.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_1"
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].hit_fx = "fx_nine_tailed_fox_hit"
tt.melee.attacks[1].hit_fx_offset = v(55, 5)
tt.melee.attacks[1].sound = "EnemyNineTailedFoxMelee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.double_attack.cooldown
tt.melee.attacks[2].damage_max = b.double_attack.damage_max
tt.melee.attacks[2].damage_min = b.double_attack.damage_min
tt.melee.attacks[2].damage_type = b.double_attack.damage_type
tt.melee.attacks[2].include_blocked = true
tt.melee.attacks[2].hit_offset = v(55, 5)
tt.melee.attacks[2].damage_radius = 50
tt.melee.attacks[2].animation = "attack_2"
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].hit_times = {fts(13), fts(22)}
tt.melee.attacks[2].hit_fx = "fx_nine_tailed_fox_hit"
tt.melee.attacks[2].sound = "EnemyNineTailedFoxMeleeDouble"
tt.melee.attacks[3] = table.deepclone(tt.melee.attacks[2])
tt.melee.attacks[3].cooldown = b.stun_attack.cooldown
tt.melee.attacks[3].damage_max = b.stun_attack.damage_max
tt.melee.attacks[3].damage_min = b.stun_attack.damage_min
tt.melee.attacks[3].damage_type = b.stun_attack.damage_type
tt.melee.attacks[3].mod = b.stun_attack.has_stun and "mod_nine_tailed_fox_stun_attack" or nil
tt.melee.attacks[3].hit_fx = "fx_nine_tailed_fox_hit_stun"
tt.melee.attacks[3].animation = "stun"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_start = "tp_in"
tt.timed_attacks.list[1].animation_end = "tp_out"
tt.timed_attacks.list[1].cooldown = b.teleport.cooldown
tt.timed_attacks.list[1].nodes_limit = b.teleport.nodes_limit
tt.timed_attacks.list[1].first_cooldown = b.teleport.first_cooldown
tt.timed_attacks.list[1].lava_paths_first_cooldown = b.teleport.lava_paths_first_cooldown
tt.timed_attacks.list[1].nodes_max = b.teleport.nodes_max
tt.timed_attacks.list[1].nodes_min = b.teleport.nodes_min
tt.timed_attacks.list[1].tp_speed = b.teleport.tp_speed
tt.timed_attacks.list[1].trail = "ps_nine_tailed_fox_underground_trail"
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].mod = "mod_nine_tailed_fox_stun_teleport"
tt.timed_attacks.list[1].stun_fx1 = "fx_nine_tailed_fox_tp_stun_1"
tt.timed_attacks.list[1].stun_fx2 = "fx_nine_tailed_fox_tp_stun_2"
tt.timed_attacks.list[1].stun_decal = "fx_nine_tailed_fox_tp_stun_decal"
tt.timed_attacks.list[1].range = 90
tt.timed_attacks.list[1].vis_flags = F_AREA
tt.timed_attacks.list[1].vis_bans = F_NONE
tt.timed_attacks.list[1].sound_in = "EnemyNineTailedFoxTeleportIn"
tt.timed_attacks.list[1].sound_out = "EnemyNineTailedFoxTeleportOut"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "ninetailedfox_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.sound_events.death = "EnemyNineTailedFoxDeath"
tt.ui.click_rect = r(-18, -3, 36, 36)
tt.unit.show_blood_pool = false
tt = E:register_t("enemy_burning_treant", "enemy")
b = balance.enemies.wukong.burning_treant

E:add_comps(tt, "melee")

tt.info.enc_icon = 99
tt.info.portrait = "kr5_info_portraits_enemies_0104"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].cooldown = b.area_attack.cooldown
tt.melee.attacks[2].damage_max = b.area_attack.damage_max
tt.melee.attacks[2].damage_min = b.area_attack.damage_min
tt.melee.attacks[2].damage_type = b.area_attack.damage_type
tt.melee.attacks[2].damage_radius = b.area_attack.radius
tt.melee.attacks[2].hit_time = fts(19)
tt.melee.attacks[2].hit_offset = v(35, 0)
tt.melee.attacks[2].hit_decal = "decal_burning_treant_flaming_ground"
tt.melee.attacks[2].animation = "area_attack"
tt.melee.attacks[2].sound = "EnemyBurningTreantSpecial"
tt.melee.attacks[2].sound_args = {
	delay = tt.melee.attacks[2].hit_time
}
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "burning_treant"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.ui.click_rect = r(-25, 0, 50, 50)
tt.unit.hit_offset = v(0, 22)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 19)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.vis.flags = bor(F_ENEMY)
tt.sound_events.death = "EnemyBurningTreantDeath"

tt = E:register_t("enemy_ash_spirit", "enemy")
b = balance.enemies.wukong.ash_spirit
E:add_comps(tt, "melee")
tt.info.enc_icon = 100
tt.info.portrait = "kr5_info_portraits_enemies_0105"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(41, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_decal = "decal_ash_spirit_hit"
tt.melee.attacks[1].hit_time = fts(23)
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.melee.attacks[1].sound = "EnemyAshSpiritMelee"
tt.melee.attacks[1].sound_args = {
	delay = tt.melee.attacks[1].hit_time
}
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "ash_spiritDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-28, 0, 50, 53)
tt.unit.hit_offset = v(0, 26)
tt.unit.head_offset = v(0, 40)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 23)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.show_blood_pool = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.sound_events.death = "EnemyAshSpiritDeath"
tt = E:register_t("enemy_storm_spirit", "enemy")

E:add_comps(tt, "tween")

b = balance.enemies.wukong.storm_spirit
tt.info.enc_icon = 103
tt.info.portrait = "kr5_info_portraits_enemies_0108"
tt.enemy.gold = b.gold
tt.flight_height = 40
tt.fly_strenght = 0
tt.fly_frequency = 10
tt.enemy.melee_slot = v(41, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 80)
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.enemy_storm_spirit.update
tt.render.sid_unit = 1
tt.render.sid_shadow = 2
tt.render.sprites[tt.render.sid_unit].prefix = "stormspirit"
tt.render.sprites[tt.render.sid_unit].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[tt.render.sid_shadow] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_shadow].animated = false
tt.render.sprites[tt.render.sid_shadow].name = "decal_flying_shadow_hard"
tt.render.sprites[tt.render.sid_shadow].offset = v(0, 0)
tt.render.sprites[tt.render.sid_shadow].scale = vv(0.8)
tt.jump_ahead = {}
tt.jump_ahead.nodes_limit = b.jump_ahead.nodes_limit
tt.jump_ahead.max_nodes = b.jump_ahead.max_nodes
tt.jump_ahead.min_nodes = b.jump_ahead.min_nodes
tt.jump_ahead.hp_threshold = b.jump_ahead.hp_threshold
tt.jump_ahead.speed_mult = b.jump_ahead.speed_mult
tt.jump_ahead.zap_fx = "fx_storm_spirit_zap_in_out"
tt.jump_ahead.ps1 = "ps_storm_spirit_jump_ahead_trail_1"
tt.jump_ahead.ps2 = "ps_storm_spirit_jump_ahead_trail_2"
tt.jump_ahead.sound = "EnemyStormSpiritLeap"
tt.sound_events.death = "EnemyStormSpiritDeath"
tt.ui.click_rect = r(-18, tt.flight_height, 36, 32)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 4)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, tt.flight_height)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "quad"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = false
tt.tween.props[1].remove = false
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].sprite_id = tt.render.sid_shadow
tt.tween.props[2].keys = {{0, 255}, {fts(34), 0}}
tt.tween.props[2].disabled = true
tt = E:register_t("enemy_water_spirit", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.water_spirit
tt.info.i18n_key = "ENEMY_WATER_SPIRIT"
tt.info.enc_icon = 102
tt.info.portrait = "kr5_info_portraits_enemies_0107"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(24, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 37)
tt.motion.max_speed = b.speed
tt.water_spawn_speed = b.water_spawn_speed
tt.main_script.insert = scripts.enemy_water_spirit.insert
tt.main_script.update = scripts.enemy_water_spirit.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_type = b.melee_attack.damage_type
tt.melee.attacks[1].mod = "fx_water_spirit_hit"
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(12)
tt.render.sprites[1].prefix = "wukong_water_spirit_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-18, 0, 36, 32)
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 8)
tt.unit.mod_offset = v(0, 0)
tt.unit.size = UNIT_SIZE_SMALL
tt.splash_fx = "fx_water_spirit_splash"
tt.ps_trail_jump = "ps_water_spirit_trail_jump"
tt.ps_trail_swim = "ps_water_spirit_trail_swim"
tt.charco_caida_fx = "fx_water_spirit_charco_caida"
tt.sound_events.death = nil
tt = E:register_t("enemy_water_spirit_spawnless", "enemy_water_spirit")
tt.skip_spawn_anim = true
tt = E:register_t("enemy_qiongqi", "enemy")

E:add_comps(tt, "ranged")

b = balance.enemies.wukong.qiongqi
tt.info.enc_icon = 104
tt.info.portrait = "kr5_info_portraits_enemies_0109"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 94)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.enemy_qiongqi.update
tt.ranged.attacks[1].bullet = "bullet_qiongqi_lightning"
tt.ranged.attacks[1].bullet_start_offset = {v(30, 40)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].hold_advance = b.ranged_attack.hold_advance
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].shoot_time = fts(25)
tt.ranged.attacks[1].vis_bans = bor(tt.ranged.attacks[1].vis_bans, F_FLYING)
tt.render.sprites[1].anchor = vv(0.5)
tt.ranged.attacks[1].animation = "attack"
tt.render.sprites[1].prefix = "qiongqi_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_down", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(1.15)
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].anchor = vv(0.5)
tt.render.sprites[3].animated = true
tt.render.sprites[3].prefix = "qiongqi_fx"
tt.render.sprites[3].name = "fly"
tt.render.sprites[3].ignore_start = true
tt.sound_events.death = "EnemyQiongqiDeath"
tt.ui.click_rect = r(-22, 30, 44, 40)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, 55)
tt.unit.head_offset = v(0, 16)
tt.unit.mod_offset = v(0, 55)
tt.flight_height = tt.unit.hit_offset.y
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt = RT("enemy_gale_warrior", "enemy")

AC(tt, "melee")

b = balance.enemies.wukong.gale_warrior
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_GALE_WARRIOR"
tt.info.enc_icon = 105
tt.info.portrait = "kr5_info_portraits_enemies_0110"
tt.melee.cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].mod = "mod_gale_warrior_combo_counter"
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].damage_max = b.puncturing_thrust.damage_max
tt.melee.attacks[2].damage_min = b.puncturing_thrust.damage_min
tt.melee.attacks[2].hit_time = fts(12)
tt.melee.attacks[2].damage_type = b.puncturing_thrust.damage_type
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].mod = "mod_gale_warrior_dot"
tt.melee.attacks[2].animation = "special_attack"
tt.combo_attacks_needed = b.puncturing_thrust.every_x_attacks
tt.combo_attacks_done = 0
tt.motion.max_speed = b.speed
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].prefix = "gale_warrior"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.sound_events.death = "DeathHuman"
tt.ui.click_rect = r(-20, -5, 40, 40)
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(0, 20)
tt.unit.size = UNIT_SIZE_MEDIUM
tt = E:register_t("enemy_storm_elemental", "enemy")
b = balance.enemies.wukong.storm_elemental

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.enc_icon = 107
tt.info.portrait = "kr5_info_portraits_enemies_0112"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(41, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 70)
tt.main_script.update = scripts.enemy_storm_elemental.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].animation = "area_attack"
tt.melee.attacks[1].hit_decal = "decal_storm_elemental_area_melee"
tt.melee.attacks[1].sound = "EnemyElementalMelee"
tt.ranged.attacks[1].bullet = "bullet_storm_elemental"
tt.ranged.attacks[1].bullet_start_offset = {v(-20, 120)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].hold_advance = b.ranged_attack.hold_advance
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].shoot_time = fts(44) - fts(27)
tt.ranged.attacks[1].animation = "ranged_attack"
tt.ranged.attacks[1].vis_bans = bor(tt.ranged.attacks[1].vis_bans, F_FLYING)
tt.ranged.attacks[1].ignore_hit_offset = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].vis_flags = F_CUSTOM
tt.timed_attacks.list[1].max_range = b.tower_block.range
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].spawn_on_instakill = b.tower_block.spawn_on_instakill
tt.timed_attacks.list[1].mod = "mod_enemy_storm_elemental_tower_debuff"
tt.timed_attacks.list[1].mark_mod = "mod_enemy_storm_elemental_tower_mark"
tt.timed_attacks.list[1].cast_sound = "EnemyElementalDeathEffectCast"
tt.timed_attacks.list[1].stun_sound = "EnemyElementalDeathEffectStun"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "storm_elemental_storm_unit"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "storm_elemental_vfx_bodyfx_run"
tt.render.sprites[2].loop = true
tt.render.sprites[2].ignore_start = true
tt.render.sprites[2].anchor = vv(0.5)
tt.render.sprites[2].offset = v(-35, 25)
tt.ui.click_rect = r(-28, 0, 56, 53)
tt.unit.hit_offset = v(0, 32)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 27)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_NONE
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.sound_events.death = "EnemyElementalDeath"
tt.ps_walk_trail = "ps_storm_elemental_walk_trail"
tt = E:register_t("enemy_water_sorceress", "enemy")

E:add_comps(tt, "melee", "ranged", "timed_attacks")

b = balance.enemies.wukong.water_sorceress
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 38)
tt.info.enc_icon = 106
tt.info.portrait = "kr5_info_portraits_enemies_0111"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 14)
tt.main_script.update = scripts.enemy_water_sorceress.update
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_type = b.melee_attack.damage_type
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_time = fts(8)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].cooldown = b.melee_attack_escupida.cooldown
tt.melee.attacks[2].damage_max = b.melee_attack_escupida.damage_max
tt.melee.attacks[2].damage_min = b.melee_attack_escupida.damage_min
tt.melee.attacks[2].damage_type = b.melee_attack_escupida.damage_type
tt.melee.attacks[2].animation = "melee_2"
tt.melee.attacks[2].hit_time = fts(12)
tt.ranged.attacks[1].animation = "basic_attack"
tt.ranged.attacks[1].bullet = "bullet_water_sorceress_bolt"
tt.ranged.attacks[1].bullet_start_offset = {v(-8, 42)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.range
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].shoot_time = fts(12)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].vis_flags = F_CUSTOM
tt.timed_attacks.list[1].safe_nodes = b.heal_wave.safe_nodes
tt.timed_attacks.list[1].cooldown = b.heal_wave.cooldown
tt.timed_attacks.list[1].first_cooldown = b.heal_wave.first_cooldown
tt.timed_attacks.list[1].nodes_range = b.heal_wave.nodes_range
tt.timed_attacks.list[1].wave_decal = "decal_water_sorceress_heal_wave"
tt.timed_attacks.list[1].animation = "special_attack"
tt.timed_attacks.list[1].sound = "EnemyWaterSorceressSpecial"
tt.unit.show_blood_pool = false
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "watersorceress"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)
tt = E:register_t("enemy_fan_guard", "enemy")
b = balance.enemies.wukong.fan_guard

E:add_comps(tt, "melee")

tt.info.enc_icon = 114
tt.info.portrait = "kr5_info_portraits_enemies_0119"
tt.main_script.update = scripts.enemy_fan_guard.update
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.walking_armor = b.walking_armor
tt.health.blocking_armor = b.blocking_armor
tt.health.walking_magic_armor = b.walking_magic_armor
tt.health.blocking_magic_armor = b.blocking_magic_armor
tt.health.armor = b.walking_armor
tt.health.magic_armor = b.walking_magic_armor
tt.health_bar.offset = v(0, 50)
tt.melee.cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].animation = "melee_1"
tt.melee.attacks[1].hit_times = {fts(10), fts(27)}
tt.melee.attacks[1].hit_fx = "fx_enemy_fan_guard_melee_hit"
tt.melee.attacks[1].hit_offset = v(23, 13)
tt.melee.attacks[1].hit_damage_factor = b.basic_attack.hit_damage_factor
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].chance = 0.35
tt.melee.attacks[2].animation = "melee_2"
tt.melee.attacks[2].hit_times = {fts(8), fts(25)}
tt.melee.attacks[2].hit_fx = "fx_enemy_fan_guard_melee_hit"
tt.melee.attacks[2].hit_offset = v(23, 13)
tt.melee.attacks[2].hit_damage_factor = b.basic_attack.hit_damage_factor
tt.melee.attacks[3] = E:clone_c("melee_attack")
tt.melee.attacks[3].cooldown = b.heavy_attack.cooldown
tt.melee.attacks[3].damage_max = b.heavy_attack.damage_max
tt.melee.attacks[3].damage_min = b.heavy_attack.damage_min
tt.melee.attacks[3].damage_type = b.heavy_attack.damage_type
tt.melee.attacks[3].shared_cooldown = false
tt.melee.attacks[3].animation = "melee_3"
tt.melee.attacks[3].hit_times = {fts(9), fts(43)}
tt.melee.attacks[3].hit_fx = "fx_enemy_fan_guard_melee_hit"
tt.melee.attacks[3].hit_offset = v(23, 13)
tt.melee.attacks[3].hit_damage_factor = b.heavy_attack.hit_damage_factor
tt.melee.attacks[3].sound = "EnemyFanGuardSpecial"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "fan_guard"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.blocking_idle_in = "idle_in"
tt.render.blocking_idle_loop = "idle_loop"
tt.render.blocking_idle_out = "idleout"
tt.ui.click_rect = r(-15, 0, 30, 40)
tt.unit.hit_offset = v(0, 17)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.blood_color = BLOOD_RED
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.sound_events.death = "EnemyFanGuardDeath"
tt = E:register_t("enemy_hellfire_warlock", "enemy")
b = balance.enemies.wukong.hellfire_warlock

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.info.enc_icon = 123
tt.info.portrait = "kr5_info_portraits_enemies_0128"
tt.main_script.update = scripts.enemy_hellfire_warlock.update
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 50)
tt.health.dead_lifetime = 5
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = b.melee_horizontal.cooldown
tt.melee.attacks[1].damage_max = b.melee_horizontal.damage_max
tt.melee.attacks[1].damage_min = b.melee_horizontal.damage_min
tt.melee.attacks[1].damage_type = b.melee_horizontal.damage_type
tt.melee.attacks[1].animation = "mele_2"
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].hit_fx = "fx_hellfire_warlock_melee_hit"
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].max_range = b.ranged.range
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].cooldown = b.ranged.cooldown
tt.ranged.attacks[1].bullet = "bullet_hellfire_warlock_fireball"
tt.ranged.attacks[1].bullet_start_offset = {v(-5, 68)}
tt.ranged.attacks[1].shoot_time = fts(11)
tt.ranged.attacks[1].node_prediction = fts(17)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].hold_advance = true
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_start = "summon_in"
tt.timed_attacks.list[1].animation_loop = "summon_loop"
tt.timed_attacks.list[1].animation_completed = "summon_casted"
tt.timed_attacks.list[1].animation_canceled = "summon_canceled"
tt.timed_attacks.list[1].summon_floor_fx = "decal_hellfire_warlock_summon_decal"
tt.timed_attacks.list[1].staff_floor_fx = "fx_hellfire_warlock_summong_floor_staff"
tt.timed_attacks.list[1].loop_duration = b.summon_fox.loop_duration
tt.timed_attacks.list[1].summon_time = fts(0)
tt.timed_attacks.list[1].cooldown = b.summon_fox.cooldown
tt.timed_attacks.list[1].first_cooldown = b.summon_fox.first_cooldown
tt.timed_attacks.list[1].cancelled_cooldown = b.summon_fox.cancelled_cooldown
tt.timed_attacks.list[1].nodes_limit = b.summon_fox.nodes_limit
tt.timed_attacks.list[1].fox_position = v(0, -30)
tt.timed_attacks.list[1].entity = "fx_nine_tailed_fox_summon"
tt.timed_attacks.list[1].sound_channel = "EnemyWarlockSummonChannel"
tt.timed_attacks.list[1].sound_spawn = "EnemyWarlockSummonSpawn"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "hellfire_warlock_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-15, 0, 30, 40)
tt.unit.hit_offset = v(0, 17)
tt.unit.head_offset = v(0, 15)
tt.unit.mod_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.blood_color = BLOOD_RED
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.sound_events.death = "EnemyWarlockDeath"

tt = E:register_t("boss_redboy_teen", "boss")
b = balance.enemies.wukong.boss_redboy_teen
E:add_comps(tt, "melee", "timed_attacks")
tt.scale = 0.8
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(45 * tt.scale, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health.dead_lifetime = 1e+99
tt.health_bar.offset = v(0, 130 * tt.scale)
tt.unit.hit_offset = v(0, 40 * tt.scale)
tt.unit.head_offset = v(0, 110 * tt.scale)
tt.unit.mod_offset = v(0, 40 * tt.scale)
tt.unit.show_blood_pool = false
tt.ui.click_rect = r(-27 * tt.scale, 0, 50 * tt.scale, 100 * tt.scale)
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.blood_color = BLOOD_GREEN
tt.motion.max_speed = b.speed
tt.info.i18n_key = "ENEMY_BOSS_REDBOY_TEEN"
tt.info.enc_icon = 109
tt.info.portrait = "kr5_info_portraits_enemies_0114"
tt.info.portrait_boss = "boss_health_bar_icon_0011"
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.exo_anim_map = {
	Stun_in = "teen_redboy_ADef",
	jump_fly_down = "teen_redboy_BDef",
	idle = "teen_redboy_ADef",
	attack_basic_c = "teen_redboy_ADef",
	jump_in = "teen_redboy_BDef",
	attack_basic_b = "teen_redboy_ADef",
	attack_basic_a = "teen_redboy_ADef",
	screen_block = "teen_redboy_ADef",
	Stun_loop = "teen_redboy_ADef",
	death_in = "teen_redboy_BDef",
	samadhi_loop = "teen_redboy_BDef",
	samadhi_out = "teen_redboy_BDef",
	jump_end = "teen_redboy_BDef",
	baculo = "teen_redboy_BDef",
	death_hit = "teen_redboy_BDef",
	talk_02 = "teen_redboy_BDef",
	jump_in_02 = "teen_redboy_BDef",
	Stun_end = "teen_redboy_ADef",
	jump_fly_up_02 = "teen_redboy_BDef",
	jump_fly_up = "teen_redboy_BDef",
	jump_fly_down_02 = "teen_redboy_BDef",
	summon = "teen_redboy_ADef",
	samadhi = "teen_redboy_BDef",
	walk = "teen_redboy_ADef",
	walk_down = "teen_redboy_ADef",
	talk = "teen_redboy_BDef",
	jump_out = "teen_redboy_BDef",
	fireabsorb = "teen_redboy_BDef",
	jump_end_2 = "teen_redboy_BDef"
}
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "teen_redboy_ADef"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].scale = vv(tt.scale)
tt.render.sid_debug_circle = 2
tt.render.sprites[tt.render.sid_debug_circle] = E:clone_c("sprite")
tt.render.sprites[tt.render.sid_debug_circle].z = Z_DECALS
tt.render.sprites[tt.render.sid_debug_circle].animated = false
tt.render.sprites[tt.render.sid_debug_circle].name = "decal_tower_hover_default_0009"
tt.render.sprites[tt.render.sid_debug_circle].scale = vv(1)
tt.render.sprites[tt.render.sid_debug_circle].scale_mult = 0.7142857142857143
tt.render.sprites[tt.render.sid_debug_circle].hidden = true
tt.render.sprites[tt.render.sid_debug_circle].color = {255, 0, 0}
tt.unit.show_blood_pool = false
tt.spawn_pos = b.spawn_pos
tt.main_script.insert = scripts.boss_redboy_teen.insert
tt.main_script.update = scripts.boss_redboy_teen.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_basic_b"
tt.melee.attacks[1].hit_time = fts(23)
tt.melee.attacks[1].hit_fx = "fx_redboy_teen_hit"
tt.melee.attacks[1].hit_offset = v(55 * tt.scale, 5)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_basic_c"
tt.melee.attacks[2].chance = 0.2
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].hit_decal = nil
tt.melee.attacks[1].hit_fx = "fx_redboy_teen_hit"
tt.melee.attacks[3] = E:clone_c("area_attack")
tt.melee.attacks[3].cooldown = b.area_attack.cooldown
tt.melee.attacks[3].damage_max = b.area_attack.damage_max
tt.melee.attacks[3].damage_min = b.area_attack.damage_min
tt.melee.attacks[3].damage_type = b.area_attack.damage_type
tt.melee.attacks[3].include_blocked = true
tt.melee.attacks[3].hit_offset = v(55 * tt.scale, 5)
tt.melee.attacks[3].damage_radius = b.area_attack.damage_radius
tt.melee.attacks[3].include_blocked = true
tt.melee.attacks[3].animation = "attack_basic_a"
tt.melee.attacks[3].vis_flags = F_BLOCK
tt.melee.attacks[3].hit_time = fts(19)
tt.melee.attacks[3].hit_fx = "fx_nine_tailed_fox_tp_stun_decal"
tt.melee.attacks[3].sound = "EnemyCrocBasicMelee"
tt.melee.attacks[3].chance = 0.4
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "summon"
tt.timed_attacks.list[1].first_cooldown = b.groundfire.first_cooldown
tt.timed_attacks.list[1].cooldown = b.groundfire.cooldown
tt.timed_attacks.list[1].cast_time = fts(20)
tt.timed_attacks.list[1].entity = "decal_redboy_teen_skyrock"
tt.timed_attacks.list[1].decal = "fx_redboy_teen_floor_fire_decal"
tt.timed_attacks.list[1].decal_offset = v(20 * tt.scale, 0)
tt.timed_attacks.list[1].nodes_limit = b.groundfire.nodes_limit
tt.timed_attacks.list[2] = E:clone_c("custom_attack")
tt.timed_attacks.list[2].animation = "screen_block"
tt.timed_attacks.list[2].first_cooldown = b.heartfire.first_cooldown
tt.timed_attacks.list[2].cooldown = b.heartfire.cooldown
tt.timed_attacks.list[2].cast_time = fts(44)
tt.timed_attacks.list[2].fx_time = fts(20)
tt.timed_attacks.list[2].duration = b.heartfire.duration
tt.timed_attacks.list[2].nodes_limit = b.heartfire.nodes_limit
tt.timed_attacks.list[2].hand_fx = "fx_redboy_teen_hand"
tt.timed_attacks.list[2].hand_fx_offset = v(-20 * tt.scale, 70 * tt.scale)
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].animation_start = "samadhi"
tt.timed_attacks.list[3].animation_loop = "samadhi_loop"
tt.timed_attacks.list[3].animation_end = "samadhi_out"
tt.timed_attacks.list[3].activate_on_positions = b.skyfire.activate_on_positions
tt.timed_attacks.list[3].cast_time = fts(55)
tt.timed_attacks.list[4] = E:clone_c("area_attack")
tt.timed_attacks.list[4].animation = "fireabsorb"
tt.timed_attacks.list[4].absorb_time = fts(25)
tt.timed_attacks.list[4].cast_time = fts(46)
tt.timed_attacks.list[4].damage_max = b.fireabsorb.damage_max
tt.timed_attacks.list[4].damage_min = b.fireabsorb.damage_min
tt.timed_attacks.list[4].damage_type = b.fireabsorb.damage_type
tt.timed_attacks.list[4].damage_radius = b.fireabsorb.damage_radius
tt.timed_attacks.list[4].minimum_fires = b.fireabsorb.minimum_fires
tt.timed_attacks.list[4].absorb_radius = b.fireabsorb.absorb_radius
tt.timed_attacks.list[4].nodes_limit = b.fireabsorb.nodes_limit
tt.timed_attacks.list[4].cooldown = b.fireabsorb.cooldown
tt.timed_attacks.list[4].first_cooldown = b.fireabsorb.first_cooldown
tt.timed_attacks.list[4].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[4].vis_flags = bor(F_AREA)
tt.timed_attacks.list[4].decal = "fx_redboy_fireabsorb_decal"
tt.timed_attacks.list[5] = E:clone_c("custom_attack")
tt.timed_attacks.list[5].animation_start = "Stun_in"
tt.timed_attacks.list[5].animation_loop = "Stun_loop"
tt.timed_attacks.list[5].animation_end = "Stun_end"
tt.timed_attacks.list[5].nodes_limit = b.stun_towers.nodes_limit
tt.timed_attacks.list[5].cooldown = b.stun_towers.cooldown
tt.timed_attacks.list[5].first_cooldown = b.stun_towers.first_cooldown
tt.timed_attacks.list[5].side = b.stun_towers.side
tt.timed_attacks.list[5].disabled = true
tt.change_path_node_start_pos = b.change_path.node_start_pos
tt.change_path_target = b.change_path.target
tt.change_path_meteorite_side = b.change_path.meteorite_side
tt.vis.flags_jumping = bor(F_ENEMY, F_BOSS)
tt.vis.bans_jumping = bor(F_RANGED, F_BLOCK, F_MOD)
tt.vis.flags_normal = bor(F_ENEMY, F_BOSS)
tt.vis.bans_normal = 0

tt = E:register_t("enemy_citizen", "enemy")
E:add_comps(tt, "melee")
b = balance.enemies.wukong.citizen
tt.main_script.insert = scripts.enemy_citizen.insert
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(22, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 108
tt.info.i18n_key = "ENEMY_CITIZEN"
tt.info.portrait = "kr5_info_portraits_enemies_0113"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 10)
tt.melee.cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "stage33_pueblerino1"
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-13, -3, 26, 32)
tt = E:register_t("enemy_citizen_1", "enemy_citizen")
tt.info.i18n_key = "ENEMY_CITIZEN_1"
tt = E:register_t("enemy_citizen_2", "enemy_citizen")
tt.melee.attacks[1].hit_time = fts(8)
tt.render.sprites[1].prefix = "stage33_pueblerino2"
tt.health_bar.offset = v(0, 43)
tt.info.portrait = "kr5_info_portraits_enemies_0115"
tt.info.i18n_key = "ENEMY_CITIZEN_2"
tt = E:register_t("enemy_citizen_3", "enemy_citizen")
tt.health_bar.offset = v(0, 35)
tt.melee.attacks[1].animation = "atack_2"
tt.melee.attacks[1].hit_times = {fts(19), fts(23), fts(27), fts(31)}
tt.melee.attacks[1].hit_fx = "fx_citizen_3_melee_1_hit"
tt.melee.attacks[1].hit_fx_offset = v(20, 10)
tt.melee.attacks[1].hit_fx_once = true
tt.render.sprites[1].prefix = "pueblerino_3_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.info.portrait = "kr5_info_portraits_enemies_0116"
tt.info.i18n_key = "ENEMY_CITIZEN_3"
tt = E:register_t("enemy_citizen_4", "enemy_citizen")
tt.health_bar.offset = v(0, 35)
tt.melee.attacks[1].animation = "atack_1"
tt.melee.attacks[1].hit_times = {fts(15), fts(22), fts(30), fts(36)}
tt.melee.attacks[1].hit_fx = "fx_citizen_4_melee_1_hit"
tt.melee.attacks[1].hit_fx_offset = v(20, 10)
tt.melee.attacks[1].hit_fx_once = true
tt.render.sprites[1].prefix = "pueblerino_4_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.info.portrait = "kr5_info_portraits_enemies_0117"
tt.info.i18n_key = "ENEMY_CITIZEN_4"
tt = E:register_t("generic_unit_spawn_scale")

E:add_comps(tt, "main_script")

tt.scale_down = 0.7
tt.scale_duration = 0.6
tt.scale_start_delay = 0.5
tt.push_and_pop_bans = scripts.generic_unit_spawn_scale.push_and_pop_bans
tt.main_script.update = scripts.generic_unit_spawn_scale.update
tt = E:register_t("enemy_terracota", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.terracota
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(27, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 1
tt.info.portrait = "kr5_info_portraits_enemies_0120"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 15)
tt.unit.blood_color = BLOOD_NONE
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(30)
tt.melee.attacks[1].hit_fx = "fx_terracota_hit"
tt.melee.attacks[1].hit_fx_offset = v(27, 10)
tt.melee.attacks[1].hit_fx_once = true
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "terracota"
tt.render.sprites[1].angles.walk = {"walk", "walkup", "walkdown"}
tt.ui.click_rect = r(-13, -3, 26, 32)
tt.main_script.update = scripts.enemy_terracota.update
tt = E:register_t("enemy_big_terracota", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.big_terracota
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(27, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 48)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 1
tt.info.portrait = "kr5_info_portraits_enemies_0121"
tt.unit.hit_offset = v(0, 24)
tt.unit.head_offset = v(0, 30)
tt.unit.mod_offset = v(0, 25)
tt.unit.blood_color = BLOOD_NONE
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].hit_fx = "fx_terracota_hit"
tt.melee.attacks[1].hit_fx_offset = v(27, 10)
tt.melee.attacks[1].hit_fx_once = true
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "big_terracota"
tt.render.sprites[1].angles.walk = {"walk", "walkup", "walkdown"}
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.main_script.update = scripts.enemy_terracota.update
tt = E:register_t("enemy_palace_guard", "enemy")

E:add_comps(tt, "melee")

b = balance.enemies.wukong.palace_guard
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 113
tt.info.portrait = "kr5_info_portraits_enemies_0118"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 20)
tt.unit.mod_offset = v(0, 15)
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "attack_01"
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "attack_02"
tt.melee.attacks[2].hit_time = fts(10)
tt.melee.attacks[2].cooldown = b.special_attack.cooldown
tt.melee.attacks[2].damage_max = b.special_attack.damage_max
tt.melee.attacks[2].damage_min = b.special_attack.damage_min
tt.melee.attacks[2].damage_type = b.special_attack.damage_type
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "palace_guard"
tt.render.sprites[1].angles.walk = {"walk", "walkup", "walkdown"}
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-13, -3, 26, 32)
tt = E:register_t("enemy_golden_eyed", "enemy")

local b = balance.enemies.wukong.golden_eyed

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 121
tt.info.portrait = "kr5_info_portraits_enemies_0126"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(55, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 80)
tt.main_script.insert = scripts.enemy_golden_eyed.insert
tt.main_script.update = scripts.enemy_golden_eyed.update
tt.main_script.remove = scripts.enemy_golden_eyed.remove
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_times = {fts(20)}
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].hit_offset = v(50, 15)
tt.melee.attacks[1].type = "area"
tt.melee.attacks[1].vis_bans = F_FLYING
tt.melee.attacks[1].vis_flags = F_RANGED
tt.melee.attacks[1].damage_bans = F_FLYING
tt.melee.attacks[1].damage_flags = F_AREA
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].hit_fx = "fx_golden_eyed_melee_hit"
tt.melee.attacks[1].sound = "EnemyGoldenEyedMelee"
tt.timed_attacks.list[1] = E:clone_c("aura_attack")
tt.timed_attacks.list[1].animation = "skill1"
tt.timed_attacks.list[1].cast_time = fts(24)
tt.timed_attacks.list[1].cooldown = b.aura.cooldown
tt.timed_attacks.list[1].max_range = b.aura.trigger_range
tt.timed_attacks.list[1].min_targets = b.aura.min_targets
tt.timed_attacks.list[1].nodes_limit_start = b.aura.nodes_limit_start
tt.timed_attacks.list[1].nodes_limit_end = b.aura.nodes_limit_end
tt.timed_attacks.list[1].aura = "aura_enemy_golden_eyed"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[1].sound = "EnemyGoldenEyedAura"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "goldeneye_beast_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-25, -3, 50, 50)
tt.unit.hit_offset = v(0, 23)
tt.unit.head_offset = v(0, 35)
tt.unit.marker_offset = v(-1, 0)
tt.unit.mod_offset = v(0, 23)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_POLYMORPH, F_DRILL, F_INSTAKILL, F_DISINTEGRATED, F_EAT)
tt.sound_events.death = "EnemyGoldenEyedDeath"
tt = E:register_t("aura_enemy_golden_eyed", "aura")
b = balance.enemies.wukong.golden_eyed.aura
tt.aura.duration = b.duration
tt.aura.radius = b.aura_radius
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = bor(F_RANGED, F_AREA)
tt.aura.mod = "mod_enemy_golden_eyed_buff"
tt.aura.cycle_time = b.cycle_time
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.filter_source = true
tt = E:register_t("fx_golden_eyed_melee_hit", "fx")
-- tt.render.sprites[1].exo = true
tt.render.sprites[1].prefix = "goldeneye_beast_hit"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].hide_after_runs = 1
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("mod_enemy_golden_eyed_buff", "modifier")
b = balance.enemies.wukong.golden_eyed.aura

E:add_comps(tt, "render", "fast", "tween")

tt.main_script.insert = scripts.mod_enemy_golden_eyed_buff.insert
tt.main_script.update = scripts.mod_enemy_golden_eyed_buff.update
tt.main_script.remove = scripts.mod_enemy_golden_eyed_buff.remove
tt.modifier.use_mod_offset = false
tt.fast.factor = b.mod.speed_factor
tt.modifier.duration = b.mod.duration
tt.target_self = b.target_self
tt.render.sprites[1].name = "goldeneye_beast_modifier"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {0.5, 255}, {b.mod.duration - 0.5, 255}, {b.mod.duration, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vv(0.9)}, {0.3, vv(1.1)}, {0.6, vv(0.9)}}
tt.tween.props[2].loop = true
tt = E:register_t("golden_eyed_shadow", "decal")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "goldeneye_beast_shadow"
tt.render.sprites[1].z = Z_DECALS
tt = E:register_t("enemy_doom_bringer", "enemy")

E:add_comps(tt, "melee", "timed_attacks")

b = balance.enemies.wukong.doom_bringer
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(38, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 59)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 122
tt.info.portrait = "kr5_info_portraits_enemies_0127"
tt.unit.hit_offset = v(0, 26)
tt.unit.head_offset = v(0, 23)
tt.unit.mod_offset = v(0, 27)
tt.main_script.update = scripts.enemy_doom_bringer.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_time = fts(9)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "skill_1"
tt.timed_attacks.list[1].first_cooldown = b.tower_curse.first_cooldown
tt.timed_attacks.list[1].cast_time = fts(22)
tt.timed_attacks.list[1].cooldown = b.tower_curse.cooldown
tt.timed_attacks.list[1].nodes_limit = b.tower_curse.nodes_limit
tt.timed_attacks.list[1].max_range = b.tower_curse.range
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].mod = "mod_doom_bringer_tower_block"
tt.timed_attacks.list[1].mark_mod = "mod_doom_bringer_tower_block_mark"
tt.timed_attacks.list[1].sound = "EnemyDoomBringerStun"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "doom_bringer_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-19, -5, 38, 43)
tt.sound_events.death = "EnemyDoomBringerDeath"
tt = E:register_t("enemy_demon_minotaur", "enemy")
b = balance.enemies.wukong.demon_minotaur

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 80)
tt.info.enc_icon = 120
tt.info.portrait = "kr5_info_portraits_enemies_0125"
tt.unit.hit_offset = v(0, 26)
tt.unit.head_offset = v(0, 7)
tt.unit.mod_offset = v(0, 14)
tt.main_script.update = scripts.enemy_demon_minotaur.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(41)
tt.melee.attacks[1].hit_fx = "fx_demon_minotaur_hit"
tt.melee.attacks[1].hit_offset = v(37, 10)
tt.melee.attacks[1].sound = "EnemyDemonMinotaurHeadButt"
tt.melee.attacks[1].animation = "mele_1"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "melee_2"
tt.melee.attacks[2].chance = 0.5
tt.melee.attacks[2].hit_time = fts(44)
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "charge"
tt.timed_attacks.list[1].max_duration = b.charge.max_duration
tt.timed_attacks.list[1].speed = b.charge.speed
tt.timed_attacks.list[1].charge_in_speed = 60
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].range_jump = b.charge.range_jump
tt.timed_attacks.list[1].range_damage = b.charge.range_damage
tt.timed_attacks.list[1].damage_min = b.charge.damage_min
tt.timed_attacks.list[1].damage_max = b.charge.damage_max
tt.timed_attacks.list[1].damage_type = b.charge.damage_type
tt.timed_attacks.list[1].particles_name_a = "ps_enemy_demon_minotaur_charge_a"
tt.timed_attacks.list[1].mod_stun = "mod_stun"
tt.timed_attacks.list[1].particles_name_b = "ps_enemy_demon_minotaur_charge_b"
tt.timed_attacks.list[1].sound_loop = "EnemyDemonMinotaurChargeTrample"
tt.timed_attacks.list[1].sound_attack = "EnemyDemonMinotaurChargeStop"
tt.timed_attacks.list[1].decal_crack = "decal_demon_minotaur_area_crack"
tt.timed_attacks.list[1].decal_smoke = "decal_demon_minotaur_area_smoke"
tt.timed_attacks.list[1].hit_fx = "fx_demon_minotaur_hit"
tt.timed_attacks.list[1].rebote_fx = "fx_demon_minotaur_rebote"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "demon_minotaur_unit"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].angles.charge = {"charge", "charge_up", "charge_down"}
tt.render.sprites[1].angles.charge_attack_in = {"charge_attack_in", "charge_attack_in", "charge_attack_in"}
tt.render.sprites[1].angles.rebote = {"rebote", "rebote", "rebote_frente"}
tt.render.sprites[1].angles_custom = {
	charge = {55, 115, 245, 305}
}
tt.ui.click_rect = r(-30, -3, 60, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_INSTAKILL, F_POLYMORPH, F_DISINTEGRATED, F_CANNIBALIZE, F_EAT)
tt.sound_events.insert = "EnemyDemonMinotaurChargeWarning"
tt.sound_events.death = "EnemyDemonMinotaurDeath"

tt = E:register_t("decal_hellfire_warlock_summon_decal", "decal_scripted")
tt.main_script.update = scripts.decal_hellfire_warlock_summon_decal.update
tt.render.sprites[1].prefix = "hellfire_warlock_summon_decal"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS

tt = RT("enemy_desert_spider", "enemy")
AC(tt, "melee", "death_spawns")
anchor_y = 0.19
anchor_x = 0.5
image_y = 68
image_x = 96
tt.enemy.gold = 80
tt.enemy.melee_slot = vec_2(35, 0)
tt.health.armor = 0
tt.health.hp_max = 1150
tt.health.magic_armor = 0.5
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.offset = vec_2(0, 51)
tt.info.portrait = "info_portraits_enemies_0037"
tt.info.enc_icon = 31
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "SpiderAttack"
tt.melee.attacks[1].mod = "mod_desert_spider_poison"
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.19)
tt.render.sprites[1].prefix = "enemy_sarelgaz_small"
tt.render.sprites[1].shader = "p_tint"
tt.render.sprites[1].shader_args = {
	tint_color = {200 / 255, 200 / 255, 120 / 255, 1}
}
tt.sound_events.death = "DeathEplosion"
tt.ui.click_rect.size = vec_2(54, 50)
tt.ui.click_rect.pos.x = -27
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 23)
tt.unit.mod_offset = vec_2(adx(45), ady(35))
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_POISON, F_SKELETON)
tt.death_spawns.concurrent_with_death = true
tt.death_spawns.name = "controller_desert_spider_death"
tt.unit.can_explode = false

tt = RT("mod_desert_spider_poison", "mod_poison")
tt.dps.damage_min = 1
tt.dps.damage_max = 2
tt.dps.damage_every = fts(6)
tt.modifier.duration = 5

tt = RT("controller_desert_spider_death")
AC(tt, "main_script", "pos")
tt.main_script.insert = scripts.controller_desert_spider_death.insert
tt.radius = 100
tt.max_count = 5
tt.vis_bans = F_NONE
tt.vis_flags = bor(F_RANGED, F_MOD)

tt = RT("bullet_desert_spider_death", "arrow")
tt.render.sprites[1].name = "regson_heal_ball_travel"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].color = {255, 200, 0}
tt.shader = "p_tint"
tt.shader_args = {
	tint_color = {200 / 255, 200 / 255, 120 / 255, 1}
}
tt.bullet.mods = {"mod_desert_spider_lamber"}
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_NONE

tt = RT("mod_desert_spider_lamber", "mod_freeze")
tt.modifier.duration = 6
tt.modifier.vis_flags = F_MOD
tt.main_script.insert = scripts.mod_desert_spider_lamber.insert
tt.main_script.remove = scripts.mod_desert_spider_lamber.remove
tt.freeze_decal_name = "decal_desert_spider_lamber"
tt.harden_factor = 0.1

tt = RT("mod_desert_spider_speedup", "mod_slow")
tt.modifier.duration = 6
-- > 1 的 factor 等价于加速
tt.slow.factor = 1.25

tt = RT("decal_desert_spider_lamber", "decal")
tt.shader = "p_tint"
tt.shader_args = {
	tint_color = {200 / 255, 200 / 255, 120 / 255, 1}
}

-- Dragon world enemy templates
tt = RT("enemy_dragons", "enemy")
tt.main_script.insert = scripts.enemy_dragons.insert
tt.gold_multiplier = balance.enemies.dragons.gold_multiplier
tt = RT("enemy_basic_lava", "enemy_dragons")

E:add_comps(tt, "melee")

b = balance.enemies.dragons.basic_lava
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 32)
tt.info.enc_icon = 127
tt.info.portrait = "kr5_info_portraits_enemies_0129"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 6)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.update = scripts.enemy_basic_lava.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "mele"
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.melee.attacks[1].fn_can = scripts.enemy_basic_lava.fn_can_attack_basic
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].animation = "firebreath"
tt.melee.attacks[2].hit_times = {fts(18), fts(24)}
tt.melee.attacks[2].cooldown = 0
tt.melee.attacks[2].damage_max = b.special_attack.damage_max
tt.melee.attacks[2].damage_min = b.special_attack.damage_min
tt.melee.attacks[2].damage_type = b.special_attack.damage_type
tt.melee.attacks[2].fn_can = scripts.enemy_basic_lava.fn_can_attack_breath
tt.melee.attacks[2].sound = "EnemyLavaBasicFlameBreath"
tt.melee.attacks[2].sound_args = {
	delay = fts(15)
}
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "lava_basic_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_back", "walk_front"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vv(0.7)
tt.render.sprites[2].name = "lava_evolve_shadow"
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].hidden = true
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.ui.click_rect = r(-13, -3, 26, 32)
tt.evolve_mod = "mod_enemy_alfa_lava_evolve"
tt.evolve_sound = "EnemyLavaBasicEvolution"
tt.transform_anim_in = "evolve_in"
tt.transform_anim_loop = "evolve_loop"
tt.transform_anim_out = "evolve_out"
tt = RT("enemy_tanky_draconian", "enemy_dragons")

E:add_comps(tt, "melee")

b = balance.enemies.dragons.tanky_draconian
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 129
tt.info.portrait = "kr5_info_portraits_enemies_0131"
tt.unit.hit_offset = v(0, 18)
tt.unit.head_offset = v(0, 13)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "mele"
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_fx = "fx_enemy_tanky_draconian_hit"
tt.melee.attacks[1].hit_offset = v(30, 15)
tt.melee.attacks[1].sound = "EnemyLavaTankyAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(20)
}
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "lava_tanky_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-16, 0, 32, 36)
tt.sound_events.death = "EnemyLavaTankyDeath"
tt = RT("enemy_evolved_lava", "enemy_dragons")

E:add_comps(tt, "melee", "tween")

b = balance.enemies.dragons.evolved_lava
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.flight_height = 40
tt.fly_strenght = 5
tt.fly_frequency = 13
tt.minimum_fly_duration = b.minimum_fly_duration
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 55 + tt.flight_height)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.enc_icon = 128
tt.info.portrait = "kr5_info_portraits_enemies_0130"
tt.unit.hit_offset = v(0, 14 + tt.flight_height)
tt.unit.head_offset = v(0, 20)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15 + tt.flight_height)
tt.unit.show_blood_pool = false
-- TODO: add tween props
-- tt.unit.fade_time_after_death = 0.6
-- tt.info.fn = scripts.enemy_evolved_lava.get_info
tt.main_script.insert = scripts.enemy_evolved_lava.insert
tt.main_script.update = scripts.enemy_evolved_lava.update
tt.melee.attacks[1].hit_times = {fts(6), fts(15), fts(22)}
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max / #tt.melee.attacks[1].hit_times
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min / #tt.melee.attacks[1].hit_times
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].animation = "mele"
tt.melee.attacks[1].hit_fx = "fx_enemy_evolved_lava_melee_hit"
tt.melee.attacks[1].hit_offset = v(30, 5)
tt.melee.attacks[1].sound = "EnemyCrocBasicMelee"
tt.melee.attacks[2] = E:clone_c("area_attack")
tt.melee.attacks[2].animation = "firebreath"
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].cooldown = b.special_attack.cooldown
tt.melee.attacks[2].damage_max = b.special_attack.damage_max
tt.melee.attacks[2].damage_min = b.special_attack.damage_min
tt.melee.attacks[2].damage_type = b.special_attack.damage_type
tt.melee.attacks[2].damage_radius = b.special_attack.radius
tt.melee.attacks[2].hit_offset = v(30, 0)
tt.melee.attacks[2].mod = "mod_enemy_evolved_lava_dot"
tt.melee.attacks[2].sound = "EnemyLavaEvolverFlameBreath"
tt.melee.attacks[2].sound_args = {
	delay = fts(20)
}
tt.motion.max_speed = b.speed
tt.speed_fly_mult = b.speed_fly_mult
tt.render.sprites[1].prefix = "lava_evolve_creep"
tt.render.sprites[1].angles.idle_ground = {"idle"}
tt.render.sprites[1].angles.idle_fly = {"fly"}
tt.render.sprites[1].angles.walk_ground = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].angles.walk_fly = {"fly", "fly_up", "fly_down"}
tt.render.sprites[1].angles.death_ground = {"death"}
tt.render.sprites[1].angles.death_fly = {"death_fly"}
tt.render.sprites[1].angles.idle = tt.render.sprites[1].angles.idle_fly
tt.render.sprites[1].angles.walk = tt.render.sprites[1].angles.walk_fly
tt.render.sprites[1].angles.death = tt.render.sprites[1].angles.death_fly
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].scale = vv(1)
tt.render.sprites[2].name = "basic_storm_shadow"
tt.sound_events.death = "EnemyTuskedBrawlerDeath"
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.vis.bans = bor(F_BLOCK)
tt.ui.click_rect = r(-13, -3 + tt.flight_height, 26, 32)
tt.landing_anim = "engage"
tt.landing_duration_evolve = fts(12)
tt.landing_duration = fts(3)
tt.landing_delay = fts(11)
tt.landing_damage_fx = "fx_enemy_evolved_lava_landing_hit"
tt.landing_damage_min = b.landing_attack.damage_min
tt.landing_damage_max = b.landing_attack.damage_max
tt.landing_damage_type = b.landing_attack.damage_type
tt.landing_damage_radius = b.landing_attack.radius
tt.landing_damage_radius_find = b.landing_attack.radius_find
tt.landing_damage_offset = v(20, 0)
tt.landing_damage_vis_flags = F_AREA
tt.landing_damage_vis_bans = F_FLYING
tt.tween.remove = false
tt.tween.props[1].disabled = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{0, v(0, tt.flight_height)}, {tt.landing_duration, v(0, 0)}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].disabled = true
tt.tween.props[2].name = "scale"
tt.tween.props[2].interp = "sine"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{0, vv(1)}, {tt.landing_duration, vv(1)}}
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].disabled = true
tt.tween.props[3].name = "offset"
tt.tween.props[3].interp = "sine"
tt.tween.props[3].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[3].loop = true
tt.tween.props[3].sprite_id = 1
tt.tween.props[4] = E:clone_c("tween_prop")
tt.tween.props[4].disabled = false
tt.tween.props[4].loop = false
tt.tween.props[4].name = "offset"
tt.tween.props[4].interp = "sine"
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].keys = {{0, v(0, 0)}, {tt.landing_duration_evolve, v(0, tt.flight_height)}}
tt.tween.props[5] = E:clone_c("tween_prop")
tt.tween.props[5].disabled = false
tt.tween.props[5].loop = false
tt.tween.props[5].name = "offset"
tt.tween.props[5].interp = "sine"
tt.tween.props[5].sprite_id = 2
tt.tween.props[5].keys = {{0, vv(1)}, {tt.landing_duration_evolve, vv(0.7)}}

tt = RT("enemy_alfa_lava", "enemy_dragons")
b = balance.enemies.dragons.alfa_lava
E:add_comps(tt, "melee", "timed_attacks")
tt.info.enc_icon = 130
tt.info.portrait = "kr5_info_portraits_enemies_0132"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(36, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.main_script.update = scripts.enemy_alfa_lava.update
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].animation = "mele"
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].hit_offset = v(40, 0)
tt.melee.attacks[1].sound = "EnemyLavaAlfaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(18)
}
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].animation = "puke"
tt.timed_attacks.list[1].first_cooldown = b.lava_vomit_attack.first_cooldown
tt.timed_attacks.list[1].cooldown_max = b.lava_vomit_attack.cooldown_max
tt.timed_attacks.list[1].cooldown_min = b.lava_vomit_attack.cooldown_min
tt.timed_attacks.list[1].nodes_limit = b.lava_vomit_attack.nodes_limit
tt.timed_attacks.list[1].cast_time = fts(48)
tt.timed_attacks.list[1].jump_damage_times = {fts(6), fts(13), fts(21), fts(30), fts(37)}
tt.timed_attacks.list[1].jump_damage_max = b.lava_vomit_attack.jump.damage_max / #tt.timed_attacks.list[1].jump_damage_times
tt.timed_attacks.list[1].jump_damage_min = b.lava_vomit_attack.jump.damage_min / #tt.timed_attacks.list[1].jump_damage_times
tt.timed_attacks.list[1].jump_damage_radius = b.lava_vomit_attack.jump.radius
tt.timed_attacks.list[1].jump_damage_type = b.lava_vomit_attack.jump.damage_type
tt.timed_attacks.list[1].jump_damage_vis_flags = F_AREA
tt.timed_attacks.list[1].jump_damage_vis_bans = bor(F_FLYING, F_ENEMY)
tt.timed_attacks.list[1].bullet = "bullet_alfa_lava_vomit"
tt.timed_attacks.list[1].bullet_start_offset = v(6, 40)
tt.timed_attacks.list[1].only_while_blocked = b.lava_vomit_attack.only_while_blocked
tt.timed_attacks.list[1].sound = "EnemyLavaAlfaEvolverShot"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "lava_alpha_creep"
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-24, 0, 50, 53)
tt.unit.hit_offset = v(0, 25)
tt.unit.head_offset = v(0, 10)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 15)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.show_blood_pool = false
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt = RT("enemy_basic_acid", "enemy_dragons")

local b = balance.enemies.dragons.basic_acid

E:add_comps(tt, "melee", "timed_attacks")

tt.info.enc_icon = 124
tt.info.portrait = "kr5_info_portraits_enemies_0133"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(24, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 34)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.motion.max_speed = b.speed
tt.main_script.update = scripts.enemy_basic_acid.update
tt.evolve_mod = "mod_enemy_alfa_acid_evolve"
tt.evolve_sound = "EnemyAcidBasicEvolution"
tt.evolve_sound_args = {
	delay = fts(20)
}
tt.transform_anim_in = "evolve_in"
tt.transform_anim_loop = "evolve_loop"
tt.transform_anim_out = "evolve_out"
tt.render.sprites[1].prefix = "acid_basic_creep"
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].ignore_start = true
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_DECALS
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].animation = "melee_attk"
tt.melee.attacks[1].hit_fx = "fx_enemy_basic_acid_melee_hit"
tt.melee.attacks[1].sound = "EnemyAcidBasicAttack"
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].bullet = "bullet_enemy_basic_acid"
tt.timed_attacks.list[1].shoot_time = fts(12)
tt.timed_attacks.list[1].cooldown = b.ranged_attack.cooldown
tt.timed_attacks.list[1].max_range = b.ranged_attack.max_range
tt.timed_attacks.list[1].min_range = b.ranged_attack.min_range
tt.timed_attacks.list[1].bullet_start_offset = {v(0, 50)}
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].animation = "ranged_attk"
tt.timed_attacks.list[1].filter_targets_with_mod = "mod_enemy_basic_acid_armor_reduction"
tt.ui.click_rect = r(-17, 0, 34, 35)
tt.unit.head_offset = v(0, 7)
tt.unit.hit_offset = v(0, 10)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 7)
tt.unit.size = UNIT_SIZE_SMALL
tt.vis.flags = bor(F_ENEMY)
tt.sound_events.death = "EnemyNoxiousHorrorDeath"
tt = RT("enemy_evolved_acid", "enemy_dragons")

local b = balance.enemies.dragons.evolved_acid

E:add_comps(tt, "timed_attacks", "tween")

tt.info.enc_icon = 125
tt.info.portrait = "kr5_info_portraits_enemies_0134"
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(25, 0)
tt.enemy.lives_cost = b.lives_cost
tt.gold_config = b.gold
tt.health.hp_max = b.hp
tt.hp_config = b.hp
tt.flight_height = 25
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 47 + tt.flight_height)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.motion.max_speed = b.speed
tt.speed_config = b.speed
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "spawn"
tt.timed_attacks.list[1].cooldown = b.summon.cooldown
tt.timed_attacks.list[1].first_cooldown = b.summon.first_cooldown
tt.timed_attacks.list[1].nodes_limit = b.summon.nodes_limit
tt.timed_attacks.list[1].cast_time = fts(34)
tt.timed_attacks.list[1].max_nodes_range = b.summon.max_nodes_range
tt.timed_attacks.list[1].min_nodes_range = b.summon.min_nodes_range
tt.timed_attacks.list[1].bullet_start_offset = v(13, 0 + tt.flight_height)
tt.timed_attacks.list[1].bullet = "bullet_enemy_evolved_acid_spawn"
tt.timed_attacks.list[2] = E:clone_c("bullet_attack")
tt.timed_attacks.list[2].animation = "attack"
tt.timed_attacks.list[2].bullet = "bullet_enemy_evolved_acid"
tt.timed_attacks.list[2].bullet_start_offset = {v(5, 50 + tt.flight_height)}
tt.timed_attacks.list[2].cooldown = b.ranged_attack.cooldown
tt.timed_attacks.list[2].max_range = b.ranged_attack.max_range
tt.timed_attacks.list[2].min_range = b.ranged_attack.min_range
tt.timed_attacks.list[2].shoot_time = fts(11)
tt.timed_attacks.list[2].vis_flags = bor(tt.timed_attacks.list[2].vis_flags, F_AREA, F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(tt.timed_attacks.list[2].vis_bans, F_FLYING)
tt.main_script.insert = scripts.enemy_evolved_acid.insert
tt.main_script.update = scripts.enemy_evolved_acid.update
tt.render.sprites[1].prefix = "evolved_acid_creep"
tt.render.sprites[1].angles.walk = {"run", "run_back", "run_front"}
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].hidden = false
tt.ui.click_rect = r(-23, -3 + tt.flight_height, 46, 38)
tt.unit.head_offset = v(0, 10)
tt.unit.hit_offset = v(0, 10 + tt.flight_height)
tt.unit.mod_offset = v(0, 7 + tt.flight_height)
tt.unit.marker_offset = v(0, 0)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.can_explode = false
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.vis.bans = bor(F_BLOCK)
tt.sound_events.death = "EnemyEvolvedAcidDeath"
tt.sound_events.death_args = {
	delay = fts(20)
}
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, 0)}, {fts(15), v(0, tt.flight_height)}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{fts(0), 255}, {fts(24), 255}, {fts(30), 0}}
tt.tween.props[2].loop = false
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].disabled = true
tt = RT("enemy_alfa_acid", "enemy_dragons")
b = balance.enemies.dragons.alfa_acid

E:add_comps(tt, "ranged", "timed_attacks", "tween")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(37, 0)
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = 40
tt.fly_strenght = 5
tt.fly_frequency = 13
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60 + tt.flight_height)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.info.enc_icon = 126
tt.info.portrait = "kr5_info_portraits_enemies_0135"
tt.main_script.update = scripts.enemy_alfa_acid.update
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].bullet = "bullet_enemy_alfa_acid"
tt.ranged.attacks[1].bullet_start_offset = {v(24, 54 + tt.flight_height)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range_variance = b.ranged_attack.max_range_variance
tt.ranged.attacks[1].shoot_time = fts(12)
tt.ranged.attacks[1].hold_advance = b.ranged_attack.hold_advance
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation = "evolve"
tt.timed_attacks.list[1].first_cooldown = b.evolve_shot.first_cooldown
tt.timed_attacks.list[1].cooldown = b.evolve_shot.cooldown
tt.timed_attacks.list[1].max_range = b.evolve_shot.max_range
tt.timed_attacks.list[1].min_range = b.evolve_shot.min_range
tt.timed_attacks.list[1].self_nodes_limit = b.evolve_shot.self_nodes_limit
tt.timed_attacks.list[1].target_nodes_limit = b.evolve_shot.target_nodes_limit
tt.timed_attacks.list[1].min_flight_time = fts(24)
tt.timed_attacks.list[1].max_flight_time = fts(36)
tt.timed_attacks.list[1].node_prediction_base = fts(10)
tt.timed_attacks.list[1].cast_time = fts(26)
tt.timed_attacks.list[1].bullet_start_offset = {v(20, 75 + tt.flight_height), v(-20, 75 + tt.flight_height)}
tt.timed_attacks.list[1].bullet = "bullet_enemy_alfa_acid_evolve"
tt.timed_attacks.list[1].mark_mod = "mod_enemy_alfa_acid_evolve_mark"
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_CUSTOM)
tt.timed_attacks.list[1].allowed_templates = {"enemy_basic_acid"}
tt.timed_attacks.list[1].nodes_front_offset = 7
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "alpha_acid_creep"
tt.render.sprites[1].angles.walk = {"run", "run_back", "run_front"}
tt.render.sprites[1].draw_order = DO_ENEMY_BIG
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "alpha_acid_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].hidden = false
tt.ui.click_rect = r(-32, tt.flight_height, 64, 60)
tt.unit.hit_offset = v(0, 20 + tt.flight_height)
tt.unit.head_offset = v(0, 10)
tt.unit.mod_offset = v(0, 15 + tt.flight_height)
tt.unit.marker_offset = v(0, 0)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.transformation_time = b.transformation_time
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.vis.bans = bor(tt.vis.bans, F_BLOCK)
tt.sound_events.death = "EnemyAlfaAcidDeath"
tt.sound_events.death_args = {
	delay = fts(21)
}
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[1].loop = true
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].keys = {{fts(0), 255}, {fts(27), 255}, {fts(34), 0}}
tt.tween.props[2].loop = false
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].disabled = true
tt = RT("enemy_alfa_acid_sheep", "decal_scripted")

E:add_comps(tt, "tween")

b = balance.enemies.dragons.alfa_acid.evolve_shot
tt.main_script.update = scripts.enemy_alfa_acid_sheep.update
tt.range = 30
tt.max_range_retarget = 200
tt.vis_flags_retarget = bor(F_RANGED, F_CUSTOM)
tt.vis_bans_retarget = 0
tt.allowed_templates = {"enemy_basic_acid"}
tt.mod = "mod_enemy_alfa_acid_evolve"
tt.die_ts = b.sheep_ttl
tt.render.sprites[1].prefix = "alpha_acid_sheep"
tt.render.sprites[1].name = "fly_out"
tt.render.sprites[1].offset = v(0, -11)
tt.render.sprites[1].sort_y_offset = -10
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {0.5, 0}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "offset"
tt.tween.props[2].keys = {{0, v(tt.render.sprites[1].offset.x, tt.render.sprites[1].offset.y)}, {0.5, v(55 + tt.render.sprites[1].offset.x, tt.render.sprites[1].offset.y)}}
tt.tween.remove = true
tt.tween.disabled = true
tt.sheep_sound = "EnemyAlfaAcidEvolverSheep"
tt = RT("enemy_basic_shadow", "enemy_dragons")

E:add_comps(tt, "tween")

b = balance.enemies.dragons.basic_shadow
tt.flight_height = 40
tt.info.enc_icon = 135
tt.info.portrait = "kr5_info_portraits_enemies_0136"
tt.unit.mod_offset = v(0, 12)
tt.unit.hit_offset = v(0, 15)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.ui.click_rect = r(-16, 0, 32, 28)
tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 31)
tt.transform_anim_in = "transform_in"
tt.transform_anim_loop = "transform_loop"
tt.transform_anim_loop_times = 1
tt.transform_anim_out = "transform_out"
tt.health.magic_armor = b.magic_armor
tt.main_script.update = scripts.enemy_basic_shadow.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "shadow_basic_creep"
tt.render.sprites[1].angles.walk_normal = {"walk", "walk_back", "walk_front"}
tt.render.sprites[1].angles.walk_shadow = {"walk_shadow", "walk_shadow_back", "walk_shadow_front"}
tt.render.sprites[1].angles.walk = table.deepclone(tt.render.sprites[1].angles.walk_normal)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].hidden = true
tt.vis.bans = bor(F_BLOCK)
tt.shadow_vis_bans = bor(F_RANGED)
tt.shadow_smoke_ps_dark = "ps_enemy_basic_shadow_trail_dark"
tt.shadow_smoke_ps = "ps_enemy_basic_shadow_trail"
tt.shadow_distance = b.shadow_distance
tt.shadow_distance_to_show = b.shadow_distance_to_show
tt.shadow_speed_mult = b.shadow_speed_mult
tt.shadow_min_duration = 1
tt.shadow_speed_nodes_limit = b.shadow_speed_nodes_limit
tt.evolve_mod = "mod_enemy_alfa_shadow_evolve"
tt.evolve_decal = "decal_enemy_basic_shadow_evolve"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{fts(0), v(0, 0)}, {fts(25), v(0, tt.flight_height)}}
tt.tween.props[1].loop = false
tt.tween.props[1].sprite_id = 1
tt = RT("enemy_evolved_shadow", "enemy_dragons")

E:add_comps(tt, "ranged")

b = balance.enemies.dragons.evolved_shadow
tt.info.enc_icon = 136
tt.info.portrait = "kr5_info_portraits_enemies_0137"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.flight_height = E:get_template("enemy_basic_shadow").flight_height
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, tt.flight_height + 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.main_script.insert = scripts.enemy_evolved_shadow.insert
tt.main_script.update = scripts.enemy_evolved_shadow.update
tt.motion.max_speed = b.speed
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].prefix = "shadow_evo_creep"
tt.render.sprites[1].angles.walk_normal = {"fly", "fly_up", "fly_down"}
tt.render.sprites[1].angles.walk_shadow = {"fly_shadow", "fly_up_shadow", "fly_down_shadow"}
tt.render.sprites[1].angles.walk = table.deepclone(tt.render.sprites[1].angles.walk_normal)
tt.render.sprites[1].angles.idle = table.deepclone(tt.render.sprites[1].angles.walk_normal)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.sound_events.death = "EnemyPatrollingVultureDeath"
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].bullet = "bullet_enemy_evolved_shadow"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 40 + tt.flight_height)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range_variance = b.ranged_attack.max_range_variance
tt.ranged.attacks[1].shoot_time = fts(16)
tt.ranged.attacks[1].hold_advance = b.ranged_attack.hold_advance
tt.ranged.attacks[1].idle_attack_anim = nil
tt.ui.click_rect = r(-18, tt.flight_height + 5, 36, 36)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 15)
tt.unit.head_offset = v(0, 7)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, tt.flight_height + 15)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.shadow_vis_bans = bor(F_RANGED)
tt.shadow_smoke_fx = "fx_enemy_evolved_shadow_burst"
tt.shadow_min_duration = 1
tt.sound_events.death = "EnemyShadowEvolvedDeath"
tt.invisibility_safe_nodes = b.invisibility_safe_nodes
tt = RT("enemy_alfa_shadow", "enemy_dragons")

local b = balance.enemies.dragons.alfa_shadow

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.ui.click_rect = r(-23, 0, 46, 60)
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health_bar.offset = v(0, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 26)
tt.unit.head_offset = v(0, 21)
tt.unit.mod_offset = v(0, 16)
tt.unit.show_blood_pool = false
tt.health.dead_lifetime = fts(126)
tt.motion.max_speed = b.speed
tt.sound_events.death = "Stage11MydriasIllusionDeath"
tt.enemy.gold = b.gold
tt.info.enc_icon = 137
tt.info.portrait = "kr5_info_portraits_enemies_0138"
tt.main_script.update = scripts.enemy_alfa_shadow.update
tt.melee.range = 72
tt.melee.attacks[1].animation = "mele"
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].hit_fx_offset = v(35, 17)
tt.melee.attacks[1].hit_fx = "fx_enemy_alfa_shadow_hit_melee"
tt.melee.attacks[1].sound = "EnemyShadowAlfaAttack"
tt.melee.attacks[1].sound_args = {
	delay = fts(10)
}
tt.ranged.attacks[1].bullet = "bullet_enemy_alfa_shadow"
tt.ranged.attacks[1].bullet_start_offset = {v(30, 60)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].shoot_time = fts(22)
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].animation = "ranged"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_in_fx = "fx_enemy_alfa_shadow_teleport_in"
tt.timed_attacks.list[1].animation_in = "teleport_in"
tt.timed_attacks.list[1].animation_loop = "teleport_loop"
tt.timed_attacks.list[1].animation_out = "teleport_out"
tt.timed_attacks.list[1].trail = "ps_enemy_alfa_shadow_teleport_trail"
tt.timed_attacks.list[1].speed_mult = 14
tt.timed_attacks.list[1].cast_time = fts(22)
tt.timed_attacks.list[1].first_cooldown = b.evolve_tp.first_cooldown
tt.timed_attacks.list[1].cooldown = b.evolve_tp.cooldown
tt.timed_attacks.list[1].max_nodes_range = b.evolve_tp.max_nodes_range
tt.timed_attacks.list[1].min_nodes_range = b.evolve_tp.min_nodes_range
tt.timed_attacks.list[1].tp_nodes_offset = 7
tt.timed_attacks.list[1].nodes_limit_end = b.evolve_tp.nodes_limit_end
tt.timed_attacks.list[1].nodes_limit_start = b.evolve_tp.nodes_limit_start
tt.timed_attacks.list[1].only_upstream = ({
	[0] = false,
	true
})[b.evolve_tp.only_upstream]
tt.timed_attacks.list[1].allowed_template = "enemy_basic_shadow"
tt.timed_attacks.list[1].mod = "mod_enemy_alfa_shadow_evolve"
tt.timed_attacks.list[1].mod_mark = "mod_enemy_alfa_shadow_evolve_mark"
tt.timed_attacks.list[1].not_while_blocked = b.evolve_tp.not_while_blocked
tt.render.sprites[1].prefix = "shadow_alpha_creep"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "fly_down", "walk_down"}
tt.render.sprites[1].animated = true
tt.sound_events.death = "EnemyShadowAlfaDeath"
tt = RT("enemy_basic_storm", "enemy_dragons")

E:add_comps(tt, "tween")

b = balance.enemies.dragons.basic_storm
tt.info.enc_icon = 131
tt.info.portrait = "kr5_info_portraits_enemies_0139"
tt.enemy.gold = b.gold
tt.flight_height = 40
tt.fly_strenght = 0
tt.fly_frequency = 10
tt.enemy.melee_slot = v(41, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 37 + tt.flight_height)
tt.motion.max_speed = b.speed
tt.evolve_mod = "mod_enemy_alfa_storm_evolve"
tt.evolve_sound = "EnemyStormBasicEvolution"
tt.transform_anim_in = "evolve_in"
tt.render.sprites[1].prefix = "basic_storm_creep"
tt.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "basic_storm_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.main_script.update = scripts.enemy_basic_storm.update
tt.ui.click_rect = r(-18, tt.flight_height, 36, 32)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 7)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, tt.flight_height + 7)
tt.unit.size = UNIT_SIZE_SMALL
tt.unit.show_blood_pool = false
tt.vis.bans = bor(F_BLOCK, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.sound_events.death = "EnemyStormBasicDeath"
tt.sound_events.death_args = {
	delay = fts(15)
}
tt.tween.disabled = false
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "quad"
tt.tween.props[1].keys = {{fts(0), v(0, tt.flight_height)}, {fts(tt.fly_frequency), v(0, tt.flight_height - tt.fly_strenght)}, {fts(tt.fly_frequency * 2), v(0, tt.flight_height)}}
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].name = "alpha"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].keys = {{0, 255}, {0.5, 255}, {0.8, 0}}
tt.tween.props[2].disabled = true
tt.tween.props[1].loop = true
tt.tween.props[1].disabled = false
tt.tween.props[1].remove = false
tt = RT("enemy_evolved_storm", "enemy_dragons")

E:add_comps(tt, "timed_attacks", "tween")

b = balance.enemies.dragons.evolved_storm
tt.info.enc_icon = 132
tt.info.portrait = "kr5_info_portraits_enemies_0140"
tt.enemy.gold = b.gold
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.flight_height = 45
tt.health_bar.offset = v(0, tt.flight_height + 44)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.motion.max_speed = b.speed
tt.main_script.insert = scripts.enemy_evolved_storm.insert
tt.main_script.update = scripts.enemy_evolved_storm.update
tt.on_storm_charged = scripts.enemy_evolved_storm.on_storm_charged
tt.on_storm_uncharged = scripts.enemy_evolved_storm.on_storm_uncharged
tt.timed_attacks.list[1] = E:clone_c("area_attack")
tt.timed_attacks.list[1].animation = "attack"
tt.timed_attacks.list[1].cooldown = b.charged_attack.cooldown
tt.timed_attacks.list[1].first_cooldown = b.charged_attack.first_cooldown
tt.timed_attacks.list[1].damage_max = b.charged_attack.damage_max
tt.timed_attacks.list[1].damage_min = b.charged_attack.damage_min
tt.timed_attacks.list[1].damage_type = b.charged_attack.damage_type
tt.timed_attacks.list[1].damage_radius = b.charged_attack.damage_radius
tt.timed_attacks.list[1].hit_time = fts(17)
tt.timed_attacks.list[1].vis_flags = bor(F_AREA)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].min_targets = b.charged_attack.min_targets
tt.timed_attacks.list[1].removes_charged_status = b.charged_attack.removes_charged_status
tt.timed_attacks.list[1].fx = "fx_enemy_evolved_storm_attack"
tt.render.sprites[1].anchor = vv(0.5)
tt.render.sprites[1].prefix = "storm_evolve_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow_hard"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].scale = vv(1.15)
tt.ui.click_rect = r(-22, tt.flight_height - 10, 44, 40)
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(0, tt.flight_height + 5)
tt.unit.head_offset = v(0, 6)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, tt.flight_height + 5)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.show_blood_pool = false
tt.vis.flags = bor(F_ENEMY, F_FLYING)
tt.vis.bans = bor(F_BLOCK)
tt.render.sprites[1].scale = vv(1.15)
tt.render.sprites[2].scale = vv(1.15)
tt.sound_events.death = "EnemyStormBasicDeath"
tt.sound_events.death_args = {
	delay = fts(17)
}
tt.tween.props[1].name = "alpha"
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].keys = {{0, 255}, {0.7, 255}, {0.9, 0}}
tt.tween.props[1].loop = false
tt.tween.props[1].remove = false
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.loop = false
tt = RT("enemy_alfa_storm", "enemy_dragons")

local b = balance.enemies.dragons.alfa_storm

E:add_comps(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(35, 0)
tt.health.hp_max = b.hp
tt.health.magic_armor = b.magic_armor
tt.health.armor = b.armor
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 13)
tt.unit.head_offset = v(0, 16)
tt.unit.mod_offset = v(0, 10)
tt.unit.show_blood_pool = false
tt.health.dead_lifetime = 7
tt.ui.click_rect = r(-18, -3, 36, 40)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "alpha_storm_creep"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"run", "run_back", "run_front"}
tt.sound_events.death = "EnemyStormAlfaDeath"
tt.sound_events.death_args = {
	delay = fts(9)
}
tt.info.enc_icon = 133
tt.info.portrait = "kr5_info_portraits_enemies_0141"
tt.main_script.update = scripts.enemy_alfa_storm.update
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].animation = "basic_attack"
tt.melee.attacks[1].sound_hit = "EnemyStormAlfaMelee"
tt.ranged.attacks[1].bullet = "bullet_enemy_alfa_storm"
tt.ranged.attacks[1].bullet_start_offset = {v(38, 53)}
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].shoot_time = fts(21)
tt.ranged.attacks[1].animation = "spell"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_start = "stun_tower"
tt.timed_attacks.list[1].cast_time = fts(87)
tt.timed_attacks.list[1].cooldown = b.special_attack.cooldown
tt.timed_attacks.list[1].max_range = b.special_attack.radius
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].allowed_templates = {"enemy_evolved_storm", "enemy_executioner_storm", "enemy_brute_storm"}
tt.timed_attacks.list[1].towers_mod = "mod_enemy_alfa_storm_tower_stun"
tt.timed_attacks.list[1].towers_mod_mark = "mod_enemy_alfa_storm_tower_mark"
tt.timed_attacks.list[1].max_towers_stunned = b.special_attack.max_towers_stunned
tt.timed_attacks.list[1].min_towers_target = b.special_attack.min_towers_target
tt.timed_attacks.list[1].vis_flags = F_MOD
tt.timed_attacks.list[1].vis_bans = 0
tt.timed_attacks.list[2] = E:clone_c("bullet_attack")
tt.timed_attacks.list[2].animation_start = "evolve_in"
tt.timed_attacks.list[2].animation_loop = "evolve_loop"
tt.timed_attacks.list[2].animation_end = "evolve_out"
tt.timed_attacks.list[2].animation_cancelled = "evolve_bloq"
tt.timed_attacks.list[2].loop_times = b.evolve_attack.loop_times
tt.timed_attacks.list[2].first_cooldown = b.evolve_attack.first_cooldown
tt.timed_attacks.list[2].cooldown = b.evolve_attack.cooldown
tt.timed_attacks.list[2].max_range = b.evolve_attack.max_range
tt.timed_attacks.list[2].min_range = b.evolve_attack.min_range
tt.timed_attacks.list[2].max_casts = b.evolve_attack.max_casts
tt.timed_attacks.list[2].nodes_limit = b.evolve_attack.nodes_limit
tt.timed_attacks.list[2].mod = "mod_enemy_alfa_storm_evolve"
tt.timed_attacks.list[2].fx = "fx_enemy_alfa_storm_evolve_ray"
tt.timed_attacks.list[2].allowed_templates = {"enemy_basic_storm"}
tt.timed_attacks.list[2].vis_flags = F_MOD
tt.timed_attacks.list[2].vis_bans = 0
tt.timed_attacks.list[2].max_count = b.evolve_attack.max_count
b = balance.enemies.dragons.executioner_storm
tt = RT("enemy_executioner_storm", "enemy_dragons")

E:add_comps(tt, "melee", "timed_attacks")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(30, 0)
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 55)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health.dead_lifetime = 1.3
tt.unit.size = UNIT_SIZE_MEDIUM
tt.info.enc_icon = 134
tt.info.portrait = "kr5_info_portraits_enemies_0142"
tt.unit.hit_offset = v(0, 23)
tt.unit.head_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 20)
tt.main_script.update = scripts.enemy_executioner_storm.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].sound = "EnemyKillertileMelee"
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].animation = "attk_melee"
tt.timed_attacks.list[1] = E:clone_c("custom_attack")
tt.timed_attacks.list[1].animation_in = "attk_charged_in"
tt.timed_attacks.list[1].animation_out = "attk_charged_out"
tt.timed_attacks.list[1].cooldown = b.charged_instakill.cooldown
tt.timed_attacks.list[1].first_cooldown = b.charged_instakill.first_cooldown
tt.timed_attacks.list[1].nodes_limit = b.charged_instakill.nodes_limit
tt.timed_attacks.list[1].damage_max = 1
tt.timed_attacks.list[1].damage_min = 1
tt.timed_attacks.list[1].damage_type = DAMAGE_INSTAKILL
tt.timed_attacks.list[1].vis_bans = bor(F_HERO)
tt.timed_attacks.list[1].vis_flags = F_INSTAKILL
tt.timed_attacks.list[1].hit_time = fts(3)
tt.timed_attacks.list[1].removes_charged_status = b.charged_instakill.removes_charged_status
tt.timed_attacks.list[1].hp_threshold = b.charged_instakill.hp_threshold
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "storm_executor_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk_up", "walk_down"}
tt.ui.click_rect = r(-23, 0, 46, 45)
tt.sound_events.death = "EnemyStormExecuthosDeath"
tt.unit.fade_time_after_death = fts(100)
tt.health.dead_lifetime = fts(100)
b = balance.enemies.dragons.brute_storm
tt = RT("enemy_brute_storm", "enemy_dragons")

E:add_comps(tt, "melee")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(42, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 60)
tt.info.enc_icon = 62
tt.info.portrait = "kr5_info_portraits_enemies_0062"
tt.unit.hit_offset = v(0, 20)
tt.unit.head_offset = v(0, 50)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 17)
tt.main_script.update = scripts.enemy_brute_storm.update
tt.on_storm_charged = scripts.enemy_brute_storm.on_storm_charged
tt.on_storm_uncharged = scripts.enemy_brute_storm.on_storm_uncharged
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].animation = "attack_2"
tt.melee.attacks[1].hit_fx = "fx_crocs_tank_melee_hit"
tt.melee.attacks[1].hit_offset = v(44, 15)
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "Tank_crocs_animationsDef"
tt.render.sprites[1].angles.idle = {"idle", "idle", "idle"}
tt.render.sprites[1].angles.walk = {"walk_side", "walk_up", "walk_down"}
tt.render.sprites[1].angles.charge = {"attack_1", "attack_1", "attack_1"}
tt.render.sprites[1].angles_custom = {
	charge = {55, 115, 245, 305}
}
tt.render.sprites[1].exo = true
tt.render.sprites[1].offset = v(-2, 0)
tt.ui.click_rect = r(-30, -3, 60, 50)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.can_explode = false
tt.unit.can_explode = false
tt.vis.flags = bor(F_ENEMY)
tt.sound_events.death = "EnemyRazingRhinoDeath"
tt.mod_invulneravility = "mod_enemy_brute_storm_invulnerability"
tt = RT("enemy_miniboss_stage_39", "enemy")
b = balance.enemies.dragons.miniboss_stage_39

E:add_comps(tt, "melee", "timed_attacks", "regen")

tt.enemy.gold = b.gold
tt.enemy.melee_slot = v(41, 0)
tt.enemy.lives_cost = b.lives_cost
tt.health.hp_max = b.hp
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health_bar.offset = v(0, 100)
tt.regen.cooldown = b.regen_cooldown
tt.regen.health = b.regen_health
tt.info.enc_icon = 139
tt.info.portrait = "kr5_info_portraits_enemies_0144"
tt.unit.hit_offset = v(0, 35)
tt.unit.head_offset = v(0, 35)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 33)
tt.main_script.insert = scripts.enemy_miniboss_stage_39.insert
tt.main_script.update = scripts.enemy_miniboss_stage_39.update
tt.melee.attacks[1].cooldown = b.basic_attack.cooldown
tt.melee.attacks[1].damage_max = b.basic_attack.damage_max
tt.melee.attacks[1].damage_min = b.basic_attack.damage_min
tt.melee.attacks[1].damage_type = b.basic_attack.damage_type
tt.melee.attacks[1].damage_radius = b.basic_attack.damage_radius
tt.melee.attacks[1].animations = {"mele_1", "mele_2"}
tt.melee.attacks[1].animation = "mele_1"
tt.melee.attacks[1].hit_offset = v(50, 0)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].type = "area"
tt.melee.attacks[1].vis_bans = bor(F_FLYING)
tt.melee.attacks[1].vis_flags = bor(F_RANGED)
tt.melee.attacks[1].damage_bans = bor(F_FLYING)
tt.melee.attacks[1].damage_flags = bor(F_AREA)
tt.melee.attacks[1].sound = "EnemyRazingRhinoBasicAttack"
tt.melee.attacks[1].hit_fx = "fx_miniboss_stage_39_hit"
tt.melee.attacks[2] = E:clone_c("melee_attack")
tt.melee.attacks[2].animation = "instakill"
tt.melee.attacks[2].cooldown = b.instakill.cooldown
tt.melee.attacks[2].damage_max = b.instakill.damage_max
tt.melee.attacks[2].damage_min = b.instakill.damage_min
tt.melee.attacks[2].damage_type = bor(b.instakill.damage_type)
tt.melee.attacks[2].damage_radius = b.instakill.damage_radius
tt.melee.attacks[2].hit_time = fts(20)
tt.melee.attacks[2].type = "area"
tt.melee.attacks[2].vis_bans = bor(F_HERO, F_FLYING)
tt.melee.attacks[2].vis_flags = bor(F_INSTAKILL, F_RANGED)
tt.melee.attacks[2].damage_bans = bor(F_HERO, F_FLYING)
tt.melee.attacks[2].damage_flags = bor(F_INSTAKILL, F_AREA)
tt.melee.attacks[2].hit_offset = v(50, 0)
tt.melee.attacks[2].sound = "Stage39MinibossInstakill"
tt.melee.attacks[2].mod = "mod_enemy_miniboss_stage_39_instakill"
tt.motion.max_speed = b.speed
tt.render.sprites[1].prefix = "mini_boss_creep"
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk_down"}
tt.ui.click_rect = r(-30, -3, 60, 65)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.unit.size = UNIT_SIZE_MEDIUM
tt.unit.can_explode = false
tt.unit.can_explode = false
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.vis.bans = bor(F_TELEPORT)
tt.sound_events.death = "Stage39MinibossDeath"
tt.health.dead_lifetime = 3
tt = RT("mod_enemy_miniboss_stage_39_instakill", "modifier")
tt.main_script.insert = scripts.mod_enemy_miniboss_stage_39_instakill.insert

tt = RT("bullet_enemy_basic_acid", "arrow")

local b = balance.enemies.dragons.basic_acid.ranged_attack

tt.render.sprites[1].prefix = "acid_basic_proyectil"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_type = b.damage_type
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_bullet_enemy_basic_acid"
tt.bullet.hit_decal = nil
tt.bullet.particles_name = "ps_bullet_enemy_basic_acid"
tt.bullet.align_with_trajectory = true
tt.bullet.damage_bans = bor(F_ENEMY)
tt.bullet.hit_blood_fx = nil
tt.bullet.miss_decal = nil
tt.bullet.miss_fx_water = nil
tt = RT("bullet_enemy_evolved_acid", "bomb")

local b = balance.enemies.dragons.evolved_acid.ranged_attack

tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.radius
tt.bullet.damage_type = b.damage_type
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_enemy_evolved_acid_hit"
tt.bullet.hit_decal = "decal_enemy_evolved_acid_bullet"
tt.bullet.particles_name = "ps_bullet_enemy_evolved_acid"
tt.bullet.align_with_trajectory = true
tt.vis_flags = bor(F_AREA)
tt.vis_bans = bor(F_FLYING, F_ENEMY)
tt.main_script.insert = scripts.bullet_enemy_evolved_acid.insert
tt.main_script.update = scripts.bullet_enemy_evolved_acid.update
tt.render.sprites[1].prefix = "evolved_acid_projectile2"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].animated = true
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.sound_events.hit = "EnemyEvolvedAcidAttack"
tt = RT("bullet_enemy_evolved_acid_spawn", "bomb")

local b = balance.enemies.dragons.evolved_acid.ranged_attack

tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.flight_time = fts(27)
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.align_with_trajectory = false
tt.bullet.hit_payload = "enemy_basic_acid"
tt.vis_flags = bor(F_AREA)
tt.vis_bans = bor(F_FLYING, F_ENEMY)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.bullet_enemy_evolved_acid_spawn.update
tt.render.sprites[1].name = "evolved_acid_projectil"
tt.render.sprites[1].animated = false
tt = RT("bullet_enemy_alfa_acid", "bolt_enemy")

local b = balance.enemies.dragons.alfa_acid.ranged_attack

tt.main_script.insert = scripts.bullet_enemy_alfa_acid.insert
tt.main_script.update = nil
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_type = b.damage_type
tt.bullets_templates = {"bullet_enemy_alfa_acid_a", "bullet_enemy_alfa_acid_b", "bullet_enemy_alfa_acid_c"}
tt.sound_events.insert = "EnemyAlfaAcidAttack"
tt = RT("bullet_enemy_alfa_acid_a", "bolt_enemy")

E:add_comps(tt, "force_motion")

local b = balance.enemies.dragons.alfa_acid.ranged_attack

tt.render.sprites[1].prefix = "alpha_acid_projectile2"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].animated = true
tt.render.sprites[1].scale = vv(0.6)
tt.main_script.insert = scripts.bolt_force_motion_kr5.insert
tt.main_script.update = scripts.bolt_force_motion_kr5.update
tt.bullet.mod = "mod_enemy_alfa_acid_poison"
tt.bullet.damage_max = b.damage_max / 3
tt.bullet.damage_min = b.damage_min / 3
tt.bullet.damage_type = b.damage_type
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.2
tt.bullet.min_speed = 120
tt.bullet.max_speed = 1200
tt.bullet.align_with_trajectory = true
tt.bullet.hit_fx = "fx_bullet_enemy_alfa_acid"
tt.bullet.particles_name = "ps_bullet_enemy_alfa_acid"
tt.initial_impulse = 13500
tt.initial_impulse_duration = 0.15
tt.initial_impulse_angle_abs = math.pi / 2
tt.initial_impulse_reduction = 0.7
tt.force_motion.a_step = 10
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.sound_events.insert = nil
tt = RT("bullet_enemy_alfa_acid_b", "bullet_enemy_alfa_acid_a")
tt.initial_impulse = 7500
tt.initial_impulse_duration = 0.12
tt.initial_impulse_angle_abs = tt.initial_impulse_angle_abs * 1.2
tt.initial_impulse_reduction = 0.7
tt.force_motion.max_v = tt.force_motion.max_v * 0.9
tt = RT("bullet_enemy_alfa_acid_c", "bullet_enemy_alfa_acid_a")
tt.initial_impulse = 9750
tt.initial_impulse_duration = 0.2
tt.initial_impulse_angle_abs = tt.initial_impulse_angle_abs * 0.7
tt.initial_impulse_reduction = 0.7
tt.force_motion.max_v = tt.force_motion.max_v * 1.1
tt = RT("bullet_enemy_alfa_acid_evolve", "bullet")

local b = balance.enemies.dragons.alfa_acid.evolve_shot

tt.main_script.insert = scripts.bullet_enemy_alfa_acid_evolve.insert
tt.main_script.update = scripts.bullet_enemy_alfa_acid_evolve.update
tt.render.sprites[1].name = "alpha_acid_sheep_projectile"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5056818181818182, 0.5988372093023255)
tt.bullet.align_with_trajectory = true
tt.bullet.hit_ts_offset = fts(7)
tt.bullet.hide_radius = nil
tt.bullet.hide_radius_start = 0
tt.bullet.hide_radius_end = 4
tt.bullet.flight_time = nil
tt.bullet.g = -1.2 / (fts(1) * fts(1))
tt.bullet.hit_fx = "fx_bullet_enemy_alfa_acid_evolve_hit"
tt.bullet.hit_blood_fx = nil
tt.sheep = "enemy_alfa_acid_sheep"
tt.sound_events.insert = "EnemyAlfaAcidEvolverSpit"
tt = RT("bullet_enemy_evolved_shadow", "bolt_enemy")

E:add_comps(tt, "force_motion")

b = balance.enemies.dragons.evolved_shadow.ranged_attack
tt.render.sprites[1].prefix = "shadow_evo_projectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_type = b.damage_type
tt.bullet.particles_name = "ps_enemy_evolved_shadow_bullet_trail"
tt.bullet.hit_blood_fx = nil
tt.bullet.acceleration_factor = 0.1
tt.bullet.min_speed = 30
tt.bullet.max_speed = 300
tt.bullet.align_with_trajectory = true
tt.main_script.insert = scripts.bolt_force_motion_kr5.insert
tt.main_script.update = scripts.bolt_force_motion_kr5.update
tt.target_soldiers = true
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = d2r(110)
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.bullet.hit_fx = "fx_enemy_evolved_shadow_bullet_hit"
tt.sound_events.insert = "EnemyShadowEvolvedAttack"
tt = RT("bullet_enemy_alfa_shadow", "bolt_enemy")

E:add_comps(tt, "force_motion")

b = balance.enemies.dragons.alfa_shadow.ranged_attack
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].prefix = "shadow_alpha_proyectile"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = vv(0.8)
tt.bullet.hit_fx = "fx_stage_11_cult_leader_attack_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.bullet.acceleration_factor = 0.5
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.max_speed = 360
tt.bullet.particles_name = "ps_bullet_stage_11_cult_leader"
tt.bullet.damage_type = b.damage_type
tt.bullet.align_with_trajectory = true
tt.main_script.insert = scripts.bolt_force_motion_kr5.insert
tt.main_script.update = scripts.bolt_force_motion_kr5.update
tt.target_soldiers = true
tt.initial_impulse = 3000
tt.initial_impulse_duration = 0.1
tt.initial_impulse_angle = d2r(110)
tt.force_motion.a_step = 5
tt.force_motion.max_a = 3000
tt.force_motion.max_v = 600
tt.sound_events.insert = "EnemyShadowAlfaRangedAttack"
tt = RT("bullet_enemy_alfa_storm", "bullet")

local b = balance.enemies.dragons.alfa_storm.ranged_attack

tt.main_script.update = scripts.ray5_simple.update
tt.bullet.vis_flags = F_RANGED
tt.bullet.vis_bans = 0
tt.render.sprites[1].name = "alpha_storm_projectil"
tt.bullet.hit_fx = "fx_bullet_enemy_alfa_storm"
tt.bullet.hit_fx_ignore_hit_offset = true
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_type = b.damage_type
tt.image_width = 152.5
tt.bullet.hit_time = fts(1)
tt.ray_duration = fts(8)
tt.sound_events.insert = "EnemyStormAlfaRanged"

tt = RT("mod_enemy_evolved_lava_dot", "modifier")

E:add_comps(tt, "render", "dps")

b = balance.enemies.dragons.evolved_lava.special_attack.dot
tt.modifier.duration = b.duration
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 4
tt.render.sprites[1].loop = true
tt.dps.damage_every = b.damage_every
tt.dps.damage_max = b.damage_max
tt.dps.damage_min = b.damage_min
tt.dps.damage_type = b.damage_type
tt.dps.fx = "fx_enemy_evolved_lava_firebreath"
tt.dps.fx_every = b.duration + 1
tt = RT("mod_enemy_alfa_lava_dot", "modifier")

E:add_comps(tt, "render", "dps")

b = balance.enemies.dragons.alfa_lava.lava_vomit_attack.dot
tt.modifier.duration = b.duration
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].prefix = "fire"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].draw_order = 4
tt.render.sprites[1].loop = true
tt.dps.damage_every = b.damage_every
tt.dps.damage_max = b.damage_max
tt.dps.damage_min = b.damage_min
tt.dps.damage_type = b.damage_type
tt = RT("mod_enemy_alfa_lava_evolve", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_enemy_alfa_acid_evolve.insert
tt.entity_t = {{"enemy_basic_lava", "enemy_evolved_lava"}}
tt = RT("mod_enemy_basic_acid_armor_reduction", "modifier")

E:add_comps(tt, "render")

b = balance.enemies.dragons.basic_acid.ranged_attack
tt.modifier.duration = b.armor_reduction_duration
tt.armor_reduction = b.armor_reduction
tt.magic_armor_reduction = b.magic_armor_reduction
tt.render.sprites[1].prefix = "evolved_acid_modifier"
tt.render.sprites[1].size_names = {"run", "run", "run"}
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.render.sprites[1].anchor = v(0.5, 0.6)
tt.main_script.insert = scripts.mod_enemy_basic_acid_armor_reduction.insert
tt.main_script.remove = scripts.mod_enemy_basic_acid_armor_reduction.remove
tt.main_script.update = scripts.mod_track_target.update
tt = RT("mod_enemy_alfa_acid_poison", "modifier")

E:add_comps(tt, "render", "dps")

b = balance.enemies.dragons.alfa_acid.ranged_attack.poison
tt.modifier.duration = b.duration
tt.modifier.vis_flags = bor(F_MOD, F_POISON)
tt.render.sprites[1].prefix = "alpha_acid_modifier"
tt.render.sprites[1].size_names = {"run", "run", "run"}
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = DO_MOD_FX
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_enemy_alfa_acid_poison.update
tt.dps.damage_every = b.damage_every
tt.dps.damage_max = b.damage_max
tt.dps.damage_min = b.damage_min
tt.dps.damage_type = b.damage_type
tt.transformation_nodes_limit = b.transformation_nodes_limit
tt.spawn_entity = "enemy_basic_acid"
tt = RT("mod_enemy_alfa_acid_evolve", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_enemy_alfa_acid_evolve.insert
tt.entity_t = {{"enemy_basic_acid", "enemy_evolved_acid"}}
tt = RT("mod_enemy_alfa_acid_evolve_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.modifier.duration = fts(210)
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = RT("mod_enemy_alfa_shadow_evolve", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_enemy_alfa_acid_evolve.insert
tt.entity_t = {{"enemy_basic_shadow", "enemy_evolved_shadow"}}
tt = RT("mod_enemy_alfa_shadow_evolve_mark", "modifier")

E:add_comps(tt, "mark_flags")

tt.modifier.duration = 4
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = RT("mod_enemy_alfa_storm_evolve", "modifier")
tt.modifier.duration = fts(2)
tt.main_script.insert = scripts.mod_enemy_alfa_acid_evolve.insert
tt.entity_t = {{"enemy_basic_storm", "enemy_evolved_storm"}}
tt = RT("mod_enemies_storm_charged", "modifier")

E:add_comps(tt, "render")

b = balance.enemies.dragons.alfa_storm.special_attack
tt.modifier.duration = 1e+99
tt.main_script.insert = scripts.mod_enemies_storm_charged.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_enemies_storm_charged.remove
tt.allowed_templates = {"enemy_evolved_storm", "enemy_executioner_storm", "enemy_brute_storm"}
tt.render.sprites[1].name = "alpha_storm_modifier_creep_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].loop = true
tt = RT("mod_enemy_alfa_storm_tower_stun", "modifier")
b = balance.enemies.dragons.alfa_storm.special_attack

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_enemy_alfa_storm_tower_stun.insert
tt.main_script.update = scripts.mod_enemy_alfa_storm_tower_stun.update
tt.main_script.remove = scripts.mod_enemy_alfa_storm_tower_stun.remove
tt.modifier.duration = b.tower_stun_duration
tt.modifier.vis_flags = F_CUSTOM
tt.render.sprites[1].prefix = "alpha_storm_fx_skill"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].sort_y_offset = -10
tt.render.sprites[1].offset = v(10, 15)
tt.render.sprites[1].scale = vv(1.6)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "alpha_storm_decal"
tt.render.sprites[2].scale = vv(2)
tt.render.sprites[2].anchor = v(0.47183098591549294, 0.5)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].offset = v(0, 15)
tt.offset_y_per_tower = {
	hermit_toad = 4
}
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "alpha_storm_ray_stun_run"
tt.render.sprites[3].z = Z_OBJECTS
tt.render.sprites[3].sort_y_offset = -20
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "alpha_storm_stun_tower_fx_run"
tt.render.sprites[4].z = Z_OBJECTS
tt.render.sprites[4].sort_y_offset = -25
tt = RT("mod_enemy_alfa_storm_tower_mark", "modifier")

E:add_comps(tt, "mark_flags")

b = balance.enemies.dragons.alfa_storm.special_attack
tt.modifier.duration = 6
tt.main_script.queue = scripts.mod_mark_flags.queue
tt.main_script.dequeue = scripts.mod_mark_flags.dequeue
tt.main_script.update = scripts.mod_mark_flags.update
tt = RT("mod_enemy_brute_storm_invulnerability", "modifier")
b = balance.enemies.dragons.alfa_storm.special_attack
tt.modifier.duration = b.charge_duration
b = balance.enemies.dragons.brute_storm.charged_invulneravility
tt.main_script.insert = scripts.mod_enemy_brute_storm_invulnerability.insert
tt.main_script.update = scripts.mod_enemy_brute_storm_invulnerability.update
tt.main_script.remove = scripts.mod_enemy_brute_storm_invulnerability.remove
tt.hp_heal_threshold = b.hp_heal_threshold
tt.hp_healing_amount = b.hp_healing_amount

tt = RT("mod_boss_murglum_tower_block", "mod_hide_tower")

E:add_comps(tt, "render")

tt.main_script.insert = scripts.mod_boss_murglum_tower_block.insert
tt.main_script.update = scripts.mod_boss_murglum_tower_block.update
tt.main_script.remove = scripts.mod_boss_murglum_tower_block.remove
tt.render.sprites[1].prefix = "boss_murglun_tower_stun"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].draw_order = 20
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].scale = vv(2)
tt.modifier.duration = nil

tt = RT("bullet_alfa_lava_vomit", "bomb")
tt.main_script.update = scripts.bullet_alfa_lava_vomit.update
tt.render.sprites[1].prefix = "lava_alpha_proyectil"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.bullet.particles_name = "ps_bullet_alfa_lava_vomit"
tt.bullet.flight_time = fts(30)
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.hit_decal = "decal_enemy_alfa_lava_dot"
tt.bullet.hit_fx = nil
tt.bullet.pop_chance = 0
tt.sound_events.insert = nil
tt.sound_events.hit = nil

tt = RT("bolt_boss_murglum", "bolt_enemy")
b = balance.enemies.dragons.dragon_boss_stage_37.basic_attack
tt.bullet.damage_type = b.damage_type
tt.bullet.particles_name = "ps_bullet_murglum_geiser_bossfight"
tt.bullet.align_with_trajectory = true
tt.bullet.ignore_hit_offset = true
tt.bullet.max_speed = 600
tt.bullet.min_speed = 600
tt.bullet.pop_chance = 0
tt.bullet.damage_type = b.damage_type
tt.bullet.damage_max = b.damage_max
tt.bullet.damage_min = b.damage_min
tt.bullet.damage_radius = b.damage_radius
tt.bullet.hit_decal = "decal_boss_murglum_geiser_bossfight"
tt.bullet.hit_fx = "fx_boss_murglum_geiser_lava"
tt.render.sprites[1].prefix = "boss_murglun_proyectil_basic"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.4166666666666667, 0.5263157894736842)
tt.render.sprites[1].z = Z_BULLETS
tt.main_script.update = scripts.bolt_boss_murglum_attack.update
tt.sound_events.insert = "Stage37MurglunAttack"

tt = RT("aura_enemy_alfa_lava_dot", "aura")
b = balance.enemies.dragons.alfa_lava.lava_vomit_attack
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.aura.duration = -1
tt.aura.mod = "mod_enemy_alfa_lava_dot"
tt.aura.radius = b.lava_radius
tt.aura.cycle_time = 0.1
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
