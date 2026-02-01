local i18n = require("i18n")

require("all.constants")

local anchor_x = 0
local anchor_y = 0
local image_x = 0
local image_y = 0
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

-- 毁灭者
--#region eb_juggernaut
tt = RT("eb_juggernaut", "boss")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.08
anchor_x = 0.5
image_y = 128
image_x = 144
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 10
tt.health.hp_max = 10000
tt.health.armor = 0.6
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = vec_2(0, ady(120))
tt.info.i18n_key = "EB_JUGGERNAUT"
tt.info.enc_icon = 32
tt.info.portrait = "info_portraits_enemies_0017"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_juggernaut.update
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.render.sprites[1].prefix = "eb_juggernaut"
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, ady(50))
tt.unit.mod_offset = vec_2(adx(70), ady(50))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 175
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.melee.attacks[1].sound_hit = "juggernaut_punch"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "missile_juggernaut"
tt.timed_attacks.list[1].bullet_start_offset = vec_2(-30, 82)
tt.timed_attacks.list[1].cooldown = 11
tt.timed_attacks.list[1].launch_vector = vec_2(12, 170)
tt.timed_attacks.list[1].max_range = math.huge
tt.timed_attacks.list[1].min_range = 100
tt.timed_attacks.list[1].shoot_time = fts(24)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].bullet = "bomb_juggernaut"
tt.timed_attacks.list[2].cooldown = 4
--#endregion
--#region bomb_juggernaut
tt = RT("bomb_juggernaut", "bomb")
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 1
tt.bullet.flight_time_base = fts(45)
tt.bullet.flight_time_factor = fts(0.025)
tt.bullet.pop = nil
tt.bullet.hit_payload = "juggernaut_bomb_spawner"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.bullet.hit_fx = nil
tt.render.sprites[1].name = "bossJuggernaut_bomb_"
tt.sound_events.hit = "BombExplosionSound"
--#endregion
--#region juggernaut_bomb_spawner
tt = RT("juggernaut_bomb_spawner", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].prefix = "bomb_juggernaut_spawner"
tt.render.sprites[1].loop = false
tt.spawner.animation_concurrent = "open"
tt.spawner.count = 5
tt.spawner.count_inc = 1
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_golem_head"
tt.spawner.keep_gold = true
tt.spawner.node_offset = 2
tt.spawner.pos_offset = vec_2(0, 0)
tt.spawner.allowed_subpaths = {1, 2, 3}
tt.spawner.random_subpath = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {4, 0}}
tt.tween.remove = true
tt.total_gold = 70
--#endregion
--#region enemy_golem_head
tt = RT("enemy_golem_head", "enemy")

AC(tt, "melee")

anchor_y = 0.20588235294117646
anchor_x = 0.5
image_y = 34
image_x = 40
tt.enemy.gold = 10
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = 90
tt.health.armor = 0.6
tt.health_bar.offset = vec_2(0, 23)
tt.info.i18n_key = "ENEMY_GOLEM_HEAD"
tt.info.enc_icon = 15
tt.info.portrait = "info_portraits_enemies_0018"
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 0.7 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "enemy_golem_head"
tt.sound_events.death = "DeathPuff"
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 8)
tt.unit.mod_offset = vec_2(adx(22), ady(15))
tt.unit.show_blood_pool = false
--#endregion
--#region missile_juggernaut
tt = RT("missile_juggernaut", "bullet")
tt.bullet.acceleration_factor = 0.1
tt.bullet.damage_bans = bor(F_ENEMY, F_BOSS)
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_max = 250
tt.bullet.damage_min = 150
tt.bullet.damage_radius = 41.25
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_explosion_air"
tt.bullet.hit_fx_air = "fx_explosion_air"
tt.bullet.max_speed = 450
tt.bullet.min_speed = 300
tt.bullet.particles_name = "ps_missile"
tt.bullet.retarget_range = math.huge
tt.bullet.rot_dir_from_long_angle = true
tt.bullet.turn_speed = 10 * math.pi / 180 * 30
tt.bullet.vis_bans = bor(F_ENEMY)
tt.bullet.vis_flags = F_RANGED
tt.main_script.update = scripts.enemy_missile.update
tt.render.sprites[1].prefix = "missile_bfg"
tt.render.sprites[1].name = "flying"
tt.sound_events.insert = "RocketLaunchSound"
tt.sound_events.hit = "BombExplosionSound"
-- 大雪怪
--#endregion
--#region eb_jt
tt = RT("eb_jt", "boss")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.19
anchor_x = 0.5
image_y = 200
image_x = 260
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "jt_spawner_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(55, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 12000
tt.health.on_damage = scripts.eb_jt.on_damage
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = vec_2(0, ady(172))
tt.info.fn = scripts.eb_jt.get_info
tt.info.i18n_key = "EB_JT"
tt.info.enc_icon = 33
tt.info.portrait = "info_portraits_enemies_0026"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_jt.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.08)
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.render.sprites[1].prefix = "eb_jt"
tt.tap_decal = "decal_jt_tap"
tt.tap_timeout = 1.5
tt.sound_events.death = "JtDeath"
tt.sound_events.death_explode = "JtExplode"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-38, 0, 76, 95)
tt.unit.hit_offset = vec_2(0, 60)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(adx(130), ady(90))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound = "JtEat"
tt.melee.attacks[1].sound_args = {
	delay = fts(6)
}
tt.melee.attacks[1].side_effect = function(this, store, attack, target)
	U.heal(this, 100)
end
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 10 + fts(29)
tt.timed_attacks.list[1].count = 4
tt.timed_attacks.list[1].exhausted_duration = 2
tt.timed_attacks.list[1].exhausted_sound = "JtRest"
tt.timed_attacks.list[1].exhausted_sound_args = {
	delay = fts(34)
}
tt.timed_attacks.list[1].hit_decal = "decal_jt_ground_hit"
tt.timed_attacks.list[1].hit_offset = vec_2(80, -10)
tt.timed_attacks.list[1].hit_time = fts(16)
tt.timed_attacks.list[1].max_range = 192
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].mod = "mod_jt_tower"
tt.timed_attacks.list[1].sound = "JtAttack"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(6)
}
-- 维兹南
--#endregion
--#region eb_veznan
tt = RT("eb_veznan", "boss")
AC(tt, "melee", "timed_attacks", "taunts")
anchor_y = 0.17010309278350516
anchor_x = 0.5
image_y = 194
image_x = 214
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(20, 0)
tt.health.hp_max = {6666, 7999, 9666, 11666}
tt.health.on_damage = scripts.eb_veznan.on_damage
tt.health.ignore_damage = true
tt.health_bar.hidden = true
tt.health_bar.offset = vec_2(0, 43)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_MEDIUM
tt.health.magic_armor = 0.4
tt.info.i18n_key = "EB_VEZNAN"
tt.info.enc_icon = 34
tt.info.portrait = "info_portraits_enemies_0035"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_veznan.update
tt.motion.max_speed = 0.35 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_veznan"
tt.render.sprites[1].name = "idleDown"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "VeznanDeath"
tt.ui.click_rect = r(-11, -2, 22, 38)
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.mod_offset = vec_2(0, 12)
tt.unit.marker_offset = vec_2(0, 0)
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.pos_castle = vec_2(518, 677)
tt.souls_aura = "veznan_souls_aura"
tt.white_circle = "decal_eb_veznan_white_circle"
tt.taunts.animation = "laught"
tt.taunts.delay_min = fts(400)
tt.taunts.delay_max = fts(700)
tt.taunts.duration = 4
tt.taunts.decal_name = "decal_s12_shoutbox"
tt.taunts.offset = vec_2(0, 0)
tt.taunts.pos = vec_2(525, 608)
tt.taunts.sets.welcome = CC("taunt_set")
tt.taunts.sets.welcome.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.welcome.end_idx = 5
tt.taunts.sets.welcome.delays = {fts(60), fts(140), fts(450), fts(250)}
tt.taunts.sets.castle = CC("taunt_set")
tt.taunts.sets.castle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.castle.start_idx = 6
tt.taunts.sets.castle.end_idx = 25
tt.taunts.sets.damage = CC("taunt_set")
tt.taunts.sets.damage.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.damage.start_idx = 26
tt.taunts.sets.damage.end_idx = 29
tt.taunts.sets.pre_battle = CC("taunt_set")
tt.taunts.sets.pre_battle.format = "VEZNAN_TAUNT_%04d"
tt.taunts.sets.pre_battle.start_idx = 30
tt.taunts.sets.pre_battle.end_idx = 30
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 8
tt.melee.attacks[1].damage_min = 666
tt.melee.attacks[1].damage_max = 999
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].hit_offset = vec_2(-10, -2)
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].hit_decal = "decal_veznan_strike"
tt.melee.attacks[1].sound_hit = "VeznanAttack"
tt.melee.attacks[2] = table.deepclone(tt.melee.attacks[1])
tt.melee.attacks[2].cooldown = 2.5
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].hit_decal = nil
tt.melee.attacks[2].hit_fx = "fx_veznan_demon_fire"
tt.melee.attacks[2].hit_fx_offset = vec_2(20, 9)
tt.melee.attacks[2].hit_fx_once = true
tt.melee.attacks[2].hit_fx_flip = true
tt.melee.attacks[2].hit_times = {fts(20), fts(24), fts(28), fts(32), fts(36), fts(38), fts(42), fts(44)}
tt.melee.attacks[2].hit_offset = vec_2(40, 0)
tt.melee.attacks[2].sound_hit = nil
tt.melee.attacks[2].sound = "VeznanDemonFire"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = 13
tt.timed_attacks.list[1].animation = "spellDown"
tt.timed_attacks.list[1].hit_time = fts(14)
tt.timed_attacks.list[1].mod = "mod_veznan_tower"
tt.timed_attacks.list[1].sound = "VeznanHoldCast"
tt.timed_attacks.list[1].attack_duration = fts(44)
tt.timed_attacks.list[1].data = {
	[9] = {13, 2},
	[10] = {13, 3},
	[11] = {14, 4},
	[12] = {14, 5},
	[13] = {16, 6},
	[14] = {16, 7},
	[15] = {18, 8}
}
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "spellDown"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].hit_time = fts(14)
tt.timed_attacks.list[2].portal_name = "veznan_portal"
tt.timed_attacks.list[2].sound = "VeznanPortalSummon"
tt.timed_attacks.list[2].attack_duration = fts(44)
tt.timed_attacks.list[2].data = {
	[6] = {15, 3, {1, 0, 0}},
	[7] = {10, 2, {1, 0, 0}},
	[8] = {20, 3, {0, 1, 0}},
	[9] = {15, 3, {1, 0, 0}},
	[10] = {20, 3, {1, 1, 0}},
	[11] = {15, 3, {1, 1, 0}},
	[12] = {15, 3, {1, 1, 0}},
	[13] = {15, 3, {0, 0, 1}},
	[14] = {15, 3, {1, 1, 1}},
	[15] = {15, 3, {1, 1, 1}}
}
tt.battle = {
	ba_animation = "spell",
	pa_animation = "spell",
	pa_cooldown = 10,
	pa_max_count = 40
}
tt.demon = {
	health_bar_offset = vec_2(0, 118),
	health_bar_scale = 1.8,
	melee_slot = vec_2(50, 0),
	speed = 0.6 * FPS,
	sprites_prefix = "eb_veznan_demon",
	transform_sound = "VeznanToDemon",
	ui_click_rect = r(-25, -5, 50, 110),
	unit_hit_offset = vec_2(0, 55),
	unit_mod_offset = vec_2(0, 45),
	unit_size = UNIT_SIZE_LARGE,
	info_portrait = "info_portraits_enemies_0072"
}
-- 萨雷格兹
--#endregion
--#region eb_sarelgaz
tt = RT("eb_sarelgaz", "boss")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.1484375
anchor_x = 0.5
image_y = 128
image_x = 220
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(80, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 17000
tt.health.magic_armor = 0.4
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = vec_2(0, 108)
tt.info.i18n_key = "EB_SARELGAZ"
tt.info.enc_icon = 35
tt.info.portrait = "info_portraits_enemies_0036"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_spider_big.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 500
tt.melee.attacks[1].damage_min = 300
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].damage_type = DAMAGE_EAT
tt.melee.attacks[1].sound = "SpiderAttack"
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "enemy_sarelgaz_egg"
tt.timed_attacks.list[1].max_cooldown = 12
tt.timed_attacks.list[1].max_count = 100
tt.timed_attacks.list[1].min_cooldown = 10
tt.motion.max_speed = 0.34 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_sarelgaz"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "DeathEplosion"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-45, 0, 90, 80)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.marker_hidden = true
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.health_judger = true
--#endregion
--#region enemy_sarelgaz_egg
tt = RT("enemy_sarelgaz_egg", "decal_scripted")

AC(tt, "render", "spawner", "tween")

tt.main_script.update = scripts.enemies_spawner.update
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[1].scale = vec_2(2, 2)
tt.render.sprites[1].prefix = "enemy_spider_egg"
tt.render.sprites[1].loop = false
tt.render.sprites[1].color = {0, 80, 255}
tt.spawner.count = 3
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
-- 古拉克
--#endregion
--#region eb_gulthak
tt = RT("eb_gulthak", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.11
anchor_x = 0.5
tt.enemy.gold = 0
image_y = 196
image_x = 340
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(60, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 12000
tt.health_bar.offset = vec_2(0, 95)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health.magic_armor = 0.1
tt.info.i18n_key = "EB_GOBLIN_CHIEFTAIN"
tt.info.enc_icon = 40
tt.info.portrait = "info_portraits_enemies_0042"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_shaman.update
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 600
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].hit_time = fts(11)
tt.motion.max_speed = 0.4 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_gulthak"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-50, 0, 90, 60)
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 27)
tt.unit.marker_hidden = true
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "heal"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 8
tt.timed_attacks.list[1].max_count = 20
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_gulthak_heal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
-- 绿泥树怪
--#endregion
--#region eb_greenmuck
tt = RT("eb_greenmuck", "boss")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.1402439024390244
anchor_x = 0.5
image_y = 232
image_x = 244
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 8000
tt.health.armor = 0.8
tt.health_bar.offset = vec_2(0, 135)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_greenmuck.get_info
tt.info.i18n_key = "EB_GREENMUCK"
tt.info.enc_icon = 45
tt.info.portrait = "info_portraits_enemies_0048"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_greenmuck.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_greenmuck"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = nil
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-30, 0, 60, 110)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 37)
tt.unit.marker_offset = vec_2(0, -10)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, 37)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "shoot"
tt.timed_attacks.list[1].bullet = "bomb_greenmuck"
tt.timed_attacks.list[1].count = 7
tt.timed_attacks.list[1].bullet_start_offset = vec_2(0, 120)
tt.timed_attacks.list[1].cooldown = 6
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].vis_bans = F_ENEMY
-- 金并
--#endregion
--#region eb_kingpin
tt = RT("eb_kingpin", "enemy")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.13
anchor_x = 0.5
image_y = 204
image_x = 218
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "kingpin_damage_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(60, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 12000
tt.health_bar.offset = vec_2(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_kingpin.get_info
tt.info.i18n_key = "EB_BANDIT"
tt.info.enc_icon = 48
tt.info.portrait = "info_portraits_enemies_0051"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_kingpin.update
tt.motion.max_speed = 0.35 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.13)
tt.render.sprites[1].prefix = "eb_kingpin"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "DeathJuggernaut"
tt.sound_events.insert = "MusicBossFight"
tt.stop_time = 5
tt.stop_cooldown = 5
tt.stop_wait = fts(20)
tt.ui.click_rect = r(-50, 0, 100, 75)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 80)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 82)
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH, F_BLOCK)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 65
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_juggernaut_smoke"
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "eat"
tt.timed_attacks.list[1].cast_time = fts(14)
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].max_count = 1
tt.timed_attacks.list[1].max_range = 320
tt.timed_attacks.list[1].mod = "mod_kingpin_heal_self"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].animation = "heal"
tt.timed_attacks.list[2].max_count = 9999
tt.timed_attacks.list[2].max_range = 100
tt.timed_attacks.list[2].mod = "mod_kingpin_heal_others"
-- 阿古克汗
--#endregion
--#region eb_ulgukhai
tt = RT("eb_ulgukhai", "boss")

AC(tt, "melee", "auras")

anchor_y = 0.1792452830188679
anchor_x = 0.5
image_y = 150
image_x = 240
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "aura_ulgukhai_regen"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 9000
tt.health.armor = 0.55
tt.health_bar.offset = vec_2(0, 90)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_ulgukhai.get_info
tt.info.i18n_key = "EB_ULGUKHAI"
tt.info.enc_icon = 52
tt.info.portrait = "info_portraits_enemies_0054"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_ulgukhai.update
tt.motion.max_speed = 0.3 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_ulgukhai"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "MusicBossFight"
tt.unit.blood_color = BLOOD_GRAY
tt.ui.click_rect = r(-25, 5, 50, 65)
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 26)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.shielded_extra_vis_bans = bor(F_MOD, F_POISON)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 3
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].damage_radius = 57.6
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(16)
tt.melee.attacks[1].hit_offset = vec_2(60, 0)
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].sound_hit = "AreaAttack"
-- 摩洛克
--#endregion
--#region eb_moloch
tt = RT("eb_moloch", "boss")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.105
anchor_x = 0.5
image_y = 282
image_x = 282
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(33, 0)
tt.health.dead_lifetime = 10
tt.health.ignore_damage = true
tt.health.hp_max = {11111, 13333, 15555, 18888}
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "EB_MOLOCH"
tt.info.enc_icon = 57
tt.info.portrait = "info_portraits_enemies_0059"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_moloch.update
tt.motion.max_speed = 0.6 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_moloch"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "EnemyInfernoBossDeath"
tt.ui.click_rect = r(-25, 0, 50, 100)
tt.unit.hit_offset = vec_2(0, 60)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_ALL)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.stand_up_wait_time = fts(14)
tt.stand_up_sound = "MusicBossFight"
tt.pos_sitting = vec_2(526, 614)
tt.nav_path.pi = 2
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.wave_active = 16
tt.active_vis_bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.5 + fts(25)
tt.melee.attacks[1].damage_max = 120
tt.melee.attacks[1].damage_min = 80
tt.melee.attacks[1].damage_radius = 40
tt.melee.attacks[1].count = nil
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].hit_fx = "fx_moloch_ring"
tt.melee.attacks[1].sound_hit = "EnemyInfernoStomp"
tt.timed_attacks.list[1] = CC("area_attack")
tt.timed_attacks.list[1].cooldown = 7
tt.timed_attacks.list[1].animation = "horn_attack"
tt.timed_attacks.list[1].damage_radius = 100
tt.timed_attacks.list[1].damage_type = DAMAGE_INSTAKILL
tt.timed_attacks.list[1].hit_time = fts(15)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].fx_list = {{"fx_moloch_rocks", {{36, -30}, {1, -10}, {90, -23}, {87, 5}, {49, -3}, {54, 17}}}, {"fx_moloch_ring", {{45, 0}}}}
tt.timed_attacks.list[1].hit_offset = vec_2(20, 0)
tt.timed_attacks.list[1].sound = "EnemyInfernoHorns"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(5)
}
tt.is_demon = true
-- 蘑菇人
--#endregion
--#region eb_myconid
tt = RT("eb_myconid", "boss")

AC(tt, "melee", "timed_attacks")

anchor_y = 0.16428571428571428
anchor_x = 0.5
image_y = 140
image_x = 174
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 12
tt.health.hp_max = 4500
tt.health_bar.offset = vec_2(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.i18n_key = "EB_MYCONID"
tt.info.enc_icon = 59
tt.info.portrait = "info_portraits_enemies_0061"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_myconid.update
tt.motion.max_speed = 0.65 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_myconid"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "EnemyMushroomBossDeath"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-25, 0, 50, 80)
tt.unit.fade_time_after_death = 4
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.hit_offset = vec_2(0, 33)
tt.unit.mod_offset = vec_2(0, 33)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.spawner_entity = "myconid_spawner"
tt.on_death_spawn_count = 12
tt.on_death_spawn_wait = fts(40)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 350
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].hit_time = fts(9)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animation = "spores"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].final_wait = fts(20)
tt.timed_attacks.list[1].fx = "fx_myconid_spores"
tt.timed_attacks.list[1].fx_offset = vec_2(0, 40)
tt.timed_attacks.list[1].min_nodes = 25
tt.timed_attacks.list[1].mod = "mod_myconid_poison"
tt.timed_attacks.list[1].radius = 110
tt.timed_attacks.list[1].sound = "EnemyMushroomGas"
tt.timed_attacks.list[1].summon_counts = {2, 3, 3, 4, 4, 4, 3, 2}
tt.timed_attacks.list[1].vis_bans = F_ENEMY
tt.timed_attacks.list[1].vis_flags = bor(F_MOD, F_POISON)
tt.timed_attacks.list[1].wait_times = {fts(15), fts(3), fts(6)}
-- 布莱克本
--#endregion
--#region eb_blackburn
tt = RT("eb_blackburn", "boss")

AC(tt, "melee", "timed_attacks", "auras")

anchor_y = 0.16993464052287582
anchor_x = 0.5
image_y = 308
image_x = 314
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 10
tt.health.armor = 0.95
tt.health.hp_max = 11000
tt.health_bar.offset = vec_2(0, 125)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_blackburn.get_info
tt.info.i18n_key = "EB_BLACKBURN"
tt.info.enc_icon = 69
tt.info.portrait = "info_portraits_enemies_0071"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_blackburn.update
tt.motion.max_speed = 0.5 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "eb_blackburn"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "EnemyBlackburnBossDeath"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect.pos.y = 9
tt.unit.hit_offset = vec_2(adx(150), ady(115))
tt.unit.marker_offset = vec_2(0, 11)
tt.unit.mod_offset = vec_2(0, ady(115))
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "blackburn_aura"
tt.auras.list[1].cooldown = 0
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.3 + fts(40)
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 100
tt.melee.attacks[1].damage_radius = 63.829787234042556
tt.melee.attacks[1].dodge_time = fts(13)
tt.melee.attacks[1].hit_time = fts(15)
tt.melee.attacks[1].sound_hit = "EnemyBlackburnBossSwing"
tt.melee.attacks[1].vis_bans = bor(F_STUN)
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].after_hit_wait = fts(20)
tt.timed_attacks.list[1].animation = "smash"
tt.timed_attacks.list[1].aura_shake = "aura_screen_shake"
tt.timed_attacks.list[1].cooldown = fts(300)
tt.timed_attacks.list[1].after_cooldown = fts(150)
tt.timed_attacks.list[1].damage_max = 5
tt.timed_attacks.list[1].damage_min = 1
tt.timed_attacks.list[1].damage_type = DAMAGE_TRUE
tt.timed_attacks.list[1].damage_radius = 106.38297872340426
tt.timed_attacks.list[1].fx = "fx_blackburn_smash"
tt.timed_attacks.list[1].fx_offset = vec_2(26, 7)
tt.timed_attacks.list[1].hit_decal = "decal_blackburn_smash_ground"
tt.timed_attacks.list[1].hit_time = fts(24)
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 283.68794326241135
tt.timed_attacks.list[1].mod = "mod_blackburn_stun"
tt.timed_attacks.list[1].mod_towers = "mod_blackburn_tower"
tt.timed_attacks.list[1].sound = "EnemyBlackburnBossSpecialStomp"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(13)
}
tt.timed_attacks.list[1].vis_flags = bor(F_MOD)

-- 纳泽鲁
--#region eb_efreeti
tt = RT("eb_efreeti", "boss")

AC(tt, "attacks", "tween")

anchor_y = 0.1
image_y = 198
tt.attacks.cooldown = 7
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].animation = "attack"
tt.attacks.list[1].chance = 0.2
tt.attacks.list[1].hit_time = fts(13)
tt.attacks.list[1].max_count = 3
tt.attacks.list[1].max_range = 320
tt.attacks.list[1].min_range = 76.8
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].animation = "attack"
tt.attacks.list[2].hit_time = fts(13)
tt.attacks.list[2].max_count = 10
tt.attacks.list[2].max_range = 96
tt.attacks.list[2].min_range = 0
tt.attacks.list[3] = CC("mod_attack")
tt.attacks.list[3].animation = "attack_sand"
tt.attacks.list[3].chance = 0.3
tt.attacks.list[3].max_count = 3
tt.attacks.list[3].max_range = 192
tt.attacks.list[3].mod = "mod_efreeti"
tt.attacks.list[3].shoot_time = fts(19)
tt.attacks.list[4] = CC("spawn_attack")
tt.attacks.list[4].animation = "attack"
tt.attacks.list[4].coords = {vec_2(816, 430), vec_2(415, 490), vec_2(270, 340), vec_2(690, 290)}
tt.attacks.list[4].entity = "enemy_efreeti_small"
tt.attacks.list[4].health_threshold = 3000
tt.attacks.list[4].max_count = 2
tt.attacks.list[4].spawn_time = fts(13)
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(50, 0)
tt.health.dead_lifetime = fts(200)
tt.health.hp_max = 9000
tt.health_bar.offset = vec_2(0, ady(195))
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_efreeti.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0015"
tt.info.enc_icon = 14
tt.main_script.insert = scripts.eb_efreeti.insert
tt.main_script.update = scripts.eb_efreeti.update
tt.motion.max_speed = 0.375 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].prefix = "eb_efreeti_legs"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].angles = {}
tt.render.sprites[2].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[2].prefix = "eb_efreeti"
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].anchor.y = anchor_y
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[3].loop_forced = true
tt.render.sprites[3].prefix = "eb_efreeti_belt"
tt.tween.props[1].keys = {{0, 0}, {1.5, 255}}
tt.tween.props[1].sprite_id = 1
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {1.5, 255}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = CC("tween_prop")
tt.tween.props[3].keys = {{0, 0}, {1.5, 255}}
tt.tween.props[3].sprite_id = 3
tt.tween.remove = false
tt.ui.click_rect = r(-40, -5, 80, 160)
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, 103)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, ady(104))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = F_ALL
tt.vis.bans_in_battlefield = bor(F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.sound_events.insert = "MusicBossFight"
tt.sound_events.laugh = "BossEfreetiLaugh"
tt.sound_events.death = "BossEfreetiDeath"
tt.sound_events.desintegrate = "BossEfreetiSnap"
tt.sound_events.polymorph = "BossEfreetiSnap"
tt.sound_events.spawn = "BossEfreetiSnap"
tt.sound_events.sand = "BossEfreetiClap"
--#endregion
--#region mod_efreeti
tt = RT("mod_efreeti", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_tower_block.update
tt.modifier.duration = 10
tt.modifier.hide_tower = true
tt.render.sprites[1].anchor.y = 0.17
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "efreeti_sandblock_tower"
tt.sound_events.finish = "BossEfreetiTowerReleased"
--#endregion
--#region eb_gorilla
tt = RT("eb_gorilla", "boss")

AC(tt, "melee", "attacks", "idle_flip")

anchor_y = 0.21
image_y = 172
tt.jump_down_advance_nodes = 10
tt.nodes_limit = 30
tt.on_tower_time = 9
tt.tower_pos_left = nil
tt.tower_pos_right = nil
tt.attacks.list[1] = CC("spawn_attack")
tt.attacks.list[1].animation = "call"
tt.attacks.list[1].cooldown = 8
tt.attacks.list[1].entity = "gorilla_small_liana"
tt.attacks.list[1].max_count = 8
tt.attacks.list[1].sound = "BossMonkeyChestPounding"
tt.attacks.list[1].spawn_node_ranges = {{{62, 113}, {130, 150}}, {{60, 105}, {120, 140}}}
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].cooldown = 10
tt.attacks.list[2].points = 500
tt.attacks.list[2].sound = "EnemyHealing"
tt.attacks.list[3] = CC("bullet_attack")
tt.attacks.list[3].animation = "throw_barrel"
tt.attacks.list[3].bullet = "gorilla_boss_barrel"
tt.attacks.list[3].bullet_start_offset = {vec_2(60, 70)}
tt.attacks.list[3].cooldown = 2
tt.attacks.list[3].max_range = 448
tt.attacks.list[3].min_range = 50
tt.attacks.list[3].shoot_time = fts(9)
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_ENEMY)
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(50, 0)
tt.health.dead_lifetime = fts(300)
tt.health.hp_max = 8000
tt.health_bar.offset = vec_2(0, ady(160))
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.idle_flip.chance = 1
tt.idle_flip.cooldown = 5
tt.info.fn = scripts.eb_gorilla.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0039"
tt.info.enc_icon = 38
tt.main_script.insert = scripts.eb_gorilla.insert
tt.main_script.update = scripts.eb_gorilla.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].damage_max = 500
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].damage_radius = 44.800000000000004
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = vec_2(50, 0)
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].sound = "BossMonkeySmashGround"
tt.motion.max_speed = 0.534 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_gorilla"
tt.sound_events.death = "BossMonkeyDeath"
tt.sound_events.insert = "MusicBossFight"
tt.sound_events.jump_to_tower = "BossMonkeyJumpToTotem"
tt.sound_events.drop_from_sky = "BossMonkeyFallSpawn"
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, ady(73))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_BLOOD)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
--#endregion
--#region fx_gorilla_boss_heal
tt = RT("fx_gorilla_boss_heal", "fx")
tt.render.sprites[1].name = "fx_gorilla_boss_heal"
tt.render.sprites[1].anchor.y = 0.21
--#endregion
--#region fx_gorilla_boss_jump_smoke
tt = RT("fx_gorilla_boss_jump_smoke", "fx")
tt.render.sprites[1].name = "fx_gorilla_boss_jump_smoke"
tt.render.sprites[1].anchor.y = 0.12
--#endregion
--#region gorilla_boss_barrel
tt = RT("gorilla_boss_barrel", "bomb")
tt.bullet.flight_time_base = fts(30)
tt.bullet.flight_time_factor = fts(0.025)
tt.bullet.g = -0.85 / (fts(1) * fts(1))
tt.bullet.warp_time = 2
tt.bullet.damage_min = 100
tt.bullet.damage_max = 150
tt.bullet.damage_radius = 51.2
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_decay_random = true
tt.bullet.pop = nil
tt.render.sprites[1].name = "CanibalBoos_Proy"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
--#endregion
--#region enemy_gorilla_small
tt = RT("enemy_gorilla_small", "enemy")

AC(tt, "melee")

anchor_y = 0.21
image_y = 68
tt.enemy.gold = 50
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.armor = 0
tt.health.hp_max = 1200
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(64))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0038"
tt.info.enc_icon = 39
tt.main_script.insert = scripts.enemy_gorilla_small.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 100
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.067 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "enemy_gorilla_small"
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.unit.hit_offset = vec_2(0, 14)
tt.unit.marker_offset = vec_2(0, ady(13))
tt.unit.mod_offset = vec_2(0, ady(28))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.sound_events.death = "DeathBig"
--#endregion
--#region gorilla_small_liana
tt = RT("gorilla_small_liana", "decal_scripted")

AC(tt, "sound_events")

tt.main_script.update = scripts.gorilla_small_liana.update
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].name = "gorilla_small_liana"
tt.spawn_name = "gorilla_small_falling"
tt.spawn_offset = {vec_2(-130, 38), vec_2(130, 38)}
tt.spawn_time = fts(8)
tt.spawn_dest = nil
tt.sound_events.insert = "BossMonkeyMonkeysScreams"
--#endregion
--#region gorilla_small_falling
tt = RT("gorilla_small_falling", "bomb")
tt.render.sprites[1].name = "CanibalBoos_Offspring_0030"
tt.bullet.flight_time = fts(27)
tt.bullet.vis_bans = F_ALL
tt.bullet.hit_fx = "enemy_gorilla_small"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.bullet.hide_radius = nil
tt.bullet.rotation_speed = nil
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
--#endregion
--#region eb_umbra
tt = RT("eb_umbra", "boss")

AC(tt, "melee", "attacks")

anchor_y = 0.18
image_y = 176
tt.attacks.list[1] = CC("spawn_attack")
tt.attacks.list[1].animation = "open_portals"
tt.attacks.list[1].cooldowns = {}
tt.attacks.list[1].cooldowns.at_home = {3, 3, 1, 1, 0, 0, 0, 2, 2, 2}
tt.attacks.list[1].cooldowns.on_battlefield = {0, 0, 0, 0, 3, 3, 3, 3, 3, 3}
tt.attacks.list[1].cooldown = nil
tt.attacks.list[1].entity = "umbra_portal"
tt.attacks.list[1].nodes_left = {{np(1, 1, 53), np(2, 1, 53)}, {np(1, 1, 85), np(2, 1, 85)}}
tt.attacks.list[1].nodes_right = {{np(3, 1, 26), np(4, 1, 24)}, {np(3, 1, 68), np(4, 1, 69)}}
tt.attacks.list[1].count_min = 3
tt.attacks.list[1].add_per_missing_piece = 0.4
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].cooldowns = {}
tt.attacks.list[2].cooldowns.at_home = {7, 7, 7, 7, 8, 8, 8, 8, 8, 8}
tt.attacks.list[2].cooldowns.on_battlefield = {6, 6, 6, 6, 8, 8, 8, 8, 8, 8}
tt.attacks.list[2].cooldown = nil
tt.attacks.list[2].max_side_jumps = 3
tt.attacks.list[2].nodes_battlefield = {np(5, 1, 48), np(2, 1, 69), np(3, 1, 51)}
tt.attacks.list[3] = CC("bullet_attack")
tt.attacks.list[3].animation = "eyes"
tt.attacks.list[3].bullet = "ray_umbra"
tt.attacks.list[3].bullet_start_offset = {vec_2(-9, ady(109)), vec_2(9, ady(109))}
tt.attacks.list[3].cooldown = 2.5
tt.attacks.list[3].max_range = 192
tt.attacks.list[3].shoot_time = fts(17)
tt.attacks.list[3].vis_bans = bor(F_FLYING, F_ENEMY)
tt.attacks.list[3].sound = "FrontiersFinalBossRay"
tt.attacks.list[4] = table.deepclone(tt.attacks.list[3])
tt.attacks.list[4].inner_towers = {"3", "4", "5", "8", "11", "13"}
tt.attacks.list[4].lower_towers = {"7", "9", "15", "16"}
tt.attacks.list[4].cooldowns = {}
tt.attacks.list[4].cooldowns.at_home = {2, 2, 0, 0, 1, 1, 1, 0, 0, 0}
tt.attacks.list[4].cooldowns.on_battlefield = {1, 2, 2, 2, 0, 0, 0, 0, 0, 0}
tt.attacks.list[4].bullet = "ray_umbra_tower"
tt.attacks.list[4].sound = "FrontiersFinalBossRayTower"
tt.attacks.list[5] = CC("spawn_attack")
tt.attacks.list[5].entity = "enemy_umbra_piece_flying"
tt.attacks.list[5].payload_entity = "enemy_umbra_piece"
tt.attacks.list[5].start_offset_x = {-20, 20}
tt.attacks.list[5].start_offset_y = {60, 80}
tt.attacks.list[5].dest_pi = {5, 6, 7, 8, 9}
tt.attacks.list[5].initial_ni = 20
tt.attacks.list[5].limit_ni = 50
tt.attacks.list[5].cooldown = 30
tt.attacks.list[5].callback_pieces = {7, 4, 2}
tt.attacks.list[5].min_pieces_to_respawn = 3
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.dead_lifetime = fts(1000)
tt.health.hp_max = {7000, 9000, 9999, 11111}
tt.health_bar.offset = vec_2(0, ady(166))
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.hidden = true
tt.info.fn = scripts.eb_umbra.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0040"
tt.info.enc_icon = 40
tt.main_script.insert = scripts.eb_umbra.insert
tt.main_script.update = scripts.eb_umbra.update
tt.motion.max_speed = 0.534 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "eb_umbra"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "eb_umbra"
tt.render.sprites[2].name = "eyes"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].anchor.y = anchor_y
tt.taunt = {}
tt.taunt.cooldown = 4
tt.taunt.format = "FINAL_BOSS_TAUNT_%04d"
tt.taunt.start_idx = 3
tt.taunt.end_idx = 25
tt.taunt.left_pos = vec_2(331, 677)
tt.taunt.right_pos = vec_2(696, 677)
tt.taunt.duration = 4
tt.taunt.ts = 0
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, 55)
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, ady(80))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans_at_home = bor(F_RANGED, F_SKELETON, F_MOD, F_BLOCK, F_LETHAL, F_FREEZE)
tt.vis.bans_in_battlefield = bor(F_SKELETON, F_POISON, F_LETHAL, F_FREEZE)
tt.vis.bans_in_pieces = F_ALL
tt.vis.bans = tt.vis.bans_at_home
tt.vis.flags = bor(F_ENEMY, F_BOSS)
--#endregion
--#region decal_umbra_shoutbox
tt = RT("decal_umbra_shoutbox", "decal_tween")

AC(tt, "texts", "timed")

tt.render.sprites[1].name = "finalBoss_tauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(20, 2)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(176, 70)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_sizes = {24, 23, 18}
tt.texts.list[1].color = {94, 217, 229}
tt.texts.list[1].line_height = 0.8
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
--#region ray_umbra
tt = RT("ray_umbra", "bullet")
tt.image_width = 190
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "ray_umbra"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 100
tt.bullet.damage_max = 150
tt.bullet.damage_radius = 64
tt.bullet.max_track_distance = 50
tt.bullet.vis_bans = bor(F_ENEMY, F_FLYING)
tt.bullet.hit_time = fts(7)
tt.bullet.hit_fx = "fx_ray_umbra_explosion"
--#endregion
--#region ray_umbra_tower
tt = RT("ray_umbra_tower", "ray_umbra")
tt.bullet.damage_radius = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = nil
tt.bullet.mod = "mod_umbra"
--#endregion
--#region fx_ray_umbra_explosion
tt = RT("fx_ray_umbra_explosion", "fx")
tt.render.sprites[1].name = "ray_umbra_explosion"
--#endregion
--#region fx_ray_umbra_explosion_smoke
tt = RT("fx_ray_umbra_explosion_smoke", "fx")
tt.render.sprites[1].name = "ray_umbra_explosion_smoke"
--#endregion
--#region fx_umbra_death_blast
tt = RT("fx_umbra_death_blast", "fx")
tt.render.sprites[1].prefix = "umbra_death_blast"
tt.render.sprites[1].name = "short"
tt.render.sprites[1].anchor.y = 0.18
--#endregion
--#region mod_umbra
tt = RT("mod_umbra", "modifier")

AC(tt, "render")

tt.main_script.update = scripts.mod_tower_remove.update
tt.modifier.hide_time = fts(22)
tt.render.sprites[1].anchor.y = 0.19
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[1].name = "umbra_tower_remove"
--#endregion
--#region umbra_portal
tt = RT("umbra_portal", "decal_scripted")

AC(tt, "render", "spawner")

tt.main_script.update = scripts.umbra_portal.update
tt.render.sprites[1].prefix = "umbra_portal"
tt.render.sprites[1].z = Z_DECALS
tt.spawner.count = 0
tt.spawner.cycle_time = fts(6)
tt.spawner.entity = "enemy_umbra_minion"
tt.spawner.animation_start = "start"
tt.spawner.animation_loop = "loop"
tt.spawner.animation_end = "end"
tt.spawner.ni_var = 3
tt.spawner.spawn_fx = "fx_umbra_minion_spawn"
--#endregion
--#region fx_umbra_minion_spawn
tt = RT("fx_umbra_minion_spawn", "fx")
tt.render.sprites[1].name = "umbra_minion_spawn"
tt.render.sprites[1].anchor.y = 0.19
--#endregion
--#region enemy_umbra_minion
tt = RT("enemy_umbra_minion", "enemy")

AC(tt, "melee")

anchor_y = 0.19
image_y = 66
tt.enemy.gold = 6
tt.enemy.melee_slot = vec_2(26, 0)
tt.health.armor = 0
tt.health.hp_max = 430
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(62))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0055"
tt.info.enc_icon = 41
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 170
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 0.967 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "enemy_umbra_minion"
tt.sound_events.death = "DeathPuff"
tt.unit.can_explode = false
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = vec_2(0, 16)
tt.unit.marker_offset = vec_2(0, ady(13))
tt.unit.mod_offset = vec_2(0, ady(30))
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
--#endregion
--#region enemy_umbra_piece
tt = RT("enemy_umbra_piece", "enemy")

AC(tt, "melee", "timed")

anchor_y = 0.21
image_y = 70
tt.enemy.gold = 90
tt.enemy.melee_slot = vec_2(30, 0)
tt.health.armor = 0
tt.health.hp_max = 1000
tt.health.magic_armor = 0
tt.health_bar.offset = vec_2(0, ady(59))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "kr2_info_portraits_enemies_0056"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_umbra_piece.update
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 1.067 * FPS
tt.motion.max_speed_called = 6.656000000000001 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].prefix = "enemy_umbra_piece"
tt.sound_events.death = "DeathPuff"
tt.sound_events.raise = "FrontiersFinalBossPiecesRespawn"
tt.timed.disabled = true
tt.ui.click_rect = r(-20, -5, 40, 50)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 24)
tt.unit.marker_offset = vec_2(0, ady(14))
tt.unit.mod_offset = vec_2(0, ady(33))
tt.unit.show_blood_pool = false
tt.unit.hide_after_death = true
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = F_ALL
tt.vis.bans_walking = bor(F_SKELETON, F_EAT, F_POISON, F_TWISTER, F_POLYMORPH, F_TELEPORT)
tt.piece_respawn_delay = fts(35) + 3
tt.piece_respawn_delay_repeating = fts(35)
--#endregion
--#region enemy_umbra_piece_flying
tt = RT("enemy_umbra_piece_flying", "bomb")
tt.render.sprites[1].name = "enemy_umbra_piece_flying"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = false
tt.bullet.flight_time = fts(20)
tt.bullet.vis_bans = F_ALL
tt.bullet.hit_fx = nil
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.bullet.rotation_speed = nil
tt.bullet.hide_radius = nil
tt.bullet.align_with_trajectory = true
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.sound_events.hit_water = nil
--#endregion
--#region fx_umbra_white_circle
tt = RT("fx_umbra_white_circle", "decal_tween")
tt.render.sprites[1].name = "white_explosion"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(0.3, 0.3)}, {0.6, vec_2(20, 20)}}
--#endregion
--#region umbra_crystals
tt = RT("umbra_crystals", "decal_scripted")
tt.render.sprites[1].prefix = "umbra_crystals"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS - 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "umbra_crystals_crack1"
tt.render.sprites[2].hidden = true
tt.render.sprites[2].loop = false
tt.render.sprites[3] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[3].name = "umbra_crystals_crack2"
tt.render.sprites[4] = table.deepclone(tt.render.sprites[2])
tt.render.sprites[4].name = "umbra_crystals_crack3"
tt.main_script.update = scripts.decal_umbra_crystals.update
--#endregion
--#region umbra_crystals_broken
tt = RT("umbra_crystals_broken", "decal")
tt.render.sprites[1].name = "finalBoss_spawn_0108"
tt.render.sprites[1].animated = false
--#endregion
--#region umbra_crystals_piece
tt = RT("umbra_crystals_piece", "decal_tween")
tt.render.sprites[1].name = "umbra_crystals_piece"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 255}, {fts(21), 255}, {fts(21) + 1, 0}}
--#endregion
--#region umbra_guy
tt = RT("umbra_guy", "decal_scripted")

AC(tt, "attacks")

tt.main_script.update = scripts.umbra_guy.update
tt.render.sprites[1].prefix = "umbra_guy"
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].bullet = "ray_umbra_guy"
tt.attacks.list[1].cooldown = 40
tt.attacks.list[1].vis_bans = bor(F_FLYING, F_ENEMY)
tt.attacks.list[1].shoot_time = fts(19)
tt.attacks.list[1].max_range = 300.16
tt.attacks.list[1].bullet_start_offset = vec_2(-17, 41)
tt.taunt = {}
tt.taunt.cooldown = 20
tt.taunt.format = "FINAL_BOSS_GUY_TAUNT_%04d"
tt.taunt.normal_idx = {3, 25}
tt.taunt.attack_idx = {30, 34}
tt.taunt.lost_life_idx = {26, 29}
tt.taunt.normal_pos = vec_2(579, 655)
tt.taunt.death_pos = vec_2(656, 610)
tt.taunt.duration = 4
tt.taunt.attack_duration = 1.25
tt.taunt.shoutbox = "decal_umbra_guy_shoutbox"
tt.taunt.ts = 0
--#endregion
--#region umbra_guy_force_field
tt = RT("umbra_guy_force_field", "decal_tween")
tt.render.sprites[1].name = "finalBoss_guy_forceShield_0013"
tt.render.sprites[1].animated = false
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_2(1, 1)}, {0.25, vec_2(0.92, 0.92)}, {0.5, vec_2(1, 1)}}
tt.tween.props[1].loop = true
--#endregion
--#region ray_umbra_guy
tt = RT("ray_umbra_guy", "bullet")
tt.image_width = 238
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].name = "ray_umbra_guy"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_min = 200
tt.bullet.damage_max = 400
tt.bullet.damage_radius = 60.160000000000004
tt.bullet.max_track_distance = 50
tt.bullet.vis_bans = bor(F_ENEMY, F_FLYING)
tt.bullet.hit_time = fts(7)
tt.bullet.hit_fx = "fx_ray_umbra_guy_explosion"
tt.sound_events.insert = "TeslaAttack"
--#endregion
--#region fx_ray_umbra_guy_explosion
tt = RT("fx_ray_umbra_guy_explosion", "fx")
tt.render.sprites[1].name = "ray_umbra_guy_explosion"
--#endregion
--#region decal_umbra_guy_shoutbox
tt = RT("decal_umbra_guy_shoutbox", "decal_tween")

AC(tt, "texts", "timed")

tt.render.sprites[1].name = "finalBoss_GuyTauntBox"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[2].offset = vec_2(7, 15)
tt.texts.list[1].text = "Hello world"
tt.texts.list[1].size = vec_2(168, 60)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 20
tt.texts.list[1].color = {255, 145, 114}
tt.texts.list[1].line_heights = {0.8, 0.8}
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
--#region eb_leviathan
tt = RT("eb_leviathan", "boss")

AC(tt, "attacks")

anchor_y = 0.15254237288135594
image_y = 118
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].cooldown = 12
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(50, 0)
tt.health.dead_lifetime = fts(200)
tt.health.hp_max = 8500
tt.health_bar.offset = vec_2(0, ady(120))
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_leviathan.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0060"
tt.info.enc_icon = 48
tt.main_script.insert = scripts.eb_leviathan.insert
tt.main_script.update = scripts.eb_leviathan.update
tt.motion.max_speed = 0.384 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "eb_leviathan_water"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].loop_forced = true
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].anchor.y = anchor_y
tt.render.sprites[2].prefix = "eb_leviathan"
tt.render.sprites[2].name = "spawn"
tt.ui.click_rect = r(-50, 0, 100, 80)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hide_after_death = true
tt.unit.hit_offset = vec_2(0, ady(47))
tt.unit.marker_hidden = true
tt.unit.mod_offset = vec_2(0, ady(65))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.unit.hit_rect = r(-58, 0, 116, 78)
tt.vis.bans = F_ALL
tt.vis.bans_in_battlefield = bor(F_STUN, F_BLOOD, F_DRILL, F_LETHAL, F_SKELETON, F_POLYMORPH, F_TELEPORT, F_BLOCK)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.sound_events.spawn = "RTBossSpawn"
tt.sound_events.death = "RTBossDeath"
--#endregion
--#region leviathan_head
tt = RT("leviathan_head", "decal")
tt.render.sprites[1].prefix = "leviathan_head"
tt.render.sprites[1].name = "show"
tt.render.sprites[1].anchor.y = 0.4830508474576271
--#endregion
--#region leviathan_tentacle
tt = RT("leviathan_tentacle", "decal_scripted")
tt.render.sprites[1].prefix = "leviathan_tentacle"
tt.render.sprites[1].name = "show"
tt.render.sprites[1].anchor.y = 0.23076923076923078
tt.main_script.update = scripts.leviathan_tentacle.update
tt.tower_bans = {"tower_mech"}
tt.range = 50
tt.search_off_x = 90
tt.duration = 8
tt.interrupt = nil
tt.flip = nil
--#endregion
--#region fx_leviathan_incoming
tt = RT("fx_leviathan_incoming", "decal_tween")
tt.tween.remove = true
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {{0, 0}, {1, 255}, {3, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_2(0.35, 0.35)}, {3, vec_2(1, 1)}}
tt.render.sprites[1].name = "fx_leviathan_bubbles"
tt.render.sprites[1].z = Z_DECALS + 2
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor.y = 0.15254237288135594
--#endregion
--#region eb_dracula
tt = RT("eb_dracula", "boss")

AC(tt, "melee")

image_y = 80
anchor_y = 0.1375
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(15, 0)
tt.health.dead_lifetime = fts(1000)
tt.health.hp_max = 8475
tt.health_bar.offset = vec_2(0, 60)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
-- tt.info.fn = scripts.eb_dracula.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0067"
tt.info.enc_icon = 57
tt.main_script.insert = scripts.eb_dracula.insert
tt.main_script.update = scripts.eb_dracula.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 200
tt.melee.attacks[1].damage_min = 150
tt.melee.attacks[1].hit_time = fts(19)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].mod = "mod_dracula_lifesteal"
tt.melee.attacks[2].cooldown = 5
tt.melee.attacks[2].animation = "lifesteal"
tt.melee.attacks[2].hit_time = fts(6)
tt.melee.attacks[2].fn_can = scripts.eb_dracula.can_lifesteal
tt.motion.max_speed = 0.427 * FPS
tt.motion.max_speed_bat = 2.56 * FPS
tt.motion.max_speed_default = 0.427 * FPS
tt.motion.max_speed_angry = 0.747 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_dracula"
tt.ui.click_rect = r(-20, -5, 40, 65)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 33)
tt.unit.mod_offset = vec_2(0, ady(33))
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_MEDIUM
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.sound_events.insert = "MusicBossFight"
tt.sound_events.death = "HWBossVampireDeath"
--#endregion
--#region mod_dracula_lifesteal
tt = RT("mod_dracula_lifesteal", "modifier")
tt.modifier.duration = fts(50)
tt.cycle_time = fts(2)
tt.heal_hp = 25
tt.damage = 150
tt.main_script.update = scripts.mod_dracula_lifesteal.update
tt.sound_events.insert = "HWBossVampireLifesteal"
--#endregion
--#region dracula_damage_aura
tt = RT("dracula_damage_aura", "aura")

AC(tt, "render")

tt.aura.cycle_time = fts(2)
tt.aura.duration = -1
tt.aura.radius = 128
tt.aura.dist_factor_min_radius = 38.4
tt.aura.vis_bans = bor(F_ENEMY, F_BOSS)
tt.aura.vis_flags = F_MOD
tt.aura.dps_min = 3 * FPS
tt.aura.dps_max = 18 * FPS
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.hero_damage_factor = 0.5555555555555556
tt.main_script.update = scripts.dracula_damage_aura.update
tt.render.sprites[1].name = "dracula_damage_aura"
tt.render.sprites[1].loop = true
tt.render.sprites[1].anchor = vec_2(0.5289855072463768, 0.48484848484848486)
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region eb_saurian_king
tt = RT("eb_saurian_king", "boss")

AC(tt, "melee", "timed_attacks")

image_y = 150
anchor_y = 0.16666666666666666
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.armor = 0.5
tt.health.dead_lifetime = fts(200)
tt.health.hp_max = 11000
tt.health_bar.offset = vec_2(0, 103)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.fn = scripts.eb_saurian_king.get_info
tt.info.portrait = "kr2_info_portraits_enemies_0042"
tt.info.enc_icon = 60
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_saurian_king.update
tt.motion.max_speed = 1.494 * FPS
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_saurian_king"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 45)
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.sound_events.insert = "MusicBossFight"
tt.sound_events.death = "SaurianKingBossDeath"
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 0
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].damage_radius = 25
tt.melee.attacks[1].hit_time = fts(6)
tt.melee.attacks[1].hit_offset = tt.enemy.melee_slot
tt.melee.attacks[1].mod = "mod_saurian_king_tongue"
tt.melee.attacks[1].sound = "SaurianKingBossTongue"
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"hammer_start", "hammer_loop"}
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].damage_radius = 500
tt.timed_attacks.list[1].damage_type = DAMAGE_EXPLOSION
tt.timed_attacks.list[1].hit_times = {fts(11), fts(18)}
tt.timed_attacks.list[1].max_damage_radius = 50
tt.timed_attacks.list[1].max_damages = {10, 15, 25, 40, 65, 100, 145, 200}
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].min_damages = {5, 7, 12, 20, 30, 50, 70, 100}
tt.timed_attacks.list[1].sound = "SaurianKingBossHammer"
tt.timed_attacks.list[1].vis_flags = F_RANGED
tt.timed_attacks.list[1].fx_offsets = {vec_2(48, -11), vec_2(62, 1)}
--#endregion
--#region decal_saurian_king_hammer
tt = RT("decal_saurian_king_hammer", "fx")
tt.render.sprites[1].name = "decal_saurian_king_hammer"
tt.render.sprites[1].z = Z_DECALS
--#endregion
--#region mod_saurian_king_tongue
tt = RT("mod_saurian_king_tongue", "modifier")
tt.main_script.insert = scripts.mod_saurian_king_tongue.insert
tt.modifier.damage_radius = 25
tt.modifier.damage_max = 150
tt.modifier.damage_min = 100
tt.modifier.vis_flags = F_MOD
tt.modifier.vis_bans = bor(F_ENEMY, F_FLYING)
--#endregion
--#region eb_gnoll
tt = RT("eb_gnoll", "boss")

AC(tt, "melee", "timed_attacks", "auras")

tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "gnoll_boss_aura"
tt.auras.list[1].cooldown = 0
tt.enemy.gold = 1
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.armor = 0.6
tt.health.dead_lifetime = 50
tt.health.hp_max = 8000
tt.health_bar.offset = vec_2(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 26
tt.info.i18n_key = "EB_GNOLL"
tt.info.portrait = "kr3_info_portraits_enemies_0010"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_gnoll.update
tt.motion.max_speed = 0.83 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.2948717948717949)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_gnoll"
tt.sound_events.death = "ElvesHyenaDeath"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 50)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 40)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 70
tt.melee.attacks[1].hit_time = fts(22)
tt.melee.attacks[1].uninterruptible = true
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].cooldown = {7, 7, 7, 5}
tt.timed_attacks.list[1].hit_time = fts(55)
tt.timed_attacks.list[1].animation = "specialAttack"
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].max_range = 9e+99
tt.timed_attacks.list[1].damage_max = {180, 180, 180, 1000}
tt.timed_attacks.list[1].damage_min = 150
tt.timed_attacks.list[1].damage_max_hero = 120
tt.timed_attacks.list[1].damage_min_hero = 100
tt.timed_attacks.list[1].damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
tt.timed_attacks.list[1].sound = "ElvesHyenaStomp"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animation = "scream"
tt.timed_attacks.list[2].nis = {85, 135, 180}
tt.timed_attacks.list[2].wave_names = {"Boss_Path_1", "Boss_Path_2", "Boss_Path_3", "Boss_Path_4"}
tt.timed_attacks.list[2].hit_time = fts(8)
tt.timed_attacks.list[2].sound = "ElvesHyenaGrowl"
--#endregion
--#region gnoll_boss_aura
tt = RT("gnoll_boss_aura", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(5)
tt.aura.duration = -1
tt.aura.filter_source = true
tt.aura.mod = "mod_gnoll_boss"
tt.aura.radius = 150
tt.aura.track_source = true
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.vis_flags = F_MOD
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update
tt.render.sprites[1].name = "bossHiena_aura_base"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "bossHiena_aura_ring"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 102}, {fts(9), 173}, {fts(21), 20}, {fts(30), 20}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[1].loop = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_2(0.65, 0.65)}, {fts(30), vec_2(1.57, 1.57)}}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].loop = true
--#endregion
--#region mod_gnoll_boss
tt = RT("mod_gnoll_boss", "modifier")

AC(tt, "render")

tt.render.sprites[1].name = "bossHiena_creepFx"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.main_script.insert = scripts.mod_gnoll_boss.insert
tt.main_script.remove = scripts.mod_gnoll_boss.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = fts(6)
tt.modifier.use_mod_offset = false
tt.extra_health_factor = 0.5
tt.inflicted_damage_factor = 1.5
--#endregion
--#region eb_drow_queen
tt = RT("eb_drow_queen", "boss")

AC(tt, "melee", "taunts", "tween")

tt.info.enc_icon = 27
tt.info.i18n_key = "EB_DROW_QUEEN"
tt.info.portrait = "kr3_info_portraits_enemies_0039"
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(25, 0)
tt.health.hp_max = {6000, 9000, 12000, 13500}
tt.health.hp_max_rounds = {{6000, 4000, 2000}, {9000, 6000, 3000}, {12000, 9000, 5000}, {13500, 10000, 5500}}
tt.health.on_damage = scripts.eb_drow_queen.on_damage
tt.health.dead_lifetime = 50
tt.health_bar.hidden = true
tt.health_bar.offset = vec_2(0, 49)
tt.health_bar.sort_y_offset = -2
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.main_script.update = scripts.eb_drow_queen.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_radius = 30
tt.melee.attacks[1].damage_max = {120, 120, 120, 500}
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].damage_type = bor(DAMAGE_MAGICAL, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_offset = vec_2(29, 0)
tt.melee.attacks[1].hit_time = fts(24)
tt.melee.attacks[1].uninterruptible = true
tt.motion.max_speed = 0.913 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.15384615384615385)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].prefix = "s11_malicia"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "malicia_glow_0001"
tt.render.sprites[2].anchor.y = 0.058823529411764705
tt.render.sprites[2].draw_order = 2
tt.render.sprites[2].alpha = 0
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "malicia_glow_0002"
tt.render.sprites[3].anchor.y = 0.058823529411764705
tt.render.sprites[3].draw_order = -2
tt.render.sprites[3].alpha = 0
tt.sound_events.death = "ElvesMaliciaDeath"
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].keys = {{0, 255}, {fts(16), 0}}
tt.tween.props[1].disabled = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 255}, {0.3, 0}}
tt.tween.props[2].sprite_id = 2
tt.tween.props[3] = table.deepclone(tt.tween.props[2])
tt.tween.props[3].sprite_id = 3
tt.ui.click_rect = r(-20, 0, 40, 50)
tt.ui.click_rect_default = r(-20, 0, 40, 50)
tt.ui.click_rect_sitting = r(20, 0, 40, 50)
tt.unit.hit_offset = vec_2(0, 17)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 17)
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF, F_SPELLCASTER)
tt.vis.bans = bor(F_BLOCK, F_RANGED, F_MOD, F_TELEPORT)
tt.fly_speed_normal = 5 * FPS
tt.fly_speed_fight = 3 * FPS
tt.fly_speed_return = 7 * FPS
tt.fly_speed_return_die = 9 * FPS
tt.fly_loop_time = 7 / FPS
tt.fly_offset_y = 26
tt.pos_fighting = vec_2(347, 396)
tt.pos_casting = vec_2(684, 404)
tt.pos_sitting = vec_2(924, 416)
tt.tower_block_sets = {{"12", "13", "14"}, {"12", "13", "14", "6"}, {"12", "13", "14", "6", "9", "5"}, {"12", "13", "14", "6", "9", "5"}}
tt.power_block_duration = {8, 8, 8, 15}
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 4
tt.taunts.sets = {
	welcome = {},
	prebattle = {},
	casting = {},
	sitting = {}
}
tt.taunts.sets.welcome.format = "EB_DROW_QUEEN_TAUNT_KIND_WELCOME_%04d"
tt.taunts.sets.welcome.start_idx = 1
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.prebattle.format = "EB_DROW_QUEEN_TAUNT_KIND_PREBATTLE_%04d"
tt.taunts.sets.prebattle.start_idx = 1
tt.taunts.sets.prebattle.end_idx = 3
tt.taunts.sets.casting.format = "EB_DROW_QUEEN_TAUNT_KIND_CASTING_%04d"
tt.taunts.sets.casting.start_idx = 1
tt.taunts.sets.casting.end_idx = 4
tt.taunts.sets.casting.pos = vec_2(791, 348)
tt.taunts.sets.casting.decal_name = "decal_drow_queen_shoutbox_casting"
tt.taunts.sets.sitting.format = "EB_DROW_QUEEN_TAUNT_KIND_SITTING_%04d"
tt.taunts.sets.sitting.start_idx = 1
tt.taunts.sets.sitting.end_idx = 5
tt.taunts.decal_name = "decal_drow_queen_shoutbox"
tt.taunts.offset = vec_2(0, 0)
tt.taunts.pos = vec_2(870, 376)
--#endregion
--#region decal_drow_queen_shoutbox
tt = RT("decal_drow_queen_shoutbox", "decal_tween")

AC(tt, "texts")

tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "malicia_taunt_0001"
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "malicia_taunt_0002"
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = CC("sprite")
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
tt.tween.props[4] = CC("tween_prop")
tt.tween.props[4].name = "scale"
tt.tween.props[4].keys = {{0, vec_2(1.01, 1.01)}, {0.4, vec_2(0.99, 0.99)}, {0.8, vec_2(1.01, 1.01)}}
tt.tween.props[4].sprite_id = 1
tt.tween.props[4].loop = true
tt.tween.props[5] = table.deepclone(tt.tween.props[4])
tt.tween.props[5].sprite_id = 2
tt.tween.props[6] = table.deepclone(tt.tween.props[4])
tt.tween.props[6].sprite_id = 3
tt.tween.remove = true
--#endregion
--#region decal_drow_queen_shoutbox_casting
tt = RT("decal_drow_queen_shoutbox_casting", "decal_drow_queen_shoutbox")
tt.render.sprites[2].name = "malicia_taunt_0003"
--#endregion
--#region decal_drow_queen_flying
tt = RT("decal_drow_queen_flying", "decal")
tt.render.sprites[1].name = "s11_malicia_teleportLoop"
tt.render.sprites[1].anchor.y = 0.35384615384615387
tt.render.sprites[1].hidden = true
tt.render.sprites[1].sort_y_offset = -24
--#endregion
--#region decal_drow_queen_shield
tt = RT("decal_drow_queen_shield", "decal_scripted")

AC(tt, "tween", "health_bar", "health")

tt.health.hp = 0
tt.health_bar.hidden = true
tt.health_bar.offset = vec_2(0, 52)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.health_bar.colors = {}
tt.health_bar.colors.fg = {255, 65, 240, 255}
tt.health_bar.colors.bg = {51, 18, 53, 255}
tt.health_bar.sort_y_offset = -2
tt.health.ignore_damage = true
tt.main_script.update = scripts.decal_drow_queen_shield.update
tt.render.sprites[1].name = "s11_malicia_shield_idle"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].offset = vec_2(-5, 0)
tt.render.sprites[1].alpha = 0
tt.render.sprites[1].sort_y_offset = -1
tt.tween.remove = false
tt.tween.disabled = true
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1)}, {fts(10), vec_1(1.1)}, {fts(20), vec_1(1)}}
tt.tween.props[1].loop = true
tt.tween.props[1].ignore_reverse = true
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, 0}, {fts(11), 153}}
tt.shield_hp = 0
--#endregion
--#region fx_drow_queen_shield_break
tt = RT("fx_drow_queen_shield_break", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "s11_malicia_shield_break"
tt.render.sprites[1].anchor.y = 0.15384615384615385
tt.render.sprites[1].offset.x = -5
tt.sound_events.insert = "ElvesMaliciaShieldBreak"
--#endregion
--#region fx_drow_queen_cast
tt = RT("fx_drow_queen_cast", "fx")
tt.render.sprites[1].name = "s11_malicia_castFx"
tt.render.sprites[1].anchor.y = 0.15384615384615385
--#endregion
--#region mod_drow_queen_tower_block
tt = RT("mod_drow_queen_tower_block", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_tower_block.update
tt.modifier.duration = 8
tt.render.sprites[1].anchor.y = 0.2
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].sort_y_offset = -2
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "malicia_tower_block"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "malicia_towerNet_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 255}, {fts(8), 204}, {fts(16), 255}}
tt.tween.props[1].loop = true
tt.tween.props[2] = table.deepclone(tt.tween.props[1])
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{0, vec_1(1)}, {fts(8), vec_1(1.015)}, {fts(16), vec_1(1)}}
tt.tween.props[3] = table.deepclone(tt.tween.props[1])
tt.tween.props[3].sprite_id = 2
tt.tween.props[4] = table.deepclone(tt.tween.props[2])
tt.tween.props[4].sprite_id = 2
--#endregion
--#region eb_spider
tt = RT("eb_spider", "boss")

AC(tt, "ranged", "timed_attacks", "taunts")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(53, 0)
tt.health.dead_lifetime = 50
tt.health.hp_max = {12000, 15000, 19000, 21000}
tt.health.hp_max_rounds = {{12000, 9000, 6000, 3000}, {15000, 11000, 7000, 3000}, {19000, 14000, 10000, 6000}, {21000, 16000, 12000, 7000}}
tt.health.magic_armor = 0.5
tt.health_bar.offset = vec_2(0, 106)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 33
tt.info.portrait = "kr3_info_portraits_enemies_0041"
tt.info.i18n_key = "EB_SPIDER"
tt.info.fn = scripts.eb_spider.get_info
tt.main_script.update = scripts.eb_spider.update
tt.motion.max_speed = 0.83 * FPS

for i = 1, 6 do
	local s = CC("sprite")

	s.prefix = "eb_spider_layer" .. i
	s.name = "idle"
	s.anchor.y = 0.3
	s.angles = {}
	s.angles.walk = {"walkingRightLeft", "walkingDown", "walkingDown"}
	tt.render.sprites[i] = s
end

tt.sound_events.death = "ElvesFinalBossDeath"
tt.ui.click_rect = r(-40, 0, 80, 80)
tt.unit.hit_offset = vec_2(0, 38)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 38)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(tt.vis.flags, F_DARK_ELF)
tt.vis.bans = bor(tt.vis.bans, F_STUN)
tt.taunts.decal_name = "decal_eb_spider_shoutbox"
tt.taunts.duration = 2
tt.taunts.offset = vec_2(130, 120)
tt.taunts.sets = {
	intro = CC("taunt_set"),
	death = CC("taunt_set")
}
tt.taunts.sets.intro.format = "EB_SPIDER_TAUNT_KIND_OURS"
tt.taunts.sets.death.format = "EB_SPIDER_DEATH_TAUNT"
tt.ranged.attacks[1].bullet = "ray_eb_spider"
tt.ranged.attacks[1].cooldown = 0.5 + fts(29)
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].bullet_start_offset = {vec_2(24, 101)}
tt.ranged.attacks[1].ignore_hit_offset = true
tt.timed_attacks.list[1] = table.deepclone(tt.ranged.attacks[1])
tt.timed_attacks.list[1].cooldown = {7, 7, 6}
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].max_range = 225
tt.timed_attacks.list[1].shoot_time = fts(13)
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].cooldown = {8, 8, 7}
tt.timed_attacks.list[2].animation = "blockTower"
tt.timed_attacks.list[2].hit_time = fts(13)
tt.timed_attacks.list[2].power_block_duration = 5
tt.timed_attacks.list[2].hit_sound = "ElvesFinalBossCastSpell"
tt.timed_attacks.list[2].tower_count = {1, 2, 3, 3}
tt.timed_attacks.list[2].mod = "mod_eb_spider_tower_block"
tt.timed_attacks.list[3] = CC("bullet_attack")
tt.timed_attacks.list[3].bullet = "ray_eb_spider_tower"
tt.timed_attacks.list[3].max_range = 200
tt.timed_attacks.list[3].excluded_templates = {"tower_drow"}
tt.timed_attacks.list[3].shoot_time = fts(8)
tt.timed_attacks.list[3].animations = {"shootTower_start", "shootTower_loop", "shootTower_end"}
tt.timed_attacks.list[3].sound = "ElvesFinalBossSpiderSuperrayCharge"
tt.timed_attacks.list[3].bullet_start_offset = {vec_2(19, 42)}
--#endregion
--#region ray_eb_spider
tt = RT("ray_eb_spider", "bullet")
tt.bullet.damage_max = 120
tt.bullet.damage_min = 80
tt.bullet.damage_radius = 45
tt.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
tt.bullet.hit_fx = "fx_ray_eb_spider_explosion"
tt.bullet.hit_time = fts(5)
tt.bullet.ignore_hit_offset = true
tt.bullet.vis_bans = bor(F_ENEMY)
tt.image_width = 248
tt.main_script.update = scripts.ray_enemy.update
tt.render.sprites[1].anchor = vec_2(0, 0.5)
tt.render.sprites[1].loop = false
tt.render.sprites[1].name = "ray_eb_spider"
tt.sound_events.insert = "ElvesFinalBosskillray"
--#endregion
--#region ray_eb_spider_tower
tt = RT("ray_eb_spider_tower", "ray_eb_spider")
tt.bullet.damage_radius = 0
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.hit_fx = nil
tt.bullet.mod = "mod_eb_spider_tower_remove"
tt.image_width = 230
tt.render.sprites[1].name = "ray_eb_spider_tower"
tt.sound_events.insert = "ElvesFinalBossSpiderSuperrayDischarge"
--#endregion
--#region mod_eb_spider_tower_block
tt = RT("mod_eb_spider_tower_block", "mod_drow_queen_tower_block")
tt.modifier.duration = 5
tt.render.sprites[1].prefix = "eb_spider_tower_block"
tt.render.sprites[2].name = "spiderQueen_towerNet_decal"
--#endregion
--#region mod_eb_spider_tower_remove
tt = RT("mod_eb_spider_tower_remove", "modifier")

AC(tt, "render", "tween")

tt.main_script.update = scripts.mod_tower_remove.update
tt.modifier.hide_time = fts(27)
tt.render.sprites[1].name = "mod_eb_spider_tower_remove_explosion"
tt.render.sprites[1].anchor.y = 0.375
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "spiderQueen_towerExplosion_ring"
tt.render.sprites[2].animated = false
tt.render.sprites[2].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].keys = {{fts(23), 0}, {fts(24), 255}, {fts(28), 255}, {fts(35), 0}}
tt.tween.props[1].sprite_id = 2
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].name = "scale"
tt.tween.props[2].keys = {{fts(24), vec_1(0.24)}, {fts(28), vec_1(1)}, {fts(35), vec_1(1.2)}}
tt.tween.props[2].sprite_id = 2
--#endregion
--#region fx_ray_eb_spider_explosion
tt = RT("fx_ray_eb_spider_explosion", "fx")
tt.render.sprites[1].name = "fx_ray_eb_spider_explosion"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "fx_ray_eb_spider_decal"
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS
--#endregion
--#region fx_eb_spider_spawn
tt = RT("fx_eb_spider_spawn", "decal_tween")
tt.render.sprites[1].name = "fx_eb_spider_spawn"
tt.render.sprites[1].offset.y = 43
tt.tween.disabled = true
tt.tween.props[1].keys = {{fts(0), 255}, {fts(5), 0}}
--#endregion
--#region fx_eb_spider_jump_smoke
tt = RT("fx_eb_spider_jump_smoke", "fx")
tt.render.sprites[1].name = "fx_eb_spider_jump_smoke"
tt.render.sprites[1].anchor.y = 0.12
--#endregion
--#region decal_shadow_eb_spider
tt = RT("decal_shadow_eb_spider", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_shadow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.y = 0.31153846153846154
tt.tween.remove = false
tt.tween.props[1].keys = {{0, 0}, {0.55, 255}, {0.6, 255}}
tt.tween.props[2] = CC("tween_prop")
tt.tween.props[2].keys = {{0, vec_1(0)}, {0.55, vec_1(1)}, {0.6, vec_1(1)}}
tt.tween.props[2].name = "scale"
--#endregion
--#region decal_eb_spider_death_second_rays
tt = RT("decal_eb_spider_death_second_rays", "decal_tween")
tt.tween.remove = false

local angles = {32, -48, 118, -128}

for i = 1, 4 do
	tt.render.sprites[i] = CC("sprite")
	tt.render.sprites[i].name = "spiderQueen_deathShapes_0001"
	tt.render.sprites[i].animated = false
	tt.render.sprites[i].r = d2r(angles[i])
	tt.render.sprites[i].z = Z_OBJECTS + 1

	local d = (i - 1) * 9 + (i == 4 and 2 or 0)

	tt.tween.props[2 * i - 1] = CC("tween_prop")
	tt.tween.props[2 * i - 1].name = "scale"
	tt.tween.props[2 * i - 1].keys = {{fts(0), vec_2(1, 1.25)}, {fts(2), vec_1(0.75)}, {fts(4), vec_2(1, 1.25)}}
	tt.tween.props[2 * i - 1].sprite_id = i
	tt.tween.props[2 * i - 1].time_offset = fts(i - 1)
	tt.tween.props[2 * i - 1].loop = true
	tt.tween.props[2 * i] = CC("tween_prop")
	tt.tween.props[2 * i].name = "scale"
	tt.tween.props[2 * i].keys = {{fts(d), vec_1(0)}, {fts(d + 2), vec_1(0.4)}, {fts(d + 3), vec_1(1)}}
	tt.tween.props[2 * i].sprite_id = i
	tt.tween.props[2 * i].multiply = true
end

tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[5].animated = false
tt.render.sprites[5].z = Z_OBJECTS + 1
tt.tween.props[9] = CC("tween_prop")
tt.tween.props[9].name = "scale"
tt.tween.props[9].keys = {{0, vec_1(0.8)}, {fts(2), vec_1(1)}, {fts(4), vec_1(0.8)}}
tt.tween.props[9].loop = true
tt.tween.props[9].sprite_id = 5
--#endregion
--#region decal_eb_spider_death_white_circle
tt = RT("decal_eb_spider_death_white_circle", "decal_tween")
tt.render.sprites[1].name = "spiderQueen_deathShapes_0002"
tt.render.sprites[1].animated = false
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_GUI - 2
tt.tween.remove = false
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {{0, vec_1(1.5)}, {fts(7), vec_1(60)}}
--#endregion
--#region decal_eb_spider_shoutbox
tt = RT("decal_eb_spider_shoutbox", "decal_drow_queen_shoutbox")
tt.render.sprites[1].name = "stage15_taunts_0001"
tt.render.sprites[2].name = "stage15_taunts_0003"
tt.render.sprites[3].offset = vec_2(13, -13)
tt.texts.list[1].font_size = i18n:cjk(28, nil, 22, nil)
tt.texts.list[1].size = vec_2(158, 56)
tt.texts.list[1].fit_height = true
--#endregion
--#region eb_bram
tt = RT("eb_bram", "boss")

AC(tt, "melee", "timed_attacks", "taunts")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(40, 0)
tt.health.dead_lifetime = 50
tt.health.hp_max = 11000
tt.health_bar.offset = vec_2(0, 98)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.health_bar.hidden = true
tt.info.enc_icon = 38
tt.info.portrait = "kr3_info_portraits_enemies_0045"
tt.info.i18n_key = "EB_BRAM"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_bram.update
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.24691358024691357)
tt.render.sprites[1].prefix = "eb_bram"
tt.render.sprites[1].name = "sitting"
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingDown", "walkingDown"}
tt.render.sprites[1].angles_custom = {
	walk = {45, 120, 240, 315}
}
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.sound_events.death = "ElvesBossBramDeath"
tt.unit.click_rect = r(-35, 0, 70, 65)
tt.unit.hit_offset = vec_2(0, 50)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(tt.vis.flags)
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH, F_MOD, F_RANGED, F_TELEPORT, F_BLOCK)
tt.pos_sitting = vec_2(716, 584)
tt.nav_path.pi = 7
tt.nav_path.spi = 1
tt.nav_path.ni = 1
tt.spawn_at_nodes = {15, 40, 70}
tt.spawn_wave_names = {"Boss_Path_1", "Boss_Path_2", "Boss_Path_3", "Boss_Path_4"}
tt.melee.cooldown = 1.5
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].damage_max = {150, 150, 150, 250}
tt.melee.attacks[1].damage_min = {100, 100, 100, 200}
tt.melee.attacks[1].hit_time = fts(11)
tt.melee.attacks[1].shared_cooldown = true
tt.melee.attacks[1].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) ~= 0
end
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "attack"
tt.melee.attacks[2].damage_type = bor(DAMAGE_NONE, DAMAGE_NO_DODGE)
tt.melee.attacks[2].hit_time = fts(11)
tt.melee.attacks[2].mod = "mod_bram_slap"
tt.melee.attacks[2].shared_cooldown = true
tt.melee.attacks[2].sound_hit = "ElvesBossBramSlap"
tt.melee.attacks[2].fn_can = function(t, s, a, target)
	return band(target.vis.flags, F_HERO) == 0
end
tt.melee.attacks[2].vis_flags = bor(F_BLOCK, F_EAT, F_INSTAKILL)
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].allowed_templates = {"enemy_gnoll_burner", "enemy_gnoll_reaver"}
tt.timed_attacks.list[1].mod = "mod_bloodsydian_warlock"
tt.timed_attacks.list[1].animation = "special"
tt.timed_attacks.list[1].cast_time = fts(18)
tt.timed_attacks.list[1].hit_decal = "decal_bloodsydian_warlock"
tt.timed_attacks.list[1].cooldown = {7, 7, 7, 5}
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].max_count = 10
tt.timed_attacks.list[1].min_count = 3
tt.timed_attacks.list[1].nodes_limit = 0
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED, F_MOD)
tt.timed_attacks.list[1].sound = "ElvesBossBramGroundStomp"
tt.taunts.delay_min = 15
tt.taunts.delay_max = 20
tt.taunts.duration = 3.7
tt.taunts.decal_name = "decal_s18_shoutbox"
tt.taunts.offset = vec_2(0, 0)
tt.taunts.pos = vec_2(736, 719)
tt.taunts.sets.welcome = CC("taunt_set")
tt.taunts.sets.welcome.format = "BOSS_BRAM_TAUNT_WELCOME_%04d"
tt.taunts.sets.welcome.end_idx = 2
tt.taunts.sets.sitting = CC("taunt_set")
tt.taunts.sets.sitting.format = "BOSS_BRAM_TAUNT_GENERIC_%04d"
tt.taunts.sets.sitting.end_idx = 5
tt.taunts.sets.prebattle = CC("taunt_set")
tt.taunts.sets.prebattle.format = "BOSS_BRAM_TAUNT_PREBATTLE_%04d"
tt.taunts.sets.prebattle.end_idx = 3
--#endregion
--#region mod_bram_slap
tt = RT("mod_bram_slap", "modifier")
tt.main_script.queue = scripts.mod_bram_slap.queue
tt.main_script.update = scripts.mod_bram_slap.update
tt.custom_anchors = {}
tt.custom_anchors.default = vec_2(0.5, 0.45)
--#endregion
--#region eb_bajnimen
tt = RT("eb_bajnimen", "boss")

AC(tt, "melee", "ranged", "timed_attacks")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(60, 0)
tt.health.dead_lifetime = 50
tt.health.armor = 0.2
tt.health.magic_armor = {0, 0, 0.5, 0.5}
tt.health.hp_max = 10000
tt.health.on_damage = scripts.eb_bajnimen.on_damage
tt.health_bar.offset = vec_2(-15, 145)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.info.enc_icon = 42
tt.info.i18n_key = "EB_BAJNIMEN"
tt.info.portrait = "kr3_info_portraits_enemies_0049"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_bajnimen.update
tt.motion.max_speed = 0.996 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.1336206896551724)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_bajnimen"
tt.sound_events.death = "ElvesBajNimenBossDeath"
tt.ui.click_rect = r(-35, 0, 70, 130)
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(-17, 86)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(17, 75)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = {150, 150, 250}
tt.melee.attacks[1].damage_min = {120, 120, 200}
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].sound = "ElvesBajNimenBossTail"
tt.melee.attacks[1].sound_args = {
	delay = fts(5)
}
tt.melee.attacks[1].uninterruptible = true
tt.ranged.attacks[1].bullet = "bolt_bajnimen"
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].shoot_time = fts(7)
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 20
tt.ranged.attacks[1].bullet_start_offset = {vec_2(30, 135)}
tt.timed_attacks.list[1] = CC("custom_attack")
tt.timed_attacks.list[1].animations = {"shadowStorm_start", "shadowStorm_loop", "shadowStorm_end"}
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_BOSS)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].sound = "ElvesBajNimenBossShadowCast"
tt.timed_attacks.list[1].spread = 5
tt.timed_attacks.list[1].cooldown = 4
tt.timed_attacks.list[1].max_range = 9e+99
tt.timed_attacks.list[1].bullet = "meteor_bajnimen"
tt.timed_attacks.list[2] = CC("custom_attack")
tt.timed_attacks.list[2].animations = {"charge_start", "charge_loop", "charge_end"}
tt.timed_attacks.list[2].current_step = 1
tt.timed_attacks.list[2].active = false
tt.timed_attacks.list[2].steps = {{}, {}, {}}
tt.timed_attacks.list[2].steps[1].hp_threshold = 0.8
tt.timed_attacks.list[2].steps[1].hp_heal = 30
tt.timed_attacks.list[2].steps[2].hp_threshold = 0.5
tt.timed_attacks.list[2].steps[2].hp_heal = 40
tt.timed_attacks.list[2].steps[3].hp_threshold = 0.2
tt.timed_attacks.list[2].steps[3].hp_heal = 50
tt.timed_attacks.list[2].heal_every = fts(3)
tt.timed_attacks.list[2].duration = 3
tt.timed_attacks.list[2].sound = "ElvesBajNimenBossHeal"
tt.timed_attacks.list[2].hit_offset = vec_2(0, 40)
tt.timed_attacks.list[2].mod_offset = vec_2(0, 35)
--#endregion
--#region meteor_bajnimen
tt = RT("meteor_bajnimen", "arrow_hero_elves_archer_ultimate")
tt.bullet.arrive_decal = "decal_bomb_crater"
tt.bullet.hit_fx = "fx_meteor_bajnimen_explosion"
tt.bullet.max_speed = 750
tt.bullet.mod = nil
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_max = {80, 80, 200}
tt.bullet.damage_min = {80, 80, 120}
tt.render.sprites[1].name = "bajnimen_boss_storm_meteor"
tt.sound_events.insert = "ElvesBajNimenBossShadowTravel"
--#endregion
--#region fx_meteor_bajnimen_explosion
tt = RT("fx_meteor_bajnimen_explosion", "fx")

AC(tt, "sound_events")

tt.render.sprites[1].name = "fx_meteor_bajnimen_explosion"
tt.render.sprites[1].z = Z_OBJECTS
tt.sound_events.insert = "ElvesBajNimenBossShadowImpact"
--#endregion
--#region bolt_bajnimen
tt = RT("bolt_bajnimen", "bolt_enemy")
tt.bullet.damage_min = {72, 72, 72, 200}
tt.bullet.damage_max = {96, 96, 96, 300}
tt.bullet.hit_fx = "fx_bolt_bajnimen_hit"
tt.bullet.max_speed = 360
tt.render.sprites[1].prefix = "bolt_bajnimen"
tt.sound_events.insert = "BoltSorcererSound"
--#endregion
--#region fx_bolt_bajnimen_hit
tt = RT("fx_bolt_bajnimen_hit", "fx")

AC(tt, "sound_events")

tt.sound_events.insert = "ElvesBajNimenBossRangedAttack"
tt.render.sprites[1].name = "fx_bolt_bajnimen_hit"
tt.render.sprites[1].anchor.y = 0.16666666666666666
--#endregion
--#region eb_balrog
tt = RT("eb_balrog", "boss")

AC(tt, "melee", "timed_attacks")

tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(60, 0)
tt.health.dead_lifetime = 50
tt.health.hp_max = 11000
tt.health.armor = 0.7
tt.health_bar.offset = vec_2(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.info.enc_icon = 48
tt.info.i18n_key = "EB_BALROG"
tt.info.portrait = "kr3_info_portraits_enemies_0056"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_balrog.update
tt.motion.max_speed = 0.664 * FPS
tt.render.sprites[1].anchor = vec_2(0.5, 0.13)
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
tt.render.sprites[1].prefix = "eb_balrog"
tt.sound_events.death = "ElvesBalrogDeath"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.blood_color = BLOOD_ORANGE
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 40)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 45)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_SKELETON, F_POLYMORPH)
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_max = 250
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].damage_radius = 45
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].count = 10
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].hit_offset = vec_2(60, -2)
tt.melee.attacks[1].sound = "ElvesBalrogAttack"
tt.melee.attacks[1].uninterruptible = true
tt.timed_attacks.list[1] = CC("bullet_attack")
tt.timed_attacks.list[1].bullet = "bullet_balrog"
tt.timed_attacks.list[1].animation = "spit"
tt.timed_attacks.list[1].cooldown = {10, 10, 10, 9}
tt.timed_attacks.list[1].shoot_time = fts(9)
tt.timed_attacks.list[1].max_range = 1e+99
tt.timed_attacks.list[1].min_range = 0
tt.timed_attacks.list[1].bullet_start_offset = {vec_2(23, 82)}
tt.timed_attacks.list[1].sound = "ElvesBalrogSpit"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.timed_attacks.list[1].vis_flag = F_RANGED
--#endregion

--#region eb_jack
tt = RT("eb_jack", "boss")

AC(tt, "melee", "ranged", "auras", "regen")

image_y = 104
anchor_y = 12 / image_y
tt.auras.list[1] = CC("aura_attack")
tt.auras.list[1].name = "eb_jack_spawner_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = CC("aura_attack")
tt.auras.list[2].name = "werewolf_regen_aura"
tt.auras.list[2].cooldown = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(36, 0)
tt.health.armor = 0.3
tt.health.hp_max = 8888
tt.health.magic_armor = 0.3
tt.health_bar.offset = vec_2(0, 65)
tt.info.portrait = "kr2_info_portraits_enemies_0064"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.eb_jack.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_max = 196
tt.melee.attacks[1].damage_min = 120
tt.melee.attacks[1].damage_type = DAMAGE_MAGICAL
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].hit_time = fts(12)
tt.motion.max_speed = 2.5 * FPS
tt.ranged.attacks[1].bullet = "eb_jack_pumpkin"
tt.ranged.attacks[1].bullet_start_offset = {vec_2(20, 65)}
tt.ranged.attacks[1].cooldown = 4
tt.ranged.attacks[1].min_range = 40
tt.ranged.attacks[1].max_range = 190
tt.ranged.attacks[1].shoot_time = fts(28)
tt.ranged.attacks[1].hold_advance = false
tt.render.sprites[1].prefix = "enemy_headless_horseman"
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.insert = {"HWHeadlessHorsemanLaugh", "HWHeadlessHorsemanEntry"}
tt.sound_events.death = nil
tt.ui.click_rect = r(-20, -5, 40, 60)
tt.unit.blood_color = BLOOD_RED
tt.unit.can_explode = false
tt.unit.hit_offset = vec_2(0, 35)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 35)
tt.unit.hide_after_death = true
tt.regen.cooldown = 0.25
tt.regen.health = 4
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_SKELETON, F_TELEPORT, F_POLYMORPH, F_INSTAKILL, F_POISON)
--#endregion
--#region eb_jack_pumpkin
tt = RT("eb_jack_pumpkin", "bomb")
tt.bullet.damage_min = 150
tt.bullet.damage_max = 210
tt.bullet.damage_radius = 40
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.flight_time = fts(20)
tt.render.sprites[1].name = "HalloweenRider_bomb"
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.sound_events.insert = nil
--#endregion
--#region eb_jack_spawner_aura
tt = RT("eb_jack_spawner_aura", "aura")
tt.main_script.update = scripts.eb_jack_spawner_aura.update
tt.aura.cycle_time = 10
tt.min_spawn_count = 4
tt.max_spawn_count = 8
tt.creeps = {"enemy_halloween_zombie", "enemy_ghoul"}
--#endregion
--#region krdove_eb_elephant_cannibal
tt = RT("krdove_eb_elephant_cannibal", "boss")
AC(tt, "melee", "timed_attacks")
anchor_y = 0.11
anchor_x = 0.5
tt.enemy.gold = 0
image_y = 196
image_x = 340
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = vec_2(60, 0)
tt.health.dead_lifetime = 8
tt.health.hp_max = 12000
tt.health_bar.offset = vec_2(0, 95)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health.magic_armor = 0.114514
tt.info.enc_icon = 40
tt.info.portrait = "kr2_info_portraits_enemies_0024"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.main_script.update = scripts.krdove_eb_elephant_cannibal.update
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1 + fts(20)
tt.melee.attacks[1].damage_max = 600
tt.melee.attacks[1].damage_min = 200
tt.melee.attacks[1].hit_time = fts(22)
tt.melee.attacks[1].hit_offset = vec_2(60, 0)
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.timed_attacks.list[1] = CC("mod_attack")
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].cooldown = 15
tt.timed_attacks.list[1].cast_time = fts(8)
tt.timed_attacks.list[1].max_range = 210
tt.timed_attacks.list[1].mod = "mod_krdove_elephant_cannibal"
tt.timed_attacks.list[1].sound = "EnemyHealing"
tt.timed_attacks.list[1].vis_flags = F_MOD
tt.motion.max_speed = 0.45 * FPS
tt.render.sprites[1].anchor = vec_2(anchor_x, anchor_y)
tt.render.sprites[1].prefix = "krdove_eb_elephant_cannibal"
tt.render.sprites[1].angles_stickiness = {
	walk = 10
}
tt.render.sprites[1].angles_flip_vertical = {
	walk = true
}
tt.render.sprites[1].angles = {
	walk = {"walkingRightLeft", "walkingUp", "walkingDown"}
}
tt.sound_events.death = "DeathBig"
tt.sound_events.insert = "MusicBossFight"
tt.ui.click_rect = r(-50, 0, 90, 60)
tt.unit.can_explode = false
tt.unit.can_disintegrate = false
tt.unit.fade_time_after_death = 2
tt.unit.hit_offset = vec_2(0, 30)
tt.unit.marker_offset = vec_2(0, 0)
tt.unit.mod_offset = vec_2(0, 27)
tt.unit.marker_hidden = true
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.bans = bor(F_TELEPORT, F_THORN, F_POLYMORPH)
tt.vis.flags = bor(F_ENEMY, F_BOSS)

tt = RT("mod_krdove_elephant_cannibal", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_krdove_elephant_cannibal.insert
tt.main_script.update = scripts.mod_krdove_elephant_cannibal.update
tt.scale_factor = 1.2
tt.scale_delay = fts(45)
tt.heal_amount = 500
tt.render.sprites[1].prefix = "healing"
tt.render.sprites[1].size_names = {"small", "medium", "large"}
tt.render.sprites[1].name = "small"
tt.render.sprites[1].loop = false
--#endregion

local balance = require("kr1.data.balance")
local v = vec_2
local vv = vec_1

tt = E:register_t("boss_pig", "boss")
local b = balance.enemies.werebeasts.boss
E:add_comps(tt, "melee", "auras")
tt.enemy.gold = 1
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = b.armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_FREEZE)
tt.info.enc_icon = 26
tt.info.i18n_key = "ENEMY_BOSS_PIG"
tt.info.portrait = "kr5_info_portraits_enemies_0010"
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
tt.unit.hit_offset = v(0, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
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
-- tt.melee.attacks[1].hit_fx = "decal_boss_pig_attack_dust"
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].hit_offset = v(50, 0)
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

-- tt = E:register_t("decal_boss_pig_attack_dust", "decal_tween")
-- tt.render.sprites[1].animated = true
-- tt.render.sprites[1].name = "werebeast_boss_attack_dust"
-- tt.render.sprites[1].loop = false
-- tt.tween.props[1].keys = {{1, 255}, {2.5, 0}}
-- tt.render.sprites[1].scale = v(0.5, 0.5)

tt = E:register_t("decal_boss_pig_ground_fall", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "werebeast_boss_decal"
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0, 255}, {fts(22), 255}, {fts(22) + fts(5), 0}}
tt.tween.remove = true

tt = E:register_t("decal_boss_pig_ground_attack", "decal_boss_pig_ground_fall")
tt.tween.props[1].keys = {{0, 255}, {fts(18), 255}, {fts(18) + fts(5), 0}}

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

tt = E:register_t("boss_corrupted_denas", "boss")

E:add_comps(tt, "melee", "timed_attacks")

b = balance.enemies.cult_of_the_overseer.boss_corrupted_denas
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.boss_corrupted_denas.update
tt.motion.max_speed = b.speed
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_FREEZE)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.render.sprites[1].prefix = "denas_character"
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk_down"}
tt.info.i18n_key = "ENEMY_BOSS_CORRUPTED_DENAS"
tt.info.enc_icon = 28
tt.info.portrait_boss = "boss_health_bar_icon_0002"
tt.info.portrait = "kr5_info_portraits_enemies_0027"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_fx_offset = v(20, -20)
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
tt.timed_attacks.list[1].bullet_start_offset = v(0, 65)
tt.timed_attacks.list[1].bullet = "bullet_boss_corrupted_denas_spawn_entities"
tt.life_threshold_stun = b.life_threshold_stun
tt.cult_leader_template_name = "decal_stage_11_cult_leader"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.sound_transform_in = "Stage11BossCorruptedDenasTransformationIn"
tt.sound_transform_out = "Stage11BossCorruptedDenasTransformationOut"

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

tt = E:register_t("boss_cult_leader", "boss")
E:add_comps(tt, "melee", "glare_kr5")
b = balance.enemies.void_beyond.boss_cult_leader
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.boss_cult_leader.update
tt.motion.max_speed = b.speed
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_FREEZE)
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = b.close_armor
tt.health.magic_armor = b.close_magic_armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 100)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.render.sprites[1].prefix = "mutamydriasDef"
tt.render.sprites[1].exo = true
tt.render.sprites[1].flip_x = false
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {"walk", "walk", "walk"}
tt.info.i18n_key = "ENEMY_BOSS_CULT_LEADER"
tt.info.enc_icon = 40
tt.info.portrait_boss = "boss_health_bar_icon_0003"
tt.info.portrait = "kr5_info_portraits_enemies_0040"
tt.melee.attacks[1] = E:clone_c("melee_attack")
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].hit_time = fts(17)
tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_fx_offset = v(20, -20)
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
tt.melee.attacks[2].hit_decal_offset = v(80, 0)
tt.melee.attacks[2].sound = "Stage15MydriasRay"
tt.life_threshold_teleport = b.life_threshold_teleport
tt.teleport_away_duration = b.life_threshold_teleport.away_duration
tt.teleport_pos = {v(746, 444), v(695, 290), v(460, 350)}
tt.teleport_path = {2, 4, 3}
tt.cult_leader_template_name = "controller_stage_15_cult_leader_tower"
tt.glare_template_name = "controller_terrain_3_stage_15_glare"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
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

tt = E:register_t("boss_navira", "boss")
E:add_comps(tt, "melee", "corruption_kr5", "tween")
b = balance.enemies.undying_hatred.boss_navira
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.boss_navira.update
tt.motion.max_speed = b.speed
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 70)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.render.sprites[1].prefix = "navira_navira"
tt.render.sprites[1].animated = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {"idle", "idle"}
tt.render.sprites[1].angles.walk = {"idle", "idle"}
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
tt.info.i18n_key = "ENEMY_BOSS_NAVIRA"
tt.info.enc_icon = 52
tt.info.portrait_boss = "boss_health_bar_icon_0005"
tt.info.portrait = "kr5_info_portraits_enemies_0054"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_fx_offset = v(15, -10)
tt.melee.attacks[1].animation = "attack"
tt.ui.click_rect = r(-35, 0, 70, 80)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 40)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 30)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_STUN, F_FREEZE)
tt.tornado_hp_trigger = b.tornado.hp_trigger
tt.tornado_duration = b.tornado.duration
tt.tornado_speed_mult = b.tornado.speed_mult
tt.tornado_balls_count = b.tornado.fire_balls
tt.tornado_aura_t = "aura_boss_navira_tornado"
tt.fire_ball_bullet_t = "bullet_stage_19_navira_fire_ball_ray"
tt.corruption_kr5.enabled = false
tt.corruption_kr5.cooldown = b.corruption.cooldown
tt.corruption_kr5.hp = b.corruption.hp
tt.corruption_kr5.on_corrupt = scripts.boss_navira.on_corrupt
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {{0, v(43, 60)}, {fts(30), v(0, 0)}}
tt.mod_heal = "mod_bullet_stage_19_navira_heal"
tt.sound_transform_in = "Stage19NaviraTornadoIn"
tt.sound_transform_out = "Stage19NaviraTornadoOut"
tt.sound_death = "Stage19NaviraDeath"

tt = E:register_t("aura_boss_navira_tornado", "aura")
b = balance.enemies.undying_hatred.boss_navira.tornado
tt.aura.damage_min = b.damage
tt.aura.damage_max = b.damage
tt.aura.damage_type = b.damage_type
tt.aura.radius = b.radius
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING, F_ENEMY)
tt.aura.cycle_time = b.cycle_time
tt.aura.duration = 1e+99
tt.aura.track_source = true
tt.main_script.insert = scripts.aura_apply_damage.insert
tt.main_script.update = scripts.aura_apply_damage.update

tt = E:register_t("boss_machinist", "boss")
E:add_comps(tt, "ranged", "tween")
b = balance.enemies.hammer_and_anvil.boss_machinist
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.boss_machinist.update
tt.motion.max_speed = b.speed
tt.enemy.lives_cost = 20
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 150)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.flight_height = 80
tt.render.sprites[1].prefix = "dlcdwarfbossstage02Def"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {"run", "run"}
tt.render.sprites[1].angles.walk = {"run", "run"}
tt.render.sprites[1].z = Z_FLYING_HEROES
tt.render.sprites[1].offset = v(0, 500)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "decal_flying_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.descend_duration = 2
tt.tween.remove = false
tt.tween.remove = false
tt.tween.props[1].keys = {{0, v(0, 500)}, {tt.descend_duration, v(0, -tt.flight_height)}}
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[2] = E:clone_c("tween_prop")
tt.tween.props[2].keys = {{0, vv(3)}, {tt.descend_duration, vv(1)}}
tt.tween.props[2].name = "scale"
tt.tween.props[2].sprite_id = 2
tt.tween.props[2].interp = "sine"
tt.tween.props[3] = E:clone_c("tween_prop")
tt.tween.props[3].keys = {{0, 0.1}, {tt.descend_duration, 255}}
tt.tween.props[3].name = "alpha"
tt.tween.props[3].sprite_id = 2
tt.tween.props[3].interp = "sine"
tt.info.i18n_key = "ENEMY_BOSS_MACHINIST"
tt.info.enc_icon = 79
tt.info.portrait_boss = "boss_health_bar_icon_0006"
tt.info.portrait = "kr5_info_portraits_enemies_0086"
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].shoot_time = fts(0)
tt.ranged.attacks[1].bullet = "bullet_boss_machinist"
tt.ranged.attacks[1].animation = "attackloop"
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING, F_ENEMY)
tt.ranged.attacks[1].bullet_start_offset = {v(0, tt.flight_height + 40), v(0, tt.flight_height + 40)}
tt.ui.click_rect = r(-35, tt.flight_height - 20, 70, 70)
tt.unit.can_explode = false
tt.unit.hit_offset = v(8, tt.flight_height + 25)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, tt.flight_height + 20)
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(F_ENEMY, F_BOSS, F_FLYING)
tt.vis.bans = bor(F_BLOCK, F_STUN)
tt.sound_death = "Stage24Outro"
tt.stop_cooldown = b.stop_cooldown
tt.attacks_count = b.attacks_count
tt.burn_aura_t = "aura_boss_machinist_burn"
tt.death_smoke_fx = "fx_boss_machinist_death_smoke"
tt.death_particle_fx = "fx_boss_machinist_death_particle"

tt = E:register_t("boss_deformed_grymbeard", "boss")
b = balance.enemies.hammer_and_anvil.boss_deformed_grymbeard
tt.render = nil
tt.motion.max_speed = 0
tt.enemy.lives_cost = 20
tt.health.immune_to = DAMAGE_ALL
tt.clones_to_die = b.clones_to_die
tt.main_script.update = scripts.boss_deformed_grymbeard.update
tt.on_clone_death_f = scripts.boss_deformed_grymbeard.on_clone_death
tt.info.i18n_key = "ENEMY_BOSS_DEFORMED_GRYMBEARD"
tt.info.enc_icon = 78
tt.info.portrait_boss = "boss_health_bar_icon_0007"
tt.ui.click_rect = r(0, 0, 0, 0)
tt.ui.can_click = false
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_ALL)
tt.sound_damage = "Stage26BFGrymbeardDamaged"
tt.sound_death = "Stage19NaviraDeath"
tt.boss_decal_t = "decal_stage_26_boss"

tt = E:register_t("boss_grymbeard", "boss")
E:add_comps(tt, "melee", "ranged")
b = balance.enemies.hammer_and_anvil.boss_grymbeard
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.boss_grymbeard.update
tt.motion.max_speed = b.speed
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(40, 0)
tt.health.armor = b.armor
tt.health.magic_armor = b.magic_armor
tt.health.dead_lifetime = 100
tt.health.hp_max = b.hp
tt.health_bar.offset = v(0, 110)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM_LARGE
tt.render.sprites[1].prefix = "dclenanos_stage05_grymbossDef"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.idle = {"idle", "idle"}
tt.render.sprites[1].angles.walk = {"walkside", "walkdown", "walkdown"}
tt.render.sprites[1].flip_x = true
tt.render.sprites[1].z = Z_OBJECTS
tt.info.i18n_key = "ENEMY_BOSS_GRYMBEARD"
tt.info.enc_icon = 80
tt.info.portrait_boss = "boss_health_bar_icon_0009"
tt.info.portrait = "kr5_info_portraits_enemies_0088"
tt.melee.attacks[1] = E:clone_c("area_attack")
tt.melee.attacks[1].cooldown = b.melee_attack.cooldown
tt.melee.attacks[1].damage_max = b.melee_attack.damage_max
tt.melee.attacks[1].damage_min = b.melee_attack.damage_min
tt.melee.attacks[1].damage_radius = b.melee_attack.damage_radius
tt.melee.attacks[1].hit_time = fts(27)
tt.melee.attacks[1].damage_type = bor(b.melee_attack.damage_type, DAMAGE_NO_DODGE)
tt.melee.attacks[1].hit_fx_offset = v(15, -10)
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].hit_decal = "decal_boss_grymbeard_area_attack"
tt.melee.attacks[1].hit_offset = v(60, 0)
tt.melee.attacks[1].sound = "Stage27BFGrymbeardMeleeAttack"
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].cooldown = b.ranged_attack.cooldown
tt.ranged.attacks[1].shoot_time = fts(25)
tt.ranged.attacks[1].bullet = "bullet_boss_grymbeard"
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].min_range = b.ranged_attack.min_range
tt.ranged.attacks[1].max_range = b.ranged_attack.max_range
tt.ranged.attacks[1].vis_flags = bor(F_RANGED, F_AREA)
tt.ranged.attacks[1].vis_bans = bor(F_FLYING, F_ENEMY)
tt.ranged.attacks[1].bullet_start_offset = {v(-35, 125), v(35, 125)}
tt.ui.click_rect = r(-40, 0, 80, 85)
tt.unit.can_explode = false
tt.unit.hit_offset = v(0, 30)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 60)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.show_blood_pool = false
tt.unit.size = UNIT_SIZE_LARGE
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_STUN)
tt.death_bullet_clone = "bullet_boss_grymbeard_death_clone"
tt.death_bullet_boss = "bullet_boss_grymbeard_death_boss"
tt.death_bullet_scrap = "bullet_boss_grymbeard_death_scrap_"
tt.sound_death = "Stage27BFGrymbeardDeath"

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
tt.render.sprites[2].offset = v(20, 620)
tt.config_per_wave = b.config_per_wave
tt.hit_point_template = "enemy_overseer_hit_point"
tt.hit_point_pos = {v(415, 425), v(520, 400), v(625, 425)}
tt.health.armor = 0
tt.health.hp_max = b.hp
tt.health.ignore_delete_after = true
tt.info.i18n_key = "ENEMY_BOSS_OVERSEER"
tt.info.enc_icon = 42
tt.info.portrait_boss = "boss_health_bar_icon_0004"
tt.phase_per_hp_threshold = b.phase_per_hp_threshold
tt.phase_per_time = b.phase_per_time
tt.change_tower_cooldown = b.change_tower_cooldown
tt.change_tower_amount = b.change_tower_amount
tt.disable_tower_cooldown = b.disable_tower_cooldown
tt.glare_cooldown = b.glare_cooldown
tt.glare_duration = b.glare_duration
tt.heal_cooldown = b.heal_cooldown
tt.heal_duration = b.heal_duration
tt.heal_per_second = b.heal_per_second
tt.downgrade_cooldown = b.downgrade_cooldown
tt.downgrade_count = b.downgrade_count
tt.holders_close = {"6", "7", "8", "9", "10"}
tt.swap_delay = fts(60)
tt.destroy_tower_cooldown = b.destroy_tower_cooldown
tt.destroy_holder_cooldown = b.destroy_holder.cooldown
tt.holders_to_destroy = {
	"1",
	"13",
	"10",
	"2",
	"12",
	"4",
	"9",
	"5",
	"14",
	"3",
	"11",
	"6",
	"8",
	"15",
	"7"
}
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
tt.info.portrait = "kr5_info_portraits_enemies_0043"
tt.sound_rumble = "Stage16OverseerRumble"
tt.sound_unchain_center = "Stage16OverseerUnchainCenter"
tt.sound_teleport_charge = "Stage16OverseerTeleportCharge"
tt.sound_teleport = "Stage16OverseerTeleport"
tt.sound_destroy_charge = "Stage16OverseerDestroyCharge"
tt.sound_destroy_ray = "Stage16OverseerDestroyRay"
tt.sound_destroy_explosion = "Stage16OverseerDestroyExplosion"
tt.sound_hurt = "Stage16OverseerHurt"
tt.sound_death = "Stage16OverseerDeath"

tt = E:register_t("mod_heal_overseer", "modifier")
E:add_comps(tt, "hps")
tt.main_script.insert = scripts.mod_hps.insert
tt.main_script.update = scripts.mod_hps.update
tt.hps.heal_every = 1

tt = E:register_t("bullet_stage_16_overseer_destroy_holders", "bullet")
tt.bullet.damage_type = DAMAGE_NONE
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.hit_time = fts(2)
tt.hit_fx_only_no_target = true
tt.image_width = 381
tt.main_script.update = scripts.ray5_simple.update
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].name = "overseer_fx_overseer_destroyray_loop"
tt.render.sprites[1].loop = false
tt.sound_events.insert = "TowerArcaneWizardBasicAttack"
tt.track_target = true
tt.ray_duration = fts(26)

tt = E:register_t("bullet_stage_16_overseer_downgrade_towers", "bullet_stage_16_overseer_destroy_holders")

tt = E:register_t("enemy_overseer_hit_point", "enemy_KR5")
E:add_comps(tt, "glare_kr5")
tt.enemy.gold = 0
tt.enemy.melee_slot = v(0, 0)
tt.enemy.lives_cost = 1
tt.health.hp_max = b.hp
tt.health.armor = 0
tt.health.magic_armor = 0
tt.unit.blood_color = BLOOD_VIOLET
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_overseer_hit_point.update
tt.health.on_damage = scripts.enemy_overseer_hit_point.on_damage
tt.motion.max_speed = 0
tt.render = nil
tt.glare_kr5.regen_hp = 15
tt.ui.click_rect = r(-30, -3, 60, 65)
tt.ui.can_click = false
tt.ui.can_select = false
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(F_BLOCK, F_FREEZE, F_STUN) --bor(F_MOD, F_BLOCK)
tt.move_bounds = v(25, 25)
tt.move_speed = v(0.2, 0.2)

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
tt.check_pos = v(282, 556)
tt.check_cooldown = fts(5)
tt.check_radius = 150
tt.check_vis_flags = F_ENEMY
tt.check_vis_bans = F_BOSS
tt.config = b
tt = E:register_t("controller_stage_16_mouth_right", "controller_stage_16_mouth_left")
tt.render.sprites[1].flip_x = true
b = balance.specials.stage16_overseer.mouth_right
tt.check_pos = v(721, 553)
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
tt.spawn_offset = v(90, -130)
tt.spawn_pos = {v(76, 332), v(218, 424)}
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
tt.spawn_offset = v(-80, -150)
tt.spawn_pos = {v(850, 446), v(860, 206)}
tt.spawn_path = {3, 4}
tt.tentacle_mouth_template = "controller_stage_16_tentacle_mouth_right"

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
tt.spawn_offset = {v(-40, 0), v(0, 20), v(30, 0), v(0, -30), v(-20, 0)}
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
tt.render.sprites[2].offset = v(-140, -350)
tt.phase_to_free = 4
tt.sound_rumble = "Stage16OverseerRumble"
tt.sound_unchain = "Stage16OverseerUnchainDown"
tt = E:register_t("controller_stage_16_tentacle_bottom_right", "controller_stage_16_tentacle_bottom_left")
tt.render.sprites[1].prefix = "overseer_undertent2Def"
tt.render.sprites[2].prefix = "overseer_underbacktents2Def"
tt.render.sprites[2].offset = v(350, -20)
tt.phase_to_free = 5
